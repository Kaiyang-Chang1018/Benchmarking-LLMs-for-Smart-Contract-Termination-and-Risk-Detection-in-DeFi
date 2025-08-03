// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC721.sol)

pragma solidity ^0.8.0;

import "../token/ERC721/IERC721.sol";
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/utils/ERC1155Holder.sol)

pragma solidity ^0.8.0;

import "./ERC1155Receiver.sol";

/**
 * Simple implementation of `ERC1155Receiver` that will allow a contract to hold ERC1155 tokens.
 *
 * IMPORTANT: When inheriting this contract, you must include a way to use the received tokens, otherwise they will be
 * stuck.
 *
 * @dev _Available since v3.1._
 */
contract ERC1155Holder is ERC1155Receiver {
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/utils/ERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../IERC1155Receiver.sol";
import "../../../utils/introspection/ERC165.sol";

/**
 * @dev _Available since v3.1._
 */
abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
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
/*
    Version 1 of the HyperCycle Migration Helper contract.
*/

pragma solidity 0.8.19;

import '@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol';
import '@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol';
import '@openzeppelin/contracts/token/ERC721/IERC721.sol';

import '../interfaces/IHyperCycleShareManager.sol';
import '../interfaces/IHyperCycleShareTokens.sol';

/*
@title HyperCycle migration helper
@author Jhonatan Hernández
@notice This contract is a bridge that facilitates share migration from the HyperCycleShareManager contract to the HyperCycleShareManagerV2 contract.
        It is also a specific way to reduce the impact of two bugs present in the HyperCycleShareManager contract
      
        The first one is caused by the claimHypcPortion function not adding the six needed decimals to the amount
        of hypc sent to the user, causing them to get their funds trapped in the contract while the second one 
        consists on the contract blindly sending all the wTokens it holds to the address targeted by the manager
        change votation instead of letting users claim their tokens back.

        Both errors are fixed in the HyperCycleShareTokensV2 contract, while this contract has two functions:
        1 - Acts as a neutral bridge that moves the share ownership from the first manager contract to the second one
        2 - Sends the funds mistakenly sent to this contract to the address that calls the migrate function
            after validating that said address holds most of the rTokens
*/

/* Errors */
// Modifier Errors
//@dev Error for when a zero address is used to initialize the contract
error ZeroAddressInConstructor();
//@dev Error for when the provided hypershare ID was not connected to the correct share ID
error WrongHypershareId();
//@dev Error for when the provided hypershare ID was not connected to the correct share ID
error InsufficientBalance(uint256 requiredBalance, uint256 currentBalance);
//@dev Error for when a received NFT does not have a predetermined owner
error NoOwnerRegistered();
//@dev Error for when a received NFT does not come from an accepted source
error NoContractAllowed();

contract MigrationHelper is ERC1155Holder, IERC721Receiver {
    IHyperCycleShareManager immutable hyperCycleShareManager;
    IHyperCycleShareManager immutable oldHyperCycleShareManager;
    IHyperCycleShareTokens immutable hyperShareTokens;
    address immutable licenseContract;

    mapping(uint256 => address) private licenseOwner;

    event Migration(uint256 oldShareId, uint256 newShareId, uint256 shareNumber);

    /**
     * @notice Initializes the MigrationHelper contract with the addresses of the new and old HyperCycleShareManager contracts and the HyperCycleShareTokens contract.
     * @dev Ensures that none of the provided addresses are zero addresses.
     * @param _hyperCycleShareManager The address of the new HyperCycleShareManager contract.
     * @param _oldHyperCycleShareManager The address of the old HyperCycleShareManager contract.
     * @param _hyperShareTokens The address of the HyperCycleShareTokens contract.
     * @custom:error ZeroAdressInConstructor Thrown if any of the provided addresses are zero addresses.
     */
    constructor(
        address _hyperCycleShareManager,
        address _oldHyperCycleShareManager,
        address _hyperShareTokens,
        address _licenseContract
    ) {
        if (
            _hyperCycleShareManager == address(0x0) ||
            _oldHyperCycleShareManager == address(0x0) ||
            _hyperShareTokens == address(0x0) ||
            _licenseContract == address(0x0)
        ) {
            revert ZeroAddressInConstructor();
        }

        hyperCycleShareManager = IHyperCycleShareManager(_hyperCycleShareManager);
        oldHyperCycleShareManager = IHyperCycleShareManager(_oldHyperCycleShareManager);
        hyperShareTokens = IHyperCycleShareTokens(_hyperShareTokens);
        licenseContract = _licenseContract;
    }

    /**
     * @notice Migrates shares from the old HyperCycleShareManager contract to the new one.
     * @dev This function validates the share ID, ensures the caller holds at least 69% of the revenue tokens,
     *      transfers mistakenly held tokens to the caller, and completes the migration process.
     * @param shareId The ID of the share to be migrated.
     * @param oldHyperShareId The ID of the hypershare in the old HyperCycleShareManager contract.
     * @custom:requirement The caller must hold at least 69% of the total supply of revenue tokens.
     * @custom:requirement The provided share ID must match the share ID in the old contract.
     * @custom:emits Emits a Migration event upon successful migration.
     */
    function migrate(uint256 shareId, uint256 oldHyperShareId) external {
        // validate that the share was in the old contract to prevent anyone from calling this contract with a wrong oldHyperShareId
        // which would risk using the wrong operator address or operator string
        Types.ShareProposalData memory oldProposalData = oldHyperCycleShareManager.getShareProposalData(
            oldHyperShareId
        );
        uint256 shareIdInContract = oldProposalData.shareTokenData.shareTokenNumber;
        if (shareIdInContract != shareId) {
            revert WrongHypershareId();
        }

        // save license original owner in order to forward accordingly on share cancel
        // this is due to the fact that this contract is named token owner for the license after the share is migrated
        licenseOwner[oldProposalData.licenseData.tokenNumber] = oldProposalData.licenseData.tokenOwner;

        // get hypershareId from new contract
        IHyperCycleShareManager manager = hyperCycleShareManager;
        IHyperCycleShareTokens tokens = hyperShareTokens;
        uint256 hypershareId = manager.sharesProposalsCounter();
        // get current string and hardware operator
        string memory operatorString = tokens.getShareMessage(shareId);
        address operatorAddress = oldHyperCycleShareManager.getShareProposalHardwareOperator(oldHyperShareId);

        // A bug in the first version of the Manager contract (./HyperCycleShareManager.sol)
        // causes all wTokens in the Manager contract (held for voting purposes) to be mistakenly
        // sent to the address targeted by the manager change votation. In this case, this contract.
        // The following code attempts to fix said error by sending those tokens to the caller of this function.
        // To validate that the funds go to the correct person, we require the function caller
        // to hold at least 69% of the total supply of revenue tokens.
        uint256 rTokensId = shareId * 2;
        uint256 wTokensId = shareId * 2 + 1;

        // get full amount
        uint256 totalsupply = tokens.getRevenueTokenTotalSupply(shareId);
        // validate that user holds at least 69% of all rTokens
        uint256 userBalance = tokens.balanceOf(msg.sender, rTokensId);
        if (userBalance < (totalsupply * 69) / 100) {
            revert InsufficientBalance((totalsupply * 69) / 100, userBalance);
        }

        // transfer previously lost contract balance to the user
        uint256 contractBalance = tokens.balanceOf(address(this), wTokensId);
        tokens.safeTransferFrom(address(this), msg.sender, wTokensId, contractBalance, '');

        // start migration process
        tokens.setApprovalForAll(address(manager), true);
        manager.startShareProposalMigration(shareId, operatorAddress, operatorString);
        // transfer share ownership
        tokens.transferShareOwnership(shareId, address(manager));
        // end migration process
        manager.finishShareTokenMigration(hypershareId);

        emit Migration(oldHyperShareId, hypershareId, shareIdInContract);
    }

    function onERC721Received(address, address, uint256 tokenId, bytes calldata) external override returns (bytes4) {
        if (msg.sender == licenseContract) {
            // Forward the received license to their respective owner
            IERC721(msg.sender).safeTransferFrom(address(this), licenseOwner[tokenId], tokenId);
        } else {
            revert NoContractAllowed();
        }

        // Return the function selector for ERC721Receiver
        return this.onERC721Received.selector;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @notice Interface for the HyperCycleToken.sol contract.
interface IHYPC is IERC20 {
    /*
     * Accesses the ERC20 functions of the HYPC contract. The burn function
     * is also exposed for future contracts.
    */
    /// @notice Burns an amount of the HyPC ERC20.
    function burn(uint256 amount) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/interfaces/IERC721.sol";

/// @notice Interface for the HYPCSwap.sol contract.
interface IHYPCSwapV2 is IERC721 {
    /**
     * Accesses the addNFT function so that the CHYPC contract can
     * add the newly created NFT into this contract.
     */

    function addRootTokens(uint256 tokens) external;

    function splitHeldToken(uint256 level, uint256 skipLevels) external;

    function swapV2(uint256 level) external;

    function redeem(uint256 tokenNumber) external;

    function assignNumber(uint256 tokenNumber, uint256 targetNumber) external;

    function assignString(uint256 tokenNumber, string memory data) external;

    function burn(uint256 tokenNumber, string memory data) external;

    function assign(uint256 tokenNumber, string memory data) external;

    function swap() external;


    function getAssignment(uint256 tokenNumber) external view returns (string memory);
    function getAssignmentNumber(uint256 tokenNumber) external view returns (uint256);
    function getAssignmentString(uint256 tokenNumber) external view returns (string memory);



    function getBurnData(uint256 tokenNumber) external view returns (string memory);

    function getAvailableToken(uint256 level, uint256 index) external view returns (uint256);

    function getTokenLevel(uint256 tokenNumber) external view returns (uint256);

    function getAssignmentTargetNumber(uint256 targetNumber) external view returns (uint256);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/// @notice Interface for the CHYPC.sol contract.
interface IHyperCycleLicense is IERC721 {
    /**
     * Accesses the assignment function of c_HyPC so the swap can remove 
     * the assignment data when a token is redeemed or swapped.
     */
    /// @notice Creates a new root token inside this contract, with a specified licenseID.
    function mint(
        uint256 numTokens
    ) external;

    /// @notice Splits a given token into two new tokens, with corresponding licenseID's.
    function split(
        uint256 tokenId
    ) external;

    /// @notice Burns a given tokenId with a specified burn string.
    function burn(
        uint256 tokenId,
        string memory burnString          
    ) external;

    /// @notice Merges together two child licenses into a parent license.
    function merge(
        uint256 tokenId
    ) external;

    /// @notice Returns the burn data from the given tokenId.
    function getBurnData(
        uint256 tokenId
    ) external view returns (string memory);

    /// @notice Returns the license height of the given tokenId.
    function getLicenseHeight(
        uint256 licenseId
    ) external view returns (uint8);

    /// @notice Returns the license height of the given tokenId.
    function getLicenseStatus(
        uint256 licenseId
    ) external view returns (uint256);
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {ShareManagerTypes as Types} from '../libs/ShareManagerTypes.sol';

interface IHyperCycleShareManager {
    //@dev managerV1
    function sharesProposalsAmount() external returns (uint256);
    //@dev managerV2
    function sharesProposalsCounter() external returns (uint256);

    function startShareProposalMigration(
        uint256 shareTokenNumber,
        address hardwareOperator,
        string memory operatorAssignedString
    ) external;

    function finishShareTokenMigration(uint256 shareProposalId) external;

    function getShareProposalHardwareOperator(uint256 shareProposalId) external view returns (address);

    function getShareProposalData(uint256 shareProposalId) external view returns (Types.ShareProposalData memory);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

/// @notice Interface for the HyperCycleShareTokens.sol contract.
interface IHyperCycleShareTokens is IERC1155 {

    struct PendingDeposit {
        uint256 availableAtTimestamp;
        uint256 amount;
    }

    function currentShareNumber() external returns (uint256);

    function increaseShareLimit(uint256 number) external;

    function createShareTokens(uint256 licenseNumber, uint256 chypcNumber, bool chypcTokenHeld, string memory startingMessage, uint256 maxRevenueDeposit) external;

    function transferShareOwnership(uint256 shareNumber, address to) external;


    function cancelShareTokens(uint256 shareNumber) external;

    function depositRevenue(uint256 shareNumber, uint256 amt) external;

    function claimRevenue(uint256 shareNumber) external;

    function withdrawEarnings(uint256 shareNumber) external;

    function claimAndWithdraw(uint256 shareNumber) external;

    function setShareMessage(uint256 shareNumber, string memory message) external;

    function burnRevenueTokens(uint256 shareNumber, uint256 amount) external;
    
    function burnWealthTokens(uint256 shareNumber, uint256 amount) external;

    function getShareLicenseId(uint256 shareNumber) external view returns (uint256);
    function getShareCHyPCId(uint256 shareNumber) external view returns (uint256);
    function getShareOwner(uint256 shareNumber) external view returns (address);
    function getShareRevenueTokenId(uint256 shareNumber) external view returns (uint256);
    function getShareWealthTokenId(uint256 shareNumber) external view returns (uint256);
    function getShareTotalRevenue(uint256 shareNumber) external view returns (uint256);
    function getShareStartTime(uint256 shareNumber) external view returns (uint256);
    function getShareMessage(uint256 shareNumber) external view returns (string memory);
    function isShareActive(uint256 shareNumber) external view returns (bool);
    function shareCreated(uint256 shareNumber) external view returns (bool);
    function getRevenueTokenTotalSupply(uint256 shareNumber) external view returns (uint256);
    function getWealthTokenTotalSupply(uint256 shareNumber) external view returns (uint256);
    function getPendingDeposit(uint256 shareNumber, uint256 index) external view returns (PendingDeposit memory);
    function getPendingDepositsLength(uint256 shareNumber) external view returns (uint256);

}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import '@openzeppelin/contracts/token/ERC1155/IERC1155.sol';

/// @notice Interface for the HyperCycleShareTokens.sol contract.
interface IHyperCycleShareTokensV2 is IERC1155 {
    struct PendingDeposit {
        uint256 availableAtTimestamp;
        uint256 amount;
    }

    function shareData(
        uint256 shareNumber
    )
        external
        pure
        returns (
            uint256 licenseId,
            uint256 chypcId,
            uint256 status,
            address owner,
            uint256 rTokenNumber,
            uint256 wTokenNumber,
            uint256 rTokenSupply,
            uint256 wTokenSupply,
            uint256 startTimestamp,
            uint256 revenueDeposited,
            uint256 revenueDepositDelay,
            string memory message,
            bool chypcTokenHeld
        );

    function currentShareNumber() external returns (uint256);

    function increaseShareLimit(uint256 number) external;

    function createShareTokens(
        uint256 licenseNumber,
        uint256 chypcNumber,
        bool chypcTokenHeld,
        string memory startingMessage,
        uint256 maxRevenueDeposit
    ) external;

    function changePendingRevenueDelay(uint256 shareNumber, uint256 newDelay) external;

    function transferShareOwnership(uint256 shareNumber, address to) external;

    function cancelShareTokens(uint256 shareNumber) external;

    function depositRevenue(uint256 shareNumber, uint256 amt) external;

    function claimRevenue(uint256 shareNumber) external;

    function withdrawEarnings(uint256 shareNumber) external;

    function claimAndWithdraw(uint256 shareNumber) external;

    function setShareMessage(uint256 shareNumber, string memory message) external;

    function burnRevenueTokens(uint256 shareNumber, uint256 amount) external;

    function burnWealthTokens(uint256 shareNumber, uint256 amount) external;

    function getShareLicenseId(uint256 shareNumber) external view returns (uint256);

    function getShareCHyPCId(uint256 shareNumber) external view returns (uint256);

    function getShareOwner(uint256 shareNumber) external view returns (address);

    function getShareRevenueTokenId(uint256 shareNumber) external view returns (uint256);

    function getShareWealthTokenId(uint256 shareNumber) external view returns (uint256);

    function getShareTotalRevenue(uint256 shareNumber) external view returns (uint256);

    function getShareStartTime(uint256 shareNumber) external view returns (uint256);

    function getShareMessage(uint256 shareNumber) external view returns (string memory);

    function isShareActive(uint256 shareNumber) external view returns (bool);

    function shareCreated(uint256 shareNumber) external view returns (bool);

    function getRevenueTokenTotalSupply(uint256 shareNumber) external view returns (uint256);

    function getWealthTokenTotalSupply(uint256 shareNumber) external view returns (uint256);

    function getPendingDeposit(uint256 shareNumber, uint256 index) external view returns (PendingDeposit memory);

    function getPendingDepositsLength(uint256 shareNumber) external view returns (uint256);
    
    function lastShareClaimRevenue(uint256 shareTokenNumber, address user) external view returns (uint256);

    function withdrawableAmounts(uint256 shareTokenNUmber, address user) external view returns (uint256); 
}
// SPDX-License-Identifier: MIT
/*
    Share Manager Types
*/

pragma solidity ^0.8.19;

import {IHYPCSwapV2} from '../interfaces/IHYPCSwapV2.sol';
import {IHyperCycleLicense} from '../interfaces/IHyperCycleLicense.sol';
import {IHyperCycleShareTokensV2} from '../interfaces/IHyperCycleShareTokensV2.sol';
import {IHYPC} from '../interfaces/IHYPC.sol';

library ShareManagerTypes {
    enum ShareProposalStatus {
        NOT_CREATED,
        PENDING,
        STARTED,
        ENDED
    }

    enum VotationOptions {
        NULL_OPTION,
        CANCEL_SHARE,
        CHANGE_HARDWARE_OPERATOR_ADDRESS,
        CHANGE_HARDWARE_OPERATOR_REVENUE,
        CHANGE_MANAGER_CONTRACT,
        CHANGE_DEPOSIT_REVENUE_DELAY
    }

    enum ConsensusOptions {
        ONE_HUNDRED_PERCENT,
        NINETY_PERCENT
    }

    struct ManagerData {
        IHYPC hypcToken;
        IHYPCSwapV2 chypcV2;
        IHyperCycleLicense licenseContract;
        IHyperCycleShareTokensV2 hypcShareTokens;
    }

    struct ShareProposalData {
        ShareTokenData shareTokenData;
        TokenHolderData licenseData;
        TokenHolderData chypcData;
        HardwareOperatorData operatorData;
        ShareProposalStatus status;
        uint256 hypcSurplus;
    }

    struct ShareTokenData {
        uint256 validEndTimestamp;
        uint256 shareTokenNumber;
        uint256 rTokenId;
        uint256 wTokenId;
        uint256 revenueDepositDelay;
    }

    struct TokenHolderData {
        uint256 tokenNumber;
        uint256 tokenLevel;
        uint256 initialRevenueTokens;
        uint256 initialWealthTokens;
        address tokenOwner;
    }

    struct HardwareOperatorData {
        uint256 operatorRevenue;
        string operatorAssignedString;
        address operatorAddress;
    }

    struct Votation {
        uint256 votationId;
        uint256 votesFor;
        uint256 votesAgainst;
        uint256 deadline;
        bytes proposedData;
        VotationOptions option;
        bool amountReached;
    }

    struct ShareData {
        uint256 licenseId;
        uint256 chypcId;
        uint256 status;
        address owner;
        uint256 rTokenNumber;
        uint256 wTokenNumber;
        uint256 rTokenSupply;
        uint256 wTokenSupply;
        uint256 startTimestamp;
        uint256 revenueDeposited;
        uint256 revenueDepositDelay;
        string message;
        bool chypcTokenHeld;
    }
}