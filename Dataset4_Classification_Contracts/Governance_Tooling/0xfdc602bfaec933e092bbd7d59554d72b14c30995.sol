// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Simple single owner authorization mixin.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/auth/Ownable.sol)
///
/// @dev Note:
/// This implementation does NOT auto-initialize the owner to `msg.sender`.
/// You MUST call the `_initializeOwner` in the constructor / initializer.
///
/// While the ownable portion follows
/// [EIP-173](https://eips.ethereum.org/EIPS/eip-173) for compatibility,
/// the nomenclature for the 2-step ownership handover may be unique to this codebase.
abstract contract Ownable {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       CUSTOM ERRORS                        */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The caller is not authorized to call the function.
    error Unauthorized();

    /// @dev The `newOwner` cannot be the zero address.
    error NewOwnerIsZeroAddress();

    /// @dev The `pendingOwner` does not have a valid handover request.
    error NoHandoverRequest();

    /// @dev Cannot double-initialize.
    error AlreadyInitialized();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                           EVENTS                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The ownership is transferred from `oldOwner` to `newOwner`.
    /// This event is intentionally kept the same as OpenZeppelin's Ownable to be
    /// compatible with indexers and [EIP-173](https://eips.ethereum.org/EIPS/eip-173),
    /// despite it not being as lightweight as a single argument event.
    event OwnershipTransferred(
        address indexed oldOwner,
        address indexed newOwner
    );

    /// @dev An ownership handover to `pendingOwner` has been requested.
    event OwnershipHandoverRequested(address indexed pendingOwner);

    /// @dev The ownership handover to `pendingOwner` has been canceled.
    event OwnershipHandoverCanceled(address indexed pendingOwner);

    /// @dev `keccak256(bytes("OwnershipTransferred(address,address)"))`.
    uint256 private constant _OWNERSHIP_TRANSFERRED_EVENT_SIGNATURE =
        0x8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e0;

    /// @dev `keccak256(bytes("OwnershipHandoverRequested(address)"))`.
    uint256 private constant _OWNERSHIP_HANDOVER_REQUESTED_EVENT_SIGNATURE =
        0xdbf36a107da19e49527a7176a1babf963b4b0ff8cde35ee35d6cd8f1f9ac7e1d;

    /// @dev `keccak256(bytes("OwnershipHandoverCanceled(address)"))`.
    uint256 private constant _OWNERSHIP_HANDOVER_CANCELED_EVENT_SIGNATURE =
        0xfa7b8eab7da67f412cc9575ed43464468f9bfbae89d1675917346ca6d8fe3c92;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                          STORAGE                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The owner slot is given by:
    /// `bytes32(~uint256(uint32(bytes4(keccak256("_OWNER_SLOT_NOT")))))`.
    /// It is intentionally chosen to be a high value
    /// to avoid collision with lower slots.
    /// The choice of manual storage layout is to enable compatibility
    /// with both regular and upgradeable contracts.
    bytes32 internal constant _OWNER_SLOT =
        0xffffffffffffffffffffffffffffffffffffffffffffffffffffffff74873927;

    /// The ownership handover slot of `newOwner` is given by:
    /// ```
    ///     mstore(0x00, or(shl(96, user), _HANDOVER_SLOT_SEED))
    ///     let handoverSlot := keccak256(0x00, 0x20)
    /// ```
    /// It stores the expiry timestamp of the two-step ownership handover.
    uint256 private constant _HANDOVER_SLOT_SEED = 0x389a75e1;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                     INTERNAL FUNCTIONS                     */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Override to return true to make `_initializeOwner` prevent double-initialization.
    function _guardInitializeOwner()
        internal
        pure
        virtual
        returns (bool guard)
    {}

    /// @dev Initializes the owner directly without authorization guard.
    /// This function must be called upon initialization,
    /// regardless of whether the contract is upgradeable or not.
    /// This is to enable generalization to both regular and upgradeable contracts,
    /// and to save gas in case the initial owner is not the caller.
    /// For performance reasons, this function will not check if there
    /// is an existing owner.
    function _initializeOwner(address newOwner) internal virtual {
        if (_guardInitializeOwner()) {
            /// @solidity memory-safe-assembly
            assembly {
                let ownerSlot := _OWNER_SLOT
                if sload(ownerSlot) {
                    mstore(0x00, 0x0dc149f0) // `AlreadyInitialized()`.
                    revert(0x1c, 0x04)
                }
                // Clean the upper 96 bits.
                newOwner := shr(96, shl(96, newOwner))
                // Store the new value.
                sstore(ownerSlot, or(newOwner, shl(255, iszero(newOwner))))
                // Emit the {OwnershipTransferred} event.
                log3(0, 0, _OWNERSHIP_TRANSFERRED_EVENT_SIGNATURE, 0, newOwner)
            }
        } else {
            /// @solidity memory-safe-assembly
            assembly {
                // Clean the upper 96 bits.
                newOwner := shr(96, shl(96, newOwner))
                // Store the new value.
                sstore(_OWNER_SLOT, newOwner)
                // Emit the {OwnershipTransferred} event.
                log3(0, 0, _OWNERSHIP_TRANSFERRED_EVENT_SIGNATURE, 0, newOwner)
            }
        }
    }

    /// @dev Sets the owner directly without authorization guard.
    function _setOwner(address newOwner) internal virtual {
        if (_guardInitializeOwner()) {
            /// @solidity memory-safe-assembly
            assembly {
                let ownerSlot := _OWNER_SLOT
                // Clean the upper 96 bits.
                newOwner := shr(96, shl(96, newOwner))
                // Emit the {OwnershipTransferred} event.
                log3(
                    0,
                    0,
                    _OWNERSHIP_TRANSFERRED_EVENT_SIGNATURE,
                    sload(ownerSlot),
                    newOwner
                )
                // Store the new value.
                sstore(ownerSlot, or(newOwner, shl(255, iszero(newOwner))))
            }
        } else {
            /// @solidity memory-safe-assembly
            assembly {
                let ownerSlot := _OWNER_SLOT
                // Clean the upper 96 bits.
                newOwner := shr(96, shl(96, newOwner))
                // Emit the {OwnershipTransferred} event.
                log3(
                    0,
                    0,
                    _OWNERSHIP_TRANSFERRED_EVENT_SIGNATURE,
                    sload(ownerSlot),
                    newOwner
                )
                // Store the new value.
                sstore(ownerSlot, newOwner)
            }
        }
    }

    /// @dev Throws if the sender is not the owner.
    function _checkOwner() internal view virtual {
        /// @solidity memory-safe-assembly
        assembly {
            // If the caller is not the stored owner, revert.
            if iszero(eq(caller(), sload(_OWNER_SLOT))) {
                mstore(0x00, 0x82b42900) // `Unauthorized()`.
                revert(0x1c, 0x04)
            }
        }
    }

    /// @dev Returns how long a two-step ownership handover is valid for in seconds.
    /// Override to return a different value if needed.
    /// Made internal to conserve bytecode. Wrap it in a public function if needed.
    function _ownershipHandoverValidFor()
        internal
        view
        virtual
        returns (uint64)
    {
        return 48 * 3600;
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                  PUBLIC UPDATE FUNCTIONS                   */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Allows the owner to transfer the ownership to `newOwner`.
    function transferOwnership(
        address newOwner
    ) public payable virtual onlyOwner {
        /// @solidity memory-safe-assembly
        assembly {
            if iszero(shl(96, newOwner)) {
                mstore(0x00, 0x7448fbae) // `NewOwnerIsZeroAddress()`.
                revert(0x1c, 0x04)
            }
        }
        _setOwner(newOwner);
    }

    /// @dev Allows the owner to renounce their ownership.
    function renounceOwnership() public payable virtual onlyOwner {
        _setOwner(address(0));
    }

    /// @dev Request a two-step ownership handover to the caller.
    /// The request will automatically expire in 48 hours (172800 seconds) by default.
    function requestOwnershipHandover() public payable virtual {
        unchecked {
            uint256 expires = block.timestamp + _ownershipHandoverValidFor();
            /// @solidity memory-safe-assembly
            assembly {
                // Compute and set the handover slot to `expires`.
                mstore(0x0c, _HANDOVER_SLOT_SEED)
                mstore(0x00, caller())
                sstore(keccak256(0x0c, 0x20), expires)
                // Emit the {OwnershipHandoverRequested} event.
                log2(
                    0,
                    0,
                    _OWNERSHIP_HANDOVER_REQUESTED_EVENT_SIGNATURE,
                    caller()
                )
            }
        }
    }

    /// @dev Cancels the two-step ownership handover to the caller, if any.
    function cancelOwnershipHandover() public payable virtual {
        /// @solidity memory-safe-assembly
        assembly {
            // Compute and set the handover slot to 0.
            mstore(0x0c, _HANDOVER_SLOT_SEED)
            mstore(0x00, caller())
            sstore(keccak256(0x0c, 0x20), 0)
            // Emit the {OwnershipHandoverCanceled} event.
            log2(0, 0, _OWNERSHIP_HANDOVER_CANCELED_EVENT_SIGNATURE, caller())
        }
    }

    /// @dev Allows the owner to complete the two-step ownership handover to `pendingOwner`.
    /// Reverts if there is no existing ownership handover requested by `pendingOwner`.
    function completeOwnershipHandover(
        address pendingOwner
    ) public payable virtual onlyOwner {
        /// @solidity memory-safe-assembly
        assembly {
            // Compute and set the handover slot to 0.
            mstore(0x0c, _HANDOVER_SLOT_SEED)
            mstore(0x00, pendingOwner)
            let handoverSlot := keccak256(0x0c, 0x20)
            // If the handover does not exist, or has expired.
            if gt(timestamp(), sload(handoverSlot)) {
                mstore(0x00, 0x6f5e8818) // `NoHandoverRequest()`.
                revert(0x1c, 0x04)
            }
            // Set the handover slot to 0.
            sstore(handoverSlot, 0)
        }
        _setOwner(pendingOwner);
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                   PUBLIC READ FUNCTIONS                    */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns the owner of the contract.
    function owner() public view virtual returns (address result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := sload(_OWNER_SLOT)
        }
    }

    /// @dev Returns the expiry timestamp for the two-step ownership handover to `pendingOwner`.
    function ownershipHandoverExpiresAt(
        address pendingOwner
    ) public view virtual returns (uint256 result) {
        /// @solidity memory-safe-assembly
        assembly {
            // Compute the handover slot.
            mstore(0x0c, _HANDOVER_SLOT_SEED)
            mstore(0x00, pendingOwner)
            // Load the handover slot.
            result := sload(keccak256(0x0c, 0x20))
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         MODIFIERS                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Marks a function as only callable by the owner.
    modifier onlyOwner() virtual {
        _checkOwner();
        _;
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

/// @notice Safe ETH and ERC20 transfer library that gracefully handles missing return values.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/SafeTransferLib.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/SafeTransferLib.sol)
/// @author Permit2 operations from (https://github.com/Uniswap/permit2/blob/main/src/libraries/Permit2Lib.sol)
///
/// @dev Note:
/// - For ETH transfers, please use `forceSafeTransferETH` for DoS protection.
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

    /// @dev The ERC20 `totalSupply` query has failed.
    error TotalSupplyQueryFailed();

    /// @dev The Permit2 operation has failed.
    error Permit2Failed();

    /// @dev The Permit2 amount must be less than `2**160 - 1`.
    error Permit2AmountOverflow();

    /// @dev The Permit2 approve operation has failed.
    error Permit2ApproveFailed();

    /// @dev The Permit2 lockdown operation has failed.
    error Permit2LockdownFailed();

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
            let success := call(gas(), token, 0, 0x1c, 0x64, 0x00, 0x20)
            if iszero(and(eq(mload(0x00), 1), success)) {
                if iszero(lt(or(iszero(extcodesize(token)), returndatasize()), success)) {
                    mstore(0x00, 0x7939f424) // `TransferFromFailed()`.
                    revert(0x1c, 0x04)
                }
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
            success := call(gas(), token, 0, 0x1c, 0x64, 0x00, 0x20)
            if iszero(and(eq(mload(0x00), 1), success)) {
                success := lt(or(iszero(extcodesize(token)), returndatasize()), success)
            }
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
            let success := call(gas(), token, 0, 0x1c, 0x64, 0x00, 0x20)
            if iszero(and(eq(mload(0x00), 1), success)) {
                if iszero(lt(or(iszero(extcodesize(token)), returndatasize()), success)) {
                    mstore(0x00, 0x7939f424) // `TransferFromFailed()`.
                    revert(0x1c, 0x04)
                }
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
            let success := call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
            if iszero(and(eq(mload(0x00), 1), success)) {
                if iszero(lt(or(iszero(extcodesize(token)), returndatasize()), success)) {
                    mstore(0x00, 0x90b8ec18) // `TransferFailed()`.
                    revert(0x1c, 0x04)
                }
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
            let success := call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
            if iszero(and(eq(mload(0x00), 1), success)) {
                if iszero(lt(or(iszero(extcodesize(token)), returndatasize()), success)) {
                    mstore(0x00, 0x90b8ec18) // `TransferFailed()`.
                    revert(0x1c, 0x04)
                }
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
            let success := call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
            if iszero(and(eq(mload(0x00), 1), success)) {
                if iszero(lt(or(iszero(extcodesize(token)), returndatasize()), success)) {
                    mstore(0x00, 0x3e3f8f73) // `ApproveFailed()`.
                    revert(0x1c, 0x04)
                }
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
            let success := call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
            if iszero(and(eq(mload(0x00), 1), success)) {
                if iszero(lt(or(iszero(extcodesize(token)), returndatasize()), success)) {
                    mstore(0x34, 0) // Store 0 for the `amount`.
                    mstore(0x00, 0x095ea7b3000000000000000000000000) // `approve(address,uint256)`.
                    pop(call(gas(), token, 0, 0x10, 0x44, codesize(), 0x00)) // Reset the approval.
                    mstore(0x34, amount) // Store back the original `amount`.
                    // Retry the approval, reverting upon failure.
                    success := call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                    if iszero(and(eq(mload(0x00), 1), success)) {
                        // Check the `extcodesize` again just in case the token selfdestructs lol.
                        if iszero(lt(or(iszero(extcodesize(token)), returndatasize()), success)) {
                            mstore(0x00, 0x3e3f8f73) // `ApproveFailed()`.
                            revert(0x1c, 0x04)
                        }
                    }
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

    /// @dev Returns the total supply of the `token`.
    /// Reverts if the token does not exist or does not implement `totalSupply()`.
    function totalSupply(address token) internal view returns (uint256 result) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, 0x18160ddd) // `totalSupply()`.
            if iszero(
                and(gt(returndatasize(), 0x1f), staticcall(gas(), token, 0x1c, 0x04, 0x00, 0x20))
            ) {
                mstore(0x00, 0x54cd9435) // `TotalSupplyQueryFailed()`.
                revert(0x1c, 0x04)
            }
            result := mload(0x00)
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
            if iszero(
                and(
                    call(gas(), p, 0, add(m, 0x10), 0x84, codesize(), 0x00),
                    lt(iszero(extcodesize(token)), exists) // Token has code and Permit2 exists.
                )
            ) {
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
                    mstore(
                        add(m, 0x94),
                        lt(iszero(amount), staticcall(gas(), token, 0x10, 0x24, add(m, 0x54), 0x20))
                    )
                    mstore(m, 0x8fcbaf0c000000000000000000000000) // `IDAIPermit.permit`.
                    // `nonces` is already at `add(m, 0x54)`.
                    // `amount != 0` is already stored at `add(m, 0x94)`.
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
            if iszero( // Revert if token does not have code, or if the call fails.
            mul(extcodesize(token), call(gas(), p, 0, add(m, 0x1c), 0x184, codesize(), 0x00))) {
                mstore(0x00, 0x6b836e6b) // `Permit2Failed()`.
                revert(0x1c, 0x04)
            }
        }
    }

    /// @dev Approves `spender` to spend `amount` of `token` for `address(this)`.
    function permit2Approve(address token, address spender, uint160 amount, uint48 expiration)
        internal
    {
        /// @solidity memory-safe-assembly
        assembly {
            let addressMask := shr(96, not(0))
            let m := mload(0x40)
            mstore(m, 0x87517c45) // `approve(address,address,uint160,uint48)`.
            mstore(add(m, 0x20), and(addressMask, token))
            mstore(add(m, 0x40), and(addressMask, spender))
            mstore(add(m, 0x60), and(addressMask, amount))
            mstore(add(m, 0x80), and(0xffffffffffff, expiration))
            if iszero(call(gas(), PERMIT2, 0, add(m, 0x1c), 0xa0, codesize(), 0x00)) {
                mstore(0x00, 0x324f14ae) // `Permit2ApproveFailed()`.
                revert(0x1c, 0x04)
            }
        }
    }

    /// @dev Revokes an approval for `token` and `spender` for `address(this)`.
    function permit2Lockdown(address token, address spender) internal {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40)
            mstore(m, 0xcc53287f) // `Permit2.lockdown`.
            mstore(add(m, 0x20), 0x20) // Offset of the `approvals`.
            mstore(add(m, 0x40), 1) // `approvals.length`.
            mstore(add(m, 0x60), shr(96, shl(96, token)))
            mstore(add(m, 0x80), shr(96, shl(96, spender)))
            if iszero(call(gas(), PERMIT2, 0, add(m, 0x1c), 0xa0, codesize(), 0x00)) {
                mstore(0x00, 0x96b3de23) // `Permit2LockdownFailed()`.
                revert(0x1c, 0x04)
            }
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Signature verification helper that supports both ECDSA signatures from EOAs
/// and ERC1271 signatures from smart contract wallets like Argent and Gnosis safe.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/SignatureCheckerLib.sol)
/// @author Modified from OpenZeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/cryptography/SignatureChecker.sol)
///
/// @dev Note:
/// - The signature checking functions use the ecrecover precompile (0x1).
/// - The `bytes memory signature` variants use the identity precompile (0x4)
///   to copy memory internally.
/// - Unlike ECDSA signatures, contract signatures are revocable.
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
library SignatureCheckerLib {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*               SIGNATURE CHECKING OPERATIONS                */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns whether `signature` is valid for `signer` and `hash`.
    /// If `signer.code.length == 0`, then validate with `ecrecover`, else
    /// it will validate with ERC1271 on `signer`.
    function isValidSignatureNow(address signer, bytes32 hash, bytes memory signature)
        internal
        view
        returns (bool isValid)
    {
        if (signer == address(0)) return isValid;
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40)
            for {} 1 {} {
                if iszero(extcodesize(signer)) {
                    switch mload(signature)
                    case 64 {
                        let vs := mload(add(signature, 0x40))
                        mstore(0x20, add(shr(255, vs), 27)) // `v`.
                        mstore(0x60, shr(1, shl(1, vs))) // `s`.
                    }
                    case 65 {
                        mstore(0x20, byte(0, mload(add(signature, 0x60)))) // `v`.
                        mstore(0x60, mload(add(signature, 0x40))) // `s`.
                    }
                    default { break }
                    mstore(0x00, hash)
                    mstore(0x40, mload(add(signature, 0x20))) // `r`.
                    let recovered := mload(staticcall(gas(), 1, 0x00, 0x80, 0x01, 0x20))
                    isValid := gt(returndatasize(), shl(96, xor(signer, recovered)))
                    mstore(0x60, 0) // Restore the zero slot.
                    mstore(0x40, m) // Restore the free memory pointer.
                    break
                }
                let f := shl(224, 0x1626ba7e)
                mstore(m, f) // `bytes4(keccak256("isValidSignature(bytes32,bytes)"))`.
                mstore(add(m, 0x04), hash)
                let d := add(m, 0x24)
                mstore(d, 0x40) // The offset of the `signature` in the calldata.
                // Copy the `signature` over.
                let n := add(0x20, mload(signature))
                let copied := staticcall(gas(), 4, signature, n, add(m, 0x44), n)
                isValid := staticcall(gas(), signer, m, add(returndatasize(), 0x44), d, 0x20)
                isValid := and(eq(mload(d), f), and(isValid, copied))
                break
            }
        }
    }

    /// @dev Returns whether `signature` is valid for `signer` and `hash`.
    /// If `signer.code.length == 0`, then validate with `ecrecover`, else
    /// it will validate with ERC1271 on `signer`.
    function isValidSignatureNowCalldata(address signer, bytes32 hash, bytes calldata signature)
        internal
        view
        returns (bool isValid)
    {
        if (signer == address(0)) return isValid;
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40)
            for {} 1 {} {
                if iszero(extcodesize(signer)) {
                    switch signature.length
                    case 64 {
                        let vs := calldataload(add(signature.offset, 0x20))
                        mstore(0x20, add(shr(255, vs), 27)) // `v`.
                        mstore(0x40, calldataload(signature.offset)) // `r`.
                        mstore(0x60, shr(1, shl(1, vs))) // `s`.
                    }
                    case 65 {
                        mstore(0x20, byte(0, calldataload(add(signature.offset, 0x40)))) // `v`.
                        calldatacopy(0x40, signature.offset, 0x40) // `r`, `s`.
                    }
                    default { break }
                    mstore(0x00, hash)
                    let recovered := mload(staticcall(gas(), 1, 0x00, 0x80, 0x01, 0x20))
                    isValid := gt(returndatasize(), shl(96, xor(signer, recovered)))
                    mstore(0x60, 0) // Restore the zero slot.
                    mstore(0x40, m) // Restore the free memory pointer.
                    break
                }
                let f := shl(224, 0x1626ba7e)
                mstore(m, f) // `bytes4(keccak256("isValidSignature(bytes32,bytes)"))`.
                mstore(add(m, 0x04), hash)
                let d := add(m, 0x24)
                mstore(d, 0x40) // The offset of the `signature` in the calldata.
                mstore(add(m, 0x44), signature.length)
                // Copy the `signature` over.
                calldatacopy(add(m, 0x64), signature.offset, signature.length)
                isValid := staticcall(gas(), signer, m, add(signature.length, 0x64), d, 0x20)
                isValid := and(eq(mload(d), f), isValid)
                break
            }
        }
    }

    /// @dev Returns whether the signature (`r`, `vs`) is valid for `signer` and `hash`.
    /// If `signer.code.length == 0`, then validate with `ecrecover`, else
    /// it will validate with ERC1271 on `signer`.
    function isValidSignatureNow(address signer, bytes32 hash, bytes32 r, bytes32 vs)
        internal
        view
        returns (bool isValid)
    {
        if (signer == address(0)) return isValid;
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40)
            for {} 1 {} {
                if iszero(extcodesize(signer)) {
                    mstore(0x00, hash)
                    mstore(0x20, add(shr(255, vs), 27)) // `v`.
                    mstore(0x40, r) // `r`.
                    mstore(0x60, shr(1, shl(1, vs))) // `s`.
                    let recovered := mload(staticcall(gas(), 1, 0x00, 0x80, 0x01, 0x20))
                    isValid := gt(returndatasize(), shl(96, xor(signer, recovered)))
                    mstore(0x60, 0) // Restore the zero slot.
                    mstore(0x40, m) // Restore the free memory pointer.
                    break
                }
                let f := shl(224, 0x1626ba7e)
                mstore(m, f) // `bytes4(keccak256("isValidSignature(bytes32,bytes)"))`.
                mstore(add(m, 0x04), hash)
                let d := add(m, 0x24)
                mstore(d, 0x40) // The offset of the `signature` in the calldata.
                mstore(add(m, 0x44), 65) // Length of the signature.
                mstore(add(m, 0x64), r) // `r`.
                mstore(add(m, 0x84), shr(1, shl(1, vs))) // `s`.
                mstore8(add(m, 0xa4), add(shr(255, vs), 27)) // `v`.
                isValid := staticcall(gas(), signer, m, 0xa5, d, 0x20)
                isValid := and(eq(mload(d), f), isValid)
                break
            }
        }
    }

    /// @dev Returns whether the signature (`v`, `r`, `s`) is valid for `signer` and `hash`.
    /// If `signer.code.length == 0`, then validate with `ecrecover`, else
    /// it will validate with ERC1271 on `signer`.
    function isValidSignatureNow(address signer, bytes32 hash, uint8 v, bytes32 r, bytes32 s)
        internal
        view
        returns (bool isValid)
    {
        if (signer == address(0)) return isValid;
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40)
            for {} 1 {} {
                if iszero(extcodesize(signer)) {
                    mstore(0x00, hash)
                    mstore(0x20, and(v, 0xff)) // `v`.
                    mstore(0x40, r) // `r`.
                    mstore(0x60, s) // `s`.
                    let recovered := mload(staticcall(gas(), 1, 0x00, 0x80, 0x01, 0x20))
                    isValid := gt(returndatasize(), shl(96, xor(signer, recovered)))
                    mstore(0x60, 0) // Restore the zero slot.
                    mstore(0x40, m) // Restore the free memory pointer.
                    break
                }
                let f := shl(224, 0x1626ba7e)
                mstore(m, f) // `bytes4(keccak256("isValidSignature(bytes32,bytes)"))`.
                mstore(add(m, 0x04), hash)
                let d := add(m, 0x24)
                mstore(d, 0x40) // The offset of the `signature` in the calldata.
                mstore(add(m, 0x44), 65) // Length of the signature.
                mstore(add(m, 0x64), r) // `r`.
                mstore(add(m, 0x84), s) // `s`.
                mstore8(add(m, 0xa4), v) // `v`.
                isValid := staticcall(gas(), signer, m, 0xa5, d, 0x20)
                isValid := and(eq(mload(d), f), isValid)
                break
            }
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                     ERC1271 OPERATIONS                     */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // Note: These ERC1271 operations do NOT have an ECDSA fallback.

    /// @dev Returns whether `signature` is valid for `hash` for an ERC1271 `signer` contract.
    function isValidERC1271SignatureNow(address signer, bytes32 hash, bytes memory signature)
        internal
        view
        returns (bool isValid)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40)
            let f := shl(224, 0x1626ba7e)
            mstore(m, f) // `bytes4(keccak256("isValidSignature(bytes32,bytes)"))`.
            mstore(add(m, 0x04), hash)
            let d := add(m, 0x24)
            mstore(d, 0x40) // The offset of the `signature` in the calldata.
            // Copy the `signature` over.
            let n := add(0x20, mload(signature))
            let copied := staticcall(gas(), 4, signature, n, add(m, 0x44), n)
            isValid := staticcall(gas(), signer, m, add(returndatasize(), 0x44), d, 0x20)
            isValid := and(eq(mload(d), f), and(isValid, copied))
        }
    }

    /// @dev Returns whether `signature` is valid for `hash` for an ERC1271 `signer` contract.
    function isValidERC1271SignatureNowCalldata(
        address signer,
        bytes32 hash,
        bytes calldata signature
    ) internal view returns (bool isValid) {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40)
            let f := shl(224, 0x1626ba7e)
            mstore(m, f) // `bytes4(keccak256("isValidSignature(bytes32,bytes)"))`.
            mstore(add(m, 0x04), hash)
            let d := add(m, 0x24)
            mstore(d, 0x40) // The offset of the `signature` in the calldata.
            mstore(add(m, 0x44), signature.length)
            // Copy the `signature` over.
            calldatacopy(add(m, 0x64), signature.offset, signature.length)
            isValid := staticcall(gas(), signer, m, add(signature.length, 0x64), d, 0x20)
            isValid := and(eq(mload(d), f), isValid)
        }
    }

    /// @dev Returns whether the signature (`r`, `vs`) is valid for `hash`
    /// for an ERC1271 `signer` contract.
    function isValidERC1271SignatureNow(address signer, bytes32 hash, bytes32 r, bytes32 vs)
        internal
        view
        returns (bool isValid)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40)
            let f := shl(224, 0x1626ba7e)
            mstore(m, f) // `bytes4(keccak256("isValidSignature(bytes32,bytes)"))`.
            mstore(add(m, 0x04), hash)
            let d := add(m, 0x24)
            mstore(d, 0x40) // The offset of the `signature` in the calldata.
            mstore(add(m, 0x44), 65) // Length of the signature.
            mstore(add(m, 0x64), r) // `r`.
            mstore(add(m, 0x84), shr(1, shl(1, vs))) // `s`.
            mstore8(add(m, 0xa4), add(shr(255, vs), 27)) // `v`.
            isValid := staticcall(gas(), signer, m, 0xa5, d, 0x20)
            isValid := and(eq(mload(d), f), isValid)
        }
    }

    /// @dev Returns whether the signature (`v`, `r`, `s`) is valid for `hash`
    /// for an ERC1271 `signer` contract.
    function isValidERC1271SignatureNow(address signer, bytes32 hash, uint8 v, bytes32 r, bytes32 s)
        internal
        view
        returns (bool isValid)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40)
            let f := shl(224, 0x1626ba7e)
            mstore(m, f) // `bytes4(keccak256("isValidSignature(bytes32,bytes)"))`.
            mstore(add(m, 0x04), hash)
            let d := add(m, 0x24)
            mstore(d, 0x40) // The offset of the `signature` in the calldata.
            mstore(add(m, 0x44), 65) // Length of the signature.
            mstore(add(m, 0x64), r) // `r`.
            mstore(add(m, 0x84), s) // `s`.
            mstore8(add(m, 0xa4), v) // `v`.
            isValid := staticcall(gas(), signer, m, 0xa5, d, 0x20)
            isValid := and(eq(mload(d), f), isValid)
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                     ERC6492 OPERATIONS                     */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // Note: These ERC6492 operations now include an ECDSA fallback at the very end.
    // The calldata variants are excluded for brevity.

    /// @dev Returns whether `signature` is valid for `hash`.
    /// If the signature is postfixed with the ERC6492 magic number, it will attempt to
    /// deploy / prepare the `signer` smart account before doing a regular ERC1271 check.
    /// Note: This function is NOT reentrancy safe.
    /// The verifier must be deployed.
    /// Otherwise, the function will return false if `signer` is not yet deployed / prepared.
    /// See: https://gist.github.com/Vectorized/011d6becff6e0a73e42fe100f8d7ef04
    /// With a dedicated verifier, this function is safe to use in contracts
    /// that have been granted special permissions.
    function isValidERC6492SignatureNowAllowSideEffects(
        address signer,
        bytes32 hash,
        bytes memory signature
    ) internal returns (bool isValid) {
        /// @solidity memory-safe-assembly
        assembly {
            function callIsValidSignature(signer_, hash_, signature_) -> _isValid {
                let m_ := mload(0x40)
                let f_ := shl(224, 0x1626ba7e)
                mstore(m_, f_) // `bytes4(keccak256("isValidSignature(bytes32,bytes)"))`.
                mstore(add(m_, 0x04), hash_)
                let d_ := add(m_, 0x24)
                mstore(d_, 0x40) // The offset of the `signature` in the calldata.
                let n_ := add(0x20, mload(signature_))
                let copied_ := staticcall(gas(), 4, signature_, n_, add(m_, 0x44), n_)
                _isValid := staticcall(gas(), signer_, m_, add(returndatasize(), 0x44), d_, 0x20)
                _isValid := and(eq(mload(d_), f_), and(_isValid, copied_))
            }
            let noCode := iszero(extcodesize(signer))
            let n := mload(signature)
            for {} 1 {} {
                if iszero(eq(mload(add(signature, n)), mul(0x6492, div(not(isValid), 0xffff)))) {
                    if iszero(noCode) { isValid := callIsValidSignature(signer, hash, signature) }
                    break
                }
                if iszero(noCode) {
                    let o := add(signature, 0x20) // Signature bytes.
                    isValid := callIsValidSignature(signer, hash, add(o, mload(add(o, 0x40))))
                    if isValid { break }
                }
                let m := mload(0x40)
                mstore(m, signer)
                mstore(add(m, 0x20), hash)
                pop(
                    call(
                        gas(), // Remaining gas.
                        0x0000bc370E4DC924F427d84e2f4B9Ec81626ba7E, // Non-reverting verifier.
                        0, // Send zero ETH.
                        m, // Start of memory.
                        add(returndatasize(), 0x40), // Length of calldata in memory.
                        staticcall(gas(), 4, add(signature, 0x20), n, add(m, 0x40), n), // 1.
                        0x00 // Length of returndata to write.
                    )
                )
                isValid := returndatasize()
                break
            }
            // Do `ecrecover` fallback if `noCode && !isValid`.
            for {} gt(noCode, isValid) {} {
                switch n
                case 64 {
                    let vs := mload(add(signature, 0x40))
                    mstore(0x20, add(shr(255, vs), 27)) // `v`.
                    mstore(0x60, shr(1, shl(1, vs))) // `s`.
                }
                case 65 {
                    mstore(0x20, byte(0, mload(add(signature, 0x60)))) // `v`.
                    mstore(0x60, mload(add(signature, 0x40))) // `s`.
                }
                default { break }
                let m := mload(0x40)
                mstore(0x00, hash)
                mstore(0x40, mload(add(signature, 0x20))) // `r`.
                let recovered := mload(staticcall(gas(), 1, 0x00, 0x80, 0x01, 0x20))
                isValid := gt(returndatasize(), shl(96, xor(signer, recovered)))
                mstore(0x60, 0) // Restore the zero slot.
                mstore(0x40, m) // Restore the free memory pointer.
                break
            }
        }
    }

    /// @dev Returns whether `signature` is valid for `hash`.
    /// If the signature is postfixed with the ERC6492 magic number, it will attempt
    /// to use a reverting verifier to deploy / prepare the `signer` smart account
    /// and do a `isValidSignature` check via the reverting verifier.
    /// Note: This function is reentrancy safe.
    /// The reverting verifier must be deployed.
    /// Otherwise, the function will return false if `signer` is not yet deployed / prepared.
    /// See: https://gist.github.com/Vectorized/846a474c855eee9e441506676800a9ad
    function isValidERC6492SignatureNow(address signer, bytes32 hash, bytes memory signature)
        internal
        returns (bool isValid)
    {
        /// @solidity memory-safe-assembly
        assembly {
            function callIsValidSignature(signer_, hash_, signature_) -> _isValid {
                let m_ := mload(0x40)
                let f_ := shl(224, 0x1626ba7e)
                mstore(m_, f_) // `bytes4(keccak256("isValidSignature(bytes32,bytes)"))`.
                mstore(add(m_, 0x04), hash_)
                let d_ := add(m_, 0x24)
                mstore(d_, 0x40) // The offset of the `signature` in the calldata.
                let n_ := add(0x20, mload(signature_))
                let copied_ := staticcall(gas(), 4, signature_, n_, add(m_, 0x44), n_)
                _isValid := staticcall(gas(), signer_, m_, add(returndatasize(), 0x44), d_, 0x20)
                _isValid := and(eq(mload(d_), f_), and(_isValid, copied_))
            }
            let noCode := iszero(extcodesize(signer))
            let n := mload(signature)
            for {} 1 {} {
                if iszero(eq(mload(add(signature, n)), mul(0x6492, div(not(isValid), 0xffff)))) {
                    if iszero(noCode) { isValid := callIsValidSignature(signer, hash, signature) }
                    break
                }
                if iszero(noCode) {
                    let o := add(signature, 0x20) // Signature bytes.
                    isValid := callIsValidSignature(signer, hash, add(o, mload(add(o, 0x40))))
                    if isValid { break }
                }
                let m := mload(0x40)
                mstore(m, signer)
                mstore(add(m, 0x20), hash)
                let willBeZeroIfRevertingVerifierExists :=
                    call(
                        gas(), // Remaining gas.
                        0x00007bd799e4A591FeA53f8A8a3E9f931626Ba7e, // Reverting verifier.
                        0, // Send zero ETH.
                        m, // Start of memory.
                        add(returndatasize(), 0x40), // Length of calldata in memory.
                        staticcall(gas(), 4, add(signature, 0x20), n, add(m, 0x40), n), // 1.
                        0x00 // Length of returndata to write.
                    )
                isValid := gt(returndatasize(), willBeZeroIfRevertingVerifierExists)
                break
            }
            // Do `ecrecover` fallback if `noCode && !isValid`.
            for {} gt(noCode, isValid) {} {
                switch n
                case 64 {
                    let vs := mload(add(signature, 0x40))
                    mstore(0x20, add(shr(255, vs), 27)) // `v`.
                    mstore(0x60, shr(1, shl(1, vs))) // `s`.
                }
                case 65 {
                    mstore(0x20, byte(0, mload(add(signature, 0x60)))) // `v`.
                    mstore(0x60, mload(add(signature, 0x40))) // `s`.
                }
                default { break }
                let m := mload(0x40)
                mstore(0x00, hash)
                mstore(0x40, mload(add(signature, 0x20))) // `r`.
                let recovered := mload(staticcall(gas(), 1, 0x00, 0x80, 0x01, 0x20))
                isValid := gt(returndatasize(), shl(96, xor(signer, recovered)))
                mstore(0x60, 0) // Restore the zero slot.
                mstore(0x40, m) // Restore the free memory pointer.
                break
            }
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
pragma solidity ^0.8.0;

//*********************************************************************
// RaffleBidHeap is a library used by RaffleAuctionMinter to store the
// highest bids in a min-heap. The min-heap ensures that we can quickly
// determine the "floor" bid and decide whether a new bid can enter
// the top bids array or be immediately refunded.
//*********************************************************************
import "./RaffleBidHeap.sol";

//*********************************************************************
// Solady libraries for Role-Based Access Control, Pausable, and
// ECDSA cryptography.
//*********************************************************************
import {Ownable} from "solady/auth/Ownable.sol";
import {SafeTransferLib} from "solady/utils/SafeTransferLib.sol";
import {SignatureCheckerLib} from "solady/utils/SignatureCheckerLib.sol";
import {ReentrancyGuard} from "solady/utils/ReentrancyGuard.sol";

import {IGVC} from "./interfaces/IGVC.sol";

/**
 * @title RaffleAuctionMinter
 * @dev This contract handles a raffle-style auction of NFTs.
 *      - Bids are stored in a "min-heap" (lowest winning bid sits at the top).
 *      - Only the highest N bids (N = capacity) remain in the heap; any new, higher
 *        bid can displace the "lowest winning" bid.
 *      - Each participant can place multiple bids, up to a maximum.
 *      - After the auction ends, winners claim their NFTs and automatically get refunds
 *        for the difference (if their winning bid is above the clearing price).
 *      - Non-winning bidders get a full refund of their bids.
 */
contract GVCAuction is Ownable, ReentrancyGuard {
    //*********************************************************************
    // State Variables
    //*********************************************************************
    bool private _paused;
    uint256 private _idCounter;

    // New state variable for claim window
    bool public claimWindowOpen;

    //*********************************************************************
    // Events
    //*********************************************************************
    event Paused(address account);
    event Unpaused(address account);

    /**
     * @notice Emitted when the claim window is closed by the owner.
     */
    event ClaimWindowClosed();

    /**
     * @notice Emitted when a user places a bid.
     * @param buyer The address that placed the bid.
     * @param bidPrice The amount of ETH submitted with the bid.
     */
    event Bid(address indexed buyer, uint256 bidPrice);

    /**
     * @notice Emitted after a user successfully claims their NFTs and/or refund.
     * @param buyer The address that claimed.
     * @param refundAmount The amount refunded to this user (0 if none).
     * @param nftCount The number of NFTs minted to the user.
     */
    event Claim(address indexed buyer, uint256 refundAmount, uint256 nftCount);

    //*********************************************************************
    // Modifiers
    //*********************************************************************
    modifier whenNotPaused() {
        require(!_paused, "GVCAuction: paused");
        _;
    }

    /**
     * @notice The maximum number of bids a single user can place in the auction.
     *         Changing this would require editing the code's constant below, but
     *         that is outside the scope of this demonstration.
     */
    uint256 public constant MAX_BID_PER_USER = 50;

    //*********************************************************************
    // Data Structures
    //*********************************************************************
    /**
     * @dev Contains information about a user's claim:
     *      - hasClaimed: Has the user already claimed their NFTs/refund?
     *      - refundAmount: How much ETH the user is owed back.
     *      - nftCount: How many NFTs the user ended up winning.
     */
    struct ClaimInfo {
        bool hasClaimed;
        uint256 refundAmount;
        uint256 nftCount;
    }

    //*********************************************************************
    // Library Usage
    //*********************************************************************
    using {
        RaffleBidHeap.initialize,
        RaffleBidHeap.tryInsert,
        RaffleBidHeap.minBid,
        RaffleBidHeap.size
    } for RaffleBidHeap.Heap;

    // Keep using isHigherOrEqualBid directly from the library
    using RaffleBidHeap for RaffleBidHeap.Bid;

    //*********************************************************************
    // Internal Heap Data
    //*********************************************************************
    /**
     * @dev `_heap` holds the top bids in a min-heap format. The size of the heap
     *      is capped at `_nftAmount` (passed in constructor).
     */
    RaffleBidHeap.Heap internal _heap;

    //*********************************************************************
    // Key Addresses
    //*********************************************************************
    address public signer; // The signer address
    address public nftAddress; // The address of the NFT that will be minted
    address public paymentRecipient; // Address to receive the final clearing price * capacity

    //*********************************************************************
    // Auction Parameters
    //*********************************************************************
    uint256 public auctionEndTime; // The timestamp when the auction ends
    bool public paymentSent; // Tracks if the final payment to `paymentRecipient` has been sent

    //*********************************************************************
    // Tracking Bidder Data
    //*********************************************************************
    /**
     * @dev userBids maps each user to an array of all their bids (including those
     *      that may no longer be in the top-bids heap).
     */
    mapping(address => RaffleBidHeap.Bid[]) public userBids;

    /**
     * @dev hasClaimed tracks whether a user has already called `claimAndRefund`.
     *      After claiming, a user cannot claim again.
     */
    mapping(address => bool) public hasClaimed;

    /**
     * @dev buyerBidCount tracks how many bids each user has placed that apply
     *      to a specific "buyer limit ID" (limitForBuyerID). This enforces an
     *      external off-chain limit that might apply to certain sets of users.
     */
    mapping(address => mapping(uint256 => uint256)) buyerBidCount;

    //*********************************************************************
    // Highest Bid Price (Not Actively Used in the Core Logic Here)
    //*********************************************************************
    uint256 public highestBidPrice;

    // Add initialization status
    bool private _initialized;

    //*********************************************************************
    // Constructor
    //*********************************************************************
    /**
     * @param _admin The address of the owner and admin
     */
    constructor(address _admin) {
        _initializeOwner(_admin);
        _paused = true; // Start in paused state
        claimWindowOpen = true; // Claim window is open by default
    }

    /**
     * @notice Initializes the auction with required parameters. Can only be called once.
     * @param _nftAddress The NFT contract address that will be minted from.
     * @param _paymentRecipient Address to receive the final proceeds.
     * @param _nftAmount The capacity for how many winning bids are accepted.
     * @param _auctionEndTime The timestamp at which the auction ends.
     * @param _signer The address that can sign bids.
     */
    function initialize(
        address _nftAddress,
        address _paymentRecipient,
        uint256 _nftAmount,
        uint256 _auctionEndTime,
        address _signer
    ) external onlyOwner {
        require(!_initialized, "GVCAuction: already initialized");
        require(_nftAddress != address(0), "GVCAuction: invalid NFT address");
        require(
            _paymentRecipient != address(0),
            "GVCAuction: invalid payment recipient"
        );
        require(_signer != address(0), "GVCAuction: invalid signer");
        require(
            _auctionEndTime > block.timestamp,
            "GVCAuction: invalid end time"
        );
        require(_nftAmount > 0, "GVCAuction: invalid NFT amount");

        nftAddress = _nftAddress;
        paymentRecipient = _paymentRecipient;
        auctionEndTime = _auctionEndTime;
        signer = _signer;
        _heap.initialize(_nftAmount);

        _initialized = true;
        _paused = false; // Unpause the contract after initialization
    }

    /**
     * @notice Fallback to accept ETH sent directly (not recommended in real usage).
     */
    receive() external payable {}

    //*********************************************************************
    // Management Functions (Admin / Manager Only)
    //*********************************************************************

    /**
     * @dev Sends the final payment to the paymentRecipient after the auction is over.
     *      This is the sum of (capacity) * (clearing price).
     */
    function sendPayment() external {
        require(
            block.timestamp > auctionEndTime,
            "RaffleAuctionMinter: payment can only be made after the auction has ended"
        );
        require(!paymentSent, "RaffleAuctionMinter: payment already sent");

        // The "minBid()" inside the heap is effectively the "floor" winning bid,
        // also known as the clearing price.
        uint256 value = _heap.size() * _heap.minBid().price;

        (bool success, ) = paymentRecipient.call{value: value}("");
        require(success, "RaffleAuctionMinter: failed to send payment");
        paymentSent = true;
    }

    /**
     * @dev Closes the claim window, which prevents users from claiming NFTs but still
     *      allows them to claim excess refunds (over clearing price) for winning bids.
     */
    function closeClaimWindow() external onlyOwner {
        require(
            block.timestamp > auctionEndTime,
            "RaffleAuctionMinter: claim window can only be closed after the auction has ended"
        );
        claimWindowOpen = false;
        emit ClaimWindowClosed();
    }

    /**
     * @dev Sets the signer address (requires owner).
     */
    function setSigner(address _s) external onlyOwner {
        signer = _s;
    }

    /**
     * @dev Sets the recipient address (requires owner).
     */
    function setRecipient(address _r) external onlyOwner {
        paymentRecipient = _r;
    }

    /**
     * @dev Sets the NFT address (requires owner).
     */
    function setNftAddress(address _addr) external onlyOwner {
        nftAddress = _addr;
    }

    /**
     * @dev Extend or modify the auction end time, as long as it's in the future
     *      and the auction hasn't ended already (requires owner).
     */
    function setAuctionEndTime(uint256 _t) external onlyOwner {
        require(_t > block.timestamp, "RaffleAuctionMinter: invalid timestamp");
        require(
            block.timestamp <= auctionEndTime,
            "RaffleAuctionMinter: already ended"
        );
        auctionEndTime = _t;
    }

    //*********************************************************************
    // Core Functions
    //*********************************************************************

    /**
     * @dev placeBid allows a user to place a new bid with ETH attached.
     *      Steps:
     *      1) Verify signature to confirm user is allowed to place this bid.
     *      2) Check if the auction is still open.
     *      3) Check user hasn't placed too many bids (MAX_BID_PER_USER).
     *      4) Check user hasn't exceeded the "limitForBuyerAmount" for the specific buyer-limit ID.
     *      5) Insert bid into the min-heap if it qualifies (or discard it if it is too low and capacity is full).
     */
    function placeBid(
        uint256 bidPrice,
        uint256 limitForBuyerID,
        uint256 limitForBuyerAmount,
        uint256 expireTime,
        bytes calldata _sig
    ) external payable whenNotPaused nonReentrant {
        require(_initialized, "GVCAuction: not initialized");
        //=== 1) Signature check ===//
        bytes32 inputHash = _getInputHash(
            bidPrice,
            limitForBuyerID,
            limitForBuyerAmount,
            expireTime
        );
        _checkSigValidity(inputHash, _sig, signer);

        require(
            block.timestamp <= expireTime,
            "RaffleAuctionMinter: signature expired"
        );

        //=== 2) Auction must be open ===//
        require(
            block.timestamp <= auctionEndTime,
            "RaffleAuctionMinter: auction ended"
        );

        //=== 3) Check max bids per user ===//
        require(
            userBids[msg.sender].length < MAX_BID_PER_USER,
            "RaffleAuctionMinter: maximum bid per user reached"
        );

        //=== 4) Check buyer limit for given limitForBuyerID ===//
        require(
            buyerBidCount[msg.sender][limitForBuyerID] < limitForBuyerAmount,
            "RaffleAuctionMinter: buyer limit exceeded"
        );

        //=== 5) Check the payment matches the bidPrice ===//
        require(msg.value == bidPrice, "RaffleAuctionMinter: payment mismatch");

        buyerBidCount[msg.sender][limitForBuyerID] += 1;

        //=== 6) Build the bid struct and attempt to insert in the min-heap ===//
        _incrementCounter();
        RaffleBidHeap.Bid memory newBid = RaffleBidHeap.Bid(
            uint96(bidPrice),
            msg.sender,
            uint32(_currentCount()),
            uint32(generateRandomNumber(_currentCount())),
            uint40(block.timestamp)
        );

        // Save the bid details in an array for the user
        userBids[msg.sender].push(newBid);

        // The min-heap decides if the new bid displaces the lowest bid (if the heap is full)
        _heap.tryInsert(newBid);

        emit Bid(msg.sender, bidPrice);
    }

    /**
     * @dev placeBatchBids allows a user to place multiple bids at once.
     * @param bidPrices Array of bid prices
     * @param limitForBuyerID Single buyer limit ID for the entire batch
     * @param limitForBuyerAmount Maximum number of bids allowed for this buyer ID
     * @param expireTime Single expiration time for the batch signature
     * @param sig Single signature authorizing the entire batch of bids
     * Requirements:
     * - Total msg.value must equal sum of all bidPrices
     * - Total bids (existing + new) must not exceed MAX_BID_PER_USER
     * - Total bids for limitForBuyerID must not exceed limitForBuyerAmount
     */
    function placeBatchBids(
        uint256[] calldata bidPrices,
        uint256 limitForBuyerID,
        uint256 limitForBuyerAmount,
        uint256 expireTime,
        bytes calldata sig
    ) external payable whenNotPaused nonReentrant {
        require(_initialized, "GVCAuction: not initialized");

        uint256 bidsCount = bidPrices.length;
        require(bidsCount > 0, "GVCAuction: empty batch");

        // Basic checks (same as placeBid)
        bytes32 inputHash = _getInputHash(
            msg.value,
            limitForBuyerID,
            limitForBuyerAmount,
            expireTime
        );
        _checkSigValidity(inputHash, sig, signer);

        require(
            block.timestamp <= expireTime,
            "RaffleAuctionMinter: signature expired"
        );
        require(
            block.timestamp <= auctionEndTime,
            "RaffleAuctionMinter: auction ended"
        );
        require(
            userBids[msg.sender].length + bidsCount <= MAX_BID_PER_USER,
            "GVCAuction: would exceed maximum bids per user"
        );
        require(
            buyerBidCount[msg.sender][limitForBuyerID] + bidsCount <=
                limitForBuyerAmount,
            "GVCAuction: buyer limit exceeded"
        );

        // Validate total payment
        uint256 totalBidAmount;
        for (uint256 i = 0; i < bidsCount; i++) {
            totalBidAmount += bidPrices[i];
        }
        require(msg.value == totalBidAmount, "GVCAuction: payment mismatch");

        // Update bid count once for the batch
        buyerBidCount[msg.sender][limitForBuyerID] += bidsCount;

        // Process bids (same as placeBid)
        for (uint256 i = 0; i < bidsCount; i++) {
            _incrementCounter();
            RaffleBidHeap.Bid memory newBid = RaffleBidHeap.Bid(
                uint96(bidPrices[i]),
                msg.sender,
                uint32(_currentCount()),
                uint32(generateRandomNumber(_currentCount())),
                uint40(block.timestamp)
            );
            userBids[msg.sender].push(newBid);
            _heap.tryInsert(newBid);
            emit Bid(msg.sender, bidPrices[i]);
        }
    }

    /**
     * @dev Returns how many NFTs a user has won and how much ETH they can get refunded.
     *      - If a user's bid is >= the "floorBid" in the final min-heap, that user wins an NFT
     *        and gets refunded (theirBid - floorBid).
     *      - Otherwise, they are refunded their full bid.
     *      - If the claim window is closed, non-winning bids will not be refunded.
     */
    function claimInfo(address _a) public view returns (ClaimInfo memory info) {
        info.hasClaimed = hasClaimed[_a];
        info.refundAmount = 0;
        info.nftCount = 0;
        RaffleBidHeap.Bid memory _floorBid = _heap.minBid();

        // Examine each of this user's bids to compute final outcome
        for (uint256 i = 0; i < userBids[_a].length; i++) {
            // If user's bid is >= floorBid, user is a winner for that bid
            if (RaffleBidHeap.isHigherOrEqualBid(userBids[_a][i], _floorBid)) {
                info.nftCount += 1;
                info.refundAmount += userBids[_a][i].price - _floorBid.price;
            } else {
                // Non-winning bids get fully refunded
                info.refundAmount += userBids[_a][i].price;
            }
        }
    }

    /**
     * @dev claimAndRefund:
     *      1) Auction must be ended.
     *      2) Generate the user's claim info (how many NFTs, how much refund).
     *      3) If claim window is open, mint NFTs and process full refunds.
     *      4) If claim window is closed, only process excess refunds for winning bids.
     *      5) Mark user as claimed to prevent double-claiming.
     */
    function claimAndRefund() external {
        require(
            block.timestamp > auctionEndTime,
            "RaffleAuctionMinter: No claims or refunds allowed until auction ends"
        );
        ClaimInfo memory info = claimInfo(msg.sender);

        require(!info.hasClaimed, "RaffleAuctionMinter: has claimed");
        require(
            info.nftCount > 0 || info.refundAmount > 0,
            "RaffleAuctionMinter: nothing to claim"
        );

        hasClaimed[msg.sender] = true;

        // Mint the user's NFTs
        if (info.nftCount > 0 && claimWindowOpen) {
            IGVC(nftAddress).vibeMint(msg.sender, info.nftCount);
        }

        // Refund the user
        (bool success, ) = msg.sender.call{value: info.refundAmount}("");
        require(success, "RaffleAuctionMinter: failed to send refund");

        emit Claim(msg.sender, info.refundAmount, info.nftCount);
    }

    //*********************************************************************
    // View / Helper Functions
    //*********************************************************************

    /**
     * @dev tvl (total value locked) returns the ETH currently in the contract.
     */
    function tvl() external view returns (uint256) {
        return address(this).balance;
    }

    /**
     * @dev floorBid returns the current lowest winning bid in the min-heap,
     *      i.e., the clearing price if the auction ended now.
     */
    function floorBid() external view returns (RaffleBidHeap.Bid memory) {
        return _heap.minBid();
    }

    /**
     * @dev getUserClaimInfos helps query claim details for multiple addresses at once.
     */
    function getUserClaimInfos(
        address[] calldata _addresses
    ) external view returns (ClaimInfo[] memory results) {
        results = new ClaimInfo[](_addresses.length);
        for (uint256 i = 0; i < _addresses.length; i++) {
            results[i] = claimInfo(_addresses[i]);
        }
    }

    /**
     * @dev getUserBids returns the array of all bids a user has made.
     */
    function getUserBids(
        address[] calldata _addresses
    ) external view returns (RaffleBidHeap.Bid[][] memory bids) {
        bids = new RaffleBidHeap.Bid[][](_addresses.length);
        for (uint256 i = 0; i < _addresses.length; i++) {
            bids[i] = userBids[_addresses[i]];
        }
    }

    /**
     * @dev getTotalBidsCnt returns the total number of bids placed in the entire auction.
     */
    function getTotalBidsCnt() external view returns (uint256) {
        return _currentCount();
    }

    /**
     * @dev getBidAmtByBuyerId returns how many times a user has bid under a certain limit ID.
     */
    function getBidAmtByBuyerId(
        address _buyer,
        uint256 _limitForBuyerID
    ) external view returns (uint256) {
        return buyerBidCount[_buyer][_limitForBuyerID];
    }

    //*********************************************************************
    // Internal Functions - Signature Validation
    //*********************************************************************

    /**
     * @dev _getInputHash encodes the input parameters into a hash used for signature checking.
     */
    function _getInputHash(
        uint256 bidPrice,
        uint256 limitForBuyerID,
        uint256 limitForBuyerAmount,
        uint256 expireTime
    ) internal view returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    msg.sender,
                    bidPrice,
                    limitForBuyerID,
                    limitForBuyerAmount,
                    expireTime,
                    block.chainid,
                    address(this)
                )
            );
    }

    /**
     * @dev _checkSigValidity recovers the signer from a signature and compares it with
     *      the expected signer (the NFT manager).
     */
    function _checkSigValidity(
        bytes32 hash,
        bytes memory sig,
        address _signer
    ) internal view {
        require(
            SignatureCheckerLib.isValidSignatureNow(
                _signer,
                _getEthSignedMessageHash(hash),
                sig
            ),
            "RaffleAuctionMinter: invalid signature"
        );
    }

    /**
     * @dev _getEthSignedMessageHash transforms a hash into the signed message format used by ECDSA.
     */
    function _getEthSignedMessageHash(
        bytes32 criteriaMessageHash
    ) internal pure returns (bytes32) {
        return SignatureCheckerLib.toEthSignedMessageHash(criteriaMessageHash);
    }

    //*********************************************************************
    // Random Number Generation
    //*********************************************************************

    /**
     * @dev generateRandomNumber can be used for tie-breaking in bids.
     *      It's pseudo-random, using blockhash, timestamp, and userInput as seed.
     */
    function generateRandomNumber(
        uint256 userInput
    ) public view returns (uint256) {
        uint256 randomNumber = uint256(
            keccak256(
                abi.encodePacked(
                    blockhash(block.number - 1), // Use the hash value of the previous block as a seed
                    block.timestamp, // Use the current block's timestamp as a seed
                    userInput // Use the user input as a seed
                )
            )
        );
        return randomNumber;
    }

    function paused() external view returns (bool) {
        return _paused;
    }

    // Add pause/unpause functions
    function pause() external onlyOwner {
        _paused = true;
        emit Paused(msg.sender);
    }

    function unpause() external onlyOwner {
        require(_initialized, "GVCAuction: not initialized");
        _paused = false;
        emit Unpaused(msg.sender);
    }

    function _incrementCounter() internal {
        unchecked {
            _idCounter++;
        }
    }

    function _currentCount() internal view returns (uint256) {
        return _idCounter;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

library RaffleBidHeap {
    struct Bid {
        uint96 price; // Up to ~7.9e28 wei (~7.9e10 ETH)
        address bidder; // 20 bytes
        uint32 id; // Up to 4.2B bids
        uint32 nonce; // Tiebreaker
        uint40 timestamp; // Block timestamp (good until year 36812)
    }

    struct Heap {
        // These variables should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _maxCapacity;
        Bid[] _tree;
    }

    function initialize(Heap storage heap, uint256 cap) internal {
        require(heap._maxCapacity == 0, "BidHeap: duplicated initialize");
        heap._maxCapacity = cap;
    }

    function isFull(Heap storage heap) internal view returns (bool) {
        return heap._tree.length >= heap._maxCapacity;
    }

    function size(Heap storage heap) internal view returns (uint256) {
        return heap._tree.length;
    }

    function minBid(Heap storage heap) internal view returns (Bid memory) {
        require(heap._tree.length > 0, "BidHeap: heap is empty");
        return heap._tree[0];
    }

    function tryInsert(
        Heap storage heap,
        Bid memory newBid
    ) internal returns (bool) {
        if (isFull(heap)) {
            if (!isHigherOrEqualBid(newBid, heap._tree[0])) {
                return false;
            }
            heap._tree[0] = newBid;
            heapifyDown(heap, 0);
        } else {
            heap._tree.push(newBid);
            heapifyUp(heap, heap._tree.length - 1);
        }
        return true;
    }

    function heapifyUp(Heap storage heap, uint256 index) private {
        unchecked {
            while (index > 0) {
                uint256 parentIndex = (index - 1) >> 1;
                if (
                    isHigherOrEqualBid(
                        heap._tree[index],
                        heap._tree[parentIndex]
                    )
                ) {
                    break;
                }
                swap(heap, index, parentIndex);
                index = parentIndex;
            }
        }
    }

    function heapifyDown(Heap storage heap, uint256 index) private {
        uint256 smallest = index;
        uint256 len = heap._tree.length;

        unchecked {
            while (true) {
                uint256 leftChild = (index << 1) + 1;
                uint256 rightChild = (index << 1) + 2;

                if (
                    leftChild < len &&
                    isHigherOrEqualBid(
                        heap._tree[smallest],
                        heap._tree[leftChild]
                    )
                ) {
                    smallest = leftChild;
                }
                if (
                    rightChild < len &&
                    isHigherOrEqualBid(
                        heap._tree[smallest],
                        heap._tree[rightChild]
                    )
                ) {
                    smallest = rightChild;
                }
                if (smallest == index) {
                    break;
                }
                swap(heap, smallest, index);
                index = smallest;
            }
        }
    }

    function isHigherOrEqualBid(
        Bid memory _b1,
        Bid memory _b2
    ) internal pure returns (bool) {
        unchecked {
            // Most bids will be decided by price, so optimize for that case
            if (_b1.price != _b2.price) return _b1.price > _b2.price;
            if (_b1.nonce != _b2.nonce) return _b1.nonce < _b2.nonce;
            return _b1.id <= _b2.id;
        }
    }

    function swap(Heap storage heap, uint256 index1, uint256 index2) private {
        Bid memory temp = heap._tree[index1];
        heap._tree[index1] = heap._tree[index2];
        heap._tree[index2] = temp;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface IGVC {
    function vibeMint(address to, uint256 quantity) external;

    function grantMinterRole(address minter) external;
}