// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.20;

import {IERC165} from "../../utils/introspection/IERC165.sol";

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
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/introspection/IERC165.sol)

pragma solidity ^0.8.20;

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
pragma solidity >=0.8.4;

/// @notice Safe ETH and ERC20 transfer library that gracefully handles missing return values.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/SafeTransferLib.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/SafeTransferLib.sol)
///
/// @dev Note:
/// - For ETH transfers, please use `forceSafeTransferETH` for gas griefing protection.
/// - For ERC20s, this implementation won't check that a token has code,
/// responsibility is delegated to the caller.
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

    /// @dev Suggested gas stipend for contract receiving ETH
    /// that disallows any storage writes.
    uint256 internal constant _GAS_STIPEND_NO_STORAGE_WRITES = 2300;

    /// @dev Suggested gas stipend for contract receiving ETH to perform a few
    /// storage reads and writes, but low enough to prevent griefing.
    /// Multiply by a small constant (e.g. 2), if needed.
    uint256 internal constant _GAS_STIPEND_NO_GRIEF = 100000;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       ETH OPERATIONS                       */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Sends `amount` (in wei) ETH to `to`.
    /// Reverts upon failure.
    ///
    /// Note: This implementation does NOT protect against gas griefing.
    /// Please use `forceSafeTransferETH` for gas griefing protection.
    function safeTransferETH(address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            // Transfer the ETH and check if it succeeded or not.
            if iszero(call(gas(), to, amount, 0, 0, 0, 0)) {
                // Store the function selector of `ETHTransferFailed()`.
                mstore(0x00, 0xb12d13eb)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }
        }
    }

    /// @dev Force sends `amount` (in wei) ETH to `to`, with a `gasStipend`.
    /// The `gasStipend` can be set to a low enough value to prevent
    /// storage writes or gas griefing.
    ///
    /// If sending via the normal procedure fails, force sends the ETH by
    /// creating a temporary contract which uses `SELFDESTRUCT` to force send the ETH.
    ///
    /// Reverts if the current contract has insufficient balance.
    function forceSafeTransferETH(address to, uint256 amount, uint256 gasStipend) internal {
        /// @solidity memory-safe-assembly
        assembly {
            // If insufficient balance, revert.
            if lt(selfbalance(), amount) {
                // Store the function selector of `ETHTransferFailed()`.
                mstore(0x00, 0xb12d13eb)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }
            // Transfer the ETH and check if it succeeded or not.
            if iszero(call(gasStipend, to, amount, 0, 0, 0, 0)) {
                mstore(0x00, to) // Store the address in scratch space.
                mstore8(0x0b, 0x73) // Opcode `PUSH20`.
                mstore8(0x20, 0xff) // Opcode `SELFDESTRUCT`.
                // We can directly use `SELFDESTRUCT` in the contract creation.
                // Compatible with `SENDALL`: https://eips.ethereum.org/EIPS/eip-4758
                if iszero(create(amount, 0x0b, 0x16)) {
                    // To coerce gas estimation to provide enough gas for the `create` above.
                    if iszero(gt(gas(), 1000000)) { revert(0, 0) }
                }
            }
        }
    }

    /// @dev Force sends `amount` (in wei) ETH to `to`, with a gas stipend
    /// equal to `_GAS_STIPEND_NO_GRIEF`. This gas stipend is a reasonable default
    /// for 99% of cases and can be overridden with the three-argument version of this
    /// function if necessary.
    ///
    /// If sending via the normal procedure fails, force sends the ETH by
    /// creating a temporary contract which uses `SELFDESTRUCT` to force send the ETH.
    ///
    /// Reverts if the current contract has insufficient balance.
    function forceSafeTransferETH(address to, uint256 amount) internal {
        // Manually inlined because the compiler doesn't inline functions with branches.
        /// @solidity memory-safe-assembly
        assembly {
            // If insufficient balance, revert.
            if lt(selfbalance(), amount) {
                // Store the function selector of `ETHTransferFailed()`.
                mstore(0x00, 0xb12d13eb)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }
            // Transfer the ETH and check if it succeeded or not.
            if iszero(call(_GAS_STIPEND_NO_GRIEF, to, amount, 0, 0, 0, 0)) {
                mstore(0x00, to) // Store the address in scratch space.
                mstore8(0x0b, 0x73) // Opcode `PUSH20`.
                mstore8(0x20, 0xff) // Opcode `SELFDESTRUCT`.
                // We can directly use `SELFDESTRUCT` in the contract creation.
                // Compatible with `SENDALL`: https://eips.ethereum.org/EIPS/eip-4758
                if iszero(create(amount, 0x0b, 0x16)) {
                    // To coerce gas estimation to provide enough gas for the `create` above.
                    if iszero(gt(gas(), 1000000)) { revert(0, 0) }
                }
            }
        }
    }

    /// @dev Sends `amount` (in wei) ETH to `to`, with a `gasStipend`.
    /// The `gasStipend` can be set to a low enough value to prevent
    /// storage writes or gas griefing.
    ///
    /// Simply use `gasleft()` for `gasStipend` if you don't need a gas stipend.
    ///
    /// Note: Does NOT revert upon failure.
    /// Returns whether the transfer of ETH is successful instead.
    function trySafeTransferETH(address to, uint256 amount, uint256 gasStipend)
        internal
        returns (bool success)
    {
        /// @solidity memory-safe-assembly
        assembly {
            // Transfer the ETH and check if it succeeded or not.
            success := call(gasStipend, to, amount, 0, 0, 0, 0)
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
            // Store the function selector of `transferFrom(address,address,uint256)`.
            mstore(0x0c, 0x23b872dd000000000000000000000000)

            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    // Set success to whether the call reverted, if not we check it either
                    // returned exactly 1 (can't just be non-zero data), or had no return data.
                    or(eq(mload(0x00), 1), iszero(returndatasize())),
                    call(gas(), token, 0, 0x1c, 0x64, 0x00, 0x20)
                )
            ) {
                // Store the function selector of `TransferFromFailed()`.
                mstore(0x00, 0x7939f424)
                // Revert with (offset, size).
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
            // Store the function selector of `balanceOf(address)`.
            mstore(0x0c, 0x70a08231000000000000000000000000)
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    gt(returndatasize(), 0x1f), // At least 32 bytes returned.
                    staticcall(gas(), token, 0x1c, 0x24, 0x60, 0x20)
                )
            ) {
                // Store the function selector of `TransferFromFailed()`.
                mstore(0x00, 0x7939f424)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }

            // Store the function selector of `transferFrom(address,address,uint256)`.
            mstore(0x00, 0x23b872dd)
            // The `amount` argument is already written to the memory word at 0x60.
            amount := mload(0x60)

            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    // Set success to whether the call reverted, if not we check it either
                    // returned exactly 1 (can't just be non-zero data), or had no return data.
                    or(eq(mload(0x00), 1), iszero(returndatasize())),
                    call(gas(), token, 0, 0x1c, 0x64, 0x00, 0x20)
                )
            ) {
                // Store the function selector of `TransferFromFailed()`.
                mstore(0x00, 0x7939f424)
                // Revert with (offset, size).
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
            // Store the function selector of `transfer(address,uint256)`.
            mstore(0x00, 0xa9059cbb000000000000000000000000)

            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    // Set success to whether the call reverted, if not we check it either
                    // returned exactly 1 (can't just be non-zero data), or had no return data.
                    or(eq(mload(0x00), 1), iszero(returndatasize())),
                    call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                )
            ) {
                // Store the function selector of `TransferFailed()`.
                mstore(0x00, 0x90b8ec18)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }
            // Restore the part of the free memory pointer that was overwritten.
            mstore(0x34, 0)
        }
    }

    /// @dev Sends all of ERC20 `token` from the current contract to `to`.
    /// Reverts upon failure.
    function safeTransferAll(address token, address to) internal returns (uint256 amount) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, 0x70a08231) // Store the function selector of `balanceOf(address)`.
            mstore(0x20, address()) // Store the address of the current contract.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    gt(returndatasize(), 0x1f), // At least 32 bytes returned.
                    staticcall(gas(), token, 0x1c, 0x24, 0x34, 0x20)
                )
            ) {
                // Store the function selector of `TransferFailed()`.
                mstore(0x00, 0x90b8ec18)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }

            mstore(0x14, to) // Store the `to` argument.
            // The `amount` argument is already written to the memory word at 0x34.
            amount := mload(0x34)
            // Store the function selector of `transfer(address,uint256)`.
            mstore(0x00, 0xa9059cbb000000000000000000000000)

            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    // Set success to whether the call reverted, if not we check it either
                    // returned exactly 1 (can't just be non-zero data), or had no return data.
                    or(eq(mload(0x00), 1), iszero(returndatasize())),
                    call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                )
            ) {
                // Store the function selector of `TransferFailed()`.
                mstore(0x00, 0x90b8ec18)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }
            // Restore the part of the free memory pointer that was overwritten.
            mstore(0x34, 0)
        }
    }

    /// @dev Sets `amount` of ERC20 `token` for `to` to manage on behalf of the current contract.
    /// Reverts upon failure.
    function safeApprove(address token, address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x14, to) // Store the `to` argument.
            mstore(0x34, amount) // Store the `amount` argument.
            // Store the function selector of `approve(address,uint256)`.
            mstore(0x00, 0x095ea7b3000000000000000000000000)

            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    // Set success to whether the call reverted, if not we check it either
                    // returned exactly 1 (can't just be non-zero data), or had no return data.
                    or(eq(mload(0x00), 1), iszero(returndatasize())),
                    call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                )
            ) {
                // Store the function selector of `ApproveFailed()`.
                mstore(0x00, 0x3e3f8f73)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }
            // Restore the part of the free memory pointer that was overwritten.
            mstore(0x34, 0)
        }
    }

    /// @dev Returns the amount of ERC20 `token` owned by `account`.
    /// Returns zero if the `token` does not exist.
    function balanceOf(address token, address account) internal view returns (uint256 amount) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x14, account) // Store the `account` argument.
            // Store the function selector of `balanceOf(address)`.
            mstore(0x00, 0x70a08231000000000000000000000000)
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
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library TopKHeap {
    struct Heap {
        uint256[] scores;
        uint256[] ids;
        mapping(uint256 => uint256) indexMap;
        uint256 k;
    }

    function initialize(Heap storage _heap, uint256 _k) internal {
        _heap.k = _k;
    }

    function swap(Heap storage _heap, uint256 i, uint256 j) private {
        (_heap.scores[i], _heap.scores[j]) = (_heap.scores[j], _heap.scores[i]);
        (_heap.ids[i], _heap.ids[j]) = (_heap.ids[j], _heap.ids[i]);
        _heap.indexMap[_heap.ids[i]] = i;
        _heap.indexMap[_heap.ids[j]] = j;
    }

    function insert(Heap storage _heap, uint256 _id, uint256 _score) internal {
        uint256 index = _heap.indexMap[_id];

        if (index == 0) {
            if (_heap.scores.length < _heap.k) {
                _heap.scores.push(_score);
                _heap.ids.push(_id);
                index = _heap.scores.length - 1;
                _heap.indexMap[_id] = index;
            } else if (_score > _heap.scores[0]) {
                _heap.scores[0] = _score;
                _heap.ids[0] = _id;
                _heap.indexMap[_id] = 0;
            } else {
                return;
            }
        } else {
            _heap.scores[index] = _score;
        }

        siftDown(_heap, index);
    }

    function siftDown(Heap storage _heap, uint256 index) private {
        uint256 left = 2 * index + 1;
        uint256 right = 2 * index + 2;
        uint256 smallest = index;

        if (left < _heap.scores.length && _heap.scores[left] < _heap.scores[smallest]) {
            smallest = left;
        }
        if (right < _heap.scores.length && _heap.scores[right] < _heap.scores[smallest]) {
            smallest = right;
        }
        if (smallest != index) {
            swap(_heap, index, smallest);
            siftDown(_heap, smallest);
        }
    }

    function isInTopK(Heap storage _heap, uint256 _id) internal view returns (bool) {
        uint256 index = _heap.indexMap[_id];
        return index != 0 && index < _heap.k;
    }

    function getTopK(Heap storage _heap) internal view returns (uint256[] memory) {
        uint256 len = _heap.scores.length < _heap.k ? _heap.scores.length : _heap.k;
        uint256[] memory topKAddresses = new uint256[](len);
        for (uint256 i = 0; i < len; ++i) {
            topKAddresses[i] = _heap.ids[i];
        }
        return topKAddresses;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.3/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./libs/SafeTransferLib.sol";
import "./libs/TopKHeap.sol";

contract ArtMarketplace7d is Ownable {
  using TopKHeap for TopKHeap.Heap;
  uint256 private constant BPS = 10_000;
  uint256 private constant BID_INCREASE_THRESHOLD = 0.2 ether;
  uint256 private constant DEFAULT_SPLIT = 7_500;
  uint256 private constant EXTENSION_TIME = 10 minutes;
  uint256 private constant INIT_AUCTION_DURATION = 24 hours;
  uint256 private constant MIN_BID = 0.1 ether;
  uint256 private constant MIN_BID_INCREASE_PRE = 2_000;
  uint256 private constant MIN_BID_INCREASE_POST = 1_000;
  uint256 private constant SAFE_GAS_LIMIT = 30_000;
  uint256 private constant RANK_AUCTION_SIZE = 50;
  IERC721 private constant CONTRACT_AD = IERC721(0x9CF0aB1cc434dB83097B7E9c831a764481DEc747);
  IERC721 private constant CONTRACT_FPP = IERC721(0xA8A425864dB32fCBB459Bf527BdBb8128e6abF21);
  address public beneficiary;
  bool public paused;
  TopKHeap.Heap public leaderboard;
  mapping(address => uint16) public discountsCount;
  uint256[] public scheduled;

  struct Auction {
    uint24 offsetFromEnd;
    uint72 amount;
    address bidder;
  }

  struct AuctionConfig {
    address artist;
    uint16 split;
    uint80 preBidStartTime;
    uint80 auctionStartTime;
    uint88 reservePrice;
    uint88 preBidPrice;
  }

  mapping(uint256 => AuctionConfig) public auctionConfig;
  mapping(uint256 => Auction) public auctionIdToAuction;
  
  event BidMade(
    uint256 indexed auctionId,
    address indexed collectionAddress,
    uint256 indexed tokenId,
    address bidder,
    uint256 amount,
    uint256 timestamp
  );

  event Settled(
    uint256 indexed auctionId,
    address indexed collectionAddress,
    uint256 indexed tokenId,
    uint256 timestamp,
    uint256 price
  );

  constructor() {
    leaderboard.initialize(RANK_AUCTION_SIZE);
  }

  function bid(
    uint256 auctionId
  ) external payable {
    require(!paused, 'Bidding is paused');

    if (auctionConfig[auctionId].auctionStartTime == type(uint80).max) {
      auctionConfig[auctionId].auctionStartTime = uint80(block.timestamp);
    }

    uint256 preBidPrice = auctionConfig[auctionId].preBidPrice;

    require(
      (
        (isAuctionActive(auctionId) && leaderboard.isInTopK(auctionId))
        || (
            block.timestamp < auctionConfig[auctionId].auctionStartTime
            && preBidPrice > 0 && msg.value >= preBidPrice
        )
      ) && block.timestamp >= auctionConfig[auctionId].preBidStartTime,
      'Auction Inactive'
    );

    Auction memory highestBid = auctionIdToAuction[auctionId];
    uint256 bidIncrease = highestBid.amount >= BID_INCREASE_THRESHOLD
      ? MIN_BID_INCREASE_POST : MIN_BID_INCREASE_PRE;

    require(
      msg.value >= (highestBid.amount * (BPS + bidIncrease) / BPS)
      && msg.value >= reservePrice(auctionId),
      'Bid not high enough'
    );

    uint256 refundAmount;
    address refundBidder;
    uint256 offset = highestBid.offsetFromEnd;
    uint256 endTime = getAuctionEndTime(auctionId);

    if (highestBid.amount > 0) {
      refundAmount = highestBid.amount;
      refundBidder = highestBid.bidder;
    }

    if (endTime - block.timestamp < EXTENSION_TIME) {
      offset += block.timestamp + EXTENSION_TIME - endTime;
    }

    auctionIdToAuction[auctionId] = Auction(uint24(offset), uint72(msg.value), msg.sender);
    if (!isAuctionActive(auctionId)) {
      leaderboard.insert(auctionId, msg.value);
    }
  
    emit BidMade(
      auctionId,
      getCollectionFromId(auctionId),
      getArtTokenIdFromId(auctionId),
      msg.sender,
      msg.value,
      block.timestamp
    );

    if (refundAmount > 0) {
      SafeTransferLib.forceSafeTransferETH(refundBidder, refundAmount, SAFE_GAS_LIMIT);
    }
  }

  function settleAuction(
    uint256 auctionId
  ) external payable {
    require(!paused, 'Settling is paused');
    require(leaderboard.isInTopK(auctionId), "Auction not pre-selected.");
    Auction memory highestBid = auctionIdToAuction[auctionId];
    AuctionConfig memory config = auctionConfig[auctionId];
    require(isAuctionOver(auctionId), 'Auction is still active');

    uint256 amountToPay = highestBid.amount;
    if (amountToPay > 0) {
      _mint(highestBid.bidder, auctionId);
    } else {
      require(msg.value == reservePrice(auctionId), 'Incorrect funds sent for unclaimed');
      amountToPay = msg.value;
      _mint(owner(), auctionId);
    }

    uint256 split = config.split;
    if (split == 0) {
      split = DEFAULT_SPLIT;
    }

    uint256 tokensOwnedInContractAD = CONTRACT_AD.balanceOf(highestBid.bidder);
    uint256 tokensOwnedInContractFPP = CONTRACT_FPP.balanceOf(highestBid.bidder);

    uint256 potentialDiscount = tokensOwnedInContractAD + tokensOwnedInContractFPP;

    if (
      highestBid.bidder != address(0) && potentialDiscount > 0
      && potentialDiscount >= discountsCount[highestBid.bidder]
    ) {
      uint256 rebate =  amountToPay * 10 / 100;
      amountToPay = amountToPay - rebate;
      discountsCount[highestBid.bidder] += 1;
      SafeTransferLib.forceSafeTransferETH(highestBid.bidder, rebate, SAFE_GAS_LIMIT);
    }
    
    emit Settled(
      auctionId,
      getCollectionFromId(auctionId),
      getArtTokenIdFromId(auctionId),
      block.timestamp,
      amountToPay
    );

    uint256 amountForArtist = amountToPay * split / 10_000;
    SafeTransferLib.forceSafeTransferETH(config.artist, amountForArtist, SAFE_GAS_LIMIT);
    SafeTransferLib.forceSafeTransferETH(beneficiary, amountToPay - amountForArtist, SAFE_GAS_LIMIT);
  }

  function settleMultipleAuctions(
    uint256[] calldata auctionIds
  ) external payable {
    require(!paused, 'Settling is paused');
    uint256 unclaimedCost; uint256 amountForBene;
    for (uint256 i; i < auctionIds.length; ++i) {
      uint256 auctionId = auctionIds[i];
      require(leaderboard.isInTopK(auctionId), "Auction not pre-selected.");
      Auction memory highestBid = auctionIdToAuction[auctionId];
      require(isAuctionOver(auctionId), 'Auction is still active');

      uint256 amountToPay = highestBid.amount;
      if (amountToPay > 0) {
        _mint(highestBid.bidder, auctionId);
      } else {
        amountToPay = reservePrice(auctionId);
        unclaimedCost += amountToPay;
        _mint(owner(), auctionId);
      }

      emit Settled(
        auctionId,
        getCollectionFromId(auctionId),
        getArtTokenIdFromId(auctionId),
        block.timestamp,
        amountToPay
      );

      AuctionConfig memory config = auctionConfig[auctionId];
      uint256 split = config.split;
      if (split == 0) {
        split = DEFAULT_SPLIT;
      }
      uint256 tokensOwnedInContractAD = CONTRACT_AD.balanceOf(highestBid.bidder);
      uint256 tokensOwnedInContractFPP = CONTRACT_FPP.balanceOf(highestBid.bidder);
      uint256 potentialDiscount = tokensOwnedInContractAD + tokensOwnedInContractFPP;

      if (
        highestBid.bidder != address(0) && potentialDiscount > 0
        && potentialDiscount >= discountsCount[highestBid.bidder]
      ) {
        uint256 rebate =  amountToPay * 10 / 100;
        amountToPay = amountToPay - rebate;
        discountsCount[highestBid.bidder] += 1;
        SafeTransferLib.forceSafeTransferETH(highestBid.bidder, rebate, SAFE_GAS_LIMIT);
      }
      uint256 amountForArtist = amountToPay * split / 10_000;
      SafeTransferLib.forceSafeTransferETH(config.artist, amountForArtist, SAFE_GAS_LIMIT);

      amountForBene += amountToPay - amountForArtist;
    }

    require(msg.value == unclaimedCost, 'Incorrect funds sent for unclaimed');
    SafeTransferLib.forceSafeTransferETH(beneficiary, amountForBene, SAFE_GAS_LIMIT);
  }

  function _mint(
    address to,
    uint256 auctionId
  ) internal {
    address collection = getCollectionFromId(auctionId);
    uint256 tokenId = getArtTokenIdFromId(auctionId);
    try INFT(collection).ownerOf(tokenId) returns (address _owner) {
      if (_owner == address(0)) {
        INFT(collection).mint(to, tokenId);
      } else {
        INFT(collection).transferFrom(_owner, to, tokenId);
      }
    } catch {
      INFT(collection).mint(to, tokenId);
    }
  }

  // INTERNAL
  function _changePrices(
    address collectionAddress,
    uint256 tokenId,
    uint256 newReservePrice,
    uint256 newPreBidPrice
  ) internal {
    uint256 auctionId = artTokentoAuctionId(collectionAddress, tokenId);
    require(auctionConfig[auctionId].auctionStartTime > block.timestamp);

    auctionConfig[auctionId].reservePrice = uint88(newReservePrice);
    auctionConfig[auctionId].preBidPrice = uint88(newPreBidPrice);
  }

  function _changeSplit(
    address collectionAddress,
    uint256 tokenId,
    address artist,
    uint256 newSplit
  ) internal {
    uint256 auctionId = artTokentoAuctionId(collectionAddress, tokenId);
    if (artist != address(0)) {
      auctionConfig[auctionId].artist = artist;
    }
    auctionConfig[auctionId].split = uint16(newSplit);
  }

  function _resetAuction(
    address collectionAddress,
    uint256 tokenId
  ) internal {
    uint256 auctionId = artTokentoAuctionId(collectionAddress, tokenId);
    if (!isAuctionOver(auctionId)) {
      Auction memory auctionData = auctionIdToAuction[auctionId];
      if (auctionData.amount > 0) {
        SafeTransferLib.forceSafeTransferETH(auctionData.bidder, auctionData.amount, SAFE_GAS_LIMIT);
      }
    }
    auctionConfig[auctionId] = AuctionConfig(address(0),0,0,0,0,0);
    auctionIdToAuction[auctionId] = Auction(0,0,address(0));
  }

  function _reschedule(
    address collectionAddress,
    uint256 tokenId,
    uint256 newpreBidStartTime,
    uint256 newAuctionStartTime
  ) internal {
    uint256 auctionId = artTokentoAuctionId(collectionAddress, tokenId);
    require(auctionConfig[auctionId].auctionStartTime > block.timestamp);
    require(newpreBidStartTime <= newAuctionStartTime);

    auctionConfig[auctionId].preBidStartTime = uint80(newpreBidStartTime);
    auctionConfig[auctionId].auctionStartTime = uint80(newAuctionStartTime);
  }

  function _schedule(
    address collectionAddress,
    uint256 tokenId,
    uint256 preBidStartTime,
    uint256 auctionStartTime,
    address artist,
    uint256 split,
    uint256 reserve,
    uint256 preBidPrice
  ) internal {
    uint256 auctionId = artTokentoAuctionId(collectionAddress, tokenId);
    require(auctionConfig[auctionId].auctionStartTime == 0);

    uint256 adjAucStartTime = auctionStartTime;
    if (adjAucStartTime == 0) {
      adjAucStartTime = type(uint80).max;
    }
    auctionConfig[auctionId] = AuctionConfig(
      artist,
      uint16(split),
      uint80(preBidStartTime),
      uint80(adjAucStartTime),
      uint88(reserve),
      uint88(preBidPrice)
    );
    scheduled.push(auctionId);
  }

  // ONLY OWNER

  function changePrices(
    address collectionAddress,
    uint256 tokenId,
    uint256 newReservePrice,
    uint256 newPreBidPrice
  ) external onlyOwner {
    _changePrices(collectionAddress, tokenId, newReservePrice, newPreBidPrice);
  }

  function changePricesMultiple(
    address[] calldata collections,
    uint256[] calldata tokenIds,
    uint256[] calldata newReservePrices,
    uint256[] calldata newPreBidPrices
  ) external onlyOwner {
    require(
      collections.length == tokenIds.length && tokenIds.length == newReservePrices.length
      && newReservePrices.length == newPreBidPrices.length,
      'Array length mismatch'
    );
    for(uint256 i; i < collections.length; ++i) {
      _changePrices(collections[i], tokenIds[i], newReservePrices[i], newPreBidPrices[i]);
    }
  }

  function changeSplit(
    address collectionAddress,
    uint256 tokenId,
    address artist,
    uint256 split
  ) external onlyOwner {
    _changeSplit(collectionAddress, tokenId, artist, split);
  }

  function changeSplitMultiple(
    address[] calldata collections,
    uint256[] calldata tokenIds,
    address[] calldata artists,
    uint256[] calldata splits
  ) external onlyOwner {
    require(
      collections.length == tokenIds.length && tokenIds.length == artists.length
      && artists.length == splits.length,
      'Array length mismatch'
    );
    for(uint256 i; i < collections.length; ++i) {
      _changeSplit(collections[i], tokenIds[i], artists[i], splits[i]);
    }
  }

  function reschedule(
    address collectionAddress,
    uint256 tokenId,
    uint256 newpreBidStartTime,
    uint256 newAuctionStartTime
  ) external onlyOwner {
    _reschedule(collectionAddress, tokenId, newpreBidStartTime, newAuctionStartTime);
  }

  function resetAuction(
    address collectionAddress,
    uint256 tokenId
  ) external onlyOwner {
    _resetAuction(collectionAddress, tokenId);
  }

  function resetMultiple(
    address[] calldata collections,
    uint256[] calldata tokenIds
  ) external onlyOwner {
    require(
      collections.length == tokenIds.length,
      'Array length mismatch'
    );
    for(uint256 i; i < collections.length; ++i) {
      _resetAuction(collections[i], tokenIds[i]);
    }
  }

  function cancelUnselected() external onlyOwner {
    uint256[] memory rest = getAuctionsToCancel();
    for(uint256 i; i < rest.length; ++i) {
      _resetAuction(getCollectionFromId(rest[i]), getArtTokenIdFromId(rest[i]));
    }
  }

  function rescheduleMultiple(
    address[] calldata collections,
    uint256[] calldata tokenIds,
    uint256[] calldata newpreBidStartTimes,
    uint256[] calldata newAuctionStartTimes
  ) external onlyOwner {
    require(
      collections.length == tokenIds.length && tokenIds.length == newpreBidStartTimes.length
      && newpreBidStartTimes.length == newAuctionStartTimes.length,
      'Array length mismatch'
    );
    for(uint256 i; i < collections.length; ++i) {
      _reschedule(collections[i], tokenIds[i], newpreBidStartTimes[i], newAuctionStartTimes[i]);
    }
  }

  function schedule(
    address collectionAddress,
    uint256 tokenId,
    uint256 preBidStartTime,
    uint256 auctionStartTime,
    address artist,
    uint256 split,
    uint256 reserve,
    uint256 preBidPrice
  ) external onlyOwner {
    _schedule(
      collectionAddress,
      tokenId,
      preBidStartTime,
      auctionStartTime,
      artist,
      split,
      reserve,
      preBidPrice
    );
  }

  function scheduleMultiple(
    address[] calldata collections,
    uint256[] calldata tokenIds,
    uint256[] calldata preBidStartTimes,
    uint256[] calldata auctionStartTimes,
    address[] calldata artists,
    uint256[] calldata splits,
    uint256[] calldata reservePrices,
    uint256[] calldata preBidPrices
  ) external onlyOwner {
    require(
      collections.length == tokenIds.length && tokenIds.length == preBidStartTimes.length &&
      preBidStartTimes.length == auctionStartTimes.length && auctionStartTimes.length == artists.length
      && artists.length == splits.length && splits.length == reservePrices.length && reservePrices.length == preBidPrices.length,
      'Array length mismatch'
    );
    for(uint256 i; i < collections.length; ++i) {
      _schedule(
        collections[i],
        tokenIds[i],
        preBidStartTimes[i],
        auctionStartTimes[i],
        artists[i],
        splits[i],
        reservePrices[i],
        preBidPrices[i]
      );
    }
  }

  function scheduleMultipleLight(
    address collections,
    uint256[] calldata tokenIds,
    uint256 preBidStartTimes,
    uint256 auctionStartTimes,
    address artists,
    uint256 splits,
    uint256 reservePrices,
    uint256 preBidPrices
  ) external onlyOwner {
    for(uint256 i; i < tokenIds.length; ++i) {
      _schedule(
        collections,
        tokenIds[i],
        preBidStartTimes,
        auctionStartTimes,
        artists,
        splits,
        reservePrices,
        preBidPrices
      );
    }
  }

  function setBeneficiary(
    address _beneficiary
  ) external onlyOwner {
    beneficiary = _beneficiary;
  }

  function setPaused(
    bool _paused
  ) external onlyOwner {
    paused = _paused;
  }

  // GETTERS

  function artTokentoAuctionId(
    address collection,
    uint256 tokenId
  ) public pure returns (uint256) {
    return (uint256(uint160(collection)) << 96) | uint96(tokenId);
  }

  function isAuctionActive(
    uint256 auctionId
  ) public view returns (bool) {
    uint256 startTime = auctionConfig[auctionId].auctionStartTime;
    uint256 endTime = getAuctionEndTime(auctionId);
    return (startTime > 0 && block.timestamp >= startTime && block.timestamp < endTime);
  }

  function isAuctionOver(
    uint256 auctionId
  ) public view returns (bool) {
    uint256 startTime = auctionConfig[auctionId].auctionStartTime;
    uint256 endTime = getAuctionEndTime(auctionId);
    return (startTime > 0 && block.timestamp >= endTime);
  }

  function getAuctionEndTime(
    uint256 auctionId
  ) public view returns (uint256) {
    return auctionConfig[auctionId].auctionStartTime + INIT_AUCTION_DURATION + auctionIdToAuction[auctionId].offsetFromEnd;
  }

  function getAuctionStartTime(
    uint256 auctionId
  ) external view returns (uint256) {
    return auctionConfig[auctionId].auctionStartTime;
  }

  function getCollectionFromId(
    uint256 id
  ) public pure returns (address) {
    return address(uint160(id >> 96));
  }

  function getArtTokenIdFromId(
    uint256 id
  ) public pure returns (uint256) {
    return uint256(uint96(id));
  }

  function getPreselectedAuctions() public view returns (uint256[] memory) {
    return leaderboard.getTopK();
  }

  function getAuctionsToCancel() public view returns (uint256[] memory) {
    uint256 len = scheduled.length;
    if (len > RANK_AUCTION_SIZE) {
      uint256 listSize = len - RANK_AUCTION_SIZE;
      uint256[] memory list = new uint256[](listSize);
      uint256 j;
      for (uint256 i;i<len && j < listSize;i++){
        if(!leaderboard.isInTopK(scheduled[i])) {
          list[j] = scheduled[i];
          j++;
        }
      }
      return list;
    }
    uint256[] memory nil = new uint256[](0);
    return nil;
  }

  function reservePrice(
    uint256 auctionId
  ) public view returns (uint256) {
    uint256 reserve = auctionConfig[auctionId].reservePrice;
    return reserve != 0 ? reserve : MIN_BID;
  }
}

interface INFT {
  function mint(address to, uint256 tokenId) external;
  function ownerOf(uint256 tokenId) external view returns (address);
  function transferFrom(address from, address to, uint256 tokenId) external;
}