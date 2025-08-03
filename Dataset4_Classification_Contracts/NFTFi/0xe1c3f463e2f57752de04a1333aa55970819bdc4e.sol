// SPDX-License-Identifier: MIT
// OpenGem Contracts (token/ERC721/extensions/ERC721PermanentProof.sol)

pragma solidity ^0.8.0;

import "lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

abstract contract ERC721PermanentProof is ERC721 {

    string private _permanentGlobalProof;
    mapping(uint256 => string) private _permanentTokenProofs;

    function tokenProofPermanent(uint256 tokenId) public view virtual returns (string memory) {
        _requireMinted(tokenId);

        string memory _tokenProof = _permanentTokenProofs[tokenId];

        if (bytes(_tokenProof).length == 0) {
            return _permanentGlobalProof;
        }
        return _tokenProof;
    }

    function _setPermanentGlobalProof(string memory _globalProof) internal virtual {
        require(bytes(_permanentGlobalProof).length == 0, "ERC721PermanentProof: Proof already set");
        _permanentGlobalProof = _globalProof;
    }

    function _setPermanentTokenProof(uint256 tokenId, string memory _tokenProof) internal virtual {
        require(_exists(tokenId), "ERC721PermanentProof: Proof set of nonexistent token");
        require(bytes(_permanentTokenProofs[tokenId]).length == 0, "ERC721PermanentProof: Proof already set");
        _permanentTokenProofs[tokenId] = _tokenProof;
    }
    
    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);

        if (bytes(_permanentTokenProofs[tokenId]).length != 0) {
            delete _permanentTokenProofs[tokenId];
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenGem Contracts (token/ERC721/extensions/ERC721PermanentURIs.sol)

pragma solidity ^0.8.0;

import "lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

abstract contract ERC721PermanentURIs is ERC721 {
    using Strings for uint256;

    string[] private _globalURIsPermanent;

    mapping(uint256 => string[]) private _tokenURIsPermanent;

    uint256 _baseURIsPermanentIndex = 0;
    mapping(uint256 => string) private _prefixBaseURIsPermanent;
    mapping(uint256 => string) private _suffixBaseURIsPermanent;

    function tokenURIsPermanent(uint256 tokenId) public view virtual returns (string[] memory) {
        _requireMinted(tokenId);
        uint256 index = 0;
        string[] memory uris = new string[](_globalURIsPermanent.length + _baseURIsPermanentIndex + _tokenURIsPermanent[tokenId].length);

        for (uint256 i = 0; i < _globalURIsPermanent.length;) {
            uris[index] = string(_globalURIsPermanent[i]);
            unchecked {
                index++;
                i++;
            }
        }

        for (uint256 i = 0; i < _baseURIsPermanentIndex;) {
            uris[index] = string(abi.encodePacked(_prefixBaseURIsPermanent[i], tokenId.toString(), _suffixBaseURIsPermanent[i]));
            unchecked {
                index++;
                i++;
            }
        }

        for (uint256 i = 0; i < _tokenURIsPermanent[tokenId].length;) {
            uris[index] = string(_tokenURIsPermanent[tokenId][i]);
            unchecked {
                index++;
                i++;
            }
        }

        return uris;
    }

    function _addPermanentBaseURI(string memory prefixURI_, string memory suffixURI_) internal virtual {
        _prefixBaseURIsPermanent[_baseURIsPermanentIndex] = prefixURI_;
        _suffixBaseURIsPermanent[_baseURIsPermanentIndex] = suffixURI_;
        _baseURIsPermanentIndex++;
    }

    function _addPermanentTokenURI(uint256 tokenId, string memory tokenURI_) internal virtual {
        require(_exists(tokenId), "ERC721PermanentURIs: PermanentURI set of nonexistent token");
        _tokenURIsPermanent[tokenId].push(tokenURI_);
    }

    function _addPermanentGlobalURI(string memory tokenURI_) internal virtual {
        _globalURIsPermanent.push(tokenURI_);
    }

    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);

        if (_tokenURIsPermanent[tokenId].length != 0) {
            delete _tokenURIsPermanent[tokenId];
        }
    }
}
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
pragma solidity ^0.8.19;

enum Status {
  notInitialized,
  allowlist,
  whitelist,
  publicMint,
  finished,
  paused,
  privateWhitelist
}

error ZeroAddress();
error contractFreezed();
error onlyApprovedPaymentAddress();
error maxSupplyToken1Reach();
error maxSupplyToken2Reach();
error invalidAmountSend();
error maxMintWalletReachToken1();
error maxMintWalletReachToken2();
error invalidSaleStatus();
error PublicSaleNotStarted();
error invalidSignature();
error exceedAllowedToken1Mint();
error exceedAllowedToken2Mint();
error failWhithdraw();
error whithdrawZeroValue();
error privateWhitelistToken1SoldOut();
error privateWhitelistToken2SoldOut();
error NoReserveToken1();
error NoReserveToken2();
error noSupplyAvailableToken1();
error noSupplyAvailableToken2();
error AmountCanNotBeLowerThanCurrent(uint256);
error WihdrawToZeroAddress();
error MaxSupplyCanNotBeMoreThan500();
error MaxSupplyCanNotbeOdd();
error MaxSupplyCanNotBeLowerThanActual();
error FeeExceed10Percent();
error PercentCanNotBeMoreThan100Percent();
error SupplySealed();
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {ERC2981} from "lib/openzeppelin-contracts/contracts/token/common/ERC2981.sol";
import {ERC721} from "lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {ERC721PermanentURIs} from "lib/opengem-contracts/token/ERC721/extensions/ERC721PermanentURIs.sol";
import {ERC721PermanentProof} from "lib/opengem-contracts/token/ERC721/extensions/ERC721PermanentProof.sol";

import "./IUNDOXXED.sol";
import "./verification/Verification.sol";

/**
 * @title UNDOXXED Book
 * @author chixx.eth
 * @notice ERC721 with 4 types of mint
 */
contract UNDOXXEDBOOK24 is ERC721, Ownable, ERC2981, ERC721PermanentProof {
  string private cover1URI = "ipfs://Qmbo6MEp788EKWf3YGRkRxDVrbEL1L3Zj4c2C4W2EGDXnU";
  string private cover2URI = "ipfs://QmPojiTQyZk7cpJ3LvbHroJJNptoX45ZLj1r5RUeWqdSyX";
  string private baseMediaURICover = "ipfs://QmXSwaTSgMaiER1zKM6mdjjAD6YMXeEgQBBBFhd4vvtCVk";
  string private baseMediaURICoverArweave = "ar://-bk2F28vmvghWo90grBHKbC12ATIjgKG3NL0G2t0G1c";
  /** @dev sha256 JSON hashed */
  string private tokenProof1 = "8d39748984ce311a99f51fec1295f4e6c2c432e38617001e879a066150bb4f1c";
  string private tokenProof2 = "003d43ec4ff0e42e297825e3c1ee0838a6191b44dfb3cb5aa11cb5653fc1dc9d";

  uint256 private maxSupply = 300;
  uint256 private token1 = 0;
  uint256 private token2 = 0;
  uint256 private whitelistPrice = 0.074 ether;
  uint256 private publicPrice = 0.091 ether;

  uint256 public cover1Reserved = 40;
  uint256 public cover2Reserved = 35;


  /** @dev 1% => 100, `withdrawPercent` / 10 000 */
  uint256 private withdrawPercent = 6000;

  address private signer = 0x90D41fA17a8dF96E7dff80227b4FC7d208dFd026;

  address[2] private fundsReceivers;

  bool public isPublic;
  bool public supplySealed;

  mapping(bytes => uint256) private signatureCheckToken1;
  mapping(bytes => uint256) private signatureCheckToken2;

  /**
   * @dev verify signature
   */
  modifier verify(
    address _to,
    uint256 _amount1,
    uint256 _amount2,
    Status _status,
    bytes memory _sign
  ) {
    if (!Verification.verifySignature(signer, _to, _amount1, _amount2, _status, _sign))
      revert invalidSignature();
    _;
  }

  constructor () ERC721("UNDOXXED BOOK Vol.1", "UNDXX24") {
    fundsReceivers = [msg.sender, 0x19C013b64b7B2c7DaA59b96514662B687665E852];
    _setDefaultRoyalty(msg.sender, 300);
  }

  // MINT FUNCTIONS

  /**
   * @dev Mint function for `allowlist`
   * 
   * Requirements:
   * 
   * - `_amount1` quantity token1 to mint
   * - `_amount2` quantity token2 to mint
   * - `_amount1Sign` quantity token1 user allowed to mint
   * - `_amount2Sign` quantity token2 user allowed to mint
   * - `_sign` the signature
   * - reserve should be set
   * 
   */
  function allowlistMint(
    uint256 _amount1,
    uint256 _amount2,
    uint256 _amount1Sign,
    uint256 _amount2Sign,
    bytes memory _sign
  )
    external
    verify(msg.sender, _amount1Sign, _amount2Sign, Status.allowlist, _sign)
  {
    address receiver = msg.sender;
    uint256 maxTokenSupply = getMaxSupplyCover();
    if (_amount1 + signatureCheckToken1[_sign] > _amount1Sign) revert exceedAllowedToken1Mint();
    if (_amount2 + signatureCheckToken2[_sign] > _amount2Sign) revert exceedAllowedToken2Mint();
    if (token1 + _amount1 > maxTokenSupply) revert maxSupplyToken1Reach();
    if (token2 + _amount2 > maxTokenSupply) revert maxSupplyToken2Reach();
    if (_amount1 > cover1Reserved) revert NoReserveToken1();
    if (_amount2 > cover2Reserved) revert NoReserveToken2();

    unchecked {
      signatureCheckToken1[_sign] += _amount1;
      signatureCheckToken2[_sign] += _amount2;
    }

    cover1Reserved -= _amount1;
    cover2Reserved -= _amount2;

    _mintToken1(receiver, _amount1);
    _mintToken2(receiver, _amount2);
  }

  /**
   * @dev Mint function for `whitelist`
   * 
   * Requirements:
   * 
   * - `_amount1` quantity token1 to mint
   * - `_amount2` quantity token2 to mint
   * - `_amount1Sign` quantity token1 user allowed to mint
   * - `_amount2Sign` quantity token2 user allowed to mint
   * - `_sign` the signature
   * - `msg.value` should be equal at (`_amount1` + `_amount2`) * `whitelistPrice`
   * 
   */
  function whitelistMint(
    uint256 _amount1,
    uint256 _amount2,
    uint256 _amount1Sign,
    uint256 _amount2Sign,
    bytes memory _sign
  )
    external
    payable
    verify(msg.sender, _amount1Sign, _amount2Sign, Status.whitelist, _sign)
  {
    address receiver = msg.sender;
    uint256 maxTokenSupply = getMaxSupplyCover();
    if (_amount1 + signatureCheckToken1[_sign] > _amount1Sign) revert exceedAllowedToken1Mint();
    if (_amount2 + signatureCheckToken2[_sign] > _amount2Sign) revert exceedAllowedToken2Mint();
    if (token1 + _amount1 + cover1Reserved > maxTokenSupply) revert maxSupplyToken1Reach();
    if (token2 + _amount2 + cover2Reserved > maxTokenSupply) revert maxSupplyToken2Reach();
    unchecked {
      if ((_amount1 + _amount2) * whitelistPrice > msg.value) revert invalidAmountSend();
    }

    unchecked {
      signatureCheckToken1[_sign] += _amount1;
      signatureCheckToken2[_sign] += _amount2;
    }

    _mintToken1(receiver, _amount1);
    _mintToken2(receiver, _amount2);
  }

  /**
   * @dev Mint function for `privateWhitelist`
   * 
   * Requirements:
   * 
   * - `_amount1` quantity token1 to mint
   * - `_amount2` quantity token2 to mint
   * - `_amount1Sign` quantity token1 user allowed to mint
   * - `_amount2Sign` quantity token2 user allowed to mint
   * - `_sign` the signature
   * - `msg.value` should be equal at (`_amount1` + `_amount2`) * `whitelistPrice`
   * 
   * NOTE: This function can only be callable when status is `whitelist` or `publicMint`
   * 
   */
  function privateWhitelistMint(
    uint256 _amount1,
    uint256 _amount2,
    uint256 _amount1Sign,
    uint256 _amount2Sign,
    bytes memory _sign
  )
    external
    payable
    verify(msg.sender, _amount1Sign, _amount2Sign, Status.privateWhitelist, _sign)
  {
    address receiver = msg.sender;
    uint256 maxTokenSupply = getMaxSupplyCover();
    if (_amount1 + signatureCheckToken1[_sign] > _amount1Sign) revert exceedAllowedToken1Mint();
    if (_amount2 + signatureCheckToken2[_sign] > _amount2Sign) revert exceedAllowedToken2Mint();
    if (token1 + _amount1 > maxTokenSupply) revert maxSupplyToken1Reach();
    if (token2 + _amount2 > maxTokenSupply) revert maxSupplyToken2Reach();
    if (_amount1 > cover1Reserved) revert NoReserveToken1();
    if (_amount2 > cover2Reserved) revert NoReserveToken2();

    unchecked {
      if ((_amount1 + _amount2) * whitelistPrice > msg.value) revert invalidAmountSend();
    }

    unchecked {
      signatureCheckToken1[_sign] += _amount1;
      signatureCheckToken2[_sign] += _amount2;
    }

    cover1Reserved -= _amount1;
    cover2Reserved -= _amount2;

    _mintToken1(receiver, _amount1);
    _mintToken2(receiver, _amount2);
  }

  /**
   * @dev Mint function for `publicMint`.
   * 
   * Requirements:
   * 
   * - `_amount1` quantity token1 to mint.
   * - `_amount2` quantity token2 to mint.
   * - `msg.value` should be equal at (`_amount1` + `_amount2`) * `publicPrice`.
   * 
   * NOTE: This function can only be callable when `isPublic` equal true.
   * 
   */
  function mint(uint256 _amount1, uint256 _amount2)
    external
    payable
  {
    address receiver = msg.sender;
    uint256 maxTokenSupply = getMaxSupplyCover();
    if (!isPublic) revert PublicSaleNotStarted();
    if (token1 + _amount1 + cover1Reserved > maxTokenSupply) revert maxSupplyToken1Reach();
    if (token2 + _amount2 + cover2Reserved > maxTokenSupply) revert maxSupplyToken2Reach();
    unchecked {
      if ((_amount1 + _amount2) * publicPrice > msg.value) revert invalidAmountSend();
    }

    _mintToken1(receiver, _amount1);
    _mintToken2(receiver, _amount2);
  }

  // WHITHDRAW

  /**
   * @dev Withdraw contract balance to 2 differents address.
   * 
   * NOTE: First address will receive the `withdrawPercent`,
   * second one will receive the remaining.
   * 
   * Requirements:
   * 
   * - `fundsReceivers` each address should not be zero address.
   * 
   */
  function withdraw() external onlyOwner {
    if (fundsReceivers[0] == address(0) || fundsReceivers[1] == address(0)) revert WihdrawToZeroAddress();
    uint256 totalValue = address(this).balance;
    if (totalValue == 0) revert whithdrawZeroValue();
    uint256 firstValue = totalValue * withdrawPercent / 10000;
    (bool success, ) = address(fundsReceivers[0]).call{value: firstValue}("");
    if (!success) revert failWhithdraw();
    (success, ) = address(fundsReceivers[1]).call{value: totalValue - firstValue}("");
    if (!success) revert failWhithdraw();
  }

  function emergencyWithdraw() external onlyOwner {
    (bool success, ) = address(msg.sender).call{value: address(this).balance}("");
    if (!success) revert failWhithdraw();
  }

  // SETTER FUNCTIONS

  /**
   * @dev Set a new max supply.
   * 
   * Requirements:
   * 
   * - `_newMaxSupply` should be in the range of 200 to 300.
   * - `_newMaxSupply` should be even.
   * 
   */
  function setMaxSupply(uint256 _newMaxSupply) external onlyOwner {
    if (_newMaxSupply > 500) revert MaxSupplyCanNotBeMoreThan500();
    if (_newMaxSupply % 2 == 1) revert MaxSupplyCanNotbeOdd();
    if (_newMaxSupply < getAllSupply() + getTotalReservedCover()) revert MaxSupplyCanNotBeLowerThanActual();
    if (supplySealed) revert SupplySealed();
    maxSupply = _newMaxSupply;
  }

  /**
   * @dev Set `isPublic` to true for enable public mint.
   */
  function setPublic(bool _public) external onlyOwner {
    isPublic = _public;
  }

  /**
   * @dev Set the address that sign all signatures.
   * 
   * NOTE: Previous signature will no longer be valid.
   */
  function setSigner(address _newSigner) external onlyOwner {
    signer = _newSigner;
  }

  /**
   * @dev Set the whitelist price.
   */
  function setWhitelistPrice(uint256 _newWhitelistPrice) external onlyOwner {
    whitelistPrice = _newWhitelistPrice;
  }

  /**
   * @dev Set the public price.
   */
  function setPublicPrice(uint256 _newPublicPrice) external onlyOwner {
    publicPrice = _newPublicPrice;
  }

  /**
   * @dev Set the amount of token1 to be reserved.
   */
  function setReserveToken1(uint256 _amountToken1) external onlyOwner {
    if (token1 + _amountToken1 > getMaxSupplyCover()) revert noSupplyAvailableToken1();
    cover1Reserved = _amountToken1;
  }

  /**
   * @dev Set the amount of token2 to be reserved.
   */
  function setReserveToken2(uint256 _amountToken2) external onlyOwner {
    if (token2 + _amountToken2 > getMaxSupplyCover()) revert noSupplyAvailableToken2();
    cover2Reserved = _amountToken2;
  }

  /**
   * @dev Set royalties inforamtions.
   * 
   * NOTE: `_feeNumerator` should be `_feeNumerator` / 10000.
   * 
   */
  function setDefaultRoyalties(address _recipient, uint96 _feeNumerator) external onlyOwner {
    if (_feeNumerator > 1000) revert FeeExceed10Percent();
    _setDefaultRoyalty(_recipient, _feeNumerator);
  }

  /**
   * @dev Set 2 address for withdraw funds.
   * 
   * NOTE:
   * 
   * - `_firstReceiver` should be the the address that will receive the `withdrawPercent`.
   * - `_secondReceiver` will receive the remaining balance.
   * 
   */
  function setFundsReceivers(address _firstReceiver, address _secondReceiver) external onlyOwner {
    if (_firstReceiver == address(0) || _secondReceiver == address(0)) revert ZeroAddress();
    fundsReceivers[0] = _firstReceiver;
    fundsReceivers[1] = _secondReceiver;
  }

  /**
   * @dev Set the percent the first address wil be funded when withdraw.
   */
  function setPercentReceiver(uint256 _percent) external onlyOwner {
    if (_percent > 10000) revert PercentCanNotBeMoreThan100Percent();
    withdrawPercent = _percent;
  }

  /**
   * @dev Seal the max supply.
   */
  function sealSupply() external onlyOwner {
    maxSupply = getAllSupply();
    supplySealed = true;
  }

  // VIEW FUNCTIONS

  /**
   * @dev Return the max supply mintable
   */
  function getMaxSupply() external view returns (uint256) {
    return maxSupply;
  }

  /**
   * @dev Return the max supply of a cover.
   */
  function getMaxSupplyCover() public view returns (uint256) {
    return maxSupply / 2;
  }

  /**
   * @dev Return total cover 1 minted.
   */
  function getToken1Supply() external view returns (uint256) {
    return token1;
  }

  /**
   * @dev Return total cover 2 minted.
   */
  function getToken2Supply() external view returns (uint256) {
    return token2;
  }

  /**
   * @dev Return supply minted.
   */
  function getAllSupply() public view returns (uint256) {
    return token1 + token2;
  }

  /**
   * @dev Return the whitelist price.
   */
  function getWhitelistPrice() external view returns (uint256) {
    return whitelistPrice;
  }

  /**
   * @dev Return the public price.
   */
  function getPublicPrice() external view returns (uint256) {
    return publicPrice;
  }

  /**
   * @dev Return the amount mint for each cover by a specific signature.
   */
  function getBalanceMintBySign(bytes memory _sign) external view returns (uint256 cover1, uint256 cover2) {
    cover1 = signatureCheckToken1[_sign];
    cover2 = signatureCheckToken2[_sign];
  }

  function getTotalReservedCover() public view returns (uint256) {
    return cover1Reserved + cover2Reserved;
  }

  /**
   * @dev Return the description of the nft.
   */
  function getDescription() external pure returns (string memory) {
    return "UNDOXXED, the finest in digital lifestyle culture, is an annual hybrid book that merges street and lifestyle culture with the digital world. It focuses on fashion, sneakers, and streetwear, cataloging the best of phygital culture. This publication bridges the physical and digital realms within the evolving Web3 space. 3D by Ryan Owers, Art Direction and Music by XERAK.";
  }

  /**
   * @dev Returns the name of a specific tokenId.
   */
  function getTokenName(uint256 _tokenId) external view returns (string memory) {
    if (keccak256(bytes(tokenProofPermanent(_tokenId))) == keccak256(bytes(tokenProof1))) {
      return string("UNDOXXED BOOK vol.1 Black");
    }
    return string("UNDOXXED BOOK vol.1 Purple");
  }

  /**
   * @dev Return the media from ipfs and arweave.
   */
  function getTokenMediaPermanent() external view returns (string[2] memory) {
    return [baseMediaURICover, baseMediaURICoverArweave];
  }

  /**
   * @dev Return the sha256 of the media.
   */
  function getMediaProofPermanent() external pure returns (string memory) {
    return "ab57c888aa9d13029b64f563ec18941eca5054ad002a35fffd4a68022975dc45";
  }

  // OVERRIDE FUNCTIONS

  function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override(ERC2981, ERC721)
    returns(bool)
  {
    return super.supportsInterface(interfaceId);
  }

  function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
    if (!_exists(tokenId)) return "";
    if (keccak256(bytes(tokenProofPermanent(tokenId))) == keccak256(bytes(tokenProof1))) {
      return cover1URI;
    }
    return cover2URI;
  }

  function _burn(uint256 tokenId) internal override(ERC721, ERC721PermanentProof) {
    super._burn(tokenId);
  }

  // INTERNAL FUNCTIONS

  function _mintToken1(address _to, uint256 _amount) internal {
    unchecked {
      for (uint256 i = 0; i < _amount; ++i) {
        uint256 nextId = getAllSupply() + 1;
        _mint(_to, nextId);
        _setPermanentTokenProof(nextId, tokenProof1);
        ++token1;
      }
    }
  }

  function _mintToken2(address _to, uint256 _amount) internal {
    unchecked {
      for (uint256 i = 0; i < _amount; ++i) {
        uint256 nextId = getAllSupply() + 1;
        _mint(_to, nextId);
        _setPermanentTokenProof(nextId, tokenProof2);
        ++token2;
      }
    }
  }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { Status } from "../IUNDOXXED.sol";

library Verification {
  function getMessageHash(address _to, uint256 _amount1, uint256 _amount2, Status _status) internal pure returns (bytes32) {
    return keccak256(
      abi.encodePacked(
        _to,
        _amount1,
        _amount2,
        _status
      )
    );
  }

  function verifySignature(
    address _signer,
    address _to,
    uint256 _amount1,
    uint256 _amount2,
    Status _status,
    bytes memory _signature
  )
    internal
    pure
    returns (bool)
  {
    bytes32 messageHash = getMessageHash(_to, _amount1, _amount2, _status);
    bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

    return recoverSigner(ethSignedMessageHash, _signature) == _signer;
  }

  function getEthSignedMessageHash(
    bytes32 _messageHash
  ) internal pure returns (bytes32) {
    /*
    Signature is produced by signing a keccak256 hash with the following format:
    "\x19Ethereum Signed Message\n" + len(msg) + msg
    */
    return keccak256(
      abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash)
    );
  }

  function recoverSigner(
    bytes32 _ethSignedMessageHash,
    bytes memory _signature
  ) public pure returns (address) {
    (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);
    return ecrecover(_ethSignedMessageHash, v, r, s);
  }

  function splitSignature(
    bytes memory _sig
  ) public pure returns (bytes32 r, bytes32 s, uint8 v) {
    require(_sig.length == 65, "invalid signature length");
    assembly {
      // first 32 bytes, after the length prefix
      r := mload(add(_sig, 32))
      // second 32 bytes
      s := mload(add(_sig, 64))
      // final byte (first byte of the next 32 bytes)
      v := byte(0, mload(add(_sig, 96)))
    }
  }
}