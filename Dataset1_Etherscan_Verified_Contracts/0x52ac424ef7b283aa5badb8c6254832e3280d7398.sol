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
// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.13;

import "@solmate/auth/Owned.sol";
import "@solmate/utils/ReentrancyGuard.sol";

/// @title AddressManager
/// @notice A contract that handles a whitelist of addresses and their indexes.
/// @dev We assume no more than 65535 addresses will be added to the directory.
contract AddressManager is Owned, ReentrancyGuard {
    event AddressAdded(address address_added);

    event AddressRemovedFromWhitelist(address address_removed);

    event AddressWhitelisted(address address_whitelisted);

    error AddressAlreadyAddedError(address _address);

    error AddressNotAddedError(address _address);

    mapping(address => uint16) private _directory;

    mapping(uint16 => address) private _inverseDirectory;

    mapping(address => bool) private _whitelist;

    uint16 private _lastAdded;

    constructor(address[] memory _original) Owned(msg.sender) {
        uint256 total = _original.length;
        for (uint256 i; i < total; ) {
            _add(_original[i]);
            unchecked {
                ++i;
            }
        }
    }

    /// @notice Adds an address to the directory. If it already exists,
    ///        reverts. It assumes it's whitelisted.
    function add(
        address _entry
    ) external onlyOwner nonReentrant returns (uint16) {
        return _add(_entry);
    }

    /// @notice Whitelist an address that's already part of the directory.
    function addToWhitelist(address _entry) external onlyOwner {
        if (_directory[_entry] == 0) {
            revert AddressNotAddedError(_entry);
        }
        _whitelist[_entry] = true;

        emit AddressWhitelisted(_entry);
    }

    /// @notice Removes an address from the whitelist. We still keep it
    ///         in the directory since this mapping is relevant across time.
    /// @param _entry The address to remove from the whitelist.
    function removeFromWhitelist(address _entry) external onlyOwner {
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
        if (_directory[_entry] != 0) {
            revert AddressAlreadyAddedError(_entry);
        }
        ++_lastAdded;
        _directory[_entry] = _lastAdded;
        _inverseDirectory[_lastAdded] = _entry;
        _whitelist[_entry] = true;

        emit AddressAdded(_entry);

        return _lastAdded;
    }
}