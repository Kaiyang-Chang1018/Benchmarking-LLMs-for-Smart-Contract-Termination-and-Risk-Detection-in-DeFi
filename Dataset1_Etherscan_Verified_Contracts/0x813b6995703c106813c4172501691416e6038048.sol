// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
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
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.21;

library LibsErrorTypes {
    /***********************************|
    |         LiquidityCalcs            | 
    |__________________________________*/

    /// @notice thrown when supply or borrow exchange price is zero at calc token data (token not configured yet)
    uint256 internal constant LiquidityCalcs__ExchangePriceZero = 70001;

    /// @notice thrown when rate data is set to a version that is not implemented
    uint256 internal constant LiquidityCalcs__UnsupportedRateVersion = 70002;

    /// @notice thrown when the calculated borrow rate turns negative. This should never happen.
    uint256 internal constant LiquidityCalcs__BorrowRateNegative = 70003;

    /***********************************|
    |           SafeTransfer            | 
    |__________________________________*/

    /// @notice thrown when safe transfer from for an ERC20 fails
    uint256 internal constant SafeTransfer__TransferFromFailed = 71001;

    /// @notice thrown when safe transfer for an ERC20 fails
    uint256 internal constant SafeTransfer__TransferFailed = 71002;

    /***********************************|
    |           SafeApprove             | 
    |__________________________________*/

    /// @notice thrown when safe approve from for an ERC20 fails
    uint256 internal constant SafeApprove__ApproveFailed = 81001;
}
// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity 0.8.21;

import { LibsErrorTypes as ErrorTypes } from "./errorTypes.sol";

/// @notice provides minimalistic methods for safe transfers, e.g. ERC20 safeTransferFrom
library SafeTransfer {
    uint256 internal constant MAX_NATIVE_TRANSFER_GAS = 20000; // pass max. 20k gas for native transfers

    error FluidSafeTransferError(uint256 errorId_);

    /// @dev Transfer `amount_` of `token_` from `from_` to `to_`, spending the approval given by `from_` to the
    /// calling contract. If `token_` returns no value, non-reverting calls are assumed to be successful.
    /// Minimally modified from Solmate SafeTransferLib (address as input param for token, Custom Error):
    /// https://github.com/transmissions11/solmate/blob/50e15bb566f98b7174da9b0066126a4c3e75e0fd/src/utils/SafeTransferLib.sol#L31-L63
    function safeTransferFrom(address token_, address from_, address to_, uint256 amount_) internal {
        bool success_;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x23b872dd00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(from_, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "from_" argument.
            mstore(add(freeMemoryPointer, 36), and(to_, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "to_" argument.
            mstore(add(freeMemoryPointer, 68), amount_) // Append the "amount_" argument. Masking not required as it's a full 32 byte type.

            success_ := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 100 because the length of our calldata totals up like so: 4 + 32 * 3.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token_, 0, freeMemoryPointer, 100, 0, 32)
            )
        }

        if (!success_) {
            revert FluidSafeTransferError(ErrorTypes.SafeTransfer__TransferFromFailed);
        }
    }

    /// @dev Transfer `amount_` of `token_` to `to_`.
    /// If `token_` returns no value, non-reverting calls are assumed to be successful.
    /// Minimally modified from Solmate SafeTransferLib (address as input param for token, Custom Error):
    /// https://github.com/transmissions11/solmate/blob/50e15bb566f98b7174da9b0066126a4c3e75e0fd/src/utils/SafeTransferLib.sol#L65-L95
    function safeTransfer(address token_, address to_, uint256 amount_) internal {
        bool success_;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(to_, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "to_" argument.
            mstore(add(freeMemoryPointer, 36), amount_) // Append the "amount_" argument. Masking not required as it's a full 32 byte type.

            success_ := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token_, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        if (!success_) {
            revert FluidSafeTransferError(ErrorTypes.SafeTransfer__TransferFailed);
        }
    }

    /// @dev Transfer `amount_` of ` native token to `to_`.
    /// Minimally modified from Solmate SafeTransferLib (Custom Error):
    /// https://github.com/transmissions11/solmate/blob/50e15bb566f98b7174da9b0066126a4c3e75e0fd/src/utils/SafeTransferLib.sol#L15-L25
    function safeTransferNative(address to_, uint256 amount_) internal {
        bool success_;

        /// @solidity memory-safe-assembly
        assembly {
            // Transfer the ETH and store if it succeeded or not. Pass limited gas
            success_ := call(MAX_NATIVE_TRANSFER_GAS, to_, amount_, 0, 0, 0, 0)
        }

        if (!success_) {
            revert FluidSafeTransferError(ErrorTypes.SafeTransfer__TransferFailed);
        }
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.21;

abstract contract Errors {
    error Unauthorized();
    error InvalidParams();

    // claim related errors:
    error InvalidCycle();
    error InvalidProof();
    error NothingToClaim();
    error MsgSenderNotRecipient();
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.21;

abstract contract Events {
    /// @notice Emitted when an address is added or removed from the allowed proposers
    event LogUpdateProposer(address proposer, bool isProposer);

    /// @notice Emitted when an address is added or removed from the allowed approvers
    event LogUpdateApprover(address approver, bool isApprover);

    /// @notice Emitted when a new cycle root hash is proposed
    event LogRootProposed(uint256 cycle, bytes32 root, bytes32 contentHash, uint256 timestamp, uint256 blockNumber);

    /// @notice Emitted when a new cycle root hash is approved by the owner and becomes the new active root
    event LogRootUpdated(uint256 cycle, bytes32 root, bytes32 contentHash, uint256 timestamp, uint256 blockNumber);

    /// @notice Emitted when a `user` claims `amount` via a valid merkle proof
    event LogClaimed(
        address user,
        uint256 amount,
        uint256 cycle,
        uint8 positionType,
        bytes32 positionId,
        uint256 timestamp,
        uint256 blockNumber
    );

    /// @notice Emitted when a new reward cycle is created
    event LogRewardCycle(
        uint256 indexed cycle,
        uint256 indexed epoch,
        uint256 amount,
        uint256 startBlock,
        uint256 endBlock
    );

    /// @notice Emitted when a new distribution is created
    event LogDistribution(
        uint256 indexed epoch,
        address indexed initiator,
        uint256 amount,
        uint256 startCycle,
        uint256 endCycle,
        uint256 registrationBlock,
        uint256 registrationTimestamp
    );

    /// @notice Emitted when the distribution configuration is updated
    event LogDistributionConfigUpdated(
        bool pullFromSender,
        uint256 blocksPerDistribution,
        uint256 cyclesPerDistribution
    );

    /// @notice Emitted when a rewards distributor is toggled
    event LogRewardsDistributorToggled(address distributor, bool isDistributor);

    /// @notice Emitted when the start block of the next cycle is updated
    event LogStartBlockOfNextCycleUpdated(uint256 startBlockOfNextCycle);
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.21;

import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

import { Events } from "./events.sol";
import { Errors } from "./errors.sol";
import { Structs } from "./structs.sol";
import { Variables } from "./variables.sol";
import { SafeTransfer } from "../../../libraries/safeTransfer.sol";

// ---------------------------------------------------------------------------------------------
//
// @dev WARNING: DO NOT USE `multiProof` related methods of `MerkleProof`.
// This repo uses OpenZeppelin 4.8.2 which has a vulnerability for multi proofs. See:
// https://github.com/OpenZeppelin/openzeppelin-contracts/security/advisories/GHSA-wprv-93r4-jj2p
//
// ---------------------------------------------------------------------------------------------

abstract contract FluidMerkleDistributorCore is Structs, Variables, Events, Errors {
    /// @dev validates that an address is not the zero address
    modifier validAddress(address value_) {
        if (value_ == address(0)) {
            revert InvalidParams();
        }
        _;
    }
}

abstract contract FluidMerkleDistributorAdmin is FluidMerkleDistributorCore {
    /// @notice                  Updates an address status as a root proposer
    /// @param proposer_         The address to update
    /// @param isProposer_       Whether or not the address should be an allowed proposer
    function updateProposer(address proposer_, bool isProposer_) public onlyOwner validAddress(proposer_) {
        _proposers[proposer_] = isProposer_;
        emit LogUpdateProposer(proposer_, isProposer_);
    }

    /// @notice                  Updates an address status as a root approver
    /// @param approver_         The address to update
    /// @param isApprover_       Whether or not the address should be an allowed approver
    function updateApprover(address approver_, bool isApprover_) public onlyOwner validAddress(approver_) {
        _approvers[approver_] = isApprover_;
        emit LogUpdateApprover(approver_, isApprover_);
    }

    /// @notice                         Spell allows owner aka governance to do any arbitrary call on factory
    /// @param target_                  Address to which the call needs to be delegated
    /// @param data_                    Data to execute at the delegated address
    function _spell(address target_, bytes memory data_) internal returns (bytes memory response_) {
        assembly {
            let succeeded := delegatecall(gas(), target_, add(data_, 0x20), mload(data_), 0, 0)
            let size := returndatasize()

            response_ := mload(0x40)
            mstore(0x40, add(response_, and(add(add(size, 0x20), 0x1f), not(0x1f))))
            mstore(response_, size)
            returndatacopy(add(response_, 0x20), 0, size)

            switch iszero(succeeded)
            case 1 {
                // throw if delegatecall failed
                returndatacopy(0x00, 0x00, size)
                revert(0x00, size)
            }
        }
    }

    /// @dev open payload method for admin to resolve emergency cases
    function spell(address[] memory targets_, bytes[] memory calldatas_) public onlyOwner {
        for (uint256 i = 0; i < targets_.length; i++) _spell(targets_[i], calldatas_[i]);
    }

    /// @notice Pause contract functionality of new roots and claiming
    function pause() external onlyOwner {
        _pause();
    }

    /// @notice Unpause contract functionality of new roots and claiming
    function unpause() external onlyOwner {
        _unpause();
    }
}

abstract contract FluidMerkleDistributorApprover is FluidMerkleDistributorCore {
    /// @dev Checks that the sender is an approver
    modifier onlyApprover() {
        if (!isApprover(msg.sender)) {
            revert Unauthorized();
        }
        _;
    }

    /// @notice checks if the `approver_` is an allowed root approver
    function isApprover(address approver_) public view returns (bool) {
        return (_approvers[approver_] || owner == approver_);
    }

    /// @notice Approve the current pending root and content hash
    function approveRoot(
        bytes32 root_,
        bytes32 contentHash_,
        uint40 cycle_,
        uint40 startBlock_,
        uint40 endBlock_
    ) external onlyApprover {
        MerkleCycle memory merkleCycle_ = _pendingMerkleCycle;

        if (
            root_ != merkleCycle_.merkleRoot ||
            contentHash_ != merkleCycle_.merkleContentHash ||
            cycle_ != merkleCycle_.cycle ||
            startBlock_ != merkleCycle_.startBlock ||
            endBlock_ != merkleCycle_.endBlock
        ) {
            revert InvalidParams();
        }

        previousMerkleRoot = _currentMerkleCycle.merkleRoot;

        merkleCycle_.timestamp = uint40(block.timestamp);
        merkleCycle_.publishBlock = uint40(block.number);

        _currentMerkleCycle = merkleCycle_;

        emit LogRootUpdated(cycle_, root_, contentHash_, block.timestamp, block.number);
    }
}

abstract contract FluidMerkleDistributorProposer is FluidMerkleDistributorCore {
    /// @dev Checks that the sender is a proposer
    modifier onlyProposer() {
        if (!isProposer(msg.sender)) {
            revert Unauthorized();
        }
        _;
    }

    /// @notice checks if the `proposer_` is an allowed root proposer
    function isProposer(address proposer_) public view returns (bool) {
        return (_proposers[proposer_] || owner == proposer_);
    }

    /// @notice Propose a new root and content hash, which will be stored as pending until approved
    function proposeRoot(
        bytes32 root_,
        bytes32 contentHash_,
        uint40 cycle_,
        uint40 startBlock_,
        uint40 endBlock_
    ) external whenNotPaused onlyProposer {
        if (cycle_ != _currentMerkleCycle.cycle + 1 || startBlock_ > endBlock_) {
            revert InvalidParams();
        }

        _pendingMerkleCycle = MerkleCycle({
            merkleRoot: root_,
            merkleContentHash: contentHash_,
            cycle: cycle_,
            startBlock: startBlock_,
            endBlock: endBlock_,
            timestamp: uint40(block.timestamp),
            publishBlock: uint40(block.number)
        });

        emit LogRootProposed(cycle_, root_, contentHash_, block.timestamp, block.number);
    }
}

abstract contract FluidMerkleDistributorRewards is FluidMerkleDistributorCore {
    /// @dev Modifier to check if the sender is a rewards distributor
    modifier onlyRewardsDistributor() {
        if (!rewardsDistributor[msg.sender] && owner != msg.sender) revert Unauthorized();
        _;
    }

    /// @notice Updates the distribution configuration
    /// @param pullFromDistributor_ - whether to pull rewards from distributor or not
    /// @param blocksPerDistribution_ - duration of distribution in blocks
    /// @param cyclesPerDistribution_ - number of cycles to distribute rewards, if 0 then means paused
    function updateDistributionConfig(
        bool pullFromDistributor_,
        uint40 blocksPerDistribution_,
        uint40 cyclesPerDistribution_
    ) external onlyOwner {
        if (blocksPerDistribution_ == 0 || cyclesPerDistribution_ == 0) revert InvalidParams();
        emit LogDistributionConfigUpdated(
            pullFromDistributor = pullFromDistributor_,
            blocksPerDistribution = blocksPerDistribution_,
            cyclesPerDistribution = cyclesPerDistribution_
        );
    }

    /// @notice Toggles a rewards distributor
    /// @param distributor_ - address of the rewards distributor
    function toggleRewardsDistributor(address distributor_) external onlyOwner {
        if (distributor_ == address(0)) revert InvalidParams();
        emit LogRewardsDistributorToggled(
            distributor_,
            rewardsDistributor[distributor_] = !rewardsDistributor[distributor_]
        );
    }

    /// @notice Sets the start block of the next cycle
    /// @param startBlockOfNextCycle_ The start block of the next cycle
    function setStartBlockOfNextCycle(uint40 startBlockOfNextCycle_) external onlyOwner {
        if (startBlockOfNextCycle_ < block.number || startBlockOfNextCycle_ == 0) revert InvalidParams();
        emit LogStartBlockOfNextCycleUpdated(startBlockOfNextCycle = uint40(startBlockOfNextCycle_));
    }

    /////// Public Functions ///////

    /// @notice Returns the cycle rewards
    /// @return rewards_ - rewards
    function getCycleRewards() external view returns (Reward[] memory) {
        return rewards;
    }

    /// @notice Returns the cycle reward for a given cycle
    /// @param cycle_ - cycle of the reward
    /// @return reward_ - reward
    function getCycleReward(uint256 cycle_) external view returns (Reward memory) {
        if (cycle_ > rewards.length || cycle_ == 0) revert InvalidParams();
        return rewards[cycle_ - 1];
    }

    /// @notice Returns the total number of cycles
    /// @return totalCycles_ - total number of cycles
    function totalCycleRewards() external view returns (uint256) {
        return rewards.length;
    }

    /// @notice Returns the total number of distributions
    /// @return totalDistributions_ - total number of distributions
    function totalDistributions() external view returns (uint256) {
        return distributions.length;
    }

    /// @notice Returns the distribution for a given epoch
    /// @param epoch_ - epoch of the distribution
    /// @return distribution_ - distribution
    function getDistributionForEpoch(uint256 epoch_) external view returns (Distribution memory) {
        if (epoch_ > distributions.length || epoch_ == 0) revert InvalidParams();
        return distributions[epoch_ - 1];
    }

    /// @notice Returns all distributions
    /// @return distributions_ - all distributions
    function getDistributions() external view returns (Distribution[] memory) {
        return distributions;
    }

    ////////// Distribution Function //////////

    /// @notice Distributes rewards for a given token
    /// @param amount_ - amount of tokens to distribute rewards for
    function distributeRewards(uint256 amount_) public onlyRewardsDistributor {
        if (amount_ == 0) revert InvalidParams();

        uint256 amountPerCycle_ = amount_ / cyclesPerDistribution;
        uint256 blocksPerCycle_ = blocksPerDistribution / cyclesPerDistribution;

        uint256 cyclesLength_ = rewards.length;
        uint256 startBlock_ = 0;
        if (cyclesLength_ > 0) {
            uint256 lastCycleEndBlock_ = rewards[cyclesLength_ - 1].endBlock + 1;
            // if there are already some cycles, then we need to check if startBlockOfNextCycle was set in order to start from that block, then assign it to startBlock_
            if (lastCycleEndBlock_ < startBlockOfNextCycle) {
                startBlock_ = startBlockOfNextCycle;
            } else {
                // if lastCycleEndBlock_ of last cycle is still syncing, then we need to start last cycle's end block + 1, else start from current block
                startBlock_ = lastCycleEndBlock_ > block.number ? lastCycleEndBlock_ : block.number;
            }
        } else {
            // if there are no cycles, that means this is the first distribution, then we need to start from startBlockOfNextCycle, if it was set, else start from current block
            startBlock_ = startBlockOfNextCycle > 0 ? startBlockOfNextCycle : block.number;
        }

        if (startBlock_ == 0) revert InvalidParams();

        uint256 distributionEpoch_ = distributions.length + 1;

        distributions.push(
            Distribution({
                amount: amount_,
                epoch: uint40(distributionEpoch_),
                startCycle: uint40(cyclesLength_ + 1),
                endCycle: uint40(cyclesLength_ + cyclesPerDistribution),
                registrationBlock: uint40(block.number),
                registrationTimestamp: uint40(block.timestamp)
            })
        );

        for (uint256 i = 0; i < cyclesPerDistribution; i++) {
            uint256 endBlock_ = startBlock_ + blocksPerCycle_ - 1;
            uint256 cycle_ = cyclesLength_ + 1 + i;
            uint256 cycleAmount_ = amountPerCycle_;
            if (i == cyclesPerDistribution - 1) {
                cycleAmount_ = amount_ - (amountPerCycle_ * i);
            }
            rewards.push(
                Reward({
                    cycle: uint40(cycle_),
                    amount: cycleAmount_,
                    startBlock: uint40(startBlock_),
                    endBlock: uint40(endBlock_),
                    epoch: uint40(distributionEpoch_)
                })
            );
            emit LogRewardCycle(cycle_, distributionEpoch_, cycleAmount_, startBlock_, endBlock_);
            startBlock_ = endBlock_ + 1;
        }

        if (pullFromDistributor) SafeERC20.safeTransferFrom(TOKEN, msg.sender, address(this), amount_);

        emit LogDistribution(
            distributionEpoch_,
            msg.sender,
            amount_,
            cyclesLength_ + 1,
            cyclesLength_ + cyclesPerDistribution,
            block.number,
            block.timestamp
        );
    }
}

contract FluidMerkleDistributor is
    FluidMerkleDistributorCore,
    FluidMerkleDistributorAdmin,
    FluidMerkleDistributorApprover,
    FluidMerkleDistributorProposer,
    FluidMerkleDistributorRewards
{
    constructor(
        string memory name_,
        address owner_,
        address proposer_,
        address approver_,
        address rewardToken_,
        uint256 distributionInHours_,
        uint256 cycleInHours_,
        uint256 startBlock_,
        bool pullFromDistributor_
    )
        validAddress(owner_)
        validAddress(proposer_)
        validAddress(approver_)
        validAddress(rewardToken_)
        Variables(owner_, rewardToken_)
    {
        if (distributionInHours_ == 0 || cycleInHours_ == 0) revert InvalidParams();

        name = name_;

        _proposers[proposer_] = true;
        emit LogUpdateProposer(proposer_, true);

        _approvers[approver_] = true;
        emit LogUpdateApprover(approver_, true);

        uint40 _blocksPerDistribution = uint40(distributionInHours_ * 1 hours);
        uint40 _cyclesPerDistribution = uint40(distributionInHours_ / cycleInHours_);

        if (block.chainid == 1) _blocksPerDistribution = _blocksPerDistribution / 12 seconds;
        else if (block.chainid == 42161)
            _blocksPerDistribution = _blocksPerDistribution * 4; // 0.25 seconds blocktime, means 4 blocks per second
        else if (block.chainid == 8453 || block.chainid == 137)
            _blocksPerDistribution = _blocksPerDistribution / 2 seconds;
        else revert("Unsupported chain");

        emit LogDistributionConfigUpdated(
            pullFromDistributor = pullFromDistributor_,
            blocksPerDistribution = _blocksPerDistribution,
            cyclesPerDistribution = _cyclesPerDistribution
        );

        if (startBlock_ > 0) emit LogStartBlockOfNextCycleUpdated(startBlockOfNextCycle = uint40(startBlock_));
    }

    /// @notice checks if there is a proposed root waiting to be approved
    function hasPendingRoot() external view returns (bool) {
        return _pendingMerkleCycle.cycle == _currentMerkleCycle.cycle + 1;
    }

    /// @notice merkle root data related to current cycle (proposed and approved).
    function currentMerkleCycle() public view returns (MerkleCycle memory) {
        return _currentMerkleCycle;
    }

    /// @notice merkle root data related to pending cycle (proposed but not yet approved).
    function pendingMerkleCycle() public view returns (MerkleCycle memory) {
        return _pendingMerkleCycle;
    }

    function encodeClaim(
        address recipient_,
        uint256 cumulativeAmount_,
        uint8 positionType_,
        bytes32 positionId_,
        uint256 cycle_,
        bytes memory metadata_
    ) public pure returns (bytes memory encoded_, bytes32 hash_) {
        encoded_ = abi.encode(positionType_, positionId_, recipient_, cycle_, cumulativeAmount_, metadata_);
        hash_ = keccak256(bytes.concat(keccak256(encoded_)));
    }

    /// @notice Claims rewards for a given recipient
    /// @param recipient_ - address of the recipient
    /// @param cumulativeAmount_ - cumulative amount of rewards to claim
    /// @param positionType_ - type of position, 1 for lending, 2 for vaults, 3 for smart lending, etc
    /// @param positionId_ - id of the position, fToken address for lending and vaultId for vaults
    /// @param cycle_ - cycle of the rewards
    /// @param merkleProof_ - merkle proof of the rewards
    function claim(
        address recipient_,
        uint256 cumulativeAmount_,
        uint8 positionType_,
        bytes32 positionId_,
        uint256 cycle_,
        bytes32[] calldata merkleProof_,
        bytes memory metadata_
    ) public whenNotPaused {
        if (msg.sender != recipient_) revert MsgSenderNotRecipient();
        uint256 currentCycle_ = uint256(_currentMerkleCycle.cycle);

        if (!(cycle_ == currentCycle_ || (currentCycle_ > 0 && cycle_ == currentCycle_ - 1))) {
            revert InvalidCycle();
        }

        // Verify the merkle proof.
        bytes32 node_ = keccak256(
            bytes.concat(
                keccak256(abi.encode(positionType_, positionId_, recipient_, cycle_, cumulativeAmount_, metadata_))
            )
        );
        if (
            !MerkleProof.verify(
                merkleProof_,
                cycle_ == currentCycle_ ? _currentMerkleCycle.merkleRoot : previousMerkleRoot,
                node_
            )
        ) {
            revert InvalidProof();
        }

        uint256 claimable_ = cumulativeAmount_ - claimed[recipient_][positionId_];
        if (claimable_ == 0) {
            revert NothingToClaim();
        }

        claimed[recipient_][positionId_] = cumulativeAmount_;

        SafeERC20.safeTransfer(TOKEN, recipient_, claimable_);

        emit LogClaimed(recipient_, claimable_, cycle_, positionType_, positionId_, block.timestamp, block.number);
    }

    struct Claim {
        address recipient;
        uint256 cumulativeAmount;
        uint8 positionType;
        bytes32 positionId;
        uint256 cycle;
        bytes32[] merkleProof;
        bytes metadata;
    }

    function bulkClaim(Claim[] calldata claims_) external {
        for (uint i = 0; i < claims_.length; i++) {
            claim(
                claims_[i].recipient,
                claims_[i].cumulativeAmount,
                claims_[i].positionType,
                claims_[i].positionId,
                claims_[i].cycle,
                claims_[i].merkleProof,
                claims_[i].metadata
            );
        }
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.21;

abstract contract Structs {
    struct MerkleCycle {
        // slot 1
        bytes32 merkleRoot;
        // slot 2
        bytes32 merkleContentHash;
        // slot 3
        uint40 cycle;
        uint40 timestamp;
        uint40 publishBlock;
        uint40 startBlock;
        uint40 endBlock;
    }

    struct Reward {
        // slot 1
        uint256 amount;
        // slot 2
        uint40 cycle;
        uint40 startBlock;
        uint40 endBlock;
        uint40 epoch;
    }

    struct Distribution {
        // slot 1
        uint256 amount;
        // slot 2
        uint40 epoch;
        uint40 startCycle;
        uint40 endCycle;
        uint40 registrationBlock;
        uint40 registrationTimestamp;
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.21;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Owned } from "solmate/src/auth/Owned.sol";
import { Pausable } from "@openzeppelin/contracts/security/Pausable.sol";

import { Structs } from "./structs.sol";

abstract contract Constants {
    IERC20 public immutable TOKEN;

    constructor(address rewardToken_) {
        TOKEN = IERC20(rewardToken_);
    }
}

abstract contract Variables is Owned, Pausable, Constants, Structs {
    // ------------ storage variables from inherited contracts (Owned, Pausable) come before vars here --------

    // ----------------------- slot 0 ---------------------------
    // address public owner; -> from Owned

    // bool private _paused; -> from Pausable

    // 11 bytes empty

    // ----------------------- slot 1 ---------------------------

    /// @dev Name of the Merkle Distributor
    string public name;

    // ----------------------- slot 2 ---------------------------

    /// @dev allow list for allowed root proposer addresses
    mapping(address => bool) internal _proposers;

    // ----------------------- slot 3 ---------------------------

    /// @dev allow list for allowed root proposer addresses
    mapping(address => bool) internal _approvers;

    // ----------------------- slot 4-6 ---------------------------

    /// @dev merkle root data related to current cycle (proposed and approved).
    /// @dev timestamp & publishBlock = data from last publish.
    // with custom getter to return whole struct at once instead of default solidity getter splitting it into tuple
    MerkleCycle internal _currentMerkleCycle;

    // ----------------------- slot 7-9 ---------------------------

    /// @dev merkle root data related to pending cycle (proposed but not yet approved).
    /// @dev timestamp & publishBlock = data from last propose.
    // with custom getter to return whole struct at once instead of default solidity getter splitting it into tuple
    MerkleCycle internal _pendingMerkleCycle;

    // ----------------------- slot 10 ---------------------------

    /// @notice merkle root of the previous cycle
    bytes32 public previousMerkleRoot;

    // ----------------------- slot 11 ---------------------------

    /// @notice total claimed amount per user address and fToken. user => positionId => claimed amount
    mapping(address => mapping(bytes32 => uint256)) public claimed;

    // ----------------------- slot 12 ---------------------------

    /// @notice Data of cycle rewards
    Reward[] internal rewards;

    // ----------------------- slot 13 ---------------------------

    /// @notice data of distributions
    Distribution[] internal distributions;

    // ----------------------- slot 14 ---------------------------

    /// @notice allow list for rewards distributors
    mapping(address => bool) public rewardsDistributor;

    // ----------------------- slot 15 ---------------------------

    /// @notice Number of cycles to distribute rewards
    uint40 public cyclesPerDistribution;

    /// @notice Duration of each distribution in blocks
    uint40 public blocksPerDistribution;

    /// @notice Start block of the next cycle
    uint40 public startBlockOfNextCycle;

    /// @notice Whether to pull tokens from distributor or not
    bool public pullFromDistributor;

    constructor(address owner_, address rewardToken_) Constants(rewardToken_) Owned(owner_) {}
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Simple single owner authorization mixin.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/auth/Owned.sol)
abstract contract Owned {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event OwnershipTransferred(address indexed user, address indexed newOwner);

    /*//////////////////////////////////////////////////////////////
                            OWNERSHIP STORAGE
    //////////////////////////////////////////////////////////////*/

    address public owner;

    modifier onlyOwner() virtual {
        require(msg.sender == owner, "UNAUTHORIZED");

        _;
    }

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _owner) {
        owner = _owner;

        emit OwnershipTransferred(address(0), _owner);
    }

    /*//////////////////////////////////////////////////////////////
                             OWNERSHIP LOGIC
    //////////////////////////////////////////////////////////////*/

    function transferOwnership(address newOwner) public virtual onlyOwner {
        owner = newOwner;

        emit OwnershipTransferred(msg.sender, newOwner);
    }
}