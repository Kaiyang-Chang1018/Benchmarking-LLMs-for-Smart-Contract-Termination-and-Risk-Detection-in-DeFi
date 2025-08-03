// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

interface IERC165 {
    /// @notice Query if a contract implements an interface
    /// @param interfaceID The interface identifier, as specified in ERC-165
    /// @dev Interface identification is specified in ERC-165. This function
    /// uses less than 30,000 gas.
    /// @return `true` if the contract implements `interfaceID` and
    /// `interfaceID` is not 0xffffffff, `false` otherwise
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Simple single owner authorization mixin.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/auth/Ownable.sol)
/// @dev While the ownable portion follows [EIP-173](https://eips.ethereum.org/EIPS/eip-173)
/// for compatibility, the nomenclature for the 2-step ownership handover
/// may be unique to this codebase.
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

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                           EVENTS                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The ownership is transferred from `oldOwner` to `newOwner`.
    /// This event is intentionally kept the same as OpenZeppelin's Ownable to be
    /// compatible with indexers and [EIP-173](https://eips.ethereum.org/EIPS/eip-173),
    /// despite it not being as lightweight as a single argument event.
    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);

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

    /// @dev The owner slot is given by: `not(_OWNER_SLOT_NOT)`.
    /// It is intentionally choosen to be a high value
    /// to avoid collision with lower slots.
    /// The choice of manual storage layout is to enable compatibility
    /// with both regular and upgradeable contracts.
    uint256 private constant _OWNER_SLOT_NOT = 0x8b78c6d8;

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

    /// @dev Initializes the owner directly without authorization guard.
    /// This function must be called upon initialization,
    /// regardless of whether the contract is upgradeable or not.
    /// This is to enable generalization to both regular and upgradeable contracts,
    /// and to save gas in case the initial owner is not the caller.
    /// For performance reasons, this function will not check if there
    /// is an existing owner.
    function _initializeOwner(address newOwner) internal virtual {
        /// @solidity memory-safe-assembly
        assembly {
            // Clean the upper 96 bits.
            newOwner := shr(96, shl(96, newOwner))
            // Store the new value.
            sstore(not(_OWNER_SLOT_NOT), newOwner)
            // Emit the {OwnershipTransferred} event.
            log3(0, 0, _OWNERSHIP_TRANSFERRED_EVENT_SIGNATURE, 0, newOwner)
        }
    }

    /// @dev Sets the owner directly without authorization guard.
    function _setOwner(address newOwner) internal virtual {
        /// @solidity memory-safe-assembly
        assembly {
            let ownerSlot := not(_OWNER_SLOT_NOT)
            // Clean the upper 96 bits.
            newOwner := shr(96, shl(96, newOwner))
            // Emit the {OwnershipTransferred} event.
            log3(0, 0, _OWNERSHIP_TRANSFERRED_EVENT_SIGNATURE, sload(ownerSlot), newOwner)
            // Store the new value.
            sstore(ownerSlot, newOwner)
        }
    }

    /// @dev Throws if the sender is not the owner.
    function _checkOwner() internal view virtual {
        /// @solidity memory-safe-assembly
        assembly {
            // If the caller is not the stored owner, revert.
            if iszero(eq(caller(), sload(not(_OWNER_SLOT_NOT)))) {
                mstore(0x00, 0x82b42900) // `Unauthorized()`.
                revert(0x1c, 0x04)
            }
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                  PUBLIC UPDATE FUNCTIONS                   */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Allows the owner to transfer the ownership to `newOwner`.
    function transferOwnership(address newOwner) public payable virtual onlyOwner {
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
    /// The request will be automatically expire in 48 hours (172800 seconds) by default.
    function requestOwnershipHandover() public payable virtual {
        unchecked {
            uint256 expires = block.timestamp + ownershipHandoverValidFor();
            /// @solidity memory-safe-assembly
            assembly {
                // Compute and set the handover slot to `expires`.
                mstore(0x0c, _HANDOVER_SLOT_SEED)
                mstore(0x00, caller())
                sstore(keccak256(0x0c, 0x20), expires)
                // Emit the {OwnershipHandoverRequested} event.
                log2(0, 0, _OWNERSHIP_HANDOVER_REQUESTED_EVENT_SIGNATURE, caller())
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
    function completeOwnershipHandover(address pendingOwner) public payable virtual onlyOwner {
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
            result := sload(not(_OWNER_SLOT_NOT))
        }
    }

    /// @dev Returns the expiry timestamp for the two-step ownership handover to `pendingOwner`.
    function ownershipHandoverExpiresAt(address pendingOwner)
        public
        view
        virtual
        returns (uint256 result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            // Compute the handover slot.
            mstore(0x0c, _HANDOVER_SLOT_SEED)
            mstore(0x00, pendingOwner)
            // Load the handover slot.
            result := sload(keccak256(0x0c, 0x20))
        }
    }

    /// @dev Returns how long a two-step ownership handover is valid for in seconds.
    function ownershipHandoverValidFor() public view virtual returns (uint64) {
        return 48 * 3600;
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

/// @notice Simple ERC721 implementation with storage hitchhiking.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/tokens/ERC721.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC721.sol)
/// @author Modified from OpenZeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/tree/master/contracts/token/ERC721/ERC721.sol)
/// Note:
/// The ERC721 standard allows for self-approvals.
/// For performance, this implementation WILL NOT revert for such actions.
/// Please add any checks with overrides if desired.
abstract contract ERC721 {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         CONSTANTS                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev An account can hold up to 4294967295 tokens.
    uint256 internal constant _MAX_ACCOUNT_BALANCE = 0xffffffff;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       CUSTOM ERRORS                        */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Only the token owner or an approved account can manage the token.
    error NotOwnerNorApproved();

    /// @dev The token does not exist.
    error TokenDoesNotExist();

    /// @dev The token already exists.
    error TokenAlreadyExists();

    /// @dev Cannot query the balance for the zero address.
    error BalanceQueryForZeroAddress();

    /// @dev Cannot mint or transfer to the zero address.
    error TransferToZeroAddress();

    /// @dev The token must be owned by `from`.
    error TransferFromIncorrectOwner();

    /// @dev The recipient's balance has overflowed.
    error AccountBalanceOverflow();

    /// @dev Cannot safely transfer to a contract that does not implement
    /// the ERC721Receiver interface.
    error TransferToNonERC721ReceiverImplementer();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                           EVENTS                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Emitted when token `id` is transferred from `from` to `to`.
    event Transfer(address indexed from, address indexed to, uint256 indexed id);

    /// @dev Emitted when `owner` enables `account` to manage the `id` token.
    event Approval(address indexed owner, address indexed account, uint256 indexed id);

    /// @dev Emitted when `owner` enables or disables `operator` to manage all of their tokens.
    event ApprovalForAll(address indexed owner, address indexed operator, bool isApproved);

    /// @dev `keccak256(bytes("Transfer(address,address,uint256)"))`.
    uint256 private constant _TRANSFER_EVENT_SIGNATURE =
        0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef;

    /// @dev `keccak256(bytes("Approval(address,address,uint256)"))`.
    uint256 private constant _APPROVAL_EVENT_SIGNATURE =
        0x8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925;

    /// @dev `keccak256(bytes("ApprovalForAll(address,address,bool)"))`.
    uint256 private constant _APPROVAL_FOR_ALL_EVENT_SIGNATURE =
        0x17307eab39ab6107e8899845ad3d59bd9653f200f220920489ca2b5937696c31;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                          STORAGE                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The ownership data slot of `id` is given by:
    /// ```
    ///     mstore(0x00, id)
    ///     mstore(0x1c, _ERC721_MASTER_SLOT_SEED)
    ///     let ownershipSlot := add(id, add(id, keccak256(0x00, 0x20)))
    /// ```
    /// Bits Layout:
    // - [0..159]   `addr`
    // - [160..223] `extraData`
    ///
    /// The approved address slot is given by: `add(1, ownershipSlot)`.
    ///
    /// See: https://notes.ethereum.org/%40vbuterin/verkle_tree_eip
    ///
    /// The balance slot of `owner` is given by:
    /// ```
    ///     mstore(0x1c, _ERC721_MASTER_SLOT_SEED)
    ///     mstore(0x00, owner)
    ///     let balanceSlot := keccak256(0x0c, 0x1c)
    /// ```
    /// Bits Layout:
    /// - [0..31]   `balance`
    /// - [32..225] `aux`
    ///
    /// The `operator` approval slot of `owner` is given by:
    /// ```
    ///     mstore(0x1c, or(_ERC721_MASTER_SLOT_SEED, operator))
    ///     mstore(0x00, owner)
    ///     let operatorApprovalSlot := keccak256(0x0c, 0x30)
    /// ```
    uint256 private constant _ERC721_MASTER_SLOT_SEED = 0x7d8825530a5a2e7a << 192;

    /// @dev Pre-shifted and pre-masked constant.
    uint256 private constant _ERC721_MASTER_SLOT_SEED_MASKED = 0x0a5a2e7a00000000;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      ERC721 METADATA                       */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns the token collection name.
    function name() public view virtual returns (string memory);

    /// @dev Returns the token collection symbol.
    function symbol() public view virtual returns (string memory);

    /// @dev Returns the Uniform Resource Identifier (URI) for token `id`.
    function tokenURI(uint256 id) public view virtual returns (string memory);

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                           ERC721                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns the owner of token `id`.
    ///
    /// Requirements:
    /// - Token `id` must exist.
    function ownerOf(uint256 id) public view virtual returns (address result) {
        result = _ownerOf(id);
        /// @solidity memory-safe-assembly
        assembly {
            if iszero(result) {
                mstore(0x00, 0xceea21b6) // `TokenDoesNotExist()`.
                revert(0x1c, 0x04)
            }
        }
    }

    /// @dev Returns the number of tokens owned by `owner`.
    ///
    /// Requirements:
    /// - `owner` must not be the zero address.
    function balanceOf(address owner) public view virtual returns (uint256 result) {
        /// @solidity memory-safe-assembly
        assembly {
            // Revert if the `owner` is the zero address.
            if iszero(owner) {
                mstore(0x00, 0x8f4eb604) // `BalanceQueryForZeroAddress()`.
                revert(0x1c, 0x04)
            }
            mstore(0x1c, _ERC721_MASTER_SLOT_SEED)
            mstore(0x00, owner)
            result := and(sload(keccak256(0x0c, 0x1c)), _MAX_ACCOUNT_BALANCE)
        }
    }

    /// @dev Returns the account approved to managed token `id`.
    ///
    /// Requirements:
    /// - Token `id` must exist.
    function getApproved(uint256 id) public view virtual returns (address result) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, id)
            mstore(0x1c, _ERC721_MASTER_SLOT_SEED)
            let ownershipSlot := add(id, add(id, keccak256(0x00, 0x20)))
            if iszero(shr(96, shl(96, sload(ownershipSlot)))) {
                mstore(0x00, 0xceea21b6) // `TokenDoesNotExist()`.
                revert(0x1c, 0x04)
            }
            result := sload(add(1, ownershipSlot))
        }
    }

    /// @dev Sets `account` as the approved account to manage token `id`.
    ///
    /// Requirements:
    /// - Token `id` must exist.
    /// - The caller must be the owner of the token,
    ///   or an approved operator for the token owner.
    ///
    /// Emits a {Approval} event.
    function approve(address account, uint256 id) public payable virtual {
        _approve(msg.sender, account, id);
    }

    /// @dev Returns whether `operator` is approved to manage the tokens of `owner`.
    function isApprovedForAll(address owner, address operator)
        public
        view
        virtual
        returns (bool result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x1c, operator)
            mstore(0x08, _ERC721_MASTER_SLOT_SEED_MASKED)
            mstore(0x00, owner)
            result := sload(keccak256(0x0c, 0x30))
        }
    }

    /// @dev Sets whether `operator` is approved to manage the tokens of the caller.
    ///
    /// Emits a {ApprovalForAll} event.
    function setApprovalForAll(address operator, bool isApproved) public virtual {
        /// @solidity memory-safe-assembly
        assembly {
            // Convert to 0 or 1.
            isApproved := iszero(iszero(isApproved))
            // Update the `isApproved` for (`msg.sender`, `operator`).
            mstore(0x1c, operator)
            mstore(0x08, _ERC721_MASTER_SLOT_SEED_MASKED)
            mstore(0x00, caller())
            sstore(keccak256(0x0c, 0x30), isApproved)
            // Emit the {ApprovalForAll} event.
            mstore(0x00, isApproved)
            log3(
                0x00, 0x20, _APPROVAL_FOR_ALL_EVENT_SIGNATURE, caller(), shr(96, shl(96, operator))
            )
        }
    }

    /// @dev Transfers token `id` from `from` to `to`.
    ///
    /// Requirements:
    ///
    /// - Token `id` must exist.
    /// - `from` must be the owner of the token.
    /// - `to` cannot be the zero address.
    /// - The caller must be the owner of the token, or be approved to manage the token.
    ///
    /// Emits a {Transfer} event.
    function transferFrom(address from, address to, uint256 id) public payable virtual {
        _beforeTokenTransfer(from, to, id);
        /// @solidity memory-safe-assembly
        assembly {
            // Clear the upper 96 bits.
            let bitmaskAddress := shr(96, not(0))
            from := and(bitmaskAddress, from)
            to := and(bitmaskAddress, to)
            // Load the ownership data.
            mstore(0x00, id)
            mstore(0x1c, or(_ERC721_MASTER_SLOT_SEED, caller()))
            let ownershipSlot := add(id, add(id, keccak256(0x00, 0x20)))
            let ownershipPacked := sload(ownershipSlot)
            let owner := and(bitmaskAddress, ownershipPacked)
            // Revert if `from` is not the owner, or does not exist.
            if iszero(mul(owner, eq(owner, from))) {
                if iszero(owner) {
                    mstore(0x00, 0xceea21b6) // `TokenDoesNotExist()`.
                    revert(0x1c, 0x04)
                }
                mstore(0x00, 0xa1148100) // `TransferFromIncorrectOwner()`.
                revert(0x1c, 0x04)
            }
            // Revert if `to` is the zero address.
            if iszero(to) {
                mstore(0x00, 0xea553b34) // `TransferToZeroAddress()`.
                revert(0x1c, 0x04)
            }
            // Load, check, and update the token approval.
            {
                mstore(0x00, from)
                let approvedAddress := sload(add(1, ownershipSlot))
                // Revert if the caller is not the owner, nor approved.
                if iszero(or(eq(caller(), from), eq(caller(), approvedAddress))) {
                    if iszero(sload(keccak256(0x0c, 0x30))) {
                        mstore(0x00, 0x4b6e7f18) // `NotOwnerNorApproved()`.
                        revert(0x1c, 0x04)
                    }
                }
                // Delete the approved address if any.
                if approvedAddress { sstore(add(1, ownershipSlot), 0) }
            }
            // Update with the new owner.
            sstore(ownershipSlot, xor(ownershipPacked, xor(from, to)))
            // Decrement the balance of `from`.
            {
                let fromBalanceSlot := keccak256(0x0c, 0x1c)
                sstore(fromBalanceSlot, sub(sload(fromBalanceSlot), 1))
            }
            // Increment the balance of `to`.
            {
                mstore(0x00, to)
                let toBalanceSlot := keccak256(0x0c, 0x1c)
                let toBalanceSlotPacked := add(sload(toBalanceSlot), 1)
                if iszero(and(toBalanceSlotPacked, _MAX_ACCOUNT_BALANCE)) {
                    mstore(0x00, 0x01336cea) // `AccountBalanceOverflow()`.
                    revert(0x1c, 0x04)
                }
                sstore(toBalanceSlot, toBalanceSlotPacked)
            }
            // Emit the {Transfer} event.
            log4(0x00, 0x00, _TRANSFER_EVENT_SIGNATURE, from, to, id)
        }
        _afterTokenTransfer(from, to, id);
    }

    /// @dev Equivalent to `safeTransferFrom(from, to, id, "")`.
    function safeTransferFrom(address from, address to, uint256 id) public payable virtual {
        transferFrom(from, to, id);
        if (_hasCode(to)) _checkOnERC721Received(from, to, id, "");
    }

    /// @dev Transfers token `id` from `from` to `to`.
    ///
    /// Requirements:
    ///
    /// - Token `id` must exist.
    /// - `from` must be the owner of the token.
    /// - `to` cannot be the zero address.
    /// - The caller must be the owner of the token, or be approved to manage the token.
    /// - If `to` refers to a smart contract, it must implement
    ///   {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
    ///
    /// Emits a {Transfer} event.
    function safeTransferFrom(address from, address to, uint256 id, bytes calldata data)
        public
        payable
        virtual
    {
        transferFrom(from, to, id);
        if (_hasCode(to)) _checkOnERC721Received(from, to, id, data);
    }

    /// @dev Returns true if this contract implements the interface defined by `interfaceId`.
    /// See: https://eips.ethereum.org/EIPS/eip-165
    /// This function call must use less than 30000 gas.
    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool result) {
        /// @solidity memory-safe-assembly
        assembly {
            let s := shr(224, interfaceId)
            // ERC165: 0x01ffc9a7, ERC721: 0x80ac58cd, ERC721Metadata: 0x5b5e139f.
            result := or(or(eq(s, 0x01ffc9a7), eq(s, 0x80ac58cd)), eq(s, 0x5b5e139f))
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                  INTERNAL QUERY FUNCTIONS                  */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns if token `id` exists.
    function _exists(uint256 id) internal view virtual returns (bool result) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, id)
            mstore(0x1c, _ERC721_MASTER_SLOT_SEED)
            result := shl(96, sload(add(id, add(id, keccak256(0x00, 0x20)))))
        }
    }

    /// @dev Returns the owner of token `id`.
    /// Returns the zero address instead of reverting if the token does not exist.
    function _ownerOf(uint256 id) internal view virtual returns (address result) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, id)
            mstore(0x1c, _ERC721_MASTER_SLOT_SEED)
            result := shr(96, shl(96, sload(add(id, add(id, keccak256(0x00, 0x20))))))
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*            INTERNAL DATA HITCHHIKING FUNCTIONS             */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns the auxiliary data for `owner`.
    /// Minting, transferring, burning the tokens of `owner` will not change the auxiliary data.
    /// Auxiliary data can be set for any address, even if it does not have any tokens.
    function _getAux(address owner) internal view virtual returns (uint224 result) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x1c, _ERC721_MASTER_SLOT_SEED)
            mstore(0x00, owner)
            result := shr(32, sload(keccak256(0x0c, 0x1c)))
        }
    }

    /// @dev Set the auxiliary data for `owner` to `value`.
    /// Minting, transferring, burning the tokens of `owner` will not change the auxiliary data.
    /// Auxiliary data can be set for any address, even if it does not have any tokens.
    function _setAux(address owner, uint224 value) internal virtual {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x1c, _ERC721_MASTER_SLOT_SEED)
            mstore(0x00, owner)
            let balanceSlot := keccak256(0x0c, 0x1c)
            let packed := sload(balanceSlot)
            sstore(balanceSlot, xor(packed, shl(32, xor(value, shr(32, packed)))))
        }
    }

    /// @dev Returns the extra data for token `id`.
    /// Minting, transferring, burning a token will not change the extra data.
    /// The extra data can be set on a non existent token.
    function _getExtraData(uint256 id) internal view virtual returns (uint96 result) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, id)
            mstore(0x1c, _ERC721_MASTER_SLOT_SEED)
            result := shr(160, sload(add(id, add(id, keccak256(0x00, 0x20)))))
        }
    }

    /// @dev Sets the extra data for token `id` to `value`.
    /// Minting, transferring, burning a token will not change the extra data.
    /// The extra data can be set on a non existent token.
    function _setExtraData(uint256 id, uint96 value) internal virtual {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, id)
            mstore(0x1c, _ERC721_MASTER_SLOT_SEED)
            let ownershipSlot := add(id, add(id, keccak256(0x00, 0x20)))
            let packed := sload(ownershipSlot)
            sstore(ownershipSlot, xor(packed, shl(160, xor(value, shr(160, packed)))))
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                  INTERNAL MINT FUNCTIONS                   */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Mints token `id` to `to`.
    ///
    /// Requirements:
    ///
    /// - Token `id` must not exist.
    /// - `to` cannot be the zero address.
    ///
    /// Emits a {Transfer} event.
    function _mint(address to, uint256 id) internal virtual {
        _beforeTokenTransfer(address(0), to, id);
        /// @solidity memory-safe-assembly
        assembly {
            // Clear the upper 96 bits.
            to := shr(96, shl(96, to))
            // Revert if `to` is the zero address.
            if iszero(to) {
                mstore(0x00, 0xea553b34) // `TransferToZeroAddress()`.
                revert(0x1c, 0x04)
            }
            // Load the ownership data.
            mstore(0x00, id)
            mstore(0x1c, _ERC721_MASTER_SLOT_SEED)
            let ownershipSlot := add(id, add(id, keccak256(0x00, 0x20)))
            let ownershipPacked := sload(ownershipSlot)
            // Revert if the token already exists.
            if shl(96, ownershipPacked) {
                mstore(0x00, 0xc991cbb1) // `TokenAlreadyExists()`.
                revert(0x1c, 0x04)
            }
            // Update with the owner.
            sstore(ownershipSlot, or(ownershipPacked, to))
            // Increment the balance of the owner.
            {
                mstore(0x00, to)
                let balanceSlot := keccak256(0x0c, 0x1c)
                let balanceSlotPacked := add(sload(balanceSlot), 1)
                if iszero(and(balanceSlotPacked, _MAX_ACCOUNT_BALANCE)) {
                    mstore(0x00, 0x01336cea) // `AccountBalanceOverflow()`.
                    revert(0x1c, 0x04)
                }
                sstore(balanceSlot, balanceSlotPacked)
            }
            // Emit the {Transfer} event.
            log4(0x00, 0x00, _TRANSFER_EVENT_SIGNATURE, 0, to, id)
        }
        _afterTokenTransfer(address(0), to, id);
    }

    /// @dev Equivalent to `_safeMint(to, id, "")`.
    function _safeMint(address to, uint256 id) internal virtual {
        _safeMint(to, id, "");
    }

    /// @dev Mints token `id` to `to`.
    ///
    /// Requirements:
    ///
    /// - Token `id` must not exist.
    /// - `to` cannot be the zero address.
    /// - If `to` refers to a smart contract, it must implement
    ///   {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
    ///
    /// Emits a {Transfer} event.
    function _safeMint(address to, uint256 id, bytes memory data) internal virtual {
        _mint(to, id);
        if (_hasCode(to)) _checkOnERC721Received(address(0), to, id, data);
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                  INTERNAL BURN FUNCTIONS                   */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Equivalent to `_burn(address(0), id)`.
    function _burn(uint256 id) internal virtual {
        _burn(address(0), id);
    }

    /// @dev Destroys token `id`, using `by`.
    ///
    /// Requirements:
    ///
    /// - Token `id` must exist.
    /// - If `by` is not the zero address,
    ///   it must be the owner of the token, or be approved to manage the token.
    ///
    /// Emits a {Transfer} event.
    function _burn(address by, uint256 id) internal virtual {
        address owner = ownerOf(id);
        _beforeTokenTransfer(owner, address(0), id);
        /// @solidity memory-safe-assembly
        assembly {
            // Clear the upper 96 bits.
            by := shr(96, shl(96, by))
            // Load the ownership data.
            mstore(0x00, id)
            mstore(0x1c, or(_ERC721_MASTER_SLOT_SEED, by))
            let ownershipSlot := add(id, add(id, keccak256(0x00, 0x20)))
            let ownershipPacked := sload(ownershipSlot)
            // Reload the owner in case it is changed in `_beforeTokenTransfer`.
            owner := shr(96, shl(96, ownershipPacked))
            // Revert if the token does not exist.
            if iszero(owner) {
                mstore(0x00, 0xceea21b6) // `TokenDoesNotExist()`.
                revert(0x1c, 0x04)
            }
            // Load and check the token approval.
            {
                mstore(0x00, owner)
                let approvedAddress := sload(add(1, ownershipSlot))
                // If `by` is not the zero address, do the authorization check.
                // Revert if the `by` is not the owner, nor approved.
                if iszero(or(iszero(by), or(eq(by, owner), eq(by, approvedAddress)))) {
                    if iszero(sload(keccak256(0x0c, 0x30))) {
                        mstore(0x00, 0x4b6e7f18) // `NotOwnerNorApproved()`.
                        revert(0x1c, 0x04)
                    }
                }
                // Delete the approved address if any.
                if approvedAddress { sstore(add(1, ownershipSlot), 0) }
            }
            // Clear the owner.
            sstore(ownershipSlot, xor(ownershipPacked, owner))
            // Decrement the balance of `owner`.
            {
                let balanceSlot := keccak256(0x0c, 0x1c)
                sstore(balanceSlot, sub(sload(balanceSlot), 1))
            }
            // Emit the {Transfer} event.
            log4(0x00, 0x00, _TRANSFER_EVENT_SIGNATURE, owner, 0, id)
        }
        _afterTokenTransfer(owner, address(0), id);
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                INTERNAL APPROVAL FUNCTIONS                 */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns whether `account` is the owner of token `id`, or is approved to managed it.
    ///
    /// Requirements:
    /// - Token `id` must exist.
    function _isApprovedOrOwner(address account, uint256 id)
        internal
        view
        virtual
        returns (bool result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            result := 1
            // Clear the upper 96 bits.
            account := shr(96, shl(96, account))
            // Load the ownership data.
            mstore(0x00, id)
            mstore(0x1c, or(_ERC721_MASTER_SLOT_SEED, account))
            let ownershipSlot := add(id, add(id, keccak256(0x00, 0x20)))
            let owner := shr(96, shl(96, sload(ownershipSlot)))
            // Revert if the token does not exist.
            if iszero(owner) {
                mstore(0x00, 0xceea21b6) // `TokenDoesNotExist()`.
                revert(0x1c, 0x04)
            }
            // Check if `account` is the `owner`.
            if iszero(eq(account, owner)) {
                mstore(0x00, owner)
                // Check if `account` is approved to
                if iszero(sload(keccak256(0x0c, 0x30))) {
                    result := eq(account, sload(add(1, ownershipSlot)))
                }
            }
        }
    }

    /// @dev Returns the account approved to manage token `id`.
    /// Returns the zero address instead of reverting if the token does not exist.
    function _getApproved(uint256 id) internal view virtual returns (address result) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, id)
            mstore(0x1c, _ERC721_MASTER_SLOT_SEED)
            result := sload(add(1, add(id, add(id, keccak256(0x00, 0x20)))))
        }
    }

    /// @dev Equivalent to `_approve(address(0), account, id)`.
    function _approve(address account, uint256 id) internal virtual {
        _approve(address(0), account, id);
    }

    /// @dev Sets `account` as the approved account to manage token `id`, using `by`.
    ///
    /// Requirements:
    /// - Token `id` must exist.
    /// - If `by` is not the zero address, `by` must be the owner
    ///   or an approved operator for the token owner.
    ///
    /// Emits a {Transfer} event.
    function _approve(address by, address account, uint256 id) internal virtual {
        assembly {
            // Clear the upper 96 bits.
            let bitmaskAddress := shr(96, not(0))
            account := and(bitmaskAddress, account)
            by := and(bitmaskAddress, by)
            // Load the owner of the token.
            mstore(0x00, id)
            mstore(0x1c, or(_ERC721_MASTER_SLOT_SEED, by))
            let ownershipSlot := add(id, add(id, keccak256(0x00, 0x20)))
            let owner := and(bitmaskAddress, sload(ownershipSlot))
            // Revert if the token does not exist.
            if iszero(owner) {
                mstore(0x00, 0xceea21b6) // `TokenDoesNotExist()`.
                revert(0x1c, 0x04)
            }
            // If `by` is not the zero address, do the authorization check.
            // Revert if `by` is not the owner, nor approved.
            if iszero(or(iszero(by), eq(by, owner))) {
                mstore(0x00, owner)
                if iszero(sload(keccak256(0x0c, 0x30))) {
                    mstore(0x00, 0x4b6e7f18) // `NotOwnerNorApproved()`.
                    revert(0x1c, 0x04)
                }
            }
            // Sets `account` as the approved account to manage `id`.
            sstore(add(1, ownershipSlot), account)
            // Emit the {Approval} event.
            log4(0x00, 0x00, _APPROVAL_EVENT_SIGNATURE, owner, account, id)
        }
    }

    /// @dev Approve or remove the `operator` as an operator for `by`,
    /// without authorization checks.
    ///
    /// Emits a {ApprovalForAll} event.
    function _setApprovalForAll(address by, address operator, bool isApproved) internal virtual {
        /// @solidity memory-safe-assembly
        assembly {
            // Clear the upper 96 bits.
            by := shr(96, shl(96, by))
            operator := shr(96, shl(96, operator))
            // Convert to 0 or 1.
            isApproved := iszero(iszero(isApproved))
            // Update the `isApproved` for (`by`, `operator`).
            mstore(0x1c, or(_ERC721_MASTER_SLOT_SEED, operator))
            mstore(0x00, by)
            sstore(keccak256(0x0c, 0x30), isApproved)
            // Emit the {ApprovalForAll} event.
            mstore(0x00, isApproved)
            log3(0x00, 0x20, _APPROVAL_FOR_ALL_EVENT_SIGNATURE, by, operator)
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                INTERNAL TRANSFER FUNCTIONS                 */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Equivalent to `_transfer(address(0), from, to, id)`.
    function _transfer(address from, address to, uint256 id) internal virtual {
        _transfer(address(0), from, to, id);
    }

    /// @dev Transfers token `id` from `from` to `to`.
    ///
    /// Requirements:
    ///
    /// - Token `id` must exist.
    /// - `from` must be the owner of the token.
    /// - `to` cannot be the zero address.
    /// - If `by` is not the zero address,
    ///   it must be the owner of the token, or be approved to manage the token.
    ///
    /// Emits a {Transfer} event.
    function _transfer(address by, address from, address to, uint256 id) internal virtual {
        _beforeTokenTransfer(from, to, id);
        /// @solidity memory-safe-assembly
        assembly {
            // Clear the upper 96 bits.
            let bitmaskAddress := shr(96, not(0))
            from := and(bitmaskAddress, from)
            to := and(bitmaskAddress, to)
            by := and(bitmaskAddress, by)
            // Load the ownership data.
            mstore(0x00, id)
            mstore(0x1c, or(_ERC721_MASTER_SLOT_SEED, by))
            let ownershipSlot := add(id, add(id, keccak256(0x00, 0x20)))
            let ownershipPacked := sload(ownershipSlot)
            let owner := and(bitmaskAddress, ownershipPacked)
            // Revert if `from` is not the owner, or does not exist.
            if iszero(mul(owner, eq(owner, from))) {
                if iszero(owner) {
                    mstore(0x00, 0xceea21b6) // `TokenDoesNotExist()`.
                    revert(0x1c, 0x04)
                }
                mstore(0x00, 0xa1148100) // `TransferFromIncorrectOwner()`.
                revert(0x1c, 0x04)
            }
            // Revert if `to` is the zero address.
            if iszero(to) {
                mstore(0x00, 0xea553b34) // `TransferToZeroAddress()`.
                revert(0x1c, 0x04)
            }
            // Load, check, and update the token approval.
            {
                mstore(0x00, from)
                let approvedAddress := sload(add(1, ownershipSlot))
                // If `by` is not the zero address, do the authorization check.
                // Revert if the `by` is not the owner, nor approved.
                if iszero(or(iszero(by), or(eq(by, from), eq(by, approvedAddress)))) {
                    if iszero(sload(keccak256(0x0c, 0x30))) {
                        mstore(0x00, 0x4b6e7f18) // `NotOwnerNorApproved()`.
                        revert(0x1c, 0x04)
                    }
                }
                // Delete the approved address if any.
                if approvedAddress { sstore(add(1, ownershipSlot), 0) }
            }
            // Update with the new owner.
            sstore(ownershipSlot, xor(ownershipPacked, xor(from, to)))
            // Decrement the balance of `from`.
            {
                let fromBalanceSlot := keccak256(0x0c, 0x1c)
                sstore(fromBalanceSlot, sub(sload(fromBalanceSlot), 1))
            }
            // Increment the balance of `to`.
            {
                mstore(0x00, to)
                let toBalanceSlot := keccak256(0x0c, 0x1c)
                let toBalanceSlotPacked := add(sload(toBalanceSlot), 1)
                if iszero(and(toBalanceSlotPacked, _MAX_ACCOUNT_BALANCE)) {
                    mstore(0x00, 0x01336cea) // `AccountBalanceOverflow()`.
                    revert(0x1c, 0x04)
                }
                sstore(toBalanceSlot, toBalanceSlotPacked)
            }
            // Emit the {Transfer} event.
            log4(0x00, 0x00, _TRANSFER_EVENT_SIGNATURE, from, to, id)
        }
        _afterTokenTransfer(from, to, id);
    }

    /// @dev Equivalent to `_safeTransfer(from, to, id, "")`.
    function _safeTransfer(address from, address to, uint256 id) internal virtual {
        _safeTransfer(from, to, id, "");
    }

    /// @dev Transfers token `id` from `from` to `to`.
    ///
    /// Requirements:
    ///
    /// - Token `id` must exist.
    /// - `from` must be the owner of the token.
    /// - `to` cannot be the zero address.
    /// - The caller must be the owner of the token, or be approved to manage the token.
    /// - If `to` refers to a smart contract, it must implement
    ///   {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
    ///
    /// Emits a {Transfer} event.
    function _safeTransfer(address from, address to, uint256 id, bytes memory data)
        internal
        virtual
    {
        _transfer(address(0), from, to, id);
        if (_hasCode(to)) _checkOnERC721Received(from, to, id, data);
    }

    /// @dev Equivalent to `_safeTransfer(by, from, to, id, "")`.
    function _safeTransfer(address by, address from, address to, uint256 id) internal virtual {
        _safeTransfer(by, from, to, id, "");
    }

    /// @dev Transfers token `id` from `from` to `to`.
    ///
    /// Requirements:
    ///
    /// - Token `id` must exist.
    /// - `from` must be the owner of the token.
    /// - `to` cannot be the zero address.
    /// - If `by` is not the zero address,
    ///   it must be the owner of the token, or be approved to manage the token.
    /// - If `to` refers to a smart contract, it must implement
    ///   {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
    ///
    /// Emits a {Transfer} event.
    function _safeTransfer(address by, address from, address to, uint256 id, bytes memory data)
        internal
        virtual
    {
        _transfer(by, from, to, id);
        if (_hasCode(to)) _checkOnERC721Received(from, to, id, data);
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                    HOOKS FOR OVERRIDING                    */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Hook that is called before any token transfers, including minting and burning.
    function _beforeTokenTransfer(address from, address to, uint256 id) internal virtual {}

    /// @dev Hook that is called after any token transfers, including minting and burning.
    function _afterTokenTransfer(address from, address to, uint256 id) internal virtual {}

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      PRIVATE HELPERS                       */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns if `a` has bytecode of non-zero length.
    function _hasCode(address a) private view returns (bool result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := extcodesize(a) // Can handle dirty upper bits.
        }
    }

    /// @dev Perform a call to invoke {IERC721Receiver-onERC721Received} on `to`.
    /// Reverts if the target does not support the function correctly.
    function _checkOnERC721Received(address from, address to, uint256 id, bytes memory data)
        private
    {
        /// @solidity memory-safe-assembly
        assembly {
            // Prepare the calldata.
            let m := mload(0x40)
            let onERC721ReceivedSelector := 0x150b7a02
            mstore(m, onERC721ReceivedSelector)
            mstore(add(m, 0x20), caller()) // The `operator`, which is always `msg.sender`.
            mstore(add(m, 0x40), shr(96, shl(96, from)))
            mstore(add(m, 0x60), id)
            mstore(add(m, 0x80), 0x80)
            let n := mload(data)
            mstore(add(m, 0xa0), n)
            if n { pop(staticcall(gas(), 4, add(data, 0x20), n, add(m, 0xc0), n)) }
            // Revert if the call reverts.
            if iszero(call(gas(), to, 0, add(m, 0x1c), add(n, 0xa4), m, 0x20)) {
                if returndatasize() {
                    // Bubble up the revert if the call reverts.
                    returndatacopy(0x00, 0x00, returndatasize())
                    revert(0x00, returndatasize())
                }
                mstore(m, 0)
            }
            // Load the returndata and compare it.
            if iszero(eq(mload(m), shl(224, onERC721ReceivedSelector))) {
                mstore(0x00, 0xd1a57ed6) // `TransferToNonERC721ReceiverImplementer()`.
                revert(0x1c, 0x04)
            }
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Library to encode strings in Base64.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/Base64.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/Base64.sol)
/// @author Modified from (https://github.com/Brechtpd/base64/blob/main/base64.sol) by Brecht Devos - <brecht@loopring.org>.
library Base64 {
    /// @dev Encodes `data` using the base64 encoding described in RFC 4648.
    /// See: https://datatracker.ietf.org/doc/html/rfc4648
    /// @param fileSafe  Whether to replace '+' with '-' and '/' with '_'.
    /// @param noPadding Whether to strip away the padding.
    function encode(bytes memory data, bool fileSafe, bool noPadding)
        internal
        pure
        returns (string memory result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let dataLength := mload(data)

            if dataLength {
                // Multiply by 4/3 rounded up.
                // The `shl(2, ...)` is equivalent to multiplying by 4.
                let encodedLength := shl(2, div(add(dataLength, 2), 3))

                // Set `result` to point to the start of the free memory.
                result := mload(0x40)

                // Store the table into the scratch space.
                // Offsetted by -1 byte so that the `mload` will load the character.
                // We will rewrite the free memory pointer at `0x40` later with
                // the allocated size.
                // The magic constant 0x0230 will translate "-_" + "+/".
                mstore(0x1f, "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdef")
                mstore(0x3f, sub("ghijklmnopqrstuvwxyz0123456789-_", mul(iszero(fileSafe), 0x0230)))

                // Skip the first slot, which stores the length.
                let ptr := add(result, 0x20)
                let end := add(ptr, encodedLength)

                // Run over the input, 3 bytes at a time.
                for {} 1 {} {
                    data := add(data, 3) // Advance 3 bytes.
                    let input := mload(data)

                    // Write 4 bytes. Optimized for fewer stack operations.
                    mstore8(0, mload(and(shr(18, input), 0x3F)))
                    mstore8(1, mload(and(shr(12, input), 0x3F)))
                    mstore8(2, mload(and(shr(6, input), 0x3F)))
                    mstore8(3, mload(and(input, 0x3F)))
                    mstore(ptr, mload(0x00))

                    ptr := add(ptr, 4) // Advance 4 bytes.
                    if iszero(lt(ptr, end)) { break }
                }
                mstore(0x40, add(end, 0x20)) // Allocate the memory.
                // Equivalent to `o = [0, 2, 1][dataLength % 3]`.
                let o := div(2, mod(dataLength, 3))
                // Offset `ptr` and pad with '='. We can simply write over the end.
                mstore(sub(ptr, o), shl(240, 0x3d3d))
                // Set `o` to zero if there is padding.
                o := mul(iszero(iszero(noPadding)), o)
                mstore(sub(ptr, o), 0) // Zeroize the slot after the string.
                mstore(result, sub(encodedLength, o)) // Store the length.
            }
        }
    }

    /// @dev Encodes `data` using the base64 encoding described in RFC 4648.
    /// Equivalent to `encode(data, false, false)`.
    function encode(bytes memory data) internal pure returns (string memory result) {
        result = encode(data, false, false);
    }

    /// @dev Encodes `data` using the base64 encoding described in RFC 4648.
    /// Equivalent to `encode(data, fileSafe, false)`.
    function encode(bytes memory data, bool fileSafe)
        internal
        pure
        returns (string memory result)
    {
        result = encode(data, fileSafe, false);
    }

    /// @dev Decodes base64 encoded `data`.
    ///
    /// Supports:
    /// - RFC 4648 (both standard and file-safe mode).
    /// - RFC 3501 (63: ',').
    ///
    /// Does not support:
    /// - Line breaks.
    ///
    /// Note: For performance reasons,
    /// this function will NOT revert on invalid `data` inputs.
    /// Outputs for invalid inputs will simply be undefined behaviour.
    /// It is the user's responsibility to ensure that the `data`
    /// is a valid base64 encoded string.
    function decode(string memory data) internal pure returns (bytes memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            let dataLength := mload(data)

            if dataLength {
                let decodedLength := mul(shr(2, dataLength), 3)

                for {} 1 {} {
                    // If padded.
                    if iszero(and(dataLength, 3)) {
                        let t := xor(mload(add(data, dataLength)), 0x3d3d)
                        // forgefmt: disable-next-item
                        decodedLength := sub(
                            decodedLength,
                            add(iszero(byte(30, t)), iszero(byte(31, t)))
                        )
                        break
                    }
                    // If non-padded.
                    decodedLength := add(decodedLength, sub(and(dataLength, 3), 1))
                    break
                }
                result := mload(0x40)

                // Write the length of the bytes.
                mstore(result, decodedLength)

                // Skip the first slot, which stores the length.
                let ptr := add(result, 0x20)
                let end := add(ptr, decodedLength)

                // Load the table into the scratch space.
                // Constants are optimized for smaller bytecode with zero gas overhead.
                // `m` also doubles as the mask of the upper 6 bits.
                let m := 0xfc000000fc00686c7074787c8084888c9094989ca0a4a8acb0b4b8bcc0c4c8cc
                mstore(0x5b, m)
                mstore(0x3b, 0x04080c1014181c2024282c3034383c4044484c5054585c6064)
                mstore(0x1a, 0xf8fcf800fcd0d4d8dce0e4e8ecf0f4)

                for {} 1 {} {
                    // Read 4 bytes.
                    data := add(data, 4)
                    let input := mload(data)

                    // Write 3 bytes.
                    // forgefmt: disable-next-item
                    mstore(ptr, or(
                        and(m, mload(byte(28, input))),
                        shr(6, or(
                            and(m, mload(byte(29, input))),
                            shr(6, or(
                                and(m, mload(byte(30, input))),
                                shr(6, mload(byte(31, input)))
                            ))
                        ))
                    ))
                    ptr := add(ptr, 3)
                    if iszero(lt(ptr, end)) { break }
                }
                mstore(0x40, add(end, 0x20)) // Allocate the memory.
                mstore(end, 0) // Zeroize the slot after the bytes.
                mstore(0x60, 0) // Restore the zero slot.
            }
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Library for converting numbers into strings and other string operations.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/LibString.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/LibString.sol)
library LibString {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                        CUSTOM ERRORS                       */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The `length` of the output is too small to contain all the hex digits.
    error HexLengthInsufficient();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         CONSTANTS                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The constant returned when the `search` is not found in the string.
    uint256 internal constant NOT_FOUND = type(uint256).max;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                     DECIMAL OPERATIONS                     */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns the base 10 decimal representation of `value`.
    function toString(uint256 value) internal pure returns (string memory str) {
        /// @solidity memory-safe-assembly
        assembly {
            // The maximum value of a uint256 contains 78 digits (1 byte per digit), but
            // we allocate 0xa0 bytes to keep the free memory pointer 32-byte word aligned.
            // We will need 1 word for the trailing zeros padding, 1 word for the length,
            // and 3 words for a maximum of 78 digits.
            str := add(mload(0x40), 0x80)
            // Update the free memory pointer to allocate.
            mstore(0x40, add(str, 0x20))
            // Zeroize the slot after the string.
            mstore(str, 0)

            // Cache the end of the memory to calculate the length later.
            let end := str

            let w := not(0) // Tsk.
            // We write the string from rightmost digit to leftmost digit.
            // The following is essentially a do-while loop that also handles the zero case.
            for { let temp := value } 1 {} {
                str := add(str, w) // `sub(str, 1)`.
                // Write the character to the pointer.
                // The ASCII index of the '0' character is 48.
                mstore8(str, add(48, mod(temp, 10)))
                // Keep dividing `temp` until zero.
                temp := div(temp, 10)
                if iszero(temp) { break }
            }

            let length := sub(end, str)
            // Move the pointer 32 bytes leftwards to make room for the length.
            str := sub(str, 0x20)
            // Store the length.
            mstore(str, length)
        }
    }

    /// @dev Returns the base 10 decimal representation of `value`.
    function toString(int256 value) internal pure returns (string memory str) {
        if (value >= 0) {
            return toString(uint256(value));
        }
        unchecked {
            str = toString(uint256(-value));
        }
        /// @solidity memory-safe-assembly
        assembly {
            // We still have some spare memory space on the left,
            // as we have allocated 3 words (96 bytes) for up to 78 digits.
            let length := mload(str) // Load the string length.
            mstore(str, 0x2d) // Store the '-' character.
            str := sub(str, 1) // Move back the string pointer by a byte.
            mstore(str, add(length, 1)) // Update the string length.
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                   HEXADECIMAL OPERATIONS                   */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns the hexadecimal representation of `value`,
    /// left-padded to an input length of `length` bytes.
    /// The output is prefixed with "0x" encoded using 2 hexadecimal digits per byte,
    /// giving a total length of `length * 2 + 2` bytes.
    /// Reverts if `length` is too small for the output to contain all the digits.
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory str) {
        str = toHexStringNoPrefix(value, length);
        /// @solidity memory-safe-assembly
        assembly {
            let strLength := add(mload(str), 2) // Compute the length.
            mstore(str, 0x3078) // Write the "0x" prefix.
            str := sub(str, 2) // Move the pointer.
            mstore(str, strLength) // Write the length.
        }
    }

    /// @dev Returns the hexadecimal representation of `value`,
    /// left-padded to an input length of `length` bytes.
    /// The output is prefixed with "0x" encoded using 2 hexadecimal digits per byte,
    /// giving a total length of `length * 2` bytes.
    /// Reverts if `length` is too small for the output to contain all the digits.
    function toHexStringNoPrefix(uint256 value, uint256 length)
        internal
        pure
        returns (string memory str)
    {
        /// @solidity memory-safe-assembly
        assembly {
            // We need 0x20 bytes for the trailing zeros padding, `length * 2` bytes
            // for the digits, 0x02 bytes for the prefix, and 0x20 bytes for the length.
            // We add 0x20 to the total and round down to a multiple of 0x20.
            // (0x20 + 0x20 + 0x02 + 0x20) = 0x62.
            str := add(mload(0x40), and(add(shl(1, length), 0x42), not(0x1f)))
            // Allocate the memory.
            mstore(0x40, add(str, 0x20))
            // Zeroize the slot after the string.
            mstore(str, 0)

            // Cache the end to calculate the length later.
            let end := str
            // Store "0123456789abcdef" in scratch space.
            mstore(0x0f, 0x30313233343536373839616263646566)

            let start := sub(str, add(length, length))
            let w := not(1) // Tsk.
            let temp := value
            // We write the string from rightmost digit to leftmost digit.
            // The following is essentially a do-while loop that also handles the zero case.
            for {} 1 {} {
                str := add(str, w) // `sub(str, 2)`.
                mstore8(add(str, 1), mload(and(temp, 15)))
                mstore8(str, mload(and(shr(4, temp), 15)))
                temp := shr(8, temp)
                if iszero(xor(str, start)) { break }
            }

            if temp {
                // Store the function selector of `HexLengthInsufficient()`.
                mstore(0x00, 0x2194895a)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }

            // Compute the string's length.
            let strLength := sub(end, str)
            // Move the pointer and write the length.
            str := sub(str, 0x20)
            mstore(str, strLength)
        }
    }

    /// @dev Returns the hexadecimal representation of `value`.
    /// The output is prefixed with "0x" and encoded using 2 hexadecimal digits per byte.
    /// As address are 20 bytes long, the output will left-padded to have
    /// a length of `20 * 2 + 2` bytes.
    function toHexString(uint256 value) internal pure returns (string memory str) {
        str = toHexStringNoPrefix(value);
        /// @solidity memory-safe-assembly
        assembly {
            let strLength := add(mload(str), 2) // Compute the length.
            mstore(str, 0x3078) // Write the "0x" prefix.
            str := sub(str, 2) // Move the pointer.
            mstore(str, strLength) // Write the length.
        }
    }

    /// @dev Returns the hexadecimal representation of `value`.
    /// The output is encoded using 2 hexadecimal digits per byte.
    /// As address are 20 bytes long, the output will left-padded to have
    /// a length of `20 * 2` bytes.
    function toHexStringNoPrefix(uint256 value) internal pure returns (string memory str) {
        /// @solidity memory-safe-assembly
        assembly {
            // We need 0x20 bytes for the trailing zeros padding, 0x20 bytes for the length,
            // 0x02 bytes for the prefix, and 0x40 bytes for the digits.
            // The next multiple of 0x20 above (0x20 + 0x20 + 0x02 + 0x40) is 0xa0.
            str := add(mload(0x40), 0x80)
            // Allocate the memory.
            mstore(0x40, add(str, 0x20))
            // Zeroize the slot after the string.
            mstore(str, 0)

            // Cache the end to calculate the length later.
            let end := str
            // Store "0123456789abcdef" in scratch space.
            mstore(0x0f, 0x30313233343536373839616263646566)

            let w := not(1) // Tsk.
            // We write the string from rightmost digit to leftmost digit.
            // The following is essentially a do-while loop that also handles the zero case.
            for { let temp := value } 1 {} {
                str := add(str, w) // `sub(str, 2)`.
                mstore8(add(str, 1), mload(and(temp, 15)))
                mstore8(str, mload(and(shr(4, temp), 15)))
                temp := shr(8, temp)
                if iszero(temp) { break }
            }

            // Compute the string's length.
            let strLength := sub(end, str)
            // Move the pointer and write the length.
            str := sub(str, 0x20)
            mstore(str, strLength)
        }
    }

    /// @dev Returns the hexadecimal representation of `value`.
    /// The output is prefixed with "0x", encoded using 2 hexadecimal digits per byte,
    /// and the alphabets are capitalized conditionally according to
    /// https://eips.ethereum.org/EIPS/eip-55
    function toHexStringChecksumed(address value) internal pure returns (string memory str) {
        str = toHexString(value);
        /// @solidity memory-safe-assembly
        assembly {
            let mask := shl(6, div(not(0), 255)) // `0b010000000100000000 ...`
            let o := add(str, 0x22)
            let hashed := and(keccak256(o, 40), mul(34, mask)) // `0b10001000 ... `
            let t := shl(240, 136) // `0b10001000 << 240`
            for { let i := 0 } 1 {} {
                mstore(add(i, i), mul(t, byte(i, hashed)))
                i := add(i, 1)
                if eq(i, 20) { break }
            }
            mstore(o, xor(mload(o), shr(1, and(mload(0x00), and(mload(o), mask)))))
            o := add(o, 0x20)
            mstore(o, xor(mload(o), shr(1, and(mload(0x20), and(mload(o), mask)))))
        }
    }

    /// @dev Returns the hexadecimal representation of `value`.
    /// The output is prefixed with "0x" and encoded using 2 hexadecimal digits per byte.
    function toHexString(address value) internal pure returns (string memory str) {
        str = toHexStringNoPrefix(value);
        /// @solidity memory-safe-assembly
        assembly {
            let strLength := add(mload(str), 2) // Compute the length.
            mstore(str, 0x3078) // Write the "0x" prefix.
            str := sub(str, 2) // Move the pointer.
            mstore(str, strLength) // Write the length.
        }
    }

    /// @dev Returns the hexadecimal representation of `value`.
    /// The output is encoded using 2 hexadecimal digits per byte.
    function toHexStringNoPrefix(address value) internal pure returns (string memory str) {
        /// @solidity memory-safe-assembly
        assembly {
            str := mload(0x40)

            // Allocate the memory.
            // We need 0x20 bytes for the trailing zeros padding, 0x20 bytes for the length,
            // 0x02 bytes for the prefix, and 0x28 bytes for the digits.
            // The next multiple of 0x20 above (0x20 + 0x20 + 0x02 + 0x28) is 0x80.
            mstore(0x40, add(str, 0x80))

            // Store "0123456789abcdef" in scratch space.
            mstore(0x0f, 0x30313233343536373839616263646566)

            str := add(str, 2)
            mstore(str, 40)

            let o := add(str, 0x20)
            mstore(add(o, 40), 0)

            value := shl(96, value)

            // We write the string from rightmost digit to leftmost digit.
            // The following is essentially a do-while loop that also handles the zero case.
            for { let i := 0 } 1 {} {
                let p := add(o, add(i, i))
                let temp := byte(i, value)
                mstore8(add(p, 1), mload(and(temp, 15)))
                mstore8(p, mload(shr(4, temp)))
                i := add(i, 1)
                if eq(i, 20) { break }
            }
        }
    }

    /// @dev Returns the hex encoded string from the raw bytes.
    /// The output is encoded using 2 hexadecimal digits per byte.
    function toHexString(bytes memory raw) internal pure returns (string memory str) {
        str = toHexStringNoPrefix(raw);
        /// @solidity memory-safe-assembly
        assembly {
            let strLength := add(mload(str), 2) // Compute the length.
            mstore(str, 0x3078) // Write the "0x" prefix.
            str := sub(str, 2) // Move the pointer.
            mstore(str, strLength) // Write the length.
        }
    }

    /// @dev Returns the hex encoded string from the raw bytes.
    /// The output is encoded using 2 hexadecimal digits per byte.
    function toHexStringNoPrefix(bytes memory raw) internal pure returns (string memory str) {
        /// @solidity memory-safe-assembly
        assembly {
            let length := mload(raw)
            str := add(mload(0x40), 2) // Skip 2 bytes for the optional prefix.
            mstore(str, add(length, length)) // Store the length of the output.

            // Store "0123456789abcdef" in scratch space.
            mstore(0x0f, 0x30313233343536373839616263646566)

            let o := add(str, 0x20)
            let end := add(raw, length)

            for {} iszero(eq(raw, end)) {} {
                raw := add(raw, 1)
                mstore8(add(o, 1), mload(and(mload(raw), 15)))
                mstore8(o, mload(and(shr(4, mload(raw)), 15)))
                o := add(o, 2)
            }
            mstore(o, 0) // Zeroize the slot after the string.
            mstore(0x40, add(o, 0x20)) // Allocate the memory.
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                   RUNE STRING OPERATIONS                   */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns the number of UTF characters in the string.
    function runeCount(string memory s) internal pure returns (uint256 result) {
        /// @solidity memory-safe-assembly
        assembly {
            if mload(s) {
                mstore(0x00, div(not(0), 255))
                mstore(0x20, 0x0202020202020202020202020202020202020202020202020303030304040506)
                let o := add(s, 0x20)
                let end := add(o, mload(s))
                for { result := 1 } 1 { result := add(result, 1) } {
                    o := add(o, byte(0, mload(shr(250, mload(o)))))
                    if iszero(lt(o, end)) { break }
                }
            }
        }
    }

    /// @dev Returns if this string is a 7-bit ASCII string.
    /// (i.e. all characters codes are in [0..127])
    function is7BitASCII(string memory s) internal pure returns (bool result) {
        /// @solidity memory-safe-assembly
        assembly {
            let mask := shl(7, div(not(0), 255))
            result := 1
            let n := mload(s)
            if n {
                let o := add(s, 0x20)
                let end := add(o, n)
                let last := mload(end)
                mstore(end, 0)
                for {} 1 {} {
                    if and(mask, mload(o)) {
                        result := 0
                        break
                    }
                    o := add(o, 0x20)
                    if iszero(lt(o, end)) { break }
                }
                mstore(end, last)
            }
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                   BYTE STRING OPERATIONS                   */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // For performance and bytecode compactness, all indices of the following operations
    // are byte (ASCII) offsets, not UTF character offsets.

    /// @dev Returns `subject` all occurrences of `search` replaced with `replacement`.
    function replace(string memory subject, string memory search, string memory replacement)
        internal
        pure
        returns (string memory result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let subjectLength := mload(subject)
            let searchLength := mload(search)
            let replacementLength := mload(replacement)

            subject := add(subject, 0x20)
            search := add(search, 0x20)
            replacement := add(replacement, 0x20)
            result := add(mload(0x40), 0x20)

            let subjectEnd := add(subject, subjectLength)
            if iszero(gt(searchLength, subjectLength)) {
                let subjectSearchEnd := add(sub(subjectEnd, searchLength), 1)
                let h := 0
                if iszero(lt(searchLength, 0x20)) { h := keccak256(search, searchLength) }
                let m := shl(3, sub(0x20, and(searchLength, 0x1f)))
                let s := mload(search)
                for {} 1 {} {
                    let t := mload(subject)
                    // Whether the first `searchLength % 32` bytes of
                    // `subject` and `search` matches.
                    if iszero(shr(m, xor(t, s))) {
                        if h {
                            if iszero(eq(keccak256(subject, searchLength), h)) {
                                mstore(result, t)
                                result := add(result, 1)
                                subject := add(subject, 1)
                                if iszero(lt(subject, subjectSearchEnd)) { break }
                                continue
                            }
                        }
                        // Copy the `replacement` one word at a time.
                        for { let o := 0 } 1 {} {
                            mstore(add(result, o), mload(add(replacement, o)))
                            o := add(o, 0x20)
                            if iszero(lt(o, replacementLength)) { break }
                        }
                        result := add(result, replacementLength)
                        subject := add(subject, searchLength)
                        if searchLength {
                            if iszero(lt(subject, subjectSearchEnd)) { break }
                            continue
                        }
                    }
                    mstore(result, t)
                    result := add(result, 1)
                    subject := add(subject, 1)
                    if iszero(lt(subject, subjectSearchEnd)) { break }
                }
            }

            let resultRemainder := result
            result := add(mload(0x40), 0x20)
            let k := add(sub(resultRemainder, result), sub(subjectEnd, subject))
            // Copy the rest of the string one word at a time.
            for {} lt(subject, subjectEnd) {} {
                mstore(resultRemainder, mload(subject))
                resultRemainder := add(resultRemainder, 0x20)
                subject := add(subject, 0x20)
            }
            result := sub(result, 0x20)
            let last := add(add(result, 0x20), k) // Zeroize the slot after the string.
            mstore(last, 0)
            mstore(0x40, add(last, 0x20)) // Allocate the memory.
            mstore(result, k) // Store the length.
        }
    }

    /// @dev Returns the byte index of the first location of `search` in `subject`,
    /// searching from left to right, starting from `from`.
    /// Returns `NOT_FOUND` (i.e. `type(uint256).max`) if the `search` is not found.
    function indexOf(string memory subject, string memory search, uint256 from)
        internal
        pure
        returns (uint256 result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            for { let subjectLength := mload(subject) } 1 {} {
                if iszero(mload(search)) {
                    if iszero(gt(from, subjectLength)) {
                        result := from
                        break
                    }
                    result := subjectLength
                    break
                }
                let searchLength := mload(search)
                let subjectStart := add(subject, 0x20)

                result := not(0) // Initialize to `NOT_FOUND`.

                subject := add(subjectStart, from)
                let end := add(sub(add(subjectStart, subjectLength), searchLength), 1)

                let m := shl(3, sub(0x20, and(searchLength, 0x1f)))
                let s := mload(add(search, 0x20))

                if iszero(and(lt(subject, end), lt(from, subjectLength))) { break }

                if iszero(lt(searchLength, 0x20)) {
                    for { let h := keccak256(add(search, 0x20), searchLength) } 1 {} {
                        if iszero(shr(m, xor(mload(subject), s))) {
                            if eq(keccak256(subject, searchLength), h) {
                                result := sub(subject, subjectStart)
                                break
                            }
                        }
                        subject := add(subject, 1)
                        if iszero(lt(subject, end)) { break }
                    }
                    break
                }
                for {} 1 {} {
                    if iszero(shr(m, xor(mload(subject), s))) {
                        result := sub(subject, subjectStart)
                        break
                    }
                    subject := add(subject, 1)
                    if iszero(lt(subject, end)) { break }
                }
                break
            }
        }
    }

    /// @dev Returns the byte index of the first location of `search` in `subject`,
    /// searching from left to right.
    /// Returns `NOT_FOUND` (i.e. `type(uint256).max`) if the `search` is not found.
    function indexOf(string memory subject, string memory search)
        internal
        pure
        returns (uint256 result)
    {
        result = indexOf(subject, search, 0);
    }

    /// @dev Returns the byte index of the first location of `search` in `subject`,
    /// searching from right to left, starting from `from`.
    /// Returns `NOT_FOUND` (i.e. `type(uint256).max`) if the `search` is not found.
    function lastIndexOf(string memory subject, string memory search, uint256 from)
        internal
        pure
        returns (uint256 result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            for {} 1 {} {
                result := not(0) // Initialize to `NOT_FOUND`.
                let searchLength := mload(search)
                if gt(searchLength, mload(subject)) { break }
                let w := result

                let fromMax := sub(mload(subject), searchLength)
                if iszero(gt(fromMax, from)) { from := fromMax }

                let end := add(add(subject, 0x20), w)
                subject := add(add(subject, 0x20), from)
                if iszero(gt(subject, end)) { break }
                // As this function is not too often used,
                // we shall simply use keccak256 for smaller bytecode size.
                for { let h := keccak256(add(search, 0x20), searchLength) } 1 {} {
                    if eq(keccak256(subject, searchLength), h) {
                        result := sub(subject, add(end, 1))
                        break
                    }
                    subject := add(subject, w) // `sub(subject, 1)`.
                    if iszero(gt(subject, end)) { break }
                }
                break
            }
        }
    }

    /// @dev Returns the byte index of the first location of `search` in `subject`,
    /// searching from right to left.
    /// Returns `NOT_FOUND` (i.e. `type(uint256).max`) if the `search` is not found.
    function lastIndexOf(string memory subject, string memory search)
        internal
        pure
        returns (uint256 result)
    {
        result = lastIndexOf(subject, search, uint256(int256(-1)));
    }

    /// @dev Returns whether `subject` starts with `search`.
    function startsWith(string memory subject, string memory search)
        internal
        pure
        returns (bool result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let searchLength := mload(search)
            // Just using keccak256 directly is actually cheaper.
            // forgefmt: disable-next-item
            result := and(
                iszero(gt(searchLength, mload(subject))),
                eq(
                    keccak256(add(subject, 0x20), searchLength),
                    keccak256(add(search, 0x20), searchLength)
                )
            )
        }
    }

    /// @dev Returns whether `subject` ends with `search`.
    function endsWith(string memory subject, string memory search)
        internal
        pure
        returns (bool result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let searchLength := mload(search)
            let subjectLength := mload(subject)
            // Whether `search` is not longer than `subject`.
            let withinRange := iszero(gt(searchLength, subjectLength))
            // Just using keccak256 directly is actually cheaper.
            // forgefmt: disable-next-item
            result := and(
                withinRange,
                eq(
                    keccak256(
                        // `subject + 0x20 + max(subjectLength - searchLength, 0)`.
                        add(add(subject, 0x20), mul(withinRange, sub(subjectLength, searchLength))),
                        searchLength
                    ),
                    keccak256(add(search, 0x20), searchLength)
                )
            )
        }
    }

    /// @dev Returns `subject` repeated `times`.
    function repeat(string memory subject, uint256 times)
        internal
        pure
        returns (string memory result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let subjectLength := mload(subject)
            if iszero(or(iszero(times), iszero(subjectLength))) {
                subject := add(subject, 0x20)
                result := mload(0x40)
                let output := add(result, 0x20)
                for {} 1 {} {
                    // Copy the `subject` one word at a time.
                    for { let o := 0 } 1 {} {
                        mstore(add(output, o), mload(add(subject, o)))
                        o := add(o, 0x20)
                        if iszero(lt(o, subjectLength)) { break }
                    }
                    output := add(output, subjectLength)
                    times := sub(times, 1)
                    if iszero(times) { break }
                }
                mstore(output, 0) // Zeroize the slot after the string.
                let resultLength := sub(output, add(result, 0x20))
                mstore(result, resultLength) // Store the length.
                // Allocate the memory.
                mstore(0x40, add(result, add(resultLength, 0x20)))
            }
        }
    }

    /// @dev Returns a copy of `subject` sliced from `start` to `end` (exclusive).
    /// `start` and `end` are byte offsets.
    function slice(string memory subject, uint256 start, uint256 end)
        internal
        pure
        returns (string memory result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let subjectLength := mload(subject)
            if iszero(gt(subjectLength, end)) { end := subjectLength }
            if iszero(gt(subjectLength, start)) { start := subjectLength }
            if lt(start, end) {
                result := mload(0x40)
                let resultLength := sub(end, start)
                mstore(result, resultLength)
                subject := add(subject, start)
                let w := not(0x1f)
                // Copy the `subject` one word at a time, backwards.
                for { let o := and(add(resultLength, 0x1f), w) } 1 {} {
                    mstore(add(result, o), mload(add(subject, o)))
                    o := add(o, w) // `sub(o, 0x20)`.
                    if iszero(o) { break }
                }
                // Zeroize the slot after the string.
                mstore(add(add(result, 0x20), resultLength), 0)
                // Allocate memory for the length and the bytes,
                // rounded up to a multiple of 32.
                mstore(0x40, add(result, and(add(resultLength, 0x3f), w)))
            }
        }
    }

    /// @dev Returns a copy of `subject` sliced from `start` to the end of the string.
    /// `start` is a byte offset.
    function slice(string memory subject, uint256 start)
        internal
        pure
        returns (string memory result)
    {
        result = slice(subject, start, uint256(int256(-1)));
    }

    /// @dev Returns all the indices of `search` in `subject`.
    /// The indices are byte offsets.
    function indicesOf(string memory subject, string memory search)
        internal
        pure
        returns (uint256[] memory result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let subjectLength := mload(subject)
            let searchLength := mload(search)

            if iszero(gt(searchLength, subjectLength)) {
                subject := add(subject, 0x20)
                search := add(search, 0x20)
                result := add(mload(0x40), 0x20)

                let subjectStart := subject
                let subjectSearchEnd := add(sub(add(subject, subjectLength), searchLength), 1)
                let h := 0
                if iszero(lt(searchLength, 0x20)) { h := keccak256(search, searchLength) }
                let m := shl(3, sub(0x20, and(searchLength, 0x1f)))
                let s := mload(search)
                for {} 1 {} {
                    let t := mload(subject)
                    // Whether the first `searchLength % 32` bytes of
                    // `subject` and `search` matches.
                    if iszero(shr(m, xor(t, s))) {
                        if h {
                            if iszero(eq(keccak256(subject, searchLength), h)) {
                                subject := add(subject, 1)
                                if iszero(lt(subject, subjectSearchEnd)) { break }
                                continue
                            }
                        }
                        // Append to `result`.
                        mstore(result, sub(subject, subjectStart))
                        result := add(result, 0x20)
                        // Advance `subject` by `searchLength`.
                        subject := add(subject, searchLength)
                        if searchLength {
                            if iszero(lt(subject, subjectSearchEnd)) { break }
                            continue
                        }
                    }
                    subject := add(subject, 1)
                    if iszero(lt(subject, subjectSearchEnd)) { break }
                }
                let resultEnd := result
                // Assign `result` to the free memory pointer.
                result := mload(0x40)
                // Store the length of `result`.
                mstore(result, shr(5, sub(resultEnd, add(result, 0x20))))
                // Allocate memory for result.
                // We allocate one more word, so this array can be recycled for {split}.
                mstore(0x40, add(resultEnd, 0x20))
            }
        }
    }

    /// @dev Returns a arrays of strings based on the `delimiter` inside of the `subject` string.
    function split(string memory subject, string memory delimiter)
        internal
        pure
        returns (string[] memory result)
    {
        uint256[] memory indices = indicesOf(subject, delimiter);
        /// @solidity memory-safe-assembly
        assembly {
            let w := not(0x1f)
            let indexPtr := add(indices, 0x20)
            let indicesEnd := add(indexPtr, shl(5, add(mload(indices), 1)))
            mstore(add(indicesEnd, w), mload(subject))
            mstore(indices, add(mload(indices), 1))
            let prevIndex := 0
            for {} 1 {} {
                let index := mload(indexPtr)
                mstore(indexPtr, 0x60)
                if iszero(eq(index, prevIndex)) {
                    let element := mload(0x40)
                    let elementLength := sub(index, prevIndex)
                    mstore(element, elementLength)
                    // Copy the `subject` one word at a time, backwards.
                    for { let o := and(add(elementLength, 0x1f), w) } 1 {} {
                        mstore(add(element, o), mload(add(add(subject, prevIndex), o)))
                        o := add(o, w) // `sub(o, 0x20)`.
                        if iszero(o) { break }
                    }
                    // Zeroize the slot after the string.
                    mstore(add(add(element, 0x20), elementLength), 0)
                    // Allocate memory for the length and the bytes,
                    // rounded up to a multiple of 32.
                    mstore(0x40, add(element, and(add(elementLength, 0x3f), w)))
                    // Store the `element` into the array.
                    mstore(indexPtr, element)
                }
                prevIndex := add(index, mload(delimiter))
                indexPtr := add(indexPtr, 0x20)
                if iszero(lt(indexPtr, indicesEnd)) { break }
            }
            result := indices
            if iszero(mload(delimiter)) {
                result := add(indices, 0x20)
                mstore(result, sub(mload(indices), 2))
            }
        }
    }

    /// @dev Returns a concatenated string of `a` and `b`.
    /// Cheaper than `string.concat()` and does not de-align the free memory pointer.
    function concat(string memory a, string memory b)
        internal
        pure
        returns (string memory result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let w := not(0x1f)
            result := mload(0x40)
            let aLength := mload(a)
            // Copy `a` one word at a time, backwards.
            for { let o := and(add(mload(a), 0x20), w) } 1 {} {
                mstore(add(result, o), mload(add(a, o)))
                o := add(o, w) // `sub(o, 0x20)`.
                if iszero(o) { break }
            }
            let bLength := mload(b)
            let output := add(result, mload(a))
            // Copy `b` one word at a time, backwards.
            for { let o := and(add(bLength, 0x20), w) } 1 {} {
                mstore(add(output, o), mload(add(b, o)))
                o := add(o, w) // `sub(o, 0x20)`.
                if iszero(o) { break }
            }
            let totalLength := add(aLength, bLength)
            let last := add(add(result, 0x20), totalLength)
            // Zeroize the slot after the string.
            mstore(last, 0)
            // Stores the length.
            mstore(result, totalLength)
            // Allocate memory for the length and the bytes,
            // rounded up to a multiple of 32.
            mstore(0x40, and(add(last, 0x1f), w))
        }
    }

    /// @dev Returns a copy of the string in either lowercase or UPPERCASE.
    /// WARNING! This function is only compatible with 7-bit ASCII strings.
    function toCase(string memory subject, bool toUpper)
        internal
        pure
        returns (string memory result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let length := mload(subject)
            if length {
                result := add(mload(0x40), 0x20)
                subject := add(subject, 1)
                let flags := shl(add(70, shl(5, toUpper)), 0x3ffffff)
                let w := not(0)
                for { let o := length } 1 {} {
                    o := add(o, w)
                    let b := and(0xff, mload(add(subject, o)))
                    mstore8(add(result, o), xor(b, and(shr(b, flags), 0x20)))
                    if iszero(o) { break }
                }
                result := mload(0x40)
                mstore(result, length) // Store the length.
                let last := add(add(result, 0x20), length)
                mstore(last, 0) // Zeroize the slot after the string.
                mstore(0x40, add(last, 0x20)) // Allocate the memory.
            }
        }
    }

    /// @dev Returns a lowercased copy of the string.
    /// WARNING! This function is only compatible with 7-bit ASCII strings.
    function lower(string memory subject) internal pure returns (string memory result) {
        result = toCase(subject, false);
    }

    /// @dev Returns an UPPERCASED copy of the string.
    /// WARNING! This function is only compatible with 7-bit ASCII strings.
    function upper(string memory subject) internal pure returns (string memory result) {
        result = toCase(subject, true);
    }

    /// @dev Escapes the string to be used within HTML tags.
    function escapeHTML(string memory s) internal pure returns (string memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            for {
                let end := add(s, mload(s))
                result := add(mload(0x40), 0x20)
                // Store the bytes of the packed offsets and strides into the scratch space.
                // `packed = (stride << 5) | offset`. Max offset is 20. Max stride is 6.
                mstore(0x1f, 0x900094)
                mstore(0x08, 0xc0000000a6ab)
                // Store "&quot;&amp;&#39;&lt;&gt;" into the scratch space.
                mstore(0x00, shl(64, 0x2671756f743b26616d703b262333393b266c743b2667743b))
            } iszero(eq(s, end)) {} {
                s := add(s, 1)
                let c := and(mload(s), 0xff)
                // Not in `["\"","'","&","<",">"]`.
                if iszero(and(shl(c, 1), 0x500000c400000000)) {
                    mstore8(result, c)
                    result := add(result, 1)
                    continue
                }
                let t := shr(248, mload(c))
                mstore(result, mload(and(t, 0x1f)))
                result := add(result, shr(5, t))
            }
            let last := result
            mstore(last, 0) // Zeroize the slot after the string.
            result := mload(0x40)
            mstore(result, sub(last, add(result, 0x20))) // Store the length.
            mstore(0x40, add(last, 0x20)) // Allocate the memory.
        }
    }

    /// @dev Escapes the string to be used within double-quotes in a JSON.
    function escapeJSON(string memory s) internal pure returns (string memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            for {
                let end := add(s, mload(s))
                result := add(mload(0x40), 0x20)
                // Store "\\u0000" in scratch space.
                // Store "0123456789abcdef" in scratch space.
                // Also, store `{0x08:"b", 0x09:"t", 0x0a:"n", 0x0c:"f", 0x0d:"r"}`.
                // into the scratch space.
                mstore(0x15, 0x5c75303030303031323334353637383961626364656662746e006672)
                // Bitmask for detecting `["\"","\\"]`.
                let e := or(shl(0x22, 1), shl(0x5c, 1))
            } iszero(eq(s, end)) {} {
                s := add(s, 1)
                let c := and(mload(s), 0xff)
                if iszero(lt(c, 0x20)) {
                    if iszero(and(shl(c, 1), e)) {
                        // Not in `["\"","\\"]`.
                        mstore8(result, c)
                        result := add(result, 1)
                        continue
                    }
                    mstore8(result, 0x5c) // "\\".
                    mstore8(add(result, 1), c)
                    result := add(result, 2)
                    continue
                }
                if iszero(and(shl(c, 1), 0x3700)) {
                    // Not in `["\b","\t","\n","\f","\d"]`.
                    mstore8(0x1d, mload(shr(4, c))) // Hex value.
                    mstore8(0x1e, mload(and(c, 15))) // Hex value.
                    mstore(result, mload(0x19)) // "\\u00XX".
                    result := add(result, 6)
                    continue
                }
                mstore8(result, 0x5c) // "\\".
                mstore8(add(result, 1), mload(add(c, 8)))
                result := add(result, 2)
            }
            let last := result
            mstore(last, 0) // Zeroize the slot after the string.
            result := mload(0x40)
            mstore(result, sub(last, add(result, 0x20))) // Store the length.
            mstore(0x40, add(last, 0x20)) // Allocate the memory.
        }
    }

    /// @dev Returns whether `a` equals `b`.
    function eq(string memory a, string memory b) internal pure returns (bool result) {
        assembly {
            result := eq(keccak256(add(a, 0x20), mload(a)), keccak256(add(b, 0x20), mload(b)))
        }
    }

    /// @dev Packs a single string with its length into a single word.
    /// Returns `bytes32(0)` if the length is zero or greater than 31.
    function packOne(string memory a) internal pure returns (bytes32 result) {
        /// @solidity memory-safe-assembly
        assembly {
            // We don't need to zero right pad the string,
            // since this is our own custom non-standard packing scheme.
            result :=
                mul(
                    // Load the length and the bytes.
                    mload(add(a, 0x1f)),
                    // `length != 0 && length < 32`. Abuses underflow.
                    // Assumes that the length is valid and within the block gas limit.
                    lt(sub(mload(a), 1), 0x1f)
                )
        }
    }

    /// @dev Unpacks a string packed using {packOne}.
    /// Returns the empty string if `packed` is `bytes32(0)`.
    /// If `packed` is not an output of {packOne}, the output behaviour is undefined.
    function unpackOne(bytes32 packed) internal pure returns (string memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            // Grab the free memory pointer.
            result := mload(0x40)
            // Allocate 2 words (1 for the length, 1 for the bytes).
            mstore(0x40, add(result, 0x40))
            // Zeroize the length slot.
            mstore(result, 0)
            // Store the length and bytes.
            mstore(add(result, 0x1f), packed)
            // Right pad with zeroes.
            mstore(add(add(result, 0x20), mload(result)), 0)
        }
    }

    /// @dev Packs two strings with their lengths into a single word.
    /// Returns `bytes32(0)` if combined length is zero or greater than 30.
    function packTwo(string memory a, string memory b) internal pure returns (bytes32 result) {
        /// @solidity memory-safe-assembly
        assembly {
            let aLength := mload(a)
            // We don't need to zero right pad the strings,
            // since this is our own custom non-standard packing scheme.
            result :=
                mul(
                    // Load the length and the bytes of `a` and `b`.
                    or(
                        shl(shl(3, sub(0x1f, aLength)), mload(add(a, aLength))),
                        mload(sub(add(b, 0x1e), aLength))
                    ),
                    // `totalLength != 0 && totalLength < 31`. Abuses underflow.
                    // Assumes that the lengths are valid and within the block gas limit.
                    lt(sub(add(aLength, mload(b)), 1), 0x1e)
                )
        }
    }

    /// @dev Unpacks strings packed using {packTwo}.
    /// Returns the empty strings if `packed` is `bytes32(0)`.
    /// If `packed` is not an output of {packTwo}, the output behaviour is undefined.
    function unpackTwo(bytes32 packed)
        internal
        pure
        returns (string memory resultA, string memory resultB)
    {
        /// @solidity memory-safe-assembly
        assembly {
            // Grab the free memory pointer.
            resultA := mload(0x40)
            resultB := add(resultA, 0x40)
            // Allocate 2 words for each string (1 for the length, 1 for the byte). Total 4 words.
            mstore(0x40, add(resultB, 0x40))
            // Zeroize the length slots.
            mstore(resultA, 0)
            mstore(resultB, 0)
            // Store the lengths and bytes.
            mstore(add(resultA, 0x1f), packed)
            mstore(add(resultB, 0x1f), mload(add(add(resultA, 0x20), mload(resultA))))
            // Right pad with zeroes.
            mstore(add(add(resultA, 0x20), mload(resultA)), 0)
            mstore(add(add(resultB, 0x20), mload(resultB)), 0)
        }
    }

    /// @dev Directly returns `a` without copying.
    function directReturn(string memory a) internal pure {
        assembly {
            // Assumes that the string does not start from the scratch space.
            let retStart := sub(a, 0x20)
            let retSize := add(mload(a), 0x40)
            // Right pad with zeroes. Just in case the string is produced
            // by a method that doesn't zero right pad.
            mstore(add(retStart, retSize), 0)
            // Store the return offset.
            mstore(retStart, 0x20)
            // End the transaction, returning the string.
            return(retStart, retSize)
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Safe ETH and ERC20 transfer library that gracefully handles missing return values.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/SafeTransferLib.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/SafeTransferLib.sol)
/// @dev Caution! This library won't check that a token has code, responsibility is delegated to the caller.
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
                    // For better gas estimation.
                    if iszero(gt(gas(), 1000000)) { revert(0, 0) }
                }
            }
        }
    }

    /// @dev Force sends `amount` (in wei) ETH to `to`, with a gas stipend
    /// equal to `_GAS_STIPEND_NO_GRIEF`. This gas stipend is a reasonable default
    /// for 99% of cases and can be overriden with the three-argument version of this
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
                    // For better gas estimation.
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
    /// The `from` account must have at least `amount` approved for
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
            // The `amount` argument is already written to the memory word at 0x6c.
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
pragma solidity 0.8.20;

import {XXYYZZMetadata} from "./XXYYZZMetadata.sol";
import {XXYYZZBurn} from "./XXYYZZBurn.sol";
import {XXYYZZSeaDrop} from "./XXYYZZSeaDrop.sol";
import {XXYYZZCore} from "./XXYYZZCore.sol";
import {XXYYZZRerollFinalize} from "./XXYYZZRerollFinalize.sol";
import {XXYYZZCore} from "./XXYYZZCore.sol";
import {LibString} from "solady/utils/LibString.sol";
import {Base64} from "solady/utils/Base64.sol";

/**
 * @title XXYYZZ
 * @author emo.eth
 * @notice XXYYZZ is a collection of fully onchain, collectible colors. Each token has a unique hex value.
 *         Tokens may be "rerolled" to new hex values, unless they are "finalized," in which case, they are immutable.
 *
 *         Finalizing tokens also adds the finalizer's wallet address to the token's metadata.
 *         Tokens may be burned, which removes it from the token supply, but unless the token was finalized, its
 *         particular hex value may be minted or rerolled again.
 *
 *         Mints and rerolls are pseudorandom by default, unless one of the "Specific" methods is called.
 *         To prevent front-running "specific" mint transactions, the XXYYZZ contract uses a commit-reveal scheme.
 *         Users must commit a hash of their desired hex value with a secret salt, wait at least one minute, and then
 *         submit their mint or reroll transaction with the original hex value(s) and salt.
 *         Multiple IDs may be minted or rerolled in a single transaction by committixng the result of hash of all IDs in order
 *         with a single secret salt.
 *         In batch methods, unavailable IDs are skipped, and excess payment is refunded to the caller.
 */
contract XXYYZZ is XXYYZZMetadata, XXYYZZBurn, XXYYZZSeaDrop, XXYYZZRerollFinalize {
    using LibString for uint256;
    using LibString for address;
    using Base64 for bytes;

    constructor(
        address initialOwner,
        address creatorPayout,
        uint256 maxBatchSize,
        uint24[] memory preMintIds,
        address seaDrop
    ) XXYYZZSeaDrop(seaDrop, creatorPayout, initialOwner, maxBatchSize) {
        for (uint256 i; i < preMintIds.length;) {
            _mint(initialOwner, preMintIds[i]);
            _finalizeToken(preMintIds[i], initialOwner);
            unchecked {
                ++i;
            }
        }
        _numMinted = uint32(preMintIds.length);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        pure
        virtual
        override(XXYYZZSeaDrop, XXYYZZCore)
        returns (bool)
    {
        return XXYYZZSeaDrop.supportsInterface(interfaceId);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {XXYYZZCore} from "./XXYYZZCore.sol";

abstract contract XXYYZZBurn is XXYYZZCore {
    //////////
    // BURN //
    //////////

    /**
     * @notice Permanently burn a token that the caller owns or is approved for.
     * @param xxyyzz The token to burn.
     * @param onlyFinalized If true, only tokens that have been finalized can be burned. Useful if an approved operator
     *                      is burning tokens on behalf of a user.
     */
    function burn(uint256 xxyyzz, bool onlyFinalized) public {
        // cannot overflow as there are at most 2^24 tokens, and _numBurned is a uint32
        unchecked {
            _numBurned += 1;
        }
        if (onlyFinalized) {
            if (!_isFinalized(xxyyzz)) {
                revert OnlyFinalized();
            }
        }
        _burn(msg.sender, xxyyzz);
    }

    /**
     * @notice Permanently burn multiple tokens. All must be owned by the same address.
     * @param ids The tokens to burn.
     * @param onlyFinalized If true, only tokens that have been finalized can be burned. Useful if an approved operator
     *                      is burning tokens on behalf of a user.
     */
    function batchBurn(uint256[] calldata ids, bool onlyFinalized) public {
        if (ids.length == 0) {
            revert NoIdsProvided();
        }
        uint256 packedOwnerFinalizedSlot = _packedOwnershipSlot(ids[0]);
        address initialTokenOwner = address(uint160(packedOwnerFinalizedSlot));
        if (onlyFinalized) {
            if (packedOwnerFinalizedSlot < type(uint160).max) {
                revert OnlyFinalized();
            }
        }
        // validate that msg.sender has approval to burn all tokens
        if (initialTokenOwner != msg.sender) {
            if (!isApprovedForAll(initialTokenOwner, msg.sender)) {
                revert BatchBurnerNotApprovedForAll();
            }
        }
        // safe because there are at most 2^24 tokens, and ownerships are checked
        unchecked {
            _numBurned += uint32(ids.length);
        }
        _burn(ids[0]);
        for (uint256 i = 1; i < ids.length;) {
            uint256 id = ids[i];
            packedOwnerFinalizedSlot = _packedOwnershipSlot(id);
            address owner = address(uint160(packedOwnerFinalizedSlot));
            // ensure that all tokens are owned by the same address
            if (owner != initialTokenOwner) {
                revert OwnerMismatch();
            }
            if (onlyFinalized) {
                if (packedOwnerFinalizedSlot < type(uint160).max) {
                    revert OnlyFinalized();
                }
            }
            // no need to specify msg.sender since caller is approved for all tokens
            // this also checks token exists
            _burn(id);
            unchecked {
                ++i;
            }
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ERC721} from "solady/tokens/ERC721.sol";
import {CommitReveal} from "./lib/CommitReveal.sol";
import {Ownable} from "solady/auth/Ownable.sol";
import {SafeTransferLib} from "solady/utils/SafeTransferLib.sol";
import {IERC4906, IERC165} from "./interfaces/IERC4906.sol";

/**
 * @title XXYYZZCore
 * @author emo.eth
 * @notice Core contract for XXYYZZ NFTs. Contains errors, constants, core token information, and helper functions.
 */
abstract contract XXYYZZCore is ERC721, IERC4906, CommitReveal, Ownable {
    error InvalidPayment();
    error InvalidHex();
    error MaximumSupplyExceeded();
    error AlreadyFinalized();
    error OnlyTokenOwner();
    error NoIdsProvided();
    error OwnerMismatch();
    error BatchBurnerNotApprovedForAll();
    error ArrayLengthMismatch();
    error MintClosed();
    error InvalidTimestamp();
    error OnlyFinalized();
    error Unavailable();
    error NoneAvailable();
    error MaxBatchSizeExceeded();

    uint256 public constant MINT_PRICE = 0.005 ether;
    uint256 public constant REROLL_PRICE = 0.00025 ether;
    uint256 public constant FINALIZE_PRICE = 0.005 ether;
    uint256 public constant REROLL_AND_FINALIZE_PRICE = 0.00525 ether;
    uint256 public immutable MAX_SPECIFIC_BATCH_SIZE;

    uint256 constant BYTES3_UINT_SHIFT = 232;
    uint256 constant MAX_UINT24 = 0xFFFFFF;
    uint96 constant FINALIZED = 1;
    uint96 constant NOT_FINALIZED = 0;

    // re-declared from solady ERC721 for custom gas optimizations
    uint256 private constant _ERC721_MASTER_SLOT_SEED = 0x7d8825530a5a2e7a << 192;

    mapping(uint256 tokenId => address finalizer) public finalizers;
    uint128 _numBurned;
    uint128 _numMinted;

    constructor(address initialOwner, uint256 maxBatchSize)
        // lifespan
        CommitReveal(
            1 days,
            // delay – MM/RPC will report a tx will revert until first eligible block is validated,
            // so 48 seconds will result in 60 seconds of delay before the frontend will report
            // that a tx will succeed
            48 seconds
        )
    {
        _initializeOwner(initialOwner);
        MAX_SPECIFIC_BATCH_SIZE = maxBatchSize;
    }

    receive() external payable {
        // send ether – see what happens! :)
    }

    ///////////////////
    // OWNER METHODS //
    ///////////////////

    /**
     * @notice Withdraws all funds from the contract to the current owner. onlyOwner.
     */
    function withdraw() public onlyOwner {
        assembly ("memory-safe") {
            let succ := call(gas(), caller(), selfbalance(), 0, 0, 0, 0)
            // revert with returndata if call failed
            if iszero(succ) {
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }
        }
    }

    ///////////////////
    // INFORMATIONAL //
    ///////////////////

    /**
     * @notice Get the total number of tokens in circulation
     */
    function totalSupply() public view returns (uint256) {
        return _numMinted - _numBurned;
    }

    /**
     * @notice Get the total number of tokens minted
     */
    function numMinted() external view returns (uint256) {
        return _numMinted;
    }

    /**
     * @notice Get the total number of tokens burned
     */
    function numBurned() external view returns (uint256) {
        return _numBurned;
    }

    /**
     * @notice Get the name of the token
     */
    function name() public pure override returns (string memory) {
        // note that this is unsafe to call internally, as it abi-encodes the name and
        // performs a low-level return
        assembly {
            mstore(0x20, 0x20)
            mstore(0x46, 0x06585859595a5a)
            return(0x20, 0x80)
        }
    }

    /**
     * @notice Get the symbol of the token
     */
    function symbol() public pure override returns (string memory) {
        // note that this is unsafe to call internally, as it abi-encodes the symbol and
        // performs a low-level return
        assembly {
            mstore(0x20, 0x20)
            mstore(0x46, 0x06585859595a5a)
            return(0x20, 0x80)
        }
    }

    /**
     * @notice Check if a specific token ID has been finalized. Will return true for tokens that were finalized and
     *         then burned. Will not revert if the tokenID does not currently exist. Will revert on invalid tokenIds.
     * @param id The token ID to check
     * @return True if the token ID has been finalized, false otherwise
     */
    function isFinalized(uint256 id) public view returns (bool) {
        _validateId(id);
        return _isFinalized(id);
    }

    ///@inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId)
        public
        pure
        virtual
        override(ERC721, IERC165)
        returns (bool result)
    {
        assembly {
            let s := shr(224, interfaceId)
            // ERC165: 0x01ffc9a7, ERC721: 0x80ac58cd, ERC721Metadata: 0x5b5e139f. ERC4906: 0x49064906
            result := or(or(or(eq(s, 0x01ffc9a7), eq(s, 0x80ac58cd)), eq(s, 0x5b5e139f)), eq(s, 0x49064906))
        }
    }

    /////////////////
    // COMMITMENTS //
    /////////////////

    /**
     * @notice Get a commitment hash for a given sender, tokenId, and salt. Note that this could expose your desired
     *         ID to the RPC provider. Won't revert if the ID is invalid, but will return an invalid hash.
     * @param sender The address of the account that will mint or reroll the token ID
     * @param id The 6-hex-digit token ID to mint or reroll
     * @param salt The salt to use for the commitment
     */
    function computeCommitment(address sender, uint256 id, bytes32 salt)
        public
        pure
        returns (bytes32 committmentHash)
    {
        assembly ("memory-safe") {
            // shift sender left by 24 bits; id stays in bottom 24
            mstore(0, or(shl(24, sender), and(id, MAX_UINT24)))
            mstore(0x20, salt)
            // start hashing at 0x09 to skip 9 empty bytes (32 - (20 + 3))
            committmentHash := keccak256(0x09, 0x40)
        }
    }

    /**
     * @notice Get a commitment hash for a given sender, array of tokenIds, and salt. This allows for a single
     *         commitment for a batch of IDs, but note that order and length of IDs matters.
     *         If 5 IDs are passed, all 5 must be passed to either batchMintSpecific or batchRerollSpecific, in the
     *         same order. Note that this could expose your desired IDs to the RPC provider.
     *         Won't revert if any IDs are invalid or duplicated.
     * @param sender The address of the account that will mint or reroll the token IDs
     * @param ids The 6-hex-digit token IDs to mint or reroll
     * @param salt The salt to use for the batch commitment
     */
    function computeBatchCommitment(address sender, uint256[] calldata ids, bytes32 salt)
        public
        pure
        returns (bytes32 commitmentHash)
    {
        assembly ("memory-safe") {
            // cache free mem pointer
            let freeMemPtr := mload(0x40)
            // multiply length of elements by 32 bytes for each element
            let numBytes := shl(5, ids.length)
            // copy contents of array to unallocated free memory
            calldatacopy(freeMemPtr, ids.offset, numBytes)
            // hash contents of array, without length
            let arrayHash :=
                keccak256(
                    // start of array contents
                    freeMemPtr,
                    //length of array contents
                    numBytes
                )

            // store sender in first memory slot
            mstore(0, sender)
            // store array hash in second memory slot
            mstore(0x20, arrayHash)
            // clobber free memory pointer with salt
            mstore(0x40, salt)
            // compute commitment hash
            // start hashing at 12 bytes since addresses are 20 bytes
            commitmentHash := keccak256(0x0c, 0x60)
            // restore free memory pointer
            mstore(0x40, freeMemPtr)
        }
    }

    /////////////
    // HELPERS //
    /////////////

    /**
     * @dev Mint a token with a specific hex value and validate it was committed to
     * @param id The 6-hex-digit token ID to mint
     * @param salt The salt to use for the commitment
     */
    function _mintSpecific(uint256 id, bytes32 salt) internal {
        bytes32 computedCommitment = computeCommitment(msg.sender, id, salt);

        // validate ID is valid 6-hex-digit number
        _validateId(id);
        // validate commitment to prevent front-running
        _assertCommittedReveal(computedCommitment);

        // don't allow minting of tokens that were finalized and then burned
        if (_isFinalized(id)) {
            revert AlreadyFinalized();
        }
        _mint(msg.sender, id);
    }

    /**
     * @dev Mint a token with a specific hex value and validate it was committed to
     * @param id The 6-hex-digit token ID to mint
     * @param computedCommitment The commitment hash to validate
     */
    function _mintSpecificWithCommitment(uint256 id, bytes32 computedCommitment) internal {
        // validate ID is valid 6-hex-digit number
        _validateId(id);
        // validate commitment to prevent front-running
        _assertCommittedReveal(computedCommitment);

        // don't allow minting of tokens that were finalized and then burned
        if (_packedOwnershipSlot(id) != 0) {
            revert AlreadyFinalized();
        }
        _mint(msg.sender, id);
    }

    /**
     * @dev Mint a token with a specific hex value without validating it was committed to
     * @param id The 6-hex-digit token ID to mint
     * @return True if the token was minted, false otherwise
     */
    function _mintSpecificUnprotected(uint256 id) internal returns (bool) {
        // validate ID is valid 6-hex-digit number
        _validateId(id);
        // don't allow minting of tokens that exist or were finalized and then burned
        if (_packedOwnershipSlot(id) != 0) {
            // return false indicating a no-op
            return false;
        }
        // otherwise mint the token
        _mint(msg.sender, id);
        return true;
    }

    /**
     * @dev Find the first unminted token ID based on the current number minted and PREVRANDAO
     * @param seed The seed to use for the random number generation – when minting, should be _numMinted, when
     *             re-rolling, should be a function of the caller. In the case of re-rolling, this means that if a single caller makes
     *             multiple re-rolls in the same block, there will be collisions. This is fine, as the extra gas  cost
     *             discourages batch re-rolling with bots or scripts (at least from the same address).
     */
    function _findAvailableHex(uint256 seed) internal view returns (uint256) {
        uint256 tokenId;
        assembly {
            mstore(0, seed)
            mstore(0x20, prevrandao())
            // hash the two values together and then mask to a uint24
            // seed is max an address, so start hashing at 0x0c
            tokenId := and(keccak256(0x0c, 0x40), MAX_UINT24)
        }
        // check for the small chance that the token ID is already minted or finalized – if so, increment until we
        // find one that isn't
        while (_packedOwnershipSlot(tokenId) != 0) {
            // safe to do unchecked math here as it is modulo 2^24
            unchecked {
                tokenId = (tokenId + 1) & MAX_UINT24;
            }
        }
        return tokenId;
    }

    ///@dev Check if an ID is a valid six-hex-digit number
    function _validateId(uint256 xxyyzz) internal pure {
        if (xxyyzz > MAX_UINT24) {
            revert InvalidHex();
        }
    }

    ///@dev Validate msg value is equal to total price
    function _validatePayment(uint256 unitPrice, uint256 quantity) internal view {
        // can't overflow because there are at most uint24 tokens, and existence is checked for each token down the line
        unchecked {
            if (msg.value != (unitPrice * quantity)) {
                revert InvalidPayment();
            }
        }
    }

    /**
     * @dev Refund any overpayment
     * @param unitPrice The price per action (mint, reroll, reroll+finalize)
     * @param availableQuantity The number of tokens (mints, rerolls) that were actually available for purchase
     */
    function _refundOverpayment(uint256 unitPrice, uint256 availableQuantity) internal {
        unchecked {
            // can't underflow because payment was already validated; even if it did, value would be larger than ether
            // supply
            uint256 overpayment = msg.value - (unitPrice * availableQuantity);
            if (overpayment != 0) {
                SafeTransferLib.safeTransferETH(msg.sender, overpayment);
            }
        }
    }

    /**
     * @dev Check if a specific token has been finalized. Does not check if token exists.
     * @param id The 6-hex-digit token ID to check
     */
    function _isFinalized(uint256 id) internal view returns (bool) {
        return _getExtraData(id) == FINALIZED;
    }

    /**
     * @dev Load the raw ownership slot for a given token ID, which contains both the owner and the extra data
     *      (finalization status). This allows for succint checking of whether or not a token is mintable,
     *      i.e., whether it does not currently exist and has not been finalized. It also allows for avoiding
     *      an extra SLOAD in cases when checking both owner/existence and finalization status.
     * @param id The 6-hex-digit token ID to check
     */
    function _packedOwnershipSlot(uint256 id) internal view returns (uint256 result) {
        assembly {
            // since all ids are < uint24, this basically just clears the 0-slot before writing 4 bytes of slot seed
            mstore(0x00, id)
            mstore(0x1c, _ERC721_MASTER_SLOT_SEED)
            result := sload(add(id, add(id, keccak256(0x00, 0x20))))
        }
    }

    function _checkCallerIsOwnerAndNotFinalized(uint256 id) internal view {
        uint256 packedSlot = _packedOwnershipSlot(id);
        // clean and cast to address
        address owner = address(uint160(packedSlot));
        if ((packedSlot) > type(uint160).max) {
            revert AlreadyFinalized();
        }
        // check that caller is owner
        if (owner != msg.sender) {
            revert OnlyTokenOwner();
        }
    }

    /**
     * @dev Check that array lengths match, the batch size is not too large, and that the payment is correct
     * @param a The first array to check
     * @param b The second array to check
     * @param unitPrice The price per action (mint, reroll, reroll+finalize)
     */
    function _validateRerollBatchAndPayment(uint256[] calldata a, uint256[] calldata b, uint256 unitPrice)
        internal
        view
    {
        if (a.length != b.length) {
            revert ArrayLengthMismatch();
        }
        if (a.length > MAX_SPECIFIC_BATCH_SIZE) {
            revert MaxBatchSizeExceeded();
        }
        _validatePayment(a.length, unitPrice);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {XXYYZZCore} from "./XXYYZZCore.sol";
import {LibString} from "solady/utils/LibString.sol";
import {Base64} from "solady/utils/Base64.sol";

/**
 * @title XXYYZZMetadata
 * @author emo.eth
 * @notice XXYYZZMetadata implements the onchain metadata for XXYYZZ tokens.
 */
abstract contract XXYYZZMetadata is XXYYZZCore {
    using LibString for uint256;
    using LibString for address;
    using Base64 for bytes;

    /**
     * @notice Return the base64-encoded token metadata. Won't revert if the token doesn't exist.
     *         Will revert if the id is not a valid six-hex-digit ID.
     */
    function tokenURI(uint256 id) public view virtual override returns (string memory) {
        _validateId(id);
        return string.concat("data:application/json;base64,", bytes(_stringURI(id)).encode());
    }

    ///@notice Return the base64-encoded contract-level metadata
    function contractURI() public pure returns (string memory) {
        return string.concat("data:application/json;base64,", bytes(_stringContractURI()).encode());
    }

    ///@dev Return a token-level JSON string
    function _stringURI(uint256 id) internal view virtual returns (string memory) {
        return string.concat(
            "{",
            _kv("name", _name(id)),
            ",",
            _kv("external_link", "https://xxyyzz.art"),
            ",",
            _kv(
                "description",
                "Proof of color. XXYYZZ is a collection of fully onchain, unique, composable, and collectable colors."
            ),
            ",",
            _kv("image", _imageURI(id)),
            ",",
            _kRawV("attributes", _traits(id)),
            "}"
        );
    }

    ///@dev Return a contract-level JSON string
    function _stringContractURI() internal pure returns (string memory) {
        return
        '{"name":"XXYYZZ","description":"Collectible, composable, and unique onchain colors.","external_link":"https://xxyyzz.art"}';
    }

    ///@dev Return a name like "#aabbcc"
    function _name(uint256 id) internal pure returns (string memory) {
        return string.concat("#", id.toHexStringNoPrefix({length: 3}));
    }

    ///@dev Return an svg as a base64-encoded data uri string
    function _imageURI(uint256 id) internal pure returns (string memory) {
        return string.concat("data:image/svg+xml;base64,", bytes(_svg(id)).encode());
    }

    ///@dev Return a 690x690 SVG with a single rect of the token's color
    function _svg(uint256 id) internal pure returns (string memory) {
        return string.concat(
            '<svg xmlns="http://www.w3.org/2000/svg" width="690" height="690"><rect width="690" height="690" fill="#',
            id.toHexStringNoPrefix({length: 3}),
            '" /></svg>'
        );
    }

    ///@dev Return a JSON array of {"trait_type":"key","value":"value"} pairs
    function _traits(uint256 id) internal view returns (string memory) {
        string memory color = _trait("Color", _name(id));
        if (isFinalized(id)) {
            string memory finalizedProp = _trait("Finalized", "Yes");
            return string.concat(
                "[", color, ",", finalizedProp, ",", _trait("Finalizer", finalizers[id].toHexString()), "]"
            );
        } else {
            return string.concat("[", color, ",", _trait("Finalized", "No"), "]");
        }
    }

    ///@dev return a {"trait_type":"key","value":"value"} pair
    function _trait(string memory key, string memory value) internal pure returns (string memory) {
        return string.concat('{"trait_type":"', key, '","value":"', value, '"}');
    }

    ///@dev return a "key":"value" pair
    function _kv(string memory key, string memory value) internal pure returns (string memory) {
        return string.concat('"', key, '":"', value, '"');
    }

    ///@dev Return a "key":value pair without quoting value
    function _kRawV(string memory key, string memory value) internal pure returns (string memory) {
        return string.concat('"', key, '":', value);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {XXYYZZCore} from "./XXYYZZCore.sol";

/**
 * @title XXYYZZMint
 * @author emo.eth
 * @notice This contract handles minting of XXYYZZ tokens.
 *         Tokens may be minted with a pseudorandom hex value, or with a specific hex value.
 *         The "Specific" methods allow for minting tokens with specific hex values with a commit-reveal scheme.
 *         Users may protect themselves against front-running by
 */
abstract contract XXYYZZMint is XXYYZZCore {
    uint256 public immutable MAX_MINT_CLOSE_TIMESTAMP;

    constructor(address initialOwner, uint256 maxBatchSize) XXYYZZCore(initialOwner, maxBatchSize) {
        MAX_MINT_CLOSE_TIMESTAMP = block.timestamp + 14 days;
    }

    //////////
    // MINT //
    //////////

    /**
     * @notice Mint a token with a pseudorandom hex value.
     * @return The token ID
     */
    function mint() public payable returns (uint256) {
        uint256 newAmount = _checkMintAndIncrementNumMinted(1);
        // get pseudorandom hex id – doesn't need to be derived from caller
        uint256 tokenId = _findAvailableHex(newAmount);
        _mint(msg.sender, tokenId);
        return tokenId;
    }

    /**
     * @notice Mint a number of tokens with pseudorandom hex values.
     * @param quantity The number of tokens to mint
     * @return The token IDs
     */
    function mint(uint256 quantity) public payable returns (uint256[] memory) {
        return _checkMintTo(msg.sender, quantity);
    }

    function mintTo(address to, uint256 quantity) public payable returns (uint256[] memory) {
        return _checkMintTo(to, quantity);
    }

    /**
     * @notice Mint a token with a specific hex value.
     *         A user must first call commit(bytes32) or batchCommit(bytes32[]) with the result(s) of
     *         computeCommittment(address,uint256,bytes32), and wait at least one minute.
     *         When calling mintSpecific, the "salt" should be the bytes32 salt provided to `computeCommitment` when
     *         creating the commitment hash.
     *
     *         Example: To register 0x123456 with salt bytes32(0xDEADBEEF)
     *             1. Call `computeCommitment(<minting addr>, 0x123456, bytes32(0xDEADBEEF))` for `bytes32 result`
     *             2. Call `commit(result)`
     *             3. Wait at least 1 minute, but less than 1 day
     *             4. Call `mintSpecific(0x123456, bytes32(0xDEADBEEF))`
     * @param id The 6-hex-digit token ID to mint
     * @param salt The salt used in the commitment for the commitment
     */
    function mintSpecific(uint256 id, bytes32 salt) public payable {
        _checkMintAndIncrementNumMinted(1);
        _mintSpecific(id, salt);
    }

    /**
     * @notice Mint a number of tokens with specific hex values.
     *         A user must first call commit(bytes32) with the result of
     *         `computeBatchCommitment(address,uint256[],bytes32)`, and wait at least COMMITMENT_LIFESPAN seconds.
     * @param ids The 6-hex-digit token IDs to mint
     * @param salt The salt used in the batch commitment
     * @return An array of booleans indicating whether each token was minted
     */
    function batchMintSpecific(uint256[] calldata ids, bytes32 salt) public payable returns (bool[] memory) {
        _validateBatchMintAndTimestamp(ids);
        bytes32 computedCommitment = computeBatchCommitment(msg.sender, ids, salt);
        _assertCommittedReveal(computedCommitment);
        return _batchMintAndIncrementAndRefund(ids);
    }

    /////////////
    // HELPERS //
    /////////////

    /**
     * @dev Mint tokens, validate that tokens were minted, and increment the number of minted tokens
     * @param to Recipient of the tokens
     * @param quantity Number of tokens to mint
     */
    function _checkMintTo(address to, uint256 quantity) internal returns (uint256[] memory) {
        // check payment and quantity once
        uint256 newAmount = _checkMintAndIncrementNumMinted(quantity);
        return _mintTo(to, quantity, newAmount);
    }

    /**
     * @dev Mint tokens, validate that tokens were minted, and increment the number of minted tokens
     * @param to Recipient of the tokens
     * @param quantity Number of tokens to mint
     */
    function _mintTo(address to, uint256 quantity, uint256 newAmount) internal returns (uint256[] memory) {
        uint256[] memory tokenIds = new uint256[](quantity);
        for (uint256 i; i < quantity;) {
            // get pseudorandom hex id
            uint256 tokenId = _findAvailableHex(newAmount);
            _mint(to, tokenId);
            tokenIds[i] = tokenId;
            unchecked {
                ++i;
                ++newAmount;
            }
        }
        return tokenIds;
    }

    /**
     * @dev Mint tokens, validate that tokens were minted, increment the number of minted tokens, and refund any
     *      overpayment
     * @param ids The 6-hex-digit token IDs to mint
     */
    function _batchMintAndIncrementAndRefund(uint256[] calldata ids) internal returns (bool[] memory) {
        bool[] memory minted = new bool[](ids.length);
        uint256 quantityMinted;
        for (uint256 i; i < ids.length;) {
            if (_mintSpecificUnprotected(ids[i])) {
                minted[i] = true;
                unchecked {
                    ++quantityMinted;
                }
            }
            unchecked {
                ++i;
            }
        }
        if (quantityMinted == 0) {
            revert NoneAvailable();
        }

        _incrementNumMintedAndRefundOverpayment(quantityMinted);
        return minted;
    }

    /**
     * @dev Check payment and quantity validation – quantityRequested for payment, quantityAvailable for updating
     *      the number of minted tokens, which may be different
     * @param quantityRequested The number of tokens requested by the user, which must be paid for
     * @return The new number of minted tokens
     */
    function _checkMintAndIncrementNumMinted(uint256 quantityRequested) internal returns (uint256) {
        if (block.timestamp > MAX_MINT_CLOSE_TIMESTAMP) {
            revert MintClosed();
        }
        _validatePayment(MINT_PRICE, quantityRequested);

        // increment supply before minting
        uint128 newAmount;
        // this can be unchecked because an ID can only be minted once, and all IDs are later validated to be uint24s
        unchecked {
            newAmount = _numMinted + uint128(quantityRequested);
        }
        _numMinted = newAmount;
        return newAmount;
    }

    /**
     * @dev Increment the number of minted tokens and refund any overpayment
     * @param quantity The number of tokens actually minted
     */
    function _incrementNumMintedAndRefundOverpayment(uint256 quantity) internal returns (uint256) {
        uint256 newAmount;
        // this can be unchecked because an ID can only be minted once, and all IDs are validated to be uint24s
        // overflow here implies invalid IDs down the line, which will cause a revert when minting
        unchecked {
            newAmount = _numMinted + quantity;
        }
        _numMinted = uint32(newAmount);
        _refundOverpayment(MINT_PRICE, quantity);
        return newAmount;
    }

    /**
     * @dev Validate the timestamp and payment for a batch mint
     * @param ids The 6-hex-digit token IDs to mint
     */
    function _validateBatchMintAndTimestamp(uint256[] calldata ids) internal view {
        if (block.timestamp > MAX_MINT_CLOSE_TIMESTAMP) {
            revert MintClosed();
        }
        if (ids.length > MAX_SPECIFIC_BATCH_SIZE) {
            revert MaxBatchSizeExceeded();
        }
        _validatePayment(ids.length, MINT_PRICE);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {XXYYZZCore} from "./XXYYZZCore.sol";

/**
 * @title XXYYZZRerollFinalize
 * @author emo.eth
 * @notice This contract handles "rerolling" and "finalizing" tokens.
 *         Rerolling allows users to burn a token they own in exchange for a new one. The new token may be either
 *         pseudorandom, or a specific color when using one of the "Specific" methods.
 *         Finalizing allows users to prevent a token from being rerolled again, in addition to adding their
 *         wallet address to the token's metadata as the "Finalizer" trait.
 */
abstract contract XXYYZZRerollFinalize is XXYYZZCore {
    ////////////
    // REROLL //
    ////////////
    /**
     * @notice Burn a token you own and mint a new one with a pseudorandom hex value.
     * @param oldId The 6-hex-digit token ID to burn
     * @return The new token ID
     */
    function reroll(uint256 oldId) public payable returns (uint256) {
        _validatePayment(REROLL_PRICE, 1);
        // use the caller as the seed to derive the new token ID
        // this means multiple calls in the same block will be gas-inefficient
        // which may somewhat discourage botting
        return _rerollWithSeed(oldId, uint160(msg.sender));
    }

    /**
     * @notice Burn a number of tokens you own and mint new ones with pseudorandom hex values.
     * @param ids The 6-hex-digit token IDs to burn in exchange for new tokens
     * @return The new token IDs
     */
    function batchReroll(uint256[] calldata ids) public payable returns (uint256[] memory) {
        _validatePayment(REROLL_PRICE, ids.length);
        // use the caller as the seed to derive the new token IDs
        // this means multiple calls in the same block will be gas-inefficient
        // which may somewhat discourage botting
        uint256 seed = uint256(uint160(msg.sender));
        uint256[] memory newIds = new uint256[](ids.length);
        for (uint256 i; i < ids.length;) {
            newIds[i] = _rerollWithSeed(ids[i], seed);
            unchecked {
                ++i;
                ++seed;
            }
        }
        return newIds;
    }

    /**
     * @notice Burn and re-mint a token with a specific hex ID. Uses a commit-reveal scheme to prevent front-running.
     *         Only callable by the owner of the token. Users must call `commit(bytes32)` with the result of
     *         `computeCommitment(address,uint256,bytes32)` and wait at least COMMITMENT_LIFESPAN seconds before
     *         calling `rerollSpecific`.
     * @param oldId The 6-hex-digit token ID to burn
     * @param newId The 6-hex-digit token ID to mint
     * @param salt The salt used in the commitment for the new ID commitment
     */
    function rerollSpecific(uint256 oldId, uint256 newId, bytes32 salt) public payable {
        _validatePayment(REROLL_PRICE, 1);
        _rerollSpecificWithSalt(oldId, newId, salt);
    }

    /**
     * @notice Burn and re-mint a number of tokens with specific hex values. Uses a commit-reveal scheme to prevent
     *         front-running. Only callable by the owner of the tokens. Users must call `commit(bytes32)` with the
     *         result of `computeBatchCommitment(address,uint256[],bytes32)` and wait at least COMMITMENT_LIFESPAN
     *         seconds before calling `batchRerollSpecific`.
     * @param oldIds The 6-hex-digit token IDs to burn
     * @param newIds The 6-hex-digit token IDs to mint
     * @param salt The salt used in the commitment for the new IDs commitment
     * @return An array of booleans indicating whether each token was successfully rerolled
     */
    function batchRerollSpecific(uint256[] calldata oldIds, uint256[] calldata newIds, bytes32 salt)
        public
        payable
        returns (bool[] memory)
    {
        _validateRerollBatchAndPayment(oldIds, newIds, REROLL_PRICE);
        bytes32 computedCommitment = computeBatchCommitment(msg.sender, newIds, salt);
        _assertCommittedReveal(computedCommitment);

        return _batchRerollAndRefund(oldIds, newIds);
    }

    /**
     * @notice Burn and re-mint a token with a specific hex ID, then finalize it. Uses a commit-reveal scheme to
     *         prevent front-running. Only callable by the owner of the token. Users must call `commit(bytes32)`
     *         with the result of `computeCommitment(address,uint256,bytes32)` and wait at least COMMITMENT_LIFESPAN
     *         seconds before calling `rerollSpecificAndFinalize`.
     * @param oldId The 6-hex-digit token ID to burn
     * @param newId The 6-hex-digit token ID to mint
     * @param salt The salt used in the commitment for the new ID commitment
     */
    function rerollSpecificAndFinalize(uint256 oldId, uint256 newId, bytes32 salt) public payable {
        _validatePayment(REROLL_AND_FINALIZE_PRICE, 1);

        _rerollSpecificWithSalt(oldId, newId, salt);
        // won't re-validate price, but above function already did
        _finalizeToken(newId, msg.sender);
    }

    /**
     * @notice Burn and re-mint a number of tokens with specific hex values, then finalize them.
     * @param oldIds The 6-hex-digit token IDs to burn
     * @param newIds The 6-hex-digit token IDs to mint
     * @param salt The salt used in the batch commitment for the new ID commitment
     * @return An array of booleans indicating whether each token was successfully rerolled
     */
    function batchRerollSpecificAndFinalize(uint256[] calldata oldIds, uint256[] calldata newIds, bytes32 salt)
        public
        payable
        returns (bool[] memory)
    {
        _validateRerollBatchAndPayment(oldIds, newIds, REROLL_AND_FINALIZE_PRICE);
        bytes32 computedCommitment = computeBatchCommitment(msg.sender, newIds, salt);
        _assertCommittedReveal(computedCommitment);
        return _batchRerollAndFinalizeAndRefund(oldIds, newIds);
    }

    //////////////
    // FINALIZE //
    //////////////

    /**
     * @notice Finalize a token, which updates its metadata with a "Finalizer" trait and prevents it from being
     *         rerolled in the future.
     * @param id The 6-hex-digit token ID to finalize. Must be owned by the caller.
     */
    function finalize(uint256 id) public payable {
        _validatePayment(FINALIZE_PRICE, 1);
        _finalize(id);
    }

    /**
     * @notice Finalize a number of tokens, which updates their metadata with a "Finalizer" trait and prevents them
     *         from being rerolled in the future. The caller must pay the finalization price for each token, and must
     *         own all tokens.
     * @param ids The 6-hex-digit token IDs to finalize
     */
    function batchFinalize(uint256[] calldata ids) public payable {
        _validatePayment(FINALIZE_PRICE, ids.length);
        for (uint256 i; i < ids.length;) {
            _finalize(ids[i]);
            unchecked {
                ++i;
            }
        }
    }

    //////////////
    // INTERNAL //
    //////////////

    /**
     * @dev Internal function to burn and re-mint tokens with a specific hex ID. Does not check initial payment.
     *      Does refund any overpayment.
     * @param oldIds The 6-hex-digit token IDs to burn
     * @param newIds The 6-hex-digit token IDs to mint
     * @return An array of booleans indicating whether each token was successfully rerolled
     */
    function _batchRerollAndRefund(uint256[] calldata oldIds, uint256[] calldata newIds)
        internal
        returns (bool[] memory)
    {
        bool[] memory rerolled = new bool[](oldIds.length);
        uint256 quantityRerolled;
        for (uint256 i; i < oldIds.length;) {
            if (_rerollSpecificUnprotected(oldIds[i], newIds[i])) {
                rerolled[i] = true;
                unchecked {
                    ++quantityRerolled;
                }
            }
            unchecked {
                ++i;
            }
        }
        // if none were rerolled, revert to avoid wasting further gas
        if (quantityRerolled == 0) {
            revert NoneAvailable();
        }
        // refund any overpayment
        _refundOverpayment(REROLL_PRICE, quantityRerolled);

        return rerolled;
    }

    /**
     * @dev Internal function to burn and re-mint tokens with a specific hex ID, then finalize them. Does not check
     *     initial payment. Does refund any overpayment.
     * @param oldIds The 6-hex-digit token IDs to burn
     * @param newIds The 6-hex-digit token IDs to mint
     * @return An array of booleans indicating whether each token was successfully rerolled
     */
    function _batchRerollAndFinalizeAndRefund(uint256[] calldata oldIds, uint256[] calldata newIds)
        internal
        returns (bool[] memory)
    {
        bool[] memory rerolled = new bool[](oldIds.length);
        uint256 quantityRerolled;
        for (uint256 i; i < oldIds.length;) {
            if (_rerollSpecificUnprotected(oldIds[i], newIds[i])) {
                _finalizeToken(newIds[i], msg.sender);
                rerolled[i] = true;
                unchecked {
                    ++quantityRerolled;
                }
            }
            unchecked {
                ++i;
            }
        }
        // if none were rerolled, revert to avoid wasting gas
        if (quantityRerolled == 0) {
            revert NoneAvailable();
        }
        // refund any overpayment
        _refundOverpayment(REROLL_AND_FINALIZE_PRICE, quantityRerolled);

        return rerolled;
    }

    /**
     * @dev Validate an old tokenId is rerollable, burn it, then mint a token with a pseudorandom
     *      hex ID.
     * @param oldId The old ID to reroll
     * @param seed The seed to use for the reroll
     *
     */
    function _rerollWithSeed(uint256 oldId, uint256 seed) internal returns (uint256) {
        _checkCallerIsOwnerAndNotFinalized(oldId);
        // burn old token
        _burn(oldId);
        uint256 tokenId = _findAvailableHex(seed);
        _mint(msg.sender, tokenId);
        return tokenId;
    }

    /**
     * @dev Validate an old tokenId is rerollable, burn it, then mint a token with a specific
     *     hex ID, validating that the commit-reveal scheme was followed.
     * @param oldId The old ID to reroll
     * @param newId The new ID to mint
     * @param salt The salt used in the commit-reveal scheme
     */
    function _rerollSpecificWithSalt(uint256 oldId, uint256 newId, bytes32 salt) internal {
        _checkCallerIsOwnerAndNotFinalized(oldId);
        // burn old token
        _burn(oldId);
        _mintSpecific(newId, salt);
    }

    /**
     * @dev Validate an old tokenId is rerollable, mint a token with a specific new hex ID (if available)
     *      and burn the old token.
     * @param oldId The old ID to reroll
     * @param newId The new ID to mint
     * @return Whether the mint succeeded, ie, the new ID was available
     */
    function _rerollSpecificUnprotected(uint256 oldId, uint256 newId) internal returns (bool) {
        _checkCallerIsOwnerAndNotFinalized(oldId);
        // only burn old token if mint succeeded
        if (_mintSpecificUnprotected(newId)) {
            _burn(oldId);
            return true;
        }
        return false;
    }

    /**
     * @dev Internal function to finalize a token, first checking that the caller is the owner and that the token
     *      has not already been finalized.
     * @param id The 6-hex-digit token ID to finalize
     */
    function _finalize(uint256 id) internal {
        _checkCallerIsOwnerAndNotFinalized(id);
        // set finalized flag
        _finalizeToken(id, msg.sender);
        // emit onchain metadata update event
        emit MetadataUpdate(id);
    }

    /**
     * @dev Finalize a tokenId, updating its metadata with a "Finalizer" trait, and preventing it from being rerolled in the future.
     * @param id The 6-hex-digit token ID to finalize
     * @param finalizer The address of the account finalizing the token
     */
    function _finalizeToken(uint256 id, address finalizer) internal {
        finalizers[id] = finalizer;
        _setExtraData(id, 1);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {XXYYZZMint} from "./XXYYZZMint.sol";
import {ISeaDrop, PublicDrop} from "./lib/SeaDropSpecific.sol";

abstract contract XXYYZZSeaDrop is XXYYZZMint {
    error OnlySeadrop();

    address immutable SEADROP;
    address immutable CREATOR_PAYOUT;
    uint256 immutable DEPLOYED_TIME;

    uint256 private constant SEADROP_TOKEN_CREATED_EVENT_TOPIC =
        0xd7aca75208b9be5ffc04c6a01922020ffd62b55e68e502e317f5344960279af8;
    address private constant SEADROP_FEE_RECIPIENT = 0x0000a26b00c1F0DF003000390027140000fAa719;
    address private constant SEADROP_ALLOWED_PAYER_1 = 0xf408Bee3443D0397e2c1cdE588Fb060AC657006F;
    address private constant SEADROP_ALLOWED_PAYER_2 = 0xE3d3D0eD702504e19825f44BC6542Ff2ec45cB9A;
    uint256 private constant INONFUNGIBLESEADROP_INTERFACE_ID = 0x1890fe8e;

    constructor(address seadrop, address creatorPayout, address initialOwner, uint256 maxBatchSize)
        XXYYZZMint(initialOwner, maxBatchSize)
    {
        SEADROP = seadrop;
        DEPLOYED_TIME = block.timestamp;
        CREATOR_PAYOUT = creatorPayout;

        // log without adding event to abi
        assembly {
            log1(0, 0, SEADROP_TOKEN_CREATED_EVENT_TOPIC)
        }
    }

    /**
     * @notice Configure the SeaDrop contract. onlyOwner.
     * @dev SeaDrop calls supportsInterface, so this unfortunately can't live in the constructor.
     */
    function configureSeaDrop() external onlyOwner {
        ISeaDrop seadrop = ISeaDrop(SEADROP);
        seadrop.updatePublicDrop(
            PublicDrop({
                mintPrice: uint80(0.005 ether),
                startTime: uint48(DEPLOYED_TIME),
                endTime: uint48(MAX_MINT_CLOSE_TIMESTAMP),
                maxTotalMintableByWallet: type(uint16).max,
                feeBps: uint16(1000),
                restrictFeeRecipients: true
            })
        );
        seadrop.updateCreatorPayoutAddress(CREATOR_PAYOUT);
        seadrop.updateAllowedFeeRecipient(SEADROP_FEE_RECIPIENT, true);
        seadrop.updatePayer(SEADROP_ALLOWED_PAYER_1, true);
        seadrop.updatePayer(SEADROP_ALLOWED_PAYER_2, true);
    }

    function mintSeaDrop(address recipient, uint256 quantity) external {
        if (msg.sender != SEADROP) {
            revert OnlySeadrop();
        }
        // increment supply before minting
        uint128 newAmount;
        // this can be unchecked because an ID can only be minted once, and all IDs are later validated to be uint24s
        unchecked {
            newAmount = _numMinted + uint128(quantity);
        }
        _numMinted = newAmount;
        _mintTo(recipient, quantity, newAmount);
    }

    /**
     * @dev See {IERC165-supportsInterface}. Overridden to support SeaDrop.
     */
    function supportsInterface(bytes4 interfaceId) public pure virtual override returns (bool result) {
        assembly {
            let s := shr(224, interfaceId)
            // ERC165: 0x01ffc9a7, ERC721: 0x80ac58cd, ERC721Metadata: 0x5b5e139f. ERC4906: 0x49064906
            result :=
                or(
                    or(or(or(eq(s, 0x01ffc9a7), eq(s, 0x80ac58cd)), eq(s, 0x5b5e139f)), eq(s, 0x49064906)),
                    eq(s, INONFUNGIBLESEADROP_INTERFACE_ID)
                )
        }
    }

    /**
     * @dev Hard-coded for SeaDrop support
     */
    function getMintStats(address) external view returns (uint256, uint256, uint256) {
        return (0, _numMinted, 16777216);
    }

    /**
     * @dev Hard-coded for SeaDrop support
     */
    function maxSupply() external pure returns (uint256) {
        return 16777216;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IERC165} from "forge-std/interfaces/IERC165.sol";

interface IERC4906 is IERC165 {
    /// @dev This event emits when the metadata of a token is changed.
    /// So that the third-party platforms such as NFT market could
    /// timely update the images and related attributes of the NFT.
    event MetadataUpdate(uint256 _tokenId);

    /// @dev This event emits when the metadata of a range of tokens is changed.
    /// So that the third-party platforms such as NFT market could
    /// timely update the images and related attributes of the NFTs.
    event BatchMetadataUpdate(uint256 _fromTokenId, uint256 _toTokenId);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract CommitReveal {
    error InvalidCommitment(uint256 committedTimestamp);

    uint256 private constant INVALID_COMMITMENT_SELECTOR = 0x31e63ea0;

    uint256 public immutable COMMITMENT_LIFESPAN;
    uint256 public immutable COMMITMENT_DELAY;

    constructor(uint256 commitmentLifespan, uint256 commitmentDelay) {
        COMMITMENT_LIFESPAN = commitmentLifespan;
        COMMITMENT_DELAY = commitmentDelay;
    }

    ///@dev mapping of user to key to commitment hash to timestamp.
    mapping(address user => mapping(bytes32 commitment => uint256 timestamp)) public commitments;

    /**
     * @notice Commit a hash to the contract, to be retrieved and verified after a delay. A commitment is valid only
     *         after COMMITMENT_DELAY seconds have passed, and is only valid for COMMITMENT_LIFESPAN seconds.
     * @param commitment The hash to commit.
     */
    function commit(bytes32 commitment) public {
        commitments[msg.sender][commitment] = block.timestamp;
    }

    /**
     * @dev Assert that a commitment has been made and is within a valid time
     *      window.
     * @param computedCommitmentHash The derived commitment hash to verify.
     */
    function _assertCommittedReveal(bytes32 computedCommitmentHash) internal view {
        // retrieve the timestamp of the commitment (if it exists)
        uint256 retrievedTimestamp = commitments[msg.sender][computedCommitmentHash];
        // compute the time difference
        uint256 timeDiff;
        // unchecked; assume blockchain time is monotonically increasing
        unchecked {
            timeDiff = block.timestamp - retrievedTimestamp;
        }
        uint256 commitmentLifespan = COMMITMENT_LIFESPAN;
        uint256 commitmentDelay = COMMITMENT_DELAY;
        assembly {
            // if the time difference is greater than the commitment lifespan,
            // the commitment has expired
            // if the time difference is less than the commitment delay, the
            // commitment is pending
            let invalidCommitment := or(gt(timeDiff, commitmentLifespan), lt(timeDiff, commitmentDelay))
            if invalidCommitment {
                mstore(0, INVALID_COMMITMENT_SELECTOR)
                mstore(0x20, retrievedTimestamp)
                revert(0x1c, 0x24)
            }
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

struct PublicDrop {
    uint80 mintPrice; // 80/256 bits
    uint48 startTime; // 128/256 bits
    uint48 endTime; // 176/256 bits
    uint16 maxTotalMintableByWallet; // 224/256 bits
    uint16 feeBps; // 240/256 bits
    bool restrictFeeRecipients; // 248/256 bits
}

interface ISeaDrop {
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
    function updateAllowedFeeRecipient(address feeRecipient, bool allowed) external;

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
}