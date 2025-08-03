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
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

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

pragma solidity ^0.8.0;

/// @author: manifold.xyz

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/**
 * @dev Lookup engine interface
 */
interface IRoyaltyEngineV1 is IERC165 {
    /**
     * Get the royalty for a given token (address, id) and value amount.  Does not cache the bps/amounts.  Caches the spec for a given token address
     *
     * @param tokenAddress - The address of the token
     * @param tokenId      - The id of the token
     * @param value        - The value you wish to get the royalty of
     *
     * returns Two arrays of equal length, royalty recipients and the corresponding amount each recipient should get
     */
    function getRoyalty(address tokenAddress, uint256 tokenId, uint256 value)
        external
        returns (address payable[] memory recipients, uint256[] memory amounts);

    /**
     * View only version of getRoyalty
     *
     * @param tokenAddress - The address of the token
     * @param tokenId      - The id of the token
     * @param value        - The value you wish to get the royalty of
     *
     * returns Two arrays of equal length, royalty recipients and the corresponding amount each recipient should get
     */
    function getRoyaltyView(address tokenAddress, uint256 tokenId, uint256 value)
        external
        view
        returns (address payable[] memory recipients, uint256[] memory amounts);
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
pragma solidity ^0.8.17;

import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";

interface IWETH is IERC20 {
    function deposit() external payable;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {TransferHelper} from "./TransferHelper.sol";
import {SanctionsCompliance} from "./SanctionsCompliance.sol";
import {IRoyaltyEngineV1} from "royalty-registry-solidity/IRoyaltyEngineV1.sol";

/*//////////////////////////////////////////////////////////////////////////
                        Royalty Payout Helper
//////////////////////////////////////////////////////////////////////////*/

/// @title Royalty Payout Helper
/// @notice Abstract contract to help payout royalties using the Royalty Registry
/// @dev Does not manage updating the sanctions oracle and expects the child contract to implement
/// @author transientlabs.xyz
/// @custom:last-updated 2.5.0
abstract contract RoyaltyPayoutHelper is TransferHelper, SanctionsCompliance {
    /*//////////////////////////////////////////////////////////////////////////
                                  State Variables
    //////////////////////////////////////////////////////////////////////////*/

    address public weth;
    IRoyaltyEngineV1 public royaltyEngine;

    /*//////////////////////////////////////////////////////////////////////////
                                  Constructor
    //////////////////////////////////////////////////////////////////////////*/

    /// @param sanctionsOracle - the init sanctions oracle
    /// @param wethAddress - the init weth address
    /// @param royaltyEngineAddress - the init royalty engine address
    constructor(address sanctionsOracle, address wethAddress, address royaltyEngineAddress) SanctionsCompliance(sanctionsOracle) {
        weth = wethAddress;
        royaltyEngine = IRoyaltyEngineV1(royaltyEngineAddress);
    }

    /*//////////////////////////////////////////////////////////////////////////
                            Internal State Functions
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Function to update the WETH address
    /// @dev Care should be taken to ensure proper access control for this function
    /// @param wethAddress The new WETH token address
    function _setWethAddress(address wethAddress) internal {
        weth = wethAddress;
    }

    /// @notice Function to update the royalty engine address
    /// @dev Care should be taken to ensure proper access control for this function
    /// @param royaltyEngineAddress The new royalty engine address
    function _setRoyaltyEngineAddress(address royaltyEngineAddress) internal {
        royaltyEngine = IRoyaltyEngineV1(royaltyEngineAddress);
    }

    /*//////////////////////////////////////////////////////////////////////////
                            Royalty Payout Function
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Function to payout royalties from the contract balance based on sale price
    /// @dev if the call to the royalty engine reverts or if the return values are invalid, no payments are made
    /// @dev if the sum of the royalty payouts is greater than the salePrice, the loop exits early for gas savings (this shouldn't happen in reality)
    /// @dev if this is used in a call where tokens should be transferred from a sender, it is advisable to 
    ///      first transfer the required amount to the contract and then call this function, as it will save on gas
    /// @param token The contract address for the token
    /// @param tokenId The token id
    /// @param currency The address of the currency to send to recipients (null address == ETH)
    /// @param salePrice The sale price for the token
    /// @return remainingSale The amount left over in the sale after paying out royalties
    function _payoutRoyalties(address token, uint256 tokenId, address currency, uint256 salePrice)
        internal
        returns (uint256 remainingSale)
    {
        remainingSale = salePrice;
        if (address(royaltyEngine).code.length == 0) return remainingSale;
        try royaltyEngine.getRoyalty(token, tokenId, salePrice) returns (
            address payable[] memory recipients, uint256[] memory amounts
        ) {
            if (recipients.length != amounts.length) return remainingSale;

            for (uint256 i = 0; i < recipients.length; i++) {
                if (_isSanctioned(recipients[i], false)) continue; // don't pay to sanctioned addresses
                if (amounts[i] > remainingSale) break;
                remainingSale -= amounts[i];
                if (currency == address(0)) {
                    _safeTransferETH(recipients[i], amounts[i], weth);
                } else {
                    _safeTransferERC20(recipients[i], currency, amounts[i]);
                }
            }

            return remainingSale;
        } catch {
            return remainingSale;
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/*//////////////////////////////////////////////////////////////////////////
                            Chainalysis Sanctions Oracle
//////////////////////////////////////////////////////////////////////////*/

interface ChainalysisSanctionsOracle {
    function isSanctioned(address addr) external view returns (bool);
}

/*//////////////////////////////////////////////////////////////////////////
                              Errors
//////////////////////////////////////////////////////////////////////////*/

error SanctionedAddress();

/*//////////////////////////////////////////////////////////////////////////
                            Sanctions Compliance
//////////////////////////////////////////////////////////////////////////*/

/// @title Sanctions Compliance
/// @notice Abstract contract to comply with U.S. sanctioned addresses
/// @dev Uses the Chainalysis Sanctions Oracle for checking sanctions
/// @author transientlabs.xyz
/// @custom:last-updated 2.5.0
contract SanctionsCompliance {
    /*//////////////////////////////////////////////////////////////////////////
                                State Variables
    //////////////////////////////////////////////////////////////////////////*/

    ChainalysisSanctionsOracle public oracle;

    /*//////////////////////////////////////////////////////////////////////////
                                Events
    //////////////////////////////////////////////////////////////////////////*/

    event SanctionsOracleUpdated(address indexed prevOracle, address indexed newOracle);

    /*//////////////////////////////////////////////////////////////////////////
                                Constructor
    //////////////////////////////////////////////////////////////////////////*/

    constructor(address initOracle) {
        _updateSanctionsOracle(initOracle);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                Internal Functions
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Internal function to change the sanctions oracle
    /// @param newOracle The new sanctions oracle address
    function _updateSanctionsOracle(address newOracle) internal {
        address prevOracle = address(oracle);
        oracle = ChainalysisSanctionsOracle(newOracle);

        emit SanctionsOracleUpdated(prevOracle, newOracle);
    }

    /// @notice Internal function to check the sanctions oracle for an address
    /// @dev Disable sanction checking by setting the oracle to the zero address
    /// @param sender The address that is trying to send money
    /// @param shouldRevertIfSanctioned A flag indicating if the call should revert if the sender is sanctioned. Set to false if wanting to get a result.
    /// @return isSanctioned Boolean indicating if the sender is sanctioned
    function _isSanctioned(address sender, bool shouldRevertIfSanctioned) internal view returns (bool isSanctioned) {
        if (address(oracle) == address(0)) {
            return false;
        }
        isSanctioned = oracle.isSanctioned(sender);
        if (shouldRevertIfSanctioned && isSanctioned) revert SanctionedAddress();
        return isSanctioned;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {SafeERC20} from "openzeppelin/token/ERC20/utils/SafeERC20.sol";
import {IWETH, IERC20} from "./IWETH.sol";

/*//////////////////////////////////////////////////////////////////////////
                            Custom Errors
//////////////////////////////////////////////////////////////////////////*/

/// @dev ETH transfer failed
error ETHTransferFailed();

/// @dev Transferred too few ERC-20 tokens
error InsufficentERC20Transfer();

/*//////////////////////////////////////////////////////////////////////////
                            Transfer Helper
//////////////////////////////////////////////////////////////////////////*/

/// @title Transfer Helper
/// @notice Abstract contract that has helper function for sending ETH and ERC20's safely
/// @author transientlabs.xyz
/// @custom:last-updated 2.6.0
abstract contract TransferHelper {
    /*//////////////////////////////////////////////////////////////////////////
                                  State Variables
    //////////////////////////////////////////////////////////////////////////*/

    using SafeERC20 for IERC20;
    using SafeERC20 for IWETH;

    /*//////////////////////////////////////////////////////////////////////////
                                   ETH Functions
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Function to force transfer ETH, defaulting to forwarding 100k gas
    /// @dev On failure to send the ETH, the ETH is converted to WETH and sent
    /// @dev Care should be taken to always pass the proper WETH address that adheres to IWETH
    /// @param recipient The recipient of the ETH
    /// @param amount The amount of ETH to send
    /// @param weth The WETH token address
    function _safeTransferETH(address recipient, uint256 amount, address weth) internal {
        _safeTransferETH(recipient, amount, weth, 1e5);
    }

    /// @notice Function to force transfer ETH, with a gas limit
    /// @dev On failure to send the ETH, the ETH is converted to WETH and sent
    /// @dev Care should be taken to always pass the proper WETH address that adheres to IWETH
    /// @param recipient The recipient of the ETH
    /// @param amount The amount of ETH to send
    /// @param weth The WETH token address
    /// @param gasLimit The gas to forward
    function _safeTransferETH(address recipient, uint256 amount, address weth, uint256 gasLimit) internal {
        (bool success,) = recipient.call{value: amount, gas: gasLimit}("");
        if (!success) {
            IWETH token = IWETH(weth);
            token.deposit{value: amount}();
            token.safeTransfer(recipient, amount);
        }
    }

    /*//////////////////////////////////////////////////////////////////////////
                                  ERC-20 Functions
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Function to safely transfer ERC-20 tokens from the contract, without checking for token tax
    /// @dev Does not check if the sender has enough balance as that is handled by the token contract
    /// @dev Does not check for token tax as that could lock up funds in the contract
    /// @dev Reverts on failure to transfer
    /// @param recipient The recipient of the ERC-20 token
    /// @param currency The address of the ERC-20 token
    /// @param amount The amount of ERC-20 to send
    function _safeTransferERC20(address recipient, address currency, uint256 amount) internal {
        IERC20(currency).safeTransfer(recipient, amount);
    }

    /// @notice Function to safely transfer ERC-20 tokens from another address to a recipient
    /// @dev Does not check if the sender has enough balance or allowance for this contract as that is handled by the token contract
    /// @dev Reverts on failure to transfer
    /// @dev Reverts if there is a token tax taken out
    /// @param sender The sender of the tokens
    /// @param recipient The recipient of the ERC-20 token
    /// @param currency The address of the ERC-20 token
    /// @param amount The amount of ERC-20 to send
    function _safeTransferFromERC20(address sender, address recipient, address currency, uint256 amount) internal {
        IERC20 token = IERC20(currency);
        uint256 intialBalance = token.balanceOf(recipient);
        token.safeTransferFrom(sender, recipient, amount);
        uint256 finalBalance = token.balanceOf(recipient);
        if (finalBalance - intialBalance < amount) revert InsufficentERC20Transfer();
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Ownable} from "openzeppelin/access/Ownable.sol";
import {Pausable} from "openzeppelin/security/Pausable.sol";
import {ReentrancyGuard} from "openzeppelin/security/ReentrancyGuard.sol";
import {IERC721} from "openzeppelin/token/ERC721/IERC721.sol";
import {RoyaltyPayoutHelper} from "tl-sol-tools/payments/RoyaltyPayoutHelper.sol";
import {AuctionHouseErrors} from "tl-stacks/utils/CommonUtils.sol";
import {Auction, Sale, ITLAuctionHouseEvents} from "tl-stacks/utils/TLAuctionHouseUtils.sol";

/*//////////////////////////////////////////////////////////////////////////
                            TL Auction House
//////////////////////////////////////////////////////////////////////////*/

/// @title TLAuctionHouse
/// @notice Transient Labs Auction House with Reserve Auctions and Buy Now Sales for ERC-721 tokens
/// @author transientlabs.xyz
/// @custom:version-last-updated 2.1.0
contract TLAuctionHouse is
    Ownable,
    Pausable,
    ReentrancyGuard,
    RoyaltyPayoutHelper,
    ITLAuctionHouseEvents,
    AuctionHouseErrors
{
    /*//////////////////////////////////////////////////////////////////////////
                                  Constants
    //////////////////////////////////////////////////////////////////////////*/

    string public constant VERSION = "2.1.0";
    uint256 public constant EXTENSION_TIME = 15 minutes;
    uint256 public constant BASIS = 10_000;

    /*//////////////////////////////////////////////////////////////////////////
                                State Variables
    //////////////////////////////////////////////////////////////////////////*/

    address public protocolFeeReceiver; // the payout receiver for the protocol fee
    uint256 public minBidIncreasePerc; // the nominal bid increase percentage (out of BASIS) so bids can't be increased by just tiny amounts
    uint256 public minBidIncreaseLimit; // the absolute min bid increase amount (ex: 1 ether)
    uint256 public protocolFeePerc; // the nominal protocol fee percentage (out of BASIS) to charge the buyer or seller
    uint256 public protocolFeeLimit; // the absolute limit for the protocol fee (ex: 1 ether)
    mapping(address => mapping(uint256 => Auction)) internal _auctions; // nft address -> token id -> auction
    mapping(address => mapping(uint256 => Sale)) internal _sales; // nft address -> token id -> sale

    /*//////////////////////////////////////////////////////////////////////////
                                Constructor
    //////////////////////////////////////////////////////////////////////////*/

    constructor(
        address initSanctionsOracle,
        address initWethAddress,
        address initRoyaltyEngineAddress,
        address initProtocolFeeReceiver,
        uint256 initMinBidIncreasePerc,
        uint256 initMinBidIncreaseLimit,
        uint256 initProtocolFeePerc,
        uint256 initProtocolFeeLimit
    )
        Ownable()
        Pausable()
        ReentrancyGuard()
        RoyaltyPayoutHelper(initSanctionsOracle, initWethAddress, initRoyaltyEngineAddress)
    {
        _setMinBidIncreaseSettings(initMinBidIncreasePerc, initMinBidIncreaseLimit);
        _setProtocolFeeSettings(initProtocolFeeReceiver, initProtocolFeePerc, initProtocolFeeLimit);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                Owner Functions
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Function to set a new royalty engine address
    /// @dev Requires owner
    /// @param newRoyaltyEngine The new royalty engine address
    function setRoyaltyEngine(address newRoyaltyEngine) external onlyOwner {
        address prevRoyaltyEngine = address(royaltyEngine);
        _setRoyaltyEngineAddress(newRoyaltyEngine);

        emit RoyaltyEngineUpdated(prevRoyaltyEngine, newRoyaltyEngine);
    }

    /// @notice Function to set a new weth address
    /// @dev Requires owner
    /// @param newWethAddress The new weth address
    function setWethAddress(address newWethAddress) external onlyOwner {
        address prevWeth = weth;
        _setWethAddress(newWethAddress);

        emit WethUpdated(prevWeth, newWethAddress);
    }

    /// @notice Function to set the min bid increase settings
    /// @dev Requires owner
    /// @param newMinBidIncreasePerc The new minimum bid increase nominal percentage, out of `BASIS`
    /// @param newMinBidIncreaseLimit The new minimum bid increase absolute limit
    function setMinBidIncreaseSettings(uint256 newMinBidIncreasePerc, uint256 newMinBidIncreaseLimit)
        external
        onlyOwner
    {
        _setMinBidIncreaseSettings(newMinBidIncreasePerc, newMinBidIncreaseLimit);
    }

    /// @notice Function to set the protocol fee settings
    /// @dev Requires owner
    /// @param newProtocolFeeReceiver The new protocol fee receiver
    /// @param newProtocolFeePerc The new protocol fee percentage, out of `BASIS`
    /// @param newProtocolFeeLimit The new protocol fee limit
    function setProtocolFeeSettings(
        address newProtocolFeeReceiver,
        uint256 newProtocolFeePerc,
        uint256 newProtocolFeeLimit
    ) external onlyOwner {
        _setProtocolFeeSettings(newProtocolFeeReceiver, newProtocolFeePerc, newProtocolFeeLimit);
    }

    /// @notice Function to pause the contract
    /// @dev Requires owner
    /// @param status The boolean to set the internal pause variable
    function pause(bool status) external onlyOwner {
        if (status) {
            _pause();
        } else {
            _unpause();
        }
    }

    /// @notice Function to set the sanctions oracle
    /// @dev Requires owner
    /// @param newOracle The new oracle address
    function setSanctionsOracle(address newOracle) external onlyOwner {
        _updateSanctionsOracle(newOracle);
    }

    /*//////////////////////////////////////////////////////////////////////////
                            Auction Configuration Functions
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Function to configure an auction
    /// @dev Requires the following items to be true
    ///     - contract is not paused
    ///     - the auction hasn't been configured yet for the current token owner
    ///     - msg.sender is the owner of the token
    ///     - auction house is approved for all
    ///     - payoutReceiver isn't the zero address
    /// @param nftAddress The nft contract address
    /// @param tokenId The nft token id
    /// @param payoutReceiver The address that receives the payout from the auction
    /// @param currencyAddress The currency to use
    /// @param reservePrice The auction reserve price
    /// @param auctionOpenTime The time at which bidding is allowed
    /// @param duration The duration of the auction after it is started
    /// @param reserveAuction A flag dictating if the auction is a reserve auction or regular scheduled auction
    function configureAuction(
        address nftAddress,
        uint256 tokenId,
        address payoutReceiver,
        address currencyAddress,
        uint256 reservePrice,
        uint256 auctionOpenTime,
        uint256 duration,
        bool reserveAuction
    ) external whenNotPaused nonReentrant {
        // sanctions
        _isSanctioned(msg.sender, true);
        _isSanctioned(payoutReceiver, true);

        IERC721 nft = IERC721(nftAddress);
        bool isNftOwner = _checkTokenOwnership(nft, tokenId, msg.sender);
        uint256 startTime = reserveAuction ? 0 : auctionOpenTime;

        if (isNftOwner) {
            if (!_checkAuctionHouseApproval(nft, msg.sender)) revert AuctionHouseNotApproved();
            if (!_checkPayoutReceiver(payoutReceiver)) revert PayoutToZeroAddress();
        } else {
            revert CallerNotTokenOwner();
        }

        Auction memory auction = Auction(
            msg.sender,
            payoutReceiver,
            currencyAddress,
            address(0),
            0,
            reservePrice,
            auctionOpenTime,
            startTime,
            duration
        );

        _auctions[nftAddress][tokenId] = auction;

        emit AuctionConfigured(msg.sender, nftAddress, tokenId, auction);
    }

    /// @notice Function to cancel an auction
    /// @dev Requires the following to be true
    ///     - msg.sender to be the auction seller
    ///     - the auction cannot be started
    /// @param nftAddress The nft contract address
    /// @param tokenId The nft token id
    function cancelAuction(address nftAddress, uint256 tokenId) external nonReentrant {
        IERC721 nft = IERC721(nftAddress);
        Auction memory auction = _auctions[nftAddress][tokenId];
        bool isNftOwner = _checkTokenOwnership(nft, tokenId, msg.sender);

        if (msg.sender != auction.seller) {
            if (!isNftOwner) revert CallerNotTokenOwner();
        }
        if (auction.highestBidder != address(0)) revert AuctionStarted();

        delete _auctions[nftAddress][tokenId];

        emit AuctionCanceled(msg.sender, nftAddress, tokenId);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    Auction Functions
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Function to bid on an auction
    /// @dev Requires the following to be true
    ///     - contract is not paused
    ///     - block.timestamp is greater than the auction open timestamp
    ///     - bid meets or exceeds the reserve price / min bid price
    ///     - msg.sender has attached enough eth/erc20 as specified by `amount`
    ///     - protocol fee has been supplied, if needed
    /// @param nftAddress The nft contract address
    /// @param tokenId The nft token id
    /// @param amount The amount to bid in the currency address set in the auction
    function bid(address nftAddress, uint256 tokenId, uint256 amount) external payable whenNotPaused nonReentrant {
        _isSanctioned(msg.sender, true);

        // cache items
        Auction memory auction = _auctions[nftAddress][tokenId];
        IERC721 nft = IERC721(nftAddress);
        bool firstBid;
        bool durationExtended;

        // check if the auction is open
        if (auction.seller == address(0)) revert AuctionNotConfigured();
        if (block.timestamp < auction.auctionOpenTime) revert AuctionNotOpen();

        if (auction.highestBidder == address(0)) {
            // first bid
            // - check bid amount
            // - clear sale
            // - start the auction (if reserve auction)
            // - escrow the NFT
            if (amount < auction.reservePrice) revert BidTooLow();
            delete _sales[nftAddress][tokenId];
            if (auction.startTime == 0) {
                auction.startTime = block.timestamp;
                firstBid = true;
            }
            // escrow nft
            if (nft.ownerOf(tokenId) != auction.seller) revert NftNotOwnedBySeller();
            nft.transferFrom(auction.seller, address(this), tokenId);
            if (nft.ownerOf(tokenId) != address(this)) revert NftNotTransferred();
        } else {
            // subsequent bids
            // - check if auction ended
            // - check bid amount
            // - refund previous bidder
            if (block.timestamp > auction.startTime + auction.duration) revert AuctionEnded();
            if (amount < _calcNextMinBid(auction.highestBid)) revert BidTooLow();
            uint256 refundAmount = auction.highestBid + _calcProtocolFee(auction.highestBid);
            if (auction.currencyAddress == address(0)) {
                _safeTransferETH(auction.highestBidder, refundAmount, weth);
            } else {
                _safeTransferERC20(auction.highestBidder, auction.currencyAddress, refundAmount);
            }
        }

        // set highest bid
        auction.highestBid = amount;
        auction.highestBidder = msg.sender;

        // extend auction if needed
        uint256 timeRemaining = auction.startTime + auction.duration - block.timestamp;
        if (timeRemaining < EXTENSION_TIME) {
            auction.duration += EXTENSION_TIME - timeRemaining;
            durationExtended = true;
        }

        // store updated parameters to storage
        Auction storage sAuction = _auctions[nftAddress][tokenId];
        sAuction.highestBid = auction.highestBid;
        sAuction.highestBidder = auction.highestBidder;
        if (firstBid) sAuction.startTime = auction.startTime;
        if (durationExtended) sAuction.duration = auction.duration;

        // calculate the protocol fee
        uint256 protocolFee = _calcProtocolFee(amount);

        // transfer funds (move ERC20, refund ETH)
        uint256 totalAmount = amount + protocolFee;
        if (auction.currencyAddress == address(0)) {
            if (msg.value < totalAmount) revert InsufficientMsgValue();
            uint256 refund = msg.value - totalAmount;
            if (refund > 0) {
                _safeTransferETH(msg.sender, refund, weth);
            }
        } else {
            _safeTransferFromERC20(msg.sender, address(this), auction.currencyAddress, totalAmount);
            if (msg.value > 0) {
                _safeTransferETH(msg.sender, msg.value, weth);
            }
        }

        emit AuctionBid(msg.sender, nftAddress, tokenId, auction);
    }

    /// @notice Function to settle an auction
    /// @dev Can be called by anyone
    /// @dev Requires the following to be true
    ///     - auction has been started
    ///     - auction has ended
    /// @param nftAddress The nft contract address
    /// @param tokenId The nft token id
    function settleAuction(address nftAddress, uint256 tokenId) external nonReentrant {
        // cache items
        Auction memory auction = _auctions[nftAddress][tokenId];
        IERC721 nft = IERC721(nftAddress);

        // check requirements
        if (auction.highestBidder == address(0)) revert AuctionNotStarted();
        if (block.timestamp < auction.startTime + auction.duration) revert AuctionNotEnded();

        // clear the auction
        delete _auctions[nftAddress][tokenId];

        // payout auction
        _payout(nftAddress, tokenId, auction.currencyAddress, auction.highestBid, auction.payoutReceiver);

        // transfer nft
        nft.transferFrom(address(this), auction.highestBidder, tokenId);
        if (nft.ownerOf(tokenId) != auction.highestBidder) revert NftNotTransferred();

        emit AuctionSettled(msg.sender, nftAddress, tokenId, auction);
    }

    /*//////////////////////////////////////////////////////////////////////////
                            Sales Configuration Functions
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Function to configure a buy now sale
    /// @dev Requires the following to be true
    ///     - contract is not paused
    ///     - the sale hasn't been configured yet by the current token owner
    ///     - an auction hasn't been started - this is captured by token ownership
    ///     - msg.sender is the owner of the token
    ///     - auction house is approved for all
    ///     - payoutReceiver isn't the zero address
    /// @param nftAddress The nft contract address
    /// @param tokenId The nft token id
    /// @param payoutReceiver The address that receives the payout from the sale
    /// @param currencyAddress The currency to use
    /// @param price The sale price
    /// @param saleOpenTime The time at which the sale opens
    function configureSale(
        address nftAddress,
        uint256 tokenId,
        address payoutReceiver,
        address currencyAddress,
        uint256 price,
        uint256 saleOpenTime
    ) external whenNotPaused nonReentrant {
        // sanctions
        _isSanctioned(msg.sender, true);
        _isSanctioned(payoutReceiver, true);

        IERC721 nft = IERC721(nftAddress);
        bool isNftOwner = _checkTokenOwnership(nft, tokenId, msg.sender);

        if (isNftOwner) {
            if (!_checkAuctionHouseApproval(nft, msg.sender)) revert AuctionHouseNotApproved();
            if (!_checkPayoutReceiver(payoutReceiver)) revert PayoutToZeroAddress();
        } else {
            revert CallerNotTokenOwner();
        }

        Sale memory sale = Sale(msg.sender, payoutReceiver, currencyAddress, price, saleOpenTime);

        _sales[nftAddress][tokenId] = sale;

        emit SaleConfigured(msg.sender, nftAddress, tokenId, sale);
    }

    /// @notice Function to cancel a sale
    /// @dev Requires msg.sender to be the token owner
    /// @param nftAddress The nft contract address
    /// @param tokenId The nft token id
    function cancelSale(address nftAddress, uint256 tokenId) external nonReentrant {
        IERC721 nft = IERC721(nftAddress);
        Sale memory sale = _sales[nftAddress][tokenId];
        bool isNftOwner = _checkTokenOwnership(nft, tokenId, msg.sender);

        if (msg.sender != sale.seller) {
            if (!isNftOwner) revert CallerNotTokenOwner();
        }

        delete _sales[nftAddress][tokenId];

        emit SaleCanceled(msg.sender, nftAddress, tokenId);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    Sales Functions
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Function to buy a token
    /// @dev Requires the following to be true
    ///     - contract is not paused
    ///     - block.timestamp is greater than the sale open timestamp
    ///     - msg.sender has attached enough eth/erc20 as specified by the sale
    ///     - protocol fee has been supplied, if needed
    /// @param nftAddress The nft contract address
    /// @param tokenId The nft token id
    function buyNow(address nftAddress, uint256 tokenId) external payable whenNotPaused nonReentrant {
        _isSanctioned(msg.sender, true);

        // cache items
        Sale memory sale = _sales[nftAddress][tokenId];
        IERC721 nft = IERC721(nftAddress);

        // check if the sale is open
        if (sale.seller == address(0)) revert SaleNotConfigured();
        if (block.timestamp < sale.saleOpenTime) revert SaleNotOpen();

        // check that the nft is owned by the seller still
        if (nft.ownerOf(tokenId) != sale.seller) revert NftNotOwnedBySeller();

        // clear storage
        delete _auctions[nftAddress][tokenId];
        delete _sales[nftAddress][tokenId];

        // calculate the protocol fee
        uint256 protocolFee = _calcProtocolFee(sale.price);

        // transfer funds to the contract, refunding if needed
        uint256 totalAmount = sale.price + protocolFee;
        if (sale.currencyAddress == address(0)) {
            if (msg.value < totalAmount) revert InsufficientMsgValue();
            uint256 refund = msg.value - totalAmount;
            if (refund > 0) {
                _safeTransferETH(msg.sender, refund, weth);
            }
        } else {
            _safeTransferFromERC20(msg.sender, address(this), sale.currencyAddress, totalAmount);
            if (msg.value > 0) {
                _safeTransferETH(msg.sender, msg.value, weth);
            }
        }

        // payout sale
        _payout(nftAddress, tokenId, sale.currencyAddress, sale.price, sale.payoutReceiver);

        // transfer nft
        nft.transferFrom(sale.seller, msg.sender, tokenId);
        if (nft.ownerOf(tokenId) != msg.sender) revert NftNotTransferred();

        emit SaleFulfilled(msg.sender, nftAddress, tokenId, sale);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                External View Functions
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice function to get a sale
    /// @param nftAddress The nft contract address
    /// @param tokenId The nft token id
    /// @return sale The sale struct
    function getSale(address nftAddress, uint256 tokenId) external view returns (Sale memory) {
        return _sales[nftAddress][tokenId];
    }

    /// @notice function to get an auction
    /// @param nftAddress The nft contract address
    /// @param tokenId The nft token id
    /// @return auction The auction struct
    function getAuction(address nftAddress, uint256 tokenId) external view returns (Auction memory) {
        return _auctions[nftAddress][tokenId];
    }

    /// @notice function to get the next minimum bid price for an auction
    /// @param nftAddress The nft contract address
    /// @param tokenId The nft token id
    /// @return uint256 The next minimum bid required
    function calcNextMinBid(address nftAddress, uint256 tokenId) external view returns (uint256) {
        return _calcNextMinBid(_auctions[nftAddress][tokenId].highestBid);
    }

    /// @notice function to calculate the protocol fee
    /// @param amount The value to calculate the fee for
    /// @return uint256 The calculated fee
    function calcProtocolFee(uint256 amount) external view returns (uint256) {
        return _calcProtocolFee(amount);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                Internal Helper Functions
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Internal function to set the min bid increase settings
    /// @param newMinBidIncreasePerc The new minimum bid increase nominal percentage, out of `BASIS`
    /// @param newMinBidIncreaseLimit The new minimum bid increase absolute limit
    function _setMinBidIncreaseSettings(uint256 newMinBidIncreasePerc, uint256 newMinBidIncreaseLimit) internal {
        if (newMinBidIncreasePerc > BASIS) revert PercentageTooLarge();

        minBidIncreasePerc = newMinBidIncreasePerc;
        minBidIncreaseLimit = newMinBidIncreaseLimit;

        emit MinBidIncreaseUpdated(newMinBidIncreasePerc, newMinBidIncreaseLimit);
    }

    /// @notice Internal function to set the protocol fee settings
    /// @param newProtocolFeeReceiver The new protocol fee receiver
    /// @param newProtocolFeePerc The new protocol fee percentage, out of `BASIS`
    /// @param newProtocolFeeLimit The new protocol fee limit
    function _setProtocolFeeSettings(
        address newProtocolFeeReceiver,
        uint256 newProtocolFeePerc,
        uint256 newProtocolFeeLimit
    ) internal {
        if (newProtocolFeePerc > BASIS) revert PercentageTooLarge();

        protocolFeeReceiver = newProtocolFeeReceiver;
        protocolFeePerc = newProtocolFeePerc;
        protocolFeeLimit = newProtocolFeeLimit;

        emit ProtocolFeeUpdated(newProtocolFeeReceiver, newProtocolFeePerc, newProtocolFeeLimit);
    }

    /// @notice Internal function to check if a token is owned by an address
    /// @param nft The nft contract
    /// @param tokenId The nft token id
    /// @param potentialTokenOwner The potential token owner to check against
    /// @return bool Indication of if the address in quesion is the owner of the token
    function _checkTokenOwnership(IERC721 nft, uint256 tokenId, address potentialTokenOwner)
        internal
        view
        returns (bool)
    {
        return nft.ownerOf(tokenId) == potentialTokenOwner;
    }

    /// @notice Internal function to check if the auction house is approved for all
    /// @param nft The nft contract
    /// @param seller The seller to check against
    /// @return bool Indication of if the auction house is approved for all by the seller
    function _checkAuctionHouseApproval(IERC721 nft, address seller) internal view returns (bool) {
        return nft.isApprovedForAll(seller, address(this));
    }

    /// @notice Internal function to check if a payout address is a valid address
    /// @param payoutReceiver The payout address to check
    /// @return bool Indication of if the payout address is not the zero address
    function _checkPayoutReceiver(address payoutReceiver) internal pure returns (bool) {
        return payoutReceiver != address(0);
    }

    /// @notice Internal function to calculate the next min bid price
    /// @param currentBid The current bid
    /// @return nextMinBid The next minimum bid
    function _calcNextMinBid(uint256 currentBid) internal view returns (uint256 nextMinBid) {
        uint256 bidIncrease = currentBid * minBidIncreasePerc / BASIS;
        if (bidIncrease > minBidIncreaseLimit) {
            bidIncrease = minBidIncreaseLimit;
        }
        nextMinBid = currentBid + bidIncrease;
    }

    /// @notice Internal function to calculate the protocol fee
    /// @param amount The value of the sale
    /// @return fee The protocol fee
    function _calcProtocolFee(uint256 amount) internal view returns (uint256 fee) {
        fee = amount * protocolFeePerc / BASIS;
        if (fee > protocolFeeLimit) {
            fee = protocolFeeLimit;
        }
    }

    /// @notice Internal function to payout from the contract
    /// @param nftAddress The nft contract address
    /// @param tokenId The token id
    /// @param currencyAddress The currency address (ZERO ADDRESS == ETH)
    /// @param amount The sale/auction end price
    /// @param payoutReceiver The receiver for the sale payout (what's remaining after royalties)
    function _payout(
        address nftAddress,
        uint256 tokenId,
        address currencyAddress,
        uint256 amount,
        address payoutReceiver
    ) internal {
        // calc protocol fee
        uint256 protocolFee = _calcProtocolFee(amount);

        // payout royalties
        uint256 remainingAmount = _payoutRoyalties(nftAddress, tokenId, currencyAddress, amount);

        // distribute protocol fee and remaining amount - should be escrowed in this contract
        if (currencyAddress == address(0)) {
            // transfer protocol fee
            _safeTransferETH(protocolFeeReceiver, protocolFee, weth);
            // transfer remaining value to payout receiver
            _safeTransferETH(payoutReceiver, remainingAmount, weth);
        } else {
            // transfer protocol fee
            _safeTransferERC20(protocolFeeReceiver, currencyAddress, protocolFee);
            // transfer remaining value to payout receiver
            _safeTransferERC20(payoutReceiver, currencyAddress, remainingAmount);
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/// @dev Enum to encapsulate drop phases
enum DropPhase {
    NOT_CONFIGURED,
    NOT_STARTED,
    PRESALE,
    PUBLIC_SALE,
    ENDED
}

/// @dev Enum to encapsulate drop types
enum DropType {
    NOT_CONFIGURED,
    REGULAR,
    VELOCITY
}

/// @dev Errors for Drops
interface DropErrors {
    error NotDropAdmin();
    error NotApprovedMintContract();
    error InvalidPayoutReceiver();
    error InvalidDropSupply();
    error DropNotConfigured();
    error DropAlreadyConfigured();
    error InvalidDropType();
    error NotAllowedForVelocityDrops();
    error MintZeroTokens();
    error NotOnAllowlist();
    error YouShallNotMint();
    error AlreadyReachedMintAllowance();
    error InvalidBatchArguments();
    error InsufficientFunds();
}

/// @dev Errors for the Auction House
interface AuctionHouseErrors {
    error PercentageTooLarge();
    error CallerNotTokenOwner();
    error AuctionHouseNotApproved();
    error PayoutToZeroAddress();
    error NftNotOwnedBySeller();
    error NftNotTransferred();
    error AuctionNotConfigured();
    error AuctionNotStarted();
    error AuctionStarted();
    error AuctionNotOpen();
    error BidTooLow();
    error AuctionEnded();
    error AuctionNotEnded();
    error InsufficientMsgValue();
    error SaleNotConfigured();
    error SaleNotOpen();
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/// @dev Auction struct
/// @param seller The seller of the token
/// @param payoutReceiver The address that receives any payout from the auction
/// @param currencyAddress The currency address - Zero address == ETH
/// @param highestBidder The highest bidder address
/// @param highestBid The highest bid
/// @param reservePrice The reserve price of the auction
/// @param auctionOpenTime The timestamp at which bidding is allowed
/// @param startTime The timestamp at which the auction was kicked off with a bid
/// @param duration The duration the auction should last after it is started
struct Auction {
    address seller;
    address payoutReceiver;
    address currencyAddress;
    address highestBidder;
    uint256 highestBid;
    uint256 reservePrice;
    uint256 auctionOpenTime;
    uint256 startTime;
    uint256 duration;
}

/// @dev Sale struct
/// @param seller The seller of the token
/// @param payoutReceiver The address that receives any payout from the auction
/// @param currencyAddress The currency address - Zero address == ETH
/// @param price The price for the nft
struct Sale {
    address seller;
    address payoutReceiver;
    address currencyAddress;
    uint256 price;
    uint256 saleOpenTime;
}

interface ITLAuctionHouseEvents {
    event RoyaltyEngineUpdated(address indexed prevRoyaltyEngine, address indexed newRoyaltyEngine);
    event WethUpdated(address indexed prevWeth, address indexed newWeth);
    event MinBidIncreaseUpdated(uint256 indexed newMinBidIncreasePerc, uint256 indexed newMinBidIncreaseLimit);
    event ProtocolFeeUpdated(
        address indexed newProtocolFeeReceiver, uint256 indexed newProtocolFeePerc, uint256 indexed newProtocolFeeLimit
    );

    event AuctionConfigured(
        address indexed sender, address indexed nftAddress, uint256 indexed tokenId, Auction auction
    );
    event AuctionCanceled(address indexed sender, address indexed nftAddress, uint256 indexed tokenId);
    event AuctionSettled(address indexed sender, address indexed nftAddress, uint256 indexed tokenId, Auction auction);
    event AuctionBid(address indexed sender, address indexed nftAddress, uint256 indexed tokenId, Auction auction);

    event SaleConfigured(address indexed sender, address indexed nftAddress, uint256 indexed tokenId, Sale sale);
    event SaleCanceled(address indexed sender, address indexed nftAddress, uint256 indexed tokenId);
    event SaleFulfilled(address indexed sender, address indexed nftAddress, uint256 indexed tokenId, Sale sale);
}