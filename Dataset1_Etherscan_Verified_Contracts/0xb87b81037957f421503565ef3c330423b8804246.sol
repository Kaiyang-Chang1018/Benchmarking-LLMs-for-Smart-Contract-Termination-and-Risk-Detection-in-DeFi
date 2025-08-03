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
// OpenZeppelin Contracts (last updated v5.1.0) (access/IAccessControl.sol)

pragma solidity ^0.8.20;

/**
 * @dev External interface of AccessControl declared to support ERC-165 detection.
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
     * `sender` is the account that originated the contract call. This account bears the admin role (for the granted role).
     * Expected in cases where the role was granted using the internal {AccessControl-_grantRole}.
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
// OpenZeppelin Contracts (last updated v5.1.0) (access/extensions/AccessControlEnumerable.sol)

pragma solidity ^0.8.20;

import {IAccessControlEnumerable} from "./IAccessControlEnumerable.sol";
import {AccessControl} from "../AccessControl.sol";
import {EnumerableSet} from "../../utils/structs/EnumerableSet.sol";

/**
 * @dev Extension of {AccessControl} that allows enumerating the members of each role.
 */
abstract contract AccessControlEnumerable is IAccessControlEnumerable, AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(bytes32 role => EnumerableSet.AddressSet) private _roleMembers;

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
    function getRoleMember(bytes32 role, uint256 index) public view virtual returns (address) {
        return _roleMembers[role].at(index);
    }

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) public view virtual returns (uint256) {
        return _roleMembers[role].length();
    }

    /**
     * @dev Return all accounts that have `role`
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function getRoleMembers(bytes32 role) public view virtual returns (address[] memory) {
        return _roleMembers[role].values();
    }

    /**
     * @dev Overload {AccessControl-_grantRole} to track enumerable memberships
     */
    function _grantRole(bytes32 role, address account) internal virtual override returns (bool) {
        bool granted = super._grantRole(role, account);
        if (granted) {
            _roleMembers[role].add(account);
        }
        return granted;
    }

    /**
     * @dev Overload {AccessControl-_revokeRole} to track enumerable memberships
     */
    function _revokeRole(bytes32 role, address account) internal virtual override returns (bool) {
        bool revoked = super._revokeRole(role, account);
        if (revoked) {
            _roleMembers[role].remove(account);
        }
        return revoked;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (access/extensions/IAccessControlEnumerable.sol)

pragma solidity ^0.8.20;

import {IAccessControl} from "../IAccessControl.sol";

/**
 * @dev External interface of AccessControlEnumerable declared to support ERC-165 detection.
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
// OpenZeppelin Contracts (last updated v5.1.0) (interfaces/IERC4626.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../token/ERC20/IERC20.sol";
import {IERC20Metadata} from "../token/ERC20/extensions/IERC20Metadata.sol";

/**
 * @dev Interface of the ERC-4626 "Tokenized Vault Standard", as defined in
 * https://eips.ethereum.org/EIPS/eip-4626[ERC-4626].
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
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC5267.sol)

pragma solidity ^0.8.20;

interface IERC5267 {
    /**
     * @dev MAY be emitted to signal that the domain could have changed.
     */
    event EIP712DomainChanged();

    /**
     * @dev returns the fields and values that describe the domain separator used by this contract for EIP-712
     * signature.
     */
    function eip712Domain()
        external
        view
        returns (
            bytes1 fields,
            string memory name,
            string memory version,
            uint256 chainId,
            address verifyingContract,
            bytes32 salt,
            uint256[] memory extensions
        );
}
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
// OpenZeppelin Contracts (last updated v5.1.0) (proxy/Clones.sol)

pragma solidity ^0.8.20;

import {Errors} from "../utils/Errors.sol";

/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[ERC-1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 * > To simply and cheaply clone contract functionality in an immutable way, this standard specifies
 * > a minimal bytecode implementation that delegates all calls to a known, fixed address.
 *
 * The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`
 * (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the
 * deterministic method.
 */
library Clones {
    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function clone(address implementation) internal returns (address instance) {
        return clone(implementation, 0);
    }

    /**
     * @dev Same as {xref-Clones-clone-address-}[clone], but with a `value` parameter to send native currency
     * to the new contract.
     *
     * NOTE: Using a non-zero value at creation will require the contract using this function (e.g. a factory)
     * to always have enough balance for new deployments. Consider exposing this function under a payable method.
     */
    function clone(address implementation, uint256 value) internal returns (address instance) {
        if (address(this).balance < value) {
            revert Errors.InsufficientBalance(address(this).balance, value);
        }
        assembly ("memory-safe") {
            // Cleans the upper 96 bits of the `implementation` word, then packs the first 3 bytes
            // of the `implementation` address with the bytecode before the address.
            mstore(0x00, or(shr(0xe8, shl(0x60, implementation)), 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000))
            // Packs the remaining 17 bytes of `implementation` with the bytecode after the address.
            mstore(0x20, or(shl(0x78, implementation), 0x5af43d82803e903d91602b57fd5bf3))
            instance := create(value, 0x09, 0x37)
        }
        if (instance == address(0)) {
            revert Errors.FailedDeployment();
        }
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create2 opcode and a `salt` to deterministically deploy
     * the clone. Using the same `implementation` and `salt` multiple time will revert, since
     * the clones cannot be deployed twice at the same address.
     */
    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        return cloneDeterministic(implementation, salt, 0);
    }

    /**
     * @dev Same as {xref-Clones-cloneDeterministic-address-bytes32-}[cloneDeterministic], but with
     * a `value` parameter to send native currency to the new contract.
     *
     * NOTE: Using a non-zero value at creation will require the contract using this function (e.g. a factory)
     * to always have enough balance for new deployments. Consider exposing this function under a payable method.
     */
    function cloneDeterministic(
        address implementation,
        bytes32 salt,
        uint256 value
    ) internal returns (address instance) {
        if (address(this).balance < value) {
            revert Errors.InsufficientBalance(address(this).balance, value);
        }
        assembly ("memory-safe") {
            // Cleans the upper 96 bits of the `implementation` word, then packs the first 3 bytes
            // of the `implementation` address with the bytecode before the address.
            mstore(0x00, or(shr(0xe8, shl(0x60, implementation)), 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000))
            // Packs the remaining 17 bytes of `implementation` with the bytecode after the address.
            mstore(0x20, or(shl(0x78, implementation), 0x5af43d82803e903d91602b57fd5bf3))
            instance := create2(value, 0x09, 0x37, salt)
        }
        if (instance == address(0)) {
            revert Errors.FailedDeployment();
        }
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        assembly ("memory-safe") {
            let ptr := mload(0x40)
            mstore(add(ptr, 0x38), deployer)
            mstore(add(ptr, 0x24), 0x5af43d82803e903d91602b57fd5bf3ff)
            mstore(add(ptr, 0x14), implementation)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73)
            mstore(add(ptr, 0x58), salt)
            mstore(add(ptr, 0x78), keccak256(add(ptr, 0x0c), 0x37))
            predicted := and(keccak256(add(ptr, 0x43), 0x55), 0xffffffffffffffffffffffffffffffffffffffff)
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
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../IERC20.sol";
import {IERC1363} from "../../../interfaces/IERC1363.sol";
import {Address} from "../../../utils/Address.sol";

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
// OpenZeppelin Contracts (last updated v5.1.0) (utils/Address.sol)

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

        (bool success, ) = recipient.call{value: amount}("");
        if (!success) {
            revert Errors.FailedCall();
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
// OpenZeppelin Contracts (last updated v5.1.0) (utils/ReentrancyGuardTransient.sol)

pragma solidity ^0.8.24;

import {TransientSlot} from "./TransientSlot.sol";

/**
 * @dev Variant of {ReentrancyGuard} that uses transient storage.
 *
 * NOTE: This variant only works on networks where EIP-1153 is available.
 *
 * _Available since v5.1._
 */
abstract contract ReentrancyGuardTransient {
    using TransientSlot for *;

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.ReentrancyGuard")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant REENTRANCY_GUARD_STORAGE =
        0x9b779b17422d0df92223018b32b4d1fa46e071723d6817e2486d003becc55f00;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

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
        if (_reentrancyGuardEntered()) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        REENTRANCY_GUARD_STORAGE.asBoolean().tstore(true);
    }

    function _nonReentrantAfter() private {
        REENTRANCY_GUARD_STORAGE.asBoolean().tstore(false);
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return REENTRANCY_GUARD_STORAGE.asBoolean().tload();
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (utils/Strings.sol)

pragma solidity ^0.8.20;

import {Math} from "./math/Math.sol";
import {SignedMath} from "./math/SignedMath.sol";

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant HEX_DIGITS = "0123456789abcdef";
    uint8 private constant ADDRESS_LENGTH = 20;

    /**
     * @dev The `value` string doesn't fit in the specified `length`.
     */
    error StringsInsufficientHexLength(uint256 value, uint256 length);

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            assembly ("memory-safe") {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                assembly ("memory-safe") {
                    mstore8(ptr, byte(mod(value, 10), HEX_DIGITS))
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
    function toStringSigned(int256 value) internal pure returns (string memory) {
        return string.concat(value < 0 ? "-" : "", toString(SignedMath.abs(value)));
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
        uint256 localValue = value;
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = HEX_DIGITS[localValue & 0xf];
            localValue >>= 4;
        }
        if (localValue != 0) {
            revert StringsInsufficientHexLength(value, length);
        }
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal
     * representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), ADDRESS_LENGTH);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its checksummed ASCII `string` hexadecimal
     * representation, according to EIP-55.
     */
    function toChecksumHexString(address addr) internal pure returns (string memory) {
        bytes memory buffer = bytes(toHexString(addr));

        // hash the hex part of buffer (skip length + 2 bytes, length 40)
        uint256 hashValue;
        assembly ("memory-safe") {
            hashValue := shr(96, keccak256(add(buffer, 0x22), 40))
        }

        for (uint256 i = 41; i > 1; --i) {
            // possible values for buffer[i] are 48 (0) to 57 (9) and 97 (a) to 102 (f)
            if (hashValue & 0xf > 7 && uint8(buffer[i]) > 96) {
                // case shift by xoring with 0x20
                buffer[i] ^= 0x20;
            }
            hashValue >>= 4;
        }
        return string(buffer);
    }

    /**
     * @dev Returns true if the two strings are equal.
     */
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return bytes(a).length == bytes(b).length && keccak256(bytes(a)) == keccak256(bytes(b));
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (utils/TransientSlot.sol)
// This file was procedurally generated from scripts/generate/templates/TransientSlot.js.

pragma solidity ^0.8.24;

/**
 * @dev Library for reading and writing value-types to specific transient storage slots.
 *
 * Transient slots are often used to store temporary values that are removed after the current transaction.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 *  * Example reading and writing values using transient storage:
 * ```solidity
 * contract Lock {
 *     using TransientSlot for *;
 *
 *     // Define the slot. Alternatively, use the SlotDerivation library to derive the slot.
 *     bytes32 internal constant _LOCK_SLOT = 0xf4678858b2b588224636b8522b729e7722d32fc491da849ed75b3fdf3c84f542;
 *
 *     modifier locked() {
 *         require(!_LOCK_SLOT.asBoolean().tload());
 *
 *         _LOCK_SLOT.asBoolean().tstore(true);
 *         _;
 *         _LOCK_SLOT.asBoolean().tstore(false);
 *     }
 * }
 * ```
 *
 * TIP: Consider using this library along with {SlotDerivation}.
 */
library TransientSlot {
    /**
     * @dev UDVT that represent a slot holding a address.
     */
    type AddressSlot is bytes32;

    /**
     * @dev Cast an arbitrary slot to a AddressSlot.
     */
    function asAddress(bytes32 slot) internal pure returns (AddressSlot) {
        return AddressSlot.wrap(slot);
    }

    /**
     * @dev UDVT that represent a slot holding a bool.
     */
    type BooleanSlot is bytes32;

    /**
     * @dev Cast an arbitrary slot to a BooleanSlot.
     */
    function asBoolean(bytes32 slot) internal pure returns (BooleanSlot) {
        return BooleanSlot.wrap(slot);
    }

    /**
     * @dev UDVT that represent a slot holding a bytes32.
     */
    type Bytes32Slot is bytes32;

    /**
     * @dev Cast an arbitrary slot to a Bytes32Slot.
     */
    function asBytes32(bytes32 slot) internal pure returns (Bytes32Slot) {
        return Bytes32Slot.wrap(slot);
    }

    /**
     * @dev UDVT that represent a slot holding a uint256.
     */
    type Uint256Slot is bytes32;

    /**
     * @dev Cast an arbitrary slot to a Uint256Slot.
     */
    function asUint256(bytes32 slot) internal pure returns (Uint256Slot) {
        return Uint256Slot.wrap(slot);
    }

    /**
     * @dev UDVT that represent a slot holding a int256.
     */
    type Int256Slot is bytes32;

    /**
     * @dev Cast an arbitrary slot to a Int256Slot.
     */
    function asInt256(bytes32 slot) internal pure returns (Int256Slot) {
        return Int256Slot.wrap(slot);
    }

    /**
     * @dev Load the value held at location `slot` in transient storage.
     */
    function tload(AddressSlot slot) internal view returns (address value) {
        assembly ("memory-safe") {
            value := tload(slot)
        }
    }

    /**
     * @dev Store `value` at location `slot` in transient storage.
     */
    function tstore(AddressSlot slot, address value) internal {
        assembly ("memory-safe") {
            tstore(slot, value)
        }
    }

    /**
     * @dev Load the value held at location `slot` in transient storage.
     */
    function tload(BooleanSlot slot) internal view returns (bool value) {
        assembly ("memory-safe") {
            value := tload(slot)
        }
    }

    /**
     * @dev Store `value` at location `slot` in transient storage.
     */
    function tstore(BooleanSlot slot, bool value) internal {
        assembly ("memory-safe") {
            tstore(slot, value)
        }
    }

    /**
     * @dev Load the value held at location `slot` in transient storage.
     */
    function tload(Bytes32Slot slot) internal view returns (bytes32 value) {
        assembly ("memory-safe") {
            value := tload(slot)
        }
    }

    /**
     * @dev Store `value` at location `slot` in transient storage.
     */
    function tstore(Bytes32Slot slot, bytes32 value) internal {
        assembly ("memory-safe") {
            tstore(slot, value)
        }
    }

    /**
     * @dev Load the value held at location `slot` in transient storage.
     */
    function tload(Uint256Slot slot) internal view returns (uint256 value) {
        assembly ("memory-safe") {
            value := tload(slot)
        }
    }

    /**
     * @dev Store `value` at location `slot` in transient storage.
     */
    function tstore(Uint256Slot slot, uint256 value) internal {
        assembly ("memory-safe") {
            tstore(slot, value)
        }
    }

    /**
     * @dev Load the value held at location `slot` in transient storage.
     */
    function tload(Int256Slot slot) internal view returns (int256 value) {
        assembly ("memory-safe") {
            value := tload(slot)
        }
    }

    /**
     * @dev Store `value` at location `slot` in transient storage.
     */
    function tstore(Int256Slot slot, int256 value) internal {
        assembly ("memory-safe") {
            tstore(slot, value)
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (utils/cryptography/ECDSA.sol)

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
    function tryRecover(
        bytes32 hash,
        bytes memory signature
    ) internal pure returns (address recovered, RecoverError err, bytes32 errArg) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly ("memory-safe") {
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
     * See https://eips.ethereum.org/EIPS/eip-2098[ERC-2098 short signatures]
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address recovered, RecoverError err, bytes32 errArg) {
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
    ) internal pure returns (address recovered, RecoverError err, bytes32 errArg) {
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
// OpenZeppelin Contracts (last updated v5.1.0) (utils/cryptography/MessageHashUtils.sol)

pragma solidity ^0.8.20;

import {Strings} from "../Strings.sol";

/**
 * @dev Signature message hash utilities for producing digests to be consumed by {ECDSA} recovery or signing.
 *
 * The library provides methods for generating a hash of a message that conforms to the
 * https://eips.ethereum.org/EIPS/eip-191[ERC-191] and https://eips.ethereum.org/EIPS/eip-712[EIP 712]
 * specifications.
 */
library MessageHashUtils {
    /**
     * @dev Returns the keccak256 digest of an ERC-191 signed data with version
     * `0x45` (`personal_sign` messages).
     *
     * The digest is calculated by prefixing a bytes32 `messageHash` with
     * `"\x19Ethereum Signed Message:\n32"` and hashing the result. It corresponds with the
     * hash signed when using the https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`] JSON-RPC method.
     *
     * NOTE: The `messageHash` parameter is intended to be the result of hashing a raw message with
     * keccak256, although any bytes32 value can be safely used because the final digest will
     * be re-hashed.
     *
     * See {ECDSA-recover}.
     */
    function toEthSignedMessageHash(bytes32 messageHash) internal pure returns (bytes32 digest) {
        assembly ("memory-safe") {
            mstore(0x00, "\x19Ethereum Signed Message:\n32") // 32 is the bytes-length of messageHash
            mstore(0x1c, messageHash) // 0x1c (28) is the length of the prefix
            digest := keccak256(0x00, 0x3c) // 0x3c is the length of the prefix (0x1c) + messageHash (0x20)
        }
    }

    /**
     * @dev Returns the keccak256 digest of an ERC-191 signed data with version
     * `0x45` (`personal_sign` messages).
     *
     * The digest is calculated by prefixing an arbitrary `message` with
     * `"\x19Ethereum Signed Message:\n" + len(message)` and hashing the result. It corresponds with the
     * hash signed when using the https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`] JSON-RPC method.
     *
     * See {ECDSA-recover}.
     */
    function toEthSignedMessageHash(bytes memory message) internal pure returns (bytes32) {
        return
            keccak256(bytes.concat("\x19Ethereum Signed Message:\n", bytes(Strings.toString(message.length)), message));
    }

    /**
     * @dev Returns the keccak256 digest of an ERC-191 signed data with version
     * `0x00` (data with intended validator).
     *
     * The digest is calculated by prefixing an arbitrary `data` with `"\x19\x00"` and the intended
     * `validator` address. Then hashing the result.
     *
     * See {ECDSA-recover}.
     */
    function toDataWithIntendedValidatorHash(address validator, bytes memory data) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(hex"19_00", validator, data));
    }

    /**
     * @dev Returns the keccak256 digest of an EIP-712 typed data (ERC-191 version `0x01`).
     *
     * The digest is calculated from a `domainSeparator` and a `structHash`, by prefixing them with
     * `\x19\x01` and hashing the result. It corresponds to the hash signed by the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`] JSON-RPC method as part of EIP-712.
     *
     * See {ECDSA-recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32 digest) {
        assembly ("memory-safe") {
            let ptr := mload(0x40)
            mstore(ptr, hex"19_01")
            mstore(add(ptr, 0x02), domainSeparator)
            mstore(add(ptr, 0x22), structHash)
            digest := keccak256(ptr, 0x42)
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (utils/introspection/ERC165.sol)

pragma solidity ^0.8.20;

import {IERC165} from "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC-165 should inherit from this contract and override {supportsInterface} to check
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
// OpenZeppelin Contracts (last updated v5.1.0) (utils/math/SignedMath.sol)

pragma solidity ^0.8.20;

import {SafeCast} from "./SafeCast.sol";

/**
 * @dev Standard signed math utilities missing in the Solidity language.
 */
library SignedMath {
    /**
     * @dev Branchless ternary evaluation for `a ? b : c`. Gas costs are constant.
     *
     * IMPORTANT: This function may reduce bytecode size and consume less gas when used standalone.
     * However, the compiler may optimize Solidity ternary operations (i.e. `a ? b : c`) to only compute
     * one branch when needed, making this function more expensive.
     */
    function ternary(bool condition, int256 a, int256 b) internal pure returns (int256) {
        unchecked {
            // branchless ternary works because:
            // b ^ (a ^ b) == a
            // b ^ 0 == b
            return b ^ ((a ^ b) * int256(SafeCast.toUint(condition)));
        }
    }

    /**
     * @dev Returns the largest of two signed numbers.
     */
    function max(int256 a, int256 b) internal pure returns (int256) {
        return ternary(a > b, a, b);
    }

    /**
     * @dev Returns the smallest of two signed numbers.
     */
    function min(int256 a, int256 b) internal pure returns (int256) {
        return ternary(a < b, a, b);
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
            // Formula from the "Bit Twiddling Hacks" by Sean Eron Anderson.
            // Since `n` is a signed integer, the generated bytecode will use the SAR opcode to perform the right shift,
            // taking advantage of the most significant (or "sign" bit) in two's complement representation.
            // This opcode adds new most significant bits set to the value of the previous most significant bit. As a result,
            // the mask will either be `bytes32(0)` (if n is positive) or `~bytes32(0)` (if n is negative).
            int256 mask = n >> 255;

            // A `bytes32(0)` mask leaves the input unchanged, while a `~bytes32(0)` mask complements it.
            return uint256((n + mask) ^ mask);
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
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {ContextUpgradeable} from "../../utils/ContextUpgradeable.sol";
import {IERC20Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
import {Initializable} from "../../proxy/utils/Initializable.sol";

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
abstract contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20, IERC20Metadata, IERC20Errors {
    /// @custom:storage-location erc7201:openzeppelin.storage.ERC20
    struct ERC20Storage {
        mapping(address account => uint256) _balances;

        mapping(address account => mapping(address spender => uint256)) _allowances;

        uint256 _totalSupply;

        string _name;
        string _symbol;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.ERC20")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant ERC20StorageLocation = 0x52c63247e1f47db19d5ce0460030c497f067ca4cebf71ba98eeadabe20bace00;

    function _getERC20Storage() private pure returns (ERC20Storage storage $) {
        assembly {
            $.slot := ERC20StorageLocation
        }
    }

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    function __ERC20_init(string memory name_, string memory symbol_) internal onlyInitializing {
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {
        ERC20Storage storage $ = _getERC20Storage();
        $._name = name_;
        $._symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        ERC20Storage storage $ = _getERC20Storage();
        return $._name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        ERC20Storage storage $ = _getERC20Storage();
        return $._symbol;
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
        ERC20Storage storage $ = _getERC20Storage();
        return $._totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual returns (uint256) {
        ERC20Storage storage $ = _getERC20Storage();
        return $._balances[account];
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
        ERC20Storage storage $ = _getERC20Storage();
        return $._allowances[owner][spender];
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
        ERC20Storage storage $ = _getERC20Storage();
        if (from == address(0)) {
            // Overflow check required: The rest of the code assumes that totalSupply never overflows
            $._totalSupply += value;
        } else {
            uint256 fromBalance = $._balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                // Overflow not possible: value <= fromBalance <= totalSupply.
                $._balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                // Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
                $._totalSupply -= value;
            }
        } else {
            unchecked {
                // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
                $._balances[to] += value;
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
        ERC20Storage storage $ = _getERC20Storage();
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        $._allowances[owner][spender] = value;
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
        if (currentAllowance != type(uint256).max) {
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
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/extensions/ERC20Permit.sol)

pragma solidity ^0.8.20;

import {IERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";
import {ERC20Upgradeable} from "../ERC20Upgradeable.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {EIP712Upgradeable} from "../../../utils/cryptography/EIP712Upgradeable.sol";
import {NoncesUpgradeable} from "../../../utils/NoncesUpgradeable.sol";
import {Initializable} from "../../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the ERC-20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[ERC-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC-20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on `{IERC20-approve}`, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
abstract contract ERC20PermitUpgradeable is Initializable, ERC20Upgradeable, IERC20Permit, EIP712Upgradeable, NoncesUpgradeable {
    bytes32 private constant PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    /**
     * @dev Permit deadline has expired.
     */
    error ERC2612ExpiredSignature(uint256 deadline);

    /**
     * @dev Mismatched signature.
     */
    error ERC2612InvalidSigner(address signer, address owner);

    /**
     * @dev Initializes the {EIP712} domain separator using the `name` parameter, and setting `version` to `"1"`.
     *
     * It's a good idea to use the same `name` that is defined as the ERC-20 token name.
     */
    function __ERC20Permit_init(string memory name) internal onlyInitializing {
        __EIP712_init_unchained(name, "1");
    }

    function __ERC20Permit_init_unchained(string memory) internal onlyInitializing {}

    /**
     * @inheritdoc IERC20Permit
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        if (block.timestamp > deadline) {
            revert ERC2612ExpiredSignature(deadline);
        }

        bytes32 structHash = keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, _useNonce(owner), deadline));

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSA.recover(hash, v, r, s);
        if (signer != owner) {
            revert ERC2612InvalidSigner(signer, owner);
        }

        _approve(owner, spender, value);
    }

    /**
     * @inheritdoc IERC20Permit
     */
    function nonces(address owner) public view virtual override(IERC20Permit, NoncesUpgradeable) returns (uint256) {
        return super.nonces(owner);
    }

    /**
     * @inheritdoc IERC20Permit
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view virtual returns (bytes32) {
        return _domainSeparatorV4();
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/extensions/ERC4626.sol)

pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {ERC20Upgradeable} from "../ERC20Upgradeable.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC4626} from "@openzeppelin/contracts/interfaces/IERC4626.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {Initializable} from "../../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the ERC-4626 "Tokenized Vault Standard" as defined in
 * https://eips.ethereum.org/EIPS/eip-4626[ERC-4626].
 *
 * This extension allows the minting and burning of "shares" (represented using the ERC-20 inheritance) in exchange for
 * underlying "assets" through standardized {deposit}, {mint}, {redeem} and {burn} workflows. This contract extends
 * the ERC-20 standard. Any additional extensions included along it would affect the "shares" token represented by this
 * contract and not the "assets" token which is an independent contract.
 *
 * [CAUTION]
 * ====
 * In empty (or nearly empty) ERC-4626 vaults, deposits are at high risk of being stolen through frontrunning
 * with a "donation" to the vault that inflates the price of a share. This is variously known as a donation or inflation
 * attack and is essentially a problem of slippage. Vault deployers can protect against this attack by making an initial
 * deposit of a non-trivial amount of the asset, such that price manipulation becomes infeasible. Withdrawals may
 * similarly be affected by slippage. Users can protect against this attack as well as unexpected slippage in general by
 * verifying the amount received is as expected, using a wrapper that performs these checks such as
 * https://github.com/fei-protocol/ERC4626#erc4626router-and-base[ERC4626Router].
 *
 * Since v4.9, this implementation introduces configurable virtual assets and shares to help developers mitigate that risk.
 * The `_decimalsOffset()` corresponds to an offset in the decimal representation between the underlying asset's decimals
 * and the vault decimals. This offset also determines the rate of virtual shares to virtual assets in the vault, which
 * itself determines the initial exchange rate. While not fully preventing the attack, analysis shows that the default
 * offset (0) makes it non-profitable even if an attacker is able to capture value from multiple user deposits, as a result
 * of the value being captured by the virtual shares (out of the attacker's donation) matching the attacker's expected gains.
 * With a larger offset, the attack becomes orders of magnitude more expensive than it is profitable. More details about the
 * underlying math can be found xref:erc4626.adoc#inflation-attack[here].
 *
 * The drawback of this approach is that the virtual shares do capture (a very small) part of the value being accrued
 * to the vault. Also, if the vault experiences losses, the users try to exit the vault, the virtual shares and assets
 * will cause the first user to exit to experience reduced losses in detriment to the last users that will experience
 * bigger losses. Developers willing to revert back to the pre-v4.9 behavior just need to override the
 * `_convertToShares` and `_convertToAssets` functions.
 *
 * To learn more, check out our xref:ROOT:erc4626.adoc[ERC-4626 guide].
 * ====
 */
abstract contract ERC4626Upgradeable is Initializable, ERC20Upgradeable, IERC4626 {
    using Math for uint256;

    /// @custom:storage-location erc7201:openzeppelin.storage.ERC4626
    struct ERC4626Storage {
        IERC20 _asset;
        uint8 _underlyingDecimals;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.ERC4626")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant ERC4626StorageLocation = 0x0773e532dfede91f04b12a73d3d2acd361424f41f76b4fb79f090161e36b4e00;

    function _getERC4626Storage() private pure returns (ERC4626Storage storage $) {
        assembly {
            $.slot := ERC4626StorageLocation
        }
    }

    /**
     * @dev Attempted to deposit more assets than the max amount for `receiver`.
     */
    error ERC4626ExceededMaxDeposit(address receiver, uint256 assets, uint256 max);

    /**
     * @dev Attempted to mint more shares than the max amount for `receiver`.
     */
    error ERC4626ExceededMaxMint(address receiver, uint256 shares, uint256 max);

    /**
     * @dev Attempted to withdraw more assets than the max amount for `receiver`.
     */
    error ERC4626ExceededMaxWithdraw(address owner, uint256 assets, uint256 max);

    /**
     * @dev Attempted to redeem more shares than the max amount for `receiver`.
     */
    error ERC4626ExceededMaxRedeem(address owner, uint256 shares, uint256 max);

    /**
     * @dev Set the underlying asset contract. This must be an ERC20-compatible contract (ERC-20 or ERC-777).
     */
    function __ERC4626_init(IERC20 asset_) internal onlyInitializing {
        __ERC4626_init_unchained(asset_);
    }

    function __ERC4626_init_unchained(IERC20 asset_) internal onlyInitializing {
        ERC4626Storage storage $ = _getERC4626Storage();
        (bool success, uint8 assetDecimals) = _tryGetAssetDecimals(asset_);
        $._underlyingDecimals = success ? assetDecimals : 18;
        $._asset = asset_;
    }

    /**
     * @dev Attempts to fetch the asset decimals. A return value of false indicates that the attempt failed in some way.
     */
    function _tryGetAssetDecimals(IERC20 asset_) private view returns (bool ok, uint8 assetDecimals) {
        (bool success, bytes memory encodedDecimals) = address(asset_).staticcall(
            abi.encodeCall(IERC20Metadata.decimals, ())
        );
        if (success && encodedDecimals.length >= 32) {
            uint256 returnedDecimals = abi.decode(encodedDecimals, (uint256));
            if (returnedDecimals <= type(uint8).max) {
                return (true, uint8(returnedDecimals));
            }
        }
        return (false, 0);
    }

    /**
     * @dev Decimals are computed by adding the decimal offset on top of the underlying asset's decimals. This
     * "original" value is cached during construction of the vault contract. If this read operation fails (e.g., the
     * asset has not been created yet), a default of 18 is used to represent the underlying asset's decimals.
     *
     * See {IERC20Metadata-decimals}.
     */
    function decimals() public view virtual override(IERC20Metadata, ERC20Upgradeable) returns (uint8) {
        ERC4626Storage storage $ = _getERC4626Storage();
        return $._underlyingDecimals + _decimalsOffset();
    }

    /** @dev See {IERC4626-asset}. */
    function asset() public view virtual returns (address) {
        ERC4626Storage storage $ = _getERC4626Storage();
        return address($._asset);
    }

    /** @dev See {IERC4626-totalAssets}. */
    function totalAssets() public view virtual returns (uint256) {
        ERC4626Storage storage $ = _getERC4626Storage();
        return $._asset.balanceOf(address(this));
    }

    /** @dev See {IERC4626-convertToShares}. */
    function convertToShares(uint256 assets) public view virtual returns (uint256) {
        return _convertToShares(assets, Math.Rounding.Floor);
    }

    /** @dev See {IERC4626-convertToAssets}. */
    function convertToAssets(uint256 shares) public view virtual returns (uint256) {
        return _convertToAssets(shares, Math.Rounding.Floor);
    }

    /** @dev See {IERC4626-maxDeposit}. */
    function maxDeposit(address) public view virtual returns (uint256) {
        return type(uint256).max;
    }

    /** @dev See {IERC4626-maxMint}. */
    function maxMint(address) public view virtual returns (uint256) {
        return type(uint256).max;
    }

    /** @dev See {IERC4626-maxWithdraw}. */
    function maxWithdraw(address owner) public view virtual returns (uint256) {
        return _convertToAssets(balanceOf(owner), Math.Rounding.Floor);
    }

    /** @dev See {IERC4626-maxRedeem}. */
    function maxRedeem(address owner) public view virtual returns (uint256) {
        return balanceOf(owner);
    }

    /** @dev See {IERC4626-previewDeposit}. */
    function previewDeposit(uint256 assets) public view virtual returns (uint256) {
        return _convertToShares(assets, Math.Rounding.Floor);
    }

    /** @dev See {IERC4626-previewMint}. */
    function previewMint(uint256 shares) public view virtual returns (uint256) {
        return _convertToAssets(shares, Math.Rounding.Ceil);
    }

    /** @dev See {IERC4626-previewWithdraw}. */
    function previewWithdraw(uint256 assets) public view virtual returns (uint256) {
        return _convertToShares(assets, Math.Rounding.Ceil);
    }

    /** @dev See {IERC4626-previewRedeem}. */
    function previewRedeem(uint256 shares) public view virtual returns (uint256) {
        return _convertToAssets(shares, Math.Rounding.Floor);
    }

    /** @dev See {IERC4626-deposit}. */
    function deposit(uint256 assets, address receiver) public virtual returns (uint256) {
        uint256 maxAssets = maxDeposit(receiver);
        if (assets > maxAssets) {
            revert ERC4626ExceededMaxDeposit(receiver, assets, maxAssets);
        }

        uint256 shares = previewDeposit(assets);
        _deposit(_msgSender(), receiver, assets, shares);

        return shares;
    }

    /** @dev See {IERC4626-mint}. */
    function mint(uint256 shares, address receiver) public virtual returns (uint256) {
        uint256 maxShares = maxMint(receiver);
        if (shares > maxShares) {
            revert ERC4626ExceededMaxMint(receiver, shares, maxShares);
        }

        uint256 assets = previewMint(shares);
        _deposit(_msgSender(), receiver, assets, shares);

        return assets;
    }

    /** @dev See {IERC4626-withdraw}. */
    function withdraw(uint256 assets, address receiver, address owner) public virtual returns (uint256) {
        uint256 maxAssets = maxWithdraw(owner);
        if (assets > maxAssets) {
            revert ERC4626ExceededMaxWithdraw(owner, assets, maxAssets);
        }

        uint256 shares = previewWithdraw(assets);
        _withdraw(_msgSender(), receiver, owner, assets, shares);

        return shares;
    }

    /** @dev See {IERC4626-redeem}. */
    function redeem(uint256 shares, address receiver, address owner) public virtual returns (uint256) {
        uint256 maxShares = maxRedeem(owner);
        if (shares > maxShares) {
            revert ERC4626ExceededMaxRedeem(owner, shares, maxShares);
        }

        uint256 assets = previewRedeem(shares);
        _withdraw(_msgSender(), receiver, owner, assets, shares);

        return assets;
    }

    /**
     * @dev Internal conversion function (from assets to shares) with support for rounding direction.
     */
    function _convertToShares(uint256 assets, Math.Rounding rounding) internal view virtual returns (uint256) {
        return assets.mulDiv(totalSupply() + 10 ** _decimalsOffset(), totalAssets() + 1, rounding);
    }

    /**
     * @dev Internal conversion function (from shares to assets) with support for rounding direction.
     */
    function _convertToAssets(uint256 shares, Math.Rounding rounding) internal view virtual returns (uint256) {
        return shares.mulDiv(totalAssets() + 1, totalSupply() + 10 ** _decimalsOffset(), rounding);
    }

    /**
     * @dev Deposit/mint common workflow.
     */
    function _deposit(address caller, address receiver, uint256 assets, uint256 shares) internal virtual {
        ERC4626Storage storage $ = _getERC4626Storage();
        // If _asset is ERC-777, `transferFrom` can trigger a reentrancy BEFORE the transfer happens through the
        // `tokensToSend` hook. On the other hand, the `tokenReceived` hook, that is triggered after the transfer,
        // calls the vault, which is assumed not malicious.
        //
        // Conclusion: we need to do the transfer before we mint so that any reentrancy would happen before the
        // assets are transferred and before the shares are minted, which is a valid state.
        // slither-disable-next-line reentrancy-no-eth
        SafeERC20.safeTransferFrom($._asset, caller, address(this), assets);
        _mint(receiver, shares);

        emit Deposit(caller, receiver, assets, shares);
    }

    /**
     * @dev Withdraw/redeem common workflow.
     */
    function _withdraw(
        address caller,
        address receiver,
        address owner,
        uint256 assets,
        uint256 shares
    ) internal virtual {
        ERC4626Storage storage $ = _getERC4626Storage();
        if (caller != owner) {
            _spendAllowance(owner, caller, shares);
        }

        // If _asset is ERC-777, `transfer` can trigger a reentrancy AFTER the transfer happens through the
        // `tokensReceived` hook. On the other hand, the `tokensToSend` hook, that is triggered before the transfer,
        // calls the vault, which is assumed not malicious.
        //
        // Conclusion: we need to do the transfer after the burn so that any reentrancy would happen after the
        // shares are burned and after the assets are transferred, which is a valid state.
        _burn(owner, shares);
        SafeERC20.safeTransfer($._asset, receiver, assets);

        emit Withdraw(caller, receiver, owner, assets, shares);
    }

    function _decimalsOffset() internal view virtual returns (uint8) {
        return 0;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;
import {Initializable} from "../proxy/utils/Initializable.sol";

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

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.1) (utils/Multicall.sol)

pragma solidity ^0.8.20;

import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {ContextUpgradeable} from "./ContextUpgradeable.sol";
import {Initializable} from "../proxy/utils/Initializable.sol";

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
abstract contract MulticallUpgradeable is Initializable, ContextUpgradeable {
    function __Multicall_init() internal onlyInitializing {
    }

    function __Multicall_init_unchained() internal onlyInitializing {
    }
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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Nonces.sol)
pragma solidity ^0.8.20;
import {Initializable} from "../proxy/utils/Initializable.sol";

/**
 * @dev Provides tracking nonces for addresses. Nonces will only increment.
 */
abstract contract NoncesUpgradeable is Initializable {
    /**
     * @dev The nonce used for an `account` is not the expected current nonce.
     */
    error InvalidAccountNonce(address account, uint256 currentNonce);

    /// @custom:storage-location erc7201:openzeppelin.storage.Nonces
    struct NoncesStorage {
        mapping(address account => uint256) _nonces;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.Nonces")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant NoncesStorageLocation = 0x5ab42ced628888259c08ac98db1eb0cf702fc1501344311d8b100cd1bfe4bb00;

    function _getNoncesStorage() private pure returns (NoncesStorage storage $) {
        assembly {
            $.slot := NoncesStorageLocation
        }
    }

    function __Nonces_init() internal onlyInitializing {
    }

    function __Nonces_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev Returns the next unused nonce for an address.
     */
    function nonces(address owner) public view virtual returns (uint256) {
        NoncesStorage storage $ = _getNoncesStorage();
        return $._nonces[owner];
    }

    /**
     * @dev Consumes a nonce.
     *
     * Returns the current value and increments nonce.
     */
    function _useNonce(address owner) internal virtual returns (uint256) {
        NoncesStorage storage $ = _getNoncesStorage();
        // For each account, the nonce has an initial value of 0, can only be incremented by one, and cannot be
        // decremented or reset. This guarantees that the nonce never overflows.
        unchecked {
            // It is important to do x++ and not ++x here.
            return $._nonces[owner]++;
        }
    }

    /**
     * @dev Same as {_useNonce} but checking that `nonce` is the next valid for `owner`.
     */
    function _useCheckedNonce(address owner, uint256 nonce) internal virtual {
        uint256 current = _useNonce(owner);
        if (nonce != current) {
            revert InvalidAccountNonce(owner, current);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (utils/cryptography/EIP712.sol)

pragma solidity ^0.8.20;

import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {IERC5267} from "@openzeppelin/contracts/interfaces/IERC5267.sol";
import {Initializable} from "../../proxy/utils/Initializable.sol";

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP-712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding scheme specified in the EIP requires a domain separator and a hash of the typed structured data, whose
 * encoding is very generic and therefore its implementation in Solidity is not feasible, thus this contract
 * does not implement the encoding itself. Protocols need to implement the type-specific encoding they need in order to
 * produce the hash of their typed data using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP-712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * NOTE: In the upgradeable version of this contract, the cached values will correspond to the address, and the domain
 * separator of the implementation contract. This will cause the {_domainSeparatorV4} function to always rebuild the
 * separator from the immutable values, which is cheaper than accessing a cached version in cold storage.
 */
abstract contract EIP712Upgradeable is Initializable, IERC5267 {
    bytes32 private constant TYPE_HASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    /// @custom:storage-location erc7201:openzeppelin.storage.EIP712
    struct EIP712Storage {
        /// @custom:oz-renamed-from _HASHED_NAME
        bytes32 _hashedName;
        /// @custom:oz-renamed-from _HASHED_VERSION
        bytes32 _hashedVersion;

        string _name;
        string _version;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.EIP712")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant EIP712StorageLocation = 0xa16a46d94261c7517cc8ff89f61c0ce93598e3c849801011dee649a6a557d100;

    function _getEIP712Storage() private pure returns (EIP712Storage storage $) {
        assembly {
            $.slot := EIP712StorageLocation
        }
    }

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP-712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     *
     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
     * contract upgrade].
     */
    function __EIP712_init(string memory name, string memory version) internal onlyInitializing {
        __EIP712_init_unchained(name, version);
    }

    function __EIP712_init_unchained(string memory name, string memory version) internal onlyInitializing {
        EIP712Storage storage $ = _getEIP712Storage();
        $._name = name;
        $._version = version;

        // Reset prior values in storage if upgrading
        $._hashedName = 0;
        $._hashedVersion = 0;
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        return _buildDomainSeparator();
    }

    function _buildDomainSeparator() private view returns (bytes32) {
        return keccak256(abi.encode(TYPE_HASH, _EIP712NameHash(), _EIP712VersionHash(), block.chainid, address(this)));
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return MessageHashUtils.toTypedDataHash(_domainSeparatorV4(), structHash);
    }

    /**
     * @dev See {IERC-5267}.
     */
    function eip712Domain()
        public
        view
        virtual
        returns (
            bytes1 fields,
            string memory name,
            string memory version,
            uint256 chainId,
            address verifyingContract,
            bytes32 salt,
            uint256[] memory extensions
        )
    {
        EIP712Storage storage $ = _getEIP712Storage();
        // If the hashed name and version in storage are non-zero, the contract hasn't been properly initialized
        // and the EIP712 domain is not reliable, as it will be missing name and version.
        require($._hashedName == 0 && $._hashedVersion == 0, "EIP712: Uninitialized");

        return (
            hex"0f", // 01111
            _EIP712Name(),
            _EIP712Version(),
            block.chainid,
            address(this),
            bytes32(0),
            new uint256[](0)
        );
    }

    /**
     * @dev The name parameter for the EIP712 domain.
     *
     * NOTE: This function reads from storage by default, but can be redefined to return a constant value if gas costs
     * are a concern.
     */
    function _EIP712Name() internal view virtual returns (string memory) {
        EIP712Storage storage $ = _getEIP712Storage();
        return $._name;
    }

    /**
     * @dev The version parameter for the EIP712 domain.
     *
     * NOTE: This function reads from storage by default, but can be redefined to return a constant value if gas costs
     * are a concern.
     */
    function _EIP712Version() internal view virtual returns (string memory) {
        EIP712Storage storage $ = _getEIP712Storage();
        return $._version;
    }

    /**
     * @dev The hash of the name parameter for the EIP712 domain.
     *
     * NOTE: In previous versions this function was virtual. In this version you should override `_EIP712Name` instead.
     */
    function _EIP712NameHash() internal view returns (bytes32) {
        EIP712Storage storage $ = _getEIP712Storage();
        string memory name = _EIP712Name();
        if (bytes(name).length > 0) {
            return keccak256(bytes(name));
        } else {
            // If the name is empty, the contract may have been upgraded without initializing the new storage.
            // We return the name hash in storage if non-zero, otherwise we assume the name is empty by design.
            bytes32 hashedName = $._hashedName;
            if (hashedName != 0) {
                return hashedName;
            } else {
                return keccak256("");
            }
        }
    }

    /**
     * @dev The hash of the version parameter for the EIP712 domain.
     *
     * NOTE: In previous versions this function was virtual. In this version you should override `_EIP712Version` instead.
     */
    function _EIP712VersionHash() internal view returns (bytes32) {
        EIP712Storage storage $ = _getEIP712Storage();
        string memory version = _EIP712Version();
        if (bytes(version).length > 0) {
            return keccak256(bytes(version));
        } else {
            // If the version is empty, the contract may have been upgraded without initializing the new storage.
            // We return the version hash in storage if non-zero, otherwise we assume the version is empty by design.
            bytes32 hashedVersion = $._hashedVersion;
            if (hashedVersion != 0) {
                return hashedVersion;
            } else {
                return keccak256("");
            }
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (utils/introspection/ERC165.sol)

pragma solidity ^0.8.20;

import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {Initializable} from "../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC-165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 */
abstract contract ERC165Upgradeable is Initializable, IERC165 {
    function __ERC165_init() internal onlyInitializing {
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}
// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity ^0.8.0;

type EC is uint256;

/// @title ExecutionContext
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice This library provides functions for managing the execution context in the Ethereum Vault Connector.
/// @dev The execution context is a bit field that stores the following information:
/// @dev - on behalf of account - an account on behalf of which the currently executed operation is being performed
/// @dev - checks deferred flag - used to indicate whether checks are deferred
/// @dev - checks in progress flag - used to indicate that the account/vault status checks are in progress. This flag is
/// used to prevent re-entrancy.
/// @dev - control collateral in progress flag - used to indicate that the control collateral is in progress. This flag
/// is used to prevent re-entrancy.
/// @dev - operator authenticated flag - used to indicate that the currently executed operation is being performed by
/// the account operator
/// @dev - simulation flag - used to indicate that the currently executed batch call is a simulation
/// @dev - stamp - dummy value for optimization purposes
library ExecutionContext {
    uint256 internal constant ON_BEHALF_OF_ACCOUNT_MASK =
        0x000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
    uint256 internal constant CHECKS_DEFERRED_MASK = 0x0000000000000000000000FF0000000000000000000000000000000000000000;
    uint256 internal constant CHECKS_IN_PROGRESS_MASK =
        0x00000000000000000000FF000000000000000000000000000000000000000000;
    uint256 internal constant CONTROL_COLLATERAL_IN_PROGRESS_LOCK_MASK =
        0x000000000000000000FF00000000000000000000000000000000000000000000;
    uint256 internal constant OPERATOR_AUTHENTICATED_MASK =
        0x0000000000000000FF0000000000000000000000000000000000000000000000;
    uint256 internal constant SIMULATION_MASK = 0x00000000000000FF000000000000000000000000000000000000000000000000;
    uint256 internal constant STAMP_OFFSET = 200;

    // None of the functions below modifies the state. All the functions operate on the copy
    // of the execution context and return its modified value as a result. In order to update
    // one should use the result of the function call as a new execution context value.

    function getOnBehalfOfAccount(EC self) internal pure returns (address result) {
        result = address(uint160(EC.unwrap(self) & ON_BEHALF_OF_ACCOUNT_MASK));
    }

    function setOnBehalfOfAccount(EC self, address account) internal pure returns (EC result) {
        result = EC.wrap((EC.unwrap(self) & ~ON_BEHALF_OF_ACCOUNT_MASK) | uint160(account));
    }

    function areChecksDeferred(EC self) internal pure returns (bool result) {
        result = EC.unwrap(self) & CHECKS_DEFERRED_MASK != 0;
    }

    function setChecksDeferred(EC self) internal pure returns (EC result) {
        result = EC.wrap(EC.unwrap(self) | CHECKS_DEFERRED_MASK);
    }

    function areChecksInProgress(EC self) internal pure returns (bool result) {
        result = EC.unwrap(self) & CHECKS_IN_PROGRESS_MASK != 0;
    }

    function setChecksInProgress(EC self) internal pure returns (EC result) {
        result = EC.wrap(EC.unwrap(self) | CHECKS_IN_PROGRESS_MASK);
    }

    function isControlCollateralInProgress(EC self) internal pure returns (bool result) {
        result = EC.unwrap(self) & CONTROL_COLLATERAL_IN_PROGRESS_LOCK_MASK != 0;
    }

    function setControlCollateralInProgress(EC self) internal pure returns (EC result) {
        result = EC.wrap(EC.unwrap(self) | CONTROL_COLLATERAL_IN_PROGRESS_LOCK_MASK);
    }

    function isOperatorAuthenticated(EC self) internal pure returns (bool result) {
        result = EC.unwrap(self) & OPERATOR_AUTHENTICATED_MASK != 0;
    }

    function setOperatorAuthenticated(EC self) internal pure returns (EC result) {
        result = EC.wrap(EC.unwrap(self) | OPERATOR_AUTHENTICATED_MASK);
    }

    function clearOperatorAuthenticated(EC self) internal pure returns (EC result) {
        result = EC.wrap(EC.unwrap(self) & ~OPERATOR_AUTHENTICATED_MASK);
    }

    function isSimulationInProgress(EC self) internal pure returns (bool result) {
        result = EC.unwrap(self) & SIMULATION_MASK != 0;
    }

    function setSimulationInProgress(EC self) internal pure returns (EC result) {
        result = EC.wrap(EC.unwrap(self) | SIMULATION_MASK);
    }
}
// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity >=0.8.0;

/// @title IEVC
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice This interface defines the methods for the Ethereum Vault Connector.
interface IEVC {
    /// @notice A struct representing a batch item.
    /// @dev Each batch item represents a single operation to be performed within a checks deferred context.
    struct BatchItem {
        /// @notice The target contract to be called.
        address targetContract;
        /// @notice The account on behalf of which the operation is to be performed. msg.sender must be authorized to
        /// act on behalf of this account. Must be address(0) if the target contract is the EVC itself.
        address onBehalfOfAccount;
        /// @notice The amount of value to be forwarded with the call. If the value is type(uint256).max, the whole
        /// balance of the EVC contract will be forwarded. Must be 0 if the target contract is the EVC itself.
        uint256 value;
        /// @notice The encoded data which is called on the target contract.
        bytes data;
    }

    /// @notice A struct representing the result of a batch item operation.
    /// @dev Used only for simulation purposes.
    struct BatchItemResult {
        /// @notice A boolean indicating whether the operation was successful.
        bool success;
        /// @notice The result of the operation.
        bytes result;
    }

    /// @notice A struct representing the result of the account or vault status check.
    /// @dev Used only for simulation purposes.
    struct StatusCheckResult {
        /// @notice The address of the account or vault for which the check was performed.
        address checkedAddress;
        /// @notice A boolean indicating whether the status of the account or vault is valid.
        bool isValid;
        /// @notice The result of the check.
        bytes result;
    }

    /// @notice Returns current raw execution context.
    /// @dev When checks in progress, on behalf of account is always address(0).
    /// @return context Current raw execution context.
    function getRawExecutionContext() external view returns (uint256 context);

    /// @notice Returns an account on behalf of which the operation is being executed at the moment and whether the
    /// controllerToCheck is an enabled controller for that account.
    /// @dev This function should only be used by external smart contracts if msg.sender is the EVC. Otherwise, the
    /// account address returned must not be trusted.
    /// @dev When checks in progress, on behalf of account is always address(0). When address is zero, the function
    /// reverts to protect the consumer from ever relying on the on behalf of account address which is in its default
    /// state.
    /// @param controllerToCheck The address of the controller for which it is checked whether it is an enabled
    /// controller for the account on behalf of which the operation is being executed at the moment.
    /// @return onBehalfOfAccount An account that has been authenticated and on behalf of which the operation is being
    /// executed at the moment.
    /// @return controllerEnabled A boolean value that indicates whether controllerToCheck is an enabled controller for
    /// the account on behalf of which the operation is being executed at the moment. Always false if controllerToCheck
    /// is address(0).
    function getCurrentOnBehalfOfAccount(address controllerToCheck)
        external
        view
        returns (address onBehalfOfAccount, bool controllerEnabled);

    /// @notice Checks if checks are deferred.
    /// @return A boolean indicating whether checks are deferred.
    function areChecksDeferred() external view returns (bool);

    /// @notice Checks if checks are in progress.
    /// @return A boolean indicating whether checks are in progress.
    function areChecksInProgress() external view returns (bool);

    /// @notice Checks if control collateral is in progress.
    /// @return A boolean indicating whether control collateral is in progress.
    function isControlCollateralInProgress() external view returns (bool);

    /// @notice Checks if an operator is authenticated.
    /// @return A boolean indicating whether an operator is authenticated.
    function isOperatorAuthenticated() external view returns (bool);

    /// @notice Checks if a simulation is in progress.
    /// @return A boolean indicating whether a simulation is in progress.
    function isSimulationInProgress() external view returns (bool);

    /// @notice Checks whether the specified account and the other account have the same owner.
    /// @dev The function is used to check whether one account is authorized to perform operations on behalf of the
    /// other. Accounts are considered to have a common owner if they share the first 19 bytes of their address.
    /// @param account The address of the account that is being checked.
    /// @param otherAccount The address of the other account that is being checked.
    /// @return A boolean flag that indicates whether the accounts have the same owner.
    function haveCommonOwner(address account, address otherAccount) external pure returns (bool);

    /// @notice Returns the address prefix of the specified account.
    /// @dev The address prefix is the first 19 bytes of the account address.
    /// @param account The address of the account whose address prefix is being retrieved.
    /// @return A bytes19 value that represents the address prefix of the account.
    function getAddressPrefix(address account) external pure returns (bytes19);

    /// @notice Returns the owner for the specified account.
    /// @dev The function returns address(0) if the owner is not registered. Registration of the owner happens on the
    /// initial
    /// interaction with the EVC that requires authentication of an owner.
    /// @param account The address of the account whose owner is being retrieved.
    /// @return owner The address of the account owner. An account owner is an EOA/smart contract which address matches
    /// the first 19 bytes of the account address.
    function getAccountOwner(address account) external view returns (address);

    /// @notice Checks if lockdown mode is enabled for a given address prefix.
    /// @param addressPrefix The address prefix to check for lockdown mode status.
    /// @return A boolean indicating whether lockdown mode is enabled.
    function isLockdownMode(bytes19 addressPrefix) external view returns (bool);

    /// @notice Checks if permit functionality is disabled for a given address prefix.
    /// @param addressPrefix The address prefix to check for permit functionality status.
    /// @return A boolean indicating whether permit functionality is disabled.
    function isPermitDisabledMode(bytes19 addressPrefix) external view returns (bool);

    /// @notice Returns the current nonce for a given address prefix and nonce namespace.
    /// @dev Each nonce namespace provides 256 bit nonce that has to be used sequentially. There's no requirement to use
    /// all the nonces for a given nonce namespace before moving to the next one which allows to use permit messages in
    /// a non-sequential manner.
    /// @param addressPrefix The address prefix for which the nonce is being retrieved.
    /// @param nonceNamespace The nonce namespace for which the nonce is being retrieved.
    /// @return nonce The current nonce for the given address prefix and nonce namespace.
    function getNonce(bytes19 addressPrefix, uint256 nonceNamespace) external view returns (uint256 nonce);

    /// @notice Returns the bit field for a given address prefix and operator.
    /// @dev The bit field is used to store information about authorized operators for a given address prefix. Each bit
    /// in the bit field corresponds to one account belonging to the same owner. If the bit is set, the operator is
    /// authorized for the account.
    /// @param addressPrefix The address prefix for which the bit field is being retrieved.
    /// @param operator The address of the operator for which the bit field is being retrieved.
    /// @return operatorBitField The bit field for the given address prefix and operator. The bit field defines which
    /// accounts the operator is authorized for. It is a 256-position binary array like 0...010...0, marking the account
    /// positionally in a uint256. The position in the bit field corresponds to the account ID (0-255), where 0 is the
    /// owner account's ID.
    function getOperator(bytes19 addressPrefix, address operator) external view returns (uint256 operatorBitField);

    /// @notice Returns whether a given operator has been authorized for a given account.
    /// @param account The address of the account whose operator is being checked.
    /// @param operator The address of the operator that is being checked.
    /// @return authorized A boolean value that indicates whether the operator is authorized for the account.
    function isAccountOperatorAuthorized(address account, address operator) external view returns (bool authorized);

    /// @notice Enables or disables lockdown mode for a given address prefix.
    /// @dev This function can only be called by the owner of the address prefix. To disable this mode, the EVC
    /// must be called directly. It is not possible to disable this mode by using checks-deferrable call or
    /// permit message.
    /// @param addressPrefix The address prefix for which the lockdown mode is being set.
    /// @param enabled A boolean indicating whether to enable or disable lockdown mode.
    function setLockdownMode(bytes19 addressPrefix, bool enabled) external payable;

    /// @notice Enables or disables permit functionality for a given address prefix.
    /// @dev This function can only be called by the owner of the address prefix. To disable this mode, the EVC
    /// must be called directly. It is not possible to disable this mode by using checks-deferrable call or (by
    /// definition) permit message. To support permit functionality by default, note that the logic was inverted here. To
    /// disable  the permit functionality, one must pass true as the second argument. To enable the permit
    /// functionality, one must pass false as the second argument.
    /// @param addressPrefix The address prefix for which the permit functionality is being set.
    /// @param enabled A boolean indicating whether to enable or disable the disable-permit mode.
    function setPermitDisabledMode(bytes19 addressPrefix, bool enabled) external payable;

    /// @notice Sets the nonce for a given address prefix and nonce namespace.
    /// @dev This function can only be called by the owner of the address prefix. Each nonce namespace provides a 256
    /// bit nonce that has to be used sequentially. There's no requirement to use all the nonces for a given nonce
    /// namespace before moving to the next one which allows the use of permit messages in a non-sequential manner. To
    /// invalidate signed permit messages, set the nonce for a given nonce namespace accordingly. To invalidate all the
    /// permit messages for a given nonce namespace, set the nonce to type(uint).max.
    /// @param addressPrefix The address prefix for which the nonce is being set.
    /// @param nonceNamespace The nonce namespace for which the nonce is being set.
    /// @param nonce The new nonce for the given address prefix and nonce namespace.
    function setNonce(bytes19 addressPrefix, uint256 nonceNamespace, uint256 nonce) external payable;

    /// @notice Sets the bit field for a given address prefix and operator.
    /// @dev This function can only be called by the owner of the address prefix. Each bit in the bit field corresponds
    /// to one account belonging to the same owner. If the bit is set, the operator is authorized for the account.
    /// @param addressPrefix The address prefix for which the bit field is being set.
    /// @param operator The address of the operator for which the bit field is being set. Can neither be the EVC address
    /// nor an address belonging to the same address prefix.
    /// @param operatorBitField The new bit field for the given address prefix and operator. Reverts if the provided
    /// value is equal to the currently stored value.
    function setOperator(bytes19 addressPrefix, address operator, uint256 operatorBitField) external payable;

    /// @notice Authorizes or deauthorizes an operator for the account.
    /// @dev Only the owner or authorized operator of the account can call this function. An operator is an address that
    /// can perform actions for an account on behalf of the owner. If it's an operator calling this function, it can
    /// only deauthorize itself.
    /// @param account The address of the account whose operator is being set or unset.
    /// @param operator The address of the operator that is being installed or uninstalled. Can neither be the EVC
    /// address nor an address belonging to the same owner as the account.
    /// @param authorized A boolean value that indicates whether the operator is being authorized or deauthorized.
    /// Reverts if the provided value is equal to the currently stored value.
    function setAccountOperator(address account, address operator, bool authorized) external payable;

    /// @notice Returns an array of collaterals enabled for an account.
    /// @dev A collateral is a vault for which an account's balances are under the control of the currently enabled
    /// controller vault.
    /// @param account The address of the account whose collaterals are being queried.
    /// @return An array of addresses that are enabled collaterals for the account.
    function getCollaterals(address account) external view returns (address[] memory);

    /// @notice Returns whether a collateral is enabled for an account.
    /// @dev A collateral is a vault for which account's balances are under the control of the currently enabled
    /// controller vault.
    /// @param account The address of the account that is being checked.
    /// @param vault The address of the collateral that is being checked.
    /// @return A boolean value that indicates whether the vault is an enabled collateral for the account or not.
    function isCollateralEnabled(address account, address vault) external view returns (bool);

    /// @notice Enables a collateral for an account.
    /// @dev A collaterals is a vault for which account's balances are under the control of the currently enabled
    /// controller vault. Only the owner or an operator of the account can call this function. Unless it's a duplicate,
    /// the collateral is added to the end of the array. There can be at most 10 unique collaterals enabled at a time.
    /// Account status checks are performed.
    /// @param account The account address for which the collateral is being enabled.
    /// @param vault The address being enabled as a collateral.
    function enableCollateral(address account, address vault) external payable;

    /// @notice Disables a collateral for an account.
    /// @dev This function does not preserve the order of collaterals in the array obtained using the getCollaterals
    /// function; the order may change. A collateral is a vault for which account’s balances are under the control of
    /// the currently enabled controller vault. Only the owner or an operator of the account can call this function.
    /// Disabling a collateral might change the order of collaterals in the array obtained using getCollaterals
    /// function. Account status checks are performed.
    /// @param account The account address for which the collateral is being disabled.
    /// @param vault The address of a collateral being disabled.
    function disableCollateral(address account, address vault) external payable;

    /// @notice Swaps the position of two collaterals so that they appear switched in the array of collaterals for a
    /// given account obtained by calling getCollaterals function.
    /// @dev A collateral is a vault for which account’s balances are under the control of the currently enabled
    /// controller vault. Only the owner or an operator of the account can call this function. The order of collaterals
    /// can be changed by specifying the indices of the two collaterals to be swapped. Indices are zero-based and must
    /// be in the range of 0 to the number of collaterals minus 1. index1 must be lower than index2. Account status
    /// checks are performed.
    /// @param account The address of the account for which the collaterals are being reordered.
    /// @param index1 The index of the first collateral to be swapped.
    /// @param index2 The index of the second collateral to be swapped.
    function reorderCollaterals(address account, uint8 index1, uint8 index2) external payable;

    /// @notice Returns an array of enabled controllers for an account.
    /// @dev A controller is a vault that has been chosen for an account to have special control over the account's
    /// balances in enabled collaterals vaults. A user can have multiple controllers during a call execution, but at
    /// most one can be selected when the account status check is performed.
    /// @param account The address of the account whose controllers are being queried.
    /// @return An array of addresses that are the enabled controllers for the account.
    function getControllers(address account) external view returns (address[] memory);

    /// @notice Returns whether a controller is enabled for an account.
    /// @dev A controller is a vault that has been chosen for an account to have special control over account’s
    /// balances in the enabled collaterals vaults.
    /// @param account The address of the account that is being checked.
    /// @param vault The address of the controller that is being checked.
    /// @return A boolean value that indicates whether the vault is enabled controller for the account or not.
    function isControllerEnabled(address account, address vault) external view returns (bool);

    /// @notice Enables a controller for an account.
    /// @dev A controller is a vault that has been chosen for an account to have special control over account’s
    /// balances in the enabled collaterals vaults. Only the owner or an operator of the account can call this function.
    /// Unless it's a duplicate, the controller is added to the end of the array. Transiently, there can be at most 10
    /// unique controllers enabled at a time, but at most one can be enabled after the outermost checks-deferrable
    /// call concludes. Account status checks are performed.
    /// @param account The address for which the controller is being enabled.
    /// @param vault The address of the controller being enabled.
    function enableController(address account, address vault) external payable;

    /// @notice Disables a controller for an account.
    /// @dev A controller is a vault that has been chosen for an account to have special control over account’s
    /// balances in the enabled collaterals vaults. Only the vault itself can call this function. Disabling a controller
    /// might change the order of controllers in the array obtained using getControllers function. Account status checks
    /// are performed.
    /// @param account The address for which the calling controller is being disabled.
    function disableController(address account) external payable;

    /// @notice Executes signed arbitrary data by self-calling into the EVC.
    /// @dev Low-level call function is used to execute the arbitrary data signed by the owner or the operator on the
    /// EVC contract. During that call, EVC becomes msg.sender.
    /// @param signer The address signing the permit message (ECDSA) or verifying the permit message signature
    /// (ERC-1271). It's also the owner or the operator of all the accounts for which authentication will be needed
    /// during the execution of the arbitrary data call.
    /// @param sender The address of the msg.sender which is expected to execute the data signed by the signer. If
    /// address(0) is passed, the msg.sender is ignored.
    /// @param nonceNamespace The nonce namespace for which the nonce is being used.
    /// @param nonce The nonce for the given account and nonce namespace. A valid nonce value is considered to be the
    /// value currently stored and can take any value between 0 and type(uint256).max - 1.
    /// @param deadline The timestamp after which the permit is considered expired.
    /// @param value The amount of value to be forwarded with the call. If the value is type(uint256).max, the whole
    /// balance of the EVC contract will be forwarded.
    /// @param data The encoded data which is self-called on the EVC contract.
    /// @param signature The signature of the data signed by the signer.
    function permit(
        address signer,
        address sender,
        uint256 nonceNamespace,
        uint256 nonce,
        uint256 deadline,
        uint256 value,
        bytes calldata data,
        bytes calldata signature
    ) external payable;

    /// @notice Calls into a target contract as per data encoded.
    /// @dev This function defers the account and vault status checks (it's a checks-deferrable call). If the outermost
    /// call ends, the account and vault status checks are performed.
    /// @dev This function can be used to interact with any contract while checks are deferred. If the target contract
    /// is msg.sender, msg.sender is called back with the calldata provided and the context set up according to the
    /// account provided. If the target contract is not msg.sender, only the owner or the operator of the account
    /// provided can call this function.
    /// @dev This function can be used to recover the remaining value from the EVC contract.
    /// @param targetContract The address of the contract to be called.
    /// @param onBehalfOfAccount  If the target contract is msg.sender, the address of the account which will be set
    /// in the context. It assumes msg.sender has authenticated the account themselves. If the target contract is
    /// not msg.sender, the address of the account for which it is checked whether msg.sender is authorized to act
    /// on behalf of.
    /// @param value The amount of value to be forwarded with the call. If the value is type(uint256).max, the whole
    /// balance of the EVC contract will be forwarded.
    /// @param data The encoded data which is called on the target contract.
    /// @return result The result of the call.
    function call(
        address targetContract,
        address onBehalfOfAccount,
        uint256 value,
        bytes calldata data
    ) external payable returns (bytes memory result);

    /// @notice For a given account, calls into one of the enabled collateral vaults from the currently enabled
    /// controller vault as per data encoded.
    /// @dev This function defers the account and vault status checks (it's a checks-deferrable call). If the outermost
    /// call ends, the account and vault status checks are performed.
    /// @dev This function can be used to interact with any contract while checks are deferred as long as the contract
    /// is enabled as a collateral of the account and the msg.sender is the only enabled controller of the account.
    /// @param targetCollateral The collateral address to be called.
    /// @param onBehalfOfAccount The address of the account for which it is checked whether msg.sender is authorized to
    /// act on behalf.
    /// @param value The amount of value to be forwarded with the call. If the value is type(uint256).max, the whole
    /// balance of the EVC contract will be forwarded.
    /// @param data The encoded data which is called on the target collateral.
    /// @return result The result of the call.
    function controlCollateral(
        address targetCollateral,
        address onBehalfOfAccount,
        uint256 value,
        bytes calldata data
    ) external payable returns (bytes memory result);

    /// @notice Executes multiple calls into the target contracts while checks deferred as per batch items provided.
    /// @dev This function defers the account and vault status checks (it's a checks-deferrable call). If the outermost
    /// call ends, the account and vault status checks are performed.
    /// @dev The authentication rules for each batch item are the same as for the call function.
    /// @param items An array of batch items to be executed.
    function batch(BatchItem[] calldata items) external payable;

    /// @notice Executes multiple calls into the target contracts while checks deferred as per batch items provided.
    /// @dev This function always reverts as it's only used for simulation purposes. This function cannot be called
    /// within a checks-deferrable call.
    /// @param items An array of batch items to be executed.
    function batchRevert(BatchItem[] calldata items) external payable;

    /// @notice Executes multiple calls into the target contracts while checks deferred as per batch items provided.
    /// @dev This function does not modify state and should only be used for simulation purposes. This function cannot
    /// be called within a checks-deferrable call.
    /// @param items An array of batch items to be executed.
    /// @return batchItemsResult An array of batch item results for each item.
    /// @return accountsStatusCheckResult An array of account status check results for each account.
    /// @return vaultsStatusCheckResult An array of vault status check results for each vault.
    function batchSimulation(BatchItem[] calldata items)
        external
        payable
        returns (
            BatchItemResult[] memory batchItemsResult,
            StatusCheckResult[] memory accountsStatusCheckResult,
            StatusCheckResult[] memory vaultsStatusCheckResult
        );

    /// @notice Retrieves the timestamp of the last successful account status check performed for a specific account.
    /// @dev This function reverts if the checks are in progress.
    /// @dev The account status check is considered to be successful if it calls into the selected controller vault and
    /// obtains expected magic value. This timestamp does not change if the account status is considered valid when no
    /// controller enabled. When consuming, one might need to ensure that the account status check is not deferred at
    /// the moment.
    /// @param account The address of the account for which the last status check timestamp is being queried.
    /// @return The timestamp of the last status check as a uint256.
    function getLastAccountStatusCheckTimestamp(address account) external view returns (uint256);

    /// @notice Checks whether the status check is deferred for a given account.
    /// @dev This function reverts if the checks are in progress.
    /// @param account The address of the account for which it is checked whether the status check is deferred.
    /// @return A boolean flag that indicates whether the status check is deferred or not.
    function isAccountStatusCheckDeferred(address account) external view returns (bool);

    /// @notice Checks the status of an account and reverts if it is not valid.
    /// @dev If checks deferred, the account is added to the set of accounts to be checked at the end of the outermost
    /// checks-deferrable call. There can be at most 10 unique accounts added to the set at a time. Account status
    /// check is performed by calling into the selected controller vault and passing the array of currently enabled
    /// collaterals. If controller is not selected, the account is always considered valid.
    /// @param account The address of the account to be checked.
    function requireAccountStatusCheck(address account) external payable;

    /// @notice Forgives previously deferred account status check.
    /// @dev Account address is removed from the set of addresses for which status checks are deferred. This function
    /// can only be called by the currently enabled controller of a given account. Depending on the vault
    /// implementation, may be needed in the liquidation flow.
    /// @param account The address of the account for which the status check is forgiven.
    function forgiveAccountStatusCheck(address account) external payable;

    /// @notice Checks whether the status check is deferred for a given vault.
    /// @dev This function reverts if the checks are in progress.
    /// @param vault The address of the vault for which it is checked whether the status check is deferred.
    /// @return A boolean flag that indicates whether the status check is deferred or not.
    function isVaultStatusCheckDeferred(address vault) external view returns (bool);

    /// @notice Checks the status of a vault and reverts if it is not valid.
    /// @dev If checks deferred, the vault is added to the set of vaults to be checked at the end of the outermost
    /// checks-deferrable call. There can be at most 10 unique vaults added to the set at a time. This function can
    /// only be called by the vault itself.
    function requireVaultStatusCheck() external payable;

    /// @notice Forgives previously deferred vault status check.
    /// @dev Vault address is removed from the set of addresses for which status checks are deferred. This function can
    /// only be called by the vault itself.
    function forgiveVaultStatusCheck() external payable;

    /// @notice Checks the status of an account and a vault and reverts if it is not valid.
    /// @dev If checks deferred, the account and the vault are added to the respective sets of accounts and vaults to be
    /// checked at the end of the outermost checks-deferrable call. Account status check is performed by calling into
    /// selected controller vault and passing the array of currently enabled collaterals. If controller is not selected,
    /// the account is always considered valid. This function can only be called by the vault itself.
    /// @param account The address of the account to be checked.
    function requireAccountAndVaultStatusCheck(address account) external payable;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {IEVC} from "../interfaces/IEthereumVaultConnector.sol";
import {ExecutionContext, EC} from "../ExecutionContext.sol";

/// @title EVCUtil
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice This contract is an abstract base contract for interacting with the Ethereum Vault Connector (EVC).
/// It provides utility functions for authenticating the callers in the context of the EVC, a pattern for enforcing the
/// contracts to be called through the EVC.
abstract contract EVCUtil {
    using ExecutionContext for EC;

    uint160 internal constant ACCOUNT_ID_OFFSET = 8;
    IEVC internal immutable evc;

    error EVC_InvalidAddress();
    error NotAuthorized();
    error ControllerDisabled();

    constructor(address _evc) {
        if (_evc == address(0)) revert EVC_InvalidAddress();

        evc = IEVC(_evc);
    }

    /// @notice Returns the address of the Ethereum Vault Connector (EVC) used by this contract.
    /// @return The address of the EVC contract.
    function EVC() external view returns (address) {
        return address(evc);
    }

    /// @notice Ensures that the msg.sender is the EVC by using the EVC callback functionality if necessary.
    /// @dev Optional to use for functions requiring account and vault status checks to enforce predictable behavior.
    /// @dev If this modifier used in conjuction with any other modifier, it must appear as the first (outermost)
    /// modifier of the function.
    modifier callThroughEVC() virtual {
        _callThroughEVC();
        _;
    }

    /// @notice Ensures that the caller is the EVC in the appropriate context.
    /// @dev Should be used for checkAccountStatus and checkVaultStatus functions.
    modifier onlyEVCWithChecksInProgress() virtual {
        _onlyEVCWithChecksInProgress();
        _;
    }

    /// @notice Ensures a standard authentication path on the EVC.
    /// @dev This modifier checks if the caller is the EVC and if so, verifies the execution context.
    /// It reverts if the operator is authenticated, control collateral is in progress, or checks are in progress.
    /// It reverts if the authenticated account owner is known and it is not the account owner.
    /// @dev It assumes that if the caller is not the EVC, the caller is the account owner.
    /// @dev This modifier must not be used on functions utilized by liquidation flows, i.e. transfer or withdraw.
    /// @dev This modifier must not be used on checkAccountStatus and checkVaultStatus functions.
    /// @dev This modifier can be used on access controlled functions to prevent non-standard authentication paths on
    /// the EVC.
    modifier onlyEVCAccountOwner() virtual {
        _onlyEVCAccountOwner();
        _;
    }

    /// @notice Checks whether the specified account and the other account have the same owner.
    /// @dev The function is used to check whether one account is authorized to perform operations on behalf of the
    /// other. Accounts are considered to have a common owner if they share the first 19 bytes of their address.
    /// @param account The address of the account that is being checked.
    /// @param otherAccount The address of the other account that is being checked.
    /// @return A boolean flag that indicates whether the accounts have the same owner.
    function _haveCommonOwner(address account, address otherAccount) internal pure returns (bool) {
        bool result;
        assembly {
            result := lt(xor(account, otherAccount), 0x100)
        }
        return result;
    }

    /// @notice Returns the address prefix of the specified account.
    /// @dev The address prefix is the first 19 bytes of the account address.
    /// @param account The address of the account whose address prefix is being retrieved.
    /// @return A bytes19 value that represents the address prefix of the account.
    function _getAddressPrefix(address account) internal pure returns (bytes19) {
        return bytes19(uint152(uint160(account) >> ACCOUNT_ID_OFFSET));
    }

    /// @notice Retrieves the message sender in the context of the EVC.
    /// @dev This function returns the account on behalf of which the current operation is being performed, which is
    /// either msg.sender or the account authenticated by the EVC.
    /// @return The address of the message sender.
    function _msgSender() internal view virtual returns (address) {
        address sender = msg.sender;

        if (sender == address(evc)) {
            (sender,) = evc.getCurrentOnBehalfOfAccount(address(0));
        }

        return sender;
    }

    /// @notice Retrieves the message sender in the context of the EVC for a borrow operation.
    /// @dev This function returns the account on behalf of which the current operation is being performed, which is
    /// either msg.sender or the account authenticated by the EVC. This function reverts if this contract is not enabled
    /// as a controller for the account on behalf of which the operation is being executed.
    /// @return The address of the message sender.
    function _msgSenderForBorrow() internal view virtual returns (address) {
        address sender = msg.sender;
        bool controllerEnabled;

        if (sender == address(evc)) {
            (sender, controllerEnabled) = evc.getCurrentOnBehalfOfAccount(address(this));
        } else {
            controllerEnabled = evc.isControllerEnabled(sender, address(this));
        }

        if (!controllerEnabled) {
            revert ControllerDisabled();
        }

        return sender;
    }

    /// @notice Calls the current external function through the EVC.
    /// @dev This function is used to route the current call through the EVC if it's not already coming from the EVC. It
    /// makes the EVC set the execution context and call back this contract with unchanged calldata. msg.sender is used
    /// as the onBehalfOfAccount.
    /// @dev This function shall only be used by the callThroughEVC modifier.
    function _callThroughEVC() internal {
        address _evc = address(evc);
        if (msg.sender == _evc) return;

        assembly {
            mstore(0, 0x1f8b521500000000000000000000000000000000000000000000000000000000) // EVC.call selector
            mstore(4, address()) // EVC.call 1st argument - address(this)
            mstore(36, caller()) // EVC.call 2nd argument - msg.sender
            mstore(68, callvalue()) // EVC.call 3rd argument - msg.value
            mstore(100, 128) // EVC.call 4th argument - msg.data, offset to the start of encoding - 128 bytes
            mstore(132, calldatasize()) // msg.data length
            calldatacopy(164, 0, calldatasize()) // original calldata

            // abi encoded bytes array should be zero padded so its length is a multiple of 32
            // store zero word after msg.data bytes and round up calldatasize to nearest multiple of 32
            mstore(add(164, calldatasize()), 0)
            let result := call(gas(), _evc, callvalue(), 0, add(164, and(add(calldatasize(), 31), not(31))), 0, 0)

            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(64, sub(returndatasize(), 64)) } // strip bytes encoding from call return
        }
    }

    /// @notice Ensures that the function is called only by the EVC during the checks phase
    /// @dev Reverts if the caller is not the EVC or if checks are not in progress.
    function _onlyEVCWithChecksInProgress() internal view {
        if (msg.sender != address(evc) || !evc.areChecksInProgress()) {
            revert NotAuthorized();
        }
    }

    /// @notice Ensures that the function is called only by the EVC account owner
    /// @dev This function checks if the caller is the EVC and if so, verifies that the execution context is not in a
    /// special state (operator authenticated, collateral control in progress, or checks in progress). If the owner was
    /// already registered on the EVC, it verifies that the onBehalfOfAccount is the owner.
    /// @dev Reverts if the caller is not the EVC or if the execution context is in a special state.
    function _onlyEVCAccountOwner() internal view {
        if (msg.sender == address(evc)) {
            EC ec = EC.wrap(evc.getRawExecutionContext());

            if (ec.isOperatorAuthenticated() || ec.isControlCollateralInProgress() || ec.areChecksInProgress()) {
                revert NotAuthorized();
            }

            address onBehalfOfAccount = ec.getOnBehalfOfAccount();
            address owner = evc.getAccountOwner(onBehalfOfAccount);

            if (owner != address(0) && owner != onBehalfOfAccount) {
                revert NotAuthorized();
            }
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Arithmetic library with operations for fixed-point numbers.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/FixedPointMathLib.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/FixedPointMathLib.sol)
library FixedPointMathLib {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       CUSTOM ERRORS                        */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The operation failed, as the output exceeds the maximum value of uint256.
    error ExpOverflow();

    /// @dev The operation failed, as the output exceeds the maximum value of uint256.
    error FactorialOverflow();

    /// @dev The operation failed, due to an overflow.
    error RPowOverflow();

    /// @dev The mantissa is too big to fit.
    error MantissaOverflow();

    /// @dev The operation failed, due to an multiplication overflow.
    error MulWadFailed();

    /// @dev The operation failed, due to an multiplication overflow.
    error SMulWadFailed();

    /// @dev The operation failed, either due to a multiplication overflow, or a division by a zero.
    error DivWadFailed();

    /// @dev The operation failed, either due to a multiplication overflow, or a division by a zero.
    error SDivWadFailed();

    /// @dev The operation failed, either due to a multiplication overflow, or a division by a zero.
    error MulDivFailed();

    /// @dev The division failed, as the denominator is zero.
    error DivFailed();

    /// @dev The full precision multiply-divide operation failed, either due
    /// to the result being larger than 256 bits, or a division by a zero.
    error FullMulDivFailed();

    /// @dev The output is undefined, as the input is less-than-or-equal to zero.
    error LnWadUndefined();

    /// @dev The input outside the acceptable domain.
    error OutOfDomain();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         CONSTANTS                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The scalar of ETH and most ERC20s.
    uint256 internal constant WAD = 1e18;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*              SIMPLIFIED FIXED POINT OPERATIONS             */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Equivalent to `(x * y) / WAD` rounded down.
    function mulWad(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Equivalent to `require(y == 0 || x <= type(uint256).max / y)`.
            if mul(y, gt(x, div(not(0), y))) {
                mstore(0x00, 0xbac65e5b) // `MulWadFailed()`.
                revert(0x1c, 0x04)
            }
            z := div(mul(x, y), WAD)
        }
    }

    /// @dev Equivalent to `(x * y) / WAD` rounded down.
    function sMulWad(int256 x, int256 y) internal pure returns (int256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := mul(x, y)
            // Equivalent to `require((x == 0 || z / x == y) && !(x == -1 && y == type(int256).min))`.
            if iszero(gt(or(iszero(x), eq(sdiv(z, x), y)), lt(not(x), eq(y, shl(255, 1))))) {
                mstore(0x00, 0xedcd4dd4) // `SMulWadFailed()`.
                revert(0x1c, 0x04)
            }
            z := sdiv(z, WAD)
        }
    }

    /// @dev Equivalent to `(x * y) / WAD` rounded down, but without overflow checks.
    function rawMulWad(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := div(mul(x, y), WAD)
        }
    }

    /// @dev Equivalent to `(x * y) / WAD` rounded down, but without overflow checks.
    function rawSMulWad(int256 x, int256 y) internal pure returns (int256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := sdiv(mul(x, y), WAD)
        }
    }

    /// @dev Equivalent to `(x * y) / WAD` rounded up.
    function mulWadUp(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Equivalent to `require(y == 0 || x <= type(uint256).max / y)`.
            if mul(y, gt(x, div(not(0), y))) {
                mstore(0x00, 0xbac65e5b) // `MulWadFailed()`.
                revert(0x1c, 0x04)
            }
            z := add(iszero(iszero(mod(mul(x, y), WAD))), div(mul(x, y), WAD))
        }
    }

    /// @dev Equivalent to `(x * y) / WAD` rounded up, but without overflow checks.
    function rawMulWadUp(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := add(iszero(iszero(mod(mul(x, y), WAD))), div(mul(x, y), WAD))
        }
    }

    /// @dev Equivalent to `(x * WAD) / y` rounded down.
    function divWad(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Equivalent to `require(y != 0 && (WAD == 0 || x <= type(uint256).max / WAD))`.
            if iszero(mul(y, iszero(mul(WAD, gt(x, div(not(0), WAD)))))) {
                mstore(0x00, 0x7c5f487d) // `DivWadFailed()`.
                revert(0x1c, 0x04)
            }
            z := div(mul(x, WAD), y)
        }
    }

    /// @dev Equivalent to `(x * WAD) / y` rounded down.
    function sDivWad(int256 x, int256 y) internal pure returns (int256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := mul(x, WAD)
            // Equivalent to `require(y != 0 && ((x * WAD) / WAD == x))`.
            if iszero(and(iszero(iszero(y)), eq(sdiv(z, WAD), x))) {
                mstore(0x00, 0x5c43740d) // `SDivWadFailed()`.
                revert(0x1c, 0x04)
            }
            z := sdiv(mul(x, WAD), y)
        }
    }

    /// @dev Equivalent to `(x * WAD) / y` rounded down, but without overflow and divide by zero checks.
    function rawDivWad(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := div(mul(x, WAD), y)
        }
    }

    /// @dev Equivalent to `(x * WAD) / y` rounded down, but without overflow and divide by zero checks.
    function rawSDivWad(int256 x, int256 y) internal pure returns (int256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := sdiv(mul(x, WAD), y)
        }
    }

    /// @dev Equivalent to `(x * WAD) / y` rounded up.
    function divWadUp(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Equivalent to `require(y != 0 && (WAD == 0 || x <= type(uint256).max / WAD))`.
            if iszero(mul(y, iszero(mul(WAD, gt(x, div(not(0), WAD)))))) {
                mstore(0x00, 0x7c5f487d) // `DivWadFailed()`.
                revert(0x1c, 0x04)
            }
            z := add(iszero(iszero(mod(mul(x, WAD), y))), div(mul(x, WAD), y))
        }
    }

    /// @dev Equivalent to `(x * WAD) / y` rounded up, but without overflow and divide by zero checks.
    function rawDivWadUp(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := add(iszero(iszero(mod(mul(x, WAD), y))), div(mul(x, WAD), y))
        }
    }

    /// @dev Equivalent to `x` to the power of `y`.
    /// because `x ** y = (e ** ln(x)) ** y = e ** (ln(x) * y)`.
    function powWad(int256 x, int256 y) internal pure returns (int256) {
        // Using `ln(x)` means `x` must be greater than 0.
        return expWad((lnWad(x) * y) / int256(WAD));
    }

    /// @dev Returns `exp(x)`, denominated in `WAD`.
    /// Credit to Remco Bloemen under MIT license: https://2π.com/22/exp-ln
    function expWad(int256 x) internal pure returns (int256 r) {
        unchecked {
            // When the result is less than 0.5 we return zero.
            // This happens when `x <= (log(1e-18) * 1e18) ~ -4.15e19`.
            if (x <= -41446531673892822313) return r;

            /// @solidity memory-safe-assembly
            assembly {
                // When the result is greater than `(2**255 - 1) / 1e18` we can not represent it as
                // an int. This happens when `x >= floor(log((2**255 - 1) / 1e18) * 1e18) ≈ 135`.
                if iszero(slt(x, 135305999368893231589)) {
                    mstore(0x00, 0xa37bfec9) // `ExpOverflow()`.
                    revert(0x1c, 0x04)
                }
            }

            // `x` is now in the range `(-42, 136) * 1e18`. Convert to `(-42, 136) * 2**96`
            // for more intermediate precision and a binary basis. This base conversion
            // is a multiplication by 1e18 / 2**96 = 5**18 / 2**78.
            x = (x << 78) / 5 ** 18;

            // Reduce range of x to (-½ ln 2, ½ ln 2) * 2**96 by factoring out powers
            // of two such that exp(x) = exp(x') * 2**k, where k is an integer.
            // Solving this gives k = round(x / log(2)) and x' = x - k * log(2).
            int256 k = ((x << 96) / 54916777467707473351141471128 + 2 ** 95) >> 96;
            x = x - k * 54916777467707473351141471128;

            // `k` is in the range `[-61, 195]`.

            // Evaluate using a (6, 7)-term rational approximation.
            // `p` is made monic, we'll multiply by a scale factor later.
            int256 y = x + 1346386616545796478920950773328;
            y = ((y * x) >> 96) + 57155421227552351082224309758442;
            int256 p = y + x - 94201549194550492254356042504812;
            p = ((p * y) >> 96) + 28719021644029726153956944680412240;
            p = p * x + (4385272521454847904659076985693276 << 96);

            // We leave `p` in `2**192` basis so we don't need to scale it back up for the division.
            int256 q = x - 2855989394907223263936484059900;
            q = ((q * x) >> 96) + 50020603652535783019961831881945;
            q = ((q * x) >> 96) - 533845033583426703283633433725380;
            q = ((q * x) >> 96) + 3604857256930695427073651918091429;
            q = ((q * x) >> 96) - 14423608567350463180887372962807573;
            q = ((q * x) >> 96) + 26449188498355588339934803723976023;

            /// @solidity memory-safe-assembly
            assembly {
                // Div in assembly because solidity adds a zero check despite the unchecked.
                // The q polynomial won't have zeros in the domain as all its roots are complex.
                // No scaling is necessary because p is already `2**96` too large.
                r := sdiv(p, q)
            }

            // r should be in the range `(0.09, 0.25) * 2**96`.

            // We now need to multiply r by:
            // - The scale factor `s ≈ 6.031367120`.
            // - The `2**k` factor from the range reduction.
            // - The `1e18 / 2**96` factor for base conversion.
            // We do this all at once, with an intermediate result in `2**213`
            // basis, so the final right shift is always by a positive amount.
            r = int256(
                (uint256(r) * 3822833074963236453042738258902158003155416615667) >> uint256(195 - k)
            );
        }
    }

    /// @dev Returns `ln(x)`, denominated in `WAD`.
    /// Credit to Remco Bloemen under MIT license: https://2π.com/22/exp-ln
    function lnWad(int256 x) internal pure returns (int256 r) {
        /// @solidity memory-safe-assembly
        assembly {
            // We want to convert `x` from `10**18` fixed point to `2**96` fixed point.
            // We do this by multiplying by `2**96 / 10**18`. But since
            // `ln(x * C) = ln(x) + ln(C)`, we can simply do nothing here
            // and add `ln(2**96 / 10**18)` at the end.

            // Compute `k = log2(x) - 96`, `r = 159 - k = 255 - log2(x) = 255 ^ log2(x)`.
            r := shl(7, lt(0xffffffffffffffffffffffffffffffff, x))
            r := or(r, shl(6, lt(0xffffffffffffffff, shr(r, x))))
            r := or(r, shl(5, lt(0xffffffff, shr(r, x))))
            r := or(r, shl(4, lt(0xffff, shr(r, x))))
            r := or(r, shl(3, lt(0xff, shr(r, x))))
            // We place the check here for more optimal stack operations.
            if iszero(sgt(x, 0)) {
                mstore(0x00, 0x1615e638) // `LnWadUndefined()`.
                revert(0x1c, 0x04)
            }
            // forgefmt: disable-next-item
            r := xor(r, byte(and(0x1f, shr(shr(r, x), 0x8421084210842108cc6318c6db6d54be)),
                0xf8f9f9faf9fdfafbf9fdfcfdfafbfcfef9fafdfafcfcfbfefafafcfbffffffff))

            // Reduce range of x to (1, 2) * 2**96
            // ln(2^k * x) = k * ln(2) + ln(x)
            x := shr(159, shl(r, x))

            // Evaluate using a (8, 8)-term rational approximation.
            // `p` is made monic, we will multiply by a scale factor later.
            // forgefmt: disable-next-item
            let p := sub( // This heavily nested expression is to avoid stack-too-deep for via-ir.
                sar(96, mul(add(43456485725739037958740375743393,
                sar(96, mul(add(24828157081833163892658089445524,
                sar(96, mul(add(3273285459638523848632254066296,
                    x), x))), x))), x)), 11111509109440967052023855526967)
            p := sub(sar(96, mul(p, x)), 45023709667254063763336534515857)
            p := sub(sar(96, mul(p, x)), 14706773417378608786704636184526)
            p := sub(mul(p, x), shl(96, 795164235651350426258249787498))
            // We leave `p` in `2**192` basis so we don't need to scale it back up for the division.

            // `q` is monic by convention.
            let q := add(5573035233440673466300451813936, x)
            q := add(71694874799317883764090561454958, sar(96, mul(x, q)))
            q := add(283447036172924575727196451306956, sar(96, mul(x, q)))
            q := add(401686690394027663651624208769553, sar(96, mul(x, q)))
            q := add(204048457590392012362485061816622, sar(96, mul(x, q)))
            q := add(31853899698501571402653359427138, sar(96, mul(x, q)))
            q := add(909429971244387300277376558375, sar(96, mul(x, q)))

            // `p / q` is in the range `(0, 0.125) * 2**96`.

            // Finalization, we need to:
            // - Multiply by the scale factor `s = 5.549…`.
            // - Add `ln(2**96 / 10**18)`.
            // - Add `k * ln(2)`.
            // - Multiply by `10**18 / 2**96 = 5**18 >> 78`.

            // The q polynomial is known not to have zeros in the domain.
            // No scaling required because p is already `2**96` too large.
            p := sdiv(p, q)
            // Multiply by the scaling factor: `s * 5**18 * 2**96`, base is now `5**18 * 2**192`.
            p := mul(1677202110996718588342820967067443963516166, p)
            // Add `ln(2) * k * 5**18 * 2**192`.
            // forgefmt: disable-next-item
            p := add(mul(16597577552685614221487285958193947469193820559219878177908093499208371, sub(159, r)), p)
            // Add `ln(2**96 / 10**18) * 5**18 * 2**192`.
            p := add(600920179829731861736702779321621459595472258049074101567377883020018308, p)
            // Base conversion: mul `2**18 / 2**192`.
            r := sar(174, p)
        }
    }

    /// @dev Returns `W_0(x)`, denominated in `WAD`.
    /// See: https://en.wikipedia.org/wiki/Lambert_W_function
    /// a.k.a. Product log function. This is an approximation of the principal branch.
    function lambertW0Wad(int256 x) internal pure returns (int256 w) {
        // forgefmt: disable-next-item
        unchecked {
            if ((w = x) <= -367879441171442322) revert OutOfDomain(); // `x` less than `-1/e`.
            int256 wad = int256(WAD);
            int256 p = x;
            uint256 c; // Whether we need to avoid catastrophic cancellation.
            uint256 i = 4; // Number of iterations.
            if (w <= 0x1ffffffffffff) {
                if (-0x4000000000000 <= w) {
                    i = 1; // Inputs near zero only take one step to converge.
                } else if (w <= -0x3ffffffffffffff) {
                    i = 32; // Inputs near `-1/e` take very long to converge.
                }
            } else if (w >> 63 == 0) {
                /// @solidity memory-safe-assembly
                assembly {
                    // Inline log2 for more performance, since the range is small.
                    let v := shr(49, w)
                    let l := shl(3, lt(0xff, v))
                    l := add(or(l, byte(and(0x1f, shr(shr(l, v), 0x8421084210842108cc6318c6db6d54be)),
                        0x0706060506020504060203020504030106050205030304010505030400000000)), 49)
                    w := sdiv(shl(l, 7), byte(sub(l, 31), 0x0303030303030303040506080c13))
                    c := gt(l, 60)
                    i := add(2, add(gt(l, 53), c))
                }
            } else {
                int256 ll = lnWad(w = lnWad(w));
                /// @solidity memory-safe-assembly
                assembly {
                    // `w = ln(x) - ln(ln(x)) + b * ln(ln(x)) / ln(x)`.
                    w := add(sdiv(mul(ll, 1023715080943847266), w), sub(w, ll))
                    i := add(3, iszero(shr(68, x)))
                    c := iszero(shr(143, x))
                }
                if (c == 0) {
                    do { // If `x` is big, use Newton's so that intermediate values won't overflow.
                        int256 e = expWad(w);
                        /// @solidity memory-safe-assembly
                        assembly {
                            let t := mul(w, div(e, wad))
                            w := sub(w, sdiv(sub(t, x), div(add(e, t), wad)))
                        }
                        if (p <= w) break;
                        p = w;
                    } while (--i != 0);
                    /// @solidity memory-safe-assembly
                    assembly {
                        w := sub(w, sgt(w, 2))
                    }
                    return w;
                }
            }
            do { // Otherwise, use Halley's for faster convergence.
                int256 e = expWad(w);
                /// @solidity memory-safe-assembly
                assembly {
                    let t := add(w, wad)
                    let s := sub(mul(w, e), mul(x, wad))
                    w := sub(w, sdiv(mul(s, wad), sub(mul(e, t), sdiv(mul(add(t, wad), s), add(t, t)))))
                }
                if (p <= w) break;
                p = w;
            } while (--i != c);
            /// @solidity memory-safe-assembly
            assembly {
                w := sub(w, sgt(w, 2))
            }
            // For certain ranges of `x`, we'll use the quadratic-rate recursive formula of
            // R. Iacono and J.P. Boyd for the last iteration, to avoid catastrophic cancellation.
            if (c != 0) {
                int256 t = w | 1;
                /// @solidity memory-safe-assembly
                assembly {
                    x := sdiv(mul(x, wad), t)
                }
                x = (t * (wad + lnWad(x)));
                /// @solidity memory-safe-assembly
                assembly {
                    w := sdiv(x, add(wad, t))
                }
            }
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                  GENERAL NUMBER UTILITIES                  */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Calculates `floor(x * y / d)` with full precision.
    /// Throws if result overflows a uint256 or when `d` is zero.
    /// Credit to Remco Bloemen under MIT license: https://2π.com/21/muldiv
    function fullMulDiv(uint256 x, uint256 y, uint256 d) internal pure returns (uint256 result) {
        /// @solidity memory-safe-assembly
        assembly {
            for {} 1 {} {
                // 512-bit multiply `[p1 p0] = x * y`.
                // Compute the product mod `2**256` and mod `2**256 - 1`
                // then use the Chinese Remainder Theorem to reconstruct
                // the 512 bit result. The result is stored in two 256
                // variables such that `product = p1 * 2**256 + p0`.

                // Least significant 256 bits of the product.
                result := mul(x, y) // Temporarily use `result` as `p0` to save gas.
                let mm := mulmod(x, y, not(0))
                // Most significant 256 bits of the product.
                let p1 := sub(mm, add(result, lt(mm, result)))

                // Handle non-overflow cases, 256 by 256 division.
                if iszero(p1) {
                    if iszero(d) {
                        mstore(0x00, 0xae47f702) // `FullMulDivFailed()`.
                        revert(0x1c, 0x04)
                    }
                    result := div(result, d)
                    break
                }

                // Make sure the result is less than `2**256`. Also prevents `d == 0`.
                if iszero(gt(d, p1)) {
                    mstore(0x00, 0xae47f702) // `FullMulDivFailed()`.
                    revert(0x1c, 0x04)
                }

                /*------------------- 512 by 256 division --------------------*/

                // Make division exact by subtracting the remainder from `[p1 p0]`.
                // Compute remainder using mulmod.
                let r := mulmod(x, y, d)
                // `t` is the least significant bit of `d`.
                // Always greater or equal to 1.
                let t := and(d, sub(0, d))
                // Divide `d` by `t`, which is a power of two.
                d := div(d, t)
                // Invert `d mod 2**256`
                // Now that `d` is an odd number, it has an inverse
                // modulo `2**256` such that `d * inv = 1 mod 2**256`.
                // Compute the inverse by starting with a seed that is correct
                // correct for four bits. That is, `d * inv = 1 mod 2**4`.
                let inv := xor(2, mul(3, d))
                // Now use Newton-Raphson iteration to improve the precision.
                // Thanks to Hensel's lifting lemma, this also works in modular
                // arithmetic, doubling the correct bits in each step.
                inv := mul(inv, sub(2, mul(d, inv))) // inverse mod 2**8
                inv := mul(inv, sub(2, mul(d, inv))) // inverse mod 2**16
                inv := mul(inv, sub(2, mul(d, inv))) // inverse mod 2**32
                inv := mul(inv, sub(2, mul(d, inv))) // inverse mod 2**64
                inv := mul(inv, sub(2, mul(d, inv))) // inverse mod 2**128
                result :=
                    mul(
                        // Divide [p1 p0] by the factors of two.
                        // Shift in bits from `p1` into `p0`. For this we need
                        // to flip `t` such that it is `2**256 / t`.
                        or(
                            mul(sub(p1, gt(r, result)), add(div(sub(0, t), t), 1)),
                            div(sub(result, r), t)
                        ),
                        // inverse mod 2**256
                        mul(inv, sub(2, mul(d, inv)))
                    )
                break
            }
        }
    }

    /// @dev Calculates `floor(x * y / d)` with full precision, rounded up.
    /// Throws if result overflows a uint256 or when `d` is zero.
    /// Credit to Uniswap-v3-core under MIT license:
    /// https://github.com/Uniswap/v3-core/blob/main/contracts/libraries/FullMath.sol
    function fullMulDivUp(uint256 x, uint256 y, uint256 d) internal pure returns (uint256 result) {
        result = fullMulDiv(x, y, d);
        /// @solidity memory-safe-assembly
        assembly {
            if mulmod(x, y, d) {
                result := add(result, 1)
                if iszero(result) {
                    mstore(0x00, 0xae47f702) // `FullMulDivFailed()`.
                    revert(0x1c, 0x04)
                }
            }
        }
    }

    /// @dev Returns `floor(x * y / d)`.
    /// Reverts if `x * y` overflows, or `d` is zero.
    function mulDiv(uint256 x, uint256 y, uint256 d) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Equivalent to require(d != 0 && (y == 0 || x <= type(uint256).max / y))
            if iszero(mul(d, iszero(mul(y, gt(x, div(not(0), y)))))) {
                mstore(0x00, 0xad251c27) // `MulDivFailed()`.
                revert(0x1c, 0x04)
            }
            z := div(mul(x, y), d)
        }
    }

    /// @dev Returns `ceil(x * y / d)`.
    /// Reverts if `x * y` overflows, or `d` is zero.
    function mulDivUp(uint256 x, uint256 y, uint256 d) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Equivalent to require(d != 0 && (y == 0 || x <= type(uint256).max / y))
            if iszero(mul(d, iszero(mul(y, gt(x, div(not(0), y)))))) {
                mstore(0x00, 0xad251c27) // `MulDivFailed()`.
                revert(0x1c, 0x04)
            }
            z := add(iszero(iszero(mod(mul(x, y), d))), div(mul(x, y), d))
        }
    }

    /// @dev Returns `ceil(x / d)`.
    /// Reverts if `d` is zero.
    function divUp(uint256 x, uint256 d) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            if iszero(d) {
                mstore(0x00, 0x65244e4e) // `DivFailed()`.
                revert(0x1c, 0x04)
            }
            z := add(iszero(iszero(mod(x, d))), div(x, d))
        }
    }

    /// @dev Returns `max(0, x - y)`.
    function zeroFloorSub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := mul(gt(x, y), sub(x, y))
        }
    }

    /// @dev Exponentiate `x` to `y` by squaring, denominated in base `b`.
    /// Reverts if the computation overflows.
    function rpow(uint256 x, uint256 y, uint256 b) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := mul(b, iszero(y)) // `0 ** 0 = 1`. Otherwise, `0 ** n = 0`.
            if x {
                z := xor(b, mul(xor(b, x), and(y, 1))) // `z = isEven(y) ? scale : x`
                let half := shr(1, b) // Divide `b` by 2.
                // Divide `y` by 2 every iteration.
                for { y := shr(1, y) } y { y := shr(1, y) } {
                    let xx := mul(x, x) // Store x squared.
                    let xxRound := add(xx, half) // Round to the nearest number.
                    // Revert if `xx + half` overflowed, or if `x ** 2` overflows.
                    if or(lt(xxRound, xx), shr(128, x)) {
                        mstore(0x00, 0x49f7642b) // `RPowOverflow()`.
                        revert(0x1c, 0x04)
                    }
                    x := div(xxRound, b) // Set `x` to scaled `xxRound`.
                    // If `y` is odd:
                    if and(y, 1) {
                        let zx := mul(z, x) // Compute `z * x`.
                        let zxRound := add(zx, half) // Round to the nearest number.
                        // If `z * x` overflowed or `zx + half` overflowed:
                        if or(xor(div(zx, x), z), lt(zxRound, zx)) {
                            // Revert if `x` is non-zero.
                            if iszero(iszero(x)) {
                                mstore(0x00, 0x49f7642b) // `RPowOverflow()`.
                                revert(0x1c, 0x04)
                            }
                        }
                        z := div(zxRound, b) // Return properly scaled `zxRound`.
                    }
                }
            }
        }
    }

    /// @dev Returns the square root of `x`.
    function sqrt(uint256 x) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // `floor(sqrt(2**15)) = 181`. `sqrt(2**15) - 181 = 2.84`.
            z := 181 // The "correct" value is 1, but this saves a multiplication later.

            // This segment is to get a reasonable initial estimate for the Babylonian method. With a bad
            // start, the correct # of bits increases ~linearly each iteration instead of ~quadratically.

            // Let `y = x / 2**r`. We check `y >= 2**(k + 8)`
            // but shift right by `k` bits to ensure that if `x >= 256`, then `y >= 256`.
            let r := shl(7, lt(0xffffffffffffffffffffffffffffffffff, x))
            r := or(r, shl(6, lt(0xffffffffffffffffff, shr(r, x))))
            r := or(r, shl(5, lt(0xffffffffff, shr(r, x))))
            r := or(r, shl(4, lt(0xffffff, shr(r, x))))
            z := shl(shr(1, r), z)

            // Goal was to get `z*z*y` within a small factor of `x`. More iterations could
            // get y in a tighter range. Currently, we will have y in `[256, 256*(2**16))`.
            // We ensured `y >= 256` so that the relative difference between `y` and `y+1` is small.
            // That's not possible if `x < 256` but we can just verify those cases exhaustively.

            // Now, `z*z*y <= x < z*z*(y+1)`, and `y <= 2**(16+8)`, and either `y >= 256`, or `x < 256`.
            // Correctness can be checked exhaustively for `x < 256`, so we assume `y >= 256`.
            // Then `z*sqrt(y)` is within `sqrt(257)/sqrt(256)` of `sqrt(x)`, or about 20bps.

            // For `s` in the range `[1/256, 256]`, the estimate `f(s) = (181/1024) * (s+1)`
            // is in the range `(1/2.84 * sqrt(s), 2.84 * sqrt(s))`,
            // with largest error when `s = 1` and when `s = 256` or `1/256`.

            // Since `y` is in `[256, 256*(2**16))`, let `a = y/65536`, so that `a` is in `[1/256, 256)`.
            // Then we can estimate `sqrt(y)` using
            // `sqrt(65536) * 181/1024 * (a + 1) = 181/4 * (y + 65536)/65536 = 181 * (y + 65536)/2**18`.

            // There is no overflow risk here since `y < 2**136` after the first branch above.
            z := shr(18, mul(z, add(shr(r, x), 65536))) // A `mul()` is saved from starting `z` at 181.

            // Given the worst case multiplicative error of 2.84 above, 7 iterations should be enough.
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))

            // If `x+1` is a perfect square, the Babylonian method cycles between
            // `floor(sqrt(x))` and `ceil(sqrt(x))`. This statement ensures we return floor.
            // See: https://en.wikipedia.org/wiki/Integer_square_root#Using_only_integer_division
            z := sub(z, lt(div(x, z), z))
        }
    }

    /// @dev Returns the cube root of `x`.
    /// Credit to bout3fiddy and pcaversaccio under AGPLv3 license:
    /// https://github.com/pcaversaccio/snekmate/blob/main/src/utils/Math.vy
    function cbrt(uint256 x) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            let r := shl(7, lt(0xffffffffffffffffffffffffffffffff, x))
            r := or(r, shl(6, lt(0xffffffffffffffff, shr(r, x))))
            r := or(r, shl(5, lt(0xffffffff, shr(r, x))))
            r := or(r, shl(4, lt(0xffff, shr(r, x))))
            r := or(r, shl(3, lt(0xff, shr(r, x))))

            z := div(shl(div(r, 3), shl(lt(0xf, shr(r, x)), 0xf)), xor(7, mod(r, 3)))

            z := div(add(add(div(x, mul(z, z)), z), z), 3)
            z := div(add(add(div(x, mul(z, z)), z), z), 3)
            z := div(add(add(div(x, mul(z, z)), z), z), 3)
            z := div(add(add(div(x, mul(z, z)), z), z), 3)
            z := div(add(add(div(x, mul(z, z)), z), z), 3)
            z := div(add(add(div(x, mul(z, z)), z), z), 3)
            z := div(add(add(div(x, mul(z, z)), z), z), 3)

            z := sub(z, lt(div(x, mul(z, z)), z))
        }
    }

    /// @dev Returns the square root of `x`, denominated in `WAD`.
    function sqrtWad(uint256 x) internal pure returns (uint256 z) {
        unchecked {
            z = 10 ** 9;
            if (x <= type(uint256).max / 10 ** 36 - 1) {
                x *= 10 ** 18;
                z = 1;
            }
            z *= sqrt(x);
        }
    }

    /// @dev Returns the cube root of `x`, denominated in `WAD`.
    function cbrtWad(uint256 x) internal pure returns (uint256 z) {
        unchecked {
            z = 10 ** 12;
            if (x <= (type(uint256).max / 10 ** 36) * 10 ** 18 - 1) {
                if (x >= type(uint256).max / 10 ** 36) {
                    x *= 10 ** 18;
                    z = 10 ** 6;
                } else {
                    x *= 10 ** 36;
                    z = 1;
                }
            }
            z *= cbrt(x);
        }
    }

    /// @dev Returns the factorial of `x`.
    function factorial(uint256 x) internal pure returns (uint256 result) {
        /// @solidity memory-safe-assembly
        assembly {
            if iszero(lt(x, 58)) {
                mstore(0x00, 0xaba0f2a2) // `FactorialOverflow()`.
                revert(0x1c, 0x04)
            }
            for { result := 1 } x { x := sub(x, 1) } { result := mul(result, x) }
        }
    }

    /// @dev Returns the log2 of `x`.
    /// Equivalent to computing the index of the most significant bit (MSB) of `x`.
    /// Returns 0 if `x` is zero.
    function log2(uint256 x) internal pure returns (uint256 r) {
        /// @solidity memory-safe-assembly
        assembly {
            r := shl(7, lt(0xffffffffffffffffffffffffffffffff, x))
            r := or(r, shl(6, lt(0xffffffffffffffff, shr(r, x))))
            r := or(r, shl(5, lt(0xffffffff, shr(r, x))))
            r := or(r, shl(4, lt(0xffff, shr(r, x))))
            r := or(r, shl(3, lt(0xff, shr(r, x))))
            // forgefmt: disable-next-item
            r := or(r, byte(and(0x1f, shr(shr(r, x), 0x8421084210842108cc6318c6db6d54be)),
                0x0706060506020504060203020504030106050205030304010505030400000000))
        }
    }

    /// @dev Returns the log2 of `x`, rounded up.
    /// Returns 0 if `x` is zero.
    function log2Up(uint256 x) internal pure returns (uint256 r) {
        r = log2(x);
        /// @solidity memory-safe-assembly
        assembly {
            r := add(r, lt(shl(r, 1), x))
        }
    }

    /// @dev Returns the log10 of `x`.
    /// Returns 0 if `x` is zero.
    function log10(uint256 x) internal pure returns (uint256 r) {
        /// @solidity memory-safe-assembly
        assembly {
            if iszero(lt(x, 100000000000000000000000000000000000000)) {
                x := div(x, 100000000000000000000000000000000000000)
                r := 38
            }
            if iszero(lt(x, 100000000000000000000)) {
                x := div(x, 100000000000000000000)
                r := add(r, 20)
            }
            if iszero(lt(x, 10000000000)) {
                x := div(x, 10000000000)
                r := add(r, 10)
            }
            if iszero(lt(x, 100000)) {
                x := div(x, 100000)
                r := add(r, 5)
            }
            r := add(r, add(gt(x, 9), add(gt(x, 99), add(gt(x, 999), gt(x, 9999)))))
        }
    }

    /// @dev Returns the log10 of `x`, rounded up.
    /// Returns 0 if `x` is zero.
    function log10Up(uint256 x) internal pure returns (uint256 r) {
        r = log10(x);
        /// @solidity memory-safe-assembly
        assembly {
            r := add(r, lt(exp(10, r), x))
        }
    }

    /// @dev Returns the log256 of `x`.
    /// Returns 0 if `x` is zero.
    function log256(uint256 x) internal pure returns (uint256 r) {
        /// @solidity memory-safe-assembly
        assembly {
            r := shl(7, lt(0xffffffffffffffffffffffffffffffff, x))
            r := or(r, shl(6, lt(0xffffffffffffffff, shr(r, x))))
            r := or(r, shl(5, lt(0xffffffff, shr(r, x))))
            r := or(r, shl(4, lt(0xffff, shr(r, x))))
            r := or(shr(3, r), lt(0xff, shr(r, x)))
        }
    }

    /// @dev Returns the log256 of `x`, rounded up.
    /// Returns 0 if `x` is zero.
    function log256Up(uint256 x) internal pure returns (uint256 r) {
        r = log256(x);
        /// @solidity memory-safe-assembly
        assembly {
            r := add(r, lt(shl(shl(3, r), 1), x))
        }
    }

    /// @dev Returns the scientific notation format `mantissa * 10 ** exponent` of `x`.
    /// Useful for compressing prices (e.g. using 25 bit mantissa and 7 bit exponent).
    function sci(uint256 x) internal pure returns (uint256 mantissa, uint256 exponent) {
        /// @solidity memory-safe-assembly
        assembly {
            mantissa := x
            if mantissa {
                if iszero(mod(mantissa, 1000000000000000000000000000000000)) {
                    mantissa := div(mantissa, 1000000000000000000000000000000000)
                    exponent := 33
                }
                if iszero(mod(mantissa, 10000000000000000000)) {
                    mantissa := div(mantissa, 10000000000000000000)
                    exponent := add(exponent, 19)
                }
                if iszero(mod(mantissa, 1000000000000)) {
                    mantissa := div(mantissa, 1000000000000)
                    exponent := add(exponent, 12)
                }
                if iszero(mod(mantissa, 1000000)) {
                    mantissa := div(mantissa, 1000000)
                    exponent := add(exponent, 6)
                }
                if iszero(mod(mantissa, 10000)) {
                    mantissa := div(mantissa, 10000)
                    exponent := add(exponent, 4)
                }
                if iszero(mod(mantissa, 100)) {
                    mantissa := div(mantissa, 100)
                    exponent := add(exponent, 2)
                }
                if iszero(mod(mantissa, 10)) {
                    mantissa := div(mantissa, 10)
                    exponent := add(exponent, 1)
                }
            }
        }
    }

    /// @dev Convenience function for packing `x` into a smaller number using `sci`.
    /// The `mantissa` will be in bits [7..255] (the upper 249 bits).
    /// The `exponent` will be in bits [0..6] (the lower 7 bits).
    /// Use `SafeCastLib` to safely ensure that the `packed` number is small
    /// enough to fit in the desired unsigned integer type:
    /// ```
    ///     uint32 packed = SafeCastLib.toUint32(FixedPointMathLib.packSci(777 ether));
    /// ```
    function packSci(uint256 x) internal pure returns (uint256 packed) {
        (x, packed) = sci(x); // Reuse for `mantissa` and `exponent`.
        /// @solidity memory-safe-assembly
        assembly {
            if shr(249, x) {
                mstore(0x00, 0xce30380c) // `MantissaOverflow()`.
                revert(0x1c, 0x04)
            }
            packed := or(shl(7, x), packed)
        }
    }

    /// @dev Convenience function for unpacking a packed number from `packSci`.
    function unpackSci(uint256 packed) internal pure returns (uint256 unpacked) {
        unchecked {
            unpacked = (packed >> 7) * 10 ** (packed & 0x7f);
        }
    }

    /// @dev Returns the average of `x` and `y`.
    function avg(uint256 x, uint256 y) internal pure returns (uint256 z) {
        unchecked {
            z = (x & y) + ((x ^ y) >> 1);
        }
    }

    /// @dev Returns the average of `x` and `y`.
    function avg(int256 x, int256 y) internal pure returns (int256 z) {
        unchecked {
            z = (x >> 1) + (y >> 1) + (x & y & 1);
        }
    }

    /// @dev Returns the absolute value of `x`.
    function abs(int256 x) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := xor(sub(0, shr(255, x)), add(sub(0, shr(255, x)), x))
        }
    }

    /// @dev Returns the absolute distance between `x` and `y`.
    function dist(int256 x, int256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := xor(mul(xor(sub(y, x), sub(x, y)), sgt(x, y)), sub(y, x))
        }
    }

    /// @dev Returns the minimum of `x` and `y`.
    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := xor(x, mul(xor(x, y), lt(y, x)))
        }
    }

    /// @dev Returns the minimum of `x` and `y`.
    function min(int256 x, int256 y) internal pure returns (int256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := xor(x, mul(xor(x, y), slt(y, x)))
        }
    }

    /// @dev Returns the maximum of `x` and `y`.
    function max(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := xor(x, mul(xor(x, y), gt(y, x)))
        }
    }

    /// @dev Returns the maximum of `x` and `y`.
    function max(int256 x, int256 y) internal pure returns (int256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := xor(x, mul(xor(x, y), sgt(y, x)))
        }
    }

    /// @dev Returns `x`, bounded to `minValue` and `maxValue`.
    function clamp(uint256 x, uint256 minValue, uint256 maxValue)
        internal
        pure
        returns (uint256 z)
    {
        /// @solidity memory-safe-assembly
        assembly {
            z := xor(x, mul(xor(x, minValue), gt(minValue, x)))
            z := xor(z, mul(xor(z, maxValue), lt(maxValue, z)))
        }
    }

    /// @dev Returns `x`, bounded to `minValue` and `maxValue`.
    function clamp(int256 x, int256 minValue, int256 maxValue) internal pure returns (int256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := xor(x, mul(xor(x, minValue), sgt(minValue, x)))
            z := xor(z, mul(xor(z, maxValue), slt(maxValue, z)))
        }
    }

    /// @dev Returns greatest common divisor of `x` and `y`.
    function gcd(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            for { z := x } y {} {
                let t := y
                y := mod(z, y)
                z := t
            }
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                   RAW NUMBER OPERATIONS                    */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns `x + y`, without checking for overflow.
    function rawAdd(uint256 x, uint256 y) internal pure returns (uint256 z) {
        unchecked {
            z = x + y;
        }
    }

    /// @dev Returns `x + y`, without checking for overflow.
    function rawAdd(int256 x, int256 y) internal pure returns (int256 z) {
        unchecked {
            z = x + y;
        }
    }

    /// @dev Returns `x - y`, without checking for underflow.
    function rawSub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        unchecked {
            z = x - y;
        }
    }

    /// @dev Returns `x - y`, without checking for underflow.
    function rawSub(int256 x, int256 y) internal pure returns (int256 z) {
        unchecked {
            z = x - y;
        }
    }

    /// @dev Returns `x * y`, without checking for overflow.
    function rawMul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        unchecked {
            z = x * y;
        }
    }

    /// @dev Returns `x * y`, without checking for overflow.
    function rawMul(int256 x, int256 y) internal pure returns (int256 z) {
        unchecked {
            z = x * y;
        }
    }

    /// @dev Returns `x / y`, returning 0 if `y` is zero.
    function rawDiv(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := div(x, y)
        }
    }

    /// @dev Returns `x / y`, returning 0 if `y` is zero.
    function rawSDiv(int256 x, int256 y) internal pure returns (int256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := sdiv(x, y)
        }
    }

    /// @dev Returns `x % y`, returning 0 if `y` is zero.
    function rawMod(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := mod(x, y)
        }
    }

    /// @dev Returns `x % y`, returning 0 if `y` is zero.
    function rawSMod(int256 x, int256 y) internal pure returns (int256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := smod(x, y)
        }
    }

    /// @dev Returns `(x + y) % d`, return 0 if `d` if zero.
    function rawAddMod(uint256 x, uint256 y, uint256 d) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := addmod(x, y, d)
        }
    }

    /// @dev Returns `(x * y) % d`, return 0 if `d` if zero.
    function rawMulMod(uint256 x, uint256 y, uint256 d) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := mulmod(x, y, d)
        }
    }
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {IERC4626} from "forge-std/interfaces/IERC4626.sol";
import {IPriceOracle} from "./interfaces/IPriceOracle.sol";
import {Errors} from "./lib/Errors.sol";
import {Governable} from "./lib/Governable.sol";

/// @title EulerRouter
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice Default Oracle resolver for Euler lending products.
/// @dev Integration Note: The router supports pricing via `convertToAssets` for trusted `resolvedVaults`.
/// By ERC4626 spec `convert*` ignores liquidity restrictions, fees, slippage and per-user restrictions.
/// Therefore the reported price may not be realizable through `redeem` or `withdraw`.
contract EulerRouter is Governable, IPriceOracle {
    /// @inheritdoc IPriceOracle
    string public constant name = "EulerRouter";
    /// @notice The PriceOracle to call if this router is not configured for base/quote.
    /// @dev If `address(0)` then there is no fallback.
    address public fallbackOracle;
    /// @notice ERC4626 vaults resolved using internal pricing (`convertToAssets`).
    mapping(address vault => address asset) public resolvedVaults;
    /// @notice PriceOracle configured per asset pair.
    /// @dev The keys are lexicographically sorted (asset0 < asset1).
    mapping(address asset0 => mapping(address asset1 => address oracle)) internal oracles;

    /// @notice Configure a PriceOracle to resolve an asset pair.
    /// @param asset0 The address first in lexicographic order.
    /// @param asset1 The address second in lexicographic order.
    /// @param oracle The address of the PriceOracle that resolves the pair.
    /// @dev If `oracle` is `address(0)` then the configuration was removed.
    /// The keys are lexicographically sorted (asset0 < asset1).
    event ConfigSet(address indexed asset0, address indexed asset1, address indexed oracle);
    /// @notice Set a PriceOracle as a fallback resolver.
    /// @param fallbackOracle The address of the PriceOracle that is called when base/quote is not configured.
    /// @dev If `fallbackOracle` is `address(0)` then there is no fallback resolver.
    event FallbackOracleSet(address indexed fallbackOracle);
    /// @notice Mark an ERC4626 vault to be resolved to its `asset` via its `convert*` methods.
    /// @param vault The address of the ERC4626 vault.
    /// @param asset The address of the vault's asset.
    /// @dev If `asset` is `address(0)` then the configuration was removed.
    event ResolvedVaultSet(address indexed vault, address indexed asset);

    /// @notice Deploy EulerRouter.
    /// @param _governor The address of the governor.
    constructor(address _evc, address _governor) Governable(_evc, _governor) {
        if (_governor == address(0)) revert Errors.PriceOracle_InvalidConfiguration();
    }

    /// @notice Configure a PriceOracle to resolve base/quote and quote/base.
    /// @param base The address of the base token.
    /// @param quote The address of the quote token.
    /// @param oracle The address of the PriceOracle to resolve the pair.
    /// @dev Callable only by the governor.
    function govSetConfig(address base, address quote, address oracle) external onlyEVCAccountOwner onlyGovernor {
        // This case is handled by `resolveOracle`.
        if (base == quote) revert Errors.PriceOracle_InvalidConfiguration();
        (address asset0, address asset1) = _sort(base, quote);
        oracles[asset0][asset1] = oracle;
        emit ConfigSet(asset0, asset1, oracle);
    }

    /// @notice Configure an ERC4626 vault to use internal pricing via `convert*` methods.
    /// @param vault The address of the ERC4626 vault.
    /// @param set True to configure the vault, false to clear the record.
    /// @dev Callable only by the governor. Vault must implement ERC4626.
    /// Note: Before configuring a vault verify that its `convertToAssets` is secure.
    function govSetResolvedVault(address vault, bool set) external onlyEVCAccountOwner onlyGovernor {
        address asset = set ? IERC4626(vault).asset() : address(0);
        resolvedVaults[vault] = asset;
        emit ResolvedVaultSet(vault, asset);
    }

    /// @notice Set a PriceOracle as a fallback resolver.
    /// @param _fallbackOracle The address of the PriceOracle that is called when base/quote is not configured.
    /// @dev Callable only by the governor. `address(0)` removes the fallback.
    function govSetFallbackOracle(address _fallbackOracle) external onlyEVCAccountOwner onlyGovernor {
        fallbackOracle = _fallbackOracle;
        emit FallbackOracleSet(_fallbackOracle);
    }

    /// @inheritdoc IPriceOracle
    function getQuote(uint256 inAmount, address base, address quote) external view returns (uint256) {
        address oracle;
        (inAmount, base, quote, oracle) = resolveOracle(inAmount, base, quote);
        if (base == quote) return inAmount;
        return IPriceOracle(oracle).getQuote(inAmount, base, quote);
    }

    /// @inheritdoc IPriceOracle
    function getQuotes(uint256 inAmount, address base, address quote) external view returns (uint256, uint256) {
        address oracle;
        (inAmount, base, quote, oracle) = resolveOracle(inAmount, base, quote);
        if (base == quote) return (inAmount, inAmount);
        return IPriceOracle(oracle).getQuotes(inAmount, base, quote);
    }

    /// @notice Get the PriceOracle configured for base/quote.
    /// @param base The address of the base token.
    /// @param quote The address of the quote token.
    /// @return The configured `PriceOracle` for the pair or `address(0)` if no oracle is configured.
    function getConfiguredOracle(address base, address quote) public view returns (address) {
        (address asset0, address asset1) = _sort(base, quote);
        return oracles[asset0][asset1];
    }

    /// @notice Resolve the PriceOracle to call for a given base/quote pair.
    /// @param inAmount The amount of `base` to convert.
    /// @param base The token that is being priced.
    /// @param quote The token that is the unit of account.
    /// @dev Implements the following resolution logic:
    /// 1. Check the base case: `base == quote` and terminate if true.
    /// 2. If a PriceOracle is configured for base/quote in the `oracles` mapping, return it.
    /// 3. If `base` is configured as a resolved ERC4626 vault, call `convertToAssets(inAmount)`
    /// and continue the recursion, substituting the ERC4626 `asset` for `base`.
    /// 4. As a last resort, return the fallback oracle or revert if it is not set.
    /// @return The resolved amount. This value may be different from the original `inAmount`
    /// if the resolution path included an ERC4626 vault present in `resolvedVaults`.
    /// @return The resolved base.
    /// @return The resolved quote.
    /// @return The resolved PriceOracle to call.
    function resolveOracle(uint256 inAmount, address base, address quote)
        public
        view
        returns (uint256, /* resolvedAmount */ address, /* base */ address, /* quote */ address /* oracle */ )
    {
        // 1. Check the base case.
        if (base == quote) return (inAmount, base, quote, address(0));
        // 2. Check if there is a PriceOracle configured for base/quote.
        address oracle = getConfiguredOracle(base, quote);
        if (oracle != address(0)) return (inAmount, base, quote, oracle);
        // 3. Recursively resolve `base`.
        address baseAsset = resolvedVaults[base];
        if (baseAsset != address(0)) {
            inAmount = IERC4626(base).convertToAssets(inAmount);
            return resolveOracle(inAmount, baseAsset, quote);
        }
        // 4. Return the fallback or revert if not configured.
        oracle = fallbackOracle;
        if (oracle == address(0)) revert Errors.PriceOracle_NotSupported(base, quote);
        return (inAmount, base, quote, oracle);
    }

    /// @notice Lexicographically sort two addresses.
    /// @param assetA One of the assets in the pair.
    /// @param assetB The other asset in the pair.
    /// @return The address first in lexicographic order.
    /// @return The address second in lexicographic order.
    function _sort(address assetA, address assetB) internal pure returns (address, address) {
        return assetA < assetB ? (assetA, assetB) : (assetB, assetA);
    }
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.8.0;

/// @title IPriceOracle
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice Common PriceOracle interface.
interface IPriceOracle {
    /// @notice Get the name of the oracle.
    /// @return The name of the oracle.
    function name() external view returns (string memory);

    /// @notice One-sided price: How much quote token you would get for inAmount of base token, assuming no price spread.
    /// @param inAmount The amount of `base` to convert.
    /// @param base The token that is being priced.
    /// @param quote The token that is the unit of account.
    /// @return outAmount The amount of `quote` that is equivalent to `inAmount` of `base`.
    function getQuote(uint256 inAmount, address base, address quote) external view returns (uint256 outAmount);

    /// @notice Two-sided price: How much quote token you would get/spend for selling/buying inAmount of base token.
    /// @param inAmount The amount of `base` to convert.
    /// @param base The token that is being priced.
    /// @param quote The token that is the unit of account.
    /// @return bidOutAmount The amount of `quote` you would get for selling `inAmount` of `base`.
    /// @return askOutAmount The amount of `quote` you would spend for buying `inAmount` of `base`.
    function getQuotes(uint256 inAmount, address base, address quote)
        external
        view
        returns (uint256 bidOutAmount, uint256 askOutAmount);
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

/// @title Errors
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice Collects common errors in PriceOracles.
library Errors {
    /// @notice The external feed returned an invalid answer.
    error PriceOracle_InvalidAnswer();
    /// @notice The configuration parameters for the PriceOracle are invalid.
    error PriceOracle_InvalidConfiguration();
    /// @notice The base/quote path is not supported.
    /// @param base The address of the base asset.
    /// @param quote The address of the quote asset.
    error PriceOracle_NotSupported(address base, address quote);
    /// @notice The quote cannot be completed due to overflow.
    error PriceOracle_Overflow();
    /// @notice The price is too stale.
    /// @param staleness The time elapsed since the price was updated.
    /// @param maxStaleness The maximum time elapsed since the last price update.
    error PriceOracle_TooStale(uint256 staleness, uint256 maxStaleness);
    /// @notice The method can only be called by the governor.
    error Governance_CallerNotGovernor();
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {EVCUtil} from "ethereum-vault-connector/utils/EVCUtil.sol";
import {Errors} from "./Errors.sol";

/// @title Governable
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice Contract mixin for governance, compatible with EVC.
abstract contract Governable is EVCUtil {
    /// @notice The active governor address. If `address(0)` then the role is renounced.
    address public governor;

    /// @notice Set the governor of the contract.
    /// @param oldGovernor The address of the previous governor.
    /// @param newGovernor The address of the newly appointed governor.
    event GovernorSet(address indexed oldGovernor, address indexed newGovernor);

    constructor(address _evc, address _governor) EVCUtil(_evc) {
        _setGovernor(_governor);
    }

    /// @notice Transfer the governor role to another address.
    /// @param newGovernor The address of the next governor.
    /// @dev Can only be called by the current governor.
    function transferGovernance(address newGovernor) external onlyEVCAccountOwner onlyGovernor {
        _setGovernor(newGovernor);
    }

    /// @notice Restrict access to the governor.
    /// @dev Consider also adding `onlyEVCAccountOwner` for stricter caller checks.
    modifier onlyGovernor() {
        if (_msgSender() != governor) {
            revert Errors.Governance_CallerNotGovernor();
        }
        _;
    }

    /// @notice Set the governor address.
    /// @param newGovernor The address of the new governor.
    function _setGovernor(address newGovernor) internal {
        emit GovernorSet(governor, newGovernor);
        governor = newGovernor;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

/// @dev Interface of the ERC20 standard as defined in the EIP.
/// @dev This includes the optional name, symbol, and decimals metadata.
interface IERC20 {
    /// @dev Emitted when `value` tokens are moved from one account (`from`) to another (`to`).
    event Transfer(address indexed from, address indexed to, uint256 value);

    /// @dev Emitted when the allowance of a `spender` for an `owner` is set, where `value`
    /// is the new allowance.
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /// @notice Returns the amount of tokens in existence.
    function totalSupply() external view returns (uint256);

    /// @notice Returns the amount of tokens owned by `account`.
    function balanceOf(address account) external view returns (uint256);

    /// @notice Moves `amount` tokens from the caller's account to `to`.
    function transfer(address to, uint256 amount) external returns (bool);

    /// @notice Returns the remaining number of tokens that `spender` is allowed
    /// to spend on behalf of `owner`
    function allowance(address owner, address spender) external view returns (uint256);

    /// @notice Sets `amount` as the allowance of `spender` over the caller's tokens.
    /// @dev Be aware of front-running risks: https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    function approve(address spender, uint256 amount) external returns (bool);

    /// @notice Moves `amount` tokens from `from` to `to` using the allowance mechanism.
    /// `amount` is then deducted from the caller's allowance.
    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    /// @notice Returns the name of the token.
    function name() external view returns (string memory);

    /// @notice Returns the symbol of the token.
    function symbol() external view returns (string memory);

    /// @notice Returns the decimals places of the token.
    function decimals() external view returns (uint8);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

import "./IERC20.sol";

/// @dev Interface of the ERC4626 "Tokenized Vault Standard", as defined in
/// https://eips.ethereum.org/EIPS/eip-4626
interface IERC4626 is IERC20 {
    event Deposit(address indexed sender, address indexed owner, uint256 assets, uint256 shares);

    event Withdraw(
        address indexed sender, address indexed receiver, address indexed owner, uint256 assets, uint256 shares
    );

    /// @notice Returns the address of the underlying token used for the Vault for accounting, depositing, and withdrawing.
    /// @dev
    /// - MUST be an ERC-20 token contract.
    /// - MUST NOT revert.
    function asset() external view returns (address assetTokenAddress);

    /// @notice Returns the total amount of the underlying asset that is “managed” by Vault.
    /// @dev
    /// - SHOULD include any compounding that occurs from yield.
    /// - MUST be inclusive of any fees that are charged against assets in the Vault.
    /// - MUST NOT revert.
    function totalAssets() external view returns (uint256 totalManagedAssets);

    /// @notice Returns the amount of shares that the Vault would exchange for the amount of assets provided, in an ideal
    /// scenario where all the conditions are met.
    /// @dev
    /// - MUST NOT be inclusive of any fees that are charged against assets in the Vault.
    /// - MUST NOT show any variations depending on the caller.
    /// - MUST NOT reflect slippage or other on-chain conditions, when performing the actual exchange.
    /// - MUST NOT revert.
    ///
    /// NOTE: This calculation MAY NOT reflect the “per-user” price-per-share, and instead should reflect the
    /// “average-user’s” price-per-share, meaning what the average user should expect to see when exchanging to and
    /// from.
    function convertToShares(uint256 assets) external view returns (uint256 shares);

    /// @notice Returns the amount of assets that the Vault would exchange for the amount of shares provided, in an ideal
    /// scenario where all the conditions are met.
    /// @dev
    /// - MUST NOT be inclusive of any fees that are charged against assets in the Vault.
    /// - MUST NOT show any variations depending on the caller.
    /// - MUST NOT reflect slippage or other on-chain conditions, when performing the actual exchange.
    /// - MUST NOT revert.
    ///
    /// NOTE: This calculation MAY NOT reflect the “per-user” price-per-share, and instead should reflect the
    /// “average-user’s” price-per-share, meaning what the average user should expect to see when exchanging to and
    /// from.
    function convertToAssets(uint256 shares) external view returns (uint256 assets);

    /// @notice Returns the maximum amount of the underlying asset that can be deposited into the Vault for the receiver,
    /// through a deposit call.
    /// @dev
    /// - MUST return a limited value if receiver is subject to some deposit limit.
    /// - MUST return 2 ** 256 - 1 if there is no limit on the maximum amount of assets that may be deposited.
    /// - MUST NOT revert.
    function maxDeposit(address receiver) external view returns (uint256 maxAssets);

    /// @notice Allows an on-chain or off-chain user to simulate the effects of their deposit at the current block, given
    /// current on-chain conditions.
    /// @dev
    /// - MUST return as close to and no more than the exact amount of Vault shares that would be minted in a deposit
    ///   call in the same transaction. I.e. deposit should return the same or more shares as previewDeposit if called
    ///   in the same transaction.
    /// - MUST NOT account for deposit limits like those returned from maxDeposit and should always act as though the
    ///   deposit would be accepted, regardless if the user has enough tokens approved, etc.
    /// - MUST be inclusive of deposit fees. Integrators should be aware of the existence of deposit fees.
    /// - MUST NOT revert.
    ///
    /// NOTE: any unfavorable discrepancy between convertToShares and previewDeposit SHOULD be considered slippage in
    /// share price or some other type of condition, meaning the depositor will lose assets by depositing.
    function previewDeposit(uint256 assets) external view returns (uint256 shares);

    /// @notice Mints shares Vault shares to receiver by depositing exactly amount of underlying tokens.
    /// @dev
    /// - MUST emit the Deposit event.
    /// - MAY support an additional flow in which the underlying tokens are owned by the Vault contract before the
    ///   deposit execution, and are accounted for during deposit.
    /// - MUST revert if all of assets cannot be deposited (due to deposit limit being reached, slippage, the user not
    ///   approving enough underlying tokens to the Vault contract, etc).
    ///
    /// NOTE: most implementations will require pre-approval of the Vault with the Vault’s underlying asset token.
    function deposit(uint256 assets, address receiver) external returns (uint256 shares);

    /// @notice Returns the maximum amount of the Vault shares that can be minted for the receiver, through a mint call.
    /// @dev
    /// - MUST return a limited value if receiver is subject to some mint limit.
    /// - MUST return 2 ** 256 - 1 if there is no limit on the maximum amount of shares that may be minted.
    /// - MUST NOT revert.
    function maxMint(address receiver) external view returns (uint256 maxShares);

    /// @notice Allows an on-chain or off-chain user to simulate the effects of their mint at the current block, given
    /// current on-chain conditions.
    /// @dev
    /// - MUST return as close to and no fewer than the exact amount of assets that would be deposited in a mint call
    ///   in the same transaction. I.e. mint should return the same or fewer assets as previewMint if called in the
    ///   same transaction.
    /// - MUST NOT account for mint limits like those returned from maxMint and should always act as though the mint
    ///   would be accepted, regardless if the user has enough tokens approved, etc.
    /// - MUST be inclusive of deposit fees. Integrators should be aware of the existence of deposit fees.
    /// - MUST NOT revert.
    ///
    /// NOTE: any unfavorable discrepancy between convertToAssets and previewMint SHOULD be considered slippage in
    /// share price or some other type of condition, meaning the depositor will lose assets by minting.
    function previewMint(uint256 shares) external view returns (uint256 assets);

    /// @notice Mints exactly shares Vault shares to receiver by depositing amount of underlying tokens.
    /// @dev
    /// - MUST emit the Deposit event.
    /// - MAY support an additional flow in which the underlying tokens are owned by the Vault contract before the mint
    ///   execution, and are accounted for during mint.
    /// - MUST revert if all of shares cannot be minted (due to deposit limit being reached, slippage, the user not
    ///   approving enough underlying tokens to the Vault contract, etc).
    ///
    /// NOTE: most implementations will require pre-approval of the Vault with the Vault’s underlying asset token.
    function mint(uint256 shares, address receiver) external returns (uint256 assets);

    /// @notice Returns the maximum amount of the underlying asset that can be withdrawn from the owner balance in the
    /// Vault, through a withdrawal call.
    /// @dev
    /// - MUST return a limited value if owner is subject to some withdrawal limit or timelock.
    /// - MUST NOT revert.
    function maxWithdraw(address owner) external view returns (uint256 maxAssets);

    /// @notice Allows an on-chain or off-chain user to simulate the effects of their withdrawal at the current block,
    /// given current on-chain conditions.
    /// @dev
    /// - MUST return as close to and no fewer than the exact amount of Vault shares that would be burned in a withdraw
    ///   call in the same transaction. I.e. withdraw should return the same or fewer shares as previewWithdraw if
    ///   called
    ///   in the same transaction.
    /// - MUST NOT account for withdrawal limits like those returned from maxWithdraw and should always act as though
    ///   the withdrawal would be accepted, regardless if the user has enough shares, etc.
    /// - MUST be inclusive of withdrawal fees. Integrators should be aware of the existence of withdrawal fees.
    /// - MUST NOT revert.
    ///
    /// NOTE: any unfavorable discrepancy between convertToShares and previewWithdraw SHOULD be considered slippage in
    /// share price or some other type of condition, meaning the depositor will lose assets by depositing.
    function previewWithdraw(uint256 assets) external view returns (uint256 shares);

    /// @notice Burns shares from owner and sends exactly assets of underlying tokens to receiver.
    /// @dev
    /// - MUST emit the Withdraw event.
    /// - MAY support an additional flow in which the underlying tokens are owned by the Vault contract before the
    ///   withdraw execution, and are accounted for during withdrawal.
    /// - MUST revert if all of assets cannot be withdrawn (due to withdrawal limit being reached, slippage, the owner
    ///   not having enough shares, etc).
    ///
    /// Note that some implementations will require pre-requesting to the Vault before a withdrawal may be performed.
    /// Those methods should be performed separately.
    function withdraw(uint256 assets, address receiver, address owner) external returns (uint256 shares);

    /// @notice Returns the maximum amount of Vault shares that can be redeemed from the owner balance in the Vault,
    /// through a redeem call.
    /// @dev
    /// - MUST return a limited value if owner is subject to some withdrawal limit or timelock.
    /// - MUST return balanceOf(owner) if owner is not subject to any withdrawal limit or timelock.
    /// - MUST NOT revert.
    function maxRedeem(address owner) external view returns (uint256 maxShares);

    /// @notice Allows an on-chain or off-chain user to simulate the effects of their redeemption at the current block,
    /// given current on-chain conditions.
    /// @dev
    /// - MUST return as close to and no more than the exact amount of assets that would be withdrawn in a redeem call
    ///   in the same transaction. I.e. redeem should return the same or more assets as previewRedeem if called in the
    ///   same transaction.
    /// - MUST NOT account for redemption limits like those returned from maxRedeem and should always act as though the
    ///   redemption would be accepted, regardless if the user has enough shares, etc.
    /// - MUST be inclusive of withdrawal fees. Integrators should be aware of the existence of withdrawal fees.
    /// - MUST NOT revert.
    ///
    /// NOTE: any unfavorable discrepancy between convertToAssets and previewRedeem SHOULD be considered slippage in
    /// share price or some other type of condition, meaning the depositor will lose assets by redeeming.
    function previewRedeem(uint256 shares) external view returns (uint256 assets);

    /// @notice Burns exactly shares from owner and sends assets of underlying tokens to receiver.
    /// @dev
    /// - MUST emit the Withdraw event.
    /// - MAY support an additional flow in which the underlying tokens are owned by the Vault contract before the
    ///   redeem execution, and are accounted for during redeem.
    /// - MUST revert if all of shares cannot be redeemed (due to withdrawal limit being reached, slippage, the owner
    ///   not having enough shares, etc).
    ///
    /// NOTE: some implementations will require pre-requesting to the Vault before a withdrawal may be performed.
    /// Those methods should be performed separately.
    function redeem(uint256 shares, address receiver, address owner) external returns (uint256 assets);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title AddressArray
 * @notice Implements a dynamic array of addresses using a mapping for storage efficiency, with the array length stored at index 0.
 * @dev This library provides basic functionalities such as push, pop, set, and retrieval of addresses in a storage-efficient manner.
 */
library AddressArray {
    /**
     * @dev Error thrown when attempting to access an index outside the bounds of the array.
     */
    error IndexOutOfBounds();

    /**
     * @dev Error thrown when attempting to pop an element from an empty array.
     */
    error PopFromEmptyArray();

    /**
     * @dev Error thrown when the output array provided for getting the list of addresses is too small.
     */
    error OutputArrayTooSmall();

    uint256 internal constant _ZERO_ADDRESS = 0x8000000000000000000000000000000000000000000000000000000000000000; // Next tx gas optimization
    uint256 internal constant _LENGTH_MASK  = 0x0000000000000000ffffffff0000000000000000000000000000000000000000;
    uint256 internal constant _ADDRESS_MASK = 0x000000000000000000000000ffffffffffffffffffffffffffffffffffffffff;
    uint256 internal constant _ONE_LENGTH   = 0x0000000000000000000000010000000000000000000000000000000000000000;
    uint256 internal constant _LENGTH_OFFSET = 160;

    /**
     * @dev Struct containing the raw mapping used to store the addresses and the array length.
     */
    struct Data {
        uint256[1 << 32] _raw;
    }

    /**
     * @notice Returns the number of addresses stored in the array.
     * @param self The instance of the Data struct.
     * @return The number of addresses.
     */
    function length(Data storage self) internal view returns (uint256) {
        return (self._raw[0] & _LENGTH_MASK) >> _LENGTH_OFFSET;
    }

    /**
     * @notice Retrieves the address at a specified index in the array. Reverts if the index is out of bounds.
     * @param self The instance of the Data struct.
     * @param i The index to retrieve the address from.
     * @return The address stored at the specified index.
     */
    function at(Data storage self, uint256 i) internal view returns (address) {
        if (length(self) <= i) revert IndexOutOfBounds();
        return address(uint160(self._raw[i] & _ADDRESS_MASK));
    }

    /**
     * @notice Retrieves the address at a specified index in the array without bounds checking.
     * @param self The instance of the Data struct.
     * @param i The index to retrieve the address from.
     * @return The address stored at the specified index.
     */
    function unsafeAt(Data storage self, uint256 i) internal view returns (address) {
        if (i >= 1 << 32) revert IndexOutOfBounds();
        return address(uint160(self._raw[i] & _ADDRESS_MASK));
    }

    /**
     * @notice Returns all addresses in the array from storage.
     * @param self The instance of the Data struct.
     * @return output Array containing all the addresses.
     */
    function get(Data storage self) internal view returns (address[] memory output) {
        assembly ("memory-safe") { // solhint-disable-line no-inline-assembly
            let lengthAndFirst := sload(self.slot)
            let len := shr(_LENGTH_OFFSET, and(lengthAndFirst, _LENGTH_MASK))
            let fst := and(lengthAndFirst, _ADDRESS_MASK)

            // Allocate array
            output := mload(0x40)
            mstore(0x40, add(output, mul(0x20, add(1, len))))
            mstore(output, len)

            if len {
                // Copy first element and then the rest in a loop
                let ptr := add(output, 0x20)
                mstore(ptr, fst)
                for { let i := 1 } lt(i, len) { i:= add(i, 1) } {
                    let item := and(sload(add(self.slot, i)), _ADDRESS_MASK)
                    mstore(add(ptr, mul(0x20, i)), item)
                }
            }
        }
    }

    /**
     * @notice Copies the addresses into the provided output array.
     * @param self The instance of the Data struct.
     * @param input The array to copy the addresses into.
     * @return output The provided output array filled with addresses.
     */
    function get(Data storage self, address[] memory input) internal view returns (address[] memory output) {
        output = input;
        bytes4 err = OutputArrayTooSmall.selector;
        assembly ("memory-safe") { // solhint-disable-line no-inline-assembly
            let lengthAndFirst := sload(self.slot)
            let len := shr(_LENGTH_OFFSET, and(lengthAndFirst, _LENGTH_MASK))
            let fst := and(lengthAndFirst, _ADDRESS_MASK)

            if gt(len, mload(input)) {
                mstore(0, err)
                revert(0, 4)
            }
            if len {
                // Copy first element and then the rest in a loop
                let ptr := add(output, 0x20)
                mstore(ptr, fst)
                for { let i := 1 } lt(i, len) { i:= add(i, 1) } {
                    let item := and(sload(add(self.slot, i)), _ADDRESS_MASK)
                    mstore(add(ptr, mul(0x20, i)), item)
                }
            }
        }
    }

    /**
     * @notice Adds an address to the end of the array.
     * @param self The instance of the Data struct.
     * @param account The address to add.
     * @return res The new length of the array.
     */
    function push(Data storage self, address account) internal returns (uint256 res) {
        assembly ("memory-safe") { // solhint-disable-line no-inline-assembly
            let lengthAndFirst := sload(self.slot)
            let len := shr(_LENGTH_OFFSET, and(lengthAndFirst, _LENGTH_MASK))

            switch len
            case 0 {
                sstore(self.slot, or(account, _ONE_LENGTH))
            }
            default {
                sstore(self.slot, add(lengthAndFirst, _ONE_LENGTH))
                sstore(add(self.slot, len), or(account, _ZERO_ADDRESS))
            }
            res := add(len, 1)
        }
    }

    /**
     * @notice Removes the last address from the array.
     * @param self The instance of the Data struct.
     */
    function pop(Data storage self) internal {
        bytes4 err = PopFromEmptyArray.selector;
        assembly ("memory-safe") { // solhint-disable-line no-inline-assembly
            let lengthAndFirst := sload(self.slot)
            let len := shr(_LENGTH_OFFSET, and(lengthAndFirst, _LENGTH_MASK))

            switch len
            case 0 {
                mstore(0, err)
                revert(0, 4)
            }
            case 1 {
                sstore(self.slot, _ZERO_ADDRESS)
            }
            default {
                sstore(self.slot, sub(lengthAndFirst, _ONE_LENGTH))
            }
        }
    }

    /**
     * @notice Array pop back operation for storage `self` that returns popped element.
     * @param self The instance of the Data struct.
     * @return res The address that was removed from the array.
     */
    function popGet(Data storage self) internal returns(address res) {
        bytes4 err = PopFromEmptyArray.selector;
        assembly ("memory-safe") { // solhint-disable-line no-inline-assembly
            let lengthAndFirst := sload(self.slot)
            let len := shr(_LENGTH_OFFSET, and(lengthAndFirst, _LENGTH_MASK))

            switch len
            case 0 {
                mstore(0, err)
                revert(0, 4)
            }
            case 1 {
                res := and(lengthAndFirst, _ADDRESS_MASK)
                sstore(self.slot, _ZERO_ADDRESS)
            }
            default {
                res := and(sload(add(self.slot, sub(len, 1))), _ADDRESS_MASK)
                sstore(self.slot, sub(lengthAndFirst, _ONE_LENGTH))
            }
        }
    }

    /**
     * @notice Sets the address at a specified index in the array.
     * @param self The instance of the Data struct.
     * @param index The index at which to set the address.
     * @param account The address to set at the specified index.
     */
    function set(Data storage self, uint256 index, address account) internal {
        bytes4 err = IndexOutOfBounds.selector;
        assembly ("memory-safe") { // solhint-disable-line no-inline-assembly
            let lengthAndFirst := sload(self.slot)
            let len := shr(_LENGTH_OFFSET, and(lengthAndFirst, _LENGTH_MASK))
            let fst := and(lengthAndFirst, _ADDRESS_MASK)

            if iszero(lt(index, len)) {
                mstore(0, err)
                revert(0, 4)
            }

            switch index
            case 0 {
                sstore(self.slot, or(xor(lengthAndFirst, fst), account))
            }
            default {
                sstore(add(self.slot, index), or(account, _ZERO_ADDRESS))
            }
        }
    }

    /**
     * @notice Erase length of the array.
     * @param self The instance of the Data struct.
     */
    function erase(Data storage self) internal {
        assembly ("memory-safe") { // solhint-disable-line no-inline-assembly
            sstore(self.slot, _ADDRESS_MASK)
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./AddressArray.sol";

/**
 * @title AddressSet
 * @notice Library for managing sets of addresses, allowing operations such as add, remove, and contains.
 * Utilizes the AddressArray library for underlying data storage.
 */
library AddressSet {
    using AddressArray for AddressArray.Data;

    uint256 internal constant _NULL_INDEX = type(uint256).max;

    /**
     * @dev Data struct from AddressArray.Data items
     * and lookup mapping address => index in data array.
     */
    struct Data {
        AddressArray.Data items;
        mapping(address => uint256) lookup;
    }

    /**
     * @notice Determines the number of addresses in the set.
     * @param s The set of addresses.
     * @return The number of addresses in the set.
     */
    function length(Data storage s) internal view returns (uint256) {
        return s.items.length();
    }

    /**
     * @notice Retrieves the address at a specified index in the set. Reverts if the index is out of bounds.
     * @param s The set of addresses.
     * @param index The index of the address to retrieve.
     * @return The address at the specified index.
     */
    function at(Data storage s, uint256 index) internal view returns (address) {
        return s.items.at(index);
    }

    /**
     * @notice Retrieves the address at a specified index in the set without bounds checking.
     * @param s The set of addresses.
     * @param index The index of the address to retrieve.
     * @return The address at the specified index.
     */
    function unsafeAt(Data storage s, uint256 index) internal view returns (address) {
        return s.items.unsafeAt(index);
    }

    /**
     * @notice Checks if the set contains the specified address.
     * @param s The set of addresses.
     * @param item The address to check for.
     * @return True if the set contains the address, false otherwise.
     */
    function contains(Data storage s, address item) internal view returns (bool) {
        uint256 index = s.lookup[item];
        return index != 0 && index != _NULL_INDEX;
    }

    /**
     * @notice Returns list of addresses from storage `s`.
     * @param s The set of addresses.
     * @return The array of addresses stored in `s`.
     */
    function get(Data storage s) internal view returns (address[] memory) {
        return s.items.get();
    }

    /**
     * @notice Puts list of addresses from `s` storage into `output` array.
     * @param s The set of addresses.
     * @return The provided output array filled with addresses.
     */
    function get(Data storage s, address[] memory input) internal view returns (address[] memory) {
        return s.items.get(input);
    }

    /**
     * @notice Adds an address to the set if it is not already present.
     * @param s The set of addresses.
     * @param item The address to add.
     * @return True if the address was added to the set, false if it was already present.
     */
    function add(Data storage s, address item) internal returns (bool) {
        uint256 index = s.lookup[item];
        if (index != 0 && index != _NULL_INDEX) {
            return false;
        }
        s.lookup[item] = s.items.push(item);
        return true;
    }

    /**
     * @notice Removes an address from the set if it exists.
     * @param s The set of addresses.
     * @param item The address to remove.
     * @return True if the address was removed from the set, false if it was not found.
     */
    function remove(Data storage s, address item) internal returns (bool) {
        uint256 index = s.lookup[item];
        s.lookup[item] = _NULL_INDEX;
        if (index == 0 || index == _NULL_INDEX) {
            return false;
        }

        address lastItem = s.items.popGet();
        if (lastItem != item) {
            unchecked {
                s.items.set(index - 1, lastItem);
                s.lookup[lastItem] = index;
            }
        }
        return true;
    }

    /**
     * @notice Erases set from storage `s`.
     * @param s The set of addresses.
     * @return items All removed items.
     */
    function erase(Data storage s) internal returns(address[] memory items) {
        items = s.items.get();
        uint256 len = items.length;
        if (len > 0) {
            s.items.erase();
            unchecked {
                for (uint256 i = 0; i < len; i++) {
                    s.lookup[items[i]] = _NULL_INDEX;
                }
            }
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { AddressArray, AddressSet } from "@1inch/solidity-utils/contracts/libraries/AddressSet.sol";
import { IERC20, ERC20Upgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";

import { IERC20Plugins } from "./interfaces/IERC20Plugins.sol";
import { IPlugin } from "./interfaces/IPlugin.sol";
import { ReentrancyGuardExt, ReentrancyGuardLib } from "./libs/ReentrancyGuard.sol";

/**
 * @title ERC20PluginsUpgradeable
 * @dev A base implementation of token contract to hold and manage plugins of an ERC20 token with a limited number of
 * plugins per account.
 * Each plugin is a contract that implements IPlugin interface (and/or derived from plugin).
 */
abstract contract ERC20PluginsUpgradeable is ERC20Upgradeable, IERC20Plugins, ReentrancyGuardExt {
    using AddressSet for AddressSet.Data;
    using AddressArray for AddressArray.Data;
    using ReentrancyGuardLib for ReentrancyGuardLib.Data;

    /// @custom:storage-location erc7201:storage.ERC20PluginsUpgradeable
    struct ERC20PluginsStorage {
        /// @dev Limit of plugins per account
        // solhint-disable-next-line var-name-mixedcase
        uint256 MAX_PLUGINS_PER_ACCOUNT;
        /// @dev Gas limit for a single plugin call
        // solhint-disable-next-line var-name-mixedcase
        uint256 PLUGIN_CALL_GAS_LIMIT;
        ReentrancyGuardLib.Data _guard;
        mapping(address => AddressSet.Data) _plugins;
    }

    // keccak256(abi.encode(uint256(keccak256("storage.ERC20PluginsUpgradeable")) - 1)) & ~bytes32(uint256(0xff))
    // solhint-disable-next-line private-vars-leading-underscore,const-name-snakecase
    bytes32 private constant ERC20PluginsStorageLocation =
        0x4108db94c380a8d8a20de99d345afff9c495eeb068ca094fde639726075c9400;

    function _getERC20PluginsStorage() internal pure returns (ERC20PluginsStorage storage $) {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            $.slot := ERC20PluginsStorageLocation
        }
    }

    // solhint-disable-next-line func-name-mixedcase
    function __ERC20Plugins_init(uint256 pluginsLimit_, uint256 pluginCallGasLimit_) internal onlyInitializing {
        __ERC20Plugins_init_unchained(pluginsLimit_, pluginCallGasLimit_);
    }

    /**
     * @dev Initializer function that sets the limit of plugins per account and the gas limit for a plugin call.
     * @param pluginsLimit The limit of plugins per account.
     * @param pluginCallGasLimit The gas limit for a plugin call. Intended to prevent gas bomb attacks
     */
    // solhint-disable-next-line func-name-mixedcase
    function __ERC20Plugins_init_unchained(uint256 pluginsLimit, uint256 pluginCallGasLimit) internal {
        if (pluginsLimit == 0) revert ZeroPluginsLimit();
        ERC20PluginsStorage storage $ = _getERC20PluginsStorage();
        $.MAX_PLUGINS_PER_ACCOUNT = pluginsLimit;
        $.PLUGIN_CALL_GAS_LIMIT = pluginCallGasLimit;
        $._guard.init();
    }

    /**
     * @notice See {IERC20Plugins-MAX_PLUGINS_PER_ACCOUNT}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function MAX_PLUGINS_PER_ACCOUNT() public view virtual returns (uint256) {
        return _getERC20PluginsStorage().MAX_PLUGINS_PER_ACCOUNT;
    }

    /**
     * @notice See {IERC20Plugins-PLUGIN_CALL_GAS_LIMIT}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function PLUGIN_CALL_GAS_LIMIT() public view virtual returns (uint256) {
        return _getERC20PluginsStorage().PLUGIN_CALL_GAS_LIMIT;
    }

    /**
     * @notice See {IERC20Plugins-hasPlugin}.
     */
    function hasPlugin(address account, address plugin) public view virtual returns (bool) {
        return _getERC20PluginsStorage()._plugins[account].contains(plugin);
    }

    /**
     * @notice See {IERC20Plugins-pluginsCount}.
     */
    function pluginsCount(address account) public view virtual returns (uint256) {
        return _getERC20PluginsStorage()._plugins[account].length();
    }

    /**
     * @notice See {IERC20Plugins-pluginAt}.
     */
    function pluginAt(address account, uint256 index) public view virtual returns (address) {
        return _getERC20PluginsStorage()._plugins[account].at(index);
    }

    /**
     * @notice See {IERC20Plugins-plugins}.
     */
    function plugins(address account) public view virtual returns (address[] memory) {
        return _getERC20PluginsStorage()._plugins[account].items.get();
    }

    /**
     * @dev Returns the balance of a given account.
     * @param account The address of the account.
     * @return balance The account balance.
     */
    function balanceOf(address account)
        public
        view
        virtual
        override(IERC20, ERC20Upgradeable)
        nonReentrantView(_getERC20PluginsStorage()._guard)
        returns (uint256)
    {
        return super.balanceOf(account);
    }

    /**
     * @notice See {IERC20Plugins-pluginBalanceOf}.
     */
    function pluginBalanceOf(
        address plugin,
        address account
    )
        public
        view
        virtual
        nonReentrantView(_getERC20PluginsStorage()._guard)
        returns (uint256)
    {
        if (hasPlugin(account, plugin)) {
            return super.balanceOf(account);
        }
        return 0;
    }

    /**
     * @notice See {IERC20Plugins-addPlugin}.
     */
    function addPlugin(address plugin) public virtual {
        _addPlugin(msg.sender, plugin);
    }

    /**
     * @notice See {IERC20Plugins-removePlugin}.
     */
    function removePlugin(address plugin) public virtual {
        _removePlugin(msg.sender, plugin);
    }

    /**
     * @notice See {IERC20Plugins-removeAllPlugins}.
     */
    function removeAllPlugins() public virtual {
        _removeAllPlugins(msg.sender);
    }

    function _addPlugin(address account, address plugin) internal virtual {
        if (plugin == address(0)) revert InvalidPluginAddress();
        if (IPlugin(plugin).TOKEN() != IERC20Plugins(address(this))) revert InvalidTokenInPlugin();
        ERC20PluginsStorage storage $ = _getERC20PluginsStorage();
        if (!$._plugins[account].add(plugin)) revert PluginAlreadyAdded();
        if ($._plugins[account].length() > $.MAX_PLUGINS_PER_ACCOUNT) revert PluginsLimitReachedForAccount();

        emit PluginAdded(account, plugin);
        uint256 balance = balanceOf(account);
        if (balance > 0) {
            _updateBalances(plugin, address(0), account, balance);
        }
    }

    function _removePlugin(address account, address plugin) internal virtual {
        if (!_getERC20PluginsStorage()._plugins[account].remove(plugin)) revert PluginNotFound();

        emit PluginRemoved(account, plugin);
        uint256 balance = balanceOf(account);
        if (balance > 0) {
            _updateBalances(plugin, account, address(0), balance);
        }
    }

    function _removeAllPlugins(address account) internal virtual {
        ERC20PluginsStorage storage $ = _getERC20PluginsStorage();
        address[] memory pluginItems = $._plugins[account].items.get();
        uint256 balance = balanceOf(account);
        unchecked {
            for (uint256 i = pluginItems.length; i > 0; i--) {
                address item = pluginItems[i - 1];
                $._plugins[account].remove(item);
                emit PluginRemoved(account, item);
                if (balance > 0) {
                    _updateBalances(item, account, address(0), balance);
                }
            }
        }
    }

    /// @notice Assembly implementation of the gas limited call to avoid return gas bomb,
    // moreover call to a destructed plugin would also revert even inside try-catch block in Solidity 0.8.17
    /// @dev try IPlugin(plugin).updateBalances{gas: _PLUGIN_CALL_GAS_LIMIT}(from, to, amount) {} catch {}
    function _updateBalances(address plugin, address from, address to, uint256 amount) private {
        bytes4 selector = IPlugin.updateBalances.selector;
        uint256 gasLimit = _getERC20PluginsStorage().PLUGIN_CALL_GAS_LIMIT;
        // solhint-disable-next-line no-inline-assembly
        assembly ("memory-safe") {
            let ptr := mload(0x40)
            mstore(ptr, selector)
            mstore(add(ptr, 0x04), from)
            mstore(add(ptr, 0x24), to)
            mstore(add(ptr, 0x44), amount)

            let gasLeft := gas()
            if iszero(call(gasLimit, plugin, 0, ptr, 0x64, 0, 0)) {
                if lt(div(mul(gasLeft, 63), 64), gasLimit) {
                    returndatacopy(ptr, 0, returndatasize())
                    revert(ptr, returndatasize())
                }
            }
        }
    }

    function _update(
        address from,
        address to,
        uint256 amount
    )
        internal
        virtual
        override
        nonReentrant(_getERC20PluginsStorage()._guard)
    {
        super._update(from, to, amount);

        unchecked {
            if (amount > 0 && from != to) {
                ERC20PluginsStorage storage $ = _getERC20PluginsStorage();
                address[] memory pluginsFrom = $._plugins[from].items.get();
                address[] memory pluginsTo = $._plugins[to].items.get();
                uint256 pluginsFromLength = pluginsFrom.length;
                uint256 pluginsToLength = pluginsTo.length;

                for (uint256 i = 0; i < pluginsFromLength; i++) {
                    address plugin = pluginsFrom[i];

                    uint256 j;
                    for (j = 0; j < pluginsToLength; j++) {
                        if (plugin == pluginsTo[j]) {
                            // Both parties are participating in the same plugin
                            _updateBalances(plugin, from, to, amount);
                            pluginsTo[j] = address(0);
                            break;
                        }
                    }

                    if (j == pluginsToLength) {
                        // Sender is participating in a plugin, but receiver is not
                        _updateBalances(plugin, from, address(0), amount);
                    }
                }

                for (uint256 j = 0; j < pluginsToLength; j++) {
                    address plugin = pluginsTo[j];
                    if (plugin != address(0)) {
                        // Receiver is participating in a plugin, but sender is not
                        _updateBalances(plugin, address(0), to, amount);
                    }
                }
            }
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IERC20Plugins is IERC20 {
    event PluginAdded(address account, address plugin);
    event PluginRemoved(address account, address plugin);

    error PluginAlreadyAdded();
    error PluginNotFound();
    error InvalidPluginAddress();
    error InvalidTokenInPlugin();
    error PluginsLimitReachedForAccount();
    error ZeroPluginsLimit();

    /**
     * @dev Returns the maximum allowed number of plugins per account.
     * @return pluginsLimit The maximum allowed number of plugins per account.
     */
    function MAX_PLUGINS_PER_ACCOUNT() external view returns(uint256 pluginsLimit); // solhint-disable-line func-name-mixedcase

    /**
     * @dev Returns the gas limit allowed to be spend by plugin per call.
     * @return gasLimit The gas limit allowed to be spend by plugin per call.
     */
    function PLUGIN_CALL_GAS_LIMIT() external view returns(uint256 gasLimit); // solhint-disable-line func-name-mixedcase

    /**
     * @dev Returns whether an account has a specific plugin.
     * @param account The address of the account.
     * @param plugin The address of the plugin.
     * @return hasPlugin A boolean indicating whether the account has the specified plugin.
     */
    function hasPlugin(address account, address plugin) external view returns(bool hasPlugin);

    /**
     * @dev Returns the number of plugins registered for an account.
     * @param account The address of the account.
     * @return count The number of plugins registered for the account.
     */
    function pluginsCount(address account) external view returns(uint256 count);

    /**
     * @dev Returns the address of a plugin at a specified index for a given account.
     * The function will revert if index is greater or equal than `pluginsCount(account)`.
     * @param account The address of the account.
     * @param index The index of the plugin to retrieve.
     * @return plugin The address of the plugin.
     */
    function pluginAt(address account, uint256 index) external view returns(address plugin);

    /**
     * @dev Returns an array of all plugins owned by a given account.
     * @param account The address of the account to query.
     * @return plugins An array of plugin addresses.
     */
    function plugins(address account) external view returns(address[] memory plugins);

    /**
     * @dev Returns the balance of a given account if a specified plugin is added or zero.
     * @param plugin The address of the plugin to query.
     * @param account The address of the account to query.
     * @return balance The account balance if the specified plugin is added and zero otherwise.
     */
    function pluginBalanceOf(address plugin, address account) external view returns(uint256 balance);

    /**
     * @dev Adds a new plugin for the calling account.
     * @param plugin The address of the plugin to add.
     */
    function addPlugin(address plugin) external;

    /**
     * @dev Removes a plugin for the calling account.
     * @param plugin The address of the plugin to remove.
     */
    function removePlugin(address plugin) external;

    /**
     * @dev Removes all plugins for the calling account.
     */
    function removeAllPlugins() external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { IERC20Plugins } from "./IERC20Plugins.sol";

interface IPlugin {
    /**
     * @dev Returns the token which this plugin belongs to.
     * @return erc20 The IERC20Plugins token.
     */
    function TOKEN() external view returns(IERC20Plugins erc20); // solhint-disable-line func-name-mixedcase

    /**
     * @dev Updates the balances of two addresses in the plugin as a result of any balance changes.
     * Only the Token contract is allowed to call this function.
     * @param from The address from which tokens were transferred.
     * @param to The address to which tokens were transferred.
     * @param amount The amount of tokens transferred.
     */
    function updateBalances(address from, address to, uint256 amount) external;
}
// SPDX-License-Identifier: MIT

// solhint-disable one-contract-per-file

pragma solidity ^0.8.0;

/**
 * @title ReentrancyGuardLib
 * @dev Library that provides reentrancy protection for functions.
 */
library ReentrancyGuardLib {

    /// @dev Emit when reentrancy detected
    error ReentrantCall();

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    /// @dev Struct to hold the current status of the contract.
    struct Data {
        uint256 _status;
    }

    /**
     * @dev Initializes the struct with the current status set to not entered.
     * @param self The storage reference to the struct.
     */
    function init(Data storage self) internal {
        self._status = _NOT_ENTERED;
    }

    /**
     * @dev Sets the status to entered if it is not already entered, otherwise reverts.
     * @param self The storage reference to the struct.
     */
    function enter(Data storage self) internal {
        if (self._status == _ENTERED) revert ReentrantCall();
        self._status = _ENTERED;
    }

    /**
     * @dev Resets the status to not entered.
     * @param self The storage reference to the struct.
     */
    function exit(Data storage self) internal {
        self._status = _NOT_ENTERED;
    }

    /**
     * @dev Checks the current status of the contract to ensure that it is not already entered.
     * @param self The storage reference to the struct.
     * @return Whether or not the contract is currently entered.
     */
    function check(Data storage self) internal view returns (bool) {
        return self._status == _ENTERED;
    }
}

/**
 * @title ReentrancyGuardExt
 * @dev Contract that uses the ReentrancyGuardLib to provide reentrancy protection.
 */
contract ReentrancyGuardExt {
    using ReentrancyGuardLib for ReentrancyGuardLib.Data;

    /**
     * @dev Modifier that prevents a contract from calling itself, directly or indirectly.
     * @param self The storage reference to the struct.
     */
    modifier nonReentrant(ReentrancyGuardLib.Data storage self) {
        self.enter();
        _;
        self.exit();
    }

    /**
     * @dev Modifier that prevents calls to a function from `nonReentrant` functions, directly or indirectly.
     * @param self The storage reference to the struct.
     */
    modifier nonReentrantView(ReentrancyGuardLib.Data storage self) {
        if (self.check()) revert ReentrancyGuardLib.ReentrantCall();
        _;
    }
}
// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.28;

import { AccessControlEnumerable } from "@openzeppelin/contracts/access/extensions/AccessControlEnumerable.sol";
import { BitFlag } from "src/libraries/BitFlag.sol";

/// @title AssetRegistry
/// @dev Manages the registration and status of assets in the system.
/// @notice This contract provides functionality to add, enable, pause, and manage assets, with role-based access
/// control.
/// @dev Utilizes OpenZeppelin's AccessControlEnumerable for granular permission management.
/// @dev Supports three asset states: DISABLED -> ENABLED <-> PAUSED.
contract AssetRegistry is AccessControlEnumerable {
    /// ENUMS ///
    enum AssetStatus {
        /// @notice Asset is disabled and cannot be used in the system
        DISABLED,
        /// @notice Asset is enabled and can be used normally in the system
        ENABLED,
        /// @notice Asset is paused and cannot be used until unpaused
        PAUSED
    }

    /// STRUCTS ///
    /// @notice Contains the index and status of an asset in the registry.
    struct AssetData {
        uint32 indexPlusOne;
        AssetStatus status;
    }

    /// CONSTANTS ///
    /// @notice Role responsible for managing assets in the registry.
    bytes32 private constant _MANAGER_ROLE = keccak256("MANAGER_ROLE");
    /// @dev Maximum number of assets that can be registered in the system.
    uint256 private constant _MAX_ASSETS = 255;

    /// STATE VARIABLES ///
    /// @dev Array of assets registered in the system.
    address[] private _assetList;
    /// @dev Mapping from asset address to AssetData struct containing the asset's index and status.
    mapping(address asset => AssetData) private _assetRegistry;
    /// @notice Bit flag representing the enabled assets in the registry.
    uint256 public enabledAssets;

    /// EVENTS ///
    /// @dev Emitted when a new asset is added to the registry.
    event AddAsset(address indexed asset);
    /// @dev Emitted when an asset's status is updated.
    event SetAssetStatus(address indexed asset, AssetStatus status);

    /// ERRORS ///
    /// @notice Thrown when the asset address is zero.
    error ZeroAddress();
    /// @notice Thrown when attempting to add an asset that is already enabled in the registry.
    error AssetAlreadyEnabled();
    /// @notice Thrown when attempting to perform an operation on an asset that is not enabled in the registry.
    error AssetNotEnabled();
    /// @notice Thrown when attempting to set the asset status to an invalid status.
    error AssetInvalidStatusUpdate();
    /// @notice Thrown when attempting to add an asset when the maximum number of assets has been reached.
    error MaxAssetsReached();
    /// @notice Thrown when length of the requested assets exceeds the maximum number of assets.
    error AssetExceedsMaximum();

    /// @notice Initializes the AssetRegistry contract
    /// @dev Sets up initial roles for admin and manager
    /// @param admin The address to be granted the DEFAULT_ADMIN_ROLE
    /// @dev Reverts if:
    ///      - The admin address is zero (ZeroAddress)
    // slither-disable-next-line locked-ether
    constructor(address admin) payable {
        if (admin == address(0)) revert ZeroAddress();
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(_MANAGER_ROLE, admin);
    }

    /// @notice Adds a new asset to the registry
    /// @dev Only callable by accounts with the MANAGER_ROLE
    /// @param asset The address of the asset to be added
    /// @dev Reverts if:
    ///      - The caller doesn't have the MANAGER_ROLE (OpenZeppelin's AccessControl)
    ///      - The asset address is zero (ZeroAddress)
    ///      - The asset is already enabled (AssetAlreadyEnabled)
    ///      - The maximum number of assets has been reached (MaxAssetsReached)
    function addAsset(address asset) external onlyRole(_MANAGER_ROLE) {
        if (asset == address(0)) revert ZeroAddress();
        AssetData storage assetData = _assetRegistry[asset];
        if (assetData.indexPlusOne > 0) revert AssetAlreadyEnabled();
        uint256 assetLength = _assetList.length;
        if (assetLength == _MAX_ASSETS) revert MaxAssetsReached();

        _assetList.push(asset);
        assetData.indexPlusOne = uint32(assetLength + 1);
        assetData.status = AssetStatus.ENABLED;
        enabledAssets = enabledAssets | (1 << assetLength);
        emit AddAsset(asset);
    }

    /// @notice Sets the status of an asset in the registry
    /// @dev Only callable by accounts with the MANAGER_ROLE
    /// @param asset The address of the asset to update
    /// @param newStatus The new status to set (ENABLED or PAUSED)
    /// @dev Reverts if:
    ///      - The caller doesn't have the MANAGER_ROLE (OpenZeppelin's AccessControl)
    ///      - The asset address is zero (ZeroAddress)
    ///      - The asset is not enabled in the registry (AssetNotEnabled)
    ///      - The new status is invalid (AssetInvalidStatusUpdate)
    function setAssetStatus(address asset, AssetStatus newStatus) external onlyRole(_MANAGER_ROLE) {
        if (asset == address(0)) revert ZeroAddress();
        AssetData storage assetData = _assetRegistry[asset];
        uint256 indexPlusOne = assetData.indexPlusOne;
        if (indexPlusOne == 0) revert AssetNotEnabled();
        if (newStatus == AssetStatus.DISABLED || assetData.status == newStatus) revert AssetInvalidStatusUpdate();
        // Based on the index of the asset in the registry, update the enabledAssets bit flag
        // If the new status is ENABLED, set the bit to 1, otherwise set it to 0
        if (newStatus == AssetStatus.ENABLED) {
            enabledAssets = enabledAssets | (1 << (indexPlusOne - 1));
        } else {
            // case: newStatus == AssetStatus.PAUSED
            enabledAssets = enabledAssets & ~(1 << (indexPlusOne - 1));
        }

        assetData.status = newStatus;
        emit SetAssetStatus(asset, newStatus);
    }

    /// @notice Retrieves the status of an asset
    /// @dev Returns the status of the asset. For non-existent assets, returns status as DISABLED
    /// @param asset The address of the asset to query
    /// @return AssetStatus The status of the asset
    function getAssetStatus(address asset) external view returns (AssetStatus) {
        AssetData storage assetData = _assetRegistry[asset];
        return assetData.status;
    }

    /// @notice Retrieves the list of assets in the registry. Parameter bitFlag is used to filter the assets.
    /// @param bitFlag The bit flag to filter the assets.
    /// @return assets The list of assets in the registry.
    function getAssets(uint256 bitFlag) external view returns (address[] memory assets) {
        uint256 maxLength = _assetList.length;

        // If the bit flag is greater than the bit flag for the latest asset, revert
        // This is to prevent accessing assets that are not present in the registry
        if (bitFlag > (1 << maxLength) - 1) {
            revert AssetExceedsMaximum();
        }

        // Initialize the return array
        assets = new address[](BitFlag.popCount(bitFlag));
        uint256 index = 0;

        // Iterate through the assets and populate the return array
        for (uint256 i; i < maxLength && bitFlag != 0;) {
            if (bitFlag & 1 != 0) {
                // nosemgrep: solidity.performance.state-variable-read-in-a-loop.state-variable-read-in-a-loop
                assets[index++] = _assetList[i];
            }
            bitFlag >>= 1;
            unchecked {
                // Overflow not possible: i is bounded by maxLength which is less than 2^256 - 1
                ++i;
            }
        }
    }

    /// @notice Retrieves the addresses of all assets in the registry without any filtering.
    /// @return assets The list of addresses of all assets in the registry.
    function getAllAssets() external view returns (address[] memory) {
        return _assetList;
    }

    /// @notice Checks if any assets in the given bit flag are paused.
    /// @param bitFlag The bit flag representing a set of assets.
    /// @return bool True if any of the assets are paused, false otherwise.
    function hasPausedAssets(uint256 bitFlag) external view returns (bool) {
        return (enabledAssets & bitFlag) != bitFlag;
    }

    /// @notice Retrieves the bit flag for a given list of assets.
    /// @param assets The list of assets to get the bit flag for.
    /// @return bitFlag The bit flag representing the list of assets.
    /// @dev This function is for off-chain usage to get the bit flag for a list of assets.
    ///    Reverts if:
    ///     - the number of assets exceeds the maximum number of assets
    ///     - an asset is not enabled in the registry
    function getAssetsBitFlag(address[] memory assets) external view returns (uint256) {
        uint256 bitFlag;
        uint256 assetsLength = assets.length;

        if (assetsLength > _assetList.length) {
            revert AssetExceedsMaximum();
        }

        for (uint256 i; i < assetsLength;) {
            // nosemgrep: solidity.performance.state-variable-read-in-a-loop.state-variable-read-in-a-loop
            uint256 indexPlusOne = _assetRegistry[assets[i]].indexPlusOne;
            if (indexPlusOne == 0) {
                revert AssetNotEnabled();
            }

            unchecked {
                // Overflow not possible: indexPlusOne is bounded by _assetList.length which is less than 2^256 - 1
                // Underflow not possible: indexPlusOne is checked to be non-zero
                bitFlag |= 1 << (indexPlusOne - 1);
                // Overflow not possible: i is bounded by assetsLength which is less than 2^256 - 1
                ++i;
            }
        }

        return bitFlag;
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import { AccessControlEnumerable } from "@openzeppelin/contracts/access/extensions/AccessControlEnumerable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { Pausable } from "@openzeppelin/contracts/utils/Pausable.sol";
import { ReentrancyGuardTransient } from "@openzeppelin/contracts/utils/ReentrancyGuardTransient.sol";
import { EulerRouter } from "euler-price-oracle/src/EulerRouter.sol";

import { AssetRegistry } from "src/AssetRegistry.sol";
import { BasketToken } from "src/BasketToken.sol";
import { FeeCollector } from "src/FeeCollector.sol";
import { Rescuable } from "src/Rescuable.sol";
import { BasketManagerUtils } from "src/libraries/BasketManagerUtils.sol";
import { StrategyRegistry } from "src/strategies/StrategyRegistry.sol";
import { WeightStrategy } from "src/strategies/WeightStrategy.sol";
import { TokenSwapAdapter } from "src/swap_adapters/TokenSwapAdapter.sol";
import { BasketManagerStorage, RebalanceStatus, Status } from "src/types/BasketManagerStorage.sol";
import { ExternalTrade, InternalTrade } from "src/types/Trades.sol";

/// @title BasketManager
/// @notice Contract responsible for managing baskets and their tokens. The accounting for assets per basket is done
/// in the BasketManagerUtils contract.
contract BasketManager is ReentrancyGuardTransient, AccessControlEnumerable, Pausable, Rescuable {
    /// LIBRARIES ///
    using BasketManagerUtils for BasketManagerStorage;
    using SafeERC20 for IERC20;

    /// CONSTANTS ///
    /// @notice Manager role. Managers can create new baskets.
    bytes32 private constant _MANAGER_ROLE = keccak256("MANAGER_ROLE");
    /// @notice Pauser role.
    bytes32 private constant _PAUSER_ROLE = keccak256("PAUSER_ROLE");
    /// @notice Rebalance Proposer role. Rebalance proposers can propose a new rebalance.
    bytes32 private constant _REBALANCE_PROPOSER_ROLE = keccak256("REBALANCE_PROPOSER_ROLE");
    /// @notice TokenSwap Proposer role. Token swap proposers can propose a new token swap.
    bytes32 private constant _TOKENSWAP_PROPOSER_ROLE = keccak256("TOKENSWAP_PROPOSER_ROLE");
    /// @notice TokenSwap Executor role. Token swap executors can execute a token swap.
    bytes32 private constant _TOKENSWAP_EXECUTOR_ROLE = keccak256("TOKENSWAP_EXECUTOR_ROLE");
    /// @notice Basket token role. Given to the basket token contracts when they are created.
    bytes32 private constant _BASKET_TOKEN_ROLE = keccak256("BASKET_TOKEN_ROLE");
    /// @notice Role given to a timelock contract that can set critical parameters.
    bytes32 private constant _TIMELOCK_ROLE = keccak256("TIMELOCK_ROLE");
    /// @notice Maximum management fee (30%) in BPS denominated in 1e4.
    uint16 private constant _MAX_MANAGEMENT_FEE = 3000;
    /// @notice Maximum swap fee (5%) in BPS denominated in 1e4.
    uint16 private constant _MAX_SWAP_FEE = 500;
    /// @notice Minimum time between steps in a rebalance in seconds.
    uint40 private constant _MIN_STEP_DELAY = 1 minutes;
    /// @notice Maximum time between steps in a rebalance in seconds.
    uint40 private constant _MAX_STEP_DELAY = 60 minutes;
    /// @notice Maximum bound of retry count.
    uint8 private constant _MAX_RETRY_COUNT = 10;
    /// @notice Maximum bound of slippage
    uint256 private constant _MAX_SLIPPAGE_LIMIT = 0.5e18;
    /// @notice Maximum bound of weight deviation
    uint256 private constant _MAX_WEIGHT_DEVIATION_LIMIT = 0.5e18;

    /// STATE VARIABLES ///
    /// @notice Struct containing the BasketManagerUtils contract and other necessary data.
    BasketManagerStorage private _bmStorage;

    /// EVENTS ///
    /// @notice Emitted when the swap fee is set.
    event SwapFeeSet(uint16 oldFee, uint16 newFee);
    /// @notice Emitted when the management fee is set.
    event ManagementFeeSet(address indexed basket, uint16 oldFee, uint16 newFee);
    /// @notice Emitted when the TokenSwapAdapter contract is set.
    event TokenSwapAdapterSet(address oldAdapter, address newAdapter);
    /// @notice Emitted when a new basket is created.
    event BasketCreated(
        address indexed basket, string basketName, string symbol, address baseAsset, uint256 bitFlag, address strategy
    );
    /// @notice Emitted when the bitFlag of a basket is updated.
    event BasketBitFlagUpdated(
        address indexed basket, uint256 oldBitFlag, uint256 newBitFlag, bytes32 oldId, bytes32 newId
    );
    /// @notice Emitted when a token swap is proposed during a rebalance.
    event TokenSwapProposed(uint40 indexed epoch, InternalTrade[] internalTrades, ExternalTrade[] externalTrades);
    /// @notice Emitted when a token swap is executed during a rebalance.
    event TokenSwapExecuted(uint40 indexed epoch, ExternalTrade[] externalTrades);
    /// @notice Emitted when the step delay is set.
    event StepDelaySet(uint40 oldDelay, uint40 newDelay);
    /// @notice Emitted when the retry limit is set.
    event RetryLimitSet(uint8 oldLimit, uint8 newLimit);
    /// @notice Emitted when the max slippage is set.
    event SlippageLimitSet(uint256 oldSlippage, uint256 newSlippage);
    /// @notice Emitted when the max weight deviation is set
    event WeightDeviationLimitSet(uint256 oldDeviation, uint256 newDeviation);

    /// ERRORS ///
    /// @notice Thrown when the address is zero.
    error ZeroAddress();
    /// @notice Thrown when attempting to execute a token swap without first proposing it.
    error TokenSwapNotProposed();
    /// @notice Thrown when the call to `TokenSwapAdapter.executeTokenSwap` fails.
    error ExecuteTokenSwapFailed();
    /// @notice Thrown when the provided hash does not match the expected hash.
    /// @dev This error is used to validate the integrity of data passed between functions.
    error InvalidHash();
    /// @notice Thrown when the provided external trades do not match the hash stored during the token swap proposal.
    /// @dev This error prevents executing a token swap with different parameters than originally proposed.
    error ExternalTradesHashMismatch();
    /// @notice Thrown when attempting to perform an action that requires no active rebalance.
    /// @dev Certain actions, like setting the token swap adapter, are disallowed during an active rebalance.
    error MustWaitForRebalanceToComplete();
    /// @notice Thrown when a caller attempts to access a function without proper authorization.
    /// @dev This error is thrown when a caller lacks the required role to perform an action.
    error Unauthorized();
    /// @notice Thrown when attempting to set an invalid management fee.
    /// @dev The management fee must not exceed `_MAX_MANAGEMENT_FEE`.
    error InvalidManagementFee();
    /// @notice Thrown when attempting to set an invalid swap fee.
    /// @dev The swap fee must not exceed `_MAX_SWAP_FEE`.
    error InvalidSwapFee();
    /// @notice Thrown when attempting to perform an action on a non-existent basket token.
    /// @dev This error is thrown when the provided basket token is not in the `basketTokenToIndexPlusOne` mapping.
    error BasketTokenNotFound();
    /// @notice Thrown when attempting to update the bitFlag to the same value.
    error BitFlagMustBeDifferent();
    /// @notice Thrown when attempting to update the bitFlag without including the current bitFlag.
    error BitFlagMustIncludeCurrent();
    /// @notice Thrown when attempting to update the bitFlag to a value not supported by the strategy.
    error BitFlagUnsupportedByStrategy();
    /// @notice Thrown when attempting to create a basket with an ID that already exists.
    error BasketIdAlreadyExists();
    /// @notice Thrown when attempting to rescue an asset to a basket that already exists in the asset universe.
    error AssetExistsInUniverse();
    /// @notice Thrown when the low-level call in the `execute` function fails.
    /// @dev This error indicates that the target contract rejected the call or execution failed unexpectedly.
    error ExecutionFailed();
    /// @notice Thrown when attempting to set an invalid step delay outside the bounds of `_MIN_STEP_DELAY` and
    /// `_MAX_STEP_DELAY`.
    error InvalidStepDelay();
    /// @notice Thrown when attempting to set an invalid retry limit outside the bounds of 0 and `_MAX_RETRY_COUNT`.
    error InvalidRetryCount();
    /// @notice Thrown when attempting to set a slippage limit greater than `_MAX_SLIPPAGE_LIMIT`.
    error InvalidSlippageLimit();
    /// @notice Thrown when attempting to set a weight deviation greater than `_MAX_WEIGHT_DEVIATION_LIMIT`.
    error InvalidWeightDeviationLimit();
    /// @notice Thrown when attempting to execute a token swap with empty external trades array
    error EmptyExternalTrades();

    /// @notice Initializes the contract with the given parameters.
    /// @param basketTokenImplementation Address of the basket token implementation.
    /// @param eulerRouter_ Address of the oracle registry.
    /// @param strategyRegistry_ Address of the strategy registry.
    /// @param assetRegistry_ Address of the asset registry.
    /// @param admin Address of the admin.
    /// @param feeCollector_ Address of the fee collector.
    constructor(
        address basketTokenImplementation,
        address eulerRouter_,
        address strategyRegistry_,
        address assetRegistry_,
        address admin,
        address feeCollector_
    )
        payable
    {
        // Checks
        if (basketTokenImplementation == address(0)) revert ZeroAddress();
        if (eulerRouter_ == address(0)) revert ZeroAddress();
        if (strategyRegistry_ == address(0)) revert ZeroAddress();
        if (admin == address(0)) revert ZeroAddress();
        if (feeCollector_ == address(0)) revert ZeroAddress();
        if (assetRegistry_ == address(0)) revert ZeroAddress();

        // Effects
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        // Initialize the BasketManagerUtils struct
        _bmStorage.strategyRegistry = StrategyRegistry(strategyRegistry_);
        _bmStorage.eulerRouter = EulerRouter(eulerRouter_);
        _bmStorage.assetRegistry = assetRegistry_;
        _bmStorage.basketTokenImplementation = basketTokenImplementation;
        _bmStorage.feeCollector = feeCollector_;
        _bmStorage.retryLimit = 3;
        _bmStorage.stepDelay = 15 minutes;
        _bmStorage.slippageLimit = 0.05e18;
        _bmStorage.weightDeviationLimit = 0.05e18;
    }

    /// PUBLIC FUNCTIONS ///

    /// @notice Returns the index of the basket token in the basketTokens array.
    /// @dev Reverts if the basket token does not exist.
    /// @param basketToken Address of the basket token.
    /// @return Index of the basket token.
    function basketTokenToIndex(address basketToken) public view returns (uint256) {
        return _bmStorage.basketTokenToIndex(basketToken);
    }

    /// @notice Returns the index of the given asset in the basket.
    /// @dev Reverts if the basket asset does not exist.
    /// @param basketToken Address of the basket token.
    /// @param asset Address of the asset.
    /// @return Index of the asset in the basket.
    function getAssetIndexInBasket(address basketToken, address asset) public view returns (uint256) {
        return _bmStorage.getAssetIndexInBasket(basketToken, asset);
    }

    /// @notice Returns the index of the base asset in the given basket token
    /// @dev Reverts if the basket token does not exist
    /// @param basketToken Address of the basket token
    /// @return Index of the base asset in the basket token's assets array
    function basketTokenToBaseAssetIndex(address basketToken) public view returns (uint256) {
        uint256 index = _bmStorage.basketTokenToBaseAssetIndexPlusOne[basketToken];
        if (index == 0) {
            revert BasketTokenNotFound();
        }
        return index - 1;
    }

    /// @notice Returns the number of basket tokens.
    /// @return Number of basket tokens.
    function numOfBasketTokens() public view returns (uint256) {
        return _bmStorage.basketTokens.length;
    }

    /// @notice Returns all basket token addresses.
    /// @return Array of basket token addresses.
    function basketTokens() external view returns (address[] memory) {
        return _bmStorage.basketTokens;
    }

    /// @notice Returns the basket token address with the given basketId.
    /// @dev The basketId is the keccak256 hash of the bitFlag and strategy address.
    /// @param basketId Basket ID.
    function basketIdToAddress(bytes32 basketId) external view returns (address) {
        return _bmStorage.basketIdToAddress[basketId];
    }

    /// @notice Returns the balance of the given asset in the given basket.
    /// @param basketToken Address of the basket token.
    /// @param asset Address of the asset.
    /// @return Balance of the asset in the basket.
    function basketBalanceOf(address basketToken, address asset) external view returns (uint256) {
        return _bmStorage.basketBalanceOf[basketToken][asset];
    }

    /// @notice Returns the current rebalance status.
    /// @return Rebalance status struct with the following fields:
    ///   - basketHash: Hash of the baskets and target weights proposed for rebalance
    ///   - basketMask: Bitmask representing baskets currently being rebalanced
    ///   - epoch: Epoch of the rebalance
    ///   - timestamp: Timestamp of the last action
    ///   - retryCount: Number of retries for the current rebalance epoch
    ///   - status: Status enum of the rebalance
    function rebalanceStatus() external view returns (RebalanceStatus memory) {
        return _bmStorage.rebalanceStatus;
    }

    /// @notice Returns the hash of the external trades stored during proposeTokenSwap
    /// @return Hash of the external trades
    function externalTradesHash() external view returns (bytes32) {
        return _bmStorage.externalTradesHash;
    }

    /// @notice Returns the address of the basket token implementation.
    /// @return Address of the basket token implementation.
    function eulerRouter() external view returns (address) {
        return address(_bmStorage.eulerRouter);
    }

    /// @notice Returns the address of the feeCollector contract.
    /// @return Address of the feeCollector.
    function feeCollector() external view returns (address) {
        return address(_bmStorage.feeCollector);
    }

    /// @notice Returns the management fee of a basket in BPS denominated in 1e4.
    /// @param basket Address of the basket.
    /// @return Management fee.
    function managementFee(address basket) external view returns (uint16) {
        return _bmStorage.managementFees[basket];
    }

    /// @notice Returns the swap fee in BPS denominated in 1e4.
    /// @return Swap fee.
    function swapFee() external view returns (uint16) {
        return _bmStorage.swapFee;
    }

    /// @notice Returns the slippage limit for token swaps denominated in 1e18.
    /// @return Maximum slippage.
    function slippageLimit() external view returns (uint256) {
        return _bmStorage.slippageLimit;
    }

    /// @notice Returns the weight deviation limit for token swaps denominated in 1e18.
    /// @return Maximum weight deviation.
    function weightDeviationLimit() external view returns (uint256) {
        return _bmStorage.weightDeviationLimit;
    }

    /// @notice Returns the address of the asset registry.
    /// @return Address of the asset registry.
    function assetRegistry() external view returns (address) {
        return _bmStorage.assetRegistry;
    }

    /// @notice Returns the address of the strategy registry.
    /// @return Address of the strategy registry.
    function strategyRegistry() external view returns (address) {
        return address(_bmStorage.strategyRegistry);
    }

    /// @notice Returns the address of the token swap adapter.
    /// @return Address of the token swap adapter.
    function tokenSwapAdapter() external view returns (address) {
        return _bmStorage.tokenSwapAdapter;
    }

    /// @notice Returns the retry count for the current rebalance epoch.
    /// @return Retry count.
    function retryCount() external view returns (uint8) {
        return _bmStorage.rebalanceStatus.retryCount;
    }

    /// @notice Returns the maximum retry limit for the rebalance process.
    /// @return Retry limit.
    function retryLimit() external view returns (uint8) {
        return _bmStorage.retryLimit;
    }

    /// @notice Returns the step delay for the rebalance process.
    /// @dev The step delay defines the minimum time interval, in seconds, required between consecutive steps in a
    /// rebalance. This ensures sufficient time for external trades or other operations to settle before proceeding.
    /// @return Step delay duration in seconds.
    function stepDelay() external view returns (uint40) {
        return _bmStorage.stepDelay;
    }

    /// @notice Returns the addresses of all assets in the given basket.
    /// @param basket Address of the basket.
    /// @return Array of asset addresses.
    function basketAssets(address basket) external view returns (address[] memory) {
        return _bmStorage.basketAssets[basket];
    }

    /// @notice Returns the collected swap fees for the given asset.
    /// @param asset Address of the asset.
    /// @return Collected swap fees.
    function collectedSwapFees(address asset) external view returns (uint256) {
        return _bmStorage.collectedSwapFees[asset];
    }

    /// @notice Creates a new basket token with the given parameters.
    /// @param basketName Name of the basket.
    /// @param symbol Symbol of the basket.
    /// @param bitFlag Asset selection bitFlag for the basket.
    /// @param strategy Address of the strategy contract for the basket.
    function createNewBasket(
        string calldata basketName,
        string calldata symbol,
        address baseAsset,
        uint256 bitFlag,
        address strategy
    )
        external
        payable
        whenNotPaused
        onlyRole(_MANAGER_ROLE)
        returns (address basket)
    {
        basket = _bmStorage.createNewBasket(basketName, symbol, baseAsset, bitFlag, strategy);
        _grantRole(_BASKET_TOKEN_ROLE, basket);
        emit BasketCreated(basket, basketName, symbol, baseAsset, bitFlag, strategy);
    }

    /// @notice Proposes a rebalance for the given baskets. The rebalance is proposed if the difference between the
    /// target balance and the current balance of any asset in the basket is more than 500 USD.
    /// @param basketsToRebalance Array of basket addresses to rebalance.
    function proposeRebalance(address[] calldata basketsToRebalance)
        external
        onlyRole(_REBALANCE_PROPOSER_ROLE)
        nonReentrant
        whenNotPaused
    {
        _bmStorage.proposeRebalance(basketsToRebalance);
    }

    /// @notice Proposes a set of internal trades and external trades to rebalance the given baskets.
    /// If the proposed token swap results are not close to the target balances, this function will revert.
    /// @dev This function can only be called after proposeRebalance.
    /// @param internalTrades Array of internal trades to execute.
    /// @param externalTrades Array of external trades to execute.
    /// @param basketsToRebalance Array of basket addresses currently being rebalanced.
    /// @param targetWeights Array of target weights for the baskets.
    function proposeTokenSwap(
        InternalTrade[] calldata internalTrades,
        ExternalTrade[] calldata externalTrades,
        address[] calldata basketsToRebalance,
        uint64[][] calldata targetWeights,
        address[][] calldata basketAssets_
    )
        external
        onlyRole(_TOKENSWAP_PROPOSER_ROLE)
        nonReentrant
        whenNotPaused
    {
        _bmStorage.proposeTokenSwap(internalTrades, externalTrades, basketsToRebalance, targetWeights, basketAssets_);
        emit TokenSwapProposed(_bmStorage.rebalanceStatus.epoch, internalTrades, externalTrades);
    }

    /// @notice Executes the token swaps proposed in proposeTokenSwap and updates the basket balances.
    /// @param externalTrades Array of external trades to execute.
    /// @param data Encoded data for the token swap.
    /// @dev This function can only be called after proposeTokenSwap.
    // slither-disable-next-line controlled-delegatecall
    function executeTokenSwap(
        ExternalTrade[] calldata externalTrades,
        bytes calldata data
    )
        external
        onlyRole(_TOKENSWAP_EXECUTOR_ROLE)
        nonReentrant
        whenNotPaused
    {
        if (_bmStorage.rebalanceStatus.status != Status.TOKEN_SWAP_PROPOSED) {
            revert TokenSwapNotProposed();
        }
        address swapAdapter = _bmStorage.tokenSwapAdapter;
        if (swapAdapter == address(0)) {
            revert ZeroAddress();
        }
        if (externalTrades.length == 0) {
            revert EmptyExternalTrades();
        }
        // Check if the external trades match the hash from proposeTokenSwap
        if (keccak256(abi.encode(externalTrades)) != _bmStorage.externalTradesHash) {
            revert ExternalTradesHashMismatch();
        }
        _bmStorage.rebalanceStatus.status = Status.TOKEN_SWAP_EXECUTED;
        _bmStorage.rebalanceStatus.timestamp = uint40(block.timestamp);

        // solhint-disable avoid-low-level-calls
        // slither-disable-next-line low-level-calls
        (bool success,) =
            swapAdapter.delegatecall(abi.encodeCall(TokenSwapAdapter.executeTokenSwap, (externalTrades, data)));
        // solhint-enable avoid-low-level-calls
        if (!success) {
            revert ExecuteTokenSwapFailed();
        }

        emit TokenSwapExecuted(_bmStorage.rebalanceStatus.epoch, externalTrades);
    }

    /// @notice Sets the address of the TokenSwapAdapter contract used to execute token swaps.
    /// @param tokenSwapAdapter_ Address of the TokenSwapAdapter contract.
    /// @dev Only callable by the timelock.
    function setTokenSwapAdapter(address tokenSwapAdapter_) external onlyRole(_TIMELOCK_ROLE) {
        if (tokenSwapAdapter_ == address(0)) {
            revert ZeroAddress();
        }
        _revertIfCurrentlyRebalancing();
        emit TokenSwapAdapterSet(_bmStorage.tokenSwapAdapter, tokenSwapAdapter_);
        _bmStorage.tokenSwapAdapter = tokenSwapAdapter_;
    }

    /// @notice Completes the rebalance for the given baskets. The rebalance can be completed if it has been more than
    /// 15 minutes since the last action.
    /// @param basketsToRebalance Array of basket addresses proposed for rebalance.
    /// @param targetWeights Array of target weights for the baskets.
    function completeRebalance(
        ExternalTrade[] calldata externalTrades,
        address[] calldata basketsToRebalance,
        uint64[][] calldata targetWeights,
        address[][] calldata basketAssets_
    )
        external
        nonReentrant
        whenNotPaused
    {
        _bmStorage.completeRebalance(externalTrades, basketsToRebalance, targetWeights, basketAssets_);
    }

    /// FALLBACK REDEEM LOGIC ///

    /// @notice Fallback redeem function to redeem shares when the rebalance is not in progress. Redeems the shares for
    /// each underlying asset in the basket pro-rata to the amount of shares redeemed.
    /// @param totalSupplyBefore Total supply of the basket token before the shares were burned.
    /// @param burnedShares Amount of shares burned.
    /// @param to Address to send the redeemed assets to.
    function proRataRedeem(
        uint256 totalSupplyBefore,
        uint256 burnedShares,
        address to
    )
        public
        nonReentrant
        whenNotPaused
        onlyRole(_BASKET_TOKEN_ROLE)
    {
        _bmStorage.proRataRedeem(totalSupplyBefore, burnedShares, to);
    }

    /// FEE FUNCTIONS ///

    /// @notice Set the management fee to be given to the treausry on rebalance.
    /// @param basket Address of the basket token.
    /// @param managementFee_ Management fee in BPS denominated in 1e4.
    /// @dev Only callable by the timelock.
    /// @dev Setting the management fee of the 0 address will set the default management fee for newly created baskets.
    function setManagementFee(address basket, uint16 managementFee_) external onlyRole(_TIMELOCK_ROLE) {
        if (managementFee_ > _MAX_MANAGEMENT_FEE) {
            revert InvalidManagementFee();
        }

        // Check if the basket is currently rebalancing
        if (basket != address(0)) {
            uint256 indexPlusOne = _bmStorage.basketTokenToIndexPlusOne[basket];
            if (indexPlusOne == 0) {
                revert BasketTokenNotFound();
            }
            if ((_bmStorage.rebalanceStatus.basketMask & (1 << indexPlusOne - 1)) != 0) {
                revert MustWaitForRebalanceToComplete();
            }
        }
        emit ManagementFeeSet(basket, _bmStorage.managementFees[basket], managementFee_);
        _bmStorage.managementFees[basket] = managementFee_;
    }

    /// @notice Set the swap fee to be given to the treasury on rebalance.
    /// @param swapFee_ Swap fee in BPS denominated in 1e4.
    /// @dev Only callable by the timelock.
    function setSwapFee(uint16 swapFee_) external onlyRole(_TIMELOCK_ROLE) {
        if (swapFee_ > _MAX_SWAP_FEE) {
            revert InvalidSwapFee();
        }
        _revertIfCurrentlyRebalancing();
        emit SwapFeeSet(_bmStorage.swapFee, swapFee_);
        _bmStorage.swapFee = swapFee_;
    }

    /// @notice Updates the step delay for the rebalance process.
    /// @dev The step delay defines the minimum time interval, in seconds, required between consecutive steps in a
    /// rebalance. This ensures sufficient time for external trades or other operations to settle before proceeding.
    /// @param stepDelay_ The new step delay duration in seconds.
    function setStepDelay(uint40 stepDelay_) external onlyRole(_TIMELOCK_ROLE) {
        if (stepDelay_ < _MIN_STEP_DELAY || stepDelay_ > _MAX_STEP_DELAY) {
            revert InvalidStepDelay();
        }
        _revertIfCurrentlyRebalancing();
        emit StepDelaySet(_bmStorage.stepDelay, stepDelay_);
        _bmStorage.stepDelay = stepDelay_;
    }

    /// @notice Sets the retry limit for future rebalances.
    /// @param retryLimit_ New retry limit.
    function setRetryLimit(uint8 retryLimit_) external onlyRole(_TIMELOCK_ROLE) {
        if (retryLimit_ > _MAX_RETRY_COUNT) {
            revert InvalidRetryCount();
        }
        _revertIfCurrentlyRebalancing();
        emit RetryLimitSet(_bmStorage.retryLimit, retryLimit_);
        _bmStorage.retryLimit = retryLimit_;
    }

    /// @notice Sets the slippage multiplier for token swaps.
    /// @param slippageLimit_ New slippage limit.
    function setSlippageLimit(uint256 slippageLimit_) external onlyRole(_TIMELOCK_ROLE) {
        if (slippageLimit_ > _MAX_SLIPPAGE_LIMIT) {
            revert InvalidSlippageLimit();
        }
        _revertIfCurrentlyRebalancing();
        emit SlippageLimitSet(_bmStorage.slippageLimit, slippageLimit_);
        _bmStorage.slippageLimit = slippageLimit_;
    }

    /// @notice Sets the deviation multiplier to determine if a set of balances has reached the desired target.
    /// @param weightDeviationLimit_ New weight deviation limit.
    function setWeightDeviation(uint256 weightDeviationLimit_) external onlyRole(_TIMELOCK_ROLE) {
        if (weightDeviationLimit_ > _MAX_WEIGHT_DEVIATION_LIMIT) {
            revert InvalidWeightDeviationLimit();
        }
        _revertIfCurrentlyRebalancing();
        emit WeightDeviationLimitSet(_bmStorage.weightDeviationLimit, weightDeviationLimit_);
        _bmStorage.weightDeviationLimit = weightDeviationLimit_;
    }

    /// @notice Claims the swap fee for the given asset and sends it to protocol treasury defined in the FeeCollector.
    /// @param asset Address of the asset to collect the swap fee for.
    function collectSwapFee(address asset) external onlyRole(_MANAGER_ROLE) returns (uint256 collectedFees) {
        collectedFees = _bmStorage.collectedSwapFees[asset];
        if (collectedFees != 0) {
            _bmStorage.collectedSwapFees[asset] = 0;
            IERC20(asset).safeTransfer(FeeCollector(_bmStorage.feeCollector).protocolTreasury(), collectedFees);
        }
    }

    /// @notice Updates the bitFlag for the given basket.
    /// @param basket Address of the basket.
    /// @param bitFlag New bitFlag. It must be inclusive of the current bitFlag.
    function updateBitFlag(address basket, uint256 bitFlag) external onlyRole(_TIMELOCK_ROLE) {
        // Checks
        // Check if basket exists
        uint256 indexPlusOne = _bmStorage.basketTokenToIndexPlusOne[basket];
        if (indexPlusOne == 0) {
            revert BasketTokenNotFound();
        }
        uint256 currentBitFlag = BasketToken(basket).bitFlag();
        if (currentBitFlag == bitFlag) {
            revert BitFlagMustBeDifferent();
        }
        // Check if basket is currently rebalancing
        if ((_bmStorage.rebalanceStatus.basketMask & (1 << indexPlusOne - 1)) != 0) {
            revert MustWaitForRebalanceToComplete();
        }
        // Check if the new bitFlag is inclusive of the current bitFlag
        if ((currentBitFlag & bitFlag) != currentBitFlag) {
            revert BitFlagMustIncludeCurrent();
        }
        address strategy = BasketToken(basket).strategy();
        if (!WeightStrategy(strategy).supportsBitFlag(bitFlag)) {
            revert BitFlagUnsupportedByStrategy();
        }
        bytes32 newId = keccak256(abi.encodePacked(bitFlag, strategy));
        if (_bmStorage.basketIdToAddress[newId] != address(0)) {
            revert BasketIdAlreadyExists();
        }
        // Remove the old bitFlag mapping and add the new bitFlag mapping
        bytes32 oldId = keccak256(abi.encodePacked(currentBitFlag, strategy));
        _bmStorage.basketIdToAddress[oldId] = address(0);
        _bmStorage.basketIdToAddress[newId] = basket;
        // Update the basketAssets and the basketAssetToIndexPlusOne mapping
        address[] memory assets = AssetRegistry(_bmStorage.assetRegistry).getAssets(bitFlag);
        address baseAsset = _bmStorage.basketAssets[basket][_bmStorage.basketTokenToBaseAssetIndexPlusOne[basket] - 1];
        _bmStorage.basketAssets[basket] = assets;
        uint256 length = assets.length;
        for (uint256 i = 0; i < length;) {
            // nosemgrep: solidity.performance.state-variable-read-in-a-loop.state-variable-read-in-a-loop
            _bmStorage.basketAssetToIndexPlusOne[basket][assets[i]] = i + 1;
            // Update the base asset index
            if (assets[i] == baseAsset) {
                // nosemgrep: solidity.performance.state-variable-read-in-a-loop.state-variable-read-in-a-loop
                _bmStorage.basketTokenToBaseAssetIndexPlusOne[basket] = i + 1;
            }
            unchecked {
                // Overflow not possible: i is less than length
                ++i;
            }
        }
        emit BasketBitFlagUpdated(basket, currentBitFlag, bitFlag, oldId, newId);
        // Update the bitFlag in the BasketToken contract
        BasketToken(basket).setBitFlag(bitFlag);
    }

    /// @notice Reverts if a rebalance is currently in progress.
    function _revertIfCurrentlyRebalancing() private view {
        if (_bmStorage.rebalanceStatus.status != Status.NOT_STARTED) {
            revert MustWaitForRebalanceToComplete();
        }
    }

    /// PAUSING FUNCTIONS ///

    /// @notice Pauses the contract. Callable by DEFAULT_ADMIN_ROLE or PAUSER_ROLE.
    function pause() external {
        if (!(hasRole(_PAUSER_ROLE, msg.sender) || hasRole(DEFAULT_ADMIN_ROLE, msg.sender))) {
            revert Unauthorized();
        }
        _pause();
    }

    /// @notice Unpauses the contract. Only callable by DEFAULT_ADMIN_ROLE.
    function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    /// @notice Allows the timelock to execute an arbitrary function call on a target contract.
    /// @dev Can only be called by addresses with the timelock role. Reverts if the execution fails. Reverts if the
    /// target of the call is an asset that is active in the asset registry.
    /// @param target The address of the target contract.
    /// @param data The calldata to send to the target contract.
    /// @param value The amount of Ether (in wei) to send with the call.
    /// @return result The data returned from the function call.
    function execute(
        address target,
        bytes calldata data,
        uint256 value
    )
        external
        payable
        onlyRole(_TIMELOCK_ROLE)
        returns (bytes memory)
    {
        // Checks
        if (target == address(0)) revert ZeroAddress();
        AssetRegistry.AssetStatus status = AssetRegistry(_bmStorage.assetRegistry).getAssetStatus(address(target));
        if (status != AssetRegistry.AssetStatus.DISABLED) {
            revert AssetExistsInUniverse();
        }

        // Interactions
        // slither-disable-start arbitrary-send-eth
        // slither-disable-start low-level-calls
        // nosemgrep: solidity.security.arbitrary-low-level-call.arbitrary-low-level-call
        (bool success, bytes memory result) = target.call{ value: value }(data);
        // slither-disable-end arbitrary-send-eth
        // slither-disable-end low-level-calls
        if (!success) {
            revert ExecutionFailed();
        }
        return result;
    }

    /// @notice Allows the admin to rescue tokens mistakenly sent to the contract.
    /// @dev Can only be called by the admin. This function is intended for use in case of accidental token
    /// transfers into the contract. It will revert if the token is part of the enabled asset universe.
    /// @param token The ERC20 token to rescue, or address(0) for ETH.
    /// @param to The recipient address of the rescued tokens.
    /// @param balance The amount of tokens to rescue. If set to 0, the entire balance will be rescued.
    function rescue(IERC20 token, address to, uint256 balance) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (address(token) != address(0)) {
            AssetRegistry.AssetStatus status = AssetRegistry(_bmStorage.assetRegistry).getAssetStatus(address(token));
            if (status != AssetRegistry.AssetStatus.DISABLED) {
                revert AssetExistsInUniverse();
            }
        }

        _rescue(token, to, balance);
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import { ERC20Upgradeable } from "@openzeppelin-upgradeable/contracts/token/ERC20/ERC20Upgradeable.sol";
import { ERC20PermitUpgradeable } from
    "@openzeppelin-upgradeable/contracts/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import { ERC4626Upgradeable } from "@openzeppelin-upgradeable/contracts/token/ERC20/extensions/ERC4626Upgradeable.sol";
import { MulticallUpgradeable } from "@openzeppelin-upgradeable/contracts/utils/MulticallUpgradeable.sol";
import { ERC165Upgradeable } from "@openzeppelin-upgradeable/contracts/utils/introspection/ERC165Upgradeable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { FixedPointMathLib } from "@solady/utils/FixedPointMathLib.sol";
import { EulerRouter } from "euler-price-oracle/src/EulerRouter.sol";
import { ERC20PluginsUpgradeable } from "token-plugins-upgradeable/contracts/ERC20PluginsUpgradeable.sol";

import { AssetRegistry } from "src/AssetRegistry.sol";
import { BasketManager } from "src/BasketManager.sol";
import { FeeCollector } from "src/FeeCollector.sol";
import { Permit2Lib } from "src/deps/permit2/Permit2Lib.sol";
import { IERC7540Deposit, IERC7540Operator, IERC7540Redeem } from "src/interfaces/IERC7540.sol";
import { WeightStrategy } from "src/strategies/WeightStrategy.sol";

/// @title BasketToken
/// @notice Manages user deposits and redemptions, which are processed asynchronously by the Basket Manager.
/// @dev Considerations for Integrators:
///
/// When users call `requestDeposit` or `requestRedeem`, the system ensures that the controller does not have any
/// pending or claimable deposits or redeems from the controller's `lastDepositRequestId`.
///
/// This behavior allows for a potential griefing attack: an attacker can call `requestDeposit` or `requestRedeem` with
/// a minimal dust amount and specify the target controller address. As a result, the target controller would then be
/// unable to make legitimate `requestDeposit` or `requestRedeem` requests until they first claim the pending request.
///
/// RECOMMENDATION FOR INTEGRATORS: When integrating `BasketToken` into other contracts, always check for any pending or
/// claimable tokens before requesting a deposit or redeem. This ensures that any pending deposits or redeems are
/// resolved, preventing such griefing attacks.
// slither-disable-next-line missing-inheritance
contract BasketToken is
    ERC20PluginsUpgradeable,
    ERC4626Upgradeable,
    ERC165Upgradeable,
    IERC7540Operator,
    IERC7540Deposit,
    IERC7540Redeem,
    MulticallUpgradeable,
    ERC20PermitUpgradeable
{
    /// LIBRARIES ///
    using SafeERC20 for IERC20;

    /// CONSTANTS ///
    /// @notice ISO 4217 numeric code for USD, used as a constant address representation
    address private constant _USD_ISO_4217_CODE = address(840);
    uint16 private constant _MANAGEMENT_FEE_DECIMALS = 1e4;
    /// @notice Maximum management fee (30%) in BPS denominated in 1e4.
    uint16 private constant _MAX_MANAGEMENT_FEE = 3000;
    string private constant _NAME_PREFIX = "CoveBasket ";
    string private constant _SYMBOL_PREFIX = "cvt";

    /// @notice Struct representing a deposit request.
    struct DepositRequestStruct {
        // Mapping of controller addresses to their deposited asset amounts.
        mapping(address controller => uint256 assets) depositAssets;
        // Total amount of assets deposited in this request.
        uint256 totalDepositAssets;
        // Number of shares fulfilled for this deposit request.
        uint256 fulfilledShares;
        // Flag indicating if the fallback redemption process has been triggered.
        bool fallbackTriggered;
    }

    /// @notice Typed tuple for externally viewing DepositRequestStruct without the mapping.
    struct DepositRequestView {
        // Total amount of assets deposited in this request.
        uint256 totalDepositAssets;
        // Number of shares fulfilled for this deposit request.
        uint256 fulfilledShares;
        // Flag indicating if the fallback redemption process has been triggered.
        bool fallbackTriggered;
    }

    /// @notice Struct representing a redeem request.
    struct RedeemRequestStruct {
        // Mapping of controller addresses to their shares to be redeemed.
        mapping(address controller => uint256 shares) redeemShares;
        // Total number of shares to be redeemed in this request.
        uint256 totalRedeemShares;
        // Amount of assets fulfilled for this redeem request.
        uint256 fulfilledAssets;
        // Flag indicating if the fallback redemption process has been triggered.
        bool fallbackTriggered;
    }

    /// @notice Typed tuple for externally viewing RedeemRequestStruct without the mapping.
    struct RedeemRequestView {
        // Total number of shares to be redeemed in this request.
        uint256 totalRedeemShares;
        // Amount of assets fulfilled for this redeem request.
        uint256 fulfilledAssets;
        // Flag indicating if the fallback redemption process has been triggered.
        bool fallbackTriggered;
    }

    /// STATE VARIABLES ///
    /// @notice Operator approval status per controller.
    mapping(address controller => mapping(address operator => bool)) public isOperator;
    /// @notice Last deposit request ID per controller.
    mapping(address controller => uint256 requestId) public lastDepositRequestId;
    /// @notice Last redemption request ID per controller.
    mapping(address controller => uint256 requestId) public lastRedeemRequestId;
    /// @dev Deposit requests mapped by request ID. Even IDs are for deposits.
    mapping(uint256 requestId => DepositRequestStruct) internal _depositRequests;
    /// @dev Redemption requests mapped by request ID. Odd IDs are for redemptions.
    mapping(uint256 requestId => RedeemRequestStruct) internal _redeemRequests;
    /// @notice Address of the BasketManager contract handling deposits and redemptions.
    address public basketManager;
    /// @notice Upcoming deposit request ID.
    uint256 public nextDepositRequestId;
    /// @notice Upcoming redemption request ID.
    uint256 public nextRedeemRequestId;
    /// @notice Address of the AssetRegistry contract for asset status checks.
    address public assetRegistry;
    /// @notice Bitflag representing selected assets.
    uint256 public bitFlag;
    /// @notice Strategy contract address associated with this basket.
    address public strategy;
    /// @notice Timestamp of the last management fee harvest.
    uint40 public lastManagementFeeHarvestTimestamp;

    /// EVENTS ///
    /// @notice Emitted when the management fee is harvested.
    /// @param fee The amount of the management fee harvested.
    event ManagementFeeHarvested(uint256 fee);
    /// @notice Emitted when a deposit request is fulfilled and assets are transferred to the user.
    /// @param requestId The unique identifier of the deposit request.
    /// @param assets The amount of assets that were deposited.
    /// @param shares The number of shares minted for the deposit.
    event DepositFulfilled(uint256 indexed requestId, uint256 assets, uint256 shares);
    /// @notice Emitted when a redemption request is fulfilled and shares are burned.
    /// @param requestId The unique identifier of the redemption request.
    /// @param shares The number of shares redeemed.
    /// @param assets The amount of assets returned to the user.
    event RedeemFulfilled(uint256 indexed requestId, uint256 shares, uint256 assets);
    /// @notice Emitted when a deposit request is triggered in fallback mode.
    /// @param requestId The unique identifier of the deposit request.
    event DepositFallbackTriggered(uint256 indexed requestId);
    /// @notice Emitted when a redemption request is triggered in fallback mode.
    /// @param requestId The unique identifier of the redemption request.
    event RedeemFallbackTriggered(uint256 indexed requestId);
    /// @notice Emitted when the bitflag is updated to a new value.
    /// @param oldBitFlag The previous bitflag value.
    /// @param newBitFlag The new bitflag value.
    event BitFlagUpdated(uint256 oldBitFlag, uint256 newBitFlag);
    /// @notice Emitted when a deposit request is queued and awaiting fulfillment.
    /// @param depositRequestId The unique identifier of the deposit request.
    /// @param pendingDeposits The total amount of assets pending deposit.
    event DepositRequestQueued(uint256 depositRequestId, uint256 pendingDeposits);
    /// @notice Emitted when a redeem request is queued and awaiting fulfillment.
    /// @param redeemRequestId The unique identifier of the redeem request.
    /// @param pendingShares The total amount of shares pending redemption.
    event RedeemRequestQueued(uint256 redeemRequestId, uint256 pendingShares);

    /// ERRORS ///
    /// @notice Thrown when the asset address is zero.
    error ZeroAddress();
    /// @notice Thrown when the amount is zero.
    error ZeroAmount();
    /// @notice Thrown when there are no pending deposits to fulfill.
    error ZeroPendingDeposits();
    /// @notice Thrown when there are no pending redeems to fulfill.
    error ZeroPendingRedeems();
    /// @notice Thrown when attempting to request a deposit or redeem while one or more of the basket's assets are
    /// paused in the AssetRegistry.
    error AssetPaused();
    /// @notice Thrown when attempting to request a new deposit while the user has an outstanding claimable deposit from
    /// a previous request. The user must first claim the outstanding deposit.
    error MustClaimOutstandingDeposit();
    /// @notice Thrown when attempting to request a new redeem while the user has an outstanding claimable redeem from a
    /// previous request. The user must first claim the outstanding redeem.
    error MustClaimOutstandingRedeem();
    /// @notice Thrown when attempting to claim a partial amount of an outstanding deposit or redeem. The user must
    /// claim the full claimable amount.
    error MustClaimFullAmount();
    /// @notice Thrown when the basket manager attempts to fulfill a deposit request with zero shares.
    error CannotFulfillWithZeroShares();
    /// @notice Thrown when the basket manager attempts to fulfill a redeem request with zero assets.
    error CannotFulfillWithZeroAssets();
    /// @notice Thrown when attempting to claim fallback assets when none are available.
    error ZeroClaimableFallbackAssets();
    /// @notice Thrown when attempting to claim fallback shares when none are available.
    error ZeroClaimableFallbackShares();
    /// @notice Thrown when a non-authorized address attempts to request a deposit or redeem on behalf of another user
    /// who has not approved them as an operator.
    error NotAuthorizedOperator();
    /// @notice Thrown when an address other than the basket manager attempts to call a basket manager only function.
    error NotBasketManager();
    /// @notice Thrown when an address other than the feeCollector attempts to harvest management fees.
    error NotFeeCollector();
    /// @notice Thrown when attempting to set an invalid management fee percentage greater than the maximum allowed.
    error InvalidManagementFee();
    /// @notice Thrown when the basket manager attempts to fulfill a deposit request that has already been fulfilled.
    error DepositRequestAlreadyFulfilled();
    /// @notice Thrown when the basket manager attempts to fulfill a redeem request that has already been fulfilled.
    error RedeemRequestAlreadyFulfilled();
    /// @notice Thrown when attempting to prepare for a new rebalance before the previous epoch's deposit request has
    /// been fulfilled.
    error PreviousDepositRequestNotFulfilled();
    /// @notice Thrown when attempting to prepare for a new rebalance before the previous epoch's redeem request has
    /// been fulfilled or put in fallback state.
    error PreviousRedeemRequestNotFulfilled();

    /// @notice Disables initializer functions.
    constructor() payable {
        _disableInitializers();
    }

    /// @notice Initializes the contract.
    /// @param asset_ Address of the underlying asset.
    /// @param name_ Name of the token, prefixed with "CoveBasket-".
    /// @param symbol_ Symbol of the token, prefixed with "cb".
    /// @param bitFlag_ Bitflag representing selected assets.
    /// @param strategy_ Strategy contract address.
    function initialize(
        IERC20 asset_,
        string memory name_,
        string memory symbol_,
        uint256 bitFlag_,
        address strategy_,
        address assetRegistry_
    )
        public
        initializer
    {
        if (strategy_ == address(0) || assetRegistry_ == address(0)) {
            revert ZeroAddress();
        }
        basketManager = msg.sender;
        bitFlag = bitFlag_;
        strategy = strategy_;
        assetRegistry = assetRegistry_;
        nextDepositRequestId = 2;
        nextRedeemRequestId = 3;
        __ERC4626_init(asset_);
        string memory tokenName = string.concat(_NAME_PREFIX, name_);
        __ERC20_init(tokenName, string.concat(_SYMBOL_PREFIX, symbol_));
        __ERC20Permit_init(tokenName);
        __ERC20Plugins_init(8, 2_000_000);
    }

    /// @notice Returns the value of the basket in assets. This will be an estimate as it does not account for other
    /// factors that may affect the swap rates.
    /// @return The total value of the basket in assets.
    function totalAssets() public view override returns (uint256) {
        address[] memory assets = getAssets();
        uint256 usdAmount = 0;
        uint256 assetsLength = assets.length;

        BasketManager bm = BasketManager(basketManager);
        EulerRouter eulerRouter = EulerRouter(bm.eulerRouter());
        address baseAsset = asset();

        for (uint256 i = 0; i < assetsLength;) {
            if (assets[i] != baseAsset) {
                // slither-disable-start calls-loop
                uint256 assetBalance = bm.basketBalanceOf(address(this), assets[i]);
                if (assetBalance > 0) {
                    // Rounding direction: down
                    usdAmount += eulerRouter.getQuote(assetBalance, assets[i], _USD_ISO_4217_CODE);
                }
                // slither-disable-end calls-loop
            }

            unchecked {
                // Overflow not possible: i is less than assetsLength
                ++i;
            }
        }
        uint256 totalBaseAssetBalance = bm.basketBalanceOf(address(this), baseAsset);
        if (usdAmount > 0) {
            totalBaseAssetBalance += eulerRouter.getQuote(usdAmount, _USD_ISO_4217_CODE, baseAsset);
        }
        return totalBaseAssetBalance;
    }

    /// @notice Returns the target weights for the given epoch.
    /// @return The target weights for the basket.
    function getTargetWeights() public view returns (uint64[] memory) {
        return WeightStrategy(strategy).getTargetWeights(bitFlag);
    }

    /// @notice Returns all assets that are eligible to be included in this basket based on the bitFlag
    /// @dev This returns the complete list of eligible assets from the AssetRegistry, filtered by this basket's
    /// bitFlag.
    ///      The list includes all assets that could potentially be part of the basket, regardless of:
    ///      - Their current balance in the basket
    ///      - Their current target weight
    ///      - Whether they are paused
    /// @return Array of asset token addresses that are eligible for this basket
    function getAssets() public view returns (address[] memory) {
        return AssetRegistry(assetRegistry).getAssets(bitFlag);
    }

    /// ERC7540 LOGIC ///

    /// @notice Transfers assets from owner and submits a request for an asynchronous deposit.
    /// @param assets The amount of assets to deposit.
    /// @param controller The address of the controller of the position being created.
    /// @param owner The address of the owner of the assets being deposited.
    /// @dev Reverts on 0 assets or if the caller is not the owner or operator of the assets being deposited.
    function requestDeposit(uint256 assets, address controller, address owner) public returns (uint256 requestId) {
        // Checks
        if (msg.sender != owner) {
            if (!isOperator[owner][msg.sender]) {
                revert NotAuthorizedOperator();
            }
        }
        if (assets == 0) {
            revert ZeroAmount();
        }
        requestId = nextDepositRequestId;
        uint256 userLastDepositRequestId = lastDepositRequestId[controller];
        // If the user has a pending deposit request in the past, they must wait for it to be fulfilled before making a
        // new one
        if (userLastDepositRequestId != requestId) {
            if (pendingDepositRequest(userLastDepositRequestId, controller) > 0) {
                revert MustClaimOutstandingDeposit();
            }
        }
        // If the user has a claimable deposit request, they must claim it before making a new one
        if (
            claimableDepositRequest(userLastDepositRequestId, controller) > 0 || claimableFallbackAssets(controller) > 0
        ) {
            revert MustClaimOutstandingDeposit();
        }
        if (AssetRegistry(assetRegistry).hasPausedAssets(bitFlag)) {
            revert AssetPaused();
        }
        // Effects
        DepositRequestStruct storage depositRequest = _depositRequests[requestId];
        // update controllers balance of assets pending deposit
        depositRequest.depositAssets[controller] += assets;
        // update total pending deposits for the current requestId
        depositRequest.totalDepositAssets += assets;
        // update controllers latest deposit request id
        lastDepositRequestId[controller] = requestId;
        emit DepositRequest(controller, owner, requestId, msg.sender, assets);
        // Interactions
        // Assets are immediately transferred to here to await the basketManager to pull them
        // slither-disable-next-line arbitrary-send-erc20
        Permit2Lib.transferFrom2(IERC20(asset()), owner, address(this), assets);
    }

    /// @notice Returns the pending deposit request amount for a controller.
    /// @dev If the epoch has been advanced then the request has been fulfilled and is no longer pending.
    /// @param requestId The id of the request.
    /// @param controller The address of the controller of the deposit request.
    /// @return assets The amount of assets pending deposit.
    function pendingDepositRequest(uint256 requestId, address controller) public view returns (uint256 assets) {
        DepositRequestStruct storage depositRequest = _depositRequests[requestId];
        assets = depositRequest.fulfilledShares == 0 && !depositRequest.fallbackTriggered
            ? depositRequest.depositAssets[controller]
            : 0;
    }

    /// @notice Returns the amount of requested assets in Claimable state for the controller with the given requestId.
    /// @param requestId The id of the request.
    /// @param controller The address of the controller.
    function claimableDepositRequest(uint256 requestId, address controller) public view returns (uint256 assets) {
        DepositRequestStruct storage depositRequest = _depositRequests[requestId];
        assets = _claimableDepositRequest(depositRequest.fulfilledShares, depositRequest.depositAssets[controller]);
    }

    function _claimableDepositRequest(
        uint256 fulfilledShares,
        uint256 depositAssets
    )
        internal
        pure
        returns (uint256 assets)
    {
        return fulfilledShares != 0 ? depositAssets : 0;
    }

    /// @notice Requests a redemption of shares from the basket.
    /// @param shares The amount of shares to redeem.
    /// @param controller The address of the controller of the redeemed shares.
    /// @param owner The address of the request owner.
    function requestRedeem(uint256 shares, address controller, address owner) public returns (uint256 requestId) {
        // Checks
        if (shares == 0) {
            revert ZeroAmount();
        }
        requestId = nextRedeemRequestId;
        // If the user has a pending redeem request in the past, they must wait for it to be fulfilled before making a
        // new one
        uint256 userLastRedeemRequestId = lastRedeemRequestId[controller];
        if (userLastRedeemRequestId != requestId) {
            if (pendingRedeemRequest(userLastRedeemRequestId, controller) > 0) {
                revert MustClaimOutstandingRedeem();
            }
        }
        // If the user has a claimable redeem request, they must claim it before making a new one
        if (claimableRedeemRequest(userLastRedeemRequestId, controller) > 0 || claimableFallbackShares(controller) > 0)
        {
            revert MustClaimOutstandingRedeem();
        }
        if (msg.sender != owner) {
            if (!isOperator[owner][msg.sender]) {
                _spendAllowance(owner, msg.sender, shares);
            }
        }
        if (AssetRegistry(assetRegistry).hasPausedAssets(bitFlag)) {
            revert AssetPaused();
        }

        // Effects
        RedeemRequestStruct storage redeemRequest = _redeemRequests[requestId];
        // update total pending redemptions for the current requestId
        redeemRequest.totalRedeemShares += shares;
        // update controllers latest redeem request id
        lastRedeemRequestId[controller] = requestId;
        // update controllers balance of assets pending deposit
        redeemRequest.redeemShares[controller] += shares;
        _transfer(owner, address(this), shares);
        emit RedeemRequest(controller, owner, requestId, msg.sender, shares);
    }

    /// @notice Returns the pending redeem request amount for a user.
    /// @param requestId The id of the request.
    /// @param controller The address of the controller of the redemption request.
    /// @return shares The amount of shares pending redemption.
    function pendingRedeemRequest(uint256 requestId, address controller) public view returns (uint256 shares) {
        RedeemRequestStruct storage redeemRequest = _redeemRequests[requestId];
        shares = redeemRequest.fulfilledAssets == 0 && !redeemRequest.fallbackTriggered
            ? redeemRequest.redeemShares[controller]
            : 0;
    }

    /// @notice Returns the amount of requested shares in Claimable state for the controller with the given requestId.
    /// @param requestId The id of the request.
    /// @param controller The address of the controller of the redemption request.
    /// @return shares The amount of shares claimable.
    // solhint-disable-next-line no-unused-vars
    function claimableRedeemRequest(uint256 requestId, address controller) public view returns (uint256 shares) {
        RedeemRequestStruct storage redeemRequest = _redeemRequests[requestId];
        shares = _claimableRedeemRequest(redeemRequest.fulfilledAssets, redeemRequest.redeemShares[controller]);
    }

    function _claimableRedeemRequest(
        uint256 fulfilledAssets,
        uint256 redeemShares
    )
        internal
        pure
        returns (uint256 shares)
    {
        return fulfilledAssets != 0 ? redeemShares : 0;
    }

    /// @notice Fulfills all pending deposit requests. Only callable by the basket manager. Assets are held by the
    /// basket manager. Locks in the rate at which users can claim their shares for deposited assets.
    /// @param shares The amount of shares the deposit was fulfilled with.
    function fulfillDeposit(uint256 shares) public {
        // Checks
        _onlyBasketManager();
        // currentRequestId was advanced by 2 to prepare for rebalance
        uint256 currentRequestId = nextDepositRequestId - 2;
        DepositRequestStruct storage depositRequest = _depositRequests[currentRequestId];
        uint256 assets = depositRequest.totalDepositAssets;

        if (assets == 0) {
            revert ZeroPendingDeposits();
        }

        if (depositRequest.fulfilledShares > 0 || depositRequest.fallbackTriggered) {
            revert DepositRequestAlreadyFulfilled();
        }

        // Effects
        // If shares is zero, trigger fallback internally instead of reverting
        if (shares == 0) {
            depositRequest.fallbackTriggered = true;
            emit DepositFallbackTriggered(currentRequestId);
            return;
        }

        // Normal path - fulfill with shares
        depositRequest.fulfilledShares = shares;
        emit DepositFulfilled(currentRequestId, assets, shares);
        _mint(address(this), shares);
        // Interactions
        // transfer the assets to the basket manager
        IERC20(asset()).safeTransfer(msg.sender, assets);
    }

    /// @notice Sets the new bitflag for the basket.
    /// @dev This can only be called by the Basket Manager therefore we assume that the new bitflag is valid.
    /// @param bitFlag_ The new bitflag.
    function setBitFlag(uint256 bitFlag_) public {
        _onlyBasketManager();
        uint256 oldBitFlag = bitFlag;
        bitFlag = bitFlag_;
        emit BitFlagUpdated(oldBitFlag, bitFlag_);
    }

    /// @notice Prepares the basket token for rebalancing by processing pending deposits and redemptions.
    /// @dev This function:
    /// - Verifies previous deposit/redeem requests were fulfilled
    /// - Advances deposit/redeem epochs if there are pending requests
    /// - Harvests management fees
    /// - Can only be called by the basket manager
    /// - Called at the start of rebalancing regardless of pending requests
    /// - Does not advance epochs if there are no pending requests
    /// @param feeBps The management fee in basis points to be harvested.
    /// @param feeCollector The address that will receive the harvested management fee.
    /// @return pendingDeposits The total amount of base assets pending deposit.
    /// @return pendingShares The total amount of shares pending redemption.
    function prepareForRebalance(
        uint16 feeBps,
        address feeCollector
    )
        external
        returns (uint256 pendingDeposits, uint256 pendingShares)
    {
        _onlyBasketManager();
        uint256 nextDepositRequestId_ = nextDepositRequestId;
        uint256 nextRedeemRequestId_ = nextRedeemRequestId;

        // Check if previous deposit request has been fulfilled
        DepositRequestStruct storage previousDepositRequest = _depositRequests[nextDepositRequestId_ - 2];
        if (previousDepositRequest.totalDepositAssets > 0) {
            if (previousDepositRequest.fulfilledShares == 0) {
                if (!previousDepositRequest.fallbackTriggered) {
                    revert PreviousDepositRequestNotFulfilled();
                }
            }
        }

        // Check if previous redeem request has been fulfilled or fallbacked
        RedeemRequestStruct storage previousRedeemRequest = _redeemRequests[nextRedeemRequestId_ - 2];
        if (previousRedeemRequest.totalRedeemShares > 0) {
            if (previousRedeemRequest.fulfilledAssets == 0) {
                if (!previousRedeemRequest.fallbackTriggered) {
                    revert PreviousRedeemRequestNotFulfilled();
                }
            }
        }

        // Get current pending deposits
        pendingDeposits = _depositRequests[nextDepositRequestId_].totalDepositAssets;
        if (pendingDeposits > 0) {
            emit DepositRequestQueued(nextDepositRequestId_, pendingDeposits);
            nextDepositRequestId = nextDepositRequestId_ + 2;
        }

        pendingShares = _redeemRequests[nextRedeemRequestId_].totalRedeemShares;
        if (pendingShares > 0) {
            emit RedeemRequestQueued(nextRedeemRequestId_, pendingShares);
            nextRedeemRequestId = nextRedeemRequestId_ + 2;
        }

        _harvestManagementFee(feeBps, feeCollector);
    }

    /// @notice Fulfills all pending redeem requests. Only callable by the basket manager. Burns the shares which are
    /// pending redemption. Locks in the rate at which users can claim their assets for redeemed shares.
    /// @dev prepareForRebalance must be called before this function.
    /// @param assets The amount of assets the redemption was fulfilled with.
    function fulfillRedeem(uint256 assets) public {
        // Checks
        _onlyBasketManager();
        uint256 currentRequestId = nextRedeemRequestId - 2;
        RedeemRequestStruct storage redeemRequest = _redeemRequests[currentRequestId];
        uint256 shares = redeemRequest.totalRedeemShares;

        if (shares == 0) {
            revert ZeroPendingRedeems();
        }

        if (redeemRequest.fulfilledAssets > 0 || redeemRequest.fallbackTriggered) {
            revert RedeemRequestAlreadyFulfilled();
        }

        // Effects
        // If assets is zero, trigger fallback internally and return
        if (assets == 0) {
            redeemRequest.fallbackTriggered = true;
            emit RedeemFallbackTriggered(currentRequestId);
            return;
        }

        // Normal path - redeem request is fulfilled
        redeemRequest.fulfilledAssets = assets;
        emit RedeemFulfilled(currentRequestId, shares, assets);
        _burn(address(this), shares);
        // Interactions
        // slither-disable-next-line arbitrary-send-erc20
        IERC20(asset()).safeTransferFrom(msg.sender, address(this), assets);
    }

    /// @notice Retrieves the total amount of assets currently pending deposit.
    /// @dev Once a rebalance is proposed, any pending deposits are processed and this function will return the pending
    /// deposits of the next epoch.
    /// @return The total pending deposit amount.
    function totalPendingDeposits() public view returns (uint256) {
        return _depositRequests[nextDepositRequestId].totalDepositAssets;
    }

    /// @notice Returns the total number of shares pending redemption.
    /// @dev Once a rebalance is proposed, any pending redemptions are processed and this function will return the
    /// pending redemptions of the next epoch.
    /// @return The total pending redeem amount.
    function totalPendingRedemptions() public view returns (uint256) {
        return _redeemRequests[nextRedeemRequestId].totalRedeemShares;
    }

    /// @notice Cancels a pending deposit request.
    function cancelDepositRequest() public {
        // Checks
        uint256 nextDepositRequestId_ = nextDepositRequestId;
        uint256 pendingDeposit = pendingDepositRequest(nextDepositRequestId_, msg.sender);
        if (pendingDeposit == 0) {
            revert ZeroPendingDeposits();
        }
        // Effects
        DepositRequestStruct storage depositRequest = _depositRequests[nextDepositRequestId_];
        depositRequest.depositAssets[msg.sender] = 0;
        depositRequest.totalDepositAssets -= pendingDeposit;
        // Interactions
        IERC20(asset()).safeTransfer(msg.sender, pendingDeposit);
    }

    /// @notice Cancels a pending redeem request.
    function cancelRedeemRequest() public {
        // Checks
        uint256 nextRedeemRequestId_ = nextRedeemRequestId;
        uint256 pendingRedeem = pendingRedeemRequest(nextRedeemRequestId_, msg.sender);
        if (pendingRedeem == 0) {
            revert ZeroPendingRedeems();
        }
        // Effects
        RedeemRequestStruct storage redeemRequest = _redeemRequests[nextRedeemRequestId_];
        redeemRequest.redeemShares[msg.sender] = 0;
        redeemRequest.totalRedeemShares -= pendingRedeem;
        _transfer(address(this), msg.sender, pendingRedeem);
    }

    /// @notice Sets a status for an operator's ability to act on behalf of a controller.
    /// @param operator The address of the operator.
    /// @param approved The status of the operator.
    /// @return success True if the operator status was set, false otherwise.
    function setOperator(address operator, bool approved) public returns (bool success) {
        isOperator[msg.sender][operator] = approved;
        emit OperatorSet(msg.sender, operator, approved);
        return true;
    }

    /// @dev Reverts if the controller is not the caller or the operator of the caller.
    function _onlySelfOrOperator(address controller) internal view {
        if (msg.sender != controller) {
            if (!isOperator[controller][msg.sender]) {
                revert NotAuthorizedOperator();
            }
        }
    }

    /// @dev Reverts if the caller is not the Basket Manager.
    function _onlyBasketManager() internal view {
        if (basketManager != msg.sender) {
            revert NotBasketManager();
        }
    }

    /// @notice Returns the address of the share token as per ERC-7575.
    /// @return shareTokenAddress The address of the share token.
    /// @dev For non-multi asset vaults this should always return address(this).
    function share() public view returns (address shareTokenAddress) {
        shareTokenAddress = address(this);
    }

    /// FALLBACK REDEEM LOGIC ///

    /// @notice Claims shares given for a previous redemption request in the event a redemption fulfillment for a
    /// given epoch fails.
    /// @param receiver The address to receive the shares.
    /// @param controller The address of the controller of the redemption request.
    /// @return shares The amount of shares claimed.
    function claimFallbackShares(address receiver, address controller) public returns (uint256 shares) {
        // Checks
        _onlySelfOrOperator(controller);
        shares = claimableFallbackShares(controller);
        if (shares == 0) {
            revert ZeroClaimableFallbackShares();
        }
        // Effects
        _redeemRequests[lastRedeemRequestId[controller]].redeemShares[controller] = 0;
        _transfer(address(this), receiver, shares);
    }

    /// @notice Claims assets given for a previous deposit request in the event a deposit fulfillment for a
    /// given epoch fails.
    /// @param receiver The address to receive the assets.
    /// @param controller The address of the controller of the deposit request.
    /// @return assets The amount of assets claimed.
    function claimFallbackAssets(address receiver, address controller) public returns (uint256 assets) {
        // Checks
        _onlySelfOrOperator(controller);
        assets = claimableFallbackAssets(controller);
        if (assets == 0) {
            revert ZeroClaimableFallbackAssets();
        }
        // Effects
        _depositRequests[lastDepositRequestId[controller]].depositAssets[controller] = 0;
        IERC20(asset()).safeTransfer(receiver, assets);
    }

    /// @notice Returns the amount of shares claimable for a given user in the event of a failed redemption
    /// fulfillment.
    /// @param controller The address of the controller.
    /// @return shares The amount of shares claimable by the controller.
    function claimableFallbackShares(address controller) public view returns (uint256 shares) {
        RedeemRequestStruct storage redeemRequest = _redeemRequests[lastRedeemRequestId[controller]];
        if (redeemRequest.fallbackTriggered) {
            return redeemRequest.redeemShares[controller];
        }
        return 0;
    }

    /// @notice Returns the amount of assets claimable for a given user in the event of a failed deposit fulfillment.
    /// @param controller The address of the controller.
    /// @return assets The amount of assets claimable by the controller.
    function claimableFallbackAssets(address controller) public view returns (uint256 assets) {
        DepositRequestStruct storage depositRequest = _depositRequests[lastDepositRequestId[controller]];
        if (depositRequest.fallbackTriggered) {
            return depositRequest.depositAssets[controller];
        }
        return 0;
    }

    /// @notice Immediately redeems shares for all assets associated with this basket. This is synchronous and does not
    /// require the rebalance process to be completed.
    /// @param shares Number of shares to redeem.
    /// @param to Address to receive the assets.
    /// @param from Address to redeem shares from.
    function proRataRedeem(uint256 shares, address to, address from) public {
        // Checks and effects
        if (msg.sender != from) {
            if (!isOperator[from][msg.sender]) {
                _spendAllowance(from, msg.sender, shares);
            }
        }

        // Interactions
        BasketManager bm = BasketManager(basketManager);
        _harvestManagementFee(bm.managementFee(address(this)), bm.feeCollector());
        bm.proRataRedeem(totalSupply(), shares, to);

        // We intentionally defer the `_burn()` operation until after the external call to
        // `BasketManager.proRataRedeem()` to prevent potential price manipulation via read-only reentrancy attacks. By
        // performing the external interaction before updating balances, we ensure that total supply and user balances
        // cannot be manipulated if a malicious contract attempts to reenter during the ERC20 transfer (e.g., through
        // ERC777 tokens or plugins with callbacks).
        _burn(from, shares);
    }

    /// @notice Harvests management fees owed to the fee collector.
    function harvestManagementFee() external {
        BasketManager bm = BasketManager(basketManager);
        address feeCollector = bm.feeCollector();
        if (msg.sender != feeCollector) {
            revert NotFeeCollector();
        }
        uint16 feeBps = bm.managementFee(address(this));
        _harvestManagementFee(feeBps, feeCollector);
    }

    /// @notice Internal function to harvest management fees. Updates the timestamp of the last management fee harvest
    /// if a non zero fee is collected. Mints the fee to the fee collector and notifies the basket manager.
    /// @param feeBps The management fee in basis points to be harvested.
    /// @param feeCollector The address that will receive the harvested management fee.
    // slither-disable-next-line timestamp
    function _harvestManagementFee(uint16 feeBps, address feeCollector) internal {
        // Checks
        if (feeBps > _MAX_MANAGEMENT_FEE) {
            revert InvalidManagementFee();
        }
        uint256 timeSinceLastHarvest = block.timestamp - lastManagementFeeHarvestTimestamp;

        // Effects
        if (feeBps != 0) {
            if (timeSinceLastHarvest != 0) {
                // remove shares held by the treasury
                uint256 currentTotalSupply = totalSupply() - balanceOf(feeCollector);
                if (currentTotalSupply > 0) {
                    uint256 fee = FixedPointMathLib.fullMulDiv(
                        currentTotalSupply,
                        feeBps * timeSinceLastHarvest,
                        ((_MANAGEMENT_FEE_DECIMALS - feeBps) * uint256(365 days))
                    );
                    if (fee != 0) {
                        lastManagementFeeHarvestTimestamp = uint40(block.timestamp);
                        emit ManagementFeeHarvested(fee);
                        _mint(feeCollector, fee);
                        // Interactions
                        FeeCollector(feeCollector).notifyHarvestFee(fee);
                    }
                } else {
                    lastManagementFeeHarvestTimestamp = uint40(block.timestamp);
                }
            }
        } else {
            lastManagementFeeHarvestTimestamp = uint40(block.timestamp);
        }
    }

    /// ERC4626 OVERRIDDEN LOGIC ///

    /// @notice Transfers a user's shares owed for a previously fulfillled deposit request.
    /// @param assets The amount of assets previously requested for deposit.
    /// @param receiver The address to receive the shares.
    /// @param controller The address of the controller of the deposit request.
    /// @return shares The amount of shares minted.
    function deposit(uint256 assets, address receiver, address controller) public returns (uint256 shares) {
        // Checks
        if (assets == 0) {
            revert ZeroAmount();
        }
        _onlySelfOrOperator(controller);
        DepositRequestStruct storage depositRequest = _depositRequests[lastDepositRequestId[controller]];
        uint256 fulfilledShares = depositRequest.fulfilledShares;
        uint256 depositAssets = depositRequest.depositAssets[controller];
        if (assets != _claimableDepositRequest(fulfilledShares, depositAssets)) {
            revert MustClaimFullAmount();
        }
        shares = _maxMint(fulfilledShares, depositAssets, depositRequest.totalDepositAssets);
        // Effects
        _claimDeposit(depositRequest, assets, shares, receiver, controller);
    }

    /// @notice Transfers a user's shares owed for a previously fulfillled deposit request.
    /// @param assets The amount of assets to be claimed.
    /// @param receiver The address to receive the assets.
    /// @return shares The amount of shares previously requested for redemption.
    function deposit(uint256 assets, address receiver) public override returns (uint256 shares) {
        return deposit(assets, receiver, msg.sender);
    }

    /// @notice Transfers a user's shares owed for a previously fulfillled deposit request.
    /// @dev Deposit should be used in all instances instead.
    /// @param shares The amount of shares to receive.
    /// @param receiver The address to receive the shares.
    /// @param controller The address of the controller of the deposit request.
    /// @return assets The amount of assets previously requested for deposit.
    function mint(uint256 shares, address receiver, address controller) public returns (uint256 assets) {
        // Checks
        _onlySelfOrOperator(controller);
        DepositRequestStruct storage depositRequest = _depositRequests[lastDepositRequestId[controller]];
        uint256 fulfilledShares = depositRequest.fulfilledShares;
        uint256 depositAssets = depositRequest.depositAssets[controller];
        if (shares != _maxMint(fulfilledShares, depositAssets, depositRequest.totalDepositAssets)) {
            revert MustClaimFullAmount();
        }
        // Effects
        assets = _claimableDepositRequest(fulfilledShares, depositAssets);
        _claimDeposit(depositRequest, assets, shares, receiver, controller);
    }

    /// @notice Transfers a user's shares owed for a previously fulfillled deposit request.
    /// @param shares The amount of shares to receive.
    /// @param receiver The address to receive the shares.
    /// @return assets The amount of assets previously requested for deposit.
    function mint(uint256 shares, address receiver) public override returns (uint256 assets) {
        return mint(shares, receiver, msg.sender);
    }

    /// @notice Internal function to claim deposit for a given amount of assets and shares.
    /// @param assets The amount of assets to claim.
    /// @param shares The amount of shares to claim.
    /// @param receiver The address of the receiver of the claimed assets.
    /// @param controller The address of the controller of the deposit request.
    function _claimDeposit(
        DepositRequestStruct storage depositRequest,
        uint256 assets,
        uint256 shares,
        address receiver,
        address controller
    )
        internal
    {
        // Effects
        depositRequest.depositAssets[controller] = 0;
        emit Deposit(controller, receiver, assets, shares);
        // Interactions
        _transfer(address(this), receiver, shares);
    }

    /// @notice Transfers a user's assets owed for a previously fulfillled redemption request.
    /// @dev Redeem should be used in all instances instead.
    /// @param assets The amount of assets to be claimed.
    /// @param receiver The address to receive the assets.
    /// @param controller The address of the controller of the redeem request.
    /// @return shares The amount of shares previously requested for redemption.
    function withdraw(uint256 assets, address receiver, address controller) public override returns (uint256 shares) {
        // Checks
        _onlySelfOrOperator(controller);
        RedeemRequestStruct storage redeemRequest = _redeemRequests[lastRedeemRequestId[controller]];
        uint256 fulfilledAssets = redeemRequest.fulfilledAssets;
        uint256 redeemShares = redeemRequest.redeemShares[controller];
        if (assets != _maxWithdraw(fulfilledAssets, redeemShares, redeemRequest.totalRedeemShares)) {
            revert MustClaimFullAmount();
        }
        shares = _claimableRedeemRequest(fulfilledAssets, redeemShares);
        // Effects
        _claimRedemption(redeemRequest, assets, shares, receiver, controller);
    }

    /// @notice Transfers the receiver assets owed for a fulfilled redeem request.
    /// @param shares The amount of shares to be claimed.
    /// @param receiver The address to receive the assets.
    /// @param controller The address of the controller of the redeem request.
    /// @return assets The amount of assets previously requested for redemption.
    function redeem(uint256 shares, address receiver, address controller) public override returns (uint256 assets) {
        // Checks
        if (shares == 0) {
            revert ZeroAmount();
        }
        _onlySelfOrOperator(controller);
        RedeemRequestStruct storage redeemRequest = _redeemRequests[lastRedeemRequestId[controller]];
        uint256 fulfilledAssets = redeemRequest.fulfilledAssets;
        uint256 redeemShares = redeemRequest.redeemShares[controller];
        if (shares != _claimableRedeemRequest(fulfilledAssets, redeemShares)) {
            revert MustClaimFullAmount();
        }
        assets = _maxWithdraw(fulfilledAssets, redeemShares, redeemRequest.totalRedeemShares);
        // Effects & Interactions
        _claimRedemption(redeemRequest, assets, shares, receiver, controller);
    }

    /// @notice Internal function to claim redemption for a given amount of assets and shares.
    /// @param assets The amount of assets to claim.
    /// @param shares The amount of shares to claim.
    /// @param receiver The address of the receiver of the claimed assets.
    /// @param controller The address of the controller of the redemption request.
    function _claimRedemption(
        RedeemRequestStruct storage redeemRequest,
        uint256 assets,
        uint256 shares,
        address receiver,
        address controller
    )
        internal
    {
        // Effects
        redeemRequest.redeemShares[controller] = 0;
        emit Withdraw(msg.sender, receiver, controller, assets, shares);
        // Interactions
        IERC20(asset()).safeTransfer(receiver, assets);
    }

    /// @notice Returns an controller's amount of assets fulfilled for redemption.
    /// @dev For requests yet to be fulfilled, this will return 0.
    /// @param controller The address of the controller.
    /// @return The amount of assets that can be withdrawn.
    function maxWithdraw(address controller) public view override returns (uint256) {
        RedeemRequestStruct storage redeemRequest = _redeemRequests[lastRedeemRequestId[controller]];
        return _maxWithdraw(
            redeemRequest.fulfilledAssets, redeemRequest.redeemShares[controller], redeemRequest.totalRedeemShares
        );
    }

    function _maxWithdraw(
        uint256 fulfilledAssets,
        uint256 redeemShares,
        uint256 totalRedeemShares
    )
        internal
        pure
        returns (uint256)
    {
        return
            totalRedeemShares == 0 ? 0 : FixedPointMathLib.fullMulDiv(fulfilledAssets, redeemShares, totalRedeemShares);
    }

    /// @notice Returns an controller's amount of shares fulfilled for redemption.
    /// @dev For requests yet to be fulfilled, this will return 0.
    /// @param controller The address of the controller.
    /// @return The amount of shares that can be redeemed.
    function maxRedeem(address controller) public view override returns (uint256) {
        return claimableRedeemRequest(lastRedeemRequestId[controller], controller);
    }

    /// @notice Returns an controller's amount of assets fulfilled for deposit.
    /// @dev For requests yet to be fulfilled, this will return 0.
    /// @param controller The address of the controller.
    /// @return The amount of assets that can be deposited.
    function maxDeposit(address controller) public view override returns (uint256) {
        return claimableDepositRequest(lastDepositRequestId[controller], controller);
    }

    /// @notice Returns an controller's amount of shares fulfilled for deposit.
    /// @dev For requests yet to be fulfilled, this will return 0.
    /// @param controller The address of the controller.
    /// @return The amount of shares that can be minted.
    function maxMint(address controller) public view override returns (uint256) {
        DepositRequestStruct storage depositRequest = _depositRequests[lastDepositRequestId[controller]];
        return _maxMint(
            depositRequest.fulfilledShares, depositRequest.depositAssets[controller], depositRequest.totalDepositAssets
        );
    }

    function _maxMint(
        uint256 fulfilledShares,
        uint256 depositAssets,
        uint256 totalDepositAssets
    )
        internal
        pure
        returns (uint256)
    {
        return totalDepositAssets == 0
            ? 0
            : FixedPointMathLib.fullMulDiv(fulfilledShares, depositAssets, totalDepositAssets);
    }

    // solhint-disable custom-errors,gas-custom-errors,reason-string
    // Preview functions always revert for async flows
    function previewDeposit(uint256) public pure override returns (uint256) {
        revert();
    }

    // Preview functions always revert for async flows
    function previewMint(uint256) public pure override returns (uint256) {
        revert();
    }

    // Preview functions always revert for async flows
    function previewWithdraw(uint256) public pure override returns (uint256) {
        revert();
    }

    // Preview functions always revert for async flows
    function previewRedeem(uint256) public pure override returns (uint256) {
        revert();
    }
    // solhint-enable custom-errors,gas-custom-errors,reason-string

    /// @notice Returns true if the redemption request's fallback has been triggered.
    /// @param requestId The id of the request.
    /// @return True if the fallback has been triggered, false otherwise.
    function fallbackRedeemTriggered(uint256 requestId) public view returns (bool) {
        return _redeemRequests[requestId].fallbackTriggered;
    }

    /// @notice Returns true if the deposit request's fallback has been triggered.
    /// @param requestId The id of the request.
    /// @return True if the fallback has been triggered, false otherwise.
    function fallbackDepositTriggered(uint256 requestId) public view returns (bool) {
        return _depositRequests[requestId].fallbackTriggered;
    }

    /// @notice Returns the deposit request data for a given requestId without the internal mapping.
    /// @param requestId The id of the deposit request.
    /// @return A DepositRequestView struct containing the deposit request data.
    function getDepositRequest(uint256 requestId) external view returns (DepositRequestView memory) {
        DepositRequestStruct storage depositRequest = _depositRequests[requestId];
        return DepositRequestView({
            totalDepositAssets: depositRequest.totalDepositAssets,
            fulfilledShares: depositRequest.fulfilledShares,
            fallbackTriggered: depositRequest.fallbackTriggered
        });
    }

    /// @notice Returns the redeem request data for a given requestId without the internal mapping.
    /// @param requestId The id of the redeem request.
    /// @return A RedeemRequestView struct containing the redeem request data.
    function getRedeemRequest(uint256 requestId) external view returns (RedeemRequestView memory) {
        RedeemRequestStruct storage redeemRequest = _redeemRequests[requestId];
        return RedeemRequestView({
            totalRedeemShares: redeemRequest.totalRedeemShares,
            fulfilledAssets: redeemRequest.fulfilledAssets,
            fallbackTriggered: redeemRequest.fallbackTriggered
        });
    }

    //// ERC165 OVERRIDDEN LOGIC ///
    /// @notice Checks if the contract supports the given interface.
    /// @param interfaceID The interface ID.
    /// @return True if the contract supports the interface, false otherwise.
    function supportsInterface(bytes4 interfaceID) public view virtual override returns (bool) {
        return interfaceID == 0x2f0a18c5 || interfaceID == 0xf815c03d
            || interfaceID == type(IERC7540Operator).interfaceId || interfaceID == type(IERC7540Deposit).interfaceId
            || interfaceID == type(IERC7540Redeem).interfaceId || super.supportsInterface(interfaceID);
    }

    /// @dev Override to call the ERC20PluginsUpgradeable's _update function.
    function _update(
        address from,
        address to,
        uint256 amount
    )
        internal
        override(ERC20PluginsUpgradeable, ERC20Upgradeable)
    {
        ERC20PluginsUpgradeable._update(from, to, amount);
    }

    /// @dev Override to call the ERC20PluginsUpgradeable's balanceOf function.
    /// See {IERC20-balanceOf}.
    function balanceOf(address account)
        public
        view
        override(ERC20PluginsUpgradeable, ERC20Upgradeable, IERC20)
        returns (uint256)
    {
        return ERC20PluginsUpgradeable.balanceOf(account);
    }

    /// @dev Override to return 18 decimals.
    /// See {IERC20Metadata-decimals}.
    function decimals() public pure override(ERC20Upgradeable, ERC4626Upgradeable) returns (uint8) {
        return 18;
    }

    /// @notice External wrapper around Permit2Lib's permit2 function to handle ERC20 permit signatures.
    /// @dev Supports both Permit2 and ERC20Permit (ERC-2612) signatures. Will try ERC-2612 first,
    /// then fall back to Permit2 if the token doesn't support ERC-2612 or if the permit call fails.
    /// @param token The token to permit
    /// @param owner The owner of the tokens
    /// @param spender The spender to approve
    /// @param value The amount to approve
    /// @param deadline The deadline for the permit
    /// @param v The v component of the signature
    /// @param r The r component of the signature
    /// @param s The s component of the signature
    function permit2(
        IERC20 token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
    {
        Permit2Lib.permit2(token, owner, spender, value, deadline, v, r, s);
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import { AccessControlEnumerable } from "@openzeppelin/contracts/access/extensions/AccessControlEnumerable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { FixedPointMathLib } from "@solady/utils/FixedPointMathLib.sol";

import { BasketManager } from "src/BasketManager.sol";
import { BasketToken } from "src/BasketToken.sol";
import { Rescuable } from "src/Rescuable.sol";

/// @title FeeCollector
/// @notice Contract to collect fees from the BasketManager and distribute them to sponsors and the protocol treasury
// slither-disable-next-line locked-ether
contract FeeCollector is AccessControlEnumerable, Rescuable {
    /// CONSTANTS ///
    bytes32 private constant _BASKET_TOKEN_ROLE = keccak256("BASKET_TOKEN_ROLE");
    /// @dev Fee split is denominated in 1e4. Also used as maximum fee split for the sponsor.
    uint16 private constant _FEE_SPLIT_DECIMALS = 1e4;

    /// STATE VARIABLES ///
    /// @notice The address of the protocol treasury
    address public protocolTreasury;
    /// @notice The BasketManager contract
    BasketManager internal immutable _basketManager;
    /// @notice Mapping of basket tokens to their sponsor addresses
    mapping(address basketToken => address sponsor) public basketTokenSponsors;
    /// @notice Mapping of basket tokens to their sponsor split percentages
    mapping(address basketToken => uint16 sponsorSplit) public basketTokenSponsorSplits;
    /// @notice Mapping of basket tokens to current claimable treasury fees
    mapping(address basketToken => uint256 claimableFees) public claimableTreasuryFees;
    /// @notice Mapping of basket tokens to the current claimable sponsor fees
    mapping(address basketToken => uint256 claimableFees) public claimableSponsorFees;

    /// EVENTS ///
    /// @notice Emitted when the sponsor for a basket token is set.
    /// @param basketToken The address of the basket token.
    /// @param sponsor The address of the sponsor that was set.
    event SponsorSet(address indexed basketToken, address indexed sponsor);
    /// @notice Emitted when the sponsor fee split for a basket token is set.
    /// @param basketToken The address of the basket token.
    /// @param sponsorSplit The percentage of fees allocated to the sponsor, denominated in _FEE_SPLIT_DECIMALS.
    event SponsorSplitSet(address indexed basketToken, uint16 sponsorSplit);
    /// @notice Emitted when the protocol treasury address is set.
    /// @param treasury The address of the new protocol treasury.
    event TreasurySet(address indexed treasury);

    /// ERRORS ///
    /// @notice Thrown when the address is zero.
    error ZeroAddress();
    /// @notice Thrown when attempting to set a sponsor fee split higher than _MAX_FEE.
    error SponsorSplitTooHigh();
    /// @notice Thrown when attempting to set a sponsor fee split for a basket token with no sponsor.
    error NoSponsor();
    /// @notice Thrown when an unauthorized address attempts to call a restricted function.
    error Unauthorized();
    /// @notice Thrown when attempting to perform an action on an address that is not a basket token.
    error NotBasketToken();
    /// @notice Thrown when attempting to claim treasury fees from an address that is not the protocol treasury.
    error NotTreasury();
    /// @notice Thrown funds attempted to be rescued exceed the available balance.
    error InsufficientFundsToRescue();

    /// @notice Constructor to set the admin, basket manager, and protocol treasury
    /// @param admin The address of the admin
    /// @param basketManager The address of the BasketManager
    /// @param treasury The address of the protocol treasury
    constructor(address admin, address basketManager, address treasury) payable {
        if (admin == address(0)) {
            revert ZeroAddress();
        }
        if (basketManager == address(0)) {
            revert ZeroAddress();
        }
        if (treasury == address(0)) {
            revert ZeroAddress();
        }
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _basketManager = BasketManager(basketManager);
        protocolTreasury = treasury;
    }

    /// @notice Set the protocol treasury address
    /// @param treasury The address of the new protocol treasury
    function setProtocolTreasury(address treasury) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (treasury == address(0)) {
            revert ZeroAddress();
        }
        protocolTreasury = treasury;
        emit TreasurySet(treasury);
    }

    /// @notice Set the sponsor for a given basket token
    /// @param basketToken The address of the basket token
    /// @param sponsor The address of the sponsor
    function setSponsor(address basketToken, address sponsor) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _checkIfBasketToken(basketToken);
        // claim any outstanding fees for previous sponsor
        address currentSponsor = basketTokenSponsors[basketToken];
        _claimSponsorFee(basketToken, currentSponsor);
        basketTokenSponsors[basketToken] = sponsor;
        emit SponsorSet(basketToken, sponsor);
    }

    /// @notice Set the split of management fees given to the sponsor for a given basket token
    /// @param basketToken The address of the basket token
    /// @param sponsorSplit The percentage of fees to give to the sponsor denominated in _FEE_SPLIT_DECIMALS
    function setSponsorSplit(address basketToken, uint16 sponsorSplit) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _checkIfBasketToken(basketToken);
        if (sponsorSplit > _FEE_SPLIT_DECIMALS) {
            revert SponsorSplitTooHigh();
        }
        if (basketTokenSponsors[basketToken] == address(0)) {
            revert NoSponsor();
        }
        basketTokenSponsorSplits[basketToken] = sponsorSplit;
        emit SponsorSplitSet(basketToken, sponsorSplit);
    }

    /// @notice Notify the FeeCollector of the fees collected from the basket token
    /// @param shares The amount of shares collected
    function notifyHarvestFee(uint256 shares) external {
        address basketToken = msg.sender;
        _checkIfBasketToken(basketToken);
        uint16 sponsorFeeSplit = basketTokenSponsorSplits[basketToken];
        if (basketTokenSponsors[basketToken] != address(0)) {
            if (sponsorFeeSplit > 0) {
                uint256 sponsorFee = FixedPointMathLib.mulDiv(shares, sponsorFeeSplit, _FEE_SPLIT_DECIMALS);
                claimableSponsorFees[basketToken] += sponsorFee;
                shares = shares - sponsorFee;
            }
        }
        claimableTreasuryFees[basketToken] += shares;
    }

    /// @notice Claim the sponsor fee for a given basket token, only callable by the sponsor
    /// @param basketToken The address of the basket token
    function claimSponsorFee(address basketToken) external {
        _checkIfBasketToken(basketToken);
        address sponsor = basketTokenSponsors[basketToken];
        if (msg.sender != sponsor) {
            if (!hasRole(DEFAULT_ADMIN_ROLE, msg.sender)) {
                revert Unauthorized();
            }
        }
        // Call harvestManagementFee to ensure that the fee is up to date
        BasketToken(basketToken).harvestManagementFee();
        _claimSponsorFee(basketToken, sponsor);
    }

    /// @notice Claim the treasury fee for a given basket token, only callable by the protocol treasury or admin
    /// @param basketToken The address of the basket token
    function claimTreasuryFee(address basketToken) external {
        _checkIfBasketToken(basketToken);
        address protocolTreasury_ = protocolTreasury;
        if (msg.sender != protocolTreasury_) {
            if (!hasRole(DEFAULT_ADMIN_ROLE, msg.sender)) {
                revert Unauthorized();
            }
        }
        // Call harvestManagementFee to ensure that the fee is up to date
        BasketToken(basketToken).harvestManagementFee();
        uint256 fee = claimableTreasuryFees[basketToken];
        if (fee > 0) {
            claimableTreasuryFees[basketToken] = 0;
            BasketToken(basketToken).proRataRedeem(fee, protocolTreasury, address(this));
        }
    }

    /// @notice Internal function to claim the sponsor fee for a given basket token. Will immediately redeem the shares
    /// through a proRataRedeem.
    /// @param basketToken The address of the basket token
    /// @param sponsor The address of the sponsor
    function _claimSponsorFee(address basketToken, address sponsor) internal {
        uint256 fee = claimableSponsorFees[basketToken];
        if (fee > 0) {
            if (sponsor != address(0)) {
                claimableSponsorFees[basketToken] = 0;
                BasketToken(basketToken).proRataRedeem(fee, sponsor, address(this));
            }
        }
    }

    /// @notice Rescue ERC20 tokens or ETH from the contract. Reverts if the balance trying to rescue exceeds the
    /// available balance minus claimable fees.
    /// @param token address of the token to rescue. Use zero address for ETH.
    /// @param to address to send the rescued tokens to
    /// @param amount amount of tokens to rescue
    function rescue(IERC20 token, address to, uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        address rescueToken = address(token);
        if (
            amount
                > token.balanceOf(address(this)) - claimableTreasuryFees[rescueToken] - claimableSponsorFees[rescueToken]
        ) {
            revert InsufficientFundsToRescue();
        }
        _rescue(token, to, amount);
    }

    /// @notice Internal function to check if a given address is a basket token
    /// @param token The address to check
    function _checkIfBasketToken(address token) internal view {
        if (!_basketManager.hasRole(_BASKET_TOKEN_ROLE, token)) {
            revert NotBasketToken();
        }
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import { IERC20, SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";

/// @title Rescuable
/// @notice Allows the inheriting contract to rescue ERC20 tokens that are sent to it by mistake.
contract Rescuable {
    // Libraries
    using SafeERC20 for IERC20;

    // Errors
    /// @notice Error for when an ETH transfer of zero is attempted.
    error ZeroEthTransfer();
    /// @notice Error for when an ETH transfer fails.
    error EthTransferFailed();
    /// @notice Error for when a token transfer of zero is attempted.
    error ZeroTokenTransfer();

    /// @dev Rescue any ERC20 tokens that are stuck in this contract.
    /// The inheriting contract that calls this function should specify required access controls
    /// @param token address of the ERC20 token to rescue. Use zero address for ETH
    /// @param to address to send the tokens to
    /// @param balance amount of tokens to rescue. Use zero to rescue all
    function _rescue(IERC20 token, address to, uint256 balance) internal {
        if (address(token) == address(0)) {
            // for ether
            uint256 totalBalance = address(this).balance;
            balance = balance != 0 ? Math.min(totalBalance, balance) : totalBalance;
            if (balance != 0) {
                // slither-disable-next-line arbitrary-send
                // slither-disable-next-line low-level-calls
                (bool success,) = to.call{ value: balance }("");
                if (!success) revert EthTransferFailed();
                return;
            }
            revert ZeroEthTransfer();
        } else {
            // for any other erc20
            uint256 totalBalance = token.balanceOf(address(this));
            balance = balance != 0 ? Math.min(totalBalance, balance) : totalBalance;
            if (balance != 0) {
                token.safeTransfer(to, balance);
                return;
            }
            revert ZeroTokenTransfer();
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IERC20Permit } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";

import { SafeCast160 } from "src/deps/permit2/SafeCast160.sol";
import { IAllowanceTransfer } from "src/interfaces/deps/permit2/IAllowanceTransfer.sol";
import { IDAIPermit } from "src/interfaces/deps/permit2/IDAIPermit.sol";

/// @title Permit2Lib
/// @notice Enables efficient transfers and EIP-2612/DAI
/// permits for any token by falling back to Permit2.
library Permit2Lib {
    using SafeCast160 for uint256;
    /*//////////////////////////////////////////////////////////////
                                CONSTANTS
    //////////////////////////////////////////////////////////////*/

    /// @dev The unique EIP-712 domain domain separator for the DAI token contract.
    bytes32 internal constant DAI_DOMAIN_SEPARATOR = 0xdbb8cf42e1ecb028be3f3dbc922e1d878b963f411dc388ced501601c60f7c6f7;

    /// @dev The address for the WETH9 contract on Ethereum mainnet, encoded as a bytes32.
    bytes32 internal constant WETH9_ADDRESS = 0x000000000000000000000000c02aaa39b223fe8d0a0e5c4f27ead9083c756cc2;

    /// @dev The address of the Permit2 contract the library will use.
    IAllowanceTransfer internal constant PERMIT2 =
        IAllowanceTransfer(address(0x000000000022D473030F116dDEE9F6B43aC78BA3));

    /// @notice Transfer a given amount of tokens from one user to another.
    /// @param token The token to transfer.
    /// @param from The user to transfer from.
    /// @param to The user to transfer to.
    /// @param amount The amount to transfer.
    function transferFrom2(IERC20 token, address from, address to, uint256 amount) internal {
        // Generate calldata for a standard transferFrom call.
        bytes memory inputData = abi.encodeCall(IERC20.transferFrom, (from, to, amount));

        bool success; // Call the token contract as normal, capturing whether it succeeded.
        assembly {
            success :=
                and(
                    // Set success to whether the call reverted, if not we check it either
                    // returned exactly 1 (can't just be non-zero data), or had no return data.
                    or(eq(mload(0), 1), iszero(returndatasize())),
                    // Counterintuitively, this call() must be positioned after the or() in the
                    // surrounding and() because and() evaluates its arguments from right to left.
                    // We use 0 and 32 to copy up to 32 bytes of return data into the first slot of scratch space.
                    call(gas(), token, 0, add(inputData, 32), mload(inputData), 0, 32)
                )
        }

        // We'll fall back to using Permit2 if calling transferFrom on the token directly reverted.
        if (!success) PERMIT2.transferFrom(from, to, amount.toUint160(), address(token));
    }

    /*//////////////////////////////////////////////////////////////
                              PERMIT LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @notice Permit a user to spend a given amount of
    /// another user's tokens via native EIP-2612 permit if possible, falling
    /// back to Permit2 if native permit fails or is not implemented on the token.
    /// @param token The token to permit spending.
    /// @param owner The user to permit spending from.
    /// @param spender The user to permit spending to.
    /// @param amount The amount to permit spending.
    /// @param deadline  The timestamp after which the signature is no longer valid.
    /// @param v Must produce valid secp256k1 signature from the owner along with r and s.
    /// @param r Must produce valid secp256k1 signature from the owner along with v and s.
    /// @param s Must produce valid secp256k1 signature from the owner along with r and v.
    function permit2(
        IERC20 token,
        address owner,
        address spender,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        internal
    {
        // Generate calldata for a call to DOMAIN_SEPARATOR on the token.
        bytes memory inputData = abi.encodeWithSelector(IERC20Permit.DOMAIN_SEPARATOR.selector);

        bool success; // Call the token contract as normal, capturing whether it succeeded.
        bytes32 domainSeparator; // If the call succeeded, we'll capture the return value here.

        assembly {
            // If the token is WETH9, we know it doesn't have a DOMAIN_SEPARATOR, and we'll skip this step.
            // We make sure to mask the token address as its higher order bits aren't guaranteed to be clean.
            if iszero(eq(and(token, 0xffffffffffffffffffffffffffffffffffffffff), WETH9_ADDRESS)) {
                success :=
                    and(
                        // Should resolve false if its not 32 bytes or its first word is 0.
                        and(iszero(iszero(mload(0))), eq(returndatasize(), 32)),
                        // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                        // Counterintuitively, this call must be positioned second to the and() call in the
                        // surrounding and() call or else returndatasize() will be zero during the computation.
                        // We send a maximum of 5000 gas to prevent tokens with fallbacks from using a ton of gas.
                        // which should be plenty to allow tokens to fetch their DOMAIN_SEPARATOR from storage, etc.
                        staticcall(15000, token, add(inputData, 32), mload(inputData), 0, 32)
                    )

                domainSeparator := mload(0) // Copy the return value into the domainSeparator variable.
            }
        }

        // If the call to DOMAIN_SEPARATOR succeeded, try using permit on the token.
        if (success) {
            // We'll use DAI's special permit if it's DOMAIN_SEPARATOR matches,
            // otherwise we'll just encode a call to the standard permit function.
            inputData = domainSeparator == DAI_DOMAIN_SEPARATOR
                ? abi.encodeCall(
                    IDAIPermit.permit, (owner, spender, IDAIPermit(address(token)).nonces(owner), deadline, true, v, r, s)
                )
                : abi.encodeCall(IERC20Permit.permit, (owner, spender, amount, deadline, v, r, s));

            assembly {
                success := call(gas(), token, 0, add(inputData, 32), mload(inputData), 0, 0)
            }
        }

        if (!success) {
            // If the initial DOMAIN_SEPARATOR call on the token failed or a
            // subsequent call to permit failed, fall back to using Permit2.
            simplePermit2(token, owner, spender, amount, deadline, v, r, s);
        }
    }

    /// @notice Simple unlimited permit on the Permit2 contract.
    /// @param token The token to permit spending.
    /// @param owner The user to permit spending from.
    /// @param spender The user to permit spending to.
    /// @param amount The amount to permit spending.
    /// @param deadline  The timestamp after which the signature is no longer valid.
    /// @param v Must produce valid secp256k1 signature from the owner along with r and s.
    /// @param r Must produce valid secp256k1 signature from the owner along with v and s.
    /// @param s Must produce valid secp256k1 signature from the owner along with r and v.
    function simplePermit2(
        IERC20 token,
        address owner,
        address spender,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        internal
    {
        (,, uint48 nonce) = PERMIT2.allowance(owner, address(token), spender);

        PERMIT2.permit(
            owner,
            IAllowanceTransfer.PermitSingle({
                details: IAllowanceTransfer.PermitDetails({
                    token: address(token),
                    amount: amount.toUint160(),
                    // Use an unlimited expiration because it most
                    // closely mimics how a standard approval works.
                    expiration: type(uint48).max,
                    nonce: nonce
                }),
                spender: spender,
                sigDeadline: deadline
            }),
            bytes.concat(r, s, bytes1(v))
        );
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

library SafeCast160 {
    /// @notice Thrown when a valude greater than type(uint160).max is cast to uint160
    error UnsafeCast();

    /// @notice Safely casts uint256 to uint160
    /// @param value The uint256 to be cast
    function toUint160(uint256 value) internal pure returns (uint160) {
        if (value > type(uint160).max) revert UnsafeCast();
        return uint160(value);
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

interface IERC7540Operator {
    /**
     * @dev The event emitted when an operator is set.
     *
     * @param controller The address of the controller.
     * @param operator The address of the operator.
     * @param approved The approval status.
     */
    event OperatorSet(address indexed controller, address indexed operator, bool approved);

    /**
     * @dev Sets or removes an operator for the caller.
     *
     * @param operator The address of the operator.
     * @param approved The approval status.
     * @return Whether the call was executed successfully or not
     */
    function setOperator(address operator, bool approved) external returns (bool);

    /**
     * @dev Returns `true` if the `operator` is approved as an operator for an `controller`.
     *
     * @param controller The address of the controller.
     * @param operator The address of the operator.
     * @return status The approval status
     */
    function isOperator(address controller, address operator) external view returns (bool status);
}

interface IERC7540Deposit {
    event DepositRequest(
        address indexed controller, address indexed owner, uint256 indexed requestId, address sender, uint256 assets
    );
    /**
     * @dev Transfers assets from sender into the Vault and submits a Request for asynchronous deposit.
     *
     * - MUST support ERC-20 approve / transferFrom on asset as a deposit Request flow.
     * - MUST revert if all of assets cannot be requested for deposit.
     * - owner MUST be msg.sender unless some unspecified explicit approval is given by the caller,
     *    approval of ERC-20 tokens from owner to sender is NOT enough.
     *
     * @param assets the amount of deposit assets to transfer from owner
     * @param controller the controller of the request who will be able to operate the request
     * @param owner the source of the deposit assets
     *
     * NOTE: most implementations will require pre-approval of the Vault with the Vault's underlying asset token.
     */

    function requestDeposit(uint256 assets, address controller, address owner) external returns (uint256 requestId);

    /**
     * @dev Returns the amount of requested assets in Pending state.
     *
     * - MUST NOT include any assets in Claimable state for deposit or mint.
     * - MUST NOT show any variations depending on the caller.
     * - MUST NOT revert unless due to integer overflow caused by an unreasonably large input.
     */
    function pendingDepositRequest(
        uint256 requestId,
        address controller
    )
        external
        view
        returns (uint256 pendingAssets);

    /**
     * @dev Returns the amount of requested assets in Claimable state for the controller to deposit or mint.
     *
     * - MUST NOT include any assets in Pending state.
     * - MUST NOT show any variations depending on the caller.
     * - MUST NOT revert unless due to integer overflow caused by an unreasonably large input.
     */
    function claimableDepositRequest(
        uint256 requestId,
        address controller
    )
        external
        view
        returns (uint256 claimableAssets);

    /**
     * @dev Mints shares Vault shares to receiver by claiming the Request of the controller.
     *
     * - MUST emit the Deposit event.
     * - controller MUST equal msg.sender unless the controller has approved the msg.sender as an operator.
     */
    function deposit(uint256 assets, address receiver, address controller) external returns (uint256 shares);

    /**
     * @dev Mints exactly shares Vault shares to receiver by claiming the Request of the controller.
     *
     * - MUST emit the Deposit event.
     * - controller MUST equal msg.sender unless the controller has approved the msg.sender as an operator.
     */
    function mint(uint256 shares, address receiver, address controller) external returns (uint256 assets);
}

interface IERC7540Redeem {
    event RedeemRequest(
        address indexed controller, address indexed owner, uint256 indexed requestId, address sender, uint256 assets
    );

    /**
     * @dev Assumes control of shares from sender into the Vault and submits a Request for asynchronous redeem.
     *
     * - MUST support a redeem Request flow where the control of shares is taken from sender directly
     *   where msg.sender has ERC-20 approval over the shares of owner.
     * - MUST revert if all of shares cannot be requested for redeem.
     *
     * @param shares the amount of shares to be redeemed to transfer from owner
     * @param controller the controller of the request who will be able to operate the request
     * @param owner the source of the shares to be redeemed
     *
     * NOTE: most implementations will require pre-approval of the Vault with the Vault's share token.
     */
    function requestRedeem(uint256 shares, address controller, address owner) external returns (uint256 requestId);

    /**
     * @dev Returns the amount of requested shares in Pending state.
     *
     * - MUST NOT include any shares in Claimable state for redeem or withdraw.
     * - MUST NOT show any variations depending on the caller.
     * - MUST NOT revert unless due to integer overflow caused by an unreasonably large input.
     */
    function pendingRedeemRequest(
        uint256 requestId,
        address controller
    )
        external
        view
        returns (uint256 pendingShares);

    /**
     * @dev Returns the amount of requested shares in Claimable state for the controller to redeem or withdraw.
     *
     * - MUST NOT include any shares in Pending state for redeem or withdraw.
     * - MUST NOT show any variations depending on the caller.
     * - MUST NOT revert unless due to integer overflow caused by an unreasonably large input.
     */
    function claimableRedeemRequest(
        uint256 requestId,
        address controller
    )
        external
        view
        returns (uint256 claimableShares);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IEIP712 } from "./IEIP712.sol";

/// @title AllowanceTransfer
/// @notice Handles ERC20 token permissions through signature based allowance setting and ERC20 token transfers by
/// checking allowed amounts
/// @dev Requires user's token approval on the Permit2 contract
interface IAllowanceTransfer is IEIP712 {
    /// @notice Thrown when an allowance on a token has expired.
    /// @param deadline The timestamp at which the allowed amount is no longer valid
    error AllowanceExpired(uint256 deadline);

    /// @notice Thrown when an allowance on a token has been depleted.
    /// @param amount The maximum amount allowed
    error InsufficientAllowance(uint256 amount);

    /// @notice Thrown when too many nonces are invalidated.
    error ExcessiveInvalidation();

    /// @notice Emits an event when the owner successfully invalidates an ordered nonce.
    event NonceInvalidation(
        address indexed owner, address indexed token, address indexed spender, uint48 newNonce, uint48 oldNonce
    );

    /// @notice Emits an event when the owner successfully sets permissions on a token for the spender.
    event Approval(
        address indexed owner, address indexed token, address indexed spender, uint160 amount, uint48 expiration
    );

    /// @notice Emits an event when the owner successfully sets permissions using a permit signature on a token for the
    /// spender.
    event Permit(
        address indexed owner,
        address indexed token,
        address indexed spender,
        uint160 amount,
        uint48 expiration,
        uint48 nonce
    );

    /// @notice Emits an event when the owner sets the allowance back to 0 with the lockdown function.
    event Lockdown(address indexed owner, address token, address spender);

    /// @notice The permit data for a token
    struct PermitDetails {
        // ERC20 token address
        address token;
        // the maximum amount allowed to spend
        uint160 amount;
        // timestamp at which a spender's token allowances become invalid
        uint48 expiration;
        // an incrementing value indexed per owner,token,and spender for each signature
        uint48 nonce;
    }

    /// @notice The permit message signed for a single token allowance
    struct PermitSingle {
        // the permit data for a single token alownce
        PermitDetails details;
        // address permissioned on the allowed tokens
        address spender;
        // deadline on the permit signature
        uint256 sigDeadline;
    }

    /// @notice The permit message signed for multiple token allowances
    struct PermitBatch {
        // the permit data for multiple token allowances
        PermitDetails[] details;
        // address permissioned on the allowed tokens
        address spender;
        // deadline on the permit signature
        uint256 sigDeadline;
    }

    /// @notice The saved permissions
    /// @dev This info is saved per owner, per token, per spender and all signed over in the permit message
    /// @dev Setting amount to type(uint160).max sets an unlimited approval
    struct PackedAllowance {
        // amount allowed
        uint160 amount;
        // permission expiry
        uint48 expiration;
        // an incrementing value indexed per owner,token,and spender for each signature
        uint48 nonce;
    }

    /// @notice A token spender pair.
    struct TokenSpenderPair {
        // the token the spender is approved
        address token;
        // the spender address
        address spender;
    }

    /// @notice Details for a token transfer.
    struct AllowanceTransferDetails {
        // the owner of the token
        address from;
        // the recipient of the token
        address to;
        // the amount of the token
        uint160 amount;
        // the token to be transferred
        address token;
    }

    /// @notice A mapping from owner address to token address to spender address to PackedAllowance struct, which
    /// contains details and conditions of the approval.
    /// @notice The mapping is indexed in the above order see: allowance[ownerAddress][tokenAddress][spenderAddress]
    /// @dev The packed slot holds the allowed amount, expiration at which the allowed amount is no longer valid, and
    /// current nonce that's updated on any signature based approvals.
    function allowance(
        address user,
        address token,
        address spender
    )
        external
        view
        returns (uint160 amount, uint48 expiration, uint48 nonce);

    /// @notice Approves the spender to use up to amount of the specified token up until the expiration
    /// @param token The token to approve
    /// @param spender The spender address to approve
    /// @param amount The approved amount of the token
    /// @param expiration The timestamp at which the approval is no longer valid
    /// @dev The packed allowance also holds a nonce, which will stay unchanged in approve
    /// @dev Setting amount to type(uint160).max sets an unlimited approval
    function approve(address token, address spender, uint160 amount, uint48 expiration) external;

    /// @notice Permit a spender to a given amount of the owners token via the owner's EIP-712 signature
    /// @dev May fail if the owner's nonce was invalidated in-flight by invalidateNonce
    /// @param owner The owner of the tokens being approved
    /// @param permitSingle Data signed over by the owner specifying the terms of approval
    /// @param signature The owner's signature over the permit data
    function permit(address owner, PermitSingle memory permitSingle, bytes calldata signature) external;

    /// @notice Permit a spender to the signed amounts of the owners tokens via the owner's EIP-712 signature
    /// @dev May fail if the owner's nonce was invalidated in-flight by invalidateNonce
    /// @param owner The owner of the tokens being approved
    /// @param permitBatch Data signed over by the owner specifying the terms of approval
    /// @param signature The owner's signature over the permit data
    function permit(address owner, PermitBatch memory permitBatch, bytes calldata signature) external;

    /// @notice Transfer approved tokens from one address to another
    /// @param from The address to transfer from
    /// @param to The address of the recipient
    /// @param amount The amount of the token to transfer
    /// @param token The token address to transfer
    /// @dev Requires the from address to have approved at least the desired amount
    /// of tokens to msg.sender.
    function transferFrom(address from, address to, uint160 amount, address token) external;

    /// @notice Transfer approved tokens in a batch
    /// @param transferDetails Array of owners, recipients, amounts, and tokens for the transfers
    /// @dev Requires the from addresses to have approved at least the desired amount
    /// of tokens to msg.sender.
    function transferFrom(AllowanceTransferDetails[] calldata transferDetails) external;

    /// @notice Enables performing a "lockdown" of the sender's Permit2 identity
    /// by batch revoking approvals
    /// @param approvals Array of approvals to revoke.
    function lockdown(TokenSpenderPair[] calldata approvals) external;

    /// @notice Invalidate nonces for a given (token, spender) pair
    /// @param token The token to invalidate nonces for
    /// @param spender The spender to invalidate nonces for
    /// @param newNonce The new nonce to set. Invalidates all nonces less than it.
    /// @dev Can't invalidate more than 2**16 nonces per transaction.
    function invalidateNonces(address token, address spender, uint48 newNonce) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IDAIPermit {
    /// @param holder The address of the token owner.
    /// @param spender The address of the token spender.
    /// @param nonce The owner's nonce, increases at each call to permit.
    /// @param expiry The timestamp at which the permit is no longer valid.
    /// @param allowed Boolean that sets approval amount, true for type(uint256).max and false for 0.
    /// @param v Must produce valid secp256k1 signature from the owner along with r and s.
    /// @param r Must produce valid secp256k1 signature from the owner along with v and s.
    /// @param s Must produce valid secp256k1 signature from the owner along with r and v.
    function permit(
        address holder,
        address spender,
        uint256 nonce,
        uint256 expiry,
        bool allowed,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external;

    /// @param holder The address of the token owner.
    function nonces(address holder) external view returns (uint256);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IEIP712 {
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import { Clones } from "@openzeppelin/contracts/proxy/Clones.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { FixedPointMathLib } from "@solady/utils/FixedPointMathLib.sol";
import { EulerRouter } from "euler-price-oracle/src/EulerRouter.sol";

import { AssetRegistry } from "src/AssetRegistry.sol";
import { BasketToken } from "src/BasketToken.sol";
import { MathUtils } from "src/libraries/MathUtils.sol";
import { TokenSwapAdapter } from "src/swap_adapters/TokenSwapAdapter.sol";
import { BasketManagerStorage, RebalanceStatus, Status } from "src/types/BasketManagerStorage.sol";
import { BasketTradeOwnership, ExternalTrade, InternalTrade } from "src/types/Trades.sol";

/// @title BasketManagerUtils
/// @notice Library containing utility functions for managing storage related to baskets, including creating new
/// baskets, proposing and executing rebalances, and settling internal and external token trades.
library BasketManagerUtils {
    using SafeERC20 for IERC20;

    /// STRUCTS ///
    /// @notice Struct containing data for an internal trade.
    struct InternalTradeInfo {
        // Index of the basket that is selling.
        uint256 fromBasketIndex;
        // Index of the basket that is buying.
        uint256 toBasketIndex;
        // Index of the token to sell.
        uint256 sellTokenAssetIndex;
        // Index of the token to buy.
        uint256 buyTokenAssetIndex;
        // Index of the buy token in the buying basket.
        uint256 toBasketBuyTokenIndex;
        // Index of the sell token in the buying basket.
        uint256 toBasketSellTokenIndex;
        // Amount of the buy token that is traded.
        uint256 netBuyAmount;
        // Amount of the sell token that is traded.
        uint256 netSellAmount;
        // Fee charged on the buy token on the trade.
        uint256 feeOnBuy;
        // Fee charged on the sell token on the trade.
        uint256 feeOnSell;
        // USD value of the sell token amount
        uint256 sellValue;
        // USD value of the fees charged on the trade
        uint256 feeValue;
    }

    /// @dev Outsource vars to resolve stack too deep during coverage runs
    struct BasketContext {
        uint256[][] basketBalances;
        uint256[] totalValues;
    }

    /// CONSTANTS ///
    /// @notice ISO 4217 numeric code for USD, used as a constant address representation
    address private constant _USD_ISO_4217_CODE = address(840);
    /// @notice Maximum number of basket tokens allowed to be created.
    uint256 private constant _MAX_NUM_OF_BASKET_TOKENS = 256;
    /// @notice Precision used for weight calculations and slippage calculations.
    uint256 private constant _WEIGHT_PRECISION = 1e18;
    /// @notice Minimum time between rebalances in seconds.
    uint40 private constant _REBALANCE_COOLDOWN_SEC = 1 hours;

    /// EVENTS ///
    /// @notice Emitted when an internal trade is settled.
    /// @param internalTrade Internal trade that was settled.
    /// @param buyAmount Amount of the the from token that is traded.
    event InternalTradeSettled(InternalTrade internalTrade, uint256 buyAmount);
    /// @notice Emitted when swap fees are charged on an internal trade.
    /// @param asset Asset that the swap fee was charged in.
    /// @param amount Amount of the asset that was charged.
    event SwapFeeCharged(address indexed asset, uint256 amount);
    /// @notice Emitted when a rebalance is proposed for a set of baskets
    /// @param epoch Unique identifier for the rebalance, incremented each time a rebalance is proposed
    /// @param baskets Array of basket addresses to rebalance
    /// @param proposedTargetWeights Array of target weights for each basket
    /// @param basketAssets Array of assets in each basket
    /// @param basketHash Hash of the basket addresses and target weights for the rebalance
    event RebalanceProposed(
        uint40 indexed epoch,
        address[] baskets,
        uint64[][] proposedTargetWeights,
        address[][] basketAssets,
        bytes32 basketHash
    );
    /// @notice Emitted when a rebalance is completed.
    /// @param epoch Unique identifier for the rebalance, incremented each time a rebalance is completed
    event RebalanceCompleted(uint40 indexed epoch);
    /// @notice Emitted when a rebalance is retried.
    /// @param epoch Unique identifier for the rebalance, incremented each time a rebalance is completed
    /// @param retryCount Number of retries for the current rebalance epoch. On the first retry, this will be 1.
    event RebalanceRetried(uint40 indexed epoch, uint256 retryCount);

    /// ERRORS ///
    /// @notice Reverts when the address is zero.
    error ZeroAddress();
    /// @notice Reverts when the amount is zero.
    error ZeroAmount();
    /// @notice Reverts when the total supply of a basket token is zero.
    error ZeroTotalSupply();
    /// @notice Reverts when the amount of burned shares is zero.
    error ZeroBurnedShares();
    /// @notice Reverts when trying to burn more shares than the total supply.
    error CannotBurnMoreSharesThanTotalSupply();
    /// @notice Reverts when the requested basket token is not found.
    error BasketTokenNotFound();
    /// @notice Reverts when the requested asset is not found in the basket.
    error AssetNotFoundInBasket();
    /// @notice Reverts when trying to create a basket token that already exists.
    error BasketTokenAlreadyExists();
    /// @notice Reverts when the maximum number of basket tokens has been reached.
    error BasketTokenMaxExceeded();
    /// @notice Reverts when the requested element index is not found.
    error ElementIndexNotFound();
    /// @notice Reverts when the strategy registry does not support the given strategy.
    error StrategyRegistryDoesNotSupportStrategy();
    /// @notice Reverts when the baskets or target weights do not match the proposed rebalance.
    error BasketsMismatch();
    /// @notice Reverts when the base asset does not match the given asset.
    error BaseAssetMismatch();
    /// @notice Reverts when the asset is not found in the asset registry.
    error AssetListEmpty();
    /// @notice Reverts when a rebalance is in progress and the caller must wait for it to complete.
    error MustWaitForRebalanceToComplete();
    /// @notice Reverts when there is no rebalance in progress.
    error NoRebalanceInProgress();
    /// @notice Reverts when it is too early to complete the rebalance.
    error TooEarlyToCompleteRebalance();
    /// @notice Reverts when it is too early to propose a rebalance.
    error TooEarlyToProposeRebalance();
    /// @notice Reverts when a rebalance is not required.
    error RebalanceNotRequired();
    /// @notice Reverts when the external trade slippage exceeds the allowed limit.
    error ExternalTradeSlippage();
    /// @notice Reverts when the target weights are not met.
    error TargetWeightsNotMet();
    /// @notice Reverts when the minimum or maximum amount is not reached for an internal trade.
    error InternalTradeMinMaxAmountNotReached();
    /// @notice Reverts when the trade token amount is incorrect.
    error IncorrectTradeTokenAmount();
    /// @notice Reverts when given external trades do not match.
    error ExternalTradeMismatch();
    /// @notice Reverts when the delegatecall to the tokenswap adapter fails.
    error CompleteTokenSwapFailed();
    /// @notice Reverts when an asset included in a bit flag is not enabled in the asset registry.
    error AssetNotEnabled();
    /// @notice Reverts when no internal or external trades are provided for a rebalance.
    error CannotProposeEmptyTrades();
    /// @notice Reverts when the sum of tradeOwnerships do not match the _WEIGHT_PRECISION
    error OwnershipSumMismatch();
    /// @dev Reverts when the sell amount of an internal trade is zero.
    error InternalTradeSellAmountZero();
    /// @dev Reverts when the sell amount of an external trade is zero.
    error ExternalTradeSellAmountZero();

    /// @notice Creates a new basket token with the given parameters.
    /// @param self BasketManagerStorage struct containing strategy data.
    /// @param basketName Name of the basket.
    /// @param symbol Symbol of the basket.
    /// @param bitFlag Asset selection bitFlag for the basket.
    /// @param strategy Address of the strategy contract for the basket.
    /// @return basket Address of the newly created basket token.
    function createNewBasket(
        BasketManagerStorage storage self,
        string calldata basketName,
        string calldata symbol,
        address baseAsset,
        uint256 bitFlag,
        address strategy
    )
        external
        returns (address basket)
    {
        // Checks
        if (baseAsset == address(0)) {
            revert ZeroAddress();
        }
        uint256 basketTokensLength = self.basketTokens.length;
        if (basketTokensLength >= _MAX_NUM_OF_BASKET_TOKENS) {
            revert BasketTokenMaxExceeded();
        }
        bytes32 basketId = keccak256(abi.encodePacked(bitFlag, strategy));
        if (self.basketIdToAddress[basketId] != address(0)) {
            revert BasketTokenAlreadyExists();
        }
        // Checks with external view calls
        if (!self.strategyRegistry.supportsBitFlag(bitFlag, strategy)) {
            revert StrategyRegistryDoesNotSupportStrategy();
        }
        AssetRegistry assetRegistry = AssetRegistry(self.assetRegistry);
        if (assetRegistry.hasPausedAssets(bitFlag)) {
            revert AssetNotEnabled();
        }
        address[] memory assets = assetRegistry.getAssets(bitFlag);
        if (assets.length == 0) {
            revert AssetListEmpty();
        }
        basket = Clones.clone(self.basketTokenImplementation);
        _setBaseAssetIndex(self, basket, assets, baseAsset);
        self.basketTokens.push(basket);
        self.basketAssets[basket] = assets;
        self.basketIdToAddress[basketId] = basket;
        // The set default management fee will given to the zero address
        self.managementFees[basket] = self.managementFees[address(0)];
        uint256 assetsLength = assets.length;
        for (uint256 j = 0; j < assetsLength;) {
            // nosemgrep: solidity.performance.state-variable-read-in-a-loop.state-variable-read-in-a-loop
            self.basketAssetToIndexPlusOne[basket][assets[j]] = j + 1;
            unchecked {
                // Overflow not possible: j is bounded by assets.length
                ++j;
            }
        }
        unchecked {
            // Overflow not possible: basketTokensLength is less than the constant _MAX_NUM_OF_BASKET_TOKENS
            self.basketTokenToIndexPlusOne[basket] = basketTokensLength + 1;
        }
        // Interactions
        BasketToken(basket).initialize(IERC20(baseAsset), basketName, symbol, bitFlag, strategy, address(assetRegistry));
    }

    /// @notice Proposes a rebalance for the given baskets. The rebalance is proposed if the difference between the
    /// target balance and the current balance of any asset in the basket is more than 500 USD.
    /// @param baskets Array of basket addresses to rebalance.
    // solhint-disable code-complexity
    // slither-disable-next-line cyclomatic-complexity
    function proposeRebalance(BasketManagerStorage storage self, address[] calldata baskets) external {
        // Checks
        // Revert if a rebalance is already in progress
        if (self.rebalanceStatus.status != Status.NOT_STARTED) {
            revert MustWaitForRebalanceToComplete();
        }
        // slither-disable-next-line timestamp
        if (block.timestamp - self.rebalanceStatus.timestamp < _REBALANCE_COOLDOWN_SEC) {
            revert TooEarlyToProposeRebalance();
        }

        // Effects
        self.rebalanceStatus.basketMask = _createRebalanceBitMask(self, baskets);
        self.rebalanceStatus.proposalTimestamp = uint40(block.timestamp);
        self.rebalanceStatus.timestamp = uint40(block.timestamp);
        self.rebalanceStatus.status = Status.REBALANCE_PROPOSED;

        address assetRegistry = self.assetRegistry;
        address feeCollector = self.feeCollector;
        EulerRouter eulerRouter = self.eulerRouter;
        uint64[][] memory basketTargetWeights = new uint64[][](baskets.length);
        address[][] memory basketAssets = new address[][](baskets.length);

        // Interactions
        for (uint256 i = 0; i < baskets.length;) {
            // slither-disable-start calls-loop
            address basket = baskets[i];
            // nosemgrep: solidity.performance.state-variable-read-in-a-loop.state-variable-read-in-a-loop
            address[] memory assets = basketAssets[i] = self.basketAssets[basket];
            basketTargetWeights[i] = BasketToken(basket).getTargetWeights();
            // nosemgrep: solidity.performance.array-length-outside-loop.array-length-outside-loop
            if (assets.length == 0) {
                revert BasketTokenNotFound();
            }
            if (AssetRegistry(assetRegistry).hasPausedAssets(BasketToken(basket).bitFlag())) {
                revert AssetNotEnabled();
            }
            // Calculate current basket value
            (uint256[] memory balances, uint256 basketValue) = _calculateBasketValue(self, eulerRouter, basket, assets);
            // Notify Basket Token of rebalance:
            (uint256 pendingDeposits, uint256 pendingRedeems) =
                BasketToken(basket).prepareForRebalance(self.managementFees[basket], feeCollector);
            // Cache total supply for later use
            uint256 totalSupply = BasketToken(basket).totalSupply();
            // Process pending deposits
            if (pendingDeposits > 0) {
                // nosemgrep: solidity.performance.state-variable-read-in-a-loop.state-variable-read-in-a-loop
                uint256 baseAssetIndex = self.basketTokenToBaseAssetIndexPlusOne[basket] - 1;
                // Process pending deposits and fulfill them
                (uint256 newShares, uint256 pendingDepositValue) = _processPendingDeposits(
                    self,
                    eulerRouter,
                    basket,
                    totalSupply,
                    basketValue,
                    balances[baseAssetIndex],
                    pendingDeposits,
                    assets[baseAssetIndex]
                );
                // If no new shares are minted, no deposit will be added to the basket
                if (newShares > 0) {
                    balances[baseAssetIndex] += pendingDeposits;
                    totalSupply += newShares;
                    basketValue += pendingDepositValue;
                }
            }
            // No need to rebalance if the total supply is 0 even after processing pending deposits
            if (totalSupply == 0) {
                revert ZeroTotalSupply();
            }
            uint256 requiredWithdrawValue = 0;
            // Pre-process pending redemptions
            if (pendingRedeems > 0) {
                if (totalSupply > 0) {
                    // totalSupply cannot be 0 when pendingRedeems is greater than 0, as redemptions
                    // can only occur if there are issued shares (i.e., totalSupply > 0).
                    // Division-by-zero is not possible: totalSupply is greater than 0
                    requiredWithdrawValue = FixedPointMathLib.fullMulDiv(basketValue, pendingRedeems, totalSupply);
                    if (requiredWithdrawValue > basketValue) {
                        // This should never happen, but if it does, withdraw the entire basket value
                        requiredWithdrawValue = basketValue;
                    }
                    unchecked {
                        // Overflow not possible: requiredWithdrawValue is less than or equal to basketValue
                        basketValue -= requiredWithdrawValue;
                    }
                }
                // nosemgrep: solidity.performance.state-variable-read-in-a-loop.state-variable-read-in-a-loop
                self.pendingRedeems[basket] = pendingRedeems;
            }
            // slither-disable-end calls-loop
            unchecked {
                // Overflow not possible: i is less than baskets.length
                ++i;
            }
        }

        // Effects after Interactions. Target weights require external view calls to respective strategies.
        bytes32 basketHash = keccak256(abi.encode(baskets, basketTargetWeights, basketAssets));
        // slither-disable-next-line reentrancy-events
        emit RebalanceProposed(self.rebalanceStatus.epoch, baskets, basketTargetWeights, basketAssets, basketHash);
        self.rebalanceStatus.basketHash = basketHash;
    }
    // solhint-enable code-complexity

    // @notice Proposes a set of internal trades and external trades to rebalance the given baskets.
    /// If the proposed token swap results are not close to the target balances, this function will revert.
    /// @dev This function can only be called after proposeRebalance.
    /// @param self BasketManagerStorage struct containing strategy data.
    /// @param internalTrades Array of internal trades to execute.
    /// @param externalTrades Array of external trades to execute.
    /// @param baskets Array of basket addresses currently being rebalanced.
    /// @param basketTargetWeights Array of target weights for each basket.
    /// @param basketAssets Array of assets in each basket.
    // slither-disable-next-line cyclomatic-complexity
    function proposeTokenSwap(
        BasketManagerStorage storage self,
        InternalTrade[] calldata internalTrades,
        ExternalTrade[] calldata externalTrades,
        address[] calldata baskets,
        uint64[][] calldata basketTargetWeights,
        address[][] calldata basketAssets
    )
        external
    {
        // Checks
        RebalanceStatus memory status = self.rebalanceStatus;
        if (status.status != Status.REBALANCE_PROPOSED) {
            revert MustWaitForRebalanceToComplete();
        }
        _validateBasketHash(self, baskets, basketTargetWeights, basketAssets);
        if (internalTrades.length == 0) {
            if (externalTrades.length == 0) {
                revert CannotProposeEmptyTrades();
            }
        }
        // Effects
        status.timestamp = uint40(block.timestamp);
        status.status = Status.TOKEN_SWAP_PROPOSED;
        self.rebalanceStatus = status;
        self.externalTradesHash = keccak256(abi.encode(externalTrades));

        EulerRouter eulerRouter = self.eulerRouter;
        BasketContext memory slot = BasketContext({
            basketBalances: new uint256[][](baskets.length),
            totalValues: new uint256[](baskets.length)
        });
        _initializeBasketData(self, eulerRouter, baskets, basketAssets, slot);
        // NOTE: for rebalance retries the internal trades must be updated as well
        _processInternalTrades(self, eulerRouter, internalTrades, baskets, slot);
        _validateExternalTrades(self, eulerRouter, externalTrades, baskets, slot);
        if (!_isTargetWeightMet(self, eulerRouter, baskets, basketTargetWeights, basketAssets, slot)) {
            revert TargetWeightsNotMet();
        }
    }

    /// @notice Completes the rebalance for the given baskets. The rebalance can be completed if it has been more than
    /// 15 minutes since the last action.
    /// @param self BasketManagerStorage struct containing strategy data.
    /// @param externalTrades Array of external trades matching those proposed for rebalance.
    /// @param baskets Array of basket addresses proposed for rebalance.
    /// @param basketTargetWeights Array of target weights for each basket.
    // slither-disable-next-line cyclomatic-complexity
    function completeRebalance(
        BasketManagerStorage storage self,
        ExternalTrade[] calldata externalTrades,
        address[] calldata baskets,
        uint64[][] calldata basketTargetWeights,
        address[][] calldata basketAssets
    )
        external
    {
        // Revert if there is no rebalance in progress
        // slither-disable-next-line incorrect-equality
        if (self.rebalanceStatus.status == Status.NOT_STARTED) {
            revert NoRebalanceInProgress();
        }
        _validateBasketHash(self, baskets, basketTargetWeights, basketAssets);
        // Check if the rebalance was proposed more than 15 minutes ago
        // slither-disable-next-line timestamp
        if (block.timestamp - self.rebalanceStatus.timestamp < self.stepDelay) {
            revert TooEarlyToCompleteRebalance();
        }
        // if external trades are proposed and executed, finalize them and claim results from the trades
        if (self.rebalanceStatus.status == Status.TOKEN_SWAP_EXECUTED) {
            if (keccak256(abi.encode(externalTrades)) != self.externalTradesHash) {
                revert ExternalTradeMismatch();
            }
            _processExternalTrades(self, externalTrades);
        }

        EulerRouter eulerRouter = self.eulerRouter;
        BasketContext memory slot = BasketContext({
            basketBalances: new uint256[][](baskets.length),
            totalValues: new uint256[](baskets.length)
        });
        _initializeBasketData(self, eulerRouter, baskets, basketAssets, slot);
        // Confirm that target weights have been met, if max retries is reached continue regardless
        uint8 currentRetryCount = self.rebalanceStatus.retryCount;
        if (currentRetryCount < self.retryLimit) {
            if (!_isTargetWeightMet(self, eulerRouter, baskets, basketTargetWeights, basketAssets, slot)) {
                emit RebalanceRetried(self.rebalanceStatus.epoch, ++currentRetryCount);
                // If target weights are not met and we have not reached max retries, revert to beginning of rebalance
                // to allow for additional token swaps to be proposed and increment retryCount.
                self.rebalanceStatus.retryCount = currentRetryCount;
                self.rebalanceStatus.timestamp = uint40(block.timestamp);
                self.externalTradesHash = bytes32(0);
                self.rebalanceStatus.status = Status.REBALANCE_PROPOSED;
                return;
            }
        }
        _finalizeRebalance(self, eulerRouter, baskets, basketAssets);
    }

    /// FALLBACK REDEEM LOGIC ///

    /// @notice Fallback redeem function to redeem shares when the rebalance is not in progress. Redeems the shares for
    /// each underlying asset in the basket pro-rata to the amount of shares redeemed.
    /// @param totalSupplyBefore Total supply of the basket token before the shares were burned.
    /// @param burnedShares Amount of shares burned.
    /// @param to Address to send the redeemed assets to.
    // solhint-disable-next-line code-complexity
    function proRataRedeem(
        BasketManagerStorage storage self,
        uint256 totalSupplyBefore,
        uint256 burnedShares,
        address to
    )
        external
    {
        // Checks
        if (totalSupplyBefore == 0) {
            revert ZeroTotalSupply();
        }
        if (burnedShares == 0) {
            revert ZeroBurnedShares();
        }
        if (burnedShares > totalSupplyBefore) {
            revert CannotBurnMoreSharesThanTotalSupply();
        }
        if (to == address(0)) {
            revert ZeroAddress();
        }
        // Revert if the basket is currently rebalancing
        if ((self.rebalanceStatus.basketMask & (1 << self.basketTokenToIndexPlusOne[msg.sender] - 1)) != 0) {
            revert MustWaitForRebalanceToComplete();
        }

        address basket = msg.sender;
        address[] memory assets = self.basketAssets[basket];
        uint256 assetsLength = assets.length;
        uint256[] memory amountToWithdraws = new uint256[](assetsLength);

        // Interactions
        // First loop: compute amountToWithdraw for each asset and update balances
        for (uint256 i = 0; i < assetsLength;) {
            address asset = assets[i];
            // nosemgrep: solidity.performance.state-variable-read-in-a-loop.state-variable-read-in-a-loop
            uint256 balance = self.basketBalanceOf[basket][asset];
            // Rounding direction: down
            // Division-by-zero is not possible: totalSupplyBefore is greater than 0
            uint256 amountToWithdraw = FixedPointMathLib.fullMulDiv(burnedShares, balance, totalSupplyBefore);
            amountToWithdraws[i] = amountToWithdraw;
            if (amountToWithdraw > 0) {
                // nosemgrep: solidity.performance.state-variable-read-in-a-loop.state-variable-read-in-a-loop
                self.basketBalanceOf[basket][asset] = balance - amountToWithdraw;
            }
            unchecked {
                // Overflow not possible: i is less than assetsLength
                ++i;
            }
        }

        // Second loop: perform safeTransfer for each asset
        for (uint256 i = 0; i < assetsLength;) {
            uint256 amountToWithdraw = amountToWithdraws[i];
            if (amountToWithdraw > 0) {
                // Asset is an allowlisted ERC20 with no reentrancy problem in transfer
                // slither-disable-next-line reentrancy-no-eth
                IERC20(assets[i]).safeTransfer(to, amountToWithdraw);
            }
            unchecked {
                // Overflow not possible: i is less than assetsLength
                ++i;
            }
        }
    }

    /// @notice Returns the index of the asset in a given basket
    /// @param self BasketManagerStorage struct containing strategy data.
    /// @param basketToken Basket token address.
    /// @param asset Asset address.
    /// @return index Index of the asset in the basket.
    function getAssetIndexInBasket(
        BasketManagerStorage storage self,
        address basketToken,
        address asset
    )
        public
        view
        returns (uint256 index)
    {
        index = self.basketAssetToIndexPlusOne[basketToken][asset];
        if (index == 0) {
            revert AssetNotFoundInBasket();
        }
        unchecked {
            // Overflow not possible: index is not 0
            return index - 1;
        }
    }

    /// @notice Returns the index of the basket token.
    /// @param self BasketManagerStorage struct containing strategy data.
    /// @param basketToken Basket token address.
    /// @return index Index of the basket token.
    function basketTokenToIndex(
        BasketManagerStorage storage self,
        address basketToken
    )
        public
        view
        returns (uint256 index)
    {
        index = self.basketTokenToIndexPlusOne[basketToken];
        if (index == 0) {
            revert BasketTokenNotFound();
        }
        unchecked {
            // Overflow not possible: index is not 0
            return index - 1;
        }
    }

    /// INTERNAL FUNCTIONS ///

    /// @notice Returns the index of the element in the array.
    /// @dev Reverts if the element does not exist in the array.
    /// @param array Array to find the element in.
    /// @param element Element to find in the array.
    /// @return index Index of the element in the array.
    function _indexOf(address[] calldata array, address element) internal pure returns (uint256 index) {
        uint256 length = array.length;
        for (uint256 i = 0; i < length;) {
            if (array[i] == element) {
                return i;
            }
            unchecked {
                // Overflow not possible: index is not 0
                ++i;
            }
        }
        revert ElementIndexNotFound();
    }

    /// PRIVATE FUNCTIONS ///

    /// @notice Internal function to finalize the state changes for the current rebalance. Resets rebalance status and
    /// attempts to process pending redeems. If all pending redeems cannot be fulfilled notifies basket token of a
    /// failed rebalance.
    /// @param self BasketManagerStorage struct containing strategy data.
    /// @param baskets Array of basket addresses currently being rebalanced.
    function _finalizeRebalance(
        BasketManagerStorage storage self,
        EulerRouter eulerRouter,
        address[] calldata baskets,
        address[][] calldata basketAssets
    )
        private
    {
        // Advance the rebalance epoch and reset the status
        uint40 epoch = self.rebalanceStatus.epoch;
        self.rebalanceStatus.basketHash = bytes32(0);
        self.rebalanceStatus.basketMask = 0;
        self.rebalanceStatus.epoch = epoch + 1;
        self.rebalanceStatus.proposalTimestamp = uint40(0);
        self.rebalanceStatus.timestamp = uint40(block.timestamp);
        self.rebalanceStatus.status = Status.NOT_STARTED;
        self.externalTradesHash = bytes32(0);
        self.rebalanceStatus.retryCount = 0;
        // slither-disable-next-line reentrancy-events
        emit RebalanceCompleted(epoch);

        // Process the redeems for the given baskets
        uint256 len = baskets.length;
        // slither-disable-start calls-loop
        for (uint256 i = 0; i < len;) {
            // NOTE: Can be optimized by using calldata for the `baskets` parameter or by moving the
            // redemption processing logic to a ZK coprocessor like Axiom for improved efficiency and scalability.
            address basket = baskets[i];
            address[] calldata assets = basketAssets[i];
            // nosemgrep: solidity.performance.array-length-outside-loop.array-length-outside-loop
            uint256 assetsLength = assets.length;
            uint256[] memory balances = new uint256[](assetsLength);
            uint256 basketValue = 0;

            // Calculate current basket value
            for (uint256 j = 0; j < assetsLength;) {
                // nosemgrep: solidity.performance.state-variable-read-in-a-loop.state-variable-read-in-a-loop
                balances[j] = self.basketBalanceOf[basket][assets[j]];
                if (balances[j] > 0) {
                    // Rounding direction: down
                    // nosemgrep: solidity.performance.state-variable-read-in-a-loop.state-variable-read-in-a-loop
                    basketValue += eulerRouter.getQuote(balances[j], assets[j], _USD_ISO_4217_CODE);
                }
                unchecked {
                    // Overflow not possible: j is less than assetsLength
                    ++j;
                }
            }

            // If there are pending redeems, process them
            // nosemgrep: solidity.performance.state-variable-read-in-a-loop.state-variable-read-in-a-loop
            uint256 pendingRedeems = self.pendingRedeems[basket];
            if (pendingRedeems > 0) {
                // slither-disable-next-line costly-loop
                delete self.pendingRedeems[basket]; // nosemgrep
                uint256 baseAssetIndex = self.basketTokenToBaseAssetIndexPlusOne[basket] - 1;
                address baseAsset = assets[baseAssetIndex];
                uint256 baseAssetBalance = balances[baseAssetIndex];
                // Rounding direction: down
                // Division-by-zero is not possible: totalSupply is greater than 0 when pendingRedeems is greater than 0
                // nosemgrep: solidity.performance.state-variable-read-in-a-loop.state-variable-read-in-a-loop
                uint256 withdrawAmount = eulerRouter.getQuote(
                    FixedPointMathLib.fullMulDiv(basketValue, pendingRedeems, BasketToken(basket).totalSupply()),
                    _USD_ISO_4217_CODE,
                    baseAsset
                );
                // Set withdrawAmount to zero if it exceeds baseAssetBalance, otherwise keep it unchanged
                withdrawAmount = withdrawAmount <= baseAssetBalance ? withdrawAmount : 0;
                if (withdrawAmount > 0) {
                    unchecked {
                        // Overflow not possible: withdrawAmount is less than or equal to balances[baseAssetIndex]
                        // nosemgrep: solidity.performance.state-variable-read-in-a-loop.state-variable-read-in-a-loop
                        self.basketBalanceOf[basket][baseAsset] = baseAssetBalance - withdrawAmount;
                    }
                    // slither-disable-next-line reentrancy-no-eth
                    IERC20(baseAsset).forceApprove(basket, withdrawAmount);
                }
                // ERC20.transferFrom is called in BasketToken.fulfillRedeem
                // slither-disable-next-line reentrancy-no-eth
                BasketToken(basket).fulfillRedeem(withdrawAmount);
            }
            unchecked {
                // Overflow not possible: i is less than baskets.length
                ++i;
            }
        }
        // slither-disable-end calls-loop
    }

    /// @notice Internal function to complete proposed token swaps.
    /// @param self BasketManagerStorage struct containing strategy data.
    /// @param externalTrades Array of external trades to be completed.
    /// @return claimedAmounts amounts claimed from the completed token swaps
    function _completeTokenSwap(
        BasketManagerStorage storage self,
        ExternalTrade[] calldata externalTrades
    )
        private
        returns (uint256[2][] memory claimedAmounts)
    {
        // solhint-disable avoid-low-level-calls
        // slither-disable-next-line low-level-calls
        (bool success, bytes memory data) =
            self.tokenSwapAdapter.delegatecall(abi.encodeCall(TokenSwapAdapter.completeTokenSwap, (externalTrades)));
        // solhint-enable avoid-low-level-calls
        if (!success) {
            // assume this low-level call never fails
            revert CompleteTokenSwapFailed();
        }
        claimedAmounts = abi.decode(data, (uint256[2][]));
    }

    /// @notice Internal function to update internal accounting with result of completed token swaps.
    /// @param self BasketManagerStorage struct containing strategy data.
    /// @param externalTrades Array of external trades to be completed.
    function _processExternalTrades(
        BasketManagerStorage storage self,
        ExternalTrade[] calldata externalTrades
    )
        private
    {
        uint256 externalTradesLength = externalTrades.length;
        uint256[2][] memory claimedAmounts = _completeTokenSwap(self, externalTrades);
        // Update basketBalanceOf with amounts gained from swaps
        for (uint256 i = 0; i < externalTradesLength;) {
            ExternalTrade calldata trade = externalTrades[i];
            // nosemgrep: solidity.performance.array-length-outside-loop.array-length-outside-loop
            uint256 tradeOwnershipLength = trade.basketTradeOwnership.length;
            uint256 remainingSellTokenAmount = claimedAmounts[i][0];
            uint256 remainingBuyTokenAmount = claimedAmounts[i][1];
            uint256 remainingSellAmount = trade.sellAmount;

            for (uint256 j; j < tradeOwnershipLength;) {
                BasketTradeOwnership calldata ownership = trade.basketTradeOwnership[j];

                // Get basket balances mapping for this ownership
                mapping(address => uint256) storage basketBalanceOf = self.basketBalanceOf[ownership.basket];

                if (j == tradeOwnershipLength - 1) {
                    // Last ownership gets remaining amounts
                    basketBalanceOf[trade.buyToken] += remainingBuyTokenAmount;
                    basketBalanceOf[trade.sellToken] =
                        basketBalanceOf[trade.sellToken] + remainingSellTokenAmount - remainingSellAmount;
                } else {
                    // Calculate ownership portions
                    uint256 buyTokenAmount =
                        FixedPointMathLib.fullMulDiv(claimedAmounts[i][1], ownership.tradeOwnership, _WEIGHT_PRECISION);
                    uint256 sellTokenAmount =
                        FixedPointMathLib.fullMulDiv(claimedAmounts[i][0], ownership.tradeOwnership, _WEIGHT_PRECISION);
                    uint256 sellAmount =
                        FixedPointMathLib.fullMulDiv(trade.sellAmount, ownership.tradeOwnership, _WEIGHT_PRECISION);

                    // Update balances
                    basketBalanceOf[trade.buyToken] += buyTokenAmount;
                    basketBalanceOf[trade.sellToken] = basketBalanceOf[trade.sellToken] + sellTokenAmount - sellAmount;

                    // Track remaining amounts
                    remainingBuyTokenAmount -= buyTokenAmount;
                    remainingSellTokenAmount -= sellTokenAmount;
                    remainingSellAmount -= sellAmount;
                }
                unchecked {
                    // Overflow not possible: i is less than tradeOwnerShipLength.length
                    ++j;
                }
            }
            unchecked {
                // Overflow not possible: i is less than externalTradesLength.length
                ++i;
            }
        }
    }

    /// @notice Internal function to initialize basket data.
    /// @param self BasketManagerStorage struct containing strategy data.
    /// @param baskets Array of basket addresses currently being rebalanced.
    /// @param basketAssets An array of arrays of basket assets.
    /// @param slot A Slot struct containing the basket balances and total values.
    function _initializeBasketData(
        BasketManagerStorage storage self,
        EulerRouter eulerRouter,
        address[] calldata baskets,
        address[][] calldata basketAssets,
        BasketContext memory slot
    )
        private
        view
    {
        uint256 numBaskets = baskets.length;
        for (uint256 i = 0; i < numBaskets;) {
            address[] calldata assets = basketAssets[i];
            // nosemgrep: solidity.performance.array-length-outside-loop.array-length-outside-loop
            uint256 assetsLength = assets.length;
            slot.basketBalances[i] = new uint256[](assetsLength);
            // Create a storage mapping reference for the current basket's balances
            mapping(address => uint256) storage basketBalanceOf = self.basketBalanceOf[baskets[i]];
            for (uint256 j = 0; j < assetsLength;) {
                address asset = assets[j];
                // nosemgrep: solidity.performance.state-variable-read-in-a-loop.state-variable-read-in-a-loop
                uint256 currentAssetAmount = basketBalanceOf[asset];
                slot.basketBalances[i][j] = currentAssetAmount;
                if (currentAssetAmount > 0) {
                    // nosemgrep: solidity.performance.state-variable-read-in-a-loop.state-variable-read-in-a-loop
                    slot.totalValues[i] += eulerRouter.getQuote(currentAssetAmount, asset, _USD_ISO_4217_CODE);
                }
                unchecked {
                    // Overflow not possible: j is less than assetsLength
                    ++j;
                }
            }
            unchecked {
                // Overflow not possible: i is less than numBaskets
                ++i;
            }
        }
    }

    /// @notice Internal function to settle internal trades.
    /// @param self BasketManagerStorage struct containing strategy data.
    /// @param internalTrades Array of internal trades to execute.
    /// @param baskets Array of basket addresses currently being rebalanced.
    /// @param slot A Slot struct containing the basket balances and total values.
    /// @dev If the result of an internal trade is not within the provided minAmount or maxAmount, this function will
    /// revert.
    function _processInternalTrades(
        BasketManagerStorage storage self,
        EulerRouter eulerRouter,
        InternalTrade[] calldata internalTrades,
        address[] calldata baskets,
        BasketContext memory slot
    )
        private
    {
        uint256 swapFee = self.swapFee; // Fetch swapFee once for gas optimization
        uint256 internalTradesLength = internalTrades.length;
        for (uint256 i = 0; i < internalTradesLength;) {
            InternalTrade calldata trade = internalTrades[i];
            if (trade.sellAmount == 0) {
                revert InternalTradeSellAmountZero();
            }
            InternalTradeInfo memory info = InternalTradeInfo({
                fromBasketIndex: _indexOf(baskets, trade.fromBasket),
                toBasketIndex: _indexOf(baskets, trade.toBasket),
                sellTokenAssetIndex: getAssetIndexInBasket(self, trade.fromBasket, trade.sellToken),
                buyTokenAssetIndex: getAssetIndexInBasket(self, trade.fromBasket, trade.buyToken),
                toBasketBuyTokenIndex: getAssetIndexInBasket(self, trade.toBasket, trade.buyToken),
                toBasketSellTokenIndex: getAssetIndexInBasket(self, trade.toBasket, trade.sellToken),
                netBuyAmount: 0,
                netSellAmount: 0,
                feeOnBuy: 0,
                feeOnSell: 0,
                sellValue: eulerRouter.getQuote(trade.sellAmount, trade.sellToken, _USD_ISO_4217_CODE),
                feeValue: 0
            });
            uint256 initialBuyAmount = 0;
            if (info.sellValue > 0) {
                initialBuyAmount = eulerRouter.getQuote(info.sellValue, _USD_ISO_4217_CODE, trade.buyToken);
            }
            // Calculate fee on sellAmount
            if (swapFee > 0) {
                info.feeOnSell = FixedPointMathLib.fullMulDiv(trade.sellAmount, swapFee, 20_000);
                info.feeValue = FixedPointMathLib.fullMulDiv(info.sellValue, swapFee, 20_000);
                slot.totalValues[info.fromBasketIndex] -= info.feeValue;
                self.collectedSwapFees[trade.sellToken] += info.feeOnSell;
                emit SwapFeeCharged(trade.sellToken, info.feeOnSell);

                info.feeOnBuy = FixedPointMathLib.fullMulDiv(initialBuyAmount, swapFee, 20_000);
                slot.totalValues[info.toBasketIndex] -= info.feeValue;
                self.collectedSwapFees[trade.buyToken] += info.feeOnBuy;
                emit SwapFeeCharged(trade.buyToken, info.feeOnBuy);
            }
            info.netSellAmount = trade.sellAmount - info.feeOnSell;
            info.netBuyAmount = initialBuyAmount - info.feeOnBuy;

            if (info.netBuyAmount < trade.minAmount || trade.maxAmount < initialBuyAmount) {
                revert InternalTradeMinMaxAmountNotReached();
            }
            if (trade.sellAmount > slot.basketBalances[info.fromBasketIndex][info.sellTokenAssetIndex]) {
                revert IncorrectTradeTokenAmount();
            }
            if (initialBuyAmount > slot.basketBalances[info.toBasketIndex][info.toBasketBuyTokenIndex]) {
                revert IncorrectTradeTokenAmount();
            }

            // Settle the internal trades and track the balance changes.
            // nosemgrep: solidity.performance.state-variable-read-in-a-loop.state-variable-read-in-a-loop
            self.basketBalanceOf[trade.fromBasket][trade.sellToken] =
                slot.basketBalances[info.fromBasketIndex][info.sellTokenAssetIndex] -= trade.sellAmount; // nosemgrep
            // nosemgrep: solidity.performance.state-variable-read-in-a-loop.state-variable-read-in-a-loop
            self.basketBalanceOf[trade.fromBasket][trade.buyToken] =
                slot.basketBalances[info.fromBasketIndex][info.buyTokenAssetIndex] += info.netBuyAmount; // nosemgrep
            // nosemgrep: solidity.performance.state-variable-read-in-a-loop.state-variable-read-in-a-loop
            self.basketBalanceOf[trade.toBasket][trade.buyToken] =
                slot.basketBalances[info.toBasketIndex][info.toBasketBuyTokenIndex] -= initialBuyAmount; // nosemgrep
            // nosemgrep: solidity.performance.state-variable-read-in-a-loop.state-variable-read-in-a-loop
            self.basketBalanceOf[trade.toBasket][trade.sellToken] =
                slot.basketBalances[info.toBasketIndex][info.toBasketSellTokenIndex] += info.netSellAmount; // nosemgrep
            unchecked {
                // Overflow not possible: i is less than internalTradesLength and internalTradesLength cannot be near
                // the maximum value of uint256 due to gas limits
                ++i;
            }
            emit InternalTradeSettled(trade, info.netBuyAmount);
        }
    }

    /// @notice Internal function to validate the results of external trades.
    /// @param self BasketManagerStorage struct containing strategy data.
    /// @param externalTrades Array of external trades to be validated.
    /// @param baskets Array of basket addresses currently being rebalanced.
    /// @param slot A Slot struct containing the basket balances and total values.
    /// @dev If the result of an external trade is not within the slippageLimit threshold of the minAmount, this
    /// function will revert. If the sum of the trade ownerships is not equal to _WEIGHT_PRECISION, this function will
    /// revert.
    function _validateExternalTrades(
        BasketManagerStorage storage self,
        EulerRouter eulerRouter,
        ExternalTrade[] calldata externalTrades,
        address[] calldata baskets,
        BasketContext memory slot
    )
        private
        view
    {
        uint256 slippageLimit = self.slippageLimit;
        for (uint256 i = 0; i < externalTrades.length;) {
            ExternalTrade calldata trade = externalTrades[i];
            if (trade.sellAmount == 0) {
                revert ExternalTradeSellAmountZero();
            }
            uint256 ownershipSum = 0;
            // nosemgrep: solidity.performance.array-length-outside-loop.array-length-outside-loop
            for (uint256 j = 0; j < trade.basketTradeOwnership.length;) {
                BasketTradeOwnership calldata ownership = trade.basketTradeOwnership[j];
                ownershipSum += ownership.tradeOwnership;
                uint256 basketIndex = _indexOf(baskets, ownership.basket);
                uint256 buyTokenAssetIndex = getAssetIndexInBasket(self, ownership.basket, trade.buyToken);
                uint256 sellTokenAssetIndex = getAssetIndexInBasket(self, ownership.basket, trade.sellToken);
                uint256 ownershipSellAmount =
                    FixedPointMathLib.fullMulDiv(trade.sellAmount, ownership.tradeOwnership, _WEIGHT_PRECISION);
                uint256 ownershipBuyAmount =
                    FixedPointMathLib.fullMulDiv(trade.minAmount, ownership.tradeOwnership, _WEIGHT_PRECISION);
                // Record changes in basket asset holdings due to the external trade
                if (ownershipSellAmount > slot.basketBalances[basketIndex][sellTokenAssetIndex]) {
                    revert IncorrectTradeTokenAmount();
                }
                // solhint-disable-next-line max-line-length
                slot.basketBalances[basketIndex][sellTokenAssetIndex] =
                    slot.basketBalances[basketIndex][sellTokenAssetIndex] - ownershipSellAmount;
                slot.basketBalances[basketIndex][buyTokenAssetIndex] =
                    slot.basketBalances[basketIndex][buyTokenAssetIndex] + ownershipBuyAmount;
                // Update total basket value
                slot.totalValues[basketIndex] = slot.totalValues[basketIndex]
                // nosemgrep: solidity.performance.state-variable-read-in-a-loop.state-variable-read-in-a-loop
                - eulerRouter.getQuote(ownershipSellAmount, trade.sellToken, _USD_ISO_4217_CODE)
                // nosemgrep: solidity.performance.state-variable-read-in-a-loop.state-variable-read-in-a-loop
                + eulerRouter.getQuote(ownershipBuyAmount, trade.buyToken, _USD_ISO_4217_CODE);
                unchecked {
                    // Overflow not possible: j is bounded by trade.basketTradeOwnership.length
                    ++j;
                }
            }
            if (ownershipSum != _WEIGHT_PRECISION) {
                revert OwnershipSumMismatch();
            }
            // nosemgrep: solidity.performance.state-variable-read-in-a-loop.state-variable-read-in-a-loop
            uint256 internalMinAmount = eulerRouter.getQuote(
                eulerRouter.getQuote(trade.sellAmount, trade.sellToken, _USD_ISO_4217_CODE),
                _USD_ISO_4217_CODE,
                trade.buyToken
            );

            // Check if the given minAmount is within the slippageLimit threshold of internalMinAmount
            if (
                FixedPointMathLib.fullMulDiv(
                    MathUtils.diff(internalMinAmount, trade.minAmount), _WEIGHT_PRECISION, internalMinAmount
                ) > slippageLimit
            ) {
                revert ExternalTradeSlippage();
            }

            unchecked {
                // Overflow not possible: i is bounded by baskets.length
                ++i;
            }
        }
    }

    /// @notice Validate the basket hash based on the given baskets and target weights.
    function _validateBasketHash(
        BasketManagerStorage storage self,
        address[] calldata baskets,
        uint64[][] calldata basketsTargetWeights,
        address[][] calldata basketAssets
    )
        private
        view
    {
        // Validate the calldata hashes
        bytes32 basketHash = keccak256(abi.encode(baskets, basketsTargetWeights, basketAssets));
        if (self.rebalanceStatus.basketHash != basketHash) {
            revert BasketsMismatch();
        }
        // Check that the length matches
        if (baskets.length != basketsTargetWeights.length || baskets.length != basketAssets.length) {
            revert BasketsMismatch();
        }
    }

    /// @notice Checks if weight deviations after trades are within the acceptable weightDeviationLimit threshold.
    /// Returns true if all deviations are within bounds for each asset in every basket.
    /// @param self BasketManagerStorage struct containing strategy data.
    /// @param baskets Array of basket addresses currently being rebalanced.
    /// @param basketsTargetWeights Array of target weights for each basket.
    /// @param basketAssets Array of assets in each basket.
    /// @param slot A Slot struct containing the basket balances and total values.
    function _isTargetWeightMet(
        BasketManagerStorage storage self,
        EulerRouter eulerRouter,
        address[] calldata baskets,
        uint64[][] calldata basketsTargetWeights,
        address[][] calldata basketAssets,
        BasketContext memory slot
    )
        private
        view
        returns (bool)
    {
        // Check if total weight change due to all trades is within the weightDeviationLimit threshold
        uint256 len = baskets.length;
        uint256 weightDeviationLimit = self.weightDeviationLimit;
        for (uint256 i = 0; i < len;) {
            // slither-disable-next-line calls-loop
            uint64[] calldata proposedTargetWeights = basketsTargetWeights[i];
            // nosemgrep: solidity.performance.array-length-outside-loop.array-length-outside-loop
            uint256 numOfAssets = proposedTargetWeights.length;
            uint64[] memory adjustedTargetWeights = new uint64[](numOfAssets);

            // Calculate adjusted target weights accounting for pending redeems
            uint256 pendingRedeems = self.pendingRedeems[baskets[i]];
            if (pendingRedeems > 0) {
                uint256 totalSupply = BasketToken(baskets[i]).totalSupply();
                uint256 remainingSupply = totalSupply - pendingRedeems;

                // Get base asset index
                uint256 baseAssetIndex = self.basketTokenToBaseAssetIndexPlusOne[baskets[i]] - 1;

                // Track running sum for all weights except the last one
                uint256 runningSum = 0;
                uint256 lastIndex = numOfAssets - 1;

                // Adjust weights while maintaining 1e18 sum
                for (uint256 j = 0; j < numOfAssets;) {
                    if (j == lastIndex) {
                        // Use remainder for the last weight to ensure exact 1e18 sum
                        adjustedTargetWeights[j] = uint64(_WEIGHT_PRECISION - runningSum);
                    } else {
                        if (j == baseAssetIndex) {
                            // Increase base asset weight by adding extra weight from pending redeems
                            adjustedTargetWeights[j] = uint64(
                                FixedPointMathLib.fullMulDiv(
                                    FixedPointMathLib.fullMulDiv(
                                        remainingSupply, proposedTargetWeights[j], _WEIGHT_PRECISION
                                    ) + pendingRedeems,
                                    _WEIGHT_PRECISION,
                                    totalSupply
                                )
                            );
                            runningSum += adjustedTargetWeights[j];
                        } else {
                            // Scale down other weights proportionally
                            adjustedTargetWeights[j] = uint64(
                                FixedPointMathLib.fullMulDiv(remainingSupply, proposedTargetWeights[j], totalSupply)
                            );
                            runningSum += adjustedTargetWeights[j];
                        }
                    }
                    unchecked {
                        ++j;
                    }
                }
            } else {
                // If no pending redeems, use original target weights
                adjustedTargetWeights = proposedTargetWeights;
            }
            // nosemgrep: solidity.performance.state-variable-read-in-a-loop.state-variable-read-in-a-loop
            address[] calldata assets = basketAssets[i];
            // nosemgrep: solidity.performance.array-length-outside-loop.array-length-outside-loop
            uint256 proposedTargetWeightsLength = proposedTargetWeights.length;
            for (uint256 j = 0; j < proposedTargetWeightsLength;) {
                // If the total value of the basket is 0, we can't calculate the weight.
                // So we assume the target weight is met.
                if (slot.totalValues[i] != 0) {
                    uint256 assetValueInUSD = 0;
                    if (slot.basketBalances[i][j] > 0) {
                        // nosemgrep: solidity.performance.state-variable-read-in-a-loop.state-variable-read-in-a-loop
                        assetValueInUSD = eulerRouter.getQuote(slot.basketBalances[i][j], assets[j], _USD_ISO_4217_CODE);
                    }
                    // Rounding direction: down
                    uint256 afterTradeWeight =
                        FixedPointMathLib.fullMulDiv(assetValueInUSD, _WEIGHT_PRECISION, slot.totalValues[i]);
                    if (MathUtils.diff(adjustedTargetWeights[j], afterTradeWeight) > weightDeviationLimit) {
                        return false;
                    }
                }
                unchecked {
                    // Overflow not possible: j is bounded by proposedTargetWeightsLength
                    ++j;
                }
            }
            unchecked {
                // Overflow not possible: i is bounded by len
                ++i;
            }
        }
        return true;
    }

    /// @notice Internal function to process pending deposits and fulfill them.
    /// @dev Assumes pendingDeposit is not 0.
    /// @param self BasketManagerStorage struct containing strategy data.
    /// @param basket Basket token address.
    /// @param basketValue Current value of the basket in USD.
    /// @param baseAssetBalance Current balance of the base asset in the basket.
    /// @param pendingDeposit Current assets pending deposit in the given basket.
    /// @return newShares Amount of new shares minted.
    /// @return pendingDepositValue Value of the pending deposits in USD.
    // slither-disable-next-line calls-loop
    function _processPendingDeposits(
        BasketManagerStorage storage self,
        EulerRouter eulerRouter,
        address basket,
        uint256 totalSupply,
        uint256 basketValue,
        uint256 baseAssetBalance,
        uint256 pendingDeposit,
        address baseAssetAddress
    )
        private
        returns (uint256 newShares, uint256 pendingDepositValue)
    {
        // Assume the first asset listed in the basket is the base asset
        // Round direction: down
        // nosemgrep: solidity.performance.state-variable-read-in-a-loop.state-variable-read-in-a-loop
        pendingDepositValue = eulerRouter.getQuote(pendingDeposit, baseAssetAddress, _USD_ISO_4217_CODE);
        // Rounding direction: down
        // Division-by-zero is not possible: basketValue is greater than 0
        newShares = basketValue > 0
            ? FixedPointMathLib.fullMulDiv(pendingDepositValue, totalSupply, basketValue)
            : pendingDepositValue;
        if (newShares > 0) {
            // Add the deposit to the basket balance if newShares is positive
            // nosemgrep: solidity.performance.state-variable-read-in-a-loop.state-variable-read-in-a-loop
            self.basketBalanceOf[basket][baseAssetAddress] = baseAssetBalance + pendingDeposit;
        } else {
            // If newShares is 0, set pendingDepositValue to 0 to indicate rejected deposit, no deposit is minted
            pendingDepositValue = 0;
        }
        // slither-disable-next-line reentrancy-no-eth,reentrancy-benign
        BasketToken(basket).fulfillDeposit(newShares);
    }

    /// @notice Internal function to calculate the current value of all assets in a given basket.
    /// @param self BasketManagerStorage struct containing strategy data.
    /// @param basket Basket token address.
    /// @param assets Array of asset addresses in the basket.
    /// @return balances Array of balances of each asset in the basket.
    /// @return basketValue Current value of the basket in USD.
    // slither-disable-next-line calls-loop
    function _calculateBasketValue(
        BasketManagerStorage storage self,
        EulerRouter eulerRouter,
        address basket,
        address[] memory assets
    )
        private
        view
        returns (uint256[] memory balances, uint256 basketValue)
    {
        uint256 assetsLength = assets.length;
        balances = new uint256[](assetsLength);
        for (uint256 j = 0; j < assetsLength;) {
            // nosemgrep: solidity.performance.state-variable-read-in-a-loop.state-variable-read-in-a-loop
            balances[j] = self.basketBalanceOf[basket][assets[j]];
            // Rounding direction: down
            // nosemgrep: solidity.performance.state-variable-read-in-a-loop.state-variable-read-in-a-loop
            if (balances[j] > 0) {
                // nosemgrep: solidity.performance.state-variable-read-in-a-loop.state-variable-read-in-a-loop
                basketValue += eulerRouter.getQuote(balances[j], assets[j], _USD_ISO_4217_CODE);
            }
            unchecked {
                // Overflow not possible: j is less than assetsLength
                ++j;
            }
        }
    }

    /// @notice Internal function to store the index of the base asset for a given basket. Reverts if the base asset is
    /// not present in the basket's assets.
    /// @param self BasketManagerStorage struct containing strategy data.
    /// @param basket Basket token address.
    /// @param assets Array of asset addresses in the basket.
    /// @param baseAsset Base asset address.
    /// @dev If the base asset is not present in the basket, this function will revert.
    function _setBaseAssetIndex(
        BasketManagerStorage storage self,
        address basket,
        address[] memory assets,
        address baseAsset
    )
        private
    {
        uint256 len = assets.length;
        for (uint256 i = 0; i < len;) {
            if (assets[i] == baseAsset) {
                self.basketTokenToBaseAssetIndexPlusOne[basket] = i + 1;
                return;
            }
            unchecked {
                // Overflow not possible: i is less than len
                ++i;
            }
        }
        revert BaseAssetMismatch();
    }

    /// @notice Internal function to create a bitmask for baskets being rebalanced.
    /// @param self BasketManagerStorage struct containing strategy data.
    /// @param baskets Array of basket addresses currently being rebalanced.
    /// @return basketMask Bitmask for baskets being rebalanced.
    /// @dev A bitmask like 00000011 indicates that the first two baskets are being rebalanced.
    function _createRebalanceBitMask(
        BasketManagerStorage storage self,
        address[] memory baskets
    )
        private
        view
        returns (uint256 basketMask)
    {
        // Create the bitmask for baskets being rebalanced
        basketMask = 0;
        uint256 len = baskets.length;
        for (uint256 i = 0; i < len;) {
            uint256 indexPlusOne = self.basketTokenToIndexPlusOne[baskets[i]];
            if (indexPlusOne == 0) {
                revert BasketTokenNotFound();
            }
            basketMask |= (1 << indexPlusOne - 1);
            unchecked {
                // Overflow not possible: i is less than len
                ++i;
            }
        }
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

library BitFlag {
    // Bit masks used in the popCount algorithm
    // Binary: ...0101 0101 0101 0101
    uint256 private constant MASK_ODD_BITS = 0x5555555555555555555555555555555555555555555555555555555555555555;
    // Binary: ...0011 0011 0011 0011
    uint256 private constant MASK_EVEN_PAIRS = 0x3333333333333333333333333333333333333333333333333333333333333333;
    // Binary: ...0000 1111 0000 1111
    uint256 private constant MASK_NIBBLES = 0x0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F;
    // Binary: ...0000 0001 0000 0001
    uint256 private constant BYTE_MULTIPLIER = 0x0101010101010101010101010101010101010101010101010101010101010101;

    /// @dev Counts the number of set bits in a bit flag using parallel counting.
    /// This algorithm is based on the "Counting bits set, in parallel" technique from:
    /// https://graphics.stanford.edu/~seander/bithacks.html#CountBitsSetParallel
    /// @param bitFlag The bit flag to count the number of set bits.
    /// @return count The number of set bits in the bit flag.
    function popCount(uint256 bitFlag) internal pure returns (uint256) {
        // The unchecked block is safe from overflow/underflow because:
        // 1. Each step only involves bitwise operations and additions, which can't overflow uint256.
        // 2. The maximum possible value of bitFlag is 2^256-1, which can be safely multiplied by BYTE_MULTIPLIER.
        // 3. The final result is always in the range [0, 256], so the right shift by 248 bits can't underflow.
        unchecked {
            // Optimization: If all bits are set, return 256 immediately
            if (bitFlag == type(uint256).max) {
                return 256;
            }

            // Step 1: Count bits in pairs
            // This step counts the number of set bits in each pair of bits
            // by subtracting the number of odd bits from the original count
            // Each result is stored in 2-bit chunks within the uint256
            bitFlag -= ((bitFlag >> 1) & MASK_ODD_BITS);

            // Step 2: Count bits in groups of 4
            // This step sums the counts of set bits in each group of 4 bits
            // Each result is stored in 4-bit chunks within the uint256
            bitFlag = (bitFlag & MASK_EVEN_PAIRS) + ((bitFlag >> 2) & MASK_EVEN_PAIRS);

            // Step 3: Sum nibbles (4-bit groups)
            // This step sums the counts from step 2 for each byte (8 bits)
            // Each result is stored in 8-bit chunks within the uint256
            bitFlag = (bitFlag + (bitFlag >> 4)) & MASK_NIBBLES;

            // Step 4: Sum all bytes and return final count
            // Multiply by BYTE_MULTIPLIER to sum all byte counts
            // Shift right by 248 (256 - 8) to get the final sum in the least significant byte
            return (bitFlag * BYTE_MULTIPLIER) >> 248;
        }
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

/// @title MathUtils
/// @notice A library to perform math operations with optimizations.
/// @dev This library is based on the code snippet from the OpenZeppelin Contracts Math library.
// solhint-disable-next-line max-line-length
/// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/05d4bf57ffed8c65256ff4ede5c3cf7a0b738e7d/contracts/utils/math/Math.sol
library MathUtils {
    /// @notice Calculates the absolute difference between two unsigned integers.
    /// @param a The first number.
    /// @param b The second number.
    /// @return The absolute difference between `a` and `b`.
    function diff(uint256 a, uint256 b) internal pure returns (uint256) {
        unchecked {
            // Safe from overflow/underflow: result is always less than larger input.
            return a > b ? a - b : b - a;
        }
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import { AccessControlEnumerable } from "@openzeppelin/contracts/access/extensions/AccessControlEnumerable.sol";

import { WeightStrategy } from "src/strategies/WeightStrategy.sol";

/// @title StrategyRegistry
/// @notice A registry for weight strategies that allows checking if a strategy supports a specific bit flag.
/// @dev Inherits from AccessControlEnumerable for role-based access control.
/// Roles:
/// - DEFAULT_ADMIN_ROLE: The default role given to an address at creation. Can grant and revoke roles.
/// - WEIGHT_STRATEGY_ROLE: Role given to approved weight strategys.
contract StrategyRegistry is AccessControlEnumerable {
    /// @dev Role identifier for weight strategys
    bytes32 private constant _WEIGHT_STRATEGY_ROLE = keccak256("WEIGHT_STRATEGY_ROLE");

    /// @notice Error thrown when an unsupported strategy is used
    error StrategyNotSupported();

    /// @notice Constructs the StrategyRegistry contract
    /// @param admin The address that will be granted the DEFAULT_ADMIN_ROLE
    // slither-disable-next-line locked-ether
    constructor(address admin) payable {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
    }

    /// @notice Checks if a given weight strategy supports a specific bit flag
    /// @param bitFlag The bit flag to check support for
    /// @param weightStrategy The address of the weight strategy to check
    /// @return bool True if the strategy supports the bit flag, false otherwise
    function supportsBitFlag(uint256 bitFlag, address weightStrategy) external view returns (bool) {
        if (!hasRole(_WEIGHT_STRATEGY_ROLE, weightStrategy)) {
            revert StrategyNotSupported();
        }
        return WeightStrategy(weightStrategy).supportsBitFlag(bitFlag);
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

/// @title WeightStrategy
/// @notice Abstract contract for weight strategies that determine the target weights of assets in a basket.
/// @dev This contract should be implemented by strategies that provide specific logic for calculating target weights.
/// Use cases include:
/// - `AutomaticWeightStrategy.sol`: Calculates weights based on external market data or other on-chain data sources.
/// - `ManagedWeightStrategy.sol`: Allows manual setting of target weights by an authorized manager.
/// The sum of the weights returned by `getTargetWeights` should be 1e18.
abstract contract WeightStrategy {
    /// @notice Returns the target weights for the assets in the basket that the rebalancing process aims to achieve.
    /// @param bitFlag The bit flag representing a list of assets.
    /// @return targetWeights The target weights of the assets in the basket. The weights should sum to 1e18.
    function getTargetWeights(uint256 bitFlag) public view virtual returns (uint64[] memory targetWeights);

    /// @notice Checks whether the strategy supports the given bit flag, representing a list of assets.
    /// @param bitFlag The bit flag representing a list of assets.
    /// @return supported A boolean indicating whether the strategy supports the given bit flag.
    function supportsBitFlag(uint256 bitFlag) public view virtual returns (bool supported);
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import { ExternalTrade } from "src/types/Trades.sol";

/// @title TokenSwapAdapter
/// @notice Abstract contract for token swap adapters
abstract contract TokenSwapAdapter {
    /// @notice Executes series of token swaps and returns the hashes of the orders submitted/executed
    /// @param externalTrades The external trades to execute
    function executeTokenSwap(ExternalTrade[] calldata externalTrades, bytes calldata data) external payable virtual;

    /// @notice Completes the token swaps by confirming each order settlement and claiming the resulting tokens (if
    /// necessary).
    /// @dev This function must return the exact amounts of sell tokens and buy tokens claimed per trade.
    /// If the adapter operates asynchronously (e.g., CoWSwap), this function should handle the following:
    /// - Cancel any unsettled trades to prevent further execution.
    /// - Claim the remaining tokens from the unsettled trades.
    ///
    /// @param externalTrades The external trades that were executed and need to be settled.
    /// @return claimedAmounts A 2D array where each element contains the claimed amounts of sell tokens and buy tokens
    /// for each corresponding trade in `externalTrades`. The first element of each sub-array is the claimed sell
    /// amount, and the second element is the claimed buy amount.
    function completeTokenSwap(ExternalTrade[] calldata externalTrades)
        external
        payable
        virtual
        returns (uint256[2][] memory claimedAmounts);
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import { EulerRouter } from "euler-price-oracle/src/EulerRouter.sol";

import { StrategyRegistry } from "src/strategies/StrategyRegistry.sol";

/// @notice Enum representing the status of a rebalance.
enum Status {
    // Rebalance has not started.
    NOT_STARTED,
    // Rebalance has been proposed.
    REBALANCE_PROPOSED,
    // Token swap has been proposed.
    TOKEN_SWAP_PROPOSED,
    // Token swap has been executed.
    TOKEN_SWAP_EXECUTED
}

/// @notice Struct representing the rebalance status.
struct RebalanceStatus {
    // Hash of the baskets and the target weights of them proposed for rebalance.
    bytes32 basketHash;
    // Bitmask representing baskets currently being rebalanced.
    uint256 basketMask;
    // Epoch of the rebalance.
    uint40 epoch;
    // Timestamp of the rebalance proposal.
    uint40 proposalTimestamp;
    // Timestamp of the last action.
    uint40 timestamp;
    // The number of retries for the current rebalance epoch.
    uint8 retryCount;
    // Status of the rebalance.
    Status status;
}

/// @notice Struct representing the storage of the BasketManager contract.
struct BasketManagerStorage {
    /// @notice Address of the StrategyRegistry contract used to resolve and verify basket target weights.
    StrategyRegistry strategyRegistry;
    /// @notice Address of the EulerRouter contract used to fetch oracle quotes for swaps.
    EulerRouter eulerRouter;
    /// @notice Asset registry contract.
    address assetRegistry;
    /// @notice Address of the FeeCollector contract responsible for receiving management fees.
    /// Swap fees are directed to the protocol treasury via feeCollector.protocolTreasury().
    address feeCollector;
    /// @notice The current management fee, expressed in basis points, applied to the total value of each basket token
    /// for a given basket  address.
    mapping(address => uint16) managementFees;
    /// @notice The current swap fee, expressed in basis points, applied to the value of internal swaps.
    uint16 swapFee;
    /// @notice Maximum slippage multiplier for token swaps, denominated in 1e18.
    uint256 slippageLimit;
    /// @notice Maximum deviation multiplier to determine if a set of balances has reached the desired target weights,
    /// denominated in 1e18.
    uint256 weightDeviationLimit;
    /// @notice Address of the BasketToken implementation.
    address basketTokenImplementation;
    /// @notice Array of all basket tokens.
    address[] basketTokens;
    /// @notice Mapping of basket token to asset to balance.
    mapping(address basketToken => mapping(address asset => uint256 balance)) basketBalanceOf;
    /// @notice Mapping of basketId to basket address.
    mapping(bytes32 basketId => address basketToken) basketIdToAddress;
    /// @notice Mapping of basket token to assets.
    mapping(address basketToken => address[] basketAssets) basketAssets;
    /// @notice Mapping of basket token to basket asset to index plus one. 0 means the basket asset does not exist.
    mapping(address basketToken => mapping(address basketAsset => uint256 indexPlusOne)) basketAssetToIndexPlusOne;
    /// @notice Mapping of basket token to index plus one. 0 means the basket token does not exist.
    mapping(address basketToken => uint256 indexPlusOne) basketTokenToIndexPlusOne;
    /// @notice Mapping of basket token to pending redeeming shares.
    mapping(address basketToken => uint256 pendingRedeems) pendingRedeems;
    /// @notice Mapping of asset to collected swap fees.
    mapping(address asset => uint256 fees) collectedSwapFees;
    /// @notice Mapping of basket token to base asset index plus one. 0 means the base asset does not exist.
    mapping(address basket => uint256 indexPlusOne) basketTokenToBaseAssetIndexPlusOne;
    /// @notice Rebalance status.
    RebalanceStatus rebalanceStatus;
    /// @notice A hash of the latest external trades stored during proposeTokenSwap
    bytes32 externalTradesHash;
    /// @notice Address of the token swap adapter.
    address tokenSwapAdapter;
    /// @notice The maximum number of retries for a rebalance epoch.
    uint8 retryLimit;
    /// @notice The minimum time between rebalances.
    uint40 stepDelay;
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

/// @notice Struct containing data for an internal trade.
struct InternalTrade {
    // Address of the basket that is selling.
    address fromBasket;
    // Address of the token to sell.
    address sellToken;
    // Address of the token to buy.
    address buyToken;
    // Address of the basket that is buying.
    address toBasket;
    // Amount of the token to sell.
    uint256 sellAmount;
    // Minimum amount of the buy token that the trade results in. Used to check that the proposers oracle prices
    // are correct.
    uint256 minAmount;
    // Maximum amount of the buy token that the trade can result in.
    uint256 maxAmount;
}

/// @notice Struct containing data for an external trade.
struct ExternalTrade {
    // Address of the token to sell.
    address sellToken;
    // Address of the token to buy.
    address buyToken;
    // Amount of the token to sell.
    uint256 sellAmount;
    // Minimum amount of the buy token that the trade results in.
    uint256 minAmount;
    // Array of basket trade ownerships.
    BasketTradeOwnership[] basketTradeOwnership;
}

/// @notice Struct representing a baskets ownership of an external trade.
struct BasketTradeOwnership {
    // Address of the basket.
    address basket;
    // Ownership of the trade with a base of 1e18. An ownershipe of 1e18 means the basket owns the entire trade.
    uint96 tradeOwnership;
}