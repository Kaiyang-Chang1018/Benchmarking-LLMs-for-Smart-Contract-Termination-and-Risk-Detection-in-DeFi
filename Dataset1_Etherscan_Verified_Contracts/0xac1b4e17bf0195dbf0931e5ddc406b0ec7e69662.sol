// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

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
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
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
        require(paused(), "Pausable: not paused");
        _;
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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

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
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
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

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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
        return functionCall(target, data, "Address: low-level call failed");
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
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
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
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
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
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
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
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/cryptography/MerkleProof.sol)

pragma solidity ^0.8.0;

/**
 * @dev These functions deal with verification of Merkle Trees proofs.
 *
 * The proofs can be generated using the JavaScript library
 * https://github.com/miguelmota/merkletreejs[merkletreejs].
 * Note: the hashing algorithm should be keccak256 and pair sorting should be enabled.
 *
 * See `test/utils/cryptography/MerkleProof.test.js` for some examples.
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
     * @dev Returns the rebuilt hash obtained by traversing a Merklee tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leafs & pre-images are assumed to be sorted.
     *
     * _Available since v4.4._
     */
    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                // Hash(current computed hash + current element of the proof)
                computedHash = _efficientHash(computedHash, proofElement);
            } else {
                // Hash(current element of the proof + current computed hash)
                computedHash = _efficientHash(proofElement, computedHash);
            }
        }
        return computedHash;
    }

    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import OpenZeppelin libraries for security and standard implementations
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

/**
 * @title TokenStakingV2
 * @dev A contract that allows users to stake ERC20 tokens and earn rewards over time.
 */
contract TokenStakingV2 is ReentrancyGuard, Ownable, Pausable {
    using SafeERC20 for IERC20;

    // The token users will stake
    IERC20 public immutable stakingToken;

    // The token used for rewards (could be the same as stakingToken)
    IERC20 public immutable rewardToken;

    // Reward rate in tokens per second
    uint256 public rewardRate;

    // Duration for which staked tokens are locked after unstaking
    uint256 public lockDuration;

    // Total tokens currently actively staked in the contract
    uint256 public totalStaked;

    // Timestamp when rewards were last updated
    uint256 public lastUpdateTime;

    // Accumulated reward per token, scaled up by 1e18 for precision
    uint256 public rewardPerTokenStored;

    // Root of the Merkle tree
    bytes32 public merkleRoot;

    // Mapping to track whether an address has claimed tokens
    mapping(address => bool) public addressClaimed;

    /// @notice Whether users can call buyAndStake or not.
    bool public buyAndStakeEnabled;

    /// @notice Price of 1 full stakingToken (assuming 18 decimals) in wei.
    /// For example, if 1 token = 0.01 ETH, then buyPrice = 0.01 * 1e18 wei = 1e16.
    uint256 public buyPrice;

    // Information about each user's staking
    struct UserInfo {
        uint256 amount; // Amount of tokens the user has actively staked
        uint256 unstakedAmount; // Amount of tokens the user has unstaked but not yet withdrawn
        uint256 rewardPerTokenPaid; // User's reward per token paid till last update
        uint256 rewards; // Rewards accumulated but not yet claimed
        uint256 lockUntil; // Timestamp until which the user's tokens are locked after unstaking
        uint256 unstakeTime; // Timestamp when the user called unstake (if any)
    }

    // Mapping from user address to their staking information
    mapping(address => UserInfo) public userInfo;

    // Events to emit when users stake, unstake, withdraw, or claim rewards
    event Staked(address indexed user, uint256 amount); // Emitted when a user stakes tokens
    event Unstaked(address indexed user, uint256 amount); // Emitted when a user unstakes tokens
    event Withdrawn(address indexed user, uint256 amount); // Emitted when a user withdraws unstaked tokens
    event RewardPaid(address indexed user, uint256 reward); // Emitted when a user claims rewards

    // Modifier to update reward variables before executing function
    modifier updateReward(address account) {
        // Update the reward per token and last update time
        rewardPerTokenStored = currentRewardPerToken();
        lastUpdateTime = lastApplicableRewardTime();

        if (account != address(0)) {
            // Update the user's accumulated rewards
            userInfo[account].rewards = earned(account);

            // Update the user's reward per token paid
            userInfo[account].rewardPerTokenPaid = rewardPerTokenStored;
        }
        _;
    }

    /**
     * @dev Constructor to initialize the staking contract.
     * @param _stakingToken Address of the token to be staked.
     * @param _rewardToken Address of the token to be rewarded.
     * @param _rewardRate Number of reward tokens distributed per second.
     * @param _lockDuration Duration (in seconds) for which staked tokens are locked after unstaking.
     */
    constructor(address _stakingToken, address _rewardToken, uint256 _rewardRate, uint256 _lockDuration) {
        // Validate the staking token address
        require(_stakingToken != address(0), "Invalid staking token address");

        // Validate the reward token address
        require(_rewardToken != address(0), "Invalid reward token address");

        // Ensure the reward rate is positive
        require(_rewardRate > 0, "Reward rate must be greater than zero");

        // Initialize the staking and reward tokens
        stakingToken = IERC20(_stakingToken);
        rewardToken = IERC20(_rewardToken);

        // Set the reward rate and lock duration
        rewardRate = _rewardRate;
        lockDuration = _lockDuration;

        // Initialize the last update time to the current timestamp
        lastUpdateTime = block.timestamp;

        // By default, buyAndStake is disabled, price is 0
        buyAndStakeEnabled = false;
        buyPrice = 0;
    }

    /**
     * @notice Pauses the contract to prevent staking, unstaking, and withdrawals. Only callable by the owner.
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @notice Unpauses the contract to allow staking, unstaking, and withdrawals. Only callable by the owner.
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * @notice Enables or disables the buyAndStake functionality.
     * @param _enabled A boolean indicating whether buyAndStake is enabled.
     */
    function setBuyAndStakeEnabled(bool _enabled) external onlyOwner {
        buyAndStakeEnabled = _enabled;
    }

    /**
     * @notice Updates the price (in wei) for buying one full stakingToken.
     *         If your token has 18 decimals, this is the cost in wei for 1 * 10^18 tokens.
     * @param _priceInWei The new price in wei.
     */
    function setBuyPrice(uint256 _priceInWei) external onlyOwner {
        require(_priceInWei > 0, "Price must be > 0");
        buyPrice = _priceInWei;
    }

    /**
     * @notice Allows a user to buy stakingToken with ETH and immediately stake them.
     *         The number of tokens is calculated by (msg.value * 1e18) / buyPrice.
     */
    function buyAndStake() external payable nonReentrant whenNotPaused updateReward(msg.sender) {
        // Check if the feature is enabled
        require(buyAndStakeEnabled, "buyAndStake is currently disabled");
        require(msg.value > 0, "Must send ETH to buy tokens");
        require(buyPrice > 0, "buyPrice is not set");

        // Calculate how many tokens the user can purchase
        // If buyPrice = wei per 1 full token (1 * 10^18 units),
        // then numberOfTokens = (msg.value * 10^18) / buyPrice
        uint256 tokensToPurchase = (msg.value * 1e18) / buyPrice;

        // Check that the contract has enough tokens to sell
        require(stakingToken.balanceOf(address(this)) - totalStaked >= tokensToPurchase, "Not enough tokens in contract to purchase");

        // Update user's staked amount
        UserInfo storage user = userInfo[msg.sender];
        user.amount += tokensToPurchase;

        // Update total staked
        totalStaked += tokensToPurchase;

        // Emit Staked event
        emit Staked(msg.sender, tokensToPurchase);
    }

    // ========= View Functions =========

    /**
     * @dev Returns the last time at which rewards can be applied.
     * @return Timestamp of the current block.
     */
    function lastApplicableRewardTime() public view returns (uint256) {
        return block.timestamp;
    }

    /**
     * @dev Calculates the current reward per token staked.
     * @return Updated reward per token value, scaled by 1e18.
     */
    function currentRewardPerToken() public view returns (uint256) {
        // If there are no tokens staked, return the last stored reward per token value
        if (totalStaked == 0) {
            return rewardPerTokenStored;
        }

        // Calculate the updated reward per token
        // Steps:
        // 1. Calculate the time elapsed since the last update
        uint256 timeElapsed = lastApplicableRewardTime() - lastUpdateTime;

        // 2. Calculate the total rewards generated since the last update
        //    totalRewards = timeElapsed * rewardRate
        uint256 totalRewards = timeElapsed * rewardRate;

        // 3. Calculate the reward per token by dividing total rewards by total staked tokens
        //    Multiply by 1e18 to maintain precision
        uint256 rewardPerTokenIncrement = (totalRewards * 1e18) / totalStaked;

        // 4. Add the new reward per token increment to the stored reward per token value
        return rewardPerTokenStored + rewardPerTokenIncrement;
    }

    /**
     * @dev Calculates the total rewards earned by a user.
     * @param account Address of the user.
     * @return Total rewards earned by the user.
     */
    function earned(address account) public view returns (uint256) {
        UserInfo storage user = userInfo[account];

        uint256 effectiveAmount = user.amount; // Only consider actively staked tokens

        // We always use the latest currentRewardPerToken()
        uint256 effectiveRewardPerToken = currentRewardPerToken();

        // Calculate the difference in reward per token since the user's last update
        uint256 rewardPerTokenDifference = effectiveRewardPerToken - user.rewardPerTokenPaid;

        // Calculate earned rewards based on actively staked amount
        uint256 earnedRewards = (effectiveAmount * rewardPerTokenDifference) / 1e18;

        // Return the total rewards (including previously accumulated rewards)
        return earnedRewards + user.rewards;
    }

    /**
     * @dev Calculates the current Annual Percentage Yield (APY) for staking.
     * @return APY percentage scaled by 1e18 (e.g., 5% APY is represented as 5e16).
     */
    function calculateAPY() external view returns (uint256) {
        // Ensure there are tokens staked to prevent division by zero
        if (totalStaked == 0) {
            return 0;
        }

        // Number of seconds in a year (365 days)
        uint256 secondsInYear = 31536000; // 365 * 24 * 60 * 60

        // Calculate the total rewards distributed in one year
        uint256 annualRewards = rewardRate * secondsInYear;

        // APY formula:
        // APY (%) = (Annual Rewards / Total Staked) * 100%
        // Scaling the result by 1e18 for precision
        uint256 apy = (annualRewards * 1e18 * 100) / totalStaked;

        return apy; // APY percentage scaled by 1e18
    }

    // ========= Mutative Functions =========

    /**
     * @dev Allows a user to stake tokens.
     * @param _amount Amount of tokens to stake.
     */
    function stake(uint256 _amount) external nonReentrant whenNotPaused updateReward(msg.sender) {
        // Ensure the staking amount is greater than zero
        require(_amount > 0, "Cannot stake zero tokens");

        // Fetch the user's staking information
        UserInfo storage user = userInfo[msg.sender];

        // Update user's staked amount
        user.amount += _amount;

        // Update total staked amount in the contract
        totalStaked += _amount;

        // Transfer staking tokens from the user to the contract
        stakingToken.safeTransferFrom(msg.sender, address(this), _amount);

        // Emit the staked event
        emit Staked(msg.sender, _amount);
    }

    /**
     * @dev Allows a user to unstake tokens, moving them to unstakedAmount and starting the lock period.
     * @param _amount Amount of tokens to unstake.
     */
    function unstake(uint256 _amount) external nonReentrant whenNotPaused updateReward(msg.sender) {
        // Fetch the user's staking information
        UserInfo storage user = userInfo[msg.sender];

        // Ensure the unstake amount is greater than zero
        require(_amount > 0, "Cannot unstake zero tokens");

        // Ensure the user has enough staked tokens
        require(user.amount >= _amount, "Unstake amount exceeds staked balance");

        // Update the user's staked amount and unstaked amount
        user.amount -= _amount;
        user.unstakedAmount += _amount;

        // Update total staked amount in the contract
        totalStaked -= _amount;

        // Set the unstake time and lock until timestamp
        user.unstakeTime = block.timestamp;
        user.lockUntil = block.timestamp + lockDuration;

        // Emit the unstaked event
        emit Unstaked(msg.sender, _amount);
    }

    /**
     * @dev Allows a user to withdraw unstaked tokens after the lock period has passed.
     * @param _amount Amount of tokens to withdraw.
     */
    function withdraw(uint256 _amount) public nonReentrant whenNotPaused {
        // Fetch the user's staking information
        UserInfo storage user = userInfo[msg.sender];

        // Ensure the withdrawal amount is greater than zero
        require(_amount > 0, "Cannot withdraw zero tokens");

        // Ensure the user has enough unstaked tokens
        require(user.unstakedAmount >= _amount, "Withdraw amount exceeds unstaked balance");

        // Ensure the lock period has passed
        require(block.timestamp >= user.lockUntil, "Tokens are still locked");

        // Update the user's unstaked amount
        user.unstakedAmount -= _amount;

        // If all unstaked tokens have been withdrawn, reset unstakeTime and lockUntil
        if (user.unstakedAmount == 0) {
            user.unstakeTime = 0;
            user.lockUntil = 0;
        }

        // Transfer staking tokens back to the user
        stakingToken.safeTransfer(msg.sender, _amount);

        // Emit the withdrawn event
        emit Withdrawn(msg.sender, _amount);
    }

    /**
     * @dev Allows a user to claim their accumulated rewards.
     */
    function getReward() public nonReentrant whenNotPaused updateReward(msg.sender) {
        // Fetch the user's staking information
        UserInfo storage user = userInfo[msg.sender];

        // Get the user's accumulated rewards
        uint256 reward = user.rewards;

        // Ensure there are rewards to claim
        require(reward > 0, "No rewards to claim");

        // Reset the user's accumulated rewards
        user.rewards = 0;

        // Transfer reward tokens to the user
        rewardToken.safeTransfer(msg.sender, reward);

        // Emit the reward paid event
        emit RewardPaid(msg.sender, reward);
    }

    function getReward(uint256 _amount, bytes32[] memory _array) external nonReentrant whenNotPaused {
        // Verify that the sender's address and amount are part of the Merkle tree
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender, _amount));
        require(MerkleProof.verify(_array, merkleRoot, leaf), "Invalid Merkle proof");

        // Ensure that the address has not already claimed
        require(!addressClaimed[msg.sender], "Address already claimed");

        // Mark this address as having claimed tokens
        addressClaimed[msg.sender] = true;

        // Transfer the tokens to the sender
        uint256 scaledAmount = _amount * (10 ** 18);
        rewardToken.safeTransfer(msg.sender, scaledAmount);
    }

    /**
     * @dev Allows a user to withdraw all unstaked tokens and claim rewards.
     */
    function exit() external {
        // Claim all accumulated rewards
        getReward();

        // Withdraw all unstaked tokens
        withdraw(userInfo[msg.sender].unstakedAmount);
    }

    // ========= Owner Functions =========

    /**
     * @dev Allows the owner to update the reward rate.
     * @param _rewardRate New reward rate in tokens per second.
     */
    function updateRewardRate(uint256 _rewardRate) external onlyOwner updateReward(address(0)) {
        // Ensure the new reward rate is greater than zero
        require(_rewardRate > 0, "Reward rate must be greater than zero");

        // Update the reward rate
        rewardRate = _rewardRate;
    }

    /**
     * @dev Allows the owner to update the lock duration.
     * @param _lockDuration New lock duration in seconds.
     */
    function updateLockDuration(uint256 _lockDuration) external onlyOwner {
        // Update the lock duration (can be zero)
        lockDuration = _lockDuration;
    }

    /**
     * @dev Allows the owner to update the merkle root.
     * @param _merkleRoot New merkle root.
     */
    function updateMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        // Update the merkle root
        merkleRoot = _merkleRoot;
    }

    // ========= Frontend Helper Functions =========

    /**
     * @dev Returns user-specific information.
     * @param _user Address of the user.
     * @return stakedAmount Amount of tokens the user has actively staked.
     * @return unstakedAmount Amount of tokens the user has unstaked but not yet withdrawn.
     * @return rewardsEarned Total rewards earned by the user.
     * @return lockUntil Timestamp until which the user's unstaked tokens are locked.
     * @return unstakeTime Timestamp when the user called unstake (if any).
     */
    function getUserInfo(
        address _user
    ) external view returns (uint256 stakedAmount, uint256 unstakedAmount, uint256 rewardsEarned, uint256 lockUntil, uint256 unstakeTime) {
        UserInfo storage user = userInfo[_user];
        stakedAmount = user.amount;
        unstakedAmount = user.unstakedAmount;
        rewardsEarned = earned(_user);
        lockUntil = user.lockUntil;
        unstakeTime = user.unstakeTime;
    }

    /**
     * @dev Returns general pool information.
     * @return _totalStaked Total tokens actively staked in the contract.
     * @return _rewardRate Current reward rate in tokens per second.
     * @return _lockDuration Current lock duration in seconds.
     * @return _lastUpdateTime Timestamp of the last reward update.
     * @return _rewardPerTokenStored Current reward per token value.
     */
    function getPoolInfo()
        external
        view
        returns (uint256 _totalStaked, uint256 _rewardRate, uint256 _lockDuration, uint256 _lastUpdateTime, uint256 _rewardPerTokenStored)
    {
        _totalStaked = totalStaked;
        _rewardRate = rewardRate;
        _lockDuration = lockDuration;
        _lastUpdateTime = lastUpdateTime;
        _rewardPerTokenStored = rewardPerTokenStored;
    }

    /**
     * @notice Withdraws any ERC20 tokens held by the contract. Only callable by the owner.
     * @param tokenContractAddress The address of the ERC20 token to withdraw.
     * @param amount The amount of tokens to withdraw.
     */
    function withdrawToken(address tokenContractAddress, uint256 amount) external onlyOwner {
        IERC20 tokenContract = IERC20(tokenContractAddress);
        tokenContract.safeTransfer(msg.sender, amount);
    }

    /**
     * @notice Withdraws native currency (ETH) held by the contract. Only callable by the owner.
     * @param amount The amount of ETH to withdraw.
     */
    function withdrawNative(uint256 amount) external onlyOwner {
        require(amount <= address(this).balance, "Insufficient balance");
        payable(msg.sender).transfer(amount);
    }

    /**
     * @dev Fallback function to accept ETH deposits.
     */
    receive() external payable {}
}