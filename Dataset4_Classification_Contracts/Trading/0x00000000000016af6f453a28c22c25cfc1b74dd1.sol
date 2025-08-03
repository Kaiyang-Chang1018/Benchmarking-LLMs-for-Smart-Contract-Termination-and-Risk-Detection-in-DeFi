// SPDX-License-Identifier: MIT
// ERC721P Contracts v1.1

pragma solidity ^0.8.20;

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155P {

    /**
     * Cannot query the balance for the zero address.
     */
    error BalanceQueryForZeroAddress();

    /**
     * Arrays cannot be different lengths.
     */
    error ArrayLengthMismatch();

    /**
     * Cannot burn from the zero address.
     */
    error BurnFromZeroAddress();

    /**
     * Cannot mint to the zero address.
     */
    error MintToZeroAddress();

    /**
     * The quantity of tokens minted must be more than zero.
     */
    error MintZeroQuantity();

    /**
     * The quantity of tokens being burned is greater than account balance.
     */
    error BurnExceedsBalance();

    /**
     * The quantity of tokens being transferred is greater than account balance.
     */
    error TransferExceedsBalance();

    /**
     * The resulting token balance exceeds the maximum storable by ERC1155P
     */
    error ExceedsMaximumBalance();

    /**
     * The caller must own the token or be an approved operator.
     */
    error TransferCallerNotOwnerNorApproved();

    /**
     * Cannot safely transfer to a contract that does not implement the
     * ERC1155Receiver interface.
     */
    error TransferToNonERC1155ReceiverImplementer();

    /**
     * Cannot transfer to the zero address.
     */
    error TransferToZeroAddress();

    /**
     * Exceeds max token ID
     */
    error ExceedsMaximumTokenId();
    
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

    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(
        address[] calldata accounts,
        uint256[] calldata ids
    ) external view returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.1) (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.20;

import {IERC165} from "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC-1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[ERC].
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` amount of tokens of type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the value of tokens of token type `id` owned by `account`.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(
        address[] calldata accounts,
        uint256[] calldata ids
    ) external view returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the zero address.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers a `value` amount of tokens of type `id` from `from` to `to`.
     *
     * WARNING: This function can potentially allow a reentrancy attack when transferring tokens
     * to an untrusted contract, when invoking {onERC1155Received} on the receiver.
     * Ensure to follow the checks-effects-interactions pattern and consider employing
     * reentrancy guards when interacting with untrusted contracts.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `value` amount.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(address from, address to, uint256 id, uint256 value, bytes calldata data) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * WARNING: This function can potentially allow a reentrancy attack when transferring tokens
     * to an untrusted contract, when invoking {onERC1155BatchReceived} on the receiver.
     * Ensure to follow the checks-effects-interactions pattern and consider employing
     * reentrancy guards when interacting with untrusted contracts.
     *
     * Emits either a {TransferSingle} or a {TransferBatch} event, depending on the length of the array arguments.
     *
     * Requirements:
     *
     * - `ids` and `values` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external;
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
    function _guardInitializeOwner() internal pure virtual returns (bool guard) {}

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
                log3(0, 0, _OWNERSHIP_TRANSFERRED_EVENT_SIGNATURE, sload(ownerSlot), newOwner)
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
                log3(0, 0, _OWNERSHIP_TRANSFERRED_EVENT_SIGNATURE, sload(ownerSlot), newOwner)
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
    function _ownershipHandoverValidFor() internal view virtual returns (uint64) {
        return 48 * 3600;
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
            result := sload(_OWNER_SLOT)
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
pragma solidity 0.8.27;

//                            _.-^-._    .--.
//                         .-'   _   '-. |__|
//                        /     |_|     \|  |
//                       /               \  |
//                      /|     _____     |\ |
//                       |    |==|==|    |  |
//   |---|---|---|---|---|    |--|--|    |  |
//   |---|---|---|---|---|    |==|==|    |  |
//  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
//  _______  Harvest.art v4 (Auctions) _________

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "solady/auth/Ownable.sol";
import "solady/utils/ReentrancyGuard.sol";
import "./IAuctions.sol";
import "./IBidTicket.sol";

enum Status {
    Active,
    Claimed,
    Refunded,
    Abandoned
}

struct Auction {
    uint8 auctionType;
    address tokenAddress;
    uint64 endTime;
    uint8 tokenCount;
    Status status;
    address highestBidder;
    uint256 highestBid;
    uint256 bidDelta;
    uint256 bidderCount;
    mapping(uint256 => address) bidders;
    mapping(uint256 => uint256) tokenIds;
    mapping(uint256 => uint256) amounts;
    mapping(address => uint256) rewards;
}

contract Auctions is IAuctions, Ownable, ReentrancyGuard {
    uint8 private constant AUCTION_TYPE_ERC721 = 0;
    uint8 private constant AUCTION_TYPE_ERC1155 = 1;

    IBidTicket public bidTicket;
    address public theBarn;
    address public theFarmer;
    uint256 public abandonmentFeePercent = 20;
    uint256 public antiSnipeDuration = 15 minutes;
    uint256 public auctionDuration = 3 days;
    uint256 public bidTicketCostBid = 1;
    uint256 public bidTicketCostStart = 1;
    uint256 public bidTicketTokenId = 1;
    uint256 public maxTokens = 50;
    uint256 public minBidIncrement = 0.01 ether;
    uint256 public minStartingBid = 0.05 ether;
    uint256 public nextAuctionId = 1;
    uint256 public outbidRewardPercent = 10;
    uint256 public settlementDuration = 7 days;

    mapping(address => uint256) public balances;
    mapping(uint256 => Auction) public auctions;
    mapping(address => mapping(uint256 => bool)) public auctionTokensERC721;
    mapping(address => mapping(uint256 => uint256)) public auctionTokensERC1155;

    constructor(
        address owner_,
        address theBarn_,
        address theFarmer_,
        address bidTicket_
    ) {
        _initializeOwner(owner_);
        theBarn = theBarn_;
        theFarmer = theFarmer_;
        bidTicket = IBidTicket(bidTicket_);
    }

    /**
     *
     * startAuction - Starts an auction for a given token
     *
     * @param startingBid - The starting bid for the auction
     * @param tokenAddress - The address of the token contract
     * @param tokenIds - The token ids to auction
     *
     */

    function startAuctionERC721(
        uint256 startingBid,
        address tokenAddress,
        uint256[] calldata tokenIds
    ) external payable nonReentrant {
        uint256 length = tokenIds.length;
        require(startingBid >= minStartingBid, StartPriceTooLow());
        require(length > 0, InvalidLengthOfTokenIds());
        require(length <= maxTokens, MaxTokensPerTxReached());

        _processPayment(startingBid);

        Auction storage auction = auctions[nextAuctionId];

        auction.auctionType = AUCTION_TYPE_ERC721;
        auction.tokenAddress = tokenAddress;
        auction.endTime = uint64(block.timestamp + auctionDuration);
        auction.highestBidder = msg.sender;
        auction.highestBid = startingBid;
        auction.tokenCount = uint8(length);
        auction.bidderCount = 1;
        auction.bidDelta = startingBid;

        mapping(uint256 => uint256) storage tokenMap = auction.tokenIds;

        for (uint256 i; i < length; ++i) {
            tokenMap[i] = tokenIds[i];
        }

        unchecked {
            ++nextAuctionId;
        }

        emit Started(msg.sender, tokenAddress, tokenIds);
        
        bidTicket.burn(msg.sender, bidTicketTokenId, bidTicketCostStart);

        _validateAuctionTokensERC721(tokenAddress, tokenIds);
    }

    /**
     *
     * startAuction - Starts an auction for a given token
     *
     * @param startingBid - The starting bid for the auction
     * @param tokenAddress - The address of the token contract
     * @param tokenIds - The token ids to auction
     * @param amounts - The amounts of each token to auction
     *
     */

    function startAuctionERC1155(
        uint256 startingBid,
        address tokenAddress,
        uint256[] calldata tokenIds,
        uint256[] calldata amounts
    ) external payable nonReentrant {
        uint256 length = tokenIds.length;
        require(startingBid >= minStartingBid, StartPriceTooLow());
        require(length > 0, InvalidLengthOfTokenIds());
        require(length == amounts.length, InvalidLengthOfAmounts());
 
        _processPayment(startingBid);

        Auction storage auction = auctions[nextAuctionId];

        auction.auctionType = AUCTION_TYPE_ERC1155;
        auction.tokenAddress = tokenAddress;
        auction.endTime = uint64(block.timestamp + auctionDuration);
        auction.highestBidder = msg.sender;
        auction.highestBid = startingBid;
        auction.tokenCount = uint8(length);
        auction.bidderCount = 1;
        auction.bidDelta = startingBid;

        mapping(uint256 => uint256) storage tokenMap = auction.tokenIds;
        mapping(uint256 => uint256) storage amountMap = auction.amounts;

        for (uint256 i; i < length; ++i) {
            tokenMap[i] = tokenIds[i];
            amountMap[i] = amounts[i];
        }

        unchecked {
            ++nextAuctionId;
        }

        emit Started(msg.sender, tokenAddress, tokenIds);

        bidTicket.burn(msg.sender, bidTicketTokenId, bidTicketCostStart);

        _validateAuctionTokensERC1155(tokenAddress, tokenIds, amounts);
    }

    /**
     * bid - Places a bid on an auction
     *
     * @param auctionId - The id of the auction to bid on
     * @param bidAmount - The amount of the bid
     *
     */

    function bid(uint256 auctionId, uint256 bidAmount) external payable nonReentrant {
        Auction storage auction = auctions[auctionId];

        require(auction.status == Status.Active, InvalidStatus());
        require(auction.highestBidder != msg.sender, IsHighestBidder());
        require(bidAmount >= auction.highestBid + minBidIncrement, BidTooLow());
        require(block.timestamp <= auction.endTime, AuctionEnded());

        if (block.timestamp > auction.endTime - antiSnipeDuration) {
            auction.endTime += uint64(antiSnipeDuration);
        }

        _processPayment(bidAmount);

        address prevHighestBidder = auction.highestBidder;
        uint256 prevHighestBid = auction.highestBid;

        unchecked {
            // Return the previous bidder's bid to their balance
            balances[prevHighestBidder] += prevHighestBid;

            // Add new bidder to the bidders list
            if (auction.rewards[prevHighestBidder] == 0) {
                auction.bidders[auction.bidderCount - 1] = prevHighestBidder;
                ++auction.bidderCount;
            }

            // Calculate the reward for user who was outbid
            uint256 reward = auction.bidDelta * outbidRewardPercent / 100;
            auction.rewards[prevHighestBidder] += reward;

            // Update the bid delta for the next potential outbid
            auction.bidDelta = bidAmount - prevHighestBid;
        }

        auction.highestBidder = msg.sender;
        auction.highestBid = bidAmount;

        emit NewBid(auctionId, msg.sender, bidAmount);

        bidTicket.burn(msg.sender, bidTicketTokenId, bidTicketCostBid);
    }

    /**
     * claim - Claims the tokens from an auction
     *
     * @param auctionId - The id of the auction to claim
     *
     */

    function claim(uint256 auctionId) external nonReentrant {
        Auction storage auction = auctions[auctionId];

        require(auction.status == Status.Active, InvalidStatus());
        require(block.timestamp > auction.endTime, AuctionNotEnded());
        require(msg.sender == auction.highestBidder || msg.sender == owner(), NotHighestBidder());

        auction.status = Status.Claimed;

        uint256 totalRewards = _distributeRewards(auction);

        emit Claimed(auctionId, auction.highestBidder);

        (bool success,) = payable(theFarmer).call{value: auction.highestBid - totalRewards}("");
        require(success, TransferFailed());
        
        if (auction.auctionType == AUCTION_TYPE_ERC721) {
            _transferERC721s(auction);
        } else {
            _transferERC1155s(auction);
        }
    }

    /**
     * refund - Refunds are available during the settlement period if The Barn has not yet approved the collection
     *
     * @param auctionId - The id of the auction to refund
     *
     */

    function refund(uint256 auctionId) external nonReentrant {
        Auction storage auction = auctions[auctionId];
        uint256 highestBid = auction.highestBid;
        uint256 endTime = auction.endTime;

        require(auction.status == Status.Active, InvalidStatus());
        require(block.timestamp > endTime, AuctionActive());
        require(block.timestamp <= endTime + settlementDuration, SettlementPeriodEnded());
        require(msg.sender == auction.highestBidder || msg.sender == owner(), NotHighestBidder());

        auction.status = Status.Refunded;

        emit Refunded(auctionId, auction.highestBidder, highestBid);

        if (auction.auctionType == AUCTION_TYPE_ERC721) {
            _checkAndResetERC721s(auction);
        } else {
            _checkAndResetERC1155s(auction);
        }

        unchecked {
            balances[auction.highestBidder] += highestBid;
        }
    }

    /**
     *
     * abandon - Mark unclaimed auctions as abandoned after the settlement period
     *
     * @param auctionId - The id of the auction to abandon
     *
     */

    function abandon(uint256 auctionId) external onlyOwner nonReentrant {
        Auction storage auction = auctions[auctionId];
        address highestBidder = auction.highestBidder;
        uint256 highestBid = auction.highestBid;

        require(auction.status == Status.Active, InvalidStatus());
        require(block.timestamp > auction.endTime + settlementDuration, SettlementPeriodNotExpired());

        auction.status = Status.Abandoned;

        if (auction.auctionType == AUCTION_TYPE_ERC721) {
            _resetERC721s(auction);
        } else {
            _resetERC1155s(auction);
        }

        uint256 fee;

        unchecked {
            fee = highestBid * abandonmentFeePercent / 100;
            balances[highestBidder] += highestBid - fee;
        }

        emit Abandoned(auctionId, highestBidder, fee);

        (bool success,) = payable(theFarmer).call{value: fee}("");
        require(success, TransferFailed());
    }

    /**
     * withdraw - Withdraws the balance of the user.
     *
     * @notice - We keep track of the balance instead of sending it directly
     *           back to the user when outbid to avoid certain types of attacks.
     *
     */

    function withdraw() external nonReentrant {
        uint256 balance = balances[msg.sender];
        require(balance > 0, NoBalanceToWithdraw());

        balances[msg.sender] = 0;

        emit Withdraw(msg.sender, balance);

        (bool success,) = payable(msg.sender).call{value: balance}("");
        require(success, TransferFailed());
    }

    /**
     *
     * Getters & Setters
     *
     */

    function getAuctionTokens(uint256 auctionId) external view returns (uint256[] memory, uint256[] memory) {
        Auction storage auction = auctions[auctionId];

        uint256[] memory tokenIds = new uint256[](auction.tokenCount);
        uint256[] memory amounts = new uint256[](auction.tokenCount);

        uint256 tokenCount = auction.tokenCount;

        for (uint256 i; i < tokenCount; ++i) {
            tokenIds[i] = auction.tokenIds[i];

            if (auction.auctionType == AUCTION_TYPE_ERC721) {
                amounts[i] = 1;
            } else {
                amounts[i] = auction.amounts[i];
            }
        }

        return (tokenIds, amounts);
    }

    function getPendingRewards(address bidder, uint256[] calldata auctionIds) external view returns (uint256) {
        uint256 totalRewards;
        uint256 length = auctionIds.length;

        for (uint256 i; i < length; ++i) {
            if (auctions[auctionIds[i]].status == Status.Active) {
                totalRewards += auctions[auctionIds[i]].rewards[bidder];
            }
        }

        return totalRewards;
    }

    function getClaimedAuctions(uint256 limit) external view returns (uint256[] memory) {
        uint256[] memory claimedAuctions = new uint256[](limit);
        uint256 count = 0;

        for (uint256 i = nextAuctionId - 1; i > 0 && count < limit; --i) {
            if (auctions[i].status == Status.Claimed) {
                claimedAuctions[count] = i;
                unchecked { ++count; }
            }
        }

        assembly {
            mstore(claimedAuctions, count)
        }

        return claimedAuctions;
    }

    function setBarnAddress(address theBarn_) external onlyOwner {
        theBarn = theBarn_;
    }

    function setFarmerAddress(address theFarmer_) external onlyOwner {
        theFarmer = theFarmer_;
    }

    function setBidTicketAddress(address bidTicket_) external onlyOwner {
        bidTicket = IBidTicket(bidTicket_);
    }

    function setBidTicketTokenId(uint256 bidTicketTokenId_) external onlyOwner {
        bidTicketTokenId = bidTicketTokenId_;
    }

    function setBidTicketCostStart(uint256 bidTicketCostStart_) external onlyOwner {
        bidTicketCostStart = bidTicketCostStart_;
    }

    function setBidTicketCostBid(uint256 bidTicketCostBid_) external onlyOwner {
        bidTicketCostBid = bidTicketCostBid_;
    }

    function setMaxTokens(uint256 maxTokens_) external onlyOwner {
        maxTokens = maxTokens_;
    }

    function setMinStartingBid(uint256 minStartingBid_) external onlyOwner {
        minStartingBid = minStartingBid_;
    }

    function setMinBidIncrement(uint256 minBidIncrement_) external onlyOwner {
        minBidIncrement = minBidIncrement_;
    }

    function setAuctionDuration(uint256 auctionDuration_) external onlyOwner {
        auctionDuration = auctionDuration_;
    }

    function setSettlementDuration(uint256 settlementDuration_) external onlyOwner {
        settlementDuration = settlementDuration_;
    }

    function setAntiSnipeDuration(uint256 antiSnipeDuration_) external onlyOwner {
        antiSnipeDuration = antiSnipeDuration_;
    }

    function setAbandonmentFeePercent(uint256 newFeePercent) external onlyOwner {
        require(newFeePercent <= 100, InvalidFeePercentage());
        abandonmentFeePercent = newFeePercent;
    }

    function setOutbidRewardPercent(uint256 newPercent) external onlyOwner {
        require(newPercent <= 100, InvalidFeePercentage());
        outbidRewardPercent = newPercent;
    }

    /**
     *
     * Internal Functions
     *
     */

    function _processPayment(uint256 payment) internal {
        uint256 balance = balances[msg.sender];
        uint256 paymentFromBalance;
        uint256 paymentFromMsgValue;

        if (balance >= payment) {
            paymentFromBalance = payment;
            paymentFromMsgValue = 0;
        } else {
            paymentFromBalance = balance;
            paymentFromMsgValue = payment - balance;
        }

        require(msg.value == paymentFromMsgValue, InvalidValue());

        if (paymentFromBalance > 0) {
            balances[msg.sender] -= paymentFromBalance;
        }
    }

    function _validateAuctionTokensERC721(address tokenAddress, uint256[] calldata tokenIds) internal {
        IERC721 erc721Contract = IERC721(tokenAddress);
        uint256 length = tokenIds.length;
        mapping(uint256 => bool) storage auctionTokens = auctionTokensERC721[tokenAddress];

        for (uint256 i; i < length; ++i) {
            uint256 tokenId = tokenIds[i];
            require(!auctionTokens[tokenId], TokenAlreadyInAuction());
            auctionTokens[tokenId] = true;
            require(erc721Contract.ownerOf(tokenId) == theBarn, TokenNotOwned());
        }
    }

    function _validateAuctionTokensERC1155(
        address tokenAddress,
        uint256[] calldata tokenIds,
        uint256[] calldata amounts
    ) internal {
        IERC1155 erc1155Contract = IERC1155(tokenAddress);
        uint256 totalTokens;
        uint256 totalNeeded;
        uint256 balance;
        uint256 tokenId;
        uint256 amount;

        mapping(uint256 => uint256) storage auctionTokens = auctionTokensERC1155[tokenAddress];
        uint256 length = tokenIds.length;

        for (uint256 i; i < length; ++i) {
            tokenId = tokenIds[i];
            amount = amounts[i];

            totalTokens += amount;
            totalNeeded = auctionTokens[tokenId] + amount;
            balance = erc1155Contract.balanceOf(theBarn, tokenId);

            require(totalNeeded <= balance, NotEnoughTokensInSupply());

            unchecked {
                auctionTokens[tokenId] += amount;
            }
        }

        require(totalTokens <= maxTokens, MaxTokensPerTxReached());
    }

    function _transferERC721s(Auction storage auction) internal {
        address tokenAddress = auction.tokenAddress;
        uint256 tokenCount = auction.tokenCount;
        address highestBidder = auction.highestBidder;
        IERC721 erc721Contract = IERC721(tokenAddress);

        mapping(uint256 => uint256) storage tokenMap = auction.tokenIds;
        mapping(uint256 => bool) storage auctionTokens = auctionTokensERC721[tokenAddress];

        for (uint256 i; i < tokenCount; ++i) {
            auctionTokens[tokenMap[i]] = false;
        }

        for (uint256 i; i < tokenCount; ++i) {
            erc721Contract.safeTransferFrom(theBarn, highestBidder, tokenMap[i]);
        }
    }

    function _transferERC1155s(Auction storage auction) internal {
        address tokenAddress = auction.tokenAddress;
        IERC1155 erc1155Contract = IERC1155(tokenAddress);
        uint256 tokenCount = auction.tokenCount;
        uint256[] memory tokenIds = new uint256[](tokenCount);
        uint256[] memory amounts = new uint256[](tokenCount);

        mapping(uint256 => uint256) storage tokenMap = auction.tokenIds;
        mapping(uint256 => uint256) storage amountMap = auction.amounts;
        mapping(uint256 => uint256) storage auctionTokens = auctionTokensERC1155[tokenAddress];

        for (uint256 i; i < tokenCount; ++i) {
            uint256 tokenId = tokenMap[i];
            uint256 amount = amountMap[i];

            tokenIds[i] = tokenId;
            amounts[i] = amount;
            auctionTokens[tokenId] -= amount;
        }

        erc1155Contract.safeBatchTransferFrom(theBarn, auction.highestBidder, tokenIds, amounts, "");
    }

    function _resetERC721s(Auction storage auction) internal {
        address tokenAddress = auction.tokenAddress;
        uint256 tokenCount = auction.tokenCount;

        mapping(uint256 => uint256) storage tokenMap = auction.tokenIds;
        mapping(uint256 => bool) storage auctionTokens = auctionTokensERC721[tokenAddress];

        for (uint256 i; i < tokenCount; ++i) {
            uint256 tokenId = tokenMap[i];
            auctionTokens[tokenId] = false;
        }
    }

    function _resetERC1155s(Auction storage auction) internal {
        address tokenAddress = auction.tokenAddress;
        uint256 tokenCount = auction.tokenCount;
        uint256[] memory tokenIds = new uint256[](tokenCount);
        uint256[] memory amounts = new uint256[](tokenCount);

        mapping(uint256 => uint256) storage tokenMap = auction.tokenIds;
        mapping(uint256 => uint256) storage amountMap = auction.amounts;
        mapping(uint256 => uint256) storage auctionTokens = auctionTokensERC1155[tokenAddress];

        for (uint256 i; i < tokenCount; ++i) {
            uint256 tokenId = tokenMap[i];
            uint256 amount = amountMap[i];

            tokenIds[i] = tokenId;
            amounts[i] = amount;
            auctionTokens[tokenId] -= amount;
        }
    }

    function _checkAndResetERC721s(Auction storage auction) internal {
        address tokenAddress = auction.tokenAddress;
        uint256 tokenCount = auction.tokenCount;

        mapping(uint256 => uint256) storage tokenMap = auction.tokenIds;
        mapping(uint256 => bool) storage auctionTokens = auctionTokensERC721[tokenAddress];

        bool notRefundable = IERC721(tokenAddress).isApprovedForAll(theBarn, address(this));

        for (uint256 i; i < tokenCount; ++i) {
            uint256 tokenId = tokenMap[i];
            auctionTokens[tokenId] = false;

            notRefundable = notRefundable && (IERC721(tokenAddress).ownerOf(tokenId) == theBarn);
        }

        require(!notRefundable, AuctionIsApproved());
    }

    function _checkAndResetERC1155s(Auction storage auction) internal {
        address tokenAddress = auction.tokenAddress;
        uint256 tokenCount = auction.tokenCount;
        uint256[] memory tokenIds = new uint256[](tokenCount);
        uint256[] memory amounts = new uint256[](tokenCount);

        mapping(uint256 => uint256) storage tokenMap = auction.tokenIds;
        mapping(uint256 => uint256) storage amountMap = auction.amounts;
        mapping(uint256 => uint256) storage auctionTokens = auctionTokensERC1155[tokenAddress];

        bool notRefundable = IERC1155(tokenAddress).isApprovedForAll(theBarn, address(this));

        for (uint256 i; i < tokenCount; ++i) {
            uint256 tokenId = tokenMap[i];
            uint256 amount = amountMap[i];

            tokenIds[i] = tokenId;
            amounts[i] = amount;
            auctionTokens[tokenId] -= amount;

            notRefundable = notRefundable && (IERC1155(tokenAddress).balanceOf(theBarn, tokenId) >= amount);
        }

        require(!notRefundable, AuctionIsApproved());
    }

    function _distributeRewards(Auction storage auction) internal returns (uint256) {
        uint256 totalRewards;
        uint256 length = auction.bidderCount;

        for (uint256 i; i < length; ++i) {
            address bidder = auction.bidders[i];
            uint256 reward = auction.rewards[bidder];

            if (reward > 0) {
                unchecked {
                    balances[bidder] += reward;
                    totalRewards += reward;
                }
            }
        }

        return totalRewards;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

interface IAuctions {
    function startAuctionERC721(uint256 startingBid, address tokenAddress, uint256[] calldata tokenIds) external payable;
    function startAuctionERC1155(uint256 startingBid, address tokenAddress, uint256[] calldata tokenIds, uint256[] calldata amounts) external payable;
    function bid(uint256 auctionId, uint256 bidAmount) external payable;
    function claim(uint256 auctionId) external;
    function refund(uint256 auctionId) external;
    function abandon(uint256 auctionId) external;
    function withdraw() external;

    function getAuctionTokens(uint256 auctionId) external view returns (uint256[] memory, uint256[] memory);
    function getPendingRewards(address bidder, uint256[] calldata auctionIds) external view returns (uint256);
    function getClaimedAuctions(uint256 limit) external view returns (uint256[] memory);

    function setBarnAddress(address theBarn_) external;
    function setFarmerAddress(address theFarmer_) external;
    function setBidTicketAddress(address bidTicket_) external;
    function setBidTicketTokenId(uint256 bidTicketTokenId_) external;
    function setBidTicketCostStart(uint256 bidTicketCostStart_) external;
    function setBidTicketCostBid(uint256 bidTicketCostBid_) external;
    function setMaxTokens(uint256 maxTokens_) external;
    function setMinStartingBid(uint256 minStartingBid_) external;
    function setMinBidIncrement(uint256 minBidIncrement_) external;
    function setAuctionDuration(uint256 auctionDuration_) external;
    function setSettlementDuration(uint256 settlementDuration_) external;
    function setAntiSnipeDuration(uint256 antiSnipeDuration_) external;
    function setAbandonmentFeePercent(uint256 newFeePercent) external;
    function setOutbidRewardPercent(uint256 newPercent) external;

    event Abandoned(uint256 indexed auctionId, address indexed bidder, uint256 indexed fee);
    event Claimed(uint256 indexed auctionId, address indexed winner);
    event NewBid(uint256 indexed auctionId, address indexed bidder, uint256 indexed value);
    event Refunded(uint256 indexed auctionId, address indexed bidder, uint256 indexed value);
    event Started(address indexed bidder, address indexed tokenAddress, uint256[] indexed tokenIds);
    event Withdraw(address indexed user, uint256 indexed value);
    
    error AuctionActive();
    error AuctionEnded();
    error AuctionIsApproved();
    error AuctionNotEnded();
    error BidTooLow();
    error InvalidFeePercentage();
    error InvalidLengthOfAmounts();
    error InvalidLengthOfTokenIds();
    error InvalidStatus();
    error InvalidValue();
    error IsHighestBidder();
    error MaxTokensPerTxReached();
    error NoBalanceToWithdraw();
    error NoRewardsToClaim();
    error NotEnoughTokensInSupply();
    error NotHighestBidder();
    error SettlementPeriodNotExpired();
    error SettlementPeriodEnded();
    error StartPriceTooLow();
    error TokenAlreadyInAuction();
    error TokenNotOwned();
    error TransferFailed();
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import "ERC1155P/contracts/IERC1155P.sol";

interface IBidTicket is IERC1155P {
    function setURI(uint256 tokenId, string calldata tokenURI) external;

    function mint(address to, uint256 id, uint256 amount) external;
    function mintBatch(address to, uint256[] calldata ids, uint256[] calldata amounts) external;

    function burn(address from, uint256 id, uint256 amount) external;
    function burnBatch(address from, uint256[] calldata ids, uint256[] calldata amounts) external;

    function setHarvestContract(address harvestContract_) external;
    function setAuctionsContract(address auctionsContract_) external;
}