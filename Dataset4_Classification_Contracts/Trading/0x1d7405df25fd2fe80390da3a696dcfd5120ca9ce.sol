// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;

import {Context} from "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
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
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
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
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
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
// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

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

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Safe ETH and ERC20 transfer library that gracefully handles missing return values.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/SafeTransferLib.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/SafeTransferLib.sol)
/// @author Permit2 operations from (https://github.com/Uniswap/permit2/blob/main/src/libraries/Permit2Lib.sol)
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

    /// @dev The Permit2 operation has failed.
    error Permit2Failed();

    /// @dev The Permit2 amount must be less than `2**160 - 1`.
    error Permit2AmountOverflow();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         CONSTANTS                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Suggested gas stipend for contract receiving ETH that disallows any storage writes.
    uint256 internal constant GAS_STIPEND_NO_STORAGE_WRITES = 2300;

    /// @dev Suggested gas stipend for contract receiving ETH to perform a few
    /// storage reads and writes, but low enough to prevent griefing.
    uint256 internal constant GAS_STIPEND_NO_GRIEF = 100000;

    /// @dev The unique EIP-712 domain domain separator for the DAI token contract.
    bytes32 internal constant DAI_DOMAIN_SEPARATOR =
        0xdbb8cf42e1ecb028be3f3dbc922e1d878b963f411dc388ced501601c60f7c6f7;

    /// @dev The address for the WETH9 contract on Ethereum mainnet.
    address internal constant WETH9 = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    /// @dev The canonical Permit2 address.
    /// [Github](https://github.com/Uniswap/permit2)
    /// [Etherscan](https://etherscan.io/address/0x000000000022D473030F116dDEE9F6B43aC78BA3)
    address internal constant PERMIT2 = 0x000000000022D473030F116dDEE9F6B43aC78BA3;

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

    /// @dev Sends `amount` of ERC20 `token` from `from` to `to`.
    ///
    /// The `from` account must have at least `amount` approved for the current contract to manage.
    function trySafeTransferFrom(address token, address from, address to, uint256 amount)
        internal
        returns (bool success)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x60, amount) // Store the `amount` argument.
            mstore(0x40, to) // Store the `to` argument.
            mstore(0x2c, shl(96, from)) // Store the `from` argument.
            mstore(0x0c, 0x23b872dd000000000000000000000000) // `transferFrom(address,address,uint256)`.
            success :=
                and( // The arguments of `and` are evaluated from right to left.
                    or(eq(mload(0x00), 1), iszero(returndatasize())), // Returned 1 or nothing.
                    call(gas(), token, 0, 0x1c, 0x64, 0x00, 0x20)
                )
            mstore(0x60, 0) // Restore the zero slot to zero.
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Sends all of ERC20 `token` from `from` to `to`.
    /// Reverts upon failure.
    ///
    /// The `from` account must have their entire balance approved for the current contract to manage.
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
                mul( // The arguments of `mul` are evaluated from right to left.
                    mload(0x20),
                    and( // The arguments of `and` are evaluated from right to left.
                        gt(returndatasize(), 0x1f), // At least 32 bytes returned.
                        staticcall(gas(), token, 0x10, 0x24, 0x20, 0x20)
                    )
                )
        }
    }

    /// @dev Sends `amount` of ERC20 `token` from `from` to `to`.
    /// If the initial attempt fails, try to use Permit2 to transfer the token.
    /// Reverts upon failure.
    ///
    /// The `from` account must have at least `amount` approved for the current contract to manage.
    function safeTransferFrom2(address token, address from, address to, uint256 amount) internal {
        if (!trySafeTransferFrom(token, from, to, amount)) {
            permit2TransferFrom(token, from, to, amount);
        }
    }

    /// @dev Sends `amount` of ERC20 `token` from `from` to `to` via Permit2.
    /// Reverts upon failure.
    function permit2TransferFrom(address token, address from, address to, uint256 amount)
        internal
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40)
            mstore(add(m, 0x74), shr(96, shl(96, token)))
            mstore(add(m, 0x54), amount)
            mstore(add(m, 0x34), to)
            mstore(add(m, 0x20), shl(96, from))
            // `transferFrom(address,address,uint160,address)`.
            mstore(m, 0x36c78516000000000000000000000000)
            let p := PERMIT2
            let exists := eq(chainid(), 1)
            if iszero(exists) { exists := iszero(iszero(extcodesize(p))) }
            if iszero(and(call(gas(), p, 0, add(m, 0x10), 0x84, codesize(), 0x00), exists)) {
                mstore(0x00, 0x7939f4248757f0fd) // `TransferFromFailed()` or `Permit2AmountOverflow()`.
                revert(add(0x18, shl(2, iszero(iszero(shr(160, amount))))), 0x04)
            }
        }
    }

    /// @dev Permit a user to spend a given amount of
    /// another user's tokens via native EIP-2612 permit if possible, falling
    /// back to Permit2 if native permit fails or is not implemented on the token.
    function permit2(
        address token,
        address owner,
        address spender,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        bool success;
        /// @solidity memory-safe-assembly
        assembly {
            for {} shl(96, xor(token, WETH9)) {} {
                mstore(0x00, 0x3644e515) // `DOMAIN_SEPARATOR()`.
                if iszero(
                    and( // The arguments of `and` are evaluated from right to left.
                        lt(iszero(mload(0x00)), eq(returndatasize(), 0x20)), // Returns 1 non-zero word.
                        // Gas stipend to limit gas burn for tokens that don't refund gas when
                        // an non-existing function is called. 5K should be enough for a SLOAD.
                        staticcall(5000, token, 0x1c, 0x04, 0x00, 0x20)
                    )
                ) { break }
                // After here, we can be sure that token is a contract.
                let m := mload(0x40)
                mstore(add(m, 0x34), spender)
                mstore(add(m, 0x20), shl(96, owner))
                mstore(add(m, 0x74), deadline)
                if eq(mload(0x00), DAI_DOMAIN_SEPARATOR) {
                    mstore(0x14, owner)
                    mstore(0x00, 0x7ecebe00000000000000000000000000) // `nonces(address)`.
                    mstore(add(m, 0x94), staticcall(gas(), token, 0x10, 0x24, add(m, 0x54), 0x20))
                    mstore(m, 0x8fcbaf0c000000000000000000000000) // `IDAIPermit.permit`.
                    // `nonces` is already at `add(m, 0x54)`.
                    // `1` is already stored at `add(m, 0x94)`.
                    mstore(add(m, 0xb4), and(0xff, v))
                    mstore(add(m, 0xd4), r)
                    mstore(add(m, 0xf4), s)
                    success := call(gas(), token, 0, add(m, 0x10), 0x104, codesize(), 0x00)
                    break
                }
                mstore(m, 0xd505accf000000000000000000000000) // `IERC20Permit.permit`.
                mstore(add(m, 0x54), amount)
                mstore(add(m, 0x94), and(0xff, v))
                mstore(add(m, 0xb4), r)
                mstore(add(m, 0xd4), s)
                success := call(gas(), token, 0, add(m, 0x10), 0xe4, codesize(), 0x00)
                break
            }
        }
        if (!success) simplePermit2(token, owner, spender, amount, deadline, v, r, s);
    }

    /// @dev Simple permit on the Permit2 contract.
    function simplePermit2(
        address token,
        address owner,
        address spender,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40)
            mstore(m, 0x927da105) // `allowance(address,address,address)`.
            {
                let addressMask := shr(96, not(0))
                mstore(add(m, 0x20), and(addressMask, owner))
                mstore(add(m, 0x40), and(addressMask, token))
                mstore(add(m, 0x60), and(addressMask, spender))
                mstore(add(m, 0xc0), and(addressMask, spender))
            }
            let p := mul(PERMIT2, iszero(shr(160, amount)))
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    gt(returndatasize(), 0x5f), // Returns 3 words: `amount`, `expiration`, `nonce`.
                    staticcall(gas(), p, add(m, 0x1c), 0x64, add(m, 0x60), 0x60)
                )
            ) {
                mstore(0x00, 0x6b836e6b8757f0fd) // `Permit2Failed()` or `Permit2AmountOverflow()`.
                revert(add(0x18, shl(2, iszero(p))), 0x04)
            }
            mstore(m, 0x2b67b570) // `Permit2.permit` (PermitSingle variant).
            // `owner` is already `add(m, 0x20)`.
            // `token` is already at `add(m, 0x40)`.
            mstore(add(m, 0x60), amount)
            mstore(add(m, 0x80), 0xffffffffffff) // `expiration = type(uint48).max`.
            // `nonce` is already at `add(m, 0xa0)`.
            // `spender` is already at `add(m, 0xc0)`.
            mstore(add(m, 0xe0), deadline)
            mstore(add(m, 0x100), 0x100) // `signature` offset.
            mstore(add(m, 0x120), 0x41) // `signature` length.
            mstore(add(m, 0x140), r)
            mstore(add(m, 0x160), s)
            mstore(add(m, 0x180), shl(248, v))
            if iszero(call(gas(), p, 0, add(m, 0x1c), 0x184, codesize(), 0x00)) {
                mstore(0x00, 0x6b836e6b) // `Permit2Failed()`.
                revert(0x1c, 0x04)
            }
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

// Dependencies
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

// Interfaces
import { IExecutor } from "@interfaces/executors/IExecutor.sol";
import { IExecutorManager } from "@interfaces/admin/IExecutorManager.sol";

/// @title PortikusV1PartnerExecutor
/// @notice A partner executor contract for executing orders on the PortikusV1 protocol
/// @dev This contract is to be implemented by partners to execute orders on the Portikus protocol,
///      it is meant used as a base to allow partners to easily integrate their own contract, while also
///      allowing extensibility and customization.
abstract contract PortikusV1PartnerExecutor is IExecutor, Ownable {
    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/

    /// @notice Error emitted when the caller is not the PortikusV1 contract
    error OnlyPortikus();

    /*//////////////////////////////////////////////////////////////
                               CONSTANTS
    //////////////////////////////////////////////////////////////*/

    /// @notice The address of the PortikusV1 contract
    address public immutable PORTIKUS_V1;

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _owner, address _portikusV1) Ownable(_owner) {
        PORTIKUS_V1 = _portikusV1;
    }

    /*//////////////////////////////////////////////////////////////
                               MODIFIERS
    //////////////////////////////////////////////////////////////*/

    /// @notice Modifier to allow only the PortikusV1 contract to call the function
    modifier onlyPortikus() {
        if (msg.sender != PORTIKUS_V1) {
            revert OnlyPortikus();
        }
        _;
    }

    /*//////////////////////////////////////////////////////////////
                                EXTERNAL
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IExecutor
    function execute(bytes calldata executorData) external virtual onlyPortikus returns (bool success) {
        // Execute the order using the provided data and transfer fees to the fee recipient
        success = _executeCalldataAndTransferFees(executorData);
    }

    /// @notice Updates the authorization status of an agent on the PortikusV1 contract
    /// @param agent The address of the agent to update
    /// @param status The new authorization status
    function updateAgentAuthorization(address agent, bool status) external virtual onlyOwner {
        IExecutorManager(PORTIKUS_V1).updateAgentAuthorization(agent, status);
    }

    /*//////////////////////////////////////////////////////////////
                                INTERNAL
    //////////////////////////////////////////////////////////////*/

    /// @notice Executes the order using the provided data on the executor contract,
    ///         after the execution, transfer optional fees to the fee recipient
    ///         this function should be implemented by the partner executor.
    /// @param executorData The data to execute
    /// @return success A boolean indicating the success of the execution
    function _executeCalldataAndTransferFees(bytes calldata executorData) internal virtual returns (bool success);

    /*//////////////////////////////////////////////////////////////
                                RECEIVE
    //////////////////////////////////////////////////////////////*/

    /// @notice Allows the contract to receive native ETH
    receive() external payable virtual { }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

// Libraries
import { SafeTransferLib } from "@solady/utils/SafeTransferLib.sol";

/// @title PartnerExecutorLib
/// @dev Library with functions that can be reused by PartnerExecutors for PortikusV1
library PartnerExecutorLib {
    /*//////////////////////////////////////////////////////////////
                               LIBRARIES
    //////////////////////////////////////////////////////////////*/

    using SafeTransferLib for address;

    /*//////////////////////////////////////////////////////////////
                               CONSTANTS
    //////////////////////////////////////////////////////////////*/

    /// @notice Native ETH address
    address internal constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    /*//////////////////////////////////////////////////////////////
                                  FEES
    //////////////////////////////////////////////////////////////*/

    /// @dev Transfers ERC20 or native ETH fees to the fee recipient, also transfers native ETH to PortikusV1 if needed
    /// @param portikusV1 The address of the PortikusV1 contract
    /// @param feeRecipient The address to transfer the fees to
    /// @param destToken The address of the dest token
    /// @param feeAmount The amount of fee to transfer
    function transferFeesAndETH(
        address portikusV1,
        address feeRecipient,
        address destToken,
        uint256 feeAmount
    )
        internal
    {
        // If the fee recipient is not set, set it to tx.origin
        feeRecipient = feeRecipient == address(0) ? tx.origin : feeRecipient;
        // If the destToken is ETH, transfer fee amount to the owner,
        // and the remaining balance to the PortikusV1 contract. Otherwise,
        // ERC20 transfer the fee amount to the owner
        if (destToken == ETH_ADDRESS) {
            // Transfer the fee amount  to the fee recipient
            feeRecipient.safeTransferETH(feeAmount);
            // Transfer the remaining balance to the PortikusV1 contract
            portikusV1.safeTransferETH(address(this).balance);
        } else {
            // Transfer the fee amount to the fee recipient or tx.origin if not set
            destToken.safeTransfer(feeRecipient, feeAmount);
        }
    }

    /*//////////////////////////////////////////////////////////////
                               APPROVALS
    //////////////////////////////////////////////////////////////*/

    /// @notice Parses the required approvals from the provided data for the src and dest tokens
    function _parseApprovals(
        uint256 requiredApprovals
    )
        internal
        pure
        returns (bool needSrcApproval, bool needDestApproval)
    {
        needSrcApproval = requiredApprovals & 1 == 1;
        needDestApproval = requiredApprovals & 2 == 2;
    }

    /// @notice Parses the required approvals from the provided data for all tokens in the batch
    /// @param requiredApprovals The required approvals for the batch, the first byte represents the length of tokens,
    /// and the remaining bits represent which tokens need approval. Maximum approval length is 248 tokens. Length
    /// needs to be even.
    function _parseBatchApprovals(uint256 requiredApprovals) internal pure returns (bool[] memory needApproval) {
        // Extract the length from the first byte (8 bits)
        uint256 length = requiredApprovals >> 248; // 256 - 8 = 248

        // Initialize the needApproval array with the extracted length
        needApproval = new bool[](length);

        // Fill the needApproval array based on the bits set in requiredApprovals
        for (uint256 i = 0; i < length; i++) {
            needApproval[i] = (requiredApprovals & (1 << i)) != 0;
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

// Contracts
import { PortikusV1PartnerExecutor } from "@executors/base/PortikusV1PartnerExecutor.sol";

// Interfaces
import { IExecutor } from "@interfaces/executors/IExecutor.sol";
import { IParaswapDelta } from "@executors/delta/interfaces/IParaswapDelta.sol";
import { ISwapSettlementFacet } from "@interfaces/facets/ISwapSettlementFacet.sol";

// Libraries
import { SafeTransferLib } from "@solady/utils/SafeTransferLib.sol";
import { PartnerExecutorLib } from "@executors/base/libraries/PartnerExecutorLib.sol";

// Types
import { SwapOrderWithSig } from "@types/SwapOrder.sol";

/// @title ParaswapDelta
/// @notice An executor contract for PortikusV1 that settles swap orders using the PortikusV1 contract
/// @author Paraswap
contract ParaswapDelta is PortikusV1PartnerExecutor, IParaswapDelta {
    /*//////////////////////////////////////////////////////////////
                               LIBRARIES
    //////////////////////////////////////////////////////////////*/

    using SafeTransferLib for address;
    using PartnerExecutorLib for address;

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _portikusV1, address _owner) PortikusV1PartnerExecutor(_owner, _portikusV1) { }

    /*//////////////////////////////////////////////////////////////
                                EXTERNAL
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IParaswapDelta
    function settleSwap(ParaswapDeltaData calldata data) external {
        // Parse required approvals
        uint256 requiredApprovals = data.requiredApprovals;
        // Approve the src token to be used by the executor when
        // executing the calldata on the execution address
        if (requiredApprovals & 1 == 1) {
            data.orderData.orderWithSig.order.srcToken.safeApproveWithRetry(
                data.orderData.executionAddress, type(uint256).max
            );
        }
        // Approve the dest token to the PortikusV1 contract which is required
        // for the final step of the settlement process where the dest token is
        // transferred to the user
        if (requiredApprovals & 2 == 2) {
            data.orderData.orderWithSig.order.destToken.safeApproveWithRetry(PORTIKUS_V1, type(uint256).max);
        }
        // Pack the executor data
        bytes memory executorData = abi.encode(
            ExecutorData({
                srcToken: data.orderData.orderWithSig.order.srcToken,
                destToken: data.orderData.orderWithSig.order.destToken,
                feeAmount: data.orderData.feeAmount,
                calldataToExecute: data.orderData.calldataToExecute,
                executionAddress: data.orderData.executionAddress,
                feeRecipient: data.feeRecipient
            })
        );
        // Call the PortikusV1 contract with the provided data
        ISwapSettlementFacet(PORTIKUS_V1).settle(data.orderData.orderWithSig, executorData);
    }

    /// @inheritdoc IParaswapDelta
    function settleBatchSwap(ParaswapDeltaBatchData calldata data) external {
        // Parse required approvals
        uint256 requiredApprovals = data.requiredApprovals;
        // Parse fee recipient
        address feeRecipient = data.feeRecipient;
        // Get the requiredApprovals length from the first byte (8 bits)
        uint256 requiredApprovalsLength = requiredApprovals >> 248; // 256 - 8 = 248
        // Cache the length of the orders data
        uint256 ordersDataLength = data.ordersData.length;
        uint256 totalLength = ordersDataLength << 1;
        // Initialize the arrays
        bytes[] memory executorDatas = new bytes[](ordersDataLength);
        SwapOrderWithSig[] memory ordersWithSigs = new SwapOrderWithSig[](ordersDataLength);
        // Approve the tokens if needed
        for (uint256 i; i < totalLength; i += 2) {
            // Get the index of the order
            uint256 j = i >> 1;
            if (i < requiredApprovalsLength) {
                // Check if src token needs approval
                if ((requiredApprovals & (1 << i)) != 0) {
                    // Approve the src token to be used by the executor when
                    // executing the calldata on the execution address
                    data.ordersData[j].orderWithSig.order.srcToken.safeApproveWithRetry(
                        data.ordersData[j].executionAddress, type(uint256).max
                    );
                }
                // Check if dest token needs approval
                if ((requiredApprovals & (1 << i + 1)) != 0) {
                    // Approve the dest token to the PortikusV1 contract which is required
                    // for the final step of the settlement process where the dest token is
                    // transferred to the user
                    data.ordersData[j].orderWithSig.order.destToken.safeApproveWithRetry(PORTIKUS_V1, type(uint256).max);
                }
            }
            // Pack the executor data
            executorDatas[j] = abi.encode(
                ExecutorData({
                    srcToken: data.ordersData[j].orderWithSig.order.srcToken,
                    destToken: data.ordersData[j].orderWithSig.order.destToken,
                    feeAmount: data.ordersData[j].feeAmount,
                    calldataToExecute: data.ordersData[j].calldataToExecute,
                    executionAddress: data.ordersData[j].executionAddress,
                    feeRecipient: feeRecipient
                })
            );
            // Store the order with sig
            ordersWithSigs[j] = data.ordersData[j].orderWithSig;
        }
        // Call the PortikusV1 contract with the provided data
        ISwapSettlementFacet(PORTIKUS_V1).settleBatch(ordersWithSigs, executorDatas);
    }

    /// @inheritdoc IParaswapDelta
    function safeSettleBatchSwap(
        ParaswapDeltaBatchData calldata data
    )
        external
        returns (bool[] memory successfulOrders)
    {
        // Parse required approvals
        uint256 requiredApprovals = data.requiredApprovals;
        // Parse fee recipient
        address feeRecipient = data.feeRecipient;
        // Get the requiredApprovals length from the first byte (8 bits)
        uint256 requiredApprovalsLength = requiredApprovals >> 248; // 256 - 8 = 248
        // Cache the length of the orders data
        uint256 ordersDataLength = data.ordersData.length;
        uint256 totalLength = ordersDataLength << 1;
        // Initialize the successful orders array
        successfulOrders = new bool[](ordersDataLength);
        bool oneSuccess;
        // Iterate through the orders
        for (uint256 i; i < totalLength; i += 2) {
            // Get the index of the order
            uint256 j = i >> 1;
            // Approve the tokens if needed
            if (i < requiredApprovalsLength) {
                // Check if src token needs approval
                if ((requiredApprovals & (1 << i)) != 0) {
                    // Approve the src token to be used by the executor when
                    // executing the calldata on the execution address
                    data.ordersData[j].orderWithSig.order.srcToken.safeApproveWithRetry(
                        data.ordersData[j].executionAddress, type(uint256).max
                    );
                }
                // Check if dest token needs approval
                if ((requiredApprovals & (1 << i + 1)) != 0) {
                    // Approve the dest token to the PortikusV1 contract which is required
                    // for the final step of the settlement process where the dest token is
                    // transferred to the user
                    data.ordersData[j].orderWithSig.order.destToken.safeApproveWithRetry(PORTIKUS_V1, type(uint256).max);
                }
            }
            // Try to settle the order
            try ISwapSettlementFacet(PORTIKUS_V1).settle(
                data.ordersData[j].orderWithSig,
                abi.encode(
                    ExecutorData({
                        srcToken: data.ordersData[j].orderWithSig.order.srcToken,
                        destToken: data.ordersData[j].orderWithSig.order.destToken,
                        feeAmount: data.ordersData[j].feeAmount,
                        calldataToExecute: data.ordersData[j].calldataToExecute,
                        executionAddress: data.ordersData[j].executionAddress,
                        feeRecipient: feeRecipient
                    })
                )
            ) {
                successfulOrders[j] = true;
                oneSuccess = true;
            } catch {
                // Continue with others
            }
        }

        // Revert if all orders failed
        if (!oneSuccess) {
            revert AllOrdersFailed();
        }

        // Return the successful orders
        return successfulOrders;
    }

    /*//////////////////////////////////////////////////////////////
                                INTERNAL
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc PortikusV1PartnerExecutor
    function _executeCalldataAndTransferFees(
        bytes calldata executorData
    )
        internal
        virtual
        override
        returns (bool success)
    {
        // Parse the executor data
        ExecutorData memory data = abi.decode(executorData, (ExecutorData));
        // Revert if execution address is PortikusV1
        if (data.executionAddress == PORTIKUS_V1) {
            revert InvalidExecutionAddress();
        }
        // Execute the swap on the execution address with the provided calldata
        (bool executionSuccess,) = data.executionAddress.call(data.calldataToExecute);
        // Return false if the execution failed
        if (!executionSuccess) {
            return false;
        }
        // Transfer the fee to the fee recipient if needed and ETH if the dest token is ETH
        PORTIKUS_V1.transferFeesAndETH(data.feeRecipient, data.destToken, data.feeAmount);
        // Return true if the execution was successful
        return true;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

// Types
import { SwapOrderWithSig } from "@types/SwapOrder.sol";

/// @title IParaswapDelta
/// @notice Interface for agents to execute swaps through the ParaswapDelta executor
interface IParaswapDelta {
    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/

    /// @notice Emitted when all orders in a batch failed
    error AllOrdersFailed();

    /// @notice Emitted when trying to execute calldata on an invalid address
    error InvalidExecutionAddress();

    /*//////////////////////////////////////////////////////////////
                                STRUCTS
    //////////////////////////////////////////////////////////////*/

    /// @notice SingleOrderData struct, containing the data required to settle a single order through
    /// ParaswapDelta
    struct SingleOrderData {
        // The swap order data used to execute the swap on PortikusV1
        SwapOrderWithSig orderWithSig;
        // The amount of fee to be paid for the swap
        uint256 feeAmount;
        // The calldata to execute the swap
        bytes calldataToExecute;
        // The address to execute the swap at
        address executionAddress;
    }

    /// @notice ParaswapDelta data struct, containing the data required to settle an order through ParaswapDelta
    struct ParaswapDeltaData {
        // Single order data
        SingleOrderData orderData;
        // The address to receive the fee, if not set the tx.origin will receive the fee
        address feeRecipient;
        // Packed data containing the required approvals for the swap, first bit being set means that
        // we need to approve the src token, and if the second bit is set we need to approve the dest token
        uint256 requiredApprovals;
    }

    /// @notice Batch ParaswapDelta data struct, containing the data required to settle multiple orders through
    /// ParaswapDelta
    struct ParaswapDeltaBatchData {
        // An array of single order data
        SingleOrderData[] ordersData;
        // The address to receive the fee, if not set the tx.origin will receive the fee
        address feeRecipient;
        // Packed data containing the required approvals for the swap. The data is packed in the following layout:
        // --------------------------------------------------------------------------------------------------------------
        // | Length of the array (8 bits) | Required approvals (from right to left, 2 bits per order where the first    |
        // |                              | bit is for the src token and the second bit is for the dest token)          |
        // --------------------------------------------------------------------------------------------------------------
        uint256 requiredApprovals;
    }

    /// @notice Executor data struct, containing all data required to execute a swap
    struct ExecutorData {
        // The address of the src token
        address srcToken;
        // The address of the dest token
        address destToken;
        // The amount of fee to be paid for the swap
        uint256 feeAmount;
        // The calldata to execute the swap
        bytes calldataToExecute;
        // The address to execute the swap
        address executionAddress;
        // The address to receive the fee, if not set the tx.origin will receive the fee
        address feeRecipient;
    }

    /*//////////////////////////////////////////////////////////////
                                EXTERNAL
    //////////////////////////////////////////////////////////////*/

    /// @notice Executes a swap on PortikusV1
    /// @param data The data required to execute the swap
    function settleSwap(ParaswapDeltaData calldata data) external;

    /// @notice Executes a batch of swaps on PortikusV1, if one of the orders fails, the function will revert
    /// @param data The data required to execute the batch of swaps
    function settleBatchSwap(ParaswapDeltaBatchData calldata data) external;

    /// @notice Execute a batch of swaps on PortikusV1, ignoring if some of the orders fail, the function will not
    /// revert if at least one of the orders is successful
    /// @param data The data required to execute the batch of swaps
    /// @return successfulOrders An array of booleans indicating if the order was successful or not
    function safeSettleBatchSwap(
        ParaswapDeltaBatchData calldata data
    )
        external
        returns (bool[] memory successfulOrders);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

/// @notice Interface for admin functions of the Portikus protocol
interface IExecutorManager {
    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/

    /// @notice Error when an executor is not authorized
    error ExecutorNotAuthorized();

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    /// @notice Emitted when the authorization of an executor is updated
    event ExecutorAuthorizationUpdated(address indexed executor, bool authorized);

    /// @notice Emitted when an agent's authorization is updated
    event AgentAuthorizationUpdated(address indexed executor, address indexed agent, bool authorized);

    /*//////////////////////////////////////////////////////////////
                                EXTERNAL
    //////////////////////////////////////////////////////////////*/

    /// @notice Update the authorization of an executor
    function updateExecutorAuthorization(address _executor, bool authorized) external;

    /// @notice Update the authorization status of an agent for an executor
    function updateAgentAuthorization(address _agent, bool authorized) external;

    /*//////////////////////////////////////////////////////////////
                                GETTERS
    //////////////////////////////////////////////////////////////*/

    /// @notice Get all authorized agents for an executor
    function getAuthorizedAgents(address _executor) external view returns (address[] memory);

    /// @notice Get the authorization status of an agent for an executor
    function isAgentAuthorized(address _executor, address _agent) external view returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

// Types
import { SwapOrderWithSig } from "@types/SwapOrder.sol";

/// @title IExecutor
/// @notice Interface for executor contracts on Portikus
interface IExecutor {
    /*//////////////////////////////////////////////////////////////
                                EXTERNAL
    //////////////////////////////////////////////////////////////*/

    /// @notice Executes the provided executor data, this function is called by the settle function
    ///        and should be implemented by the executor contract, it is recommend to limit the
    ///        access to this function to the ParaswapUltra contract
    /// @param executorData The data to execute
    /// @return success A boolean indicating the success of the execution
    function execute(bytes calldata executorData) external returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

// Interfaces
import { IBaseSettlement } from "./base/IBaseSettlement.sol";

// Types
import { SwapOrderWithSig } from "@types/SwapOrder.sol";

/// @notice Interface for swap order settlement on Portikus
interface ISwapSettlementFacet is IBaseSettlement {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    /// @notice Emitted when an order is settled
    event OrderSettled(
        address indexed owner,
        address indexed partner,
        address indexed beneficiary,
        address srcToken,
        address destToken,
        uint256 srcAmount,
        uint256 destAmount,
        uint256 receivedAmount
    );

    /*//////////////////////////////////////////////////////////////
                                EXTERNAL
    //////////////////////////////////////////////////////////////*/

    /// @notice Settles an order using the caller's contract as the executor and the
    ///         provided data as the calldata for the execution
    /// @param orderWithSig The order and signature to settle
    /// @param executorData The data to pass to the executor contract
    function settle(SwapOrderWithSig calldata orderWithSig, bytes calldata executorData) external;

    /// @notice Settles a batch of orders using the caller's contract as the executor and the
    ///         provided data as the calldata for the execution
    /// @param ordersWithSigs The orders and signatures to settle
    /// @param executorData An array of data to pass to the executor contract
    function settleBatch(SwapOrderWithSig[] calldata ordersWithSigs, bytes[] calldata executorData) external;

    /// @notice Verifies the order signature
    /// @param orderWithSig The order and signature to validate
    /// @return True if the order is valid, otherwise false
    function verify(SwapOrderWithSig calldata orderWithSig) external view returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

/// @notice Base interface for settlement facets
interface IBaseSettlement { }
// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

/// @dev Order data structure containing the order details to be settled,
///      the order is signed by the owner to be executed by an agent
///      on behalf of the owner, executing the swap and transferring the
///      dest token to the beneficiary
struct SwapOrder {
    /// @dev The address of the order owner
    address owner;
    /// @dev The address of the order beneficiary
    address beneficiary;
    /// @dev The address of the src token
    address srcToken;
    /// @dev The address of the dest token
    address destToken;
    /// @dev The amount of src token to swap
    uint256 srcAmount;
    /// @dev The amount of dest token expected
    uint256 destAmount;
    /// @dev The deadline for the order
    uint256 deadline;
    /// @dev The nonce of the order
    uint256 nonce;
    /// @dev Optional permit signature for the src token
    bytes permit;
}

/// @dev SwapOrder with signature
struct SwapOrderWithSig {
    /// @dev The order data
    SwapOrder order;
    /// @dev The signature of the order
    bytes signature;
}