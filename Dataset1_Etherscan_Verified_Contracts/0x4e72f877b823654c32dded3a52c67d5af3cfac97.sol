// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;

import {Context} from "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
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
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
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
// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

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
// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity ^0.8.0;

import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";

/// @title SnapshotRegistry
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice Revokeable append-only registry of addresses.
contract SnapshotRegistry is Ownable {
    struct Entry {
        /// @notice The timestamp when the address was added.
        uint128 addedAt;
        /// @notice The timestamp when the address was revoked.
        uint128 revokedAt;
    }

    /// @notice List of addresses by their base and quote asset.
    /// @dev The keys are lexicographically sorted (asset0 < asset1).
    mapping(address asset0 => mapping(address asset1 => address[])) internal map;

    /// @notice Addresses added to the registry.
    mapping(address => Entry) public entries;

    /// @notice An address was added to the registry.
    /// @param element The address added.
    /// @param asset0 The smaller address out of (base, quote).
    /// @param asset1 The larger address out of (base, quote).
    /// @param addedAt The timestamp when the address was added.
    event Added(address indexed element, address indexed asset0, address indexed asset1, uint256 addedAt);
    /// @notice An address was revoked from the registry.
    /// @param element The address revoked.
    /// @param revokedAt The timestamp when the address was revoked.
    event Revoked(address indexed element, uint256 revokedAt);

    /// @notice The address cannot be added because it already exists in the registry.
    error Registry_AlreadyAdded();
    /// @notice The address cannot be revoked because it does not exist in the registry.
    error Registry_NotAdded();
    /// @notice The address cannot be revoked because it was already revoked from the registry.
    error Registry_AlreadyRevoked();

    /// @notice Deploy SnapshotRegistry.
    /// @param _owner The address of the owner.
    constructor(address _owner) Ownable(_owner) {}

    /// @notice Adds an address to the registry.
    /// @param element The address to add.
    /// @param base The corresponding base asset.
    /// @param quote The corresponding quote asset.
    /// @dev Only callable by the owner.
    function add(address element, address base, address quote) external onlyOwner {
        Entry storage entry = entries[element];
        if (entry.addedAt != 0) revert Registry_AlreadyAdded();
        entry.addedAt = uint128(block.timestamp);

        (address asset0, address asset1) = _sort(base, quote);
        map[asset0][asset1].push(element);

        emit Added(element, asset0, asset1, block.timestamp);
    }

    /// @notice Revokes an address from the registry.
    /// @param element The address to revoke.
    /// @dev Only callable by the owner.
    function revoke(address element) external onlyOwner {
        Entry storage entry = entries[element];
        if (entry.addedAt == 0) revert Registry_NotAdded();
        if (entry.revokedAt != 0) revert Registry_AlreadyRevoked();
        entry.revokedAt = uint128(block.timestamp);
        emit Revoked(element, block.timestamp);
    }

    /// @notice Returns the all valid addresses for a given base and quote.
    /// @param base The address of the base asset.
    /// @param quote The address of the quote asset.
    /// @param snapshotTime The timestamp to check.
    /// @dev Order of base and quote does not matter.
    /// @return All addresses for base and quote valid at `snapshotTime`.
    function getValidAddresses(address base, address quote, uint256 snapshotTime)
        external
        view
        returns (address[] memory)
    {
        (address asset0, address asset1) = _sort(base, quote);
        address[] memory elements = map[asset0][asset1];
        address[] memory validElements = new address[](elements.length);

        uint256 numValid = 0;
        for (uint256 i = 0; i < elements.length; ++i) {
            address element = elements[i];
            if (isValid(element, snapshotTime)) {
                validElements[numValid++] = element;
            }
        }

        /// @solidity memory-safe-assembly
        assembly {
            // update the length
            mstore(validElements, numValid)
        }
        return validElements;
    }

    /// @notice Returns whether an address was valid at a point in time.
    /// @param element The address to check.
    /// @param snapshotTime The timestamp to check.
    /// @dev Returns false if:
    /// - address was never added,
    /// - address was added after the timestamp,
    /// - address was revoked before or at the timestamp.
    /// @return Whether `element` was valid at `snapshotTime`.
    function isValid(address element, uint256 snapshotTime) public view returns (bool) {
        uint256 addedAt = entries[element].addedAt;
        uint256 revokedAt = entries[element].revokedAt;

        if (addedAt == 0 || addedAt > snapshotTime) return false;
        if (revokedAt != 0 && revokedAt <= snapshotTime) return false;
        return true;
    }

    /// @notice Lexicographically sort two addresses.
    /// @param assetA One of the assets in the pair.
    /// @param assetB The other asset in the pair.
    /// @return The address first in lexicographic order.
    /// @return The address second in lexicographic order.
    function _sort(address assetA, address assetB) internal pure returns (address, address) {
        return assetA < assetB ? (assetA, assetB) : (assetB, assetA);
    }
}