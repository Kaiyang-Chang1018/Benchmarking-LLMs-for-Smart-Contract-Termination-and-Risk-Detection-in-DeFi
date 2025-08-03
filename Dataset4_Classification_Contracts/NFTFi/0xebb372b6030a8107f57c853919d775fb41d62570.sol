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
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC2981.sol)

pragma solidity ^0.8.20;

import {IERC165} from "../utils/introspection/IERC165.sol";

/**
 * @dev Interface for the NFT Royalty Standard.
 *
 * A standardized way to retrieve royalty payment information for non-fungible tokens (NFTs) to enable universal
 * support for royalty payments across all NFT marketplaces and ecosystem participants.
 */
interface IERC2981 is IERC165 {
    /**
     * @dev Returns how much royalty is owed and to whom, based on a sale price that may be denominated in any unit of
     * exchange. The royalty amount is denominated and should be paid in that same unit of exchange.
     */
    function royaltyInfo(
        uint256 tokenId,
        uint256 salePrice
    ) external view returns (address receiver, uint256 royaltyAmount);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/draft-IERC6093.sol)
pragma solidity ^0.8.20;

/**
 * @dev Standard ERC20 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC20 tokens.
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
 * @dev Standard ERC721 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC721 tokens.
 */
interface IERC721Errors {
    /**
     * @dev Indicates that an address can't be an owner. For example, `address(0)` is a forbidden owner in EIP-20.
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
 * @dev Standard ERC1155 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC1155 tokens.
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
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
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
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.20;

import {IERC721} from "./IERC721.sol";
import {IERC721Receiver} from "./IERC721Receiver.sol";
import {IERC721Metadata} from "./extensions/IERC721Metadata.sol";
import {Context} from "../../utils/Context.sol";
import {Strings} from "../../utils/Strings.sol";
import {IERC165, ERC165} from "../../utils/introspection/ERC165.sol";
import {IERC721Errors} from "../../interfaces/draft-IERC6093.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
abstract contract ERC721 is Context, ERC165, IERC721, IERC721Metadata, IERC721Errors {
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    mapping(uint256 tokenId => address) private _owners;

    mapping(address owner => uint256) private _balances;

    mapping(uint256 tokenId => address) private _tokenApprovals;

    mapping(address owner => mapping(address operator => bool)) private _operatorApprovals;

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
    function balanceOf(address owner) public view virtual returns (uint256) {
        if (owner == address(0)) {
            revert ERC721InvalidOwner(address(0));
        }
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual returns (address) {
        return _requireOwned(tokenId);
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual returns (string memory) {
        _requireOwned(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string.concat(baseURI, tokenId.toString()) : "";
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
    function approve(address to, uint256 tokenId) public virtual {
        _approve(to, tokenId, _msgSender());
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual returns (address) {
        _requireOwned(tokenId);

        return _getApproved(tokenId);
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(address from, address to, uint256 tokenId) public virtual {
        if (to == address(0)) {
            revert ERC721InvalidReceiver(address(0));
        }
        // Setting an "auth" arguments enables the `_isAuthorized` check which verifies that the token exists
        // (from != 0). Therefore, it is not needed to verify that the return value is not 0 here.
        address previousOwner = _update(to, tokenId, _msgSender());
        if (previousOwner != from) {
            revert ERC721IncorrectOwner(from, tokenId, previousOwner);
        }
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public virtual {
        transferFrom(from, to, tokenId);
        _checkOnERC721Received(from, to, tokenId, data);
    }

    /**
     * @dev Returns the owner of the `tokenId`. Does NOT revert if token doesn't exist
     *
     * IMPORTANT: Any overrides to this function that add ownership of tokens not tracked by the
     * core ERC721 logic MUST be matched with the use of {_increaseBalance} to keep balances
     * consistent with ownership. The invariant to preserve is that for any address `a` the value returned by
     * `balanceOf(a)` must be equal to the number of tokens such that `_ownerOf(tokenId)` is `a`.
     */
    function _ownerOf(uint256 tokenId) internal view virtual returns (address) {
        return _owners[tokenId];
    }

    /**
     * @dev Returns the approved address for `tokenId`. Returns 0 if `tokenId` is not minted.
     */
    function _getApproved(uint256 tokenId) internal view virtual returns (address) {
        return _tokenApprovals[tokenId];
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `owner`'s tokens, or `tokenId` in
     * particular (ignoring whether it is owned by `owner`).
     *
     * WARNING: This function assumes that `owner` is the actual owner of `tokenId` and does not verify this
     * assumption.
     */
    function _isAuthorized(address owner, address spender, uint256 tokenId) internal view virtual returns (bool) {
        return
            spender != address(0) &&
            (owner == spender || isApprovedForAll(owner, spender) || _getApproved(tokenId) == spender);
    }

    /**
     * @dev Checks if `spender` can operate on `tokenId`, assuming the provided `owner` is the actual owner.
     * Reverts if `spender` does not have approval from the provided `owner` for the given token or for all its assets
     * the `spender` for the specific `tokenId`.
     *
     * WARNING: This function assumes that `owner` is the actual owner of `tokenId` and does not verify this
     * assumption.
     */
    function _checkAuthorized(address owner, address spender, uint256 tokenId) internal view virtual {
        if (!_isAuthorized(owner, spender, tokenId)) {
            if (owner == address(0)) {
                revert ERC721NonexistentToken(tokenId);
            } else {
                revert ERC721InsufficientApproval(spender, tokenId);
            }
        }
    }

    /**
     * @dev Unsafe write access to the balances, used by extensions that "mint" tokens using an {ownerOf} override.
     *
     * NOTE: the value is limited to type(uint128).max. This protect against _balance overflow. It is unrealistic that
     * a uint256 would ever overflow from increments when these increments are bounded to uint128 values.
     *
     * WARNING: Increasing an account's balance using this function tends to be paired with an override of the
     * {_ownerOf} function to resolve the ownership of the corresponding tokens so that balances and ownership
     * remain consistent with one another.
     */
    function _increaseBalance(address account, uint128 value) internal virtual {
        unchecked {
            _balances[account] += value;
        }
    }

    /**
     * @dev Transfers `tokenId` from its current owner to `to`, or alternatively mints (or burns) if the current owner
     * (or `to`) is the zero address. Returns the owner of the `tokenId` before the update.
     *
     * The `auth` argument is optional. If the value passed is non 0, then this function will check that
     * `auth` is either the owner of the token, or approved to operate on the token (by the owner).
     *
     * Emits a {Transfer} event.
     *
     * NOTE: If overriding this function in a way that tracks balances, see also {_increaseBalance}.
     */
    function _update(address to, uint256 tokenId, address auth) internal virtual returns (address) {
        address from = _ownerOf(tokenId);

        // Perform (optional) operator check
        if (auth != address(0)) {
            _checkAuthorized(from, auth, tokenId);
        }

        // Execute the update
        if (from != address(0)) {
            // Clear approval. No need to re-authorize or emit the Approval event
            _approve(address(0), tokenId, address(0), false);

            unchecked {
                _balances[from] -= 1;
            }
        }

        if (to != address(0)) {
            unchecked {
                _balances[to] += 1;
            }
        }

        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        return from;
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
    function _mint(address to, uint256 tokenId) internal {
        if (to == address(0)) {
            revert ERC721InvalidReceiver(address(0));
        }
        address previousOwner = _update(to, tokenId, address(0));
        if (previousOwner != address(0)) {
            revert ERC721InvalidSender(address(0));
        }
    }

    /**
     * @dev Mints `tokenId`, transfers it to `to` and checks for `to` acceptance.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(address to, uint256 tokenId, bytes memory data) internal virtual {
        _mint(to, tokenId);
        _checkOnERC721Received(address(0), to, tokenId, data);
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
    function _burn(uint256 tokenId) internal {
        address previousOwner = _update(address(0), tokenId, address(0));
        if (previousOwner == address(0)) {
            revert ERC721NonexistentToken(tokenId);
        }
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
    function _transfer(address from, address to, uint256 tokenId) internal {
        if (to == address(0)) {
            revert ERC721InvalidReceiver(address(0));
        }
        address previousOwner = _update(to, tokenId, address(0));
        if (previousOwner == address(0)) {
            revert ERC721NonexistentToken(tokenId);
        } else if (previousOwner != from) {
            revert ERC721IncorrectOwner(from, tokenId, previousOwner);
        }
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking that contract recipients
     * are aware of the ERC721 standard to prevent tokens from being forever locked.
     *
     * `data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is like {safeTransferFrom} in the sense that it invokes
     * {IERC721Receiver-onERC721Received} on the receiver, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `tokenId` token must exist and be owned by `from`.
     * - `to` cannot be the zero address.
     * - `from` cannot be the zero address.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(address from, address to, uint256 tokenId) internal {
        _safeTransfer(from, to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeTransfer-address-address-uint256-}[`_safeTransfer`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal virtual {
        _transfer(from, to, tokenId);
        _checkOnERC721Received(from, to, tokenId, data);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * The `auth` argument is optional. If the value passed is non 0, then this function will check that `auth` is
     * either the owner of the token, or approved to operate on all tokens held by this owner.
     *
     * Emits an {Approval} event.
     *
     * Overrides to this logic should be done to the variant with an additional `bool emitEvent` argument.
     */
    function _approve(address to, uint256 tokenId, address auth) internal {
        _approve(to, tokenId, auth, true);
    }

    /**
     * @dev Variant of `_approve` with an optional flag to enable or disable the {Approval} event. The event is not
     * emitted in the context of transfers.
     */
    function _approve(address to, uint256 tokenId, address auth, bool emitEvent) internal virtual {
        // Avoid reading the owner unless necessary
        if (emitEvent || auth != address(0)) {
            address owner = _requireOwned(tokenId);

            // We do not use _isAuthorized because single-token approvals should not be able to call approve
            if (auth != address(0) && owner != auth && !isApprovedForAll(owner, auth)) {
                revert ERC721InvalidApprover(auth);
            }

            if (emitEvent) {
                emit Approval(owner, to, tokenId);
            }
        }

        _tokenApprovals[tokenId] = to;
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Requirements:
     * - operator can't be the address zero.
     *
     * Emits an {ApprovalForAll} event.
     */
    function _setApprovalForAll(address owner, address operator, bool approved) internal virtual {
        if (operator == address(0)) {
            revert ERC721InvalidOperator(operator);
        }
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Reverts if the `tokenId` doesn't have a current owner (it hasn't been minted, or it has been burned).
     * Returns the owner.
     *
     * Overrides to ownership logic should be done to {_ownerOf}.
     */
    function _requireOwned(uint256 tokenId) internal view returns (address) {
        address owner = _ownerOf(tokenId);
        if (owner == address(0)) {
            revert ERC721NonexistentToken(tokenId);
        }
        return owner;
    }

    /**
     * @dev Private function to invoke {IERC721Receiver-onERC721Received} on a target address. This will revert if the
     * recipient doesn't accept the token transfer. The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param data bytes optional data to send along with the call
     */
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) private {
        if (to.code.length > 0) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, data) returns (bytes4 retval) {
                if (retval != IERC721Receiver.onERC721Received.selector) {
                    revert ERC721InvalidReceiver(to);
                }
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert ERC721InvalidReceiver(to);
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.20;

import {IERC165} from "../../utils/introspection/IERC165.sol";

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
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
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
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or
     *   {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
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
     * - The `operator` cannot be the address zero.
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
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.20;

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
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be
     * reverted.
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
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/extensions/ERC721Burnable.sol)

pragma solidity ^0.8.20;

import {ERC721} from "../ERC721.sol";
import {Context} from "../../../utils/Context.sol";

/**
 * @title ERC721 Burnable Token
 * @dev ERC721 Token that can be burned (destroyed).
 */
abstract contract ERC721Burnable is Context, ERC721 {
    /**
     * @dev Burns `tokenId`. See {ERC721-_burn}.
     *
     * Requirements:
     *
     * - The caller must own `tokenId` or be an approved operator.
     */
    function burn(uint256 tokenId) public virtual {
        // Setting an "auth" arguments enables the `_isAuthorized` check which verifies that the token exists
        // (from != 0). Therefore, it is not needed to verify that the return value is not 0 here.
        _update(address(0), tokenId, _msgSender());
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/extensions/ERC721Enumerable.sol)

pragma solidity ^0.8.20;

import {ERC721} from "../ERC721.sol";
import {IERC721Enumerable} from "./IERC721Enumerable.sol";
import {IERC165} from "../../../utils/introspection/ERC165.sol";

/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds enumerability
 * of all the token ids in the contract as well as all token ids owned by each account.
 *
 * CAUTION: `ERC721` extensions that implement custom `balanceOf` logic, such as `ERC721Consecutive`,
 * interfere with enumerability and should not be used together with `ERC721Enumerable`.
 */
abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    mapping(address owner => mapping(uint256 index => uint256)) private _ownedTokens;
    mapping(uint256 tokenId => uint256) private _ownedTokensIndex;

    uint256[] private _allTokens;
    mapping(uint256 tokenId => uint256) private _allTokensIndex;

    /**
     * @dev An `owner`'s token query was out of bounds for `index`.
     *
     * NOTE: The owner being `address(0)` indicates a global out of bounds index.
     */
    error ERC721OutOfBoundsIndex(address owner, uint256 index);

    /**
     * @dev Batch mint is not allowed.
     */
    error ERC721EnumerableForbiddenBatchMint();

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual returns (uint256) {
        if (index >= balanceOf(owner)) {
            revert ERC721OutOfBoundsIndex(owner, index);
        }
        return _ownedTokens[owner][index];
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual returns (uint256) {
        if (index >= totalSupply()) {
            revert ERC721OutOfBoundsIndex(address(0), index);
        }
        return _allTokens[index];
    }

    /**
     * @dev See {ERC721-_update}.
     */
    function _update(address to, uint256 tokenId, address auth) internal virtual override returns (address) {
        address previousOwner = super._update(to, tokenId, auth);

        if (previousOwner == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (previousOwner != to) {
            _removeTokenFromOwnerEnumeration(previousOwner, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (previousOwner != to) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }

        return previousOwner;
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = balanceOf(to) - 1;
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = balanceOf(from);
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }

    /**
     * See {ERC721-_increaseBalance}. We need that to account tokens that were minted in batch
     */
    function _increaseBalance(address account, uint128 amount) internal virtual override {
        if (amount > 0) {
            revert ERC721EnumerableForbiddenBatchMint();
        }
        super._increaseBalance(account, amount);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/extensions/ERC721Royalty.sol)

pragma solidity ^0.8.20;

import {ERC721} from "../ERC721.sol";
import {ERC2981} from "../../common/ERC2981.sol";

/**
 * @dev Extension of ERC721 with the ERC2981 NFT Royalty Standard, a standardized way to retrieve royalty payment
 * information.
 *
 * Royalty information can be specified globally for all token ids via {ERC2981-_setDefaultRoyalty}, and/or individually
 * for specific token ids via {ERC2981-_setTokenRoyalty}. The latter takes precedence over the first.
 *
 * IMPORTANT: ERC-2981 only specifies a way to signal royalty information and does not enforce its payment. See
 * https://eips.ethereum.org/EIPS/eip-2981#optional-royalty-payments[Rationale] in the EIP. Marketplaces are expected to
 * voluntarily pay royalties together with sales, but note that this standard is not yet widely supported.
 */
abstract contract ERC721Royalty is ERC2981, ERC721 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC2981) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.20;

import {IERC721} from "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.20;

import {IERC721} from "../IERC721.sol";

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
// OpenZeppelin Contracts (last updated v5.0.0) (token/common/ERC2981.sol)

pragma solidity ^0.8.20;

import {IERC2981} from "../../interfaces/IERC2981.sol";
import {IERC165, ERC165} from "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of the NFT Royalty Standard, a standardized way to retrieve royalty payment information.
 *
 * Royalty information can be specified globally for all token ids via {_setDefaultRoyalty}, and/or individually for
 * specific token ids via {_setTokenRoyalty}. The latter takes precedence over the first.
 *
 * Royalty is specified as a fraction of sale price. {_feeDenominator} is overridable but defaults to 10000, meaning the
 * fee is specified in basis points by default.
 *
 * IMPORTANT: ERC-2981 only specifies a way to signal royalty information and does not enforce its payment. See
 * https://eips.ethereum.org/EIPS/eip-2981#optional-royalty-payments[Rationale] in the EIP. Marketplaces are expected to
 * voluntarily pay royalties together with sales, but note that this standard is not yet widely supported.
 */
abstract contract ERC2981 is IERC2981, ERC165 {
    struct RoyaltyInfo {
        address receiver;
        uint96 royaltyFraction;
    }

    RoyaltyInfo private _defaultRoyaltyInfo;
    mapping(uint256 tokenId => RoyaltyInfo) private _tokenRoyaltyInfo;

    /**
     * @dev The default royalty set is invalid (eg. (numerator / denominator) >= 1).
     */
    error ERC2981InvalidDefaultRoyalty(uint256 numerator, uint256 denominator);

    /**
     * @dev The default royalty receiver is invalid.
     */
    error ERC2981InvalidDefaultRoyaltyReceiver(address receiver);

    /**
     * @dev The royalty set for an specific `tokenId` is invalid (eg. (numerator / denominator) >= 1).
     */
    error ERC2981InvalidTokenRoyalty(uint256 tokenId, uint256 numerator, uint256 denominator);

    /**
     * @dev The royalty receiver for `tokenId` is invalid.
     */
    error ERC2981InvalidTokenRoyaltyReceiver(uint256 tokenId, address receiver);

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC165) returns (bool) {
        return interfaceId == type(IERC2981).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @inheritdoc IERC2981
     */
    function royaltyInfo(uint256 tokenId, uint256 salePrice) public view virtual returns (address, uint256) {
        RoyaltyInfo memory royalty = _tokenRoyaltyInfo[tokenId];

        if (royalty.receiver == address(0)) {
            royalty = _defaultRoyaltyInfo;
        }

        uint256 royaltyAmount = (salePrice * royalty.royaltyFraction) / _feeDenominator();

        return (royalty.receiver, royaltyAmount);
    }

    /**
     * @dev The denominator with which to interpret the fee set in {_setTokenRoyalty} and {_setDefaultRoyalty} as a
     * fraction of the sale price. Defaults to 10000 so fees are expressed in basis points, but may be customized by an
     * override.
     */
    function _feeDenominator() internal pure virtual returns (uint96) {
        return 10000;
    }

    /**
     * @dev Sets the royalty information that all ids in this contract will default to.
     *
     * Requirements:
     *
     * - `receiver` cannot be the zero address.
     * - `feeNumerator` cannot be greater than the fee denominator.
     */
    function _setDefaultRoyalty(address receiver, uint96 feeNumerator) internal virtual {
        uint256 denominator = _feeDenominator();
        if (feeNumerator > denominator) {
            // Royalty fee will exceed the sale price
            revert ERC2981InvalidDefaultRoyalty(feeNumerator, denominator);
        }
        if (receiver == address(0)) {
            revert ERC2981InvalidDefaultRoyaltyReceiver(address(0));
        }

        _defaultRoyaltyInfo = RoyaltyInfo(receiver, feeNumerator);
    }

    /**
     * @dev Removes default royalty information.
     */
    function _deleteDefaultRoyalty() internal virtual {
        delete _defaultRoyaltyInfo;
    }

    /**
     * @dev Sets the royalty information for a specific token id, overriding the global default.
     *
     * Requirements:
     *
     * - `receiver` cannot be the zero address.
     * - `feeNumerator` cannot be greater than the fee denominator.
     */
    function _setTokenRoyalty(uint256 tokenId, address receiver, uint96 feeNumerator) internal virtual {
        uint256 denominator = _feeDenominator();
        if (feeNumerator > denominator) {
            // Royalty fee will exceed the sale price
            revert ERC2981InvalidTokenRoyalty(tokenId, feeNumerator, denominator);
        }
        if (receiver == address(0)) {
            revert ERC2981InvalidTokenRoyaltyReceiver(tokenId, address(0));
        }

        _tokenRoyaltyInfo[tokenId] = RoyaltyInfo(receiver, feeNumerator);
    }

    /**
     * @dev Resets royalty information for the token id back to the global default.
     */
    function _resetTokenRoyalty(uint256 tokenId) internal virtual {
        delete _tokenRoyaltyInfo[tokenId];
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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Strings.sol)

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
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
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
     * @dev Returns true if the two strings are equal.
     */
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return bytes(a).length == bytes(b).length && keccak256(bytes(a)) == keccak256(bytes(b));
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/cryptography/MerkleProof.sol)

pragma solidity ^0.8.20;

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
 * the Merkle tree could be reinterpreted as a leaf value.
 * OpenZeppelin's JavaScript library generates Merkle trees that are safe
 * against this attack out of the box.
 */
library MerkleProof {
    /**
     *@dev The multiproof provided is not valid.
     */
    error MerkleProofInvalidMultiproof();

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
     */
    function verifyCalldata(bytes32[] calldata proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        return processProofCalldata(proof, leaf) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merkle tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leafs & pre-images are assumed to be sorted.
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
     */
    function processProofCalldata(bytes32[] calldata proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Returns true if the `leaves` can be simultaneously proven to be a part of a Merkle tree defined by
     * `root`, according to `proof` and `proofFlags` as described in {processMultiProof}.
     *
     * CAUTION: Not all Merkle trees admit multiproofs. See {processMultiProof} for details.
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
     * CAUTION: Not all Merkle trees admit multiproofs. See {processMultiProof} for details.
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
     * CAUTION: Not all Merkle trees admit multiproofs. To use multiproofs, it is sufficient to ensure that: 1) the tree
     * is complete (but not necessarily perfect), 2) the leaves to be proven are in the opposite order they are in the
     * tree (i.e., as seen from right to left starting at the deepest layer and continuing at the next layer).
     */
    function processMultiProof(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuilds the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the Merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 proofLen = proof.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        if (leavesLen + proofLen != totalHashes + 1) {
            revert MerkleProofInvalidMultiproof();
        }

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
            if (proofPos != proofLen) {
                revert MerkleProofInvalidMultiproof();
            }
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
     * CAUTION: Not all Merkle trees admit multiproofs. See {processMultiProof} for details.
     */
    function processMultiProofCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuilds the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the Merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 proofLen = proof.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        if (leavesLen + proofLen != totalHashes + 1) {
            revert MerkleProofInvalidMultiproof();
        }

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
            if (proofPos != proofLen) {
                revert MerkleProofInvalidMultiproof();
            }
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
     * @dev Sorts the pair (a, b) and hashes the result.
     */
    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {
        return a < b ? _efficientHash(a, b) : _efficientHash(b, a);
    }

    /**
     * @dev Implementation of keccak256(abi.encode(a, b)) that doesn't allocate or expand memory.
     */
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/Math.sol)

pragma solidity ^0.8.20;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Muldiv operation overflow.
     */
    error MathOverflowedMulDiv();

    enum Rounding {
        Floor, // Toward negative infinity
        Ceil, // Toward positive infinity
        Trunc, // Toward zero
        Expand // Away from zero
    }

    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
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
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
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
     * This differs from standard division with `/` in that it rounds towards infinity instead
     * of rounding towards zero.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b == 0) {
            // Guarantee the same behavior as in a regular Solidity division.
            return a / b;
        }

        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or
     * denominator == 0.
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv) with further edits by
     * Uniswap Labs also under MIT license.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
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

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            if (denominator <= prod1) {
                revert MathOverflowedMulDiv();
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

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also
            // works in modular arithmetic, doubling the correct bits in each step.
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
        if (unsignedRoundsUp(rounding) && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded
     * towards zero.
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
            return result + (unsignedRoundsUp(rounding) && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2 of a positive value rounded towards zero.
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
            return result + (unsignedRoundsUp(rounding) && 1 << result < value ? 1 : 0);
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
            return result + (unsignedRoundsUp(rounding) && 10 ** result < value ? 1 : 0);
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
            return result + (unsignedRoundsUp(rounding) && 1 << (result << 3) < value ? 1 : 0);
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
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/SignedMath.sol)

pragma solidity ^0.8.20;

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
pragma solidity ^0.8.23;

// Import OpenZeppelin contracts
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

// Kondux contract inherits from various OpenZeppelin contracts
contract Kondux is ERC721, ERC721Enumerable, ERC721Burnable, ERC721Royalty, AccessControl {
    uint256 private _tokenIdCounter;

    // Events emitted by the contract
    event BaseURIChanged(string baseURI);
    event DnaChanged(uint256 indexed tokenID, uint256 dna);
    event DenominatorChanged(uint96 denominator);
    event DnaModified(uint256 indexed tokenID, uint256 dna, uint256 inputValue, uint8 startIndex, uint8 endIndex);
    event RoleChanged(address indexed addr, bytes32 role, bool enabled);

    // Role definitions
    bytes32 public MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public DNA_MODIFIER_ROLE = keccak256("DNA_MODIFIER_ROLE");

    // Contract state variables
    string public baseURI;
    uint96 public denominator;

    mapping (uint256 => uint256) public indexDna; // Maps token IDs to DNA values
    
    mapping (uint256 => uint256) public transferDates; // Maps token IDs to the timestamp of receiving the token

    /**
     * @dev Initializes the Kondux contract with the given name and symbol.
     * Grants the DEFAULT_ADMIN_ROLE, MINTER_ROLE, and DNA_MODIFIER_ROLE to the contract creator.
     * Inherits the ERC721 constructor to set the token name and symbol.
     *
     * @param _name The name of the token.
     * @param _symbol The symbol of the token.
     */
    constructor(string memory _name, string memory _symbol) 
        ERC721(_name, _symbol) {
            _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
            _grantRole(MINTER_ROLE, msg.sender);
            _grantRole(DNA_MODIFIER_ROLE, msg.sender);
    }


    /**
     * @dev Modifier that requires the caller to have the DEFAULT_ADMIN_ROLE.
     * Reverts with an error message if the caller does not have the required role.
     */
    modifier onlyAdmin() {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "kNFT Access Control: only admin");
        _;
    }

    /**
     * @dev Modifier that requires the caller to have the MINTER_ROLE.
     * Reverts with an error message if the caller does not have the required role.
     */
    modifier onlyMinter() {
        require(hasRole(MINTER_ROLE, msg.sender), "kNFT Access Control: only minter");
        _;
    }

    /**
     * @dev Modifier that requires the caller to have the DNA_MODIFIER_ROLE.
     * Reverts with an error message if the caller does not have the required role.
     */
    modifier onlyDnaModifier() {
        require(hasRole(DNA_MODIFIER_ROLE, msg.sender), "kNFT Access Control: only dna modifier");
        _;
    }

    /**
     * @dev Changes the denominator value.
     * Emits a DenominatorChanged event with the new denominator value.
     *
     * @param _denominator The new denominator value.
     * @return The updated denominator value.
     */
    function changeDenominator(uint96 _denominator) public onlyAdmin returns (uint96) { 
        denominator = _denominator;
        emit DenominatorChanged(denominator);
        return denominator;
    }

    /**
     * @dev Sets the default royalty for the contract.
     *
     * @param receiver The address that will receive the royalty fees.
     * @param feeNumerator The numerator of the royalty fee.
     */
    function setDefaultRoyalty(address receiver, uint96 feeNumerator) public onlyAdmin {
        _setDefaultRoyalty(receiver, feeNumerator);
    }

    /**
     * @dev Sets the royalty for a specific token.
     *
     * @param tokenId The ID of the token for which the royalty will be set.
     * @param receiver The address that will receive the royalty fees.
     * @param feeNumerator The numerator of the royalty fee.
     */
    function setTokenRoyalty(uint256 tokenId,address receiver,uint96 feeNumerator) public onlyAdmin {
        _setTokenRoyalty(tokenId, receiver, feeNumerator); 
    }

    /**
     * @dev Sets the base URI for token metadata.
     * Emits a BaseURIChanged event with the new base URI.
     *
     * @param _newURI The new base URI.
     * @return The updated base URI.
     */
    function setBaseURI(string memory _newURI) external onlyAdmin returns (string memory) {
        baseURI = _newURI;
        emit BaseURIChanged(baseURI);
        return baseURI;
    }

    /**
     * @dev Returns the token URI for a given token ID.
     * Reverts if the token ID does not exist.
     *
     * @param tokenId The ID of the token.
     * @return The token URI.
     */
    function tokenURI(uint256 tokenId) public view override(ERC721) returns (string memory) {
        require(_ownerOf(tokenId) != address(0), "ERC721Metadata: URI query for nonexistent token");
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, Strings.toString(tokenId))) : "";
    }

    /**
     * @dev Safely mints a new token with a specified DNA value for the recipient.
     * Increments the token ID counter.
     *
     * @param to The address of the recipient.
     * @param dna The DNA value of the new token.
     * @return The new token ID.
     */
    function safeMint(address to, uint256 dna) public onlyMinter returns (uint256) {
        uint256 tokenId = _tokenIdCounter++;
        _setDna(tokenId, dna);
        _safeMint(to, tokenId);
        return tokenId;
    }

    /**
     * @dev Sets the DNA value for a given token ID.
     *
     * @param _tokenID The ID of the token for which the DNA value will be set.
     * @param _dna The new DNA value.
     */
    function setDna(uint256 _tokenID, uint256 _dna) public onlyDnaModifier {
        _setDna(_tokenID, _dna);
    }

    /**
     * @dev Returns the DNA value for a given token ID.
     * Reverts if the token ID does not exist.
     *
     * @param _tokenID The ID of the token.
     * @return The DNA value of the token.
     */
    function getDna(uint256 _tokenID) public view returns (uint256) {
        require(_ownerOf(_tokenID) != address(0), "ERC721Metadata: URI query for nonexistent token");
        return indexDna[_tokenID];
    }

    /**
     * @dev Reads a range of bytes from the DNA value of a given token ID.
     * Reverts if the specified range is invalid.
     *
     * @param _tokenID The ID of the token.
     * @param startIndex The starting index of the byte range.
     * @param endIndex The ending index of the byte range.
     * @return The extracted value from the specified byte range.
     */
    function readGene(uint256 _tokenID, uint8 startIndex, uint8 endIndex) public view returns (int256) {
        require(startIndex < endIndex && endIndex <= 32, "Invalid range");

        uint256 originalValue = indexDna[_tokenID];
        uint256 extractedValue;

        for (uint8 i = startIndex; i < endIndex; i++) {
            assembly {
                let bytePos := sub(31, i) // Reverse the index since bytes are stored in big-endian
                let shiftAmount := mul(8, bytePos)

                // Extract the byte from the original value at the current position
                let extractedByte := and(shr(shiftAmount, originalValue), 0xff)

                // Shift the extracted byte to the left by the number of positions
                // from the start of the requested range
                let adjustedShiftAmount := mul(8, sub(i, startIndex))

                // Combine the shifted byte with the previously extracted bytes
                extractedValue := or(extractedValue, shl(adjustedShiftAmount, extractedByte))
            }
        }

        return int256(extractedValue);
    }

    /**
     * @dev Writes a range of bytes to the DNA value of a given token ID.
     * @param _tokenID The ID of the token.
     * @param inputValue The value to be written to the specified byte range.
     * @param startIndex The starting index of the byte range.
     * @param endIndex The ending index of the byte range.
     */ 
    function writeGene(uint256 _tokenID, uint256 inputValue, uint8 startIndex, uint8 endIndex) public onlyDnaModifier {
        _writeGene(_tokenID, inputValue, startIndex, endIndex); 
    }

    /**
     * @dev Writes a range of bytes to the DNA value of a given token ID.
     * Reverts if the specified range is invalid or the input value is too large.
     *
     * @param _tokenID The ID of the token.
     * @param inputValue The value to be written to the specified byte range.
     * @param startIndex The starting index of the byte range.
     * @param endIndex The ending index of the byte range.
     */
    function _writeGene(uint256 _tokenID, uint256 inputValue, uint8 startIndex, uint8 endIndex) internal {
        require(startIndex < endIndex && endIndex <= 32, "Invalid range");
        require(inputValue >= 0, "Only positive values are supported");

        uint256 maxInputValue = (1 << ((endIndex - startIndex) * 8)) - 1;
        require(uint256(inputValue) <= maxInputValue, "Input value is too large for the specified range");

        uint256 originalValue = indexDna[_tokenID];
        uint256 mask;
        uint256 updatedValue;

        for (uint8 i = startIndex; i < endIndex; i++) {
            assembly {
                let bytePos := sub(31, i) // Reverse the index since bytes are stored in big-endian
                let shiftAmount := mul(8, bytePos)

                // Prepare the mask for the current byte
                mask := or(mask, shl(shiftAmount, 0xff))

                // Prepare the updated value
                updatedValue := or(updatedValue, shl(shiftAmount, and(shr(mul(8, sub(i, startIndex)), inputValue), 0xff)))
            }
        }

        // Clear the bytes in the specified range of the original value, then store the updated value
        indexDna[_tokenID] = (originalValue & ~mask) | (updatedValue & mask);

        // Emit the BytesRangeModified event
        emit DnaModified(_tokenID, indexDna[_tokenID], inputValue, startIndex, endIndex);
    }

    /**
     * @dev Add or remove a role from an address.
     * @param role The role identifier (keccak256 hash of the role name).
     * @param addr The address for which the role will be granted or revoked.
     * @param enabled Flag to indicate if the role should be granted (true) or revoked (false).
     */
    function setRole(bytes32 role, address addr, bool enabled) public onlyAdmin {
        if (enabled) {
            _grantRole(role, addr);
        } else {
            _revokeRole(role, addr);
        }
        emit RoleChanged(addr, role, enabled);
    }

    /**
     * @dev Returns the timestamp of the last transfer for a given token ID.
     * Reverts if the token ID does not exist.
     *
     * @param tokenId The ID of the token.
     * @return The timestamp of the last transfer.
     */
    function getTransferDate(uint256 tokenId) public view returns (uint256) {
        require(_ownerOf(tokenId) != address(0), "ERC721Metadata: URI query for nonexistent token");
        return transferDates[tokenId];
    }
  
    // Internal functions //

    /**
     * @dev Returns the base URI for constructing token URIs.
     * @return The base URI.
     */
    function _baseURI() internal view override returns (string memory) { 
        return baseURI;
    }

    /**
     * @dev Internal function to set the DNA value for a given token ID.
     * @param _tokenID The ID of the token.
     * @param _dna The DNA value to be set.
     */
    function _setDna(uint256 _tokenID, uint256 _dna) internal {
        indexDna[_tokenID] = _dna;
        emit DnaChanged(_tokenID, _dna);
    }

    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding Solidity interface to learn more
     * about how these IDs are created.
     * @param interfaceId The interface identifier.
     * @return Whether the interface is supported.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, ERC721Royalty, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    /**
     * @dev Internal function to update the balance of a given account.
     * @param to The address of the account.
     * @param tokenId The ID of the token.
     * @param auth The address of the authorizer.
     */
    function _update(address to, uint256 tokenId, address auth) internal
        override(ERC721, ERC721Enumerable) 
        returns (address prevOwner) {
        return super._update(to, tokenId, auth);
    }

    /**
     * @dev Internal function to increase the balance of a given account.
     * @param account The address of the account.
     * @param value The amount by which to increase the balance.
     */
    function _increaseBalance(address account, uint128 value) internal
        override(ERC721, ERC721Enumerable) {
        super._increaseBalance(account, value);
    }

}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;
import "./interfaces/IKondux.sol";
import "./interfaces/ITreasury.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";


/**
 * @title MinterBundle
 * @notice Manages the minting of NFT bundles, including setting prices, pausing/unpausing minting, and interacting with external contracts for NFT and treasury management. Designed to facilitate bulk operations for efficiency and convenience.
 * @dev Inherits from OpenZeppelin's AccessControl for comprehensive role management, enabling a robust permission system. Utilizes interfaces for external contract interactions, ensuring modularity and flexibility.
 */
contract MinterBundle is AccessControl {

    bool public paused; // Controls whether minting is currently allowed.
    bool public foundersPassActive; // Controls whether founders pass can be used for minting.
    bool public kBoxActive; // Controls whether kBox can be used for minting.
    bool public kNFTActive; // Controls whether kNFT can be used for minting.
    bool public whitelistActive; // Controls whether the whitelist is active.
    uint16 public bundleSize; // The number of NFTs in each minted bundle.
    uint256 public price; // The ETH price for minting a bundle.
    bytes32 public rootWhitelist; // The Merkle root for the whitelist.

    IKondux public kNFT; // Interface to interact with the Kondux NFT contract for NFT operations.
    IKondux public kBox; // Interface for the kBOX NFT contract, allowing for special minting conditions.
    IKondux public foundersPass; // Interface for the founders pass contract, allowing for special minting conditions.
    ITreasury public treasury; // Interface to interact with the treasury contract for financial transactions.

    mapping (uint256 => bool) public usedFoundersPass;

    // Events for tracking contract state changes and interactions.
    event BundleMinted(address indexed minter, uint256[] tokenIds);
    event FoundersPassUsed(address indexed minter, uint256[] tokenIds, uint256 foundersPassId);
    event TreasuryChanged(address indexed treasury);
    event KNFTChanged(address indexed kNFT);
    event KBoxChanged(address indexed kBox);
    event FoundersPassChanged(address indexed foundersPass);
    event PriceChanged(uint256 price);
    event BundleSizeChanged(uint16 bundleSize);
    event Paused(bool paused);
    event PublicMintActive(bool active);
    event KBoxMintActive(bool active);
    event FoundersPassMintActive(bool active);
    event WhitelistActive(bool active);
    event WhitelistRootChanged(bytes32 root);

    /**
     * @dev Sets initial contract state, including addresses of related contracts, default price, and bundle size. Grants admin role to the deployer for further administrative actions.
     * @param _kNFT Address of the Kondux NFT contract.
     * @param _kBox Address of the kBox NFT contract.
     * @param _treasury Address of the treasury contract.
     */
    constructor(address _kNFT, address _kBox, address _foundersPass, address _treasury) {
        kNFT = IKondux(_kNFT);
        kBox = IKondux(_kBox);
        foundersPass = IKondux(_foundersPass);
        treasury = ITreasury(_treasury);
        price = 0.25 ether;
        bundleSize = 5;
        paused = true;
        foundersPassActive = true;
        kBoxActive = true;
        whitelistActive = true;
        kNFTActive = false;
        
        // Grant admin role to the message sender
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /**
     * @notice Toggles the paused state of minting operations.
     * @dev Can only be executed by an admin. Emits a `Paused` event reflecting the new state.
     * @param _paused Boolean indicating the desired paused state.
     */
    function setPaused(bool _paused) public onlyAdmin {
        paused = _paused;
        emit Paused(_paused);
    }

    /**
     * @notice Mints a bundle of NFTs if minting is active and sufficient ETH is sent.
     * @dev Validates the sent ETH amount against the current price, deposits the ETH to the treasury, and mints the NFT bundle. Requires the contract to not be paused.
     * @return tokenIds Array of minted token IDs.
     */
    function publicMint() public payable isActive isPublicMintActive returns (uint256[] memory) {
        require(msg.value >= price, "Not enough ETH sent");
        treasury.depositEther{ value: msg.value }();
        uint256[] memory tokenIds = _mintBundle(bundleSize);
        emit BundleMinted(msg.sender, tokenIds);
        return tokenIds;
    }

    /**
     * @notice Mints a bundle of NFTs if minting is active and sufficient ETH is sent. Requires the sender to be on the whitelist.
     * @dev Validates the sent ETH amount against the current price, deposits the ETH to the treasury, and mints the NFT bundle. Requires the contract to not be paused and the whitelist to be active.
     * @param _merkleProof The Merkle proof for the sender's address.
     * @return tokenIds Array of minted token IDs.
     */     
    function publicMintWhitelist(bytes32[] calldata _merkleProof) public payable isActive isWhitelistActive returns (uint256[] memory) {
        require(msg.value >= price, "Not enough ETH sent");        
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(_merkleProof, rootWhitelist, leaf), "Incorrect proof");
        treasury.depositEther{ value: msg.value }();
        uint256[] memory tokenIds = _mintBundle(bundleSize);
        emit BundleMinted(msg.sender, tokenIds);
        return tokenIds;
    }

    /**
     * @notice Burns a specified kBox and mints a bundle of NFTs as a special minting operation.
     * @dev Requires the sender to be the owner of the kBox and for the contract to be approved to burn the kBox. This function demonstrates an alternative minting pathway with additional prerequisites.
     * @param _kBoxId The ID of the kBox to be burned in exchange for minting a new NFT bundle.
     * @return tokenIds Array of minted token IDs.
     */
    function publicMintWithBox(uint256 _kBoxId) public isActive isKBoxMintActive returns (uint256[] memory){
        require(kBox.ownerOf(_kBoxId) == msg.sender, "You are not the owner of this kBox");
        require(kBox.getApproved(_kBoxId) == address(this), "This contract is not approved to burn this kBox");

        kBox.burn(_kBoxId);

        // Mint a bundle of NFTs
        uint256[] memory tokenIds = _mintBundle(bundleSize);

        emit BundleMinted(msg.sender, tokenIds);
        return tokenIds;
    }

    /**
     * @notice Marsks a specified founders pass as used and mints a bundle of NFTs as a special minting operation.
     * @dev Requires the sender to be the owner of the founders pass and we mark it as used in the redeem process. This function demonstrates an alternative minting pathway with additional prerequisites.
     * @param _foundersPassId The ID of the founders pass to be marked as used in exchange for minting a new NFT bundle.
     * @return tokenIds Array of minted token IDs.
     */
    function publicMintWithFoundersPass(uint256 _foundersPassId) public isActive isFoundersPassMintActive returns (uint256[] memory){
        require(foundersPass.ownerOf(_foundersPassId) == msg.sender, "You are not the owner of this founders pass");
        require(!usedFoundersPass[_foundersPassId], "This founders pass has already been used");

        usedFoundersPass[_foundersPassId] = true;

        // Mint a bundle of NFTs
        uint256[] memory tokenIds = _mintBundle(bundleSize);

        emit FoundersPassUsed(msg.sender, tokenIds, _foundersPassId);
        return tokenIds;
    }

    /**
     * @notice Sets the DNA for each NFT in a minted bundle.
     * @dev Admin-only function that assigns a unique DNA to each NFT in the bundle, ensuring that each NFT has distinct characteristics. Validates that the lengths of the `tokenIds` and `dnas` arrays match and correspond to the current `bundleSize`.
     * @param tokenIds Array of token IDs for which to set DNA.
     * @param dnas Array of DNA values corresponding to each token ID.
     */
    function setBundleDna(uint256[] memory tokenIds, uint256[] memory dnas) public onlyAdmin {        
        require(tokenIds.length == dnas.length, "Array lengths do not match");
        require(tokenIds.length == bundleSize, "Array length must match bundle size");
        for (uint256 i = 0; i < bundleSize; i++) {
            kNFT.setDna(tokenIds[i], dnas[i]);
        }
    }

    /**
     * @notice Updates the address of the kBox NFT contract.
     * @dev Admin-only function to change the contract address through which the smart contract interacts with kBox NFTs. Emits a `KNFTChanged` event on success.
     * @param _kBox The new address of the kBox contract.
     */
    function setKBox(address _kBox) public onlyAdmin {
        require(_kBox != address(0), "kBox address is not set");
        kBox = IKondux(_kBox);
        emit KBoxChanged(_kBox);
    }

    /**
     * @notice Updates the address of the treasury contract.
     * @dev Admin-only function to change the contract address for managing treasury operations. Validates the new address before updating and emits a `TreasuryChanged` event on success.
     * @param _treasury The new treasury contract address.
     */
    function setTreasury(address _treasury) public onlyAdmin {
        require(_treasury != address(0), "Treasury address is not set");
        treasury = ITreasury(_treasury);
        emit TreasuryChanged(_treasury);
    }

    /**
     * @notice Updates the address of the Kondux NFT contract.
     * @dev Admin-only function to change the contract address for managing Kondux NFT operations. Validates the new address before updating and emits a `KNFTChanged` event on success.
     * @param _kNFT The new Kondux NFT contract address.
     */
    function setKNFT(address _kNFT) public onlyAdmin {
        require(_kNFT != address(0), "KNFT address is not set");
        kNFT = IKondux(_kNFT);
        emit KNFTChanged(_kNFT);
    }

    /**
     * @notice Updates the address of the founders pass contract.
     * @dev Admin-only function to change the contract address for managing founders pass operations. Validates the new address before updating and emits a `FoundersPassChanged` event on success.
     * @param _foundersPass The new founders pass contract address.
     */
    function setFoundersPass(address _foundersPass) public onlyAdmin {
        require(_foundersPass != address(0), "Founders pass address is not set");
        foundersPass = IKondux(_foundersPass);
        emit FoundersPassChanged(_foundersPass);
    }

    /**
     * @notice Updates the minting price for an NFT bundle.
     * @dev Admin-only function to adjust the ETH price required to mint an NFT bundle. Validates the new price before applying the change and emits a `PriceChanged` event on success.
     * @param _price The new minting price in ETH.
     */
    function setPrice(uint256 _price) public onlyAdmin {
        require(_price > 0, "Price must be greater than 0");
        price = _price;
        emit PriceChanged(_price);
    }

    /**
     * @notice Adjusts the size of the NFT bundle that can be minted at once.
     * @dev Admin-only function to set the number of NFTs included in a single mint operation. Validates the new size for practical limits and emits a `BundleSizeChanged` event on update.
     * @param _bundleSize The new bundle size, within set boundaries.
     */
    function setBundleSize(uint16 _bundleSize) public onlyAdmin {
        require(_bundleSize > 0, "Bundle size must be greater than 0");
        require(_bundleSize <= 15, "Bundle size must be less than or equal to 15");
        bundleSize = _bundleSize;
        emit BundleSizeChanged(_bundleSize);
    }

    /**
     * @notice Grants the admin role to a specified address.
     * @dev Can be executed only by an existing admin. Ensures that the target address is not already an admin and is not the zero address before granting the role.
     * @param _admin The address to be granted admin privileges.
     */
    function setAdmin(address _admin) public onlyAdmin {
        require(_admin != address(0), "Admin address is not set");
        require(!hasRole(DEFAULT_ADMIN_ROLE, _admin), "Address already has admin role");
        grantRole(DEFAULT_ADMIN_ROLE, _admin);
    }

    /**
     * @notice Sets the active state for public minting of Kondux NFTs.
     * @dev Admin-only function to toggle the active state of public minting for Kondux NFTs. Emits a `PublicMintActive` event reflecting the new state.
     * @param _active Boolean indicating the desired active state.
     */
    function setPublicMintActive(bool _active) public onlyAdmin {
        kNFTActive = _active;
        emit PublicMintActive(_active);
    }

    /**
     * @notice Sets the active state for kBox minting.
     * @dev Admin-only function to toggle the active state of minting kBox NFTs. Emits a `KBoxMintActive` event reflecting the new state.
     * @param _active Boolean indicating the desired active state.
     */
    function setKBoxMintActive(bool _active) public onlyAdmin {
        kBoxActive = _active;
        emit KBoxMintActive(_active);
    }

    /**
     * @notice Sets the active state for founders pass minting.
     * @dev Admin-only function to toggle the active state of minting NFTs with founders passes. Emits a `FoundersPassMintActive` event reflecting the new state.
     * @param _active Boolean indicating the desired active state.
     */
    function setFoundersPassMintActive(bool _active) public onlyAdmin {
        foundersPassActive = _active;
        emit FoundersPassMintActive(_active);
    }

    /**
     * @notice Sets the active state for the whitelist.
     * @dev Admin-only function to toggle the active state of the whitelist. Emits a `WhitelistActive` event reflecting the new state.
     * @param _active Boolean indicating the desired active state.
     */
    function setWhitelistActive(bool _active) public onlyAdmin {
        whitelistActive = _active;
        emit WhitelistActive(_active);
    }

    /**
     * @notice Updates the Merkle root for the whitelist.
     * @dev Admin-only function to set a new Merkle root for the whitelist. Emits a `WhitelistRootChanged` event reflecting the new root.
     * @param _root The new Merkle root for the whitelist.
     */
    function setWhitelistRoot(bytes32 _root) public onlyAdmin {
        rootWhitelist = _root;

        emit WhitelistRootChanged(_root);
    }

    // Getter functions provide external visibility into the contract's state without modifying it.

    /**
     * @notice Returns the address of the Kondux NFT contract.
     * @return The current address interfaced by this contract for Kondux NFT operations.
     */
    function getKNFT() public view returns (address) {
        return address(kNFT);
    }

    /**
     * @notice Returns the address of the kBox NFT contract.
     * @return The current address interfaced by this contract for kBox NFT operations.
     */
    function getKBox() public view returns (address) {
        return address(kBox);
    }

    /**
     * @notice Returns the address of the treasury contract.
     * @return The current treasury contract address for financial transactions related to minting.
     */
    function getTreasury() public view returns (address) {
        return address(treasury);
    }

    // Internal functions are utilized by public functions to perform core operations in a secure and encapsulated manner.

    /**
     * @dev Mints a specified number of NFTs to the sender's address. Each NFT minted is part of the bundle and is assigned a consecutive token ID.
     * @param _bundleSize The number of NFTs to mint in the bundle.
     * @return tokenIds An array of the minted NFT token IDs.
     */
    function _mintBundle(uint16 _bundleSize) internal returns (uint256[] memory) {
        uint256[] memory tokenIds = new uint256[](_bundleSize);
        for (uint16 i = 0; i < _bundleSize; i++) {
            tokenIds[i] = kNFT.safeMint(msg.sender, 0); // The second parameter could be a metadata identifier or similar.
        }
        return tokenIds;
    }

    // Modifiers enhance function behaviors with pre-conditions, making the contract's logic more modular, readable, and secure.

    /**
     * @dev Ensures a function is only callable when the contract is not paused.
     * @notice Requires the contract to not be paused for the function to execute.
     */
    modifier isActive() {
        require(!paused, "Contract is paused");
        _;
    }

    /**
     * @dev Ensures a function is only callable when kNFT minting is active.
     * @notice Requires the kNFT minting to be active for the function to execute.
     */
    modifier isPublicMintActive() {
        require(kNFTActive || (foundersPassActive && foundersPass.balanceOf(msg.sender) > 0), "kNFT minting is not active or you don't have a Founder's Pass");
        _;
    }

    /**
     * @dev Ensures a function is only callable when kBox minting is active.
     * @notice Requires the kBox minting to be active for the function to execute.
     */
    modifier isKBoxMintActive() {
        require(kBoxActive, "kBox minting is not active");
        _;
    }

    /**
     * @dev Ensures a function is only callable when founders pass minting is active.
     * @notice Requires the founders pass minting to be active for the function to execute.
     */
    modifier isFoundersPassMintActive() {
        require(foundersPassActive, "Founder's Pass minting is not active");
        _;
    }

    /**
     * @dev Ensures a function is only callable when the whitelist is active.
     * @notice Requires the whitelist to be active for the function to execute.
     */
    modifier isWhitelistActive() {
        require(whitelistActive, "Whitelist is not active");
        _;
    }

    /**
     * @dev Restricts a function's access to users with the admin role.
     * @notice Only callable by users with the admin role.
     */
    modifier onlyAdmin() {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not an admin");
        _;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "./interfaces/IKonduxFounders.sol";
import "./interfaces/ITreasury.sol";
import "./interfaces/IKondux.sol";
import "./types/AccessControlled.sol";

import "hardhat/console.sol";

contract MinterFounders is AccessControlled {

    uint256 public priceFounders020;
    uint256 public priceFounders025;
    uint256 public priceFreeKNFT;
    uint256 public priceFreeFounders;

    bytes32 public rootFreeFounders;
    bytes32 public rootFounders020;
    bytes32 public rootFounders025;
    bytes32 public rootFreeKNFT;

    bool public pausedWhitelist;
    bool public pausedFounders020;
    bool public pausedFounders025;
    bool public pausedFreeFounders;
    bool public pausedFreeKNFT;

    IKondux public kondux;
    IKonduxFounders public konduxFounders;
    ITreasury public treasury;

    mapping (address => bool) public founders020Claimed;
    mapping (address => bool) public founders025Claimed;
    mapping (address => bool) public freeFoundersClaimed;
    mapping (address => bool) public freeKNFTClaimed;


    constructor(address _authority, address _konduxFounders, address _kondux, address _vault) 
        AccessControlled(IAuthority(_authority)) {        
            require(_konduxFounders != address(0), "Kondux address is not set");
            konduxFounders = IKonduxFounders(_konduxFounders);
            require(_kondux != address(0), "Kondux address is not set");
            kondux = IKondux(_kondux);
            require(_vault != address(0), "Vault address is not set");
            treasury = ITreasury(_vault);

            pausedFounders020 = false;
            pausedFounders025 = false;
            pausedFreeFounders = false;
            pausedFreeKNFT = false;
    }      

    function setPriceFounders020(uint256 _price) public onlyGovernor {
        priceFounders020 = _price;
    }

    function setPriceFounders025(uint256 _price) public onlyGovernor {
        priceFounders025 = _price;
    }

    function setPriceFreeFounders(uint256 _price) public onlyGovernor {
        priceFreeKNFT = _price;
    }

    function setPriceFreeKNFT(uint256 _price) public onlyGovernor {
        priceFreeKNFT = _price;
    }

    function setPausedFounders020(bool _paused) public onlyGovernor {
        pausedFounders020 = _paused;
    }

    function setPausedFounders025(bool _paused) public onlyGovernor {
        pausedFounders025 = _paused;
    }

    function setPausedFreeFounders(bool _paused) public onlyGovernor {
        pausedFreeFounders = _paused;
    }

    function setPausedFreeKNFT(bool _paused) public onlyGovernor {
        pausedFreeKNFT = _paused;
    }

    function whitelistMintFounders020(bytes32[] calldata _merkleProof) public payable isFounders020Active returns (uint256) {
        require(msg.value >= priceFounders020, "Not enought ether");
        require(!founders020Claimed[msg.sender], "Already claimed");
        treasury.depositEther{ value: msg.value }();
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));        
        require(MerkleProof.verify(_merkleProof, rootFounders020, leaf), "Incorrect proof");
        founders020Claimed[msg.sender] = true;
        return _mintFounders();
    }

    function whitelistMintFounders025(bytes32[] calldata _merkleProof) public payable isFounders025Active returns (uint256) {
        require(msg.value >= priceFounders025, "Not enought ether");
        require(!founders025Claimed[msg.sender], "Already claimed");
        treasury.depositEther{ value: msg.value }();
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(_merkleProof, rootFounders025, leaf), "Incorrect proof");
        founders025Claimed[msg.sender] = true;
        return _mintFounders();
    }

    function whitelistMintFreeKNFT(bytes32[] calldata _merkleProof) public isFreeKNFTActive returns (uint256) {
        require(!freeKNFTClaimed[msg.sender], "Already claimed");
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(_merkleProof, rootFreeKNFT, leaf), "Incorrect proof");
        freeKNFTClaimed[msg.sender] = true;
        return _mintKNFT();
    }

    function whitelistMintFreeFounders(bytes32[] calldata _merkleProof) public isFreeFoundersActive returns (uint256) {
        require(!freeFoundersClaimed[msg.sender], "Already claimed");
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(_merkleProof, rootFreeFounders, leaf), "Incorrect proof");
        freeFoundersClaimed[msg.sender] = true;
        return _mintFounders();
    }

    function setRootFreeFounders(bytes32 _rootFreeFounders) public onlyGovernor {
        rootFreeFounders = _rootFreeFounders;
    }

    function setRootFounders020(bytes32 _rootFounders020) public onlyGovernor {
        console.logBytes32(_rootFounders020);
        rootFounders020 = _rootFounders020;
    }

    function setRootFounders025(bytes32 _rootFounders025) public onlyGovernor {
        rootFounders025 = _rootFounders025;
    }

    function setRootFreeKNFT(bytes32 _rootFreeKNFT) public onlyGovernor {
        rootFreeKNFT = _rootFreeKNFT;
    }

    function setTreasury(address _treasury) public onlyGovernor {
        treasury = ITreasury(_treasury);
    }

    function setKonduxFounders(address _konduxFounders) public onlyGovernor {
        konduxFounders = IKonduxFounders(_konduxFounders);
    }

    // TODO: REMOVE BEFORE DEPLOY TO MAINNET
    // function unclaimAddress(address _address) public {
    //     founders020Claimed[_address] = false;
    //     founders025Claimed[_address] = false;
    //     freeFoundersClaimed[_address] = false;
    //     freeKNFTClaimed[_address] = false;
    // }

    


    // ** INTERNAL FUNCTIONS **

    function _mintFounders() internal returns (uint256) {
        uint256 id = konduxFounders.safeMint(msg.sender);
        return id;
    }

    function _mintKNFT() internal returns (uint256) {
        uint256 id = kondux.safeMint(msg.sender, 0);
        return id;
    }

    // ** MODIFIERS **


    modifier isFounders020Active() {
        require(!pausedFounders020, "Founders 020 minting is paused");
        _;
    }

    modifier isFounders025Active() {
        require(!pausedFounders025, "Founders 025 minting is paused");
        _;
    }

    modifier isFreeFoundersActive() {
        require(!pausedFreeFounders, "Free Founders minting is paused");
        _;
    }

    modifier isFreeKNFTActive() {
        require(!pausedFreeKNFT, "Free KNFT minting is paused");
        _;
    }

}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "./interfaces/ITreasury.sol";
import "./interfaces/IHelix.sol";
import "./interfaces/IKondux.sol";
import "./interfaces/IKonduxERC20.sol";
import "./types/AccessControlled.sol";

contract Staking is AccessControlled {

    uint256 private _depositIds;

    /**
     * @dev Struct representing a staker's information.
     */
    struct Staker {
        // The address of the staked token
        address token;
        // The address of the staker
        address staker;
        // The total amount of tokens deposited by the staker
        uint256 deposited;
        // The total amount of tokens redeemed by the staker
        uint256 redeemed;
        // The timestamp of the last update for this staker's deposit
        uint256 timeOfLastUpdate;
        // The timestamp of the staker's last deposit
        uint256 lastDepositTime;
        // The accumulated, but unclaimed rewards for the staker. These are calculated
        // each time a user writes to the contract
        uint256 unclaimedRewards;
        // The duration of the timelock applied to the staker's deposit
        uint256 timelock;
        // The category of the timelock applied to the staker's deposit
        uint8 timelockCategory;
        // ERC20 Ratio at the time of staking
        uint256 ratioERC20;
    } 

    enum LockingTimes {        
        OneMonth, // 0
        ThreeMonths, // 1
        SixMonths, // 2
        OneYear // 3
    }

    // The deposit IDs associated with a user's address
    mapping(address => uint[]) public userDepositsIds;

    // The Staker struct information associated with a deposit ID
    mapping(uint => Staker) public userDeposits;

    // Indicates whether a specific ERC20 token is authorized for staking
    mapping (address => bool) public authorizedERC20;

    // The minimum amount required to stake for a specific ERC20 token
    mapping (address => uint256) public minStakeERC20;

    // The compound frequency for a specific ERC20 token
    mapping (address => uint256) public compoundFreqERC20;

    // The rewards per hour for a specific ERC20 token
    mapping (address => uint256) public aprERC20;

    // The withdrawal fee for a specific ERC20 token
    mapping (address => uint256) public withdrawalFeeERC20;

    // The founders reward boost for a specific ERC20 token
    mapping (address => uint256) public foundersRewardBoostERC20;

    // The kNFT reward boost for a specific ERC20 token
    mapping (address => uint256) public kNFTRewardBoostERC20;

    // The ratio for a specific ERC20 token
    mapping (address => uint256) public ratioERC20;

    // The decimals of a specific ERC20 token
    mapping (address => uint8) public decimalsERC20;

    // The total amount staked for a specific ERC20 token
    mapping (address => uint256) public totalStaked;

    // The total amount staked by a user for a specific ERC20 token
    mapping (address => mapping (address => uint256)) public userTotalStakedByCoin;

    // The total amount rewarded for a specific ERC20 token
    mapping (address => uint256) public totalRewarded;

    // The total amount rewarded by a user for a specific ERC20 token
    mapping (address => mapping (address => uint256)) public userTotalRewardedByCoin;

    // The total amount paid as a withdrawal fee for a specific ERC20 token
    mapping (address => uint256) public totalWithdrawalFees;

    // The penalty for withdrawing early for a specific ERC20 token
    mapping (address => uint256) public earlyWithdrawalPenalty;

    // The boost for a specific timelock category
    mapping(uint => uint256) public timelockCategoryBoost;

    // The divisor for a specific token
    mapping (address => uint256) public divisorERC20;

    // The allowed dnaVersion for reward boost
    mapping (uint256 => bool) public allowedDnaVersions;

    // Map of timelock durartions
    mapping(uint8 => uint256) public timelockDurations;

    IHelix public helixERC20; // Helix ERC20 Token
    IERC721 public konduxERC721Founders; // Kondux ERC721 Founders Token
    address public konduxERC721kNFT; // Kondux ERC721 kNFT Token
    ITreasury public treasury; // Treasury Contract

    // Events
    // Emitted when a staker withdraws their rewards
    event Withdraw(address indexed user, uint256 liquidAmount, uint256 fees);

    // Emitted when a staker withdraws all their rewards
    event WithdrawAll(address indexed staker, uint256 amount);

    // Emitted when a staker compounds their rewards
    event Compound(address indexed staker, uint256 amount);

    // Emitted when a staker stakes their tokens
    event Stake(uint indexed id, address indexed staker, address token, uint256 amount);

    // Emitted when a staker unstakes their tokens
    event Unstake(address indexed staker, uint256 amount);

    // Emitted when a staker receives a reward
    event Reward(address indexed user, uint256 netRewards, uint256 fees);

    // Emitted when the rewards per hour is updated for a token
    event NewAPR(uint256 indexed amount, address indexed token);

    // Emitted when the minimum stake is updated for a token
    event NewMinStake(uint256 indexed amount, address indexed token);

    // Emitted when the compound frequency is updated for a token
    event NewCompoundFreq(uint256 indexed amount, address indexed token);

    // Emitted when the Helix ERC20 token is updated
    event NewHelixERC20(address indexed helixERC20);

    // Emitted when the Kondux ERC721 Founders token is updated
    event NewKonduxERC721Founders(address indexed konduxERC721Founders);

    // Emitted when the Kondux ERC721 kNFT token is updated
    event NewKonduxERC721kNFT(address indexed konduxERC721kNFT);

    // Emitted when the treasury address is updated
    event NewTreasury(address indexed treasury);

    // Emitted when the withdrawal fee is updated for a token
    event NewWithdrawalFee(uint256 indexed amount, address indexed token);

    // Emitted when the founders reward boost is updated for a token
    event NewFoundersRewardBoost(uint256 indexed amount, address indexed token);

    // Emitted when the kNFT reward boost is updated for a token
    event NewKNFTRewardBoost(uint256 indexed amount, address indexed token);

    // Emitted when a token is authorized or deauthorized for staking
    event NewAuthorizedERC20(address indexed token, bool indexed authorized);

    // Emitted when the ratio is updated for a token
    event NewRatio(uint256 indexed amount, address indexed token);

    // Emitted when a new divisor is set for a token
    event NewDivisorERC20(uint256 indexed amount, address indexed token);
 

    /**
     * @dev Initializes the staking contract with the provided parameters.
     *
     * @param _authority The address of the authority contract.
     * @param _konduxERC20 The address of the Kondux ERC20 token contract.
     * @param _treasury The address of the treasury contract.
     * @param _konduxERC721Founders The address of the Kondux ERC721 Founders token contract.
     * @param _konduxERC721kNFT The address of the Kondux ERC721 kNFT token contract.
     * @param _helixERC20 The address of the Helix ERC20 token contract.
     *
     * The constructor sets up the initial state of the staking contract by initializing contract variables,
     * setting up default staking token parameters, and authorizing the Kondux ERC20 token for staking.
     */
    constructor(
        address _authority,
        address _konduxERC20,
        address _treasury,
        address _konduxERC721Founders,
        address _konduxERC721kNFT,
        address _helixERC20
    ) AccessControlled(IAuthority(_authority)) {
        // Ensure the provided addresses are valid
        require(_konduxERC20 != address(0), "Kondux ERC20 address is not set");
        require(_treasury != address(0), "Treasury address is not set");
        require(_konduxERC721Founders != address(0), "Kondux ERC721 Founders address is not set");
        require(_konduxERC721kNFT != address(0), "Kondux ERC721 kNFT address is not set");
        require(_helixERC20 != address(0), "Helix ERC20 address is not set");

        // Initialize contract variables
        konduxERC721Founders = IERC721(_konduxERC721Founders);
        konduxERC721kNFT = _konduxERC721kNFT;
        helixERC20 = IHelix(_helixERC20);
        treasury = ITreasury(_treasury);

        timelockDurations[0] = 30 days;         // 1 month
        timelockDurations[1] = 90 days;         // 3 months
        timelockDurations[2] = 180 days;        // 6 months
        timelockDurations[3] = 365 days;        // 1 year

        // Set up default staking token parameters
        setDivisorERC20(10_000, _konduxERC20); // 10,000 basis points
        setWithdrawalFee(100, _konduxERC20); // 1% fee on withdrawal or 100 / 10_000
        setFoundersRewardBoost(1_000, _konduxERC20); // 10% boost (=110%) on rewards or 1,000,000/10,000,000
        setkNFTRewardBoost(500, _konduxERC20); // 5% boost on rewards or 500 / 
        setMinStake(10_000_000, _konduxERC20); // 10,000,000 wei
        setAPR(25, _konduxERC20); // 0.00285%/h or 25% APR
        setCompoundFreq(60 * 60 * 24, _konduxERC20); // 24 hours
        setRatio(10_000, _konduxERC20); // 10,000:1 ratio, adjusted for kondux ERC20 decimals
        setEarlyWithdrawalPenalty(_konduxERC20, 10); // 10% penalty
        setTimelockCategoryBoost(1, 100); // 1% boost for 90 days timelock
        setTimelockCategoryBoost(2, 300); // 3% boost for 180 days timelock 
        setTimelockCategoryBoost(3, 900); // 9% boost for 365 days timelock
        setAllowedDnaVersion(1, true); // allow DNA version 1
        setDecimalsERC20(helixERC20.decimals(), _helixERC20); // set decimals for Helix ERC20 token 
        setDecimalsERC20(IKonduxERC20(_konduxERC20).decimals(), _konduxERC20); // set decimals for Kondux ERC20 token

        _setAuthorizedERC20(_konduxERC20, true);
    }

    /**
     * @dev This function allows a user to deposit a specified amount of an authorized token with a selected timelock period.
     *      The function checks the user's token balance, allowance, and the timelock value before proceeding.
     *      It then creates a new deposit record, sets the timelock based on the selected category, and updates the user's
     *      deposit list and total staked amount. The specified amount of tokens is transferred from the user to the vault,
     *      and an equivalent amount of reward tokens is minted for the user.
     * @param _amount The amount of tokens to deposit.
     * @param _timelock The timelock category, represented as an integer (0-4).
     * @param _token The address of the token contract.
     * @return _id The deposit ID assigned to this deposit.
     */
    function deposit(uint256 _amount, uint8 _timelock, address _token) public returns (uint) {
        // Check if the token address is set
        require(_token != address(0), "Token address is not set");
        // Check if the token is authorized for staking
        require(authorizedERC20[_token], "Token not authorized");
        // Check if the deposit amount is greater than or equal to the minimum required stake
        require(_amount >= minStakeERC20[_token], "Amount smaller than minimimum deposit");
        IERC20 konduxERC20 = IERC20(_token);
        // Check if the user has enough balance to stake the specified amount
        require(konduxERC20.balanceOf(msg.sender) >= _amount, "Can't stake more than you own");
        // Check if the user has approved the staking contract to spend the specified amount
        require(konduxERC20.allowance(msg.sender, address(this)) >= _amount, "Allowance not set");
        // Check if the selected timelock category is valid (between 0 and 3)
        require(_timelock <= 3, "Invalid timelock");

        // Get the current deposit ID
        uint _id = _depositIds;

        // Create a new deposit record for the user
        userDeposits[_id] = Staker({
            token: _token,
            staker: msg.sender,
            deposited: _amount,
            unclaimedRewards: 0,
            timelock: block.timestamp + timelockDurations[_timelock], // Set the timelock period based on the selected category
            timelockCategory: _timelock,
            timeOfLastUpdate: block.timestamp,
            lastDepositTime: block.timestamp,
            redeemed: 0,
            ratioERC20: ratioERC20[_token]
        });

        // Add the deposit ID to the user's deposit list
        userDepositsIds[msg.sender].push(_id);

        // Update the user's total staked amount
        _addTotalStakedAmount(_amount, _token, msg.sender);
        
        // Mint an equivalent amount of reward tokens for the user
        // Get the decimals of the original staked token and Helix
        uint8 originalTokenDecimals = decimalsERC20[_token];
        uint8 helixDecimals = decimalsERC20[address(helixERC20)];

        // Calculate the decimal difference
        uint decimalDifference;
        if (helixDecimals > originalTokenDecimals) {
            decimalDifference = helixDecimals - originalTokenDecimals;
        } else {
            decimalDifference = 0;
        }

        // Transfer the deposited tokens from the user to the vault
        konduxERC20.transferFrom(msg.sender, authority.vault(), _amount);

        // Mint an equivalent amount of reward tokens for the user, adjusted based on the decimal difference
        helixERC20.mint(msg.sender, _amount * ratioERC20[_token] * (10 ** decimalDifference));

        // Increment the deposit ID counter
        _depositIds++;

        // Emit a Stake event
        emit Stake(_id, msg.sender, _token, _amount);

        return _id;
    }

    /**
     * @dev This function allows the owner of a deposit to stake their earned rewards.
     *      It verifies that the caller is the deposit owner and that the compounding is not happening too soon.
     *      The function calculates the rewards, resets the unclaimed rewards to zero, and updates the deposit record.
     *      The total staked amount is updated, and an equivalent amount of reward tokens is minted for the user.
     * @param _depositId The ID of the deposit whose rewards are to be staked.
     */
    function stakeRewards(uint _depositId) public {
        // Verify that the caller is the owner of the deposit
        require(msg.sender == userDeposits[_depositId].staker, "You are not the owner of this deposit");
        // Verify that the user is not trying to compound rewards too soon
        // require(compoundRewardsTimer(_depositId) == 0, "Tried to compound rewards too soon");

        // Calculate the rewards and add any unclaimed rewards
        uint256 rewards = calculateRewards(msg.sender, _depositId) + userDeposits[_depositId].unclaimedRewards;

        // Check if the rewards are non-zero
        require(rewards > 0, "No rewards available");

        // Reset the unclaimed rewards to zero
        userDeposits[_depositId].unclaimedRewards = 0;
        // Update the deposited amount with the compounded rewards
        userDeposits[_depositId].deposited += rewards;
        // Update the time of the last update
        userDeposits[_depositId].timeOfLastUpdate = block.timestamp;

        // Update the user's total staked amount
        _addTotalStakedAmount(rewards, userDeposits[_depositId].token, userDeposits[_depositId].staker);

        // Mint an equivalent amount of reward tokens for the user
        // Get the decimals of the original staked token and Helix
        uint8 originalTokenDecimals = decimalsERC20[userDeposits[_depositId].token];
        uint8 helixDecimals = decimalsERC20[address(helixERC20)];

        // Calculate the decimal difference
        uint decimalDifference;
        if (helixDecimals > originalTokenDecimals) {
            decimalDifference = helixDecimals - originalTokenDecimals;
        } else {
            decimalDifference = 0;
        }

        // Mint the calculated rewards for the user, adjusted based on the decimal difference
        helixERC20.mint(msg.sender, rewards * userDeposits[_depositId].ratioERC20 * (10 ** decimalDifference));

        // Emit a Compound event
        emit Compound(msg.sender, rewards);
    }

    /**
     * @dev This function allows the owner of a deposit to claim their earned rewards.
     *      It verifies that the caller is the deposit owner and that the timelock has passed.
     *      The function calculates the rewards, resets the unclaimed rewards to zero, and updates the deposit record.
     *      The reward tokens are burned, and the earned rewards are transferred to the user from the vault.
     *      The function emits a Reward event upon successful execution.
     * @param _depositId The ID of the deposit whose rewards are to be claimed.
     */
    function claimRewards(uint _depositId) public {
        require(msg.sender == userDeposits[_depositId].staker, "You are not the owner of this deposit");
        require(block.timestamp >= userDeposits[_depositId].timelock, "Timelock not passed");

        uint256 rewards = calculateRewards(msg.sender, _depositId) + userDeposits[_depositId].unclaimedRewards;

        require(rewards > 0, "You have no rewards");

        userDeposits[_depositId].unclaimedRewards = 0;
        userDeposits[_depositId].timeOfLastUpdate = block.timestamp;

        IERC20 konduxERC20 = IERC20(userDeposits[_depositId].token);

        uint256 netRewards = (rewards * (10_000 - withdrawalFeeERC20[userDeposits[_depositId].token])) / divisorERC20[userDeposits[_depositId].token];
        uint256 fees = rewards - netRewards;

        konduxERC20.transferFrom(authority.vault(), msg.sender, netRewards); 

        _addTotalRewardedAmount(netRewards, userDeposits[_depositId].token, userDeposits[_depositId].staker);
        _addTotalWithdrawalFees(rewards - netRewards, userDeposits[_depositId].token);

        emit Reward(msg.sender, netRewards, fees);
    }

    /**
     * @dev This function allows the owner of a deposit to withdraw a specified amount of their deposited tokens.
     *      It verifies that the timelock has passed, the caller is the deposit owner, and the withdrawal amount
     *      is within the available limits. The function calculates the rewards, updates the deposit record, and
     *      transfers the liquid amount to the user after applying the withdrawal fee. The collateral tokens are burned.
     *      The function emits a Withdraw event upon successful execution.
     * @param _amount The amount of tokens to withdraw.
     * @param _depositId The ID of the deposit from which to withdraw the tokens.
     */
    function withdraw(uint256 _amount, uint _depositId) public {
        // Verify that the timelock has passed
        require(block.timestamp >= userDeposits[_depositId].timelock, "Timelock not passed");
        // Verify that the caller is the owner of the deposit
        require(msg.sender == userDeposits[_depositId].staker, "You are not the owner of this deposit");
        // Verify that the withdrawal amount is within the available limits
        require(userDeposits[_depositId].deposited >= _amount, "Can't withdraw more than you have");
        // Verify that the withdrawal amount is less than or equal to the collateral tokens the user has
        require(_amount * userDeposits[_depositId].ratioERC20 <= helixERC20.balanceOf(msg.sender), "Can't withdraw more tokens than the collateral you have");

        // Calculate the rewards
        uint256 _rewards = calculateRewards(msg.sender, _depositId);
        // Update the deposit record
        userDeposits[_depositId].deposited -= _amount;
        userDeposits[_depositId].timeOfLastUpdate = block.timestamp;
        userDeposits[_depositId].unclaimedRewards += _rewards;

        // Calculate the liquid amount to transfer after applying the withdrawal fee
        uint256 _liquid = (_amount * (divisorERC20[userDeposits[_depositId].token] - withdrawalFeeERC20[userDeposits[_depositId].token])) / divisorERC20[userDeposits[_depositId].token];
        uint256 fees = _amount - _liquid;

        // Get the token contract
        IERC20 konduxERC20 = IERC20(userDeposits[_depositId].token);

        // Check if the treasury contract has approved the staking contract to withdraw the tokens
        require(konduxERC20.allowance(authority.vault(), address(this)) >= _liquid, "Treasury Contract need to approve Staking Contract to withdraw your tokens -- please call an Admin");

        // Subtract the staked amount
        _subtractStakedAmount(_amount, userDeposits[_depositId].token, userDeposits[_depositId].staker);

        // Get the decimals of the original staked token and Helix
        uint8 originalTokenDecimals = decimalsERC20[userDeposits[_depositId].token];
        uint8 helixDecimals = decimalsERC20[address(helixERC20)];

        // Calculate the decimal difference
        uint decimalDifference;
        if (originalTokenDecimals < helixDecimals) {
            decimalDifference = helixDecimals - originalTokenDecimals;
        } else {
            decimalDifference = 0;
        }

        // Burn the equivalent amount of collateral tokens, adjusted based on the decimal difference
        helixERC20.burn(msg.sender, _amount * userDeposits[_depositId].ratioERC20 * (10 ** decimalDifference));

        
        // Transfer the liquid amount to the user
        konduxERC20.transferFrom(authority.vault(), msg.sender, _liquid);

        // Update the user's total rewarded amount + total rewarded amount for the token
        _addTotalRewardedAmount(_liquid, userDeposits[_depositId].token, userDeposits[_depositId].staker); 
        _addTotalWithdrawalFees(_amount - _liquid, userDeposits[_depositId].token); 

        // Emit a Withdraw event
        emit Withdraw(msg.sender, _liquid, fees);
    }

    /**
     * @dev This function allows the owner of a deposit to withdraw a specified amount of their deposited tokens
     *      before the timelock has passed. The user is punished by not receiving any reward boosts and paying an extra
     *      fee proportional to the time left until the lock (the closer to the end of the locking time, the smaller the fee,
     *      starting at 10%).
     *      It verifies that the caller is the deposit owner, and the withdrawal amount is within the available limits.
     *      The function calculates the rewards, updates the deposit record, and transfers the liquid amount to the user
     *      after applying the extra fee and withdrawal fee. The collateral tokens are burned.
     *      The function emits a Withdraw event upon successful execution.
     * @param _amount The amount of tokens to withdraw.
     * @param _depositId The ID of the deposit from which to withdraw the tokens.
     */
    function earlyUnstake(uint256 _amount, uint _depositId) public {
        // Verify that the caller is the owner of the deposit
        require(msg.sender == userDeposits[_depositId].staker, "You are not the owner of this deposit");
        // Verify that the withdrawal amount is within the available limits
        require(userDeposits[_depositId].deposited >= _amount, "Can't withdraw more than you have");
        // Verify that the withdrawal amount is less than or equal to the collateral tokens the user has
        require(_amount * userDeposits[_depositId].ratioERC20 <= helixERC20.balanceOf(msg.sender), "Can't withdraw more tokens than the collateral you have");
        // Verify if the timelock has passed
        require(block.timestamp < userDeposits[_depositId].timelock, "Timelock has passed");

        // Calculate the extra fee proportional to the time left until the lock (the closer to the end of the locking time, the smaller the fee)
        uint256 timeLeft = userDeposits[_depositId].timelock - block.timestamp;
        uint256 lockDuration = userDeposits[_depositId].timelock - userDeposits[_depositId].lastDepositTime;
        uint256 extraFee = (_amount * earlyWithdrawalPenalty[userDeposits[_depositId].token] * timeLeft) / (lockDuration * 100);

        // If extra fee is more than the amount, set it to the amount
        if (extraFee > _amount) {
            extraFee = _amount;
        }

        // If extra fee is zero, apply 1% fee
        if (extraFee == 0) {
            extraFee = (_amount * 1) / 100;
        }

        // Calculate the total fee percentage
        uint256 totalFeePercentage = extraFee + withdrawalFeeERC20[userDeposits[_depositId].token];

        // Calculate the liquid amount to transfer after applying the total fee
        uint256 _liquid = (_amount - totalFeePercentage);
        uint256 fees = _amount - _liquid;

        // Update the deposit record
        userDeposits[_depositId].deposited -= _amount;
        userDeposits[_depositId].timeOfLastUpdate = block.timestamp;

        // Get the token contract
        IERC20 konduxERC20 = IERC20(userDeposits[_depositId].token);

        // Check if the treasury contract has approved the staking contract to withdraw the tokens
        require(konduxERC20.allowance(authority.vault(), address(this)) >= _liquid, "Treasury Contract need to approve Staking Contract to withdraw your tokens -- please call an Admin");

        // Subtract the staked amount
        _subtractStakedAmount(_amount, userDeposits[_depositId].token, userDeposits[_depositId].staker);

        // Calculate the decimal difference
        uint decimalDifference;
        if (decimalsERC20[userDeposits[_depositId].token] < decimalsERC20[address(helixERC20)]) {
            decimalDifference = decimalsERC20[address(helixERC20)] - decimalsERC20[userDeposits[_depositId].token];
        } else {
            decimalDifference = 0;
        }

        // Burn the equivalent amount of collateral tokens, adjusted based on the decimal difference
        helixERC20.burn(msg.sender, _amount * userDeposits[_depositId].ratioERC20 * (10 ** decimalDifference));
        
        // Transfer the liquid amount to the user
        konduxERC20.transferFrom(authority.vault(), msg.sender, _liquid);

        // Update the user's total rewarded amount + total rewarded amount for the token
        _addTotalRewardedAmount(_liquid, userDeposits[_depositId].token, userDeposits[_depositId].staker); 
        _addTotalWithdrawalFees(_amount - _liquid, userDeposits[_depositId].token); 

        // Emit a Withdraw event
        emit Withdraw(msg.sender, _liquid, fees);
    }

    /**
     * @dev This function allows the owner of a deposit to withdraw a specified amount of their deposited tokens
     *      and claim their earned rewards in a single transaction. It calls the withdraw and claimRewards functions.
     * @param _amount The amount of tokens to withdraw.
     * @param _depositId The ID of the deposit from which to withdraw the tokens and claim the rewards.
     */
    function withdrawAndClaim(uint256 _amount, uint _depositId) public {
        withdraw(_amount, _depositId);
        claimRewards(_depositId);
    }

    /**
     * @dev This function returns the remaining time until the next allowed compounding action for a given deposit ID.
     *      It calculates the remaining time based on the compound frequency for the deposited token.
     *      If the timer has already passed, it returns 0.
     * @param _depositId The ID of the deposit for which to return the compound timer.
     * @return remainingTime The remaining time until the next allowed compounding action in seconds.
     */
    function compoundRewardsTimer(uint _depositId) public view returns (uint256 remainingTime) {
        uint256 lastUpdateTime = userDeposits[_depositId].timeOfLastUpdate;
        uint256 compoundFrequency = compoundFreqERC20[userDeposits[_depositId].token];

        if (block.timestamp >= lastUpdateTime + compoundFrequency) {
            return 0;
        }

        remainingTime = (lastUpdateTime + compoundFrequency) - block.timestamp;
        return remainingTime;
    }

    /**
     * @dev This function calculates the rewards for a specified staker and deposit ID. The rewards calculation
     *      considers the deposit's elapsed time, staked amount, and a 25% APY compounded hourly.
     *      If the provided staker is not the owner of the deposit, the function returns 0.
     * @param _staker The address of the staker for which to calculate the rewards.
     * @param _depositId The ID of the deposit for which to calculate the rewards.
     * @return rewards The calculated rewards for the specified staker and deposit ID.
     */
    function calculateRewards(address _staker, uint _depositId) public view returns (uint256 rewards) {
        // Retrieve deposit details by _depositId
        Staker memory deposit_ = userDeposits[_depositId];

        // Check if the staker is the owner of the deposit; if not, return 0
        if (deposit_.staker != _staker) {
            return 0;
        }

        // Calculate the elapsed time since the last update
        uint256 elapsedTime = block.timestamp - deposit_.timeOfLastUpdate;
        // Get the deposited amount
        uint256 depositedAmount = deposit_.deposited;

        // Calculate the base reward per second using the token's APR
        uint256 tokenApr = aprERC20[deposit_.token];

        /**
         * @dev This line calculates the reward earned per second by a staker for their deposit, considering the deposit's APR (annual percentage rate).
         *
         * The formula breakdown:
         * 1. depositedAmount: The amount of tokens the staker deposited.
         * 2. tokenApr: The annual percentage rate for the token in question (e.g. 25% APR).
         * 3. 1e18: A scaling factor used to maintain precision in the calculations (10^18 or 1 followed by 18 zeros).
         * 4. 365 * 24 * 3600: The total number of seconds in a year, used to convert the APR to a per-second rate.
         * 5. 100: Used to convert the APR percentage to a decimal (e.g. 25% becomes 0.25).
         *
         * The formula calculates the per-second reward by multiplying the deposited amount and the token's APR, and then scaling it up by 1e18.
         * After that, it divides the result by the total number of seconds in a year and by 100 to adjust for the percentage.
         *
         * Using 1e18 maintains precision in the calculation, avoiding truncation errors due to integer division in Solidity.
         * By scaling up the result and performing the divisions afterward, the calculation maintains precision without truncating intermediate results to zero.
         */
        uint256 rewardPerSecond = (depositedAmount * tokenApr * 1e18) / (365 * 24 * 3600 * 100);
        
        // Calculate the base reward based on elapsed time
        uint256 _reward = elapsedTime * rewardPerSecond / 1e18;

        // Calculate the boost percentage
        uint256 boostPercentage = calculateBoostPercentage(_staker, _depositId);

        // Calculate the final reward by applying the boost percentage
        _reward = (_reward * boostPercentage) / divisorERC20[deposit_.token];

        // Return the calculated reward
        return _reward;
    }      

    // Internal functions:

    /**
     * @dev This internal function calculates the compounded rewards for a given deposited amount and number of elapsed periods.
     *      The function assumes a fixed 25% APR and 8760 periods per year (hourly compounding). It uses exponentiation to calculate
     *      the compounded rewards using the formula A = P * (1 + r/n)^(nt), where:
     *          A: final amount after compounding
     *          P: initial deposited amount
     *          r: annual interest rate (25%)
     *          n: number of periods in a year (8760)
     *          t: number of elapsed periods
     * @param _depositedAmount The initial deposited amount.
     * @param _periodsElapsed The number of elapsed periods (hours) since the deposit.
     * @return compound The calculated compounded rewards for the given deposited amount and elapsed periods.
     */
    function _calculateCompound(uint256 _depositedAmount, uint256 _periodsElapsed) internal pure returns (uint256 compound) {
        uint256 periodsInYear = 8760; // 24 hours * 365 days
        uint256 compoundFactor = 1 + (25 * 1e1 / periodsInYear);

        //Calculate compounded rewards using exponentiation (A = P * (1 + r/n)^(nt))
        compound = _depositedAmount * (compoundFactor ** _periodsElapsed) / (1e1 ** _periodsElapsed);

        return compound;        
    }
        
        
    // Functions for modifying  staking mechanism variables:
    /**
     * @dev This internal function is used to update the total rewarded amount and the total rewarded amount
     *      for a specific user and token. It is called when rewards are distributed or staked.
     * @param _amount The amount of tokens to add to the total rewarded and user's total rewarded.
     * @param _token The address of the token contract.
     * @param _user The address of the user receiving the rewards.
     */
    function _addTotalRewardedAmount(uint256 _amount, address _token, address _user) internal {
        totalRewarded[_token] += _amount;
        userTotalRewardedByCoin[_token][_user] += _amount;
    }


    /**
     * @dev This internal function adds the given amount to the total staked amount for a specified token
     *      and increases the staked amount for the user by the same amount.
     * @param _amount The amount to add to the total staked amount and user's staked amount.
     * @param _token The address of the token for which to update the staked amount.
     * @param _user The address of the user whose staked amount should be increased.
     */
    function _addTotalStakedAmount(uint256 _amount, address _token, address _user) internal {
        totalStaked[_token] += _amount;
        userTotalStakedByCoin[_token][_user] += _amount;
    }

    /**
     * @dev This internal function subtracts the given amount from the total staked amount for a specified token
     *      and decreases the staked amount for the user by the same amount.
     * @param _amount The amount to subtract from the total staked amount and user's staked amount.
     * @param _token The address of the token for which to update the staked amount.
     * @param _user The address of the user whose staked amount should be decreased.
     */
    function _subtractStakedAmount(uint256 _amount,  address _token, address _user) internal {
        // do a underflow check
        require(totalStaked[_token] >= _amount, "Staking: Not enough staked (Contract)");
        require(userTotalStakedByCoin[_token][_user] >= _amount, "Staking: Not enough staked (User)");
        totalStaked[_token] -= _amount;
        userTotalStakedByCoin[_token][_user] -= _amount;
    }

    /**
     * @dev This internal function adds the given amount to the total withdrawal fees for a specified token.
     * @param _amount The amount to add to the total withdrawal fees.
     * @param _token The address of the token for which to update the withdrawal fees.
     */
    function _addTotalWithdrawalFees(uint256 _amount, address _token) internal {
        totalWithdrawalFees[_token] += _amount;
    }
    
    /**
     * @dev This function sets the APR for a specified token.
     * @param _apr The rewards per hour value to be set, as x% APR. (e.g. 25 = 25%)
     * @param _tokenId The address of the token for which to set the rewards per hour.
     */
    function setAPR(uint256 _apr, address _tokenId) public onlyGovernor {
        // Check if the token address is set
        require(_tokenId != address(0), "Token address is not set"); 
        aprERC20[_tokenId] = _apr; 
        emit NewAPR(_apr, _tokenId);
    }

    /**
     * @dev This function sets the minimum staking amount for a specified token.
     * @param _minStake The minimum staking amount to be set, in wei.
     * @param _tokenId The address of the token for which to set the minimum staking amount.
     */
    function setMinStake(uint256 _minStake, address _tokenId) public onlyGovernor {
        // Check if the token address is set
        require(_tokenId != address(0), "Token address is not set"); 
        minStakeERC20[_tokenId] = _minStake;
        emit NewMinStake(_minStake, _tokenId);
    }

    /**
     * @dev This function sets the ratio for a specified ERC20 token.
     * @param _ratio The ratio value to be set.
     * @param _tokenId The address of the token for which to set the ratio.
     */
    function setRatio(uint256 _ratio, address _tokenId) public onlyGovernor {
        // Check if the token address is set
        require(_tokenId != address(0), "Token address is not set"); 
        ratioERC20[_tokenId] = _ratio;
        emit NewRatio(_ratio, _tokenId);
    }

    /**
     * @dev This function sets the address of the Helix ERC20 contract.
     * @param _helix The address of the Helix ERC20 contract.
     */
    function setHelixERC20(address _helix) public onlyGovernor {
        require(_helix != address(0), "Helix address cannot be 0x0");
        helixERC20 = IHelix(_helix);
        emit NewHelixERC20(_helix);
    }

    /**
     * @dev This function sets the address of the konduxERC721Founders contract.
     * @param _konduxERC721Founders The address of the konduxERC721Founders contract.
     */
    function setKonduxERC721Founders(address _konduxERC721Founders) public onlyGovernor {
        require(_konduxERC721Founders != address(0), "Founders address cannot be 0x0");
        konduxERC721Founders = IERC721(_konduxERC721Founders);
        emit NewKonduxERC721Founders(_konduxERC721Founders);
    }

    /**
     * @dev This function sets the address of the konduxERC721kNFT contract.
     * @param _konduxERC721kNFT The address of the konduxERC721kNFT contract.
     */
    function setKonduxERC721kNFT(address _konduxERC721kNFT) public onlyGovernor {
        require(_konduxERC721kNFT != address(0), "kNFT address cannot be 0x0");
        konduxERC721kNFT = _konduxERC721kNFT;
        emit NewKonduxERC721kNFT(_konduxERC721kNFT);
    }

    /**
     * @dev This function sets the address of the Treasury contract.
     * @param _treasury The address of the Treasury contract.
     */
    function setTreasury(address _treasury) public onlyGovernor {
        require(_treasury != address(0), "Treasury address cannot be 0x0");
        treasury = ITreasury(_treasury);
        emit NewTreasury(_treasury);
    }

    /**
     * @dev This function sets the withdrawal fee for a specified token.
     * @param _withdrawalFee The withdrawal fee value to be set.
     * @param _tokenId The address of the token for which to set the withdrawal fee.
     */
    function setWithdrawalFee(uint256 _withdrawalFee, address _tokenId) public onlyGovernor {
        // Check if the token address is set
        require(_tokenId != address(0), "Token address is not set"); 
        require(_withdrawalFee <= divisorERC20[_tokenId], "Withdrawal fee cannot be more than 100%");
        withdrawalFeeERC20[_tokenId] = _withdrawalFee;
        emit NewWithdrawalFee(_withdrawalFee, _tokenId); 
    }

    /**
     * @dev This function sets the founders reward boost for a specified token.
     * @param _foundersRewardBoost The founders reward boost value to be set.
     * @param _tokenId The address of the token for which to set the founders reward boost.
     */
    function setFoundersRewardBoost(uint256 _foundersRewardBoost, address _tokenId) public onlyGovernor {
        // Check if the token address is set
        require(_tokenId != address(0), "Token address is not set"); 
        foundersRewardBoostERC20[_tokenId] = _foundersRewardBoost;
        emit NewFoundersRewardBoost(_foundersRewardBoost, _tokenId);
    }

    /**
     * @dev This function sets the kNFT reward boost for a specified token.
     * @param _kNFTRewardBoost The kNFT reward boost value to be set.
     * @param _tokenId The address of the token for which to set the kNFT reward boost.
     */
    function setkNFTRewardBoost(uint256 _kNFTRewardBoost, address _tokenId) public onlyGovernor {
        // Check if the token address is set
        require(_tokenId != address(0), "Token address is not set"); 
        kNFTRewardBoostERC20[_tokenId] = _kNFTRewardBoost;
        emit NewKNFTRewardBoost(_kNFTRewardBoost, _tokenId); 
    }

    /**
    * @dev This function sets the compound frequency for a specified token.
    * @param _compoundFreq The compound frequency value to be set.
    * @param _tokenId The address of the token for which to set the compound frequency.
    */
    function setCompoundFreq(uint256 _compoundFreq, address _tokenId) public onlyGovernor {
        // Check if the token address is set
        require(_tokenId != address(0), "Token address is not set"); 
        compoundFreqERC20[_tokenId] = _compoundFreq;
        emit NewCompoundFreq(_compoundFreq, _tokenId);
    }

    /**
     * @dev This function sets the penalty percentage for early withdrawal of a specified token.
     * @param _token The address of the token for which to set the penalty percentage.
     * @param penaltyPercentage The penalty percentage value to be set. Must be between 0 and 100. 
     */
    function setEarlyWithdrawalPenalty(address _token, uint256 penaltyPercentage) public onlyGovernor {
        // Check if the token address is set
        require(_token != address(0), "Token address is not set"); 
        require(penaltyPercentage <= 100, "Penalty percentage must be between 0 and 100");
        earlyWithdrawalPenalty[_token] = penaltyPercentage;
    }  

    /**
     * @dev This function sets the timelock category boost for a specified category.
     * @param _category The category for which to set the boost.
     * @param _boost The boost value to be set.
     */
    function setTimelockCategoryBoost(uint _category, uint256 _boost) public onlyGovernor {
        timelockCategoryBoost[_category] = _boost;
    }

    /**
     * @dev This function sets the divisor for a specified token.
     * @param _divisor The divisor value to be set.
     * @param _tokenId The address of the token for which to set the divisor.
     */
    function setDivisorERC20(uint256 _divisor, address _tokenId) public onlyGovernor {
        // Check if the token address is set
        require(_tokenId != address(0), "Token address is not set"); 
        divisorERC20[_tokenId] = _divisor;
        emit NewDivisorERC20(_divisor, _tokenId);
    }

    /**
     * @dev This internal function sets whether an ERC20 token is authorized as a staking currency.
     * Emits a {NewAuthorizedERC20} event.
     * @param _token The address of the token to be authorized or deauthorized.
     * @param _authorized True to authorize the token, false to deauthorize.
     */
    function _setAuthorizedERC20(address _token, bool _authorized) internal {
        require(_token != address(0), "Token address cannot be 0x0");
        if (_authorized == true) {
            require(aprERC20[_token] > 0, "Rewards per hour must be greater than 0");
            require(compoundFreqERC20[_token] > 0, "Compound frequency must be greater than 0");
            require(withdrawalFeeERC20[_token] > 0, "Withdrawal fee must be greater than 0");
            require(foundersRewardBoostERC20[_token] > 0, "Founders reward boost must be greater than 0");
            require(kNFTRewardBoostERC20[_token] > 0, "kNFT reward boost must be greater than 0");
            require(ratioERC20[_token] > 0, "Ratio must be greater than 0");
            require(minStakeERC20[_token] > 0, "Minimum stake must be greater than 0");
            require(divisorERC20[_token] > 0, "Divisor must be greater than 0");
            require(IERC20(_token).totalSupply() > 0, "Token total supply must be greater than 0");
        }
        authorizedERC20[_token] = _authorized;
        emit NewAuthorizedERC20(_token, _authorized);
    }

    /**
     * @dev This function sets whether an ERC20 token is authorized as a staking currency.
     * Emits a {NewAuthorizedERC20} event.
     * @param _token The address of the token to be authorized or deauthorized.
     * @param _authorized True to authorize the token, false to deauthorize.
     */
    function setAuthorizedERC20(address _token, bool _authorized) public onlyGovernor {
        // Check if the token address is set
        require(_token != address(0), "Token address is not set"); 
        _setAuthorizedERC20(_token, _authorized);
    }

    /**
     * @dev This function sets the version of dna that is allowed to be used for reward bonus
     * @param _dnaVersion The dna version to be set.
     * @param _allowed True to allow the dna version, false to disallow.
     */
    function setAllowedDnaVersion(uint256 _dnaVersion, bool _allowed) public onlyGovernor {
        allowedDnaVersions[_dnaVersion] = _allowed;
    }

    /**
     * @dev This function sets the decimals of a specified token.
     * @param _decimals The decimals value to be set.
     * @param _tokenId The address of the token for which to set the decimals.
     */
    function setDecimalsERC20(uint8 _decimals, address _tokenId) public onlyGovernor {
        // Check if the token address is set
        require(_tokenId != address(0), "Token address is not set"); 
        decimalsERC20[_tokenId] = _decimals;
    }

    /**
     * @dev This function adds a new staking token with its parameters.
     * Emits various events based on the setter functions called during token addition.
     * Emits a {NewAuthorizedERC20} event at the end.
     * @param _token The address of the new staking token.
     * @param _apr The rewards per hour for the new staking token.
     * @param _compoundFreq The compound frequency for the new staking token.
     * @param _withdrawalFee The withdrawal fee for the new staking token.
     * @param _foundersRewardBoost The founders reward boost for the new staking token.
     * @param _kNFTRewardBoost The kNFT reward boost for the new staking token.
     * @param _ratio The ratio for the new staking token.
     * @param _minStake The minimum stake for the new staking token.
     */ 
    function addNewStakingToken(address _token, uint256 _apr, uint256 _compoundFreq, uint256 _withdrawalFee, uint256 _foundersRewardBoost, uint256 _kNFTRewardBoost, uint256 _ratio, uint256 _minStake) public onlyGovernor {
        require(_token != address(0), "Token address cannot be 0x0");
        require(_apr > 0, "Rewards per hour must be greater than 0"); 
        require(_compoundFreq > 0, "Compound frequency must be greater than 0");
        require(_withdrawalFee > 0, "Withdrawal fee must be greater than 0");
        require(_foundersRewardBoost > 0, "Founders reward boost must be greater than 0");
        require(_kNFTRewardBoost > 0, "kNFT reward boost must be greater than 0");
        require(_ratio > 0, "Ratio must be greater than 0");
        require(_minStake > 0, "Minimum stake must be greater than 0");
        require(IERC20(_token).totalSupply() > 0, "Token total supply must be greater than 0");

        setDivisorERC20(10_000, _token);
        setFoundersRewardBoost(_foundersRewardBoost, _token);
        setkNFTRewardBoost(_kNFTRewardBoost, _token);
        setAPR(_apr, _token); 
        setRatio(_ratio, _token);
        setWithdrawalFee(_withdrawalFee, _token);
        setCompoundFreq(_compoundFreq, _token);
        setMinStake(_minStake, _token);
        setDecimalsERC20(IERC20Metadata(_token).decimals(), _token);

        _setAuthorizedERC20(_token, true); 
    }


    // Functions for getting staking mechanism variables:

    /**
     * @dev This function returns the time of the last update for the specified deposit ID.
     * @param _depositId The ID of the deposit for which the time of the last update is requested.
     * @return _timeOfLastUpdate The time of the last update for the specified deposit ID.
     */
    function getTimeOfLastUpdate(uint _depositId) public view returns (uint256 _timeOfLastUpdate) {
        return userDeposits[_depositId].timeOfLastUpdate;
    }

    /**
     * @dev This function returns the staked amount for the specified deposit ID.
     * @param _depositId The ID of the deposit for which the staked amount is requested.
     * @return _deposited The staked amount for the specified deposit ID.
     */
    function getStakedAmount(uint _depositId) public view returns (uint256 _deposited) {
        return userDeposits[_depositId].deposited;
    }

    /**
     * @dev This function returns the APR for the specified token.
     * @param _tokenId The address of the token for which the rewards per hour are requested.
     * @return _rewardsPerHour The rewards per hour for the specified token.
     */
    function getAPR(address _tokenId) public view returns (uint256 _rewardsPerHour) {
        return aprERC20[_tokenId];
    }

    /**
     * @dev This function returns the Founder's reward boost for the specified token.
     * @param _tokenId The address of the token for which the Founder's reward boost is requested.
     * @return _foundersRewardBoost The Founder's reward boost for the specified token.
     */
    function getFoundersRewardBoost(address _tokenId) public view returns (uint256 _foundersRewardBoost) {
        return foundersRewardBoostERC20[_tokenId];
    }

    /**
     * @dev This function returns the kNFT reward boost for the specified token.
     * @param _tokenId The address of the token for which the kNFT reward boost is requested.
     * @return _kNFTRewardBoost The kNFT reward boost for the specified token.
     */
    function getkNFTRewardBoost(address _tokenId) public view returns (uint256 _kNFTRewardBoost) {
        return kNFTRewardBoostERC20[_tokenId];
    }

    /**
     * @dev This function returns the minimum stake for the specified token.
     * @param _tokenId The address of the token for which the minimum stake is requested.
     * @return _minStake The minimum stake for the specified token.
     */
    function getMinStake(address _tokenId) public view returns (uint256 _minStake) {
        return minStakeERC20[_tokenId];
    }

    /**
     * @dev This function returns the timelock category for the specified deposit ID.
     * @param _depositId The ID of the deposit for which the timelock category is requested.
     * @return _timelockCategory The timelock category for the specified deposit ID.
     */
    function getTimelockCategory(uint _depositId) public view returns (uint8 _timelockCategory) {
        return userDeposits[_depositId].timelockCategory;
    }

    /**
     * @dev This function returns the timelock for the specified deposit ID.
     * @param _depositId The ID of the deposit for which the timelock is requested.
     * @return _timelock The timelock for the specified deposit ID.
     */
    function getTimelock(uint _depositId) public view returns (uint256 _timelock) {
        return userDeposits[_depositId].timelock;
    }

    /**
     * @dev This function returns the deposit IDs for the specified user.
     * @param _user The address of the user for which the deposit IDs are requested.
     * @return An array of deposit IDs for the specified user.
     */
    function getDepositIds(address _user) public view returns (uint256[] memory) {
        return userDepositsIds[_user];
    }

    /**
     * @dev This function returns the withdrawal fee for the specified token.
     * @param _tokenId The address of the token for which the withdrawal fee is requested.
     * @return _withdrawalFee The withdrawal fee for the specified token.
     */
    function getWithdrawalFee(address _tokenId) public view returns (uint256 _withdrawalFee) {
        return withdrawalFeeERC20[_tokenId]; 
    }

    /**
     * @dev This function returns the total amount staked for a specific token.
     * @param _token The address of the token contract.
     * @return _totalStaked The total amount staked for the given token.
     */
    function getTotalStaked(address _token) public view returns (uint256 _totalStaked) {
        return totalStaked[_token];
    }

    /**
     * @dev This function returns the total amount staked by a specific user for a specific token.
     * @param _user The address of the user.
     * @param _token The address of the token contract.
     * @return _totalStaked The total amount staked by the user for the given token.
     */
    function getUserTotalStakedByCoin(address _user, address _token) public view returns (uint256 _totalStaked) {
        return userTotalStakedByCoin[_token][_user];
    }

    /**
     * @dev This function returns the total rewards earned for a specific token.
     * @param _token The address of the token contract.
     * @return _totalRewards The total rewards earned for the given token.
     */
    function getTotalRewards(address _token) public view returns (uint256 _totalRewards) {
        return totalRewarded[_token];
    }

    /**
     * @dev This function returns the total rewards earned by a specific user for a specific token.
     * @param _user The address of the user.
     * @param _token The address of the token contract.
     * @return _totalRewards The total rewards earned by the user for the given token.
     */
    function getUserTotalRewardsByCoin(address _user, address _token) public view returns (uint256 _totalRewards) {
        return userTotalRewardedByCoin[_token][_user]; 
    }

    /**
     * @dev This function returns the total withdrawal fees for a specific token.
     * @param _token The address of the token contract.
     * @return _totalWithdrawalFees The total withdrawal fees for the given token.
     */
    function getTotalWithdrawalFees(address _token) public view returns (uint256 _totalWithdrawalFees) {
        return totalWithdrawalFees[_token];
    }

    /**
     * @dev This function returns the timestamp of the deposit with the specified ID.
     * @param _depositId The id of the deposit for which the timestamp is requested.
     * @return _depositTimestamp The timestamp of the deposit
     */
    function getDepositTimestamp(uint _depositId) public view returns (uint256 _depositTimestamp) {
        return userDeposits[_depositId].lastDepositTime; 
    }

    /**
     * @dev This function returns the penalty for early withdrawal for the specified token in basis points. (X% = X * 100)
     * @param token The address of the token for which the penalty is requested.
     * @return The penalty for early withdrawal for the specified token in basis points.
     */
    function getEarlyWithdrawalPenalty(address token) public view returns (uint256) {
        return earlyWithdrawalPenalty[token];
    }

    /**
     * @dev This function returns the timelock category boost for the specified category.
     * @param _category The category for which the timelock category boost is requested.
     * @return The timelock category boost for the specified category.
     */
    function getTimelockCategoryBoost(uint _category) public view returns (uint256) {
        return timelockCategoryBoost[_category];
    }

    /**
     * @dev This function returns the divisor for the specified token.
     * @param _token The address of the token for which the divisor is requested.
     * @return The divisor for the specified token.
     */
    function getDivisorERC20(address _token) public view returns (uint256) {
        return divisorERC20[_token];
    }

    /**
     * @dev This function returns the permission of usage of a dna version as boost.
     * @param _dnaVersion The dna version for which the permission is requested.
     * @return The permission of usage of a dna version as boost
     */
    function getAllowedDnaVersion(uint256 _dnaVersion) public view returns (bool) {
        return allowedDnaVersions[_dnaVersion];
    }

    /**
     * @dev This function retrieves the deposit information for a given deposit ID. It returns the staked amount
     *      and the earned rewards (including unclaimed rewards) for the specified deposit.
     * @param _depositId The ID of the deposit for which to retrieve the information.
     * @return _stake The staked amount for the specified deposit.
     * @return _unclaimedRewards The earned rewards (including unclaimed rewards) for the specified deposit.
     */
    function getDepositInfo(uint _depositId) public view returns (uint256 _stake, uint256 _unclaimedRewards) {
        _stake = userDeposits[_depositId].deposited;  
        _unclaimedRewards = calculateRewards(msg.sender, _depositId) + userDeposits[_depositId].unclaimedRewards;
        return (_stake, _unclaimedRewards);  
    }

    /**
     * @dev This function returns the decimals for the specified token.
     * @param _token The address of the token for which the decimals are requested.
     * @return The decimals for the specified token.
     */
    function getDecimalsERC20(address _token) public view returns (uint8) {
        return decimalsERC20[_token];
    }

    /**
     * @dev This function returns the ratio for the specified token.
     * @param _token The address of the token for which the ratio is requested.
     * @return The ratio for the specified token.
     */
    function getRatioERC20(address _token) public view returns (uint256) {
        return ratioERC20[_token];
    }

    /**
     * @dev This function returns the ratio for the specified deposit.
     * @param _depositId The ID of the deposit for which to retrieve the information.
     * @return The ratio for the specified deposit.
     */
    function getDepositRatioERC20(uint256 _depositId) public view returns (uint256) {
        return userDeposits[_depositId].ratioERC20;
    }   

    /**
     * @dev This function returns the top 5 bonuses and their corresponding kNFT IDs.
     * @param _staker The address of the staker.
     * @param _stakeId The ID of the deposit for which to calculate the boost percentage.
     * @return top5Bonuses An array of the top 5 bonuses.
     * @return top5Ids An array of the corresponding kNFT IDs.
     */
    function getTop5BonusesAndIds(address _staker, uint256 _stakeId) public view returns (uint256[] memory top5Bonuses, uint256[] memory top5Ids) {
        uint256 kNFTBalance = IERC721(konduxERC721kNFT).balanceOf(_staker);

        // Initialize arrays to store the top 5 bonuses and their corresponding kNFT IDs
        top5Bonuses = new uint256[](5);
        top5Ids = new uint256[](5);

        // Iterate through the staker's kNFTs
        for (uint256 i = 0; i < kNFTBalance; i++) {
            uint256 tokenId = IERC721Enumerable(konduxERC721kNFT).tokenOfOwnerByIndex(_staker, i);

            // if the user's kNFT was received after the deposit date, continue
            if (IKondux(konduxERC721kNFT).getTransferDate(tokenId) > userDeposits[_stakeId].lastDepositTime) {
                continue;
            }

            // Get the kNFT's DNA version and check if it's allowed
            int256 dnaVersion = IKondux(konduxERC721kNFT).readGen(tokenId, 0, 1);
            if (!allowedDnaVersions[uint256(dnaVersion)]) { 
                continue;
            }

            // Get the kNFT's boost value and multiply it by 100 to get a percentage
            int256 dnaBoost = IKondux(konduxERC721kNFT).readGen(tokenId, 1, 2) * 100;

            // Clamp the boost value to 0 if it's negative
            if (dnaBoost < 0) {
                dnaBoost = 0;
            }

            // Update the top 5 bonuses array with the current kNFT boost
            for (uint256 j = 0; j < 5; j++) {
                if (uint256(dnaBoost) > top5Bonuses[j]) {
                    uint256 temp = top5Bonuses[j];
                    top5Bonuses[j] = uint256(dnaBoost);
                    dnaBoost = int256(temp);

                    uint256 tempId = top5Ids[j];
                    top5Ids[j] = tokenId;
                    tokenId = tempId;
                }
            }
        }

        return (top5Bonuses, top5Ids);
    }

    /**
     * @dev This function returns the top 5 bonuses and their corresponding kNFT IDs.
     * @param _staker The address of the staker.
     * @return top5Bonuses An array of the top 5 bonuses.
     * @return top5Ids An array of the corresponding kNFT IDs.
     */
    function getMaxTop5BonusesAndIds(address _staker) public view returns (uint256[] memory top5Bonuses, uint256[] memory top5Ids) {
        uint256 kNFTBalance = IERC721(konduxERC721kNFT).balanceOf(_staker);

        // Initialize arrays to store the top 5 bonuses and their corresponding kNFT IDs
        top5Bonuses = new uint256[](5);
        top5Ids = new uint256[](5);

        // Iterate through the staker's kNFTs
        for (uint256 i = 0; i < kNFTBalance; i++) {
            uint256 tokenId = IERC721Enumerable(konduxERC721kNFT).tokenOfOwnerByIndex(_staker, i);

            // Get the kNFT's DNA version and check if it's allowed
            int256 dnaVersion = IKondux(konduxERC721kNFT).readGen(tokenId, 0, 1);
            if (!allowedDnaVersions[uint256(dnaVersion)]) { 
                continue;
            }

            // Get the kNFT's boost value and multiply it by 100 to get a percentage
            int256 dnaBoost = IKondux(konduxERC721kNFT).readGen(tokenId, 1, 2) * 100;

            // Clamp the boost value to 0 if it's negative
            if (dnaBoost < 0) {
                dnaBoost = 0;
            }

            // Update the top 5 bonuses array with the current kNFT boost
            for (uint256 j = 0; j < 5; j++) {
                if (uint256(dnaBoost) > top5Bonuses[j]) {
                    uint256 temp = top5Bonuses[j];
                    top5Bonuses[j] = uint256(dnaBoost);
                    dnaBoost = int256(temp);

                    uint256 tempId = top5Ids[j];
                    top5Ids[j] = tokenId;
                    tokenId = tempId;
                }
            }
        }

        return (top5Bonuses, top5Ids);
    }

    /**
     * @dev This function calculates the boost percentage for a staker's deposit.
     * @param _staker The address of the staker.
     * @param _stakeId The ID of the deposit for which to calculate the boost percentage.
     * @return boostPercentage The boost percentage for the staker's deposit.
     */
    function calculateKNFTBoostPercentage(address _staker, uint256 _stakeId) public view returns (uint256 boostPercentage) {
        // Get the top 5 bonuses and their corresponding kNFT IDs
        (uint256[] memory top5Bonuses, ) = getTop5BonusesAndIds(_staker, _stakeId);

        // Add the top 5 bonuses to the boost percentage
        for (uint256 i = 0; i < 5; i++) {
            boostPercentage += top5Bonuses[i];
        }

        return boostPercentage;
    }

    /**
     * @dev This function calculates the boost percentage for a staker.
     * @param _staker The address of the staker.
     * @return boostPercentage The boost percentage for the staker's deposit.
     */
    function calculateMaxKNFTBoostPercentage(address _staker) public view returns (uint256 boostPercentage) {
        // Get the top 5 bonuses and their corresponding kNFT IDs
        (uint256[] memory top5Bonuses, ) = getMaxTop5BonusesAndIds(_staker);

        // Add the top 5 bonuses to the boost percentage
        for (uint256 i = 0; i < 5; i++) {
            boostPercentage += top5Bonuses[i];
        }

        return boostPercentage;
    }

    /**
     * @dev This function calculates the boost percentage for a specified staker and deposit ID.
     * @param _staker The address of the staker for which to calculate the boost.
     * @param _stakeId The ID of the stake for which to calculate the boost.
     * @return boostPercentage The calculated boost percentage for the specified staker and deposit ID.
     */
    function calculateBoostPercentage(address _staker, uint _stakeId) public view returns (uint256 boostPercentage) {
        // Retrieve deposit details by _depositId
        Staker memory deposit_ = userDeposits[_stakeId];

        // Initialize the boost percentage with the base boost percentage for the token
        boostPercentage = divisorERC20[deposit_.token];

        // Check if the staker has Founder's NFTs and add the boost percentage
        if (IERC721(konduxERC721Founders).balanceOf(_staker) > 0) {
            boostPercentage += foundersRewardBoostERC20[deposit_.token];
        }

        // Check if the staker has any kNFTs and calculate the top 5 boosts
        if (IERC721(konduxERC721kNFT).balanceOf(_staker) > 0) {
            boostPercentage += calculateKNFTBoostPercentage(_staker, _stakeId); 
        }

        // If the deposit has a timelock category, add the corresponding boost
        if (deposit_.timelockCategory > 0) {
            boostPercentage += timelockCategoryBoost[deposit_.timelockCategory];
        }

        return boostPercentage;
    }

    /**
     * @dev A function that agreggates the returned values of getTimelock, getDepositTimestamp, getTimelockCategory, getDepositInfo and calculateKNFTBoostPercentage
     * @param _staker The address of the staker for which to calculate the boost.
     * @param _stakeId The ID of the stake for which to calculate the boost.
     * @return _timelock The timelock for the specified deposit ID.
     * @return _depositTimestamp The timestamp of the deposit
     * @return _timelockCategory The timelock category for the specified deposit ID.
     * @return _stake The staked amount for the specified deposit.
     * @return _unclaimedRewards The earned rewards (including unclaimed rewards) for the specified deposit.
     * @return _boostPercentage The calculated boost percentage for the specified staker and deposit ID.
     */
    function getDepositDetails(address _staker, uint _stakeId) public view returns (uint256 _timelock, uint256 _depositTimestamp, uint8 _timelockCategory, uint256 _stake, uint256 _unclaimedRewards, uint256 _boostPercentage) {
        _timelock = getTimelock(_stakeId);
        _depositTimestamp = getDepositTimestamp(_stakeId);
        _timelockCategory = getTimelockCategory(_stakeId);
        (_stake, _unclaimedRewards) = getDepositInfo(_stakeId);
        _boostPercentage = calculateBoostPercentage(_staker, _stakeId);
    }
 
}
// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.8.9;

interface IAuthority {
    /* ========== EVENTS ========== */

    event GovernorPushed(address indexed from, address indexed to, bool _effectiveImmediately);
    event GuardianPushed(address indexed from, address indexed to, bool _effectiveImmediately);
    event PolicyPushed(address indexed from, address indexed to, bool _effectiveImmediately);
    event VaultPushed(address indexed from, address indexed to, bool _effectiveImmediately);
    event RolePushed(address indexed account, bytes32 _role);

    event GovernorPulled(address indexed from, address indexed to);
    event GuardianPulled(address indexed from, address indexed to);
    event PolicyPulled(address indexed from, address indexed to);
    event VaultPulled(address indexed from, address indexed to);

    /* ========== VIEW ========== */

    function governor() external view returns (address);

    function guardian() external view returns (address);

    function policy() external view returns (address);

    function vault() external view returns (address);

    function roles(address _addr) external view returns (bytes32);

}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

interface IHelix is IERC20, IERC20Metadata {
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);
    function burn(address _to, uint256 _amount) external;
    function mint(address _to, uint256 _amount) external; 
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

interface IKondux {
    function changeDenominator(uint96 _denominator) external returns (uint96);
    function setDefaultRoyalty(address receiver, uint96 feeNumerator) external;
    function setTokenRoyalty(uint256 tokenId, address receiver, uint96 feeNumerator) external;
    function setBaseURI(string memory _newURI) external returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
    function safeMint(address to, uint256 dna) external returns (uint256);
    function setDna(uint256 _tokenID, uint256 _dna) external;
    function getDna(uint256 _tokenID) external view returns (uint256);
    function readGen(uint256 _tokenID, uint8 startIndex, uint8 endIndex) external view returns (int256);
    function writeGen(uint256 _tokenID, uint256 inputValue, uint8 startIndex, uint8 endIndex) external;
    function getTransferDate(uint256 _tokenID) external view returns (uint256);
    function burn(uint256 tokenId) external;
    function ownerOf(uint256 tokenId) external view returns (address);
    function getApproved(uint256 tokenId) external view returns (address);
    function faucet() external;
    function balanceOf(address owner) external view returns (uint256);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

interface IKonduxERC20 is IERC20 {
    function excludedFromFees(address) external view returns (bool);
    function tradingOpen() external view returns (bool);
    function taxSwapMin() external view returns (uint256);
    function taxSwapMax() external view returns (uint256);
    function _isLiqPool(address) external view returns (bool);
    function taxRateBuy() external view returns (uint8);
    function taxRateSell() external view returns (uint8);
    function antiBotEnabled() external view returns (bool);
    function excludedFromAntiBot(address) external view returns (bool);
    function _lastSwapBlock(address) external view returns (uint256);
    function taxWallet() external view returns (address);

    event TokensAirdropped(uint256 totalWallets, uint256 totalTokens);
    event TokensBurned(address indexed burnedByWallet, uint256 tokenAmount);
    event TaxWalletChanged(address newTaxWallet);
    event TaxRateChanged(uint8 newBuyTax, uint8 newSellTax);

    function initLP() external;
    function enableTrading() external;
    function burnTokens(uint256 amount) external;
    function enableAntiBot(bool isEnabled) external;
    function excludeFromAntiBot(address wallet, bool isExcluded) external;
    function excludeFromFees(address wallet, bool isExcluded) external;
    function adjustTaxRate(uint8 newBuyTax, uint8 newSellTax) external;
    function setTaxWallet(address newTaxWallet) external;
    function taxSwapSettings(uint32 minValue, uint32 minDivider, uint32 maxValue, uint32 maxDivider) external;

    function totalSupply() external view returns (uint256);
	function decimals() external view returns (uint8);
	function symbol() external view returns (string memory);
	function name() external view returns (string memory);
	function getOwner() external view returns (address);
	function balanceOf(address account) external view returns (uint256);
	function transfer(address recipient, uint256 amount) external returns (bool);
	function allowance(address _owner, address spender) external view returns (uint256);
	function approve(address spender, uint256 amount) external returns (bool);
	function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IKonduxFounders {

    function changeDenominator(uint96 _denominator) external returns (uint96);

    function setDefaultRoyalty(address receiver, uint96 feeNumerator) external;

    function setTokenRoyalty(uint256 tokenId,address receiver,uint96 feeNumerator) external;

    function setBaseURI(string memory _newURI) external returns (string memory);

    function pause() external;

    function unpause() external;

    function safeMint(address to) external returns (uint256);

    function setMinter(address _minter) external;

    function totalSupply() external view returns (uint256);


}
//SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

interface ITreasury {
    function deposit(
        uint256 _amount,
        address _token
    ) external;

    function depositEther() external payable;

    function withdraw(
        uint256 _amount,
        address _token
    ) external;

    function withdrawTo(
        uint256 _amount,
        address _token,
        address _to
    ) external;

    function withdrawEther(
        uint256 _amount
    ) external;
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;
import "../interfaces/IKondux.sol";
import "../interfaces/ITreasury.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";


/**
 * @title MinterBundle
 * @notice Manages the minting of NFT bundles, including setting prices, pausing/unpausing minting, and interacting with external contracts for NFT and treasury management. Designed to facilitate bulk operations for efficiency and convenience.
 * @dev Inherits from OpenZeppelin's AccessControl for comprehensive role management, enabling a robust permission system. Utilizes interfaces for external contract interactions, ensuring modularity and flexibility.
 */
contract MinterBundleDemo is AccessControl {

    bool public paused; // Controls whether minting is currently allowed.
    bool public foundersPassActive; // Controls whether founders pass can be used for minting.
    bool public kBoxActive; // Controls whether kBox can be used for minting.
    bool public kNFTActive; // Controls whether kNFT can be used for minting.
    bool public whitelistActive; // Controls whether the whitelist is active.
    uint16 public bundleSize; // The number of NFTs in each minted bundle.
    uint256 public price; // The ETH price for minting a bundle.
    bytes32 public rootWhitelist; // The Merkle root for the whitelist.

    IKondux public kNFT; // Interface to interact with the Kondux NFT contract for NFT operations.
    IKondux public kBox; // Interface for the kBOX NFT contract, allowing for special minting conditions.
    IKondux public foundersPass; // Interface for the founders pass contract, allowing for special minting conditions.
    ITreasury public treasury; // Interface to interact with the treasury contract for financial transactions.

    mapping (uint256 => bool) public usedFoundersPass;

    // Events for tracking contract state changes and interactions.
    event BundleMinted(address indexed minter, uint256[] tokenIds);
    event FoundersPassUsed(address indexed minter, uint256[] tokenIds, uint256 foundersPassId);
    event TreasuryChanged(address indexed treasury);
    event KNFTChanged(address indexed kNFT);
    event KBoxChanged(address indexed kBox);
    event FoundersPassChanged(address indexed foundersPass);
    event PriceChanged(uint256 price);
    event BundleSizeChanged(uint16 bundleSize);
    event Paused(bool paused);
    event PublicMintActive(bool active);
    event KBoxMintActive(bool active);
    event FoundersPassMintActive(bool active);
    event WhitelistActive(bool active);
    event WhitelistRootChanged(bytes32 root);

    /**
     * @dev Sets initial contract state, including addresses of related contracts, default price, and bundle size. Grants admin role to the deployer for further administrative actions.
     * @param _kNFT Address of the Kondux NFT contract.
     * @param _kBox Address of the kBox NFT contract.
     * @param _treasury Address of the treasury contract.
     */
    constructor(address _kNFT, address _kBox, address _foundersPass, address _treasury) {
        kNFT = IKondux(_kNFT);
        kBox = IKondux(_kBox);
        foundersPass = IKondux(_foundersPass);
        treasury = ITreasury(_treasury);
        price = 0.000001 ether;
        bundleSize = 5;
        paused = false;
        foundersPassActive = true;
        kBoxActive = true;
        whitelistActive = true;
        kNFTActive = true;
        
        // Grant admin role to the message sender
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /**
     * @notice Toggles the paused state of minting operations.
     * @dev Can only be executed by an admin. Emits a `Paused` event reflecting the new state.
     * @param _paused Boolean indicating the desired paused state.
     */
    function setPaused(bool _paused) public onlyAdmin {
        paused = _paused;
        emit Paused(_paused);
    }

    /**
     * @notice Mints a bundle of NFTs if minting is active and sufficient ETH is sent.
     * @dev Validates the sent ETH amount against the current price, deposits the ETH to the treasury, and mints the NFT bundle. Requires the contract to not be paused.
     * @return tokenIds Array of minted token IDs.
     */
    function publicMint() public payable isActive isPublicMintActive returns (uint256[] memory) {
        require(msg.value >= price, "Not enough ETH sent");
        treasury.depositEther{ value: msg.value }();
        uint256[] memory tokenIds = _mintBundle(bundleSize);
        emit BundleMinted(msg.sender, tokenIds);
        return tokenIds;
    }

    /**
     * @notice Mints a bundle of NFTs if minting is active and sufficient ETH is sent. Requires the sender to be on the whitelist.
     * @dev Validates the sent ETH amount against the current price, deposits the ETH to the treasury, and mints the NFT bundle. Requires the contract to not be paused and the whitelist to be active.
     * @param _merkleProof The Merkle proof for the sender's address.
     * @return tokenIds Array of minted token IDs.
     */     
    function publicMintWhitelist(bytes32[] calldata _merkleProof) public payable isActive isWhitelistActive returns (uint256[] memory) {
        require(msg.value >= price, "Not enough ETH sent");        
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(_merkleProof, rootWhitelist, leaf), "Incorrect proof");
        treasury.depositEther{ value: msg.value }();
        uint256[] memory tokenIds = _mintBundle(bundleSize);
        emit BundleMinted(msg.sender, tokenIds);
        return tokenIds;
    }

    /**
     * @notice Burns a specified kBox and mints a bundle of NFTs as a special minting operation.
     * @dev Requires the sender to be the owner of the kBox and for the contract to be approved to burn the kBox. This function demonstrates an alternative minting pathway with additional prerequisites.
     * @param _kBoxId The ID of the kBox to be burned in exchange for minting a new NFT bundle.
     * @return tokenIds Array of minted token IDs.
     */
    function publicMintWithBox(uint256 _kBoxId) public isActive isKBoxMintActive returns (uint256[] memory){
        require(kBox.ownerOf(_kBoxId) == msg.sender, "You are not the owner of this kBox");
        require(kBox.getApproved(_kBoxId) == address(this), "This contract is not approved to burn this kBox");

        kBox.burn(_kBoxId);

        // Mint a bundle of NFTs
        uint256[] memory tokenIds = _mintBundle(bundleSize);

        emit BundleMinted(msg.sender, tokenIds);
        return tokenIds;
    }

    /**
     * @notice Marsks a specified founders pass as used and mints a bundle of NFTs as a special minting operation.
     * @dev Requires the sender to be the owner of the founders pass and we mark it as used in the redeem process. This function demonstrates an alternative minting pathway with additional prerequisites.
     * @param _foundersPassId The ID of the founders pass to be marked as used in exchange for minting a new NFT bundle.
     * @return tokenIds Array of minted token IDs.
     */
    function publicMintWithFoundersPass(uint256 _foundersPassId) public isActive isFoundersPassMintActive returns (uint256[] memory){
        require(foundersPass.ownerOf(_foundersPassId) == msg.sender, "You are not the owner of this founders pass");
        require(!usedFoundersPass[_foundersPassId], "This founders pass has already been used");

        usedFoundersPass[_foundersPassId] = true;

        // Mint a bundle of NFTs
        uint256[] memory tokenIds = _mintBundle(bundleSize);

        emit FoundersPassUsed(msg.sender, tokenIds, _foundersPassId);
        return tokenIds;
    }

    /**
     * @notice Sets the DNA for each NFT in a minted bundle.
     * @dev Admin-only function that assigns a unique DNA to each NFT in the bundle, ensuring that each NFT has distinct characteristics. Validates that the lengths of the `tokenIds` and `dnas` arrays match and correspond to the current `bundleSize`.
     * @param tokenIds Array of token IDs for which to set DNA.
     * @param dnas Array of DNA values corresponding to each token ID.
     */
    function setBundleDna(uint256[] memory tokenIds, uint256[] memory dnas) public onlyAdmin {        
        require(tokenIds.length == dnas.length, "Array lengths do not match");
        require(tokenIds.length == bundleSize, "Array length must match bundle size");
        for (uint256 i = 0; i < bundleSize; i++) {
            kNFT.setDna(tokenIds[i], dnas[i]);
        }
    }

    /**
     * @notice Updates the address of the kBox NFT contract.
     * @dev Admin-only function to change the contract address through which the smart contract interacts with kBox NFTs. Emits a `KNFTChanged` event on success.
     * @param _kBox The new address of the kBox contract.
     */
    function setKBox(address _kBox) public onlyAdmin {
        require(_kBox != address(0), "kBox address is not set");
        kBox = IKondux(_kBox);
        emit KBoxChanged(_kBox);
    }

    /**
     * @notice Updates the address of the treasury contract.
     * @dev Admin-only function to change the contract address for managing treasury operations. Validates the new address before updating and emits a `TreasuryChanged` event on success.
     * @param _treasury The new treasury contract address.
     */
    function setTreasury(address _treasury) public onlyAdmin {
        require(_treasury != address(0), "Treasury address is not set");
        treasury = ITreasury(_treasury);
        emit TreasuryChanged(_treasury);
    }

    /// @notice Sets the Kondux NFT contract address.
    /// @dev Can only be called by an admin, requires non-zero address.
    /// @param _kNFT The new KNFT address.
    function setKNFT(address _kNFT) public onlyAdmin {
        require(_kNFT != address(0), "KNFT address is not set");
        kNFT = IKondux(_kNFT);
        emit KNFTChanged(_kNFT);
    }

    /**
     * @notice Updates the address of the founders pass contract.
     * @dev Admin-only function to change the contract address for managing founders pass operations. Validates the new address before updating and emits a `FoundersPassChanged` event on success.
     * @param _foundersPass The new founders pass contract address.
     */
    function setFoundersPass(address _foundersPass) public onlyAdmin {
        require(_foundersPass != address(0), "Founders pass address is not set");
        foundersPass = IKondux(_foundersPass);
        emit FoundersPassChanged(_foundersPass);
    }

    /**
     * @notice Updates the minting price for an NFT bundle.
     * @dev Admin-only function to adjust the ETH price required to mint an NFT bundle. Validates the new price before applying the change and emits a `PriceChanged` event on success.
     * @param _price The new minting price in ETH.
     */
    function setPrice(uint256 _price) public onlyAdmin {
        require(_price > 0, "Price must be greater than 0");
        price = _price;
        emit PriceChanged(_price);
    }

    /**
     * @notice Adjusts the size of the NFT bundle that can be minted at once.
     * @dev Admin-only function to set the number of NFTs included in a single mint operation. Validates the new size for practical limits and emits a `BundleSizeChanged` event on update.
     * @param _bundleSize The new bundle size, within set boundaries.
     */
    function setBundleSize(uint16 _bundleSize) public onlyAdmin {
        require(_bundleSize > 0, "Bundle size must be greater than 0");
        require(_bundleSize <= 15, "Bundle size must be less than or equal to 15");
        bundleSize = _bundleSize;
        emit BundleSizeChanged(_bundleSize);
    }

    /**
     * @notice Grants the admin role to a specified address.
     * @dev Can be executed only by an existing admin. Ensures that the target address is not already an admin and is not the zero address before granting the role.
     * @param _admin The address to be granted admin privileges.
     */
    function setAdmin(address _admin) public onlyAdmin {
        require(_admin != address(0), "Admin address is not set");
        require(!hasRole(DEFAULT_ADMIN_ROLE, _admin), "Address already has admin role");
        grantRole(DEFAULT_ADMIN_ROLE, _admin);
    }

    /**
     * @notice Sets the active state for public minting of Kondux NFTs.
     * @dev Admin-only function to toggle the active state of public minting for Kondux NFTs. Emits a `PublicMintActive` event reflecting the new state.
     * @param _active Boolean indicating the desired active state.
     */
    function setPublicMintActive(bool _active) public onlyAdmin {
        kNFTActive = _active;
        emit PublicMintActive(_active);
    }

    /**
     * @notice Sets the active state for kBox minting.
     * @dev Admin-only function to toggle the active state of minting kBox NFTs. Emits a `KBoxMintActive` event reflecting the new state.
     * @param _active Boolean indicating the desired active state.
     */
    function setKBoxMintActive(bool _active) public onlyAdmin {
        kBoxActive = _active;
        emit KBoxMintActive(_active);
    }

    /**
     * @notice Sets the active state for founders pass minting.
     * @dev Admin-only function to toggle the active state of minting NFTs with founders passes. Emits a `FoundersPassMintActive` event reflecting the new state.
     * @param _active Boolean indicating the desired active state.
     */
    function setFoundersPassMintActive(bool _active) public onlyAdmin {
        foundersPassActive = _active;
        emit FoundersPassMintActive(_active);
    }

    /**
     * @notice Sets the active state for the whitelist.
     * @dev Admin-only function to toggle the active state of the whitelist. Emits a `WhitelistActive` event reflecting the new state.
     * @param _active Boolean indicating the desired active state.
     */
    function setWhitelistActive(bool _active) public onlyAdmin {
        whitelistActive = _active;
        emit WhitelistActive(_active);
    }

    /**
     * @notice Updates the Merkle root for the whitelist.
     * @dev Admin-only function to set a new Merkle root for the whitelist. Emits a `WhitelistRootChanged` event reflecting the new root.
     * @param _root The new Merkle root for the whitelist.
     */
    function setWhitelistRoot(bytes32 _root) public onlyAdmin {
        rootWhitelist = _root;

        emit WhitelistRootChanged(_root);
    }

    // Getter functions provide external visibility into the contract's state without modifying it.

    /**
     * @notice Returns the address of the Kondux NFT contract.
     * @return The current address interfaced by this contract for Kondux NFT operations.
     */
    function getKNFT() public view returns (address) {
        return address(kNFT);
    }

    /**
     * @notice Returns the address of the kBox NFT contract.
     * @return The current address interfaced by this contract for kBox NFT operations.
     */
    function getKBox() public view returns (address) {
        return address(kBox);
    }

    /**
     * @notice Returns the address of the treasury contract.
     * @return The current treasury contract address for financial transactions related to minting.
     */
    function getTreasury() public view returns (address) {
        return address(treasury);
    }

    // Internal functions are utilized by public functions to perform core operations in a secure and encapsulated manner.

    /**
     * @dev Mints a specified number of NFTs to the sender's address. Each NFT minted is part of the bundle and is assigned a consecutive token ID.
     * @param _bundleSize The number of NFTs to mint in the bundle.
     * @return tokenIds An array of the minted NFT token IDs.
     */
    function _mintBundle(uint16 _bundleSize) internal returns (uint256[] memory) {
        uint256[] memory tokenIds = new uint256[](_bundleSize);
        for (uint16 i = 0; i < _bundleSize; i++) {
            tokenIds[i] = kNFT.safeMint(msg.sender, 0); // The second parameter could be a metadata identifier or similar.
        }
        return tokenIds;
    }

    // Modifiers enhance function behaviors with pre-conditions, making the contract's logic more modular, readable, and secure.

    /**
     * @dev Ensures a function is only callable when the contract is not paused.
     */
    modifier isActive() {
        require(!paused, "Contract is paused");
        _;
    }

    /**
     * @dev Ensures a function is only callable when kNFT minting is active.
     */
    modifier isPublicMintActive() {
        require(kNFTActive || (foundersPassActive && foundersPass.balanceOf(msg.sender) > 0), "kNFT minting is not active or you don't have a Founder's Pass");
        _;
    }

    /**
     * @dev Ensures a function is only callable when kBox minting is active.
     */
    modifier isKBoxMintActive() {
        require(kBoxActive, "kBox minting is not active");
        _;
    }

    /**
     * @dev Ensures a function is only callable when founders pass minting is active.
     */
    modifier isFoundersPassMintActive() {
        require(foundersPassActive, "Founder's Pass minting is not active");
        _;
    }

    /**
     * @dev Ensures a function is only callable when the whitelist is active.
     */
    modifier isWhitelistActive() {
        require(whitelistActive, "Whitelist is not active");
        _;
    }

    /**
     * @dev Restricts a function's access to users with the admin role.
     */
    modifier onlyAdmin() {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not an admin");
        _;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../interfaces/IAuthority.sol";

/// @dev Reasoning for this contract = modifiers literaly copy code
/// instead of pointing towards the logic to execute. Over many
/// functions this bloats contract size unnecessarily.
/// imho modifiers are a meme.
abstract contract AccessControlled {
    /* ========== EVENTS ========== */

    event AuthorityUpdated(IAuthority authority);

    /* ========== STATE VARIABLES ========== */

    IAuthority public authority;

    /* ========== Constructor ========== */

    constructor(IAuthority _authority) {
        require(address(_authority) != address(0), "Authority cannot be zero address");
        authority = _authority;
        emit AuthorityUpdated(_authority);
    }

    /* ========== "MODIFIERS" ========== */

    modifier onlyGovernor {
        _onlyGovernor();
        _;
    }

    modifier onlyGuardian {
        _onlyGuardian();
        _;
    }

    modifier onlyPolicy {
        _onlyPolicy();
        _;
    }

    modifier onlyVault {
        _onlyVault();
        _;
    }

    modifier onlyGlobalRole(bytes32 _role){
        _onlyRole(_role);
        _;
    }

    /* ========== GOV ONLY ========== */

    function initializeAuthority(IAuthority _newAuthority) internal {
        require(authority == IAuthority(address(0)), "AUTHORITY_INITIALIZED");
        authority = _newAuthority;
        emit AuthorityUpdated(_newAuthority);
    }

    function setAuthority(IAuthority _newAuthority) external {
        _onlyGovernor();
        authority = _newAuthority;
        emit AuthorityUpdated(_newAuthority);
    }

    /* ========== INTERNAL CHECKS ========== */

    function _onlyGovernor() internal view {
        require(msg.sender == authority.governor(), "UNAUTHORIZED");
    }

    function _onlyGuardian() internal view {
        require(msg.sender == authority.guardian(), "UNAUTHORIZED");
    }

    function _onlyPolicy() internal view {
        require(msg.sender == authority.policy(), "UNAUTHORIZED");        
    }

    function _onlyVault() internal view {
        require(msg.sender == authority.vault(), "UNAUTHORIZED");                
    }

    function _onlyRole(bytes32 _role) internal view {
        require(authority.roles(msg.sender) == _role, "UNAUTHORIZED");
    }
  
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

library console {
    address constant CONSOLE_ADDRESS =
        0x000000000000000000636F6e736F6c652e6c6f67;

    function _sendLogPayloadImplementation(bytes memory payload) internal view {
        address consoleAddress = CONSOLE_ADDRESS;
        /// @solidity memory-safe-assembly
        assembly {
            pop(
                staticcall(
                    gas(),
                    consoleAddress,
                    add(payload, 32),
                    mload(payload),
                    0,
                    0
                )
            )
        }
    }

    function _castToPure(
      function(bytes memory) internal view fnIn
    ) internal pure returns (function(bytes memory) pure fnOut) {
        assembly {
            fnOut := fnIn
        }
    }

    function _sendLogPayload(bytes memory payload) internal pure {
        _castToPure(_sendLogPayloadImplementation)(payload);
    }

    function log() internal pure {
        _sendLogPayload(abi.encodeWithSignature("log()"));
    }
    function logInt(int256 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(int256)", p0));
    }

    function logUint(uint256 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256)", p0));
    }

    function logString(string memory p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string)", p0));
    }

    function logBool(bool p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
    }

    function logAddress(address p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address)", p0));
    }

    function logBytes(bytes memory p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes)", p0));
    }

    function logBytes1(bytes1 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes1)", p0));
    }

    function logBytes2(bytes2 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes2)", p0));
    }

    function logBytes3(bytes3 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes3)", p0));
    }

    function logBytes4(bytes4 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes4)", p0));
    }

    function logBytes5(bytes5 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes5)", p0));
    }

    function logBytes6(bytes6 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes6)", p0));
    }

    function logBytes7(bytes7 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes7)", p0));
    }

    function logBytes8(bytes8 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes8)", p0));
    }

    function logBytes9(bytes9 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes9)", p0));
    }

    function logBytes10(bytes10 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes10)", p0));
    }

    function logBytes11(bytes11 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes11)", p0));
    }

    function logBytes12(bytes12 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes12)", p0));
    }

    function logBytes13(bytes13 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes13)", p0));
    }

    function logBytes14(bytes14 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes14)", p0));
    }

    function logBytes15(bytes15 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes15)", p0));
    }

    function logBytes16(bytes16 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes16)", p0));
    }

    function logBytes17(bytes17 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes17)", p0));
    }

    function logBytes18(bytes18 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes18)", p0));
    }

    function logBytes19(bytes19 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes19)", p0));
    }

    function logBytes20(bytes20 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes20)", p0));
    }

    function logBytes21(bytes21 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes21)", p0));
    }

    function logBytes22(bytes22 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes22)", p0));
    }

    function logBytes23(bytes23 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes23)", p0));
    }

    function logBytes24(bytes24 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes24)", p0));
    }

    function logBytes25(bytes25 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes25)", p0));
    }

    function logBytes26(bytes26 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes26)", p0));
    }

    function logBytes27(bytes27 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes27)", p0));
    }

    function logBytes28(bytes28 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes28)", p0));
    }

    function logBytes29(bytes29 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes29)", p0));
    }

    function logBytes30(bytes30 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes30)", p0));
    }

    function logBytes31(bytes31 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes31)", p0));
    }

    function logBytes32(bytes32 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes32)", p0));
    }

    function log(uint256 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256)", p0));
    }

    function log(string memory p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string)", p0));
    }

    function log(bool p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
    }

    function log(address p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address)", p0));
    }

    function log(uint256 p0, uint256 p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256)", p0, p1));
    }

    function log(uint256 p0, string memory p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string)", p0, p1));
    }

    function log(uint256 p0, bool p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool)", p0, p1));
    }

    function log(uint256 p0, address p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address)", p0, p1));
    }

    function log(string memory p0, uint256 p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256)", p0, p1));
    }

    function log(string memory p0, string memory p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string)", p0, p1));
    }

    function log(string memory p0, bool p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool)", p0, p1));
    }

    function log(string memory p0, address p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address)", p0, p1));
    }

    function log(bool p0, uint256 p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256)", p0, p1));
    }

    function log(bool p0, string memory p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string)", p0, p1));
    }

    function log(bool p0, bool p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool)", p0, p1));
    }

    function log(bool p0, address p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address)", p0, p1));
    }

    function log(address p0, uint256 p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256)", p0, p1));
    }

    function log(address p0, string memory p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string)", p0, p1));
    }

    function log(address p0, bool p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool)", p0, p1));
    }

    function log(address p0, address p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address)", p0, p1));
    }

    function log(uint256 p0, uint256 p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256)", p0, p1, p2));
    }

    function log(uint256 p0, uint256 p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string)", p0, p1, p2));
    }

    function log(uint256 p0, uint256 p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool)", p0, p1, p2));
    }

    function log(uint256 p0, uint256 p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address)", p0, p1, p2));
    }

    function log(uint256 p0, string memory p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256)", p0, p1, p2));
    }

    function log(uint256 p0, string memory p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,string)", p0, p1, p2));
    }

    function log(uint256 p0, string memory p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool)", p0, p1, p2));
    }

    function log(uint256 p0, string memory p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,address)", p0, p1, p2));
    }

    function log(uint256 p0, bool p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256)", p0, p1, p2));
    }

    function log(uint256 p0, bool p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string)", p0, p1, p2));
    }

    function log(uint256 p0, bool p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool)", p0, p1, p2));
    }

    function log(uint256 p0, bool p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address)", p0, p1, p2));
    }

    function log(uint256 p0, address p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256)", p0, p1, p2));
    }

    function log(uint256 p0, address p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,string)", p0, p1, p2));
    }

    function log(uint256 p0, address p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool)", p0, p1, p2));
    }

    function log(uint256 p0, address p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,address)", p0, p1, p2));
    }

    function log(string memory p0, uint256 p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256)", p0, p1, p2));
    }

    function log(string memory p0, uint256 p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,string)", p0, p1, p2));
    }

    function log(string memory p0, uint256 p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool)", p0, p1, p2));
    }

    function log(string memory p0, uint256 p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,address)", p0, p1, p2));
    }

    function log(string memory p0, string memory p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,uint256)", p0, p1, p2));
    }

    function log(string memory p0, string memory p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,string)", p0, p1, p2));
    }

    function log(string memory p0, string memory p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,bool)", p0, p1, p2));
    }

    function log(string memory p0, string memory p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,address)", p0, p1, p2));
    }

    function log(string memory p0, bool p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256)", p0, p1, p2));
    }

    function log(string memory p0, bool p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,string)", p0, p1, p2));
    }

    function log(string memory p0, bool p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,bool)", p0, p1, p2));
    }

    function log(string memory p0, bool p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,address)", p0, p1, p2));
    }

    function log(string memory p0, address p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,uint256)", p0, p1, p2));
    }

    function log(string memory p0, address p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,string)", p0, p1, p2));
    }

    function log(string memory p0, address p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,bool)", p0, p1, p2));
    }

    function log(string memory p0, address p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,address)", p0, p1, p2));
    }

    function log(bool p0, uint256 p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256)", p0, p1, p2));
    }

    function log(bool p0, uint256 p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string)", p0, p1, p2));
    }

    function log(bool p0, uint256 p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool)", p0, p1, p2));
    }

    function log(bool p0, uint256 p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address)", p0, p1, p2));
    }

    function log(bool p0, string memory p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256)", p0, p1, p2));
    }

    function log(bool p0, string memory p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,string)", p0, p1, p2));
    }

    function log(bool p0, string memory p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,bool)", p0, p1, p2));
    }

    function log(bool p0, string memory p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,address)", p0, p1, p2));
    }

    function log(bool p0, bool p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256)", p0, p1, p2));
    }

    function log(bool p0, bool p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,string)", p0, p1, p2));
    }

    function log(bool p0, bool p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool)", p0, p1, p2));
    }

    function log(bool p0, bool p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,address)", p0, p1, p2));
    }

    function log(bool p0, address p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256)", p0, p1, p2));
    }

    function log(bool p0, address p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,string)", p0, p1, p2));
    }

    function log(bool p0, address p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,bool)", p0, p1, p2));
    }

    function log(bool p0, address p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,address)", p0, p1, p2));
    }

    function log(address p0, uint256 p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256)", p0, p1, p2));
    }

    function log(address p0, uint256 p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,string)", p0, p1, p2));
    }

    function log(address p0, uint256 p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool)", p0, p1, p2));
    }

    function log(address p0, uint256 p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,address)", p0, p1, p2));
    }

    function log(address p0, string memory p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,uint256)", p0, p1, p2));
    }

    function log(address p0, string memory p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,string)", p0, p1, p2));
    }

    function log(address p0, string memory p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,bool)", p0, p1, p2));
    }

    function log(address p0, string memory p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,address)", p0, p1, p2));
    }

    function log(address p0, bool p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256)", p0, p1, p2));
    }

    function log(address p0, bool p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,string)", p0, p1, p2));
    }

    function log(address p0, bool p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,bool)", p0, p1, p2));
    }

    function log(address p0, bool p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,address)", p0, p1, p2));
    }

    function log(address p0, address p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,uint256)", p0, p1, p2));
    }

    function log(address p0, address p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,string)", p0, p1, p2));
    }

    function log(address p0, address p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,bool)", p0, p1, p2));
    }

    function log(address p0, address p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,address)", p0, p1, p2));
    }

    function log(uint256 p0, uint256 p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256,uint256)", p0, p1, p2, p3));
    }

    function log(uint256 p0, uint256 p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256,string)", p0, p1, p2, p3));
    }

    function log(uint256 p0, uint256 p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256,bool)", p0, p1, p2, p3));
    }

    function log(uint256 p0, uint256 p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256,address)", p0, p1, p2, p3));
    }

    function log(uint256 p0, uint256 p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string,uint256)", p0, p1, p2, p3));
    }

    function log(uint256 p0, uint256 p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string,string)", p0, p1, p2, p3));
    }

    function log(uint256 p0, uint256 p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string,bool)", p0, p1, p2, p3));
    }

    function log(uint256 p0, uint256 p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string,address)", p0, p1, p2, p3));
    }

    function log(uint256 p0, uint256 p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool,uint256)", p0, p1, p2, p3));
    }

    function log(uint256 p0, uint256 p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool,string)", p0, p1, p2, p3));
    }

    function log(uint256 p0, uint256 p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool,bool)", p0, p1, p2, p3));
    }

    function log(uint256 p0, uint256 p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool,address)", p0, p1, p2, p3));
    }

    function log(uint256 p0, uint256 p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address,uint256)", p0, p1, p2, p3));
    }

    function log(uint256 p0, uint256 p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address,string)", p0, p1, p2, p3));
    }

    function log(uint256 p0, uint256 p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address,bool)", p0, p1, p2, p3));
    }

    function log(uint256 p0, uint256 p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address,address)", p0, p1, p2, p3));
    }

    function log(uint256 p0, string memory p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256,uint256)", p0, p1, p2, p3));
    }

    function log(uint256 p0, string memory p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256,string)", p0, p1, p2, p3));
    }

    function log(uint256 p0, string memory p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256,bool)", p0, p1, p2, p3));
    }

    function log(uint256 p0, string memory p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256,address)", p0, p1, p2, p3));
    }

    function log(uint256 p0, string memory p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,string,uint256)", p0, p1, p2, p3));
    }

    function log(uint256 p0, string memory p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,string,string)", p0, p1, p2, p3));
    }

    function log(uint256 p0, string memory p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,string,bool)", p0, p1, p2, p3));
    }

    function log(uint256 p0, string memory p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,string,address)", p0, p1, p2, p3));
    }

    function log(uint256 p0, string memory p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool,uint256)", p0, p1, p2, p3));
    }

    function log(uint256 p0, string memory p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool,string)", p0, p1, p2, p3));
    }

    function log(uint256 p0, string memory p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool,bool)", p0, p1, p2, p3));
    }

    function log(uint256 p0, string memory p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool,address)", p0, p1, p2, p3));
    }

    function log(uint256 p0, string memory p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,address,uint256)", p0, p1, p2, p3));
    }

    function log(uint256 p0, string memory p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,address,string)", p0, p1, p2, p3));
    }

    function log(uint256 p0, string memory p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,address,bool)", p0, p1, p2, p3));
    }

    function log(uint256 p0, string memory p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,address,address)", p0, p1, p2, p3));
    }

    function log(uint256 p0, bool p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256,uint256)", p0, p1, p2, p3));
    }

    function log(uint256 p0, bool p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256,string)", p0, p1, p2, p3));
    }

    function log(uint256 p0, bool p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256,bool)", p0, p1, p2, p3));
    }

    function log(uint256 p0, bool p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256,address)", p0, p1, p2, p3));
    }

    function log(uint256 p0, bool p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string,uint256)", p0, p1, p2, p3));
    }

    function log(uint256 p0, bool p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string,string)", p0, p1, p2, p3));
    }

    function log(uint256 p0, bool p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string,bool)", p0, p1, p2, p3));
    }

    function log(uint256 p0, bool p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string,address)", p0, p1, p2, p3));
    }

    function log(uint256 p0, bool p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool,uint256)", p0, p1, p2, p3));
    }

    function log(uint256 p0, bool p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool,string)", p0, p1, p2, p3));
    }

    function log(uint256 p0, bool p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool,bool)", p0, p1, p2, p3));
    }

    function log(uint256 p0, bool p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool,address)", p0, p1, p2, p3));
    }

    function log(uint256 p0, bool p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address,uint256)", p0, p1, p2, p3));
    }

    function log(uint256 p0, bool p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address,string)", p0, p1, p2, p3));
    }

    function log(uint256 p0, bool p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address,bool)", p0, p1, p2, p3));
    }

    function log(uint256 p0, bool p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address,address)", p0, p1, p2, p3));
    }

    function log(uint256 p0, address p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256,uint256)", p0, p1, p2, p3));
    }

    function log(uint256 p0, address p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256,string)", p0, p1, p2, p3));
    }

    function log(uint256 p0, address p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256,bool)", p0, p1, p2, p3));
    }

    function log(uint256 p0, address p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256,address)", p0, p1, p2, p3));
    }

    function log(uint256 p0, address p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,string,uint256)", p0, p1, p2, p3));
    }

    function log(uint256 p0, address p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,string,string)", p0, p1, p2, p3));
    }

    function log(uint256 p0, address p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,string,bool)", p0, p1, p2, p3));
    }

    function log(uint256 p0, address p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,string,address)", p0, p1, p2, p3));
    }

    function log(uint256 p0, address p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool,uint256)", p0, p1, p2, p3));
    }

    function log(uint256 p0, address p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool,string)", p0, p1, p2, p3));
    }

    function log(uint256 p0, address p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool,bool)", p0, p1, p2, p3));
    }

    function log(uint256 p0, address p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool,address)", p0, p1, p2, p3));
    }

    function log(uint256 p0, address p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,address,uint256)", p0, p1, p2, p3));
    }

    function log(uint256 p0, address p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,address,string)", p0, p1, p2, p3));
    }

    function log(uint256 p0, address p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,address,bool)", p0, p1, p2, p3));
    }

    function log(uint256 p0, address p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,address,address)", p0, p1, p2, p3));
    }

    function log(string memory p0, uint256 p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256,uint256)", p0, p1, p2, p3));
    }

    function log(string memory p0, uint256 p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256,string)", p0, p1, p2, p3));
    }

    function log(string memory p0, uint256 p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256,bool)", p0, p1, p2, p3));
    }

    function log(string memory p0, uint256 p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256,address)", p0, p1, p2, p3));
    }

    function log(string memory p0, uint256 p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,string,uint256)", p0, p1, p2, p3));
    }

    function log(string memory p0, uint256 p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,string,string)", p0, p1, p2, p3));
    }

    function log(string memory p0, uint256 p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,string,bool)", p0, p1, p2, p3));
    }

    function log(string memory p0, uint256 p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,string,address)", p0, p1, p2, p3));
    }

    function log(string memory p0, uint256 p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool,uint256)", p0, p1, p2, p3));
    }

    function log(string memory p0, uint256 p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool,string)", p0, p1, p2, p3));
    }

    function log(string memory p0, uint256 p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool,bool)", p0, p1, p2, p3));
    }

    function log(string memory p0, uint256 p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool,address)", p0, p1, p2, p3));
    }

    function log(string memory p0, uint256 p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,address,uint256)", p0, p1, p2, p3));
    }

    function log(string memory p0, uint256 p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,address,string)", p0, p1, p2, p3));
    }

    function log(string memory p0, uint256 p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,address,bool)", p0, p1, p2, p3));
    }

    function log(string memory p0, uint256 p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,address,address)", p0, p1, p2, p3));
    }

    function log(string memory p0, string memory p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,uint256,uint256)", p0, p1, p2, p3));
    }

    function log(string memory p0, string memory p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,uint256,string)", p0, p1, p2, p3));
    }

    function log(string memory p0, string memory p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,uint256,bool)", p0, p1, p2, p3));
    }

    function log(string memory p0, string memory p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,uint256,address)", p0, p1, p2, p3));
    }

    function log(string memory p0, string memory p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,string,uint256)", p0, p1, p2, p3));
    }

    function log(string memory p0, string memory p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,string,string)", p0, p1, p2, p3));
    }

    function log(string memory p0, string memory p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,string,bool)", p0, p1, p2, p3));
    }

    function log(string memory p0, string memory p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,string,address)", p0, p1, p2, p3));
    }

    function log(string memory p0, string memory p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,bool,uint256)", p0, p1, p2, p3));
    }

    function log(string memory p0, string memory p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,bool,string)", p0, p1, p2, p3));
    }

    function log(string memory p0, string memory p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,bool,bool)", p0, p1, p2, p3));
    }

    function log(string memory p0, string memory p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,bool,address)", p0, p1, p2, p3));
    }

    function log(string memory p0, string memory p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,address,uint256)", p0, p1, p2, p3));
    }

    function log(string memory p0, string memory p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,address,string)", p0, p1, p2, p3));
    }

    function log(string memory p0, string memory p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,address,bool)", p0, p1, p2, p3));
    }

    function log(string memory p0, string memory p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,address,address)", p0, p1, p2, p3));
    }

    function log(string memory p0, bool p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256,uint256)", p0, p1, p2, p3));
    }

    function log(string memory p0, bool p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256,string)", p0, p1, p2, p3));
    }

    function log(string memory p0, bool p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256,bool)", p0, p1, p2, p3));
    }

    function log(string memory p0, bool p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256,address)", p0, p1, p2, p3));
    }

    function log(string memory p0, bool p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,string,uint256)", p0, p1, p2, p3));
    }

    function log(string memory p0, bool p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,string,string)", p0, p1, p2, p3));
    }

    function log(string memory p0, bool p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,string,bool)", p0, p1, p2, p3));
    }

    function log(string memory p0, bool p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,string,address)", p0, p1, p2, p3));
    }

    function log(string memory p0, bool p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,uint256)", p0, p1, p2, p3));
    }

    function log(string memory p0, bool p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,string)", p0, p1, p2, p3));
    }

    function log(string memory p0, bool p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,bool)", p0, p1, p2, p3));
    }

    function log(string memory p0, bool p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,address)", p0, p1, p2, p3));
    }

    function log(string memory p0, bool p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,address,uint256)", p0, p1, p2, p3));
    }

    function log(string memory p0, bool p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,address,string)", p0, p1, p2, p3));
    }

    function log(string memory p0, bool p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,address,bool)", p0, p1, p2, p3));
    }

    function log(string memory p0, bool p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,address,address)", p0, p1, p2, p3));
    }

    function log(string memory p0, address p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,uint256,uint256)", p0, p1, p2, p3));
    }

    function log(string memory p0, address p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,uint256,string)", p0, p1, p2, p3));
    }

    function log(string memory p0, address p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,uint256,bool)", p0, p1, p2, p3));
    }

    function log(string memory p0, address p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,uint256,address)", p0, p1, p2, p3));
    }

    function log(string memory p0, address p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,string,uint256)", p0, p1, p2, p3));
    }

    function log(string memory p0, address p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,string,string)", p0, p1, p2, p3));
    }

    function log(string memory p0, address p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,string,bool)", p0, p1, p2, p3));
    }

    function log(string memory p0, address p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,string,address)", p0, p1, p2, p3));
    }

    function log(string memory p0, address p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,bool,uint256)", p0, p1, p2, p3));
    }

    function log(string memory p0, address p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,bool,string)", p0, p1, p2, p3));
    }

    function log(string memory p0, address p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,bool,bool)", p0, p1, p2, p3));
    }

    function log(string memory p0, address p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,bool,address)", p0, p1, p2, p3));
    }

    function log(string memory p0, address p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,address,uint256)", p0, p1, p2, p3));
    }

    function log(string memory p0, address p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,address,string)", p0, p1, p2, p3));
    }

    function log(string memory p0, address p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,address,bool)", p0, p1, p2, p3));
    }

    function log(string memory p0, address p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,address,address)", p0, p1, p2, p3));
    }

    function log(bool p0, uint256 p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256,uint256)", p0, p1, p2, p3));
    }

    function log(bool p0, uint256 p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256,string)", p0, p1, p2, p3));
    }

    function log(bool p0, uint256 p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256,bool)", p0, p1, p2, p3));
    }

    function log(bool p0, uint256 p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256,address)", p0, p1, p2, p3));
    }

    function log(bool p0, uint256 p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string,uint256)", p0, p1, p2, p3));
    }

    function log(bool p0, uint256 p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string,string)", p0, p1, p2, p3));
    }

    function log(bool p0, uint256 p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string,bool)", p0, p1, p2, p3));
    }

    function log(bool p0, uint256 p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string,address)", p0, p1, p2, p3));
    }

    function log(bool p0, uint256 p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool,uint256)", p0, p1, p2, p3));
    }

    function log(bool p0, uint256 p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool,string)", p0, p1, p2, p3));
    }

    function log(bool p0, uint256 p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool,bool)", p0, p1, p2, p3));
    }

    function log(bool p0, uint256 p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool,address)", p0, p1, p2, p3));
    }

    function log(bool p0, uint256 p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address,uint256)", p0, p1, p2, p3));
    }

    function log(bool p0, uint256 p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address,string)", p0, p1, p2, p3));
    }

    function log(bool p0, uint256 p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address,bool)", p0, p1, p2, p3));
    }

    function log(bool p0, uint256 p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address,address)", p0, p1, p2, p3));
    }

    function log(bool p0, string memory p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256,uint256)", p0, p1, p2, p3));
    }

    function log(bool p0, string memory p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256,string)", p0, p1, p2, p3));
    }

    function log(bool p0, string memory p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256,bool)", p0, p1, p2, p3));
    }

    function log(bool p0, string memory p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256,address)", p0, p1, p2, p3));
    }

    function log(bool p0, string memory p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,string,uint256)", p0, p1, p2, p3));
    }

    function log(bool p0, string memory p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,string,string)", p0, p1, p2, p3));
    }

    function log(bool p0, string memory p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,string,bool)", p0, p1, p2, p3));
    }

    function log(bool p0, string memory p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,string,address)", p0, p1, p2, p3));
    }

    function log(bool p0, string memory p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,uint256)", p0, p1, p2, p3));
    }

    function log(bool p0, string memory p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,string)", p0, p1, p2, p3));
    }

    function log(bool p0, string memory p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,bool)", p0, p1, p2, p3));
    }

    function log(bool p0, string memory p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,address)", p0, p1, p2, p3));
    }

    function log(bool p0, string memory p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,address,uint256)", p0, p1, p2, p3));
    }

    function log(bool p0, string memory p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,address,string)", p0, p1, p2, p3));
    }

    function log(bool p0, string memory p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,address,bool)", p0, p1, p2, p3));
    }

    function log(bool p0, string memory p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,address,address)", p0, p1, p2, p3));
    }

    function log(bool p0, bool p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256,uint256)", p0, p1, p2, p3));
    }

    function log(bool p0, bool p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256,string)", p0, p1, p2, p3));
    }

    function log(bool p0, bool p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256,bool)", p0, p1, p2, p3));
    }

    function log(bool p0, bool p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256,address)", p0, p1, p2, p3));
    }

    function log(bool p0, bool p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,uint256)", p0, p1, p2, p3));
    }

    function log(bool p0, bool p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,string)", p0, p1, p2, p3));
    }

    function log(bool p0, bool p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,bool)", p0, p1, p2, p3));
    }

    function log(bool p0, bool p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,address)", p0, p1, p2, p3));
    }

    function log(bool p0, bool p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,uint256)", p0, p1, p2, p3));
    }

    function log(bool p0, bool p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,string)", p0, p1, p2, p3));
    }

    function log(bool p0, bool p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,bool)", p0, p1, p2, p3));
    }

    function log(bool p0, bool p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,address)", p0, p1, p2, p3));
    }

    function log(bool p0, bool p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,uint256)", p0, p1, p2, p3));
    }

    function log(bool p0, bool p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,string)", p0, p1, p2, p3));
    }

    function log(bool p0, bool p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,bool)", p0, p1, p2, p3));
    }

    function log(bool p0, bool p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,address)", p0, p1, p2, p3));
    }

    function log(bool p0, address p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256,uint256)", p0, p1, p2, p3));
    }

    function log(bool p0, address p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256,string)", p0, p1, p2, p3));
    }

    function log(bool p0, address p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256,bool)", p0, p1, p2, p3));
    }

    function log(bool p0, address p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256,address)", p0, p1, p2, p3));
    }

    function log(bool p0, address p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,string,uint256)", p0, p1, p2, p3));
    }

    function log(bool p0, address p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,string,string)", p0, p1, p2, p3));
    }

    function log(bool p0, address p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,string,bool)", p0, p1, p2, p3));
    }

    function log(bool p0, address p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,string,address)", p0, p1, p2, p3));
    }

    function log(bool p0, address p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,uint256)", p0, p1, p2, p3));
    }

    function log(bool p0, address p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,string)", p0, p1, p2, p3));
    }

    function log(bool p0, address p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,bool)", p0, p1, p2, p3));
    }

    function log(bool p0, address p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,address)", p0, p1, p2, p3));
    }

    function log(bool p0, address p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,address,uint256)", p0, p1, p2, p3));
    }

    function log(bool p0, address p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,address,string)", p0, p1, p2, p3));
    }

    function log(bool p0, address p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,address,bool)", p0, p1, p2, p3));
    }

    function log(bool p0, address p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,address,address)", p0, p1, p2, p3));
    }

    function log(address p0, uint256 p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256,uint256)", p0, p1, p2, p3));
    }

    function log(address p0, uint256 p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256,string)", p0, p1, p2, p3));
    }

    function log(address p0, uint256 p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256,bool)", p0, p1, p2, p3));
    }

    function log(address p0, uint256 p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256,address)", p0, p1, p2, p3));
    }

    function log(address p0, uint256 p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,string,uint256)", p0, p1, p2, p3));
    }

    function log(address p0, uint256 p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,string,string)", p0, p1, p2, p3));
    }

    function log(address p0, uint256 p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,string,bool)", p0, p1, p2, p3));
    }

    function log(address p0, uint256 p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,string,address)", p0, p1, p2, p3));
    }

    function log(address p0, uint256 p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool,uint256)", p0, p1, p2, p3));
    }

    function log(address p0, uint256 p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool,string)", p0, p1, p2, p3));
    }

    function log(address p0, uint256 p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool,bool)", p0, p1, p2, p3));
    }

    function log(address p0, uint256 p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool,address)", p0, p1, p2, p3));
    }

    function log(address p0, uint256 p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,address,uint256)", p0, p1, p2, p3));
    }

    function log(address p0, uint256 p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,address,string)", p0, p1, p2, p3));
    }

    function log(address p0, uint256 p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,address,bool)", p0, p1, p2, p3));
    }

    function log(address p0, uint256 p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,address,address)", p0, p1, p2, p3));
    }

    function log(address p0, string memory p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,uint256,uint256)", p0, p1, p2, p3));
    }

    function log(address p0, string memory p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,uint256,string)", p0, p1, p2, p3));
    }

    function log(address p0, string memory p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,uint256,bool)", p0, p1, p2, p3));
    }

    function log(address p0, string memory p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,uint256,address)", p0, p1, p2, p3));
    }

    function log(address p0, string memory p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,string,uint256)", p0, p1, p2, p3));
    }

    function log(address p0, string memory p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,string,string)", p0, p1, p2, p3));
    }

    function log(address p0, string memory p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,string,bool)", p0, p1, p2, p3));
    }

    function log(address p0, string memory p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,string,address)", p0, p1, p2, p3));
    }

    function log(address p0, string memory p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,bool,uint256)", p0, p1, p2, p3));
    }

    function log(address p0, string memory p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,bool,string)", p0, p1, p2, p3));
    }

    function log(address p0, string memory p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,bool,bool)", p0, p1, p2, p3));
    }

    function log(address p0, string memory p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,bool,address)", p0, p1, p2, p3));
    }

    function log(address p0, string memory p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,address,uint256)", p0, p1, p2, p3));
    }

    function log(address p0, string memory p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,address,string)", p0, p1, p2, p3));
    }

    function log(address p0, string memory p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,address,bool)", p0, p1, p2, p3));
    }

    function log(address p0, string memory p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,address,address)", p0, p1, p2, p3));
    }

    function log(address p0, bool p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256,uint256)", p0, p1, p2, p3));
    }

    function log(address p0, bool p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256,string)", p0, p1, p2, p3));
    }

    function log(address p0, bool p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256,bool)", p0, p1, p2, p3));
    }

    function log(address p0, bool p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256,address)", p0, p1, p2, p3));
    }

    function log(address p0, bool p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,string,uint256)", p0, p1, p2, p3));
    }

    function log(address p0, bool p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,string,string)", p0, p1, p2, p3));
    }

    function log(address p0, bool p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,string,bool)", p0, p1, p2, p3));
    }

    function log(address p0, bool p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,string,address)", p0, p1, p2, p3));
    }

    function log(address p0, bool p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,uint256)", p0, p1, p2, p3));
    }

    function log(address p0, bool p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,string)", p0, p1, p2, p3));
    }

    function log(address p0, bool p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,bool)", p0, p1, p2, p3));
    }

    function log(address p0, bool p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,address)", p0, p1, p2, p3));
    }

    function log(address p0, bool p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,address,uint256)", p0, p1, p2, p3));
    }

    function log(address p0, bool p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,address,string)", p0, p1, p2, p3));
    }

    function log(address p0, bool p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,address,bool)", p0, p1, p2, p3));
    }

    function log(address p0, bool p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,address,address)", p0, p1, p2, p3));
    }

    function log(address p0, address p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,uint256,uint256)", p0, p1, p2, p3));
    }

    function log(address p0, address p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,uint256,string)", p0, p1, p2, p3));
    }

    function log(address p0, address p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,uint256,bool)", p0, p1, p2, p3));
    }

    function log(address p0, address p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,uint256,address)", p0, p1, p2, p3));
    }

    function log(address p0, address p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,string,uint256)", p0, p1, p2, p3));
    }

    function log(address p0, address p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,string,string)", p0, p1, p2, p3));
    }

    function log(address p0, address p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,string,bool)", p0, p1, p2, p3));
    }

    function log(address p0, address p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,string,address)", p0, p1, p2, p3));
    }

    function log(address p0, address p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,bool,uint256)", p0, p1, p2, p3));
    }

    function log(address p0, address p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,bool,string)", p0, p1, p2, p3));
    }

    function log(address p0, address p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,bool,bool)", p0, p1, p2, p3));
    }

    function log(address p0, address p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,bool,address)", p0, p1, p2, p3));
    }

    function log(address p0, address p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,address,uint256)", p0, p1, p2, p3));
    }

    function log(address p0, address p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,address,string)", p0, p1, p2, p3));
    }

    function log(address p0, address p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,address,bool)", p0, p1, p2, p3));
    }

    function log(address p0, address p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,address,address)", p0, p1, p2, p3));
    }

}