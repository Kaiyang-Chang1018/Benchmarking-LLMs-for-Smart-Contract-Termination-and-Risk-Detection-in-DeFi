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
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable2Step.sol)

pragma solidity ^0.8.20;

import {Ownable} from "./Ownable.sol";

/**
 * @dev Contract module which provides access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is specified at deployment time in the constructor for `Ownable`. This
 * can later be changed with {transferOwnership} and {acceptOwnership}.
 *
 * This module is used through inheritance. It will make available all functions
 * from parent (Ownable).
 */
abstract contract Ownable2Step is Ownable {
    address private _pendingOwner;

    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Returns the address of the pending owner.
     */
    function pendingOwner() public view virtual returns (address) {
        return _pendingOwner;
    }

    /**
     * @dev Starts the ownership transfer of the contract to a new account. Replaces the pending transfer if there is one.
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual override onlyOwner {
        _pendingOwner = newOwner;
        emit OwnershipTransferStarted(owner(), newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`) and deletes any pending owner.
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual override {
        delete _pendingOwner;
        super._transferOwnership(newOwner);
    }

    /**
     * @dev The new owner accepts the ownership transfer.
     */
    function acceptOwnership() public virtual {
        address sender = _msgSender();
        if (pendingOwner() != sender) {
            revert OwnableUnauthorizedAccount(sender);
        }
        _transferOwnership(sender);
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
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Permit.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
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
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../IERC20.sol";
import {IERC20Permit} from "../extensions/IERC20Permit.sol";
import {Address} from "../../../utils/Address.sol";

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
     * @dev An operation with an ERC20 token failed.
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
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data);
        if (returndata.length != 0 && !abi.decode(returndata, (bool))) {
            revert SafeERC20FailedOperation(address(token));
        }
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
        return success && (returndata.length == 0 || abi.decode(returndata, (bool))) && address(token).code.length > 0;
    }
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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Address.sol)

pragma solidity ^0.8.20;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev The ETH balance of the account is not enough to perform the operation.
     */
    error AddressInsufficientBalance(address account);

    /**
     * @dev There's no code at `target` (it is not a contract).
     */
    error AddressEmptyCode(address target);

    /**
     * @dev A call to an address target failed. The target may have reverted.
     */
    error FailedInnerCall();

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
            revert AddressInsufficientBalance(address(this));
        }

        (bool success, ) = recipient.call{value: amount}("");
        if (!success) {
            revert FailedInnerCall();
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
     * {FailedInnerCall} error.
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
            revert AddressInsufficientBalance(address(this));
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
     * was not a contract or bubbling up the revert reason (falling back to {FailedInnerCall}) in case of an
     * unsuccessful call.
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
     * revert reason or with a default {FailedInnerCall} error.
     */
    function verifyCallResult(bool success, bytes memory returndata) internal pure returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            return returndata;
        }
    }

    /**
     * @dev Reverts with returndata if present. Otherwise reverts with {FailedInnerCall}.
     */
    function _revert(bytes memory returndata) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert FailedInnerCall();
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
pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";

// Use the SafeERC20 for IERC20 tokens
using SafeERC20 for IERC20;

contract AlkimiV2 is ERC721, Ownable2Step, ReentrancyGuard {
  using Address for address;

  // ------------ Variables {{{
  uint8     private constant TOTAL_ADMINS = 2;
  uint32    public  validatorVersionCount;
  uint256   private _totalMinted;
  address   private _treasuryWallet; // Address of the treasury wallet
  address[] private _admins; // Array to store admin addresses
  uint256   private maxReclaimFee = 0.01 ether; // Max reclaim fee is 0.01 ether
  uint256   public  reclaimFee = 0.005 ether; // Initial reclaim fee

  // Validator status enum
  enum ValidatorStatus {Invalid, Inactive, Active}
  // Request approval status
  enum RequestStatus { Invalid, Pending, Approved, Rejected }

  struct ValidatorVersion {
    string          version;
    address         underlying;
    uint256         collateral;
    uint256         ts;
    uint256         minted;
    string          activeURI;
    string          inactiveURI;
  }

  struct UserRequest {
    address       user;
    RequestStatus status;
    string        reason; // rejection reason
  }

  mapping(uint256 tokenId => ValidatorStatus validatorStatus) public nftValidatorStatus;
  mapping(uint256 valVerIdx => ValidatorVersion validatorVer) public validatorVersions;
  mapping(uint256 tokenId => string tokenUri) private _tokenURIs; // Mapping to store individual NFT URIs
  mapping(address adminAddr => bool flag) private _isAdmin;
  mapping(uint256 tokenId => bool flag) public reclaimable; // Mapping to store reclaimable flag for NFTs
  mapping(uint256 tokenId => uint256 valVerIdx ) public nftToValidatorVersion; // tokenId -> Validatorversion
  mapping(uint256 tokenId => UserRequest stReq) public approvalRequests;
  mapping(uint256 tokenId => UserRequest stReq) public reclaimRequests; // Mapping between tokenId and struct

  // ------------ Variables }}}

  // ------------ Errors {{{
  /**
   * @notice Error emitted when a token ID does not exist.
   * @param tokenId The ID of the token that does not exist.
   */
  error TokenIDDoesNotExist(uint256 tokenId);
  /**
   * @notice Error emitted when an address is unauthorized.
   * @param sender The address that attempted the unauthorized action.
   */
  error UnauthorizedAdmin(address sender);
  /**
   * @notice Error emitted when an incorrect validator version index is used.
   * @param validatorVerIdx The invalid validator version index.
   */
  error WrongValidatorVersionIndex(uint256 validatorVerIdx);
  /**
   * @notice Error emitted when the caller is not the owner of the specified NFT.
   * @param sender The address attempting the operation.
   * @param tokenId The ID of the NFT being accessed.
   */
  error NotNFTOwner(address sender, uint256 tokenId);
  /// @notice Error emitted when a request to create a validator node fails.
  error validatorNodeRequestFailed();
  /**
   * @notice Error emitted when an invalid address is used.
   * @param addr The address that was invalid.
   */
  error InvalidAddress(address addr);
  /// @notice Error emitted when the maximum number of admins has been reached.
  error MaxAdminsReached();
  /**
   * @notice Error emitted when an address is already registered as an admin.
   * @param admin The address that is already an admin.
   */
  error AdminAlreadyAdded(address admin);
  /**
   * @notice Error emitted when the specified address is not an admin.
   * @param admin The address that attempted an admin-only operation.
   */
  error NotAnAdmin(address admin);
  /**
   * @notice Error emitted when the new fee specified exceeds the maximum allowable reclaim fee.
   * @param attemptedFee The fee that was attempted to be set.
   * @param maxFee The maximum allowable fee.
   */
  error FeeExceedsMaximum(uint256 attemptedFee, uint256 maxFee);
  /**
   * @notice Error emitted when the new total supply is set to less than the number already minted.
   * @param attemptedTotalSupply The new total supply attempted to be set.
   * @param minted The number of items already minted.
   */
  error TotalSupplyLessThanMinted(uint256 attemptedTotalSupply, uint256 minted);
  /**
   * @notice Error emitted when a specified version ID is invalid because it exceeds the number of validator versions.
   * @param versionId The invalid version ID provided.
   * @param maxValidId The maximum valid version ID, based on the count of validator versions.
   */
  error InvalidVersionMapping(uint256 versionId, uint256 maxValidId);
  /**
   * @notice Error emitted when the attempted minting exceeds the total supply for the validator version.
   * @param validatorVerIdx The index of the validator version being accessed.
   * @param attemptedMint The total number of NFTs attempted to be minted.
   * @param totalSupply The total supply available for that validator version.
   */
  error MintingExceedsTotalSupply(uint256 validatorVerIdx, uint256 attemptedMint, uint256 totalSupply);
  /// @notice Error emitted when an operation is attempted on an NFT with an invalid validator status.
  error InvalidValidatorStatus();
  /**
   * @notice Error emitted when minting of NFTs fails.
   * @param validatorVerIdx Index of the validator version used for minting.
   * @param user The address of the user attempting the mint.
   * @param noOfNFTs The number of NFTs attempted to be minted.
   * @param uri The intended URI for the NFTs being minted.
   * @param status The intended status of the NFTs being minted.
   */
  error MintingFailed(uint256 validatorVerIdx, address user, uint256 noOfNFTs, string uri, ValidatorStatus status);
  /**
   * @notice Error emitted when the allowance for the contract to spend tokens on behalf of the sender is insufficient.
   * @param sender The address of the token holder.
   * @param spender The contract attempting to spend the tokens.
   * @param requiredCollateral The amount of collateral required but not permitted by allowance.
   * @param currentAllowance The current allowance amount that is insufficient.
   */
  error InsufficientAllowance(address sender, address spender, uint256 requiredCollateral, uint256 currentAllowance);
  /**
   * @notice Error emitted when the request status is not as expected.
   * @param tokenId The ID of the token for which the request status is incorrect.
   * @param currentStatus The current status of the request.
   * @param expectedStatus The expected status that was not met.
   */
  error IncorrectRequestStatus(uint256 tokenId, RequestStatus currentStatus, RequestStatus expectedStatus);
  /**
   * @notice Error emitted when an operation is attempted on a token that is not reclaimable.
   * @param tokenId The ID of the token which is not reclaimable.
   */
  error NotReclaimable(uint256 tokenId);
  /**
   * @notice Error emitted when the amount of ether sent does not match the required reclaim fee.
   * @param sentAmount The amount of ether sent.
   * @param requiredAmount The reclaim fee required.
   */
  error IncorrectReclaimFeeSent(uint256 sentAmount, uint256 requiredAmount);
  /**
   * @notice Error emitted when the transfer of Ether fails.
   * @param to The recipient address of the Ether.
   * @param amount The amount of Ether attempted to be transferred.
   */
  error EtherTransferFailed(address to, uint256 amount);
  /**
   * @notice Error emitted when the function argument is Invalid.
   * @param parameter Name of the parameter that is Invalid
   */
  error InvalidArg(string parameter);

  // ------------ Errors }}}

  // ------------ Modifiers {{{

  // Modifier to check if a token ID exists
  modifier tokenIDExists(uint256 tokenId) {
    if (!_tokenExists(tokenId)) {
      revert TokenIDDoesNotExist(tokenId);
    }
    _;
  }
  modifier onlyAdmin() {
    if (!_isAdmin[_msgSender()] && owner() != _msgSender()) {
      revert UnauthorizedAdmin(_msgSender());
    }
    _;
  }

  // ------------ Modifiers }}}

  // ------------ EVENTS {{{
  event AdminAdded(address indexed admin);
  event AdminRemoved(address indexed admin);
  event NFTMinted(address indexed minter, uint256 indexed tokenId, uint256 indexed validatorVerIdx);
  event NFTBurned(address indexed burner, uint256 indexed tokenId);
  event TreasuryWalletSet(address indexed newTreasuryWallet);
  event ValidatorVersionAdded(address indexed caller, string version, uint256 indexed validatorVerIdx, address underlying, uint256 collateral, uint256 ts);
  event ValidatorTSUpdated(address indexed caller, uint256 indexed validatorVerIdx, uint256 newTs);
  event ValidatorURIUpdated(address indexed updater, uint256 indexed validatorVerIdx, string activeURI, string inactiveURI);
  event ValidatorNodeRequested(address indexed caller, uint256 indexed tokenId, uint256 validatorVerIdx);
  event ValidatorNodeApproved(address admin, uint256 indexed tokenId, address indexed user, uint256 validatorVerIdx);
  event ValidatorNodeRejected(address admin, uint256 indexed tokenId, address indexed user, uint256 validatorVerIdx);
  event ValidatorNodeRejectedReclaimCompleted(address indexed user, uint256 tokenId);
  event ReclaimRequested(address indexed caller, uint256 tokenId, uint256 validatorVerIdx);
  event ReclaimApproved(address indexed admin, uint256 tokenId, uint256 validatorVerIdx);
  event ReclaimRejected(address indexed admin, uint256 tokenId, uint256 validatorVerIdx);
  event ReclaimCompleted(address indexed user, uint256 tokenId);
  event ReclaimFeeUpdated(address indexed admin, uint256 newFee);
  event NFTStatusChanged(address indexed user, uint256 indexed tokenId, ValidatorStatus status);
  // ------------ EVENTS }}}

  constructor() ERC721("AlkimiValidatorNetwork", "AVN") Ownable(_msgSender()){}

  /**
   * @notice Returns the total number of NFTs that have been minted.
   * @dev This function returns the value of `_totalMinted`, which represents the total supply of minted NFTs.
   * The `_totalMinted` variable is updated every time a new NFT is minted.
   * @return totalMinted The total number of minted NFTs.
   */
  function totalSupply() public view returns (uint256) {
    return _totalMinted;
  }

  /**
   * @notice Checks if a token exists by verifying its ownership.
   * @dev This internal function checks whether a given token ID is associated with an owner.
   * It determines if the token exists by checking if the token is owned by a non-zero address.
   * @param tokenId The ID of the token to check for existence.
   * @return exists True if the token exists (i.e., is owned by a non-zero address), otherwise false.
   */
  function _tokenExists(uint256 tokenId) internal view returns (bool) {
    return ownerOf(tokenId) != address(0);
  }

  /**
   * @notice Adds a new admin to the contract.
   * @dev This function allows the contract owner to add a new admin address. The number of admins is limited by `TOTAL_ADMINS`, and the new admin 
   *      cannot be the current owner, an already added admin, or the zero address.
   * @param admin The address of the new admin to be added.
   * 
   * Requirements:
   * - The caller must be the contract owner.
   * - The new admin address must not be the contract owner.
   * - The new admin address must not already be listed as an admin.
   * - The new admin address must not be the zero address.
   * - The total number of admins must be less than `TOTAL_ADMINS`.
   * 
   * Emits:
   * - {AdminAdded} event indicating the addition of a new admin.
   * 
   * Reverts:
   * - {MaxAdminsReached} if the number of admins has reached the maximum limit.
   * - {AdminAlreadyAdded} if the admin address is already listed.
   * - {InvalidAddress} if the provided address is zero or is the owner.
   */
  function addAdmin(address admin) external onlyOwner {
    if (admin == address(0) || admin == owner()) {
      revert InvalidAddress(admin);
    }

    if (_isAdmin[admin]) {
      revert AdminAlreadyAdded(admin);
    }

    if (_admins.length >= TOTAL_ADMINS) {
      revert MaxAdminsReached();
    }

    _admins.push(admin); // Add admin address to the admins array
    _isAdmin[admin] = true;
    emit AdminAdded(admin);
  }

  /**
   * @notice Removes an existing admin from the contract.
   * @dev This function allows the contract owner to remove an existing admin address. The removed admin is replaced by the last element in the array, and then the last element is removed to maintain array order.
   * @param admin The address of the admin to be removed.
   * 
   * Requirements:
   * - The caller must be the contract owner.
   * - The address to be removed must be an existing admin.
   * 
   * Emits:
   * - {AdminRemoved} event indicating the removal of an admin.
   * 
   * Reverts:
   * - {NotAnAdmin} if the provided address is not listed as an admin.
   */
  function removeAdmin(address admin) external onlyOwner {
    if (!_isAdmin[admin]) {
      revert NotAnAdmin(admin);
    }
    uint256 index = (_admins[0] == admin) ? 0 : 1;
    _admins[index] = _admins[_admins.length - 1]; // Replace removed admin with the last element
    _admins.pop(); // Remove the last element (replaced element)
    _isAdmin[admin] = false;
    emit AdminRemoved(admin);
  }

  /**
   * @notice Returns the list of current admin addresses.
   * @dev This function returns the array of admin addresses currently managed by the contract.
   * @return admins An array of addresses representing the current admins.
   * 
   * Requirements:
   * - The caller must be the contract owner.
   */

  function getAdmins() external view onlyOwner returns (address[] memory) {
    return _admins; // Simply return the admins array
  }

  /**
   * @notice Sets the reclaim fee amount in Wei.
   * @dev This function allows an admin to update the reclaim fee. The fee is provided in Wei (1 Ether = 10^18 Wei).
   * @param newFeeInWei The new fee amount to be set, specified in Wei.
   * 
   * Requirements:
   * - The caller must be an admin.
   * - The new fee must not exceed the `maxReclaimFee`.
   * 
   * Emits:
   * - {ReclaimFeeUpdated} event indicating the fee update with the new fee in Wei.
   * 
   * Reverts:
   * - {FeeExceedsMaximum} if the new fee exceeds the maximum allowed `maxReclaimFee`.
   */
  function setReclaimFee(uint256 newFeeInWei) external onlyAdmin {
    // Ensure the new fee does not exceed the maxReclaimFee
    if (newFeeInWei > maxReclaimFee) {
      revert FeeExceedsMaximum(newFeeInWei, maxReclaimFee);
    }
    // Update the reclaim fee
    reclaimFee = newFeeInWei;
    
    // Emit the event with the new fee in wei
    emit ReclaimFeeUpdated(_msgSender(), newFeeInWei);
  }

  /**
   * @notice Adds a new validator version with specified parameters.
   * @dev This function allows the admin to create and add a new validator version to the contract. The new version is initialized with a version string, underlying token address, collateral amount, total supply, and URIs for both active and inactive states.
   * @param version The version string for the new validator.
   * @param underlying The address of the underlying token used for collateral.
   * @param collateral The amount of collateral required for the validator, in the underlying token's smallest unit (e.g., Wei for Ether-based tokens).
   * @param ts The total supply of the validator version.
   * @param activeURI The URI to be used for the active state of NFTs.
   * @param inactiveURI The URI to be used for the inactive state of NFTs.
   * 
   * Requirements:
   * - The caller must be an admin.
   * - The `version` string must not be empty.
   * - The `underlying` token address must not be the zero address.
   * - The `collateral` must be greater than zero.
   * - The total supply (`ts`) must be greater than zero.
   * - The `activeURI` and `inactiveURI` must not be empty.
   * 
   * Emits:
   * - {ValidatorVersionAdded} event indicating the addition of a new validator version.
   * 
   * Reverts:
   * - {InvalidAddress} if the `underlying` address is the zero address.
   * - {InvalidArg} if the arguments to the functions is Invalid.
   */
  function addValidatorVersion(
      string calldata   version,
      address           underlying,
      uint256           collateral,
      uint256           ts,
      string calldata   activeURI,
      string calldata   inactiveURI
  ) external onlyAdmin {
    if (bytes(version).length == 0) {
      revert InvalidArg("version");
    }
    if (underlying == address(0)) {
      revert InvalidAddress(underlying);
    }
    if (collateral == 0) {
      revert InvalidArg("collateral");
    }
    if (ts == 0) {
      revert InvalidArg("ts");
    }
    if (bytes(activeURI).length == 0) {
      revert InvalidArg("activeURI");
    }
    if (bytes(inactiveURI).length == 0) {
      revert InvalidArg("inactiveURI");
    }

    validatorVersions[validatorVersionCount].version = version;
    validatorVersions[validatorVersionCount].underlying = underlying;
    validatorVersions[validatorVersionCount].collateral = collateral;
    validatorVersions[validatorVersionCount].ts = ts;
    validatorVersions[validatorVersionCount].minted = 0;
    validatorVersions[validatorVersionCount].activeURI = activeURI;
    validatorVersions[validatorVersionCount].inactiveURI = inactiveURI;
    emit ValidatorVersionAdded(_msgSender(), version, validatorVersionCount, underlying, collateral, ts);
    validatorVersionCount += 1;
  }

  /**
   * @notice Updates the total supply (TS) for an existing validator version.
   * @dev This function allows an admin to modify the total supply for a specific validator version. It ensures that the new total supply is not less than the number of NFTs that have already been minted for that version.
   * @param validatorVerIdx The index of the validator version to update.
   * @param newTs The new total supply for the validator version.
   * 
   * Requirements:
   * - The caller must be an admin.
   * - The validator version index must be valid.
   * - The new total supply must be greater than or equal to the number of minted NFTs.
   * 
   * Emits:
   * - {ValidatorTSUpdated} event indicating that the total supply was updated.
   * 
   * Reverts:
   * - {WrongValidatorVersionIndex} if the validator version index is invalid.
   * - {TotalSupplyLessThanMinted} if the new total supply is less than the number of minted NFTs.
   */
  function updateTotalSupplyForValidatorVersion(uint256 validatorVerIdx, uint256 newTs) external onlyAdmin {
    if (validatorVerIdx >= validatorVersionCount) {
      revert WrongValidatorVersionIndex(validatorVerIdx);
    }

    if (validatorVersions[validatorVerIdx].minted > newTs) {
      revert TotalSupplyLessThanMinted(newTs, validatorVersions[validatorVerIdx].minted);
    }

    // NOTE: ONLY TS and URI can be changed. For others, Admin should create a new validator version
    validatorVersions[validatorVerIdx].ts = newTs;
    emit ValidatorTSUpdated(_msgSender(), validatorVerIdx, newTs);
  }

  /**
   * @notice Updates the URIs for an existing validator version.
   * @dev This function allows the admin to update the URIs for both the active and inactive states of a validator version. Only the URIs and total supply (TS) can be updated using this function; any other changes require creating a new validator version.
   * @param validatorVerIdx The index of the validator version to update.
   * @param activeURI The new URI for the active state.
   * @param inactiveURI The new URI for the inactive state.
   * 
   * Requirements:
   * - The caller must be an admin.
   * - The validator version index (`validatorVerIdx`) must be valid.
   * - The `activeURI` and `inactiveURI` must not be empty.
   * 
   * Emits:
   * - {ValidatorURIUpdated} event indicating that the URIs were updated for the specified validator version.
   * 
   * Reverts:
   * - {WrongValidatorVersionIndex} if the validator version index is invalid.
   * - {InvalidArg} if the `activeURI` or `inactiveURI` is empty.
   */
  function updateURIValidatorVersion(uint256 validatorVerIdx, string calldata activeURI, string calldata inactiveURI) external onlyAdmin {
    if (validatorVerIdx >= validatorVersionCount) {
      revert WrongValidatorVersionIndex(validatorVerIdx);
    }
    if (bytes(activeURI).length == 0) {
      revert InvalidArg("activeURI");
    }
    if (bytes(inactiveURI).length == 0) {
      revert InvalidArg("inactiveURI");
    }

    // NOTE: ONLY TS and URI can be changed. For others, Admin should create a new validator version
    validatorVersions[validatorVerIdx].activeURI = activeURI;
    validatorVersions[validatorVerIdx].inactiveURI = inactiveURI;
    emit ValidatorURIUpdated(_msgSender(), validatorVerIdx, activeURI, inactiveURI);
  }

  /**
   * @notice Retrieves all validator versions in the contract.
   * @dev This function returns an array containing all validator versions, allowing users to view the details of each version stored in the contract.
   * @return versions An array of `ValidatorVersion` structs representing all the validator versions.
   * 
   * Requirements:
   * - None.
   * 
   * Emits:
   * - None.
   * 
   * Reverts:
   * - None.
   */
  function getAllValidatorVersions() external view returns (ValidatorVersion[] memory) {
    ValidatorVersion[] memory versions = new ValidatorVersion[](validatorVersionCount);
    for (uint256 i = 0; i < validatorVersionCount; i++) {
      versions[i] = validatorVersions[i];
    }
    return versions;
  }

  /**
   * @notice Retrieves the validator version details associated with a specific NFT.
   * @dev This function allows users to get the details of the validator version linked to a given NFT. It checks that the token ID is valid and that the NFT is associated with a valid validator version.
   * @param tokenId The ID of the NFT whose validator version details are being queried.
   * @return validatorVersion The `ValidatorVersion` struct associated with the NFT.
   * 
   * Requirements:
   * - The token ID must exist.
   * - The validator version index associated with the NFT must be valid.
   * 
   * Emits:
   * - None.
   * 
   * Reverts:
   * - {InvalidVersionMapping} if the validator version index associated with the token ID is invalid.
   */
  // NOTE : No set provided for nftToValidatorVersion. A NFT minted cannot be changed to a new validator version
  function getValidatorVersionDetailsForNFT(uint256 tokenId) external view tokenIDExists(tokenId) returns (ValidatorVersion memory) {
    uint256 versionId = nftToValidatorVersion[tokenId];

    if (versionId >= validatorVersionCount) {
      revert InvalidVersionMapping(versionId, validatorVersionCount - 1);
    }

    return validatorVersions[versionId];
  }

  /**
   * @notice Sets the status of multiple NFTs to Active and updates their token URIs.
   * @dev This function allows the admin to mark multiple NFTs as active. It updates the status of each NFT to `Active` and sets the token URI to the active URI specified for the validator version associated with each NFT.
   * @param tokenIds An array of NFT IDs whose validator statuses are being set to active.
   * 
   * Requirements:
   * - The caller must be an admin.
   * - The array of token IDs must not be empty.
   * - Each NFT must exist in the contract.
   * 
   * Emits:
   * - {NFTStatusChanged} event for each NFT whose status is updated.
   * 
   * Reverts:
   * - {InvalidArg} if the array of token IDs is empty.
   * - {TokenIDDoesNotExist} if any token ID does not exist in the contract.
   */
  function setNFTValidatorStatusesActive(uint256[] calldata tokenIds) external onlyAdmin {
    if (tokenIds.length == 0) {
      revert InvalidArg("tokenIds");
    }

    for (uint256 i = 0; i < tokenIds.length; i++) {
      uint256 tokenId = tokenIds[i];

      // Ensure the token ID exists
      if (!_tokenExists(tokenId)) {
        revert TokenIDDoesNotExist(tokenId);
      }

      // Set the NFT validator status to Active
      nftValidatorStatus[tokenId] = ValidatorStatus.Active;

      // Set the token URI to the active URI of the corresponding validator version
      _tokenURIs[tokenId] = validatorVersions[nftToValidatorVersion[tokenId]].activeURI;
      emit NFTStatusChanged(ownerOf(tokenId), tokenId, ValidatorStatus.Active);
    }
  }

  /**
   * @notice Sets the status of multiple NFTs to Inactive and updates their token URIs.
   * @dev This function allows the admin to mark multiple NFTs as inactive. It updates the status of each NFT to `Inactive` and sets the token URI to the inactive URI specified for the validator version associated with each NFT.
   * @param tokenIds An array of NFT IDs whose validator statuses are being set to inactive.
   * 
   * Requirements:
   * - The caller must be an admin.
   * - The array of token IDs must not be empty.
   * - Each NFT must exist in the contract.
   * 
   * Emits:
   * - {NFTStatusChanged} event for each NFT whose status is updated.
   * 
   * Reverts:
   * - {InvalidArg} if the array of token IDs is empty.
   * - {TokenIDDoesNotExist} if any token ID does not exist.
   */
  function setNFTValidatorStatusesInactive(uint256[] calldata tokenIds) external onlyAdmin {
    if (tokenIds.length == 0) {
      revert InvalidArg("tokenIds");
    }

    for (uint256 i = 0; i < tokenIds.length; i++) {
      uint256 tokenId = tokenIds[i];

      // Ensure the token ID exists
      if (!_tokenExists(tokenId)) {
        revert TokenIDDoesNotExist(tokenId);
      }

      // Set the NFT validator status to Inactive
      nftValidatorStatus[tokenId] = ValidatorStatus.Inactive;

      // Set the token URI to the inactive URI of the corresponding validator version
      _tokenURIs[tokenId] = validatorVersions[nftToValidatorVersion[tokenId]].inactiveURI;
      emit NFTStatusChanged(ownerOf(tokenId), tokenId, ValidatorStatus.Inactive);
    }
  }

  /**
   * @notice Sets the status of an NFT validator to Inactive and updates the token URI.
   * @dev This function allows the owner of an NFT to mark it as inactive. It updates the NFT's validator status to `Inactive` and sets the token URI to the inactive URI specified for the validator version associated with the NFT.
   * @param tokenId The ID of the NFT whose validator status is being set to inactive.
   * 
   * Requirements:
   * - The caller must be the owner of the NFT.
   * - The NFT must exist in the contract.
   * 
   * Emits:
   * - {NFTStatusChanged} event indicating the NFT's status was updated to inactive.
   * - {ValidatorNodeRequested} event indicating the NFT has been set to inactive and must go through the approval process again.
   * 
   * Reverts:
   * - {NotNFTOwner} if the caller is not the owner of the NFT.
   * - {TokenIDDoesNotExist} if the token ID does not exist in the contract.
   */
  function setNFTValidatorStatusInactive(uint256 tokenId) external {
    // caller must be the owner
    if (ownerOf(tokenId) != _msgSender()) {
      revert NotNFTOwner(_msgSender(), tokenId);
    }

    // Ensure the token ID exists
    if (!_tokenExists(tokenId)) {
      revert TokenIDDoesNotExist(tokenId);
    }

    // Set the NFT validator status to Inactive
    nftValidatorStatus[tokenId] = ValidatorStatus.Inactive;
    // Set the token URI to the inactive URI of the corresponding validator version
    _tokenURIs[tokenId] = validatorVersions[nftToValidatorVersion[tokenId]].inactiveURI;

    // add the user to the approval list... he has to go through the approval process again  
    approvalRequests[tokenId].user = _msgSender();
    approvalRequests[tokenId].status = RequestStatus.Pending;
    approvalRequests[tokenId].reason = "";
    emit NFTStatusChanged(_msgSender(), tokenId, ValidatorStatus.Inactive);
    emit ValidatorNodeRequested(_msgSender(), tokenId, nftToValidatorVersion[tokenId]);
  }

  /**
   * @notice Admin function to mint a specified number of NFTs for a user.
   * @dev This function allows an admin to mint NFTs for a specific user from a particular validator version. It ensures that the total number of minted NFTs does not exceed the total supply for the validator version.
   * @param validatorVerIdx The index of the validator version from which the NFTs are to be minted.
   * @param user The address of the user receiving the NFTs.
   * @param noOfNFTs The number of NFTs to mint for the user.
   * @param uri The URI for the metadata associated with the minted NFTs.
   * @param status The status of the validator for the minted NFTs.
   * 
   * Requirements:
   * - The caller must be an admin.
   * - The `validatorVerIdx` must be a valid index.
   * - The `uri` must not be empty.
   * - The `noOfNFTs` must be greater than zero.
   * - The `user` must not be the zero address.
   * - The `status` must not be `Invalid`.
   * 
   * Emits:
   * - None.
   * 
   * Reverts:
   * - {WrongValidatorVersionIndex} if the validator version index is invalid.
   * - {InvalidArg} if the `uri` or `noOfNFTs` is invalid.
   * - {InvalidAddress} if the `user` is the zero address.
   * - {InvalidValidatorStatus} if the validator status is `Invalid`.
   * - {MintingExceedsTotalSupply} if minting the requested number of NFTs exceeds the total supply for the validator version.
   * - {MintingFailed} if the minting operation fails.
   */
  function adminMint(uint256 validatorVerIdx, address user, uint256 noOfNFTs, string calldata uri, ValidatorStatus status) external nonReentrant onlyAdmin {
    if (validatorVerIdx >= validatorVersionCount) {
      revert WrongValidatorVersionIndex(validatorVerIdx);
    }
    if (bytes(uri).length == 0) {
      revert InvalidArg("uri");
    }
    if (noOfNFTs == 0) {
      revert InvalidArg("noOfNFTs");
    }
    if (user == address(0)) {
      revert InvalidAddress(user);
    }
    if (status == ValidatorStatus.Invalid) {
      revert InvalidValidatorStatus();
    }

    uint256 totalMintReq = validatorVersions[validatorVerIdx].minted + noOfNFTs;
    if (totalMintReq > validatorVersions[validatorVerIdx].ts) {
      revert MintingExceedsTotalSupply(validatorVerIdx, totalMintReq, validatorVersions[validatorVerIdx].ts);
    }

    bool success = _internalMint(validatorVerIdx, user, noOfNFTs, uri, status);
    if (!success) {
      revert MintingFailed(validatorVerIdx, user, noOfNFTs, uri, status);
    }
  }

  /**
   * @notice Admin function to mint NFTs for multiple users.
   * @dev This function allows the admin to mint 1 NFT per user from the specified validator version. It checks that the total supply is not exceeded and ensures each user receives exactly 1 NFT.
   * @param validatorVerIdx The index of the validator version to mint from.
   * @param users Array of user addresses, each of whom will receive 1 NFT.
   * @param uri The URI for the metadata associated with the NFTs.
   * @param status The status of the validator for the minted NFTs.
   * 
   * Requirements:
   * - The caller must be an admin.
   * - The `validatorVerIdx` must be valid.
   * - The `uri` must not be empty.
   * - The `users` array must not be empty.
   * - The `status` must not be `Invalid`.
   * - Each `user` address must not be the zero address.
   * - The total number of NFTs being minted must not exceed the total supply for the validator version.
   * 
   * Emits:
   * - None.
   * 
   * Reverts:
   * - {WrongValidatorVersionIndex} if the validator version index is invalid.
   * - {InvalidArg} if the `uri` is empty or `users` array is empty.
   * - {InvalidValidatorStatus} if the validator status is `Invalid`.
   * - {MintingExceedsTotalSupply} if minting the requested number of NFTs exceeds the total supply for the validator version.
   * - {InvalidAddress} if any `user` is the zero address.
   * - {MintingFailed} if the minting operation fails for any user.
   */
  function adminMint(uint256 validatorVerIdx, address[] calldata users, string calldata uri, ValidatorStatus status) 
      external nonReentrant onlyAdmin 
  {
    if (validatorVerIdx >= validatorVersionCount) {
      revert WrongValidatorVersionIndex(validatorVerIdx);
    }

    if (bytes(uri).length == 0) {
      revert InvalidArg("uri");
    }

    if (users.length == 0) {
      revert InvalidArg("users");
    }

    if (status == ValidatorStatus.Invalid) {
      revert InvalidValidatorStatus();
    }

    uint256 totalMintReq = validatorVersions[validatorVerIdx].minted + users.length;
    if (totalMintReq > validatorVersions[validatorVerIdx].ts) {
      revert MintingExceedsTotalSupply(validatorVerIdx, totalMintReq, validatorVersions[validatorVerIdx].ts);
    }

    for (uint256 i = 0; i < users.length; i++) {
      address user = users[i];
      if (user == address(0)) {
        revert InvalidAddress(user);
      }

      // Mint 1 NFT per user
      bool success = _internalMint(validatorVerIdx, user, 1, uri, status);
      if (!success) {
        revert MintingFailed(validatorVerIdx, user, 1, uri, status);
      }
    }
  }

  /**
   * @notice Internal function to mint NFTs for a user from a specific validator version.
   * @dev This function mints the specified number of NFTs to a user, verifies the mint was successful, and updates the minted count for the validator version.
   * It assigns the NFT metadata URI, updates the validator status, and handles approval requests if the status is not active.
   * @param validatorVerIdx The index of the validator version from which the NFTs are being minted.
   * @param user The address of the user receiving the NFTs.
   * @param noOfNFTs The number of NFTs to mint for the user.
   * @param uri The URI for the metadata associated with the minted NFTs.
   * @param status The status of the validator for the minted NFTs.
   * @return success Returns `true` if the minting was successful, otherwise returns `false`.
   */
  function _internalMint(uint256 validatorVerIdx, address user, uint256 noOfNFTs, string memory uri, ValidatorStatus status) private returns (bool) {
    if (validatorVerIdx >= validatorVersionCount) {
      // Invalid validator version
      return false;
    }
    if (bytes(uri).length == 0) {
      return false;
    }
    if (validatorVersions[validatorVerIdx].minted >= validatorVersions[validatorVerIdx].ts) {
      // Cannot mint more than ts
      return false;
    }

    for (uint256 i = 0; i < noOfNFTs; i++) {
      // Get the user's balance before mint
      uint256 previousBalance = balanceOf(user);

      _safeMint(user, _totalMinted); // mint the NFT to the user

      // Validate successful mint
      if (balanceOf(user) != previousBalance + 1) {
        return false;
      }

      validatorVersions[validatorVerIdx].minted++;
      _tokenURIs[_totalMinted] = uri;

      reclaimable[_totalMinted] = true;
      nftToValidatorVersion[_totalMinted] = validatorVerIdx;
      nftValidatorStatus[_totalMinted] = status;

      emit NFTMinted(user, _totalMinted, validatorVerIdx);

      // Only add to approvalRequests if the status is not active
      if (status != ValidatorStatus.Active) {
        approvalRequests[_totalMinted].user = user;
        approvalRequests[_totalMinted].status = RequestStatus.Pending;
        approvalRequests[_totalMinted].reason = "";
        emit ValidatorNodeRequested(user, _totalMinted, validatorVerIdx);
      }

      _totalMinted++;  // Increment the total minted count
    }
    return true;
  }

  /**
   * @notice Internal function to update the ownership of an NFT with a soulbound transfer restriction.
   * @dev This function overrides the base `_update` function to enforce the soulbound property, preventing transfers by disallowing updates if both `from` and `to` addresses are non-zero.
   * @param to The address to which the token is being updated (new owner).
   * @param tokenId The ID of the token being updated.
   * @param auth The authorized address responsible for initiating the update.
   * @return previousOwner Returns the previous owner of the token before the update.
   * 
   * Reverts:
   * - If both `from` and `to` addresses are non-zero, indicating a soulbound transfer attempt.
   */
  function _update(address to, uint256 tokenId, address auth) internal override returns (address) {
    // Restricts the transfer of Soulbound tokens
    address from = _ownerOf(tokenId);
    if (from != address(0) && to != address(0)) {
      revert("Soulbound: Transfer failed");
    }

    return super._update(to, tokenId, auth);
  }

  /**
   * @notice Sets the treasury wallet address.
   * @dev This function allows the contract owner to update the treasury wallet address. The new address must not be the zero address.
   * @param walletAddr The new address for the treasury wallet.
   * 
   * Requirements:
   * - The caller must be the contract owner.
   * - The `walletAddr` must not be the zero address.
   * 
   * Emits:
   * - {TreasuryWalletSet} event indicating the treasury wallet address was updated.
   * 
   * Reverts:
   * - {InvalidAddress} if the provided `walletAddr` is the zero address.
   */
  function setTreasuryWallet(address walletAddr) external onlyOwner {
    if (walletAddr == address(0)) {
      revert InvalidAddress(walletAddr);
    }
    _treasuryWallet = walletAddr;
    emit TreasuryWalletSet(walletAddr);
  }

  /**
   * @notice Retrieves the current treasury wallet address.
   * @dev This function allows only the contract owner to retrieve the treasury wallet address.
   * @return treasuryWallet The address of the current treasury wallet.
   */
  function getTreasuryWallet() external view onlyOwner returns (address) {
    return _treasuryWallet;
  }

  /**
   * @notice Sets the token URIs for multiple NFTs.
   * @dev This function allows an admin to update the metadata URI for a batch of NFTs. Each token in the `tokenIds` array must exist in the contract.
   * @param tokenIds An array of token IDs for which the URIs will be updated.
   * @param uriStr The new URI to set for all the provided tokens.
   * 
   * Requirements:
   * - The caller must be an admin.
   * - The `tokenIds` array must not be empty.
   * - The `uriStr` must not be empty.
   * - Each token in the `tokenIds` array must exist.
   * 
   * Emits:
   * - None.
   * 
   * Reverts:
   * - {InvalidArg} if the `uriStr` is empty or `tokenIds` array is empty.
   * - {TokenIDDoesNotExist} if any token ID in the array does not exist.
   */
  function setTokenURIs(uint256[] calldata tokenIds, string calldata uriStr) external onlyAdmin {
    if (tokenIds.length == 0) {
      revert InvalidArg("tokenIds");
    }
    if (bytes(uriStr).length == 0) {
      revert InvalidArg("uriStr");
    }

    for (uint256 i = 0; i < tokenIds.length; i++) {
      if (!_tokenExists(tokenIds[i])) {
        revert TokenIDDoesNotExist(tokenIds[i]);
      }

      _tokenURIs[tokenIds[i]] = uriStr;
    }
  }

  /**
   * @notice Returns the metadata URI for a specific token.
   * @dev If the token URI is set in the `_tokenURIs` mapping, it returns that value. Otherwise, it returns the inactive URI associated with the validator version of the token.
   * @param tokenId The ID of the token for which the URI is requested.
   * @return uri The metadata URI for the specified token.
   * 
   * Requirements:
   * - The `tokenId` must exist.
   */
  function tokenURI(uint256 tokenId) public view virtual override tokenIDExists(tokenId) returns (string memory) {
    // Override tokenURI to return the URI from mapping (if not set)
    if (bytes(_tokenURIs[tokenId]).length > 0) {
      return _tokenURIs[tokenId];
    } else {
      return validatorVersions[nftToValidatorVersion[tokenId]].inactiveURI;
    }
  }

  // ----------------- APPROVAL {{{

  /**
   * @notice Allows users to request the minting of validator node NFTs by providing the required collateral.
   * @dev This function mints NFTs for users from a specific validator version, provided the collateral is successfully transferred to the treasury wallet.
   *      It ensures that the minting does not exceed the total supply for the specified validator version. The function reverts if the transfer or minting process fails.
   * @param validatorVerIdx The index of the validator version from which the NFTs are to be minted.
   * @param noOfNFTs The number of NFTs to mint.
   * 
   * Requirements:
   * - `validatorVerIdx` must be valid and less than the total count of validator versions.
   * - `noOfNFTs` must be greater than 0.
   * - The total minted NFTs must not exceed the validator version's total supply (`ts`).
   * - The treasury wallet must be set.
   * - The user must have approved sufficient token allowance for the collateral transfer.
   * 
   * Emits:
   * - {NFTMinted} event for each minted NFT.
   * - {ValidatorNodeRequested} event for each minted NFT with status inactive.
   * 
   * Reverts:
   * - {WrongValidatorVersionIndex} if the validator version index is invalid.
   * - {InvalidArg} if the number of NFTs is zero or less.
   * - {MintingExceedsTotalSupply} if minting exceeds the total supply for the validator version.
   * - {InvalidAddress} if the treasury wallet is not set.
   * - {InsufficientAllowance} if the user does not have enough allowance for the collateral transfer.
   * - {validatorNodeRequestFailed} if the minting operation fails.
   */
  // Function for users to request a validator node
  function validatorNodeRequest(uint256 validatorVerIdx, uint256 noOfNFTs) external nonReentrant {
    if (validatorVerIdx >= validatorVersionCount) {
      revert WrongValidatorVersionIndex(validatorVerIdx);
    }

    if (noOfNFTs == 0) {
      revert InvalidArg("noOfNFTs");
    }

    uint256 totalMintReq = validatorVersions[validatorVerIdx].minted + noOfNFTs;
    if (totalMintReq > validatorVersions[validatorVerIdx].ts) {
      revert MintingExceedsTotalSupply(validatorVerIdx, totalMintReq, validatorVersions[validatorVerIdx].ts);
    }

    if (_treasuryWallet == address(0)) {
      revert InvalidAddress(_treasuryWallet);
    }

    address underlyingToken = validatorVersions[validatorVerIdx].underlying;
    uint256 collateral = validatorVersions[validatorVerIdx].collateral * noOfNFTs;

    // Transfer tokens from the user to the treasury wallet
    uint256 allowance = IERC20(underlyingToken).allowance(_msgSender(), address(this));
    if (allowance < collateral) {
      revert InsufficientAllowance(_msgSender(), address(this), collateral, allowance);
    }

    // transfer collateral
    IERC20(underlyingToken).safeTransferFrom(_msgSender(), _treasuryWallet, collateral);

    // Perform minting
    bool mintSuccess = _internalMint(validatorVerIdx, _msgSender(), noOfNFTs, validatorVersions[validatorVerIdx].inactiveURI, ValidatorStatus.Inactive);
    // Check if both operations were successful
    if (!mintSuccess) {
      revert validatorNodeRequestFailed();
    }
  }

  /**
   * @notice Approves and processes validator node NFT requests.
   * @dev This function updates the metadata URI and sets the status of NFTs to active for tokens with pending approval requests. After processing, it emits an event and deletes the approval request.
   * @param tokenIds An array of token IDs to be approved.
   * @param uriStr The new URI to set for each approved token.
   * 
   * Requirements:
   * - The caller must be an admin.
   * - The `tokenIds` array must not be empty.
   * - Each token ID must have a pending approval request.
   * - The `uriStr` must not be empty.
   * 
   * Emits:
   * - {ValidatorNodeApproved} event for each approved token request.
   * 
   * Reverts:
   * - {InvalidArg} if the `uriStr` is empty or `tokenIds` array is empty.
   * - {IncorrectRequestStatus} if any token ID does not have a pending approval request.
   */
  function approveValidatorNodeRequests(uint256[] calldata tokenIds, string calldata uriStr) external onlyAdmin {
    if (tokenIds.length == 0) {
      revert InvalidArg("tokenIds");
    }
    if (bytes(uriStr).length == 0) {
      revert InvalidArg("uriStr");
    }

    for (uint256 i = 0; i < tokenIds.length; i++) {
      uint256 tokenId = tokenIds[i];
      if (approvalRequests[tokenId].status != RequestStatus.Pending) {
        revert IncorrectRequestStatus(tokenId, approvalRequests[tokenId].status, RequestStatus.Pending);
      }

      // Update the uriStr for each token
      _tokenURIs[tokenId] = uriStr;

      // Set the NFT status to active
      nftValidatorStatus[tokenId] = ValidatorStatus.Active;

      // Emit event for each approval
      emit ValidatorNodeApproved(_msgSender(), tokenId, approvalRequests[tokenId].user, nftToValidatorVersion[tokenId]);

      // Delete the approval request after processing
      delete approvalRequests[tokenId];
    }
  }

  /**
   * @notice Rejects pending validator node NFT requests and records the reason for rejection.
   * @dev This function updates the status of NFTs with pending approval requests to rejected and records the provided reason for each rejection.
   * @param tokenIds An array of token IDs whose approval requests are to be rejected.
   * @param reason The reason for rejecting the approval requests for the provided token IDs.
   * 
   * Requirements:
   * - The caller must be an admin.
   * - The `tokenIds` array must not be empty.
   * - Each token ID in the `tokenIds` array must have a pending approval request.
   * - The `reason` must not be an empty string.
   * 
   * Emits:
   * - {ValidatorNodeRejected} event for each rejected token request.
   * 
   * Reverts:
   * - {InvalidArg} if the `reason` is an empty string or `tokenIds` array is empty.
   * - {IncorrectRequestStatus} if any token ID does not have a pending approval request.
   */
  function rejectValidatorNodeRequests(uint256[] calldata tokenIds, string calldata reason) external onlyAdmin {
    if (tokenIds.length == 0) {
      revert InvalidArg("tokenIds");
    }
    if (bytes(reason).length == 0) {
      revert InvalidArg("reason");
    }

    for (uint256 i = 0; i < tokenIds.length; i++) {
      uint256 tokenId = tokenIds[i];
      
      if (approvalRequests[tokenId].status != RequestStatus.Pending) {
        revert IncorrectRequestStatus(tokenId, approvalRequests[tokenId].status, RequestStatus.Pending);
      }

      // Update the request status to Rejected
      approvalRequests[tokenId].status = RequestStatus.Rejected;
      
      // Set the rejection reason for each token
      approvalRequests[tokenId].reason = reason;
      
      // Emit event for each token ID rejection
      emit ValidatorNodeRejected(_msgSender(), tokenId, approvalRequests[tokenId].user, nftToValidatorVersion[tokenId]);
    }
  }

  /**
   * @notice Retrieves the status and reason for a validator node NFT request.
   * @dev This function allows users to check the current status of their request and the reason if it was rejected. It returns the status and rejection reason associated with the specified token ID.
   * @param tokenId The ID of the token for which the request status is being queried.
   * @return status The current status of the request (Pending, Approved, or Rejected).
   * @return reason The reason for rejection if the status is Rejected, or an empty string if the request is Pending or Approved.
   * 
   * Requirements:
   * - The `tokenId` must exist.
   */
  function getValidatorNodeRequestStatus(uint256 tokenId) external view returns (RequestStatus, string memory) {
    return (approvalRequests[tokenId].status, approvalRequests[tokenId].reason);
  }

  /**
   * @notice Allows the owner of a rejected validator node NFT to reclaim the collateral.
   * @dev This function enables users to reclaim collateral for NFTs that have been rejected. It burns the NFT, resets related state, and transfers the collateral back to the owner.
   * @param tokenId The ID of the token for which the collateral is being reclaimed.
   * 
   * Requirements:
   * - The request status of the NFT must be `Rejected`.
   * - The caller must be the owner of the NFT.
   * - The NFT must be marked as reclaimable.
   * 
   * Emits:
   * - {NFTBurned} event indicating the token has been burned.
   * - {ValidatorNodeRejectedReclaimCompleted} event indicating the collateral has been transferred back to the owner.
   * 
   * Reverts:
   * - {IncorrectRequestStatus} if the request status is not `Rejected`.
   * - {NotNFTOwner} if the caller is not the owner of the NFT.
   * - {NotReclaimable} if the NFT is not marked as reclaimable.
   * - If the collateral transfer fails.
   */
  function reclaimValidatorNodeRequestRejectedCollateral(uint256 tokenId) external nonReentrant {
    if (approvalRequests[tokenId].status != RequestStatus.Rejected) {
      revert IncorrectRequestStatus(tokenId, approvalRequests[tokenId].status, RequestStatus.Rejected);
    }
    if (ownerOf(tokenId) != _msgSender()) {
      revert NotNFTOwner(_msgSender(), tokenId);
    }
    if (!reclaimable[tokenId]) {
      revert NotReclaimable(tokenId);
    }

    // Get the collateral details
    uint256 valIdx = nftToValidatorVersion[tokenId];
    uint256 collateral = validatorVersions[valIdx].collateral;
    address underlyingToken = validatorVersions[valIdx].underlying;

    // Burn the NFT before transferring collateral
    _burn(tokenId);
    emit NFTBurned(_msgSender(), tokenId);

    // Reset values
    reclaimable[tokenId] = false;
    nftToValidatorVersion[tokenId] = type(uint256).max;
    nftValidatorStatus[tokenId] = ValidatorStatus.Invalid;
    delete approvalRequests[tokenId];

    // transfer collateral
    IERC20(underlyingToken).safeTransfer(_msgSender(), collateral);

    emit ValidatorNodeRejectedReclaimCompleted(_msgSender(), tokenId);
  }

  // ----------------- APPROVAL }}}

  // ----------------- RECLAIM {{{

  /**
   * @notice Sets the reclaimable status for a list of NFT tokens.
   * @dev This function allows the admin to update the reclaimable flag for multiple token IDs. It verifies that each token ID exists before updating its status.
   * @param tokenIds An array of token IDs for which the reclaimable status is being set.
   * @param flag The reclaimable status to set for the provided token IDs (true or false).
   * 
   * Requirements:
   * - The caller must be an admin.
   * - The `tokenIds` array must not be empty.
   * - Each token ID in the `tokenIds` array must exist.
   * 
   * Reverts:
   * - {InvalidArg} if the `tokenIds` array is empty.
   * - {TokenIDDoesNotExist} if any token ID does not exist.
   */
  function setReclaimable(uint256[] calldata tokenIds, bool flag) external onlyAdmin {
    if (tokenIds.length == 0) {
      revert InvalidArg("tokenIds");
    }

    for (uint256 i = 0; i < tokenIds.length; i++) {
      if (!_tokenExists(tokenIds[i])) {
        revert TokenIDDoesNotExist(tokenIds[i]);
      }
      reclaimable[tokenIds[i]] = flag;
    }
  }

  /**
   * @notice Initiates a reclaim request for the collateral associated with a specific NFT.
   * @dev This function allows the owner of a reclaimable NFT to request the return of collateral by sending the required reclaim fee.
   *      It verifies ownership, ensures the reclaim request is not already pending or approved, and processes the request if the correct fee is provided.
   * @param tokenId The ID of the token for which the reclaim request is being made.
   * 
   * Requirements:
   * - The token ID must exist.
   * - The caller must be the owner of the NFT.
   * - The NFT must be marked as reclaimable.
   * - The reclaim request must not be in `Pending` or `Approved` state.
   * - The correct reclaim fee must be sent with the request.
   * 
   * Emits:
   * - {ReclaimRequested} event indicating a new reclaim request has been made.
   * 
   * Reverts:
   * - {NotNFTOwner} if the caller is not the owner of the NFT.
   * - {NotReclaimable} if the NFT is not marked as reclaimable.
   * - If a reclaim request is already in `Pending` or `Approved` state.
   * - {IncorrectReclaimFeeSent} if the incorrect reclaim fee is provided.
   */
  function requestReclaimCollateral(uint256 tokenId) external payable tokenIDExists(tokenId) {
    if (ownerOf(tokenId) != _msgSender()) {
      revert NotNFTOwner(_msgSender(), tokenId);
    }

    if (!reclaimable[tokenId]) {
      revert NotReclaimable(tokenId);
    }

    require(reclaimRequests[tokenId].status != RequestStatus.Pending, "Reclaim already in Pending state");
    require(reclaimRequests[tokenId].status != RequestStatus.Approved, "Reclaim already in Approved state");

    // NOTE: If the earlier request is in Rejected state, the use must be able to go through the reclaim again

    // Check if the correct reclaim fee is sent
    if (msg.value != reclaimFee) {
      revert IncorrectReclaimFeeSent(msg.value, reclaimFee);
    }

    // Set reclaim request details
    reclaimRequests[tokenId].user = _msgSender();
    reclaimRequests[tokenId].status = RequestStatus.Pending;
    reclaimRequests[tokenId].reason = "";

    // Emit reclaim requested event
    emit ReclaimRequested(_msgSender(), tokenId, nftToValidatorVersion[tokenId]);
  }

  /**
   * @notice Approves pending reclaim requests for a list of NFT tokens.
   * @dev This function allows the admin to approve reclaim requests for multiple tokens. It updates the status of each request to `Approved`
   *      if the request is pending and the token exists. It emits an event for each approved request.
   * @param tokenIds An array of token IDs whose reclaim requests are to be approved.
   * 
   * Requirements:
   * - The caller must be an admin.
   * - The `tokenIds` array must not be empty.
   * - Each token ID in the `tokenIds` array must exist.
   * - Each reclaim request associated with the token ID must be in the `Pending` state.
   * 
   * Emits:
   * - {ReclaimApproved} event for each token ID whose reclaim request is approved.
   * 
   * Reverts:
   * - {InvalidArg} if the `tokenIds` array is empty.
   * - {TokenIDDoesNotExist} if any token ID does not exist.
   * - {IncorrectRequestStatus} if any reclaim request is not in the `Pending` state.
   */
  function approveReclaimRequests(uint256[] calldata tokenIds) external onlyAdmin {
    if (tokenIds.length == 0) {
      revert InvalidArg("tokenIds");
    }

    for (uint256 i = 0; i < tokenIds.length; i++) {
      uint256 tokenId = tokenIds[i];

      // Check if the token exists
      if (!_tokenExists(tokenId)) {
        revert TokenIDDoesNotExist(tokenId);
      }

      if (reclaimRequests[tokenId].status != RequestStatus.Pending) {
        revert IncorrectRequestStatus(tokenId, reclaimRequests[tokenId].status, RequestStatus.Pending);
      }

      // Approve the reclaim request by updating its status
      reclaimRequests[tokenId].status = RequestStatus.Approved;
      emit ReclaimApproved(_msgSender(), tokenId, nftToValidatorVersion[tokenId]);
    }
  }

  /**
   * @notice Claims back the collateral for a specific NFT by the owner, provided that the reclaim request is approved.
   * @dev This function allows the owner of an NFT to reclaim the collateral if the reclaim request is approved and the NFT is marked as reclaimable. The NFT is burned before the collateral is transferred back to the user.
   * @param tokenId The ID of the NFT for which the collateral is being reclaimed.
   * 
   * Requirements:
   * - The caller must be the owner of the NFT.
   * - The NFT must be marked as reclaimable.
   * - The reclaim request for the NFT must be approved.
   * 
   * Emits:
   * - {NFTBurned} event indicating the NFT has been burned.
   * - {ReclaimCompleted} event indicating the collateral has been transferred to the owner.
   * 
   * Reverts:
   * - {NotNFTOwner} if the caller is not the owner of the NFT.
   * - {NotReclaimable} if the NFT is not marked as reclaimable.
   * - {IncorrectRequestStatus} if the reclaim request is not approved.
   * - If the collateral transfer fails.
   */
  function reclaimCollateral(uint256 tokenId) external nonReentrant tokenIDExists(tokenId) {
    // Function for users to reclaim collateral
    if (ownerOf(tokenId) != _msgSender()) {
        revert NotNFTOwner(_msgSender(), tokenId);
    }
    if (!reclaimable[tokenId]) {
        revert NotReclaimable(tokenId);
    }
    if (reclaimRequests[tokenId].status != RequestStatus.Approved) {
        revert IncorrectRequestStatus(tokenId, reclaimRequests[tokenId].status, RequestStatus.Approved);
    }

    // Get the validator version for the NFT
    uint256 validatorIdx = nftToValidatorVersion[tokenId];
    address underlyingToken = validatorVersions[validatorIdx].underlying;
    uint256 collateral = validatorVersions[validatorIdx].collateral;

    // Burn the NFT before transferring collateral
    _burn(tokenId);
    emit NFTBurned(_msgSender(), tokenId);

    // Reset values
    reclaimable[tokenId] = false;
    nftToValidatorVersion[tokenId] = type(uint256).max;
    nftValidatorStatus[tokenId] = ValidatorStatus.Invalid;

    // delete the record once everything is settled
    delete reclaimRequests[tokenId];

    // transfer collateral
    IERC20(underlyingToken).safeTransfer(_msgSender(), collateral);

    emit ReclaimCompleted(_msgSender(), tokenId);
  }

  /**
   * @notice Rejects reclaim requests for multiple NFTs and sets the reason for rejection for each one.
   * @dev This function allows the admin to reject reclaim requests for an array of token IDs. It updates the request status
   *      to `Rejected` and records the reason for rejection for each token. The reclaimable flag for the NFTs is not automatically
   *      set to `False` and must be managed manually if needed.
   * @param tokenIds An array of token IDs whose reclaim requests are being rejected.
   * @param reason A string providing the reason for rejecting the reclaim requests.
   * 
   * Requirements:
   * - The caller must be an admin.
   * - The `tokenIds` array must not be empty.
   * - Each reclaim request must be in the `Pending` state.
   * - The `reason` must not be an empty string.
   * 
   * Emits:
   * - {ReclaimRejected} event for each token ID indicating the rejection of the reclaim request.
   * 
   * Reverts:
   * - {InvalidArg} if the `reason` is an empty string or `tokenIds` array is empty.
   * - {IncorrectRequestStatus} if any reclaim request is not in the `Pending` state.
   */
  function rejectReclaimRequests(uint256[] calldata tokenIds, string calldata reason) external onlyAdmin {
    if (tokenIds.length == 0) {
      revert InvalidArg("tokenIds");
    }
    if (bytes(reason).length == 0) {
      revert InvalidArg("reason");
    }

    for (uint256 i = 0; i < tokenIds.length; i++) {
      uint256 tokenId = tokenIds[i];

      // Check if token ID exists and the reclaim request is in Pending status
      if (reclaimRequests[tokenId].status != RequestStatus.Pending) {
        revert IncorrectRequestStatus(tokenId, reclaimRequests[tokenId].status, RequestStatus.Pending);
      }

      // Reject the reclaim request and set the reason
      reclaimRequests[tokenId].status = RequestStatus.Rejected;
      reclaimRequests[tokenId].reason = reason;

      // NOTE: The request is rejected but the reclaimable flag is not set to False. This has to be done manually by Admin if required

      // Emit event for each token ID
      emit ReclaimRejected(_msgSender(), tokenId, nftToValidatorVersion[tokenId]);
    }
  }

  /**
   * @notice Retrieves the status and reason of a reclaim request for a specific NFT.
   * @dev This function provides the current status and reason for a reclaim request associated with a given token ID. 
   *      It is a read-only function and does not modify the contract state.
   * @param tokenId The ID of the token for which the reclaim request status is being queried.
   * @return status The current status of the reclaim request (e.g., Pending, Approved, Rejected).
   * @return reason The reason provided for the reclaim request status, such as the reason for rejection if applicable.
   * 
   * Requirements:
   * - The token ID must exist.
   */
  function getReclaimRequestStatus(uint256 tokenId) external view returns (RequestStatus, string memory) {
    return (reclaimRequests[tokenId].status, reclaimRequests[tokenId].reason);
  }
  // ----------------- RECLAIM }}}

  // ----------------- RESCUE {{{

  /**
   * @notice Withdraws all Ether from the contract and transfers it to a specified address.
   * @dev This function allows the admin to rescue all Ether from the contract. The entire Ether balance is transferred to the specified address.
   * @param to The address to which the Ether will be sent.
   * 
   * Requirements:
   * - The caller must be an admin.
   * - The `to` address must not be the zero address.
   * - The Ether transfer must be successful.
   * 
   * Reverts:
   * - {InvalidAddress} if the `to` address is the zero address.
   * - {EtherTransferFailed} if the Ether transfer fails.
   */
  function rescue(address to) public nonReentrant onlyAdmin {
    if (to == address(0)) {
      revert InvalidAddress(to);
    }
    // withdraw accidentally sent native currency. Can also be used to withdraw reclaim fees
    uint256 amount = address(this).balance;
    (bool success, ) = payable(to).call{value: amount}("");
    if (!success) {
      revert EtherTransferFailed(to, amount);
    }
  }

  /**
   * @notice Withdraws all ERC20 tokens from the contract and transfers them to a specified address.
   * @dev This function allows the admin to rescue ERC20 tokens that were accidentally sent to the contract. All tokens of the specified type held by the contract are transferred to the specified address.
   * @param token The address of the ERC20 token to be rescued.
   * @param to The address to which the ERC20 tokens will be sent.
   * 
   * Requirements:
   * - The caller must be an admin.
   * - The `token` address must not be the zero address.
   * - The `to` address must not be the zero address.
   * - The contract must hold a balance of the specified token.
   * 
   * Reverts:
   * - {InvalidAddress} if the `token` or `to` address is the zero address.
   */
  function rescueToken(address token, address to) public nonReentrant onlyAdmin {
    // withdraw accidentally sent erc20 tokens
    if (token == address(0)) {
      revert InvalidAddress(token);
    }

    if (to == address(0)) {
      revert InvalidAddress(to);
    }

    uint256 amount = IERC20(token).balanceOf(address(this));
    IERC20(token).safeTransfer(to, amount);
  }

  /**
   * @notice Withdraws an ERC721 NFT from the contract and transfers it to a specified address.
   * @dev This function allows the admin to rescue an NFT that was accidentally sent to the contract. The specified NFT is transferred from the contract to the provided address.
   * @param receiver The address to which the NFT will be sent.
   * @param nft The address of the ERC721 NFT contract.
   * @param id The ID of the NFT to be rescued.
   * 
   * Requirements:
   * - The caller must be an admin.
   * - The `receiver` address must not be the zero address.
   * - The `nft` contract address must not be the zero address.
   * - The contract must own the NFT with the specified `id`.
   * 
   * Reverts:
   * - {InvalidAddress} if the `receiver` or `nft` address is the zero address.
   * - {NotNFTOwner} if the contract does not own the NFT with the specified `id`.
   */
  function rescueNFT(address receiver, address nft, uint256 id) public nonReentrant onlyAdmin {
    // withdraw accidentally sent nft
    if (receiver == address(0)) {
      revert InvalidAddress(receiver);
    }
    if (nft == address(0)) {
      revert InvalidAddress(nft);
    }

    // Check if the contract owns the NFT
    if (IERC721(nft).ownerOf(id) != address(this)) {
      revert NotNFTOwner(nft, id);
    }

    // Execute the transfer if the ownership check passes
    IERC721(nft).safeTransferFrom(address(this), receiver, id);
  }

  // ----------------- RESCUE }}}

  // ----------------- Ownership Handling {{{

  /**
   * @notice Disables the ability to renounce ownership of the contract.
   * @dev This function is overridden to prevent the contract owner from renouncing ownership.
   *      Calling this function will always revert with the message "RenounceOwnership is disabled".
   */
  function renounceOwnership() public view override onlyOwner {
    revert("RenounceOwnership is disabled");
  }

  // ----------------- Ownership Handling }}}

  // ----------------- Request List Handling {{{

  /**
   * @notice Admin function to update the status and rejection reason for a specific token's approval request.
   * @dev This function allows the admin to update the `status` and `reason` fields in the `approvalRequests` mapping for a given token ID.
   * @param tokenId The ID of the token whose approval request is being updated.
   * @param status The new status to set (e.g., Pending, Approved, Rejected).
   * @param reason The reason for the status update (e.g., rejection reason).
   * 
   * Requirements:
   * - The caller must be an admin.
   * - The token ID must exist in the `approvalRequests`.
   * 
   * Reverts:
   * - If the token ID does not exist.
   */
  function setApprovalRequestStatus(uint256 tokenId, RequestStatus status, string calldata reason) external onlyAdmin {
    if (approvalRequests[tokenId].user == address(0)) {
      revert TokenIDDoesNotExist(tokenId);
    }

    approvalRequests[tokenId].status = status;
    approvalRequests[tokenId].reason = reason;
  }

  /**
   * @notice Admin function to update the status and rejection reason for a specific token's reclaim request.
   * @dev This function allows the admin to update the `status` and `reason` fields in the `reclaimRequests` mapping for a given token ID.
   * @param tokenId The ID of the token whose reclaim request is being updated.
   * @param status The new status to set (e.g., Pending, Approved, Rejected).
   * @param reason The reason for the status update (e.g., rejection reason).
   * 
   * Requirements:
   * - The caller must be an admin.
   * - The token ID must exist in the `reclaimRequests`.
   * 
   * Reverts:
   * - If the token ID does not exist.
   */
  function setReclaimRequestStatus(uint256 tokenId, RequestStatus status, string calldata reason) external onlyAdmin {
    if (reclaimRequests[tokenId].user == address(0)) {
      revert TokenIDDoesNotExist(tokenId);
    }

    reclaimRequests[tokenId].status = status;
    reclaimRequests[tokenId].reason = reason;
  }

  /**
   * @notice Admin function to delete an approval request for a specific token.
   * @dev This function allows the admin to remove an approval request from the `approvalRequests` mapping for a given token ID.
   * @param tokenId The ID of the token whose approval request is to be deleted.
   * 
   * Requirements:
   * - The caller must be an admin.
   * - The token ID must exist in the `approvalRequests`.
   * 
   * Reverts:
   * - {TokenIDDoesNotExist} if the token ID does not exist in the `approvalRequests`.
   */
  function deleteApprovalRequest(uint256 tokenId) external onlyAdmin {
    if (approvalRequests[tokenId].user == address(0)) {
      revert TokenIDDoesNotExist(tokenId);
    }
    delete approvalRequests[tokenId];
  }

  /**
   * @notice Admin function to delete a reclaim request for a specific token.
   * @dev This function allows the admin to remove a reclaim request from the `reclaimRequests` mapping for a given token ID.
   * @param tokenId The ID of the token whose reclaim request is to be deleted.
   * 
   * Requirements:
   * - The caller must be an admin.
   * - The token ID must exist in the `reclaimRequests`.
   * 
   * Reverts:
   * - {TokenIDDoesNotExist} if the token ID does not exist in the `reclaimRequests`.
   */
  function deleteReclaimRequest(uint256 tokenId) external onlyAdmin {
    if (reclaimRequests[tokenId].user == address(0)) {
      revert TokenIDDoesNotExist(tokenId);
    }
    delete reclaimRequests[tokenId];
  }

  // ----------------- Request List Handling }}}

}