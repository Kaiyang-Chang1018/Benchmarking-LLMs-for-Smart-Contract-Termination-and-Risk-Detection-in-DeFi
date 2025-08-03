// SPDX-License-Identifier: MIT

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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
// SPDX-License-Identifier: MIT

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
     * by making the `nonReentrant` function external, and make it call a
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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
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
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

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
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

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
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}
// SPDX-License-Identifier: MIT

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
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC721Receiver.sol";

/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721Holder is IERC721Receiver {
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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

pragma solidity 0.8.18;

/**
 * @title RolloverErrors
 * @author Non-Fungible Technologies, Inc.
 *
 * This file contains all custom errors for V2 -> V3 rollover contracts. All errors are
 * prefixed by "R_" for Rollover. Errors are located in one place to make it possible to
 * holistically look at all V2 -> V3 rollover failure cases.
 */

// ================================== V2 To V3 Rollover ====================================

/**
 * @notice The flash loan callback caller is not recognized. The caller must be the flash
 *         loan provider.
 *
 * @param caller                  The address of the caller.
 * @param lendingPool             Expected address of the flash loan provider.
 */
error R_UnknownCaller(address caller, address lendingPool);

/**
 * @notice The balance of the borrower is insufficient to repay the difference between
 *         the V2 loan and the V3 loan principal minus fees.
 *
 * @param borrower                The address of the borrower.
 * @param amount                  The difference amount.
 * @param balance                 Current balance of the borrower.
 */
error R_InsufficientFunds(address borrower, uint256 amount, uint256 balance);

/**
 * @notice The allowance of the borrower to the V2 -> V3 rollover contract is insufficient
 *          to repay the difference between the V2 loan and the V3 loan principal minus fees.
 *
 * @param borrower                The address of the borrower.
 * @param amount                  The difference amount.
 * @param allowance               Current allowance of the borrower.
 */
error R_InsufficientAllowance(address borrower, uint256 amount, uint256 allowance);

/**
 * @notice An accounting check to verify that either the leftover V3 loan principal is
 *         zero or the amount needed from the borrower to cover any difference is zero.
 *         Either there is leftover principal that needs to be sent to the borrower, or
 *         the borrower needs to send funds to cover the difference between the V2 repayment
 *         amount and the new V3 loan principal minus any fees.
 *
 * @param leftoverPrincipal       The leftover principal from the V3 loan.
 * @param needFromBorrower        The amount needed from the borrower to cover the difference.
 */
error R_FundsConflict(uint256 leftoverPrincipal, uint256 needFromBorrower);

/**
 * @notice After repaying the V2 loan, the V2 -> V3 rollover contract must be the owner of
 *         the collateral token.
 *
 * @param owner                   The owner of the collateral token.
 */
error R_NotCollateralOwner(address owner);

/**
 * @notice Only the holder of the borrowerNote can rollover their loan.
 *
 * @param caller                  The address of the caller.
 * @param borrower                Holder of the borrower notes address
 */
error R_CallerNotBorrower(address caller, address borrower);

/**
 * @notice The V2 and V3 payable currency tokens must be the same so that the flash loan can
 *         be repaid.
 *
 * @param v2Currency              The V2 payable currency address.
 * @param v3Currency              The V3 payable currency address.
 */
error R_CurrencyMismatch(address v2Currency, address v3Currency);

/**
 * @notice The V2 and V3 collateral tokens must be the same.
 *
 * @param v2Collateral            The V2 collateral token address.
 * @param v3Collateral            The V3 collateral token address.
 */
error R_CollateralMismatch(address v2Collateral, address v3Collateral);

/**
 * @notice The V2 and V3 collateral token IDs must be the same.
 *
 * @param v2CollateralId          The V2 collateral token ID.
 * @param v3CollateralId          The V3 collateral token ID.
 */
error R_CollateralIdMismatch(uint256 v2CollateralId, uint256 v3CollateralId);

/**
 * @notice The rollover contract does not hold a balance for the token specified to flush.
 */
error R_NoTokenBalance();

/**
 * @notice Contract is paused, rollover operations are blocked.
 */
error R_Paused();

/**
 * @notice The rollover contract is already in the specified pause state.
 */
error R_StateAlreadySet();

/**
 * @notice Cannot pass the zero address as an argument.
 *
 * @param name                    The name of the contract.
 */
error R_ZeroAddress(string name);

/**
 * @notice The borrower address saved in the rollover contract is not the same as the
 *         borrower address provided in the flash loan operation data. The initiator of
 *         the flash loan must be the rollover contract.
 *
 * @param providedBorrower        Borrower address passed in the flash loan operation data.
 * @param cachedBorrower          Borrower address saved in the rollover contract.
 */
error R_UnknownBorrower(address providedBorrower, address cachedBorrower);

/**
 * @notice The borrower state must be address(0) to initiate a rollover sequence.
 *
 * @param borrower                The borrower address.
 */
error R_BorrowerNotReset(address borrower);
// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IFlashLoanRecipient {
    /**
     * @dev When `flashLoan` is called on the Vault, it invokes the `receiveFlashLoan` hook on the recipient.
     *
     * At the time of the call, the Vault will have transferred `amounts` for `tokens` to the recipient. Before this
     * call returns, the recipient must have transferred `amounts` plus `feeAmounts` for each token back to the
     * Vault, or else the entire flash loan will revert.
     *
     * `userData` is the same value passed in the `IVault.flashLoan` call.
     */
    function receiveFlashLoan(
        IERC20[] memory tokens,
        uint256[] memory amounts,
        uint256[] memory feeAmounts,
        bytes memory userData
    ) external;
}

interface IVault {
    /**
     * @dev copied from @balancer-labs/v2-vault/contracts/interfaces/IVault.sol,
     *      which uses an incompatible compiler version. Only necessary selectors
     *      (flashLoan) included.
     */
    function flashLoan(
        IFlashLoanRecipient recipient,
        IERC20[] memory tokens,
        uint256[] memory amounts,
        bytes memory userData
    ) external;
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

interface IFeeController {
    // ================ Structs ================

    struct FeesOrigination {
        uint16 borrowerOriginationFee;
        uint16 lenderOriginationFee;
        uint16 lenderDefaultFee;
        uint16 lenderInterestFee;
        uint16 lenderPrincipalFee;
    }

    struct FeesRollover {
        uint16 borrowerRolloverFee;
        uint16 lenderRolloverFee;
    }

    // ================ Events =================

    event SetLendingFee(bytes32 indexed id, uint16 fee);

    event SetVaultMintFee(uint64 fee);

    // ================ Getter/Setter =================

    function setLendingFee(bytes32 id, uint16 fee) external;

    function setVaultMintFee(uint64 fee) external;

    function getLendingFee(bytes32 id) external view returns (uint16);

    function getVaultMintFee() external view returns (uint64);

    function getFeesOrigination() external view returns (FeesOrigination memory);

    function getFeesRollover() external view returns (FeesRollover memory);

    function getMaxLendingFee(bytes32 id) external view returns (uint16);

    function getMaxVaultMintFee() external view returns (uint64);
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import "../libraries/LoanLibrary.sol";
import "./IPromissoryNote.sol";

interface ILoanCore {

    // ================ Data Types =================

    struct AffiliateSplit {
        address affiliate;
        uint96 splitBps;
    }

    struct NoteReceipt {
        address token;
        uint256 amount;
    }

    // ================ Events =================

    event LoanStarted(uint256 loanId, address lender, address borrower);
    event LoanRepaid(uint256 loanId);
    event ForceRepay(uint256 loanId);
    event LoanRolledOver(uint256 oldLoanId, uint256 newLoanId);
    event LoanClaimed(uint256 loanId);
    event NoteRedeemed(address indexed token, address indexed caller, address indexed to, uint256 tokenId, uint256 amount);
    event NonceUsed(address indexed user, uint160 nonce);

    event FeesWithdrawn(address indexed token, address indexed caller, address indexed to, uint256 amount);
    event AffiliateSet(bytes32 indexed code, address indexed affiliate, uint96 splitBps);

    // ============== Lifecycle Operations ==============

    function startLoan(
        address lender,
        address borrower,
        LoanLibrary.LoanTerms calldata terms,
        uint256 _amountFromLender,
        uint256 _amountToBorrower,
        LoanLibrary.FeeSnapshot calldata feeSnapshot
    ) external returns (uint256 loanId);

    function repay(
        uint256 loanId,
        address payer,
        uint256 _amountFromPayer,
        uint256 _amountToLender
    ) external;

    function forceRepay(
        uint256 loanId,
        address payer,
        uint256 _amountFromPayer,
        uint256 _amountToLender
    ) external;

    function claim(
        uint256 loanId,
        uint256 _amountFromLender
    ) external;

    function redeemNote(
        uint256 loanId,
        uint256 _amountFromLender,
        address to
    ) external;

    function rollover(
        uint256 oldLoanId,
        address borrower,
        address lender,
        LoanLibrary.LoanTerms calldata terms,
        uint256 _settledAmount,
        uint256 _amountToOldLender,
        uint256 _amountToLender,
        uint256 _amountToBorrower
    ) external returns (uint256 newLoanId);

    // ============== Nonce Management ==============

    function consumeNonce(address user, uint160 nonce) external;

    function cancelNonce(uint160 nonce) external;

    // ============== Fee Management ==============

    function withdraw(address token, uint256 amount, address to) external;

    function withdrawProtocolFees(address token, address to) external;

    // ============== Admin Operations ==============

    function setAffiliateSplits(bytes32[] calldata codes, AffiliateSplit[] calldata splits) external;

    // ============== View Functions ==============

    function getLoan(uint256 loanId) external view returns (LoanLibrary.LoanData calldata loanData);

    function getNoteReceipt(uint256 loanId) external view returns (address token, uint256 amount);

    function isNonceUsed(address user, uint160 nonce) external view returns (bool);

    function borrowerNote() external view returns (IPromissoryNote);

    function lenderNote() external view returns (IPromissoryNote);

}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import "./ILoanCore.sol";

interface IMigration {
    struct OperationData {
        uint256 loanId;
        address borrower;
        LoanLibrary.LoanTerms newLoanTerms;
        address lender;
        uint160 nonce;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    function migrateLoan(
        uint256 loanId,
        LoanLibrary.LoanTerms calldata newLoanTerms,
        address lender,
        uint160 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import "./ILoanCore.sol";
import "./IOriginationController.sol";
import "./IFeeController.sol";

import "../external/interfaces/IFlashLoanRecipient.sol";

import "../v2-migration/v2-contracts/v2-interfaces/ILoanCoreV2.sol";
import "../v2-migration/v2-contracts/v2-interfaces/IRepaymentControllerV2.sol";

interface IMigrationBase is IFlashLoanRecipient {
    event PausedStateChanged(bool isPaused);

    function flushToken(IERC20 token, address to) external;

    function pause(bool _pause) external;
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

interface INFTWithDescriptor {
    // ============= Events ==============

    event SetDescriptor(address indexed caller, address indexed descriptor);

    // ================ Resource Metadata ================

    function tokenURI(uint256 tokenId) external view returns (string memory);

    function setDescriptor(address descriptor) external;
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import "../libraries/LoanLibrary.sol";

interface IOriginationController {
    // ================ Data Types =============

    struct Currency {
        bool isAllowed;
        uint256 minPrincipal;
    }

    enum Side {
        BORROW,
        LEND
    }

    struct Signature {
        uint8 v;
        bytes32 r;
        bytes32 s;
        bytes extraData;
    }

    struct RolloverAmounts {
        uint256 needFromBorrower;
        uint256 leftoverPrincipal;
        uint256 amountFromLender;
        uint256 amountToOldLender;
        uint256 amountToLender;
        uint256 amountToBorrower;
    }

    // ================ Events =================

    event Approval(address indexed owner, address indexed signer, bool isApproved);
    event SetAllowedVerifier(address indexed verifier, bool isAllowed);
    event SetAllowedCurrency(address indexed currency, bool isAllowed, uint256 minPrincipal);
    event SetAllowedCollateral(address indexed collateral, bool isAllowed);

    // ============== Origination Operations ==============

    function initializeLoan(
        LoanLibrary.LoanTerms calldata loanTerms,
        address borrower,
        address lender,
        Signature calldata sig,
        uint160 nonce
    ) external returns (uint256 loanId);

    function initializeLoanWithItems(
        LoanLibrary.LoanTerms calldata loanTerms,
        address borrower,
        address lender,
        Signature calldata sig,
        uint160 nonce,
        LoanLibrary.Predicate[] calldata itemPredicates
    ) external returns (uint256 loanId);

    function initializeLoanWithCollateralPermit(
        LoanLibrary.LoanTerms calldata loanTerms,
        address borrower,
        address lender,
        Signature calldata sig,
        uint160 nonce,
        Signature calldata collateralSig,
        uint256 permitDeadline
    ) external returns (uint256 loanId);

    function initializeLoanWithCollateralPermitAndItems(
        LoanLibrary.LoanTerms calldata loanTerms,
        address borrower,
        address lender,
        Signature calldata sig,
        uint160 nonce,
        Signature calldata collateralSig,
        uint256 permitDeadline,
        LoanLibrary.Predicate[] calldata itemPredicates
    ) external returns (uint256 loanId);

    function rolloverLoan(
        uint256 oldLoanId,
        LoanLibrary.LoanTerms calldata loanTerms,
        address lender,
        Signature calldata sig,
        uint160 nonce
    ) external returns (uint256 newLoanId);

    function rolloverLoanWithItems(
        uint256 oldLoanId,
        LoanLibrary.LoanTerms calldata loanTerms,
        address lender,
        Signature calldata sig,
        uint160 nonce,
        LoanLibrary.Predicate[] calldata itemPredicates
    ) external returns (uint256 newLoanId);

    // ================ Permission Management =================

    function approve(address signer, bool approved) external;

    function isApproved(address owner, address signer) external returns (bool);

    function isSelfOrApproved(address target, address signer) external returns (bool);

    function isApprovedForContract(
        address target,
        Signature calldata sig,
        bytes32 sighash
    ) external returns (bool);

    // ============== Signature Verification ==============

    function recoverTokenSignature(
        LoanLibrary.LoanTerms calldata loanTerms,
        Signature calldata sig,
        uint160 nonce,
        Side side
    ) external view returns (bytes32 sighash, address signer);

    function recoverItemsSignature(
        LoanLibrary.LoanTerms calldata loanTerms,
        Signature calldata sig,
        uint160 nonce,
        Side side,
        bytes32 itemsHash
    ) external view returns (bytes32 sighash, address signer);

    // ============== Admin Operations ==============

    function setAllowedPayableCurrencies(address[] memory _tokenAddress, Currency[] calldata currencyData) external;

    function setAllowedCollateralAddresses(address[] memory _tokenAddress, bool[] calldata isAllowed) external;

    function setAllowedVerifiers(address[] calldata verifiers, bool[] calldata isAllowed) external;

    function isAllowedCurrency(address token) external view returns (bool);

    function isAllowedCollateral(address token) external view returns (bool);

    function isAllowedVerifier(address verifier) external view returns (bool);
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

import "./INFTWithDescriptor.sol";

interface IPromissoryNote is INFTWithDescriptor, IERC721Enumerable {
    // ============== Token Operations ==============

    function mint(address to, uint256 loanId) external returns (uint256);

    function burn(uint256 tokenId) external;

    // ============== Initializer ==============

    function initialize(address loanCore) external;
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

/**
 * @title FeeLookups
 * @author Non-Fungible Technologies, Inc.
 *
 * Enumerates unique identifiers for fee identifiers
 * that the lending protocol uses.
 */
abstract contract FeeLookups {
    /// @dev Origination fees: amount in bps, payable in loan token
    bytes32 public constant FL_01 = keccak256("BORROWER_ORIGINATION_FEE");
    bytes32 public constant FL_02 = keccak256("LENDER_ORIGINATION_FEE");

    /// @dev Rollover fees: amount in bps, payable in loan token
    bytes32 public constant FL_03 = keccak256("BORROWER_ROLLOVER_FEE");
    bytes32 public constant FL_04 = keccak256("LENDER_ROLLOVER_FEE");

    /// @dev Loan closure fees: amount in bps, payable in loan token
    bytes32 public constant FL_05 = keccak256("LENDER_DEFAULT_FEE");
    bytes32 public constant FL_06 = keccak256("LENDER_INTEREST_FEE");
    bytes32 public constant FL_07 = keccak256("LENDER_PRINCIPAL_FEE");
    bytes32 public constant FL_08 = keccak256("LENDER_REDEEM_FEE");
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

/**
 * @title LoanLibrary
 * @author Non-Fungible Technologies, Inc.
 *
 * Contains all data types used across Arcade lending contracts.
 */
library LoanLibrary {
    /**
     * @dev Enum describing the current state of a loan.
     * State change flow:
     * Created -> Active -> Repaid
     *                   -> Defaulted
     */
    enum LoanState {
        // We need a default that is not 'Created' - this is the zero value
        DUMMY_DO_NOT_USE,
        // The loan has been initialized, funds have been delivered to the borrower and the collateral is held.
        Active,
        // The loan has been repaid, and the collateral has been returned to the borrower. This is a terminal state.
        Repaid,
        // The loan was delinquent and collateral claimed by the lender. This is a terminal state.
        Defaulted
    }

    /**
     * @dev The raw terms of a loan.
     */
    struct LoanTerms {
        // Interest expressed as a rate, unlike V1 gross value.
        // Input conversion: 0.01% = (1 * 10**18) ,  10.00% = (1000 * 10**18)
        // This represents the rate over the lifetime of the loan, not APR.
        // 0.01% is the minimum interest rate allowed by the protocol.
        uint256 proratedInterestRate;
        /// @dev Full-slot variables
        // The amount of principal in terms of the payableCurrency.
        uint256 principal;
        // The token ID of the address holding the collateral.
        /// @dev Can be an AssetVault, or the NFT contract for unbundled collateral
        address collateralAddress;
        /// @dev Packed variables
        // The number of seconds representing relative due date of the loan.
        /// @dev Max is 94,608,000, fits in 96 bits
        uint96 durationSecs;
        // The token ID of the collateral.
        uint256 collateralId;
        // The payable currency for the loan principal and interest.
        address payableCurrency;
        // Timestamp for when signature for terms expires
        uint96 deadline;
        // Affiliate code used to start the loan.
        bytes32 affiliateCode;
    }

    /**
     * @dev Modification of loan terms, used for signing only.
     *      Instead of a collateralId, a list of predicates
     *      is defined by 'bytes' in items.
     */
    struct LoanTermsWithItems {
        // Interest expressed as a rate, unlike V1 gross value.
        // Input conversion: 0.01% = (1 * 10**18) ,  10.00% = (1000 * 10**18)
        // This represents the rate over the lifetime of the loan, not APR.
        // 0.01% is the minimum interest rate allowed by the protocol.
        uint256 proratedInterestRate;
        /// @dev Full-slot variables
        // The amount of principal in terms of the payableCurrency.
        uint256 principal;
        // The tokenID of the address holding the collateral
        address collateralAddress;
        /// @dev Packed variables
        // The number of seconds representing relative due date of the loan.
        /// @dev Max is 94,608,000, fits in 96 bits
        uint96 durationSecs;
        // An encoded list of predicates, along with their verifiers.
        bytes items;
        // The payable currency for the loan principal and interest.
        address payableCurrency;
        // Timestamp for when signature for terms expires
        uint96 deadline;
        // Affiliate code used to start the loan.
        bytes32 affiliateCode;
    }

    /**
     * @dev Predicate for item-based verifications
     */
    struct Predicate {
        // The encoded predicate, to decoded and parsed by the verifier contract.
        bytes data;
        // The verifier contract.
        address verifier;
    }

    /**
     * @dev Snapshot of lending fees at the time of loan creation.
     */
    struct FeeSnapshot {
        // The fee taken when lender claims defaulted collateral.
        uint16 lenderDefaultFee;
        // The fee taken from the borrower's interest repayment.
        uint16 lenderInterestFee;
        // The fee taken from the borrower's principal repayment.
        uint16 lenderPrincipalFee;
    }

    /**
     * @dev The data of a loan. This is stored once the loan is Active
     */
    struct LoanData {
        /// @dev Packed variables
        // The current state of the loan.
        LoanState state;
        // Start date of the loan, using block.timestamp.
        uint160 startDate;
        /// @dev Full-slot variables
        // The raw terms of the loan.
        LoanTerms terms;
        // Record of lending fees at the time of loan creation.
        FeeSnapshot feeSnapshot;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import "./V2ToV3RolloverBase.sol";

import "../interfaces/IMigration.sol";

import "../libraries/FeeLookups.sol";

import {
    R_UnknownCaller,
    R_UnknownBorrower,
    R_InsufficientFunds,
    R_InsufficientAllowance,
    R_Paused,
    R_ZeroAddress
} from "../errors/RolloverErrors.sol";

/**
 * @title V2ToV3Rollover
 * @author Non-Fungible Technologies, Inc.
 *
 * This contract is used to rollover a loan from the legacy V2 lending protocol to the new
 * V3 lending protocol. The rollover mechanism takes out a flash loan for the principal +
 * interest of the old loan from Balancer pool, repays the V2 loan, and starts a new loan on V3.
 * This migration contract can only used with specific loan terms signed by a lender not from a
 * collection wide offer. To perform a rollover with items, use V2ToV3RolloverWithItems contract.
 *
 * It is required that the V2 protocol has zero fees enabled. This contract only works with
 * ERC721 collateral.
 */
contract V2ToV3Rollover is IMigration, V2ToV3RolloverBase, FeeLookups {
    using SafeERC20 for IERC20;

    constructor(IVault _vault, OperationContracts memory _opContracts) V2ToV3RolloverBase(_vault, _opContracts) {}

    /**
     * @notice Rollover a loan from V2 to V3. Validates new loan terms against the old terms.
     *         Takes out Flash Loan for principal + interest, repays old loan, and starts new
     *         loan on V3.
     *
     * @param loanId                 The ID of the loan to be rolled over.
     * @param newLoanTerms           The terms of the new loan.
     * @param lender                 The address of the lender.
     * @param nonce                  The nonce of the new loan.
     * @param v                      The v value of signature for new loan.
     * @param r                      The r value of signature for new loan.
     * @param s                      The s value of signature for new loan.
     */
    function migrateLoan(
        uint256 loanId,
        LoanLibrary.LoanTerms calldata newLoanTerms,
        address lender,
        uint160 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override whenBorrowerReset {
        if (paused) revert R_Paused();

        LoanLibraryV2.LoanTerms memory loanTerms = loanCoreV2.getLoan(loanId).terms;

        (address _borrower) = _validateRollover(
            loanTerms,
            newLoanTerms,
            loanId // same as borrowerNoteId
        );

        // cache borrower address for flash loan callback
        borrower = _borrower;

        IERC20[] memory assets = new IERC20[](1);
        assets[0] = IERC20(loanTerms.payableCurrency);

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = repaymentControllerV2.getFullInterestAmount(loanTerms.principal, loanTerms.interestRate);

        bytes memory params = abi.encode(
            OperationData(
                {
                    loanId: loanId,
                    borrower: _borrower,
                    newLoanTerms: newLoanTerms,
                    lender: lender,
                    nonce: nonce,
                    v: v,
                    r: r,
                    s: s
                }
            )
        );

        // Flash loan based on principal + interest
        VAULT.flashLoan(this, assets, amounts, params);
    }

    /**
     * @notice Callback function for flash loan.
     *
     * @dev The caller of this function must be the lending pool.
     *
     * @param assets                 The ERC20 address that was borrowed in Flash Loan.
     * @param amounts                The amount that was borrowed in Flash Loan.
     * @param feeAmounts             The fees that are due to the lending pool.
     * @param params                 The data to be executed after receiving Flash Loan.
     */
    function receiveFlashLoan(
        IERC20[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata feeAmounts,
        bytes calldata params
    ) external nonReentrant {
        if (msg.sender != address(VAULT)) revert R_UnknownCaller(msg.sender, address(VAULT));

        OperationData memory opData = abi.decode(params, (OperationData));

        // verify this contract started the flash loan
        if (opData.borrower != borrower) revert R_UnknownBorrower(opData.borrower, borrower);
        // borrower must be set
        if (borrower == address(0)) revert R_ZeroAddress("borrower");

        _executeOperation(assets, amounts, feeAmounts, opData);
    }

    /**
     * @notice Executes repayment of old loan and initialization of new loan. Any funds
     *         that are not covered by closing out the old loan must be covered by the borrower.
     *
     * @param assets                 The ERC20 that was borrowed in Flash Loan.
     * @param amounts                The amount that was borrowed in Flash Loan.
     * @param premiums               The fees that are due back to the lending pool.
     * @param opData                 The data to be executed after receiving Flash Loan.
     */
    function _executeOperation(
        IERC20[] calldata assets,
        uint256[] calldata amounts,
        uint256[] memory premiums,
        OperationData memory opData
    ) internal {
        // Get loan details
        LoanLibraryV2.LoanData memory loanData = loanCoreV2.getLoan(opData.loanId);

        // Do accounting to figure out amount each party needs to receive
        (uint256 flashAmountDue, uint256 needFromBorrower, uint256 leftoverPrincipal) = _ensureFunds(
            amounts[0], // principal + interest
            premiums[0], // flash loan fee
            uint256(feeControllerV3.getLendingFee(FL_01)), // borrower origination fee
            opData.newLoanTerms.principal // new loan terms principal
        );

        IERC20 asset = assets[0];

        if (needFromBorrower > 0) {
            if (asset.balanceOf(opData.borrower) < needFromBorrower) {
                revert R_InsufficientFunds(opData.borrower, needFromBorrower, asset.balanceOf(opData.borrower));
            }
            if (asset.allowance(opData.borrower, address(this)) < needFromBorrower) {
                revert R_InsufficientAllowance(
                    opData.borrower,
                    needFromBorrower,
                    asset.allowance(opData.borrower, address(this))
                );
            }
        }

        _repayLoan(loanData, opData.loanId, opData.borrower);

        {
            uint256 newLoanId = _initializeNewLoan(
                opData.borrower,
                opData.lender,
                opData
            );

            emit V2V3Rollover(
                opData.lender,
                opData.borrower,
                loanData.terms.collateralId,
                newLoanId
            );
        }

        if (leftoverPrincipal > 0) {
            asset.safeTransfer(opData.borrower, leftoverPrincipal);
        } else if (needFromBorrower > 0) {
            asset.safeTransferFrom(opData.borrower, address(this), needFromBorrower);
        }

        // Make flash loan repayment
        // Balancer requires a transfer back the vault
        asset.safeTransfer(address(VAULT), flashAmountDue);
    }

    /**
     * @notice Helper function to initialize the new loan. Approves the V3 Loan Core contract
     *         to take the collateral, then starts the new loan. Once the new loan is started,
     *         the borrowerNote is sent to the borrower.
     *
     * @param opDataBorrower           The address of the borrower from the opData.
     * @param lender                   The address of the new lender.
     * @param opData                   The data used to initiate new V3 loan.
     *
     * @return newLoanId               V3 loanId for the new loan that is started.
     */
    function _initializeNewLoan(
        address opDataBorrower,
        address lender,
        OperationData memory opData
    ) internal returns (uint256) {
        uint256 collateralId = opData.newLoanTerms.collateralId;

        // approve targetLoanCore to take collateral
        IERC721(opData.newLoanTerms.collateralAddress).approve(address(loanCoreV3), collateralId);

        // start new loan
        // stand in for borrower to meet OriginationController's requirements
        uint256 newLoanId = originationControllerV3.initializeLoan(
            opData.newLoanTerms,
            address(this),
            lender,
            IOriginationController.Signature({
                v: opData.v,
                r: opData.r,
                s: opData.s,
                extraData: "0x"
            }),
            opData.nonce
        );

        // send the V3 borrowerNote to the caller of the rollover function
        borrowerNoteV3.safeTransferFrom(address(this), opDataBorrower, newLoanId);

        return newLoanId;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "../interfaces/IMigrationBase.sol";

import {
    R_FundsConflict,
    R_NotCollateralOwner,
    R_CallerNotBorrower,
    R_BorrowerNotReset,
    R_CurrencyMismatch,
    R_CollateralMismatch,
    R_CollateralIdMismatch,
    R_NoTokenBalance,
    R_StateAlreadySet,
    R_ZeroAddress
} from "../errors/RolloverErrors.sol";

/**
 * @title V2ToV3RolloverBase
 * @author Non-Fungible Technologies, Inc.
 *
 * This contract holds the common logic for the V2ToV3Rollover and V2ToV3RolloverWithItems contracts.
 */
abstract contract V2ToV3RolloverBase is IMigrationBase, ReentrancyGuard, ERC721Holder, Ownable {
    using SafeERC20 for IERC20;

    event V2V3Rollover(
        address indexed lender,
        address indexed borrower,
        uint256 collateralTokenId,
        uint256 newLoanId
    );

    struct OperationContracts {
        ILoanCoreV2 loanCoreV2;
        IERC721 borrowerNoteV2;
        IRepaymentControllerV2 repaymentControllerV2;
        IFeeController feeControllerV3;
        IOriginationController originationControllerV3;
        ILoanCore loanCoreV3;
        IERC721 borrowerNoteV3;
    }

    // Balancer vault contract
    /* solhint-disable var-name-mixedcase */
    IVault public immutable VAULT; // 0xBA12222222228d8Ba445958a75a0704d566BF2C8

    /// @notice lending protocol contract references
    ILoanCoreV2 public immutable loanCoreV2;
    IERC721 public immutable borrowerNoteV2;
    IRepaymentControllerV2 public immutable repaymentControllerV2;
    IFeeController public immutable feeControllerV3;
    IOriginationController public immutable originationControllerV3;
    ILoanCore public immutable loanCoreV3;
    IERC721 public immutable borrowerNoteV3;

    /// @notice State variable used for checking the inheriting contract initiated the flash
    ///         loan. When a rollover function is called the borrowers address is cached here
    ///         and checked against the opData in the flash loan callback.
    address public borrower;

    /// @notice state variable for pausing the contract
    bool public paused;

    constructor(IVault _vault, OperationContracts memory _opContracts) {
        // input sanitization
        if (address(_vault) == address(0)) revert R_ZeroAddress("vault");
        if (address(_opContracts.loanCoreV2) == address(0)) revert R_ZeroAddress("loanCoreV2");
        if (address(_opContracts.borrowerNoteV2) == address(0)) revert R_ZeroAddress("borrowerNoteV2");
        if (address(_opContracts.repaymentControllerV2) == address(0)) revert R_ZeroAddress("repaymentControllerV2");
        if (address(_opContracts.feeControllerV3) == address(0)) revert R_ZeroAddress("feeControllerV3");
        if (address(_opContracts.originationControllerV3) == address(0)) revert R_ZeroAddress("originationControllerV3");
        if (address(_opContracts.loanCoreV3) == address(0)) revert R_ZeroAddress("loanCoreV3");
        if (address(_opContracts.borrowerNoteV3) == address(0)) revert R_ZeroAddress("borrowerNoteV3");

        // Set Balancer vault address
        VAULT = _vault;

        // Set lending protocol contract references
        loanCoreV2 = ILoanCoreV2(_opContracts.loanCoreV2);
        borrowerNoteV2 = IERC721(_opContracts.borrowerNoteV2);
        repaymentControllerV2 = IRepaymentControllerV2(_opContracts.repaymentControllerV2);
        feeControllerV3 = IFeeController(_opContracts.feeControllerV3);
        originationControllerV3 = IOriginationController(_opContracts.originationControllerV3);
        loanCoreV3 = ILoanCore(_opContracts.loanCoreV3);
        borrowerNoteV3 = IERC721(_opContracts.borrowerNoteV3);
    }

    /**
     * @notice This helper function to calculate the net amounts required to repay the flash loan.
     *         This function will return the total amount due back to the lending pool. The amount
     *         that needs to be paid by the borrower, in the case that the new loan does not cover
     *         the flashAmountDue. Lastly, the amount that will be sent back to the borrower, in
     *         the case that the new loan covers more than the flashAmountDue. There cannot be a
     *         case where both needFromBorrower and leftoverPrincipal are non-zero.
     *
     * @param amount                  The amount that was borrowed in Flash Loan.
     * @param premium                 The fees that are due back to the lending pool.
     * @param originationFee          The origination fee for the new loan.
     * @param newPrincipal            The principal of the new loan.
     *
     * @return flashAmountDue         The total amount due back to the lending pool.
     * @return needFromBorrower       The amount borrower owes if new loan cannot repay flash loan.
     * @return leftoverPrincipal      The amount to send to borrower if new loan amount is more than
     *                                amount required to repay flash loan.
     */
    function _ensureFunds(
        uint256 amount,
        uint256 premium,
        uint256 originationFee,
        uint256 newPrincipal
    ) internal pure returns (uint256 flashAmountDue, uint256 needFromBorrower, uint256 leftoverPrincipal) {
        // total amount due to flash loan contract
        flashAmountDue = amount + premium;
        // amount that will be received when starting the new loan
        uint256 willReceive = newPrincipal - ((newPrincipal * originationFee) / 1e4);

        if (flashAmountDue > willReceive) {
            // Not enough - have borrower pay the difference
            unchecked {
                needFromBorrower = flashAmountDue - willReceive;
            }
        } else if (willReceive > flashAmountDue) {
            // Too much - will send extra to borrower
            unchecked {
                leftoverPrincipal = willReceive - flashAmountDue;
            }
        }
    }

    /**
     * @notice Helper function to repay the loan. Takes the borrowerNote from the borrower, approves
     *         the V2 repayment controller to spend the payable currency received from flash loan.
     *         Repays the loan, and ensures this contract holds the collateral after the loan is repaid.
     *
     * @param loanData                 The loan data for the loan to be repaid.
     * @param borrowerNoteId           ID of the borrowerNote for the loan to be repaid.
     * @param opDataBorrower           The address of the borrower.
     */
    function _repayLoan(
        LoanLibraryV2.LoanData memory loanData,
        uint256 borrowerNoteId,
        address opDataBorrower
    ) internal {
        // take BorrowerNote from borrower so that this contract receives collateral
        // borrower must approve this withdrawal
        borrowerNoteV2.transferFrom(opDataBorrower, address(this), borrowerNoteId);

        // approve repayment
        uint256 totalRepayment = repaymentControllerV2.getFullInterestAmount(
            loanData.terms.principal,
            loanData.terms.interestRate
        );

        IERC20(loanData.terms.payableCurrency).approve(
            address(repaymentControllerV2),
            totalRepayment
        );

        // repay loan
        repaymentControllerV2.repay(borrowerNoteId);

        // contract now has collateral but has lost funds
        address collateralOwner = IERC721(loanData.terms.collateralAddress).ownerOf(loanData.terms.collateralId);
        if (collateralOwner != address(this)) revert R_NotCollateralOwner(collateralOwner);
    }

    /**
     * @notice Validates that the rollover is valid. The borrower from the old loan must be the caller.
     *         The new loan must have the same currency as the old loan. The new loan must use the same
     *         collateral as the old loan. If any of these conditionals are not met, the transaction
     *         will revert.
     *
     * @param sourceLoanTerms           The terms of the V2 loan.
     * @param newLoanTerms              The terms of the V3 loan.
     * @param borrowerNoteId            The ID of the borrowerNote for the old loan.
     *
     * @return _borrower                Caller and the owner of borrowerNote address.
     */
    function _validateRollover(
        LoanLibraryV2.LoanTerms memory sourceLoanTerms,
        LoanLibrary.LoanTerms memory newLoanTerms,
        uint256 borrowerNoteId
    ) internal view returns (address _borrower) {
        _borrower = borrowerNoteV2.ownerOf(borrowerNoteId);

        if (_borrower != msg.sender) revert R_CallerNotBorrower(msg.sender, _borrower);

        if (sourceLoanTerms.payableCurrency != newLoanTerms.payableCurrency) {
            revert R_CurrencyMismatch(sourceLoanTerms.payableCurrency, newLoanTerms.payableCurrency);
        }

        if (sourceLoanTerms.collateralAddress != newLoanTerms.collateralAddress) {
            revert R_CollateralMismatch(sourceLoanTerms.collateralAddress, newLoanTerms.collateralAddress);
        }

        if (sourceLoanTerms.collateralId != newLoanTerms.collateralId) {
            revert R_CollateralIdMismatch(sourceLoanTerms.collateralId, newLoanTerms.collateralId);
        }
    }

    /**
     * @notice Function to be used by the contract owner to pause the contract.
     *
     * @dev This function is only to be used if a vulnerability is found or the contract
     *      is no longer being used.
     *
     * @param _pause              The state to set the contract to.
     */
    function pause(bool _pause) external override onlyOwner {
        if (paused == _pause) revert R_StateAlreadySet();

        paused = _pause;

        emit PausedStateChanged(_pause);
    }

    /**
     * @notice Function to be used by the contract owner to withdraw any ERC20 tokens that
     *         are sent to the contract and get stuck.
     */
    function flushToken(IERC20 token, address to) external override onlyOwner {
        uint256 balance = token.balanceOf(address(this));
        if (balance == 0) revert R_NoTokenBalance();

        token.safeTransfer(to, balance);
    }

    /**
     * @notice This function ensures that at the start of every flash loan sequence, the borrower
     *         state is reset to address(0). The rollover functions that inherit this modifier set
     *         the borrower state while executing the rollover operations. At the end of the rollover
     *         the borrower state is reset to address(0).
     */
    modifier whenBorrowerReset() {
        if (borrower != address(0)) revert R_BorrowerNotReset(borrower);

        _;

        borrower = address(0);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

/**
 * @title LoanLibrary
 * @author Non-Fungible Technologies, Inc.
 *
 * Contains all data types used across Arcade lending contracts.
 */
library LoanLibraryV2 {
    /**
     * @dev Enum describing the current state of a loan.
     * State change flow:
     * Created -> Active -> Repaid
     *                   -> Defaulted
     */
    enum LoanState {
        // We need a default that is not 'Created' - this is the zero value
        DUMMY_DO_NOT_USE,
        // The loan has been initialized, funds have been delivered to the borrower and the collateral is held.
        Active,
        // The loan has been repaid, and the collateral has been returned to the borrower. This is a terminal state.
        Repaid,
        // The loan was delinquent and collateral claimed by the lender. This is a terminal state.
        Defaulted
    }

    /**
     * @dev The raw terms of a loan.
     */
    struct LoanTerms {
        /// @dev Packed variables
        // The number of seconds representing relative due date of the loan.
        /// @dev Max is 94,608,000, fits in 32 bits
        uint32 durationSecs;
        // Timestamp for when signature for terms expires
        uint32 deadline;
        // Total number of installment periods within the loan duration.
        /// @dev Max is 1,000,000, fits in 24 bits
        uint24 numInstallments;
        // Interest expressed as a rate, unlike V1 gross value.
        // Input conversion: 0.01% = (1 * 10**18) ,  10.00% = (1000 * 10**18)
        // This represents the rate over the lifetime of the loan, not APR.
        // 0.01% is the minimum interest rate allowed by the protocol.
        /// @dev Max is 10,000%, fits in 160 bits
        uint160 interestRate;
        /// @dev Full-slot variables
        // The amount of principal in terms of the payableCurrency.
        uint256 principal;
        // The token ID of the address holding the collateral.
        /// @dev Can be an AssetVault, or the NFT contract for unbundled collateral
        address collateralAddress;
        // The token ID of the collateral.
        uint256 collateralId;
        // The payable currency for the loan principal and interest.
        address payableCurrency;
    }

    /**
     * @dev Modification of loan terms, used for signing only.
     *      Instead of a collateralId, a list of predicates
     *      is defined by 'bytes' in items.
     */
    struct LoanTermsWithItems {
        /// @dev Packed variables
        // The number of seconds representing relative due date of the loan.
        /// @dev Max is 94,608,000, fits in 32 bits
        uint32 durationSecs;
        // Timestamp for when signature for terms expires
        uint32 deadline;
        // Total number of installment periods within the loan duration.
        /// @dev Max is 1,000,000, fits in 24 bits
        uint24 numInstallments;
        // Interest expressed as a rate, unlike V1 gross value.
        // Input conversion: 0.01% = (1 * 10**18) ,  10.00% = (1000 * 10**18)
        // This represents the rate over the lifetime of the loan, not APR.
        // 0.01% is the minimum interest rate allowed by the protocol.
        /// @dev Max is 10,000%, fits in 160 bits
        uint160 interestRate;
        /// @dev Full-slot variables
        uint256 principal;
        // The tokenID of the address holding the collateral
        /// @dev Must be an AssetVault for LoanTermsWithItems
        address collateralAddress;
        // An encoded list of predicates
        bytes items;
        // The payable currency for the loan principal and interest
        address payableCurrency;
    }

    /**
     * @dev Predicate for item-based verifications
     */
    struct Predicate {
        // The encoded predicate, to decoded and parsed by the verifier contract
        bytes data;
        // The verifier contract
        address verifier;
    }

    /**
     * @dev The data of a loan. This is stored once the loan is Active
     */
    struct LoanData {
        /// @dev Packed variables
        // The current state of the loan
        LoanState state;
        // Number of installment payments made on the loan
        uint24 numInstallmentsPaid;
        // installment loan specific
        // Start date of the loan, using block.timestamp - for determining installment period
        uint160 startDate;
        /// @dev Full-slot variables
        // The raw terms of the loan
        LoanTerms terms;
        // Remaining balance of the loan. Starts as equal to principal. Can reduce based on
        // payments made, can increased based on compounded interest from missed payments and late fees
        uint256 balance;
        // Amount paid in total by the borrower
        uint256 balancePaid;
        // Total amount of late fees accrued
        uint256 lateFeesAccrued;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

interface IFeeControllerV2 {
    // ================ Events =================

    event UpdateOriginationFee(uint256 _newFee);
    event UpdateRolloverFee(uint256 _newFee);
    event UpdateCollateralSaleFee(uint256 _newFee);
    event UpdatePayLaterFee(uint256 _newFee);

    // ================ Fee Setters =================

    function setOriginationFee(uint256 _originationFee) external;

    function setRolloverFee(uint256 _rolloverFee) external;

    function setCollateralSaleFee(uint256 _collateralSaleFee) external;

    function setPayLaterFee(uint256 _payLaterFee) external;

    // ================ Fee Getters =================

    function getOriginationFee() external view returns (uint256);

    function getRolloverFee() external view returns (uint256);

    function getCollateralSaleFee() external view returns (uint256);

    function getPayLaterFee() external view returns (uint256);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import "../LoanLibraryV2.sol";

import "./IPromissoryNoteV2.sol";
import "./IFeeControllerV2.sol";

interface ILoanCoreV2 {
    // ================ Events =================

    event LoanCreated(LoanLibraryV2.LoanTerms terms, uint256 loanId);
    event LoanStarted(uint256 loanId, address lender, address borrower);
    event LoanRepaid(uint256 loanId);
    event LoanRolledOver(uint256 oldLoanId, uint256 newLoanId);
    event InstallmentPaymentReceived(uint256 loanId, uint256 repaidAmount, uint256 remBalance);
    event LoanClaimed(uint256 loanId);
    event FeesClaimed(address token, address to, uint256 amount);
    event SetFeeController(address feeController);
    event NonceUsed(address indexed user, uint160 nonce);

    // ============== Lifecycle Operations ==============

    function startLoan(
        address lender,
        address borrower,
        LoanLibraryV2.LoanTerms calldata terms
    ) external returns (uint256 loanId);

    function repay(uint256 loanId) external;

    function repayPart(
        uint256 _loanId,
        uint256 _currentMissedPayments,
        uint256 _paymentToPrincipal,
        uint256 _paymentToInterest,
        uint256 _paymentToLateFees,
        address _caller
    ) external;

    function claim(uint256 loanId, uint256 currentInstallmentPeriod) external;

    function rollover(
        uint256 oldLoanId,
        address borrower,
        address lender,
        LoanLibraryV2.LoanTerms calldata terms,
        uint256 _settledAmount,
        uint256 _amountToOldLender,
        uint256 _amountToLender,
        uint256 _amountToBorrower
    ) external returns (uint256 newLoanId);

    // ============== Nonce Management ==============

    function consumeNonce(address user, uint160 nonce) external;

    function cancelNonce(uint160 nonce) external;

    // ============== View Functions ==============

    function getLoan(uint256 loanId) external view returns (LoanLibraryV2.LoanData calldata loanData);

    function isNonceUsed(address user, uint160 nonce) external view returns (bool);

    function borrowerNote() external returns (IPromissoryNoteV2);

    function lenderNote() external returns (IPromissoryNoteV2);

    function feeController() external returns (IFeeControllerV2);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

interface IPromissoryNoteV2 is IERC721Enumerable {
    // ============== Token Operations ==============

    function mint(address to, uint256 loanId) external returns (uint256);

    function burn(uint256 tokenId) external;

    function setPaused(bool paused) external;

    // ============== Initializer ==============

    function initialize(address loanCore) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

interface IRepaymentControllerV2 {
    // ============== Lifeycle Operations ==============

    function repay(uint256 loanId) external;

    function claim(uint256 loanId) external;

    function repayPartMinimum(uint256 loanId) external;

    function repayPart(uint256 loanId, uint256 amount) external;

    function closeLoan(uint256 loanId) external;

    // ============== View Functions ==============

    function getInstallmentMinPayment(uint256 loanId)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );

    function amountToCloseLoan(uint256 loanId) external returns (uint256, uint256);

    function getFullInterestAmount(uint256 principal, uint256 interestRate) external pure returns (uint256);
}