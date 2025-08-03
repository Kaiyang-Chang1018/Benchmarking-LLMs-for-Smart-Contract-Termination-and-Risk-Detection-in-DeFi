// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (interfaces/IERC2981.sol)

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
    function royaltyInfo(
        uint256 tokenId,
        uint256 salePrice
    ) external view returns (address receiver, uint256 royaltyAmount);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./extensions/IERC721Metadata.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/Strings.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

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
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _ownerOf(tokenId);
        require(owner != address(0), "ERC721: invalid token ID");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
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
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not token owner or approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        _requireMinted(tokenId);

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");
        _safeTransfer(from, to, tokenId, data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns the owner of the `tokenId`. Does NOT revert if token doesn't exist
     */
    function _ownerOf(uint256 tokenId) internal view virtual returns (address) {
        return _owners[tokenId];
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(address to, uint256 tokenId, bytes memory data) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
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
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId, 1);

        // Check that tokenId was not minted by `_beforeTokenTransfer` hook
        require(!_exists(tokenId), "ERC721: token already minted");

        unchecked {
            // Will not overflow unless all 2**256 token ids are minted to the same owner.
            // Given that tokens are minted one by one, it is impossible in practice that
            // this ever happens. Might change if we allow batch minting.
            // The ERC fails to describe this case.
            _balances[to] += 1;
        }

        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId, 1);
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
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId, 1);

        // Update ownership in case tokenId was transferred by `_beforeTokenTransfer` hook
        owner = ERC721.ownerOf(tokenId);

        // Clear approvals
        delete _tokenApprovals[tokenId];

        unchecked {
            // Cannot overflow, as that would require more tokens to be burned/transferred
            // out than the owner initially received through minting and transferring in.
            _balances[owner] -= 1;
        }
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId, 1);
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
    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId, 1);

        // Check that tokenId was not transferred by `_beforeTokenTransfer` hook
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");

        // Clear approvals from the previous owner
        delete _tokenApprovals[tokenId];

        unchecked {
            // `_balances[from]` cannot overflow for the same reason as described in `_burn`:
            // `from`'s balance is the number of token held, which is at least one before the current
            // transfer.
            // `_balances[to]` could overflow in the conditions described in `_mint`. That would require
            // all 2**256 token ids to be minted, which in practice is impossible.
            _balances[from] -= 1;
            _balances[to] += 1;
        }
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId, 1);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits an {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
     */
    function _setApprovalForAll(address owner, address operator, bool approved) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Reverts if the `tokenId` has not been minted yet.
     */
    function _requireMinted(uint256 tokenId) internal view virtual {
        require(_exists(tokenId), "ERC721: invalid token ID");
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    /// @solidity memory-safe-assembly
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
     * @dev Hook that is called before any token transfer. This includes minting and burning. If {ERC721Consecutive} is
     * used, the hook may be called as part of a consecutive (batch) mint, as indicated by `batchSize` greater than 1.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s tokens will be transferred to `to`.
     * - When `from` is zero, the tokens will be minted for `to`.
     * - When `to` is zero, ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     * - `batchSize` is non-zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 firstTokenId, uint256 batchSize) internal virtual {}

    /**
     * @dev Hook that is called after any token transfer. This includes minting and burning. If {ERC721Consecutive} is
     * used, the hook may be called as part of a consecutive (batch) mint, as indicated by `batchSize` greater than 1.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s tokens were transferred to `to`.
     * - When `from` is zero, the tokens were minted for `to`.
     * - When `to` is zero, ``from``'s tokens were burned.
     * - `from` and `to` are never both zero.
     * - `batchSize` is non-zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(address from, address to, uint256 firstTokenId, uint256 batchSize) internal virtual {}

    /**
     * @dev Unsafe write access to the balances, used by extensions that "mint" tokens using an {ownerOf} override.
     *
     * WARNING: Anyone calling this MUST ensure that the balances remain consistent with the ownership. The invariant
     * being that for any address `a` the value returned by `balanceOf(a)` must be equal to the number of tokens such
     * that `ownerOf(tokenId)` is `a`.
     */
    // solhint-disable-next-line func-name-mixedcase
    function __unsafe_increaseBalance(address account, uint256 amount) internal {
        _balances[account] += amount;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC721/IERC721.sol)

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
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
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
     * - The `operator` cannot be the caller.
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
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/extensions/ERC721Royalty.sol)

pragma solidity ^0.8.0;

import "../ERC721.sol";
import "../../common/ERC2981.sol";
import "../../../utils/introspection/ERC165.sol";

/**
 * @dev Extension of ERC721 with the ERC2981 NFT Royalty Standard, a standardized way to retrieve royalty payment
 * information.
 *
 * Royalty information can be specified globally for all token ids via {ERC2981-_setDefaultRoyalty}, and/or individually for
 * specific token ids via {ERC2981-_setTokenRoyalty}. The latter takes precedence over the first.
 *
 * IMPORTANT: ERC-2981 only specifies a way to signal royalty information and does not enforce its payment. See
 * https://eips.ethereum.org/EIPS/eip-2981#optional-royalty-payments[Rationale] in the EIP. Marketplaces are expected to
 * voluntarily pay royalties together with sales, but note that this standard is not yet widely supported.
 *
 * _Available since v4.5._
 */
abstract contract ERC721Royalty is ERC2981, ERC721 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC2981) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {ERC721-_burn}. This override additionally clears the royalty information for the token.
     */
    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);
        _resetTokenRoyalty(tokenId);
    }
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
// OpenZeppelin Contracts (last updated v4.9.0) (token/common/ERC2981.sol)

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
    function royaltyInfo(uint256 tokenId, uint256 salePrice) public view virtual override returns (address, uint256) {
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
    function _setTokenRoyalty(uint256 tokenId, address receiver, uint96 feeNumerator) internal virtual {
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
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
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
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title FREESTYLE H-AI-KU v2.3.4
 * @notice This is an extended and composable ERC-721 contract (ERC-721-ExC) for Matto's FREESTYLE H-AI-KU.
 * @author Matto AKA MonkMatto
 * @custom:experimental This contract is experimental.
 * @custom:security-contact info@substratum.art
 */
contract FREESTYLE_HAIKU is ERC721Royalty, Ownable {
    using Counters for Counters.Counter;
    using Strings for string;

    struct Attribute {
        string traitType;
        string value;
    }

    struct TokenData {
        string name; // The name of the artwork.
        string mediaImage; // The image corresponding to the token.
        string mediaAnimation; // The animation corresponding to the token.
        string description; // The token's description.
        string externalUrl; // If data is stored in this field, it will override baseExternalUrl/tokenId in tokenDataOf. To access this dynamic field, use the public function externalUrl().
        string additionalData; // Additional data that can get added to the token description by the API.
        string artistNameOverride; // Lets the artist set a custom artist name(s) for a token.
        string licenseOverride; // Lets the artist set a custom license for a token.
        uint256 tokenEntropy; // Seed for random number generation or image creation.
        uint256 unlockBlock; // If set, the token is locked until the block number exceeds this value.
        uint256 transferCount; // If countTransfers is true, this is the number of times the token has been transferred.
        uint256 lastBlockTransferred; // If countTransfers is true, this is the block number of the last transfer.
        address royaltyAddressOverride; // Lets the artist set a custom royalty address for a token.
        uint8 mediaType; // Defaults to 0 for decentralized storage. 1 denotes directly stored data. 2 denotes generated from script. 204 denotes media accessible elsewhere in smart contract.
        uint8 widthRatio; // The media's aspect ratio: widthRatio/heightRatio. Defaults to 1.
        uint8 heightRatio; // The media's aspect ratio: widthRatio/heightRatio. Defaults to 1.
        bool countTransfers; // If true, the token will count transfers and update transferCount and lastBlockTransferred.
        bool frozen; // If true, the token's crucial data cannot be updated.
    }

    Counters.Counter public tokensMinted;
    uint256 public maxSupply = 10 ** 12;
    uint96 public royaltyBPS;
    bool public mintActive;
    string public baseURI;
    string public baseExternalUrl;
    string public collectionNotes;
    string public collection;
    string public collectionDescription;
    string public defaultArtistName;
    string public defaultLicense;
    string public projectWebsite;
    address public artistAddress;
    address public minterAddress;
    address public platformAddress;
    address public defaultRoyaltyAddress;
    mapping(uint256 => TokenData) tokenData;
    mapping(uint256 => Attribute[]) private attributes;

    constructor() ERC721("Freestyle H-AI-KU", "FHAIKU") {}

    // CUSTOM EVENTS
    // These events are watched by the substratum.art platform.
    // These will be monitored by the custom backend. They will trigger
    // updating the API data returned by the tokenDataOf() function.

    /**
     * @notice The TokenUpdated event is emitted from multiple functions that
     * that affect the rendering of traits/image of the token.
     * @param tokenId is the token that is being updated.
     */
    event TokenUpdated(uint256 tokenId);

    /**
     * @notice The TokenLocked event is emitted when a token is locked.
     * @param tokenId is the token that is being locked.
     * @param unlockBlock is the block number when the token will be unlocked.
     */
    event TokenLocked(uint256 indexed tokenId, uint256 unlockBlock);

    // MODIFIERS
    // These are reusable code blocks to control function execution.

    /**
     * @notice onlyArtist restricts functions to the artist.
     */
    modifier onlyArtist() {
        require(msg.sender == artistAddress);
        _;
    }

    /**
     * @notice notFrozen ensures that a token is not frozen.
     */
    modifier notFrozen(uint256 _tokenId) {
        require(tokenData[_tokenId].frozen == false);
        _;
    }

    // OVERRIDE FUNCTIONS
    // These functions are declared as overrides because functions of the
    // same name exist in imported contracts.
    // 'super.<overridden function>' calls the overridden function.

    /**
     * @notice _baseURI is an internal function that returns a state value.
     * @dev This override is needed when using a custom baseURI.
     * @return baseURI, which is a state value.
     */
    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    /**
     * @notice _beforeTokenTransfer is an override function that is called
     * before a token is transferred.
     * @dev This override is needed to check if a token is locked, and if token counts transfers.
     * @param _from is the address the token is being transferred from.
     * @param _to is the address the token is being transferred to.
     * @param _tokenId is the token being transferred.
     */
    function _transfer(
        address _from,
        address _to,
        uint256 _tokenId
    ) internal virtual override {
        require(
            ownerOf(_tokenId) == artistAddress || !isTokenLocked(_tokenId),
            "Token is locked"
        );
        if (tokenData[_tokenId].countTransfers) {
            tokenData[_tokenId].transferCount++;
            tokenData[_tokenId].lastBlockTransferred = block.number;
            emit TokenUpdated(_tokenId);
        }
        super._transfer(_from, _to, _tokenId);
    }

    /**
     * @notice this override checks if a token has a specific royalty address set.
     * @dev as a mapping, if a token does not have an address set, it returns the
     * zero address, so a catch must be used to reset the returned address to the
     * contract's default address.
     * @param _tokenId is the token to check its royalty information.
     * @param _salePrice is the price to calculate the royalty with.
     */
    function royaltyInfo(
        uint256 _tokenId,
        uint256 _salePrice
    ) public view virtual override returns (address, uint256) {
        address royaltyReceiver = tokenData[_tokenId].royaltyAddressOverride ==
            address(0)
            ? defaultRoyaltyAddress
            : tokenData[_tokenId].royaltyAddressOverride;
        return (royaltyReceiver, (_salePrice * royaltyBPS) / 10000);
    }

    // CUSTOM VIEW FUNCTIONS
    // These are custom view functions implemented for efficiency.

    /**
     * @notice additionalDataOf returns the additional data for a token.
     * @dev This function returns the additional data for a token.
     * If the contents are shorter than 13 bytes, the content is converted into an integer.
     * If the conversion is successful and the integer is less than the total number of tokens minted,
     * the integer is treated like a tokenId and additionalData is returned from that tokenId.
     * @param _tokenId is the token whose additional data will be returned.
     * @return additionalData is the additional data for the token or referenced token.
     */
    function additionalDataOf(
        uint256 _tokenId
    ) public view returns (string memory) {
        string memory additionalData = tokenData[_tokenId].additionalData;
        if (bytes(additionalData).length == 0) {
            return "";
        }
        if (bytes(additionalData).length < 13) {
            (uint256 targetId, bool success) = _strToUint(additionalData);
            if (success && targetId < tokensMinted.current() + 1) {
                return tokenData[targetId].additionalData;
            }
        }
        return additionalData;
    }

    /**
     * @notice externalUrl returns the external URL for a token.
     * @dev This function returns the external URL for a token by either using the tokenData.externalUrl field (priority) or the baseExternalUrl with tokenId appended.
     * @param _tokenId is the token whose external URL will be returned.
     * @return externalUrl is the external URL for the token.
     */
    function externalUrl(uint256 _tokenId) public view returns (string memory) {
        if (bytes(tokenData[_tokenId].externalUrl).length > 0) {
            return tokenData[_tokenId].externalUrl;
        }
        return
            string(
                abi.encodePacked(baseExternalUrl, Strings.toString(_tokenId))
            );
    }

    /**
     * @notice getAttributeTuples returns the attribute data for a token.
     * @dev This function returns the attribute data for a token.
     * @param _tokenId is the token whose traits will be returned.
     * @return attributes is the array of trait - tuples for the token.
     */
    function getAttributeTuples(
        uint256 _tokenId
    ) external view returns (Attribute[] memory) {
        return attributes[_tokenId];
    }

    /**
     * @notice getDescription returns the description for a token.
     * @dev This function returns the description for a token as a string,
     * allowing for it to be used composably in other contracts.
     * @param _tokenId is the token whose description will be returned.
     * @return description is the description for the token.
     */
    function getDescription(uint256 _tokenId) external view returns (string memory) {
        return tokenData[_tokenId].description;
    }

    /**
     * @notice attributesOf returns the attribute data for a token in JSON format.
     * @dev This function returns the attribute data for a token in JSON format.
     * @param _tokenId is the token whose traits will be returned.
     * @return attributesJSON is a string of traits for the token in JSON format.
     */
    function attributesOf(
        uint256 _tokenId
    ) public view returns (string memory) {
        string memory attributesJSON;
        uint256 traitCount = attributes[_tokenId].length;
        if (traitCount == 0) {
            return '"attributes":[]';
        } else {
            for (uint256 i = 0; i < traitCount; i++) {
                if (i == 0) {
                    attributesJSON = string(
                        abi.encodePacked(
                            '"attributes":[{"trait_type":"',
                            attributes[_tokenId][i].traitType,
                            '","value":"',
                            attributes[_tokenId][i].value,
                            '"}'
                        )
                    );
                } else {
                    attributesJSON = string(
                        abi.encodePacked(
                            attributesJSON,
                            ',{"trait_type":"',
                            attributes[_tokenId][i].traitType,
                            '","value":"',
                            attributes[_tokenId][i].value,
                            '"}'
                        )
                    );
                }
            }
            attributesJSON = string(abi.encodePacked(attributesJSON, "]"));
            return attributesJSON;
        }
    }

    /**
     * @notice tokenDataOf returns the input data necessary for the generative
     * script to create/recreate a Mattos_Fine_Art token.
     * @dev For any given token, this function returns all its on-chain data.
     * @dev entropyString is set outside of the return to standardize this code.
     * @param _tokenId is the token whose inputs will be returned.
     * @return tokenData is returned in JSON format.
     */
    function tokenDataOf(uint256 _tokenId) public view returns (string memory) {
        TokenData memory token = tokenData[_tokenId];
        string memory externalUrlString = externalUrl(_tokenId);
        string memory entropyString = Strings.toString(token.tokenEntropy);
        string memory artistName = bytes(token.artistNameOverride).length == 0
            ? defaultArtistName
            : token.artistNameOverride;
        string memory license = bytes(token.licenseOverride).length == 0
            ? defaultLicense
            : token.licenseOverride;
        address royaltyReceiver = token.royaltyAddressOverride == address(0)
            ? defaultRoyaltyAddress
            : token.royaltyAddressOverride;
        string memory transferData;
        if (token.countTransfers) {
            transferData = string(
                abi.encodePacked(
                    '","transfer_count":"',
                    Strings.toString(token.transferCount),
                    '","last_transfer_block":"',
                    Strings.toString(token.lastBlockTransferred)
                )
            );
        } else {
            transferData = '","transfer_count":"","last_transfer_block":"';
        }
        string memory isFrozen = token.frozen ? "true" : "false";
        string memory allTokenData = string(
            abi.encodePacked(
                '{"collection":"',
                collection,
                '","name":"',
                token.name,
                '","description":"',
                token.description,
                '","artist":"',
                artistName
            )
        );
        allTokenData = string(
            abi.encodePacked(
                allTokenData,
                '","image":"',
                token.mediaImage,
                '","animation":"',
                token.mediaAnimation,
                '","width_ratio":"',
                Strings.toString(token.widthRatio),
                '","height_ratio":"',
                Strings.toString(token.heightRatio),
                '","media_type":"',
                Strings.toString(token.mediaType),
                '","token_data_frozen":"',
                isFrozen,
                '","license":"',
                license
            )
        );
        allTokenData = string(
            abi.encodePacked(
                allTokenData,
                '","token_entropy":"',
                entropyString,
                transferData,
                '","additional_data":"',
                additionalDataOf(_tokenId),
                '","website":"',
                projectWebsite,
                '","external_url":"',
                externalUrlString,
                '","royalty_address":"',
                Strings.toHexString(uint160(royaltyReceiver), 20),
                '","royalty_bps":"',
                Strings.toString(royaltyBPS),
                '",'
            )
        );
        allTokenData = string(
            abi.encodePacked(allTokenData, attributesOf(_tokenId), "}")
        );
        return allTokenData;
    }

    /**
     * @notice isTokenLocked returns whether a token is locked.
     * @dev This function returns whether a token is locked. If the current
     * block is less than the unlockBlock value, the token is locked.
     * @param _tokenId is the token to check.
     */
    function isTokenLocked(uint256 _tokenId) public view returns (bool) {
        return block.number < tokenData[_tokenId].unlockBlock;
    }

    /**
     * @notice getRemainingLockupBlocks returns the number of blocks remaining
     * until a token is unlocked.
     * @dev The token automatically unlocks once the block number exceeds the
     * unlockBlock value.
     * @param _tokenId is the token to check.
     */
    function getRemainingLockupBlocks(
        uint256 _tokenId
    ) public view returns (uint256) {
        if (block.number >= tokenData[_tokenId].unlockBlock) {
            return 0;
        }
        return tokenData[_tokenId].unlockBlock - block.number;
    }

    // ARTIST CONTROLS
    // These functions have various levels of artist-only control
    // mechanisms in place.
    // All functions should use onlyArtist modifier.

    /**
     * @notice changeMaxSupply allows changes to the maximum iteration count,
     * a value that is checked against during mint.
     * @dev This function will only update the maxSupply variable if the
     * submitted value is greater than or equal to the current number of minted
     * tokens. maxSupply is used in the internal _minter function to cap the
     * number of mintable tokens.
     * @param _maxSupply is the new maximum supply.
     */
    function changeMaxSupply(uint256 _maxSupply) external onlyArtist {
        require(_maxSupply >= tokensMinted.current());
        maxSupply = _maxSupply;
    }

    /**
     * @notice setArtistName allows the artist to update their name.
     * @dev This function is used to update the defaultArtistName variable.
     * @param _defaultArtistName is the new artist name.
     */
    function setDefaultArtistName(
        string memory _defaultArtistName
    ) external onlyArtist {
        defaultArtistName = _defaultArtistName;
    }

    /**
     * @notice setDefaultLicense allows the artist to update the default license.
     * @dev This function is used to update the defaultLicense variable.
     * @param _defaultLicense is the new default license.
     */
    function setDefaultLicense(
        string memory _defaultLicense
    ) external onlyArtist {
        defaultLicense = _defaultLicense;
    }

    /**
     * @notice setCollection allows the artist to update the collection name.
     * @dev This function is used to update the collection variable.
     * @param _collection is the new collection name.
     */
    function setCollection(string memory _collection) external onlyArtist {
        collection = _collection;
    }

    /**
     * @notice Updates the collection description.
     * @dev This is separate from other update functions because the collection description
     * size may be large and thus expensive to update.
     * @param _collectionDescription is the new collection description.
     */
    function setCollectionDescription(
        string memory _collectionDescription
    ) external onlyArtist {
        collectionDescription = _collectionDescription;
    }

    /**
     * @notice Updates the base external URL.
     * @dev If this is set, and no data is written to the token's externalUrl field, baseExternalUrl/tokenId will be returned from tokenDataOf.
     * If this is not set or if any data is written to the token's externalUrl field, the token's externalUrl field will be returned from tokenDataOf.
     * @param _baseExternalUrl is the new external base URL. It should end with a slash.
     */
    function setBaseExternalUrl(
        string memory _baseExternalUrl
    ) external onlyArtist {
        baseExternalUrl = _baseExternalUrl;
    }

    /**
     * @notice Updates the collection notes, which are general and collection-wide.
     * @dev This is separate from other update functions because it's unlikely to change.
     * @param _collectionNotes new collection notes.
     */
    function setCollectionNotes(
        string memory _collectionNotes
    ) external onlyArtist {
        collectionNotes = _collectionNotes;
    }

    /**
     * @notice setProjectWebsite allows the artist to update the project's website.
     * @dev This function is used to update the projectWebsite variable.
     * @param _projectWebsite is the new projectWebsite.
     */
    function setProjectWebsite(
        string memory _projectWebsite
    ) external onlyArtist {
        projectWebsite = _projectWebsite;
    }

    /**
     * @notice setTokenData fills in data required to actualize a token with custom data.
     * @dev this is separated from MINT functions to allow flexibility in sales or
     * token distribution. Platform is allowed to access this function to assist
     * artists and to replace URI's as needed if decentralized storage fails.
     * Token must already be minted. tokensMinted.current() is always the last token's Id
     * (tokens start at index 1).
     * @param _tokenId is the token who's data is being set
     * @param _name is the name of the token
     * @param _mediaImage is the token mediaImage (additionalData may be used for more info)
     * @param _mediaType is the type of media (additionalData may be used for more info)
     * 0 for decentralized storage link(s) (eg. IPFS or Arweave)
     * 1 for directly stored data (eg. escaped or base64 encoded SVG)
     * 2 for generated from script (eg. javascript code)
     * (additional types may supported in the future)
     * 204 for media accessible elsewhere in smart contract (eg. standard / non-escaped SVG code)
     * @param _description is the description of the NFT content.
     * @param _tokenEntropy is the token's entropy, used for random number generation or image creation.
     * @param _additionalData is any on-chain data specific to the token.
     * @param _externalUrl is the external URL for the token.
     * @param _attributesArray is the token's attributes in one-dimensional string array,
     * eg. ["color", "red", "size", "large"]
     * @param _dimensions is a uint8 array of widthRatio and heightRatio data.
     */
    function setTokenData(
        uint256 _tokenId,
        string memory _name,
        string memory _mediaImage,
        string memory _mediaAnimation,
        uint8 _mediaType,
        string memory _description,
        uint256 _tokenEntropy,
        string memory _additionalData,
        string memory _externalUrl,
        string[] memory _attributesArray,
        uint8[] memory _dimensions
    ) external onlyArtist notFrozen(_tokenId) {
        require(_tokenId < tokensMinted.current() + 1);
        TokenData storage updateToken = tokenData[_tokenId];
        if (bytes(_name).length > 0) updateToken.name = _name;
        if (bytes(_mediaImage).length > 0) updateToken.mediaImage = _mediaImage;
        if (bytes(_mediaAnimation).length > 0)
            updateToken.mediaAnimation = _mediaAnimation;
        if (_mediaType != updateToken.mediaType)
            updateToken.mediaType = _mediaType;
        if (bytes(_description).length > 0)
            updateToken.description = _description;
        if (_tokenEntropy != updateToken.tokenEntropy)
            updateToken.tokenEntropy = _tokenEntropy;
        if (bytes(_additionalData).length > 0)
            updateToken.additionalData = _additionalData;
        if (_attributesArray.length > 0) {
            _addAttributes(_tokenId, _attributesArray);
        }
        if (bytes(_externalUrl).length > 0)
            updateToken.externalUrl = _externalUrl;
        if (_dimensions.length > 0) {
            updateToken.widthRatio = _dimensions[0];
            updateToken.heightRatio = _dimensions[1];
        } else if (updateToken.widthRatio == 0) {
            updateToken.widthRatio = 1;
            updateToken.heightRatio = 1;
        }
        emit TokenUpdated(_tokenId);
    }

    /**
     * @notice setTokenOverrides fills in override data for a token.
     * @dev This function is used to update the tokenData struct for a token.
     * @param _tokenId is the token who's data is being set
     * @param _licenseOverride is the new license override.
     * @param _artistNameOverride is the new artist name override.
     * @param _royaltyAddressOverride is the new royalty address override.
     */
    function setTokenOverrides(
        uint256 _tokenId,
        string memory _licenseOverride,
        string memory _artistNameOverride,
        address _royaltyAddressOverride
    ) external onlyArtist notFrozen(_tokenId) {
        TokenData storage updateToken = tokenData[_tokenId];
        if (bytes(_licenseOverride).length > 0)
            updateToken.licenseOverride = _licenseOverride;
        if (bytes(_artistNameOverride).length > 0)
            updateToken.artistNameOverride = _artistNameOverride;
        if (_royaltyAddressOverride != address(0))
            updateToken.royaltyAddressOverride = _royaltyAddressOverride;
        emit TokenUpdated(_tokenId);
    }

    /**
     * @notice setCountTransferBool sets whether a token counts transfers.
     * @dev This function is used to update the tokenData struct for a token.
     * @param _tokenId is the token who's data is being set
     * @param _countTransfers is the new countTransfers bool.
     */
    function setCountTransferBool(
        uint256 _tokenId,
        bool _countTransfers
    ) external onlyArtist notFrozen(_tokenId) {
        tokenData[_tokenId].countTransfers = _countTransfers;
        emit TokenUpdated(_tokenId);
    }

    /**
     * @notice Adds a token attribute pair to a token's traits array.
     * @dev Each tuple is a attribute type and value, eg. "color" and "red".
     * @param _tokenId is the token to update.
     * @param _traitType is the attribute type.
     * @param _value is the attribute value.
     */
    function pushTokenTrait(
        uint256 _tokenId,
        string memory _traitType,
        string memory _value
    ) external onlyArtist notFrozen(_tokenId) {
        Attribute memory newTrait = Attribute(_traitType, _value);
        attributes[_tokenId].push(newTrait);
        emit TokenUpdated(_tokenId);
    }

    /**
     * @notice Locks a token for a specified number of blocks.
     * @dev This function is used to lock a token for a specified number of blocks.
     * Only the artist can lock a token if owned, and for a maximum period of 2,000,000 blocks.
     * @param _tokenId is the token to update.
     * @param _lockPeriodInBlocks is the number of blocks to lock the token for.
     */
    function setTokenLock(
        uint256 _tokenId,
        uint256 _lockPeriodInBlocks
    ) external onlyArtist {
        require(ownerOf(_tokenId) == artistAddress, "Artist must own token");
        require(_lockPeriodInBlocks <= 2000000, "Lockup period too long");
        _lockToken(_tokenId, _lockPeriodInBlocks);
    }

    /**
     * @notice Updates a token lock.
     * @dev This function is used to shorten the lock period of a currently locked token.
     * @param _tokenId is the token to update.
     * @param _lockPeriodInBlocks is the number of blocks to lock the token for.
     */
    function updateTokenLock(
        uint256 _tokenId,
        uint256 _lockPeriodInBlocks
    ) external onlyArtist {
        require(isTokenLocked(_tokenId));
        require(
            _lockPeriodInBlocks < getRemainingLockupBlocks(_tokenId),
            "Lockup period too long"
        );
        _lockToken(_tokenId, _lockPeriodInBlocks);
    }

    /**
     * @notice Updates a token trait pair in a token's attributes array.
     * @dev Index can be ascertained from the public getter function for attributes.
     * @param _tokenId is the token to update.
     * @param _attributeIndex is the index of the attribute to update.
     * @param _traitType is the attribute type.
     * @param _value is the attribute value.
     */
    function updateTokenTrait(
        uint256 _tokenId,
        uint256 _attributeIndex,
        string memory _traitType,
        string memory _value
    ) external onlyArtist notFrozen(_tokenId) {
        attributes[_tokenId][_attributeIndex].traitType = _traitType;
        attributes[_tokenId][_attributeIndex].value = _value;
        emit TokenUpdated(_tokenId);
    }

    /**
     * @notice Removes a token trait pair from a token's attributes array.
     * @dev Index can be ascertained from the public getter function for attributes.
     * @param _tokenId is the token to update.
     * @param _attributeIndex is the index of the attribute to remove.
     */
    function removeTokenTrait(
        uint256 _tokenId,
        uint256 _attributeIndex
    ) external onlyArtist notFrozen(_tokenId) {
        uint256 lastAttributeIndex = attributes[_tokenId].length - 1;
        attributes[_tokenId][_attributeIndex] = attributes[_tokenId][
            lastAttributeIndex
        ];
        attributes[_tokenId].pop();
        emit TokenUpdated(_tokenId);
    }

    /** Updates the name of a token.
     * @param _tokenId is the token to update.
     * @param _name is the new name.
     */
    function updateTokenName(
        uint256 _tokenId,
        string memory _name
    ) external onlyArtist notFrozen(_tokenId) {
        tokenData[_tokenId].name = _name;
        emit TokenUpdated(_tokenId);
    }

    /** Updates the mediaImage of a token.
     * @param _tokenId is the token to update.
     * @param _mediaImage is the new mediaImage.
     */
    function updateTokenMediaImage(
        uint256 _tokenId,
        string memory _mediaImage
    ) external onlyArtist notFrozen(_tokenId) {
        tokenData[_tokenId].mediaImage = _mediaImage;
        emit TokenUpdated(_tokenId);
    }

    /** Updates the mediaAnimation of a token.
     * @param _tokenId is the token to update.
     * @param _mediaAnimation is the new mediaAnimation.
     */
    function updateTokenMediaAnimation(
        uint256 _tokenId,
        string memory _mediaAnimation
    ) external onlyArtist notFrozen(_tokenId) {
        tokenData[_tokenId].mediaAnimation = _mediaAnimation;
        emit TokenUpdated(_tokenId);
    }

    /** Updates the description of a token.
     * @param _tokenId is the token to update.
     * @param _description is the new description.
     */
    function updateTokenDescription(
        uint256 _tokenId,
        string memory _description
    ) external onlyArtist notFrozen(_tokenId) {
        tokenData[_tokenId].description = _description;
        emit TokenUpdated(_tokenId);
    }

    /** Updates the externalUrl of a token.
     * @param _tokenId is the token to update.
     * @param _externalUrl is the new externalUrl.
     */
    function updateTokenExternalUrl(
        uint256 _tokenId,
        string memory _externalUrl
    ) external onlyArtist {
        tokenData[_tokenId].externalUrl = _externalUrl;
        emit TokenUpdated(_tokenId);
    }

    /**
     * @notice Updates the royalty address per token.
     * @dev This updates a mapping that is used by royaltyInfo().
     * @param _tokenId is the token to update.
     * @param _royaltyAddressOverride is the address for that token.
     */
    function updateRoyaltyAddressOverride(
        uint256 _tokenId,
        address _royaltyAddressOverride
    ) external onlyArtist {
        tokenData[_tokenId].royaltyAddressOverride = _royaltyAddressOverride;
        emit TokenUpdated(_tokenId);
    }

    /** @notice Updates the additionalData of a token.
     * @param _tokenId is the token to update.
     * @param _additionalData is the new additionalData.
     */
    function updateTokenAdditionalData(
        uint256 _tokenId,
        string memory _additionalData
    ) external onlyArtist notFrozen(_tokenId) {
        tokenData[_tokenId].additionalData = _additionalData;
        emit TokenUpdated(_tokenId);
    }

    /** Updates the artistNameOverride of a token.
     * @param _tokenId is the token to update.
     * @param _artistNameOverride is the new artistNameOverride.
     */
    function updateArtistNameOverride(
        uint256 _tokenId,
        string memory _artistNameOverride
    ) external onlyArtist notFrozen(_tokenId) {
        tokenData[_tokenId].artistNameOverride = _artistNameOverride;
        emit TokenUpdated(_tokenId);
    }

    /**
     * @notice Allows manual setting tokenEntropy for a token.
     * @dev This is the seed for the Stable Diffusion Model.
     * @param _tokenId is the token to update.
     * @param _tokenEntropy is the new tokenEntropy.
     */
    function updateTokenEntropy(
        uint256 _tokenId,
        uint256 _tokenEntropy
    ) external onlyArtist notFrozen(_tokenId) {
        tokenData[_tokenId].tokenEntropy = _tokenEntropy;
        emit TokenUpdated(_tokenId);
    }

    /** Updates the mediaType of a token.
     * @param _tokenId is the token to update.
     * @param _mediaType is the new mediaType.
     */
    function updateTokenMediaType(
        uint256 _tokenId,
        uint8 _mediaType
    ) external onlyArtist notFrozen(_tokenId) {
        tokenData[_tokenId].mediaType = _mediaType;
        emit TokenUpdated(_tokenId);
    }

    /** Updates the dimensions of a token.
     * @param _tokenId is the token to update.
     * @param _dimensions is a uint8 array of widthRatio and heightRatio data.
     */
    function updateTokenDimensions(
        uint256 _tokenId,
        uint8[] memory _dimensions
    ) external onlyArtist notFrozen(_tokenId) {
        tokenData[_tokenId].widthRatio = _dimensions[0];
        tokenData[_tokenId].heightRatio = _dimensions[1];
        emit TokenUpdated(_tokenId);
    }

    /**
     * @notice toggleMint pauses and unpauses mint.
     */
    function toggleMint() external onlyArtist {
        mintActive = !mintActive;
    }

    /**
     * @notice freezeToken freezes a token's data.
     */
    function freezeToken(uint256 _tokenId) external onlyArtist {
        tokenData[_tokenId].frozen = true;
    }

    // MINTER CONTROLS
    // These functione can only be called by the minter or artist.

    /**
     * @notice mintToAddress can only be called by the artist and the minter
     * account, and it mints to a specified address.
     * @dev Variation of a mint function that uses a submitted address as the
     * account to mint to. The artist account can bypass the mintActive requirement.
     * @param _to is the address to send the token to.
     */
    function mintToAddress(address _to) external {
        require(msg.sender == artistAddress || msg.sender == minterAddress);
        require(mintActive || msg.sender == artistAddress);
        _minter(_to);
    }

    // OWNER CONTROLS
    // These are contract-level controls.
    // All should use the onlyOwner modifier.

    /**
     * @notice ownerPauseMint pauses minting.
     * @dev onlyOwner modifier gates access.
     */
    function ownerPauseMint() external onlyOwner {
        mintActive = false;
    }

    /**
     * @notice ownerSetMinterAddress sets/updates the project's approved minting address.
     * @dev minter can be any type of account.
     * @param _minterAddress is the new account to be set as the minter.
     */
    function ownerSetMinterAddress(address _minterAddress) external onlyOwner {
        minterAddress = _minterAddress;
    }

    /**
     * @notice ownerSetAddresses sets authorized addresses.
     * @dev This must be set prior to executing many other functions.
     * @param _artistAddress is the new artist address.
     * @param _platformAddress is the new platform address.
     */
    function ownerSetAddresses(
        address _artistAddress,
        address _platformAddress
    ) external onlyOwner {
        artistAddress = _artistAddress;
        platformAddress = _platformAddress;
    }

    /**
     * @notice ownerSetRoyaltyData updates the royalty address and BPS for the project.
     * @dev This function allows changes to the payments address and secondary sale
     * royalty amount. After setting values, _setDefaultRoyalty is called in
     * order to update the imported EIP-2981 contract functions.
     * @param _defaultRoyaltyAddress is the new payments address.
     * @param _royaltyBPS is the new projet royalty amount, measured in
     * base percentage points.
     */
    function ownerSetRoyaltyData(
        address _defaultRoyaltyAddress,
        uint96 _royaltyBPS
    ) external onlyOwner {
        defaultRoyaltyAddress = _defaultRoyaltyAddress;
        royaltyBPS = _royaltyBPS;
        _setDefaultRoyalty(_defaultRoyaltyAddress, _royaltyBPS);
    }

    /**
     * @notice ownerSetBaseURI sets/updates the project's baseURI.
     * @dev baseURI is appended with tokenId and is returned in tokenURI calls.
     * @dev _newBaseURI is used instead of _baseURI because an override function
     * with that name already exists.
     * @param _newBaseURI is the API endpoint base for tokenURI calls.
     */
    function ownerSetBaseURI(string memory _newBaseURI) external onlyOwner {
        baseURI = _newBaseURI;
    }

    // INTERNAL FUNCTIONS
    // These are helper functions that can only be called from within this contract.

    /**
     * @notice _minter is the internal function that generates mints.
     * @dev Minting function called by the public 'mintToAddress' function.
     * The artist can bypass the payment requirement.
     * @param _to is the address to send the token to.
     */
    function _minter(address _to) internal {
        require(tokensMinted.current() < maxSupply, "All minted.");
        tokensMinted.increment();
        uint256 tokenId = tokensMinted.current();
        _safeMint(_to, tokenId);
    }

    /** 
     * @notice _addAttributes adds attributes to a token.
     * @dev This function is used to add attributes to a token.
     * @param _tokenId is the token to update.
     * @param _attributesArray is the token's attributes in one-dimensional string array,
     */
    function _addAttributes(uint256 _tokenId, string[] memory _attributesArray) internal {
            for (uint256 i = 0; i < _attributesArray.length; i += 2) {
                Attribute memory newAttribute = Attribute(
                    _attributesArray[i],
                    _attributesArray[i + 1]
                );
                attributes[_tokenId].push(newAttribute);
            }
    }

    /**
     * @notice Internal function to execute token locking logic.
     * @param _tokenId is the token to update.
     * @param _lockPeriodInBlocks is the number of blocks to lock the token for.
     */
    function _lockToken(
        uint256 _tokenId,
        uint256 _lockPeriodInBlocks
    ) internal {
        uint256 unlockBlock = block.number + _lockPeriodInBlocks;
        tokenData[_tokenId].unlockBlock = unlockBlock;
        emit TokenLocked(_tokenId, unlockBlock);
    }

    /**
     * @notice _strToUint converts a string to a uint.
     * @dev This function is called if a tokenId reference is likely, in the additionalData storage.
     * If the string is not a number, the conversion will not be accurate and the function will return false.
     * @param _str is the string to convert.
     * @return res is the converted uint.
     * @return success is whether the conversion was successful.
     */
    function _strToUint(
        string memory _str
    ) internal pure returns (uint256 res, bool success) {
        for (uint256 i = 0; i < bytes(_str).length; i++) {
            if (
                (uint8(bytes(_str)[i]) - 48) < 0 ||
                (uint8(bytes(_str)[i]) - 48) > 9
            ) {
                return (0, false);
            }
            res +=
                (uint8(bytes(_str)[i]) - 48) *
                10 ** (bytes(_str).length - i - 1);
        }
        return (res, true);
    }
}