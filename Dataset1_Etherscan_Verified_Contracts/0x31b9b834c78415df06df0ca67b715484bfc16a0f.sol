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
//
//              @@@@@@@@@@        @@@@@@@     @@@@@@@@@@@@@@@@@@@  @@@@@@@@@@@@@@
//            @@@@@@@@@@@@       @@@@@@@    .@@@@@@@@@@@@@@@@@@@ @@@@@@@@@@@@@@@@@
//          @@@@@@@@@@@@@@      @@@@@@@           @@@@@@@        @@@@@@     @@@@@@
//         @@@@@@@ @@@@@@@     @@@@@@@           @@@@@@@         @@@@@@@@@@@
//       @@@@@@@   @@@@@@@     @@@@@@            @@@@@@           @@@@@@@@@@@@@@
//      @@@@@@@@@@@@@@@@@@    @@@@@@@           @@@@@@@               #@@@@@@@@@@
//    @@@@@@@@@@@@@@@@@@@@   @@@@@@@           @@@@@@@        @@@@@@@     @@@@@@#
//   @@@@@@@@@@@@@@@@@@@@@   @@@@@@@@@@@@@@@@ @@@@@@@         @@@@@@@@@@@@@@@@@
// @@@@@@@          @@@@@@  @@@@@@@@@@@@@@@@ @@@@@@@            @@@@@@@@@@@@

pragma solidity ^0.8.21;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";

interface IRVM {
    function burn(address account, uint256 id, uint256 value) external;

    function isApprovedForAll(address account, address operator) external view returns (bool);
}

interface IALTS {
    function ownerOf(uint256 tokenId) external view returns (address);
}

contract TraitSwapping is Ownable, Pausable, ReentrancyGuard, IERC1155Receiver {
    using SafeERC20 for IERC20;
    IERC20 public immutable APE;
    IRVM public immutable RVM;
    IALTS public immutable ALTS;
    IERC20 public immutable WETH;

    enum Currency {
        ETH,
        WETH,
        APE,
        RVM
    }

    enum OrderStatus {
        UNSET,
        PENDING,
        ACCEPTED,
        CANCELED
    }

    struct Order {
        address buyer;
        uint96 amount;
        address seller;
        uint32 expiresAt;
        uint24 id;
        uint16 buyerAlt;
        uint16 sellerAlt;
        OrderStatus status;
    }

    struct Transfer {
        address buyer;
        uint16[3] buyerAlts;
        uint16[3] sellerAlts;
        address seller;
        uint72 amount;
        uint24 id;
    }

    struct Exchange {
        uint72 rateApe;
        uint56 rateEth;
        uint56 minFee;
        uint56 minOrder;
        uint8 rateRvm;
        uint8 fee;
    }

    Exchange public exchange;
    address payable public receiver;
    address public permittedOperator;
    bool public pointsTransfers = false;
    uint32 public expiryPeriod;
    uint24 public totalOrders = 0;
    uint24 public totalTransfers = 0;

    mapping(address => uint256) public points;
    mapping(uint56 => Order) public orders;
    mapping(uint96 => Transfer) private transfers;

    event PointsPurchase(
        address indexed user,
        Currency indexed currency,
        uint256 value,
        uint256 indexed points,
        uint256 currentPointsBalance
    );
    event TransferPoints(address indexed sender, address indexed receiver, uint256 amount);
    event TransferWETH(uint96 indexed id, address indexed buyer, address indexed seller, uint256 amount, uint256 fee);
    event OrderCreated(
        uint56 indexed orderId,
        address indexed buyer,
        address indexed seller,
        uint256 amount,
        uint32 expiresAt
    );
    event OrderFulfilled(uint56 indexed orderId);
    event OrderCanceled(uint56 indexed orderId, address indexed buyer, address indexed seller, uint256 amount);

    constructor(
        uint56 _rateEth,
        uint72 _rateApe,
        uint8 _rateRvm,
        uint56 _minFee,
        uint56 _minOrder,
        uint8 _fee,
        uint32 _expiryPeriod,
        address _ape,
        address _rvm,
        address _weth,
        address _alts,
        address _permittedOperator,
        address payable _receiver
    ) {
        exchange.rateEth = _rateEth;
        exchange.rateApe = _rateApe;
        exchange.rateRvm = _rateRvm;
        exchange.minFee = _minFee;
        exchange.minOrder = _minOrder;
        exchange.fee = _fee;
        expiryPeriod = _expiryPeriod;
        APE = IERC20(_ape);
        RVM = IRVM(_rvm);
        WETH = IERC20(_weth);
        ALTS = IALTS(_alts);
        permittedOperator = _permittedOperator;
        receiver = _receiver;
    }

    modifier onlyPermittedOperator() {
        require(msg.sender == permittedOperator || msg.sender == owner(), "Not a permitted operator");
        _;
    }

    /// @notice Exchanges ETH for swapping points.
    function exchangeETH() external payable nonReentrant whenNotPaused {
        require(msg.value > 0, "Amount cannot be 0");
        require(msg.value % exchange.rateEth == 0, "Invalid ETH amount");
        uint256 pointsToReceive = msg.value / exchange.rateEth;
        points[msg.sender] += pointsToReceive;
        (bool sent, ) = receiver.call{value: msg.value}("");
        require(sent, "Failed to send ETH");
        emit PointsPurchase(msg.sender, Currency.ETH, msg.value, pointsToReceive, points[msg.sender]);
    }

    /// @notice Exchanges WETH for swapping points.
    /// @param amount The amount of WETH to be exchanged.
    function exchangeWETH(uint256 amount) external nonReentrant whenNotPaused {
        require(amount > 0, "Amount cannot be 0");
        require(amount % exchange.rateEth == 0, "Invalid WETH amount");
        uint256 pointsToReceive = amount / exchange.rateEth;
        points[msg.sender] += pointsToReceive;
        WETH.safeTransferFrom(msg.sender, receiver, amount);
        emit PointsPurchase(msg.sender, Currency.WETH, amount, pointsToReceive, points[msg.sender]);
    }

    /// @notice Exchanges APE coin for swapping points.
    /// @param amount The amount of APE to be exchanged.
    function exchangeAPE(uint256 amount) external nonReentrant whenNotPaused {
        require(amount > 0, "Amount cannot be 0");
        require(amount % exchange.rateApe == 0, "Invalid APE amount");
        uint256 pointsToReceive = amount / exchange.rateApe;
        points[msg.sender] += pointsToReceive;
        APE.safeTransferFrom(msg.sender, receiver, amount);
        emit PointsPurchase(msg.sender, Currency.APE, amount, pointsToReceive, points[msg.sender]);
    }

    /// @notice Exchanges RVM coins for points.
    /// @param amount The amount of RVM coins to be exchanged.
    function exchangeRVM(uint256 amount) external nonReentrant whenNotPaused {
        require(amount > 0, "Amount cannot be 0");
        require(amount % exchange.rateRvm == 0, "Invalid RVM amount");
        uint256 pointsToReceive = amount / exchange.rateRvm;
        points[msg.sender] += pointsToReceive;
        RVM.burn(msg.sender, 0, amount);
        emit PointsPurchase(msg.sender, Currency.RVM, amount, pointsToReceive, points[msg.sender]);
    }

    /// @notice Enables a user to create a WETH transfer.
    /// @param transfer The details of the new WETH transfer.
    function executeWETHOrder(Transfer memory transfer) external nonReentrant whenNotPaused {
        require(transfer.buyer == msg.sender, "Buyer must create own order");
        require(transfer.amount >= exchange.minOrder, "Transfer amount is below minimum");
        require(validateAltsOwnership(transfer.buyerAlts, msg.sender), "Buyer: no valid ALT ID");
        require(validateAltsOwnership(transfer.sellerAlts, transfer.seller), "Seller: no valid ALT ID");

        unchecked {
            uint256 minFee = exchange.minFee;
            uint256 calculatedFee = (transfer.amount * exchange.fee) / 100;
            uint256 feeAmount = calculatedFee < minFee ? minFee : calculatedFee;

            totalTransfers++;
            transfer.id = totalTransfers;
            transfers[transfer.id] = transfer;

            address buyer = transfer.buyer;
            WETH.safeTransferFrom(buyer, receiver, feeAmount);
            WETH.safeTransferFrom(buyer, transfer.seller, transfer.amount);

            emit TransferWETH(transfer.id, transfer.buyer, transfer.seller, transfer.amount, feeAmount);
        }
    }

    /// @notice Enables a user to create a new WETH offer.
    /// @param order The details of the new WETH offer.
    function createOrder(Order memory order) external nonReentrant whenNotPaused {
        require(order.buyer == msg.sender, "Buyer must create their own order");
        require(order.buyerAlt >= 1 && order.buyerAlt <= 30000, "Invalid buyer ALT ID");
        require(order.sellerAlt >= 1 && order.sellerAlt <= 30000, "Invalid seller ALT ID");
        require(order.amount >= exchange.minOrder, "Order amount is below minimum");

        require(ALTS.ownerOf(order.buyerAlt) == msg.sender, "Buyer does not own the specified ALT");
        require(ALTS.ownerOf(order.sellerAlt) == order.seller, "Seller does not own the specified ALT");

        // No overflow in unchecked block as order.amount is uint96 and exchange.fee is max 100
        unchecked {
            uint256 minFee = exchange.minFee;
            uint256 calculatedFee = (order.amount * exchange.fee) / 100;
            uint256 feeAmount = calculatedFee < minFee ? minFee : calculatedFee;

            require(
                WETH.allowance(msg.sender, address(this)) >= order.amount + feeAmount,
                "Insufficient WETH allowance"
            );

            totalOrders++;
        }

        order.id = totalOrders;
        order.status = OrderStatus.PENDING;
        order.expiresAt = uint32(block.timestamp + expiryPeriod);
        orders[order.id] = order;

        emit OrderCreated(order.id, order.buyer, order.seller, order.amount, order.expiresAt);
    }

    /// @notice Enables a user to cancel a WETH offer.
    /// @param id The ID of the WETH offer to be canceled.
    function cancelOrder(uint56 id) external nonReentrant whenNotPaused {
        Order storage order = orders[id];
        OrderStatus status = order.status;

        require(status != OrderStatus.UNSET, "Order does not exist");
        require(status == OrderStatus.PENDING, "Order is not pending");

        address buyer = order.buyer;

        require(
            buyer == msg.sender || permittedOperator == msg.sender || owner() == msg.sender,
            "Not the buyer of this order"
        );

        order.status = OrderStatus.CANCELED;

        emit OrderCanceled(id, buyer, order.seller, order.amount);
    }

    /// @notice Fulfills a specific WETH offer.
    /// @param id The ID of the WETH offer to be fulfilled.
    function fulfillOrder(uint56 id) external onlyPermittedOperator {
        Order storage order = orders[id];
        require(order.status == OrderStatus.PENDING, "Order not eligible for fulfillment");

        if (block.timestamp > order.expiresAt) {
            revert("Expired");
        }

        unchecked {
            uint256 orderAmount = order.amount;
            uint256 feeAmount = (orderAmount * exchange.fee) / 100;

            if (feeAmount < exchange.minFee) {
                feeAmount = exchange.minFee;
            }
            // WETH calls in unchecked block scope vs separate declarations
            address buyer = order.buyer;
            WETH.safeTransferFrom(buyer, receiver, feeAmount);
            WETH.safeTransferFrom(buyer, order.seller, orderAmount);
        }

        order.status = OrderStatus.ACCEPTED;
        emit OrderFulfilled(id);
    }

    /// @notice Enables a user to send their points to another user.
    /// @param to The address to receive the points.
    /// @param amount The amount of points to send.
    function transferPoints(address to, uint256 amount) external nonReentrant whenNotPaused {
        require(pointsTransfers, "Transfers of points are disabled");
        require(to != address(0), "Cannot send to zero address");
        require(points[msg.sender] >= amount, "Insufficient points balance");

        points[msg.sender] -= amount;
        points[to] += amount;

        emit TransferPoints(msg.sender, to, amount);
    }

    /// @notice Overwrite the current points balance for the given users.
    /// @param users The list of user addresses.
    /// @param balances The corresponding list of point balances for each user.
    function setPoints(address[] calldata users, uint256[] calldata balances) external onlyPermittedOperator {
        require(users.length == balances.length, "Mismatched arrays");
        unchecked {
            for (uint256 i = 0; i < users.length; i++) {
                points[users[i]] = balances[i];
            }
        }
    }

    /// @notice Increments or decrements the current points balance for the given users by the given amount(s).
    /// @param users The list of user addresses whose points should be incremented or decremented.
    /// @param adjustments The corresponding list of point adjustments (positive for increments, negative for decrements) for each user.
    function adjustPoints(address[] calldata users, int256[] calldata adjustments) external onlyPermittedOperator {
        require(users.length == adjustments.length, "Mismatched arrays");
        unchecked {
            for (uint256 i = 0; i < users.length; i++) {
                if (adjustments[i] > 0) {
                    points[users[i]] += uint256(adjustments[i]);
                } else {
                    require(points[users[i]] >= uint256(-adjustments[i]), "Cannot decrease below zero");
                    points[users[i]] -= uint256(-adjustments[i]);
                }
            }
        }
    }

    /// @notice Sets the wallet to receive exchange payments.
    /// @param _receiver The new address of the receiver.
    function setReceiver(address payable _receiver) external onlyOwner {
        receiver = _receiver;
    }

    /// @notice Sets the period from order creation block timestamp after which orders should expire.
    /// @param period The new expiry period in seconds (e.g. 14 days is 1209600).
    function setExpiryPeriod(uint32 period) external onlyOwner {
        expiryPeriod = period;
    }

    /// @notice Sets WETH fee and exchange rates for the supported currencies and tokens.
    /// @param eth The exchange rate for ETH.
    /// @param ape The exchange rate for APE coin.
    /// @param rvm The exchange rate for RVM coin.
    /// @param fee The fee applied to WETH offers.
    function setExchange(
        uint56 eth,
        uint72 ape,
        uint8 rvm,
        uint8 fee,
        uint56 minFee,
        uint56 minOrder
    ) external onlyOwner {
        exchange.rateApe = ape;
        exchange.rateEth = eth;
        exchange.minFee = fee;
        exchange.minOrder = minOrder;
        exchange.rateRvm = rvm;
        exchange.fee = fee;
    }

    /// @notice Sets the permitted operator address.
    /// @param _operator The address of the operator.
    function setPermittedOperator(address _operator) external onlyOwner {
        require(_operator != address(0), "Operator address cannot be null");
        permittedOperator = _operator;
    }

    /// @notice Removes permissions from the permitted operator.
    function removePermittedOperator() external onlyOwner {
        permittedOperator = address(0);
    }

    /// @notice Fetches allowances for the user for all supported tokens.
    /// @param user The address of the user.
    function getAllowances(address user) external view returns (uint256[] memory) {
        uint256[] memory allowances = new uint256[](3);
        allowances[0] = WETH.allowance(user, address(this));
        allowances[1] = APE.allowance(user, address(this));
        allowances[2] = RVM.isApprovedForAll(user, address(this)) ? 1 : 0;
        return allowances;
    }

    /// @notice Fetches orders including a specific wallet address between the given range.
    /// @param user The address of the user.
    /// @param start The starting ID of the order range.
    /// @param end The ending ID of the order range.
    /// @param isSeller Whether to fetch orders where the user is the buyer (WETH sender) or the seller (WETH receiver).
    function getOrdersByUser(
        address user,
        uint56 start,
        uint56 end,
        bool isSeller
    ) external view returns (uint56[] memory) {
        require(start <= end, "Invalid range");

        uint56[] memory orderRange = new uint56[](end - start + 1);
        uint256 count = 0;

        unchecked {
            for (uint56 i = start; i <= end; i++) {
                bool isUserOrder = (isSeller && orders[i].seller == user) || (!isSeller && orders[i].buyer == user);
                if (isUserOrder && orders[i].status != OrderStatus.UNSET) {
                    orderRange[count++] = i;
                }
            }
        }

        uint56[] memory result = new uint56[](count);
        unchecked {
            for (uint256 j = 0; j < count; j++) {
                result[j] = orderRange[j];
            }
        }
        return result;
    }

    /// @notice Gets informatiom about a WETH transfer
    /// @param transferId The ID of the transfer to get data for
    /// @dev Alternative to public transfers mapping to facilitate uint16[3] display
    function getTransfer(
        uint96 transferId
    ) public view returns (address, uint16[3] memory, uint16[3] memory, address, uint96, uint256) {
        Transfer storage t = transfers[transferId];
        return (t.buyer, t.buyerAlts, t.sellerAlts, t.seller, t.id, t.amount);
    }

    /// @notice Drains any Ether from the contract to the owner.
    /// @dev This is an emergency function for funds release.
    function drainETH() external onlyOwner {
        owner().call{value: address(this).balance}("");
    }

    /// @notice Drains any WETH from the contract to the owner.
    /// @dev This is an emergency function for funds release.
    function drainWETH() external onlyOwner {
        WETH.transfer(owner(), WETH.balanceOf(address(this)));
    }

    /// @notice Drains any APE tokens from the contract to the owner.
    /// @dev This is an emergency function for funds release.
    function drainAPE() external onlyOwner {
        APE.transfer(owner(), APE.balanceOf(address(this)));
    }

    /// @notice Enables peer-to-peer points transfer.
    function enableTransfers() external onlyOwner {
        pointsTransfers = true;
    }

    /// @notice Disables peer-to-peer points transfer.
    function disableTransfers() external onlyOwner {
        pointsTransfers = false;
    }

    /// @notice Pauses exchanges and points issuance.
    function pause() external onlyPermittedOperator {
        _pause();
    }

    /// @notice Unpauses exchanges and points issuance.
    function unpause() external onlyPermittedOperator {
        _unpause();
    }

    /// @dev Issues swapping points for RVM coins send to the contract.
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external override returns (bytes4) {
        require(address(RVM) == msg.sender, "Only RVM tokens accepted");
        require(id == 0, "Only RVM tokenId 0 accepted");

        uint256 pointsToReceive = value / exchange.rateRvm;
        points[from] += pointsToReceive;

        emit PointsPurchase(from, Currency.RVM, value, pointsToReceive, points[from]);

        RVM.burn(address(this), id, value);

        return this.onERC1155Received.selector;
    }

    /// @dev Declines batch transfers of ERC1155 tokens to the contract.
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external override returns (bytes4) {
        revert("Not supported");
    }

    /// @dev Supports IERC1155Receiver
    function supportsInterface(bytes4 interfaceId) external pure override returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId;
    }

    /// @notice Check a wallet owns the given ALTs
    /// @param tokenIds The ALT tokenIds to check
    /// @param owner The expected owner wallet address
    function validateAltsOwnership(uint16[3] memory tokenIds, address owner) internal view returns (bool) {
        bool validAlt = false;
        for (uint i = 0; i < 3; i++) {
            if (tokenIds[i] != 0) {
                validAlt = true;
                require(ALTS.ownerOf(tokenIds[i]) == owner, "ALT ownership mismatch");
            }
        }
        return validAlt;
    }
}