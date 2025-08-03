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
// OpenZeppelin Contracts (last updated v4.6.0) (interfaces/IERC2981.sol)

pragma solidity ^0.8.0;

import "../utils/introspection/IERC165.sol";

/**
 * @dev Interface for the NFT Royalty Standard.
 *
 * A standardized way to retrieve royalty payment information for non-fungible tokens (NFTs) to enable universal
 * support for royalty payments across all NFT marketplaces and ecosystem participants.
 *
 * _Available since v4.5._
 */
interface IERC2981 is IERC165 {
    /**
     * @dev Returns how much royalty is owed and to whom, based on a sale price that may be denominated in any unit of
     * exchange. The royalty amount is denominated and should be paid in that same unit of exchange.
     */
    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)

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
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

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
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

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
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

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
    function setApprovalForAll(address operator, bool _approved) external;

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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

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
// OpenZeppelin Contracts (last updated v4.7.0) (token/common/ERC2981.sol)

pragma solidity ^0.8.0;

import "../../interfaces/IERC2981.sol";
import "../../utils/introspection/ERC165.sol";

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
 *
 * _Available since v4.5._
 */
abstract contract ERC2981 is IERC2981, ERC165 {
    struct RoyaltyInfo {
        address receiver;
        uint96 royaltyFraction;
    }

    RoyaltyInfo private _defaultRoyaltyInfo;
    mapping(uint256 => RoyaltyInfo) private _tokenRoyaltyInfo;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC165) returns (bool) {
        return interfaceId == type(IERC2981).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @inheritdoc IERC2981
     */
    function royaltyInfo(uint256 _tokenId, uint256 _salePrice) public view virtual override returns (address, uint256) {
        RoyaltyInfo memory royalty = _tokenRoyaltyInfo[_tokenId];

        if (royalty.receiver == address(0)) {
            royalty = _defaultRoyaltyInfo;
        }

        uint256 royaltyAmount = (_salePrice * royalty.royaltyFraction) / _feeDenominator();

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
        require(feeNumerator <= _feeDenominator(), "ERC2981: royalty fee will exceed salePrice");
        require(receiver != address(0), "ERC2981: invalid receiver");

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
    function _setTokenRoyalty(
        uint256 tokenId,
        address receiver,
        uint96 feeNumerator
    ) internal virtual {
        require(feeNumerator <= _feeDenominator(), "ERC2981: royalty fee will exceed salePrice");
        require(receiver != address(0), "ERC2981: Invalid parameters");

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

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "erc721bo/contracts/extensions/ERC721BONonburnable.sol";
import "./ITokenUriProvider.sol";
import "./IDaisy.sol";

contract Daisy is ERC721BONonburnable, ERC2981, AccessControl, IDaisy {
    using Strings for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;

    address private _owner;
    bytes32 public constant CHANGE_ROYALTY_ROLE = keccak256("CHANGE_ROYALTY_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PROVIDER_ADMIN_ROLE = keccak256("PROVIDER_ADMIN_ROLE");
    bytes32 public constant OWNER_ADMIN_ROLE = keccak256("OWNER_ADMIN_ROLE");

    EnumerableSet.AddressSet private _uriProviders;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(string memory name,
        string memory symbol,
        uint96 feeNumerator,
        address payee,
        address defaultProvider) ERC721BO(name, symbol) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(PROVIDER_ADMIN_ROLE, msg.sender);
        _setupRole(OWNER_ADMIN_ROLE, msg.sender);
        _setupRole(CHANGE_ROYALTY_ROLE, msg.sender);

        _setDefaultRoyalty(payee, feeNumerator);
        addUriProvider(defaultProvider);
    }

    function setDefaultRoyalty(uint96 feeNumerator, address payee) public virtual onlyRole(CHANGE_ROYALTY_ROLE) {
        _setDefaultRoyalty(payee, feeNumerator);
    }

    function changeOwnership(address newOwner) public virtual onlyRole(OWNER_ADMIN_ROLE) {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721BO, ERC2981, AccessControl, IERC165) returns (bool) {
        return interfaceId == type(IDaisy).interfaceId || super.supportsInterface(interfaceId);
    }

    function addUriProvider(address provider) public virtual onlyRole(PROVIDER_ADMIN_ROLE) {
        require(provider != address(0), "Daisy: provider is the zero address");

        uint256 providerCount = _uriProviders.length();
        if (providerCount > 0)
        {
            address p = _uriProviders.at(providerCount - 1);
            uint256 startId = ITokenUriProvider(p).startId();
            uint256 maxSupply = ITokenUriProvider(p).maxSupply();
            require(startId + maxSupply == totalMinted(), "Daisy: invalid start id");
        }

        _uriProviders.add(provider);
    }

    function uriProvider(uint256 index) public view virtual returns (address) {
        return address(uint160(_uriProviders.at(index)));
    }

    function uriProviderCount() public view virtual returns (uint256) {
        return _uriProviders.length();
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "Daisy: URI query for nonexistent token");

        uint256 count;
        uint256 providerCount = _uriProviders.length();
        for (uint256 i = 0; i < providerCount; i++) {
            ITokenUriProvider provider = ITokenUriProvider(_uriProviders.at(i));
            uint256 a = count + provider.maxSupply();
            if (tokenId < a)
                return provider.tokenURI(tokenId);

            count = a;
        }

        revert("ERC721URIStorage: URI query for nonexistent token");
    }

    function safeMint(address to, uint256 count, bytes memory data) external onlyRole(MINTER_ROLE) {
        uint256 start = totalSupply();

        uint256 providerCount = _uriProviders.length();
        require(providerCount > 0, "Daisy: no uri provider");
        address provider = _uriProviders.at(providerCount - 1);
        require(provider != address(0), "Daisy: provider is the zero address");

        uint256 startId = ITokenUriProvider(provider).startId();
        uint256 maxSupply = ITokenUriProvider(provider).maxSupply();
        require(startId <= start && start + count <= startId + maxSupply, "Daisy: invalid count");

        _safeMint(to, count, data);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface IDaisy is IERC165 {
    function safeMint(address to, uint256 count, bytes memory data) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITokenUriProvider {
    function maxSupply() external view returns (uint256);

    function startId() external view returns (uint256);

    function tokenURI(uint256 tokenId) external view returns (string memory);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Library for ownership flag table.
 */
library Assets {
    struct Pages {
        mapping(uint256 => uint256) _inner;
    }

    /**
     * @dev Returns page key by `pageNo` and `owner`.
     */
    function getPageKeyBy(uint256 pageNo, address owner) internal pure returns (uint256) {
        require(type(uint32).max >= pageNo, "ERC721BO Assets: pageNo must be less than 2^32");
        unchecked {
            return (uint256(uint160(owner)) << 32) | uint32(pageNo);
        }
    }

    /**
     * @dev Returns ownership flags by `owner` and `pageNo`.
     */
    function page(Pages storage pages, address owner, uint256 pageNo) internal view returns (uint256) {
        return pages._inner[getPageKeyBy(pageNo, owner)];
    }

    /**
     * @dev Returns whether the `owner` owns the `tokenId`.
     * Returns true if owned, false otherwise.
     */
    function exists(Pages storage pages, address owner, uint256 tokenId) internal view returns (bool) {
        unchecked {
            uint256 key = getPageKeyBy(tokenId >> 8, owner);
            return (pages._inner[key] >> (tokenId & 0xFF)) & 1 == 1;
        }
    }

    /**
     * @dev Set the ownership flag of the `tokenId` of `from` to false and the ownership flag of `to` to true.
     */
    function transfer(Pages storage pages, address from, address to, uint256 tokenId) internal {
        unset(pages, from, tokenId);
        set(pages, to, tokenId);
    }

    /**
     * @dev Set the ownership flag of the `tokenId` of `owner` to true.
     */
    function set(Pages storage pages, address owner, uint256 tokenId) internal {
        unchecked {
            uint256 key = getPageKeyBy(tokenId >> 8, owner);
            pages._inner[key] |= (1 << (tokenId & 0xFF));
        }
    }

    /**
     * @dev Override the ownership flag of `owner` from `from` to `from` + `count` with true.
     */
    function setRange(Pages storage pages, address owner, uint256 from, uint256 count) internal {
        if (count == 0)
            return;

        uint256 to = from + count - 1;
        uint256 fromPageNo = from >> 8;
        uint256 toPageNo = to >> 8;

        unchecked {
            if (fromPageNo != toPageNo)
            {
                uint256 fromPage = getPageKeyBy(fromPageNo, owner);
                uint256 toPage = getPageKeyBy(toPageNo, owner);

                uint256 i = fromPage;
                do {
                    uint256 mask = type(uint256).max;
                    if (i == toPage)
                        mask >>= 0xFF - (to & 0xFF);

                    if (i == fromPage)
                        mask -= (1 << (from & 0xFF)) - 1;

                    pages._inner[i] |= mask;
                    ++i;
                } while (i <= toPage);
            }
            else{
                uint256 mask = type(uint256).max;
                mask >>= 0xFF - (to & 0xFF);
                mask -= (1 << (from & 0xFF)) - 1;
                pages._inner[getPageKeyBy(fromPageNo, owner)] |= mask;
            }
        }
    }

    /**
     * @dev Set the ownership flag of the `tokenId` of `owner` to false.
     */
    function unset(Pages storage pages, address owner, uint256 tokenId) internal {
        unchecked {
            uint256 key = getPageKeyBy(tokenId >> 8, owner);
            pages._inner[key] &= ~(1 << (tokenId & 0xFF));
        }
    }

    /**
     * @dev Override the ownership flag of `owner` from `from` to `from` + `count` with false.
     */
    function unsetRange(Pages storage pages, address owner, uint256 from, uint256 count) internal {
        if (count == 0)
            return;

        uint256 to = from + count - 1;
        uint256 fromPageNo = from >> 8;
        uint256 toPageNo = to >> 8;

        unchecked {
            if (fromPageNo != toPageNo)
            {
                uint256 fromPage = getPageKeyBy(fromPageNo, owner);
                uint256 toPage = getPageKeyBy(toPageNo, owner);

                uint256 i = fromPage;
                do {
                    uint256 mask = type(uint256).max;
                    if (i == toPage)
                        mask >>= 0xFF - (to & 0xFF);

                    if (i == fromPage)
                        mask -= (1 << (from & 0xFF)) - 1;

                    pages._inner[i] &= ~mask;
                    ++i;
                } while (i <= toPage);
            }
            else{
                uint256 mask = type(uint256).max;
                mask >>= 0xFF - (to & 0xFF);
                mask -= (1 << (from & 0xFF)) - 1;
                pages._inner[getPageKeyBy(fromPageNo, owner)] &= ~mask;
            }
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to bits.
 */
library Bits {
    uint256 internal constant MASK_BIT_COUNT_ALL_3   = 0x3333333333333333333333333333333333333333333333333333333333333333;
    uint256 internal constant MASK_BIT_COUNT_ALL_5   = 0x5555555555555555555555555555555555555555555555555555555555555555;
    uint256 internal constant MASK_BIT_COUNT_LOW_4   = 0x0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F;
    uint256 internal constant MASK_BIT_COUNT_LOW_8   = 0x00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF;
    uint256 internal constant MASK_BIT_COUNT_LOW_16  = 0x0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF;
    uint256 internal constant MASK_BIT_COUNT_LOW_32  = 0x00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF;
    uint256 internal constant MASK_BIT_COUNT_LOW_64  = 0x0000000000000000FFFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF;
    uint256 internal constant MASK_BIT_COUNT_LOW_128 = 0x00000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    /**
     * @dev Returns the number of bits set to true in the given `value`.
     */
    function popCount(uint256 flags) internal pure returns (uint256) {
        if (flags == 0)
            return 0;

        assembly {
            //Add every 1 bits in parallel.
            //flags = (flags & MASK_BIT_COUNT_ALL_5) + ((flags >> 1) & MASK_BIT_COUNT_ALL_5);
            flags := add(and(flags, MASK_BIT_COUNT_ALL_5), and(shr(1, flags), MASK_BIT_COUNT_ALL_5))

            //Add every 2 bits in parallel.
            //flags = (flags & MASK_BIT_COUNT_ALL_3) + ((flags >> 2) & MASK_BIT_COUNT_ALL_3);
            flags := add(and(flags, MASK_BIT_COUNT_ALL_3), and(shr(2, flags), MASK_BIT_COUNT_ALL_3))

            //Add every 4 bits in parallel.
            //flags = (flags & MASK_BIT_COUNT_LOW_4) + ((flags >> 4) & MASK_BIT_COUNT_LOW_4);
            flags := add(and(flags, MASK_BIT_COUNT_LOW_4), and(shr(4, flags), MASK_BIT_COUNT_LOW_4))

            //Add every 8 bits in parallel.
            //flags = (flags & MASK_BIT_COUNT_LOW_8) + ((flags >> 8) & MASK_BIT_COUNT_LOW_8);
            flags := add(and(flags, MASK_BIT_COUNT_LOW_8), and(shr(8, flags), MASK_BIT_COUNT_LOW_8))

            //Add every 16 bits in parallel.
            //flags = (flags & MASK_BIT_COUNT_LOW_16) + ((flags >> 16) & MASK_BIT_COUNT_LOW_16);
            flags := add(and(flags, MASK_BIT_COUNT_LOW_16), and(shr(16, flags), MASK_BIT_COUNT_LOW_16))

            //Add every 32 bits in parallel.
            //flags = (flags & MASK_BIT_COUNT_LOW_32) + ((flags >> 32) & MASK_BIT_COUNT_LOW_32);
            flags := add(and(flags, MASK_BIT_COUNT_LOW_32), and(shr(32, flags), MASK_BIT_COUNT_LOW_32))

            //Add every 64 bits in parallel.
            //flags = (flags & MASK_BIT_COUNT_LOW_64) + ((flags >> 64) & MASK_BIT_COUNT_LOW_64);
            flags := add(and(flags, MASK_BIT_COUNT_LOW_64), and(shr(64, flags), MASK_BIT_COUNT_LOW_64))

            //Add every 128 bits in parallel.
            //flags = (flags & MASK_BIT_COUNT_LOW_128) + ((flags >> 128) & MASK_BIT_COUNT_LOW_128);
            flags := add(and(flags, MASK_BIT_COUNT_LOW_128), and(shr(128, flags), MASK_BIT_COUNT_LOW_128))
       }
        return flags;
    }

    /**
     * @dev Returns the index of the given `value` counting from the right, with the `n`th bit set to true.
     */
    function indexOf(uint256 flags, uint256 n) internal pure returns (uint256 rank) {
        require(n <= 0xFF, "Bits: index out of bounds");

        if (flags == 0)
        {
            rank = type(uint256).max;
        }
        else
        {
            rank = 0;

            assembly {
                //n = n + 1;
                n := add(n, 1)

                /* At each step, the range of the addition target is increased and the results are reserved. */
                //uint256 flags0 = flags;
                let flags0 := flags

                //uint256 flags1 = (flags0 & MASK_BIT_COUNT_ALL_5) + ((flags0 >> 1) & MASK_BIT_COUNT_ALL_5);
                let flags1 := add(and(flags0, MASK_BIT_COUNT_ALL_5), and(shr(1, flags0), MASK_BIT_COUNT_ALL_5))

                //uint256 flags2 = (flags1 & MASK_BIT_COUNT_ALL_3) + ((flags1 >> 2) & MASK_BIT_COUNT_ALL_3);
                let flags2 := add(and(flags1, MASK_BIT_COUNT_ALL_3), and(shr(2, flags1), MASK_BIT_COUNT_ALL_3))

                //uint256 flags3 = (flags2 & MASK_BIT_COUNT_LOW_4) + ((flags2 >> 4) & MASK_BIT_COUNT_LOW_4);
                let flags3 := add(and(flags2, MASK_BIT_COUNT_LOW_4), and(shr(4, flags2), MASK_BIT_COUNT_LOW_4))

                //uint256 flags4 = (flags3 & MASK_BIT_COUNT_LOW_8) + ((flags3 >> 8) & MASK_BIT_COUNT_LOW_8);
                let flags4 := add(and(flags3, MASK_BIT_COUNT_LOW_8), and(shr(8, flags3), MASK_BIT_COUNT_LOW_8))

                //uint256 flags5 = (flags4 & MASK_BIT_COUNT_LOW_16) + ((flags4 >> 16) & MASK_BIT_COUNT_LOW_16);
                let flags5 := add(and(flags4, MASK_BIT_COUNT_LOW_16), and(shr(16, flags4), MASK_BIT_COUNT_LOW_16))

                //uint256 flags6 = (flags5 & MASK_BIT_COUNT_LOW_32) + ((flags5 >> 32) & MASK_BIT_COUNT_LOW_32);
                let flags6 := add(and(flags5, MASK_BIT_COUNT_LOW_32), and(shr(32, flags5), MASK_BIT_COUNT_LOW_32))

                //uint256 flags7 = (flags6 & MASK_BIT_COUNT_LOW_64) + ((flags6 >> 64) & MASK_BIT_COUNT_LOW_64);
                let flags7 := add(and(flags6, MASK_BIT_COUNT_LOW_64), and(shr(64, flags6), MASK_BIT_COUNT_LOW_64))


                /* Based on the step-by-step addition results, the index is identified by a binary search. */
                //flags7 & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
                let temp := and(flags7, MASK_BIT_COUNT_LOW_128)

                //if (n > temp) { rank += 128; n -= temp; }
                if gt(n, temp) { rank := add(rank, 128) n := sub(n, temp) }
                //temp = (flags6 >> rank) & 0xFFFFFFFFFFFFFFFF;
                temp := and(shr(rank, flags6), 0xFFFFFFFFFFFFFFFF)

                //if (n > temp) { rank += 64; n -= temp; }
                if gt(n, temp) { rank := add(rank, 64) n := sub(n, temp) }
                //temp = (flags5 >> rank) & 0xFFFFFFFF;
                temp := and(shr(rank, flags5), 0xFFFFFFFF)

                //if (n > temp) { rank += 32; n -= temp; }
                if gt(n, temp) { rank := add(rank, 32) n := sub(n, temp) }
                //temp = (flags4 >> rank) & 0xFFFF;
                temp := and(shr(rank, flags4), 0xFFFF)

                //if (n > temp) { rank += 16; n -= temp; }
                if gt(n, temp) { rank := add(rank, 16) n := sub(n, temp) }
                //temp = (flags3 >> rank) & 0xFF;
                temp := and(shr(rank, flags3), 0xFF)

                //if (n > temp) { rank += 8; n -= temp; }
                if gt(n, temp) { rank := add(rank, 8) n := sub(n, temp) }
                //temp = (flags2 >> rank) & 0x0F;
                temp := and(shr(rank, flags2), 0x0F)

                //if (n > temp) { rank += 4; n -= temp; }
                if gt(n, temp) { rank := add(rank, 4) n := sub(n, temp) }
                //temp = (flags1 >> rank) & 0x03;
                temp := and(shr(rank, flags1), 0x03)

                //if (n > temp) { rank += 2; n -= temp; }
                if gt(n, temp) { rank := add(rank, 2) n := sub(n, temp) }
                //temp = (flags0 >> rank) & 0x01;
                temp := and(shr(rank, flags0), 0x01)

                //if (n > temp) { rank += 1; }
                if gt(n, temp) { rank := add(rank, 1) }
            }
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Library for counter with initial value of non zero.
 */
library Counter {
    struct Minted {
        uint256 _inner;
    }

    /**
     * @dev Save `type(uint256).max` to save on gas costs for the first mint.
     * Zero to non-zero gas costs are less than zero to non-zero.
     */
    function initialize(Minted storage minted) internal {
        minted._inner = type(uint256).max;
    }

    /**
     * @dev Add `count` to the internal value.
     */
    function increment(Minted storage minted, uint256 count) internal {
        require(count > 0, "Counter: count must be greater than 0");
        uint256 t = minted._inner;
        uint256 incremented = t == type(uint256).max ? count : t + count;
        require(incremented != type(uint256).max, "Counter: overflow");
        minted._inner = incremented;
    }

    /**
     * @dev Returns the internal value.
     */
    function current(Minted storage minted) internal view returns (uint256) {
        uint256 t = minted._inner;
        return t == type(uint256).max ? 0 : t;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./IERC721BO.sol";
import "./Bits.sol";
import "./Assets.sol";
import "./Owners.sol";
import "./Counter.sol";

abstract contract ERC721BO is Context, IERC721BO {
    using Address for address;
    using Strings for uint256;
    using Bits for uint256;
    using Assets for Assets.Pages;
    using Owners for Owners.AddressSet;
    using Counter for Counter.Minted;

    uint256 private constant DEFAULT_MAX_TOKEN_COUNT = 1 << 16;

    //Burned tokens are stored as assets at address(1).
    address private constant BURN_ADDRESS = address(1);

    /**
     * @dev Token name.
     */
    string internal _name;

    /**
     * @dev Token symbol.
     */
    string internal _symbol;

    /**
     * @dev Total minted tokens count.
     * This counter is incremented on each token minting.
     * It is used to generate new token ids.
     * Initialized with `type(uint256).max` to reduce gas cost for first `SSTORE`.
     */
    Counter.Minted private _totalMints;

    /**
     * @dev Used to store token owners.
     * Store multiple owners in bulk with a lazy initialization mechanism.
     */
    Owners.AddressSet private _owners;

    /**
     * @dev Stores the ownership flag table for each owner.
     * `uint256` as one page, 256 ownerships can be stored on a single page.
     */
    Assets.Pages private _assets;

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
        _totalMints.initialize();
    }

    /**
     * @dev Returns true if this contract implements the interface defined by `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165 to learn more about how these ids are created.
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165) returns (bool) {
        return
        interfaceId == type(IERC165).interfaceId ||
        interfaceId == type(IERC721).interfaceId ||
        interfaceId == type(IERC721Enumerable).interfaceId ||
        interfaceId == type(IERC721Metadata).interfaceId;
    }

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        if (owner <= BURN_ADDRESS) revert InvalidAddress();
        return _balanceOf(owner);
    }

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        if (_totalMints.current() <= tokenId) revert NonexistentToken();
        address owner = _owners.ownerOf(tokenId);
        if (owner <= BURN_ADDRESS) revert NonexistentToken();
        return owner;
    }

    /**
     * @dev Returns the token collection name.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        if (!_exists(tokenId)) revert NonexistentToken();
        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing tokenURI. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

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
     * Emits an `Approval` event of ERC721.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721BO.ownerOf(tokenId);
        if (to == owner)
            revert CallerIsNotOwnerNorApproved();

        if (_msgSender() != owner && !isApprovedForAll(owner, _msgSender()))
            revert CallerIsNotOwnerNorApprovedForAll();

        _approve(owner, to, tokenId);
    }

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        if (!_exists(tokenId)) revert NonexistentToken();
        return _tokenApprovals[tokenId];
    }

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call transferFrom or safeTransferFrom for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an `ApprovalForAll` event of ERC721.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See setApprovalForAll
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use safeTransferFrom whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either approve or setApprovalForAll.
     *
     * Emits an `Transfer` event of ERC721.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        if (!_isApprovedOrOwner(_msgSender(), tokenId)) revert CallerIsNotOwnerNorApproved();
        _transfer(from, to, tokenId);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either approve or setApprovalForAll.
     * - If `to` refers to a smart contract, it must implement IERC721Receiver.onERC721Received, which is called upon a safe transfer.
     *
     * Emits an `Transfer` event of ERC721.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either approve or setApprovalForAll.
     * - If `to` refers to a smart contract, it must implement IERC721Receiver.onERC721Received, which is called upon a safe transfer.
     *
     * Emits an `Transfer` event of ERC721.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        if (!_isApprovedOrOwner(_msgSender(), tokenId)) revert CallerIsNotOwnerNorApproved();
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() public override view returns (uint256){
        return totalMinted() - totalBurnt();
    }

    /**
     * @dev Returns the total amount of burnt token by the contract.
     */
    function totalBurnt() public virtual view returns (uint256){
        return _balanceOf(BURN_ADDRESS);
    }

    /**
     * @dev Returns the total amount of minted token by the contract.
     */
    function totalMinted() public virtual view returns (uint256){
        return _totalMints.current();
    }

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with balanceOf to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public virtual override view returns (uint256){
        uint256 pageCount = _totalMints.current() >> 8;
        uint256 total = 0;

        uint256 i = 0;
        do {
            unchecked {
                uint256 page = _assets.page(owner, i);
                if (page == 0)
                {
                    ++i;
                    continue;
                }

                uint256 count = page.popCount();
                if (total + count > index)
                    return page.indexOf(index - total) + (i << 8);

                total += count;
                ++i;
            }
        } while (i <= pageCount);

        revert IndexOutOfRange();
    }

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with totalSupply to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) public virtual override view returns (uint256){
        uint256 totalMints = _totalMints.current();
        uint256 pageCount = totalMints >> 8;

        uint256 i = 0;
        uint256 popTotal = 0;
        uint256 tokenId = type(uint256).max;

        do {
            unchecked {
                uint256 page = ~_assets.page(BURN_ADDRESS, i);
                if (page == 0)
                {
                    ++i;
                    continue;
                }

                uint256 count = page.popCount();
                if (popTotal + count > index)
                {
                    tokenId = page.indexOf(index - popTotal) + (i << 8);
                    break;
                }

                popTotal += count;
                ++i;
            }
        } while (i <= pageCount);

        if (tokenId >= totalMints)
            revert IndexOutOfRange();

        return tokenId;
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to safeTransferFrom, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement IERC721Receiver.onERC721Received, which is called upon a safe transfer.
     *
     * Emits an `Transfer` event of ERC721.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        if (!_checkOnERC721Received(from, to, tokenId, _data)) revert TransferToNonERC721ReceiverImplementer();
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via approve or setApprovalForAll.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _totalMints.current() > tokenId && !_assets.exists(BURN_ADDRESS, tokenId);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        if (!_exists(tokenId)) revert NonexistentToken();
        if (_assets.exists(spender, tokenId))
            return true;

        address owner = ERC721BO.ownerOf(tokenId);

        // Direct reference to `_tokenApprovals` as it passes `_exists(tokenId)`.
        return (isApprovedForAll(owner, spender) || _tokenApprovals[tokenId] == spender);
    }

    function _safeMint(address to, uint256 quantity) internal virtual {
        _safeMint(to, quantity, "");
    }

    /**
     * @dev Same as `_safeMint`, with an additional `data` parameter which is
     * forwarded in IERC721Receiver.onERC721Received to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 quantity,
        bytes memory _data
    ) internal virtual {
        uint256 start = _totalMints.current();
        _mint(to, start, quantity);

        if (!to.isContract())
            return;

        // Implemented with reference to ERC721A
        // The possibility of overflow is unrealistic based on the `start + quantity` validation in `_mint`.
        unchecked {
            uint256 end = start + quantity;
            uint256 index = start;
            do {
                if (!_checkOnERC721Received(address(0), to, index, _data))
                    revert TransferToNonERC721ReceiverImplementer();
                ++index;
            } while (index <= end);
            // Reentrancy protection.
            if (start + quantity != end) revert();
        }
    }


    /**
     * @dev Safely re-mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement IERC721Receiver.onERC721Received, which is called upon a safe transfer.
     *
     * Emits an `Transfer` event of ERC721.
     */
    function _safeReMint(address to, uint256 tokenId) internal virtual {
        _safeReMint(to, tokenId, "");
    }

    /**
     * @dev Same as `_safeReMint`, with an additional `data` parameter which is
     * forwarded in IERC721Receiver.onERC721Received to contract recipients.
     */
    function _safeReMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _remint(to, tokenId);
        if (!_checkOnERC721Received(address(0), to, tokenId, _data))
            revert TransferToNonERC721ReceiverImplementer();
    }

    /**
     * @dev Batch mints `count` tokens and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use _safeMint whenever possible
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `quantity` mints count.
     *
      * Emits an `Transfer` event of ERC721.
     */
    function _mint(address to, uint256 quantity) internal virtual {
        uint256 start = _totalMints.current();
        _mint(to, start, quantity);
    }

    /**
     * @dev Batch mints `start` to `count` tokens and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use _safeMint whenever possible
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `start` number to start mints.
     * - `quantity` mints count.
     *
     * Emits an `Transfer` event of ERC721.
     */
    function _mint(address to, uint256 start, uint256 quantity) internal virtual {
        if (to <= BURN_ADDRESS)
            revert InvalidAddress();

        // Cannot mint more than a defined number of mints
        if (start + quantity > _getMaxTokenCount())
            revert ExceededMaxOfMint();

        _beforeTokenMint(address(0), to, start, quantity);

        _assets.setRange(to, start, quantity);
        _owners.mint(to, start, quantity);
        _totalMints.increment(quantity);

        // Unchecked as it is emit only.
        unchecked {
            uint256 i = 0;
            do {
                emit Transfer(address(0), to, start + i);
                ++i;
            } while (i < quantity);
        }

        _afterTokenMint(address(0), to, start, quantity);
    }

    /**
     * @dev Re-mints `tokenId` and transfers it to `to`.
     * The approval is cleared when the token is burned.
     *
     * WARNING: Usage of this method is discouraged, use _safeReMint whenever possible
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` must not exist and burnt.
     *
     * Emits an `Transfer` event of ERC721.
     */
    function _remint(address to, uint256 tokenId) internal virtual {
        if (to <= BURN_ADDRESS)
            revert InvalidAddress();

        // Burned tokens become the property of `BURN_ADDRESS`.
        if (!_assets.exists(BURN_ADDRESS, tokenId))
            revert TokenAlreadyMinted();

        _beforeTokenTransfer(address(0), to, tokenId);

        _assets.transfer(BURN_ADDRESS, to, tokenId);
        _owners.overwrite(tokenId, to);

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits an `Transfer` event of ERC721.
     */
    function _burn(uint256 tokenId) internal virtual {
        if(!_exists(tokenId))
            revert NonexistentToken();

        address owner = ERC721BO.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _clearApprove(owner, tokenId);

        //  Burned tokens are stored in the `BURN_ADDRESS` asset.
        _assets.transfer(owner, BURN_ADDRESS, tokenId);
        _owners.overwrite(tokenId, BURN_ADDRESS);

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to transferFrom, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits an `Transfer` event of ERC721.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        if (!_assets.exists(from, tokenId))
            revert TransferFromIncorrectOwner();

        if (to <= BURN_ADDRESS)
            revert InvalidAddress();

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _clearApprove(from, tokenId);

        _assets.transfer(from, to, tokenId);
        _owners.overwrite(tokenId, to);

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev Approval for `tokenId` from `from` to zero address.
     *
     * Emits an `Approval` event of ERC721.
     */
    function _clearApprove(address from, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = address(0);
        emit Approval(from, address(0), tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId` of `owner`
     *
     * Emits an `Approval` event of ERC721.
     */
    function _approve(address owner, address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an `ApprovalForAll` event of ERC721.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        if (owner == operator) revert ApproveToCaller();
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Returns the number of tokens in the `owner`'s account.
     * Note that no validation of the specified address is performed.
     */
    function _balanceOf(address owner) internal view returns (uint256) {
        uint256 pageCount = _totalMints.current() >> 8;
        uint256 balance = 0;

        // Counting Owner Flags.
        // The number of pages is calculated from the total mints.
        // Therefore, the max value of `balance` is `page count * 256` and it is impractical to overflow.
        unchecked {
            uint256 i = 0;
            do {
                balance += _assets.page(owner, i).popCount();
                ++i;
            } while (i <= pageCount);
        }
        return balance;
    }


    /**
     * @dev Returns the maximum of tokens that can be stored by the contract.
     */
    function _getMaxTokenCount() internal pure returns (uint256) {
        return DEFAULT_MAX_TOKEN_COUNT;
    }

    /**
     * @dev Internal function to invoke IERC721Receiver.onERC721Received on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert TransferToNonERC721ReceiverImplementer();
                } else {
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
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    function _beforeTokenMint(
        address from,
        address to,
        uint256 start,
        uint256 quantity
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    function _afterTokenMint(
        address from,
        address to,
        uint256 start,
        uint256 quantity
    ) internal virtual {}
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface IERC721BO is IERC165, IERC721Enumerable, IERC721Metadata{

    error NonexistentToken();
    error InvalidAddress();
    error CallerIsNotOwnerNorApproved();
    error CallerIsNotOwnerNorApprovedForAll();
    error IndexOutOfRange();
    error TransferToNonERC721ReceiverImplementer();
    error ExceededMaxOfMint();
    error TokenAlreadyMinted();
    error TransferFromIncorrectOwner();
    error ApproveToCaller();
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Library for owner list using delayed initialization mechanism.
 */
library Owners {
    struct AddressSet {
        mapping(uint256 => uint256) _inner;
    }

    /**
     * @dev Returns the owner of `tokenId`.
     */
    function ownerOf(AddressSet storage set, uint256 tokenId) internal view returns (address) {
        unchecked{
            uint256 i = tokenId;
            do {
                (address o, uint256 c) = unpack(set._inner[i]);
                if (o != address(0) && i + c > tokenId){
                    return o;
                }
                --i;
            } while (i != type(uint256).max);

            return address(0);
        }
    }

    /**
     * @dev Set `from` to `from + count` as tokens owned by the `owner`.
     */
    function mint(AddressSet storage set, address owner, uint256 from, uint256 count) internal {
        set._inner[from] = pack(owner, count);
    }

    /**
     * @dev Change the owner of `tokenId` to `owner`.
     */
    function overwrite(AddressSet storage set, uint256 tokenId, address owner) internal {
        (address o, uint256 c) = unpack(set._inner[tokenId]);
        set._inner[tokenId] = pack(owner, 1);
        if (o == address(0) || c <= 1)
            return;

        uint256 nextTokenId = tokenId + 1;
        if (unpackAddress(set._inner[nextTokenId]) == address(0))
            set._inner[nextTokenId] = pack(o, c - 1);
    }

    /**
     * @dev Returns the value of `owner` and `count` packed into a uint256 value.
     */
    function pack(address owner, uint256 count) private pure returns (uint256){
        require(type(uint32).max >= count, "ERC721BO Owners: count must be less than 2^32");
        // Unchecked because bitwise operations only.
        unchecked {
            return (uint256(uint160(owner)) << 32) | count;
        }
    }

    /**
     * @dev Returns `owner` and `count` from `packed`.
     */
    function unpack(uint256 packed) private pure returns (address owner, uint256 count){
        // Unchecked because bitwise operations only.
        unchecked {
            owner = address(uint160(packed >> 32));
            count = packed & type(uint32).max;
        }
    }

    /**
     * @dev Returns owner address from `packed`.
     */
    function unpackAddress(uint256 packed) private pure returns (address){
        // Unchecked because bitwise operations only.
        unchecked {
            return address(uint160(packed >> 32) & type(uint160).max);
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../ERC721BO.sol";

abstract contract ERC721BONonburnable is ERC721BO {

    function totalBurnt() public virtual override view returns (uint256){
        return 0;
    }

    function tokenByIndex(uint256 index) public virtual override view returns (uint256){
        if (index >= totalSupply()) revert IndexOutOfRange();
        return index;
    }

    function _exists(uint256 tokenId) internal view virtual override returns (bool) {
        return totalSupply() > tokenId;
    }

    function _remint(address, uint256) internal virtual override {
        revert("Not supported");
    }

    function _burn(uint256) internal virtual override {
        revert("Not supported");
    }
}