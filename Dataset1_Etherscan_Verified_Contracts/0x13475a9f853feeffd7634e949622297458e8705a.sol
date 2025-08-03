// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

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
// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { LogosTypes as L } from "./LogosTypes.sol";

contract LogosTraits is Ownable {
    
    mapping (uint8 => L.CharacterInfo) private _charactersByID;
    mapping (uint8 => L.ShapeInfo) private _shapesPrimaryByID;
    mapping (uint8 => L.ShapeInfo) private _shapesSecondaryByID;
    mapping (uint16 => L.ColorPalette) private _colorPalettesByID;

    event CharacterInfoAdded(uint8 id, L.CharacterInfo info);
    event PrimaryShapeInfoAdded(uint8 id, L.ShapeInfo info);
    event SecondaryShapeInfoAdded(uint8 id, L.ShapeInfo info);
    event ColorPaletteAdded(uint16 id, L.ColorPalette info);
    event CharactersEnabled(uint8 startID, uint8 endID);
    event PrimaryShapesEnabled(uint8 startID, uint8 endID);
    event SecondaryShapesEnabled(uint8 startID, uint8 endID);
    event ColorPalettesEnabled(uint16 startID, uint16 endID);
    event CharacterInfoRemoved(uint8 id);
    event PrimaryShapeInfoRemoved(uint8 id);
    event SecondaryShapeInfoRemoved(uint8 id);
    event ColorPaletteRemoved(uint16 id);
    
    constructor() Ownable() {
        
    }

    function charactersByID(uint8 id) external view returns (L.CharacterInfo memory) {
        return _charactersByID[id];
    }

    function shapesPrimaryByID(uint8 id) external view returns (L.ShapeInfo memory) {
        return _shapesPrimaryByID[id];
    }

    function shapesSecondaryByID(uint8 id) external view returns (L.ShapeInfo memory) {
        return _shapesSecondaryByID[id];
    }

    function colorPalettesByID(uint16 id) external view returns (L.ColorPalette memory) {
        return _colorPalettesByID[id];
    }

    function addCharacterInfo(uint8 id, L.CharacterInfo calldata info) external onlyOwner {
        _charactersByID[id] = info;
        emit CharacterInfoAdded(id, info);
    }
    
    function addPrimaryShapeInfo(uint8 id, L.ShapeInfo memory info) external onlyOwner {
        _shapesPrimaryByID[id] = info;
        emit PrimaryShapeInfoAdded(id, info);
    }

    function addSecondaryShapeInfo(uint8 id, L.ShapeInfo memory info) external onlyOwner {
        _shapesSecondaryByID[id] = info;
        emit SecondaryShapeInfoAdded(id, info);
    }

    function addColorPalette(uint16 id, L.ColorPalette memory info) external onlyOwner {
        _colorPalettesByID[id] = info;
        emit ColorPaletteAdded(id, info);
    }

    function enableCharacters(uint8 startID, uint8 endID) external onlyOwner {
        for (uint8 i = startID; i <= endID; i++) {
            _charactersByID[i].enabled = true;
        }
        emit CharactersEnabled(startID, endID);
    }

    function enablePrimaryShapes(uint8 startID, uint8 endID) external onlyOwner {
        for (uint8 i = startID; i <= endID; i++) {
            _shapesPrimaryByID[i].enabled = true;
        }
        emit PrimaryShapesEnabled(startID, endID);
    }

    function enableSecondaryShapes(uint8 startID, uint8 endID) external onlyOwner {
        for (uint8 i = startID; i <= endID; i++) {
            _shapesSecondaryByID[i].enabled = true;
        }
        emit SecondaryShapesEnabled(startID, endID);
    }

    function enableColorPalettes(uint16 startID, uint16 endID) external onlyOwner {
        for (uint16 i = startID; i <= endID; i++) {
            _colorPalettesByID[i].enabled = true;
        }
        emit ColorPalettesEnabled(startID, endID);
    }

    function removeCharacterInfo(uint8 id) external onlyOwner {
        delete _charactersByID[id];
        emit CharacterInfoRemoved(id);
    }

    function removePrimaryShapeInfo(uint8 id) external onlyOwner {
        delete _shapesPrimaryByID[id];
        emit PrimaryShapeInfoRemoved(id);
    }

    function removeSecondaryShapeInfo(uint8 id) external onlyOwner {
        delete _shapesSecondaryByID[id];
        emit SecondaryShapeInfoRemoved(id);
    }

    function removeColorPalette(uint16 id) external onlyOwner {
        delete _colorPalettesByID[id];
        emit ColorPaletteRemoved(id);
    }
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.20;

library LogosTypes {
    struct TraitChoice {
        string name;
        bool isBonus;
    }

    struct CharacterInfo {
        string name;
        TraitChoice[] bodies;
        TraitChoice[] heads;
        string[] slotNames;
        uint8[] slotOffsets;
        TraitChoice[] slotOptions;
        bool enabled;
    }

    struct ShapeInfo {
        string name;
        string companyName;
        uint8 numVariants; // number of ADDITIONAL variants, not including the base
        bool enabled;
    }

    struct ColorPalette {
        string name;
        bool isBonus;
        string colorA;
        string colorB;
        bool enabled;
    }

    struct CharacterSelections {
        uint8 characterID;
        uint8 body;
        uint8 head;
        uint8[] slotSelections;
    }

    struct ShapeSelections {
        uint8 primaryShape;
        uint8 primaryShapeVariant;
        uint8 secondaryShape;
        uint8 secondaryShapeVariant;
    }

    struct Logo {
        bool enabled;
        CharacterSelections characterSelections;
        ShapeSelections shapeSelections;
        uint16 colorPalette;
    }
}