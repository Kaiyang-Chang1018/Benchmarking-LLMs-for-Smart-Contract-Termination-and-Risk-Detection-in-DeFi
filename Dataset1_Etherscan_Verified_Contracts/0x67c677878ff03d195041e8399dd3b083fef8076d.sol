// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @author: manifold.xyz

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/**
 * @dev Core creator interface
 */
interface ICreatorCore is IERC165 {

    event ExtensionRegistered(address indexed extension, address indexed sender);
    event ExtensionUnregistered(address indexed extension, address indexed sender);
    event ExtensionBlacklisted(address indexed extension, address indexed sender);
    event MintPermissionsUpdated(address indexed extension, address indexed permissions, address indexed sender);
    event RoyaltiesUpdated(uint256 indexed tokenId, address payable[] receivers, uint256[] basisPoints);
    event DefaultRoyaltiesUpdated(address payable[] receivers, uint256[] basisPoints);
    event ApproveTransferUpdated(address extension);
    event ExtensionRoyaltiesUpdated(address indexed extension, address payable[] receivers, uint256[] basisPoints);
    event ExtensionApproveTransferUpdated(address indexed extension, bool enabled);

    /**
     * @dev gets address of all extensions
     */
    function getExtensions() external view returns (address[] memory);

    /**
     * @dev add an extension.  Can only be called by contract owner or admin.
     * extension address must point to a contract implementing ICreatorExtension.
     * Returns True if newly added, False if already added.
     */
    function registerExtension(address extension, string calldata baseURI) external;

    /**
     * @dev add an extension.  Can only be called by contract owner or admin.
     * extension address must point to a contract implementing ICreatorExtension.
     * Returns True if newly added, False if already added.
     */
    function registerExtension(address extension, string calldata baseURI, bool baseURIIdentical) external;

    /**
     * @dev add an extension.  Can only be called by contract owner or admin.
     * Returns True if removed, False if already removed.
     */
    function unregisterExtension(address extension) external;

    /**
     * @dev blacklist an extension.  Can only be called by contract owner or admin.
     * This function will destroy all ability to reference the metadata of any tokens created
     * by the specified extension. It will also unregister the extension if needed.
     * Returns True if removed, False if already removed.
     */
    function blacklistExtension(address extension) external;

    /**
     * @dev set the baseTokenURI of an extension.  Can only be called by extension.
     */
    function setBaseTokenURIExtension(string calldata uri) external;

    /**
     * @dev set the baseTokenURI of an extension.  Can only be called by extension.
     * For tokens with no uri configured, tokenURI will return "uri+tokenId"
     */
    function setBaseTokenURIExtension(string calldata uri, bool identical) external;

    /**
     * @dev set the common prefix of an extension.  Can only be called by extension.
     * If configured, and a token has a uri set, tokenURI will return "prefixURI+tokenURI"
     * Useful if you want to use ipfs/arweave
     */
    function setTokenURIPrefixExtension(string calldata prefix) external;

    /**
     * @dev set the tokenURI of a token extension.  Can only be called by extension that minted token.
     */
    function setTokenURIExtension(uint256 tokenId, string calldata uri) external;

    /**
     * @dev set the tokenURI of a token extension for multiple tokens.  Can only be called by extension that minted token.
     */
    function setTokenURIExtension(uint256[] memory tokenId, string[] calldata uri) external;

    /**
     * @dev set the baseTokenURI for tokens with no extension.  Can only be called by owner/admin.
     * For tokens with no uri configured, tokenURI will return "uri+tokenId"
     */
    function setBaseTokenURI(string calldata uri) external;

    /**
     * @dev set the common prefix for tokens with no extension.  Can only be called by owner/admin.
     * If configured, and a token has a uri set, tokenURI will return "prefixURI+tokenURI"
     * Useful if you want to use ipfs/arweave
     */
    function setTokenURIPrefix(string calldata prefix) external;

    /**
     * @dev set the tokenURI of a token with no extension.  Can only be called by owner/admin.
     */
    function setTokenURI(uint256 tokenId, string calldata uri) external;

    /**
     * @dev set the tokenURI of multiple tokens with no extension.  Can only be called by owner/admin.
     */
    function setTokenURI(uint256[] memory tokenIds, string[] calldata uris) external;

    /**
     * @dev set a permissions contract for an extension.  Used to control minting.
     */
    function setMintPermissions(address extension, address permissions) external;

    /**
     * @dev Configure so transfers of tokens created by the caller (must be extension) gets approval
     * from the extension before transferring
     */
    function setApproveTransferExtension(bool enabled) external;

    /**
     * @dev get the extension of a given token
     */
    function tokenExtension(uint256 tokenId) external view returns (address);

    /**
     * @dev Set default royalties
     */
    function setRoyalties(address payable[] calldata receivers, uint256[] calldata basisPoints) external;

    /**
     * @dev Set royalties of a token
     */
    function setRoyalties(uint256 tokenId, address payable[] calldata receivers, uint256[] calldata basisPoints) external;

    /**
     * @dev Set royalties of an extension
     */
    function setRoyaltiesExtension(address extension, address payable[] calldata receivers, uint256[] calldata basisPoints) external;

    /**
     * @dev Get royalites of a token.  Returns list of receivers and basisPoints
     */
    function getRoyalties(uint256 tokenId) external view returns (address payable[] memory, uint256[] memory);
    
    // Royalty support for various other standards
    function getFeeRecipients(uint256 tokenId) external view returns (address payable[] memory);
    function getFeeBps(uint256 tokenId) external view returns (uint[] memory);
    function getFees(uint256 tokenId) external view returns (address payable[] memory, uint256[] memory);
    function royaltyInfo(uint256 tokenId, uint256 value) external view returns (address, uint256);

    /**
     * @dev Set the default approve transfer contract location.
     */
    function setApproveTransfer(address extension) external; 

    /**
     * @dev Get the default approve transfer contract location.
     */
    function getApproveTransfer() external view returns (address);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @author: manifold.xyz

import "./ICreatorCore.sol";

/**
 * @dev Core ERC721 creator interface
 */
interface IERC721CreatorCore is ICreatorCore {

    /**
     * @dev mint a token with no extension. Can only be called by an admin.
     * Returns tokenId minted
     */
    function mintBase(address to) external returns (uint256);

    /**
     * @dev mint a token with no extension. Can only be called by an admin.
     * Returns tokenId minted
     */
    function mintBase(address to, string calldata uri) external returns (uint256);

    /**
     * @dev batch mint a token with no extension. Can only be called by an admin.
     * Returns tokenId minted
     */
    function mintBaseBatch(address to, uint16 count) external returns (uint256[] memory);

    /**
     * @dev batch mint a token with no extension. Can only be called by an admin.
     * Returns tokenId minted
     */
    function mintBaseBatch(address to, string[] calldata uris) external returns (uint256[] memory);

    /**
     * @dev mint a token. Can only be called by a registered extension.
     * Returns tokenId minted
     */
    function mintExtension(address to) external returns (uint256);

    /**
     * @dev mint a token. Can only be called by a registered extension.
     * Returns tokenId minted
     */
    function mintExtension(address to, string calldata uri) external returns (uint256);

    /**
     * @dev batch mint a token. Can only be called by a registered extension.
     * Returns tokenIds minted
     */
    function mintExtensionBatch(address to, uint16 count) external returns (uint256[] memory);

    /**
     * @dev batch mint a token. Can only be called by a registered extension.
     * Returns tokenId minted
     */
    function mintExtensionBatch(address to, string[] calldata uris) external returns (uint256[] memory);

    /**
     * @dev burn a token. Can only be called by token owner or approved address.
     * On burn, calls back to the registered extension's onBurn method
     */
    function burn(uint256 tokenId) external;

}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @author: manifold.xyz

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

/**
 * @dev Base creator extension variables
 */
abstract contract CreatorExtension is ERC165 {

    /**
     * @dev Legacy extension interface identifiers
     *
     * {IERC165-supportsInterface} needs to return 'true' for this interface
     * in order backwards compatible with older creator contracts
     */
    bytes4 constant internal LEGACY_EXTENSION_INTERFACE = 0x7005caad;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165) returns (bool) {
        return interfaceId == LEGACY_EXTENSION_INTERFACE
            || super.supportsInterface(interfaceId);
    }
    
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @author: manifold.xyz

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/**
 * @dev Implement this if you want your extension to have overloadable URI's
 */
interface ICreatorExtensionTokenURI is IERC165 {

    /**
     * Get the uri for a given creator/tokenId
     */
    function tokenURI(address creator, uint256 tokenId) external view returns (string memory);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @author: manifold.xyz

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/**
 * @dev Interface for admin control
 */
interface IAdminControl is IERC165 {

    event AdminApproved(address indexed account, address indexed sender);
    event AdminRevoked(address indexed account, address indexed sender);

    /**
     * @dev gets address of all admins
     */
    function getAdmins() external view returns (address[] memory);

    /**
     * @dev add an admin.  Can only be called by contract owner.
     */
    function approveAdmin(address admin) external;

    /**
     * @dev remove an admin.  Can only be called by contract owner.
     */
    function revokeAdmin(address admin) external;

    /**
     * @dev checks whether or not given address is an admin
     * Returns True if they are
     */
    function isAdmin(address admin) external view returns (bool);

}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
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

pragma solidity ^0.8.0;

/// @author dievardump (https://twitter.com/dievardump)

import "@openzeppelin/contracts/utils/Strings.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "@manifoldxyz/libraries-solidity/contracts/access/IAdminControl.sol";
import "@manifoldxyz/creator-core-solidity/contracts/core/IERC721CreatorCore.sol";
import "@manifoldxyz/creator-core-solidity/contracts/extensions/CreatorExtension.sol";
import "@manifoldxyz/creator-core-solidity/contracts/extensions/ICreatorExtensionTokenURI.sol";

import {IMetadataHelper} from "./interfaces/IMetadataHelper.sol";

/// @title PADBurn
/// @author dievardump (https://twitter.com/dievardump)
contract PADBurn is CreatorExtension, ICreatorExtensionTokenURI, ReentrancyGuard {
	using Strings for uint256;

	error NotAuthorized();
	error InvalidParameter();
	error TooManyRequested();
	error NotOwnerOfBurnToken();
	error SeriesExists();
	error UnknownToken();
	error InvalidPADID();
	error AlreadyMintedOut();
	error BurnInactive();
	error BurnOngoing();

	struct Series {
		uint64 maxSupply;
		uint64 bucketSize;
		uint64 burnAmount;
		bool active;
	}

	struct TokenData {
		uint32 series;
		uint32 index;
	}

	struct BurnOrder {
		uint32 series;
		uint256[] ids;
	}

	uint256 public constant BLANK_PAD_MAX_ID = 1349;
	address public immutable PAD;

	string public baseURI;
	address public metadataHelper;

	mapping(uint256 => Series) public seriesList;
	mapping(uint256 => TokenData) public tokenData;
	mapping(uint256 => mapping(uint256 => uint256)) _buckets;

	/// @dev Only allows approved admins to call the specified function
	modifier creatorAdminRequired(address creator) {
		if (!IAdminControl(creator).isAdmin(msg.sender)) {
			revert NotAuthorized();
		}

		_;
	}

	constructor(address pad, string memory newBaseURI) {
		PAD = pad;

		seriesList[1] = Series(128, 128, 3, true);
		seriesList[2] = Series(100, 100, 2, true);
		seriesList[3] = Series(765, 765, 1, true);

		baseURI = newBaseURI;
	}

	// =============================================================
	//                           Views
	// =============================================================

	function supportsInterface(
		bytes4 interfaceId
	) public view virtual override(CreatorExtension, IERC165) returns (bool) {
		return
			interfaceId == type(ICreatorExtensionTokenURI).interfaceId ||
			CreatorExtension.supportsInterface(interfaceId);
	}

	/// @notice returns the tokenURI for a tokenId
	/// @param creator the collection address
	/// @param tokenId the token id
	function tokenURI(address creator, uint256 tokenId) external view override returns (string memory) {
		if (creator != PAD) {
			revert UnknownToken();
		}

		TokenData memory data = tokenData[tokenId];

		if (data.index == 0) {
			revert UnknownToken();
		}

		string memory uri;

		address metadataHelper_ = metadataHelper;
		if (metadataHelper_ != address(0)) {
			uri = IMetadataHelper(metadataHelper_).tokenURI(creator, tokenId, data.series, data.index);
		} else {
			uri = string.concat(
				baseURI,
				"/",
				uint256(data.series).toString(),
				"/",
				uint256(data.index).toString(),
				".json"
			);
		}

		return uri;
	}

	/// @notice Allows to get tokenData in batch
	/// @param ids the token ids
	/// @return an array of token data corresponding to each ids
	function tokenDataBatch(uint256[] calldata ids) external view returns (TokenData[] memory) {
		uint256 length = ids.length;
		TokenData[] memory data = new TokenData[](length);
		for (uint i; i < length; i++) {
			data[i] = tokenData[ids[i]];
		}

		return data;
	}

	// =============================================================
	//                     Public Interactions
	// =============================================================

	/// @notice allows to transform blank pads into final pads
	/// @param order the burn order
	function doodle(BurnOrder calldata order) external nonReentrant {
		uint32 seriesId = order.series;
		Series memory series = seriesList[seriesId];

		if (!series.active) {
			revert BurnInactive();
		}

		uint256 length = order.ids.length;
		if (length == 0 || (length % series.burnAmount) != 0) {
			revert InvalidParameter();
		}

		uint256 amount = length / series.burnAmount;
		if (amount > series.bucketSize) {
			revert TooManyRequested();
		}

		uint256 tokenId;
		for (uint i; i < length; i++) {
			tokenId = order.ids[i];
			if (tokenId > BLANK_PAD_MAX_ID) {
				revert InvalidPADID();
			}
			if (msg.sender != IERC721(PAD).ownerOf(tokenId)) {
				revert NotOwnerOfBurnToken();
			}

			IERC721CreatorCore(PAD).burn(tokenId);
		}

		_mintSome(seriesId, amount);
	}

	// =============================================================
	//                       	  Gated Admin
	// =============================================================

	/// @notice allows a creator's admin to create a new series
	/// @param series the series data
	function createSeries(uint256 seriesId, Series memory series) external creatorAdminRequired(PAD) {
		Series memory exists = seriesList[seriesId];
		if (exists.burnAmount != 0) {
			revert SeriesExists();
		}

		if (series.burnAmount == 0) {
			revert InvalidParameter();
		}

		seriesList[seriesId] = series;
	}

	/// @notice allows a PAD admin to change the metadata helper
	/// @param newMetadataHelper the new metadata helper
	function setMetadataHelper(address newMetadataHelper) external creatorAdminRequired(PAD) {
		metadataHelper = newMetadataHelper;
	}

	/// @notice allows a PAD admin to change the base URI
	/// @param newBaseURI the new base uri
	function setBaseURI(string calldata newBaseURI) external creatorAdminRequired(PAD) {
		baseURI = newBaseURI;
	}

	/// @notice allows a PAD admin to mint all the remaining ids
	/// @param seriesId the series id to mint the remaining from
	function mintFromSeries(uint256 seriesId, uint256 amount) external creatorAdminRequired(PAD) {
		if (seriesList[seriesId].active) {
			revert BurnOngoing();
		}

		if (amount > seriesList[seriesId].bucketSize) {
			revert TooManyRequested();
		}

		_mintSome(uint32(seriesId), amount);
	}

	/// @notice allows a PAD admin to deactive the burn for given series
	/// @param series the series ids to deactive burn for
	function stopBurn(uint256[] calldata series) external creatorAdminRequired(PAD) {
		for (uint i; i < series.length; i++) {
			seriesList[series[i]].active = false;
		}
	}

	/// @notice allows a PAD admin to activate the burn for given series
	/// @param series the series ids to activate burn for
	function startBurn(uint256[] calldata series) external creatorAdminRequired(PAD) {
		for (uint i; i < series.length; i++) {
			seriesList[series[i]].active = true;
		}
	}

	// =============================================================
	//                       	   Internals
	// =============================================================

	function _mintSome(uint32 seriesId, uint256 amount) internal {
		uint256 bucketSize = seriesList[seriesId].bucketSize;

		uint256[] memory tokenIds;
		if (amount == 1) {
			tokenIds = new uint256[](1);
			tokenIds[0] = IERC721CreatorCore(PAD).mintExtension(msg.sender);
		} else {
			tokenIds = IERC721CreatorCore(PAD).mintExtensionBatch(msg.sender, uint16(amount));
		}

		for (uint i; i < amount; ) {
			tokenData[tokenIds[i]] = TokenData(
				uint32(seriesId),
				uint32(_pickNextIndex(_buckets[seriesId], bucketSize))
			);
			unchecked {
				++i;
				--bucketSize;
			}
		}

		seriesList[seriesId].bucketSize = uint64(bucketSize);
	}

	function _pickNextIndex(
		mapping(uint256 => uint256) storage _bucket,
		uint256 bucketSize
	) internal returns (uint256 selectedIndex) {
		uint256 seed = _seed(bucketSize);
		uint256 index = 1 + (seed % bucketSize);

		// select value at index
		selectedIndex = _bucket[index];
		if (selectedIndex == 0) {
			// if 0, it was never initialized, so value is index
			selectedIndex = index;
		}

		// if the index picked is not the last one
		if (index != bucketSize) {
			// swap last value of the bucket into the index that was just picked
			uint256 temp = _bucket[bucketSize];
			if (temp != 0) {
				_bucket[index] = temp;
				delete _bucket[bucketSize];
			} else {
				_bucket[index] = bucketSize;
			}
		} else if (index != selectedIndex) {
			// else of the index is the last one, but the value wasn't 0, delete
			delete _bucket[bucketSize];
		}
	}

	function _seed(uint256 size) internal view returns (uint256) {
		return uint256(keccak256(abi.encodePacked(block.difficulty, size)));
	}
}

interface IERC721 {
	function ownerOf(uint256 tokenId) external view returns (address);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @author dievardump (https://twitter.com/dievardump)
interface IMetadataHelper {
	function tokenURI(
		address creator,
		uint256 tokenId,
		uint32 seriesId,
		uint32 index
	) external view returns (string memory);
}