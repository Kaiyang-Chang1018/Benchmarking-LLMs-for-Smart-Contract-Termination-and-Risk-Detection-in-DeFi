// SPDX-License-Identifier: CC0-1.0
pragma solidity >=0.8.13;

/**
 * @title IDelegateRegistry
 * @custom:version 2.0
 * @custom:author foobar (0xfoobar)
 * @notice A standalone immutable registry storing delegated permissions from one address to another
 */
interface IDelegateRegistry {
    /// @notice Delegation type, NONE is used when a delegation does not exist or is revoked
    enum DelegationType {
        NONE,
        ALL,
        CONTRACT,
        ERC721,
        ERC20,
        ERC1155
    }

    /// @notice Struct for returning delegations
    struct Delegation {
        DelegationType type_;
        address to;
        address from;
        bytes32 rights;
        address contract_;
        uint256 tokenId;
        uint256 amount;
    }

    /// @notice Emitted when an address delegates or revokes rights for their entire wallet
    event DelegateAll(address indexed from, address indexed to, bytes32 rights, bool enable);

    /// @notice Emitted when an address delegates or revokes rights for a contract address
    event DelegateContract(address indexed from, address indexed to, address indexed contract_, bytes32 rights, bool enable);

    /// @notice Emitted when an address delegates or revokes rights for an ERC721 tokenId
    event DelegateERC721(address indexed from, address indexed to, address indexed contract_, uint256 tokenId, bytes32 rights, bool enable);

    /// @notice Emitted when an address delegates or revokes rights for an amount of ERC20 tokens
    event DelegateERC20(address indexed from, address indexed to, address indexed contract_, bytes32 rights, uint256 amount);

    /// @notice Emitted when an address delegates or revokes rights for an amount of an ERC1155 tokenId
    event DelegateERC1155(address indexed from, address indexed to, address indexed contract_, uint256 tokenId, bytes32 rights, uint256 amount);

    /// @notice Thrown if multicall calldata is malformed
    error MulticallFailed();

    /**
     * -----------  WRITE -----------
     */

    /**
     * @notice Call multiple functions in the current contract and return the data from all of them if they all succeed
     * @param data The encoded function data for each of the calls to make to this contract
     * @return results The results from each of the calls passed in via data
     */
    function multicall(bytes[] calldata data) external payable returns (bytes[] memory results);

    /**
     * @notice Allow the delegate to act on behalf of `msg.sender` for all contracts
     * @param to The address to act as delegate
     * @param rights Specific subdelegation rights granted to the delegate, pass an empty bytestring to encompass all rights
     * @param enable Whether to enable or disable this delegation, true delegates and false revokes
     * @return delegationHash The unique identifier of the delegation
     */
    function delegateAll(address to, bytes32 rights, bool enable) external payable returns (bytes32 delegationHash);

    /**
     * @notice Allow the delegate to act on behalf of `msg.sender` for a specific contract
     * @param to The address to act as delegate
     * @param contract_ The contract whose rights are being delegated
     * @param rights Specific subdelegation rights granted to the delegate, pass an empty bytestring to encompass all rights
     * @param enable Whether to enable or disable this delegation, true delegates and false revokes
     * @return delegationHash The unique identifier of the delegation
     */
    function delegateContract(address to, address contract_, bytes32 rights, bool enable) external payable returns (bytes32 delegationHash);

    /**
     * @notice Allow the delegate to act on behalf of `msg.sender` for a specific ERC721 token
     * @param to The address to act as delegate
     * @param contract_ The contract whose rights are being delegated
     * @param tokenId The token id to delegate
     * @param rights Specific subdelegation rights granted to the delegate, pass an empty bytestring to encompass all rights
     * @param enable Whether to enable or disable this delegation, true delegates and false revokes
     * @return delegationHash The unique identifier of the delegation
     */
    function delegateERC721(address to, address contract_, uint256 tokenId, bytes32 rights, bool enable) external payable returns (bytes32 delegationHash);

    /**
     * @notice Allow the delegate to act on behalf of `msg.sender` for a specific amount of ERC20 tokens
     * @dev The actual amount is not encoded in the hash, just the existence of a amount (since it is an upper bound)
     * @param to The address to act as delegate
     * @param contract_ The address for the fungible token contract
     * @param rights Specific subdelegation rights granted to the delegate, pass an empty bytestring to encompass all rights
     * @param amount The amount to delegate, > 0 delegates and 0 revokes
     * @return delegationHash The unique identifier of the delegation
     */
    function delegateERC20(address to, address contract_, bytes32 rights, uint256 amount) external payable returns (bytes32 delegationHash);

    /**
     * @notice Allow the delegate to act on behalf of `msg.sender` for a specific amount of ERC1155 tokens
     * @dev The actual amount is not encoded in the hash, just the existence of a amount (since it is an upper bound)
     * @param to The address to act as delegate
     * @param contract_ The address of the contract that holds the token
     * @param tokenId The token id to delegate
     * @param rights Specific subdelegation rights granted to the delegate, pass an empty bytestring to encompass all rights
     * @param amount The amount of that token id to delegate, > 0 delegates and 0 revokes
     * @return delegationHash The unique identifier of the delegation
     */
    function delegateERC1155(address to, address contract_, uint256 tokenId, bytes32 rights, uint256 amount) external payable returns (bytes32 delegationHash);

    /**
     * ----------- CHECKS -----------
     */

    /**
     * @notice Check if `to` is a delegate of `from` for the entire wallet
     * @param to The potential delegate address
     * @param from The potential address who delegated rights
     * @param rights Specific rights to check for, pass the zero value to ignore subdelegations and check full delegations only
     * @return valid Whether delegate is granted to act on the from's behalf
     */
    function checkDelegateForAll(address to, address from, bytes32 rights) external view returns (bool);

    /**
     * @notice Check if `to` is a delegate of `from` for the specified `contract_` or the entire wallet
     * @param to The delegated address to check
     * @param contract_ The specific contract address being checked
     * @param from The cold wallet who issued the delegation
     * @param rights Specific rights to check for, pass the zero value to ignore subdelegations and check full delegations only
     * @return valid Whether delegate is granted to act on from's behalf for entire wallet or that specific contract
     */
    function checkDelegateForContract(address to, address from, address contract_, bytes32 rights) external view returns (bool);

    /**
     * @notice Check if `to` is a delegate of `from` for the specific `contract` and `tokenId`, the entire `contract_`, or the entire wallet
     * @param to The delegated address to check
     * @param contract_ The specific contract address being checked
     * @param tokenId The token id for the token to delegating
     * @param from The wallet that issued the delegation
     * @param rights Specific rights to check for, pass the zero value to ignore subdelegations and check full delegations only
     * @return valid Whether delegate is granted to act on from's behalf for entire wallet, that contract, or that specific tokenId
     */
    function checkDelegateForERC721(address to, address from, address contract_, uint256 tokenId, bytes32 rights) external view returns (bool);

    /**
     * @notice Returns the amount of ERC20 tokens the delegate is granted rights to act on the behalf of
     * @param to The delegated address to check
     * @param contract_ The address of the token contract
     * @param from The cold wallet who issued the delegation
     * @param rights Specific rights to check for, pass the zero value to ignore subdelegations and check full delegations only
     * @return balance The delegated balance, which will be 0 if the delegation does not exist
     */
    function checkDelegateForERC20(address to, address from, address contract_, bytes32 rights) external view returns (uint256);

    /**
     * @notice Returns the amount of a ERC1155 tokens the delegate is granted rights to act on the behalf of
     * @param to The delegated address to check
     * @param contract_ The address of the token contract
     * @param tokenId The token id to check the delegated amount of
     * @param from The cold wallet who issued the delegation
     * @param rights Specific rights to check for, pass the zero value to ignore subdelegations and check full delegations only
     * @return balance The delegated balance, which will be 0 if the delegation does not exist
     */
    function checkDelegateForERC1155(address to, address from, address contract_, uint256 tokenId, bytes32 rights) external view returns (uint256);

    /**
     * ----------- ENUMERATIONS -----------
     */

    /**
     * @notice Returns all enabled delegations a given delegate has received
     * @param to The address to retrieve delegations for
     * @return delegations Array of Delegation structs
     */
    function getIncomingDelegations(address to) external view returns (Delegation[] memory delegations);

    /**
     * @notice Returns all enabled delegations an address has given out
     * @param from The address to retrieve delegations for
     * @return delegations Array of Delegation structs
     */
    function getOutgoingDelegations(address from) external view returns (Delegation[] memory delegations);

    /**
     * @notice Returns all hashes associated with enabled delegations an address has received
     * @param to The address to retrieve incoming delegation hashes for
     * @return delegationHashes Array of delegation hashes
     */
    function getIncomingDelegationHashes(address to) external view returns (bytes32[] memory delegationHashes);

    /**
     * @notice Returns all hashes associated with enabled delegations an address has given out
     * @param from The address to retrieve outgoing delegation hashes for
     * @return delegationHashes Array of delegation hashes
     */
    function getOutgoingDelegationHashes(address from) external view returns (bytes32[] memory delegationHashes);

    /**
     * @notice Returns the delegations for a given array of delegation hashes
     * @param delegationHashes is an array of hashes that correspond to delegations
     * @return delegations Array of Delegation structs, return empty structs for nonexistent or revoked delegations
     */
    function getDelegationsFromHashes(bytes32[] calldata delegationHashes) external view returns (Delegation[] memory delegations);

    /**
     * ----------- STORAGE ACCESS -----------
     */

    /**
     * @notice Allows external contracts to read arbitrary storage slots
     */
    function readSlot(bytes32 location) external view returns (bytes32);

    /**
     * @notice Allows external contracts to read an arbitrary array of storage slots
     */
    function readSlots(bytes32[] calldata locations) external view returns (bytes32[] memory);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC1271.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC-1271 standard signature validation method for
 * contracts as defined in https://eips.ethereum.org/EIPS/eip-1271[ERC-1271].
 */
interface IERC1271 {
    /**
     * @dev Should return whether the signature provided is valid for the provided data
     * @param hash      Hash of the data to be signed
     * @param signature Signature byte array associated with _data
     */
    function isValidSignature(bytes32 hash, bytes memory signature) external view returns (bytes4 magicValue);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Strings.sol)

pragma solidity ^0.8.20;

import {Math} from "./math/Math.sol";
import {SignedMath} from "./math/SignedMath.sol";

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant HEX_DIGITS = "0123456789abcdef";
    uint8 private constant ADDRESS_LENGTH = 20;

    /**
     * @dev The `value` string doesn't fit in the specified `length`.
     */
    error StringsInsufficientHexLength(uint256 value, uint256 length);

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
                    mstore8(ptr, byte(mod(value, 10), HEX_DIGITS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `int256` to its ASCII `string` decimal representation.
     */
    function toStringSigned(int256 value) internal pure returns (string memory) {
        return string.concat(value < 0 ? "-" : "", toString(SignedMath.abs(value)));
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
        uint256 localValue = value;
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = HEX_DIGITS[localValue & 0xf];
            localValue >>= 4;
        }
        if (localValue != 0) {
            revert StringsInsufficientHexLength(value, length);
        }
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal
     * representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), ADDRESS_LENGTH);
    }

    /**
     * @dev Returns true if the two strings are equal.
     */
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return bytes(a).length == bytes(b).length && keccak256(bytes(a)) == keccak256(bytes(b));
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.20;

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
        InvalidSignatureS
    }

    /**
     * @dev The signature derives the `address(0)`.
     */
    error ECDSAInvalidSignature();

    /**
     * @dev The signature has an invalid length.
     */
    error ECDSAInvalidSignatureLength(uint256 length);

    /**
     * @dev The signature has an S value that is in the upper half order.
     */
    error ECDSAInvalidSignatureS(bytes32 s);

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with `signature` or an error. This will not
     * return address(0) without also returning an error description. Errors are documented using an enum (error type)
     * and a bytes32 providing additional information about the error.
     *
     * If no error is returned, then the address can be used for verification purposes.
     *
     * The `ecrecover` EVM precompile allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {MessageHashUtils-toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError, bytes32) {
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
            return (address(0), RecoverError.InvalidSignatureLength, bytes32(signature.length));
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM precompile allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {MessageHashUtils-toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, signature);
        _throwError(error, errorArg);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[ERC-2098 short signatures]
     */
    function tryRecover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address, RecoverError, bytes32) {
        unchecked {
            bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
            // We do not check for an overflow here since the shift operation results in 0 or 1.
            uint8 v = uint8((uint256(vs) >> 255) + 27);
            return tryRecover(hash, v, r, s);
        }
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     */
    function recover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address) {
        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, r, vs);
        _throwError(error, errorArg);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError, bytes32) {
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
            return (address(0), RecoverError.InvalidSignatureS, s);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature, bytes32(0));
        }

        return (signer, RecoverError.NoError, bytes32(0));
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, v, r, s);
        _throwError(error, errorArg);
        return recovered;
    }

    /**
     * @dev Optionally reverts with the corresponding custom error according to the `error` argument provided.
     */
    function _throwError(RecoverError error, bytes32 errorArg) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert ECDSAInvalidSignature();
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert ECDSAInvalidSignatureLength(uint256(errorArg));
        } else if (error == RecoverError.InvalidSignatureS) {
            revert ECDSAInvalidSignatureS(errorArg);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/cryptography/MessageHashUtils.sol)

pragma solidity ^0.8.20;

import {Strings} from "../Strings.sol";

/**
 * @dev Signature message hash utilities for producing digests to be consumed by {ECDSA} recovery or signing.
 *
 * The library provides methods for generating a hash of a message that conforms to the
 * https://eips.ethereum.org/EIPS/eip-191[ERC-191] and https://eips.ethereum.org/EIPS/eip-712[EIP 712]
 * specifications.
 */
library MessageHashUtils {
    /**
     * @dev Returns the keccak256 digest of an ERC-191 signed data with version
     * `0x45` (`personal_sign` messages).
     *
     * The digest is calculated by prefixing a bytes32 `messageHash` with
     * `"\x19Ethereum Signed Message:\n32"` and hashing the result. It corresponds with the
     * hash signed when using the https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`] JSON-RPC method.
     *
     * NOTE: The `messageHash` parameter is intended to be the result of hashing a raw message with
     * keccak256, although any bytes32 value can be safely used because the final digest will
     * be re-hashed.
     *
     * See {ECDSA-recover}.
     */
    function toEthSignedMessageHash(bytes32 messageHash) internal pure returns (bytes32 digest) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, "\x19Ethereum Signed Message:\n32") // 32 is the bytes-length of messageHash
            mstore(0x1c, messageHash) // 0x1c (28) is the length of the prefix
            digest := keccak256(0x00, 0x3c) // 0x3c is the length of the prefix (0x1c) + messageHash (0x20)
        }
    }

    /**
     * @dev Returns the keccak256 digest of an ERC-191 signed data with version
     * `0x45` (`personal_sign` messages).
     *
     * The digest is calculated by prefixing an arbitrary `message` with
     * `"\x19Ethereum Signed Message:\n" + len(message)` and hashing the result. It corresponds with the
     * hash signed when using the https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`] JSON-RPC method.
     *
     * See {ECDSA-recover}.
     */
    function toEthSignedMessageHash(bytes memory message) internal pure returns (bytes32) {
        return
            keccak256(bytes.concat("\x19Ethereum Signed Message:\n", bytes(Strings.toString(message.length)), message));
    }

    /**
     * @dev Returns the keccak256 digest of an ERC-191 signed data with version
     * `0x00` (data with intended validator).
     *
     * The digest is calculated by prefixing an arbitrary `data` with `"\x19\x00"` and the intended
     * `validator` address. Then hashing the result.
     *
     * See {ECDSA-recover}.
     */
    function toDataWithIntendedValidatorHash(address validator, bytes memory data) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(hex"19_00", validator, data));
    }

    /**
     * @dev Returns the keccak256 digest of an EIP-712 typed data (ERC-191 version `0x01`).
     *
     * The digest is calculated from a `domainSeparator` and a `structHash`, by prefixing them with
     * `\x19\x01` and hashing the result. It corresponds to the hash signed by the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`] JSON-RPC method as part of EIP-712.
     *
     * See {ECDSA-recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32 digest) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, hex"19_01")
            mstore(add(ptr, 0x02), domainSeparator)
            mstore(add(ptr, 0x22), structHash)
            digest := keccak256(ptr, 0x42)
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/Math.sol)

pragma solidity ^0.8.20;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Muldiv operation overflow.
     */
    error MathOverflowedMulDiv();

    enum Rounding {
        Floor, // Toward negative infinity
        Ceil, // Toward positive infinity
        Trunc, // Toward zero
        Expand // Away from zero
    }

    /**
     * @dev Returns the addition of two unsigned integers, with an success flag (no overflow).
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool success, uint256 result) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an success flag (no overflow).
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool success, uint256 result) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an success flag (no overflow).
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool success, uint256 result) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a success flag (no division by zero).
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool success, uint256 result) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a success flag (no division by zero).
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool success, uint256 result) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
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
     * This differs from standard division with `/` in that it rounds towards infinity instead
     * of rounding towards zero.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b == 0) {
            // Guarantee the same behavior as in a regular Solidity division.
            return a / b;
        }

        // The following calculation ensures accurate ceiling division without overflow.
        // Since a is non-zero, (a - 1) / b will not overflow.
        // The largest possible result occurs when (a - 1) / b is type(uint256).max,
        // but the largest value we can obtain is type(uint256).max - 1, which happens
        // when a = type(uint256).max and b = 1.
        unchecked {
            return a == 0 ? 0 : (a - 1) / b + 1;
        }
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or
     * denominator == 0.
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv) with further edits by
     * Uniswap Labs also under MIT license.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0 = x * y; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                // Solidity will revert if denominator == 0, unlike the div opcode on its own.
                // The surrounding unchecked block does not change this fact.
                // See https://docs.soliditylang.org/en/latest/control-structures.html#checked-or-unchecked-arithmetic.
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            if (denominator <= prod1) {
                revert MathOverflowedMulDiv();
            }

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

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator.
            // Always >= 1. See https://cs.stackexchange.com/q/138556/92363.

            uint256 twos = denominator & (0 - denominator);
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

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also
            // works in modular arithmetic, doubling the correct bits in each step.
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
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (unsignedRoundsUp(rounding) && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded
     * towards zero.
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
            return result + (unsignedRoundsUp(rounding) && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2 of a positive value rounded towards zero.
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
            return result + (unsignedRoundsUp(rounding) && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
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
            return result + (unsignedRoundsUp(rounding) && 10 ** result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256 of a positive value rounded towards zero.
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
     * @dev Return the log in base 256, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (unsignedRoundsUp(rounding) && 1 << (result << 3) < value ? 1 : 0);
        }
    }

    /**
     * @dev Returns whether a provided rounding mode is considered rounding up for unsigned integers.
     */
    function unsignedRoundsUp(Rounding rounding) internal pure returns (bool) {
        return uint8(rounding) % 2 == 1;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/SignedMath.sol)

pragma solidity ^0.8.20;

/**
 * @dev Standard signed math utilities missing in the Solidity language.
 */
library SignedMath {
    /**
     * @dev Returns the largest of two signed numbers.
     */
    function max(int256 a, int256 b) internal pure returns (int256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two signed numbers.
     */
    function min(int256 a, int256 b) internal pure returns (int256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two signed numbers without overflow.
     * The result is rounded towards zero.
     */
    function average(int256 a, int256 b) internal pure returns (int256) {
        // Formula from the book "Hacker's Delight"
        int256 x = (a & b) + ((a ^ b) >> 1);
        return x + (int256(uint256(x) >> 255) & (a ^ b));
    }

    /**
     * @dev Returns the absolute unsigned value of a signed value.
     */
    function abs(int256 n) internal pure returns (uint256) {
        unchecked {
            // Formula from the "Bit Twiddling Hacks" by Sean Eron Anderson.
            // Since `n` is a signed integer, the generated bytecode will use the SAR opcode to perform the right shift,
            // taking advantage of the most significant (or "sign" bit) in two's complement representation.
            // This opcode adds new most significant bits set to the value of the previous most significant bit. As a result,
            // the mask will either be `bytes(0)` (if n is positive) or `~bytes32(0)` (if n is negative).
            int256 mask = n >> 255;

            // A `bytes(0)` mask leaves the input unchanged, while a `~bytes32(0)` mask complements it.
            return uint256((n + mask) ^ mask);
        }
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Simple single owner authorization mixin.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/auth/Owned.sol)
abstract contract Owned {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event OwnershipTransferred(address indexed user, address indexed newOwner);

    /*//////////////////////////////////////////////////////////////
                            OWNERSHIP STORAGE
    //////////////////////////////////////////////////////////////*/

    address public owner;

    modifier onlyOwner() virtual {
        require(msg.sender == owner, "UNAUTHORIZED");

        _;
    }

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _owner) {
        owner = _owner;

        emit OwnershipTransferred(address(0), _owner);
    }

    /*//////////////////////////////////////////////////////////////
                             OWNERSHIP LOGIC
    //////////////////////////////////////////////////////////////*/

    function transferOwnership(address newOwner) public virtual onlyOwner {
        owner = newOwner;

        emit OwnershipTransferred(msg.sender, newOwner);
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Modern and gas efficient ERC20 + EIP-2612 implementation.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC20.sol)
/// @author Modified from Uniswap (https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/UniswapV2ERC20.sol)
/// @dev Do not manually set balances without updating totalSupply, as the sum of all user balances must not exceed it.
abstract contract ERC20 {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    /*//////////////////////////////////////////////////////////////
                            METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

    string public name;

    string public symbol;

    uint8 public immutable decimals;

    /*//////////////////////////////////////////////////////////////
                              ERC20 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    /*//////////////////////////////////////////////////////////////
                            EIP-2612 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 internal immutable INITIAL_CHAIN_ID;

    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;

    mapping(address => uint256) public nonces;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        INITIAL_CHAIN_ID = block.chainid;
        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();
    }

    /*//////////////////////////////////////////////////////////////
                               ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        balanceOf[msg.sender] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(msg.sender, to, amount);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;

        balanceOf[from] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);

        return true;
    }

    /*//////////////////////////////////////////////////////////////
                             EIP-2612 LOGIC
    //////////////////////////////////////////////////////////////*/

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

        // Unchecked because the only math done is incrementing
        // the owner's nonce which cannot realistically overflow.
        unchecked {
            address recoveredAddress = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19\x01",
                        DOMAIN_SEPARATOR(),
                        keccak256(
                            abi.encode(
                                keccak256(
                                    "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                                ),
                                owner,
                                spender,
                                value,
                                nonces[owner]++,
                                deadline
                            )
                        )
                    )
                ),
                v,
                r,
                s
            );

            require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_SIGNER");

            allowance[recoveredAddress][spender] = value;
        }

        emit Approval(owner, spender, value);
    }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();
    }

    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                    keccak256(bytes(name)),
                    keccak256("1"),
                    block.chainid,
                    address(this)
                )
            );
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        balanceOf[from] -= amount;

        // Cannot underflow because a user's balance
        // will never be larger than the total supply.
        unchecked {
            totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Modern, minimalist, and gas efficient ERC-721 implementation.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC721.sol)
abstract contract ERC721 {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 indexed id);

    event Approval(address indexed owner, address indexed spender, uint256 indexed id);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /*//////////////////////////////////////////////////////////////
                         METADATA STORAGE/LOGIC
    //////////////////////////////////////////////////////////////*/

    string public name;

    string public symbol;

    function tokenURI(uint256 id) public view virtual returns (string memory);

    /*//////////////////////////////////////////////////////////////
                      ERC721 BALANCE/OWNER STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(uint256 => address) internal _ownerOf;

    mapping(address => uint256) internal _balanceOf;

    function ownerOf(uint256 id) public view virtual returns (address owner) {
        require((owner = _ownerOf[id]) != address(0), "NOT_MINTED");
    }

    function balanceOf(address owner) public view virtual returns (uint256) {
        require(owner != address(0), "ZERO_ADDRESS");

        return _balanceOf[owner];
    }

    /*//////////////////////////////////////////////////////////////
                         ERC721 APPROVAL STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(uint256 => address) public getApproved;

    mapping(address => mapping(address => bool)) public isApprovedForAll;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    /*//////////////////////////////////////////////////////////////
                              ERC721 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 id) public virtual {
        address owner = _ownerOf[id];

        require(msg.sender == owner || isApprovedForAll[owner][msg.sender], "NOT_AUTHORIZED");

        getApproved[id] = spender;

        emit Approval(owner, spender, id);
    }

    function setApprovalForAll(address operator, bool approved) public virtual {
        isApprovedForAll[msg.sender][operator] = approved;

        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function transferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual {
        require(from == _ownerOf[id], "WRONG_FROM");

        require(to != address(0), "INVALID_RECIPIENT");

        require(
            msg.sender == from || isApprovedForAll[from][msg.sender] || msg.sender == getApproved[id],
            "NOT_AUTHORIZED"
        );

        // Underflow of the sender's balance is impossible because we check for
        // ownership above and the recipient's balance can't realistically overflow.
        unchecked {
            _balanceOf[from]--;

            _balanceOf[to]++;
        }

        _ownerOf[id] = to;

        delete getApproved[id];

        emit Transfer(from, to, id);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual {
        transferFrom(from, to, id);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, "") ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        bytes calldata data
    ) public virtual {
        transferFrom(from, to, id);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, data) ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    /*//////////////////////////////////////////////////////////////
                              ERC165 LOGIC
    //////////////////////////////////////////////////////////////*/

    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return
            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
            interfaceId == 0x80ac58cd || // ERC165 Interface ID for ERC721
            interfaceId == 0x5b5e139f; // ERC165 Interface ID for ERC721Metadata
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(address to, uint256 id) internal virtual {
        require(to != address(0), "INVALID_RECIPIENT");

        require(_ownerOf[id] == address(0), "ALREADY_MINTED");

        // Counter overflow is incredibly unrealistic.
        unchecked {
            _balanceOf[to]++;
        }

        _ownerOf[id] = to;

        emit Transfer(address(0), to, id);
    }

    function _burn(uint256 id) internal virtual {
        address owner = _ownerOf[id];

        require(owner != address(0), "NOT_MINTED");

        // Ownership check above ensures no underflow.
        unchecked {
            _balanceOf[owner]--;
        }

        delete _ownerOf[id];

        delete getApproved[id];

        emit Transfer(owner, address(0), id);
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL SAFE MINT LOGIC
    //////////////////////////////////////////////////////////////*/

    function _safeMint(address to, uint256 id) internal virtual {
        _mint(to, id);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, address(0), id, "") ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function _safeMint(
        address to,
        uint256 id,
        bytes memory data
    ) internal virtual {
        _mint(to, id);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, address(0), id, data) ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }
}

/// @notice A generic interface for a contract which properly accepts ERC721 tokens.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC721.sol)
abstract contract ERC721TokenReceiver {
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external virtual returns (bytes4) {
        return ERC721TokenReceiver.onERC721Received.selector;
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Arithmetic library with operations for fixed-point numbers.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/FixedPointMathLib.sol)
/// @author Inspired by USM (https://github.com/usmfum/USM/blob/master/contracts/WadMath.sol)
library FixedPointMathLib {
    /*//////////////////////////////////////////////////////////////
                    SIMPLIFIED FIXED POINT OPERATIONS
    //////////////////////////////////////////////////////////////*/

    uint256 internal constant MAX_UINT256 = 2**256 - 1;

    uint256 internal constant WAD = 1e18; // The scalar of ETH and most ERC20s.

    function mulWadDown(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulDivDown(x, y, WAD); // Equivalent to (x * y) / WAD rounded down.
    }

    function mulWadUp(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulDivUp(x, y, WAD); // Equivalent to (x * y) / WAD rounded up.
    }

    function divWadDown(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulDivDown(x, WAD, y); // Equivalent to (x * WAD) / y rounded down.
    }

    function divWadUp(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulDivUp(x, WAD, y); // Equivalent to (x * WAD) / y rounded up.
    }

    /*//////////////////////////////////////////////////////////////
                    LOW LEVEL FIXED POINT OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function mulDivDown(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Equivalent to require(denominator != 0 && (y == 0 || x <= type(uint256).max / y))
            if iszero(mul(denominator, iszero(mul(y, gt(x, div(MAX_UINT256, y)))))) {
                revert(0, 0)
            }

            // Divide x * y by the denominator.
            z := div(mul(x, y), denominator)
        }
    }

    function mulDivUp(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Equivalent to require(denominator != 0 && (y == 0 || x <= type(uint256).max / y))
            if iszero(mul(denominator, iszero(mul(y, gt(x, div(MAX_UINT256, y)))))) {
                revert(0, 0)
            }

            // If x * y modulo the denominator is strictly greater than 0,
            // 1 is added to round up the division of x * y by the denominator.
            z := add(gt(mod(mul(x, y), denominator), 0), div(mul(x, y), denominator))
        }
    }

    function rpow(
        uint256 x,
        uint256 n,
        uint256 scalar
    ) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            switch x
            case 0 {
                switch n
                case 0 {
                    // 0 ** 0 = 1
                    z := scalar
                }
                default {
                    // 0 ** n = 0
                    z := 0
                }
            }
            default {
                switch mod(n, 2)
                case 0 {
                    // If n is even, store scalar in z for now.
                    z := scalar
                }
                default {
                    // If n is odd, store x in z for now.
                    z := x
                }

                // Shifting right by 1 is like dividing by 2.
                let half := shr(1, scalar)

                for {
                    // Shift n right by 1 before looping to halve it.
                    n := shr(1, n)
                } n {
                    // Shift n right by 1 each iteration to halve it.
                    n := shr(1, n)
                } {
                    // Revert immediately if x ** 2 would overflow.
                    // Equivalent to iszero(eq(div(xx, x), x)) here.
                    if shr(128, x) {
                        revert(0, 0)
                    }

                    // Store x squared.
                    let xx := mul(x, x)

                    // Round to the nearest number.
                    let xxRound := add(xx, half)

                    // Revert if xx + half overflowed.
                    if lt(xxRound, xx) {
                        revert(0, 0)
                    }

                    // Set x to scaled xxRound.
                    x := div(xxRound, scalar)

                    // If n is even:
                    if mod(n, 2) {
                        // Compute z * x.
                        let zx := mul(z, x)

                        // If z * x overflowed:
                        if iszero(eq(div(zx, x), z)) {
                            // Revert if x is non-zero.
                            if iszero(iszero(x)) {
                                revert(0, 0)
                            }
                        }

                        // Round to the nearest number.
                        let zxRound := add(zx, half)

                        // Revert if zx + half overflowed.
                        if lt(zxRound, zx) {
                            revert(0, 0)
                        }

                        // Return properly scaled zxRound.
                        z := div(zxRound, scalar)
                    }
                }
            }
        }
    }

    /*//////////////////////////////////////////////////////////////
                        GENERAL NUMBER UTILITIES
    //////////////////////////////////////////////////////////////*/

    function sqrt(uint256 x) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            let y := x // We start y at x, which will help us make our initial estimate.

            z := 181 // The "correct" value is 1, but this saves a multiplication later.

            // This segment is to get a reasonable initial estimate for the Babylonian method. With a bad
            // start, the correct # of bits increases ~linearly each iteration instead of ~quadratically.

            // We check y >= 2^(k + 8) but shift right by k bits
            // each branch to ensure that if x >= 256, then y >= 256.
            if iszero(lt(y, 0x10000000000000000000000000000000000)) {
                y := shr(128, y)
                z := shl(64, z)
            }
            if iszero(lt(y, 0x1000000000000000000)) {
                y := shr(64, y)
                z := shl(32, z)
            }
            if iszero(lt(y, 0x10000000000)) {
                y := shr(32, y)
                z := shl(16, z)
            }
            if iszero(lt(y, 0x1000000)) {
                y := shr(16, y)
                z := shl(8, z)
            }

            // Goal was to get z*z*y within a small factor of x. More iterations could
            // get y in a tighter range. Currently, we will have y in [256, 256*2^16).
            // We ensured y >= 256 so that the relative difference between y and y+1 is small.
            // That's not possible if x < 256 but we can just verify those cases exhaustively.

            // Now, z*z*y <= x < z*z*(y+1), and y <= 2^(16+8), and either y >= 256, or x < 256.
            // Correctness can be checked exhaustively for x < 256, so we assume y >= 256.
            // Then z*sqrt(y) is within sqrt(257)/sqrt(256) of sqrt(x), or about 20bps.

            // For s in the range [1/256, 256], the estimate f(s) = (181/1024) * (s+1) is in the range
            // (1/2.84 * sqrt(s), 2.84 * sqrt(s)), with largest error when s = 1 and when s = 256 or 1/256.

            // Since y is in [256, 256*2^16), let a = y/65536, so that a is in [1/256, 256). Then we can estimate
            // sqrt(y) using sqrt(65536) * 181/1024 * (a + 1) = 181/4 * (y + 65536)/65536 = 181 * (y + 65536)/2^18.

            // There is no overflow risk here since y < 2^136 after the first branch above.
            z := shr(18, mul(z, add(y, 65536))) // A mul() is saved from starting z at 181.

            // Given the worst case multiplicative error of 2.84 above, 7 iterations should be enough.
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))

            // If x+1 is a perfect square, the Babylonian method cycles between
            // floor(sqrt(x)) and ceil(sqrt(x)). This statement ensures we return floor.
            // See: https://en.wikipedia.org/wiki/Integer_square_root#Using_only_integer_division
            // Since the ceil is rare, we save gas on the assignment and repeat division in the rare case.
            // If you don't care whether the floor or ceil square root is returned, you can remove this statement.
            z := sub(z, lt(div(x, z), z))
        }
    }

    function unsafeMod(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Mod x by y. Note this will return
            // 0 instead of reverting if y is zero.
            z := mod(x, y)
        }
    }

    function unsafeDiv(uint256 x, uint256 y) internal pure returns (uint256 r) {
        /// @solidity memory-safe-assembly
        assembly {
            // Divide x by y. Note this will return
            // 0 instead of reverting if y is zero.
            r := div(x, y)
        }
    }

    function unsafeDivUp(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Add 1 to x * y if x % y > 0. Note this will
            // return 0 instead of reverting if y is zero.
            z := add(gt(mod(x, y), 0), div(x, y))
        }
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Gas optimized reentrancy protection for smart contracts.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/ReentrancyGuard.sol)
/// @author Modified from OpenZeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/ReentrancyGuard.sol)
abstract contract ReentrancyGuard {
    uint256 private locked = 1;

    modifier nonReentrant() virtual {
        require(locked == 1, "REENTRANCY");

        locked = 2;

        _;

        locked = 1;
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ERC20} from "../tokens/ERC20.sol";

/// @notice Safe ETH and ERC20 transfer library that gracefully handles missing return values.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/SafeTransferLib.sol)
/// @dev Use with caution! Some functions in this library knowingly create dirty bits at the destination of the free memory pointer.
/// @dev Note that none of the functions in this library check that a token has code at all! That responsibility is delegated to the caller.
library SafeTransferLib {
    /*//////////////////////////////////////////////////////////////
                             ETH OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferETH(address to, uint256 amount) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Transfer the ETH and store if it succeeded or not.
            success := call(gas(), to, amount, 0, 0, 0, 0)
        }

        require(success, "ETH_TRANSFER_FAILED");
    }

    /*//////////////////////////////////////////////////////////////
                            ERC20 OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferFrom(
        ERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x23b872dd00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(from, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "from" argument.
            mstore(add(freeMemoryPointer, 36), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "to" argument.
            mstore(add(freeMemoryPointer, 68), amount) // Append the "amount" argument. Masking not required as it's a full 32 byte type.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 100 because the length of our calldata totals up like so: 4 + 32 * 3.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 100, 0, 32)
            )
        }

        require(success, "TRANSFER_FROM_FAILED");
    }

    function safeTransfer(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument. Masking not required as it's a full 32 byte type.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        require(success, "TRANSFER_FAILED");
    }

    function safeApprove(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x095ea7b300000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument. Masking not required as it's a full 32 byte type.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        require(success, "APPROVE_FAILED");
    }
}
// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import "./loans/IMultiSourceLoan.sol";

/// @title Liquidates Collateral for Defaulted Loans using English Auctions.
/// @author Florida St
/// @notice It liquidates collateral corresponding to defaulted loans
///         and sends back the proceeds to the loan contract for distribution.
interface IAuctionLoanLiquidator {
    /// @notice The auction struct.
    /// @param loanAddress The loan contract address.
    /// @param loanId The loan id.
    /// @param highestBid The highest bid.
    /// @param triggerFee The trigger fee.
    /// @param minBid The minimum bid.
    /// @param highestBidder The highest bidder.
    /// @param duration The auction duration.
    /// @param asset The asset address.
    /// @param startTime The auction start time.
    /// @param originator The address that triggered the liquidation.
    /// @param lastBidTime The last bid time.
    struct Auction {
        address loanAddress;
        uint256 loanId;
        uint256 highestBid;
        uint256 triggerFee;
        uint256 minBid;
        address highestBidder;
        uint96 duration;
        address asset;
        uint96 startTime;
        address originator;
        uint96 lastBidTime;
    }

    /// @notice Add a loan contract to the list of accepted contracts.
    /// @param _loanContract The loan contract to be added.
    function addLoanContract(address _loanContract) external;

    /// @notice Remove a loan contract from the list of accepted contracts.
    /// @param _loanContract The loan contract to be removed.
    function removeLoanContract(address _loanContract) external;

    /// @return The loan contracts that are accepted by this liquidator.
    function getValidLoanContracts() external view returns (address[] memory);

    /// @notice Update liquidation distributor.
    /// @param _liquidationDistributor The new liquidation distributor.
    function updateLiquidationDistributor(address _liquidationDistributor) external;

    /// @return liquidationDistributor The liquidation distributor address.
    function getLiquidationDistributor() external view returns (address);

    /// @notice Called by the owner to update the trigger fee.
    /// @param triggerFee The new trigger fee.
    function updateTriggerFee(uint256 triggerFee) external;

    /// @return triggerFee The trigger fee.
    function getTriggerFee() external view returns (uint256);

    /// @notice When a bid is placed, the contract takes possesion of the bid, and
    ///         if there was a previous bid, it returns that capital to the original
    ///         bidder.
    /// @param _contract The nft contract address.
    /// @param _tokenId The nft id.
    /// @param _auction The auction struct.
    /// @param _bid The bid amount.
    /// @return auction The updated auction struct.
    function placeBid(address _contract, uint256 _tokenId, Auction memory _auction, uint256 _bid)
        external
        returns (Auction memory);

    /// @notice On settlement, the NFT is sent to the highest bidder.
    ///         Calls loan liquidated for accounting purposes.
    /// @param _auction The auction struct.
    /// @param _loan The loan struct.
    function settleAuction(Auction calldata _auction, IMultiSourceLoan.Loan calldata _loan) external;

    /// @notice The contract has hashes of all auctions to save space (not the actual struct)
    /// @param _contract The nft contract address.
    /// @param _tokenId The nft id.
    /// @return auctionHash The auction hash.
    function getAuctionHash(address _contract, uint256 _tokenId) external view returns (bytes32);
}
// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.21;

import "./loans/IMultiSourceLoan.sol";

/// @title Interface for liquidation handlers.
/// @author Florida St
/// @notice Liquidation Handler
interface ILiquidationHandler {
    /// @return Liquidator contract address
    function getLiquidator() external returns (address);

    /// @notice Updates the liquidation contract.
    /// @param loanLiquidator New liquidation contract.
    function updateLiquidationContract(address loanLiquidator) external;

    /// @notice Updates the auction duration for liquidations.
    /// @param _newDuration New auction duration.
    function updateLiquidationAuctionDuration(uint48 _newDuration) external;

    /// @return auctionDuration Returns the auction's duration for liquidations.
    function getLiquidationAuctionDuration() external returns (uint48);
}
// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import "../interfaces/loans/IMultiSourceLoan.sol";

/// @title Liquidates Collateral for Defaulted Loans
/// @author Florida St
/// @notice It liquidates collateral corresponding to defaulted loans
///         and sends back the proceeds to the loan contract for distribution.
interface ILoanLiquidator {
    /// @notice Given a loan, it takes posession of the NFT and liquidates it.
    /// @param _loanId The loan id.
    /// @param _contract The loan contract address.
    /// @param _tokenId The NFT id.
    /// @param _asset The asset address.
    /// @param _duration The liquidation duration.
    /// @param _minBid The minimum bid.
    /// @param _originator The address that trigger the liquidation.
    /// @return encodedAuction Encoded struct.
    function liquidateLoan(
        uint256 _loanId,
        address _contract,
        uint256 _tokenId,
        address _asset,
        uint96 _duration,
        uint256 _minBid,
        address _originator
    ) external returns (bytes memory);
}
// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

interface IMulticall {
    error MulticallFailed(uint256 i, bytes returndata);

    /// @notice Call multiple functions in the contract. Revert if one of them fails, return results otherwise.
    /// @param data Encoded function calls.
    /// @return results The results of the function calls.
    function multicall(bytes[] calldata data) external payable returns (bytes[] memory results);
}
// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

/// @title NFT Flash Action Interface
/// @author Florida St
/// @notice Interface for Flash Actions on NFTs in outstanding loans.
interface INFTFlashAction {
    error InvalidOwnerError();

    /// @notice Execute an arbitrary flash action on a given NFT. This contract owns it and must return it.
    /// @param _collection The NFT collection.
    /// @param _tokenId The NFT token ID.
    /// @param _target The target contract.
    /// @param _data The data to send to the target.
    function execute(address _collection, uint256 _tokenId, address _target, bytes calldata _data) external;
}
// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.20;

import "../loans/IMultiSourceLoan.sol";

interface ILoanCallback {
    error InvalidCallbackError();

    /// @notice Called by the MSL contract after the principal of loan has been tranfered (when a loan is initiated)
    /// but before it tries to transfer the NFT into escrow.
    /// @param _loan The loan.
    /// @param _fee The origination fee.
    /// @param _executionData Execution data for purchase.
    /// @return The bytes4 magic value.
    function afterPrincipalTransfer(IMultiSourceLoan.Loan memory _loan, uint256 _fee, bytes calldata _executionData)
        external
        returns (bytes4);

    /// @notice Call by the MSL contract after the NFT has been transfered to the borrower repaying the loan, but before
    /// transfering the principal to the lender.
    /// @param _loan The loan.
    /// @param _executionData Execution data for the offer.
    /// @return The bytes4 magic value.
    function afterNFTTransfer(IMultiSourceLoan.Loan memory _loan, bytes calldata _executionData)
        external
        returns (bytes4);
}
// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import "../../interfaces/ILoanLiquidator.sol";

/// @title Interface for Loans.
/// @author Florida St
/// @notice Basic Loan
interface IBaseLoan {
    /// @notice Minimum improvement (in BPS) required for a strict improvement.
    /// @param principalAmount Minimum delta of principal amount.
    /// @param interest Minimum delta of interest.
    /// @param duration Minimum delta of duration.
    struct ImprovementMinimum {
        uint256 principalAmount;
        uint256 interest;
        uint256 duration;
    }

    /// @notice Arbitrary contract to validate offers implementing `IBaseOfferValidator`.
    /// @param validator Address of the validator contract.
    /// @param arguments Arguments to pass to the validator.
    struct OfferValidator {
        address validator;
        bytes arguments;
    }

    /// @notice Total number of loans issued by this contract.
    function getTotalLoansIssued() external view returns (uint256);

    /// @notice Cancel offer for `msg.sender`. Each lender has unique offerIds.
    /// @param _offerId Offer ID.
    function cancelOffer(uint256 _offerId) external;

    /// @notice Cancell all offers with offerId < _minOfferId
    /// @param _minOfferId Minimum offer ID.
    function cancelAllOffers(uint256 _minOfferId) external;

    /// @notice Cancel renegotiation offer. Similar to offers.
    /// @param _renegotiationId Renegotiation offer ID.
    function cancelRenegotiationOffer(uint256 _renegotiationId) external;
}
// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.21;

/// @title Multi Source Loan Interface
/// @author Florida St
/// @notice A multi source loan is one with multiple tranches.
interface ILoanManager {
    struct ProposedCaller {
        address caller;
        bool isLoanContract;
    }

    /// @notice Validate an offer. Can only be called by an accepted caller.
    /// @param _tokenId The token id.
    /// @param _offer The offer to validate.
    /// @param _protocolFee The protocol fee.
    function validateOffer(uint256 _tokenId, bytes calldata _offer, uint256 _protocolFee) external;

    /// @notice Update the offer handler.
    /// @param _offerHandler The new offer handler.
    function updateOfferHandler(address _offerHandler) external;

    /// @notice Get the offer handler setter.
    /// @dev Had to take this out from the contract because of size issues.
    /// @return The offer handler setter.
    function getParameterSetter() external view returns (address);

    /// @notice Add allowed callers.
    /// @param _callers The callers to add.
    function addCallers(ProposedCaller[] calldata _callers) external;

    /// @notice Called on loan repayment.
    /// @param _loanId The loan id.
    /// @param _principalAmount The principal amount.
    /// @param _apr The APR.
    /// @param _accruedInterest The accrued interest.
    /// @param _protocolFee The protocol fee.
    /// @param _startTime The start time.
    function loanRepayment(
        uint256 _loanId,
        uint256 _principalAmount,
        uint256 _apr,
        uint256 _accruedInterest,
        uint256 _protocolFee,
        uint256 _startTime
    ) external;

    /// @notice Called on loan liquidation.
    /// @param _loanAddress The address of the loan contract since this might be called by a liquidator.
    /// @param _loanId The loan id.
    /// @param _principalAmount The principal amount.
    /// @param _apr The APR.
    /// @param _accruedInterest The accrued interest.
    /// @param _protocolFee The protocol fee.
    /// @param _received The received amount (from liquidation proceeds)
    /// @param _startTime The start time.
    function loanLiquidation(
        address _loanAddress,
        uint256 _loanId,
        uint256 _principalAmount,
        uint256 _apr,
        uint256 _accruedInterest,
        uint256 _protocolFee,
        uint256 _received,
        uint256 _startTime
    ) external;
}
// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

/// @title Interface Loan Manager Registry
/// @author Florida St
/// @notice Interface for a Loan Manager Registry.
interface ILoanManagerRegistry {
    /// @notice Add a loan manager to the registry
    /// @param _loanManager Address of the loan manager
    function addLoanManager(address _loanManager) external;

    /// @notice Remove a loan manager from the registry
    /// @param _loanManager Address of the loan manager
    function removeLoanManager(address _loanManager) external;

    /// @notice Check if a loan manager is registered
    /// @param _loanManager Address of the loan manager
    /// @return True if the loan manager is registered
    function isLoanManager(address _loanManager) external view returns (bool);
}
// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.21;

import "./IBaseLoan.sol";

/// @title Multi Source Loan Interface
/// @author Florida St
/// @notice A multi source loan is one with multiple tranches.
interface IMultiSourceLoan {
    /// @notice Borrowers receive offers that are then validated.
    /// @dev Setting the nftCollateralTokenId to 0 triggers validation through `validators`.
    /// @param offerId Offer ID. Used for canceling/setting as executed.
    /// @param lender Lender of the offer.
    /// @param fee Origination fee.
    /// @param capacity Capacity of the offer.
    /// @param nftCollateralAddress Address of the NFT collateral.
    /// @param nftCollateralTokenId NFT collateral token ID.
    /// @param principalAddress Address of the principal.
    /// @param principalAmount Principal amount of the loan.
    /// @param aprBps APR in BPS.
    /// @param expirationTime Expiration time of the offer.
    /// @param duration Duration of the loan in seconds.
    /// @param maxSeniorRepayment Max amount of senior capital ahead (principal + interest).
    /// @param validators Arbitrary contract to validate offers implementing `IBaseOfferValidator`.
    struct LoanOffer {
        uint256 offerId;
        address lender;
        uint256 fee;
        uint256 capacity;
        address nftCollateralAddress;
        uint256 nftCollateralTokenId;
        address principalAddress;
        uint256 principalAmount;
        uint256 aprBps;
        uint256 expirationTime;
        uint256 duration;
        uint256 maxSeniorRepayment;
        IBaseLoan.OfferValidator[] validators;
    }

    /// @notice Offer + how much will be filled (always <= principalAmount).
    /// @param offer Offer.
    /// @param amount Amount to be filled.
    struct OfferExecution {
        LoanOffer offer;
        uint256 amount;
        bytes lenderOfferSignature;
    }

    /// @notice Offer + necessary fields to execute a specific loan. This has a separate expirationTime to avoid
    /// someone holding an offer and executing much later, without the borrower's awareness.
    /// @dev It's advised that borrowers only set an expirationTime close to the actual time they will execute the loan
    ///      to avoid replays.
    /// @param offerExecution List of offers to be filled and amount for each.
    /// @param tokenId NFT collateral token ID.
    /// @param amount The amount the borrower is willing to take (must be <= _loanOffer principalAmount)
    /// @param expirationTime Expiration time of the signed offer by the borrower.
    /// @param callbackData Data to pass to the callback.
    struct ExecutionData {
        OfferExecution[] offerExecution;
        uint256 tokenId;
        uint256 duration;
        uint256 expirationTime;
        address principalReceiver;
        bytes callbackData;
    }

    /// @param executionData Execution data.
    /// @param borrower Address that owns the NFT and will take over the loan.
    /// @param borrowerOfferSignature Signature of the offer (signed by borrower).
    /// @param callbackData Whether to call the afterPrincipalTransfer callback
    struct LoanExecutionData {
        ExecutionData executionData;
        address borrower;
        bytes borrowerOfferSignature;
    }

    /// @param loanId Loan ID.
    /// @param callbackData Whether to call the afterNFTTransfer callback
    /// @param shouldDelegate Whether to delegate ownership of the NFT (avoid seaport flags).
    struct SignableRepaymentData {
        uint256 loanId;
        bytes callbackData;
        bool shouldDelegate;
    }

    /// @param loan Loan.
    /// @param borrowerLoanSignature Signature of the loan (signed by borrower).
    struct LoanRepaymentData {
        SignableRepaymentData data;
        Loan loan;
        bytes borrowerSignature;
    }

    /// @notice Tranches have different seniority levels.
    /// @param loanId Loan ID.
    /// @param floor Amount of principal more senior to this tranche.
    /// @param principalAmount Total principal in this tranche.
    /// @param lender Lender for this given tranche.
    /// @param accruedInterest Accrued Interest.
    /// @param startTime Start Time. Either the time at which the loan initiated / was refinanced.
    /// @param aprBps APR in basis points.
    struct Tranche {
        uint256 loanId;
        uint256 floor;
        uint256 principalAmount;
        address lender;
        uint256 accruedInterest;
        uint256 startTime;
        uint256 aprBps;
    }

    /// @dev Principal Amount is equal to the sum of all tranches principalAmount.
    /// We keep it for caching purposes. Since we are not saving this on chain but the hash,
    /// it does not have a huge impact on gas.
    /// @param borrower Borrower.
    /// @param nftCollateralTokenId NFT Collateral Token ID.
    /// @param nftCollateralAddress NFT Collateral Address.
    /// @param principalAddress Principal Address.
    /// @param principalAmount Principal Amount.
    /// @param startTime Start Time.
    /// @param duration Duration.
    /// @param tranche Tranches.
    /// @param protocolFee Protocol Fee.
    struct Loan {
        address borrower;
        uint256 nftCollateralTokenId;
        address nftCollateralAddress;
        address principalAddress;
        uint256 principalAmount;
        uint256 startTime;
        uint256 duration;
        Tranche[] tranche;
        uint256 protocolFee;
    }

    /// @notice Renegotiation offer.
    /// @param renegotiationId Renegotiation ID.
    /// @param loanId Loan ID.
    /// @param lender Lender.
    /// @param fee Fee.
    /// @param trancheIndex Tranche Indexes to be refinanced.
    /// @param principalAmount Principal Amount. If more than one tranche, it must be the sum.
    /// @param aprBps APR in basis points.
    /// @param expirationTime Expiration Time.
    /// @param duration Duration.
    struct RenegotiationOffer {
        uint256 renegotiationId;
        uint256 loanId;
        address lender;
        uint256 fee;
        uint256[] trancheIndex;
        uint256 principalAmount;
        uint256 aprBps;
        uint256 expirationTime;
        uint256 duration;
    }

    event LoanLiquidated(uint256 loanId);
    event LoanEmitted(uint256 loanId, uint256[] offerId, Loan loan, uint256 fee);
    event LoanRefinanced(uint256 renegotiationId, uint256 oldLoanId, uint256 newLoanId, Loan loan, uint256 fee);
    event LoanRepaid(uint256 loanId, uint256 totalRepayment, uint256 fee);
    event LoanRefinancedFromNewOffers(
        uint256 loanId, uint256 newLoanId, Loan loan, uint256[] offerIds, uint256 totalFee
    );
    event Delegated(uint256 loanId, address delegate, bytes32 _rights, bool value);
    event FlashActionContractUpdated(address newFlashActionContract);
    event FlashActionExecuted(uint256 loanId, address target, bytes data);
    event RevokeDelegate(address delegate, address collection, uint256 tokenId, bytes32 _rights);
    event MinLockPeriodUpdated(uint256 minLockPeriod);

    /// @notice Call by the borrower when emiting a new loan.
    /// @param _loanExecutionData Loan execution data.
    /// @return loanId Loan ID.
    /// @return loan Loan.
    function emitLoan(LoanExecutionData calldata _loanExecutionData) external returns (uint256, Loan memory);

    /// @notice Refinance whole loan (leaving just one tranche).
    /// @param _renegotiationOffer Offer to refinance a loan.
    /// @param _loan Current loan.
    /// @param _renegotiationOfferSignature Signature of the offer.
    /// @return loanId New Loan Id, New Loan.
    function refinanceFull(
        RenegotiationOffer calldata _renegotiationOffer,
        Loan memory _loan,
        bytes calldata _renegotiationOfferSignature
    ) external returns (uint256, Loan memory);

    /// @notice Add a new tranche to a loan.
    /// @param _renegotiationOffer Offer for new tranche.
    /// @param _loan Current loan.
    /// @param _renegotiationOfferSignature Signature of the offer.
    /// @return loanId New Loan Id
    /// @return loan New Loan.
    function addNewTranche(
        RenegotiationOffer calldata _renegotiationOffer,
        Loan memory _loan,
        bytes calldata _renegotiationOfferSignature
    ) external returns (uint256, Loan memory);

    /// @notice Refinance a loan partially. It can only be called by the new lender
    /// (they are always a strict improvement on apr).
    /// @param _renegotiationOffer Offer to refinance a loan partially.
    /// @param _loan Current loan.
    /// @return loanId New Loan Id, New Loan.
    /// @return loan New Loan.
    function refinancePartial(RenegotiationOffer calldata _renegotiationOffer, Loan memory _loan)
        external
        returns (uint256, Loan memory);

    /// @notice Refinance a loan from LoanExecutionData. We let borrowers use outstanding offers for new loans
    ///         to refinance their current loan.
    /// @param _loanId Loan ID.
    /// @param _loan Current loan.
    /// @param _loanExecutionData Loan Execution Data.
    /// @return loanId New Loan Id.
    /// @return loan New Loan.
    function refinanceFromLoanExecutionData(
        uint256 _loanId,
        Loan calldata _loan,
        LoanExecutionData calldata _loanExecutionData
    ) external returns (uint256, Loan memory);

    /// @notice Repay loan. Interest is calculated pro-rata based on time. Lender is defined by nft ownership.
    /// @param _repaymentData Repayment data.
    function repayLoan(LoanRepaymentData calldata _repaymentData) external;

    /// @notice Call when a loan is past its due date.
    /// @param _loanId Loan ID.
    /// @param _loan Loan.
    /// @return Liquidation Struct of the liquidation.
    function liquidateLoan(uint256 _loanId, Loan calldata _loan) external returns (bytes memory);

    /// @return getMaxTranches Maximum number of tranches per loan.
    function getMaxTranches() external view returns (uint256);

    /// @notice Set min lock period (in BPS).
    /// @param _minLockPeriod Min lock period.
    function setMinLockPeriod(uint256 _minLockPeriod) external;

    /// @notice Get min lock period (in BPS).
    /// @return minLockPeriod Min lock period.
    function getMinLockPeriod() external view returns (uint256);

    /// @notice Get delegation registry.
    /// @return delegateRegistry Delegate registry.
    function getDelegateRegistry() external view returns (address);

    /// @notice Delegate ownership.
    /// @param _loanId Loan ID.
    /// @param _loan Loan.
    /// @param _rights Delegation Rights. Empty for all.
    /// @param _delegate Delegate address.
    /// @param _value True if delegate, false if undelegate.
    function delegate(uint256 _loanId, Loan calldata _loan, address _delegate, bytes32 _rights, bool _value) external;

    /// @notice Anyone can reveke a delegation on an NFT that's no longer in escrow.
    /// @param _delegate Delegate address.
    /// @param _collection Collection address.
    /// @param _tokenId Token ID.
    /// @param _rights Delegation Rights. Empty for all.
    function revokeDelegate(address _delegate, address _collection, uint256 _tokenId, bytes32 _rights) external;

    /// @notice Get Flash Action Contract.
    /// @return flashActionContract Flash Action Contract.
    function getFlashActionContract() external view returns (address);

    /// @notice Update Flash Action Contract.
    /// @param _newFlashActionContract Flash Action Contract.
    function setFlashActionContract(address _newFlashActionContract) external;

    /// @notice Get Loan Hash.
    /// @param _loanId Loan ID.
    /// @return loanHash Loan Hash.
    function getLoanHash(uint256 _loanId) external view returns (bytes32);

    /// @notice Transfer NFT to the flash action contract (expected use cases here are for airdrops and similar scenarios).
    /// The flash action contract would implement specific interactions with given contracts.
    /// Only the the borrower can call this function for a given loan. By the end of the transaction, the NFT must have
    /// been returned to escrow.
    /// @param _loanId Loan ID.
    /// @param _loan Loan.
    /// @param _target Target address for the flash action contract to interact with.
    /// @param _data Data to be passed to be passed to the ultimate contract.
    function executeFlashAction(uint256 _loanId, Loan calldata _loan, address _target, bytes calldata _data) external;

    /// @notice Called by the liquidator for accounting purposes.
    /// @param _loanId The id of the loan.
    /// @param _loan The loan object.
    function loanLiquidated(uint256 _loanId, Loan calldata _loan) external;
}
// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import "../loans/IMultiSourceLoan.sol";

/// @title Interface for  Loan Offer Validators.
/// @author Florida St
/// @notice Verify the given `_offer` is valid for `_tokenId` and `_validatorData`.
interface IOfferValidator {
    /// @notice Validate a loan offer.
    function validateOffer(IMultiSourceLoan.LoanOffer calldata _offer, uint256 _tokenId, bytes calldata _validatorData)
        external
        view;
}
// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.21;

import "@solmate/auth/Owned.sol";
import "@solmate/utils/ReentrancyGuard.sol";

import "./InputChecker.sol";

/// @title AddressManager
/// @notice A contract that handles a whitelist of addresses and their indexes.
/// @dev We assume no more than 65535 addresses will be added to the directory.
contract AddressManager is Owned, ReentrancyGuard {
    using InputChecker for address;

    event AddressAdded(address address_added);

    event AddressRemovedFromWhitelist(address address_removed);

    event AddressWhitelisted(address address_whitelisted);

    error AddressAlreadyAddedError(address _address);

    error AddressNotAddedError(address _address);

    mapping(address => uint16) private _directory;

    mapping(uint16 => address) private _inverseDirectory;

    mapping(address => bool) private _whitelist;

    uint16 private _lastAdded;

    constructor(address[] memory _original) Owned(tx.origin) {
        uint256 total = _original.length;
        for (uint256 i; i < total;) {
            _add(_original[i]);
            unchecked {
                ++i;
            }
        }
    }

    /// @notice Adds an address to the directory. If it already exists,
    ///        reverts. It assumes it's whitelisted.
    /// @param _entry The address to add.
    /// @return The index of the address in the directory.
    function add(address _entry) external payable onlyOwner returns (uint16) {
        return _add(_entry);
    }

    /// @notice Whitelist an address that's already part of the directory.
    /// @param _entry The address to whitelist.
    function addToWhitelist(address _entry) external payable onlyOwner {
        if (_directory[_entry] == 0) {
            revert AddressNotAddedError(_entry);
        }
        _whitelist[_entry] = true;

        emit AddressWhitelisted(_entry);
    }

    /// @notice Removes an address from the whitelist. We still keep it
    ///         in the directory since this mapping is relevant across time.
    /// @param _entry The address to remove from the whitelist.
    function removeFromWhitelist(address _entry) external payable onlyOwner {
        _whitelist[_entry] = false;

        emit AddressRemovedFromWhitelist(_entry);
    }

    /// @param _address The address to get the index for.
    /// @return The index for a given address.
    function addressToIndex(address _address) external view returns (uint16) {
        return _directory[_address];
    }

    /// @param _index The index to get the address for.
    /// @return The address for a given index.
    function indexToAddress(uint16 _index) external view returns (address) {
        return _inverseDirectory[_index];
    }

    /// @param _entry The address to check if it's whitelisted.
    /// @return Whether the address is whitelisted or not.
    function isWhitelisted(address _entry) external view returns (bool) {
        return _whitelist[_entry];
    }

    function _add(address _entry) private returns (uint16) {
        _entry.checkNotZero();
        if (_directory[_entry] != 0) {
            revert AddressAlreadyAddedError(_entry);
        }
        unchecked {
            ++_lastAdded;
        }
        _directory[_entry] = _lastAdded;
        _inverseDirectory[_lastAdded] = _entry;
        _whitelist[_entry] = true;

        emit AddressAdded(_entry);

        return _lastAdded;
    }
}
// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.21;

/// @title InputChecker
/// @author Florida St
/// @notice Some basic input checks.
library InputChecker {
    error AddressZeroError();

    function checkNotZero(address _address) internal pure {
        if (_address == address(0)) {
            revert AddressZeroError();
        }
    }
}
// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.21;

import "@solmate/auth/Owned.sol";
import "@solmate/tokens/ERC721.sol";
import "@solmate/utils/FixedPointMathLib.sol";
import "@solmate/utils/ReentrancyGuard.sol";

import "../interfaces/ILiquidationHandler.sol";
import "../interfaces/loans/IMultiSourceLoan.sol";
import "./callbacks/CallbackHandler.sol";
import "./InputChecker.sol";

/// @title Liquidation Handler
/// @author Florida St
/// @notice Liquidation Handler for defaulted loans
abstract contract LiquidationHandler is ILiquidationHandler, ReentrancyGuard, CallbackHandler {
    using InputChecker for address;
    using FixedPointMathLib for uint256;

    uint48 public constant MIN_AUCTION_DURATION = 3 days;
    uint48 public constant MAX_AUCTION_DURATION = 7 days;
    uint256 public constant MIN_BID_LIQUIDATION = 50;
    uint256 private constant _BPS = 10000;

    /// @notice Duration of the auction when a loan defaults requires a liquidation.
    uint48 internal _liquidationAuctionDuration = 3 days;

    /// @notice Liquidator used defaulted loans that requires liquidation.
    address internal _loanLiquidator;

    event MinBidLiquidationUpdated(uint256 newMinBid);

    event LoanSentToLiquidator(uint256 loanId, address liquidator);

    event LoanForeclosed(uint256 loanId);

    event LiquidationContractUpdated(address liquidator);

    event LiquidationAuctionDurationUpdated(uint256 newDuration);

    error LiquidatorOnlyError(address _liquidator);

    error LoanNotDueError(uint256 _expirationTime);

    error InvalidDurationError();

    /// @notice Constructor
    /// @param __owner The owner of the contract
    /// @param _updateWaitTime The time to wait before a new owner can be set
    /// @param __loanLiquidator The liquidator contract
    /// @param __protocolFee The protocol fee
    constructor(address __owner, uint256 _updateWaitTime, address __loanLiquidator, ProtocolFee memory __protocolFee)
        CallbackHandler(__owner, _updateWaitTime, __protocolFee)
    {
        __loanLiquidator.checkNotZero();

        _loanLiquidator = __loanLiquidator;
    }

    modifier onlyLiquidator() {
        if (msg.sender != address(_loanLiquidator)) {
            revert LiquidatorOnlyError(address(_loanLiquidator));
        }
        _;
    }
    /// @inheritdoc ILiquidationHandler

    function getLiquidator() external view override returns (address) {
        return _loanLiquidator;
    }

    /// @inheritdoc ILiquidationHandler
    function updateLiquidationContract(address __loanLiquidator) external override onlyOwner {
        __loanLiquidator.checkNotZero();
        _loanLiquidator = __loanLiquidator;

        emit LiquidationContractUpdated(__loanLiquidator);
    }

    /// @inheritdoc ILiquidationHandler
    function updateLiquidationAuctionDuration(uint48 _newDuration) external override onlyOwner {
        if (_newDuration < MIN_AUCTION_DURATION || _newDuration > MAX_AUCTION_DURATION) {
            revert InvalidDurationError();
        }
        _liquidationAuctionDuration = _newDuration;

        emit LiquidationAuctionDurationUpdated(_newDuration);
    }

    /// @inheritdoc ILiquidationHandler
    function getLiquidationAuctionDuration() external view override returns (uint48) {
        return _liquidationAuctionDuration;
    }

    function _liquidateLoan(uint256 _loanId, IMultiSourceLoan.Loan calldata _loan, bool _canClaim)
        internal
        returns (bool liquidated, bytes memory liquidation)
    {
        uint256 expirationTime;
        unchecked {
            expirationTime = _loan.startTime + _loan.duration;
        }
        if (expirationTime > block.timestamp) {
            revert LoanNotDueError(expirationTime);
        }
        if (_canClaim) {
            ERC721(_loan.nftCollateralAddress).transferFrom(
                address(this), _loan.tranche[0].lender, _loan.nftCollateralTokenId
            );
            emit LoanForeclosed(_loanId);

            liquidated = true;
        } else {
            address liquidator = _loanLiquidator;
            ERC721(_loan.nftCollateralAddress).transferFrom(address(this), liquidator, _loan.nftCollateralTokenId);
            liquidation = ILoanLiquidator(liquidator).liquidateLoan(
                _loanId,
                _loan.nftCollateralAddress,
                _loan.nftCollateralTokenId,
                _loan.principalAddress,
                _liquidationAuctionDuration,
                _loan.principalAmount.mulDivDown(MIN_BID_LIQUIDATION, _BPS),
                msg.sender
            );

            emit LoanSentToLiquidator(_loanId, liquidator);
        }
    }
}
// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.21;

import "../interfaces/IMulticall.sol";

/// @title Multicall
/// @author Florida St
/// @notice Base implementation for multicall.
abstract contract Multicall is IMulticall {
    function multicall(bytes[] calldata data) external payable override returns (bytes[] memory results) {
        results = new bytes[](data.length);
        bool success;
        uint256 totalCalls = data.length;
        for (uint256 i = 0; i < totalCalls;) {
            //slither-disable-next-line calls-loop,delegatecall-loop
            (success, results[i]) = address(this).delegatecall(data[i]);
            if (!success) {
                revert MulticallFailed(i, results[i]);
            }

            unchecked {
                ++i;
            }
        }
    }
}
// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.21;

import "../utils/TwoStepOwned.sol";
import "../InputChecker.sol";
import "../utils/WithProtocolFee.sol";
import "../../interfaces/callbacks/ILoanCallback.sol";

/// @title CallbackHandler
/// @author Florida St
/// @notice Handle callbacks from the MultiSourceLoan contract.
abstract contract CallbackHandler is WithProtocolFee {
    using InputChecker for address;

    /// @notice For security reasons we only allow a whitelisted set of callback contracts.
    mapping(address callbackContract => bool isWhitelisted) internal _isWhitelistedCallbackContract;

    address private immutable _multiSourceLoan;

    event WhitelistedCallbackContractAdded(address contractAdded);
    event WhitelistedCallbackContractRemoved(address contractRemoved);

    constructor(address __owner, uint256 _minWaitTime, ProtocolFee memory __protocolFee)
        WithProtocolFee(__owner, _minWaitTime, __protocolFee)
    {}

    /// @notice Add a whitelisted callback contract.
    /// @param _contract Address of the contract.
    function addWhitelistedCallbackContract(address _contract) external onlyOwner {
        _contract.checkNotZero();
        _isWhitelistedCallbackContract[_contract] = true;

        emit WhitelistedCallbackContractAdded(_contract);
    }

    /// @notice Remove a whitelisted callback contract.
    /// @param _contract Address of the contract.
    function removeWhitelistedCallbackContract(address _contract) external onlyOwner {
        _isWhitelistedCallbackContract[_contract] = false;

        emit WhitelistedCallbackContractRemoved(_contract);
    }

    /// @return Whether a callback contract is whitelisted
    function isWhitelistedCallbackContract(address _contract) external view returns (bool) {
        return _isWhitelistedCallbackContract[_contract];
    }

    /// @notice Handle the afterPrincipalTransfer callback.
    /// @param _loan Loan.
    /// @param _callbackAddress Callback address.
    /// @param _callbackData Callback data.
    /// @param _fee Fee.
    function handleAfterPrincipalTransferCallback(
        IMultiSourceLoan.Loan memory _loan,
        address _callbackAddress,
        bytes memory _callbackData,
        uint256 _fee
    ) internal {
        if (
            !_isWhitelistedCallbackContract[_callbackAddress]
                || ILoanCallback(_callbackAddress).afterPrincipalTransfer(_loan, _fee, _callbackData)
                    != ILoanCallback.afterPrincipalTransfer.selector
        ) {
            revert ILoanCallback.InvalidCallbackError();
        }
    }

    /// @notice Handle the afterNFTTransfer callback.
    /// @param _loan Loan.
    /// @param _callbackAddress Callback address.
    /// @param _callbackData Callback data.
    function handleAfterNFTTransferCallback(
        IMultiSourceLoan.Loan memory _loan,
        address _callbackAddress,
        bytes calldata _callbackData
    ) internal {
        if (
            !_isWhitelistedCallbackContract[_callbackAddress]
                || ILoanCallback(_callbackAddress).afterNFTTransfer(_loan, _callbackData)
                    != ILoanCallback.afterNFTTransfer.selector
        ) {
            revert ILoanCallback.InvalidCallbackError();
        }
    }
}
// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.21;

import "@openzeppelin/utils/cryptography/MessageHashUtils.sol";
import "@openzeppelin/interfaces/IERC1271.sol";

import "@solmate/auth/Owned.sol";
import "@solmate/tokens/ERC721.sol";
import "@solmate/utils/FixedPointMathLib.sol";

import "../../interfaces/loans/IBaseLoan.sol";
import "../utils/Hash.sol";
import "../AddressManager.sol";
import "../LiquidationHandler.sol";

/// @title BaseLoan
/// @author Florida St
/// @notice Base implementation that we expect all loans to share. Offers can either be
///         for new loans or renegotiating existing ones.
///         Offers are signed off-chain.
///         Offers have a nonce associated that is used for cancelling and
///         marking as executed.
abstract contract BaseLoan is ERC721TokenReceiver, IBaseLoan, LiquidationHandler {
    using FixedPointMathLib for uint256;
    using InputChecker for address;
    using MessageHashUtils for bytes32;

    /// @notice Used in compliance with EIP712
    uint256 internal immutable INITIAL_CHAIN_ID;
    bytes32 public immutable INITIAL_DOMAIN_SEPARATOR;

    bytes4 internal constant MAGICVALUE_1271 = 0x1626ba7e;

    /// @notice Precision used for calculating interests.
    uint256 internal constant _PRECISION = 10000;

    bytes public constant VERSION = "3";

    /// @notice Minimum improvement (in BPS) required for a strict improvement.
    uint256 internal _minImprovementApr = 1000;

    string public name;

    /// @notice Total number of loans issued. Given it's a serial value, we use it
    ///         as loan id.
    uint256 public override getTotalLoansIssued;

    /// @notice Offer capacity
    mapping(address user => mapping(uint256 offerId => uint256 used)) internal _used;

    /// @notice Used for validate off chain maker offers / canceling one
    mapping(address user => mapping(uint256 offerId => bool notActive)) public isOfferCancelled;
    /// @notice Used for validating off chain maker offers / canceling all
    mapping(address user => uint256 minOfferId) public minOfferId;

    /// @notice Used in a similar way as `isOfferCancelled` to handle renegotiations.
    mapping(address user => mapping(uint256 renegotiationIf => bool notActive)) public isRenegotiationOfferCancelled;

    /// @notice Loans are only denominated in whitelisted addresses. Within each struct,
    ///         we save those as their `uint` representation.
    AddressManager internal immutable _currencyManager;

    /// @notice Only whilteslited collections are accepted as collateral. Within each struct,
    ///         we save those as their `uint` representation.
    AddressManager internal immutable _collectionManager;

    event OfferCancelled(address lender, uint256 offerId);

    event AllOffersCancelled(address lender, uint256 minOfferId);

    event RenegotiationOfferCancelled(address lender, uint256 renegotiationId);

    event MinAprImprovementUpdated(uint256 _minimum);

    error CancelledOrExecutedOfferError(address _lender, uint256 _offerId);

    error ExpiredOfferError(uint256 _expirationTime);

    error LowOfferIdError(address _lender, uint256 _newMinOfferId, uint256 _minOfferId);

    error LowRenegotiationOfferIdError(address _lender, uint256 _newMinRenegotiationOfferId, uint256 _minOfferId);

    error ZeroInterestError();

    error InvalidSignatureError();

    error CurrencyNotWhitelistedError();

    error CollectionNotWhitelistedError();

    error MaxCapacityExceededError();

    error InvalidLoanError(uint256 _loanId);

    error NotStrictlyImprovedError();

    error InvalidAmountError(uint256 _amount, uint256 _principalAmount);

    /// @notice Constructor
    /// @param _name The name of the loan contract
    /// @param currencyManager The address of the currency manager
    /// @param collectionManager The address of the collection manager
    /// @param protocolFee The protocol fee
    /// @param loanLiquidator The liquidator contract
    /// @param owner The owner of the contract
    /// @param minWaitTime The time to wait before a new owner can be set
    constructor(
        string memory _name,
        address currencyManager,
        address collectionManager,
        ProtocolFee memory protocolFee,
        address loanLiquidator,
        address owner,
        uint256 minWaitTime
    ) LiquidationHandler(owner, minWaitTime, loanLiquidator, protocolFee) {
        name = _name;
        currencyManager.checkNotZero();
        collectionManager.checkNotZero();

        _currencyManager = AddressManager(currencyManager);
        _collectionManager = AddressManager(collectionManager);

        INITIAL_CHAIN_ID = block.chainid;
        INITIAL_DOMAIN_SEPARATOR = _computeDomainSeparator();
    }

    /// @return The minimum improvement for a loan to be considered strictly better.
    function getMinImprovementApr() external view returns (uint256) {
        return _minImprovementApr;
    }

    /// @notice Updates the minimum improvement for a loan to be considered strictly better.
    ///         Only the owner can call this function.
    /// @param _newMinimum The new minimum improvement.
    function updateMinImprovementApr(uint256 _newMinimum) external onlyOwner {
        _minImprovementApr = _newMinimum;

        emit MinAprImprovementUpdated(_minImprovementApr);
    }

    /// @return Address of the currency manager.
    function getCurrencyManager() external view returns (address) {
        return address(_currencyManager);
    }

    /// @return Address of the collection manager.
    function getCollectionManager() external view returns (address) {
        return address(_collectionManager);
    }

    /// @inheritdoc IBaseLoan
    function cancelOffer(uint256 _offerId) external {
        address user = msg.sender;
        isOfferCancelled[user][_offerId] = true;

        emit OfferCancelled(user, _offerId);
    }

    /// @inheritdoc IBaseLoan
    function cancelAllOffers(uint256 _minOfferId) external virtual {
        address user = msg.sender;
        uint256 currentMinOfferId = minOfferId[user];
        if (currentMinOfferId >= _minOfferId) {
            revert LowOfferIdError(user, _minOfferId, currentMinOfferId);
        }
        minOfferId[user] = _minOfferId;

        emit AllOffersCancelled(user, _minOfferId);
    }

    /// @inheritdoc IBaseLoan
    function cancelRenegotiationOffer(uint256 _renegotiationId) external virtual {
        address lender = msg.sender;
        isRenegotiationOfferCancelled[lender][_renegotiationId] = true;

        emit RenegotiationOfferCancelled(lender, _renegotiationId);
    }

    /// @notice Returns the remaining capacity for a given loan offer.
    /// @param _lender The address of the lender.
    /// @param _offerId The id of the offer.
    /// @return The amount lent out.
    function getUsedCapacity(address _lender, uint256 _offerId) external view returns (uint256) {
        return _used[_lender][_offerId];
    }

    /// @notice Get the domain separator requried to comply with EIP-712.
    function DOMAIN_SEPARATOR() public view returns (bytes32) {
        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : _computeDomainSeparator();
    }

    /// @notice Call when issuing a new loan to get/set a unique serial id.
    /// @dev This id should never be 0.
    /// @return The new loan id.
    function _getAndSetNewLoanId() internal returns (uint256) {
        unchecked {
            return ++getTotalLoansIssued;
        }
    }

    /// @notice Compute domain separator for EIP-712.
    /// @return The domain separator.
    function _computeDomainSeparator() private view returns (bytes32) {
        return keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(name)),
                keccak256(VERSION),
                block.chainid,
                address(this)
            )
        );
    }
}
// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.21;

import "@delegate/IDelegateRegistry.sol";
import "@openzeppelin/utils/cryptography/ECDSA.sol";
import "@solmate/tokens/ERC20.sol";
import "@solmate/tokens/ERC721.sol";
import "@solmate/utils/FixedPointMathLib.sol";
import "@solmate/utils/ReentrancyGuard.sol";
import "@solmate/utils/SafeTransferLib.sol";

import "../../interfaces/validators/IOfferValidator.sol";
import "../../interfaces/INFTFlashAction.sol";
import "../../interfaces/loans/ILoanManager.sol";
import "../../interfaces/loans/ILoanManagerRegistry.sol";
import "../../interfaces/loans/IMultiSourceLoan.sol";
import "../utils/Hash.sol";
import "../utils/Interest.sol";
import "../Multicall.sol";
import "./BaseLoan.sol";

/// @title MultiSourceLoan (v3)
/// @author Florida St
/// @notice Loan contract that allows for multiple tranches with different
///         seniorities. Each loan is collateralized by an NFT. Loans have a duration,
///         principal, and APR. Loans can be refinanced automatically by lenders (if terms
///         are improved). Borrowers can also get renegotiation offers which they can then
///         accept. If a loan is not repaid by its end time, it's considered to have defaulted.
///         If it had only one lender behind it, then the lender (unless it's a pool), can claim
///         the collateral. If there are multiple lenders or the sole lender is a pool, then there's
///         a liquidation process (run by an instance of `ILoanLiquidator`).
contract MultiSourceLoan is IMultiSourceLoan, Multicall, ReentrancyGuard, BaseLoan {
    using FixedPointMathLib for uint256;
    using Hash for ExecutionData;
    using Hash for Loan;
    using Hash for LoanOffer;
    using Hash for SignableRepaymentData;
    using Hash for RenegotiationOffer;
    using InputChecker for address;
    using Interest for uint256;
    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;
    using SafeTransferLib for ERC20;

    /// @notice Loan Id to hash
    mapping(uint256 loanId => bytes32 loanHash) private _loans;

    /// This is used in _getMinTranchePrincipal.
    uint256 private constant _MAX_RATIO_TRANCHE_MIN_PRINCIPAL = 2;

    /// @notice Maximum number of tranches per loan
    uint256 public immutable getMaxTranches;

    /// @notice delegate registry
    address public immutable getDelegateRegistry;

    /// @notice Contract to execute flash actions.
    address public getFlashActionContract;

    /// @notice Loan manager registry (we currently have Gondi's pools)
    ILoanManagerRegistry public immutable getLoanManagerRegistry;

    /// @notice Min lock period for a tranche
    uint256 private _minLockPeriod;

    error InvalidParametersError();
    error MismatchError();
    error InvalidCollateralIdError();
    error InvalidMethodError();
    error InvalidAddressesError();
    error InvalidCallerError();
    error InvalidTrancheError();
    error InvalidRenegotiationOfferError();
    error TooManyTranchesError();
    error LoanExpiredError();
    error NFTNotReturnedError();
    error TrancheCannotBeRefinancedError(uint256 minTimestamp);
    error LoanLockedError();

    /// @param loanLiquidator Address of the liquidator contract.
    /// @param protocolFee Protocol fee charged on gains.
    /// @param currencyManager Address of the currency manager.
    /// @param collectionManager Address of the collection manager.
    /// @param maxTranches Maximum number of tranches per loan.
    /// @param minLockPeriod Minimum lock period for a tranche/loan.
    /// @param delegateRegistry Address of the delegate registry (Delegate.xyz).
    /// @param loanManagerRegistry Address of the loan manager registry.
    /// @param flashActionContract Address of the flash action contract.
    /// @param minWaitTime The time to wait before a new owner can be set.
    constructor(
        address loanLiquidator,
        ProtocolFee memory protocolFee,
        address currencyManager,
        address collectionManager,
        uint256 maxTranches,
        uint256 minLockPeriod,
        address delegateRegistry,
        address loanManagerRegistry,
        address flashActionContract,
        uint256 minWaitTime
    )
        BaseLoan(
            "GONDI_MULTI_SOURCE_LOAN",
            currencyManager,
            collectionManager,
            protocolFee,
            loanLiquidator,
            tx.origin,
            minWaitTime
        )
    {
        loanLiquidator.checkNotZero();

        _minLockPeriod = minLockPeriod;
        getMaxTranches = maxTranches;
        getDelegateRegistry = delegateRegistry;
        getFlashActionContract = flashActionContract;
        getLoanManagerRegistry = ILoanManagerRegistry(loanManagerRegistry);
    }

    /// @inheritdoc IMultiSourceLoan
    function emitLoan(LoanExecutionData calldata _loanExecutionData)
        external
        nonReentrant
        returns (uint256, Loan memory)
    {
        address borrower = _loanExecutionData.borrower;
        ExecutionData calldata executionData = _loanExecutionData.executionData;
        (address principalAddress, address nftCollateralAddress) = _getAddressesFromExecutionData(executionData);

        OfferExecution[] calldata offerExecution = executionData.offerExecution;

        _validateExecutionData(_loanExecutionData, borrower);
        _checkWhitelists(principalAddress, nftCollateralAddress);

        (uint256 loanId, uint256[] memory offerIds, Loan memory loan, uint256 totalFee) =
        _processOffersFromExecutionData(
            borrower,
            executionData.principalReceiver,
            principalAddress,
            nftCollateralAddress,
            executionData.tokenId,
            executionData.duration,
            offerExecution
        );

        if (_hasCallback(executionData.callbackData)) {
            handleAfterPrincipalTransferCallback(loan, msg.sender, executionData.callbackData, totalFee);
        }

        ERC721(nftCollateralAddress).transferFrom(borrower, address(this), executionData.tokenId);

        _loans[loanId] = loan.hash();
        emit LoanEmitted(loanId, offerIds, loan, totalFee);

        return (loanId, loan);
    }

    /// @inheritdoc IMultiSourceLoan
    function refinanceFull(
        RenegotiationOffer calldata _renegotiationOffer,
        Loan memory _loan,
        bytes calldata _renegotiationOfferSignature
    ) external nonReentrant returns (uint256, Loan memory) {
        _baseLoanChecks(_renegotiationOffer.loanId, _loan);
        _baseRenegotiationChecks(_renegotiationOffer, _loan);

        if (_renegotiationOffer.trancheIndex.length != _loan.tranche.length) {
            revert InvalidRenegotiationOfferError();
        }

        bool lenderInitiated = msg.sender == _renegotiationOffer.lender;
        uint256 netNewLender = _renegotiationOffer.principalAmount - _renegotiationOffer.fee;
        uint256 totalAccruedInterest;
        uint256 totalAnnualInterest;

        /// @dev If it's lender initiated, needs to be strictly better.
        if (lenderInitiated) {
            (totalAccruedInterest, totalAnnualInterest,) =
                _processOldTranchesFull(_renegotiationOffer, _loan, lenderInitiated, 0);
            if (_isLoanLocked(_loan.startTime, _loan.duration)) {
                revert LoanLockedError();
            }
            _checkStrictlyBetter(
                _renegotiationOffer.principalAmount,
                _loan.principalAmount,
                _renegotiationOffer.duration + block.timestamp,
                _loan.duration + _loan.startTime,
                _renegotiationOffer.aprBps,
                totalAnnualInterest / _loan.principalAmount,
                _renegotiationOffer.fee
            );
            if (_renegotiationOffer.principalAmount > _loan.principalAmount) {
                ERC20(_loan.principalAddress).safeTransferFrom(
                    _renegotiationOffer.lender,
                    _loan.borrower,
                    _renegotiationOffer.principalAmount - _loan.principalAmount
                );
            }
        } else if (msg.sender != _loan.borrower) {
            revert InvalidCallerError();
        } else {
            (totalAccruedInterest, totalAnnualInterest, netNewLender) =
                _processOldTranchesFull(_renegotiationOffer, _loan, lenderInitiated, netNewLender);
            /// @notice Borrowers clears interest
            _checkSignature(_renegotiationOffer.lender, _renegotiationOffer.hash(), _renegotiationOfferSignature);
            if (netNewLender > 0) {
                ERC20(_loan.principalAddress).safeTransferFrom(_renegotiationOffer.lender, _loan.borrower, netNewLender);
            }
            totalAccruedInterest = 0;
        }
        uint256 newLoanId = _getAndSetNewLoanId();
        Tranche[] memory newTranche = new Tranche[](1);
        newTranche[0] = Tranche(
            newLoanId,
            0,
            _renegotiationOffer.principalAmount,
            _renegotiationOffer.lender,
            totalAccruedInterest,
            block.timestamp,
            _renegotiationOffer.aprBps
        );
        _loan.tranche = newTranche;
        _loan.startTime = block.timestamp;
        _loan.duration = _renegotiationOffer.duration;
        _loan.principalAmount = _renegotiationOffer.principalAmount;

        _loans[newLoanId] = _loan.hash();
        delete _loans[_renegotiationOffer.loanId];

        emit LoanRefinanced(
            _renegotiationOffer.renegotiationId, _renegotiationOffer.loanId, newLoanId, _loan, _renegotiationOffer.fee
        );

        return (newLoanId, _loan);
    }

    /// @inheritdoc IMultiSourceLoan
    function refinancePartial(RenegotiationOffer calldata _renegotiationOffer, Loan memory _loan)
        external
        nonReentrant
        returns (uint256, Loan memory)
    {
        if (msg.sender != _renegotiationOffer.lender) {
            revert InvalidCallerError();
        }

        if (_isLoanLocked(_loan.startTime, _loan.duration)) {
            revert LoanLockedError();
        }
        if (_renegotiationOffer.trancheIndex.length == 0) {
            revert InvalidRenegotiationOfferError();
        }

        uint256 loanId = _renegotiationOffer.loanId;
        _baseLoanChecks(loanId, _loan);
        _baseRenegotiationChecks(_renegotiationOffer, _loan);

        uint256 newLoanId = _getAndSetNewLoanId();
        uint256 totalProtocolFee;
        uint256 totalAnnualInterest;
        uint256 totalRefinanced;
        /// @dev bring to mem
        uint256 minImprovementApr = _minImprovementApr;
        /// @dev We iterate over all tranches to execute repayments.
        uint256 totalTranchesRenegotiated = _renegotiationOffer.trancheIndex.length;
        for (uint256 i; i < totalTranchesRenegotiated;) {
            uint256 index = _renegotiationOffer.trancheIndex[i];
            if (index >= _loan.tranche.length) {
                revert InvalidRenegotiationOfferError();
            }
            Tranche memory tranche = _loan.tranche[index];
            _checkTrancheStrictly(true, tranche.aprBps, _renegotiationOffer.aprBps, minImprovementApr);
            (uint256 accruedInterest, uint256 thisProtocolFee,) = _processOldTranche(
                _renegotiationOffer.lender,
                _loan.borrower,
                _loan.principalAddress,
                tranche,
                _loan.startTime + _loan.duration,
                _loan.protocolFee,
                type(uint256).max
            );
            unchecked {
                totalRefinanced += tranche.principalAmount;
                totalAnnualInterest += tranche.principalAmount * tranche.aprBps;
                totalProtocolFee += thisProtocolFee;
            }

            tranche.loanId = newLoanId;
            tranche.lender = _renegotiationOffer.lender;
            tranche.accruedInterest = accruedInterest;
            tranche.startTime = block.timestamp;
            tranche.aprBps = _renegotiationOffer.aprBps;
            unchecked {
                ++i;
            }
        }

        if (_renegotiationOffer.principalAmount != totalRefinanced) {
            revert InvalidRenegotiationOfferError();
        }
        _handleProtocolFeeForFee(
            _loan.principalAddress, _renegotiationOffer.lender, totalProtocolFee, _protocolFee.recipient
        );

        _loans[newLoanId] = _loan.hash();
        delete _loans[loanId];

        /// @dev Here reneg fee is always 0
        emit LoanRefinanced(_renegotiationOffer.renegotiationId, loanId, newLoanId, _loan, 0);

        return (newLoanId, _loan);
    }

    /// @inheritdoc IMultiSourceLoan
    function refinanceFromLoanExecutionData(
        uint256 _loanId,
        Loan calldata _loan,
        LoanExecutionData calldata _loanExecutionData
    ) external nonReentrant returns (uint256, Loan memory) {
        if (msg.sender != _loan.borrower) {
            revert InvalidCallerError();
        }
        _baseLoanChecks(_loanId, _loan);

        ExecutionData calldata executionData = _loanExecutionData.executionData;
        /// @dev We ignore the borrower in executionData, and used existing one.
        address borrower = _loan.borrower;
        (address principalAddress, address nftCollateralAddress) = _getAddressesFromExecutionData(executionData);

        OfferExecution[] calldata offerExecution = executionData.offerExecution;

        _validateExecutionData(_loanExecutionData, borrower);
        _checkWhitelists(principalAddress, nftCollateralAddress);

        if (_loan.principalAddress != principalAddress || _loan.nftCollateralAddress != nftCollateralAddress) {
            revert InvalidAddressesError();
        }
        if (_loan.nftCollateralTokenId != executionData.tokenId) {
            revert InvalidCollateralIdError();
        }

        /// @dev We first process the incoming offers so borrower gets the capital. After that, we process repayments.
        ///      NFT doesn't need to be transfered (it was already in escrow)
        (uint256 newLoanId, uint256[] memory offerIds, Loan memory loan, uint256 totalFee) =
        _processOffersFromExecutionData(
            borrower,
            executionData.principalReceiver,
            principalAddress,
            nftCollateralAddress,
            executionData.tokenId,
            executionData.duration,
            offerExecution
        );
        _processRepayments(_loan);

        emit LoanRefinancedFromNewOffers(_loanId, newLoanId, loan, offerIds, totalFee);

        _loans[newLoanId] = loan.hash();
        delete _loans[_loanId];

        return (newLoanId, loan);
    }

    /// @inheritdoc IMultiSourceLoan
    function addNewTranche(
        RenegotiationOffer calldata _renegotiationOffer,
        Loan memory _loan,
        bytes calldata _renegotiationOfferSignature
    ) external nonReentrant returns (uint256, Loan memory) {
        if (msg.sender != _loan.borrower) {
            revert InvalidCallerError();
        }
        uint256 loanId = _renegotiationOffer.loanId;

        _baseLoanChecks(loanId, _loan);
        _baseRenegotiationChecks(_renegotiationOffer, _loan);
        _checkSignature(_renegotiationOffer.lender, _renegotiationOffer.hash(), _renegotiationOfferSignature);

        if (_renegotiationOffer.trancheIndex.length != 1 || _renegotiationOffer.trancheIndex[0] != _loan.tranche.length)
        {
            revert InvalidRenegotiationOfferError();
        }

        if (_loan.tranche.length == getMaxTranches) {
            revert TooManyTranchesError();
        }

        uint256 newLoanId = _getAndSetNewLoanId();
        Loan memory loanWithTranche = _addNewTranche(newLoanId, _loan, _renegotiationOffer);
        _loans[newLoanId] = loanWithTranche.hash();
        delete _loans[loanId];

        ERC20(_loan.principalAddress).safeTransferFrom(
            _renegotiationOffer.lender, _loan.borrower, _renegotiationOffer.principalAmount - _renegotiationOffer.fee
        );
        if (_renegotiationOffer.fee != 0) {
            /// @dev Cached
            ERC20(_loan.principalAddress).safeTransferFrom(
                _renegotiationOffer.lender,
                _protocolFee.recipient,
                _renegotiationOffer.fee.mulDivUp(_loan.protocolFee, _PRECISION)
            );
        }

        emit LoanRefinanced(
            _renegotiationOffer.renegotiationId, loanId, newLoanId, loanWithTranche, _renegotiationOffer.fee
        );

        return (newLoanId, loanWithTranche);
    }

    /// @inheritdoc IMultiSourceLoan
    function repayLoan(LoanRepaymentData calldata _repaymentData) external override nonReentrant {
        uint256 loanId = _repaymentData.data.loanId;
        Loan calldata loan = _repaymentData.loan;
        /// @dev If the caller is not the borrower itself, check the signature to avoid someone else forcing an unwanted repayment.
        if (msg.sender != loan.borrower) {
            _checkSignature(loan.borrower, _repaymentData.data.hash(), _repaymentData.borrowerSignature);
        }

        _baseLoanChecks(loanId, loan);

        /// @dev Unlikely this is used outside of the callback with a seaport sell, but leaving here in case that's not correct.
        if (_repaymentData.data.shouldDelegate) {
            IDelegateRegistry(getDelegateRegistry).delegateERC721(
                loan.borrower, loan.nftCollateralAddress, loan.nftCollateralTokenId, bytes32(""), true
            );
        }

        ERC721(loan.nftCollateralAddress).transferFrom(address(this), loan.borrower, loan.nftCollateralTokenId);
        /// @dev After returning the NFT to the borrower, check if there's an action to be taken (eg: sell it to cover repayment).
        if (_hasCallback(_repaymentData.data.callbackData)) {
            handleAfterNFTTransferCallback(loan, msg.sender, _repaymentData.data.callbackData);
        }

        (uint256 totalRepayment, uint256 totalProtocolFee) = _processRepayments(loan);

        emit LoanRepaid(loanId, totalRepayment, totalProtocolFee);

        /// @dev Reclaim space.
        delete _loans[loanId];
    }

    /// @inheritdoc IMultiSourceLoan
    function liquidateLoan(uint256 _loanId, Loan calldata _loan)
        external
        override
        nonReentrant
        returns (bytes memory)
    {
        if (_loan.hash() != _loans[_loanId]) {
            revert InvalidLoanError(_loanId);
        }
        (bool liquidated, bytes memory liquidation) = _liquidateLoan(
            _loanId, _loan, _loan.tranche.length == 1 && !getLoanManagerRegistry.isLoanManager(_loan.tranche[0].lender)
        );
        if (liquidated) {
            delete _loans[_loanId];
        }
        return liquidation;
    }

    /// @inheritdoc IMultiSourceLoan
    function loanLiquidated(uint256 _loanId, Loan calldata _loan) external override onlyLiquidator {
        if (_loan.hash() != _loans[_loanId]) {
            revert InvalidLoanError(_loanId);
        }

        emit LoanLiquidated(_loanId);

        /// @dev Reclaim space.
        delete _loans[_loanId];
    }

    /// @inheritdoc IMultiSourceLoan
    function delegate(uint256 _loanId, Loan calldata loan, address _delegate, bytes32 _rights, bool _value) external {
        if (loan.hash() != _loans[_loanId]) {
            revert InvalidLoanError(_loanId);
        }
        if (msg.sender != loan.borrower) {
            revert InvalidCallerError();
        }
        IDelegateRegistry(getDelegateRegistry).delegateERC721(
            _delegate, loan.nftCollateralAddress, loan.nftCollateralTokenId, _rights, _value
        );

        emit Delegated(_loanId, _delegate, _rights, _value);
    }

    /// @inheritdoc IMultiSourceLoan
    function revokeDelegate(address _delegate, address _collection, uint256 _tokenId, bytes32 _rights) external {
        if (ERC721(_collection).ownerOf(_tokenId) == address(this)) {
            revert InvalidMethodError();
        }

        IDelegateRegistry(getDelegateRegistry).delegateERC721(_delegate, _collection, _tokenId, _rights, false);

        emit RevokeDelegate(_delegate, _collection, _tokenId, _rights);
    }

    /// @inheritdoc IMultiSourceLoan
    function getMinLockPeriod() external view returns (uint256) {
        return _minLockPeriod;
    }

    /// @inheritdoc IMultiSourceLoan
    function setMinLockPeriod(uint256 __minLockPeriod) external onlyOwner {
        _minLockPeriod = __minLockPeriod;

        emit MinLockPeriodUpdated(__minLockPeriod);
    }

    /// @inheritdoc IMultiSourceLoan
    function getLoanHash(uint256 _loanId) external view returns (bytes32) {
        return _loans[_loanId];
    }

    /// @inheritdoc IMultiSourceLoan
    function executeFlashAction(uint256 _loanId, Loan calldata _loan, address _target, bytes calldata _data)
        external
        nonReentrant
    {
        if (_loan.hash() != _loans[_loanId]) {
            revert InvalidLoanError(_loanId);
        }
        if (msg.sender != _loan.borrower) {
            revert InvalidCallerError();
        }
        address flashActionContract = getFlashActionContract;
        ERC721(_loan.nftCollateralAddress).transferFrom(address(this), flashActionContract, _loan.nftCollateralTokenId);
        INFTFlashAction(flashActionContract).execute(
            _loan.nftCollateralAddress, _loan.nftCollateralTokenId, _target, _data
        );

        if (ERC721(_loan.nftCollateralAddress).ownerOf(_loan.nftCollateralTokenId) != address(this)) {
            revert NFTNotReturnedError();
        }

        emit FlashActionExecuted(_loanId, _target, _data);
    }

    /// @inheritdoc IMultiSourceLoan
    function setFlashActionContract(address _newFlashActionContract) external onlyOwner {
        getFlashActionContract = _newFlashActionContract;

        emit FlashActionContractUpdated(_newFlashActionContract);
    }

    /// @notice Process repayments for tranches upon a full renegotiation.
    /// @param _renegotiationOffer The renegotiation offer.
    /// @param _loan The loan to be processed.
    /// @param _isStrictlyBetter Whether the new tranche needs to be strictly better than all previous ones.
    /// @param _remainingNewLender Amount left for new lender to pay
    function _processOldTranchesFull(
        RenegotiationOffer calldata _renegotiationOffer,
        Loan memory _loan,
        bool _isStrictlyBetter,
        uint256 _remainingNewLender
    ) private returns (uint256 totalAccruedInterest, uint256 totalAnnualInterest, uint256 remainingNewLender) {
        uint256 totalProtocolFee = _renegotiationOffer.fee.mulDivUp(_loan.protocolFee, _PRECISION);
        unchecked {
            _remainingNewLender += totalProtocolFee;

            /// @dev bring to mem
            uint256 minImprovementApr = _minImprovementApr;
            remainingNewLender = _isStrictlyBetter ? type(uint256).max : _remainingNewLender;
            // We iterate first for the new lender and then for the rest.
            // This way if he is owed some principal,
            // it's discounted before transfering to the other lenders
            for (uint256 i = 0; i < _loan.tranche.length << 1;) {
                Tranche memory tranche = _loan.tranche[i % _loan.tranche.length];
                bool onlyNewLenderPass = i < _loan.tranche.length;
                bool isNewLender = tranche.lender == _renegotiationOffer.lender;
                ++i;
                if (onlyNewLenderPass != isNewLender) continue;
                uint256 accruedInterest;
                uint256 thisProtocolFee;
                (accruedInterest, thisProtocolFee, remainingNewLender) = _processOldTranche(
                    _renegotiationOffer.lender,
                    _loan.borrower,
                    _loan.principalAddress,
                    tranche,
                    _loan.startTime + _loan.duration,
                    _loan.protocolFee,
                    remainingNewLender
                );
                _checkTrancheStrictly(_isStrictlyBetter, tranche.aprBps, _renegotiationOffer.aprBps, minImprovementApr);

                totalAnnualInterest += tranche.principalAmount * tranche.aprBps;
                totalAccruedInterest += accruedInterest;
                totalProtocolFee += thisProtocolFee;
            }
            uint256 lenderFee = remainingNewLender > totalProtocolFee ? totalProtocolFee : remainingNewLender;
            uint256 borrowerFee = totalProtocolFee - lenderFee;
            _handleProtocolFeeForFee(
                _loan.principalAddress, _renegotiationOffer.lender, lenderFee, _protocolFee.recipient
            );
            _handleProtocolFeeForFee(_loan.principalAddress, _loan.borrower, borrowerFee, _protocolFee.recipient);
            remainingNewLender -= lenderFee;
        }
    }

    /// @notice Process the current source tranche during a renegotiation.
    /// @param _lender The new lender.
    /// @param _borrower The borrower of the loan.
    /// @param _principalAddress The principal address of the loan.
    /// @param _tranche The tranche to be processed.
    /// @param _endTime The end time of the loan.
    /// @param _protocolFeeFraction The protocol fee fraction.
    /// @param _remainingNewLender The amount left for the new lender to pay.
    /// @return accruedInterest The accrued interest paid.
    /// @return thisProtocolFee The protocol fee paid for this tranche.
    /// @return remainingNewLender The amount left for the new lender to pay.
    function _processOldTranche(
        address _lender,
        address _borrower,
        address _principalAddress,
        Tranche memory _tranche,
        uint256 _endTime,
        uint256 _protocolFeeFraction,
        uint256 _remainingNewLender
    ) private returns (uint256 accruedInterest, uint256 thisProtocolFee, uint256 remainingNewLender) {
        uint256 unlockTime = _getUnlockedTime(_tranche.startTime, _endTime);
        if (unlockTime > block.timestamp) {
            revert TrancheCannotBeRefinancedError(unlockTime);
        }
        unchecked {
            accruedInterest =
                _tranche.principalAmount.getInterest(_tranche.aprBps, block.timestamp - _tranche.startTime);
            thisProtocolFee = accruedInterest.mulDivUp(_protocolFeeFraction, _PRECISION);
            accruedInterest += _tranche.accruedInterest;
        }

        if (getLoanManagerRegistry.isLoanManager(_tranche.lender)) {
            ILoanManager(_tranche.lender).loanRepayment(
                _tranche.loanId,
                _tranche.principalAmount,
                _tranche.aprBps,
                _tranche.accruedInterest,
                _protocolFeeFraction,
                _tranche.startTime
            );
        }

        uint256 oldLenderDebt;
        unchecked {
            oldLenderDebt = _tranche.principalAmount + accruedInterest - thisProtocolFee;
        }
        ERC20 asset = ERC20(_principalAddress);
        if (oldLenderDebt > _remainingNewLender) {
            /// @dev already checked in the condition
            asset.safeTransferFrom(_borrower, _tranche.lender, oldLenderDebt - _remainingNewLender);
            oldLenderDebt = _remainingNewLender;
        }
        if (oldLenderDebt > 0) {
            if (_lender != _tranche.lender) {
                asset.safeTransferFrom(_lender, _tranche.lender, oldLenderDebt);
            }
            /// @dev oldLenderDebt < _remainingNewLender because it would enter previous condition if not and set to _remainingNewLender
            unchecked {
                _remainingNewLender -= oldLenderDebt;
            }
        }
        remainingNewLender = _remainingNewLender;
    }

    /// @notice Basic loan checks (check if the hash is correct) + whether loan is still active.
    /// @param _loanId The loan ID.
    /// @param _loan The loan to be checked.
    function _baseLoanChecks(uint256 _loanId, Loan memory _loan) private view {
        if (_loan.hash() != _loans[_loanId]) {
            revert InvalidLoanError(_loanId);
        }
        if (_loan.startTime + _loan.duration <= block.timestamp) {
            revert LoanExpiredError();
        }
    }

    /// @notice Basic renegotiation checks. Check basic parameters + expiration + whether the offer is active.
    function _baseRenegotiationChecks(RenegotiationOffer calldata _renegotiationOffer, Loan memory _loan)
        private
        view
    {
        if (
            (_renegotiationOffer.principalAmount == 0)
                || (_loan.tranche.length < _renegotiationOffer.trancheIndex.length)
        ) {
            revert InvalidRenegotiationOfferError();
        }
        if (block.timestamp > _renegotiationOffer.expirationTime) {
            revert ExpiredOfferError(_renegotiationOffer.expirationTime);
        }
        uint256 renegotiationId = _renegotiationOffer.renegotiationId;
        address lender = _renegotiationOffer.lender;
        if (isRenegotiationOfferCancelled[lender][renegotiationId]) {
            revert CancelledOrExecutedOfferError(lender, renegotiationId);
        }
    }

    /// @notice Protocol fee for fees charged on offers/renegotationOffers.
    /// @param _principalAddress The principal address of the loan.
    /// @param _lender The lender of the loan.
    /// @param _fee The fee to be charged.
    /// @param _feeRecipient The protocol fee recipient.
    function _handleProtocolFeeForFee(address _principalAddress, address _lender, uint256 _fee, address _feeRecipient)
        private
    {
        if (_fee != 0) {
            ERC20(_principalAddress).safeTransferFrom(_lender, _feeRecipient, _fee);
        }
    }

    /// @notice Check condition for strictly better tranches
    /// @param _isStrictlyBetter Whether the new tranche needs to be strictly better than the old one.
    /// @param _currentAprBps The current apr of the tranche.
    /// @param _targetAprBps The target apr of the tranche.
    /// @param __minImprovementApr The minimum improvement in APR.
    function _checkTrancheStrictly(
        bool _isStrictlyBetter,
        uint256 _currentAprBps,
        uint256 _targetAprBps,
        uint256 __minImprovementApr
    ) private pure {
        /// @dev If _isStrictlyBetter is set, and the new apr is higher, then it'll underflow.
        if (
            _isStrictlyBetter
                && ((_currentAprBps - _targetAprBps).mulDivDown(_PRECISION, _currentAprBps) < __minImprovementApr)
        ) {
            revert InvalidRenegotiationOfferError();
        }
    }

    /// @dev Tranches are locked from any refi after they are initiated for some time.
    function _getUnlockedTime(uint256 _trancheStartTime, uint256 _loanEndTime) private view returns (uint256) {
        uint256 delta;
        unchecked {
            delta = _loanEndTime - _trancheStartTime;
        }
        return _trancheStartTime + delta.mulDivUp(_minLockPeriod, _PRECISION);
    }

    /// @dev Loans are locked from lender initiated refis in the end.
    function _isLoanLocked(uint256 _loanStartTime, uint256 _loanDuration) private view returns (bool) {
        unchecked {
            /// @dev doesn't overflow because _minLockPeriod should be < 1
            return block.timestamp > _loanStartTime + _loanDuration - _loanDuration.mulDivUp(_minLockPeriod, _PRECISION);
        }
    }

    /// @notice Base ExecutionData Checks
    /// @dev Note that we do not validate fee < principalAmount since this is done in the child class in this case.
    /// @param _offerExecution The offer execution.
    /// @param _tokenId The token ID.
    /// @param _lender The lender.
    /// @param _duration The duration.
    /// @param _lenderOfferSignature The signature of the lender of LoanOffer.
    /// @param _feeFraction The protocol fee fraction.
    /// @param _totalAmount The total amount ahead.
    function _validateOfferExecution(
        OfferExecution calldata _offerExecution,
        uint256 _tokenId,
        address _lender,
        uint256 _duration,
        bytes calldata _lenderOfferSignature,
        uint256 _feeFraction,
        uint256 _totalAmount
    ) private {
        LoanOffer calldata offer = _offerExecution.offer;
        address lender = offer.lender;
        uint256 offerId = offer.offerId;
        uint256 totalAmountAfterExecution = _offerExecution.amount + _totalAmount;

        if (lender.code.length != 0 && getLoanManagerRegistry.isLoanManager(lender)) {
            ILoanManager(lender).validateOffer(_tokenId, abi.encode(_offerExecution), _feeFraction);
        } else {
            _checkSignature(lender, offer.hash(), _lenderOfferSignature);
        }

        if (block.timestamp > offer.expirationTime) {
            revert ExpiredOfferError(offer.expirationTime);
        }

        if (isOfferCancelled[_lender][offerId] || (offerId <= minOfferId[_lender])) {
            revert CancelledOrExecutedOfferError(_lender, offerId);
        }

        if (totalAmountAfterExecution > offer.principalAmount) {
            revert InvalidAmountError(totalAmountAfterExecution, offer.principalAmount);
        }

        if (offer.duration == 0 || _duration > offer.duration) {
            revert InvalidDurationError();
        }
        if (offer.aprBps == 0) {
            revert ZeroInterestError();
        }
        if ((offer.capacity != 0) && (_used[_lender][offer.offerId] + _offerExecution.amount > offer.capacity)) {
            revert MaxCapacityExceededError();
        }

        _checkValidators(_offerExecution.offer, _tokenId);
    }

    /// @notice Basic checks (expiration / signature if diff than borrower) for execution data.
    function _validateExecutionData(LoanExecutionData calldata _executionData, address _borrower) private view {
        if (msg.sender != _borrower) {
            _checkSignature(_borrower, _executionData.executionData.hash(), _executionData.borrowerOfferSignature);
        }
        if (block.timestamp > _executionData.executionData.expirationTime) {
            revert ExpiredOfferError(_executionData.executionData.expirationTime);
        }
        if (_executionData.executionData.offerExecution.length > getMaxTranches) {
            revert TooManyTranchesError();
        }
    }

    /// @notice Extract addresses from first offer. Used for validations.
    /// @param _executionData Execution data.
    /// @return principalAddress Address of the principal token.
    /// @return nftCollateralAddress Address of the NFT collateral.
    function _getAddressesFromExecutionData(ExecutionData calldata _executionData)
        private
        pure
        returns (address, address)
    {
        LoanOffer calldata one = _executionData.offerExecution[0].offer;
        return (one.principalAddress, one.nftCollateralAddress);
    }

    /// @notice Check addresses are whitelisted.
    /// @param _principalAddress Address of the principal token.
    /// @param _nftCollateralAddress Address of the NFT collateral.
    function _checkWhitelists(address _principalAddress, address _nftCollateralAddress) private view {
        if (!_currencyManager.isWhitelisted(_principalAddress)) {
            revert CurrencyNotWhitelistedError();
        }
        if (!_collectionManager.isWhitelisted(_nftCollateralAddress)) {
            revert CollectionNotWhitelistedError();
        }
    }

    /// @notice Check principal/collateral addresses match.
    /// @param _offer The offer to check.
    /// @param _principalAddress Address of the principal token.
    /// @param _nftCollateralAddress Address of the NFT collateral.
    /// @param _amountWithInterestAhead Amount of more senior principal + max accrued interest ahead.
    function _checkOffer(
        LoanOffer calldata _offer,
        address _principalAddress,
        address _nftCollateralAddress,
        uint256 _amountWithInterestAhead
    ) private pure {
        if (_offer.principalAddress != _principalAddress || _offer.nftCollateralAddress != _nftCollateralAddress) {
            revert InvalidAddressesError();
        }
        if (_amountWithInterestAhead > _offer.maxSeniorRepayment) {
            revert InvalidTrancheError();
        }
    }

    /// @notice Check generic offer validators for a given offer or
    ///         an exact match if no validators are given. The validators
    ///         check is performed only if tokenId is set to 0.
    ///         Having one empty validator is used for collection offers (all IDs match).
    /// @param _loanOffer The loan offer to check.
    /// @param _tokenId The token ID to check.
    function _checkValidators(LoanOffer calldata _loanOffer, uint256 _tokenId) private view {
        uint256 offerTokenId = _loanOffer.nftCollateralTokenId;
        if (_loanOffer.nftCollateralTokenId != 0) {
            if (offerTokenId != _tokenId) {
                revert InvalidCollateralIdError();
            }
        } else {
            uint256 totalValidators = _loanOffer.validators.length;
            if (totalValidators == 0 && _tokenId != 0) {
                revert InvalidCollateralIdError();
            } else if ((totalValidators == 1) && _loanOffer.validators[0].validator == address(0)) {
                return;
            }
            for (uint256 i = 0; i < totalValidators;) {
                IBaseLoan.OfferValidator memory thisValidator = _loanOffer.validators[i];
                IOfferValidator(thisValidator.validator).validateOffer(_loanOffer, _tokenId, thisValidator.arguments);
                unchecked {
                    ++i;
                }
            }
        }
    }

    /// @dev Check new trnches are at least this big.
    function _getMinTranchePrincipal(uint256 _loanPrincipal) private view returns (uint256) {
        return _loanPrincipal / (_MAX_RATIO_TRANCHE_MIN_PRINCIPAL * getMaxTranches);
    }

    function _hasCallback(bytes calldata _callbackData) private pure returns (bool) {
        return _callbackData.length != 0;
    }

    function _processRepayments(Loan calldata loan) private returns (uint256, uint256) {
        bool withProtocolFee = loan.protocolFee != 0;
        uint256 totalRepayment = 0;
        uint256 totalProtocolFee = 0;

        ERC20 asset = ERC20(loan.principalAddress);
        uint256 totalTranches = loan.tranche.length;
        for (uint256 i; i < totalTranches;) {
            Tranche memory tranche = loan.tranche[i];
            uint256 newInterest =
                tranche.principalAmount.getInterest(tranche.aprBps, block.timestamp - tranche.startTime);
            uint256 thisProtocolFee = 0;
            if (withProtocolFee) {
                thisProtocolFee = newInterest.mulDivUp(loan.protocolFee, _PRECISION);
                unchecked {
                    totalProtocolFee += thisProtocolFee;
                }
            }
            uint256 repayment = tranche.principalAmount + tranche.accruedInterest + newInterest - thisProtocolFee;
            asset.safeTransferFrom(loan.borrower, tranche.lender, repayment);
            unchecked {
                totalRepayment += repayment;
            }
            if (getLoanManagerRegistry.isLoanManager(tranche.lender)) {
                ILoanManager(tranche.lender).loanRepayment(
                    tranche.loanId,
                    tranche.principalAmount,
                    tranche.aprBps,
                    tranche.accruedInterest,
                    loan.protocolFee,
                    tranche.startTime
                );
            }
            unchecked {
                ++i;
            }
        }

        if (withProtocolFee) {
            asset.safeTransferFrom(loan.borrower, _protocolFee.recipient, totalProtocolFee);
        }
        return (totalRepayment, totalProtocolFee);
    }

    /// @notice Process a series of offers and return the loan ID, offer IDs, loan (built from such offers) and total fee.
    /// @param _borrower The borrower of the loan.
    /// @param _principalReceiver The receiver of the principal.
    /// @param _principalAddress The principal address of the loan.
    /// @param _nftCollateralAddress The NFT collateral address of the loan.
    /// @param _tokenId The token ID of the loan.
    /// @param _duration The duration of the loan.
    /// @param _offerExecution The offer execution.
    /// @return loanId The loan ID.
    /// @return offerIds The offer IDs.
    /// @return loan The loan.
    /// @return totalFee The total fee.
    function _processOffersFromExecutionData(
        address _borrower,
        address _principalReceiver,
        address _principalAddress,
        address _nftCollateralAddress,
        uint256 _tokenId,
        uint256 _duration,
        OfferExecution[] calldata _offerExecution
    ) private returns (uint256, uint256[] memory, Loan memory, uint256) {
        Tranche[] memory tranche = new Tranche[](_offerExecution.length);
        uint256[] memory offerIds = new uint256[](_offerExecution.length);
        uint256 totalAmount;
        uint256 loanId = _getAndSetNewLoanId();

        ProtocolFee memory protocolFee = _protocolFee;
        LoanOffer calldata offer;
        uint256 totalFee;
        uint256 totalAmountWithMaxInterest;
        uint256 minAmount = type(uint256).max;
        uint256 totalOffers = _offerExecution.length;
        for (uint256 i = 0; i < totalOffers;) {
            OfferExecution calldata thisOfferExecution = _offerExecution[i];
            offer = thisOfferExecution.offer;
            _validateOfferExecution(
                thisOfferExecution,
                _tokenId,
                offer.lender,
                _duration,
                thisOfferExecution.lenderOfferSignature,
                protocolFee.fraction,
                totalAmount
            );
            uint256 amount = thisOfferExecution.amount;
            if (amount < minAmount) {
                minAmount = amount;
            }
            address lender = offer.lender;
            _checkOffer(offer, _principalAddress, _nftCollateralAddress, totalAmountWithMaxInterest);
            /// @dev Please note that we can now have many tranches with same `loanId`.
            tranche[i] = Tranche(loanId, totalAmount, amount, lender, 0, block.timestamp, offer.aprBps);
            unchecked {
                totalAmount += amount;
                totalAmountWithMaxInterest += amount + amount.getInterest(offer.aprBps, _duration);
            }

            uint256 fee;
            unchecked {
                fee = offer.fee.mulDivUp(amount, offer.principalAmount);
                totalFee += fee;
            }
            _handleProtocolFeeForFee(
                offer.principalAddress, lender, fee.mulDivUp(protocolFee.fraction, _PRECISION), protocolFee.recipient
            );

            ERC20(offer.principalAddress).safeTransferFrom(lender, _principalReceiver, amount - fee);
            if (offer.capacity != 0) {
                unchecked {
                    _used[lender][offer.offerId] += amount;
                }
            } else {
                isOfferCancelled[lender][offer.offerId] = true;
            }

            offerIds[i] = offer.offerId;
            unchecked {
                ++i;
            }
        }
        if (minAmount < _getMinTranchePrincipal(totalAmount)) {
            revert InvalidTrancheError();
        }
        Loan memory loan = Loan(
            _borrower,
            _tokenId,
            _nftCollateralAddress,
            _principalAddress,
            totalAmount,
            block.timestamp,
            _duration,
            tranche,
            protocolFee.fraction
        );

        return (loanId, offerIds, loan, totalFee);
    }

    function _addNewTranche(
        uint256 _newLoanId,
        IMultiSourceLoan.Loan memory _loan,
        IMultiSourceLoan.RenegotiationOffer calldata _renegotiationOffer
    ) private view returns (IMultiSourceLoan.Loan memory) {
        if (_renegotiationOffer.principalAmount < _getMinTranchePrincipal(_loan.principalAmount)) {
            revert InvalidTrancheError();
        }
        uint256 newTrancheIndex = _loan.tranche.length;
        IMultiSourceLoan.Tranche[] memory tranches = new IMultiSourceLoan.Tranche[](newTrancheIndex + 1);

        /// @dev Copy old tranches
        for (uint256 i = 0; i < newTrancheIndex;) {
            tranches[i] = _loan.tranche[i];
            unchecked {
                ++i;
            }
        }

        tranches[newTrancheIndex] = IMultiSourceLoan.Tranche(
            _newLoanId,
            _loan.principalAmount,
            _renegotiationOffer.principalAmount,
            _renegotiationOffer.lender,
            0,
            block.timestamp,
            _renegotiationOffer.aprBps
        );
        _loan.tranche = tranches;
        unchecked {
            _loan.principalAmount += _renegotiationOffer.principalAmount;
        }
        return _loan;
    }

    /// @notice Check a signature is valid given a hash and signer.
    /// @dev Comply with IERC1271 and EIP-712.
    function _checkSignature(address _signer, bytes32 _hash, bytes calldata _signature) private view {
        bytes32 typedDataHash = DOMAIN_SEPARATOR().toTypedDataHash(_hash);

        if (_signer.code.length != 0) {
            if (IERC1271(_signer).isValidSignature(typedDataHash, _signature) != MAGICVALUE_1271) {
                revert InvalidSignatureError();
            }
        } else {
            address recovered = typedDataHash.recover(_signature);
            if (_signer != recovered) {
                revert InvalidSignatureError();
            }
        }
    }

    /// @dev Check whether an offer is strictly better than a tranche
    function _checkStrictlyBetter(
        uint256 _offerPrincipalAmount,
        uint256 _loanPrincipalAmount,
        uint256 _offerEndTime,
        uint256 _loanEndTime,
        uint256 _offerAprBps,
        uint256 _loanAprBps,
        uint256 _offerFee
    ) internal view {
        uint256 minImprovementApr = _minImprovementApr;

        /// @dev If principal is increased, then we need to check net daily interest is better.
        /// interestDelta = (_loanAprBps * _loanPrincipalAmount - _offerAprBps * _offerPrincipalAmount)
        /// We already checked that all tranches are strictly better.
        /// We check that the duration is not decreased or the offer charges a fee.
        if (
            (
                (_offerPrincipalAmount - _loanPrincipalAmount != 0)
                    && (
                        (_loanAprBps * _loanPrincipalAmount - _offerAprBps * _offerPrincipalAmount).mulDivDown(
                            _PRECISION, _loanAprBps * _loanPrincipalAmount
                        ) < minImprovementApr
                    )
            ) || (_offerFee != 0) || (_offerEndTime < _loanEndTime)
        ) {
            revert NotStrictlyImprovedError();
        }
    }
}
// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.21;

import "../../interfaces/loans/IMultiSourceLoan.sol";
import "../../interfaces/loans/IBaseLoan.sol";
import "../../interfaces/IAuctionLoanLiquidator.sol";

library Hash {
    // keccak256("OfferValidator(address validator,bytes arguments)")
    bytes32 private constant _VALIDATOR_HASH = 0x4def3e04bd42194484d5f8a5b268ec0df03b9d9d0402606fe3100023c5d79ac4;

    // keccak256("LoanOffer(uint256 offerId,address lender,uint256 fee,uint256 capacity,address nftCollateralAddress,uint256 nftCollateralTokenId,address principalAddress,uint256 principalAmount,uint256 aprBps,uint256 expirationTime,uint256 duration,uint256 maxSeniorRepayment,OfferValidator[] validators)OfferValidator(address validator,bytes arguments)")
    bytes32 private constant _LOAN_OFFER_HASH = 0xa87df46e2d2684eb0bbc7abfb05483167cdccac6d7302078a9eaad540c119958;

    // keccak256("OfferExecution(LoanOffer offer,uint256 amount,bytes lenderOfferSignature)LoanOffer(uint256 offerId,address lender,uint256 fee,uint256 capacity,address nftCollateralAddress,uint256 nftCollateralTokenId,address principalAddress,uint256 principalAmount,uint256 aprBps,uint256 expirationTime,uint256 duration,uint256 maxSeniorRepayment,OfferValidator[] validators)OfferValidator(address validator,bytes arguments)")
    bytes32 private constant _OFFER_EXECUTION_HASH = 0x00c14ad24a24ef957b8af9ebdfbc5d353bba0d3b20bbd97fb243c9f5fb361282;

    /// keccak256("ExecutionData(OfferExecution[] offerExecution,uint256 tokenId,uint256 duration,uint256 expirationTime,address principalReceiver,bytes callbackData)OfferExecution(LoanOffer offer,uint256 amount,bytes lenderOfferSignature)LoanOffer(uint256 offerId,address lender,uint256 fee,uint256 capacity,address nftCollateralAddress,uint256 nftCollateralTokenId,address principalAddress,uint256 principalAmount,uint256 aprBps,uint256 expirationTime,uint256 duration,uint256 maxSeniorRepayment,OfferValidator[] validators)OfferValidator(address validator,bytes arguments)")
    bytes32 private constant _EXECUTION_DATA_HASH = 0xa5cb06a0c5f03000a6afa6b0d5080d0f863338257beb253058bc2c184ad7d4e1;

    /// keccak256("SignableRepaymentData(uint256 loanId,bytes callbackData,bool shouldDelegate)")
    bytes32 private constant _SIGNABLE_REPAYMENT_DATA_HASH =
        0x41277b3c1cbe08ea7bbdd10a13f24dc956f3936bf46526f904c73697d9958e0c;

    // keccak256("Loan(address borrower,uint256 nftCollateralTokenId,address nftCollateralAddress,address principalAddress,uint256 principalAmount,uint256 startTime,uint256 duration,Tranche[] tranche,uint256 protocolFee)Tranche(uint256 floor,uint256 principalAmount,Source[] source)Source(uint256 loanId,address lender,uint256 principalAmount,uint256 accruedInterest,uint256 startTime,uint256 aprBps)")
    bytes32 private constant _MULTI_SOURCE_LOAN_HASH =
        0x47dba7e6940f0063b21c2ef8f7b0beaf1a2f4c2f84144c36b274ceec12e99b57;

    /// keccak256("Tranche(uint256 loanId,uint256 floor,uint256 principalAmount,address lender,uint256 accruedInterest,uint256 startTime,uint256 aprBps)")
    bytes32 private constant _TRANCHE_HASH = 0x6ac594952a72f2e6b24efaf9744b05c23b1b92ce25aa97d18a4338f484c41b95;

    /// keccak256("RenegotiationOffer(uint256 renegotiationId,uint256 loanId,address lender,uint256 fee,uint256[] trancheIndex,uint256 principalAmount,uint256 aprBps,uint256 expirationTime,uint256 duration)")
    bytes32 private constant _MULTI_RENEGOTIATION_OFFER_HASH =
        0x986a160abc209a64a5b0786817ff0aa7a5f5737a4ee6a95197f86290598cd03d;

    /// keccak256("Auction(address loanAddress,uint256 loanId,uint256 highestBid,uint256 triggerFee,uint256 minBid,address highestBidder,uint96 duration,address asset,uint96 startTime,address originator,uint96 lastBidTime)")
    bytes32 private constant _AUCTION_HASH = 0x091bb2c766793330514b24dc458b085f596716d69fcb631d53788558ff148646;

    function hash(IMultiSourceLoan.LoanOffer memory _loanOffer) internal pure returns (bytes32) {
        bytes memory encodedValidators;
        uint256 totalValidators = _loanOffer.validators.length;
        for (uint256 i = 0; i < totalValidators;) {
            encodedValidators = abi.encodePacked(encodedValidators, _hashValidator(_loanOffer.validators[i]));

            unchecked {
                ++i;
            }
        }
        return keccak256(
            abi.encode(
                _LOAN_OFFER_HASH,
                _loanOffer.offerId,
                _loanOffer.lender,
                _loanOffer.fee,
                _loanOffer.capacity,
                _loanOffer.nftCollateralAddress,
                _loanOffer.nftCollateralTokenId,
                _loanOffer.principalAddress,
                _loanOffer.principalAmount,
                _loanOffer.aprBps,
                _loanOffer.expirationTime,
                _loanOffer.duration,
                _loanOffer.maxSeniorRepayment,
                keccak256(encodedValidators)
            )
        );
    }

    function hash(IMultiSourceLoan.ExecutionData memory _executionData) internal pure returns (bytes32) {
        bytes memory encodedOfferExecution;
        uint256 totalOfferExecution = _executionData.offerExecution.length;
        for (uint256 i = 0; i < totalOfferExecution;) {
            encodedOfferExecution =
                abi.encodePacked(encodedOfferExecution, _hashOfferExecution(_executionData.offerExecution[i]));

            unchecked {
                ++i;
            }
        }
        return keccak256(
            abi.encode(
                _EXECUTION_DATA_HASH,
                keccak256(encodedOfferExecution),
                _executionData.tokenId,
                _executionData.duration,
                _executionData.expirationTime,
                _executionData.principalReceiver,
                keccak256(_executionData.callbackData)
            )
        );
    }

    function hash(IMultiSourceLoan.SignableRepaymentData memory _repaymentData) internal pure returns (bytes32) {
        return keccak256(
            abi.encode(
                _SIGNABLE_REPAYMENT_DATA_HASH,
                _repaymentData.loanId,
                keccak256(_repaymentData.callbackData),
                _repaymentData.shouldDelegate
            )
        );
    }

    function hash(IMultiSourceLoan.Loan memory _loan) internal pure returns (bytes32) {
        bytes memory trancheHashes;
        uint256 totalTranches = _loan.tranche.length;
        for (uint256 i; i < totalTranches;) {
            trancheHashes = abi.encodePacked(trancheHashes, _hashTranche(_loan.tranche[i]));
            unchecked {
                ++i;
            }
        }
        return keccak256(
            abi.encode(
                _MULTI_SOURCE_LOAN_HASH,
                _loan.borrower,
                _loan.nftCollateralTokenId,
                _loan.nftCollateralAddress,
                _loan.principalAddress,
                _loan.principalAmount,
                _loan.startTime,
                _loan.duration,
                keccak256(trancheHashes),
                _loan.protocolFee
            )
        );
    }

    function hash(IMultiSourceLoan.RenegotiationOffer memory _refinanceOffer) internal pure returns (bytes32) {
        bytes memory encodedIndexes;
        uint256 totalIndexes = _refinanceOffer.trancheIndex.length;
        for (uint256 i = 0; i < totalIndexes;) {
            encodedIndexes = abi.encodePacked(encodedIndexes, _refinanceOffer.trancheIndex[i]);
            unchecked {
                ++i;
            }
        }
        return keccak256(
            abi.encode(
                _MULTI_RENEGOTIATION_OFFER_HASH,
                _refinanceOffer.renegotiationId,
                _refinanceOffer.loanId,
                _refinanceOffer.lender,
                _refinanceOffer.fee,
                keccak256(encodedIndexes),
                _refinanceOffer.principalAmount,
                _refinanceOffer.aprBps,
                _refinanceOffer.expirationTime,
                _refinanceOffer.duration
            )
        );
    }

    function hash(IAuctionLoanLiquidator.Auction memory _auction) internal pure returns (bytes32) {
        return keccak256(
            abi.encode(
                _AUCTION_HASH,
                _auction.loanAddress,
                _auction.loanId,
                _auction.highestBid,
                _auction.triggerFee,
                _auction.minBid,
                _auction.highestBidder,
                _auction.duration,
                _auction.asset,
                _auction.startTime,
                _auction.originator,
                _auction.lastBidTime
            )
        );
    }

    function _hashTranche(IMultiSourceLoan.Tranche memory _tranche) private pure returns (bytes32) {
        return keccak256(
            abi.encode(
                _TRANCHE_HASH,
                _tranche.loanId,
                _tranche.floor,
                _tranche.principalAmount,
                _tranche.lender,
                _tranche.accruedInterest,
                _tranche.startTime,
                _tranche.aprBps
            )
        );
    }

    function _hashValidator(IBaseLoan.OfferValidator memory _validator) private pure returns (bytes32) {
        return keccak256(abi.encode(_VALIDATOR_HASH, _validator.validator, keccak256(_validator.arguments)));
    }

    function _hashOfferExecution(IMultiSourceLoan.OfferExecution memory _offerExecution)
        private
        pure
        returns (bytes32)
    {
        return keccak256(
            abi.encode(
                _OFFER_EXECUTION_HASH,
                hash(_offerExecution.offer),
                _offerExecution.amount,
                keccak256(_offerExecution.lenderOfferSignature)
            )
        );
    }
}
// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.21;

import "@solmate/utils/FixedPointMathLib.sol";
import "../../interfaces/loans/IMultiSourceLoan.sol";
import "../../interfaces/loans/IBaseLoan.sol";

library Interest {
    using FixedPointMathLib for uint256;

    uint256 private constant _PRECISION = 10000;

    uint256 private constant _SECONDS_PER_YEAR = 31536000;

    function getInterest(IMultiSourceLoan.LoanOffer memory _loanOffer) internal pure returns (uint256) {
        return _getInterest(_loanOffer.principalAmount, _loanOffer.aprBps, _loanOffer.duration);
    }

    function getInterest(uint256 _amount, uint256 _aprBps, uint256 _duration) internal pure returns (uint256) {
        return _getInterest(_amount, _aprBps, _duration);
    }

    function getTotalOwed(IMultiSourceLoan.Loan memory _loan, uint256 _timestamp) internal pure returns (uint256) {
        uint256 owed = 0;
        for (uint256 i = 0; i < _loan.tranche.length;) {
            IMultiSourceLoan.Tranche memory tranche = _loan.tranche[i];
            owed += tranche.principalAmount + tranche.accruedInterest
                + _getInterest(tranche.principalAmount, tranche.aprBps, _timestamp - tranche.startTime);
            unchecked {
                ++i;
            }
        }
        return owed;
    }

    function _getInterest(uint256 _amount, uint256 _aprBps, uint256 _duration) private pure returns (uint256) {
        return _amount.mulDivUp(_aprBps * _duration, _PRECISION * _SECONDS_PER_YEAR);
    }
}
// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.21;

import "@solmate/auth/Owned.sol";

/// @title TwoStepOwned
/// @author Florida St
/// @notice This contract is used to transfer ownership of a contract in two steps.
abstract contract TwoStepOwned is Owned {
    event TransferOwnerRequested(address newOwner);

    error TooSoonError();
    error InvalidInputError();

    uint256 public immutable MIN_WAIT_TIME;

    address public pendingOwner;
    uint256 public pendingOwnerTime;

    constructor(address _owner, uint256 _minWaitTime) Owned(_owner) {
        pendingOwnerTime = type(uint256).max;
        MIN_WAIT_TIME = _minWaitTime;
    }

    /// @notice First step transferring ownership to the new owner.
    /// @param _newOwner The address of the new owner.
    function requestTransferOwner(address _newOwner) external onlyOwner {
        pendingOwner = _newOwner;
        pendingOwnerTime = block.timestamp;

        emit TransferOwnerRequested(_newOwner);
    }

    /// @notice Second step transferring ownership to the new owner.
    function transferOwnership() public {
        address newOwner = msg.sender;
        if (pendingOwnerTime + MIN_WAIT_TIME > block.timestamp) {
            revert TooSoonError();
        }
        if (newOwner != pendingOwner) {
            revert InvalidInputError();
        }
        owner = newOwner;
        pendingOwner = address(0);
        pendingOwnerTime = type(uint256).max;

        emit OwnershipTransferred(owner, newOwner);
    }
}
// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.21;

import "./TwoStepOwned.sol";

import "../InputChecker.sol";

abstract contract WithProtocolFee is TwoStepOwned {
    using InputChecker for address;

    /// @notice Recipient address and fraction of gains charged by the protocol.
    struct ProtocolFee {
        address recipient;
        uint256 fraction;
    }

    uint256 public constant FEE_UPDATE_NOTICE = 30 days;

    /// @notice Protocol fee charged on gains.
    ProtocolFee internal _protocolFee;
    /// @notice Set as the target new protocol fee.
    ProtocolFee internal _pendingProtocolFee;
    /// @notice Set when the protocol fee updating mechanisms starts.
    uint256 internal _pendingProtocolFeeSetTime;

    event ProtocolFeeUpdated(ProtocolFee fee);
    event ProtocolFeePendingUpdate(ProtocolFee fee);

    error TooEarlyError(uint256 _pendingProtocolFeeSetTime);

    /// @notice Constructor
    /// @param _owner The owner of the contract
    /// @param _minWaitTime The time to wait before a new owner can be set
    /// @param __protocolFee The protocol fee
    constructor(address _owner, uint256 _minWaitTime, ProtocolFee memory __protocolFee)
        TwoStepOwned(_owner, _minWaitTime)
    {
        _protocolFee = __protocolFee;
        _pendingProtocolFeeSetTime = type(uint256).max;
    }

    /// @return protocolFee The Protocol fee.
    function getProtocolFee() external view returns (ProtocolFee memory) {
        return _protocolFee;
    }

    /// @return pendingProtocolFee The pending protocol fee.
    function getPendingProtocolFee() external view returns (ProtocolFee memory) {
        return _pendingProtocolFee;
    }

    /// @return protocolFeeSetTime Time when the protocol fee was set to be changed.
    function getPendingProtocolFeeSetTime() external view returns (uint256) {
        return _pendingProtocolFeeSetTime;
    }

    /// @notice Kicks off the process to update the protocol fee.
    /// @param _newProtocolFee New protocol fee.
    function updateProtocolFee(ProtocolFee calldata _newProtocolFee) external onlyOwner {
        _newProtocolFee.recipient.checkNotZero();

        _pendingProtocolFee = _newProtocolFee;
        _pendingProtocolFeeSetTime = block.timestamp;

        emit ProtocolFeePendingUpdate(_pendingProtocolFee);
    }

    /// @notice Set the protocol fee if enough notice has been given.
    function setProtocolFee() external virtual {
        if (block.timestamp < _pendingProtocolFeeSetTime + FEE_UPDATE_NOTICE) {
            revert TooSoonError();
        }
        ProtocolFee memory protocolFee = _pendingProtocolFee;
        _protocolFee = protocolFee;

        emit ProtocolFeeUpdated(protocolFee);
    }
}