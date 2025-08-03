// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (governance/utils/IVotes.sol)
pragma solidity ^0.8.0;

/**
 * @dev Common interface for {ERC20Votes}, {ERC721Votes}, and other {Votes}-enabled contracts.
 *
 * _Available since v4.5._
 */
interface IVotes {
    /**
     * @dev Emitted when an account changes their delegate.
     */
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    /**
     * @dev Emitted when a token transfer or delegate change results in changes to a delegate's number of votes.
     */
    event DelegateVotesChanged(address indexed delegate, uint256 previousBalance, uint256 newBalance);

    /**
     * @dev Returns the current amount of votes that `account` has.
     */
    function getVotes(address account) external view returns (uint256);

    /**
     * @dev Returns the amount of votes that `account` had at the end of a past block (`blockNumber`).
     */
    function getPastVotes(address account, uint256 blockNumber) external view returns (uint256);

    /**
     * @dev Returns the total supply of votes available at the end of a past block (`blockNumber`).
     *
     * NOTE: This value is the sum of all available votes, which is not necessarily the sum of all delegated votes.
     * Votes that have not been delegated are still part of total supply, even though they would not participate in a
     * vote.
     */
    function getPastTotalSupply(uint256 blockNumber) external view returns (uint256);

    /**
     * @dev Returns the delegate that `account` has chosen.
     */
    function delegates(address account) external view returns (address);

    /**
     * @dev Delegates votes from the sender to `delegatee`.
     */
    function delegate(address delegatee) external;

    /**
     * @dev Delegates votes from signer to `delegatee`.
     */
    function delegateBySig(
        address delegatee,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (metatx/ERC2771Context.sol)

pragma solidity ^0.8.9;

import "../utils/Context.sol";

/**
 * @dev Context variant with ERC2771 support.
 */
abstract contract ERC2771Context is Context {
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable
    address private immutable _trustedForwarder;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(address trustedForwarder) {
        _trustedForwarder = trustedForwarder;
    }

    function isTrustedForwarder(address forwarder) public view virtual returns (bool) {
        return forwarder == _trustedForwarder;
    }

    function _msgSender() internal view virtual override returns (address sender) {
        if (isTrustedForwarder(msg.sender)) {
            // The assembly code is more direct than the Solidity version using `abi.decode`.
            /// @solidity memory-safe-assembly
            assembly {
                sender := shr(96, calldataload(sub(calldatasize(), 20)))
            }
        } else {
            return super._msgSender();
        }
    }

    function _msgData() internal view virtual override returns (bytes calldata) {
        if (isTrustedForwarder(msg.sender)) {
            return msg.data[:msg.data.length - 20];
        } else {
            return super._msgData();
        }
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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/Math.sol)

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
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
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
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1);

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
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
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
            if (value >= 10**64) {
                value /= 10**64;
                result += 64;
            }
            if (value >= 10**32) {
                value /= 10**32;
                result += 32;
            }
            if (value >= 10**16) {
                value /= 10**16;
                result += 16;
            }
            if (value >= 10**8) {
                value /= 10**8;
                result += 8;
            }
            if (value >= 10**4) {
                value /= 10**4;
                result += 4;
            }
            if (value >= 10**2) {
                value /= 10**2;
                result += 2;
            }
            if (value >= 10**1) {
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
            return result + (rounding == Rounding.Up && 10**result < value ? 1 : 0);
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
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result * 8) < value ? 1 : 0);
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IVotes } from "@openzeppelin/contracts/governance/utils/IVotes.sol";
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";

interface IFolio is IERC20 {
    // === Events ===

    event AuctionApproved(uint256 indexed auctionId, address indexed from, address indexed to, Auction auction);
    event AuctionOpened(uint256 indexed auctionId, Auction auction);
    event AuctionBid(uint256 indexed auctionId, uint256 sellAmount, uint256 buyAmount);
    event AuctionClosed(uint256 indexed auctionId);

    event FolioFeePaid(address indexed recipient, uint256 amount);
    event ProtocolFeePaid(address indexed recipient, uint256 amount);

    event BasketTokenAdded(address indexed token);
    event BasketTokenRemoved(address indexed token);
    event TVLFeeSet(uint256 newFee, uint256 feeAnnually);
    event MintFeeSet(uint256 newFee);
    event FeeRecipientSet(address indexed recipient, uint96 portion);
    event AuctionDelaySet(uint256 newAuctionDelay);
    event AuctionLengthSet(uint256 newAuctionLength);
    event MandateSet(string newMandate);
    event FolioKilled();

    // === Errors ===

    error Folio__FolioKilled();
    error Folio__Unauthorized();

    error Folio__EmptyAssets();
    error Folio__BasketModificationFailed();

    error Folio__FeeRecipientInvalidAddress();
    error Folio__FeeRecipientInvalidFeeShare();
    error Folio__BadFeeTotal();
    error Folio__TVLFeeTooHigh();
    error Folio__TVLFeeTooLow();
    error Folio__MintFeeTooHigh();
    error Folio__ZeroInitialShares();

    error Folio__InvalidAsset();
    error Folio__InvalidAssetAmount(address asset);

    error Folio__InvalidAuctionLength();
    error Folio__InvalidSellLimit();
    error Folio__InvalidBuyLimit();
    error Folio__AuctionCannotBeOpened();
    error Folio__AuctionCannotBeOpenedPermissionlesslyYet();
    error Folio__AuctionNotOngoing();
    error Folio__AuctionCollision();
    error Folio__InvalidPrices();
    error Folio__AuctionTimeout();
    error Folio__SlippageExceeded();
    error Folio__InsufficientBalance();
    error Folio__InsufficientBid();
    error Folio__ExcessiveBid();
    error Folio__InvalidAuctionTokens();
    error Folio__InvalidAuctionDelay();
    error Folio__InvalidAuctionTTL();
    error Folio__TooManyFeeRecipients();
    error Folio__InvalidArrayLengths();

    // === Structures ===

    struct FolioBasicDetails {
        string name;
        string symbol;
        address[] assets;
        uint256[] amounts; // {tok}
        uint256 initialShares; // {share}
    }

    struct FolioAdditionalDetails {
        uint256 auctionDelay; // {s}
        uint256 auctionLength; // {s}
        FeeRecipient[] feeRecipients;
        uint256 tvlFee; // D18{1/s}
        uint256 mintFee; // D18{1}
        string mandate;
    }

    struct FeeRecipient {
        address recipient;
        uint96 portion; // D18{1}
    }

    struct BasketRange {
        uint256 spot; // D27{buyTok/share}
        uint256 low; // D27{buyTok/share} inclusive
        uint256 high; // D27{buyTok/share} inclusive
    }

    struct Prices {
        uint256 start; // D27{buyTok/sellTok}
        uint256 end; // D27{buyTok/sellTok}
    }

    /// Auction states:
    ///   - APPROVED: start == 0 && end == 0
    ///   - OPEN: block.timestamp >= start && block.timestamp <= end
    ///   - CLOSED: block.timestamp > end
    struct Auction {
        uint256 id;
        IERC20 sell;
        IERC20 buy;
        BasketRange sellLimit; // D27{sellTok/share} min ratio of sell token in the basket, inclusive
        BasketRange buyLimit; // D27{buyTok/share} max ratio of buy token in the basket, exclusive
        Prices prices; // D27{buyTok/sellTok}
        uint256 availableAt; // {s} inclusive
        uint256 launchTimeout; // {s} inclusive
        uint256 start; // {s} inclusive
        uint256 end; // {s} inclusive
        // === Gas optimization ===
        uint256 k; // D18{1} price = startPrice * e ^ -kt
    }

    function distributeFees() external;

    function folio() external view returns (address[] memory _assets, uint256[] memory _amounts);
    function toAssets(uint256 shares, Math.Rounding rounding) external view returns (address[] memory _assets, uint256[] memory _amounts);
    function AUCTION_APPROVER() external view returns (bytes32);
    function AUCTION_LAUNCHER() external view returns (bytes32);
    function BRAND_MANAGER() external view returns (bytes32);

    function mint(uint256 shares, address receiver) external returns (address[] memory _assets, uint256[] memory _amounts);
    function redeem(
        uint256 shares,
        address receiver,
        address[] calldata assets,
        uint256[] calldata minAmountsOut
    ) external returns (uint256[] memory _amounts);
}


interface IGovernanceDeployer {
    struct GovParams {
        // Basic Parameters
        uint48 votingDelay; // {s}
        uint32 votingPeriod; // {s}
        uint256 proposalThreshold; // D18{1}
        uint256 quorumPercent; // in percent, e.g 4 for 4%
        uint256 timelockDelay; // {s}
        // Roles
        address[] guardians; // Canceller Role
    }

    function deployGovernanceWithTimelock(
        IGovernanceDeployer.GovParams calldata govParams,
        IVotes stToken
    ) external returns (address governor, address timelock);
}

struct GovRoles {
  address[] existingTradeProposers;
  address[] tradeLaunchers;
  address[] vibesOfficers;
}


interface IFolioDeployer {
  error FolioDeployer__LengthMismatch();

  event FolioDeployed(address indexed folioOwner, address indexed folio, address folioAdmin);
  event GovernedFolioDeployed(
      address indexed stToken,
      address indexed folio,
      address ownerGovernor,
      address ownerTimelock,
      address tradingGovernor,
      address tradingTimelock
  );


  function folioImplementation() external view returns (address);


  function deployFolio(
    IFolio.FolioBasicDetails calldata basicDetails,
    IFolio.FolioAdditionalDetails calldata additionalDetails,
    address owner,
    address[] memory auctionApprovers,
    address[] memory auctionLaunchers,
    address[] memory brandManagers,
    bytes32 deploymentNonce
  ) external returns (address folio, address proxyAdmin);

  function deployGovernedFolio(
    IVotes stToken,
    IFolio.FolioBasicDetails calldata basicDetails,
    IFolio.FolioAdditionalDetails calldata additionalDetails,
    IGovernanceDeployer.GovParams calldata ownerGovParams,
    IGovernanceDeployer.GovParams calldata tradingGovParams,
    GovRoles calldata govRoles,
    bytes32 deploymentNonce
  )
    external
    returns (
        address folio,
        address proxyAdmin,
        address ownerGovernor,
        address ownerTimelock,
        address tradingGovernor,
        address tradingTimelock
    );


}
// SPDX-License-Identifier: BlueOak-1.0.0
pragma solidity 0.8.17;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

struct Call {
    address to;
    bytes data;
    uint256 value;
}

struct ZapERC20Params {
    // Token to zap
    IERC20 tokenIn;
    // Total amount to zap / pull from user
    uint256 amountIn;
    
    // Weiroll code to execute to produce 'amountOut' of 'tokenOut'
    bytes32[] commands;
    bytes[] state;
    IERC20[] tokens;

    // RTokens the user requested
    uint256 amountOut;
    // RToken to issue
    IERC20 tokenOut;
}


struct ZapParams {
    // Token to zap
    address tokenIn;
    // Total amount to zap / pull from user
    uint256 amountIn;
    
    // Weiroll code to execute to produce 'amountOut' of 'tokenOut'
    bytes32[] commands;
    bytes[] state;
    IERC20[] tokens;

    // RTokens the user requested
    uint256 amountOut;
    // RToken to issue
    address tokenOut;

    address recipient;
}
// SPDX-License-Identifier: BlueOak-1.0.0
pragma solidity 0.8.17;

interface IWrappedNative {
    function deposit() external payable;
    function withdraw(uint256 amount) external;
    function balanceOf(address account) external view returns (uint256);
}
// SPDX-License-Identifier: BlueOak-1.0.0
pragma solidity 0.8.17;

abstract contract PreventTampering {
    modifier revertOnCodeHashChange() {
        bytes32 hashBefore;
        assembly {
            hashBefore := extcodehash(address())
        }
        _;
        bytes32 hashPostExecution;
        assembly {
            hashPostExecution := extcodehash(address())
        }
        require(hashPostExecution == hashBefore, "PreventTampering: Code has changed");
    }
}


contract SelfDestruct {
    function destroy() external {
        selfdestruct(payable(msg.sender));
    }
    function doNothing() external {}
}

contract TestPreventTampering is PreventTampering {
    function shouldNotRevert() external {
        SelfDestruct selfDestruct = new SelfDestruct();
        address(selfDestruct).delegatecall(abi.encodeWithSelector(selfDestruct.destroy.selector));
    }
    function shouldRevert() revertOnCodeHashChange() external {
        SelfDestruct selfDestruct = new SelfDestruct();
        address(selfDestruct).delegatecall(abi.encodeWithSelector(selfDestruct.destroy.selector));
    }
    function markedRevertOnCodeHashChangeDontRevert() revertOnCodeHashChange() external {
        SelfDestruct selfDestruct = new SelfDestruct();
        address(selfDestruct).delegatecall(abi.encodeWithSelector(selfDestruct.doNothing.selector));
    }
}
// SPDX-License-Identifier: BlueOak-1.0.0
pragma solidity 0.8.17;

import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ERC2771Context } from "@openzeppelin/contracts/metatx/ERC2771Context.sol";

import { IWrappedNative } from "./IWrappedNative.sol";
import { VM } from "./weiroll/VM.sol";
import { PreventTampering } from "./PreventTampering.sol";

import { ZapParams, ZapERC20Params } from "./IRTokenZapper.sol";
import { ZapperExecutor, DeployFolioConfig, ExecuteDeployOutput } from "./ZapperExecutor.sol";

struct ZapperOutput {
    uint256[] dust;
    uint256 amountOut;
    uint256 gasUsed;
}

contract Zapper2 is ReentrancyGuard {
    IWrappedNative internal immutable wrappedNative;
    ZapperExecutor internal immutable zapperExecutor;

    constructor(
        IWrappedNative wrappedNative_,
        ZapperExecutor executor_
    ) {
        wrappedNative = wrappedNative_;
        zapperExecutor = executor_;
    }

    receive() external payable {}

    function zap(ZapParams calldata params) external payable nonReentrant returns (ZapperOutput memory) {
        uint256 startGas = gasleft();
        return zapInner(params, balanceOf(params.tokenOut, params.recipient), startGas);
    }
    function zapDeploy(
        ZapParams calldata params,
        DeployFolioConfig calldata config,
        bytes32 nonce
    ) external payable nonReentrant returns (ZapperOutput memory out) {
        uint256 startGas = gasleft();
        pullFundsFromSender(params.tokenIn, params.amountIn, address(zapperExecutor));
        // STEP 1: Execute
        ExecuteDeployOutput memory deployOutput = zapperExecutor.executeDeploy(
            params.commands,
            params.state,
            params.tokens,
            config,
            params.recipient,
            nonce
        );
        out.amountOut = deployOutput.amountOut;
        out.dust = deployOutput.dust;

        require(out.amountOut > params.amountOut, "INSUFFICIENT_OUT");


        out.gasUsed = startGas - gasleft();
    }
    function validateTokenOut(address tokenOut) private {
        uint256 codeSizeTokenOut = 0;
        assembly {
            codeSizeTokenOut := extcodesize(tokenOut)
        }
        require(codeSizeTokenOut == 0, "RETRY");
    }

    function zapInner(ZapParams memory params, uint256 initialBalance, uint256 startGas) private returns (ZapperOutput memory out) {
        require(params.amountIn != 0, "INVALID_INPUT_AMOUNT");
        require(params.amountOut != 0, "INVALID_OUTPUT_AMOUNT");

        pullFundsFromSender(params.tokenIn, params.amountIn, address(zapperExecutor));
        // STEP 1: Execute
        out.dust = zapperExecutor.execute(
            params.commands,
            params.state,
            params.tokens
        ).dust;

        // STEP 2: Verify that the user has gotten the tokens they requested
        uint256 newBalance = balanceOf(params.tokenOut, params.recipient);
        require(newBalance > initialBalance, "INVALID_NEW_BALANCE");
        uint256 difference = newBalance - initialBalance;
        require(difference >= params.amountOut, "INSUFFICIENT_OUT");

        out.amountOut = difference;
        out.gasUsed = startGas - gasleft();
    }

    function pullFundsFromSender(
        address token,
        uint256 amount,
        address to
    ) private {
        if (token != address(0)) {
            SafeERC20.safeTransferFrom(IERC20(token), msg.sender, to, amount);
        } else {
            require(msg.value >= amount, "INSUFFICIENT_ETH");
            wrappedNative.deposit{ value: amount }();
            SafeERC20.safeTransfer(IERC20(address(wrappedNative)), to, amount);
        }   
    }


    function balanceOf(address token, address account) private view returns (uint256) {
        if (token != address(0)) {
            // Check if token address contains bytecode
            return IERC20(token).balanceOf(account);
        } else {
            return account.balance;
        }
    }


    /** Stubs for old interface  */
    function translateOldStyleZap(ZapERC20Params calldata params) private returns (ZapperOutput memory) {
        uint256 startGas = gasleft();
        ZapParams memory zapParams = ZapParams({
            tokenIn: address(params.tokenIn),
            amountIn: params.amountIn,
            commands: params.commands,
            state: params.state,
            tokens: params.tokens,
            amountOut: params.amountOut,
            tokenOut: address(params.tokenOut),
            recipient: msg.sender
        });

        return zapInner(zapParams, balanceOf(address(params.tokenOut), msg.sender), startGas);
    }

    function zapERC20(ZapERC20Params calldata params) external  nonReentrant returns (ZapperOutput memory) {
        return translateOldStyleZap(params);
    }
    function zapETH(ZapERC20Params calldata params) external payable nonReentrant returns (ZapperOutput memory) {
        return translateOldStyleZap(params);
    }
    function zapToETH(ZapERC20Params calldata params) external payable nonReentrant returns (ZapperOutput memory) {
        return translateOldStyleZap(params);
    }

}
// SPDX-License-Identifier: BlueOak-1.0.0
pragma solidity 0.8.17;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { VM } from "./weiroll/VM.sol";
import { PreventTampering } from "./PreventTampering.sol";

import { IFolio, IVotes, GovRoles, IFolioDeployer, IGovernanceDeployer } from "./IFolio.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

struct DeployFolioConfig {
  address deployer;
  IFolio.FolioBasicDetails basicDetails;
  IFolio.FolioAdditionalDetails additionalDetails;
  GovRoles govRoles;

  bool isGoverned;
  IVotes stToken;
  address owner;
  IGovernanceDeployer.GovParams ownerGovParams;
  IGovernanceDeployer.GovParams tradingGovParams;
}

struct ExecuteOutput {
  uint256[] dust;
}
struct ExecuteDeployOutput {
  uint256[] dust;
  uint256 amountOut;
}
contract ZapperExecutor is VM, PreventTampering {
  receive() external payable {}

  function add(
      uint256 a,
      uint256 b
  ) external pure returns (uint256) {
      return a + b;
  }
  function sub(
      uint256 a,
      uint256 b
  ) external pure returns (uint256) {
      return a - b;
  }
  function fpMul(
      uint256 a,
      uint256 b,
      uint256 scale
  ) external pure returns (uint256) {
      return (a * b) / scale;
  }
  function assertLarger(
      uint256 a,
      uint256 b
  ) external pure returns (bool) {
      require(a > b, "!ASSERT_GT");
      return true;
  }
  function assertEqual(
      uint256 a,
      uint256 b
  ) external pure returns (bool) {
      require(a == b, "!ASSERT_EQ");
      return true;
  }


  /** @dev Main endpoint to call
   * @param commands - Weiroll code to execute
   * @param state - Intiaial Weiroll state to use
   * @param tokens - All tokens used by the Zap in order to calculate dust
   */
  function execute(
      bytes32[] calldata commands,
      bytes[] memory state,
      IERC20[] memory tokens
  )
      revertOnCodeHashChange
      public
      payable
      returns (ExecuteOutput memory out)
  {
      _execute(commands, state);
      out.dust = new uint256[](tokens.length);
      for(uint256 i; i < tokens.length; i++) {
          out.dust[i] = tokens[i].balanceOf(address(this));
      }
  }

  function executeDeploy(
      bytes32[] calldata commands,
      bytes[] memory state,
      IERC20[] memory tokens,
      DeployFolioConfig memory config,
      address recipient,
      bytes32 nonce
  ) revertOnCodeHashChange public payable returns (ExecuteDeployOutput memory out) {
    _execute(commands, state);
    // DSTEP 2: Deploy folio
    uint256 initialShares = type(uint256).max;
    for (uint256 i = 0; i < config.basicDetails.assets.length; i++) {
        uint256 balance = IERC20(config.basicDetails.assets[i]).balanceOf(address(this));
        if (balance == 0) {
            revert('ZERO BALANCE');
        }
        uint256 quantityPrShare = config.basicDetails.amounts[i];
        if (quantityPrShare == 0) {
            revert('ZERO QUANTITY');
        }
        uint256 shares = balance * 1e18 / quantityPrShare;
        
        if (shares < initialShares) {
            initialShares = shares;
        }
        SafeERC20.safeApprove(IERC20(config.basicDetails.assets[i]), address(config.deployer), 0);
        SafeERC20.safeApprove(IERC20(config.basicDetails.assets[i]), address(config.deployer), type(uint256).max);
    }
    if (initialShares == type(uint256).max) {
        revert('NO SHARES');
    }
    for (uint256 i = 0; i < config.basicDetails.assets.length; i++) {
        config.basicDetails.amounts[i] = initialShares * config.basicDetails.amounts[i] / 1e18;
    }

    config.basicDetails.initialShares = initialShares;

    if (config.isGoverned) {
        (address folio, , , , ,) = IFolioDeployer(config.deployer).deployGovernedFolio(
            config.stToken,
            config.basicDetails,
            config.additionalDetails,
            config.ownerGovParams,
            config.tradingGovParams,
            config.govRoles,
            nonce
        );
        out.amountOut = IERC20(folio).balanceOf(address(this));
        IERC20(folio).transfer(recipient, out.amountOut);
    } else {
        (address folio, ) = IFolioDeployer(config.deployer).deployFolio(
            config.basicDetails,
            config.additionalDetails,
            config.owner,
            config.govRoles.existingTradeProposers,
            config.govRoles.tradeLaunchers,
            config.govRoles.vibesOfficers,
            nonce
        );
        out.amountOut = IERC20(folio).balanceOf(address(this));
        IERC20(folio).transfer(recipient, out.amountOut);
    }
    out.dust = new uint256[](tokens.length);
      for(uint256 i; i < tokens.length; i++) {
          out.dust[i] = tokens[i].balanceOf(address(this));
          tokens[i].transfer(recipient, out.dust[i]);
      }
  }

  /** @dev Workaround for weiroll not supporting a way to make untyped calls.
    * @param to - Address to call
    * @param value - Amount of ETH to send
    * @param data - Data to send
   */
  function rawCall(
      address to,
      uint256 value,
      bytes calldata data
  ) external returns (bool success, bytes memory out) {
      require(msg.sender == address(this), "ZapperExecutor: Only callable by Zapper");
      (success, out) = to.call{value: value}(data);
  }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

library CommandBuilder {

    uint256 constant IDX_VARIABLE_LENGTH = 0x80;
    uint256 constant IDX_VALUE_MASK = 0x7f;
    uint256 constant IDX_END_OF_ARGS = 0xff;
    uint256 constant IDX_USE_STATE = 0xfe;

    function buildInputs(
        bytes[] memory state,
        bytes4 selector,
        bytes32 indices
    ) internal view returns (bytes memory ret) {
        uint256 count; // Number of bytes in whole ABI encoded message
        uint256 free; // Pointer to first free byte in tail part of message
        bytes memory stateData; // Optionally encode the current state if the call requires it

        uint256 idx;

        // Determine the length of the encoded data
        for (uint256 i; i < 32;) {
            idx = uint8(indices[i]);
            if (idx == IDX_END_OF_ARGS) break;

            if (idx & IDX_VARIABLE_LENGTH != 0) {
                if (idx == IDX_USE_STATE) {
                    if (stateData.length == 0) {
                        stateData = abi.encode(state);
                    }
                    count += stateData.length;
                } else {
                    // Add the size of the value, rounded up to the next word boundary, plus space for pointer and length
                    uint256 arglen = state[idx & IDX_VALUE_MASK].length;
                    require(
                        arglen % 32 == 0,
                        "Dynamic state variables must be a multiple of 32 bytes"
                    );
                    count += arglen + 32;
                }
            } else {
                require(
                    state[idx & IDX_VALUE_MASK].length == 32,
                    "Static state variables must be 32 bytes"
                );
                count += 32;
            }
            unchecked{free += 32;}
            unchecked{++i;}
        }

        // Encode it
        ret = new bytes(count + 4);
        assembly {
            mstore(add(ret, 32), selector)
        }
        count = 0;
        for (uint256 i; i < 32;) {
            idx = uint8(indices[i]);
            if (idx == IDX_END_OF_ARGS) break;

            if (idx & IDX_VARIABLE_LENGTH != 0) {
                if (idx == IDX_USE_STATE) {
                    assembly {
                        mstore(add(add(ret, 36), count), free)
                    }
                    memcpy(stateData, 32, ret, free + 4, stateData.length - 32);
                    free += stateData.length - 32;
                } else {
                    uint256 arglen = state[idx & IDX_VALUE_MASK].length;

                    // Variable length data; put a pointer in the slot and write the data at the end
                    assembly {
                        mstore(add(add(ret, 36), count), free)
                    }
                    memcpy(
                        state[idx & IDX_VALUE_MASK],
                        0,
                        ret,
                        free + 4,
                        arglen
                    );
                    free += arglen;
                }
            } else {
                // Fixed length data; write it directly
                bytes memory statevar = state[idx & IDX_VALUE_MASK];
                assembly {
                    mstore(add(add(ret, 36), count), mload(add(statevar, 32)))
                }
            }
            unchecked{count += 32;}
            unchecked{++i;}
        }
    }

    function writeOutputs(
        bytes[] memory state,
        bytes1 index,
        bytes memory output
    ) internal view returns (bytes[] memory) {
        uint256 idx = uint8(index);
        if (idx == IDX_END_OF_ARGS) return state;

        if (idx & IDX_VARIABLE_LENGTH != 0) {
            if (idx == IDX_USE_STATE) {
                state = abi.decode(output, (bytes[]));
            } else {
                // Check the first field is 0x20 (because we have only a single return value)
                uint256 argptr;
                assembly {
                    argptr := mload(add(output, 32))
                }
                require(
                    argptr == 32,
                    "Only one return value permitted (variable)"
                );

                assembly {
                    // Overwrite the first word of the return data with the length - 32
                    mstore(add(output, 32), sub(mload(output), 32))
                    // Insert a pointer to the return data, starting at the second word, into state
                    mstore(
                        add(add(state, 32), mul(and(idx, IDX_VALUE_MASK), 32)),
                        add(output, 32)
                    )
                }
            }
        } else {
            require(output.length >= 32, "Return at least 32 bytes");
            // Single word
            // require(
            //     output.length == 32,
            //     "Only one return value permitted (static)"
            // );

            // There are rare instances of contracts whoes ABI indicate a single word return returning more than 1 word
            // returndata buffers containing a single word of data.
            if (output.length > 32) {
                // Truncate returndata to proper size
                bytes memory newOutput = new bytes(32);
                memcpy(output, 0, newOutput, 0, output.length);
                output = newOutput;
            }

            state[idx & IDX_VALUE_MASK] = output;
        }

        return state;
    }

    function writeTuple(
        bytes[] memory state,
        bytes1 index,
        bytes memory output
    ) internal view {
        uint256 idx = uint256(uint8(index));
        if (idx == IDX_END_OF_ARGS) return;

        bytes memory entry = state[idx] = new bytes(output.length + 32);
        memcpy(output, 0, entry, 32, output.length);
        assembly {
            let l := mload(output)
            mstore(add(entry, 32), l)
        }
    }

    function memcpy(
        bytes memory src,
        uint256 srcidx,
        bytes memory dest,
        uint256 destidx,
        uint256 len
    ) internal view {
        assembly {
            pop(
                staticcall(
                    gas(),
                    4,
                    add(add(src, 32), srcidx),
                    len,
                    add(add(dest, 32), destidx),
                    len
                )
            )
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "./CommandBuilder.sol";


abstract contract VM {
    using CommandBuilder for bytes[];

    uint256 constant FLAG_CT_DELEGATECALL = 0x00;
    uint256 constant FLAG_CT_CALL = 0x01;
    uint256 constant FLAG_CT_STATICCALL = 0x02;
    uint256 constant FLAG_CT_VALUECALL = 0x03;
    uint256 constant FLAG_CT_MASK = 0x03;
    uint256 constant FLAG_EXTENDED_COMMAND = 0x80;
    uint256 constant FLAG_TUPLE_RETURN = 0x40;

    uint256 constant SHORT_COMMAND_FILL = 0x000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    address immutable self;

    error ExecutionFailed(
        uint256 command_index,
        address target,
        string message
    );

    constructor() {
        self = address(this);
    }

    // function callExtension(
    //     bytes memory data
    // ) virtual internal returns (bool success, bytes memory outdata);

    function _execute(bytes32[] calldata commands, bytes[] memory state)
      internal returns (bytes[] memory)
    {
        bytes32 command;
        uint256 flags;
        bytes32 indices;

        bool success;
        bytes memory outdata;

        uint256 commandsLength = commands.length;
        for (uint256 i; i < commandsLength;) {
            command = commands[i];
            flags = uint256(uint8(bytes1(command << 32)));

            if (flags & FLAG_EXTENDED_COMMAND != 0) {
                indices = commands[i++];
            } else {
                indices = bytes32(uint256(command << 40) | SHORT_COMMAND_FILL);
            }

            if (flags & FLAG_CT_MASK == FLAG_CT_DELEGATECALL) {
                (success, outdata) = address(uint160(uint256(command))).delegatecall( // target
                    // inputs
                    state.buildInputs(
                        //selector
                        bytes4(command),
                        indices
                    )
                );
            } else if (flags & FLAG_CT_MASK == FLAG_CT_CALL) {
                    (success, outdata) = address(uint160(uint256(command))).call( // target
                        // inputs
                        state.buildInputs(
                            //selector
                            bytes4(command),
                            indices
                        )
                    );
            } else if (flags & FLAG_CT_MASK == FLAG_CT_STATICCALL) {
                (success, outdata) = address(uint160(uint256(command))).staticcall( // target
                    // inputs
                    state.buildInputs(
                        //selector
                        bytes4(command),
                        indices
                    )
                );
            } else if (flags & FLAG_CT_MASK == FLAG_CT_VALUECALL) {
                uint256 calleth;
                bytes memory v = state[uint8(bytes1(indices))];
                require(v.length == 32, "_execute: value call has no value indicated.");
                assembly {
                    calleth := mload(add(v, 0x20))
                }
                (success, outdata) = address(uint160(uint256(command))).call{ // target
                    value: calleth
                }(
                    // inputs
                    state.buildInputs(
                        //selector
                        bytes4(command),
                        bytes32(uint256(indices << 8) | CommandBuilder.IDX_END_OF_ARGS)
                    )
                );
            } else {
                revert("Invalid calltype");
            }

            if (!success) {
                if (outdata.length > 0) {
                    assembly {
                        outdata := add(outdata, 68)
                    }
                }
                revert ExecutionFailed({
                    command_index: i,
                    target: address(uint160(uint256(command))),
                    message: string(outdata)
                });
            }

            if (flags & FLAG_TUPLE_RETURN != 0) {
                state.writeTuple(bytes1(command << 88), outdata);
            } else {
                state = state.writeOutputs(bytes1(command << 88), outdata);
            }
            unchecked{++i;}
        }
        return state;
    }
}