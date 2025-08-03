// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "./interface/IPermissions.sol";
import "../lib/TWStrings.sol";

/**
 *  @title   Permissions
 *  @dev     This contracts provides extending-contracts with role-based access control mechanisms
 */
contract Permissions is IPermissions {
    /// @dev Map from keccak256 hash of a role => a map from address => whether address has role.
    mapping(bytes32 => mapping(address => bool)) private _hasRole;

    /// @dev Map from keccak256 hash of a role to role admin. See {getRoleAdmin}.
    mapping(bytes32 => bytes32) private _getRoleAdmin;

    /// @dev Default admin role for all roles. Only accounts with this role can grant/revoke other roles.
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /// @dev Modifier that checks if an account has the specified role; reverts otherwise.
    modifier onlyRole(bytes32 role) {
        _checkRole(role, msg.sender);
        _;
    }

    /**
     *  @notice         Checks whether an account has a particular role.
     *  @dev            Returns `true` if `account` has been granted `role`.
     *
     *  @param role     keccak256 hash of the role. e.g. keccak256("TRANSFER_ROLE")
     *  @param account  Address of the account for which the role is being checked.
     */
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _hasRole[role][account];
    }

    /**
     *  @notice         Checks whether an account has a particular role;
     *                  role restrictions can be swtiched on and off.
     *
     *  @dev            Returns `true` if `account` has been granted `role`.
     *                  Role restrictions can be swtiched on and off:
     *                      - If address(0) has ROLE, then the ROLE restrictions
     *                        don't apply.
     *                      - If address(0) does not have ROLE, then the ROLE
     *                        restrictions will apply.
     *
     *  @param role     keccak256 hash of the role. e.g. keccak256("TRANSFER_ROLE")
     *  @param account  Address of the account for which the role is being checked.
     */
    function hasRoleWithSwitch(bytes32 role, address account) public view returns (bool) {
        if (!_hasRole[role][address(0)]) {
            return _hasRole[role][account];
        }

        return true;
    }

    /**
     *  @notice         Returns the admin role that controls the specified role.
     *  @dev            See {grantRole} and {revokeRole}.
     *                  To change a role's admin, use {_setRoleAdmin}.
     *
     *  @param role     keccak256 hash of the role. e.g. keccak256("TRANSFER_ROLE")
     */
    function getRoleAdmin(bytes32 role) external view override returns (bytes32) {
        return _getRoleAdmin[role];
    }

    /**
     *  @notice         Grants a role to an account, if not previously granted.
     *  @dev            Caller must have admin role for the `role`.
     *                  Emits {RoleGranted Event}.
     *
     *  @param role     keccak256 hash of the role. e.g. keccak256("TRANSFER_ROLE")
     *  @param account  Address of the account to which the role is being granted.
     */
    function grantRole(bytes32 role, address account) public virtual override {
        _checkRole(_getRoleAdmin[role], msg.sender);
        if (_hasRole[role][account]) {
            revert("Can only grant to non holders");
        }
        _setupRole(role, account);
    }

    /**
     *  @notice         Revokes role from an account.
     *  @dev            Caller must have admin role for the `role`.
     *                  Emits {RoleRevoked Event}.
     *
     *  @param role     keccak256 hash of the role. e.g. keccak256("TRANSFER_ROLE")
     *  @param account  Address of the account from which the role is being revoked.
     */
    function revokeRole(bytes32 role, address account) public virtual override {
        _checkRole(_getRoleAdmin[role], msg.sender);
        _revokeRole(role, account);
    }

    /**
     *  @notice         Revokes role from the account.
     *  @dev            Caller must have the `role`, with caller being the same as `account`.
     *                  Emits {RoleRevoked Event}.
     *
     *  @param role     keccak256 hash of the role. e.g. keccak256("TRANSFER_ROLE")
     *  @param account  Address of the account from which the role is being revoked.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        if (msg.sender != account) {
            revert("Can only renounce for self");
        }
        _revokeRole(role, account);
    }

    /// @dev Sets `adminRole` as `role`'s admin role.
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = _getRoleAdmin[role];
        _getRoleAdmin[role] = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /// @dev Sets up `role` for `account`
    function _setupRole(bytes32 role, address account) internal virtual {
        _hasRole[role][account] = true;
        emit RoleGranted(role, account, msg.sender);
    }

    /// @dev Revokes `role` from `account`
    function _revokeRole(bytes32 role, address account) internal virtual {
        _checkRole(role, account);
        delete _hasRole[role][account];
        emit RoleRevoked(role, account, msg.sender);
    }

    /// @dev Checks `role` for `account`. Reverts with a message including the required role.
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!_hasRole[role][account]) {
            revert(
                string(
                    abi.encodePacked(
                        "Permissions: account ",
                        TWStrings.toHexString(uint160(account), 20),
                        " is missing role ",
                        TWStrings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /// @dev Checks `role` for `account`. Reverts with a message including the required role.
    function _checkRoleWithSwitch(bytes32 role, address account) internal view virtual {
        if (!hasRoleWithSwitch(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "Permissions: account ",
                        TWStrings.toHexString(uint160(account), 20),
                        " is missing role ",
                        TWStrings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IPermissions {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library TWStrings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

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
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../../../lib/TWStrings.sol";

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
        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
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
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", TWStrings.toString(s.length), s));
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
// OpenZeppelin Contracts v4.4.1 (utils/cryptography/draft-EIP712.sol)

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
pragma solidity ^0.8.0;

import "@thirdweb-dev/contracts/extension/Permissions.sol";
import "@thirdweb-dev/contracts/openzeppelin-presets/security/ReentrancyGuard.sol";
import "@thirdweb-dev/contracts/openzeppelin-presets/utils/cryptography/EIP712.sol";
import "./extensions/Pausable.sol";
import "./interfaces/IBonfire.sol";

import "./interfaces/original/IOldWorldPass.sol"; // old WP
import "./interfaces/original/IOldDiceNFT.sol"; // old Dice
import "./interfaces/IDiceNFT.sol"; // new Dice
import "./interfaces/IWorldPassNFT.sol"; // new WP

contract Bonfire is EIP712, ReentrancyGuard, Pausable, Permissions, IBonfire {
    using ECDSA for bytes32;

    bytes32 private constant TYPEHASH =
        keccak256(
            "BurnRequest(address to,uint128 wpBurnAmount,uint256[] diceIds,uint8[] diceResults,uint8[] wpHouses,uint128 validityStartTimestamp,uint128 validityEndTimestamp,bytes32 uid)"
        );

    /// @dev Mapping from burn request UID => whether the request is processed.
    mapping(bytes32 => bool) private requestIdProcessed;

    address public allowedSigner;

    address public immutable originalDice;
    address public immutable originalWP;
    address public immutable reforgedDice;
    address public immutable reforgedWP;

    IOldWorldPass internal immutable oldWP;
    IOldDiceNFT internal immutable oldDice;
    IDiceNFT internal immutable newDice;
    IWorldPassNFT internal immutable newWP;

    // Allows pausing/unpausing
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    constructor(
        address _originalDice,
        address _originalWP,
        address _reforgedDice,
        address _reforgedWP,
        address _allowedSigner
    ) EIP712("Bonfire", "1") {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(PAUSER_ROLE, msg.sender);

        allowedSigner = _allowedSigner;

        originalDice = _originalDice;
        originalWP = _originalWP;
        reforgedDice = _reforgedDice;
        reforgedWP = _reforgedWP;

        oldWP = IOldWorldPass(originalWP);
        oldDice = IOldDiceNFT(originalDice);
        newDice = IDiceNFT(reforgedDice);
        newWP = IWorldPassNFT(reforgedWP);
    }

    /*//////////////////////////////////////////////////////////////
                        Our custom logic
    //////////////////////////////////////////////////////////////*/

    function bonfireBurn(BurnRequest calldata _req, bytes calldata _signature)
        external
        nonReentrant
        whenNotPaused
        returns (address signer)
    {
        require(
            _req.wpBurnAmount == _req.wpHouses.length,
            "Unequal wpBurnAmount & wpHouses"
        );

        require(
            _req.wpBurnAmount > 0 || _req.diceIds.length > 0,
            "Nothing to burn"
        );

        // Verify and process payload.
        signer = _processRequest(_req, _signature);

        // Burn the requested amount of original WPs
        // User needs to first approveAll on original WP for this Bonfire contract
        if (_req.wpBurnAmount > 0) {
            oldWP.burn(_req.to, 0, _req.wpBurnAmount);
        }

        // Burn the requested original dice NFTs & ensure req.to is the owner of the diceIDs
        // User needs to first approveAll on original Dice for this Bonfire contract
        uint256 diceBurnAmount = _req.diceIds.length;
        for (uint256 i = 0; i < diceBurnAmount; ) {
            if (oldDice.ownerOf(_req.diceIds[i]) != _req.to) {
                revert("Only the owner of the dice can burn them");
            }

            oldDice.burn(_req.diceIds[i]);

            unchecked {
                ++i;
            }
        }

        // Mint the new WP NFTs
        for (uint256 i = 0; i < _req.wpHouses.length; ) {
            newWP.mintWithHouseTo(_req.to, House(_req.wpHouses[i]));

            unchecked {
                ++i;
            }
        }

        // Mint the new Dice NFTs
        if (diceBurnAmount > 0) {
            if (diceBurnAmount == 1) {
                newDice.mint(_req.to, _req.diceIds[0]);
            } else {
                newDice.batchMint(_req.to, _req.diceIds);
            }
        }

        emit BonfireBurn(_req.to, _req);
    }

    /**
     *  @notice Allows caller to burn their old dice to mint new ones.
     *
     *  @param diceIds The diceIds to burn & re-mint from new contract.
     */
    function burnDiceOnly(uint256[] calldata diceIds)
        external
        nonReentrant
        whenNotPaused
    {
        require(diceIds.length > 0, "Nothing to burn");

        // Burn the requested original dice NFTs
        // User needs to first approveAll on original Dice for this Bonfire contract
        uint256 diceBurnAmount = diceIds.length;
        for (uint256 i = 0; i < diceBurnAmount; ) {
            if (oldDice.ownerOf(diceIds[i]) != msg.sender) {
                revert("Only the owner of the dice can burn them");
            }

            oldDice.burn(diceIds[i]);

            unchecked {
                ++i;
            }
        }

        // Mint the new Dice NFTs
        if (diceBurnAmount == 1) {
            newDice.mint(msg.sender, diceIds[0]);
        } else {
            newDice.batchMint(msg.sender, diceIds);
        }

        emit BonfireBurnDiceOnly(msg.sender, diceIds);
    }

    /**
     *  @notice Allows caller to burn their old wp to mint new WPs with "Scarred" attribute.
     *
     *  @param burnAmount The amount of old WPs to burn & re-mint from new contract.
     */
    function joinScarred(uint256 burnAmount)
        external
        nonReentrant
        whenNotPaused
    {
        require(burnAmount > 0, "Cannot burn nothing");

        oldWP.burn(msg.sender, 0, burnAmount);

        if (burnAmount == 1) {
            newWP.mintWithHouseTo(msg.sender, House.Scarred);
        } else {
            newWP.batchMintWithHouseTo(msg.sender, burnAmount, House.Scarred);
        }

        emit BonfireJoinScarred(msg.sender, burnAmount);
    }

    function setAllowedSigner(address _allowedSigner)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        require(_allowedSigner != address(0), "allowedSigner undefined");

        allowedSigner = _allowedSigner;
    }

    /*//////////////////////////////////////////////////////////////
                        EIP712 related logic
    //////////////////////////////////////////////////////////////*/

    /// @dev Verifies that a burn request is signed by an authorized account.
    function verify(BurnRequest calldata _req, bytes calldata _signature)
        public
        view
        returns (bool success, address signer)
    {
        signer = _recoverAddress(_req, _signature);
        success = !requestIdProcessed[_req.uid] && _canSignBurnRequest(signer);
    }

    /// @dev Returns whether a given address is authorized to sign burn requests.
    function _canSignBurnRequest(address _signer) internal view returns (bool) {
        return _signer == allowedSigner;
    }

    /// @dev Verifies a burn request and marks the request as processed.
    function _processRequest(
        BurnRequest calldata _req,
        bytes calldata _signature
    ) internal returns (address signer) {
        bool success;
        (success, signer) = verify(_req, _signature);

        if (!success) {
            revert("Invalid req");
        }

        if (
            _req.validityStartTimestamp > block.timestamp ||
            block.timestamp > _req.validityEndTimestamp
        ) {
            revert("Req expired");
        }
        require(_req.to != address(0), "recipient undefined");

        requestIdProcessed[_req.uid] = true;
    }

    /// @dev Returns the address of the signer of the burn request.
    function _recoverAddress(
        BurnRequest calldata _req,
        bytes calldata _signature
    ) internal view returns (address) {
        return
            _hashTypedDataV4(keccak256(_encodeRequest(_req))).recover(
                _signature
            );
    }

    /// @dev Resolves 'stack too deep' error in `recoverAddress`.
    function _encodeRequest(BurnRequest calldata _req)
        internal
        pure
        returns (bytes memory)
    {
        return
            abi.encode(
                TYPEHASH,
                _req.to,
                _req.wpBurnAmount,
                keccak256(abi.encodePacked(_req.diceIds)),
                keccak256(abi.encodePacked(_req.diceResults)),
                keccak256(abi.encodePacked(_req.wpHouses)),
                _req.validityStartTimestamp,
                _req.validityEndTimestamp,
                _req.uid
            );
    }

    /*//////////////////////////////////////////////////////////////
                            Pausable Logic
    //////////////////////////////////////////////////////////////*/

    function pause() external onlyRole(PAUSER_ROLE) whenNotPaused {
        _pause();
    }

    function unpause() external onlyRole(PAUSER_ROLE) whenPaused {
        _unpause();
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)
// Modified context dependency to work with thirdweb's ecosystem

pragma solidity ^0.8.0;

import "@thirdweb-dev/contracts/openzeppelin-presets/utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IWorldPassNFT.sol";

interface IBonfire {
    /**
     *  @notice The body of a request to burn old WP & mint new, including dice roll.
     *
     *  @param to The owner of rolled dice & burnt WPs, and receiver of the WP tokens to mint.
     *  @param wpBurnAmount The amount of 1155 WPs to burn. Needs to be <= the amount of WPs owned by `to` address.
     *  @param diceIds Array of original Dice NFT IDs to be reforged (burn old & mint new).
     *  @param diceResults Array of the dice roll results (totals).
     *  @param wpIds Array of the new WP IDs to mint.
     *  @param validityStartTimestamp The unix timestamp after which the payload is valid.
     *  @param validityEndTimestamp The unix timestamp at which the payload expires.
     *  @param uid A unique identifier for the payload.
     */
    struct BurnRequest {
        address to;
        uint128 wpBurnAmount;
        uint256[] diceIds;
        uint8[] diceResults;
        uint8[] wpHouses;
        uint128 validityStartTimestamp;
        uint128 validityEndTimestamp;
        bytes32 uid;
    }

    /// @dev Emitted on Bonfire Burn call.
    event BonfireBurn(address indexed mintedTo, BurnRequest burnRequest);

    /// @dev Emitted on Bonfire burnDiceOnly call.
    event BonfireBurnDiceOnly(
        address indexed mintedTo,
        uint256[] indexed burntDiceIDs
    );

    /// @dev Emitted on Bonfire joinScarred call.
    event BonfireJoinScarred(
        address indexed mintedTo,
        uint256 indexed burnAmount
    );

    /**
     *  @notice Verifies that a burn request is signed by a specific account
     *
     *  @param req The payload / burn request.
     *  @param signature The signature produced by an account signing the burn request.
     *
     *  returns (success, signer) Result of verification and the recovered address.
     */
    function verify(BurnRequest calldata req, bytes calldata signature)
        external
        view
        returns (bool success, address signer);

    /**
     *  @notice Mints tokens according to the provided mint request.
     *
     *  @param req The payload / mint request.
     *  @param signature The signature produced by an account signing the mint request.
     *
     *  returns (signer) the recovered address.
     */
    function bonfireBurn(BurnRequest calldata req, bytes calldata signature)
        external
        returns (address signer);

    /**
     *  @notice Allows caller to burn their old dice to mint new ones.
     *
     *  @param diceIds The diceIds to burn & re-mint from new contract.
     */
    function burnDiceOnly(uint256[] calldata diceIds) external;

    /**
     *  @notice Allows caller to burn their old wp to mint new WPs with "Scarred" attribute.
     *
     *  @param burnAmount The amount of old WPs to burn & re-mint from new contract.
     */
    function joinScarred(uint256 burnAmount) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

enum Material {
    Amber,
    Amethyst,
    Ruby,
    Sapphire,
    Spinel,
    Topaz
}

enum DieType {
    D4,
    D6,
    D8,
    D10,
    D12,
    D20
}

enum ElementalType {
    Dark,
    Space,
    Time,
    Psychic,
    Light
}

library MaterialUtil {
    function toString(Material _material)
        internal
        pure
        returns (string memory)
    {
        if (_material == Material.Amber) {
            return "Amber";
        } else if (_material == Material.Amethyst) {
            return "Amethyst";
        } else if (_material == Material.Ruby) {
            return "Ruby";
        } else if (_material == Material.Sapphire) {
            return "Sapphire";
        } else if (_material == Material.Spinel) {
            return "Spinel";
        } else {
            return "Topaz";
        }
    }
}

library DiceTypeUtil {
    function toString(DieType _type) internal pure returns (string memory) {
        if (_type == DieType.D4) {
            return "D4";
        } else if (_type == DieType.D6) {
            return "D6";
        } else if (_type == DieType.D8) {
            return "D8";
        } else if (_type == DieType.D10) {
            return "D10";
        } else if (_type == DieType.D12) {
            return "D12";
        } else {
            return "D20";
        }
    }
}

library ElementalTypeUtil {
    function toString(ElementalType _el) internal pure returns (string memory) {
        if (_el == ElementalType.Dark) {
            return "Dark";
        } else if (_el == ElementalType.Space) {
            return "Space";
        } else if (_el == ElementalType.Time) {
            return "Time";
        } else if (_el == ElementalType.Psychic) {
            return "Psychic";
        } else {
            return "Light";
        }
    }
}

library DiceBitmapUtil {
    function getDiceType(uint48 bitmap, uint8 diceIdx)
        internal
        pure
        returns (DieType)
    {
        // 3 bits type, then 3 bits material. This is repeated 7 times perDiceIdx
        uint256 shiftAmount = diceIdx * 6;
        // 7 as mask, which is 111, to get three bits
        uint8 typeBit = uint8((bitmap & (7 << shiftAmount)) >> shiftAmount);
        return DieType(typeBit);
    }

    function getDiceMaterial(uint48 bitmap, uint8 diceIdx)
        internal
        pure
        returns (Material)
    {
        uint256 shiftAmount = diceIdx * 6 + 3;
        uint8 typeBit = uint8((bitmap & (7 << shiftAmount)) >> shiftAmount);
        return Material(typeBit);
    }

    function getElementType(uint48 bitmap)
        internal
        pure
        returns (ElementalType)
    {
        uint256 shiftAmount = 7 * 6; // after last/7th dice
        uint8 typeBit = uint8((bitmap & (7 << shiftAmount)) >> shiftAmount);
        return ElementalType(typeBit);
    }
}

interface IDiceNFT {
    struct DiceMetadata {
        uint48 bitmap;
        uint8 amount;
        uint8 power;
    }

    event BoostUpdated(uint256 indexed tokenId, uint256 newBoostCount);

    function setOriginalMetadata(
        DiceMetadata[] calldata originalMetadata,
        uint128 _startIndex,
        uint128 _endIndex
    ) external;

    function resetBoosts(uint256 _newDefaultBoostCount) external;

    function useBoost(uint256 tokenId, uint256 count) external;

    function setBoostCount(uint256 tokenId, uint16 boostCount) external;

    function mint(address _to, uint256 _oldTokenId) external;

    function batchMint(address _to, uint256[] calldata _oldTokenIds) external;

    function getDiceBoosts(uint256 _tokenId) external view returns (uint256);

    function getDiceMaterials(uint256 _tokenId)
        external
        view
        returns (string[] memory);

    function getDiceMetadata(uint256 _tokenId)
        external
        view
        returns (DiceMetadata memory);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

enum House {
    Scarred,
    Arms,
    Hearts,
    Sight,
    Hearing,
    Shadows
}

library HouseUtil {
    function toString(House _house) internal pure returns (string memory) {
        if (_house == House.Arms) {
            return "Arms";
        } else if (_house == House.Hearts) {
            return "Hearts";
        } else if (_house == House.Sight) {
            return "Sight";
        } else if (_house == House.Hearing) {
            return "Hearing";
        } else if (_house == House.Shadows) {
            return "Shadows";
        } else {
            return "Scarred";
        }
    }
}

interface IWorldPassNFT {
    struct TokenData {
        bool __exists;

        House house;
    }

    function setTokenHouse(uint256 _tokenId, House _house) external;

    function getTokenHouse(uint256 _tokenId) external view returns (House);

    function getRemainingHouseSupply(House _house) external view returns (uint256);

    function mintWithHouseTo(address _to, House _house) external;

    function batchMintWithHouseTo(
        address _to,
        uint256 _quantity,
        House _house
    ) external;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

interface IOldDiceNFT {
    error ApprovalCallerNotOwnerNorApproved();
    error ApprovalQueryForNonexistentToken();
    error ApprovalToCurrentOwner();
    error ApproveToCaller();
    error BalanceQueryForZeroAddress();
    error MintToZeroAddress();
    error MintZeroQuantity();
    error OwnerQueryForNonexistentToken();
    error TransferCallerNotOwnerNorApproved();
    error TransferFromIncorrectOwner();
    error TransferToNonERC721ReceiverImplementer();
    error TransferToZeroAddress();
    error URIQueryForNonexistentToken();
    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );
    event ContractURIUpdated(string prevURI, string newURI);
    event DefaultRoyalty(
        address indexed newRoyaltyRecipient,
        uint256 newRoyaltyBps
    );
    event OwnerUpdated(address indexed prevOwner, address indexed newOwner);
    event RoyaltyForToken(
        uint256 indexed tokenId,
        address indexed royaltyRecipient,
        uint256 royaltyBps
    );
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    function airdrop(address[] memory _addresses, uint256[] memory _amounts)
        external;

    function approve(address to, uint256 tokenId) external;

    function balanceOf(address owner) external view returns (uint256);

    function burn(uint256 _tokenId) external;

    function contractURI() external view returns (string memory);

    function getApproved(uint256 tokenId) external view returns (address);

    function getDefaultRoyaltyInfo() external view returns (address, uint16);

    function getRoyaltyInfoForToken(uint256 _tokenId)
        external
        view
        returns (address, uint16);

    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);

    function multicall(bytes[] memory data)
        external
        returns (bytes[] memory results);

    function name() external view returns (string memory);

    function owner() external view returns (address);

    function ownerOf(uint256 tokenId) external view returns (address);

    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) external;

    function setApprovalForAll(address operator, bool approved) external;

    function setBaseURI(string memory _uri) external;

    function setContractURI(string memory _uri) external;

    function setDefaultRoyaltyInfo(
        address _royaltyRecipient,
        uint256 _royaltyBps
    ) external;

    function setOwner(address _newOwner) external;

    function setRoyaltyInfoForToken(
        uint256 _tokenId,
        address _recipient,
        uint256 _bps
    ) external;

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 _tokenId) external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

interface IOldWorldPass {
    error Ownable__NotAuthorized();
    error PlatformFee__ExceedsMaxBps(uint256 platformFeeBps);
    error PlatformFee__NotAuthorized();
    error PrimarySale__NotAuthorized();
    error Royalty__ExceedsMaxBps(uint256 royaltyBps);
    error Royalty__NotAuthorized();
    event ApprovalForAll(
        address indexed account,
        address indexed operator,
        bool approved
    );
    event ClaimConditionsUpdated(
        uint256 indexed tokenId,
        IDropClaimCondition.ClaimCondition[] claimConditions
    );
    event DefaultRoyalty(
        address indexed newRoyaltyRecipient,
        uint256 newRoyaltyBps
    );
    event MaxTotalSupplyUpdated(uint256 tokenId, uint256 maxTotalSupply);
    event MaxWalletClaimCountUpdated(uint256 tokenId, uint256 count);
    event OwnerUpdated(address indexed prevOwner, address indexed newOwner);
    event PlatformFeeInfoUpdated(
        address indexed platformFeeRecipient,
        uint256 platformFeeBps
    );
    event PrimarySaleRecipientUpdated(address indexed recipient);
    event RoleAdminChanged(
        bytes32 indexed role,
        bytes32 indexed previousAdminRole,
        bytes32 indexed newAdminRole
    );
    event RoleGranted(
        bytes32 indexed role,
        address indexed account,
        address indexed sender
    );
    event RoleRevoked(
        bytes32 indexed role,
        address indexed account,
        address indexed sender
    );
    event RoyaltyForToken(
        uint256 indexed tokenId,
        address indexed royaltyRecipient,
        uint256 royaltyBps
    );
    event SaleRecipientForTokenUpdated(
        uint256 indexed tokenId,
        address saleRecipient
    );
    event TokensClaimed(
        uint256 indexed claimConditionIndex,
        uint256 indexed tokenId,
        address indexed claimer,
        address receiver,
        uint256 quantityClaimed
    );
    event TokensLazyMinted(
        uint256 startTokenId,
        uint256 endTokenId,
        string baseURI
    );
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );
    event TransferSingle(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 value
    );
    event URI(string value, uint256 indexed id);
    event WalletClaimCountUpdated(
        uint256 tokenId,
        address indexed wallet,
        uint256 count
    );

    function DEFAULT_ADMIN_ROLE() external view returns (bytes32);

    function balanceOf(address account, uint256 id)
        external
        view
        returns (uint256);

    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        external
        view
        returns (uint256[] memory);

    function burn(
        address account,
        uint256 id,
        uint256 value
    ) external;

    function burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory values
    ) external;

    function claim(
        address _receiver,
        uint256 _tokenId,
        uint256 _quantity,
        address _currency,
        uint256 _pricePerToken,
        bytes32[] memory _proofs,
        uint256 _proofMaxQuantityPerTransaction
    ) external payable;

    function claimCondition(uint256)
        external
        view
        returns (uint256 currentStartId, uint256 count);

    function contractType() external pure returns (bytes32);

    function contractURI() external view returns (string memory);

    function contractVersion() external pure returns (uint8);

    function getActiveClaimConditionId(uint256 _tokenId)
        external
        view
        returns (uint256);

    function getClaimConditionById(uint256 _tokenId, uint256 _conditionId)
        external
        view
        returns (IDropClaimCondition.ClaimCondition memory condition);

    function getClaimTimestamp(
        uint256 _tokenId,
        uint256 _conditionId,
        address _claimer
    )
        external
        view
        returns (uint256 lastClaimTimestamp, uint256 nextValidClaimTimestamp);

    function getDefaultRoyaltyInfo() external view returns (address, uint16);

    function getPlatformFeeInfo() external view returns (address, uint16);

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function getRoleMember(bytes32 role, uint256 index)
        external
        view
        returns (address);

    function getRoleMemberCount(bytes32 role) external view returns (uint256);

    function getRoyaltyInfoForToken(uint256 _tokenId)
        external
        view
        returns (address, uint16);

    function grantRole(bytes32 role, address account) external;

    function hasRole(bytes32 role, address account)
        external
        view
        returns (bool);

    function initialize(
        address _defaultAdmin,
        string memory _name,
        string memory _symbol,
        string memory _contractURI,
        address[] memory _trustedForwarders,
        address _saleRecipient,
        address _royaltyRecipient,
        uint128 _royaltyBps,
        uint128 _platformFeeBps,
        address _platformFeeRecipient
    ) external;

    function isApprovedForAll(address account, address operator)
        external
        view
        returns (bool);

    function isTrustedForwarder(address forwarder) external view returns (bool);

    function lazyMint(uint256 _amount, string memory _baseURIForTokens)
        external;

    function maxTotalSupply(uint256) external view returns (uint256);

    function maxWalletClaimCount(uint256) external view returns (uint256);

    function multicall(bytes[] memory data)
        external
        returns (bytes[] memory results);

    function name() external view returns (string memory);

    function nextTokenIdToMint() external view returns (uint256);

    function owner() external view returns (address);

    function primarySaleRecipient() external view returns (address);

    function renounceRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;

    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external;

    function saleRecipient(uint256) external view returns (address);

    function setApprovalForAll(address operator, bool approved) external;

    function setClaimConditions(
        uint256 _tokenId,
        IDropClaimCondition.ClaimCondition[] memory _phases,
        bool _resetClaimEligibility
    ) external;

    function setContractURI(string memory _uri) external;

    function setDefaultRoyaltyInfo(
        address _royaltyRecipient,
        uint256 _royaltyBps
    ) external;

    function setMaxTotalSupply(uint256 _tokenId, uint256 _maxTotalSupply)
        external;

    function setMaxWalletClaimCount(uint256 _tokenId, uint256 _count) external;

    function setOwner(address _newOwner) external;

    function setPlatformFeeInfo(
        address _platformFeeRecipient,
        uint256 _platformFeeBps
    ) external;

    function setPrimarySaleRecipient(address _saleRecipient) external;

    function setRoyaltyInfoForToken(
        uint256 _tokenId,
        address _recipient,
        uint256 _bps
    ) external;

    function setSaleRecipientForToken(uint256 _tokenId, address _saleRecipient)
        external;

    function setWalletClaimCount(
        uint256 _tokenId,
        address _claimer,
        uint256 _count
    ) external;

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

    function symbol() external view returns (string memory);

    function totalSupply(uint256) external view returns (uint256);

    function uri(uint256 _tokenId)
        external
        view
        returns (string memory _tokenURI);

    function verifyClaim(
        uint256 _conditionId,
        address _claimer,
        uint256 _tokenId,
        uint256 _quantity,
        address _currency,
        uint256 _pricePerToken,
        bool verifyMaxQuantityPerTransaction
    ) external view;

    function verifyClaimMerkleProof(
        uint256 _conditionId,
        address _claimer,
        uint256 _tokenId,
        uint256 _quantity,
        bytes32[] memory _proofs,
        uint256 _proofMaxQuantityPerTransaction
    ) external view returns (bool validMerkleProof, uint256 merkleProofIndex);

    function walletClaimCount(uint256, address) external view returns (uint256);
}

interface IDropClaimCondition {
    struct ClaimCondition {
        uint256 startTimestamp;
        uint256 maxClaimableSupply;
        uint256 supplyClaimed;
        uint256 quantityLimitPerTransaction;
        uint256 waitTimeInSecondsBetweenClaims;
        bytes32 merkleRoot;
        uint256 pricePerToken;
        address currency;
    }
}