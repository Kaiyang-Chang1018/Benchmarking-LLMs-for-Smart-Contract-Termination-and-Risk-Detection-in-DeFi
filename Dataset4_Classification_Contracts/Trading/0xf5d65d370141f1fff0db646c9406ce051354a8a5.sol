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
// OpenZeppelin Contracts (last updated v4.9.0) (finance/VestingWallet.sol)
pragma solidity ^0.8.0;

import "../token/ERC20/utils/SafeERC20.sol";
import "../utils/Address.sol";
import "../utils/Context.sol";

/**
 * @title VestingWallet
 * @dev This contract handles the vesting of Eth and ERC20 tokens for a given beneficiary. Custody of multiple tokens
 * can be given to this contract, which will release the token to the beneficiary following a given vesting schedule.
 * The vesting schedule is customizable through the {vestedAmount} function.
 *
 * Any token transferred to this contract will follow the vesting schedule as if they were locked from the beginning.
 * Consequently, if the vesting has already started, any amount of tokens sent to this contract will (at least partly)
 * be immediately releasable.
 */
contract VestingWallet is Context {
    event EtherReleased(uint256 amount);
    event ERC20Released(address indexed token, uint256 amount);

    uint256 private _released;
    mapping(address => uint256) private _erc20Released;
    address private immutable _beneficiary;
    uint64 private immutable _start;
    uint64 private immutable _duration;

    /**
     * @dev Set the beneficiary, start timestamp and vesting duration of the vesting wallet.
     */
    constructor(address beneficiaryAddress, uint64 startTimestamp, uint64 durationSeconds) payable {
        require(beneficiaryAddress != address(0), "VestingWallet: beneficiary is zero address");
        _beneficiary = beneficiaryAddress;
        _start = startTimestamp;
        _duration = durationSeconds;
    }

    /**
     * @dev The contract should be able to receive Eth.
     */
    receive() external payable virtual {}

    /**
     * @dev Getter for the beneficiary address.
     */
    function beneficiary() public view virtual returns (address) {
        return _beneficiary;
    }

    /**
     * @dev Getter for the start timestamp.
     */
    function start() public view virtual returns (uint256) {
        return _start;
    }

    /**
     * @dev Getter for the vesting duration.
     */
    function duration() public view virtual returns (uint256) {
        return _duration;
    }

    /**
     * @dev Amount of eth already released
     */
    function released() public view virtual returns (uint256) {
        return _released;
    }

    /**
     * @dev Amount of token already released
     */
    function released(address token) public view virtual returns (uint256) {
        return _erc20Released[token];
    }

    /**
     * @dev Getter for the amount of releasable eth.
     */
    function releasable() public view virtual returns (uint256) {
        return vestedAmount(uint64(block.timestamp)) - released();
    }

    /**
     * @dev Getter for the amount of releasable `token` tokens. `token` should be the address of an
     * IERC20 contract.
     */
    function releasable(address token) public view virtual returns (uint256) {
        return vestedAmount(token, uint64(block.timestamp)) - released(token);
    }

    /**
     * @dev Release the native token (ether) that have already vested.
     *
     * Emits a {EtherReleased} event.
     */
    function release() public virtual {
        uint256 amount = releasable();
        _released += amount;
        emit EtherReleased(amount);
        Address.sendValue(payable(beneficiary()), amount);
    }

    /**
     * @dev Release the tokens that have already vested.
     *
     * Emits a {ERC20Released} event.
     */
    function release(address token) public virtual {
        uint256 amount = releasable(token);
        _erc20Released[token] += amount;
        emit ERC20Released(token, amount);
        SafeERC20.safeTransfer(IERC20(token), beneficiary(), amount);
    }

    /**
     * @dev Calculates the amount of ether that has already vested. Default implementation is a linear vesting curve.
     */
    function vestedAmount(uint64 timestamp) public view virtual returns (uint256) {
        return _vestingSchedule(address(this).balance + released(), timestamp);
    }

    /**
     * @dev Calculates the amount of tokens that has already vested. Default implementation is a linear vesting curve.
     */
    function vestedAmount(address token, uint64 timestamp) public view virtual returns (uint256) {
        return _vestingSchedule(IERC20(token).balanceOf(address(this)) + released(token), timestamp);
    }

    /**
     * @dev Virtual implementation of the vesting formula. This returns the amount vested, as a function of time, for
     * an asset given its total historical allocation.
     */
    function _vestingSchedule(uint256 totalAllocation, uint64 timestamp) internal view virtual returns (uint256) {
        if (timestamp < start()) {
            return 0;
        } else if (timestamp > start() + duration()) {
            return totalAllocation;
        } else {
            return (totalAllocation * (timestamp - start())) / duration();
        }
    }
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
// SPDX-License-Identifier: BUSL 1.1
pragma solidity =0.8.22;

import "openzeppelin-contracts/contracts/utils/math/Math.sol";
import "../interfaces/IExchangeConfig.sol";
import "../pools/PoolUtils.sol";

// Finds a circular path after a user's swap has occurred (from WETH to WETH in this case) that results in an arbitrage profit.
abstract contract ArbitrageSearch
    {
	IERC20 immutable public weth;
	IERC20 immutable public usdc;
	IERC20 immutable public usdt;


    constructor( IExchangeConfig _exchangeConfig )
    	{
		// Cached for efficiency
		weth = _exchangeConfig.weth();
		usdc = _exchangeConfig.usdc();
		usdt = _exchangeConfig.usdt();
    	}


	// Returns the middle two tokens in an arbitrage path that starts and ends with WETH.
	// The WETH tokens at the beginning and end of the path are not returned as they are always the same.
	// Full arbitrage cycle is: WETH->arbToken2->arbToken3->WETH
	function _arbitragePath( IERC20 swapTokenIn, IERC20 swapTokenOut ) internal view returns (IERC20 arbToken2, IERC20 arbToken3)
		{
		// swap: USDC->WETH
        // arb: WETH->USDC->USDT->WETH
		if ( address(swapTokenIn) == address(usdc))
		if ( address(swapTokenOut) == address(weth))
			return (usdc, usdt);

		// swap: WETH->USDC
        // arb: WETH->USDT->USDC->WETH
		if ( address(swapTokenIn) == address(weth))
		if ( address(swapTokenOut) == address(usdc))
			return (usdt, usdc);

		// swap: WETH->swapTokenOut
        // arb: WETH->USDC->swapTokenOut->WETH
		if ( address(swapTokenIn) == address(weth))
			return (usdc, swapTokenOut);

		// swap: swapTokenIn->WETH
        // arb: WETH->swapTokenIn->USDC->WETH
		if ( address(swapTokenOut) == address(weth))
			return (swapTokenIn, usdc);

		// swap: swapTokenIn->swapTokenOut
        // arb: WETH->swapTokenOut->swapTokenIn->WETH
		return (swapTokenOut, swapTokenIn);
		}


	// Determine the most significant bit of a non-zero number
    function _mostSignificantBit(uint256 x) internal pure returns (uint256 msb)
    	{
    	unchecked
    		{
			if (x >= 2**128) { x >>= 128; msb += 128; }
			if (x >= 2**64) { x >>= 64; msb += 64; }
			if (x >= 2**32) { x >>= 32; msb += 32; }
			if (x >= 2**16) { x >>= 16; msb += 16; }
			if (x >= 2**8) { x >>= 8; msb += 8; }
			if (x >= 2**4) { x >>= 4; msb += 4; }
			if (x >= 2**2) { x >>= 2; msb += 2; }
			if (x >= 2**1) { x >>= 1; msb += 1; }
			}
	    }


	// Given that x, y and z will be multiplied: determine the bit shift necessary to keep the product contained in 240 bits
	function _shiftRequired( uint256 x, uint256 y, uint256 z ) internal pure returns (uint256)
		{
		unchecked
			{
			// Determine the maximum number of bits required without shifting
			uint256 requiredBits0 = _mostSignificantBit(x) + _mostSignificantBit(y) + _mostSignificantBit(z);

			// Already fits in 240?
			if ( requiredBits0 < 240 )
				return 0;

			// Each number will be shifted so we can divide the required difference by 3
			return Math.ceilDiv( requiredBits0 - 240, 3 );
			}
		}


	// Determine the shift required to keep a0 * b0 * c0 and a1 * b1 * c1 within 240 bits
	function _determineShift( uint256 a0, uint256 b0, uint256 c0, uint256 a1, uint256 b1, uint256 c1 ) internal pure returns (uint256)
		{
		uint256 shift0 = _shiftRequired(a0, b0, c0);
		uint256 shift1 = _shiftRequired(a1, b1, c1);

		return shift0 > shift1 ? shift0 : shift1;
		}


	function _bestArbitrageIn( uint256 a0, uint256 a1, uint256 b0, uint256 b1, uint256 c0, uint256 c1 ) internal pure returns (uint256 bestArbAmountIn)
		{
		// This can be unchecked as the actual arbitrage that is performed when this is non-zero is checked and duplicates the check for profitability.
		// testArbitrageMethodsLarge() checks for proper behavior with extremely large reserves as well.
		unchecked
			{
			// Original derivation: https://github.com/code-423n4/2024-01-salty-findings/issues/419
			// uint256 n0 = A0 * B0 * C0;
			//	uint256 n1 = A1 * B1 * C1;
			//	if (n1 <= n0) return 0;
			//
			//	uint256 m = A1 * B1 + C0 * B0 + C0 * A1;
			//	uint256 z = Math.sqrt(A0 * C1);
			//	z *= Math.sqrt(A1 * B0);
			//	z *= Math.sqrt(B1 * C0);
			//	bestArbAmountIn = (z - n0) / m;

			// Determine the shift required to keep a0 * b0 * c0 and a1 * b1 * c1 each within 240 bits
			uint256 shift = _determineShift( a0, b0, c0, a1, b1, c1 );

			if ( shift > 0 )
				{
				a0 = a0 >> shift;
				a1 = a1 >> shift;
				b0 = b0 >> shift;
				b1 = b1 >> shift;
				c0 = c0 >> shift;
				c1 = c1 >> shift;
				}

			// Each variable will use less than 80 bits
			uint256 n0 = a0 * b0 * c0;
			uint256 n1 = a1 * b1 * c1;

			if (n1 <= n0)
				return 0;

			uint256 m = a1 *  b1 + c0 * ( b0 + a1 );

			// Calculating n0 * n1 directly would overflow under some situations.
			// Multiply the sqrt's instead - effectively keeping the max size the same
			uint256 z = Math.sqrt(n0) * Math.sqrt(n1);

			bestArbAmountIn = ( z - n0 ) / m;
			if ( bestArbAmountIn == 0 )
				return 0;

			// Needed for the below arbitrage profit testing
			if ( shift > 0 )
				{
				// Convert back to normal scaling
				bestArbAmountIn = bestArbAmountIn << shift;

				a0 = a0 << shift;
				a1 = a1 << shift;
				b0 = b0 << shift;
				b1 = b1 << shift;
				c0 = c0 << shift;
				c1 = c1 << shift;
				}

			// Make sure bestArbAmountIn arbitrage is actually profitable (or else it will revert when actually performed in Pools.sol)
			uint256 amountOut = (a1 * bestArbAmountIn) / (a0 + bestArbAmountIn);
			amountOut = (b1 * amountOut) / (b0 + amountOut);
			amountOut = (c1 * amountOut) / (c0 + amountOut);

			if ( amountOut < bestArbAmountIn )
				return 0;
			}
		}
	}
// SPDX-License-Identifier: BUSL 1.1
pragma solidity =0.8.22;

import "../../rewards/interfaces/ISaltRewards.sol";
import "../../pools/interfaces/IPools.sol";
import "../../interfaces/ISalt.sol";

interface IDAO
	{
	function finalizeBallot( uint256 ballotID ) external;
	function manuallyRemoveBallot( uint256 ballotID ) external;

	function withdrawFromDAO( IERC20 token ) external returns (uint256 withdrawnAmount);

	// Views
	function pools() external view returns (IPools);
	function websiteURL() external view returns (string memory);
	function countryIsExcluded( string calldata country ) external view returns (bool);
	}
// SPDX-License-Identifier: BUSL 1.1
pragma solidity =0.8.22;


interface IAccessManager
	{
	function excludedCountriesUpdated() external;
	function grantAccess(bytes calldata signature) external;

	// Views
	function geoVersion() external view returns (uint256);
	function walletHasAccess(address wallet) external view returns (bool);
	}
// SPDX-License-Identifier: BUSL 1.1
pragma solidity =0.8.22;

import "openzeppelin-contracts/contracts/finance/VestingWallet.sol";
import "../staking/interfaces/ILiquidity.sol";
import "../launch/interfaces/IInitialDistribution.sol";
import "../rewards/interfaces/IRewardsEmitter.sol";
import "../rewards/interfaces/ISaltRewards.sol";
import "../rewards/interfaces/IEmissions.sol";
import "../interfaces/IAccessManager.sol";
import "../launch/interfaces/IAirdrop.sol";
import "../dao/interfaces/IDAO.sol";
import "../interfaces/ISalt.sol";
import "./IUpkeep.sol";


interface IExchangeConfig
	{
	function setContracts( IDAO _dao, IUpkeep _upkeep, IInitialDistribution _initialDistribution, VestingWallet _teamVestingWallet, VestingWallet _daoVestingWallet ) external; // onlyOwner
	function setAccessManager( IAccessManager _accessManager ) external; // onlyOwner

	// Views
	function salt() external view returns (ISalt);
	function wbtc() external view returns (IERC20);
	function weth() external view returns (IERC20);
	function usdc() external view returns (IERC20);
	function usdt() external view returns (IERC20);

	function daoVestingWallet() external view returns (VestingWallet);
    function teamVestingWallet() external view returns (VestingWallet);
    function initialDistribution() external view returns (IInitialDistribution);

	function accessManager() external view returns (IAccessManager);
	function dao() external view returns (IDAO);
	function upkeep() external view returns (IUpkeep);
	function teamWallet() external view returns (address);

	function walletHasAccess( address wallet ) external view returns (bool);
	}
// SPDX-License-Identifier: BUSL 1.1
pragma solidity =0.8.22;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";


interface ISalt is IERC20
	{
	function burnTokensInContract() external;

	// Views
	function totalBurned() external view returns (uint256);
	}
// SPDX-License-Identifier: BUSL 1.1
pragma solidity =0.8.22;


interface IUpkeep
	{
	function performUpkeep() external;

	// Views
	function currentRewardsForCallingPerformUpkeep() external view returns (uint256);
	function lastUpkeepTimeEmissions() external view returns (uint256);
	function lastUpkeepTimeRewardsEmitters() external view returns (uint256);
	}
// SPDX-License-Identifier: BUSL 1.1
pragma solidity =0.8.22;


interface IAirdrop
	{
	function authorizeWallet( address wallet, uint256 saltAmount ) external;
	function allowClaiming() external;
	function claim() external;

	// Views
	function claimedByUser( address wallet) external view returns (uint256);
	function claimingAllowed() external view returns (bool);
	function claimingStartTimestamp() external view returns (uint256);
	function claimableAmount(address wallet) external view returns (uint256);
    function airdropForUser( address wallet ) external view returns (uint256);
	}
// SPDX-License-Identifier: BUSL 1.1
pragma solidity =0.8.22;


interface IBootstrapBallot
	{
	function vote( bool voteStartExchangeYes, uint256 saltAmount, bytes calldata signature ) external;
	function finalizeBallot() external;

	function authorizeAirdrop2( uint256 saltAmount, bytes calldata signature ) external;
	function finalizeAirdrop2() external;

	// Views
	function claimableTimestamp1() external view returns (uint256);
	function claimableTimestamp2() external view returns (uint256);

	function hasVoted(address user) external view returns (bool);
	function ballotFinalized() external view returns (bool);

	function startExchangeYes() external view returns (uint256);
	function startExchangeNo() external view returns (uint256);
	}
// SPDX-License-Identifier: BUSL 1.1
pragma solidity =0.8.22;

import "./IBootstrapBallot.sol";
import "./IAirdrop.sol";


interface IInitialDistribution
	{
	function distributionApproved( IAirdrop airdrop1, IAirdrop airdrop2 ) external;

	// Views
	function bootstrapBallot() external view returns (IBootstrapBallot);
	}
// SPDX-License-Identifier: BUSL 1.1
pragma solidity =0.8.22;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../interfaces/IExchangeConfig.sol";
import "./interfaces/IPoolsConfig.sol";
import "./interfaces/IPoolStats.sol";
import "./PoolUtils.sol";


// Keeps track of the arbitrage profits generated by pools (for rewards distribution proportional to the profits generated per pool).
abstract contract PoolStats is IPoolStats
	{
	uint64 constant INVALID_POOL_ID = type(uint64).max;

	IExchangeConfig immutable public exchangeConfig;
	IPoolsConfig immutable public poolsConfig;
	IERC20 immutable public _weth;

	// poolID(arbToken2, arbToken3) => arbitrage profits contributed since the last performUpkeep
	mapping(bytes32=>uint256) public _arbitrageProfits;

	// Maps poolID(arbToken2, arbToken3) => the indicies (within the whitelistedPools array) of the pools involved in WETH->arbToken2->arbToken3->WETH
	mapping(bytes32=>ArbitrageIndicies) public _arbitrageIndicies;


    constructor( IExchangeConfig _exchangeConfig, IPoolsConfig _poolsConfig )
    	{
		exchangeConfig = _exchangeConfig;
		poolsConfig = _poolsConfig;

		_weth = exchangeConfig.weth();
    	}


	// Record that arbitrageProfit was generated and the a specific arbitrage path generated it (which is defined by the middle two tokens in WETH->arbToken2->arbToken3->WETH)
	function _updateProfitsFromArbitrage( IERC20 arbToken2, IERC20 arbToken3, uint256 arbitrageProfit ) internal
		{
		// Though three pools contributed to the arbitrage we can record just the middle one as we know the input and output token will be WETH
		bytes32 poolID = PoolUtils._poolID( arbToken2, arbToken3 );

		_arbitrageProfits[poolID] += arbitrageProfit;
		}


	// Called at the end of Upkeep.performUpkeep to reset the arbitrage stats for the pools
	function clearProfitsForPools() external
		{
		require(msg.sender == address(exchangeConfig.upkeep()), "PoolStats.clearProfitsForPools is only callable from the Upkeep contract" );

		bytes32[] memory poolIDs = poolsConfig.whitelistedPools();

		// Don't fully set profits to zero to avoid the increased gas cost of overwriting zero
		for( uint256 i = 0; i < poolIDs.length; i++ )
			_arbitrageProfits[ poolIDs[i] ] = 1;
		}


	// The index of pool tokenA/tokenB within the whitelistedPools array.
	// Should always find a value as only whitelisted pools are used in the arbitrage path.
	// Returns uint64.max in the event of failed lookup
	function _poolIndex( IERC20 tokenA, IERC20 tokenB, bytes32[] memory poolIDs ) internal pure returns (uint64 index)
		{
		bytes32 poolID = PoolUtils._poolID( tokenA, tokenB );

		for( uint256 i = 0; i < poolIDs.length; i++ )
			{
			if (poolID == poolIDs[i])
				return uint64(i);
			}

		return INVALID_POOL_ID;
		}


	// Traverse the current whitelisted poolIDs and update the indicies of each pool that would contribute to arbitrage for it.
	// Maps poolID(arbToken2, arbToken3) => the indicies (within the whitelistedPools array) of the pools involved in WETH->arbToken2->arbToken3->WETH arbitrage.
	function updateArbitrageIndicies() public
		{
		bytes32[] memory poolIDs = poolsConfig.whitelistedPools();

		for( uint256 i = 0; i < poolIDs.length; i++ )
			{
			bytes32 poolID = poolIDs[i];
			(IERC20 arbToken2, IERC20 arbToken3) = poolsConfig.underlyingTokenPair(poolID);

			// The middle two tokens can never be WETH in a valid arbitrage path as the path is WETH->arbToken2->arbToken3->WETH.
			if ( (arbToken2 != _weth) && (arbToken3 != _weth) )
				{
				uint64 poolIndex1 = _poolIndex( _weth, arbToken2, poolIDs );
				uint64 poolIndex2 = _poolIndex( arbToken2, arbToken3, poolIDs );
				uint64 poolIndex3 = _poolIndex( arbToken3, _weth, poolIDs );

				// Check if the indicies in storage have the correct values - and if not then update them
				ArbitrageIndicies memory indicies = _arbitrageIndicies[poolID];
				if ( ( poolIndex1 != indicies.index1 ) || ( poolIndex2 != indicies.index2 ) || ( poolIndex3 != indicies.index3 ) )
					_arbitrageIndicies[poolID] = ArbitrageIndicies(poolIndex1, poolIndex2, poolIndex3);
				}
			}
		}


	// Examine the arbitrage that has been generated since the last Upkeep.performUpkeep call and credit the pools that have contributed towards it.
	// The calculated sums for each pool will then be used to proportionally distribute SALT rewards to each of the contributing pools.
	function _calculateArbitrageProfits( bytes32[] memory poolIDs, uint256[] memory _calculatedProfits ) internal view
		{
		for( uint256 i = 0; i < poolIDs.length; i++ )
			{
			// references poolID(arbToken2, arbToken3) which defines the arbitage path of WETH->arbToken2->arbToken3->WETH
			bytes32 poolID = poolIDs[i];

			// Split the arbitrage profit between all the pools that contributed to generating the arbitrage for the referenced pool.
			uint256 arbitrageProfit = _arbitrageProfits[poolID] / 3;
			if ( arbitrageProfit > 0 )
				{
				ArbitrageIndicies memory indicies = _arbitrageIndicies[poolID];

				if ( indicies.index1 != INVALID_POOL_ID )
					_calculatedProfits[indicies.index1] += arbitrageProfit;

				if ( indicies.index2 != INVALID_POOL_ID )
					_calculatedProfits[indicies.index2] += arbitrageProfit;

				if ( indicies.index3 != INVALID_POOL_ID )
					_calculatedProfits[indicies.index3] += arbitrageProfit;
				}
			}
		}


	// === VIEWS ===

	// Look at the arbitrage that has been generated since the last performUpkeep and determine how much each of the pools contributed to those generated profits.
	// Returns the profits for all of the current whitelisted pools
	function profitsForWhitelistedPools() external view returns (uint256[] memory _calculatedProfits)
		{
		bytes32[] memory poolIDs = poolsConfig.whitelistedPools();

		_calculatedProfits = new uint256[](poolIDs.length);
		_calculateArbitrageProfits( poolIDs, _calculatedProfits );
		}


	function arbitrageIndicies(bytes32 poolID) external view returns (ArbitrageIndicies memory)
		{
		return _arbitrageIndicies[poolID];
		}
	}
pragma solidity =0.8.22;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";


library PoolUtils
	{
	// Token reserves less than dust are treated as if they don't exist at all.
	// With the 18 decimals that are used for most tokens, DUST has a value of 0.0000000000000001
	uint256 constant public DUST = 100;

	// A special pool that represents staked SALT that is not associated with any actual liquidity pool.
    bytes32 constant public STAKED_SALT = bytes32(0);


    // Return the unique poolID for the given two tokens.
    // Tokens are sorted before being hashed to make reversed pairs equivalent.
    function _poolID( IERC20 tokenA, IERC20 tokenB ) internal pure returns (bytes32 poolID)
    	{
        // See if the token orders are flipped
        if ( uint160(address(tokenB)) < uint160(address(tokenA)) )
            return keccak256(abi.encodePacked(address(tokenB), address(tokenA)));

        return keccak256(abi.encodePacked(address(tokenA), address(tokenB)));
    	}


    // Return the unique poolID and whether or not it is flipped
    function _poolIDAndFlipped( IERC20 tokenA, IERC20 tokenB ) internal pure returns (bytes32 poolID, bool flipped)
    	{
        // See if the token orders are flipped
        if ( uint160(address(tokenB)) < uint160(address(tokenA)) )
            return (keccak256(abi.encodePacked(address(tokenB), address(tokenA))), true);

        return (keccak256(abi.encodePacked(address(tokenA), address(tokenB))), false);
    	}
	}
// SPDX-License-Identifier: BUSL 1.1
pragma solidity =0.8.22;

import "openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";
import "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "../interfaces/IExchangeConfig.sol";
import "../arbitrage/ArbitrageSearch.sol";
import "./interfaces/IPoolsConfig.sol";
import "./interfaces/IPools.sol";
import "./PoolStats.sol";
import "./PoolUtils.sol";


// The Pools contract stores the reserves that are used for swaps within the DEX.
// It handles deposits, arbitrage, and keeps stats for proportional rewards distribution to the liquidity providers.
//
// Only the Liquidity contract can actually call addLiquidity and removeLiquidity.
// User liquidity accounting is done by Liquidity (via its derivation of StakingRewards).

contract Pools is IPools, ReentrancyGuard, PoolStats, ArbitrageSearch, Ownable
	{
	event LiquidityAdded(IERC20 indexed tokenA, IERC20 indexed tokenB, uint256 addedAmountA, uint256 addedAmountB, uint256 addedLiquidity);
	event LiquidityRemoved(IERC20 indexed tokenA, IERC20 indexed tokenB, uint256 reclaimedA, uint256 reclaimedB, uint256 removedLiquidity);
	event TokenDeposit(address indexed user, IERC20 indexed token, uint256 amount);
	event TokenWithdrawal(address indexed user, IERC20 indexed token, uint256 amount);
	event SwapAndArbitrage(address indexed user, IERC20 indexed swapTokenIn, IERC20 indexed swapTokenOut, uint256 swapAmountIn, uint256 swapAmountOut, uint256 arbitrageProfit);

	using SafeERC20 for IERC20;

	struct PoolReserves
		{
		uint128 reserve0;						// The token reserves such that address(token0) < address(token1)
		uint128 reserve1;
		}


	IDAO public dao;
	ILiquidity public liquidity;
	ISalt public salt;

	// Set to true when starting the exchange is approved by the bootstrapBallot
	bool public exchangeIsLive;

	// Keeps track of the pool reserves by poolID
	mapping(bytes32=>PoolReserves) private _poolReserves;

	// User token balances for deposited tokens
	mapping(address=>mapping(IERC20=>uint256)) private _userDeposits;

	// Used to prevent splitting large swaps within a single block into smaller ones as doing so allows for greater price manipulation without consequence from the arbitrage rebalancing.
	mapping(address => uint) private lastSwappedBlocks;


	constructor( IExchangeConfig _exchangeConfig, IPoolsConfig _poolsConfig )
	ArbitrageSearch(_exchangeConfig)
	PoolStats(_exchangeConfig, _poolsConfig)
		{
		salt = _exchangeConfig.salt();
		}


	// Allow users to make only one swap per block
	modifier oneUserSwapPerBlock()
		{
		require(lastSwappedBlocks[msg.sender] != block.number, "User already swapped in this block");
        _;
        lastSwappedBlocks[msg.sender] = block.number;
        }


	modifier ensureNotExpired(uint256 deadline)
		{
		require(block.timestamp <= deadline, "TX EXPIRED");
		_;
		}


	// This will be called only once - at deployment time
	function setContracts( IDAO _dao, ILiquidity _liquidity ) external onlyOwner
		{
		dao = _dao;
		liquidity = _liquidity;

		// setContracts can only be called once
		renounceOwnership();
		}


	function startExchangeApproved() external nonReentrant
		{
    	require( msg.sender == address(exchangeConfig.initialDistribution().bootstrapBallot()), "Pools.startExchangeApproved can only be called from the BootstrapBallot contract" );

		// Make sure that the arbitrage indicies for the whitelisted pools are updated before starting the exchange
		updateArbitrageIndicies();

		exchangeIsLive = true;
		}


	// Add the given amount of two tokens to the specified liquidity pool.
	// The maximum amount of tokens is added while having the added amount have the same ratio as the current reserves.
	function _addLiquidity( bytes32 poolID, uint256 maxAmount0, uint256 maxAmount1, uint256 totalLiquidity ) internal returns(uint256 addedAmount0, uint256 addedAmount1, uint256 addedLiquidity)
		{
		PoolReserves storage reserves = _poolReserves[poolID];
		uint256 reserve0 = reserves.reserve0;
		uint256 reserve1 = reserves.reserve1;

		// If either reserve is zero then consider the pool to be empty and that the added liquidity will become the initial token ratio
		if ( ( reserve0 == 0 ) || ( reserve1 == 0 ) )
			{
			// Update the reserves
			reserves.reserve0 += uint128(maxAmount0);
			reserves.reserve1 += uint128(maxAmount1);

			// Default liquidity will be the addition of both maxAmounts in case one of them is much smaller (has smaller decimals)
			return ( maxAmount0, maxAmount1, (maxAmount0 + maxAmount1) );
			}

		// Add liquidity to the pool proportional to the current existing token reserves in the pool.
		// First, try the proportional amount of tokenB for the given maxAmountA
		uint256 proportionalB = ( maxAmount0 * reserve1 ) / reserve0;

		// proportionalB too large for the specified maxAmountB?
		if ( proportionalB > maxAmount1 )
			{
			// Use maxAmountB and a proportional amount for tokenA instead
			addedAmount0 = ( maxAmount1 * reserve0 ) / reserve1;
			addedAmount1 = maxAmount1;
			}
		else
			{
			addedAmount0 = maxAmount0;
			addedAmount1 = proportionalB;
			}

		// Ensure that the added amounts are at least DUST
		require( addedAmount0 > PoolUtils.DUST, "Added liquidity for token 0 less than DUST" );
		require( addedAmount1 > PoolUtils.DUST, "Added liquidity for token 1 less than DUST" );

		// Update the reserves
		reserves.reserve0 += uint128(addedAmount0);
		reserves.reserve1 += uint128(addedAmount1);

		// Determine the amount of liquidity that will be given to the user to reflect their share of the total liquidity.
		addedLiquidity = (totalLiquidity * (addedAmount0+addedAmount1) ) / (reserve0+reserve1);
		}


	// Add liquidity to the specified pool (must be a whitelisted pool)
	// Only callable from the Liquidity contract - so it can specify totalLiquidity with authority
	function addLiquidity( IERC20 tokenA, IERC20 tokenB, uint256 maxAmountA, uint256 maxAmountB, uint256 minAddedAmountA, uint256 minAddedAmountB, uint256 totalLiquidity ) external nonReentrant returns (uint256 addedAmountA, uint256 addedAmountB, uint256 addedLiquidity)
		{
		require( msg.sender == address(liquidity), "Pools.addLiquidity is only callable from the Liquidity contract" );
		require( exchangeIsLive, "The exchange is not yet live" );
		require( address(tokenA) != address(tokenB), "Cannot add liquidity for duplicate tokens" );

		require( maxAmountA > PoolUtils.DUST, "The amount of tokenA to add is too small" );
		require( maxAmountB > PoolUtils.DUST, "The amount of tokenB to add is too small" );

		(bytes32 poolID, bool flipped) = PoolUtils._poolIDAndFlipped(tokenA, tokenB);

		// Flip the users arguments if they are not in reserve token order with address(tokenA) < address(tokenB)
		if ( flipped )
			(addedAmountB, addedAmountA, addedLiquidity) = _addLiquidity( poolID, maxAmountB, maxAmountA, totalLiquidity );
		else
			(addedAmountA, addedAmountB, addedLiquidity) = _addLiquidity( poolID, maxAmountA, maxAmountB, totalLiquidity );

		// Make sure the minimum liquidity has been added
		require( addedAmountA >= minAddedAmountA, "Insufficient tokenA added to liquidity" );
		require( addedAmountB >= minAddedAmountB, "Insufficient tokenB added to liquidity" );

		// Transfer the tokens from the sender - only tokens without fees should be whitelisted on the DEX
		tokenA.safeTransferFrom(msg.sender, address(this), addedAmountA );
		tokenB.safeTransferFrom(msg.sender, address(this), addedAmountB );

		emit LiquidityAdded(tokenA, tokenB, addedAmountA, addedAmountB, addedLiquidity);
		}


	// Remove liquidity for the user and reclaim the underlying tokens
	// Only callable from the Liquidity contract - so it can specify totalLiquidity with authority
	function removeLiquidity( IERC20 tokenA, IERC20 tokenB, uint256 liquidityToRemove, uint256 minReclaimedA, uint256 minReclaimedB, uint256 totalLiquidity ) external nonReentrant returns (uint256 reclaimedA, uint256 reclaimedB)
		{
		require( msg.sender == address(liquidity), "Pools.removeLiquidity is only callable from the Liquidity contract" );
		require( liquidityToRemove > 0, "The amount of liquidityToRemove cannot be zero" );

		(bytes32 poolID, bool flipped) = PoolUtils._poolIDAndFlipped(tokenA, tokenB);

		// Determine how much liquidity is being withdrawn and round down in favor of the protocol
		PoolReserves storage reserves = _poolReserves[poolID];

		if (reserves.reserve0 <= reserves.reserve1 )
			{
			reclaimedA = ( reserves.reserve0 * liquidityToRemove ) / totalLiquidity;
			reclaimedB = ( reserves.reserve1 * reclaimedA ) / reserves.reserve0;
			}
		else
			{
			reclaimedB = ( reserves.reserve1 * liquidityToRemove ) / totalLiquidity;
			reclaimedA = ( reserves.reserve0 * reclaimedB ) / reserves.reserve1;
			}

		reserves.reserve0 -= uint128(reclaimedA);
		reserves.reserve1 -= uint128(reclaimedB);

		// Make sure that removing liquidity doesn't drive either of the reserves below DUST.
		// This is to ensure that ratios remain relatively constant even after a maximum withdrawal.
        require((reserves.reserve0 >= PoolUtils.DUST) && (reserves.reserve1 >= PoolUtils.DUST), "Insufficient reserves after liquidity removal");

		// Switch reclaimed amounts back to the order that was specified in the call arguments so they make sense to the caller
		if (flipped)
			(reclaimedA,reclaimedB) = (reclaimedB,reclaimedA);

		require( (reclaimedA >= minReclaimedA) && (reclaimedB >= minReclaimedB), "Insufficient underlying tokens returned" );

		// Send the reclaimed tokens to the user
		tokenA.safeTransfer( msg.sender, reclaimedA );
		tokenB.safeTransfer( msg.sender, reclaimedB );

		emit LiquidityRemoved(tokenA, tokenB, reclaimedA, reclaimedB, liquidityToRemove);
		}


	// Allow users to deposit tokens into the contract.
	// This is not rewarded or considered staking in any way.  It's simply a way to reduce gas costs by preventing transfers at swap time.
	function deposit( IERC20 token, uint256 amount ) external nonReentrant
		{
        require( amount > PoolUtils.DUST, "Deposit amount too small");

		_userDeposits[msg.sender][token] += amount;

		// Transfer the tokens from the sender - only tokens without fees should be whitelisted on the DEX
		token.safeTransferFrom(msg.sender, address(this), amount );

		emit TokenDeposit(msg.sender, token, amount);
		}


	// Withdraw tokens that were previously deposited
    function withdraw( IERC20 token, uint256 amount ) external nonReentrant
    	{
    	require( _userDeposits[msg.sender][token] >= amount, "Insufficient balance to withdraw specified amount" );
        require( amount > PoolUtils.DUST, "Withdraw amount too small");

		_userDeposits[msg.sender][token] -= amount;

    	// Send the token to the user
    	token.safeTransfer( msg.sender, amount );

    	emit TokenWithdrawal(msg.sender, token, amount);
    	}


	// Swap amountIn tokens for amountOut tokens in the direction specified by flipped and update the reserves.
	// Only the reserves are updated - the function does not adjust deposited user balances or do ERC20 transfers.
	// Assumes that the reserves have already been checked for minimal necessary liquidity.
    function _adjustReservesForSwap( PoolReserves storage reserves, bool flipped, uint256 amountIn ) internal returns (uint256 amountOut)
    	{
		// Constant Product AMM Math
		// k=r0*r1																	• product of reserves is constant k
		// k=(r0+amountIn)*(r1-amountOut)							• add some token0 to r0 and swap it for some token1 which is removed from r1
		// r1-amountOut=k/(r0+amountIn)								• divide by (r0+amountIn) and flip
		// amountOut=r1-k/(r0+amountIn)								• multiply by -1 and isolate amountOut
		// amountOut(r0+amountIn)=r1(r0+amountIn)-k		• multiply by (r0+amountIn)
		// amountOut(r0+amountIn)=r1*r0+r1*amountIn-k	• multiply r1 by (r0+amountIn)
		// amountOut(r0+amountIn)=k+r1*amountIn-k			• r0*r1=k (from above)
		// amountOut(r0+amountIn)=r1*amountIn					• cancel k
		// amountOut=r1*amountIn/(r0+amountIn)				• isolate amountOut

        uint256 reserve0 = reserves.reserve0;
        uint256 reserve1 = reserves.reserve1;

		// See if the reserves should be flipped
        if (flipped)
        	{
			reserve1 += amountIn;
			amountOut = reserve0 * amountIn / reserve1;
			reserve0 -= amountOut;
        	}
        else
        	{
			reserve0 += amountIn;
			amountOut = reserve1 * amountIn / reserve0;
			reserve1 -= amountOut;
        	}

		// Make sure that the reserves after swap are greater than DUST
        require( (reserve0 > PoolUtils.DUST) && (reserve1 > PoolUtils.DUST), "Insufficient reserves after swap");

		// Update the reserves with an overflow check
		require( (reserve0 <= type(uint128).max) && (reserve1 <= type(uint128).max), "Reserves overflow after swap" );

		reserves.reserve0 = uint128(reserve0);
		reserves.reserve1 = uint128(reserve1);
    	}


    // Arbitrage a token to itself along a specified circular path (starting and ending with WETH), taking advantage of imbalances in the exchange pools.
    // Does not require any deposited tokens to make the call, but requires that the resulting amountOut is greater than the specified arbitrageAmountIn.
    // Essentially the caller virtually "borrows" arbitrageAmountIn of the starting token and virtually "repays" it from their received amountOut at the end of the swap chain.
    // The extra amountOut (compared to arbitrageAmountIn) is the arbitrageProfit.
	function _arbitrage(uint256 arbitrageAmountIn, PoolReserves storage reservesA, PoolReserves storage reservesB, PoolReserves storage reservesC, bool flippedA, bool flippedB, bool flippedC ) internal returns (uint256 arbitrageProfit)
		{
		uint256 amountOut = _adjustReservesForSwap( reservesA, flippedA, arbitrageAmountIn );
		amountOut = _adjustReservesForSwap( reservesB, flippedB, amountOut );
		amountOut = _adjustReservesForSwap( reservesC, flippedC, amountOut );

		// Will revert if amountOut < arbitrageAmountIn
		arbitrageProfit = amountOut - arbitrageAmountIn;

		// Immediately swap the generated WETH arbitrage profits to SALT
		(bytes32 poolID, bool flipped) = PoolUtils._poolIDAndFlipped(weth, salt);
        PoolReserves storage reserves = _poolReserves[poolID];

        // Only swap for SALT with sufficient reserves
		if ( ( reserves.reserve0 > PoolUtils.DUST ) && ( reserves.reserve1 > PoolUtils.DUST ) )
			{
			uint256 saltOut = _adjustReservesForSwap(reserves, flipped, arbitrageProfit);

			// Deposit the swapped SALT for the DAO - to be used later within DAO.performUpkeep
			_userDeposits[address(dao)][salt] += saltOut;
			}
		}


	// Check to see if profitable arbitrage is possible after the user swap that was just made
	// Check the arbitrage path: WETH->arbToken2->arbToken3->WETH
	function _attemptArbitrage( IERC20 arbToken2, IERC20 arbToken3 ) internal returns (uint256 arbitrageProfit)
		{
		bytes32 poolID;
		bool flippedA;
		bool flippedB;
		bool flippedC;

		PoolReserves storage reservesA;
		PoolReserves storage reservesB;
		PoolReserves storage reservesC;

		// Given the specified arbitrage path, determine the best arbitrageAmountIn to use
		uint256 arbitrageAmountIn;
			{
			(poolID, flippedA) = PoolUtils._poolIDAndFlipped(weth, arbToken2);
			reservesA = _poolReserves[poolID];
			(uint256 a0, uint256 a1) = (reservesA.reserve0, reservesA.reserve1 );
			if (flippedA)
				(a0, a1) = (a1, a0);


			(poolID, flippedB) = PoolUtils._poolIDAndFlipped(arbToken2, arbToken3);
			reservesB = _poolReserves[poolID];
			(uint256 b0, uint256 b1) = (reservesB.reserve0, reservesB.reserve1 );
			if (flippedB)
				(b0, b1) = (b1, b0);


			(poolID, flippedC) = PoolUtils._poolIDAndFlipped(arbToken3, weth);
			reservesC = _poolReserves[poolID];
			(uint256 c0, uint256 c1) = (reservesC.reserve0, reservesC.reserve1 );
			if (flippedC)
				(c0, c1) = (c1, c0);

			// Determine the best amount of WETH to start the arbitrage with
			if ( a0 > PoolUtils.DUST && a1 > PoolUtils.DUST && b0 > PoolUtils.DUST && b1 > PoolUtils.DUST && c0 > PoolUtils.DUST && c1 > PoolUtils.DUST )
				arbitrageAmountIn = _bestArbitrageIn(a0, a1, b0, b1, c0, c1 );
			}

		// If arbitrage is viable, then perform it
		if (arbitrageAmountIn > 0)
			{
			 arbitrageProfit = _arbitrage(arbitrageAmountIn, reservesA, reservesB, reservesC, flippedA, flippedB, flippedC);

			// Update the stats related to the pools that contributed to the arbitrage so they can be rewarded proportionally later.
			// The arbitrage path can be identified by the middle tokens arbToken2 and arbToken3 (with WETH always on both ends)
			_updateProfitsFromArbitrage( arbToken2, arbToken3, arbitrageProfit );
			 }
		}


	// Adjust the reserves for swapping between the two specified tokens and then immediately attempt arbitrage.
	// Does not require exchange access for the sending wallet.
	function _adjustReservesForSwapAndAttemptArbitrage( IERC20 swapTokenIn, IERC20 swapTokenOut, uint256 swapAmountIn, uint256 minAmountOut ) internal returns (uint256 swapAmountOut)
		{
		// Place the user swap first
		(bytes32 poolID, bool flipped) = PoolUtils._poolIDAndFlipped(swapTokenIn, swapTokenOut);
        PoolReserves storage reserves = _poolReserves[poolID];

        // Revert if reserves are insufficient
        require((reserves.reserve0 > PoolUtils.DUST) && (reserves.reserve1 > PoolUtils.DUST), "Insufficient reserves before swap");
		swapAmountOut = _adjustReservesForSwap( reserves, flipped, swapAmountIn );

		// Make sure the swap meets the minimums specified by the user
		require( swapAmountOut >= minAmountOut, "Insufficient resulting token amount" );

		// The user's swap has just been made - attempt atomic arbitrage to rebalance the pool and yield arbitrage profit.

		// Determine the arbitrage path for the given user swap.
		// Arbitrage path returned as: weth->arbToken2->arbToken3->weth
		(IERC20 arbToken2, IERC20 arbToken3) = _arbitragePath( swapTokenIn, swapTokenOut );
		uint256 arbitrageProfit = _attemptArbitrage( arbToken2, arbToken3 );

		emit SwapAndArbitrage(msg.sender, swapTokenIn, swapTokenOut, swapAmountIn, swapAmountOut, arbitrageProfit);
		}


    // Swap one token for another via a direct whitelisted pool.
    // Having simpler swaps without multiple tokens in the swap chain makes it simpler (and less expensive gas wise) to find suitable arbitrage opportunities.
    // Cheap arbitrage gas-wise is important as arbitrage will be atomically attempted with every user swap transaction.
    // Requires that the first token in the chain has already been deposited for the caller.
	function swap( IERC20 swapTokenIn, IERC20 swapTokenOut, uint256 swapAmountIn, uint256 minAmountOut, uint256 deadline ) external oneUserSwapPerBlock nonReentrant ensureNotExpired(deadline) returns (uint256 swapAmountOut)
		{
		// Confirm and adjust user deposits
		mapping(IERC20=>uint256) storage userDeposits = _userDeposits[msg.sender];

    	require( userDeposits[swapTokenIn] >= swapAmountIn, "Insufficient deposited token balance of initial token" );
		userDeposits[swapTokenIn] -= swapAmountIn;

		swapAmountOut = _adjustReservesForSwapAndAttemptArbitrage(swapTokenIn, swapTokenOut, swapAmountIn, minAmountOut );

		// Deposit the final tokenOut for the caller
		userDeposits[swapTokenOut] += swapAmountOut;
		}


	// Deposit tokenIn, swap to tokenOut and then have tokenOut sent to the sender
	function depositSwapWithdraw(IERC20 swapTokenIn, IERC20 swapTokenOut, uint256 swapAmountIn, uint256 minAmountOut, uint256 deadline ) external oneUserSwapPerBlock nonReentrant ensureNotExpired(deadline) returns (uint256 swapAmountOut)
		{
		// Transfer the tokens from the sender - only tokens without fees should be whitelisted on the DEX
		swapTokenIn.safeTransferFrom(msg.sender, address(this), swapAmountIn );

		swapAmountOut = _adjustReservesForSwapAndAttemptArbitrage(swapTokenIn, swapTokenOut, swapAmountIn, minAmountOut );

    	// Send tokenOut to the user
    	swapTokenOut.safeTransfer( msg.sender, swapAmountOut );
		}


	// Deposit tokenIn, swap to tokenOut without arbitrage and then have tokenOut sent to the sender.
	// Only callable by the Liquidity contract
	function depositZapSwapWithdraw(IERC20 zapSwapTokenIn, IERC20 zapSwapTokenOut, uint256 zapSwapAmountIn ) external returns (uint256 zapSwapAmountOut)
		{
		require( msg.sender == address(liquidity), "Pools.depositZapSwapWithdraw is only callable from the Liquidity contract" );

		// Transfer the tokens from the sender - only tokens without fees should be whitelisted on the DEX
		zapSwapTokenIn.safeTransferFrom(msg.sender, address(this), zapSwapAmountIn );

		// Perform the zap swap without arbitrage or minimum checks (as the users final swap will be checked for relevant minimums).
		// PoolMath.determineZapSwapAmount already checked for reservers > DUST as well.
		(bytes32 poolID, bool flipped) = PoolUtils._poolIDAndFlipped(zapSwapTokenIn, zapSwapTokenOut);
        PoolReserves storage reserves = _poolReserves[poolID];

		// Prevent users from zapping too much at once as they may encounter unexpected slippage
		if ( flipped )
			require( zapSwapAmountIn < reserves.reserve1 / 100, "Cannot zap more than 1% of the reserves" );
		else
			require( zapSwapAmountIn < reserves.reserve0 / 100, "Cannot zap more than 1% of the reserves" );

		zapSwapAmountOut = _adjustReservesForSwap( reserves, flipped, zapSwapAmountIn );

    	// Send tokenOut to the user
    	zapSwapTokenOut.safeTransfer( msg.sender, zapSwapAmountOut );
		}


	// A convenience method to perform two swaps in one transaction
	function depositDoubleSwapWithdraw( IERC20 swapTokenIn, IERC20 swapTokenMiddle, IERC20 swapTokenOut, uint256 swapAmountIn, uint256 minAmountOut, uint256 deadline ) external oneUserSwapPerBlock nonReentrant ensureNotExpired(deadline) returns (uint256 swapAmountOut)
		{
		swapTokenIn.safeTransferFrom(msg.sender, address(this), swapAmountIn );

		uint256 middleAmountOut = _adjustReservesForSwapAndAttemptArbitrage(swapTokenIn, swapTokenMiddle, swapAmountIn, 0 );
		swapAmountOut = _adjustReservesForSwapAndAttemptArbitrage(swapTokenMiddle, swapTokenOut, middleAmountOut, minAmountOut );

    	swapTokenOut.safeTransfer( msg.sender, swapAmountOut );
		}


	// === VIEWS ===

	// The pool reserves for two specified tokens - returned in the order specified by the caller
	function getPoolReserves(IERC20 tokenA, IERC20 tokenB) public view returns (uint256 reserveA, uint256 reserveB)
		{
		(bytes32 poolID, bool flipped) = PoolUtils._poolIDAndFlipped(tokenA, tokenB);
		PoolReserves memory reserves = _poolReserves[poolID];
		reserveA = reserves.reserve0;
		reserveB = reserves.reserve1;

		// Return the reserves in the order that they were requested
		if (flipped)
			(reserveA, reserveB) = (reserveB, reserveA);
		}


	// A user's deposited balance for a token
	function depositedUserBalance(address user, IERC20 token) public view returns (uint256)
		{
		return _userDeposits[user][token];
		}
	}
// SPDX-License-Identifier: BUSL 1.1
pragma solidity =0.8.22;


interface IPoolStats
	{
	// These are the indicies (in terms of a poolIDs location in the current whitelistedPoolIDs array) of pools involved in an arbitrage path
	struct ArbitrageIndicies
		{
		uint64 index1;
		uint64 index2;
		uint64 index3;
		}

	function clearProfitsForPools() external;
	function updateArbitrageIndicies() external;

	// Views
	function profitsForWhitelistedPools() external view returns (uint256[] memory _calculatedProfits);
	function arbitrageIndicies(bytes32 poolID) external view returns (ArbitrageIndicies memory);
	}
// SPDX-License-Identifier: BUSL 1.1
pragma solidity =0.8.22;

import "../../staking/interfaces/ILiquidity.sol";
import "../../dao/interfaces/IDAO.sol";
import "./IPoolStats.sol";


interface IPools is IPoolStats
	{
	function startExchangeApproved() external;
	function setContracts( IDAO _dao, ILiquidity _liquidity ) external; // onlyOwner

	function addLiquidity( IERC20 tokenA, IERC20 tokenB, uint256 maxAmountA, uint256 maxAmountB, uint256 minAddedAmountA, uint256 minAddedAmountB, uint256 totalLiquidity ) external returns (uint256 addedAmountA, uint256 addedAmountB, uint256 addedLiquidity);
	function removeLiquidity( IERC20 tokenA, IERC20 tokenB, uint256 liquidityToRemove, uint256 minReclaimedA, uint256 minReclaimedB, uint256 totalLiquidity ) external returns (uint256 reclaimedA, uint256 reclaimedB);

	function deposit( IERC20 token, uint256 amount ) external;
	function withdraw( IERC20 token, uint256 amount ) external;
	function swap( IERC20 swapTokenIn, IERC20 swapTokenOut, uint256 swapAmountIn, uint256 minAmountOut, uint256 deadline ) external returns (uint256 swapAmountOut);
	function depositSwapWithdraw(IERC20 swapTokenIn, IERC20 swapTokenOut, uint256 swapAmountIn, uint256 minAmountOut, uint256 deadline ) external returns (uint256 swapAmountOut);
	function depositDoubleSwapWithdraw( IERC20 swapTokenIn, IERC20 swapTokenMiddle, IERC20 swapTokenOut, uint256 swapAmountIn, uint256 minAmountOut, uint256 deadline ) external returns (uint256 swapAmountOut);
	function depositZapSwapWithdraw(IERC20 swapTokenIn, IERC20 swapTokenOut, uint256 swapAmountIn ) external returns (uint256 swapAmountOut);

	// Views
	function exchangeIsLive() external view returns (bool);
	function getPoolReserves(IERC20 tokenA, IERC20 tokenB) external view returns (uint256 reserveA, uint256 reserveB);
	function depositedUserBalance(address user, IERC20 token) external view returns (uint256);
	}
// SPDX-License-Identifier: BUSL 1.1
pragma solidity =0.8.22;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "./IPools.sol";


interface IPoolsConfig
	{
	function whitelistPool( IERC20 tokenA, IERC20 tokenB ) external; // onlyOwner
	function unwhitelistPool( IERC20 tokenA, IERC20 tokenB ) external; // onlyOwner
	function changeMaximumWhitelistedPools(bool increase) external; // onlyOwner

	// Views
    function maximumWhitelistedPools() external view returns (uint256);

	function numberOfWhitelistedPools() external view returns (uint256);
	function isWhitelisted( bytes32 poolID ) external view returns (bool);
	function whitelistedPools() external view returns (bytes32[] calldata);
	function underlyingTokenPair( bytes32 poolID ) external view returns (IERC20 tokenA, IERC20 tokenB);

	// Returns true if the token has been whitelisted (meaning it has been pooled with either WETH and USDC)
	function tokenHasBeenWhitelisted( IERC20 token, IERC20 weth, IERC20 usdc ) external view returns (bool);
	}
// SPDX-License-Identifier: BUSL 1.1
pragma solidity =0.8.22;


interface IEmissions
	{
	function performUpkeep( uint256 timeSinceLastUpkeep ) external;
    }
// SPDX-License-Identifier: BUSL 1.1
pragma solidity =0.8.22;

import "../../staking/interfaces/IStakingRewards.sol";


interface IRewardsEmitter
	{
	function addSALTRewards( AddedReward[] calldata addedRewards ) external;
	function performUpkeep( uint256 timeSinceLastUpkeep ) external;

	// Views
	function pendingRewardsForPools( bytes32[] calldata pools ) external view returns (uint256[] calldata);
	}
// SPDX-License-Identifier: BUSL 1.1
pragma solidity =0.8.22;

import "./IRewardsEmitter.sol";


interface ISaltRewards
	{
	function sendInitialSaltRewards( uint256 liquidityBootstrapAmount, bytes32[] calldata poolIDs ) external;
    function performUpkeep( bytes32[] calldata poolIDs, uint256[] calldata profitsForPools ) external;

    // Views
    function stakingRewardsEmitter() external view returns (IRewardsEmitter);
    function liquidityRewardsEmitter() external view returns (IRewardsEmitter);
    }
// SPDX-License-Identifier: BUSL 1.1
pragma solidity =0.8.22;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "./IStakingRewards.sol";


interface ILiquidity is IStakingRewards
	{
	function depositLiquidityAndIncreaseShare( IERC20 tokenA, IERC20 tokenB, uint256 maxAmountA, uint256 maxAmountB, uint256 minAddedAmountA, uint256 minAddedAmountB, uint256 minAddedLiquidity, uint256 deadline, bool useZapping ) external returns (uint256 addedLiquidity);
	function withdrawLiquidityAndClaim( IERC20 tokenA, IERC20 tokenB, uint256 liquidityToWithdraw, uint256 minReclaimedA, uint256 minReclaimedB, uint256 deadline ) external returns (uint256 reclaimedA, uint256 reclaimedB);
	}
// SPDX-License-Identifier: BUSL 1.1
pragma solidity =0.8.22;


struct AddedReward
	{
	bytes32 poolID;							// The pool to add rewards to
	uint256 amountToAdd;				// The amount of rewards (as SALT) to add
	}

struct UserShareInfo
	{
	uint256 userShare;					// A user's share for a given poolID
	uint256 virtualRewards;				// The amount of rewards that were added to maintain proper rewards/share ratio - and will be deducted from a user's pending rewards.
	uint256 cooldownExpiration;		// The timestamp when the user can modify their share
	}


interface IStakingRewards
	{
	function claimAllRewards( bytes32[] calldata poolIDs ) external returns (uint256 rewardsAmount);
	function addSALTRewards( AddedReward[] calldata addedRewards ) external;

	// Views
	function totalShares(bytes32 poolID) external view returns (uint256);
	function totalSharesForPools( bytes32[] calldata poolIDs ) external view returns (uint256[] calldata shares);
	function totalRewardsForPools( bytes32[] calldata poolIDs ) external view returns (uint256[] calldata rewards);

	function userRewardForPool( address wallet, bytes32 poolID ) external view returns (uint256);
	function userShareForPool( address wallet, bytes32 poolID ) external view returns (uint256);
	function userVirtualRewardsForPool( address wallet, bytes32 poolID ) external view returns (uint256);

	function userRewardsForPools( address wallet, bytes32[] calldata poolIDs ) external view returns (uint256[] calldata rewards);
	function userShareForPools( address wallet, bytes32[] calldata poolIDs ) external view returns (uint256[] calldata shares);
	function userCooldowns( address wallet, bytes32[] calldata poolIDs ) external view returns (uint256[] calldata cooldowns);
	}