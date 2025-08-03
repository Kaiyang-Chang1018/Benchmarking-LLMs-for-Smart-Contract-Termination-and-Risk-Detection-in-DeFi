// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
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
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
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
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.20;

import {IERC165} from "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC-721 compliant contract.
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
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC-721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or
     *   {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC-721
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
    function transferFrom(address from, address to, uint256 tokenId) external;

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
     * - The `operator` cannot be the address zero.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool approved) external;

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
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.20;

import {IERC721} from "../IERC721.sol";

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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/introspection/IERC165.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC-165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[ERC].
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
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[ERC section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

// Common.sol
//
// Common mathematical functions used in both SD59x18 and UD60x18. Note that these global functions do not
// always operate with SD59x18 and UD60x18 numbers.

/*//////////////////////////////////////////////////////////////////////////
                                CUSTOM ERRORS
//////////////////////////////////////////////////////////////////////////*/

/// @notice Thrown when the resultant value in {mulDiv} overflows uint256.
error PRBMath_MulDiv_Overflow(uint256 x, uint256 y, uint256 denominator);

/// @notice Thrown when the resultant value in {mulDiv18} overflows uint256.
error PRBMath_MulDiv18_Overflow(uint256 x, uint256 y);

/// @notice Thrown when one of the inputs passed to {mulDivSigned} is `type(int256).min`.
error PRBMath_MulDivSigned_InputTooSmall();

/// @notice Thrown when the resultant value in {mulDivSigned} overflows int256.
error PRBMath_MulDivSigned_Overflow(int256 x, int256 y);

/*//////////////////////////////////////////////////////////////////////////
                                    CONSTANTS
//////////////////////////////////////////////////////////////////////////*/

/// @dev The maximum value a uint128 number can have.
uint128 constant MAX_UINT128 = type(uint128).max;

/// @dev The maximum value a uint40 number can have.
uint40 constant MAX_UINT40 = type(uint40).max;

/// @dev The maximum value a uint64 number can have.
uint64 constant MAX_UINT64 = type(uint64).max;

/// @dev The unit number, which the decimal precision of the fixed-point types.
uint256 constant UNIT = 1e18;

/// @dev The unit number inverted mod 2^256.
uint256 constant UNIT_INVERSE = 78156646155174841979727994598816262306175212592076161876661_508869554232690281;

/// @dev The the largest power of two that divides the decimal value of `UNIT`. The logarithm of this value is the least significant
/// bit in the binary representation of `UNIT`.
uint256 constant UNIT_LPOTD = 262144;

/*//////////////////////////////////////////////////////////////////////////
                                    FUNCTIONS
//////////////////////////////////////////////////////////////////////////*/

/// @notice Calculates the binary exponent of x using the binary fraction method.
/// @dev Has to use 192.64-bit fixed-point numbers. See https://ethereum.stackexchange.com/a/96594/24693.
/// @param x The exponent as an unsigned 192.64-bit fixed-point number.
/// @return result The result as an unsigned 60.18-decimal fixed-point number.
/// @custom:smtchecker abstract-function-nondet
function exp2(uint256 x) pure returns (uint256 result) {
    unchecked {
        // Start from 0.5 in the 192.64-bit fixed-point format.
        result = 0x800000000000000000000000000000000000000000000000;

        // The following logic multiplies the result by $\sqrt{2^{-i}}$ when the bit at position i is 1. Key points:
        //
        // 1. Intermediate results will not overflow, as the starting point is 2^191 and all magic factors are under 2^65.
        // 2. The rationale for organizing the if statements into groups of 8 is gas savings. If the result of performing
        // a bitwise AND operation between x and any value in the array [0x80; 0x40; 0x20; 0x10; 0x08; 0x04; 0x02; 0x01] is 1,
        // we know that `x & 0xFF` is also 1.
        if (x & 0xFF00000000000000 > 0) {
            if (x & 0x8000000000000000 > 0) {
                result = (result * 0x16A09E667F3BCC909) >> 64;
            }
            if (x & 0x4000000000000000 > 0) {
                result = (result * 0x1306FE0A31B7152DF) >> 64;
            }
            if (x & 0x2000000000000000 > 0) {
                result = (result * 0x1172B83C7D517ADCE) >> 64;
            }
            if (x & 0x1000000000000000 > 0) {
                result = (result * 0x10B5586CF9890F62A) >> 64;
            }
            if (x & 0x800000000000000 > 0) {
                result = (result * 0x1059B0D31585743AE) >> 64;
            }
            if (x & 0x400000000000000 > 0) {
                result = (result * 0x102C9A3E778060EE7) >> 64;
            }
            if (x & 0x200000000000000 > 0) {
                result = (result * 0x10163DA9FB33356D8) >> 64;
            }
            if (x & 0x100000000000000 > 0) {
                result = (result * 0x100B1AFA5ABCBED61) >> 64;
            }
        }

        if (x & 0xFF000000000000 > 0) {
            if (x & 0x80000000000000 > 0) {
                result = (result * 0x10058C86DA1C09EA2) >> 64;
            }
            if (x & 0x40000000000000 > 0) {
                result = (result * 0x1002C605E2E8CEC50) >> 64;
            }
            if (x & 0x20000000000000 > 0) {
                result = (result * 0x100162F3904051FA1) >> 64;
            }
            if (x & 0x10000000000000 > 0) {
                result = (result * 0x1000B175EFFDC76BA) >> 64;
            }
            if (x & 0x8000000000000 > 0) {
                result = (result * 0x100058BA01FB9F96D) >> 64;
            }
            if (x & 0x4000000000000 > 0) {
                result = (result * 0x10002C5CC37DA9492) >> 64;
            }
            if (x & 0x2000000000000 > 0) {
                result = (result * 0x1000162E525EE0547) >> 64;
            }
            if (x & 0x1000000000000 > 0) {
                result = (result * 0x10000B17255775C04) >> 64;
            }
        }

        if (x & 0xFF0000000000 > 0) {
            if (x & 0x800000000000 > 0) {
                result = (result * 0x1000058B91B5BC9AE) >> 64;
            }
            if (x & 0x400000000000 > 0) {
                result = (result * 0x100002C5C89D5EC6D) >> 64;
            }
            if (x & 0x200000000000 > 0) {
                result = (result * 0x10000162E43F4F831) >> 64;
            }
            if (x & 0x100000000000 > 0) {
                result = (result * 0x100000B1721BCFC9A) >> 64;
            }
            if (x & 0x80000000000 > 0) {
                result = (result * 0x10000058B90CF1E6E) >> 64;
            }
            if (x & 0x40000000000 > 0) {
                result = (result * 0x1000002C5C863B73F) >> 64;
            }
            if (x & 0x20000000000 > 0) {
                result = (result * 0x100000162E430E5A2) >> 64;
            }
            if (x & 0x10000000000 > 0) {
                result = (result * 0x1000000B172183551) >> 64;
            }
        }

        if (x & 0xFF00000000 > 0) {
            if (x & 0x8000000000 > 0) {
                result = (result * 0x100000058B90C0B49) >> 64;
            }
            if (x & 0x4000000000 > 0) {
                result = (result * 0x10000002C5C8601CC) >> 64;
            }
            if (x & 0x2000000000 > 0) {
                result = (result * 0x1000000162E42FFF0) >> 64;
            }
            if (x & 0x1000000000 > 0) {
                result = (result * 0x10000000B17217FBB) >> 64;
            }
            if (x & 0x800000000 > 0) {
                result = (result * 0x1000000058B90BFCE) >> 64;
            }
            if (x & 0x400000000 > 0) {
                result = (result * 0x100000002C5C85FE3) >> 64;
            }
            if (x & 0x200000000 > 0) {
                result = (result * 0x10000000162E42FF1) >> 64;
            }
            if (x & 0x100000000 > 0) {
                result = (result * 0x100000000B17217F8) >> 64;
            }
        }

        if (x & 0xFF000000 > 0) {
            if (x & 0x80000000 > 0) {
                result = (result * 0x10000000058B90BFC) >> 64;
            }
            if (x & 0x40000000 > 0) {
                result = (result * 0x1000000002C5C85FE) >> 64;
            }
            if (x & 0x20000000 > 0) {
                result = (result * 0x100000000162E42FF) >> 64;
            }
            if (x & 0x10000000 > 0) {
                result = (result * 0x1000000000B17217F) >> 64;
            }
            if (x & 0x8000000 > 0) {
                result = (result * 0x100000000058B90C0) >> 64;
            }
            if (x & 0x4000000 > 0) {
                result = (result * 0x10000000002C5C860) >> 64;
            }
            if (x & 0x2000000 > 0) {
                result = (result * 0x1000000000162E430) >> 64;
            }
            if (x & 0x1000000 > 0) {
                result = (result * 0x10000000000B17218) >> 64;
            }
        }

        if (x & 0xFF0000 > 0) {
            if (x & 0x800000 > 0) {
                result = (result * 0x1000000000058B90C) >> 64;
            }
            if (x & 0x400000 > 0) {
                result = (result * 0x100000000002C5C86) >> 64;
            }
            if (x & 0x200000 > 0) {
                result = (result * 0x10000000000162E43) >> 64;
            }
            if (x & 0x100000 > 0) {
                result = (result * 0x100000000000B1721) >> 64;
            }
            if (x & 0x80000 > 0) {
                result = (result * 0x10000000000058B91) >> 64;
            }
            if (x & 0x40000 > 0) {
                result = (result * 0x1000000000002C5C8) >> 64;
            }
            if (x & 0x20000 > 0) {
                result = (result * 0x100000000000162E4) >> 64;
            }
            if (x & 0x10000 > 0) {
                result = (result * 0x1000000000000B172) >> 64;
            }
        }

        if (x & 0xFF00 > 0) {
            if (x & 0x8000 > 0) {
                result = (result * 0x100000000000058B9) >> 64;
            }
            if (x & 0x4000 > 0) {
                result = (result * 0x10000000000002C5D) >> 64;
            }
            if (x & 0x2000 > 0) {
                result = (result * 0x1000000000000162E) >> 64;
            }
            if (x & 0x1000 > 0) {
                result = (result * 0x10000000000000B17) >> 64;
            }
            if (x & 0x800 > 0) {
                result = (result * 0x1000000000000058C) >> 64;
            }
            if (x & 0x400 > 0) {
                result = (result * 0x100000000000002C6) >> 64;
            }
            if (x & 0x200 > 0) {
                result = (result * 0x10000000000000163) >> 64;
            }
            if (x & 0x100 > 0) {
                result = (result * 0x100000000000000B1) >> 64;
            }
        }

        if (x & 0xFF > 0) {
            if (x & 0x80 > 0) {
                result = (result * 0x10000000000000059) >> 64;
            }
            if (x & 0x40 > 0) {
                result = (result * 0x1000000000000002C) >> 64;
            }
            if (x & 0x20 > 0) {
                result = (result * 0x10000000000000016) >> 64;
            }
            if (x & 0x10 > 0) {
                result = (result * 0x1000000000000000B) >> 64;
            }
            if (x & 0x8 > 0) {
                result = (result * 0x10000000000000006) >> 64;
            }
            if (x & 0x4 > 0) {
                result = (result * 0x10000000000000003) >> 64;
            }
            if (x & 0x2 > 0) {
                result = (result * 0x10000000000000001) >> 64;
            }
            if (x & 0x1 > 0) {
                result = (result * 0x10000000000000001) >> 64;
            }
        }

        // In the code snippet below, two operations are executed simultaneously:
        //
        // 1. The result is multiplied by $(2^n + 1)$, where $2^n$ represents the integer part, and the additional 1
        // accounts for the initial guess of 0.5. This is achieved by subtracting from 191 instead of 192.
        // 2. The result is then converted to an unsigned 60.18-decimal fixed-point format.
        //
        // The underlying logic is based on the relationship $2^{191-ip} = 2^{ip} / 2^{191}$, where $ip$ denotes the,
        // integer part, $2^n$.
        result *= UNIT;
        result >>= (191 - (x >> 64));
    }
}

/// @notice Finds the zero-based index of the first 1 in the binary representation of x.
///
/// @dev See the note on "msb" in this Wikipedia article: https://en.wikipedia.org/wiki/Find_first_set
///
/// Each step in this implementation is equivalent to this high-level code:
///
/// ```solidity
/// if (x >= 2 ** 128) {
///     x >>= 128;
///     result += 128;
/// }
/// ```
///
/// Where 128 is replaced with each respective power of two factor. See the full high-level implementation here:
/// https://gist.github.com/PaulRBerg/f932f8693f2733e30c4d479e8e980948
///
/// The Yul instructions used below are:
///
/// - "gt" is "greater than"
/// - "or" is the OR bitwise operator
/// - "shl" is "shift left"
/// - "shr" is "shift right"
///
/// @param x The uint256 number for which to find the index of the most significant bit.
/// @return result The index of the most significant bit as a uint256.
/// @custom:smtchecker abstract-function-nondet
function msb(uint256 x) pure returns (uint256 result) {
    // 2^128
    assembly ("memory-safe") {
        let factor := shl(7, gt(x, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF))
        x := shr(factor, x)
        result := or(result, factor)
    }
    // 2^64
    assembly ("memory-safe") {
        let factor := shl(6, gt(x, 0xFFFFFFFFFFFFFFFF))
        x := shr(factor, x)
        result := or(result, factor)
    }
    // 2^32
    assembly ("memory-safe") {
        let factor := shl(5, gt(x, 0xFFFFFFFF))
        x := shr(factor, x)
        result := or(result, factor)
    }
    // 2^16
    assembly ("memory-safe") {
        let factor := shl(4, gt(x, 0xFFFF))
        x := shr(factor, x)
        result := or(result, factor)
    }
    // 2^8
    assembly ("memory-safe") {
        let factor := shl(3, gt(x, 0xFF))
        x := shr(factor, x)
        result := or(result, factor)
    }
    // 2^4
    assembly ("memory-safe") {
        let factor := shl(2, gt(x, 0xF))
        x := shr(factor, x)
        result := or(result, factor)
    }
    // 2^2
    assembly ("memory-safe") {
        let factor := shl(1, gt(x, 0x3))
        x := shr(factor, x)
        result := or(result, factor)
    }
    // 2^1
    // No need to shift x any more.
    assembly ("memory-safe") {
        let factor := gt(x, 0x1)
        result := or(result, factor)
    }
}

/// @notice Calculates x*y÷denominator with 512-bit precision.
///
/// @dev Credits to Remco Bloemen under MIT license https://xn--2-umb.com/21/muldiv.
///
/// Notes:
/// - The result is rounded toward zero.
///
/// Requirements:
/// - The denominator must not be zero.
/// - The result must fit in uint256.
///
/// @param x The multiplicand as a uint256.
/// @param y The multiplier as a uint256.
/// @param denominator The divisor as a uint256.
/// @return result The result as a uint256.
/// @custom:smtchecker abstract-function-nondet
function mulDiv(uint256 x, uint256 y, uint256 denominator) pure returns (uint256 result) {
    // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
    // use the Chinese Remainder Theorem to reconstruct the 512-bit result. The result is stored in two 256
    // variables such that product = prod1 * 2^256 + prod0.
    uint256 prod0; // Least significant 256 bits of the product
    uint256 prod1; // Most significant 256 bits of the product
    assembly ("memory-safe") {
        let mm := mulmod(x, y, not(0))
        prod0 := mul(x, y)
        prod1 := sub(sub(mm, prod0), lt(mm, prod0))
    }

    // Handle non-overflow cases, 256 by 256 division.
    if (prod1 == 0) {
        unchecked {
            return prod0 / denominator;
        }
    }

    // Make sure the result is less than 2^256. Also prevents denominator == 0.
    if (prod1 >= denominator) {
        revert PRBMath_MulDiv_Overflow(x, y, denominator);
    }

    ////////////////////////////////////////////////////////////////////////////
    // 512 by 256 division
    ////////////////////////////////////////////////////////////////////////////

    // Make division exact by subtracting the remainder from [prod1 prod0].
    uint256 remainder;
    assembly ("memory-safe") {
        // Compute remainder using the mulmod Yul instruction.
        remainder := mulmod(x, y, denominator)

        // Subtract 256 bit number from 512-bit number.
        prod1 := sub(prod1, gt(remainder, prod0))
        prod0 := sub(prod0, remainder)
    }

    unchecked {
        // Calculate the largest power of two divisor of the denominator using the unary operator ~. This operation cannot overflow
        // because the denominator cannot be zero at this point in the function execution. The result is always >= 1.
        // For more detail, see https://cs.stackexchange.com/q/138556/92363.
        uint256 lpotdod = denominator & (~denominator + 1);
        uint256 flippedLpotdod;

        assembly ("memory-safe") {
            // Factor powers of two out of denominator.
            denominator := div(denominator, lpotdod)

            // Divide [prod1 prod0] by lpotdod.
            prod0 := div(prod0, lpotdod)

            // Get the flipped value `2^256 / lpotdod`. If the `lpotdod` is zero, the flipped value is one.
            // `sub(0, lpotdod)` produces the two's complement version of `lpotdod`, which is equivalent to flipping all the bits.
            // However, `div` interprets this value as an unsigned value: https://ethereum.stackexchange.com/q/147168/24693
            flippedLpotdod := add(div(sub(0, lpotdod), lpotdod), 1)
        }

        // Shift in bits from prod1 into prod0.
        prod0 |= prod1 * flippedLpotdod;

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
    }
}

/// @notice Calculates x*y÷1e18 with 512-bit precision.
///
/// @dev A variant of {mulDiv} with constant folding, i.e. in which the denominator is hard coded to 1e18.
///
/// Notes:
/// - The body is purposely left uncommented; to understand how this works, see the documentation in {mulDiv}.
/// - The result is rounded toward zero.
/// - We take as an axiom that the result cannot be `MAX_UINT256` when x and y solve the following system of equations:
///
/// $$
/// \begin{cases}
///     x * y = MAX\_UINT256 * UNIT \\
///     (x * y) \% UNIT \geq \frac{UNIT}{2}
/// \end{cases}
/// $$
///
/// Requirements:
/// - Refer to the requirements in {mulDiv}.
/// - The result must fit in uint256.
///
/// @param x The multiplicand as an unsigned 60.18-decimal fixed-point number.
/// @param y The multiplier as an unsigned 60.18-decimal fixed-point number.
/// @return result The result as an unsigned 60.18-decimal fixed-point number.
/// @custom:smtchecker abstract-function-nondet
function mulDiv18(uint256 x, uint256 y) pure returns (uint256 result) {
    uint256 prod0;
    uint256 prod1;
    assembly ("memory-safe") {
        let mm := mulmod(x, y, not(0))
        prod0 := mul(x, y)
        prod1 := sub(sub(mm, prod0), lt(mm, prod0))
    }

    if (prod1 == 0) {
        unchecked {
            return prod0 / UNIT;
        }
    }

    if (prod1 >= UNIT) {
        revert PRBMath_MulDiv18_Overflow(x, y);
    }

    uint256 remainder;
    assembly ("memory-safe") {
        remainder := mulmod(x, y, UNIT)
        result :=
            mul(
                or(
                    div(sub(prod0, remainder), UNIT_LPOTD),
                    mul(sub(prod1, gt(remainder, prod0)), add(div(sub(0, UNIT_LPOTD), UNIT_LPOTD), 1))
                ),
                UNIT_INVERSE
            )
    }
}

/// @notice Calculates x*y÷denominator with 512-bit precision.
///
/// @dev This is an extension of {mulDiv} for signed numbers, which works by computing the signs and the absolute values separately.
///
/// Notes:
/// - The result is rounded toward zero.
///
/// Requirements:
/// - Refer to the requirements in {mulDiv}.
/// - None of the inputs can be `type(int256).min`.
/// - The result must fit in int256.
///
/// @param x The multiplicand as an int256.
/// @param y The multiplier as an int256.
/// @param denominator The divisor as an int256.
/// @return result The result as an int256.
/// @custom:smtchecker abstract-function-nondet
function mulDivSigned(int256 x, int256 y, int256 denominator) pure returns (int256 result) {
    if (x == type(int256).min || y == type(int256).min || denominator == type(int256).min) {
        revert PRBMath_MulDivSigned_InputTooSmall();
    }

    // Get hold of the absolute values of x, y and the denominator.
    uint256 xAbs;
    uint256 yAbs;
    uint256 dAbs;
    unchecked {
        xAbs = x < 0 ? uint256(-x) : uint256(x);
        yAbs = y < 0 ? uint256(-y) : uint256(y);
        dAbs = denominator < 0 ? uint256(-denominator) : uint256(denominator);
    }

    // Compute the absolute value of x*y÷denominator. The result must fit in int256.
    uint256 resultAbs = mulDiv(xAbs, yAbs, dAbs);
    if (resultAbs > uint256(type(int256).max)) {
        revert PRBMath_MulDivSigned_Overflow(x, y);
    }

    // Get the signs of x, y and the denominator.
    uint256 sx;
    uint256 sy;
    uint256 sd;
    assembly ("memory-safe") {
        // "sgt" is the "signed greater than" assembly instruction and "sub(0,1)" is -1 in two's complement.
        sx := sgt(x, sub(0, 1))
        sy := sgt(y, sub(0, 1))
        sd := sgt(denominator, sub(0, 1))
    }

    // XOR over sx, sy and sd. What this does is to check whether there are 1 or 3 negative signs in the inputs.
    // If there are, the result should be negative. Otherwise, it should be positive.
    unchecked {
        result = sx ^ sy ^ sd == 0 ? -int256(resultAbs) : int256(resultAbs);
    }
}

/// @notice Calculates the square root of x using the Babylonian method.
///
/// @dev See https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method.
///
/// Notes:
/// - If x is not a perfect square, the result is rounded down.
/// - Credits to OpenZeppelin for the explanations in comments below.
///
/// @param x The uint256 number for which to calculate the square root.
/// @return result The result as a uint256.
/// @custom:smtchecker abstract-function-nondet
function sqrt(uint256 x) pure returns (uint256 result) {
    if (x == 0) {
        return 0;
    }

    // For our first guess, we calculate the biggest power of 2 which is smaller than the square root of x.
    //
    // We know that the "msb" (most significant bit) of x is a power of 2 such that we have:
    //
    // $$
    // msb(x) <= x <= 2*msb(x)$
    // $$
    //
    // We write $msb(x)$ as $2^k$, and we get:
    //
    // $$
    // k = log_2(x)
    // $$
    //
    // Thus, we can write the initial inequality as:
    //
    // $$
    // 2^{log_2(x)} <= x <= 2*2^{log_2(x)+1} \\
    // sqrt(2^k) <= sqrt(x) < sqrt(2^{k+1}) \\
    // 2^{k/2} <= sqrt(x) < 2^{(k+1)/2} <= 2^{(k/2)+1}
    // $$
    //
    // Consequently, $2^{log_2(x) /2} is a good first approximation of sqrt(x) with at least one correct bit.
    uint256 xAux = uint256(x);
    result = 1;
    if (xAux >= 2 ** 128) {
        xAux >>= 128;
        result <<= 64;
    }
    if (xAux >= 2 ** 64) {
        xAux >>= 64;
        result <<= 32;
    }
    if (xAux >= 2 ** 32) {
        xAux >>= 32;
        result <<= 16;
    }
    if (xAux >= 2 ** 16) {
        xAux >>= 16;
        result <<= 8;
    }
    if (xAux >= 2 ** 8) {
        xAux >>= 8;
        result <<= 4;
    }
    if (xAux >= 2 ** 4) {
        xAux >>= 4;
        result <<= 2;
    }
    if (xAux >= 2 ** 2) {
        result <<= 1;
    }

    // At this point, `result` is an estimation with at least one bit of precision. We know the true value has at
    // most 128 bits, since it is the square root of a uint256. Newton's method converges quadratically (precision
    // doubles at every iteration). We thus need at most 7 iteration to turn our partial result with one bit of
    // precision into the expected uint128 result.
    unchecked {
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;

        // If x is not a perfect square, round the result toward zero.
        uint256 roundedResult = x / result;
        if (result >= roundedResult) {
            result = roundedResult;
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

/*

██████╗ ██████╗ ██████╗ ███╗   ███╗ █████╗ ████████╗██╗  ██╗
██╔══██╗██╔══██╗██╔══██╗████╗ ████║██╔══██╗╚══██╔══╝██║  ██║
██████╔╝██████╔╝██████╔╝██╔████╔██║███████║   ██║   ███████║
██╔═══╝ ██╔══██╗██╔══██╗██║╚██╔╝██║██╔══██║   ██║   ██╔══██║
██║     ██║  ██║██████╔╝██║ ╚═╝ ██║██║  ██║   ██║   ██║  ██║
╚═╝     ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝

██╗   ██╗██████╗ ██████╗ ██╗  ██╗ ██╗ █████╗
██║   ██║██╔══██╗╚════██╗╚██╗██╔╝███║██╔══██╗
██║   ██║██║  ██║ █████╔╝ ╚███╔╝ ╚██║╚█████╔╝
██║   ██║██║  ██║██╔═══╝  ██╔██╗  ██║██╔══██╗
╚██████╔╝██████╔╝███████╗██╔╝ ██╗ ██║╚█████╔╝
 ╚═════╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═╝ ╚════╝

*/

import "./ud2x18/Casting.sol";
import "./ud2x18/Constants.sol";
import "./ud2x18/Errors.sol";
import "./ud2x18/ValueType.sol";
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

/*

██████╗ ██████╗ ██████╗ ███╗   ███╗ █████╗ ████████╗██╗  ██╗
██╔══██╗██╔══██╗██╔══██╗████╗ ████║██╔══██╗╚══██╔══╝██║  ██║
██████╔╝██████╔╝██████╔╝██╔████╔██║███████║   ██║   ███████║
██╔═══╝ ██╔══██╗██╔══██╗██║╚██╔╝██║██╔══██║   ██║   ██╔══██║
██║     ██║  ██║██████╔╝██║ ╚═╝ ██║██║  ██║   ██║   ██║  ██║
╚═╝     ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝

██╗   ██╗██████╗  ██████╗  ██████╗ ██╗  ██╗ ██╗ █████╗
██║   ██║██╔══██╗██╔════╝ ██╔═████╗╚██╗██╔╝███║██╔══██╗
██║   ██║██║  ██║███████╗ ██║██╔██║ ╚███╔╝ ╚██║╚█████╔╝
██║   ██║██║  ██║██╔═══██╗████╔╝██║ ██╔██╗  ██║██╔══██╗
╚██████╔╝██████╔╝╚██████╔╝╚██████╔╝██╔╝ ██╗ ██║╚█████╔╝
 ╚═════╝ ╚═════╝  ╚═════╝  ╚═════╝ ╚═╝  ╚═╝ ╚═╝ ╚════╝

*/

import "./ud60x18/Casting.sol";
import "./ud60x18/Constants.sol";
import "./ud60x18/Conversions.sol";
import "./ud60x18/Errors.sol";
import "./ud60x18/Helpers.sol";
import "./ud60x18/Math.sol";
import "./ud60x18/ValueType.sol";
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "../Common.sol" as Common;
import "./Errors.sol" as CastingErrors;
import { SD59x18 } from "../sd59x18/ValueType.sol";
import { UD60x18 } from "../ud60x18/ValueType.sol";
import { SD1x18 } from "./ValueType.sol";

/// @notice Casts an SD1x18 number into SD59x18.
/// @dev There is no overflow check because SD1x18 ⊆ SD59x18.
function intoSD59x18(SD1x18 x) pure returns (SD59x18 result) {
    result = SD59x18.wrap(int256(SD1x18.unwrap(x)));
}

/// @notice Casts an SD1x18 number into UD60x18.
/// @dev Requirements:
/// - x ≥ 0
function intoUD60x18(SD1x18 x) pure returns (UD60x18 result) {
    int64 xInt = SD1x18.unwrap(x);
    if (xInt < 0) {
        revert CastingErrors.PRBMath_SD1x18_ToUD60x18_Underflow(x);
    }
    result = UD60x18.wrap(uint64(xInt));
}

/// @notice Casts an SD1x18 number into uint128.
/// @dev Requirements:
/// - x ≥ 0
function intoUint128(SD1x18 x) pure returns (uint128 result) {
    int64 xInt = SD1x18.unwrap(x);
    if (xInt < 0) {
        revert CastingErrors.PRBMath_SD1x18_ToUint128_Underflow(x);
    }
    result = uint128(uint64(xInt));
}

/// @notice Casts an SD1x18 number into uint256.
/// @dev Requirements:
/// - x ≥ 0
function intoUint256(SD1x18 x) pure returns (uint256 result) {
    int64 xInt = SD1x18.unwrap(x);
    if (xInt < 0) {
        revert CastingErrors.PRBMath_SD1x18_ToUint256_Underflow(x);
    }
    result = uint256(uint64(xInt));
}

/// @notice Casts an SD1x18 number into uint40.
/// @dev Requirements:
/// - x ≥ 0
/// - x ≤ MAX_UINT40
function intoUint40(SD1x18 x) pure returns (uint40 result) {
    int64 xInt = SD1x18.unwrap(x);
    if (xInt < 0) {
        revert CastingErrors.PRBMath_SD1x18_ToUint40_Underflow(x);
    }
    if (xInt > int64(uint64(Common.MAX_UINT40))) {
        revert CastingErrors.PRBMath_SD1x18_ToUint40_Overflow(x);
    }
    result = uint40(uint64(xInt));
}

/// @notice Alias for {wrap}.
function sd1x18(int64 x) pure returns (SD1x18 result) {
    result = SD1x18.wrap(x);
}

/// @notice Unwraps an SD1x18 number into int64.
function unwrap(SD1x18 x) pure returns (int64 result) {
    result = SD1x18.unwrap(x);
}

/// @notice Wraps an int64 number into SD1x18.
function wrap(int64 x) pure returns (SD1x18 result) {
    result = SD1x18.wrap(x);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { SD1x18 } from "./ValueType.sol";

/// @dev Euler's number as an SD1x18 number.
SD1x18 constant E = SD1x18.wrap(2_718281828459045235);

/// @dev The maximum value an SD1x18 number can have.
int64 constant uMAX_SD1x18 = 9_223372036854775807;
SD1x18 constant MAX_SD1x18 = SD1x18.wrap(uMAX_SD1x18);

/// @dev The minimum value an SD1x18 number can have.
int64 constant uMIN_SD1x18 = -9_223372036854775808;
SD1x18 constant MIN_SD1x18 = SD1x18.wrap(uMIN_SD1x18);

/// @dev PI as an SD1x18 number.
SD1x18 constant PI = SD1x18.wrap(3_141592653589793238);

/// @dev The unit number, which gives the decimal precision of SD1x18.
SD1x18 constant UNIT = SD1x18.wrap(1e18);
int64 constant uUNIT = 1e18;
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { SD1x18 } from "./ValueType.sol";

/// @notice Thrown when trying to cast an SD1x18 number that doesn't fit in UD60x18.
error PRBMath_SD1x18_ToUD60x18_Underflow(SD1x18 x);

/// @notice Thrown when trying to cast an SD1x18 number that doesn't fit in uint128.
error PRBMath_SD1x18_ToUint128_Underflow(SD1x18 x);

/// @notice Thrown when trying to cast an SD1x18 number that doesn't fit in uint256.
error PRBMath_SD1x18_ToUint256_Underflow(SD1x18 x);

/// @notice Thrown when trying to cast an SD1x18 number that doesn't fit in uint40.
error PRBMath_SD1x18_ToUint40_Overflow(SD1x18 x);

/// @notice Thrown when trying to cast an SD1x18 number that doesn't fit in uint40.
error PRBMath_SD1x18_ToUint40_Underflow(SD1x18 x);
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "./Casting.sol" as Casting;

/// @notice The signed 1.18-decimal fixed-point number representation, which can have up to 1 digit and up to 18
/// decimals. The values of this are bound by the minimum and the maximum values permitted by the underlying Solidity
/// type int64. This is useful when end users want to use int64 to save gas, e.g. with tight variable packing in contract
/// storage.
type SD1x18 is int64;

/*//////////////////////////////////////////////////////////////////////////
                                    CASTING
//////////////////////////////////////////////////////////////////////////*/

using {
    Casting.intoSD59x18,
    Casting.intoUD60x18,
    Casting.intoUint128,
    Casting.intoUint256,
    Casting.intoUint40,
    Casting.unwrap
} for SD1x18 global;
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "../Common.sol" as Common;
import "./Errors.sol" as CastingErrors;
import { SD59x18 } from "../sd59x18/ValueType.sol";
import { UD60x18 } from "../ud60x18/ValueType.sol";
import { SD21x18 } from "./ValueType.sol";

/// @notice Casts an SD21x18 number into SD59x18.
/// @dev There is no overflow check because SD21x18 ⊆ SD59x18.
function intoSD59x18(SD21x18 x) pure returns (SD59x18 result) {
    result = SD59x18.wrap(int256(SD21x18.unwrap(x)));
}

/// @notice Casts an SD21x18 number into UD60x18.
/// @dev Requirements:
/// - x ≥ 0
function intoUD60x18(SD21x18 x) pure returns (UD60x18 result) {
    int128 xInt = SD21x18.unwrap(x);
    if (xInt < 0) {
        revert CastingErrors.PRBMath_SD21x18_ToUD60x18_Underflow(x);
    }
    result = UD60x18.wrap(uint128(xInt));
}

/// @notice Casts an SD21x18 number into uint128.
/// @dev Requirements:
/// - x ≥ 0
function intoUint128(SD21x18 x) pure returns (uint128 result) {
    int128 xInt = SD21x18.unwrap(x);
    if (xInt < 0) {
        revert CastingErrors.PRBMath_SD21x18_ToUint128_Underflow(x);
    }
    result = uint128(xInt);
}

/// @notice Casts an SD21x18 number into uint256.
/// @dev Requirements:
/// - x ≥ 0
function intoUint256(SD21x18 x) pure returns (uint256 result) {
    int128 xInt = SD21x18.unwrap(x);
    if (xInt < 0) {
        revert CastingErrors.PRBMath_SD21x18_ToUint256_Underflow(x);
    }
    result = uint256(uint128(xInt));
}

/// @notice Casts an SD21x18 number into uint40.
/// @dev Requirements:
/// - x ≥ 0
/// - x ≤ MAX_UINT40
function intoUint40(SD21x18 x) pure returns (uint40 result) {
    int128 xInt = SD21x18.unwrap(x);
    if (xInt < 0) {
        revert CastingErrors.PRBMath_SD21x18_ToUint40_Underflow(x);
    }
    if (xInt > int128(uint128(Common.MAX_UINT40))) {
        revert CastingErrors.PRBMath_SD21x18_ToUint40_Overflow(x);
    }
    result = uint40(uint128(xInt));
}

/// @notice Alias for {wrap}.
function sd21x18(int128 x) pure returns (SD21x18 result) {
    result = SD21x18.wrap(x);
}

/// @notice Unwraps an SD21x18 number into int128.
function unwrap(SD21x18 x) pure returns (int128 result) {
    result = SD21x18.unwrap(x);
}

/// @notice Wraps an int128 number into SD21x18.
function wrap(int128 x) pure returns (SD21x18 result) {
    result = SD21x18.wrap(x);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { SD21x18 } from "./ValueType.sol";

/// @dev Euler's number as an SD21x18 number.
SD21x18 constant E = SD21x18.wrap(2_718281828459045235);

/// @dev The maximum value an SD21x18 number can have.
int128 constant uMAX_SD21x18 = 170141183460469231731_687303715884105727;
SD21x18 constant MAX_SD21x18 = SD21x18.wrap(uMAX_SD21x18);

/// @dev The minimum value an SD21x18 number can have.
int128 constant uMIN_SD21x18 = -170141183460469231731_687303715884105728;
SD21x18 constant MIN_SD21x18 = SD21x18.wrap(uMIN_SD21x18);

/// @dev PI as an SD21x18 number.
SD21x18 constant PI = SD21x18.wrap(3_141592653589793238);

/// @dev The unit number, which gives the decimal precision of SD21x18.
SD21x18 constant UNIT = SD21x18.wrap(1e18);
int128 constant uUNIT = 1e18;
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { SD21x18 } from "./ValueType.sol";

/// @notice Thrown when trying to cast an SD21x18 number that doesn't fit in uint128.
error PRBMath_SD21x18_ToUint128_Underflow(SD21x18 x);

/// @notice Thrown when trying to cast an SD21x18 number that doesn't fit in UD60x18.
error PRBMath_SD21x18_ToUD60x18_Underflow(SD21x18 x);

/// @notice Thrown when trying to cast an SD21x18 number that doesn't fit in uint256.
error PRBMath_SD21x18_ToUint256_Underflow(SD21x18 x);

/// @notice Thrown when trying to cast an SD21x18 number that doesn't fit in uint40.
error PRBMath_SD21x18_ToUint40_Overflow(SD21x18 x);

/// @notice Thrown when trying to cast an SD21x18 number that doesn't fit in uint40.
error PRBMath_SD21x18_ToUint40_Underflow(SD21x18 x);
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "./Casting.sol" as Casting;

/// @notice The signed 21.18-decimal fixed-point number representation, which can have up to 21 digits and up to 18
/// decimals. The values of this are bound by the minimum and the maximum values permitted by the underlying Solidity
/// type int128. This is useful when end users want to use int128 to save gas, e.g. with tight variable packing in contract
/// storage.
type SD21x18 is int128;

/*//////////////////////////////////////////////////////////////////////////
                                    CASTING
//////////////////////////////////////////////////////////////////////////*/

using {
    Casting.intoSD59x18,
    Casting.intoUD60x18,
    Casting.intoUint128,
    Casting.intoUint256,
    Casting.intoUint40,
    Casting.unwrap
} for SD21x18 global;
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "./Errors.sol" as CastingErrors;
import { MAX_UINT128, MAX_UINT40 } from "../Common.sol";
import { uMAX_SD1x18, uMIN_SD1x18 } from "../sd1x18/Constants.sol";
import { SD1x18 } from "../sd1x18/ValueType.sol";
import { uMAX_SD21x18, uMIN_SD21x18 } from "../sd21x18/Constants.sol";
import { SD21x18 } from "../sd21x18/ValueType.sol";
import { uMAX_UD2x18 } from "../ud2x18/Constants.sol";
import { UD2x18 } from "../ud2x18/ValueType.sol";
import { uMAX_UD21x18 } from "../ud21x18/Constants.sol";
import { UD21x18 } from "../ud21x18/ValueType.sol";
import { UD60x18 } from "../ud60x18/ValueType.sol";
import { SD59x18 } from "./ValueType.sol";

/// @notice Casts an SD59x18 number into int256.
/// @dev This is basically a functional alias for {unwrap}.
function intoInt256(SD59x18 x) pure returns (int256 result) {
    result = SD59x18.unwrap(x);
}

/// @notice Casts an SD59x18 number into SD1x18.
/// @dev Requirements:
/// - x ≥ uMIN_SD1x18
/// - x ≤ uMAX_SD1x18
function intoSD1x18(SD59x18 x) pure returns (SD1x18 result) {
    int256 xInt = SD59x18.unwrap(x);
    if (xInt < uMIN_SD1x18) {
        revert CastingErrors.PRBMath_SD59x18_IntoSD1x18_Underflow(x);
    }
    if (xInt > uMAX_SD1x18) {
        revert CastingErrors.PRBMath_SD59x18_IntoSD1x18_Overflow(x);
    }
    result = SD1x18.wrap(int64(xInt));
}

/// @notice Casts an SD59x18 number into SD21x18.
/// @dev Requirements:
/// - x ≥ uMIN_SD21x18
/// - x ≤ uMAX_SD21x18
function intoSD21x18(SD59x18 x) pure returns (SD21x18 result) {
    int256 xInt = SD59x18.unwrap(x);
    if (xInt < uMIN_SD21x18) {
        revert CastingErrors.PRBMath_SD59x18_IntoSD21x18_Underflow(x);
    }
    if (xInt > uMAX_SD21x18) {
        revert CastingErrors.PRBMath_SD59x18_IntoSD21x18_Overflow(x);
    }
    result = SD21x18.wrap(int128(xInt));
}

/// @notice Casts an SD59x18 number into UD2x18.
/// @dev Requirements:
/// - x ≥ 0
/// - x ≤ uMAX_UD2x18
function intoUD2x18(SD59x18 x) pure returns (UD2x18 result) {
    int256 xInt = SD59x18.unwrap(x);
    if (xInt < 0) {
        revert CastingErrors.PRBMath_SD59x18_IntoUD2x18_Underflow(x);
    }
    if (xInt > int256(uint256(uMAX_UD2x18))) {
        revert CastingErrors.PRBMath_SD59x18_IntoUD2x18_Overflow(x);
    }
    result = UD2x18.wrap(uint64(uint256(xInt)));
}

/// @notice Casts an SD59x18 number into UD21x18.
/// @dev Requirements:
/// - x ≥ 0
/// - x ≤ uMAX_UD21x18
function intoUD21x18(SD59x18 x) pure returns (UD21x18 result) {
    int256 xInt = SD59x18.unwrap(x);
    if (xInt < 0) {
        revert CastingErrors.PRBMath_SD59x18_IntoUD21x18_Underflow(x);
    }
    if (xInt > int256(uint256(uMAX_UD21x18))) {
        revert CastingErrors.PRBMath_SD59x18_IntoUD21x18_Overflow(x);
    }
    result = UD21x18.wrap(uint128(uint256(xInt)));
}

/// @notice Casts an SD59x18 number into UD60x18.
/// @dev Requirements:
/// - x ≥ 0
function intoUD60x18(SD59x18 x) pure returns (UD60x18 result) {
    int256 xInt = SD59x18.unwrap(x);
    if (xInt < 0) {
        revert CastingErrors.PRBMath_SD59x18_IntoUD60x18_Underflow(x);
    }
    result = UD60x18.wrap(uint256(xInt));
}

/// @notice Casts an SD59x18 number into uint256.
/// @dev Requirements:
/// - x ≥ 0
function intoUint256(SD59x18 x) pure returns (uint256 result) {
    int256 xInt = SD59x18.unwrap(x);
    if (xInt < 0) {
        revert CastingErrors.PRBMath_SD59x18_IntoUint256_Underflow(x);
    }
    result = uint256(xInt);
}

/// @notice Casts an SD59x18 number into uint128.
/// @dev Requirements:
/// - x ≥ 0
/// - x ≤ uMAX_UINT128
function intoUint128(SD59x18 x) pure returns (uint128 result) {
    int256 xInt = SD59x18.unwrap(x);
    if (xInt < 0) {
        revert CastingErrors.PRBMath_SD59x18_IntoUint128_Underflow(x);
    }
    if (xInt > int256(uint256(MAX_UINT128))) {
        revert CastingErrors.PRBMath_SD59x18_IntoUint128_Overflow(x);
    }
    result = uint128(uint256(xInt));
}

/// @notice Casts an SD59x18 number into uint40.
/// @dev Requirements:
/// - x ≥ 0
/// - x ≤ MAX_UINT40
function intoUint40(SD59x18 x) pure returns (uint40 result) {
    int256 xInt = SD59x18.unwrap(x);
    if (xInt < 0) {
        revert CastingErrors.PRBMath_SD59x18_IntoUint40_Underflow(x);
    }
    if (xInt > int256(uint256(MAX_UINT40))) {
        revert CastingErrors.PRBMath_SD59x18_IntoUint40_Overflow(x);
    }
    result = uint40(uint256(xInt));
}

/// @notice Alias for {wrap}.
function sd(int256 x) pure returns (SD59x18 result) {
    result = SD59x18.wrap(x);
}

/// @notice Alias for {wrap}.
function sd59x18(int256 x) pure returns (SD59x18 result) {
    result = SD59x18.wrap(x);
}

/// @notice Unwraps an SD59x18 number into int256.
function unwrap(SD59x18 x) pure returns (int256 result) {
    result = SD59x18.unwrap(x);
}

/// @notice Wraps an int256 number into SD59x18.
function wrap(int256 x) pure returns (SD59x18 result) {
    result = SD59x18.wrap(x);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { SD59x18 } from "./ValueType.sol";

// NOTICE: the "u" prefix stands for "unwrapped".

/// @dev Euler's number as an SD59x18 number.
SD59x18 constant E = SD59x18.wrap(2_718281828459045235);

/// @dev The maximum input permitted in {exp}.
int256 constant uEXP_MAX_INPUT = 133_084258667509499440;
SD59x18 constant EXP_MAX_INPUT = SD59x18.wrap(uEXP_MAX_INPUT);

/// @dev Any value less than this returns 0 in {exp}.
int256 constant uEXP_MIN_THRESHOLD = -41_446531673892822322;
SD59x18 constant EXP_MIN_THRESHOLD = SD59x18.wrap(uEXP_MIN_THRESHOLD);

/// @dev The maximum input permitted in {exp2}.
int256 constant uEXP2_MAX_INPUT = 192e18 - 1;
SD59x18 constant EXP2_MAX_INPUT = SD59x18.wrap(uEXP2_MAX_INPUT);

/// @dev Any value less than this returns 0 in {exp2}.
int256 constant uEXP2_MIN_THRESHOLD = -59_794705707972522261;
SD59x18 constant EXP2_MIN_THRESHOLD = SD59x18.wrap(uEXP2_MIN_THRESHOLD);

/// @dev Half the UNIT number.
int256 constant uHALF_UNIT = 0.5e18;
SD59x18 constant HALF_UNIT = SD59x18.wrap(uHALF_UNIT);

/// @dev $log_2(10)$ as an SD59x18 number.
int256 constant uLOG2_10 = 3_321928094887362347;
SD59x18 constant LOG2_10 = SD59x18.wrap(uLOG2_10);

/// @dev $log_2(e)$ as an SD59x18 number.
int256 constant uLOG2_E = 1_442695040888963407;
SD59x18 constant LOG2_E = SD59x18.wrap(uLOG2_E);

/// @dev The maximum value an SD59x18 number can have.
int256 constant uMAX_SD59x18 = 57896044618658097711785492504343953926634992332820282019728_792003956564819967;
SD59x18 constant MAX_SD59x18 = SD59x18.wrap(uMAX_SD59x18);

/// @dev The maximum whole value an SD59x18 number can have.
int256 constant uMAX_WHOLE_SD59x18 = 57896044618658097711785492504343953926634992332820282019728_000000000000000000;
SD59x18 constant MAX_WHOLE_SD59x18 = SD59x18.wrap(uMAX_WHOLE_SD59x18);

/// @dev The minimum value an SD59x18 number can have.
int256 constant uMIN_SD59x18 = -57896044618658097711785492504343953926634992332820282019728_792003956564819968;
SD59x18 constant MIN_SD59x18 = SD59x18.wrap(uMIN_SD59x18);

/// @dev The minimum whole value an SD59x18 number can have.
int256 constant uMIN_WHOLE_SD59x18 = -57896044618658097711785492504343953926634992332820282019728_000000000000000000;
SD59x18 constant MIN_WHOLE_SD59x18 = SD59x18.wrap(uMIN_WHOLE_SD59x18);

/// @dev PI as an SD59x18 number.
SD59x18 constant PI = SD59x18.wrap(3_141592653589793238);

/// @dev The unit number, which gives the decimal precision of SD59x18.
int256 constant uUNIT = 1e18;
SD59x18 constant UNIT = SD59x18.wrap(1e18);

/// @dev The unit number squared.
int256 constant uUNIT_SQUARED = 1e36;
SD59x18 constant UNIT_SQUARED = SD59x18.wrap(uUNIT_SQUARED);

/// @dev Zero as an SD59x18 number.
SD59x18 constant ZERO = SD59x18.wrap(0);
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { SD59x18 } from "./ValueType.sol";

/// @notice Thrown when taking the absolute value of `MIN_SD59x18`.
error PRBMath_SD59x18_Abs_MinSD59x18();

/// @notice Thrown when ceiling a number overflows SD59x18.
error PRBMath_SD59x18_Ceil_Overflow(SD59x18 x);

/// @notice Thrown when converting a basic integer to the fixed-point format overflows SD59x18.
error PRBMath_SD59x18_Convert_Overflow(int256 x);

/// @notice Thrown when converting a basic integer to the fixed-point format underflows SD59x18.
error PRBMath_SD59x18_Convert_Underflow(int256 x);

/// @notice Thrown when dividing two numbers and one of them is `MIN_SD59x18`.
error PRBMath_SD59x18_Div_InputTooSmall();

/// @notice Thrown when dividing two numbers and one of the intermediary unsigned results overflows SD59x18.
error PRBMath_SD59x18_Div_Overflow(SD59x18 x, SD59x18 y);

/// @notice Thrown when taking the natural exponent of a base greater than 133_084258667509499441.
error PRBMath_SD59x18_Exp_InputTooBig(SD59x18 x);

/// @notice Thrown when taking the binary exponent of a base greater than 192e18.
error PRBMath_SD59x18_Exp2_InputTooBig(SD59x18 x);

/// @notice Thrown when flooring a number underflows SD59x18.
error PRBMath_SD59x18_Floor_Underflow(SD59x18 x);

/// @notice Thrown when taking the geometric mean of two numbers and their product is negative.
error PRBMath_SD59x18_Gm_NegativeProduct(SD59x18 x, SD59x18 y);

/// @notice Thrown when taking the geometric mean of two numbers and multiplying them overflows SD59x18.
error PRBMath_SD59x18_Gm_Overflow(SD59x18 x, SD59x18 y);

/// @notice Thrown when trying to cast an SD59x18 number that doesn't fit in SD1x18.
error PRBMath_SD59x18_IntoSD1x18_Overflow(SD59x18 x);

/// @notice Thrown when trying to cast an SD59x18 number that doesn't fit in SD1x18.
error PRBMath_SD59x18_IntoSD1x18_Underflow(SD59x18 x);

/// @notice Thrown when trying to cast an SD59x18 number that doesn't fit in SD21x18.
error PRBMath_SD59x18_IntoSD21x18_Overflow(SD59x18 x);

/// @notice Thrown when trying to cast an SD59x18 number that doesn't fit in SD21x18.
error PRBMath_SD59x18_IntoSD21x18_Underflow(SD59x18 x);

/// @notice Thrown when trying to cast an SD59x18 number that doesn't fit in UD2x18.
error PRBMath_SD59x18_IntoUD2x18_Overflow(SD59x18 x);

/// @notice Thrown when trying to cast an SD59x18 number that doesn't fit in UD2x18.
error PRBMath_SD59x18_IntoUD2x18_Underflow(SD59x18 x);

/// @notice Thrown when trying to cast an SD59x18 number that doesn't fit in UD21x18.
error PRBMath_SD59x18_IntoUD21x18_Overflow(SD59x18 x);

/// @notice Thrown when trying to cast an SD59x18 number that doesn't fit in UD21x18.
error PRBMath_SD59x18_IntoUD21x18_Underflow(SD59x18 x);

/// @notice Thrown when trying to cast an SD59x18 number that doesn't fit in UD60x18.
error PRBMath_SD59x18_IntoUD60x18_Underflow(SD59x18 x);

/// @notice Thrown when trying to cast an SD59x18 number that doesn't fit in uint128.
error PRBMath_SD59x18_IntoUint128_Overflow(SD59x18 x);

/// @notice Thrown when trying to cast an SD59x18 number that doesn't fit in uint128.
error PRBMath_SD59x18_IntoUint128_Underflow(SD59x18 x);

/// @notice Thrown when trying to cast an SD59x18 number that doesn't fit in uint256.
error PRBMath_SD59x18_IntoUint256_Underflow(SD59x18 x);

/// @notice Thrown when trying to cast an SD59x18 number that doesn't fit in uint40.
error PRBMath_SD59x18_IntoUint40_Overflow(SD59x18 x);

/// @notice Thrown when trying to cast an SD59x18 number that doesn't fit in uint40.
error PRBMath_SD59x18_IntoUint40_Underflow(SD59x18 x);

/// @notice Thrown when taking the logarithm of a number less than or equal to zero.
error PRBMath_SD59x18_Log_InputTooSmall(SD59x18 x);

/// @notice Thrown when multiplying two numbers and one of the inputs is `MIN_SD59x18`.
error PRBMath_SD59x18_Mul_InputTooSmall();

/// @notice Thrown when multiplying two numbers and the intermediary absolute result overflows SD59x18.
error PRBMath_SD59x18_Mul_Overflow(SD59x18 x, SD59x18 y);

/// @notice Thrown when raising a number to a power and the intermediary absolute result overflows SD59x18.
error PRBMath_SD59x18_Powu_Overflow(SD59x18 x, uint256 y);

/// @notice Thrown when taking the square root of a negative number.
error PRBMath_SD59x18_Sqrt_NegativeInput(SD59x18 x);

/// @notice Thrown when the calculating the square root overflows SD59x18.
error PRBMath_SD59x18_Sqrt_Overflow(SD59x18 x);
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { wrap } from "./Casting.sol";
import { SD59x18 } from "./ValueType.sol";

/// @notice Implements the checked addition operation (+) in the SD59x18 type.
function add(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    return wrap(x.unwrap() + y.unwrap());
}

/// @notice Implements the AND (&) bitwise operation in the SD59x18 type.
function and(SD59x18 x, int256 bits) pure returns (SD59x18 result) {
    return wrap(x.unwrap() & bits);
}

/// @notice Implements the AND (&) bitwise operation in the SD59x18 type.
function and2(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    return wrap(x.unwrap() & y.unwrap());
}

/// @notice Implements the equal (=) operation in the SD59x18 type.
function eq(SD59x18 x, SD59x18 y) pure returns (bool result) {
    result = x.unwrap() == y.unwrap();
}

/// @notice Implements the greater than operation (>) in the SD59x18 type.
function gt(SD59x18 x, SD59x18 y) pure returns (bool result) {
    result = x.unwrap() > y.unwrap();
}

/// @notice Implements the greater than or equal to operation (>=) in the SD59x18 type.
function gte(SD59x18 x, SD59x18 y) pure returns (bool result) {
    result = x.unwrap() >= y.unwrap();
}

/// @notice Implements a zero comparison check function in the SD59x18 type.
function isZero(SD59x18 x) pure returns (bool result) {
    result = x.unwrap() == 0;
}

/// @notice Implements the left shift operation (<<) in the SD59x18 type.
function lshift(SD59x18 x, uint256 bits) pure returns (SD59x18 result) {
    result = wrap(x.unwrap() << bits);
}

/// @notice Implements the lower than operation (<) in the SD59x18 type.
function lt(SD59x18 x, SD59x18 y) pure returns (bool result) {
    result = x.unwrap() < y.unwrap();
}

/// @notice Implements the lower than or equal to operation (<=) in the SD59x18 type.
function lte(SD59x18 x, SD59x18 y) pure returns (bool result) {
    result = x.unwrap() <= y.unwrap();
}

/// @notice Implements the unchecked modulo operation (%) in the SD59x18 type.
function mod(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    result = wrap(x.unwrap() % y.unwrap());
}

/// @notice Implements the not equal operation (!=) in the SD59x18 type.
function neq(SD59x18 x, SD59x18 y) pure returns (bool result) {
    result = x.unwrap() != y.unwrap();
}

/// @notice Implements the NOT (~) bitwise operation in the SD59x18 type.
function not(SD59x18 x) pure returns (SD59x18 result) {
    result = wrap(~x.unwrap());
}

/// @notice Implements the OR (|) bitwise operation in the SD59x18 type.
function or(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    result = wrap(x.unwrap() | y.unwrap());
}

/// @notice Implements the right shift operation (>>) in the SD59x18 type.
function rshift(SD59x18 x, uint256 bits) pure returns (SD59x18 result) {
    result = wrap(x.unwrap() >> bits);
}

/// @notice Implements the checked subtraction operation (-) in the SD59x18 type.
function sub(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    result = wrap(x.unwrap() - y.unwrap());
}

/// @notice Implements the checked unary minus operation (-) in the SD59x18 type.
function unary(SD59x18 x) pure returns (SD59x18 result) {
    result = wrap(-x.unwrap());
}

/// @notice Implements the unchecked addition operation (+) in the SD59x18 type.
function uncheckedAdd(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    unchecked {
        result = wrap(x.unwrap() + y.unwrap());
    }
}

/// @notice Implements the unchecked subtraction operation (-) in the SD59x18 type.
function uncheckedSub(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    unchecked {
        result = wrap(x.unwrap() - y.unwrap());
    }
}

/// @notice Implements the unchecked unary minus operation (-) in the SD59x18 type.
function uncheckedUnary(SD59x18 x) pure returns (SD59x18 result) {
    unchecked {
        result = wrap(-x.unwrap());
    }
}

/// @notice Implements the XOR (^) bitwise operation in the SD59x18 type.
function xor(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    result = wrap(x.unwrap() ^ y.unwrap());
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "../Common.sol" as Common;
import "./Errors.sol" as Errors;
import {
    uEXP_MAX_INPUT,
    uEXP2_MAX_INPUT,
    uEXP_MIN_THRESHOLD,
    uEXP2_MIN_THRESHOLD,
    uHALF_UNIT,
    uLOG2_10,
    uLOG2_E,
    uMAX_SD59x18,
    uMAX_WHOLE_SD59x18,
    uMIN_SD59x18,
    uMIN_WHOLE_SD59x18,
    UNIT,
    uUNIT,
    uUNIT_SQUARED,
    ZERO
} from "./Constants.sol";
import { wrap } from "./Helpers.sol";
import { SD59x18 } from "./ValueType.sol";

/// @notice Calculates the absolute value of x.
///
/// @dev Requirements:
/// - x > MIN_SD59x18.
///
/// @param x The SD59x18 number for which to calculate the absolute value.
/// @return result The absolute value of x as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function abs(SD59x18 x) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap();
    if (xInt == uMIN_SD59x18) {
        revert Errors.PRBMath_SD59x18_Abs_MinSD59x18();
    }
    result = xInt < 0 ? wrap(-xInt) : x;
}

/// @notice Calculates the arithmetic average of x and y.
///
/// @dev Notes:
/// - The result is rounded toward zero.
///
/// @param x The first operand as an SD59x18 number.
/// @param y The second operand as an SD59x18 number.
/// @return result The arithmetic average as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function avg(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap();
    int256 yInt = y.unwrap();

    unchecked {
        // This operation is equivalent to `x / 2 +  y / 2`, and it can never overflow.
        int256 sum = (xInt >> 1) + (yInt >> 1);

        if (sum < 0) {
            // If at least one of x and y is odd, add 1 to the result, because shifting negative numbers to the right
            // rounds toward negative infinity. The right part is equivalent to `sum + (x % 2 == 1 || y % 2 == 1)`.
            assembly ("memory-safe") {
                result := add(sum, and(or(xInt, yInt), 1))
            }
        } else {
            // Add 1 if both x and y are odd to account for the double 0.5 remainder truncated after shifting.
            result = wrap(sum + (xInt & yInt & 1));
        }
    }
}

/// @notice Yields the smallest whole number greater than or equal to x.
///
/// @dev Optimized for fractional value inputs, because every whole value has (1e18 - 1) fractional counterparts.
/// See https://en.wikipedia.org/wiki/Floor_and_ceiling_functions.
///
/// Requirements:
/// - x ≤ MAX_WHOLE_SD59x18
///
/// @param x The SD59x18 number to ceil.
/// @return result The smallest whole number greater than or equal to x, as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function ceil(SD59x18 x) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap();
    if (xInt > uMAX_WHOLE_SD59x18) {
        revert Errors.PRBMath_SD59x18_Ceil_Overflow(x);
    }

    int256 remainder = xInt % uUNIT;
    if (remainder == 0) {
        result = x;
    } else {
        unchecked {
            // Solidity uses C fmod style, which returns a modulus with the same sign as x.
            int256 resultInt = xInt - remainder;
            if (xInt > 0) {
                resultInt += uUNIT;
            }
            result = wrap(resultInt);
        }
    }
}

/// @notice Divides two SD59x18 numbers, returning a new SD59x18 number.
///
/// @dev This is an extension of {Common.mulDiv} for signed numbers, which works by computing the signs and the absolute
/// values separately.
///
/// Notes:
/// - Refer to the notes in {Common.mulDiv}.
/// - The result is rounded toward zero.
///
/// Requirements:
/// - Refer to the requirements in {Common.mulDiv}.
/// - None of the inputs can be `MIN_SD59x18`.
/// - The denominator must not be zero.
/// - The result must fit in SD59x18.
///
/// @param x The numerator as an SD59x18 number.
/// @param y The denominator as an SD59x18 number.
/// @return result The quotient as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function div(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap();
    int256 yInt = y.unwrap();
    if (xInt == uMIN_SD59x18 || yInt == uMIN_SD59x18) {
        revert Errors.PRBMath_SD59x18_Div_InputTooSmall();
    }

    // Get hold of the absolute values of x and y.
    uint256 xAbs;
    uint256 yAbs;
    unchecked {
        xAbs = xInt < 0 ? uint256(-xInt) : uint256(xInt);
        yAbs = yInt < 0 ? uint256(-yInt) : uint256(yInt);
    }

    // Compute the absolute value (x*UNIT÷y). The resulting value must fit in SD59x18.
    uint256 resultAbs = Common.mulDiv(xAbs, uint256(uUNIT), yAbs);
    if (resultAbs > uint256(uMAX_SD59x18)) {
        revert Errors.PRBMath_SD59x18_Div_Overflow(x, y);
    }

    // Check if x and y have the same sign using two's complement representation. The left-most bit represents the sign (1 for
    // negative, 0 for positive or zero).
    bool sameSign = (xInt ^ yInt) > -1;

    // If the inputs have the same sign, the result should be positive. Otherwise, it should be negative.
    unchecked {
        result = wrap(sameSign ? int256(resultAbs) : -int256(resultAbs));
    }
}

/// @notice Calculates the natural exponent of x using the following formula:
///
/// $$
/// e^x = 2^{x * log_2{e}}
/// $$
///
/// @dev Notes:
/// - Refer to the notes in {exp2}.
///
/// Requirements:
/// - Refer to the requirements in {exp2}.
/// - x < 133_084258667509499441.
///
/// @param x The exponent as an SD59x18 number.
/// @return result The result as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function exp(SD59x18 x) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap();

    // Any input less than the threshold returns zero.
    // This check also prevents an overflow for very small numbers.
    if (xInt < uEXP_MIN_THRESHOLD) {
        return ZERO;
    }

    // This check prevents values greater than 192e18 from being passed to {exp2}.
    if (xInt > uEXP_MAX_INPUT) {
        revert Errors.PRBMath_SD59x18_Exp_InputTooBig(x);
    }

    unchecked {
        // Inline the fixed-point multiplication to save gas.
        int256 doubleUnitProduct = xInt * uLOG2_E;
        result = exp2(wrap(doubleUnitProduct / uUNIT));
    }
}

/// @notice Calculates the binary exponent of x using the binary fraction method using the following formula:
///
/// $$
/// 2^{-x} = \frac{1}{2^x}
/// $$
///
/// @dev See https://ethereum.stackexchange.com/q/79903/24693.
///
/// Notes:
/// - If x < -59_794705707972522261, the result is zero.
///
/// Requirements:
/// - x < 192e18.
/// - The result must fit in SD59x18.
///
/// @param x The exponent as an SD59x18 number.
/// @return result The result as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function exp2(SD59x18 x) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap();
    if (xInt < 0) {
        // The inverse of any number less than the threshold is truncated to zero.
        if (xInt < uEXP2_MIN_THRESHOLD) {
            return ZERO;
        }

        unchecked {
            // Inline the fixed-point inversion to save gas.
            result = wrap(uUNIT_SQUARED / exp2(wrap(-xInt)).unwrap());
        }
    } else {
        // Numbers greater than or equal to 192e18 don't fit in the 192.64-bit format.
        if (xInt > uEXP2_MAX_INPUT) {
            revert Errors.PRBMath_SD59x18_Exp2_InputTooBig(x);
        }

        unchecked {
            // Convert x to the 192.64-bit fixed-point format.
            uint256 x_192x64 = uint256((xInt << 64) / uUNIT);

            // It is safe to cast the result to int256 due to the checks above.
            result = wrap(int256(Common.exp2(x_192x64)));
        }
    }
}

/// @notice Yields the greatest whole number less than or equal to x.
///
/// @dev Optimized for fractional value inputs, because for every whole value there are (1e18 - 1) fractional
/// counterparts. See https://en.wikipedia.org/wiki/Floor_and_ceiling_functions.
///
/// Requirements:
/// - x ≥ MIN_WHOLE_SD59x18
///
/// @param x The SD59x18 number to floor.
/// @return result The greatest whole number less than or equal to x, as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function floor(SD59x18 x) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap();
    if (xInt < uMIN_WHOLE_SD59x18) {
        revert Errors.PRBMath_SD59x18_Floor_Underflow(x);
    }

    int256 remainder = xInt % uUNIT;
    if (remainder == 0) {
        result = x;
    } else {
        unchecked {
            // Solidity uses C fmod style, which returns a modulus with the same sign as x.
            int256 resultInt = xInt - remainder;
            if (xInt < 0) {
                resultInt -= uUNIT;
            }
            result = wrap(resultInt);
        }
    }
}

/// @notice Yields the excess beyond the floor of x for positive numbers and the part of the number to the right.
/// of the radix point for negative numbers.
/// @dev Based on the odd function definition. https://en.wikipedia.org/wiki/Fractional_part
/// @param x The SD59x18 number to get the fractional part of.
/// @return result The fractional part of x as an SD59x18 number.
function frac(SD59x18 x) pure returns (SD59x18 result) {
    result = wrap(x.unwrap() % uUNIT);
}

/// @notice Calculates the geometric mean of x and y, i.e. $\sqrt{x * y}$.
///
/// @dev Notes:
/// - The result is rounded toward zero.
///
/// Requirements:
/// - x * y must fit in SD59x18.
/// - x * y must not be negative, since complex numbers are not supported.
///
/// @param x The first operand as an SD59x18 number.
/// @param y The second operand as an SD59x18 number.
/// @return result The result as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function gm(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap();
    int256 yInt = y.unwrap();
    if (xInt == 0 || yInt == 0) {
        return ZERO;
    }

    unchecked {
        // Equivalent to `xy / x != y`. Checking for overflow this way is faster than letting Solidity do it.
        int256 xyInt = xInt * yInt;
        if (xyInt / xInt != yInt) {
            revert Errors.PRBMath_SD59x18_Gm_Overflow(x, y);
        }

        // The product must not be negative, since complex numbers are not supported.
        if (xyInt < 0) {
            revert Errors.PRBMath_SD59x18_Gm_NegativeProduct(x, y);
        }

        // We don't need to multiply the result by `UNIT` here because the x*y product picked up a factor of `UNIT`
        // during multiplication. See the comments in {Common.sqrt}.
        uint256 resultUint = Common.sqrt(uint256(xyInt));
        result = wrap(int256(resultUint));
    }
}

/// @notice Calculates the inverse of x.
///
/// @dev Notes:
/// - The result is rounded toward zero.
///
/// Requirements:
/// - x must not be zero.
///
/// @param x The SD59x18 number for which to calculate the inverse.
/// @return result The inverse as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function inv(SD59x18 x) pure returns (SD59x18 result) {
    result = wrap(uUNIT_SQUARED / x.unwrap());
}

/// @notice Calculates the natural logarithm of x using the following formula:
///
/// $$
/// ln{x} = log_2{x} / log_2{e}
/// $$
///
/// @dev Notes:
/// - Refer to the notes in {log2}.
/// - The precision isn't sufficiently fine-grained to return exactly `UNIT` when the input is `E`.
///
/// Requirements:
/// - Refer to the requirements in {log2}.
///
/// @param x The SD59x18 number for which to calculate the natural logarithm.
/// @return result The natural logarithm as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function ln(SD59x18 x) pure returns (SD59x18 result) {
    // Inline the fixed-point multiplication to save gas. This is overflow-safe because the maximum value that
    // {log2} can return is ~195_205294292027477728.
    result = wrap(log2(x).unwrap() * uUNIT / uLOG2_E);
}

/// @notice Calculates the common logarithm of x using the following formula:
///
/// $$
/// log_{10}{x} = log_2{x} / log_2{10}
/// $$
///
/// However, if x is an exact power of ten, a hard coded value is returned.
///
/// @dev Notes:
/// - Refer to the notes in {log2}.
///
/// Requirements:
/// - Refer to the requirements in {log2}.
///
/// @param x The SD59x18 number for which to calculate the common logarithm.
/// @return result The common logarithm as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function log10(SD59x18 x) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap();
    if (xInt < 0) {
        revert Errors.PRBMath_SD59x18_Log_InputTooSmall(x);
    }

    // Note that the `mul` in this block is the standard multiplication operation, not {SD59x18.mul}.
    // prettier-ignore
    assembly ("memory-safe") {
        switch x
        case 1 { result := mul(uUNIT, sub(0, 18)) }
        case 10 { result := mul(uUNIT, sub(1, 18)) }
        case 100 { result := mul(uUNIT, sub(2, 18)) }
        case 1000 { result := mul(uUNIT, sub(3, 18)) }
        case 10000 { result := mul(uUNIT, sub(4, 18)) }
        case 100000 { result := mul(uUNIT, sub(5, 18)) }
        case 1000000 { result := mul(uUNIT, sub(6, 18)) }
        case 10000000 { result := mul(uUNIT, sub(7, 18)) }
        case 100000000 { result := mul(uUNIT, sub(8, 18)) }
        case 1000000000 { result := mul(uUNIT, sub(9, 18)) }
        case 10000000000 { result := mul(uUNIT, sub(10, 18)) }
        case 100000000000 { result := mul(uUNIT, sub(11, 18)) }
        case 1000000000000 { result := mul(uUNIT, sub(12, 18)) }
        case 10000000000000 { result := mul(uUNIT, sub(13, 18)) }
        case 100000000000000 { result := mul(uUNIT, sub(14, 18)) }
        case 1000000000000000 { result := mul(uUNIT, sub(15, 18)) }
        case 10000000000000000 { result := mul(uUNIT, sub(16, 18)) }
        case 100000000000000000 { result := mul(uUNIT, sub(17, 18)) }
        case 1000000000000000000 { result := 0 }
        case 10000000000000000000 { result := uUNIT }
        case 100000000000000000000 { result := mul(uUNIT, 2) }
        case 1000000000000000000000 { result := mul(uUNIT, 3) }
        case 10000000000000000000000 { result := mul(uUNIT, 4) }
        case 100000000000000000000000 { result := mul(uUNIT, 5) }
        case 1000000000000000000000000 { result := mul(uUNIT, 6) }
        case 10000000000000000000000000 { result := mul(uUNIT, 7) }
        case 100000000000000000000000000 { result := mul(uUNIT, 8) }
        case 1000000000000000000000000000 { result := mul(uUNIT, 9) }
        case 10000000000000000000000000000 { result := mul(uUNIT, 10) }
        case 100000000000000000000000000000 { result := mul(uUNIT, 11) }
        case 1000000000000000000000000000000 { result := mul(uUNIT, 12) }
        case 10000000000000000000000000000000 { result := mul(uUNIT, 13) }
        case 100000000000000000000000000000000 { result := mul(uUNIT, 14) }
        case 1000000000000000000000000000000000 { result := mul(uUNIT, 15) }
        case 10000000000000000000000000000000000 { result := mul(uUNIT, 16) }
        case 100000000000000000000000000000000000 { result := mul(uUNIT, 17) }
        case 1000000000000000000000000000000000000 { result := mul(uUNIT, 18) }
        case 10000000000000000000000000000000000000 { result := mul(uUNIT, 19) }
        case 100000000000000000000000000000000000000 { result := mul(uUNIT, 20) }
        case 1000000000000000000000000000000000000000 { result := mul(uUNIT, 21) }
        case 10000000000000000000000000000000000000000 { result := mul(uUNIT, 22) }
        case 100000000000000000000000000000000000000000 { result := mul(uUNIT, 23) }
        case 1000000000000000000000000000000000000000000 { result := mul(uUNIT, 24) }
        case 10000000000000000000000000000000000000000000 { result := mul(uUNIT, 25) }
        case 100000000000000000000000000000000000000000000 { result := mul(uUNIT, 26) }
        case 1000000000000000000000000000000000000000000000 { result := mul(uUNIT, 27) }
        case 10000000000000000000000000000000000000000000000 { result := mul(uUNIT, 28) }
        case 100000000000000000000000000000000000000000000000 { result := mul(uUNIT, 29) }
        case 1000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 30) }
        case 10000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 31) }
        case 100000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 32) }
        case 1000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 33) }
        case 10000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 34) }
        case 100000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 35) }
        case 1000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 36) }
        case 10000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 37) }
        case 100000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 38) }
        case 1000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 39) }
        case 10000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 40) }
        case 100000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 41) }
        case 1000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 42) }
        case 10000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 43) }
        case 100000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 44) }
        case 1000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 45) }
        case 10000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 46) }
        case 100000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 47) }
        case 1000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 48) }
        case 10000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 49) }
        case 100000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 50) }
        case 1000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 51) }
        case 10000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 52) }
        case 100000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 53) }
        case 1000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 54) }
        case 10000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 55) }
        case 100000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 56) }
        case 1000000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 57) }
        case 10000000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 58) }
        default { result := uMAX_SD59x18 }
    }

    if (result.unwrap() == uMAX_SD59x18) {
        unchecked {
            // Inline the fixed-point division to save gas.
            result = wrap(log2(x).unwrap() * uUNIT / uLOG2_10);
        }
    }
}

/// @notice Calculates the binary logarithm of x using the iterative approximation algorithm:
///
/// $$
/// log_2{x} = n + log_2{y}, \text{ where } y = x*2^{-n}, \ y \in [1, 2)
/// $$
///
/// For $0 \leq x \lt 1$, the input is inverted:
///
/// $$
/// log_2{x} = -log_2{\frac{1}{x}}
/// $$
///
/// @dev See https://en.wikipedia.org/wiki/Binary_logarithm#Iterative_approximation.
///
/// Notes:
/// - Due to the lossy precision of the iterative approximation, the results are not perfectly accurate to the last decimal.
///
/// Requirements:
/// - x > 0
///
/// @param x The SD59x18 number for which to calculate the binary logarithm.
/// @return result The binary logarithm as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function log2(SD59x18 x) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap();
    if (xInt <= 0) {
        revert Errors.PRBMath_SD59x18_Log_InputTooSmall(x);
    }

    unchecked {
        int256 sign;
        if (xInt >= uUNIT) {
            sign = 1;
        } else {
            sign = -1;
            // Inline the fixed-point inversion to save gas.
            xInt = uUNIT_SQUARED / xInt;
        }

        // Calculate the integer part of the logarithm.
        uint256 n = Common.msb(uint256(xInt / uUNIT));

        // This is the integer part of the logarithm as an SD59x18 number. The operation can't overflow
        // because n is at most 255, `UNIT` is 1e18, and the sign is either 1 or -1.
        int256 resultInt = int256(n) * uUNIT;

        // Calculate $y = x * 2^{-n}$.
        int256 y = xInt >> n;

        // If y is the unit number, the fractional part is zero.
        if (y == uUNIT) {
            return wrap(resultInt * sign);
        }

        // Calculate the fractional part via the iterative approximation.
        // The `delta >>= 1` part is equivalent to `delta /= 2`, but shifting bits is more gas efficient.
        int256 DOUBLE_UNIT = 2e18;
        for (int256 delta = uHALF_UNIT; delta > 0; delta >>= 1) {
            y = (y * y) / uUNIT;

            // Is y^2 >= 2e18 and so in the range [2e18, 4e18)?
            if (y >= DOUBLE_UNIT) {
                // Add the 2^{-m} factor to the logarithm.
                resultInt = resultInt + delta;

                // Halve y, which corresponds to z/2 in the Wikipedia article.
                y >>= 1;
            }
        }
        resultInt *= sign;
        result = wrap(resultInt);
    }
}

/// @notice Multiplies two SD59x18 numbers together, returning a new SD59x18 number.
///
/// @dev Notes:
/// - Refer to the notes in {Common.mulDiv18}.
///
/// Requirements:
/// - Refer to the requirements in {Common.mulDiv18}.
/// - None of the inputs can be `MIN_SD59x18`.
/// - The result must fit in SD59x18.
///
/// @param x The multiplicand as an SD59x18 number.
/// @param y The multiplier as an SD59x18 number.
/// @return result The product as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function mul(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap();
    int256 yInt = y.unwrap();
    if (xInt == uMIN_SD59x18 || yInt == uMIN_SD59x18) {
        revert Errors.PRBMath_SD59x18_Mul_InputTooSmall();
    }

    // Get hold of the absolute values of x and y.
    uint256 xAbs;
    uint256 yAbs;
    unchecked {
        xAbs = xInt < 0 ? uint256(-xInt) : uint256(xInt);
        yAbs = yInt < 0 ? uint256(-yInt) : uint256(yInt);
    }

    // Compute the absolute value (x*y÷UNIT). The resulting value must fit in SD59x18.
    uint256 resultAbs = Common.mulDiv18(xAbs, yAbs);
    if (resultAbs > uint256(uMAX_SD59x18)) {
        revert Errors.PRBMath_SD59x18_Mul_Overflow(x, y);
    }

    // Check if x and y have the same sign using two's complement representation. The left-most bit represents the sign (1 for
    // negative, 0 for positive or zero).
    bool sameSign = (xInt ^ yInt) > -1;

    // If the inputs have the same sign, the result should be positive. Otherwise, it should be negative.
    unchecked {
        result = wrap(sameSign ? int256(resultAbs) : -int256(resultAbs));
    }
}

/// @notice Raises x to the power of y using the following formula:
///
/// $$
/// x^y = 2^{log_2{x} * y}
/// $$
///
/// @dev Notes:
/// - Refer to the notes in {exp2}, {log2}, and {mul}.
/// - Returns `UNIT` for 0^0.
///
/// Requirements:
/// - Refer to the requirements in {exp2}, {log2}, and {mul}.
///
/// @param x The base as an SD59x18 number.
/// @param y Exponent to raise x to, as an SD59x18 number
/// @return result x raised to power y, as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function pow(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap();
    int256 yInt = y.unwrap();

    // If both x and y are zero, the result is `UNIT`. If just x is zero, the result is always zero.
    if (xInt == 0) {
        return yInt == 0 ? UNIT : ZERO;
    }
    // If x is `UNIT`, the result is always `UNIT`.
    else if (xInt == uUNIT) {
        return UNIT;
    }

    // If y is zero, the result is always `UNIT`.
    if (yInt == 0) {
        return UNIT;
    }
    // If y is `UNIT`, the result is always x.
    else if (yInt == uUNIT) {
        return x;
    }

    // Calculate the result using the formula.
    result = exp2(mul(log2(x), y));
}

/// @notice Raises x (an SD59x18 number) to the power y (an unsigned basic integer) using the well-known
/// algorithm "exponentiation by squaring".
///
/// @dev See https://en.wikipedia.org/wiki/Exponentiation_by_squaring.
///
/// Notes:
/// - Refer to the notes in {Common.mulDiv18}.
/// - Returns `UNIT` for 0^0.
///
/// Requirements:
/// - Refer to the requirements in {abs} and {Common.mulDiv18}.
/// - The result must fit in SD59x18.
///
/// @param x The base as an SD59x18 number.
/// @param y The exponent as a uint256.
/// @return result The result as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function powu(SD59x18 x, uint256 y) pure returns (SD59x18 result) {
    uint256 xAbs = uint256(abs(x).unwrap());

    // Calculate the first iteration of the loop in advance.
    uint256 resultAbs = y & 1 > 0 ? xAbs : uint256(uUNIT);

    // Equivalent to `for(y /= 2; y > 0; y /= 2)`.
    uint256 yAux = y;
    for (yAux >>= 1; yAux > 0; yAux >>= 1) {
        xAbs = Common.mulDiv18(xAbs, xAbs);

        // Equivalent to `y % 2 == 1`.
        if (yAux & 1 > 0) {
            resultAbs = Common.mulDiv18(resultAbs, xAbs);
        }
    }

    // The result must fit in SD59x18.
    if (resultAbs > uint256(uMAX_SD59x18)) {
        revert Errors.PRBMath_SD59x18_Powu_Overflow(x, y);
    }

    unchecked {
        // Is the base negative and the exponent odd? If yes, the result should be negative.
        int256 resultInt = int256(resultAbs);
        bool isNegative = x.unwrap() < 0 && y & 1 == 1;
        if (isNegative) {
            resultInt = -resultInt;
        }
        result = wrap(resultInt);
    }
}

/// @notice Calculates the square root of x using the Babylonian method.
///
/// @dev See https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method.
///
/// Notes:
/// - Only the positive root is returned.
/// - The result is rounded toward zero.
///
/// Requirements:
/// - x ≥ 0, since complex numbers are not supported.
/// - x ≤ MAX_SD59x18 / UNIT
///
/// @param x The SD59x18 number for which to calculate the square root.
/// @return result The result as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function sqrt(SD59x18 x) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap();
    if (xInt < 0) {
        revert Errors.PRBMath_SD59x18_Sqrt_NegativeInput(x);
    }
    if (xInt > uMAX_SD59x18 / uUNIT) {
        revert Errors.PRBMath_SD59x18_Sqrt_Overflow(x);
    }

    unchecked {
        // Multiply x by `UNIT` to account for the factor of `UNIT` picked up when multiplying two SD59x18 numbers.
        // In this case, the two numbers are both the square root.
        uint256 resultUint = Common.sqrt(uint256(xInt * uUNIT));
        result = wrap(int256(resultUint));
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "./Casting.sol" as Casting;
import "./Helpers.sol" as Helpers;
import "./Math.sol" as Math;

/// @notice The signed 59.18-decimal fixed-point number representation, which can have up to 59 digits and up to 18
/// decimals. The values of this are bound by the minimum and the maximum values permitted by the underlying Solidity
/// type int256.
type SD59x18 is int256;

/*//////////////////////////////////////////////////////////////////////////
                                    CASTING
//////////////////////////////////////////////////////////////////////////*/

using {
    Casting.intoInt256,
    Casting.intoSD1x18,
    Casting.intoSD21x18,
    Casting.intoUD2x18,
    Casting.intoUD21x18,
    Casting.intoUD60x18,
    Casting.intoUint256,
    Casting.intoUint128,
    Casting.intoUint40,
    Casting.unwrap
} for SD59x18 global;

/*//////////////////////////////////////////////////////////////////////////
                            MATHEMATICAL FUNCTIONS
//////////////////////////////////////////////////////////////////////////*/

using {
    Math.abs,
    Math.avg,
    Math.ceil,
    Math.div,
    Math.exp,
    Math.exp2,
    Math.floor,
    Math.frac,
    Math.gm,
    Math.inv,
    Math.log10,
    Math.log2,
    Math.ln,
    Math.mul,
    Math.pow,
    Math.powu,
    Math.sqrt
} for SD59x18 global;

/*//////////////////////////////////////////////////////////////////////////
                                HELPER FUNCTIONS
//////////////////////////////////////////////////////////////////////////*/

using {
    Helpers.add,
    Helpers.and,
    Helpers.eq,
    Helpers.gt,
    Helpers.gte,
    Helpers.isZero,
    Helpers.lshift,
    Helpers.lt,
    Helpers.lte,
    Helpers.mod,
    Helpers.neq,
    Helpers.not,
    Helpers.or,
    Helpers.rshift,
    Helpers.sub,
    Helpers.uncheckedAdd,
    Helpers.uncheckedSub,
    Helpers.uncheckedUnary,
    Helpers.xor
} for SD59x18 global;

/*//////////////////////////////////////////////////////////////////////////
                                    OPERATORS
//////////////////////////////////////////////////////////////////////////*/

// The global "using for" directive makes it possible to use these operators on the SD59x18 type.
using {
    Helpers.add as +,
    Helpers.and2 as &,
    Math.div as /,
    Helpers.eq as ==,
    Helpers.gt as >,
    Helpers.gte as >=,
    Helpers.lt as <,
    Helpers.lte as <=,
    Helpers.mod as %,
    Math.mul as *,
    Helpers.neq as !=,
    Helpers.not as ~,
    Helpers.or as |,
    Helpers.sub as -,
    Helpers.unary as -,
    Helpers.xor as ^
} for SD59x18 global;
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "../Common.sol" as Common;
import "./Errors.sol" as Errors;
import { SD59x18 } from "../sd59x18/ValueType.sol";
import { UD60x18 } from "../ud60x18/ValueType.sol";
import { UD21x18 } from "./ValueType.sol";

/// @notice Casts a UD21x18 number into SD59x18.
/// @dev There is no overflow check because UD21x18 ⊆ SD59x18.
function intoSD59x18(UD21x18 x) pure returns (SD59x18 result) {
    result = SD59x18.wrap(int256(uint256(UD21x18.unwrap(x))));
}

/// @notice Casts a UD21x18 number into UD60x18.
/// @dev There is no overflow check because UD21x18 ⊆ UD60x18.
function intoUD60x18(UD21x18 x) pure returns (UD60x18 result) {
    result = UD60x18.wrap(UD21x18.unwrap(x));
}

/// @notice Casts a UD21x18 number into uint128.
/// @dev This is basically an alias for {unwrap}.
function intoUint128(UD21x18 x) pure returns (uint128 result) {
    result = UD21x18.unwrap(x);
}

/// @notice Casts a UD21x18 number into uint256.
/// @dev There is no overflow check because UD21x18 ⊆ uint256.
function intoUint256(UD21x18 x) pure returns (uint256 result) {
    result = uint256(UD21x18.unwrap(x));
}

/// @notice Casts a UD21x18 number into uint40.
/// @dev Requirements:
/// - x ≤ MAX_UINT40
function intoUint40(UD21x18 x) pure returns (uint40 result) {
    uint128 xUint = UD21x18.unwrap(x);
    if (xUint > uint128(Common.MAX_UINT40)) {
        revert Errors.PRBMath_UD21x18_IntoUint40_Overflow(x);
    }
    result = uint40(xUint);
}

/// @notice Alias for {wrap}.
function ud21x18(uint128 x) pure returns (UD21x18 result) {
    result = UD21x18.wrap(x);
}

/// @notice Unwrap a UD21x18 number into uint128.
function unwrap(UD21x18 x) pure returns (uint128 result) {
    result = UD21x18.unwrap(x);
}

/// @notice Wraps a uint128 number into UD21x18.
function wrap(uint128 x) pure returns (UD21x18 result) {
    result = UD21x18.wrap(x);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { UD21x18 } from "./ValueType.sol";

/// @dev Euler's number as a UD21x18 number.
UD21x18 constant E = UD21x18.wrap(2_718281828459045235);

/// @dev The maximum value a UD21x18 number can have.
uint128 constant uMAX_UD21x18 = 340282366920938463463_374607431768211455;
UD21x18 constant MAX_UD21x18 = UD21x18.wrap(uMAX_UD21x18);

/// @dev PI as a UD21x18 number.
UD21x18 constant PI = UD21x18.wrap(3_141592653589793238);

/// @dev The unit number, which gives the decimal precision of UD21x18.
uint256 constant uUNIT = 1e18;
UD21x18 constant UNIT = UD21x18.wrap(1e18);
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { UD21x18 } from "./ValueType.sol";

/// @notice Thrown when trying to cast a UD21x18 number that doesn't fit in uint40.
error PRBMath_UD21x18_IntoUint40_Overflow(UD21x18 x);
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "./Casting.sol" as Casting;

/// @notice The unsigned 21.18-decimal fixed-point number representation, which can have up to 21 digits and up to 18
/// decimals. The values of this are bound by the minimum and the maximum values permitted by the underlying Solidity
/// type uint128. This is useful when end users want to use uint128 to save gas, e.g. with tight variable packing in contract
/// storage.
type UD21x18 is uint128;

/*//////////////////////////////////////////////////////////////////////////
                                    CASTING
//////////////////////////////////////////////////////////////////////////*/

using {
    Casting.intoSD59x18,
    Casting.intoUD60x18,
    Casting.intoUint128,
    Casting.intoUint256,
    Casting.intoUint40,
    Casting.unwrap
} for UD21x18 global;
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "../Common.sol" as Common;
import "./Errors.sol" as Errors;
import { SD59x18 } from "../sd59x18/ValueType.sol";
import { UD60x18 } from "../ud60x18/ValueType.sol";
import { UD2x18 } from "./ValueType.sol";

/// @notice Casts a UD2x18 number into SD59x18.
/// @dev There is no overflow check because UD2x18 ⊆ SD59x18.
function intoSD59x18(UD2x18 x) pure returns (SD59x18 result) {
    result = SD59x18.wrap(int256(uint256(UD2x18.unwrap(x))));
}

/// @notice Casts a UD2x18 number into UD60x18.
/// @dev There is no overflow check because UD2x18 ⊆ UD60x18.
function intoUD60x18(UD2x18 x) pure returns (UD60x18 result) {
    result = UD60x18.wrap(UD2x18.unwrap(x));
}

/// @notice Casts a UD2x18 number into uint128.
/// @dev There is no overflow check because UD2x18 ⊆ uint128.
function intoUint128(UD2x18 x) pure returns (uint128 result) {
    result = uint128(UD2x18.unwrap(x));
}

/// @notice Casts a UD2x18 number into uint256.
/// @dev There is no overflow check because UD2x18 ⊆ uint256.
function intoUint256(UD2x18 x) pure returns (uint256 result) {
    result = uint256(UD2x18.unwrap(x));
}

/// @notice Casts a UD2x18 number into uint40.
/// @dev Requirements:
/// - x ≤ MAX_UINT40
function intoUint40(UD2x18 x) pure returns (uint40 result) {
    uint64 xUint = UD2x18.unwrap(x);
    if (xUint > uint64(Common.MAX_UINT40)) {
        revert Errors.PRBMath_UD2x18_IntoUint40_Overflow(x);
    }
    result = uint40(xUint);
}

/// @notice Alias for {wrap}.
function ud2x18(uint64 x) pure returns (UD2x18 result) {
    result = UD2x18.wrap(x);
}

/// @notice Unwrap a UD2x18 number into uint64.
function unwrap(UD2x18 x) pure returns (uint64 result) {
    result = UD2x18.unwrap(x);
}

/// @notice Wraps a uint64 number into UD2x18.
function wrap(uint64 x) pure returns (UD2x18 result) {
    result = UD2x18.wrap(x);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { UD2x18 } from "./ValueType.sol";

/// @dev Euler's number as a UD2x18 number.
UD2x18 constant E = UD2x18.wrap(2_718281828459045235);

/// @dev The maximum value a UD2x18 number can have.
uint64 constant uMAX_UD2x18 = 18_446744073709551615;
UD2x18 constant MAX_UD2x18 = UD2x18.wrap(uMAX_UD2x18);

/// @dev PI as a UD2x18 number.
UD2x18 constant PI = UD2x18.wrap(3_141592653589793238);

/// @dev The unit number, which gives the decimal precision of UD2x18.
UD2x18 constant UNIT = UD2x18.wrap(1e18);
uint64 constant uUNIT = 1e18;
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { UD2x18 } from "./ValueType.sol";

/// @notice Thrown when trying to cast a UD2x18 number that doesn't fit in uint40.
error PRBMath_UD2x18_IntoUint40_Overflow(UD2x18 x);
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "./Casting.sol" as Casting;

/// @notice The unsigned 2.18-decimal fixed-point number representation, which can have up to 2 digits and up to 18
/// decimals. The values of this are bound by the minimum and the maximum values permitted by the underlying Solidity
/// type uint64. This is useful when end users want to use uint64 to save gas, e.g. with tight variable packing in contract
/// storage.
type UD2x18 is uint64;

/*//////////////////////////////////////////////////////////////////////////
                                    CASTING
//////////////////////////////////////////////////////////////////////////*/

using {
    Casting.intoSD59x18,
    Casting.intoUD60x18,
    Casting.intoUint128,
    Casting.intoUint256,
    Casting.intoUint40,
    Casting.unwrap
} for UD2x18 global;
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "./Errors.sol" as CastingErrors;
import { MAX_UINT128, MAX_UINT40 } from "../Common.sol";
import { uMAX_SD1x18 } from "../sd1x18/Constants.sol";
import { SD1x18 } from "../sd1x18/ValueType.sol";
import { uMAX_SD21x18 } from "../sd21x18/Constants.sol";
import { SD21x18 } from "../sd21x18/ValueType.sol";
import { uMAX_SD59x18 } from "../sd59x18/Constants.sol";
import { SD59x18 } from "../sd59x18/ValueType.sol";
import { uMAX_UD2x18 } from "../ud2x18/Constants.sol";
import { uMAX_UD21x18 } from "../ud21x18/Constants.sol";
import { UD2x18 } from "../ud2x18/ValueType.sol";
import { UD21x18 } from "../ud21x18/ValueType.sol";
import { UD60x18 } from "./ValueType.sol";

/// @notice Casts a UD60x18 number into SD1x18.
/// @dev Requirements:
/// - x ≤ uMAX_SD1x18
function intoSD1x18(UD60x18 x) pure returns (SD1x18 result) {
    uint256 xUint = UD60x18.unwrap(x);
    if (xUint > uint256(int256(uMAX_SD1x18))) {
        revert CastingErrors.PRBMath_UD60x18_IntoSD1x18_Overflow(x);
    }
    result = SD1x18.wrap(int64(uint64(xUint)));
}

/// @notice Casts a UD60x18 number into SD21x18.
/// @dev Requirements:
/// - x ≤ uMAX_SD21x18
function intoSD21x18(UD60x18 x) pure returns (SD21x18 result) {
    uint256 xUint = UD60x18.unwrap(x);
    if (xUint > uint256(int256(uMAX_SD21x18))) {
        revert CastingErrors.PRBMath_UD60x18_IntoSD21x18_Overflow(x);
    }
    result = SD21x18.wrap(int128(uint128(xUint)));
}

/// @notice Casts a UD60x18 number into UD2x18.
/// @dev Requirements:
/// - x ≤ uMAX_UD2x18
function intoUD2x18(UD60x18 x) pure returns (UD2x18 result) {
    uint256 xUint = UD60x18.unwrap(x);
    if (xUint > uMAX_UD2x18) {
        revert CastingErrors.PRBMath_UD60x18_IntoUD2x18_Overflow(x);
    }
    result = UD2x18.wrap(uint64(xUint));
}

/// @notice Casts a UD60x18 number into UD21x18.
/// @dev Requirements:
/// - x ≤ uMAX_UD21x18
function intoUD21x18(UD60x18 x) pure returns (UD21x18 result) {
    uint256 xUint = UD60x18.unwrap(x);
    if (xUint > uMAX_UD21x18) {
        revert CastingErrors.PRBMath_UD60x18_IntoUD21x18_Overflow(x);
    }
    result = UD21x18.wrap(uint128(xUint));
}

/// @notice Casts a UD60x18 number into SD59x18.
/// @dev Requirements:
/// - x ≤ uMAX_SD59x18
function intoSD59x18(UD60x18 x) pure returns (SD59x18 result) {
    uint256 xUint = UD60x18.unwrap(x);
    if (xUint > uint256(uMAX_SD59x18)) {
        revert CastingErrors.PRBMath_UD60x18_IntoSD59x18_Overflow(x);
    }
    result = SD59x18.wrap(int256(xUint));
}

/// @notice Casts a UD60x18 number into uint128.
/// @dev This is basically an alias for {unwrap}.
function intoUint256(UD60x18 x) pure returns (uint256 result) {
    result = UD60x18.unwrap(x);
}

/// @notice Casts a UD60x18 number into uint128.
/// @dev Requirements:
/// - x ≤ MAX_UINT128
function intoUint128(UD60x18 x) pure returns (uint128 result) {
    uint256 xUint = UD60x18.unwrap(x);
    if (xUint > MAX_UINT128) {
        revert CastingErrors.PRBMath_UD60x18_IntoUint128_Overflow(x);
    }
    result = uint128(xUint);
}

/// @notice Casts a UD60x18 number into uint40.
/// @dev Requirements:
/// - x ≤ MAX_UINT40
function intoUint40(UD60x18 x) pure returns (uint40 result) {
    uint256 xUint = UD60x18.unwrap(x);
    if (xUint > MAX_UINT40) {
        revert CastingErrors.PRBMath_UD60x18_IntoUint40_Overflow(x);
    }
    result = uint40(xUint);
}

/// @notice Alias for {wrap}.
function ud(uint256 x) pure returns (UD60x18 result) {
    result = UD60x18.wrap(x);
}

/// @notice Alias for {wrap}.
function ud60x18(uint256 x) pure returns (UD60x18 result) {
    result = UD60x18.wrap(x);
}

/// @notice Unwraps a UD60x18 number into uint256.
function unwrap(UD60x18 x) pure returns (uint256 result) {
    result = UD60x18.unwrap(x);
}

/// @notice Wraps a uint256 number into the UD60x18 value type.
function wrap(uint256 x) pure returns (UD60x18 result) {
    result = UD60x18.wrap(x);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { UD60x18 } from "./ValueType.sol";

// NOTICE: the "u" prefix stands for "unwrapped".

/// @dev Euler's number as a UD60x18 number.
UD60x18 constant E = UD60x18.wrap(2_718281828459045235);

/// @dev The maximum input permitted in {exp}.
uint256 constant uEXP_MAX_INPUT = 133_084258667509499440;
UD60x18 constant EXP_MAX_INPUT = UD60x18.wrap(uEXP_MAX_INPUT);

/// @dev The maximum input permitted in {exp2}.
uint256 constant uEXP2_MAX_INPUT = 192e18 - 1;
UD60x18 constant EXP2_MAX_INPUT = UD60x18.wrap(uEXP2_MAX_INPUT);

/// @dev Half the UNIT number.
uint256 constant uHALF_UNIT = 0.5e18;
UD60x18 constant HALF_UNIT = UD60x18.wrap(uHALF_UNIT);

/// @dev $log_2(10)$ as a UD60x18 number.
uint256 constant uLOG2_10 = 3_321928094887362347;
UD60x18 constant LOG2_10 = UD60x18.wrap(uLOG2_10);

/// @dev $log_2(e)$ as a UD60x18 number.
uint256 constant uLOG2_E = 1_442695040888963407;
UD60x18 constant LOG2_E = UD60x18.wrap(uLOG2_E);

/// @dev The maximum value a UD60x18 number can have.
uint256 constant uMAX_UD60x18 = 115792089237316195423570985008687907853269984665640564039457_584007913129639935;
UD60x18 constant MAX_UD60x18 = UD60x18.wrap(uMAX_UD60x18);

/// @dev The maximum whole value a UD60x18 number can have.
uint256 constant uMAX_WHOLE_UD60x18 = 115792089237316195423570985008687907853269984665640564039457_000000000000000000;
UD60x18 constant MAX_WHOLE_UD60x18 = UD60x18.wrap(uMAX_WHOLE_UD60x18);

/// @dev PI as a UD60x18 number.
UD60x18 constant PI = UD60x18.wrap(3_141592653589793238);

/// @dev The unit number, which gives the decimal precision of UD60x18.
uint256 constant uUNIT = 1e18;
UD60x18 constant UNIT = UD60x18.wrap(uUNIT);

/// @dev The unit number squared.
uint256 constant uUNIT_SQUARED = 1e36;
UD60x18 constant UNIT_SQUARED = UD60x18.wrap(uUNIT_SQUARED);

/// @dev Zero as a UD60x18 number.
UD60x18 constant ZERO = UD60x18.wrap(0);
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { uMAX_UD60x18, uUNIT } from "./Constants.sol";
import { PRBMath_UD60x18_Convert_Overflow } from "./Errors.sol";
import { UD60x18 } from "./ValueType.sol";

/// @notice Converts a UD60x18 number to a simple integer by dividing it by `UNIT`.
/// @dev The result is rounded toward zero.
/// @param x The UD60x18 number to convert.
/// @return result The same number in basic integer form.
function convert(UD60x18 x) pure returns (uint256 result) {
    result = UD60x18.unwrap(x) / uUNIT;
}

/// @notice Converts a simple integer to UD60x18 by multiplying it by `UNIT`.
///
/// @dev Requirements:
/// - x ≤ MAX_UD60x18 / UNIT
///
/// @param x The basic integer to convert.
/// @return result The same number converted to UD60x18.
function convert(uint256 x) pure returns (UD60x18 result) {
    if (x > uMAX_UD60x18 / uUNIT) {
        revert PRBMath_UD60x18_Convert_Overflow(x);
    }
    unchecked {
        result = UD60x18.wrap(x * uUNIT);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { UD60x18 } from "./ValueType.sol";

/// @notice Thrown when ceiling a number overflows UD60x18.
error PRBMath_UD60x18_Ceil_Overflow(UD60x18 x);

/// @notice Thrown when converting a basic integer to the fixed-point format overflows UD60x18.
error PRBMath_UD60x18_Convert_Overflow(uint256 x);

/// @notice Thrown when taking the natural exponent of a base greater than 133_084258667509499441.
error PRBMath_UD60x18_Exp_InputTooBig(UD60x18 x);

/// @notice Thrown when taking the binary exponent of a base greater than 192e18.
error PRBMath_UD60x18_Exp2_InputTooBig(UD60x18 x);

/// @notice Thrown when taking the geometric mean of two numbers and multiplying them overflows UD60x18.
error PRBMath_UD60x18_Gm_Overflow(UD60x18 x, UD60x18 y);

/// @notice Thrown when trying to cast a UD60x18 number that doesn't fit in SD1x18.
error PRBMath_UD60x18_IntoSD1x18_Overflow(UD60x18 x);

/// @notice Thrown when trying to cast a UD60x18 number that doesn't fit in SD21x18.
error PRBMath_UD60x18_IntoSD21x18_Overflow(UD60x18 x);

/// @notice Thrown when trying to cast a UD60x18 number that doesn't fit in SD59x18.
error PRBMath_UD60x18_IntoSD59x18_Overflow(UD60x18 x);

/// @notice Thrown when trying to cast a UD60x18 number that doesn't fit in UD2x18.
error PRBMath_UD60x18_IntoUD2x18_Overflow(UD60x18 x);

/// @notice Thrown when trying to cast a UD60x18 number that doesn't fit in UD21x18.
error PRBMath_UD60x18_IntoUD21x18_Overflow(UD60x18 x);

/// @notice Thrown when trying to cast a UD60x18 number that doesn't fit in uint128.
error PRBMath_UD60x18_IntoUint128_Overflow(UD60x18 x);

/// @notice Thrown when trying to cast a UD60x18 number that doesn't fit in uint40.
error PRBMath_UD60x18_IntoUint40_Overflow(UD60x18 x);

/// @notice Thrown when taking the logarithm of a number less than UNIT.
error PRBMath_UD60x18_Log_InputTooSmall(UD60x18 x);

/// @notice Thrown when calculating the square root overflows UD60x18.
error PRBMath_UD60x18_Sqrt_Overflow(UD60x18 x);
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { wrap } from "./Casting.sol";
import { UD60x18 } from "./ValueType.sol";

/// @notice Implements the checked addition operation (+) in the UD60x18 type.
function add(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    result = wrap(x.unwrap() + y.unwrap());
}

/// @notice Implements the AND (&) bitwise operation in the UD60x18 type.
function and(UD60x18 x, uint256 bits) pure returns (UD60x18 result) {
    result = wrap(x.unwrap() & bits);
}

/// @notice Implements the AND (&) bitwise operation in the UD60x18 type.
function and2(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    result = wrap(x.unwrap() & y.unwrap());
}

/// @notice Implements the equal operation (==) in the UD60x18 type.
function eq(UD60x18 x, UD60x18 y) pure returns (bool result) {
    result = x.unwrap() == y.unwrap();
}

/// @notice Implements the greater than operation (>) in the UD60x18 type.
function gt(UD60x18 x, UD60x18 y) pure returns (bool result) {
    result = x.unwrap() > y.unwrap();
}

/// @notice Implements the greater than or equal to operation (>=) in the UD60x18 type.
function gte(UD60x18 x, UD60x18 y) pure returns (bool result) {
    result = x.unwrap() >= y.unwrap();
}

/// @notice Implements a zero comparison check function in the UD60x18 type.
function isZero(UD60x18 x) pure returns (bool result) {
    // This wouldn't work if x could be negative.
    result = x.unwrap() == 0;
}

/// @notice Implements the left shift operation (<<) in the UD60x18 type.
function lshift(UD60x18 x, uint256 bits) pure returns (UD60x18 result) {
    result = wrap(x.unwrap() << bits);
}

/// @notice Implements the lower than operation (<) in the UD60x18 type.
function lt(UD60x18 x, UD60x18 y) pure returns (bool result) {
    result = x.unwrap() < y.unwrap();
}

/// @notice Implements the lower than or equal to operation (<=) in the UD60x18 type.
function lte(UD60x18 x, UD60x18 y) pure returns (bool result) {
    result = x.unwrap() <= y.unwrap();
}

/// @notice Implements the checked modulo operation (%) in the UD60x18 type.
function mod(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    result = wrap(x.unwrap() % y.unwrap());
}

/// @notice Implements the not equal operation (!=) in the UD60x18 type.
function neq(UD60x18 x, UD60x18 y) pure returns (bool result) {
    result = x.unwrap() != y.unwrap();
}

/// @notice Implements the NOT (~) bitwise operation in the UD60x18 type.
function not(UD60x18 x) pure returns (UD60x18 result) {
    result = wrap(~x.unwrap());
}

/// @notice Implements the OR (|) bitwise operation in the UD60x18 type.
function or(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    result = wrap(x.unwrap() | y.unwrap());
}

/// @notice Implements the right shift operation (>>) in the UD60x18 type.
function rshift(UD60x18 x, uint256 bits) pure returns (UD60x18 result) {
    result = wrap(x.unwrap() >> bits);
}

/// @notice Implements the checked subtraction operation (-) in the UD60x18 type.
function sub(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    result = wrap(x.unwrap() - y.unwrap());
}

/// @notice Implements the unchecked addition operation (+) in the UD60x18 type.
function uncheckedAdd(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    unchecked {
        result = wrap(x.unwrap() + y.unwrap());
    }
}

/// @notice Implements the unchecked subtraction operation (-) in the UD60x18 type.
function uncheckedSub(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    unchecked {
        result = wrap(x.unwrap() - y.unwrap());
    }
}

/// @notice Implements the XOR (^) bitwise operation in the UD60x18 type.
function xor(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    result = wrap(x.unwrap() ^ y.unwrap());
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "../Common.sol" as Common;
import "./Errors.sol" as Errors;
import { wrap } from "./Casting.sol";
import {
    uEXP_MAX_INPUT,
    uEXP2_MAX_INPUT,
    uHALF_UNIT,
    uLOG2_10,
    uLOG2_E,
    uMAX_UD60x18,
    uMAX_WHOLE_UD60x18,
    UNIT,
    uUNIT,
    uUNIT_SQUARED,
    ZERO
} from "./Constants.sol";
import { UD60x18 } from "./ValueType.sol";

/*//////////////////////////////////////////////////////////////////////////
                            MATHEMATICAL FUNCTIONS
//////////////////////////////////////////////////////////////////////////*/

/// @notice Calculates the arithmetic average of x and y using the following formula:
///
/// $$
/// avg(x, y) = (x & y) + ((xUint ^ yUint) / 2)
/// $$
///
/// In English, this is what this formula does:
///
/// 1. AND x and y.
/// 2. Calculate half of XOR x and y.
/// 3. Add the two results together.
///
/// This technique is known as SWAR, which stands for "SIMD within a register". You can read more about it here:
/// https://devblogs.microsoft.com/oldnewthing/20220207-00/?p=106223
///
/// @dev Notes:
/// - The result is rounded toward zero.
///
/// @param x The first operand as a UD60x18 number.
/// @param y The second operand as a UD60x18 number.
/// @return result The arithmetic average as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function avg(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    uint256 xUint = x.unwrap();
    uint256 yUint = y.unwrap();
    unchecked {
        result = wrap((xUint & yUint) + ((xUint ^ yUint) >> 1));
    }
}

/// @notice Yields the smallest whole number greater than or equal to x.
///
/// @dev This is optimized for fractional value inputs, because for every whole value there are (1e18 - 1) fractional
/// counterparts. See https://en.wikipedia.org/wiki/Floor_and_ceiling_functions.
///
/// Requirements:
/// - x ≤ MAX_WHOLE_UD60x18
///
/// @param x The UD60x18 number to ceil.
/// @return result The smallest whole number greater than or equal to x, as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function ceil(UD60x18 x) pure returns (UD60x18 result) {
    uint256 xUint = x.unwrap();
    if (xUint > uMAX_WHOLE_UD60x18) {
        revert Errors.PRBMath_UD60x18_Ceil_Overflow(x);
    }

    assembly ("memory-safe") {
        // Equivalent to `x % UNIT`.
        let remainder := mod(x, uUNIT)

        // Equivalent to `UNIT - remainder`.
        let delta := sub(uUNIT, remainder)

        // Equivalent to `x + remainder > 0 ? delta : 0`.
        result := add(x, mul(delta, gt(remainder, 0)))
    }
}

/// @notice Divides two UD60x18 numbers, returning a new UD60x18 number.
///
/// @dev Uses {Common.mulDiv} to enable overflow-safe multiplication and division.
///
/// Notes:
/// - Refer to the notes in {Common.mulDiv}.
///
/// Requirements:
/// - Refer to the requirements in {Common.mulDiv}.
///
/// @param x The numerator as a UD60x18 number.
/// @param y The denominator as a UD60x18 number.
/// @return result The quotient as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function div(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    result = wrap(Common.mulDiv(x.unwrap(), uUNIT, y.unwrap()));
}

/// @notice Calculates the natural exponent of x using the following formula:
///
/// $$
/// e^x = 2^{x * log_2{e}}
/// $$
///
/// @dev Requirements:
/// - x ≤ 133_084258667509499440
///
/// @param x The exponent as a UD60x18 number.
/// @return result The result as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function exp(UD60x18 x) pure returns (UD60x18 result) {
    uint256 xUint = x.unwrap();

    // This check prevents values greater than 192e18 from being passed to {exp2}.
    if (xUint > uEXP_MAX_INPUT) {
        revert Errors.PRBMath_UD60x18_Exp_InputTooBig(x);
    }

    unchecked {
        // Inline the fixed-point multiplication to save gas.
        uint256 doubleUnitProduct = xUint * uLOG2_E;
        result = exp2(wrap(doubleUnitProduct / uUNIT));
    }
}

/// @notice Calculates the binary exponent of x using the binary fraction method.
///
/// @dev See https://ethereum.stackexchange.com/q/79903/24693
///
/// Requirements:
/// - x < 192e18
/// - The result must fit in UD60x18.
///
/// @param x The exponent as a UD60x18 number.
/// @return result The result as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function exp2(UD60x18 x) pure returns (UD60x18 result) {
    uint256 xUint = x.unwrap();

    // Numbers greater than or equal to 192e18 don't fit in the 192.64-bit format.
    if (xUint > uEXP2_MAX_INPUT) {
        revert Errors.PRBMath_UD60x18_Exp2_InputTooBig(x);
    }

    // Convert x to the 192.64-bit fixed-point format.
    uint256 x_192x64 = (xUint << 64) / uUNIT;

    // Pass x to the {Common.exp2} function, which uses the 192.64-bit fixed-point number representation.
    result = wrap(Common.exp2(x_192x64));
}

/// @notice Yields the greatest whole number less than or equal to x.
/// @dev Optimized for fractional value inputs, because every whole value has (1e18 - 1) fractional counterparts.
/// See https://en.wikipedia.org/wiki/Floor_and_ceiling_functions.
/// @param x The UD60x18 number to floor.
/// @return result The greatest whole number less than or equal to x, as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function floor(UD60x18 x) pure returns (UD60x18 result) {
    assembly ("memory-safe") {
        // Equivalent to `x % UNIT`.
        let remainder := mod(x, uUNIT)

        // Equivalent to `x - remainder > 0 ? remainder : 0)`.
        result := sub(x, mul(remainder, gt(remainder, 0)))
    }
}

/// @notice Yields the excess beyond the floor of x using the odd function definition.
/// @dev See https://en.wikipedia.org/wiki/Fractional_part.
/// @param x The UD60x18 number to get the fractional part of.
/// @return result The fractional part of x as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function frac(UD60x18 x) pure returns (UD60x18 result) {
    assembly ("memory-safe") {
        result := mod(x, uUNIT)
    }
}

/// @notice Calculates the geometric mean of x and y, i.e. $\sqrt{x * y}$, rounding down.
///
/// @dev Requirements:
/// - x * y must fit in UD60x18.
///
/// @param x The first operand as a UD60x18 number.
/// @param y The second operand as a UD60x18 number.
/// @return result The result as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function gm(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    uint256 xUint = x.unwrap();
    uint256 yUint = y.unwrap();
    if (xUint == 0 || yUint == 0) {
        return ZERO;
    }

    unchecked {
        // Checking for overflow this way is faster than letting Solidity do it.
        uint256 xyUint = xUint * yUint;
        if (xyUint / xUint != yUint) {
            revert Errors.PRBMath_UD60x18_Gm_Overflow(x, y);
        }

        // We don't need to multiply the result by `UNIT` here because the x*y product picked up a factor of `UNIT`
        // during multiplication. See the comments in {Common.sqrt}.
        result = wrap(Common.sqrt(xyUint));
    }
}

/// @notice Calculates the inverse of x.
///
/// @dev Notes:
/// - The result is rounded toward zero.
///
/// Requirements:
/// - x must not be zero.
///
/// @param x The UD60x18 number for which to calculate the inverse.
/// @return result The inverse as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function inv(UD60x18 x) pure returns (UD60x18 result) {
    unchecked {
        result = wrap(uUNIT_SQUARED / x.unwrap());
    }
}

/// @notice Calculates the natural logarithm of x using the following formula:
///
/// $$
/// ln{x} = log_2{x} / log_2{e}
/// $$
///
/// @dev Notes:
/// - Refer to the notes in {log2}.
/// - The precision isn't sufficiently fine-grained to return exactly `UNIT` when the input is `E`.
///
/// Requirements:
/// - Refer to the requirements in {log2}.
///
/// @param x The UD60x18 number for which to calculate the natural logarithm.
/// @return result The natural logarithm as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function ln(UD60x18 x) pure returns (UD60x18 result) {
    unchecked {
        // Inline the fixed-point multiplication to save gas. This is overflow-safe because the maximum value that
        // {log2} can return is ~196_205294292027477728.
        result = wrap(log2(x).unwrap() * uUNIT / uLOG2_E);
    }
}

/// @notice Calculates the common logarithm of x using the following formula:
///
/// $$
/// log_{10}{x} = log_2{x} / log_2{10}
/// $$
///
/// However, if x is an exact power of ten, a hard coded value is returned.
///
/// @dev Notes:
/// - Refer to the notes in {log2}.
///
/// Requirements:
/// - Refer to the requirements in {log2}.
///
/// @param x The UD60x18 number for which to calculate the common logarithm.
/// @return result The common logarithm as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function log10(UD60x18 x) pure returns (UD60x18 result) {
    uint256 xUint = x.unwrap();
    if (xUint < uUNIT) {
        revert Errors.PRBMath_UD60x18_Log_InputTooSmall(x);
    }

    // Note that the `mul` in this assembly block is the standard multiplication operation, not {UD60x18.mul}.
    // prettier-ignore
    assembly ("memory-safe") {
        switch x
        case 1 { result := mul(uUNIT, sub(0, 18)) }
        case 10 { result := mul(uUNIT, sub(1, 18)) }
        case 100 { result := mul(uUNIT, sub(2, 18)) }
        case 1000 { result := mul(uUNIT, sub(3, 18)) }
        case 10000 { result := mul(uUNIT, sub(4, 18)) }
        case 100000 { result := mul(uUNIT, sub(5, 18)) }
        case 1000000 { result := mul(uUNIT, sub(6, 18)) }
        case 10000000 { result := mul(uUNIT, sub(7, 18)) }
        case 100000000 { result := mul(uUNIT, sub(8, 18)) }
        case 1000000000 { result := mul(uUNIT, sub(9, 18)) }
        case 10000000000 { result := mul(uUNIT, sub(10, 18)) }
        case 100000000000 { result := mul(uUNIT, sub(11, 18)) }
        case 1000000000000 { result := mul(uUNIT, sub(12, 18)) }
        case 10000000000000 { result := mul(uUNIT, sub(13, 18)) }
        case 100000000000000 { result := mul(uUNIT, sub(14, 18)) }
        case 1000000000000000 { result := mul(uUNIT, sub(15, 18)) }
        case 10000000000000000 { result := mul(uUNIT, sub(16, 18)) }
        case 100000000000000000 { result := mul(uUNIT, sub(17, 18)) }
        case 1000000000000000000 { result := 0 }
        case 10000000000000000000 { result := uUNIT }
        case 100000000000000000000 { result := mul(uUNIT, 2) }
        case 1000000000000000000000 { result := mul(uUNIT, 3) }
        case 10000000000000000000000 { result := mul(uUNIT, 4) }
        case 100000000000000000000000 { result := mul(uUNIT, 5) }
        case 1000000000000000000000000 { result := mul(uUNIT, 6) }
        case 10000000000000000000000000 { result := mul(uUNIT, 7) }
        case 100000000000000000000000000 { result := mul(uUNIT, 8) }
        case 1000000000000000000000000000 { result := mul(uUNIT, 9) }
        case 10000000000000000000000000000 { result := mul(uUNIT, 10) }
        case 100000000000000000000000000000 { result := mul(uUNIT, 11) }
        case 1000000000000000000000000000000 { result := mul(uUNIT, 12) }
        case 10000000000000000000000000000000 { result := mul(uUNIT, 13) }
        case 100000000000000000000000000000000 { result := mul(uUNIT, 14) }
        case 1000000000000000000000000000000000 { result := mul(uUNIT, 15) }
        case 10000000000000000000000000000000000 { result := mul(uUNIT, 16) }
        case 100000000000000000000000000000000000 { result := mul(uUNIT, 17) }
        case 1000000000000000000000000000000000000 { result := mul(uUNIT, 18) }
        case 10000000000000000000000000000000000000 { result := mul(uUNIT, 19) }
        case 100000000000000000000000000000000000000 { result := mul(uUNIT, 20) }
        case 1000000000000000000000000000000000000000 { result := mul(uUNIT, 21) }
        case 10000000000000000000000000000000000000000 { result := mul(uUNIT, 22) }
        case 100000000000000000000000000000000000000000 { result := mul(uUNIT, 23) }
        case 1000000000000000000000000000000000000000000 { result := mul(uUNIT, 24) }
        case 10000000000000000000000000000000000000000000 { result := mul(uUNIT, 25) }
        case 100000000000000000000000000000000000000000000 { result := mul(uUNIT, 26) }
        case 1000000000000000000000000000000000000000000000 { result := mul(uUNIT, 27) }
        case 10000000000000000000000000000000000000000000000 { result := mul(uUNIT, 28) }
        case 100000000000000000000000000000000000000000000000 { result := mul(uUNIT, 29) }
        case 1000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 30) }
        case 10000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 31) }
        case 100000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 32) }
        case 1000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 33) }
        case 10000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 34) }
        case 100000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 35) }
        case 1000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 36) }
        case 10000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 37) }
        case 100000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 38) }
        case 1000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 39) }
        case 10000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 40) }
        case 100000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 41) }
        case 1000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 42) }
        case 10000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 43) }
        case 100000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 44) }
        case 1000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 45) }
        case 10000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 46) }
        case 100000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 47) }
        case 1000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 48) }
        case 10000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 49) }
        case 100000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 50) }
        case 1000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 51) }
        case 10000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 52) }
        case 100000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 53) }
        case 1000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 54) }
        case 10000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 55) }
        case 100000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 56) }
        case 1000000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 57) }
        case 10000000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 58) }
        case 100000000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 59) }
        default { result := uMAX_UD60x18 }
    }

    if (result.unwrap() == uMAX_UD60x18) {
        unchecked {
            // Inline the fixed-point division to save gas.
            result = wrap(log2(x).unwrap() * uUNIT / uLOG2_10);
        }
    }
}

/// @notice Calculates the binary logarithm of x using the iterative approximation algorithm:
///
/// $$
/// log_2{x} = n + log_2{y}, \text{ where } y = x*2^{-n}, \ y \in [1, 2)
/// $$
///
/// For $0 \leq x \lt 1$, the input is inverted:
///
/// $$
/// log_2{x} = -log_2{\frac{1}{x}}
/// $$
///
/// @dev See https://en.wikipedia.org/wiki/Binary_logarithm#Iterative_approximation
///
/// Notes:
/// - Due to the lossy precision of the iterative approximation, the results are not perfectly accurate to the last decimal.
///
/// Requirements:
/// - x ≥ UNIT
///
/// @param x The UD60x18 number for which to calculate the binary logarithm.
/// @return result The binary logarithm as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function log2(UD60x18 x) pure returns (UD60x18 result) {
    uint256 xUint = x.unwrap();

    if (xUint < uUNIT) {
        revert Errors.PRBMath_UD60x18_Log_InputTooSmall(x);
    }

    unchecked {
        // Calculate the integer part of the logarithm.
        uint256 n = Common.msb(xUint / uUNIT);

        // This is the integer part of the logarithm as a UD60x18 number. The operation can't overflow because n
        // n is at most 255 and UNIT is 1e18.
        uint256 resultUint = n * uUNIT;

        // Calculate $y = x * 2^{-n}$.
        uint256 y = xUint >> n;

        // If y is the unit number, the fractional part is zero.
        if (y == uUNIT) {
            return wrap(resultUint);
        }

        // Calculate the fractional part via the iterative approximation.
        // The `delta >>= 1` part is equivalent to `delta /= 2`, but shifting bits is more gas efficient.
        uint256 DOUBLE_UNIT = 2e18;
        for (uint256 delta = uHALF_UNIT; delta > 0; delta >>= 1) {
            y = (y * y) / uUNIT;

            // Is y^2 >= 2e18 and so in the range [2e18, 4e18)?
            if (y >= DOUBLE_UNIT) {
                // Add the 2^{-m} factor to the logarithm.
                resultUint += delta;

                // Halve y, which corresponds to z/2 in the Wikipedia article.
                y >>= 1;
            }
        }
        result = wrap(resultUint);
    }
}

/// @notice Multiplies two UD60x18 numbers together, returning a new UD60x18 number.
///
/// @dev Uses {Common.mulDiv} to enable overflow-safe multiplication and division.
///
/// Notes:
/// - Refer to the notes in {Common.mulDiv}.
///
/// Requirements:
/// - Refer to the requirements in {Common.mulDiv}.
///
/// @dev See the documentation in {Common.mulDiv18}.
/// @param x The multiplicand as a UD60x18 number.
/// @param y The multiplier as a UD60x18 number.
/// @return result The product as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function mul(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    result = wrap(Common.mulDiv18(x.unwrap(), y.unwrap()));
}

/// @notice Raises x to the power of y.
///
/// For $1 \leq x \leq \infty$, the following standard formula is used:
///
/// $$
/// x^y = 2^{log_2{x} * y}
/// $$
///
/// For $0 \leq x \lt 1$, since the unsigned {log2} is undefined, an equivalent formula is used:
///
/// $$
/// i = \frac{1}{x}
/// w = 2^{log_2{i} * y}
/// x^y = \frac{1}{w}
/// $$
///
/// @dev Notes:
/// - Refer to the notes in {log2} and {mul}.
/// - Returns `UNIT` for 0^0.
/// - It may not perform well with very small values of x. Consider using SD59x18 as an alternative.
///
/// Requirements:
/// - Refer to the requirements in {exp2}, {log2}, and {mul}.
///
/// @param x The base as a UD60x18 number.
/// @param y The exponent as a UD60x18 number.
/// @return result The result as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function pow(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    uint256 xUint = x.unwrap();
    uint256 yUint = y.unwrap();

    // If both x and y are zero, the result is `UNIT`. If just x is zero, the result is always zero.
    if (xUint == 0) {
        return yUint == 0 ? UNIT : ZERO;
    }
    // If x is `UNIT`, the result is always `UNIT`.
    else if (xUint == uUNIT) {
        return UNIT;
    }

    // If y is zero, the result is always `UNIT`.
    if (yUint == 0) {
        return UNIT;
    }
    // If y is `UNIT`, the result is always x.
    else if (yUint == uUNIT) {
        return x;
    }

    // If x is > UNIT, use the standard formula.
    if (xUint > uUNIT) {
        result = exp2(mul(log2(x), y));
    }
    // Conversely, if x < UNIT, use the equivalent formula.
    else {
        UD60x18 i = wrap(uUNIT_SQUARED / xUint);
        UD60x18 w = exp2(mul(log2(i), y));
        result = wrap(uUNIT_SQUARED / w.unwrap());
    }
}

/// @notice Raises x (a UD60x18 number) to the power y (an unsigned basic integer) using the well-known
/// algorithm "exponentiation by squaring".
///
/// @dev See https://en.wikipedia.org/wiki/Exponentiation_by_squaring.
///
/// Notes:
/// - Refer to the notes in {Common.mulDiv18}.
/// - Returns `UNIT` for 0^0.
///
/// Requirements:
/// - The result must fit in UD60x18.
///
/// @param x The base as a UD60x18 number.
/// @param y The exponent as a uint256.
/// @return result The result as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function powu(UD60x18 x, uint256 y) pure returns (UD60x18 result) {
    // Calculate the first iteration of the loop in advance.
    uint256 xUint = x.unwrap();
    uint256 resultUint = y & 1 > 0 ? xUint : uUNIT;

    // Equivalent to `for(y /= 2; y > 0; y /= 2)`.
    for (y >>= 1; y > 0; y >>= 1) {
        xUint = Common.mulDiv18(xUint, xUint);

        // Equivalent to `y % 2 == 1`.
        if (y & 1 > 0) {
            resultUint = Common.mulDiv18(resultUint, xUint);
        }
    }
    result = wrap(resultUint);
}

/// @notice Calculates the square root of x using the Babylonian method.
///
/// @dev See https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method.
///
/// Notes:
/// - The result is rounded toward zero.
///
/// Requirements:
/// - x ≤ MAX_UD60x18 / UNIT
///
/// @param x The UD60x18 number for which to calculate the square root.
/// @return result The result as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function sqrt(UD60x18 x) pure returns (UD60x18 result) {
    uint256 xUint = x.unwrap();

    unchecked {
        if (xUint > uMAX_UD60x18 / uUNIT) {
            revert Errors.PRBMath_UD60x18_Sqrt_Overflow(x);
        }
        // Multiply x by `UNIT` to account for the factor of `UNIT` picked up when multiplying two UD60x18 numbers.
        // In this case, the two numbers are both the square root.
        result = wrap(Common.sqrt(xUint * uUNIT));
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "./Casting.sol" as Casting;
import "./Helpers.sol" as Helpers;
import "./Math.sol" as Math;

/// @notice The unsigned 60.18-decimal fixed-point number representation, which can have up to 60 digits and up to 18
/// decimals. The values of this are bound by the minimum and the maximum values permitted by the Solidity type uint256.
/// @dev The value type is defined here so it can be imported in all other files.
type UD60x18 is uint256;

/*//////////////////////////////////////////////////////////////////////////
                                    CASTING
//////////////////////////////////////////////////////////////////////////*/

using {
    Casting.intoSD1x18,
    Casting.intoSD21x18,
    Casting.intoSD59x18,
    Casting.intoUD2x18,
    Casting.intoUD21x18,
    Casting.intoUint128,
    Casting.intoUint256,
    Casting.intoUint40,
    Casting.unwrap
} for UD60x18 global;

/*//////////////////////////////////////////////////////////////////////////
                            MATHEMATICAL FUNCTIONS
//////////////////////////////////////////////////////////////////////////*/

// The global "using for" directive makes the functions in this library callable on the UD60x18 type.
using {
    Math.avg,
    Math.ceil,
    Math.div,
    Math.exp,
    Math.exp2,
    Math.floor,
    Math.frac,
    Math.gm,
    Math.inv,
    Math.ln,
    Math.log10,
    Math.log2,
    Math.mul,
    Math.pow,
    Math.powu,
    Math.sqrt
} for UD60x18 global;

/*//////////////////////////////////////////////////////////////////////////
                                HELPER FUNCTIONS
//////////////////////////////////////////////////////////////////////////*/

// The global "using for" directive makes the functions in this library callable on the UD60x18 type.
using {
    Helpers.add,
    Helpers.and,
    Helpers.eq,
    Helpers.gt,
    Helpers.gte,
    Helpers.isZero,
    Helpers.lshift,
    Helpers.lt,
    Helpers.lte,
    Helpers.mod,
    Helpers.neq,
    Helpers.not,
    Helpers.or,
    Helpers.rshift,
    Helpers.sub,
    Helpers.uncheckedAdd,
    Helpers.uncheckedSub,
    Helpers.xor
} for UD60x18 global;

/*//////////////////////////////////////////////////////////////////////////
                                    OPERATORS
//////////////////////////////////////////////////////////////////////////*/

// The global "using for" directive makes it possible to use these operators on the UD60x18 type.
using {
    Helpers.add as +,
    Helpers.and2 as &,
    Math.div as /,
    Helpers.eq as ==,
    Helpers.gt as >,
    Helpers.gte as >=,
    Helpers.lt as <,
    Helpers.lte as <=,
    Helpers.or as |,
    Helpers.mod as %,
    Math.mul as *,
    Helpers.neq as !=,
    Helpers.not as ~,
    Helpers.sub as -,
    Helpers.xor as ^
} for UD60x18 global;
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Class with helper read functions for clone with immutable args.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/Clone.sol)
/// @author Adapted from clones with immutable args by zefram.eth, Saw-mon & Natalie
/// (https://github.com/Saw-mon-and-Natalie/clones-with-immutable-args)
abstract contract Clone {
    /// @dev Reads all of the immutable args.
    function _getArgBytes() internal pure returns (bytes memory arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := mload(0x40)
            let length := sub(calldatasize(), add(2, offset)) // 2 bytes are used for the length.
            mstore(arg, length) // Store the length.
            calldatacopy(add(arg, 0x20), offset, length)
            let o := add(add(arg, 0x20), length)
            mstore(o, 0) // Zeroize the slot after the bytes.
            mstore(0x40, add(o, 0x20)) // Allocate the memory.
        }
    }

    /// @dev Reads an immutable arg with type bytes.
    function _getArgBytes(uint256 argOffset, uint256 length)
        internal
        pure
        returns (bytes memory arg)
    {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := mload(0x40)
            mstore(arg, length) // Store the length.
            calldatacopy(add(arg, 0x20), add(offset, argOffset), length)
            let o := add(add(arg, 0x20), length)
            mstore(o, 0) // Zeroize the slot after the bytes.
            mstore(0x40, add(o, 0x20)) // Allocate the memory.
        }
    }

    /// @dev Reads an immutable arg with type address.
    function _getArgAddress(uint256 argOffset) internal pure returns (address arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(96, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads a uint256 array stored in the immutable args.
    function _getArgUint256Array(uint256 argOffset, uint256 length)
        internal
        pure
        returns (uint256[] memory arg)
    {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := mload(0x40)
            mstore(arg, length) // Store the length.
            calldatacopy(add(arg, 0x20), add(offset, argOffset), shl(5, length))
            mstore(0x40, add(add(arg, 0x20), shl(5, length))) // Allocate the memory.
        }
    }

    /// @dev Reads a bytes32 array stored in the immutable args.
    function _getArgBytes32Array(uint256 argOffset, uint256 length)
        internal
        pure
        returns (bytes32[] memory arg)
    {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := mload(0x40)
            mstore(arg, length) // Store the length.
            calldatacopy(add(arg, 0x20), add(offset, argOffset), shl(5, length))
            mstore(0x40, add(add(arg, 0x20), shl(5, length))) // Allocate the memory.
        }
    }

    /// @dev Reads an immutable arg with type bytes32.
    function _getArgBytes32(uint256 argOffset) internal pure returns (bytes32 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := calldataload(add(offset, argOffset))
        }
    }

    /// @dev Reads an immutable arg with type uint256.
    function _getArgUint256(uint256 argOffset) internal pure returns (uint256 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := calldataload(add(offset, argOffset))
        }
    }

    /// @dev Reads an immutable arg with type uint248.
    function _getArgUint248(uint256 argOffset) internal pure returns (uint248 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(8, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint240.
    function _getArgUint240(uint256 argOffset) internal pure returns (uint240 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(16, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint232.
    function _getArgUint232(uint256 argOffset) internal pure returns (uint232 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(24, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint224.
    function _getArgUint224(uint256 argOffset) internal pure returns (uint224 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(0x20, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint216.
    function _getArgUint216(uint256 argOffset) internal pure returns (uint216 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(40, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint208.
    function _getArgUint208(uint256 argOffset) internal pure returns (uint208 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(48, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint200.
    function _getArgUint200(uint256 argOffset) internal pure returns (uint200 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(56, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint192.
    function _getArgUint192(uint256 argOffset) internal pure returns (uint192 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(64, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint184.
    function _getArgUint184(uint256 argOffset) internal pure returns (uint184 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(72, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint176.
    function _getArgUint176(uint256 argOffset) internal pure returns (uint176 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(80, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint168.
    function _getArgUint168(uint256 argOffset) internal pure returns (uint168 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(88, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint160.
    function _getArgUint160(uint256 argOffset) internal pure returns (uint160 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(96, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint152.
    function _getArgUint152(uint256 argOffset) internal pure returns (uint152 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(104, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint144.
    function _getArgUint144(uint256 argOffset) internal pure returns (uint144 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(112, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint136.
    function _getArgUint136(uint256 argOffset) internal pure returns (uint136 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(120, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint128.
    function _getArgUint128(uint256 argOffset) internal pure returns (uint128 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(128, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint120.
    function _getArgUint120(uint256 argOffset) internal pure returns (uint120 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(136, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint112.
    function _getArgUint112(uint256 argOffset) internal pure returns (uint112 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(144, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint104.
    function _getArgUint104(uint256 argOffset) internal pure returns (uint104 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(152, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint96.
    function _getArgUint96(uint256 argOffset) internal pure returns (uint96 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(160, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint88.
    function _getArgUint88(uint256 argOffset) internal pure returns (uint88 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(168, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint80.
    function _getArgUint80(uint256 argOffset) internal pure returns (uint80 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(176, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint72.
    function _getArgUint72(uint256 argOffset) internal pure returns (uint72 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(184, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint64.
    function _getArgUint64(uint256 argOffset) internal pure returns (uint64 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(192, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint56.
    function _getArgUint56(uint256 argOffset) internal pure returns (uint56 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(200, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint48.
    function _getArgUint48(uint256 argOffset) internal pure returns (uint48 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(208, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint40.
    function _getArgUint40(uint256 argOffset) internal pure returns (uint40 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(216, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint32.
    function _getArgUint32(uint256 argOffset) internal pure returns (uint32 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(224, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint24.
    function _getArgUint24(uint256 argOffset) internal pure returns (uint24 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(232, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint16.
    function _getArgUint16(uint256 argOffset) internal pure returns (uint16 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(240, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint8.
    function _getArgUint8(uint256 argOffset) internal pure returns (uint8 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(248, calldataload(add(offset, argOffset)))
        }
    }

    /// @return offset The offset of the packed immutable args in calldata.
    function _getImmutableArgsOffset() internal pure returns (uint256 offset) {
        /// @solidity memory-safe-assembly
        assembly {
            offset := sub(calldatasize(), shr(240, calldataload(sub(calldatasize(), 2))))
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Gas optimized ECDSA wrapper.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/ECDSA.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/ECDSA.sol)
/// @author Modified from OpenZeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/cryptography/ECDSA.sol)
///
/// @dev Note:
/// - The recovery functions use the ecrecover precompile (0x1).
/// - As of Solady version 0.0.68, the `recover` variants will revert upon recovery failure.
///   This is for more safety by default.
///   Use the `tryRecover` variants if you need to get the zero address back
///   upon recovery failure instead.
/// - As of Solady version 0.0.134, all `bytes signature` variants accept both
///   regular 65-byte `(r, s, v)` and EIP-2098 `(r, vs)` short form signatures.
///   See: https://eips.ethereum.org/EIPS/eip-2098
///   This is for calldata efficiency on smart accounts prevalent on L2s.
///
/// WARNING! Do NOT use signatures as unique identifiers:
/// - Use a nonce in the digest to prevent replay attacks on the same contract.
/// - Use EIP-712 for the digest to prevent replay attacks across different chains and contracts.
///   EIP-712 also enables readable signing of typed data for better user safety.
/// This implementation does NOT check if a signature is non-malleable.
library ECDSA {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                        CUSTOM ERRORS                       */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The signature is invalid.
    error InvalidSignature();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                    RECOVERY OPERATIONS                     */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Recovers the signer's address from a message digest `hash`, and the `signature`.
    function recover(bytes32 hash, bytes memory signature) internal view returns (address result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := 1
            let m := mload(0x40) // Cache the free memory pointer.
            for {} 1 {} {
                mstore(0x00, hash)
                mstore(0x40, mload(add(signature, 0x20))) // `r`.
                if eq(mload(signature), 64) {
                    let vs := mload(add(signature, 0x40))
                    mstore(0x20, add(shr(255, vs), 27)) // `v`.
                    mstore(0x60, shr(1, shl(1, vs))) // `s`.
                    break
                }
                if eq(mload(signature), 65) {
                    mstore(0x20, byte(0, mload(add(signature, 0x60)))) // `v`.
                    mstore(0x60, mload(add(signature, 0x40))) // `s`.
                    break
                }
                result := 0
                break
            }
            result :=
                mload(
                    staticcall(
                        gas(), // Amount of gas left for the transaction.
                        result, // Address of `ecrecover`.
                        0x00, // Start of input.
                        0x80, // Size of input.
                        0x01, // Start of output.
                        0x20 // Size of output.
                    )
                )
            // `returndatasize()` will be `0x20` upon success, and `0x00` otherwise.
            if iszero(returndatasize()) {
                mstore(0x00, 0x8baa579f) // `InvalidSignature()`.
                revert(0x1c, 0x04)
            }
            mstore(0x60, 0) // Restore the zero slot.
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Recovers the signer's address from a message digest `hash`, and the `signature`.
    function recoverCalldata(bytes32 hash, bytes calldata signature)
        internal
        view
        returns (address result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            result := 1
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x00, hash)
            for {} 1 {} {
                if eq(signature.length, 64) {
                    let vs := calldataload(add(signature.offset, 0x20))
                    mstore(0x20, add(shr(255, vs), 27)) // `v`.
                    mstore(0x40, calldataload(signature.offset)) // `r`.
                    mstore(0x60, shr(1, shl(1, vs))) // `s`.
                    break
                }
                if eq(signature.length, 65) {
                    mstore(0x20, byte(0, calldataload(add(signature.offset, 0x40)))) // `v`.
                    calldatacopy(0x40, signature.offset, 0x40) // Copy `r` and `s`.
                    break
                }
                result := 0
                break
            }
            result :=
                mload(
                    staticcall(
                        gas(), // Amount of gas left for the transaction.
                        result, // Address of `ecrecover`.
                        0x00, // Start of input.
                        0x80, // Size of input.
                        0x01, // Start of output.
                        0x20 // Size of output.
                    )
                )
            // `returndatasize()` will be `0x20` upon success, and `0x00` otherwise.
            if iszero(returndatasize()) {
                mstore(0x00, 0x8baa579f) // `InvalidSignature()`.
                revert(0x1c, 0x04)
            }
            mstore(0x60, 0) // Restore the zero slot.
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Recovers the signer's address from a message digest `hash`,
    /// and the EIP-2098 short form signature defined by `r` and `vs`.
    function recover(bytes32 hash, bytes32 r, bytes32 vs) internal view returns (address result) {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x00, hash)
            mstore(0x20, add(shr(255, vs), 27)) // `v`.
            mstore(0x40, r)
            mstore(0x60, shr(1, shl(1, vs))) // `s`.
            result :=
                mload(
                    staticcall(
                        gas(), // Amount of gas left for the transaction.
                        1, // Address of `ecrecover`.
                        0x00, // Start of input.
                        0x80, // Size of input.
                        0x01, // Start of output.
                        0x20 // Size of output.
                    )
                )
            // `returndatasize()` will be `0x20` upon success, and `0x00` otherwise.
            if iszero(returndatasize()) {
                mstore(0x00, 0x8baa579f) // `InvalidSignature()`.
                revert(0x1c, 0x04)
            }
            mstore(0x60, 0) // Restore the zero slot.
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Recovers the signer's address from a message digest `hash`,
    /// and the signature defined by `v`, `r`, `s`.
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s)
        internal
        view
        returns (address result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x00, hash)
            mstore(0x20, and(v, 0xff))
            mstore(0x40, r)
            mstore(0x60, s)
            result :=
                mload(
                    staticcall(
                        gas(), // Amount of gas left for the transaction.
                        1, // Address of `ecrecover`.
                        0x00, // Start of input.
                        0x80, // Size of input.
                        0x01, // Start of output.
                        0x20 // Size of output.
                    )
                )
            // `returndatasize()` will be `0x20` upon success, and `0x00` otherwise.
            if iszero(returndatasize()) {
                mstore(0x00, 0x8baa579f) // `InvalidSignature()`.
                revert(0x1c, 0x04)
            }
            mstore(0x60, 0) // Restore the zero slot.
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                   TRY-RECOVER OPERATIONS                   */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // WARNING!
    // These functions will NOT revert upon recovery failure.
    // Instead, they will return the zero address upon recovery failure.
    // It is critical that the returned address is NEVER compared against
    // a zero address (e.g. an uninitialized address variable).

    /// @dev Recovers the signer's address from a message digest `hash`, and the `signature`.
    function tryRecover(bytes32 hash, bytes memory signature)
        internal
        view
        returns (address result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            result := 1
            let m := mload(0x40) // Cache the free memory pointer.
            for {} 1 {} {
                mstore(0x00, hash)
                mstore(0x40, mload(add(signature, 0x20))) // `r`.
                if eq(mload(signature), 64) {
                    let vs := mload(add(signature, 0x40))
                    mstore(0x20, add(shr(255, vs), 27)) // `v`.
                    mstore(0x60, shr(1, shl(1, vs))) // `s`.
                    break
                }
                if eq(mload(signature), 65) {
                    mstore(0x20, byte(0, mload(add(signature, 0x60)))) // `v`.
                    mstore(0x60, mload(add(signature, 0x40))) // `s`.
                    break
                }
                result := 0
                break
            }
            pop(
                staticcall(
                    gas(), // Amount of gas left for the transaction.
                    result, // Address of `ecrecover`.
                    0x00, // Start of input.
                    0x80, // Size of input.
                    0x40, // Start of output.
                    0x20 // Size of output.
                )
            )
            mstore(0x60, 0) // Restore the zero slot.
            // `returndatasize()` will be `0x20` upon success, and `0x00` otherwise.
            result := mload(xor(0x60, returndatasize()))
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Recovers the signer's address from a message digest `hash`, and the `signature`.
    function tryRecoverCalldata(bytes32 hash, bytes calldata signature)
        internal
        view
        returns (address result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            result := 1
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x00, hash)
            for {} 1 {} {
                if eq(signature.length, 64) {
                    let vs := calldataload(add(signature.offset, 0x20))
                    mstore(0x20, add(shr(255, vs), 27)) // `v`.
                    mstore(0x40, calldataload(signature.offset)) // `r`.
                    mstore(0x60, shr(1, shl(1, vs))) // `s`.
                    break
                }
                if eq(signature.length, 65) {
                    mstore(0x20, byte(0, calldataload(add(signature.offset, 0x40)))) // `v`.
                    calldatacopy(0x40, signature.offset, 0x40) // Copy `r` and `s`.
                    break
                }
                result := 0
                break
            }
            pop(
                staticcall(
                    gas(), // Amount of gas left for the transaction.
                    result, // Address of `ecrecover`.
                    0x00, // Start of input.
                    0x80, // Size of input.
                    0x40, // Start of output.
                    0x20 // Size of output.
                )
            )
            mstore(0x60, 0) // Restore the zero slot.
            // `returndatasize()` will be `0x20` upon success, and `0x00` otherwise.
            result := mload(xor(0x60, returndatasize()))
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Recovers the signer's address from a message digest `hash`,
    /// and the EIP-2098 short form signature defined by `r` and `vs`.
    function tryRecover(bytes32 hash, bytes32 r, bytes32 vs)
        internal
        view
        returns (address result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x00, hash)
            mstore(0x20, add(shr(255, vs), 27)) // `v`.
            mstore(0x40, r)
            mstore(0x60, shr(1, shl(1, vs))) // `s`.
            pop(
                staticcall(
                    gas(), // Amount of gas left for the transaction.
                    1, // Address of `ecrecover`.
                    0x00, // Start of input.
                    0x80, // Size of input.
                    0x40, // Start of output.
                    0x20 // Size of output.
                )
            )
            mstore(0x60, 0) // Restore the zero slot.
            // `returndatasize()` will be `0x20` upon success, and `0x00` otherwise.
            result := mload(xor(0x60, returndatasize()))
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Recovers the signer's address from a message digest `hash`,
    /// and the signature defined by `v`, `r`, `s`.
    function tryRecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s)
        internal
        view
        returns (address result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x00, hash)
            mstore(0x20, and(v, 0xff))
            mstore(0x40, r)
            mstore(0x60, s)
            pop(
                staticcall(
                    gas(), // Amount of gas left for the transaction.
                    1, // Address of `ecrecover`.
                    0x00, // Start of input.
                    0x80, // Size of input.
                    0x40, // Start of output.
                    0x20 // Size of output.
                )
            )
            mstore(0x60, 0) // Restore the zero slot.
            // `returndatasize()` will be `0x20` upon success, and `0x00` otherwise.
            result := mload(xor(0x60, returndatasize()))
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                     HASHING OPERATIONS                     */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns an Ethereum Signed Message, created from a `hash`.
    /// This produces a hash corresponding to the one signed with the
    /// [`eth_sign`](https://eth.wiki/json-rpc/API#eth_sign)
    /// JSON-RPC method as part of EIP-191.
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32 result) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x20, hash) // Store into scratch space for keccak256.
            mstore(0x00, "\x00\x00\x00\x00\x19Ethereum Signed Message:\n32") // 28 bytes.
            result := keccak256(0x04, 0x3c) // `32 * 2 - (32 - 28) = 60 = 0x3c`.
        }
    }

    /// @dev Returns an Ethereum Signed Message, created from `s`.
    /// This produces a hash corresponding to the one signed with the
    /// [`eth_sign`](https://eth.wiki/json-rpc/API#eth_sign)
    /// JSON-RPC method as part of EIP-191.
    /// Note: Supports lengths of `s` up to 999999 bytes.
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32 result) {
        /// @solidity memory-safe-assembly
        assembly {
            let sLength := mload(s)
            let o := 0x20
            mstore(o, "\x19Ethereum Signed Message:\n") // 26 bytes, zero-right-padded.
            mstore(0x00, 0x00)
            // Convert the `s.length` to ASCII decimal representation: `base10(s.length)`.
            for { let temp := sLength } 1 {} {
                o := sub(o, 1)
                mstore8(o, add(48, mod(temp, 10)))
                temp := div(temp, 10)
                if iszero(temp) { break }
            }
            let n := sub(0x3a, o) // Header length: `26 + 32 - o`.
            // Throw an out-of-offset error (consumes all gas) if the header exceeds 32 bytes.
            returndatacopy(returndatasize(), returndatasize(), gt(n, 0x20))
            mstore(s, or(mload(0x00), mload(n))) // Temporarily store the header.
            result := keccak256(add(s, sub(0x20, n)), add(n, sLength))
            mstore(s, sLength) // Restore the length.
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                   EMPTY CALLDATA HELPERS                   */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns an empty calldata bytes.
    function emptySignature() internal pure returns (bytes calldata signature) {
        /// @solidity memory-safe-assembly
        assembly {
            signature.length := 0
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Contract for EIP-712 typed structured data hashing and signing.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/EIP712.sol)
/// @author Modified from Solbase (https://github.com/Sol-DAO/solbase/blob/main/src/utils/EIP712.sol)
/// @author Modified from OpenZeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/cryptography/EIP712.sol)
///
/// @dev Note, this implementation:
/// - Uses `address(this)` for the `verifyingContract` field.
/// - Does NOT use the optional EIP-712 salt.
/// - Does NOT use any EIP-712 extensions.
/// This is for simplicity and to save gas.
/// If you need to customize, please fork / modify accordingly.
abstract contract EIP712 {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                  CONSTANTS AND IMMUTABLES                  */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev `keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)")`.
    bytes32 internal constant _DOMAIN_TYPEHASH =
        0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f;

    uint256 private immutable _cachedThis;
    uint256 private immutable _cachedChainId;
    bytes32 private immutable _cachedNameHash;
    bytes32 private immutable _cachedVersionHash;
    bytes32 private immutable _cachedDomainSeparator;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                        CONSTRUCTOR                         */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Cache the hashes for cheaper runtime gas costs.
    /// In the case of upgradeable contracts (i.e. proxies),
    /// or if the chain id changes due to a hard fork,
    /// the domain separator will be seamlessly calculated on-the-fly.
    constructor() {
        _cachedThis = uint256(uint160(address(this)));
        _cachedChainId = block.chainid;

        string memory name;
        string memory version;
        if (!_domainNameAndVersionMayChange()) (name, version) = _domainNameAndVersion();
        bytes32 nameHash = _domainNameAndVersionMayChange() ? bytes32(0) : keccak256(bytes(name));
        bytes32 versionHash =
            _domainNameAndVersionMayChange() ? bytes32(0) : keccak256(bytes(version));
        _cachedNameHash = nameHash;
        _cachedVersionHash = versionHash;

        bytes32 separator;
        if (!_domainNameAndVersionMayChange()) {
            /// @solidity memory-safe-assembly
            assembly {
                let m := mload(0x40) // Load the free memory pointer.
                mstore(m, _DOMAIN_TYPEHASH)
                mstore(add(m, 0x20), nameHash)
                mstore(add(m, 0x40), versionHash)
                mstore(add(m, 0x60), chainid())
                mstore(add(m, 0x80), address())
                separator := keccak256(m, 0xa0)
            }
        }
        _cachedDomainSeparator = separator;
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                   FUNCTIONS TO OVERRIDE                    */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Please override this function to return the domain name and version.
    /// ```
    ///     function _domainNameAndVersion()
    ///         internal
    ///         pure
    ///         virtual
    ///         returns (string memory name, string memory version)
    ///     {
    ///         name = "Solady";
    ///         version = "1";
    ///     }
    /// ```
    ///
    /// Note: If the returned result may change after the contract has been deployed,
    /// you must override `_domainNameAndVersionMayChange()` to return true.
    function _domainNameAndVersion()
        internal
        view
        virtual
        returns (string memory name, string memory version);

    /// @dev Returns if `_domainNameAndVersion()` may change
    /// after the contract has been deployed (i.e. after the constructor).
    /// Default: false.
    function _domainNameAndVersionMayChange() internal pure virtual returns (bool result) {}

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                     HASHING OPERATIONS                     */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns the EIP-712 domain separator.
    function _domainSeparator() internal view virtual returns (bytes32 separator) {
        if (_domainNameAndVersionMayChange()) {
            separator = _buildDomainSeparator();
        } else {
            separator = _cachedDomainSeparator;
            if (_cachedDomainSeparatorInvalidated()) separator = _buildDomainSeparator();
        }
    }

    /// @dev Returns the hash of the fully encoded EIP-712 message for this domain,
    /// given `structHash`, as defined in
    /// https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct.
    ///
    /// The hash can be used together with {ECDSA-recover} to obtain the signer of a message:
    /// ```
    ///     bytes32 digest = _hashTypedData(keccak256(abi.encode(
    ///         keccak256("Mail(address to,string contents)"),
    ///         mailTo,
    ///         keccak256(bytes(mailContents))
    ///     )));
    ///     address signer = ECDSA.recover(digest, signature);
    /// ```
    function _hashTypedData(bytes32 structHash) internal view virtual returns (bytes32 digest) {
        // We will use `digest` to store the domain separator to save a bit of gas.
        if (_domainNameAndVersionMayChange()) {
            digest = _buildDomainSeparator();
        } else {
            digest = _cachedDomainSeparator;
            if (_cachedDomainSeparatorInvalidated()) digest = _buildDomainSeparator();
        }
        /// @solidity memory-safe-assembly
        assembly {
            // Compute the digest.
            mstore(0x00, 0x1901000000000000) // Store "\x19\x01".
            mstore(0x1a, digest) // Store the domain separator.
            mstore(0x3a, structHash) // Store the struct hash.
            digest := keccak256(0x18, 0x42)
            // Restore the part of the free memory slot that was overwritten.
            mstore(0x3a, 0)
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                    EIP-5267 OPERATIONS                     */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev See: https://eips.ethereum.org/EIPS/eip-5267
    function eip712Domain()
        public
        view
        virtual
        returns (
            bytes1 fields,
            string memory name,
            string memory version,
            uint256 chainId,
            address verifyingContract,
            bytes32 salt,
            uint256[] memory extensions
        )
    {
        fields = hex"0f"; // `0b01111`.
        (name, version) = _domainNameAndVersion();
        chainId = block.chainid;
        verifyingContract = address(this);
        salt = salt; // `bytes32(0)`.
        extensions = extensions; // `new uint256[](0)`.
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      PRIVATE HELPERS                       */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns the EIP-712 domain separator.
    function _buildDomainSeparator() private view returns (bytes32 separator) {
        // We will use `separator` to store the name hash to save a bit of gas.
        bytes32 versionHash;
        if (_domainNameAndVersionMayChange()) {
            (string memory name, string memory version) = _domainNameAndVersion();
            separator = keccak256(bytes(name));
            versionHash = keccak256(bytes(version));
        } else {
            separator = _cachedNameHash;
            versionHash = _cachedVersionHash;
        }
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Load the free memory pointer.
            mstore(m, _DOMAIN_TYPEHASH)
            mstore(add(m, 0x20), separator) // Name hash.
            mstore(add(m, 0x40), versionHash)
            mstore(add(m, 0x60), chainid())
            mstore(add(m, 0x80), address())
            separator := keccak256(m, 0xa0)
        }
    }

    /// @dev Returns if the cached domain separator has been invalidated.
    function _cachedDomainSeparatorInvalidated() private view returns (bool result) {
        uint256 cachedChainId = _cachedChainId;
        uint256 cachedThis = _cachedThis;
        /// @solidity memory-safe-assembly
        assembly {
            result := iszero(and(eq(chainid(), cachedChainId), eq(address(), cachedThis)))
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Arithmetic library with operations for fixed-point numbers.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/FixedPointMathLib.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/FixedPointMathLib.sol)
library FixedPointMathLib {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       CUSTOM ERRORS                        */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The operation failed, as the output exceeds the maximum value of uint256.
    error ExpOverflow();

    /// @dev The operation failed, as the output exceeds the maximum value of uint256.
    error FactorialOverflow();

    /// @dev The operation failed, due to an overflow.
    error RPowOverflow();

    /// @dev The mantissa is too big to fit.
    error MantissaOverflow();

    /// @dev The operation failed, due to an multiplication overflow.
    error MulWadFailed();

    /// @dev The operation failed, due to an multiplication overflow.
    error SMulWadFailed();

    /// @dev The operation failed, either due to a multiplication overflow, or a division by a zero.
    error DivWadFailed();

    /// @dev The operation failed, either due to a multiplication overflow, or a division by a zero.
    error SDivWadFailed();

    /// @dev The operation failed, either due to a multiplication overflow, or a division by a zero.
    error MulDivFailed();

    /// @dev The division failed, as the denominator is zero.
    error DivFailed();

    /// @dev The full precision multiply-divide operation failed, either due
    /// to the result being larger than 256 bits, or a division by a zero.
    error FullMulDivFailed();

    /// @dev The output is undefined, as the input is less-than-or-equal to zero.
    error LnWadUndefined();

    /// @dev The input outside the acceptable domain.
    error OutOfDomain();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         CONSTANTS                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The scalar of ETH and most ERC20s.
    uint256 internal constant WAD = 1e18;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*              SIMPLIFIED FIXED POINT OPERATIONS             */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Equivalent to `(x * y) / WAD` rounded down.
    function mulWad(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Equivalent to `require(y == 0 || x <= type(uint256).max / y)`.
            if mul(y, gt(x, div(not(0), y))) {
                mstore(0x00, 0xbac65e5b) // `MulWadFailed()`.
                revert(0x1c, 0x04)
            }
            z := div(mul(x, y), WAD)
        }
    }

    /// @dev Equivalent to `(x * y) / WAD` rounded down.
    function sMulWad(int256 x, int256 y) internal pure returns (int256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := mul(x, y)
            // Equivalent to `require((x == 0 || z / x == y) && !(x == -1 && y == type(int256).min))`.
            if iszero(gt(or(iszero(x), eq(sdiv(z, x), y)), lt(not(x), eq(y, shl(255, 1))))) {
                mstore(0x00, 0xedcd4dd4) // `SMulWadFailed()`.
                revert(0x1c, 0x04)
            }
            z := sdiv(z, WAD)
        }
    }

    /// @dev Equivalent to `(x * y) / WAD` rounded down, but without overflow checks.
    function rawMulWad(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := div(mul(x, y), WAD)
        }
    }

    /// @dev Equivalent to `(x * y) / WAD` rounded down, but without overflow checks.
    function rawSMulWad(int256 x, int256 y) internal pure returns (int256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := sdiv(mul(x, y), WAD)
        }
    }

    /// @dev Equivalent to `(x * y) / WAD` rounded up.
    function mulWadUp(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Equivalent to `require(y == 0 || x <= type(uint256).max / y)`.
            if mul(y, gt(x, div(not(0), y))) {
                mstore(0x00, 0xbac65e5b) // `MulWadFailed()`.
                revert(0x1c, 0x04)
            }
            z := add(iszero(iszero(mod(mul(x, y), WAD))), div(mul(x, y), WAD))
        }
    }

    /// @dev Equivalent to `(x * y) / WAD` rounded up, but without overflow checks.
    function rawMulWadUp(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := add(iszero(iszero(mod(mul(x, y), WAD))), div(mul(x, y), WAD))
        }
    }

    /// @dev Equivalent to `(x * WAD) / y` rounded down.
    function divWad(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Equivalent to `require(y != 0 && (WAD == 0 || x <= type(uint256).max / WAD))`.
            if iszero(mul(y, iszero(mul(WAD, gt(x, div(not(0), WAD)))))) {
                mstore(0x00, 0x7c5f487d) // `DivWadFailed()`.
                revert(0x1c, 0x04)
            }
            z := div(mul(x, WAD), y)
        }
    }

    /// @dev Equivalent to `(x * WAD) / y` rounded down.
    function sDivWad(int256 x, int256 y) internal pure returns (int256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := mul(x, WAD)
            // Equivalent to `require(y != 0 && ((x * WAD) / WAD == x))`.
            if iszero(and(iszero(iszero(y)), eq(sdiv(z, WAD), x))) {
                mstore(0x00, 0x5c43740d) // `SDivWadFailed()`.
                revert(0x1c, 0x04)
            }
            z := sdiv(mul(x, WAD), y)
        }
    }

    /// @dev Equivalent to `(x * WAD) / y` rounded down, but without overflow and divide by zero checks.
    function rawDivWad(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := div(mul(x, WAD), y)
        }
    }

    /// @dev Equivalent to `(x * WAD) / y` rounded down, but without overflow and divide by zero checks.
    function rawSDivWad(int256 x, int256 y) internal pure returns (int256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := sdiv(mul(x, WAD), y)
        }
    }

    /// @dev Equivalent to `(x * WAD) / y` rounded up.
    function divWadUp(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Equivalent to `require(y != 0 && (WAD == 0 || x <= type(uint256).max / WAD))`.
            if iszero(mul(y, iszero(mul(WAD, gt(x, div(not(0), WAD)))))) {
                mstore(0x00, 0x7c5f487d) // `DivWadFailed()`.
                revert(0x1c, 0x04)
            }
            z := add(iszero(iszero(mod(mul(x, WAD), y))), div(mul(x, WAD), y))
        }
    }

    /// @dev Equivalent to `(x * WAD) / y` rounded up, but without overflow and divide by zero checks.
    function rawDivWadUp(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := add(iszero(iszero(mod(mul(x, WAD), y))), div(mul(x, WAD), y))
        }
    }

    /// @dev Equivalent to `x` to the power of `y`.
    /// because `x ** y = (e ** ln(x)) ** y = e ** (ln(x) * y)`.
    function powWad(int256 x, int256 y) internal pure returns (int256) {
        // Using `ln(x)` means `x` must be greater than 0.
        return expWad((lnWad(x) * y) / int256(WAD));
    }

    /// @dev Returns `exp(x)`, denominated in `WAD`.
    /// Credit to Remco Bloemen under MIT license: https://2π.com/22/exp-ln
    function expWad(int256 x) internal pure returns (int256 r) {
        unchecked {
            // When the result is less than 0.5 we return zero.
            // This happens when `x <= (log(1e-18) * 1e18) ~ -4.15e19`.
            if (x <= -41446531673892822313) return r;

            /// @solidity memory-safe-assembly
            assembly {
                // When the result is greater than `(2**255 - 1) / 1e18` we can not represent it as
                // an int. This happens when `x >= floor(log((2**255 - 1) / 1e18) * 1e18) ≈ 135`.
                if iszero(slt(x, 135305999368893231589)) {
                    mstore(0x00, 0xa37bfec9) // `ExpOverflow()`.
                    revert(0x1c, 0x04)
                }
            }

            // `x` is now in the range `(-42, 136) * 1e18`. Convert to `(-42, 136) * 2**96`
            // for more intermediate precision and a binary basis. This base conversion
            // is a multiplication by 1e18 / 2**96 = 5**18 / 2**78.
            x = (x << 78) / 5 ** 18;

            // Reduce range of x to (-½ ln 2, ½ ln 2) * 2**96 by factoring out powers
            // of two such that exp(x) = exp(x') * 2**k, where k is an integer.
            // Solving this gives k = round(x / log(2)) and x' = x - k * log(2).
            int256 k = ((x << 96) / 54916777467707473351141471128 + 2 ** 95) >> 96;
            x = x - k * 54916777467707473351141471128;

            // `k` is in the range `[-61, 195]`.

            // Evaluate using a (6, 7)-term rational approximation.
            // `p` is made monic, we'll multiply by a scale factor later.
            int256 y = x + 1346386616545796478920950773328;
            y = ((y * x) >> 96) + 57155421227552351082224309758442;
            int256 p = y + x - 94201549194550492254356042504812;
            p = ((p * y) >> 96) + 28719021644029726153956944680412240;
            p = p * x + (4385272521454847904659076985693276 << 96);

            // We leave `p` in `2**192` basis so we don't need to scale it back up for the division.
            int256 q = x - 2855989394907223263936484059900;
            q = ((q * x) >> 96) + 50020603652535783019961831881945;
            q = ((q * x) >> 96) - 533845033583426703283633433725380;
            q = ((q * x) >> 96) + 3604857256930695427073651918091429;
            q = ((q * x) >> 96) - 14423608567350463180887372962807573;
            q = ((q * x) >> 96) + 26449188498355588339934803723976023;

            /// @solidity memory-safe-assembly
            assembly {
                // Div in assembly because solidity adds a zero check despite the unchecked.
                // The q polynomial won't have zeros in the domain as all its roots are complex.
                // No scaling is necessary because p is already `2**96` too large.
                r := sdiv(p, q)
            }

            // r should be in the range `(0.09, 0.25) * 2**96`.

            // We now need to multiply r by:
            // - The scale factor `s ≈ 6.031367120`.
            // - The `2**k` factor from the range reduction.
            // - The `1e18 / 2**96` factor for base conversion.
            // We do this all at once, with an intermediate result in `2**213`
            // basis, so the final right shift is always by a positive amount.
            r = int256(
                (uint256(r) * 3822833074963236453042738258902158003155416615667) >> uint256(195 - k)
            );
        }
    }

    /// @dev Returns `ln(x)`, denominated in `WAD`.
    /// Credit to Remco Bloemen under MIT license: https://2π.com/22/exp-ln
    function lnWad(int256 x) internal pure returns (int256 r) {
        /// @solidity memory-safe-assembly
        assembly {
            // We want to convert `x` from `10**18` fixed point to `2**96` fixed point.
            // We do this by multiplying by `2**96 / 10**18`. But since
            // `ln(x * C) = ln(x) + ln(C)`, we can simply do nothing here
            // and add `ln(2**96 / 10**18)` at the end.

            // Compute `k = log2(x) - 96`, `r = 159 - k = 255 - log2(x) = 255 ^ log2(x)`.
            r := shl(7, lt(0xffffffffffffffffffffffffffffffff, x))
            r := or(r, shl(6, lt(0xffffffffffffffff, shr(r, x))))
            r := or(r, shl(5, lt(0xffffffff, shr(r, x))))
            r := or(r, shl(4, lt(0xffff, shr(r, x))))
            r := or(r, shl(3, lt(0xff, shr(r, x))))
            // We place the check here for more optimal stack operations.
            if iszero(sgt(x, 0)) {
                mstore(0x00, 0x1615e638) // `LnWadUndefined()`.
                revert(0x1c, 0x04)
            }
            // forgefmt: disable-next-item
            r := xor(r, byte(and(0x1f, shr(shr(r, x), 0x8421084210842108cc6318c6db6d54be)),
                0xf8f9f9faf9fdfafbf9fdfcfdfafbfcfef9fafdfafcfcfbfefafafcfbffffffff))

            // Reduce range of x to (1, 2) * 2**96
            // ln(2^k * x) = k * ln(2) + ln(x)
            x := shr(159, shl(r, x))

            // Evaluate using a (8, 8)-term rational approximation.
            // `p` is made monic, we will multiply by a scale factor later.
            // forgefmt: disable-next-item
            let p := sub( // This heavily nested expression is to avoid stack-too-deep for via-ir.
                sar(96, mul(add(43456485725739037958740375743393,
                sar(96, mul(add(24828157081833163892658089445524,
                sar(96, mul(add(3273285459638523848632254066296,
                    x), x))), x))), x)), 11111509109440967052023855526967)
            p := sub(sar(96, mul(p, x)), 45023709667254063763336534515857)
            p := sub(sar(96, mul(p, x)), 14706773417378608786704636184526)
            p := sub(mul(p, x), shl(96, 795164235651350426258249787498))
            // We leave `p` in `2**192` basis so we don't need to scale it back up for the division.

            // `q` is monic by convention.
            let q := add(5573035233440673466300451813936, x)
            q := add(71694874799317883764090561454958, sar(96, mul(x, q)))
            q := add(283447036172924575727196451306956, sar(96, mul(x, q)))
            q := add(401686690394027663651624208769553, sar(96, mul(x, q)))
            q := add(204048457590392012362485061816622, sar(96, mul(x, q)))
            q := add(31853899698501571402653359427138, sar(96, mul(x, q)))
            q := add(909429971244387300277376558375, sar(96, mul(x, q)))

            // `p / q` is in the range `(0, 0.125) * 2**96`.

            // Finalization, we need to:
            // - Multiply by the scale factor `s = 5.549…`.
            // - Add `ln(2**96 / 10**18)`.
            // - Add `k * ln(2)`.
            // - Multiply by `10**18 / 2**96 = 5**18 >> 78`.

            // The q polynomial is known not to have zeros in the domain.
            // No scaling required because p is already `2**96` too large.
            p := sdiv(p, q)
            // Multiply by the scaling factor: `s * 5**18 * 2**96`, base is now `5**18 * 2**192`.
            p := mul(1677202110996718588342820967067443963516166, p)
            // Add `ln(2) * k * 5**18 * 2**192`.
            // forgefmt: disable-next-item
            p := add(mul(16597577552685614221487285958193947469193820559219878177908093499208371, sub(159, r)), p)
            // Add `ln(2**96 / 10**18) * 5**18 * 2**192`.
            p := add(600920179829731861736702779321621459595472258049074101567377883020018308, p)
            // Base conversion: mul `2**18 / 2**192`.
            r := sar(174, p)
        }
    }

    /// @dev Returns `W_0(x)`, denominated in `WAD`.
    /// See: https://en.wikipedia.org/wiki/Lambert_W_function
    /// a.k.a. Product log function. This is an approximation of the principal branch.
    function lambertW0Wad(int256 x) internal pure returns (int256 w) {
        // forgefmt: disable-next-item
        unchecked {
            if ((w = x) <= -367879441171442322) revert OutOfDomain(); // `x` less than `-1/e`.
            int256 wad = int256(WAD);
            int256 p = x;
            uint256 c; // Whether we need to avoid catastrophic cancellation.
            uint256 i = 4; // Number of iterations.
            if (w <= 0x1ffffffffffff) {
                if (-0x4000000000000 <= w) {
                    i = 1; // Inputs near zero only take one step to converge.
                } else if (w <= -0x3ffffffffffffff) {
                    i = 32; // Inputs near `-1/e` take very long to converge.
                }
            } else if (w >> 63 == 0) {
                /// @solidity memory-safe-assembly
                assembly {
                    // Inline log2 for more performance, since the range is small.
                    let v := shr(49, w)
                    let l := shl(3, lt(0xff, v))
                    l := add(or(l, byte(and(0x1f, shr(shr(l, v), 0x8421084210842108cc6318c6db6d54be)),
                        0x0706060506020504060203020504030106050205030304010505030400000000)), 49)
                    w := sdiv(shl(l, 7), byte(sub(l, 31), 0x0303030303030303040506080c13))
                    c := gt(l, 60)
                    i := add(2, add(gt(l, 53), c))
                }
            } else {
                int256 ll = lnWad(w = lnWad(w));
                /// @solidity memory-safe-assembly
                assembly {
                    // `w = ln(x) - ln(ln(x)) + b * ln(ln(x)) / ln(x)`.
                    w := add(sdiv(mul(ll, 1023715080943847266), w), sub(w, ll))
                    i := add(3, iszero(shr(68, x)))
                    c := iszero(shr(143, x))
                }
                if (c == 0) {
                    do { // If `x` is big, use Newton's so that intermediate values won't overflow.
                        int256 e = expWad(w);
                        /// @solidity memory-safe-assembly
                        assembly {
                            let t := mul(w, div(e, wad))
                            w := sub(w, sdiv(sub(t, x), div(add(e, t), wad)))
                        }
                        if (p <= w) break;
                        p = w;
                    } while (--i != 0);
                    /// @solidity memory-safe-assembly
                    assembly {
                        w := sub(w, sgt(w, 2))
                    }
                    return w;
                }
            }
            do { // Otherwise, use Halley's for faster convergence.
                int256 e = expWad(w);
                /// @solidity memory-safe-assembly
                assembly {
                    let t := add(w, wad)
                    let s := sub(mul(w, e), mul(x, wad))
                    w := sub(w, sdiv(mul(s, wad), sub(mul(e, t), sdiv(mul(add(t, wad), s), add(t, t)))))
                }
                if (p <= w) break;
                p = w;
            } while (--i != c);
            /// @solidity memory-safe-assembly
            assembly {
                w := sub(w, sgt(w, 2))
            }
            // For certain ranges of `x`, we'll use the quadratic-rate recursive formula of
            // R. Iacono and J.P. Boyd for the last iteration, to avoid catastrophic cancellation.
            if (c != 0) {
                int256 t = w | 1;
                /// @solidity memory-safe-assembly
                assembly {
                    x := sdiv(mul(x, wad), t)
                }
                x = (t * (wad + lnWad(x)));
                /// @solidity memory-safe-assembly
                assembly {
                    w := sdiv(x, add(wad, t))
                }
            }
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                  GENERAL NUMBER UTILITIES                  */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Calculates `floor(x * y / d)` with full precision.
    /// Throws if result overflows a uint256 or when `d` is zero.
    /// Credit to Remco Bloemen under MIT license: https://2π.com/21/muldiv
    function fullMulDiv(uint256 x, uint256 y, uint256 d) internal pure returns (uint256 result) {
        /// @solidity memory-safe-assembly
        assembly {
            for {} 1 {} {
                // 512-bit multiply `[p1 p0] = x * y`.
                // Compute the product mod `2**256` and mod `2**256 - 1`
                // then use the Chinese Remainder Theorem to reconstruct
                // the 512 bit result. The result is stored in two 256
                // variables such that `product = p1 * 2**256 + p0`.

                // Least significant 256 bits of the product.
                result := mul(x, y) // Temporarily use `result` as `p0` to save gas.
                let mm := mulmod(x, y, not(0))
                // Most significant 256 bits of the product.
                let p1 := sub(mm, add(result, lt(mm, result)))

                // Handle non-overflow cases, 256 by 256 division.
                if iszero(p1) {
                    if iszero(d) {
                        mstore(0x00, 0xae47f702) // `FullMulDivFailed()`.
                        revert(0x1c, 0x04)
                    }
                    result := div(result, d)
                    break
                }

                // Make sure the result is less than `2**256`. Also prevents `d == 0`.
                if iszero(gt(d, p1)) {
                    mstore(0x00, 0xae47f702) // `FullMulDivFailed()`.
                    revert(0x1c, 0x04)
                }

                /*------------------- 512 by 256 division --------------------*/

                // Make division exact by subtracting the remainder from `[p1 p0]`.
                // Compute remainder using mulmod.
                let r := mulmod(x, y, d)
                // `t` is the least significant bit of `d`.
                // Always greater or equal to 1.
                let t := and(d, sub(0, d))
                // Divide `d` by `t`, which is a power of two.
                d := div(d, t)
                // Invert `d mod 2**256`
                // Now that `d` is an odd number, it has an inverse
                // modulo `2**256` such that `d * inv = 1 mod 2**256`.
                // Compute the inverse by starting with a seed that is correct
                // correct for four bits. That is, `d * inv = 1 mod 2**4`.
                let inv := xor(2, mul(3, d))
                // Now use Newton-Raphson iteration to improve the precision.
                // Thanks to Hensel's lifting lemma, this also works in modular
                // arithmetic, doubling the correct bits in each step.
                inv := mul(inv, sub(2, mul(d, inv))) // inverse mod 2**8
                inv := mul(inv, sub(2, mul(d, inv))) // inverse mod 2**16
                inv := mul(inv, sub(2, mul(d, inv))) // inverse mod 2**32
                inv := mul(inv, sub(2, mul(d, inv))) // inverse mod 2**64
                inv := mul(inv, sub(2, mul(d, inv))) // inverse mod 2**128
                result :=
                    mul(
                        // Divide [p1 p0] by the factors of two.
                        // Shift in bits from `p1` into `p0`. For this we need
                        // to flip `t` such that it is `2**256 / t`.
                        or(
                            mul(sub(p1, gt(r, result)), add(div(sub(0, t), t), 1)),
                            div(sub(result, r), t)
                        ),
                        // inverse mod 2**256
                        mul(inv, sub(2, mul(d, inv)))
                    )
                break
            }
        }
    }

    /// @dev Calculates `floor(x * y / d)` with full precision, rounded up.
    /// Throws if result overflows a uint256 or when `d` is zero.
    /// Credit to Uniswap-v3-core under MIT license:
    /// https://github.com/Uniswap/v3-core/blob/main/contracts/libraries/FullMath.sol
    function fullMulDivUp(uint256 x, uint256 y, uint256 d) internal pure returns (uint256 result) {
        result = fullMulDiv(x, y, d);
        /// @solidity memory-safe-assembly
        assembly {
            if mulmod(x, y, d) {
                result := add(result, 1)
                if iszero(result) {
                    mstore(0x00, 0xae47f702) // `FullMulDivFailed()`.
                    revert(0x1c, 0x04)
                }
            }
        }
    }

    /// @dev Returns `floor(x * y / d)`.
    /// Reverts if `x * y` overflows, or `d` is zero.
    function mulDiv(uint256 x, uint256 y, uint256 d) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Equivalent to require(d != 0 && (y == 0 || x <= type(uint256).max / y))
            if iszero(mul(d, iszero(mul(y, gt(x, div(not(0), y)))))) {
                mstore(0x00, 0xad251c27) // `MulDivFailed()`.
                revert(0x1c, 0x04)
            }
            z := div(mul(x, y), d)
        }
    }

    /// @dev Returns `ceil(x * y / d)`.
    /// Reverts if `x * y` overflows, or `d` is zero.
    function mulDivUp(uint256 x, uint256 y, uint256 d) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Equivalent to require(d != 0 && (y == 0 || x <= type(uint256).max / y))
            if iszero(mul(d, iszero(mul(y, gt(x, div(not(0), y)))))) {
                mstore(0x00, 0xad251c27) // `MulDivFailed()`.
                revert(0x1c, 0x04)
            }
            z := add(iszero(iszero(mod(mul(x, y), d))), div(mul(x, y), d))
        }
    }

    /// @dev Returns `ceil(x / d)`.
    /// Reverts if `d` is zero.
    function divUp(uint256 x, uint256 d) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            if iszero(d) {
                mstore(0x00, 0x65244e4e) // `DivFailed()`.
                revert(0x1c, 0x04)
            }
            z := add(iszero(iszero(mod(x, d))), div(x, d))
        }
    }

    /// @dev Returns `max(0, x - y)`.
    function zeroFloorSub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := mul(gt(x, y), sub(x, y))
        }
    }

    /// @dev Exponentiate `x` to `y` by squaring, denominated in base `b`.
    /// Reverts if the computation overflows.
    function rpow(uint256 x, uint256 y, uint256 b) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := mul(b, iszero(y)) // `0 ** 0 = 1`. Otherwise, `0 ** n = 0`.
            if x {
                z := xor(b, mul(xor(b, x), and(y, 1))) // `z = isEven(y) ? scale : x`
                let half := shr(1, b) // Divide `b` by 2.
                // Divide `y` by 2 every iteration.
                for { y := shr(1, y) } y { y := shr(1, y) } {
                    let xx := mul(x, x) // Store x squared.
                    let xxRound := add(xx, half) // Round to the nearest number.
                    // Revert if `xx + half` overflowed, or if `x ** 2` overflows.
                    if or(lt(xxRound, xx), shr(128, x)) {
                        mstore(0x00, 0x49f7642b) // `RPowOverflow()`.
                        revert(0x1c, 0x04)
                    }
                    x := div(xxRound, b) // Set `x` to scaled `xxRound`.
                    // If `y` is odd:
                    if and(y, 1) {
                        let zx := mul(z, x) // Compute `z * x`.
                        let zxRound := add(zx, half) // Round to the nearest number.
                        // If `z * x` overflowed or `zx + half` overflowed:
                        if or(xor(div(zx, x), z), lt(zxRound, zx)) {
                            // Revert if `x` is non-zero.
                            if iszero(iszero(x)) {
                                mstore(0x00, 0x49f7642b) // `RPowOverflow()`.
                                revert(0x1c, 0x04)
                            }
                        }
                        z := div(zxRound, b) // Return properly scaled `zxRound`.
                    }
                }
            }
        }
    }

    /// @dev Returns the square root of `x`.
    function sqrt(uint256 x) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // `floor(sqrt(2**15)) = 181`. `sqrt(2**15) - 181 = 2.84`.
            z := 181 // The "correct" value is 1, but this saves a multiplication later.

            // This segment is to get a reasonable initial estimate for the Babylonian method. With a bad
            // start, the correct # of bits increases ~linearly each iteration instead of ~quadratically.

            // Let `y = x / 2**r`. We check `y >= 2**(k + 8)`
            // but shift right by `k` bits to ensure that if `x >= 256`, then `y >= 256`.
            let r := shl(7, lt(0xffffffffffffffffffffffffffffffffff, x))
            r := or(r, shl(6, lt(0xffffffffffffffffff, shr(r, x))))
            r := or(r, shl(5, lt(0xffffffffff, shr(r, x))))
            r := or(r, shl(4, lt(0xffffff, shr(r, x))))
            z := shl(shr(1, r), z)

            // Goal was to get `z*z*y` within a small factor of `x`. More iterations could
            // get y in a tighter range. Currently, we will have y in `[256, 256*(2**16))`.
            // We ensured `y >= 256` so that the relative difference between `y` and `y+1` is small.
            // That's not possible if `x < 256` but we can just verify those cases exhaustively.

            // Now, `z*z*y <= x < z*z*(y+1)`, and `y <= 2**(16+8)`, and either `y >= 256`, or `x < 256`.
            // Correctness can be checked exhaustively for `x < 256`, so we assume `y >= 256`.
            // Then `z*sqrt(y)` is within `sqrt(257)/sqrt(256)` of `sqrt(x)`, or about 20bps.

            // For `s` in the range `[1/256, 256]`, the estimate `f(s) = (181/1024) * (s+1)`
            // is in the range `(1/2.84 * sqrt(s), 2.84 * sqrt(s))`,
            // with largest error when `s = 1` and when `s = 256` or `1/256`.

            // Since `y` is in `[256, 256*(2**16))`, let `a = y/65536`, so that `a` is in `[1/256, 256)`.
            // Then we can estimate `sqrt(y)` using
            // `sqrt(65536) * 181/1024 * (a + 1) = 181/4 * (y + 65536)/65536 = 181 * (y + 65536)/2**18`.

            // There is no overflow risk here since `y < 2**136` after the first branch above.
            z := shr(18, mul(z, add(shr(r, x), 65536))) // A `mul()` is saved from starting `z` at 181.

            // Given the worst case multiplicative error of 2.84 above, 7 iterations should be enough.
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))

            // If `x+1` is a perfect square, the Babylonian method cycles between
            // `floor(sqrt(x))` and `ceil(sqrt(x))`. This statement ensures we return floor.
            // See: https://en.wikipedia.org/wiki/Integer_square_root#Using_only_integer_division
            z := sub(z, lt(div(x, z), z))
        }
    }

    /// @dev Returns the cube root of `x`.
    /// Credit to bout3fiddy and pcaversaccio under AGPLv3 license:
    /// https://github.com/pcaversaccio/snekmate/blob/main/src/utils/Math.vy
    function cbrt(uint256 x) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            let r := shl(7, lt(0xffffffffffffffffffffffffffffffff, x))
            r := or(r, shl(6, lt(0xffffffffffffffff, shr(r, x))))
            r := or(r, shl(5, lt(0xffffffff, shr(r, x))))
            r := or(r, shl(4, lt(0xffff, shr(r, x))))
            r := or(r, shl(3, lt(0xff, shr(r, x))))

            z := div(shl(div(r, 3), shl(lt(0xf, shr(r, x)), 0xf)), xor(7, mod(r, 3)))

            z := div(add(add(div(x, mul(z, z)), z), z), 3)
            z := div(add(add(div(x, mul(z, z)), z), z), 3)
            z := div(add(add(div(x, mul(z, z)), z), z), 3)
            z := div(add(add(div(x, mul(z, z)), z), z), 3)
            z := div(add(add(div(x, mul(z, z)), z), z), 3)
            z := div(add(add(div(x, mul(z, z)), z), z), 3)
            z := div(add(add(div(x, mul(z, z)), z), z), 3)

            z := sub(z, lt(div(x, mul(z, z)), z))
        }
    }

    /// @dev Returns the square root of `x`, denominated in `WAD`.
    function sqrtWad(uint256 x) internal pure returns (uint256 z) {
        unchecked {
            z = 10 ** 9;
            if (x <= type(uint256).max / 10 ** 36 - 1) {
                x *= 10 ** 18;
                z = 1;
            }
            z *= sqrt(x);
        }
    }

    /// @dev Returns the cube root of `x`, denominated in `WAD`.
    function cbrtWad(uint256 x) internal pure returns (uint256 z) {
        unchecked {
            z = 10 ** 12;
            if (x <= (type(uint256).max / 10 ** 36) * 10 ** 18 - 1) {
                if (x >= type(uint256).max / 10 ** 36) {
                    x *= 10 ** 18;
                    z = 10 ** 6;
                } else {
                    x *= 10 ** 36;
                    z = 1;
                }
            }
            z *= cbrt(x);
        }
    }

    /// @dev Returns the factorial of `x`.
    function factorial(uint256 x) internal pure returns (uint256 result) {
        /// @solidity memory-safe-assembly
        assembly {
            if iszero(lt(x, 58)) {
                mstore(0x00, 0xaba0f2a2) // `FactorialOverflow()`.
                revert(0x1c, 0x04)
            }
            for { result := 1 } x { x := sub(x, 1) } { result := mul(result, x) }
        }
    }

    /// @dev Returns the log2 of `x`.
    /// Equivalent to computing the index of the most significant bit (MSB) of `x`.
    /// Returns 0 if `x` is zero.
    function log2(uint256 x) internal pure returns (uint256 r) {
        /// @solidity memory-safe-assembly
        assembly {
            r := shl(7, lt(0xffffffffffffffffffffffffffffffff, x))
            r := or(r, shl(6, lt(0xffffffffffffffff, shr(r, x))))
            r := or(r, shl(5, lt(0xffffffff, shr(r, x))))
            r := or(r, shl(4, lt(0xffff, shr(r, x))))
            r := or(r, shl(3, lt(0xff, shr(r, x))))
            // forgefmt: disable-next-item
            r := or(r, byte(and(0x1f, shr(shr(r, x), 0x8421084210842108cc6318c6db6d54be)),
                0x0706060506020504060203020504030106050205030304010505030400000000))
        }
    }

    /// @dev Returns the log2 of `x`, rounded up.
    /// Returns 0 if `x` is zero.
    function log2Up(uint256 x) internal pure returns (uint256 r) {
        r = log2(x);
        /// @solidity memory-safe-assembly
        assembly {
            r := add(r, lt(shl(r, 1), x))
        }
    }

    /// @dev Returns the log10 of `x`.
    /// Returns 0 if `x` is zero.
    function log10(uint256 x) internal pure returns (uint256 r) {
        /// @solidity memory-safe-assembly
        assembly {
            if iszero(lt(x, 100000000000000000000000000000000000000)) {
                x := div(x, 100000000000000000000000000000000000000)
                r := 38
            }
            if iszero(lt(x, 100000000000000000000)) {
                x := div(x, 100000000000000000000)
                r := add(r, 20)
            }
            if iszero(lt(x, 10000000000)) {
                x := div(x, 10000000000)
                r := add(r, 10)
            }
            if iszero(lt(x, 100000)) {
                x := div(x, 100000)
                r := add(r, 5)
            }
            r := add(r, add(gt(x, 9), add(gt(x, 99), add(gt(x, 999), gt(x, 9999)))))
        }
    }

    /// @dev Returns the log10 of `x`, rounded up.
    /// Returns 0 if `x` is zero.
    function log10Up(uint256 x) internal pure returns (uint256 r) {
        r = log10(x);
        /// @solidity memory-safe-assembly
        assembly {
            r := add(r, lt(exp(10, r), x))
        }
    }

    /// @dev Returns the log256 of `x`.
    /// Returns 0 if `x` is zero.
    function log256(uint256 x) internal pure returns (uint256 r) {
        /// @solidity memory-safe-assembly
        assembly {
            r := shl(7, lt(0xffffffffffffffffffffffffffffffff, x))
            r := or(r, shl(6, lt(0xffffffffffffffff, shr(r, x))))
            r := or(r, shl(5, lt(0xffffffff, shr(r, x))))
            r := or(r, shl(4, lt(0xffff, shr(r, x))))
            r := or(shr(3, r), lt(0xff, shr(r, x)))
        }
    }

    /// @dev Returns the log256 of `x`, rounded up.
    /// Returns 0 if `x` is zero.
    function log256Up(uint256 x) internal pure returns (uint256 r) {
        r = log256(x);
        /// @solidity memory-safe-assembly
        assembly {
            r := add(r, lt(shl(shl(3, r), 1), x))
        }
    }

    /// @dev Returns the scientific notation format `mantissa * 10 ** exponent` of `x`.
    /// Useful for compressing prices (e.g. using 25 bit mantissa and 7 bit exponent).
    function sci(uint256 x) internal pure returns (uint256 mantissa, uint256 exponent) {
        /// @solidity memory-safe-assembly
        assembly {
            mantissa := x
            if mantissa {
                if iszero(mod(mantissa, 1000000000000000000000000000000000)) {
                    mantissa := div(mantissa, 1000000000000000000000000000000000)
                    exponent := 33
                }
                if iszero(mod(mantissa, 10000000000000000000)) {
                    mantissa := div(mantissa, 10000000000000000000)
                    exponent := add(exponent, 19)
                }
                if iszero(mod(mantissa, 1000000000000)) {
                    mantissa := div(mantissa, 1000000000000)
                    exponent := add(exponent, 12)
                }
                if iszero(mod(mantissa, 1000000)) {
                    mantissa := div(mantissa, 1000000)
                    exponent := add(exponent, 6)
                }
                if iszero(mod(mantissa, 10000)) {
                    mantissa := div(mantissa, 10000)
                    exponent := add(exponent, 4)
                }
                if iszero(mod(mantissa, 100)) {
                    mantissa := div(mantissa, 100)
                    exponent := add(exponent, 2)
                }
                if iszero(mod(mantissa, 10)) {
                    mantissa := div(mantissa, 10)
                    exponent := add(exponent, 1)
                }
            }
        }
    }

    /// @dev Convenience function for packing `x` into a smaller number using `sci`.
    /// The `mantissa` will be in bits [7..255] (the upper 249 bits).
    /// The `exponent` will be in bits [0..6] (the lower 7 bits).
    /// Use `SafeCastLib` to safely ensure that the `packed` number is small
    /// enough to fit in the desired unsigned integer type:
    /// ```
    ///     uint32 packed = SafeCastLib.toUint32(FixedPointMathLib.packSci(777 ether));
    /// ```
    function packSci(uint256 x) internal pure returns (uint256 packed) {
        (x, packed) = sci(x); // Reuse for `mantissa` and `exponent`.
        /// @solidity memory-safe-assembly
        assembly {
            if shr(249, x) {
                mstore(0x00, 0xce30380c) // `MantissaOverflow()`.
                revert(0x1c, 0x04)
            }
            packed := or(shl(7, x), packed)
        }
    }

    /// @dev Convenience function for unpacking a packed number from `packSci`.
    function unpackSci(uint256 packed) internal pure returns (uint256 unpacked) {
        unchecked {
            unpacked = (packed >> 7) * 10 ** (packed & 0x7f);
        }
    }

    /// @dev Returns the average of `x` and `y`.
    function avg(uint256 x, uint256 y) internal pure returns (uint256 z) {
        unchecked {
            z = (x & y) + ((x ^ y) >> 1);
        }
    }

    /// @dev Returns the average of `x` and `y`.
    function avg(int256 x, int256 y) internal pure returns (int256 z) {
        unchecked {
            z = (x >> 1) + (y >> 1) + (((x & 1) + (y & 1)) >> 1);
        }
    }

    /// @dev Returns the absolute value of `x`.
    function abs(int256 x) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := xor(sub(0, shr(255, x)), add(sub(0, shr(255, x)), x))
        }
    }

    /// @dev Returns the absolute distance between `x` and `y`.
    function dist(int256 x, int256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := xor(mul(xor(sub(y, x), sub(x, y)), sgt(x, y)), sub(y, x))
        }
    }

    /// @dev Returns the minimum of `x` and `y`.
    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := xor(x, mul(xor(x, y), lt(y, x)))
        }
    }

    /// @dev Returns the minimum of `x` and `y`.
    function min(int256 x, int256 y) internal pure returns (int256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := xor(x, mul(xor(x, y), slt(y, x)))
        }
    }

    /// @dev Returns the maximum of `x` and `y`.
    function max(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := xor(x, mul(xor(x, y), gt(y, x)))
        }
    }

    /// @dev Returns the maximum of `x` and `y`.
    function max(int256 x, int256 y) internal pure returns (int256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := xor(x, mul(xor(x, y), sgt(y, x)))
        }
    }

    /// @dev Returns `x`, bounded to `minValue` and `maxValue`.
    function clamp(uint256 x, uint256 minValue, uint256 maxValue)
        internal
        pure
        returns (uint256 z)
    {
        /// @solidity memory-safe-assembly
        assembly {
            z := xor(x, mul(xor(x, minValue), gt(minValue, x)))
            z := xor(z, mul(xor(z, maxValue), lt(maxValue, z)))
        }
    }

    /// @dev Returns `x`, bounded to `minValue` and `maxValue`.
    function clamp(int256 x, int256 minValue, int256 maxValue) internal pure returns (int256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := xor(x, mul(xor(x, minValue), sgt(minValue, x)))
            z := xor(z, mul(xor(z, maxValue), slt(maxValue, z)))
        }
    }

    /// @dev Returns greatest common divisor of `x` and `y`.
    function gcd(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            for { z := x } y {} {
                let t := y
                y := mod(z, y)
                z := t
            }
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                   RAW NUMBER OPERATIONS                    */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns `x + y`, without checking for overflow.
    function rawAdd(uint256 x, uint256 y) internal pure returns (uint256 z) {
        unchecked {
            z = x + y;
        }
    }

    /// @dev Returns `x + y`, without checking for overflow.
    function rawAdd(int256 x, int256 y) internal pure returns (int256 z) {
        unchecked {
            z = x + y;
        }
    }

    /// @dev Returns `x - y`, without checking for underflow.
    function rawSub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        unchecked {
            z = x - y;
        }
    }

    /// @dev Returns `x - y`, without checking for underflow.
    function rawSub(int256 x, int256 y) internal pure returns (int256 z) {
        unchecked {
            z = x - y;
        }
    }

    /// @dev Returns `x * y`, without checking for overflow.
    function rawMul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        unchecked {
            z = x * y;
        }
    }

    /// @dev Returns `x * y`, without checking for overflow.
    function rawMul(int256 x, int256 y) internal pure returns (int256 z) {
        unchecked {
            z = x * y;
        }
    }

    /// @dev Returns `x / y`, returning 0 if `y` is zero.
    function rawDiv(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := div(x, y)
        }
    }

    /// @dev Returns `x / y`, returning 0 if `y` is zero.
    function rawSDiv(int256 x, int256 y) internal pure returns (int256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := sdiv(x, y)
        }
    }

    /// @dev Returns `x % y`, returning 0 if `y` is zero.
    function rawMod(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := mod(x, y)
        }
    }

    /// @dev Returns `x % y`, returning 0 if `y` is zero.
    function rawSMod(int256 x, int256 y) internal pure returns (int256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := smod(x, y)
        }
    }

    /// @dev Returns `(x + y) % d`, return 0 if `d` if zero.
    function rawAddMod(uint256 x, uint256 y, uint256 d) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := addmod(x, y, d)
        }
    }

    /// @dev Returns `(x * y) % d`, return 0 if `d` if zero.
    function rawMulMod(uint256 x, uint256 y, uint256 d) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := mulmod(x, y, d)
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Gas optimized verification of proof of inclusion for a leaf in a Merkle tree.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/MerkleProofLib.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/MerkleProofLib.sol)
/// @author Modified from OpenZeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/cryptography/MerkleProof.sol)
library MerkleProofLib {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*            MERKLE PROOF VERIFICATION OPERATIONS            */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns whether `leaf` exists in the Merkle tree with `root`, given `proof`.
    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf)
        internal
        pure
        returns (bool isValid)
    {
        /// @solidity memory-safe-assembly
        assembly {
            if mload(proof) {
                // Initialize `offset` to the offset of `proof` elements in memory.
                let offset := add(proof, 0x20)
                // Left shift by 5 is equivalent to multiplying by 0x20.
                let end := add(offset, shl(5, mload(proof)))
                // Iterate over proof elements to compute root hash.
                for {} 1 {} {
                    // Slot of `leaf` in scratch space.
                    // If the condition is true: 0x20, otherwise: 0x00.
                    let scratch := shl(5, gt(leaf, mload(offset)))
                    // Store elements to hash contiguously in scratch space.
                    // Scratch space is 64 bytes (0x00 - 0x3f) and both elements are 32 bytes.
                    mstore(scratch, leaf)
                    mstore(xor(scratch, 0x20), mload(offset))
                    // Reuse `leaf` to store the hash to reduce stack operations.
                    leaf := keccak256(0x00, 0x40)
                    offset := add(offset, 0x20)
                    if iszero(lt(offset, end)) { break }
                }
            }
            isValid := eq(leaf, root)
        }
    }

    /// @dev Returns whether `leaf` exists in the Merkle tree with `root`, given `proof`.
    function verifyCalldata(bytes32[] calldata proof, bytes32 root, bytes32 leaf)
        internal
        pure
        returns (bool isValid)
    {
        /// @solidity memory-safe-assembly
        assembly {
            if proof.length {
                // Left shift by 5 is equivalent to multiplying by 0x20.
                let end := add(proof.offset, shl(5, proof.length))
                // Initialize `offset` to the offset of `proof` in the calldata.
                let offset := proof.offset
                // Iterate over proof elements to compute root hash.
                for {} 1 {} {
                    // Slot of `leaf` in scratch space.
                    // If the condition is true: 0x20, otherwise: 0x00.
                    let scratch := shl(5, gt(leaf, calldataload(offset)))
                    // Store elements to hash contiguously in scratch space.
                    // Scratch space is 64 bytes (0x00 - 0x3f) and both elements are 32 bytes.
                    mstore(scratch, leaf)
                    mstore(xor(scratch, 0x20), calldataload(offset))
                    // Reuse `leaf` to store the hash to reduce stack operations.
                    leaf := keccak256(0x00, 0x40)
                    offset := add(offset, 0x20)
                    if iszero(lt(offset, end)) { break }
                }
            }
            isValid := eq(leaf, root)
        }
    }

    /// @dev Returns whether all `leaves` exist in the Merkle tree with `root`,
    /// given `proof` and `flags`.
    ///
    /// Note:
    /// - Breaking the invariant `flags.length == (leaves.length - 1) + proof.length`
    ///   will always return false.
    /// - The sum of the lengths of `proof` and `leaves` must never overflow.
    /// - Any non-zero word in the `flags` array is treated as true.
    /// - The memory offset of `proof` must be non-zero
    ///   (i.e. `proof` is not pointing to the scratch space).
    function verifyMultiProof(
        bytes32[] memory proof,
        bytes32 root,
        bytes32[] memory leaves,
        bool[] memory flags
    ) internal pure returns (bool isValid) {
        // Rebuilds the root by consuming and producing values on a queue.
        // The queue starts with the `leaves` array, and goes into a `hashes` array.
        // After the process, the last element on the queue is verified
        // to be equal to the `root`.
        //
        // The `flags` array denotes whether the sibling
        // should be popped from the queue (`flag == true`), or
        // should be popped from the `proof` (`flag == false`).
        /// @solidity memory-safe-assembly
        assembly {
            // Cache the lengths of the arrays.
            let leavesLength := mload(leaves)
            let proofLength := mload(proof)
            let flagsLength := mload(flags)

            // Advance the pointers of the arrays to point to the data.
            leaves := add(0x20, leaves)
            proof := add(0x20, proof)
            flags := add(0x20, flags)

            // If the number of flags is correct.
            for {} eq(add(leavesLength, proofLength), add(flagsLength, 1)) {} {
                // For the case where `proof.length + leaves.length == 1`.
                if iszero(flagsLength) {
                    // `isValid = (proof.length == 1 ? proof[0] : leaves[0]) == root`.
                    isValid := eq(mload(xor(leaves, mul(xor(proof, leaves), proofLength))), root)
                    break
                }

                // The required final proof offset if `flagsLength` is not zero, otherwise zero.
                let proofEnd := add(proof, shl(5, proofLength))
                // We can use the free memory space for the queue.
                // We don't need to allocate, since the queue is temporary.
                let hashesFront := mload(0x40)
                // Copy the leaves into the hashes.
                // Sometimes, a little memory expansion costs less than branching.
                // Should cost less, even with a high free memory offset of 0x7d00.
                leavesLength := shl(5, leavesLength)
                for { let i := 0 } iszero(eq(i, leavesLength)) { i := add(i, 0x20) } {
                    mstore(add(hashesFront, i), mload(add(leaves, i)))
                }
                // Compute the back of the hashes.
                let hashesBack := add(hashesFront, leavesLength)
                // This is the end of the memory for the queue.
                // We recycle `flagsLength` to save on stack variables (sometimes save gas).
                flagsLength := add(hashesBack, shl(5, flagsLength))

                for {} 1 {} {
                    // Pop from `hashes`.
                    let a := mload(hashesFront)
                    // Pop from `hashes`.
                    let b := mload(add(hashesFront, 0x20))
                    hashesFront := add(hashesFront, 0x40)

                    // If the flag is false, load the next proof,
                    // else, pops from the queue.
                    if iszero(mload(flags)) {
                        // Loads the next proof.
                        b := mload(proof)
                        proof := add(proof, 0x20)
                        // Unpop from `hashes`.
                        hashesFront := sub(hashesFront, 0x20)
                    }

                    // Advance to the next flag.
                    flags := add(flags, 0x20)

                    // Slot of `a` in scratch space.
                    // If the condition is true: 0x20, otherwise: 0x00.
                    let scratch := shl(5, gt(a, b))
                    // Hash the scratch space and push the result onto the queue.
                    mstore(scratch, a)
                    mstore(xor(scratch, 0x20), b)
                    mstore(hashesBack, keccak256(0x00, 0x40))
                    hashesBack := add(hashesBack, 0x20)
                    if iszero(lt(hashesBack, flagsLength)) { break }
                }
                isValid :=
                    and(
                        // Checks if the last value in the queue is same as the root.
                        eq(mload(sub(hashesBack, 0x20)), root),
                        // And whether all the proofs are used, if required.
                        eq(proofEnd, proof)
                    )
                break
            }
        }
    }

    /// @dev Returns whether all `leaves` exist in the Merkle tree with `root`,
    /// given `proof` and `flags`.
    ///
    /// Note:
    /// - Breaking the invariant `flags.length == (leaves.length - 1) + proof.length`
    ///   will always return false.
    /// - Any non-zero word in the `flags` array is treated as true.
    /// - The calldata offset of `proof` must be non-zero
    ///   (i.e. `proof` is from a regular Solidity function with a 4-byte selector).
    function verifyMultiProofCalldata(
        bytes32[] calldata proof,
        bytes32 root,
        bytes32[] calldata leaves,
        bool[] calldata flags
    ) internal pure returns (bool isValid) {
        // Rebuilds the root by consuming and producing values on a queue.
        // The queue starts with the `leaves` array, and goes into a `hashes` array.
        // After the process, the last element on the queue is verified
        // to be equal to the `root`.
        //
        // The `flags` array denotes whether the sibling
        // should be popped from the queue (`flag == true`), or
        // should be popped from the `proof` (`flag == false`).
        /// @solidity memory-safe-assembly
        assembly {
            // If the number of flags is correct.
            for {} eq(add(leaves.length, proof.length), add(flags.length, 1)) {} {
                // For the case where `proof.length + leaves.length == 1`.
                if iszero(flags.length) {
                    // `isValid = (proof.length == 1 ? proof[0] : leaves[0]) == root`.
                    // forgefmt: disable-next-item
                    isValid := eq(
                        calldataload(
                            xor(leaves.offset, mul(xor(proof.offset, leaves.offset), proof.length))
                        ),
                        root
                    )
                    break
                }

                // The required final proof offset if `flagsLength` is not zero, otherwise zero.
                let proofEnd := add(proof.offset, shl(5, proof.length))
                // We can use the free memory space for the queue.
                // We don't need to allocate, since the queue is temporary.
                let hashesFront := mload(0x40)
                // Copy the leaves into the hashes.
                // Sometimes, a little memory expansion costs less than branching.
                // Should cost less, even with a high free memory offset of 0x7d00.
                calldatacopy(hashesFront, leaves.offset, shl(5, leaves.length))
                // Compute the back of the hashes.
                let hashesBack := add(hashesFront, shl(5, leaves.length))
                // This is the end of the memory for the queue.
                // We recycle `flagsLength` to save on stack variables (sometimes save gas).
                flags.length := add(hashesBack, shl(5, flags.length))

                // We don't need to make a copy of `proof.offset` or `flags.offset`,
                // as they are pass-by-value (this trick may not always save gas).

                for {} 1 {} {
                    // Pop from `hashes`.
                    let a := mload(hashesFront)
                    // Pop from `hashes`.
                    let b := mload(add(hashesFront, 0x20))
                    hashesFront := add(hashesFront, 0x40)

                    // If the flag is false, load the next proof,
                    // else, pops from the queue.
                    if iszero(calldataload(flags.offset)) {
                        // Loads the next proof.
                        b := calldataload(proof.offset)
                        proof.offset := add(proof.offset, 0x20)
                        // Unpop from `hashes`.
                        hashesFront := sub(hashesFront, 0x20)
                    }

                    // Advance to the next flag offset.
                    flags.offset := add(flags.offset, 0x20)

                    // Slot of `a` in scratch space.
                    // If the condition is true: 0x20, otherwise: 0x00.
                    let scratch := shl(5, gt(a, b))
                    // Hash the scratch space and push the result onto the queue.
                    mstore(scratch, a)
                    mstore(xor(scratch, 0x20), b)
                    mstore(hashesBack, keccak256(0x00, 0x40))
                    hashesBack := add(hashesBack, 0x20)
                    if iszero(lt(hashesBack, flags.length)) { break }
                }
                isValid :=
                    and(
                        // Checks if the last value in the queue is same as the root.
                        eq(mload(sub(hashesBack, 0x20)), root),
                        // And whether all the proofs are used, if required.
                        eq(proofEnd, proof.offset)
                    )
                break
            }
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                   EMPTY CALLDATA HELPERS                   */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns an empty calldata bytes32 array.
    function emptyProof() internal pure returns (bytes32[] calldata proof) {
        /// @solidity memory-safe-assembly
        assembly {
            proof.length := 0
        }
    }

    /// @dev Returns an empty calldata bytes32 array.
    function emptyLeaves() internal pure returns (bytes32[] calldata leaves) {
        /// @solidity memory-safe-assembly
        assembly {
            leaves.length := 0
        }
    }

    /// @dev Returns an empty calldata bool array.
    function emptyFlags() internal pure returns (bool[] calldata flags) {
        /// @solidity memory-safe-assembly
        assembly {
            flags.length := 0
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Reentrancy guard mixin.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/ReentrancyGuard.sol)
abstract contract ReentrancyGuard {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       CUSTOM ERRORS                        */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Unauthorized reentrant call.
    error Reentrancy();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                          STORAGE                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Equivalent to: `uint72(bytes9(keccak256("_REENTRANCY_GUARD_SLOT")))`.
    /// 9 bytes is large enough to avoid collisions with lower slots,
    /// but not too large to result in excessive bytecode bloat.
    uint256 private constant _REENTRANCY_GUARD_SLOT = 0x929eee149b4bd21268;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      REENTRANCY GUARD                      */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Guards a function from reentrancy.
    modifier nonReentrant() virtual {
        /// @solidity memory-safe-assembly
        assembly {
            if eq(sload(_REENTRANCY_GUARD_SLOT), address()) {
                mstore(0x00, 0xab143c06) // `Reentrancy()`.
                revert(0x1c, 0x04)
            }
            sstore(_REENTRANCY_GUARD_SLOT, address())
        }
        _;
        /// @solidity memory-safe-assembly
        assembly {
            sstore(_REENTRANCY_GUARD_SLOT, codesize())
        }
    }

    /// @dev Guards a view function from read-only reentrancy.
    modifier nonReadReentrant() virtual {
        /// @solidity memory-safe-assembly
        assembly {
            if eq(sload(_REENTRANCY_GUARD_SLOT), address()) {
                mstore(0x00, 0xab143c06) // `Reentrancy()`.
                revert(0x1c, 0x04)
            }
        }
        _;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Safe integer casting library that reverts on overflow.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/SafeCastLib.sol)
/// @author Modified from OpenZeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeCast.sol)
library SafeCastLib {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       CUSTOM ERRORS                        */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    error Overflow();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*          UNSIGNED INTEGER SAFE CASTING OPERATIONS          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function toUint8(uint256 x) internal pure returns (uint8) {
        if (x >= 1 << 8) _revertOverflow();
        return uint8(x);
    }

    function toUint16(uint256 x) internal pure returns (uint16) {
        if (x >= 1 << 16) _revertOverflow();
        return uint16(x);
    }

    function toUint24(uint256 x) internal pure returns (uint24) {
        if (x >= 1 << 24) _revertOverflow();
        return uint24(x);
    }

    function toUint32(uint256 x) internal pure returns (uint32) {
        if (x >= 1 << 32) _revertOverflow();
        return uint32(x);
    }

    function toUint40(uint256 x) internal pure returns (uint40) {
        if (x >= 1 << 40) _revertOverflow();
        return uint40(x);
    }

    function toUint48(uint256 x) internal pure returns (uint48) {
        if (x >= 1 << 48) _revertOverflow();
        return uint48(x);
    }

    function toUint56(uint256 x) internal pure returns (uint56) {
        if (x >= 1 << 56) _revertOverflow();
        return uint56(x);
    }

    function toUint64(uint256 x) internal pure returns (uint64) {
        if (x >= 1 << 64) _revertOverflow();
        return uint64(x);
    }

    function toUint72(uint256 x) internal pure returns (uint72) {
        if (x >= 1 << 72) _revertOverflow();
        return uint72(x);
    }

    function toUint80(uint256 x) internal pure returns (uint80) {
        if (x >= 1 << 80) _revertOverflow();
        return uint80(x);
    }

    function toUint88(uint256 x) internal pure returns (uint88) {
        if (x >= 1 << 88) _revertOverflow();
        return uint88(x);
    }

    function toUint96(uint256 x) internal pure returns (uint96) {
        if (x >= 1 << 96) _revertOverflow();
        return uint96(x);
    }

    function toUint104(uint256 x) internal pure returns (uint104) {
        if (x >= 1 << 104) _revertOverflow();
        return uint104(x);
    }

    function toUint112(uint256 x) internal pure returns (uint112) {
        if (x >= 1 << 112) _revertOverflow();
        return uint112(x);
    }

    function toUint120(uint256 x) internal pure returns (uint120) {
        if (x >= 1 << 120) _revertOverflow();
        return uint120(x);
    }

    function toUint128(uint256 x) internal pure returns (uint128) {
        if (x >= 1 << 128) _revertOverflow();
        return uint128(x);
    }

    function toUint136(uint256 x) internal pure returns (uint136) {
        if (x >= 1 << 136) _revertOverflow();
        return uint136(x);
    }

    function toUint144(uint256 x) internal pure returns (uint144) {
        if (x >= 1 << 144) _revertOverflow();
        return uint144(x);
    }

    function toUint152(uint256 x) internal pure returns (uint152) {
        if (x >= 1 << 152) _revertOverflow();
        return uint152(x);
    }

    function toUint160(uint256 x) internal pure returns (uint160) {
        if (x >= 1 << 160) _revertOverflow();
        return uint160(x);
    }

    function toUint168(uint256 x) internal pure returns (uint168) {
        if (x >= 1 << 168) _revertOverflow();
        return uint168(x);
    }

    function toUint176(uint256 x) internal pure returns (uint176) {
        if (x >= 1 << 176) _revertOverflow();
        return uint176(x);
    }

    function toUint184(uint256 x) internal pure returns (uint184) {
        if (x >= 1 << 184) _revertOverflow();
        return uint184(x);
    }

    function toUint192(uint256 x) internal pure returns (uint192) {
        if (x >= 1 << 192) _revertOverflow();
        return uint192(x);
    }

    function toUint200(uint256 x) internal pure returns (uint200) {
        if (x >= 1 << 200) _revertOverflow();
        return uint200(x);
    }

    function toUint208(uint256 x) internal pure returns (uint208) {
        if (x >= 1 << 208) _revertOverflow();
        return uint208(x);
    }

    function toUint216(uint256 x) internal pure returns (uint216) {
        if (x >= 1 << 216) _revertOverflow();
        return uint216(x);
    }

    function toUint224(uint256 x) internal pure returns (uint224) {
        if (x >= 1 << 224) _revertOverflow();
        return uint224(x);
    }

    function toUint232(uint256 x) internal pure returns (uint232) {
        if (x >= 1 << 232) _revertOverflow();
        return uint232(x);
    }

    function toUint240(uint256 x) internal pure returns (uint240) {
        if (x >= 1 << 240) _revertOverflow();
        return uint240(x);
    }

    function toUint248(uint256 x) internal pure returns (uint248) {
        if (x >= 1 << 248) _revertOverflow();
        return uint248(x);
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*           SIGNED INTEGER SAFE CASTING OPERATIONS           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function toInt8(int256 x) internal pure returns (int8) {
        int8 y = int8(x);
        if (x != y) _revertOverflow();
        return y;
    }

    function toInt16(int256 x) internal pure returns (int16) {
        int16 y = int16(x);
        if (x != y) _revertOverflow();
        return y;
    }

    function toInt24(int256 x) internal pure returns (int24) {
        int24 y = int24(x);
        if (x != y) _revertOverflow();
        return y;
    }

    function toInt32(int256 x) internal pure returns (int32) {
        int32 y = int32(x);
        if (x != y) _revertOverflow();
        return y;
    }

    function toInt40(int256 x) internal pure returns (int40) {
        int40 y = int40(x);
        if (x != y) _revertOverflow();
        return y;
    }

    function toInt48(int256 x) internal pure returns (int48) {
        int48 y = int48(x);
        if (x != y) _revertOverflow();
        return y;
    }

    function toInt56(int256 x) internal pure returns (int56) {
        int56 y = int56(x);
        if (x != y) _revertOverflow();
        return y;
    }

    function toInt64(int256 x) internal pure returns (int64) {
        int64 y = int64(x);
        if (x != y) _revertOverflow();
        return y;
    }

    function toInt72(int256 x) internal pure returns (int72) {
        int72 y = int72(x);
        if (x != y) _revertOverflow();
        return y;
    }

    function toInt80(int256 x) internal pure returns (int80) {
        int80 y = int80(x);
        if (x != y) _revertOverflow();
        return y;
    }

    function toInt88(int256 x) internal pure returns (int88) {
        int88 y = int88(x);
        if (x != y) _revertOverflow();
        return y;
    }

    function toInt96(int256 x) internal pure returns (int96) {
        int96 y = int96(x);
        if (x != y) _revertOverflow();
        return y;
    }

    function toInt104(int256 x) internal pure returns (int104) {
        int104 y = int104(x);
        if (x != y) _revertOverflow();
        return y;
    }

    function toInt112(int256 x) internal pure returns (int112) {
        int112 y = int112(x);
        if (x != y) _revertOverflow();
        return y;
    }

    function toInt120(int256 x) internal pure returns (int120) {
        int120 y = int120(x);
        if (x != y) _revertOverflow();
        return y;
    }

    function toInt128(int256 x) internal pure returns (int128) {
        int128 y = int128(x);
        if (x != y) _revertOverflow();
        return y;
    }

    function toInt136(int256 x) internal pure returns (int136) {
        int136 y = int136(x);
        if (x != y) _revertOverflow();
        return y;
    }

    function toInt144(int256 x) internal pure returns (int144) {
        int144 y = int144(x);
        if (x != y) _revertOverflow();
        return y;
    }

    function toInt152(int256 x) internal pure returns (int152) {
        int152 y = int152(x);
        if (x != y) _revertOverflow();
        return y;
    }

    function toInt160(int256 x) internal pure returns (int160) {
        int160 y = int160(x);
        if (x != y) _revertOverflow();
        return y;
    }

    function toInt168(int256 x) internal pure returns (int168) {
        int168 y = int168(x);
        if (x != y) _revertOverflow();
        return y;
    }

    function toInt176(int256 x) internal pure returns (int176) {
        int176 y = int176(x);
        if (x != y) _revertOverflow();
        return y;
    }

    function toInt184(int256 x) internal pure returns (int184) {
        int184 y = int184(x);
        if (x != y) _revertOverflow();
        return y;
    }

    function toInt192(int256 x) internal pure returns (int192) {
        int192 y = int192(x);
        if (x != y) _revertOverflow();
        return y;
    }

    function toInt200(int256 x) internal pure returns (int200) {
        int200 y = int200(x);
        if (x != y) _revertOverflow();
        return y;
    }

    function toInt208(int256 x) internal pure returns (int208) {
        int208 y = int208(x);
        if (x != y) _revertOverflow();
        return y;
    }

    function toInt216(int256 x) internal pure returns (int216) {
        int216 y = int216(x);
        if (x != y) _revertOverflow();
        return y;
    }

    function toInt224(int256 x) internal pure returns (int224) {
        int224 y = int224(x);
        if (x != y) _revertOverflow();
        return y;
    }

    function toInt232(int256 x) internal pure returns (int232) {
        int232 y = int232(x);
        if (x != y) _revertOverflow();
        return y;
    }

    function toInt240(int256 x) internal pure returns (int240) {
        int240 y = int240(x);
        if (x != y) _revertOverflow();
        return y;
    }

    function toInt248(int256 x) internal pure returns (int248) {
        int248 y = int248(x);
        if (x != y) _revertOverflow();
        return y;
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*               OTHER SAFE CASTING OPERATIONS                */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function toInt256(uint256 x) internal pure returns (int256) {
        if (x >= 1 << 255) _revertOverflow();
        return int256(x);
    }

    function toUint256(int256 x) internal pure returns (uint256) {
        if (x < 0) _revertOverflow();
        return uint256(x);
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      PRIVATE HELPERS                       */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function _revertOverflow() private pure {
        /// @solidity memory-safe-assembly
        assembly {
            // Store the function selector of `Overflow()`.
            mstore(0x00, 0x35278d12)
            // Revert with (offset, size).
            revert(0x1c, 0x04)
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Safe ETH and ERC20 transfer library that gracefully handles missing return values.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/SafeTransferLib.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/SafeTransferLib.sol)
///
/// @dev Note:
/// - For ETH transfers, please use `forceSafeTransferETH` for DoS protection.
/// - For ERC20s, this implementation won't check that a token has code,
///   responsibility is delegated to the caller.
library SafeTransferLib {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       CUSTOM ERRORS                        */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The ETH transfer has failed.
    error ETHTransferFailed();

    /// @dev The ERC20 `transferFrom` has failed.
    error TransferFromFailed();

    /// @dev The ERC20 `transfer` has failed.
    error TransferFailed();

    /// @dev The ERC20 `approve` has failed.
    error ApproveFailed();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         CONSTANTS                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Suggested gas stipend for contract receiving ETH that disallows any storage writes.
    uint256 internal constant GAS_STIPEND_NO_STORAGE_WRITES = 2300;

    /// @dev Suggested gas stipend for contract receiving ETH to perform a few
    /// storage reads and writes, but low enough to prevent griefing.
    uint256 internal constant GAS_STIPEND_NO_GRIEF = 100000;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       ETH OPERATIONS                       */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // If the ETH transfer MUST succeed with a reasonable gas budget, use the force variants.
    //
    // The regular variants:
    // - Forwards all remaining gas to the target.
    // - Reverts if the target reverts.
    // - Reverts if the current contract has insufficient balance.
    //
    // The force variants:
    // - Forwards with an optional gas stipend
    //   (defaults to `GAS_STIPEND_NO_GRIEF`, which is sufficient for most cases).
    // - If the target reverts, or if the gas stipend is exhausted,
    //   creates a temporary contract to force send the ETH via `SELFDESTRUCT`.
    //   Future compatible with `SENDALL`: https://eips.ethereum.org/EIPS/eip-4758.
    // - Reverts if the current contract has insufficient balance.
    //
    // The try variants:
    // - Forwards with a mandatory gas stipend.
    // - Instead of reverting, returns whether the transfer succeeded.

    /// @dev Sends `amount` (in wei) ETH to `to`.
    function safeTransferETH(address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            if iszero(call(gas(), to, amount, codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, 0xb12d13eb) // `ETHTransferFailed()`.
                revert(0x1c, 0x04)
            }
        }
    }

    /// @dev Sends all the ETH in the current contract to `to`.
    function safeTransferAllETH(address to) internal {
        /// @solidity memory-safe-assembly
        assembly {
            // Transfer all the ETH and check if it succeeded or not.
            if iszero(call(gas(), to, selfbalance(), codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, 0xb12d13eb) // `ETHTransferFailed()`.
                revert(0x1c, 0x04)
            }
        }
    }

    /// @dev Force sends `amount` (in wei) ETH to `to`, with a `gasStipend`.
    function forceSafeTransferETH(address to, uint256 amount, uint256 gasStipend) internal {
        /// @solidity memory-safe-assembly
        assembly {
            if lt(selfbalance(), amount) {
                mstore(0x00, 0xb12d13eb) // `ETHTransferFailed()`.
                revert(0x1c, 0x04)
            }
            if iszero(call(gasStipend, to, amount, codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, to) // Store the address in scratch space.
                mstore8(0x0b, 0x73) // Opcode `PUSH20`.
                mstore8(0x20, 0xff) // Opcode `SELFDESTRUCT`.
                if iszero(create(amount, 0x0b, 0x16)) { revert(codesize(), codesize()) } // For gas estimation.
            }
        }
    }

    /// @dev Force sends all the ETH in the current contract to `to`, with a `gasStipend`.
    function forceSafeTransferAllETH(address to, uint256 gasStipend) internal {
        /// @solidity memory-safe-assembly
        assembly {
            if iszero(call(gasStipend, to, selfbalance(), codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, to) // Store the address in scratch space.
                mstore8(0x0b, 0x73) // Opcode `PUSH20`.
                mstore8(0x20, 0xff) // Opcode `SELFDESTRUCT`.
                if iszero(create(selfbalance(), 0x0b, 0x16)) { revert(codesize(), codesize()) } // For gas estimation.
            }
        }
    }

    /// @dev Force sends `amount` (in wei) ETH to `to`, with `GAS_STIPEND_NO_GRIEF`.
    function forceSafeTransferETH(address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            if lt(selfbalance(), amount) {
                mstore(0x00, 0xb12d13eb) // `ETHTransferFailed()`.
                revert(0x1c, 0x04)
            }
            if iszero(call(GAS_STIPEND_NO_GRIEF, to, amount, codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, to) // Store the address in scratch space.
                mstore8(0x0b, 0x73) // Opcode `PUSH20`.
                mstore8(0x20, 0xff) // Opcode `SELFDESTRUCT`.
                if iszero(create(amount, 0x0b, 0x16)) { revert(codesize(), codesize()) } // For gas estimation.
            }
        }
    }

    /// @dev Force sends all the ETH in the current contract to `to`, with `GAS_STIPEND_NO_GRIEF`.
    function forceSafeTransferAllETH(address to) internal {
        /// @solidity memory-safe-assembly
        assembly {
            // forgefmt: disable-next-item
            if iszero(call(GAS_STIPEND_NO_GRIEF, to, selfbalance(), codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, to) // Store the address in scratch space.
                mstore8(0x0b, 0x73) // Opcode `PUSH20`.
                mstore8(0x20, 0xff) // Opcode `SELFDESTRUCT`.
                if iszero(create(selfbalance(), 0x0b, 0x16)) { revert(codesize(), codesize()) } // For gas estimation.
            }
        }
    }

    /// @dev Sends `amount` (in wei) ETH to `to`, with a `gasStipend`.
    function trySafeTransferETH(address to, uint256 amount, uint256 gasStipend)
        internal
        returns (bool success)
    {
        /// @solidity memory-safe-assembly
        assembly {
            success := call(gasStipend, to, amount, codesize(), 0x00, codesize(), 0x00)
        }
    }

    /// @dev Sends all the ETH in the current contract to `to`, with a `gasStipend`.
    function trySafeTransferAllETH(address to, uint256 gasStipend)
        internal
        returns (bool success)
    {
        /// @solidity memory-safe-assembly
        assembly {
            success := call(gasStipend, to, selfbalance(), codesize(), 0x00, codesize(), 0x00)
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      ERC20 OPERATIONS                      */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Sends `amount` of ERC20 `token` from `from` to `to`.
    /// Reverts upon failure.
    ///
    /// The `from` account must have at least `amount` approved for
    /// the current contract to manage.
    function safeTransferFrom(address token, address from, address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x60, amount) // Store the `amount` argument.
            mstore(0x40, to) // Store the `to` argument.
            mstore(0x2c, shl(96, from)) // Store the `from` argument.
            mstore(0x0c, 0x23b872dd000000000000000000000000) // `transferFrom(address,address,uint256)`.
            // Perform the transfer, reverting upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    or(eq(mload(0x00), 1), iszero(returndatasize())), // Returned 1 or nothing.
                    call(gas(), token, 0, 0x1c, 0x64, 0x00, 0x20)
                )
            ) {
                mstore(0x00, 0x7939f424) // `TransferFromFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x60, 0) // Restore the zero slot to zero.
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Sends all of ERC20 `token` from `from` to `to`.
    /// Reverts upon failure.
    ///
    /// The `from` account must have their entire balance approved for
    /// the current contract to manage.
    function safeTransferAllFrom(address token, address from, address to)
        internal
        returns (uint256 amount)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x40, to) // Store the `to` argument.
            mstore(0x2c, shl(96, from)) // Store the `from` argument.
            mstore(0x0c, 0x70a08231000000000000000000000000) // `balanceOf(address)`.
            // Read the balance, reverting upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    gt(returndatasize(), 0x1f), // At least 32 bytes returned.
                    staticcall(gas(), token, 0x1c, 0x24, 0x60, 0x20)
                )
            ) {
                mstore(0x00, 0x7939f424) // `TransferFromFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x00, 0x23b872dd) // `transferFrom(address,address,uint256)`.
            amount := mload(0x60) // The `amount` is already at 0x60. We'll need to return it.
            // Perform the transfer, reverting upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    or(eq(mload(0x00), 1), iszero(returndatasize())), // Returned 1 or nothing.
                    call(gas(), token, 0, 0x1c, 0x64, 0x00, 0x20)
                )
            ) {
                mstore(0x00, 0x7939f424) // `TransferFromFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x60, 0) // Restore the zero slot to zero.
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Sends `amount` of ERC20 `token` from the current contract to `to`.
    /// Reverts upon failure.
    function safeTransfer(address token, address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x14, to) // Store the `to` argument.
            mstore(0x34, amount) // Store the `amount` argument.
            mstore(0x00, 0xa9059cbb000000000000000000000000) // `transfer(address,uint256)`.
            // Perform the transfer, reverting upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    or(eq(mload(0x00), 1), iszero(returndatasize())), // Returned 1 or nothing.
                    call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                )
            ) {
                mstore(0x00, 0x90b8ec18) // `TransferFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x34, 0) // Restore the part of the free memory pointer that was overwritten.
        }
    }

    /// @dev Sends all of ERC20 `token` from the current contract to `to`.
    /// Reverts upon failure.
    function safeTransferAll(address token, address to) internal returns (uint256 amount) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, 0x70a08231) // Store the function selector of `balanceOf(address)`.
            mstore(0x20, address()) // Store the address of the current contract.
            // Read the balance, reverting upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    gt(returndatasize(), 0x1f), // At least 32 bytes returned.
                    staticcall(gas(), token, 0x1c, 0x24, 0x34, 0x20)
                )
            ) {
                mstore(0x00, 0x90b8ec18) // `TransferFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x14, to) // Store the `to` argument.
            amount := mload(0x34) // The `amount` is already at 0x34. We'll need to return it.
            mstore(0x00, 0xa9059cbb000000000000000000000000) // `transfer(address,uint256)`.
            // Perform the transfer, reverting upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    or(eq(mload(0x00), 1), iszero(returndatasize())), // Returned 1 or nothing.
                    call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                )
            ) {
                mstore(0x00, 0x90b8ec18) // `TransferFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x34, 0) // Restore the part of the free memory pointer that was overwritten.
        }
    }

    /// @dev Sets `amount` of ERC20 `token` for `to` to manage on behalf of the current contract.
    /// Reverts upon failure.
    function safeApprove(address token, address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x14, to) // Store the `to` argument.
            mstore(0x34, amount) // Store the `amount` argument.
            mstore(0x00, 0x095ea7b3000000000000000000000000) // `approve(address,uint256)`.
            // Perform the approval, reverting upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    or(eq(mload(0x00), 1), iszero(returndatasize())), // Returned 1 or nothing.
                    call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                )
            ) {
                mstore(0x00, 0x3e3f8f73) // `ApproveFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x34, 0) // Restore the part of the free memory pointer that was overwritten.
        }
    }

    /// @dev Sets `amount` of ERC20 `token` for `to` to manage on behalf of the current contract.
    /// If the initial attempt to approve fails, attempts to reset the approved amount to zero,
    /// then retries the approval again (some tokens, e.g. USDT, requires this).
    /// Reverts upon failure.
    function safeApproveWithRetry(address token, address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x14, to) // Store the `to` argument.
            mstore(0x34, amount) // Store the `amount` argument.
            mstore(0x00, 0x095ea7b3000000000000000000000000) // `approve(address,uint256)`.
            // Perform the approval, retrying upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    or(eq(mload(0x00), 1), iszero(returndatasize())), // Returned 1 or nothing.
                    call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                )
            ) {
                mstore(0x34, 0) // Store 0 for the `amount`.
                mstore(0x00, 0x095ea7b3000000000000000000000000) // `approve(address,uint256)`.
                pop(call(gas(), token, 0, 0x10, 0x44, codesize(), 0x00)) // Reset the approval.
                mstore(0x34, amount) // Store back the original `amount`.
                // Retry the approval, reverting upon failure.
                if iszero(
                    and(
                        or(eq(mload(0x00), 1), iszero(returndatasize())), // Returned 1 or nothing.
                        call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                    )
                ) {
                    mstore(0x00, 0x3e3f8f73) // `ApproveFailed()`.
                    revert(0x1c, 0x04)
                }
            }
            mstore(0x34, 0) // Restore the part of the free memory pointer that was overwritten.
        }
    }

    /// @dev Returns the amount of ERC20 `token` owned by `account`.
    /// Returns zero if the `token` does not exist.
    function balanceOf(address token, address account) internal view returns (uint256 amount) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x14, account) // Store the `account` argument.
            mstore(0x00, 0x70a08231000000000000000000000000) // `balanceOf(address)`.
            amount :=
                mul(
                    mload(0x20),
                    and( // The arguments of `and` are evaluated from right to left.
                        gt(returndatasize(), 0x1f), // At least 32 bytes returned.
                        staticcall(gas(), token, 0x10, 0x24, 0x20, 0x20)
                    )
                )
        }
    }
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

/// @title IAdminable
/// @notice Contract module that provides a basic access control mechanism, with an admin that can be
/// granted exclusive access to specific functions. The inheriting contract must set the initial admin
/// in the constructor.
interface IAdminable {
    /*//////////////////////////////////////////////////////////////////////////
                                       EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Emitted when the admin is transferred.
    /// @param oldAdmin The address of the old admin.
    /// @param newAdmin The address of the new admin.
    event TransferAdmin(address indexed oldAdmin, address indexed newAdmin);

    /*//////////////////////////////////////////////////////////////////////////
                                 CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice The address of the admin account or contract.
    function admin() external view returns (address);

    /*//////////////////////////////////////////////////////////////////////////
                               NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Transfers the contract admin to a new address.
    ///
    /// @dev Notes:
    /// - Does not revert if the admin is the same.
    /// - This function can potentially leave the contract without an admin, thereby removing any
    /// functionality that is only available to the admin.
    ///
    /// Requirements:
    /// - `msg.sender` must be the contract admin.
    ///
    /// @param newAdmin The address of the new admin.
    function transferAdmin(address newAdmin) external;
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { UD60x18 } from "@prb/math/src/UD60x18.sol";

import { IAdminable } from "./IAdminable.sol";
import { ISablierV2Comptroller } from "./ISablierV2Comptroller.sol";

/// @title ISablierV2Base
/// @notice Base logic for all Sablier V2 streaming contracts.
interface ISablierV2Base is IAdminable {
    /*//////////////////////////////////////////////////////////////////////////
                                       EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Emitted when the admin claims all protocol revenues accrued for a particular ERC-20 asset.
    /// @param admin The address of the contract admin.
    /// @param asset The contract address of the ERC-20 asset the protocol revenues have been claimed for.
    /// @param protocolRevenues The amount of protocol revenues claimed, denoted in units of the asset's decimals.
    event ClaimProtocolRevenues(address indexed admin, IERC20 indexed asset, uint128 protocolRevenues);

    /// @notice Emitted when the admin sets a new comptroller contract.
    /// @param admin The address of the contract admin.
    /// @param oldComptroller The address of the old comptroller contract.
    /// @param newComptroller The address of the new comptroller contract.
    event SetComptroller(
        address indexed admin, ISablierV2Comptroller oldComptroller, ISablierV2Comptroller newComptroller
    );

    /*//////////////////////////////////////////////////////////////////////////
                                 CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Retrieves the maximum fee that can be charged by the protocol or a broker, denoted as a fixed-point
    /// number where 1e18 is 100%.
    /// @dev This value is hard coded as a constant.
    function MAX_FEE() external view returns (UD60x18);

    /// @notice Retrieves the address of the comptroller contract, responsible for the Sablier V2 protocol
    /// configuration.
    function comptroller() external view returns (ISablierV2Comptroller);

    /// @notice Retrieves the protocol revenues accrued for the provided ERC-20 asset, in units of the asset's
    /// decimals.
    /// @param asset The contract address of the ERC-20 asset to query.
    function protocolRevenues(IERC20 asset) external view returns (uint128 revenues);

    /*//////////////////////////////////////////////////////////////////////////
                               NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Claims all accumulated protocol revenues for the provided ERC-20 asset.
    ///
    /// @dev Emits a {ClaimProtocolRevenues} event.
    ///
    /// Requirements:
    /// - `msg.sender` must be the contract admin.
    ///
    /// @param asset The contract address of the ERC-20 asset for which to claim protocol revenues.
    function claimProtocolRevenues(IERC20 asset) external;

    /// @notice Assigns a new comptroller contract responsible for the protocol configuration.
    ///
    /// @dev Emits a {SetComptroller} event.
    ///
    /// Notes:
    /// - Does not revert if the comptroller is the same.
    ///
    /// Requirements:
    /// - `msg.sender` must be the contract admin.
    ///
    /// @param newComptroller The address of the new comptroller contract.
    function setComptroller(ISablierV2Comptroller newComptroller) external;
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { UD60x18 } from "@prb/math/src/UD60x18.sol";

import { IAdminable } from "./IAdminable.sol";

/// @title ISablierV2Controller
/// @notice This contract is in charge of the Sablier V2 protocol configuration, handling such values as the
/// protocol fees.
interface ISablierV2Comptroller is IAdminable {
    /*//////////////////////////////////////////////////////////////////////////
                                       EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Emitted when the admin sets a new flash fee.
    /// @param admin The address of the contract admin.
    /// @param oldFlashFee The old flash fee, denoted as a fixed-point number.
    /// @param newFlashFee The new flash fee, denoted as a fixed-point number.
    event SetFlashFee(address indexed admin, UD60x18 oldFlashFee, UD60x18 newFlashFee);

    /// @notice Emitted when the admin sets a new protocol fee for the provided ERC-20 asset.
    /// @param admin The address of the contract admin.
    /// @param asset The contract address of the ERC-20 asset the new protocol fee has been set for.
    /// @param oldProtocolFee The old protocol fee, denoted as a fixed-point number.
    /// @param newProtocolFee The new protocol fee, denoted as a fixed-point number.
    event SetProtocolFee(address indexed admin, IERC20 indexed asset, UD60x18 oldProtocolFee, UD60x18 newProtocolFee);

    /// @notice Emitted when the admin enables or disables an ERC-20 asset for flash loaning.
    /// @param admin The address of the contract admin.
    /// @param asset The contract address of the ERC-20 asset to toggle.
    /// @param newFlag Whether the ERC-20 asset can be flash loaned.
    event ToggleFlashAsset(address indexed admin, IERC20 indexed asset, bool newFlag);

    /*//////////////////////////////////////////////////////////////////////////
                                 CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Retrieves the global flash fee, denoted as a fixed-point number where 1e18 is 100%.
    ///
    /// @dev Notes:
    /// - This fee represents a percentage, not an amount. Do not confuse it with {IERC3156FlashLender.flashFee},
    /// which calculates the fee amount for a specified flash loan amount.
    /// - Unlike the protocol fee, this is a global fee applied to all flash loans, not a per-asset fee.
    function flashFee() external view returns (UD60x18 fee);

    /// @notice Retrieves a flag indicating whether the provided ERC-20 asset can be flash loaned.
    /// @param token The contract address of the ERC-20 asset to check.
    function isFlashAsset(IERC20 token) external view returns (bool result);

    /// @notice Retrieves the protocol fee for all streams created with the provided ERC-20 asset.
    /// @param asset The contract address of the ERC-20 asset to query.
    /// @return fee The protocol fee denoted as a fixed-point number where 1e18 is 100%.
    function protocolFees(IERC20 asset) external view returns (UD60x18 fee);

    /*//////////////////////////////////////////////////////////////////////////
                               NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Updates the flash fee charged on all flash loans made with any ERC-20 asset.
    ///
    /// @dev Emits a {SetFlashFee} event.
    ///
    /// Notes:
    /// - Does not revert if the fee is the same.
    ///
    /// Requirements:
    /// - `msg.sender` must be the contract admin.
    ///
    /// @param newFlashFee The new flash fee to set, denoted as a fixed-point number where 1e18 is 100%.
    function setFlashFee(UD60x18 newFlashFee) external;

    /// @notice Sets a new protocol fee that will be charged on all streams created with the provided ERC-20 asset.
    ///
    /// @dev Emits a {SetProtocolFee} event.
    ///
    /// Notes:
    /// - The fee is not denoted in units of the asset's decimals; it is a fixed-point number. Refer to the
    /// PRBMath documentation for more detail on the logic of UD60x18.
    /// - Does not revert if the fee is the same.
    ///
    /// Requirements:
    /// - `msg.sender` must be the contract admin.
    ///
    /// @param asset The contract address of the ERC-20 asset to update the fee for.
    /// @param newProtocolFee The new protocol fee, denoted as a fixed-point number where 1e18 is 100%.
    function setProtocolFee(IERC20 asset, UD60x18 newProtocolFee) external;

    /// @notice Toggles the flash loanability of an ERC-20 asset.
    ///
    /// @dev Emits a {ToggleFlashAsset} event.
    ///
    /// Requirements:
    /// - `msg.sender` must be the admin.
    ///
    /// @param asset The address of the ERC-20 asset to toggle.
    function toggleFlashAsset(IERC20 asset) external;
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IERC721Metadata } from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";

import { Lockup } from "../types/DataTypes.sol";
import { ISablierV2Base } from "./ISablierV2Base.sol";
import { ISablierV2NFTDescriptor } from "./ISablierV2NFTDescriptor.sol";

/// @title ISablierV2Lockup
/// @notice Common logic between all Sablier V2 Lockup streaming contracts.
interface ISablierV2Lockup is
    ISablierV2Base, // 1 inherited component
    IERC721Metadata // 2 inherited components
{
    /*//////////////////////////////////////////////////////////////////////////
                                       EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Emitted when a stream is canceled.
    /// @param streamId The id of the stream.
    /// @param sender The address of the stream's sender.
    /// @param recipient The address of the stream's recipient.
    /// @param asset The contract address of the ERC-20 asset used for streaming.
    /// @param senderAmount The amount of assets refunded to the stream's sender, denoted in units of the asset's
    /// decimals.
    /// @param recipientAmount The amount of assets left for the stream's recipient to withdraw, denoted in units of the
    /// asset's decimals.
    event CancelLockupStream(
        uint256 streamId,
        address indexed sender,
        address indexed recipient,
        IERC20 indexed asset,
        uint128 senderAmount,
        uint128 recipientAmount
    );

    /// @notice Emitted when a sender gives up the right to cancel a stream.
    /// @param streamId The id of the stream.
    event RenounceLockupStream(uint256 indexed streamId);

    /// @notice Emitted when the admin sets a new NFT descriptor contract.
    /// @param admin The address of the current contract admin.
    /// @param oldNFTDescriptor The address of the old NFT descriptor contract.
    /// @param newNFTDescriptor The address of the new NFT descriptor contract.
    event SetNFTDescriptor(
        address indexed admin, ISablierV2NFTDescriptor oldNFTDescriptor, ISablierV2NFTDescriptor newNFTDescriptor
    );

    /// @notice Emitted when assets are withdrawn from a stream.
    /// @param streamId The id of the stream.
    /// @param to The address that has received the withdrawn assets.
    /// @param asset The contract address of the ERC-20 asset used for streaming.
    /// @param amount The amount of assets withdrawn, denoted in units of the asset's decimals.
    event WithdrawFromLockupStream(uint256 indexed streamId, address indexed to, IERC20 indexed asset, uint128 amount);

    /*//////////////////////////////////////////////////////////////////////////
                                 CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Retrieves the address of the ERC-20 asset used for streaming.
    /// @dev Reverts if `streamId` references a null stream.
    /// @param streamId The stream id for the query.
    function getAsset(uint256 streamId) external view returns (IERC20 asset);

    /// @notice Retrieves the amount deposited in the stream, denoted in units of the asset's decimals.
    /// @dev Reverts if `streamId` references a null stream.
    /// @param streamId The stream id for the query.
    function getDepositedAmount(uint256 streamId) external view returns (uint128 depositedAmount);

    /// @notice Retrieves the stream's end time, which is a Unix timestamp.
    /// @dev Reverts if `streamId` references a null stream.
    /// @param streamId The stream id for the query.
    function getEndTime(uint256 streamId) external view returns (uint40 endTime);

    /// @notice Retrieves the stream's recipient.
    /// @dev Reverts if the NFT has been burned.
    /// @param streamId The stream id for the query.
    function getRecipient(uint256 streamId) external view returns (address recipient);

    /// @notice Retrieves the amount refunded to the sender after a cancellation, denoted in units of the asset's
    /// decimals. This amount is always zero unless the stream was canceled.
    /// @dev Reverts if `streamId` references a null stream.
    /// @param streamId The stream id for the query.
    function getRefundedAmount(uint256 streamId) external view returns (uint128 refundedAmount);

    /// @notice Retrieves the stream's sender.
    /// @dev Reverts if `streamId` references a null stream.
    /// @param streamId The stream id for the query.
    function getSender(uint256 streamId) external view returns (address sender);

    /// @notice Retrieves the stream's start time, which is a Unix timestamp.
    /// @dev Reverts if `streamId` references a null stream.
    /// @param streamId The stream id for the query.
    function getStartTime(uint256 streamId) external view returns (uint40 startTime);

    /// @notice Retrieves the amount withdrawn from the stream, denoted in units of the asset's decimals.
    /// @dev Reverts if `streamId` references a null stream.
    /// @param streamId The stream id for the query.
    function getWithdrawnAmount(uint256 streamId) external view returns (uint128 withdrawnAmount);

    /// @notice Retrieves a flag indicating whether the stream can be canceled. When the stream is cold, this
    /// flag is always `false`.
    /// @dev Reverts if `streamId` references a null stream.
    /// @param streamId The stream id for the query.
    function isCancelable(uint256 streamId) external view returns (bool result);

    /// @notice Retrieves a flag indicating whether the stream is cold, i.e. settled, canceled, or depleted.
    /// @dev Reverts if `streamId` references a null stream.
    /// @param streamId The stream id for the query.
    function isCold(uint256 streamId) external view returns (bool result);

    /// @notice Retrieves a flag indicating whether the stream is depleted.
    /// @dev Reverts if `streamId` references a null stream.
    /// @param streamId The stream id for the query.
    function isDepleted(uint256 streamId) external view returns (bool result);

    /// @notice Retrieves a flag indicating whether the stream exists.
    /// @dev Does not revert if `streamId` references a null stream.
    /// @param streamId The stream id for the query.
    function isStream(uint256 streamId) external view returns (bool result);

    /// @notice Retrieves a flag indicating whether the stream NFT can be transferred.
    /// @dev Reverts if `streamId` references a null stream.
    /// @param streamId The stream id for the query.
    function isTransferable(uint256 streamId) external view returns (bool result);

    /// @notice Retrieves a flag indicating whether the stream is warm, i.e. either pending or streaming.
    /// @dev Reverts if `streamId` references a null stream.
    /// @param streamId The stream id for the query.
    function isWarm(uint256 streamId) external view returns (bool result);

    /// @notice Counter for stream ids, used in the create functions.
    function nextStreamId() external view returns (uint256);

    /// @notice Calculates the amount that the sender would be refunded if the stream were canceled, denoted in units
    /// of the asset's decimals.
    /// @dev Reverts if `streamId` references a null stream.
    /// @param streamId The stream id for the query.
    function refundableAmountOf(uint256 streamId) external view returns (uint128 refundableAmount);

    /// @notice Retrieves the stream's status.
    /// @param streamId The stream id for the query.
    function statusOf(uint256 streamId) external view returns (Lockup.Status status);

    /// @notice Calculates the amount streamed to the recipient, denoted in units of the asset's decimals.
    /// @dev Reverts if `streamId` references a null stream.
    /// @param streamId The stream id for the query.
    function streamedAmountOf(uint256 streamId) external view returns (uint128 streamedAmount);

    /// @notice Retrieves a flag indicating whether the stream was canceled.
    /// @dev Reverts if `streamId` references a null stream.
    /// @param streamId The stream id for the query.
    function wasCanceled(uint256 streamId) external view returns (bool result);

    /// @notice Calculates the amount that the recipient can withdraw from the stream, denoted in units of the asset's
    /// decimals.
    /// @dev Reverts if `streamId` references a null stream.
    /// @param streamId The stream id for the query.
    function withdrawableAmountOf(uint256 streamId) external view returns (uint128 withdrawableAmount);

    /*//////////////////////////////////////////////////////////////////////////
                               NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Burns the NFT associated with the stream.
    ///
    /// @dev Emits a {Transfer} event.
    ///
    /// Requirements:
    /// - Must not be delegate called.
    /// - `streamId` must reference a depleted stream.
    /// - The NFT must exist.
    /// - `msg.sender` must be either the NFT owner or an approved third party.
    ///
    /// @param streamId The id of the stream NFT to burn.
    function burn(uint256 streamId) external;

    /// @notice Cancels the stream and refunds any remaining assets to the sender.
    ///
    /// @dev Emits a {Transfer}, {CancelLockupStream}, and {MetadataUpdate} event.
    ///
    /// Notes:
    /// - If there any assets left for the recipient to withdraw, the stream is marked as canceled. Otherwise, the
    /// stream is marked as depleted.
    /// - This function attempts to invoke a hook on the recipient, if the resolved address is a contract.
    ///
    /// Requirements:
    /// - Must not be delegate called.
    /// - The stream must be warm and cancelable.
    /// - `msg.sender` must be the stream's sender.
    ///
    /// @param streamId The id of the stream to cancel.
    function cancel(uint256 streamId) external;

    /// @notice Cancels multiple streams and refunds any remaining assets to the sender.
    ///
    /// @dev Emits multiple {Transfer}, {CancelLockupStream}, and {MetadataUpdate} events.
    ///
    /// Notes:
    /// - Refer to the notes in {cancel}.
    ///
    /// Requirements:
    /// - All requirements from {cancel} must be met for each stream.
    ///
    /// @param streamIds The ids of the streams to cancel.
    function cancelMultiple(uint256[] calldata streamIds) external;

    /// @notice Removes the right of the stream's sender to cancel the stream.
    ///
    /// @dev Emits a {RenounceLockupStream} and {MetadataUpdate} event.
    ///
    /// Notes:
    /// - This is an irreversible operation.
    /// - This function attempts to invoke a hook on the stream's recipient, provided that the recipient is a contract.
    ///
    /// Requirements:
    /// - Must not be delegate called.
    /// - `streamId` must reference a warm stream.
    /// - `msg.sender` must be the stream's sender.
    /// - The stream must be cancelable.
    ///
    /// @param streamId The id of the stream to renounce.
    function renounce(uint256 streamId) external;

    /// @notice Sets a new NFT descriptor contract, which produces the URI describing the Sablier stream NFTs.
    ///
    /// @dev Emits a {SetNFTDescriptor} and {BatchMetadataUpdate} event.
    ///
    /// Notes:
    /// - Does not revert if the NFT descriptor is the same.
    ///
    /// Requirements:
    /// - `msg.sender` must be the contract admin.
    ///
    /// @param newNFTDescriptor The address of the new NFT descriptor contract.
    function setNFTDescriptor(ISablierV2NFTDescriptor newNFTDescriptor) external;

    /// @notice Withdraws the provided amount of assets from the stream to the `to` address.
    ///
    /// @dev Emits a {Transfer}, {WithdrawFromLockupStream}, and {MetadataUpdate} event.
    ///
    /// Notes:
    /// - This function attempts to invoke a hook on the stream's recipient, provided that the recipient is a contract
    /// and `msg.sender` is either the sender or an approved operator.
    ///
    /// Requirements:
    /// - Must not be delegate called.
    /// - `streamId` must not reference a null or depleted stream.
    /// - `msg.sender` must be the stream's sender, the stream's recipient or an approved third party.
    /// - `to` must be the recipient if `msg.sender` is the stream's sender.
    /// - `to` must not be the zero address.
    /// - `amount` must be greater than zero and must not exceed the withdrawable amount.
    ///
    /// @param streamId The id of the stream to withdraw from.
    /// @param to The address receiving the withdrawn assets.
    /// @param amount The amount to withdraw, denoted in units of the asset's decimals.
    function withdraw(uint256 streamId, address to, uint128 amount) external;

    /// @notice Withdraws the maximum withdrawable amount from the stream to the provided address `to`.
    ///
    /// @dev Emits a {Transfer}, {WithdrawFromLockupStream}, and {MetadataUpdate} event.
    ///
    /// Notes:
    /// - Refer to the notes in {withdraw}.
    ///
    /// Requirements:
    /// - Refer to the requirements in {withdraw}.
    ///
    /// @param streamId The id of the stream to withdraw from.
    /// @param to The address receiving the withdrawn assets.
    function withdrawMax(uint256 streamId, address to) external;

    /// @notice Withdraws the maximum withdrawable amount from the stream to the current recipient, and transfers the
    /// NFT to `newRecipient`.
    ///
    /// @dev Emits a {WithdrawFromLockupStream} and a {Transfer} event.
    ///
    /// Notes:
    /// - If the withdrawable amount is zero, the withdrawal is skipped.
    /// - Refer to the notes in {withdraw}.
    ///
    /// Requirements:
    /// - `msg.sender` must be the stream's recipient.
    /// - Refer to the requirements in {withdraw}.
    /// - Refer to the requirements in {IERC721.transferFrom}.
    ///
    /// @param streamId The id of the stream NFT to transfer.
    /// @param newRecipient The address of the new owner of the stream NFT.
    function withdrawMaxAndTransfer(uint256 streamId, address newRecipient) external;

    /// @notice Withdraws assets from streams to the provided address `to`.
    ///
    /// @dev Emits multiple {Transfer}, {WithdrawFromLockupStream}, and {MetadataUpdate} events.
    ///
    /// Notes:
    /// - This function attempts to call a hook on the recipient of each stream, unless `msg.sender` is the recipient.
    ///
    /// Requirements:
    /// - All requirements from {withdraw} must be met for each stream.
    /// - There must be an equal number of `streamIds` and `amounts`.
    ///
    /// @param streamIds The ids of the streams to withdraw from.
    /// @param to The address receiving the withdrawn assets.
    /// @param amounts The amounts to withdraw, denoted in units of the asset's decimals.
    function withdrawMultiple(uint256[] calldata streamIds, address to, uint128[] calldata amounts) external;
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { Lockup, LockupLinear } from "../types/DataTypes.sol";
import { ISablierV2Lockup } from "./ISablierV2Lockup.sol";

/// @title ISablierV2LockupLinear
/// @notice Creates and manages Lockup streams with linear streaming functions.
interface ISablierV2LockupLinear is ISablierV2Lockup {
    /*//////////////////////////////////////////////////////////////////////////
                                       EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Emitted when a stream is created.
    /// @param streamId The id of the newly created stream.
    /// @param funder The address which funded the stream.
    /// @param sender The address streaming the assets, with the ability to cancel the stream.
    /// @param recipient The address receiving the assets.
    /// @param amounts Struct containing (i) the deposit amount, (ii) the protocol fee amount, and (iii) the
    /// broker fee amount, all denoted in units of the asset's decimals.
    /// @param asset The contract address of the ERC-20 asset used for streaming.
    /// @param cancelable Boolean indicating whether the stream will be cancelable or not.
    /// @param transferable Boolean indicating whether the stream NFT is transferable or not.
    /// @param range Struct containing (i) the stream's start time, (ii) cliff time, and (iii) end time, all as Unix
    /// timestamps.
    /// @param broker The address of the broker who has helped create the stream, e.g. a front-end website.
    event CreateLockupLinearStream(
        uint256 streamId,
        address funder,
        address indexed sender,
        address indexed recipient,
        Lockup.CreateAmounts amounts,
        IERC20 indexed asset,
        bool cancelable,
        bool transferable,
        LockupLinear.Range range,
        address broker
    );

    /*//////////////////////////////////////////////////////////////////////////
                                 CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Retrieves the stream's cliff time, which is a Unix timestamp.
    /// @dev Reverts if `streamId` references a null stream.
    /// @param streamId The stream id for the query.
    function getCliffTime(uint256 streamId) external view returns (uint40 cliffTime);

    /// @notice Retrieves the stream's range, which is a struct containing (i) the stream's start time, (ii) cliff
    /// time, and (iii) end time, all as Unix timestamps.
    /// @dev Reverts if `streamId` references a null stream.
    /// @param streamId The stream id for the query.
    function getRange(uint256 streamId) external view returns (LockupLinear.Range memory range);

    /// @notice Retrieves the stream entity.
    /// @dev Reverts if `streamId` references a null stream.
    /// @param streamId The stream id for the query.
    function getStream(uint256 streamId) external view returns (LockupLinear.Stream memory stream);

    /// @notice Calculates the amount streamed to the recipient, denoted in units of the asset's decimals.
    ///
    /// When the stream is warm, the streaming function is:
    ///
    /// $$
    /// f(x) = x * d + c
    /// $$
    ///
    /// Where:
    ///
    /// - $x$ is the elapsed time divided by the stream's total duration.
    /// - $d$ is the deposited amount.
    /// - $c$ is the cliff amount.
    ///
    /// Upon cancellation of the stream, the amount streamed is calculated as the difference between the deposited
    /// amount and the refunded amount. Ultimately, when the stream becomes depleted, the streamed amount is equivalent
    /// to the total amount withdrawn.
    ///
    /// @dev Reverts if `streamId` references a null stream.
    /// @param streamId The stream id for the query.
    function streamedAmountOf(uint256 streamId) external view returns (uint128 streamedAmount);

    /*//////////////////////////////////////////////////////////////////////////
                               NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Creates a stream by setting the start time to `block.timestamp`, and the end time to
    /// the sum of `block.timestamp` and `params.durations.total`. The stream is funded by `msg.sender` and is wrapped
    /// in an ERC-721 NFT.
    ///
    /// @dev Emits a {Transfer} and {CreateLockupLinearStream} event.
    ///
    /// Requirements:
    /// - All requirements in {createWithRange} must be met for the calculated parameters.
    ///
    /// @param params Struct encapsulating the function parameters, which are documented in {DataTypes}.
    /// @return streamId The id of the newly created stream.
    function createWithDurations(LockupLinear.CreateWithDurations calldata params)
        external
        returns (uint256 streamId);

    /// @notice Creates a stream with the provided start time and end time as the range. The stream is
    /// funded by `msg.sender` and is wrapped in an ERC-721 NFT.
    ///
    /// @dev Emits a {Transfer} and {CreateLockupLinearStream} event.
    ///
    /// Notes:
    /// - As long as the times are ordered, it is not an error for the start or the cliff time to be in the past.
    ///
    /// Requirements:
    /// - Must not be delegate called.
    /// - `params.totalAmount` must be greater than zero.
    /// - If set, `params.broker.fee` must not be greater than `MAX_FEE`.
    /// - `params.range.start` must be less than or equal to `params.range.cliff`.
    /// - `params.range.cliff` must be less than `params.range.end`.
    /// - `params.range.end` must be in the future.
    /// - `params.recipient` must not be the zero address.
    /// - `msg.sender` must have allowed this contract to spend at least `params.totalAmount` assets.
    ///
    /// @param params Struct encapsulating the function parameters, which are documented in {DataTypes}.
    /// @return streamId The id of the newly created stream.
    function createWithRange(LockupLinear.CreateWithRange calldata params) external returns (uint256 streamId);
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { IERC721Metadata } from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";

/// @title ISablierV2NFTDescriptor
/// @notice This contract generates the URI describing the Sablier V2 stream NFTs.
/// @dev Inspired by Uniswap V3 Positions NFTs.
interface ISablierV2NFTDescriptor {
    /// @notice Produces the URI describing a particular stream NFT.
    /// @dev This is a data URI with the JSON contents directly inlined.
    /// @param sablier The address of the Sablier contract the stream was created in.
    /// @param streamId The id of the stream for which to produce a description.
    /// @return uri The URI of the ERC721-compliant metadata.
    function tokenURI(IERC721Metadata sablier, uint256 streamId) external view returns (string memory uri);
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { UD2x18 } from "@prb/math/src/UD2x18.sol";
import { UD60x18 } from "@prb/math/src/UD60x18.sol";

// DataTypes.sol
//
// This file defines all structs used in V2 Core, most of which are organized under three namespaces:
//
// - Lockup
// - LockupDynamic
// - LockupLinear
//
// You will notice that some structs contain "slot" annotations - they are used to indicate the
// storage layout of the struct. It is more gas efficient to group small data types together so
// that they fit in a single 32-byte slot.

/// @notice Struct encapsulating the broker parameters passed to the create functions. Both can be set to zero.
/// @param account The address receiving the broker's fee.
/// @param fee The broker's percentage fee from the total amount, denoted as a fixed-point number where 1e18 is 100%.
struct Broker {
    address account;
    UD60x18 fee;
}

/// @notice Namespace for the structs used in both {SablierV2LockupLinear} and {SablierV2LockupDynamic}.
library Lockup {
    /// @notice Struct encapsulating the deposit, withdrawn, and refunded amounts, all denoted in units
    /// of the asset's decimals.
    /// @dev Because the deposited and the withdrawn amount are often read together, declaring them in
    /// the same slot saves gas.
    /// @param deposited The initial amount deposited in the stream, net of fees.
    /// @param withdrawn The cumulative amount withdrawn from the stream.
    /// @param refunded The amount refunded to the sender. Unless the stream was canceled, this is always zero.
    struct Amounts {
        // slot 0
        uint128 deposited;
        uint128 withdrawn;
        // slot 1
        uint128 refunded;
    }

    /// @notice Struct encapsulating the deposit amount, the protocol fee amount, and the broker fee amount,
    /// all denoted in units of the asset's decimals.
    /// @param deposit The amount to deposit in the stream.
    /// @param protocolFee The protocol fee amount.
    /// @param brokerFee The broker fee amount.
    struct CreateAmounts {
        uint128 deposit;
        uint128 protocolFee;
        uint128 brokerFee;
    }

    /// @notice Enum representing the different statuses of a stream.
    /// @custom:value PENDING Stream created but not started; assets are in a pending state.
    /// @custom:value STREAMING Active stream where assets are currently being streamed.
    /// @custom:value SETTLED All assets have been streamed; recipient is due to withdraw them.
    /// @custom:value CANCELED Canceled stream; remaining assets await recipient's withdrawal.
    /// @custom:value DEPLETED Depleted stream; all assets have been withdrawn and/or refunded.
    enum Status {
        PENDING, // value 0
        STREAMING, // value 1
        SETTLED, // value 2
        CANCELED, // value 3
        DEPLETED // value 4
    }
}

/// @notice Namespace for the structs used in {SablierV2LockupDynamic}.
library LockupDynamic {
    /// @notice Struct encapsulating the parameters for the {SablierV2LockupDynamic.createWithDeltas} function.
    /// @param sender The address streaming the assets, with the ability to cancel the stream. It doesn't have to be the
    /// same as `msg.sender`.
    /// @param recipient The address receiving the assets.
    /// @param totalAmount The total amount of ERC-20 assets to be paid, including the stream deposit and any potential
    /// fees, all denoted in units of the asset's decimals.
    /// @param asset The contract address of the ERC-20 asset used for streaming.
    /// @param cancelable Indicates if the stream is cancelable.
    /// @param transferable Indicates if the stream NFT is transferable.
    /// @param broker Struct containing (i) the address of the broker assisting in creating the stream, and (ii) the
    /// percentage fee paid to the broker from `totalAmount`, denoted as a fixed-point number. Both can be set to zero.
    /// @param segments Segments with deltas used to compose the custom streaming curve. Milestones are calculated by
    /// starting from `block.timestamp` and adding each delta to the previous milestone.
    struct CreateWithDeltas {
        address sender;
        bool cancelable;
        bool transferable;
        address recipient;
        uint128 totalAmount;
        IERC20 asset;
        Broker broker;
        SegmentWithDelta[] segments;
    }

    /// @notice Struct encapsulating the parameters for the {SablierV2LockupDynamic.createWithMilestones}
    /// function.
    /// @param sender The address streaming the assets, with the ability to cancel the stream. It doesn't have to be the
    /// same as `msg.sender`.
    /// @param startTime The Unix timestamp indicating the stream's start.
    /// @param cancelable Indicates if the stream is cancelable.
    /// @param transferable Indicates if the stream NFT is transferable.
    /// @param recipient The address receiving the assets.
    /// @param totalAmount The total amount of ERC-20 assets to be paid, including the stream deposit and any potential
    /// fees, all denoted in units of the asset's decimals.
    /// @param asset The contract address of the ERC-20 asset used for streaming.
    /// @param broker Struct containing (i) the address of the broker assisting in creating the stream, and (ii) the
    /// percentage fee paid to the broker from `totalAmount`, denoted as a fixed-point number. Both can be set to zero.
    /// @param segments Segments used to compose the custom streaming curve.
    struct CreateWithMilestones {
        address sender;
        uint40 startTime;
        bool cancelable;
        bool transferable;
        address recipient;
        uint128 totalAmount;
        IERC20 asset;
        Broker broker;
        Segment[] segments;
    }

    /// @notice Struct encapsulating the time range.
    /// @param start The Unix timestamp indicating the stream's start.
    /// @param end The Unix timestamp indicating the stream's end.
    struct Range {
        uint40 start;
        uint40 end;
    }

    /// @notice Segment struct used in the Lockup Dynamic stream.
    /// @param amount The amount of assets to be streamed in this segment, denoted in units of the asset's decimals.
    /// @param exponent The exponent of this segment, denoted as a fixed-point number.
    /// @param milestone The Unix timestamp indicating this segment's end.
    struct Segment {
        // slot 0
        uint128 amount;
        UD2x18 exponent;
        uint40 milestone;
    }

    /// @notice Segment struct used at runtime in {SablierV2LockupDynamic.createWithDeltas}.
    /// @param amount The amount of assets to be streamed in this segment, denoted in units of the asset's decimals.
    /// @param exponent The exponent of this segment, denoted as a fixed-point number.
    /// @param delta The time difference in seconds between this segment and the previous one.
    struct SegmentWithDelta {
        uint128 amount;
        UD2x18 exponent;
        uint40 delta;
    }

    /// @notice Lockup Dynamic stream.
    /// @dev The fields are arranged like this to save gas via tight variable packing.
    /// @param sender The address streaming the assets, with the ability to cancel the stream.
    /// @param startTime The Unix timestamp indicating the stream's start.
    /// @param endTime The Unix timestamp indicating the stream's end.
    /// @param isCancelable Boolean indicating if the stream is cancelable.
    /// @param wasCanceled Boolean indicating if the stream was canceled.
    /// @param asset The contract address of the ERC-20 asset used for streaming.
    /// @param isDepleted Boolean indicating if the stream is depleted.
    /// @param isStream Boolean indicating if the struct entity exists.
    /// @param isTransferable Boolean indicating if the stream NFT is transferable.
    /// @param amounts Struct containing the deposit, withdrawn, and refunded amounts, all denoted in units of the
    /// asset's decimals.
    /// @param segments Segments used to compose the custom streaming curve.
    struct Stream {
        // slot 0
        address sender;
        uint40 startTime;
        uint40 endTime;
        bool isCancelable;
        bool wasCanceled;
        // slot 1
        IERC20 asset;
        bool isDepleted;
        bool isStream;
        bool isTransferable;
        // slot 2 and 3
        Lockup.Amounts amounts;
        // slots [4..n]
        Segment[] segments;
    }
}

/// @notice Namespace for the structs used in {SablierV2LockupLinear}.
library LockupLinear {
    /// @notice Struct encapsulating the parameters for the {SablierV2LockupLinear.createWithDurations} function.
    /// @param sender The address streaming the assets, with the ability to cancel the stream. It doesn't have to be the
    /// same as `msg.sender`.
    /// @param recipient The address receiving the assets.
    /// @param totalAmount The total amount of ERC-20 assets to be paid, including the stream deposit and any potential
    /// fees, all denoted in units of the asset's decimals.
    /// @param asset The contract address of the ERC-20 asset used for streaming.
    /// @param cancelable Indicates if the stream is cancelable.
    /// @param transferable Indicates if the stream NFT is transferable.
    /// @param durations Struct containing (i) cliff period duration and (ii) total stream duration, both in seconds.
    /// @param broker Struct containing (i) the address of the broker assisting in creating the stream, and (ii) the
    /// percentage fee paid to the broker from `totalAmount`, denoted as a fixed-point number. Both can be set to zero.
    struct CreateWithDurations {
        address sender;
        address recipient;
        uint128 totalAmount;
        IERC20 asset;
        bool cancelable;
        bool transferable;
        Durations durations;
        Broker broker;
    }

    /// @notice Struct encapsulating the parameters for the {SablierV2LockupLinear.createWithRange} function.
    /// @param sender The address streaming the assets, with the ability to cancel the stream. It doesn't have to be the
    /// same as `msg.sender`.
    /// @param recipient The address receiving the assets.
    /// @param totalAmount The total amount of ERC-20 assets to be paid, including the stream deposit and any potential
    /// fees, all denoted in units of the asset's decimals.
    /// @param asset The contract address of the ERC-20 asset used for streaming.
    /// @param cancelable Indicates if the stream is cancelable.
    /// @param transferable Indicates if the stream NFT is transferable.
    /// @param range Struct containing (i) the stream's start time, (ii) cliff time, and (iii) end time, all as Unix
    /// timestamps.
    /// @param broker Struct containing (i) the address of the broker assisting in creating the stream, and (ii) the
    /// percentage fee paid to the broker from `totalAmount`, denoted as a fixed-point number. Both can be set to zero.
    struct CreateWithRange {
        address sender;
        address recipient;
        uint128 totalAmount;
        IERC20 asset;
        bool cancelable;
        bool transferable;
        Range range;
        Broker broker;
    }

    /// @notice Struct encapsulating the cliff duration and the total duration.
    /// @param cliff The cliff duration in seconds.
    /// @param total The total duration in seconds.
    struct Durations {
        uint40 cliff;
        uint40 total;
    }

    /// @notice Struct encapsulating the time range.
    /// @param start The Unix timestamp for the stream's start.
    /// @param cliff The Unix timestamp for the cliff period's end.
    /// @param end The Unix timestamp for the stream's end.
    struct Range {
        uint40 start;
        uint40 cliff;
        uint40 end;
    }

    /// @notice Lockup Linear stream.
    /// @dev The fields are arranged like this to save gas via tight variable packing.
    /// @param sender The address streaming the assets, with the ability to cancel the stream.
    /// @param startTime The Unix timestamp indicating the stream's start.
    /// @param cliffTime The Unix timestamp indicating the cliff period's end.
    /// @param isCancelable Boolean indicating if the stream is cancelable.
    /// @param wasCanceled Boolean indicating if the stream was canceled.
    /// @param asset The contract address of the ERC-20 asset used for streaming.
    /// @param endTime The Unix timestamp indicating the stream's end.
    /// @param isDepleted Boolean indicating if the stream is depleted.
    /// @param isStream Boolean indicating if the struct entity exists.
    /// @param isTransferable Boolean indicating if the stream NFT is transferable.
    /// @param amounts Struct containing the deposit, withdrawn, and refunded amounts, all denoted in units of the
    /// asset's decimals.
    struct Stream {
        // slot 0
        address sender;
        uint40 startTime;
        uint40 cliffTime;
        bool isCancelable;
        bool wasCanceled;
        // slot 1
        IERC20 asset;
        uint40 endTime;
        bool isDepleted;
        bool isStream;
        bool isTransferable;
        // slot 2 and 3
        Lockup.Amounts amounts;
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity =0.8.25;

import { SafeTransferLib } from "solady/utils/SafeTransferLib.sol";
import { FixedPointMathLib } from "solady/utils/FixedPointMathLib.sol";
import { ReentrancyGuard } from "solady/utils/ReentrancyGuard.sol";
import { Clone } from "solady/utils/Clone.sol";
import { MerkleProofLib } from "solady/utils/MerkleProofLib.sol";
import { EIP712 } from "solady/utils/EIP712.sol";
import { ECDSA } from "solady/utils/ECDSA.sol";
import { ud60x18 } from "@prb/math/src/UD60x18.sol";
import {
    ISablierV2LockupLinear,
    IERC20
} from "@sablier/v2-core/src/interfaces/ISablierV2LockupLinear.sol";
import { Broker, LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";

import { FjordMath } from "./libraries/FjordMath.sol";
import { FjordConstants } from "./libraries/FjordConstants.sol";

enum PoolStatus {
    Active,
    Paused,
    Closed,
    Canceled
}

enum PoolType {
    Fixed,
    Overflow
}

/// @notice A struct representing a tiered sale within a FixedPricePool.
/// @param amountForSale The total number of shares available for purchase in this tier.
/// @param pricePerShare The price per share in this tier.
/// @param maximumPerUser The maximum number of shares a user can purchase in this tier.
/// @param minimumPerUser The minimum number of shares a user must purchase in this tier.
struct Tier {
    uint256 amountForSale;
    uint256 pricePerShare;
    uint256 maximumPerUser;
    uint256 minimumPerUser;
}

struct TiersModified {
    uint8 tierIndex;
    uint256 assetsIn;
    uint256 sharesOutInTier;
}

abstract contract BasePool is Clone, ReentrancyGuard, EIP712, FjordConstants {
    /// -----------------------------------------------------------------------
    /// Dependencies
    /// -----------------------------------------------------------------------
    using SafeTransferLib for address;
    using FixedPointMathLib for uint256;
    using FjordMath for *;
    using MerkleProofLib for *;
    using ECDSA for bytes32;

    /// -----------------------------------------------------------------------
    /// Errors
    /// -----------------------------------------------------------------------

    /// @notice Error when the whitelist proof provided is invalid or does not exist.
    error InvalidProof();

    /// @notice Error when the recovered signer of the signature is not the delegate signer.
    error InvalidSignature();

    /// @notice Error when the user attempts to purchase/supply more than the maximum allowed.
    error MaxPurchaseExeeded();

    /// @notice Error when the user attempts to purchase/supply less than the minimum allowed.
    error MinPurchaseNotMet();

    /// @notice Error when the user attempts to redeem shares that they do not have.
    error NoSharesRedeemable();

    /// @notice Error when the caller is not the pool owner.
    error NotOwner();

    /// @notice Error when the redemption timestamp has not been reached.
    error RedeemedTooEarly();

    /// @notice Error when the sale is still active.
    error SaleActive();

    /// @notice Error when a redeem is called on a canceled pool.
    error SaleCancelled();

    /// @notice Error when the sale is paused/canceled/closed.
    error SaleInactive();

    /// @notice Error when the sale is not cancelable due to the sale being active.
    error SaleNotCancelable();

    /// @notice Error when the sale is not pausable due to the sale being closed or cancelled.
    error SaleNotPausable();

    /// @notice Error when the user attempts to purchase/supply an amount that would leave less than the minimum swap threshold available in the pool.
    error MandatoryMinimumSwapThreshold();

    /// @notice Error when the signature deadline has passed.
    error StaleSignature();

    /// @notice Error emitted when a user tries to redeem a token that is not redeemable, generally due to the token being airdropped on a different chain post sale.
    error TokenNotRedeemable();

    /// @notice Error when a user tries to swap an amount of tokens that is 0.
    error TransferZero();

    /// @notice Error when a user tries to purchase more than the maximum purchase amount.
    error UserMaxPurchaseExceeded();

    /// @notice Error when the user tries to purchase less than the minimum purchase amount.
    error UserMinPurchaseNotMet();

    /// @notice Error when the recipient address is the zero address.
    error ZeroAddress();

    /// @notice Invalid close operations.
    error CloseConditionNotMet();

    /// -----------------------------------------------------------------------
    /// Events
    /// -----------------------------------------------------------------------

    /// @notice Emitted when the pool is closed and the funds are distributed.
    event Closed(
        uint256 totalFundsRaised, uint256 totalSharesSold, uint256 platformFee, uint256 swapFee
    );

    /// @notice Emitted when the pool is paused or unpaused.
    event PauseToggled(bool paused);

    /// @notice Emitted when the pool is canceled before it begins.
    event PoolCanceled();

    /// @notice Emitted when the pool is able to close early due to reaching its raise cap.
    event PoolCompleted();

    /// @notice Emitted when a user is refunded due to the raise goal not being met.
    event Refunded(address indexed recipient, uint256 amount);

    /// @notice Emitted when a user redeems their shares post sale if the raise goal was met.
    event Redeemed(address indexed recipient, uint256 shares, uint256 streamID);

    /// @notice Emitted when the raise goal is not met and the pool is closed.
    event RaiseGoalNotMet(uint256 sharesNotSold, uint256 fundsRaised, uint256 feesGenerated);

    /// -----------------------------------------------------------------------
    /// Immutable Arguments -- Public
    /// -----------------------------------------------------------------------

    ISablierV2LockupLinear public immutable SABLIER;

    /// -----------------------------------------------------------------------
    /// Immutable Arguments -- Public
    /// -----------------------------------------------------------------------

    /// @notice The owner of the pool.
    /// @dev The owner can cancel the sale before it starts, pause/unpause the sale, and will receive the funds raised post sale.
    function owner() public pure returns (address) {
        return _getArgAddress(OWNER_OFFSET);
    }

    /// @notice The address of the share token that is being sold off by the creator.
    function shareToken() public pure returns (address) {
        return _getArgAddress(SHARE_TOKEN_OFFSET);
    }

    /// @notice Returns the address of the asset token used for purchasing shares.
    function assetToken() public pure returns (address) {
        return _getArgAddress(ASSET_TOKEN_OFFSET);
    }

    /// @notice Returns the address of the recipient of platform and swap fees generated by the pool.
    function feeRecipient() public pure returns (address) {
        return _getArgAddress(FEE_RECIPIENT_OFFSET);
    }

    /// @notice Returns the address of the delegate signer used for anti-snipe protection.
    /// @dev This address is provided by the factory contract and is protocol-owned.
    function delegateSigner() public pure returns (address) {
        return _getArgAddress(DELEGATE_SIGNER_OFFSET);
    }

    /// @notice The total number of shares that are being sold during the sale.
    /// @dev This value is normalized to 18 decimals.
    function sharesForSale() public pure virtual returns (uint256) {
        return _getArgUint256(SHARES_FOR_SALE_OFFSET);
    }

    /// @notice Returns the minimum raise goal defined by the creator.
    /// @dev For FixedPricePools, this is the number of shares that must be sold.
    /// @dev For OverflowPools, this is the number of assets that must be raised.
    /// @dev If the minimum raise goal is not met, users and creator are refunded.
    /// @dev This value is normalized to 18 decimals.
    function minimumTokensForSale() public pure returns (uint256) {
        return _getArgUint256(MINIMUM_TOKENS_FOR_SALE_OFFSET);
    }

    /// @notice Returns the maximum number of tokens that can be purchased within a sale.
    /// @dev For FixedPricePools, this is the number of shares a user can purchase.
    /// @dev For OverflowPools, this is the number of assets a user can used to purchase.
    /// @dev This value is normalized to 18 decimals.
    function maximumTokensPerUser() public pure returns (uint256) {
        return _getArgUint256(MAXIMUM_TOKENS_PER_USER_OFFSET);
    }

    /// @notice Returns the minimum number of tokens that must be purchased within a sale.
    /// @dev For FixedPricePools, this is the minimum number of shares a user must purchase.
    /// @dev For OverflowPools, this is the minimum number of assets a user must use to purchase.
    /// @dev This value is normalized to 18 decimals.
    function minimumTokensPerUser() public pure returns (uint256) {
        return _getArgUint256(MINIMUM_TOKENS_PER_USER_OFFSET);
    }

    /// @notice The swap fee charged on each purchase.
    /// @dev This value is scaled to WAD such that 1e18 is equivalent to a 100% swap fee.
    function swapFeeWAD() public pure returns (uint64) {
        return _getArgUint64(SWAP_FEE_WAD_OFFSET);
    }

    /// @notice The platform fee charged on post-sale funds raised.
    function platformFeeWAD() public pure returns (uint64) {
        return _getArgUint64(PLATFORM_FEE_WAD_OFFSET);
    }

    /// @notice The timestamp at which the sale will start.
    function saleStart() public pure returns (uint40) {
        return _getArgUint40(SALE_START_OFFSET);
    }

    /// @notice The timestamp at which the sale will end.
    /// @dev This value is bypassed if a raise goal is defined and met or exceeded.
    function saleEnd() public pure returns (uint40) {
        return _getArgUint40(SALE_END_OFFSET);
    }

    /// @notice The timestamp at which users will be able to redeem their shares.
    /// @dev This value is bypassed in favor of a 24H max should a sale end early due to meeting its raise cap.
    function redemptionDelay() public pure returns (uint40) {
        return _getArgUint40(REDEMPTION_DELAY_OFFSET);
    }

    /// @notice The timestamp at which the vesting period will end.
    function vestEnd() public pure returns (uint40) {
        return _getArgUint40(VEST_END_OFFSET);
    }

    /// @notice The timestamp at which the vesting cliff period will end.
    function vestCliff() public pure returns (uint40) {
        return _getArgUint40(VEST_CLIFF_OFFSET);
    }

    /// @notice The number of decimals for the share token.
    function shareDecimals() public pure returns (uint8) {
        return _getArgUint8(SHARE_TOKEN_DECIMALS_OFFSET);
    }

    /// @notice Returns the number of decimals for the asset token.
    function assetDecimals() public pure returns (uint8) {
        return _getArgUint8(ASSET_TOKEN_DECIMALS_OFFSET);
    }

    /// @notice Returns true if the anti-snipe feature is enabled, false otherwise.
    /// @dev If anti-snipe is enabled, a valid signature from a delegate signer is required to make a purchase.
    function antiSnipeEnabled() public pure returns (bool) {
        return _getArgUint8(ANTISNIPE_ENABLED_OFFSET) != 0;
    }

    /// @notice A merkle root representing a whitelist of addresses allowed to participate in the sale.
    /// @dev If the whitelist is empty, the sale is open to all addresses.
    function whitelistMerkleRoot() public pure returns (bytes32) {
        return _getArgBytes32(WHITELIST_MERKLE_ROOT_OFFSET);
    }

    function vestingEnabled() public pure returns (bool) {
        return vestEnd() > saleEnd();
    }

    /// -----------------------------------------------------------------------
    /// Mutable State -- Public
    /// -----------------------------------------------------------------------

    /// @notice The current transaction nonce of the recipient, used for anti-snipe replay protection.
    mapping(address user => uint32 nonce) public nonces;

    /// @notice The current status of the pool (Paused, Active, Canceled, Closed).
    PoolStatus public status;

    /// @notice The total number of assets received during the sale, sans swap fees.
    /// @dev Must be denormalized before use.
    uint256 public totalNormalizedAssetsIn;

    /// @notice The total amount of swap fees generated during the sale.
    /// @dev Must be denormalized before use.
    uint256 public totalNormalizedAssetFeesIn;

    /// @notice The total normalized number of assets received per user, without accounting for swap fees.
    /// @dev Must be denormalized before use.
    mapping(address user => uint256 assetsIn) public userNormalizedAssetsIn;

    /// @dev actual sale end timestamp
    uint256 public saleEndTimestamp;

    /// -----------------------------------------------------------------------------------------------------------------------------------------
    /// Constructor
    /// -----------------------------------------------------------------------------------------------------------------------------------------

    constructor(address sablier) {
        SABLIER = ISablierV2LockupLinear(sablier);
    }

    /// -----------------------------------------------------------------------
    /// Modifiers
    /// -----------------------------------------------------------------------

    /// @notice Checks if the caller is the owner of the pool.
    modifier onlyOwner() {
        if (msg.sender != owner()) {
            revert NotOwner();
        }
        _;
    }

    /// @notice Checks if the current timestamp is lessthan the sale start, greater than the sale end, or canceled/closed/paused.
    /// @dev If the sale is not active, the pool bought into.
    modifier whenSaleActive() {
        if (
            uint40(block.timestamp) < saleStart() || uint40(block.timestamp) >= saleEnd()
                || PoolStatus.Active != status
        ) {
            revert SaleInactive();
        }
        _;
    }

    /// -----------------------------------------------------------------------
    /// GLOBAL LOGIC -- OVERRIDE REQUIRED -- Public -- Read Functions
    /// -----------------------------------------------------------------------

    /// @notice Checks if the pool can be closed.
    /// @return True if the pool can be closed, false otherwise.
    /// @dev The pool can be closed if all shares have been sold, or the sale end date has passed.
    function canClose() public view virtual returns (bool);

    /// @notice Returns the pool's pricing model (Fixed or Overflow).
    function poolType() public pure virtual returns (PoolType);

    /// @notice Returns the hash of the EIP712 typehash for the pool's buy function.
    function typeHash() public pure virtual returns (bytes32);

    /// @notice Returns the number of tokens remaining for purchase.
    /// @dev For FixedPricePools, this is the Math.min(sharesForSale - totalSharesSold, maximumTokensPerUser - purchasedShares[user]).
    /// @dev For OverflowPools, this is maximumTokensPerUser - rawAssetsIn[user] when mTPU > 0.
    function userTokensRemaining(address user) public view virtual returns (uint256);

    /// -----------------------------------------------------------------------
    /// GLOBAL LOGIC -- OVERRIDE REQUIRED -- Internal -- Read Functions
    /// -----------------------------------------------------------------------

    ///@dev Checks if the minimum reserve is set and whether or not the shares/assets in sold surpasses this value.
    function _minReserveMet() internal view virtual returns (bool);

    /// -----------------------------------------------------------------------
    /// GLOBAL LOGIC -- Public -- Read Functions
    /// -----------------------------------------------------------------------

    /// @notice Whether or not a non-empty whitelist is present.
    function hasWhitelist() public pure returns (bool) {
        return whitelistMerkleRoot() != 0;
    }

    /// -----------------------------------------------------------------------
    /// BUY LOGIC -- OVERRIDE REQUIRED -- Internal -- Read Functions
    /// -----------------------------------------------------------------------

    ///@notice Calculates the base assets in based on the pool type.
    ///@dev For FixedPricePools, this will additionally handle tier logic.
    function _calculateBaseAssetsIn(
        address recipient,
        uint256 tokenAmount,
        uint256 maxPricePerShare
    )
        internal
        view
        virtual
        returns (uint256, TiersModified[] memory);

    ///@dev Normalizes the amount based on the pool type.
    ///@dev For FixedPricePools, this is the number of shares being purchased.
    ///@dev For OverflowPools, this is the number of assets being used to purchase.
    function _normalizeAmount(uint256 amount) internal pure virtual returns (uint256);

    ///@dev Checks if the raise cap has been met and if the pool can be closed early.
    function _raiseCapMet() internal view virtual returns (bool);

    ///@notice Validates the pool limits based on the pool type.
    ///@param amount The number of tokens being purchased/used to purchase based on the pool type.
    ///@dev For fixed price pools this checks total shares sold, for overflow pools this checks total assets in.
    function _validatePoolLimits(uint256 amount) internal view virtual;

    ///@notice Updates the user's normalized assets in the pool.
    ///@param recipient The address of the recipient of the purchase.
    ///@param tokenAmount The number of tokens being purchased/used to purchase based on the pool type.
    ///@dev Checks if the updated user amount exceeds the maximumTokensPerUser and reverts if so.
    function _validateUserLimits(address recipient, uint256 tokenAmount) internal view virtual;

    /// -----------------------------------------------------------------------
    /// BUY LOGIC -- OVERRIDE REQUIRED -- Internal -- Write Functions
    /// -----------------------------------------------------------------------

    ///@dev Emits the buy event for the pool based on the pool type's implementation.
    function _emitBuyEvent(
        address recipient,
        uint256 assetsIn,
        uint256 feesPaid,
        uint256 sharesOut
    )
        internal
        virtual;

    ///@dev Handles updating pool state and user state post-purchase.
    ///@dev Additionally handles the transfer of assets to the pool.
    ///@param recipient The address of the recipient of the purchase.
    ///@param assetsIn The number of assets being used to purchase based on the pool type.
    ///@param sharesOut The number of shares being purchased based on the pool type.
    ///@param fees The swap fees generated from the purchase.
    function _updatePoolState(
        address recipient,
        uint256 assetsIn,
        uint256 sharesOut,
        uint256 fees,
        TiersModified[] memory updatedTiers
    )
        internal
        virtual
        returns (uint256);

    /// -----------------------------------------------------------------------
    /// BUY LOGIC -- Public -- Read Functions
    /// -----------------------------------------------------------------------

    ///@notice Returns the minimum swap threshold required for a purchase to be valid.
    ///@dev This is used to prevent rounding errors when making swaps between tokens of varying decimals.
    function mandatoryMinimumSwapIn() public pure virtual returns (uint256) {
        return shareDecimals().mandatoryMinimumSwapIn(assetDecimals());
    }

    ///@notice Calculates the swap fees and assets in based on the pool type and token amount being purchased/used to purchase.
    ///@param recipient The address of the recipient of the purchase.
    ///@param tokenAmount The number of tokens being purchased/used to purchase based on the pool type.
    ///@dev This function will account for tiers and all user-defined purchase limits, if applicable.
    function previewBuy(
        uint256 tokenAmount,
        address recipient
    )
        public
        view
        returns (uint256 assetsIn, uint256 feesPaid, TiersModified[] memory updatedTiers)
    {
        return previewBuy(tokenAmount, recipient, 0);
    }

    ///@notice Calculates the swap fees and assets in based on the pool type and token amount being purchased/used to purchase.
    ///@param recipient The address of the recipient of the purchase.
    ///@param tokenAmount The number of tokens being purchased/used to purchase based on the pool type.
    ///@dev This function will account for tiers and all user-defined purchase limits, if applicable.
    function previewBuy(
        uint256 tokenAmount,
        address recipient,
        uint256 maxPricePerShare
    )
        public
        view
        returns (uint256 assetsIn, uint256 feesPaid, TiersModified[] memory updatedTiers)
    {
        //Normalize the token amount based on the pool type
        tokenAmount = _normalizeAmount(tokenAmount);

        //Zero-checks and min/max purchase amount checks
        _validateBaseConditions(tokenAmount, recipient);

        //Pool-type specific conditional checks
        _validatePoolLimits(tokenAmount);

        //Pool-type specific User-specific conditional checks
        _validateUserLimits(recipient, tokenAmount);

        (assetsIn, updatedTiers) = _calculateBaseAssetsIn(recipient, tokenAmount, maxPricePerShare);
        feesPaid = _calculateFees(assetsIn);
    }

    /// -----------------------------------------------------------------------
    /// BUY LOGIC -- Internal -- Read Functions
    /// -----------------------------------------------------------------------

    /// @notice restrict access to whitelisted addresses.
    /// @dev  checks if the recipient address is whitelisted using a Merkle proof.
    function _validateWhitelist(address recipient, bytes32[] memory proof) internal pure {
        if (!proof.verify(whitelistMerkleRoot(), keccak256(abi.encodePacked(recipient)))) {
            revert InvalidProof();
        }
    }

    ///@notice Verifies the signature of buy payload for anti-snipe protection.
    ///@param recipient The address of the recipient of the purchase.
    ///@param tokenAmount The number of tokens being purchased/used to purchase based on the pool type.
    ///@param deadline The deadline for the signature to be valid.
    ///@param signature The signature to be verified.
    ///@dev Recovers the signer of the payload and compares it to the delegate signer.
    function _validateAntisnipe(
        address recipient,
        uint256 tokenAmount,
        uint64 deadline,
        bytes memory signature
    )
        internal
        view
    {
        if (uint64(block.timestamp) > deadline) {
            revert StaleSignature();
        }

        bytes32 expectedDigest = getDigest(tokenAmount, recipient, deadline);

        address signer = expectedDigest.recover(signature);

        if (signer != delegateSigner()) {
            revert InvalidSignature();
        }
    }

    ///@notice Helper function to validate non-zero token amounts and recipient addresses and
    ///ensures minimum purchase amounts are upheld. Passes the signature and proof to the
    ///_checkWhitelistAndAntisnipe function.
    function _validateBaseConditions(uint256 tokenAmount, address recipient) internal pure {
        if (tokenAmount == 0) revert TransferZero();
        if (recipient == address(0)) revert ZeroAddress();
        if (tokenAmount < mandatoryMinimumSwapIn()) revert MinPurchaseNotMet();
    }

    ///@notice Calculates the swap fees based on the swapFeeWAD and the token amount.
    function _calculateFees(uint256 assetsIn) internal pure returns (uint256) {
        return assetsIn.mulWadUp(swapFeeWAD());
    }

    /// -----------------------------------------------------------------------
    /// BUY LOGIC -- Internal --  Write Functions
    /// -----------------------------------------------------------------------

    /// @notice Allows any user to purchase shares in the pool.
    /// @param amount The number of shares to purchase (Fixed) or assets in (Overflow).
    /// @param recipient The address to receive the shares.
    /// @param deadline The deadline for the signature to be valid if anti-snipe is enabled.
    /// @param signature The signature to be verified if anti-snipe is enabled.
    /// @param proof The Merkle proof to be verified if a whitelist is present.
    function buy(
        uint256 amount,
        address recipient,
        uint64 deadline,
        bytes memory signature,
        bytes32[] memory proof,
        uint256 maxPricePerShare
    )
        internal
        nonReentrant
        whenSaleActive
    {
        if (hasWhitelist()) {
            _validateWhitelist(recipient, proof);
        }

        if (antiSnipeEnabled()) {
            _validateAntisnipe(recipient, amount, deadline, signature);
        }

        (uint256 normalizedAssetsIn, uint256 normalizedFees, TiersModified[] memory updatedTiers) =
            previewBuy(amount, recipient, maxPricePerShare);

        uint256 sharesOut = poolType() == PoolType.Fixed ? amount.normalize(shareDecimals()) : 0;

        uint256 normalizedAssetsOwed =
            _updatePoolState(recipient, normalizedAssetsIn, sharesOut, normalizedFees, updatedTiers);

        if (normalizedAssetsOwed > 0) {
            assetToken().safeTransferFrom(
                msg.sender, address(this), normalizedAssetsOwed.denormalizeUp(assetDecimals())
            );
        }

        if (antiSnipeEnabled()) {
            // increase nonce
            nonces[recipient]++;
        }

        _emitBuyEvent(recipient, normalizedAssetsIn, normalizedFees, sharesOut);

        //close early if the raise cap is met

        _handleEarlyClose();
    }

    /// @notice Checks if the pool has met its raise cap
    /// and if so, emits the PoolCompleted event.
    function _handleEarlyClose() internal {
        if (_raiseCapMet()) {
            emit PoolCompleted();
            close();
        }
    }

    /// -----------------------------------------------------------------------
    /// CLOSE LOGIC -- OVERRIDE REQUIRED -- Internal -- Read Functions
    /// -----------------------------------------------------------------------

    ///@notice Calculates the leftover shares that were not sold during the sale.
    ///@dev If overflow, this is sharesForSale(), otherwise it's sharesForSale() - totalSharesSold.
    function _calculateLeftoverShares() internal view virtual returns (uint256);

    /// -----------------------------------------------------------------------
    /// CLOSE LOGIC -- OVERRIDE REQUIRED -- Internal -- Write Functions
    /// -----------------------------------------------------------------------

    /// @notice Handles the refund of the owner's shares in the pool and the transfer of swap fees to the fee recipient.
    /// @dev Only called if the raise goal was not met. The overriding function should handle the transfer of funds to the owner
    /// according to the pool type.
    function _handleManagerRefund()
        internal
        virtual
        returns (uint256 sharesNotSold, uint256 fundsRaised, uint256 swapFees)
    {
        sharesNotSold = sharesForSale().denormalizeDown(shareDecimals());

        swapFees = totalNormalizedAssetFeesIn.denormalizeDown(assetDecimals());
        if (swapFees > 0) {
            assetToken().safeTransfer(feeRecipient(), swapFees);
        }
        fundsRaised = totalNormalizedAssetsIn.denormalizeUp(assetDecimals());
        uint256 currentBalance = assetToken().balanceOf(address(this));
        if (fundsRaised > currentBalance) {
            // possible precision loss after denormalize
            fundsRaised = currentBalance;
        } else if (fundsRaised < currentBalance) {
            // if someone donates assets to the pool, then take all back to owner
            assetToken().safeTransfer(owner(), currentBalance - fundsRaised);
        }
    }

    /// -----------------------------------------------------------------------
    /// CLOSE LOGIC -- Public -- Write Functions
    /// -----------------------------------------------------------------------

    // @notice Allows any user to close the pool and distribute the fees.
    // @dev The pool can only be closed after the sale end date has passed, OR the max shares sold have been reached.
    function close() public {
        if (!canClose()) {
            revert CloseConditionNotMet();
        }

        status = PoolStatus.Closed;
        saleEndTimestamp =
            uint256(saleEnd()) < block.timestamp ? uint256(saleEnd()) : block.timestamp;

        if (!_minReserveMet()) {
            (uint256 sharesNotSold, uint256 fundsRaised, uint256 swapFee) = _handleManagerRefund();
            emit RaiseGoalNotMet(sharesNotSold, fundsRaised, swapFee);
            return;
        } else {
            // avoid shawdow variable
            (uint256 platformFees, uint256 swapFees, uint256 totalFees) = _calculateCloseFees();
            if (totalFees > 0) {
                assetToken().safeTransfer(feeRecipient(), totalFees);
            }

            uint256 fundsRaised = IERC20(assetToken()).balanceOf(address(this));
            if (fundsRaised > 0) {
                assetToken().safeTransfer(owner(), fundsRaised);
            }

            uint256 sharesNotSold = _calculateLeftoverShares();
            // return the unsold shares to the owner
            if (sharesNotSold > 0 && shareToken() != address(0)) {
                shareToken().safeTransfer(owner(), sharesNotSold);
            }

            //totalsharessold, fundsraised
            emit Closed(
                fundsRaised,
                sharesForSale().denormalizeDown(shareDecimals()).rawSub(sharesNotSold),
                platformFees,
                swapFees
            );

            if (vestingEnabled()) {
                shareToken().safeApprove(address(SABLIER), type(uint256).max);
            }
        }
    }

    /// -----------------------------------------------------------------------
    /// CLOSE LOGIC -- Internal -- Read Functions
    /// -----------------------------------------------------------------------

    ///@dev Calculates the fees generated during the sale and denormalizes them for event emission and transfer.
    function _calculateCloseFees()
        internal
        view
        returns (uint256 platformFees, uint256 swapFees, uint256 totalFees)
    {
        platformFees = totalNormalizedAssetsIn.mulWad(platformFeeWAD());
        // denormalize the fees for event emission.
        swapFees = totalNormalizedAssetFeesIn.denormalizeDown(assetDecimals());
        platformFees = platformFees.denormalizeDown(assetDecimals());
        // totalFees sum of platformFees and swapFees
        totalFees = platformFees + swapFees;
    }
    /// -----------------------------------------------------------------------
    /// REDEEM LOGIC -- OVERRIDE REQUIRED - Internal -- Read Functions
    /// -----------------------------------------------------------------------

    /// @notice Calculates the amount of shares owed to the user based on the pool type.
    /// @dev For FixedPricePools, this is the number of shares the user has purchased directly.
    /// @dev For OverflowPools, this is calculate as the ratio of the users assets to the total assets in the pool
    /// multiplied by the total shares for sale.
    function _calculateSharesOwed(address user) internal view virtual returns (uint256);

    /// -----------------------------------------------------------------------
    /// REDEEM LOGIC -- OVERRIDE REQUIRED - Internal -- Write Functions
    /// -----------------------------------------------------------------------

    /// @notice Handles the refund/transfer of the user's assets in the pool if the raise goal was not met
    /// and updates user-specific state variables.
    /// @dev For FixedPricePools, this sets the user's sharesPurchased and assetsIn to 0.
    /// @dev For OverflowPools, this sets the user's assetsIn to 0.
    function _handleUserRefund(address user) internal virtual returns (uint256 assetsOwed);

    /// @notice Handles the state updates triggered on user-specific variables of pool state post-redemption.
    /// @dev For FixedPricePools, this sets the user's sharesPurchased and assetsIn to 0.
    /// @dev For OverflowPools, this sets the user's assetsIn to 0.
    function _handleUpdateUserRedemption(address sender) internal virtual;

    /// -----------------------------------------------------------------------
    /// REDEEM LOGIC -- External -- Write Functions
    /// -----------------------------------------------------------------------

    // @notice Allows any user to redeem their shares after the redemption timestamp has passed.
    // @dev Users can only redeem their shares if the sale has closed and the redemption timestamp has passed.
    // unless the pool met a hard cap and closed early, at which point the redemption timestamp is
    function redeem() external nonReentrant returns (uint256 streamID) {
        if (status == PoolStatus.Canceled) {
            revert SaleCancelled();
        }
        if (status != PoolStatus.Closed) {
            revert SaleActive();
        }

        if (block.timestamp < saleEndTimestamp + redemptionDelay()) {
            revert RedeemedTooEarly();
        }

        uint256 sharesOut;
        address sender = msg.sender;
        if (!_minReserveMet()) {
            emit Refunded(sender, _handleUserRefund(sender));
        } else {
            if (shareToken() != address(0)) {
                sharesOut = _calculateSharesOwed(sender);

                if (sharesOut == 0) {
                    revert NoSharesRedeemable();
                }

                _handleUpdateUserRedemption(sender);
                streamID = _handleRedemptionPayment(sender, sharesOut);
                emit Redeemed(sender, sharesOut, streamID);
            } else {
                revert TokenNotRedeemable();
            }
        }
    }

    /// -----------------------------------------------------------------------
    /// REDEEM LOGIC -- Internal -- Write Functions
    /// -----------------------------------------------------------------------

    ///@notice Handles the transfer of shares to the user post-redemption.
    ///@param recipient The address of the recipient of the shares.
    ///@param sharesOwed The number of shares owed to the user.
    ///@dev Only utilized if the raise goal was met.
    ///@dev If vesting is enabled and not expired, the shares are streamed to the user via sablier.
    function _handleRedemptionPayment(
        address recipient,
        uint256 sharesOwed
    )
        internal
        returns (uint256 streamID)
    {
        if (vestingEnabled() && vestEnd() > uint40(block.timestamp)) {
            LockupLinear.CreateWithRange memory params;

            params.sender = owner();
            params.recipient = recipient;
            params.totalAmount = uint128(sharesOwed);
            params.asset = IERC20(shareToken());
            params.cancelable = false;
            params.range =
                LockupLinear.Range({ start: saleEnd(), end: vestEnd(), cliff: vestCliff() });
            params.broker = Broker(address(0), ud60x18(0));

            streamID = SABLIER.createWithRange(params);
        } else {
            shareToken().safeTransfer(recipient, sharesOwed);
        }
    }

    /// -----------------------------------------------------------------------
    /// POOL ADMIN LOGIC -- External -- Owner-Only -- Write Functions
    /// -----------------------------------------------------------------------

    /// @notice Allows the pool creator to cancel the sale and withdraw all funds and shares before a sale begins.
    /// @dev The pool can only be canceled if the sale has not started.
    function cancelSale() external nonReentrant onlyOwner {
        if (status != PoolStatus.Active && status != PoolStatus.Paused) {
            revert SaleNotCancelable();
        }
        if (uint40(block.timestamp) >= saleStart()) {
            revert SaleActive();
        }

        status = PoolStatus.Canceled;

        if (shareToken() != address(0)) {
            shareToken().safeTransfer(owner(), sharesForSale().denormalizeDown(shareDecimals()));
        }
        emit PoolCanceled();
    }

    /// @notice Allows the pool creator to pause/unpause the sale, halting/enabling any trading activity.
    function togglePause() external nonReentrant onlyOwner {
        if (status == PoolStatus.Canceled || status == PoolStatus.Closed) {
            revert SaleNotPausable();
        }

        bool paused = status == PoolStatus.Paused;
        status = paused ? PoolStatus.Active : PoolStatus.Paused;

        emit PauseToggled(!paused);
    }

    /// -----------------------------------------------------------------------
    /// EIP712 Logic  -- External -- Read Functions
    /// -----------------------------------------------------------------------

    /// @notice Returns the expected digest for the EIP712 signature.
    /// @param tokenAmount The number of tokens being purchased/used to purchase based on the pool type.
    /// @param recipient The address of the recipient of the purchase.
    /// @param deadline The deadline for the signature to be valid.
    function getDigest(
        uint256 tokenAmount,
        address recipient,
        uint64 deadline
    )
        public
        view
        returns (bytes32)
    {
        return _hashTypedData(
            keccak256(
                abi.encode(typeHash(), tokenAmount, recipient, nonces[recipient] + 1, deadline)
            )
        );
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity =0.8.25;

import {
    BasePool,
    FixedPointMathLib,
    SafeTransferLib,
    MerkleProofLib,
    PoolStatus,
    PoolType,
    IERC20,
    Tier,
    TiersModified,
    FjordMath
} from "./BasePool.sol";

import { SafeCastLib } from "solady/utils/SafeCastLib.sol";

/// @title FixedERC2Pool
/// @notice A fixed price pool that allows users to purchase shares with a predefined standard ERC20 token.
/// @notice The pool creator can set the number of shares available for purchase, the price of each share,
/// @notice the sale start and end dates, the redemption date, and the maximum number of shares a user can purchase.
/// @notice The pool creator can also set a minimum number of shares that must be sold for the sale to be considered successful.
/// @notice The pool creator can also set a platform fee and a swap fee that will be taken from the raised funds.
/// @dev Creation will fail if the asset token has less than 2 or more than 18 decimals, or if the share token has more than 18 decimals.
/// @dev The pool will fail if the sale start date is after the sale end date, or if the redemption date is before the sale end date.
/// @dev The pool will fail if the platform fee or swap fee is greater than or equal to 1e18.
/// @dev The pool will fail if the price of each share is 0, or if the minimum number of shares that must be sold is greater than the number of shares available for purchase.
contract FixedPricePool is BasePool {
    /// -----------------------------------------------------------------------
    /// Dependencies
    /// -----------------------------------------------------------------------

    using MerkleProofLib for bytes32;
    using FixedPointMathLib for uint256;
    using SafeTransferLib for address;
    using FjordMath for uint256;
    using SafeCastLib for uint256;

    /// -----------------------------------------------------------------------------------------------------------------------------------------
    /// Errors
    /// -----------------------------------------------------------------------------------------------------------------------------------------

    error TierMaxPurchaseExceeded();
    error TierPurchaseTooLow(uint256 tierIndex);
    error InvalidTierPurchaseAmount();
    error SlippageExceeded();

    /// -----------------------------------------------------------------------------------------------------------------------------------------
    /// Events
    /// -----------------------------------------------------------------------------------------------------------------------------------------

    /// @notice Emitted when a user purchases shares in the pool.
    event BuyFixedShares(
        address indexed recipient, uint256 sharesOut, uint256 baseAssetsIn, uint256 feesPaid
    );

    /// @notice Emitted when a tiered sale rolls over to the next tier.
    event TierRollover(uint256 newTier);

    /// -----------------------------------------------------------------------------------------------------------------------------------------
    /// Constructor
    /// -----------------------------------------------------------------------------------------------------------------------------------------

    constructor(address _sablier) BasePool(_sablier) { }

    /// -----------------------------------------------------------------------------------------------------------------------------------------
    /// FIXED PRICE LOGIC -- Immutable Arguments -- Public -- Read Functions
    /// -----------------------------------------------------------------------------------------------------------------------------------------

    /// @notice The number of assets (with decimals) required to purchase 1 share.
    /// @dev This value is normalized to 18 decimals.
    function assetsPerToken() public pure returns (uint256) {
        return _getArgUint256(ASSETS_PER_TOKEN_OFFSET);
    }

    /// @notice All the tiers available for this sale.
    function tiers() public pure returns (Tier[] memory) {
        return abi.decode(_getArgBytes(TIERS_OFFSET, _tierDataLength()), (Tier[]));
    }

    /// @notice Whether the sale has multiple Tiers enabled, modifying the sale price and user-specific limits per tier.
    function isTiered() public pure returns (bool) {
        return _tierDataLength() > EMPTY_TIER_ARRAY_OFFSET;
    }

    /// @notice The current tier of the sale.
    function getCurrentTierData() public view returns (Tier memory) {
        return tiers()[currentTier];
    }

    /// @notice The tier data for a specific index.
    function getTierData(uint256 index) public pure returns (Tier memory) {
        return tiers()[index];
    }

    /// @notice The number of tiers slots allocated to the tiers array.
    /// @dev This is used to instantiate
    function getTierLength() public pure returns (uint8) {
        uint256 offDiff = _tierDataLength().rawSub(EMPTY_TIER_ARRAY_OFFSET);

        if (offDiff == 0) {
            return SafeCastLib.toUint8(0);
        } else {
            return (offDiff.rawDiv(TIER_BASE_OFFSET)).toUint8();
        }
    }

    /// -----------------------------------------------------------------------------------------------------------------------------------------
    /// FIXED PRICE LOGIC -- Immutable Arguments -- Internal -- Read Functions
    /// -----------------------------------------------------------------------------------------------------------------------------------------

    /// @notice The byte length of the `Tiers` arg, used to decode the tiers array into the proper number of elements.
    function _tierDataLength() internal pure returns (uint256) {
        return _getArgUint256(TIER_DATA_LENGTH_OFFSET);
    }

    /// -----------------------------------------------------------------------
    /// FIXED PRICE LOGIC -- Mutable State -- Public
    /// -----------------------------------------------------------------------

    /// @notice The active Tier of the sale, if in use.
    uint8 public currentTier;

    /// @notice The number of shares sold per tier.
    mapping(uint8 tier => uint256 totalSold) public amountSoldInTier;

    /// @notice The number of shares sold per tier per user.
    mapping(uint8 tier => mapping(address user => uint256 purchaseAmount)) public purchasedByTier;

    /// @notice The number of shares purchased by each user.
    /// @dev This value is normalized to 18 decimals.
    mapping(address user => uint256 sharesPurchased) public purchasedShares;

    /// @notice The total number of shares sold during the sale so far.
    /// @dev This value is normalized to 18 decimals.
    uint256 public totalSharesSold;

    /// @notice The total number of shares remaining for purchase.
    /// @dev This value is normalized to 18 decimals.
    function sharesRemaining() public view returns (uint256) {
        return sharesForSale().rawSub(totalSharesSold);
    }

    /// -----------------------------------------------------------------------------------------------------------------------------------------
    /// GLOBAL LOGIC -- OVERRIDE REQUIRED -- Public -- Read Functions
    /// -----------------------------------------------------------------------------------------------------------------------------------------

    /// @notice Checks if the sale period has passed or the pool has reached its shares out cap.
    function canClose() public view override returns (bool) {
        if (status == PoolStatus.Closed || status == PoolStatus.Canceled) {
            return false;
        }
        // Greater comparision for safety purpose only
        if (totalSharesSold >= sharesForSale() || uint40(block.timestamp) >= saleEnd()) {
            return true;
        }

        return false;
    }

    /// @notice The underlying pricing mechanism for the pool.
    function poolType() public pure override returns (PoolType) {
        return PoolType.Fixed;
    }

    /// @notice The keccak256 hash of the function used to buy shares in the pool.
    function typeHash() public pure override returns (bytes32) {
        return keccak256(
            "BuyExactShares(uint256 sharesOut,address recipient,uint32 nonce,uint64 deadline)"
        );
    }

    /// @notice Returns the number of shares remaining for purchase for a specific user.
    /// @param user The address of the user to check.
    /// @return The number of shares remaining for purchase.
    /// @dev This value is normalized to 18 decimals.
    function userTokensRemaining(address user) public view override returns (uint256) {
        return maximumTokensPerUser().rawSub(purchasedShares[user]).min(sharesRemaining());
    }

    /// -----------------------------------------------------------------------------------------------------------------------------------------
    /// GLOBAL LOGIC -- OVERRIDE REQUIRED -- Internal -- Read Functions
    /// -----------------------------------------------------------------------------------------------------------------------------------------

    ///@notice Checks if the minimum number of asset tokens have been swapped into the pool
    ///surpassed the creator-defined minimum.
    ///@dev Returning false will trigger refunds on `close` and user refunds on `redeem`.
    function _minReserveMet() internal view override returns (bool) {
        if (minimumTokensForSale() > 0 && totalSharesSold < minimumTokensForSale()) {
            return false;
        }
        return true;
    }

    /// -----------------------------------------------------------------------
    /// BUY LOGIC -- OVERRIDE REQUIRED -- Internal -- Read Functions
    /// -----------------------------------------------------------------------

    /// @notice Calculates the number of asset tokens that will be swapped into the pool before fees.
    /// @dev For overflow pools this is always the tokenAmount passed in, we're just conforming to the interface.
    function _calculateBaseAssetsIn(
        address recipient,
        uint256 tokenAmount,
        uint256 maxPricePerShare
    )
        internal
        view
        override
        returns (uint256, TiersModified[] memory)
    {
        if (!isTiered()) {
            return (tokenAmount.mulWadUp(assetsPerToken()), new TiersModified[](0));
        }

        return _calculateTieredPurchase(recipient, tokenAmount, maxPricePerShare);
    }

    /// @notice Normalizes the assets being swapped in to 18 decimals, if needed.
    /// @param amount The amount of assets being swapped in.
    function _normalizeAmount(uint256 amount) internal pure override returns (uint256) {
        return amount.normalize(shareDecimals());
    }

    /// @notice Checks if the pool has reached its asset token hard cap.
    /// @dev This value does not account for assets in the pool in the form of swap fees.
    function _raiseCapMet() internal view override returns (bool) {
        // Greater comparision for safety purpose only
        return totalSharesSold >= sharesForSale();
    }

    /// @notice Validates the amount of shares being swapped in do not exceed Overflow specific limits.
    /// @dev The amount of shares being swapped in must not exceed the shares for sale.
    /// @dev The amount of shares remaining for purchase before the pool cap is met after the swap must be greater than the mandatoryMinimumSwapIn to prevent the pool from being left with dust.
    /// @param amount The amount of shares being swapped in.
    function _validatePoolLimits(uint256 amount) internal view override {
        if (amount > sharesForSale()) {
            revert MaxPurchaseExeeded();
        }
        if (totalSharesSold.rawAdd(amount) > sharesForSale()) {
            revert MaxPurchaseExeeded();
        }
        if (
            mandatoryMinimumSwapIn() > 0 && sharesRemaining().rawSub(amount) > 0
                && sharesRemaining().rawSub(amount) < mandatoryMinimumSwapIn()
        ) {
            revert MandatoryMinimumSwapThreshold();
        }
    }

    /// @notice Validates the amount of shares being swapped in do not exceed FixedPrice specific user limits.
    /// @dev The amount of shares purchased in total(including this swap) by the user must not exceed the user's maximum purchase limit.
    /// @dev The amount of shares purchased in total(including this swap) must not be less than the user's minimum purchase limit.
    /// @param recipient The address of the user swapping in.
    /// @param tokenAmount The amount of shares being swapped in.
    function _validateUserLimits(address recipient, uint256 tokenAmount) internal view override {
        uint256 updatedUserAmount = purchasedShares[recipient].rawAdd(tokenAmount);
        if (updatedUserAmount > maximumTokensPerUser()) revert UserMaxPurchaseExceeded();
        if (updatedUserAmount < minimumTokensPerUser()) revert UserMinPurchaseNotMet();
    }

    /// -----------------------------------------------------------------------------------------------------------------------------------------
    /// BUY LOGIC -- OVERRIDE REQUIRED --  Internal -- Write Functions
    /// -----------------------------------------------------------------------------------------------------------------------------------------

    /// @notice Helper function to emit the BuyFixedShares event post purchase.
    /// @dev All values are denormalized before being emitted.
    function _emitBuyEvent(
        address recipient,
        uint256 assetsIn,
        uint256 feesPaid,
        uint256 sharesOut
    )
        internal
        override
    {
        emit BuyFixedShares(
            recipient,
            sharesOut.denormalizeDown(shareDecimals()),
            assetsIn.denormalizeUp(assetDecimals()),
            feesPaid.denormalizeUp(assetDecimals())
        );
    }

    /// @notice Updates the pool state after a successful asset swap in.
    /// @dev Updates the total shares sold, the user's purchased shares, the user's assets in,
    /// the total assets in, and the total fees in.
    function _updatePoolState(
        address recipient,
        uint256 assetsIn,
        uint256 sharesOut,
        uint256 fees,
        TiersModified[] memory tiersModified
    )
        internal
        override
        returns (uint256)
    {
        //Update Pool shares
        totalSharesSold = totalSharesSold.rawAdd(sharesOut);

        purchasedShares[recipient] = purchasedShares[recipient].rawAdd(sharesOut);

        //Update Pool assets
        userNormalizedAssetsIn[recipient] = userNormalizedAssetsIn[recipient].rawAdd(assetsIn);
        totalNormalizedAssetsIn = totalNormalizedAssetsIn.rawAdd(assetsIn);

        //Update Pool fees
        totalNormalizedAssetFeesIn = totalNormalizedAssetFeesIn.rawAdd(fees);

        if (isTiered()) {
            _updateTierData(recipient, tiersModified);
        }

        return (assetsIn.rawAdd(fees));
    }

    /// -----------------------------------------------------------------------------------------------------------------------------------------
    /// BUY LOGIC --  TIER SPECIFIC -- Internal -- Read Functions
    /// -----------------------------------------------------------------------------------------------------------------------------------------

    ///@notice Helper function to calculate the amount of assets the user will swap into the pool and the amount of shares they are able to receive.
    ///@param tier The tier the user is attempting to purchase in.
    ///@param tierIndex The index of the tier the user is attempting to purchase in.
    ///@param newTotalUserPurchased The total amount of shares the user will have purchased in the tier after this purchase.
    ///@param newTotalSold The total amount of shares sold in the tier after this purchase.
    ///@param sharesOut The amount of shares the user is attempting to purchase.
    ///@return assetsIn The total amount of assets the user will swap into the pool before swap fees are applied.
    ///@return sharesOutInTier The total amount of shares the user will purchase in the tier.
    ///@dev This function will revert if the user is attempting to purchase more shares than they are allowed across all tiers.
    function _calculatePurchaseAmounts(
        Tier memory tier,
        address recipient,
        uint8 tierIndex,
        uint256 newTotalUserPurchased,
        uint256 newTotalSold,
        uint256 sharesOut
    )
        internal
        view
        returns (uint256 assetsIn, uint256 sharesOutInTier)
    {
        (uint256 userMaxAssetsIn, uint256 userMaxSharesOutInTier) = (0, 0);
        (uint256 tierMaxAssetsIn, uint256 tierMaxSharesOutInTier) = (0, 0);
        if (newTotalUserPurchased > tier.maximumPerUser) {
            (userMaxAssetsIn, userMaxSharesOutInTier) =
                _handleExcessPurchase(tier, recipient, tierIndex);
        }
        if (newTotalSold > tier.amountForSale) {
            (tierMaxAssetsIn, tierMaxSharesOutInTier) = _handleTierOverflow(tier, tierIndex);
        }

        if (userMaxAssetsIn == 0 && tierMaxAssetsIn == 0) {
            assetsIn = sharesOut.mulWadUp(tier.pricePerShare);
            sharesOutInTier = sharesOut;
        }
        // If only the tier limit was exceeded
        else if (userMaxAssetsIn == 0) {
            (assetsIn, sharesOutInTier) = (tierMaxAssetsIn, tierMaxSharesOutInTier);
        }
        // If only the user limit was exceeded
        else if (tierMaxAssetsIn == 0) {
            (assetsIn, sharesOutInTier) = (userMaxAssetsIn, userMaxSharesOutInTier);
        }
        // If both limits were exceeded, take the minimum
        else {
            if (tierMaxAssetsIn < userMaxAssetsIn) {
                (assetsIn, sharesOutInTier) = (tierMaxAssetsIn, tierMaxSharesOutInTier);
            } else {
                (assetsIn, sharesOutInTier) = (userMaxAssetsIn, userMaxSharesOutInTier);
            }
        }
    }

    ///@notice Helper function to handle the case where a user is attempting to purchase more shares than they are allowed for that tier.
    ///@param tier The tier the user is attempting to purchase in.
    ///@param recipient The address of the user attempting to purchase.
    ///@param tierIndex The index of the tier the user is attempting to purchase in.
    ///@dev This function will revert if there is no next tier as that would indicate they are unable to fulfill the current order.
    function _handleExcessPurchase(
        Tier memory tier,
        address recipient,
        uint8 tierIndex
    )
        internal
        view
        returns (uint256 assetsIn, uint256 sharesOutInTier)
    {
        _validateNextTierExists(tierIndex);

        sharesOutInTier = tier.maximumPerUser.rawSub(purchasedByTier[tierIndex][recipient]);
        assetsIn = sharesOutInTier.mulWadUp(tier.pricePerShare);
    }

    ///@notice Helper function to handle the case where a user is attempting to purchase more shares than are available in the current tier.
    ///@param tier The tier the user is attempting to purchase in.
    ///@param tierIndex The index of the tier the user is attempting to purchase in.
    ///@dev This function will revert if there is no next tier as that would indicate they are unable to fulfill the current order.
    function _handleTierOverflow(
        Tier memory tier,
        uint8 tierIndex
    )
        internal
        view
        returns (uint256 assetsIn, uint256 sharesOutInTier)
    {
        _validateNextTierExists(tierIndex);

        sharesOutInTier = tier.amountForSale.rawSub(amountSoldInTier[tierIndex]);

        assetsIn = sharesOutInTier.mulWadUp(tier.pricePerShare);
    }

    ///@notice Helper function to check that the requested swap amount meets the minimum purchase requirements for the tier.
    // function _validateMinimumPurchase(
    //     uint256 tierIndex,
    //     uint256 minimumPerUser,
    //     uint256 tokenAmount
    // )
    //     internal
    //     pure
    // {
    //     if (tokenAmount < minimumPerUser) {
    //         revert TierPurchaseTooLow(tierIndex);
    //     }
    // }

    ///@notice Helper function to validate that the next tier exists before attempting to purchase in it and accessing OOB data.
    ///@param tierIndex The index of the tier the user is attempting to purchase in.
    ///@dev This function will revert if there is no next tier as that would indicate they are unable to fulfill the current order.
    function _validateNextTierExists(uint8 tierIndex) internal pure {
        if (tierIndex + 1 > getTierLength() - 1) {
            revert TierMaxPurchaseExceeded();
        }
    }

    /// -----------------------------------------------------------------------------------------------------------------------------------------
    /// BUY LOGIC --  TIER SPECIFIC -- Internal -- Write Functions
    /// -----------------------------------------------------------------------------------------------------------------------------------------

    ///@notice Helper function to check if the current tier has reached its maximum shares sold and rollover to the next tier if needed.
    ///@param currentTierSharesOut The total amount of shares sold in the current tier.
    ///@param maximumInTier The maximum amount of shares that can be sold in the current tier.
    ///@dev emits a `TierRollover` event if the current tier has reached its maximum shares sold.
    function _handleTierRollover(uint256 currentTierSharesOut, uint256 maximumInTier) internal {
        if (currentTierSharesOut >= maximumInTier) {
            currentTier++;
            emit TierRollover(currentTier);
        }
    }

    ///@notice Helper function to perform an iteration across the current tier and all subsequent tiers to validate the user's
    ///requested purchase amount is within the bounds of the Tiers combined min/max purchase limits.
    ///@param recipient The address of the user purchasing shares.
    ///@param shareAmount The amount of shares the user is attempting to purchase.
    ///@return assetsIn The total amount of assets the user will swap into the pool before swap fees are applied.
    ///@dev This function will revert if the user is attempting to purchase more shares than they are allowed across all tiers. It will additionally
    ///rollover the tier to the next one if the current tier reaches its maximum shares sold within this transaction.
    function _calculateTieredPurchase(
        address recipient,
        uint256 shareAmount,
        uint256 maxPricePerShare
    )
        internal
        view
        returns (uint256 assetsIn, TiersModified[] memory tiersModified)
    {
        uint256 tempSharesOut;

        uint8 lengthOfTiers = getTierLength();
        uint8 iter;

        tiersModified = new TiersModified[](lengthOfTiers);

        for (uint8 i = currentTier; i < lengthOfTiers; i++) {
            if (maxPricePerShare != 0 && getTierData(i).pricePerShare > maxPricePerShare) {
                revert SlippageExceeded();
            }
            //Ensure there is a next tier available and the user is not attempting to purchase more/less shares than they are allowed.
            (uint256 assetsInInTier, uint256 sharesOutInTier) =
                _validateAndReturnTierLimits(i, recipient, shareAmount.rawSub(tempSharesOut));

            tiersModified[iter] = TiersModified({
                tierIndex: i,
                assetsIn: assetsInInTier,
                sharesOutInTier: sharesOutInTier
            });

            tempSharesOut = tempSharesOut.rawAdd(sharesOutInTier);
            assetsIn = assetsIn.rawAdd(assetsInInTier);

            if (tempSharesOut > shareAmount) {
                revert TierMaxPurchaseExceeded();
            }

            //If the user has purchased the requested amount of shares, exit the loop.
            if (tempSharesOut == shareAmount) {
                break;
            }

            unchecked {
                iter++;
            }
        }

        if (tempSharesOut != shareAmount) {
            revert InvalidTierPurchaseAmount();
        }
    }

    ///@notice Helper function to update state data for the tier at index after this iteration of purchases is complete.
    function _updateTierData(address recipient, TiersModified[] memory tiersModified) internal {
        uint8 length = tiersModified.length.toUint8();
        for (uint8 i; i < length; i++) {
            if (tiersModified[i].assetsIn == 0) {
                continue;
            }

            uint8 tierIndex = tiersModified[i].tierIndex;

            uint256 sharesOutInTier = tiersModified[i].sharesOutInTier;

            purchasedByTier[tierIndex][recipient] += sharesOutInTier;
            amountSoldInTier[tierIndex] += sharesOutInTier;
            _handleTierRollover(amountSoldInTier[tierIndex], getTierData(tierIndex).amountForSale);
        }
    }

    ///@notice Helper function to update state data for the tier at index after this iteration of purchases is complete, and return both the assets in and shares out for the user.
    ///@param tierIndex The index of the tier to update.
    ///@param recipient The address of the user purchasing shares.
    ///@param sharesOutInTier The amount of shares the user is purchasing in the tier.
    ///@dev This function will revert if the user is attempting to purchase more shares than they are allowed across all tiers.
    function _validateAndReturnTierLimits(
        uint8 tierIndex,
        address recipient,
        uint256 tokenAmount
    )
        internal
        view
        returns (uint256 assetsIn, uint256 sharesOutInTier)
    {
        Tier memory tier = getTierData(tierIndex);

        // if one tier fail this condition when rollover the whole transaction will be reverted
        if (tokenAmount < tier.minimumPerUser) {
            revert TierPurchaseTooLow(tierIndex);
        }

        // _validateMinimumPurchase(tierIndex, tier.minimumPerUser, tokenAmount);

        (assetsIn, sharesOutInTier) = _calculatePurchaseAmounts(
            tier,
            recipient,
            tierIndex,
            purchasedByTier[tierIndex][recipient].rawAdd(tokenAmount),
            amountSoldInTier[tierIndex].rawAdd(tokenAmount),
            tokenAmount
        );
    }

    /// -----------------------------------------------------------------------
    /// BUY LOGIC -- PUBLIC -- Write Functions
    /// -----------------------------------------------------------------------

    ///@notice Allows a user to purchase shares in the pool by swapping in assets.
    ///@param sharesOut The amount of shares to swap out the pool.
    ///@param recipient The address that will receive the shares.
    ///@param deadline The deadline for the swap to be executed.
    ///@param signature The signature of the user authorizing the swap.
    ///@param proof The Merkle proof for the user's whitelist status.
    ///@dev If the pool has reached its asset token hard cap, the pool will emit a `PoolCompleted` event.
    /// @dev The sharesOut value should not be normalized to 18 decimals when supplied.
    function buyExactShares(
        uint256 sharesOut,
        address recipient,
        uint64 deadline,
        bytes memory signature,
        bytes32[] memory proof
    )
        public
        whenSaleActive
    {
        buy(sharesOut, recipient, deadline, signature, proof, 0);
    }

    ///@notice Allows a user to purchase shares in the pool by swapping in assets.
    ///@param sharesOut The amount of shares to swap out the pool.
    ///@param recipient The address that will receive the shares.
    ///@param deadline The deadline for the swap to be executed.
    ///@param signature The signature of the user authorizing the swap.
    ///@param proof The Merkle proof for the user's whitelist status.
    ///@param maxPricePerShare The maximum price per share the user is willing to pay.
    ///@dev If the pool has reached its asset token hard cap, the pool will emit a `PoolCompleted` event.
    /// @dev The sharesOut value should not be normalized to 18 decimals when supplied.
    function buyExactShares(
        uint256 sharesOut,
        address recipient,
        uint64 deadline,
        bytes memory signature,
        bytes32[] memory proof,
        uint256 maxPricePerShare
    )
        public
        whenSaleActive
    {
        buy(sharesOut, recipient, deadline, signature, proof, maxPricePerShare);
    }

    /// -----------------------------------------------------------------------------------------------------------------------------------------
    /// CLOSE LOGIC -- Overriden --  Internal -- Read Functionss
    /// -----------------------------------------------------------------------------------------------------------------------------------------

    /// @notice Calculates and denormalizes the number of unsold shares that will be refunded to the owner.
    /// @dev For FixedPricePools this is the difference between the total shares sold and the shares available for purchase.
    function _calculateLeftoverShares() internal view override returns (uint256 sharesNotSold) {
        sharesNotSold = (sharesForSale().rawSub(totalSharesSold)).denormalizeDown(shareDecimals());
    }

    /// -----------------------------------------------------------------------------------------------------------------------------------------
    /// CLOSE LOGIC -- Overriden --  Internal -- Write Functions
    /// -----------------------------------------------------------------------------------------------------------------------------------------

    /// @notice Helper function to handle refunding in the case of a minReserve not being met.
    /// @dev Refunds all shares to the owner(), and distro's asset swap fees to the platform.
    function _handleManagerRefund()
        internal
        override
        returns (uint256 sharesNotSold, uint256 fundsRaised, uint256 swapFeesGenerated)
    {
        (sharesNotSold, fundsRaised, swapFeesGenerated) = super._handleManagerRefund();
        sharesNotSold = sharesNotSold.rawSub(totalSharesSold.denormalizeDown(shareDecimals()));
        if (shareToken() != address(0)) {
            uint256 sharesTotal = IERC20(shareToken()).balanceOf(address(this));
            if (sharesTotal > 0) {
                shareToken().safeTransfer(owner(), sharesTotal);
            }
        }
    }

    /// -----------------------------------------------------------------------------------------------------------------------------------------
    /// REDEEM LOGIC -- Overriden --  Internal -- READ Functions
    /// -----------------------------------------------------------------------------------------------------------------------------------------

    /// @notice Calculates and denormalizes the number of shares owed to the user based on the number of shares they have purchased.
    function _calculateSharesOwed(address sender)
        internal
        view
        override
        returns (uint256 sharesOut)
    {
        sharesOut = purchasedShares[sender].denormalizeDown(shareDecimals());
    }

    /// -----------------------------------------------------------------------------------------------------------------------------------------
    /// REDEEM LOGIC -- Overriden --  Internal -- Write Functions
    /// -----------------------------------------------------------------------------------------------------------------------------------------

    /// @notice Sets the users assets in and purchased shares balances to 0 after a successful redemption.
    function _handleUpdateUserRedemption(address sender) internal override {
        purchasedShares[sender] = 0;
        userNormalizedAssetsIn[sender] = 0;
    }

    /// @notice Helper function to handle refunding in the case of a minReserve not being met.
    /// @dev Refunds all assets to the purchaser sans swap fees.
    function _handleUserRefund(address sender) internal override returns (uint256 assetsOwed) {
        assetsOwed = userNormalizedAssetsIn[sender].denormalizeDown(assetDecimals());
        purchasedShares[sender] = 0;
        userNormalizedAssetsIn[sender] = 0;

        if (assetsOwed > 0) {
            assetToken().safeTransfer(sender, assetsOwed);
        }
    }

    /// -----------------------------------------------------------------------------------------------------------------------------------------
    ///  EIP712 Helper Functions
    /// -----------------------------------------------------------------------------------------------------------------------------------------

    /// @notice Overrides the default domain name and version for EIP-712 signatures.
    function _domainNameAndVersion()
        internal
        pure
        override
        returns (string memory name, string memory version)
    {
        name = "FixedPricePool";
        version = "1.0.0";
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity =0.8.25;

abstract contract FjordConstants {
    //-----------------------------------------------------------------------------------------------------------------------------------------
    // BASE POOL OFFSETS ONLY
    //-----------------------------------------------------------------------------------------------------------------------------------------

    uint256 internal constant OWNER_OFFSET = 0; // Increment offset by 20
    uint256 internal constant SHARE_TOKEN_OFFSET = 20; // Increment offset by 20
    uint256 internal constant ASSET_TOKEN_OFFSET = 40; // Increment offset by 20
    uint256 internal constant FEE_RECIPIENT_OFFSET = 60; // Increment offset by 20
    uint256 internal constant DELEGATE_SIGNER_OFFSET = 80; // Increment offset by 20
    uint256 internal constant SHARES_FOR_SALE_OFFSET = 100; // Increment offset by 32
    uint256 internal constant MINIMUM_TOKENS_FOR_SALE_OFFSET = 132; // Increment offset by 32
    uint256 internal constant MAXIMUM_TOKENS_PER_USER_OFFSET = 164; // Increment offset by 32
    uint256 internal constant MINIMUM_TOKENS_PER_USER_OFFSET = 196; // Increment offset by 32
    uint256 internal constant SWAP_FEE_WAD_OFFSET = 228; // Increment offset by 8
    uint256 internal constant PLATFORM_FEE_WAD_OFFSET = 236; // Increment offset by 8
    uint256 internal constant SALE_START_OFFSET = 244; // Increment offset by 5
    uint256 internal constant SALE_END_OFFSET = 249; // Increment offset by 5
    uint256 internal constant REDEMPTION_DELAY_OFFSET = 254; // Increment offset by 5
    uint256 internal constant VEST_END_OFFSET = 259; // Increment offset by 5
    uint256 internal constant VEST_CLIFF_OFFSET = 264; // Increment offset by 5
    uint256 internal constant SHARE_TOKEN_DECIMALS_OFFSET = 269; // Increment offset by 1
    uint256 internal constant ASSET_TOKEN_DECIMALS_OFFSET = 270; // Increment offset by 1
    uint256 internal constant ANTISNIPE_ENABLED_OFFSET = 271; // Increment offset by 1
    uint256 internal constant WHITELIST_MERKLE_ROOT_OFFSET = 272; // Increment offset by 32

    //-----------------------------------------------------------------------------------------------------------------------------------------
    // FIXED PRICE OFFSETS ONLY
    //-----------------------------------------------------------------------------------------------------------------------------------------

    uint256 internal constant ASSETS_PER_TOKEN_OFFSET = 304; // Increment offset by 32
    uint256 internal constant TIER_DATA_LENGTH_OFFSET = 336; // Increment offset by 32
    uint256 internal constant TIERS_OFFSET = 368; // Increment offset by 32

    uint256 internal constant EMPTY_TIER_ARRAY_OFFSET = 64; // Size of an empty encoded Tier[] struct
    uint256 internal constant TIER_BASE_OFFSET = 128; // Size of an encoded Tier struct (uint256,uint256,uint256,uint256)

    //-----------------------------------------------------------------------------------------------------------------------------------------
    //OVERFLOW OFFSETS ONLY
    //-----------------------------------------------------------------------------------------------------------------------------------------

    uint256 internal constant ASSET_HARD_CAP_OFFSET = 304; // Increment offset by 32
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity =0.8.25;

import { FixedPointMathLib } from "solady/utils/FixedPointMathLib.sol";

library FjordMath {
    using FixedPointMathLib for uint256;

    /// @notice The scaling factor for all normalization/denormalization operations
    uint256 private constant SCALING_FACTOR = 18;

    /// @notice Normalize a value to the scaling factor
    /// @param value The value to normalize
    /// @param decimals The number of decimals of the value
    /// @dev No greater than check is required as > 18 decimals are not supported
    function normalize(uint256 value, uint8 decimals) internal pure returns (uint256) {
        if (decimals < SCALING_FACTOR) {
            return value * (10 ** (SCALING_FACTOR - decimals));
        }
        return value;
    }

    /// @notice Denormalizes a value back to its original value
    /// @param value The value to denormalize
    /// @param decimals The number of decimals of the value
    /// @dev No greater than check is required as > 18 decimals are not supported. This function rounds up post division.
    function denormalizeUp(uint256 value, uint8 decimals) internal pure returns (uint256) {
        if (decimals < SCALING_FACTOR) {
            return value.divUp(10 ** (SCALING_FACTOR - decimals));
        }
        return value;
    }

    /// @notice Denormalizes a value back to its original value
    /// @param value The value to denormalize
    /// @param decimals The number of decimals of the value
    /// @dev No greater than check is required as > 18 decimals are not supported. This function rounds down post division.
    function denormalizeDown(uint256 value, uint8 decimals) internal pure returns (uint256) {
        if (decimals < SCALING_FACTOR) {
            return value / (10 ** (SCALING_FACTOR - decimals));
        }
        return value;
    }

    ///@notice Returns the minimum swap threshold required for a purchase to be valid.
    ///@dev This is used to prevent rounding errors when making swaps between tokens of varying decimals.
    function mandatoryMinimumSwapIn(
        uint8 shareDecimals,
        uint8 assetDecimals
    )
        public
        pure
        returns (uint256)
    {
        if (shareDecimals > assetDecimals) {
            return 10 ** (shareDecimals - assetDecimals + 2);
        } else {
            return 0;
        }
    }
}