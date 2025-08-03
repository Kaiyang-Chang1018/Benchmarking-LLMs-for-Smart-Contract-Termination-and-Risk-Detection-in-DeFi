// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (interfaces/IERC2981.sol)

pragma solidity ^0.8.0;

import "../utils/introspection/IERC165.sol";

/**
 * @dev Interface for the NFT Royalty Standard.
 *
 * A standardized way to retrieve royalty payment information for non-fungible tokens (NFTs) to enable universal
 * support for royalty payments across all NFT marketplaces and ecosystem participants.
 *
 * _Available since v4.5._
 */
interface IERC2981 is IERC165 {
    /**
     * @dev Returns how much royalty is owed and to whom, based on a sale price that may be denominated in any unit of
     * exchange. The royalty amount is denominated and should be paid in that same unit of exchange.
     */
    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

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
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
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
/**
 *Glitch was here
 */

// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.19;
/*
            ____ _ _ _       _     _          _
           / ___| (_) |_ ___| |__ ( )___     / \   _ __ _ __ ___  _   _
          | |  _| | | __/ __| '_ \|// __|   / _ \ | '__| '_ ` _ \| | | |
          | |_| | | | || (__| | | | \__ \  / ___ \| |  | | | | | | |_| |
           \____|_|_|\__\___|_| |_| |___/ /_/   \_\_|  |_| |_| |_|\__, |
                                                                  |___/

             ____             _      _____
            |  _ \  __ _ _ __| | __ | ____|_ __   ___ _ __ __ _ _   _
            | | | |/ _` | '__| |/ / |  _| | '_ \ / _ \ '__/ _` | | | |
            | |_| | (_| | |  |   <  | |___| | | |  __/ | | (_| | |_| |
            |____/ \__,_|_|  |_|\_\ |_____|_| |_|\___|_|  \__, |\__, |
                                                          |___/ |___/
*/


import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./GlitchGeneralMintSpots.sol";
import "../interfaces/ISeaDrop.sol";
import "../util/OwnableAndAdministrable.sol";
import "../libraries/UriEncode.sol";
import "../interfaces/IDarkEnergy.sol";
import "../libraries/DarkEnergyPackedStruct.sol";

/**
 * @title  DarkEnergy
 * @author mouradif.eth
 * @notice Optimized ERC721 base for use with LazyLion's missing 80 Open
 *         Edition: DarkEnergy
 */
contract DarkEnergy is
    OwnableAndAdministrable,
    ReentrancyGuard,
    IDarkEnergy
{
    string internal constant NAME = "Glitchs Army: Dark Energy";
    string internal constant SYMBOL = "DE";
    uint256 internal constant ENERGY_PER_MINT = 100;

    using DarkEnergyPackedStruct for bytes32;
    using DarkEnergyPackedStruct for DarkEnergyPackedStruct.GameRules;
    using Strings for uint256;
    using Strings for int256;
    using UriEncode for string;

    /// @notice Missing80 Ordinals Vouchers contract
    address public ordinalsVouchers;

    /// @notice Track the allowed SeaDrop addresses.
    mapping(address => bool) internal _allowedSeaDrop;

    /// @notice Track the enumerated allowed SeaDrop addresses.
    address[] internal _enumeratedAllowedSeaDrop;

    /// @notice Mapping from address to ownership details in binary format
    ///
    /// Bits Layout:
    /// - [0]        bool   isHolder
    /// - [1..40]    int40  energyAmount
    /// - [41..56]   uint16 gamePasses
    /// - [57..72]   uint16 mintCount
    /// - [73..88]   uint16 mergeCount
    /// - [89..104]  uint16 noRiskPlayCount
    /// - [105..120] uint16 noRiskWinCount
    /// - [121..136] uint16 highStakesPlayCount
    /// - [137..152] uint16 highStakesWinCount
    /// - [153..168] uint16 highStakesLossCount
    /// - [169..200] uint32 totalEarned
    /// - [201..232] uint32 totalRugged
    /// - [233..255] 23bits unused
    mapping(address => bytes32) internal _playerData;

    /// @notice Game configuration
    ///
    /// @dev for the Odds:
    ///              Each uint16 is a number that divided by 120_000
    ///              returns the probability of an event to occur
    /// Bits layout:
    /// - [0]        bool isActive (bool)
    /// - [1..16]    uint16 oddsNoRiskEarn100
    /// - [17..32]   uint16 oddsNoRiskEarn300
    /// - [33..48]   uint16 oddsNoRiskEarn500
    /// - [49..64]   uint16 oddsHighStakesWinOrdinal
    /// - [65..80]   uint16 oddsHighStakesLose100
    /// - [81..96]   uint16 oddsHighStakesLose300
    /// - [97..112]  uint16 oddsHighStakesLose500
    /// - [113..128] uint16 oddsHighStakesLose1000
    /// - [129..144] uint16 oddsHighStakesEarn100
    /// - [145..160] uint16 oddsHighStakesEarn300
    /// - [161..176] uint16 oddsHighStakesEarn500
    /// - [177..192] uint16 oddsHighStakesEarn1000
    /// - [193..208] uint16 oddsHighStakesDoubles
    /// - [209..224] uint16 oddsHighStakesHalves
    /// - [225..240] uint16 oddsGamePassOnMint
    /// - [241..248] uint8  remainingOrdinals
    /// - [249]      bool   flagA
    /// - [250]      bool   flagB
    /// - [251]      bool   flagC
    /// - [252]      bool   flagD
    /// - [253]      bool   flagE
    /// - [254]      bool   flagF
    /// - [255]      bool   flagG

    bytes32 internal _gameRules =
        0x0026ea60096009602ee03e805dc0bb802ee03e805dc0bb80003c096012c02ee1;

    /// @notice The maximum supply
    uint64 internal _maxSupply;

    /// @notice The current circulating supply
    uint64 internal _totalSupply;

    /// @notice The current circulating energy
    int256 internal _circulatingEnergy;

    /// @notice Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) internal _operatorApprovals;

    /// @notice Mapping from token ID to approved address.
    mapping(uint256 => address) internal _tokenApprovals;

    /// @notice Track the royalty info: address to receive royalties, and
    ///         royalty basis points.
    RoyaltyInfo _royaltyInfo;

    /// @notice AllowList of marketplaces
    mapping(address => bool) internal _allowedOperators;

    /**
     * @notice Deploy the token contract with its name and symbol.
     */
    constructor(address admin, address[] memory allowedSeaDrop) {
        _setOwner(msg.sender);
        _setRole(admin, 0, true);
        // Put the length on the stack for more efficient access.
        uint256 allowedSeaDropLength = allowedSeaDrop.length;

        // Set the mapping for allowed SeaDrop contracts.
        for (uint256 i = 0; i < allowedSeaDropLength; ) {
            _allowedSeaDrop[allowedSeaDrop[i]] = true;
            unchecked {
                ++i;
            }
        }
        GlitchGeneralMintSpots _ordinalsVouchers = new GlitchGeneralMintSpots();
        ordinalsVouchers = address(_ordinalsVouchers);
        _royaltyInfo.royaltyBps = 500;
        _royaltyInfo.royaltyAddress = msg.sender;
        emit SeaDropTokenDeployed();
        emit OrdinalsVouchersDeployed(ordinalsVouchers);
    }

    /**
     * @dev Returns the total number of tokens in existence.
     * Burned tokens will reduce the count.
     */
    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Returns the total number of energy in circulation
     */
    function circulatingEnergy() external view returns (int256) {
        return _circulatingEnergy;
    }

    /**
     * @notice Returns the token collection name.
     */
    function name() external pure override returns (string memory) {
        return NAME;
    }

    /**
     * @notice Returns the token collection symbol.
     */
    function symbol() external pure override returns (string memory) {
        return SYMBOL;
    }

    /**
     * @notice Checks wether a token exists or not
     */
    function exists(uint256 tokenId) external view returns(bool) {
        address potentialOwner = address(uint160(tokenId));
        return _playerData[potentialOwner].isHolder();
    }

    /**
     * @notice Returns the expected ball size in the SVG
     */
    function _getBallSize(uint32 x) internal pure returns (uint256) {
        if (x < 150) return x;
        if (x < 1000) return 150 + (x - 150) / 20;
        if (x < 4000) return 193 + (x - 1000) / 30;
        if (x < 10000) return 293 + (x - 4000) / 80;
        if (x < 300000) return 368 + (x - 10000) / 2200;
        return 500;
    }

    /**
     * @notice Returns the expected center of the ball in the SVG
     */
    function _getCenter(uint256 x) internal pure returns (uint256) {
        if (x < 150) return 1000 + x / 4;
        if (x < 1000) return 1070 - x / 5;
        if (x < 4000) return 870 - (x - 1000) / 20;
        if (x < 9500) return 720 - (x - 4000) / 25;
        return 500;
    }

    /**
     * @notice Special metadata for dead tokens
     */
    function _deadToken() internal pure returns (string memory) {
        string memory svgData = string(abi.encodePacked(
                "<svg viewBox='0 0 1e3 1e3' xmlns='http://www.w3.org/2000/svg'><style>svg{background:#000000}</style></svg>"
            ));
        return string(
            abi.encodePacked(
                'data:application/json,{"name":"Energy Waste","image_data":"',
                svgData,
                '","attributes":[{"trait_type":"energy","value":0},',
                '{"trait_type":"Game Passes","value":0},',
                '{"trait_type":"Burned","value":"yes"}',
                ']}'
            )
        ).uriEncode();
    }

    /**
     * @notice Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        address potentialOwner = address(uint160(tokenId));
        bytes32 data = _playerData[potentialOwner];
        if (!data.isHolder()) {
            return _deadToken();
        }
        int40 energy = data.getEnergy();
        uint16 gamePasses = data.getGamePasses();
        uint32 absEnergy = uint32(uint40(energy < 0 ? -energy : energy));
        uint256 size = _getBallSize(absEnergy);
        uint256 center = _getCenter(absEnergy);
        bytes6 color = energy < 0 ? bytes6(bytes("B46278")) : bytes6(bytes("5C6BBA"));
        bytes6 background = gamePasses == 0 ? bytes6(bytes("0B0B0B")) : bytes6(bytes("1B309F"));

        string memory svgData = string(abi.encodePacked(
            "<svg viewBox='0 0 1e3 1e3' xmlns='http://www.w3.org/2000/svg'><defs><radialGradient id='a' cx='500' cy='",
            center.toString(),
            "' r='",
            size.toString(),
            "' gradientUnits='userSpaceOnUse'><stop stop-color='#fff' stop-opacity='.6' offset='.17'/><stop stop-color='#fff' stop-opacity='0' offset='1'/></radialGradient></defs><circle cx='500' cy='",
            center.toString(),
            "' r='",
            size.toString(),
            "' fill='#",
            color,
            "'/><circle id='cg' cx='500' cy='",
            center.toString(),
            "' r='",
            size.toString(),
            "' fill='url(#a)' opacity='0'/><style>svg{background:#",
            background,
            "}#cg{-webkit-animation:1.5s ease-in-out infinite alternate p;animation:1.5s ease-in-out infinite alternate p}@-webkit-keyframes p{to{opacity:1}}@keyframes p{to{opacity:1}}</style></svg>"
        ));

        return string(
            abi.encodePacked(
                'data:application/json,{"name":"Dark Energy: ',
                int256(energy).toString(),
                '","image_data":"',
                svgData,
                '","attributes":[{"trait_type":"Energy","value":"',
                int256(energy).toString(),
                '"},{"trait_type":"Game Passes","value":"',
                uint256(gamePasses).toString(),
                '"}]}'
            )
        ).uriEncode();
    }

    /**
     * @notice Returns the contract URI for contract metadata.
     */
    function contractURI() external view override returns (string memory) {
        return string(
            abi.encodePacked(
                'data:application/json,{"name":"',
                NAME,
                '","totalSupply":',
                uint256(_totalSupply).toString(),
                '}'
            )
        ).uriEncode();
    }

    /**
     * @notice Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     */
    function approve(address to, uint256 tokenId) external virtual override {
        address _owner = ownerOf(tokenId);

        if (msg.sender != _owner) {
            if (!_operatorApprovals[_owner][msg.sender]) {
                revert CallerNotOwnerNorApproved();
            }
        }
        _tokenApprovals[tokenId] = to;

        emit Approval(_owner, to, tokenId);
    }

    /**
     * @notice Returns the account approved for `tokenId` token.
     */
    function getApproved(
        uint256 tokenId
    ) public view virtual override returns (address) {
        ownerOf(tokenId);
        return _tokenApprovals[tokenId];
    }

    /**
     * @notice Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom}, {safeTransferFrom} or {approve}
     * for any token owned by the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(
        address operator,
        bool approved
    ) public virtual override {
        if (!_allowedOperators[operator]) {
            revert OperatorNotAllowed();
        }
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(
        address owner,
        address operator
    ) external view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function _transferFrom(address from, address to, uint256 tokenId) internal {
        address potentialOwner = ownerOf(tokenId);

        if (potentialOwner != from) revert TransferFromIncorrectOwner();
        if (to == address(0)) revert QueryForZeroAddress();
        if (!_isApprovedOrOwner(msg.sender, tokenId))
            revert CallerNotOwnerNorApproved();
        if (from != msg.sender && !_allowedOperators[msg.sender])
            revert OperatorNotAllowed();

        bytes32 senderData = _playerData[from];
        bytes32 recipientData = _playerData[to];
        int40 senderEnergy = senderData.getEnergy();
        int40 recipientEnergy = recipientData.getEnergy();
        uint256 newTokenId = uint256(uint160(to));

        emit Transfer(from, to, tokenId);

        if (recipientData.isHolder()) {
            if (senderEnergy < 0 && recipientEnergy >= 0)
                revert NegativeEnergyToPositiveHolder();
            recipientEnergy += senderEnergy;
            uint256 realTotalGamePasses;
            unchecked {
                realTotalGamePasses = senderData.getGamePasses() +
                recipientData.getGamePasses();
            }
            uint16 gamePasses = realTotalGamePasses > 0xFFFF
            ? 0xFFFF
            : uint16(realTotalGamePasses);
            uint16 mergeCount = recipientData.getMergeCount();

            recipientData = recipientData.setHolder(true);
            recipientData = recipientData.setEnergy(recipientEnergy);
            recipientData = recipientData.setGamePasses(gamePasses);
            recipientData = recipientData.setMergeCount(mergeCount + 1);
            unchecked {
                _totalSupply--;
            }
        } else {
            recipientData = recipientData.setHoldingData(senderData);
            emit Transfer(address(0), to, newTokenId);
        }
        _playerData[from] = senderData.clearHoldingData();
        _playerData[to] = recipientData;
        _tokenApprovals[tokenId] = address(0);

        // Burn of the sent token
        emit Transfer(to, address(0), tokenId);
        emit MetadataUpdate(tokenId);
        emit MetadataUpdate(newTokenId);
    }

    function _safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal {
        _transferFrom(from, to, tokenId);
        if (to.code.length != 0)
            if (!_checkContractOnERC721Received(from, to, tokenId, _data)) {
                revert TransferToNonERC721ReceiverImplementer();
            }
    }

    /**
     * @notice Transfers `tokenId` from `from` to `to`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external override {
        _transferFrom(from, to, tokenId);
    }

    /**
     * @dev Equivalent to `safeTransferFrom(from, to, tokenId, '')`.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        _safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @notice Safely transfers `tokenId` token from `from` to `to`.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        _safeTransferFrom(from, to, tokenId, _data);
    }

    /**
     * @dev Mints `quantity` tokens and transfers them to `to`.
     */
    function _mint(
        address to,
        uint16 quantity
    ) internal virtual returns (uint256) {
        uint256 tokenId = uint256(uint160(to));
        bytes32 data = _playerData[to];
        uint16 mintCount = data.getMintCount();
        int40 energy = data.getEnergy();
        unchecked {
            energy += int40(uint40(quantity * ENERGY_PER_MINT));
            mintCount += quantity;
        }
        uint16 gamePasses = 0;
        bool isHolder = data.isHolder();
        if (quantity >= 4) {
            unchecked { gamePasses = uint16(quantity / 4); }
        }
        uint8 remainder = uint8(quantity % 4);
        for (uint256 i = 0; i < remainder;) {
            uint256 base;
            unchecked {
                base = block.prevrandao - i;
                ++i;
            }

            uint256 n = uint256(keccak256(abi.encode(base))) % 120000;
            if (n < _gameRules.getUint16(225)) {
                unchecked { gamePasses++; }
            }
        }
        if (isHolder) {
            uint16 mergeCount = data.getMergeCount();
            data = data.setMergeCount(mergeCount + 1);
        } else {
            unchecked { _totalSupply++; }
            if (_totalSupply > _maxSupply) {
                revert MaxSupplyExceeded();
            }
            emit Transfer(address(0), to, tokenId);
        }

        data = data.setHolder(true);
        data = data.setEnergy(energy);
        data = data.setGamePasses(gamePasses + data.getGamePasses());
        data = data.setMintCount(mintCount);
        _playerData[to] = data;
        unchecked { _circulatingEnergy += int256(ENERGY_PER_MINT * quantity); }
        emit GlitchMint(to, quantity * ENERGY_PER_MINT, gamePasses);
        emit MetadataUpdate(tokenId);
        return isHolder ? 0 : tokenId;
    }

    function _noRiskEarn(int40 amount, bytes32 data) internal {
        _circulatingEnergy += amount;
        uint256 tokenId = uint256(uint160(msg.sender));
        int40 energy = data.getEnergy();
        uint16 winCount = data.getNoRiskWinCount();
        uint32 totalEarned = data.getTotalEarned();
        data = data.setEnergy(energy + amount);
        data = data.setNoRiskWinCount(winCount + 1);
        data = data.setTotalEarned(totalEarned + uint32(uint40(amount)));
        _playerData[msg.sender] = data;
        emit EnergyUpdate(msg.sender, int40(amount));
        emit MetadataUpdate(tokenId);
    }

    function _winOrdinal(address winner, bytes32 data) internal {
        uint256 tokenId = uint256(uint160(winner));
        int40 energy = data.getEnergy();
        _circulatingEnergy -= energy;
        data = data.setEnergy(int40(0));
        _playerData[winner] = data;

        GlitchGeneralMintSpots vouchers = GlitchGeneralMintSpots(ordinalsVouchers);
        uint256 voucherId = vouchers.nextId();
        if (energy < 0) {
            energy = -energy;
        }
        uint256 ballSize = _getBallSize(uint32(uint40(energy)));
        vouchers.adminMint(winner, voucherId, ballSize);

        emit MetadataUpdate(tokenId);
        emit OrdinalWon(winner);
    }

    function _highStakesResult(int40 result, bytes32 data) internal {
        _circulatingEnergy += result;
        uint256 tokenId = uint256(uint160(msg.sender));
        emit EnergyUpdate(msg.sender, result);
        data = data.setEnergy(data.getEnergy() + result);
        if (result < 0) {
            result = -result;
            data = data.setHighStakesLossCount(
                data.getHighStakesLossCount() + 1
            );
            data = data.setTotalRugged(
                data.getTotalRugged() + uint32(uint40(result))
            );
        } else {
            data = data.setHighStakesWinCount(
                data.getHighStakesWinCount() + 1
            );
            data = data.setTotalEarned(
                data.getTotalEarned() + uint32(uint40(result))
            );
        }
        _playerData[msg.sender] = data;
        emit MetadataUpdate(tokenId);
    }

    function playNoRisk() external {
        if (!_gameRules.getBool(0)) {
            revert GameNotActive();
        }
        emit PlayNoRisk(msg.sender);
        bytes32 data = _playerData[msg.sender];
        uint16 gamePasses = data.getGamePasses();
        if (gamePasses == 0) {
            revert NoGamePass();
        }
        data = data.setNoRiskPlayCount(data.getNoRiskPlayCount() + 1);
        data = data.setGamePasses(gamePasses - 1);
        bytes32 rules = _gameRules;

        uint256 randomNumber = uint256(
            keccak256(abi.encode(block.prevrandao))
        ) % 120000;
        uint32 treshold = rules.getUint16(1);
        if (randomNumber < treshold) {
            _noRiskEarn(100, data);
            return;
        }
        treshold += rules.getUint16(17);
        if (randomNumber < treshold) {
            _noRiskEarn(300, data);
            return;
        }
        treshold += rules.getUint16(33);
        if (randomNumber < treshold) {
            _noRiskEarn(500, data);
            return;
        }
        _playerData[msg.sender] = data;
        emit MetadataUpdate(uint256(uint160(msg.sender)));
    }

    function playHighStakes() external {
        if (!_gameRules.getBool(0)) {
            revert GameNotActive();
        }
        emit PlayHighStakes(msg.sender);
        bytes32 data = _playerData[msg.sender];
        uint16 gamePasses = data.getGamePasses();
        if (gamePasses == 0) {
            revert NoGamePass();
        }
        data = data.setHighStakesPlayCount(data.getHighStakesPlayCount() + 1);
        data = data.setGamePasses(gamePasses - 1);
        bytes32 rules = _gameRules;
        uint256 randomNumber = uint256(
            keccak256(abi.encode(block.prevrandao))
        ) % 120000;
        uint32 treshold = uint32(rules.getUint16(49)) * uint32(rules.getUint8(241));
        if (randomNumber < treshold) {
            _gameRules = _gameRules.setUint8(241, _gameRules.getUint8(241) - 1);
            return _winOrdinal(msg.sender, data);
        }
        treshold = rules.getUint16(65);
        if (randomNumber < treshold) {
            return _highStakesResult(-100, data);
        }
        treshold += rules.getUint16(81);
        if (randomNumber < treshold) {
            return _highStakesResult(-300, data);
        }
        treshold += rules.getUint16(97);
        if (randomNumber < treshold) {
            return _highStakesResult(-500, data);
        }
        treshold += rules.getUint16(113);
        if (randomNumber < treshold) {
            return _highStakesResult(-1000, data);
        }
        treshold += rules.getUint16(129);
        if (randomNumber < treshold) {
            return _highStakesResult(100, data);
        }
        treshold += rules.getUint16(145);
        if (randomNumber < treshold) {
            return _highStakesResult(300, data);
        }
        treshold += rules.getUint16(161);
        if (randomNumber < treshold) {
            return _highStakesResult(500, data);
        }
        treshold += rules.getUint16(177);
        if (randomNumber < treshold) {
            return _highStakesResult(1000, data);
        }
        int40 energy = data.getEnergy();
        uint256 tokenId = uint256(uint160(msg.sender));
        treshold += rules.getUint16(193);
        if (randomNumber < treshold && energy != 0) {
            emit EnergyDoubled(msg.sender, energy);
            return _highStakesResult(energy, data);
        }
        treshold += rules.getUint16(209);
        if (randomNumber < treshold && energy != 0) {
            emit EnergyHalved(msg.sender, energy);
            int40 diff = energy / 2;
            return _highStakesResult(-diff, data);
        }
        _playerData[msg.sender] = data;
        emit MetadataUpdate(tokenId);
    }

    /**
     * @dev Private function to invoke {IERC721Receiver-onERC721Received} on a target contract.
     *
     * `from` - Previous owner of the given token ID.
     * `to` - Target address that will receive the token.
     * `tokenId` - Token ID to be transferred.
     * `_data` - Optional data to send along with the call.
     *
     * Returns whether the call correctly returned the expected magic value.
     */
    function _checkContractOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        try
        IERC721Receiver(to).onERC721Received(
            msg.sender,
            from,
            tokenId,
            _data
        )
        returns (bytes4 retval) {
            return retval == IERC721Receiver(to).onERC721Received.selector;
        } catch (bytes memory reason) {
            if (reason.length == 0) {
                revert TransferToNonERC721ReceiverImplementer();
            }
            assembly {
                revert(add(32, reason), mload(reason))
            }
        }
    }

    /**
     * @dev Safely mints `quantity` tokens and transfers them to `to`.
     */
    function _safeMint(
        address to,
        uint256 quantity,
        bytes memory _data
    ) internal virtual {
        uint256 tokenId = _mint(to, uint16(quantity));
        if (tokenId == 0) {
            return;
        }

        unchecked {
            if (to.code.length != 0) {
                if (
                    !_checkContractOnERC721Received(
                    address(0),
                    to,
                    tokenId,
                    _data
                )
                ) {
                    revert TransferToNonERC721ReceiverImplementer();
                }
            }
        }
    }

    function _onlyAllowedSeaDrop(address seaDrop) internal view {
        if (!_allowedSeaDrop[seaDrop]) {
            revert OnlyAllowedSeaDrop();
        }
    }

    /**
     * @notice Mint tokens, restricted to the SeaDrop contract.
     */
    function mintSeaDrop(
        address minter,
        uint256 quantity
    ) external override nonReentrant {
        _onlyAllowedSeaDrop(msg.sender);
        _safeMint(minter, quantity, "");
    }

    /**
     * @notice Mint tokens, restricted to the SeaDrop contract.
     */
    function adminMint(
        address minter,
        int40 energy,
        uint16 gamePasses
    ) external nonReentrant {
        _checkRoleOrOwner(msg.sender, 1);
        _safeMint(minter, 0, "");
        bytes32 data = _playerData[minter];
        emit AdminMint(minter, energy - data.getEnergy(), gamePasses - data.getGamePasses());
        _circulatingEnergy += energy - data.getEnergy();
        data = data.setEnergy(energy);
        data = data.setGamePasses(gamePasses);
        _playerData[minter] = data;
    }

    /**
     * @notice Admin function to distribute rewards to the raffle winners
     */
    function raffleReward(address winner) external nonReentrant {
        _checkRoleOrOwner(msg.sender, 1);
        bytes32 data = _playerData[winner];
        if (!data.isHolder()) {
            revert AddressNotHolder();
        }
        _winOrdinal(winner, data);
    }

    /**
     * @notice Sets the address and basis points for royalties.
     *
     * @param newInfo The struct to configure royalties.
     */
    function setRoyaltyInfo(RoyaltyInfo calldata newInfo) external {
        // Ensure the sender is only the owner or contract itself.
        _checkRoleOrOwner(msg.sender, 1);

        // Revert if the new royalty address is the zero address.
        if (newInfo.royaltyAddress == address(0)) {
            revert RoyaltyAddressCannotBeZeroAddress();
        }

        // Revert if the new basis points is greater than 10_000.
        if (newInfo.royaltyBps > 10_000) {
            revert InvalidRoyaltyBasisPoints(newInfo.royaltyBps);
        }

        // Set the new royalty info.
        _royaltyInfo = newInfo;

        // Emit an event with the updated params.
        emit RoyaltyInfoUpdated(newInfo.royaltyAddress, newInfo.royaltyBps);
    }

    /**
     * @notice Returns the address that receives royalties.
     */
    function royaltyAddress() external view returns (address) {
        return _royaltyInfo.royaltyAddress;
    }

    /**
     * @notice Returns the royalty basis points out of 10_000.
     */
    function royaltyBasisPoints() external view returns (uint256) {
        return _royaltyInfo.royaltyBps;
    }

    /**
     * @notice Called with the sale price to determine how much royalty
     *         is owed and to whom.
     *
     * @return receiver      Address of who should be sent the royalty payment.
     * @return royaltyAmount The royalty payment amount for _salePrice.
     */
    function royaltyInfo(
        uint256,
        uint256 _salePrice
    ) external view returns (address receiver, uint256 royaltyAmount) {
        royaltyAmount = (_salePrice * _royaltyInfo.royaltyBps) / 10_000;
        receiver = _royaltyInfo.royaltyAddress;
    }

    /**
     * @dev Returns whether `tokenId` exists.
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        address potentialOwner = address(uint160(tokenId));
        return _playerData[potentialOwner].isHolder();
    }

    /**
     * @dev Returns whether `address` is approved for transfering `tokenId`
     */
    function _isApprovedOrOwner(
        address spender,
        uint256 tokenId
    ) internal view returns (bool) {
        address potentialOwner = ownerOf(tokenId);
        if (spender == potentialOwner) return true;
        return spender == _tokenApprovals[tokenId] ||
        _operatorApprovals[potentialOwner][spender];
    }

    /**
     * @notice Returns whether the interface is supported.
     *
     * @param interfaceId The interface id to check against.
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(IDarkEnergy) returns (bool) {
        return
        interfaceId == 0x01ffc9a7 || // ER165
        interfaceId == 0x80ac58cd || // ERC721
        interfaceId == 0x5b5e139f || // ERC721-Metadata
        interfaceId == 0x2a55205a || // ERC2981
        interfaceId == 0x49064906 || // ERC4906
        interfaceId == type(INonFungibleSeaDropToken).interfaceId ||
        interfaceId == type(ISeaDropTokenContractMetadata).interfaceId;
    }

    // =============================================================
    //                      Game configuration
    // =============================================================

    function _checkNoRiskOdds(
        uint16 earn1,
        uint16 earn3,
        uint16 earn5
    ) internal pure {
        uint256 total = earn1 + earn3 + earn5;
        if (total > 120000) {
            revert InvalidGameRules();
        }
    }

    function _checkHighStakesOdds(
        uint16 lose1,
        uint16 lose3,
        uint16 lose5,
        uint16 lose10,
        uint16 earn1,
        uint16 earn3,
        uint16 earn5,
        uint16 earn10,
        uint16 double,
        uint16 halve
    ) internal pure {
        uint256 total = lose1 + lose3 + lose5;
        total = total + lose10 + earn1;
        total = total + earn3 + earn5;
        total = total + earn10 + double + halve;
        if (total > 120000) {
            revert InvalidGameRules();
        }
    }

    function _checkOrdinalsRules(
        uint16 odds,
        uint8 amount
    ) internal pure {
        uint256 total = uint256(odds) * uint256(amount);
        if (total > 120000) {
            revert InvalidGameRules();
        }
    }

    function setRules(
        DarkEnergyPackedStruct.GameRules calldata config
    ) external {
        _checkRoleOrOwner(msg.sender, 1);
        _checkNoRiskOdds(
            config.oddsNoRiskEarn100,
            config.oddsNoRiskEarn300,
            config.oddsNoRiskEarn500
        );
        _checkHighStakesOdds(
            config.oddsHighStakesLose100,
            config.oddsHighStakesLose300,
            config.oddsHighStakesLose500,
            config.oddsHighStakesLose1000,
            config.oddsHighStakesEarn100,
            config.oddsHighStakesEarn300,
            config.oddsHighStakesEarn500,
            config.oddsHighStakesEarn1000,
            config.oddsHighStakesDoubles,
            config.oddsHighStakesHalves
        );
        _checkOrdinalsRules(
            config.oddsHighStakesWinOrdinal,
            config.remainingOrdinals
        );
        bytes32 newRules = config.packGameRules();
        emit GameRulesUpdated(_gameRules, newRules);
        _gameRules = newRules;
    }

    function gameRules()
    external
    view
    returns (DarkEnergyPackedStruct.GameRules memory) {
        return _gameRules.gameRules();
    }

    // =============================================================
    //                  Administrative functions
    // =============================================================

    /**
     * @notice Sets the max token supply and emits an event.
     *
     * @param operator   The operator account or contract address
     * @param status        The status (true = approved, false = denied)
     */
    function setOperatorStatus(address operator, bool status) external {
        _checkRoleOrOwner(msg.sender, 1);
        _allowedOperators[operator] = status;
    }

    /**
     * @notice Sets the max token supply and emits an event.
     *
     * @param newMaxSupply The new max supply to set.
     */
    function setMaxSupply(uint256 newMaxSupply) external {
        _checkRoleOrOwner(msg.sender, 1);
        uint64 supply = uint64(newMaxSupply);
        if (supply < _totalSupply) {
            supply = _totalSupply;
        }
        _maxSupply = supply;
        emit MaxSupplyUpdated(supply);
    }

    /**
     * @notice Internal function to update the allowed SeaDrop contracts.
     *
     * @param allowedSeaDrop The allowed SeaDrop addresses.
     */
    function _updateAllowedSeaDrop(address[] calldata allowedSeaDrop) internal {
        // Put the length on the stack for more efficient access.
        uint256 enumeratedAllowedSeaDropLength = _enumeratedAllowedSeaDrop
        .length;
        uint256 allowedSeaDropLength = allowedSeaDrop.length;

        // Reset the old mapping.
        for (uint256 i = 0; i < enumeratedAllowedSeaDropLength; ) {
            _allowedSeaDrop[_enumeratedAllowedSeaDrop[i]] = false;
            unchecked {
                ++i;
            }
        }

        // Set the new mapping for allowed SeaDrop contracts.
        for (uint256 i = 0; i < allowedSeaDropLength; ) {
            _allowedSeaDrop[allowedSeaDrop[i]] = true;
            unchecked {
                ++i;
            }
        }

        // Set the enumeration.
        _enumeratedAllowedSeaDrop = allowedSeaDrop;

        // Emit an event for the update.
        emit AllowedSeaDropUpdated(allowedSeaDrop);
    }


    function updateAllowedSeaDrop(address[] calldata allowedSeaDrop) external {
        _checkRoleOrOwner(msg.sender, 0);

        _updateAllowedSeaDrop(allowedSeaDrop);
    }

    function updateCreatorPayoutAddress(
        address seaDrop,
        address creator
    ) external {
        _checkRoleOrOwner(msg.sender, 1);
        _onlyAllowedSeaDrop(seaDrop);
        ISeaDrop(seaDrop).updateCreatorPayoutAddress(creator);
    }

    function updatePublicDrop(
        address seaDrop,
        PublicDrop memory dropData
    ) external {
        _checkRoleOrOwner(msg.sender, 0);
        _onlyAllowedSeaDrop(seaDrop);
        PublicDrop memory r = ISeaDrop(seaDrop).getPublicDrop(address(this));
        if (!_hasRole(msg.sender, 0)) {
            if (r.maxTotalMintableByWallet == 0) {
                revert AdministratorMustInitializeWithFee();
            }
            dropData.feeBps = r.feeBps;
            dropData.restrictFeeRecipients = true;
        } else {
            uint256 maxTotalMintableByWallet = r.maxTotalMintableByWallet;
            r.maxTotalMintableByWallet = maxTotalMintableByWallet > 0 ?
                uint16(maxTotalMintableByWallet) :
                1;
            r.feeBps = dropData.feeBps;
            r.restrictFeeRecipients = true;
            dropData = r;
        }
        ISeaDrop(seaDrop).updatePublicDrop(dropData);
    }

    /**
     * @notice Update the drop URI for this nft contract on SeaDrop.
     *         Only the owner or administrator can use this function.
     *
     * @param seaDropImpl The allowed SeaDrop contract.
     * @param dropURI     The new drop URI.
     */
    function updateDropURI(address seaDropImpl, string calldata dropURI)
        external
        virtual
        override
    {
        _checkRoleOrOwner(msg.sender, 0);
        // Ensure the SeaDrop is allowed.
        _onlyAllowedSeaDrop(seaDropImpl);

        // Update the drop URI.
        ISeaDrop(seaDropImpl).updateDropURI(dropURI);
    }

    /**
     * @notice Update the allow list data for this nft contract on SeaDrop.
     *         Only the owner or administrator can use this function.
     *
     * @param seaDropImpl   The allowed SeaDrop contract.
     * @param allowListData The allow list data.
     */
    function updateAllowList(
        address seaDropImpl,
        AllowListData calldata allowListData
    ) external virtual override {
        _checkRoleOrOwner(msg.sender, 0);
        // Ensure the SeaDrop is allowed.
        _onlyAllowedSeaDrop(seaDropImpl);

        // Update the allow list on SeaDrop.
        ISeaDrop(seaDropImpl).updateAllowList(allowListData);
    }

    /**
     * @notice Update the allowed fee recipient for this nft contract
     *         on SeaDrop.
     *         Only the administrator can set the allowed fee recipient.
     *
     * @param seaDrop      The allowed SeaDrop contract.
     * @param feeRecipient The new fee recipient.
     * @param status       If the fee recipient is allowed.
     */
    function updateAllowedFeeRecipient(
        address seaDrop,
        address feeRecipient,
        bool status
    ) external {
        _checkRole(msg.sender, 0);
        _onlyAllowedSeaDrop(seaDrop);
        ISeaDrop(seaDrop).updateAllowedFeeRecipient(feeRecipient, status);
    }

    /**
     * @notice Update the allowed payers for this nft contract on SeaDrop.
     *         Only the owner or administrator can use this function.
     *
     * @param seaDropImpl The allowed SeaDrop contract.
     * @param payer       The payer to update.
     * @param allowed     Whether the payer is allowed.
     */
    function updatePayer(
        address seaDropImpl,
        address payer,
        bool allowed
    ) external virtual override {
        _checkRoleOrOwner(msg.sender, 0);
        // Ensure the SeaDrop is allowed.
        _onlyAllowedSeaDrop(seaDropImpl);

        // Update the payer.
        ISeaDrop(seaDropImpl).updatePayer(payer, allowed);
    }

    /**
     * @notice Configure multiple properties at a time.
     *
     *         Note: The individual configure methods should be used
     *         to unset or reset any properties to zero, as this method
     *         will ignore zero-value properties in the config struct.
     *
     * @param config The configuration struct.
     */
    function multiConfigure(MultiConfigureStruct calldata config)
    external
    {
        _checkRoleOrOwner(msg.sender, 1);
        if (config.maxSupply > 0) {
            this.setMaxSupply(config.maxSupply);
        }
        if (
            config.publicDrop.startTime != 0 ||
            config.publicDrop.endTime != 0
        ) {
            this.updatePublicDrop(config.seaDropImpl, config.publicDrop);
        }
        if (bytes(config.dropURI).length != 0) {
            this.updateDropURI(config.seaDropImpl, config.dropURI);
        }
        if (config.allowListData.merkleRoot != bytes32(0)) {
            this.updateAllowList(config.seaDropImpl, config.allowListData);
        }
        if (config.creatorPayoutAddress != address(0)) {
            this.updateCreatorPayoutAddress(
                config.seaDropImpl,
                config.creatorPayoutAddress
            );
        }
        if (config.allowedFeeRecipients.length > 0) {
            for (uint256 i = 0; i < config.allowedFeeRecipients.length; ) {
                this.updateAllowedFeeRecipient(
                    config.seaDropImpl,
                    config.allowedFeeRecipients[i],
                    true
                );
                unchecked {
                    ++i;
                }
            }
        }
        if (config.disallowedFeeRecipients.length > 0) {
            for (uint256 i = 0; i < config.disallowedFeeRecipients.length; ) {
                this.updateAllowedFeeRecipient(
                    config.seaDropImpl,
                    config.disallowedFeeRecipients[i],
                    false
                );
                unchecked {
                    ++i;
                }
            }
        }
        if (config.allowedPayers.length > 0) {
            for (uint256 i = 0; i < config.allowedPayers.length; ) {
                this.updatePayer(
                    config.seaDropImpl,
                    config.allowedPayers[i],
                    true
                );
                unchecked {
                    ++i;
                }
            }
        }
        if (config.disallowedPayers.length > 0) {
            for (uint256 i = 0; i < config.disallowedPayers.length; ) {
                this.updatePayer(
                    config.seaDropImpl,
                    config.disallowedPayers[i],
                    false
                );
                unchecked {
                    ++i;
                }
            }
        }
    }

    // =============================================================
    //   No-op or low-op functions to ensure compatibility
    // =============================================================

    function setBaseURI(string calldata) external override {}

    function setContractURI(string calldata) external override {}


    function setProvenanceHash(bytes32) external {}

    function updateSignedMintValidationParams(
        address,
        address,
        SignedMintValidationParams memory
    ) external {}

    function updateTokenGatedDrop(
        address,
        address,
        TokenGatedDropStage calldata
    ) external {}

    function baseURI() external pure override returns (string memory) {
        return "";
    }

    // =============================================================
    //        NFT and Game stats
    // =============================================================


    function maxSupply() external view returns (uint256) {
        return _maxSupply;
    }

    function provenanceHash() external pure override returns (bytes32) {
        return bytes32(0);
    }

    function getMintStats(
        address minter
    ) external view returns (uint256, uint256, uint256) {
        bytes32 data = _playerData[minter];
        return (
        uint256(data.getMintCount()),
        _totalSupply,
        _maxSupply
        );
    }

    /**
     * @notice Returns the address that owns the given token.
     *
     * @dev The tokenId is the numeric representation of the owner's address.
     *      If that address holds a token, its last bit will be 1 and we can
     *      return the address representation of the tokenId. If not, then
     *      the token doesn't exist.
     */
    function ownerOf(
        uint256 tokenId
    ) public view virtual override returns (address) {
        address potentialOwner = address(uint160(tokenId));
        if (!_playerData[potentialOwner].isHolder()) {
            revert QueryForNonExistentToken();
        }
        return potentialOwner;
    }

    /**
     * @notice Returns the number of tokens in `owner`'s account.
     *
     * @dev An address may have at most one token. If the data of an
            address has 1 as a last bit, then that address has a token.
     */
    function balanceOf(address _owner) public view override returns (uint256) {
        if (_owner == address(0)) {
            revert QueryForZeroAddress();
        }
        bool isHolder = _playerData[_owner].isHolder();
        if (isHolder) {
            return 1;
        }
        return 0;
    }

    /**
     * @notice Returns the amount of energy in a given tokenId
     */
    function playerData(
        address player
    ) external view returns (DarkEnergyPackedStruct.PlayerData memory) {
        return _playerData[player].playerData();
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.2) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "../libraries/Strings.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string internal _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
        interfaceId == type(IERC721).interfaceId ||
        interfaceId == type(IERC721Metadata).interfaceId ||
        super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _ownerOf(tokenId);
        require(owner != address(0), "ERC721: invalid token ID");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not token owner or approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        _requireMinted(tokenId);

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");
        _safeTransfer(from, to, tokenId, data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns the owner of the `tokenId`. Does NOT revert if token doesn't exist
     */
    function _ownerOf(uint256 tokenId) internal view virtual returns (address) {
        return _owners[tokenId];
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId, 1);

        // Check that tokenId was not minted by `_beforeTokenTransfer` hook
        require(!_exists(tokenId), "ERC721: token already minted");

        unchecked {
            // Will not overflow unless all 2**256 token ids are minted to the same owner.
            // Given that tokens are minted one by one, it is impossible in practice that
            // this ever happens. Might change if we allow batch minting.
            // The ERC fails to describe this case.
            _balances[to] += 1;
        }

        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId, 1);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     * This is an internal function that does not check if the sender is authorized to operate on the token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId, 1);

        // Update ownership in case tokenId was transferred by `_beforeTokenTransfer` hook
        owner = ERC721.ownerOf(tokenId);

        // Clear approvals
        delete _tokenApprovals[tokenId];

        unchecked {
            // Cannot overflow, as that would require more tokens to be burned/transferred
            // out than the owner initially received through minting and transferring in.
            _balances[owner] -= 1;
        }
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId, 1);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId, 1);

        // Check that tokenId was not transferred by `_beforeTokenTransfer` hook
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");

        // Clear approvals from the previous owner
        delete _tokenApprovals[tokenId];

        unchecked {
            // `_balances[from]` cannot overflow for the same reason as described in `_burn`:
            // `from`'s balance is the number of token held, which is at least one before the current
            // transfer.
            // `_balances[to]` could overflow in the conditions described in `_mint`. That would require
            // all 2**256 token ids to be minted, which in practice is impossible.
            _balances[from] -= 1;
            _balances[to] += 1;
        }
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId, 1);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits an {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Reverts if the `tokenId` has not been minted yet.
     */
    function _requireMinted(uint256 tokenId) internal view virtual {
        require(_exists(tokenId), "ERC721: invalid token ID");
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting and burning. If {ERC721Consecutive} is
     * used, the hook may be called as part of a consecutive (batch) mint, as indicated by `batchSize` greater than 1.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s tokens will be transferred to `to`.
     * - When `from` is zero, the tokens will be minted for `to`.
     * - When `to` is zero, ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     * - `batchSize` is non-zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual {}

    /**
     * @dev Hook that is called after any token transfer. This includes minting and burning. If {ERC721Consecutive} is
     * used, the hook may be called as part of a consecutive (batch) mint, as indicated by `batchSize` greater than 1.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s tokens were transferred to `to`.
     * - When `from` is zero, the tokens were minted for `to`.
     * - When `to` is zero, ``from``'s tokens were burned.
     * - `from` and `to` are never both zero.
     * - `batchSize` is non-zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual {}

    /**
     * @dev Unsafe write access to the balances, used by extensions that "mint" tokens using an {ownerOf} override.
     *
     * WARNING: Anyone calling this MUST ensure that the balances remain consistent with the ownership. The invariant
     * being that for any address `a` the value returned by `balanceOf(a)` must be equal to the number of tokens such
     * that `ownerOf(tokenId)` is `a`.
     */
    // solhint-disable-next-line func-name-mixedcase
    function __unsafe_increaseBalance(address account, uint256 amount) internal {
        _balances[account] += amount;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./ERC721.sol";
import "../util/OwnableAndAdministrable.sol";
import "../libraries/UriEncode.sol";

contract GlitchGeneralMintSpots is ERC721, OwnableAndAdministrable {
  using Strings for uint256;
  using UriEncode for string;

  /**
   * @dev Revert if the royalty basis points is greater than 10_000.
     */
  error InvalidRoyaltyBasisPoints(uint256 basisPoints);

  /**
   * @dev Revert if the royalty address is being set to the zero address.
     */
  error RoyaltyAddressCannotBeZeroAddress();

  /**
   * @dev Emit an event when the royalties info is updated.
   */
  event RoyaltyInfoUpdated(address receiver, uint256 bps);

  /**
   * @notice A struct defining royalty info for the contract.
   */
  struct RoyaltyInfo {
    address royaltyAddress;
    uint96 royaltyBps;
  }

  /// @notice Track the royalty info: address to receive royalties, and
  ///         royalty basis points.
  RoyaltyInfo _royaltyInfo;

  uint256 private _tokenIdCounter = 1;
  mapping(uint256 => uint256) private _tokenSize;

  event MetadataUpdate(uint256 _tokenId);

  address public darkEnergyContract;

  constructor() ERC721("Glitchs Army: The Generals mint spot", "GMS") {
    _setOwner(tx.origin);
    _setRole(tx.origin, 0, true);
    _setRole(msg.sender, 0, true);
    _royaltyInfo.royaltyBps = 500;
    _royaltyInfo.royaltyAddress = tx.origin;
    darkEnergyContract = msg.sender;
  }

  /**
   * @notice Returns whether the interface is supported.
   *
   * @param interfaceId The interface id to check against.
   */
  function supportsInterface(
    bytes4 interfaceId
  ) public view virtual override(ERC721) returns (bool) {
    return
    interfaceId == 0x01ffc9a7 || // ER165
    interfaceId == 0x80ac58cd || // ERC721
    interfaceId == 0x5b5e139f || // ERC721-Metadata
    interfaceId == 0x2a55205a;   // ERC2981
  }

  /**
   * @notice Sets the address and basis points for royalties.
   *
   * @param newInfo The struct to configure royalties.
   */
  function setRoyaltyInfo(RoyaltyInfo calldata newInfo) external {
    // Ensure the sender is only the owner or contract itself.
    _checkRoleOrOwner(msg.sender, 1);

    // Revert if the new royalty address is the zero address.
    if (newInfo.royaltyAddress == address(0)) {
      revert RoyaltyAddressCannotBeZeroAddress();
    }

    // Revert if the new basis points is greater than 10_000.
    if (newInfo.royaltyBps > 10_000) {
      revert InvalidRoyaltyBasisPoints(newInfo.royaltyBps);
    }

    // Set the new royalty info.
    _royaltyInfo = newInfo;

    // Emit an event with the updated params.
    emit RoyaltyInfoUpdated(newInfo.royaltyAddress, newInfo.royaltyBps);
  }

  /**
   * @notice Returns the address that receives royalties.
   */
  function royaltyAddress() external view returns (address) {
    return _royaltyInfo.royaltyAddress;
  }

  /**
   * @notice Returns the royalty basis points out of 10_000.
   */
  function royaltyBasisPoints() external view returns (uint256) {
    return _royaltyInfo.royaltyBps;
  }

  /**
   * @notice Called with the sale price to determine how much royalty
   *         is owed and to whom.
   *
   * @return receiver      Address of who should be sent the royalty payment.
   * @return royaltyAmount The royalty payment amount for _salePrice.
   */
  function royaltyInfo(
    uint256,
    uint256 _salePrice
  ) external view returns (address receiver, uint256 royaltyAmount) {
    royaltyAmount = (_salePrice * _royaltyInfo.royaltyBps) / 10_000;
    receiver = _royaltyInfo.royaltyAddress;
  }

  function adminMint(address to, uint256 tokenId, uint256 size) external {
    _checkRoleOrOwner(msg.sender, 0);
    if(tokenId == _tokenIdCounter) {
      _tokenIdCounter++;
    }
    _tokenSize[tokenId] = size;
    _safeMint(to, tokenId);
  }

  function adminBurn(uint256 tokenId) external {
    _checkRoleOrOwner(msg.sender, 0);
    _burn(tokenId);
  }

  function adminSetTokenSize(uint256 tokenId, uint256 size) external {
    _checkRoleOrOwner(msg.sender, 0);
    _requireMinted(tokenId);
    _tokenSize[tokenId] = size;
    emit MetadataUpdate(tokenId);
  }

  function nextId() external view returns(uint256) {
    return _tokenIdCounter;
  }

  function tokenURI(uint256 tokenId) public view override returns(string memory) {
    _requireMinted(tokenId);
    uint256 size = _tokenSize[tokenId];
    uint256 center = 500;
    bytes6 color = bytes6(bytes("DDC159"));
    bytes6 background = bytes6(bytes("0B0B0B"));

    string memory svgData = string(abi.encodePacked(
        "<svg viewBox='0 0 1e3 1e3' xmlns='http://www.w3.org/2000/svg'><defs><radialGradient id='a' cx='500' cy='",
        center.toString(),
        "' r='",
        size.toString(),
        "' gradientUnits='userSpaceOnUse'><stop stop-color='#fff' stop-opacity='.6' offset='.17'/><stop stop-color='#fff' stop-opacity='0' offset='1'/></radialGradient></defs><circle cx='500' cy='",
        center.toString(),
        "' r='",
        size.toString(),
        "' fill='#",
        color,
        "'/><circle id='cg' cx='500' cy='",
        center.toString(),
        "' r='",
        size.toString(),
        "' fill='url(#a)' opacity='0'/><style>svg{background:#",
        background,
        "}#cg{-webkit-animation:1.5s ease-in-out infinite alternate p;animation:1.5s ease-in-out infinite alternate p}@-webkit-keyframes p{to{opacity:1}}@keyframes p{to{opacity:1}}</style></svg>"
      ));

    return string(
      abi.encodePacked(
        'data:application/json,{"name":"Glitch\'s Army: The Generals mint spot #',
        tokenId.toString(),
        '","image_data":"',
        svgData,
        '"}'
      )
    ).uriEncode();
  }

  function contractURI() external pure returns(string memory) {
    return string(abi.encodePacked(
      'data:application/json,{"name": "Glitch\'s Army: The Generals mint spot"}'
    )).uriEncode();
  }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import { PublicDrop, TokenGatedDropStage, SignedMintValidationParams } from "./SeaDropStructs.sol";

interface SeaDropErrorsAndEvents {
    /**
     * @dev Revert with an error if the drop stage is not active.
     */
    error NotActive(
        uint256 currentTimestamp,
        uint256 startTimestamp,
        uint256 endTimestamp
    );

    /**
     * @dev Revert with an error if the mint quantity is zero.
     */
    error MintQuantityCannotBeZero();

    /**
     * @dev Revert with an error if the mint quantity exceeds the max allowed
     *      to be minted per wallet.
     */
    error MintQuantityExceedsMaxMintedPerWallet(uint256 total, uint256 allowed);

    /**
     * @dev Revert with an error if the mint quantity exceeds the max token
     *      supply.
     */
    error MintQuantityExceedsMaxSupply(uint256 total, uint256 maxSupply);

    /**
     * @dev Revert with an error if the mint quantity exceeds the max token
     *      supply for the stage.
     *      Note: The `maxTokenSupplyForStage` for public mint is
     *      always `type(uint).max`.
     */
    error MintQuantityExceedsMaxTokenSupplyForStage(
        uint256 total,
        uint256 maxTokenSupplyForStage
    );

    /**
     * @dev Revert if the fee recipient is the zero address.
     */
    error FeeRecipientCannotBeZeroAddress();

    /**
     * @dev Revert if the fee recipient is not already included.
     */
    error FeeRecipientNotPresent();

    /**
     * @dev Revert if the fee basis points is greater than 10_000.
     */
    error InvalidFeeBps(uint256 feeBps);

    /**
     * @dev Revert if the fee recipient is already included.
     */
    error DuplicateFeeRecipient();

    /**
     * @dev Revert if the fee recipient is restricted and not allowed.
     */
    error FeeRecipientNotAllowed();

    /**
     * @dev Revert if the creator payout address is the zero address.
     */
    error CreatorPayoutAddressCannotBeZeroAddress();

    /**
     * @dev Revert with an error if the received payment is incorrect.
     */
    error IncorrectPayment(uint256 got, uint256 want);

    /**
     * @dev Revert with an error if the allow list proof is invalid.
     */
    error InvalidProof();

    /**
     * @dev Revert if a supplied signer address is the zero address.
     */
    error SignerCannotBeZeroAddress();

    /**
     * @dev Revert with an error if signer's signature is invalid.
     */
    error InvalidSignature(address recoveredSigner);

    /**
     * @dev Revert with an error if a signer is not included in
     *      the enumeration when removing.
     */
    error SignerNotPresent();

    /**
     * @dev Revert with an error if a payer is not included in
     *      the enumeration when removing.
     */
    error PayerNotPresent();

    /**
     * @dev Revert with an error if a payer is already included in mapping
     *      when adding.
     *      Note: only applies when adding a single payer, as duplicates in
     *      enumeration can be removed with updatePayer.
     */
    error DuplicatePayer();

    /**
     * @dev Revert with an error if the payer is not allowed. The minter must
     *      pay for their own mint.
     */
    error PayerNotAllowed();

    /**
     * @dev Revert if a supplied payer address is the zero address.
     */
    error PayerCannotBeZeroAddress();

    /**
     * @dev Revert with an error if the sender does not
     *      match the INonFungibleSeaDropToken interface.
     */
    error OnlyINonFungibleSeaDropToken(address sender);

    /**
     * @dev Revert with an error if the sender of a token gated supplied
     *      drop stage redeem is not the owner of the token.
     */
    error TokenGatedNotTokenOwner(
        address nftContract,
        address allowedNftToken,
        uint256 allowedNftTokenId
    );

    /**
     * @dev Revert with an error if the token id has already been used to
     *      redeem a token gated drop stage.
     */
    error TokenGatedTokenIdAlreadyRedeemed(
        address nftContract,
        address allowedNftToken,
        uint256 allowedNftTokenId
    );

    /**
     * @dev Revert with an error if an empty TokenGatedDropStage is provided
     *      for an already-empty TokenGatedDropStage.
     */
     error TokenGatedDropStageNotPresent();

    /**
     * @dev Revert with an error if an allowedNftToken is set to
     *      the zero address.
     */
     error TokenGatedDropAllowedNftTokenCannotBeZeroAddress();

    /**
     * @dev Revert with an error if an allowedNftToken is set to
     *      the drop token itself.
     */
     error TokenGatedDropAllowedNftTokenCannotBeDropToken();


    /**
     * @dev Revert with an error if supplied signed mint price is less than
     *      the minimum specified.
     */
    error InvalidSignedMintPrice(uint256 got, uint256 minimum);

    /**
     * @dev Revert with an error if supplied signed maxTotalMintableByWallet
     *      is greater than the maximum specified.
     */
    error InvalidSignedMaxTotalMintableByWallet(uint256 got, uint256 maximum);

    /**
     * @dev Revert with an error if supplied signed start time is less than
     *      the minimum specified.
     */
    error InvalidSignedStartTime(uint256 got, uint256 minimum);

    /**
     * @dev Revert with an error if supplied signed end time is greater than
     *      the maximum specified.
     */
    error InvalidSignedEndTime(uint256 got, uint256 maximum);

    /**
     * @dev Revert with an error if supplied signed maxTokenSupplyForStage
     *      is greater than the maximum specified.
     */
     error InvalidSignedMaxTokenSupplyForStage(uint256 got, uint256 maximum);

     /**
     * @dev Revert with an error if supplied signed feeBps is greater than
     *      the maximum specified, or less than the minimum.
     */
    error InvalidSignedFeeBps(uint256 got, uint256 minimumOrMaximum);

    /**
     * @dev Revert with an error if signed mint did not specify to restrict
     *      fee recipients.
     */
    error SignedMintsMustRestrictFeeRecipients();

    /**
     * @dev Revert with an error if a signature for a signed mint has already
     *      been used.
     */
    error SignatureAlreadyUsed();

    /**
     * @dev An event with details of a SeaDrop mint, for analytical purposes.
     *
     * @param nftContract    The nft contract.
     * @param minter         The mint recipient.
     * @param feeRecipient   The fee recipient.
     * @param payer          The address who payed for the tx.
     * @param quantityMinted The number of tokens minted.
     * @param unitMintPrice  The amount paid for each token.
     * @param feeBps         The fee out of 10_000 basis points collected.
     * @param dropStageIndex The drop stage index. Items minted
     *                       through mintPublic() have
     *                       dropStageIndex of 0.
     */
    event SeaDropMint(
        address indexed nftContract,
        address indexed minter,
        address indexed feeRecipient,
        address payer,
        uint256 quantityMinted,
        uint256 unitMintPrice,
        uint256 feeBps,
        uint256 dropStageIndex
    );

    /**
     * @dev An event with updated public drop data for an nft contract.
     */
    event PublicDropUpdated(
        address indexed nftContract,
        PublicDrop publicDrop
    );

    /**
     * @dev An event with updated token gated drop stage data
     *      for an nft contract.
     */
    event TokenGatedDropStageUpdated(
        address indexed nftContract,
        address indexed allowedNftToken,
        TokenGatedDropStage dropStage
    );

    /**
     * @dev An event with updated allow list data for an nft contract.
     *
     * @param nftContract        The nft contract.
     * @param previousMerkleRoot The previous allow list merkle root.
     * @param newMerkleRoot      The new allow list merkle root.
     * @param publicKeyURI       If the allow list is encrypted, the public key
     *                           URIs that can decrypt the list.
     *                           Empty if unencrypted.
     * @param allowListURI       The URI for the allow list.
     */
    event AllowListUpdated(
        address indexed nftContract,
        bytes32 indexed previousMerkleRoot,
        bytes32 indexed newMerkleRoot,
        string[] publicKeyURI,
        string allowListURI
    );

    /**
     * @dev An event with updated drop URI for an nft contract.
     */
    event DropURIUpdated(address indexed nftContract, string newDropURI);

    /**
     * @dev An event with the updated creator payout address for an nft
     *      contract.
     */
    event CreatorPayoutAddressUpdated(
        address indexed nftContract,
        address indexed newPayoutAddress
    );

    /**
     * @dev An event with the updated allowed fee recipient for an nft
     *      contract.
     */
    event AllowedFeeRecipientUpdated(
        address indexed nftContract,
        address indexed feeRecipient,
        bool indexed allowed
    );

    /**
     * @dev An event with the updated validation parameters for server-side
     *      signers.
     */
    event SignedMintValidationParamsUpdated(
        address indexed nftContract,
        address indexed signer,
        SignedMintValidationParams signedMintValidationParams
    );

    /**
     * @dev An event with the updated payer for an nft contract.
     */
    event PayerUpdated(
        address indexed nftContract,
        address indexed payer,
        bool indexed allowed
    );
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/**
 * @notice A struct defining public drop data.
 *         Designed to fit efficiently in one storage slot.
 *
 * @param mintPrice                The mint price per token. (Up to 1.2m
 *                                 of native token, e.g. ETH, MATIC)
 * @param startTime                The start time, ensure this is not zero.
 * @param endTIme                  The end time, ensure this is not zero.
 * @param maxTotalMintableByWallet Maximum total number of mints a user is
 *                                 allowed. (The limit for this field is
 *                                 2^16 - 1)
 * @param feeBps                   Fee out of 10_000 basis points to be
 *                                 collected.
 * @param restrictFeeRecipients    If false, allow any fee recipient;
 *                                 if true, check fee recipient is allowed.
 */
struct PublicDrop {
    uint80 mintPrice; // 80/256 bits
    uint48 startTime; // 128/256 bits
    uint48 endTime; // 176/256 bits
    uint16 maxTotalMintableByWallet; // 224/256 bits
    uint16 feeBps; // 240/256 bits
    bool restrictFeeRecipients; // 248/256 bits
}

/**
 * @notice A struct defining token gated drop stage data.
 *         Designed to fit efficiently in one storage slot.
 *
 * @param mintPrice                The mint price per token. (Up to 1.2m
 *                                 of native token, e.g.: ETH, MATIC)
 * @param maxTotalMintableByWallet Maximum total number of mints a user is
 *                                 allowed. (The limit for this field is
 *                                 2^16 - 1)
 * @param startTime                The start time, ensure this is not zero.
 * @param endTime                  The end time, ensure this is not zero.
 * @param dropStageIndex           The drop stage index to emit with the event
 *                                 for analytical purposes. This should be
 *                                 non-zero since the public mint emits
 *                                 with index zero.
 * @param maxTokenSupplyForStage   The limit of token supply this stage can
 *                                 mint within. (The limit for this field is
 *                                 2^16 - 1)
 * @param feeBps                   Fee out of 10_000 basis points to be
 *                                 collected.
 * @param restrictFeeRecipients    If false, allow any fee recipient;
 *                                 if true, check fee recipient is allowed.
 */
struct TokenGatedDropStage {
    uint80 mintPrice; // 80/256 bits
    uint16 maxTotalMintableByWallet; // 96/256 bits
    uint48 startTime; // 144/256 bits
    uint48 endTime; // 192/256 bits
    uint8 dropStageIndex; // non-zero. 200/256 bits
    uint32 maxTokenSupplyForStage; // 232/256 bits
    uint16 feeBps; // 248/256 bits
    bool restrictFeeRecipients; // 256/256 bits
}

/**
 * @notice A struct defining mint params for an allow list.
 *         An allow list leaf will be composed of `msg.sender` and
 *         the following params.
 *
 *         Note: Since feeBps is encoded in the leaf, backend should ensure
 *         that feeBps is acceptable before generating a proof.
 *
 * @param mintPrice                The mint price per token.
 * @param maxTotalMintableByWallet Maximum total number of mints a user is
 *                                 allowed.
 * @param startTime                The start time, ensure this is not zero.
 * @param endTime                  The end time, ensure this is not zero.
 * @param dropStageIndex           The drop stage index to emit with the event
 *                                 for analytical purposes. This should be
 *                                 non-zero since the public mint emits with
 *                                 index zero.
 * @param maxTokenSupplyForStage   The limit of token supply this stage can
 *                                 mint within.
 * @param feeBps                   Fee out of 10_000 basis points to be
 *                                 collected.
 * @param restrictFeeRecipients    If false, allow any fee recipient;
 *                                 if true, check fee recipient is allowed.
 */
struct MintParams {
    uint256 mintPrice;
    uint256 maxTotalMintableByWallet;
    uint256 startTime;
    uint256 endTime;
    uint256 dropStageIndex; // non-zero
    uint256 maxTokenSupplyForStage;
    uint256 feeBps;
    bool restrictFeeRecipients;
}

/**
 * @notice A struct defining token gated mint params.
 *
 * @param allowedNftToken    The allowed nft token contract address.
 * @param allowedNftTokenIds The token ids to redeem.
 */
struct TokenGatedMintParams {
    address allowedNftToken;
    uint256[] allowedNftTokenIds;
}

/**
 * @notice A struct defining allow list data (for minting an allow list).
 *
 * @param merkleRoot    The merkle root for the allow list.
 * @param publicKeyURIs If the allowListURI is encrypted, a list of URIs
 *                      pointing to the public keys. Empty if unencrypted.
 * @param allowListURI  The URI for the allow list.
 */
struct AllowListData {
    bytes32 merkleRoot;
    string[] publicKeyURIs;
    string allowListURI;
}

/**
 * @notice A struct defining minimum and maximum parameters to validate for
 *         signed mints, to minimize negative effects of a compromised signer.
 *
 * @param minMintPrice                The minimum mint price allowed.
 * @param maxMaxTotalMintableByWallet The maximum total number of mints allowed
 *                                    by a wallet.
 * @param minStartTime                The minimum start time allowed.
 * @param maxEndTime                  The maximum end time allowed.
 * @param maxMaxTokenSupplyForStage   The maximum token supply allowed.
 * @param minFeeBps                   The minimum fee allowed.
 * @param maxFeeBps                   The maximum fee allowed.
 */
struct SignedMintValidationParams {
    uint80 minMintPrice; // 80/256 bits
    uint24 maxMaxTotalMintableByWallet; // 104/256 bits
    uint40 minStartTime; // 144/256 bits
    uint40 maxEndTime; // 184/256 bits
    uint40 maxMaxTokenSupplyForStage; // 224/256 bits
    uint16 minFeeBps; // 240/256 bits
    uint16 maxFeeBps; // 256/256 bits
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {
  AllowListData,
  PublicDrop,
  SignedMintValidationParams,
  TokenGatedDropStage
} from "../contracts/lib/SeaDropStructs.sol";

interface ERC721SeaDropStructsErrorsAndEvents {
  /**
   * @notice Revert with an error if mint exceeds the max supply.
   */
  error MintQuantityExceedsMaxSupply(uint256 total, uint256 maxSupply);

  /**
   * @notice Revert with an error if the number of token gated
   *         allowedNftTokens doesn't match the length of supplied
   *         drop stages.
   */
  error TokenGatedMismatch();

  /**
   *  @notice Revert with an error if the number of signers doesn't match
   *          the length of supplied signedMintValidationParams
   */
  error SignersMismatch();

  /**
   * @notice A struct to configure multiple contract options at a time.
   */
  struct MultiConfigureStruct {
    uint256 maxSupply;
    string baseURI;
    string contractURI;
    address seaDropImpl;
    PublicDrop publicDrop;
    string dropURI;
    AllowListData allowListData;
    address creatorPayoutAddress;
    bytes32 provenanceHash;

    address[] allowedFeeRecipients;
    address[] disallowedFeeRecipients;

    address[] allowedPayers;
    address[] disallowedPayers;

    // Token-gated
    address[] tokenGatedAllowedNftTokens;
    TokenGatedDropStage[] tokenGatedDropStages;
    address[] disallowedTokenGatedAllowedNftTokens;

    // Server-signed
    address[] signers;
    SignedMintValidationParams[] signedMintValidationParams;
    address[] disallowedSigners;
  }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./INonFungibleSeaDropToken.sol";
import "./ERC721SeaDropStructsErrorsAndEvents.sol";

/**
 * @dev Interface of ERC721A.
 */
interface IDarkEnergy is INonFungibleSeaDropToken, ERC721SeaDropStructsErrorsAndEvents {
    /**
     * The caller must own the token or be an approved operator.
     */
    error CallerNotOwnerNorApproved();

    /**
     * The quantity of tokens minted must be more than zero.
     */
    error MintZeroQuantity();

    /**
     * One cannot send a token holding negative energy to a holder of a token
     * holding positive energy
     */
    error NegativeEnergyToPositiveHolder();

    /**
     * The `quantity` minted with ERC2309 exceeds the safety limit.
     */
    error QuantityExceedsLimit();

    /**
     * The token does not exist.
     */
    error QueryForNonExistentToken();

    /**
     * Cannot query the balance for the zero address.
     */
    error QueryForZeroAddress();

    /**
     * The token must be owned by `from`.
     */
    error TransferFromIncorrectOwner();

    /**
     * Cannot safely transfer to a contract that does not implement the
     * ERC721Receiver interface.
     */
    error TransferToNonERC721ReceiverImplementer();

    /**
     * Caller needs a gamePass to proceed
     */
    error NoGamePass();

    /**
     * The game rules aren't consistent
     */
    error InvalidGameRules();

    /**
     * To prevent Owner from overriding fees, Administrator must
     * first initialize with fee.
     */
    error AdministratorMustInitializeWithFee();

    /**
     * To be thrown in case the max supply was reached and the mint doesn't go
     * through SeaDrop
     */
    error MaxSupplyExceeded();

    /**
     * To be thrown in case the max supply was reached and the mint doesn't go
     * through SeaDrop
     */
    error OperatorNotAllowed();

    /**
     * To be thrown in case the max supply was reached and the mint doesn't go
     * through SeaDrop
     */
    error AddressNotHolder();

    /**
     * To be thrown in case the max supply was reached and the mint doesn't go
     * through SeaDrop
     */
    error GameNotActive();

    // =============================================================
    //                            STRUCTS
    // =============================================================

    struct TokenOwnership {
        // The address of the owner.
        address addr;
        // Stores the start time of ownership with minimal overhead for tokenomics.
        uint64 startTimestamp;
        // Whether the token has been burned.
        bool burned;
        // Arbitrary data similar to `startTimestamp` that can be set via {_extraData}.
        uint24 extraData;
    }

    // =============================================================
    //                         TOKEN COUNTERS
    // =============================================================

    /**
     * @dev Returns the total number of tokens in existence.
     * Burned tokens will reduce the count.
     * To get the total number of tokens minted, please see {_totalMinted}.
     */
    function totalSupply() external view returns (uint256);

    // =============================================================
    //                            IERC165
    // =============================================================

    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * [EIP section](https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified)
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);

    // =============================================================
    //                            IERC721
    // =============================================================

    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );

    /**
     * @dev Emitted when `owner` enables or disables
     * (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    /**
     * @dev Returns the number of tokens in `owner`'s account.
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
     * @dev Safely transfers `tokenId` token from `from` to `to`,
     * checking first that contract recipients are aware of the ERC721 protocol
     * to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move
     * this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement
     * {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
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
     * @dev Equivalent to `safeTransferFrom(from, to, tokenId, '')`.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom}
     * whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token
     * by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the
     * zero address clears previous approvals.
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
     * Operators can call {transferFrom} or {safeTransferFrom}
     * for any token owned by the caller.
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
    function getApproved(
        uint256 tokenId
    ) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(
        address owner,
        address operator
    ) external view returns (bool);

    // =============================================================
    //                        IERC721Metadata
    // =============================================================

    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);

    // =============================================================
    //                           IERC2309
    // =============================================================

    /**
     * @dev Emitted when tokens in `fromTokenId` to `toTokenId`
     * (inclusive) is transferred from `from` to `to`, as defined in the
     * [ERC2309](https://eips.ethereum.org/EIPS/eip-2309) standard.
     *
     * See {_mintERC2309} for more details.
     */
    event ConsecutiveTransfer(
        uint256 indexed fromTokenId,
        uint256 toTokenId,
        address indexed from,
        address indexed to
    );

    // =============================================================
    //                      Marketplace Related
    // =============================================================
    /**
     * @dev Signal to marketplaces that the token has been updated
     */
    event MetadataUpdate(uint256 _tokenId);

    /**
     * @dev Allowed a SeaDrop
     */
    event AllowedSeaDrop(address indexed seaDrop);

    /**
     * @dev Denied a SeaDrop
     */
    event DeniedSeaDrop(address indexed seaDrop);

    // =============================================================
    //                      DarkEnergy-specific
    // =============================================================

    /**
     * @dev GamePass earned through minting
     */
    event GamePassesGained(uint256 indexed tokenId, uint16 indexed amount);

    /**
     * @dev Energy updated
     */
    event EnergyUpdate(address indexed player, int40 indexed energyDiff);

    /**
     * @dev Energy doubled
     */
    event EnergyDoubled(address indexed player, int40 indexed energy);

    /**
     * @dev Energy halved
     */
    event EnergyHalved(address indexed player, int40 indexed energy);

    /**
     * @dev No risk game played
     */
    event PlayNoRisk(address indexed player);

    /**
     * @dev High stakes game played
     */
    event PlayHighStakes(address indexed player);

    /**
     * @dev Ordinal won
     */
    event OrdinalWon(address indexed player);

    /**
     * @dev Game rules updated
     */
    event GameRulesUpdated(bytes32 indexed oldRules, bytes32 indexed newRules);

    /**
     * @dev Game rules updated
     */
    event OrdinalsVouchersDeployed(address indexed contractAddress);

    /**
     * @dev Dark Energy minted
     */
    event GlitchMint(address indexed to, uint256 indexed energy, uint256 indexed gamePasses);

    /**
     * @dev Dark Energy minted
     */
    event AdminMint(address indexed to, int40 indexed energyDiff, uint16 indexed gamePassesDiff);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {
    ISeaDropTokenContractMetadata
} from "./ISeaDropTokenContractMetadata.sol";

import {
    AllowListData,
    PublicDrop,
    TokenGatedDropStage,
    SignedMintValidationParams
} from "../contracts/lib/SeaDropStructs.sol";

interface INonFungibleSeaDropToken is ISeaDropTokenContractMetadata {
    /**
     * @dev Revert with an error if a contract is not an allowed
     *      SeaDrop address.
     */
    error OnlyAllowedSeaDrop();

    /**
     * @dev Emit an event when allowed SeaDrop contracts are updated.
     */
    event AllowedSeaDropUpdated(address[] allowedSeaDrop);

    /**
     * @notice An event to signify that a SeaDrop token contract was deployed.
     */
    event SeaDropTokenDeployed();

    /**
     * @notice Update the allowed SeaDrop contracts.
     *         Only the owner or administrator can use this function.
     *
     * @param allowedSeaDrop The allowed SeaDrop addresses.
     */
    function updateAllowedSeaDrop(address[] calldata allowedSeaDrop) external;

    /**
     * @notice Mint tokens, restricted to the SeaDrop contract.
     *
     * @dev    NOTE: If a token registers itself with multiple SeaDrop
     *         contracts, the implementation of this function should guard
     *         against reentrancy. If the implementing token uses
     *         _safeMint(), or a feeRecipient with a malicious receive() hook
     *         is specified, the token or fee recipients may be able to execute
     *         another mint in the same transaction via a separate SeaDrop
     *         contract.
     *         This is dangerous if an implementing token does not correctly
     *         update the minterNumMinted and currentTotalSupply values before
     *         transferring minted tokens, as SeaDrop references these values
     *         to enforce token limits on a per-wallet and per-stage basis.
     *
     * @param minter   The address to mint to.
     * @param quantity The number of tokens to mint.
     */
    function mintSeaDrop(address minter, uint256 quantity) external;

    /**
     * @notice Returns a set of mint stats for the address.
     *         This assists SeaDrop in enforcing maxSupply,
     *         maxTotalMintableByWallet, and maxTokenSupplyForStage checks.
     *
     * @dev    NOTE: Implementing contracts should always update these numbers
     *         before transferring any tokens with _safeMint() to mitigate
     *         consequences of malicious onERC721Received() hooks.
     *
     * @param minter The minter address.
     */
    function getMintStats(address minter)
        external
        view
        returns (
            uint256 minterNumMinted,
            uint256 currentTotalSupply,
            uint256 maxSupply
        );

    /**
     * @notice Update the public drop data for this nft contract on SeaDrop.
     *         Only the owner or administrator can use this function.
     *
     *         The administrator can only update `feeBps`.
     *
     * @param seaDropImpl The allowed SeaDrop contract.
     * @param publicDrop  The public drop data.
     */
    function updatePublicDrop(
        address seaDropImpl,
        PublicDrop calldata publicDrop
    ) external;

    /**
     * @notice Update the allow list data for this nft contract on SeaDrop.
     *         Only the owner or administrator can use this function.
     *
     * @param seaDropImpl   The allowed SeaDrop contract.
     * @param allowListData The allow list data.
     */
    function updateAllowList(
        address seaDropImpl,
        AllowListData calldata allowListData
    ) external;

    /**
     * @notice Update the token gated drop stage data for this nft contract
     *         on SeaDrop.
     *         Only the owner or administrator can use this function.
     *
     *         The administrator, when present, must first set `feeBps`.
     *
     *         Note: If two INonFungibleSeaDropToken tokens are doing
     *         simultaneous token gated drop promotions for each other,
     *         they can be minted by the same actor until
     *         `maxTokenSupplyForStage` is reached. Please ensure the
     *         `allowedNftToken` is not running an active drop during the
     *         `dropStage` time period.
     *
     *
     * @param seaDropImpl     The allowed SeaDrop contract.
     * @param allowedNftToken The allowed nft token.
     * @param dropStage       The token gated drop stage data.
     */
    function updateTokenGatedDrop(
        address seaDropImpl,
        address allowedNftToken,
        TokenGatedDropStage calldata dropStage
    ) external;

    /**
     * @notice Update the drop URI for this nft contract on SeaDrop.
     *         Only the owner or administrator can use this function.
     *
     * @param seaDropImpl The allowed SeaDrop contract.
     * @param dropURI     The new drop URI.
     */
    function updateDropURI(address seaDropImpl, string calldata dropURI)
        external;

    /**
     * @notice Update the creator payout address for this nft contract on
     *         SeaDrop.
     *         Only the owner can set the creator payout address.
     *
     * @param seaDropImpl   The allowed SeaDrop contract.
     * @param payoutAddress The new payout address.
     */
    function updateCreatorPayoutAddress(
        address seaDropImpl,
        address payoutAddress
    ) external;

    /**
     * @notice Update the allowed fee recipient for this nft contract
     *         on SeaDrop.
     *         Only the administrator can set the allowed fee recipient.
     *
     * @param seaDropImpl  The allowed SeaDrop contract.
     * @param feeRecipient The new fee recipient.
     */
    function updateAllowedFeeRecipient(
        address seaDropImpl,
        address feeRecipient,
        bool allowed
    ) external;

    /**
     * @notice Update the server-side signers for this nft contract
     *         on SeaDrop.
     *         Only the owner or administrator can use this function.
     *
     * @param seaDropImpl                The allowed SeaDrop contract.
     * @param signer                     The signer to update.
     * @param signedMintValidationParams Minimum and maximum parameters
     *                                   to enforce for signed mints.
     */
    function updateSignedMintValidationParams(
        address seaDropImpl,
        address signer,
        SignedMintValidationParams memory signedMintValidationParams
    ) external;

    /**
     * @notice Update the allowed payers for this nft contract on SeaDrop.
     *         Only the owner or administrator can use this function.
     *
     * @param seaDropImpl The allowed SeaDrop contract.
     * @param payer       The payer to update.
     * @param allowed     Whether the payer is allowed.
     */
    function updatePayer(
        address seaDropImpl,
        address payer,
        bool allowed
    ) external;
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {
    AllowListData,
    MintParams,
    PublicDrop,
    TokenGatedDropStage,
    TokenGatedMintParams,
    SignedMintValidationParams
} from "../contracts/lib/SeaDropStructs.sol";

import { SeaDropErrorsAndEvents } from "../contracts/lib/SeaDropErrorsAndEvents.sol";

interface ISeaDrop is SeaDropErrorsAndEvents {
    /**
     * @notice Mint a public drop.
     *
     * @param nftContract      The nft contract to mint.
     * @param feeRecipient     The fee recipient.
     * @param minterIfNotPayer The mint recipient if different than the payer.
     * @param quantity         The number of tokens to mint.
     */
    function mintPublic(
        address nftContract,
        address feeRecipient,
        address minterIfNotPayer,
        uint256 quantity
    ) external payable;

    /**
     * @notice Mint from an allow list.
     *
     * @param nftContract      The nft contract to mint.
     * @param feeRecipient     The fee recipient.
     * @param minterIfNotPayer The mint recipient if different than the payer.
     * @param quantity         The number of tokens to mint.
     * @param mintParams       The mint parameters.
     * @param proof            The proof for the leaf of the allow list.
     */
    function mintAllowList(
        address nftContract,
        address feeRecipient,
        address minterIfNotPayer,
        uint256 quantity,
        MintParams calldata mintParams,
        bytes32[] calldata proof
    ) external payable;

    /**
     * @notice Mint with a server-side signature.
     *         Note that a signature can only be used once.
     *
     * @param nftContract      The nft contract to mint.
     * @param feeRecipient     The fee recipient.
     * @param minterIfNotPayer The mint recipient if different than the payer.
     * @param quantity         The number of tokens to mint.
     * @param mintParams       The mint parameters.
     * @param salt             The sale for the signed mint.
     * @param signature        The server-side signature, must be an allowed
     *                         signer.
     */
    function mintSigned(
        address nftContract,
        address feeRecipient,
        address minterIfNotPayer,
        uint256 quantity,
        MintParams calldata mintParams,
        uint256 salt,
        bytes calldata signature
    ) external payable;

    /**
     * @notice Mint as an allowed token holder.
     *         This will mark the token id as redeemed and will revert if the
     *         same token id is attempted to be redeemed twice.
     *
     * @param nftContract      The nft contract to mint.
     * @param feeRecipient     The fee recipient.
     * @param minterIfNotPayer The mint recipient if different than the payer.
     * @param mintParams       The token gated mint params.
     */
    function mintAllowedTokenHolder(
        address nftContract,
        address feeRecipient,
        address minterIfNotPayer,
        TokenGatedMintParams calldata mintParams
    ) external payable;

    /**
     * @notice Emits an event to notify update of the drop URI.
     *
     *         This method assume msg.sender is an nft contract and its
     *         ERC165 interface id matches INonFungibleSeaDropToken.
     *
     *         Note: Be sure only authorized users can call this from
     *         token contracts that implement INonFungibleSeaDropToken.
     *
     * @param dropURI The new drop URI.
     */
    function updateDropURI(string calldata dropURI) external;

    /**
     * @notice Updates the public drop data for the nft contract
     *         and emits an event.
     *
     *         This method assume msg.sender is an nft contract and its
     *         ERC165 interface id matches INonFungibleSeaDropToken.
     *
     *         Note: Be sure only authorized users can call this from
     *         token contracts that implement INonFungibleSeaDropToken.
     *
     * @param publicDrop The public drop data.
     */
    function updatePublicDrop(PublicDrop calldata publicDrop) external;

    /**
     * @notice Updates the allow list merkle root for the nft contract
     *         and emits an event.
     *
     *         This method assume msg.sender is an nft contract and its
     *         ERC165 interface id matches INonFungibleSeaDropToken.
     *
     *         Note: Be sure only authorized users can call this from
     *         token contracts that implement INonFungibleSeaDropToken.
     *
     * @param allowListData The allow list data.
     */
    function updateAllowList(AllowListData calldata allowListData) external;

    /**
     * @notice Updates the token gated drop stage for the nft contract
     *         and emits an event.
     *
     *         This method assume msg.sender is an nft contract and its
     *         ERC165 interface id matches INonFungibleSeaDropToken.
     *
     *         Note: Be sure only authorized users can call this from
     *         token contracts that implement INonFungibleSeaDropToken.
     *
     *         Note: If two INonFungibleSeaDropToken tokens are doing
     *         simultaneous token gated drop promotions for each other,
     *         they can be minted by the same actor until
     *         `maxTokenSupplyForStage` is reached. Please ensure the
     *         `allowedNftToken` is not running an active drop during
     *         the `dropStage` time period.
     *
     * @param allowedNftToken The token gated nft token.
     * @param dropStage       The token gated drop stage data.
     */
    function updateTokenGatedDrop(
        address allowedNftToken,
        TokenGatedDropStage calldata dropStage
    ) external;

    /**
     * @notice Updates the creator payout address and emits an event.
     *
     *         This method assume msg.sender is an nft contract and its
     *         ERC165 interface id matches INonFungibleSeaDropToken.
     *
     *         Note: Be sure only authorized users can call this from
     *         token contracts that implement INonFungibleSeaDropToken.
     *
     * @param payoutAddress The creator payout address.
     */
    function updateCreatorPayoutAddress(address payoutAddress) external;

    /**
     * @notice Updates the allowed fee recipient and emits an event.
     *
     *         This method assume msg.sender is an nft contract and its
     *         ERC165 interface id matches INonFungibleSeaDropToken.
     *
     *         Note: Be sure only authorized users can call this from
     *         token contracts that implement INonFungibleSeaDropToken.
     *
     * @param feeRecipient The fee recipient.
     * @param allowed      If the fee recipient is allowed.
     */
    function updateAllowedFeeRecipient(address feeRecipient, bool allowed)
        external;

    /**
     * @notice Updates the allowed server-side signers and emits an event.
     *
     *         This method assume msg.sender is an nft contract and its
     *         ERC165 interface id matches INonFungibleSeaDropToken.
     *
     *         Note: Be sure only authorized users can call this from
     *         token contracts that implement INonFungibleSeaDropToken.
     *
     * @param signer                     The signer to update.
     * @param signedMintValidationParams Minimum and maximum parameters
     *                                   to enforce for signed mints.
     */
    function updateSignedMintValidationParams(
        address signer,
        SignedMintValidationParams calldata signedMintValidationParams
    ) external;

    /**
     * @notice Updates the allowed payer and emits an event.
     *
     *         This method assume msg.sender is an nft contract and its
     *         ERC165 interface id matches INonFungibleSeaDropToken.
     *
     *         Note: Be sure only authorized users can call this from
     *         token contracts that implement INonFungibleSeaDropToken.
     *
     * @param payer   The payer to add or remove.
     * @param allowed Whether to add or remove the payer.
     */
    function updatePayer(address payer, bool allowed) external;

    /**
     * @notice Returns the public drop data for the nft contract.
     *
     * @param nftContract The nft contract.
     */
    function getPublicDrop(address nftContract)
        external
        view
        returns (PublicDrop memory);

    /**
     * @notice Returns the creator payout address for the nft contract.
     *
     * @param nftContract The nft contract.
     */
    function getCreatorPayoutAddress(address nftContract)
        external
        view
        returns (address);

    /**
     * @notice Returns the allow list merkle root for the nft contract.
     *
     * @param nftContract The nft contract.
     */
    function getAllowListMerkleRoot(address nftContract)
        external
        view
        returns (bytes32);

    /**
     * @notice Returns if the specified fee recipient is allowed
     *         for the nft contract.
     *
     * @param nftContract  The nft contract.
     * @param feeRecipient The fee recipient.
     */
    function getFeeRecipientIsAllowed(address nftContract, address feeRecipient)
        external
        view
        returns (bool);

    /**
     * @notice Returns an enumeration of allowed fee recipients for an
     *         nft contract when fee recipients are enforced
     *
     * @param nftContract The nft contract.
     */
    function getAllowedFeeRecipients(address nftContract)
        external
        view
        returns (address[] memory);

    /**
     * @notice Returns the server-side signers for the nft contract.
     *
     * @param nftContract The nft contract.
     */
    function getSigners(address nftContract)
        external
        view
        returns (address[] memory);

    /**
     * @notice Returns the struct of SignedMintValidationParams for a signer.
     *
     * @param nftContract The nft contract.
     * @param signer      The signer.
     */
    function getSignedMintValidationParams(address nftContract, address signer)
        external
        view
        returns (SignedMintValidationParams memory);

    /**
     * @notice Returns the payers for the nft contract.
     *
     * @param nftContract The nft contract.
     */
    function getPayers(address nftContract)
        external
        view
        returns (address[] memory);

    /**
     * @notice Returns if the specified payer is allowed
     *         for the nft contract.
     *
     * @param nftContract The nft contract.
     * @param payer       The payer.
     */
    function getPayerIsAllowed(address nftContract, address payer)
        external
        view
        returns (bool);

    /**
     * @notice Returns the allowed token gated drop tokens for the nft contract.
     *
     * @param nftContract The nft contract.
     */
    function getTokenGatedAllowedTokens(address nftContract)
        external
        view
        returns (address[] memory);

    /**
     * @notice Returns the token gated drop data for the nft contract
     *         and token gated nft.
     *
     * @param nftContract     The nft contract.
     * @param allowedNftToken The token gated nft token.
     */
    function getTokenGatedDrop(address nftContract, address allowedNftToken)
        external
        view
        returns (TokenGatedDropStage memory);

    /**
     * @notice Returns whether the token id for a token gated drop has been
     *         redeemed.
     *
     * @param nftContract       The nft contract.
     * @param allowedNftToken   The token gated nft token.
     * @param allowedNftTokenId The token gated nft token id to check.
     */
    function getAllowedNftTokenIdIsRedeemed(
        address nftContract,
        address allowedNftToken,
        uint256 allowedNftTokenId
    ) external view returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import { IERC2981 } from "@openzeppelin/contracts/interfaces/IERC2981.sol";

interface ISeaDropTokenContractMetadata is IERC2981 {
    /**
     * @notice Throw if the max supply exceeds uint64, a limit
     *         due to the storage of bit-packed variables in ERC721A.
     */
    error CannotExceedMaxSupplyOfUint64(uint256 newMaxSupply);

    /**
     * @dev Revert with an error when attempting to set the provenance
     *      hash after the mint has started.
     */
    error ProvenanceHashCannotBeSetAfterMintStarted();

    /**
     * @dev Revert if the royalty basis points is greater than 10_000.
     */
    error InvalidRoyaltyBasisPoints(uint256 basisPoints);

    /**
     * @dev Revert if the royalty address is being set to the zero address.
     */
    error RoyaltyAddressCannotBeZeroAddress();

    /**
     * @dev Emit an event for token metadata reveals/updates,
     *      according to EIP-4906.
     *
     * @param _fromTokenId The start token id.
     * @param _toTokenId   The end token id.
     */
    event BatchMetadataUpdate(uint256 _fromTokenId, uint256 _toTokenId);

    /**
     * @dev Emit an event when the URI for the collection-level metadata
     *      is updated.
     */
    event ContractURIUpdated(string newContractURI);

    /**
     * @dev Emit an event when the max token supply is updated.
     */
    event MaxSupplyUpdated(uint256 newMaxSupply);

    /**
     * @dev Emit an event with the previous and new provenance hash after
     *      being updated.
     */
    event ProvenanceHashUpdated(bytes32 previousHash, bytes32 newHash);

    /**
     * @dev Emit an event when the royalties info is updated.
     */
    event RoyaltyInfoUpdated(address receiver, uint256 bps);

    /**
     * @notice A struct defining royalty info for the contract.
     */
    struct RoyaltyInfo {
        address royaltyAddress;
        uint96 royaltyBps;
    }

    /**
     * @notice Sets the base URI for the token metadata and emits an event.
     *
     * @param tokenURI The new base URI to set.
     */
    function setBaseURI(string calldata tokenURI) external;

    /**
     * @notice Sets the contract URI for contract metadata.
     *
     * @param newContractURI The new contract URI.
     */
    function setContractURI(string calldata newContractURI) external;

    /**
     * @notice Sets the max supply and emits an event.
     *
     * @param newMaxSupply The new max supply to set.
     */
    function setMaxSupply(uint256 newMaxSupply) external;

    /**
     * @notice Sets the provenance hash and emits an event.
     *
     *         The provenance hash is used for random reveals, which
     *         is a hash of the ordered metadata to show it has not been
     *         modified after mint started.
     *
     *         This function will revert after the first item has been minted.
     *
     * @param newProvenanceHash The new provenance hash to set.
     */
    function setProvenanceHash(bytes32 newProvenanceHash) external;

    /**
     * @notice Sets the address and basis points for royalties.
     *
     * @param newInfo The struct to configure royalties.
     */
    function setRoyaltyInfo(RoyaltyInfo calldata newInfo) external;

    /**
     * @notice Returns the base URI for token metadata.
     */
    function baseURI() external view returns (string memory);

    /**
     * @notice Returns the contract URI.
     */
    function contractURI() external view returns (string memory);

    /**
     * @notice Returns the max token supply.
     */
    function maxSupply() external view returns (uint256);

    /**
     * @notice Returns the provenance hash.
     *         The provenance hash is used for random reveals, which
     *         is a hash of the ordered metadata to show it is unmodified
     *         after mint has started.
     */
    function provenanceHash() external view returns (bytes32);

    /**
     * @notice Returns the address that receives royalties.
     */
    function royaltyAddress() external view returns (address);

    /**
     * @notice Returns the royalty basis points out of 10_000.
     */
    function royaltyBasisPoints() external view returns (uint256);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

library DarkEnergyPackedStruct {
    // =============================================================
    //                            Structs
    // =============================================================

    /// @dev All 256 bits from a PlayerData (from right to left)
    struct PlayerData {
        bool isHolder;
        int40 energyAmount;
        uint16 gamePasses;
        uint16 mintCount;
        uint16 mergeCount;
        uint16 noRiskPlayCount;
        uint16 noRiskWinCount;
        uint16 highStakesPlayCount;
        uint16 highStakesWinCount;
        uint16 highStakesLossCount;
        uint32 totalEarned;
        uint32 totalRugged;
        uint16 unused;
        bool flagA;
        bool flagB;
        bool flagC;
        bool flagD;
        bool flagE;
        bool flagF;
        bool flagG;
    }

    /// @dev All 256 bits from a GameRules (from right to left)
    struct GameRules {
        bool isActive;
        uint16 oddsNoRiskEarn100;
        uint16 oddsNoRiskEarn300;
        uint16 oddsNoRiskEarn500;
        uint16 oddsHighStakesWinOrdinal;
        uint16 oddsHighStakesLose100;
        uint16 oddsHighStakesLose300;
        uint16 oddsHighStakesLose500;
        uint16 oddsHighStakesLose1000;
        uint16 oddsHighStakesEarn100;
        uint16 oddsHighStakesEarn300;
        uint16 oddsHighStakesEarn500;
        uint16 oddsHighStakesEarn1000;
        uint16 oddsHighStakesDoubles;
        uint16 oddsHighStakesHalves;
        uint16 oddsGamePassOnMint;
        uint8 remainingOrdinals;
        bool flagA;
        bool flagB;
        bool flagC;
        bool flagD;
        bool flagE;
        bool flagF;
        bool flagG;
    }

    // =============================================================
    //                 Unpacking by type and offset
    // =============================================================

    /**
     * @dev unpack bit [offset] (bool)
     */
    function getBool(bytes32 p, uint8 offset) internal pure returns (bool r) {
        assembly {
            r := and(shr(offset, p), 1)
        }
    }

    /**
     * @dev unpack bits [offset..offset + 8]
     */
    function getUint8(bytes32 p, uint8 offset) internal pure returns (uint8 r) {
        assembly {
            r := and(shr(offset, p), 0xFF)
        }
    }

    /**
     * @dev unpack bits [offset..offset + 16]
     */
    function getUint16(
        bytes32 p,
        uint8 offset
    ) internal pure returns (uint16 r) {
        assembly {
            r := and(shr(offset, p), 0xFFFF)
        }
    }

    /**
     * @dev unpack bits [offset..offset + 32]
     */
    function getUint32(
        bytes32 p,
        uint8 offset
    ) internal pure returns (uint32 r) {
        assembly {
            r := and(shr(offset, p), 0xFFFFFFFF)
        }
    }

    /**
     * @dev unpack bits[offset..offset + 40]
     */
    function getInt40(bytes32 p, uint8 offset) internal pure returns (int40 r) {
        assembly {
            r := and(shr(offset, p), 0xFFFFFFFFFF)
        }
    }

    // =============================================================
    //                    Unpacking whole structs
    // =============================================================

    function playerData(bytes32 p) internal pure returns (PlayerData memory r) {
        return
            PlayerData({
                isHolder: getBool(p, 0),
                energyAmount: getInt40(p, 1),
                gamePasses: getUint16(p, 41),
                mintCount: getUint16(p, 57),
                mergeCount: getUint16(p, 73),
                noRiskPlayCount: getUint16(p, 89),
                noRiskWinCount: getUint16(p, 105),
                highStakesPlayCount: getUint16(p, 121),
                highStakesWinCount: getUint16(p, 137),
                highStakesLossCount: getUint16(p, 153),
                totalEarned: getUint32(p, 169),
                totalRugged: getUint32(p, 201),
                unused: getUint16(p, 169),
                flagA: getBool(p, 249),
                flagB: getBool(p, 250),
                flagC: getBool(p, 251),
                flagD: getBool(p, 252),
                flagE: getBool(p, 253),
                flagF: getBool(p, 254),
                flagG: getBool(p, 255)
        });
    }

    function gameRules(bytes32 p) internal pure returns (GameRules memory r) {
        return
            GameRules({
                isActive: getBool(p, 0),
                oddsNoRiskEarn100: getUint16(p, 1),
                oddsNoRiskEarn300: getUint16(p, 17),
                oddsNoRiskEarn500: getUint16(p, 33),
                oddsHighStakesWinOrdinal: getUint16(p, 49),
                oddsHighStakesLose100: getUint16(p, 65),
                oddsHighStakesLose300: getUint16(p, 81),
                oddsHighStakesLose500: getUint16(p, 97),
                oddsHighStakesLose1000: getUint16(p, 113),
                oddsHighStakesEarn100: getUint16(p, 129),
                oddsHighStakesEarn300: getUint16(p, 145),
                oddsHighStakesEarn500: getUint16(p, 161),
                oddsHighStakesEarn1000: getUint16(p, 177),
                oddsHighStakesDoubles: getUint16(p, 193),
                oddsHighStakesHalves: getUint16(p, 209),
                oddsGamePassOnMint: getUint16(p, 225),
                remainingOrdinals: getUint8(p, 241),
                flagA: getBool(p, 249),
                flagB: getBool(p, 250),
                flagC: getBool(p, 251),
                flagD: getBool(p, 252),
                flagE: getBool(p, 253),
                flagF: getBool(p, 254),
                flagG: getBool(p, 255)
            });
    }

    // =============================================================
    //                         Setting Bits
    // =============================================================

    /**
     * @dev set bit [{offset}] to {value}
     */
    function setBit(
        bytes32 p,
        uint8 offset,
        bool value
    ) internal pure returns (bytes32 np) {
        assembly {
            np := or(
                and(
                    p,
                    xor(
                        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF,
                        shl(offset, 1)
                    )
                ),
                shl(offset, value)
            )
        }
    }

    /**
     * @dev set 8 bits to {value} at [{offset}]
     */
    function setUint8(
        bytes32 p,
        uint8 offset,
        uint8 value
    ) internal pure returns (bytes32 np) {
        assembly {
            np := or(
                and(
                    p,
                    xor(
                        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF,
                        shl(offset, 0xFF)
                    )
                ),
                shl(offset, and(value, 0xFF))
            )
        }
    }

    /**
     * @dev set 16 bits to {value} at [{offset}]
     */
    function setUint16(
        bytes32 p,
        uint8 offset,
        uint16 value
    ) internal pure returns (bytes32 np) {
        assembly {
            np := or(
                and(
                    p,
                    xor(
                        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF,
                        shl(offset, 0xFFFF)
                    )
                ),
                shl(offset, and(value, 0xFFFF))
            )
        }
    }

    /**
     * @dev set 32 bits to {value} at [{offset}]
     */
    function setUint32(
        bytes32 p,
        uint8 offset,
        uint32 value
    ) internal pure returns (bytes32 np) {
        assembly {
            np := or(
                and(
                    p,
                    xor(
                        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF,
                        shl(offset, 0xFFFFFFFF)
                    )
                ),
                shl(offset, and(value, 0xFFFFFFFF))
            )
        }
    }

    /**
     * @dev set 40 bits to {value} at [{offset}]
     */
    function setInt40(
        bytes32 p,
        uint8 offset,
        int40 value
    ) internal pure returns (bytes32 np) {
        assembly {
            np := or(
                and(
                    p,
                    xor(
                        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF,
                        shl(offset, 0xFFFFFFFFFF)
                    )
                ),
                shl(offset, and(value, 0xFFFFFFFFFF))
            )
        }
    }

    // =============================================================
    //                         DarkEnergy-specific
    // =============================================================

    /**
     * @dev get _playerData.isHolder
     */
    function isHolder(bytes32 p) internal pure returns (bool) {
        return getBool(p, 0);
    }

    /**
     * @dev get _playerData.energyAmount
     */
    function getEnergy(bytes32 p) internal pure returns (int40) {
        return getInt40(p, 1);
    }

    /**
     * @dev get _playerData.gamePasses
     */
    function getGamePasses(bytes32 p) internal pure returns (uint16) {
        return getUint16(p, 41);
    }

    /**
     * @dev get _playerData.mintCount
     */
    function getMintCount(bytes32 p) internal pure returns (uint16) {
        return getUint16(p, 57);
    }

    /**
     * @dev get _playerData.mergeCount
     */
    function getMergeCount(bytes32 p) internal pure returns (uint16) {
        return getUint16(p, 73);
    }

    /**
     * @dev get _playerData.noRiskPlayCount
     */
    function getNoRiskPlayCount(bytes32 p) internal pure returns (uint16) {
        return getUint16(p, 89);
    }

    /**
     * @dev get _playerData.noRiskWinCount
     */
    function getNoRiskWinCount(bytes32 p) internal pure returns (uint16) {
        return getUint16(p, 105);
    }

    /**
     * @dev get _playerData.highStakesPlayCount
     */
    function getHighStakesPlayCount(bytes32 p) internal pure returns (uint16) {
        return getUint16(p, 121);
    }

    /**
     * @dev get _playerData.highStakesWinCount
     */
    function getHighStakesWinCount(bytes32 p) internal pure returns (uint16) {
        return getUint16(p, 137);
    }

    /**
     * @dev get _playerData.highStakesLossCount
     */
    function getHighStakesLossCount(bytes32 p) internal pure returns (uint16) {
        return getUint16(p, 153);
    }

    /**
     * @dev get _playerData.totalEarned
     */
    function getTotalEarned(bytes32 p) internal pure returns (uint32) {
        return getUint32(p, 169);
    }

    /**
     * @dev get _playerData.totalRugged
     */
    function getTotalRugged(bytes32 p) internal pure returns (uint32) {
        return getUint32(p, 201);
    }

    /**
     * @dev sets _playerData.isHolder
     */
    function setHolder(bytes32 p, bool status) internal pure returns (bytes32 np) {
        return setBit(p, 0, status);
    }

    /**
     * @dev sets _playerData.energyAmount
     */
    function setEnergy(bytes32 p, int40 value) internal pure returns (bytes32 np) {
        return setInt40(p, 1, value);
    }

    /**
     * @dev sets _playerData.gamePasses
     */
    function setGamePasses(bytes32 p, uint16 value) internal pure returns (bytes32 np) {
        return setUint16(p, 41, value);
    }

    /**
     * @dev sets _playerData.mintCount
     */
    function setMintCount(bytes32 p, uint16 value) internal pure returns (bytes32 np) {
        return setUint16(p, 57, value);
    }

    /**
     * @dev sets _playerData.mergeCount
     */
    function setMergeCount(bytes32 p, uint16 value) internal pure returns (bytes32 np) {
        return setUint16(p, 73, value);
    }

    /**
     * @dev sets _playerData.noRiskPlayCount
     */
    function setNoRiskPlayCount(bytes32 p, uint16 value) internal pure returns (bytes32 np) {
        return setUint16(p, 89, value);
    }

    /**
     * @dev sets _playerData.noRiskWinCount
     */
    function setNoRiskWinCount(bytes32 p, uint16 value) internal pure returns (bytes32 np) {
        return setUint16(p, 105, value);
    }

    /**
     * @dev sets _playerData.highStakesPlayCount
     */
    function setHighStakesPlayCount(bytes32 p, uint16 value) internal pure returns (bytes32 np) {
        return setUint16(p, 121, value);
    }

    /**
     * @dev sets _playerData.highStakesWinCount
     */
    function setHighStakesWinCount(bytes32 p, uint16 value) internal pure returns (bytes32 np) {
        return setUint16(p, 137, value);
    }

    /**
     * @dev sets _playerData.highStakesLossCount
     */
    function setHighStakesLossCount(bytes32 p, uint16 value) internal pure returns (bytes32 np) {
        return setUint16(p, 153, value);
    }

    /**
     * @dev sets _playerData.totalEarned
     */
    function setTotalEarned(bytes32 p, uint32 value) internal pure returns (bytes32 np) {
        return setUint32(p, 169, value);
    }

    /**
     * @dev sets _playerData.totalRugged
     */
    function setTotalRugged(bytes32 p, uint32 value) internal pure returns (bytes32 np) {
        return setUint32(p, 201, value);
    }

    /**
     * @dev Clears the last 57 bits (isHolder, energyAmount, gamePasses)
     */
    function clearHoldingData(bytes32 p) internal pure returns (bytes32 np) {
        assembly {
            np := and(
                p,
                0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE00000000000000
            )
        }
    }

    /**
     * @dev Replace the last 57 bits (isHolder, energyAmount, gamePasses) from
     *      another packed bytes variable (to be used for transfers)
     */
    function setHoldingData(
        bytes32 p,
        bytes32 q
    ) internal pure returns (bytes32 np) {
        assembly {
            np := or(
                and(
                    p,
                    0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE00000000000000
                ),
                and(q, 0x1FFFFFFFFFFFFFF)
            )
        }
    }

    /**
     * @dev tight-pack a GameRules struct into a uint256
     */
    function packGameRules(
        GameRules calldata
    ) internal pure returns (bytes32 result) {
        assembly {
            result := calldataload(4)
            result := or(result, shl(1, calldataload(36)))
            result := or(result, shl(17, calldataload(68)))
            result := or(result, shl(33, calldataload(100)))
            result := or(result, shl(49, calldataload(132)))
            result := or(result, shl(65, calldataload(164)))
            result := or(result, shl(81, calldataload(196)))
            result := or(result, shl(97, calldataload(228)))
            result := or(result, shl(113, calldataload(260)))
            result := or(result, shl(129, calldataload(292)))
            result := or(result, shl(145, calldataload(324)))
            result := or(result, shl(161, calldataload(356)))
            result := or(result, shl(177, calldataload(388)))
            result := or(result, shl(193, calldataload(420)))
            result := or(result, shl(209, calldataload(452)))
            result := or(result, shl(225, calldataload(484)))
            result := or(result, shl(241, calldataload(516)))
            result := or(result, shl(249, calldataload(548)))
            result := or(result, shl(250, calldataload(580)))
            result := or(result, shl(251, calldataload(612)))
            result := or(result, shl(252, calldataload(644)))
            result := or(result, shl(253, calldataload(676)))
            result := or(result, shl(254, calldataload(708)))
            result := or(result, shl(255, calldataload(740)))
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Strings.sol)
// Added support for int256

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/Math.sol";

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `int256` to its ASCII `string` decimal representation.
     */
    function toString(int256 value) internal pure returns (string memory) {
        if (value >= 0) {
            return toString(uint256(value));
        }
        return
            string(
                abi.encodePacked(
                    "-",
                    toString(uint256(-value))
                )
            );
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(
        uint256 value,
        uint256 length
    ) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

library UriEncode {
    string internal constant _TABLE = "0123456789abcdef";

    function uriEncode(
        string memory uri
    ) internal pure returns (string memory) {
        bytes memory bytesUri = bytes(uri);

        string memory table = _TABLE;

        // Max size is worse case all chars need to be encoded
        bytes memory result = new bytes(3 * bytesUri.length);

        /// @solidity memory-safe-assembly
        assembly {
            // Get the lookup table
            let tablePtr := add(table, 1)

            // Prepare result pointer, jump over length
            let resultPtr := add(result, 32)

            // Keep track of the final result size string length
            let resultSize := 0

            for {
                let dataPtr := bytesUri
                let endPtr := add(bytesUri, mload(bytesUri))
            } lt(dataPtr, endPtr) {

            } {
                // advance 1 byte
                dataPtr := add(dataPtr, 1)
                // bytemask out a char
                let char := and(mload(dataPtr), 255)

                // Check if is valid URI character
                let isInvalidUriChar := or(
                    or(
                        lt(char, 33), // lower than "!"
                        gt(char, 122) // higher than "z"
                    ),
                    or(
                        or(
                            eq(char, 37), // "%"
                            or(
                                eq(char, 60), // "<"
                                eq(char, 62) // ">"
                            )
                        ),
                        or(
                            and(gt(char, 90), lt(char, 95)), // "[\]^"
                            eq(char, 96) // "`"
                        )
                    )
                )
                if eq(char, 35) { isInvalidUriChar := 1 }

                switch isInvalidUriChar
                // If is valid uri character copy character over and increment the result
                case 0 {
                    mstore8(resultPtr, char)
                    resultPtr := add(resultPtr, 1)
                    resultSize := add(resultSize, 1)
                }
                // If the char is not a valid uri character, uriencode the character
                case 1 {
                    mstore8(resultPtr, 37)
                    resultPtr := add(resultPtr, 1)
                    // table[character >> 4] (take the last 4 bits)
                    mstore8(resultPtr, mload(add(tablePtr, shr(4, char))))
                    resultPtr := add(resultPtr, 1)
                    // table & 15 (take the first 4 bits)
                    mstore8(resultPtr, mload(add(tablePtr, and(char, 15))))
                    resultPtr := add(resultPtr, 1)
                    resultSize := add(resultSize, 3)
                }
            }

            // Set size of result string in memory
            mstore(result, resultSize)
        }

        return string(result);
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "../libraries/DarkEnergyPackedStruct.sol";

contract OwnableAndAdministrable {
    using DarkEnergyPackedStruct for bytes32;

    error MissingRole(address user, uint256 role);
    error NotOwner(address user);

    event OwnershipTransferred(address indexed user, address indexed newOwner);
    event RoleUpdated(address indexed user, uint256 indexed role, bool indexed status);

    /**
     * @dev There is a maximum of 256 roles: each bit says if the role is on or off
     */
    mapping(address => bytes32) private _addressRoles;

    /**
     * @dev There is one owner
     */
    address internal _owner;

    function _isOwner(address sender) internal view returns(bool) {
        return (sender == _owner || sender == address(this));
    }

    function _hasRole(address sender, uint8 role) internal view returns(bool) {
        bytes32 roles = _addressRoles[sender];
        return roles.getBool(role);
    }

    function _checkOwner(address sender) internal virtual view {
        if (!_isOwner(sender)) {
            revert NotOwner(sender);
        }
    }

    function _checkRoleOrOwner(address sender, uint8 role) internal virtual view {
        if (_isOwner(sender)) return;
        _checkRole(sender, role);
    }

    function _checkRole(address sender, uint8 role) internal virtual view {
        if (sender == address(this)) return;
        bytes32 roles = _addressRoles[sender];
        bool allowed = roles.getBool(role);
        if (!allowed) {
            revert MissingRole(sender, role);
        }
    }

    function _setOwner(address newOwner) internal virtual {
        _owner = newOwner;
        emit OwnershipTransferred(_owner, newOwner);
    }

    function _setRole(address user, uint8 role, bool status) internal virtual {
        _addressRoles[user] = _addressRoles[user].setBit(role, status);
        emit RoleUpdated(user, role, status);
    }

    function setRole(address user, uint8 role, bool status) external virtual {
        _checkOwner(msg.sender);
        _setRole(user, role, status);
    }

    function transferOwnership(address newOwner) external virtual {
        _checkOwner(msg.sender);
        _setOwner(newOwner);
    }

    function owner() external virtual view returns(address) {
        return _owner;
    }
}