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
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IERC721 {
    function ownerOf(uint256 tokenId) external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function mintFromContract(uint256 cId, address to) external;
}

contract MeshionicsResearchTier1 is Ownable {
    address public cardContractAddress;
    address public holoContractAddress;
    bool public isClaimable = true;
    
    mapping(uint256 => uint256) public totalResearchBlocks;
    mapping(uint256 => uint256) public startBlock;
    mapping(uint256 => bool) public idClaimed;

    constructor(address _cardContractAddress, address _holoContractAddress) {
        cardContractAddress = _cardContractAddress;
        holoContractAddress = _holoContractAddress;
    }
    
    function flipClaimable() external onlyOwner() {
        isClaimable = !isClaimable;
    }

    function claimResearchCardDrop(uint256 tokenId) external {
        require(idClaimed[tokenId] == false, "ALREADY CLAIMED");
        require(IERC721(holoContractAddress).ownerOf(tokenId) == msg.sender, "NOT OWNER");
        require(isClaimable, "NOT CLAIMABLE");

        idClaimed[tokenId] = true;
        IERC721(cardContractAddress).mintFromContract(0, msg.sender);
    }

    function startResearch(uint256 tokenId) external {
        require(IERC721(cardContractAddress).ownerOf(tokenId) == msg.sender, "NOT OWNER");
        require(IERC721(holoContractAddress).balanceOf(msg.sender) > 0, "MUST OWN A HOLOFACT");
        require(startBlock[tokenId] == 0, "IS ALREADY RESEARCHING");

        startBlock[tokenId] = block.number;
    }

    function stopResearch(uint256 tokenId) external {
        require(IERC721(cardContractAddress).ownerOf(tokenId) == msg.sender, "NOT OWNER");
        require(IERC721(holoContractAddress).balanceOf(msg.sender) > 0, "MUST OWN A HOLOFACT");
        require(startBlock[tokenId] != 0, "IS NOT RESEARCHING");

        totalResearchBlocks[tokenId] += block.number - startBlock[tokenId];
        startBlock[tokenId] = 0;
    }
}