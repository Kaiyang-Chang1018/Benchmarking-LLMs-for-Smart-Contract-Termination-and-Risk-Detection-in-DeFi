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
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC721/IERC721.sol)

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
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

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
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

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
     * - The `operator` cannot be the caller.
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
// OpenZeppelin Contracts (last updated v4.9.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```solidity
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableSet.
 * ====
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
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
import { UD2x18 } from "../ud2x18/ValueType.sol";
import { UD60x18 } from "../ud60x18/ValueType.sol";
import { SD1x18 } from "./ValueType.sol";

/// @notice Casts an SD1x18 number into SD59x18.
/// @dev There is no overflow check because the domain of SD1x18 is a subset of SD59x18.
function intoSD59x18(SD1x18 x) pure returns (SD59x18 result) {
    result = SD59x18.wrap(int256(SD1x18.unwrap(x)));
}

/// @notice Casts an SD1x18 number into UD2x18.
/// - x must be positive.
function intoUD2x18(SD1x18 x) pure returns (UD2x18 result) {
    int64 xInt = SD1x18.unwrap(x);
    if (xInt < 0) {
        revert CastingErrors.PRBMath_SD1x18_ToUD2x18_Underflow(x);
    }
    result = UD2x18.wrap(uint64(xInt));
}

/// @notice Casts an SD1x18 number into UD60x18.
/// @dev Requirements:
/// - x must be positive.
function intoUD60x18(SD1x18 x) pure returns (UD60x18 result) {
    int64 xInt = SD1x18.unwrap(x);
    if (xInt < 0) {
        revert CastingErrors.PRBMath_SD1x18_ToUD60x18_Underflow(x);
    }
    result = UD60x18.wrap(uint64(xInt));
}

/// @notice Casts an SD1x18 number into uint256.
/// @dev Requirements:
/// - x must be positive.
function intoUint256(SD1x18 x) pure returns (uint256 result) {
    int64 xInt = SD1x18.unwrap(x);
    if (xInt < 0) {
        revert CastingErrors.PRBMath_SD1x18_ToUint256_Underflow(x);
    }
    result = uint256(uint64(xInt));
}

/// @notice Casts an SD1x18 number into uint128.
/// @dev Requirements:
/// - x must be positive.
function intoUint128(SD1x18 x) pure returns (uint128 result) {
    int64 xInt = SD1x18.unwrap(x);
    if (xInt < 0) {
        revert CastingErrors.PRBMath_SD1x18_ToUint128_Underflow(x);
    }
    result = uint128(uint64(xInt));
}

/// @notice Casts an SD1x18 number into uint40.
/// @dev Requirements:
/// - x must be positive.
/// - x must be less than or equal to `MAX_UINT40`.
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

/// @dev The maximum value an SD1x18 number can have.
int64 constant uMIN_SD1x18 = -9_223372036854775808;
SD1x18 constant MIN_SD1x18 = SD1x18.wrap(uMIN_SD1x18);

/// @dev PI as an SD1x18 number.
SD1x18 constant PI = SD1x18.wrap(3_141592653589793238);

/// @dev The unit number, which gives the decimal precision of SD1x18.
SD1x18 constant UNIT = SD1x18.wrap(1e18);
int256 constant uUNIT = 1e18;
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { SD1x18 } from "./ValueType.sol";

/// @notice Thrown when trying to cast a SD1x18 number that doesn't fit in UD2x18.
error PRBMath_SD1x18_ToUD2x18_Underflow(SD1x18 x);

/// @notice Thrown when trying to cast a SD1x18 number that doesn't fit in UD60x18.
error PRBMath_SD1x18_ToUD60x18_Underflow(SD1x18 x);

/// @notice Thrown when trying to cast a SD1x18 number that doesn't fit in uint128.
error PRBMath_SD1x18_ToUint128_Underflow(SD1x18 x);

/// @notice Thrown when trying to cast a SD1x18 number that doesn't fit in uint256.
error PRBMath_SD1x18_ToUint256_Underflow(SD1x18 x);

/// @notice Thrown when trying to cast a SD1x18 number that doesn't fit in uint40.
error PRBMath_SD1x18_ToUint40_Overflow(SD1x18 x);

/// @notice Thrown when trying to cast a SD1x18 number that doesn't fit in uint40.
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
    Casting.intoUD2x18,
    Casting.intoUD60x18,
    Casting.intoUint256,
    Casting.intoUint128,
    Casting.intoUint40,
    Casting.unwrap
} for SD1x18 global;
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "./Errors.sol" as CastingErrors;
import { MAX_UINT128, MAX_UINT40 } from "../Common.sol";
import { uMAX_SD1x18, uMIN_SD1x18 } from "../sd1x18/Constants.sol";
import { SD1x18 } from "../sd1x18/ValueType.sol";
import { uMAX_UD2x18 } from "../ud2x18/Constants.sol";
import { UD2x18 } from "../ud2x18/ValueType.sol";
import { UD60x18 } from "../ud60x18/ValueType.sol";
import { SD59x18 } from "./ValueType.sol";

/// @notice Casts an SD59x18 number into int256.
/// @dev This is basically a functional alias for {unwrap}.
function intoInt256(SD59x18 x) pure returns (int256 result) {
    result = SD59x18.unwrap(x);
}

/// @notice Casts an SD59x18 number into SD1x18.
/// @dev Requirements:
/// - x must be greater than or equal to `uMIN_SD1x18`.
/// - x must be less than or equal to `uMAX_SD1x18`.
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

/// @notice Casts an SD59x18 number into UD2x18.
/// @dev Requirements:
/// - x must be positive.
/// - x must be less than or equal to `uMAX_UD2x18`.
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

/// @notice Casts an SD59x18 number into UD60x18.
/// @dev Requirements:
/// - x must be positive.
function intoUD60x18(SD59x18 x) pure returns (UD60x18 result) {
    int256 xInt = SD59x18.unwrap(x);
    if (xInt < 0) {
        revert CastingErrors.PRBMath_SD59x18_IntoUD60x18_Underflow(x);
    }
    result = UD60x18.wrap(uint256(xInt));
}

/// @notice Casts an SD59x18 number into uint256.
/// @dev Requirements:
/// - x must be positive.
function intoUint256(SD59x18 x) pure returns (uint256 result) {
    int256 xInt = SD59x18.unwrap(x);
    if (xInt < 0) {
        revert CastingErrors.PRBMath_SD59x18_IntoUint256_Underflow(x);
    }
    result = uint256(xInt);
}

/// @notice Casts an SD59x18 number into uint128.
/// @dev Requirements:
/// - x must be positive.
/// - x must be less than or equal to `uMAX_UINT128`.
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
/// - x must be positive.
/// - x must be less than or equal to `MAX_UINT40`.
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

/// @dev The maximum input permitted in {exp2}.
int256 constant uEXP2_MAX_INPUT = 192e18 - 1;
SD59x18 constant EXP2_MAX_INPUT = SD59x18.wrap(uEXP2_MAX_INPUT);

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

/// @notice Thrown when trying to cast a UD60x18 number that doesn't fit in SD1x18.
error PRBMath_SD59x18_IntoSD1x18_Overflow(SD59x18 x);

/// @notice Thrown when trying to cast a UD60x18 number that doesn't fit in SD1x18.
error PRBMath_SD59x18_IntoSD1x18_Underflow(SD59x18 x);

/// @notice Thrown when trying to cast a UD60x18 number that doesn't fit in UD2x18.
error PRBMath_SD59x18_IntoUD2x18_Overflow(SD59x18 x);

/// @notice Thrown when trying to cast a UD60x18 number that doesn't fit in UD2x18.
error PRBMath_SD59x18_IntoUD2x18_Underflow(SD59x18 x);

/// @notice Thrown when trying to cast a UD60x18 number that doesn't fit in UD60x18.
error PRBMath_SD59x18_IntoUD60x18_Underflow(SD59x18 x);

/// @notice Thrown when trying to cast a UD60x18 number that doesn't fit in uint128.
error PRBMath_SD59x18_IntoUint128_Overflow(SD59x18 x);

/// @notice Thrown when trying to cast a UD60x18 number that doesn't fit in uint128.
error PRBMath_SD59x18_IntoUint128_Underflow(SD59x18 x);

/// @notice Thrown when trying to cast a UD60x18 number that doesn't fit in uint256.
error PRBMath_SD59x18_IntoUint256_Underflow(SD59x18 x);

/// @notice Thrown when trying to cast a UD60x18 number that doesn't fit in uint40.
error PRBMath_SD59x18_IntoUint40_Overflow(SD59x18 x);

/// @notice Thrown when trying to cast a UD60x18 number that doesn't fit in uint40.
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
/// - x must be greater than `MIN_SD59x18`.
///
/// @param x The SD59x18 number for which to calculate the absolute value.
/// @param result The absolute value of x as an SD59x18 number.
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
/// - x must be less than or equal to `MAX_WHOLE_SD59x18`.
///
/// @param x The SD59x18 number to ceil.
/// @param result The smallest whole number greater than or equal to x, as an SD59x18 number.
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
/// @param result The quotient as an SD59x18 number.
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
/// - x must be less than 133_084258667509499441.
///
/// @param x The exponent as an SD59x18 number.
/// @return result The result as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function exp(SD59x18 x) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap();

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
/// - If x is less than -59_794705707972522261, the result is zero.
///
/// Requirements:
/// - x must be less than 192e18.
/// - The result must fit in SD59x18.
///
/// @param x The exponent as an SD59x18 number.
/// @return result The result as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function exp2(SD59x18 x) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap();
    if (xInt < 0) {
        // The inverse of any number less than this is truncated to zero.
        if (xInt < -59_794705707972522261) {
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
/// - x must be greater than or equal to `MIN_WHOLE_SD59x18`.
///
/// @param x The SD59x18 number to floor.
/// @param result The greatest whole number less than or equal to x, as an SD59x18 number.
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
/// @param result The fractional part of x as an SD59x18 number.
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
/// - x must be greater than zero.
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
/// - x cannot be negative, since complex numbers are not supported.
/// - x must be less than `MAX_SD59x18 / UNIT`.
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
    Casting.intoUD2x18,
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
import { uMAX_SD1x18 } from "../sd1x18/Constants.sol";
import { SD1x18 } from "../sd1x18/ValueType.sol";
import { SD59x18 } from "../sd59x18/ValueType.sol";
import { UD60x18 } from "../ud60x18/ValueType.sol";
import { UD2x18 } from "./ValueType.sol";

/// @notice Casts a UD2x18 number into SD1x18.
/// - x must be less than or equal to `uMAX_SD1x18`.
function intoSD1x18(UD2x18 x) pure returns (SD1x18 result) {
    uint64 xUint = UD2x18.unwrap(x);
    if (xUint > uint64(uMAX_SD1x18)) {
        revert Errors.PRBMath_UD2x18_IntoSD1x18_Overflow(x);
    }
    result = SD1x18.wrap(int64(xUint));
}

/// @notice Casts a UD2x18 number into SD59x18.
/// @dev There is no overflow check because the domain of UD2x18 is a subset of SD59x18.
function intoSD59x18(UD2x18 x) pure returns (SD59x18 result) {
    result = SD59x18.wrap(int256(uint256(UD2x18.unwrap(x))));
}

/// @notice Casts a UD2x18 number into UD60x18.
/// @dev There is no overflow check because the domain of UD2x18 is a subset of UD60x18.
function intoUD60x18(UD2x18 x) pure returns (UD60x18 result) {
    result = UD60x18.wrap(UD2x18.unwrap(x));
}

/// @notice Casts a UD2x18 number into uint128.
/// @dev There is no overflow check because the domain of UD2x18 is a subset of uint128.
function intoUint128(UD2x18 x) pure returns (uint128 result) {
    result = uint128(UD2x18.unwrap(x));
}

/// @notice Casts a UD2x18 number into uint256.
/// @dev There is no overflow check because the domain of UD2x18 is a subset of uint256.
function intoUint256(UD2x18 x) pure returns (uint256 result) {
    result = uint256(UD2x18.unwrap(x));
}

/// @notice Casts a UD2x18 number into uint40.
/// @dev Requirements:
/// - x must be less than or equal to `MAX_UINT40`.
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
uint256 constant uUNIT = 1e18;
UD2x18 constant UNIT = UD2x18.wrap(1e18);
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { UD2x18 } from "./ValueType.sol";

/// @notice Thrown when trying to cast a UD2x18 number that doesn't fit in SD1x18.
error PRBMath_UD2x18_IntoSD1x18_Overflow(UD2x18 x);

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
    Casting.intoSD1x18,
    Casting.intoSD59x18,
    Casting.intoUD60x18,
    Casting.intoUint256,
    Casting.intoUint128,
    Casting.intoUint40,
    Casting.unwrap
} for UD2x18 global;
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "./Errors.sol" as CastingErrors;
import { MAX_UINT128, MAX_UINT40 } from "../Common.sol";
import { uMAX_SD1x18 } from "../sd1x18/Constants.sol";
import { SD1x18 } from "../sd1x18/ValueType.sol";
import { uMAX_SD59x18 } from "../sd59x18/Constants.sol";
import { SD59x18 } from "../sd59x18/ValueType.sol";
import { uMAX_UD2x18 } from "../ud2x18/Constants.sol";
import { UD2x18 } from "../ud2x18/ValueType.sol";
import { UD60x18 } from "./ValueType.sol";

/// @notice Casts a UD60x18 number into SD1x18.
/// @dev Requirements:
/// - x must be less than or equal to `uMAX_SD1x18`.
function intoSD1x18(UD60x18 x) pure returns (SD1x18 result) {
    uint256 xUint = UD60x18.unwrap(x);
    if (xUint > uint256(int256(uMAX_SD1x18))) {
        revert CastingErrors.PRBMath_UD60x18_IntoSD1x18_Overflow(x);
    }
    result = SD1x18.wrap(int64(uint64(xUint)));
}

/// @notice Casts a UD60x18 number into UD2x18.
/// @dev Requirements:
/// - x must be less than or equal to `uMAX_UD2x18`.
function intoUD2x18(UD60x18 x) pure returns (UD2x18 result) {
    uint256 xUint = UD60x18.unwrap(x);
    if (xUint > uMAX_UD2x18) {
        revert CastingErrors.PRBMath_UD60x18_IntoUD2x18_Overflow(x);
    }
    result = UD2x18.wrap(uint64(xUint));
}

/// @notice Casts a UD60x18 number into SD59x18.
/// @dev Requirements:
/// - x must be less than or equal to `uMAX_SD59x18`.
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
/// - x must be less than or equal to `MAX_UINT128`.
function intoUint128(UD60x18 x) pure returns (uint128 result) {
    uint256 xUint = UD60x18.unwrap(x);
    if (xUint > MAX_UINT128) {
        revert CastingErrors.PRBMath_UD60x18_IntoUint128_Overflow(x);
    }
    result = uint128(xUint);
}

/// @notice Casts a UD60x18 number into uint40.
/// @dev Requirements:
/// - x must be less than or equal to `MAX_UINT40`.
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
/// - x must be less than or equal to `MAX_UD60x18 / UNIT`.
///
/// @param x The basic integer to convert.
/// @param result The same number converted to UD60x18.
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

/// @notice Thrown when trying to cast a UD60x18 number that doesn't fit in SD59x18.
error PRBMath_UD60x18_IntoSD59x18_Overflow(UD60x18 x);

/// @notice Thrown when trying to cast a UD60x18 number that doesn't fit in UD2x18.
error PRBMath_UD60x18_IntoUD2x18_Overflow(UD60x18 x);

/// @notice Thrown when trying to cast a UD60x18 number that doesn't fit in uint128.
error PRBMath_UD60x18_IntoUint128_Overflow(UD60x18 x);

/// @notice Thrown when trying to cast a UD60x18 number that doesn't fit in uint40.
error PRBMath_UD60x18_IntoUint40_Overflow(UD60x18 x);

/// @notice Thrown when taking the logarithm of a number less than 1.
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
/// - x must be less than or equal to `MAX_WHOLE_UD60x18`.
///
/// @param x The UD60x18 number to ceil.
/// @param result The smallest whole number greater than or equal to x, as a UD60x18 number.
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
/// @param result The quotient as a UD60x18 number.
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
/// - x must be less than 133_084258667509499441.
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
/// - x must be less than 192e18.
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
/// @param result The greatest whole number less than or equal to x, as a UD60x18 number.
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
/// @param result The fractional part of x as a UD60x18 number.
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
/// - x must be greater than zero.
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

    // If x is greater than `UNIT`, use the standard formula.
    if (xUint > uUNIT) {
        result = exp2(mul(log2(x), y));
    }
    // Conversely, if x is less than `UNIT`, use the equivalent formula.
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
/// - x must be less than `MAX_UD60x18 / UNIT`.
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
    Casting.intoUD2x18,
    Casting.intoSD59x18,
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
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Modern and gas efficient ERC20 + EIP-2612 implementation.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC20.sol)
/// @author Modified from Uniswap (https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/UniswapV2ERC20.sol)
/// @dev Do not manually set balances without updating totalSupply, as the sum of all user balances must not exceed it.
abstract contract ERC20 {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    /*//////////////////////////////////////////////////////////////
                            METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

    string public name;

    string public symbol;

    uint8 public immutable decimals;

    /*//////////////////////////////////////////////////////////////
                              ERC20 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    /*//////////////////////////////////////////////////////////////
                            EIP-2612 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 internal immutable INITIAL_CHAIN_ID;

    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;

    mapping(address => uint256) public nonces;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        INITIAL_CHAIN_ID = block.chainid;
        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();
    }

    /*//////////////////////////////////////////////////////////////
                               ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        balanceOf[msg.sender] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(msg.sender, to, amount);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;

        balanceOf[from] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);

        return true;
    }

    /*//////////////////////////////////////////////////////////////
                             EIP-2612 LOGIC
    //////////////////////////////////////////////////////////////*/

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

        // Unchecked because the only math done is incrementing
        // the owner's nonce which cannot realistically overflow.
        unchecked {
            address recoveredAddress = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19\x01",
                        DOMAIN_SEPARATOR(),
                        keccak256(
                            abi.encode(
                                keccak256(
                                    "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                                ),
                                owner,
                                spender,
                                value,
                                nonces[owner]++,
                                deadline
                            )
                        )
                    )
                ),
                v,
                r,
                s
            );

            require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_SIGNER");

            allowance[recoveredAddress][spender] = value;
        }

        emit Approval(owner, spender, value);
    }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();
    }

    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                    keccak256(bytes(name)),
                    keccak256("1"),
                    block.chainid,
                    address(this)
                )
            );
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        balanceOf[from] -= amount;

        // Cannot underflow because a user's balance
        // will never be larger than the total supply.
        unchecked {
            totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ERC20} from "../tokens/ERC20.sol";

/// @notice Safe ETH and ERC20 transfer library that gracefully handles missing return values.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/SafeTransferLib.sol)
/// @dev Use with caution! Some functions in this library knowingly create dirty bits at the destination of the free memory pointer.
/// @dev Note that none of the functions in this library check that a token has code at all! That responsibility is delegated to the caller.
library SafeTransferLib {
    /*//////////////////////////////////////////////////////////////
                             ETH OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferETH(address to, uint256 amount) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Transfer the ETH and store if it succeeded or not.
            success := call(gas(), to, amount, 0, 0, 0, 0)
        }

        require(success, "ETH_TRANSFER_FAILED");
    }

    /*//////////////////////////////////////////////////////////////
                            ERC20 OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferFrom(
        ERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x23b872dd00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(from, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "from" argument.
            mstore(add(freeMemoryPointer, 36), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "to" argument.
            mstore(add(freeMemoryPointer, 68), amount) // Append the "amount" argument. Masking not required as it's a full 32 byte type.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 100 because the length of our calldata totals up like so: 4 + 32 * 3.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 100, 0, 32)
            )
        }

        require(success, "TRANSFER_FROM_FAILED");
    }

    function safeTransfer(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument. Masking not required as it's a full 32 byte type.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        require(success, "TRANSFER_FAILED");
    }

    function safeApprove(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x095ea7b300000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument. Masking not required as it's a full 32 byte type.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        require(success, "APPROVE_FAILED");
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
/// @notice Common logic between all Sablier V2 lockup streaming contracts.
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
    /// @param senderAmount The amount of assets refunded to the stream's sender, denoted in units of the asset's
    /// decimals.
    /// @param recipientAmount The amount of assets left for the stream's recipient to withdraw, denoted in units of the
    /// asset's decimals.
    event CancelLockupStream(
        uint256 indexed streamId,
        address indexed sender,
        address indexed recipient,
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
    /// @param amount The amount of assets withdrawn, denoted in units of the asset's decimals.
    event WithdrawFromLockupStream(uint256 indexed streamId, address indexed to, uint128 amount);

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
    /// - This function attempts to invoke a hook on either the sender or the recipient, depending on who `msg.sender`
    /// is, and if the resolved address is a contract.
    ///
    /// Requirements:
    /// - Must not be delegate called.
    /// - The stream must be warm and cancelable.
    /// - `msg.sender` must be either the stream's sender or the stream's recipient (i.e. the NFT owner).
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
/// @notice Creates and manages lockup streams with a linear streaming function.
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
    /// the sum of `block.timestamp` and `params.durations.total. The stream is funded by `msg.sender` and is wrapped
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

/// @title ISablierV2LockupRecipient
/// @notice Interface for recipient contracts capable of reacting to cancellations, renouncements, and withdrawals.
/// @dev Implementation of this interface is optional. If a recipient contract doesn't implement this
/// interface or implements it partially, function execution will not revert.
interface ISablierV2LockupRecipient {
    /// @notice Responds to sender-triggered cancellations.
    ///
    /// @dev Notes:
    /// - This function may revert, but the Sablier contract will ignore the revert.
    ///
    /// @param streamId The id of the canceled stream.
    /// @param sender The stream's sender, who canceled the stream.
    /// @param senderAmount The amount of assets refunded to the stream's sender, denoted in units of the asset's
    /// decimals.
    /// @param recipientAmount The amount of assets left for the stream's recipient to withdraw, denoted in units of
    /// the asset's decimals.
    function onStreamCanceled(
        uint256 streamId,
        address sender,
        uint128 senderAmount,
        uint128 recipientAmount
    )
        external;

    /// @notice Responds to renouncements.
    ///
    /// @dev Notes:
    /// - This function may revert, but the Sablier contract will ignore the revert.
    ///
    /// @param streamId The id of the renounced stream.
    function onStreamRenounced(uint256 streamId) external;

    /// @notice Responds to withdrawals triggered by either the stream's sender or an approved third party.
    ///
    /// @dev Notes:
    /// - This function may revert, but the Sablier contract will ignore the revert.
    ///
    /// @param streamId The id of the stream being withdrawn from.
    /// @param caller The original `msg.sender` address that triggered the withdrawal.
    /// @param to The address receiving the withdrawn assets.
    /// @param amount The amount of assets withdrawn, denoted in units of the asset's decimals.
    function onStreamWithdrawn(uint256 streamId, address caller, address to, uint128 amount) external;
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
    /// @param broker Struct containing (i) the address of the broker assisting in creating the stream, and (ii) the
    /// percentage fee paid to the broker from `totalAmount`, denoted as a fixed-point number. Both can be set to zero.
    /// @param segments Segments with deltas used to compose the custom streaming curve. Milestones are calculated by
    /// starting from `block.timestamp` and adding each delta to the previous milestone.
    struct CreateWithDeltas {
        address sender;
        bool cancelable;
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
    /// @param durations Struct containing (i) cliff period duration and (ii) total stream duration, both in seconds.
    /// @param broker Struct containing (i) the address of the broker assisting in creating the stream, and (ii) the
    /// percentage fee paid to the broker from `totalAmount`, denoted as a fixed-point number. Both can be set to zero.
    struct CreateWithDurations {
        address sender;
        address recipient;
        uint128 totalAmount;
        IERC20 asset;
        bool cancelable;
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
        // slot 2 and 3
        Lockup.Amounts amounts;
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity =0.8.21;

import { ERC20 } from "lib/solmate/src/tokens/ERC20.sol";
import { SafeTransferLib } from "lib/solmate/src/utils/SafeTransferLib.sol";
import "lib/openzeppelin-contracts/contracts/utils/structs/EnumerableSet.sol";
import { ISablierV2Lockup } from "lib/v2-core/src/interfaces/ISablierV2LockupLinear.sol";
import { ISablierV2LockupRecipient } from
    "lib/v2-core/src/interfaces/hooks/ISablierV2LockupRecipient.sol";
import { IFjordPoints } from "./interfaces/IFjordPoints.sol";

struct DepositReceipt {
    uint16 epoch;
    uint256 staked;
    uint256 vestedStaked;
}

struct ClaimReceipt {
    uint16 requestEpoch;
    uint256 amount;
}

struct NFTData {
    uint16 epoch;
    uint256 amount;
}

struct UserData {
    uint256 totalStaked;
    uint256 unclaimedRewards;
    uint16 unredeemedEpoch;
    uint16 lastClaimedEpoch;
}

contract FjordStaking is ISablierV2LockupRecipient {
    /// -----------------------------------------------------------------------
    /// Dependencies
    /// -----------------------------------------------------------------------

    using EnumerableSet for EnumerableSet.UintSet;
    using SafeTransferLib for ERC20;

    /// -----------------------------------------------------------------------
    /// Events
    /// -----------------------------------------------------------------------

    /// @dev Emitted when tokens are staked in the contract.
    /// @param user The address of the caller initiating the stake.
    /// @param epoch The current epoch cycle.
    /// @param amount The amount of tokens received in the stake.
    event Staked(address indexed user, uint16 indexed epoch, uint256 amount);

    /// @dev Emitted when vested FJORD tokens are staked in the contract.
    /// @param user The address of the caller initiating the stake.
    /// @param epoch The current epoch cycle.
    /// @param amount The amount of tokens received in the stake.
    /// @param streamID The stream id of the NFT.
    event VestedStaked(
        address indexed user, uint16 indexed epoch, uint256 indexed streamID, uint256 amount
    );

    /// @dev Emitted when rewards are added in the contract.
    /// @param epoch The current epoch cycle.
    /// @param amount The amount of tokens added as rewards.
    event RewardAdded(uint16 indexed epoch, address rewardAdmin, uint256 amount);

    /// @dev Emitted when rewards are claimed by the user.
    /// @param user The address of the caller initiating the claim.
    /// @param amount The amount of rewards given.
    event RewardClaimed(address indexed user, uint256 amount);

    /// @dev Emitted when rewards are claimed by the user before cooldown.
    /// @param user The address of the caller initiating the claim.
    /// @param rewardAmount The amount of rewards given.
    /// @param penaltyAmount The amount of tokens deducted as penalty.
    event EarlyRewardClaimed(address indexed user, uint256 rewardAmount, uint256 penaltyAmount);

    /// @dev Emitted when user claims rewards from all epoch cycles.
    /// @param user The address of the caller initiating the claim.
    /// @param totalRewardAmount The total reward amount given.
    /// @param totalPenaltyAmount The total amount penalised for early claim.
    event ClaimedAll(address indexed user, uint256 totalRewardAmount, uint256 totalPenaltyAmount);

    /// @dev Emitted when user unstakes the deposit.
    /// @param user The address of the caller initiating the unstake.
    /// @param epoch The epoch cycle for which unstake is initiated.
    /// @param stakedAmount The staked amount for the user.
    event Unstaked(address indexed user, uint16 indexed epoch, uint256 stakedAmount);

    /// @dev Emitted when user unstakes the vested FJO.
    /// @param user The address of the caller initiating the unstake.
    /// @param epoch The epoch cycle for which unstake is initiated.
    /// @param stakedAmount The staked amount for the user.
    /// @param streamID The stream id of the NFT.
    event VestedUnstaked(
        address indexed user, uint16 indexed epoch, uint256 stakedAmount, uint256 streamID
    );

    /// @dev Emitted when user unstakes the deposit from all epoch cycles.
    /// @param user The address of the caller initiating the unstake.
    /// @param totalStakedAmount The total staked amount for the user.
    /// @param activeDepositsBefore The epochs with active deposit in which user staked before unstake.
    /// @param activeDepositsAfter The epochs with active deposit in which user staked after unstake.
    event UnstakedAll(
        address indexed user,
        uint256 totalStakedAmount,
        uint256[] activeDepositsBefore,
        uint256[] activeDepositsAfter
    );

    /// @dev Emitted when user create a claim receipt.
    /// @param user The address of the caller initiating the claim receipt.
    /// @param requestEpoch The epoch of claim receipt.
    event ClaimReceiptCreated(address indexed user, uint16 requestEpoch);

    /// @dev Emitted when user claims reward from the claim receipt.
    /// @param epoch The epoch cycle for which reward is changed.
    /// @param rewardPerToken The amount of reward for given epoch.
    event RewardPerTokenChanged(uint16 epoch, uint256 rewardPerToken);

    /// @dev Emitted when sablier withdrawn hook is invoked.
    /// @param user The owner that stake stream id.
    /// @param streamID The stream id of the NFT.
    /// @param caller The stream sender that withdrawn the stream.
    /// @param amount The amount of tokens withdrawn.
    event SablierWithdrawn(address indexed user, uint256 streamID, address caller, uint256 amount);

    /// @dev Emitted when sablier withdrawn hook is invoked.
    /// @param user The owner that stake stream id.
    /// @param streamID The stream id of the NFT.
    /// @param caller The stream sender that withdrawn the stream.
    /// @param amount The amount of tokens unstake.
    event SablierCanceled(address indexed user, uint256 streamID, address caller, uint256 amount);
    /// -----------------------------------------------------------------------
    /// Errors
    /// -----------------------------------------------------------------------

    /// @dev Error thrown when an address is not allowed to call a function.
    error CallerDisallowed();

    /// @dev Error thrown when a given amount is not in valid range.
    error InvalidAmount();

    /// @dev Error thrown when unstake a deposit too early.
    error UnstakeEarly();

    /// @dev Error thrown when claim reward too early.
    error ClaimTooEarly();

    /// @dev Error thrown when a deposit is not found.
    error DepositNotFound();

    /// @dev Error thrown when a claim receipt is not found.
    error ClaimReceiptNotFound();

    /// @dev Error thrown when a user have no active deposit.
    error NoActiveDeposit();

    /// @dev Error thrown when try to unstake more amount than the given deposit available.
    error UnstakeMoreThanDeposit();

    /// @dev Error thrown when user tries to stake an NFT that doesn't exists.
    error NotAStream();

    /// @dev Error thrown when user tries to stake an NFT that is not supported.
    error StreamNotSupported();

    /// @dev Error thrown when user tries to stake an NFT a cold stream.
    error NotAWarmStream();

    /// @dev Error thrown sablier vesting NFT is not of FJO token.
    error InvalidAsset();

    /// @dev Error thrown when there is nothing to claim.
    error NothingToClaim();

    /// @dev Error thrown when stream owner not found.
    error StreamOwnerNotFound();

    /// @dev Error thrown when address is zero.
    error InvalidZeroAddress();

    /// @dev Error thrown when complete claim request too early.
    error CompleteRequestTooEarly();

    /// -----------------------------------------------------------------------
    /// Mutable Storage
    /// -----------------------------------------------------------------------

    /// @notice The owner of the staking contract.
    address public owner;

    /// @notice The address of the sablier vesting contrat.
    ISablierV2Lockup public sablier;

    /// @notice The address of the fjord points contract.
    IFjordPoints public points;

    /// @notice Deposit receipts for staking, user => epoch => deposit receipt
    mapping(address user => mapping(uint16 epoch => DepositReceipt)) public deposits;

    /// @notice Claim receipt receipts for reawrds, user => epoch => claim receipt
    mapping(address user => ClaimReceipt) public claimReceipts;

    /// @notice Active deposits by the user, user => set of epoch
    mapping(address user => EnumerableSet.UintSet epochIds) private _activeDeposits;

    /// @notice StreamIDs of the vested FJO staked, user => streamID => NFTData
    mapping(address user => mapping(uint256 streamID => NFTData)) private _streamIDs;

    /// @notice Owners of staked streams
    mapping(uint256 streamID => address user) private _streamIDOwners;

    /// @notice User stakes and rewards data
    mapping(address user => UserData) public userData;

    /// @notice Rewards distributed accumulated up to the epoch
    ///  rewardPerToken in each epoch will be updated one and only one, epoch => rewardPerToken
    mapping(uint16 epoch => uint256) public rewardPerToken;

    /// @notice Total staked
    uint256 public totalStaked;

    /// @notice Total vested staked
    uint256 public totalVestedStaked;

    /// @notice New staked
    uint256 public newStaked;

    /// @notice New vested staked
    uint256 public newVestedStaked;

    /// @notice Total rerwards
    uint256 public totalRewards;

    /// @notice Current epoch cycle number.
    uint16 public currentEpoch;

    /// @notice Last epoch when rewards were distributed.
    uint16 public lastEpochRewarded;

    /// @notice Mapping of authorized Sablier stream senders.
    mapping(address authorizedSablierSender => bool) public authorizedSablierSenders;

    /// -----------------------------------------------------------------------
    /// Immutable Storage
    /// -----------------------------------------------------------------------

    /// @notice One epoch time in seconds.
    uint256 public constant EPOCH_DURATION = 86_400 * 7; // 7 days;

    /// @notice Lock duration in epoch cycles.
    uint8 public constant LOCK_CYCLE = 6;

    /// @notice Constant
    uint256 public constant PRECISION_18 = 1e18;

    /// @notice Claim cooldown duration in epoch cycles.
    uint8 public constant CLAIM_CYCLE = 3;

    /// @notice Address of FJORD token.
    ERC20 public immutable fjordToken;

    /// @notice Start time of the staking contract.
    uint256 public immutable startTime;

    /// @notice Reward admin.
    address public rewardAdmin;

    /**
     *
     *  CONSTRUCTOR & INITIALIZATION
     *
     */

    /**
     * @notice Initializes the contract with starting variables
     * @param _fjordToken is the FJORD token contract
     * @param _rewardAdmin is the Fee distributor contract
     */
    constructor(
        address _fjordToken,
        address _rewardAdmin,
        address _sablier,
        address _authorizedSablierSender,
        address _fjordPoints
    ) {
        if (
            _rewardAdmin == address(0) || _sablier == address(0) || _fjordToken == address(0)
                || _fjordPoints == address(0)
        ) revert InvalidZeroAddress();

        startTime = block.timestamp;
        owner = msg.sender;
        fjordToken = ERC20(_fjordToken);
        currentEpoch = 1;
        rewardAdmin = _rewardAdmin;
        sablier = ISablierV2Lockup(_sablier);
        points = IFjordPoints(_fjordPoints);
        if (_authorizedSablierSender != address(0)) {
            authorizedSablierSenders[_authorizedSablierSender] = true;
        }
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert CallerDisallowed();
        _;
    }

    modifier onlyRewardAdmin() {
        if (msg.sender != rewardAdmin) revert CallerDisallowed();
        _;
    }

    modifier checkEpochRollover() {
        _checkEpochRollover();
        _;
    }

    modifier redeemPendingRewards() {
        _redeem(msg.sender);
        _;
    }

    modifier onlySablier() {
        if (msg.sender != address(sablier)) revert CallerDisallowed();
        _;
    }

    function getEpoch(uint256 _timestamp) public view returns (uint16) {
        if (_timestamp < startTime) return 0;
        return uint16((_timestamp - startTime) / EPOCH_DURATION) + 1;
    }

    function getActiveDeposits(address _user) public view returns (uint256[] memory) {
        return _activeDeposits[_user].values();
    }

    function getStreamData(address _user, uint256 _streamID) public view returns (NFTData memory) {
        return _streamIDs[_user][_streamID];
    }

    function getStreamOwner(uint256 _streamID) public view returns (address) {
        return _streamIDOwners[_streamID];
    }

    function setOwner(address _newOwner) external onlyOwner {
        if (_newOwner == address(0)) revert InvalidZeroAddress();
        owner = _newOwner;
    }

    function setRewardAdmin(address _rewardAdmin) external onlyOwner {
        if (_rewardAdmin == address(0)) revert InvalidZeroAddress();
        rewardAdmin = _rewardAdmin;
    }

    function addAuthorizedSablierSender(address _address) external onlyOwner {
        authorizedSablierSenders[_address] = true;
    }

    function removeAuthorizedSablierSender(address _address) external onlyOwner {
        if (authorizedSablierSenders[_address]) authorizedSablierSenders[_address] = false;
    }

    /// @notice Stake FJORD tokens into the contract.
    /// @dev This function allows users to stake a certain number of FJORD tokens.
    /// @param _amount The amount of tokens user wants to stake.
    function stake(uint256 _amount) external checkEpochRollover redeemPendingRewards {
        //CHECK
        if (_amount == 0) revert InvalidAmount();

        //EFFECT
        userData[msg.sender].unredeemedEpoch = currentEpoch;

        DepositReceipt storage dr = deposits[msg.sender][currentEpoch];
        if (dr.epoch == 0) {
            dr.staked = _amount;
            dr.epoch = currentEpoch;
            _activeDeposits[msg.sender].add(currentEpoch);
        } else {
            dr.staked += _amount;
        }

        newStaked += _amount;

        //INTERACT
        fjordToken.safeTransferFrom(msg.sender, address(this), _amount);
        points.onStaked(msg.sender, _amount);

        emit Staked(msg.sender, currentEpoch, _amount);
    }

    /// @notice Stake vested FJORD tokens into the contract.
    /// @dev This function allows users to stake a certain their NFT from
    /// sablier that contains FJORD tokens.
    /// @param _streamID The streamID of the vested NFT.
    function stakeVested(uint256 _streamID) external checkEpochRollover redeemPendingRewards {
        //CHECK
        if (!sablier.isStream(_streamID)) revert NotAStream();
        if (sablier.isCold(_streamID)) revert NotAWarmStream();

        // only allow authorized stream sender to stake cancelable stream
        if (!authorizedSablierSenders[sablier.getSender(_streamID)]) {
            revert StreamNotSupported();
        }
        if (address(sablier.getAsset(_streamID)) != address(fjordToken)) revert InvalidAsset();

        uint128 depositedAmount = sablier.getDepositedAmount(_streamID);
        uint128 withdrawnAmount = sablier.getWithdrawnAmount(_streamID);
        uint128 refundedAmount = sablier.getRefundedAmount(_streamID);

        if (depositedAmount - (withdrawnAmount + refundedAmount) <= 0) revert InvalidAmount();

        uint256 _amount = depositedAmount - (withdrawnAmount + refundedAmount);

        //EFFECT
        userData[msg.sender].unredeemedEpoch = currentEpoch;

        DepositReceipt storage dr = deposits[msg.sender][currentEpoch];
        if (dr.epoch == 0) {
            dr.vestedStaked = _amount;
            dr.epoch = currentEpoch;

            _activeDeposits[msg.sender].add(currentEpoch);
        } else {
            dr.vestedStaked += _amount;
        }

        _streamIDs[msg.sender][_streamID] = NFTData({ epoch: currentEpoch, amount: _amount });
        _streamIDOwners[_streamID] = msg.sender;
        newStaked += _amount;
        newVestedStaked += _amount;

        //INTERACT
        sablier.transferFrom({ from: msg.sender, to: address(this), tokenId: _streamID });
        points.onStaked(msg.sender, _amount);

        emit VestedStaked(msg.sender, currentEpoch, _streamID, _amount);
    }

    /// @notice Unstake FJORD tokens from the contract.
    /// @dev This function allows users to unstake a certain number of FJORD tokens,
    /// while also claiming all the pending rewards. If _isEarly is true then the
    /// user will be able to bypass rewards cooldown of 3 epochs and claim early,
    /// but will incur early claim penalty.
    /// @param _epoch The epoch cycle from which user wants to unstake.
    /// @param _amount The amount of tokens user wants to unstake.
    /// @return total The total amount sent to the user.
    function unstake(uint16 _epoch, uint256 _amount)
        external
        checkEpochRollover
        redeemPendingRewards
        returns (uint256 total)
    {
        if (_amount == 0) revert InvalidAmount();

        DepositReceipt storage dr = deposits[msg.sender][_epoch];

        if (dr.epoch == 0) revert DepositNotFound();
        if (dr.staked < _amount) revert UnstakeMoreThanDeposit();

        // _epoch is same as current epoch then user can unstake immediately
        if (currentEpoch != _epoch) {
            // _epoch less than current epoch then user can unstake after at complete LOCK_CYCLE
            if (currentEpoch - _epoch <= LOCK_CYCLE) revert UnstakeEarly();
        }

        //EFFECT
        dr.staked -= _amount;
        if (currentEpoch != _epoch) {
            totalStaked -= _amount;
            userData[msg.sender].totalStaked -= _amount;
        } else {
            // unstake immediately
            newStaked -= _amount;
        }

        if (dr.staked == 0 && dr.vestedStaked == 0) {
            delete deposits[msg.sender][_epoch];
            _activeDeposits[msg.sender].remove(_epoch);
        }

        total = _amount;

        //INTERACT
        fjordToken.safeTransfer(msg.sender, total);
        points.onUnstaked(msg.sender, _amount);

        emit Unstaked(msg.sender, _epoch, _amount);
    }

    /// @notice Unstake vested FJORD tokens from the contract.
    /// @dev This function allows users to unstake vested FJORD tokens,
    /// while also claiming all the pending rewards. If _isClaimEarly is true then the
    /// user will be able to bypass rewards cooldown of 3 epochs and claim early,
    /// but will incur early claim penalty.
    /// @param _streamID The sablier streamID that the user staked.
    function unstakeVested(uint256 _streamID) external checkEpochRollover redeemPendingRewards {
        //CHECK
        NFTData memory data = _streamIDs[msg.sender][_streamID];
        DepositReceipt memory dr = deposits[msg.sender][data.epoch];

        if (data.epoch == 0 || data.amount == 0 || dr.vestedStaked == 0 || dr.epoch == 0) {
            revert DepositNotFound();
        }

        // If epoch is same as current epoch then user can unstake immediately
        if (currentEpoch != data.epoch) {
            // If epoch less than current epoch then user can unstake after at complete LOCK_CYCLE
            if (currentEpoch - data.epoch <= LOCK_CYCLE) revert UnstakeEarly();
        }

        _unstakeVested(msg.sender, _streamID, data.amount);
    }

    /// @notice Partial or fully unstake vested .
    function _unstakeVested(address streamOwner, uint256 _streamID, uint256 amount) internal {
        NFTData storage data = _streamIDs[streamOwner][_streamID];
        DepositReceipt storage dr = deposits[streamOwner][data.epoch];
        if (amount > data.amount) revert InvalidAmount();

        bool isFullUnstaked = data.amount == amount;
        uint16 epoch = data.epoch;

        dr.vestedStaked -= amount;
        if (currentEpoch != data.epoch) {
            totalStaked -= amount;
            totalVestedStaked -= amount;
            userData[streamOwner].totalStaked -= amount;
        } else {
            // unstake immediately
            newStaked -= amount;
            newVestedStaked -= amount;
        }

        if (dr.vestedStaked == 0 && dr.staked == 0) {
            // instant unstake
            delete deposits[streamOwner][data.epoch];
            _activeDeposits[streamOwner].remove(data.epoch);
        }
        // fully unstake
        if (isFullUnstaked) {
            delete _streamIDs[streamOwner][_streamID];
            delete _streamIDOwners[_streamID];
        } else {
            data.amount -= amount;
        }

        //INTERACT
        if (isFullUnstaked) {
            sablier.transferFrom({ from: address(this), to: streamOwner, tokenId: _streamID });
        }

        points.onUnstaked(streamOwner, amount);

        emit VestedUnstaked(streamOwner, epoch, amount, _streamID);
    }

    /// @notice Unstake from all epochs.
    /// @dev This function allows users to unstake from all the epochs at once,
    /// while also claiming all the pending rewards.
    /// @return totalStakedAmount The total amount that has been unstaked.
    function unstakeAll()
        external
        checkEpochRollover
        redeemPendingRewards
        returns (uint256 totalStakedAmount)
    {
        uint256[] memory activeDeposits = getActiveDeposits(msg.sender);
        if (activeDeposits.length == 0) revert NoActiveDeposit();

        for (uint16 i = 0; i < activeDeposits.length; i++) {
            uint16 epoch = uint16(activeDeposits[i]);
            DepositReceipt storage dr = deposits[msg.sender][epoch];

            if (dr.epoch == 0 || currentEpoch - epoch <= LOCK_CYCLE) continue;

            totalStakedAmount += dr.staked;

            // no vested staked and stake is 0 then delete the deposit
            if (dr.vestedStaked == 0) {
                delete deposits[msg.sender][epoch];
                _activeDeposits[msg.sender].remove(epoch);
            } else {
                // still have vested staked, then only delete the staked
                dr.staked = 0;
            }
        }

        totalStaked -= totalStakedAmount;
        userData[msg.sender].totalStaked -= totalStakedAmount;

        fjordToken.transfer(msg.sender, totalStakedAmount);
        points.onUnstaked(msg.sender, totalStakedAmount);

        // emit event
        emit UnstakedAll(
            msg.sender, totalStakedAmount, activeDeposits, getActiveDeposits(msg.sender)
        );
    }

    /// @notice Claim reward from specific epoch.
    /// @dev This function allows users to claim rewards from an epochs,
    /// if the user chooses to bypass the reward cooldown of 3 epochs,
    /// then reward penalty will be levied.
    /// @param _isClaimEarly Whether user wants to claim early and incur penalty.
    /// @return rewardAmount The reward amount that has been distributed.
    /// @return penaltyAmount The penalty incurred by the user for early claim.
    function claimReward(bool _isClaimEarly)
        external
        checkEpochRollover
        redeemPendingRewards
        returns (uint256 rewardAmount, uint256 penaltyAmount)
    {
        //CHECK
        UserData storage ud = userData[msg.sender];

        // do not allow to claimReward while user have pending claimReceipt
        // or user have claimed from the last epoch
        if (claimReceipts[msg.sender].requestEpoch > 0) revert ClaimTooEarly();

        if (ud.unclaimedRewards == 0) revert NothingToClaim();

        //EFFECT
        if (!_isClaimEarly) {
            claimReceipts[msg.sender] =
                ClaimReceipt({ requestEpoch: currentEpoch, amount: ud.unclaimedRewards });

            emit ClaimReceiptCreated(msg.sender, currentEpoch);

            return (0, 0);
        }

        rewardAmount = ud.unclaimedRewards;
        penaltyAmount = rewardAmount / 2;
        rewardAmount -= penaltyAmount;

        if (rewardAmount == 0) return (0, 0);

        totalRewards -= (rewardAmount + penaltyAmount);
        userData[msg.sender].unclaimedRewards -= (rewardAmount + penaltyAmount);

        //INTERACT
        fjordToken.safeTransfer(msg.sender, rewardAmount);

        emit EarlyRewardClaimed(msg.sender, rewardAmount, penaltyAmount);
    }

    /// @notice Comaplete claim receipt from specific epoch.
    /// @dev This function allows users to complete claim receipt from an epoch
    /// @return rewardAmount The reward amount that has been distributed.
    function completeClaimRequest()
        external
        checkEpochRollover
        redeemPendingRewards
        returns (uint256 rewardAmount)
    {
        ClaimReceipt memory cr = claimReceipts[msg.sender];

        //CHECK
        if (cr.requestEpoch < 1) revert ClaimReceiptNotFound();
        // to complete claim receipt, user must wait for at least 3 epochs
        if (currentEpoch - cr.requestEpoch <= CLAIM_CYCLE) revert CompleteRequestTooEarly();

        //EFFECT
        rewardAmount = cr.amount;

        userData[msg.sender].unclaimedRewards -= rewardAmount;

        totalRewards -= rewardAmount;
        delete claimReceipts[msg.sender];

        //INTERACT
        fjordToken.safeTransfer(msg.sender, rewardAmount);

        emit RewardClaimed(msg.sender, rewardAmount);
    }

    /// @notice Check and update epoch rollover.
    /// @dev rollover to latest epoch, gap epoches will be filled with previous epoch reward per token
    function _checkEpochRollover() internal {
        uint16 latestEpoch = getEpoch(block.timestamp);

        if (latestEpoch > currentEpoch) {
            //Time to rollover
            currentEpoch = latestEpoch;

            if (totalStaked > 0) {
                uint256 currentBalance = fjordToken.balanceOf(address(this));

                // no distribute the rewards to the users coming in the current epoch
                uint256 pendingRewards = (currentBalance + totalVestedStaked + newVestedStaked)
                    - totalStaked - newStaked - totalRewards;
                uint256 pendingRewardsPerToken = (pendingRewards * PRECISION_18) / totalStaked;
                totalRewards += pendingRewards;
                for (uint16 i = lastEpochRewarded + 1; i < currentEpoch; i++) {
                    rewardPerToken[i] = rewardPerToken[lastEpochRewarded] + pendingRewardsPerToken;
                    emit RewardPerTokenChanged(i, rewardPerToken[i]);
                }
            } else {
                for (uint16 i = lastEpochRewarded + 1; i < currentEpoch; i++) {
                    rewardPerToken[i] = rewardPerToken[lastEpochRewarded];
                    emit RewardPerTokenChanged(i, rewardPerToken[i]);
                }
            }

            totalStaked += newStaked;
            totalVestedStaked += newVestedStaked;
            newStaked = 0;
            newVestedStaked = 0;

            lastEpochRewarded = currentEpoch - 1;
        }
    }

    /// @notice accumulate unclaimed rewards for the user from last non-zero unredeemed epoch
    /// This function should run before every tx user does, so state is correctly maintained everytime
    /// Last unredeemed epoch will be the last epoch user staked
    function _redeem(address sender) internal {
        //1. Get user data
        UserData storage ud = userData[sender];

        ud.unclaimedRewards +=
            _calculateReward(ud.totalStaked, ud.lastClaimedEpoch, currentEpoch - 1);
        ud.lastClaimedEpoch = currentEpoch - 1;

        if (ud.unredeemedEpoch > 0 && ud.unredeemedEpoch < currentEpoch) {
            // 2. Calculate rewards for all deposits since last redeemed, there will be only 1 pending unredeemed epoch
            DepositReceipt memory deposit = deposits[sender][ud.unredeemedEpoch];

            // 3. Update last redeemed and pending rewards
            ud.unclaimedRewards += _calculateReward(
                deposit.staked + deposit.vestedStaked, ud.unredeemedEpoch, currentEpoch - 1
            );

            ud.unredeemedEpoch = 0;
            ud.totalStaked += (deposit.staked + deposit.vestedStaked);
        }
    }

    /// @notice addReward should be called by master chef
    /// must be only call if it's can trigger update next epoch so the total staked won't increase anymore
    /// must be the action to trigger update epoch and the last action of the epoch
    /// @param _amount The amount of tokens to be added as rewards.
    function addReward(uint256 _amount) external onlyRewardAdmin {
        //CHECK
        if (_amount == 0) revert InvalidAmount();

        //EFFECT
        uint16 previousEpoch = currentEpoch;

        //INTERACT
        fjordToken.safeTransferFrom(msg.sender, address(this), _amount);

        _checkEpochRollover();

        emit RewardAdded(previousEpoch, msg.sender, _amount);
    }

    /// @notice Calculate reward for a given amount from _fromEpoch to _toEpoch
    /// @param _amount The amount of tokens staked.
    /// @param _fromEpoch The epoch from which reward calculation starts.
    /// @param _toEpoch The epoch till which reward calculation is done.
    /// @return rewardAmount The reward amount that has been distributed.
    function _calculateReward(uint256 _amount, uint16 _fromEpoch, uint16 _toEpoch)
        internal
        view
        returns (uint256 rewardAmount)
    {
        rewardAmount =
            (_amount * (rewardPerToken[_toEpoch] - rewardPerToken[_fromEpoch])) / PRECISION_18;
    }

    /// @notice Responds to withdrawals triggered by either the stream's sender or an approved third party.
    /// @notice if onStreamWithdrawn is implemented inproperly, the execution flow still continues.
    /// @dev Notes:
    /// - This function may revert, but the Sablier contract will ignore the revert.
    /// @param /*streamId*/ The id of the stream being withdrawn from.
    /// @param /*caller*/ The original `msg.sender` address that triggered the withdrawal.
    /// @param /*to*/ The staking contract address receiving the withdrawn assets.
    /// @param /*amount*/ The amount of assets withdrawn, denoted in units of the asset's decimals.
    function onStreamWithdrawn(
        uint256, /*streamId*/
        address, /*caller*/
        address, /*to*/
        uint128 /*amount*/
    ) external override onlySablier {
        // Left blank intentionally
    }

    /// @notice Responds to renouncements.
    /// @notice Renouncing a stream means that the sender of the stream will no longer be able to cancel it.
    /// This is useful if the sender wants to give up control of the stream.
    /// @notice onStreamRenounced never be called with non-cancelable stream
    /// and does nothing effect on the staking contract
    /// @dev Notes:
    /// - This function may revert, but the Sablier contract will ignore the revert.
    /// @param /*streamId*/ The id of the renounced stream.
    function onStreamRenounced(uint256 /*streamId*/ ) external override onlySablier {
        // Left blank intentionally
    }

    /// @notice onStreamCanceled never be called with non-cancelable stream
    /// @notice Responds to sender-triggered cancellations.
    /// @dev Notes:
    /// - This function may revert, but the Sablier contract will ignore the revert.
    /// @param streamId The id of the canceled stream.
    /// @param sender The stream's sender, who canceled the stream.
    /// @param senderAmount The amount of assets refunded to the stream's sender, denoted in units of the asset's
    /// decimals.
    /// @param /*recipientAmount*/ The amount of assets left for the stream's recipient to withdraw, denoted in units of
    /// the asset's decimals. This is the expected amount left in staking contract.
    function onStreamCanceled(
        uint256 streamId,
        address sender,
        uint128 senderAmount,
        uint128 /*recipientAmount*/
    ) external override onlySablier checkEpochRollover {
        address streamOwner = _streamIDOwners[streamId];

        if (streamOwner == address(0)) revert StreamOwnerNotFound();

        _redeem(streamOwner);

        NFTData memory nftData = _streamIDs[streamOwner][streamId];

        uint256 amount =
            uint256(senderAmount) > nftData.amount ? nftData.amount : uint256(senderAmount);

        _unstakeVested(streamOwner, streamId, amount);

        emit SablierCanceled(streamOwner, streamId, sender, amount);
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity =0.8.21;

interface IFjordPoints {
    function onStaked(address user, uint256 amount) external;
    function onUnstaked(address user, uint256 amount) external;
}