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
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC1155/ERC1155.sol)

pragma solidity ^0.8.0;

import "./IERC1155.sol";
import "./IERC1155Receiver.sol";
import "./extensions/IERC1155MetadataURI.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of the basic standard multi-token.
 * See https://eips.ethereum.org/EIPS/eip-1155
 * Originally based on code by Enjin: https://github.com/enjin/erc-1155
 *
 * _Available since v3.1._
 */
contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {
    using Address for address;

    // Mapping from token ID to account balances
    mapping(uint256 => mapping(address => uint256)) private _balances;

    // Mapping from account to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
    string private _uri;

    /**
     * @dev See {_setURI}.
     */
    constructor(string memory uri_) {
        _setURI(uri_);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC1155MetadataURI-uri}.
     *
     * This implementation returns the same URI for *all* token types. It relies
     * on the token type ID substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * Clients calling this function must replace the `\{id\}` substring with the
     * actual token type ID.
     */
    function uri(uint256) public view virtual override returns (string memory) {
        return _uri;
    }

    /**
     * @dev See {IERC1155-balanceOf}.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
        require(account != address(0), "ERC1155: address zero is not a valid owner");
        return _balances[id][account];
    }

    /**
     * @dev See {IERC1155-balanceOfBatch}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {
        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    /**
     * @dev See {IERC1155-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC1155-isApprovedForAll}.
     */
    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[account][operator];
    }

    /**
     * @dev See {IERC1155-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner or approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }

    /**
     * @dev See {IERC1155-safeBatchTransferFrom}.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner or approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _afterTokenTransfer(operator, from, to, ids, amounts, data);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _afterTokenTransfer(operator, from, to, ids, amounts, data);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    /**
     * @dev Sets a new URI for all token types, by relying on the token type ID
     * substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * By this mechanism, any occurrence of the `\{id\}` substring in either the
     * URI or any of the amounts in the JSON file at said URI will be replaced by
     * clients with the token type ID.
     *
     * For example, the `https://token-cdn-domain/\{id\}.json` URI would be
     * interpreted by clients as
     * `https://token-cdn-domain/000000000000000000000000000000000000000000000000000000000004cce0.json`
     * for token type ID 0x4cce0.
     *
     * See {uri}.
     *
     * Because these URIs cannot be meaningfully represented by the {URI} event,
     * this function emits no events.
     */
    function _setURI(string memory newuri) internal virtual {
        _uri = newuri;
    }

    /**
     * @dev Creates `amount` tokens of token type `id`, and assigns them to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        _balances[id][to] += amount;
        emit TransferSingle(operator, address(0), to, id, amount);

        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

        _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_mint}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    /**
     * @dev Destroys `amount` tokens of token type `id` from `from`
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `from` must have at least `amount` tokens of token type `id`.
     */
    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }

        emit TransferSingle(operator, from, address(0), id, amount);

        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_burn}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     */
    function _burnBatch(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
        }

        emit TransferBatch(operator, from, address(0), ids, amounts);

        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC1155: setting approval status for self");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `ids` and `amounts` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    /**
     * @dev Hook that is called after any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `id` and `amount` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155Receiver.onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non-ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non-ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
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
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC1155/extensions/ERC1155Burnable.sol)

pragma solidity ^0.8.0;

import "../ERC1155.sol";

/**
 * @dev Extension of {ERC1155} that allows token holders to destroy both their
 * own tokens and those that they have been approved to use.
 *
 * _Available since v3.1._
 */
abstract contract ERC1155Burnable is ERC1155 {
    function burn(
        address account,
        uint256 id,
        uint256 value
    ) public virtual {
        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()),
            "ERC1155: caller is not token owner or approved"
        );

        _burn(account, id, value);
    }

    function burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory values
    ) public virtual {
        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()),
            "ERC1155: caller is not token owner or approved"
        );

        _burnBatch(account, ids, values);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC1155/extensions/ERC1155Supply.sol)

pragma solidity ^0.8.0;

import "../ERC1155.sol";

/**
 * @dev Extension of ERC1155 that adds tracking of total supply per id.
 *
 * Useful for scenarios where Fungible and Non-fungible tokens have to be
 * clearly identified. Note: While a totalSupply of 1 might mean the
 * corresponding is an NFT, there is no guarantees that no other token with the
 * same id are not going to be minted.
 */
abstract contract ERC1155Supply is ERC1155 {
    mapping(uint256 => uint256) private _totalSupply;

    /**
     * @dev Total amount of tokens in with a given id.
     */
    function totalSupply(uint256 id) public view virtual returns (uint256) {
        return _totalSupply[id];
    }

    /**
     * @dev Indicates whether any token exist with a given id, or not.
     */
    function exists(uint256 id) public view virtual returns (bool) {
        return ERC1155Supply.totalSupply(id) > 0;
    }

    /**
     * @dev See {ERC1155-_beforeTokenTransfer}.
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);

        if (from == address(0)) {
            for (uint256 i = 0; i < ids.length; ++i) {
                _totalSupply[ids[i]] += amounts[i];
            }
        }

        if (to == address(0)) {
            for (uint256 i = 0; i < ids.length; ++i) {
                uint256 id = ids[i];
                uint256 amount = amounts[i];
                uint256 supply = _totalSupply[id];
                require(supply >= amount, "ERC1155: burn amount exceeds totalSupply");
                unchecked {
                    _totalSupply[id] = supply - amount;
                }
            }
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/extensions/IERC1155MetadataURI.sol)

pragma solidity ^0.8.0;

import "../IERC1155.sol";

/**
 * @dev Interface of the optional ERC1155MetadataExtension interface, as defined
 * in the https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155MetadataURI is IERC1155 {
    /**
     * @dev Returns the URI for token type `id`.
     *
     * If the `\{id\}` substring is present in the URI, it must be replaced by
     * clients with the actual token type ID.
     */
    function uri(uint256 id) external view returns (string memory);
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

pragma solidity ^0.8.24;

import {AccessControl} from "openzeppelin-contracts/contracts/access/AccessControl.sol";

import {ICreditEnforcer} from "src/interfaces/ICreditEnforcer.sol";

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

import {ITermIssuer} from "src/interfaces/ITermIssuer.sol";
import {IPegStabilityModule} from "src/interfaces/IPegStabilityModule.sol";
import {ISavingModule} from "src/interfaces/ISavingModule.sol";

import {IAssetAdapter} from "src/adapters/AssetAdapter.sol";

contract CreditEnforcer is AccessControl, ICreditEnforcer {
    bytes32 public constant MANAGER =
        keccak256(abi.encode("credit.enforcer.manager"));

    bytes32 public constant SUPERVISOR =
        keccak256(abi.encode("credit.enforcer.supervisor"));

    struct AssetAdapter {
        bool set;
        uint256 index;
    }

    IERC20 public immutable underlying;

    ITermIssuer public immutable termIssuer;

    ISavingModule public immutable sm;
    IPegStabilityModule public immutable psm;

    uint256 public duration = 365 days;

    uint256 public assetRatioMin = type(uint256).max;
    uint256 public equityRatioMin = type(uint256).max;
    uint256 public liquidityRatioMin = type(uint256).max;

    uint256 public smDebtMax = 0;
    uint256 public psmDebtMax = 0;

    mapping(uint256 => uint256) public termDebtMax;

    address[] public assetAdapterList;
    mapping(address => AssetAdapter) public assetAdapterMap;

    constructor(
        address admin,
        IERC20 underlying_,
        ITermIssuer termIssuer_,
        IPegStabilityModule psm_,
        ISavingModule sm_
    ) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);

        underlying = underlying_;
        termIssuer = termIssuer_;
        psm = psm_;
        sm = sm_;
    }

    /// @notice Issue the stablecoin, check the debt cap and solvency
    /// @param amount Transfer amount of the underlying
    function mintStablecoin(uint256 amount) external returns (uint256) {
        return _mintStablecoin(msg.sender, msg.sender, amount);
    }

    /// @notice Issue the stablecoin to a recipient, check the debt cap and
    /// solvency
    /// @param amount Transfer amount of the underlying
    function mintStablecoin(
        address to,
        uint256 amount
    ) external returns (uint256) {
        return _mintStablecoin(msg.sender, to, amount);
    }

    function _mintStablecoin(
        address from,
        address to,
        uint256 amount
    ) private returns (uint256) {
        bool valid;
        string memory message;

        (valid, message) = _checkPSMDebtMax(amount);
        require(valid, message);

        psm.mint(from, to, amount);

        (valid, message) = _checkRatios();
        require(valid, message);

        return amount;
    }

    /// @notice Issue the savingcoin to the sender, check the debt cap and
    /// solvency
    /// @param amount Underlying amount
    function mintSavingcoin(uint256 amount) external returns (uint256) {
        return _mintSavingcoin(msg.sender, msg.sender, amount);
    }

    /// @notice Issue the savingcoin to a recipient, check the debt cap and
    /// solvency
    /// @param to Receiver address
    /// @param amount Underlying amount
    function mintSavingcoin(
        address to,
        uint256 amount
    ) external returns (uint256) {
        return _mintSavingcoin(msg.sender, to, amount);
    }

    function _mintSavingcoin(
        address from,
        address to,
        uint256 amount
    ) private returns (uint256) {
        bool valid;
        string memory message;

        (valid, message) = _checkSMDebtMax(amount);
        require(valid, message);

        sm.mint(from, to, amount);

        (valid, message) = _checkRatios();
        require(valid, message);

        return amount;
    }

    /// @notice Issue the term to the sender, check the debt cap and solvency
    /// @param id Term index
    /// @param amount Term mint balance
    function mintTerm(uint256 id, uint256 amount) external returns (uint256) {
        return _mintTerm(msg.sender, msg.sender, id, amount);
    }

    /// @notice Issue the term to a recipient, check the debt cap and solvency
    /// @param to Receiver address
    /// @param id Term index
    /// @param amount Term mint balance
    function mintTerm(
        address to,
        uint256 id,
        uint256 amount
    ) external returns (uint256) {
        return _mintTerm(msg.sender, to, id, amount);
    }

    function _mintTerm(
        address from,
        address to,
        uint256 id,
        uint256 amount
    ) private returns (uint256) {
        bool valid;
        string memory message;

        (valid, message) = _checkTermDebtMax(id, amount);
        require(valid, message);

        uint256 cost = termIssuer.mint(from, to, id, amount);

        (valid, message) = _checkRatios();
        require(valid, message);

        return cost;
    }

    /// @notice Move capital (underlying) to a fund and check solvency
    /// @param index Fund index
    /// @param amount Underlying amount
    function allocate(
        uint256 index,
        uint256 amount
    ) external onlyRole(MANAGER) {
        require(
            _assetAdapterLength() > index,
            "CE: Asset Adapter index out of bounds"
        );

        address assetAdapterAddress = assetAdapterList[index];

        psm.withdraw(amount);

        underlying.approve(assetAdapterAddress, amount);
        IAssetAdapter(assetAdapterAddress).allocate(amount);
    }

    /// @notice Move capital (underlying) from a fund and check solvency
    /// @param index Fund index
    /// @param amount Underlying amount
    function withdraw(
        uint256 index,
        uint256 amount
    ) external onlyRole(MANAGER) {
        require(
            _assetAdapterLength() > index,
            "CE: Asset Adapter index out of bounds"
        );

        address assetAdapterAddress = assetAdapterList[index];
        IAssetAdapter(assetAdapterAddress).withdraw(amount);

        underlying.approve(address(psm), amount);
        psm.allocate(amount);
    }

    /// @notice Submit a deposit order on a fund and check solvency
    /// @param index Fund index
    /// @param amount Underlying amount
    function deposit(uint256 index, uint256 amount) external onlyRole(MANAGER) {
        require(
            _assetAdapterLength() > index,
            "CE: Asset Adapter index out of bounds"
        );

        bool valid;
        string memory message;

        address assetAdapterAddress = assetAdapterList[index];
        IAssetAdapter(assetAdapterAddress).deposit(amount);

        (valid, message) = _checkRatios();
        require(valid, message);
    }

    /// @notice Submit a redemption order on a fund and check solvency
    /// @param index Fund index
    /// @param amount Underlying amount
    function redeem(uint256 index, uint256 amount) external onlyRole(MANAGER) {
        require(
            _assetAdapterLength() > index,
            "CE: Asset Adapter index out of bounds"
        );

        bool valid;
        string memory message;

        address assetAdapterAddress = assetAdapterList[index];
        IAssetAdapter(assetAdapterAddress).redeem(amount);

        (valid, message) = _checkRatios();
        require(valid, message);
    }

    /// @notice Check PSM's max debt status if specified amount of underlying stablecoin was swapped
    /// @param amount amount of underlying stablecoin
    /// @return valid If swapping with the amount is valid in terms of PSM debt
    /// @return message error message
    function checkPSMDebtMax(
        uint256 amount
    ) external view returns (bool, string memory) {
        return _checkPSMDebtMax(amount);
    }

    function _checkPSMDebtMax(
        uint256 amount
    ) private view returns (bool, string memory) {
        if (amount + psm.underlyingBalance() > psmDebtMax) {
            return (false, "CE: amount exceeds PSM debt max");
        }

        return (true, "");
    }

    /// @notice Check SM's max debt status if specifie amount of underlying stablecoin was swapped
    /// @param amount amount of underlying stablecoin
    /// @return valid If swapping with the amount is valid in terms of SM debt
    /// @return message error message
    function checkSMDebtMax(
        uint256 amount
    ) external view returns (bool, string memory) {
        return _checkSMDebtMax(amount);
    }

    function _checkSMDebtMax(
        uint256 amount
    ) private view returns (bool, string memory) {
        if (amount + sm.totalDebt() > smDebtMax) {
            return (false, "CE: amount exceeds SM debt max");
        }

        return (true, "");
    }

    /// @notice Check specific Term's max debt status if specifie amount of that term was minted
    /// @param id Term identifier
    /// @param amount term amount
    /// @return valid If minting the term with the amount is valid in terms of it's max debt
    /// @return message error message
    function checkTermDebtMax(
        uint256 id,
        uint256 amount
    ) external view returns (bool, string memory) {
        return _checkTermDebtMax(id, amount);
    }

    function _checkTermDebtMax(
        uint256 id,
        uint256 amount
    ) private view returns (bool, string memory) {
        if (amount + termIssuer.totalSupply(id) > _getTermDebtMax(id)) {
            return (false, "CE: amount exceeds term minter debt max");
        }

        return (true, "");
    }

    /// @notice Check balance sheet ratios
    /// @return valid If ratios are valid
    /// @return message error message
    function checkRatios() external view returns (bool, string memory) {
        return _checkRatios();
    }

    function _checkRatios() private view returns (bool, string memory) {
        if (assetRatioMin > _assetRatio(0)) {
            return (false, "CE: invalid asset ratio");
        }

        if (equityRatioMin > _equityRatio(0)) {
            return (false, "CE: invalid equity ratio");
        }

        if (liquidityRatioMin > _liquidityRatio(duration)) {
            return (false, "CE: invalid liquidity ratio");
        }

        return (true, "");
    }

    /// @notice Get asset ratio
    /// @return ratio asset ratio
    function assetRatio() external view returns (uint256) {
        return _assetRatio(0);
    }

    function _assetRatio(uint256) private view returns (uint256) {
        uint256 assets_ = _assets();
        uint256 liabilities_ = _liabilities();

        if (assets_ == 0) return 0;
        if (liabilities_ == 0) return type(uint256).max;

        return (assets_ * 1e6) / liabilities_;
    }

    /// @notice Get equity ratio
    /// @return ratio equity ratio
    function equityRatio() external view returns (uint256) {
        return _equityRatio(0);
    }

    function _equityRatio(uint256) private view returns (uint256) {
        uint256 equity_ = _equity();
        uint256 riskWeightedAssets_ = _riskWeightedAssets();

        if (equity_ == 0) return 0;
        if (riskWeightedAssets_ == 0) return type(uint256).max;

        return (equity_ * 1e6) / riskWeightedAssets_;
    }

    /// @notice Get liquidity ratio
    /// @return ratio liquidity ratio
    function liquidityRatio() external view returns (uint256) {
        return _liquidityRatio(duration);
    }

    function _liquidityRatio(uint256 duration_) private view returns (uint256) {
        uint256 assets_ = _shortTermAssets(duration_);
        uint256 liabilities_ = _shortTermLiabilities(duration_);

        if (assets_ == 0) return 0;
        if (liabilities_ == 0) return type(uint256).max;

        return (assets_ * 1e6) / liabilities_;
    }

    /// @notice Get short term assets
    /// @return assets short term assets
    function shortTermAssets() external view returns (uint256) {
        return _shortTermAssets(duration);
    }

    function _shortTermAssets(
        uint256 _duration
    ) private view returns (uint256 stAssets) {
        uint256 length = assetAdapterList.length;

        for (uint256 i = 0; i < length; i++) {
            IAssetAdapter assetAdapter = IAssetAdapter(assetAdapterList[i]);

            if (_duration <= assetAdapter.duration()) continue;

            stAssets += assetAdapter.totalValue();
        }

        stAssets += psm.totalValue();
    }

    /// @notice Get extended assets
    /// @return assets extended assets
    function extendedAssets() external view returns (uint256) {
        return _extendedAssets(duration);
    }

    function _extendedAssets(
        uint256 _duration
    ) private view returns (uint256 eAssets) {
        uint256 length = assetAdapterList.length;

        for (uint256 i = 0; i < length; i++) {
            IAssetAdapter assetAdapter = IAssetAdapter(assetAdapterList[i]);

            if (_duration >= assetAdapter.duration()) continue;

            eAssets += assetAdapter.totalValue();
        }
    }

    /// @notice Get short term liabilities
    /// @return liabilities short term liabilities
    function shortTermLiabilities() external view returns (uint256) {
        return _shortTermLiabilities(duration);
    }

    function _shortTermLiabilities(
        uint256 duration_
    ) private view returns (uint256 totalLiabilities) {
        totalLiabilities = _liabilities();
        totalLiabilities -= _extendedLiabilities(duration_);

        // NOTE: The `extendedLiabilities` can not be greater than the
        // `liabilities`, but we may want to do a check here anyways, just in
        // case.
    }

    /// @notice Get extended liabilities
    /// @return liabilities extended liabilities
    function extendedLiabilities(
        uint256 duration_
    ) external view returns (uint256) {
        return _extendedLiabilities(duration_);
    }

    function _extendedLiabilities(
        uint256 duration_
    ) private view returns (uint256) {
        uint256 latestID = termIssuer.latestID();
        uint256 earliestID = termIssuer.earliestID();

        uint256 sum = 0;
        for (uint256 i = earliestID; i <= latestID; i++) {
            // MTS - BTS > duration

            // prettier-ignore
            if (termIssuer.maturityTimestamp(i) <= block.timestamp + duration_) {
                continue;
            }

            sum += termIssuer.totalSupply(i);
        }

        return sum;
    }

    /// @notice Get capital at risk
    /// @return riskWeightedAssets capital at risk
    function riskWeightedAssets() external view returns (uint256) {
        return _riskWeightedAssets();
    }

    function _riskWeightedAssets() private view returns (uint256) {
        uint256 total = 0;

        uint256 length = assetAdapterList.length;
        for (uint256 i = 0; i < length; i++) {
            total += IAssetAdapter(assetAdapterList[i]).totalRiskValue();
        }

        return total + psm.totalRiskValue();
    }

    /// @notice Get equity
    /// @return equity equity
    function equity() external view returns (uint256) {
        return _equity();
    }

    function _equity() private view returns (uint256) {
        uint256 assets_ = _assets();
        uint256 liabilities_ = _liabilities();

        return liabilities_ > assets_ ? 0 : assets_ - liabilities_;
    }

    /// @notice Get assets
    /// @return assets assets
    function assets() external view returns (uint256) {
        return _assets();
    }

    function _assets() private view returns (uint256) {
        uint256 total = 0;

        uint256 length = assetAdapterList.length;
        for (uint256 i = 0; i < length; i++) {
            total += IAssetAdapter(assetAdapterList[i]).totalValue();
        }

        return total + psm.totalValue();
    }

    /// @notice Get liabilities
    /// @return liabilities liabilities
    function liabilities() external view returns (uint256) {
        return _liabilities();
    }

    function _liabilities() private view returns (uint256) {
        return sm.rusdTotalLiability() + termIssuer.totalDebt();
    }

    /// @notice Set a length of time that determines long term and short term
    /// @param duration_ Length of time used to determine long and short term
    /// balance sheet items
    function setDuration(uint256 duration_) external onlyRole(MANAGER) {
        duration = duration_;
    }

    /// @notice Set a floor for the asset ratio
    /// @param assetRatioMin_ Value assigned to the minimum asset ratio
    function setAssetRatioMin(
        uint256 assetRatioMin_
    ) external onlyRole(MANAGER) {
        assetRatioMin = assetRatioMin_;
    }

    /// @notice Set a floor for the equity ratio
    /// @param equityRatioMin_ Value assigned to the minimum equity ratio
    function setEquityRatioMin(
        uint256 equityRatioMin_
    ) external onlyRole(MANAGER) {
        equityRatioMin = equityRatioMin_;
    }

    /// @notice Set a floor for the liquidity ratio
    /// @param liquidityRatioMin_ Value assigned to the minimum liquidity ratio
    function setLiquidityRatioMin(
        uint256 liquidityRatioMin_
    ) external onlyRole(MANAGER) {
        liquidityRatioMin = liquidityRatioMin_;
    }

    /// @notice Set a ceiling for the maximum amount of underlying stablecoin
    /// that can be held in the PSM at any given time
    /// @param psmDebtMax_ Maximum underlying balance
    function setPSMDebtMax(uint256 psmDebtMax_) external onlyRole(MANAGER) {
        psmDebtMax = psmDebtMax_;
    }

    /// @notice Set a ceiling for the maximum amount of native stablecoin
    /// that can be held in the SM at any given time
    /// @param smDebtMax_ Maximum stablecoin deposit
    function setSMDebtMax(uint256 smDebtMax_) external onlyRole(MANAGER) {
        smDebtMax = smDebtMax_;
    }

    /// @notice Set a ceiling for the maximum amount of term debt that can be
    /// issued for any given maturity
    /// @param id Term index
    /// @param amount Highest permitted debt value
    function setTermDebtMax(
        uint256 id,
        uint256 amount
    ) external onlyRole(MANAGER) {
        _setTermDebtMax(id, amount);
    }

    function _setTermDebtMax(uint256 id, uint256 amount) private {
        termDebtMax[id] = amount;
    }

    /// @notice Get the maximum amount of term debt that can be issued for specified term id
    /// @param id term identifier
    /// @return amount term's max debt
    function getTermDebtMax(uint256 id) external view returns (uint256) {
        return _getTermDebtMax(id);
    }

    function _getTermDebtMax(uint256 id) private view returns (uint256) {
        return termDebtMax[id];
    }

    function assetAdapterLength() external view returns (uint256) {
        return _assetAdapterLength();
    }

    function _assetAdapterLength() private view returns (uint256) {
        return assetAdapterList.length;
    }

    /// @notice Get a list of Asset Adapters
    /// @param startIndex Start index
    /// @param length Number of Asset Adapters to return
    /// @return list List of Asset Adapters
    function getAssetAdapterList(
        uint256 startIndex,
        uint256 length
    ) external view returns (address[] memory) {
        return _getAssetAdapterList(startIndex, length);
    }

    function _getAssetAdapterList(
        uint256 startIndex,
        uint256 length
    ) private view returns (address[] memory) {
        address[] memory list = new address[](length);

        for (uint256 i = startIndex; i < startIndex + length; i++) {
            list[i - startIndex] = assetAdapterList[i];
        }

        return list;
    }

    /// @notice Get a Asset Adapter
    /// @param adapter Asset Adapter address
    /// @return assetAdapter Asset Adapter
    function getAssetAdapter(
        address adapter
    ) external view returns (AssetAdapter memory) {
        return _getAssetAdapter(adapter);
    }

    function _getAssetAdapter(
        address adapter
    ) private view returns (AssetAdapter memory) {
        return assetAdapterMap[adapter];
    }

    /// @notice Add a Asset Adapter
    /// @param adapter Asset Adapter address
    function addAssetAdapter(address adapter) external onlyRole(SUPERVISOR) {
        AssetAdapter storage assetAdapter = assetAdapterMap[adapter];

        require(!assetAdapter.set, "CE: adapter already set");

        assetAdapterList.push(adapter);

        assetAdapter.set = true;
        assetAdapter.index = _assetAdapterLength() - 1;
    }

    /// @notice Remove a Asset Adapter
    /// @param adapter Asset Adapter address
    function removeAssetAdapter(address adapter) external onlyRole(SUPERVISOR) {
        AssetAdapter storage assetAdapter = assetAdapterMap[adapter];

        require(assetAdapter.set, "CE: adapter not set");

        uint256 lastIndex = _assetAdapterLength() - 1;
        address key = assetAdapterList[lastIndex];

        uint256 index = assetAdapter.index;

        assetAdapterList[index] = assetAdapterList[lastIndex];
        assetAdapterMap[key].index = index;

        assetAdapterList.pop();

        delete assetAdapterMap[adapter];
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {AccessControl} from "openzeppelin-contracts/contracts/access/AccessControl.sol";

import {ITerm} from "src/interfaces/ITerm.sol";

import {ERC1155} from "openzeppelin-contracts/contracts/token/ERC1155/ERC1155.sol";
import {ERC1155Supply} from "openzeppelin-contracts/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import {ERC1155Burnable} from "openzeppelin-contracts/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";

contract Term is AccessControl, ERC1155Supply, ERC1155Burnable {
    bytes32 public constant MINTER = keccak256(abi.encode("term.minter"));

    constructor(address admin, string memory uri) ERC1155(uri) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
    }

    /// @notice Increase specific token's total supply
    /// @param to address to increment the token balance
    /// @param id token identifier
    /// @param amount quantity of token added
    function mint(
        address to,
        uint256 id,
        uint256 amount
    ) external onlyRole(MINTER) {
        _mint(to, id, amount, "");
    }

    /// @notice Increase multiple token's total supply in batch
    /// @param to address to increment the token balance
    /// @param ids array of token identifiers
    /// @param amounts array of quantity of token added
    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts
    ) external onlyRole(MINTER) {
        _mintBatch(to, ids, amounts, "");
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC1155, AccessControl) returns (bool) {
        // TODO: Combine with `AccessControl`

        return super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override(ERC1155, ERC1155Supply) {
        ERC1155Supply._beforeTokenTransfer(
            operator,
            from,
            to,
            ids,
            amounts,
            data
        );
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {AccessControl} from "openzeppelin-contracts/contracts/access/AccessControl.sol";

import {AggregatorV3Interface} from "chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import {IFund} from "src/interfaces/IFund.sol";
import {IAssetAdapter} from "src/interfaces/IAssetAdapter.sol";
import {IOracle} from "src/interfaces/IOracle.sol";

contract UnderlyingAssetPrice is IOracle {
    AggregatorV3Interface aggregator;

    constructor(address _aggregator) {
        aggregator = AggregatorV3Interface(_aggregator);
    }

    function latestAnswer() external view returns (int256) {
        int256 answer;
        uint256 updatedAt;

        (, answer, , updatedAt, ) = aggregator.latestRoundData();

        return (block.timestamp > 1.1 days + updatedAt) ? int256(1e8) : answer;
    }
}

contract AssetPrice is IOracle {
    IFund public immutable fund;

    constructor(address fundAddress) {
        fund = IFund(fundAddress);
    }

    function latestAnswer() external view returns (int256) {
        uint256 currentPrice = fund.currentPrice();

        return
            currentPrice > uint256(type(int256).max)
                ? type(int256).max
                : int256(currentPrice);
    }
}

contract AssetAdapter is AccessControl, IAssetAdapter {
    bytes32 public constant MANAGER =
        keccak256(abi.encode("asset.adapter.manager"));

    bytes32 public constant CONTROLLER =
        keccak256(abi.encode("asset.adapter.controller"));

    uint256 public immutable duration;

    IOracle public immutable underlyingPriceOracle;
    IOracle public immutable fundPriceOracle;

    uint256 public underlyingRiskWeight = 0e6; // 100% = 1000000
    uint256 public fundRiskWeight = 0e6; // 100% = 1000000

    IFund public immutable fund;
    IERC20 public immutable underlying;

    uint8 public immutable DECIMAL_FACTOR;

    constructor(
        address admin,
        address underlyingAddr,
        address fundAddr,
        address underlyingPriceOracleAddr,
        address fundPriceOracleAddr,
        uint256 _duration
    ) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);

        duration = _duration;

        underlying = IERC20(underlyingAddr);
        DECIMAL_FACTOR = IERC20Metadata(address(underlying)).decimals();

        fund = IFund(fundAddr);

        underlyingPriceOracle = IOracle(underlyingPriceOracleAddr);
        fundPriceOracle = IOracle(fundPriceOracleAddr);
    }

    /// @notice Deposit underlying into the contract
    /// @param amount underlying amount
    function allocate(uint256 amount) external {
        underlying.transferFrom(msg.sender, address(this), amount);

        emit Allocate(msg.sender, amount, block.timestamp);
    }

    /// @notice Withdraw underlying from the contract
    /// @param amount underlying amount
    function withdraw(uint256 amount) external onlyRole(CONTROLLER) {
        underlying.transfer(msg.sender, amount);

        emit Withdraw(msg.sender, amount, block.timestamp);
    }

    function deposit(uint256 amount) external onlyRole(CONTROLLER) {
        underlying.approve(address(fund), amount);

        fund.deposit(amount);

        emit Deposit(msg.sender, amount, block.timestamp);
    }

    function redeem(uint256 amount) external onlyRole(CONTROLLER) {
        fund.approve(address(fund), amount);

        fund.redeem(amount);

        emit Redeem(msg.sender, amount, block.timestamp);
    }

    /// @notice Set risk weight of pool's junior token
    /// @param riskWeight value for the risk weight
    function setUnderlyingRiskWeight(
        uint256 riskWeight
    ) external onlyRole(MANAGER) {
        require(1e6 > riskWeight, "FA: Risk Weight can not be above 100%");

        underlyingRiskWeight = riskWeight;

        emit UnderlyingRiskWeightUpdate(riskWeight, block.timestamp);
    }

    /// @notice Set risk weight of pool's junior token
    /// @param riskWeight value for the risk weight
    function setFundRiskWeight(uint256 riskWeight) external onlyRole(MANAGER) {
        require(1e6 > riskWeight, "FA: Risk Weight can not be above 100%");

        fundRiskWeight = riskWeight;

        emit FundRiskWeightUpdate(riskWeight, block.timestamp);
    }

    /// @notice Total value held by this contract
    /// @return Asset value of the contract in USD
    function totalValue() external view returns (uint256) {
        uint256 total = 0;

        total += _underlyingTotalValue();
        total += _fundTotalValue();

        return total;
    }

    /// @notice Risk adjusted value held by this contract
    function totalRiskValue() external view returns (uint256) {
        uint256 total = 0;

        total += _underlyingTotalRiskValue();
        total += _fundTotalRiskValue();

        return total;
    }

    function underlyingTotalRiskValue() external view returns (uint256) {
        return _underlyingTotalRiskValue();
    }

    function _underlyingTotalRiskValue() private view returns (uint256) {
        uint256 assets;

        (, assets) = fund.userDeposits(address(this));

        return _underlyingRiskValue(assets + _underlyingBalance());
    }

    function underlyingRiskValue(
        uint256 amount
    ) external view returns (uint256) {
        return _underlyingRiskValue(amount);
    }

    function _underlyingRiskValue(
        uint256 amount
    ) private view returns (uint256) {
        return (underlyingRiskWeight * _underlyingValue(amount)) / 1e6;
    }

    function underlyingTotalValue() external view returns (uint256) {
        return _underlyingTotalValue();
    }

    function _underlyingTotalValue() private view returns (uint256) {
        uint256 assets;

        (, assets) = fund.userDeposits(address(this));

        return _underlyingValue(assets + _underlyingBalance());
    }

    function underlyingValue(uint256 amount) external view returns (uint256) {
        return _underlyingValue(amount);
    }

    function _underlyingValue(uint256 amount) private view returns (uint256) {
        return
            (_underlyingPriceOracleLatestAnswer() *
                amount *
                (10 ** (18 - DECIMAL_FACTOR))) / 1e8;
    }

    function underlyingBalance() external view returns (uint256) {
        return _underlyingBalance();
    }

    function _underlyingBalance() private view returns (uint256) {
        return underlying.balanceOf(address(this));
    }

    function fundTotalRiskValue() external view returns (uint256) {
        return _fundTotalRiskValue();
    }

    function _fundTotalRiskValue() private view returns (uint256) {
        uint256 shares;

        (, shares) = fund.userRedemptions(address(this));

        return _fundRiskValue(shares + _fundBalance());
    }

    function fundRiskValue(uint256 amount) external view returns (uint256) {
        return _fundRiskValue(amount);
    }

    function _fundRiskValue(uint256 amount) private view returns (uint256) {
        return (fundRiskWeight * _fundValue(amount)) / 1e6;
    }

    function fundTotalValue() external view returns (uint256) {
        return _fundTotalValue();
    }

    function _fundTotalValue() private view returns (uint256) {
        uint256 shares;

        (, shares) = fund.userRedemptions(address(this));

        return _fundValue(shares + _fundBalance());
    }

    function fundValue(uint256 amount) external view returns (uint256) {
        return _fundValue(amount);
    }

    function _fundValue(uint256 amount) private view returns (uint256) {
        return (_fundPriceOracleLatestAnswer() * amount) / 1e8;
    }

    function fundBalance() external view returns (uint256) {
        return _fundBalance();
    }

    function _fundBalance() private view returns (uint256) {
        return fund.balanceOf(address(this));
    }

    function _underlyingPriceOracleLatestAnswer()
        private
        view
        returns (uint256)
    {
        int256 latestAnswer = underlyingPriceOracle.latestAnswer();

        return latestAnswer > 0 ? uint256(latestAnswer) : 0;
    }

    function _fundPriceOracleLatestAnswer() private view returns (uint256) {
        int256 latestAnswer = fundPriceOracle.latestAnswer();

        return latestAnswer > 0 ? uint256(latestAnswer) : 0;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {IOracle} from "src/interfaces/IOracle.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

interface IAssetAdapter {
    event Allocate(address indexed signer, uint256 amount, uint256 timestamp);
    event Withdraw(address indexed signer, uint256 amount, uint256 timestamp);
    event Deposit(address indexed signer, uint256 amount, uint256 timestamp);
    event Redeem(address indexed signer, uint256 amount, uint256 timestamp);
    event UnderlyingRiskWeightUpdate(uint256 riskWeight, uint256 timestamp);
    event FundRiskWeightUpdate(uint256 riskWeight, uint256 timestamp);

    function duration() external view returns (uint256);

    function underlyingPriceOracle() external view returns (IOracle);

    function fundPriceOracle() external view returns (IOracle);

    function underlyingRiskWeight() external view returns (uint256);

    function fundRiskWeight() external view returns (uint256);

    //! function fund() external view returns (uint256); DIFFERS IN `ASSETADAPTER` AND MORPHO ADAPTERS

    function underlying() external view returns (IERC20);

    function allocate(uint256) external;

    function withdraw(uint256) external;

    function deposit(uint256) external;

    function redeem(uint256) external;

    function totalValue() external view returns (uint256);

    function totalRiskValue() external view returns (uint256);

    function underlyingTotalRiskValue() external view returns (uint256);

    function underlyingRiskValue(uint256) external view returns (uint256);

    function underlyingTotalValue() external view returns (uint256);

    function underlyingValue(uint256) external view returns (uint256);

    function underlyingBalance() external view returns (uint256);

    function fundTotalRiskValue() external view returns (uint256);

    function fundRiskValue(uint256) external view returns (uint256);

    function fundTotalValue() external view returns (uint256);

    function fundValue(uint256) external view returns (uint256);

    function fundBalance() external view returns (uint256);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {IPegStabilityModule} from "./IPegStabilityModule.sol";
import {ITermIssuer} from "./ITermIssuer.sol";

interface ICreditEnforcer {
    function mintTerm(uint256, uint256) external returns (uint256);

    function psm() external view returns (IPegStabilityModule);

    function termIssuer() external view returns (ITermIssuer);
}
// SPDX-License-Identifier: MIT

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

pragma solidity ^0.8.24;

interface IFund is IERC20 {
    function deposit(uint256) external;

    function redeem(uint256) external;

    function userDeposits(address) external view returns (uint256, uint256);

    function userRedemptions(address) external view returns (uint256, uint256);

    function currentPrice() external view returns (uint256);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

interface IOracle {
    function latestAnswer() external view returns (int256);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

interface IPegStabilityModule {
    event Allocate(address indexed signer, uint256 amount, uint256 timestamp);
    event Withdraw(address indexed signer, uint256 amount, uint256 timestamp);
    event UnderlyingRiskWeightUpdate(uint256 riskWeight, uint256 timestamp);

    event Mint(
        address indexed from,
        address indexed to,
        uint256 amount,
        uint256 timestamp
    );

    event Redeem(
        address indexed from,
        address indexed to,
        uint256 amount,
        uint256 timestamp
    );

    function allocate(uint256) external;

    function withdraw(uint256) external;

    function mint(address, address, uint256) external;

    function totalValue() external view returns (uint256);

    function totalRiskValue() external view returns (uint256);

    function underlyingBalance() external view returns (uint256);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

interface ISavingModule {
    event Mint(
        address indexed from,
        address indexed to,
        uint256 mintAmount,
        uint256 burnAmount,
        uint256 timestamp
    );

    event Redeem(
        address indexed from,
        address indexed to,
        uint256 redeemAmount,
        uint256 burnAmount,
        uint256 timestamp
    );

    event Update(
        uint256 compoundFactorAccum,
        uint256 currentRate,
        uint256 rate,
        uint256 timestamp
    );

    function mint(address, address, uint256) external;

    function rusdTotalLiability() external view returns (uint256);

    function totalDebt() external view returns (uint256);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

interface ITerm {
    function mint(address, uint256, uint256) external;

    function burn(address, uint256, uint256) external;

    function totalSupply(uint256) external view returns (uint256);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {IToken} from "./IToken.sol";
import {ITerm} from "../Term.sol";

interface ITermIssuer {
    event MintTerm(
        address indexed from,
        address indexed to,
        uint256 indexed termId,
        uint256 principle,
        uint256 cost,
        uint256 timestamp
    );

    event RedeemTerm(
        address indexed from,
        address indexed to,
        uint256 indexed termId,
        uint256 principle,
        uint256 timestamp
    );

    function mint(
        address,
        address,
        uint256,
        uint256
    ) external returns (uint256);

    function redeem(uint256, uint256) external;

    function redeem(address, uint256, uint256) external;

    function applyDiscount(
        uint256,
        uint256,
        uint256
    ) external view returns (uint256);

    function getDiscountRate(uint256 id) external view returns (uint256);

    function latestID() external view returns (uint256);

    function earliestID() external view returns (uint256);

    function maturityTimestamp(uint256) external view returns (uint256);

    function totalSupply(uint256) external view returns (uint256);

    function totalDebt() external view returns (uint256);

    function rusd() external view returns (IToken);

    function term() external view returns (ITerm);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

interface IToken is IERC20 {
    function mint(address, uint256) external;

    function burnFrom(address, uint256) external;
}