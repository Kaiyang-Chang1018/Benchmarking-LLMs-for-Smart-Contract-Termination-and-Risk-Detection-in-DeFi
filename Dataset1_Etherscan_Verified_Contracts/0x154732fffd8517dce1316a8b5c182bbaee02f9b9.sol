// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(account),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleGranted} event.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleRevoked} event.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     *
     * May emit a {RoleRevoked} event.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * May emit a {RoleGranted} event.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleGranted} event.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
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
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Strings.sol)

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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/cryptography/MerkleProof.sol)

pragma solidity ^0.8.0;

/**
 * @dev These functions deal with verification of Merkle Tree proofs.
 *
 * The tree and the proofs can be generated using our
 * https://github.com/OpenZeppelin/merkle-tree[JavaScript library].
 * You will find a quickstart guide in the readme.
 *
 * WARNING: You should avoid using leaf values that are 64 bytes long prior to
 * hashing, or use a hash function other than keccak256 for hashing leaves.
 * This is because the concatenation of a sorted pair of internal nodes in
 * the merkle tree could be reinterpreted as a leaf value.
 * OpenZeppelin's JavaScript library generates merkle trees that are safe
 * against this attack out of the box.
 */
library MerkleProof {
    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     */
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    /**
     * @dev Calldata version of {verify}
     *
     * _Available since v4.7._
     */
    function verifyCalldata(
        bytes32[] calldata proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProofCalldata(proof, leaf) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merkle tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leafs & pre-images are assumed to be sorted.
     *
     * _Available since v4.4._
     */
    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Calldata version of {processProof}
     *
     * _Available since v4.7._
     */
    function processProofCalldata(bytes32[] calldata proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Returns true if the `leaves` can be simultaneously proven to be a part of a merkle tree defined by
     * `root`, according to `proof` and `proofFlags` as described in {processMultiProof}.
     *
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
     */
    function multiProofVerify(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) internal pure returns (bool) {
        return processMultiProof(proof, proofFlags, leaves) == root;
    }

    /**
     * @dev Calldata version of {multiProofVerify}
     *
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
     */
    function multiProofVerifyCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) internal pure returns (bool) {
        return processMultiProofCalldata(proof, proofFlags, leaves) == root;
    }

    /**
     * @dev Returns the root of a tree reconstructed from `leaves` and sibling nodes in `proof`. The reconstruction
     * proceeds by incrementally reconstructing all inner nodes by combining a leaf/inner node with either another
     * leaf/inner node or a proof sibling node, depending on whether each `proofFlags` item is true or false
     * respectively.
     *
     * CAUTION: Not all merkle trees admit multiproofs. To use multiproofs, it is sufficient to ensure that: 1) the tree
     * is complete (but not necessarily perfect), 2) the leaves to be proven are in the opposite order they are in the
     * tree (i.e., as seen from right to left starting at the deepest layer and continuing at the next layer).
     *
     * _Available since v4.7._
     */
    function processMultiProof(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuild the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        require(leavesLen + proof.length - 1 == totalHashes, "MerkleProof: invalid multiproof");

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value for the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i] ? leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++] : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            return hashes[totalHashes - 1];
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    /**
     * @dev Calldata version of {processMultiProof}.
     *
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
     */
    function processMultiProofCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuild the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        require(leavesLen + proof.length - 1 == totalHashes, "MerkleProof: invalid multiproof");

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value for the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i] ? leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++] : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            return hashes[totalHashes - 1];
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {
        return a < b ? _efficientHash(a, b) : _efficientHash(b, a);
    }

    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/Math.sol)

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
            return result + (rounding == Rounding.Up && 1 << (result * 8) < value ? 1 : 0);
        }
    }
}
/**
 *
 * Developed by
 *                        _       _             _ _
 *                       | |     | |           | (_)
 *     __ _ _ __ ___   __| |  ___| |_ _   _  __| |_  ___
 *    / _` | '__/ _ \ / _` | / __| __| | | |/ _` | |/ _ \
 *   | (_| | | | (_) | (_| |_\__ \ |_| |_| | (_| | | (_) |
 *    \__,_|_|  \___/ \__,_(_)___/\__|\__,_|\__,_|_|\___/
 *
 *
 * @title Auction contract
 * @author arod.studio and Fingerprints DAO
 * @dev This contract is used to auction Panopticon collection.
 * @notice This contract implements a Dutch Auction for NFTs (Non-Fungible Tokens).
 * The auction starts at a high price, decreasing over time until a bid is made or
 * a reserve price is reached. Users bid for a quantity of NFTs. They can withdraw
 * their funds after the auction, or claim a refund if conditions are met.
 * Additionally, users can claim additional NFTs using their prospective refunds
 * while the auction is ongoing.
 * The auction can be paused, unpaused, and configured by an admin.
 * Security features like reentrancy guard and overflow/underflow checks.
 *
 * SPDX-License-Identifier: MIT
 */

pragma solidity 0.8.17;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

import "./IDutchAuction.sol";
import "./INFT.sol";

/**
 * @title Dutch Auction Contract
 * @dev This contract manages a dutch auction for NFT tokens. Users can bid,
 * claim refunds, claim tokens, and admins can refund users.
 * The contract is pausable and non-reentrant for safety.
 */
contract DutchAuction is
  IDutchAuction,
  AccessControl,
  Pausable,
  ReentrancyGuard
{
  /// @notice Merkle root hash for discount addresses
  bytes32 public merkleRoot;

  /// @notice NFT contract address
  INFT public nftContractAddress;

  /// @notice Treasury address that will receive funds
  address public treasuryAddress;

  /// @dev Settled Price in wei
  uint256 private _settledPriceInWei;

  /// @dev Auction Config
  Config private _config;

  /// @dev Total minted tokens
  uint16 private _totalMinted;

  /// @dev Funds withdrawn or not
  bool private _withdrawn;

  /// @dev discount value in percentage
  uint16 constant discount = 100; // 10%

  /// @dev counter of discounted nfts sold
  uint16 private _discountedNFTs = 0;

  /// @dev Mapping of user address to User data
  mapping(address => User) private _userData;

  modifier validConfig() {
    if (_config.startTime == 0) revert ConfigNotSet();
    _;
  }

  modifier validTime() {
    Config memory config = _config;
    if (block.timestamp > config.endTime || block.timestamp < config.startTime)
      revert InvalidStartEndTime(config.startTime, config.endTime);
    _;
  }

  /// @notice DutchAuction Constructor
  /// @param _nftAddress NFT contract address
  /// @param _treasuryAddress Treasury address
  constructor(address _nftAddress, address _treasuryAddress) {
    nftContractAddress = INFT(_nftAddress);
    treasuryAddress = _treasuryAddress;

    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
  }

  /// @notice Change merkle root hash
  function setMerkleRoot(
    bytes32 merkleRootHash
  ) external onlyRole(DEFAULT_ADMIN_ROLE) {
    merkleRoot = merkleRootHash;
  }

  /// @notice Verify merkle proof of the address
  function verifyAddress(
    bytes32[] calldata _merkleProof,
    address _address
  ) private view returns (bool) {
    if (_merkleProof.length == 0) return false;
    bytes32 leaf = keccak256(abi.encodePacked(_address));
    return MerkleProof.verify(_merkleProof, merkleRoot, leaf);
  }

  function hasDiscount(
    bytes32[] calldata _merkleProof,
    address _address
  ) external view returns (bool) {
    return verifyAddress(_merkleProof, _address);
  }

  /// @notice Set auction config
  /// @dev Only admin can set auction config
  /// @param startAmountInWei Auction start amount in wei
  /// @param endAmountInWei Auction end amount in wei
  /// @param refundDelayTime Delay time which users need to wait to claim refund after the auction ends
  /// @param startTime Auction start time
  /// @param endTime Auction end time
  function setConfig(
    uint256 startAmountInWei,
    uint256 endAmountInWei,
    uint16 refundDelayTime,
    uint64 startTime,
    uint64 endTime
  ) external onlyRole(DEFAULT_ADMIN_ROLE) {
    if (_config.startTime != 0 && _config.startTime <= block.timestamp)
      revert ConfigAlreadySet();

    if (startTime == 0 || startTime >= endTime)
      revert InvalidStartEndTime(startTime, endTime);
    if (startAmountInWei == 0 || startAmountInWei <= endAmountInWei)
      revert InvalidAmountInWei();

    _settledPriceInWei = endAmountInWei;

    _config = Config({
      startAmountInWei: startAmountInWei,
      endAmountInWei: endAmountInWei,
      refundDelayTime: refundDelayTime,
      startTime: startTime,
      endTime: endTime
    });
  }

  /**
   * @dev Sets the address of the NFT contract.
   *
   * Requirements:
   * - Caller must have the DEFAULT_ADMIN_ROLE.
   * - New address must not be the zero address.
   *
   * @param newAddress The address of the new NFT contract.
   */
  function setNftContractAddress(
    address newAddress
  ) external onlyRole(DEFAULT_ADMIN_ROLE) {
    require(
      newAddress != address(0),
      "Invalid address: zero address not allowed"
    );
    nftContractAddress = INFT(newAddress);
  }

  /// @notice Sets treasury address
  /// @param _treasuryAddress New treasury address
  function setTreasuryAddress(
    address _treasuryAddress
  ) external onlyRole(DEFAULT_ADMIN_ROLE) {
    require(
      _treasuryAddress != address(0),
      "Invalid address: zero address not allowed"
    );
    treasuryAddress = _treasuryAddress;
  }

  /// @notice Pause the auction
  function pause() external onlyRole(DEFAULT_ADMIN_ROLE) {
    _pause();
  }

  /// @notice Unpause the auction
  function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {
    _unpause();
  }

  /// @notice Get auction config
  /// @return config Auction config
  function getConfig() external view returns (Config memory) {
    return _config;
  }

  /// @notice Get user data
  /// @param user User address
  /// @return User struct
  function getUserData(address user) external view returns (User memory) {
    return _userData[user];
  }

  /// @notice Get auction's settled price
  /// @return price Auction's settled price
  function getSettledPriceInWei() public view returns (uint256) {
    return _settledPriceInWei;
  }

  /// @notice Get auction's settled price with discount
  /// @return price Auction's settled price with _discount applied
  function getSettledPriceWithDiscountInWei() public view returns (uint256) {
    return _settledPriceInWei - ((_settledPriceInWei * discount) / 1000);
  }

  /// @notice Get auction's current price
  /// @return price Auction's current price
  function getCurrentPriceInWei() public view returns (uint256) {
    Config memory config = _config; // storage to memory
    // Return startAmountInWei if auction not started
    if (block.timestamp <= config.startTime) return config.startAmountInWei;
    // Return endAmountInWei if auction ended
    if (block.timestamp >= config.endTime) return config.endAmountInWei;

    // Declare variables to derive in the subsequent unchecked scope.
    uint256 duration;
    uint256 elapsed;
    uint256 remaining;

    // Skip underflow checks as startTime <= block.timestamp < endTime.
    unchecked {
      // Derive the duration for the order and place it on the stack.
      duration = config.endTime - config.startTime;

      // Derive time elapsed since the order started & place on stack.
      elapsed = block.timestamp - config.startTime;

      // Derive time remaining until order expires and place on stack.
      remaining = duration - elapsed;
    }

    return
      (config.startAmountInWei * remaining + config.endAmountInWei * elapsed) /
      duration;
  }

  /// @notice Make bid to purchase NFTs
  /// @param qty Amount of tokens to purchase
  function bid(
    uint16 qty,
    bytes32[] calldata _merkleProof
  ) external payable nonReentrant whenNotPaused validConfig validTime {
    if (qty < 1) revert InvalidQuantity();

    uint16 available = nftContractAddress.tokenIdMax() -
      nftContractAddress.currentTokenId();

    if (qty > available) {
      revert MaxSupplyReached();
    }

    uint256 price = getCurrentPriceInWei();
    if (msg.value < qty * price) revert NotEnoughValue();

    User storage bidder = _userData[msg.sender]; // get user's current bid total
    bidder.contribution = bidder.contribution + uint216(msg.value);
    bidder.tokensBidded = bidder.tokensBidded + qty;

    _totalMinted += qty;

    // @dev if it's the last bid, set the price as the settled price
    if (qty == available) {
      _settledPriceInWei = price;
    }

    if (verifyAddress(_merkleProof, msg.sender)) {
      _discountedNFTs += qty;
      bidder.tokensBiddedWithDiscount = bidder.tokensBiddedWithDiscount + qty;
    }

    // if (msg.value > payment) {
    //   uint256 refundInWei = msg.value - payment;
    //   (bool success, ) = msg.sender.call{value: refundInWei}("");
    //   if (!success) revert TransferFailed();
    // }
    // mint tokens to user
    _mintTokens(msg.sender, qty);

    emit Bid(msg.sender, qty, price, verifyAddress(_merkleProof, msg.sender));
  }

  /// @notice Return user's claimable tokens count
  /// @param user User address
  /// @return claimable Claimable tokens count
  function getClaimableTokens(
    address user
  ) public view returns (uint32 claimable) {
    User storage bidder = _userData[user]; // get user's current bid total
    uint256 price = getCurrentPriceInWei();
    claimable = uint32(bidder.contribution / price) - bidder.tokensBidded;
    uint16 available = nftContractAddress.tokenIdMax() -
      nftContractAddress.currentTokenId();
    if (claimable > available) claimable = available;
  }

  /// @notice Claim additional NFTs without additional payment
  /// @param amount Number of tokens to claim
  function claimTokens(
    uint16 amount,
    bytes32[] calldata _merkleProof
  ) external nonReentrant whenNotPaused validConfig validTime {
    User storage bidder = _userData[msg.sender]; // get user's current bid total
    uint256 price = getCurrentPriceInWei();
    uint32 claimable = getClaimableTokens(msg.sender);
    if (amount > claimable) amount = uint16(claimable);
    if (amount == 0) revert NothingToClaim();

    uint16 available = nftContractAddress.tokenIdMax() -
      nftContractAddress.currentTokenId();
    bidder.tokensBidded = bidder.tokensBidded + amount;
    _totalMinted += amount;

    if (amount == available) {
      _settledPriceInWei = price;
    }

    if (verifyAddress(_merkleProof, msg.sender)) {
      _discountedNFTs += amount;
      bidder.tokensBiddedWithDiscount =
        bidder.tokensBiddedWithDiscount +
        amount;
    }

    _mintTokens(msg.sender, amount);

    emit Claim(msg.sender, amount, verifyAddress(_merkleProof, msg.sender));
  }

  /// @notice Admin withdraw funds
  /// @dev Only admin can withdraw funds
  function withdrawFunds() external nonReentrant onlyRole(DEFAULT_ADMIN_ROLE) {
    if (_config.endTime >= block.timestamp) revert NotEnded();
    if (_withdrawn) revert AlreadyWithdrawn();
    _withdrawn = true;

    uint256 amountWithoutDiscount = (_totalMinted - _discountedNFTs) *
      getSettledPriceInWei();
    uint256 amountWithDiscount = _discountedNFTs *
      getSettledPriceWithDiscountInWei();
    uint256 amount = amountWithoutDiscount + amountWithDiscount;

    (bool success, ) = treasuryAddress.call{value: amount}("");
    if (!success) revert TransferFailed();
  }

  /**
   * @notice Allows a participant to claim their refund after the auction ends.
   * Refund is calculated based on the difference between their contribution and the final settled price.
   * This function can only be called after the refund delay time has passed post-auction end.
   * Note: If the function reverts with 'ClaimRefundNotReady', it means the refund delay time has not passed yet.
   */
  function claimRefund() external nonReentrant whenNotPaused validConfig {
    Config memory config = _config;
    if (config.endTime + config.refundDelayTime >= block.timestamp)
      revert ClaimRefundNotReady();

    _claimRefund(msg.sender);
  }

  /**
   * @notice Admin-enforced claim of refunds for a list of user addresses.
   * This function is identical to `claimRefund` but allows an admin to force
   * users to claim their refund. Can only be called after the refund delay time has passed post-auction end.
   * Only callable by addresses with the DEFAULT_ADMIN_ROLE.
   * Note: If the function reverts with 'ClaimRefundNotReady', it means the refund delay time has not passed yet.
   * @param accounts An array of addresses for which refunds will be claimed.
   */
  function refundUsers(
    address[] memory accounts
  )
    external
    nonReentrant
    whenNotPaused
    validConfig
    onlyRole(DEFAULT_ADMIN_ROLE)
  {
    Config memory config = _config;
    if (config.endTime + config.refundDelayTime >= block.timestamp)
      revert ClaimRefundNotReady();

    uint256 length = accounts.length;
    for (uint16 i = 0; i != length; ++i) {
      _claimRefund(accounts[i]);
    }
  }

  /**
   * @dev Internal function for processing refunds.
   * The function calculates the refund as the user's total contribution minus the amount spent on bidding.
   * It then sends the refund (if any) to the user's account.
   * Note: If the function reverts with 'UserAlreadyClaimed', it means the user has already claimed their refund.
   * @param account Address of the user claiming the refund.
   */
  function _claimRefund(address account) internal {
    User storage user = _userData[account];
    if (user.refundClaimed) revert UserAlreadyClaimed();
    user.refundClaimed = true;

    uint256 paidWithoutDiscount = (getSettledPriceInWei() *
      (user.tokensBidded - user.tokensBiddedWithDiscount));
    uint256 paidWithDiscount = (getSettledPriceWithDiscountInWei() *
      user.tokensBiddedWithDiscount);

    uint256 refundInWei = user.contribution -
      (paidWithDiscount + paidWithoutDiscount);

    if (refundInWei > 0) {
      (bool success, ) = account.call{value: refundInWei}("");
      if (!success) revert TransferFailed();
      emit ClaimRefund(account, refundInWei);
    }
  }

  /**
   * @dev Internal function to mint a specified quantity of NFTs for a recipient.
   * This function mints 'qty' number of NFTs to the 'to' address.
   * @param to Recipient address.
   * @param qty Number of NFTs to mint.
   */
  function _mintTokens(address to, uint16 qty) internal {
    for (uint16 i = 0; i != qty; ++i) {
      nftContractAddress.mint(to);
    }
  }
}
//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @title Dutch Auction Interface
/// @dev Defines the methods and structures for the Dutch Auction contract.
interface IDutchAuction {
  /// Errors
  /// @dev Emitted when trying to interact with the contract before its config is set.
  error ConfigNotSet();

  /// @dev Emitted when trying to set the contract config when it's already been set.
  error ConfigAlreadySet();

  /// @dev Emitted when the amount of wei provided is invalid.
  error InvalidAmountInWei();

  /// @dev Emitted when the start or end time is invalid.
  error InvalidStartEndTime(uint64 startTime, uint64 endTime);

  /// @dev Emitted when the quantity provided is invalid.
  error InvalidQuantity();

  /// @dev Emitted when trying to interact with the contract before the auction has ended.
  error NotEnded();

  /// @dev Emitted when the value provided is not enough for the desired action.
  error NotEnoughValue();

  /// @dev Emitted when trying to request a refund when not eligible.
  error NotRefundable();

  /// @dev Emitted when trying to interact with the contract before the auction has started.
  error NotStarted();

  /// @dev Emitted when a transfer fails.
  error TransferFailed();

  /// @dev Emitted when a user tries to claim a refund that they've already claimed.
  error UserAlreadyClaimed();

  /// @dev Emitted when a bid has expired.
  error BidExpired(uint256 deadline);

  /// @dev Emitted when trying to claim a refund before the refund time is ready.
  error ClaimRefundNotReady();

  /// @dev Emitted when there's nothing to claim.
  error NothingToClaim();

  /// @dev Emitted when funds have already been withdrawn.
  error AlreadyWithdrawn();

  /// @dev Emitted when the max supply is reached.
  error MaxSupplyReached();
  /// @dev Represents a user in the auction

  struct User {
    /// @notice The total amount of ETH contributed by the user.
    uint216 contribution;
    /// @notice The total number of tokens bidded by the user. Includes tokensBiddedWithDiscount.
    uint16 tokensBidded;
    /// @notice The total number of tokens bidded by the user with discount.
    uint16 tokensBiddedWithDiscount;
    /// @notice A flag indicating if the user has claimed a refund.
    bool refundClaimed;
  }

  /// @dev Represents the auction configuration
  struct Config {
    /// @notice The initial amount per token in wei when the auction starts.
    uint256 startAmountInWei;
    /// @notice The final amount per token in wei when the auction ends.
    uint256 endAmountInWei;
    /// @notice The maximum contribution allowed per user in wei.
    /// @notice The delay time for a refund to be available.
    uint32 refundDelayTime;
    /// @notice The start time of the auction.
    uint64 startTime;
    /// @notice The end time of the auction.
    uint64 endTime;
  }
  /// @dev Emitted when a user claims a refund.
  /// @param user The address of the user claiming the refund.
  /// @param refundInWei The amount of the refund in Wei.
  event ClaimRefund(address user, uint256 refundInWei);

  /// @dev Emitted when a user places a bid.
  /// @param user The address of the user placing the bid.
  /// @param qty The quantity of tokens the user is bidding for.
  /// @param price The total price of the bid in Wei.
  event Bid(address user, uint32 qty, uint256 price, bool withDiscount);

  /// @dev Emitted when a user claims their tokens after the auction.
  /// @param user The address of the user claiming the tokens.
  /// @param qty The quantity of tokens claimed.
  event Claim(address user, uint32 qty, bool withDiscount);
}
//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface INFT {
  function tokenIdMax() external view returns (uint16);

  function currentTokenId() external view returns (uint16);

  function mint(address to) external;
}