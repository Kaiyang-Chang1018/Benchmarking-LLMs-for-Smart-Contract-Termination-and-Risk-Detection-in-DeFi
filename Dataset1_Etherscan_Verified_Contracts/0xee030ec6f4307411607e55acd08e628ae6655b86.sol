// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IButterBridgeV3 {
    struct BridgeParam {
        uint256 gasLimit;
        bytes refundAddress;
        bytes swapData;
    }

    function swapOutToken(
        address _sender, // user account send this transaction
        address _token, // src token
        bytes memory _to, // receiver account
        uint256 _amount, // token amount
        uint256 _toChain, // target chain id
        bytes calldata _bridgeData
    ) external payable returns (bytes32 orderId);

    function depositToken(address _token, address to, uint256 _amount) external payable;

    function getNativeFee(address _token, uint256 _gasLimit, uint256 _toChain) external view returns (uint256);

    event Relay(bytes32 orderId1, bytes32 orderId2);

    event CollectFee(bytes32 indexed orderId, address indexed token, uint256 value);

    event SwapOut(
        bytes32 indexed orderId, // orderId
        uint256 indexed tochain, // to chain
        address indexed token, // token to across chain
        uint256 amount, // amount to transfer
        address from, // account send this transaction
        address caller, // msg.sender call swapOutToken
        bytes to, // account receiver on target chain
        bytes outToken, // token bridge to target chain(token is native this maybe wtoken)
        uint256 gasLimit, // gasLimit for call on target chain
        uint256 messageFee // native amount for pass message
    );

    event SwapIn(
        bytes32 indexed orderId, // orderId
        uint256 indexed fromChain, // from chain
        address indexed token, // token received on target chain
        uint256 amount, // target token amount
        address to, // account receiver on target chain
        address outToken, //
        bytes from // from chain account send this transaction
    );
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IButterReceiver {
    //_srcToken received token (wtoken or erc20 token)
    function onReceived(
        bytes32 _orderId,
        address _srcToken,
        uint256 _amount,
        uint256 _fromChain,
        bytes calldata _from,
        bytes calldata _payload
    ) external;
}
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
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable2Step.sol)

pragma solidity ^0.8.0;

import "./Ownable.sol";

/**
 * @dev Contract module which provides access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
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
        require(pendingOwner() == sender, "Ownable2Step: caller is not the new owner");
        _transferOwnership(sender);
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
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@butternetwork/bridge/contracts/interface/IButterBridgeV3.sol";
import "@butternetwork/bridge/contracts/interface/IButterReceiver.sol";
import "./interface/IFeeManager.sol";
import "./abstract/SwapCall.sol";
import "./interface/IButterRouterV3.sol";
import "./abstract/FeeManager.sol";

contract ButterRouterV3 is SwapCall, FeeManager, ReentrancyGuard, IButterReceiver, IButterRouterV3 {
    using SafeERC20 for IERC20;
    using Address for address;

    address public bridgeAddress;
    IFeeManager public feeManager;
    uint256 public gasForReFund = 80000;

    // use to solve deep stack
    struct SwapTemp {
        address srcToken;
        address swapToken;
        uint256 srcAmount;
        uint256 swapAmount;
        bytes32 transferId;
        address referrer;
        address initiator;
        address receiver;
        address target;
        uint256 callAmount;
        uint256 fromChain;
        uint256 toChain;
        uint256 nativeBalance;
        uint256 inputBalance;
        bytes from;
    }

    event Approve(address indexed executor, bool indexed flag);
    event SetFeeManager(address indexed _feeManager);
    event CollectFee(
        address indexed token,
        address indexed receiver,
        address indexed integrator,
        uint256 routerAmount,
        uint256 integratorAmount,
        uint256 nativeAmount,
        uint256 integratorNative,
        bytes32 transferId
    );

    event SetBridgeAddress(address indexed _bridgeAddress);
    event SetGasForReFund(uint256 indexed _gasForReFund);

    constructor(address _bridgeAddress, address _owner, address _wToken) payable SwapCall(_wToken) FeeManager(_owner) {
        _setBridgeAddress(_bridgeAddress);
    }

    function setAuthorization(address[] calldata _executors, bool _flag) external onlyOwner {
        if (_executors.length == 0) revert Errors.EMPTY();
        for (uint i = 0; i < _executors.length; i++) {
            if (!_executors[i].isContract()) revert Errors.NOT_CONTRACT();
            approved[_executors[i]] = _flag;
            emit Approve(_executors[i], _flag);
        }
    }

    function setGasForReFund(uint256 _gasForReFund) external onlyOwner {
        gasForReFund = _gasForReFund;
        emit SetGasForReFund(_gasForReFund);
    }

    function setBridgeAddress(address _bridgeAddress) public onlyOwner returns (bool) {
        _setBridgeAddress(_bridgeAddress);
        return true;
    }

    function setWToken(address _wToken) external onlyOwner {
        _setWToken(_wToken);
    }

    function setFeeManager(address _feeManager) public onlyOwner {
        if (!_feeManager.isContract()) revert Errors.NOT_CONTRACT();
        feeManager = IFeeManager(_feeManager);
        emit SetFeeManager(_feeManager);
    }

    function editFuncBlackList(bytes4 _func, bool _flag) external onlyOwner {
        _editFuncBlackList(_func, _flag);
    }

    function swapAndBridge(
        bytes32 _transferId,
        address _initiator, // initiator address
        address _srcToken,
        uint256 _amount,
        bytes calldata _swapData,
        bytes calldata _bridgeData,
        bytes calldata _permitData,
        bytes calldata _feeData
    ) external payable override nonReentrant returns (bytes32 orderId) {
        if ((_swapData.length + _bridgeData.length) == 0) revert Errors.DATA_EMPTY();
        SwapTemp memory swapTemp;
        swapTemp.initiator = _initiator;
        swapTemp.srcToken = _srcToken;
        swapTemp.srcAmount = _amount;
        swapTemp.swapToken = _srcToken;
        swapTemp.swapAmount = _amount;
        swapTemp.transferId = _transferId;
        (swapTemp.nativeBalance, swapTemp.inputBalance) = _transferIn(
            swapTemp.srcToken,
            swapTemp.srcAmount,
            _permitData
        );
        bytes memory receiver;
        FeeDetail memory fd;
        (fd, swapTemp.swapAmount, swapTemp.referrer) = _collectFee(swapTemp.srcToken, swapTemp.srcAmount, _feeData);
        if (_swapData.length != 0) {
            SwapParam memory swapParam = abi.decode(_swapData, (SwapParam));
            (swapTemp.swapToken, swapTemp.swapAmount) = _swap(
                swapTemp.srcToken,
                swapTemp.swapAmount,
                swapTemp.inputBalance,
                swapParam
            );
            if (_bridgeData.length == 0 && swapTemp.swapAmount != 0) {
                receiver = abi.encodePacked(swapParam.receiver);
                _transfer(swapTemp.swapToken, swapParam.receiver, swapTemp.swapAmount);
            }
        }
        if (_bridgeData.length != 0) {
            BridgeParam memory bridge = abi.decode(_bridgeData, (BridgeParam));
            swapTemp.toChain = bridge.toChain;
            receiver = bridge.receiver;
            orderId = _doBridge(msg.sender, swapTemp.swapToken, swapTemp.swapAmount, bridge);
        }
        emit CollectFee(
            swapTemp.srcToken,
            fd.routerReceiver,
            fd.integrator,
            fd.routerTokenFee,
            fd.integratorTokenFee,
            fd.routerNativeFee,
            fd.integratorNativeFee,
            orderId
        );
        emit SwapAndBridge(
            swapTemp.referrer,
            swapTemp.initiator,
            msg.sender,
            swapTemp.transferId,
            orderId,
            swapTemp.srcToken,
            swapTemp.swapToken,
            swapTemp.srcAmount,
            swapTemp.swapAmount,
            swapTemp.toChain,
            receiver
        );
        _afterCheck(swapTemp.nativeBalance);
    }

    function swapAndCall(
        bytes32 _transferId,
        address _initiator, // initiator address
        address _srcToken,
        uint256 _amount,
        bytes calldata _swapData,
        bytes calldata _callbackData,
        bytes calldata _permitData,
        bytes calldata _feeData
    ) external payable override nonReentrant {
        SwapTemp memory swapTemp;
        swapTemp.initiator = _initiator;
        swapTemp.srcToken = _srcToken;
        swapTemp.srcAmount = _amount;
        swapTemp.transferId = _transferId;
        (swapTemp.nativeBalance, swapTemp.inputBalance) = _transferIn(
            swapTemp.srcToken,
            swapTemp.srcAmount,
            _permitData
        );
        if ((_swapData.length + _callbackData.length) == 0) revert Errors.DATA_EMPTY();
        FeeDetail memory fd;
        (fd, swapTemp.swapAmount, swapTemp.referrer) = _collectFee(swapTemp.srcToken, swapTemp.srcAmount, _feeData);
        emit CollectFee(
            swapTemp.srcToken,
            fd.routerReceiver,
            fd.integrator,
            fd.routerTokenFee,
            fd.integratorTokenFee,
            fd.routerNativeFee,
            fd.integratorNativeFee,
            swapTemp.transferId
        );
        (
            swapTemp.receiver,
            swapTemp.target,
            swapTemp.swapToken,
            swapTemp.swapAmount,
            swapTemp.callAmount
        ) = _doSwapAndCall(swapTemp.srcToken, swapTemp.swapAmount, swapTemp.inputBalance, _swapData, _callbackData);

        if (swapTemp.swapAmount > swapTemp.callAmount) {
            _transfer(swapTemp.swapToken, swapTemp.receiver, (swapTemp.swapAmount - swapTemp.callAmount));
        }

        emit SwapAndCall(
            swapTemp.referrer,
            swapTemp.initiator,
            msg.sender,
            swapTemp.transferId,
            swapTemp.srcToken,
            swapTemp.swapToken,
            swapTemp.srcAmount,
            swapTemp.swapAmount,
            swapTemp.receiver,
            swapTemp.target,
            swapTemp.callAmount
        );
        _afterCheck(swapTemp.nativeBalance);
    }

    // _srcToken must erc20 Token or wToken
    function onReceived(
        bytes32 _orderId,
        address _srcToken,
        uint256 _amount,
        uint256 _fromChain,
        bytes calldata _from,
        bytes calldata _swapAndCall
    ) external override nonReentrant {
        SwapTemp memory swapTemp;
        swapTemp.srcToken = _srcToken;
        swapTemp.srcAmount = _amount;
        swapTemp.swapToken = _srcToken;
        swapTemp.swapAmount = _amount;
        swapTemp.fromChain = _fromChain;
        swapTemp.toChain = block.chainid;
        swapTemp.from = _from;
        if (msg.sender != bridgeAddress) revert Errors.BRIDGE_ONLY();
        {
            uint256 balance = _getBalance(swapTemp.srcToken, address(this));
            if (balance < _amount) revert Errors.RECEIVE_LOW();
            swapTemp.nativeBalance = address(this).balance;
            swapTemp.inputBalance = balance - _amount;
        }
        (bytes memory _swapData, bytes memory _callbackData) = abi.decode(_swapAndCall, (bytes, bytes));
        if ((_swapData.length + _callbackData.length) == 0) revert Errors.DATA_EMPTY();
        bool result = true;
        uint256 minExecGas = gasForReFund;
        if (_swapData.length > 0) {
            SwapParam memory swap = abi.decode(_swapData, (SwapParam));
            swapTemp.receiver = swap.receiver;
            if (gasleft() > minExecGas) {
                try
                    this.remoteSwap{gas: gasleft() - minExecGas}(
                        swapTemp.srcToken,
                        swapTemp.srcAmount,
                        swapTemp.inputBalance,
                        swap
                    )
                returns (address dstToken, uint256 dstAmount) {
                    swapTemp.swapToken = dstToken;
                    swapTemp.swapAmount = dstAmount;
                } catch {
                    result = false;
                }
            }
        }

        if (_callbackData.length > 0) {
            CallbackParam memory callParam = abi.decode(_callbackData, (CallbackParam));
            if (swapTemp.receiver == address(0)) {
                swapTemp.receiver = callParam.receiver;
            }
            if (result && gasleft() > minExecGas) {
                try
                    this.remoteCall{gas: gasleft() - minExecGas}(callParam, swapTemp.swapToken, swapTemp.swapAmount)
                returns (address target, uint256 callAmount) {
                    swapTemp.target = target;
                    swapTemp.callAmount = callAmount;
                    swapTemp.receiver = callParam.receiver;
                } catch {}
            }
        }
        if (swapTemp.swapAmount > swapTemp.callAmount) {
            _transfer(swapTemp.swapToken, swapTemp.receiver, (swapTemp.swapAmount - swapTemp.callAmount));
        }
        emit RemoteSwapAndCall(
            _orderId,
            swapTemp.receiver,
            swapTemp.target,
            swapTemp.srcToken,
            swapTemp.swapToken,
            swapTemp.srcAmount,
            swapTemp.swapAmount,
            swapTemp.callAmount,
            swapTemp.fromChain,
            swapTemp.toChain,
            swapTemp.from
        );
        _afterCheck(swapTemp.nativeBalance);
    }

    function getFee(
        address _inputToken,
        uint256 _inputAmount,
        bytes calldata _feeData
    ) external view override returns (address feeToken, uint256 tokenFee, uint256 nativeFee, uint256 afterFeeAmount) {
        IFeeManager.FeeDetail memory fd = _getFee(_inputToken, _inputAmount, _feeData);
        feeToken = fd.feeToken;
        if (_isNative(_inputToken)) {
            tokenFee = 0;
            nativeFee = fd.routerNativeFee + fd.routerTokenFee + fd.integratorTokenFee + fd.integratorNativeFee;
            afterFeeAmount = _inputAmount - nativeFee;
        } else {
            tokenFee = fd.routerTokenFee + fd.integratorTokenFee;
            nativeFee = fd.routerNativeFee + fd.integratorNativeFee;
            afterFeeAmount = _inputAmount - tokenFee;
        }
    }

    function _getFee(
        address _inputToken,
        uint256 _inputAmount,
        bytes calldata _feeData
    ) internal view returns (FeeDetail memory fd) {
        if (address(feeManager) == ZERO_ADDRESS) {
            fd = this.getFeeDetail(_inputToken, _inputAmount, _feeData);
        } else {
            fd = feeManager.getFeeDetail(_inputToken, _inputAmount, _feeData);
        }
    }

    function getInputBeforeFee(
        address _token,
        uint256 _amountAfterFee,
        bytes calldata _feeData
    ) external view override returns (address _feeToken, uint256 _input, uint256 _fee) {
        if (address(feeManager) == ZERO_ADDRESS) {
            return this.getAmountBeforeFee(_token, _amountAfterFee, _feeData);
        }
        return feeManager.getAmountBeforeFee(_token, _amountAfterFee, _feeData);
    }

    function remoteSwap(
        address _srcToken,
        uint256 _amount,
        uint256 _initBalance,
        SwapParam memory swapParam
    ) external returns (address dstToken, uint256 dstAmount) {
        if (msg.sender != address(this)) revert Errors.SELF_ONLY();
        (dstToken, dstAmount) = _swap(_srcToken, _amount, _initBalance, swapParam);
    }

    function remoteCall(
        CallbackParam memory _callbackParam,
        address _callToken,
        uint256 _amount
    ) external returns (address target, uint256 callAmount) {
        if (msg.sender != address(this)) revert Errors.SELF_ONLY();
        target = _callbackParam.target;
        callAmount = _callBack(_amount, _callToken, _callbackParam);
    }

    function _doSwapAndCall(
        address _srcToken,
        uint256 _amount,
        uint256 _initBalance,
        bytes memory _swapData,
        bytes memory _callbackData
    ) internal returns (address receiver, address target, address dstToken, uint256 swapOutAmount, uint256 callAmount) {
        swapOutAmount = _amount;
        dstToken = _srcToken;
        if (_swapData.length > 0) {
            SwapParam memory swapParam = abi.decode(_swapData, (SwapParam));
            (dstToken, swapOutAmount) = _swap(_srcToken, _amount, _initBalance, swapParam);
            receiver = swapParam.receiver;
        }
        if (_callbackData.length > 0) {
            CallbackParam memory callbackParam = abi.decode(_callbackData, (CallbackParam));
            callAmount = _callBack(swapOutAmount, dstToken, callbackParam);
            receiver = callbackParam.receiver;
            target = callbackParam.target;
        }
    }

    function _doBridge(
        address _sender,
        address _token,
        uint256 _amount,
        BridgeParam memory _bridge
    ) internal returns (bytes32 _orderId) {
        uint256 value;
        address bridgeAddr = bridgeAddress;
        if (_isNative(_token)) {
            value = _amount + _bridge.nativeFee;
        } else {
            value = _bridge.nativeFee;
            IERC20(_token).forceApprove(bridgeAddr, _amount);
        }
        _orderId = IButterBridgeV3(bridgeAddr).swapOutToken{value: value}(
            _sender,
            _token,
            _bridge.receiver,
            _amount,
            _bridge.toChain,
            _bridge.data
        );
    }

    function _collectFee(
        address _token,
        uint256 _amount,
        bytes calldata _feeData
    ) internal returns (FeeDetail memory fd, uint256 remain, address referrer) {
        fd = _getFee(_token, _amount, _feeData);
        referrer = fd.integrator;
        if (_isNative(_token)) {
            uint256 routerNative = fd.routerNativeFee + fd.routerTokenFee;
            if (routerNative > 0) {
                _transfer(_token, fd.routerReceiver, routerNative);
            }
            uint256 integratorNative = fd.integratorTokenFee + fd.integratorNativeFee;
            if (integratorNative > 0) {
                _transfer(_token, fd.integrator, integratorNative);
            }
            remain = _amount - routerNative - integratorNative;
        } else {
            if (fd.routerNativeFee > 0) {
                _transfer(ZERO_ADDRESS, fd.routerReceiver, fd.routerNativeFee);
            }
            if (fd.routerTokenFee > 0) {
                _transfer(_token, fd.routerReceiver, fd.routerTokenFee);
            }
            if (fd.integratorNativeFee > 0) {
                _transfer(ZERO_ADDRESS, fd.integrator, fd.integratorNativeFee);
            }
            if (fd.integratorTokenFee > 0) {
                _transfer(_token, fd.integrator, fd.integratorTokenFee);
            }
            remain = _amount - fd.routerTokenFee - fd.integratorTokenFee;

            if (fd.routerNativeFee + fd.integratorNativeFee > msg.value) revert Errors.FEE_MISMATCH();
        }
        if (remain == 0) revert Errors.ZERO_IN();
    }

    function _setBridgeAddress(address _bridgeAddress) internal returns (bool) {
        if (!_bridgeAddress.isContract()) revert Errors.NOT_CONTRACT();
        bridgeAddress = _bridgeAddress;
        emit SetBridgeAddress(_bridgeAddress);
        return true;
    }

    function rescueFunds(address _token, uint256 _amount) external onlyOwner {
        _transfer(_token, msg.sender, _amount);
    }

    receive() external payable {}
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "../interface/IFeeManager.sol";
import "../interface/IButterRouterV3.sol";
import "../lib/Errors.sol";

abstract contract FeeManager is Ownable2Step, IFeeManager {
    uint256 constant FEE_DENOMINATOR = 10000;

    uint256 public routerFeeRate;
    uint256 public routerFixedFee;
    address public feeReceiver;

    uint256 public maxFeeRate; // referrer max fee rate
    uint256 public maxNativeFee; // referrer max fixed native fee

    event SetFee(address indexed receiver, uint256 indexed rate, uint256 indexed fixedf);
    event SetReferrerMaxFee(uint256 indexed _maxFeeRate, uint256 indexed _maxNativeFee);

    constructor(address _owner) payable {
        if (_owner == address(0)) revert Errors.ZERO_ADDRESS();
        _transferOwnership(_owner);
    }

    function setFee(address _feeReceiver, uint256 _feeRate, uint256 _fixedFee) external onlyOwner {
        if (_feeReceiver == address(0)) revert Errors.ZERO_ADDRESS();

        require(_feeRate < FEE_DENOMINATOR);

        feeReceiver = _feeReceiver;
        routerFeeRate = _feeRate;
        routerFixedFee = _fixedFee;

        emit SetFee(_feeReceiver, _feeRate, routerFixedFee);
    }

    function setReferrerMaxFee(uint256 _maxFeeRate, uint256 _maxNativeFee) external onlyOwner {
        require(_maxFeeRate < FEE_DENOMINATOR);
        maxFeeRate = _maxFeeRate;
        maxNativeFee = _maxNativeFee;
        emit SetReferrerMaxFee(_maxFeeRate, _maxNativeFee);
    }

    function getFeeDetail(
        address _inputToken,
        uint256 _inputAmount,
        bytes calldata _feeData
    ) external view virtual override returns (FeeDetail memory feeDetail) {
        IButterRouterV3.Fee memory fee = _checkFeeData(_feeData);
        if (feeReceiver == address(0) && fee.referrer == address(0)) {
            return feeDetail;
        }
        feeDetail.feeToken = _inputToken;
        if (feeReceiver != address(0)) {
            feeDetail.routerReceiver = feeReceiver;
            feeDetail.routerNativeFee = routerFixedFee;
            if (_inputToken == address(0)) {
                feeDetail.routerNativeFee += (_inputAmount * routerFeeRate) / FEE_DENOMINATOR;
            } else {
                feeDetail.routerTokenFee = (_inputAmount * routerFeeRate) / FEE_DENOMINATOR;
            }
        }

        if (fee.referrer != address(0)) {
            feeDetail.integrator = fee.referrer;
            if (fee.feeType == IButterRouterV3.FeeType.FIXED) {
                feeDetail.integratorNativeFee = fee.rateOrNativeFee;
            } else {
                if (_inputToken == address(0)) {
                    feeDetail.integratorNativeFee = (_inputAmount * fee.rateOrNativeFee) / FEE_DENOMINATOR;
                } else {
                    feeDetail.integratorTokenFee = (_inputAmount * fee.rateOrNativeFee) / FEE_DENOMINATOR;
                }
            }
        }

        return feeDetail;
    }

    function getAmountBeforeFee(
        address _token,
        uint256 _amountAfterFee,
        bytes calldata _feeData
    ) external view virtual returns (address feeToken, uint256 beforeAmount, uint256 nativeFeeAmount) {
        IButterRouterV3.Fee memory fee = _checkFeeData(_feeData);

        if (feeReceiver == address(0) && fee.referrer == address(0)) {
            return (address(0), _amountAfterFee, 0);
        }
        uint256 feeRate = 0;
        if (feeReceiver != address(0)) {
            nativeFeeAmount += routerFixedFee;
            feeRate += routerFeeRate;
        }
        if (fee.referrer != address(0)) {
            if (fee.feeType == IButterRouterV3.FeeType.FIXED) {
                nativeFeeAmount += fee.rateOrNativeFee;
            } else {
                feeRate += fee.rateOrNativeFee;
            }
        }

        if (_token == address(0) || _token == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE) {
            beforeAmount = _amountAfterFee + nativeFeeAmount;
            if (feeRate > 0) {
                beforeAmount = (beforeAmount * FEE_DENOMINATOR) / (FEE_DENOMINATOR - feeRate) + 1;
            }
        } else {
            if (feeRate > 0) {
                beforeAmount = (_amountAfterFee * FEE_DENOMINATOR) / (FEE_DENOMINATOR - feeRate) + 1;
            } else {
                beforeAmount = _amountAfterFee;
            }
        }
    }

    function _checkFeeData(bytes calldata _feeData) internal view returns (IButterRouterV3.Fee memory fee) {
        if (_feeData.length == 0) {
            return fee;
        }
        fee = abi.decode(_feeData, (IButterRouterV3.Fee));
        if (fee.feeType == IButterRouterV3.FeeType.PROPORTION) {
            require(fee.rateOrNativeFee < maxFeeRate, "FeeManager: invalid feeRate");
        } else {
            require(fee.rateOrNativeFee < maxNativeFee, "FeeManager: invalid native fee");
        }
        return fee;
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "../lib/Errors.sol";

abstract contract SwapCall {
    using SafeERC20 for IERC20;
    using Address for address;

    address internal constant ZERO_ADDRESS = address(0);
    address internal constant NATIVE_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    address public wToken;
    // uint256 internal nativeBalanceBeforeExec;
    // uint256 internal initInputTokenBalance;
    mapping(address => bool) public approved;
    mapping(bytes4 => bool) public funcBlackList;
    event EditFuncBlackList(bytes4 _func, bool flag);
    event SetWrappedToken(address indexed _wToken);

    enum DexType {
        AGG,
        UNIV2,
        UNIV3,
        CURVE,
        FILL,
        MIX
    }

    struct CallbackParam {
        address target;
        address approveTo;
        uint256 offset;
        uint256 extraNativeAmount;
        address receiver;
        bytes data;
    }

    struct SwapParam {
        address dstToken;
        address receiver;
        address leftReceiver;
        uint256 minAmount;
        SwapData[] swaps;
    }

    struct SwapData {
        DexType dexType;
        address callTo;
        address approveTo;
        uint256 fromAmount;
        bytes callData;
    }

    constructor(address _wToken) payable {
        _setWToken(_wToken);
        //| a9059cbb | transfer(address,uint256)
        funcBlackList[bytes4(0xa9059cbb)] = true;
        //| 095ea7b3 | approve(address,uint256) |
        funcBlackList[bytes4(0x095ea7b3)] = true;
        //| 23b872dd | transferFrom(address,address,uint256) |
        funcBlackList[bytes4(0x23b872dd)] = true;
        //| 39509351 | increaseAllowance(address,uint256)
        funcBlackList[bytes4(0x39509351)] = true;
        //| a22cb465 | setApprovalForAll(address,bool) |
        funcBlackList[bytes4(0xa22cb465)] = true;
        //| 42842e0e | safeTransferFrom(address,address,uint256) |
        funcBlackList[bytes4(0x42842e0e)] = true;
        //| b88d4fde | safeTransferFrom(address,address,uint256,bytes) |
        funcBlackList[bytes4(0xb88d4fde)] = true;
        //| 9bd9bbc6 | send(address,uint256,bytes) |
        funcBlackList[bytes4(0x9bd9bbc6)] = true;
        //| fe9d9303 | burn(uint256,bytes) |
        funcBlackList[bytes4(0xfe9d9303)] = true;
        //| 959b8c3f | authorizeOperator
        funcBlackList[bytes4(0x959b8c3f)] = true;
        //| f242432a | safeTransferFrom(address,address,uint256,uint256,bytes) |
        funcBlackList[bytes4(0xf242432a)] = true;
        //| 2eb2c2d6 | safeBatchTransferFrom(address,address,uint256[],uint256[],bytes) |
        funcBlackList[bytes4(0x2eb2c2d6)] = true;
    }

    function _editFuncBlackList(bytes4 _func, bool _flag) internal {
        funcBlackList[_func] = _flag;
        emit EditFuncBlackList(_func, _flag);
    }

    function _setWToken(address _wToken) internal {
        if (!_wToken.isContract()) revert Errors.NOT_CONTRACT();
        wToken = _wToken;
        emit SetWrappedToken(_wToken);
    }

    function _transferIn(
        address token,
        uint256 amount,
        bytes memory permitData
    ) internal returns (uint256 nativeBalanceBeforeExec, uint256 initInputTokenBalance) {
        if (amount == 0) revert Errors.ZERO_IN();

        if (permitData.length != 0) {
            _permit(permitData);
        }
        nativeBalanceBeforeExec = address(this).balance - msg.value;
        if (_isNative(token)) {
            if (msg.value < amount) revert Errors.FEE_MISMATCH();
            //extra value maybe used for call native or bridge native fee
            initInputTokenBalance = address(this).balance - amount;
        } else {
            initInputTokenBalance = _getBalance(token, address(this));
            SafeERC20.safeTransferFrom(IERC20(token), msg.sender, address(this), amount);
        }
    }

    function _afterCheck(uint256 nativeBalanceBeforeExec) internal view {
        if (address(this).balance < nativeBalanceBeforeExec) revert Errors.NATIVE_VALUE_OVERSPEND();
    }

    function _swap(
        address _token,
        uint256 _amount,
        uint256 _initBalance,
        SwapParam memory swapParam
    ) internal returns (address _dstToken, uint256 _dstAmount) {
        _dstToken = swapParam.dstToken;
        if (_token == _dstToken) revert Errors.SWAP_SAME_TOKEN();

        uint256 finalTokenAmount = _getBalance(swapParam.dstToken, address(this));
        _doSwap(_token, _amount, swapParam);
        _dstAmount = _getBalance(swapParam.dstToken, address(this)) - finalTokenAmount;
        if (_dstAmount < swapParam.minAmount) revert Errors.RECEIVE_LOW();
        uint256 left = _getBalance(_token, address(this)) - _initBalance;
        if (left != 0) {
            _transfer(_token, swapParam.leftReceiver, left);
        }
    }

    function _callBack(
        uint256 _amount,
        address _token,
        CallbackParam memory callParam
    ) internal returns (uint256 _callAmount) {
        _callAmount = _getBalance(_token, address(this));
        uint256 offset = callParam.offset;
        bytes memory callPayload = callParam.data;
        if (offset > 35) {
            //32 length + 4 funcSig
            assembly {
                mstore(add(callPayload, offset), _amount)
            }
        }
        _checkApprove(callParam.target, callPayload);
        bool _result;
        if (_isNative(_token)) {
            (_result, ) = callParam.target.call{value: _amount}(callPayload);
        } else {
            if (_amount != 0) IERC20(_token).safeIncreaseAllowance(callParam.approveTo, _amount);
            // this contract not save money make sure send value can cover this
            (_result, ) = callParam.target.call{value: callParam.extraNativeAmount}(callPayload);
            if (_amount != 0) IERC20(_token).safeApprove(callParam.approveTo, 0);
        }
        if (!_result) revert Errors.CALL_BACK_FAIL();
        _callAmount = _callAmount - _getBalance(_token, address(this));
    }

    function _checkApprove(address _callTo, bytes memory _calldata) private view {
        address wTokenAddr = wToken;
        if (_callTo != wTokenAddr && (!approved[_callTo])) revert Errors.NO_APPROVE();

        bytes4 sig = _getFirst4Bytes(_calldata);
        if (funcBlackList[sig]) revert Errors.CALL_FUNC_BLACK_LIST();

        if (_callTo == wTokenAddr) {
            if (sig != bytes4(0x2e1a7d4d) && sig != bytes4(0xd0e30db0)) revert Errors.CALL_FUNC_BLACK_LIST();
        }
    }

    function _doSwap(address _token, uint256 _amount, SwapParam memory swapParam) internal {
        uint256 len = swapParam.swaps.length;
        if (len == 0) revert Errors.EMPTY();
        (uint256 amountAdjust, uint256 firstAdjust, bool isUp) = _rebuildSwaps(_amount, len, swapParam.swaps);
        SwapData[] memory _swaps = swapParam.swaps;
        bool isNative = _isNative(_token);
        for (uint i = 0; i < len; ) {
            if (firstAdjust != 0) {
                if (i == 0) {
                    isUp ? _swaps[i].fromAmount += firstAdjust : _swaps[i].fromAmount -= firstAdjust;
                } else {
                    isUp ? _swaps[i].fromAmount += amountAdjust : _swaps[i].fromAmount -= amountAdjust;
                }
            }
            if (!isNative) {
                IERC20(_token).safeIncreaseAllowance(_swaps[i].approveTo, _swaps[i].fromAmount);
            }
            _execute(_swaps[i].dexType, isNative, _swaps[i].callTo, _token, _swaps[i].fromAmount, _swaps[i].callData);
            if (!isNative) {
                IERC20(_token).safeApprove(_swaps[i].approveTo, 0);
            }
            unchecked {
                i++;
            }
        }
    }

    function _rebuildSwaps(
        uint256 _amount,
        uint256 _len,
        SwapData[] memory _swaps
    ) private pure returns (uint256 amountAdjust, uint256 firstAdjust, bool isUp) {
        uint256 total = 0;
        for (uint256 i = 0; i < _len; i++) {
            total += _swaps[i].fromAmount;
        }
        if (total > _amount) {
            isUp = false;
            uint256 margin = total - _amount;
            amountAdjust = margin / _len;
            firstAdjust = amountAdjust + (margin - amountAdjust * _len);
        } else if (total < _amount) {
            isUp = true;
            uint256 margin = _amount - total;
            amountAdjust = margin / _len;
            firstAdjust = amountAdjust + (margin - amountAdjust * _len);
        }
    }

    function _execute(
        DexType _dexType,
        bool _native,
        address _router,
        address _srcToken,
        uint256 _amount,
        bytes memory _swapData
    ) internal {
        bool _result;
        if (_dexType == DexType.FILL) {
            (_result) = _makeAggFill(_router, _amount, _native, _swapData);
        } else if (_dexType == DexType.MIX) {
            (_result) = _makeMixSwap(_srcToken, _amount, _swapData);
        } else {
            revert Errors.UNSUPPORT_DEX_TYPE();
        }
        if (!_result) revert Errors.SWAP_FAIL();
    }

    struct MixSwap {
        uint256 offset;
        address srcToken;
        address callTo;
        address approveTo;
        bytes callData;
    }

    function _makeMixSwap(address _srcToken, uint256 _amount, bytes memory _swapData) internal returns (bool _result) {
        MixSwap[] memory mixSwaps = abi.decode(_swapData, (MixSwap[]));
        for (uint256 i = 0; i < mixSwaps.length; i++) {
            if (i != 0) {
                _amount = _getBalance(mixSwaps[i].srcToken, address(this));
                _srcToken = mixSwaps[i].srcToken;
            }
            bytes memory callData = mixSwaps[i].callData;
            uint256 offset = mixSwaps[i].offset;
            if (offset > 35) {
                //32 length + 4 funcSig
                assembly {
                    mstore(add(callData, offset), _amount)
                }
            }
            _checkApprove(mixSwaps[i].callTo, callData);
            if (_isNative(_srcToken)) {
                (_result, ) = mixSwaps[i].callTo.call{value: _amount}(callData);
            } else {
                if (i != 0) {
                    IERC20(_srcToken).safeIncreaseAllowance(mixSwaps[i].approveTo, _amount);
                }

                (_result, ) = mixSwaps[i].callTo.call(callData);

                if (i != 0) {
                    IERC20(_srcToken).safeApprove(mixSwaps[i].approveTo, 0);
                }
            }
            if (!_result) {
                break;
            }
        }
    }

    function _makeAggFill(
        address _router,
        uint256 _amount,
        bool native,
        bytes memory _swapData
    ) internal returns (bool _result) {
        (uint256[] memory offsets, bytes memory callData) = abi.decode(_swapData, (uint256[], bytes));
        uint256 len = offsets.length;
        for (uint i = 0; i < len; i++) {
            uint256 offset = offsets[i];
            if (offset > 35) {
                //32 length + 4 funcSig
                assembly {
                    mstore(add(callData, offset), _amount)
                }
            }
        }
        _checkApprove(_router, callData);
        if (native) {
            (_result, ) = _router.call{value: _amount}(callData);
        } else {
            (_result, ) = _router.call(callData);
        }
    }

    function _isNative(address token) internal pure returns (bool) {
        return (token == ZERO_ADDRESS || token == NATIVE_ADDRESS);
    }

    function _getBalance(address _token, address _account) internal view returns (uint256) {
        if (_isNative(_token)) {
            return _account.balance;
        } else {
            return IERC20(_token).balanceOf(_account);
        }
    }

    function _transfer(address _token, address _to, uint256 _amount) internal {
        if (_isNative(_token)) {
            Address.sendValue(payable(_to), _amount);
        } else {
            uint256 _chainId = block.chainid;
            if (_chainId == 728126428 && _token == 0xa614f803B6FD780986A42c78Ec9c7f77e6DeD13C) {
                // Tron USDT
                _token.call(abi.encodeWithSelector(0xa9059cbb, _to, _amount));
            } else {
                IERC20(_token).safeTransfer(_to, _amount);
            }
        }
    }

    function _getFirst4Bytes(bytes memory data) internal pure returns (bytes4 outBytes4) {
        if (data.length == 0) {
            return 0x0;
        }
        assembly {
            outBytes4 := mload(add(data, 32))
        }
    }

    function _permit(bytes memory _data) internal {
        (
            address token,
            address owner,
            address spender,
            uint256 value,
            uint256 deadline,
            uint8 v,
            bytes32 r,
            bytes32 s
        ) = abi.decode(_data, (address, address, address, uint256, uint256, uint8, bytes32, bytes32));

        SafeERC20.safePermit(IERC20Permit(token), owner, spender, value, deadline, v, r, s);
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IButterRouterV3 {
    enum FeeType {
        FIXED,
        PROPORTION
    }

    struct Fee {
        FeeType feeType;
        address referrer;
        uint256 rateOrNativeFee;
    }

    struct BridgeParam {
        uint256 toChain;
        uint256 nativeFee;
        bytes receiver;
        bytes data;
    }

    event SwapAndBridge(
        address indexed referrer,
        address indexed initiator,
        address indexed from,
        bytes32 transferId,
        bytes32 orderId,
        address originToken,
        address bridgeToken,
        uint256 originAmount,
        uint256 bridgeAmount,
        uint256 toChain,
        bytes to
    );

    event SwapAndCall(
        address indexed referrer,
        address indexed initiator,
        address indexed from,
        bytes32 transferId,
        address originToken,
        address swapToken,
        uint256 originAmount,
        uint256 swapAmount,
        address receiver,
        address target,
        uint256 callAmount
    );

    event RemoteSwapAndCall(
        bytes32 indexed orderId,
        address indexed receiver,
        address indexed target,
        address originToken,
        address swapToken,
        uint256 originAmount,
        uint256 swapAmount,
        uint256 callAmount,
        uint256 fromChain,
        uint256 toChain,
        bytes from
    );

    // 1. swap: _swapData.length > 0 and _bridgeData.length == 0
    // 2. swap and call: _swapData.length > 0 and _callbackData.length > 0
    function swapAndCall(
        bytes32 _transferId,
        address _initiator,
        address _srcToken,
        uint256 _amount,
        bytes calldata _swapData,
        bytes calldata _callbackData,
        bytes calldata _permitData,
        bytes calldata _feeData
    ) external payable;

    // 1. bridge:  _swapData.length == 0 and _bridgeData.length > 0
    // 2. swap and bridge: _swapData.length > 0 and _bridgeData.length > 0
    function swapAndBridge(
        bytes32 _transferId,
        address _initiator,
        address _srcToken,
        uint256 _amount,
        bytes calldata _swapData,
        bytes calldata _bridgeData,
        bytes calldata _permitData,
        bytes calldata _feeData
    ) external payable returns (bytes32 orderId);

    function getFee(
        address _inputToken,
        uint256 _inputAmount,
        bytes calldata _feeData
    ) external view returns (address feeToken, uint256 tokenFee, uint256 nativeFee, uint256 afterFeeAmount);

    function getInputBeforeFee(
        address _inputToken,
        uint256 _afterFeeAmount,
        bytes calldata _feeData
    ) external view returns (address feeToken, uint256 inputAmount, uint256 nativeFee);
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IFeeManager {
    struct FeeDetail {
        address feeToken;
        address routerReceiver;
        address integrator;
        uint256 routerNativeFee;
        uint256 integratorNativeFee;
        uint256 routerTokenFee;
        uint256 integratorTokenFee;
    }

    function getFeeDetail(
        address inputToken,
        uint256 inputAmount,
        bytes calldata _feeData
    ) external view returns (FeeDetail memory feeDetail);

    function getAmountBeforeFee(
        address inputToken,
        uint256 inputAmount,
        bytes calldata _feeData
    ) external view returns (address feeToken, uint256 beforeAmount, uint256 nativeFeeAmount);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

library Errors {
    error NOT_CONTRACT();
    error SWAP_FAIL();
    error CALL_BACK_FAIL();
    error ZERO_IN();
    error FEE_MISMATCH();
    error FEE_LOWER();
    error ZERO_ADDRESS();
    error RECEIVE_LOW();
    error CALL_AMOUNT_INVALID();
    error BRIDGE_ONLY();
    error DATA_EMPTY();
    error NO_APPROVE();
    error NATIVE_VALUE_OVERSPEND();
    error EMPTY();
    error UNSUPPORT_DEX_TYPE();
    error SWAP_SAME_TOKEN();
    error CANNOT_ADJUST();
    error SELF_ONLY();
    error CALL_FUNC_BLACK_LIST();
}