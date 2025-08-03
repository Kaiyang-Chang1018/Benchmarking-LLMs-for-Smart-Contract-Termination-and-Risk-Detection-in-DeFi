// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "./libs/Ownable.sol";

contract ElementDrop is Ownable {

    // methodID -> implementation
    mapping(bytes4 => address) private implementations;

    event MethodUpdated(bytes4 indexed methodID, address oldImpl, address newImpl);

    function registerMethods(address impl, bytes4[] calldata methodIDs) external onlyOwner {
        if (impl != address(0)) {
            require(impl.code.length > 0, "Invalid implementation address");
        }
        for (uint256 i = 0; i < methodIDs.length; i++) {
            bytes4 methodID = methodIDs[i];
            address oldImpl = implementations[methodID];
            implementations[methodID] = impl;
            emit MethodUpdated(methodID, oldImpl, impl);
        }
    }

    function getMethodImplementation(bytes4 methodID) external view returns (address) {
        return implementations[methodID];
    }

    receive() external payable {}

    fallback() external payable {
        address impl = implementations[msg.sig];
        require(impl != address(0), "Not implemented method.");
        assembly {
            calldatacopy(0, 0, calldatasize())

            if delegatecall(gas(), impl, 0, calldatasize(), 0, 0) {
                returndatacopy(0, 0, returndatasize())
                return(0, returndatasize())
            }

            returndatacopy(0, 0, returndatasize())
            revert(0, returndatasize())
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "../storage/LibOwnableStorage.sol";


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
abstract contract Ownable {

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(tx.origin);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return LibOwnableStorage.getStorage().owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
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
    function _transferOwnership(address newOwner) private {
        LibOwnableStorage.Storage storage stor = LibOwnableStorage.getStorage();
        address oldOwner = stor.owner;
        stor.owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;


library LibOwnableStorage {

    uint256 constant STORAGE_ID_OWNABLE = 1 << 128;

    struct Storage {
        address owner;
    }

    /// @dev Get the storage bucket for this contract.
    function getStorage() internal pure returns (Storage storage stor) {
        assembly { stor.slot := STORAGE_ID_OWNABLE }
    }
}