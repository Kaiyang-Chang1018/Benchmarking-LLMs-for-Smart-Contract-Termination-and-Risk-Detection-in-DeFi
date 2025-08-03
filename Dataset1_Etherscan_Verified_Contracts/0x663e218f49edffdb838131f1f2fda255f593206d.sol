// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Optimized and flexible operator filterer to abide to OpenSea's
/// mandatory on-chain royalty enforcement in order for new collections to
/// receive royalties.
/// For more information, see:
/// See: https://github.com/ProjectOpenSea/operator-filter-registry
abstract contract OperatorFilterer {
    /// @dev The default OpenSea operator blocklist subscription.
    address internal constant _DEFAULT_SUBSCRIPTION = 0x3cc6CddA760b79bAfa08dF41ECFA224f810dCeB6;

    /// @dev The OpenSea operator filter registry.
    address internal constant _OPERATOR_FILTER_REGISTRY = 0x000000000000AAeB6D7670E522A718067333cd4E;

    /// @dev Registers the current contract to OpenSea's operator filter,
    /// and subscribe to the default OpenSea operator blocklist.
    /// Note: Will not revert nor update existing settings for repeated registration.
    function _registerForOperatorFiltering() internal virtual {
        _registerForOperatorFiltering(_DEFAULT_SUBSCRIPTION, true);
    }

    /// @dev Registers the current contract to OpenSea's operator filter.
    /// Note: Will not revert nor update existing settings for repeated registration.
    function _registerForOperatorFiltering(address subscriptionOrRegistrantToCopy, bool subscribe)
        internal
        virtual
    {
        /// @solidity memory-safe-assembly
        assembly {
            let functionSelector := 0x7d3e3dbe // `registerAndSubscribe(address,address)`.

            // Clean the upper 96 bits of `subscriptionOrRegistrantToCopy` in case they are dirty.
            subscriptionOrRegistrantToCopy := shr(96, shl(96, subscriptionOrRegistrantToCopy))

            for {} iszero(subscribe) {} {
                if iszero(subscriptionOrRegistrantToCopy) {
                    functionSelector := 0x4420e486 // `register(address)`.
                    break
                }
                functionSelector := 0xa0af2903 // `registerAndCopyEntries(address,address)`.
                break
            }
            // Store the function selector.
            mstore(0x00, shl(224, functionSelector))
            // Store the `address(this)`.
            mstore(0x04, address())
            // Store the `subscriptionOrRegistrantToCopy`.
            mstore(0x24, subscriptionOrRegistrantToCopy)
            // Register into the registry.
            if iszero(call(gas(), _OPERATOR_FILTER_REGISTRY, 0, 0x00, 0x44, 0x00, 0x04)) {
                // If the function selector has not been overwritten,
                // it is an out-of-gas error.
                if eq(shr(224, mload(0x00)), functionSelector) {
                    // To prevent gas under-estimation.
                    revert(0, 0)
                }
            }
            // Restore the part of the free memory pointer that was overwritten,
            // which is guaranteed to be zero, because of Solidity's memory size limits.
            mstore(0x24, 0)
        }
    }

    /// @dev Modifier to guard a function and revert if the caller is a blocked operator.
    modifier onlyAllowedOperator(address from) virtual {
        if (from != msg.sender) {
            if (!_isPriorityOperator(msg.sender)) {
                if (_operatorFilteringEnabled()) _revertIfBlocked(msg.sender);
            }
        }
        _;
    }

    /// @dev Modifier to guard a function from approving a blocked operator..
    modifier onlyAllowedOperatorApproval(address operator) virtual {
        if (!_isPriorityOperator(operator)) {
            if (_operatorFilteringEnabled()) _revertIfBlocked(operator);
        }
        _;
    }

    /// @dev Helper function that reverts if the `operator` is blocked by the registry.
    function _revertIfBlocked(address operator) private view {
        /// @solidity memory-safe-assembly
        assembly {
            // Store the function selector of `isOperatorAllowed(address,address)`,
            // shifted left by 6 bytes, which is enough for 8tb of memory.
            // We waste 6-3 = 3 bytes to save on 6 runtime gas (PUSH1 0x224 SHL).
            mstore(0x00, 0xc6171134001122334455)
            // Store the `address(this)`.
            mstore(0x1a, address())
            // Store the `operator`.
            mstore(0x3a, operator)

            // `isOperatorAllowed` always returns true if it does not revert.
            if iszero(staticcall(gas(), _OPERATOR_FILTER_REGISTRY, 0x16, 0x44, 0x00, 0x00)) {
                // Bubble up the revert if the staticcall reverts.
                returndatacopy(0x00, 0x00, returndatasize())
                revert(0x00, returndatasize())
            }

            // We'll skip checking if `from` is inside the blacklist.
            // Even though that can block transferring out of wrapper contracts,
            // we don't want tokens to be stuck.

            // Restore the part of the free memory pointer that was overwritten,
            // which is guaranteed to be zero, if less than 8tb of memory is used.
            mstore(0x3a, 0)
        }
    }

    /// @dev For deriving contracts to override, so that operator filtering
    /// can be turned on / off.
    /// Returns true by default.
    function _operatorFilteringEnabled() internal view virtual returns (bool) {
        return true;
    }

    /// @dev For deriving contracts to override, so that preferred marketplaces can
    /// skip operator filtering, helping users save gas.
    /// Returns false for all inputs by default.
    function _isPriorityOperator(address) internal view virtual returns (bool) {
        return false;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (interfaces/IERC2981.sol)

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
    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

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
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

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
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

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
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

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
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

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
    function setApprovalForAll(address operator, bool _approved) external;

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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

import "./math/Math.sol";

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/cryptography/ECDSA.sol)

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
        InvalidSignatureV // Deprecated in v4.8
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

pragma solidity ^0.8.0;

import "./ECDSA.sol";

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding specified in the EIP is very generic, and such a generic implementation in Solidity is not feasible,
 * thus this contract does not implement the encoding itself. Protocols need to implement the type-specific encoding
 * they need in their contracts using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * _Available since v3.4._
 */
abstract contract EIP712 {
    /* solhint-disable var-name-mixedcase */
    // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to
    // invalidate the cached domain separator if the chain id changes.
    bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;
    uint256 private immutable _CACHED_CHAIN_ID;
    address private immutable _CACHED_THIS;

    bytes32 private immutable _HASHED_NAME;
    bytes32 private immutable _HASHED_VERSION;
    bytes32 private immutable _TYPE_HASH;

    /* solhint-enable var-name-mixedcase */

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     *
     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
     * contract upgrade].
     */
    constructor(string memory name, string memory version) {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        bytes32 typeHash = keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
        _CACHED_CHAIN_ID = block.chainid;
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion);
        _CACHED_THIS = address(this);
        _TYPE_HASH = typeHash;
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        if (address(this) == _CACHED_THIS && block.chainid == _CACHED_CHAIN_ID) {
            return _CACHED_DOMAIN_SEPARATOR;
        } else {
            return _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);
        }
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash,
        bytes32 versionHash
    ) private view returns (bytes32) {
        return keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, address(this)));
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1);

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10**64) {
                value /= 10**64;
                result += 64;
            }
            if (value >= 10**32) {
                value /= 10**32;
                result += 32;
            }
            if (value >= 10**16) {
                value /= 10**16;
                result += 16;
            }
            if (value >= 10**8) {
                value /= 10**8;
                result += 8;
            }
            if (value >= 10**4) {
                value /= 10**4;
                result += 4;
            }
            if (value >= 10**2) {
                value /= 10**2;
                result += 2;
            }
            if (value >= 10**1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10**result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result << 3) < value ? 1 : 0);
        }
    }
}
// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

/**
 * @author Sam King (samkingstudio.eth) for Fount Gallery
 * @title  Simple owner and admin authentication
 * @notice Allows the management of a contract by using simple ownership and admin modifiers.
 */
abstract contract Auth {
    /* ------------------------------------------------------------------------
                                   S T O R A G E
    ------------------------------------------------------------------------ */

    /// @notice Current owner of the contract
    address public owner;

    /// @notice Current admins of the contract
    mapping(address => bool) public admins;

    /* ------------------------------------------------------------------------
                                    E V E N T S
    ------------------------------------------------------------------------ */

    /**
     * @notice When the contract owner is updated
     * @param user The account that updated the new owner
     * @param newOwner The new owner of the contract
     */
    event OwnerUpdated(address indexed user, address indexed newOwner);

    /**
     * @notice When an admin is added to the contract
     * @param user The account that added the new admin
     * @param newAdmin The admin that was added
     */
    event AdminAdded(address indexed user, address indexed newAdmin);

    /**
     * @notice When an admin is removed from the contract
     * @param user The account that removed an admin
     * @param prevAdmin The admin that got removed
     */
    event AdminRemoved(address indexed user, address indexed prevAdmin);

    /* ------------------------------------------------------------------------
                                 M O D I F I E R S
    ------------------------------------------------------------------------ */

    /**
     * @dev Only the owner can call
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "UNAUTHORIZED");
        _;
    }

    /**
     * @dev Only an admin can call
     */
    modifier onlyAdmin() {
        require(admins[msg.sender], "UNAUTHORIZED");
        _;
    }

    /**
     * @dev Only the owner or an admin can call
     */
    modifier onlyOwnerOrAdmin() {
        require((msg.sender == owner || admins[msg.sender]), "UNAUTHORIZED");
        _;
    }

    /* ------------------------------------------------------------------------
                                      I N I T
    ------------------------------------------------------------------------ */

    /**
     * @dev Sets the initial owner and a first admin upon creation.
     * @param owner_ The initial owner of the contract
     * @param admin_ An initial admin of the contract
     */
    constructor(address owner_, address admin_) {
        owner = owner_;
        emit OwnerUpdated(address(0), owner_);

        admins[admin_] = true;
        emit AdminAdded(address(0), admin_);
    }

    /* ------------------------------------------------------------------------
                                     A D M I N
    ------------------------------------------------------------------------ */

    /**
     * @notice Transfers ownership of the contract to `newOwner`
     * @dev Can only be called by the current owner or an admin
     * @param newOwner The new owner of the contract
     */
    function setOwner(address newOwner) public virtual onlyOwnerOrAdmin {
        owner = newOwner;
        emit OwnerUpdated(msg.sender, newOwner);
    }

    /**
     * @notice Adds `newAdmin` as an amdin of the contract
     * @dev Can only be called by the current owner or an admin
     * @param newAdmin A new admin of the contract
     */
    function addAdmin(address newAdmin) public virtual onlyOwnerOrAdmin {
        admins[newAdmin] = true;
        emit AdminAdded(address(0), newAdmin);
    }

    /**
     * @notice Removes `prevAdmin` as an amdin of the contract
     * @dev Can only be called by the current owner or an admin
     * @param prevAdmin The admin to remove
     */
    function removeAdmin(address prevAdmin) public virtual onlyOwnerOrAdmin {
        admins[prevAdmin] = false;
        emit AdminRemoved(address(0), prevAdmin);
    }
}
// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "openzeppelin/token/ERC1155/IERC1155.sol";

/**
 * @author Sam King (samkingstudio.eth) for Fount Gallery
 * @title  Fount Gallery Card Check
 * @notice Utility functions to check ownership of a Fount Gallery Patron Card NFT
 */
contract FountCardCheck {
    /// @dev Address of the Fount Gallery Patron Card contract
    IERC1155 internal _fountCard;

    /// @dev Does not own a Fount Gallery Patron Card
    error NotFountCardHolder();

    /**
     * @dev Does not own enough Fount Gallery Patron Cards
     * @param required The minimum amount of cards that need to be owned
     * @param owned The actualy amount of cards owned
     */
    error DoesNotHoldEnoughFountCards(uint256 required, uint256 owned);

    /**
     * @dev Init with the Fount Gallery Patron Card contract address
     * @param fountCard The Fount Gallery Patron Card contract address
     */
    constructor(address fountCard) {
        _fountCard = IERC1155(fountCard);
    }

    /**
     * @dev Modifier that only allows the caller to do something if they hold
     * a Fount Gallery Patron Card
     */
    modifier onlyWhenFountCardHolder() {
        if (_getFountCardBalance(msg.sender) < 1) revert NotFountCardHolder();
        _;
    }

    /**
     * @dev Modifier that only allows the caller to do something if they hold
     * at least a specific amount Fount Gallery Patron Cards
     * @param minAmount The minimum amount of cards that need to be owned
     */
    modifier onlyWhenHoldingMinFountCards(uint256 minAmount) {
        uint256 balance = _getFountCardBalance(msg.sender);
        if (minAmount > balance) revert DoesNotHoldEnoughFountCards(minAmount, balance);
        _;
    }

    /**
     * @dev Get the number of Fount Gallery Patron Cards an address owns
     * @param owner The owner address to query
     * @return balance The balance of the owner
     */
    function _getFountCardBalance(address owner) internal view returns (uint256 balance) {
        balance = _fountCard.balanceOf(owner, 1);
    }

    /**
     * @dev Check if an address holds at least one Fount Gallery Patron Card
     * @param owner The owner address to query
     * @return isHolder If the owner holds at least one card
     */
    function _isFountCardHolder(address owner) internal view returns (bool isHolder) {
        isHolder = _getFountCardBalance(owner) > 0;
    }
}
// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

/**
 * @author Sam King (samkingstudio.eth) for Fount Gallery
 * @title  Swappable metadata module
 * @notice Allows the use of a separate and swappable metadata contract
 */
abstract contract SwappableMetadata {
    /* ------------------------------------------------------------------------
                                   S T O R A G E
    ------------------------------------------------------------------------ */

    /// @notice Address of metadata contract
    address public metadata;

    /// @notice Flag for whether the metadata address can be updated or not
    bool public isMetadataLocked;

    /* ------------------------------------------------------------------------
                                    E R R O R S
    ------------------------------------------------------------------------ */

    error MetadataLocked();

    /* ------------------------------------------------------------------------
                                    E V E N T S
    ------------------------------------------------------------------------ */

    /**
     * @dev When the metadata contract has been set
     * @param metadataContract The new metadata contract address
     */
    event MetadataContractSet(address indexed metadataContract);

    /**
     * @dev When the metadata contract has been locked and is no longer swappable
     * @param metadataContract The final locked metadata contract address
     */
    event MetadataContractLocked(address indexed metadataContract);

    /* ------------------------------------------------------------------------
                                      I N I T
    ------------------------------------------------------------------------ */

    /**
     * @param metadata_ The address of the initial metadata contract
     */
    constructor(address metadata_) {
        metadata = metadata_;
        emit MetadataContractSet(metadata_);
    }

    /* ------------------------------------------------------------------------
                                     A D M I N
    ------------------------------------------------------------------------ */

    /**
     * @notice Sets the metadata address
     * @param metadata_ The new address of the metadata contract
     */
    function _setMetadataAddress(address metadata_) internal {
        if (isMetadataLocked) revert MetadataLocked();
        metadata = metadata_;
        emit MetadataContractSet(metadata_);
    }

    /**
     * @notice Sets the metadata address
     * @param metadata The new address of the metadata contract
     */
    function setMetadataAddress(address metadata) public virtual;

    /**
     * @dev Locks the metadata address preventing further updates
     */
    function _lockMetadata() internal {
        isMetadataLocked = true;
        emit MetadataContractLocked(metadata);
    }
}
// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "openzeppelin/interfaces/IERC2981.sol";

/**
 * @author Sam King (samkingstudio.eth) for Fount Gallery
 * @title  Royalty payments
 * @notice Support for the royalty standard (ERC-2981)
 */
abstract contract Royalties is IERC2981 {
    /* ------------------------------------------------------------------------
                                   S T O R A G E
    ------------------------------------------------------------------------ */

    /// @dev Store information about token royalties
    struct RoyaltyInfo {
        address receiver;
        uint96 amount;
    }

    /// @dev The current royalty information
    RoyaltyInfo internal _royaltyInfo;

    /// @dev Interface id for the royalty information standard
    /// bytes4(keccak256("royaltyInfo(uint256,uint256)")) == 0x2a55205a
    bytes4 internal constant ROYALTY_INTERFACE_ID = 0x2a55205a;

    /* ------------------------------------------------------------------------
                                    E R R O R S
    ------------------------------------------------------------------------ */

    error MoreThanOneHundredPercentRoyalty();

    /* ------------------------------------------------------------------------
                                    E V E N T S
    ------------------------------------------------------------------------ */

    event RoyaltyInfoSet(address indexed receiver, uint256 indexed amount);
    event RoyaltyInfoUpdated(address indexed receiver, uint256 indexed amount);

    /* ------------------------------------------------------------------------
                                      I N I T
    ------------------------------------------------------------------------ */

    /**
     * @param royaltiesReceiver The receiver of royalty payments
     * @param royaltiesAmount The royalty percentage with two decimals (10,000 = 100%)
     */
    constructor(address royaltiesReceiver, uint256 royaltiesAmount) {
        _royaltyInfo = RoyaltyInfo(royaltiesReceiver, uint96(royaltiesAmount));
        emit RoyaltyInfoSet(royaltiesReceiver, royaltiesAmount);
    }

    /* ------------------------------------------------------------------------
                                  E R C 2 9 8 1
    ------------------------------------------------------------------------ */

    /// @notice EIP-2981 royalty standard for on-chain royalties
    function royaltyInfo(uint256, uint256 salePrice)
        public
        view
        virtual
        returns (address receiver, uint256 royaltyAmount)
    {
        receiver = _royaltyInfo.receiver;
        royaltyAmount = (salePrice * _royaltyInfo.amount) / 100_00;
    }

    /* ------------------------------------------------------------------------
                                     A D M I N
    ------------------------------------------------------------------------ */

    /**
     * @dev Internal function to set the royalty information
     * @param receiver The receiver of royalty payments
     * @param amount The royalty percentage with two decimals (10,000 = 100%)
     */
    function _setRoyaltyInfo(address receiver, uint256 amount) internal {
        if (amount > 100_00) revert MoreThanOneHundredPercentRoyalty();
        _royaltyInfo = RoyaltyInfo(receiver, uint24(amount));
        emit RoyaltyInfoUpdated(receiver, amount);
    }
}
// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "openzeppelin/token/ERC20/IERC20.sol";
import "openzeppelin/token/ERC721/IERC721.sol";
import "openzeppelin/token/ERC1155/IERC1155.sol";

/**
 * @author Sam King (samkingstudio.eth) for Fount Gallery
 * @title  Withdraw ETH and tokens module
 * @notice Allows the withdrawal of ETH, ERC20, ERC721, an ERC1155 tokens
 */
abstract contract Withdraw {
    /* ------------------------------------------------------------------------
                                    E R R O R S
    ------------------------------------------------------------------------ */

    error CannotWithdrawToZeroAddress();
    error WithdrawFailed();
    error BalanceTooLow();
    error ZeroBalance();

    /* ------------------------------------------------------------------------
                                  W I T H D R A W
    ------------------------------------------------------------------------ */

    function _withdrawETH(address to) internal {
        // Prevent withdrawing to the zero address
        if (to == address(0)) revert CannotWithdrawToZeroAddress();

        // Check there is eth to withdraw
        uint256 balance = address(this).balance;
        if (balance == 0) revert ZeroBalance();

        // Transfer funds
        (bool success, ) = payable(to).call{value: balance}("");
        if (!success) revert WithdrawFailed();
    }

    function _withdrawToken(address tokenAddress, address to) internal {
        // Prevent withdrawing to the zero address
        if (to == address(0)) revert CannotWithdrawToZeroAddress();

        // Check there are tokens to withdraw
        uint256 balance = IERC20(tokenAddress).balanceOf(address(this));
        if (balance == 0) revert ZeroBalance();

        // Transfer tokens
        bool success = IERC20(tokenAddress).transfer(to, balance);
        if (!success) revert WithdrawFailed();
    }

    function _withdrawERC721Token(
        address tokenAddress,
        uint256 id,
        address to
    ) internal {
        // Prevent withdrawing to the zero address
        if (to == address(0)) revert CannotWithdrawToZeroAddress();

        // Check the NFT is in this contract
        address owner = IERC721(tokenAddress).ownerOf(id);
        if (owner != address(this)) revert ZeroBalance();

        // Transfer NFT
        IERC721(tokenAddress).transferFrom(address(this), to, id);
    }

    function _withdrawERC1155Token(
        address tokenAddress,
        uint256 id,
        uint256 amount,
        address to
    ) internal {
        // Prevent withdrawing to the zero address
        if (to == address(0)) revert CannotWithdrawToZeroAddress();

        // Check the tokens are owned by this contract, and there's at least `amount`
        uint256 balance = IERC1155(tokenAddress).balanceOf(address(this), id);
        if (balance == 0) revert ZeroBalance();
        if (amount > balance) revert BalanceTooLow();

        // Transfer tokens
        IERC1155(tokenAddress).safeTransferFrom(address(this), to, id, amount, "");
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Minimalist and gas efficient standard ERC1155 implementation.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC1155.sol)
abstract contract ERC1155 {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event TransferSingle(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 amount
    );

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] amounts
    );

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    /*//////////////////////////////////////////////////////////////
                             ERC1155 STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(address => mapping(uint256 => uint256)) public balanceOf;

    mapping(address => mapping(address => bool)) public isApprovedForAll;

    /*//////////////////////////////////////////////////////////////
                             METADATA LOGIC
    //////////////////////////////////////////////////////////////*/

    function uri(uint256 id) public view virtual returns (string memory);

    /*//////////////////////////////////////////////////////////////
                              ERC1155 LOGIC
    //////////////////////////////////////////////////////////////*/

    function setApprovalForAll(address operator, bool approved) public virtual {
        isApprovedForAll[msg.sender][operator] = approved;

        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) public virtual {
        require(msg.sender == from || isApprovedForAll[from][msg.sender], "NOT_AUTHORIZED");

        balanceOf[from][id] -= amount;
        balanceOf[to][id] += amount;

        emit TransferSingle(msg.sender, from, to, id, amount);

        require(
            to.code.length == 0
                ? to != address(0)
                : ERC1155TokenReceiver(to).onERC1155Received(msg.sender, from, id, amount, data) ==
                    ERC1155TokenReceiver.onERC1155Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) public virtual {
        require(ids.length == amounts.length, "LENGTH_MISMATCH");

        require(msg.sender == from || isApprovedForAll[from][msg.sender], "NOT_AUTHORIZED");

        // Storing these outside the loop saves ~15 gas per iteration.
        uint256 id;
        uint256 amount;

        for (uint256 i = 0; i < ids.length; ) {
            id = ids[i];
            amount = amounts[i];

            balanceOf[from][id] -= amount;
            balanceOf[to][id] += amount;

            // An array can't have a total length
            // larger than the max uint256 value.
            unchecked {
                ++i;
            }
        }

        emit TransferBatch(msg.sender, from, to, ids, amounts);

        require(
            to.code.length == 0
                ? to != address(0)
                : ERC1155TokenReceiver(to).onERC1155BatchReceived(msg.sender, from, ids, amounts, data) ==
                    ERC1155TokenReceiver.onERC1155BatchReceived.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function balanceOfBatch(address[] calldata owners, uint256[] calldata ids)
        public
        view
        virtual
        returns (uint256[] memory balances)
    {
        require(owners.length == ids.length, "LENGTH_MISMATCH");

        balances = new uint256[](owners.length);

        // Unchecked because the only math done is incrementing
        // the array index counter which cannot possibly overflow.
        unchecked {
            for (uint256 i = 0; i < owners.length; ++i) {
                balances[i] = balanceOf[owners[i]][ids[i]];
            }
        }
    }

    /*//////////////////////////////////////////////////////////////
                              ERC165 LOGIC
    //////////////////////////////////////////////////////////////*/

    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return
            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
            interfaceId == 0xd9b67a26 || // ERC165 Interface ID for ERC1155
            interfaceId == 0x0e89341c; // ERC165 Interface ID for ERC1155MetadataURI
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        balanceOf[to][id] += amount;

        emit TransferSingle(msg.sender, address(0), to, id, amount);

        require(
            to.code.length == 0
                ? to != address(0)
                : ERC1155TokenReceiver(to).onERC1155Received(msg.sender, address(0), id, amount, data) ==
                    ERC1155TokenReceiver.onERC1155Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function _batchMint(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        uint256 idsLength = ids.length; // Saves MLOADs.

        require(idsLength == amounts.length, "LENGTH_MISMATCH");

        for (uint256 i = 0; i < idsLength; ) {
            balanceOf[to][ids[i]] += amounts[i];

            // An array can't have a total length
            // larger than the max uint256 value.
            unchecked {
                ++i;
            }
        }

        emit TransferBatch(msg.sender, address(0), to, ids, amounts);

        require(
            to.code.length == 0
                ? to != address(0)
                : ERC1155TokenReceiver(to).onERC1155BatchReceived(msg.sender, address(0), ids, amounts, data) ==
                    ERC1155TokenReceiver.onERC1155BatchReceived.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function _batchBurn(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {
        uint256 idsLength = ids.length; // Saves MLOADs.

        require(idsLength == amounts.length, "LENGTH_MISMATCH");

        for (uint256 i = 0; i < idsLength; ) {
            balanceOf[from][ids[i]] -= amounts[i];

            // An array can't have a total length
            // larger than the max uint256 value.
            unchecked {
                ++i;
            }
        }

        emit TransferBatch(msg.sender, from, address(0), ids, amounts);
    }

    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal virtual {
        balanceOf[from][id] -= amount;

        emit TransferSingle(msg.sender, from, address(0), id, amount);
    }
}

/// @notice A generic interface for a contract which properly accepts ERC1155 tokens.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC1155.sol)
abstract contract ERC1155TokenReceiver {
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external virtual returns (bytes4) {
        return ERC1155TokenReceiver.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) external virtual returns (bytes4) {
        return ERC1155TokenReceiver.onERC1155BatchReceived.selector;
    }
}
// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "solmate/tokens/ERC1155.sol";
import "fount-contracts/auth/Auth.sol";
import "fount-contracts/community/FountCardCheck.sol";
import "fount-contracts/extensions/SwappableMetadata.sol";
import "fount-contracts/utils/Royalties.sol";
import "fount-contracts/utils/Withdraw.sol";
import "closedsea/OperatorFilterer.sol";
import "openzeppelin/utils/cryptography/ECDSA.sol";
import "openzeppelin/utils/cryptography/EIP712.sol";
import "openzeppelin/token/ERC20/IERC20.sol";
import "./interfaces/IMetadata.sol";
import "./interfaces/IMorningsPayments.sol";
import "./interfaces/IWETH.sol";

/**
 * @author Fount Gallery
 * @title  ERC1155Base
 * @notice Base contract for Mornings Open Editions to inherit from
 *
 * Features:
 *   - EIP-712 signature minting and verification
 *   - On-chain checking of Fount Gallery Patron cards for minting
 *   - Swappable metadata contract
 *   - On-chain royalties standard (EIP-2981)
 *   - Support for OpenSea's Operator Filterer to allow royalties
 */
abstract contract ERC1155Base is
    ERC1155,
    Auth,
    FountCardCheck,
    SwappableMetadata,
    Royalties,
    Withdraw,
    EIP712,
    OperatorFilterer
{
    /* ------------------------------------------------------------------------
       S T O R A G E
    ------------------------------------------------------------------------ */

    /// @notice Gutty Kreum
    address public artist = 0x95D89b7069D3e401EfE987a94e4cC4C64Af746Fb;

    /// @notice Contract information
    string public contractURI;

    /// @notice Contract name
    string public name = "Mornings";

    /// @notice Contract symbol
    string public symbol = "GKAM";

    /// @notice EIP-712 signing domain
    string public constant SIGNING_DOMAIN = "MorningsOpenEditions";

    /// @notice EIP-712 signature version
    string public constant SIGNATURE_VERSION = "1";

    /// @notice EIP-712 signed data type hash for minting with an off-chain signature
    bytes32 public constant MINT_SIGNATURE_TYPEHASH =
        keccak256(
            "MintSignatureData(uint256 id,uint256 amount_guttys,uint256 amount_founts,address to,uint256 nonce)"
        );

    /// @dev EIP-712 signed data struct for minting with an off-chain signature
    struct MintSignatureData {
        uint256 id;
        uint256 amount_guttys;
        uint256 amount_founts;
        address to;
        uint256 nonce;
        bytes signature;
    }

    /// @notice Approved signer public addresses
    mapping(address => bool) public approvedSigners;

    /// @notice Nonce management to avoid signature replay attacks
    mapping(address => uint256) public nonces;

    /// @notice If operator filtering is applied
    bool public operatorFilteringEnabled;

    /// @notice Wrapped ETH contract address for safe ETH transfer fallbacks
    address public weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    /// @notice Address where proceeds should be sent
    address public payments;

    /* ------------------------------------------------------------------------
       E R R O R S
    ------------------------------------------------------------------------ */

    error CannotSetPaymentAddressToZero();

    /* ------------------------------------------------------------------------
       E V E N T S
    ------------------------------------------------------------------------ */

    event Init();

    /* ------------------------------------------------------------------------
       I N I T
    ------------------------------------------------------------------------ */

    /**
     * @param owner_ The owner of the contract
     * @param admin_ The admin of the contract
     * @param payments_ The admin of the contract
     * @param royaltiesAmount_ The royalty percentage with two decimals (10,000 = 100%)
     * @param metadata_ The initial metadata contract address
     * @param fountCard_ The address of the Fount Gallery Patron Card
     */
    constructor(
        address owner_,
        address admin_,
        address payments_,
        uint256 royaltiesAmount_,
        address metadata_,
        address fountCard_
    )
        ERC1155()
        Auth(owner_, admin_)
        FountCardCheck(fountCard_)
        SwappableMetadata(metadata_)
        Royalties(payments_, royaltiesAmount_)
        EIP712(SIGNING_DOMAIN, SIGNATURE_VERSION)
    {
        payments = payments_;
        _registerForOperatorFiltering();
        operatorFilteringEnabled = true;
        emit Init();
    }

    /* ------------------------------------------------------------------------
       A R T I S T   M I N T I N G
    ------------------------------------------------------------------------ */

    function _mintToArtistFirst(address to, uint256 id, uint256 amount) internal {
        balanceOf[to][id] += amount;

        emit TransferSingle(msg.sender, address(0), artist, id, amount);
        emit TransferSingle(msg.sender, artist, to, id, amount);

        require(
            to.code.length == 0
                ? to != address(0)
                : ERC1155TokenReceiver(to).onERC1155Received(msg.sender, artist, id, amount, "") ==
                    ERC1155TokenReceiver.onERC1155Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    /* ------------------------------------------------------------------------
       S I G N A T U R E   V E R I F I C A T I O N
    ------------------------------------------------------------------------ */

    /**
     * @notice Internal function to verify an EIP-712 minting signature
     * @param id The token id
     * @param to The account that has approval to mint
     * @param signature The EIP-712 signature
     * @return bool If the signature is verified or not
     */
    function _verifyMintSignature(
        uint256 id,
        uint256 amount_guttys,
        uint256 amount_founts,
        address to,
        bytes calldata signature
    ) internal returns (bool) {
        MintSignatureData memory data = MintSignatureData({
            id: id,
            amount_guttys: amount_guttys,
            amount_founts: amount_founts,
            to: to,
            nonce: nonces[to],
            signature: signature
        });

        // Hash the data for verification
        bytes32 digest = _hashTypedDataV4(
            keccak256(
                abi.encode(
                    MINT_SIGNATURE_TYPEHASH,
                    data.id,
                    data.amount_guttys,
                    data.amount_founts,
                    data.to,
                    nonces[data.to]++
                )
            )
        );

        // Verifiy signature is ok
        address addr = ECDSA.recover(digest, data.signature);
        return approvedSigners[addr] && addr != address(0);
    }

    /* ------------------------------------------------------------------------
       A D M I N
    ------------------------------------------------------------------------ */

    /** SIGNERS ------------------------------------------------------------ */

    /**
     * @notice Admin function to set an EIP-712 signer address
     * @param signer The address of the new signer
     * @param approved If the signer is approved
     */
    function setSigner(address signer, bool approved) external onlyOwnerOrAdmin {
        approvedSigners[signer] = approved;
    }

    /** METADATA ----------------------------------------------------------- */

    /**
     * @notice Admin function to set the metadata contract address
     * @param metadata The new metadata contract address
     */
    function setMetadataAddress(address metadata) public override onlyOwnerOrAdmin {
        _setMetadataAddress(metadata);
    }

    /**
     * @notice Admin function to set the contract URI for marketplaces
     * @param contractURI_ The new contract URI
     */
    function setContractURI(string memory contractURI_) external onlyOwnerOrAdmin {
        contractURI = contractURI_;
    }

    /** ROYALTIES ---------------------------------------------------------- */

    /**
     * @notice Admin function to set the royalty information
     * @param receiver The receiver of royalty payments
     * @param amount The royalty percentage with two decimals (10,000 = 100%)
     */
    function setRoyaltyInfo(address receiver, uint256 amount) external onlyOwnerOrAdmin {
        _setRoyaltyInfo(receiver, amount);
    }

    /**
     * @notice Admin function to set whether OpenSea's Operator Filtering should be enabled
     * @param enabled If the operator filtering should be enabled
     */
    function setOperatorFilteringEnabled(bool enabled) external onlyOwnerOrAdmin {
        operatorFilteringEnabled = enabled;
    }

    function registerForOperatorFiltering(
        address subscriptionOrRegistrantToCopy,
        bool subscribe
    ) external onlyOwnerOrAdmin {
        _registerForOperatorFiltering(subscriptionOrRegistrantToCopy, subscribe);
    }

    /** PAYMENTS ----------------------------------------------------------- */

    /**
     * @notice Admin function to set the payment address for withdrawing funds
     * @param paymentAddress The new address where payments should be sent upon withdrawal
     */
    function setPaymentAddress(address paymentAddress) external onlyOwnerOrAdmin {
        if (paymentAddress == address(0)) revert CannotSetPaymentAddressToZero();
        payments = paymentAddress;
    }

    /* ------------------------------------------------------------------------
       R O T A L T I E S
    ------------------------------------------------------------------------ */

    /**
     * @notice Add interface for on-chain royalty standard
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC1155, IERC165) returns (bool) {
        return interfaceId == ROYALTY_INTERFACE_ID || super.supportsInterface(interfaceId);
    }

    /**
     * @notice Repeats the OpenSea Operator Filtering registration
     */
    function repeatRegistration() public {
        _registerForOperatorFiltering();
    }

    /**
     * @notice Override ERC-1155 `setApprovalForAll` to support OpenSea Operator Filtering
     */
    function setApprovalForAll(
        address operator,
        bool approved
    ) public override onlyAllowedOperatorApproval(operator) {
        super.setApprovalForAll(operator, approved);
    }

    /**
     * @notice Override ERC-1155 `safeTransferFrom` to support OpenSea Operator Filtering
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) public override onlyAllowedOperator(from) {
        super.safeTransferFrom(from, to, id, amount, data);
    }

    /**
     * @notice Override ERC-1155 `safeTransferFrom` to support OpenSea Operator Filtering
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) public virtual override onlyAllowedOperator(from) {
        super.safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    /**
     * @dev Overrde `OperatorFilterer._operatorFilteringEnabled` to return whether
     * the operator filtering is enabled in this contract.
     */
    function _operatorFilteringEnabled() internal view virtual override returns (bool) {
        return operatorFilteringEnabled;
    }

    /* ------------------------------------------------------------------------
       S A F E   T R A N S F E R S
    ------------------------------------------------------------------------ */

    /**
     * @notice Safely transfer ETH by wrapping as WETH if the ETH transfer fails
     * @param to The address to transfer ETH/WETH to
     * @param amount The amount of ETH/WETH to transfer
     */
    function _transferETHWithFallback(address to, uint256 amount) internal {
        if (!_transferETH(to, amount)) {
            IWETH(weth).deposit{value: amount}();
            IERC20(weth).transfer(to, amount);
        }
    }

    /**
     * @notice Transfer ETH and return the success status.
     * @param to The address to transfer ETH to
     * @param amount The amount of ETH to transfer
     */
    function _transferETH(address to, uint256 amount) internal returns (bool) {
        (bool success, ) = payable(to).call{value: amount}(new bytes(0));
        return success;
    }

    /* ------------------------------------------------------------------------
       E R C 1 1 5 5
    ------------------------------------------------------------------------ */

    /**
     * @notice Returns the token metadata
     * @return id The token id to get metadata for
     */
    function uri(uint256 id) public view override returns (string memory) {
        return IMetadata(metadata).tokenURI(id);
    }

    /**
     * @notice Burn a token. You can only burn tokens you own.
     * @param id The token id to burn
     * @param amount The amount to burn
     */
    function burn(uint256 id, uint256 amount) external {
        require(balanceOf[msg.sender][id] >= amount, "CANNOT_BURN");
        _burn(msg.sender, id, amount);
    }

    /* ------------------------------------------------------------------------
       W I T H D R A W
    ------------------------------------------------------------------------ */

    /**
     * @notice Admin function to withdraw ETH from this contract
     * @dev Withdraws to the `payments` address.
     *
     * Reverts if:
     *  - there are active auctions
     *  - the payments address is set to zero
     *
     */
    function withdrawETH() public onlyOwnerOrAdmin {
        // Send the eth to the payments address
        _withdrawETH(payments);
    }

    /**
     * @notice Admin function to withdraw ETH from this contract and release from payments contract
     * @dev Withdraws to the `payments` address, then calls `releaseAllETH` as a splitter.
     *
     * Reverts if:
     *  - there are active auctions
     *  - the payments address is set to zero
     *
     */
    function withdrawAndReleaseAllETH() public onlyOwnerOrAdmin {
        // Send the eth to the payments address
        _withdrawETH(payments);
        // And then release all the ETH to the payees
        IMorningsPayments(payments).releaseAllETH();
    }

    /**
     * @notice Admin function to withdraw ERC-20 tokens from this contract
     * @dev Withdraws to the `payments` address.
     *
     * Reverts if:
     *  - the payments address is set to zero
     *
     */
    function withdrawTokens(address tokenAddress) public onlyOwnerOrAdmin {
        // Send the tokens to the payments address
        _withdrawToken(tokenAddress, payments);
    }

    /**
     * @notice Admin function to withdraw ERC-20 tokens from this contract
     * @param to The address to send the ERC-20 tokens to
     */
    function withdrawTokens(address tokenAddress, address to) public onlyOwnerOrAdmin {
        _withdrawToken(tokenAddress, to);
    }
}
// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "./ERC1155Base.sol";

/**
 * @author Fount Gallery
 * @title  Mornings Open Editions by Gutty Kreum
 * @notice Mornings is a collection of digital memories exploring morning ambience by pixel artist, Gutty Kreum.
 *         A limited release in collaboration with Fount Gallery, Mornings drops on June 22, 2023.
 *
 * Features:
 *   - Open edition NFTs
 *   - ERC-1155 lazy minting
 *   - Flexible minting conditions with EIP-712 signatures or on-chain Fount Card checks
 *   - Swappable metadata contract
 *   - On-chain royalties standard (EIP-2981)
 *   - Support for OpenSea's Operator Filterer to allow royalties
 */
contract MorningsOpenEditions is ERC1155Base {
    /* ------------------------------------------------------------------------
       S T O R A G E
    ------------------------------------------------------------------------ */

    /// @dev Stores information about a given token
    struct TokenData {
        uint128 price;
        uint32 startTime;
        uint32 endTime;
        uint256 gutty_reserve_collected;
        uint256 fount_reserve_collected;
        uint16 perAddressAllowance;
        bool fountExclusive;
        bool requiresSig;
    }

    /// @dev Mapping of token id to token data
    mapping(uint256 => TokenData) internal _idToTokenData;

    /// @dev Check if the artist has minted the batch of 25 prior to launch
    bool public _artistBatchMinted = false;

    /// @notice The amount of tokens reserved for Fount Gallery Patrons
    uint256 public constant FOUNT_PATRON_RESERVE = 100;

    /// @notice The amount of tokens reserved for Gutty Kreum artwork holders
    uint256 public constant GUTTY_KREUM_RESERVE = 225;

    /* ------------------------------------------------------------------------
       M O D I F I E R S
    ------------------------------------------------------------------------ */

    /**
     * @dev Reverts if the caller is not the artist
     */
    modifier onlyArtist() {
        require(msg.sender == artist, "Only the artist can call this function");
        _;
    }

    /* ------------------------------------------------------------------------
       E R R O R S
    ------------------------------------------------------------------------ */

    /** TOKEN DATA ---------------------------------------------------------- */
    error TokenDataDoesNotExist();
    error TokenDataAlreadyExists();
    error CannotSetStartTimeToZero();
    error CannotSetEndTimeToThePast();

    /** SALE CONDITIONS ---------------------------------------------------- */
    error RequiresFountCard();
    error RequiresSignature();
    error InvalidSignature();
    error SoldOut();
    error BatchAlreadyMinted();

    /** PURCHASING --------------------------------------------------------- */
    error NotForSale();
    error IncorrectPaymentAmount();
    error AmountExceedsMaxWalletMint();
    error AmountExceedsWalletAllowance();

    /** EDITIONS ----------------------------------------------------------- */
    error OpenEditionEnded();
    error OpenEditionNotStartedYet();

    /* ------------------------------------------------------------------------
       E V E N T S
    ------------------------------------------------------------------------ */

    event TokenDataAdded(uint256 indexed id, TokenData tokenData);
    event TokenDataSaleTimesUpdated(uint256 indexed id, TokenData tokenData);
    event TokenDataSalePriceUpdated(uint256 indexed id, TokenData tokenData);
    event TokenDataSaleConditionsUpdated(uint256 indexed id, TokenData tokenData);

    event CollectedOpenEdition(uint256 indexed id);

    /* ------------------------------------------------------------------------
       I N I T
    ------------------------------------------------------------------------ */

    /**
     * @param owner_ The owner of the contract
     * @param admin_ The admin of the contract
     * @param payments_ The address where payments should be sent
     * @param royaltiesAmount_ The royalty percentage with two decimals (10,000 = 100%)
     * @param metadata_ The initial metadata contract address
     * @param fountCard_ The address of the Fount Gallery Patron Card
     */
    constructor(
        address owner_,
        address admin_,
        address payments_,
        uint256 royaltiesAmount_,
        address metadata_,
        address fountCard_
    ) ERC1155Base(owner_, admin_, payments_, royaltiesAmount_, metadata_, fountCard_) {}

    /* ------------------------------------------------------------------------
       O P E N   E D I T I O N S
    ------------------------------------------------------------------------ */

    /**
     * @notice Mints a batch of 25 editions to the artist's wallet
     *
     * Reverts if:
     * - the batch has already been minted
     */
    function mintArtistBatch() external onlyArtist {
        if (_artistBatchMinted) revert BatchAlreadyMinted();

        TokenData memory tokenData = _idToTokenData[3];
        tokenData.gutty_reserve_collected += 25;
        _idToTokenData[3] = tokenData;

        _artistBatchMinted = true;
        _mintToArtistFirst(artist, 3, 25);
        emit CollectedOpenEdition(3);
    }

    /**
     * @notice Mints a number of editions from an open edition NFT
     * @dev Calls internal `_collectEdition` for logic.
     *
     * Reverts if:
     *  - the edition requires an off-chain signature
     *  - see `_collectEdition` for other conditions
     *
     * @param id The id of the edition
     * @param amount_guttys The amount of editions to mint from the Gutty Kreum reserve
     * @param amount_founts The amount of editions to mint from the Fount Gallery Patron Card reserve
     * @param to The address to mint the token to
     */
    function collectEdition(
        uint256 id,
        uint256 amount_guttys,
        uint256 amount_founts,
        address to
    ) external payable {
        TokenData memory tokenData = _idToTokenData[id];
        if (tokenData.requiresSig) revert RequiresSignature();
        _collectEdition(id, amount_guttys, amount_founts, to, tokenData);
    }

    /**
     * @notice Mints a number of editions from an open edition NFT with an off-chain signature
     * @dev Calls internal `_collectEdition` for logic.
     *
     * Reverts if:
     *  - the edition requires an off-chain signature and the signature is invalid
     *  - see `_collectEdition` for other conditions
     *
     * @param id The id of the edition
     * @param amount_guttys The amount of editions to mint from the Gutty Kreum reserve
     * @param amount_founts The amount of editions to mint from the Fount Gallery Patron Card reserve
     * @param to The address to mint the token to
     * @param signature The off-chain signature which permits a mint
     */
    function collectEdition(
        uint256 id,
        uint256 amount_guttys,
        uint256 amount_founts,
        address to,
        bytes calldata signature
    ) external payable {
        TokenData memory tokenData = _idToTokenData[id];
        if (
            tokenData.requiresSig &&
            !_verifyMintSignature(id, amount_guttys, amount_founts, to, signature)
        ) {
            revert InvalidSignature();
        }
        _collectEdition(id, amount_guttys, amount_founts, to, tokenData);
    }

    /**
     * @notice Internal function to mint some editions with some conditions
     * @dev Allows minting to a different address from msg.sender.
     *
     * Reverts if:
     *  - the edition has not started
     *  - the edition has ended
     *  - msg.value does not equal the required amount
     *  - the edition requires a Fount Card, but `to` does not hold one
     *
     * @param id The token id of the edition
     * @param amount_guttys The amount of editions to mint from the Gutty Kreum reserve
     * @param amount_founts The amount of editions to mint from the Fount Gallery Patron Card reserve
     * @param to The address to mint the token to
     * @param tokenData Information about the token
     */
    function _collectEdition(
        uint256 id,
        uint256 amount_guttys,
        uint256 amount_founts,
        address to,
        TokenData memory tokenData
    ) internal {
        uint256 trueGuttysToMintAmount;
        uint256 trueFountsToMintAmount;

        // Check to see if the edition is mintable and the price is correct
        if (tokenData.startTime > block.timestamp) revert OpenEditionNotStartedYet();
        if (tokenData.endTime > 0 && block.timestamp > tokenData.endTime) revert OpenEditionEnded();
        if (msg.value > 0) revert IncorrectPaymentAmount();

        // Check if it's a Fount Gallery exclusive
        if (tokenData.fountExclusive && !_isFountCardHolder(to)) revert RequiresFountCard();

        // Check to see if the mint amounts exceed the reserves
        if (
            GUTTY_KREUM_RESERVE <= tokenData.gutty_reserve_collected &&
            FOUNT_PATRON_RESERVE <= tokenData.fount_reserve_collected
        ) revert SoldOut();

        // If the amount of tokens to mint will exceed the Fount Patron Reserve, only mint the remaining amount
        // eg. 98/100 tokens minted, 5 tokens requested, only 2 tokens will be minted
        if (amount_founts > FOUNT_PATRON_RESERVE - tokenData.fount_reserve_collected) {
            trueFountsToMintAmount = FOUNT_PATRON_RESERVE - tokenData.fount_reserve_collected;
        } else {
            trueFountsToMintAmount = amount_founts;
        }

        // If the amount of tokens to mint will exceed the Gutty Kreum artwork holder Reserve, only mint the remaining amount
        // eg. 223/225 tokens minted, 5 tokens requested, only 2 tokens will be minted
        if (amount_guttys > GUTTY_KREUM_RESERVE - tokenData.gutty_reserve_collected) {
            trueGuttysToMintAmount = GUTTY_KREUM_RESERVE - tokenData.gutty_reserve_collected;
        } else {
            trueGuttysToMintAmount = amount_guttys;
        }

        // Add the new mint to the token data
        unchecked {
            tokenData.gutty_reserve_collected += trueGuttysToMintAmount;
            tokenData.fount_reserve_collected += trueFountsToMintAmount;
        }
        _idToTokenData[id] = tokenData;

        // Calculate the total amount of tokens to mint
        uint256 mintAmount = uint256(trueGuttysToMintAmount) + uint256(trueFountsToMintAmount);

        // Mint the NFT to the `to` address
        _mintToArtistFirst(to, id, mintAmount);
        emit CollectedOpenEdition(id);
    }

    /* ------------------------------------------------------------------------
       A D M I N
    ------------------------------------------------------------------------ */

    /** ADD TOKEN DATA ----------------------------------------------------- */

    /**
     * @notice Admin function to make a token available for sale
     * @dev As soon as the token data is registered, the NFT will be available to collect.
     *
     * Reverts if:
     *  - `startTime` is zero (used to check if a token can be sold or not)
     *  - `endTime` is in the past
     *  - the token data already exists (to update token data, use the other admin
     *    functions to set price and sale conditions)
     *
     * @param id The token id
     * @param price The sale price, if any
     * @param startTime The start time of the sale
     * @param endTime The end time of the sale, if any
     * @param mintPerAddress The max amount that can be minted for a wallet, if any
     * @param fountExclusive If the sale requires a Fount Gallery Patron card
     * @param requiresSig If the sale requires an off-chain signature
     */
    function addTokenForSale(
        uint256 id,
        uint128 price,
        uint32 startTime,
        uint32 endTime,
        uint16 mintPerAddress,
        bool fountExclusive,
        bool requiresSig
    ) external onlyOwnerOrAdmin {
        // Check that start time is valid. This value is used to check if the token data
        // exists. Setting to zero will effectively "delete" the token data for other functions.
        if (startTime == 0) revert CannotSetStartTimeToZero();

        // Check the end time is not in the past
        if (endTime > 0 && block.timestamp > endTime) revert CannotSetEndTimeToThePast();

        TokenData memory tokenData = _idToTokenData[id];

        // Check the token data is empty before adding
        if (tokenData.startTime != 0) revert TokenDataAlreadyExists();

        // Set the new token data
        tokenData.price = price;
        tokenData.startTime = startTime;
        tokenData.endTime = endTime;
        tokenData.perAddressAllowance = mintPerAddress;
        tokenData.fountExclusive = fountExclusive;
        tokenData.requiresSig = requiresSig;
        _idToTokenData[id] = tokenData;
        emit TokenDataAdded(id, tokenData);
    }

    /** SET SALE PRICE ----------------------------------------------------- */

    /**
     * @notice Admin function to update the sale price for a token
     * @dev Sets the start and end time values for a token. Setting `endTime` to zero
     * effectively keeps the edition open forever.
     *
     * Reverts if:
     *  - `startTime` is zero (used to check if a token can be sold or not)
     *  - `endTime` is in the past
     *  - the token data does not exist, must be added with `addTokenForSale` first
     *
     * @param id The token id
     * @param startTime The new start time of the sale
     * @param endTime The new end time of the sale
     */
    function setTokenSaleTimes(
        uint256 id,
        uint32 startTime,
        uint32 endTime
    ) external onlyOwnerOrAdmin {
        // Check that start time is not zero. This value is used to check if the token data
        // exists. Setting to zero will effectively "delete" the token data for other functions.
        if (startTime == 0) revert CannotSetStartTimeToZero();

        // Check the end time is not in the past
        if (endTime > 0 && block.timestamp > endTime) revert CannotSetEndTimeToThePast();

        TokenData memory tokenData = _idToTokenData[id];

        // Check the token data already exists.
        // If not, it should be created with `addTokenForSale` first.
        if (tokenData.startTime == 0) revert TokenDataDoesNotExist();

        // Set the new sale price
        tokenData.startTime = startTime;
        tokenData.endTime = endTime;
        _idToTokenData[id] = tokenData;
        emit TokenDataSaleTimesUpdated(id, tokenData);
    }

    /** SET SALE TIMES ----------------------------------------------------- */

    /**
     * @notice Admin function to update the sale price for a token
     * @dev Reverts if the token data does not exist. Must be added with `addTokenForSale` first.
     * @param id The token id
     * @param price The new sale price
     */
    function setTokenSalePrice(uint256 id, uint128 price) external onlyOwnerOrAdmin {
        TokenData memory tokenData = _idToTokenData[id];

        // Check the token data already exists.
        // If not, it should be created with `addTokenForSale` first.
        if (tokenData.startTime == 0) revert TokenDataDoesNotExist();

        // Set the new sale price
        tokenData.price = price;
        _idToTokenData[id] = tokenData;
        emit TokenDataSalePriceUpdated(id, tokenData);
    }

    /** SET SALE CONDITIONS ------------------------------------------------ */

    /**
     * @notice Admin function to update the sale conditions for a token
     * @dev Reverts if the token data does not exist. Must be added with `addTokenForSale` first.
     * @param id The token id
     * @param mintPerAddress The max amount that can be minted for a wallet, if any
     * @param fountExclusive If the sale requires a Fount Gallery Patron card
     * @param requiresSig If the sale requires an off-chain signature
     */
    function setTokenSaleConditions(
        uint256 id,
        uint16 mintPerAddress,
        bool fountExclusive,
        bool requiresSig
    ) external onlyOwnerOrAdmin {
        TokenData memory tokenData = _idToTokenData[id];

        // Check the token data already exists.
        // If not, it should be created with `addTokenForSale` first.
        if (tokenData.startTime == 0) revert TokenDataDoesNotExist();

        tokenData.perAddressAllowance = mintPerAddress;
        tokenData.fountExclusive = fountExclusive;
        tokenData.requiresSig = requiresSig;
        _idToTokenData[id] = tokenData;

        emit TokenDataSaleConditionsUpdated(id, tokenData);
    }

    /* ------------------------------------------------------------------------
                                   G E T T E R S
    ------------------------------------------------------------------------ */

    function tokenPrice(uint256 id) external view returns (uint256) {
        return _idToTokenData[id].price;
    }

    function tokenStartTime(uint256 id) external view returns (uint256) {
        return _idToTokenData[id].startTime;
    }

    function tokenEndTime(uint256 id) external view returns (uint256) {
        return _idToTokenData[id].endTime;
    }

    function tokenGuttyReserveCollectedCount(uint256 id) external view returns (uint256) {
        return _idToTokenData[id].gutty_reserve_collected;
    }

    function tokenFountReserveCollectedCount(uint256 id) external view returns (uint256) {
        return _idToTokenData[id].fount_reserve_collected;
    }

    function tokenAllowancePerAddress(uint256 id) external view returns (uint256) {
        return _idToTokenData[id].perAddressAllowance;
    }

    function tokenRemainingAllowanceForAddress(
        uint256 id,
        address account
    ) external view returns (uint256) {
        TokenData memory tokenData = _idToTokenData[id];
        uint256 currentBalance = balanceOf[account][id];
        uint256 remainingAllowance = currentBalance > tokenData.perAddressAllowance
            ? 0
            : tokenData.perAddressAllowance - currentBalance;
        return remainingAllowance;
    }

    function tokenIsFountExclusive(uint256 id) external view returns (bool) {
        return _idToTokenData[id].fountExclusive;
    }

    function tokenRequiresOffChainSignatureToMint(uint256 id) external view returns (bool) {
        return _idToTokenData[id].requiresSig;
    }
}
// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

interface IMetadata {
    function tokenURI(uint256 id) external view returns (string memory);
}
// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

interface IMorningsPayments {
    function releaseAllETH() external;

    function releaseAllToken(address tokenAddress) external;
}
// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

interface IWETH {
    function deposit() external payable;

    function withdraw(uint256 wad) external;

    function transfer(address to, uint256 value) external returns (bool);
}