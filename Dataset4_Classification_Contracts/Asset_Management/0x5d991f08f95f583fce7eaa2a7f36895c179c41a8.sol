// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

// OpenZeppelin Contracts (last updated v4.9.3) (token/ERC20/utils/SafeERC20.sol)

// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

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

// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/extensions/IERC20Permit.sol)

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

// OpenZeppelin Contracts (last updated v4.9.0) (utils/Address.sol)

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

// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

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

// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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

abstract contract IERC20ExtentedExtented is IERC20 {
    function decimals() public view virtual returns (uint8);
}

contract CairoStakingEth is ReentrancyGuard, Ownable {
    ICertificateToken public underlyingToken; //aankrProxy Token  // Mainnet 0xE95A203B1a91a908F9B9CE46459d101078c2c3cb //
    IERC20ExtentedExtented public rewardsToken;
    IStakingContract public StakingContract; // Mainnet 0x84db6eE82b7Cf3b47E8F19270abdE5718B936670
    address public WBNB;
    address public _bondToken;
    uint256 public minimumUnstake;

    using SafeERC20 for IERC20ExtentedExtented;

    address _treasuryWallet;
    uint256 public updatedAt;
    // Reward to be paid out per second
    uint256 public rewardRate;
    uint256 public rewardPerTokenStored;
    uint256 public constant FEE_MAX = 100000;
    uint256 public depositFee;
    uint256 public feeCollected;
    uint256 public minimumCooldown;
    // Referral reward arr for users
    uint256[4] refRew = [5, 2, 2, 1];
    uint256 fee = 30;
    uint256 public lastUpdateTime;
    uint256 public totalUnderlyingToken;
    uint256 private _cooldownTime;

    struct user_data {
        address referralAddress;
        uint256 userRewardPerTokenPaid;
        uint256 rewards;
        uint256 balance;
        uint256 underlyingBalance;
        uint256 lastUpdated;
    }

    struct reward_data {
        uint256 available;
        uint256 claimed;
    }

    // Withdrawal Requests
    struct request_data {
        uint256 amount;
        uint256 fee;
        uint256 cooldownTime;
    }

    mapping(address => reward_data) public rewards;
    mapping(address => user_data) public user;
    mapping(address => request_data) public requests;

    // User address => rewardPerTokenStored
    // User address => rewards to be claimed
    // User address => staked amount
    // Underlying token abnb

    constructor(
        address _underlyingToken,
        address _rewardToken,
        address _stakingContract,
        address treasuryWallet,
        uint256 _rewardRate,
        uint256 _depositFee,
        address _wbnb,
        uint256 minimumCooldownTime
    ) {
        rewardRate = _rewardRate;
        rewardsToken = IERC20ExtentedExtented(_rewardToken);
        require(rewardsToken.decimals() == 18, "Reward token only supports 18 decimal");
        lastUpdateTime = block.timestamp;

        underlyingToken = ICertificateToken(_underlyingToken);
        StakingContract = IStakingContract(_stakingContract);
        _treasuryWallet = treasuryWallet;
        depositFee = _depositFee;
        WBNB = _wbnb;
        minimumCooldown = minimumCooldownTime * 1 days;
    }

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = block.timestamp;
        if (account != address(0)) {
            user[account].rewards = earned(account);
            user[account].userRewardPerTokenPaid = rewardPerTokenStored;
        }

        _;
    }

    event ReferRewardsClaimed(address indexed claimer, uint256 amount);
    event ReferRewarded(address indexed referrer, address referee, uint256 _amount);
    event Recovered(address token, uint256 amount);
    event Unstaked(
        address indexed ownerAddress,
        address indexed receiverAddress,
        uint256 amount,
        uint256 shares,
        bool indexed isRebasing
    );
    event FeeAmount(uint256 _fee);

    event UnstakeClaimed(address indexed receiver, uint256 _amount);

    /**
     * @dev Get the current timestamp for calculating the last applicable reward time.
     * @return The current block timestamp.
     */
    function lastTimeRewardApplicable() public view returns (uint256) {
        return block.timestamp;
    }

    /**
     * @dev Get the current reward rate per token.
     * @return The current reward rate.
     */
    function rewardPerToken() public view returns (uint256) {
        if (totalUnderlyingToken == 0) {
            return rewardPerTokenStored;
        }
        return rewardPerTokenStored
            + (((lastTimeRewardApplicable() - lastUpdateTime) * (rewardRate * 1e18)) / (totalUnderlyingToken));
    }
    /**
     * @dev Change the reward rate per token.
     * Only the contract owner can execute this function.
     * @param _rewardRate The new reward rate to set.
     */

    function setRewardPerToken(uint256 _rewardRate) external onlyOwner updateReward(address(0)) {
        require(rewardRate > 0, "Reward rate must be greater than 0");

        rewardRate = _rewardRate;
    }

    /**
     * @dev Stake ETH to earn rewards and certificates.
     * @param _referrer The address of the referrer who referred the user (optional).
     */

    function stake(address _referrer) external payable nonReentrant updateReward(msg.sender) {
        uint256 feeCharged = ((msg.value * depositFee) / FEE_MAX);
        uint256 _amount = msg.value - feeCharged;
        require(_referrer != msg.sender && _referrer != address(0), "Cannot use same address");

        require(_amount > 0, "amount = 0");
        user[msg.sender].balance += _amount;
        if (user[msg.sender].referralAddress == address(0)) {
            user[msg.sender].referralAddress = _referrer;
        }
        feeCollected += feeCharged;
        uint256 unAmount = getRatio(_amount);
        totalUnderlyingToken += unAmount;

        user[msg.sender].underlyingBalance += unAmount;
        StakingContract.stakeAndClaimAethC{value: _amount}();
    }

    function getRatio(uint256 _amount) public view returns (uint256 ratio) {
        ratio = underlyingToken.bondsToShares(_amount);
        return ratio;
    }

    /**
     * @dev Withdraw staked certificates and claim underlying ETH.
     */
    function withdraw() external updateReward(msg.sender) nonReentrant {
        uint256 underlyingAmount = user[msg.sender].underlyingBalance;
        require(underlyingAmount >= minimumUnstake, "Invalid amount Called");

        requests[msg.sender].cooldownTime = block.timestamp + _cooldownTime;
        uint256 balance = user[msg.sender].balance;

        user[msg.sender].balance -= balance;
        user[msg.sender].underlyingBalance -= underlyingAmount;

        underlyingAmount -= 1;
        totalUnderlyingToken -= underlyingAmount;
        uint256 currentAmount = underlyingToken.sharesToBonds(underlyingAmount);
        requests[msg.sender].amount += currentAmount;
        _checkReferReward(balance, currentAmount);
        StakingContract.unstakeAETH(underlyingAmount);
    }

    /**
     * @dev Check and distribute referral rewards if the increase in underlying amount exceeds the previous amount.
     * @param _prevAmount The previous amount of underlying tokens.
     * @param _unAmount The current amount of underlying tokens.
     */

    function _checkReferReward(uint256 _prevAmount, uint256 _unAmount) private {
        if (_unAmount > _prevAmount) {
            uint256 rewA = _unAmount - _prevAmount;
            uint256 _unstakeFee = (rewA * fee) / 100;
            requests[msg.sender].fee += _unstakeFee;
            // feeCollected += _unstakeFee;
            // _payRefs(rewA);
        }
    }

    /**
     * @dev Distribute referral rewards to referrers.
     * @param _amount The total amount of rewards to be distributed.
     */
    function _payRefs(uint256 _amount) private {
        address referrer = user[msg.sender].referralAddress;
        uint256 feeTransferred;
        for (uint256 i = 0; i < 4; i++) {
            if (referrer != address(0)) {
                uint256 rew = (_amount * refRew[i]) / 100;
                rewards[referrer].available += rew;
                feeTransferred += rew;
                emit ReferRewarded(referrer, msg.sender, rew);
                referrer = user[referrer].referralAddress;
            } else {
                break;
            }
        }
        feeCollected += (_amount - feeTransferred);
    }

    /**
     * @dev Claim and transfer available referral rewards to the sender.
     */
    function claimReferRewards() external {
        uint256 rew = rewards[msg.sender].available;
        require(rew != 0, "No rewards available");
        require(address(this).balance >= rew, "Wait for rewards to be available");
        rewards[msg.sender].available = 0;
        _unsafeTransfer(msg.sender, rew, true);
        rewards[msg.sender].claimed += rew;
        emit ReferRewardsClaimed(msg.sender, rew);
    }

    /**
     * @dev Calculate the total earned rewards for an account.
     * @param _account The account address for which to calculate rewards.
     * @return The total earned rewards for the account.
     */
    function earned(address _account) public view returns (uint256) {
        uint256 balance = user[_account].underlyingBalance;
        uint256 userRewardPerTokenPaid = user[_account].userRewardPerTokenPaid;
        uint256 _rewards = user[_account].rewards;
        return (balance * (rewardPerToken() - userRewardPerTokenPaid)) / 1e18 + _rewards;
    }

    /**
     * @dev Claim and transfer accumulated rewards to the sender.
     */
    function getReward() public updateReward(msg.sender) nonReentrant {
        uint256 reward = user[msg.sender].rewards;
        require(rewardsToken.balanceOf(address(this)) > reward, "Generating tokens please try again after some time.");
        if (reward > 0 && rewardsToken.balanceOf(address(this)) > reward) {
            user[msg.sender].rewards = 0;
            rewardsToken.transfer(msg.sender, reward);
        }
    }

    // Added to support recovering LP Rewards from other systems such as BAL to be distributed to holders
    /**
     * @dev Recover ERC20 tokens from the contract, transferring them to the owner.
     * Only the owner can execute this function.
     * @param tokenAddress The address of the ERC20 token to recover.
     * @param tokenAmount The amount of ERC20 tokens to recover.
     */
    function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyOwner {
        require(tokenAddress != address(underlyingToken), "Cannot withdraw the staking token");
        IERC20ExtentedExtented(tokenAddress).safeTransfer(owner(), tokenAmount);
        emit Recovered(tokenAddress, tokenAmount);
    }

    function _min(uint256 x, uint256 y) private pure returns (uint256) {
        return x <= y ? x : y;
    }

    function _unsafeTransfer(address receiverAddress, uint256 amount, bool limit) internal virtual returns (bool) {
        address payable wallet = payable(receiverAddress);
        bool success;
        if (limit) {
            assembly {
                success := call(27000, wallet, amount, 0, 0, 0, 0)
            }
            require(success == true, "Send Eth reverted");

            return success;
        }
        (success,) = wallet.call{value: amount}("");
        require(success == true, "Send Eth reverted");
        return success;
    }

    /**
     * @dev Claim the requested unstaked amount after deducting the fee and transfer to the sender.
     */
    function claimUnstakeAmount() external nonReentrant {
        request_data memory userRq = requests[msg.sender];
        uint256 _amount = userRq.amount;
        uint256 _fee = userRq.fee;
        uint256 _cooldown = userRq.cooldownTime;
        require(isClaimAvailable(msg.sender), "No Claim Available Rn");
        require(_cooldown < block.timestamp, "Wait for cooldown to end");
        require(_amount > 0, "No unstaking request made");
        require((address(this).balance >= _amount));
        uint256 totalAmount = _amount - _fee;
        emit FeeAmount(_fee);
        emit UnstakeClaimed(msg.sender, _amount);
        requests[msg.sender].fee = 0;
        requests[msg.sender].amount = 0;
        _payRefs(_fee);
        _unsafeTransfer(msg.sender, totalAmount, true);
    }

    /**
     * @dev Check if a user is eligible to claim their requested unstaked amount.
     * @param _user The user's address to check.
     * @return Whether the user can claim their unstaked amount.
     */
    function isClaimAvailable(address _user) public view returns (bool) {
        if (
            address(this).balance - feeCollected >= (requests[_user].amount)
                && requests[_user].cooldownTime <= block.timestamp
        ) {
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Withdraw collected unstake fees to the treasury.
     * Only the contract owner can execute this function.
     */
    function withdrawFee() external onlyOwner {
        require(feeCollected > 0, "No fee collected yet!");
        uint256 _fee = feeCollected;
        feeCollected = 0;
        _unsafeTransfer(_treasuryWallet, _fee, false);
    }

    /**
     * @dev Update the treasury address.
     * Only the contract owner can execute this function.
     * @param _receiverAddress The new treasury address to set.
     */
    function setTreasuryAddress(address _receiverAddress) external onlyOwner {
        require(_receiverAddress != address(0), "Treasury address CANNOT be DEAD WALLET");

        _treasuryWallet = _receiverAddress;
    }

    function setDepositFee(uint256 _fee) external onlyOwner {
        require(_fee / 1_000 <= 5, "Invalid Fee");

        depositFee = _fee;
    }

    function setCooldownTime(uint256 _time) external onlyOwner {
        require(_time * 1 days >= minimumCooldown, "Invalid cooldown time");
        _cooldownTime = (_time * 1 days);
    }

    function getCooldownTime() public view returns (uint256) {
        return _cooldownTime;
    }

    function setMinimumUnStake(uint256 _amount) external onlyOwner {
        require(_amount > 0 && _amount <= 10 ether, "Amount should be less than 0.1");

        minimumUnstake = _amount;
    }

    /**
     * @dev Fallback function to receive incoming Ether.
     */
    receive() external payable {}
}

interface IStakingContract {
    function stakeAndClaimAethC() external payable;

    function unstakeAETH(uint256 shares) external;
}

interface ICertificateToken {
    function sharesToBonds(uint256 amount) external view returns (uint256);

    function bondsToShares(uint256 amount) external view returns (uint256);
}