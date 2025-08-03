// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

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
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
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

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

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
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/cryptography/MerkleProof.sol)

pragma solidity ^0.8.0;

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
 * the merkle tree could be reinterpreted as a leaf value.
 * OpenZeppelin's JavaScript library generates merkle trees that are safe
 * against this attack out of the box.
 */
library MerkleProof {
    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     */
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    /**
     * @dev Calldata version of {verify}
     *
     * _Available since v4.7._
     */
    function verifyCalldata(
        bytes32[] calldata proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProofCalldata(proof, leaf) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merkle tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leafs & pre-images are assumed to be sorted.
     *
     * _Available since v4.4._
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
     *
     * _Available since v4.7._
     */
    function processProofCalldata(bytes32[] calldata proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Returns true if the `leaves` can be simultaneously proven to be a part of a merkle tree defined by
     * `root`, according to `proof` and `proofFlags` as described in {processMultiProof}.
     *
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
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
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
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
     * CAUTION: Not all merkle trees admit multiproofs. To use multiproofs, it is sufficient to ensure that: 1) the tree
     * is complete (but not necessarily perfect), 2) the leaves to be proven are in the opposite order they are in the
     * tree (i.e., as seen from right to left starting at the deepest layer and continuing at the next layer).
     *
     * _Available since v4.7._
     */
    function processMultiProof(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuild the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        require(leavesLen + proof.length - 1 == totalHashes, "MerkleProof: invalid multiproof");

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value for the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i] ? leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++] : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            return hashes[totalHashes - 1];
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    /**
     * @dev Calldata version of {processMultiProof}.
     *
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
     */
    function processMultiProofCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuild the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        require(leavesLen + proof.length - 1 == totalHashes, "MerkleProof: invalid multiproof");

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value for the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i] ? leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++] : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            return hashes[totalHashes - 1];
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {
        return a < b ? _efficientHash(a, b) : _efficientHash(b, a);
    }

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
//                                                                       %%
//             .@@@@@@@@@         @@@@@@     @@@@@@@@@@@@@@@@@@@   @@@@@@@@@@@@@@
//            @@@@@@@@@@@(       @@@@@@@    .@@@@@@@@@@@@@@@@@@@ @@@@@@@@@@@@@@@@@
//          @@@@@@@@@@@@@@      @@@@@@@           @@@@@@@       (@@@@@@     @@@@@@
//         @@@@@@@ @@@@@@@     @@@@@@@           @@@@@@@         @@@@@@@@@@@
//       @@@@@@@   @@@@@@@     @@@@@@            @@@@@@           @@@@@@@@@@@@@@
//      @@@@@@@@@@@@@@@@@@    @@@@@@@           @@@@@@@               #@@@@@@@@@@
//    @@@@@@@@@@@@@@@@@@@@   @@@@@@@           @@@@@@@        @@@@@@@     @@@@@@#
//   @@@@@@@@@@@@@@@@@@@@@   @@@@@@@@@@@@@@@@ @@@@@@@         @@@@@@@@@@@@@@@@@
// @@@@@@@         *@@@@@@  @@@@@@@@@@@@@@@@  @@@@@@            .@@@@@@@@@@@@

pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "./interfaces/IDelegationRegistry.sol";

interface IAltsByAdidas is IERC721 {
    function walletOfOwner(
        address __owner,
        uint256 _startingIndex,
        uint256 _endingIndex
    ) external view returns (uint256[] memory);
}

interface IAdidasBluePass is IERC721 {
    function burnByOperator(uint256[] memory tokenIds) external;
}

/**
 * @title UniversalKey
 * @notice This contract enables ALTS by adidas holders to purchase Universal Keys
 * @dev This contract should be used with the ALTS by adidas ERC721 contract and optionally the Apecoin ERC20 token.
 */
contract UniversalKey is Ownable {
    using SafeERC20 for IERC20;
    struct Purchase {
        bool purchased;
        address owner;
    }
    /**
     * @notice ALTS by adidas ERC721 contract
     */
    IERC721 public erc721;
    /**
     * @notice Blue Pass ERC721 contract
     */
    IAdidasBluePass public bluePass;
    /**
     * @notice Apecoin ERC20 contract
     */
    IERC20 public apeCoin;
    /**
     * @notice Wallet to receive funds
     */
    address payable public receiver;
    /**
     * @notice The total limit of keys available for purchase.
     */
    uint256 public totalKeyLimit;
    /**
     * @notice The total number of Universal Keys purchased.
     */
    uint256 public totalKeysPurchased;
    /**
     *  @notice Get the maximum number of ALTS permitted in each team
     */
    uint256[8] public teamLimits;
    /**
     * @notice Exchange rate (# of APE per 1 ETH)
     */
    uint256 public ethApeExchangeRate;
    /**
     * @notice Snapshot prices
     */
    uint256[4] public snapshotPrices;
    /**
     * @notice Status of team selection
     */
    bool public teamSelectionEnabled;
    /**
     * @notice Status of Universal Key purchases
     */
    bool public purchasesEnabled;
    /**
     * @notice Status of team selection early access
     */
    bool public earlyAccessEnabled;

    mapping(uint256 => uint8) private tokenTeam;
    mapping(uint8 => uint256) private teamMemberCounts;
    mapping(uint256 => Purchase) private tokenPurchases;
    mapping(address => uint256[]) private userPurchasedTokens;
    /**
     * @notice Discounted purchases remaining for relevant snapshot groups
     */
    mapping(address => mapping(uint8 => bool)) public discountUsed;
    /**
     * @notice Token IDs with Universal Keys that are permitted for early access team selection
     */
    mapping(uint256 => bool) public earlyAccessTokens;
    /**
     * @notice Merkle roots for snapshots
     */
    mapping(uint8 => bytes32) public merkleRoots;

    IDelegationRegistry public immutable dc;

    constructor(
        address _erc721,
        address _bluePass,
        address _apeCoin,
        address payable _receiver,
        uint256[8] memory _teamLimits,
        uint256 _totalKeyLimit,
        uint256[4] memory _snapshotPrices,
        uint256 _ethApeExchangeRate,
        address _delegateCash,
        bytes32 _snapshot1Merkle,
        bytes32 _snapshot2Merkle,
        bytes32 _snapshot3Merkle
    ) {
        erc721 = IERC721(_erc721);
        bluePass = IAdidasBluePass(_bluePass);
        apeCoin = IERC20(_apeCoin);
        dc = IDelegationRegistry(_delegateCash);
        receiver = _receiver;
        totalKeyLimit = _totalKeyLimit;
        ethApeExchangeRate = _ethApeExchangeRate;
        snapshotPrices = _snapshotPrices;

        setMerkleRoot(0, _snapshot1Merkle);
        setMerkleRoot(1, _snapshot2Merkle);
        setMerkleRoot(2, _snapshot3Merkle);

        for (uint8 i = 0; i < 8; i++) {
            teamLimits[i] = _teamLimits[i];
        }
    }

    /**
     * @notice Enables ALTS by adidas holders to burn a Blue Pass for a Universal Key
     * @dev Purchases one key at zero price for a burned Blue Pass
     * @param tokenId Blue Pass token ID
     * @param altTokenId The ALTS by adidas ALT token ID to purchase a key for
     */
    function burnForKey(uint256 tokenId, uint256 altTokenId) public {
        require(
            purchasesEnabled || owner() == msg.sender,
            "Purchases are disabled"
        );
        require(
            totalKeysPurchased + 1 <= totalKeyLimit,
            "Total token limit exceeded"
        );
        require(
            bluePass.ownerOf(tokenId) == msg.sender,
            "User must own a Blue Pass"
        );
        require(
            erc721.ownerOf(altTokenId) == msg.sender,
            "User must own the ALTS token ID"
        );
        require(
            !tokenPurchases[altTokenId].purchased,
            "Key already purchased for ALT"
        );

        // Burn the Blue Pass
        uint256[] memory passToBurn = new uint256[](1);
        passToBurn[0] = tokenId;
        bluePass.burnByOperator(passToBurn);

        // Ensure successful Blue Pass burn before purchase

        tokenPurchases[altTokenId] = Purchase(true, msg.sender);
        userPurchasedTokens[msg.sender].push(altTokenId);

        totalKeysPurchased += 1;

        uint256[] memory singleTokenId = new uint256[](1);
        singleTokenId[0] = altTokenId;
    }

    /**
     * @notice Enables ALTS by adidas holders to purchase Universal Keys
     * @dev Purchases keys for the provided ALTS token IDs and handles payment
     * @param tokenIds The ALTS by adidas ALTS token IDs to purchase keys for
     * @param useApe Whether to pay with Apecoin
     */
    function purchaseKeys(
        uint256[] calldata tokenIds,
        bool useApe,
        address _vault,
        uint8[] calldata snapshotIds,
        bytes32[][] calldata proofs
    ) public payable {
        address requester = msg.sender;

        require(
            snapshotIds.length == proofs.length,
            "Snapshots/proofs length mismatch"
        );
        require(
            purchasesEnabled || owner() == msg.sender,
            "Purchases are disabled"
        );
        require(
            totalKeysPurchased + tokenIds.length <= totalKeyLimit,
            "Total token limit exceeded"
        );

        if (_vault != address(0)) {
            bool isDelegateValid = dc.checkDelegateForContract(
                msg.sender,
                _vault,
                address(erc721)
            );
            require(isDelegateValid, "invalid delegate-vault pairing");
            requester = _vault;
        }

        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(
                erc721.ownerOf(tokenIds[i]) == requester,
                "User must own the token ID"
            );
            require(
                !tokenPurchases[tokenIds[i]].purchased,
                "Token ID already purchased"
            );
        }

        uint256 price = 0;
        uint256 remainingKeys = tokenIds.length;
        bool[4] memory inSnapshot;

        for (uint256 i = 0; i < snapshotIds.length; i++) {
            inSnapshot[snapshotIds[i]] = isSnapshot(
                snapshotIds[i],
                requester,
                proofs[i]
            );
        }

        if (inSnapshot[0] && !discountUsed[requester][0]) {
            price += snapshotPrices[0];
            remainingKeys--;
            discountUsed[requester][0] = true;
        }
        if (remainingKeys > 0 && inSnapshot[1] && !discountUsed[requester][1]) {
            price += snapshotPrices[1];
            remainingKeys--;
            discountUsed[requester][1] = true;
        }
        if (remainingKeys > 0) {
            uint256 nextLowestPrice = inSnapshot[2]
                ? snapshotPrices[2]
                : snapshotPrices[3];
            price += nextLowestPrice * remainingKeys;
        }

        if (useApe) {
            require(msg.value == 0, "Should not send ETH with APE");
            uint256 apePrice = getApePrice(price);
            SafeERC20.safeTransferFrom(apeCoin, msg.sender, receiver, apePrice);
        } else {
            require(msg.value == price, "Insufficient payment");
            (bool sent, ) = receiver.call{value: price}("");
            require(sent, "Failed to send Ether");
        }

        for (uint256 i = 0; i < tokenIds.length; i++) {
            tokenPurchases[tokenIds[i]] = Purchase(true, requester);
            userPurchasedTokens[requester].push(tokenIds[i]);
        }

        unchecked {
            totalKeysPurchased += tokenIds.length;
        }
    }

    /**
     * @notice Admin function to assign keys to ALTS
     * @param tokenIds The ALTS token IDs
     */
    function grantKeys(uint256[] calldata tokenIds) public onlyOwner {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            address wallet = erc721.ownerOf(tokenId);

            require(
                !tokenPurchases[tokenId].purchased,
                "Token ID already has key"
            );

            tokenPurchases[tokenId] = Purchase(true, wallet);
            userPurchasedTokens[wallet].push(tokenId);

            totalKeysPurchased++;
        }
    }

    /**
     * @notice Admin function to update the wallet address to receive funds from purchases
     * @dev Only callable by the contract owner
     * @param newReceiver The new receiver wallet address
     */
    function updateReceiver(address payable newReceiver) public onlyOwner {
        receiver = newReceiver;
    }

    /**
     * @notice Get owned ALTS by adidas tokens for the given wallet
     * @param wallet The wallet to check for owned ALTS
     * @return tokenIds An array of token IDs of owned ALTS
     */
    function getOwnedAlts(
        address wallet
    ) public view returns (uint256[] memory tokenIds) {
        IAltsByAdidas source = IAltsByAdidas(address(erc721));
        tokenIds = source.walletOfOwner(wallet, 1, 30000);
        return tokenIds;
    }

    /**
     * @notice Check if the given ALTS token IDs are purchased and get their respective owner wallet addresses
     * @param tokenIds The token IDs to check
     * @return purchased An array of booleans representing the purchase status
     * @return walletAddresses An array of wallet addresses of the owners
     */
    function isTokenIdPurchased(
        uint256[] memory tokenIds
    )
        public
        view
        returns (bool[] memory purchased, address[] memory walletAddresses)
    {
        purchased = new bool[](tokenIds.length);
        walletAddresses = new address[](tokenIds.length);
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            purchased[i] = tokenPurchases[tokenId].purchased;
            if (purchased[i]) {
                walletAddresses[i] = erc721.ownerOf(tokenId);
            }
        }
    }

    /**
     * @notice Get the purchased keys for the given user
     * @param user The user to check for purchased keys
     * @return An array of purchased keys (token IDs)
     */
    function getPurchasedKeys(
        address user
    ) public view returns (uint256[] memory) {
        return userPurchasedTokens[user];
    }

    /**
     * @notice Admin function to update the snapshot prices for all groups
     * @param prices An array of updated snapshot prices
     */
    function updateSnapshotPrices(uint256[4] memory prices) public onlyOwner {
        snapshotPrices = prices;
    }

    /**
     * @notice Set the APE to ETH exchange rate
     * @param rate The multiple of APE per ETH value
     */
    function setEthApeExchangeRate(uint256 rate) public onlyOwner {
        ethApeExchangeRate = rate;
    }

    /**
     * @notice Get the APE price for the given ETH price
     * @param ethPrice The ETH price to calculate APE price for
     * @return The calculated APE price
     */
    function getApePrice(uint256 ethPrice) public view returns (uint256) {
        return ethPrice * ethApeExchangeRate;
    }

    /**
     * @notice Get the payable amount for the given wallet and ALTS token IDs
     * @param wallet The wallet to check
     * @param tokenIds The ALTS token IDs to check
     * @param useApe Whether to use Ape token for payment
     * @return price The calculated payable amount
     */
    function getAmountPayable(
        address wallet,
        uint8[] calldata snapshotIds,
        uint256[] calldata tokenIds,
        bool useApe
    ) public view returns (uint256) {
        uint256 price = 0;
        uint256 remainingKeys = tokenIds.length;
        bool[4] memory inSnapshot;

        for (uint256 i = 0; i < snapshotIds.length; i++) {
            uint8 snapshotId = snapshotIds[i];
            inSnapshot[snapshotId] = true;
        }

        if (inSnapshot[0] && !discountUsed[wallet][0]) {
            price += snapshotPrices[0];
            remainingKeys--;
        }

        if (remainingKeys > 0 && inSnapshot[1] && !discountUsed[wallet][1]) {
            price += snapshotPrices[1];
            remainingKeys--;
        }

        if (remainingKeys > 0) {
            uint256 nextLowestPrice = inSnapshot[2]
                ? snapshotPrices[2]
                : snapshotPrices[3];
            price += nextLowestPrice * remainingKeys;
        }

        if (useApe) {
            return getApePrice(price);
        } else {
            return price;
        }
    }

    /**
     * @notice Admin function to set the total key limit
     * @param limit The limit to set for total keys
     */
    function setTotalKeyLimit(uint256 limit) public onlyOwner {
        totalKeyLimit = limit;
    }

    /**
     * @notice Admin function to update the team limits for all teams
     * @param limits An array of updated team limits
     */
    function updateTeamLimits(uint256[8] memory limits) public onlyOwner {
        for (uint8 i = 0; i < 8; i++) {
            teamLimits[i] = limits[i];
        }
    }

    /**
     * @notice Select teams for the given ALTS token IDs for which Universal Keys have been purchased
     * @param tokenIds The ALTS token IDs to select teams for
     * @param teams The selected teams for each ALTS token ID
     */
    function selectTeam(
        uint256[] memory tokenIds,
        uint8[] memory teams,
        address _vault
    ) public {
        require(
            tokenIds.length == teams.length,
            "TokenIds/teams length mismatch"
        );

        // Check if the user has early access for all tokens
        bool hasEarlyAccess = true;
        if (earlyAccessEnabled) {
            for (uint256 i = 0; i < tokenIds.length; i++) {
                if (!earlyAccessTokens[tokenIds[i]]) {
                    hasEarlyAccess = false;
                    break;
                }
            }
        }

        require(
            teamSelectionEnabled || owner() == msg.sender || hasEarlyAccess,
            "No team selection / early access"
        );

        address requester = msg.sender;
        if (_vault != address(0)) {
            bool isDelegateValid = dc.checkDelegateForContract(
                msg.sender,
                _vault,
                address(erc721)
            );
            require(isDelegateValid, "invalid delegate-vault pairing");
            requester = _vault;
        }

        uint256[8] memory teamSelections;

        for (uint256 i = 0; i < teams.length; i++) {
            uint8 team = teams[i];
            require(1 <= team && team <= 8, "Invalid team number");

            uint256 tokenId = tokenIds[i];
            require(
                erc721.ownerOf(tokenId) == requester,
                "User must own the token ID"
            );
            require(
                tokenPurchases[tokenId].purchased &&
                    tokenPurchases[tokenId].owner == requester,
                "No key found for token ID"
            );
            require(tokenTeam[tokenId] == 0, "Token ID already has a team");

            /// Check if the team is, or would become, oversubscribed
            teamSelections[team - 1]++;
            require(
                teamMemberCounts[team] + teamSelections[team - 1] <=
                    teamLimits[team - 1],
                "Not enough spaces in this team"
            );

            tokenTeam[tokenId] = team;
        }
        for (uint8 i = 0; i < 8; i++) {
            teamMemberCounts[i + 1] += teamSelections[i];
        }
    }

    /**
     * @notice Admin function to update team selections for ALTS token IDs
     * @param tokenIds The token IDs to update team selections for
     * @param teams The updated team selections for each token ID
     */
    function updateTeamSelections(
        uint256[] memory tokenIds,
        uint8[] memory teams
    ) public onlyOwner {
        require(
            tokenIds.length == teams.length,
            "TokenIds/teams length mismatch"
        );
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint8 team = teams[i];
            uint256 tokenId = tokenIds[i];
            tokenTeam[tokenId] = team;
            teamMemberCounts[team]++;
        }
    }

    /**
     * @notice Get the team selections for the given ALTS token IDs
     * @param tokenIds The token IDs to check for teams
     * @return An array of selected teams (indexed by ALT token ID)
     */
    function getTeam(
        uint256[] memory tokenIds
    ) public view returns (uint8[] memory) {
        uint8[] memory teamsSelected = new uint8[](tokenIds.length);

        for (uint256 i = 0; i < tokenIds.length; i++) {
            teamsSelected[i] = tokenTeam[tokenIds[i]];
        }
        return teamsSelected;
    }

    /**
     * @notice Get all ALTS token IDs associated with a specified team
     * @param team The team number to get the token IDs for
     * @return An array of token IDs that belong to the specified team
     */
    function getTokenIdsByTeam(
        uint8 team
    ) public view returns (uint256[] memory) {
        require(1 <= team && team <= 8, "Invalid team number");

        uint256[] memory tokenIds = new uint256[](teamMemberCounts[team]);
        uint256 index = 0;

        for (uint256 tokenId = 1; tokenId <= totalKeyLimit; tokenId++) {
            if (tokenTeam[tokenId] == team) {
                tokenIds[index] = tokenId;
                index++;
            }
        }
        return tokenIds;
    }

    /**
     * @notice Get the total number of ALTS in each team
     * @return An array containing the number of ALTS in each team
     */
    function getTeamTotals() public view returns (uint256[8] memory) {
        uint256[8] memory currentTeamMembers;

        for (uint8 i = 0; i < 8; i++) {
            currentTeamMembers[i] = teamMemberCounts[i + 1];
        }
        return currentTeamMembers;
    }

    /**
     * @notice Get the total number of keys distributed among all teams
     * @return The total number of keys in all teams
     */
    function totalKeysInTeams() public view returns (uint256) {
        uint256 total = 0;
        for (uint8 i = 1; i <= 8; i++) {
            total += teamMemberCounts[i];
        }
        return total;
    }

    /**
     * @notice Admin function to set ALTS with early access to select team (golden keys)
     * @param tokenIds The ALTS token IDs to set
     */
    function setEarlyAccessTokens(uint256[] memory tokenIds) public onlyOwner {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            earlyAccessTokens[tokenIds[i]] = true;
        }
    }

    /**
     * @notice Admin function to enable team selection for early access token holders
     * @param enabled Bool to enable/disable early access
     */
    function setEarlyAccessEnabled(bool enabled) public onlyOwner {
        earlyAccessEnabled = enabled;
    }

    /**
     * @notice Admin function to enable or disable the ability to select a team
     * @param enabled A boolean representing whether team selection should be enabled or disabled
     */
    function setTeamSelectionEnabled(bool enabled) public onlyOwner {
        teamSelectionEnabled = enabled;
    }

    /**
     * @notice Admin function to enable or disable the ability to make key purchases
     * @param enabled A boolean for the status of key purchases
     */
    function setPurchasesEnabled(bool enabled) public onlyOwner {
        purchasesEnabled = enabled;
    }

    /**
     * @notice Admin function to reset discounted purchase availability for multiple wallets
     * @param users Array of wallet addresses
     * @param snapshots Snapshot IDs
     */
    function setDiscountedPurchasesRemaining(
        address[] calldata users,
        uint8[] calldata snapshots
    ) public onlyOwner {
        require(
            users.length == snapshots.length,
            "Users/snapshots length mismatch"
        );

        for (uint256 i = 0; i < users.length * snapshots.length; i++) {
            uint256 userIndex = i / snapshots.length;
            uint256 snapshotIndex = i % snapshots.length;
            discountUsed[users[userIndex]][snapshots[snapshotIndex]] = false;
        }
    }

    /**
     * @notice Admin function to update merkle roots for snapshots
     * @param snapshotId Snapshot to update root for
     * @param newRoot The new merkle root
     */
    function setMerkleRoot(uint8 snapshotId, bytes32 newRoot) public onlyOwner {
        merkleRoots[snapshotId] = newRoot;
    }

    /**
     * @notice Check if a wallet address is valid in the given snapshot
     * @param wallet Wallet address to check
     * @param proof Wallet's merkle proof
     * @param snapshotId Snapshot to check
     */
    function isSnapshot(
        uint8 snapshotId,
        address wallet,
        bytes32[] calldata proof
    ) public view returns (bool) {
        bytes32 merkleRoot = merkleRoots[snapshotId];
        return
            MerkleProof.verify(
                proof,
                merkleRoot,
                keccak256(abi.encodePacked(wallet))
            );
    }

    /**
     * @notice Admin function drain any ETH or APE funds stuck in the contract
     */
    function drain(address to) public onlyOwner {
        // Transfer stuck ETH to the contract owner
        uint256 balanceETH = address(this).balance;
        if (balanceETH > 0) {
            (bool sent, ) = to.call{value: balanceETH}("");
            require(sent, "Failed to send Ether");
        }

        // Transfer stuck APE to the contract owner
        uint256 balanceAPE = apeCoin.balanceOf(address(this));
        if (balanceAPE > 0) {
            apeCoin.safeTransfer(to, balanceAPE);
        }
    }
}
// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.17;

/**
 * @title An immutable registry contract to be deployed as a standalone primitive
 * @dev See EIP-5639, new project launches can read previous cold wallet -> hot wallet delegations
 * from here and integrate those permissions into their flow
 */
interface IDelegationRegistry {
    /// @notice Delegation type
    enum DelegationType {
        NONE,
        ALL,
        CONTRACT,
        TOKEN
    }

    /// @notice Info about a single delegation, used for onchain enumeration
    struct DelegationInfo {
        DelegationType type_;
        address vault;
        address delegate;
        address contract_;
        uint256 tokenId;
    }

    /// @notice Info about a single contract-level delegation
    struct ContractDelegation {
        address contract_;
        address delegate;
    }

    /// @notice Info about a single token-level delegation
    struct TokenDelegation {
        address contract_;
        uint256 tokenId;
        address delegate;
    }

    /// @notice Emitted when a user delegates their entire wallet
    event DelegateForAll(address vault, address delegate, bool value);

    /// @notice Emitted when a user delegates a specific contract
    event DelegateForContract(address vault, address delegate, address contract_, bool value);

    /// @notice Emitted when a user delegates a specific token
    event DelegateForToken(address vault, address delegate, address contract_, uint256 tokenId, bool value);

    /// @notice Emitted when a user revokes all delegations
    event RevokeAllDelegates(address vault);

    /// @notice Emitted when a user revoes all delegations for a given delegate
    event RevokeDelegate(address vault, address delegate);

    /**
     * -----------  WRITE -----------
     */

    /**
     * @notice Allow the delegate to act on your behalf for all contracts
     * @param delegate The hotwallet to act on your behalf
     * @param value Whether to enable or disable delegation for this address, true for setting and false for revoking
     */
    function delegateForAll(address delegate, bool value) external;

    /**
     * @notice Allow the delegate to act on your behalf for a specific contract
     * @param delegate The hotwallet to act on your behalf
     * @param contract_ The address for the contract you're delegating
     * @param value Whether to enable or disable delegation for this address, true for setting and false for revoking
     */
    function delegateForContract(address delegate, address contract_, bool value) external;

    /**
     * @notice Allow the delegate to act on your behalf for a specific token
     * @param delegate The hotwallet to act on your behalf
     * @param contract_ The address for the contract you're delegating
     * @param tokenId The token id for the token you're delegating
     * @param value Whether to enable or disable delegation for this address, true for setting and false for revoking
     */
    function delegateForToken(address delegate, address contract_, uint256 tokenId, bool value) external;

    /**
     * @notice Revoke all delegates
     */
    function revokeAllDelegates() external;

    /**
     * @notice Revoke a specific delegate for all their permissions
     * @param delegate The hotwallet to revoke
     */
    function revokeDelegate(address delegate) external;

    /**
     * @notice Remove yourself as a delegate for a specific vault
     * @param vault The vault which delegated to the msg.sender, and should be removed
     */
    function revokeSelf(address vault) external;

    /**
     * -----------  READ -----------
     */

    /**
     * @notice Returns all active delegations a given delegate is able to claim on behalf of
     * @param delegate The delegate that you would like to retrieve delegations for
     * @return info Array of DelegationInfo structs
     */
    function getDelegationsByDelegate(address delegate) external view returns (DelegationInfo[] memory);

    /**
     * @notice Returns an array of wallet-level delegates for a given vault
     * @param vault The cold wallet who issued the delegation
     * @return addresses Array of wallet-level delegates for a given vault
     */
    function getDelegatesForAll(address vault) external view returns (address[] memory);

    /**
     * @notice Returns an array of contract-level delegates for a given vault and contract
     * @param vault The cold wallet who issued the delegation
     * @param contract_ The address for the contract you're delegating
     * @return addresses Array of contract-level delegates for a given vault and contract
     */
    function getDelegatesForContract(address vault, address contract_) external view returns (address[] memory);

    /**
     * @notice Returns an array of contract-level delegates for a given vault's token
     * @param vault The cold wallet who issued the delegation
     * @param contract_ The address for the contract holding the token
     * @param tokenId The token id for the token you're delegating
     * @return addresses Array of contract-level delegates for a given vault's token
     */
    function getDelegatesForToken(address vault, address contract_, uint256 tokenId)
        external
        view
        returns (address[] memory);

    /**
     * @notice Returns all contract-level delegations for a given vault
     * @param vault The cold wallet who issued the delegations
     * @return delegations Array of ContractDelegation structs
     */
    function getContractLevelDelegations(address vault)
        external
        view
        returns (ContractDelegation[] memory delegations);

    /**
     * @notice Returns all token-level delegations for a given vault
     * @param vault The cold wallet who issued the delegations
     * @return delegations Array of TokenDelegation structs
     */
    function getTokenLevelDelegations(address vault) external view returns (TokenDelegation[] memory delegations);

    /**
     * @notice Returns true if the address is delegated to act on the entire vault
     * @param delegate The hotwallet to act on your behalf
     * @param vault The cold wallet who issued the delegation
     */
    function checkDelegateForAll(address delegate, address vault) external view returns (bool);

    /**
     * @notice Returns true if the address is delegated to act on your behalf for a token contract or an entire vault
     * @param delegate The hotwallet to act on your behalf
     * @param contract_ The address for the contract you're delegating
     * @param vault The cold wallet who issued the delegation
     */
    function checkDelegateForContract(address delegate, address vault, address contract_)
        external
        view
        returns (bool);

    /**
     * @notice Returns true if the address is delegated to act on your behalf for a specific token, the token's contract or an entire vault
     * @param delegate The hotwallet to act on your behalf
     * @param contract_ The address for the contract you're delegating
     * @param tokenId The token id for the token you're delegating
     * @param vault The cold wallet who issued the delegation
     */
    function checkDelegateForToken(address delegate, address vault, address contract_, uint256 tokenId)
        external
        view
        returns (bool);
}