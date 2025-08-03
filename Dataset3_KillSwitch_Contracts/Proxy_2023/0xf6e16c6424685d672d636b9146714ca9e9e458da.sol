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
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/extensions/IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
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
// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.18;

import {IERC721} from '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import {ReentrancyGuard} from '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {IERC1155} from '@openzeppelin/contracts/token/ERC1155/IERC1155.sol';
import {SafeERC20} from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import {ERC1155Holder} from '@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol';
import {IERC2981} from '@openzeppelin/contracts/interfaces/IERC2981.sol';
import {IERC165} from '@openzeppelin/contracts/utils/introspection/IERC165.sol';
import {ILoveNFTMarketplace} from './interfaces/ILoveNFTMarketplace.sol';
import {ILoveNFTShared} from './interfaces/ILoveNFTShared.sol';
import {LoveRoles} from './lib/LoveRoles.sol';
import {TokenIdentifiers} from './lib/TokenIdentifiers.sol';

/* Love NFT Marketplace
    List NFT,
    Buy NFT,
    Offer NFT,
    Accept offer,
    Create auction,
    Bid place,
    & support Royalty
*/
contract LoveNFTMarketplace is ILoveNFTMarketplace, LoveRoles, ERC1155Holder, ReentrancyGuard {
  using TokenIdentifiers for uint256;
  using SafeERC20 for IERC20;

  uint256 public platformFee = 50;
  uint256 public constant LISTING_FEE = 1 ether;
  uint256 public constant MINIMUM_BUYING_FEE = 5 ether;
  uint256 public reservedBalance;
  address public feeReceiver;
  ILoveNFTShared private immutable loveNFTShared;
  IERC20 private immutable loveToken;

  constructor(address _loveToken, address _loveNFTShared, address tokenOwner) {
    transferOwnership(tokenOwner);
    loveToken = IERC20(_loveToken);
    loveNFTShared = ILoveNFTShared(_loveNFTShared);
  }

  // NFT => list struct
  mapping(bytes32 encodedNft => ListNFT listingStruct) private listNfts;

  // NFT => offerer address => offer price => offer struct
  mapping(bytes32 encodedNft => mapping(address offerer => mapping(uint256 price => OfferNFT offerStruct)))
    private offerNfts;

  // NFT => action struct
  mapping(bytes32 encodedNft => AuctionNFT auctionStruct) private auctionNfts;

  modifier onlyListedNFT(NFT calldata nft) {
    ListNFT memory listedNFT = listNfts[encodeNft(nft)];
    require(
      listedNFT.seller != address(0) && listedNFT.price > 0 && block.timestamp <= listedNFT.endTime,
      'not listed'
    );
    _;
  }

  modifier onAuction(NFT calldata nft) {
    NFT memory auctionNft = auctionNfts[encodeNft(nft)].nft;
    require(auctionNft.addr == nft.addr && auctionNft.tokenId == nft.tokenId, 'auction is not created');
    _;
  }

  modifier notOnAuction(NFT calldata nft) {
    AuctionNFT memory auction = auctionNfts[encodeNft(nft)];
    require(auction.nft.addr == address(0) || auction.success, 'auction already created');
    _;
  }

  modifier onlyOfferedNFT(OfferNFTParams calldata params) {
    OfferNFT memory offer = offerNfts[encodeNft(params.nft)][params.offerer][params.price];
    require(offer.offerer == params.offerer && offer.offerPrice == params.price, 'not offered');
    require(!offer.accepted, 'already accepted');
    _;
  }

  modifier minimumPrice(uint256 price) {
    require(price > MINIMUM_BUYING_FEE, 'price is less than the minimum commission');
    _;
  }

  /**
   * @notice List NFT on Marketplace
   * @param params The listing parameters (nft, tokenId, price, startTime, endTime)
   */
  function listNft(ListingParams calldata params) external minimumPrice(params.price) returns (uint256) {
    require(block.timestamp <= params.startTime && params.endTime > params.startTime, 'invalid time range');

    bytes32 encodedNft = encodeNft(params.nft);
    ListNFT memory listedNFT = listNfts[encodedNft];
    TokenType tokenType = _getTokenType(params.nft.addr);
    // If the NFT is already listed, the seller must be the same as the caller.
    if (listedNFT.seller != address(0)) {
      require(listedNFT.seller == msg.sender, 'not seller');
    } else {
      // Otherwise, the caller must be the owner of the NFT.
      _verifyOwnershipAndApproval(msg.sender, params.nft, tokenType);
      // The caller must have enough tokens for the platform fee.
      require(loveToken.balanceOf(msg.sender) >= LISTING_FEE, 'no tokens for platform fee');
      // The caller must transfer the NFT to the marketplace contract.
      _transferNFT(msg.sender, address(this), params.nft, tokenType);
      // The caller must transfer the platform fee to the marketplace contract.
      loveToken.safeTransferFrom(msg.sender, address(this), LISTING_FEE);
    }

    // Update the listing.
    listNfts[encodedNft] = ListNFT({
      nft: params.nft,
      tokenType: tokenType,
      price: params.price,
      seller: msg.sender,
      startTime: params.startTime,
      endTime: params.endTime
    });
    emit ListedNFT(params.nft.addr, params.nft.tokenId, params.price, msg.sender, params.startTime, params.endTime);
    return LISTING_FEE;
  }

  function getListedNFT(NFT calldata nft) external view returns (ListNFT memory) {
    return listNfts[encodeNft(nft)];
  }

  /**
   * @notice Cancel listed NFT
   * @param nft NFT address
   */
  function cancelListedNFT(NFT calldata nft) external onlyListedNFT(nft) {
    bytes32 encodedNft = encodeNft(nft);
    ListNFT memory listedNFT = listNfts[encodedNft];
    // Ensure the sender is the seller
    require(listedNFT.seller == msg.sender, 'not seller');

    delete listNfts[encodedNft];
    // Transfer the NFT back to the seller
    _transferNFT(address(this), msg.sender, nft, listedNFT.tokenType);

    emit CanceledListedNFT(
      listedNFT.nft.addr,
      listedNFT.nft.tokenId,
      listedNFT.price,
      listedNFT.seller,
      listedNFT.startTime,
      listedNFT.endTime
    );
  }

  function buyLazyListedNFT(
    ILoveNFTShared.MintRequest calldata params,
    bytes calldata signature
  ) external returns (uint256 priceWithRoyalty) {
    address creator = params.tokenId.tokenCreator();

    // calculate platform fee
    (uint256 amount, ) = calculateFeeAndAmount(params.price);
    // calculate royalty fee

    uint256 royaltyAmount = (params.price * params.royaltyFraction) / loveNFTShared.feeDenominator();

    TokenRoyaltyInfo memory royaltyInfo = TokenRoyaltyInfo(params.royaltyRecipient, royaltyAmount);

    loveToken.safeTransferFrom(msg.sender, address(this), params.price + royaltyInfo.royaltyAmount);

    if (royaltyInfo.royaltyReceiver == creator) {
      uint256 amountWithRoyalty = amount + royaltyInfo.royaltyAmount;
      loveToken.safeTransfer(creator, amountWithRoyalty);
    } else {
      _transferRoyalty(royaltyInfo, address(this));
      loveToken.safeTransfer(creator, amount);
    }

    // mint nft
    loveNFTShared.redeem(msg.sender, params, signature);

    emit BoughtNFT(address(loveNFTShared), params.tokenId, params.price, creator, msg.sender);

    return royaltyInfo.royaltyAmount + params.price;
  }

  /**
   * @notice Buy NFT on Marketplace
   * @param nft NFT address
   * @param price listed price
   * @return priceWithRoyalty price with fees
   */
  function buyNFT(NFT calldata nft, uint256 price) external onlyListedNFT(nft) returns (uint256 priceWithRoyalty) {
    bytes32 encodedNft = encodeNft(nft);
    ListNFT memory listedNft = listNfts[encodedNft];
    require(price >= listedNft.price, 'less than listed price');

    delete listNfts[encodedNft];
    TokenRoyaltyInfo memory royaltyInfo = _tryGetRoyaltyInfo(nft, price);
    _transferRoyalty(royaltyInfo, msg.sender);
    // remove nft from listing
    (uint256 amount, uint256 buyingFee) = calculateFeeAndAmount(price);
    // transfer platform fee to marketplace contract
    loveToken.safeTransferFrom(msg.sender, address(this), buyingFee);

    // Transfer payment to nft owner
    loveToken.safeTransferFrom(msg.sender, listedNft.seller, amount);

    // Transfer NFT to buyer
    _transferNFT(address(this), msg.sender, nft, listedNft.tokenType);

    emit BoughtNFT(nft.addr, nft.tokenId, price, listedNft.seller, msg.sender);
    return price + royaltyInfo.royaltyAmount;
  }

  /**
   * @notice Offer NFT on Marketplace
   * @param params OfferNFTParams
   * @return offerPriceWithRoyalty offer price with royalty
   */
  function offerNFT(
    OfferNFTParams calldata params
  ) external notOnAuction(params.nft) minimumPrice(params.price) returns (uint256) {
    // nft should be minted
    TokenType tokenType = _getTokenType(params.nft.addr);
    if (tokenType == TokenType.ERC721) {
      require(IERC721(params.nft.addr).ownerOf(params.nft.tokenId) != address(0), 'not exist');
    } else if (params.nft.addr == address(loveNFTShared)) {
      require(loveNFTShared.exists(params.nft.tokenId), 'not exist');
    }

    TokenRoyaltyInfo memory royaltyInfo = _tryGetRoyaltyInfo(params.nft, params.price);
    uint256 offerPriceWithRoyalty = params.price + royaltyInfo.royaltyAmount;

    reservedBalance += offerPriceWithRoyalty;

    loveToken.safeTransferFrom(msg.sender, address(this), offerPriceWithRoyalty);

    offerNfts[encodeNft(params.nft)][msg.sender][params.price] = OfferNFT({
      nft: params.nft,
      tokenType: tokenType,
      offerer: msg.sender,
      offerPrice: params.price,
      accepted: false,
      royaltyInfo: royaltyInfo
    });

    emit OfferedNFT(params.nft.addr, params.nft.tokenId, params.price, msg.sender);
    return offerPriceWithRoyalty;
  }

  /**
   * @notice Cancel offer
   * @param params The offer parameters (nft, tokenId, offerer, price)
   * @return offerPriceWithRoyalty offer price with royalty
   */
  function cancelOfferNFT(OfferNFTParams calldata params) external onlyOfferedNFT(params) returns (uint256) {
    require(params.offerer == msg.sender, 'not offerer');

    bytes32 encodedNft = encodeNft(params.nft);
    OfferNFT memory offer = offerNfts[encodedNft][params.offerer][params.price];
    delete offerNfts[encodedNft][params.offerer][params.price];

    uint256 offerPriceWithRoyalty = offer.offerPrice + offer.royaltyInfo.royaltyAmount;
    reservedBalance -= offerPriceWithRoyalty;

    loveToken.safeTransfer(offer.offerer, offerPriceWithRoyalty);

    emit CanceledOfferedNFT(offer.nft.addr, offer.nft.tokenId, offer.offerPrice, params.offerer);
    return offerPriceWithRoyalty;
  }

  /**
   * @notice Accept offer
   * @param params The offer parameters (nft, tokenId, offerer, price)
   * @return amount amount transfer to seller
   */
  function acceptOfferNFT(
    OfferNFTParams calldata params
  ) external onlyOfferedNFT(params) nonReentrant returns (uint256) {
    bytes32 encodedNft = encodeNft(params.nft);
    OfferNFT storage offer = offerNfts[encodedNft][params.offerer][params.price];
    ListNFT memory list = listNfts[encodedNft];
    address from = address(this);
    // If the NFT is listed, the seller is the owner of the NFT
    if (list.seller != address(0)) {
      require(msg.sender == list.seller, 'not listed owner');
      delete listNfts[encodedNft];
    } else {
      // If not, the seller is the owner of the NFT
      _verifyOwnershipAndApproval(msg.sender, params.nft, offer.tokenType);
      from = msg.sender;
    }

    TokenRoyaltyInfo memory royaltyInfo = offer.royaltyInfo;
    uint256 offerPriceWithRoyalty = params.price + royaltyInfo.royaltyAmount;

    // Release reserved balance
    reservedBalance -= offerPriceWithRoyalty;
    offer.accepted = true;

    // Calculate & Transfer platform fee
    (uint256 amount, ) = calculateFeeAndAmount(params.price);

    if (royaltyInfo.royaltyReceiver == msg.sender) {
      uint256 amountWithRoyalty = amount + royaltyInfo.royaltyAmount;
      loveToken.safeTransfer(msg.sender, amountWithRoyalty);
    } else {
      _transferRoyalty(royaltyInfo, address(this));
      loveToken.safeTransfer(msg.sender, amount);
    }

    // Transfer NFT to offerer
    _transferNFT(from, params.offerer, params.nft, offer.tokenType);

    emit AcceptedNFT(params.nft.addr, params.nft.tokenId, params.price, params.offerer, msg.sender);
    return amount;
  }

  /**
   * @notice Create auction for NFT
   * @dev This function allows users to create an auction for an NFT
   * @param params The auction parameters (nft, tokenId, initialPrice, minBidStep, startTime, endTime)
   */
  function createAuction(
    AuctionParams calldata params
  ) external notOnAuction(params.nft) minimumPrice(params.initialPrice) {
    TokenType tokenType = _getTokenType(params.nft.addr);
    // Verify if the caller is the owner of the NFT
    _verifyOwnershipAndApproval(msg.sender, params.nft, tokenType);

    require(loveToken.balanceOf(msg.sender) >= LISTING_FEE, 'no tokens for platform fee');
    // The caller must transfer the platform fee to the marketplace contract.
    loveToken.safeTransferFrom(msg.sender, address(this), LISTING_FEE);
    // Transfer the NFT from the caller to the contract
    _transferNFT(msg.sender, address(this), params.nft, tokenType);

    // Store the auction details in the auctionNfts mapping
    auctionNfts[encodeNft(params.nft)] = AuctionNFT({
      nft: params.nft,
      tokenType: tokenType,
      creator: msg.sender,
      initialPrice: params.initialPrice,
      minBidStep: params.minBidStep,
      startTime: params.startTime,
      endTime: params.endTime,
      lastBidder: address(0),
      highestBid: params.initialPrice,
      royaltyInfo: TokenRoyaltyInfo(address(0), 0),
      winner: address(0),
      success: false
    });

    emit CreatedAuction(
      params.nft.addr,
      params.nft.tokenId,
      params.initialPrice,
      params.minBidStep,
      params.startTime,
      params.endTime,
      msg.sender
    );
  }

  /**
   * @notice Cancel auction
   * @param nft NFT address
   */
  function cancelAuction(NFT calldata nft) external onAuction(nft) {
    bytes32 encodedNft = encodeNft(nft);
    AuctionNFT memory auction = auctionNfts[encodedNft];
    require(auction.creator == msg.sender, 'not auction creator');
    require(!auction.success, 'auction already success');
    require(auction.lastBidder == address(0), 'already have bidder');

    delete auctionNfts[encodedNft];

    _transferNFT(address(this), msg.sender, nft, auction.tokenType);

    emit CanceledAuction(nft.addr, nft.tokenId);
  }

  /**
   * @notice Place bid on auction
   * @param nft NFT address
   * @param bidPrice bid price (must be greater than highest bid + min bid step)
   * @return bidPriceWithRoyalty bid price with royalty
   */
  function bidPlace(NFT calldata nft, uint256 bidPrice) external onAuction(nft) nonReentrant returns (uint256) {
    AuctionNFT storage auction = auctionNfts[encodeNft(nft)];
    require(block.timestamp >= auction.startTime, 'auction not started');
    require(block.timestamp <= auction.endTime, 'auction ended');
    require(bidPrice >= auction.highestBid + auction.minBidStep, 'less than min bid price');

    TokenRoyaltyInfo memory royaltyInfo = _tryGetRoyaltyInfo(nft, bidPrice);
    uint256 lastBidPriceWithRoyalty = 0;
    uint256 bidPriceWithRoyalty = bidPrice + royaltyInfo.royaltyAmount;

    if (auction.lastBidder != address(0)) {
      address lastBidder = auction.lastBidder;
      uint256 lastBidPrice = auction.highestBid;
      // Transfer back to last bidder
      lastBidPriceWithRoyalty = lastBidPrice + auction.royaltyInfo.royaltyAmount;
      loveToken.safeTransfer(lastBidder, lastBidPriceWithRoyalty);
    }

    reservedBalance += bidPriceWithRoyalty - lastBidPriceWithRoyalty;
    // Set new highest bid price & bidder
    auction.lastBidder = msg.sender;
    auction.highestBid = bidPrice;
    auction.royaltyInfo = royaltyInfo;

    loveToken.safeTransferFrom(msg.sender, address(this), bidPriceWithRoyalty);

    emit PlacedBid(nft.addr, nft.tokenId, bidPrice, msg.sender);
    return bidPriceWithRoyalty;
  }

  /**
   * @notice Result auctions
   * @param nft NFT
   */
  function resultAuction(NFT calldata nft) external returns (uint256) {
    uint256 amount = _resultAuction(nft);
    reservedBalance -= amount;
    return amount;
  }

  /**
   * @notice Result multiple auctions
   * @param nfts NFT (nftAddres, tokenId)
   */
  function resultAuctions(NFT[] calldata nfts) external returns (uint256) {
    uint256 totalAmount = 0;

    for (uint256 i = 0; i < nfts.length; ++i) {
      // Result each auction and accumulate the amount transferred to the auction creator
      uint256 amount = _resultAuction(nfts[i]);
      totalAmount += amount;
    }
    reservedBalance -= totalAmount;
    return totalAmount;
  }

  /**
   * @notice Get auction info by NFT address and token id
   * @param nft NFT address
   * @return AuctionNFT struct
   */
  function getAuction(NFT calldata nft) external view returns (AuctionNFT memory) {
    return auctionNfts[encodeNft(nft)];
  }

  /**
   * @notice Transfer fee to fee receiver contract
   * @dev should set feeReceiver (updateFeeReceiver()) address before call this function
   * @param amount Fee amount
   */
  function transferFee(uint256 amount) external hasRole('admin') {
    require(feeReceiver != address(0), 'invalid feeReceiver address');
    require(getAvailableBalance() >= amount, 'insufficient balance (reserved)');
    loveToken.safeTransfer(feeReceiver, amount);
  }

  /**
   * @notice Set platform fee
   * @param newPlatformFee new platform fee
   */
  function setPlatformFee(uint256 newPlatformFee) external onlyOwner {
    platformFee = newPlatformFee;
    emit ChangedPlatformFee(newPlatformFee);
  }

  /**
   * @notice Set platform fee contract (LoveDrop)
   * @param newFeeReceiver new fee receiver address
   */
  function updateFeeReceiver(address newFeeReceiver) external onlyOwner {
    require(newFeeReceiver != address(0), 'invalid address');
    feeReceiver = newFeeReceiver;

    emit ChangedFeeReceiver(newFeeReceiver);
  }

  /**
   * @notice Calculate fee and amount
   * @param price price
   * @return amount amount transfer to seller
   * @return fee fee transfer to marketplace contract
   */
  function calculateFeeAndAmount(uint256 price) public view returns (uint256 amount, uint256 fee) {
    uint256 fee1e27 = (price * platformFee * 1e27) / 100;
    fee = fee1e27 / 1e27;
    if (fee < MINIMUM_BUYING_FEE) {
      fee = MINIMUM_BUYING_FEE;
    }
    return (price - fee, fee);
  }

  /**
   * @notice Get available balance
   * @return availableBalance available balance (not reserved)
   */
  function getAvailableBalance() public view returns (uint256 availableBalance) {
    return loveToken.balanceOf(address(this)) - reservedBalance;
  }

  function _resultAuction(NFT calldata nft) internal onAuction(nft) returns (uint256) {
    AuctionNFT storage auction = auctionNfts[encodeNft(nft)];
    require(!auction.success, 'already resulted');
    require(block.timestamp > auction.endTime, 'auction not ended');
    address creator = auction.creator;
    address winner = auction.lastBidder;
    uint256 highestBid = auction.highestBid;
    TokenType tokenType = auction.tokenType;
    if (winner == address(0)) {
      // If no one bid, transfer NFT back to creator
      delete auctionNfts[encodeNft(nft)];
      _transferNFT(address(this), creator, nft, tokenType);
      emit CanceledAuction(nft.addr, nft.tokenId);
      return 0;
    }

    auction.success = true;
    auction.winner = winner;
    TokenRoyaltyInfo memory royaltyInfo = auction.royaltyInfo;
    // Calculate royalty fee and transfer to recipient
    _transferRoyalty(royaltyInfo, address(this));

    // Calculate platform fee
    (uint256 amount, ) = calculateFeeAndAmount(highestBid);

    // Transfer to auction creator
    loveToken.safeTransfer(creator, amount);
    // Transfer NFT to the winner
    _transferNFT(address(this), winner, nft, auction.tokenType);

    emit ResultedAuction(nft.addr, nft.tokenId, creator, winner, highestBid, msg.sender);
    return highestBid + royaltyInfo.royaltyAmount;
  }

  function rescueTokens(NFT calldata nft, address receiver) external onlyOwner {
    bool isAuction = auctionNfts[encodeNft(nft)].creator != address(0);
    bool isListed = listNfts[encodeNft(nft)].seller != address(0);
    require(!isListed, 'nft is on sale');
    require(!isAuction, 'nft is on auction');
    TokenType tokenType = _getTokenType(nft.addr);
    _transferNFT(address(this), receiver, nft, tokenType);
  }

  function _tryGetRoyaltyInfo(
    NFT memory nft,
    uint256 price
  ) internal view returns (TokenRoyaltyInfo memory royaltyInfo) {
    if (IERC2981(nft.addr).supportsInterface(type(IERC2981).interfaceId)) {
      (address royaltyRecipient, uint256 amount) = IERC2981(nft.addr).royaltyInfo(nft.tokenId, price);
      if (amount > price / 5) amount = price / 5;
      royaltyInfo = TokenRoyaltyInfo(royaltyRecipient, amount);
    }
    return royaltyInfo;
  }

  function _transferRoyalty(TokenRoyaltyInfo memory royaltyInfo, address from) internal {
    if (royaltyInfo.royaltyReceiver != address(0) && royaltyInfo.royaltyAmount > 0) {
      if (from == address(this)) {
        loveToken.safeTransfer(royaltyInfo.royaltyReceiver, royaltyInfo.royaltyAmount);
      } else {
        loveToken.safeTransferFrom(from, royaltyInfo.royaltyReceiver, royaltyInfo.royaltyAmount);
      }
    }
  }

  function _getTokenType(address nftAddress) internal view returns (TokenType tokenType) {
    if (IERC165(nftAddress).supportsInterface(type(IERC1155).interfaceId)) {
      return TokenType.ERC1155;
    } else if (IERC165(nftAddress).supportsInterface(type(IERC721).interfaceId)) {
      return TokenType.ERC721;
    } else {
      revert('Invalid NFT type');
    }
  }

  function _verifyOwnershipAndApproval(address claimant, NFT memory nft, TokenType tokenType) internal view {
    bool isValid = false;
    if (tokenType == TokenType.ERC1155) {
      isValid =
        IERC1155(nft.addr).balanceOf(claimant, nft.tokenId) >= 1 &&
        IERC1155(nft.addr).isApprovedForAll(claimant, address(this));
    } else if (tokenType == TokenType.ERC721) {
      isValid =
        IERC721(nft.addr).ownerOf(nft.tokenId) == claimant &&
        (IERC721(nft.addr).getApproved(nft.tokenId) == address(this) ||
          IERC721(nft.addr).isApprovedForAll(claimant, address(this)));
    }
    require(isValid, 'not owner or approved tokens');
  }

  function _transferNFT(address from, address to, NFT calldata nft, TokenType tokenType) internal {
    if (tokenType == TokenType.ERC1155) {
      IERC1155(nft.addr).safeTransferFrom(from, to, nft.tokenId, 1, '');
    } else if (tokenType == TokenType.ERC721) {
      IERC721(nft.addr).transferFrom(from, to, nft.tokenId);
    }
  }

  function encodeNft(NFT calldata nft) internal pure returns (bytes32 encodedNft) {
    return keccak256(abi.encodePacked(nft.addr, nft.tokenId));
  }

  function onERC1155Received(
    address,
    address,
    uint256,
    uint256,
    bytes memory
  ) public virtual override returns (bytes4) {
    return this.onERC1155Received.selector;
  }
}
// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.18;

import {ILoveRoles} from './ILoveRoles.sol';
import {ILoveNFTShared} from './ILoveNFTShared.sol';

interface ILoveNFTMarketplace is ILoveRoles {
  enum TokenType {
    ERC721,
    ERC1155
  }

  struct NFT {
    address addr;
    uint256 tokenId;
  }

  struct ListingParams {
    NFT nft;
    uint256 price;
    uint256 startTime;
    uint256 endTime;
  }

  struct ListNFT {
    NFT nft;
    TokenType tokenType;
    address seller;
    uint256 price;
    uint256 startTime;
    uint256 endTime;
  }

  struct LazyListingParams {
    NFT nft;
    uint256 price;
    uint256 startTime;
    uint256 endTime;
    bytes32 uid;
  }

  struct OfferNFT {
    NFT nft;
    address offerer;
    uint256 offerPrice;
    TokenType tokenType;
    TokenRoyaltyInfo royaltyInfo;
    bool accepted;
  }

  struct OfferNFTParams {
    NFT nft;
    address offerer;
    uint256 price;
  }

  struct AuctionParams {
    NFT nft;
    uint256 initialPrice;
    uint256 minBidStep;
    uint256 startTime;
    uint256 endTime;
  }

  struct AuctionNFT {
    NFT nft;
    TokenType tokenType;
    address creator;
    uint256 initialPrice;
    uint256 minBidStep;
    uint256 startTime;
    uint256 endTime;
    address lastBidder;
    uint256 highestBid;
    TokenRoyaltyInfo royaltyInfo;
    address winner;
    bool success;
  }

  struct TokenRoyaltyInfo {
    address royaltyReceiver;
    uint256 royaltyAmount;
  }

  // events
  event ChangedPlatformFee(uint256 newValue);
  event ChangedFeeReceiver(address newFeeReceiver);

  event ListedNFT(
    address indexed nftAddress,
    uint256 indexed tokenId,
    uint256 price,
    address indexed seller,
    uint256 startTime,
    uint256 endTime
  );

  event CanceledListedNFT(
    address indexed nftAddress,
    uint256 indexed tokenId,
    uint256 price,
    address indexed seller,
    uint256 startTime,
    uint256 endTime
  );

  event BoughtNFT(
    address indexed nftAddress,
    uint256 indexed tokenId,
    uint256 price,
    address seller,
    address indexed buyer
  );
  event OfferedNFT(address indexed nftAddress, uint256 indexed tokenId, uint256 offerPrice, address indexed offerer);
  event CanceledOfferedNFT(
    address indexed nftAddress,
    uint256 indexed tokenId,
    uint256 offerPrice,
    address indexed offerer
  );
  event AcceptedNFT(
    address indexed nftAddress,
    uint256 indexed tokenId,
    uint256 offerPrice,
    address offerer,
    address indexed nftOwner
  );
  event CreatedAuction(
    address indexed nftAddress,
    uint256 indexed tokenId,
    uint256 price,
    uint256 minBidStep,
    uint256 startTime,
    uint256 endTime,
    address indexed creator
  );
  event PlacedBid(address indexed nftAddress, uint256 indexed tokenId, uint256 bidPrice, address indexed bidder);
  event CanceledAuction(address indexed nftAddress, uint256 indexed tokenId);

  event ResultedAuction(
    address indexed nftAddress,
    uint256 indexed tokenId,
    address creator,
    address indexed winner,
    uint256 price,
    address caller
  );

  function listNft(ListingParams calldata params) external returns (uint256);

  function getListedNFT(NFT calldata nft) external view returns (ListNFT memory);

  function cancelListedNFT(NFT calldata nft) external;

  function buyNFT(NFT calldata nft, uint256 price) external returns (uint256 priceWithRoyalty);

  function buyLazyListedNFT(
    ILoveNFTShared.MintRequest calldata params,
    bytes calldata signature
  ) external returns (uint256 priceWithRoyalty);

  function offerNFT(OfferNFTParams calldata params) external returns (uint256);

  function cancelOfferNFT(OfferNFTParams calldata params) external returns (uint256);

  function acceptOfferNFT(OfferNFTParams calldata params) external returns (uint256);

  function createAuction(AuctionParams calldata params) external;

  function cancelAuction(NFT calldata nft) external;

  function bidPlace(NFT calldata nft, uint256 bidPrice) external returns (uint256);

  function resultAuction(NFT calldata nft) external returns (uint256);

  function resultAuctions(NFT[] calldata nfts) external returns (uint256);

  function getAuction(NFT calldata nft) external view returns (AuctionNFT memory);

  function transferFee(uint256 amount) external;

  function setPlatformFee(uint256 newPlatformFee) external;

  function updateFeeReceiver(address newFeeReceiver) external;
}
// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.18;

import {IERC1155} from '@openzeppelin/contracts/token/ERC1155/IERC1155.sol';
import {IERC2981} from '@openzeppelin/contracts/interfaces/IERC2981.sol';
import {IERC1155MetadataURI} from '@openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol';

interface ILoveNFTShared is IERC1155, IERC1155MetadataURI, IERC2981 {
  struct MintRequest {
    uint256 tokenId;
    uint256 price;
    uint128 startTimestamp;
    uint128 endTimestamp;
    string uri;
    address royaltyRecipient;
    uint96 royaltyFraction;
    bytes32 uid;
  }

  function redeem(address account, MintRequest calldata _req, bytes calldata signature) external;

  function exists(uint256 tokenId) external view returns (bool);

  function feeDenominator() external pure returns (uint96);

  function decodeTokenId(uint256 tokenId) external pure returns (address, uint256, uint256);

  function encodeTokenId(address creator, uint256 index, uint256 collection) external pure returns (uint256);
}
// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.18;

interface ILoveRoles {
  function grantRole(address account, string calldata role) external;

  function revokeRole(address account, string calldata role) external;

  function checkRole(address accountToCheck, string calldata role) external view returns (bool);
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {Ownable} from '@openzeppelin/contracts/access/Ownable.sol';
import {ILoveRoles} from '../interfaces/ILoveRoles.sol';

abstract contract LoveRoles is ILoveRoles, Ownable {
  mapping(address user => mapping(string role => bool hasRole)) private users;

  event RoleGranted(address indexed account, string role);
  event RoleRevoked(address indexed account, string role);

  modifier hasRole(string memory role) {
    require(users[msg.sender][role] || msg.sender == owner(), 'account doesnt have this role');
    _;
  }

  function grantRole(address account, string calldata role) external onlyOwner {
    require(!users[account][role], 'role already granted');
    users[account][role] = true;

    emit RoleGranted(account, role);
  }

  function revokeRole(address account, string calldata role) external onlyOwner {
    require(users[account][role], 'role already revoked');
    users[account][role] = false;

    emit RoleRevoked(account, role);
  }

  function checkRole(address accountToCheck, string calldata role) external view returns (bool) {
    return users[accountToCheck][role];
  }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import {Strings} from '@openzeppelin/contracts/utils/Strings.sol';

/*
    DESIGN NOTES:
    Token ids are a concatenation of:
   * creator: hex address of the creator of the token. 160 bits
   * index: Index for this token (the regular ID), up to 2^56 - 1. 56 bits
   * collection: Virtual collection id for this token, up to 2^40 - 1 (1 trillion).  40 bits

  */
/**
 * @title TokenIdentifiers
 * support for authentication and metadata for token ids
 */

library TokenIdentifiers {
  uint56 private constant MAX_INDEX = 0xFFFFFFFFFFFFFF;
  uint40 private constant MAX_COLLECTION = 0xFFFFFFFFFF;

  // Function to create a token ID based on creator, index, and supply
  function createTokenId(address creator, uint256 index, uint256 collection) internal pure returns (uint256) {
    // Concatenate the values into a single uint256 token ID
    uint256 tokenID = (uint256(uint160(creator)) << 96) | (uint256(index) << 40) | uint256(collection);
    return tokenID;
  }

  function tokenCreator(uint256 _id) internal pure returns (address) {
    return address(uint160(_id >> 96));
  }

  function tokenIndex(uint256 _id) internal pure returns (uint56) {
    return uint56((_id >> 40) & MAX_INDEX);
  }

  function tokenCollection(uint256 _id) internal pure returns (uint40) {
    return uint40(_id & MAX_COLLECTION);
  }

  // Function to extract creator, index, and supply from a token ID
  function decodeTokenId(uint256 _id) internal pure returns (address creator, uint56 index, uint40 collection) {
    creator = tokenCreator(_id);
    index = tokenIndex(_id);
    collection = tokenCollection(_id);
  }
}