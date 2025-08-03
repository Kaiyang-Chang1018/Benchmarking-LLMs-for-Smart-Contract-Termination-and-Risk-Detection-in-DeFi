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
     * @dev mint a token. Can only be called by a registered extension.
     * Returns tokenId minted
     */
    function mintExtension(address to, uint80 data) external returns (uint256);

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
     * @dev batch mint a token. Can only be called by a registered extension.
     * Returns tokenId minted
     */
    function mintExtensionBatch(address to, uint80[] calldata data) external returns (uint256[] memory);

    /**
     * @dev burn a token. Can only be called by token owner or approved address.
     * On burn, calls back to the registered extension's onBurn method
     */
    function burn(uint256 tokenId) external;

    /**
     * @dev get token data
     */
    function tokenData(uint256 tokenId) external view returns (uint80);

}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @author: manifold.xyz

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/**
 * Implement this if you want your extension to approve a transfer
 */
interface IERC721CreatorExtensionApproveTransfer is IERC165 {

    /**
     * @dev Set whether or not the creator will check the extension for approval of token transfer
     */
    function setApproveTransfer(address creator, bool enabled) external;

    /**
     * @dev Called by creator contract to approve a transfer
     */
    function approveTransfer(address operator, address from, address to, uint256 tokenId) external returns (bool);
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

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IAdminControl.sol";

abstract contract AdminControl is Ownable, IAdminControl, ERC165 {
    using EnumerableSet for EnumerableSet.AddressSet;

    // Track registered admins
    EnumerableSet.AddressSet private _admins;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IAdminControl).interfaceId
            || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Only allows approved admins to call the specified function
     */
    modifier adminRequired() {
        require(owner() == msg.sender || _admins.contains(msg.sender), "AdminControl: Must be owner or admin");
        _;
    }   

    /**
     * @dev See {IAdminControl-getAdmins}.
     */
    function getAdmins() external view override returns (address[] memory admins) {
        admins = new address[](_admins.length());
        for (uint i = 0; i < _admins.length(); i++) {
            admins[i] = _admins.at(i);
        }
        return admins;
    }

    /**
     * @dev See {IAdminControl-approveAdmin}.
     */
    function approveAdmin(address admin) external override onlyOwner {
        if (!_admins.contains(admin)) {
            emit AdminApproved(admin, msg.sender);
            _admins.add(admin);
        }
    }

    /**
     * @dev See {IAdminControl-revokeAdmin}.
     */
    function revokeAdmin(address admin) external override onlyOwner {
        if (_admins.contains(admin)) {
            emit AdminRevoked(admin, msg.sender);
            _admins.remove(admin);
        }
    }

    /**
     * @dev See {IAdminControl-isAdmin}.
     */
    function isAdmin(address admin) public override view returns (bool) {
        return (owner() == admin || _admins.contains(admin));
    }

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
// OpenZeppelin Contracts (last updated v4.7.3) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../Strings.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
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
// OpenZeppelin Contracts (last updated v4.7.2) (utils/introspection/ERC165Checker.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Library used to query support of an interface declared via {IERC165}.
 *
 * Note that these functions return the actual result of the query: they do not
 * `revert` if an interface is not supported. It is up to the caller to decide
 * what to do in these cases.
 */
library ERC165Checker {
    // As per the EIP-165 spec, no interface should ever match 0xffffffff
    bytes4 private constant _INTERFACE_ID_INVALID = 0xffffffff;

    /**
     * @dev Returns true if `account` supports the {IERC165} interface,
     */
    function supportsERC165(address account) internal view returns (bool) {
        // Any contract that implements ERC165 must explicitly indicate support of
        // InterfaceId_ERC165 and explicitly indicate non-support of InterfaceId_Invalid
        return
            _supportsERC165Interface(account, type(IERC165).interfaceId) &&
            !_supportsERC165Interface(account, _INTERFACE_ID_INVALID);
    }

    /**
     * @dev Returns true if `account` supports the interface defined by
     * `interfaceId`. Support for {IERC165} itself is queried automatically.
     *
     * See {IERC165-supportsInterface}.
     */
    function supportsInterface(address account, bytes4 interfaceId) internal view returns (bool) {
        // query support of both ERC165 as per the spec and support of _interfaceId
        return supportsERC165(account) && _supportsERC165Interface(account, interfaceId);
    }

    /**
     * @dev Returns a boolean array where each value corresponds to the
     * interfaces passed in and whether they're supported or not. This allows
     * you to batch check interfaces for a contract where your expectation
     * is that some interfaces may not be supported.
     *
     * See {IERC165-supportsInterface}.
     *
     * _Available since v3.4._
     */
    function getSupportedInterfaces(address account, bytes4[] memory interfaceIds)
        internal
        view
        returns (bool[] memory)
    {
        // an array of booleans corresponding to interfaceIds and whether they're supported or not
        bool[] memory interfaceIdsSupported = new bool[](interfaceIds.length);

        // query support of ERC165 itself
        if (supportsERC165(account)) {
            // query support of each interface in interfaceIds
            for (uint256 i = 0; i < interfaceIds.length; i++) {
                interfaceIdsSupported[i] = _supportsERC165Interface(account, interfaceIds[i]);
            }
        }

        return interfaceIdsSupported;
    }

    /**
     * @dev Returns true if `account` supports all the interfaces defined in
     * `interfaceIds`. Support for {IERC165} itself is queried automatically.
     *
     * Batch-querying can lead to gas savings by skipping repeated checks for
     * {IERC165} support.
     *
     * See {IERC165-supportsInterface}.
     */
    function supportsAllInterfaces(address account, bytes4[] memory interfaceIds) internal view returns (bool) {
        // query support of ERC165 itself
        if (!supportsERC165(account)) {
            return false;
        }

        // query support of each interface in _interfaceIds
        for (uint256 i = 0; i < interfaceIds.length; i++) {
            if (!_supportsERC165Interface(account, interfaceIds[i])) {
                return false;
            }
        }

        // all interfaces supported
        return true;
    }

    /**
     * @notice Query if a contract implements an interface, does not check ERC165 support
     * @param account The address of the contract to query for support of an interface
     * @param interfaceId The interface identifier, as specified in ERC-165
     * @return true if the contract at account indicates support of the interface with
     * identifier interfaceId, false otherwise
     * @dev Assumes that account contains a contract that supports ERC165, otherwise
     * the behavior of this method is undefined. This precondition can be checked
     * with {supportsERC165}.
     * Interface identification is specified in ERC-165.
     */
    function _supportsERC165Interface(address account, bytes4 interfaceId) private view returns (bool) {
        // prepare call
        bytes memory encodedParams = abi.encodeWithSelector(IERC165.supportsInterface.selector, interfaceId);

        // perform static call
        bool success;
        uint256 returnSize;
        uint256 returnValue;
        assembly {
            success := staticcall(30000, account, add(encodedParams, 0x20), mload(encodedParams), 0x00, 0x20)
            returnSize := returndatasize()
            returnValue := mload(0x00)
        }

        return success && returnSize >= 0x20 && returnValue > 0;
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/structs/EnumerableSet.sol)

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
 * ```
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
 *  Trying to delete such a structure from storage will likely result in data corruption, rendering the structure unusable.
 *  See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 *  In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an array of EnumerableSet.
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
        return _values(set._inner);
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
     * @dev Returns the number of values on the set. O(1).
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
pragma solidity ^0.8.0;

interface IERC721CreatorCoreVersion {
    function VERSION() external view returns(uint256);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @author: manifold.xyz

/**
 * Manifold Membership interface
 */
interface IManifoldMembership {
   function isActiveMember(address sender) external view returns (bool);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @author: manifold.xyz
import "@manifoldxyz/libraries-solidity/contracts/access/AdminControl.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "../../libraries/manifold-membership/IManifoldMembership.sol";

import "./ICollectibleCore.sol";

/**
 * Collection Drop Contract (Base)
 */
abstract contract CollectibleCore is ICollectibleCore, AdminControl {
    using ECDSA for bytes32;

    uint256 public constant MINT_FEE = 690000000000000;
    uint256 internal constant MAX_UINT_24 = 0xffffff;
    uint256 internal constant MAX_UINT_56 = 0xffffffffffffff;

    address public manifoldMembershipContract;

    // { creatorContractAddress => { instanceId => nonce => t/f  } }
    mapping(address => mapping(uint256 => mapping(bytes32 => bool))) internal _usedNonces;
    // { creatorContractAddress => { instanceId => address  } }
    mapping(address => mapping(uint256 => address)) private _signingAddresses;
    // { creatorContractAddress => { instanceId => CollectibleInstance } }
    mapping(address => mapping(uint256 => CollectibleInstance)) internal _instances;

    /**
    * @notice This extension is shared, not single-creator. So we must ensure
    * that a claim's initializer is an admin on the creator contract
    * @param creatorContractAddress    the address of the creator contract to check the admin against
    */
    modifier creatorAdminRequired(address creatorContractAddress) {
        AdminControl creatorCoreContract = AdminControl(creatorContractAddress);
        require(creatorCoreContract.isAdmin(msg.sender), "Wallet is not an administrator for contract");
        _;
    }

    /**
    * Initialize collectible
    */
    function _initializeCollectible(
      address creatorContractAddress,
      uint8 creatorContractVersion,
      uint256 instanceId,
      InitializationParameters calldata initializationParameters
    ) internal {
        // Max uint56 for instanceId
        require(instanceId > 0 && instanceId <= MAX_UINT_56, "Invalid instanceId");

        address signingAddress = _signingAddresses[creatorContractAddress][instanceId];
        CollectibleInstance storage instance = _instances[creatorContractAddress][instanceId];

        // Revert if claim at instanceId already exists
        require(signingAddress == address(0), "Collectible already initialized");
        require(initializationParameters.signingAddress != address(0), "Invalid signing address");
        require(initializationParameters.paymentReceiver != address(0), "Invalid payment address");
        require(initializationParameters.purchaseMax != 0, "Invalid purchase max");

        _signingAddresses[creatorContractAddress][instanceId] = initializationParameters.signingAddress;
        instance.contractVersion = creatorContractVersion;
        instance.purchaseMax = initializationParameters.purchaseMax;
        instance.purchasePrice = initializationParameters.purchasePrice;
        instance.purchaseLimit = initializationParameters.purchaseLimit;
        instance.transactionLimit = initializationParameters.transactionLimit;
        instance.presalePurchasePrice = initializationParameters.presalePurchasePrice;
        instance.presalePurchaseLimit = initializationParameters.presalePurchaseLimit;
        instance.useDynamicPresalePurchaseLimit = initializationParameters.useDynamicPresalePurchaseLimit;
        instance.paymentReceiver = initializationParameters.paymentReceiver;

        emit CollectibleInitialized(creatorContractAddress, instanceId, msg.sender);
    }

    /**
    * See {ICollectibleCore-withdraw}.
    */
    function withdraw(address payable receiver, uint256 amount) external override adminRequired {
        (bool sent, ) = receiver.call{ value: amount }("");
        require(sent, "Failed to transfer to receiver");
    }

    /**
    * See {ICollectibleCore-activate}.
    */
    function activate(
      address creatorContractAddress,
      uint256 instanceId,
      ActivationParameters calldata activationParameters
    ) external override creatorAdminRequired(creatorContractAddress) {
        CollectibleInstance storage instance = _getInstance(creatorContractAddress, instanceId);
        require(!instance.isActive, "Already active");
        require(activationParameters.startTime > block.timestamp, "Cannot activate in the past");
        require(
          activationParameters.presaleInterval <= activationParameters.duration,
          "Presale Interval cannot be longer than the sale"
        );
        require(
          activationParameters.claimStartTime <= activationParameters.claimEndTime &&
            activationParameters.claimEndTime <= activationParameters.startTime,
          "Invalid claim times"
        );
        instance.startTime = activationParameters.startTime;
        instance.endTime = activationParameters.startTime + activationParameters.duration;
        instance.presaleInterval = activationParameters.presaleInterval;
        instance.claimStartTime = activationParameters.claimStartTime;
        instance.claimEndTime = activationParameters.claimEndTime;
        instance.isActive = true;

        emit CollectibleActivated(
          creatorContractAddress,
          instanceId,
          instance.startTime,
          instance.endTime,
          instance.presaleInterval,
          instance.claimStartTime,
          instance.claimEndTime
        );
    }

    /**
    * See {ICollectibleCore-deactivate}.
    */
    function deactivate(
      address creatorContractAddress,
      uint256 instanceId
    ) external override creatorAdminRequired(creatorContractAddress) {
        CollectibleInstance storage instance = _getInstance(creatorContractAddress, instanceId);

        instance.startTime = 0;
        instance.endTime = 0;
        instance.isActive = false;
        instance.claimStartTime = 0;
        instance.claimEndTime = 0;

        emit CollectibleDeactivated(creatorContractAddress, instanceId);
    }

    /**
    * @dev See {ICollectibleCore-getCollectible}.
    */
    function getCollectible(
        address creatorContractAddress,
        uint256 index
    ) external view override returns (CollectibleInstance memory) {
        return _getCollectible(creatorContractAddress, index);
    }

    /**
    * @dev See {IERC721Collectible-setMembershipAddress}.
    */
    function setMembershipAddress(address addr) external override adminRequired {
        manifoldMembershipContract = addr;
    }

    /**
    * @dev See {ICollectibleCore-updateInitializationParameters}.
    */
    function updateInitializationParameters(
        address creatorContractAddress,
        uint256 instanceId,
        UpdateInitializationParameters calldata initializationParameters
    ) external override creatorAdminRequired(creatorContractAddress) {
        CollectibleInstance storage instance = _getInstance(creatorContractAddress, instanceId);

        require(!instance.isActive, "Already active");
        instance.purchasePrice = initializationParameters.purchasePrice;
        instance.purchaseLimit = initializationParameters.purchaseLimit;
        instance.transactionLimit = initializationParameters.transactionLimit;
        instance.presalePurchasePrice = initializationParameters.presalePurchasePrice;
        instance.presalePurchaseLimit = initializationParameters.presalePurchaseLimit;
        instance.useDynamicPresalePurchaseLimit = initializationParameters.useDynamicPresalePurchaseLimit;
    }

    /**
    * @dev See {ICollectibleCore-updatePaymentReceiver}.
    */
    function updatePaymentReceiver(
        address creatorContractAddress,
        uint256 instanceId,
        address payable paymentReceiver
    ) external override creatorAdminRequired(creatorContractAddress) {
        CollectibleInstance storage instance = _getInstance(creatorContractAddress, instanceId);
        require(paymentReceiver != address(0), "Invalid payment address");

        instance.paymentReceiver = paymentReceiver;
    }

    /**
    * Validate claim signature
    */
    function _getCollectible(
        address creatorContractAddress,
        uint256 instanceId
    ) internal view returns (CollectibleInstance storage) {
        return _instances[creatorContractAddress][instanceId];
    }

    /**
    * Validate claim signature
    */
    function _validateClaimRequest(
        address creatorContractAddress,
        uint256 instanceId,
        bytes32 message,
        bytes calldata signature,
        bytes32 nonce,
        uint16 amount
    ) internal virtual {
        _validatePurchaseRequestWithAmount(creatorContractAddress, instanceId, message, signature, nonce, amount);
    }

    /**
    * Validate claim restrictions
    */
    function _validateClaimRestrictions(address creatorContractAddress, uint256 instanceId) internal virtual {
        CollectibleInstance storage instance = _getInstance(creatorContractAddress, instanceId);
        require(instance.isActive, "Inactive");
        require(block.timestamp >= instance.claimStartTime && block.timestamp <= instance.claimEndTime, "Outside claim period.");
    }

    /**
    * Validate purchase signature
    */
    function _validatePurchaseRequest(
        address creatorContractAddress,
        uint256 instanceId,
        bytes32 message,
        bytes calldata signature,
        bytes32 nonce
    ) internal virtual {
        // Verify nonce usage/re-use
        require(!_usedNonces[creatorContractAddress][instanceId][nonce], "Cannot replay transaction");
        // Verify valid message based on input variables
        bytes32 expectedMessage = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n52", msg.sender, nonce));
        require(message == expectedMessage, "Malformed message");
        // Verify signature was performed by the expected signing address
        address signer = message.recover(signature);
        address signingAddress = _signingAddresses[creatorContractAddress][instanceId];
        require(signer == signingAddress, "Invalid signature");

        _usedNonces[creatorContractAddress][instanceId][nonce] = true;
    }

    /**
    * Validate purchase signature with amount
    */
    function _validatePurchaseRequestWithAmount(
        address creatorContractAddress,
        uint256 instanceId,
        bytes32 message,
        bytes calldata signature,
        bytes32 nonce,
        uint16 amount
    ) internal virtual {
        // Verify nonce usage/re-use
        require(!_usedNonces[creatorContractAddress][instanceId][nonce], "Cannot replay transaction");
        // Verify valid message based on input variables
        bytes32 expectedMessage = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n54", msg.sender, nonce, amount));
        require(message == expectedMessage, "Malformed message");
        // Verify signature was performed by the expected signing address
        address signer = message.recover(signature);
        address signingAddress = _signingAddresses[creatorContractAddress][instanceId];
        require(signer == signingAddress, "Invalid signature");

        _usedNonces[creatorContractAddress][instanceId][nonce] = true;
    }

    /**
    * Perform purchase restriction checks. Override if more logic is needed
    */
    function _validatePurchaseRestrictions(address creatorContractAddress, uint256 instanceId) internal virtual {
        CollectibleInstance storage instance = _getInstance(creatorContractAddress, instanceId);

        require(instance.isActive, "Inactive");
        require(block.timestamp >= instance.startTime, "Purchasing not active");
    }

    /**
    * @dev See {ICollectibleCore-nonceUsed}.
    */
    function nonceUsed(
        address creatorContractAddress,
        uint256 instanceId,
        bytes32 nonce
    ) external view override returns (bool) {
        return _usedNonces[creatorContractAddress][instanceId][nonce];
    }

    /**
    * @dev Check if currently in presale
    */
    function _isPresale(address creatorContractAddress, uint256 instanceId) internal view returns (bool) {
        CollectibleInstance storage instance = _getInstance(creatorContractAddress, instanceId);

        return (block.timestamp > instance.startTime && block.timestamp - instance.startTime < instance.presaleInterval);
    }

    function _getInstance(
        address creatorContractAddress,
        uint256 instanceId
    ) internal view returns (CollectibleInstance storage instance) {
        instance = _instances[creatorContractAddress][instanceId];
        require(instance.purchaseMax != 0, "Collectible not initialized");
    }

    /**
    * Send funds to receiver
    */
    function _forwardValue(address payable receiver, uint256 amount) internal {
        (bool sent, ) = receiver.call{ value: amount }("");
        require(sent, "Failed to transfer to recipient");
    }

    /**
    * Helper to check if the sender holds an active Manifold membership
    */
    function _isActiveMember(address sender) internal view returns(bool) {
        return manifoldMembershipContract != address(0) &&
            IManifoldMembership(manifoldMembershipContract).isActiveMember(sender);
    }

    /**
    * Helper to get the Manifold fee for the sender
    */
    function _getManifoldFee(uint256 numTokens) internal view returns(uint256) {
        return _isActiveMember(msg.sender) ? 0 : (MINT_FEE * numTokens);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @author: manifold.xyz

import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import "@manifoldxyz/libraries-solidity/contracts/access/AdminControl.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./IERC721Collectible.sol";
import "./CollectibleCore.sol";
import "../../libraries/IERC721CreatorCoreVersion.sol";

contract ERC721Collectible is CollectibleCore, IERC721Collectible {
    struct TokenClaim {
      uint224 instanceId;
      uint32 mintOrder;
    }

    // NOTE: Only used for creatorContract versions < 3
    // { contractAddress => { tokenId => TokenClaim }
    mapping(address => mapping(uint256 => TokenClaim)) internal _tokenIdToTokenClaimMap;

    // { contractAddress => { instanceId => { address => mintCount } }
    mapping(address => mapping(uint256 => mapping(address => uint256))) internal _addressMintCount;

    function supportsInterface(bytes4 interfaceId) public view virtual override(AdminControl, IERC165) returns (bool) {
        return (interfaceId == type(IERC721Collectible).interfaceId ||
            interfaceId == type(ICreatorExtensionTokenURI).interfaceId ||
            interfaceId == type(IERC721CreatorExtensionApproveTransfer).interfaceId ||
            interfaceId == type(IAdminControl).interfaceId ||
            interfaceId == type(IERC165).interfaceId);
    }

    /**
    * See {ICollectibleCore-initializeCollectible}.
    */
    function initializeCollectible(
        address creatorContractAddress,
        uint256 instanceId,
        InitializationParameters calldata initializationParameters
    ) external override creatorAdminRequired(creatorContractAddress) {
        uint8 creatorContractVersion;
        try IERC721CreatorCoreVersion(creatorContractAddress).VERSION() returns(uint256 version) {
            require(version <= 255, "Unsupported contract version");
            creatorContractVersion = uint8(version);
        } catch {}
        _initializeCollectible(creatorContractAddress, creatorContractVersion, instanceId, initializationParameters);
  }

    /**
    * @dev See {IERC721Collectible-premint}.
    */
    function premint(
        address creatorContractAddress,
        uint256 instanceId,
        uint16 amount
    ) external override creatorAdminRequired(creatorContractAddress) {
        CollectibleInstance storage instance = _getInstance(creatorContractAddress, instanceId);
        require(!instance.isActive, "Already active");

        _mint(creatorContractAddress, instanceId, msg.sender, amount);
    }

    /**
    * @dev See {IERC721Collectible-premint}.
    */
    function premint(
        address creatorContractAddress,
        uint256 instanceId,
        address[] calldata addresses
    ) external override creatorAdminRequired(creatorContractAddress) {
        CollectibleInstance storage instance = _getInstance(creatorContractAddress, instanceId);
        require(!instance.isActive, "Already active");

        for (uint256 i = 0; i < addresses.length; ) {
            _mint(creatorContractAddress, instanceId, addresses[i], 1);
            unchecked {
              i++;
            }
        }
    }

    /**
    * @dev See {IERC721Collectible-setTokenURIPrefix}.
    */
    function setTokenURIPrefix(
        address creatorContractAddress,
        uint256 instanceId,
        string calldata prefix
    ) external override creatorAdminRequired(creatorContractAddress) {
        CollectibleInstance storage instance = _getInstance(creatorContractAddress, instanceId);
        instance.baseURI = prefix;
    }

    /**
    * @dev See {IERC721Collectible-setTransferLocked}.
    */
    function setTransferLocked(
        address creatorContractAddress,
        uint256 instanceId,
        bool isLocked
    ) external override creatorAdminRequired(creatorContractAddress) {
        CollectibleInstance storage instance = _getInstance(creatorContractAddress, instanceId);
        instance.isTransferLocked = isLocked;
    }

    /**
    * @dev See {IERC721Collectible-claim}.
    */
    function claim(
        address creatorContractAddress,
        uint256 instanceId,
        uint16 amount,
        bytes32 message,
        bytes calldata signature,
        bytes32 nonce
    ) public payable virtual override {
        _validateClaimRestrictions(creatorContractAddress, instanceId);
        _validateClaimRequest(creatorContractAddress, instanceId, message, signature, nonce, amount);
        _addressMintCount[creatorContractAddress][instanceId][msg.sender] += amount;
        require(msg.value == _getManifoldFee(amount), "Invalid purchase amount");
        _mint(creatorContractAddress, instanceId, msg.sender, amount);
    }

    /**
    * @dev See {IERC721Collection-purchase}.
    */
    function purchase(
      address creatorContractAddress,
      uint256 instanceId,
      uint16 amount,
      bytes32 message,
      bytes calldata signature,
      bytes32 nonce
    ) public payable virtual override {
        CollectibleInstance storage instance = _getInstance(creatorContractAddress, instanceId);
        _validatePurchaseRestrictions(creatorContractAddress, instanceId);

        bool isPresale = _isPresale(creatorContractAddress, instanceId);
        uint256 priceWithoutFee;

        // Check purchase amounts
        require(
            amount <= purchaseRemaining(creatorContractAddress, instanceId) &&
                ((isPresale && instance.useDynamicPresalePurchaseLimit) ||
                  instance.transactionLimit == 0 ||
                  amount <= instance.transactionLimit),
            "Too many requested"
        );

        if (isPresale) {
            if (!instance.useDynamicPresalePurchaseLimit) {
                // Make sure we are not over presalePurchaseLimit
                if (instance.presalePurchaseLimit != 0) {
                    uint256 mintCount = _addressMintCount[creatorContractAddress][instanceId][msg.sender];
                    require(
                        instance.presalePurchaseLimit > mintCount && amount <= (instance.presalePurchaseLimit - mintCount),
                        "Too many requested"
                    );
                }
                // Make sure we are not over purchaseLimit
                if (instance.purchaseLimit != 0) {
                    uint256 mintCount = _addressMintCount[creatorContractAddress][instanceId][msg.sender];
                    require(
                        instance.purchaseLimit > mintCount && amount <= (instance.purchaseLimit - mintCount),
                        "Too many requested"
                    );
                  }
              }
            priceWithoutFee = _validatePresalePrice(amount, instance);
            // Only track mint count if needed
            if (!instance.useDynamicPresalePurchaseLimit && (instance.presalePurchaseLimit != 0 || instance.purchaseLimit != 0)) {
                _addressMintCount[creatorContractAddress][instanceId][msg.sender] += amount;
            }
        } else {
            // Make sure we are not over purchaseLimit
            if (instance.purchaseLimit != 0) {
                uint256 mintCount = _addressMintCount[creatorContractAddress][instanceId][msg.sender];
                require(instance.purchaseLimit > mintCount && amount <= (instance.purchaseLimit - mintCount), "Too many requested");
            }
            priceWithoutFee = _validatePrice(amount, instance);

            if (instance.purchaseLimit != 0) {
                _addressMintCount[creatorContractAddress][instanceId][msg.sender] += amount;
            }
        }

        if (isPresale && instance.useDynamicPresalePurchaseLimit) {
           _validatePurchaseRequestWithAmount(creatorContractAddress, instanceId, message, signature, nonce, amount);
        } else {
            _validatePurchaseRequest(creatorContractAddress, instanceId, message, signature, nonce);
        }

        if (priceWithoutFee > 0) {
            _forwardValue(instance.paymentReceiver, priceWithoutFee);
        }

        _mint(creatorContractAddress, instanceId, msg.sender, amount);
    }

    /**
    * @dev returns the collection state
    */
    function state(address creatorContractAddress, uint256 instanceId) external view returns (CollectibleState memory) {
        CollectibleInstance storage instance = _getInstance(creatorContractAddress, instanceId);

        return CollectibleState(
            instance.isActive,
            instance.useDynamicPresalePurchaseLimit,
            instance.isTransferLocked,
            instance.transactionLimit,
            instance.purchaseMax,
            instance.purchaseLimit,
            instance.presalePurchaseLimit,
            instance.purchaseCount,
            instance.startTime,
            instance.endTime,
            instance.presaleInterval,
            instance.claimStartTime,
            instance.claimEndTime,
            instance.purchasePrice,
            instance.presalePurchasePrice,
            purchaseRemaining(creatorContractAddress, instanceId),
            instance.paymentReceiver
        );
    }

    /**
    * @dev See {IERC721Collectible-purchaseRemaining}.
    */
    function purchaseRemaining(
        address creatorContractAddress,
        uint256 instanceId
    ) public view virtual override returns (uint16) {
        CollectibleInstance storage instance = _getInstance(creatorContractAddress, instanceId);
        return instance.purchaseMax - instance.purchaseCount;
    }

    /**
    * @dev See {ICreatorExtensionTokenURI-tokenURI}
    */
    function tokenURI(address creatorContractAddress, uint256 tokenId) external view override returns (string memory) {
        TokenClaim memory tokenClaim = _tokenIdToTokenClaimMap[creatorContractAddress][tokenId];
        uint256 mintOrder;
        CollectibleInstance memory instance;
        if (tokenClaim.instanceId == 0) {
            // No claim, try to retrieve from tokenData
            uint80 tokenData = IERC721CreatorCore(creatorContractAddress).tokenData(tokenId);
            uint56 instanceId = uint56(tokenData >> 24);
            require(instanceId != 0, "Token not found");
            instance = _getInstance(creatorContractAddress, instanceId);
            mintOrder = uint24(tokenData & MAX_UINT_24);
        } else {
            mintOrder = tokenClaim.mintOrder;
            instance = _getInstance(creatorContractAddress, tokenClaim.instanceId);
        }

        require(bytes(instance.baseURI).length != 0, "No base uri prefix set");

        return string(abi.encodePacked(instance.baseURI, Strings.toString(mintOrder)));
    }

    /**
    * @dev See {IERC721CreatorExtensionApproveTransfer-setApproveTransfer}
    */
    function setApproveTransfer(
      address creatorContractAddress,
      bool enabled
    ) external override creatorAdminRequired(creatorContractAddress) {
        require(
            ERC165Checker.supportsInterface(creatorContractAddress, type(IERC721CreatorCore).interfaceId),
            "creator must implement IERC721CreatorCore"
        );
        IERC721CreatorCore(creatorContractAddress).setApproveTransferExtension(enabled);
    }

    /**
    * @dev See {IERC721CreatorExtensionApproveTransfer-approveTransfer}.
    */
    function approveTransfer(address, address from, address, uint256 tokenId) external view override returns (bool) {
        // always allow mints
        if (from == address(0)) {
            return true;
        }
        TokenClaim memory tokenClaim = _tokenIdToTokenClaimMap[msg.sender][tokenId];
        uint256 instanceId;
        if (tokenClaim.instanceId == 0) {
            // No claim, try to retrieve from tokenData
            uint80 tokenData = IERC721CreatorCore(msg.sender).tokenData(tokenId);
            instanceId = uint56(tokenData >> 24);
            require(instanceId != 0, "Token not found");
        } else {
            instanceId = tokenClaim.instanceId;
        }
        CollectibleInstance storage instance = _getInstance(msg.sender, instanceId);

        return !instance.isTransferLocked;
    }

    /**
    * @dev override if you want to perform different mint functionality
    */
    function _mint(address creatorContractAddress, uint256 instanceId, address to, uint16 amount) internal virtual {
        CollectibleInstance storage instance = _getInstance(creatorContractAddress, instanceId);

        if (amount == 1) {
            uint256 tokenId;
            if (instance.contractVersion >= 3) {
                uint80 tokenData = uint56(instanceId) << 24 | uint24(++instance.purchaseCount);
                tokenId = IERC721CreatorCore(creatorContractAddress).mintExtension(to, tokenData);
            } else {
                ++instance.purchaseCount;
                tokenId = IERC721CreatorCore(creatorContractAddress).mintExtension(to);
                _tokenIdToTokenClaimMap[creatorContractAddress][tokenId] = TokenClaim(uint224(instanceId), instance.purchaseCount);
            }
            emit Unveil(creatorContractAddress, instanceId, instance.purchaseCount, tokenId);
        } else {
            uint32 tokenStart = instance.purchaseCount + 1;
            instance.purchaseCount += amount;
            if (instance.contractVersion >= 3) {
                uint80[] memory tokenDatas = new uint80[](amount);
                for (uint256 i; i < amount;) {
                    tokenDatas[i] = uint56(instanceId) << 24 | uint24(tokenStart + i);
                    unchecked { ++i; }
                }
                uint256[] memory tokenIds = IERC721CreatorCore(creatorContractAddress).mintExtensionBatch(to, tokenDatas);
                for (uint32 i = 0; i < amount; ) {
                    emit Unveil(creatorContractAddress, instanceId, tokenStart + i, tokenIds[i]);
                    unchecked { ++i; }
                }
            } else {
                uint256[] memory tokenIds = IERC721CreatorCore(creatorContractAddress).mintExtensionBatch(to, amount);
                for (uint32 i = 0; i < amount; ) {
                    emit Unveil(creatorContractAddress, instanceId, tokenStart + i, tokenIds[i]);
                    _tokenIdToTokenClaimMap[creatorContractAddress][tokenIds[i]] = TokenClaim(uint224(instanceId), tokenStart + i);
                    unchecked { ++i; }
                }
            }
        }
    }

    /**
    * Validate price (override for custom pricing mechanics)
    */
    function _validatePrice(uint16 numTokens, CollectibleInstance storage instance) internal virtual returns (uint256) {
        uint256 priceWithoutFee = numTokens * instance.purchasePrice;
        uint256 price = priceWithoutFee + _getManifoldFee(numTokens);
        require(msg.value == price, "Invalid purchase amount sent");

        return priceWithoutFee;
    }

    /**
    * Validate price (override for custom pricing mechanics)
    */
    function _validatePresalePrice(uint16 numTokens, CollectibleInstance storage instance) internal virtual returns (uint256) {
        uint256 priceWithoutFee = numTokens * instance.presalePurchasePrice;
        uint256 price = priceWithoutFee + _getManifoldFee(numTokens);
        require(msg.value == price, "Invalid purchase amount sent");

        return priceWithoutFee;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/// @author: manifold.xyz

/**
 * @dev CollectibleBase Interface
 */
interface ICollectibleCore is IERC165 {
    struct ActivationParameters {
        uint48 startTime;
        uint48 duration;
        uint48 presaleInterval;
        uint48 claimStartTime;
        uint48 claimEndTime;
    }

    struct InitializationParameters {
        bool useDynamicPresalePurchaseLimit;
        uint16 transactionLimit;
        uint16 purchaseMax;
        uint16 purchaseLimit;
        uint16 presalePurchaseLimit;
        uint256 purchasePrice;
        uint256 presalePurchasePrice;
        address signingAddress;
        address payable paymentReceiver;
    }


    struct UpdateInitializationParameters {
        bool useDynamicPresalePurchaseLimit;
        uint16 transactionLimit;
        uint16 purchaseMax;
        uint16 purchaseLimit;
        uint16 presalePurchaseLimit;
        uint256 purchasePrice;
        uint256 presalePurchasePrice;
    }

    struct CollectibleInstance {
        bool isActive;
        bool useDynamicPresalePurchaseLimit;
        bool isTransferLocked;
        uint8 contractVersion;
        uint16 transactionLimit;
        uint16 purchaseMax;
        uint16 purchaseLimit;
        uint16 presalePurchaseLimit;
        uint16 purchaseCount;
        uint48 startTime;
        uint48 endTime;
        uint48 presaleInterval;
        uint48 claimStartTime;
        uint48 claimEndTime;
        uint256 purchasePrice;
        uint256 presalePurchasePrice;
        string baseURI;
        address payable paymentReceiver;
    }

    struct CollectibleState {
        bool isActive;
        bool useDynamicPresalePurchaseLimit;
        bool isTransferLocked;
        uint16 transactionLimit;
        uint16 purchaseMax;
        uint16 purchaseLimit;
        uint16 presalePurchaseLimit;
        uint16 purchaseCount;
        uint48 startTime;
        uint48 endTime;
        uint48 presaleInterval;
        uint48 claimStartTime;
        uint48 claimEndTime;
        uint256 purchasePrice;
        uint256 presalePurchasePrice;
        uint256 purchaseRemaining;
        address payable paymentReceiver;
    }

    event CollectibleInitialized(address creatorContractAddress, uint256 instanceId, address initializer);

    event CollectibleActivated(
        address creatorContractAddress,
        uint256 instanceId,
        uint48 startTime,
        uint48 endTime,
        uint48 presaleInterval,
        uint48 claimStartTime,
        uint48 claimEndTime
    );

    event CollectibleDeactivated(address creatorContractAddress, uint256 instanceId);

    /**
    * @notice get a burn redeem corresponding to a creator contract and index
    * @param creatorContractAddress    the address of the creator contract
    * @param index                     the index of the burn redeem
    * @return CollectibleInstsance               the burn redeem object
    */
    function getCollectible(
        address creatorContractAddress,
        uint256 index
    ) external view returns (CollectibleInstance memory);

    /**
    * @dev Check if nonce has been used
    * @param creatorContractAddress    the creator contract address
    * @param instanceId                the index of the claim for which we will mint
    */
    function nonceUsed(address creatorContractAddress, uint256 instanceId, bytes32 nonce) external view returns (bool);

    /**
    * @dev Activate the contract
    * @param creatorContractAddress    the creator contract the claim will mint tokens for
    * @param instanceId                the index of the claim in the list of creatorContractAddress' _claims
    * @param activationParameters      the sale start time
    */
    function activate(
        address creatorContractAddress,
        uint256 instanceId,
        ActivationParameters calldata activationParameters
    ) external;

    /**
    * @dev Deactivate the contract
    * @param creatorContractAddress    the creator contract the claim will mint tokens for
    * @param instanceId                the index of the claim in the list of creatorContractAddress' _claims
    */
    function deactivate(address creatorContractAddress, uint256 instanceId) external;

    /**
    * @notice Set the Manifold Membership address
    */
    function setMembershipAddress(address membershipAddress) external;

    /**
    * @notice withdraw Manifold fee proceeds from the contract
    * @param recipient                 recepient of the funds
    * @param amount                    amount to withdraw in Wei
    */
    function withdraw(address payable recipient, uint256 amount) external;

    /**
    * @notice initialize a new burn redeem, emit initialize event, and return the newly created index
    * @param creatorContractAddress    the creator contract the burn will mint redeem tokens for
    * @param instanceId                the id of the multi-asssetclaim in the mapping of creatorContractAddress <-> instance id
    * @param initializationParameters  initial claim parameters
    */
    function initializeCollectible(
        address creatorContractAddress,
        uint256 instanceId,
        InitializationParameters calldata initializationParameters
    ) external;

    /**
    * Updates a handful of sale parameters
    * @param creatorContractAddress    the creator contract the burn will mint redeem tokens for
    * @param instanceId                the id of the multi-asssetclaim in the mapping of creatorContractAddress <-> instance id
    * @param initializationParameters  initial claim parameters
    */
    function updateInitializationParameters(
        address creatorContractAddress,
        uint256 instanceId,
        UpdateInitializationParameters calldata initializationParameters
    ) external;

    /**
    * Updates payment receiver
    * @param creatorContractAddress    the creator contract the burn will mint redeem tokens for
    * @param instanceId                the id of the multi-asssetclaim in the mapping of creatorContractAddress <-> instance id
    * @param paymentReceiver           the new address that will receive payments
    */
    function updatePaymentReceiver(
        address creatorContractAddress,
        uint256 instanceId,
        address payable paymentReceiver
    ) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @author: manifold.xyz

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@manifoldxyz/creator-core-solidity/contracts/core/IERC721CreatorCore.sol";
import "@manifoldxyz/creator-core-solidity/contracts/extensions/ERC721/IERC721CreatorExtensionApproveTransfer.sol";
import "@manifoldxyz/creator-core-solidity/contracts/extensions/ICreatorExtensionTokenURI.sol";

import "./ICollectibleCore.sol";

/**
 * @dev ERC721 Collection Interface
 */
interface IERC721Collectible is ICollectibleCore, IERC721CreatorExtensionApproveTransfer, ICreatorExtensionTokenURI {
    event Unveil(address creatorContractAddress, uint256 instanceId, uint256 tokenMintIndex, uint256 tokenId);

    /**
    * @dev Pre-mint given amount to caller
    * @param creatorContractAddress    the creator contract the claim will mint tokens for
    * @param instanceId                the id of the claim in the list of creatorContractAddress' _instances
    * @param amount                    the number of tokens to mint
    */
    function premint(address creatorContractAddress, uint256 instanceId, uint16 amount) external;

    /**
    * @dev Pre-mint 1 token to designated addresses
    * @param creatorContractAddress    the creator contract the claim will mint tokens for
    * @param instanceId                the id of the claim in the list of creatorContractAddress' _instances
    * @param addresses                 List of addresses to premint to
    */
    function premint(address creatorContractAddress, uint256 instanceId, address[] calldata addresses) external;

    /**
    *  @dev set the tokenURI prefix
    * @param creatorContractAddress    the creator contract the claim will mint tokens for
    * @param instanceId                the id of the claim in the list of creatorContractAddress' _instances
    * @param prefix                    the uri prefix to set
    */
    function setTokenURIPrefix(address creatorContractAddress, uint256 instanceId, string calldata prefix) external;

    /**
    * @dev Set whether or not token transfers are locked until end of sale.
    * @param creatorContractAddress    the creator contract the claim will mint tokens for
    * @param instanceId                the id of the claim in the list of creatorContractAddress' _instances
    * @param locked Whether or not transfers are locked
    */
    function setTransferLocked(address creatorContractAddress, uint256 instanceId, bool locked) external;

    /**
    * @dev The `claim` function represents minting during a free claim period. A bit of an overloaded use of hte word "claim".
    */
    function claim(
        address creatorContractAddress,
        uint256 instanceId,
        uint16 amount,
        bytes32 message,
        bytes calldata signature,
        bytes32 nonce
    ) external payable;

    /**
    * @dev purchase
    */
    function purchase(
        address creatorContractAddress,
        uint256 instanceId,
        uint16 amount,
        bytes32 message,
        bytes calldata signature,
        bytes32 nonce
    ) external payable;

    /**
    * @dev returns the collection state
    */
    function state(address creatorContractAddress, uint256 instanceId) external view returns (CollectibleState memory);

    /**
    * @dev Get number of tokens left
    */
    function purchaseRemaining(address creatorContractAddress, uint256 instanceId) external view returns (uint16);
}