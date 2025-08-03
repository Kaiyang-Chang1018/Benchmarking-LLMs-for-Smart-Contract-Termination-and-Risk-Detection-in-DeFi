// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;

import {Context} from "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
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
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
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
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
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
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC1155/ERC1155.sol)

pragma solidity ^0.8.20;

import {IERC1155} from "./IERC1155.sol";
import {IERC1155Receiver} from "./IERC1155Receiver.sol";
import {IERC1155MetadataURI} from "./extensions/IERC1155MetadataURI.sol";
import {Context} from "../../utils/Context.sol";
import {IERC165, ERC165} from "../../utils/introspection/ERC165.sol";
import {Arrays} from "../../utils/Arrays.sol";
import {IERC1155Errors} from "../../interfaces/draft-IERC6093.sol";

/**
 * @dev Implementation of the basic standard multi-token.
 * See https://eips.ethereum.org/EIPS/eip-1155
 * Originally based on code by Enjin: https://github.com/enjin/erc-1155
 */
abstract contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI, IERC1155Errors {
    using Arrays for uint256[];
    using Arrays for address[];

    mapping(uint256 id => mapping(address account => uint256)) private _balances;

    mapping(address account => mapping(address operator => bool)) private _operatorApprovals;

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
    function uri(uint256 /* id */) public view virtual returns (string memory) {
        return _uri;
    }

    /**
     * @dev See {IERC1155-balanceOf}.
     */
    function balanceOf(address account, uint256 id) public view virtual returns (uint256) {
        return _balances[id][account];
    }

    /**
     * @dev See {IERC1155-balanceOfBatch}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(
        address[] memory accounts,
        uint256[] memory ids
    ) public view virtual returns (uint256[] memory) {
        if (accounts.length != ids.length) {
            revert ERC1155InvalidArrayLength(ids.length, accounts.length);
        }

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts.unsafeMemoryAccess(i), ids.unsafeMemoryAccess(i));
        }

        return batchBalances;
    }

    /**
     * @dev See {IERC1155-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC1155-isApprovedForAll}.
     */
    function isApprovedForAll(address account, address operator) public view virtual returns (bool) {
        return _operatorApprovals[account][operator];
    }

    /**
     * @dev See {IERC1155-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 id, uint256 value, bytes memory data) public virtual {
        address sender = _msgSender();
        if (from != sender && !isApprovedForAll(from, sender)) {
            revert ERC1155MissingApprovalForAll(sender, from);
        }
        _safeTransferFrom(from, to, id, value, data);
    }

    /**
     * @dev See {IERC1155-safeBatchTransferFrom}.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    ) public virtual {
        address sender = _msgSender();
        if (from != sender && !isApprovedForAll(from, sender)) {
            revert ERC1155MissingApprovalForAll(sender, from);
        }
        _safeBatchTransferFrom(from, to, ids, values, data);
    }

    /**
     * @dev Transfers a `value` amount of tokens of type `id` from `from` to `to`. Will mint (or burn) if `from`
     * (or `to`) is the zero address.
     *
     * Emits a {TransferSingle} event if the arrays contain one element, and {TransferBatch} otherwise.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement either {IERC1155Receiver-onERC1155Received}
     *   or {IERC1155Receiver-onERC1155BatchReceived} and return the acceptance magic value.
     * - `ids` and `values` must have the same length.
     *
     * NOTE: The ERC-1155 acceptance check is not performed in this function. See {_updateWithAcceptanceCheck} instead.
     */
    function _update(address from, address to, uint256[] memory ids, uint256[] memory values) internal virtual {
        if (ids.length != values.length) {
            revert ERC1155InvalidArrayLength(ids.length, values.length);
        }

        address operator = _msgSender();

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids.unsafeMemoryAccess(i);
            uint256 value = values.unsafeMemoryAccess(i);

            if (from != address(0)) {
                uint256 fromBalance = _balances[id][from];
                if (fromBalance < value) {
                    revert ERC1155InsufficientBalance(from, fromBalance, value, id);
                }
                unchecked {
                    // Overflow not possible: value <= fromBalance
                    _balances[id][from] = fromBalance - value;
                }
            }

            if (to != address(0)) {
                _balances[id][to] += value;
            }
        }

        if (ids.length == 1) {
            uint256 id = ids.unsafeMemoryAccess(0);
            uint256 value = values.unsafeMemoryAccess(0);
            emit TransferSingle(operator, from, to, id, value);
        } else {
            emit TransferBatch(operator, from, to, ids, values);
        }
    }

    /**
     * @dev Version of {_update} that performs the token acceptance check by calling
     * {IERC1155Receiver-onERC1155Received} or {IERC1155Receiver-onERC1155BatchReceived} on the receiver address if it
     * contains code (eg. is a smart contract at the moment of execution).
     *
     * IMPORTANT: Overriding this function is discouraged because it poses a reentrancy risk from the receiver. So any
     * update to the contract state after this function would break the check-effect-interaction pattern. Consider
     * overriding {_update} instead.
     */
    function _updateWithAcceptanceCheck(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    ) internal virtual {
        _update(from, to, ids, values);
        if (to != address(0)) {
            address operator = _msgSender();
            if (ids.length == 1) {
                uint256 id = ids.unsafeMemoryAccess(0);
                uint256 value = values.unsafeMemoryAccess(0);
                _doSafeTransferAcceptanceCheck(operator, from, to, id, value, data);
            } else {
                _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, values, data);
            }
        }
    }

    /**
     * @dev Transfers a `value` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `from` must have a balance of tokens of type `id` of at least `value` amount.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _safeTransferFrom(address from, address to, uint256 id, uint256 value, bytes memory data) internal {
        if (to == address(0)) {
            revert ERC1155InvalidReceiver(address(0));
        }
        if (from == address(0)) {
            revert ERC1155InvalidSender(address(0));
        }
        (uint256[] memory ids, uint256[] memory values) = _asSingletonArrays(id, value);
        _updateWithAcceptanceCheck(from, to, ids, values, data);
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
     * - `ids` and `values` must have the same length.
     */
    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    ) internal {
        if (to == address(0)) {
            revert ERC1155InvalidReceiver(address(0));
        }
        if (from == address(0)) {
            revert ERC1155InvalidSender(address(0));
        }
        _updateWithAcceptanceCheck(from, to, ids, values, data);
    }

    /**
     * @dev Sets a new URI for all token types, by relying on the token type ID
     * substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * By this mechanism, any occurrence of the `\{id\}` substring in either the
     * URI or any of the values in the JSON file at said URI will be replaced by
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
     * @dev Creates a `value` amount of tokens of type `id`, and assigns them to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _mint(address to, uint256 id, uint256 value, bytes memory data) internal {
        if (to == address(0)) {
            revert ERC1155InvalidReceiver(address(0));
        }
        (uint256[] memory ids, uint256[] memory values) = _asSingletonArrays(id, value);
        _updateWithAcceptanceCheck(address(0), to, ids, values, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_mint}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `values` must have the same length.
     * - `to` cannot be the zero address.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _mintBatch(address to, uint256[] memory ids, uint256[] memory values, bytes memory data) internal {
        if (to == address(0)) {
            revert ERC1155InvalidReceiver(address(0));
        }
        _updateWithAcceptanceCheck(address(0), to, ids, values, data);
    }

    /**
     * @dev Destroys a `value` amount of tokens of type `id` from `from`
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `from` must have at least `value` amount of tokens of type `id`.
     */
    function _burn(address from, uint256 id, uint256 value) internal {
        if (from == address(0)) {
            revert ERC1155InvalidSender(address(0));
        }
        (uint256[] memory ids, uint256[] memory values) = _asSingletonArrays(id, value);
        _updateWithAcceptanceCheck(from, address(0), ids, values, "");
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_burn}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `from` must have at least `value` amount of tokens of type `id`.
     * - `ids` and `values` must have the same length.
     */
    function _burnBatch(address from, uint256[] memory ids, uint256[] memory values) internal {
        if (from == address(0)) {
            revert ERC1155InvalidSender(address(0));
        }
        _updateWithAcceptanceCheck(from, address(0), ids, values, "");
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the zero address.
     */
    function _setApprovalForAll(address owner, address operator, bool approved) internal virtual {
        if (operator == address(0)) {
            revert ERC1155InvalidOperator(address(0));
        }
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Performs an acceptance check by calling {IERC1155-onERC1155Received} on the `to` address
     * if it contains code at the moment of execution.
     */
    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 value,
        bytes memory data
    ) private {
        if (to.code.length > 0) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, value, data) returns (bytes4 response) {
                if (response != IERC1155Receiver.onERC1155Received.selector) {
                    // Tokens rejected
                    revert ERC1155InvalidReceiver(to);
                }
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    // non-ERC1155Receiver implementer
                    revert ERC1155InvalidReceiver(to);
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        }
    }

    /**
     * @dev Performs a batch acceptance check by calling {IERC1155-onERC1155BatchReceived} on the `to` address
     * if it contains code at the moment of execution.
     */
    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    ) private {
        if (to.code.length > 0) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, values, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
                    // Tokens rejected
                    revert ERC1155InvalidReceiver(to);
                }
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    // non-ERC1155Receiver implementer
                    revert ERC1155InvalidReceiver(to);
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        }
    }

    /**
     * @dev Creates an array in memory with only one value for each of the elements provided.
     */
    function _asSingletonArrays(
        uint256 element1,
        uint256 element2
    ) private pure returns (uint256[] memory array1, uint256[] memory array2) {
        /// @solidity memory-safe-assembly
        assembly {
            // Load the free memory pointer
            array1 := mload(0x40)
            // Set array length to 1
            mstore(array1, 1)
            // Store the single element at the next word after the length (where content starts)
            mstore(add(array1, 0x20), element1)

            // Repeat for next array locating it right after the first array
            array2 := add(array1, 0x40)
            mstore(array2, 1)
            mstore(add(array2, 0x20), element2)

            // Update the free memory pointer by pointing after the second array
            mstore(0x40, add(array2, 0x40))
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.1) (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.20;

import {IERC165} from "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` amount of tokens of type `id` are transferred from `from` to `to` by `operator`.
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
     * @dev Returns the value of tokens of token type `id` owned by `account`.
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
    function balanceOfBatch(
        address[] calldata accounts,
        uint256[] calldata ids
    ) external view returns (uint256[] memory);

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
     * @dev Transfers a `value` amount of tokens of type `id` from `from` to `to`.
     *
     * WARNING: This function can potentially allow a reentrancy attack when transferring tokens
     * to an untrusted contract, when invoking {onERC1155Received} on the receiver.
     * Ensure to follow the checks-effects-interactions pattern and consider employing
     * reentrancy guards when interacting with untrusted contracts.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `value` amount.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(address from, address to, uint256 id, uint256 value, bytes calldata data) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * WARNING: This function can potentially allow a reentrancy attack when transferring tokens
     * to an untrusted contract, when invoking {onERC1155BatchReceived} on the receiver.
     * Ensure to follow the checks-effects-interactions pattern and consider employing
     * reentrancy guards when interacting with untrusted contracts.
     *
     * Emits either a {TransferSingle} or a {TransferBatch} event, depending on the length of the array arguments.
     *
     * Requirements:
     *
     * - `ids` and `values` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.20;

import {IERC165} from "../../utils/introspection/IERC165.sol";

/**
 * @dev Interface that must be implemented by smart contracts in order to receive
 * ERC-1155 token transfers.
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
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC1155/extensions/IERC1155MetadataURI.sol)

pragma solidity ^0.8.20;

import {IERC1155} from "../IERC1155.sol";

/**
 * @dev Interface of the optional ERC1155MetadataExtension interface, as defined
 * in the https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[EIP].
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
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
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
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
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
     * ```
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
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/ERC20Burnable.sol)

pragma solidity ^0.8.20;

import {ERC20} from "../ERC20.sol";
import {Context} from "../../../utils/Context.sol";

/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
abstract contract ERC20Burnable is Context, ERC20 {
    /**
     * @dev Destroys a `value` amount of tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 value) public virtual {
        _burn(_msgSender(), value);
    }

    /**
     * @dev Destroys a `value` amount of tokens from `account`, deducting from
     * the caller's allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `value`.
     */
    function burnFrom(address account, uint256 value) public virtual {
        _spendAllowance(account, _msgSender(), value);
        _burn(account, value);
    }
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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Arrays.sol)

pragma solidity ^0.8.20;

import {StorageSlot} from "./StorageSlot.sol";
import {Math} from "./math/Math.sol";

/**
 * @dev Collection of functions related to array types.
 */
library Arrays {
    using StorageSlot for bytes32;

    /**
     * @dev Searches a sorted `array` and returns the first index that contains
     * a value greater or equal to `element`. If no such index exists (i.e. all
     * values in the array are strictly less than `element`), the array length is
     * returned. Time complexity O(log n).
     *
     * `array` is expected to be sorted in ascending order, and to contain no
     * repeated elements.
     */
    function findUpperBound(uint256[] storage array, uint256 element) internal view returns (uint256) {
        uint256 low = 0;
        uint256 high = array.length;

        if (high == 0) {
            return 0;
        }

        while (low < high) {
            uint256 mid = Math.average(low, high);

            // Note that mid will always be strictly less than high (i.e. it will be a valid array index)
            // because Math.average rounds towards zero (it does integer division with truncation).
            if (unsafeAccess(array, mid).value > element) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        // At this point `low` is the exclusive upper bound. We will return the inclusive upper bound.
        if (low > 0 && unsafeAccess(array, low - 1).value == element) {
            return low - 1;
        } else {
            return low;
        }
    }

    /**
     * @dev Access an array in an "unsafe" way. Skips solidity "index-out-of-range" check.
     *
     * WARNING: Only use if you are certain `pos` is lower than the array length.
     */
    function unsafeAccess(address[] storage arr, uint256 pos) internal pure returns (StorageSlot.AddressSlot storage) {
        bytes32 slot;
        // We use assembly to calculate the storage slot of the element at index `pos` of the dynamic array `arr`
        // following https://docs.soliditylang.org/en/v0.8.20/internals/layout_in_storage.html#mappings-and-dynamic-arrays.

        /// @solidity memory-safe-assembly
        assembly {
            mstore(0, arr.slot)
            slot := add(keccak256(0, 0x20), pos)
        }
        return slot.getAddressSlot();
    }

    /**
     * @dev Access an array in an "unsafe" way. Skips solidity "index-out-of-range" check.
     *
     * WARNING: Only use if you are certain `pos` is lower than the array length.
     */
    function unsafeAccess(bytes32[] storage arr, uint256 pos) internal pure returns (StorageSlot.Bytes32Slot storage) {
        bytes32 slot;
        // We use assembly to calculate the storage slot of the element at index `pos` of the dynamic array `arr`
        // following https://docs.soliditylang.org/en/v0.8.20/internals/layout_in_storage.html#mappings-and-dynamic-arrays.

        /// @solidity memory-safe-assembly
        assembly {
            mstore(0, arr.slot)
            slot := add(keccak256(0, 0x20), pos)
        }
        return slot.getBytes32Slot();
    }

    /**
     * @dev Access an array in an "unsafe" way. Skips solidity "index-out-of-range" check.
     *
     * WARNING: Only use if you are certain `pos` is lower than the array length.
     */
    function unsafeAccess(uint256[] storage arr, uint256 pos) internal pure returns (StorageSlot.Uint256Slot storage) {
        bytes32 slot;
        // We use assembly to calculate the storage slot of the element at index `pos` of the dynamic array `arr`
        // following https://docs.soliditylang.org/en/v0.8.20/internals/layout_in_storage.html#mappings-and-dynamic-arrays.

        /// @solidity memory-safe-assembly
        assembly {
            mstore(0, arr.slot)
            slot := add(keccak256(0, 0x20), pos)
        }
        return slot.getUint256Slot();
    }

    /**
     * @dev Access an array in an "unsafe" way. Skips solidity "index-out-of-range" check.
     *
     * WARNING: Only use if you are certain `pos` is lower than the array length.
     */
    function unsafeMemoryAccess(uint256[] memory arr, uint256 pos) internal pure returns (uint256 res) {
        assembly {
            res := mload(add(add(arr, 0x20), mul(pos, 0x20)))
        }
    }

    /**
     * @dev Access an array in an "unsafe" way. Skips solidity "index-out-of-range" check.
     *
     * WARNING: Only use if you are certain `pos` is lower than the array length.
     */
    function unsafeMemoryAccess(address[] memory arr, uint256 pos) internal pure returns (address res) {
        assembly {
            res := mload(add(add(arr, 0x20), mul(pos, 0x20)))
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Base64.sol)

pragma solidity ^0.8.20;

/**
 * @dev Provides a set of functions to operate with Base64 strings.
 */
library Base64 {
    /**
     * @dev Base64 Encoding/Decoding Table
     */
    string internal constant _TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    /**
     * @dev Converts a `bytes` to its Bytes64 `string` representation.
     */
    function encode(bytes memory data) internal pure returns (string memory) {
        /**
         * Inspired by Brecht Devos (Brechtpd) implementation - MIT licence
         * https://github.com/Brechtpd/base64/blob/e78d9fd951e7b0977ddca77d92dc85183770daf4/base64.sol
         */
        if (data.length == 0) return "";

        // Loads the table into memory
        string memory table = _TABLE;

        // Encoding takes 3 bytes chunks of binary data from `bytes` data parameter
        // and split into 4 numbers of 6 bits.
        // The final Base64 length should be `bytes` data length multiplied by 4/3 rounded up
        // - `data.length + 2`  -> Round up
        // - `/ 3`              -> Number of 3-bytes chunks
        // - `4 *`              -> 4 characters for each chunk
        string memory result = new string(4 * ((data.length + 2) / 3));

        /// @solidity memory-safe-assembly
        assembly {
            // Prepare the lookup table (skip the first "length" byte)
            let tablePtr := add(table, 1)

            // Prepare result pointer, jump over length
            let resultPtr := add(result, 32)

            // Run over the input, 3 bytes at a time
            for {
                let dataPtr := data
                let endPtr := add(data, mload(data))
            } lt(dataPtr, endPtr) {

            } {
                // Advance 3 bytes
                dataPtr := add(dataPtr, 3)
                let input := mload(dataPtr)

                // To write each character, shift the 3 bytes (18 bits) chunk
                // 4 times in blocks of 6 bits for each character (18, 12, 6, 0)
                // and apply logical AND with 0x3F which is the number of
                // the previous character in the ASCII table prior to the Base64 Table
                // The result is then added to the table to get the character to write,
                // and finally write it in the result pointer but with a left shift
                // of 256 (1 byte) - 8 (1 ASCII char) = 248 bits

                mstore8(resultPtr, mload(add(tablePtr, and(shr(18, input), 0x3F))))
                resultPtr := add(resultPtr, 1) // Advance

                mstore8(resultPtr, mload(add(tablePtr, and(shr(12, input), 0x3F))))
                resultPtr := add(resultPtr, 1) // Advance

                mstore8(resultPtr, mload(add(tablePtr, and(shr(6, input), 0x3F))))
                resultPtr := add(resultPtr, 1) // Advance

                mstore8(resultPtr, mload(add(tablePtr, and(input, 0x3F))))
                resultPtr := add(resultPtr, 1) // Advance
            }

            // When data `bytes` is not exactly 3 bytes long
            // it is padded with `=` characters at the end
            switch mod(mload(data), 3)
            case 1 {
                mstore8(sub(resultPtr, 1), 0x3d)
                mstore8(sub(resultPtr, 2), 0x3d)
            }
            case 2 {
                mstore8(sub(resultPtr, 1), 0x3d)
            }
        }

        return result;
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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/ReentrancyGuard.sol)

pragma solidity ^0.8.20;

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
abstract contract ReentrancyGuard {
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
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
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
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/StorageSlot.sol)
// This file was procedurally generated from scripts/generate/templates/StorageSlot.js.

pragma solidity ^0.8.20;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```solidity
 * contract ERC1967 {
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

    struct StringSlot {
        string value;
    }

    struct BytesSlot {
        bytes value;
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

    /**
     * @dev Returns an `StringSlot` with member `value` located at `slot`.
     */
    function getStringSlot(bytes32 slot) internal pure returns (StringSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `StringSlot` representation of the string storage pointer `store`.
     */
    function getStringSlot(string storage store) internal pure returns (StringSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := store.slot
        }
    }

    /**
     * @dev Returns an `BytesSlot` with member `value` located at `slot`.
     */
    function getBytesSlot(bytes32 slot) internal pure returns (BytesSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BytesSlot` representation of the bytes storage pointer `store`.
     */
    function getBytesSlot(bytes storage store) internal pure returns (BytesSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := store.slot
        }
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
pragma solidity 0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../token/Bean.sol";
import "./interface/IReferral.sol";
import "../utils/Registry.sol";

/**
 * @title Referral Contract
 * @notice This contract manages a referral system where users can refer others and earn rewards.
 * @dev It allows setting referral relationships, calculating rewards, and managing referral-related data.
 */
contract Referral is Ownable, IReferral {
    /// @notice Registry contract to fetch contract addresses.
    Registry public registry;

    /// @notice Array of referral brackets based on the amount referred.
    uint256[] public amtReferredBracket;
    /// @notice 2D array storing interest rates for different supply markers and referral brackets.
    uint256[][] public interestSet;
    /// @notice Array of supply markers for determining referral rewards.
    uint256[] public supplyMarkers;
    /// @notice Array of reward rates for referred users.
    uint256[] public referredRewardRates;
    /// @notice Default referrer address.
    address public defaultReferrer;
    /// @notice Indicates whether the interest rates have been set.
    bool _interestSet;

    /// @notice Maps addresses to their referral data.
    mapping(address => Referrer) public referrer;
    /// @notice Maps addresses to their registration status.
    mapping(address => bool) public isRegistered;

    // =============================================================
    //                          EVENTS
    // =============================================================

    /// @notice Emitted when a referral is recorded.
    event ReferralRecorded(address indexed user, address indexed referrer);
    /// @notice Emitted when a referral is removed.
    event ReferralRemoved(address indexed user);

    // =============================================================
    //                          CONSTRUCTOR
    // =============================================================

    /**
     * @notice Initializes the Referral contract.
     */
    constructor() Ownable(msg.sender) {
        supplyMarkers = new uint256[](11);
        referredRewardRates = new uint256[](11);
    }

    // =============================================================
    //                          MODIFIERS
    // =============================================================

    /// @notice Ensures that only registered contracts can call the function.
    modifier onlyRegistered() {
        require(isRegistered[msg.sender], "Referral: Not authorized");
        _;
    }

    // =============================================================
    //                          SETTERS
    // =============================================================

    /**
     * @notice Adds a referrer for a new user.
     * @dev Can only be called by registered contracts.
     * @param _referred The address of the user being referred.
     * @param _referrer The address of the referrer.
     */
    function addReferrer(
        address _referred,
        address _referrer
    ) external onlyRegistered {
        require(
            referrer[_referred].referrer == address(0),
            "Referral: Referrer already set"
        );
        require(
            _referrer != _referred,
            "Referral: Cannot set referrer to yourself"
        );
        require(
            !isReferral(_referrer, _referred),
            "Referral: Circular referral not allowed"
        );
        require(isReferrerValid(_referrer), "Referral: Invalid referrer");

        referrer[_referrer].referrals.push(_referred);
        referrer[_referrer].referralCount++;
        referrer[_referred].wasReferred = true;
        referrer[_referred].referrer = _referrer;
        emit ReferralRecorded(_referred, _referrer);
    }

    /**
     * @notice Sets the interest rates for referral rewards.
     * @dev Can only be called by the owner.
     * @param _newInterestSet A 2D array of interest rates.
     */
    function setInterestRate(
        uint256[][] memory _newInterestSet
    ) external onlyOwner {
        require(_newInterestSet.length > 0, "Referral: Empty array");

        interestSet = new uint256[][](_newInterestSet.length);
        _interestSet = true;
        for (uint256 i = 0; i < _newInterestSet.length; i++) {
            require(_newInterestSet[i].length > 0, "Referral: Empty sub-array");
            interestSet[i] = _newInterestSet[i];
        }
    }

    /**
     * @notice Sets the supply markers for referral rewards.
     * @dev Can only be called by the owner.
     * @param _markers An array of supply markers.
     */
    function setSupplyMarkers(uint256[] memory _markers) external onlyOwner {
        require(_markers.length > 0, "Referral: Empty markers array");

        for (uint256 i = 0; i < _markers.length; i++) {
            supplyMarkers[i] = _markers[i];
        }
    }

    /**
     * @notice Sets the reward rates for referred users.
     * @dev Can only be called by the owner.
     * @param _rewards An array of reward rates.
     */
    function setReferredRewards(uint256[] memory _rewards) external onlyOwner {
        require(_rewards.length > 0, "Referral: Empty markers array");

        for (uint256 i = 0; i < _rewards.length; i++) {
            referredRewardRates[i] = _rewards[i];
        }
    }

    /**
     * @notice Registers a contract as authorized to perform restricted operations.
     * @dev Can only be called by the owner.
     * @param _contract The address of the contract to register.
     */
    function setRegisteredContracts(address _contract) external onlyOwner {
        isRegistered[_contract] = true;
    }

    /**
     * @notice Sets the referral brackets based on the amount referred.
     * @dev Can only be called by the owner.
     * @param _amtReferredBracket An array of referral brackets.
     */
    function setAmtReferredBracket(
        uint256[] memory _amtReferredBracket
    ) external onlyOwner {
        require(_amtReferredBracket.length > 0, "Referral: Empty array");

        amtReferredBracket = _amtReferredBracket;
    }

    /**
     * @notice Sets the registry contract address.
     * @dev Can only be called by the owner.
     * @param _registry The address of the Registry contract.
     */
    function setRegistry(Registry _registry) external onlyOwner {
        registry = _registry;
    }

    /**
     * @notice Rewards the referrer for a successful referral.
     * @dev Can only be called by registered contracts.
     * @param _sender The address of the user who made a purchase.
     * @param amount The amount of the purchase.
     */
    function rewardForReferrer(
        address _sender,
        uint256 amount
    ) external onlyRegistered {
        require(referredRewardRates.length != 0, "referredRewardRates not set");
        require(supplyMarkers.length != 0, "supplyMarkers not set");
        require(amtReferredBracket.length != 0, "supplyMarkers not set");
        require(_interestSet, "interest not set");

        referrer[_sender].buyCount++;
        address _referrer = referrer[_sender].referrer;
        uint256 returnRate = getUserInterest(_referrer);
        uint256 reward = (amount * returnRate) / 10000;
        if (reward > 0) {
            Bean token = Bean(registry.getContractAddress("Bean"));
            token.mint(_referrer, reward);
        }
        referrer[_referrer].rewarded += reward;
    }

    // =============================================================
    //                          GETTERS
    // =============================================================

    /**
     * @notice Checks if an address is a contract.
     * @param addr The address to check.
     * @return isContractBool True if the address is a contract, otherwise false.
     */
    function isContract(
        address addr
    ) internal view returns (bool isContractBool) {
        uint size;
        assembly {
            size := extcodesize(addr)
        }
        isContractBool = size > 0;
    }

    /**
     * @notice Gets the current supply marker based on the total supply of the Bean token.
     * @return The current supply marker.
     */
    function getMarker() public view returns (uint256) {
        uint256 totalSupply = IERC20(registry.getContractAddress("Bean"))
            .totalSupply();
        uint256 supplyMarker = 0;

        if (totalSupply > supplyMarkers[supplyMarkers.length - 1]) {
            return supplyMarkers.length - 1;
        }

        for (uint256 index = 0; index < supplyMarkers.length - 1; index++) {
            if (
                totalSupply > supplyMarkers[index] &&
                totalSupply <= supplyMarkers[index + 1]
            ) {
                supplyMarker = index;
                break;
            }
        }

        return supplyMarker;
    }

    /**
     * @notice Gets the interest marker for a referrer based on their referral count.
     * @param _referrer The address of the referrer.
     * @return The interest marker for the referrer.
     */
    function getUsersInterestMarker(
        address _referrer
    ) public view returns (uint256) {
        uint256 referredCount = referrer[_referrer].referralCount;

        uint256 bracketIndex = 0;
        while (
            bracketIndex < amtReferredBracket.length &&
            referredCount >= amtReferredBracket[bracketIndex]
        ) {
            bracketIndex++;
        }
        require(
            bracketIndex < interestSet.length,
            "Referral: Invalid bracket index"
        );
        return bracketIndex;
    }

    /**
     * @notice Checks if a referrer is eligible for rewards.
     * @param _referrer The address of the referrer.
     * @return True if the referrer is eligible, otherwise false.
     */
    function eligibleForReward(address _referrer) external view returns (bool) {
        if (
            referrer[_referrer].buyCount < 10 &&
            referrer[_referrer].referrer != address(0)
        ) {
            return true;
        } else {
            return false;
        }
    }

    /**
     * @notice Checks if a referral relationship exists between two addresses.
     * @param _referral The address of the referred user.
     * @param _referrer The address of the referrer.
     * @return True if the referral relationship exists, otherwise false.
     */
    function isReferral(
        address _referral,
        address _referrer
    ) internal view returns (bool) {
        uint256 referralCount = referrer[_referrer].referralCount;
        for (uint256 i = 0; i < referralCount; i++) {
            address referredAddress = referrer[_referrer].referrals[i];
            if (referredAddress == _referral) {
                return true;
            }
        }
        return false;
    }

    /**
     * @notice Checks if a referrer is valid.
     * @param _referrer The address of the referrer.
     * @return True if the referrer is valid, otherwise false.
     */
    function isReferrerValid(address _referrer) public view returns (bool) {
        if (
            _referrer == 0x000000000000000000000000000000000000dEaD ||
            isContract(_referrer)
        ) {
            return false;
        }
        return true;
    }

    /**
     * @notice Gets the referral attributes for a specific address.
     * @param _address The address to query.
     * @return The referral attributes for the address.
     */
    function getAttributes(
        address _address
    ) external view returns (Referrer memory) {
        Referrer memory _attributes = referrer[_address];
        return _attributes;
    }

    /**
     * @notice Gets the interest rate for a referrer.
     * @param _referrer The address of the referrer.
     * @return The interest rate for the referrer.
     */
    function getUserInterest(
        address _referrer
    ) internal view returns (uint256) {
        uint256 globalMarker = getMarker();
        uint256[] memory interestBracket = interestSet[globalMarker];

        uint256 userMarker = getUsersInterestMarker(_referrer);
        uint256 userInterest = interestBracket[userMarker];

        return userInterest;
    }

    /**
     * @notice Gets the list of referrals for a specific address.
     * @param _address The address to query.
     * @return An array of referral addresses.
     */
    function checkReferrals(
        address _address
    ) external view returns (address[] memory) {
        address[] memory _referrals = referrer[_address].referrals;
        return _referrals;
    }

    /**
     * @notice Gets referral data for a specific address.
     * @param _address The address to query.
     * @return The referral count, interest rate, and next referral count.
     */
    function getReferralData(
        address _address
    ) external view returns (uint256, uint256, uint256) {
        uint256 referredCount = referrer[_address].referralCount;

        uint256 bracketIndex = 0;
        while (
            bracketIndex < amtReferredBracket.length &&
            referredCount >= amtReferredBracket[bracketIndex]
        ) {
            bracketIndex++;
        }

        uint256 nextReferralCount = bracketIndex < amtReferredBracket.length
            ? amtReferredBracket[bracketIndex]
            : 0;

        return (
            referrer[_address].referralCount,
            getUserInterest(_address),
            nextReferralCount
        );
    }

    /**
     * @notice Gets the current referred discount rate.
     * @return The current referred discount rate.
     */
    function getReferredDiscount() external view returns (uint256) {
        uint256 _getMarker = getMarker();
        uint256 reward = referredRewardRates[_getMarker];
        return reward;
    }

    /**
     * @notice Gets the referrer for a specific user.
     * @param _user The address of the user.
     * @return The address of the referrer.
     */
    function yourReferrer(address _user) external view returns (address) {
        return referrer[_user].referrer;
    }

    /**
     * @notice Gets the number of discounts left for a specific user.
     * @param _user The address of the user.
     * @return The number of discounts left.
     */
    function discountLeft(address _user) external view returns (uint256) {
        return 10 - referrer[_user].buyCount;
    }

    /**
     * @notice Gets the total rewards received by a specific user.
     * @param _user The address of the user.
     * @return The total rewards received.
     */
    function totalRewardsReceived(
        address _user
    ) external view returns (uint256) {
        return referrer[_user].rewarded;
    }

    /**
     * @notice Calculates the discounted price for a given principal amount.
     * @param _principal The principal amount.
     * @return The discounted price.
     */
    function getDiscountedPrice(
        uint256 _principal
    ) external view returns (uint256) {
        uint256 _getMarker = getMarker();
        uint256 reward = referredRewardRates[_getMarker];
        uint256 _discountedPrice = (_principal * reward) / 10000;
        return _discountedPrice;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "./interface/Formatters.sol";
import "./interface/ISavings.sol";
import "./Referral.sol";
import "../utils/Registry.sol";
import "../utils/GlobalMarker.sol";
import "../utils/Event.sol";
import "./interface/IInterestRateModel.sol";

/**
 * @title Savings Contract
 * @notice This contract allows users to create savings positions, earn interest, and take loans against their savings.
 * @dev It uses ERC1155 for representing savings positions and integrates with referral and event systems.
 */
contract Savings is ISavings, ERC1155, Ownable, ReentrancyGuard {
    using Strings for uint256;
    using Formatters for uint256;

    /// @notice System-wide variables for managing savings.
    System public system;
    /// @notice Referral contract for managing referral rewards.
    Referral public referral;
    /// @notice Registry contract to fetch contract addresses.
    Registry public registry;
    /// @notice Metadata for the Savings CFA (Collateralized Financial Agreement).
    Metadata public metadata;
    /// @notice The contract URI for metadata.
    string public contractUri;
    /// @notice Indicates whether the event system is active.
    bool public isEventActive;
    /// @notice Address of the manager with restricted permissions.
    address public manager;
    /// @notice Indicates whether the contract is paused.
    bool public emergencyPause;
    /// @notice Total number of loans created.
    uint256 public totalLoans;

    string public name;
    string public symbol;

    /// @notice Maps token IDs to their loan details.
    mapping(uint256 => Loan) public loan;
    /// @notice Maps token IDs to their attributes.
    mapping(uint256 => Attributes) public attributes;

    // =============================================================
    //                          EVENTS
    // =============================================================

    /// @notice Emitted when a new savings position is created.
    event SavingsCreated(Attributes _attribute, address _sender);

    /// @notice Emitted when a savings position is withdrawn.
    event SavingsWithdrawn(
        Attributes _attribute,
        uint256 _time,
        address _sender
    );

    /// @notice Emitted when a savings position is burned.
    event SavingsBurned(Attributes _attribute, uint256 _time, address _sender);

    /// @notice Emitted when a loan is created.
    event LoanCreated(uint256 _id, uint256 _totalLoan, address _sender);

    /// @notice Emitted when a loan is repaid.
    event LoanRepaid(uint256 _id, address _sender);

    /// @notice Emitted when metadata is updated.
    event MetadataUpdate(uint256 _tokenId);

    /// @notice Emitted when the contract URI is updated.
    event ContractURIUpdated();

    /// @notice Emitted when the name of the contract is updated.
    event UpdateNameEvent(string oldName, string newName);

    /// @notice Emitted when the symbol of the contract is updated.
    event UpdateSymbolEvent(string oldSymbol, string newSymbol);

    /// @notice Emitted when the manager address is updated.
    event ManagerUpdated(
        address indexed oldManager,
        address indexed newManager
    );

    /// @notice Emitted when the contract is paused or unpaused.
    event Paused(bool emergencyPause);

    // =============================================================
    //                          MODIFIERS
    // =============================================================

    /// @notice Ensures that only the owner or manager can call the function.
    modifier onlyOwnerOrManager() {
        require(
            msg.sender == owner() || msg.sender == manager,
            "Savings: Caller is not the owner or manager"
        );
        _;
    }

    // =============================================================
    //                          CONSTRUCTOR
    // =============================================================

    /**
     * @notice Initializes the Savings contract.
     */
    constructor() ERC1155("") Ownable(msg.sender) {
        system.idCounter = 1;
    }

    // =============================================================
    //                          MAIN FUNCTIONS
    // =============================================================

    /**
     * @notice Mints a new savings position.
     * @dev Users can lock their tokens for a fixed period and earn interest.
     * @param _principal The amount of tokens to lock.
     * @param _cfaLife The duration of the savings position in years.
     * @param _qty The number of positions to mint.
     * @param _referrer The address of the referrer (optional).
     */
    function mintSavings(
        uint256 _principal,
        uint256 _cfaLife,
        uint256 _qty,
        address _referrer
    ) external nonReentrant {
        require(!emergencyPause, "Savings: Mintings are paused");
        require(_qty <= 999, "Savings: Max qty reached");
        require(
            GlobalMarker(registry.getContractAddress("GlobalMarker"))
                .isInterestSet(),
            "GlobalSupply: Interest not yet set"
        );
        require(
            _principal <= 99999000000000000000000 &&
                _principal >= 10000000000000,
            "Savings: Invalid Principal"
        );
        Bean token = Bean(registry.getContractAddress("Bean"));
        require(
            token.totalSupply() < 21000000000 ether,
            "Savings: Max Supply Reached"
        );

        // If a referrer address is provided, register it in the Referral contract
        if (_referrer != address(0)) {
            Referral(registry.getContractAddress("Referral")).addReferrer(
                msg.sender,
                _referrer
            );
        }

        for (uint256 i = 0; i < _qty; i++) {
            // Check if the user is eligible for a referral reward
            if (
                (
                    Referral(registry.getContractAddress("Referral"))
                        .eligibleForReward(msg.sender)
                )
            ) {
                // Reward the referrer based on the principal amount
                Referral(registry.getContractAddress("Referral"))
                    .rewardForReferrer(msg.sender, _principal);

                // Retrieve the discount percentage for referred users
                uint256 discount = Referral(
                    registry.getContractAddress("Referral")
                ).getReferredDiscount();

                // Store the discount in the attributes mapping for reference
                attributes[system.idCounter].discountGiven = discount;

                // Calculate the discounted amount the user has to pay
                uint256 amtPayable = _principal -
                    ((_principal * discount) / 10000);

                // Calculate the discount amount that will be minted
                uint256 discounted = ((_principal * discount) / 10000);

                // Mint the discounted amount to this contract to compensate for the referral discount
                token.mint(address(this), discounted);

                // Transfer the discounted principal amount from the user to this contract
                IERC20(registry.getContractAddress("Bean")).transferFrom(
                    msg.sender,
                    address(this),
                    amtPayable
                );
            } else {
                // If no referral discount applies, transfer the full principal amount
                IERC20(registry.getContractAddress("Bean")).transferFrom(
                    msg.sender,
                    address(this),
                    _principal
                );
            }

            // Setting Attributes
            require(
                _cfaLife >= system.minLife && system.maxLife >= _cfaLife,
                "Savings: Invalid CFA life duration"
            );
            IInterestRateModel interestModel = IInterestRateModel(
                registry.getContractAddress("InterestRateModel")
            );
            uint256 totalReward = (
                interestModel.getSavingsOutcome(
                    _cfaLife,
                    GlobalMarker(registry.getContractAddress("GlobalMarker"))
                        .getMarker(),
                    _principal
                )
            );

            // Store savings details
            attributes[system.idCounter].timeCreated = block.timestamp;
            attributes[system.idCounter].cfaLifeTimestamp =
                block.timestamp +
                (30 days * 12 * _cfaLife);
            attributes[system.idCounter].cfaLife = _cfaLife;
            attributes[system.idCounter].effectiveInterestTime = block
                .timestamp;
            attributes[system.idCounter].principal = _principal;
            attributes[system.idCounter].marker = GlobalMarker(
                registry.getContractAddress("GlobalMarker")
            ).getMarker();
            attributes[system.idCounter].systemInterestRate = GlobalMarker(
                registry.getContractAddress("GlobalMarker")
            ).getInterestRate();
            emit SavingsCreated(attributes[system.idCounter], msg.sender);

            // Mint the calculated reward amount to this contract
            token.mint(address(this), totalReward);

            // Mint an NFT representing the savings position
            _mint(msg.sender, system.idCounter, 1, "");

            // If an event is active, update the event contract with the new value
            if (isEventActive) {
                Event eventContract = Event(
                    registry.getContractAddress("EventSavings")
                );
                eventContract.addValue(msg.sender, _principal);
            }

            // Update System Counters
            system.idCounter++;
            system.totalActiveCfa++;
        }
    }

    /**
     * @notice Burns a savings position when it has matured.
     * @param _id The ID of the savings position.
     */
    function _burnSavings(uint256 _id) internal {
        delete attributes[_id];
        _burn(msg.sender, _id, 1);
        system.totalActiveCfa--;
    }

    /**
     * @notice Withdraws tokens from a savings position after maturity.
     * @param _id The ID of the savings position.
     */
    function withdrawSavings(uint256 _id) external nonReentrant {
        require(
            block.timestamp > attributes[_id].cfaLifeTimestamp,
            "Savings: CFA not yet matured"
        );
        require(!loan[_id].onLoan, "Savings: On Loan");

        uint256 interestRate = IInterestRateModel(
            registry.getContractAddress("InterestRateModel")
        ).getSavingsOutcome(
                attributes[_id].cfaLife,
                GlobalMarker(registry.getContractAddress("GlobalMarker"))
                    .getMarker(),
                attributes[_id].principal
            );

        Bean token = Bean(registry.getContractAddress("Bean"));
        token.transfer(msg.sender, interestRate + attributes[_id].principal);
        token.addTotalRewarded(interestRate, msg.sender);
        emit SavingsWithdrawn(attributes[_id], block.timestamp, msg.sender);
        emit SavingsBurned(attributes[_id], block.timestamp, msg.sender);
        _burnSavings(_id);
    }

    // =============================================================
    //                          LOAN FUNCTIONS
    // =============================================================

    /**
     * @notice Creates a loan against a savings position.
     * @param _id The ID of the savings position.
     */
    function createLoan(uint256 _id) external nonReentrant {
        require(balanceOf(msg.sender, _id) == 1, "Savings: not the owner");
        require(!loan[_id].onLoan, "Savings: Loan already created");
        require(
            block.timestamp < attributes[_id].cfaLifeTimestamp,
            "Savings: CFA has expired"
        );

        uint256 _yieldedInterest = getYieldedInterest(_id);

        uint256 loanedPrincipal = ((attributes[_id].principal +
            _yieldedInterest) * 25) / 100;
        Bean token = Bean(registry.getContractAddress("Bean"));
        token.mint(msg.sender, loanedPrincipal);

        loan[_id].onLoan = true;
        loan[_id].loanBalance = loanedPrincipal;
        loan[_id].timeWhenLoaned = block.timestamp;

        totalLoans++;
        emit LoanCreated(_id, loanedPrincipal, msg.sender);
        emit MetadataUpdate(_id);
    }

    /**
     * @notice Repays a loan against a savings position.
     * @param _id The ID of the savings position.
     */
    function repayLoan(uint256 _id) external nonReentrant {
        require(loan[_id].onLoan, "Savings: Loan invalid"); // Ensure that the loan exists and is active

        // Transfer the loan balance from the borrower to the contract
        IERC20(registry.getContractAddress("Bean")).transferFrom(
            msg.sender,
            address(this),
            loan[_id].loanBalance
        );

        // Burn the repaid tokens, effectively reducing the supply
        Bean(registry.getContractAddress("Bean")).burn(loan[_id].loanBalance);

        // Calculate the time elapsed since the loan was taken
        uint256 timePassed = block.timestamp - loan[_id].timeWhenLoaned;

        // Extend the savings maturity timestamp by the duration of the loan
        attributes[_id].cfaLifeTimestamp += timePassed;

        // Adjust the effective interest time to account for the loan period
        uint256 oldTime = attributes[_id].effectiveInterestTime;
        attributes[_id].effectiveInterestTime =
            block.timestamp -
            (loan[_id].timeWhenLoaned - oldTime);

        // Clear the loan balance and mark the loan as repaid
        loan[_id].loanBalance = 0;
        loan[_id].onLoan = false;

        // Decrease the total active loans count
        totalLoans--;

        // Emit events to notify of the repayment and metadata update
        emit LoanRepaid(_id, msg.sender);
        emit MetadataUpdate(_id);
    }

    // =============================================================
    //                          SETTERS
    // =============================================================

    /**
     * @notice Sets the manager address.
     * @dev Can only be called by the owner.
     * @param _newManager The new manager address.
     */
    function setManager(address _newManager) external onlyOwner {
        emit ManagerUpdated(manager, _newManager);
        manager = _newManager;
    }

    /**
     * @notice Toggles the pause state of the contract.
     * @dev Can only be called by the owner or manager.
     */
    function togglePause() external onlyOwnerOrManager {
        emergencyPause = !emergencyPause;
        emit Paused(emergencyPause);
    }

    /**
     * @notice Sets the contract URI for metadata.
     * @dev Can only be called by the owner or manager.
     * @param _uri The new contract URI.
     */
    function setContractUri(string memory _uri) external onlyOwnerOrManager {
        contractUri = _uri;
        emit ContractURIUpdated();
    }

    /**
     * @notice Sets the image for the Savings CFA.
     * @dev Can only be called by the owner or manager.
     * @param _image The new image URI.
     */
    function setImage(string memory _image) external onlyOwnerOrManager {
        metadata.image = _image;
    }

    /**
     * @notice Sets the loan image for the Savings CFA.
     * @dev Can only be called by the owner or manager.
     * @param _image The new loan image URI.
     */
    function setLoanImage(string memory _image) external onlyOwnerOrManager {
        metadata.loanImage = _image;
    }

    /**
     * @notice Sets the event status.
     * @dev Can only be called by the owner or manager.
     * @param _status The new event status.
     */
    function setEventStatus(bool _status) external onlyOwnerOrManager {
        isEventActive = _status;
    }

    /**
     * @notice Sets the metadata for the Savings CFA.
     * @dev Can only be called by the owner.
     * @param _name The name of the Savings CFA.
     * @param _description The description of the Savings CFA.
     */
    function setMetadata(
        string memory _name,
        string memory _description
    ) external onlyOwner {
        metadata.name = _name;
        metadata.description = _description;
    }

    /**
     * @notice Sets the registry contract address.
     * @dev Can only be called by the owner.
     * @param _registry The address of the Registry contract.
     */
    function setRegistry(address _registry) external onlyOwner {
        registry = Registry(_registry);
    }

    /**
     * @notice Sets the minimum and maximum life duration for savings positions.
     * @dev Can only be called by the owner.
     * @param _min The minimum life duration.
     * @param _max The maximum life duration.
     */
    function setLife(uint256 _min, uint256 _max) external onlyOwner {
        system.minLife = _min;
        system.maxLife = _max;
    }

    /**
     * @notice Sets the name of the contract.
     * @dev Can only be called by the owner.
     * @param _name The new name of the contract.
     */
    function setName(string memory _name) external onlyOwner {
        emit UpdateNameEvent(name, _name);
        name = _name;
    }

    /**
     * @notice Sets the symbol of the contract.
     * @dev Can only be called by the owner.
     * @param _symbol The new symbol of the contract.
     */
    function setSymbol(string memory _symbol) external onlyOwner {
        emit UpdateSymbolEvent(symbol, _symbol);
        symbol = _symbol;
    }

    // =============================================================
    //                          GETTERS
    // =============================================================

    /**
     * @notice Gets the loan balance for a specific savings position.
     * @param _id The ID of the savings position.
     * @return The loan balance.
     */
    function getLoanBalance(uint256 _id) external view returns (uint256) {
        uint256 _loanBalance = loan[_id].loanBalance;
        return _loanBalance;
    }

    /**
     * @notice Calculates the yielded interest for a specific savings position.
     * @param _id The ID of the savings position.
     * @return The yielded interest.
     */
    function getYieldedInterest(uint256 _id) public view returns (uint256) {
        uint256 _timePassed = ((block.timestamp -
            attributes[_id].effectiveInterestTime) / (30 days * 12)); // In years

        if (_timePassed == 0) {
            return 0;
        }

        uint256 _yieldedInterest = IInterestRateModel(
            registry.getContractAddress("InterestRateModel")
        ).getSavingsOutcome(
                _timePassed,
                attributes[_id].marker,
                attributes[_id].principal
            );

        return _yieldedInterest;
    }

    /**
     * @notice Gets the total outcome for a specific savings position.
     * @param _id The ID of the savings position.
     * @return The total outcome.
     */
    function getSavingsOutcome(uint256 _id) external view returns (uint256) {
        IInterestRateModel interestRateModel = IInterestRateModel(
            registry.getContractAddress("InterestRateModel")
        );
        uint256 _outcome = interestRateModel.getSavingsOutcome(
            attributes[_id].cfaLife,
            attributes[_id].marker,
            attributes[_id].principal
        );

        return _outcome;
    }

    /**
     * @notice Gets the total number of active CFAs.
     * @return The total number of active CFAs.
     */
    function getTotalActiveCfa()
        external
        view
        returns (uint256, uint256, uint256)
    {
        return (system.totalActiveCfa, totalLoans, system.idCounter);
    }

    /**
     * @notice Calculates the total amount needed for multiple savings positions, factoring in possible referral discounts.
     * @param _address The address of the user making the investment.
     * @param _principal The principal amount for each savings position.
     * @param _qty The number of savings positions to be created.
     * @return The total amount of tokens required, after applying any applicable referral discounts.
     */
    function getTotalInvestment(
        address _address,
        uint256 _principal,
        uint256 _qty
    ) public view returns (uint256) {
        uint256 totalInvestment;
        for (uint256 i = 0; i < _qty; i++) {
            if (
                (
                    Referral(registry.getContractAddress("Referral"))
                        .eligibleForReward(_address)
                )
            ) {
                uint256 discount = Referral(
                    registry.getContractAddress("Referral")
                ).getReferredDiscount();
                uint256 amtPayable = _principal -
                    ((_principal * discount) / 10000);

                totalInvestment += amtPayable;
            } else {
                totalInvestment += _principal;
            }
        }
        return totalInvestment;
    }

    /**
     * @notice Calculates the new expiry date for a loan.
     * @param _id The ID of the savings position.
     * @return The new expiry date.
     */
    function newExpiry(uint256 _id) external view returns (uint256) {
        uint256 timePassed = block.timestamp - loan[_id].timeWhenLoaned;
        uint256 _newExpiry = attributes[_id].cfaLifeTimestamp + timePassed;
        return _newExpiry;
    }

    // =============================================================
    //                          METADATA GETTERS
    // =============================================================

    /**
     * @notice Generates the metadata for a specific token ID.
     * @dev Combines basic info, attributes, and loan info into a JSON string.
     * @param _tokenId The token ID for which metadata is generated.
     * @return A JSON string representing the metadata.
     */
    function getMetadata(uint256 _tokenId) public view returns (string memory) {
        string memory basicInfo = getBasicInfo(_tokenId);
        string memory firstHalfAttributesInfo = getFirstHalfAttributesInfo(
            _tokenId
        );
        string memory secondHalfAttributesInfo = getSecondHalfAttributesInfo(
            _tokenId
        );
        string memory loanInfo = getLoanInfo(_tokenId);

        return
            string(
                abi.encodePacked(
                    "{",
                    basicInfo,
                    firstHalfAttributesInfo,
                    secondHalfAttributesInfo,
                    loanInfo,
                    "]}"
                )
            );
    }

    /**
     * @notice Generates the basic info for a specific token ID.
     * @dev Includes the name, description, and image URI for the token.
     * @param _tokenId The token ID for which basic info is generated.
     * @return A JSON string representing the basic info.
     */
    function getBasicInfo(
        uint256 _tokenId
    ) internal view returns (string memory) {
        string memory imageUri = loan[_tokenId].onLoan
            ? metadata.loanImage
            : metadata.image;

        return
            string(
                abi.encodePacked(
                    '"name":"',
                    metadata.name,
                    Strings.toString(_tokenId),
                    '",',
                    '"description":"',
                    metadata.description,
                    '",',
                    '"image":"',
                    imageUri,
                    '",',
                    '"attributes": ['
                )
            );
    }

    /**
     * @notice Generates the first half of the attributes for a specific token ID.
     * @dev Includes creation date, maturity date, principal, and total earnings.
     * @param _tokenId The token ID for which attributes are generated.
     * @return A JSON string representing the first half of the attributes.
     */
    function getFirstHalfAttributesInfo(
        uint256 _tokenId
    ) internal view returns (string memory) {
        IInterestRateModel interestModel = IInterestRateModel(
            registry.getContractAddress("InterestRateModel")
        );
        return
            string(
                abi.encodePacked(
                    '{ "trait_type": "Creation Date", "display_type": "date", "value": "',
                    attributes[_tokenId].timeCreated.toString(),
                    '" },',
                    '{ "trait_type": "Maturity Date", "display_type": "date", "value": "',
                    attributes[_tokenId].cfaLifeTimestamp.toString(),
                    '" },',
                    '{ "trait_type": "Principal", "value": "',
                    attributes[_tokenId].principal.formatEther(),
                    '" },',
                    '{ "trait_type": "Earnings Total", "value": "',
                    (interestModel.getSavingsOutcome(
                        attributes[_tokenId].cfaLife,
                        attributes[_tokenId].marker,
                        attributes[_tokenId].principal
                    ) + attributes[_tokenId].principal).formatEther(),
                    '" },'
                )
            );
    }

    /**
     * @notice Generates the second half of the attributes for a specific token ID.
     * @dev Includes interest return, ROI rate, system interest rate, loan status, and discount given.
     * @param _tokenId The token ID for which attributes are generated.
     * @return A JSON string representing the second half of the attributes.
     */
    function getSecondHalfAttributesInfo(
        uint256 _tokenId
    ) internal view returns (string memory) {
        IInterestRateModel interestModel = IInterestRateModel(
            registry.getContractAddress("InterestRateModel")
        );
        return
            string(
                abi.encodePacked(
                    '{ "trait_type": "Interest Return", "value": "',
                    interestModel
                        .getSavingsOutcome(
                            attributes[_tokenId].cfaLife,
                            attributes[_tokenId].marker,
                            attributes[_tokenId].principal
                        )
                        .formatEther(),
                    '" },',
                    '{ "trait_type": "ROI Rate (%)", "value": "',
                    (interestModel.getSavingsInterestRate(
                        attributes[_tokenId].cfaLife,
                        attributes[_tokenId].marker
                    ) * 100).formatPercentage(),
                    '" },',
                    '{ "trait_type": "System Interest Rate (%)", "value": "',
                    attributes[_tokenId].systemInterestRate.formatPercentage(),
                    '" },',
                    '{ "trait_type": "Loan Status", "value": "',
                    (loan[_tokenId].onLoan ? "On Loan" : "Not on Loan"),
                    '" },',
                    '{ "trait_type": "Discount Given (%)", "value": "',
                    attributes[_tokenId].discountGiven.formatDiscount(),
                    '" }'
                )
            );
    }

    /**
     * @notice Generates loan-specific metadata for a specific token ID.
     * @dev Includes lending date and loan awarded amount if the token is on loan.
     * @param _tokenId The token ID for which loan info is generated.
     * @return A JSON string representing the loan info.
     */
    function getLoanInfo(
        uint256 _tokenId
    ) internal view returns (string memory) {
        if (loan[_tokenId].onLoan) {
            return
                string(
                    abi.encodePacked(
                        ', { "trait_type": "Lending Date", "display_type": "date", "value": "',
                        loan[_tokenId].timeWhenLoaned.toString(),
                        '" },',
                        '{ "trait_type": "Loan Awarded", "value": "',
                        loan[_tokenId].loanBalance.formatEther(),
                        '" }'
                    )
                );
        }
        return "";
    }

    /**
     * @notice Returns the contract URI for metadata.
     * @dev Combines the contract URI with the JSON prefix.
     * @return A JSON string representing the contract URI.
     */
    function contractURI() public view returns (string memory) {
        return string.concat("data:application/json;utf8,", contractUri);
    }

    // =============================================================
    //                          OVERRIDES
    // =============================================================

    /**
     * @notice Returns the URI for a specific token ID.
     * @dev Encodes the metadata as a base64 JSON string.
     * @param _tokenId The token ID for which the URI is generated.
     * @return A base64-encoded JSON string representing the token URI.
     */
    function uri(
        uint256 _tokenId
    ) public view virtual override returns (string memory) {
        bytes memory _metadata = abi.encodePacked(getMetadata(_tokenId));

        return
            string(abi.encodePacked("data:application/json;utf8,", _metadata));
    }

    /**
     * @dev Prevents single transfers when the contract is paused.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(!emergencyPause, "Savings: Transfers are paused");
        super.safeTransferFrom(from, to, id, amount, data);
    }

    /**
     * @dev Prevents batch transfers when the contract is paused.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(!emergencyPause, "Savings: Transfers are paused");
        super.safeBatchTransferFrom(from, to, ids, amounts, data);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/utils/Strings.sol";

library Formatters {
    using Strings for uint256;

    function formatEther(
        uint256 amountInWei
    ) public pure returns (string memory) {
        uint256 wholePart = amountInWei / 1 ether;
        uint256 decimalPart = (amountInWei % 1 ether) / 10 ** 13; // Extract 5 decimal places

        string memory decimalStr;
        if (decimalPart == 0) {
            decimalStr = "00000"; // Ensure 5 trailing zeros
        } else {
            // Format decimalPart to always be 5 digits
            decimalStr = decimalPart < 10000
                ? string(abi.encodePacked("0", decimalPart.toString()))
                : decimalPart.toString();
            while (bytes(decimalStr).length < 5) {
                decimalStr = string(abi.encodePacked("0", decimalStr));
            }
        }

        return string(abi.encodePacked(wholePart.toString(), ".", decimalStr));
    }

    function formatPercentage(
        uint256 input
    ) public pure returns (string memory) {
        // Divide by 10^16 to get the main percentage value (with fractional part)
        uint256 percentage = input / 10 ** 16;

        // Extract the whole and fractional parts
        uint256 wholePart = percentage / 100; // Whole part of the percentage
        uint256 fractionalPart = percentage % 1000; // Up to three decimal digits

        // Convert the whole part to string
        string memory wholeStr = Strings.toString(wholePart);

        // If fractional part is zero, return the whole part as a string
        if (fractionalPart == 0) {
            return wholeStr;
        }

        // Format the fractional part to ensure correct digits
        string memory fractionalStr = Strings.toString(fractionalPart);

        // Handle leading zeros for fractional parts with less than three digits
        if (fractionalPart < 10) {
            fractionalStr = string(abi.encodePacked("00", fractionalStr));
        } else if (fractionalPart < 100) {
            fractionalStr = string(abi.encodePacked("0", fractionalStr));
        }

        // Trim trailing zeros for cleaner output
        while (bytes(fractionalStr)[bytes(fractionalStr).length - 1] == "0") {
            fractionalStr = substring(
                fractionalStr,
                0,
                bytes(fractionalStr).length - 1
            );
        }

        // Combine the whole and fractional parts
        return string(abi.encodePacked(wholeStr, ".", fractionalStr));
    }

    // Helper function to trim strings
    function substring(
        string memory str,
        uint256 startIndex,
        uint256 endIndex
    ) internal pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(endIndex - startIndex);
        for (uint256 i = startIndex; i < endIndex; i++) {
            result[i - startIndex] = strBytes[i];
        }
        return string(result);
    }

    function formatDiscount(
        uint256 discount
    ) public pure returns (string memory) {
        if (discount < 100) {
            // For discounts less than 100, format as 0.XX
            return
                string(
                    abi.encodePacked(
                        "0.",
                        discount < 10
                            ? string(abi.encodePacked("0", discount.toString()))
                            : discount.toString()
                    )
                );
        } else {
            // For discounts 100 or greater, separate the whole and fractional parts
            uint256 wholePart = discount / 100; // Get the whole number part
            uint256 fractionalPart = discount % 100; // Get the fractional part

            if (fractionalPart == 0) {
                // If there's no fractional part, return the whole number
                return wholePart.toString();
            } else {
                // Format the fractional part to ensure two digits
                string memory fractionalStr = fractionalPart < 10
                    ? string(abi.encodePacked("0", fractionalPart.toString()))
                    : fractionalPart.toString();

                // Combine the whole and fractional parts
                return
                    string(
                        abi.encodePacked(
                            wholePart.toString(),
                            ".",
                            fractionalStr
                        )
                    );
            }
        }
    }
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.20;

interface IInterestRateModel {
    /// @notice Initialize the contract (used in upgradeable contracts)
    function initialize() external;

    /// @notice Set the savings table
    /// @dev The savings table is a 2D array that stores the interest rate for the savings
    /// @param _multiplier is the interest rate for the savings
    function setSavingsTable(uint256[][] memory _multiplier) external;

    /// @notice Set the locked savings multipliers table
    /// @param _multiplier - array of multipliers
    /// @param _monthsLocked - 2D array with months locked
    function setLockedSavingsMultiplierTable(
        uint256[] memory _multiplier,
        uint256[][] memory _monthsLocked
    ) external;

    /// @notice Return the interest outcome for a given period and marker
    /// @param _period - number of years
    /// @param _marker - index of the savings table
    /// @param _amount - principal amount
    /// @return interest - computed interest value
    function getSavingsOutcome(
        uint256 _period,
        uint256 _marker,
        uint256 _amount
    ) external view returns (uint256);

    /// @notice Return the interest rate for a given period and marker
    /// @param _period - number of years
    /// @param _marker - index of the savings table
    /// @return interestRate - interest rate (multiplier) in 1e18 precision
    function getSavingsInterestRate(
        uint256 _period,
        uint256 _marker
    ) external view returns (uint256);

    /// @notice Return the income outcome for a given payment frequency, marker, period, and principal
    /// @param _paymentFrequency - e.g., monthly, quarterly, annually
    /// @param _marker - index of the income table
    /// @param _period - the index in the array (e.g., 0 for month1, 1 for month2, etc.)
    /// @param _amount - principal amount
    /// @return interest - computed interest value
    function getIncomeOutcome(
        uint256 _paymentFrequency,
        uint256 _marker,
        uint256 _period,
        uint256 _amount
    ) external view returns (uint256);

    /// @notice Return the income interest rate for a specific payment frequency, marker, and period
    /// @param _paymentFrequency - e.g., monthly, quarterly, annually
    /// @param _marker - index of the income table
    /// @param _period - the index in the array
    /// @return interestRate - interest rate (multiplier) in 1e18 precision
    function getIncomeInterestRate(
        uint256 _paymentFrequency,
        uint256 _marker,
        uint256 _period
    ) external view returns (uint256);

    /// @notice Return how many months are locked for a given locked savings multiplier
    /// @param _multiplier - multiplier used
    /// @param _marker - index in the locked savings table
    /// @return monthsLocked - number of months locked
    function getLockedSavingsMonths(
        uint256 _multiplier,
        uint256 _marker
    ) external view returns (uint256);

    /// @notice Return the locked savings outcome for a given multiplier and principal
    /// @param _multiplier - multiplier used
    /// @param _amount - principal amount
    /// @return lockedOutcome - total amount (principal * multiplier)
    function getLockedSavingsOutcome(
        uint256 _multiplier,
        uint256 _amount
    ) external pure returns (uint256);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IReferral {
    struct Referrer {
        address referrer;
        address[] referrals;
        uint256 referralCount;
        uint256 buyCount;
        uint256 rewarded;
        bool wasReferred;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface ISavings {
    struct System {
        uint256 idCounter; // The total number of CFAs minted
        uint256 minLife;
        uint256 maxLife;
        uint256 totalActiveCfa;
    }

    struct Attributes {
        uint256 timeCreated; // The time the CFA was minted in unix timestamp
        uint256 cfaLifeTimestamp; // maturity date, adjusted for loan
        uint256 cfaLife; // The duration of the CFA in number of years
        uint256 effectiveInterestTime; // time created basically, but adjusted
        uint256 principal; // The amount of B&B tokens locked
        uint256 marker; // Current marker when CFA was created
        uint256 discountGiven; // The discount given to the user
        // uint256 totalPossibleReward
        uint256 systemInterestRate;
    }

    struct Loan {
        bool onLoan;
        uint256 loanBalance;
        uint256 timeWhenLoaned;
    }

    struct Metadata {
        string name; // The name of the CFA
        string description; // The description of the CFA
        string image; // The image of the CFA
        string loanImage;
    }
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../utils/Registry.sol";

/**
 * @title Bean Token Contract
 */
contract Bean is Ownable(msg.sender), ERC20, ERC20Burnable {
    
    /// @notice Tracks total rewards given to each address.
    mapping(address => uint256) public totalRewarded;
    /// @notice Indicates whether an address is authorized to perform restricted operations.
    mapping(address => bool) public isRegistered;

    /// @notice Maximum supply of the Bean tokens.
    uint256 public immutable MAX_SUPPLY = 21000000000 ether;

    // =============================================================
    //                          CONSTRUCTOR
    // =============================================================

    constructor(uint256 _initSupply) ERC20("BEAN", "BEAN") {
        _mint(msg.sender, _initSupply);
    }

    // =============================================================
    //                          MAIN FUNCTIONS
    // =============================================================

    /**
     * @notice Mints new tokens to a specified user.
     * @dev Can only be called by registered contracts.
     * @param _user The address receiving the newly minted tokens.
     * @param _amount The amount of tokens to mint.
     */
    function mint(address _user, uint256 _amount) public {
        require(isRegistered[msg.sender], "Bean:: Not authorized");
        require(
            totalSupply() + _amount <= MAX_SUPPLY,
            "Bean:: Max supply reached"
        );
        _mint(_user, _amount);
    }

    /**
     * @notice Adds reward amount to the total rewarded for a specific address.
     * @dev Can only be called by registered contracts.
     * @param _amount The reward amount to add.
     * @param _address The recipient's address for tracking rewards.
     */
    function addTotalRewarded(uint256 _amount, address _address) external {
        require(isRegistered[msg.sender], "Bean:: Not authorized");
        totalRewarded[_address] += _amount;
    }

    // =============================================================
    //                            SETTERS
    // =============================================================

    /**
     * @notice Registers a contract as authorized to perform restricted operations.
     * @param _contract The contract address to authorize.
     */
    function setRegisteredContracts(address _contract) external onlyOwner {
        isRegistered[_contract] = true;
    }

    // =============================================================
    //                            GETTER
    // =============================================================

    /**
     * @notice Checks whether the maximum supply of tokens has been reached.
     * @return True if the total supply is equal to or exceeds the maximum supply.
     */
    function isMaxSupplyReached() external view returns (bool) {
        return totalSupply() >= MAX_SUPPLY;
    }
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../token/Bean.sol";
import "./Registry.sol";
import "../token/Bean.sol";

/**
 * @title Event Contract
 * @notice This contract manages event-based allotments and claims for users.
 * @dev It allows the owner to set time markers and multipliers, and users to claim their allotted tokens based on the current time.
 */
contract Event is Ownable(msg.sender) {
    
    /// @notice Registry contract to fetch contract addresses.
    Registry public registry;

    /// @notice Tracks the allotted amount for each address.
    mapping(address => uint256) public allotted;

    /// @notice Array of time markers for event-based allotments.
    uint256[] public timeMarkers;
    /// @notice Array of multipliers corresponding to each time marker.
    uint256[] public multpliers;

    // =============================================================
    //                          SETTERS
    // =============================================================

    /**
     * @notice Sets the time markers and corresponding multipliers.
     * @dev Can only be called by the owner.
     * @param _timeMarkers An array of time markers.
     * @param _multipliers An array of multipliers corresponding to each time marker.
     */
    function setMarkersAndMultipliers(
        uint256[] memory _timeMarkers,
        uint256[] memory _multipliers
    ) external onlyOwner {
        require(
            _timeMarkers.length == _multipliers.length,
            "Airdrop:: Marker and multiplier length should be equal"
        );
        timeMarkers = _timeMarkers;
        multpliers = _multipliers;
    }

    /**
     * @notice Sets the registry contract address.
     * @dev Can only be called by the owner.
     * @param _registry The address of the Registry contract.
     */
    function setRegistry(Registry _registry) external onlyOwner {
        registry = _registry;
    }

    // =============================================================
    //                          MAIN FUNCTIONS
    // =============================================================

    /**
     * @notice Adds an allotted amount to a user's balance based on the current time marker.
     * @dev Can only be called by registered contracts.
     * @param _address The address of the user to whom the amount is allotted.
     * @param _amount The amount to be allotted.
     */
    function addValue(address _address, uint256 _amount) external {
        require(registry.isRegistered(msg.sender), "Event:: Not authorized");

        uint256 i;
        for (i = 0; i < timeMarkers.length; i++) {
            if (block.timestamp < timeMarkers[i]) {
                break;
            }
        }
        require(i < timeMarkers.length, "Event:: No valid time marker found");

        allotted[_address] += _amount * multpliers[i];
    }

    /**
     * @notice Allows a user to claim their allotted tokens.
     * @dev Mints the allotted tokens to the user's address and resets their allotted balance.
     */
    function claimAllotted() external {
        uint256 amount = allotted[msg.sender];
        require(amount > 0, "Event:: No allotted amount found");

        Bean bean = Bean(registry.getContractAddress("Bean"));
        bean.mint(msg.sender, amount);
        allotted[msg.sender] = 0;
    }
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.20;

import "./Registry.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../token/Bean.sol";

/**
 * @title Global Marker Contract
 * @notice This contract manages markers and interest rates based on the total supply of the Bean token.
 * @dev It allows the owner to set markers and corresponding interest rates, and provides functionality to retrieve the current marker and interest rate.
 */
contract GlobalMarker is Ownable(msg.sender) {
    
    /// @notice Registry contract to fetch contract addresses.
    Registry public registry;

    /// @notice The size of the markers array.
    uint256 markerSize;
    /// @notice Array of markers representing supply thresholds.
    uint256[] public markers;
    /// @notice Array of interest rates corresponding to each marker.
    uint256[] public interests;
    /// @notice Indicates whether the interest rates have been set.
    bool interestsSet;

    // =============================================================
    //                          CONSTRUCTOR
    // =============================================================

    /**
     * @notice Initializes the GlobalMarker contract.
     * @param _registry The address of the Registry contract.
     */
    constructor(Registry _registry) {
        registry = _registry;
        markers = new uint256[](41);
        interests = new uint256[](41);
    }

    // =============================================================
    //                          SETTERS
    // =============================================================

    /**
     * @notice Sets the markers and corresponding interest rates.
     * @dev Can only be called by the owner.
     * @param _marker An array of markers representing supply thresholds.
     * @param _interest An array of interest rates corresponding to each marker.
     */
    function setInterest(
        uint256[] memory _marker,
        uint256[] memory _interest
    ) external onlyOwner {
        require(
            _marker.length == _interest.length,
            "GlobalMarker: Marker and interest length should be equal"
        );
        interestsSet = true;
        uint256 _markerSize;
        for (uint256 i = 0; i < _marker.length; i++) {
            markers[i] = _marker[i];
            interests[i] = _interest[i];
            _markerSize++;
        }
        markerSize = _markerSize;
    }

    /**
     * @notice Sets the registry contract address.
     * @dev Can only be called by the owner.
     * @param _registry The address of the Registry contract.
     */
    function setRegistry(Registry _registry) external onlyOwner {
        registry = _registry;
    }

    // =============================================================
    //                          GETTERS
    // =============================================================

    /**
     * @notice Retrieves the current marker based on the total supply of the Bean token.
     * @dev Requires that the interest rates have been set.
     * @return The current marker index.
     */
    function getMarker() public view returns (uint256) {
        require(interestsSet, "GlobalMarker: Marker & Interest not yet set");
        uint256 totalSupply = IERC20(registry.getContractAddress("Bean"))
            .totalSupply();
        uint256 marker = 0;

        if (totalSupply > markers[markerSize - 1]) {
            return markerSize - 1;
        } else {
            for (uint256 index = 0; index < markers.length - 1; index++) {
                if (
                    totalSupply >= markers[index] &&
                    totalSupply < markers[index + 1]
                ) {
                    marker = index;
                    return marker;
                }
            }
        }
    }

    /**
     * @notice Retrieves the current interest rate based on the current marker.
     * @dev Requires that the interest rates have been set.
     * @return The current interest rate.
     */
    function getInterestRate() external view returns (uint256) {
        // Interests should be ready to be divided by 10000
        require(interestsSet, "GlobalMarker: Marker & Interest not yet set");
        uint256 marker = getMarker();
        return interests[marker];
    }

    /**
     * @notice Checks if the interest rates have been set.
     * @return True if the interest rates have been set, otherwise false.
     */
    function isInterestSet() external view returns (bool) {
        bool _interestsSet = interestsSet;
        return _interestsSet;
    }
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Registry
 * @dev The bean registry contract for mapping contract names to addresses and tracking registration status.
 */
contract Registry is Ownable(msg.sender) {

    /// @notice Maps contract names to their addresses.
    mapping(string => address) public registry;
    /// @notice Tracks whether an address is registered.
    mapping(address => bool) public registered;

    // =============================================================
    //                          WRITE FUNCTIONS
    // =============================================================

    /**
     * @notice Sets the contract address for a given name.
     * @dev Can only be called by the owner.
     * @param _name The name of the contract.
     * @param _address The address associated with the contract.
     */
    function setContractAddress(
        string memory _name,
        address _address
    ) external onlyOwner {
        registry[_name] = _address;
        registered[_address] = true;
    }

    // =============================================================
    //                          READ FUNCTIONS
    // =============================================================

    /**
     * @notice Retrieves the contract address associated with a given name.
     * @param _name The name of the contract.
     * @return The address associated with the provided name.
     */
    function getContractAddress(
        string memory _name
    ) external view returns (address) {
        require(
            registry[_name] != address(0),
            string(abi.encodePacked("Registry: Does not exist ", _name))
        );
        return registry[_name];
    }

    /**
     * @notice Checks if a given address is registered.
     * @param _address The address to check.
     * @return True if the address is registered, false otherwise.
     */
    function isRegistered(address _address) external view returns (bool) {
        return registered[_address];
    }
}