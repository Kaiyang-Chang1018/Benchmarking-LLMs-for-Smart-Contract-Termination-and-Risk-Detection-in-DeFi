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
// OpenZeppelin Contracts (last updated v4.9.0) (interfaces/IERC2612.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/extensions/IERC20Permit.sol";

interface IERC2612 is IERC20Permit {}
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
// OpenZeppelin Contracts (last updated v4.9.4) (token/ERC20/extensions/IERC20Permit.sol)

pragma solidity ^0.8.0;

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
// OpenZeppelin Contracts (last updated v4.9.4) (utils/Context.sol)

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

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
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
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

import './pool/IUniswapV3PoolImmutables.sol';
import './pool/IUniswapV3PoolState.sol';
import './pool/IUniswapV3PoolDerivedState.sol';
import './pool/IUniswapV3PoolActions.sol';
import './pool/IUniswapV3PoolOwnerActions.sol';
import './pool/IUniswapV3PoolEvents.sol';

/// @title The interface for a Uniswap V3 Pool
/// @notice A Uniswap pool facilitates swapping and automated market making between any two assets that strictly conform
/// to the ERC20 specification
/// @dev The pool interface is broken up into many smaller pieces
interface IUniswapV3Pool is
    IUniswapV3PoolImmutables,
    IUniswapV3PoolState,
    IUniswapV3PoolDerivedState,
    IUniswapV3PoolActions,
    IUniswapV3PoolOwnerActions,
    IUniswapV3PoolEvents
{

}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Callback for IUniswapV3PoolActions#swap
/// @notice Any contract that calls IUniswapV3PoolActions#swap must implement this interface
interface IUniswapV3SwapCallback {
    /// @notice Called to `msg.sender` after executing a swap via IUniswapV3Pool#swap.
    /// @dev In the implementation you must pay the pool tokens owed for the swap.
    /// The caller of this method must be checked to be a UniswapV3Pool deployed by the canonical UniswapV3Factory.
    /// amount0Delta and amount1Delta can both be 0 if no tokens were swapped.
    /// @param amount0Delta The amount of token0 that was sent (negative) or must be received (positive) by the pool by
    /// the end of the swap. If positive, the callback must send that amount of token0 to the pool.
    /// @param amount1Delta The amount of token1 that was sent (negative) or must be received (positive) by the pool by
    /// the end of the swap. If positive, the callback must send that amount of token1 to the pool.
    /// @param data Any data passed through by the caller via the IUniswapV3PoolActions#swap call
    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external;
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Permissionless pool actions
/// @notice Contains pool methods that can be called by anyone
interface IUniswapV3PoolActions {
    /// @notice Sets the initial price for the pool
    /// @dev Price is represented as a sqrt(amountToken1/amountToken0) Q64.96 value
    /// @param sqrtPriceX96 the initial sqrt price of the pool as a Q64.96
    function initialize(uint160 sqrtPriceX96) external;

    /// @notice Adds liquidity for the given recipient/tickLower/tickUpper position
    /// @dev The caller of this method receives a callback in the form of IUniswapV3MintCallback#uniswapV3MintCallback
    /// in which they must pay any token0 or token1 owed for the liquidity. The amount of token0/token1 due depends
    /// on tickLower, tickUpper, the amount of liquidity, and the current price.
    /// @param recipient The address for which the liquidity will be created
    /// @param tickLower The lower tick of the position in which to add liquidity
    /// @param tickUpper The upper tick of the position in which to add liquidity
    /// @param amount The amount of liquidity to mint
    /// @param data Any data that should be passed through to the callback
    /// @return amount0 The amount of token0 that was paid to mint the given amount of liquidity. Matches the value in the callback
    /// @return amount1 The amount of token1 that was paid to mint the given amount of liquidity. Matches the value in the callback
    function mint(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount,
        bytes calldata data
    ) external returns (uint256 amount0, uint256 amount1);

    /// @notice Collects tokens owed to a position
    /// @dev Does not recompute fees earned, which must be done either via mint or burn of any amount of liquidity.
    /// Collect must be called by the position owner. To withdraw only token0 or only token1, amount0Requested or
    /// amount1Requested may be set to zero. To withdraw all tokens owed, caller may pass any value greater than the
    /// actual tokens owed, e.g. type(uint128).max. Tokens owed may be from accumulated swap fees or burned liquidity.
    /// @param recipient The address which should receive the fees collected
    /// @param tickLower The lower tick of the position for which to collect fees
    /// @param tickUpper The upper tick of the position for which to collect fees
    /// @param amount0Requested How much token0 should be withdrawn from the fees owed
    /// @param amount1Requested How much token1 should be withdrawn from the fees owed
    /// @return amount0 The amount of fees collected in token0
    /// @return amount1 The amount of fees collected in token1
    function collect(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);

    /// @notice Burn liquidity from the sender and account tokens owed for the liquidity to the position
    /// @dev Can be used to trigger a recalculation of fees owed to a position by calling with an amount of 0
    /// @dev Fees must be collected separately via a call to #collect
    /// @param tickLower The lower tick of the position for which to burn liquidity
    /// @param tickUpper The upper tick of the position for which to burn liquidity
    /// @param amount How much liquidity to burn
    /// @return amount0 The amount of token0 sent to the recipient
    /// @return amount1 The amount of token1 sent to the recipient
    function burn(
        int24 tickLower,
        int24 tickUpper,
        uint128 amount
    ) external returns (uint256 amount0, uint256 amount1);

    /// @notice Swap token0 for token1, or token1 for token0
    /// @dev The caller of this method receives a callback in the form of IUniswapV3SwapCallback#uniswapV3SwapCallback
    /// @param recipient The address to receive the output of the swap
    /// @param zeroForOne The direction of the swap, true for token0 to token1, false for token1 to token0
    /// @param amountSpecified The amount of the swap, which implicitly configures the swap as exact input (positive), or exact output (negative)
    /// @param sqrtPriceLimitX96 The Q64.96 sqrt price limit. If zero for one, the price cannot be less than this
    /// value after the swap. If one for zero, the price cannot be greater than this value after the swap
    /// @param data Any data to be passed through to the callback
    /// @return amount0 The delta of the balance of token0 of the pool, exact when negative, minimum when positive
    /// @return amount1 The delta of the balance of token1 of the pool, exact when negative, minimum when positive
    function swap(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata data
    ) external returns (int256 amount0, int256 amount1);

    /// @notice Receive token0 and/or token1 and pay it back, plus a fee, in the callback
    /// @dev The caller of this method receives a callback in the form of IUniswapV3FlashCallback#uniswapV3FlashCallback
    /// @dev Can be used to donate underlying tokens pro-rata to currently in-range liquidity providers by calling
    /// with 0 amount{0,1} and sending the donation amount(s) from the callback
    /// @param recipient The address which will receive the token0 and token1 amounts
    /// @param amount0 The amount of token0 to send
    /// @param amount1 The amount of token1 to send
    /// @param data Any data to be passed through to the callback
    function flash(
        address recipient,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external;

    /// @notice Increase the maximum number of price and liquidity observations that this pool will store
    /// @dev This method is no-op if the pool already has an observationCardinalityNext greater than or equal to
    /// the input observationCardinalityNext.
    /// @param observationCardinalityNext The desired minimum number of observations for the pool to store
    function increaseObservationCardinalityNext(uint16 observationCardinalityNext) external;
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Pool state that is not stored
/// @notice Contains view functions to provide information about the pool that is computed rather than stored on the
/// blockchain. The functions here may have variable gas costs.
interface IUniswapV3PoolDerivedState {
    /// @notice Returns the cumulative tick and liquidity as of each timestamp `secondsAgo` from the current block timestamp
    /// @dev To get a time weighted average tick or liquidity-in-range, you must call this with two values, one representing
    /// the beginning of the period and another for the end of the period. E.g., to get the last hour time-weighted average tick,
    /// you must call it with secondsAgos = [3600, 0].
    /// @dev The time weighted average tick represents the geometric time weighted average price of the pool, in
    /// log base sqrt(1.0001) of token1 / token0. The TickMath library can be used to go from a tick value to a ratio.
    /// @param secondsAgos From how long ago each cumulative tick and liquidity value should be returned
    /// @return tickCumulatives Cumulative tick values as of each `secondsAgos` from the current block timestamp
    /// @return secondsPerLiquidityCumulativeX128s Cumulative seconds per liquidity-in-range value as of each `secondsAgos` from the current block
    /// timestamp
    function observe(uint32[] calldata secondsAgos)
        external
        view
        returns (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s);

    /// @notice Returns a snapshot of the tick cumulative, seconds per liquidity and seconds inside a tick range
    /// @dev Snapshots must only be compared to other snapshots, taken over a period for which a position existed.
    /// I.e., snapshots cannot be compared if a position is not held for the entire period between when the first
    /// snapshot is taken and the second snapshot is taken.
    /// @param tickLower The lower tick of the range
    /// @param tickUpper The upper tick of the range
    /// @return tickCumulativeInside The snapshot of the tick accumulator for the range
    /// @return secondsPerLiquidityInsideX128 The snapshot of seconds per liquidity for the range
    /// @return secondsInside The snapshot of seconds per liquidity for the range
    function snapshotCumulativesInside(int24 tickLower, int24 tickUpper)
        external
        view
        returns (
            int56 tickCumulativeInside,
            uint160 secondsPerLiquidityInsideX128,
            uint32 secondsInside
        );
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Events emitted by a pool
/// @notice Contains all events emitted by the pool
interface IUniswapV3PoolEvents {
    /// @notice Emitted exactly once by a pool when #initialize is first called on the pool
    /// @dev Mint/Burn/Swap cannot be emitted by the pool before Initialize
    /// @param sqrtPriceX96 The initial sqrt price of the pool, as a Q64.96
    /// @param tick The initial tick of the pool, i.e. log base 1.0001 of the starting price of the pool
    event Initialize(uint160 sqrtPriceX96, int24 tick);

    /// @notice Emitted when liquidity is minted for a given position
    /// @param sender The address that minted the liquidity
    /// @param owner The owner of the position and recipient of any minted liquidity
    /// @param tickLower The lower tick of the position
    /// @param tickUpper The upper tick of the position
    /// @param amount The amount of liquidity minted to the position range
    /// @param amount0 How much token0 was required for the minted liquidity
    /// @param amount1 How much token1 was required for the minted liquidity
    event Mint(
        address sender,
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    /// @notice Emitted when fees are collected by the owner of a position
    /// @dev Collect events may be emitted with zero amount0 and amount1 when the caller chooses not to collect fees
    /// @param owner The owner of the position for which fees are collected
    /// @param tickLower The lower tick of the position
    /// @param tickUpper The upper tick of the position
    /// @param amount0 The amount of token0 fees collected
    /// @param amount1 The amount of token1 fees collected
    event Collect(
        address indexed owner,
        address recipient,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount0,
        uint128 amount1
    );

    /// @notice Emitted when a position's liquidity is removed
    /// @dev Does not withdraw any fees earned by the liquidity position, which must be withdrawn via #collect
    /// @param owner The owner of the position for which liquidity is removed
    /// @param tickLower The lower tick of the position
    /// @param tickUpper The upper tick of the position
    /// @param amount The amount of liquidity to remove
    /// @param amount0 The amount of token0 withdrawn
    /// @param amount1 The amount of token1 withdrawn
    event Burn(
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    /// @notice Emitted by the pool for any swaps between token0 and token1
    /// @param sender The address that initiated the swap call, and that received the callback
    /// @param recipient The address that received the output of the swap
    /// @param amount0 The delta of the token0 balance of the pool
    /// @param amount1 The delta of the token1 balance of the pool
    /// @param sqrtPriceX96 The sqrt(price) of the pool after the swap, as a Q64.96
    /// @param liquidity The liquidity of the pool after the swap
    /// @param tick The log base 1.0001 of price of the pool after the swap
    event Swap(
        address indexed sender,
        address indexed recipient,
        int256 amount0,
        int256 amount1,
        uint160 sqrtPriceX96,
        uint128 liquidity,
        int24 tick
    );

    /// @notice Emitted by the pool for any flashes of token0/token1
    /// @param sender The address that initiated the swap call, and that received the callback
    /// @param recipient The address that received the tokens from flash
    /// @param amount0 The amount of token0 that was flashed
    /// @param amount1 The amount of token1 that was flashed
    /// @param paid0 The amount of token0 paid for the flash, which can exceed the amount0 plus the fee
    /// @param paid1 The amount of token1 paid for the flash, which can exceed the amount1 plus the fee
    event Flash(
        address indexed sender,
        address indexed recipient,
        uint256 amount0,
        uint256 amount1,
        uint256 paid0,
        uint256 paid1
    );

    /// @notice Emitted by the pool for increases to the number of observations that can be stored
    /// @dev observationCardinalityNext is not the observation cardinality until an observation is written at the index
    /// just before a mint/swap/burn.
    /// @param observationCardinalityNextOld The previous value of the next observation cardinality
    /// @param observationCardinalityNextNew The updated value of the next observation cardinality
    event IncreaseObservationCardinalityNext(
        uint16 observationCardinalityNextOld,
        uint16 observationCardinalityNextNew
    );

    /// @notice Emitted when the protocol fee is changed by the pool
    /// @param feeProtocol0Old The previous value of the token0 protocol fee
    /// @param feeProtocol1Old The previous value of the token1 protocol fee
    /// @param feeProtocol0New The updated value of the token0 protocol fee
    /// @param feeProtocol1New The updated value of the token1 protocol fee
    event SetFeeProtocol(uint8 feeProtocol0Old, uint8 feeProtocol1Old, uint8 feeProtocol0New, uint8 feeProtocol1New);

    /// @notice Emitted when the collected protocol fees are withdrawn by the factory owner
    /// @param sender The address that collects the protocol fees
    /// @param recipient The address that receives the collected protocol fees
    /// @param amount0 The amount of token0 protocol fees that is withdrawn
    /// @param amount0 The amount of token1 protocol fees that is withdrawn
    event CollectProtocol(address indexed sender, address indexed recipient, uint128 amount0, uint128 amount1);
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Pool state that never changes
/// @notice These parameters are fixed for a pool forever, i.e., the methods will always return the same values
interface IUniswapV3PoolImmutables {
    /// @notice The contract that deployed the pool, which must adhere to the IUniswapV3Factory interface
    /// @return The contract address
    function factory() external view returns (address);

    /// @notice The first of the two tokens of the pool, sorted by address
    /// @return The token contract address
    function token0() external view returns (address);

    /// @notice The second of the two tokens of the pool, sorted by address
    /// @return The token contract address
    function token1() external view returns (address);

    /// @notice The pool's fee in hundredths of a bip, i.e. 1e-6
    /// @return The fee
    function fee() external view returns (uint24);

    /// @notice The pool tick spacing
    /// @dev Ticks can only be used at multiples of this value, minimum of 1 and always positive
    /// e.g.: a tickSpacing of 3 means ticks can be initialized every 3rd tick, i.e., ..., -6, -3, 0, 3, 6, ...
    /// This value is an int24 to avoid casting even though it is always positive.
    /// @return The tick spacing
    function tickSpacing() external view returns (int24);

    /// @notice The maximum amount of position liquidity that can use any tick in the range
    /// @dev This parameter is enforced per tick to prevent liquidity from overflowing a uint128 at any point, and
    /// also prevents out-of-range liquidity from being used to prevent adding in-range liquidity to a pool
    /// @return The max amount of liquidity per tick
    function maxLiquidityPerTick() external view returns (uint128);
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Permissioned pool actions
/// @notice Contains pool methods that may only be called by the factory owner
interface IUniswapV3PoolOwnerActions {
    /// @notice Set the denominator of the protocol's % share of the fees
    /// @param feeProtocol0 new protocol fee for token0 of the pool
    /// @param feeProtocol1 new protocol fee for token1 of the pool
    function setFeeProtocol(uint8 feeProtocol0, uint8 feeProtocol1) external;

    /// @notice Collect the protocol fee accrued to the pool
    /// @param recipient The address to which collected protocol fees should be sent
    /// @param amount0Requested The maximum amount of token0 to send, can be 0 to collect fees in only token1
    /// @param amount1Requested The maximum amount of token1 to send, can be 0 to collect fees in only token0
    /// @return amount0 The protocol fee collected in token0
    /// @return amount1 The protocol fee collected in token1
    function collectProtocol(
        address recipient,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Pool state that can change
/// @notice These methods compose the pool's state, and can change with any frequency including multiple times
/// per transaction
interface IUniswapV3PoolState {
    /// @notice The 0th storage slot in the pool stores many values, and is exposed as a single method to save gas
    /// when accessed externally.
    /// @return sqrtPriceX96 The current price of the pool as a sqrt(token1/token0) Q64.96 value
    /// tick The current tick of the pool, i.e. according to the last tick transition that was run.
    /// This value may not always be equal to SqrtTickMath.getTickAtSqrtRatio(sqrtPriceX96) if the price is on a tick
    /// boundary.
    /// observationIndex The index of the last oracle observation that was written,
    /// observationCardinality The current maximum number of observations stored in the pool,
    /// observationCardinalityNext The next maximum number of observations, to be updated when the observation.
    /// feeProtocol The protocol fee for both tokens of the pool.
    /// Encoded as two 4 bit values, where the protocol fee of token1 is shifted 4 bits and the protocol fee of token0
    /// is the lower 4 bits. Used as the denominator of a fraction of the swap fee, e.g. 4 means 1/4th of the swap fee.
    /// unlocked Whether the pool is currently locked to reentrancy
    function slot0()
        external
        view
        returns (
            uint160 sqrtPriceX96,
            int24 tick,
            uint16 observationIndex,
            uint16 observationCardinality,
            uint16 observationCardinalityNext,
            uint8 feeProtocol,
            bool unlocked
        );

    /// @notice The fee growth as a Q128.128 fees of token0 collected per unit of liquidity for the entire life of the pool
    /// @dev This value can overflow the uint256
    function feeGrowthGlobal0X128() external view returns (uint256);

    /// @notice The fee growth as a Q128.128 fees of token1 collected per unit of liquidity for the entire life of the pool
    /// @dev This value can overflow the uint256
    function feeGrowthGlobal1X128() external view returns (uint256);

    /// @notice The amounts of token0 and token1 that are owed to the protocol
    /// @dev Protocol fees will never exceed uint128 max in either token
    function protocolFees() external view returns (uint128 token0, uint128 token1);

    /// @notice The currently in range liquidity available to the pool
    /// @dev This value has no relationship to the total liquidity across all ticks
    function liquidity() external view returns (uint128);

    /// @notice Look up information about a specific tick in the pool
    /// @param tick The tick to look up
    /// @return liquidityGross the total amount of position liquidity that uses the pool either as tick lower or
    /// tick upper,
    /// liquidityNet how much liquidity changes when the pool price crosses the tick,
    /// feeGrowthOutside0X128 the fee growth on the other side of the tick from the current tick in token0,
    /// feeGrowthOutside1X128 the fee growth on the other side of the tick from the current tick in token1,
    /// tickCumulativeOutside the cumulative tick value on the other side of the tick from the current tick
    /// secondsPerLiquidityOutsideX128 the seconds spent per liquidity on the other side of the tick from the current tick,
    /// secondsOutside the seconds spent on the other side of the tick from the current tick,
    /// initialized Set to true if the tick is initialized, i.e. liquidityGross is greater than 0, otherwise equal to false.
    /// Outside values can only be used if the tick is initialized, i.e. if liquidityGross is greater than 0.
    /// In addition, these values are only relative and must be used only in comparison to previous snapshots for
    /// a specific position.
    function ticks(int24 tick)
        external
        view
        returns (
            uint128 liquidityGross,
            int128 liquidityNet,
            uint256 feeGrowthOutside0X128,
            uint256 feeGrowthOutside1X128,
            int56 tickCumulativeOutside,
            uint160 secondsPerLiquidityOutsideX128,
            uint32 secondsOutside,
            bool initialized
        );

    /// @notice Returns 256 packed tick initialized boolean values. See TickBitmap for more information
    function tickBitmap(int16 wordPosition) external view returns (uint256);

    /// @notice Returns the information about a position by the position's key
    /// @param key The position's key is a hash of a preimage composed by the owner, tickLower and tickUpper
    /// @return _liquidity The amount of liquidity in the position,
    /// Returns feeGrowthInside0LastX128 fee growth of token0 inside the tick range as of the last mint/burn/poke,
    /// Returns feeGrowthInside1LastX128 fee growth of token1 inside the tick range as of the last mint/burn/poke,
    /// Returns tokensOwed0 the computed amount of token0 owed to the position as of the last mint/burn/poke,
    /// Returns tokensOwed1 the computed amount of token1 owed to the position as of the last mint/burn/poke
    function positions(bytes32 key)
        external
        view
        returns (
            uint128 _liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        );

    /// @notice Returns data about a specific observation index
    /// @param index The element of the observations array to fetch
    /// @dev You most likely want to use #observe() instead of this method to get an observation as of some amount of time
    /// ago, rather than at a specific index in the array.
    /// @return blockTimestamp The timestamp of the observation,
    /// Returns tickCumulative the tick multiplied by seconds elapsed for the life of the pool as of the observation timestamp,
    /// Returns secondsPerLiquidityCumulativeX128 the seconds per in range liquidity for the life of the pool as of the observation timestamp,
    /// Returns initialized whether the observation has been initialized and the values are safe to use
    function observations(uint256 index)
        external
        view
        returns (
            uint32 blockTimestamp,
            int56 tickCumulative,
            uint160 secondsPerLiquidityCumulativeX128,
            bool initialized
        );
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.5;

import '@openzeppelin/contracts/token/ERC721/IERC721.sol';

/// @title ERC721 with permit
/// @notice Extension to ERC721 that includes a permit function for signature based approvals
interface IERC721Permit is IERC721 {
    /// @notice The permit typehash used in the permit signature
    /// @return The typehash for the permit
    function PERMIT_TYPEHASH() external pure returns (bytes32);

    /// @notice The domain separator used in the permit signature
    /// @return The domain seperator used in encoding of permit signature
    function DOMAIN_SEPARATOR() external view returns (bytes32);

    /// @notice Approve of a specific token ID for spending by spender via signature
    /// @param spender The account that is being approved
    /// @param tokenId The ID of the token that is being approved for spending
    /// @param deadline The deadline timestamp by which the call must be mined for the approve to work
    /// @param v Must produce valid secp256k1 signature from the holder along with `r` and `s`
    /// @param r Must produce valid secp256k1 signature from the holder along with `v` and `s`
    /// @param s Must produce valid secp256k1 signature from the holder along with `r` and `v`
    function permit(
        address spender,
        uint256 tokenId,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable;
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Immutable state
/// @notice Functions that return immutable state of the router
interface IPeripheryImmutableState {
    /// @return Returns the address of the Uniswap V3 factory
    function factory() external view returns (address);

    /// @return Returns the address of WETH9
    function WETH9() external view returns (address);
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.5;

/// @title Periphery Payments
/// @notice Functions to ease deposits and withdrawals of ETH
interface IPeripheryPayments {
    /// @notice Unwraps the contract's WETH9 balance and sends it to recipient as ETH.
    /// @dev The amountMinimum parameter prevents malicious contracts from stealing WETH9 from users.
    /// @param amountMinimum The minimum amount of WETH9 to unwrap
    /// @param recipient The address receiving ETH
    function unwrapWETH9(uint256 amountMinimum, address recipient) external payable;

    /// @notice Refunds any ETH balance held by this contract to the `msg.sender`
    /// @dev Useful for bundling with mint or increase liquidity that uses ether, or exact output swaps
    /// that use ether for the input amount
    function refundETH() external payable;

    /// @notice Transfers the full amount of a token held by this contract to recipient
    /// @dev The amountMinimum parameter prevents malicious contracts from stealing the token from users
    /// @param token The contract address of the token which will be transferred to `recipient`
    /// @param amountMinimum The minimum amount of token required for a transfer
    /// @param recipient The destination address of the token
    function sweepToken(
        address token,
        uint256 amountMinimum,
        address recipient
    ) external payable;
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.5;
pragma abicoder v2;

/// @title Creates and initializes V3 Pools
/// @notice Provides a method for creating and initializing a pool, if necessary, for bundling with other methods that
/// require the pool to exist.
interface IPoolInitializer {
    /// @notice Creates a new pool if it does not exist, then initializes if not initialized
    /// @dev This method can be bundled with others via IMulticall for the first action (e.g. mint) performed against a pool
    /// @param token0 The contract address of token0 of the pool
    /// @param token1 The contract address of token1 of the pool
    /// @param fee The fee amount of the v3 pool for the specified token pair
    /// @param sqrtPriceX96 The initial square root price of the pool as a Q64.96 value
    /// @return pool Returns the pool address based on the pair of tokens and fee, will return the newly created pool address if necessary
    function createAndInitializePoolIfNecessary(
        address token0,
        address token1,
        uint24 fee,
        uint160 sqrtPriceX96
    ) external payable returns (address pool);
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.5;
pragma abicoder v2;

import '@uniswap/v3-core/contracts/interfaces/callback/IUniswapV3SwapCallback.sol';

/// @title Router token swapping functionality
/// @notice Functions for swapping tokens via Uniswap V3
interface ISwapRouter is IUniswapV3SwapCallback {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps `amountIn` of one token for as much as possible of another token
    /// @param params The parameters necessary for the swap, encoded as `ExactInputSingleParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    /// @notice Swaps `amountIn` of one token for as much as possible of another along the specified path
    /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactInputParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);

    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps as little as possible of one token for `amountOut` of another token
    /// @param params The parameters necessary for the swap, encoded as `ExactOutputSingleParams` in calldata
    /// @return amountIn The amount of the input token
    function exactOutputSingle(ExactOutputSingleParams calldata params) external payable returns (uint256 amountIn);

    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    /// @notice Swaps as little as possible of one token for `amountOut` of another along the specified path (reversed)
    /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactOutputParams` in calldata
    /// @return amountIn The amount of the input token
    function exactOutput(ExactOutputParams calldata params) external payable returns (uint256 amountIn);
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

// Uniswap
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";

// OpenZeppelin
import "@openzeppelin/contracts/utils/math/Math.sol";

/**
 * @notice Adapted Uniswap V3 OracleLibrary computation to be compliant with Solidity 0.8.x and later.
 *
 * Documentation for Auditors:
 *
 * Solidity Version: Updated the Solidity version pragma to ^0.8.0. This change ensures compatibility
 * with Solidity version 0.8.x.
 *
 * Safe Arithmetic Operations: Solidity 0.8.x automatically checks for arithmetic overflows/underflows.
 * Therefore, the code no longer needs to use SafeMath library (or similar) for basic arithmetic operations.
 * This change simplifies the code and reduces the potential for errors related to manual overflow/underflow checking.
 *
 * Overflow/Underflow: With the introduction of automatic overflow/underflow checks in Solidity 0.8.x, the code is inherently
 * safer and less prone to certain types of arithmetic errors.
 *
 * Removal of SafeMath Library: Since Solidity 0.8.x handles arithmetic operations safely, the use of SafeMath library
 * is omitted in this update.
 *
 * Git-style diff for the `consult` function:
 *
 * ```diff
 * function consult(address pool, uint32 secondsAgo)
 *     internal
 *     view
 *     returns (int24 arithmeticMeanTick, uint128 harmonicMeanLiquidity)
 * {
 *     require(secondsAgo != 0, 'BP');
 *
 *     uint32[] memory secondsAgos = new uint32[](2);
 *     secondsAgos[0] = secondsAgo;
 *     secondsAgos[1] = 0;
 *
 *     (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s) =
 *         IUniswapV3Pool(pool).observe(secondsAgos);
 *
 *     int56 tickCumulativesDelta = tickCumulatives[1] - tickCumulatives[0];
 *     uint160 secondsPerLiquidityCumulativesDelta =
 *         secondsPerLiquidityCumulativeX128s[1] - secondsPerLiquidityCumulativeX128s[0];
 *
 * -   arithmeticMeanTick = int24(tickCumulativesDelta / secondsAgo);
 * +   int56 secondsAgoInt56 = int56(uint56(secondsAgo));
 * +   arithmeticMeanTick = int24(tickCumulativesDelta / secondsAgoInt56);
 *     // Always round to negative infinity
 * -   if (tickCumulativesDelta < 0 && (tickCumulativesDelta % secondsAgo != 0)) arithmeticMeanTick--;
 * +   if (tickCumulativesDelta < 0 && (tickCumulativesDelta % secondsAgoInt56 != 0)) arithmeticMeanTick--;
 *
 * -   uint192 secondsAgoX160 = uint192(secondsAgo) * type(uint160).max;
 * +   uint192 secondsAgoUint192 = uint192(secondsAgo);
 * +   uint192 secondsAgoX160 = secondsAgoUint192 * type(uint160).max;
 *     harmonicMeanLiquidity = uint128(secondsAgoX160 / (uint192(secondsPerLiquidityCumulativesDelta) << 32));
 * }
 * ```
 */

/// @title Oracle library
/// @notice Provides functions to integrate with V3 pool oracle
library OracleLibrary {
    /// @notice Calculates time-weighted means of tick and liquidity for a given Uniswap V3 pool
    /// @param pool Address of the pool that we want to observe
    /// @param secondsAgo Number of seconds in the past from which to calculate the time-weighted means
    /// @return arithmeticMeanTick The arithmetic mean tick from (block.timestamp - secondsAgo) to block.timestamp
    /// @return harmonicMeanLiquidity The harmonic mean liquidity from (block.timestamp - secondsAgo) to block.timestamp
    function consult(
        address pool,
        uint32 secondsAgo
    )
    internal
    view
    returns (int24 arithmeticMeanTick, uint128 harmonicMeanLiquidity)
    {
        require(secondsAgo != 0, "BP");

        uint32[] memory secondsAgos = new uint32[](2);
        secondsAgos[0] = secondsAgo;
        secondsAgos[1] = 0;

        (
            int56[] memory tickCumulatives,
            uint160[] memory secondsPerLiquidityCumulativeX128s
        ) = IUniswapV3Pool(pool).observe(secondsAgos);

        int56 tickCumulativesDelta = tickCumulatives[1] - tickCumulatives[0];
        uint160 secondsPerLiquidityCumulativesDelta = secondsPerLiquidityCumulativeX128s[
                    1
            ] - secondsPerLiquidityCumulativeX128s[0];

        // Safe casting of secondsAgo to int56 for division
        int56 secondsAgoInt56 = int56(uint56(secondsAgo));
        arithmeticMeanTick = int24(tickCumulativesDelta / secondsAgoInt56);
        // Always round to negative infinity
        if (
            tickCumulativesDelta < 0 &&
            (tickCumulativesDelta % secondsAgoInt56 != 0)
        ) arithmeticMeanTick--;

        // Safe casting of secondsAgo to uint192 for multiplication
        uint192 secondsAgoUint192 = uint192(secondsAgo);
        harmonicMeanLiquidity = uint128(
            (secondsAgoUint192 * uint192(type(uint160).max)) /
            (uint192(secondsPerLiquidityCumulativesDelta) << 32)
        );
    }

    /// @notice Given a pool, it returns the number of seconds ago of the oldest stored observation
    /// @param pool Address of Uniswap V3 pool that we want to observe
    /// @return secondsAgo The number of seconds ago of the oldest observation stored for the pool
    function getOldestObservationSecondsAgo(
        address pool
    ) internal view returns (uint32 secondsAgo) {
        (
            ,
            ,
            uint16 observationIndex,
            uint16 observationCardinality,
            ,
            ,

        ) = IUniswapV3Pool(pool).slot0();
        require(observationCardinality > 0, "NI");

        (uint32 observationTimestamp, , , bool initialized) = IUniswapV3Pool(
            pool
        ).observations((observationIndex + 1) % observationCardinality);

        // The next index might not be initialized if the cardinality is in the process of increasing
        // In this case the oldest observation is always in index 0
        if (!initialized) {
            (observationTimestamp, , , ) = IUniswapV3Pool(pool).observations(0);
        }

        secondsAgo = uint32(block.timestamp) - observationTimestamp;
    }

    /// @notice Given a tick and a token amount, calculates the amount of token received in exchange
    /// a slightly modified version of the UniSwap library getQuoteAtTick to accept a sqrtRatioX96 as input parameter
    /// @param sqrtRatioX96 The sqrt ration
    /// @param baseAmount Amount of token to be converted
    /// @param baseToken Address of an ERC20 token contract used as the baseAmount denomination
    /// @param quoteToken Address of an ERC20 token contract used as the quoteAmount denomination
    /// @return quoteAmount Amount of quoteToken received for baseAmount of baseToken
    function getQuoteForSqrtRatioX96(
        uint160 sqrtRatioX96,
        uint256 baseAmount,
        address baseToken,
        address quoteToken
    ) internal pure returns (uint256 quoteAmount) {
        // Calculate quoteAmount with better precision if it doesn't overflow when multiplied by itself
        if (sqrtRatioX96 <= type(uint128).max) {
            uint256 ratioX192 = uint256(sqrtRatioX96) * sqrtRatioX96;
            quoteAmount = baseToken < quoteToken
                ? Math.mulDiv(ratioX192, baseAmount, 1 << 192)
                : Math.mulDiv(1 << 192, baseAmount, ratioX192);
        } else {
            uint256 ratioX128 = Math.mulDiv(
                sqrtRatioX96,
                sqrtRatioX96,
                1 << 64
            );
            quoteAmount = baseToken < quoteToken
                ? Math.mulDiv(ratioX128, baseAmount, 1 << 128)
                : Math.mulDiv(1 << 128, baseAmount, ratioX128);
        }
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

/**
 * @notice Adapted Uniswap V3 pool address computation to be compliant with Solidity 0.8.x and later.
 * @dev Changes were made to address the stricter type conversion rules in newer Solidity versions.
 *      Original Uniswap V3 code directly converted a uint256 to an address, which is disallowed in Solidity 0.8.x.
 *      Adaptation Steps:
 *        1. The `pool` address is computed by first hashing pool parameters.
 *        2. The resulting `uint256` hash is then explicitly cast to `uint160` before casting to `address`.
 *           This two-step conversion process is necessary due to the Solidity 0.8.x restriction.
 *           Direct conversion from `uint256` to `address` is disallowed to prevent mistakes
 *           that can occur due to the size mismatch between the types.
 *        3. Added a require statement to ensure `token0` is less than `token1`, maintaining
 *           Uniswap's invariant and preventing pool address calculation errors.
 * @param factory The Uniswap V3 factory contract address.
 * @param key The PoolKey containing token addresses and fee tier.
 * @return pool The computed address of the Uniswap V3 pool.
 * @custom:modification Explicit type conversion from `uint256` to `uint160` then to `address`.
 *
 * function computeAddress(address factory, PoolKey memory key) internal pure returns (address pool) {
 *     require(key.token0 < key.token1);
 *     pool = address(
 *         uint160( // Explicit conversion to uint160 added for compatibility with Solidity 0.8.x
 *             uint256(
 *                 keccak256(
 *                     abi.encodePacked(
 *                         hex'ff',
 *                         factory,
 *                         keccak256(abi.encode(key.token0, key.token1, key.fee)),
 *                         POOL_INIT_CODE_HASH
 *                     )
 *                 )
 *             )
 *         )
 *     );
 * }
 */

/// @dev This code is copied from Uniswap V3 which uses an older compiler version.
/// @title Provides functions for deriving a pool address from the factory, tokens, and the fee
library PoolAddress {
    bytes32 internal constant POOL_INIT_CODE_HASH =
        0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54;

    /// @notice The identifying key of the pool
    struct PoolKey {
        address token0;
        address token1;
        uint24 fee;
    }

    /// @notice Returns PoolKey: the ordered tokens with the matched fee levels
    /// @param tokenA The first token of a pool, unsorted
    /// @param tokenB The second token of a pool, unsorted
    /// @param fee The fee level of the pool
    /// @return Poolkey The pool details with ordered token0 and token1 assignments
    function getPoolKey(
        address tokenA,
        address tokenB,
        uint24 fee
    ) internal pure returns (PoolKey memory) {
        if (tokenA > tokenB) (tokenA, tokenB) = (tokenB, tokenA);
        return PoolKey({token0: tokenA, token1: tokenB, fee: fee});
    }

    /// @notice Deterministically computes the pool address given the factory and PoolKey
    /// @param factory The Uniswap V3 factory contract address
    /// @param key The PoolKey
    /// @return pool The contract address of the V3 pool
    function computeAddress(
        address factory,
        PoolKey memory key
    ) internal pure returns (address pool) {
        require(key.token0 < key.token1);
        pool = address(
            uint160( // Convert uint256 to uint160 first
                uint256(
                    keccak256(
                        abi.encodePacked(
                            hex"ff",
                            factory,
                            keccak256(
                                abi.encode(key.token0, key.token1, key.fee)
                            ),
                            POOL_INIT_CODE_HASH
                        )
                    )
                )
            )
        );
    }
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

/**
 * @notice Adapted Uniswap V3 TickMath library computation to be compliant with Solidity 0.8.x and later.
 *
 * Documentation for Auditors:
 *
 * Solidity Version: Updated the Solidity version pragma to ^0.8.0. This change ensures compatibility
 * with Solidity version 0.8.x.
 *
 * Safe Arithmetic Operations: Solidity 0.8.x automatically checks for arithmetic overflows/underflows.
 * Therefore, the code no longer needs to use the SafeMath library (or similar) for basic arithmetic operations.
 * This change simplifies the code and reduces the potential for errors related to manual overflow/underflow checking.
 *
 * Explicit Type Conversion: The explicit conversion of `MAX_TICK` from `int24` to `uint256` in the `require` statement
 * is safe and necessary for comparison with `absTick`, which is a `uint256`. This conversion is compliant with
 * Solidity 0.8.x's type system and does not introduce any arithmetic risk.
 *
 * Overflow/Underflow: With the introduction of automatic overflow/underflow checks in Solidity 0.8.x, the code is inherently
 * safer and less prone to certain types of arithmetic errors.
 *
 * Removal of SafeMath Library: Since Solidity 0.8.x handles arithmetic operations safely, the use of the SafeMath library
 * is omitted in this update.
 *
 * Git-style diff for the TickMath library:
 *
 * ```diff
 * - pragma solidity >=0.5.0 <0.8.0;
 * + pragma solidity ^0.8.0;
 *
 *   function getSqrtRatioAtTick(int24 tick) internal pure returns (uint160 sqrtPriceX96) {
 *       uint256 absTick = tick < 0 ? uint256(-int256(tick)) : uint256(int256(tick));
 * -     require(absTick <= uint256(MAX_TICK), 'T');
 * +     require(absTick <= uint256(int256(MAX_TICK)), 'T'); // Explicit type conversion for Solidity 0.8.x compatibility
 *       // ... (rest of the function)
 *   }
 *
 * function getTickAtSqrtRatio(
 *     uint160 sqrtPriceX96
 * ) internal pure returns (int24 tick) {
 *     // [Code for calculating the tick based on sqrtPriceX96 remains unchanged]
 *
 * -   tick = tickLow == tickHi
 * -       ? tickLow
 * -       : getSqrtRatioAtTick(tickHi) <= sqrtPriceX96
 * -       ? tickHi
 * -       : tickLow;
 * +   if (tickLow == tickHi) {
 * +       tick = tickLow;
 * +   } else {
 * +       tick = (getSqrtRatioAtTick(tickHi) <= sqrtPriceX96) ? tickHi : tickLow;
 * +   }
 * }
 * ```
 *
 * Note: Other than the pragma version change and the explicit type conversion in the `require` statement, the original functions
 * within the TickMath library are compatible with Solidity 0.8.x without requiring any further modifications. This is due to
 * the fact that the logic within these functions already adheres to safe arithmetic practices and does not involve operations
 * that would be affected by the 0.8.x compiler's built-in checks.
 */

/// @title Math library for computing sqrt prices from ticks and vice versa
/// @notice Computes sqrt price for ticks of size 1.0001, i.e. sqrt(1.0001^tick) as fixed point Q64.96 numbers. Supports
/// prices between 2**-128 and 2**128
library TickMath {
    /// @dev The minimum tick that may be passed to #getSqrtRatioAtTick computed from log base 1.0001 of 2**-128
    int24 internal constant MIN_TICK = -887272;
    /// @dev The maximum tick that may be passed to #getSqrtRatioAtTick computed from log base 1.0001 of 2**128
    int24 internal constant MAX_TICK = -MIN_TICK;

    /// @dev The minimum value that can be returned from #getSqrtRatioAtTick. Equivalent to getSqrtRatioAtTick(MIN_TICK)
    uint160 internal constant MIN_SQRT_RATIO = 4295128739;
    /// @dev The maximum value that can be returned from #getSqrtRatioAtTick. Equivalent to getSqrtRatioAtTick(MAX_TICK)
    uint160 internal constant MAX_SQRT_RATIO =
    1461446703485210103287273052203988822378723970342;

    /// @notice Calculates sqrt(1.0001^tick) * 2^96
    /// @dev Throws if |tick| > max tick
    /// @param tick The input tick for the above formula
    /// @return sqrtPriceX96 A Fixed point Q64.96 number representing the sqrt of the ratio of the two assets (token1/token0)
    /// at the given tick
    function getSqrtRatioAtTick(
        int24 tick
    ) internal pure returns (uint160 sqrtPriceX96) {
        uint256 absTick = tick < 0
            ? uint256(-int256(tick))
            : uint256(int256(tick));
        require(absTick <= uint256(int256(MAX_TICK)), "T"); // Explicit type conversion for Solidity 0.8.x compatibility

        uint256 ratio = absTick & 0x1 != 0
            ? 0xfffcb933bd6fad37aa2d162d1a594001
            : 0x100000000000000000000000000000000;
        if (absTick & 0x2 != 0)
            ratio = (ratio * 0xfff97272373d413259a46990580e213a) >> 128;
        if (absTick & 0x4 != 0)
            ratio = (ratio * 0xfff2e50f5f656932ef12357cf3c7fdcc) >> 128;
        if (absTick & 0x8 != 0)
            ratio = (ratio * 0xffe5caca7e10e4e61c3624eaa0941cd0) >> 128;
        if (absTick & 0x10 != 0)
            ratio = (ratio * 0xffcb9843d60f6159c9db58835c926644) >> 128;
        if (absTick & 0x20 != 0)
            ratio = (ratio * 0xff973b41fa98c081472e6896dfb254c0) >> 128;
        if (absTick & 0x40 != 0)
            ratio = (ratio * 0xff2ea16466c96a3843ec78b326b52861) >> 128;
        if (absTick & 0x80 != 0)
            ratio = (ratio * 0xfe5dee046a99a2a811c461f1969c3053) >> 128;
        if (absTick & 0x100 != 0)
            ratio = (ratio * 0xfcbe86c7900a88aedcffc83b479aa3a4) >> 128;
        if (absTick & 0x200 != 0)
            ratio = (ratio * 0xf987a7253ac413176f2b074cf7815e54) >> 128;
        if (absTick & 0x400 != 0)
            ratio = (ratio * 0xf3392b0822b70005940c7a398e4b70f3) >> 128;
        if (absTick & 0x800 != 0)
            ratio = (ratio * 0xe7159475a2c29b7443b29c7fa6e889d9) >> 128;
        if (absTick & 0x1000 != 0)
            ratio = (ratio * 0xd097f3bdfd2022b8845ad8f792aa5825) >> 128;
        if (absTick & 0x2000 != 0)
            ratio = (ratio * 0xa9f746462d870fdf8a65dc1f90e061e5) >> 128;
        if (absTick & 0x4000 != 0)
            ratio = (ratio * 0x70d869a156d2a1b890bb3df62baf32f7) >> 128;
        if (absTick & 0x8000 != 0)
            ratio = (ratio * 0x31be135f97d08fd981231505542fcfa6) >> 128;
        if (absTick & 0x10000 != 0)
            ratio = (ratio * 0x9aa508b5b7a84e1c677de54f3e99bc9) >> 128;
        if (absTick & 0x20000 != 0)
            ratio = (ratio * 0x5d6af8dedb81196699c329225ee604) >> 128;
        if (absTick & 0x40000 != 0)
            ratio = (ratio * 0x2216e584f5fa1ea926041bedfe98) >> 128;
        if (absTick & 0x80000 != 0)
            ratio = (ratio * 0x48a170391f7dc42444e8fa2) >> 128;

        if (tick > 0) ratio = type(uint256).max / ratio;

        // this divides by 1<<32 rounding up to go from a Q128.128 to a Q128.96.
        // we then downcast because we know the result always fits within 160 bits due to our tick input constraint
        // we round up in the division so getTickAtSqrtRatio of the output price is always consistent
        sqrtPriceX96 = uint160(
            (ratio >> 32) + (ratio % (1 << 32) == 0 ? 0 : 1)
        );
    }

    /// @notice Calculates the greatest tick value such that getRatioAtTick(tick) <= ratio
    /// @dev Throws in case sqrtPriceX96 < MIN_SQRT_RATIO, as MIN_SQRT_RATIO is the lowest value getRatioAtTick may
    /// ever return.
    /// @param sqrtPriceX96 The sqrt ratio for which to compute the tick as a Q64.96
    /// @return tick The greatest tick for which the ratio is less than or equal to the input ratio
    function getTickAtSqrtRatio(
        uint160 sqrtPriceX96
    ) internal pure returns (int24 tick) {
        // second inequality must be < because the price can never reach the price at the max tick
        require(
            sqrtPriceX96 >= MIN_SQRT_RATIO && sqrtPriceX96 < MAX_SQRT_RATIO,
            "R"
        );
        uint256 ratio = uint256(sqrtPriceX96) << 32;

        uint256 r = ratio;
        uint256 msb = 0;

        assembly {
            let f := shl(7, gt(r, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(6, gt(r, 0xFFFFFFFFFFFFFFFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(5, gt(r, 0xFFFFFFFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(4, gt(r, 0xFFFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(3, gt(r, 0xFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(2, gt(r, 0xF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(1, gt(r, 0x3))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := gt(r, 0x1)
            msb := or(msb, f)
        }

        if (msb >= 128) r = ratio >> (msb - 127);
        else r = ratio << (127 - msb);

        int256 log_2 = (int256(msb) - 128) << 64;

        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(63, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(62, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(61, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(60, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(59, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(58, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(57, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(56, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(55, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(54, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(53, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(52, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(51, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(50, f))
        }

        int256 log_sqrt10001 = log_2 * 255738958999603826347141; // 128.128 number

        int24 tickLow = int24(
            (log_sqrt10001 - 3402992956809132418596140100660247210) >> 128
        );
        int24 tickHi = int24(
            (log_sqrt10001 + 291339464771989622907027621153398088495) >> 128
        );

        // Adjusted logic for determining the tick
        if (tickLow == tickHi) {
            tick = tickLow;
        } else {
            tick = (getSqrtRatioAtTick(tickHi) <= sqrtPriceX96)
                ? tickHi
                : tickLow;
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC2612.sol";

interface IFeeToken is IERC20 {
    /**
     * @dev Sends tokens directly to the Fee Staking contract
     * @param _sender The address of the token sender
     * @param _amount The amount of tokens to send
     */
    function sendToFeeStaking(address _sender, uint _amount) external;

    /**
     * @dev Mints new tokens
     * @param account The address that will receive the minted tokens
     * @param amount The amount of tokens to mint
     */
    function mint(address account, uint amount) external;

    /**
     * @dev Burns tokens
     * @param amount The amount of tokens to burn
     */
    function burn(uint amount) external;

    /**
     * @dev Returns the supply of the token which is mintable via the Minter
     * @return The base supply amount
     */
    function minterSupply() external view returns (uint);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

/**
 * @title IFeeTokenMinter
 * @dev Interface for the FeeTokenMinter contract, responsible for managing vesting entries on behalf of other system components
 */
interface IFeeTokenMinter {
    /**
     * @dev Appends a new vesting entry for an account
     * @param account The address of the account to receive the vested tokens
     * @param quantity The amount of tokens to be vested
     */
    function appendVestingEntry(address account, uint256 quantity) external;
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import "@uniswap/v3-periphery/contracts/interfaces/IPoolInitializer.sol";
import "@uniswap/v3-periphery/contracts/interfaces/IPeripheryPayments.sol";
import "@uniswap/v3-periphery/contracts/interfaces/IPeripheryImmutableState.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@uniswap/v3-periphery/contracts/interfaces/IERC721Permit.sol";

/**
 * @notice A subset of the Uniswap Interface to allow
 * using latest openzeppelin contracts
 */
interface INonfungiblePositionManager is
    IPoolInitializer,
    IPeripheryPayments,
    IPeripheryImmutableState,
    IERC721Metadata,
    IERC721Enumerable,
    IERC721Permit {

    // Structs for mint and collect functions
    struct MintParams {
        address token0;
        address token1;
        uint24 fee;
        int24 tickLower;
        int24 tickUpper;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        address recipient;
        uint256 deadline;
    }

    struct CollectParams {
        uint256 tokenId;
        address recipient;
        uint128 amount0Max;
        uint128 amount1Max;
    }

    function createAndInitializePoolIfNecessary(
        address token0,
        address token1,
        uint24 fee,
        uint160 sqrtPriceX96
    ) external payable returns (address pool);

    function mint(MintParams calldata params) external payable returns (
        uint256 tokenId,
        uint128 liquidity,
        uint256 amount0,
        uint256 amount1
    );

    function collect(CollectParams calldata params) external payable returns (uint256 amount0, uint256 amount1);
}
pragma solidity 0.8.21;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "../../interfaces/IFeeToken.sol";
import "../../common/uniswap/PoolAddress.sol";
import "../../common/uniswap/Oracle.sol";
import "../../common/uniswap/TickMath.sol";
import "../../interfaces/INonfungiblePositionManager.sol";
import "../../interfaces/IFeeTokenMinter.sol";
import "@openzeppelin/contracts/utils/Address.sol";

/**
 Token Minting Process State Diagram:

 stateDiagram-v2
    [*] --> PreLaunch: ORX Minter Deployment
    PreLaunch --> Launched: LaunchBlock Reached
    Launched --> TitanXDeposited: User Deposits TitanX
    Launched --> EthContributionReceived: User Contributes ETH
    TitanXDeposited --> CalculatingReturn: Calculate ORX Return
    EthContributionReceived --> EthQueuePeriod: Enter 14-day Queue
    EthQueuePeriod --> EthDripCreated: Queue Period Ends
    CalculatingReturn --> VestingCreated: Create Vesting Entry
    VestingCreated --> Vesting: Start Vesting Period
    EthDripCreated --> EthCliffPeriod: Start 21-day Cliff Period
    EthCliffPeriod --> EthVesting: Cliff Period Ends
    Vesting --> ClaimRequested: User Requests to Claim
    EthVesting --> EthDripClaimRequested: User Requests to Claim Dripped ORX
    ClaimRequested --> CalculatingClaimable: Calculate Claimable Amount
    EthDripClaimRequested --> CalculatingDrippedAmount: Calculate Dripped ORX Amount
    CalculatingClaimable --> TokensStaged: ORX Staged for 3 Days
    CalculatingDrippedAmount --> DrippedTokensMinted: Dripped ORX Minted Immediately
    TokensStaged --> TokensClaimed: User Claims ORX After 3 Days
    DrippedTokensMinted --> EthVesting: Continue Vesting
    TokensClaimed --> [*]: Vesting Complete
    EthVesting --> [*]: All ORX Vested (12 weeks total)

    Vesting --> NukeRequested: User Requests Nuke (Before 28 Days)
    NukeRequested --> Forfeited: User Confirms Nuke
    Forfeited --> [*]: All ORX Sent to Forfeit Sink

    state CalculatingReturn {
        [*] --> FixedRate: Total TitanX Deposits < Fixed Rate Threshold
        [*] --> MixedRate: Total TitanX Deposits Crosses Fixed Rate Threshold
        [*] --> CurveRate: Total TitanX Deposits > Fixed Rate Threshold
        FixedRate --> [*]: Return Fixed Rate Amount
        MixedRate --> [*]: Return Fixed Rate Amount + Curve-Based Amount
        CurveRate --> [*]: Return Curve-Based Amount
    }

    state CalculatingClaimable {
        [*] --> FullAmount: After Vesting Period
        [*] --> PartialAmount: During Vesting Period (After 28 Days)
        [*] --> ZeroAmount: Before 28 Days
        FullAmount --> [*]: Return Full Amount
        PartialAmount --> [*]: Return Partial Amount
        ZeroAmount --> [*]: Return Zero (Require Nuke Confirmation)
    }

    state CalculatingDrippedAmount {
        [*] --> DrippedFullAmount: After Vesting Period (12 weeks)
        [*] --> DrippedPartialAmount: During Vesting Period (After Cliff)
        [*] --> DrippedZeroAmount: During Cliff Period (21 days)
        DrippedFullAmount --> [*]: Return Remaining Amount
        DrippedPartialAmount --> [*]: Return Vested Amount
        DrippedZeroAmount --> [*]: Return Zero
    }
 */

/**
 * @title FeeTokenMinter
 * @dev Contract for minting/vesting FeeTokens in exchange for deposits. Also manages token buybacks and a locked LP.
 *
 *  Key features:
 *      1. Token Issuance: Hybrid initial fixed-rate with transition to curve-based model for FeeToken minting.
 *                         A small % of supply is given to Ethereum contributions.
 *      2. Deposit Vesting: 52-week vesting schedule with one-time claim and early claim forfeit system. Vesting massively tail weighted.
 *      3. ETH Contribution Vesting: 12-week vesting schedule with a 21-day cliff period for ETH contributors. Progressive linear drip release.
 *      4. Referral System: Bonus rewards for referrers. 2% additional tokens minted if referrer is present.
 *      5. Locked Liquidity: Uniswap V3 integration for liquidity and buybacks.
 *      6. Buyback Mechanism: Purchases and burns FeeTokens in either a public incentivised manner, or permissioned manner which is not incentivised.
 *      7. Incentive Programs: Supports external backstop and LP incentives vesting schedules, but reserves the right to cancel them.
 *      8. Control Functions: Functions for parameter adjustments and management within hardcoded parameter ranges.
 */
contract FeeTokenMinter is Ownable, IFeeTokenMinter, ReentrancyGuard {
    //==================================================================//
    //---------------------- LAUNCH PARAMETERS -------------------------//
    //==================================================================//
    /// @dev Deposit Token contribution vesting period
    uint public constant DEPOSIT_VESTING_PERIOD = 52 weeks;

    /// @dev Deposit Token contribution cliff period
    uint public constant DEPOSIT_VESTING_CLIFF_DURATION = 28 days;

    /// @dev ETH contribution vesting period
    uint public constant CONTRIBUTION_VESTING_PERIOD = 12 weeks;

    /// @dev ETH contribution cliff period
    uint public constant ETH_CONTRIBUTION_CLIFF_DURATION = 21 days;

    /// @dev Amount of time ETH will be allowed to stage during launch phase. (Rough approximation)
    uint public constant ETH_LAUNCH_PHASE_TIME = 14 days;

    //==================================================================//
    //-------------------------- CONSTANTS -----------------------------//
    //==================================================================//

    /// @dev Timestamp when the contract was deployed
    uint public immutable DEPLOYMENT_TIMESTAMP;

    /// @dev Block when the contract was deployed
    uint public immutable DEPLOYMENT_BLOCK;

    /// @dev Block number at which the contract is considered launched and deposits, eth contributions, and incentive vests can be triggered.
    uint public immutable LAUNCH_BLOCK;

    /// @dev Rough approximation of launch timestamp.
    uint public immutable LAUNCH_TIMESTAMP;

    /// @dev Approx share of fee token supply which is available at a fixed rate expressed as a percentage
    uint public constant FEE_TOKEN_AVAILABLE_AT_FIXED_DEPOSIT_RATE = 250_000_000e18;

    /// @dev Approx deposits at fixed rate. How many deposit token before we transition to curve emissions.
    uint public constant TOTAL_DEPOSITS_AT_FIXED_RATE = 1_500_000_000_000e18;

    /// @dev Initial fixed deposit rate before curve kicks in.
    /// Calculated by TOTAL_DEPOSITS_AT_FIXED_RATE / FEE_TOKEN_AVAILABLE_AT_FIXED_DEPOSIT_RATE
    uint public immutable FIXED_RATE_FOR_DEPOSIT_TOKEN;

    /// @dev Higher number implies more liquid virtual pair for x*y=k curve
    uint private constant CURVE_RATE_INCREASE_WEIGHT = 6_000_000_000_000e18;

    /// @dev Rate for ETH contributions.  Implies 369eth * 135502 == 50,000,000~ Fee Token for Eth emissions
    uint public constant ETH_RATE = 135502;

    /// @dev Fee tier for Uniswap V3 pool (1%)
    uint24 public constant POOL_FEE = 10000;

    /// @dev Minimum tick for Uniswap V3 position (full range)
    int24 public constant MIN_TICK = -887200;

    /// @dev Maximum tick for Uniswap V3 position (full range)
    int24 public constant MAX_TICK = 887200;

    /// @dev Initial LP price if token0 is occupied by the deposit token
    int24 public constant INITIAL_TICK_IF_DEPOSIT_TOKEN_IS_TOKEN0 = -120244;

    /// @dev Initial LP price if token0 is occupied by the fee token
    int24 public constant INITIAL_TICK_IF_FEE_TOKEN_IS_TOKEN0 = -INITIAL_TICK_IF_DEPOSIT_TOKEN_IS_TOKEN0;

    /// @dev Initial input to LP for Fee Token
    uint public constant INITIAL_FEE_TOKEN_LIQUIDITY_AMOUNT = 600_000e18;

    /// @dev Initial input to LP for Deposit Token
    uint public constant INITIAL_DEPOSIT_TOKEN_LIQUIDITY_AMOUNT = 100_000_000_000e18;

    /// @dev Address where forfeited tokens are sent. Ideally a multisig.
    address public immutable FORFEIT_SINK;

    /// @dev Address where ETH is sent. Ideally a multisig for slow LP management release and dev reward.
    address public immutable ETH_SINK;

    /// @dev Approximate block production time, doesn't need to be exact
    uint private constant TIME_PER_BLOCK_PRODUCTION = 12 seconds;

    //==================================================================//
    //-------------------------- INTERFACES ----------------------------//
    //==================================================================//

    /// @dev Interface for Uniswap V3 SwapRouter
    ISwapRouter public immutable router;

    /// @dev Interface for Uniswap V3 NonfungiblePositionManager
    INonfungiblePositionManager public immutable positionManager;

    /// @dev Interface for Uniswap V3 Pool
    IUniswapV3Pool public pool;

    /// @dev Interface for the deposit token
    IERC20 public immutable depositToken;

    /// @dev Interface for the FeeToken
    IFeeToken public immutable feeToken;

    //==================================================================//
    //----------------------- STATE VARIABLES --------------------------//
    //==================================================================//

    /// @dev Flag indicating if the Uniswap pool has been created
    bool public uniPoolInitialised;

    /// @dev Cooldown period between buybacks
    uint public buybackCooldownPeriod = 15 minutes;

    /// @dev Reward bips which is sent to buyback caller when buyback mode is Public
    uint public incentiveFeeBips = 300;

    /// @dev Timestamp of the last buyback/burn
    uint public lastBuyback;

    /// @dev Address for backstop incentives
    address public backstopIncentives;

    /// @dev Address for LP incentives
    address public lpIncentives;

    /// @dev Remaining ETH emissions cap
    uint public remainingCappedEthEmissions = 369 ether;

    /// @dev Available emissions for deposits
    uint public availableCurveEmissionsForDepositToken;

    /// @dev Flag indicating if the curve mechanism is active
    bool public curveActive = true;

    /// @dev Flag indicating if the backstop deposit farm is active
    bool public backstopFarmActive = true; // we assume true, even though another part of the system controls emissions

    /// @dev Flag indicating if the LP farm is active
    bool public lpFarmActive = true; // we assume true, even though another part of the system controls emissions

    /// @dev Maximum future FeeTokens from deposits
    uint public maxFutureFeeTokensFromDeposits;

    /// @dev Currently vesting FeeTokens
    uint public currentlyVestingFeeTokens;

    /// @dev Total deposited amount
    uint public totalDeposited;

    /// @dev Total staged amount waiting to unlock in the 3 day window
    uint public totalStaged;

    /// @dev Total forfeited supply
    uint public forfeitedSupply;

    /// @dev Duration in minutes for TWAP calculation
    uint32 public twapDurationMins = 15;

    /// @dev X value for curve calculations
    uint internal _x;

    /// @dev Y value for curve calculations
    uint internal _y;

    /// @dev K value for curve calculations (x * y = k)
    uint internal _k;

    /// @dev Generator for unique vest IDs
    uint public vestIdGenerator = 1;

    /// @dev Generator for unique drip IDs
    uint public dripIdGenerator = 1;

    /// @dev Cap per swap for buybacks
    uint public capPerSwap = 1_000_000_000e18;

    /// @dev Current buyback mode (Public or Private)
    BuybackMode public buybackMode = BuybackMode.Private;

    /// @dev Slippage percentage for swaps
    uint public slippagePCT = 5;

    /// @dev Total depositToken used for buy and burns
    uint public totalDepositTokenUsedForBuyAndBurns;

    /// @dev Total FeeTokens burned
    uint public totalFeeTokensBurned;

    //==================================================================//
    //--------------------------- STRUCTS ------------------------------//
    //==================================================================//

    /// @dev Structure to hold deposit vesting entry details
    struct VestingEntry {
        address owner;
        uint64 endTime;
        uint startTime;
        uint escrowAmount;
        uint vested;
        uint forfeit;
        uint deposit;
        uint duration;
        address referrer;
        bool isValid;
        uint stagedStart;
        uint stagedAmount;
    }

    /// @dev Structure to hold ETH contribution vesting entry details
    struct DripEntry {
        address contributor;
        uint contributionAmount;
        uint64 endTime;
        uint startTime;
        uint amount;
        uint vested;
        bool isValid;
    }

    /// @dev Structure to hold token information for Uniswap V3 position
    struct TokenInfo {
        uint tokenId;
        uint128 liquidity;
        int24 tickLower;
        int24 tickUpper;
        bool initialized;
    }

    //==================================================================//
    //-------------------------- MAPPINGS ------------------------------//
    //==================================================================//

    /// @dev Mapping of account addresses to their vesting entries
    mapping(address => mapping(uint => VestingEntry)) public vests;

    /// @dev Mapping of account addresses to their vesting FeeToken drips
    mapping(address => mapping(uint => DripEntry)) public drips;

    /// @dev Mapping of account addresses to their drip IDs
    mapping(address => uint[]) public accountDripIDs;

    /// @dev Mapping of vest IDs to their owners
    mapping(uint => address) public vestToVestOwnerIfHasReferrer;

    /// @dev Mapping of account addresses to their vesting IDs
    mapping(address => uint[]) public accountVestingIDs;

    /// @dev Mapping of referrer addresses to their total referrals
    mapping(address => uint) public totalReferrals;

    /// @dev Mapping of referrer addresses to their total referral rewards
    mapping(address => uint) public totalReferralRewards;

    /// @dev Mapping of referrer addresses to their referral vesting IDs
    mapping(address => uint[]) public referralVestingIDs;

    /// @dev Mapping of account addresses to their deposited amounts
    mapping(address => uint) public deposited;

    /// @dev Mapping of account addresses to their vesting amounts
    mapping(address => uint) public vesting;

    //==================================================================//
    //------------------------- PUBLIC VARS ----------------------------//
    //==================================================================//

    /// @dev Public variable to store token information
    TokenInfo public tokenInfo;

    //==================================================================//
    //--------------------------- ENUMS --------------------------------//
    //==================================================================//

    /// @dev Enum to represent buyback modes
    enum BuybackMode {Public, Private}

    //==================================================================//
    //--------------------------- EVENTS -------------------------------//
    //==================================================================//

    event VestStarted(address indexed beneficiary, uint value, uint duration, uint entryID, address referrer);
    event TokensStaged(address indexed beneficiary, uint value, uint availableTime);
    event EthContributed(address indexed contributor, uint256 ethAmount, uint256 feeTokenAmount, uint256 vestId);
    event DripClaimed(address indexed claimer, uint256 indexed vestId, uint256 amount);
    event Buyback(address indexed caller, uint swapInput, uint feeTokensBought, uint amountOutMinimum, uint incentiveFee, BuybackMode buybackMode, uint slippagePCT);
    event LiquidityAdded(uint initialDepositTokenSupplyInput, uint initialFeeTokenSupplyInput);
    event LPUnlocked();
    event CurveTerminated();
    event BackstopDepositFarmTerminated();
    event LPFarmTerminated();
    event Deposit(address indexed account, uint deposit, address referrer, uint mintableFeeTokens);
    event VestClaimed(address indexed account, uint vestId, uint vested, uint forfeit);
    event StagedTokensClaimed(address indexed account, uint vestId, uint amount);

    // Custom Errors
    error NotYetLaunched();
    error CurveClosed();
    error ZeroValueTransaction();
    error NoFurtherEthAllocation();
    error CannotDepositZero();
    error FailedToTransferDepositToken();
    error DepositResultsInZeroFeeTokensMinted();
    error LPNotInitialized();
    error OnlyCallableByOwnerDuringPrivateMode();
    error OnlyCallableByEOA();
    error BuybackCooldownNotRespected();
    error BuybackEmpty();
    error InvalidDripId();
    error AllTokensAlreadyDripped();
    error InvalidVestId();
    error ClaimAlreadyVested();
    error ClaimingBeforeMinimumPeriod();
    error NoTokensToClaim();
    error TokensNotYetClaimable();
    error VestDoesNotExist();

    //==================================================================//
    //------------------------- CONSTRUCTOR ----------------------------//
    //==================================================================//

    /**
     * @dev Constructor to initialize the FeeTokenMinter contract
     * @param _depositToken Address of the deposit token
     * @param _feeToken Address of the FeeToken token
     * @param _forfeitSink Address where forfeited tokens are sent
     * @param _ethSink Address where ETH contributions are sent
     * @param _swapRouter Address of the Uniswap V3 SwapRouter
     * @param _nonfungiblePositionManager Address of the Uniswap V3 NonfungiblePositionManager
     * @param _backstopIssuance Address for backstop issuance
     * @param _lpIncentives Address for LP issuance
     * @param _launchBlock Block number at which the contract is considered launched
     */
    constructor(
        address _depositToken,
        address _feeToken,
        address _forfeitSink,
        address _ethSink,
        address _swapRouter,
        address _nonfungiblePositionManager,
        address _backstopIssuance,
        address _lpIncentives,
        uint _launchBlock
    ) {
        require(_depositToken != address(0), "_depositToken is null");
        require(_feeToken != address(0), "_feeToken is null");
        require(_forfeitSink != address(0), "_forfeitSink is null");
        require(_ethSink != address(0), "_ethSink is null");
        require(_swapRouter != address(0), "_swapRouter is null");
        require(_nonfungiblePositionManager != address(0), "_nonfungiblePositionManager is null");
        require(_backstopIssuance != address(0), "_backstopIssuance is null");
        require(_lpIncentives != address(0), "_lpIncentives is null");

        DEPLOYMENT_TIMESTAMP = block.timestamp;
        DEPLOYMENT_BLOCK = block.number;

        LAUNCH_BLOCK = _launchBlock;
        LAUNCH_TIMESTAMP = ((LAUNCH_BLOCK - DEPLOYMENT_BLOCK) * TIME_PER_BLOCK_PRODUCTION) + DEPLOYMENT_TIMESTAMP;

        depositToken = IERC20(_depositToken);
        feeToken = IFeeToken(_feeToken);
        router = ISwapRouter(_swapRouter);
        positionManager = INonfungiblePositionManager(_nonfungiblePositionManager);
        FORFEIT_SINK = _forfeitSink;
        ETH_SINK = _ethSink;

        // these addresses will have ability to add token vests for incentive farms if activated elsewhere in the system
        backstopIncentives = _backstopIssuance;
        lpIncentives = _lpIncentives;

        // amount of fee token which can be emitted at a fixed Eth rate
        uint availableEmissionsForEth = remainingCappedEthEmissions * ETH_RATE;

        // amount of fee tokens which will be available in aggregate across curve emissions and fixed rate
        availableCurveEmissionsForDepositToken = feeToken.minterSupply() - availableEmissionsForEth;

        // initial fee tokens rewarded for deposit token come out at a fixed rate
        FIXED_RATE_FOR_DEPOSIT_TOKEN = TOTAL_DEPOSITS_AT_FIXED_RATE / FEE_TOKEN_AVAILABLE_AT_FIXED_DEPOSIT_RATE;

        _x = CURVE_RATE_INCREASE_WEIGHT;
        _y = availableCurveEmissionsForDepositToken;
        _k = _x * _y;
    }

    /// @dev There is no valid case for renouncing ownership
    function renounceOwnership() public override onlyOwner {
        revert();
    }

    //==================================================================//
    //-------------------------- MODIFIERS -----------------------------//
    //==================================================================//

    /// @dev Modifier to check if the curve mechanism is active
    modifier curveIsActive {
        if (!curveActive) revert CurveClosed();
        _;
    }

    /// @dev Modifier to restrict access to incentive contracts
    modifier onlyIncentives {
        require((msg.sender == backstopIncentives) || (msg.sender == lpIncentives));
        _;
    }

    /// @dev Modifier to ensure function is only callable after launch
    modifier afterLaunch {
        if (LAUNCH_BLOCK > block.number) revert NotYetLaunched();
        _;
    }

    //==================================================================//
    //----------------------- ADMIN FUNCTIONS --------------------------//
    //==================================================================//

    /**
     * @dev Sets the reward for triggering ORX buybacks when buyback mode is Public
     * @param bips New percentage reward in basis points
     */
    function setBuybackIncentiveBips(uint bips) external onlyOwner {
        require(bips >= 100 && bips <= 1000);
        incentiveFeeBips = bips;
    }

    /**
     * @dev Sets the interval for ORX buybacks
     * @param secs New interval in seconds
     */
    function setBuybackCooldownInterval(uint secs) external onlyOwner {
        require(secs >= 15 minutes && secs <= 1 days);
        buybackCooldownPeriod = secs;
    }

    /**
     * @dev Sets the duration for TWAP calculation
     * @param min New duration in minutes
     */
    function setTwapDurationMins(uint32 min) external onlyOwner {
        require(min >= 5 && min <= 60);
        twapDurationMins = min;
    }

    /**
     * @dev Sets the cap for auto swap
     * @param amount New cap amount
     */
    function setCapPerAutoSwap(uint amount) external onlyOwner {
        require(amount >= 1e18 && amount <= 500_000_000_000e18);
        capPerSwap = amount;
    }

    /**
     * @dev Sets the buyback mode
     * @param mode New buyback mode
     */
    function setBuybackMode(BuybackMode mode) external onlyOwner {
        // not doing input validation, as external call reverts if out of enum range
        buybackMode = mode;
    }

    /**
     * @dev Sets the slippage percentage
     * @param amount New slippage percentage
     */
    function setSlippage(uint amount) external onlyOwner {
        require(amount >= 1 && amount <= 50);
        slippagePCT = amount;
    }

    /**
     * @dev Terminates the curve mechanism
     */
    function terminateCurve() external onlyOwner {
        require(curveActive);
        curveActive = false;
        emit CurveTerminated();
    }

    /**
     * @dev Terminates the backstop deposit farm
     */
    function terminateBackstopDepositFarm() external onlyOwner {
        require(backstopFarmActive);
        backstopFarmActive = false;
        emit BackstopDepositFarmTerminated();
    }

    /**
     * @dev Terminates the LP farm
     */
    function terminateLPFarm() external onlyOwner {
        require(lpFarmActive);
        lpFarmActive = false;
        emit LPFarmTerminated();
    }

    /**
     * @dev Mints the initial position in the Uniswap V3 pool
     */
    function mintInitialPosition() external onlyOwner {
        require(!uniPoolInitialised);

        (address token0, address token1, uint amount0Desired, uint amount1Desired, int24 initialTick) =
                        _getPoolConfig();

        pool = IUniswapV3Pool(
            positionManager.createAndInitializePoolIfNecessary(
                token0,
                token1,
                POOL_FEE,
                TickMath.getSqrtRatioAtTick(initialTick)
            )
        );

        pool.increaseObservationCardinalityNext(100);

        INonfungiblePositionManager.MintParams memory params = INonfungiblePositionManager.MintParams({
            token0: token0,
            token1: token1,
            fee: POOL_FEE,
            tickLower: MIN_TICK,
            tickUpper: MAX_TICK,
            amount0Desired: amount0Desired,
            amount1Desired: amount1Desired,
            amount0Min: (amount0Desired * 90) / 100,
            amount1Min: (amount1Desired * 90) / 100,
            recipient: address(this),
            deadline: block.timestamp + 600
        });

        feeToken.mint(address(this), INITIAL_FEE_TOKEN_LIQUIDITY_AMOUNT);
        feeToken.approve(address(positionManager), INITIAL_FEE_TOKEN_LIQUIDITY_AMOUNT);
        depositToken.approve(address(positionManager), INITIAL_DEPOSIT_TOKEN_LIQUIDITY_AMOUNT);

        (uint tokenId, uint128 liquidity,,) =
                                INonfungiblePositionManager(address(positionManager)).mint(params);

        tokenInfo.tokenId = uint80(tokenId);
        tokenInfo.liquidity = uint128(liquidity);
        tokenInfo.tickLower = MIN_TICK;
        tokenInfo.tickUpper = MAX_TICK;
        uniPoolInitialised = true;
    }

    /**
     * @dev Collects fees from the Uniswap V3 position
     */
    function collectFees() external onlyOwner {
        require(uniPoolInitialised);
        address feeTokenAddress_ = address(feeToken);
        address depositTokenAddress_ = address(depositToken);

        (uint amount0, uint amount1) = _collectFees();

        uint feeTokenAmount;
        uint depositTokenAmount;

        if (feeTokenAddress_ < depositTokenAddress_) {
            feeTokenAmount = amount0;
            depositTokenAmount = amount1;
        } else {
            depositTokenAmount = amount0;
            feeTokenAmount = amount1;
        }

        totalFeeTokensBurned += feeTokenAmount;
        feeToken.burn(feeTokenAmount);
    }

    //==================================================================//
    //----------------- EXTERNAL MUTATIVE FUNCTIONS --------------------//
    //==================================================================//

    function contributeEth() external payable afterLaunch nonReentrant {
        if (msg.value == 0) revert ZeroValueTransaction();
        if (remainingCappedEthEmissions == 0) revert NoFurtherEthAllocation();

        uint contributionAmount = msg.value;
        uint refund;

        if (msg.value > remainingCappedEthEmissions) {
            contributionAmount = remainingCappedEthEmissions;
            refund = msg.value - contributionAmount;
        }

        uint feeTokenAmount = contributionAmount * ETH_RATE;
        remainingCappedEthEmissions -= contributionAmount;

        uint ethContributionId = dripIdGenerator;
        dripIdGenerator++;

        uint beginTime = (block.timestamp < (LAUNCH_TIMESTAMP + ETH_LAUNCH_PHASE_TIME)) ?
            LAUNCH_TIMESTAMP :
            block.timestamp;

        drips[msg.sender][ethContributionId] = DripEntry({
            contributor: msg.sender,
            endTime: uint64(beginTime + CONTRIBUTION_VESTING_PERIOD),
            startTime: uint64(beginTime),
            amount: feeTokenAmount,
            contributionAmount: contributionAmount,
            vested: 0,
            isValid: true
        });

        accountDripIDs[msg.sender].push(ethContributionId);
        currentlyVestingFeeTokens += feeTokenAmount;

        Address.sendValue(payable(ETH_SINK), contributionAmount);

        if (refund > 0) {
            Address.sendValue(payable(msg.sender), refund);
        }

        emit EthContributed(msg.sender, contributionAmount, feeTokenAmount, ethContributionId);
    }

    /**
     * @dev Allows users to deposit tokens and start vesting
     * @param _deposit Amount of tokens to deposit
     * @param referredBy Address of the referrer
     */
    function deposit(uint _deposit, address referredBy) external curveIsActive afterLaunch {
        if (_deposit == 0) revert CannotDepositZero();
        if (!depositToken.transferFrom(msg.sender, address(this), _deposit)) revert FailedToTransferDepositToken();

        (uint mintableFeeTokens, uint newX, uint newY) = calculateReturn(_deposit);
        if (mintableFeeTokens == 0) revert DepositResultsInZeroFeeTokensMinted();

        _y = newY;
        _x = newX;

        deposited[msg.sender] += _deposit;
        totalDeposited += _deposit;
        maxFutureFeeTokensFromDeposits += mintableFeeTokens;
        currentlyVestingFeeTokens += mintableFeeTokens;

        _appendVestingEntry(msg.sender, mintableFeeTokens, referredBy, DEPOSIT_VESTING_PERIOD, _deposit);
        emit Deposit(msg.sender, _deposit, referredBy, mintableFeeTokens);
    }

    /**
     * @dev Performs a buyback of FeeTokens
     * @return amountOut The amount of FeeTokens bought back
     */
    function buyback() external nonReentrant returns (uint amountOut) {
        if (!uniPoolInitialised) revert LPNotInitialized();
        if (buybackMode == BuybackMode.Private && msg.sender != owner()) revert OnlyCallableByOwnerDuringPrivateMode();

        if (msg.sender != tx.origin) revert OnlyCallableByEOA();
        if ((block.timestamp - lastBuyback) < buybackCooldownPeriod) revert BuybackCooldownNotRespected();

        lastBuyback = block.timestamp;

        uint amountIn = depositToken.balanceOf(address(this));
        uint buyCap = capPerSwap;
        if (amountIn > buyCap) {
            amountIn = buyCap;
        }

        uint256 incentiveFee;
        if (buybackMode == BuybackMode.Private) {
            incentiveFee = 0;
        } else {
            incentiveFee = (amountIn * incentiveFeeBips) / 10_000;
            amountIn -= incentiveFee;
            require(depositToken.transfer(msg.sender, incentiveFee), "Inc transfer error");
        }

        if (amountIn == 0) revert BuybackEmpty();

        depositToken.approve(address(router), amountIn);
        uint amountOutMinimum = calculateMinimumFeeTokenAmount(amountIn);

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: address(depositToken),
            tokenOut: address(feeToken),
            fee: POOL_FEE,
            recipient: address(this),
            deadline: block.timestamp + 1,
            amountIn: amountIn,
            amountOutMinimum: amountOutMinimum,
            sqrtPriceLimitX96: 0
        });

        amountOut = router.exactInputSingle(params);

        feeToken.burn(amountOut);

        totalDepositTokenUsedForBuyAndBurns += amountIn;
        totalFeeTokensBurned += amountOut;

        emit Buyback(msg.sender, amountIn, amountOut, amountOutMinimum, incentiveFee, buybackMode, slippagePCT);
    }

    /**
    * @dev Allows users to claim vested FeeTokens from their ETH contribution
    * @param dripId ID of the ETH contribution (drip)
    * @return dripped Amount of FeeTokens claimed
    */
    function drip(uint dripId) external returns (uint dripped) {
        DripEntry storage contribution = drips[msg.sender][dripId];

        if (!contribution.isValid) revert InvalidDripId();
        if (contribution.amount <= contribution.vested) revert AllTokensAlreadyDripped();

        uint claimableAmount = calculatePendingDrip(msg.sender, dripId);
        contribution.vested = contribution.vested + claimableAmount;
        dripped = claimableAmount;
        currentlyVestingFeeTokens -= dripped;
        if (dripped > 0) {
            feeToken.mint(msg.sender, claimableAmount);
            emit DripClaimed(msg.sender, dripId, claimableAmount);
        }
    }

    /**
     * @dev Allows users to vest their tokens
     * @param vestId ID of the vesting entry to vest
     */
    function vest(uint vestId, bool allowNuke) external {
        VestingEntry storage entry = vests[msg.sender][vestId];

        if (!entry.isValid) revert InvalidVestId();
        if (entry.escrowAmount == 0) revert ClaimAlreadyVested();

        (uint vested, uint forfeit) = _claimableVest(entry);
        if (vested == 0 && !allowNuke) revert ClaimingBeforeMinimumPeriod();

        currentlyVestingFeeTokens -= entry.escrowAmount;
        vesting[msg.sender] -= entry.escrowAmount;
        entry.escrowAmount = 0;
        entry.vested = vested;
        entry.forfeit = forfeit;

        if (forfeit != 0) {
            forfeitedSupply += forfeit;
            feeToken.mint(FORFEIT_SINK, forfeit);
        }

        if (vested != 0) {
            entry.stagedStart = block.timestamp;
            entry.stagedAmount = vested;
            totalStaged += vested;
            emit TokensStaged(msg.sender, vested, block.timestamp + 3 days);

            if (entry.referrer != address(0)) {
                uint referralBonus = (vested * 2) / 100; // 2%
                totalStaged += referralBonus;
                emit TokensStaged(entry.referrer, referralBonus, block.timestamp + 3 days);
            }
        }

        emit VestClaimed(msg.sender, vestId, vested, forfeit);
    }

    /**
     * @dev Allows users to claim their staged tokens
     * @param vestId ID of the vesting entry to claim staged tokens from
     */
    function claimStagedTokens(uint vestId) public {
        VestingEntry storage entry = vests[msg.sender][vestId];
        if (!entry.isValid) revert InvalidVestId();
        if (entry.stagedAmount == 0) revert NoTokensToClaim();
        if (block.timestamp < entry.stagedStart + 3 days) revert TokensNotYetClaimable();

        uint amount = entry.stagedAmount;
        entry.stagedAmount = 0;

        totalStaged -= amount;

        if (entry.referrer != address(0)) {
            uint referralBonus = (amount * 2) / 100; // 2%
            totalStaged -= referralBonus;
            totalReferralRewards[entry.referrer] += referralBonus;
            feeToken.mint(entry.referrer, referralBonus);
            emit StagedTokensClaimed(entry.referrer, vestId, referralBonus);
        }

        feeToken.mint(msg.sender, amount);

        emit StagedTokensClaimed(msg.sender, vestId, amount);
    }

    /**
     * @dev Appends a vesting entry for an account (only callable by incentive contracts)
     * @param account Address of the account to receive the vested tokens
     * @param quantity Amount of tokens to vest
     */
    function appendVestingEntry(address account, uint quantity) external override onlyIncentives {
        bool shouldReward =
            (msg.sender == lpIncentives && lpFarmActive) ||
            (msg.sender == backstopIncentives && backstopFarmActive);

        if (shouldReward && (block.number >= LAUNCH_BLOCK)) {
            currentlyVestingFeeTokens += quantity;
            _appendVestingEntry(account, quantity, address(0), DEPOSIT_VESTING_PERIOD, 0);
        }
    }

    //==================================================================//
    //---------------------- INTERNAL FUNCTIONS ------------------------//
    //==================================================================//

    /**
     * @dev Appends a vesting entry
     * @param account Address of the account to receive the vested tokens
     * @param quantity Amount of tokens to vest
     * @param referrer Address of the referrer
     * @param duration Duration of the vesting period
     * @param _deposit Amount of tokens deposited
     */
    function _appendVestingEntry(address account, uint quantity, address referrer, uint duration, uint _deposit) internal {
        uint vestId = vestIdGenerator;
        vestIdGenerator++;
        uint endTime = block.timestamp + duration;
        vesting[account] += quantity;

        vests[account][vestId] = VestingEntry({
            owner: account,
            endTime: uint64(endTime),
            startTime: uint64(block.timestamp),
            deposit: _deposit,
            escrowAmount: quantity,
            vested: 0,
            forfeit: 0,
            duration: duration,
            referrer: referrer,
            isValid: true,
            stagedStart: 0,
            stagedAmount: 0
        });

        if (referrer != address(0)) {
            totalReferrals[referrer]++;
            vestToVestOwnerIfHasReferrer[vestId] = account;
            referralVestingIDs[referrer].push(vestId);
        }

        accountVestingIDs[account].push(vestId);
        emit VestStarted(account, quantity, duration, vestId, referrer);
    }

    /**
     * @dev Calculates the claimable amount for a vesting entry
     * @param _entry The vesting entry to calculate for
     * @return vested The amount of tokens vested
     * @return forfeit The amount of tokens forfeited
     */
    function _claimableVest(VestingEntry memory _entry) internal view returns (uint vested, uint forfeit) {
        uint escrowAmount = _entry.escrowAmount;

        if (escrowAmount == 0) {
            return (0, 0); // Already fully claimed
        }

        uint timeElapsed = block.timestamp - _entry.startTime;
        uint halfDuration = _entry.duration / 2;

        if (block.timestamp >= _entry.endTime) {
            return (escrowAmount, 0); // Full amount claimable after end time
        } else if (timeElapsed < DEPOSIT_VESTING_CLIFF_DURATION) {
            return (0, escrowAmount); // Nothing claimable in first 28 days
        } else if (timeElapsed <= halfDuration) {
            // Slow linear increase up to 10% for the first half of the term
            uint maxFirstHalfVested = escrowAmount * 10 / 100;
            vested = maxFirstHalfVested * timeElapsed / halfDuration;
        } else {
            // Exponential increase for the second half of the term
            uint secondHalfElapsed = timeElapsed - halfDuration;
            uint secondHalfDuration = _entry.duration - halfDuration;

            // It's ok that second half initially vests slower than linear vest, because it makes up for it on tail end.
            uint exponentialFactor = ((secondHalfElapsed ** 2) * 1e18) / (secondHalfDuration ** 2);
            uint maxSecondHalfVested = escrowAmount - (escrowAmount * 10 / 100);
            vested = (escrowAmount * 10 / 100) + ((maxSecondHalfVested * exponentialFactor) / 1e18);
        }

        forfeit = escrowAmount - vested;
        return (vested, forfeit);
    }

    /**
     * @dev Gets the token configuration for pool initialization
     * @return token0 Address of token0
     * @return token1 Address of token1
     * @return amount0 Amount of token0
     * @return amount1 Amount of token1
     */
    function _getPoolConfig()
    private view returns (address token0, address token1, uint amount0, uint amount1, int24 tick) {
        address feeTokenAddress_ = address(feeToken);
        address depositTokenAddress_ = address(depositToken);

        if (feeTokenAddress_ < depositTokenAddress_) {
            token0 = feeTokenAddress_;
            amount0 = INITIAL_FEE_TOKEN_LIQUIDITY_AMOUNT;
            token1 = depositTokenAddress_;
            amount1 = INITIAL_DEPOSIT_TOKEN_LIQUIDITY_AMOUNT;
            tick = INITIAL_TICK_IF_FEE_TOKEN_IS_TOKEN0;
        } else {
            token0 = depositTokenAddress_;
            amount0 = INITIAL_DEPOSIT_TOKEN_LIQUIDITY_AMOUNT;
            token1 = feeTokenAddress_;
            amount1 = INITIAL_FEE_TOKEN_LIQUIDITY_AMOUNT;
            tick = INITIAL_TICK_IF_DEPOSIT_TOKEN_IS_TOKEN0;
        }
    }

    /**
     * @dev Collects fees from the Uniswap V3 position
     * @return amount0 Amount of token0 collected
     * @return amount1 Amount of token1 collected
     */
    function _collectFees() private returns (uint amount0, uint amount1) {
        (amount0, amount1) = positionManager.collect(INonfungiblePositionManager.CollectParams({
            tokenId: tokenInfo.tokenId,
            recipient: address(this),
            amount0Max: type(uint128).max,
            amount1Max: type(uint128).max
        }));
    }

    //==================================================================//
    //----------------- PUBLIC/EXTERNAL VIEW FUNCTIONS -----------------//
    //==================================================================//

    /**
     * @dev Calculates the FeeToken return for a given ETH amount
     * @param amount Amount of ETH
     * @return The calculated FeeToken return
     */
    function calculateEthReturn(uint amount) external view returns (uint) {
        if (amount == 0) {
            return 0;
        } else if (amount >= remainingCappedEthEmissions) {
            return remainingCappedEthEmissions * ETH_RATE;
        } else {
            return amount * ETH_RATE;
        }
    }

    /**
    * @dev Calculates the amount of FeeTokens available to claim from an ETH contribution
    * @param owner Address of the ETH contributor
    * @param dripId ID of the ETH contribution (drip)
    * @return claimableAmount Amount of FeeTokens available to claim
    */
    function calculatePendingDrip(address owner, uint dripId) public view returns (uint256 claimableAmount) {
        DripEntry storage _drip = drips[owner][dripId];
        if (!_drip.isValid || _drip.amount <= _drip.vested) {
            return 0;
        }

        uint256 currentTime = block.timestamp;
        uint256 startTime = uint256(_drip.startTime);
        uint256 endTime = uint256(_drip.endTime);
        uint256 cliffDuration = ETH_CONTRIBUTION_CLIFF_DURATION;

        if (currentTime >= endTime) {
            claimableAmount = _drip.amount - _drip.vested;
        } else if (currentTime <= startTime + cliffDuration) {
            claimableAmount = 0;
        } else {
            uint256 vestingDuration = endTime - startTime - cliffDuration;
            uint256 timeVested = currentTime - startTime - cliffDuration;
            claimableAmount = ((((_drip.amount * 1e18) * timeVested) / vestingDuration) / 1e18) - _drip.vested;
        }
    }

    /**
     * @dev Calculates the return for a given token input
     * @param tokenIn Amount of tokens to input
     * @return emittableFeeTokens Amount of FeeToken that can be emitted
     * @return newX New X value after the calculation
     * @return newY New Y value after the calculation
     */
    function calculateReturn(uint tokenIn) public view returns (uint emittableFeeTokens, uint newX, uint newY) {
        if (totalDeposited >= TOTAL_DEPOSITS_AT_FIXED_RATE) {
            newX = _x + tokenIn;
            newY = _k / newX;
            emittableFeeTokens = _y - newY;
        } else if ((totalDeposited + tokenIn) <= TOTAL_DEPOSITS_AT_FIXED_RATE) {
            emittableFeeTokens = tokenIn / FIXED_RATE_FOR_DEPOSIT_TOKEN;
            // Still update the curve, because we want it to be higher than the fixed rate by the time it kicks in.
            newX = _x;
            newY = _y;
        } else {
            uint curveRatePortion = (totalDeposited + tokenIn) - TOTAL_DEPOSITS_AT_FIXED_RATE;
            uint fixedRatePortion = tokenIn - curveRatePortion;
            newX = _x + curveRatePortion;
            newY = _k / newX;
            emittableFeeTokens = _y - newY;
            emittableFeeTokens += fixedRatePortion / FIXED_RATE_FOR_DEPOSIT_TOKEN;
        }
    }

    /**
     * @dev Gets the claimable amount for a specific vesting entry
     * @param user Address of the user
     * @param vestId ID of the vesting entry
     * @return quantity Amount claimable
     * @return forfeit Amount to be forfeited
     */
    function getVestingEntryClaimable(address user, uint vestId) external view returns (uint quantity, uint forfeit) {
        VestingEntry memory entry = vests[user][vestId];
        if (!entry.isValid) revert VestDoesNotExist();
        (quantity, forfeit) = _claimableVest(entry);
    }

    /**
     * @dev Calculates the minimum FeeToken amount for a given input amount
     * @param amountIn Input amount
     * @return amountOutMinimum Minimum output amount
     */
    function calculateMinimumFeeTokenAmount(uint amountIn) public view returns (uint amountOutMinimum) {
        uint slippage_ = slippagePCT;
        uint expectedFeeTokenAmount = getFeeTokenQuoteForDepositToken(amountIn);
        amountOutMinimum = (expectedFeeTokenAmount * (100 - slippage_)) / 100;
    }

    /**
     * @dev Gets a quote for token swap
     * @param tokenIn Address of input token
     * @param tokenOut Address of output token
     * @param amountIn Amount of input token
     * @param secondsAgo Number of seconds ago for the TWAP
     * @return amountOut Quoted output amount
     */
    function getQuote(address tokenIn, address tokenOut, uint amountIn, uint32 secondsAgo) public view returns (uint amountOut) {
        address poolAddress = PoolAddress.computeAddress(
            address(positionManager.factory()),
            PoolAddress.getPoolKey(tokenIn, tokenOut, POOL_FEE)
        );

        uint32 oldestObservation = OracleLibrary.getOldestObservationSecondsAgo(poolAddress);
        if (oldestObservation < secondsAgo) {
            secondsAgo = oldestObservation;
        }

        uint160 sqrtPriceX96;
        if (secondsAgo == 0) {
            IUniswapV3Pool uniPool = IUniswapV3Pool(poolAddress);
            (sqrtPriceX96,,,,,,) = uniPool.slot0();
        } else {
            (int24 arithmeticMeanTick,) = OracleLibrary.consult(poolAddress, secondsAgo);
            sqrtPriceX96 = TickMath.getSqrtRatioAtTick(arithmeticMeanTick);
        }

        return OracleLibrary.getQuoteForSqrtRatioX96(sqrtPriceX96, amountIn, tokenIn, tokenOut);
    }

    /**
     * @dev Gets a quote for FeeToken in terms of deposit token
     * @param baseAmount Amount of deposit token
     * @return quote Quoted amount of FeeToken
     */
    function getFeeTokenQuoteForDepositToken(uint baseAmount) public view returns (uint quote) {
        return getQuote(address(depositToken), address(feeToken), baseAmount, twapDurationMins * 60);
    }

    //==================================================================//
    //-------------- EXTERNAL VIEW FUNCTIONS FOR UI --------------------//
    //==================================================================//

    /**
     * @dev Struct to represent a vesting entry with additional information
     */
    struct External_VestingEntry {
        address owner;
        uint64 endTime;
        uint startTime;
        uint escrowAmount;
        uint vested;
        uint forfeit;
        uint deposit;
        uint duration;
        address referrer;
        bool isValid;
        uint stagedStart;
        uint stagedAmount;

        uint vestId;
        uint currentVest;
        uint currentForfeit;
    }

    /**
     * @dev Struct to represent a drip entry with additional information
     */
    struct External_DripEntry {
        address contributor;
        uint64 endTime;
        uint startTime;
        uint amount;
        uint contributionAmount;
        uint vested;
        bool isValid;

        uint dripId;
        uint claimable;
    }

    /**
     * @dev Returns accountVestingId's as array for account
     * @param account The account to lookup
     * @return vestingIds array
     */
    function getAccountVestingIDs(address account) external view returns (uint[] memory) {
        return accountVestingIDs[account];
    }

    /**
     * @dev Returns referralVestingId's as array for account
     * @param account The account to lookup
     * @return referralVestingIds array
     */
    function getReferralVestingIDs(address account) external view returns (uint[] memory) {
        return referralVestingIDs[account];
    }

    /**
     * @dev Gets the total number of ETH vesting entries for an account
     * @param account Address of the account
     * @return The total number of ETH vesting entries
     */
    function getTotalEthContributions(address account) external view returns (uint) {
        return accountDripIDs[account].length;
    }

    /**
     * @dev Gets the total number of vesting entries for an account
     * @param account Address of the account
     * @return The total number of vesting entries
     */
    function getTotalVestingEntries(address account) external view returns (uint) {
        return accountVestingIDs[account].length;
    }

    /**
     * @dev Gets the total number of referral entries for an account
     * @param account Address of the account
     * @return The total number of referral entries
     */
    function getTotalReferralEntries(address account) external view returns (uint) {
        return referralVestingIDs[account].length;
    }

    /**
     * @dev Gets a paginated list of vesting entries for an account
     * @param account Address of the account
     * @param startIdx Starting index for pagination
     * @param count Number of entries to return
     * @return entries An array of External_VestingEntry structs
     */
    function getVestingEntries(address account, uint startIdx, uint count) external view returns (External_VestingEntry[] memory entries) {
        uint totalVests = accountVestingIDs[account].length;

        if (startIdx >= totalVests) {
            // Paged to the end.
            return entries;
        }

        uint endIdx = startIdx + count;
        if (endIdx > totalVests) {
            endIdx = totalVests;
        }

        entries = new External_VestingEntry[](endIdx - startIdx);

        for (uint i = startIdx; i < endIdx; i++) {
            uint vestId = accountVestingIDs[account][i];
            VestingEntry memory _vest = vests[account][vestId];
            (uint vested, uint forfeit) = _claimableVest(_vest);

            entries[i - startIdx] = External_VestingEntry({
                vestId: vestId,
                owner: _vest.owner,
                endTime: _vest.endTime,
                startTime: _vest.startTime,
                escrowAmount: _vest.escrowAmount,
                vested: _vest.vested,
                forfeit: _vest.forfeit,
                deposit: _vest.deposit,
                duration: _vest.duration,
                referrer: _vest.referrer,
                isValid: _vest.isValid,
                stagedStart: _vest.stagedStart,
                stagedAmount: _vest.stagedAmount,
                currentVest: vested,
                currentForfeit: forfeit
            });
        }
    }

    /**
    * @dev Gets a paginated list of drip entries for an account
    * @param account Address of the account
    * @param startIdx Starting index for pagination
    * @param count Number of entries to return
    * @return entries An array of External_DripEntry structs
    */
    function getDripEntries(address account, uint startIdx, uint count) external view returns (External_DripEntry[] memory entries) {
        uint totalVests = accountDripIDs[account].length;

        if (startIdx >= totalVests) {
            return entries;
        }

        uint endIdx = startIdx + count;
        if (endIdx > totalVests) {
            endIdx = totalVests;
        }

        entries = new External_DripEntry[](endIdx - startIdx);

        for (uint i = startIdx; i < endIdx; i++) {
            uint dripId = accountDripIDs[account][i];
            DripEntry memory _drip = drips[account][dripId];
            uint claimable = calculatePendingDrip(account, dripId);

            entries[i - startIdx] = External_DripEntry({
                contributor: _drip.contributor,
                endTime: _drip.endTime,
                startTime: _drip.startTime,
                amount: _drip.amount,
                contributionAmount: _drip.contributionAmount,
                vested: _drip.vested,
                isValid: _drip.isValid,
                dripId: dripId,
                claimable: claimable
            });
        }
    }

    /**
     * @dev Gets a paginated list of referral entries for an account
     * @param account Address of the account
     * @param startIdx Starting index for pagination
     * @param count Number of entries to return
     * @return entries An array of External_VestingEntry structs
     */
    function getReferralEntries(address account, uint startIdx, uint count) external view returns (External_VestingEntry[] memory entries) {
        uint totalRefs = referralVestingIDs[account].length;

        if (startIdx >= totalRefs) {
            // Paged to the end.
            return entries;
        }

        uint endIdx = startIdx + count;
        if (endIdx > totalRefs) {
            endIdx = totalRefs;
        }

        entries = new External_VestingEntry[](endIdx - startIdx);

        for (uint i = startIdx; i < endIdx; i++) {
            uint vestId = referralVestingIDs[account][i];
            VestingEntry memory _vest = vests[vestToVestOwnerIfHasReferrer[vestId]][vestId];
            (uint vested, uint forfeit) = _claimableVest(_vest);

            entries[i - startIdx] = External_VestingEntry({
                vestId: vestId,
                owner: _vest.owner,
                endTime: _vest.endTime,
                startTime: _vest.startTime,
                escrowAmount: _vest.escrowAmount,
                vested: _vest.vested,
                forfeit: _vest.forfeit,
                deposit: _vest.deposit,
                duration: _vest.duration,
                referrer: _vest.referrer,
                isValid: _vest.isValid,
                stagedStart: _vest.stagedStart,
                stagedAmount: _vest.stagedAmount,
                currentVest: vested,
                currentForfeit: forfeit
            });
        }
    }
}