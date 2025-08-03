// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/IERC1155.sol)

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
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

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
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

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
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {ERC165, IERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

import {ITPLRevealedParts} from "../TPLRevealedParts/ITPLRevealedParts.sol";

/// @title TPLMechCrafter
/// @author CyberBrokers
/// @author dev by @dievardump
/// @notice Contract containing the Mech Crafting logic: use 6 parts + one afterglow to get a mech!
contract TPLMechCrafter is Ownable {
    error UserNotPartsOwner();
    error InvalidBodyPart();
    error InvalidPartsAmount();
    error InvalidModelAmount();
    error DelegationInactive();
    error NotAuthorized();
    error InvalidFees();

    error ErrorWithdrawing();
    error NothingToWithdraw();

    error ErrorDisassemblyFeePayment();

    error CraftingDisabled();
    error InvalidLength();

    /// @notice Emitted when a mech is assembled
    /// @param id the mech id
    /// @param partsIds the parts (body parts, afterglow) bitpacked
    /// @param extraData extra data used when crafting
    event MechAssembly(uint256 indexed id, uint256 partsIds, uint256 extraData);

    address public immutable TPL_REVEALED;
    address public immutable TPL_AFTERGLOW;
    address public immutable TPL_MECH;
    address public immutable TPL_PARTS_ESCROW;
    address public immutable DELEGATE_REGISTRY;

    uint256 public disassemblyFee;

    address public disassemblyFeeRecipient;

    bool public delegationActive;

    bool public craftingPublic;

    mapping(address => bool) public allowedCrafters;

    /// @notice Mech IDs linked to Engine ID; Once an engine is used, it will always mint the same Mech ID
    mapping(uint256 => uint256) public engineIds;

    modifier craftingAllowed() {
        if (!craftingPublic) {
            if (!allowedCrafters[msg.sender]) {
                revert CraftingDisabled();
            }
        }
        _;
    }

    constructor(
        address tplRevealed,
        address tplAfterglow,
        address tplMech,
        address tplPartsEscrow,
        address delegateRegistry,
        address disassemblyFeeRecipient_,
        uint256 disassemblyFee_
    ) {
        TPL_REVEALED = tplRevealed;
        TPL_AFTERGLOW = tplAfterglow;
        TPL_MECH = tplMech;
        TPL_PARTS_ESCROW = tplPartsEscrow;

        DELEGATE_REGISTRY = delegateRegistry;

        disassemblyFeeRecipient = disassemblyFeeRecipient_;
        disassemblyFee = disassemblyFee_;
    }

    /// @notice function allowing to parse the ExtraData sent with the mech build
    /// @param extraData the extra data
    /// @return seed the seed used for the name
    /// @return colors the colors used for the parts
    /// @return colorsActive the colors used for the parts
    /// @return emissive whether emissive is topToBottom or bottomToTop
    function parseExtraData(
        uint256 extraData
    ) external pure returns (uint256 seed, uint256[] memory colors, bool[] memory colorsActive, bool emissive) {
        seed = extraData & 0xffffff;
        extraData = extraData >> 24;

        colors = new uint256[](5);
        for (uint256 i; i < 5; i++) {
            colors[i] = extraData & 0xffffff;
            extraData = extraData >> 24;
        }

        colorsActive = new bool[](5);
        for (uint256 i; i < 5; i++) {
            colorsActive[i] = 1 == (extraData & 1);
            extraData = extraData >> 4;
        }

        emissive = (extraData & 1) == 1;
    }

    /////////////////////////////////////////////////////////
    // Actions                                             //
    /////////////////////////////////////////////////////////

    /// @notice Warning: This function should not be used directly from the contract. MechCrafting requires off-chain interactions
    ///         before the crafting.
    ///
    ///         Allows a TPL Revealed Mech Parts owner to craft a new Mech by using their parts
    /// @dev partsIds must be in the order of crafting (ARM_LEFT, ARM_RIGHT, ...) in order to make it less expensive
    /// @param partsIds the token ids to use to craft the mech
    /// @param afterglowId the afterglow id used on the mech
    /// @param extraData the data about seed for name, colors, emissive, ...
    function craft(uint256[] calldata partsIds, uint256 afterglowId, uint256 extraData) external craftingAllowed {
        _craft(partsIds, afterglowId, msg.sender, extraData);
    }

    /// @notice Warning: This function should not be used directly from the contract. MechCrafting requires off-chain interactions
    ///         before the crafting.
    ///
    ///         Allows a TPL Revealed Mech Parts owner to craft a new Mech by using their parts, with support of DelegateCash
    ///
    ///         requirements:
    ///             - All parts MUST be owned by the vault
    ///             - The afterglow MUST be owned by the vault
    ///             - The caller must be delegate for `vault` globally or on the current contract
    ///
    ///         Note that the Mech will be minted to the Vault directly
    ///
    /// @dev partsIds must be in the order of crafting (ARM_LEFT, ARM_RIGHT, ...) in order to make it less expensive
    /// @param partsIds the token ids to use to craft the mech
    /// @param afterglowId the afterglow id used on the mech
    /// @param extraData the data about seed for name, colors, emissive, ...
    /// @param vault the vault the current wallet tries to mint for
    function craftFor(
        uint256[] calldata partsIds,
        uint256 afterglowId,
        uint256 extraData,
        address vault
    ) external craftingAllowed {
        if (!delegationActive) {
            revert DelegationInactive();
        }

        _requireDelegate(vault);

        _craft(partsIds, afterglowId, vault, extraData);
    }

    /// @notice Allows a mech owner to dissasemble `mechId` and get back the parts & afterglow
    /// @param mechId the mech id
    function disassemble(uint256 mechId) external payable {
        _disassemble(mechId, msg.sender);
    }

    /// @notice Allows a mech owner to dissasemble `mechId` and get back the parts & afterglow, with support of DelegateCash
    /// @param mechId the mech id
    function disassembleFor(uint256 mechId, address vault) external payable {
        if (!delegationActive) {
            revert DelegationInactive();
        }

        _requireDelegate(vault);

        _disassemble(mechId, vault);
    }

    /////////////////////////////////////////////////////////
    // Owner                                               //
    /////////////////////////////////////////////////////////

    /// @notice Allows owner to set the disassembly fee & fee recipient
    /// @param newDisassemblyFeeRecipient the new fee recipient
    /// @param newFee the new fee
    function setDisassemblyFee(address newDisassemblyFeeRecipient, uint256 newFee) external onlyOwner {
        disassemblyFeeRecipient = newDisassemblyFeeRecipient;
        disassemblyFee = newFee;
    }

    /// @notice allows owner to activate or not interaction through delegate cash delegates
    /// @param isActive if we activate or not
    function setDelegationActive(bool isActive) external onlyOwner {
        delegationActive = isActive;
    }

    /// @notice allows owner to add or remove addresses allowed to craft even when public crafting is not open
    /// @param crafters the list of addresses to allow/disallow
    /// @param allowed if we are giving or removing the right to craft
    function setAllowedCrafters(address[] calldata crafters, bool allowed) external onlyOwner {
        uint256 length = crafters.length;
        if (length == 0) {
            revert InvalidLength();
        }

        for (uint i; i < length; i++) {
            allowedCrafters[crafters[i]] = allowed;
        }
    }

    /// @notice allows owner to change the "public crafting" status
    /// @param isPublic if the crafting is public or not
    function setCraftingPublic(bool isPublic) external onlyOwner {
        craftingPublic = isPublic;
    }

    /// @notice allows owner to withdraw the possible funds to `to`
    function withdraw(address to) external onlyOwner {
        uint256 balance = address(this).balance;

        if (balance == 0) {
            revert NothingToWithdraw();
        }

        (bool success, ) = to.call{value: balance}("");
        if (!success) {
            revert ErrorWithdrawing();
        }
    }

    /////////////////////////////////////////////////////////
    // Internals                                           //
    /////////////////////////////////////////////////////////

    /// @dev crafts
    function _craft(uint256[] calldata partsIds, uint256 afterglowId, address account, uint256 extraData) internal {
        uint256 length = partsIds.length;
        if (length != 6) {
            revert InvalidPartsAmount();
        }

        // get all ids "TokenData"
        ITPLRevealedParts.TokenData[] memory tokenPartsData = ITPLRevealedParts(TPL_REVEALED).partDataBatch(partsIds);

        uint256 packedIds;
        unchecked {
            uint256 engineModel = tokenPartsData[5].model;
            uint256 sameModelAsEngine;

            // verifies we have all the needed body parts
            // here we simply check that the bodyParts sent have the right types:
            // [ARM, ARM, HEAD, BODY, LEGS, ENGINE] which is [0, 0, 1, 2, 3, 4]
            // this is why they have to be sent in order
            if (
                tokenPartsData[0].bodyPart != 0 ||
                tokenPartsData[1].bodyPart != 0 ||
                tokenPartsData[2].bodyPart != 1 ||
                tokenPartsData[3].bodyPart != 2 ||
                tokenPartsData[4].bodyPart != 3 ||
                tokenPartsData[5].bodyPart != 4
            ) {
                revert InvalidBodyPart();
            }

            do {
                length--;
                if (tokenPartsData[length].model == engineModel) {
                    sameModelAsEngine++;
                }

                // builds the "packedIds" for the Mech to be able to store all the ids used to craft it
                packedIds = packedIds | (partsIds[length] << (length * 32));
            } while (length > 0);

            // engine + at least 2 parts
            if (sameModelAsEngine < 3) {
                revert InvalidModelAmount();
            }
        }

        // we add the afterglow id at the end
        packedIds = packedIds | (afterglowId << (6 * 32));

        // transfer all partsIds to TPL_PARTS_ESCROW
        ITPLRevealedParts(TPL_REVEALED).batchTransferFrom(account, TPL_PARTS_ESCROW, partsIds);

        // transfer the afterGlow to TPL_PARTS_ESCROW
        IERC1155(TPL_AFTERGLOW).safeTransferFrom(account, TPL_PARTS_ESCROW, afterglowId, 1, "");

        // then we mint the next Mech with the needed data
        uint256 engineKnownId = engineIds[partsIds[5]];
        if (engineKnownId != 0) {
            ITPLMech(TPL_MECH).mintToken(engineKnownId, account, packedIds);
        } else {
            engineKnownId = ITPLMech(TPL_MECH).mintNext(account, packedIds);
            engineIds[partsIds[5]] = engineKnownId;
        }

        emit MechAssembly(engineKnownId, packedIds, extraData);
    }

    function _disassemble(uint256 mechId, address account) internal {
        if (msg.value != disassemblyFee) {
            revert InvalidFees();
        }

        // make sure account is the owner of the mech.
        if (account != ITPLMech(TPL_MECH).ownerOf(mechId)) {
            revert NotAuthorized();
        }

        // get all ids used in the Mech assembly
        (uint256[] memory partsIds, uint256 afterglowId) = ITPLMech(TPL_MECH).getMechPartsIds(mechId);

        // burn the mech
        ITPLMech(TPL_MECH).burn(mechId);

        // batch transfer all IDs from ESCROW to account
        ITPLRevealedParts(TPL_REVEALED).batchTransferFrom(TPL_PARTS_ESCROW, account, partsIds);

        // transfer afterglow from ESCROW to account
        IERC1155(TPL_AFTERGLOW).safeTransferFrom(TPL_PARTS_ESCROW, account, afterglowId, 1, "");

        // if there is a fee
        if (msg.value > 0) {
            address disassemblyFeeRecipient_ = disassemblyFeeRecipient;
            // and a fee recipient
            if (disassemblyFeeRecipient_ != address(0)) {
                // send directly
                (bool success, ) = disassemblyFeeRecipient_.call{value: msg.value}("");
                if (!success) {
                    revert ErrorDisassemblyFeePayment();
                }
            }
        }
    }

    function _requireDelegate(address vault) internal view {
        // checks that msg.sender is delegate for vault, either globally or for the current contract or for the RevealedParts contract
        if (!IDelegateRegistry(DELEGATE_REGISTRY).checkDelegateForContract(msg.sender, vault, address(this))) {
            if (!IDelegateRegistry(DELEGATE_REGISTRY).checkDelegateForContract(msg.sender, vault, TPL_REVEALED)) {
                revert NotAuthorized();
            }
        }
    }
}

interface ITPLMech {
    function mintNext(address to, uint256 packedIds) external returns (uint256);

    function mintToken(uint256 tokenId, address to, uint256 packedIds) external;

    function ownerOf(uint256 mechId) external view returns (address);

    function burn(uint256 tokenId) external;

    function getMechPartsIds(uint256 tokenId) external view returns (uint256[] memory, uint256);
}

interface IDelegateRegistry {
    /**
     * @notice Returns true if the address is delegated to act on your behalf for a token contract or an entire vault
     * @param delegate The hotwallet to act on your behalf
     * @param contract_ The address for the contract you're delegating
     * @param vault The cold wallet who issued the delegation
     */
    function checkDelegateForContract(address delegate, address vault, address contract_) external view returns (bool);
}
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import {IBase721A} from "../../utils/tokens/ERC721/IBase721A.sol";

/// @title ITPLRevealedParts
/// @author CyberBrokers
/// @author dev by @dievardump
/// @notice Interface for the Revealed Parts contract.
interface ITPLRevealedParts is IBase721A {
    struct TokenData {
        uint256 generation;
        uint256 originalId;
        uint256 bodyPart;
        uint256 model;
        uint256[] stats;
    }

    /// @notice verifies that `account` owns all `tokenIds`
    /// @param account the account
    /// @param tokenIds the token ids to check
    /// @return if account owns all tokens
    function isOwnerOfBatch(address account, uint256[] calldata tokenIds) external view returns (bool);

    /// @notice returns a Mech Part data (body part and original id)
    /// @param tokenId the tokenId to check
    /// @return the Mech Part data (body part and original id)
    function partData(uint256 tokenId) external view returns (TokenData memory);

    /// @notice returns a list of Mech Part data (body part and original id)
    /// @param tokenIds the tokenIds to knoMechParts type of
    /// @return a list of Mech Part data (body part and original id)
    function partDataBatch(uint256[] calldata tokenIds) external view returns (TokenData[] memory);

    /// @notice Allows to burn tokens in batch
    /// @param tokenIds the tokens to burn
    function burnBatch(uint256[] calldata tokenIds) external;

    /// @notice Transfers the ownership of multiple NFTs from one address to another address
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenIds The NFTs to transfer
    function batchTransferFrom(
        address _from,
        address _to,
        uint256[] calldata _tokenIds
    ) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface IBase721A {
    /// @notice Allows a `minter` to mint `amount` tokens to `to` with `extraData_`
    /// @param to to whom we need to mint
    /// @param amount how many to mint
    /// @param extraData extraData for these items
    function mintTo(
        address to,
        uint256 amount,
        uint24 extraData
    ) external;
}