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
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC1363.sol)

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
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC20Metadata.sol)

pragma solidity ^0.8.20;

import {IERC20Metadata} from "../token/ERC20/extensions/IERC20Metadata.sol";
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC4626.sol)

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
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/draft-IERC6093.sol)
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
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.20;

import {IERC20} from "./IERC20.sol";
import {IERC20Metadata} from "./extensions/IERC20Metadata.sol";
import {Context} from "../../utils/Context.sol";
import {IERC20Errors} from "../../interfaces/draft-IERC6093.sol";

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
abstract contract ERC20 is Context, IERC20, IERC20Metadata, IERC20Errors {
    mapping(address account => uint256) private _balances;

    mapping(address account => mapping(address spender => uint256)) private _allowances;

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
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
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
    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
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
        return _allowances[owner][spender];
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
        if (from == address(0)) {
            // Overflow check required: The rest of the code assumes that totalSupply never overflows
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                // Overflow not possible: value <= fromBalance <= totalSupply.
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                // Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
                _totalSupply -= value;
            }
        } else {
            unchecked {
                // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
                _balances[to] += value;
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
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        _allowances[owner][spender] = value;
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
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

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
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/ERC20Wrapper.sol)

pragma solidity ^0.8.20;

import {IERC20, IERC20Metadata, ERC20} from "../ERC20.sol";
import {SafeERC20} from "../utils/SafeERC20.sol";

/**
 * @dev Extension of the ERC-20 token contract to support token wrapping.
 *
 * Users can deposit and withdraw "underlying tokens" and receive a matching number of "wrapped tokens". This is useful
 * in conjunction with other modules. For example, combining this wrapping mechanism with {ERC20Votes} will allow the
 * wrapping of an existing "basic" ERC-20 into a governance token.
 *
 * WARNING: Any mechanism in which the underlying token changes the {balanceOf} of an account without an explicit transfer
 * may desynchronize this contract's supply and its underlying balance. Please exercise caution when wrapping tokens that
 * may undercollateralize the wrapper (i.e. wrapper's total supply is higher than its underlying balance). See {_recover}
 * for recovering value accrued to the wrapper.
 */
abstract contract ERC20Wrapper is ERC20 {
    IERC20 private immutable _underlying;

    /**
     * @dev The underlying token couldn't be wrapped.
     */
    error ERC20InvalidUnderlying(address token);

    constructor(IERC20 underlyingToken) {
        if (underlyingToken == this) {
            revert ERC20InvalidUnderlying(address(this));
        }
        _underlying = underlyingToken;
    }

    /**
     * @dev See {ERC20-decimals}.
     */
    function decimals() public view virtual override returns (uint8) {
        try IERC20Metadata(address(_underlying)).decimals() returns (uint8 value) {
            return value;
        } catch {
            return super.decimals();
        }
    }

    /**
     * @dev Returns the address of the underlying ERC-20 token that is being wrapped.
     */
    function underlying() public view returns (IERC20) {
        return _underlying;
    }

    /**
     * @dev Allow a user to deposit underlying tokens and mint the corresponding number of wrapped tokens.
     */
    function depositFor(address account, uint256 value) public virtual returns (bool) {
        address sender = _msgSender();
        if (sender == address(this)) {
            revert ERC20InvalidSender(address(this));
        }
        if (account == address(this)) {
            revert ERC20InvalidReceiver(account);
        }
        SafeERC20.safeTransferFrom(_underlying, sender, address(this), value);
        _mint(account, value);
        return true;
    }

    /**
     * @dev Allow a user to burn a number of wrapped tokens and withdraw the corresponding number of underlying tokens.
     */
    function withdrawTo(address account, uint256 value) public virtual returns (bool) {
        if (account == address(this)) {
            revert ERC20InvalidReceiver(account);
        }
        _burn(_msgSender(), value);
        SafeERC20.safeTransfer(_underlying, account, value);
        return true;
    }

    /**
     * @dev Mint wrapped token to cover any underlyingTokens that would have been transferred by mistake or acquired from
     * rebasing mechanisms. Internal function that can be exposed with access control if desired.
     */
    function _recover(address account) internal virtual returns (uint256) {
        uint256 value = _underlying.balanceOf(address(this)) - totalSupply();
        _mint(account, value);
        return value;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/ERC4626.sol)

pragma solidity ^0.8.20;

import {IERC20, IERC20Metadata, ERC20} from "../ERC20.sol";
import {SafeERC20} from "../utils/SafeERC20.sol";
import {IERC4626} from "../../../interfaces/IERC4626.sol";
import {Math} from "../../../utils/math/Math.sol";

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
abstract contract ERC4626 is ERC20, IERC4626 {
    using Math for uint256;

    IERC20 private immutable _asset;
    uint8 private immutable _underlyingDecimals;

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
    constructor(IERC20 asset_) {
        (bool success, uint8 assetDecimals) = _tryGetAssetDecimals(asset_);
        _underlyingDecimals = success ? assetDecimals : 18;
        _asset = asset_;
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
    function decimals() public view virtual override(IERC20Metadata, ERC20) returns (uint8) {
        return _underlyingDecimals + _decimalsOffset();
    }

    /** @dev See {IERC4626-asset}. */
    function asset() public view virtual returns (address) {
        return address(_asset);
    }

    /** @dev See {IERC4626-totalAssets}. */
    function totalAssets() public view virtual returns (uint256) {
        return _asset.balanceOf(address(this));
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
        // If _asset is ERC-777, `transferFrom` can trigger a reentrancy BEFORE the transfer happens through the
        // `tokensToSend` hook. On the other hand, the `tokenReceived` hook, that is triggered after the transfer,
        // calls the vault, which is assumed not malicious.
        //
        // Conclusion: we need to do the transfer before we mint so that any reentrancy would happen before the
        // assets are transferred and before the shares are minted, which is a valid state.
        // slither-disable-next-line reentrancy-no-eth
        SafeERC20.safeTransferFrom(_asset, caller, address(this), assets);
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
        SafeERC20.safeTransfer(_asset, receiver, assets);

        emit Withdraw(caller, receiver, owner, assets, shares);
    }

    function _decimalsOffset() internal view virtual returns (uint8) {
        return 0;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Metadata.sol)

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
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/utils/SafeERC20.sol)

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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Address.sol)

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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/introspection/ERC165.sol)

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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/introspection/IERC165.sol)

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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/Math.sol)

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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/SafeCast.sol)
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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/structs/EnumerableSet.sol)
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
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import {IAccessControlErrors} from "../interfaces/IAccessControlErrors.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title LimitedAccessControl
 * @dev This contract extends OpenZeppelin's AccessControl, disabling direct role granting and revoking.
 * It's designed to be used as a base contract for more specific access control implementations.
 * @dev This contract overrides the grantRole and revokeRole functions from AccessControl to disable direct role
 * granting and revoking.
 * @dev It doesn't override the renounceRole function, so it can be used to renounce roles for compromised accounts.
 */
abstract contract LimitedAccessControl is AccessControl, IAccessControlErrors {
    /**
     * @dev Overrides the grantRole function from AccessControl to disable direct role granting.
     * @notice This function always reverts with a DirectGrantIsDisabled error.
     */
    function grantRole(bytes32, address) public view override {
        revert DirectGrantIsDisabled(msg.sender);
    }

    /**
     * @dev Overrides the revokeRole function from AccessControl to disable direct role revoking.
     * @notice This function always reverts with a DirectRevokeIsDisabled error.
     */
    function revokeRole(bytes32, address) public view override {
        revert DirectRevokeIsDisabled(msg.sender);
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import {IAccessControlErrors} from "../interfaces/IAccessControlErrors.sol";
import {ContractSpecificRoles, IProtocolAccessManager} from "../interfaces/IProtocolAccessManager.sol";
import {ProtocolAccessManager} from "./ProtocolAccessManager.sol";

import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/**
 * @title ProtocolAccessManaged
 * @notice This contract provides role-based access control functionality for protocol contracts
 * by interfacing with a central ProtocolAccessManager.
 *
 * @dev This contract is meant to be inherited by other protocol contracts that need
 * role-based access control. It provides modifiers and utilities to check various roles.
 *
 * The contract supports several key roles through modifiers:
 * 1. GOVERNOR_ROLE: System-wide administrators
 * 2. KEEPER_ROLE: Routine maintenance operators (contract-specific)
 * 3. SUPER_KEEPER_ROLE: Advanced maintenance operators (global)
 * 4. CURATOR_ROLE: Fleet-specific managers
 * 5. GUARDIAN_ROLE: Emergency response operators
 * 6. DECAY_CONTROLLER_ROLE: Specific role for decay management
 * 7. ADMIRALS_QUARTERS_ROLE: Specific role for admirals quarters bundler contract
 *
 * Usage:
 * - Inherit from this contract to gain access to role-checking modifiers
 * - Use modifiers like onlyGovernor, onlyKeeper, etc. to protect functions
 * - Access the internal _accessManager to perform custom role checks
 *
 * Security Considerations:
 * - The contract validates the access manager address during construction
 * - All role checks are performed against the immutable access manager instance
 * - Contract-specific roles are generated using the contract's address to prevent conflicts
 */
contract ProtocolAccessManaged is IAccessControlErrors, Context {
    /*//////////////////////////////////////////////////////////////
                                CONSTANTS
    //////////////////////////////////////////////////////////////*/

    /// @notice Role identifier for protocol governors - highest privilege level with admin capabilities
    bytes32 public constant GOVERNOR_ROLE = keccak256("GOVERNOR_ROLE");

    /// @notice Role identifier for super keepers who can globally perform fleet maintanence roles
    bytes32 public constant SUPER_KEEPER_ROLE = keccak256("SUPER_KEEPER_ROLE");

    /**
     * @notice Role identifier for protocol guardians
     * @dev Guardians have emergency powers across multiple protocol components:
     * - Can pause/unpause Fleet operations for security
     * - Can pause/unpause TipJar operations
     * - Can cancel governance proposals on SummerGovernor even if they don't meet normal cancellation requirements
     * - Can cancel TipJar proposals
     *
     * The guardian role serves as an emergency backstop to protect the protocol, but with less
     * privilege than governors.
     */
    bytes32 public constant GUARDIAN_ROLE = keccak256("GUARDIAN_ROLE");

    /**
     * @notice Role identifier for decay controller
     * @dev This role allows the decay controller to manage the decay of user voting power
     */
    bytes32 public constant DECAY_CONTROLLER_ROLE =
        keccak256("DECAY_CONTROLLER_ROLE");

    /**
     * @notice Role identifier for admirals quarters bundler contract
     * @dev This role allows Admirals Quarters to unstake and withdraw assets from fleets, on behalf of users
     * @dev Withdrawn tokens go straight to users wallet, lowering the risk of manipulation if the role is compromised
     */
    bytes32 public constant ADMIRALS_QUARTERS_ROLE =
        keccak256("ADMIRALS_QUARTERS_ROLE");

    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/

    /// @notice The ProtocolAccessManager instance used for access control
    ProtocolAccessManager internal immutable _accessManager;

    /*//////////////////////////////////////////////////////////////
                                CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Initializes the ProtocolAccessManaged contract
     * @param accessManager Address of the ProtocolAccessManager contract
     * @dev Validates the provided accessManager address and initializes the _accessManager
     */
    constructor(address accessManager) {
        if (accessManager == address(0)) {
            revert InvalidAccessManagerAddress(address(0));
        }

        if (
            !IERC165(accessManager).supportsInterface(
                type(IProtocolAccessManager).interfaceId
            )
        ) {
            revert InvalidAccessManagerAddress(accessManager);
        }

        _accessManager = ProtocolAccessManager(accessManager);
    }

    /*//////////////////////////////////////////////////////////////
                                MODIFIERS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Modifier to restrict access to governors only
     *
     * @dev Modifier to check that the caller has the Governor role
     * @custom:internal-logic
     * - Checks if the caller has the GOVERNOR_ROLE in the access manager
     * @custom:effects
     * - Reverts if the caller doesn't have the GOVERNOR_ROLE
     * - Allows the function to proceed if the caller has the role
     * @custom:security-considerations
     * - Ensures that only authorized governors can access critical functions
     * - Relies on the correct setup of the access manager
     */
    modifier onlyGovernor() {
        if (!_accessManager.hasRole(GOVERNOR_ROLE, msg.sender)) {
            revert CallerIsNotGovernor(msg.sender);
        }
        _;
    }

    /**
     * @notice Modifier to restrict access to keepers only
     * @dev Modifier to check that the caller has the Keeper role
     * @custom:internal-logic
     * - Checks if the caller has either the contract-specific KEEPER_ROLE or the SUPER_KEEPER_ROLE
     * @custom:effects
     * - Reverts if the caller doesn't have either of the required roles
     * - Allows the function to proceed if the caller has one of the roles
     * @custom:security-considerations
     * - Ensures that only authorized keepers can access maintenance functions
     * - Allows for both contract-specific and super keepers
     * @custom:gas-considerations
     * - Performs two role checks, which may impact gas usage
     */
    modifier onlyKeeper() {
        if (
            !_accessManager.hasRole(
                generateRole(ContractSpecificRoles.KEEPER_ROLE, address(this)),
                msg.sender
            ) && !_accessManager.hasRole(SUPER_KEEPER_ROLE, msg.sender)
        ) {
            revert CallerIsNotKeeper(msg.sender);
        }
        _;
    }

    /**
     * @notice Modifier to restrict access to super keepers only
     * @dev Modifier to check that the caller has the Super Keeper role
     * @custom:internal-logic
     * - Checks if the caller has the SUPER_KEEPER_ROLE in the access manager
     * @custom:effects
     * - Reverts if the caller doesn't have the SUPER_KEEPER_ROLE
     * - Allows the function to proceed if the caller has the role
     * @custom:security-considerations
     * - Ensures that only authorized super keepers can access advanced maintenance functions
     * - Relies on the correct setup of the access manager
     */
    modifier onlySuperKeeper() {
        if (!_accessManager.hasRole(SUPER_KEEPER_ROLE, msg.sender)) {
            revert CallerIsNotSuperKeeper(msg.sender);
        }
        _;
    }

    /**
     * @notice Modifier to restrict access to curators only
     * @param fleetAddress The address of the fleet to check the curator role for
     * @dev Checks if the caller has the contract-specific CURATOR_ROLE
     */
    modifier onlyCurator(address fleetAddress) {
        if (
            fleetAddress == address(0) ||
            !_accessManager.hasRole(
                generateRole(ContractSpecificRoles.CURATOR_ROLE, fleetAddress),
                msg.sender
            )
        ) {
            revert CallerIsNotCurator(msg.sender);
        }
        _;
    }

    /**
     * @notice Modifier to restrict access to guardians only
     * @dev Modifier to check that the caller has the Guardian role
     * @custom:internal-logic
     * - Checks if the caller has the GUARDIAN_ROLE in the access manager
     * @custom:effects
     * - Reverts if the caller doesn't have the GUARDIAN_ROLE
     * - Allows the function to proceed if the caller has the role
     * @custom:security-considerations
     * - Ensures that only authorized guardians can access emergency functions
     * - Relies on the correct setup of the access manager
     */
    modifier onlyGuardian() {
        if (!_accessManager.hasRole(GUARDIAN_ROLE, msg.sender)) {
            revert CallerIsNotGuardian(msg.sender);
        }
        _;
    }

    /**
     * @notice Modifier to restrict access to either guardians or governors
     * @dev Modifier to check that the caller has either the Guardian or Governor role
     * @custom:internal-logic
     * - Checks if the caller has either the GUARDIAN_ROLE or the GOVERNOR_ROLE
     * @custom:effects
     * - Reverts if the caller doesn't have either of the required roles
     * - Allows the function to proceed if the caller has one of the roles
     * @custom:security-considerations
     * - Ensures that only authorized guardians or governors can access certain functions
     * - Provides flexibility for functions that can be accessed by either role
     * @custom:gas-considerations
     * - Performs two role checks, which may impact gas usage
     */
    modifier onlyGuardianOrGovernor() {
        if (
            !_accessManager.hasRole(GUARDIAN_ROLE, msg.sender) &&
            !_accessManager.hasRole(GOVERNOR_ROLE, msg.sender)
        ) {
            revert CallerIsNotGuardianOrGovernor(msg.sender);
        }
        _;
    }

    /**
     * @notice Modifier to restrict access to decay controllers only
     */
    modifier onlyDecayController() {
        if (!_accessManager.hasRole(DECAY_CONTROLLER_ROLE, msg.sender)) {
            revert CallerIsNotDecayController(msg.sender);
        }
        _;
    }

    /**
     * @notice Modifier to restrict access to foundation only
     * @dev Modifier to check that the caller has the Foundation role
     * @custom:security-considerations
     * - Ensures that only the Foundation can access vesting and related functions
     * - Relies on the correct setup of the access manager
     */
    modifier onlyFoundation() {
        if (
            !_accessManager.hasRole(
                _accessManager.FOUNDATION_ROLE(),
                msg.sender
            )
        ) {
            revert CallerIsNotFoundation(msg.sender);
        }
        _;
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Generates a role identifier for a specific contract and role
     * @param roleName The name of the role
     * @param roleTargetContract The address of the contract the role is for
     * @return The generated role identifier
     * @dev This function is used to create unique role identifiers for contract-specific roles
     */
    function generateRole(
        ContractSpecificRoles roleName,
        address roleTargetContract
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(roleName, roleTargetContract));
    }

    /**
     * @notice Checks if an account has the Admirals Quarters role
     * @param account The address to check
     * @return bool True if the account has the Admirals Quarters role
     */
    function hasAdmiralsQuartersRole(
        address account
    ) public view returns (bool) {
        return _accessManager.hasRole(ADMIRALS_QUARTERS_ROLE, account);
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Helper function to check if an address has the Governor role
     * @param account The address to check
     * @return bool True if the address has the Governor role
     */
    function _isGovernor(address account) internal view returns (bool) {
        return _accessManager.hasRole(GOVERNOR_ROLE, account);
    }

    function _isDecayController(address account) internal view returns (bool) {
        return _accessManager.hasRole(DECAY_CONTROLLER_ROLE, account);
    }

    /**
     * @notice Helper function to check if an address has the Foundation role
     * @param account The address to check
     * @return bool True if the address has the Foundation role
     */
    function _isFoundation(address account) internal view returns (bool) {
        return
            _accessManager.hasRole(_accessManager.FOUNDATION_ROLE(), account);
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import {ContractSpecificRoles, IProtocolAccessManager} from "../interfaces/IProtocolAccessManager.sol";
import {LimitedAccessControl} from "./LimitedAccessControl.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title ProtocolAccessManager
 * @notice This contract is the central authority for access control within the protocol.
 * It defines and manages various roles that govern different aspects of the system.
 *
 * @dev This contract extends LimitedAccessControl, which restricts direct role management.
 * Roles are typically assigned during deployment or through governance proposals.
 *
 * The contract defines four main roles:
 * 1. GOVERNOR_ROLE: System-wide administrators
 * 2. KEEPER_ROLE: Routine maintenance operators
 * 3. SUPER_KEEPER_ROLE: Advanced maintenance operators
 * 4. COMMANDER_ROLE: Managers of specific protocol components (Arks)
 * 5. ADMIRALS_QUARTERS_ROLE: Specific role for admirals quarters bundler contract
 * Role Hierarchy and Management:
 * - The GOVERNOR_ROLE is at the top of the hierarchy and can manage all other roles.
 * - Other roles cannot manage roles directly due to LimitedAccessControl restrictions.
 * - Role assignments are typically done through governance proposals or during initial setup.
 *
 * Usage in the System:
 * - Other contracts in the system inherit from ProtocolAccessManaged, which checks permissions
 *   against this ProtocolAccessManager.
 * - Critical functions in various contracts are protected by role-based modifiers
 *   (e.g., onlyGovernor, onlyKeeper, etc.) which query this contract for permissions.
 *
 * Security Considerations:
 * - The GOVERNOR_ROLE has significant power and should be managed carefully, potentially
 *   through a multi-sig wallet or governance contract.
 * - The SUPER_KEEPER_ROLE has elevated privileges and should be assigned judiciously.
 * - The COMMANDER_ROLE is not directly manageable through this contract but is used
 *   in other parts of the system for specific access control.
 */
contract ProtocolAccessManager is IProtocolAccessManager, LimitedAccessControl {
    /*//////////////////////////////////////////////////////////////
                                CONSTANTS
    //////////////////////////////////////////////////////////////*/

    /// @notice Role identifier for protocol governors - highest privilege level with admin capabilities
    bytes32 public constant GOVERNOR_ROLE = keccak256("GOVERNOR_ROLE");

    /// @notice Role identifier for super keepers who can globally perform fleet maintanence roles
    bytes32 public constant SUPER_KEEPER_ROLE = keccak256("SUPER_KEEPER_ROLE");

    /**
     * @notice Role identifier for protocol guardians
     * @dev Guardians have emergency powers across multiple protocol components:
     * - Can pause/unpause Fleet operations for security
     * - Can pause/unpause TipJar operations
     * - Can cancel governance proposals on SummerGovernor even if they don't meet normal cancellation requirements
     * - Can cancel TipJar proposals
     *
     * The guardian role serves as an emergency backstop to protect the protocol, but with less
     * privilege than governors.
     */
    bytes32 public constant GUARDIAN_ROLE = keccak256("GUARDIAN_ROLE");

    /**
     * @notice Role identifier for decay controller
     * @dev This role allows the decay controller to manage the decay of user voting power
     */
    bytes32 public constant DECAY_CONTROLLER_ROLE =
        keccak256("DECAY_CONTROLLER_ROLE");

    /**
     * @notice Role identifier for admirals quarters bundler contract
     * @dev This role allows Admirals Quarters to unstake and withdraw assets from fleets, on behalf of users
     * @dev Withdrawn tokens go straight to users wallet, lowering the risk of manipulation if the role is compromised
     */
    bytes32 public constant ADMIRALS_QUARTERS_ROLE =
        keccak256("ADMIRALS_QUARTERS_ROLE");

    /// @notice Minimum allowed guardian expiration period (7 days)
    uint256 public constant MIN_GUARDIAN_EXPIRY = 7 days;

    /// @notice Maximum allowed guardian expiration period (180 days)
    uint256 public constant MAX_GUARDIAN_EXPIRY = 180 days;

    /// @notice Role identifier for the Foundation which manages vesting wallets and related operations
    bytes32 public constant FOUNDATION_ROLE = keccak256("FOUNDATION_ROLE");

    /*//////////////////////////////////////////////////////////////
                                CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Initializes the ProtocolAccessManager contract
     * @param governor Address of the initial governor
     * @dev Grants the governor address the GOVERNOR_ROLE
     */
    constructor(address governor) {
        _grantRole(GOVERNOR_ROLE, governor);
    }

    /**
     * @dev Modifier to check that the caller has the Governor role
     */
    modifier onlyGovernor() {
        if (!hasRole(GOVERNOR_ROLE, msg.sender)) {
            revert CallerIsNotGovernor(msg.sender);
        }
        _;
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Checks if the contract supports a given interface
     * @dev Overrides the supportsInterface function from AccessControl
     * @param interfaceId The interface identifier, as specified in ERC-165
     * @return bool True if the contract supports the interface, false otherwise
     *
     * This function supports:
     * - IProtocolAccessManager interface
     * - All interfaces supported by the parent AccessControl contract
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view override returns (bool) {
        return
            interfaceId == type(IProtocolAccessManager).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /// @inheritdoc IProtocolAccessManager
    function grantGovernorRole(address account) external onlyGovernor {
        _grantRole(GOVERNOR_ROLE, account);
    }

    /// @inheritdoc IProtocolAccessManager
    function revokeGovernorRole(address account) external onlyGovernor {
        _revokeRole(GOVERNOR_ROLE, account);
    }

    /*//////////////////////////////////////////////////////////////
                        EXTERNAL GOVERNOR FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IProtocolAccessManager
    function grantSuperKeeperRole(address account) external onlyGovernor {
        _grantRole(SUPER_KEEPER_ROLE, account);
    }

    /// @inheritdoc IProtocolAccessManager
    function grantGuardianRole(address account) external onlyGovernor {
        _grantRole(GUARDIAN_ROLE, account);
    }

    /// @inheritdoc IProtocolAccessManager
    function revokeGuardianRole(address account) external onlyGovernor {
        _revokeRole(GUARDIAN_ROLE, account);
    }

    /// @inheritdoc IProtocolAccessManager
    function revokeSuperKeeperRole(address account) external onlyGovernor {
        _revokeRole(SUPER_KEEPER_ROLE, account);
    }

    /// @inheritdoc IProtocolAccessManager
    function grantContractSpecificRole(
        ContractSpecificRoles roleName,
        address roleTargetContract,
        address roleOwner
    ) public onlyGovernor {
        bytes32 role = generateRole(roleName, roleTargetContract);
        _grantRole(role, roleOwner);
    }

    /// @inheritdoc IProtocolAccessManager
    function revokeContractSpecificRole(
        ContractSpecificRoles roleName,
        address roleTargetContract,
        address roleOwner
    ) public onlyGovernor {
        bytes32 role = generateRole(roleName, roleTargetContract);
        _revokeRole(role, roleOwner);
    }

    /// @inheritdoc IProtocolAccessManager
    function grantCuratorRole(
        address fleetCommanderAddress,
        address account
    ) public onlyGovernor {
        grantContractSpecificRole(
            ContractSpecificRoles.CURATOR_ROLE,
            fleetCommanderAddress,
            account
        );
    }

    /// @inheritdoc IProtocolAccessManager
    function revokeCuratorRole(
        address fleetCommanderAddress,
        address account
    ) public onlyGovernor {
        revokeContractSpecificRole(
            ContractSpecificRoles.CURATOR_ROLE,
            fleetCommanderAddress,
            account
        );
    }

    /// @inheritdoc IProtocolAccessManager
    function grantKeeperRole(
        address fleetCommanderAddress,
        address account
    ) public onlyGovernor {
        grantContractSpecificRole(
            ContractSpecificRoles.KEEPER_ROLE,
            fleetCommanderAddress,
            account
        );
    }

    /// @inheritdoc IProtocolAccessManager
    function revokeKeeperRole(
        address fleetCommanderAddress,
        address account
    ) public onlyGovernor {
        revokeContractSpecificRole(
            ContractSpecificRoles.KEEPER_ROLE,
            fleetCommanderAddress,
            account
        );
    }

    /// @inheritdoc IProtocolAccessManager
    function grantCommanderRole(
        address arkAddress,
        address account
    ) public onlyGovernor {
        grantContractSpecificRole(
            ContractSpecificRoles.COMMANDER_ROLE,
            arkAddress,
            account
        );
    }

    /// @inheritdoc IProtocolAccessManager
    function revokeCommanderRole(
        address arkAddress,
        address account
    ) public onlyGovernor {
        revokeContractSpecificRole(
            ContractSpecificRoles.COMMANDER_ROLE,
            arkAddress,
            account
        );
    }

    /// @inheritdoc IProtocolAccessManager
    function grantDecayControllerRole(address account) public onlyGovernor {
        _grantRole(DECAY_CONTROLLER_ROLE, account);
    }

    /// @inheritdoc IProtocolAccessManager
    function revokeDecayControllerRole(address account) public onlyGovernor {
        _revokeRole(DECAY_CONTROLLER_ROLE, account);
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IProtocolAccessManager
    function selfRevokeContractSpecificRole(
        ContractSpecificRoles roleName,
        address roleTargetContract
    ) public {
        bytes32 role = generateRole(roleName, roleTargetContract);
        if (!hasRole(role, msg.sender)) {
            revert CallerIsNotContractSpecificRole(msg.sender, role);
        }
        _revokeRole(role, msg.sender);
    }

    /// @inheritdoc IProtocolAccessManager
    function generateRole(
        ContractSpecificRoles roleName,
        address roleTargetContract
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(roleName, roleTargetContract));
    }

    /// @inheritdoc IProtocolAccessManager
    function grantAdmiralsQuartersRole(
        address account
    ) external onlyRole(GOVERNOR_ROLE) {
        _grantRole(ADMIRALS_QUARTERS_ROLE, account);
    }

    /// @inheritdoc IProtocolAccessManager
    function revokeAdmiralsQuartersRole(
        address account
    ) external onlyRole(GOVERNOR_ROLE) {
        _revokeRole(ADMIRALS_QUARTERS_ROLE, account);
    }

    mapping(address guardian => uint256 expirationTimestamp)
        public guardianExpirations;

    /**
     * @notice Checks if an account is an active guardian (has role and not expired)
     * @param account Address to check
     * @return bool True if account is an active guardian
     */
    function isActiveGuardian(address account) public view returns (bool) {
        return
            hasRole(GUARDIAN_ROLE, account) &&
            guardianExpirations[account] > block.timestamp;
    }

    /**
     * @notice Sets the expiration timestamp for a guardian
     * @param account Guardian address
     * @param expiration Timestamp when guardian powers expire
     * @dev The expiration period (time from now until expiration) must be between MIN_GUARDIAN_EXPIRY and MAX_GUARDIAN_EXPIRY
     * This ensures guardians can't be immediately removed (protecting against malicious proposals) while still
     * allowing for their eventual phase-out (protecting against malicious guardians)
     */
    function setGuardianExpiration(
        address account,
        uint256 expiration
    ) external onlyRole(GOVERNOR_ROLE) {
        if (!hasRole(GUARDIAN_ROLE, account)) {
            revert CallerIsNotGuardian(account);
        }

        uint256 expiryPeriod = expiration - block.timestamp;
        if (
            expiryPeriod < MIN_GUARDIAN_EXPIRY ||
            expiryPeriod > MAX_GUARDIAN_EXPIRY
        ) {
            revert InvalidGuardianExpiryPeriod(
                expiryPeriod,
                MIN_GUARDIAN_EXPIRY,
                MAX_GUARDIAN_EXPIRY
            );
        }

        guardianExpirations[account] = expiration;
        emit GuardianExpirationSet(account, expiration);
    }

    /**
     * @inheritdoc IProtocolAccessManager
     */
    function hasRole(
        bytes32 role,
        address account
    )
        public
        view
        virtual
        override(IProtocolAccessManager, AccessControl)
        returns (bool)
    {
        return super.hasRole(role, account);
    }

    /// @inheritdoc IProtocolAccessManager
    function getGuardianExpiration(
        address account
    ) external view returns (uint256 expiration) {
        if (!hasRole(GUARDIAN_ROLE, account)) {
            revert CallerIsNotGuardian(account);
        }
        return guardianExpirations[account];
    }

    /// @inheritdoc IProtocolAccessManager
    function grantFoundationRole(address account) external onlyGovernor {
        _grantRole(FOUNDATION_ROLE, account);
    }

    /// @inheritdoc IProtocolAccessManager
    function revokeFoundationRole(address account) external onlyGovernor {
        _revokeRole(FOUNDATION_ROLE, account);
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

/**
 * @title IAccessControlErrors
 * @dev This file contains custom error definitions for access control in the system.
 * @notice These custom errors provide more gas-efficient and informative error handling
 * compared to traditional require statements with string messages.
 */
interface IAccessControlErrors {
    /**
     * @notice Thrown when a caller does not have the required role.
     */
    error CallerIsNotContractSpecificRole(address caller, bytes32 role);

    /**
     * @notice Thrown when a caller is not the curator.
     */
    error CallerIsNotCurator(address caller);

    /**
     * @notice Thrown when a caller is not the governor.
     */
    error CallerIsNotGovernor(address caller);

    /**
     * @notice Thrown when a caller is not a keeper.
     */
    error CallerIsNotKeeper(address caller);

    /**
     * @notice Thrown when a caller is not a super keeper.
     */
    error CallerIsNotSuperKeeper(address caller);

    /**
     * @notice Thrown when a caller is not the commander.
     */
    error CallerIsNotCommander(address caller);

    /**
     * @notice Thrown when a caller is neither the Raft nor the commander.
     */
    error CallerIsNotRaftOrCommander(address caller);

    /**
     * @notice Thrown when a caller is not the Raft.
     */
    error CallerIsNotRaft(address caller);

    /**
     * @notice Thrown when a caller is not an admin.
     */
    error CallerIsNotAdmin(address caller);

    /**
     * @notice Thrown when a caller is not the guardian.
     */
    error CallerIsNotGuardian(address caller);

    /**
     * @notice Thrown when a caller is not the guardian or governor.
     */
    error CallerIsNotGuardianOrGovernor(address caller);

    /**
     * @notice Thrown when a caller is not the decay controller.
     */
    error CallerIsNotDecayController(address caller);

    /**
     * @notice Thrown when a caller is not authorized to board.
     */
    error CallerIsNotAuthorizedToBoard(address caller);

    /**
     * @notice Thrown when direct grant is disabled.
     */
    error DirectGrantIsDisabled(address caller);

    /**
     * @notice Thrown when direct revoke is disabled.
     */
    error DirectRevokeIsDisabled(address caller);

    /**
     * @notice Thrown when an invalid access manager address is provided.
     */
    error InvalidAccessManagerAddress(address invalidAddress);

    /**
     * @notice Error thrown when a caller is not the Foundation
     * @param caller The address that attempted the operation
     */
    error CallerIsNotFoundation(address caller);
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @dev Dynamic roles are roles that are not hardcoded in the contract but are defined by the protocol
 * Members of this enum are treated as prefixes to the role generated using prefix and target contract address
 * e.g generateRole(ContractSpecificRoles.CURATOR_ROLE, address(this)) for FleetCommander, to generate the CURATOR_ROLE
 * for the curator of the FleetCommander contract
 */
enum ContractSpecificRoles {
    CURATOR_ROLE,
    KEEPER_ROLE,
    COMMANDER_ROLE
}

/**
 * @title IProtocolAccessManager
 * @notice Defines system roles and provides role based remote-access control for
 *         contracts that inherit from ProtocolAccessManaged contract
 */
interface IProtocolAccessManager {
    /**
     * @notice Grants the Governor role to a given account
     *
     * @param account The account to which the Governor role will be granted
     */
    function grantGovernorRole(address account) external;

    /**
     * @notice Revokes the Governor role from a given account
     *
     * @param account The account from which the Governor role will be revoked
     */
    function revokeGovernorRole(address account) external;

    /**
     * @notice Grants the Super Keeper role to a given account
     *
     * @param account The account to which the Super Keeper role will be granted
     */
    function grantSuperKeeperRole(address account) external;

    /**
     * @notice Revokes the Super Keeper role from a given account
     *
     * @param account The account from which the Super Keeper role will be revoked
     */
    function revokeSuperKeeperRole(address account) external;

    /**
     * @dev Generates a unique role identifier based on the role name and target contract address
     * @param roleName The name of the role (from ContractSpecificRoles enum)
     * @param roleTargetContract The address of the contract the role is for
     * @return bytes32 The generated role identifier
     * @custom:internal-logic
     * - Combines the roleName and roleTargetContract using abi.encodePacked
     * - Applies keccak256 hash function to generate a unique bytes32 identifier
     * @custom:effects
     * - Does not modify any state, pure function
     * @custom:security-considerations
     * - Ensures unique role identifiers for different contracts
     * - Relies on the uniqueness of contract addresses and role names
     */
    function generateRole(
        ContractSpecificRoles roleName,
        address roleTargetContract
    ) external pure returns (bytes32);

    /**
     * @notice Grants a contract specific role to a given account
     * @param roleName The name of the role to grant
     * @param roleTargetContract The address of the contract to grant the role for
     * @param account The account to which the role will be granted
     */
    function grantContractSpecificRole(
        ContractSpecificRoles roleName,
        address roleTargetContract,
        address account
    ) external;

    /**
     * @notice Revokes a contract specific role from a given account
     * @param roleName The name of the role to revoke
     * @param roleTargetContract The address of the contract to revoke the role for
     * @param account The account from which the role will be revoked
     */
    function revokeContractSpecificRole(
        ContractSpecificRoles roleName,
        address roleTargetContract,
        address account
    ) external;

    /**
     * @notice Grants the Curator role to a given account
     * @param fleetCommanderAddress The address of the fleet commander to grant the role for
     * @param account The account to which the role will be granted
     */
    function grantCuratorRole(
        address fleetCommanderAddress,
        address account
    ) external;

    /**
     * @notice Revokes the Curator role from a given account
     * @param fleetCommanderAddress The address of the fleet commander to revoke the role for
     * @param account The account from which the role will be revoked
     */
    function revokeCuratorRole(
        address fleetCommanderAddress,
        address account
    ) external;

    /**
     * @notice Grants the Keeper role to a given account
     * @param fleetCommanderAddress The address of the fleet commander to grant the role for
     * @param account The account to which the role will be granted
     */
    function grantKeeperRole(
        address fleetCommanderAddress,
        address account
    ) external;

    /**
     * @notice Revokes the Keeper role from a given account
     * @param fleetCommanderAddress The address of the fleet commander to revoke the role for
     * @param account The account from which the role will be revoked
     */
    function revokeKeeperRole(
        address fleetCommanderAddress,
        address account
    ) external;

    /**
     * @notice Grants the Commander role for a specific Ark
     * @param arkAddress Address of the Ark contract
     * @param account Address to grant the Commander role to
     */
    function grantCommanderRole(address arkAddress, address account) external;

    /**
     * @notice Revokes the Commander role for a specific Ark
     * @param arkAddress Address of the Ark contract
     * @param account Address to revoke the Commander role from
     */
    function revokeCommanderRole(address arkAddress, address account) external;

    /**
     * @notice Revokes a contract specific role from the caller
     * @param roleName The name of the role to revoke
     * @param roleTargetContract The address of the contract to revoke the role for
     */
    function selfRevokeContractSpecificRole(
        ContractSpecificRoles roleName,
        address roleTargetContract
    ) external;

    /**
     * @notice Grants the Guardian role to a given account
     *
     * @param account The account to which the Guardian role will be granted
     */
    function grantGuardianRole(address account) external;

    /**
     * @notice Revokes the Guardian role from a given account
     *
     * @param account The account from which the Guardian role will be revoked
     */
    function revokeGuardianRole(address account) external;

    /**
     * @notice Grants the Decay Controller role to a given account
     * @param account The account to which the Decay Controller role will be granted
     */
    function grantDecayControllerRole(address account) external;

    /**
     * @notice Revokes the Decay Controller role from a given account
     * @param account The account from which the Decay Controller role will be revoked
     */
    function revokeDecayControllerRole(address account) external;

    /**
     * @notice Grants the ADMIRALS_QUARTERS_ROLE to an address
     * @param account The address to grant the role to
     */
    function grantAdmiralsQuartersRole(address account) external;

    /**
     * @notice Revokes the ADMIRALS_QUARTERS_ROLE from an address
     * @param account The address to revoke the role from
     */
    function revokeAdmiralsQuartersRole(address account) external;

    /*//////////////////////////////////////////////////////////////
                            ROLE CONSTANTS
    //////////////////////////////////////////////////////////////*/

    /// @notice Role identifier for the Governor role
    function GOVERNOR_ROLE() external pure returns (bytes32);

    /// @notice Role identifier for the Guardian role
    function GUARDIAN_ROLE() external pure returns (bytes32);

    /// @notice Role identifier for the Super Keeper role
    function SUPER_KEEPER_ROLE() external pure returns (bytes32);

    /// @notice Role identifier for the Decay Controller role
    function DECAY_CONTROLLER_ROLE() external pure returns (bytes32);

    /// @notice Role identifier for the Admirals Quarters role
    function ADMIRALS_QUARTERS_ROLE() external pure returns (bytes32);

    /// @notice Role identifier for the Foundation, responsible for managing vesting wallets and related operations
    function FOUNDATION_ROLE() external pure returns (bytes32);

    /**
     * @notice Checks if an account has a specific role
     * @param role The role identifier to check
     * @param account The account to check the role for
     * @return bool True if the account has the role, false otherwise
     */
    function hasRole(
        bytes32 role,
        address account
    ) external view returns (bool);

    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Emitted when a guardian's expiration is set
     * @param account The address of the guardian
     * @param expiration The timestamp until which the guardian powers are valid
     */
    event GuardianExpirationSet(address indexed account, uint256 expiration);

    /*//////////////////////////////////////////////////////////////
                            GUARDIAN FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Checks if an account is an active guardian (has role and not expired)
     * @param account Address to check
     * @return bool True if account is an active guardian
     */
    function isActiveGuardian(address account) external view returns (bool);

    /**
     * @notice Sets the expiration timestamp for a guardian
     * @param account Guardian address
     * @param expiration Timestamp when guardian powers expire
     */
    function setGuardianExpiration(
        address account,
        uint256 expiration
    ) external;

    /**
     * @notice Gets the expiration timestamp for a guardian
     * @param account Guardian address
     * @return uint256 Timestamp when guardian powers expire
     */
    function guardianExpirations(
        address account
    ) external view returns (uint256);

    /**
     * @notice Gets the expiration timestamp for a guardian
     * @param account Guardian address
     * @return expiration Timestamp when guardian powers expire
     */
    function getGuardianExpiration(
        address account
    ) external view returns (uint256 expiration);

    /**
     * @notice Emitted when an invalid guardian expiry period is set
     * @param expiryPeriod The expiry period that was set
     * @param minExpiryPeriod The minimum allowed expiry period
     * @param maxExpiryPeriod The maximum allowed expiry period
     */
    error InvalidGuardianExpiryPeriod(
        uint256 expiryPeriod,
        uint256 minExpiryPeriod,
        uint256 maxExpiryPeriod
    );

    /**
     * @notice Grants the Foundation role to a given account. The Foundation is responsible for
     * managing vesting wallets and related operations.
     * @param account The account to which the Foundation role will be granted
     */
    function grantFoundationRole(address account) external;

    /**
     * @notice Revokes the Foundation role from a given account
     * @param account The account from which the Foundation role will be revoked
     */
    function revokeFoundationRole(address account) external;
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

library Constants {
    // WAD: Common unit, stands for "18 decimals"
    uint256 public constant WAD = 1e18;

    // RAY: Higher precision unit, "27 decimals"
    uint256 public constant RAY = 1e27;

    // Conversion factor from WAD to RAY
    uint256 public constant WAD_TO_RAY = 1e9;

    // Number of seconds in a day
    uint256 public constant SECONDS_PER_DAY = 1 days;

    // Number of seconds in a year (assuming 365 days)
    uint256 public constant SECONDS_PER_YEAR = 365 days;

    // Maximum value for uint256
    uint256 public constant MAX_UINT256 = type(uint256).max;

    // AAVE V3 POOL CONFIG DATA MASK

    uint256 internal constant ACTIVE_MASK =
        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF;
    uint256 internal constant FROZEN_MASK =
        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDFFFFFFFFFFFFFF;
    uint256 internal constant PAUSED_MASK =
        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFF;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {StorageSlot} from "./StorageSlot.sol";

/**
 * @dev Variant of {ReentrancyGuard} that uses transient storage.
 *
 * NOTE: This variant only works on networks where EIP-1153 is available.
 */
abstract contract ReentrancyGuardTransient {
    using StorageSlot for *;

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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/StorageSlot.sol)
// This file was procedurally generated from scripts/generate/templates/StorageSlot.js.

pragma solidity ^0.8.24;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC-1967 implementation slot:
 * ```solidity
 * contract ERC1967 {
 *     // Define the slot. Alternatively, use the SlotDerivation library to derive the slot.
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(newImplementation.code.length > 0);
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * Since version 5.1, this library also support writing and reading value types to and from transient storage.
 *
 *  * Example using transient storage:
 * ```solidity
 * contract Lock {
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

    struct Int256Slot {
        int256 value;
    }

    struct StringSlot {
        string value;
    }

    struct BytesSlot {
        bytes value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(
        bytes32 slot
    ) internal pure returns (AddressSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(
        bytes32 slot
    ) internal pure returns (BooleanSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(
        bytes32 slot
    ) internal pure returns (Bytes32Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(
        bytes32 slot
    ) internal pure returns (Uint256Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Int256Slot` with member `value` located at `slot`.
     */
    function getInt256Slot(
        bytes32 slot
    ) internal pure returns (Int256Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `StringSlot` with member `value` located at `slot`.
     */
    function getStringSlot(
        bytes32 slot
    ) internal pure returns (StringSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `StringSlot` representation of the string storage pointer `store`.
     */
    function getStringSlot(
        string storage store
    ) internal pure returns (StringSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := store.slot
        }
    }

    /**
     * @dev Returns an `BytesSlot` with member `value` located at `slot`.
     */
    function getBytesSlot(
        bytes32 slot
    ) internal pure returns (BytesSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BytesSlot` representation of the bytes storage pointer `store`.
     */
    function getBytesSlot(
        bytes storage store
    ) internal pure returns (BytesSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := store.slot
        }
    }

    /**
     * @dev UDVT that represent a slot holding a address.
     */
    type AddressSlotType is bytes32;

    /**
     * @dev Cast an arbitrary slot to a AddressSlotType.
     */
    function asAddress(bytes32 slot) internal pure returns (AddressSlotType) {
        return AddressSlotType.wrap(slot);
    }

    /**
     * @dev UDVT that represent a slot holding a bool.
     */
    type BooleanSlotType is bytes32;

    /**
     * @dev Cast an arbitrary slot to a BooleanSlotType.
     */
    function asBoolean(bytes32 slot) internal pure returns (BooleanSlotType) {
        return BooleanSlotType.wrap(slot);
    }

    /**
     * @dev UDVT that represent a slot holding a bytes32.
     */
    type Bytes32SlotType is bytes32;

    /**
     * @dev Cast an arbitrary slot to a Bytes32SlotType.
     */
    function asBytes32(bytes32 slot) internal pure returns (Bytes32SlotType) {
        return Bytes32SlotType.wrap(slot);
    }

    /**
     * @dev UDVT that represent a slot holding a uint256.
     */
    type Uint256SlotType is bytes32;

    /**
     * @dev Cast an arbitrary slot to a Uint256SlotType.
     */
    function asUint256(bytes32 slot) internal pure returns (Uint256SlotType) {
        return Uint256SlotType.wrap(slot);
    }

    /**
     * @dev UDVT that represent a slot holding a int256.
     */
    type Int256SlotType is bytes32;

    /**
     * @dev Cast an arbitrary slot to a Int256SlotType.
     */
    function asInt256(bytes32 slot) internal pure returns (Int256SlotType) {
        return Int256SlotType.wrap(slot);
    }

    /**
     * @dev Load the value held at location `slot` in transient storage.
     */
    function tload(AddressSlotType slot) internal view returns (address value) {
        /// @solidity memory-safe-assembly
        assembly {
            value := tload(slot)
        }
    }

    /**
     * @dev Store `value` at location `slot` in transient storage.
     */
    function tstore(AddressSlotType slot, address value) internal {
        /// @solidity memory-safe-assembly
        assembly {
            tstore(slot, value)
        }
    }

    /**
     * @dev Load the value held at location `slot` in transient storage.
     */
    function tload(BooleanSlotType slot) internal view returns (bool value) {
        /// @solidity memory-safe-assembly
        assembly {
            value := tload(slot)
        }
    }

    /**
     * @dev Store `value` at location `slot` in transient storage.
     */
    function tstore(BooleanSlotType slot, bool value) internal {
        /// @solidity memory-safe-assembly
        assembly {
            tstore(slot, value)
        }
    }

    /**
     * @dev Load the value held at location `slot` in transient storage.
     */
    function tload(Bytes32SlotType slot) internal view returns (bytes32 value) {
        /// @solidity memory-safe-assembly
        assembly {
            value := tload(slot)
        }
    }

    /**
     * @dev Store `value` at location `slot` in transient storage.
     */
    function tstore(Bytes32SlotType slot, bytes32 value) internal {
        /// @solidity memory-safe-assembly
        assembly {
            tstore(slot, value)
        }
    }

    /**
     * @dev Load the value held at location `slot` in transient storage.
     */
    function tload(Uint256SlotType slot) internal view returns (uint256 value) {
        /// @solidity memory-safe-assembly
        assembly {
            value := tload(slot)
        }
    }

    /**
     * @dev Store `value` at location `slot` in transient storage.
     */
    function tstore(Uint256SlotType slot, uint256 value) internal {
        /// @solidity memory-safe-assembly
        assembly {
            tstore(slot, value)
        }
    }

    /**
     * @dev Load the value held at location `slot` in transient storage.
     */
    function tload(Int256SlotType slot) internal view returns (int256 value) {
        /// @solidity memory-safe-assembly
        assembly {
            value := tload(slot)
        }
    }

    /**
     * @dev Store `value` at location `slot` in transient storage.
     */
    function tstore(Int256SlotType slot, int256 value) internal {
        /// @solidity memory-safe-assembly
        assembly {
            tstore(slot, value)
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/**
 * @title Percentage
 * @author Roberto Cano
 * @notice Custom type for Percentage values with associated utility functions
 * @dev This contract defines a custom Percentage type and overloaded operators
 *      to perform arithmetic and comparison operations on Percentage values.
 */

/**
 * @dev Custom percentage type as uint256
 * @notice This type is used to represent percentage values with high precision
 */
type Percentage is uint256;

/**
 * @dev Overridden operators declaration for Percentage
 * @notice These operators allow for intuitive arithmetic and comparison operations
 *         on Percentage values
 */
using {
    add as +,
    subtract as -,
    multiply as *,
    divide as /,
    lessOrEqualThan as <=,
    lessThan as <,
    greaterOrEqualThan as >=,
    greaterThan as >,
    equalTo as ==
} for Percentage global;

/**
 * @dev The number of decimals used for the percentage
 *  This constant defines the precision of the Percentage type
 */
uint256 constant PERCENTAGE_DECIMALS = 18;

/**
 * @dev The factor used to scale the percentage
 *  This constant is used to convert between human-readable percentages
 *         and the internal representation
 */
uint256 constant PERCENTAGE_FACTOR = 10 ** PERCENTAGE_DECIMALS;

/**
 * @dev Percentage of 100% with the given `PERCENTAGE_DECIMALS`
 *  This constant represents 100% in the Percentage type
 */
Percentage constant PERCENTAGE_100 = Percentage.wrap(100 * PERCENTAGE_FACTOR);

/**
 * OPERATOR FUNCTIONS
 */

/**
 * @dev Adds two Percentage values
 * @param a The first Percentage value
 * @param b The second Percentage value
 * @return The sum of a and b as a Percentage
 */
function add(Percentage a, Percentage b) pure returns (Percentage) {
    return Percentage.wrap(Percentage.unwrap(a) + Percentage.unwrap(b));
}

/**
 * @dev Subtracts one Percentage value from another
 * @param a The Percentage value to subtract from
 * @param b The Percentage value to subtract
 * @return The difference between a and b as a Percentage
 */
function subtract(Percentage a, Percentage b) pure returns (Percentage) {
    return Percentage.wrap(Percentage.unwrap(a) - Percentage.unwrap(b));
}

/**
 * @dev Multiplies two Percentage values
 * @param a The first Percentage value
 * @param b The second Percentage value
 * @return The product of a and b as a Percentage, scaled appropriately
 */
function multiply(Percentage a, Percentage b) pure returns (Percentage) {
    return
        Percentage.wrap(
            (Percentage.unwrap(a) * Percentage.unwrap(b)) /
                Percentage.unwrap(PERCENTAGE_100)
        );
}

/**
 * @dev Divides one Percentage value by another
 * @param a The Percentage value to divide
 * @param b The Percentage value to divide by
 * @return The quotient of a divided by b as a Percentage, scaled appropriately
 */
function divide(Percentage a, Percentage b) pure returns (Percentage) {
    return
        Percentage.wrap(
            (Percentage.unwrap(a) * Percentage.unwrap(PERCENTAGE_100)) /
                Percentage.unwrap(b)
        );
}

/**
 * @dev Checks if one Percentage value is less than or equal to another
 * @param a The first Percentage value
 * @param b The second Percentage value
 * @return True if a is less than or equal to b, false otherwise
 */
function lessOrEqualThan(Percentage a, Percentage b) pure returns (bool) {
    return Percentage.unwrap(a) <= Percentage.unwrap(b);
}

/**
 * @dev Checks if one Percentage value is less than another
 * @param a The first Percentage value
 * @param b The second Percentage value
 * @return True if a is less than b, false otherwise
 */
function lessThan(Percentage a, Percentage b) pure returns (bool) {
    return Percentage.unwrap(a) < Percentage.unwrap(b);
}

/**
 * @dev Checks if one Percentage value is greater than or equal to another
 * @param a The first Percentage value
 * @param b The second Percentage value
 * @return True if a is greater than or equal to b, false otherwise
 */
function greaterOrEqualThan(Percentage a, Percentage b) pure returns (bool) {
    return Percentage.unwrap(a) >= Percentage.unwrap(b);
}

/**
 * @dev Checks if one Percentage value is greater than another
 * @param a The first Percentage value
 * @param b The second Percentage value
 * @return True if a is greater than b, false otherwise
 */
function greaterThan(Percentage a, Percentage b) pure returns (bool) {
    return Percentage.unwrap(a) > Percentage.unwrap(b);
}

/**
 * @dev Checks if two Percentage values are equal
 * @param a The first Percentage value
 * @param b The second Percentage value
 * @return True if a is equal to b, false otherwise
 */
function equalTo(Percentage a, Percentage b) pure returns (bool) {
    return Percentage.unwrap(a) == Percentage.unwrap(b);
}

/**
 * @dev Alias for equalTo function
 * @param a The first Percentage value
 * @param b The second Percentage value
 * @return True if a is equal to b, false otherwise
 */
function equals(Percentage a, Percentage b) pure returns (bool) {
    return Percentage.unwrap(a) == Percentage.unwrap(b);
}

/**
 * @dev Converts a uint256 value to a Percentage
 * @param value The uint256 value to convert
 * @return The input value as a Percentage
 */
function toPercentage(uint256 value) pure returns (Percentage) {
    return Percentage.wrap(value * PERCENTAGE_FACTOR);
}

/**
 * @dev Converts a Percentage value to a uint256
 * @param value The Percentage value to convert
 * @return The Percentage value as a uint256
 */
function fromPercentage(Percentage value) pure returns (uint256) {
    return Percentage.unwrap(value) / PERCENTAGE_FACTOR;
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {PERCENTAGE_100, PERCENTAGE_FACTOR, Percentage, toPercentage} from "./Percentage.sol";

/**
 * @title PercentageUtils
 * @author Roberto Cano
 * @notice Utility library to apply percentage calculations to input amounts
 * @dev This library provides functions for adding, subtracting, and applying
 *      percentages to amounts, as well as utility functions for working with
 *      percentages.
 */
library PercentageUtils {
    /**
     * @notice Adds the percentage to the given amount and returns the result
     * @param amount The base amount to which the percentage will be added
     * @param percentage The percentage to add to the amount
     * @return The amount after the percentage is applied
     * @dev It performs the following operation: (100.0% + percentage) * amount
     */
    function addPercentage(
        uint256 amount,
        Percentage percentage
    ) internal pure returns (uint256) {
        return applyPercentage(amount, PERCENTAGE_100 + percentage);
    }

    /**
     * @notice Subtracts the percentage from the given amount and returns the result
     * @param amount The base amount from which the percentage will be subtracted
     * @param percentage The percentage to subtract from the amount
     * @return The amount after the percentage is applied
     * @dev It performs the following operation: (100.0% - percentage) * amount
     */
    function subtractPercentage(
        uint256 amount,
        Percentage percentage
    ) internal pure returns (uint256) {
        return applyPercentage(amount, PERCENTAGE_100 - percentage);
    }

    /**
     * @notice Applies the given percentage to the given amount and returns the result
     * @param amount The amount to apply the percentage to
     * @param percentage The percentage to apply to the amount
     * @return The amount after the percentage is applied
     * @dev This function is used internally by addPercentage and subtractPercentage
     */
    function applyPercentage(
        uint256 amount,
        Percentage percentage
    ) internal pure returns (uint256) {
        return
            (amount * Percentage.unwrap(percentage)) /
            Percentage.unwrap(PERCENTAGE_100);
    }

    /**
     * @notice Checks if the given percentage is in range, this is, if it is between 0 and 100
     * @param percentage The percentage to check
     * @return True if the percentage is in range, false otherwise
     * @dev This function is useful for validating input percentages
     */
    function isPercentageInRange(
        Percentage percentage
    ) internal pure returns (bool) {
        return percentage <= PERCENTAGE_100;
    }

    /**
     * @notice Converts the given fraction into a percentage with the right number of decimals
     * @param numerator The numerator of the fraction
     * @param denominator The denominator of the fraction
     * @return The percentage with `PERCENTAGE_DECIMALS` decimals
     * @dev This function is useful for converting ratios to percentages
     *     For example, fromFraction(1, 2) returns 50%
     */
    function fromFraction(
        uint256 numerator,
        uint256 denominator
    ) internal pure returns (Percentage) {
        return
            Percentage.wrap(
                (numerator * PERCENTAGE_FACTOR * 100) / denominator
            );
    }

    /**
     * @notice Converts the given integer into a percentage
     * @param percentage The percentage in human-readable format, i.e., 50 for 50%
     * @return The percentage with `PERCENTAGE_DECIMALS` decimals
     * @dev This function is useful for converting human-readable percentages to the internal representation
     */
    function fromIntegerPercentage(
        uint256 percentage
    ) internal pure returns (Percentage) {
        return toPercentage(percentage);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/**
 * @title StakingRewardsManager
 * @notice Contract for managing staking rewards with multiple reward tokens in the Summer protocol
 * @dev Implements IStakingRewards interface and inherits from ReentrancyGuardTransient and ProtocolAccessManaged
 * @dev Inspired by Synthetix's StakingRewards contract:
 * https://github.com/Synthetixio/synthetix/blob/v2.101.3/contracts/StakingRewards.sol
 */
import {IStakingRewardsManagerBase} from "../interfaces/IStakingRewardsManagerBase.sol";
import {ProtocolAccessManaged} from "@summerfi/access-contracts/contracts/ProtocolAccessManaged.sol";
import {ReentrancyGuardTransient} from "@summerfi/dependencies/openzeppelin-next/ReentrancyGuardTransient.sol";
import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {Constants} from "@summerfi/constants/Constants.sol";
import {ERC20Wrapper} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Wrapper.sol";

/**
 * @title StakingRewards
 * @notice Contract for managing staking rewards with multiple reward tokens in the Summer protocol
 * @dev Implements IStakingRewards interface and inherits from ReentrancyGuardTransient and ProtocolAccessManaged
 */
abstract contract StakingRewardsManagerBase is
    IStakingRewardsManagerBase,
    ReentrancyGuardTransient,
    ProtocolAccessManaged
{
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.AddressSet;

    struct RewardData {
        uint256 periodFinish;
        uint256 rewardRate;
        uint256 rewardsDuration;
        uint256 lastUpdateTime;
        uint256 rewardPerTokenStored;
    }

    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/

    /* @notice List of all reward tokens supported by this contract */
    EnumerableSet.AddressSet internal _rewardTokensList;
    /* @notice The token that users stake to earn rewards */
    address public immutable stakingToken;

    /* @notice Mapping of reward token to its reward distribution data */
    mapping(address rewardToken => RewardData data) public rewardData;
    /* @notice Tracks the last reward per token paid to each user for each reward token */
    mapping(address rewardToken => mapping(address account => uint256 rewardPerTokenPaid))
        public userRewardPerTokenPaid;
    /* @notice Tracks the unclaimed rewards for each user for each reward token */
    mapping(address rewardToken => mapping(address account => uint256 rewardAmount))
        public rewards;

    /* @notice Total amount of tokens staked in the contract */
    uint256 public totalSupply;
    mapping(address account => uint256 balance) internal _balances;

    uint256 private constant MAX_REWARD_DURATION = 360 days; // 1 year

    /*//////////////////////////////////////////////////////////////
                                MODIFIERS
    //////////////////////////////////////////////////////////////*/

    modifier updateReward(address account) virtual {
        _updateReward(account);
        _;
    }

    /*//////////////////////////////////////////////////////////////
                                CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Initializes the StakingRewards contract
     * @param accessManager The address of the access manager
     */
    constructor(address accessManager) ProtocolAccessManaged(accessManager) {}

    /*//////////////////////////////////////////////////////////////
                                VIEWS
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IStakingRewardsManagerBase
    function rewardTokens(
        uint256 index
    ) external view override returns (address) {
        if (index >= _rewardTokensList.length()) revert IndexOutOfBounds();
        address rewardTokenAddress = _rewardTokensList.at(index);
        return rewardTokenAddress;
    }

    /// @inheritdoc IStakingRewardsManagerBase
    function rewardTokensLength() external view returns (uint256) {
        return _rewardTokensList.length();
    }

    /// @inheritdoc IStakingRewardsManagerBase
    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    /// @inheritdoc IStakingRewardsManagerBase
    function lastTimeRewardApplicable(
        address rewardToken
    ) public view returns (uint256) {
        return
            block.timestamp < rewardData[rewardToken].periodFinish
                ? block.timestamp
                : rewardData[rewardToken].periodFinish;
    }

    /// @inheritdoc IStakingRewardsManagerBase
    function rewardPerToken(address rewardToken) public view returns (uint256) {
        if (totalSupply == 0) {
            return rewardData[rewardToken].rewardPerTokenStored;
        }
        return
            rewardData[rewardToken].rewardPerTokenStored +
            ((lastTimeRewardApplicable(rewardToken) -
                rewardData[rewardToken].lastUpdateTime) *
                rewardData[rewardToken].rewardRate) /
            totalSupply;
    }

    /// @inheritdoc IStakingRewardsManagerBase
    function earned(
        address account,
        address rewardToken
    ) public view virtual returns (uint256) {
        return _earned(account, rewardToken);
    }

    /// @inheritdoc IStakingRewardsManagerBase
    function getRewardForDuration(
        address rewardToken
    ) external view returns (uint256) {
        RewardData storage data = rewardData[rewardToken];
        if (block.timestamp >= data.periodFinish) {
            return (data.rewardRate * data.rewardsDuration) / Constants.WAD;
        }
        // For active periods, calculate remaining rewards plus any new rewards
        uint256 remaining = data.periodFinish - block.timestamp;
        return (data.rewardRate * remaining) / Constants.WAD;
    }

    /// @inheritdoc IStakingRewardsManagerBase
    function isRewardToken(address rewardToken) external view returns (bool) {
        return _isRewardToken(rewardToken);
    }

    /*//////////////////////////////////////////////////////////////
                            MUTATIVE FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IStakingRewardsManagerBase
    function stake(uint256 amount) external virtual updateReward(_msgSender()) {
        _stake(_msgSender(), _msgSender(), amount);
    }

    /// @inheritdoc IStakingRewardsManagerBase
    function unstake(
        uint256 amount
    ) external virtual updateReward(_msgSender()) {
        _unstake(_msgSender(), _msgSender(), amount);
    }

    /// @inheritdoc IStakingRewardsManagerBase
    function getReward() public virtual nonReentrant {
        uint256 rewardTokenCount = _rewardTokensList.length();
        for (uint256 i = 0; i < rewardTokenCount; i++) {
            address rewardTokenAddress = _rewardTokensList.at(i);
            _getReward(_msgSender(), rewardTokenAddress);
        }
    }

    /// @inheritdoc IStakingRewardsManagerBase
    function getReward(address rewardToken) public virtual nonReentrant {
        if (!_isRewardToken(rewardToken)) revert RewardTokenDoesNotExist();
        _getReward(_msgSender(), rewardToken);
    }

    /// @inheritdoc IStakingRewardsManagerBase
    function exit() external virtual {
        getReward();
        _unstake(_msgSender(), _msgSender(), _balances[_msgSender()]);
    }

    /// @notice Claims rewards for a specific account
    /// @param account The address to claim rewards for
    function getRewardFor(address account) public virtual nonReentrant {
        uint256 rewardTokenCount = _rewardTokensList.length();
        for (uint256 i = 0; i < rewardTokenCount; i++) {
            address rewardTokenAddress = _rewardTokensList.at(i);
            _getReward(account, rewardTokenAddress);
        }
    }

    /// @notice Claims rewards for a specific account and specific reward token
    /// @param account The address to claim rewards for
    /// @param rewardToken The address of the reward token to claim
    function getRewardFor(
        address account,
        address rewardToken
    ) public virtual nonReentrant {
        if (!_isRewardToken(rewardToken)) revert RewardTokenDoesNotExist();
        _getReward(account, rewardToken);
    }

    /*//////////////////////////////////////////////////////////////
                            RESTRICTED FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IStakingRewardsManagerBase
    function notifyRewardAmount(
        address rewardToken,
        uint256 reward,
        uint256 newRewardsDuration
    ) external virtual onlyGovernor updateReward(address(0)) {
        _notifyRewardAmount(rewardToken, reward, newRewardsDuration);
    }

    /// @inheritdoc IStakingRewardsManagerBase
    function setRewardsDuration(
        address rewardToken,
        uint256 _rewardsDuration
    ) external onlyGovernor {
        if (!_isRewardToken(rewardToken)) {
            revert RewardTokenDoesNotExist();
        }
        if (_rewardsDuration == 0) {
            revert RewardsDurationCannotBeZero();
        }
        if (_rewardsDuration > MAX_REWARD_DURATION) {
            revert RewardsDurationTooLong();
        }

        RewardData storage data = rewardData[rewardToken];
        if (block.timestamp <= data.periodFinish) {
            revert RewardPeriodNotComplete();
        }
        data.rewardsDuration = _rewardsDuration;
        emit RewardsDurationUpdated(address(rewardToken), _rewardsDuration);
    }

    /// @notice Removes a reward token from the list of reward tokens
    /// @param rewardToken The address of the reward token to remove
    function removeRewardToken(address rewardToken) external onlyGovernor {
        if (!_isRewardToken(rewardToken)) {
            revert RewardTokenDoesNotExist();
        }

        if (block.timestamp <= rewardData[rewardToken].periodFinish) {
            revert RewardPeriodNotComplete();
        }

        // Check if all tokens have been claimed, allowing a small dust balance
        uint256 remainingBalance = IERC20(rewardToken).balanceOf(address(this));
        uint256 dustThreshold;

        try IERC20Metadata(address(rewardToken)).decimals() returns (
            uint8 decimals
        ) {
            // For tokens with 4 or fewer decimals, use a minimum threshold of 1
            // For tokens with more decimals, use 0.01% of 1 token
            if (decimals <= 4) {
                dustThreshold = 1;
            } else {
                dustThreshold = 10 ** (decimals - 4); // 0.01% of 1 token
            }
        } catch {
            dustThreshold = 1e14; // Default threshold for tokens without decimals
        }

        if (remainingBalance > dustThreshold) {
            revert RewardTokenStillHasBalance(remainingBalance);
        }

        // Remove the token from the rewardTokens map
        bool success = _rewardTokensList.remove(address(rewardToken));
        if (!success) revert RewardTokenDoesNotExist();

        emit RewardTokenRemoved(address(rewardToken));
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function _isRewardToken(address rewardToken) internal view returns (bool) {
        return _rewardTokensList.contains(rewardToken);
    }

    function _stake(
        address staker,
        address receiver,
        uint256 amount
    ) internal virtual {
        if (receiver == address(0)) revert CannotStakeToZeroAddress();
        if (amount == 0) revert CannotStakeZero();
        if (address(stakingToken) == address(0)) {
            revert StakingTokenNotInitialized();
        }
        totalSupply += amount;
        _balances[receiver] += amount;
        IERC20(stakingToken).safeTransferFrom(staker, address(this), amount);
        emit Staked(staker, receiver, amount);
    }

    function _unstake(
        address staker,
        address receiver,
        uint256 amount
    ) internal virtual {
        if (amount == 0) revert CannotUnstakeZero();
        totalSupply -= amount;
        _balances[staker] -= amount;
        IERC20(stakingToken).safeTransfer(receiver, amount);
        emit Unstaked(staker, receiver, amount);
    }

    /*
     * @notice Internal function to calculate earned rewards for an account
     * @param account The address to calculate earnings for
     * @param rewardToken The reward token to calculate earnings for
     * @return The amount of reward tokens earned
     */
    function _earned(
        address account,
        address rewardToken
    ) internal view returns (uint256) {
        return
            (_balances[account] *
                (rewardPerToken(rewardToken) -
                    userRewardPerTokenPaid[rewardToken][account])) /
            Constants.WAD +
            rewards[rewardToken][account];
    }

    function _updateReward(address account) internal {
        uint256 rewardTokenCount = _rewardTokensList.length();
        for (uint256 i = 0; i < rewardTokenCount; i++) {
            address rewardTokenAddress = _rewardTokensList.at(i);
            RewardData storage rewardTokenData = rewardData[rewardTokenAddress];
            rewardTokenData.rewardPerTokenStored = rewardPerToken(
                rewardTokenAddress
            );
            rewardTokenData.lastUpdateTime = lastTimeRewardApplicable(
                rewardTokenAddress
            );
            if (account != address(0)) {
                rewards[rewardTokenAddress][account] = earned(
                    account,
                    rewardTokenAddress
                );
                userRewardPerTokenPaid[rewardTokenAddress][
                    account
                ] = rewardTokenData.rewardPerTokenStored;
            }
        }
    }

    /**
     * @notice Internal function to claim rewards for an account for a specific token
     * @param account The address to claim rewards for
     * @param rewardTokenAddress The address of the reward token to claim
     * @dev rewards go straight to the user's wallet
     */
    function _getReward(
        address account,
        address rewardTokenAddress
    ) internal virtual updateReward(account) {
        uint256 reward = rewards[rewardTokenAddress][account];
        if (reward > 0) {
            rewards[rewardTokenAddress][account] = 0;
            IERC20(rewardTokenAddress).safeTransfer(account, reward);
            emit RewardPaid(account, rewardTokenAddress, reward);
        }
    }

    /**
     * @dev Internal implementation of notifyRewardAmount
     * @param rewardToken The token to distribute as rewards
     * @param reward The amount of reward tokens to distribute
     * @param newRewardsDuration The duration for new reward tokens (only used for first time)
     */
    function _notifyRewardAmount(
        address rewardToken,
        uint256 reward,
        uint256 newRewardsDuration
    ) internal {
        RewardData storage rewardTokenData = rewardData[rewardToken];
        if (newRewardsDuration == 0) {
            revert RewardsDurationCannotBeZero();
        }

        if (newRewardsDuration > MAX_REWARD_DURATION) {
            revert RewardsDurationTooLong();
        }

        // For existing reward tokens, check if current period is complete
        if (_isRewardToken(rewardToken)) {
            if (newRewardsDuration != rewardTokenData.rewardsDuration) {
                revert CannotChangeRewardsDuration();
            }
        } else {
            // First time setup for new reward token
            bool success = _rewardTokensList.add(rewardToken);
            if (!success) revert RewardTokenAlreadyExists();

            rewardTokenData.rewardsDuration = newRewardsDuration;
            emit RewardTokenAdded(rewardToken, rewardTokenData.rewardsDuration);
        }

        // Transfer exact amount needed for new rewards
        IERC20(rewardToken).safeTransferFrom(msg.sender, address(this), reward);

        // Calculate new reward rate
        rewardTokenData.rewardRate =
            (reward * Constants.WAD) /
            rewardTokenData.rewardsDuration;
        rewardTokenData.lastUpdateTime = block.timestamp;
        rewardTokenData.periodFinish =
            block.timestamp +
            rewardTokenData.rewardsDuration;

        emit RewardAdded(address(rewardToken), reward);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IStakingRewardsManagerBaseErrors} from "./IStakingRewardsManagerBaseErrors.sol";

/* @title IStakingRewardsManagerBase
 * @notice Interface for the Staking Rewards Manager contract
 * @dev Manages staking and distribution of multiple reward tokens
 */
interface IStakingRewardsManagerBase is IStakingRewardsManagerBaseErrors {
    // Views

    /* @notice Get the total amount of staked tokens
     * @return The total supply of staked tokens
     */
    function totalSupply() external view returns (uint256);

    /* @notice Get the staked balance of a specific account
     * @param account The address of the account to check
     * @return The staked balance of the account
     */
    function balanceOf(address account) external view returns (uint256);

    /* @notice Get the last time the reward was applicable for a specific reward token
     * @param rewardToken The address of the reward token
     * @return The timestamp of the last applicable reward time
     */
    function lastTimeRewardApplicable(
        address rewardToken
    ) external view returns (uint256);

    /* @notice Get the reward per token for a specific reward token
     * @param rewardToken The address of the reward token
     * @return The reward amount per staked token (WAD-scaled)
     * @dev Returns a WAD-scaled value (1e18) to maintain precision in calculations
     * @dev This value represents: (rewardRate * timeElapsed * WAD) / totalSupply
     */
    function rewardPerToken(
        address rewardToken
    ) external view returns (uint256);

    /* @notice Calculate the earned reward for an account and a specific reward token
     * @param account The address of the account
     * @param rewardToken The address of the reward token
     * @return The amount of reward tokens earned (not WAD-scaled)
     * @dev Calculated as: (balance * (rewardPerToken - userRewardPerTokenPaid)) / WAD + rewards
     */
    function earned(
        address account,
        address rewardToken
    ) external view returns (uint256);

    /* @notice Get the reward for the entire duration for a specific reward token
     * @param rewardToken The address of the reward token
     * @return The total reward amount for the duration (not WAD-scaled)
     * @dev Calculated as: (rewardRate * rewardsDuration) / WAD
     */
    function getRewardForDuration(
        address rewardToken
    ) external view returns (uint256);

    /* @notice Get the address of the staking token
     * @return The address of the staking token
     */
    function stakingToken() external view returns (address);

    /* @notice Get the reward token at a specific index
     * @param index The index of the reward token
     * @return The address of the reward token
     * @dev Reverts with IndexOutOfBounds if index >= rewardTokensLength()
     */
    function rewardTokens(uint256 index) external view returns (address);

    /* @notice Get the total number of reward tokens
     * @return The length of the reward tokens list
     */
    function rewardTokensLength() external view returns (uint256);

    /* @notice Check if a token is in the list of reward tokens
     * @param rewardToken The address to check
     * @return bool True if the token is a reward token, false otherwise
     */
    function isRewardToken(address rewardToken) external view returns (bool);

    // Mutative functions

    /* @notice Stake tokens for an account
     * @param amount The amount of tokens to stake
     */
    function stake(uint256 amount) external;

    /* @notice Stake tokens for an account on behalf of another account
     * @param receiver The address of the account to stake for
     * @param amount The amount of tokens to stake
     */
    function stakeOnBehalfOf(address receiver, uint256 amount) external;

    /* @notice Unstake staked tokens on behalf of another account
     * @param owner The address of the account to unstake from
     * @param amount The amount of tokens to unstake
     * @param claimRewards Whether to claim rewards before unstaking
     */
    function unstakeAndWithdrawOnBehalfOf(
        address owner,
        uint256 amount,
        bool claimRewards
    ) external;

    /* @notice Unstake staked tokens
     * @param amount The amount of tokens to unstake
     */
    function unstake(uint256 amount) external;

    /* @notice Claim accumulated rewards for all reward tokens */
    function getReward() external;

    /* @notice Claim accumulated rewards for a specific reward token
     * @param rewardToken The address of the reward token to claim
     */
    function getReward(address rewardToken) external;

    /* @notice Withdraw all staked tokens and claim rewards */
    function exit() external;

    // Admin functions

    /* @notice Notify the contract about new reward amount
     * @param rewardToken The address of the reward token
     * @param reward The amount of new reward (not WAD-scaled)
     * @param newRewardsDuration The duration for rewards distribution (only used when adding a new reward token)
     * @dev Internally sets rewardRate as (reward * WAD) / duration to maintain precision
     */
    function notifyRewardAmount(
        address rewardToken,
        uint256 reward,
        uint256 newRewardsDuration
    ) external;

    /* @notice Set the duration for rewards distribution
     * @param rewardToken The address of the reward token
     * @param _rewardsDuration The new duration for rewards
     */
    function setRewardsDuration(
        address rewardToken,
        uint256 _rewardsDuration
    ) external;

    /* @notice Removes a reward token from the list of reward tokens
     * @dev Can only be called by governor
     * @dev Can only be called after reward period is complete
     * @dev Can only be called if remaining balance is below dust threshold
     * @param rewardToken The address of the reward token to remove
     */
    function removeRewardToken(address rewardToken) external;

    // Events

    /* @notice Emitted when a new reward is added
     * @param rewardToken The address of the reward token
     * @param reward The amount of reward added
     */
    event RewardAdded(address indexed rewardToken, uint256 reward);

    /* @notice Emitted when tokens are staked
     * @param staker The address that provided the tokens for staking
     * @param receiver The address whose staking balance was updated
     * @param amount The amount of tokens added to the staking position
     */
    event Staked(
        address indexed staker,
        address indexed receiver,
        uint256 amount
    );

    /* @notice Emitted when tokens are unstaked
     * @param staker The address whose tokens were unstaked
     * @param receiver The address receiving the unstaked tokens
     * @param amount The amount of tokens unstaked
     */
    event Unstaked(
        address indexed staker,
        address indexed receiver,
        uint256 amount
    );

    /* @notice Emitted when tokens are withdrawn
     * @param user The address of the user that withdrew
     * @param amount The amount of tokens withdrawn
     */
    event Withdrawn(address indexed user, uint256 amount);

    /* @notice Emitted when rewards are paid out
     * @param user The address of the user receiving the reward
     * @param rewardToken The address of the reward token
     * @param reward The amount of reward paid
     */
    event RewardPaid(
        address indexed user,
        address indexed rewardToken,
        uint256 reward
    );

    /* @notice Emitted when the rewards duration is updated
     * @param rewardToken The address of the reward token
     * @param newDuration The new duration for rewards
     */
    event RewardsDurationUpdated(
        address indexed rewardToken,
        uint256 newDuration
    );

    /* @notice Emitted when a new reward token is added
     * @param rewardToken The address of the new reward token
     * @param rewardsDuration The duration for the new reward token
     */
    event RewardTokenAdded(address rewardToken, uint256 rewardsDuration);

    /* @notice Emitted when a reward token is removed
     * @param rewardToken The address of the reward token
     */
    event RewardTokenRemoved(address rewardToken);

    /* @notice Claims rewards for a specific account
     * @param account The address to claim rewards for
     */
    function getRewardFor(address account) external;

    /* @notice Claims rewards for a specific account and specific reward token
     * @param account The address to claim rewards for
     * @param rewardToken The address of the reward token to claim
     */
    function getRewardFor(address account, address rewardToken) external;
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/* @title IStakingRewardsManagerBaseErrors
 * @notice Interface defining custom errors for the Staking Rewards Manager
 */
interface IStakingRewardsManagerBaseErrors {
    /* @notice Thrown when attempting to stake zero tokens */
    error CannotStakeZero();

    /* @notice Thrown when attempting to withdraw zero tokens */
    error CannotWithdrawZero();

    /* @notice Thrown when the provided reward amount is too high */
    error ProvidedRewardTooHigh();

    /* @notice Thrown when trying to set rewards before the current period is complete */
    error RewardPeriodNotComplete();

    /* @notice Thrown when there are no reward tokens set */
    error NoRewardTokens();

    /* @notice Thrown when trying to add a reward token that already exists */
    error RewardTokenAlreadyExists();

    /* @notice Thrown when setting an invalid rewards duration */
    error InvalidRewardsDuration();

    /* @notice Thrown when trying to interact with a reward token that hasn't been initialized */
    error RewardTokenNotInitialized();

    /* @notice Thrown when the reward amount is invalid for the given duration
     * @param rewardToken The address of the reward token
     * @param rewardsDuration The duration for which the reward is invalid
     */
    error InvalidRewardAmount(address rewardToken, uint256 rewardsDuration);

    /* @notice Thrown when trying to interact with the staking token before it's initialized */
    error StakingTokenNotInitialized();

    /* @notice Thrown when trying to remove a reward token that doesn't exist */
    error RewardTokenDoesNotExist();

    /* @notice Thrown when trying to change the rewards duration of a reward token */
    error CannotChangeRewardsDuration();

    /* @notice Thrown when a reward token still has a balance */
    error RewardTokenStillHasBalance(uint256 balance);

    /* @notice Thrown when the index is out of bounds */
    error IndexOutOfBounds();

    /* @notice Thrown when the rewards duration is zero */
    error RewardsDurationCannotBeZero();

    /* @notice Thrown when attempting to unstake zero tokens */
    error CannotUnstakeZero();

    /* @notice Thrown when the rewards duration is too long */
    error RewardsDurationTooLong();

    /**
     * @notice Thrown when the receiver is the zero address
     */
    error CannotStakeToZeroAddress();
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import {IArk} from "../interfaces/IArk.sol";
import {IFleetCommander} from "../interfaces/IFleetCommander.sol";
import {ArkConfig, ArkParams} from "../types/ArkTypes.sol";
import {ArkConfigProvider} from "./ArkConfigProvider.sol";

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Constants} from "@summerfi/constants/Constants.sol";
import {ReentrancyGuardTransient} from "@summerfi/dependencies/openzeppelin-next/ReentrancyGuardTransient.sol";

/**
 * @title Ark
 * @author SummerFi
 * @notice This contract implements the core functionality for the Ark system,
 *         handling asset boarding, disembarking, and harvesting operations.
 * @dev This is an abstract contract that should be inherited by specific Ark implementations.
 *      Inheriting contracts must implement the abstract functions defined here.
 */
abstract contract Ark is IArk, ArkConfigProvider, ReentrancyGuardTransient {
    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////
                            CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(ArkParams memory _params) ArkConfigProvider(_params) {}

    /*//////////////////////////////////////////////////////////////
                                MODIFIERS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Modifier to validate board data.
     * @dev This modifier calls `_validateCommonData` and `_validateBoardData` to ensure the data is valid.
     * In the base Ark contract, we use generic bytes for the data. It is the responsibility of the Ark
     * implementing contract to override the `_validateBoardData` function to provide specific validation logic.
     * @param data The data to be validated.
     */
    modifier validateBoardData(bytes calldata data) {
        _validateCommonData(data);
        _validateBoardData(data);
        _;
    }

    /**
     * @notice Modifier to validate disembark data.
     * @dev This modifier calls `_validateCommonData` and `_validateDisembarkData` to ensure the data is valid.
     * In the base Ark contract, we use generic bytes for the data. It is the responsibility of the Ark
     * implementing contract to override the `_validateDisembarkData` function to provide specific validation logic.
     * @param data The data to be validated.
     */
    modifier validateDisembarkData(bytes calldata data) {
        _validateCommonData(data);
        _validateDisembarkData(data);
        _;
    }

    /*//////////////////////////////////////////////////////////////
                            EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IArk
    function totalAssets() external view virtual returns (uint256) {}

    /// @inheritdoc IArk
    function withdrawableTotalAssets() external view returns (uint256) {
        if (config.requiresKeeperData) {
            return 0;
        }
        return _withdrawableTotalAssets();
    }

    /// @inheritdoc IArk
    function harvest(
        bytes calldata additionalData
    )
        external
        onlyRaft
        nonReentrant
        returns (address[] memory rewardTokens, uint256[] memory rewardAmounts)
    {
        (rewardTokens, rewardAmounts) = _harvest(additionalData);
        emit ArkHarvested(rewardTokens, rewardAmounts);
    }

    /// @inheritdoc IArk
    function sweep(
        address[] memory tokens
    )
        external
        onlyRaft
        nonReentrant
        returns (address[] memory sweptTokens, uint256[] memory sweptAmounts)
    {
        sweptTokens = new address[](tokens.length);
        sweptAmounts = new uint256[](tokens.length);
        IERC20 asset = config.asset;

        address bufferArk = address(
            IFleetCommander(config.commander).bufferArk()
        );

        if (asset.balanceOf(address(this)) > 0 && address(this) != bufferArk) {
            asset.forceApprove(bufferArk, asset.balanceOf(address(this)));
            IArk(bufferArk).board(asset.balanceOf(address(this)), bytes(""));
        }
        for (uint256 i = 0; i < tokens.length; i++) {
            uint256 amount = IERC20(tokens[i]).balanceOf(address(this));
            if (amount > 0) {
                IERC20(tokens[i]).safeTransfer(
                    raft(),
                    IERC20(tokens[i]).balanceOf(address(this))
                );
                sweptTokens[i] = tokens[i];
                sweptAmounts[i] = amount;
            }
        }
        emit ArkSwept(sweptTokens, sweptAmounts);
    }

    /// @inheritdoc IArk
    function board(
        uint256 amount,
        bytes calldata boardData
    )
        external
        nonReentrant
        onlyAuthorizedToBoard(this.commander())
        validateBoardData(boardData)
    {
        address msgSender = msg.sender;
        IERC20 asset = config.asset;
        asset.safeTransferFrom(msgSender, address(this), amount);
        _board(amount, boardData);

        emit Boarded(msgSender, address(asset), amount);
    }

    /// @inheritdoc IArk
    function disembark(
        uint256 amount,
        bytes calldata disembarkData
    ) external onlyCommander nonReentrant validateDisembarkData(disembarkData) {
        address msgSender = msg.sender;
        IERC20 asset = config.asset;
        _disembark(amount, disembarkData);
        asset.safeTransfer(msgSender, amount);

        emit Disembarked(msgSender, address(asset), amount);
    }

    /// @inheritdoc IArk
    function move(
        uint256 amount,
        address receiverArk,
        bytes calldata boardData,
        bytes calldata disembarkData
    ) external onlyCommander validateDisembarkData(disembarkData) {
        _disembark(amount, disembarkData);

        IERC20 asset = config.asset;
        asset.forceApprove(receiverArk, amount);
        IArk(receiverArk).board(amount, boardData);

        emit Moved(address(this), receiverArk, address(asset), amount);
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Internal function to get the total assets that are withdrawable
     * @dev This function should be implemented by derived contracts to define specific withdrawability logic
     * @dev The Ark is withdrawable if it doesnt require keeper data and _withdrawableTotalAssets returns a non-zero
     * value
     * @return uint256 The total assets that are withdrawable
     */
    function _withdrawableTotalAssets() internal view virtual returns (uint256);

    /**
     * @notice Internal function to handle the boarding (depositing) of assets
     * @dev This function should be implemented by derived contracts to define specific boarding logic
     * @param amount The amount of assets to board
     * @param data Additional data for boarding, interpreted by the specific Ark implementation
     */
    function _board(uint256 amount, bytes calldata data) internal virtual;

    /**
     * @notice Internal function to handle the disembarking (withdrawing) of assets
     * @dev This function should be implemented by derived contracts to define specific disembarking logic
     * @param amount The amount of assets to disembark
     * @param data Additional data for disembarking, interpreted by the specific Ark implementation
     */
    function _disembark(uint256 amount, bytes calldata data) internal virtual;

    /**
     * @notice Internal function to handle the harvesting of rewards
     * @dev This function should be implemented by derived contracts to define specific harvesting logic
     * @param additionalData Additional data for harvesting, interpreted by the specific Ark implementation
     * @return rewardTokens The addresses of the reward tokens harvested
     * @return rewardAmounts The amounts of the reward tokens harvested
     */
    function _harvest(
        bytes calldata additionalData
    )
        internal
        virtual
        returns (address[] memory rewardTokens, uint256[] memory rewardAmounts);

    /**
     * @notice Internal function to validate boarding data
     * @dev This function should be implemented by derived contracts to define specific boarding data validation
     * @param data The boarding data to validate
     */
    function _validateBoardData(bytes calldata data) internal virtual;

    /**
     * @notice Internal function to validate disembarking data
     * @dev This function should be implemented by derived contracts to define specific disembarking data validation
     * @param data The disembarking data to validate
     */
    function _validateDisembarkData(bytes calldata data) internal virtual;

    /**
     * @notice Internal function to validate the presence or absence of additional data based on withdrawal restrictions
     * @dev This function checks if the data length is consistent with the Ark's withdrawal restrictions
     * @param data The data to validate
     */
    function _validateCommonData(bytes calldata data) internal view {
        if (data.length > 0 && !config.requiresKeeperData) {
            revert CannotUseKeeperDataWhenNotRequired();
        }
        if (data.length == 0 && config.requiresKeeperData) {
            revert KeeperDataRequired();
        }
    }

    /**
     * @notice Internal function to get the balance of the Ark's asset
     * @dev This function returns the balance of the Ark's token held by this contract
     * @return The balance of the Ark's asset
     */
    function _balanceOfAsset() internal view virtual returns (uint256) {
        return config.asset.balanceOf(address(this));
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import {IArkAccessManaged} from "../interfaces/IArkAccessManaged.sol";

import {IConfigurationManaged} from "../interfaces/IConfigurationManaged.sol";
import {IFleetCommander} from "../interfaces/IFleetCommander.sol";
import {ContractSpecificRoles} from "@summerfi/access-contracts/interfaces/IProtocolAccessManager.sol";

import {ProtocolAccessManaged} from "@summerfi/access-contracts/contracts/ProtocolAccessManaged.sol";

/**
 * @title ArkAccessManaged
 * @author SummerFi
 * @notice This contract manages access control for Ark-related operations.
 * @dev Inherits from ProtocolAccessManaged and implements IArkAccessManaged.
 * @custom:see IArkAccessManaged
 */
contract ArkAccessManaged is IArkAccessManaged, ProtocolAccessManaged {
    /**
     * @notice Initializes the ArkAccessManaged contract.
     * @param accessManager The address of the access manager contract.
     */
    constructor(address accessManager) ProtocolAccessManaged(accessManager) {}

    /**
     * @notice Checks if the caller is authorized to board funds.
     * @dev This modifier allows the Commander, RAFT contract, or active Arks to proceed.
     * @param commander The address of the FleetCommander contract.
     * @custom:internal-logic
     * - Checks if the caller is the registered commander
     * - If not, checks if the caller is the RAFT contract
     * - If not, checks if the caller is an active Ark in the FleetCommander
     * @custom:effects
     * - Reverts if the caller doesn't have the necessary permissions
     * - Allows the function to proceed if the caller is authorized
     * @custom:security-considerations
     * - Ensures that only authorized entities can board funds
     * - Relies on the correct setup of the FleetCommander and RAFT contracts
     */
    modifier onlyAuthorizedToBoard(address commander) {
        if (commander != _msgSender()) {
            address msgSender = _msgSender();
            bool isRaft = msgSender ==
                IConfigurationManaged(address(this)).raft();

            if (!isRaft) {
                bool isArk = IFleetCommander(commander).isArkActiveOrBufferArk(
                    msgSender
                );
                if (!isArk) {
                    revert CallerIsNotAuthorizedToBoard(msgSender);
                }
            }
        }
        _;
    }

    /**
     * @notice Restricts access to only the RAFT contract.
     * @dev Modifier to check that the caller is the RAFT contract
     * @custom:internal-logic
     * - Retrieves the RAFT address from the ConfigurationManaged contract
     * - Compares the caller's address with the RAFT address
     * @custom:effects
     * - Reverts if the caller is not the RAFT contract
     * - Allows the function to proceed if the caller is the RAFT contract
     * @custom:security-considerations
     * - Ensures that only the RAFT contract can call certain functions
     * - Relies on the correct setup of the ConfigurationManaged contract
     */
    modifier onlyRaft() {
        if (_msgSender() != IConfigurationManaged(address(this)).raft()) {
            revert CallerIsNotRaft(_msgSender());
        }
        _;
    }

    /**
     * @notice Checks if the caller has the Commander role.
     * @dev Internal function to check if the caller has the Commander role
     * @return bool True if the caller has the Commander role, false otherwise
     * @custom:internal-logic
     * - Generates the Commander role identifier for this contract
     * - Checks if the caller has the generated role in the access manager
     * @custom:effects
     * - Does not modify any state, view function only
     * @custom:security-considerations
     * - Relies on the correct setup of the access manager
     * - Assumes that the Commander role is properly assigned
     */
    function _hasCommanderRole() internal view returns (bool) {
        return
            _accessManager.hasRole(
                generateRole(
                    ContractSpecificRoles.COMMANDER_ROLE,
                    address(this)
                ),
                _msgSender()
            );
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import {ArkConfig, ArkParams} from "../types/ArkTypes.sol";

import {IArkConfigProvider} from "../interfaces/IArkConfigProvider.sol";

import {ArkAccessManaged} from "./ArkAccessManaged.sol";

import {ConfigurationManaged} from "./ConfigurationManaged.sol";
import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Percentage, PercentageUtils} from "@summerfi/percentage-solidity/contracts/PercentageUtils.sol";

/**
 * @title ArkConfigProvider
 * @author SummerFi
 * @notice This contract manages the configuration for Ark contracts.
 * @dev Inherits from IArkConfigProvider, ArkAccessManaged, and ConfigurationManaged.
 * @custom:see IArkConfigProvider
 */
abstract contract ArkConfigProvider is
    IArkConfigProvider,
    ArkAccessManaged,
    ConfigurationManaged
{
    ArkConfig public config;

    /**
     * @notice Initializes the ArkConfigProvider contract.
     * @param _params The initial parameters for the Ark configuration.
     * @dev Validates input parameters and sets up the initial configuration.
     */
    constructor(
        ArkParams memory _params
    )
        ArkAccessManaged(_params.accessManager)
        ConfigurationManaged(_params.configurationManager)
    {
        if (_params.asset == address(0)) {
            revert CannotDeployArkWithoutToken();
        }
        if (bytes(_params.name).length == 0) {
            revert CannotDeployArkWithEmptyName();
        }
        if (raft() == address(0)) {
            revert CannotDeployArkWithoutRaft();
        }
        if (
            !PercentageUtils.isPercentageInRange(
                _params.maxDepositPercentageOfTVL
            )
        ) {
            revert MaxDepositPercentageOfTVLTooHigh();
        }

        config = ArkConfig({
            asset: IERC20(_params.asset),
            commander: address(0), // Commander is initially set to address(0)
            raft: raft(),
            depositCap: _params.depositCap,
            maxRebalanceOutflow: _params.maxRebalanceOutflow,
            maxRebalanceInflow: _params.maxRebalanceInflow,
            name: _params.name,
            details: _params.details,
            requiresKeeperData: _params.requiresKeeperData,
            maxDepositPercentageOfTVL: _params.maxDepositPercentageOfTVL
        });

        // The commander address is initially set to address(0).
        // This allows the FleetCommander contract to self-register with the Ark later,
        // using the `registerFleetCommander()` function. This approach ensures that:
        // 1. The FleetCommander's address is not hardcoded during deployment.
        // 2. Only the authorized FleetCommander can register itself.
        // 3. The Ark remains flexible for potential commander changes in the future.
        // See the `registerFleetCommander()` function for the actual registration process.
    }

    /// @inheritdoc IArkConfigProvider
    function name() external view returns (string memory) {
        return config.name;
    }

    /// @inheritdoc IArkConfigProvider
    function details() external view returns (string memory) {
        return config.details;
    }

    /// @inheritdoc IArkConfigProvider
    function depositCap() external view returns (uint256) {
        return config.depositCap;
    }

    /// @inheritdoc IArkConfigProvider
    function asset() external view returns (IERC20) {
        return config.asset;
    }

    function maxDepositPercentageOfTVL() external view returns (Percentage) {
        return config.maxDepositPercentageOfTVL;
    }
    /// @inheritdoc IArkConfigProvider

    function commander() public view returns (address) {
        return config.commander;
    }

    /// @inheritdoc IArkConfigProvider
    function maxRebalanceOutflow() external view returns (uint256) {
        return config.maxRebalanceOutflow;
    }

    /// @inheritdoc IArkConfigProvider
    function maxRebalanceInflow() external view returns (uint256) {
        return config.maxRebalanceInflow;
    }

    /// @inheritdoc IArkConfigProvider
    function requiresKeeperData() external view returns (bool) {
        return config.requiresKeeperData;
    }

    /// @inheritdoc IArkConfigProvider
    function getConfig() external view returns (ArkConfig memory) {
        return config;
    }

    /// @inheritdoc IArkConfigProvider
    function setDepositCap(uint256 newDepositCap) external onlyCommander {
        config.depositCap = newDepositCap;
        emit DepositCapUpdated(newDepositCap);
    }

    /// @inheritdoc IArkConfigProvider
    function setMaxDepositPercentageOfTVL(
        Percentage newMaxDepositPercentageOfTVL
    ) external onlyCommander {
        if (
            !PercentageUtils.isPercentageInRange(newMaxDepositPercentageOfTVL)
        ) {
            revert MaxDepositPercentageOfTVLTooHigh();
        }
        config.maxDepositPercentageOfTVL = newMaxDepositPercentageOfTVL;
        emit MaxDepositPercentageOfTVLUpdated(newMaxDepositPercentageOfTVL);
    }

    /// @inheritdoc IArkConfigProvider
    function setMaxRebalanceOutflow(
        uint256 newMaxRebalanceOutflow
    ) external onlyCommander {
        config.maxRebalanceOutflow = newMaxRebalanceOutflow;
        emit MaxRebalanceOutflowUpdated(newMaxRebalanceOutflow);
    }

    /// @inheritdoc IArkConfigProvider
    function setMaxRebalanceInflow(
        uint256 newMaxRebalanceInflow
    ) external onlyCommander {
        config.maxRebalanceInflow = newMaxRebalanceInflow;
        emit MaxRebalanceInflowUpdated(newMaxRebalanceInflow);
    }

    function registerFleetCommander() external {
        if (!_hasCommanderRole()) {
            revert CallerIsNotCommander(msg.sender);
        }
        if (config.commander != address(0)) {
            revert FleetCommanderAlreadyRegistered();
        }
        config.commander = msg.sender;
        emit FleetCommanderRegistered(msg.sender);
    }

    function unregisterFleetCommander() external {
        if (_msgSender() != config.commander) {
            revert FleetCommanderNotRegistered();
        }
        config.commander = address(0);
        emit FleetCommanderUnregistered(msg.sender);
    }

    modifier onlyCommander() {
        if (_msgSender() != config.commander) {
            revert CallerIsNotCommander(_msgSender());
        }
        _;
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import {IConfigurationManaged} from "../interfaces/IConfigurationManaged.sol";
import {IConfigurationManager} from "../interfaces/IConfigurationManager.sol";

/**
 * @title ConfigurationManaged
 * @notice Base contract for contracts that need to read from the ConfigurationManager
 * @custom:see IConfigurationManaged
 */
abstract contract ConfigurationManaged is IConfigurationManaged {
    IConfigurationManager public immutable configurationManager;

    /**
     * @notice Constructs the ConfigurationManaged contract
     * @param _configurationManager The address of the ConfigurationManager contract
     */
    constructor(address _configurationManager) {
        if (_configurationManager == address(0)) {
            revert ConfigurationManagerZeroAddress();
        }
        configurationManager = IConfigurationManager(_configurationManager);
    }

    /// @inheritdoc IConfigurationManaged
    function raft() public view virtual returns (address) {
        return configurationManager.raft();
    }

    /// @inheritdoc IConfigurationManaged
    function tipJar() public view virtual returns (address) {
        return configurationManager.tipJar();
    }

    /// @inheritdoc IConfigurationManaged
    function treasury() public view virtual returns (address) {
        return configurationManager.treasury();
    }

    /// @inheritdoc IConfigurationManaged
    function harborCommand() public view virtual returns (address) {
        return configurationManager.harborCommand();
    }

    /// @inheritdoc IConfigurationManaged
    function fleetCommanderRewardsManagerFactory()
        public
        view
        virtual
        returns (address)
    {
        return configurationManager.fleetCommanderRewardsManagerFactory();
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import {IArk} from "../interfaces/IArk.sol";
import {IFleetCommander} from "../interfaces/IFleetCommander.sol";
import {ArkData, FleetCommanderParams, FleetConfig, RebalanceData} from "../types/FleetCommanderTypes.sol";

import {CooldownEnforcer} from "../utils/CooldownEnforcer/CooldownEnforcer.sol";

import {FleetCommanderCache} from "./FleetCommanderCache.sol";
import {FleetCommanderConfigProvider} from "./FleetCommanderConfigProvider.sol";

import {Tipper} from "./Tipper.sol";
import {ERC20, ERC4626, IERC20, IERC4626, SafeERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

import {IFleetCommanderRewardsManager} from "../interfaces/IFleetCommanderRewardsManager.sol";
import {Constants} from "@summerfi/constants/Constants.sol";
import {Percentage} from "@summerfi/percentage-solidity/contracts/Percentage.sol";
import {PercentageUtils} from "@summerfi/percentage-solidity/contracts/PercentageUtils.sol";

/**
 * @title FleetCommander
 * @notice Manages a fleet of Arks, coordinating deposits, withdrawals, and rebalancing operations
 * @dev Implements IFleetCommander interface and inherits from various utility contracts
 */
contract FleetCommander is
    IFleetCommander,
    FleetCommanderConfigProvider,
    ERC4626,
    Tipper,
    FleetCommanderCache,
    CooldownEnforcer
{
    using SafeERC20 for IERC20;
    using PercentageUtils for uint256;
    using Math for uint256;

    /*//////////////////////////////////////////////////////////////
                            CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Initializes the FleetCommander contract
     * @param params FleetCommanderParams struct containing initialization parameters
     */
    constructor(
        FleetCommanderParams memory params
    )
        ERC4626(IERC20(params.asset))
        ERC20(params.name, params.symbol)
        FleetCommanderConfigProvider(params)
        Tipper(params.initialTipRate)
        CooldownEnforcer(params.initialRebalanceCooldown, false)
    {}

    /*//////////////////////////////////////////////////////////////
                            MODIFIERS
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Modifier to collect the tip before any other action is taken
     */
    modifier collectTip() {
        _setIsCollectingTip(true);
        _accrueTip(tipJar(), totalSupply());

        _;
        _setIsCollectingTip(false);
    }

    /**
     * @dev Modifier to cache ark data for deposit operations.
     * @notice This modifier retrieves ark data before the function execution,
     *         allows the modified function to run, and then flushes the cache.
     * @dev The cache is required due to multiple calls to `totalAssets` in the same transaction.
     *         those calls migh be gas expensive for some arks.
     */
    modifier useCache() {
        _getArksData(config.bufferArk);
        _;
        _flushCache();
    }

    /**
     * @dev Modifier to cache withdrawable ark data for withdraw operations.
     * @notice This modifier retrieves withdrawable ark data before the function execution,
     *         allows the modified function to run, and then flushes the cache.
     * @dev The cache is required due to multiple calls to `totalAssets` in the same transaction.
     *         those calls migh be gas expensive for some arks.
     */
    modifier useWithdrawCache() {
        _getWithdrawableArksData(config.bufferArk);
        _;
        _flushCache();
    }

    /*//////////////////////////////////////////////////////////////
                        PUBLIC USER FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IFleetCommander
    function withdrawFromBuffer(
        uint256 assets,
        address receiver,
        address owner
    ) public whenNotPaused collectTip useCache returns (uint256 shares) {
        shares = previewWithdraw(assets);
        _validateBufferWithdraw(assets, shares, owner);

        uint256 prevQueueBalance = config.bufferArk.totalAssets();

        _disembark(address(config.bufferArk), assets);
        _withdraw(_msgSender(), receiver, owner, assets, shares);

        emit FundsBufferBalanceUpdated(
            _msgSender(),
            prevQueueBalance,
            config.bufferArk.totalAssets()
        );
    }

    /// @inheritdoc IFleetCommander
    function redeem(
        uint256 shares,
        address receiver,
        address owner
    )
        public
        override(ERC4626, IFleetCommander)
        collectTip
        useCache
        whenNotPaused
        returns (uint256 assets)
    {
        uint256 bufferBalance = config.bufferArk.totalAssets();
        uint256 bufferBalanceInShares = convertToShares(bufferBalance);

        if (shares == Constants.MAX_UINT256) {
            shares = balanceOf(owner);
        }

        if (shares <= bufferBalanceInShares) {
            assets = redeemFromBuffer(shares, receiver, owner);
        } else {
            assets = redeemFromArks(shares, receiver, owner);
        }
    }

    /// @inheritdoc IFleetCommander
    function redeemFromBuffer(
        uint256 shares,
        address receiver,
        address owner
    ) public collectTip useCache whenNotPaused returns (uint256 assets) {
        _validateBufferRedeem(shares, owner);

        uint256 previousFundsBufferBalance = config.bufferArk.totalAssets();

        assets = previewRedeem(shares);
        _disembark(address(config.bufferArk), assets);
        _withdraw(_msgSender(), receiver, owner, assets, shares);

        emit FundsBufferBalanceUpdated(
            _msgSender(),
            previousFundsBufferBalance,
            config.bufferArk.totalAssets()
        );
    }

    /// @inheritdoc IFleetCommander
    function withdraw(
        uint256 assets,
        address receiver,
        address owner
    )
        public
        override(ERC4626, IFleetCommander)
        collectTip
        useCache
        whenNotPaused
        returns (uint256 shares)
    {
        uint256 bufferBalance = config.bufferArk.totalAssets();

        if (assets == Constants.MAX_UINT256) {
            uint256 totalUserShares = balanceOf(owner);
            assets = previewRedeem(totalUserShares);
        }

        if (assets <= bufferBalance) {
            shares = withdrawFromBuffer(assets, receiver, owner);
        } else {
            shares = withdrawFromArks(assets, receiver, owner);
        }
    }

    /// @inheritdoc IFleetCommander
    function withdrawFromArks(
        uint256 assets,
        address receiver,
        address owner
    )
        public
        override(IFleetCommander)
        collectTip
        useWithdrawCache
        whenNotPaused
        returns (uint256 totalSharesToRedeem)
    {
        totalSharesToRedeem = previewWithdraw(assets);

        _validateWithdrawFromArks(assets, totalSharesToRedeem, owner);

        _forceDisembarkFromSortedArks(assets);
        _withdraw(_msgSender(), receiver, owner, assets, totalSharesToRedeem);
        _resetLastActionTimestamp();

        emit FleetCommanderWithdrawnFromArks(owner, receiver, assets);
    }

    /// @inheritdoc IFleetCommander
    function redeemFromArks(
        uint256 shares,
        address receiver,
        address owner
    )
        public
        override(IFleetCommander)
        collectTip
        useWithdrawCache
        whenNotPaused
        returns (uint256 totalAssetsToWithdraw)
    {
        _validateRedeemFromArks(shares, owner);

        totalAssetsToWithdraw = previewRedeem(shares);
        _forceDisembarkFromSortedArks(totalAssetsToWithdraw);
        _withdraw(_msgSender(), receiver, owner, totalAssetsToWithdraw, shares);
        _resetLastActionTimestamp();
        emit FleetCommanderRedeemedFromArks(owner, receiver, shares);
    }

    /// @inheritdoc IERC4626
    function deposit(
        uint256 assets,
        address receiver
    )
        public
        override(ERC4626, IERC4626)
        collectTip
        useCache
        whenNotPaused
        returns (uint256 shares)
    {
        _validateDeposit(assets, _msgSender());

        uint256 previousFundsBufferBalance = config.bufferArk.totalAssets();

        shares = previewDeposit(assets);
        _deposit(_msgSender(), receiver, assets, shares);
        _board(address(config.bufferArk), assets);

        emit FundsBufferBalanceUpdated(
            _msgSender(),
            previousFundsBufferBalance,
            config.bufferArk.totalAssets()
        );
    }

    /// @inheritdoc IFleetCommander
    function deposit(
        uint256 assets,
        address receiver,
        bytes memory referralCode
    ) external returns (uint256) {
        emit FleetCommanderReferral(receiver, referralCode);
        return deposit(assets, receiver);
    }

    /// @inheritdoc IERC4626
    function mint(
        uint256 shares,
        address receiver
    )
        public
        override(ERC4626, IERC4626)
        collectTip
        useCache
        whenNotPaused
        returns (uint256 assets)
    {
        _validateMint(shares, _msgSender());

        uint256 previousFundsBufferBalance = config.bufferArk.totalAssets();
        assets = previewMint(shares);

        _deposit(_msgSender(), receiver, assets, shares);
        _board(address(config.bufferArk), assets);

        emit FundsBufferBalanceUpdated(
            _msgSender(),
            previousFundsBufferBalance,
            config.bufferArk.totalAssets()
        );
    }

    /// @inheritdoc IFleetCommander
    function tip() public whenNotPaused returns (uint256) {
        return _accrueTip(tipJar(), totalSupply());
    }

    /*//////////////////////////////////////////////////////////////
                        PUBLIC VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Overrides the totalSupply function to include the tip shares
     * @dev This is done to ensure that the totalSupply is always accurate, even when tips are being accrued
     * @dev This is done by checking if the _isCollectingTip flag is set, and if it is, return the totalSupply
     * @dev If the _isCollectingTip flag is not set, then we need to accrue the tips and return the totalSupply + the
     * previewTip
     * @dev when collecting fee we require totalSupply to be the pre tip totalSupply, after the tip is collected the
     * totalSupply will include the tip shares
     * @dev when called in view functions we need to return the totalSupply + the previewTip
     * @return uint256 The total supply of the FleetCommander, including tip shares
     */
    function totalSupply()
        public
        view
        override(ERC20, IERC20)
        returns (uint256)
    {
        if (_isCollectingTip()) {
            return super.totalSupply();
        }
        uint256 _totalSupply = super.totalSupply();
        return _totalSupply + previewTip(tipJar(), _totalSupply);
    }

    /// @inheritdoc IFleetCommander
    function totalAssets()
        public
        view
        override(IFleetCommander, ERC4626)
        returns (uint256)
    {
        return _totalAssets(config.bufferArk);
    }

    /// @inheritdoc IFleetCommander
    function withdrawableTotalAssets() public view returns (uint256) {
        return _withdrawableTotalAssets(config.bufferArk);
    }

    /// @inheritdoc IERC4626
    function maxDeposit(
        address owner
    ) public view override(ERC4626, IERC4626) returns (uint256 _maxDeposit) {
        uint256 _totalAssets = totalAssets();
        uint256 maxAssets = _totalAssets > config.depositCap
            ? 0
            : config.depositCap - _totalAssets;

        _maxDeposit = Math.min(maxAssets, IERC20(asset()).balanceOf(owner));
    }

    /// @inheritdoc IERC4626
    function maxMint(
        address owner
    ) public view override(ERC4626, IERC4626) returns (uint256 _maxMint) {
        uint256 _totalAssets = totalAssets();
        uint256 maxAssets = _totalAssets > config.depositCap
            ? 0
            : config.depositCap - _totalAssets;
        _maxMint = previewDeposit(
            Math.min(maxAssets, IERC20(asset()).balanceOf(owner))
        );
    }

    /// @inheritdoc IFleetCommander
    function maxBufferWithdraw(
        address owner
    ) public view returns (uint256 _maxBufferWithdraw) {
        _maxBufferWithdraw = Math.min(
            config.bufferArk.totalAssets(),
            previewRedeem(balanceOf(owner))
        );
    }

    /// @inheritdoc IERC4626
    function maxWithdraw(
        address owner
    ) public view override(ERC4626, IERC4626) returns (uint256 _maxWithdraw) {
        _maxWithdraw = Math.min(
            withdrawableTotalAssets(),
            previewRedeem(balanceOf(owner))
        );
    }

    /// @inheritdoc IERC4626
    function maxRedeem(
        address owner
    ) public view override(ERC4626, IERC4626) returns (uint256 _maxRedeem) {
        _maxRedeem = Math.min(
            convertToShares(withdrawableTotalAssets()),
            balanceOf(owner)
        );
    }

    /// @inheritdoc IFleetCommander
    function maxBufferRedeem(
        address owner
    ) public view returns (uint256 _maxBufferRedeem) {
        _maxBufferRedeem = Math.min(
            previewWithdraw(config.bufferArk.totalAssets()),
            balanceOf(owner)
        );
    }

    /*//////////////////////////////////////////////////////////////
                        EXTERNAL KEEPER FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IFleetCommander
    function rebalance(
        RebalanceData[] calldata rebalanceData
    ) external onlyKeeper enforceCooldown collectTip whenNotPaused {
        _validateReallocateAllAssets(rebalanceData);
        _validateAdjustBuffer(rebalanceData);
        _reallocateAllAssets(rebalanceData);
    }

    /*//////////////////////////////////////////////////////////////
                        EXTERNAL GOVERNOR FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IFleetCommander
    function setTipRate(
        Percentage newTipRate
    ) external onlyGovernor whenNotPaused {
        // The newTipRate uses the Percentage type from @summerfi/percentage-solidity
        // Percentages have 18 decimals of precision
        // For example, 1% would be represented as 1 * 10^18 (assuming PERCENTAGE_DECIMALS is 18)
        _setTipRate(newTipRate, tipJar(), totalSupply());
    }

    /// @inheritdoc IFleetCommander
    function setMinimumPauseTime(
        uint256 _newMinimumPauseTime
    ) public onlyGovernor whenNotPaused {
        _setMinimumPauseTime(_newMinimumPauseTime);
    }

    /// @inheritdoc IFleetCommander
    function updateRebalanceCooldown(
        uint256 newCooldown
    ) external onlyCurator(address(this)) whenNotPaused {
        _updateCooldown(newCooldown);
    }

    /// @inheritdoc IFleetCommander
    function forceRebalance(
        RebalanceData[] calldata rebalanceData
    ) external onlyGovernor collectTip whenNotPaused {
        _validateReallocateAllAssets(rebalanceData);
        _validateAdjustBuffer(rebalanceData);
        _reallocateAllAssets(rebalanceData);
    }

    /// @inheritdoc IFleetCommander
    function pause() external onlyGuardianOrGovernor {
        _pause();
    }

    /// @inheritdoc IFleetCommander
    function unpause() external onlyGuardianOrGovernor {
        _unpause();
    }

    /*//////////////////////////////////////////////////////////////
                        PUBLIC ERC20 FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IERC20
    function transfer(
        address to,
        uint256 amount
    ) public override(IERC20, ERC20) returns (bool) {
        if (transfersEnabled || _msgSender() == config.stakingRewardsManager) {
            return super.transfer(to, amount);
        }

        revert FleetCommanderTransfersDisabled();
    }

    /// @inheritdoc IERC20
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override(IERC20, ERC20) returns (bool) {
        if (transfersEnabled || _msgSender() == config.stakingRewardsManager) {
            return super.transferFrom(from, to, amount);
        }
        revert FleetCommanderTransfersDisabled();
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Mints new shares as tips to the specified account
     * @dev This function overrides the abstract _mintTip function from the Tipper contract.
     *      It is called internally by the _accrueTip function to mint new shares as tips.
     *      In the context of FleetCommander, this creates new shares without requiring
     *      additional underlying assets, effectively diluting existing shareholders slightly
     *      to pay for the protocol's ongoing operations.
     * @param account The address to receive the minted tip shares
     * @param amount The amount of shares to mint as a tip
     */
    function _mintTip(
        address account,
        uint256 amount
    ) internal virtual override {
        _mint(account, amount);
    }

    /**
     * @notice Reallocates all assets based on the provided rebalance data
     * @param rebalanceData Array of RebalanceData structs containing information about the reallocation
     */
    function _reallocateAllAssets(
        RebalanceData[] calldata rebalanceData
    ) internal {
        for (uint256 i = 0; i < rebalanceData.length; i++) {
            _reallocateAssets(rebalanceData[i]);
        }
        emit Rebalanced(_msgSender(), rebalanceData);
    }

    /* INTERNAL - ARK */

    /**
     * @notice Approves and boards a specified amount of assets to an Ark
     * @param ark The address of the Ark
     * @param amount The amount of assets to board
     */
    function _board(address ark, uint256 amount) internal {
        IERC20(asset()).forceApprove(ark, amount);
        IArk(ark).board(amount, bytes(""));
    }

    /**
     * @notice Disembarks a specified amount of assets from an Ark
     * @param ark The address of the Ark
     * @param amount The amount of assets to disembark
     */
    function _disembark(address ark, uint256 amount) internal {
        IArk(ark).disembark(amount, bytes(""));
    }

    /**
     * @notice Moves a specified amount of assets from one Ark to another
     * @param fromArk The address of the Ark to move assets from
     * @param toArk The address of the Ark to move assets to
     * @param amount The amount of assets to move
     * @param boardData Additional data for the board operation
     * @param disembarkData Additional data for the disembark operation
     */
    function _move(
        address fromArk,
        address toArk,
        uint256 amount,
        bytes memory boardData,
        bytes memory disembarkData
    ) internal {
        IArk(fromArk).move(amount, toArk, boardData, disembarkData);
    }

    /* INTERNAL */

    /**
     * @notice Reallocates assets from one Ark to another
     * @dev This function handles the reallocation of assets between Arks, considering:
     *      1. The maximum allocation of the destination Ark
     *      2. The current allocation of the destination Ark
     * @param data The RebalanceData struct containing information about the reallocation
     * @custom:error FleetCommanderEffectiveDepositCapExceeded Thrown when the destination Ark is already at or above
     * its maximum
     * allocation
     */
    function _reallocateAssets(RebalanceData memory data) internal {
        IArk toArk = IArk(data.toArk);
        IArk fromArk = IArk(data.fromArk);
        uint256 amount;
        if (data.amount == Constants.MAX_UINT256) {
            amount = fromArk.totalAssets();
        } else {
            amount = data.amount;
        }
        // The validation has to take into account the actual amount that will be moved
        _validateReallocateAssets(data.fromArk, data.toArk, amount);

        uint256 toArkDepositCap = getEffectiveArkDepositCap(toArk);
        uint256 toArkAllocation = toArk.totalAssets();

        if (toArkAllocation + amount > toArkDepositCap) {
            revert FleetCommanderEffectiveDepositCapExceeded(
                address(toArk),
                amount,
                toArkDepositCap
            );
        }

        _move(
            address(fromArk),
            address(toArk),
            amount,
            data.boardData,
            data.disembarkData
        );
    }
    /**
     * @notice Calculates the effective deposit cap for an Ark
     * @dev This function returns the lower of two caps: a percentage-based cap derived from TVL,
     *      and the absolute deposit cap set for the Ark
     * @param ark The address of the Ark
     * @return The effective deposit cap in token units
     */

    function getEffectiveArkDepositCap(IArk ark) public view returns (uint256) {
        uint256 tvl = this.totalAssets();
        uint256 pctBasedCap = tvl.applyPercentage(
            ark.maxDepositPercentageOfTVL()
        );
        return Math.min(pctBasedCap, ark.depositCap());
    }

    /**
     * @notice Withdraws assets from multiple arks in a specific order
     * @dev This function attempts to withdraw the requested amount from arks,
     *      that allow such operations, in the order of total assets held
     * @param assets The total amount of assets to withdraw
     */
    function _forceDisembarkFromSortedArks(uint256 assets) internal {
        ArkData[] memory withdrawableArks = _getWithdrawableArksDataFromCache();
        for (uint256 i = 0; i < withdrawableArks.length; i++) {
            uint256 assetsInArk = withdrawableArks[i].totalAssets;
            if (assetsInArk >= assets) {
                _disembark(withdrawableArks[i].arkAddress, assets);
                break;
            } else if (assetsInArk > 0) {
                _disembark(withdrawableArks[i].arkAddress, assetsInArk);
                assets -= assetsInArk;
            }
        }
    }

    /* INTERNAL - VALIDATIONS */

    /**
     * @notice Validates the data for adjusting the buffer
     * @dev This function checks if all operations in the rebalance data are consistent
     *      (either all moving to buffer or all moving from buffer) and ensures that
     *      the buffer balance remains above the minimum required balance.
     *      When moving to the buffer, using MAX_UINT256 as the amount will move all funds from the source Ark.
     * @param rebalanceData An array of RebalanceData structs containing the rebalance operations
     * @custom:error FleetCommanderNoExcessFunds Thrown when trying to move funds out of an already minimum buffer
     * @custom:error FleetCommanderInsufficientBuffer Thrown when trying to move more funds than available excess
     * @custom:error FleetCommanderCantUseMaxUintMovingFromBuffer Thrown when trying to use MAX_UINT256 amount when
     * moving from buffer
     */
    function _validateAdjustBuffer(
        RebalanceData[] calldata rebalanceData
    ) internal view {
        uint256 initialBufferBalance = config.bufferArk.totalAssets();
        int256 netBufferChange;
        address _bufferArkAddress = address(config.bufferArk);
        for (uint256 i = 0; i < rebalanceData.length; i++) {
            if (
                rebalanceData[i].toArk == _bufferArkAddress ||
                rebalanceData[i].fromArk == _bufferArkAddress
            ) {
                bool isMovingToBuffer = rebalanceData[i].toArk ==
                    _bufferArkAddress;
                uint256 amount = rebalanceData[i].amount;
                if (amount == Constants.MAX_UINT256) {
                    if (!isMovingToBuffer) {
                        revert FleetCommanderCantUseMaxUintMovingFromBuffer();
                    }
                    amount = IArk(rebalanceData[i].fromArk).totalAssets();
                }
                if (isMovingToBuffer) {
                    netBufferChange += int256(amount);
                } else {
                    netBufferChange -= int256(amount);
                }
            }
        }
        if (netBufferChange < 0) {
            _validateBufferExcessFunds(
                initialBufferBalance,
                uint256(-netBufferChange)
            );
        }
    }

    /**
     * @notice Validates that there are sufficient excess funds in the buffer for withdrawal
     * @dev This function checks two conditions:
     *      1. The initial buffer balance is greater than the minimum required balance
     *      2. The amount to move does not exceed the excess funds in the buffer
     * @param initialBufferBalance The current balance of the buffer before the adjustment
     * @param totalToMove The total amount of assets to be moved from the buffer
     * @custom:error FleetCommanderNoExcessFunds Thrown when the buffer balance is at or below the minimum required
     * balance
     * @custom:error FleetCommanderInsufficientBuffer Thrown when the amount to move exceeds the available excess funds
     * in the buffer
     */
    function _validateBufferExcessFunds(
        uint256 initialBufferBalance,
        uint256 totalToMove
    ) internal view {
        uint256 minimumBufferBalance = config.minimumBufferBalance;
        if (initialBufferBalance <= minimumBufferBalance) {
            revert FleetCommanderNoExcessFunds();
        }
        uint256 excessFunds = initialBufferBalance - minimumBufferBalance;
        if (totalToMove > excessFunds) {
            revert FleetCommanderInsufficientBuffer();
        }
    }

    /**
     * @notice Validates the asset reallocation data for correctness and consistency
     * @dev This function checks various conditions of the rebalance operations:
     *      - Number of operations is within limits
     * @param rebalanceData An array of RebalanceData structs containing the rebalance operations
     */
    function _validateReallocateAllAssets(
        RebalanceData[] calldata rebalanceData
    ) internal view {
        if (rebalanceData.length > config.maxRebalanceOperations) {
            revert FleetCommanderRebalanceTooManyOperations(
                rebalanceData.length
            );
        }
        if (rebalanceData.length == 0) {
            revert FleetCommanderRebalanceNoOperations();
        }
    }

    /**
     * @notice Validates the reallocation of assets between two ARKs.
     * @param fromArk The address of the source ARK.
     * @param toArk The address of the destination ARK.
     * @param amount The amount of assets to be reallocated.
     * @custom:error FleetCommanderRebalanceAmountZero if the amount is zero.
     * @custom:error FleetCommanderArkNotFound if the source or destination ARK is not found.
     * @custom:error FleetCommanderArkNotActive if the source or destination ARK is not active.
     * @custom:error FleetCommanderExceedsMaxOutflow if the amount exceeds the maximum move from limit of the source
     * ARK.
     * @custom:error FleetCommanderExceedsMaxInflow if the amount exceeds the maximum move to limit of the destination
     * ARK.
     * @custom:error FleetCommanderArkDepositCapZero if the deposit cap of the destination ARK is zero.
     */
    function _validateReallocateAssets(
        address fromArk,
        address toArk,
        uint256 amount
    ) internal {
        if (amount == 0) {
            revert FleetCommanderRebalanceAmountZero(toArk);
        }
        if (toArk == address(0)) {
            revert FleetCommanderArkNotFound(toArk);
        }
        if (fromArk == address(0)) {
            revert FleetCommanderArkNotFound(fromArk);
        }
        if (!isArkActiveOrBufferArk(toArk)) {
            revert FleetCommanderArkNotActive(toArk);
        }
        if (!isArkActiveOrBufferArk(fromArk)) {
            revert FleetCommanderArkNotActive(fromArk);
        }
        if (IArk(toArk).depositCap() == 0) {
            revert FleetCommanderArkDepositCapZero(toArk);
        }
        (
            uint256 inflowBalance,
            uint256 outflowBalance,
            uint256 maxRebalanceInflow,
            uint256 maxRebalanceOutflow
        ) = _cacheArkFlow(fromArk, toArk, amount);
        if (outflowBalance > maxRebalanceOutflow) {
            revert FleetCommanderExceedsMaxOutflow(
                fromArk,
                outflowBalance,
                maxRebalanceOutflow
            );
        }
        if (inflowBalance > maxRebalanceInflow) {
            revert FleetCommanderExceedsMaxInflow(
                toArk,
                inflowBalance,
                maxRebalanceInflow
            );
        }
    }

    /**
     * @notice Validates the withdraw request
     * @dev This function checks two conditions:
     *      1. The caller is authorized to withdraw on behalf of the owner
     *      2. The withdrawal amount does not exceed the maximum allowed
     * @param assets The amount of assets to withdraw
     * @param shares The number of shares to redeem
     * @param owner The address of the owner of the assets
     * @custom:error FleetCommanderUnauthorizedWithdrawal Thrown when the caller is not authorized to withdraw
     * @custom:error IERC4626ExceededMaxWithdraw Thrown when the withdrawal amount exceeds the maximum allowed
     * @custom:error FleetCommanderZeroAmount Thrown when the withdrawal amount is zero
     */
    function _validateBufferWithdraw(
        uint256 assets,
        uint256 shares,
        address owner
    ) internal view {
        if (shares == 0) {
            revert FleetCommanderZeroAmount();
        }
        if (
            _msgSender() != owner &&
            IERC20(address(this)).allowance(owner, _msgSender()) < shares
        ) {
            revert FleetCommanderUnauthorizedWithdrawal(_msgSender(), owner);
        }
        uint256 maxAssets = maxBufferWithdraw(owner);
        if (assets > maxAssets) {
            revert ERC4626ExceededMaxWithdraw(owner, assets, maxAssets);
        }
    }

    /**
     * @notice Validates the redemption request
     * @dev This function checks two conditions:
     *      1. The caller is authorized to redeem on behalf of the owner
     *      2. The redemption amount does not exceed the maximum allowed
     * @param shares The number of shares to redeem
     * @param owner The address of the owner of the shares
     * @custom:error FleetCommanderUnauthorizedRedemption Thrown when the caller is not authorized to redeem
     * @custom:error IERC4626ExceededMaxRedeem Thrown when the redemption amount exceeds the maximum allowed
     * @custom:error FleetCommanderZeroAmount Thrown when the redemption amount is zero
     */
    function _validateBufferRedeem(
        uint256 shares,
        address owner
    ) internal view {
        if (shares == 0) {
            revert FleetCommanderZeroAmount();
        }
        if (
            _msgSender() != owner &&
            IERC20(address(this)).allowance(owner, _msgSender()) < shares
        ) {
            revert FleetCommanderUnauthorizedRedemption(_msgSender(), owner);
        }

        uint256 maxShares = maxBufferRedeem(owner);
        if (shares > maxShares) {
            revert ERC4626ExceededMaxRedeem(owner, shares, maxShares);
        }
    }

    /**
     * @notice Validates the deposit request
     * @dev This function checks if the requested deposit amount exceeds the maximum allowed
     * @param assets The amount of assets to deposit
     * @param owner The address of the account making the deposit
     * @custom:error FleetCommanderZeroAmount Thrown when the deposit amount is zero
     * @custom:error IERC4626ExceededMaxDeposit Thrown when the deposit amount exceeds the maximum allowed
     */
    function _validateDeposit(uint256 assets, address owner) internal view {
        if (assets == 0) {
            revert FleetCommanderZeroAmount();
        }
        uint256 maxAssets = maxDeposit(owner);
        if (assets > maxAssets) {
            revert ERC4626ExceededMaxDeposit(owner, assets, maxAssets);
        }
    }

    /**
     * @notice Validates the mint request
     * @dev This function checks if the requested mint amount exceeds the maximum allowed
     * @param shares The number of shares to mint
     * @param owner The address of the account minting the shares
     * @custom:error FleetCommanderZeroAmount Thrown when the mint amount is zero
     * @custom:error IERC4626ExceededMaxMint Thrown when the mint amount exceeds the maximum allowed
     */
    function _validateMint(uint256 shares, address owner) internal view {
        if (shares == 0) {
            revert FleetCommanderZeroAmount();
        }
        uint256 maxShares = maxMint(owner);
        if (shares > maxShares) {
            revert ERC4626ExceededMaxMint(owner, shares, maxShares);
        }
    }

    /**
     * @notice Validates the force withdraw request
     * @dev This function checks two conditions:
     *      1. The caller is authorized to withdraw on behalf of the owner
     *      2. The withdrawal amount does not exceed the maximum allowed
     * @param assets The amount of assets to withdraw
     * @param shares The amount of shares to redeem
     * @param owner The address of the owner of the assets
     * @custom:error FleetCommanderUnauthorizedWithdrawal Thrown when the caller is not authorized to withdraw
     * @custom:error IERC4626ExceededMaxWithdraw Thrown when the withdrawal amount exceeds the maximum allowed
     * @custom:error FleetCommanderZeroAmount Thrown when the withdrawal amount is zero
     */
    function _validateWithdrawFromArks(
        uint256 assets,
        uint256 shares,
        address owner
    ) internal view {
        if (shares == 0) {
            revert FleetCommanderZeroAmount();
        }
        if (
            _msgSender() != owner &&
            IERC20(address(this)).allowance(owner, _msgSender()) < shares
        ) {
            revert FleetCommanderUnauthorizedWithdrawal(_msgSender(), owner);
        }
        uint256 maxAssets = maxWithdraw(owner);

        if (assets > maxAssets) {
            revert ERC4626ExceededMaxWithdraw(owner, assets, maxAssets);
        }
    }

    /**
     * @notice Validates the force redeem request
     * @dev This function checks two conditions:
     *      1. The caller is authorized to redeem on behalf of the owner
     *      2. The redemption amount does not exceed the maximum allowed
     * @param shares The amount of shares to redeem
     * @param owner The address of the owner of the assets
     * @custom:error FleetCommanderUnauthorizedRedemption Thrown when the caller is not authorized to redeem
     * @custom:error IERC4626ExceededMaxRedeem Thrown when the redemption amount exceeds the maximum allowed
     * @custom:error FleetCommanderZeroAmount Thrown when the redemption amount is zero
     */
    function _validateRedeemFromArks(
        uint256 shares,
        address owner
    ) internal view {
        if (shares == 0) {
            revert FleetCommanderZeroAmount();
        }
        if (
            _msgSender() != owner &&
            IERC20(address(this)).allowance(owner, _msgSender()) < shares
        ) {
            revert FleetCommanderUnauthorizedRedemption(_msgSender(), owner);
        }
        uint256 maxShares = maxRedeem(owner);
        if (shares > maxShares) {
            revert ERC4626ExceededMaxRedeem(owner, shares, maxShares);
        }
    }

    function _getActiveArksAddresses()
        internal
        view
        override(FleetCommanderCache)
        returns (address[] memory)
    {
        return getActiveArks();
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import {StorageSlot} from "@summerfi/dependencies/openzeppelin-next/StorageSlot.sol";

import {IArk} from "../interfaces/IArk.sol";
import {ArkData} from "../types/FleetCommanderTypes.sol";
import {StorageSlots} from "./libraries/StorageSlots.sol";

/**
 * @title FleetCommanderCache - Caching System
 * @dev This contract implements a caching mechanism
 *      for efficient asset tracking and operations.
 *
 * Caching System:
 * 1. Purpose: The caching system is designed to optimize gas costs and improve performance
 *    for operations that require frequent access to total assets and ark data.
 *
 * 2. Key Components:
 *    - FleetCommanderCache: A contract that this FleetCommander inherits from, providing
 *      caching functionality.
 *    - Cache Modifiers: 'useDepositCache' and 'useWithdrawCache' are used to manage the
 *      caching lifecycle for deposit and withdrawal operations.
 *
 * 3. Caching Mechanism:
 *    - Before Operation: The cache is populated with current ark data.
 *    - During Operation: The contract uses cached data instead of making repeated calls to arks.
 *    - After Operation: The cache is flushed to ensure data freshness for subsequent operations.
 *
 * 4. Benefits:
 *    - Gas Optimization: Reduces the number of external calls to arks, saving gas.
 *    - Consistency: Ensures that a single operation uses consistent data throughout its execution.
 *
 * 5. Cache Usage:
 *    - Deposit Operations: Uses 'useDepositCache' modifier to cache all ark data.
 *    - Withdrawal Operations: Uses 'useWithdrawCache' modifier to cache data for withdrawable arks.
 *    - Rebalance Operations: Does not use cache as it directly interacts with arks.
 *
 * 6. Cache Management:
 *    - Cache population: Performed by '_getArksData' and '_getWithdrawableArksData' functions.
 *    - Cache flushing: Done by '_flushCache' function after each operation.
 *
 * This caching system is crucial for maintaining efficient operations in the FleetCommander,
 * especially when dealing with multiple arks and frequent asset calculations.
 */
contract FleetCommanderCache {
    using StorageSlot for *;

    /**
     * @dev Checks if the FleetCommander is currently performing a trnsaction that includes a tip
     * @return bool True if collecting tips, false otherwise
     */
    function _isCollectingTip() internal view returns (bool) {
        return StorageSlots.TIP_TAKEN_STORAGE.asBoolean().tload();
    }

    /**
     * @dev Sets the isCollectingTip flag
     * @param value The value to set the flag to
     */
    function _setIsCollectingTip(bool value) internal {
        StorageSlots.TIP_TAKEN_STORAGE.asBoolean().tstore(value);
    }

    /**
     * @dev Calculates the total assets across all arks
     * @param bufferArk The buffer ark instance
     * @return total The sum of total assets across all arks
     * @custom:internal-logic
     * - Checks if total assets are cached
     * - If cached, returns the cached value
     * - If not cached, calculates the sum of total assets across all arks
     * @custom:effects
     * - No state changes
     * @custom:security-considerations
     * - Relies on accurate reporting of total assets by individual arks
     * - Caching mechanism must be properly managed to ensure data freshness
     * - Assumes no changes in total assets throughout the execution of function that use this cache
     */
    function _totalAssets(
        IArk bufferArk
    ) internal view returns (uint256 total) {
        bool isTotalAssetsCached = StorageSlots
            .IS_TOTAL_ASSETS_CACHED_STORAGE
            .asBoolean()
            .tload();
        if (isTotalAssetsCached) {
            return StorageSlots.TOTAL_ASSETS_STORAGE.asUint256().tload();
        }
        return
            _sumTotalAssets(_getAllArks(_getActiveArksAddresses(), bufferArk));
    }

    /**
     * @dev Calculates the total assets of withdrawable arks
     * @param bufferArk The buffer ark instance
     * @return withdrawableTotalAssets The sum of total assets across withdrawable arks
     *  - arks that don't require additional data to be boarded or disembarked from.
     * @custom:internal-logic
     * - Checks if withdrawable total assets are cached
     * - If cached, returns the cached value
     * - If not cached, calculates the sum of total assets across withdrawable arks
     * @custom:effects
     * - No state changes
     * @custom:security-considerations
     * - Relies on accurate reporting of total assets by individual arks
     * - Depends on the correctness of the withdrawableTotalAssets function
     */
    function _withdrawableTotalAssets(
        IArk bufferArk
    ) internal view returns (uint256 withdrawableTotalAssets) {
        bool isWithdrawableTotalAssetsCached = StorageSlots
            .IS_WITHDRAWABLE_ARKS_TOTAL_ASSETS_CACHED_STORAGE
            .asBoolean()
            .tload();
        if (isWithdrawableTotalAssetsCached) {
            return
                StorageSlots
                    .WITHDRAWABLE_ARKS_TOTAL_ASSETS_STORAGE
                    .asUint256()
                    .tload();
        }

        IArk[] memory allArks = _getAllArks(
            _getActiveArksAddresses(),
            bufferArk
        );
        for (uint256 i = 0; i < allArks.length; i++) {
            uint256 withdrawableAssets = IArk(allArks[i])
                .withdrawableTotalAssets();
            if (withdrawableAssets > 0) {
                withdrawableTotalAssets += withdrawableAssets;
            }
        }
    }

    /**
     * @dev Retrieves an array of all Arks, including regular Arks and the buffer Ark
     * @param arks Array of regular ark addresses
     * @param bufferArk The buffer ark instance
     * @return An array of IArk interfaces representing all Arks in the system
     * @custom:internal-logic
     * - Creates a new array with length of regular arks plus one (for buffer ark)
     * - Populates the array with regular arks and appends the buffer ark
     * @custom:effects
     * - No state changes
     * @custom:security-considerations
     * - Ensures the buffer ark is always included at the end of the array
     */
    function _getAllArks(
        address[] memory arks,
        IArk bufferArk
    ) private pure returns (IArk[] memory) {
        IArk[] memory allArks = new IArk[](arks.length + 1);
        for (uint256 i = 0; i < arks.length; i++) {
            allArks[i] = IArk(arks[i]);
        }
        allArks[arks.length] = IArk(bufferArk);
        return allArks;
    }

    /**
     * @dev Calculates the sum of total assets across all provided Arks
     * @param _arks An array of IArk interfaces representing the Arks to sum assets from
     * @return total The sum of total assets across all provided Arks
     * @custom:internal-logic
     * - Iterates through the provided array of Arks
     * - Accumulates the total assets from each Ark
     * @custom:effects
     * - No state changes
     * @custom:security-considerations
     * - Relies on accurate reporting of total assets by individual arks
     * - Vulnerable to integer overflow if total assets become extremely large
     */
    function _sumTotalAssets(
        IArk[] memory _arks
    ) private view returns (uint256 total) {
        for (uint256 i = 0; i < _arks.length; i++) {
            total += _arks[i].totalAssets();
        }
    }

    /**
     * @dev Flushes the cache for all arks and related data
     * @custom:internal-logic
     * - Resets the cached data for all arks and related data
     * @custom:effects
     * - Sets IS_TOTAL_ASSETS_CACHED_STORAGE to false
     * - Sets IS_WITHDRAWABLE_ARKS_TOTAL_ASSETS_CACHED_STORAGE to false
     * - Resets WITHDRAWABLE_ARKS_LENGTH_STORAGE to 0
     * - Resets ARKS_LENGTH_STORAGE to 0
     * @custom:security-considerations
     * - Ensures that the next call to totalAssets or withdrawableTotalAssets recalculates values
     * - Critical for maintaining data freshness and preventing stale cache issues
     * - Flushes cache in case of reentrancy
     * - That also allows efficient testing using Forge (transient storage is persistent during single test)
     */
    function _flushCache() internal {
        StorageSlots.IS_TOTAL_ASSETS_CACHED_STORAGE.asBoolean().tstore(false);
        StorageSlots
            .IS_WITHDRAWABLE_ARKS_TOTAL_ASSETS_CACHED_STORAGE
            .asBoolean()
            .tstore(false);
        StorageSlots.WITHDRAWABLE_ARKS_LENGTH_STORAGE.asUint256().tstore(0);
        StorageSlots.ARKS_LENGTH_STORAGE.asUint256().tstore(0);
    }

    /**
     * @dev Retrieves the data (address, totalAssets) for all arks and the buffer ark
     * @param bufferArk The buffer ark instance
     * @return _arksData An array of ArkData structs containing the ark addresses and their total assets
     * @custom:internal-logic
     * - Initializes data for all arks including the buffer ark
     * - Populates data for regular arks and buffer ark
     * - Caches the total assets and ark data
     * - buffer ark is always at the end of the array
     * @custom:effects
     * - Caches total assets and ark data
     * - Modifies storage slots related to ark data
     * @custom:security-considerations
     * - Relies on accurate reporting of total assets by individual arks
     */
    function _getArksData(
        IArk bufferArk
    ) internal returns (ArkData[] memory _arksData) {
        if (StorageSlots.IS_TOTAL_ASSETS_CACHED_STORAGE.asBoolean().tload()) {
            return _getAllArksDataFromCache();
        }

        address[] memory arks = _getActiveArksAddresses();
        // Initialize data for all arks
        _arksData = new ArkData[](arks.length + 1); // +1 for buffer ark
        uint256 totalAssets = 0;

        // Populate data for regular arks
        for (uint256 i = 0; i < arks.length; i++) {
            uint256 arkAssets = IArk(arks[i]).totalAssets();
            _arksData[i] = ArkData(arks[i], arkAssets);
            totalAssets += arkAssets;
        }

        // Add buffer ark data
        uint256 bufferArkAssets = bufferArk.totalAssets();
        _arksData[arks.length] = ArkData(address(bufferArk), bufferArkAssets);
        totalAssets += bufferArkAssets;

        _cacheAllArksTotalAssets(totalAssets);
        _cacheAllArks(_arksData);
    }

    /**
     * @notice Retrieves a storage slot based on the provided prefix and index
     * @param prefix The prefix for the storage slot
     * @param index The index for the storage slot
     * @return bytes32 The storage slot value
     */
    function _getStorageSlot(
        bytes32 prefix,
        uint256 index
    ) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(prefix, index));
    }

    /**
     * @dev Caches the inflow and outflow balances for the specified Ark addresses.
     *      Updates the maximum inflow and outflow balances if they are not set.
     * @param outflowArkAddress The address of the Ark from which the outflow is occurring.
     * @param inflowArkAddress The address of the Ark to which the inflow is occurring.
     * @param amount The amount to be added to both inflow and outflow balances.
     * @return newInflowBalance The updated inflow balance for the inflow Ark.
     * @return newOutflowBalance The updated outflow balance for the outflow Ark.
     * @return maxInflow The maximum inflow balance for the inflow Ark.
     * @return maxOutflow The maximum outflow balance for the outflow Ark.
     */
    function _cacheArkFlow(
        address outflowArkAddress,
        address inflowArkAddress,
        uint256 amount
    )
        internal
        returns (
            uint256 newInflowBalance,
            uint256 newOutflowBalance,
            uint256 maxInflow,
            uint256 maxOutflow
        )
    {
        bytes32 inflowSlot = _getStorageSlot(
            StorageSlots.ARK_INFLOW_BALANCE_STORAGE,
            uint256(uint160(inflowArkAddress))
        );
        bytes32 outflowSlot = _getStorageSlot(
            StorageSlots.ARK_OUTFLOW_BALANCE_STORAGE,
            uint256(uint160(outflowArkAddress))
        );
        bytes32 maxInflowSlot = _getStorageSlot(
            StorageSlots.ARK_MAX_INFLOW_BALANCE_STORAGE,
            uint256(uint160(inflowArkAddress))
        );
        bytes32 maxOutflowSlot = _getStorageSlot(
            StorageSlots.ARK_MAX_OUTFLOW_BALANCE_STORAGE,
            uint256(uint160(outflowArkAddress))
        );

        maxInflow = maxInflowSlot.asUint256().tload();
        maxOutflow = maxOutflowSlot.asUint256().tload();

        if (maxInflow == 0) {
            maxInflow = IArk(inflowArkAddress).maxRebalanceInflow();
            maxInflowSlot.asUint256().tstore(maxInflow);
        }
        if (maxOutflow == 0) {
            maxOutflow = IArk(outflowArkAddress).maxRebalanceOutflow();
            maxOutflowSlot.asUint256().tstore(maxOutflow);
        }

        // Load current balance (if it's the first time, it will be 0)
        newInflowBalance = inflowSlot.asUint256().tload() + amount;
        newOutflowBalance = outflowSlot.asUint256().tload() + amount;

        inflowSlot.asUint256().tstore(newInflowBalance);
        outflowSlot.asUint256().tstore(newOutflowBalance);
    }

    /**
     * @notice Retrieves the data (address, totalAssets) for all withdrawable arks from cache
     * @return arksData An array of ArkData structs containing the ark addresses and their total assets
     */
    function _getWithdrawableArksDataFromCache()
        internal
        view
        returns (ArkData[] memory arksData)
    {
        uint256 arksLength = StorageSlots
            .WITHDRAWABLE_ARKS_LENGTH_STORAGE
            .asUint256()
            .tload();
        arksData = new ArkData[](arksLength);
        for (uint256 i = 0; i < arksLength; i++) {
            address arkAddress = _getStorageSlot(
                StorageSlots.WITHDRAWABLE_ARKS_ADDRESS_ARRAY_STORAGE,
                i
            ).asAddress().tload();
            uint256 totalAssets = _getStorageSlot(
                StorageSlots.WITHDRAWABLE_ARKS_TOTAL_ASSETS_ARRAY_STORAGE,
                i
            ).asUint256().tload();
            arksData[i] = ArkData(arkAddress, totalAssets);
        }
    }

    function _getAllArksDataFromCache()
        internal
        view
        returns (ArkData[] memory arksData)
    {
        uint256 arksLength = StorageSlots
            .ARKS_LENGTH_STORAGE
            .asUint256()
            .tload();
        arksData = new ArkData[](arksLength);
        for (uint256 i = 0; i < arksLength; i++) {
            address arkAddress = _getStorageSlot(
                StorageSlots.ARKS_ADDRESS_ARRAY_STORAGE,
                i
            ).asAddress().tload();
            uint256 totalAssets = _getStorageSlot(
                StorageSlots.ARKS_TOTAL_ASSETS_ARRAY_STORAGE,
                i
            ).asUint256().tload();
            arksData[i] = ArkData(arkAddress, totalAssets);
        }
    }
    /**
     * @notice Caches the data for all arks in the specified storage slots
     * @param arksData The array of ArkData structs containing the ark addresses and their total assets
     * @param totalAssetsPrefix The prefix for the ark total assets storage slot
     * @param addressPrefix The prefix for the ark addresses storage slot
     * @param lengthSlot The storage slot containing the number of arks
     */
    function _cacheArks(
        ArkData[] memory arksData,
        bytes32 totalAssetsPrefix,
        bytes32 addressPrefix,
        bytes32 lengthSlot
    ) internal {
        for (uint256 i = 0; i < arksData.length; i++) {
            _getStorageSlot(totalAssetsPrefix, i).asUint256().tstore(
                arksData[i].totalAssets
            );
            _getStorageSlot(addressPrefix, i).asAddress().tstore(
                arksData[i].arkAddress
            );
        }
        lengthSlot.asUint256().tstore(arksData.length);
    }

    /**
     * @notice Caches the data for all arks in the specified storage slots
     * @param _arksData The array of ArkData structs containing the ark addresses and their total assets
     */
    function _cacheAllArks(ArkData[] memory _arksData) internal {
        _cacheArks(
            _arksData,
            StorageSlots.ARKS_TOTAL_ASSETS_ARRAY_STORAGE,
            StorageSlots.ARKS_ADDRESS_ARRAY_STORAGE,
            StorageSlots.ARKS_LENGTH_STORAGE
        );
    }

    /**
     * @notice Caches the data for all withdrawable arks in the specified storage slots
     * @param _withdrawableArksData The array of ArkData structs containing the ark addresses and their total assets
     */
    function _cacheWithdrawableArksTotalAssetsArray(
        ArkData[] memory _withdrawableArksData
    ) internal {
        _cacheArks(
            _withdrawableArksData,
            StorageSlots.WITHDRAWABLE_ARKS_TOTAL_ASSETS_ARRAY_STORAGE,
            StorageSlots.WITHDRAWABLE_ARKS_ADDRESS_ARRAY_STORAGE,
            StorageSlots.WITHDRAWABLE_ARKS_LENGTH_STORAGE
        );
    }

    /**
     * @dev Retrieves and processes data for withdrawable arks
     * @param bufferArk The buffer ark instance
     * @custom:internal-logic
     * - Fetches data for all arks using _getArksData
     * - Filters arks based on withdrawability
     * - Accumulates total assets of withdrawable arks
     * - Resizes the array to remove empty slots
     * - Sorts the withdrawable arks by total assets
     * - Caches the processed data
     * - checks if the arks are cached, if yes skips the rest of the function
     * - cache check is important for nested calls e.g. withdraw (withdrawFromArks)
     * @custom:effects
     * - Modifies storage by caching withdrawable arks data
     * - Updates the total assets of withdrawable arks in storage
     * @custom:security-considerations
     * - Assumes the withdrawableTotalAssets function is correctly implemented by Ark contracts
     * - Uses assembly for array resizing, which bypasses Solidity's safety checks
     * - Relies on the correctness of _getArksData, _cacheWithdrawableArksTotalAssets,
     *   _sortArkDataByTotalAssets, and _cacheWithdrawableArksTotalAssetsArray functions
     */
    function _getWithdrawableArksData(IArk bufferArk) internal {
        if (
            StorageSlots
                .IS_WITHDRAWABLE_ARKS_TOTAL_ASSETS_CACHED_STORAGE
                .asBoolean()
                .tload()
        ) {
            return;
        }
        ArkData[] memory _arksData = _getArksData(bufferArk);
        // Initialize data for withdrawable arks
        ArkData[] memory _withdrawableArksData = new ArkData[](
            _arksData.length
        );
        uint256 withdrawableTotalAssets = 0;
        uint256 withdrawableCount = 0;

        // Populate data for withdrawable arks
        for (uint256 i = 0; i < _arksData.length; i++) {
            uint256 withdrawableAssets = IArk(_arksData[i].arkAddress)
                .withdrawableTotalAssets();
            if (withdrawableAssets > 0) {
                // overwrite the ArkData struct with the withdrawable assets
                _withdrawableArksData[withdrawableCount] = ArkData(
                    _arksData[i].arkAddress,
                    withdrawableAssets
                );

                withdrawableTotalAssets += withdrawableAssets;
                withdrawableCount++;
            }
        }

        // Resize _withdrawableArksData array to remove empty slots
        assembly {
            mstore(_withdrawableArksData, withdrawableCount)
        }
        _cacheWithdrawableArksTotalAssets(withdrawableTotalAssets);
        _sortArkDataByTotalAssets(_withdrawableArksData);
        _cacheWithdrawableArksTotalAssetsArray(_withdrawableArksData);
    }

    /**
     * @notice Caches the total assets for all arks in the specified storage slot
     * @param totalAssets The total assets to cache
     */
    function _cacheAllArksTotalAssets(uint256 totalAssets) internal {
        StorageSlots.TOTAL_ASSETS_STORAGE.asUint256().tstore(totalAssets);
        StorageSlots.IS_TOTAL_ASSETS_CACHED_STORAGE.asBoolean().tstore(true);
    }

    /**
     * @notice Caches the total assets for all withdrawable arks in the specified storage slot
     * @param withdrawableTotalAssets The total assets to cache
     */
    function _cacheWithdrawableArksTotalAssets(
        uint256 withdrawableTotalAssets
    ) internal {
        StorageSlots.WITHDRAWABLE_ARKS_TOTAL_ASSETS_STORAGE.asUint256().tstore(
            withdrawableTotalAssets
        );
        StorageSlots
            .IS_WITHDRAWABLE_ARKS_TOTAL_ASSETS_CACHED_STORAGE
            .asBoolean()
            .tstore(true);
    }

    /**
     * @dev Sorts the ArkData structs based on their total assets in ascending order
     * @param arkDataArray An array of ArkData structs to be sorted
     * @custom:internal-logic
     * - Implements a simple bubble sort algorithm
     * - Compares adjacent elements and swaps them if they are in the wrong order
     * - Continues until no more swaps are needed
     * @custom:effects
     * - Modifies the input array in-place, sorting it by totalAssets
     * @custom:security-considerations
     * - Time complexity is O(n^2), which may be inefficient for large arrays
     * - Assumes that the totalAssets values fit within uint256 and won't overflow during comparisons
     */
    function _sortArkDataByTotalAssets(
        ArkData[] memory arkDataArray
    ) internal pure {
        for (uint256 i = 0; i < arkDataArray.length; i++) {
            for (uint256 j = i + 1; j < arkDataArray.length; j++) {
                if (arkDataArray[i].totalAssets > arkDataArray[j].totalAssets) {
                    (arkDataArray[i], arkDataArray[j]) = (
                        arkDataArray[j],
                        arkDataArray[i]
                    );
                }
            }
        }
    }

    /**
     * @notice Returns an array of addresses for all currently active Arks in the fleet
     * @dev This is an abstract internal function that must be implemented by the FleetCommander contract
     *      It serves as a critical component in the caching system for efficient ark management
     *
     * @return address[] An array containing the addresses of all active Arks
     *
     * @custom:purpose
     * - Provides the foundation for the caching system by identifying which Arks are currently active
     * - Used by _getArksData and _getWithdrawableArksData to populate cache data
     * - Essential for operations that need to iterate over or manage all active Arks
     * - Defined as virtual to be overridden by the FleetCommander contract and avoid calling it before it's required
     *
     * @custom:implementation-notes
     * - Must be implemented by the inheriting FleetCommander contract
     * - Should return a fresh array of addresses each time it's called
     * - Buffer Ark should NOT be included in this list (it's handled separately)
     * - Only truly active and operational Arks should be included
     *
     * @custom:related-functions
     * - _getArksData: Uses this function to get data for all active Arks
     * - _getWithdrawableArksData: Uses this function to identify withdrawable Arks
     * - _getAllArks: Combines these addresses with the buffer Ark
     */
    function _getActiveArksAddresses()
        internal
        view
        virtual
        returns (address[] memory)
    {}
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import {IArk} from "../interfaces/IArk.sol";
import {FleetCommanderParams} from "../types/FleetCommanderTypes.sol";
import {FleetCommanderPausable} from "./FleetCommanderPausable.sol";

import {IFleetCommanderConfigProvider} from "../interfaces/IFleetCommanderConfigProvider.sol";

import {IFleetCommanderRewardsManagerFactory} from "../interfaces/IFleetCommanderRewardsManagerFactory.sol";
import {FleetConfig} from "../types/FleetCommanderTypes.sol";
import {ConfigurationManaged} from "./ConfigurationManaged.sol";
import {FleetCommanderRewardsManager} from "./FleetCommanderRewardsManager.sol";
import {ArkParams, BufferArk} from "./arks/BufferArk.sol";

import {IERC4626} from "@openzeppelin/contracts/interfaces/IERC4626.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {ProtocolAccessManaged} from "@summerfi/access-contracts/contracts/ProtocolAccessManaged.sol";
import {ContractSpecificRoles, IProtocolAccessManager} from "@summerfi/access-contracts/interfaces/IProtocolAccessManager.sol";
import {Constants} from "@summerfi/constants/Constants.sol";
import {PERCENTAGE_100, Percentage} from "@summerfi/percentage-solidity/contracts/Percentage.sol";

/**
 * @title FleetCommanderConfigProvider
 * @author SummerFi
 * @notice This contract provides configuration management for the FleetCommander
 * @custom:see IFleetCommanderConfigProvider
 */
contract FleetCommanderConfigProvider is
    ProtocolAccessManaged,
    FleetCommanderPausable,
    ConfigurationManaged,
    IFleetCommanderConfigProvider
{
    using EnumerableSet for EnumerableSet.AddressSet;

    FleetConfig public config;
    string public details;
    EnumerableSet.AddressSet private _activeArks;

    uint256 public constant MAX_REBALANCE_OPERATIONS = 50;
    uint256 public constant INITIAL_MINIMUM_PAUSE_TIME = 2 days;

    bool public transfersEnabled;

    constructor(
        FleetCommanderParams memory params
    )
        ProtocolAccessManaged(params.accessManager)
        FleetCommanderPausable(INITIAL_MINIMUM_PAUSE_TIME)
        ConfigurationManaged(params.configurationManager)
    {
        BufferArk _bufferArk = new BufferArk(
            ArkParams({
                name: "BufferArk",
                details: "BufferArk details",
                accessManager: address(params.accessManager),
                asset: params.asset,
                configurationManager: address(params.configurationManager),
                depositCap: Constants.MAX_UINT256,
                maxRebalanceOutflow: Constants.MAX_UINT256,
                maxRebalanceInflow: Constants.MAX_UINT256,
                requiresKeeperData: false,
                maxDepositPercentageOfTVL: PERCENTAGE_100
            }),
            address(this)
        );
        emit ArkAdded(address(_bufferArk));
        config = FleetConfig({
            bufferArk: IArk(address(_bufferArk)),
            minimumBufferBalance: params.initialMinimumBufferBalance,
            depositCap: params.depositCap,
            maxRebalanceOperations: MAX_REBALANCE_OPERATIONS,
            stakingRewardsManager: IFleetCommanderRewardsManagerFactory(
                fleetCommanderRewardsManagerFactory()
            ).createRewardsManager(address(_accessManager), address(this))
        });
        details = params.details;
    }

    /**
     * @dev Modifier to restrict function access to only active Arks (excluding the buffer ark)
     * @param arkAddress The address of the Ark to check
     * @custom:internal-logic
     * - Checks if the provided arkAddress is in the _activeArks set
     * - If not found, reverts with FleetCommanderArkNotFound error
     * - If the arkAddress is the buffer ark, it will revert, due to the buffer ark being a special case
     * @custom:effects
     * - No direct state changes, but may revert the transaction
     * @custom:security-considerations
     * - Ensures that only active Arks can perform certain operations
     * - Prevents unauthorized access from inactive or non-existent Arks
     * - Critical for maintaining the integrity and security of Ark-specific operations
     */
    modifier onlyActiveArk(address arkAddress) {
        if (!_activeArks.contains(arkAddress)) {
            revert FleetCommanderArkNotFound(arkAddress);
        }
        _;
    }

    ///@inheritdoc IFleetCommanderConfigProvider
    function isArkActiveOrBufferArk(
        address arkAddress
    ) public view returns (bool) {
        return
            _activeArks.contains(arkAddress) ||
            arkAddress == address(config.bufferArk);
    }

    ///@inheritdoc IFleetCommanderConfigProvider
    function arks(uint256 index) public view returns (address) {
        return _activeArks.at(index);
    }

    ///@inheritdoc IFleetCommanderConfigProvider
    function getActiveArks() public view returns (address[] memory) {
        return _activeArks.values();
    }

    ///@inheritdoc IFleetCommanderConfigProvider
    function getConfig() external view override returns (FleetConfig memory) {
        return config;
    }

    ///@inheritdoc IFleetCommanderConfigProvider
    function bufferArk() external view returns (address) {
        return address(config.bufferArk);
    }

    // ARK MANAGEMENT

    ///@inheritdoc IFleetCommanderConfigProvider
    function addArk(address ark) external onlyGovernor whenNotPaused {
        _addArk(ark);
    }

    ///@inheritdoc IFleetCommanderConfigProvider
    function removeArk(address ark) external onlyGovernor whenNotPaused {
        _removeArk(ark);
    }

    ///@inheritdoc IFleetCommanderConfigProvider
    function setArkDepositCap(
        address ark,
        uint256 newDepositCap
    ) external onlyCurator(address(this)) onlyActiveArk(ark) whenNotPaused {
        IArk(ark).setDepositCap(newDepositCap);
    }

    ///@inheritdoc IFleetCommanderConfigProvider
    function setArkMaxDepositPercentageOfTVL(
        address ark,
        Percentage newMaxDepositPercentageOfTVL
    ) external onlyCurator(address(this)) onlyActiveArk(ark) whenNotPaused {
        IArk(ark).setMaxDepositPercentageOfTVL(newMaxDepositPercentageOfTVL);
    }

    ///@inheritdoc IFleetCommanderConfigProvider
    function setArkMaxRebalanceOutflow(
        address ark,
        uint256 newMaxRebalanceOutflow
    ) external onlyCurator(address(this)) onlyActiveArk(ark) whenNotPaused {
        IArk(ark).setMaxRebalanceOutflow(newMaxRebalanceOutflow);
    }

    ///@inheritdoc IFleetCommanderConfigProvider
    function setArkMaxRebalanceInflow(
        address ark,
        uint256 newMaxRebalanceInflow
    ) external onlyCurator(address(this)) onlyActiveArk(ark) whenNotPaused {
        IArk(ark).setMaxRebalanceInflow(newMaxRebalanceInflow);
    }

    ///@inheritdoc IFleetCommanderConfigProvider
    function setMinimumBufferBalance(
        uint256 newMinimumBalance
    ) external onlyCurator(address(this)) whenNotPaused {
        config.minimumBufferBalance = newMinimumBalance;
        emit FleetCommanderminimumBufferBalanceUpdated(newMinimumBalance);
    }

    ///@inheritdoc IFleetCommanderConfigProvider
    function setFleetDepositCap(
        uint256 newCap
    ) external onlyCurator(address(this)) whenNotPaused {
        config.depositCap = newCap;
        emit FleetCommanderDepositCapUpdated(newCap);
    }

    ///@inheritdoc IFleetCommanderConfigProvider
    function updateStakingRewardsManager()
        external
        onlyCurator(address(this))
        whenNotPaused
    {
        config.stakingRewardsManager = IFleetCommanderRewardsManagerFactory(
            fleetCommanderRewardsManagerFactory()
        ).createRewardsManager(address(_accessManager), address(this));
        emit FleetCommanderStakingRewardsUpdated(config.stakingRewardsManager);
    }

    ///@inheritdoc IFleetCommanderConfigProvider
    function setMaxRebalanceOperations(
        uint256 newMaxRebalanceOperations
    ) external onlyCurator(address(this)) whenNotPaused {
        if (newMaxRebalanceOperations > MAX_REBALANCE_OPERATIONS) {
            revert FleetCommanderMaxRebalanceOperationsTooHigh(
                newMaxRebalanceOperations
            );
        }
        config.maxRebalanceOperations = newMaxRebalanceOperations;
        emit FleetCommanderMaxRebalanceOperationsUpdated(
            newMaxRebalanceOperations
        );
    }

    ///@inheritdoc IFleetCommanderConfigProvider
    function setFleetTokenTransferability()
        external
        onlyGovernor
        whenNotPaused
    {
        if (!transfersEnabled) {
            transfersEnabled = true;
            emit TransfersEnabled();
        }
    }

    // INTERNAL FUNCTIONS
    /**
     * @dev Internal function to add a new Ark to the fleet
     * @param ark The address of the Ark to be added
     * @custom:internal-logic
     * - Checks if the ark address is valid (not zero)
     * - Verifies the ark is not already active
     * - Sets the ark as active and determines its withdrawability
     * - Checks if the ark already has a commander
     * - Registers this contract as the ark's FleetCommander
     * - Adds the ark to the list of active arks
     * @custom:effects
     * - Modifies isArkActiveOrBufferArk mapping
     * - Updates the arks array
     * - Emits an ArkAdded event
     * @custom:security-considerations
     * - Ensures no duplicate arks are added
     * - Prevents adding arks that already have a commander
     * - Only callable internally, typically by privileged roles
     */
    function _addArk(address ark) internal {
        if (ark == address(0)) {
            revert FleetCommanderInvalidArkAddress();
        }
        if (isArkActiveOrBufferArk(ark)) {
            revert FleetCommanderArkAlreadyExists(ark);
        }
        if (address(IArk(ark).asset()) != IERC4626(address(this)).asset()) {
            revert FleetCommanderAssetMismatch();
        }
        IArk(ark).registerFleetCommander();
        _activeArks.add(ark);
        emit ArkAdded(ark);
    }

    /**
     * @dev Internal function to remove an Ark from the fleet
     * @param ark The address of the Ark to be removed
     * @custom:internal-logic
     * - Checks if the ark is currently active
     * - Locates and removes the ark from the active arks list
     * - Validates that the ark can be safely removed
     * - Marks the ark as inactive
     * - Unregisters this contract as the ark's FleetCommander
     * - Revokes the COMMANDER_ROLE for this contract on the ark
     * @custom:effects
     * - Modifies the isArkActiveOrBufferArk mapping
     * - Updates the arks array
     * - Changes the ark's FleetCommander status
     * - Revokes a role in the access manager
     * - Emits an ArkRemoved event
     * @custom:security-considerations
     * - Ensures only active arks can be removed
     * - Validates ark state before removal to prevent inconsistencies
     * - Only callable internally, typically by privileged roles
     */
    function _removeArk(address ark) internal onlyActiveArk(ark) {
        _validateArkRemoval(ark);
        _activeArks.remove(ark);

        IArk(ark).unregisterFleetCommander();
        _accessManager.selfRevokeContractSpecificRole(
            ContractSpecificRoles.COMMANDER_ROLE,
            address(ark)
        );
        emit ArkRemoved(ark);
    }

    /**
     * @dev Internal function to validate if an Ark can be safely removed
     * @param ark The address of the Ark to be validated for removal
     * @custom:internal-logic
     * - Checks if the ark's deposit cap is zero
     * - Verifies that the ark holds no assets
     * @custom:effects
     * - No direct state changes, but may revert the transaction
     * @custom:security-considerations
     * - Prevents removal of arks with non-zero deposit caps or assets
     * - Ensures arks are in a safe state before removal
     * - Critical for maintaining the integrity of the fleet
     */
    function _validateArkRemoval(address ark) internal view {
        IArk _ark = IArk(ark);
        if (_ark.depositCap() > 0) {
            revert FleetCommanderArkDepositCapGreaterThanZero(ark);
        }
        if (_ark.totalAssets() != 0) {
            revert FleetCommanderArkAssetsNotZero(ark);
        }
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";

/// @title FleetCommanderPausable
/// @notice An abstract contract that extends OpenZeppelin's Pausable with a minimum pause time functionality
/// @dev This contract should be inherited by other contracts that require a minimum pause duration
abstract contract FleetCommanderPausable is Pausable {
    /// @notice The minimum duration that the contract must remain paused
    uint256 public minimumPauseTime;

    /// @notice The timestamp when the contract was last paused
    uint256 public pauseStartTime;

    /// @notice The minimum duration that the contract must remain paused
    uint256 constant MINIMUM_PAUSE_TIME_SECONDS = 2 days;

    /// @notice Emitted when the minimum pause time is updated
    /// @param newMinimumPauseTime The new minimum pause time value
    event MinimumPauseTimeUpdated(uint256 newMinimumPauseTime);

    /// @notice Error thrown when trying to unpause before the minimum pause time has elapsed
    error FleetCommanderPausableMinimumPauseTimeNotElapsed();

    /// @notice Error thrown when trying to set a minimum pause time that is too short
    error FleetCommanderPausableMinimumPauseTimeTooShort();

    /**
     * @notice Initializes the FleetCommanderPausable contract with a specified minimum pause time
     * @param _initialMinimumPauseTime The initial minimum pause time in seconds
     */
    constructor(uint256 _initialMinimumPauseTime) {
        if (_initialMinimumPauseTime < MINIMUM_PAUSE_TIME_SECONDS) {
            revert FleetCommanderPausableMinimumPauseTimeTooShort();
        }
        minimumPauseTime = _initialMinimumPauseTime;
        emit MinimumPauseTimeUpdated(_initialMinimumPauseTime);
    }

    /**
     * @notice Internal function to pause the contract
     * @dev Overrides the _pause function from OpenZeppelin's Pausable
     */
    function _pause() internal override {
        super._pause();
        pauseStartTime = block.timestamp;
    }

    /**
     * @notice Internal function to unpause the contract
     * @dev Overrides the _unpause function from OpenZeppelin's Pausable
     * @dev Reverts if the minimum pause time has not elapsed
     */
    function _unpause() internal override {
        if (block.timestamp < pauseStartTime + minimumPauseTime) {
            revert FleetCommanderPausableMinimumPauseTimeNotElapsed();
        }
        super._unpause();
    }

    /**
     * @notice Internal function to set a new minimum pause time
     * @param _newMinimumPauseTime The new minimum pause time in seconds
     * @dev Emits a MinimumPauseTimeUpdated event
     */
    function _setMinimumPauseTime(uint256 _newMinimumPauseTime) internal {
        if (_newMinimumPauseTime < MINIMUM_PAUSE_TIME_SECONDS) {
            revert FleetCommanderPausableMinimumPauseTimeTooShort();
        }
        minimumPauseTime = _newMinimumPauseTime;
        emit MinimumPauseTimeUpdated(_newMinimumPauseTime);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IFleetCommander} from "../interfaces/IFleetCommander.sol";
import {IFleetCommanderRewardsManager} from "../interfaces/IFleetCommanderRewardsManager.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {StakingRewardsManagerBase, EnumerableSet} from "@summerfi/rewards-contracts/contracts/StakingRewardsManagerBase.sol";
import {IStakingRewardsManagerBase} from "@summerfi/rewards-contracts/interfaces/IStakingRewardsManagerBase.sol";
/**
 * @title FleetCommanderRewardsManager
 * @notice Contract for managing staking rewards specific to the Fleet system
 * @dev Extends StakingRewardsManagerBase with Fleet-specific functionality
 */

contract FleetCommanderRewardsManager is
    IFleetCommanderRewardsManager,
    StakingRewardsManagerBase
{
    using EnumerableSet for EnumerableSet.AddressSet;
    address public immutable fleetCommander;

    /**
     * @notice Initializes the FleetStakingRewardsManager contract
     * @param _accessManager Address of the AccessManager contract
     * @param _fleetCommander Address of the FleetCommander contract
     */
    constructor(
        address _accessManager,
        address _fleetCommander
    ) StakingRewardsManagerBase(_accessManager) {
        fleetCommander = _fleetCommander;
        stakingToken = fleetCommander;
    }

    /// @inheritdoc IStakingRewardsManagerBase
    function stakeOnBehalfOf(
        address receiver,
        uint256 amount
    ) external override updateReward(receiver) {
        _stake(_msgSender(), receiver, amount);
    }

    /// @inheritdoc IStakingRewardsManagerBase
    function notifyRewardAmount(
        address rewardToken,
        uint256 reward,
        uint256 newRewardsDuration
    )
        external
        override(StakingRewardsManagerBase, IStakingRewardsManagerBase)
        onlyGovernor
        updateReward(address(0))
    {
        if (address(rewardToken) == address(stakingToken)) {
            revert CantAddStakingTokenAsReward();
        }
        _notifyRewardAmount(rewardToken, reward, newRewardsDuration);
    }

    function unstakeAndWithdrawOnBehalfOf(
        address owner,
        uint256 amount,
        bool claimRewards
    ) external override updateReward(owner) {
        // Check if the caller is the same as the 'owner' address or has the required role
        if (_msgSender() != owner && !hasAdmiralsQuartersRole(_msgSender())) {
            revert CallerNotAdmiralsQuarters();
        }

        _unstake(owner, address(this), amount);
        IFleetCommander(fleetCommander).redeem(amount, owner, address(this));

        if (claimRewards) {
            uint256 rewardTokenCount = _rewardTokensList.length();
            for (uint256 i = 0; i < rewardTokenCount; i++) {
                address rewardTokenAddress = _rewardTokensList.at(i);
                _getReward(owner, rewardTokenAddress);
            }
        }
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import {ITipper} from "../interfaces/ITipper.sol";
import {IERC20, IERC4626} from "@openzeppelin/contracts/interfaces/IERC4626.sol";

import {Constants} from "@summerfi/constants/Constants.sol";
import {PERCENTAGE_100, Percentage, toPercentage} from "@summerfi/percentage-solidity/contracts/Percentage.sol";
import {PercentageUtils} from "@summerfi/percentage-solidity/contracts/PercentageUtils.sol";

/**
 * @title Tipper
 * @notice Contract implementing tip accrual functionality
 * @dev This contract is designed to be inherited by ERC20-compliant contracts.
 *      It relies on the inheriting contract to implement ERC20 functionality,
 *      particularly the totalSupply() function.
 *
 * Important:
 * 1. The inheriting contract MUST be ERC20-compliant.
 * 2. The inheriting contract MUST implement the _mintTip function.
 * 3. The contract uses its own address as the token for calculations,
 *    assuming it represents shares in the system.
 * @custom:see ITipper
 */
abstract contract Tipper is ITipper {
    using PercentageUtils for uint256;

    /// @notice The maximum tip rate is 5%
    Percentage immutable MAX_TIP_RATE = Percentage.wrap(5 * 1e18);

    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/

    /// @notice The current tip rate (as Percentage)
    /// @dev Percentages have 18 decimals of precision
    Percentage public tipRate;

    /// @notice The timestamp of the last tip accrual
    uint256 public lastTipTimestamp;

    /*//////////////////////////////////////////////////////////////
                                CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Initializes the Tipper contract
     * @param initialTipRate The initial tip rate for the Fleet
     */
    constructor(Percentage initialTipRate) {
        if (initialTipRate > MAX_TIP_RATE) {
            revert TipRateCannotExceedFivePercent();
        }
        tipRate = initialTipRate;
        lastTipTimestamp = block.timestamp;
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Abstract function to mint new shares as tips
     * @dev This function is meant to be overridden by inheriting contracts.
     *      It is called internally by the _accrueTip function to mint new shares as tips.
     *      The implementation should create new shares for the specified account
     *      without requiring additional underlying assets.
     * @param account The address to receive the minted tip shares
     * @param amount The amount of shares to mint as a tip
     */
    function _mintTip(address account, uint256 amount) internal virtual;

    /**
     * @notice Sets a new tip rate
     * @dev Only callable by the FleetCommander. Accrues tips before changing the rate.
     * @param newTipRate The new tip rate to set, as a Percentage type (defined in @Percentage.sol)
     * @param tipJar The address of the tip jar
     * @param totalSupply The total supply of the shares
     * @custom:internal-logic
     * - Validates that the new tip rate is within the valid percentage range using @PercentageUtils.sol
     * - Accrues tips based on the current rate before updating
     * - Updates the tip rate to the new value
     * @custom:effects
     * - May mint new tip shares (via _accrueTip)
     * - Updates the tipRate state variable
     * @custom:security-considerations
     * - Ensures the new tip rate is within valid bounds (0-100%) using @PercentageUtils.isPercentageInRange
     * - Accrues tips before changing the rate to prevent loss of accrued tips
     * @custom:note The newTipRate should be sized according to the PERCENTAGE_FACTOR in @Percentage.sol.
     *              For example, 1% would be represented as 1 * 10^18 (assuming PERCENTAGE_DECIMALS is 18).
     */
    function _setTipRate(
        Percentage newTipRate,
        address tipJar,
        uint256 totalSupply
    ) internal {
        if (newTipRate > MAX_TIP_RATE) {
            revert TipRateCannotExceedFivePercent();
        }
        _accrueTip(tipJar, totalSupply); // Accrue tips before changing the rate
        tipRate = newTipRate;
        emit TipRateUpdated(newTipRate);
    }

    /**
     * @notice Previews the amount of tip that would be accrued if _accrueTip was called
     * @param tipJar The address of the tip jar
     * @param totalSupply The total supply of the shares
     * @return tippedShares The amount of tips that would be accrued in shares
     */
    function previewTip(
        address tipJar,
        uint256 totalSupply
    ) public view returns (uint256 tippedShares) {
        uint256 timeElapsed = block.timestamp - lastTipTimestamp;
        if (timeElapsed == 0) return 0;

        if (tipRate == toPercentage(0)) return 0;

        uint256 totalShares = totalSupply -
            IERC20(address(this)).balanceOf(tipJar);
        tippedShares = _calculateTip(totalShares, timeElapsed);
        return tippedShares;
    }

    /**
     * @notice Accrues tips based on the current tip rate and time elapsed
     * @dev Only callable by the FleetCommander
     * @param tipJar The address of the tip jar
     * @param totalSupply The total supply of the tip jar
     * @return tippedShares The amount of tips accrued in shares
     * @custom:internal-logic
     * - Calculates the time elapsed since the last tip accrual
     * - Computes the amount of new shares to mint based on the tip rate and time elapsed
     * - Mints new shares to the tip jar if the calculated amount is greater than zero
     * - Updates the lastTipTimestamp to the current block timestamp
     * @custom:effects
     * - May mint new tip shares (via _mintTip)
     * - Updates the lastTipTimestamp state variable
     * @custom:security-considerations
     * - Handles the case where tipRate is zero to prevent unnecessary computations
     * - Uses a custom power function for precise calculations
     */
    function _accrueTip(
        address tipJar,
        uint256 totalSupply
    ) internal returns (uint256 tippedShares) {
        if (tipRate == toPercentage(0)) {
            lastTipTimestamp = block.timestamp;
            return 0;
        }

        tippedShares = previewTip(tipJar, totalSupply);

        if (tippedShares > 0) {
            lastTipTimestamp = block.timestamp;
            _mintTip(tipJar, tippedShares);
            emit TipAccrued(tippedShares);
        }
    }

    /**
     * @notice Calculates the amount of tip to be accrued
     * @param totalShares The total number of shares in the system
     * @param timeElapsed The time elapsed since the last tip accrual
     * @return The amount of new shares to be minted as tip
     * @custom:internal-logic
     * - Calculates a time-adjusted rate by scaling the annual tip rate by the elapsed time
     * - Applies this adjusted rate to the total shares to determine tip amount
     * @custom:effects
     * - Does not modify any state, pure function
     */
    function _calculateTip(
        uint256 totalShares,
        uint256 timeElapsed
    ) internal view returns (uint256) {
        Percentage timeAdjustedRate = Percentage.wrap(
            ((timeElapsed * Percentage.unwrap(tipRate)) /
                Constants.SECONDS_PER_YEAR)
        );

        return totalShares.applyPercentage(timeAdjustedRate);
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import "../Ark.sol";

/**
 * @title BufferArk
 * @notice Specialized Ark contract for Fleet Buffer operations.
 * @dev This contract holds a certain percentage of total assets in a buffer,
 *      which are not deployed and not subject to yield-generating strategies.
 *      The buffer ensures quick disembarkation of assets when needed.
 *
 * Key features:
 * - Maintains a minimum buffer balance as per FleetCommander configuration
 * - Does not deploy assets to any yield-generating strategies
 * - Provides quick access to funds for disembarkation
 * (see {IFleetCommanderConfigProvider-config-minimumBufferBalance})
 */
contract BufferArk is Ark {
    /*//////////////////////////////////////////////////////////////
                                CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Initializes the BufferArk
     * @param _params The ArkParams struct containing initialization parameters
     * @param commanderAddress The address of the Fleet Commander
     */
    constructor(
        ArkParams memory _params,
        address commanderAddress
    ) Ark(_params) {
        config.commander = commanderAddress;
    }

    /*//////////////////////////////////////////////////////////////
                                FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IArk
     * @dev For BufferArk, total assets are simply the token balance of this contract,
     *      as no assets are deployed to external strategies.
     */
    function totalAssets() public view override returns (uint256) {
        return config.asset.balanceOf(address(this));
    }

    /**
     * @notice Internal function to get the total assets that are withdrawable
     * @dev For Buffer Ark, the total assets are always withdrawable
     */
    function _withdrawableTotalAssets()
        internal
        view
        override
        returns (uint256)
    {
        return totalAssets();
    }

    /**
     * @notice No-op for board function
     * @dev This function is intentionally left empty because the BufferArk doesn't need to perform any
     * additional actions when boarding tokens. The actual token transfer is handled by the Ark.board() function,
     * and the BufferArk simply holds these tokens without deploying them to any strategy.
     * @param amount The amount of tokens being boarded (unused in this implementation)
     * @param data Additional data for boarding (unused in this implementation)
     */
    function _board(uint256 amount, bytes calldata data) internal override {}

    /**
     * @notice No-op for disembark function
     * @dev This function is intentionally left empty because the BufferArk doesn't need to perform any
     * additional actions when disembarking tokens. The actual token transfer is handled by the Ark.disembark()
     * function,
     * and the BufferArk simply releases these tokens without any complex withdrawal process.
     * @param amount The amount of tokens being disembarked (unused in this implementation)
     * @param data Additional data for disembarking (unused in this implementation)
     */
    function _disembark(
        uint256 amount,
        bytes calldata data
    ) internal override {}

    /**
     * @notice No-op for harvest function
     * @dev This function is intentionally left empty and returns empty arrays because the BufferArk
     * does not generate any rewards. It's a simple holding contract for tokens, not an investment strategy.
     * @param data Additional data for harvesting (unused in this implementation)
     * @return rewardTokens An empty array of reward token addresses
     * @return rewardAmounts An empty array of reward amounts
     */
    function _harvest(
        bytes calldata data
    )
        internal
        override
        returns (address[] memory rewardTokens, uint256[] memory rewardAmounts)
    {}

    /**
     * @notice No-op for validateBoardData function
     * @dev This function is intentionally left empty because the BufferArk doesn't require any
     * specific validation for boarding data. It accepts any data without validation.
     * @param data The boarding data to validate (unused in this implementation)
     */
    function _validateBoardData(bytes calldata data) internal override {}

    /**
     * @notice No-op for validateDisembarkData function
     * @dev This function is intentionally left empty because the BufferArk doesn't require any
     * specific validation for disembarking data. It accepts any data without validation.
     * @param data The disembarking data to validate (unused in this implementation)
     */
    function _validateDisembarkData(bytes calldata data) internal override {}
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

/**
 * @dev This library defines storage slots using the technique described in EIP-1967.
 * @notice The subtraction of 1 from the keccak256 hash is used to avoid potential conflicts
 * with Solidity's default storage slot allocation for state variables.
 * @dev For more information, see: https://eips.ethereum.org/EIPS/eip-1967
 */
library StorageSlots {
    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.ReentrancyGuard")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 public constant TOTAL_ASSETS_STORAGE =
        keccak256(
            abi.encode(
                uint256(keccak256("fleetCommander.storage.totalAssets")) - 1
            )
        ) & ~bytes32(uint256(0xff));
    bytes32 public constant IS_TOTAL_ASSETS_CACHED_STORAGE =
        keccak256(
            abi.encode(
                uint256(
                    keccak256("fleetCommander.storage.isTotalAssetsCached")
                ) - 1
            )
        ) & ~bytes32(uint256(0xff));

    bytes32 public constant ARKS_TOTAL_ASSETS_ARRAY_STORAGE =
        keccak256(
            abi.encode(
                uint256(
                    keccak256("fleetCommander.storage.arksTotalAssetsArray")
                ) - 1
            )
        ) & ~bytes32(uint256(0xff));
    bytes32 public constant ARKS_ADDRESS_ARRAY_STORAGE =
        keccak256(
            abi.encode(
                uint256(keccak256("fleetCommander.storage.arksAddressArray")) -
                    1
            )
        ) & ~bytes32(uint256(0xff));
    bytes32 public constant ARKS_LENGTH_STORAGE =
        keccak256(
            abi.encode(
                uint256(keccak256("fleetCommander.storage.arksLength")) - 1
            )
        ) & ~bytes32(uint256(0xff));

    bytes32 public constant WITHDRAWABLE_ARKS_TOTAL_ASSETS_STORAGE =
        keccak256(
            abi.encode(
                uint256(
                    keccak256(
                        "fleetCommander.storage.withdrawableArksTotalAssets"
                    )
                ) - 1
            )
        ) & ~bytes32(uint256(0xff));
    bytes32 public constant WITHDRAWABLE_ARKS_TOTAL_ASSETS_ARRAY_STORAGE =
        keccak256(
            abi.encode(
                uint256(
                    keccak256(
                        "fleetCommander.storage.withdrawableArksTotalAssetsArray"
                    )
                ) - 1
            )
        ) & ~bytes32(uint256(0xff));

    bytes32 public constant WITHDRAWABLE_ARKS_ADDRESS_ARRAY_STORAGE =
        keccak256(
            abi.encode(
                uint256(
                    keccak256(
                        "fleetCommander.storage.withdrawableArksAddressArray"
                    )
                ) - 1
            )
        ) & ~bytes32(uint256(0xff));
    bytes32 public constant WITHDRAWABLE_ARKS_LENGTH_STORAGE =
        keccak256(
            abi.encode(
                uint256(
                    keccak256("fleetCommander.storage.withdrawableArksLength")
                ) - 1
            )
        ) & ~bytes32(uint256(0xff));

    bytes32 public constant IS_WITHDRAWABLE_ARKS_TOTAL_ASSETS_CACHED_STORAGE =
        keccak256(
            abi.encode(
                uint256(
                    keccak256(
                        "fleetCommander.storage.isWithdrawableArksTotalAssetsCached"
                    )
                ) - 1
            )
        ) & ~bytes32(uint256(0xff));
    bytes32 public constant ARK_INFLOW_BALANCE_STORAGE =
        keccak256(
            abi.encode(
                uint256(keccak256("fleetCommander.storage.arkInflowBalance")) -
                    1
            )
        ) & ~bytes32(uint256(0xff));

    bytes32 public constant ARK_OUTFLOW_BALANCE_STORAGE =
        keccak256(
            abi.encode(
                uint256(keccak256("fleetCommander.storage.arkOutflowBalance")) -
                    1
            )
        ) & ~bytes32(uint256(0xff));

    bytes32 public constant ARK_MAX_INFLOW_BALANCE_STORAGE =
        keccak256(
            abi.encode(
                uint256(
                    keccak256("fleetCommander.storage.arkMaxInflowBalance")
                ) - 1
            )
        ) & ~bytes32(uint256(0xff));

    bytes32 public constant ARK_MAX_OUTFLOW_BALANCE_STORAGE =
        keccak256(
            abi.encode(
                uint256(
                    keccak256("fleetCommander.storage.arkMaxOutflowBalance")
                ) - 1
            )
        ) & ~bytes32(uint256(0xff));
    bytes32 public constant TIP_TAKEN_STORAGE =
        keccak256(
            abi.encode(
                uint256(keccak256("fleetCommander.storage._isCollectingTip")) -
                    1
            )
        ) & ~bytes32(uint256(0xff));
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

/**
 * @title IArkConfigProviderErrors
 * @dev This file contains custom error definitions for the ArkConfigProvider contract.
 * @notice These custom errors provide more gas-efficient and informative error handling
 * compared to traditional require statements with string messages.
 */
interface IArkConfigProviderErrors {
    /**
     * @notice Thrown when attempting to deploy an Ark without specifying a configuration manager.
     */
    error CannotDeployArkWithoutConfigurationManager();

    /**
     * @notice Thrown when attempting to deploy an Ark without specifying a Raft address.
     */
    error CannotDeployArkWithoutRaft();

    /**
     * @notice Thrown when attempting to deploy an Ark without specifying a token address.
     */
    error CannotDeployArkWithoutToken();

    /**
     * @notice Thrown when attempting to deploy an Ark with an empty name.
     */
    error CannotDeployArkWithEmptyName();

    /**
     * @notice Thrown when an invalid vault address is provided.
     */
    error InvalidVaultAddress();

    /**
     * @notice Thrown when there's a mismatch between expected and actual assets in an ERC4626 operation.
     */
    error ERC4626AssetMismatch();

    /**
     * @notice Thrown when the max deposit percentage of TVL is greater than 100%.
     */
    error MaxDepositPercentageOfTVLTooHigh();

    /**
     * @notice Thrown when attempting to register a FleetCommander when one is already registered.
     */
    error FleetCommanderAlreadyRegistered();

    /**
     * @notice Thrown when attempting to unregister a FleetCommander by a non-registered address.
     */
    error FleetCommanderNotRegistered();
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

/**
 * @title IArkErrors
 * @dev This file contains custom error definitions for the Ark contract.
 * @notice These custom errors provide more gas-efficient and informative error handling
 * compared to traditional require statements with string messages.
 */
interface IArkErrors {
    /**
     * @notice Thrown when attempting to remove a commander from an Ark that still has assets.
     */
    error CannotRemoveCommanderFromArkWithAssets();

    /**
     * @notice Thrown when trying to add a commander to an Ark that already has one.
     */
    error CannotAddCommanderToArkWithCommander();

    /**
     * @notice Thrown when attempting to use keeper data when it's not required.
     */
    error CannotUseKeeperDataWhenNotRequired();

    /**
     * @notice Thrown when keeper data is required but not provided.
     */
    error KeeperDataRequired();

    /**
     * @notice Thrown when invalid board data is provided.
     */
    error InvalidBoardData();

    /**
     * @notice Thrown when invalid disembark data is provided.
     */
    error InvalidDisembarkData();
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

/**
 * @title IConfigurationManagerErrors
 * @dev This file contains custom error definitions for the ConfigurationManager contract.
 * @notice These custom errors provide more gas-efficient and informative error handling
 * compared to traditional require statements with string messages.
 */
interface IConfigurationManagerErrors {
    /**
     * @notice Thrown when an operation is attempted with a zero address where a non-zero address is required.
     */
    error ZeroAddress();
    /**
     * @notice Thrown when ConfigurationManager was already initialized.
     */
    error ConfigurationManagerAlreadyInitialized();

    /**
     * @notice Thrown when the Raft address is not set.
     */
    error RaftNotSet();

    /**
     * @notice Thrown when the TipJar address is not set.
     */
    error TipJarNotSet();

    /**
     * @notice Thrown when the Treasury address is not set.
     */
    error TreasuryNotSet();

    /**
     * @notice Thrown when constructor address is set to the zero address.
     */
    error AddressZero();

    /**
     * @notice Thrown when the HarborCommand address is not set.
     */
    error HarborCommandNotSet();
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

/**
 * @title IFleetCommanderConfigProviderErrors
 * @dev This file contains custom error definitions for the FleetCommanderConfigProvider contract.
 * @notice These custom errors provide more gas-efficient and informative error handling
 * compared to traditional require statements with string messages.
 */
interface IFleetCommanderConfigProviderErrors {
    /**
     * @notice Thrown when an operation is attempted on a non-existent Ark
     * @param ark The address of the Ark that was not found
     */
    error FleetCommanderArkNotFound(address ark);

    /**
     * @notice Thrown when trying to remove an Ark that still has a non-zero deposit cap
     * @param ark The address of the Ark with a non-zero deposit cap
     */
    error FleetCommanderArkDepositCapGreaterThanZero(address ark);

    /**
     * @notice Thrown when attempting to remove an Ark that still holds assets
     * @param ark The address of the Ark with non-zero assets
     */
    error FleetCommanderArkAssetsNotZero(address ark);

    /**
     * @notice Thrown when trying to add an Ark that already exists in the system
     * @param ark The address of the Ark that already exists
     */
    error FleetCommanderArkAlreadyExists(address ark);

    /**
     * @notice Thrown when an invalid Ark address is provided (e.g., zero address)
     */
    error FleetCommanderInvalidArkAddress();

    /**
     * @notice Thrown when trying to set a StakingRewardsManager to the zero address
     */
    error FleetCommanderInvalidStakingRewardsManager();

    /**
     * @notice Thrown when trying to set a max rebalance operations to a value greater than the max allowed
     * @param newMaxRebalanceOperations The new max rebalance operations value
     */
    error FleetCommanderMaxRebalanceOperationsTooHigh(
        uint256 newMaxRebalanceOperations
    );

    /**
     * @notice Thrown when the asset of the Ark does not match the asset of the FleetCommander
     */
    error FleetCommanderAssetMismatch();
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

/**
 * @title IFleetCommanderErrors
 * @dev This file contains custom error definitions for the FleetCommander contract.
 * @notice These custom errors provide more gas-efficient and informative error handling
 * compared to traditional require statements with string messages.
 */
interface IFleetCommanderErrors {
    /**
     * @notice Thrown when transfers are disabled.
     */
    error FleetCommanderTransfersDisabled();

    /**
     * @notice Thrown when an operation is attempted on an inactive Ark.
     * @param ark The address of the inactive Ark.
     */
    error FleetCommanderArkNotActive(address ark);

    /**
     * @notice Thrown when attempting to rebalance to an invalid Ark.
     * @param ark The address of the invalid Ark.
     * @param amount Amount of tokens added to target ark
     * @param effectiveDepositCap Effective deposit cap of the ark (minimum of % of fleet TVL or arbitrary ark deposit
     * cap)
     */
    error FleetCommanderEffectiveDepositCapExceeded(
        address ark,
        uint256 amount,
        uint256 effectiveDepositCap
    );

    /**
     * @notice Thrown when there is insufficient buffer for an operation.
     */
    error FleetCommanderInsufficientBuffer();

    /**
     * @notice Thrown when a rebalance operation is attempted with no actual operations.
     */
    error FleetCommanderRebalanceNoOperations();

    /**
     * @notice Thrown when a rebalance operation exceeds the maximum allowed number of operations.
     * @param operationsCount The number of operations attempted.
     */
    error FleetCommanderRebalanceTooManyOperations(uint256 operationsCount);

    /**
     * @notice Thrown when a rebalance amount for an Ark is zero.
     * @param ark The address of the Ark with zero rebalance amount.
     */
    error FleetCommanderRebalanceAmountZero(address ark);

    /**
     * @notice Thrown when a withdrawal amount exceeds the maximum buffer limit.
     */
    error WithdrawalAmountExceedsMaxBufferLimit();

    /**
     * @notice Thrown when an Ark's deposit cap is zero.
     * @param ark The address of the Ark with zero deposit cap.
     */
    error FleetCommanderArkDepositCapZero(address ark);

    /**
     * @notice Thrown when no funds were moved in an operation that expected fund movement.
     */
    error FleetCommanderNoFundsMoved();

    /**
     * @notice Thrown when there are no excess funds to perform an operation.
     */
    error FleetCommanderNoExcessFunds();

    /**
     * @notice Thrown when an invalid source Ark is specified for an operation.
     * @param ark The address of the invalid source Ark.
     */
    error FleetCommanderInvalidSourceArk(address ark);

    /**
     * @notice Thrown when an operation attempts to move more funds than available.
     */
    error FleetCommanderMovedMoreThanAvailable();

    /**
     * @notice Thrown when an unauthorized withdrawal is attempted.
     * @param caller The address attempting the withdrawal.
     * @param owner The address of the authorized owner.
     */
    error FleetCommanderUnauthorizedWithdrawal(address caller, address owner);

    /**
     * @notice Thrown when an unauthorized redemption is attempted.
     * @param caller The address attempting the redemption.
     * @param owner The address of the authorized owner.
     */
    error FleetCommanderUnauthorizedRedemption(address caller, address owner);

    /**
     * @notice Thrown when attempting to use rebalance on a buffer Ark.
     */
    error FleetCommanderCantUseRebalanceOnBufferArk();

    /**
     * @notice Thrown when attempting to use the maximum uint value for buffer adjustment from buffer.
     */
    error FleetCommanderCantUseMaxUintMovingFromBuffer();

    /**
     * @notice Thrown when a rebalance operation exceeds the maximum outflow for an Ark.
     * @param fromArk The address of the Ark from which funds are being moved.
     * @param amount The amount being moved.
     * @param maxRebalanceOutflow The maximum allowed outflow.
     */
    error FleetCommanderExceedsMaxOutflow(
        address fromArk,
        uint256 amount,
        uint256 maxRebalanceOutflow
    );

    /**
     * @notice Thrown when a rebalance operation exceeds the maximum inflow for an Ark.
     * @param fromArk The address of the Ark to which funds are being moved.
     * @param amount The amount being moved.
     * @param maxRebalanceInflow The maximum allowed inflow.
     */
    error FleetCommanderExceedsMaxInflow(
        address fromArk,
        uint256 amount,
        uint256 maxRebalanceInflow
    );

    /**
     * @notice Thrown when the staking rewards manager is not set.
     */
    error FleetCommanderStakingRewardsManagerNotSet();

    /**
     * @notice Thrown when user attempts to deposit/mint or withdraw/redeem 0 units
     */
    error FleetCommanderZeroAmount();
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

/**
 * @title ITipperErrors
 * @dev This file contains custom error definitions for the Tipper contract.
 * @notice These custom errors provide more gas-efficient and informative error handling
 * compared to traditional require statements with string messages.
 */
interface ITipperErrors {
    /**
     * @notice Thrown when an invalid FleetCommander address is provided.
     */
    error InvalidFleetCommanderAddress();

    /**
     * @notice Thrown when an invalid TipJar address is provided.
     */
    error InvalidTipJarAddress();

    /**
     * @notice Thrown when the tip rate exceeds 5%.
     */
    error TipRateCannotExceedFivePercent();
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import {Percentage} from "@summerfi/percentage-solidity/contracts/Percentage.sol";

/**
 * @title IArkConfigProviderEvents
 * @notice Interface for events emitted by ArkConfigProvider contracts
 */
interface IArkConfigProviderEvents {
    /**
     * @notice Emitted when the deposit cap of the Ark is updated
     * @param newCap The new deposit cap value
     */
    event DepositCapUpdated(uint256 newCap);

    /**
     * @notice Emitted when the maximum deposit percentage of TVL is updated
     * @param newMaxDepositPercentageOfTVL The new maximum deposit percentage of TVL
     */
    event MaxDepositPercentageOfTVLUpdated(
        Percentage newMaxDepositPercentageOfTVL
    );

    /**
     * @notice Emitted when the Raft address associated with the Ark is updated
     * @param newRaft The address of the new Raft
     */
    event RaftUpdated(address newRaft);

    /**
     * @notice Emitted when the maximum outflow limit for the Ark during rebalancing is updated
     * @param newMaxOutflow The new maximum amount that can be transferred out of the Ark during a rebalance
     */
    event MaxRebalanceOutflowUpdated(uint256 newMaxOutflow);

    /**
     * @notice Emitted when the maximum inflow limit for the Ark during rebalancing is updated
     * @param newMaxInflow The new maximum amount that can be transferred into the Ark during a rebalance
     */
    event MaxRebalanceInflowUpdated(uint256 newMaxInflow);

    /**
     * @notice Emitted when the Fleet Commander is registered
     * @param commander The address of the Fleet Commander
     */
    event FleetCommanderRegistered(address commander);

    /**
     * @notice Emitted when the Fleet Commander is unregistered
     * @param commander The address of the Fleet Commander
     */
    event FleetCommanderUnregistered(address commander);
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

/**
 * @title IArkEvents
 * @notice Interface for events emitted by Ark contracts
 */
interface IArkEvents {
    /**
     * @notice Emitted when rewards are harvested from an Ark
     * @param rewardTokens The addresses of the harvested reward tokens
     * @param rewardAmounts The amounts of the harvested reward tokens
     */
    event ArkHarvested(
        address[] indexed rewardTokens,
        uint256[] indexed rewardAmounts
    );

    /**
     * @notice Emitted when tokens are boarded (deposited) into the Ark
     * @param commander The address of the FleetCommander initiating the boarding
     * @param token The address of the token being boarded
     * @param amount The amount of tokens boarded
     */
    event Boarded(address indexed commander, address token, uint256 amount);

    /**
     * @notice Emitted when tokens are disembarked (withdrawn) from the Ark
     * @param commander The address of the FleetCommander initiating the disembarking
     * @param token The address of the token being disembarked
     * @param amount The amount of tokens disembarked
     */
    event Disembarked(address indexed commander, address token, uint256 amount);

    /**
     * @notice Emitted when tokens are moved from one address to another
     * @param from Ark being boarded from
     * @param to Ark being boarded to
     * @param token The address of the token being moved
     * @param amount The amount of tokens moved
     */
    event Moved(
        address indexed from,
        address indexed to,
        address token,
        uint256 amount
    );

    /**
     * @notice Emitted when the Ark is poked and the share price is updated
     * @param currentPrice Current share price of the Ark
     * @param timestamp The timestamp of the poke
     */
    event ArkPoked(uint256 currentPrice, uint256 timestamp);

    /**
     * @notice Emitted when the Ark is swept
     * @param sweptTokens The addresses of the swept tokens
     * @param sweptAmounts The amounts of the swept tokens
     */
    event ArkSwept(
        address[] indexed sweptTokens,
        uint256[] indexed sweptAmounts
    );
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

/**
 * @title IConfigurationManagerEvents
 * @notice Interface for events emitted by the Configuration Manager
 */
interface IConfigurationManagerEvents {
    /**
     * @notice Emitted when the Raft address is updated
     * @param newRaft The address of the new Raft
     */
    event RaftUpdated(address oldRaft, address newRaft);

    /**
     * @notice Emitted when the tip jar address is updated
     * @param newTipJar The address of the new tip jar
     */
    event TipJarUpdated(address oldTipJar, address newTipJar);

    /**
     * @notice Emitted when the tip rate is updated
     * @param newTipRate The new tip rate value
     */
    event TipRateUpdated(uint8 oldTipRate, uint8 newTipRate);

    /**
     * @notice Emitted when the Treasury address is updated
     * @param newTreasury The address of the new Treasury
     */
    event TreasuryUpdated(address oldTreasury, address newTreasury);

    /**
     * @notice Emitted when the Harbor Command address is updated
     * @param oldHarborCommand The address of the old Harbor Command
     * @param newHarborCommand The address of the new Harbor Command
     */
    event HarborCommandUpdated(
        address oldHarborCommand,
        address newHarborCommand
    );

    /**
     * @notice Emitted when the Fleet Commander Rewards Manager Factory address is updated
     * @param oldFleetCommanderRewardsManagerFactory The address of the old Fleet Commander Rewards Manager Factory
     * @param newFleetCommanderRewardsManagerFactory The address of the new Fleet Commander Rewards Manager Factory
     */
    event FleetCommanderRewardsManagerFactoryUpdated(
        address oldFleetCommanderRewardsManagerFactory,
        address newFleetCommanderRewardsManagerFactory
    );
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

interface IFleetCommanderConfigProviderEvents {
    /**
     * @notice Emitted when the deposit cap is updated
     * @param newCap The new deposit cap value
     */
    event FleetCommanderDepositCapUpdated(uint256 newCap);
    /**
     * @notice Emitted when a new Ark is added
     * @param ark The address of the newly added Ark
     */
    event ArkAdded(address indexed ark);

    /**
     * @notice Emitted when an Ark is removed
     * @param ark The address of the removed Ark
     */
    event ArkRemoved(address indexed ark);
    /**
     * @notice Emitted when new minimum funds buffer balance is set
     * @param newBalance New minimum funds buffer balance
     */
    event FleetCommanderminimumBufferBalanceUpdated(uint256 newBalance);

    /**
     * @notice Emitted when new max allowed rebalance operations is set
     * @param newMaxRebalanceOperations Max allowed rebalance operations
     */
    event FleetCommanderMaxRebalanceOperationsUpdated(
        uint256 newMaxRebalanceOperations
    );

    /**
     * @notice Emitted when the staking rewards contract address is updated
     * @param newStakingRewards The address of the new staking rewards contract
     */
    event FleetCommanderStakingRewardsUpdated(address newStakingRewards);

    /**
     * @notice Emitted when the transfer enabled status is updated
     */
    event TransfersEnabled();
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import {RebalanceData} from "../types/FleetCommanderTypes.sol";

interface IFleetCommanderEvents {
    /* EVENTS */
    /**
     * @notice Emitted when a rebalance operation is completed
     * @param keeper The address of the keeper who initiated the rebalance
     * @param rebalances An array of RebalanceData structs detailing the rebalance operations
     */
    event Rebalanced(address indexed keeper, RebalanceData[] rebalances);

    /**
     * @notice Emitted when queued funds are committed
     * @param keeper The address of the keeper who committed the funds
     * @param prevBalance The previous balance before committing funds
     * @param newBalance The new balance after committing funds
     */
    event QueuedFundsCommitted(
        address indexed keeper,
        uint256 prevBalance,
        uint256 newBalance
    );

    /**
     * @notice Emitted when the funds queue is refilled
     * @param keeper The address of the keeper who initiated the queue refill
     * @param prevBalance The previous balance before refilling
     * @param newBalance The new balance after refilling
     */
    event FundsQueueRefilled(
        address indexed keeper,
        uint256 prevBalance,
        uint256 newBalance
    );

    /**
     * @notice Emitted when the minimum balance of the funds queue is updated
     * @param keeper The address of the keeper who updated the minimum balance
     * @param newBalance The new minimum balance
     */
    event MinFundsQueueBalanceUpdated(
        address indexed keeper,
        uint256 newBalance
    );

    /**
     * @notice Emitted when the fee address is updated
     * @param newAddress The new fee address
     */
    event FeeAddressUpdated(address newAddress);

    /**
     * @notice Emitted when the funds buffer balance is updated
     * @param user The address of the user who triggered the update
     * @param prevBalance The previous buffer balance
     * @param newBalance The new buffer balance
     */
    event FundsBufferBalanceUpdated(
        address indexed user,
        uint256 prevBalance,
        uint256 newBalance
    );

    /**
     * @notice Emitted when funds are withdrawn from Arks
     * @param owner The address of the owner who initiated the withdrawal
     * @param receiver The address of the receiver of the withdrawn funds
     * @param totalWithdrawn The total amount of funds withdrawn
     */
    event FleetCommanderWithdrawnFromArks(
        address indexed owner,
        address receiver,
        uint256 totalWithdrawn
    );

    /**
     * @notice Emitted when funds are redeemed from Arks
     * @param owner The address of the owner who initiated the redemption
     * @param receiver The address of the receiver of the redeemed funds
     * @param totalRedeemed The total amount of funds redeemed
     */
    event FleetCommanderRedeemedFromArks(
        address indexed owner,
        address receiver,
        uint256 totalRedeemed
    );
    /**
     * @notice Emitted when referee deposits into the FleetCommander
     * @param referee The address of the referee who was referred
     * @param referralCode The referral code of the referrer
     */
    event FleetCommanderReferral(
        address indexed referee,
        bytes indexed referralCode
    );
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import {Percentage} from "@summerfi/percentage-solidity/contracts/Percentage.sol";

interface ITipperEvents {
    /**
     * @notice Emitted when the tip rate is updated
     * @param newTipRate The new tip rate value
     */
    event TipRateUpdated(Percentage newTipRate);

    /**
     * @notice Emitted when tips are accrued
     * @param tipAmount The amount of tips accrued in the underlying asset's smallest unit
     */
    event TipAccrued(uint256 tipAmount);

    /**
     * @notice Emitted when the tip jar address is updated
     * @param newTipJar The new address of the tip jar
     */
    event TipJarUpdated(address newTipJar);
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import {IArkErrors} from "../errors/IArkErrors.sol";

import {IArkEvents} from "../events/IArkEvents.sol";
import {IArkAccessManaged} from "./IArkAccessManaged.sol";
import {IArkConfigProvider} from "./IArkConfigProvider.sol";

/**
 * @title IArk
 * @notice Interface for the Ark contract, which manages funds and interacts with Rafts
 * @dev Inherits from IArkAccessManaged for access control and IArkEvents for event definitions
 */
interface IArk is
    IArkAccessManaged,
    IArkEvents,
    IArkErrors,
    IArkConfigProvider
{
    /**
     * @notice Returns the current underlying balance of the Ark
     * @return The total assets in the Ark, in token precision
     */
    function totalAssets() external view returns (uint256);

    /**
     * @notice Triggers a harvest operation to collect rewards
     * @param additionalData Optional bytes that might be required by a specific protocol to harvest
     * @return rewardTokens The reward token addresses
     * @return rewardAmounts The reward amounts
     */
    function harvest(
        bytes calldata additionalData
    )
        external
        returns (address[] memory rewardTokens, uint256[] memory rewardAmounts);

    /**
     * @notice Sweeps tokens from the Ark
     * @param tokens The tokens to sweep
     * @return sweptTokens The swept tokens
     * @return sweptAmounts The swept amounts
     */
    function sweep(
        address[] calldata tokens
    )
        external
        returns (address[] memory sweptTokens, uint256[] memory sweptAmounts);

    /**
     * @notice Deposits (boards) tokens into the Ark
     * @dev This function is called by the Fleet Commander to deposit assets into the Ark.
     *      It transfers tokens from the caller to this contract and then calls the internal _board function.
     * @param amount The amount of assets to board
     * @param boardData Additional data required for boarding, specific to the Ark implementation
     * @custom:security-note This function is only callable by authorized entities
     */
    function board(uint256 amount, bytes calldata boardData) external;

    /**
     * @notice Withdraws (disembarks) tokens from the Ark
     * @param amount The amount of tokens to withdraw
     * @param disembarkData Additional data that might be required by a specific protocol to withdraw funds
     */
    function disembark(uint256 amount, bytes calldata disembarkData) external;

    /**
     * @notice Moves tokens from one ark to another
     * @param amount The amount of tokens to move
     * @param receiver The address of the Ark the funds will be boarded to
     * @param boardData Additional data that might be required by a specific protocol to board funds
     * @param disembarkData Additional data that might be required by a specific protocol to disembark funds
     */
    function move(
        uint256 amount,
        address receiver,
        bytes calldata boardData,
        bytes calldata disembarkData
    ) external;

    /**
     * @notice Internal function to get the total assets that are withdrawable
     * @return uint256 The total assets that are withdrawable
     * @dev _withdrawableTotalAssets is an internal function that should be implemented by derived contracts to define
     * specific withdrawability logic
     * @dev the ark is withdrawable if it doesnt require keeper data and _isWithdrawable returns true
     */
    function withdrawableTotalAssets() external view returns (uint256);
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

/**
 * @title IArkAccessManaged
 * @notice Extends the ProtocolAccessManaged contract with Ark specific AccessControl
 *         Used to specifically tie one FleetCommander to each Ark
 *
 * @dev One Ark specific role is defined:
 *   - Commander: is the fleet commander contract itself and couples an
 *        Ark to specific Fleet Commander
 *
 *   The Commander role is still declared on the access manager to centralise
 *   role definitions.
 */
interface IArkAccessManaged {}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import {IArkConfigProviderErrors} from "../errors/IArkConfigProviderErrors.sol";
import {IArkAccessManaged} from "./IArkAccessManaged.sol";

import {IArkConfigProviderEvents} from "../events/IArkConfigProviderEvents.sol";
import {ArkConfig} from "../types/ArkTypes.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Percentage} from "@summerfi/percentage-solidity/contracts/Percentage.sol";

/**
 * @title IArkConfigProvider
 * @notice Interface for configuration of Ark contracts
 * @dev Inherits from IArkAccessManaged for access control and IArkConfigProviderEvents for event definitions
 */
interface IArkConfigProvider is
    IArkAccessManaged,
    IArkConfigProviderErrors,
    IArkConfigProviderEvents
{
    /**
     * @notice Retrieves the current fleet config
     */
    function getConfig() external view returns (ArkConfig memory);

    /**
     * @dev Returns the name of the Ark.
     * @return The name of the Ark as a string.
     */
    function name() external view returns (string memory);

    /**
     * @notice Returns the details of the Ark
     * @return The details of the Ark as a string
     */
    function details() external view returns (string memory);

    /**
     * @notice Returns the deposit cap for this Ark
     * @return The maximum amount of tokens that can be deposited into the Ark
     */
    function depositCap() external view returns (uint256);

    /**
     * @notice Returns the maximum percentage of TVL that can be deposited into the Ark
     * @return The maximum percentage of TVL that can be deposited into the Ark
     */
    function maxDepositPercentageOfTVL() external view returns (Percentage);

    /**
     * @notice Returns the maximum amount that can be moved to this Ark in one rebalance
     * @return maximum amount that can be moved to this Ark in one rebalance
     */
    function maxRebalanceInflow() external view returns (uint256);

    /**
     * @notice Returns the maximum amount that can be moved from this Ark in one rebalance
     * @return maximum amount that can be moved from this Ark in one rebalance
     */
    function maxRebalanceOutflow() external view returns (uint256);

    /**
     * @notice Returns whether the Ark requires keeper data to board/disembark
     * @return true if the Ark requires keeper data, false otherwise
     */
    function requiresKeeperData() external view returns (bool);

    /**
     * @notice Returns the ERC20 token managed by this Ark
     * @return The IERC20 interface of the managed token
     */
    function asset() external view returns (IERC20);

    /**
     * @notice Returns the address of the Fleet commander managing the ark
     * @return address Address of Fleet commander managing the ark if a Commander is assigned, address(0) otherwise
     */
    function commander() external view returns (address);

    /**
     * @notice Sets a new maximum allocation for the Ark
     * @param newDepositCap The new maximum allocation amount
     */
    function setDepositCap(uint256 newDepositCap) external;

    /**
     * @notice Sets a new maximum deposit percentage of TVL for the Ark
     * @param newMaxDepositPercentageOfTVL The new maximum deposit percentage of TVL
     */
    function setMaxDepositPercentageOfTVL(
        Percentage newMaxDepositPercentageOfTVL
    ) external;

    /**
     * @notice Sets a new maximum amount that can be moved from the Ark in one rebalance
     * @param newMaxRebalanceOutflow The new maximum amount that can be moved from the Ark
     */
    function setMaxRebalanceOutflow(uint256 newMaxRebalanceOutflow) external;

    /**
     * @notice Sets a new maximum amount that can be moved to the Ark in one rebalance
     * @param newMaxRebalanceInflow The new maximum amount that can be moved to the Ark
     */
    function setMaxRebalanceInflow(uint256 newMaxRebalanceInflow) external;

    /**
     * @notice Registers the Fleet commander for the Ark
     * @dev This function is used to register the Fleet commander for the Ark
     * it's called by the FleetCommander when ark is added to the fleet
     */
    function registerFleetCommander() external;

    /**
     * @notice Unregisters the Fleet commander for the Ark
     * @dev This function is used to unregister the Fleet commander for the Ark
     * it's called by the FleetCommander when ark is removed from the fleet
     * all balance checks are done within the FleetCommander
     */
    function unregisterFleetCommander() external;
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import {IConfigurationManager} from "./IConfigurationManager.sol";

/**
 * @title IConfigurationManaged
 * @notice Interface for contracts that need to read from the ConfigurationManager
 * @dev This interface defines the standard methods for accessing configuration values
 *      from the ConfigurationManager. It should be implemented by contracts that
 *      need to read these configurations.
 */
interface IConfigurationManaged {
    /**
     * @notice Gets the address of the ConfigurationManager contract
     * @return The address of the ConfigurationManager contract
     */
    function configurationManager()
        external
        view
        returns (IConfigurationManager);

    /**
     * @notice Gets the address of the Raft contract
     * @return The address of the Raft contract
     */
    function raft() external view returns (address);

    /**
     * @notice Gets the address of the TipJar contract
     * @return The address of the TipJar contract
     */
    function tipJar() external view returns (address);

    /**
     * @notice Gets the address of the Treasury contract
     * @return The address of the Treasury contract
     */
    function treasury() external view returns (address);

    /**
     * @notice Gets the address of the HarborCommand contract
     * @return The address of the HarborCommand contract
     */
    function harborCommand() external view returns (address);

    /**
     * @notice Gets the address of the Fleet Commander Rewards Manager Factory contract
     * @return The address of the Fleet Commander Rewards Manager Factory contract
     */
    function fleetCommanderRewardsManagerFactory()
        external
        view
        returns (address);

    error ConfigurationManagerZeroAddress();
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import {IConfigurationManagerErrors} from "../errors/IConfigurationManagerErrors.sol";
import {IConfigurationManagerEvents} from "../events/IConfigurationManagerEvents.sol";
import {ConfigurationManagerParams} from "../types/ConfigurationManagerTypes.sol";

/**
 * @title IConfigurationManager
 * @notice Interface for the ConfigurationManager contract, which manages system-wide parameters
 * @dev This interface defines the getters and setters for system-wide parameters
 */

interface IConfigurationManager is
    IConfigurationManagerEvents,
    IConfigurationManagerErrors
{
    /**
     * @notice Initialize the configuration with the given parameters
     * @param params The parameters to initialize the configuration with
     * @dev Can only be called by the governor
     */
    function initializeConfiguration(
        ConfigurationManagerParams memory params
    ) external;

    /**
     * @notice Get the address of the Raft contract
     * @return The address of the Raft contract
     * @dev This is where rewards and farmed tokens are sent for processing
     */
    function raft() external view returns (address);

    /**
     * @notice Get the current tip jar address
     * @return The current tip jar address
     * @dev This is the contract that owns tips and is responsible for
     *     dispensing them to claimants
     */
    function tipJar() external view returns (address);

    /**
     * @notice Get the current treasury address
     * @return The current treasury address
     *       @dev This is the contract that owns the treasury and is responsible for
     *      dispensing funds to the protocol's operations
     */
    function treasury() external view returns (address);

    /**
     * @notice Get the address of theHarbor command
     * @return The address of theHarbor command
     * @dev This is the contract that's the registry of all Fleet Commanders
     */
    function harborCommand() external view returns (address);

    /**
     * @notice Get the address of the Fleet Commander Rewards Manager Factory contract
     * @return The address of the Fleet Commander Rewards Manager Factory contract
     */
    function fleetCommanderRewardsManagerFactory()
        external
        view
        returns (address);

    /**
     * @notice Set a new address for the Raft contract
     * @param newRaft The new address for the Raft contract
     * @dev Can only be called by the governor
     */
    function setRaft(address newRaft) external;

    /**
     * @notice Set a new tip ar address
     * @param newTipJar The address of the new tip jar
     * @dev Can only be called by the governor
     */
    function setTipJar(address newTipJar) external;

    /**
     * @notice Set a new treasury address
     * @param newTreasury The address of the new treasury
     * @dev Can only be called by the governor
     */
    function setTreasury(address newTreasury) external;

    /**
     * @notice Set a new harbor command address
     * @param newHarborCommand The address of the new harbor command
     * @dev Can only be called by the governor
     */
    function setHarborCommand(address newHarborCommand) external;

    /**
     * @notice Set a new fleet commander rewards manager factory address
     * @param newFleetCommanderRewardsManagerFactory The address of the new fleet commander rewards manager factory
     * @dev Can only be called by the governor
     */
    function setFleetCommanderRewardsManagerFactory(
        address newFleetCommanderRewardsManagerFactory
    ) external;
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import {IFleetCommanderErrors} from "../errors/IFleetCommanderErrors.sol";
import {IFleetCommanderEvents} from "../events/IFleetCommanderEvents.sol";
import {RebalanceData} from "../types/FleetCommanderTypes.sol";

import {IFleetCommanderConfigProvider} from "./IFleetCommanderConfigProvider.sol";
import {IERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {Percentage} from "@summerfi/percentage-solidity/contracts/Percentage.sol";

/**
 * @title IFleetCommander Interface
 * @notice Interface for the FleetCommander contract, which manages asset allocation across multiple Arks
 */
interface IFleetCommander is
    IERC4626,
    IFleetCommanderEvents,
    IFleetCommanderErrors,
    IFleetCommanderConfigProvider
{
    /**
     * @notice Returns the total assets that are currently withdrawable from the FleetCommander.
     * @dev If cached data is available, it will be used. Otherwise, it will be calculated on demand (and cached)
     * @return uint256 The total amount of assets that can be withdrawn.
     */
    function withdrawableTotalAssets() external view returns (uint256);

    /**
     * @notice Returns the total assets that are managed the FleetCommander.
     * @dev If cached data is available, it will be used. Otherwise, it will be calculated on demand (and cached)
     * @return uint256 The total amount of assets that can be withdrawn.
     */
    function totalAssets() external view returns (uint256);

    /**
     * @notice Returns the maximum amount of the underlying asset that can be withdrawn from the owner balance in the
     * Vault, directly from Buffer.
     * @param owner The address of the owner of the assets
     * @return uint256 The maximum amount that can be withdrawn.
     */
    function maxBufferWithdraw(address owner) external view returns (uint256);

    /**
     * @notice Returns the maximum amount of the underlying asset that can be redeemed from the owner balance in the
     * Vault, directly from Buffer.
     * @param owner The address of the owner of the assets
     * @return uint256 The maximum amount that can be redeemed.
     */
    function maxBufferRedeem(address owner) external view returns (uint256);

    /* FUNCTIONS - PUBLIC - USER */
    /**
     * @notice Deposits a specified amount of assets into the contract for a given receiver.
     * @param assets The amount of assets to be deposited.
     * @param receiver The address of the receiver who will receive the deposited assets.
     * @param referralCode An optional referral code that can be used for tracking or rewards.
     */
    function deposit(
        uint256 assets,
        address receiver,
        bytes memory referralCode
    ) external returns (uint256);

    /**
     * @notice Forces a withdrawal of assets from the FleetCommander
     * @param assets The amount of assets to forcefully withdraw
     * @param receiver The address that will receive the withdrawn assets
     * @param owner The address of the owner of the assets
     * @return shares The amount of shares redeemed
     */
    function withdrawFromArks(
        uint256 assets,
        address receiver,
        address owner
    ) external returns (uint256 shares);

    /**
     * @notice Withdraws a specified amount of assets from the FleetCommander
     * @dev This function first attempts to withdraw from the buffer. If the buffer doesn't have enough assets,
     *      it will withdraw from the arks. It also handles the case where the maximum possible amount is requested.
     * @param assets The amount of assets to withdraw. If set to type(uint256).max, it will withdraw the maximum
     * possible amount.
     * @param receiver The address that will receive the withdrawn assets
     * @param owner The address of the owner of the shares
     * @return shares The number of shares burned in exchange for the withdrawn assets
     */
    function withdraw(
        uint256 assets,
        address receiver,
        address owner
    ) external returns (uint256 shares);

    /**
     * @notice Redeems a specified amount of shares from the FleetCommander
     * @dev This function first attempts to redeem from the buffer. If the buffer doesn't have enough assets,
     *      it will redeem from the arks. It also handles the case where the maximum possible amount is requested.
     * @param shares The number of shares to redeem. If set to type(uint256).max, it will redeem all shares owned by the
     * owner.
     * @param receiver The address that will receive the redeemed assets
     * @param owner The address of the owner of the shares
     * @return assets The amount of assets received in exchange for the redeemed shares
     */
    function redeem(
        uint256 shares,
        address receiver,
        address owner
    ) external returns (uint256 assets);

    /**
     * @notice Redeems shares for assets from the FleetCommander
     * @param shares The amount of shares to redeem
     * @param receiver  The address that will receive the assets
     * @param owner The address of the owner of the shares
     * @return assets The amount of assets forcefully withdrawn
     */
    function redeemFromArks(
        uint256 shares,
        address receiver,
        address owner
    ) external returns (uint256 assets);

    /**
     * @notice Redeems shares for assets directly from the Buffer
     * @param shares The amount of shares to redeem
     * @param receiver The address that will receive the assets
     * @param owner The address of the owner of the shares
     * @return assets The amount of assets redeemed
     */
    function redeemFromBuffer(
        uint256 shares,
        address receiver,
        address owner
    ) external returns (uint256 assets);

    /**
     * @notice Forces a withdrawal of assets directly from the Buffer
     * @param assets The amount of assets to withdraw
     * @param receiver The address that will receive the withdrawn assets
     * @param owner The address of the owner of the assets
     * @return shares The amount of shares redeemed
     */
    function withdrawFromBuffer(
        uint256 assets,
        address receiver,
        address owner
    ) external returns (uint256 shares);

    /**
     * @notice Accrues and distributes tips
     * @return uint256 The amount of tips accrued
     */
    function tip() external returns (uint256);

    /**
     * @notice Rebalances the assets across Arks, including buffer adjustments
     * @param data Array of RebalanceData structs
     * @dev RebalanceData struct contains:
     *      - fromArk: The address of the Ark to move assets from
     *      - toArk: The address of the Ark to move assets to
     *      - amount: The amount of assets to move
     *      - boardData: Additional data for the board operation
     *      - disembarkData: Additional data for the disembark operation
     * @dev Using type(uint256).max as the amount will move all assets from the fromArk to the toArk
     * @dev For standard rebalancing:
     *      - Operations cannot involve the buffer Ark directly
     * @dev For buffer adjustments:
     *      - type(uint256).max is only allowed when moving TO the buffer
     *      - When withdrawing FROM buffer, total amount cannot reduce balance below minFundsBufferBalance
     * @dev The number of operations in a single rebalance call is limited to MAX_REBALANCE_OPERATIONS
     * @dev Rebalance is subject to a cooldown period between calls
     * @dev Only callable by accounts with the Keeper role
     */
    function rebalance(RebalanceData[] calldata data) external;

    /* FUNCTIONS - EXTERNAL - GOVERNANCE */

    /**
     * @notice Sets a new tip rate for the FleetCommander
     * @dev Only callable by the governor
     * @dev The tip rate is set as a Percentage. Percentages use 18 decimals of precision
     *      For example, for a 5% rate, you'd pass 5 * 1e18 (5 000 000 000 000 000 000)
     * @param newTipRate The new tip rate as a Percentage
     */
    function setTipRate(Percentage newTipRate) external;

    /**
     * @notice Sets a new minimum pause time for the FleetCommander
     * @dev Only callable by the governor
     * @param newMinimumPauseTime The new minimum pause time in seconds
     */
    function setMinimumPauseTime(uint256 newMinimumPauseTime) external;

    /**
     * @notice Updates the rebalance cooldown period
     * @param newCooldown The new cooldown period in seconds
     */
    function updateRebalanceCooldown(uint256 newCooldown) external;

    /**
     * @notice Forces a rebalance operation
     * @param data Array of typed rebalance data struct
     * @dev has no cooldown enforced but only callable by privileged role
     */
    function forceRebalance(RebalanceData[] calldata data) external;

    /**
     * @notice Pauses the FleetCommander
     * @dev This function is used to pause the FleetCommander in case of critical issues or emergencies
     * @dev Only callable by the guardian or governor
     */
    function pause() external;

    /**
     * @notice Unpauses the FleetCommander
     * @dev This function is used to resume normal operations after a pause
     * @dev Only callable by the guardian or governor
     */
    function unpause() external;
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import {IFleetCommanderConfigProviderErrors} from "../errors/IFleetCommanderConfigProviderErrors.sol";

import {IFleetCommanderConfigProviderEvents} from "../events/IFleetCommanderConfigProviderEvents.sol";

import {FleetConfig} from "../types/FleetCommanderTypes.sol";
import {Percentage} from "@summerfi/percentage-solidity/contracts/Percentage.sol";

/**
 * @title IFleetCommander Interface
 * @notice Interface for the FleetCommander contract, which manages asset allocation across multiple Arks
 */
interface IFleetCommanderConfigProvider is
    IFleetCommanderConfigProviderErrors,
    IFleetCommanderConfigProviderEvents
{
    /**
     * @notice Retrieves the ark address at the specified index
     * @param index The index of the ark in the arks array
     * @return The address of the ark at the specified index
     */
    function arks(uint256 index) external view returns (address);

    /**
     * @notice Retrieves the arks currently linked to fleet (excluding the buffer ark)
     */
    function getActiveArks() external view returns (address[] memory);

    /**
     * @notice Retrieves the current fleet config
     */
    function getConfig() external view returns (FleetConfig memory);

    /**
     * @notice Retrieves the buffer ark address
     */
    function bufferArk() external view returns (address);

    /**
     * @notice Checks if the ark is part of the fleet or is the buffer ark
     * @param ark The address of the Ark
     * @return bool Returns true if the ark is active or the buffer ark, false otherwise.
     */
    function isArkActiveOrBufferArk(address ark) external view returns (bool);

    /* FUNCTIONS - EXTERNAL - GOVERNANCE */

    /**
     * @notice Adds a new Ark
     * @param ark The address of the new Ark
     */
    function addArk(address ark) external;

    /**
     * @notice Removes an existing Ark
     * @param ark The address of the Ark to remove
     */
    function removeArk(address ark) external;

    /**
     * @notice Sets a new deposit cap for Fleet
     * @param newDepositCap The new deposit cap
     */
    function setFleetDepositCap(uint256 newDepositCap) external;

    /**
     * @notice Sets a new deposit cap for an Ark
     * @param ark The address of the Ark
     * @param newDepositCap The new deposit cap
     */
    function setArkDepositCap(address ark, uint256 newDepositCap) external;

    /**
     * @notice Sets the max deposit percentage of TVL for an Ark
     * @param ark The address of the Ark
     * @param newMaxDepositPercentageOfTVL The new max deposit percentage of TVL
     */
    function setArkMaxDepositPercentageOfTVL(
        address ark,
        Percentage newMaxDepositPercentageOfTVL
    ) external;

    /**
     * @dev Sets the minimum buffer balance for the fleet commander.
     * @param newMinimumBalance The new minimum buffer balance to be set.
     */
    function setMinimumBufferBalance(uint256 newMinimumBalance) external;

    /**
     * @dev Sets the minimum number of allowe rebalance operations.
     * @param newMaxRebalanceOperations The new maximum allowed rebalance operations.
     */
    function setMaxRebalanceOperations(
        uint256 newMaxRebalanceOperations
    ) external;

    /**
     * @notice Sets the maxRebalanceOutflow for an Ark
     * @dev Only callable by the governor
     * @param ark The address of the Ark
     * @param newMaxRebalanceOutflow The new maxRebalanceOutflow value
     */
    function setArkMaxRebalanceOutflow(
        address ark,
        uint256 newMaxRebalanceOutflow
    ) external;

    /**
     * @notice Sets the maxRebalanceInflow for an Ark
     * @dev Only callable by the governor
     * @param ark The address of the Ark
     * @param newMaxRebalanceInflow The new maxRebalanceInflow value
     */
    function setArkMaxRebalanceInflow(
        address ark,
        uint256 newMaxRebalanceInflow
    ) external;

    /**
     * @notice Deploys and sets the staking rewards manager contract address
     */
    function updateStakingRewardsManager() external;

    /**
     * @notice Enables or disables transfers of fleet commander shares
     * @dev Only callable by the governor when not paused
     */
    function setFleetTokenTransferability() external;
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IStakingRewardsManagerBase} from "@summerfi/rewards-contracts/interfaces/IStakingRewardsManagerBase.sol";

/**
 * @title IFleetCommanderRewardsManager
 * @notice Interface for the FleetStakingRewardsManager contract
 * @dev Extends IStakingRewardsManagerBase with Fleet-specific functionality
 */
interface IFleetCommanderRewardsManager is IStakingRewardsManagerBase {
    /**
     * @notice Returns the address of the FleetCommander contract
     * @return The address of the FleetCommander
     */
    function fleetCommander() external view returns (address);

    /**
     * @notice Thrown when a non-AdmiralsQuarters contract tries
     * to unstake on behalf
     */
    error CallerNotAdmiralsQuarters();

    /**
     * @notice Thrown when AdmiralsQuarters tries to unstake for
     * someone other than msg.sender
     */
    error InvalidUnstakeRecipient();

    /* @notice Thrown when trying to add a staking token as a reward token */
    error CantAddStakingTokenAsReward();
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/**
 * @title IFleetCommanderRewardsManagerFactory
 * @notice Interface for the FleetCommanderRewardsManagerFactory contract
 * @dev Defines the interface for creating new FleetCommanderRewardsManager instances
 */
interface IFleetCommanderRewardsManagerFactory {
    /**
     * @notice Event emitted when a new rewards manager is created
     * @param rewardsManager Address of the newly created rewards manager
     * @param fleetCommander Address of the fleet commander associated with the rewards manager
     */
    event RewardsManagerCreated(
        address indexed rewardsManager,
        address indexed fleetCommander
    );

    /**
     * @notice Creates a new FleetCommanderRewardsManager instance
     * @param accessManager Address of the access manager to associate with the rewards manager
     * @param fleetCommander Address of the fleet commander to associate with the rewards manager
     * @return Address of the newly created rewards manager
     */
    function createRewardsManager(
        address accessManager,
        address fleetCommander
    ) external returns (address);
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import {ITipperErrors} from "../errors/ITipperErrors.sol";
import {ITipperEvents} from "../events/ITipperEvents.sol";
import {Percentage} from "@summerfi/percentage-solidity/contracts/Percentage.sol";

/**
 * @title ITipper Interface
 * @notice Interface for the tip accrual functionality in the FleetCommander contract
 * @dev This interface defines the events and functions related to tip accrual and management
 */
interface ITipper is ITipperEvents, ITipperErrors {
    /**
     * @notice Get the current tip rate
     * @return The current tip rate
     * @dev A tip rate of 100 * 1e18 represents 100%
     */
    function tipRate() external view returns (Percentage);

    /**
     * @notice Get the timestamp of the last tip accrual
     * @return The Unix timestamp of when tips were last accrued
     */
    function lastTipTimestamp() external view returns (uint256);
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Percentage} from "@summerfi/percentage-solidity/contracts/Percentage.sol";

/**
 * @title ArkParams
 * @notice Constructor parameters for the Ark contract
 *
 *  @dev This struct is used to initialize an Ark contract with all necessary parameters
 */
struct ArkParams {
    /**
     * @notice The name of the Ark
     * @dev This should be a unique, human-readable identifier for the Ark
     */
    string name;
    /**
     * @notice Additional details about the Ark
     * @dev This can be used to store additional information about the Ark
     */
    string details;
    /**
     * @notice The address of the access manager contract
     * @dev This contract manages roles and permissions for the Ark
     */
    address accessManager;
    /**
     * @notice The address of the configuration manager contract
     * @dev This contract stores global configuration parameters
     */
    address configurationManager;
    /**
     * @notice The address of the ERC20 token managed by this Ark
     * @dev This is the underlying asset that the Ark will handle
     */
    address asset;
    /**
     * @notice The maximum amount of tokens that can be deposited into the Ark
     * @dev This cap helps to manage risk and exposure
     */
    uint256 depositCap;
    /**
     * @notice The maximum amount of tokens that can be moved from this Ark in a single transaction
     * @dev This limit helps to prevent large, sudden outflows
     */
    uint256 maxRebalanceOutflow;
    /**
     * @notice The maximum amount of tokens that can be moved to this Ark in a single transaction
     * @dev This limit helps to prevent large, sudden inflows
     */
    uint256 maxRebalanceInflow;
    /**
     * @notice Whether the Ark requires Keepr data to be passed in with rebalance transactions
     * @dev This flag is used to determine whether Keepr data is required for rebalance transactions
     */
    bool requiresKeeperData;
    /**
     * @notice The maximum percentage of Total Value Locked (TVL) that can be deposited into this Ark
     * @dev This value is represented as a percentage with 18 decimal places (1e18 = 100%)
     *      For example, 0.5e18 represents 50% of TVL
     */
    Percentage maxDepositPercentageOfTVL;
}

/**
 * @title ArkConfig
 * @notice Configuration of the Ark contract
 * @dev This struct stores the current configuration of an Ark, which can be updated during its lifecycle
 */
struct ArkConfig {
    /**
     * @notice The address of the commander (typically a FleetCommander contract)
     * @dev The commander has special permissions to manage the Ark
     */
    address commander;
    /**
     * @notice The address of the associated Raft contract
     * @dev The Raft contract handles reward distribution and other protocol-wide functions
     */
    address raft;
    /**
     * @notice The ERC20 token interface for the asset managed by this Ark
     * @dev This allows direct interaction with the token contract
     */
    IERC20 asset;
    /**
     * @notice The current maximum amount of tokens that can be deposited into the Ark
     * @dev This can be adjusted by the commander to manage capacity
     */
    uint256 depositCap;
    /**
     * @notice The current maximum amount of tokens that can be moved from this Ark in a single transaction
     * @dev This can be adjusted to manage liquidity and risk
     */
    uint256 maxRebalanceOutflow;
    /**
     * @notice The current maximum amount of tokens that can be moved to this Ark in a single transaction
     * @dev This can be adjusted to manage inflows and capacity
     */
    uint256 maxRebalanceInflow;
    /**
     * @notice The name of the Ark
     * @dev This is typically set at initialization and not changed
     */
    string name;
    /**
     * @notice Additional details about the Ark
     * @dev This can be used to store additional information about the Ark
     */
    string details;
    /**
     * @notice Whether the Ark requires Keeper data to be passed in with rebalance transactions
     * @dev This flag is used to determine whether Keeper data is required for rebalance transactions
     */
    bool requiresKeeperData;
    /**
     * @notice The maximum percentage of Total Value Locked (TVL) that can be deposited into this Ark
     * @dev This value is represented as a percentage with 18 decimal places (1e18 = 100%)
     *      For example, 0.5e18 represents 50% of TVL
     */
    Percentage maxDepositPercentageOfTVL;
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

/**
 * @notice Initialization parameters for the ConfigurationManager contract
 */
struct ConfigurationManagerParams {
    address raft;
    address tipJar;
    address treasury;
    address harborCommand;
    address fleetCommanderRewardsManagerFactory;
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import {IArk} from "../interfaces/IArk.sol";

import {IFleetCommanderRewardsManager} from "../interfaces/IFleetCommanderRewardsManager.sol";
import {Percentage} from "@summerfi/percentage-solidity/contracts/Percentage.sol";

/**
 * @notice Configuration parameters for the FleetCommander contract
 */
struct FleetCommanderParams {
    string name;
    string details;
    string symbol;
    address configurationManager;
    address accessManager;
    address asset;
    uint256 initialMinimumBufferBalance;
    uint256 initialRebalanceCooldown;
    uint256 depositCap;
    Percentage initialTipRate;
}

/**
 * @title FleetConfig
 * @notice Configuration parameters for the FleetCommander contract
 * @dev This struct encapsulates the mutable configuration settings of a FleetCommander.
 *      These parameters can be updated during the contract's lifecycle to adjust its behavior.
 */
struct FleetConfig {
    /**
     * @notice The buffer Ark associated with this FleetCommander
     * @dev This Ark is used as a temporary holding area for funds before they are allocated
     *      to other Arks or when they need to be quickly accessed for withdrawals.
     */
    IArk bufferArk;
    /**
     * @notice The minimum balance that should be maintained in the buffer Ark
     * @dev This value is used to ensure there's always a certain amount of funds readily
     *      available for withdrawals or rebalancing operations. It's denominated in the
     *      smallest unit of the underlying asset (e.g., wei for ETH).
     */
    uint256 minimumBufferBalance;
    /**
     * @notice The maximum total value of assets that can be deposited into the FleetCommander
     * @dev This cap helps manage the total assets under management and can be used to
     *      implement controlled growth strategies. It's denominated in the smallest unit
     *      of the underlying asset.
     */
    uint256 depositCap;
    /**
     * @notice The maximum number of rebalance operations in a single rebalance
     */
    uint256 maxRebalanceOperations;
    /**
     * @notice The address of the staking rewards contract
     */
    address stakingRewardsManager;
}

/**
 * @notice Data structure for the rebalance event
 * @param fromArk The address of the Ark from which assets are moved
 * @param toArk The address of the Ark to which assets are moved
 * @param amount The amount of assets being moved
 * @param boardData The data to be passed to the `board` function of the `toArk`
 * @param disembarkData The data to be passed to the `disembark` function of the `fromArk`
 * @dev if the `boardData` or `disembarkData` is not needed, it should be an empty byte array
 */
struct RebalanceData {
    address fromArk;
    address toArk;
    uint256 amount;
    bytes boardData;
    bytes disembarkData;
}

/**
 * @title ArkData
 * @dev Struct to store information about an Ark.
 * This struct holds the address of the Ark and the total assets it holds.
 * @dev used in the caching mechanism for the FleetCommander
 */
struct ArkData {
    /// @notice The address of the Ark.
    address arkAddress;
    /// @notice The total assets held by the Ark.
    uint256 totalAssets;
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import {ICooldownEnforcer} from "./ICooldownEnforcer.sol";

import "./ICooldownEnforcerErrors.sol";
import "./ICooldownEnforcerEvents.sol";

/**
 * @title CooldownEnforcer
 * @custom:see ICooldownEnforcer
 */
abstract contract CooldownEnforcer is ICooldownEnforcer {
    /**
     * STATE VARIABLES
     */

    /**
     * Cooldown between actions in seconds
     */
    uint256 private _cooldown;

    /**
     * Timestamp of the last action in Epoch time (block timestamp)
     */
    uint256 private _lastActionTimestamp;

    /**
     * @notice The minimum duration that the contract must remain paused
     */
    uint256 private constant MINIMUM_COOLDOWN_TIME_SECONDS = 1 minutes;

    /**
     * @notice The maximum duration that the contract can enforce
     */
    uint256 private constant MAXIMUM_COOLDOWN_TIME_SECONDS = 1 days;

    /**
     * CONSTRUCTOR
     */

    /**
     * @notice Initializes the cooldown period and sets the last action timestamp to the current block timestamp
     *         if required
     *
     * @param cooldown_ The cooldown period in seconds.
     * @param enforceFromNow If true, the last action timestamp is set to the current block timestamp.
     *
     * @dev The last action timestamp is set to the current block timestamp if enforceFromNow is true,
     *      otherwise it is set to 0 signaling that the cooldown period has not started yet.
     */
    constructor(uint256 cooldown_, bool enforceFromNow) {
        if (cooldown_ < MINIMUM_COOLDOWN_TIME_SECONDS) {
            revert CooldownEnforcerCooldownTooShort();
        }
        if (cooldown_ > MAXIMUM_COOLDOWN_TIME_SECONDS) {
            revert CooldownEnforcerCooldownTooLong();
        }

        _cooldown = cooldown_;

        if (enforceFromNow) {
            _lastActionTimestamp = block.timestamp;
        }
    }

    /**
     * MODIFIERS
     */

    /**
     * @notice Modifier to enforce the cooldown period between actions.
     *
     * @dev If the cooldown period has not elapsed, the function call will revert.
     *      Otherwise, the last action timestamp is updated to the current block timestamp.
     */
    modifier enforceCooldown() {
        if (block.timestamp - _lastActionTimestamp < _cooldown) {
            revert CooldownNotElapsed(
                _lastActionTimestamp,
                _cooldown,
                block.timestamp
            );
        }

        // Update the last action timestamp to the current block timestamp
        // before executing the function so it acts as a reentrancy guard
        // by not allowing a second call to execute
        _lastActionTimestamp = block.timestamp;
        _;
    }

    /**
     * VIEW FUNCTIONS
     */

    /// @inheritdoc ICooldownEnforcer
    function getCooldown() public view returns (uint256) {
        return _cooldown;
    }

    /// @inheritdoc ICooldownEnforcer
    function getLastActionTimestamp() public view returns (uint256) {
        return _lastActionTimestamp;
    }

    /**
     * INTERNAL STATE CHANGE FUNCTIONS
     */

    /**
     * @notice Updates the cooldown period.
     *
     * @param newCooldown The new cooldown period in seconds.
     *
     * @dev The function is internal so it can be wrapped with access modifiers if needed
     */
    function _updateCooldown(uint256 newCooldown) internal {
        if (newCooldown < MINIMUM_COOLDOWN_TIME_SECONDS) {
            revert CooldownEnforcerCooldownTooShort();
        }
        if (newCooldown > MAXIMUM_COOLDOWN_TIME_SECONDS) {
            revert CooldownEnforcerCooldownTooLong();
        }
        emit CooldownUpdated(_cooldown, newCooldown);

        _cooldown = newCooldown;
    }

    /**
     * @notice Resets the last action timestamp
     * @dev Allows for cooldown period to be skipped (IE after force withdrawal)
     */
    function _resetLastActionTimestamp() internal {
        _lastActionTimestamp = 0;
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

/**
 * @title ICooldownEnforcer
 * @notice Enforces a cooldown period between actions. It provides the basic management for a cooldown
 *            period, allows to update the cooldown period and provides a modifier to enforce the cooldown.
 */
interface ICooldownEnforcer {
    /**
     * ERRORS
     */

    /**
     * @notice Error thrown when the cooldown period is too short
     */
    error CooldownEnforcerCooldownTooShort();

    /**
     * @notice Error thrown when the cooldown period is too long
     */
    error CooldownEnforcerCooldownTooLong();

    /**
     * VIEW FUNCTIONS
     */

    /**
     * @notice Returns the cooldown period in seoonds.
     */
    function getCooldown() external view returns (uint256);

    /**
     * @notice Returns the timestamp of the last action in Epoch time (block timestamp).
     */
    function getLastActionTimestamp() external view returns (uint256);
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

/**
 * @notice Emitted by the modifier when the cooldown period has not elapsed.
 *
 * @param lastActionTimestamp The timestamp of the last action in Epoch time (block timestamp).
 * @param cooldown The cooldown period in seconds.
 * @param currentTimestamp The current block timestamp.
 */
error CooldownNotElapsed(
    uint256 lastActionTimestamp,
    uint256 cooldown,
    uint256 currentTimestamp
);
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

/**
 * EVENTS
 */

/**
 * @param previousCooldown The previous cooldown period in seconds.
 * @param newCooldown The new cooldown period in seconds.
 */
event CooldownUpdated(uint256 previousCooldown, uint256 newCooldown);