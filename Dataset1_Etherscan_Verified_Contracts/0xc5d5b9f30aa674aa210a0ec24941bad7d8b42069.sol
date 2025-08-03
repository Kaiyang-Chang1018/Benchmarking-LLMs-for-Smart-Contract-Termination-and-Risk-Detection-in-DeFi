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
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC721.sol)

pragma solidity ^0.8.0;

import "../token/ERC721/IERC721.sol";
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
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
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC1155/IERC1155.sol)

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
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;

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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/utils/ERC1155Holder.sol)

pragma solidity ^0.8.0;

import "./ERC1155Receiver.sol";

/**
 * Simple implementation of `ERC1155Receiver` that will allow a contract to hold ERC1155 tokens.
 *
 * IMPORTANT: When inheriting this contract, you must include a way to use the received tokens, otherwise they will be
 * stuck.
 *
 * @dev _Available since v3.1._
 */
contract ERC1155Holder is ERC1155Receiver {
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/utils/ERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../IERC1155Receiver.sol";
import "../../../utils/introspection/ERC165.sol";

/**
 * @dev _Available since v3.1._
 */
abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
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
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC721/utils/ERC721Holder.sol)

pragma solidity ^0.8.0;

import "../IERC721Receiver.sol";

/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721Holder is IERC721Receiver {
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
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
/*
Version 1 of the HyperCycle Share Manager contract.
*/

pragma solidity 0.8.26;

import {Context} from '@openzeppelin/contracts/utils/Context.sol';
import "@openzeppelin/contracts/access/Ownable.sol";
import {ERC721Holder} from '@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol';
import {ERC1155Holder} from '@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol';
import {ShareManagerErrors as Errors} from '../libs/ShareManagerErrorsV2.sol';
import {ShareManagerEvents as Events} from '../libs/ShareManagerEventsV2.sol';
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {ShareManagerTypes as Types, IHYPCSwapV2, IHyperCycleLicense, IHyperCycleShareTokensV2, IHYPC} from '../libs/ShareManagerTypesV2.sol';

/**
@title HyperCycle Share ManagerV2, revenue sharing manager.
@author Barry Rowe, Rodolfo Cova
@notice HyperCycle is a network of AI computation nodes offering different AI services in a 
    decentralized manner. In this system, there are license holders, token holders, hardware
    operators, and AI developers. Using the HyperCycleSwapV2 contract, an amount of HyPC (erc20)
    can be swapped for a cHyPC (containerized HyPC) token, which can then point towards a
    license (HyperCycleLicense) NFT id. At this point, the owner of this license can assign
    their license to some hardware running the HyperCycle Node Manager, and can from then
    on accept AI service requests on the network. 

    The HyperCycle Share Manager (This contract) allows the chypc owner to create a revenue sharing proposal, 
    to understand in deep the Share Token Contract, please refer to he Share Token Contract 
    documentation, See {HyperCycleShareTokensV2}.

    The main idea of the Share Manager is to be the one holding and managing the Share Token,
    being able to use the same benefits of the Share Tokens and extend it with the votations that
    share token holders can execute for the Share.

    To create a Share Proposal with the Share Manager, the chypc owner needs to call 
    `createShareProposal` function, this function will create a new Share Proposal and transfer
    the chypc to the Share Manager, the Share Manager will be the one holding the chypc until
    the Share Proposal is ended, in case the Share Proposal is ended, the chypc will be redeemed
    into hypc tokens, in which the share holders will be able to claim the proportional amount
    of share tokens to hypc tokens.

    The Share Proposal will be created with the following data:
        - CHyPC Data: CHyPC Id, CHyPC Owner, CHyPC Level, Initial Revenue Tokens, Initial Wealth Tokens
        - License Data: License Number, License Owner, License Level, Initial Revenue Tokens, Initial Wealth Tokens
        - Operator Data: Operator Revenue, Operator Assigned String, Operator Address
        - Share Token Data: Share Token Number, Revenue Deposit Delay, Revenue Token Id, Wealth Token Id, Valid End Timestamp
        - Status: Pending
    
    The Share Proposal can have the following status in the entire lifecycle of the Share Proposal:
        - Pending: The Share Proposal is created and waiting for the CHyPC NFT to be transfered to the Share Manager
        - Started: The Share Proposal is started and the Share Tokens are created, the CHyPC NFT is transfered to the Share Manager
        - Ended: The Share Proposal is ended and the license is transfered to the License Owner, 
                the CHyPC NFT will be redeem for HyPC tokens and will be claimable by the Share Token Holders.

    The Share Manager contract had a DAO system where share token holderes can be able to create votations to change 
    the hardware operator, the hardware operator revenue, the manager contract and to cancel the share proposal, 
    the votations will be created by the Share Manager and the share token holders will be able to vote.

    The Share Proposal can be ended by the share token holders any time the consensus is reached, for this 100% or 90% (depends on the
    actual `SELECTED_VOTATION_PORCENT`) of the wealth tokens needs to be voted to end the Share Proposal, in case the Share Proposal is 
    ended, the ending process will be executed.

    The Share Manager contract can be changed by the share token holders any time the consensus is reached, for this 100% of the wealth tokens
    needs to be voted to change the Share Manager, in case the Share Manager is changed,  the transfer of the Share Token Ownership will be executed.

    The Hardware Operator can be changed by the share token holders any time the consensus is reached, for this 50% of the wealth tokens
    needs to be voted to change the Hardware Operator, in case the Hardware Operator is changed, the Operator Revenue will be transfered
    to the older operator and the new operator will be set.

    The Hardware Operator Revenue can be changed by the share token holders any time the consensus is reached, 
    for this 50% of the wealth tokens needs to be voted to change the Hardware Operator Revenue, 
    in case the Hardware Operator Revenue is changed, the new operator revenue will be set.

    Another important feature of the Share Manager is the ability to migrate the Share Tokens from the Share Tokens contract
    to the Share Manager, this will allow the Share Manager to be the one holding the Share Tokens and be able to manage the Share
    Proposal and Votations. The Share Manager will be able to claim the Hypc tokens, based in the amount of wealth tokens available, 
    in case the Share Proposal is ended and the CHyPC exists.

    To migrate the Share Tokens to the Share Manager contract, the Share Token owner needs to call `startShareProposalMigration` function,
    this function will start the migration and the Share Manager contract will be able to finish the migration only if the ownership
    of the share token is changed to the Share Manager contract, and the Share Proposal is pending.
*/

contract HyperCycleShareManagerV2 is ERC721Holder, ERC1155Holder, ReentrancyGuard, Context {
    Types.ManagerData private managerData;

    uint256 public sharesProposalsCounter = 1;

    uint256 constant ONE_HUNDRED_PERCENT = 1e18;
    uint256 constant SIX_DECIMALS = 1e6;

    uint256 constant MAX_REVENUE_DELAY = 14 days;

    uint256 public SELECTED_VOTATION_PERCENT;
    uint256 public maxVotationDuration;

    mapping(uint256 shareProposalId => mapping(address user => uint256)) private _votePower;

    mapping(uint256 shareProposalId => mapping(uint256 votationIndex =>mapping(address user => bool))) private _voted;

    
    mapping(uint256 shareProposalId => mapping(address user => uint256)) public _lastVotationCreated;

    mapping(uint256 shareProposalId => mapping(address user => uint256)) private _votedFreeTime;

    mapping(uint256 shareProposalId => Types.Votation[]) private _votations;
  
    mapping(uint256 shareProposalId => Types.ShareProposalData) private _shareProposals;

    mapping(uint256 shareProposalId => bool) private shareCancelled;

    mapping(uint256 shareTokenNumber => uint256) public shareTokenExists;

    modifier onlyVoter(uint256 shareProposalId) {
        if (_votePower[shareProposalId][_msgSender()] == 0) revert Errors.NotEnoughWealthTokensAvailable();   
        _;
    }

    modifier validVoter(uint256 shareProposalId) {
        if (_votePower[shareProposalId][_msgSender()] == 0) revert Errors.NotEnoughWealthTokensAvailable();
        if (_shareProposals[shareProposalId].status != Types.ShareProposalStatus.STARTED) revert Errors.ShareProposalMustBeActive();
        if (_lastVotationCreated[shareProposalId][_msgSender()] > block.timestamp - 2 hours) revert Errors.VotationCreatedTooSoon();
         _;
    }

    modifier validVotation(uint256 shareProposalId, uint256 votationIndex) {
        if (_votations[shareProposalId].length <= votationIndex) {
            revert Errors.InvalidVotation();
        }
        _;
    }

    modifier onlyCHyPCOwner(uint256 shareProposalId) {
        if (_shareProposals[shareProposalId].chypcData.tokenOwner != _msgSender()) revert Errors.InvalidCHYPCOwner();
        _;
    }

    modifier onlyLicenseOwner(uint256 licenseNumber) {
        if (managerData.licenseContract.ownerOf(licenseNumber) != _msgSender()) revert Errors.InvalidLicenseOwner();
        _;
    }

    modifier proposalActive(uint256 shareProposalId) {
        if (_shareProposals[shareProposalId].status != Types.ShareProposalStatus.STARTED) {
            revert Errors.ShareProposalMustBeActive();
        }
        _;
    }

    modifier isHardwareOperator(uint256 shareProposalId) {
        if (_shareProposals[shareProposalId].operatorData.operatorAddress != _msgSender()) {
            revert Errors.MustBeClaimedByHardwareOperatorAddress();
        }
        _;
    }

    modifier validProposedDeadline(uint256 shareProposalId, uint256 deadline) {
        if (deadline <= block.timestamp+1 days) revert Errors.InvalidDeadline();
        if (_votations[shareProposalId].length > 0 && _votations[shareProposalId][_votations[shareProposalId].length-1].deadline > deadline) revert Errors.DeadlineMustBeIncreasing();
        if (deadline - block.timestamp > maxVotationDuration) revert Errors.DeadlineTooLate();
        _;
    }

    /**
    @dev The constructor takes in the contract addresses for the HyPC token, license, cHyPC NFTs and Share Tokens contract.
    @param _consensusOption: The consensus option to be used for the votations.
    @param _hypcToken: The HyPC ERC20 contract address.
    @param _chypcV2: The cHyPC ERC721 contract address.
    @param _licenseContract: The license ERC721 contract address.
    @param _hypcShareTokens: The license ERC721 contract address.
    */
    constructor(Types.ConsensusOptions _consensusOption, address _hypcToken, address _chypcV2, address _licenseContract, 
                address _hypcShareTokens, uint256 _maxVotingTime) {
        if (_hypcToken == address(0)) revert Errors.InvalidHYPCTokenAddress();

        if (_chypcV2 == address(0)) revert Errors.InvalidCHYPCAddress();

        if (_licenseContract == address(0)) revert Errors.InvalidLicenseAddress();

        if (_hypcShareTokens == address(0)) revert Errors.InvalidShareTokenContract();

        if (_maxVotingTime < 1 days || _maxVotingTime > 14 days) revert Errors.InvalidVotingDuration();

        maxVotationDuration = _maxVotingTime;

        _consensusOption == Types.ConsensusOptions.ONE_HUNDRED_PERCENT ?
            SELECTED_VOTATION_PERCENT = ONE_HUNDRED_PERCENT :
            SELECTED_VOTATION_PERCENT = ONE_HUNDRED_PERCENT * 9 / 10;

        managerData = Types.ManagerData({
            hypcToken: IHYPC(_hypcToken),
            chypcV2: IHYPCSwapV2(_chypcV2),
            licenseContract: IHyperCycleLicense(_licenseContract),
            hypcShareTokens: IHyperCycleShareTokensV2(_hypcShareTokens)
       });
    }

    // Share proposal management functions

    /**
    @notice Allows a user to create a new share.
    @param proposalData The encoded data needed to create a new share proposal, should have encoded: 
                        (uint256,uint256,uint256,uint256,uint256,string,address,bool,bool).
    @notice chypcId: should be the license number to be used for the share.
    @notice revenueToAssignToChypc: should be the amount of revenue tokens to be assigned to the chypc owner.
    @notice wealthToAssignToChypc: should be the amount of wealth tokens to be assigned to the chypc owner.
    @notice revenueDepositDelay: should be the amount of time in seconds that the revenue tokens will be locked.
    @notice licenseNumber: the license number to user for the proposal. If 0, then proposal will wait for a license owner to complete it.
    @notice operatorAssignedString: should be the string to be used as the operator assigned string for the share.
    @notice hardwareOperator: should be the address of the hardware operator to be used for the share.
    */
    function createShareProposal(bytes memory proposalData) external nonReentrant {
        (
            uint256 chypcId,
            uint256 revenueToAssignToChypc,
            uint256 wealthToAssignToChypc,
            uint256 revenueDepositDelay,
            uint256 licenseNumber,
            string memory operatorAssignedString,
            address hardwareOperator
        ) = abi.decode(proposalData, (uint256, uint256, uint256, uint256, uint256, string, address));

        uint256 chypcLevel = managerData.chypcV2.getTokenLevel(chypcId);

        if (managerData.chypcV2.ownerOf(chypcId) != _msgSender()) revert Errors.InvalidCHYPCOwner();

        if (hardwareOperator == address(0)) revert Errors.InvalidProposedAddress();

        if (revenueDepositDelay > MAX_REVENUE_DELAY) revert Errors.InvalidDepositRevenueDelay();

        if (
            revenueToAssignToChypc > (1 << chypcLevel) * 7 / 10 ||
            wealthToAssignToChypc > (1 << chypcLevel)
        ) revert Errors.InvalidTokenAmount();

        // @dev We don't want one person to be able to cancel a share themselves off the bat, so
        //      we prevent the creator from getting >= 90% or <= 10% (the acceptor getting 90%),
        //      in the case of 90% consensus.
        // @dev Due to division by ONE_HUNDRED_PERCENT rounds down, the second condition needs + 1.
        //      For example, totalSupply = 524288, 90%, gives 471859.2 -> 471859 as the required
        //      votes to pass. But 524288*1/10 = 52428.8 -> 52428, so if wealthToAssignToChypc is
        //      52429, then this condition would pass, but 524288-52429 = 471859, which would be
        //      enough to pass a cancel share proposal by the other user, which we want to avoid.
        //      Adding 1 to the second condition addresses this.
        if (wealthToAssignToChypc >= (1<<chypcLevel) * SELECTED_VOTATION_PERCENT/ONE_HUNDRED_PERCENT || 
            wealthToAssignToChypc <= (1<<chypcLevel) * (ONE_HUNDRED_PERCENT-SELECTED_VOTATION_PERCENT)/ONE_HUNDRED_PERCENT + 1) {
            revert Errors.InvalidTokenAmount();

        }

        uint256 shareProposalId = sharesProposalsCounter++;

        Types.ShareProposalData storage shareProposal = _shareProposals[shareProposalId];
  
        // @dev  operatorRevenue: (1 << chypcLevel) * 2 * SIX_DECIMALS / 10,
        //       but is simplified to reduce the contract size. 
        shareProposal.operatorData = Types.HardwareOperatorData({
            operatorRevenue: (1 << chypcLevel) * 200000,
            operatorAssignedString: operatorAssignedString,
            operatorAddress: hardwareOperator
        });

        shareProposal.status = Types.ShareProposalStatus.PENDING;

        shareProposal.chypcData = Types.TokenHolderData({
            tokenNumber: chypcId,
            tokenOwner: _msgSender(),
            tokenLevel: chypcLevel,
            initialRevenueTokens: revenueToAssignToChypc,
            initialWealthTokens: wealthToAssignToChypc
        });

        shareProposal.shareTokenData.revenueDepositDelay = revenueDepositDelay;

        managerData.chypcV2.safeTransferFrom(_msgSender(), address(this), chypcId);

        if (licenseNumber != 0) {
            if (managerData.licenseContract.ownerOf(licenseNumber) != _msgSender()) revert Errors.InvalidLicenseOwner();

            _completeProposal(shareProposalId, licenseNumber);
        }

        emit Events.ShareProposalCreated(shareProposalId);
    }

    /// @notice Allows the owner of the cHyPC to cancel a pending share proposal.
    /// @param shareProposalId the share proposal Id to be cancelled.
    function cancelPendingShareProposal(uint256 shareProposalId) external nonReentrant onlyCHyPCOwner(shareProposalId) {
        if (_shareProposals[shareProposalId].status != Types.ShareProposalStatus.PENDING)
            revert Errors.ShareProposalIsNotPending();

        _endShareProposal(shareProposalId);
    }

    /// @notice Allows the owner of the License to complete a pending share proposal.
    /// @param shareProposalId The share proposal Id to be used to complete the share.
    /// @param licenseNumber The License NFT id to be used to start the share.
    function completeShareProposal(uint256 shareProposalId, uint256 licenseNumber) external nonReentrant onlyLicenseOwner(licenseNumber) {
        if (_shareProposals[shareProposalId].status != Types.ShareProposalStatus.PENDING)
            revert Errors.ShareProposalIsNotPending();

        _completeProposal(shareProposalId, licenseNumber);
    }

    /// @notice Internal function to allow the License NFT owner to complete a pending share proposal.
    /// @param shareProposalId The share proposal Id to be used to complete the share.
    /// @param licenseNumber The License NFT id to be used to start the share.
    function _completeProposal(uint256 shareProposalId, uint256 licenseNumber) private {
        Types.ShareProposalData storage shareProposal = _shareProposals[shareProposalId];

        uint256 licenseLevel = managerData.licenseContract.getLicenseHeight(licenseNumber);
        uint256 totalSupply = 1 << shareProposal.chypcData.tokenLevel;

        if (licenseLevel != shareProposal.chypcData.tokenLevel)
            revert Errors.TokenLevelMismatch();

        shareProposal.status = Types.ShareProposalStatus.STARTED;

        shareProposal.licenseData = Types.TokenHolderData({
            tokenNumber: licenseNumber,
            tokenOwner: _msgSender(),
            tokenLevel: licenseLevel,
            initialRevenueTokens: (totalSupply * 7 / 10) - shareProposal.chypcData.initialRevenueTokens,
            initialWealthTokens: totalSupply - shareProposal.chypcData.initialWealthTokens
        });

        uint256 currentShareNumber = managerData.hypcShareTokens.currentShareNumber();
        shareTokenExists[currentShareNumber] = shareProposalId;

        shareProposal.shareTokenData = Types.ShareTokenData({
            shareTokenNumber: currentShareNumber,
            revenueDepositDelay: shareProposal.shareTokenData.revenueDepositDelay,
            rTokenId: currentShareNumber << 1,
            wTokenId: (currentShareNumber << 1) + 1,
            validEndTimestamp: block.timestamp + 1 days
        });

        managerData.licenseContract.safeTransferFrom(_msgSender(), address(this), licenseNumber);

        managerData.licenseContract.approve(
            address(managerData.hypcShareTokens),
            licenseNumber
        );

        managerData.chypcV2.approve(address(managerData.hypcShareTokens), shareProposal.chypcData.tokenNumber);

        managerData.hypcShareTokens.createShareTokens(
            licenseNumber,
            shareProposal.chypcData.tokenNumber,
            true,
            shareProposal.operatorData.operatorAssignedString,
            shareProposal.shareTokenData.revenueDepositDelay
        );

        _sendRevenueAndWealthTokens(
            shareProposal.licenseData.tokenOwner,
            shareProposal.shareTokenData.rTokenId,
            shareProposal.shareTokenData.wTokenId,
            shareProposal.licenseData.initialRevenueTokens,
            shareProposal.licenseData.initialWealthTokens
        );

        _sendRevenueAndWealthTokens(
            shareProposal.chypcData.tokenOwner,
            shareProposal.shareTokenData.rTokenId,
            shareProposal.shareTokenData.wTokenId,
            shareProposal.chypcData.initialRevenueTokens,
            shareProposal.chypcData.initialWealthTokens
        );

        emit Events.ShareProposalStarted(shareProposalId);
    }

    /// @notice Private function to send the share proposal tokens
    /// @param to address to send tokens
    /// @param rTokenId id of the revenue token
    /// @param wTokenId id of the wealth token
    /// @param rTokenAmount amount of revenue to send
    /// @param wTokenAmount amount of wealth to send
    function _sendRevenueAndWealthTokens(
        address to,
        uint256 rTokenId,
        uint256 wTokenId,
        uint256 rTokenAmount,
        uint256 wTokenAmount
    ) private {
        uint256[] memory amounts = new uint256[](2);
        (amounts[0], amounts[1]) = (rTokenAmount, wTokenAmount);
        uint256[] memory tokenIds = new uint256[](2);
        (tokenIds[0], tokenIds[1]) = (rTokenId, wTokenId);

        managerData.hypcShareTokens.safeBatchTransferFrom(address(this), to, tokenIds, amounts, '');
    }
    
    /// @notice This contract will start the migration to the Share Manager contract
    ///         to be able to migrate the share proposal, it needs to be called by the share owner
    /// @param shareTokenNumber share token number to start migration from Share Tokens contract
    /// @param hardwareOperator address of the hardware operator to be used for the share
    function startShareProposalMigration(
        uint256 shareTokenNumber,
        address hardwareOperator,
        string memory operatorAssignedString
    ) external nonReentrant {
        if (managerData.hypcShareTokens.getShareOwner(shareTokenNumber) != _msgSender())
            revert Errors.InvalidShareTokenOwner();

        if (!managerData.hypcShareTokens.isShareActive(shareTokenNumber)) revert Errors.GetShareDataFailed();

        if (shareTokenExists[shareTokenNumber] > 0) revert Errors.ShareTokenAlreadyExists();

        if (hardwareOperator == address(0)) revert Errors.InvalidProposedAddress();

        (uint256 revenueDepositDelay, bool chypcExists) = _getShareDataRevenueDelayAndCHYPCExists(shareTokenNumber);

        if (revenueDepositDelay > MAX_REVENUE_DELAY) revert Errors.InvalidDepositRevenueDelay();

        if (!chypcExists) revert Errors.ChypcIsNotHeld();

        uint256 shareProposalId = sharesProposalsCounter++;

        _shareProposals[shareProposalId].shareTokenData = Types.ShareTokenData({
            shareTokenNumber: shareTokenNumber,
            revenueDepositDelay: revenueDepositDelay,
            rTokenId: shareTokenNumber << 1,
            wTokenId: (shareTokenNumber << 1) + 1,
            validEndTimestamp: block.timestamp + 1 days
        });

        uint256 chypcId = managerData.hypcShareTokens.getShareCHyPCId(shareTokenNumber);
        uint256 licenseId = managerData.hypcShareTokens.getShareLicenseId(shareTokenNumber);
        uint256 chypcLevel = managerData.chypcV2.getTokenLevel(chypcId);
        uint256 licenseLevel = managerData.licenseContract.getLicenseHeight(licenseId);
        uint256 revenueTokensSupply = managerData.hypcShareTokens.getRevenueTokenTotalSupply(shareTokenNumber);

        if (licenseLevel != chypcLevel)
            revert Errors.TokenLevelMismatch();

        _shareProposals[shareProposalId].chypcData = Types.TokenHolderData({
            tokenNumber: chypcId,
            tokenOwner: _msgSender(),
            tokenLevel: chypcLevel,
            initialRevenueTokens: revenueTokensSupply * 7 / 10,
            initialWealthTokens: revenueTokensSupply
        });

        _shareProposals[shareProposalId].licenseData = Types.TokenHolderData({
            tokenNumber: licenseId,
            tokenOwner: _msgSender(),
            tokenLevel: licenseLevel,
            initialRevenueTokens: 0,
            initialWealthTokens: 0
        });

        // @dev operatorRevenue: revenueTokensSupply * 2 * SIX_DECIMALS / 10,
        //      simlipified to reduce contract size.
        _shareProposals[shareProposalId].operatorData = Types.HardwareOperatorData({
            operatorRevenue: revenueTokensSupply * 200000,
            operatorAssignedString: operatorAssignedString,
            operatorAddress: hardwareOperator
        });

        _shareProposals[shareProposalId].status = Types.ShareProposalStatus.MIGRATING;

        managerData.hypcShareTokens.safeTransferFrom(
            _msgSender(), 
            address(this), 
            _shareProposals[shareProposalId].shareTokenData.rTokenId, 
            revenueTokensSupply * 3 / 10, 
            ''
        );
        shareTokenExists[shareTokenNumber] = shareProposalId;

        emit Events.ShareProposalCreated(shareProposalId);
    }

    // @notice Cancels a pending share migration
    // @param  shareProposalId Id of the proposal migration to cancel.
    function cancelShareTokenMigration(uint256 shareProposalId) external nonReentrant {
        Types.ShareProposalData storage shareProposal = _shareProposals[shareProposalId];

        uint256 shareTokenNumber = shareProposal.shareTokenData.shareTokenNumber;

        if (shareProposal.status != Types.ShareProposalStatus.MIGRATING)
            revert Errors.NotMigratingProposal();
        
        // @dev Note that the chypcDat.tokenOwner is the user that started the migration in this case.
        if (_msgSender() != shareProposal.chypcData.tokenOwner) revert Errors.InvalidCHYPCOwner();

        shareProposal.status = Types.ShareProposalStatus.ENDED;
        if (managerData.hypcShareTokens.getShareOwner(shareTokenNumber) == address(this)) {
            // @dev for the case that the user transferred the ownership of the share, but
            //      decided to cancel it instead of finishing the migration.
            managerData.hypcShareTokens.transferShareOwnership(shareTokenNumber, _msgSender());
        }
        uint256 revenueTokensSupply = managerData.hypcShareTokens.getRevenueTokenTotalSupply(shareTokenNumber);

        managerData.hypcShareTokens.safeTransferFrom(
            address(this),
            _msgSender(),
            _shareProposals[shareProposalId].shareTokenData.rTokenId, 
            revenueTokensSupply * 3 / 10, 
            ''
        );
        shareTokenExists[shareTokenNumber] = 0;

        emit Events.ShareProposalEnded(shareProposalId);
    }

    /// @notice This function will finish the migration to the Share Manager contract
    ///         The owner will be able to finish the migration only if the ownership of the share token
    ///         is changed to this contract, and the share proposal is pending
    /// @param shareProposalId Share proposal id to finish migration
    function finishShareTokenMigration(uint256 shareProposalId) external nonReentrant {
        Types.ShareProposalData storage shareProposal = _shareProposals[shareProposalId];

        uint256 shareTokenNumber = shareProposal.shareTokenData.shareTokenNumber;
       
        if (_shareProposals[shareProposalId].status != Types.ShareProposalStatus.MIGRATING) revert Errors.NotMigratingProposal();

        if (_msgSender() != shareProposal.chypcData.tokenOwner) revert Errors.InvalidShareTokenOwner();

        if (managerData.hypcShareTokens.getShareOwner(shareTokenNumber) != address(this)) 
            revert Errors.InvalidShareTokenOwner();

        managerData.hypcShareTokens.setShareMessage(
            shareTokenNumber,
            shareProposal.operatorData.operatorAssignedString
        );

        managerData.hypcShareTokens.changePendingRevenueDelay(
            shareTokenNumber,
            shareProposal.shareTokenData.revenueDepositDelay
        );        

        _shareProposals[shareProposalId].status = Types.ShareProposalStatus.STARTED;
    }

    /// @notice Private function to get the sharde data from the share token contract, 
    ///         and return the revenue deposit delay and if the share is backed by a cHyPC
    ///         Using the specific slot of the `ShareData` struct to initialize the variables
    /// @param shareNumber share number to get the data from
    /// @return revenueDepositDelay delay in seconds to unlock the revenue deposited
    /// @return chypcExists if the share was backed by a HyPC or using a cHyPC NFT
    function _getShareDataRevenueDelayAndCHYPCExists(uint256 shareNumber) private view returns(uint256 revenueDepositDelay, bool chypcExists) {
        (bool success, bytes memory data) = address(managerData.hypcShareTokens).staticcall(abi.encodeWithSelector(managerData.hypcShareTokens.shareData.selector, shareNumber));
        
        if (!success) revert Errors.GetShareDataFailed();

        assembly {
            revenueDepositDelay := mload(add(data, 0x160))
            chypcExists := mload(add(data, 0x1A0))
        }
    }

    /// @notice Private function that returns the revenue deposited into the given share.
    /// @param  shareNumber to get the data from
    /// @return revenueDeposited total revenue deposited into the share.
    function _getShareDataRevenueDeposited(uint256 shareNumber) private view returns (uint256 revenueDeposited) {
        (bool success, bytes memory data) = address(managerData.hypcShareTokens).staticcall(abi.encodeWithSelector(managerData.hypcShareTokens.shareData.selector, shareNumber));
        
        if (!success) revert Errors.GetShareDataFailed();

        assembly {
            revenueDeposited := mload(add(data, 0x140))
        }
    }

    // @notice Returns the amount of deposited revenuf or this share
    // @param  shareNumber the share tokens number
    // @return The total HyPC deposited into this share
    function getShareDataRevenueDeposited(uint256 shareNumber) external view returns(uint256) {
        return _getShareDataRevenueDeposited(shareNumber);
    }

    /// @notice Allows an user to claim Hypc tokens, based in the amount of wealth tokens available,
    ///         and also claim the surplus HyPC revenue based on their revenue tokens.
    ///         The Share Proposal needs to be ended and the user needs to have wTokens or rTokes.
    /// @param shareProposalId The share proposal Id to be used to claim the Hypc.
    /// @param overridePendingDeposits  Bool for whether or not to ignore pending deposits left in the share.
    //          It is generally advised to not override pending revenue deposits and make sure they are unlocked
    //          and claimed before claiming HyPC and surplus.
    function claimHypcPortionAndSurplus(uint256 shareProposalId, bool overridePendingDeposits) external nonReentrant {
        Types.ShareProposalData storage shareProposal = _shareProposals[shareProposalId];
        if (shareProposal.status != Types.ShareProposalStatus.ENDED || shareCancelled[shareProposalId] != true) {
            revert Errors.ShareProposalIsNotEnded();
        }

        uint256 userWealthTokenBalance = managerData.hypcShareTokens.balanceOf(
            _msgSender(),
            shareProposal.shareTokenData.wTokenId
        );
        uint256 userRevenueTokenBalance = managerData.hypcShareTokens.balanceOf(
            _msgSender(),
            shareProposal.shareTokenData.rTokenId
        );
        uint256 shareTokenNumber = shareProposal.shareTokenData.shareTokenNumber;
        uint256 userVotePower = _votePower[shareProposalId][_msgSender()];

        if ( userRevenueTokenBalance == 0 && userVotePower + userWealthTokenBalance == 0 ) {
            revert Errors.NoWealthOrRevenueTokensAvailable();
        }

        uint256 hypcRefundAmount = 0;

        if ( userRevenueTokenBalance > 0 ) {    
            // @dev Suppose there's 1000 HyPC left after share was ended. This is the shareData.hypcSurplus amount.
            //      hardware operator had 10%, so 20% of the last deposit was held (this is the 1000 HyPC).
            //      This 1000 HyPC needs to be distributed amongst the remaining 70% of rTokens in the wild.
            uint256 revenueDeposited = _getShareDataRevenueDeposited(shareTokenNumber);
            if (overridePendingDeposits == false) {
                if (managerData.hypcShareTokens.getPendingDepositsLength(shareTokenNumber) != 0) {
                    revert Errors.MustUnlockRevenueBeforeClaimingSurplus();
                } 
                if (managerData.hypcShareTokens.lastShareClaimRevenue(shareTokenNumber, _msgSender()) != revenueDeposited) {
                    revert Errors.MustClaimRevenueBeforeClaimingSurplus();
                }
            
                if (managerData.hypcShareTokens.withdrawableAmounts(shareTokenNumber, _msgSender()) != 0 ) {
                    revert Errors.MustWithdrawRevenueBeforeClaimingSurplus();
                }
            }  
           
            uint256 surplusAmount = shareProposal.hypcSurplus;
            uint256 revenueTokenTotalSupply = managerData.hypcShareTokens.getRevenueTokenTotalSupply(shareTokenNumber);
            uint256 totalWildRevenueTokens = revenueTokenTotalSupply * 7 / 10;
            uint256 amountToRefund = surplusAmount * userRevenueTokenBalance / totalWildRevenueTokens;

            managerData.hypcShareTokens.safeTransferFrom(
                _msgSender(),
                address(this),
                shareProposal.shareTokenData.rTokenId,
                userRevenueTokenBalance,
                ''
            );
            hypcRefundAmount += amountToRefund;
        }      

        if ( userWealthTokenBalance + userVotePower > 0 ) {
            uint256 wealthTokenTotalSupply = managerData.hypcShareTokens.getWealthTokenTotalSupply(shareTokenNumber);

            uint256 hypcBacked = (1 << shareProposal.chypcData.tokenLevel ) * SIX_DECIMALS;

            uint256 userTransferAmount = (hypcBacked * (userWealthTokenBalance + userVotePower)) / wealthTokenTotalSupply;

            delete _votePower[shareProposalId][_msgSender()];

            if (userWealthTokenBalance > 0) {
                managerData.hypcShareTokens.safeTransferFrom(
                    _msgSender(),
                    address(this),
                    shareProposal.shareTokenData.wTokenId,
                    userWealthTokenBalance,
                    ''
                );
            }
            
            hypcRefundAmount += userTransferAmount;
        }
        if (hypcRefundAmount > 0) {
            managerData.hypcToken.transfer(
                _msgSender(),
                hypcRefundAmount
            );
            emit Events.HypcClaimed(shareProposalId, hypcRefundAmount);
        }

    }

    /// @notice Private function to end the share proposal
    /// @dev It will send the license only if the proposal was started.
    /// @dev It will send the cHyPC only if the token was transfered
    /// @dev It will send the hardware operator revenue only if proposal started
    /// @param shareProposalId The share proposal Id to be used to end the share.
    function _endShareProposal(uint256 shareProposalId) private {
        Types.ShareProposalData storage shareProposal = _shareProposals[shareProposalId];

        bool shareProposalStarted = shareProposal.status == Types.ShareProposalStatus.STARTED;

        shareProposal.status = Types.ShareProposalStatus.ENDED;

        if (!shareProposalStarted) {
            managerData.chypcV2.safeTransferFrom(
                address(this),
                shareProposal.chypcData.tokenOwner,
                shareProposal.chypcData.tokenNumber
            );
        } else {
            managerData.licenseContract.safeTransferFrom(
                address(this),
                shareProposal.licenseData.tokenOwner,
                shareProposal.licenseData.tokenNumber
            );

            _sendRevenueToHardwareOperator(shareProposalId);
            shareCancelled[shareProposalId] = true;
            managerData.chypcV2.redeem(shareProposal.chypcData.tokenNumber);
        }

        emit Events.ShareProposalEnded(shareProposalId);
    }

    /// @notice Public function for the hardware operator to use to claim their revenue 
    /// @param  shareProposalId The share proposal Id to send out the hardware revenue.
    function sendRevenueToHardwareOperator(uint256 shareProposalId) external nonReentrant isHardwareOperator(shareProposalId) proposalActive(shareProposalId) {
        _sendRevenueToHardwareOperator(shareProposalId);
    }

    /// @notice Private function that will send the revenue collected to the hardware operator
    /// @param shareProposalId The share proposal Id to send out the hardware revenue.
    function _sendRevenueToHardwareOperator(uint256 shareProposalId) private {
        Types.ShareProposalData storage shareProposal = _shareProposals[shareProposalId];

        uint256 oldBalance = managerData.hypcToken.balanceOf(address(this));

        try managerData.hypcShareTokens.claimAndWithdraw(shareProposal.shareTokenData.shareTokenNumber) {
            // ...
        } catch (bytes memory err) {
            if (keccak256(abi.encodeWithSignature('NoRevenueToClaim()')) != keccak256(err)) {
                revert(string(err));
                
            }
        }

        uint256 newBalance = managerData.hypcToken.balanceOf(address(this));
        uint256 amountReceived = newBalance - oldBalance;
        if (amountReceived > 0) {
            uint256 hardwareOperatorRevenue = (amountReceived * shareProposal.operatorData.operatorRevenue*10) / ((1 << shareProposal.chypcData.tokenLevel) * 3000000);// 3 * SIX_DECIMALS
        
            // @dev If the hardware operator revenue is 10%, then the 20% surplus will be divide up amongst the rToken holders.
            //      However, if the share is now cancelled (specifically from the cancel share votation), then we can't deposit the revenue anymore, 
            //      so in that case we hold it in the contract so rToken holders can get their share of the final remaining HyPC in the share.
            uint256 hypcSurplus = amountReceived - hardwareOperatorRevenue;
            if ( shareProposal.status != Types.ShareProposalStatus.ENDED ) {
                managerData.hypcToken.approve(address(managerData.hypcShareTokens), hypcSurplus);
                managerData.hypcShareTokens.depositRevenue(shareProposal.shareTokenData.shareTokenNumber, hypcSurplus);
            } else {
                // @dev Add this to the hypcSurplus, that will be claimed on a per-user basis.
                shareProposal.hypcSurplus += hypcSurplus;
            }

            managerData.hypcToken.transfer(shareProposal.operatorData.operatorAddress, hardwareOperatorRevenue);
        }
    }

    // Propose functions

    /// @notice Allows an user to create a new votation and propose to cancel the share.
    /// @param shareProposalId The share proposal Id to be used to create the votation
    /// @param deadline Time to be waited to complete the votation
    function proposeCancelShare(
        uint256 shareProposalId,
        uint256 deadline
    ) external nonReentrant validVoter(shareProposalId) validProposedDeadline(shareProposalId, deadline) {
        uint256 votationId = _votations[shareProposalId].length;
        _lastVotationCreated[shareProposalId][_msgSender()] = block.timestamp;
        _votations[shareProposalId].push(Types.Votation({
            votesFor: 0,
            votesAgainst: 0,
            deadline: deadline,
            proposedData: '',
            option: Types.VotationOptions.CANCEL_SHARE,
            amountReached: false
        }));
        emit Events.VoteStarted(shareProposalId, votationId, Types.VotationOptions.CANCEL_SHARE);
    }

    /// @notice Allows an user to create a new votation and propose a new Hardware Operator.
    /// @param shareProposalId The share proposal Id to be used to create the votation
    /// @param deadline Time to be waited to complete the votation
    /// @param newProposedString the new proposed assigned string for the hardware operator
    /// @param newHardwareOperator the new hardware operator address
    function proposeNewHardwareOperatorAddress(
        uint256 shareProposalId,
        uint256 deadline,
        string memory newProposedString,
        address newHardwareOperator
    ) external nonReentrant validVoter(shareProposalId) validProposedDeadline(shareProposalId, deadline) {
        if (newHardwareOperator == address(0)) revert Errors.InvalidProposedAddress();

        _lastVotationCreated[shareProposalId][_msgSender()] = block.timestamp;
        uint256 votationId = _votations[shareProposalId].length;

        _votations[shareProposalId].push(Types.Votation({
            votesFor: 0,
            votesAgainst: 0,
            deadline: deadline,
            proposedData: abi.encode(newProposedString, newHardwareOperator),
            option: Types.VotationOptions.CHANGE_HARDWARE_OPERATOR_ADDRESS,
            amountReached: false
        }));

        emit Events.VoteStarted(shareProposalId, votationId, Types.VotationOptions.CHANGE_HARDWARE_OPERATOR_ADDRESS);
    }

    /// @notice Allows an user to create a new votation and propose a new Hardware Operator Revenue.
    /// @param shareProposalId The share proposal Id to be used to create the votation
    /// @param deadline Time to be waited to complete the votation
    /// @param newRevenue the new proposed hardware operator revenue
    /// @dev `newRevenue` should be greater or equal than 1/10 of the W Token total supply times 1,000,000
    /// @dev `newRevenue` should be less or equal than 3/10 of the W Token total supply times 1,000,000
    function proposeNewHardwareOperatorRevenue(
        uint256 shareProposalId,
        uint256 deadline,
        uint256 newRevenue
    ) external nonReentrant validVoter(shareProposalId) validProposedDeadline(shareProposalId, deadline) {
        uint256 revenueTotalSupply = managerData.hypcShareTokens.getRevenueTokenTotalSupply(
            _shareProposals[shareProposalId].shareTokenData.shareTokenNumber
        );
        // @dev revenueTotalSupply * 3 * SIX_DECIMALS / 10  but compressed to lower contract size.
        if ( newRevenue > revenueTotalSupply * 300000 ) {
            revert Errors.InvalidTokenAmount();
        }
        _lastVotationCreated[shareProposalId][_msgSender()] = block.timestamp;

        uint256 votationId = _votations[shareProposalId].length;

        _votations[shareProposalId].push(Types.Votation({
            votesFor: 0,
            votesAgainst: 0,
            deadline: deadline,
            proposedData: abi.encode(newRevenue),
            option: Types.VotationOptions.CHANGE_HARDWARE_OPERATOR_REVENUE,
            amountReached: false
        }));
        emit Events.VoteStarted(shareProposalId, votationId, Types.VotationOptions.CHANGE_HARDWARE_OPERATOR_REVENUE);
    }

    /// @notice Allows an user to create a new votation and propose a new share manager
    /// @param shareProposalId The share proposal Id to be used to create the votation
    /// @param deadline Time to be waited to complete the votation
    /// @param newShareManager The new share manager address
    function proposeNewManager(
        uint256 shareProposalId,
        uint256 deadline,
        address newShareManager
    ) external nonReentrant validVoter(shareProposalId) validProposedDeadline(shareProposalId, deadline) {
        if (
            newShareManager == address(0) ||
            newShareManager == address(this)
        ) revert Errors.InvalidProposedAddress();
        _lastVotationCreated[shareProposalId][_msgSender()] = block.timestamp;

        uint256 votationId = _votations[shareProposalId].length;

        _votations[shareProposalId].push(Types.Votation({
            votesFor: 0,
            votesAgainst: 0,
            deadline: deadline,
            proposedData: abi.encode(newShareManager),
            option: Types.VotationOptions.CHANGE_MANAGER_CONTRACT,
            amountReached: false
        }));

        emit Events.VoteStarted(shareProposalId, votationId, Types.VotationOptions.CHANGE_MANAGER_CONTRACT);
    }

    function proposeNewDepositRevenueDelay(
        uint256 shareProposalId,
        uint256 deadline,
        uint256 newDepositRevenueDelay
    ) external nonReentrant validVoter(shareProposalId) validProposedDeadline(shareProposalId, deadline) {
        if (newDepositRevenueDelay > MAX_REVENUE_DELAY) revert Errors.InvalidDepositRevenueDelay();

        uint256 votationId = _votations[shareProposalId].length;
        _lastVotationCreated[shareProposalId][_msgSender()] = block.timestamp;

        _votations[shareProposalId].push(Types.Votation({
            votesFor: 0,
            votesAgainst: 0,
            deadline: deadline,
            proposedData: abi.encode(newDepositRevenueDelay),
            option: Types.VotationOptions.CHANGE_DEPOSIT_REVENUE_DELAY,
            amountReached: false
        }));

        emit Events.VoteStarted(shareProposalId, votationId, Types.VotationOptions.CHANGE_DEPOSIT_REVENUE_DELAY);
    }

    // Votation functions

    /// @notice Function to execute or finish a votation, only able to vote if user increase the vote power
    /// @param shareProposalId Share Proposal Id to get the votations
    /// @param votationIndex Index of the votation to vote
    /// @param voteFor If true will increase the votes to execute the votation, otherwise will increase the votes to finish it.
    function vote(uint256 shareProposalId, uint256 votationIndex, bool voteFor) external nonReentrant onlyVoter(shareProposalId) validVotation(shareProposalId, votationIndex) {
        Types.Votation storage votation = _votations[shareProposalId][votationIndex];

        if (_shareProposals[shareProposalId].status == Types.ShareProposalStatus.ENDED)
            revert Errors.ShareTokenIsNotActive();

        if (votation.amountReached) revert Errors.VotationAmountReached();

        if (block.timestamp > votation.deadline) revert Errors.VotationDeadlineReached();

        if (_voted[shareProposalId][votationIndex][_msgSender()]) revert Errors.ParticipantAlreadyVote();

        _voted[shareProposalId][votationIndex][_msgSender()] = true;

        if (_votedFreeTime[shareProposalId][_msgSender()] < votation.deadline) {
            _votedFreeTime[shareProposalId][_msgSender()] = votation.deadline;
        }

        uint256 votePower = _votePower[shareProposalId][_msgSender()];

        voteFor ? votation.votesFor += votePower : votation.votesAgainst += votePower;

        uint256 wealthTokenSupply = managerData.hypcShareTokens.getWealthTokenTotalSupply(
            _shareProposals[shareProposalId].shareTokenData.shareTokenNumber
        );

        if (
            votation.option == Types.VotationOptions.CANCEL_SHARE ||
            votation.option == Types.VotationOptions.CHANGE_MANAGER_CONTRACT
        ) {
            if (
                (voteFor ? votation.votesFor : votation.votesAgainst ) >= wealthTokenSupply * SELECTED_VOTATION_PERCENT / ONE_HUNDRED_PERCENT
            ) {
                votation.amountReached = true;
            }
        } else {
            if (
                (voteFor ? votation.votesFor : votation.votesAgainst) > (wealthTokenSupply >> 1) 
            ) {
                votation.amountReached = true;
            }
        }

        if (votation.amountReached) {
            if(voteFor) {
                _executeVotationAction(shareProposalId, votationIndex);
            }
            emit Events.VotationEnded(shareProposalId, votationIndex, voteFor);
        }

        emit Events.VoteEmitted(shareProposalId, _msgSender(), votationIndex, voteFor, votePower);
    }

    /// @notice Increase the caller votation power, transfering the wealth tokens from the user to the contract
    /// @param shareProposalId Id of the Share Proposal to increase the vote power
    function increaseVotePower(uint256 shareProposalId, uint256 amount) external nonReentrant proposalActive(shareProposalId) {
        Types.ShareTokenData storage shareTokenData = _shareProposals[shareProposalId].shareTokenData;
        
        uint256 balance = managerData.hypcShareTokens.balanceOf(_msgSender(), shareTokenData.wTokenId);

        if (amount > balance || balance == 0) revert Errors.NotEnoughWealthTokensAvailable();

        managerData.hypcShareTokens.safeTransferFrom(_msgSender(), address(this), shareTokenData.wTokenId, amount, '');

        _votePower[shareProposalId][_msgSender()] += amount;
    }

    /// @notice Decrease the caller votation power, transfering the wealth tokens from the contract to the user
    /// @param shareProposalId Id of the Share Proposal to decrease the vote power
    function decreaseVotePower(uint256 shareProposalId) external nonReentrant {
        if (_shareProposals[shareProposalId].status != Types.ShareProposalStatus.ENDED && _votations[shareProposalId].length > 0 && _votedFreeTime[shareProposalId][_msgSender()] >= block.timestamp)
            revert Errors.VotePowerLockedUntilDeadline();
        Types.ShareTokenData storage shareTokenData = _shareProposals[shareProposalId].shareTokenData;

        uint256 balance = _votePower[shareProposalId][_msgSender()];

        delete _votePower[shareProposalId][_msgSender()];

        managerData.hypcShareTokens.safeTransferFrom(address(this), _msgSender(), shareTokenData.wTokenId, balance, '');
    }

    // Votation Actions

    /// Private function that will execute the votations actions based on the votation type
    /// @param shareProposalId Id of the Share Proposal to execute the action
    /// @param votationIndex Index of the votation to execute the action
    /// @dev If `votationIndex` is zero the proposal will be cancelled
    function _executeVotationAction(uint256 shareProposalId, uint256 votationIndex) private {
        Types.VotationOptions votationOption = _votations[shareProposalId][votationIndex].option;

        if (votationOption == Types.VotationOptions.CANCEL_SHARE) {
            _cancelShareProposal(shareProposalId);
        }

        if (votationOption == Types.VotationOptions.CHANGE_HARDWARE_OPERATOR_ADDRESS) {
            _changeHardwareOperatorAddress(shareProposalId, votationIndex);
        }

        if (votationOption == Types.VotationOptions.CHANGE_HARDWARE_OPERATOR_REVENUE) {
            _changeHardwareOperatorRevenue(shareProposalId, votationIndex);
        }

        if (votationOption == Types.VotationOptions.CHANGE_MANAGER_CONTRACT) {
            _changeShareManagerContract(shareProposalId, votationIndex);
        }

        if (votationOption == Types.VotationOptions.CHANGE_DEPOSIT_REVENUE_DELAY) {
            _changeDepositRevenueDelay(shareProposalId, votationIndex);
        }
    }

    /// Private function that will execute the cancel action
    /// @param shareProposalId Id of the Share Proposal to be cancelled
    function _cancelShareProposal(uint256 shareProposalId) private {
        if (_shareProposals[shareProposalId].shareTokenData.validEndTimestamp > block.timestamp)
            revert Errors.ShareProposalEndTimeNotReached();

        managerData.hypcShareTokens.cancelShareTokens(_shareProposals[shareProposalId].shareTokenData.shareTokenNumber);

        _endShareProposal(shareProposalId);

        emit Events.VoteActionExecuted(shareProposalId, Types.VotationOptions.CANCEL_SHARE);
    }

    /// Private function that will execute the change hardware operator action
    /// @param shareProposalId Id of the Share Proposal to be changed
    /// @param votationIndex Index of the votation to execute
    function _changeHardwareOperatorAddress(uint256 shareProposalId, uint256 votationIndex) private {

        Types.ShareProposalData storage shareProposal = _shareProposals[shareProposalId];
       
        _sendRevenueToHardwareOperator(shareProposalId);

        (string memory newHardwareOperatorString, address newHardwareOperatorAddress) = abi.decode(
            _votations[shareProposalId][votationIndex].proposedData,
            (string, address)
        );

        shareProposal.operatorData.operatorAddress = newHardwareOperatorAddress;
        shareProposal.operatorData.operatorAssignedString = newHardwareOperatorString;

        managerData.hypcShareTokens.setShareMessage(
            shareProposal.shareTokenData.shareTokenNumber,
            shareProposal.operatorData.operatorAssignedString
        );

        emit Events.VoteActionExecuted(shareProposalId, Types.VotationOptions.CHANGE_HARDWARE_OPERATOR_ADDRESS);
    }

    /// Private function that will execute the change hardware operator revenue action
    /// @param shareProposalId Id of the Share Proposal to be changed
    /// @param votationIndex Index of the votation to execute
    function _changeHardwareOperatorRevenue(uint256 shareProposalId, uint256 votationIndex) private{
        _sendRevenueToHardwareOperator(shareProposalId);

        _shareProposals[shareProposalId].operatorData.operatorRevenue = abi.decode(_votations[shareProposalId][votationIndex].proposedData, (uint256));

        emit Events.VoteActionExecuted(shareProposalId, Types.VotationOptions.CHANGE_HARDWARE_OPERATOR_REVENUE);
    }

    /// Private function that will execute the change share manager action
    /// @param shareProposalId Id of the Share Proposal to be changed
    /// @param votationIndex Index of the votation to execute
    /// @dev The share proposal will be ended afterward
    function _changeShareManagerContract(uint256 shareProposalId, uint256 votationIndex) private {
        Types.ShareProposalData storage shareProposal = _shareProposals[shareProposalId];
        uint256 shareTokenNumber = shareProposal.shareTokenData.shareTokenNumber;

        address newManager = abi.decode(_votations[shareProposalId][votationIndex].proposedData, (address));

        managerData.hypcShareTokens.transferShareOwnership(shareTokenNumber, newManager);

        _sendRevenueToHardwareOperator(shareProposalId);

        shareProposal.status = Types.ShareProposalStatus.ENDED;

        _sendRevenueAndWealthTokens(
            newManager,
            shareProposal.shareTokenData.rTokenId,
            shareProposal.shareTokenData.wTokenId,
            managerData.hypcShareTokens.balanceOf(
                address(this),
                shareProposal.shareTokenData.rTokenId
            ),
            0
        );
        shareTokenExists[shareTokenNumber] = 0;

        emit Events.VoteActionExecuted(shareProposalId, Types.VotationOptions.CHANGE_MANAGER_CONTRACT);
    }

    /// Private function that will execute the change deposit revenue delay
    /// @param shareProposalId Id of the Share Proposal to be changed
    /// @param votationIndex Index of the votation to execute
    function _changeDepositRevenueDelay(uint256 shareProposalId, uint256 votationIndex) private {

        _shareProposals[shareProposalId].shareTokenData.revenueDepositDelay = abi.decode(_votations[shareProposalId][votationIndex].proposedData, (uint256));

        managerData.hypcShareTokens.changePendingRevenueDelay(
            _shareProposals[shareProposalId].shareTokenData.shareTokenNumber,
            _shareProposals[shareProposalId].shareTokenData.revenueDepositDelay
        );

        emit Events.VoteActionExecuted(shareProposalId, Types.VotationOptions.CHANGE_DEPOSIT_REVENUE_DELAY);
    }

    // Get functions

    // ManagerData getters

/*   
    /// @notice Get the setted swap V2 contract
    /// @return Swap V2 contract address
    function getCHYPC() external view returns (address) {
        return address(managerData.chypcV2);
    }

    /// @notice Get the setted License contract
    /// @return License contract address
    function getLicenseContract() external view returns (address) {
        return address(managerData.licenseContract);
    }

    /// @notice Get the setted HyperCycle Share Token contract
    /// @return HyperCycle Share Token contract address
    function getHypcShareTokenContract() external view returns (address) {
        return address(managerData.hypcShareTokens);
    }

    /// @notice Get the setted HyperCycle Token contract
    /// @return HyperCycle ERC 20 token
    function getHypcToken() external view returns (address) {
        return address(managerData.hypcToken);
    }
*/
    /// @notice Get the contract addresses used by this contrat
    /// @return addresses of the cHyPC contract, the License contract, the ShareTokens contract, and the HyPC contract.
    function getContracts() external view returns (address,address,address,address) {
        return (address(managerData.chypcV2), address(managerData.licenseContract), address(managerData.hypcShareTokens), address(managerData.hypcToken));
    }

    // ShareProposalData getters

    /// @notice Get the data of a selected share proposal
    /// @param shareProposalId Id of the Share Proposal
    /// @return Share Proposal Data
    function getShareProposalData(uint256 shareProposalId) external view returns (Types.ShareProposalData memory) {
        return _shareProposals[shareProposalId];
    }
/*
    /// @notice Get the status of a selected share proposal
    /// @param shareProposalId Id of the share proposal
    /// @return Share proposal status
    function getShareProposalStatus(uint256 shareProposalId) external view returns (Types.ShareProposalStatus) {
        return _shareProposals[shareProposalId].status;
    }
    
    /// @notice Get the revenue deposit delay of a selected share proposal
    /// @param shareProposalId Id of the share proposal
    /// @return Revenue deposit delay
    function getRevenueDelay(uint256 shareProposalId) external view returns (uint256) {
        return _shareProposals[shareProposalId].shareTokenData.revenueDepositDelay;
    }

    /// @notice Get the actual Hardware Operator Revenue of a selected share proposal
    /// @param shareProposalId Id of the share proposal
    /// @return Hardware Operator Revenue
    function getShareProposalHardwareOperatorRevenue(uint256 shareProposalId) external view returns (uint256) {
        return _shareProposals[shareProposalId].operatorData.operatorRevenue;
    }

    /// @notice Get the License token id
    /// @param shareProposalId Id of the share proposal
    /// @return License token id
    function getShareProposalLicenseNumber(uint256 shareProposalId) external view returns (uint256) {
        return _shareProposals[shareProposalId].licenseData.tokenNumber;
    }

    /// @notice Get the License Owner
    /// @param shareProposalId Id of the share proposal
    /// @return License Owner
    function getShareProposalLicenseOwner(uint256 shareProposalId) external view returns (address) {
        return _shareProposals[shareProposalId].licenseData.tokenOwner;
    }

    /// @notice Get the License Level
    /// @param shareProposalId Id of the share proposal
    /// @return License level
    function getShareProposalLicenseLevel(uint256 shareProposalId) external view returns (uint256) {
        return _shareProposals[shareProposalId].licenseData.tokenLevel;
    }

    /// @notice Get the cHyPc token id
    /// @param shareProposalId Id of the share proposal
    /// @return cHyPc token id
    function getShareProposalCHYPCNumber(uint256 shareProposalId) external view returns (uint256) {
        return _shareProposals[shareProposalId].chypcData.tokenNumber;
    }

    /// @notice Get the cHyPc owner
    /// @param shareProposalId Id of the share proposal
    /// @return cHyPc owner
    function getShareProposalCHYPCOwner(uint256 shareProposalId) external view returns (address) {
        return _shareProposals[shareProposalId].chypcData.tokenOwner;
    }

    /// @notice Get the cHyPc level
    /// @param shareProposalId Id of the share proposal
    /// @return cHyPc level
    function getShareProposalCHYPCLevel(uint256 shareProposalId) external view returns (uint256) {
        return _shareProposals[shareProposalId].chypcData.tokenLevel;
    }

    /// @notice Get the Hardware Operator address
    /// @param shareProposalId Id of the share proposal
    /// @return Hardware Operator address
    function getShareProposalHardwareOperator(uint256 shareProposalId) external view returns (address) {
        return _shareProposals[shareProposalId].operatorData.operatorAddress;
    }

    /// @notice Get the Hardware Operator address
    /// @param shareProposalId Id of the share proposal
    /// @return the share number for this proposal
    function getShareProposalShareNumber(uint256 shareProposalId) external view returns (uint256) {
        return _shareProposals[shareProposalId].shareTokenData.shareTokenNumber;
    }
*/  

    // Votation getters

    /// @notice Get the amount of votes needed to execute or finish the votation
    /// @return Votes needed 
    function getVotationConsensus(uint256 shareProposalId, Types.VotationOptions votationOption) external view returns (uint256) {
        uint256 totalSupply = managerData.hypcShareTokens.getWealthTokenTotalSupply(
            _shareProposals[shareProposalId].shareTokenData.shareTokenNumber
        );
        if (votationOption == Types.VotationOptions.CANCEL_SHARE || votationOption == Types.VotationOptions.CHANGE_MANAGER_CONTRACT) {
            return totalSupply * SELECTED_VOTATION_PERCENT / ONE_HUNDRED_PERCENT;
        } else {
            return (totalSupply >> 1);
        }
    }

    /// @notice Get the voting stats for this user, including the vote power and votedFreeTime. 
    /// @param shareProposalId Id of the share proposal
    /// @param user address of the voter to check
    /// @return votePower of this user.
    ///         votedFreeTime: the timestamp when this user will be able to decrease their votePower
    function getVoteStats(uint256 shareProposalId, address user) external view returns (uint256, uint256) {
        return (_votePower[shareProposalId][user], _votedFreeTime[shareProposalId][user]);
    }

    /// @notice Get if a selected address has voted in a specific votation
    /// @param shareProposalId Id of the share proposal
    /// @param votationIndex Index of the votation
    /// @param voter address of the voter to check
    /// @return If voter has voted
    function getUserVote(uint256 shareProposalId, uint256 votationIndex, address voter) external view returns (bool) {
        return _voted[shareProposalId][votationIndex][voter];
    }


    /// @notice Get the amount of votations a share proposal has
    /// @param shareProposalId Id of the share proposal
    /// @return Amount of votations
    function getVotationsLength(uint256 shareProposalId) external view returns (uint256) {
        return _votations[shareProposalId].length;
    }

    /// @notice Get the votation data
    /// @param shareProposalId Id of the share proposal
    /// @param votationIndex Index of the votation
    /// @return Votation data
    function getVotationData(
        uint256 shareProposalId,
        uint256 votationIndex
    ) external view validVotation(shareProposalId, votationIndex) returns (Types.Votation memory) {
        return _votations[shareProposalId][votationIndex];
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @notice Interface for the HyperCycleToken.sol contract.
interface IHYPC is IERC20 {
    /*
     * Accesses the ERC20 functions of the HYPC contract. The burn function
     * is also exposed for future contracts.
    */
    /// @notice Burns an amount of the HyPC ERC20.
    function burn(uint256 amount) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/interfaces/IERC721.sol";

/// @notice Interface for the HYPCSwap.sol contract.
interface IHYPCSwapV2 is IERC721 {
    /**
     * Accesses the addNFT function so that the CHYPC contract can
     * add the newly created NFT into this contract.
     */

    function addRootTokens(uint256 tokens) external;

    function splitHeldToken(uint256 level, uint256 skipLevels) external;

    function swapV2(uint256 level) external;

    function redeem(uint256 tokenNumber) external;

    function assignNumber(uint256 tokenNumber, uint256 targetNumber) external;

    function assignString(uint256 tokenNumber, string memory data) external;

    function burn(uint256 tokenNumber, string memory data) external;

    function assign(uint256 tokenNumber, string memory data) external;

    function swap() external;


    function getAssignment(uint256 tokenNumber) external view returns (string memory);
    function getAssignmentNumber(uint256 tokenNumber) external view returns (uint256);
    function getAssignmentString(uint256 tokenNumber) external view returns (string memory);



    function getBurnData(uint256 tokenNumber) external view returns (string memory);

    function getAvailableToken(uint256 level, uint256 index) external view returns (uint256);

    function getTokenLevel(uint256 tokenNumber) external view returns (uint256);

    function getAssignmentTargetNumber(uint256 targetNumber) external view returns (uint256);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/// @notice Interface for the CHYPC.sol contract.
interface IHyperCycleLicense is IERC721 {
    /**
     * Accesses the assignment function of c_HyPC so the swap can remove 
     * the assignment data when a token is redeemed or swapped.
     */
    /// @notice Creates a new root token inside this contract, with a specified licenseID.
    function mint(
        uint256 numTokens
    ) external;

    /// @notice Splits a given token into two new tokens, with corresponding licenseID's.
    function split(
        uint256 tokenId
    ) external;

    /// @notice Burns a given tokenId with a specified burn string.
    function burn(
        uint256 tokenId,
        string memory burnString          
    ) external;

    /// @notice Merges together two child licenses into a parent license.
    function merge(
        uint256 tokenId
    ) external;

    /// @notice Returns the burn data from the given tokenId.
    function getBurnData(
        uint256 tokenId
    ) external view returns (string memory);

    /// @notice Returns the license height of the given tokenId.
    function getLicenseHeight(
        uint256 licenseId
    ) external view returns (uint8);

    /// @notice Returns the license height of the given tokenId.
    function getLicenseStatus(
        uint256 licenseId
    ) external view returns (uint256);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import '@openzeppelin/contracts/token/ERC1155/IERC1155.sol';

/// @notice Interface for the HyperCycleShareTokens.sol contract.
interface IHyperCycleShareTokensV2 is IERC1155 {
    struct PendingDeposit {
        uint256 availableAtTimestamp;
        uint256 amount;
    }

    function shareData(
        uint256 shareNumber
    )
        external
        pure
        returns (
            uint256 licenseId,
            uint256 chypcId,
            uint256 status,
            address owner,
            uint256 rTokenNumber,
            uint256 wTokenNumber,
            uint256 rTokenSupply,
            uint256 wTokenSupply,
            uint256 startTimestamp,
            uint256 revenueDeposited,
            uint256 revenueDepositDelay,
            string memory message,
            bool chypcTokenHeld
        );

    function currentShareNumber() external returns (uint256);

    function increaseShareLimit(uint256 number) external;

    function createShareTokens(
        uint256 licenseNumber,
        uint256 chypcNumber,
        bool chypcTokenHeld,
        string memory startingMessage,
        uint256 maxRevenueDeposit
    ) external;

    function changePendingRevenueDelay(uint256 shareNumber, uint256 newDelay) external;

    function transferShareOwnership(uint256 shareNumber, address to) external;

    function cancelShareTokens(uint256 shareNumber) external;

    function depositRevenue(uint256 shareNumber, uint256 amt) external;

    function claimRevenue(uint256 shareNumber) external;

    function withdrawEarnings(uint256 shareNumber) external;

    function claimAndWithdraw(uint256 shareNumber) external;

    function setShareMessage(uint256 shareNumber, string memory message) external;

    function burnRevenueTokens(uint256 shareNumber, uint256 amount) external;

    function burnWealthTokens(uint256 shareNumber, uint256 amount) external;

    function getShareLicenseId(uint256 shareNumber) external view returns (uint256);

    function getShareCHyPCId(uint256 shareNumber) external view returns (uint256);

    function getShareOwner(uint256 shareNumber) external view returns (address);

    function getShareRevenueTokenId(uint256 shareNumber) external view returns (uint256);

    function getShareWealthTokenId(uint256 shareNumber) external view returns (uint256);

    function getShareTotalRevenue(uint256 shareNumber) external view returns (uint256);

    function getShareStartTime(uint256 shareNumber) external view returns (uint256);

    function getShareMessage(uint256 shareNumber) external view returns (string memory);

    function isShareActive(uint256 shareNumber) external view returns (bool);

    function shareCreated(uint256 shareNumber) external view returns (bool);

    function getRevenueTokenTotalSupply(uint256 shareNumber) external view returns (uint256);

    function getWealthTokenTotalSupply(uint256 shareNumber) external view returns (uint256);

    function getPendingDeposit(uint256 shareNumber, uint256 index) external view returns (PendingDeposit memory);

    function getPendingDepositsLength(uint256 shareNumber) external view returns (uint256);
    
    function lastShareClaimRevenue(uint256 shareTokenNumber, address user) external view returns (uint256);

    function withdrawableAmounts(uint256 shareTokenNUmber, address user) external view returns (uint256); 
}
// SPDX-License-Identifier: MIT
/*
    Share Manager Errors
*/

pragma solidity ^0.8.19;

library ShareManagerErrors {
    error NotMigratingProposal();

    error ShareProposalIsNotPending();

    error ShareProposalIsNotEnded();

    error ShareProposalEndTimeNotReached();

    error ShareProposalMustBeActive();

    error InvalidProposedAddress();

    error InvalidHYPCTokenAddress();

    error InvalidCHYPCAddress();

    error InvalidCHYPCOwner();

    error InvalidTokenAmount();

    error InvalidShareTokenContract();

    error VotationCreatedTooSoon();

    error InvalidLicenseAddress();

    error InvalidLicenseOwner();

    error InvalidDeadline();

    error InvalidVotingDuration();
 
    error InvalidVotation();

    error InvalidVotationOption();

    error DeadlineMustBeIncreasing();

    error DeadlineTooLate();

    error VotePowerLockedUntilDeadline();

    error ChypcIsNotHeld();

    error ParticipantAlreadyVote();

    error NotEnoughWealthTokensAvailable();

    error VotationAmountReached();

    error VotationDeadlineReached();

    error TokenLevelMismatch();

    error ShareTokenAlreadyExists();

    error InvalidShareTokenOwner();

    error GetShareDataFailed();

    error ShareTokenIsNotActive();

    error NotEnoughHYPC();

    error InvalidDepositRevenueDelay();

    error NoWealthOrRevenueTokensAvailable();

    error MustUnlockRevenueBeforeClaimingSurplus();

    error MustClaimRevenueBeforeClaimingSurplus();
        
    error MustWithdrawRevenueBeforeClaimingSurplus();

    error MustBeClaimedByHardwareOperatorAddress();
}
// SPDX-License-Identifier: MIT
/*
    Share Manager Events
*/

pragma solidity ^0.8.19;

import {ShareManagerTypes} from './ShareManagerTypesV2.sol';

library ShareManagerEvents {
    event ShareProposalCreated(uint256 shareProposalId);

    event ShareProposalStarted(uint256 shareProposalId);

    event ShareProposalEnded(uint256 shareProposalId);

    event HypcClaimed(uint256 shareProposalId, uint256 hypcClaimed);

    event VoteStarted(uint256 shareProposalId, uint256 votationIndex, ShareManagerTypes.VotationOptions selectedOption);

    event VoteActionExecuted(uint256 shareProposalId, ShareManagerTypes.VotationOptions selectedOption);

    event VoteEmitted(uint256 shareProposalId, address voter, uint256 votationIndex, bool voteFor, uint256 votePower);

    event VotationEnded(uint256 shareProposalId, uint256 votationIndex, bool voteForWinner);
}
// SPDX-License-Identifier: MIT
/*
    Share Manager Types
*/

pragma solidity ^0.8.19;

import {IHYPCSwapV2} from '../interfaces/IHYPCSwapV2.sol';
import {IHyperCycleLicense} from '../interfaces/IHyperCycleLicense.sol';
import {IHyperCycleShareTokensV2} from '../interfaces/IHyperCycleShareTokensV2.sol';
import {IHYPC} from '../interfaces/IHYPC.sol';

library ShareManagerTypes {
    enum ShareProposalStatus {
        NOT_CREATED,
        MIGRATING,
        PENDING,
        STARTED,
        ENDED
    }

    enum VotationOptions {
        NULL_OPTION,
        CANCEL_SHARE,
        CHANGE_HARDWARE_OPERATOR_ADDRESS,
        CHANGE_HARDWARE_OPERATOR_REVENUE,
        CHANGE_MANAGER_CONTRACT,
        CHANGE_DEPOSIT_REVENUE_DELAY
    }

    enum ConsensusOptions {
        ONE_HUNDRED_PERCENT,
        NINETY_PERCENT
    }

    struct ManagerData {
        IHYPC hypcToken;
        IHYPCSwapV2 chypcV2;
        IHyperCycleLicense licenseContract;
        IHyperCycleShareTokensV2 hypcShareTokens;
    }

    struct ShareProposalData {
        ShareTokenData shareTokenData;
        TokenHolderData licenseData;
        TokenHolderData chypcData;
        HardwareOperatorData operatorData;
        ShareProposalStatus status;
        uint256 hypcSurplus;
    }

    struct ShareTokenData {
        uint256 validEndTimestamp;
        uint256 shareTokenNumber;
        uint256 rTokenId;
        uint256 wTokenId;
        uint256 revenueDepositDelay;
    }

    struct TokenHolderData {
        uint256 tokenNumber;
        uint256 tokenLevel;
        uint256 initialRevenueTokens;
        uint256 initialWealthTokens;
        address tokenOwner;
    }

    struct HardwareOperatorData {
        uint256 operatorRevenue;
        string operatorAssignedString;
        address operatorAddress;
    }

    struct Votation {
        uint256 votesFor;
        uint256 votesAgainst;
        uint256 deadline;
        bytes proposedData;
        VotationOptions option;
        bool amountReached;
    }

    struct ShareData {
        uint256 licenseId;
        uint256 chypcId;
        uint256 status;
        address owner;
        uint256 rTokenNumber;
        uint256 wTokenNumber;
        uint256 rTokenSupply;
        uint256 wTokenSupply;
        uint256 startTimestamp;
        uint256 revenueDeposited;
        uint256 revenueDepositDelay;
        string message;
        bool chypcTokenHeld;
    }
}