// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC165.sol)

pragma solidity ^0.8.0;

import "../utils/introspection/IERC165.sol";
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (interfaces/IERC2981.sol)

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
    function royaltyInfo(
        uint256 tokenId,
        uint256 salePrice
    ) external view returns (address receiver, uint256 royaltyAmount);
}
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
// OpenZeppelin Contracts (last updated v4.9.0) (token/common/ERC2981.sol)

pragma solidity ^0.8.0;

import "../../interfaces/IERC2981.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of the NFT Royalty Standard, a standardized way to retrieve royalty payment information.
 *
 * Royalty information can be specified globally for all token ids via {_setDefaultRoyalty}, and/or individually for
 * specific token ids via {_setTokenRoyalty}. The latter takes precedence over the first.
 *
 * Royalty is specified as a fraction of sale price. {_feeDenominator} is overridable but defaults to 10000, meaning the
 * fee is specified in basis points by default.
 *
 * IMPORTANT: ERC-2981 only specifies a way to signal royalty information and does not enforce its payment. See
 * https://eips.ethereum.org/EIPS/eip-2981#optional-royalty-payments[Rationale] in the EIP. Marketplaces are expected to
 * voluntarily pay royalties together with sales, but note that this standard is not yet widely supported.
 *
 * _Available since v4.5._
 */
abstract contract ERC2981 is IERC2981, ERC165 {
    struct RoyaltyInfo {
        address receiver;
        uint96 royaltyFraction;
    }

    RoyaltyInfo private _defaultRoyaltyInfo;
    mapping(uint256 => RoyaltyInfo) private _tokenRoyaltyInfo;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC165) returns (bool) {
        return interfaceId == type(IERC2981).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @inheritdoc IERC2981
     */
    function royaltyInfo(uint256 tokenId, uint256 salePrice) public view virtual override returns (address, uint256) {
        RoyaltyInfo memory royalty = _tokenRoyaltyInfo[tokenId];

        if (royalty.receiver == address(0)) {
            royalty = _defaultRoyaltyInfo;
        }

        uint256 royaltyAmount = (salePrice * royalty.royaltyFraction) / _feeDenominator();

        return (royalty.receiver, royaltyAmount);
    }

    /**
     * @dev The denominator with which to interpret the fee set in {_setTokenRoyalty} and {_setDefaultRoyalty} as a
     * fraction of the sale price. Defaults to 10000 so fees are expressed in basis points, but may be customized by an
     * override.
     */
    function _feeDenominator() internal pure virtual returns (uint96) {
        return 10000;
    }

    /**
     * @dev Sets the royalty information that all ids in this contract will default to.
     *
     * Requirements:
     *
     * - `receiver` cannot be the zero address.
     * - `feeNumerator` cannot be greater than the fee denominator.
     */
    function _setDefaultRoyalty(address receiver, uint96 feeNumerator) internal virtual {
        require(feeNumerator <= _feeDenominator(), "ERC2981: royalty fee will exceed salePrice");
        require(receiver != address(0), "ERC2981: invalid receiver");

        _defaultRoyaltyInfo = RoyaltyInfo(receiver, feeNumerator);
    }

    /**
     * @dev Removes default royalty information.
     */
    function _deleteDefaultRoyalty() internal virtual {
        delete _defaultRoyaltyInfo;
    }

    /**
     * @dev Sets the royalty information for a specific token id, overriding the global default.
     *
     * Requirements:
     *
     * - `receiver` cannot be the zero address.
     * - `feeNumerator` cannot be greater than the fee denominator.
     */
    function _setTokenRoyalty(uint256 tokenId, address receiver, uint96 feeNumerator) internal virtual {
        require(feeNumerator <= _feeDenominator(), "ERC2981: royalty fee will exceed salePrice");
        require(receiver != address(0), "ERC2981: Invalid parameters");

        _tokenRoyaltyInfo[tokenId] = RoyaltyInfo(receiver, feeNumerator);
    }

    /**
     * @dev Resets royalty information for the token id back to the global default.
     */
    function _resetTokenRoyalty(uint256 tokenId) internal virtual {
        delete _tokenRoyaltyInfo[tokenId];
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.4) (utils/Context.sol)

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

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
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
pragma solidity ^0.8.4;

/// @notice Simple ERC721 implementation with storage hitchhiking.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/tokens/ERC721.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC721.sol)
/// @author Modified from OpenZeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/tree/master/contracts/token/ERC721/ERC721.sol)
///
/// @dev Note:
/// - The ERC721 standard allows for self-approvals.
///   For performance, this implementation WILL NOT revert for such actions.
///   Please add any checks with overrides if desired.
/// - For performance, methods are made payable where permitted by the ERC721 standard.
/// - The `safeTransfer` functions use the identity precompile (0x4)
///   to copy memory internally.
///
/// If you are overriding:
/// - NEVER violate the ERC721 invariant:
///   the balance of an owner MUST always be equal to their number of ownership slots.
///   The transfer functions do not have an underflow guard for user token balances.
/// - Make sure all variables written to storage are properly cleaned
//    (e.g. the bool value for `isApprovedForAll` MUST be either 1 or 0 under the hood).
/// - Check that the overridden function is actually used in the function you want to
///   change the behavior of. Much of the code has been manually inlined for performance.
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
    /// - [0..159]   `addr`
    /// - [160..255] `extraData`
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
    /// - [32..255] `aux`
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

    /// @dev Returns the account approved to manage token `id`.
    ///
    /// Requirements:
    /// - Token `id` must exist.
    function getApproved(uint256 id) public view virtual returns (address result) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, id)
            mstore(0x1c, _ERC721_MASTER_SLOT_SEED)
            let ownershipSlot := add(id, add(id, keccak256(0x00, 0x20)))
            if iszero(shl(96, sload(ownershipSlot))) {
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
    /// Emits an {Approval} event.
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
    /// Emits an {ApprovalForAll} event.
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
            // forgefmt: disable-next-item
            log3(0x00, 0x20, _APPROVAL_FOR_ALL_EVENT_SIGNATURE, caller(), shr(96, shl(96, operator)))
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
            // Revert if the token does not exist, or if `from` is not the owner.
            if iszero(mul(owner, eq(owner, from))) {
                // `TokenDoesNotExist()`, `TransferFromIncorrectOwner()`.
                mstore(shl(2, iszero(owner)), 0xceea21b6a1148100)
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
                // Revert if `to` is the zero address, or if the account balance overflows.
                if iszero(mul(to, and(toBalanceSlotPacked, _MAX_ACCOUNT_BALANCE))) {
                    // `TransferToZeroAddress()`, `AccountBalanceOverflow()`.
                    mstore(shl(2, iszero(to)), 0xea553b3401336cea)
                    revert(0x1c, 0x04)
                }
                sstore(toBalanceSlot, toBalanceSlotPacked)
            }
            // Emit the {Transfer} event.
            log4(codesize(), 0x00, _TRANSFER_EVENT_SIGNATURE, from, to, id)
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
            result := iszero(iszero(shl(96, sload(add(id, add(id, keccak256(0x00, 0x20)))))))
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

    // For performance, no events are emitted for the hitchhiking setters.
    // Please emit your own events if required.

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
    /// The extra data can be set on a non-existent token.
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
    /// The extra data can be set on a non-existent token.
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
                // Revert if `to` is the zero address, or if the account balance overflows.
                if iszero(mul(to, and(balanceSlotPacked, _MAX_ACCOUNT_BALANCE))) {
                    // `TransferToZeroAddress()`, `AccountBalanceOverflow()`.
                    mstore(shl(2, iszero(to)), 0xea553b3401336cea)
                    revert(0x1c, 0x04)
                }
                sstore(balanceSlot, balanceSlotPacked)
            }
            // Emit the {Transfer} event.
            log4(codesize(), 0x00, _TRANSFER_EVENT_SIGNATURE, 0, to, id)
        }
        _afterTokenTransfer(address(0), to, id);
    }

    /// @dev Mints token `id` to `to`, and updates the extra data for token `id` to `value`.
    /// Does NOT check if token `id` already exists (assumes `id` is auto-incrementing).
    ///
    /// Requirements:
    ///
    /// - `to` cannot be the zero address.
    ///
    /// Emits a {Transfer} event.
    function _mintAndSetExtraDataUnchecked(address to, uint256 id, uint96 value) internal virtual {
        _beforeTokenTransfer(address(0), to, id);
        /// @solidity memory-safe-assembly
        assembly {
            // Clear the upper 96 bits.
            to := shr(96, shl(96, to))
            // Update with the owner and extra data.
            mstore(0x00, id)
            mstore(0x1c, _ERC721_MASTER_SLOT_SEED)
            sstore(add(id, add(id, keccak256(0x00, 0x20))), or(shl(160, value), to))
            // Increment the balance of the owner.
            {
                mstore(0x00, to)
                let balanceSlot := keccak256(0x0c, 0x1c)
                let balanceSlotPacked := add(sload(balanceSlot), 1)
                // Revert if `to` is the zero address, or if the account balance overflows.
                if iszero(mul(to, and(balanceSlotPacked, _MAX_ACCOUNT_BALANCE))) {
                    // `TransferToZeroAddress()`, `AccountBalanceOverflow()`.
                    mstore(shl(2, iszero(to)), 0xea553b3401336cea)
                    revert(0x1c, 0x04)
                }
                sstore(balanceSlot, balanceSlotPacked)
            }
            // Emit the {Transfer} event.
            log4(codesize(), 0x00, _TRANSFER_EVENT_SIGNATURE, 0, to, id)
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
            log4(codesize(), 0x00, _TRANSFER_EVENT_SIGNATURE, owner, 0, id)
        }
        _afterTokenTransfer(owner, address(0), id);
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                INTERNAL APPROVAL FUNCTIONS                 */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns whether `account` is the owner of token `id`, or is approved to manage it.
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
                // Check if `account` is approved to manage the token.
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
    /// Emits a {Approval} event.
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
            log4(codesize(), 0x00, _APPROVAL_EVENT_SIGNATURE, owner, account, id)
        }
    }

    /// @dev Approve or remove the `operator` as an operator for `by`,
    /// without authorization checks.
    ///
    /// Emits an {ApprovalForAll} event.
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
            // Revert if the token does not exist, or if `from` is not the owner.
            if iszero(mul(owner, eq(owner, from))) {
                // `TokenDoesNotExist()`, `TransferFromIncorrectOwner()`.
                mstore(shl(2, iszero(owner)), 0xceea21b6a1148100)
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
                // Revert if `to` is the zero address, or if the account balance overflows.
                if iszero(mul(to, and(toBalanceSlotPacked, _MAX_ACCOUNT_BALANCE))) {
                    // `TransferToZeroAddress()`, `AccountBalanceOverflow()`.
                    mstore(shl(2, iszero(to)), 0xea553b3401336cea)
                    revert(0x1c, 0x04)
                }
                sstore(toBalanceSlot, toBalanceSlotPacked)
            }
            // Emit the {Transfer} event.
            log4(codesize(), 0x00, _TRANSFER_EVENT_SIGNATURE, from, to, id)
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
                    returndatacopy(m, 0x00, returndatasize())
                    revert(m, returndatasize())
                }
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
            if gt(x, div(not(0), y)) {
                if y {
                    mstore(0x00, 0xbac65e5b) // `MulWadFailed()`.
                    revert(0x1c, 0x04)
                }
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
            z := mul(x, y)
            // Equivalent to `require(y == 0 || x <= type(uint256).max / y)`.
            if iszero(eq(div(z, y), x)) {
                if y {
                    mstore(0x00, 0xbac65e5b) // `MulWadFailed()`.
                    revert(0x1c, 0x04)
                }
            }
            z := add(iszero(iszero(mod(z, WAD))), div(z, WAD))
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
            // Equivalent to `require(y != 0 && x <= type(uint256).max / WAD)`.
            if iszero(mul(y, lt(x, add(1, div(not(0), WAD))))) {
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
            if iszero(mul(y, eq(sdiv(z, WAD), x))) {
                mstore(0x00, 0x5c43740d) // `SDivWadFailed()`.
                revert(0x1c, 0x04)
            }
            z := sdiv(z, y)
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
            // Equivalent to `require(y != 0 && x <= type(uint256).max / WAD)`.
            if iszero(mul(y, lt(x, add(1, div(not(0), WAD))))) {
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
    /// Note: This function is an approximation.
    function powWad(int256 x, int256 y) internal pure returns (int256) {
        // Using `ln(x)` means `x` must be greater than 0.
        return expWad((lnWad(x) * y) / int256(WAD));
    }

    /// @dev Returns `exp(x)`, denominated in `WAD`.
    /// Credit to Remco Bloemen under MIT license: https://2π.com/22/exp-ln
    /// Note: This function is an approximation. Monotonically increasing.
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
    /// Note: This function is an approximation. Monotonically increasing.
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
    /// Note: This function is an approximation. Monotonically increasing.
    function lambertW0Wad(int256 x) internal pure returns (int256 w) {
        // forgefmt: disable-next-item
        unchecked {
            if ((w = x) <= -367879441171442322) revert OutOfDomain(); // `x` less than `-1/e`.
            (int256 wad, int256 p) = (int256(WAD), x);
            uint256 c; // Whether we need to avoid catastrophic cancellation.
            uint256 i = 4; // Number of iterations.
            if (w <= 0x1ffffffffffff) {
                if (-0x4000000000000 <= w) {
                    i = 1; // Inputs near zero only take one step to converge.
                } else if (w <= -0x3ffffffffffffff) {
                    i = 32; // Inputs near `-1/e` take very long to converge.
                }
            } else if (uint256(w >> 63) == uint256(0)) {
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
                if (c == uint256(0)) {
                    do { // If `x` is big, use Newton's so that intermediate values won't overflow.
                        int256 e = expWad(w);
                        /// @solidity memory-safe-assembly
                        assembly {
                            let t := mul(w, div(e, wad))
                            w := sub(w, sdiv(sub(t, x), div(add(e, t), wad)))
                        }
                        if (p <= w) break;
                        p = w;
                    } while (--i != uint256(0));
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
            if (c == uint256(0)) return w;
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

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                  GENERAL NUMBER UTILITIES                  */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns `a * b == x * y`, with full precision.
    function fullMulEq(uint256 a, uint256 b, uint256 x, uint256 y)
        internal
        pure
        returns (bool result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            result := and(eq(mul(a, b), mul(x, y)), eq(mulmod(x, y, not(0)), mulmod(a, b, not(0))))
        }
    }

    /// @dev Calculates `floor(x * y / d)` with full precision.
    /// Throws if result overflows a uint256 or when `d` is zero.
    /// Credit to Remco Bloemen under MIT license: https://2π.com/21/muldiv
    function fullMulDiv(uint256 x, uint256 y, uint256 d) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // 512-bit multiply `[p1 p0] = x * y`.
            // Compute the product mod `2**256` and mod `2**256 - 1`
            // then use the Chinese Remainder Theorem to reconstruct
            // the 512 bit result. The result is stored in two 256
            // variables such that `product = p1 * 2**256 + p0`.

            // Temporarily use `z` as `p0` to save gas.
            z := mul(x, y) // Lower 256 bits of `x * y`.
            for {} 1 {} {
                // If overflows.
                if iszero(mul(or(iszero(x), eq(div(z, x), y)), d)) {
                    let mm := mulmod(x, y, not(0))
                    let p1 := sub(mm, add(z, lt(mm, z))) // Upper 256 bits of `x * y`.

                    /*------------------- 512 by 256 division --------------------*/

                    // Make division exact by subtracting the remainder from `[p1 p0]`.
                    let r := mulmod(x, y, d) // Compute remainder using mulmod.
                    let t := and(d, sub(0, d)) // The least significant bit of `d`. `t >= 1`.
                    // Make sure `z` is less than `2**256`. Also prevents `d == 0`.
                    // Placing the check here seems to give more optimal stack operations.
                    if iszero(gt(d, p1)) {
                        mstore(0x00, 0xae47f702) // `FullMulDivFailed()`.
                        revert(0x1c, 0x04)
                    }
                    d := div(d, t) // Divide `d` by `t`, which is a power of two.
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
                    z :=
                        mul(
                            // Divide [p1 p0] by the factors of two.
                            // Shift in bits from `p1` into `p0`. For this we need
                            // to flip `t` such that it is `2**256 / t`.
                            or(mul(sub(p1, gt(r, z)), add(div(sub(0, t), t), 1)), div(sub(z, r), t)),
                            mul(sub(2, mul(d, inv)), inv) // inverse mod 2**256
                        )
                    break
                }
                z := div(z, d)
                break
            }
        }
    }

    /// @dev Calculates `floor(x * y / d)` with full precision.
    /// Behavior is undefined if `d` is zero or the final result cannot fit in 256 bits.
    /// Performs the full 512 bit calculation regardless.
    function fullMulDivUnchecked(uint256 x, uint256 y, uint256 d)
        internal
        pure
        returns (uint256 z)
    {
        /// @solidity memory-safe-assembly
        assembly {
            z := mul(x, y)
            let mm := mulmod(x, y, not(0))
            let p1 := sub(mm, add(z, lt(mm, z)))
            let t := and(d, sub(0, d))
            let r := mulmod(x, y, d)
            d := div(d, t)
            let inv := xor(2, mul(3, d))
            inv := mul(inv, sub(2, mul(d, inv)))
            inv := mul(inv, sub(2, mul(d, inv)))
            inv := mul(inv, sub(2, mul(d, inv)))
            inv := mul(inv, sub(2, mul(d, inv)))
            inv := mul(inv, sub(2, mul(d, inv)))
            z :=
                mul(
                    or(mul(sub(p1, gt(r, z)), add(div(sub(0, t), t), 1)), div(sub(z, r), t)),
                    mul(sub(2, mul(d, inv)), inv)
                )
        }
    }

    /// @dev Calculates `floor(x * y / d)` with full precision, rounded up.
    /// Throws if result overflows a uint256 or when `d` is zero.
    /// Credit to Uniswap-v3-core under MIT license:
    /// https://github.com/Uniswap/v3-core/blob/main/contracts/libraries/FullMath.sol
    function fullMulDivUp(uint256 x, uint256 y, uint256 d) internal pure returns (uint256 z) {
        z = fullMulDiv(x, y, d);
        /// @solidity memory-safe-assembly
        assembly {
            if mulmod(x, y, d) {
                z := add(z, 1)
                if iszero(z) {
                    mstore(0x00, 0xae47f702) // `FullMulDivFailed()`.
                    revert(0x1c, 0x04)
                }
            }
        }
    }

    /// @dev Calculates `floor(x * y / 2 ** n)` with full precision.
    /// Throws if result overflows a uint256.
    /// Credit to Philogy under MIT license:
    /// https://github.com/SorellaLabs/angstrom/blob/main/contracts/src/libraries/X128MathLib.sol
    function fullMulDivN(uint256 x, uint256 y, uint8 n) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Temporarily use `z` as `p0` to save gas.
            z := mul(x, y) // Lower 256 bits of `x * y`. We'll call this `z`.
            for {} 1 {} {
                if iszero(or(iszero(x), eq(div(z, x), y))) {
                    let k := and(n, 0xff) // `n`, cleaned.
                    let mm := mulmod(x, y, not(0))
                    let p1 := sub(mm, add(z, lt(mm, z))) // Upper 256 bits of `x * y`.
                    //         |      p1     |      z     |
                    // Before: | p1_0 ¦ p1_1 | z_0  ¦ z_1 |
                    // Final:  |   0  ¦ p1_0 | p1_1 ¦ z_0 |
                    // Check that final `z` doesn't overflow by checking that p1_0 = 0.
                    if iszero(shr(k, p1)) {
                        z := add(shl(sub(256, k), p1), shr(k, z))
                        break
                    }
                    mstore(0x00, 0xae47f702) // `FullMulDivFailed()`.
                    revert(0x1c, 0x04)
                }
                z := shr(and(n, 0xff), z)
                break
            }
        }
    }

    /// @dev Returns `floor(x * y / d)`.
    /// Reverts if `x * y` overflows, or `d` is zero.
    function mulDiv(uint256 x, uint256 y, uint256 d) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := mul(x, y)
            // Equivalent to `require(d != 0 && (y == 0 || x <= type(uint256).max / y))`.
            if iszero(mul(or(iszero(x), eq(div(z, x), y)), d)) {
                mstore(0x00, 0xad251c27) // `MulDivFailed()`.
                revert(0x1c, 0x04)
            }
            z := div(z, d)
        }
    }

    /// @dev Returns `ceil(x * y / d)`.
    /// Reverts if `x * y` overflows, or `d` is zero.
    function mulDivUp(uint256 x, uint256 y, uint256 d) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := mul(x, y)
            // Equivalent to `require(d != 0 && (y == 0 || x <= type(uint256).max / y))`.
            if iszero(mul(or(iszero(x), eq(div(z, x), y)), d)) {
                mstore(0x00, 0xad251c27) // `MulDivFailed()`.
                revert(0x1c, 0x04)
            }
            z := add(iszero(iszero(mod(z, d))), div(z, d))
        }
    }

    /// @dev Returns `x`, the modular multiplicative inverse of `a`, such that `(a * x) % n == 1`.
    function invMod(uint256 a, uint256 n) internal pure returns (uint256 x) {
        /// @solidity memory-safe-assembly
        assembly {
            let g := n
            let r := mod(a, n)
            for { let y := 1 } 1 {} {
                let q := div(g, r)
                let t := g
                g := r
                r := sub(t, mul(r, q))
                let u := x
                x := y
                y := sub(u, mul(y, q))
                if iszero(r) { break }
            }
            x := mul(eq(g, 1), add(x, mul(slt(x, 0), n)))
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

    /// @dev Returns `condition ? x : y`, without branching.
    function ternary(bool condition, uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := xor(x, mul(xor(x, y), iszero(condition)))
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
                            if x {
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

    /// @dev Returns the square root of `x`, rounded down.
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

    /// @dev Returns the cube root of `x`, rounded down.
    /// Credit to bout3fiddy and pcaversaccio under AGPLv3 license:
    /// https://github.com/pcaversaccio/snekmate/blob/main/src/utils/Math.vy
    /// Formally verified by xuwinnie:
    /// https://github.com/vectorized/solady/blob/main/audits/xuwinnie-solady-cbrt-proof.pdf
    function cbrt(uint256 x) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            let r := shl(7, lt(0xffffffffffffffffffffffffffffffff, x))
            r := or(r, shl(6, lt(0xffffffffffffffff, shr(r, x))))
            r := or(r, shl(5, lt(0xffffffff, shr(r, x))))
            r := or(r, shl(4, lt(0xffff, shr(r, x))))
            r := or(r, shl(3, lt(0xff, shr(r, x))))
            // Makeshift lookup table to nudge the approximate log2 result.
            z := div(shl(div(r, 3), shl(lt(0xf, shr(r, x)), 0xf)), xor(7, mod(r, 3)))
            // Newton-Raphson's.
            z := div(add(add(div(x, mul(z, z)), z), z), 3)
            z := div(add(add(div(x, mul(z, z)), z), z), 3)
            z := div(add(add(div(x, mul(z, z)), z), z), 3)
            z := div(add(add(div(x, mul(z, z)), z), z), 3)
            z := div(add(add(div(x, mul(z, z)), z), z), 3)
            z := div(add(add(div(x, mul(z, z)), z), z), 3)
            z := div(add(add(div(x, mul(z, z)), z), z), 3)
            // Round down.
            z := sub(z, lt(div(x, mul(z, z)), z))
        }
    }

    /// @dev Returns the square root of `x`, denominated in `WAD`, rounded down.
    function sqrtWad(uint256 x) internal pure returns (uint256 z) {
        unchecked {
            if (x <= type(uint256).max / 10 ** 18) return sqrt(x * 10 ** 18);
            z = (1 + sqrt(x)) * 10 ** 9;
            z = (fullMulDivUnchecked(x, 10 ** 18, z) + z) >> 1;
        }
        /// @solidity memory-safe-assembly
        assembly {
            z := sub(z, gt(999999999999999999, sub(mulmod(z, z, x), 1))) // Round down.
        }
    }

    /// @dev Returns the cube root of `x`, denominated in `WAD`, rounded down.
    /// Formally verified by xuwinnie:
    /// https://github.com/vectorized/solady/blob/main/audits/xuwinnie-solady-cbrt-proof.pdf
    function cbrtWad(uint256 x) internal pure returns (uint256 z) {
        unchecked {
            if (x <= type(uint256).max / 10 ** 36) return cbrt(x * 10 ** 36);
            z = (1 + cbrt(x)) * 10 ** 12;
            z = (fullMulDivUnchecked(x, 10 ** 36, z * z) + z + z) / 3;
        }
        /// @solidity memory-safe-assembly
        assembly {
            let p := x
            for {} 1 {} {
                if iszero(shr(229, p)) {
                    if iszero(shr(199, p)) {
                        p := mul(p, 100000000000000000) // 10 ** 17.
                        break
                    }
                    p := mul(p, 100000000) // 10 ** 8.
                    break
                }
                if iszero(shr(249, p)) { p := mul(p, 100) }
                break
            }
            let t := mulmod(mul(z, z), z, p)
            z := sub(z, gt(lt(t, shr(1, p)), iszero(t))) // Round down.
        }
    }

    /// @dev Returns the factorial of `x`.
    function factorial(uint256 x) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := 1
            if iszero(lt(x, 58)) {
                mstore(0x00, 0xaba0f2a2) // `FactorialOverflow()`.
                revert(0x1c, 0x04)
            }
            for {} x { x := sub(x, 1) } { z := mul(z, x) }
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

    /// @dev Returns the average of `x` and `y`. Rounds towards zero.
    function avg(uint256 x, uint256 y) internal pure returns (uint256 z) {
        unchecked {
            z = (x & y) + ((x ^ y) >> 1);
        }
    }

    /// @dev Returns the average of `x` and `y`. Rounds towards negative infinity.
    function avg(int256 x, int256 y) internal pure returns (int256 z) {
        unchecked {
            z = (x >> 1) + (y >> 1) + (x & y & 1);
        }
    }

    /// @dev Returns the absolute value of `x`.
    function abs(int256 x) internal pure returns (uint256 z) {
        unchecked {
            z = (uint256(x) + uint256(x >> 255)) ^ uint256(x >> 255);
        }
    }

    /// @dev Returns the absolute distance between `x` and `y`.
    function dist(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := add(xor(sub(0, gt(x, y)), sub(y, x)), gt(x, y))
        }
    }

    /// @dev Returns the absolute distance between `x` and `y`.
    function dist(int256 x, int256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := add(xor(sub(0, sgt(x, y)), sub(y, x)), sgt(x, y))
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

    /// @dev Returns `a + (b - a) * (t - begin) / (end - begin)`,
    /// with `t` clamped between `begin` and `end` (inclusive).
    /// Agnostic to the order of (`a`, `b`) and (`end`, `begin`).
    /// If `begins == end`, returns `t <= begin ? a : b`.
    function lerp(uint256 a, uint256 b, uint256 t, uint256 begin, uint256 end)
        internal
        pure
        returns (uint256)
    {
        if (begin > end) (t, begin, end) = (~t, ~begin, ~end);
        if (t <= begin) return a;
        if (t >= end) return b;
        unchecked {
            if (b >= a) return a + fullMulDiv(b - a, t - begin, end - begin);
            return a - fullMulDiv(a - b, t - begin, end - begin);
        }
    }

    /// @dev Returns `a + (b - a) * (t - begin) / (end - begin)`.
    /// with `t` clamped between `begin` and `end` (inclusive).
    /// Agnostic to the order of (`a`, `b`) and (`end`, `begin`).
    /// If `begins == end`, returns `t <= begin ? a : b`.
    function lerp(int256 a, int256 b, int256 t, int256 begin, int256 end)
        internal
        pure
        returns (int256)
    {
        if (begin > end) (t, begin, end) = (~t, ~begin, ~end);
        if (t <= begin) return a;
        if (t >= end) return b;
        // forgefmt: disable-next-item
        unchecked {
            if (b >= a) return int256(uint256(a) + fullMulDiv(uint256(b - a),
                uint256(t - begin), uint256(end - begin)));
            return int256(uint256(a) - fullMulDiv(uint256(a - b),
                uint256(t - begin), uint256(end - begin)));
        }
    }

    /// @dev Returns if `x` is an even number. Some people may need this.
    function isEven(uint256 x) internal pure returns (bool) {
        return x & uint256(1) == uint256(0);
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

/// @notice Library for bit twiddling and boolean operations.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/LibBit.sol)
/// @author Inspired by (https://graphics.stanford.edu/~seander/bithacks.html)
library LibBit {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                  BIT TWIDDLING OPERATIONS                  */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Find last set.
    /// Returns the index of the most significant bit of `x`,
    /// counting from the least significant bit position.
    /// If `x` is zero, returns 256.
    function fls(uint256 x) internal pure returns (uint256 r) {
        /// @solidity memory-safe-assembly
        assembly {
            r := or(shl(8, iszero(x)), shl(7, lt(0xffffffffffffffffffffffffffffffff, x)))
            r := or(r, shl(6, lt(0xffffffffffffffff, shr(r, x))))
            r := or(r, shl(5, lt(0xffffffff, shr(r, x))))
            r := or(r, shl(4, lt(0xffff, shr(r, x))))
            r := or(r, shl(3, lt(0xff, shr(r, x))))
            // forgefmt: disable-next-item
            r := or(r, byte(and(0x1f, shr(shr(r, x), 0x8421084210842108cc6318c6db6d54be)),
                0x0706060506020504060203020504030106050205030304010505030400000000))
        }
    }

    /// @dev Count leading zeros.
    /// Returns the number of zeros preceding the most significant one bit.
    /// If `x` is zero, returns 256.
    function clz(uint256 x) internal pure returns (uint256 r) {
        /// @solidity memory-safe-assembly
        assembly {
            r := shl(7, lt(0xffffffffffffffffffffffffffffffff, x))
            r := or(r, shl(6, lt(0xffffffffffffffff, shr(r, x))))
            r := or(r, shl(5, lt(0xffffffff, shr(r, x))))
            r := or(r, shl(4, lt(0xffff, shr(r, x))))
            r := or(r, shl(3, lt(0xff, shr(r, x))))
            // forgefmt: disable-next-item
            r := add(xor(r, byte(and(0x1f, shr(shr(r, x), 0x8421084210842108cc6318c6db6d54be)),
                0xf8f9f9faf9fdfafbf9fdfcfdfafbfcfef9fafdfafcfcfbfefafafcfbffffffff)), iszero(x))
        }
    }

    /// @dev Find first set.
    /// Returns the index of the least significant bit of `x`,
    /// counting from the least significant bit position.
    /// If `x` is zero, returns 256.
    /// Equivalent to `ctz` (count trailing zeros), which gives
    /// the number of zeros following the least significant one bit.
    function ffs(uint256 x) internal pure returns (uint256 r) {
        /// @solidity memory-safe-assembly
        assembly {
            // Isolate the least significant bit.
            x := and(x, add(not(x), 1))
            // For the upper 3 bits of the result, use a De Bruijn-like lookup.
            // Credit to adhusson: https://blog.adhusson.com/cheap-find-first-set-evm/
            // forgefmt: disable-next-item
            r := shl(5, shr(252, shl(shl(2, shr(250, mul(x,
                0xb6db6db6ddddddddd34d34d349249249210842108c6318c639ce739cffffffff))),
                0x8040405543005266443200005020610674053026020000107506200176117077)))
            // For the lower 5 bits of the result, use a De Bruijn lookup.
            // forgefmt: disable-next-item
            r := or(r, byte(and(div(0xd76453e0, shr(r, x)), 0x1f),
                0x001f0d1e100c1d070f090b19131c1706010e11080a1a141802121b1503160405))
        }
    }

    /// @dev Returns the number of set bits in `x`.
    function popCount(uint256 x) internal pure returns (uint256 c) {
        /// @solidity memory-safe-assembly
        assembly {
            let max := not(0)
            let isMax := eq(x, max)
            x := sub(x, and(shr(1, x), div(max, 3)))
            x := add(and(x, div(max, 5)), and(shr(2, x), div(max, 5)))
            x := and(add(x, shr(4, x)), div(max, 17))
            c := or(shl(8, isMax), shr(248, mul(x, div(max, 255))))
        }
    }

    /// @dev Returns whether `x` is a power of 2.
    function isPo2(uint256 x) internal pure returns (bool result) {
        /// @solidity memory-safe-assembly
        assembly {
            // Equivalent to `x && !(x & (x - 1))`.
            result := iszero(add(and(x, sub(x, 1)), iszero(x)))
        }
    }

    /// @dev Returns `x` reversed at the bit level.
    function reverseBits(uint256 x) internal pure returns (uint256 r) {
        uint256 m0 = 0x0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f;
        uint256 m1 = m0 ^ (m0 << 2);
        uint256 m2 = m1 ^ (m1 << 1);
        r = reverseBytes(x);
        r = (m2 & (r >> 1)) | ((m2 & r) << 1);
        r = (m1 & (r >> 2)) | ((m1 & r) << 2);
        r = (m0 & (r >> 4)) | ((m0 & r) << 4);
    }

    /// @dev Returns `x` reversed at the byte level.
    function reverseBytes(uint256 x) internal pure returns (uint256 r) {
        unchecked {
            // Computing masks on-the-fly reduces bytecode size by about 200 bytes.
            uint256 m0 = 0x100000000000000000000000000000001 * (~toUint(x == uint256(0)) >> 192);
            uint256 m1 = m0 ^ (m0 << 32);
            uint256 m2 = m1 ^ (m1 << 16);
            uint256 m3 = m2 ^ (m2 << 8);
            r = (m3 & (x >> 8)) | ((m3 & x) << 8);
            r = (m2 & (r >> 16)) | ((m2 & r) << 16);
            r = (m1 & (r >> 32)) | ((m1 & r) << 32);
            r = (m0 & (r >> 64)) | ((m0 & r) << 64);
            r = (r >> 128) | (r << 128);
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                     BOOLEAN OPERATIONS                     */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // A Solidity bool on the stack or memory is represented as a 256-bit word.
    // Non-zero values are true, zero is false.
    // A clean bool is either 0 (false) or 1 (true) under the hood.
    // Usually, if not always, the bool result of a regular Solidity expression,
    // or the argument of a public/external function will be a clean bool.
    // You can usually use the raw variants for more performance.
    // If uncertain, test (best with exact compiler settings).
    // Or use the non-raw variants (compiler can sometimes optimize out the double `iszero`s).

    /// @dev Returns `x & y`. Inputs must be clean.
    function rawAnd(bool x, bool y) internal pure returns (bool z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := and(x, y)
        }
    }

    /// @dev Returns `x & y`.
    function and(bool x, bool y) internal pure returns (bool z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := and(iszero(iszero(x)), iszero(iszero(y)))
        }
    }

    /// @dev Returns `x | y`. Inputs must be clean.
    function rawOr(bool x, bool y) internal pure returns (bool z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := or(x, y)
        }
    }

    /// @dev Returns `x | y`.
    function or(bool x, bool y) internal pure returns (bool z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := or(iszero(iszero(x)), iszero(iszero(y)))
        }
    }

    /// @dev Returns 1 if `b` is true, else 0. Input must be clean.
    function rawToUint(bool b) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := b
        }
    }

    /// @dev Returns 1 if `b` is true, else 0.
    function toUint(bool b) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := iszero(iszero(b))
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {LibBit} from "./LibBit.sol";

/// @notice Library for storage of packed unsigned booleans.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/LibBitmap.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/LibBitmap.sol)
/// @author Modified from Solidity-Bits (https://github.com/estarriolvetch/solidity-bits/blob/main/contracts/BitMaps.sol)
library LibBitmap {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         CONSTANTS                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The constant returned when a bitmap scan does not find a result.
    uint256 internal constant NOT_FOUND = type(uint256).max;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                          STRUCTS                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev A bitmap in storage.
    struct Bitmap {
        mapping(uint256 => uint256) map;
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         OPERATIONS                         */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns the boolean value of the bit at `index` in `bitmap`.
    function get(Bitmap storage bitmap, uint256 index) internal view returns (bool isSet) {
        // It is better to set `isSet` to either 0 or 1, than zero vs non-zero.
        // Both cost the same amount of gas, but the former allows the returned value
        // to be reused without cleaning the upper bits.
        uint256 b = (bitmap.map[index >> 8] >> (index & 0xff)) & 1;
        /// @solidity memory-safe-assembly
        assembly {
            isSet := b
        }
    }

    /// @dev Updates the bit at `index` in `bitmap` to true.
    function set(Bitmap storage bitmap, uint256 index) internal {
        bitmap.map[index >> 8] |= (1 << (index & 0xff));
    }

    /// @dev Updates the bit at `index` in `bitmap` to false.
    function unset(Bitmap storage bitmap, uint256 index) internal {
        bitmap.map[index >> 8] &= ~(1 << (index & 0xff));
    }

    /// @dev Flips the bit at `index` in `bitmap`.
    /// Returns the boolean result of the flipped bit.
    function toggle(Bitmap storage bitmap, uint256 index) internal returns (bool newIsSet) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x20, bitmap.slot)
            mstore(0x00, shr(8, index))
            let storageSlot := keccak256(0x00, 0x40)
            let shift := and(index, 0xff)
            let storageValue := xor(sload(storageSlot), shl(shift, 1))
            // It makes sense to return the `newIsSet`,
            // as it allow us to skip an additional warm `sload`,
            // and it costs minimal gas (about 15),
            // which may be optimized away if the returned value is unused.
            newIsSet := and(1, shr(shift, storageValue))
            sstore(storageSlot, storageValue)
        }
    }

    /// @dev Updates the bit at `index` in `bitmap` to `shouldSet`.
    function setTo(Bitmap storage bitmap, uint256 index, bool shouldSet) internal {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x20, bitmap.slot)
            mstore(0x00, shr(8, index))
            let storageSlot := keccak256(0x00, 0x40)
            let storageValue := sload(storageSlot)
            let shift := and(index, 0xff)
            sstore(
                storageSlot,
                // Unsets the bit at `shift` via `and`, then sets its new value via `or`.
                or(and(storageValue, not(shl(shift, 1))), shl(shift, iszero(iszero(shouldSet))))
            )
        }
    }

    /// @dev Consecutively sets `amount` of bits starting from the bit at `start`.
    function setBatch(Bitmap storage bitmap, uint256 start, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            let max := not(0)
            let shift := and(start, 0xff)
            mstore(0x20, bitmap.slot)
            mstore(0x00, shr(8, start))
            if iszero(lt(add(shift, amount), 257)) {
                let storageSlot := keccak256(0x00, 0x40)
                sstore(storageSlot, or(sload(storageSlot), shl(shift, max)))
                let bucket := add(mload(0x00), 1)
                let bucketEnd := add(mload(0x00), shr(8, add(amount, shift)))
                amount := and(add(amount, shift), 0xff)
                shift := 0
                for {} iszero(eq(bucket, bucketEnd)) { bucket := add(bucket, 1) } {
                    mstore(0x00, bucket)
                    sstore(keccak256(0x00, 0x40), max)
                }
                mstore(0x00, bucket)
            }
            let storageSlot := keccak256(0x00, 0x40)
            sstore(storageSlot, or(sload(storageSlot), shl(shift, shr(sub(256, amount), max))))
        }
    }

    /// @dev Consecutively unsets `amount` of bits starting from the bit at `start`.
    function unsetBatch(Bitmap storage bitmap, uint256 start, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            let shift := and(start, 0xff)
            mstore(0x20, bitmap.slot)
            mstore(0x00, shr(8, start))
            if iszero(lt(add(shift, amount), 257)) {
                let storageSlot := keccak256(0x00, 0x40)
                sstore(storageSlot, and(sload(storageSlot), not(shl(shift, not(0)))))
                let bucket := add(mload(0x00), 1)
                let bucketEnd := add(mload(0x00), shr(8, add(amount, shift)))
                amount := and(add(amount, shift), 0xff)
                shift := 0
                for {} iszero(eq(bucket, bucketEnd)) { bucket := add(bucket, 1) } {
                    mstore(0x00, bucket)
                    sstore(keccak256(0x00, 0x40), 0)
                }
                mstore(0x00, bucket)
            }
            let storageSlot := keccak256(0x00, 0x40)
            sstore(
                storageSlot, and(sload(storageSlot), not(shl(shift, shr(sub(256, amount), not(0)))))
            )
        }
    }

    /// @dev Returns number of set bits within a range by
    /// scanning `amount` of bits starting from the bit at `start`.
    function popCount(Bitmap storage bitmap, uint256 start, uint256 amount)
        internal
        view
        returns (uint256 count)
    {
        unchecked {
            uint256 bucket = start >> 8;
            uint256 shift = start & 0xff;
            if (!(amount + shift < 257)) {
                count = LibBit.popCount(bitmap.map[bucket] >> shift);
                uint256 bucketEnd = bucket + ((amount + shift) >> 8);
                amount = (amount + shift) & 0xff;
                shift = 0;
                for (++bucket; bucket != bucketEnd; ++bucket) {
                    count += LibBit.popCount(bitmap.map[bucket]);
                }
            }
            count += LibBit.popCount((bitmap.map[bucket] >> shift) << (256 - amount));
        }
    }

    /// @dev Returns the index of the most significant set bit in `[0..upTo]`.
    /// If no set bit is found, returns `NOT_FOUND`.
    function findLastSet(Bitmap storage bitmap, uint256 upTo)
        internal
        view
        returns (uint256 setBitIndex)
    {
        setBitIndex = NOT_FOUND;
        uint256 bucket = upTo >> 8;
        uint256 bits;
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, bucket)
            mstore(0x20, bitmap.slot)
            let offset := and(0xff, not(upTo)) // `256 - (255 & upTo) - 1`.
            bits := shr(offset, shl(offset, sload(keccak256(0x00, 0x40))))
            if iszero(or(bits, iszero(bucket))) {
                for {} 1 {} {
                    bucket := add(bucket, setBitIndex) // `sub(bucket, 1)`.
                    mstore(0x00, bucket)
                    bits := sload(keccak256(0x00, 0x40))
                    if or(bits, iszero(bucket)) { break }
                }
            }
        }
        if (bits != 0) {
            setBitIndex = (bucket << 8) | LibBit.fls(bits);
            /// @solidity memory-safe-assembly
            assembly {
                setBitIndex := or(setBitIndex, sub(0, gt(setBitIndex, upTo)))
            }
        }
    }

    /// @dev Returns the index of the least significant unset bit in `[begin..upTo]`.
    /// If no unset bit is found, returns `NOT_FOUND`.
    function findFirstUnset(Bitmap storage bitmap, uint256 begin, uint256 upTo)
        internal
        view
        returns (uint256 unsetBitIndex)
    {
        unsetBitIndex = NOT_FOUND;
        uint256 bucket = begin >> 8;
        uint256 negBits;
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, bucket)
            mstore(0x20, bitmap.slot)
            let offset := and(0xff, begin)
            negBits := shl(offset, shr(offset, not(sload(keccak256(0x00, 0x40)))))
            if iszero(negBits) {
                let lastBucket := shr(8, upTo)
                for {} 1 {} {
                    bucket := add(bucket, 1)
                    mstore(0x00, bucket)
                    negBits := not(sload(keccak256(0x00, 0x40)))
                    if or(negBits, gt(bucket, lastBucket)) { break }
                }
                if gt(bucket, lastBucket) {
                    negBits := shl(and(0xff, not(upTo)), shr(and(0xff, not(upTo)), negBits))
                }
            }
        }
        if (negBits != 0) {
            uint256 r = (bucket << 8) | LibBit.ffs(negBits);
            /// @solidity memory-safe-assembly
            assembly {
                unsetBitIndex := or(r, sub(0, or(gt(r, upTo), lt(r, begin))))
            }
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Library for byte related operations.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/LibBytes.sol)
library LibBytes {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                          STRUCTS                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Goated bytes storage struct that totally MOGs, no cap, fr.
    /// Uses less gas and bytecode than Solidity's native bytes storage. It's meta af.
    /// Packs length with the first 31 bytes if <255 bytes, so it’s mad tight.
    struct BytesStorage {
        bytes32 _spacer;
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         CONSTANTS                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The constant returned when the `search` is not found in the bytes.
    uint256 internal constant NOT_FOUND = type(uint256).max;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                  BYTE STORAGE OPERATIONS                   */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Sets the value of the bytes storage `$` to `s`.
    function set(BytesStorage storage $, bytes memory s) internal {
        /// @solidity memory-safe-assembly
        assembly {
            let n := mload(s)
            let packed := or(0xff, shl(8, n))
            for { let i := 0 } 1 {} {
                if iszero(gt(n, 0xfe)) {
                    i := 0x1f
                    packed := or(n, shl(8, mload(add(s, i))))
                    if iszero(gt(n, i)) { break }
                }
                let o := add(s, 0x20)
                mstore(0x00, $.slot)
                for { let p := keccak256(0x00, 0x20) } 1 {} {
                    sstore(add(p, shr(5, i)), mload(add(o, i)))
                    i := add(i, 0x20)
                    if iszero(lt(i, n)) { break }
                }
                break
            }
            sstore($.slot, packed)
        }
    }

    /// @dev Sets the value of the bytes storage `$` to `s`.
    function setCalldata(BytesStorage storage $, bytes calldata s) internal {
        /// @solidity memory-safe-assembly
        assembly {
            let packed := or(0xff, shl(8, s.length))
            for { let i := 0 } 1 {} {
                if iszero(gt(s.length, 0xfe)) {
                    i := 0x1f
                    packed := or(s.length, shl(8, shr(8, calldataload(s.offset))))
                    if iszero(gt(s.length, i)) { break }
                }
                mstore(0x00, $.slot)
                for { let p := keccak256(0x00, 0x20) } 1 {} {
                    sstore(add(p, shr(5, i)), calldataload(add(s.offset, i)))
                    i := add(i, 0x20)
                    if iszero(lt(i, s.length)) { break }
                }
                break
            }
            sstore($.slot, packed)
        }
    }

    /// @dev Sets the value of the bytes storage `$` to the empty bytes.
    function clear(BytesStorage storage $) internal {
        delete $._spacer;
    }

    /// @dev Returns whether the value stored is `$` is the empty bytes "".
    function isEmpty(BytesStorage storage $) internal view returns (bool) {
        return uint256($._spacer) & 0xff == uint256(0);
    }

    /// @dev Returns the length of the value stored in `$`.
    function length(BytesStorage storage $) internal view returns (uint256 result) {
        result = uint256($._spacer);
        /// @solidity memory-safe-assembly
        assembly {
            let n := and(0xff, result)
            result := or(mul(shr(8, result), eq(0xff, n)), mul(n, iszero(eq(0xff, n))))
        }
    }

    /// @dev Returns the value stored in `$`.
    function get(BytesStorage storage $) internal view returns (bytes memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := mload(0x40)
            let o := add(result, 0x20)
            let packed := sload($.slot)
            let n := shr(8, packed)
            for { let i := 0 } 1 {} {
                if iszero(eq(and(packed, 0xff), 0xff)) {
                    mstore(o, packed)
                    n := and(0xff, packed)
                    i := 0x1f
                    if iszero(gt(n, i)) { break }
                }
                mstore(0x00, $.slot)
                for { let p := keccak256(0x00, 0x20) } 1 {} {
                    mstore(add(o, i), sload(add(p, shr(5, i))))
                    i := add(i, 0x20)
                    if iszero(lt(i, n)) { break }
                }
                break
            }
            mstore(result, n) // Store the length of the memory.
            mstore(add(o, n), 0) // Zeroize the slot after the bytes.
            mstore(0x40, add(add(o, n), 0x20)) // Allocate memory.
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      BYTES OPERATIONS                      */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns `subject` all occurrences of `needle` replaced with `replacement`.
    function replace(bytes memory subject, bytes memory needle, bytes memory replacement)
        internal
        pure
        returns (bytes memory result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            result := mload(0x40)
            let needleLen := mload(needle)
            let replacementLen := mload(replacement)
            let d := sub(result, subject) // Memory difference.
            let i := add(subject, 0x20) // Subject bytes pointer.
            mstore(0x00, add(i, mload(subject))) // End of subject.
            if iszero(gt(needleLen, mload(subject))) {
                let subjectSearchEnd := add(sub(mload(0x00), needleLen), 1)
                let h := 0 // The hash of `needle`.
                if iszero(lt(needleLen, 0x20)) { h := keccak256(add(needle, 0x20), needleLen) }
                let s := mload(add(needle, 0x20))
                for { let m := shl(3, sub(0x20, and(needleLen, 0x1f))) } 1 {} {
                    let t := mload(i)
                    // Whether the first `needleLen % 32` bytes of `subject` and `needle` matches.
                    if iszero(shr(m, xor(t, s))) {
                        if h {
                            if iszero(eq(keccak256(i, needleLen), h)) {
                                mstore(add(i, d), t)
                                i := add(i, 1)
                                if iszero(lt(i, subjectSearchEnd)) { break }
                                continue
                            }
                        }
                        // Copy the `replacement` one word at a time.
                        for { let j := 0 } 1 {} {
                            mstore(add(add(i, d), j), mload(add(add(replacement, 0x20), j)))
                            j := add(j, 0x20)
                            if iszero(lt(j, replacementLen)) { break }
                        }
                        d := sub(add(d, replacementLen), needleLen)
                        if needleLen {
                            i := add(i, needleLen)
                            if iszero(lt(i, subjectSearchEnd)) { break }
                            continue
                        }
                    }
                    mstore(add(i, d), t)
                    i := add(i, 1)
                    if iszero(lt(i, subjectSearchEnd)) { break }
                }
            }
            let end := mload(0x00)
            let n := add(sub(d, add(result, 0x20)), end)
            // Copy the rest of the bytes one word at a time.
            for {} lt(i, end) { i := add(i, 0x20) } { mstore(add(i, d), mload(i)) }
            let o := add(i, d)
            mstore(o, 0) // Zeroize the slot after the bytes.
            mstore(0x40, add(o, 0x20)) // Allocate memory.
            mstore(result, n) // Store the length.
        }
    }

    /// @dev Returns the byte index of the first location of `needle` in `subject`,
    /// needleing from left to right, starting from `from`.
    /// Returns `NOT_FOUND` (i.e. `type(uint256).max`) if the `needle` is not found.
    function indexOf(bytes memory subject, bytes memory needle, uint256 from)
        internal
        pure
        returns (uint256 result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            result := not(0) // Initialize to `NOT_FOUND`.
            for { let subjectLen := mload(subject) } 1 {} {
                if iszero(mload(needle)) {
                    result := from
                    if iszero(gt(from, subjectLen)) { break }
                    result := subjectLen
                    break
                }
                let needleLen := mload(needle)
                let subjectStart := add(subject, 0x20)

                subject := add(subjectStart, from)
                let end := add(sub(add(subjectStart, subjectLen), needleLen), 1)
                let m := shl(3, sub(0x20, and(needleLen, 0x1f)))
                let s := mload(add(needle, 0x20))

                if iszero(and(lt(subject, end), lt(from, subjectLen))) { break }

                if iszero(lt(needleLen, 0x20)) {
                    for { let h := keccak256(add(needle, 0x20), needleLen) } 1 {} {
                        if iszero(shr(m, xor(mload(subject), s))) {
                            if eq(keccak256(subject, needleLen), h) {
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

    /// @dev Returns the byte index of the first location of `needle` in `subject`,
    /// needleing from left to right.
    /// Returns `NOT_FOUND` (i.e. `type(uint256).max`) if the `needle` is not found.
    function indexOf(bytes memory subject, bytes memory needle) internal pure returns (uint256) {
        return indexOf(subject, needle, 0);
    }

    /// @dev Returns the byte index of the first location of `needle` in `subject`,
    /// needleing from right to left, starting from `from`.
    /// Returns `NOT_FOUND` (i.e. `type(uint256).max`) if the `needle` is not found.
    function lastIndexOf(bytes memory subject, bytes memory needle, uint256 from)
        internal
        pure
        returns (uint256 result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            for {} 1 {} {
                result := not(0) // Initialize to `NOT_FOUND`.
                let needleLen := mload(needle)
                if gt(needleLen, mload(subject)) { break }
                let w := result

                let fromMax := sub(mload(subject), needleLen)
                if iszero(gt(fromMax, from)) { from := fromMax }

                let end := add(add(subject, 0x20), w)
                subject := add(add(subject, 0x20), from)
                if iszero(gt(subject, end)) { break }
                // As this function is not too often used,
                // we shall simply use keccak256 for smaller bytecode size.
                for { let h := keccak256(add(needle, 0x20), needleLen) } 1 {} {
                    if eq(keccak256(subject, needleLen), h) {
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

    /// @dev Returns the byte index of the first location of `needle` in `subject`,
    /// needleing from right to left.
    /// Returns `NOT_FOUND` (i.e. `type(uint256).max`) if the `needle` is not found.
    function lastIndexOf(bytes memory subject, bytes memory needle)
        internal
        pure
        returns (uint256)
    {
        return lastIndexOf(subject, needle, type(uint256).max);
    }

    /// @dev Returns true if `needle` is found in `subject`, false otherwise.
    function contains(bytes memory subject, bytes memory needle) internal pure returns (bool) {
        return indexOf(subject, needle) != NOT_FOUND;
    }

    /// @dev Returns whether `subject` starts with `needle`.
    function startsWith(bytes memory subject, bytes memory needle)
        internal
        pure
        returns (bool result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let n := mload(needle)
            // Just using keccak256 directly is actually cheaper.
            let t := eq(keccak256(add(subject, 0x20), n), keccak256(add(needle, 0x20), n))
            result := lt(gt(n, mload(subject)), t)
        }
    }

    /// @dev Returns whether `subject` ends with `needle`.
    function endsWith(bytes memory subject, bytes memory needle)
        internal
        pure
        returns (bool result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let n := mload(needle)
            let notInRange := gt(n, mload(subject))
            // `subject + 0x20 + max(subject.length - needle.length, 0)`.
            let t := add(add(subject, 0x20), mul(iszero(notInRange), sub(mload(subject), n)))
            // Just using keccak256 directly is actually cheaper.
            result := gt(eq(keccak256(t, n), keccak256(add(needle, 0x20), n)), notInRange)
        }
    }

    /// @dev Returns `subject` repeated `times`.
    function repeat(bytes memory subject, uint256 times)
        internal
        pure
        returns (bytes memory result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let l := mload(subject) // Subject length.
            if iszero(or(iszero(times), iszero(l))) {
                result := mload(0x40)
                subject := add(subject, 0x20)
                let o := add(result, 0x20)
                for {} 1 {} {
                    // Copy the `subject` one word at a time.
                    for { let j := 0 } 1 {} {
                        mstore(add(o, j), mload(add(subject, j)))
                        j := add(j, 0x20)
                        if iszero(lt(j, l)) { break }
                    }
                    o := add(o, l)
                    times := sub(times, 1)
                    if iszero(times) { break }
                }
                mstore(o, 0) // Zeroize the slot after the bytes.
                mstore(0x40, add(o, 0x20)) // Allocate memory.
                mstore(result, sub(o, add(result, 0x20))) // Store the length.
            }
        }
    }

    /// @dev Returns a copy of `subject` sliced from `start` to `end` (exclusive).
    /// `start` and `end` are byte offsets.
    function slice(bytes memory subject, uint256 start, uint256 end)
        internal
        pure
        returns (bytes memory result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let l := mload(subject) // Subject length.
            if iszero(gt(l, end)) { end := l }
            if iszero(gt(l, start)) { start := l }
            if lt(start, end) {
                result := mload(0x40)
                let n := sub(end, start)
                let i := add(subject, start)
                let w := not(0x1f)
                // Copy the `subject` one word at a time, backwards.
                for { let j := and(add(n, 0x1f), w) } 1 {} {
                    mstore(add(result, j), mload(add(i, j)))
                    j := add(j, w) // `sub(j, 0x20)`.
                    if iszero(j) { break }
                }
                let o := add(add(result, 0x20), n)
                mstore(o, 0) // Zeroize the slot after the bytes.
                mstore(0x40, add(o, 0x20)) // Allocate memory.
                mstore(result, n) // Store the length.
            }
        }
    }

    /// @dev Returns a copy of `subject` sliced from `start` to the end of the bytes.
    /// `start` is a byte offset.
    function slice(bytes memory subject, uint256 start)
        internal
        pure
        returns (bytes memory result)
    {
        result = slice(subject, start, type(uint256).max);
    }

    /// @dev Returns a copy of `subject` sliced from `start` to `end` (exclusive).
    /// `start` and `end` are byte offsets. Faster than Solidity's native slicing.
    function sliceCalldata(bytes calldata subject, uint256 start, uint256 end)
        internal
        pure
        returns (bytes calldata result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            end := xor(end, mul(xor(end, subject.length), lt(subject.length, end)))
            start := xor(start, mul(xor(start, subject.length), lt(subject.length, start)))
            result.offset := add(subject.offset, start)
            result.length := mul(lt(start, end), sub(end, start))
        }
    }

    /// @dev Returns a copy of `subject` sliced from `start` to the end of the bytes.
    /// `start` is a byte offset. Faster than Solidity's native slicing.
    function sliceCalldata(bytes calldata subject, uint256 start)
        internal
        pure
        returns (bytes calldata result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            start := xor(start, mul(xor(start, subject.length), lt(subject.length, start)))
            result.offset := add(subject.offset, start)
            result.length := mul(lt(start, subject.length), sub(subject.length, start))
        }
    }

    /// @dev Reduces the size of `subject` to `n`.
    /// If `n` is greater than the size of `subject`, this will be a no-op.
    function truncate(bytes memory subject, uint256 n)
        internal
        pure
        returns (bytes memory result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            result := subject
            mstore(mul(lt(n, mload(result)), result), n)
        }
    }

    /// @dev Returns a copy of `subject`, with the length reduced to `n`.
    /// If `n` is greater than the size of `subject`, this will be a no-op.
    function truncatedCalldata(bytes calldata subject, uint256 n)
        internal
        pure
        returns (bytes calldata result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            result.offset := subject.offset
            result.length := xor(n, mul(xor(n, subject.length), lt(subject.length, n)))
        }
    }

    /// @dev Returns all the indices of `needle` in `subject`.
    /// The indices are byte offsets.
    function indicesOf(bytes memory subject, bytes memory needle)
        internal
        pure
        returns (uint256[] memory result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let searchLen := mload(needle)
            if iszero(gt(searchLen, mload(subject))) {
                result := mload(0x40)
                let i := add(subject, 0x20)
                let o := add(result, 0x20)
                let subjectSearchEnd := add(sub(add(i, mload(subject)), searchLen), 1)
                let h := 0 // The hash of `needle`.
                if iszero(lt(searchLen, 0x20)) { h := keccak256(add(needle, 0x20), searchLen) }
                let s := mload(add(needle, 0x20))
                for { let m := shl(3, sub(0x20, and(searchLen, 0x1f))) } 1 {} {
                    let t := mload(i)
                    // Whether the first `searchLen % 32` bytes of `subject` and `needle` matches.
                    if iszero(shr(m, xor(t, s))) {
                        if h {
                            if iszero(eq(keccak256(i, searchLen), h)) {
                                i := add(i, 1)
                                if iszero(lt(i, subjectSearchEnd)) { break }
                                continue
                            }
                        }
                        mstore(o, sub(i, add(subject, 0x20))) // Append to `result`.
                        o := add(o, 0x20)
                        i := add(i, searchLen) // Advance `i` by `searchLen`.
                        if searchLen {
                            if iszero(lt(i, subjectSearchEnd)) { break }
                            continue
                        }
                    }
                    i := add(i, 1)
                    if iszero(lt(i, subjectSearchEnd)) { break }
                }
                mstore(result, shr(5, sub(o, add(result, 0x20)))) // Store the length of `result`.
                // Allocate memory for result.
                // We allocate one more word, so this array can be recycled for {split}.
                mstore(0x40, add(o, 0x20))
            }
        }
    }

    /// @dev Returns a arrays of bytess based on the `delimiter` inside of the `subject` bytes.
    function split(bytes memory subject, bytes memory delimiter)
        internal
        pure
        returns (bytes[] memory result)
    {
        uint256[] memory indices = indicesOf(subject, delimiter);
        /// @solidity memory-safe-assembly
        assembly {
            let w := not(0x1f)
            let indexPtr := add(indices, 0x20)
            let indicesEnd := add(indexPtr, shl(5, add(mload(indices), 1)))
            mstore(add(indicesEnd, w), mload(subject))
            mstore(indices, add(mload(indices), 1))
            for { let prevIndex := 0 } 1 {} {
                let index := mload(indexPtr)
                mstore(indexPtr, 0x60)
                if iszero(eq(index, prevIndex)) {
                    let element := mload(0x40)
                    let l := sub(index, prevIndex)
                    mstore(element, l) // Store the length of the element.
                    // Copy the `subject` one word at a time, backwards.
                    for { let o := and(add(l, 0x1f), w) } 1 {} {
                        mstore(add(element, o), mload(add(add(subject, prevIndex), o)))
                        o := add(o, w) // `sub(o, 0x20)`.
                        if iszero(o) { break }
                    }
                    mstore(add(add(element, 0x20), l), 0) // Zeroize the slot after the bytes.
                    // Allocate memory for the length and the bytes, rounded up to a multiple of 32.
                    mstore(0x40, add(element, and(add(l, 0x3f), w)))
                    mstore(indexPtr, element) // Store the `element` into the array.
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

    /// @dev Returns a concatenated bytes of `a` and `b`.
    /// Cheaper than `bytes.concat()` and does not de-align the free memory pointer.
    function concat(bytes memory a, bytes memory b) internal pure returns (bytes memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := mload(0x40)
            let w := not(0x1f)
            let aLen := mload(a)
            // Copy `a` one word at a time, backwards.
            for { let o := and(add(aLen, 0x20), w) } 1 {} {
                mstore(add(result, o), mload(add(a, o)))
                o := add(o, w) // `sub(o, 0x20)`.
                if iszero(o) { break }
            }
            let bLen := mload(b)
            let output := add(result, aLen)
            // Copy `b` one word at a time, backwards.
            for { let o := and(add(bLen, 0x20), w) } 1 {} {
                mstore(add(output, o), mload(add(b, o)))
                o := add(o, w) // `sub(o, 0x20)`.
                if iszero(o) { break }
            }
            let totalLen := add(aLen, bLen)
            let last := add(add(result, 0x20), totalLen)
            mstore(last, 0) // Zeroize the slot after the bytes.
            mstore(result, totalLen) // Store the length.
            mstore(0x40, add(last, 0x20)) // Allocate memory.
        }
    }

    /// @dev Returns whether `a` equals `b`.
    function eq(bytes memory a, bytes memory b) internal pure returns (bool result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := eq(keccak256(add(a, 0x20), mload(a)), keccak256(add(b, 0x20), mload(b)))
        }
    }

    /// @dev Returns whether `a` equals `b`, where `b` is a null-terminated small bytes.
    function eqs(bytes memory a, bytes32 b) internal pure returns (bool result) {
        /// @solidity memory-safe-assembly
        assembly {
            // These should be evaluated on compile time, as far as possible.
            let m := not(shl(7, div(not(iszero(b)), 255))) // `0x7f7f ...`.
            let x := not(or(m, or(b, add(m, and(b, m)))))
            let r := shl(7, iszero(iszero(shr(128, x))))
            r := or(r, shl(6, iszero(iszero(shr(64, shr(r, x))))))
            r := or(r, shl(5, lt(0xffffffff, shr(r, x))))
            r := or(r, shl(4, lt(0xffff, shr(r, x))))
            r := or(r, shl(3, lt(0xff, shr(r, x))))
            // forgefmt: disable-next-item
            result := gt(eq(mload(a), add(iszero(x), xor(31, shr(3, r)))),
                xor(shr(add(8, r), b), shr(add(8, r), mload(add(a, 0x20)))))
        }
    }

    /// @dev Directly returns `a` without copying.
    function directReturn(bytes memory a) internal pure {
        assembly {
            // Assumes that the bytes does not start from the scratch space.
            let retStart := sub(a, 0x20)
            let retUnpaddedSize := add(mload(a), 0x40)
            // Right pad with zeroes. Just in case the bytes is produced
            // by a method that doesn't zero right pad.
            mstore(add(retStart, retUnpaddedSize), 0)
            mstore(retStart, 0x20) // Store the return offset.
            // End the transaction, returning the bytes.
            return(retStart, and(not(0x1f), add(0x1f, retUnpaddedSize)))
        }
    }

    /// @dev Directly returns `a` with minimal copying.
    function directReturn(bytes[] memory a) internal pure {
        assembly {
            let n := mload(a) // `a.length`.
            let o := add(a, 0x20) // Start of elements in `a`.
            let u := a // Highest memory slot.
            let w := not(0x1f)
            for { let i := 0 } iszero(eq(i, n)) { i := add(i, 1) } {
                let c := add(o, shl(5, i)) // Location of pointer to `a[i]`.
                let s := mload(c) // `a[i]`.
                let l := mload(s) // `a[i].length`.
                let r := and(l, 0x1f) // `a[i].length % 32`.
                let z := add(0x20, and(l, w)) // Offset of last word in `a[i]` from `s`.
                // If `s` comes before `o`, or `s` is not zero right padded.
                if iszero(lt(lt(s, o), or(iszero(r), iszero(shl(shl(3, r), mload(add(s, z))))))) {
                    let m := mload(0x40)
                    mstore(m, l) // Copy `a[i].length`.
                    for {} 1 {} {
                        mstore(add(m, z), mload(add(s, z))) // Copy `a[i]`, backwards.
                        z := add(z, w) // `sub(z, 0x20)`.
                        if iszero(z) { break }
                    }
                    let e := add(add(m, 0x20), l)
                    mstore(e, 0) // Zeroize the slot after the copied bytes.
                    mstore(0x40, add(e, 0x20)) // Allocate memory.
                    s := m
                }
                mstore(c, sub(s, o)) // Convert to calldata offset.
                let t := add(l, add(s, 0x20))
                if iszero(lt(t, u)) { u := t }
            }
            let retStart := add(a, w) // Assumes `a` doesn't start from scratch space.
            mstore(retStart, 0x20) // Store the return offset.
            return(retStart, add(0x40, sub(u, retStart))) // End the transaction.
        }
    }

    /// @dev Returns the word at `offset`, without any bounds checks.
    /// To load an address, you can use `address(bytes20(load(a, offset)))`.
    function load(bytes memory a, uint256 offset) internal pure returns (bytes32 result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := mload(add(add(a, 0x20), offset))
        }
    }

    /// @dev Returns the word at `offset`, without any bounds checks.
    /// To load an address, you can use `address(bytes20(loadCalldata(a, offset)))`.
    function loadCalldata(bytes calldata a, uint256 offset)
        internal
        pure
        returns (bytes32 result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            result := calldataload(add(a.offset, offset))
        }
    }

    /// @dev Returns empty calldata bytes. For silencing the compiler.
    function emptyCalldata() internal pure returns (bytes calldata result) {
        /// @solidity memory-safe-assembly
        assembly {
            result.length := 0
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Minimal proxy library.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/LibClone.sol)
/// @author Minimal proxy by 0age (https://github.com/0age)
/// @author Clones with immutable args by wighawag, zefram.eth, Saw-mon & Natalie
/// (https://github.com/Saw-mon-and-Natalie/clones-with-immutable-args)
/// @author Minimal ERC1967 proxy by jtriley-eth (https://github.com/jtriley-eth/minimum-viable-proxy)
///
/// @dev Minimal proxy:
/// Although the sw0nt pattern saves 5 gas over the ERC1167 pattern during runtime,
/// it is not supported out-of-the-box on Etherscan. Hence, we choose to use the 0age pattern,
/// which saves 4 gas over the ERC1167 pattern during runtime, and has the smallest bytecode.
/// - Automatically verified on Etherscan.
///
/// @dev Minimal proxy (PUSH0 variant):
/// This is a new minimal proxy that uses the PUSH0 opcode introduced during Shanghai.
/// It is optimized first for minimal runtime gas, then for minimal bytecode.
/// The PUSH0 clone functions are intentionally postfixed with a jarring "_PUSH0" as
/// many EVM chains may not support the PUSH0 opcode in the early months after Shanghai.
/// Please use with caution.
/// - Automatically verified on Etherscan.
///
/// @dev Clones with immutable args (CWIA):
/// The implementation of CWIA here is does NOT append the immutable args into the calldata
/// passed into delegatecall. It is simply an ERC1167 minimal proxy with the immutable arguments
/// appended to the back of the runtime bytecode.
/// - Uses the identity precompile (0x4) to copy args during deployment.
///
/// @dev Minimal ERC1967 proxy:
/// An minimal ERC1967 proxy, intended to be upgraded with UUPS.
/// This is NOT the same as ERC1967Factory's transparent proxy, which includes admin logic.
/// - Automatically verified on Etherscan.
///
/// @dev Minimal ERC1967 proxy with immutable args:
/// - Uses the identity precompile (0x4) to copy args during deployment.
/// - Automatically verified on Etherscan.
///
/// @dev ERC1967I proxy:
/// An variant of the minimal ERC1967 proxy, with a special code path that activates
/// if `calldatasize() == 1`. This code path skips the delegatecall and directly returns the
/// `implementation` address. The returned implementation is guaranteed to be valid if the
/// keccak256 of the proxy's code is equal to `ERC1967I_CODE_HASH`.
///
/// @dev ERC1967I proxy with immutable args:
/// An variant of the minimal ERC1967 proxy, with a special code path that activates
/// if `calldatasize() == 1`. This code path skips the delegatecall and directly returns the
/// - Uses the identity precompile (0x4) to copy args during deployment.
///
/// @dev Minimal ERC1967 beacon proxy:
/// A minimal beacon proxy, intended to be upgraded with an upgradable beacon.
/// - Automatically verified on Etherscan.
///
/// @dev Minimal ERC1967 beacon proxy with immutable args:
/// - Uses the identity precompile (0x4) to copy args during deployment.
/// - Automatically verified on Etherscan.
///
/// @dev ERC1967I beacon proxy:
/// An variant of the minimal ERC1967 beacon proxy, with a special code path that activates
/// if `calldatasize() == 1`. This code path skips the delegatecall and directly returns the
/// `implementation` address. The returned implementation is guaranteed to be valid if the
/// keccak256 of the proxy's code is equal to `ERC1967I_CODE_HASH`.
///
/// @dev ERC1967I proxy with immutable args:
/// An variant of the minimal ERC1967 beacon proxy, with a special code path that activates
/// if `calldatasize() == 1`. This code path skips the delegatecall and directly returns the
/// - Uses the identity precompile (0x4) to copy args during deployment.
library LibClone {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         CONSTANTS                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The keccak256 of deployed code for the clone proxy,
    /// with the implementation set to `address(0)`.
    bytes32 internal constant CLONE_CODE_HASH =
        0x48db2cfdb2853fce0b464f1f93a1996469459df3ab6c812106074c4106a1eb1f;

    /// @dev The keccak256 of deployed code for the PUSH0 proxy,
    /// with the implementation set to `address(0)`.
    bytes32 internal constant PUSH0_CLONE_CODE_HASH =
        0x67bc6bde1b84d66e267c718ba44cf3928a615d29885537955cb43d44b3e789dc;

    /// @dev The keccak256 of deployed code for the ERC-1167 CWIA proxy,
    /// with the implementation set to `address(0)`.
    bytes32 internal constant CWIA_CODE_HASH =
        0x3cf92464268225a4513da40a34d967354684c32cd0edd67b5f668dfe3550e940;

    /// @dev The keccak256 of the deployed code for the ERC1967 proxy.
    bytes32 internal constant ERC1967_CODE_HASH =
        0xaaa52c8cc8a0e3fd27ce756cc6b4e70c51423e9b597b11f32d3e49f8b1fc890d;

    /// @dev The keccak256 of the deployed code for the ERC1967I proxy.
    bytes32 internal constant ERC1967I_CODE_HASH =
        0xce700223c0d4cea4583409accfc45adac4a093b3519998a9cbbe1504dadba6f7;

    /// @dev The keccak256 of the deployed code for the ERC1967 beacon proxy.
    bytes32 internal constant ERC1967_BEACON_PROXY_CODE_HASH =
        0x14044459af17bc4f0f5aa2f658cb692add77d1302c29fe2aebab005eea9d1162;

    /// @dev The keccak256 of the deployed code for the ERC1967 beacon proxy.
    bytes32 internal constant ERC1967I_BEACON_PROXY_CODE_HASH =
        0xf8c46d2793d5aa984eb827aeaba4b63aedcab80119212fce827309788735519a;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       CUSTOM ERRORS                        */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Unable to deploy the clone.
    error DeploymentFailed();

    /// @dev The salt must start with either the zero address or `by`.
    error SaltDoesNotStartWith();

    /// @dev The ETH transfer has failed.
    error ETHTransferFailed();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                  MINIMAL PROXY OPERATIONS                  */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Deploys a clone of `implementation`.
    function clone(address implementation) internal returns (address instance) {
        instance = clone(0, implementation);
    }

    /// @dev Deploys a clone of `implementation`.
    /// Deposits `value` ETH during deployment.
    function clone(uint256 value, address implementation) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            /**
             * --------------------------------------------------------------------------+
             * CREATION (9 bytes)                                                        |
             * --------------------------------------------------------------------------|
             * Opcode     | Mnemonic          | Stack     | Memory                       |
             * --------------------------------------------------------------------------|
             * 60 runSize | PUSH1 runSize     | r         |                              |
             * 3d         | RETURNDATASIZE    | 0 r       |                              |
             * 81         | DUP2              | r 0 r     |                              |
             * 60 offset  | PUSH1 offset      | o r 0 r   |                              |
             * 3d         | RETURNDATASIZE    | 0 o r 0 r |                              |
             * 39         | CODECOPY          | 0 r       | [0..runSize): runtime code   |
             * f3         | RETURN            |           | [0..runSize): runtime code   |
             * --------------------------------------------------------------------------|
             * RUNTIME (44 bytes)                                                        |
             * --------------------------------------------------------------------------|
             * Opcode  | Mnemonic       | Stack                  | Memory                |
             * --------------------------------------------------------------------------|
             *                                                                           |
             * ::: keep some values in stack ::::::::::::::::::::::::::::::::::::::::::: |
             * 3d      | RETURNDATASIZE | 0                      |                       |
             * 3d      | RETURNDATASIZE | 0 0                    |                       |
             * 3d      | RETURNDATASIZE | 0 0 0                  |                       |
             * 3d      | RETURNDATASIZE | 0 0 0 0                |                       |
             *                                                                           |
             * ::: copy calldata to memory ::::::::::::::::::::::::::::::::::::::::::::: |
             * 36      | CALLDATASIZE   | cds 0 0 0 0            |                       |
             * 3d      | RETURNDATASIZE | 0 cds 0 0 0 0          |                       |
             * 3d      | RETURNDATASIZE | 0 0 cds 0 0 0 0        |                       |
             * 37      | CALLDATACOPY   | 0 0 0 0                | [0..cds): calldata    |
             *                                                                           |
             * ::: delegate call to the implementation contract :::::::::::::::::::::::: |
             * 36      | CALLDATASIZE   | cds 0 0 0 0            | [0..cds): calldata    |
             * 3d      | RETURNDATASIZE | 0 cds 0 0 0 0          | [0..cds): calldata    |
             * 73 addr | PUSH20 addr    | addr 0 cds 0 0 0 0     | [0..cds): calldata    |
             * 5a      | GAS            | gas addr 0 cds 0 0 0 0 | [0..cds): calldata    |
             * f4      | DELEGATECALL   | success 0 0            | [0..cds): calldata    |
             *                                                                           |
             * ::: copy return data to memory :::::::::::::::::::::::::::::::::::::::::: |
             * 3d      | RETURNDATASIZE | rds success 0 0        | [0..cds): calldata    |
             * 3d      | RETURNDATASIZE | rds rds success 0 0    | [0..cds): calldata    |
             * 93      | SWAP4          | 0 rds success 0 rds    | [0..cds): calldata    |
             * 80      | DUP1           | 0 0 rds success 0 rds  | [0..cds): calldata    |
             * 3e      | RETURNDATACOPY | success 0 rds          | [0..rds): returndata  |
             *                                                                           |
             * 60 0x2a | PUSH1 0x2a     | 0x2a success 0 rds     | [0..rds): returndata  |
             * 57      | JUMPI          | 0 rds                  | [0..rds): returndata  |
             *                                                                           |
             * ::: revert :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: |
             * fd      | REVERT         |                        | [0..rds): returndata  |
             *                                                                           |
             * ::: return :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: |
             * 5b      | JUMPDEST       | 0 rds                  | [0..rds): returndata  |
             * f3      | RETURN         |                        | [0..rds): returndata  |
             * --------------------------------------------------------------------------+
             */
            mstore(0x21, 0x5af43d3d93803e602a57fd5bf3)
            mstore(0x14, implementation)
            mstore(0x00, 0x602c3d8160093d39f33d3d3d3d363d3d37363d73)
            instance := create(value, 0x0c, 0x35)
            if iszero(instance) {
                mstore(0x00, 0x30116425) // `DeploymentFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x21, 0) // Restore the overwritten part of the free memory pointer.
        }
    }

    /// @dev Deploys a deterministic clone of `implementation` with `salt`.
    function cloneDeterministic(address implementation, bytes32 salt)
        internal
        returns (address instance)
    {
        instance = cloneDeterministic(0, implementation, salt);
    }

    /// @dev Deploys a deterministic clone of `implementation` with `salt`.
    /// Deposits `value` ETH during deployment.
    function cloneDeterministic(uint256 value, address implementation, bytes32 salt)
        internal
        returns (address instance)
    {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x21, 0x5af43d3d93803e602a57fd5bf3)
            mstore(0x14, implementation)
            mstore(0x00, 0x602c3d8160093d39f33d3d3d3d363d3d37363d73)
            instance := create2(value, 0x0c, 0x35, salt)
            if iszero(instance) {
                mstore(0x00, 0x30116425) // `DeploymentFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x21, 0) // Restore the overwritten part of the free memory pointer.
        }
    }

    /// @dev Returns the initialization code of the clone of `implementation`.
    function initCode(address implementation) internal pure returns (bytes memory c) {
        /// @solidity memory-safe-assembly
        assembly {
            c := mload(0x40)
            mstore(add(c, 0x40), 0x5af43d3d93803e602a57fd5bf30000000000000000000000)
            mstore(add(c, 0x28), implementation)
            mstore(add(c, 0x14), 0x602c3d8160093d39f33d3d3d3d363d3d37363d73)
            mstore(c, 0x35) // Store the length.
            mstore(0x40, add(c, 0x60)) // Allocate memory.
        }
    }

    /// @dev Returns the initialization code hash of the clone of `implementation`.
    function initCodeHash(address implementation) internal pure returns (bytes32 hash) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x21, 0x5af43d3d93803e602a57fd5bf3)
            mstore(0x14, implementation)
            mstore(0x00, 0x602c3d8160093d39f33d3d3d3d363d3d37363d73)
            hash := keccak256(0x0c, 0x35)
            mstore(0x21, 0) // Restore the overwritten part of the free memory pointer.
        }
    }

    /// @dev Returns the address of the clone of `implementation`, with `salt` by `deployer`.
    /// Note: The returned result has dirty upper 96 bits. Please clean if used in assembly.
    function predictDeterministicAddress(address implementation, bytes32 salt, address deployer)
        internal
        pure
        returns (address predicted)
    {
        bytes32 hash = initCodeHash(implementation);
        predicted = predictDeterministicAddress(hash, salt, deployer);
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*          MINIMAL PROXY OPERATIONS (PUSH0 VARIANT)          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Deploys a PUSH0 clone of `implementation`.
    function clone_PUSH0(address implementation) internal returns (address instance) {
        instance = clone_PUSH0(0, implementation);
    }

    /// @dev Deploys a PUSH0 clone of `implementation`.
    /// Deposits `value` ETH during deployment.
    function clone_PUSH0(uint256 value, address implementation)
        internal
        returns (address instance)
    {
        /// @solidity memory-safe-assembly
        assembly {
            /**
             * --------------------------------------------------------------------------+
             * CREATION (9 bytes)                                                        |
             * --------------------------------------------------------------------------|
             * Opcode     | Mnemonic          | Stack     | Memory                       |
             * --------------------------------------------------------------------------|
             * 60 runSize | PUSH1 runSize     | r         |                              |
             * 5f         | PUSH0             | 0 r       |                              |
             * 81         | DUP2              | r 0 r     |                              |
             * 60 offset  | PUSH1 offset      | o r 0 r   |                              |
             * 5f         | PUSH0             | 0 o r 0 r |                              |
             * 39         | CODECOPY          | 0 r       | [0..runSize): runtime code   |
             * f3         | RETURN            |           | [0..runSize): runtime code   |
             * --------------------------------------------------------------------------|
             * RUNTIME (45 bytes)                                                        |
             * --------------------------------------------------------------------------|
             * Opcode  | Mnemonic       | Stack                  | Memory                |
             * --------------------------------------------------------------------------|
             *                                                                           |
             * ::: keep some values in stack ::::::::::::::::::::::::::::::::::::::::::: |
             * 5f      | PUSH0          | 0                      |                       |
             * 5f      | PUSH0          | 0 0                    |                       |
             *                                                                           |
             * ::: copy calldata to memory ::::::::::::::::::::::::::::::::::::::::::::: |
             * 36      | CALLDATASIZE   | cds 0 0                |                       |
             * 5f      | PUSH0          | 0 cds 0 0              |                       |
             * 5f      | PUSH0          | 0 0 cds 0 0            |                       |
             * 37      | CALLDATACOPY   | 0 0                    | [0..cds): calldata    |
             *                                                                           |
             * ::: delegate call to the implementation contract :::::::::::::::::::::::: |
             * 36      | CALLDATASIZE   | cds 0 0                | [0..cds): calldata    |
             * 5f      | PUSH0          | 0 cds 0 0              | [0..cds): calldata    |
             * 73 addr | PUSH20 addr    | addr 0 cds 0 0         | [0..cds): calldata    |
             * 5a      | GAS            | gas addr 0 cds 0 0     | [0..cds): calldata    |
             * f4      | DELEGATECALL   | success                | [0..cds): calldata    |
             *                                                                           |
             * ::: copy return data to memory :::::::::::::::::::::::::::::::::::::::::: |
             * 3d      | RETURNDATASIZE | rds success            | [0..cds): calldata    |
             * 5f      | PUSH0          | 0 rds success          | [0..cds): calldata    |
             * 5f      | PUSH0          | 0 0 rds success        | [0..cds): calldata    |
             * 3e      | RETURNDATACOPY | success                | [0..rds): returndata  |
             *                                                                           |
             * 60 0x29 | PUSH1 0x29     | 0x29 success           | [0..rds): returndata  |
             * 57      | JUMPI          |                        | [0..rds): returndata  |
             *                                                                           |
             * ::: revert :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: |
             * 3d      | RETURNDATASIZE | rds                    | [0..rds): returndata  |
             * 5f      | PUSH0          | 0 rds                  | [0..rds): returndata  |
             * fd      | REVERT         |                        | [0..rds): returndata  |
             *                                                                           |
             * ::: return :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: |
             * 5b      | JUMPDEST       |                        | [0..rds): returndata  |
             * 3d      | RETURNDATASIZE | rds                    | [0..rds): returndata  |
             * 5f      | PUSH0          | 0 rds                  | [0..rds): returndata  |
             * f3      | RETURN         |                        | [0..rds): returndata  |
             * --------------------------------------------------------------------------+
             */
            mstore(0x24, 0x5af43d5f5f3e6029573d5ffd5b3d5ff3) // 16
            mstore(0x14, implementation) // 20
            mstore(0x00, 0x602d5f8160095f39f35f5f365f5f37365f73) // 9 + 9
            instance := create(value, 0x0e, 0x36)
            if iszero(instance) {
                mstore(0x00, 0x30116425) // `DeploymentFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x24, 0) // Restore the overwritten part of the free memory pointer.
        }
    }

    /// @dev Deploys a deterministic PUSH0 clone of `implementation` with `salt`.
    function cloneDeterministic_PUSH0(address implementation, bytes32 salt)
        internal
        returns (address instance)
    {
        instance = cloneDeterministic_PUSH0(0, implementation, salt);
    }

    /// @dev Deploys a deterministic PUSH0 clone of `implementation` with `salt`.
    /// Deposits `value` ETH during deployment.
    function cloneDeterministic_PUSH0(uint256 value, address implementation, bytes32 salt)
        internal
        returns (address instance)
    {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x24, 0x5af43d5f5f3e6029573d5ffd5b3d5ff3) // 16
            mstore(0x14, implementation) // 20
            mstore(0x00, 0x602d5f8160095f39f35f5f365f5f37365f73) // 9 + 9
            instance := create2(value, 0x0e, 0x36, salt)
            if iszero(instance) {
                mstore(0x00, 0x30116425) // `DeploymentFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x24, 0) // Restore the overwritten part of the free memory pointer.
        }
    }

    /// @dev Returns the initialization code of the PUSH0 clone of `implementation`.
    function initCode_PUSH0(address implementation) internal pure returns (bytes memory c) {
        /// @solidity memory-safe-assembly
        assembly {
            c := mload(0x40)
            mstore(add(c, 0x40), 0x5af43d5f5f3e6029573d5ffd5b3d5ff300000000000000000000) // 16
            mstore(add(c, 0x26), implementation) // 20
            mstore(add(c, 0x12), 0x602d5f8160095f39f35f5f365f5f37365f73) // 9 + 9
            mstore(c, 0x36) // Store the length.
            mstore(0x40, add(c, 0x60)) // Allocate memory.
        }
    }

    /// @dev Returns the initialization code hash of the PUSH0 clone of `implementation`.
    function initCodeHash_PUSH0(address implementation) internal pure returns (bytes32 hash) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x24, 0x5af43d5f5f3e6029573d5ffd5b3d5ff3) // 16
            mstore(0x14, implementation) // 20
            mstore(0x00, 0x602d5f8160095f39f35f5f365f5f37365f73) // 9 + 9
            hash := keccak256(0x0e, 0x36)
            mstore(0x24, 0) // Restore the overwritten part of the free memory pointer.
        }
    }

    /// @dev Returns the address of the PUSH0 clone of `implementation`, with `salt` by `deployer`.
    /// Note: The returned result has dirty upper 96 bits. Please clean if used in assembly.
    function predictDeterministicAddress_PUSH0(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        bytes32 hash = initCodeHash_PUSH0(implementation);
        predicted = predictDeterministicAddress(hash, salt, deployer);
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*           CLONES WITH IMMUTABLE ARGS OPERATIONS            */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Deploys a clone of `implementation` with immutable arguments encoded in `args`.
    function clone(address implementation, bytes memory args) internal returns (address instance) {
        instance = clone(0, implementation, args);
    }

    /// @dev Deploys a clone of `implementation` with immutable arguments encoded in `args`.
    /// Deposits `value` ETH during deployment.
    function clone(uint256 value, address implementation, bytes memory args)
        internal
        returns (address instance)
    {
        /// @solidity memory-safe-assembly
        assembly {
            /**
             * ---------------------------------------------------------------------------+
             * CREATION (10 bytes)                                                        |
             * ---------------------------------------------------------------------------|
             * Opcode     | Mnemonic          | Stack     | Memory                        |
             * ---------------------------------------------------------------------------|
             * 61 runSize | PUSH2 runSize     | r         |                               |
             * 3d         | RETURNDATASIZE    | 0 r       |                               |
             * 81         | DUP2              | r 0 r     |                               |
             * 60 offset  | PUSH1 offset      | o r 0 r   |                               |
             * 3d         | RETURNDATASIZE    | 0 o r 0 r |                               |
             * 39         | CODECOPY          | 0 r       | [0..runSize): runtime code    |
             * f3         | RETURN            |           | [0..runSize): runtime code    |
             * ---------------------------------------------------------------------------|
             * RUNTIME (45 bytes + extraLength)                                           |
             * ---------------------------------------------------------------------------|
             * Opcode   | Mnemonic       | Stack                  | Memory                |
             * ---------------------------------------------------------------------------|
             *                                                                            |
             * ::: copy calldata to memory :::::::::::::::::::::::::::::::::::::::::::::: |
             * 36       | CALLDATASIZE   | cds                    |                       |
             * 3d       | RETURNDATASIZE | 0 cds                  |                       |
             * 3d       | RETURNDATASIZE | 0 0 cds                |                       |
             * 37       | CALLDATACOPY   |                        | [0..cds): calldata    |
             *                                                                            |
             * ::: delegate call to the implementation contract ::::::::::::::::::::::::: |
             * 3d       | RETURNDATASIZE | 0                      | [0..cds): calldata    |
             * 3d       | RETURNDATASIZE | 0 0                    | [0..cds): calldata    |
             * 3d       | RETURNDATASIZE | 0 0 0                  | [0..cds): calldata    |
             * 36       | CALLDATASIZE   | cds 0 0 0              | [0..cds): calldata    |
             * 3d       | RETURNDATASIZE | 0 cds 0 0 0 0          | [0..cds): calldata    |
             * 73 addr  | PUSH20 addr    | addr 0 cds 0 0 0 0     | [0..cds): calldata    |
             * 5a       | GAS            | gas addr 0 cds 0 0 0 0 | [0..cds): calldata    |
             * f4       | DELEGATECALL   | success 0 0            | [0..cds): calldata    |
             *                                                                            |
             * ::: copy return data to memory ::::::::::::::::::::::::::::::::::::::::::: |
             * 3d       | RETURNDATASIZE | rds success 0          | [0..cds): calldata    |
             * 82       | DUP3           | 0 rds success 0         | [0..cds): calldata   |
             * 80       | DUP1           | 0 0 rds success 0      | [0..cds): calldata    |
             * 3e       | RETURNDATACOPY | success 0              | [0..rds): returndata  |
             * 90       | SWAP1          | 0 success              | [0..rds): returndata  |
             * 3d       | RETURNDATASIZE | rds 0 success          | [0..rds): returndata  |
             * 91       | SWAP2          | success 0 rds          | [0..rds): returndata  |
             *                                                                            |
             * 60 0x2b  | PUSH1 0x2b     | 0x2b success 0 rds     | [0..rds): returndata  |
             * 57       | JUMPI          | 0 rds                  | [0..rds): returndata  |
             *                                                                            |
             * ::: revert ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: |
             * fd       | REVERT         |                        | [0..rds): returndata  |
             *                                                                            |
             * ::: return ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: |
             * 5b       | JUMPDEST       | 0 rds                  | [0..rds): returndata  |
             * f3       | RETURN         |                        | [0..rds): returndata  |
             * ---------------------------------------------------------------------------+
             */
            let m := mload(0x40)
            let n := mload(args)
            pop(staticcall(gas(), 4, add(args, 0x20), n, add(m, 0x43), n))
            mstore(add(m, 0x23), 0x5af43d82803e903d91602b57fd5bf3)
            mstore(add(m, 0x14), implementation)
            mstore(m, add(0xfe61002d3d81600a3d39f3363d3d373d3d3d363d73, shl(136, n)))
            // Do a out-of-gas revert if `n` is greater than `0xffff - 0x2d = 0xffd2`.
            instance := create(value, add(m, add(0x0b, lt(n, 0xffd3))), add(n, 0x37))
            if iszero(instance) {
                mstore(0x00, 0x30116425) // `DeploymentFailed()`.
                revert(0x1c, 0x04)
            }
        }
    }

    /// @dev Deploys a deterministic clone of `implementation`
    /// with immutable arguments encoded in `args` and `salt`.
    function cloneDeterministic(address implementation, bytes memory args, bytes32 salt)
        internal
        returns (address instance)
    {
        instance = cloneDeterministic(0, implementation, args, salt);
    }

    /// @dev Deploys a deterministic clone of `implementation`
    /// with immutable arguments encoded in `args` and `salt`.
    function cloneDeterministic(
        uint256 value,
        address implementation,
        bytes memory args,
        bytes32 salt
    ) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40)
            let n := mload(args)
            pop(staticcall(gas(), 4, add(args, 0x20), n, add(m, 0x43), n))
            mstore(add(m, 0x23), 0x5af43d82803e903d91602b57fd5bf3)
            mstore(add(m, 0x14), implementation)
            mstore(m, add(0xfe61002d3d81600a3d39f3363d3d373d3d3d363d73, shl(136, n)))
            // Do a out-of-gas revert if `n` is greater than `0xffff - 0x2d = 0xffd2`.
            instance := create2(value, add(m, add(0x0b, lt(n, 0xffd3))), add(n, 0x37), salt)
            if iszero(instance) {
                mstore(0x00, 0x30116425) // `DeploymentFailed()`.
                revert(0x1c, 0x04)
            }
        }
    }

    /// @dev Deploys a deterministic clone of `implementation`
    /// with immutable arguments encoded in `args` and `salt`.
    /// This method does not revert if the clone has already been deployed.
    function createDeterministicClone(address implementation, bytes memory args, bytes32 salt)
        internal
        returns (bool alreadyDeployed, address instance)
    {
        return createDeterministicClone(0, implementation, args, salt);
    }

    /// @dev Deploys a deterministic clone of `implementation`
    /// with immutable arguments encoded in `args` and `salt`.
    /// This method does not revert if the clone has already been deployed.
    function createDeterministicClone(
        uint256 value,
        address implementation,
        bytes memory args,
        bytes32 salt
    ) internal returns (bool alreadyDeployed, address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40)
            let n := mload(args)
            pop(staticcall(gas(), 4, add(args, 0x20), n, add(m, 0x43), n))
            mstore(add(m, 0x23), 0x5af43d82803e903d91602b57fd5bf3)
            mstore(add(m, 0x14), implementation)
            // Do a out-of-gas revert if `n` is greater than `0xffff - 0x2d = 0xffd2`.
            // forgefmt: disable-next-item
            mstore(add(m, gt(n, 0xffd2)), add(0xfe61002d3d81600a3d39f3363d3d373d3d3d363d73, shl(136, n)))
            // Compute and store the bytecode hash.
            mstore8(0x00, 0xff) // Write the prefix.
            mstore(0x35, keccak256(add(m, 0x0c), add(n, 0x37)))
            mstore(0x01, shl(96, address()))
            mstore(0x15, salt)
            instance := keccak256(0x00, 0x55)
            for {} 1 {} {
                if iszero(extcodesize(instance)) {
                    instance := create2(value, add(m, 0x0c), add(n, 0x37), salt)
                    if iszero(instance) {
                        mstore(0x00, 0x30116425) // `DeploymentFailed()`.
                        revert(0x1c, 0x04)
                    }
                    break
                }
                alreadyDeployed := 1
                if iszero(value) { break }
                if iszero(call(gas(), instance, value, codesize(), 0x00, codesize(), 0x00)) {
                    mstore(0x00, 0xb12d13eb) // `ETHTransferFailed()`.
                    revert(0x1c, 0x04)
                }
                break
            }
            mstore(0x35, 0) // Restore the overwritten part of the free memory pointer.
        }
    }

    /// @dev Returns the initialization code hash of the clone of `implementation`
    /// using immutable arguments encoded in `args`.
    function initCode(address implementation, bytes memory args)
        internal
        pure
        returns (bytes memory c)
    {
        /// @solidity memory-safe-assembly
        assembly {
            c := mload(0x40)
            let n := mload(args)
            // Do a out-of-gas revert if `n` is greater than `0xffff - 0x2d = 0xffd2`.
            returndatacopy(returndatasize(), returndatasize(), gt(n, 0xffd2))
            for { let i := 0 } lt(i, n) { i := add(i, 0x20) } {
                mstore(add(add(c, 0x57), i), mload(add(add(args, 0x20), i)))
            }
            mstore(add(c, 0x37), 0x5af43d82803e903d91602b57fd5bf3)
            mstore(add(c, 0x28), implementation)
            mstore(add(c, 0x14), add(0x61002d3d81600a3d39f3363d3d373d3d3d363d73, shl(136, n)))
            mstore(c, add(0x37, n)) // Store the length.
            mstore(add(c, add(n, 0x57)), 0) // Zeroize the slot after the bytes.
            mstore(0x40, add(c, add(n, 0x77))) // Allocate memory.
        }
    }

    /// @dev Returns the initialization code hash of the clone of `implementation`
    /// using immutable arguments encoded in `args`.
    function initCodeHash(address implementation, bytes memory args)
        internal
        pure
        returns (bytes32 hash)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40)
            let n := mload(args)
            // Do a out-of-gas revert if `n` is greater than `0xffff - 0x2d = 0xffd2`.
            returndatacopy(returndatasize(), returndatasize(), gt(n, 0xffd2))
            for { let i := 0 } lt(i, n) { i := add(i, 0x20) } {
                mstore(add(add(m, 0x43), i), mload(add(add(args, 0x20), i)))
            }
            mstore(add(m, 0x23), 0x5af43d82803e903d91602b57fd5bf3)
            mstore(add(m, 0x14), implementation)
            mstore(m, add(0x61002d3d81600a3d39f3363d3d373d3d3d363d73, shl(136, n)))
            hash := keccak256(add(m, 0x0c), add(n, 0x37))
        }
    }

    /// @dev Returns the address of the clone of
    /// `implementation` using immutable arguments encoded in `args`, with `salt`, by `deployer`.
    /// Note: The returned result has dirty upper 96 bits. Please clean if used in assembly.
    function predictDeterministicAddress(
        address implementation,
        bytes memory data,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        bytes32 hash = initCodeHash(implementation, data);
        predicted = predictDeterministicAddress(hash, salt, deployer);
    }

    /// @dev Equivalent to `argsOnClone(instance, 0, 2 ** 256 - 1)`.
    function argsOnClone(address instance) internal view returns (bytes memory args) {
        /// @solidity memory-safe-assembly
        assembly {
            args := mload(0x40)
            mstore(args, and(0xffffffffff, sub(extcodesize(instance), 0x2d))) // Store the length.
            extcodecopy(instance, add(args, 0x20), 0x2d, add(mload(args), 0x20))
            mstore(0x40, add(mload(args), add(args, 0x40))) // Allocate memory.
        }
    }

    /// @dev Equivalent to `argsOnClone(instance, start, 2 ** 256 - 1)`.
    function argsOnClone(address instance, uint256 start)
        internal
        view
        returns (bytes memory args)
    {
        /// @solidity memory-safe-assembly
        assembly {
            args := mload(0x40)
            let n := and(0xffffffffff, sub(extcodesize(instance), 0x2d))
            extcodecopy(instance, add(args, 0x20), add(start, 0x2d), add(n, 0x20))
            mstore(args, mul(sub(n, start), lt(start, n))) // Store the length.
            mstore(0x40, add(args, add(0x40, mload(args)))) // Allocate memory.
        }
    }

    /// @dev Returns a slice of the immutable arguments on `instance` from `start` to `end`.
    /// `start` and `end` will be clamped to the range `[0, args.length]`.
    /// The `instance` MUST be deployed via the clone with immutable args functions.
    /// Otherwise, the behavior is undefined.
    /// Out-of-gas reverts if `instance` does not have any code.
    function argsOnClone(address instance, uint256 start, uint256 end)
        internal
        view
        returns (bytes memory args)
    {
        /// @solidity memory-safe-assembly
        assembly {
            args := mload(0x40)
            if iszero(lt(end, 0xffff)) { end := 0xffff }
            let d := mul(sub(end, start), lt(start, end))
            extcodecopy(instance, args, add(start, 0x0d), add(d, 0x20))
            if iszero(and(0xff, mload(add(args, d)))) {
                let n := sub(extcodesize(instance), 0x2d)
                returndatacopy(returndatasize(), returndatasize(), shr(40, n))
                d := mul(gt(n, start), sub(d, mul(gt(end, n), sub(end, n))))
            }
            mstore(args, d) // Store the length.
            mstore(add(add(args, 0x20), d), 0) // Zeroize the slot after the bytes.
            mstore(0x40, add(add(args, 0x40), d)) // Allocate memory.
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*              MINIMAL ERC1967 PROXY OPERATIONS              */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // Note: The ERC1967 proxy here is intended to be upgraded with UUPS.
    // This is NOT the same as ERC1967Factory's transparent proxy, which includes admin logic.

    /// @dev Deploys a minimal ERC1967 proxy with `implementation`.
    function deployERC1967(address implementation) internal returns (address instance) {
        instance = deployERC1967(0, implementation);
    }

    /// @dev Deploys a minimal ERC1967 proxy with `implementation`.
    /// Deposits `value` ETH during deployment.
    function deployERC1967(uint256 value, address implementation)
        internal
        returns (address instance)
    {
        /// @solidity memory-safe-assembly
        assembly {
            /**
             * ---------------------------------------------------------------------------------+
             * CREATION (34 bytes)                                                              |
             * ---------------------------------------------------------------------------------|
             * Opcode     | Mnemonic       | Stack            | Memory                          |
             * ---------------------------------------------------------------------------------|
             * 60 runSize | PUSH1 runSize  | r                |                                 |
             * 3d         | RETURNDATASIZE | 0 r              |                                 |
             * 81         | DUP2           | r 0 r            |                                 |
             * 60 offset  | PUSH1 offset   | o r 0 r          |                                 |
             * 3d         | RETURNDATASIZE | 0 o r 0 r        |                                 |
             * 39         | CODECOPY       | 0 r              | [0..runSize): runtime code      |
             * 73 impl    | PUSH20 impl    | impl 0 r         | [0..runSize): runtime code      |
             * 60 slotPos | PUSH1 slotPos  | slotPos impl 0 r | [0..runSize): runtime code      |
             * 51         | MLOAD          | slot impl 0 r    | [0..runSize): runtime code      |
             * 55         | SSTORE         | 0 r              | [0..runSize): runtime code      |
             * f3         | RETURN         |                  | [0..runSize): runtime code      |
             * ---------------------------------------------------------------------------------|
             * RUNTIME (61 bytes)                                                               |
             * ---------------------------------------------------------------------------------|
             * Opcode     | Mnemonic       | Stack            | Memory                          |
             * ---------------------------------------------------------------------------------|
             *                                                                                  |
             * ::: copy calldata to memory :::::::::::::::::::::::::::::::::::::::::::::::::::: |
             * 36         | CALLDATASIZE   | cds              |                                 |
             * 3d         | RETURNDATASIZE | 0 cds            |                                 |
             * 3d         | RETURNDATASIZE | 0 0 cds          |                                 |
             * 37         | CALLDATACOPY   |                  | [0..calldatasize): calldata     |
             *                                                                                  |
             * ::: delegatecall to implementation ::::::::::::::::::::::::::::::::::::::::::::: |
             * 3d         | RETURNDATASIZE | 0                |                                 |
             * 3d         | RETURNDATASIZE | 0 0              |                                 |
             * 36         | CALLDATASIZE   | cds 0 0          | [0..calldatasize): calldata     |
             * 3d         | RETURNDATASIZE | 0 cds 0 0        | [0..calldatasize): calldata     |
             * 7f slot    | PUSH32 slot    | s 0 cds 0 0      | [0..calldatasize): calldata     |
             * 54         | SLOAD          | i 0 cds 0 0      | [0..calldatasize): calldata     |
             * 5a         | GAS            | g i 0 cds 0 0    | [0..calldatasize): calldata     |
             * f4         | DELEGATECALL   | succ             | [0..calldatasize): calldata     |
             *                                                                                  |
             * ::: copy returndata to memory :::::::::::::::::::::::::::::::::::::::::::::::::: |
             * 3d         | RETURNDATASIZE | rds succ         | [0..calldatasize): calldata     |
             * 60 0x00    | PUSH1 0x00     | 0 rds succ       | [0..calldatasize): calldata     |
             * 80         | DUP1           | 0 0 rds succ     | [0..calldatasize): calldata     |
             * 3e         | RETURNDATACOPY | succ             | [0..returndatasize): returndata |
             *                                                                                  |
             * ::: branch on delegatecall status :::::::::::::::::::::::::::::::::::::::::::::: |
             * 60 0x38    | PUSH1 0x38     | dest succ        | [0..returndatasize): returndata |
             * 57         | JUMPI          |                  | [0..returndatasize): returndata |
             *                                                                                  |
             * ::: delegatecall failed, revert :::::::::::::::::::::::::::::::::::::::::::::::: |
             * 3d         | RETURNDATASIZE | rds              | [0..returndatasize): returndata |
             * 60 0x00    | PUSH1 0x00     | 0 rds            | [0..returndatasize): returndata |
             * fd         | REVERT         |                  | [0..returndatasize): returndata |
             *                                                                                  |
             * ::: delegatecall succeeded, return ::::::::::::::::::::::::::::::::::::::::::::: |
             * 5b         | JUMPDEST       |                  | [0..returndatasize): returndata |
             * 3d         | RETURNDATASIZE | rds              | [0..returndatasize): returndata |
             * 60 0x00    | PUSH1 0x00     | 0 rds            | [0..returndatasize): returndata |
             * f3         | RETURN         |                  | [0..returndatasize): returndata |
             * ---------------------------------------------------------------------------------+
             */
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x60, 0xcc3735a920a3ca505d382bbc545af43d6000803e6038573d6000fd5b3d6000f3)
            mstore(0x40, 0x5155f3363d3d373d3d363d7f360894a13ba1a3210667c828492db98dca3e2076)
            mstore(0x20, 0x6009)
            mstore(0x1e, implementation)
            mstore(0x0a, 0x603d3d8160223d3973)
            instance := create(value, 0x21, 0x5f)
            if iszero(instance) {
                mstore(0x00, 0x30116425) // `DeploymentFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x40, m) // Restore the free memory pointer.
            mstore(0x60, 0) // Restore the zero slot.
        }
    }

    /// @dev Deploys a deterministic minimal ERC1967 proxy with `implementation` and `salt`.
    function deployDeterministicERC1967(address implementation, bytes32 salt)
        internal
        returns (address instance)
    {
        instance = deployDeterministicERC1967(0, implementation, salt);
    }

    /// @dev Deploys a deterministic minimal ERC1967 proxy with `implementation` and `salt`.
    /// Deposits `value` ETH during deployment.
    function deployDeterministicERC1967(uint256 value, address implementation, bytes32 salt)
        internal
        returns (address instance)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x60, 0xcc3735a920a3ca505d382bbc545af43d6000803e6038573d6000fd5b3d6000f3)
            mstore(0x40, 0x5155f3363d3d373d3d363d7f360894a13ba1a3210667c828492db98dca3e2076)
            mstore(0x20, 0x6009)
            mstore(0x1e, implementation)
            mstore(0x0a, 0x603d3d8160223d3973)
            instance := create2(value, 0x21, 0x5f, salt)
            if iszero(instance) {
                mstore(0x00, 0x30116425) // `DeploymentFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x40, m) // Restore the free memory pointer.
            mstore(0x60, 0) // Restore the zero slot.
        }
    }

    /// @dev Creates a deterministic minimal ERC1967 proxy with `implementation` and `salt`.
    /// Note: This method is intended for use in ERC4337 factories,
    /// which are expected to NOT revert if the proxy is already deployed.
    function createDeterministicERC1967(address implementation, bytes32 salt)
        internal
        returns (bool alreadyDeployed, address instance)
    {
        return createDeterministicERC1967(0, implementation, salt);
    }

    /// @dev Creates a deterministic minimal ERC1967 proxy with `implementation` and `salt`.
    /// Deposits `value` ETH during deployment.
    /// Note: This method is intended for use in ERC4337 factories,
    /// which are expected to NOT revert if the proxy is already deployed.
    function createDeterministicERC1967(uint256 value, address implementation, bytes32 salt)
        internal
        returns (bool alreadyDeployed, address instance)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x60, 0xcc3735a920a3ca505d382bbc545af43d6000803e6038573d6000fd5b3d6000f3)
            mstore(0x40, 0x5155f3363d3d373d3d363d7f360894a13ba1a3210667c828492db98dca3e2076)
            mstore(0x20, 0x6009)
            mstore(0x1e, implementation)
            mstore(0x0a, 0x603d3d8160223d3973)
            // Compute and store the bytecode hash.
            mstore(add(m, 0x35), keccak256(0x21, 0x5f))
            mstore(m, shl(88, address()))
            mstore8(m, 0xff) // Write the prefix.
            mstore(add(m, 0x15), salt)
            instance := keccak256(m, 0x55)
            for {} 1 {} {
                if iszero(extcodesize(instance)) {
                    instance := create2(value, 0x21, 0x5f, salt)
                    if iszero(instance) {
                        mstore(0x00, 0x30116425) // `DeploymentFailed()`.
                        revert(0x1c, 0x04)
                    }
                    break
                }
                alreadyDeployed := 1
                if iszero(value) { break }
                if iszero(call(gas(), instance, value, codesize(), 0x00, codesize(), 0x00)) {
                    mstore(0x00, 0xb12d13eb) // `ETHTransferFailed()`.
                    revert(0x1c, 0x04)
                }
                break
            }
            mstore(0x40, m) // Restore the free memory pointer.
            mstore(0x60, 0) // Restore the zero slot.
        }
    }

    /// @dev Returns the initialization code of the minimal ERC1967 proxy of `implementation`.
    function initCodeERC1967(address implementation) internal pure returns (bytes memory c) {
        /// @solidity memory-safe-assembly
        assembly {
            c := mload(0x40)
            mstore(add(c, 0x60), 0x3735a920a3ca505d382bbc545af43d6000803e6038573d6000fd5b3d6000f300)
            mstore(add(c, 0x40), 0x55f3363d3d373d3d363d7f360894a13ba1a3210667c828492db98dca3e2076cc)
            mstore(add(c, 0x20), or(shl(24, implementation), 0x600951))
            mstore(add(c, 0x09), 0x603d3d8160223d3973)
            mstore(c, 0x5f) // Store the length.
            mstore(0x40, add(c, 0x80)) // Allocate memory.
        }
    }

    /// @dev Returns the initialization code hash of the minimal ERC1967 proxy of `implementation`.
    function initCodeHashERC1967(address implementation) internal pure returns (bytes32 hash) {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x60, 0xcc3735a920a3ca505d382bbc545af43d6000803e6038573d6000fd5b3d6000f3)
            mstore(0x40, 0x5155f3363d3d373d3d363d7f360894a13ba1a3210667c828492db98dca3e2076)
            mstore(0x20, 0x6009)
            mstore(0x1e, implementation)
            mstore(0x0a, 0x603d3d8160223d3973)
            hash := keccak256(0x21, 0x5f)
            mstore(0x40, m) // Restore the free memory pointer.
            mstore(0x60, 0) // Restore the zero slot.
        }
    }

    /// @dev Returns the address of the ERC1967 proxy of `implementation`, with `salt` by `deployer`.
    /// Note: The returned result has dirty upper 96 bits. Please clean if used in assembly.
    function predictDeterministicAddressERC1967(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        bytes32 hash = initCodeHashERC1967(implementation);
        predicted = predictDeterministicAddress(hash, salt, deployer);
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*    MINIMAL ERC1967 PROXY WITH IMMUTABLE ARGS OPERATIONS    */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Deploys a minimal ERC1967 proxy with `implementation` and `args`.
    function deployERC1967(address implementation, bytes memory args)
        internal
        returns (address instance)
    {
        instance = deployERC1967(0, implementation, args);
    }

    /// @dev Deploys a minimal ERC1967 proxy with `implementation` and `args`.
    /// Deposits `value` ETH during deployment.
    function deployERC1967(uint256 value, address implementation, bytes memory args)
        internal
        returns (address instance)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40)
            let n := mload(args)
            pop(staticcall(gas(), 4, add(args, 0x20), n, add(m, 0x60), n))
            mstore(add(m, 0x40), 0xcc3735a920a3ca505d382bbc545af43d6000803e6038573d6000fd5b3d6000f3)
            mstore(add(m, 0x20), 0x5155f3363d3d373d3d363d7f360894a13ba1a3210667c828492db98dca3e2076)
            mstore(0x16, 0x6009)
            mstore(0x14, implementation)
            // Do a out-of-gas revert if `n` is greater than `0xffff - 0x3d = 0xffc2`.
            mstore(gt(n, 0xffc2), add(0xfe61003d3d8160233d3973, shl(56, n)))
            mstore(m, mload(0x16))
            instance := create(value, m, add(n, 0x60))
            if iszero(instance) {
                mstore(0x00, 0x30116425) // `DeploymentFailed()`.
                revert(0x1c, 0x04)
            }
        }
    }

    /// @dev Deploys a deterministic minimal ERC1967 proxy with `implementation`, `args` and `salt`.
    function deployDeterministicERC1967(address implementation, bytes memory args, bytes32 salt)
        internal
        returns (address instance)
    {
        instance = deployDeterministicERC1967(0, implementation, args, salt);
    }

    /// @dev Deploys a deterministic minimal ERC1967 proxy with `implementation`, `args` and `salt`.
    /// Deposits `value` ETH during deployment.
    function deployDeterministicERC1967(
        uint256 value,
        address implementation,
        bytes memory args,
        bytes32 salt
    ) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40)
            let n := mload(args)
            pop(staticcall(gas(), 4, add(args, 0x20), n, add(m, 0x60), n))
            mstore(add(m, 0x40), 0xcc3735a920a3ca505d382bbc545af43d6000803e6038573d6000fd5b3d6000f3)
            mstore(add(m, 0x20), 0x5155f3363d3d373d3d363d7f360894a13ba1a3210667c828492db98dca3e2076)
            mstore(0x16, 0x6009)
            mstore(0x14, implementation)
            // Do a out-of-gas revert if `n` is greater than `0xffff - 0x3d = 0xffc2`.
            mstore(gt(n, 0xffc2), add(0xfe61003d3d8160233d3973, shl(56, n)))
            mstore(m, mload(0x16))
            instance := create2(value, m, add(n, 0x60), salt)
            if iszero(instance) {
                mstore(0x00, 0x30116425) // `DeploymentFailed()`.
                revert(0x1c, 0x04)
            }
        }
    }

    /// @dev Creates a deterministic minimal ERC1967 proxy with `implementation`, `args` and `salt`.
    /// Note: This method is intended for use in ERC4337 factories,
    /// which are expected to NOT revert if the proxy is already deployed.
    function createDeterministicERC1967(address implementation, bytes memory args, bytes32 salt)
        internal
        returns (bool alreadyDeployed, address instance)
    {
        return createDeterministicERC1967(0, implementation, args, salt);
    }

    /// @dev Creates a deterministic minimal ERC1967 proxy with `implementation`, `args` and `salt`.
    /// Deposits `value` ETH during deployment.
    /// Note: This method is intended for use in ERC4337 factories,
    /// which are expected to NOT revert if the proxy is already deployed.
    function createDeterministicERC1967(
        uint256 value,
        address implementation,
        bytes memory args,
        bytes32 salt
    ) internal returns (bool alreadyDeployed, address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40)
            let n := mload(args)
            pop(staticcall(gas(), 4, add(args, 0x20), n, add(m, 0x60), n))
            mstore(add(m, 0x40), 0xcc3735a920a3ca505d382bbc545af43d6000803e6038573d6000fd5b3d6000f3)
            mstore(add(m, 0x20), 0x5155f3363d3d373d3d363d7f360894a13ba1a3210667c828492db98dca3e2076)
            mstore(0x16, 0x6009)
            mstore(0x14, implementation)
            // Do a out-of-gas revert if `n` is greater than `0xffff - 0x3d = 0xffc2`.
            mstore(gt(n, 0xffc2), add(0xfe61003d3d8160233d3973, shl(56, n)))
            mstore(m, mload(0x16))
            // Compute and store the bytecode hash.
            mstore8(0x00, 0xff) // Write the prefix.
            mstore(0x35, keccak256(m, add(n, 0x60)))
            mstore(0x01, shl(96, address()))
            mstore(0x15, salt)
            instance := keccak256(0x00, 0x55)
            for {} 1 {} {
                if iszero(extcodesize(instance)) {
                    instance := create2(value, m, add(n, 0x60), salt)
                    if iszero(instance) {
                        mstore(0x00, 0x30116425) // `DeploymentFailed()`.
                        revert(0x1c, 0x04)
                    }
                    break
                }
                alreadyDeployed := 1
                if iszero(value) { break }
                if iszero(call(gas(), instance, value, codesize(), 0x00, codesize(), 0x00)) {
                    mstore(0x00, 0xb12d13eb) // `ETHTransferFailed()`.
                    revert(0x1c, 0x04)
                }
                break
            }
            mstore(0x35, 0) // Restore the overwritten part of the free memory pointer.
        }
    }

    /// @dev Returns the initialization code of the minimal ERC1967 proxy of `implementation` and `args`.
    function initCodeERC1967(address implementation, bytes memory args)
        internal
        pure
        returns (bytes memory c)
    {
        /// @solidity memory-safe-assembly
        assembly {
            c := mload(0x40)
            let n := mload(args)
            // Do a out-of-gas revert if `n` is greater than `0xffff - 0x3d = 0xffc2`.
            returndatacopy(returndatasize(), returndatasize(), gt(n, 0xffc2))
            for { let i := 0 } lt(i, n) { i := add(i, 0x20) } {
                mstore(add(add(c, 0x80), i), mload(add(add(args, 0x20), i)))
            }
            mstore(add(c, 0x60), 0xcc3735a920a3ca505d382bbc545af43d6000803e6038573d6000fd5b3d6000f3)
            mstore(add(c, 0x40), 0x5155f3363d3d373d3d363d7f360894a13ba1a3210667c828492db98dca3e2076)
            mstore(add(c, 0x20), 0x6009)
            mstore(add(c, 0x1e), implementation)
            mstore(add(c, 0x0a), add(0x61003d3d8160233d3973, shl(56, n)))
            mstore(c, add(n, 0x60)) // Store the length.
            mstore(add(c, add(n, 0x80)), 0) // Zeroize the slot after the bytes.
            mstore(0x40, add(c, add(n, 0xa0))) // Allocate memory.
        }
    }

    /// @dev Returns the initialization code hash of the minimal ERC1967 proxy of `implementation` and `args`.
    function initCodeHashERC1967(address implementation, bytes memory args)
        internal
        pure
        returns (bytes32 hash)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40)
            let n := mload(args)
            // Do a out-of-gas revert if `n` is greater than `0xffff - 0x3d = 0xffc2`.
            returndatacopy(returndatasize(), returndatasize(), gt(n, 0xffc2))
            for { let i := 0 } lt(i, n) { i := add(i, 0x20) } {
                mstore(add(add(m, 0x60), i), mload(add(add(args, 0x20), i)))
            }
            mstore(add(m, 0x40), 0xcc3735a920a3ca505d382bbc545af43d6000803e6038573d6000fd5b3d6000f3)
            mstore(add(m, 0x20), 0x5155f3363d3d373d3d363d7f360894a13ba1a3210667c828492db98dca3e2076)
            mstore(0x16, 0x6009)
            mstore(0x14, implementation)
            mstore(0x00, add(0x61003d3d8160233d3973, shl(56, n)))
            mstore(m, mload(0x16))
            hash := keccak256(m, add(n, 0x60))
        }
    }

    /// @dev Returns the address of the ERC1967 proxy of `implementation`, `args`, with `salt` by `deployer`.
    /// Note: The returned result has dirty upper 96 bits. Please clean if used in assembly.
    function predictDeterministicAddressERC1967(
        address implementation,
        bytes memory args,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        bytes32 hash = initCodeHashERC1967(implementation, args);
        predicted = predictDeterministicAddress(hash, salt, deployer);
    }

    /// @dev Equivalent to `argsOnERC1967(instance, start, 2 ** 256 - 1)`.
    function argsOnERC1967(address instance) internal view returns (bytes memory args) {
        /// @solidity memory-safe-assembly
        assembly {
            args := mload(0x40)
            mstore(args, and(0xffffffffff, sub(extcodesize(instance), 0x3d))) // Store the length.
            extcodecopy(instance, add(args, 0x20), 0x3d, add(mload(args), 0x20))
            mstore(0x40, add(mload(args), add(args, 0x40))) // Allocate memory.
        }
    }

    /// @dev Equivalent to `argsOnERC1967(instance, start, 2 ** 256 - 1)`.
    function argsOnERC1967(address instance, uint256 start)
        internal
        view
        returns (bytes memory args)
    {
        /// @solidity memory-safe-assembly
        assembly {
            args := mload(0x40)
            let n := and(0xffffffffff, sub(extcodesize(instance), 0x3d))
            extcodecopy(instance, add(args, 0x20), add(start, 0x3d), add(n, 0x20))
            mstore(args, mul(sub(n, start), lt(start, n))) // Store the length.
            mstore(0x40, add(args, add(0x40, mload(args)))) // Allocate memory.
        }
    }

    /// @dev Returns a slice of the immutable arguments on `instance` from `start` to `end`.
    /// `start` and `end` will be clamped to the range `[0, args.length]`.
    /// The `instance` MUST be deployed via the ERC1967 with immutable args functions.
    /// Otherwise, the behavior is undefined.
    /// Out-of-gas reverts if `instance` does not have any code.
    function argsOnERC1967(address instance, uint256 start, uint256 end)
        internal
        view
        returns (bytes memory args)
    {
        /// @solidity memory-safe-assembly
        assembly {
            args := mload(0x40)
            if iszero(lt(end, 0xffff)) { end := 0xffff }
            let d := mul(sub(end, start), lt(start, end))
            extcodecopy(instance, args, add(start, 0x1d), add(d, 0x20))
            if iszero(and(0xff, mload(add(args, d)))) {
                let n := sub(extcodesize(instance), 0x3d)
                returndatacopy(returndatasize(), returndatasize(), shr(40, n))
                d := mul(gt(n, start), sub(d, mul(gt(end, n), sub(end, n))))
            }
            mstore(args, d) // Store the length.
            mstore(add(add(args, 0x20), d), 0) // Zeroize the slot after the bytes.
            mstore(0x40, add(add(args, 0x40), d)) // Allocate memory.
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                 ERC1967I PROXY OPERATIONS                  */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // Note: This proxy has a special code path that activates if `calldatasize() == 1`.
    // This code path skips the delegatecall and directly returns the `implementation` address.
    // The returned implementation is guaranteed to be valid if the keccak256 of the
    // proxy's code is equal to `ERC1967I_CODE_HASH`.

    /// @dev Deploys a ERC1967I proxy with `implementation`.
    function deployERC1967I(address implementation) internal returns (address instance) {
        instance = deployERC1967I(0, implementation);
    }

    /// @dev Deploys a ERC1967I proxy with `implementation`.
    /// Deposits `value` ETH during deployment.
    function deployERC1967I(uint256 value, address implementation)
        internal
        returns (address instance)
    {
        /// @solidity memory-safe-assembly
        assembly {
            /**
             * ---------------------------------------------------------------------------------+
             * CREATION (34 bytes)                                                              |
             * ---------------------------------------------------------------------------------|
             * Opcode     | Mnemonic       | Stack            | Memory                          |
             * ---------------------------------------------------------------------------------|
             * 60 runSize | PUSH1 runSize  | r                |                                 |
             * 3d         | RETURNDATASIZE | 0 r              |                                 |
             * 81         | DUP2           | r 0 r            |                                 |
             * 60 offset  | PUSH1 offset   | o r 0 r          |                                 |
             * 3d         | RETURNDATASIZE | 0 o r 0 r        |                                 |
             * 39         | CODECOPY       | 0 r              | [0..runSize): runtime code      |
             * 73 impl    | PUSH20 impl    | impl 0 r         | [0..runSize): runtime code      |
             * 60 slotPos | PUSH1 slotPos  | slotPos impl 0 r | [0..runSize): runtime code      |
             * 51         | MLOAD          | slot impl 0 r    | [0..runSize): runtime code      |
             * 55         | SSTORE         | 0 r              | [0..runSize): runtime code      |
             * f3         | RETURN         |                  | [0..runSize): runtime code      |
             * ---------------------------------------------------------------------------------|
             * RUNTIME (82 bytes)                                                               |
             * ---------------------------------------------------------------------------------|
             * Opcode     | Mnemonic       | Stack            | Memory                          |
             * ---------------------------------------------------------------------------------|
             *                                                                                  |
             * ::: check calldatasize ::::::::::::::::::::::::::::::::::::::::::::::::::::::::: |
             * 36         | CALLDATASIZE   | cds              |                                 |
             * 58         | PC             | 1 cds            |                                 |
             * 14         | EQ             | eqs              |                                 |
             * 60 0x43    | PUSH1 0x43     | dest eqs         |                                 |
             * 57         | JUMPI          |                  |                                 |
             *                                                                                  |
             * ::: copy calldata to memory :::::::::::::::::::::::::::::::::::::::::::::::::::: |
             * 36         | CALLDATASIZE   | cds              |                                 |
             * 3d         | RETURNDATASIZE | 0 cds            |                                 |
             * 3d         | RETURNDATASIZE | 0 0 cds          |                                 |
             * 37         | CALLDATACOPY   |                  | [0..calldatasize): calldata     |
             *                                                                                  |
             * ::: delegatecall to implementation ::::::::::::::::::::::::::::::::::::::::::::: |
             * 3d         | RETURNDATASIZE | 0                |                                 |
             * 3d         | RETURNDATASIZE | 0 0              |                                 |
             * 36         | CALLDATASIZE   | cds 0 0          | [0..calldatasize): calldata     |
             * 3d         | RETURNDATASIZE | 0 cds 0 0        | [0..calldatasize): calldata     |
             * 7f slot    | PUSH32 slot    | s 0 cds 0 0      | [0..calldatasize): calldata     |
             * 54         | SLOAD          | i 0 cds 0 0      | [0..calldatasize): calldata     |
             * 5a         | GAS            | g i 0 cds 0 0    | [0..calldatasize): calldata     |
             * f4         | DELEGATECALL   | succ             | [0..calldatasize): calldata     |
             *                                                                                  |
             * ::: copy returndata to memory :::::::::::::::::::::::::::::::::::::::::::::::::: |
             * 3d         | RETURNDATASIZE | rds succ         | [0..calldatasize): calldata     |
             * 60 0x00    | PUSH1 0x00     | 0 rds succ       | [0..calldatasize): calldata     |
             * 80         | DUP1           | 0 0 rds succ     | [0..calldatasize): calldata     |
             * 3e         | RETURNDATACOPY | succ             | [0..returndatasize): returndata |
             *                                                                                  |
             * ::: branch on delegatecall status :::::::::::::::::::::::::::::::::::::::::::::: |
             * 60 0x3E    | PUSH1 0x3E     | dest succ        | [0..returndatasize): returndata |
             * 57         | JUMPI          |                  | [0..returndatasize): returndata |
             *                                                                                  |
             * ::: delegatecall failed, revert :::::::::::::::::::::::::::::::::::::::::::::::: |
             * 3d         | RETURNDATASIZE | rds              | [0..returndatasize): returndata |
             * 60 0x00    | PUSH1 0x00     | 0 rds            | [0..returndatasize): returndata |
             * fd         | REVERT         |                  | [0..returndatasize): returndata |
             *                                                                                  |
             * ::: delegatecall succeeded, return ::::::::::::::::::::::::::::::::::::::::::::: |
             * 5b         | JUMPDEST       |                  | [0..returndatasize): returndata |
             * 3d         | RETURNDATASIZE | rds              | [0..returndatasize): returndata |
             * 60 0x00    | PUSH1 0x00     | 0 rds            | [0..returndatasize): returndata |
             * f3         | RETURN         |                  | [0..returndatasize): returndata |
             *                                                                                  |
             * ::: implementation , return :::::::::::::::::::::::::::::::::::::::::::::::::::: |
             * 5b         | JUMPDEST       |                  |                                 |
             * 60 0x20    | PUSH1 0x20     | 32               |                                 |
             * 60 0x0F    | PUSH1 0x0F     | o 32             |                                 |
             * 3d         | RETURNDATASIZE | 0 o 32           |                                 |
             * 39         | CODECOPY       |                  | [0..32): implementation slot    |
             * 3d         | RETURNDATASIZE | 0                | [0..32): implementation slot    |
             * 51         | MLOAD          | slot             | [0..32): implementation slot    |
             * 54         | SLOAD          | impl             | [0..32): implementation slot    |
             * 3d         | RETURNDATASIZE | 0 impl           | [0..32): implementation slot    |
             * 52         | MSTORE         |                  | [0..32): implementation address |
             * 59         | MSIZE          | 32               | [0..32): implementation address |
             * 3d         | RETURNDATASIZE | 0 32             | [0..32): implementation address |
             * f3         | RETURN         |                  | [0..32): implementation address |
             * ---------------------------------------------------------------------------------+
             */
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x60, 0x3d6000803e603e573d6000fd5b3d6000f35b6020600f3d393d51543d52593df3)
            mstore(0x40, 0xa13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc545af4)
            mstore(0x20, 0x600f5155f3365814604357363d3d373d3d363d7f360894)
            mstore(0x09, or(shl(160, 0x60523d8160223d3973), shr(96, shl(96, implementation))))
            instance := create(value, 0x0c, 0x74)
            if iszero(instance) {
                mstore(0x00, 0x30116425) // `DeploymentFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x40, m) // Restore the free memory pointer.
            mstore(0x60, 0) // Restore the zero slot.
        }
    }

    /// @dev Deploys a deterministic ERC1967I proxy with `implementation` and `salt`.
    function deployDeterministicERC1967I(address implementation, bytes32 salt)
        internal
        returns (address instance)
    {
        instance = deployDeterministicERC1967I(0, implementation, salt);
    }

    /// @dev Deploys a deterministic ERC1967I proxy with `implementation` and `salt`.
    /// Deposits `value` ETH during deployment.
    function deployDeterministicERC1967I(uint256 value, address implementation, bytes32 salt)
        internal
        returns (address instance)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x60, 0x3d6000803e603e573d6000fd5b3d6000f35b6020600f3d393d51543d52593df3)
            mstore(0x40, 0xa13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc545af4)
            mstore(0x20, 0x600f5155f3365814604357363d3d373d3d363d7f360894)
            mstore(0x09, or(shl(160, 0x60523d8160223d3973), shr(96, shl(96, implementation))))
            instance := create2(value, 0x0c, 0x74, salt)
            if iszero(instance) {
                mstore(0x00, 0x30116425) // `DeploymentFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x40, m) // Restore the free memory pointer.
            mstore(0x60, 0) // Restore the zero slot.
        }
    }

    /// @dev Creates a deterministic ERC1967I proxy with `implementation` and `salt`.
    /// Note: This method is intended for use in ERC4337 factories,
    /// which are expected to NOT revert if the proxy is already deployed.
    function createDeterministicERC1967I(address implementation, bytes32 salt)
        internal
        returns (bool alreadyDeployed, address instance)
    {
        return createDeterministicERC1967I(0, implementation, salt);
    }

    /// @dev Creates a deterministic ERC1967I proxy with `implementation` and `salt`.
    /// Deposits `value` ETH during deployment.
    /// Note: This method is intended for use in ERC4337 factories,
    /// which are expected to NOT revert if the proxy is already deployed.
    function createDeterministicERC1967I(uint256 value, address implementation, bytes32 salt)
        internal
        returns (bool alreadyDeployed, address instance)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x60, 0x3d6000803e603e573d6000fd5b3d6000f35b6020600f3d393d51543d52593df3)
            mstore(0x40, 0xa13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc545af4)
            mstore(0x20, 0x600f5155f3365814604357363d3d373d3d363d7f360894)
            mstore(0x09, or(shl(160, 0x60523d8160223d3973), shr(96, shl(96, implementation))))
            // Compute and store the bytecode hash.
            mstore(add(m, 0x35), keccak256(0x0c, 0x74))
            mstore(m, shl(88, address()))
            mstore8(m, 0xff) // Write the prefix.
            mstore(add(m, 0x15), salt)
            instance := keccak256(m, 0x55)
            for {} 1 {} {
                if iszero(extcodesize(instance)) {
                    instance := create2(value, 0x0c, 0x74, salt)
                    if iszero(instance) {
                        mstore(0x00, 0x30116425) // `DeploymentFailed()`.
                        revert(0x1c, 0x04)
                    }
                    break
                }
                alreadyDeployed := 1
                if iszero(value) { break }
                if iszero(call(gas(), instance, value, codesize(), 0x00, codesize(), 0x00)) {
                    mstore(0x00, 0xb12d13eb) // `ETHTransferFailed()`.
                    revert(0x1c, 0x04)
                }
                break
            }
            mstore(0x40, m) // Restore the free memory pointer.
            mstore(0x60, 0) // Restore the zero slot.
        }
    }

    /// @dev Returns the initialization code of the ERC1967I proxy of `implementation`.
    function initCodeERC1967I(address implementation) internal pure returns (bytes memory c) {
        /// @solidity memory-safe-assembly
        assembly {
            c := mload(0x40)
            mstore(add(c, 0x74), 0x3d6000803e603e573d6000fd5b3d6000f35b6020600f3d393d51543d52593df3)
            mstore(add(c, 0x54), 0xa13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc545af4)
            mstore(add(c, 0x34), 0x600f5155f3365814604357363d3d373d3d363d7f360894)
            mstore(add(c, 0x1d), implementation)
            mstore(add(c, 0x09), 0x60523d8160223d3973)
            mstore(add(c, 0x94), 0)
            mstore(c, 0x74) // Store the length.
            mstore(0x40, add(c, 0xa0)) // Allocate memory.
        }
    }

    /// @dev Returns the initialization code hash of the ERC1967I proxy of `implementation`.
    function initCodeHashERC1967I(address implementation) internal pure returns (bytes32 hash) {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x60, 0x3d6000803e603e573d6000fd5b3d6000f35b6020600f3d393d51543d52593df3)
            mstore(0x40, 0xa13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc545af4)
            mstore(0x20, 0x600f5155f3365814604357363d3d373d3d363d7f360894)
            mstore(0x09, or(shl(160, 0x60523d8160223d3973), shr(96, shl(96, implementation))))
            hash := keccak256(0x0c, 0x74)
            mstore(0x40, m) // Restore the free memory pointer.
            mstore(0x60, 0) // Restore the zero slot.
        }
    }

    /// @dev Returns the address of the ERC1967I proxy of `implementation`, with `salt` by `deployer`.
    /// Note: The returned result has dirty upper 96 bits. Please clean if used in assembly.
    function predictDeterministicAddressERC1967I(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        bytes32 hash = initCodeHashERC1967I(implementation);
        predicted = predictDeterministicAddress(hash, salt, deployer);
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*       ERC1967I PROXY WITH IMMUTABLE ARGS OPERATIONS        */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Deploys a minimal ERC1967I proxy with `implementation` and `args`.
    function deployERC1967I(address implementation, bytes memory args) internal returns (address) {
        return deployERC1967I(0, implementation, args);
    }

    /// @dev Deploys a minimal ERC1967I proxy with `implementation` and `args`.
    /// Deposits `value` ETH during deployment.
    function deployERC1967I(uint256 value, address implementation, bytes memory args)
        internal
        returns (address instance)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40)
            let n := mload(args)
            pop(staticcall(gas(), 4, add(args, 0x20), n, add(m, 0x8b), n))

            mstore(add(m, 0x6b), 0x3d6000803e603e573d6000fd5b3d6000f35b6020600f3d393d51543d52593df3)
            mstore(add(m, 0x4b), 0xa13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc545af4)
            mstore(add(m, 0x2b), 0x600f5155f3365814604357363d3d373d3d363d7f360894)
            mstore(add(m, 0x14), implementation)
            mstore(m, add(0xfe6100523d8160233d3973, shl(56, n)))

            // Do a out-of-gas revert if `n` is greater than `0xffff - 0x52 = 0xffad`.
            instance := create(value, add(m, add(0x15, lt(n, 0xffae))), add(0x75, n))
            if iszero(instance) {
                mstore(0x00, 0x30116425) // `DeploymentFailed()`.
                revert(0x1c, 0x04)
            }
        }
    }

    /// @dev Deploys a deterministic ERC1967I proxy with `implementation`, `args`, and `salt`.
    function deployDeterministicERC1967I(address implementation, bytes memory args, bytes32 salt)
        internal
        returns (address instance)
    {
        instance = deployDeterministicERC1967I(0, implementation, args, salt);
    }

    /// @dev Deploys a deterministic ERC1967I proxy with `implementation`,`args`,  and `salt`.
    /// Deposits `value` ETH during deployment.
    function deployDeterministicERC1967I(
        uint256 value,
        address implementation,
        bytes memory args,
        bytes32 salt
    ) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40)
            let n := mload(args)
            pop(staticcall(gas(), 4, add(args, 0x20), n, add(m, 0x8b), n))

            mstore(add(m, 0x6b), 0x3d6000803e603e573d6000fd5b3d6000f35b6020600f3d393d51543d52593df3)
            mstore(add(m, 0x4b), 0xa13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc545af4)
            mstore(add(m, 0x2b), 0x600f5155f3365814604357363d3d373d3d363d7f360894)
            mstore(add(m, 0x14), implementation)
            mstore(m, add(0xfe6100523d8160233d3973, shl(56, n)))

            // Do a out-of-gas revert if `n` is greater than `0xffff - 0x52 = 0xffad`.
            instance := create2(value, add(m, add(0x15, lt(n, 0xffae))), add(0x75, n), salt)
            if iszero(instance) {
                mstore(0x00, 0x30116425) // `DeploymentFailed()`.
                revert(0x1c, 0x04)
            }
        }
    }

    /// @dev Creates a deterministic ERC1967I proxy with `implementation`, `args` and `salt`.
    /// Note: This method is intended for use in ERC4337 factories,
    /// which are expected to NOT revert if the proxy is already deployed.
    function createDeterministicERC1967I(address implementation, bytes memory args, bytes32 salt)
        internal
        returns (bool alreadyDeployed, address instance)
    {
        return createDeterministicERC1967I(0, implementation, args, salt);
    }

    /// @dev Creates a deterministic ERC1967I proxy with `implementation`,`args` and `salt`.
    /// Deposits `value` ETH during deployment.
    /// Note: This method is intended for use in ERC4337 factories,
    /// which are expected to NOT revert if the proxy is already deployed.
    function createDeterministicERC1967I(
        uint256 value,
        address implementation,
        bytes memory args,
        bytes32 salt
    ) internal returns (bool alreadyDeployed, address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40)
            let n := mload(args)
            pop(staticcall(gas(), 4, add(args, 0x20), n, add(m, 0x75), n))
            mstore(add(m, 0x55), 0x3d6000803e603e573d6000fd5b3d6000f35b6020600f3d393d51543d52593df3)
            mstore(add(m, 0x35), 0xa13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc545af4)
            mstore(add(m, 0x15), 0x5155f3365814604357363d3d373d3d363d7f360894)
            mstore(0x16, 0x600f)
            mstore(0x14, implementation)
            // Do a out-of-gas revert if `n` is greater than `0xffff - 0x52 = 0xffad`.
            mstore(gt(n, 0xffad), add(0xfe6100523d8160233d3973, shl(56, n)))
            mstore(m, mload(0x16))
            // Compute and store the bytecode hash.
            mstore8(0x00, 0xff) // Write the prefix.
            mstore(0x35, keccak256(m, add(n, 0x75)))
            mstore(0x01, shl(96, address()))
            mstore(0x15, salt)
            instance := keccak256(0x00, 0x55)
            for {} 1 {} {
                if iszero(extcodesize(instance)) {
                    instance := create2(value, m, add(0x75, n), salt)
                    if iszero(instance) {
                        mstore(0x00, 0x30116425) // `DeploymentFailed()`.
                        revert(0x1c, 0x04)
                    }
                    break
                }
                alreadyDeployed := 1
                if iszero(value) { break }
                if iszero(call(gas(), instance, value, codesize(), 0x00, codesize(), 0x00)) {
                    mstore(0x00, 0xb12d13eb) // `ETHTransferFailed()`.
                    revert(0x1c, 0x04)
                }
                break
            }
            mstore(0x35, 0) // Restore the overwritten part of the free memory pointer.
        }
    }

    /// @dev Returns the initialization code of the ERC1967I proxy of `implementation`and `args`.
    function initCodeERC1967I(address implementation, bytes memory args)
        internal
        pure
        returns (bytes memory c)
    {
        /// @solidity memory-safe-assembly
        assembly {
            c := mload(0x40)
            let n := mload(args)
            // Do a out-of-gas revert if `n` is greater than `0xffff - 0x52 = 0xffad`.
            returndatacopy(returndatasize(), returndatasize(), gt(n, 0xffad))
            for { let i := 0 } lt(i, n) { i := add(i, 0x20) } {
                mstore(add(add(c, 0x95), i), mload(add(add(args, 0x20), i)))
            }

            mstore(add(c, 0x75), 0x3d6000803e603e573d6000fd5b3d6000f35b6020600f3d393d51543d52593df3)
            mstore(add(c, 0x55), 0xa13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc545af4)
            mstore(add(c, 0x35), 0x600f5155f3365814604357363d3d373d3d363d7f360894)
            mstore(add(c, 0x1e), implementation)
            mstore(add(c, 0x0a), add(0x6100523d8160233d3973, shl(56, n)))
            mstore(add(c, add(n, 0x95)), 0)
            mstore(c, add(0x75, n)) // Store the length.
            mstore(0x40, add(c, add(n, 0xb5))) // Allocate memory.
        }
    }

    /// @dev Returns the initialization code hash of the ERC1967I proxy of `implementation` and `args.
    function initCodeHashERC1967I(address implementation, bytes memory args)
        internal
        pure
        returns (bytes32 hash)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            let n := mload(args)
            // Do a out-of-gas revert if `n` is greater than `0xffff - 0x52 = 0xffad`.
            returndatacopy(returndatasize(), returndatasize(), gt(n, 0xffad))

            for { let i := 0 } lt(i, n) { i := add(i, 0x20) } {
                mstore(add(add(m, 0x75), i), mload(add(add(args, 0x20), i)))
            }

            mstore(add(m, 0x55), 0x3d6000803e603e573d6000fd5b3d6000f35b6020600f3d393d51543d52593df3)
            mstore(add(m, 0x35), 0xa13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc545af4)
            mstore(add(m, 0x15), 0x5155f3365814604357363d3d373d3d363d7f360894)
            mstore(0x16, 0x600f)
            mstore(0x14, implementation)
            mstore(0x00, add(0x6100523d8160233d3973, shl(56, n)))
            mstore(m, mload(0x16))
            hash := keccak256(m, add(0x75, n))
        }
    }

    /// @dev Returns the address of the ERC1967I proxy of `implementation`, 'args` with `salt` by `deployer`.
    /// Note: The returned result has dirty upper 96 bits. Please clean if used in assembly.
    function predictDeterministicAddressERC1967I(
        address implementation,
        bytes memory args,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        bytes32 hash = initCodeHashERC1967I(implementation, args);
        predicted = predictDeterministicAddress(hash, salt, deployer);
    }

    /// @dev Equivalent to `argsOnERC1967I(instance, start, 2 ** 256 - 1)`.
    function argsOnERC1967I(address instance) internal view returns (bytes memory args) {
        /// @solidity memory-safe-assembly
        assembly {
            args := mload(0x40)
            mstore(args, and(0xffffffffff, sub(extcodesize(instance), 0x52))) // Store the length.
            extcodecopy(instance, add(args, 0x20), 0x52, add(mload(args), 0x20))
            mstore(0x40, add(mload(args), add(args, 0x40))) // Allocate memory.
        }
    }

    /// @dev Equivalent to `argsOnERC1967I(instance, start, 2 ** 256 - 1)`.
    function argsOnERC1967I(address instance, uint256 start)
        internal
        view
        returns (bytes memory args)
    {
        /// @solidity memory-safe-assembly
        assembly {
            args := mload(0x40)
            let n := and(0xffffffffff, sub(extcodesize(instance), 0x52))
            extcodecopy(instance, add(args, 0x20), add(start, 0x52), add(n, 0x20))
            mstore(args, mul(sub(n, start), lt(start, n))) // Store the length.
            mstore(0x40, add(mload(args), add(args, 0x40))) // Allocate memory.
        }
    }

    /// @dev Returns a slice of the immutable arguments on `instance` from `start` to `end`.
    /// `start` and `end` will be clamped to the range `[0, args.length]`.
    /// The `instance` MUST be deployed via the ERC1967 with immutable args functions.
    /// Otherwise, the behavior is undefined.
    /// Out-of-gas reverts if `instance` does not have any code.
    function argsOnERC1967I(address instance, uint256 start, uint256 end)
        internal
        view
        returns (bytes memory args)
    {
        /// @solidity memory-safe-assembly
        assembly {
            args := mload(0x40)
            if iszero(lt(end, 0xffff)) { end := 0xffff }
            let d := mul(sub(end, start), lt(start, end))
            extcodecopy(instance, args, add(start, 0x32), add(d, 0x20))
            if iszero(and(0xff, mload(add(args, d)))) {
                let n := sub(extcodesize(instance), 0x52)
                returndatacopy(returndatasize(), returndatasize(), shr(40, n))
                d := mul(gt(n, start), sub(d, mul(gt(end, n), sub(end, n))))
            }
            mstore(args, d) // Store the length.
            mstore(add(add(args, 0x20), d), 0) // Zeroize the slot after the bytes.
            mstore(0x40, add(add(args, 0x40), d)) // Allocate memory.
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                ERC1967 BOOTSTRAP OPERATIONS                */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // A bootstrap is a minimal UUPS implementation that allows an ERC1967 proxy
    // pointing to it to be upgraded. The ERC1967 proxy can then be deployed to a
    // deterministic address independent of the implementation:
    // ```
    //     address bootstrap = LibClone.erc1967Bootstrap();
    //     address instance = LibClone.deployDeterministicERC1967(0, bootstrap, salt);
    //     LibClone.bootstrapERC1967(bootstrap, implementation);
    // ```

    /// @dev Deploys the ERC1967 bootstrap if it has not been deployed.
    function erc1967Bootstrap() internal returns (address) {
        return erc1967Bootstrap(address(this));
    }

    /// @dev Deploys the ERC1967 bootstrap if it has not been deployed.
    function erc1967Bootstrap(address authorizedUpgrader) internal returns (address bootstrap) {
        bytes memory c = initCodeERC1967Bootstrap(authorizedUpgrader);
        bootstrap = predictDeterministicAddress(keccak256(c), bytes32(0), address(this));
        /// @solidity memory-safe-assembly
        assembly {
            if iszero(extcodesize(bootstrap)) {
                if iszero(create2(0, add(c, 0x20), mload(c), 0)) {
                    mstore(0x00, 0x30116425) // `DeploymentFailed()`.
                    revert(0x1c, 0x04)
                }
            }
        }
    }

    /// @dev Replaces the implementation at `instance`.
    function bootstrapERC1967(address instance, address implementation) internal {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, implementation)
            if iszero(call(gas(), instance, 0, 0x0c, 0x14, codesize(), 0x00)) {
                mstore(0x00, 0x30116425) // `DeploymentFailed()`.
                revert(0x1c, 0x04)
            }
        }
    }

    /// @dev Replaces the implementation at `instance`, and then call it with `data`.
    function bootstrapERC1967AndCall(address instance, address implementation, bytes memory data)
        internal
    {
        /// @solidity memory-safe-assembly
        assembly {
            let n := mload(data)
            mstore(data, implementation)
            if iszero(call(gas(), instance, 0, add(data, 0x0c), add(n, 0x14), codesize(), 0x00)) {
                if iszero(returndatasize()) {
                    mstore(0x00, 0x30116425) // `DeploymentFailed()`.
                    revert(0x1c, 0x04)
                }
                returndatacopy(mload(0x40), 0x00, returndatasize())
                revert(mload(0x40), returndatasize())
            }
            mstore(data, n) // Restore the length of `data`.
        }
    }

    /// @dev Returns the implementation address of the ERC1967 bootstrap for this contract.
    function predictDeterministicAddressERC1967Bootstrap() internal view returns (address) {
        return predictDeterministicAddressERC1967Bootstrap(address(this), address(this));
    }

    /// @dev Returns the implementation address of the ERC1967 bootstrap for this contract.
    function predictDeterministicAddressERC1967Bootstrap(
        address authorizedUpgrader,
        address deployer
    ) internal pure returns (address) {
        bytes32 hash = initCodeHashERC1967Bootstrap(authorizedUpgrader);
        return predictDeterministicAddress(hash, bytes32(0), deployer);
    }

    /// @dev Returns the initialization code of the ERC1967 bootstrap.
    function initCodeERC1967Bootstrap(address authorizedUpgrader)
        internal
        pure
        returns (bytes memory c)
    {
        /// @solidity memory-safe-assembly
        assembly {
            c := mload(0x40)
            mstore(add(c, 0x80), 0x3d3560601c5af46047573d6000383e3d38fd0000000000000000000000000000)
            mstore(add(c, 0x60), 0xa920a3ca505d382bbc55601436116049575b005b363d3d373d3d601436036014)
            mstore(add(c, 0x40), 0x0338573d3560601c7f360894a13ba1a3210667c828492db98dca3e2076cc3735)
            mstore(add(c, 0x20), authorizedUpgrader)
            mstore(add(c, 0x0c), 0x606880600a3d393df3fe3373)
            mstore(c, 0x72)
            mstore(0x40, add(c, 0xa0))
        }
    }

    /// @dev Returns the initialization code hash of the ERC1967 bootstrap.
    function initCodeHashERC1967Bootstrap(address authorizedUpgrader)
        internal
        pure
        returns (bytes32)
    {
        return keccak256(initCodeERC1967Bootstrap(authorizedUpgrader));
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*          MINIMAL ERC1967 BEACON PROXY OPERATIONS           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // Note: If you use this proxy, you MUST make sure that the beacon is a
    // valid ERC1967 beacon. This means that the beacon must always return a valid
    // address upon a staticcall to `implementation()`, given sufficient gas.
    // For performance, the deployment operations and the proxy assumes that the
    // beacon is always valid and will NOT validate it.

    /// @dev Deploys a minimal ERC1967 beacon proxy.
    function deployERC1967BeaconProxy(address beacon) internal returns (address instance) {
        instance = deployERC1967BeaconProxy(0, beacon);
    }

    /// @dev Deploys a minimal ERC1967 beacon proxy.
    /// Deposits `value` ETH during deployment.
    function deployERC1967BeaconProxy(uint256 value, address beacon)
        internal
        returns (address instance)
    {
        /// @solidity memory-safe-assembly
        assembly {
            /**
             * ---------------------------------------------------------------------------------+
             * CREATION (34 bytes)                                                              |
             * ---------------------------------------------------------------------------------|
             * Opcode     | Mnemonic       | Stack            | Memory                          |
             * ---------------------------------------------------------------------------------|
             * 60 runSize | PUSH1 runSize  | r                |                                 |
             * 3d         | RETURNDATASIZE | 0 r              |                                 |
             * 81         | DUP2           | r 0 r            |                                 |
             * 60 offset  | PUSH1 offset   | o r 0 r          |                                 |
             * 3d         | RETURNDATASIZE | 0 o r 0 r        |                                 |
             * 39         | CODECOPY       | 0 r              | [0..runSize): runtime code      |
             * 73 beac    | PUSH20 beac    | beac 0 r         | [0..runSize): runtime code      |
             * 60 slotPos | PUSH1 slotPos  | slotPos beac 0 r | [0..runSize): runtime code      |
             * 51         | MLOAD          | slot beac 0 r    | [0..runSize): runtime code      |
             * 55         | SSTORE         | 0 r              | [0..runSize): runtime code      |
             * f3         | RETURN         |                  | [0..runSize): runtime code      |
             * ---------------------------------------------------------------------------------|
             * RUNTIME (82 bytes)                                                               |
             * ---------------------------------------------------------------------------------|
             * Opcode     | Mnemonic       | Stack            | Memory                          |
             * ---------------------------------------------------------------------------------|
             *                                                                                  |
             * ::: copy calldata to memory :::::::::::::::::::::::::::::::::::::::::::::::::::: |
             * 36         | CALLDATASIZE   | cds              |                                 |
             * 3d         | RETURNDATASIZE | 0 cds            |                                 |
             * 3d         | RETURNDATASIZE | 0 0 cds          |                                 |
             * 37         | CALLDATACOPY   |                  | [0..calldatasize): calldata     |
             *                                                                                  |
             * ::: delegatecall to implementation ::::::::::::::::::::::::::::::::::::::::::::: |
             * 3d         | RETURNDATASIZE | 0                |                                 |
             * 3d         | RETURNDATASIZE | 0 0              |                                 |
             * 36         | CALLDATASIZE   | cds 0 0          | [0..calldatasize): calldata     |
             * 3d         | RETURNDATASIZE | 0 cds 0 0        | [0..calldatasize): calldata     |
             *                                                                                  |
             * ~~~~~~~ beacon staticcall sub procedure ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ |
             * 60 0x20       | PUSH1 0x20       | 32                          |                 |
             * 36            | CALLDATASIZE     | cds 32                      |                 |
             * 60 0x04       | PUSH1 0x04       | 4 cds 32                    |                 |
             * 36            | CALLDATASIZE     | cds 4 cds 32                |                 |
             * 63 0x5c60da1b | PUSH4 0x5c60da1b | 0x5c60da1b cds 4 cds 32     |                 |
             * 60 0xe0       | PUSH1 0xe0       | 224 0x5c60da1b cds 4 cds 32 |                 |
             * 1b            | SHL              | sel cds 4 cds 32            |                 |
             * 36            | CALLDATASIZE     | cds sel cds 4 cds 32        |                 |
             * 52            | MSTORE           | cds 4 cds 32                | sel             |
             * 7f slot       | PUSH32 slot      | s cds 4 cds 32              | sel             |
             * 54            | SLOAD            | beac cds 4 cds 32           | sel             |
             * 5a            | GAS              | g beac cds 4 cds 32         | sel             |
             * fa            | STATICCALL       | succ                        | impl            |
             * 50            | POP              |                             | impl            |
             * 36            | CALLDATASIZE     | cds                         | impl            |
             * 51            | MLOAD            | impl                        | impl            |
             * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ |
             * 5a         | GAS            | g impl 0 cds 0 0 | [0..calldatasize): calldata     |
             * f4         | DELEGATECALL   | succ             | [0..calldatasize): calldata     |
             *                                                                                  |
             * ::: copy returndata to memory :::::::::::::::::::::::::::::::::::::::::::::::::: |
             * 3d         | RETURNDATASIZE | rds succ         | [0..calldatasize): calldata     |
             * 60 0x00    | PUSH1 0x00     | 0 rds succ       | [0..calldatasize): calldata     |
             * 80         | DUP1           | 0 0 rds succ     | [0..calldatasize): calldata     |
             * 3e         | RETURNDATACOPY | succ             | [0..returndatasize): returndata |
             *                                                                                  |
             * ::: branch on delegatecall status :::::::::::::::::::::::::::::::::::::::::::::: |
             * 60 0x4d    | PUSH1 0x4d     | dest succ        | [0..returndatasize): returndata |
             * 57         | JUMPI          |                  | [0..returndatasize): returndata |
             *                                                                                  |
             * ::: delegatecall failed, revert :::::::::::::::::::::::::::::::::::::::::::::::: |
             * 3d         | RETURNDATASIZE | rds              | [0..returndatasize): returndata |
             * 60 0x00    | PUSH1 0x00     | 0 rds            | [0..returndatasize): returndata |
             * fd         | REVERT         |                  | [0..returndatasize): returndata |
             *                                                                                  |
             * ::: delegatecall succeeded, return ::::::::::::::::::::::::::::::::::::::::::::: |
             * 5b         | JUMPDEST       |                  | [0..returndatasize): returndata |
             * 3d         | RETURNDATASIZE | rds              | [0..returndatasize): returndata |
             * 60 0x00    | PUSH1 0x00     | 0 rds            | [0..returndatasize): returndata |
             * f3         | RETURN         |                  | [0..returndatasize): returndata |
             * ---------------------------------------------------------------------------------+
             */
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x60, 0xb3582b35133d50545afa5036515af43d6000803e604d573d6000fd5b3d6000f3)
            mstore(0x40, 0x1b60e01b36527fa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6c)
            mstore(0x20, 0x60195155f3363d3d373d3d363d602036600436635c60da)
            mstore(0x09, or(shl(160, 0x60523d8160223d3973), shr(96, shl(96, beacon))))
            instance := create(value, 0x0c, 0x74)
            if iszero(instance) {
                mstore(0x00, 0x30116425) // `DeploymentFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x40, m) // Restore the free memory pointer.
            mstore(0x60, 0) // Restore the zero slot.
        }
    }

    /// @dev Deploys a deterministic minimal ERC1967 beacon proxy with `salt`.
    function deployDeterministicERC1967BeaconProxy(address beacon, bytes32 salt)
        internal
        returns (address instance)
    {
        instance = deployDeterministicERC1967BeaconProxy(0, beacon, salt);
    }

    /// @dev Deploys a deterministic minimal ERC1967 beacon proxy with `salt`.
    /// Deposits `value` ETH during deployment.
    function deployDeterministicERC1967BeaconProxy(uint256 value, address beacon, bytes32 salt)
        internal
        returns (address instance)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x60, 0xb3582b35133d50545afa5036515af43d6000803e604d573d6000fd5b3d6000f3)
            mstore(0x40, 0x1b60e01b36527fa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6c)
            mstore(0x20, 0x60195155f3363d3d373d3d363d602036600436635c60da)
            mstore(0x09, or(shl(160, 0x60523d8160223d3973), shr(96, shl(96, beacon))))
            instance := create2(value, 0x0c, 0x74, salt)
            if iszero(instance) {
                mstore(0x00, 0x30116425) // `DeploymentFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x40, m) // Restore the free memory pointer.
            mstore(0x60, 0) // Restore the zero slot.
        }
    }

    /// @dev Creates a deterministic minimal ERC1967 beacon proxy with `salt`.
    /// Note: This method is intended for use in ERC4337 factories,
    /// which are expected to NOT revert if the proxy is already deployed.
    function createDeterministicERC1967BeaconProxy(address beacon, bytes32 salt)
        internal
        returns (bool alreadyDeployed, address instance)
    {
        return createDeterministicERC1967BeaconProxy(0, beacon, salt);
    }

    /// @dev Creates a deterministic minimal ERC1967 beacon proxy with `salt`.
    /// Deposits `value` ETH during deployment.
    /// Note: This method is intended for use in ERC4337 factories,
    /// which are expected to NOT revert if the proxy is already deployed.
    function createDeterministicERC1967BeaconProxy(uint256 value, address beacon, bytes32 salt)
        internal
        returns (bool alreadyDeployed, address instance)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x60, 0xb3582b35133d50545afa5036515af43d6000803e604d573d6000fd5b3d6000f3)
            mstore(0x40, 0x1b60e01b36527fa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6c)
            mstore(0x20, 0x60195155f3363d3d373d3d363d602036600436635c60da)
            mstore(0x09, or(shl(160, 0x60523d8160223d3973), shr(96, shl(96, beacon))))
            // Compute and store the bytecode hash.
            mstore(add(m, 0x35), keccak256(0x0c, 0x74))
            mstore(m, shl(88, address()))
            mstore8(m, 0xff) // Write the prefix.
            mstore(add(m, 0x15), salt)
            instance := keccak256(m, 0x55)
            for {} 1 {} {
                if iszero(extcodesize(instance)) {
                    instance := create2(value, 0x0c, 0x74, salt)
                    if iszero(instance) {
                        mstore(0x00, 0x30116425) // `DeploymentFailed()`.
                        revert(0x1c, 0x04)
                    }
                    break
                }
                alreadyDeployed := 1
                if iszero(value) { break }
                if iszero(call(gas(), instance, value, codesize(), 0x00, codesize(), 0x00)) {
                    mstore(0x00, 0xb12d13eb) // `ETHTransferFailed()`.
                    revert(0x1c, 0x04)
                }
                break
            }
            mstore(0x40, m) // Restore the free memory pointer.
            mstore(0x60, 0) // Restore the zero slot.
        }
    }

    /// @dev Returns the initialization code of the minimal ERC1967 beacon proxy.
    function initCodeERC1967BeaconProxy(address beacon) internal pure returns (bytes memory c) {
        /// @solidity memory-safe-assembly
        assembly {
            c := mload(0x40)
            mstore(add(c, 0x74), 0xb3582b35133d50545afa5036515af43d6000803e604d573d6000fd5b3d6000f3)
            mstore(add(c, 0x54), 0x1b60e01b36527fa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6c)
            mstore(add(c, 0x34), 0x60195155f3363d3d373d3d363d602036600436635c60da)
            mstore(add(c, 0x1d), beacon)
            mstore(add(c, 0x09), 0x60523d8160223d3973)
            mstore(add(c, 0x94), 0)
            mstore(c, 0x74) // Store the length.
            mstore(0x40, add(c, 0xa0)) // Allocate memory.
        }
    }

    /// @dev Returns the initialization code hash of the minimal ERC1967 beacon proxy.
    function initCodeHashERC1967BeaconProxy(address beacon) internal pure returns (bytes32 hash) {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x60, 0xb3582b35133d50545afa5036515af43d6000803e604d573d6000fd5b3d6000f3)
            mstore(0x40, 0x1b60e01b36527fa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6c)
            mstore(0x20, 0x60195155f3363d3d373d3d363d602036600436635c60da)
            mstore(0x09, or(shl(160, 0x60523d8160223d3973), shr(96, shl(96, beacon))))
            hash := keccak256(0x0c, 0x74)
            mstore(0x40, m) // Restore the free memory pointer.
            mstore(0x60, 0) // Restore the zero slot.
        }
    }

    /// @dev Returns the address of the ERC1967 beacon proxy, with `salt` by `deployer`.
    /// Note: The returned result has dirty upper 96 bits. Please clean if used in assembly.
    function predictDeterministicAddressERC1967BeaconProxy(
        address beacon,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        bytes32 hash = initCodeHashERC1967BeaconProxy(beacon);
        predicted = predictDeterministicAddress(hash, salt, deployer);
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*    ERC1967 BEACON PROXY WITH IMMUTABLE ARGS OPERATIONS     */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Deploys a minimal ERC1967 beacon proxy with `args`.
    function deployERC1967BeaconProxy(address beacon, bytes memory args)
        internal
        returns (address instance)
    {
        instance = deployERC1967BeaconProxy(0, beacon, args);
    }

    /// @dev Deploys a minimal ERC1967 beacon proxy with `args`.
    /// Deposits `value` ETH during deployment.
    function deployERC1967BeaconProxy(uint256 value, address beacon, bytes memory args)
        internal
        returns (address instance)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40)
            let n := mload(args)
            pop(staticcall(gas(), 4, add(args, 0x20), n, add(m, 0x8b), n))
            mstore(add(m, 0x6b), 0xb3582b35133d50545afa5036515af43d6000803e604d573d6000fd5b3d6000f3)
            mstore(add(m, 0x4b), 0x1b60e01b36527fa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6c)
            mstore(add(m, 0x2b), 0x60195155f3363d3d373d3d363d602036600436635c60da)
            mstore(add(m, 0x14), beacon)
            // Do a out-of-gas revert if `n` is greater than `0xffff - 0x52 = 0xffad`.
            mstore(add(m, gt(n, 0xffad)), add(0xfe6100523d8160233d3973, shl(56, n)))
            instance := create(value, add(m, 0x16), add(n, 0x75))
            if iszero(instance) {
                mstore(0x00, 0x30116425) // `DeploymentFailed()`.
                revert(0x1c, 0x04)
            }
        }
    }

    /// @dev Deploys a deterministic minimal ERC1967 beacon proxy with `args` and `salt`.
    function deployDeterministicERC1967BeaconProxy(address beacon, bytes memory args, bytes32 salt)
        internal
        returns (address instance)
    {
        instance = deployDeterministicERC1967BeaconProxy(0, beacon, args, salt);
    }

    /// @dev Deploys a deterministic minimal ERC1967 beacon proxy with `args` and `salt`.
    /// Deposits `value` ETH during deployment.
    function deployDeterministicERC1967BeaconProxy(
        uint256 value,
        address beacon,
        bytes memory args,
        bytes32 salt
    ) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40)
            let n := mload(args)
            pop(staticcall(gas(), 4, add(args, 0x20), n, add(m, 0x8b), n))
            mstore(add(m, 0x6b), 0xb3582b35133d50545afa5036515af43d6000803e604d573d6000fd5b3d6000f3)
            mstore(add(m, 0x4b), 0x1b60e01b36527fa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6c)
            mstore(add(m, 0x2b), 0x60195155f3363d3d373d3d363d602036600436635c60da)
            mstore(add(m, 0x14), beacon)
            // Do a out-of-gas revert if `n` is greater than `0xffff - 0x52 = 0xffad`.
            mstore(add(m, gt(n, 0xffad)), add(0xfe6100523d8160233d3973, shl(56, n)))
            instance := create2(value, add(m, 0x16), add(n, 0x75), salt)
            if iszero(instance) {
                mstore(0x00, 0x30116425) // `DeploymentFailed()`.
                revert(0x1c, 0x04)
            }
        }
    }

    /// @dev Creates a deterministic minimal ERC1967 beacon proxy with `args` and `salt`.
    /// Note: This method is intended for use in ERC4337 factories,
    /// which are expected to NOT revert if the proxy is already deployed.
    function createDeterministicERC1967BeaconProxy(address beacon, bytes memory args, bytes32 salt)
        internal
        returns (bool alreadyDeployed, address instance)
    {
        return createDeterministicERC1967BeaconProxy(0, beacon, args, salt);
    }

    /// @dev Creates a deterministic minimal ERC1967 beacon proxy with `args` and `salt`.
    /// Deposits `value` ETH during deployment.
    /// Note: This method is intended for use in ERC4337 factories,
    /// which are expected to NOT revert if the proxy is already deployed.
    function createDeterministicERC1967BeaconProxy(
        uint256 value,
        address beacon,
        bytes memory args,
        bytes32 salt
    ) internal returns (bool alreadyDeployed, address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40)
            let n := mload(args)
            pop(staticcall(gas(), 4, add(args, 0x20), n, add(m, 0x8b), n))
            mstore(add(m, 0x6b), 0xb3582b35133d50545afa5036515af43d6000803e604d573d6000fd5b3d6000f3)
            mstore(add(m, 0x4b), 0x1b60e01b36527fa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6c)
            mstore(add(m, 0x2b), 0x60195155f3363d3d373d3d363d602036600436635c60da)
            mstore(add(m, 0x14), beacon)
            // Do a out-of-gas revert if `n` is greater than `0xffff - 0x52 = 0xffad`.
            mstore(add(m, gt(n, 0xffad)), add(0xfe6100523d8160233d3973, shl(56, n)))
            // Compute and store the bytecode hash.
            mstore8(0x00, 0xff) // Write the prefix.
            mstore(0x35, keccak256(add(m, 0x16), add(n, 0x75)))
            mstore(0x01, shl(96, address()))
            mstore(0x15, salt)
            instance := keccak256(0x00, 0x55)
            for {} 1 {} {
                if iszero(extcodesize(instance)) {
                    instance := create2(value, add(m, 0x16), add(n, 0x75), salt)
                    if iszero(instance) {
                        mstore(0x00, 0x30116425) // `DeploymentFailed()`.
                        revert(0x1c, 0x04)
                    }
                    break
                }
                alreadyDeployed := 1
                if iszero(value) { break }
                if iszero(call(gas(), instance, value, codesize(), 0x00, codesize(), 0x00)) {
                    mstore(0x00, 0xb12d13eb) // `ETHTransferFailed()`.
                    revert(0x1c, 0x04)
                }
                break
            }
            mstore(0x35, 0) // Restore the overwritten part of the free memory pointer.
        }
    }

    /// @dev Returns the initialization code of the minimal ERC1967 beacon proxy.
    function initCodeERC1967BeaconProxy(address beacon, bytes memory args)
        internal
        pure
        returns (bytes memory c)
    {
        /// @solidity memory-safe-assembly
        assembly {
            c := mload(0x40)
            let n := mload(args)
            // Do a out-of-gas revert if `n` is greater than `0xffff - 0x52 = 0xffad`.
            returndatacopy(returndatasize(), returndatasize(), gt(n, 0xffad))
            for { let i := 0 } lt(i, n) { i := add(i, 0x20) } {
                mstore(add(add(c, 0x95), i), mload(add(add(args, 0x20), i)))
            }
            mstore(add(c, 0x75), 0xb3582b35133d50545afa5036515af43d6000803e604d573d6000fd5b3d6000f3)
            mstore(add(c, 0x55), 0x1b60e01b36527fa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6c)
            mstore(add(c, 0x35), 0x60195155f3363d3d373d3d363d602036600436635c60da)
            mstore(add(c, 0x1e), beacon)
            mstore(add(c, 0x0a), add(0x6100523d8160233d3973, shl(56, n)))
            mstore(c, add(n, 0x75)) // Store the length.
            mstore(add(c, add(n, 0x95)), 0) // Zeroize the slot after the bytes.
            mstore(0x40, add(c, add(n, 0xb5))) // Allocate memory.
        }
    }

    /// @dev Returns the initialization code hash of the minimal ERC1967 beacon proxy with `args`.
    function initCodeHashERC1967BeaconProxy(address beacon, bytes memory args)
        internal
        pure
        returns (bytes32 hash)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40)
            let n := mload(args)
            // Do a out-of-gas revert if `n` is greater than `0xffff - 0x52 = 0xffad`.
            returndatacopy(returndatasize(), returndatasize(), gt(n, 0xffad))
            for { let i := 0 } lt(i, n) { i := add(i, 0x20) } {
                mstore(add(add(m, 0x8b), i), mload(add(add(args, 0x20), i)))
            }
            mstore(add(m, 0x6b), 0xb3582b35133d50545afa5036515af43d6000803e604d573d6000fd5b3d6000f3)
            mstore(add(m, 0x4b), 0x1b60e01b36527fa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6c)
            mstore(add(m, 0x2b), 0x60195155f3363d3d373d3d363d602036600436635c60da)
            mstore(add(m, 0x14), beacon)
            mstore(m, add(0x6100523d8160233d3973, shl(56, n)))
            hash := keccak256(add(m, 0x16), add(n, 0x75))
        }
    }

    /// @dev Returns the address of the ERC1967 beacon proxy with `args`, with `salt` by `deployer`.
    /// Note: The returned result has dirty upper 96 bits. Please clean if used in assembly.
    function predictDeterministicAddressERC1967BeaconProxy(
        address beacon,
        bytes memory args,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        bytes32 hash = initCodeHashERC1967BeaconProxy(beacon, args);
        predicted = predictDeterministicAddress(hash, salt, deployer);
    }

    /// @dev Equivalent to `argsOnERC1967BeaconProxy(instance, start, 2 ** 256 - 1)`.
    function argsOnERC1967BeaconProxy(address instance) internal view returns (bytes memory args) {
        /// @solidity memory-safe-assembly
        assembly {
            args := mload(0x40)
            mstore(args, and(0xffffffffff, sub(extcodesize(instance), 0x52))) // Store the length.
            extcodecopy(instance, add(args, 0x20), 0x52, add(mload(args), 0x20))
            mstore(0x40, add(mload(args), add(args, 0x40))) // Allocate memory.
        }
    }

    /// @dev Equivalent to `argsOnERC1967BeaconProxy(instance, start, 2 ** 256 - 1)`.
    function argsOnERC1967BeaconProxy(address instance, uint256 start)
        internal
        view
        returns (bytes memory args)
    {
        /// @solidity memory-safe-assembly
        assembly {
            args := mload(0x40)
            let n := and(0xffffffffff, sub(extcodesize(instance), 0x52))
            extcodecopy(instance, add(args, 0x20), add(start, 0x52), add(n, 0x20))
            mstore(args, mul(sub(n, start), lt(start, n))) // Store the length.
            mstore(0x40, add(args, add(0x40, mload(args)))) // Allocate memory.
        }
    }

    /// @dev Returns a slice of the immutable arguments on `instance` from `start` to `end`.
    /// `start` and `end` will be clamped to the range `[0, args.length]`.
    /// The `instance` MUST be deployed via the ERC1967 beacon proxy with immutable args functions.
    /// Otherwise, the behavior is undefined.
    /// Out-of-gas reverts if `instance` does not have any code.
    function argsOnERC1967BeaconProxy(address instance, uint256 start, uint256 end)
        internal
        view
        returns (bytes memory args)
    {
        /// @solidity memory-safe-assembly
        assembly {
            args := mload(0x40)
            if iszero(lt(end, 0xffff)) { end := 0xffff }
            let d := mul(sub(end, start), lt(start, end))
            extcodecopy(instance, args, add(start, 0x32), add(d, 0x20))
            if iszero(and(0xff, mload(add(args, d)))) {
                let n := sub(extcodesize(instance), 0x52)
                returndatacopy(returndatasize(), returndatasize(), shr(40, n))
                d := mul(gt(n, start), sub(d, mul(gt(end, n), sub(end, n))))
            }
            mstore(args, d) // Store the length.
            mstore(add(add(args, 0x20), d), 0) // Zeroize the slot after the bytes.
            mstore(0x40, add(add(args, 0x40), d)) // Allocate memory.
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*              ERC1967I BEACON PROXY OPERATIONS              */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // Note: This proxy has a special code path that activates if `calldatasize() == 1`.
    // This code path skips the delegatecall and directly returns the `implementation` address.
    // The returned implementation is guaranteed to be valid if the keccak256 of the
    // proxy's code is equal to `ERC1967_BEACON_PROXY_CODE_HASH`.
    //
    // If you use this proxy, you MUST make sure that the beacon is a
    // valid ERC1967 beacon. This means that the beacon must always return a valid
    // address upon a staticcall to `implementation()`, given sufficient gas.
    // For performance, the deployment operations and the proxy assumes that the
    // beacon is always valid and will NOT validate it.

    /// @dev Deploys a ERC1967I beacon proxy.
    function deployERC1967IBeaconProxy(address beacon) internal returns (address instance) {
        instance = deployERC1967IBeaconProxy(0, beacon);
    }

    /// @dev Deploys a ERC1967I beacon proxy.
    /// Deposits `value` ETH during deployment.
    function deployERC1967IBeaconProxy(uint256 value, address beacon)
        internal
        returns (address instance)
    {
        /// @solidity memory-safe-assembly
        assembly {
            /**
             * ---------------------------------------------------------------------------------+
             * CREATION (34 bytes)                                                              |
             * ---------------------------------------------------------------------------------|
             * Opcode     | Mnemonic       | Stack            | Memory                          |
             * ---------------------------------------------------------------------------------|
             * 60 runSize | PUSH1 runSize  | r                |                                 |
             * 3d         | RETURNDATASIZE | 0 r              |                                 |
             * 81         | DUP2           | r 0 r            |                                 |
             * 60 offset  | PUSH1 offset   | o r 0 r          |                                 |
             * 3d         | RETURNDATASIZE | 0 o r 0 r        |                                 |
             * 39         | CODECOPY       | 0 r              | [0..runSize): runtime code      |
             * 73 beac    | PUSH20 beac    | beac 0 r         | [0..runSize): runtime code      |
             * 60 slotPos | PUSH1 slotPos  | slotPos beac 0 r | [0..runSize): runtime code      |
             * 51         | MLOAD          | slot beac 0 r    | [0..runSize): runtime code      |
             * 55         | SSTORE         | 0 r              | [0..runSize): runtime code      |
             * f3         | RETURN         |                  | [0..runSize): runtime code      |
             * ---------------------------------------------------------------------------------|
             * RUNTIME (87 bytes)                                                               |
             * ---------------------------------------------------------------------------------|
             * Opcode     | Mnemonic       | Stack            | Memory                          |
             * ---------------------------------------------------------------------------------|
             *                                                                                  |
             * ::: copy calldata to memory :::::::::::::::::::::::::::::::::::::::::::::::::::: |
             * 36         | CALLDATASIZE   | cds              |                                 |
             * 3d         | RETURNDATASIZE | 0 cds            |                                 |
             * 3d         | RETURNDATASIZE | 0 0 cds          |                                 |
             * 37         | CALLDATACOPY   |                  | [0..calldatasize): calldata     |
             *                                                                                  |
             * ::: delegatecall to implementation ::::::::::::::::::::::::::::::::::::::::::::: |
             * 3d         | RETURNDATASIZE | 0                |                                 |
             * 3d         | RETURNDATASIZE | 0 0              |                                 |
             * 36         | CALLDATASIZE   | cds 0 0          | [0..calldatasize): calldata     |
             * 3d         | RETURNDATASIZE | 0 cds 0 0        | [0..calldatasize): calldata     |
             *                                                                                  |
             * ~~~~~~~ beacon staticcall sub procedure ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ |
             * 60 0x20       | PUSH1 0x20       | 32                          |                 |
             * 36            | CALLDATASIZE     | cds 32                      |                 |
             * 60 0x04       | PUSH1 0x04       | 4 cds 32                    |                 |
             * 36            | CALLDATASIZE     | cds 4 cds 32                |                 |
             * 63 0x5c60da1b | PUSH4 0x5c60da1b | 0x5c60da1b cds 4 cds 32     |                 |
             * 60 0xe0       | PUSH1 0xe0       | 224 0x5c60da1b cds 4 cds 32 |                 |
             * 1b            | SHL              | sel cds 4 cds 32            |                 |
             * 36            | CALLDATASIZE     | cds sel cds 4 cds 32        |                 |
             * 52            | MSTORE           | cds 4 cds 32                | sel             |
             * 7f slot       | PUSH32 slot      | s cds 4 cds 32              | sel             |
             * 54            | SLOAD            | beac cds 4 cds 32           | sel             |
             * 5a            | GAS              | g beac cds 4 cds 32         | sel             |
             * fa            | STATICCALL       | succ                        | impl            |
             * ~~~~~~ check calldatasize ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ |
             * 36            | CALLDATASIZE     | cds succ                    |                 |
             * 14            | EQ               |                             | impl            |
             * 60 0x52       | PUSH1 0x52       |                             | impl            |
             * 57            | JUMPI            |                             | impl            |
             * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ |
             * 36            | CALLDATASIZE     | cds                         | impl            |
             * 51            | MLOAD            | impl                        | impl            |
             * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ |
             * 5a         | GAS            | g impl 0 cds 0 0 | [0..calldatasize): calldata     |
             * f4         | DELEGATECALL   | succ             | [0..calldatasize): calldata     |
             *                                                                                  |
             * ::: copy returndata to memory :::::::::::::::::::::::::::::::::::::::::::::::::: |
             * 3d         | RETURNDATASIZE | rds succ         | [0..calldatasize): calldata     |
             * 60 0x00    | PUSH1 0x00     | 0 rds succ       | [0..calldatasize): calldata     |
             * 60 0x01    | PUSH1 0x01     | 1 0 rds succ     | [0..calldatasize): calldata     |
             * 3e         | RETURNDATACOPY | succ             | [1..returndatasize): returndata |
             *                                                                                  |
             * ::: branch on delegatecall status :::::::::::::::::::::::::::::::::::::::::::::: |
             * 60 0x52    | PUSH1 0x52     | dest succ        | [1..returndatasize): returndata |
             * 57         | JUMPI          |                  | [1..returndatasize): returndata |
             *                                                                                  |
             * ::: delegatecall failed, revert :::::::::::::::::::::::::::::::::::::::::::::::: |
             * 3d         | RETURNDATASIZE | rds              | [1..returndatasize): returndata |
             * 60 0x01    | PUSH1 0x01     | 1 rds            | [1..returndatasize): returndata |
             * fd         | REVERT         |                  | [1..returndatasize): returndata |
             *                                                                                  |
             * ::: delegatecall succeeded, return ::::::::::::::::::::::::::::::::::::::::::::: |
             * 5b         | JUMPDEST       |                  | [1..returndatasize): returndata |
             * 3d         | RETURNDATASIZE | rds              | [1..returndatasize): returndata |
             * 60 0x01    | PUSH1 0x01     | 1 rds            | [1..returndatasize): returndata |
             * f3         | RETURN         |                  | [1..returndatasize): returndata |
             * ---------------------------------------------------------------------------------+
             */
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x60, 0x3d50545afa361460525736515af43d600060013e6052573d6001fd5b3d6001f3)
            mstore(0x40, 0x527fa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b3513)
            mstore(0x20, 0x60195155f3363d3d373d3d363d602036600436635c60da1b60e01b36)
            mstore(0x04, or(shl(160, 0x60573d8160223d3973), shr(96, shl(96, beacon))))
            instance := create(value, 0x07, 0x79)
            if iszero(instance) {
                mstore(0x00, 0x30116425) // `DeploymentFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x40, m) // Restore the free memory pointer.
            mstore(0x60, 0) // Restore the zero slot.
        }
    }

    /// @dev Deploys a deterministic ERC1967I beacon proxy with `salt`.
    function deployDeterministicERC1967IBeaconProxy(address beacon, bytes32 salt)
        internal
        returns (address instance)
    {
        instance = deployDeterministicERC1967IBeaconProxy(0, beacon, salt);
    }

    /// @dev Deploys a deterministic ERC1967I beacon proxy with `salt`.
    /// Deposits `value` ETH during deployment.
    function deployDeterministicERC1967IBeaconProxy(uint256 value, address beacon, bytes32 salt)
        internal
        returns (address instance)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x60, 0x3d50545afa361460525736515af43d600060013e6052573d6001fd5b3d6001f3)
            mstore(0x40, 0x527fa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b3513)
            mstore(0x20, 0x60195155f3363d3d373d3d363d602036600436635c60da1b60e01b36)
            mstore(0x04, or(shl(160, 0x60573d8160223d3973), shr(96, shl(96, beacon))))
            instance := create2(value, 0x07, 0x79, salt)
            if iszero(instance) {
                mstore(0x00, 0x30116425) // `DeploymentFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x40, m) // Restore the free memory pointer.
            mstore(0x60, 0) // Restore the zero slot.
        }
    }

    /// @dev Creates a deterministic ERC1967I beacon proxy with `salt`.
    /// Note: This method is intended for use in ERC4337 factories,
    /// which are expected to NOT revert if the proxy is already deployed.
    function createDeterministicERC1967IBeaconProxy(address beacon, bytes32 salt)
        internal
        returns (bool alreadyDeployed, address instance)
    {
        return createDeterministicERC1967IBeaconProxy(0, beacon, salt);
    }

    /// @dev Creates a deterministic ERC1967I beacon proxy with `salt`.
    /// Deposits `value` ETH during deployment.
    /// Note: This method is intended for use in ERC4337 factories,
    /// which are expected to NOT revert if the proxy is already deployed.
    function createDeterministicERC1967IBeaconProxy(uint256 value, address beacon, bytes32 salt)
        internal
        returns (bool alreadyDeployed, address instance)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x60, 0x3d50545afa361460525736515af43d600060013e6052573d6001fd5b3d6001f3)
            mstore(0x40, 0x527fa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b3513)
            mstore(0x20, 0x60195155f3363d3d373d3d363d602036600436635c60da1b60e01b36)
            mstore(0x04, or(shl(160, 0x60573d8160223d3973), shr(96, shl(96, beacon))))
            // Compute and store the bytecode hash.
            mstore(add(m, 0x35), keccak256(0x07, 0x79))
            mstore(m, shl(88, address()))
            mstore8(m, 0xff) // Write the prefix.
            mstore(add(m, 0x15), salt)
            instance := keccak256(m, 0x55)
            for {} 1 {} {
                if iszero(extcodesize(instance)) {
                    instance := create2(value, 0x07, 0x79, salt)
                    if iszero(instance) {
                        mstore(0x00, 0x30116425) // `DeploymentFailed()`.
                        revert(0x1c, 0x04)
                    }
                    break
                }
                alreadyDeployed := 1
                if iszero(value) { break }
                if iszero(call(gas(), instance, value, codesize(), 0x00, codesize(), 0x00)) {
                    mstore(0x00, 0xb12d13eb) // `ETHTransferFailed()`.
                    revert(0x1c, 0x04)
                }
                break
            }
            mstore(0x40, m) // Restore the free memory pointer.
            mstore(0x60, 0) // Restore the zero slot.
        }
    }

    /// @dev Returns the initialization code of the ERC1967I beacon proxy.
    function initCodeERC1967IBeaconProxy(address beacon) internal pure returns (bytes memory c) {
        /// @solidity memory-safe-assembly
        assembly {
            c := mload(0x40)
            mstore(add(c, 0x79), 0x3d50545afa361460525736515af43d600060013e6052573d6001fd5b3d6001f3)
            mstore(add(c, 0x59), 0x527fa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b3513)
            mstore(add(c, 0x39), 0x60195155f3363d3d373d3d363d602036600436635c60da1b60e01b36)
            mstore(add(c, 0x1d), beacon)
            mstore(add(c, 0x09), 0x60573d8160223d3973)
            mstore(add(c, 0x99), 0)
            mstore(c, 0x79) // Store the length.
            mstore(0x40, add(c, 0xa0)) // Allocate memory.
        }
    }

    /// @dev Returns the initialization code hash of the ERC1967I beacon proxy.
    function initCodeHashERC1967IBeaconProxy(address beacon) internal pure returns (bytes32 hash) {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x60, 0x3d50545afa361460525736515af43d600060013e6052573d6001fd5b3d6001f3)
            mstore(0x40, 0x527fa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b3513)
            mstore(0x20, 0x60195155f3363d3d373d3d363d602036600436635c60da1b60e01b36)
            mstore(0x04, or(shl(160, 0x60573d8160223d3973), shr(96, shl(96, beacon))))
            hash := keccak256(0x07, 0x79)
            mstore(0x40, m) // Restore the free memory pointer.
            mstore(0x60, 0) // Restore the zero slot.
        }
    }

    /// @dev Returns the address of the ERC1967I beacon proxy, with `salt` by `deployer`.
    /// Note: The returned result has dirty upper 96 bits. Please clean if used in assembly.
    function predictDeterministicAddressERC1967IBeaconProxy(
        address beacon,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        bytes32 hash = initCodeHashERC1967IBeaconProxy(beacon);
        predicted = predictDeterministicAddress(hash, salt, deployer);
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*    ERC1967I BEACON PROXY WITH IMMUTABLE ARGS OPERATIONS    */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Deploys a ERC1967I beacon proxy with `args.
    function deployERC1967IBeaconProxy(address beacon, bytes memory args)
        internal
        returns (address instance)
    {
        instance = deployERC1967IBeaconProxy(0, beacon, args);
    }

    /// @dev Deploys a ERC1967I beacon proxy with `args.
    /// Deposits `value` ETH during deployment.
    function deployERC1967IBeaconProxy(uint256 value, address beacon, bytes memory args)
        internal
        returns (address instance)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            let n := mload(args)
            pop(staticcall(gas(), 4, add(args, 0x20), n, add(m, 0x90), n))
            mstore(add(m, 0x70), 0x3d50545afa361460525736515af43d600060013e6052573d6001fd5b3d6001f3)
            mstore(add(m, 0x50), 0x527fa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b3513)
            mstore(add(m, 0x30), 0x60195155f3363d3d373d3d363d602036600436635c60da1b60e01b36)
            mstore(add(m, 0x14), beacon)
            // Do a out-of-gas revert if `n` is greater than `0xffff - 0x57 = 0xffa8`.
            mstore(add(m, gt(n, 0xffa8)), add(0xfe6100573d8160233d3973, shl(56, n)))
            instance := create(value, add(m, 0x16), add(n, 0x7a))
            if iszero(instance) {
                mstore(0x00, 0x30116425) // `DeploymentFailed()`.
                revert(0x1c, 0x04)
            }
        }
    }

    /// @dev Deploys a deterministic ERC1967I beacon proxy with `args` and `salt`.
    function deployDeterministicERC1967IBeaconProxy(address beacon, bytes memory args, bytes32 salt)
        internal
        returns (address instance)
    {
        instance = deployDeterministicERC1967IBeaconProxy(0, beacon, args, salt);
    }

    /// @dev Deploys a deterministic ERC1967I beacon proxy with `args` and `salt`.
    /// Deposits `value` ETH during deployment.
    function deployDeterministicERC1967IBeaconProxy(
        uint256 value,
        address beacon,
        bytes memory args,
        bytes32 salt
    ) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            let n := mload(args)
            pop(staticcall(gas(), 4, add(args, 0x20), n, add(m, 0x90), n))
            mstore(add(m, 0x70), 0x3d50545afa361460525736515af43d600060013e6052573d6001fd5b3d6001f3)
            mstore(add(m, 0x50), 0x527fa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b3513)
            mstore(add(m, 0x30), 0x60195155f3363d3d373d3d363d602036600436635c60da1b60e01b36)
            mstore(add(m, 0x14), beacon)
            // Do a out-of-gas revert if `n` is greater than `0xffff - 0x57 = 0xffa8`.
            mstore(add(m, gt(n, 0xffa8)), add(0xfe6100573d8160233d3973, shl(56, n)))
            instance := create2(value, add(m, 0x16), add(n, 0x7a), salt)
            if iszero(instance) {
                mstore(0x00, 0x30116425) // `DeploymentFailed()`.
                revert(0x1c, 0x04)
            }
        }
    }

    /// @dev Creates a deterministic ERC1967I beacon proxy with `args` and `salt`.
    /// Note: This method is intended for use in ERC4337 factories,
    /// which are expected to NOT revert if the proxy is already deployed.
    function createDeterministicERC1967IBeaconProxy(address beacon, bytes memory args, bytes32 salt)
        internal
        returns (bool alreadyDeployed, address instance)
    {
        return createDeterministicERC1967IBeaconProxy(0, beacon, args, salt);
    }

    /// @dev Creates a deterministic ERC1967I beacon proxy with `args` and `salt`.
    /// Deposits `value` ETH during deployment.
    /// Note: This method is intended for use in ERC4337 factories,
    /// which are expected to NOT revert if the proxy is already deployed.
    function createDeterministicERC1967IBeaconProxy(
        uint256 value,
        address beacon,
        bytes memory args,
        bytes32 salt
    ) internal returns (bool alreadyDeployed, address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40)
            let n := mload(args)
            pop(staticcall(gas(), 4, add(args, 0x20), n, add(m, 0x90), n))
            mstore(add(m, 0x70), 0x3d50545afa361460525736515af43d600060013e6052573d6001fd5b3d6001f3)
            mstore(add(m, 0x50), 0x527fa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b3513)
            mstore(add(m, 0x30), 0x60195155f3363d3d373d3d363d602036600436635c60da1b60e01b36)
            mstore(add(m, 0x14), beacon)
            // Do a out-of-gas revert if `n` is greater than `0xffff - 0x57 = 0xffa8`.
            mstore(add(m, gt(n, 0xffa8)), add(0xfe6100573d8160233d3973, shl(56, n)))
            // Compute and store the bytecode hash.
            mstore8(0x00, 0xff) // Write the prefix.
            mstore(0x35, keccak256(add(m, 0x16), add(n, 0x7a)))
            mstore(0x01, shl(96, address()))
            mstore(0x15, salt)
            instance := keccak256(0x00, 0x55)
            for {} 1 {} {
                if iszero(extcodesize(instance)) {
                    instance := create2(value, add(m, 0x16), add(n, 0x7a), salt)
                    if iszero(instance) {
                        mstore(0x00, 0x30116425) // `DeploymentFailed()`.
                        revert(0x1c, 0x04)
                    }
                    break
                }
                alreadyDeployed := 1
                if iszero(value) { break }
                if iszero(call(gas(), instance, value, codesize(), 0x00, codesize(), 0x00)) {
                    mstore(0x00, 0xb12d13eb) // `ETHTransferFailed()`.
                    revert(0x1c, 0x04)
                }
                break
            }
            mstore(0x35, 0) // Restore the overwritten part of the free memory pointer.
        }
    }

    /// @dev Returns the initialization code of the ERC1967I beacon proxy with `args`.
    function initCodeERC1967IBeaconProxy(address beacon, bytes memory args)
        internal
        pure
        returns (bytes memory c)
    {
        /// @solidity memory-safe-assembly
        assembly {
            c := mload(0x40)
            let n := mload(args)
            // Do a out-of-gas revert if `n` is greater than `0xffff - 0x57 = 0xffa8`.
            returndatacopy(returndatasize(), returndatasize(), gt(n, 0xffa8))
            for { let i := 0 } lt(i, n) { i := add(i, 0x20) } {
                mstore(add(add(c, 0x9a), i), mload(add(add(args, 0x20), i)))
            }
            mstore(add(c, 0x7a), 0x3d50545afa361460525736515af43d600060013e6052573d6001fd5b3d6001f3)
            mstore(add(c, 0x5a), 0x527fa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b3513)
            mstore(add(c, 0x3a), 0x60195155f3363d3d373d3d363d602036600436635c60da1b60e01b36)
            mstore(add(c, 0x1e), beacon)
            mstore(add(c, 0x0a), add(0x6100573d8160233d3973, shl(56, n)))
            mstore(add(c, add(n, 0x9a)), 0)
            mstore(c, add(n, 0x7a)) // Store the length.
            mstore(0x40, add(c, add(n, 0xba))) // Allocate memory.
        }
    }

    /// @dev Returns the initialization code hash of the ERC1967I beacon proxy with `args`.
    function initCodeHashERC1967IBeaconProxy(address beacon, bytes memory args)
        internal
        pure
        returns (bytes32 hash)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let c := mload(0x40) // Cache the free memory pointer.
            let n := mload(args)
            // Do a out-of-gas revert if `n` is greater than `0xffff - 0x57 = 0xffa8`.
            returndatacopy(returndatasize(), returndatasize(), gt(n, 0xffa8))
            for { let i := 0 } lt(i, n) { i := add(i, 0x20) } {
                mstore(add(add(c, 0x90), i), mload(add(add(args, 0x20), i)))
            }
            mstore(add(c, 0x70), 0x3d50545afa361460525736515af43d600060013e6052573d6001fd5b3d6001f3)
            mstore(add(c, 0x50), 0x527fa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b3513)
            mstore(add(c, 0x30), 0x60195155f3363d3d373d3d363d602036600436635c60da1b60e01b36)
            mstore(add(c, 0x14), beacon)
            mstore(c, add(0x6100573d8160233d3973, shl(56, n)))
            hash := keccak256(add(c, 0x16), add(n, 0x7a))
        }
    }

    /// @dev Returns the address of the ERC1967I beacon proxy, with  `args` and salt` by `deployer`.
    /// Note: The returned result has dirty upper 96 bits. Please clean if used in assembly.
    function predictDeterministicAddressERC1967IBeaconProxy(
        address beacon,
        bytes memory args,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        bytes32 hash = initCodeHashERC1967IBeaconProxy(beacon, args);
        predicted = predictDeterministicAddress(hash, salt, deployer);
    }

    /// @dev Equivalent to `argsOnERC1967IBeaconProxy(instance, start, 2 ** 256 - 1)`.
    function argsOnERC1967IBeaconProxy(address instance)
        internal
        view
        returns (bytes memory args)
    {
        /// @solidity memory-safe-assembly
        assembly {
            args := mload(0x40)
            mstore(args, and(0xffffffffff, sub(extcodesize(instance), 0x57))) // Store the length.
            extcodecopy(instance, add(args, 0x20), 0x57, add(mload(args), 0x20))
            mstore(0x40, add(mload(args), add(args, 0x40))) // Allocate memory.
        }
    }

    /// @dev Equivalent to `argsOnERC1967IBeaconProxy(instance, start, 2 ** 256 - 1)`.
    function argsOnERC1967IBeaconProxy(address instance, uint256 start)
        internal
        view
        returns (bytes memory args)
    {
        /// @solidity memory-safe-assembly
        assembly {
            args := mload(0x40)
            let n := and(0xffffffffff, sub(extcodesize(instance), 0x57))
            extcodecopy(instance, add(args, 0x20), add(start, 0x57), add(n, 0x20))
            mstore(args, mul(sub(n, start), lt(start, n))) // Store the length.
            mstore(0x40, add(args, add(0x40, mload(args)))) // Allocate memory.
        }
    }

    /// @dev Returns a slice of the immutable arguments on `instance` from `start` to `end`.
    /// `start` and `end` will be clamped to the range `[0, args.length]`.
    /// The `instance` MUST be deployed via the ERC1967I beacon proxy with immutable args functions.
    /// Otherwise, the behavior is undefined.
    /// Out-of-gas reverts if `instance` does not have any code.
    function argsOnERC1967IBeaconProxy(address instance, uint256 start, uint256 end)
        internal
        view
        returns (bytes memory args)
    {
        /// @solidity memory-safe-assembly
        assembly {
            args := mload(0x40)
            if iszero(lt(end, 0xffff)) { end := 0xffff }
            let d := mul(sub(end, start), lt(start, end))
            extcodecopy(instance, args, add(start, 0x37), add(d, 0x20))
            if iszero(and(0xff, mload(add(args, d)))) {
                let n := sub(extcodesize(instance), 0x57)
                returndatacopy(returndatasize(), returndatasize(), shr(40, n))
                d := mul(gt(n, start), sub(d, mul(gt(end, n), sub(end, n))))
            }
            mstore(args, d) // Store the length.
            mstore(add(add(args, 0x20), d), 0) // Zeroize the slot after the bytes.
            mstore(0x40, add(add(args, 0x40), d)) // Allocate memory.
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      OTHER OPERATIONS                      */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns `address(0)` if the implementation address cannot be determined.
    function implementationOf(address instance) internal view returns (address result) {
        /// @solidity memory-safe-assembly
        assembly {
            for { extcodecopy(instance, 0x00, 0x00, 0x57) } 1 {} {
                if mload(0x2d) {
                    // ERC1967I and ERC1967IBeaconProxy detection.
                    if or(
                        eq(keccak256(0x00, 0x52), ERC1967I_CODE_HASH),
                        eq(keccak256(0x00, 0x57), ERC1967I_BEACON_PROXY_CODE_HASH)
                    ) {
                        pop(staticcall(gas(), instance, 0x00, 0x01, 0x00, 0x20))
                        result := mload(0x0c)
                        break
                    }
                }
                // 0age clone detection.
                result := mload(0x0b)
                codecopy(0x0b, codesize(), 0x14) // Zeroize the 20 bytes for the address.
                if iszero(xor(keccak256(0x00, 0x2c), CLONE_CODE_HASH)) { break }
                mstore(0x0b, result) // Restore the zeroized memory.
                // CWIA detection.
                result := mload(0x0a)
                codecopy(0x0a, codesize(), 0x14) // Zeroize the 20 bytes for the address.
                if iszero(xor(keccak256(0x00, 0x2d), CWIA_CODE_HASH)) { break }
                mstore(0x0a, result) // Restore the zeroized memory.
                // PUSH0 clone detection.
                result := mload(0x09)
                codecopy(0x09, codesize(), 0x14) // Zeroize the 20 bytes for the address.
                result := shr(xor(keccak256(0x00, 0x2d), PUSH0_CLONE_CODE_HASH), result)
                break
            }
            result := shr(96, result)
            mstore(0x37, 0) // Restore the overwritten part of the free memory pointer.
        }
    }

    /// @dev Returns the address when a contract with initialization code hash,
    /// `hash`, is deployed with `salt`, by `deployer`.
    /// Note: The returned result has dirty upper 96 bits. Please clean if used in assembly.
    function predictDeterministicAddress(bytes32 hash, bytes32 salt, address deployer)
        internal
        pure
        returns (address predicted)
    {
        /// @solidity memory-safe-assembly
        assembly {
            // Compute and store the bytecode hash.
            mstore8(0x00, 0xff) // Write the prefix.
            mstore(0x35, hash)
            mstore(0x01, shl(96, deployer))
            mstore(0x15, salt)
            predicted := keccak256(0x00, 0x55)
            mstore(0x35, 0) // Restore the overwritten part of the free memory pointer.
        }
    }

    /// @dev Requires that `salt` starts with either the zero address or `by`.
    function checkStartsWith(bytes32 salt, address by) internal pure {
        /// @solidity memory-safe-assembly
        assembly {
            // If the salt does not start with the zero address or `by`.
            if iszero(or(iszero(shr(96, salt)), eq(shr(96, shl(96, by)), shr(96, salt)))) {
                mstore(0x00, 0x0c4549ef) // `SaltDoesNotStartWith()`.
                revert(0x1c, 0x04)
            }
        }
    }

    /// @dev Returns the `bytes32` at `offset` in `args`, without any bounds checks.
    /// To load an address, you can use `address(bytes20(argLoad(args, offset)))`.
    function argLoad(bytes memory args, uint256 offset) internal pure returns (bytes32 result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := mload(add(add(args, 0x20), offset))
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {LibBytes} from "./LibBytes.sol";

/// @notice Library for converting numbers into strings and other string operations.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/LibString.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/LibString.sol)
///
/// @dev Note:
/// For performance and bytecode compactness, most of the string operations are restricted to
/// byte strings (7-bit ASCII), except where otherwise specified.
/// Usage of byte string operations on charsets with runes spanning two or more bytes
/// can lead to undefined behavior.
library LibString {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                          STRUCTS                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Goated string storage struct that totally MOGs, no cap, fr.
    /// Uses less gas and bytecode than Solidity's native string storage. It's meta af.
    /// Packs length with the first 31 bytes if <255 bytes, so it’s mad tight.
    struct StringStorage {
        bytes32 _spacer;
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                        CUSTOM ERRORS                       */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The length of the output is too small to contain all the hex digits.
    error HexLengthInsufficient();

    /// @dev The length of the string is more than 32 bytes.
    error TooBigForSmallString();

    /// @dev The input string must be a 7-bit ASCII.
    error StringNot7BitASCII();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         CONSTANTS                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The constant returned when the `search` is not found in the string.
    uint256 internal constant NOT_FOUND = type(uint256).max;

    /// @dev Lookup for '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'.
    uint128 internal constant ALPHANUMERIC_7_BIT_ASCII = 0x7fffffe07fffffe03ff000000000000;

    /// @dev Lookup for 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'.
    uint128 internal constant LETTERS_7_BIT_ASCII = 0x7fffffe07fffffe0000000000000000;

    /// @dev Lookup for 'abcdefghijklmnopqrstuvwxyz'.
    uint128 internal constant LOWERCASE_7_BIT_ASCII = 0x7fffffe000000000000000000000000;

    /// @dev Lookup for 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.
    uint128 internal constant UPPERCASE_7_BIT_ASCII = 0x7fffffe0000000000000000;

    /// @dev Lookup for '0123456789'.
    uint128 internal constant DIGITS_7_BIT_ASCII = 0x3ff000000000000;

    /// @dev Lookup for '0123456789abcdefABCDEF'.
    uint128 internal constant HEXDIGITS_7_BIT_ASCII = 0x7e0000007e03ff000000000000;

    /// @dev Lookup for '01234567'.
    uint128 internal constant OCTDIGITS_7_BIT_ASCII = 0xff000000000000;

    /// @dev Lookup for '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!"#$%&\'()*+,-./:;<=>?@[\\]^_`{|}~ \t\n\r\x0b\x0c'.
    uint128 internal constant PRINTABLE_7_BIT_ASCII = 0x7fffffffffffffffffffffff00003e00;

    /// @dev Lookup for '!"#$%&\'()*+,-./:;<=>?@[\\]^_`{|}~'.
    uint128 internal constant PUNCTUATION_7_BIT_ASCII = 0x78000001f8000001fc00fffe00000000;

    /// @dev Lookup for ' \t\n\r\x0b\x0c'.
    uint128 internal constant WHITESPACE_7_BIT_ASCII = 0x100003e00;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                 STRING STORAGE OPERATIONS                  */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Sets the value of the string storage `$` to `s`.
    function set(StringStorage storage $, string memory s) internal {
        LibBytes.set(bytesStorage($), bytes(s));
    }

    /// @dev Sets the value of the string storage `$` to `s`.
    function setCalldata(StringStorage storage $, string calldata s) internal {
        LibBytes.setCalldata(bytesStorage($), bytes(s));
    }

    /// @dev Sets the value of the string storage `$` to the empty string.
    function clear(StringStorage storage $) internal {
        delete $._spacer;
    }

    /// @dev Returns whether the value stored is `$` is the empty string "".
    function isEmpty(StringStorage storage $) internal view returns (bool) {
        return uint256($._spacer) & 0xff == uint256(0);
    }

    /// @dev Returns the length of the value stored in `$`.
    function length(StringStorage storage $) internal view returns (uint256) {
        return LibBytes.length(bytesStorage($));
    }

    /// @dev Returns the value stored in `$`.
    function get(StringStorage storage $) internal view returns (string memory) {
        return string(LibBytes.get(bytesStorage($)));
    }

    /// @dev Helper to cast `$` to a `BytesStorage`.
    function bytesStorage(StringStorage storage $)
        internal
        pure
        returns (LibBytes.BytesStorage storage casted)
    {
        /// @solidity memory-safe-assembly
        assembly {
            casted.slot := $.slot
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                     DECIMAL OPERATIONS                     */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns the base 10 decimal representation of `value`.
    function toString(uint256 value) internal pure returns (string memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            // The maximum value of a uint256 contains 78 digits (1 byte per digit), but
            // we allocate 0xa0 bytes to keep the free memory pointer 32-byte word aligned.
            // We will need 1 word for the trailing zeros padding, 1 word for the length,
            // and 3 words for a maximum of 78 digits.
            result := add(mload(0x40), 0x80)
            mstore(0x40, add(result, 0x20)) // Allocate memory.
            mstore(result, 0) // Zeroize the slot after the string.

            let end := result // Cache the end of the memory to calculate the length later.
            let w := not(0) // Tsk.
            // We write the string from rightmost digit to leftmost digit.
            // The following is essentially a do-while loop that also handles the zero case.
            for { let temp := value } 1 {} {
                result := add(result, w) // `sub(result, 1)`.
                // Store the character to the pointer.
                // The ASCII index of the '0' character is 48.
                mstore8(result, add(48, mod(temp, 10)))
                temp := div(temp, 10) // Keep dividing `temp` until zero.
                if iszero(temp) { break }
            }
            let n := sub(end, result)
            result := sub(result, 0x20) // Move the pointer 32 bytes back to make room for the length.
            mstore(result, n) // Store the length.
        }
    }

    /// @dev Returns the base 10 decimal representation of `value`.
    function toString(int256 value) internal pure returns (string memory result) {
        if (value >= 0) return toString(uint256(value));
        unchecked {
            result = toString(~uint256(value) + 1);
        }
        /// @solidity memory-safe-assembly
        assembly {
            // We still have some spare memory space on the left,
            // as we have allocated 3 words (96 bytes) for up to 78 digits.
            let n := mload(result) // Load the string length.
            mstore(result, 0x2d) // Store the '-' character.
            result := sub(result, 1) // Move back the string pointer by a byte.
            mstore(result, add(n, 1)) // Update the string length.
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                   HEXADECIMAL OPERATIONS                   */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns the hexadecimal representation of `value`,
    /// left-padded to an input length of `byteCount` bytes.
    /// The output is prefixed with "0x" encoded using 2 hexadecimal digits per byte,
    /// giving a total length of `byteCount * 2 + 2` bytes.
    /// Reverts if `byteCount` is too small for the output to contain all the digits.
    function toHexString(uint256 value, uint256 byteCount)
        internal
        pure
        returns (string memory result)
    {
        result = toHexStringNoPrefix(value, byteCount);
        /// @solidity memory-safe-assembly
        assembly {
            let n := add(mload(result), 2) // Compute the length.
            mstore(result, 0x3078) // Store the "0x" prefix.
            result := sub(result, 2) // Move the pointer.
            mstore(result, n) // Store the length.
        }
    }

    /// @dev Returns the hexadecimal representation of `value`,
    /// left-padded to an input length of `byteCount` bytes.
    /// The output is not prefixed with "0x" and is encoded using 2 hexadecimal digits per byte,
    /// giving a total length of `byteCount * 2` bytes.
    /// Reverts if `byteCount` is too small for the output to contain all the digits.
    function toHexStringNoPrefix(uint256 value, uint256 byteCount)
        internal
        pure
        returns (string memory result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            // We need 0x20 bytes for the trailing zeros padding, `byteCount * 2` bytes
            // for the digits, 0x02 bytes for the prefix, and 0x20 bytes for the length.
            // We add 0x20 to the total and round down to a multiple of 0x20.
            // (0x20 + 0x20 + 0x02 + 0x20) = 0x62.
            result := add(mload(0x40), and(add(shl(1, byteCount), 0x42), not(0x1f)))
            mstore(0x40, add(result, 0x20)) // Allocate memory.
            mstore(result, 0) // Zeroize the slot after the string.

            let end := result // Cache the end to calculate the length later.
            // Store "0123456789abcdef" in scratch space.
            mstore(0x0f, 0x30313233343536373839616263646566)

            let start := sub(result, add(byteCount, byteCount))
            let w := not(1) // Tsk.
            let temp := value
            // We write the string from rightmost digit to leftmost digit.
            // The following is essentially a do-while loop that also handles the zero case.
            for {} 1 {} {
                result := add(result, w) // `sub(result, 2)`.
                mstore8(add(result, 1), mload(and(temp, 15)))
                mstore8(result, mload(and(shr(4, temp), 15)))
                temp := shr(8, temp)
                if iszero(xor(result, start)) { break }
            }
            if temp {
                mstore(0x00, 0x2194895a) // `HexLengthInsufficient()`.
                revert(0x1c, 0x04)
            }
            let n := sub(end, result)
            result := sub(result, 0x20)
            mstore(result, n) // Store the length.
        }
    }

    /// @dev Returns the hexadecimal representation of `value`.
    /// The output is prefixed with "0x" and encoded using 2 hexadecimal digits per byte.
    /// As address are 20 bytes long, the output will left-padded to have
    /// a length of `20 * 2 + 2` bytes.
    function toHexString(uint256 value) internal pure returns (string memory result) {
        result = toHexStringNoPrefix(value);
        /// @solidity memory-safe-assembly
        assembly {
            let n := add(mload(result), 2) // Compute the length.
            mstore(result, 0x3078) // Store the "0x" prefix.
            result := sub(result, 2) // Move the pointer.
            mstore(result, n) // Store the length.
        }
    }

    /// @dev Returns the hexadecimal representation of `value`.
    /// The output is prefixed with "0x".
    /// The output excludes leading "0" from the `toHexString` output.
    /// `0x00: "0x0", 0x01: "0x1", 0x12: "0x12", 0x123: "0x123"`.
    function toMinimalHexString(uint256 value) internal pure returns (string memory result) {
        result = toHexStringNoPrefix(value);
        /// @solidity memory-safe-assembly
        assembly {
            let o := eq(byte(0, mload(add(result, 0x20))), 0x30) // Whether leading zero is present.
            let n := add(mload(result), 2) // Compute the length.
            mstore(add(result, o), 0x3078) // Store the "0x" prefix, accounting for leading zero.
            result := sub(add(result, o), 2) // Move the pointer, accounting for leading zero.
            mstore(result, sub(n, o)) // Store the length, accounting for leading zero.
        }
    }

    /// @dev Returns the hexadecimal representation of `value`.
    /// The output excludes leading "0" from the `toHexStringNoPrefix` output.
    /// `0x00: "0", 0x01: "1", 0x12: "12", 0x123: "123"`.
    function toMinimalHexStringNoPrefix(uint256 value)
        internal
        pure
        returns (string memory result)
    {
        result = toHexStringNoPrefix(value);
        /// @solidity memory-safe-assembly
        assembly {
            let o := eq(byte(0, mload(add(result, 0x20))), 0x30) // Whether leading zero is present.
            let n := mload(result) // Get the length.
            result := add(result, o) // Move the pointer, accounting for leading zero.
            mstore(result, sub(n, o)) // Store the length, accounting for leading zero.
        }
    }

    /// @dev Returns the hexadecimal representation of `value`.
    /// The output is encoded using 2 hexadecimal digits per byte.
    /// As address are 20 bytes long, the output will left-padded to have
    /// a length of `20 * 2` bytes.
    function toHexStringNoPrefix(uint256 value) internal pure returns (string memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            // We need 0x20 bytes for the trailing zeros padding, 0x20 bytes for the length,
            // 0x02 bytes for the prefix, and 0x40 bytes for the digits.
            // The next multiple of 0x20 above (0x20 + 0x20 + 0x02 + 0x40) is 0xa0.
            result := add(mload(0x40), 0x80)
            mstore(0x40, add(result, 0x20)) // Allocate memory.
            mstore(result, 0) // Zeroize the slot after the string.

            let end := result // Cache the end to calculate the length later.
            mstore(0x0f, 0x30313233343536373839616263646566) // Store the "0123456789abcdef" lookup.

            let w := not(1) // Tsk.
            // We write the string from rightmost digit to leftmost digit.
            // The following is essentially a do-while loop that also handles the zero case.
            for { let temp := value } 1 {} {
                result := add(result, w) // `sub(result, 2)`.
                mstore8(add(result, 1), mload(and(temp, 15)))
                mstore8(result, mload(and(shr(4, temp), 15)))
                temp := shr(8, temp)
                if iszero(temp) { break }
            }
            let n := sub(end, result)
            result := sub(result, 0x20)
            mstore(result, n) // Store the length.
        }
    }

    /// @dev Returns the hexadecimal representation of `value`.
    /// The output is prefixed with "0x", encoded using 2 hexadecimal digits per byte,
    /// and the alphabets are capitalized conditionally according to
    /// https://eips.ethereum.org/EIPS/eip-55
    function toHexStringChecksummed(address value) internal pure returns (string memory result) {
        result = toHexString(value);
        /// @solidity memory-safe-assembly
        assembly {
            let mask := shl(6, div(not(0), 255)) // `0b010000000100000000 ...`
            let o := add(result, 0x22)
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
    function toHexString(address value) internal pure returns (string memory result) {
        result = toHexStringNoPrefix(value);
        /// @solidity memory-safe-assembly
        assembly {
            let n := add(mload(result), 2) // Compute the length.
            mstore(result, 0x3078) // Store the "0x" prefix.
            result := sub(result, 2) // Move the pointer.
            mstore(result, n) // Store the length.
        }
    }

    /// @dev Returns the hexadecimal representation of `value`.
    /// The output is encoded using 2 hexadecimal digits per byte.
    function toHexStringNoPrefix(address value) internal pure returns (string memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := mload(0x40)
            // Allocate memory.
            // We need 0x20 bytes for the trailing zeros padding, 0x20 bytes for the length,
            // 0x02 bytes for the prefix, and 0x28 bytes for the digits.
            // The next multiple of 0x20 above (0x20 + 0x20 + 0x02 + 0x28) is 0x80.
            mstore(0x40, add(result, 0x80))
            mstore(0x0f, 0x30313233343536373839616263646566) // Store the "0123456789abcdef" lookup.

            result := add(result, 2)
            mstore(result, 40) // Store the length.
            let o := add(result, 0x20)
            mstore(add(o, 40), 0) // Zeroize the slot after the string.
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
    function toHexString(bytes memory raw) internal pure returns (string memory result) {
        result = toHexStringNoPrefix(raw);
        /// @solidity memory-safe-assembly
        assembly {
            let n := add(mload(result), 2) // Compute the length.
            mstore(result, 0x3078) // Store the "0x" prefix.
            result := sub(result, 2) // Move the pointer.
            mstore(result, n) // Store the length.
        }
    }

    /// @dev Returns the hex encoded string from the raw bytes.
    /// The output is encoded using 2 hexadecimal digits per byte.
    function toHexStringNoPrefix(bytes memory raw) internal pure returns (string memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            let n := mload(raw)
            result := add(mload(0x40), 2) // Skip 2 bytes for the optional prefix.
            mstore(result, add(n, n)) // Store the length of the output.

            mstore(0x0f, 0x30313233343536373839616263646566) // Store the "0123456789abcdef" lookup.
            let o := add(result, 0x20)
            let end := add(raw, n)
            for {} iszero(eq(raw, end)) {} {
                raw := add(raw, 1)
                mstore8(add(o, 1), mload(and(mload(raw), 15)))
                mstore8(o, mload(and(shr(4, mload(raw)), 15)))
                o := add(o, 2)
            }
            mstore(o, 0) // Zeroize the slot after the string.
            mstore(0x40, add(o, 0x20)) // Allocate memory.
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
            result := 1
            let mask := shl(7, div(not(0), 255))
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

    /// @dev Returns if this string is a 7-bit ASCII string,
    /// AND all characters are in the `allowed` lookup.
    /// Note: If `s` is empty, returns true regardless of `allowed`.
    function is7BitASCII(string memory s, uint128 allowed) internal pure returns (bool result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := 1
            if mload(s) {
                let allowed_ := shr(128, shl(128, allowed))
                let o := add(s, 0x20)
                for { let end := add(o, mload(s)) } 1 {} {
                    result := and(result, shr(byte(0, mload(o)), allowed_))
                    o := add(o, 1)
                    if iszero(and(result, lt(o, end))) { break }
                }
            }
        }
    }

    /// @dev Converts the bytes in the 7-bit ASCII string `s` to
    /// an allowed lookup for use in `is7BitASCII(s, allowed)`.
    /// To save runtime gas, you can cache the result in an immutable variable.
    function to7BitASCIIAllowedLookup(string memory s) internal pure returns (uint128 result) {
        /// @solidity memory-safe-assembly
        assembly {
            if mload(s) {
                let o := add(s, 0x20)
                for { let end := add(o, mload(s)) } 1 {} {
                    result := or(result, shl(byte(0, mload(o)), 1))
                    o := add(o, 1)
                    if iszero(lt(o, end)) { break }
                }
                if shr(128, result) {
                    mstore(0x00, 0xc9807e0d) // `StringNot7BitASCII()`.
                    revert(0x1c, 0x04)
                }
            }
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                   BYTE STRING OPERATIONS                   */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // For performance and bytecode compactness, byte string operations are restricted
    // to 7-bit ASCII strings. All offsets are byte offsets, not UTF character offsets.
    // Usage of byte string operations on charsets with runes spanning two or more bytes
    // can lead to undefined behavior.

    /// @dev Returns `subject` all occurrences of `needle` replaced with `replacement`.
    function replace(string memory subject, string memory needle, string memory replacement)
        internal
        pure
        returns (string memory)
    {
        return string(LibBytes.replace(bytes(subject), bytes(needle), bytes(replacement)));
    }

    /// @dev Returns the byte index of the first location of `needle` in `subject`,
    /// needleing from left to right, starting from `from`.
    /// Returns `NOT_FOUND` (i.e. `type(uint256).max`) if the `needle` is not found.
    function indexOf(string memory subject, string memory needle, uint256 from)
        internal
        pure
        returns (uint256)
    {
        return LibBytes.indexOf(bytes(subject), bytes(needle), from);
    }

    /// @dev Returns the byte index of the first location of `needle` in `subject`,
    /// needleing from left to right.
    /// Returns `NOT_FOUND` (i.e. `type(uint256).max`) if the `needle` is not found.
    function indexOf(string memory subject, string memory needle) internal pure returns (uint256) {
        return LibBytes.indexOf(bytes(subject), bytes(needle), 0);
    }

    /// @dev Returns the byte index of the first location of `needle` in `subject`,
    /// needleing from right to left, starting from `from`.
    /// Returns `NOT_FOUND` (i.e. `type(uint256).max`) if the `needle` is not found.
    function lastIndexOf(string memory subject, string memory needle, uint256 from)
        internal
        pure
        returns (uint256)
    {
        return LibBytes.lastIndexOf(bytes(subject), bytes(needle), from);
    }

    /// @dev Returns the byte index of the first location of `needle` in `subject`,
    /// needleing from right to left.
    /// Returns `NOT_FOUND` (i.e. `type(uint256).max`) if the `needle` is not found.
    function lastIndexOf(string memory subject, string memory needle)
        internal
        pure
        returns (uint256)
    {
        return LibBytes.lastIndexOf(bytes(subject), bytes(needle), type(uint256).max);
    }

    /// @dev Returns true if `needle` is found in `subject`, false otherwise.
    function contains(string memory subject, string memory needle) internal pure returns (bool) {
        return LibBytes.contains(bytes(subject), bytes(needle));
    }

    /// @dev Returns whether `subject` starts with `needle`.
    function startsWith(string memory subject, string memory needle) internal pure returns (bool) {
        return LibBytes.startsWith(bytes(subject), bytes(needle));
    }

    /// @dev Returns whether `subject` ends with `needle`.
    function endsWith(string memory subject, string memory needle) internal pure returns (bool) {
        return LibBytes.endsWith(bytes(subject), bytes(needle));
    }

    /// @dev Returns `subject` repeated `times`.
    function repeat(string memory subject, uint256 times) internal pure returns (string memory) {
        return string(LibBytes.repeat(bytes(subject), times));
    }

    /// @dev Returns a copy of `subject` sliced from `start` to `end` (exclusive).
    /// `start` and `end` are byte offsets.
    function slice(string memory subject, uint256 start, uint256 end)
        internal
        pure
        returns (string memory)
    {
        return string(LibBytes.slice(bytes(subject), start, end));
    }

    /// @dev Returns a copy of `subject` sliced from `start` to the end of the string.
    /// `start` is a byte offset.
    function slice(string memory subject, uint256 start) internal pure returns (string memory) {
        return string(LibBytes.slice(bytes(subject), start, type(uint256).max));
    }

    /// @dev Returns all the indices of `needle` in `subject`.
    /// The indices are byte offsets.
    function indicesOf(string memory subject, string memory needle)
        internal
        pure
        returns (uint256[] memory)
    {
        return LibBytes.indicesOf(bytes(subject), bytes(needle));
    }

    /// @dev Returns a arrays of strings based on the `delimiter` inside of the `subject` string.
    function split(string memory subject, string memory delimiter)
        internal
        pure
        returns (string[] memory result)
    {
        bytes[] memory a = LibBytes.split(bytes(subject), bytes(delimiter));
        /// @solidity memory-safe-assembly
        assembly {
            result := a
        }
    }

    /// @dev Returns a concatenated string of `a` and `b`.
    /// Cheaper than `string.concat()` and does not de-align the free memory pointer.
    function concat(string memory a, string memory b) internal pure returns (string memory) {
        return string(LibBytes.concat(bytes(a), bytes(b)));
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
            let n := mload(subject)
            if n {
                result := mload(0x40)
                let o := add(result, 0x20)
                let d := sub(subject, result)
                let flags := shl(add(70, shl(5, toUpper)), 0x3ffffff)
                for { let end := add(o, n) } 1 {} {
                    let b := byte(0, mload(add(d, o)))
                    mstore8(o, xor(and(shr(b, flags), 0x20), b))
                    o := add(o, 1)
                    if eq(o, end) { break }
                }
                mstore(result, n) // Store the length.
                mstore(o, 0) // Zeroize the slot after the string.
                mstore(0x40, add(o, 0x20)) // Allocate memory.
            }
        }
    }

    /// @dev Returns a string from a small bytes32 string.
    /// `s` must be null-terminated, or behavior will be undefined.
    function fromSmallString(bytes32 s) internal pure returns (string memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := mload(0x40)
            let n := 0
            for {} byte(n, s) { n := add(n, 1) } {} // Scan for '\0'.
            mstore(result, n) // Store the length.
            let o := add(result, 0x20)
            mstore(o, s) // Store the bytes of the string.
            mstore(add(o, n), 0) // Zeroize the slot after the string.
            mstore(0x40, add(result, 0x40)) // Allocate memory.
        }
    }

    /// @dev Returns the small string, with all bytes after the first null byte zeroized.
    function normalizeSmallString(bytes32 s) internal pure returns (bytes32 result) {
        /// @solidity memory-safe-assembly
        assembly {
            for {} byte(result, s) { result := add(result, 1) } {} // Scan for '\0'.
            mstore(0x00, s)
            mstore(result, 0x00)
            result := mload(0x00)
        }
    }

    /// @dev Returns the string as a normalized null-terminated small string.
    function toSmallString(string memory s) internal pure returns (bytes32 result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := mload(s)
            if iszero(lt(result, 33)) {
                mstore(0x00, 0xec92f9a3) // `TooBigForSmallString()`.
                revert(0x1c, 0x04)
            }
            result := shl(shl(3, sub(32, result)), mload(add(s, result)))
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
            result := mload(0x40)
            let end := add(s, mload(s))
            let o := add(result, 0x20)
            // Store the bytes of the packed offsets and strides into the scratch space.
            // `packed = (stride << 5) | offset`. Max offset is 20. Max stride is 6.
            mstore(0x1f, 0x900094)
            mstore(0x08, 0xc0000000a6ab)
            // Store "&quot;&amp;&#39;&lt;&gt;" into the scratch space.
            mstore(0x00, shl(64, 0x2671756f743b26616d703b262333393b266c743b2667743b))
            for {} iszero(eq(s, end)) {} {
                s := add(s, 1)
                let c := and(mload(s), 0xff)
                // Not in `["\"","'","&","<",">"]`.
                if iszero(and(shl(c, 1), 0x500000c400000000)) {
                    mstore8(o, c)
                    o := add(o, 1)
                    continue
                }
                let t := shr(248, mload(c))
                mstore(o, mload(and(t, 0x1f)))
                o := add(o, shr(5, t))
            }
            mstore(o, 0) // Zeroize the slot after the string.
            mstore(result, sub(o, add(result, 0x20))) // Store the length.
            mstore(0x40, add(o, 0x20)) // Allocate memory.
        }
    }

    /// @dev Escapes the string to be used within double-quotes in a JSON.
    /// If `addDoubleQuotes` is true, the result will be enclosed in double-quotes.
    function escapeJSON(string memory s, bool addDoubleQuotes)
        internal
        pure
        returns (string memory result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            result := mload(0x40)
            let o := add(result, 0x20)
            if addDoubleQuotes {
                mstore8(o, 34)
                o := add(1, o)
            }
            // Store "\\u0000" in scratch space.
            // Store "0123456789abcdef" in scratch space.
            // Also, store `{0x08:"b", 0x09:"t", 0x0a:"n", 0x0c:"f", 0x0d:"r"}`.
            // into the scratch space.
            mstore(0x15, 0x5c75303030303031323334353637383961626364656662746e006672)
            // Bitmask for detecting `["\"","\\"]`.
            let e := or(shl(0x22, 1), shl(0x5c, 1))
            for { let end := add(s, mload(s)) } iszero(eq(s, end)) {} {
                s := add(s, 1)
                let c := and(mload(s), 0xff)
                if iszero(lt(c, 0x20)) {
                    if iszero(and(shl(c, 1), e)) {
                        // Not in `["\"","\\"]`.
                        mstore8(o, c)
                        o := add(o, 1)
                        continue
                    }
                    mstore8(o, 0x5c) // "\\".
                    mstore8(add(o, 1), c)
                    o := add(o, 2)
                    continue
                }
                if iszero(and(shl(c, 1), 0x3700)) {
                    // Not in `["\b","\t","\n","\f","\d"]`.
                    mstore8(0x1d, mload(shr(4, c))) // Hex value.
                    mstore8(0x1e, mload(and(c, 15))) // Hex value.
                    mstore(o, mload(0x19)) // "\\u00XX".
                    o := add(o, 6)
                    continue
                }
                mstore8(o, 0x5c) // "\\".
                mstore8(add(o, 1), mload(add(c, 8)))
                o := add(o, 2)
            }
            if addDoubleQuotes {
                mstore8(o, 34)
                o := add(1, o)
            }
            mstore(o, 0) // Zeroize the slot after the string.
            mstore(result, sub(o, add(result, 0x20))) // Store the length.
            mstore(0x40, add(o, 0x20)) // Allocate memory.
        }
    }

    /// @dev Escapes the string to be used within double-quotes in a JSON.
    function escapeJSON(string memory s) internal pure returns (string memory result) {
        result = escapeJSON(s, false);
    }

    /// @dev Encodes `s` so that it can be safely used in a URI,
    /// just like `encodeURIComponent` in JavaScript.
    /// See: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/encodeURIComponent
    /// See: https://datatracker.ietf.org/doc/html/rfc2396
    /// See: https://datatracker.ietf.org/doc/html/rfc3986
    function encodeURIComponent(string memory s) internal pure returns (string memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := mload(0x40)
            // Store "0123456789ABCDEF" in scratch space.
            // Uppercased to be consistent with JavaScript's implementation.
            mstore(0x0f, 0x30313233343536373839414243444546)
            let o := add(result, 0x20)
            for { let end := add(s, mload(s)) } iszero(eq(s, end)) {} {
                s := add(s, 1)
                let c := and(mload(s), 0xff)
                // If not in `[0-9A-Z-a-z-_.!~*'()]`.
                if iszero(and(1, shr(c, 0x47fffffe87fffffe03ff678200000000))) {
                    mstore8(o, 0x25) // '%'.
                    mstore8(add(o, 1), mload(and(shr(4, c), 15)))
                    mstore8(add(o, 2), mload(and(c, 15)))
                    o := add(o, 3)
                    continue
                }
                mstore8(o, c)
                o := add(o, 1)
            }
            mstore(result, sub(o, add(result, 0x20))) // Store the length.
            mstore(o, 0) // Zeroize the slot after the string.
            mstore(0x40, add(o, 0x20)) // Allocate memory.
        }
    }

    /// @dev Returns whether `a` equals `b`.
    function eq(string memory a, string memory b) internal pure returns (bool result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := eq(keccak256(add(a, 0x20), mload(a)), keccak256(add(b, 0x20), mload(b)))
        }
    }

    /// @dev Returns whether `a` equals `b`, where `b` is a null-terminated small string.
    function eqs(string memory a, bytes32 b) internal pure returns (bool result) {
        /// @solidity memory-safe-assembly
        assembly {
            // These should be evaluated on compile time, as far as possible.
            let m := not(shl(7, div(not(iszero(b)), 255))) // `0x7f7f ...`.
            let x := not(or(m, or(b, add(m, and(b, m)))))
            let r := shl(7, iszero(iszero(shr(128, x))))
            r := or(r, shl(6, iszero(iszero(shr(64, shr(r, x))))))
            r := or(r, shl(5, lt(0xffffffff, shr(r, x))))
            r := or(r, shl(4, lt(0xffff, shr(r, x))))
            r := or(r, shl(3, lt(0xff, shr(r, x))))
            // forgefmt: disable-next-item
            result := gt(eq(mload(a), add(iszero(x), xor(31, shr(3, r)))),
                xor(shr(add(8, r), b), shr(add(8, r), mload(add(a, 0x20)))))
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
    /// If `packed` is not an output of {packOne}, the output behavior is undefined.
    function unpackOne(bytes32 packed) internal pure returns (string memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := mload(0x40) // Grab the free memory pointer.
            mstore(0x40, add(result, 0x40)) // Allocate 2 words (1 for the length, 1 for the bytes).
            mstore(result, 0) // Zeroize the length slot.
            mstore(add(result, 0x1f), packed) // Store the length and bytes.
            mstore(add(add(result, 0x20), mload(result)), 0) // Right pad with zeroes.
        }
    }

    /// @dev Packs two strings with their lengths into a single word.
    /// Returns `bytes32(0)` if combined length is zero or greater than 30.
    function packTwo(string memory a, string memory b) internal pure returns (bytes32 result) {
        /// @solidity memory-safe-assembly
        assembly {
            let aLen := mload(a)
            // We don't need to zero right pad the strings,
            // since this is our own custom non-standard packing scheme.
            result :=
                mul(
                    or( // Load the length and the bytes of `a` and `b`.
                    shl(shl(3, sub(0x1f, aLen)), mload(add(a, aLen))), mload(sub(add(b, 0x1e), aLen))),
                    // `totalLen != 0 && totalLen < 31`. Abuses underflow.
                    // Assumes that the lengths are valid and within the block gas limit.
                    lt(sub(add(aLen, mload(b)), 1), 0x1e)
                )
        }
    }

    /// @dev Unpacks strings packed using {packTwo}.
    /// Returns the empty strings if `packed` is `bytes32(0)`.
    /// If `packed` is not an output of {packTwo}, the output behavior is undefined.
    function unpackTwo(bytes32 packed)
        internal
        pure
        returns (string memory resultA, string memory resultB)
    {
        /// @solidity memory-safe-assembly
        assembly {
            resultA := mload(0x40) // Grab the free memory pointer.
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
            let retUnpaddedSize := add(mload(a), 0x40)
            // Right pad with zeroes. Just in case the string is produced
            // by a method that doesn't zero right pad.
            mstore(add(retStart, retUnpaddedSize), 0)
            mstore(retStart, 0x20) // Store the return offset.
            // End the transaction, returning the string.
            return(retStart, and(not(0x1f), add(0x1f, retUnpaddedSize)))
        }
    }
}
// SPDX-License-Identifier: VPL - VIRAL PUBLIC LICENSE
pragma solidity ^0.8.25;

function _allocateBytes(uint256 len) pure returns (bytes memory ret) {
    assembly {
        ret := mload(0x40)

        // new "memory end" including padding
        mstore(0x40, add(ret, and(add(add(len, 0x20), 0x1f), not(0x1f))))

        mstore(ret, len)
    }
}

function _allocateString(uint256 len) pure returns (string memory ret) {
    assembly {
        ret := mload(0x40)

        // new "memory end" including padding
        mstore(0x40, add(ret, and(add(add(len, 0x20), 0x1f), not(0x1f))))

        mstore(ret, len)
    }
}

function _allocateArr(uint256 len) pure returns (bytes[] memory ret) {
    assembly {
        ret := mload(0x40)

        // new "memory end" including padding
        mstore(0x40, add(ret, and(add(add(mul(len, 0x20), 0x20), 0x1f), not(0x1f))))
        mstore(ret, len)
    }
}

function _allocateStringArr(uint256 len) pure returns (string[] memory ret) {
    assembly {
        ret := mload(0x40)

        // new "memory end" including padding
        mstore(0x40, add(ret, and(add(add(mul(len, 0x20), 0x20), 0x1f), not(0x1f))))
        mstore(ret, len)
    }
}

function _allocateUintArr(uint256 len) pure returns (uint256[] memory ret) {
    assembly {
        ret := mload(0x40)

        // new "memory end" including padding
        mstore(0x40, add(ret, and(add(add(mul(len, 0x20), 0x20), 0x1f), not(0x1f))))

        mstore(ret, len)
    }
}

function _allocateIntArr(uint256 len) pure returns (int256[] memory ret) {
    assembly {
        ret := mload(0x40)

        // new "memory end" including padding
        mstore(0x40, add(ret, and(add(add(mul(len, 0x20), 0x20), 0x1f), not(0x1f))))

        mstore(ret, len)
    }
}

function _allocateAddressArr(uint256 len) pure returns (address[] memory ret) {
    assembly {
        ret := mload(0x40)

        // new "memory end" including padding
        mstore(0x40, add(ret, and(add(add(mul(len, 0x20), 0x20), 0x1f), not(0x1f))))

        mstore(ret, len)
    }
}
// SPDX-License-Identifier: VPL - VIRAL PUBLIC LICENSE
pragma solidity ^0.8.25;

import "./Allocate.sol";

// cheaper than bytes concat :)
function _append(bytes memory dst, bytes memory src) pure {
    assembly {
        // resize

        let priorLength := mload(dst)

        mstore(dst, add(priorLength, mload(src)))

        // copy
        mcopy(add(dst, add(0x20, priorLength)), add(src, 0x20), mload(src))
    }
}

// assumes dev is not stupid and startIdx < endIdx
function _appendSubstring(bytes memory dst, bytes memory src, uint256 startIdx, uint256 endIdx) pure {
    assembly {
        // resize

        let priorLength := mload(dst)
        let substringLength := sub(endIdx, startIdx)
        mstore(dst, add(priorLength, substringLength))

        // copy
        mcopy(add(dst, add(0x20, priorLength)), add(src, add(0x20, startIdx)), substringLength)
    }
}

function _tail(bytes memory subject) pure returns (bytes memory ret) {
    uint256 length = subject.length;
    if (length < 1) return ret;
    unchecked {
        ret = _allocateBytes(length - 1);
    } // uc
    assembly {
        mstore(ret, 0)
    }
    _appendSubstring(ret, subject, 1, length);
}
// SPDX-License-Identifier: VPL - VIRAL PUBLIC LICENSE
pragma solidity ^0.8.25;

import "./Append.sol";
import "./Structs.sol";
import "./Errors.sol";
import "./MemoryMappings.sol";

import "./LibDynamicThing.sol";

function toBytes32(bytes memory b) pure returns (bytes32 ret) {
    assembly {
        ret := mload(add(b, 0x20))
    }
}

function toBytes(bytes32 b32) pure returns (bytes memory ret) {
    ret = _allocateBytes(32);
    assembly {
        mstore(add(ret, 0x20), b32)
    }
}

function allAreDistinct(uint256[] memory arr) pure returns (bool) {
    // note: may not be ordered! so have to use map!
    MemoryMappings.MemoryMapping memory m = MemoryMappings.newMemoryMapping({overwrite: false, sorted: false});
    for (uint256 i; i < arr.length; ++i) {
        MemoryMappings.add(m, bytes32(arr[i]), bytes32(0));
    }
    return arr.length == m.totalKeys;
}

// shoutout vectorized!
function hashArr(uint256[] memory arr) pure returns (bytes32 result) {
    assembly {
        result := keccak256(add(arr, 0x20), shl(5, mload(arr)))
    }
}

function _concat(bytes memory a, bytes memory b) pure returns (bytes memory ret) {
    unchecked {
        ret = _allocateBytes(a.length + b.length);
        assembly {
            mstore(ret, 0)
        }
        _append(ret, a);
        _append(ret, b);
    } // uc
}

function typeToString(Type t) pure returns (string memory ret) {
    if (t == Type.NONE) {
        ret = "NONE";
    } else if (t == Type.TAB) {
        ret = "TAB";
    } else if (t == Type.TAB_ENCRYPTED) {
        ret = "TAB_ENCRYPTED";
    } else if (t == Type.FRAME) {
        ret = "FRAME";
    } else if (t == Type.FRAME_ENCRYPTED) {
        ret = "FRAME_ENCRYPTED";
    } else if (t == Type.COLLECTION) {
        ret = "COLLECTION";
    } else if (t == Type.COLLECTION_ENCRYPTED) {
        ret = "COLLECTION_ENCRYPTED";
    } else {
        revert Unsupported_error();
    }
}

function typeToStringDECRYPTED(Type t) pure returns (string memory ret) {
    if (t == Type.NONE) {
        ret = "NONE";
    } else if (t == Type.TAB) {
        ret = "TAB";
    } else if (t == Type.TAB_ENCRYPTED) {
        ret = "TAB_DECRYPTED";
    } else if (t == Type.FRAME) {
        ret = "FRAME";
    } else if (t == Type.FRAME_ENCRYPTED) {
        ret = "FRAME_DECRYPTED";
    } else if (t == Type.COLLECTION) {
        ret = "COLLECTION";
    } else if (t == Type.COLLECTION_ENCRYPTED) {
        ret = "COLLECTION_DECRYPTED";
    } else {
        revert Unsupported_error();
    }
}

function validityToString(Validity v) pure returns (string memory ret) {
    if (v == Validity.UNKNOWN) {
        ret = "UNKNOWN";
    } else if (v == Validity.PENDING_DECRYPTION) {
        ret = "PENDING_DECRYPTION";
    } else if (v == Validity.VALID) {
        ret = "VALID";
    } else if (v == Validity.INVALID) {
        ret = "INVALID";
    } else {
        revert Unsupported_error();
    }
}

function boolToString(bool tf) pure returns (string memory ret) {
    if (tf) return "true";
    return "false";
}

// single split is more efficient than others
function _splitBy(bytes memory data, bytes8 rune) pure returns (bool ok, bytes[2] memory ret) {
    unchecked {
        for (uint256 i; i < data.length; ++i) {
            if (data[i] == rune) {
                bytes memory start = _allocateBytes(i);
                assembly {
                    mstore(start, 0)
                }
                _appendSubstring(start, data, 0, i);
                ret[0] = start;

                bytes memory finish = _allocateBytes(data.length - i);
                assembly {
                    mstore(finish, 0)
                }
                _appendSubstring(finish, data, i + 1, data.length);
                ret[1] = finish;
                ok = true;
                break;
            }
        }
    } // uc
}

// not the most efficient but very useful for validating given the "ok"
function _splitByEvery(bytes memory data, bytes8 rune) pure returns (bool ok, bytes[] memory ret) {
    LibDynamicBytesArr.LinkedBytes memory lb = LibDynamicBytesArr.newDynamicBytesArr();
    uint256 lastIdx;
    bytes memory b;
    uint256 size;
    unchecked {
        for (uint256 i; i < data.length; ++i) {
            if (data[i] == rune) {
                size = i - lastIdx;
                if (size < 1) {
                    lastIdx = i;
                    continue;
                }
                b = _allocateBytes(size);
                assembly {
                    mstore(b, 0)
                }
                _appendSubstring(b, data, lastIdx, i);
                LibDynamicBytesArr.p(lb, b);
                lastIdx = i;
                ok = true;
            }
        }
        size = data.length - lastIdx;
        if (size > 0) {
            // don't forget last section :)
            b = _allocateBytes(size);
            assembly {
                mstore(b, 0)
            }
            _appendSubstring(b, data, lastIdx, data.length);
            LibDynamicBytesArr.p(lb, b);
        }
        ret = LibDynamicBytesArr.dump(lb);
    } // uc
}

// this protects ux from long msgs
function _cropWithDots(bytes memory _msg, uint256 maxLength) pure returns (bytes memory) {
    if (_msg.length < maxLength) return _msg;
    assembly {
        mstore(_msg, maxLength)
        let start := sub(maxLength, 3) // assumes maxLength is greater than 3
        for { let i := start } 1 {} {
            mstore8(add(_msg, add(0x20, i)), 0x2e)
            i := add(i, 1)
            if iszero(lt(i, maxLength)) { break }
        }
    }
    return _msg;
}

function validateHexColor(bytes memory subject, uint256 startIdx) pure returns (bool ok) {
    unchecked {
        uint256 length = subject.length;
        if (length != 6 + startIdx) return false; // the 7 - is safe within this contract
        uint256 c;
        for (uint256 i = startIdx; i < length; ++i) {
            c = uint256(uint8(subject[i]));
            // [0-9] || [a-f]
            if (!((c >= 48 && c <= 57) || (c >= 97 && c <= 102))) return false;
        }
    } // uc
    ok = true;
}

function _hashPrefixIfHexColor(bytes memory subject) pure returns (bytes memory ret) {
    if (validateHexColor(subject, 0)) {
        return _concat(bytes("#"), subject);
    }
    return subject;
}

function getFrameHash(Frame memory frame) pure returns (bytes32) {
    unchecked {
        MemoryMappings.MemoryMapping memory m = MemoryMappings.newMemoryMapping({overwrite: true, sorted: true});
        uint256[] memory ids = frame.tabIds;
        uint256[] memory spots = new uint256[](4);
        bytes32 hash;
        uint256 count = 1; // both compressFrame and decompressFrame checks "allAreDistinct" so count is 1..
        for (uint256 i; i < ids.length; ++i) {
            spots[0] = ids[i];
            //spots[1] = 0; // "origin"
            //spots[2] = 0;
            //spots[3] = 0;
            hash = hashArr(spots);
            MemoryMappings.add(m, hash, bytes32(count));
        }
        Fork[] memory forks = frame.forks;
        Fork memory fork;
        bool ok;
        bytes memory bCount;
        for (uint256 i; i < forks.length; ++i) {
            fork = forks[i];
            ids = fork.frameIds;
            for (uint256 j; j < ids.length; ++j) {
                spots[0] = ids[j];
                spots[1] = fork.footprints[j];
                spots[2] = fork.positions[2 * j];
                spots[3] = fork.positions[2 * j + 1];
                hash = hashArr(spots);
                (ok, bCount) = MemoryMappings.get(m, hash);
                if (ok) {
                    count = uint256(toBytes32(bCount));
                    ++count;
                } else {
                    count = 1;
                }
                MemoryMappings.add(m, hash, bytes32(count));
            }
        }
        (uint256[] memory ks, uint256[] memory vs) = MemoryMappings.dumpUint256s(m);
        // this strategy is cheaper gas than keccak256(abi.encode(ks,vs)) lol
        spots[0] = uint256(hashArr(ks));
        spots[1] = uint256(hashArr(vs));
        spots[2] = 0;
        spots[3] = 0;

        return hashArr(spots);
    } // uc
}
// SPDX-License-Identifier: VPL - VIRAL PUBLIC LICENSE
pragma solidity ^0.8.25;

error AlreadyImmortalized_error();
error IDOrdering_error();
error MustRespectExclusivity_error();
error InvalidExclusivityParams_error();
error InvalidOptionsLength_error();
error RevealTimeNotSet_error();
error RevealOrdering_error();
error NotOwner_error();
error InsufficientImmortalizeFee_error();
error FailedCall_error();

error ExceedsMaxFreeMintsPerTx_error();
error MalformedInputs_error();
error ZeroInput_error();
error RepeatedEncryptionReference_error();
error InvalidCommitment_error();
error InvalidKey_error();
error InvalidFeeNumerator_error();
error BadMintPrices_error();
error BadMintCheckpoints_error();
error TrivialMaxSupply_error();
error MintEconomicsOrderering_error();

error NotHub_error();
error AlreadyRevealed_error();
error NotRevealed_error();
error InvalidInput_error();
error InvalidDimensions_error();
error InvalidResolution_error();
error InvalidData_error();
error InvalidColor_error();
error InvalidCaller_error();
error TrivialFrame_error();
error NoWrapping_error();

error NotReady_error();
error CollectionFinalized_error();
error NotCollection_error();
error Transfer_error();

error InvalidLengths_error();
error InvalidPath_error();
error PathsNotOrdered_error();
error InvalidFileBundle_error();
error InvalidTabFingerprint_error();
error InvalidFrameFingerprint_error();
error InvalidColorClassAliases_error();

error RefundFailed_error();
error InsufficientValue_error();
error ExceedsMaxSupply_error();
error MintNotStarted_error();
error MintEnded_error();
error DiscountAlreadyClaimed_error();
error CollectionNotDiscounted_error();

error BridgingNotCurrentlySupported_error();
error InvalidProof_error();
error NotDistinct_error();
error ReadFile_error();
error AlreadySet_error();

error InvalidCollection_error();
error InvalidBurnWindow_error();
error InvalidMintCheckpoints_error();
error InvalidNFTTemplateVersion_error();

error InvalidMaxFreeMintsPerTx_error();

error Overflow_error();

error IsFrozen_error();

error Unsupported_error();

// from ethfs
error SliceOutOfBounds(address pointer, uint32 codeSize, uint32 sliceStart, uint32 sliceEnd);
// SPDX-License-Identifier: VPL - VIRAL PUBLIC LICENSE
pragma solidity ^0.8.25;

import "lib/solady/src/utils/FixedPointMathLib.sol";
import "lib/solady/src/utils/LibString.sol";

import {LibDynamicBuffer} from "./LibDynamicThing.sol";

import "./Append.sol";

library FixedPoint {
    struct FP {
        uint256 value;
    }

    function toFixedPointNumber(uint256 x) internal pure returns (FP memory fp) {
        x *= 1 ether;
        fp.value = x;
    }

    function toFixedPointNumberRaw(uint256 x) internal pure returns (FP memory fp) {
        fp.value = x;
    }

    function toNaturalNumber(FixedPoint.FP memory fp) internal pure returns (uint256) {
        unchecked {
            return fp.value / 1 ether;
        } // uc
    }

    function add(FP memory a, FP memory b) internal pure returns (FP memory res) {
        res.value = a.value + b.value;
    }

    function sub(FP memory a, FP memory b) internal pure returns (FP memory res) {
        res.value = a.value - b.value;
    }

    function mul(FP memory a, FP memory b) internal pure returns (FP memory res) {
        res.value = a.value * b.value / 1 ether;
    }

    function div(FP memory a, FP memory b) internal pure returns (FP memory res) {
        res.value = a.value * 1 ether / b.value;
    }

    function mulDiv(FP memory a, FP memory b, FP memory d) internal pure returns (FP memory res) {
        return div(mul(a, b), d);
    }

    function eq(FP memory a, FP memory b) internal pure returns (bool) {
        return a.value == b.value;
    }

    function toString(FP memory x) internal pure returns (string memory ret) {
        unchecked {
            uint256 value = x.value;
            LibDynamicBuffer.DynamicBuffer memory db = LibDynamicBuffer.newDynamicBuffer();
            LibDynamicBuffer.p(db, bytes(LibString.toString(value / 1 ether)));

            uint256 decimals = value % 1 ether;
            if (decimals > 0) {
                LibDynamicBuffer.p(db, bytes("."));
                uint256 numZeros = 17 - FixedPointMathLib.log10(decimals);
                LibDynamicBuffer.p(db, bytes(sZeros(numZeros)));
                while (decimals > 1 && decimals % 10 == 0) {
                    decimals /= 10;
                }
                LibDynamicBuffer.p(db, bytes(LibString.toString(decimals)));
            }

            ret = string(LibDynamicBuffer.getBuffer(db));
        } // uc
    }

    function sZeros(uint256 numZeros) internal pure returns (string memory ret) {
        ret = _allocateString(numZeros);
        assembly {
            for { let i := 0 } 1 {} {
                mstore8(add(ret, add(0x20, i)), 48)
                i := add(i, 1)
                if iszero(lt(i, numZeros)) { break }
            }
            // 48 is utf8 for "0"
        }
    }
}
// SPDX-License-Identifier: VPL - VIRAL PUBLIC LICENSE
pragma solidity 0.8.28;

/*

     _                              _             _    ___ ___
    | |                            | |           | |  |  _|_  |
  __| |_ __ ___  __ _ _ __ ___  ___| |_ __ _  ___| | _| |   | |_  ___   _ ____
 / _` | '__/ _ \/ _` | '_ ` _ \/ __| __/ _` |/ __| |/ / |   | \ \/ / | | |_  /
| (_| | | |  __/ (_| | | | | | \__ \ || (_| | (__|   <| | _ | |>  <| |_| |/ /
 \__,_|_|  \___|\__,_|_| |_| |_|___/\__\__,_|\___|_|\_\ |(_)| /_/\_\\__, /___|
                                                      |___|___|      __/ |
                                                                    |___/

**/

import "lib/solady/src/utils/LibClone.sol";
import "lib/solady/src/utils/LibBitmap.sol";

import "./modded/creator-token-standards/ERC721C.sol";
import "./modded/creator-token-standards/BasicRoyalties.sol";
import "./modded/openzeppelin/ReentrancyGuard.sol"; // this version uses tstore

import "./Refunds.sol";

import "./Interfaces.sol";
import "./Structs.sol";
import "./Withdrawable.sol"; // for stray tokens
import "./LibPack.sol";
import "./Errors.sol";
import "./Common.sol";

contract Hub is IHub, ERC721C, BasicRoyalties, Withdrawable, Refunds, ReentrancyGuard {
    Supply private _supply;
    string private _name;
    string private _symbol;

    uint256 public constant OWNER_TOKENID = 0;

    uint256 private constant ONE = 1 ether;
    uint256 public constant SHARE_SCALAR = ONE;
    uint256 public constant HUB_DIVISOR = 100_00;
    uint256 public hubRoyalty = 2_50;
    uint256 public hubPercentage = 2_50;
    uint256 public immortalizeFee; // = type(uint256).max; // setImmortalizeFee will unlock!

    address public paymentFiltererTemplate;
    address[] public nftTemplates; // allow for versioning of nftTemplates since we may find from users that they desire nft templates with added/reduced functionality or improved implementations
    IPremierAccessERC1155 public premierAccess;
    IRobustRenderer public robustRenderer;
    IValidityLens public validityLens;
    IURI public uriRenderer;
    IBridging public bridging;
    IProver public prover;

    uint256 public freelancerPercentage;
    uint96 public minFeeNumerator; // to ensure downstream elements get recognized
    uint256 public maxBurnWindow;

    mapping(uint256 => uint256) private _collectionIdxs;
    INFT[] public allCollections;

    mapping(address => bool) public accountOptedOut;
    mapping(uint256 => IPaymentFilterer) private _beneficiaries;
    mapping(bytes32 => uint256) public pledgedRevealTimestamps;
    mapping(address => bool) public platformApprovedWrapper;
    mapping(uint256 => mapping(address => bool)) public ownerApprovedTokenWrapper;
    mapping(uint256 => bool) public ownerApprovedTokenOpen;
    // didn't do bitmap in above maps since they are all staticcall render related so would
    // not benefit greatly from gas vs bytecode size
    LibBitmap.Bitmap private _burned;

    event NewCollection(string collectionName, string collectionSymbol, uint256 curationTokenId, address nft);
    event FreelancerPercentageSet(uint256 newFreelancerPercentage);
    event MinFeeNumeratorSet(uint96 newFeeNumerator);
    event MaxBurnWindowSet(uint256 newMax);
    event NewNFTTemplate(uint256 idx, address newNFTTemplate);
    event AccountOptedOut(address account, bool tf);
    event ArtImmortalized(uint256 tokenId, Type t);
    event NewEncryptedReference(bytes32 encrypted, uint256 pledgedRevealTimestamp);
    event BridgingSet(bool active);
    event ContractURIUpdated();
    event MetadataUpdate(uint256 curationTokenId);

    constructor(address initialOwner) payable BasicRoyalties(initialOwner, uint96(hubRoyalty)) {
        _name = "DreamStack";
        _symbol = "DRS";
        _incrementSupply(1);
        _mint(initialOwner, OWNER_TOKENID);
        // means tabs cannot have tokenId < 1 lol
        allCollections.push(INFT(address(0))); // so that getCollection will consider 0 idx as pathological
    }

    receive() external payable {}
    fallback() external payable {}

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721C, ERC2981) returns (bool) {
        return ERC721C.supportsInterface(interfaceId) || ERC2981.supportsInterface(interfaceId)
            || super.supportsInterface(interfaceId);
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function setComponents(
        INFT nft_,
        IPremierAccessERC1155 premierAccess_,
        IPaymentFilterer paymentFiltererTemplate_,
        IRobustRenderer robustRenderer_,
        IValidityLens validityLens_,
        IURI uri_,
        IRefunder refunder_
    ) external {
        _onlyOwner();

        if (address(premierAccess) != address(0)) revert AlreadySet_error();

        nftTemplates.push(address(nft_));
        premierAccess = premierAccess_;
        paymentFiltererTemplate = address(paymentFiltererTemplate_);
        robustRenderer = robustRenderer_;
        validityLens = validityLens_;
        platformApprovedWrapper[address(validityLens_)] = true;
        uriRenderer = uri_;
        platformApprovedWrapper[address(uri_)] = true;
        refunder = refunder_;
        refunder_.setCustomer(address(this));
        refunder_.setCustomer(address(premierAccess_));

        emit ContractURIUpdated();
    }

    function totalSupply() external view returns (uint256) {
        return uint256(_supply.totalSupply);
    }

    function totalMinted() external view returns (uint256) {
        return uint256(_supply.totalMinted);
    }

    function owner() public view override(IHub) returns (address) {
        if (!_exists(OWNER_TOKENID)) return address(0);
        return ownerOf(OWNER_TOKENID);
    }

    function contractURI() external view returns (string memory) {
        // wrapping is ok
        return uriRenderer.hubContractURI();
    }

    function tokenURI(uint256 curationTokenId) public view override(ERC721, IHub) returns (string memory ret) {
        bool ok;
        ownerOf(curationTokenId); // will throw if dne!
        (ok, ret) = _tokenURI(curationTokenId, msg.sender);
        if (!ok) revert NoWrapping_error();
    }

    function _tokenURI(uint256 curationTokenId, address caller) private view returns (bool ok, string memory ret) {
        if (
            !(
                caller == tx.origin || platformApprovedWrapper[caller] || ownerApprovedTokenOpen[curationTokenId]
                    || ownerApprovedTokenWrapper[curationTokenId][caller]
            )
        ) return (false, ret);
        return (true, uriRenderer.hubTokenURI(curationTokenId));
    }

    function multiTokenURI(uint256[] calldata curationTokenIds) public view returns (string[] memory ret) {
        ret = _allocateStringArr(curationTokenIds.length);
        bool ok;
        uint256 id;
        for (uint256 i; i < curationTokenIds.length; ++i) {
            string memory uri;
            id = curationTokenIds[i];
            if (!_exists(id)) continue; // gracefully ignores
            (ok, uri) = _tokenURI(id, msg.sender);
            if (ok) ret[i] = uri; // otherwise gracefully ignores
        }
    }

    // since the hub itself can be sold lol!
    // can be called by anyone
    function setDefaultRoyalty() external {
        _setDefaultRoyalty(ownerOf(OWNER_TOKENID), uint96(hubRoyalty));

        emit MetadataUpdate(OWNER_TOKENID);
        emit ContractURIUpdated();
    }

    function setHubValues(uint256 hubPercentage_, uint256 hubRoyalty_) external {
        _onlyOwner();
        hubPercentage = hubPercentage_;
        hubRoyalty = hubRoyalty_;
    }

    function addNewNFTTemplate(address newNFTTemplate) external {
        _onlyOwner();
        uint256 idx = nftTemplates.length;
        nftTemplates.push(newNFTTemplate);
        emit NewNFTTemplate(idx, newNFTTemplate);
    }

    function nftTemplatesLength() external view returns (uint256) {
        return nftTemplates.length;
    }

    // VERY convenient in the case of V2 etc
    function setApprovedWrapper(address wrapper) external {
        _onlyOwner();
        platformApprovedWrapper[wrapper] = true;
    }

    function setApprovedTokenOpen(uint256 curationTokenId) external {
        if (msg.sender != ownerOf(curationTokenId)) revert NotOwner_error();
        ownerApprovedTokenOpen[curationTokenId] = true;
    }

    function setApprovedTokenWrapper(uint256 curationTokenId, address wrapper) external {
        if (msg.sender != ownerOf(curationTokenId)) revert NotOwner_error();
        ownerApprovedTokenWrapper[curationTokenId][wrapper] = true;
    }

    function setBridging(IBridging bridging_, IProver prover_) external {
        _onlyOwner();
        bridging = bridging_;
        prover = prover_;
        emit BridgingSet(address(bridging_) != address(0) && address(prover_) != address(0));
        // we have bridging for the INFT's but not for these DreamStack curated components,
        // since payment streams of curated components would not map properly when bridged.
        // specifically if we had the PaymentFilterer check some "isBridged", then a bridged
        // frame could not receive a release which would stall transfers to featuredIds.
        // perhaps this feature will be in V2!!
    }

    function ownerOf(uint256 tokenId) public view override(IHub, ERC721) returns (address) {
        return super.ownerOf(tokenId);
    }

    function exists(uint256 tokenId) public view returns (bool) {
        return _exists(tokenId);
    }

    function beneficiariesOf(uint256 tokenId) public view returns (IPaymentFilterer beneficiary, address holder) {
        beneficiary = _beneficiaries[tokenId]; // if non-null, then is payment filterer associated with frame
        holder = _exists(tokenId) ? ownerOf(tokenId) : address(this);
    }

    function optOutIncentivizedRelease(bool optOut) external {
        accountOptedOut[msg.sender] = optOut;

        emit AccountOptedOut(msg.sender, optOut);
    }

    function getCollection(uint256 curationTokenId) public view returns (INFT) {
        return allCollections[_collectionIdxs[curationTokenId]];
    }

    function allCollectionsLength() public view returns (uint256) {
        return allCollections.length;
    }

    // note: feeDenominator is 100_00

    function setMinFeeNumerator(uint96 newFeeNumerator) external {
        _onlyOwner();
        if (newFeeNumerator > 100_00) revert InvalidInput_error();
        minFeeNumerator = newFeeNumerator;
        emit MinFeeNumeratorSet(newFeeNumerator);
    }

    function setMaxBurnWindow(uint256 newMax) external {
        _onlyOwner();
        maxBurnWindow = newMax;
        emit MaxBurnWindowSet(newMax);
    }

    function setFreelancerPercentage(uint256 newPercentage) external {
        _onlyOwner();
        if (newPercentage > IPaymentFilterer(paymentFiltererTemplate).BASIS()) revert InvalidInput_error();
        freelancerPercentage = newPercentage;
        emit FreelancerPercentageSet(newPercentage);
    }

    function setImmortalizeFee(uint256 newFee) external {
        _onlyOwner();
        immortalizeFee = newFee;
    }

    function immortalizeTab(
        bytes32 encrypted,
        FileBundle calldata compressedTab,
        ExclusivityData calldata exclusivityData,
        address to
    ) external payable returns (uint256 tokenId) {
        _processImmortalizeFee({qty: 1});
        tokenId = _incrementSupply({qty: 1});

        _immortalizeTab(encrypted, compressedTab, exclusivityData, to, tokenId);
    }

    function immortalizeTabBulk(
        bytes32[] calldata encrypteds,
        FileBundle[] calldata compressedTabs,
        ExclusivityData[] calldata exclusivityDatas,
        address[] calldata tos
    ) external payable nonReentrant returns (uint256[] memory tokenIds) {
        // nonReentrant since is _safeMint in a loop
        uint256 qty = compressedTabs.length;
        _processImmortalizeFee(qty);
        uint256 tokenId = _incrementSupply(qty);
        tokenIds = _allocateUintArr(qty);
        unchecked {
            for (uint256 i; i < qty; ++i) {
                tokenIds[i] = tokenId;
                _immortalizeTab(encrypteds[i], compressedTabs[i], exclusivityDatas[i], tos[i], tokenId++);
            }
        } // uc
    }

    function getDeclaredFingerprint(FileBundle calldata compressed) public pure returns (bytes32) {
        if (compressed.chunks.length == 0) revert InvalidFileBundle_error();
        return toBytes32(LibPack.bytesAt(compressed.chunks[0], 0));
    }

    function _immortalizeTab(
        bytes32 encrypted,
        FileBundle calldata compressedTab,
        ExclusivityData calldata exclusivityData,
        address to,
        uint256 tokenId
    ) private {
        bytes32 declaredFingerprint = getDeclaredFingerprint(compressedTab);

        if (robustRenderer.immortalized(declaredFingerprint) > 0) revert AlreadyImmortalized_error();
        // recall that the id > 0 .. since 0 tokenId is claimed by deployoor

        if (encrypted != bytes32(0) && pledgedRevealTimestamps[encrypted] < 1) revert RevealTimeNotSet_error();

        premierAccess.setExclusivityData(tokenId, exclusivityData); // this validates data

        robustRenderer.immortalize(tokenId, encrypted, declaredFingerprint, Type.TAB, compressedTab);

        _safeMint(to, tokenId);
        emit ArtImmortalized(tokenId, Type.TAB);
    }

    function immortalizeFrame(
        uint256[] calldata featuredIds, // tabIds and frameIds<Forks, unique array by client
        bytes32 encrypted,
        FileBundle calldata compressedFrame,
        ExclusivityData calldata exclusivityData,
        address to
    ) external payable returns (uint256 tokenId) {
        _processImmortalizeFee(1);
        uint256 pledgedRevealTimestamp_ = pledgedRevealTimestamps[encrypted];
        if (encrypted != bytes32(0) && pledgedRevealTimestamp_ < 1) revert RevealTimeNotSet_error();
        unchecked {
            tokenId = _incrementSupply(1);
            {
                //s2d
                uint256 length = featuredIds.length;
                if (length < 1) revert ZeroInput_error();
                uint256 id;
                Type t;
                for (uint256 i; i < length; ++i) {
                    id = featuredIds[i];
                    t = robustRenderer.immortalizedType(id);
                    // must be at or after reveal of children
                    if (pledgedRevealTimestamp_ < pledgedRevealTimestamps[robustRenderer.encryptionReference(id)]) {
                        revert RevealOrdering_error();
                    }
                    if (t < Type.TAB || t > Type.FRAME_ENCRYPTED) revert InvalidInput_error();

                    if (i < length - 1 && !(id < featuredIds[i + 1])) revert IDOrdering_error();

                    _processPremierAccess(id, msg.sender);
                }
                if (!(id < tokenId)) revert InvalidInput_error();

                premierAccess.setExclusivityData(tokenId, exclusivityData); // this validates data
            } //s2d

            bytes32 declaredFingerprint = getDeclaredFingerprint(compressedFrame);

            if (robustRenderer.immortalized(declaredFingerprint) > 0) revert AlreadyImmortalized_error();
            IPaymentFilterer paymentFiltererClone = IPaymentFilterer(
                LibClone.cloneDeterministic({implementation: paymentFiltererTemplate, salt: declaredFingerprint})
            );
            {
                (uint256[] memory payeeTokenIds, uint256[] memory shares,) = _getPaymentArrs(featuredIds, 1);
                payeeTokenIds[0] = tokenId;
                shares[0] = SHARE_SCALAR;
                // dev gets share of collection mint/royalties, so no use putting dev share here
                paymentFiltererClone.initialize(payeeTokenIds, shares);
            } // s2d

            _beneficiaries[tokenId] = paymentFiltererClone; // note: _beneficiaries is only set for frame, not for tab or collectionTokenId

            robustRenderer.immortalize(tokenId, encrypted, declaredFingerprint, Type.FRAME, compressedFrame);

            _safeMint(to, tokenId);
            emit ArtImmortalized(tokenId, (encrypted != bytes32(0)) ? Type.FRAME_ENCRYPTED : Type.FRAME);
        } //uc
    }

    function immortalizeCollection(ImmortalizeCollectionData calldata icd)
        public
        nonReentrant
        returns (uint256 tokenId)
    {
        // nonreentrant since future nftTemplate versions are in control of future hub owners
        unchecked {
            //s2d
            uint256 pledgedRevealTimestamp_ = pledgedRevealTimestamps[icd.encrypted];
            if (icd.encrypted != bytes32(0) && pledgedRevealTimestamp_ < 1) revert RevealTimeNotSet_error();
            tokenId = _incrementSupply(1);
            uint256 length = icd.featuredFrameIds.length;
            if (length < 1) revert ZeroInput_error();
            uint256 id;
            Type t;
            for (uint256 i; i < length; ++i) {
                id = icd.featuredFrameIds[i];
                t = robustRenderer.immortalizedType(id);
                // must be at or after reveal of children
                if (pledgedRevealTimestamp_ < pledgedRevealTimestamps[robustRenderer.encryptionReference(id)]) {
                    revert RevealOrdering_error();
                }
                // can be tab posing as frame
                if (t < Type.TAB || t > Type.FRAME_ENCRYPTED) revert InvalidInput_error();
                if (i < length - 1 && !(id < icd.featuredFrameIds[i + 1])) revert IDOrdering_error();
                _processPremierAccess(id, msg.sender);
            }
            if (!(id < tokenId)) revert InvalidInput_error();
        } //s2d

        INFT nftClone;
        IPaymentFilterer paymentFiltererClone;
        {
            // s2d

            bytes32 salt = _computeSalt(icd.featuredFrameIds, Type.COLLECTION);

            if (robustRenderer.immortalized(salt) > 0) revert AlreadyImmortalized_error();

            paymentFiltererClone = IPaymentFilterer(LibClone.cloneDeterministic(paymentFiltererTemplate, salt));
            (uint256[] memory payeeTokenIds, uint256[] memory shares, uint256 totalShares) =
                _getPaymentArrs(icd.featuredFrameIds, 2);

            payeeTokenIds[0] = tokenId; // as first index for availability target
            // notice this math IS checked since input can be hostile
            shares[0] = icd.mintEconomics.curatorShare * SHARE_SCALAR;
            totalShares += shares[0];

            payeeTokenIds[1] = OWNER_TOKENID;
            uint256 hp = hubPercentage;
            shares[1] = hp * totalShares / (HUB_DIVISOR - hp); // so that hub fee is hubRoyalty% of shares
            /* 
                algebra:
                  want share s such that s = (a/b) * t' where t' is the resulting total
                  since t' = s + t
                  it follows that s = a*t / (b - a)
            **/
            // so payeeTokenIds and shares will never be empty

            paymentFiltererClone.initialize(payeeTokenIds, shares);

            // will be initialized in nftClone.initialize(...)
            if (!(icd.nftVersionId < nftTemplates.length)) revert InvalidNFTTemplateVersion_error();
            nftClone = INFT(LibClone.cloneDeterministic(nftTemplates[icd.nftVersionId], salt));
        } // s2d

        // safeMint not needed since this is recipient
        _mint(address(this), tokenId); // 'this' necessary for ownership in initialization

        robustRenderer.setCollection(tokenId, icd.encrypted, icd.names.walker, icd.compressedCollectionData);

        nftClone.initialize(tokenId, paymentFiltererClone, refunder, icd.names, icd.mintEconomics, icd.dd, icd.auxData);
        refunder.setCustomer(address(nftClone));
        uriRenderer.setCollection(address(nftClone), tokenId);

        _collectionIdxs[tokenId] = allCollections.length;
        allCollections.push(nftClone);

        _transfer(address(this), icd.to, tokenId);

        emit NewCollection(icd.names.name, icd.names.symbol, tokenId, address(nftClone));
    }

    function immortalizeCollectionCombined(
        bytes32 encryptionPre,
        uint256 pledgedRevealTimestamp_,
        ImmortalizeCollectionData calldata icd
    ) external returns (bytes32 encryptionReference, uint256 tokenId) {
        encryptionReference = setEncryptedRevealTime(encryptionPre, pledgedRevealTimestamp_);
        tokenId = immortalizeCollection(icd);
    }

    function computeEncryptionReference(bytes32 encryptionPre, address account)
        public
        pure
        returns (bytes32 encryptionReference)
    {
        assembly {
            // efficient hashing lol
            mstore(0x00, encryptionPre)
            mstore(0x20, account)
            encryptionReference := keccak256(0x00, 0x40)
        }
    }

    function setEncryptedRevealTime(bytes32 encryptionPre, uint256 pledgedRevealTimestamp_)
        public
        returns (bytes32 encryptionReference)
    {
        // bound to msg.sender to prevent frontrunning griefoors
        encryptionReference = computeEncryptionReference(encryptionPre, msg.sender);
        if (encryptionReference == bytes32(0)) revert ZeroInput_error(); // overzealous assert

        if (pledgedRevealTimestamps[encryptionReference] != 0) revert RepeatedEncryptionReference_error();
        pledgedRevealTimestamps[encryptionReference] = pledgedRevealTimestamp_;
        emit NewEncryptedReference(encryptionReference, pledgedRevealTimestamp_);
    }

    // optionalCurationTokenId is for the sake of emitting logs to trigger updates on exchanges
    function reveal(bytes32 key, uint256 optionalCurationTokenId) external {
        bytes32 encryptedPre;
        assembly {
            // efficient hashing lol, equivalent to // = keccak256(abi.encodePacked(key));
            mstore(0x0, key)
            encryptedPre := keccak256(0x0, 0x20)
        }
        // bound to msg.sender to prevent frontrunning griefoors
        bytes32 encryptionReference = computeEncryptionReference(encryptedPre, msg.sender);
        if (pledgedRevealTimestamps[encryptionReference] == 0) revert InvalidKey_error();
        robustRenderer.reveal(encryptionReference, key); // only allows ONE reveal per encryptedReference
        if (optionalCurationTokenId < 1) return;
        emitUpdated(optionalCurationTokenId);
    }

    function emitUpdated(uint256 curationTokenId) public {
        emit MetadataUpdate(curationTokenId);

        Type t = robustRenderer.immortalizedType(curationTokenId);
        if (t > Type.FRAME_ENCRYPTED) {
            getCollection(curationTokenId).emitContractURIUpdated();
            getCollection(curationTokenId).emitBatchMetadataUpdate(0, type(uint256).max);
            return;
        }
        premierAccess.emitMetadataUpdate(curationTokenId);
    }

    function pledgedRevealTimestamp(uint256 id) external view returns (uint256) {
        return pledgedRevealTimestamps[robustRenderer.encryptionReference(id)];
    }

    function updateContractURIImage(uint256 curationTokenId, FileBundle calldata imageData, address customRenderer)
        external
    {
        if (msg.sender != ownerOf(curationTokenId)) revert NotOwner_error(); // throws if dne!
        robustRenderer.updateContractURIImage(curationTokenId, imageData, customRenderer);
        if (curationTokenId < 1) {
            emit ContractURIUpdated();
        } else {
            INFT nft = allCollections[_collectionIdxs[curationTokenId]];
            nft.emitContractURIUpdated();
        }
    }

    function burn(uint256 tokenId) external {
        if (msg.sender != ownerOf(tokenId)) revert NotOwner_error();
        unchecked {
            --_supply.totalSupply;
        }
        LibBitmap.set(_burned, tokenId);
        _burn(tokenId);
    }

    function burned(uint256 tokenId) external view returns (bool) {
        return LibBitmap.get(_burned, tokenId);
    }

    function _onlyOwner() internal view override {
        if (msg.sender != ownerOf(OWNER_TOKENID)) revert NotOwner_error();
    }

    function _processImmortalizeFee(uint256 qty) private {
        uint256 immortalizeFee_ = immortalizeFee * qty;
        if (msg.value < immortalizeFee_) revert InsufficientImmortalizeFee_error();
        if (msg.value > immortalizeFee_) {
            unchecked {
                _setRefund(msg.sender, msg.value - immortalizeFee_);
            } // uc
        }
    }

    function _processPremierAccess(uint256 id, address account) private {
        if (!_exists(id) || account != ownerOf(id)) {
            // check exists since can be burned

            if (!premierAccess.processAccess(account, id)) revert MustRespectExclusivity_error();
        }
    }

    function _incrementSupply(uint256 qty) private returns (uint256 tokenId) {
        Supply memory s = _supply;
        assembly {
            tokenId := mload(add(s, 0x20)) // = s.totalMinted

            mstore(s, add(mload(s), qty)) //s.totalSupply += uint128(qty);
            mstore(add(s, 0x20), add(tokenId, qty)) //s.totalMinted += uint128(qty);
        }
        _supply = s;
    }

    function _getPaymentArrs(uint256[] memory ids, uint256 offset)
        private
        pure
        returns (uint256[] memory payeeTokenIds, uint256[] memory shares, uint256 totalShares)
    {
        unchecked {
            uint256 length = ids.length + offset;
            payeeTokenIds = _allocateUintArr(length);
            shares = _allocateUintArr(length);
            uint256 idx;
            for (uint256 i; i < ids.length; ++i) {
                idx = i + offset;
                payeeTokenIds[idx] = ids[i];
                shares[idx] = SHARE_SCALAR;
                totalShares += SHARE_SCALAR;
            }
        } // uc
    }

    function _computeSalt(uint256[] calldata featuredIds, Type t) private pure returns (bytes32 salt) {
        salt = hashArr(featuredIds); // two frames cannot have same exact featuredIds lol
        assembly {
            mstore(0x0, salt)
            mstore(0x20, t)
            salt := keccak256(0x0, 0x40)
        }
    }

    function _requireCallerIsContractOwner() internal view override {
        if (msg.sender != ownerOf(OWNER_TOKENID)) revert NotOwner_error();
    }
}
// SPDX-License-Identifier: VPL - VIRAL PUBLIC LICENSE
pragma solidity ^0.8.25;

import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "lib/openzeppelin-contracts/contracts/utils/introspection/IERC165.sol";

import "./modded/creator-token-standards/TransferPolicy.sol";

import "./Structs.sol";
import "./FixedPoint.sol";

interface IFS {
    function flzCompressContents(bytes calldata contents) external pure returns (bytes memory);
    function fileBundleFromContents(bytes calldata contents) external view returns (FileBundle memory);
    function saveFileBundle(FileBundle calldata fb) external returns (address);
    function readFile(address ptr) external view returns (bytes memory);
}

interface IHub {
    function owner() external view returns (address);
    function OWNER_TOKENID() external view returns (uint256);
    function hubRoyalty() external view returns (uint256);
    function hubPercentage() external view returns (uint256);
    function HUB_DIVISOR() external view returns (uint256);
    function paymentFiltererTemplate() external view returns (address);
    function robustRenderer() external view returns (IRobustRenderer);
    function uriRenderer() external view returns (IURI);
    function nftTemplates(uint256 nftTemplateId) external view returns (address);
    function nftTemplatesLength() external view returns (uint256);
    function validityLens() external view returns (IValidityLens);
    function totalSupply() external view returns (uint256);
    function totalMinted() external view returns (uint256);
    function ownerOf(uint256 tokenId) external view returns (address);
    function exists(uint256 tokenId) external view returns (bool);
    function burned(uint256 tokenId) external view returns (bool);
    function emitUpdated(uint256 curationTokenId) external;
    function beneficiariesOf(uint256 tokenId) external view returns (IPaymentFilterer beneficiary, address holder);
    function accountOptedOut(address account) external view returns (bool);
    function minFeeNumerator() external view returns (uint96);
    function maxBurnWindow() external view returns (uint256);
    function setMaxBurnWindow(uint256) external;
    function addNewNFTTemplate(address) external;
    function freelancerPercentage() external view returns (uint256);
    function premierAccess() external view returns (IPremierAccessERC1155);
    function platformApprovedWrapper(address account) external view returns (bool);
    function ownerApprovedTokenWrapper(uint256 curationTokenId, address account) external view returns (bool);
    function ownerApprovedTokenOpen(uint256 curationTokenId) external view returns (bool);
    function bridging() external view returns (IBridging);
    function prover() external view returns (IProver);

    function updateContractURIImage(uint256 curationTokenId, FileBundle memory imageData, address customRenderer)
        external;

    function immortalizeCollection(ImmortalizeCollectionData calldata icd) external returns (uint256 curationTokenId);

    function getCollection(uint256 curationTokenId) external view returns (INFT);

    function pledgedRevealTimestamps(bytes32 encryptionReference) external view returns (uint256);
    function pledgedRevealTimestamp(uint256 curationTokenId) external view returns (uint256);
    function getDeclaredFingerprint(FileBundle memory compressedTab) external view returns (bytes32);

    function tokenURI(uint256 tokenId) external view returns (string memory);
}

interface INFT {
    function curationTokenId() external view returns (uint256);
    function owner() external view returns (address);
    function ownerOf(uint256 tokenId) external view returns (address);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function contractURI() external view returns (string memory);
    function emitContractURIUpdated() external;
    function emitBatchMetadataUpdate(uint256 fromTokenId, uint256 toTokenId) external;
    function MINT_REVEAL_BLOCK_OFFSET() external view returns (uint256);
    function tokenURI(uint256 tokenId) external view returns (string memory);
    function description() external view returns (string memory);
    function website() external view returns (string memory);
    function maxSupply() external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function totalMinted() external view returns (uint256);
    function qtyAvailableToMint() external view returns (uint256);
    function mintStarts() external view returns (uint256);
    function mintEnds() external view returns (uint256);
    function mintStarted() external view returns (bool);
    function mintPriceCurrent() external view returns (uint256);
    function mintPrice(uint256 nth) external view returns (uint256);
    function mintPrices() external view returns (uint256[] memory mintQtyCheckpoints, uint256[] memory mintPrices);
    function ONE() external view returns (uint256);
    function mintEconomics() external view returns (MintEconomics memory);
    function willBeFinalized() external view returns (uint256);
    function initialize(
        uint256 curationTokenId,
        IPaymentFilterer paymentFilterer_,
        IRefunder refunder_,
        CollectionNames calldata names,
        MintEconomics calldata mintEconomics,
        DiscountData calldata dd,
        bytes calldata auxData
    ) external;

    function paymentFilterer() external view returns (IPaymentFilterer);

    function pushETHToPaymentFilterer() external;

    function setMintEnds(uint256 mintEndsTime) external;
    function updateSupply() external;

    function mint(address to, uint256 qty) external payable;

    function mintDiscounted(address to, IERC721[] calldata collections, uint256[] calldata tokenIds) external payable;

    function burn(uint256[] memory ids) external;
}

interface IERC1155 is IERC165 {
    function balanceOf(address account, uint256 id) external view returns (uint256);
    function setApprovalForAll(address operator, bool approved) external;
    function isApprovedForAll(address account, address operator) external view returns (bool);
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;
}

interface IERC1155MetadataURI {
    function uri(uint256 id) external view returns (string memory);
}

interface IPremierAccessERC1155 is IERC1155, IERC1155MetadataURI {
    function ONE() external view returns (uint256);
    function feePercentage() external view returns (uint256);
    function setExclusivityData(uint256 curationTokenId, ExclusivityData calldata xclusivityData) external;
    function exclusivityData(uint256 curationTokenId) external view returns (ExclusivityData memory);
    function supply(uint256 curationTokenId) external view returns (Supply memory);
    function processAccess(address account, uint256 curationTokenId) external returns (bool ok);
    function mint(uint256 curationTokenId, uint256 qty, address to) external payable;
    function emitMetadataUpdate(uint256 curationTokenId) external;
}

interface IImmortalizerCompressUtil {
    function checkValidatePathsOrder(bytes[] calldata paths) external view returns (bool ok);

    function compressCollectionData(bytes32 key, bytes32 nonce, CollectionData memory cd)
        external
        view
        returns (FileBundle memory ret);

    function compressFrame(bytes32 key, bytes32 nonce, Frame memory frame)
        external
        view
        returns (FileBundle memory ret);

    function compressTab(
        bytes32 key,
        bytes32 nonce,
        bytes[] memory attributes,
        bytes[][2] memory colorClasses,
        uint256 dimension,
        bytes[] memory paths
    ) external view returns (FileBundle memory ret);
}

interface IImmortalizerDecompressUtil {
    function decompressCollectionData(bytes32 key, bytes memory compressed)
        external
        pure
        returns (CollectionData memory ret);

    function decompressFrame(bytes32 key, bytes memory packed) external pure returns (Frame memory frame);

    function decompressTab(bytes32 key, bytes memory compressedTab)
        external
        view
        returns (bytes[] memory attributes, bytes[][2] memory colorClasses, uint256 dimension, bytes[] memory paths);
}

interface IRobustRenderer {
    function fs() external view returns (IFS);
    function immortalize(uint256 id, bytes32 encrypted, bytes32 fingerprint, Type t, FileBundle calldata compressed)
        external;

    function updateContractURIImage(uint256 id, FileBundle calldata fb, address customRenderer) external;
    function immortalized(bytes32 fingerprint) external view returns (uint256 id);
    function encryptionReference(uint256 id) external view returns (bytes32);
    function decrypted(uint256 id) external view returns (bool tf);
    function key(uint256 id) external view returns (bytes32);
    function keySafe(uint256 id) external view returns (bytes32);
    function immortalizedType(uint256 id) external view returns (Type);
    function isWalker(uint256 id) external view returns (bool);
    function setCollection(uint256 id, bytes32 encrypted, bool walker, FileBundle calldata compressedCollectionData)
        external;
    function reveal(bytes32 encryptionReference, bytes32 key) external;
    function decompressCollectionData(uint256 collectionCurationId) external view returns (CollectionData memory);
    function decompressFrame(uint256 frameId) external view returns (Frame memory);

    function renderTab(uint256 tabId, PointAndBounded calldata pb)
        external
        view
        returns (
            string[][2] memory attributes,
            string[][2] memory colorClasses,
            string memory svg,
            FixedPoint.FP memory resolution
        );
    function getNumberOfFrameStates(uint256 frameId) external view returns (uint256);
    function renderFrame(uint256 frameId, uint256 entropy, uint256 seed, PointAndBounded calldata pb)
        external
        view
        returns (
            string[][2] memory attributes,
            string[][2] memory colorClasses,
            string memory svg,
            FixedPoint.FP memory resolution
        );
    function renderCollection(uint256 collectionId, uint256 entropy, uint256 seed, PointAndBounded calldata pb)
        external
        view
        returns (RenderedCollectionData memory renderedCollectionData);
    function renderContractURIImage(uint256 id) external view returns (string memory);
    function formSVG(FixedPoint.FP memory resolution, PointAndBounded memory pb, bytes memory nestedData)
        external
        pure
        returns (string memory);
}

interface IValidityLens {
    function scanValidity(uint256 id, uint256 seed, uint256 runs)
        external
        view
        returns (Validity validity, bytes memory error);
    function checkEncrypted(uint256 pledgedRevealTimestamp, bytes32 key) external view returns (Validity);
}

interface IURI {
    function svgFramed() external view returns (ISVGFramed);
    function uriFinisher() external view returns (IURIFinisher);
    function maxMsgLength() external view returns (uint256);
    function setCollection(address target, uint256 collectionTokenId) external;
    function hubContractURI() external view returns (string memory);
    function hubTokenURI(uint256 curationTokenId) external view returns (string memory);
    function hubURI(uint256 curationTokenId) external view returns (string memory);
    function collectionContractURI() external view returns (string memory);
    function collectionTokenURI(uint256 tokenId, RevealedStatus revealedStatus, uint256 entropy)
        external
        view
        returns (string memory);
}

interface ISVGFramed {
    function MAT_OFFSET() external view returns (uint256);
    function MAT_INNER() external view returns (uint256);
    function framed(string memory color, bytes memory _msg, string memory sSvg, bool truncate)
        external
        view
        returns (string memory ret);
}

interface IURIFinisher {
    function finishContractURI(
        CollectionNames calldata names,
        string calldata sSvg,
        uint256 feeBasisPoints,
        address feeRecipient
    ) external view returns (string memory ret);

    function finishPending(Type t, Validity v, uint256 pledgedRevealTimestamp, uint256 curationTokenId)
        external
        view
        returns (string memory ret);

    function finishTokenURIAliased(
        CollectionNames calldata names,
        string[][2] calldata attributes,
        JSON[][2] calldata additionalAttributes,
        string[][2] calldata colorClasses,
        string calldata sSvg
    ) external view returns (string memory ret);

    function finishTokenURI(
        CollectionNames calldata names,
        string[][2] calldata attributes,
        JSON[][2] calldata additionalAttributes,
        bytes memory formattedColorClasses,
        string calldata sSvg
    ) external view returns (string memory ret);
}

interface IPaymentFilterer {
    function BASIS() external view returns (uint256);
    function initialize(uint256[] memory payeeTokenIds, uint256[] memory shares_) external payable;
    function payeesLength() external view returns (uint256);
    function payee(uint256 idx) external view returns (uint256);
    function shares(uint256 id) external view returns (uint256);
    function isPayee(uint256 payeeTokenId) external view returns (bool);
    function releasable(uint256 payeeTokenId) external view returns (uint256);
    function releasable(IERC20 token, uint256 payeeTokenId) external view returns (uint256);
    function release(uint256 payeeTokenId, address to) external;
    function release(IERC20 token, uint256 payeeTokenId, address to) external;

    function incentivizedRelease(uint256 payeeTokenId) external;
    function incentivizedRelease(IERC20 token, uint256 payeeTokenId) external;
}

interface IRefunds {
    function refundAvailable(address account) external view returns (uint256);
    function claimRefund() external;
}

interface IRefunder {
    function setCustomer(address customer) external;
    function refundAvailable(address account) external view returns (uint256);
    function claimRefund(address account) external;
    function setRefund(address account) external payable;
}

interface IProver {
    function validateProof(address to, INFT nft, uint256[] calldata tokenIds, uint256 l2Id, bytes calldata proof)
        external
        returns (bool);
}

interface IBridging {
    function bridgeTo(address from, INFT nft, uint256[] calldata tokenIds, uint256 l2Id) external;
    function bridgeFrom(address to, INFT nft, uint256[] calldata tokenIds, uint256 l2Id) external;
    function isBridged(INFT nft, uint256 tokenId) external view returns (bool);
}

interface ISudoPoolValidator {
    function validateAndAddSudoPoolsToWhitelist(address[] calldata sudoPools) external;
}
// SPDX-License-Identifier: VPL - VIRAL PUBLIC LICENSE
pragma solidity ^0.8.25;

import "./Append.sol";
import "./Structs.sol";

library LibDynamicJSONKVArr {
    struct LinkedKVs {
        LibDynamicThing.LinkedThings lks;
        LibDynamicThing.LinkedThings lvs;
    }

    function newDynamicKVArr() internal pure returns (LinkedKVs memory ret) {
        ret = LinkedKVs(LibDynamicThing.newLinkedThings(), LibDynamicThing.newLinkedThings());
    }

    function p(LinkedKVs memory lkvs, bytes memory kData, bytes memory vData) internal pure {
        p(lkvs, kData, vData, JSONType.STRING);
    }

    function p(LinkedKVs memory lkvs, bytes memory kData, bytes memory vData, JSONType valueType) internal pure {
        if (vData.length < 1) return; // note: don't forget it ignores kvs with trivial value!!

        JSON memory k = JSON(JSONType.STRING, kData);
        JSON memory v = JSON(valueType, vData);
        uint256 kPtr;
        uint256 vPtr;
        assembly {
            kPtr := k
            vPtr := v
        }

        LibDynamicThing.p(lkvs.lks, kPtr);
        LibDynamicThing.p(lkvs.lvs, vPtr);
    }

    function dump(LinkedKVs memory lkvs) internal pure returns (JSON[][2] memory aakvs) {
        uint256[] memory kPtrs = LibDynamicThing.dump(lkvs.lks);
        uint256[] memory vPtrs = LibDynamicThing.dump(lkvs.lvs);
        JSON[] memory ks;
        JSON[] memory vs;
        assembly {
            ks := kPtrs
            vs := vPtrs
        }
        aakvs[0] = ks;
        aakvs[1] = vs;
    }
}

library LibDynamicKVArr {
    struct LinkedKVs {
        LibDynamicThing.LinkedThings lks;
        LibDynamicThing.LinkedThings lvs;
    }

    function newDynamicKVArr() internal pure returns (LinkedKVs memory ret) {
        ret = LinkedKVs(LibDynamicThing.newLinkedThings(), LibDynamicThing.newLinkedThings());
    }

    function p(LinkedKVs memory lkvs, bytes memory kData, bytes memory vData) internal pure {
        if (vData.length < 1) return; // note: don't forget it ignores kvs with trivial value!!

        uint256 kPtr;
        uint256 vPtr;
        assembly {
            kPtr := kData
            vPtr := vData
        }

        LibDynamicThing.p(lkvs.lks, kPtr);
        LibDynamicThing.p(lkvs.lvs, vPtr);
    }

    function dump(LinkedKVs memory lkvs) internal pure returns (bytes[][2] memory aakvs) {
        uint256[] memory kPtrs = LibDynamicThing.dump(lkvs.lks);
        uint256[] memory vPtrs = LibDynamicThing.dump(lkvs.lvs);
        bytes[] memory ks;
        bytes[] memory vs;
        assembly {
            ks := kPtrs
            vs := vPtrs
        }
        aakvs[0] = ks;
        aakvs[1] = vs;
    }
}

library LibDynamicBytesArr {
    struct LinkedBytes {
        LibDynamicThing.LinkedThings ldt;
    }

    function newDynamicBytesArr() internal pure returns (LinkedBytes memory ret) {
        return LinkedBytes(LibDynamicThing.newLinkedThings());
    }

    function p(LinkedBytes memory ls, bytes memory b) internal pure {
        uint256 ptr;
        assembly {
            ptr := b
        }
        LibDynamicThing.p(ls.ldt, ptr);
    }

    function dump(LinkedBytes memory lb) internal pure returns (bytes[] memory ret) {
        uint256[] memory ptrs = LibDynamicThing.dump(lb.ldt);
        uint256 length = ptrs.length;
        ret = _allocateArr(length);
        assembly {
            for { let i := 0 } 1 {} {
                // hail solady
                let ptr := mload(add(ptrs, add(0x20, mul(i, 0x20))))
                mstore(add(ret, add(0x20, mul(i, 0x20))), ptr)
                i := add(i, 1)
                if iszero(lt(i, length)) { break }
            }
        }
        /* // does this
          uint256 length = ptrs.length;
          ret = new string[](length);
          uint256 ptr;
          string memory str;
          for (uint256 i; i < length; ++i) {
              ptr = ptrs[i];
              assembly {
                  str := ptr
              }
              ret[i] = str;
          }
        */
    }
}

library LibDynamicStringArr {
    struct LinkedStrings {
        LibDynamicThing.LinkedThings ldt;
    }

    function newDynamicStringArr() internal pure returns (LinkedStrings memory ret) {
        return LinkedStrings(LibDynamicThing.newLinkedThings());
    }

    function p(LinkedStrings memory ls, string memory str) internal pure {
        uint256 ptr;
        assembly {
            ptr := str
        }
        LibDynamicThing.p(ls.ldt, ptr);
    }

    function dump(LinkedStrings memory ls) internal pure returns (string[] memory ret) {
        uint256[] memory ptrs = LibDynamicThing.dump(ls.ldt);
        uint256 length = ptrs.length;
        ret = _allocateStringArr(length);
        assembly {
            for { let i := 0 } 1 {} {
                // hail solady
                let ptr := mload(add(ptrs, add(0x20, mul(i, 0x20))))
                mstore(add(ret, add(0x20, mul(i, 0x20))), ptr)
                i := add(i, 1)
                if iszero(lt(i, length)) { break }
            }
        }
        /* // does this
          uint256 length = ptrs.length;
          ret = new string[](length);
          uint256 ptr;
          string memory str;
          for (uint256 i; i < length; ++i) {
              ptr = ptrs[i];
              assembly {
                  str := ptr
              }
              ret[i] = str;
          }
        */
    }
}

library LibDynamicUint256Arr {
    struct LinkedUint256s {
        LibDynamicThing.LinkedThings ldt;
    }

    function newDynamicUint256Arr() internal pure returns (LinkedUint256s memory ret) {
        return LinkedUint256s(LibDynamicThing.newLinkedThings());
    }

    function p(LinkedUint256s memory ls, uint256 n) internal pure {
        LibDynamicThing.p(ls.ldt, n);
    }

    function dump(LinkedUint256s memory ls) internal pure returns (uint256[] memory ret) {
        ret = LibDynamicThing.dump(ls.ldt);
    }
}

library LibDynamicBuffer {
    struct DynamicBuffer {
        uint256 numThings; // not used. but for some reason having it as buffer reduces gas!?
        uint256 first;
        uint256 last;
    }

    struct Thing {
        uint256 ptr;
        uint256 next;
    }

    function newDynamicBuffer() internal pure returns (DynamicBuffer memory ret) {
        Thing memory first;
        assembly {
            mstore(add(ret, 0x20), first)
            mstore(add(ret, 0x40), first)
        }
    }

    function p(DynamicBuffer memory ls, bytes memory data) internal pure {
        LibDynamicThing.Thing memory t;
        assembly {
            mstore(t, data)
            let newPtr := t
            let lastPtr := mload(add(ls, 0x40))

            mstore(add(lastPtr, 0x20), newPtr)
            mstore(add(ls, 0x40), newPtr)
        }
    }

    // will need concat but had issues w it so deprecated it

    function getBuffer(DynamicBuffer memory lts) internal pure returns (bytes memory ret) {
        assembly {
            ret := mload(0x40)

            let len := 0x20 // offset

            let nextPtr := mload(add(lts, 0x20)) // lt.first
            for {} 1 {} {
                nextPtr := mload(add(nextPtr, 0x20)) // ptr to next LinkedThing

                if iszero(nextPtr) { break }

                let ptr := mload(nextPtr) // ptr to actual thing

                mcopy(add(ret, len), add(ptr, 0x20), mload(ptr))
                len := add(len, mload(ptr))
            }
            len := sub(len, 0x20) // undo offset

            mstore(0x40, add(ret, and(add(add(len, 0x20), 0x1f), not(0x1f))))
            mstore(ret, len)
        }
    }
}

library LibDynamicThing {
    struct LinkedThings {
        uint256 numThings;
        uint256 first;
        uint256 last;
    }

    struct Thing {
        uint256 ptr;
        uint256 next;
    }

    // will need concat but had issues w it so deprecated it

    function newLinkedThings() internal pure returns (LinkedThings memory ret) {
        Thing memory first;
        assembly {
            mstore(add(ret, 0x20), first)
            mstore(add(ret, 0x40), first)
        }

        /* // it does this ...
          Thing memory first;
          uint256 ptr;
          assembly {
              ptr := first
          }
          ret.first = ptr;
          ret.last = ptr;
       */
    }

    function p(LinkedThings memory lts, uint256 ptr) internal pure {
        Thing memory t;
        assembly {
            mstore(t, ptr)
            let newPtr := t
            let lastPtr := mload(add(lts, 0x40))

            mstore(add(lastPtr, 0x20), newPtr)
            mstore(add(lts, 0x40), newPtr)
            //mstore(lts, add(mload(lts), 1)) // TODO deprecate numThings
        }

        /*// it does this ...
          Thing memory t;
          t.ptr = ptr;
          uint256 newPtr;
          assembly {
              newPtr := t
          }
          uint256 lastPtr = lt.last;
          Thing memory lastThing;
          assembly {
              lastThing := lastPtr
          }
          lastThing.next = newPtr;
          lt.last = newPtr;
          ++lt.numThings;
        */
    }

    function dump(LinkedThings memory lts) internal pure returns (uint256[] memory ret) {
        assembly {
            ret := mload(0x40)
            let len
            let nextPtr := mload(add(lts, 0x20)) // lt.first
            for {} 1 {} {
                nextPtr := mload(add(nextPtr, 0x20))
                if iszero(nextPtr) { break }
                mstore(add(ret, add(0x20, mul(len, 0x20))), mload(nextPtr))
                len := add(len, 1)
            }
            mstore(0x40, add(ret, and(add(add(mul(len, 0x20), 0x20), 0x1f), not(0x1f))))
            mstore(ret, len)
        }

        /* // it does this ..
            uint256 length = lts.numThings;
            ret = new uint256[](length);
            uint256 length = lt.numThings;
            ret = new uint256[](length);
            Thing memory t;
            uint256 nextPtr = lt.first;
            assembly {
                t := nextPtr
            }
            for (uint256 i; i < length; ++i) {
                nextPtr = t.next;
                assembly {
                    t := nextPtr
                }
                ret[i] = t.ptr;
            }
        */
    }
}
// SPDX-License-Identifier: VPL - VIRAL PUBLIC LICENSE
pragma solidity ^0.8.25;

import "lib/solady/src/utils/LibBit.sol";

import {LibDynamicBuffer} from "./LibDynamicThing.sol";
import "./Append.sol";
import "./Errors.sol";

library LibPack {
    function packBytesArrs(bytes[] memory arrs) internal pure returns (bytes memory ret) {
        uint256[] memory positions = new uint256[](arrs.length);
        uint256 position;
        for (uint256 i; i < positions.length; ++i) {
            positions[i] = position;
            position += arrs[i].length;
        }
        bytes memory packedPositions = packUint256s(positions);
        uint256[] memory lengthPacked = new uint256[](1);
        lengthPacked[0] = packedPositions.length;
        bytes memory packedLengthPacked = packUint256s(lengthPacked);
        LibDynamicBuffer.DynamicBuffer memory db = LibDynamicBuffer.newDynamicBuffer();
        LibDynamicBuffer.p(db, packedLengthPacked);
        LibDynamicBuffer.p(db, packedPositions);
        for (uint256 i; i < arrs.length; ++i) {
            LibDynamicBuffer.p(db, arrs[i]);
        }
        ret = LibDynamicBuffer.getBuffer(db);
    }

    function bytesAt(bytes memory input, uint256 idx) internal pure returns (bytes memory ret) {
        uint256 packedPositionsLength = uint256At(input, 0);
        uint256 bound = uint256(uint8(input[0]));
        uint256 scratch = 1 + bound;
        uint256 start = scratch;
        bytes memory packedPositions = _allocateBytes(packedPositionsLength);
        assembly {
            mstore(packedPositions, 0)
        }
        _appendSubstring(packedPositions, input, start, start + packedPositionsLength);
        uint256[] memory positions = unpackBytesIntoUint256s(packedPositions);

        scratch += packedPositionsLength;
        start = scratch;
        uint256 position;
        uint256 end;
        for (uint256 i; i < positions.length; ++i) {
            assembly {
                position := mload(add(positions, add(0x20, mul(i, 0x20))))
                start := add(start, position)

                switch eq(i, sub(mload(positions), 1))
                case 1 { end := mload(input) }
                default { end := add(scratch, mload(add(positions, add(0x20, mul(add(i, 1), 0x20))))) }
            }
            if (i == idx) {
                ret = _allocateBytes(end - start);
                assembly {
                    mstore(ret, 0)
                }
                _appendSubstring(ret, input, start, end);
                return ret;
            }

            // reset start
            start = scratch;
        }
    }

    function unpackBytesIntoBytesArrs(bytes memory input) internal pure returns (bytes[] memory ret) {
        // assumes input is from pack function and thus is well-formed.. meaning overflows are not an issue
        unchecked {
            uint256 packedPositionsLength = uint256At(input, 0);
            uint256 bound = uint256(uint8(input[0]));
            uint256 scratch = 1 + bound;
            uint256 start = scratch;
            bytes memory packedPositions = _allocateBytes(packedPositionsLength);
            assembly {
                mstore(packedPositions, 0)
            }
            _appendSubstring(packedPositions, input, start, start + packedPositionsLength);
            uint256[] memory positions = unpackBytesIntoUint256s(packedPositions);

            ret = _allocateArr(positions.length);
            scratch += packedPositionsLength;
            start = scratch;
            uint256 position;
            uint256 end;
            for (uint256 i; i < positions.length; ++i) {
                assembly {
                    position := mload(add(positions, add(0x20, mul(i, 0x20))))
                    start := add(start, position)

                    switch eq(i, sub(mload(positions), 1))
                    case 1 { end := mload(input) }
                    default { end := add(scratch, mload(add(positions, add(0x20, mul(add(i, 1), 0x20))))) }
                }
                bytes memory _ret = _allocateBytes(end - start);
                assembly {
                    mstore(_ret, 0)
                }
                _appendSubstring(_ret, input, start, end);
                assembly {
                    mstore(add(ret, add(0x20, mul(i, 0x20))), _ret)

                    // reset start
                    start := scratch
                }
            }
        } //uc
    }

    function packUint256s(uint256[] memory arr) internal pure returns (bytes memory ret) {
        uint256 maxIdxMSB; // idx most significant bit
        uint256 idxMSB;
        unchecked {
            for (uint256 i; i < arr.length; ++i) {
                idxMSB = LibBit.fls(arr[i]);
                if (idxMSB == 256) continue;
                if (idxMSB > maxIdxMSB) maxIdxMSB = idxMSB;
            }
            uint256 bound = maxIdxMSB / 8 + 1;
            ret = new bytes(arr.length * bound + 1);
            uint256 retIdx;
            ret[retIdx++] = bytes1(uint8(bound));
            uint256 n;
            for (uint256 i; i < arr.length; ++i) {
                n = arr[i];
                for (uint256 j; j < bound; ++j) {
                    ret[retIdx++] = bytes1(uint8(n >> (8 * j)));
                }
            }
        } // uc
    }

    function uint256At(bytes memory packed, uint256 idx) internal pure returns (uint256 ret) {
        if (packed.length < 1) revert InvalidInput_error();
        unchecked {
            uint256 bound = uint256(uint8(packed[0]));
            assembly {
                idx := add(mul(idx, bound), 1)
                for { let j := 0 } 1 {} {
                    let shift := mul(8, j)

                    let r := byte(0, mload(add(packed, add(0x20, idx))))
                    r := shl(shift, r)

                    ret := or(ret, r)

                    idx := add(idx, 1)
                    j := add(j, 1)
                    if iszero(lt(j, bound)) { break }
                }
            }
        } // uc
    }

    function unpackBytesIntoUint256s(bytes memory packed) internal pure returns (uint256[] memory ret) {
        uint256 idx;
        if (packed.length < 1) revert InvalidInput_error();
        unchecked {
            uint256 bound = uint256(uint8(packed[idx++]));
            ret = _allocateUintArr((packed.length - 1) / bound);
            assembly {
                let length := mload(ret)
                for { let i := 0 } 1 {} {
                    let n := 0
                    for { let j := 0 } 1 {} {
                        let shift := mul(8, j)

                        let r := byte(0, mload(add(packed, add(0x20, idx))))
                        r := shl(shift, r)

                        n := or(n, r)
                        idx := add(idx, 1)
                        j := add(j, 1)
                        if iszero(lt(j, bound)) { break }
                    }
                    mstore(add(ret, add(0x20, mul(i, 0x20))), n)
                    i := add(i, 1)
                    if iszero(lt(i, length)) { break }
                }
            }
        } // uc

        // does this ...
        /*
        unchecked {
            if (packed.length < ret.length * bound) revert InvalidInput_error();
            uint256 n;
            for (uint256 i; i < ret.length; ++i) {
                n = 0;
                for (uint256 j; j < bound; ++j) {
                    n |= (uint256(uint8(packed[idx++])) << (8 * j));
                }
                ret[i] = n;
            }
        } // uc
       */
    }

    function decomposeZ(int256 z) internal pure returns (bool negative, uint256 n) {
        unchecked {
            if (z < int256(0)) return (true, ~uint256(z) + 1);
            return (false, uint256(z));
        } // uc
    }

    function packInt256s(int256[] memory arr) internal pure returns (bytes memory ret) {
        uint256 length = arr.length;
        uint256[] memory us = new uint256[](length);
        bool negative;
        uint256 n;
        for (uint256 i; i < arr.length; ++i) {
            (negative, n) = decomposeZ(arr[i]);
            n = n << 1;
            us[i] = n;
            if (negative) {
                us[i] |= 0x1;
            }
        }
        ret = packUint256s(us);
    }

    function int256At(bytes memory packed, uint256 idx) internal pure returns (int256 ret) {
        uint256 n = uint256At(packed, idx);
        ret = int256(n >> 1);
        if (n & 0x1 == 0x1) ret *= -1;
    }

    function unpackBytesIntoInt256s(bytes memory packed) internal pure returns (int256[] memory ret) {
        uint256 idx;
        if (packed.length < 1) revert InvalidInput_error();
        unchecked {
            uint256 bound = uint256(uint8(packed[idx++]));
            if (bound < 1) revert InvalidInput_error();
            uint256 length = (packed.length - 1) / bound;
            ret = _allocateIntArr(length);
            assembly {
                for { let i := 0 } 1 {} {
                    let n := 0
                    for { let j := 0 } 1 {} {
                        let shift := mul(8, j)

                        let r := byte(0, mload(add(packed, add(0x20, idx))))
                        r := shl(shift, r)

                        n := or(n, r)
                        idx := add(idx, 1)
                        j := add(j, 1)
                        if iszero(lt(j, bound)) { break }
                    }
                    let ptr := add(ret, add(0x20, mul(i, 0x20)))
                    mstore(ptr, shr(1, n))
                    if and(n, 0x1) { mstore(ptr, sub(0, mload(ptr))) }
                    i := add(i, 1)
                    if iszero(lt(i, length)) { break }
                }
            }
        } // uc

        /* // does this ...
        uint256[] memory us = unpackBytesIntoUint256s(packed);
        uint256 length = us.length;
        uint256 n;
        for (uint256 i; i < length; ++i) {
            n = us[i];
            ret[i] = int256(n >> 1);
            if (n & 0x1 == 0x1) ret[i] *= -1;
        }
       */
    }

    function packAddresses(address[] memory arr) internal pure returns (bytes memory ret) {
        uint256 bound = 20;
        ret = new bytes(arr.length * bound);
        uint256 retIdx;
        uint256 n;
        for (uint256 i; i < arr.length; ++i) {
            n = uint256(uint160(arr[i]));
            for (uint256 j; j < bound; ++j) {
                ret[retIdx++] = bytes1(uint8(n >> (8 * j)));
            }
        }
    }

    function addressAt(bytes memory packed, uint256 idx) internal pure returns (address ret) {
        if (packed.length < 1) revert InvalidInput_error();
        unchecked {
            idx = idx * 20; // no +1 since know bound
            uint256 n;
            for (uint256 j; j < 20; ++j) {
                n |= (uint256(uint8(packed[idx++])) << (8 * j));
            }
            ret = address(uint160(n));
        } // uc
    }

    function unpackBytesIntoAddresses(bytes memory packed) internal pure returns (address[] memory ret) {
        uint256 idx;
        if (packed.length < 1) revert InvalidInput_error();
        unchecked {
            ret = new address[](packed.length / 20); // no +1 since know bound
            if (packed.length < ret.length * 20) revert InvalidInput_error();
            uint256 n;
            for (uint256 i; i < ret.length; ++i) {
                n = 0;
                for (uint256 j; j < 20; ++j) {
                    n |= (uint256(uint8(packed[idx++])) << (8 * j));
                }
                ret[i] = address(uint160(n));
            }
        } // uc
    }
}
// SPDX-License-Identifier: VPL - VIRAL PUBLIC LICENSE
pragma solidity ^0.8.25;

import "./Append.sol";

library MemoryMappings {
    struct MemoryMapping {
        bool sorted; // more efficient read/write when NOT sorted
        // note sorted only for uint256/bytes32 NOT for bytes key
        bool overwrite;
        uint256 totalKeys;
        Tree tree;
    }

    function newMemoryMapping(bool sorted, bool overwrite) internal pure returns (MemoryMapping memory) {
        return MemoryMapping({sorted: sorted, overwrite: overwrite, totalKeys: 0, tree: newNode()});
    }

    function newMemoryMapping(bool sorted, bool overwrite, bytes32 key, bytes memory value)
        internal
        pure
        returns (MemoryMapping memory)
    {
        bytes32 ogKey = key;
        if (!sorted) {
            assembly {
                mstore(0x0, key)
                key := keccak256(0x0, 0x20)
            }
        }
        return MemoryMapping({
            sorted: sorted,
            overwrite: overwrite,
            totalKeys: 1,
            tree: newNode(uint256(key), uint256(ogKey), bytes(""), value)
        });
    }

    function add(MemoryMapping memory mm, bytes32 key, bytes32 value) internal pure {
        _add(mm, key, bytes(""), value);
    }

    function add(MemoryMapping memory mm, bytes32 key, bytes memory bValue) internal pure {
        _add(mm, key, bytes(""), bValue);
    }

    function add(MemoryMapping memory mm, bytes memory bKey, bytes memory value) internal pure {
        if (bKey.length < 1) return;
        _add(mm, keccak256(bKey), bKey, value);
    }

    function add(MemoryMapping memory mm, bytes memory bKey, bytes32 value) internal pure {
        bytes memory bValue = _allocateBytes(32);
        assembly {
            mstore(add(bValue, 0x20), value)
        }
        _add(mm, keccak256(bKey), bKey, bValue);
    }

    function _add(MemoryMapping memory mm, bytes32 key, bytes memory bKey, bytes32 value) private pure {
        bytes memory bValue = _allocateBytes(32);
        assembly {
            mstore(add(bValue, 0x20), value)
        }
        _add(mm, key, bKey, bValue);
    }

    function _add(MemoryMapping memory mm, bytes32 key, bytes memory bKey, bytes memory value) private pure {
        bytes32 ogKey = key;
        if (!mm.sorted) {
            assembly {
                mstore(0x0, key)
                key := keccak256(0x0, 0x20)
            }
        }
        bool existed = add(mm.tree, mm.overwrite, uint256(key), uint256(ogKey), bKey, value);
        unchecked {
            if (!existed) ++mm.totalKeys;
        } //uc
    }

    function get(MemoryMapping memory mm, bytes32 key) internal pure returns (bool ok, bytes memory ret) {
        if (!mm.sorted) {
            assembly {
                mstore(0x0, key)
                key := keccak256(0x0, 0x20)
            }
        }
        Tree memory node = get(mm.tree, uint256(key));
        if (node.exists) {
            ok = true;
            assembly {
                ret := mload(add(node, 0x80))
            }
        }
    }

    function get(MemoryMapping memory mm, bytes memory key) internal pure returns (bool ok, bytes memory ret) {
        return get(mm, keccak256(key));
    }

    function dumpKeys(MemoryMapping memory mm) internal pure returns (uint256[] memory keys) {
        uint256 totalKeys = mm.totalKeys;
        if (totalKeys < 1) return keys;
        keys = _allocateUintArr(totalKeys);
        assembly {
            mstore(keys, 0)
        }
        readInto(mm.tree, 0, keys);
    }

    function dumpKeyBytes(MemoryMapping memory mm) internal pure returns (bytes[] memory keys) {
        uint256 totalKeys = mm.totalKeys;
        if (totalKeys < 1) return keys;
        keys = _allocateArr(totalKeys);
        assembly {
            mstore(keys, 0)
        }
        readInto(mm.tree, 0, keys);
    }

    function dumpBytes(MemoryMapping memory mm) internal pure returns (uint256[] memory keys, bytes[] memory values) {
        uint256 totalKeys = mm.totalKeys;
        if (totalKeys < 1) return (keys, values);
        keys = _allocateUintArr(totalKeys);
        values = _allocateArr(totalKeys);
        assembly {
            mstore(keys, 0)
            mstore(values, 0)
        }
        readInto(mm.tree, 0, keys, values);
    }

    function dumpBothBytes(MemoryMapping memory mm)
        internal
        pure
        returns (bytes[] memory keys, bytes[] memory values)
    {
        uint256 totalKeys = mm.totalKeys;
        if (totalKeys < 1) return (keys, values);
        keys = _allocateArr(totalKeys);
        values = _allocateArr(totalKeys);
        assembly {
            mstore(keys, 0)
            mstore(values, 0)
        }
        readInto(mm.tree, 0, keys, values);
    }

    function dumpUint256s(MemoryMapping memory mm)
        internal
        pure
        returns (uint256[] memory keys, uint256[] memory values)
    {
        uint256 totalKeys = mm.totalKeys;
        if (totalKeys < 1) return (keys, values);
        keys = _allocateUintArr(totalKeys);
        values = _allocateUintArr(totalKeys);
        assembly {
            mstore(keys, 0)
            mstore(values, 0)
        }
        readInto(mm.tree, 0, keys, values);
    }

    // Tree

    struct Tree {
        bool exists;
        uint256 key; // sort by key in descending order max -> min
        uint256 ogKey;
        bytes bKey;
        bytes payload; // optional arbitrary payload
        Tree[] neighbors; // 0-left, 1-right
    }

    function newNode() internal pure returns (Tree memory) {
        Tree memory tree;
        tree.neighbors = new Tree[](2);
        return tree;
    }

    function newNode(uint256 key, uint256 ogKey, bytes memory bKey, bytes memory payload)
        internal
        pure
        returns (Tree memory)
    {
        return Tree({exists: true, key: key, ogKey: ogKey, bKey: bKey, payload: payload, neighbors: new Tree[](2)});
    }

    function fillNode(Tree memory tree, uint256 key, uint256 ogKey, bytes memory bKey, bytes memory payload)
        internal
        pure
    {
        tree.exists = true;
        tree.key = key;
        tree.ogKey = ogKey;
        tree.bKey = bKey;
        tree.payload = payload;
    }

    function add(Tree memory tree, bool overwrite, uint256 key, uint256 ogKey, bytes memory bKey, bytes memory payload)
        internal
        pure
        returns (bool existed)
    {
        if (!tree.exists) {
            fillNode(tree, key, ogKey, bKey, payload);
            return false;
        }
        uint256 idx;
        if (key == tree.key) {
            if (overwrite) {
                tree.payload = payload;
            }
            return true;
        }

        if (tree.key > key) idx = 1;
        if (tree.neighbors[idx].exists) {
            return add(tree.neighbors[idx], overwrite, key, ogKey, bKey, payload);
        }
        tree.neighbors[idx] = newNode(key, ogKey, bKey, payload);
        return false;
    }

    function get(Tree memory tree, uint256 key) internal pure returns (Tree memory) {
        if (tree.exists) {
            uint256 _key = tree.key;
            if (_key < key) {
                return get(tree.neighbors[0], key);
            } else if (_key > key) {
                return get(tree.neighbors[1], key);
            }
        } // else dne
        return tree;
    }

    function readInto(Tree memory tree, uint256 idx, uint256[] memory arrayA) internal pure returns (uint256) {
        Tree memory other = tree.neighbors[0];
        if (other.exists) idx = readInto(other, idx, arrayA); // left
        // center

        // assembly does this:

        //arrayA[idx++] = tree.key;

        assembly {
            // assumes arrays come in allocated BUT have their length initialized to 0 so will know how many added
            mstore(arrayA, add(mload(arrayA), 1))

            mstore(add(arrayA, add(0x20, mul(idx, 0x20))), mload(add(tree, 0x40)))
            idx := add(idx, 1)
        }
        other = tree.neighbors[1];
        if (other.exists) idx = readInto(other, idx, arrayA); // right
        return idx;
    }

    function readInto(Tree memory tree, uint256 idx, bytes[] memory arrayA) internal pure returns (uint256) {
        Tree memory other = tree.neighbors[0];
        if (other.exists) idx = readInto(other, idx, arrayA); // left
        // center

        // assembly does this:

        //arrayA[idx++] = tree.key;

        assembly {
            // assumes arrays come in allocated BUT have their length initialized to 0 so will know how many added
            mstore(arrayA, add(mload(arrayA), 1))

            mstore(add(arrayA, add(0x20, mul(idx, 0x20))), mload(add(tree, 0x60)))
            idx := add(idx, 1)
        }
        other = tree.neighbors[1];
        if (other.exists) idx = readInto(other, idx, arrayA); // right
        return idx;
    }

    function readInto(Tree memory tree, uint256 idx, uint256[] memory arrayA, bytes[] memory arrayB)
        internal
        pure
        returns (uint256)
    {
        Tree memory other = tree.neighbors[0];
        if (other.exists) idx = readInto(other, idx, arrayA, arrayB); // left
        // center

        // assembly does this:

        //arrayA[idx] = tree.key;
        //arrayB[idx++] = tree.payload;

        assembly {
            // assumes arrays come in allocated BUT have their length initialized to 0 so will know how many added
            mstore(arrayA, add(mload(arrayA), 1))
            mstore(arrayB, add(mload(arrayB), 1))

            mstore(add(arrayA, add(0x20, mul(idx, 0x20))), mload(add(tree, 0x40)))

            mstore(add(arrayB, add(0x20, mul(idx, 0x20))), mload(add(tree, 0x80)))
            idx := add(idx, 1)
        }
        other = tree.neighbors[1];
        if (other.exists) idx = readInto(other, idx, arrayA, arrayB); // right
        return idx;
    }

    function readInto(Tree memory tree, uint256 idx, bytes[] memory arrayA, bytes[] memory arrayB)
        internal
        pure
        returns (uint256)
    {
        Tree memory other = tree.neighbors[0];
        if (other.exists) idx = readInto(other, idx, arrayA, arrayB); // left
        // center

        // assembly does this:

        //arrayA[idx] = tree.key;
        //arrayB[idx++] = tree.payload;

        assembly {
            // assumes arrays come in allocated BUT have their length initialized to 0 so will know how many added
            mstore(arrayA, add(mload(arrayA), 1))
            mstore(arrayB, add(mload(arrayB), 1))

            mstore(add(arrayA, add(0x20, mul(idx, 0x20))), mload(add(tree, 0x60)))

            mstore(add(arrayB, add(0x20, mul(idx, 0x20))), mload(add(tree, 0x80)))
            idx := add(idx, 1)
        }
        other = tree.neighbors[1];
        if (other.exists) idx = readInto(other, idx, arrayA, arrayB); // right
        return idx;
    }

    function readInto(Tree memory tree, uint256 idx, uint256[] memory arrayA, uint256[] memory arrayB)
        internal
        pure
        returns (uint256)
    {
        Tree memory other = tree.neighbors[0];
        if (other.exists) idx = readInto(other, idx, arrayA, arrayB); // left
        // center

        // assembly does this:

        //arrayA[idx] = tree.key;
        //arrayB[idx++] = abi.decode(tree.payload, (uint256));

        assembly {
            // assumes arrays come in allocated BUT have their length initialized to 0 so will know how many added
            mstore(arrayA, add(mload(arrayA), 1))
            mstore(arrayB, add(mload(arrayB), 1))

            mstore(add(arrayA, add(0x20, mul(idx, 0x20))), mload(add(tree, 0x40)))

            mstore(add(arrayB, add(0x20, mul(idx, 0x20))), mload(add(mload(add(tree, 0x80)), 0x20)))
            idx := add(idx, 1)
        }
        other = tree.neighbors[1];
        if (other.exists) idx = readInto(other, idx, arrayA, arrayB); // right
        return idx;
    }
}
// SPDX-License-Identifier: VPL - VIRAL PUBLIC LICENSE
pragma solidity ^0.8.25;

import "./Interfaces.sol";
import "./Errors.sol";

abstract contract Refunds is IRefunds {
    IRefunder public refunder;

    function _setRefunder(IRefunder refunder_) internal {
        if (address(refunder) != address(0)) revert AlreadySet_error();
        refunder = refunder_;
    }

    function refundAvailable(address account) external view returns (uint256) {
        return refunder.refundAvailable(account);
    }

    function claimRefund() external {
        return refunder.claimRefund(msg.sender);
    }

    function _setRefund(address account, uint256 amount) internal {
        return refunder.setRefund{value: amount}(account);
    }
}
// SPDX-License-Identifier: VPL - VIRAL PUBLIC LICENSE
pragma solidity ^0.8.25;

import "lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

import "./FixedPoint.sol";

struct Supply {
    uint128 totalSupply;
    uint128 totalMinted;
}

struct ImmortalizeCollectionData {
    CollectionNames names;
    bytes32 encrypted; // if ANY frame has encrypted reference then this must be set
    uint256[] featuredFrameIds;
    FileBundle compressedCollectionData;
    MintEconomics mintEconomics;
    DiscountData dd;
    address to;
    uint256 nftVersionId;
    bytes auxData;
}

struct CollectionNames {
    string name;
    string symbol;
    string description;
    bool walker;
}

enum MintPricingType {
    TIMED,
    BATCHED
}

struct MintEconomics {
    uint256 curatorShare;
    uint256 mintStarts;
    uint256 mintEnds;
    uint256 maxFreeMintsPerTx;
    uint256 burnWindow;
    MintPricingType mintPricingType;
    uint256 maxSupply;
    uint256[] mintCheckpoints;
    uint256[] mintPrices;
    uint96 feeNumerator;
}

struct ExclusivityData {
    uint64 exclusivityWindow; // uint32 is too small
    uint112 premiumAccessMax;
    uint112 premiumAccessPrice;
}

struct DiscountData {
    IERC721[] discountedCollections;
    uint256[] discountFactors;
}

/////////////////////////

/*
// reference
struct Tab {
    bytes[] attributes;
    bytes[] colorClasses;
    uint256 dimension;
    bytes[] paths;
}
*/

struct RenderedCollectionData {
    string[][2] attributes;
    string[][2] colorClasses;
    string sSvg;
    FixedPoint.FP resolution;
}

struct Frame {
    uint256 dimension; // validated so that all children tabs match dimension
    bytes[] attributes; // {face: pretty, .. etc}
    uint256[] tabProbabilities; // can be len=0 if a walker
    uint256[] tabIds; // checked against payment splitter on render
    bytes forkAttributeKey;
    uint256[] forkProbabilities; // can be len=0 if a walker
    Fork[] forks;
}

struct Fork {
    bytes forkAttributeValue;
    uint256[] frameIds; // checked against payment splitter on render
    uint256[] footprints; // footprint & dimension gives scale
    uint256[] positions; // array w len%2=0 for obvs reasons.. x,y..
}

struct CollectionData {
    bytes32 idxBlinder;
    uint256[] frameProbabilities; // can be len=0 if a walker
    uint256[] frameIds; // checked against payment splitter on render, see _validatePayeeConficguration
    ColorClassOverride[] colorClassOverrides;
}

struct ColorClassOverride {
    bytes colorClass;
    uint256[] probabilityKeys; // can be len=0 if a walker
    bytes[] colorClassValues;
    bytes[] colorClassAliases;
}

enum Type {
    NONE,
    TAB,
    TAB_ENCRYPTED,
    FRAME,
    FRAME_ENCRYPTED,
    COLLECTION,
    COLLECTION_ENCRYPTED
}

enum Validity {
    UNKNOWN,
    PENDING_DECRYPTION,
    VALID,
    INVALID
}

struct Point {
    uint256 x;
    uint256 y;
}

struct PointAndBounded {
    Point p;
    Point b;
}

struct UIBasicData {
    Type t;
    uint256 tokenId;
    bool burned;
    bool encrypted;
    uint256 pledgedRevealTimestamp;
    CollectionNames names;
    MintEconomics mintEconomics;
    ExclusivityData exclusivityData;
    Supply exclusivitySupply;
    address owner; // obviously can change and should prompt updates
    string website;
}

struct CounterPtr {
    uint256 tally;
}

struct FileBundle {
    bytes compressedFile;
    bytes[] chunks;
}

enum JSONType {
    STRING,
    DATE,
    NUMBER,
    ARRAY,
    OBJ
}

struct JSON {
    JSONType t;
    bytes data;
}

enum RevealedStatus {
    PENDING,
    REVEALED
}
// SPDX-License-Identifier: VPL - VIRAL PUBLIC LICENSE
pragma solidity ^0.8.25;

import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

abstract contract Withdrawable {
    error FailedCall_error();

    function withdrawETH(address to, uint256 amount) public virtual {
        _onlyOwner();
        (bool success,) = to.call{value: amount}("");
        if (!success) revert FailedCall_error();
    }

    function withdrawERC20(IERC20 token, address to, uint256 amount) public {
        _onlyOwner();
        token.transfer(to, amount);
    }

    function _onlyOwner() internal view virtual;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "lib/openzeppelin-contracts/contracts/token/common/ERC2981.sol";

/**
 * @title BasicRoyaltiesBase
 * @author Limit Break, Inc.
 * @dev Base functionality of an NFT mix-in contract implementing the most basic form of programmable royalties.
 */
abstract contract BasicRoyaltiesBase is ERC2981 {
    event DefaultRoyaltySet(address indexed receiver, uint96 feeNumerator);
    event TokenRoyaltySet(uint256 indexed tokenId, address indexed receiver, uint96 feeNumerator);

    function _setDefaultRoyalty(address receiver, uint96 feeNumerator) internal virtual override {
        super._setDefaultRoyalty(receiver, feeNumerator);
        emit DefaultRoyaltySet(receiver, feeNumerator);
    }

    function _setTokenRoyalty(uint256 tokenId, address receiver, uint96 feeNumerator) internal virtual override {
        super._setTokenRoyalty(tokenId, receiver, feeNumerator);
        emit TokenRoyaltySet(tokenId, receiver, feeNumerator);
    }
}

/**
 * @title BasicRoyalties
 * @author Limit Break, Inc.
 * @notice Constructable BasicRoyalties Contract implementation.
 */
abstract contract BasicRoyalties is BasicRoyaltiesBase {
    constructor(address receiver, uint96 feeNumerator) {
        _setDefaultRoyalty(receiver, feeNumerator);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "lib/openzeppelin-contracts/contracts/interfaces/IERC165.sol";

import "./OwnablePermissions.sol";
import "./ICreatorToken.sol";
import "./ICreatorTokenTransferValidator.sol";
import "./TransferValidation.sol";

/**
 * @title CreatorTokenBase
 * @author Limit Break, Inc.
 * @notice CreatorTokenBase is an abstract contract that provides basic functionality for managing token
 * transfer policies through an implementation of ICreatorTokenTransferValidator. This contract is intended to be used
 * as a base for creator-specific token contracts, enabling customizable transfer restrictions and security policies.
 *
 * <h4>Features:</h4>
 * <ul>Ownable: This contract can have an owner who can set and update the transfer validator.</ul>
 * <ul>TransferValidation: Implements the basic token transfer validation interface.</ul>
 * <ul>ICreatorToken: Implements the interface for creator tokens, providing view functions for token security policies.</ul>
 *
 * <h4>Benefits:</h4>
 * <ul>Provides a flexible and modular way to implement custom token transfer restrictions and security policies.</ul>
 * <ul>Allows creators to enforce policies such as whitelisted operators and permitted contract receivers.</ul>
 * <ul>Can be easily integrated into other token contracts as a base contract.</ul>
 *
 * <h4>Intended Usage:</h4>
 * <ul>Use as a base contract for creator token implementations that require advanced transfer restrictions and
 *   security policies.</ul>
 * <ul>Set and update the ICreatorTokenTransferValidator implementation contract to enforce desired policies for the
 *   creator token.</ul>
 */
abstract contract CreatorTokenBase is OwnablePermissions, TransferValidation, ICreatorToken {
    error CreatorTokenBase__InvalidTransferValidatorContract();
    error CreatorTokenBase__SetTransferValidatorFirst();

    address public constant DEFAULT_TRANSFER_VALIDATOR = address(0x0000721C310194CcfC01E523fc93C9cCcFa2A0Ac);
    TransferSecurityLevels public constant DEFAULT_TRANSFER_SECURITY_LEVEL = TransferSecurityLevels.One;
    uint120 public constant DEFAULT_OPERATOR_WHITELIST_ID = uint120(1);

    ICreatorTokenTransferValidator private transferValidator;

    /**
     * @notice Allows the contract owner to set the transfer validator to the official validator contract
     *         and set the security policy to the recommended default settings.
     * @dev    May be overridden to change the default behavior of an individual collection.
     */
    function setToDefaultSecurityPolicy() public virtual {
        _requireCallerIsContractOwner();
        setTransferValidator(DEFAULT_TRANSFER_VALIDATOR);
        ICreatorTokenTransferValidator(DEFAULT_TRANSFER_VALIDATOR).setTransferSecurityLevelOfCollection(
            address(this), DEFAULT_TRANSFER_SECURITY_LEVEL
        );
        ICreatorTokenTransferValidator(DEFAULT_TRANSFER_VALIDATOR).setOperatorWhitelistOfCollection(
            address(this), DEFAULT_OPERATOR_WHITELIST_ID
        );
    }

    /**
     * @notice Allows the contract owner to set the transfer validator to a custom validator contract
     *         and set the security policy to their own custom settings.
     */
    function setToCustomValidatorAndSecurityPolicy(
        address validator,
        TransferSecurityLevels level,
        uint120 operatorWhitelistId,
        uint120 permittedContractReceiversAllowlistId
    ) public virtual {
        _requireCallerIsContractOwner();

        setTransferValidator(validator);

        ICreatorTokenTransferValidator(validator).setTransferSecurityLevelOfCollection(address(this), level);

        ICreatorTokenTransferValidator(validator).setOperatorWhitelistOfCollection(address(this), operatorWhitelistId);

        ICreatorTokenTransferValidator(validator).setPermittedContractReceiverAllowlistOfCollection(
            address(this), permittedContractReceiversAllowlistId
        );
    }

    /**
     * @notice Allows the contract owner to set the security policy to their own custom settings.
     * @dev    Reverts if the transfer validator has not been set.
     */
    function setToCustomSecurityPolicy(
        TransferSecurityLevels level,
        uint120 operatorWhitelistId,
        uint120 permittedContractReceiversAllowlistId
    ) public virtual {
        _requireCallerIsContractOwner();

        ICreatorTokenTransferValidator validator = getTransferValidator();
        if (address(validator) == address(0)) {
            revert CreatorTokenBase__SetTransferValidatorFirst();
        }

        validator.setTransferSecurityLevelOfCollection(address(this), level);
        validator.setOperatorWhitelistOfCollection(address(this), operatorWhitelistId);
        validator.setPermittedContractReceiverAllowlistOfCollection(
            address(this), permittedContractReceiversAllowlistId
        );
    }

    /**
     * @notice Sets the transfer validator for the token contract.
     *
     * @dev    Throws when provided validator contract is not the zero address and doesn't support
     *         the ICreatorTokenTransferValidator interface.
     * @dev    Throws when the caller is not the contract owner.
     *
     * @dev    <h4>Postconditions:</h4>
     *         1. The transferValidator address is updated.
     *         2. The `TransferValidatorUpdated` event is emitted.
     *
     * @param transferValidator_ The address of the transfer validator contract.
     */
    function setTransferValidator(address transferValidator_) public virtual {
        _requireCallerIsContractOwner();

        bool isValidTransferValidator = false;

        if (transferValidator_.code.length > 0) {
            try IERC165(transferValidator_).supportsInterface(type(ICreatorTokenTransferValidator).interfaceId)
            returns (bool supportsInterface) {
                isValidTransferValidator = supportsInterface;
            } catch {}
        }

        if (transferValidator_ != address(0) && !isValidTransferValidator) {
            revert CreatorTokenBase__InvalidTransferValidatorContract();
        }

        emit TransferValidatorUpdated(address(transferValidator), transferValidator_);

        transferValidator = ICreatorTokenTransferValidator(transferValidator_);
    }

    /**
     * @notice Returns the transfer validator contract address for this token contract.
     */
    function getTransferValidator() public view override returns (ICreatorTokenTransferValidator) {
        return transferValidator;
    }

    /**
     * @notice Returns the security policy for this token contract, which includes:
     *         Transfer security level, operator whitelist id, permitted contract receiver allowlist id.
     */
    function getSecurityPolicy() public view override returns (CollectionSecurityPolicy memory) {
        if (address(transferValidator) != address(0)) {
            return transferValidator.getCollectionSecurityPolicy(address(this));
        }

        return CollectionSecurityPolicy({
            transferSecurityLevel: TransferSecurityLevels.Zero,
            operatorWhitelistId: 0,
            permittedContractReceiversId: 0
        });
    }

    /**
     * @notice Returns the list of all whitelisted operators for this token contract.
     * @dev    This can be an expensive call and should only be used in view-only functions.
     */
    function getWhitelistedOperators() public view override returns (address[] memory) {
        if (address(transferValidator) != address(0)) {
            return transferValidator.getWhitelistedOperators(
                transferValidator.getCollectionSecurityPolicy(address(this)).operatorWhitelistId
            );
        }

        return new address[](0);
    }

    /**
     * @notice Returns the list of permitted contract receivers for this token contract.
     * @dev    This can be an expensive call and should only be used in view-only functions.
     */
    function getPermittedContractReceivers() public view override returns (address[] memory) {
        if (address(transferValidator) != address(0)) {
            return transferValidator.getPermittedContractReceivers(
                transferValidator.getCollectionSecurityPolicy(address(this)).permittedContractReceiversId
            );
        }

        return new address[](0);
    }

    /**
     * @notice Checks if an operator is whitelisted for this token contract.
     * @param operator The address of the operator to check.
     */
    function isOperatorWhitelisted(address operator) public view override returns (bool) {
        if (address(transferValidator) != address(0)) {
            return transferValidator.isOperatorWhitelisted(
                transferValidator.getCollectionSecurityPolicy(address(this)).operatorWhitelistId, operator
            );
        }

        return false;
    }

    /**
     * @notice Checks if a contract receiver is permitted for this token contract.
     * @param receiver The address of the receiver to check.
     */
    function isContractReceiverPermitted(address receiver) public view override returns (bool) {
        if (address(transferValidator) != address(0)) {
            return transferValidator.isContractReceiverPermitted(
                transferValidator.getCollectionSecurityPolicy(address(this)).permittedContractReceiversId, receiver
            );
        }

        return false;
    }

    /**
     * @notice Determines if a transfer is allowed based on the token contract's security policy.  Use this function
     *         to simulate whether or not a transfer made by the specified `caller` from the `from` address to the `to`
     *         address would be allowed by this token's security policy.
     *
     * @notice This function only checks the security policy restrictions and does not check whether token ownership
     *         or approvals are in place.
     *
     * @param caller The address of the simulated caller.
     * @param from   The address of the sender.
     * @param to     The address of the receiver.
     * @return       True if the transfer is allowed, false otherwise.
     */
    function isTransferAllowed(address caller, address from, address to) public view override returns (bool) {
        if (address(transferValidator) != address(0)) {
            try transferValidator.applyCollectionTransferPolicy(caller, from, to) {
                return true;
            } catch {
                return false;
            }
        }
        return true;
    }

    /**
     * @dev Pre-validates a token transfer, reverting if the transfer is not allowed by this token's security policy.
     *      Inheriting contracts are responsible for overriding the _beforeTokenTransfer function, or its equivalent
     *      and calling _validateBeforeTransfer so that checks can be properly applied during token transfers.
     *
     * @dev Throws when the transfer doesn't comply with the collection's transfer policy, if the transferValidator is
     *      set to a non-zero address.
     *
     * @param caller  The address of the caller.
     * @param from    The address of the sender.
     * @param to      The address of the receiver.
     */
    function _preValidateTransfer(address caller, address from, address to, uint256, /*tokenId*/ uint256 /*value*/ )
        internal
        virtual
        override
    {
        if (address(transferValidator) != address(0)) {
            transferValidator.applyCollectionTransferPolicy(caller, from, to);
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "lib/solady/src/tokens/ERC721.sol";

import "./CreatorTokenBase.sol";

// modified by no_side666 to favor the solady library

/**
 * @title ERC721C
 * @author Limit Break, Inc.
 * @notice Extends OpenZeppelin's ERC721 implementation with Creator Token functionality, which
 *         allows the contract owner to update the transfer validation logic by managing a security policy in
 *         an external transfer validation security policy registry.  See {CreatorTokenTransferValidator}.
 */
abstract contract ERC721C is ERC721, CreatorTokenBase {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(ICreatorToken).interfaceId || super.supportsInterface(interfaceId);
    }

    /// @dev Ties the solady _beforeTokenTransfer hook to more granular transfer validation logic
    function _beforeTokenTransfer(address from, address to, uint256 id) internal virtual override {
        _validateBeforeTransfer(from, to, id);
    }

    /// @dev Ties the solady _afterTokenTransfer hook to more granular transfer validation logic
    function _afterTokenTransfer(address from, address to, uint256 id) internal virtual override {
        _validateAfterTransfer(from, to, id);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ICreatorTokenTransferValidator.sol";

interface ICreatorToken {
    event TransferValidatorUpdated(address oldValidator, address newValidator);

    function getTransferValidator() external view returns (ICreatorTokenTransferValidator);
    function getSecurityPolicy() external view returns (CollectionSecurityPolicy memory);
    function getWhitelistedOperators() external view returns (address[] memory);
    function getPermittedContractReceivers() external view returns (address[] memory);
    function isOperatorWhitelisted(address operator) external view returns (bool);
    function isContractReceiverPermitted(address receiver) external view returns (bool);
    function isTransferAllowed(address caller, address from, address to) external view returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./IEOARegistry.sol";
import "./ITransferSecurityRegistry.sol";
import "./ITransferValidator.sol";

interface ICreatorTokenTransferValidator is ITransferSecurityRegistry, ITransferValidator, IEOARegistry {}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "lib/openzeppelin-contracts/contracts/utils/introspection/IERC165.sol";

interface IEOARegistry is IERC165 {
    function isVerifiedEOA(address account) external view returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./TransferPolicy.sol";

interface ITransferSecurityRegistry {
    event AddedToAllowlist(AllowlistTypes indexed kind, uint256 indexed id, address indexed account);
    event CreatedAllowlist(AllowlistTypes indexed kind, uint256 indexed id, string indexed name);
    event ReassignedAllowlistOwnership(AllowlistTypes indexed kind, uint256 indexed id, address indexed newOwner);
    event RemovedFromAllowlist(AllowlistTypes indexed kind, uint256 indexed id, address indexed account);
    event SetAllowlist(AllowlistTypes indexed kind, address indexed collection, uint120 indexed id);
    event SetTransferSecurityLevel(address indexed collection, TransferSecurityLevels level);

    function createOperatorWhitelist(string calldata name) external returns (uint120);
    function createPermittedContractReceiverAllowlist(string calldata name) external returns (uint120);
    function reassignOwnershipOfOperatorWhitelist(uint120 id, address newOwner) external;
    function reassignOwnershipOfPermittedContractReceiverAllowlist(uint120 id, address newOwner) external;
    function renounceOwnershipOfOperatorWhitelist(uint120 id) external;
    function renounceOwnershipOfPermittedContractReceiverAllowlist(uint120 id) external;
    function setTransferSecurityLevelOfCollection(address collection, TransferSecurityLevels level) external;
    function setOperatorWhitelistOfCollection(address collection, uint120 id) external;
    function setPermittedContractReceiverAllowlistOfCollection(address collection, uint120 id) external;
    function addOperatorToWhitelist(uint120 id, address operator) external;
    function addPermittedContractReceiverToAllowlist(uint120 id, address receiver) external;
    function removeOperatorFromWhitelist(uint120 id, address operator) external;
    function removePermittedContractReceiverFromAllowlist(uint120 id, address receiver) external;
    function getCollectionSecurityPolicy(address collection) external view returns (CollectionSecurityPolicy memory);
    function getWhitelistedOperators(uint120 id) external view returns (address[] memory);
    function getPermittedContractReceivers(uint120 id) external view returns (address[] memory);
    function isOperatorWhitelisted(uint120 id, address operator) external view returns (bool);
    function isContractReceiverPermitted(uint120 id, address receiver) external view returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./TransferPolicy.sol";

interface ITransferValidator {
    function applyCollectionTransferPolicy(address caller, address from, address to) external view;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

abstract contract OwnablePermissions {
    function _requireCallerIsContractOwner() internal view virtual;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

enum AllowlistTypes {
    Operators,
    PermittedContractReceivers
}

enum ReceiverConstraints {
    None,
    NoCode,
    EOA
}

enum CallerConstraints {
    None,
    OperatorWhitelistEnableOTC,
    OperatorWhitelistDisableOTC
}

enum StakerConstraints {
    None,
    CallerIsTxOrigin,
    EOA
}

enum TransferSecurityLevels {
    Zero,
    One,
    Two,
    Three,
    Four,
    Five,
    Six
}

struct TransferSecurityPolicy {
    CallerConstraints callerConstraints;
    ReceiverConstraints receiverConstraints;
}

struct CollectionSecurityPolicy {
    TransferSecurityLevels transferSecurityLevel;
    uint120 operatorWhitelistId;
    uint120 permittedContractReceiversId;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "lib/openzeppelin-contracts/contracts/utils/Context.sol";

/**
 * @title TransferValidation
 * @author Limit Break, Inc.
 * @notice A mix-in that can be combined with ERC-721 contracts to provide more granular hooks.
 * Openzeppelin's ERC721 contract only provides hooks for before and after transfer.  This allows
 * developers to validate or customize transfers within the context of a mint, a burn, or a transfer.
 */
abstract contract TransferValidation is Context {
    error ShouldNotMintToBurnAddress();

    /// @dev Inheriting contracts should call this function in the _beforeTokenTransfer function to get more granular hooks.
    function _validateBeforeTransfer(address from, address to, uint256 tokenId) internal virtual {
        bool fromZeroAddress = from == address(0);
        bool toZeroAddress = to == address(0);

        if (fromZeroAddress && toZeroAddress) {
            revert ShouldNotMintToBurnAddress();
        } else if (fromZeroAddress) {
            _preValidateMint(_msgSender(), to, tokenId, msg.value);
        } else if (toZeroAddress) {
            _preValidateBurn(_msgSender(), from, tokenId, msg.value);
        } else {
            _preValidateTransfer(_msgSender(), from, to, tokenId, msg.value);
        }
    }

    /// @dev Inheriting contracts should call this function in the _afterTokenTransfer function to get more granular hooks.
    function _validateAfterTransfer(address from, address to, uint256 tokenId) internal virtual {
        bool fromZeroAddress = from == address(0);
        bool toZeroAddress = to == address(0);

        if (fromZeroAddress && toZeroAddress) {
            revert ShouldNotMintToBurnAddress();
        } else if (fromZeroAddress) {
            _postValidateMint(_msgSender(), to, tokenId, msg.value);
        } else if (toZeroAddress) {
            _postValidateBurn(_msgSender(), from, tokenId, msg.value);
        } else {
            _postValidateTransfer(_msgSender(), from, to, tokenId, msg.value);
        }
    }

    /// @dev Optional validation hook that fires before a mint
    function _preValidateMint(address caller, address to, uint256 tokenId, uint256 value) internal virtual {}

    /// @dev Optional validation hook that fires after a mint
    function _postValidateMint(address caller, address to, uint256 tokenId, uint256 value) internal virtual {}

    /// @dev Optional validation hook that fires before a burn
    function _preValidateBurn(address caller, address from, uint256 tokenId, uint256 value) internal virtual {}

    /// @dev Optional validation hook that fires after a burn
    function _postValidateBurn(address caller, address from, uint256 tokenId, uint256 value) internal virtual {}

    /// @dev Optional validation hook that fires before a transfer
    function _preValidateTransfer(address caller, address from, address to, uint256 tokenId, uint256 value)
        internal
        virtual
    {}

    /// @dev Optional validation hook that fires after a transfer
    function _postValidateTransfer(address caller, address from, address to, uint256 tokenId, uint256 value)
        internal
        virtual
    {}
}
// SPDX-License-Identifier: MIT
// MODIFIED by no_side666, the change being using transient storage for gas saving$$$.
// adapted from: OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.25;

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

    uint256 private constant _NOT_ENTERED = 0; // using tstore so 0 is no problem and ideal
    uint256 private constant _ENTERED = 1;

    uint256 private immutable _tstoreKey = uint256(keccak256(abi.encode("ReentrancyGuard", address(this))));

    constructor() {}

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
        // On the first call to nonReentrant, status will be _NOT_ENTERED
        uint256 status;
        uint256 tstoreKey = _tstoreKey;
        assembly {
            status := tload(tstoreKey)
        }
        require(status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        assembly {
            tstore(tstoreKey, _ENTERED)
        }
    }

    function _nonReentrantAfter() private {
        uint256 tstoreKey = _tstoreKey;
        assembly {
            tstore(tstoreKey, _NOT_ENTERED)
        }
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        uint256 status;
        uint256 tstoreKey = _tstoreKey;
        assembly {
            status := tload(tstoreKey)
        }
        return status == _ENTERED;
    }
}