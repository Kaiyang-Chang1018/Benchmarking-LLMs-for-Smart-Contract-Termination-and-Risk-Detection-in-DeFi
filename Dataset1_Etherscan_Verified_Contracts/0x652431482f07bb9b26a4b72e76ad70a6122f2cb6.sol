// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

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
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
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
// SPDX-FileCopyrightText: © Courtyard Inc. (https://courtyard.io)
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Strings.sol";


/**
 * The relevant interface of the Golden Egg Club NFT contract
 * Note: The deployed contract does not expose its token existence or supply accessors.
 */
interface IGoldenEggClub {
    function ownerOf(uint256 tokenId) external returns (address owner);
}


/**
 * The relevant interface of the Courtyard Registry contract
 */
interface ICourtyardRegistry {
    function generateProofOfIntegrity(string memory fingerprint, uint256 salt) external pure returns (bytes32);
    function getTokenId(bytes32 proofOfIntegrity) external view returns (uint256);
    function mintToken(address to, bytes32 proofOfIntegrity) external returns (uint256);
}


/**
 * @title Minter contract for the Golden Egg Club X Courtyard collaboration.
 * A few notes:
 *  - This contract handles the business logic behind the drop of a golden egg for the owners of the original Golden Egg Club NFT.
 *  - Each Golden Egg Club NFT owner can claim the corresponding golden egg that is secured by Courtyard.
 *  - A particular Golden Egg Club NFT can only be used once to claim the corresponding golden egg.
 *  - Before purchasing a Golden Egg Club NFT with the intent to claim the corresponding golden egg, please double check that
 * it has not been claimed yet. 
 */ 
contract GoldenEggClubXCourtyardDrop is Context, ReentrancyGuard, Ownable {

    using Strings for uint256;

    event GoldenEggClaimed(uint256 indexed goldenEggClubTokenId, address indexed claimer);

    IGoldenEggClub public immutable goldenEggClubContract;  // the Golden Egg Club NFT contract.
    ICourtyardRegistry public immutable courtyardRegistry;  // the address of the Courtyard registry that holds the golden egg.
    bool[222] _claimedGoldenEggs;                           // keeps track of the Golden Egg Club NFTs that were successfully claimed.
                                                            // indexes are shifted by 1, so that the Golden Egg Club NFTs with
                                                            // goldenEggClubTokenId {ii} is represented by _claimedGoldenEggs[ii-1]
    bool public isClaimingWindowOpen = false;               // flag used to control the claiming window.

    /* ================================================ CONSTRUCTOR ================================================ */

    /**
     * @dev Constructor.
     *  - Sets the Golden Egg Club NFT contract address. This cannot be changed.
     *  - Sets the Courtyard registry that holds the golden egg. This cannot be changed.
     */
    constructor(address goldenEggClubContractAddress, address courtyardRegistryAddress) {
        goldenEggClubContract = IGoldenEggClub(goldenEggClubContractAddress);
        courtyardRegistry = ICourtyardRegistry(courtyardRegistryAddress);
    }


    /* ========================================= CLAIMING WINDOW CONTROLS ========================================= */

    /**
     * @dev Check that the claiming window is open.
     */
    modifier onlyClaimingWindowOpen {
        require(isClaimingWindowOpen, "GoldenEggClubXCourtyardDrop: The claiming window is closed.");
        _ ;
    }

    /**
     * @dev Open the claiming window.
     */
    function openClaimingWindow() public onlyOwner {
        isClaimingWindowOpen = true;
    }    

    /**
     * @dev Close the claiming window.
     */
    function closeClaimingWindow() public onlyOwner {
        isClaimingWindowOpen = false;
    }


    /* ============================================= INTERNAL HELPERS ============================================= */

    /**
     * @dev helper function to convert a Golden Egg Club NFT's goldenEggClubTokenId to a padded string.
     * 
     *  - goldenEggClubTokenId 1 to 9 -> "001" to "009"
     *  - goldenEggClubTokenId 10 to 99 -> "010" to "099"
     *  - goldenEggClubTokenId 100 to 222 -> "100" to "222"
     * 
     * Optimization note: this function being private, it can only be called from within this smart contract,
     * and the calling function must have checked that the {goldenEggClubTokenId} is supported using the
     * {onlySupportedGoldenEggClubToken} modifier.
     */
    function _toPaddedString(uint256 goldenEggClubTokenId) private pure returns (string memory) {
        if (goldenEggClubTokenId < 10) {
            return string(abi.encodePacked("00", goldenEggClubTokenId.toString()));
        } else if (goldenEggClubTokenId < 100) {
            return string(abi.encodePacked("0", goldenEggClubTokenId.toString()));
        } else {
            return goldenEggClubTokenId.toString();
        }
    }

    /**
     * @dev construct the fingerprint for a particular golden egg, so that it can be used to 
     * generate the Proof of Integrity using the {courtyardRegistry}.
     * 
     * Optimization note: this function being private, it can only be called from within this smart contract,
     * and the calling function must have checked that the {goldenEggClubTokenId} is supported using the
     * {onlySupportedGoldenEggClubToken} modifier.
     */
    function _courtyardFingerprint(uint256 goldenEggClubTokenId) private pure returns (string memory) {
        string memory paddedTokenId = _toPaddedString(goldenEggClubTokenId);
        return string(abi.encodePacked("Golden Egg Club X Courtyard | 23K gold plated golden egg #", paddedTokenId, " | CYxGEC_GE_", paddedTokenId));    
    }

    /**
     * @dev get the Proof of Integrity of a golden egg that has been minted in the {courtyardRegistry}, given the 
     * token id of the corresponding original Golden Egg Club NFT.
     *
     * Optimization note: this function being private, it can only be called from within this smart contract,
     * and the calling function must have checked that the {goldenEggClubTokenId} is supported using the
     * {onlySupportedGoldenEggClubToken} modifier.
     */
    function _courtyardProofOfIntegrity(uint256 goldenEggClubTokenId) private view returns (bytes32) {
        return courtyardRegistry.generateProofOfIntegrity(_courtyardFingerprint(goldenEggClubTokenId), 0);
    }

    /**
     * @dev mark a particular {goldenEggClubTokenId} as claimed.
     */   
    function _markAsClaimed(uint256 goldenEggClubTokenId) private {
        _claimedGoldenEggs[goldenEggClubTokenId - 1] = true;
    }


    /* ============================================= EXTERNAL HELPERS ============================================= */

    /**
     * @dev modifier to ensure that a requested Golden Egg Club token id is supported, i.e. there is golden egg 
     * for it. This extra check will ensure that if the owner of the Golden Egg Club smart contract decides to mint new
     * tokens that were not accounted for in the scope of this project, the owners of those new tokens would not be able
     * to claim a non existent golden egg.
     * 
     * Note: The scope of this collaboration covers 222 Golden Egg Club NTFs with the token IDs ranging from 1 to 222.
     */
    modifier onlySupportedGoldenEggClubToken(uint256 goldenEggClubTokenId) {
        require(goldenEggClubTokenId > 0 && goldenEggClubTokenId <= 222, "GoldenEggClubXCourtyardDrop: Request for a non supported Golden Egg Club token.");
        _ ;
    }

    /**
     * @dev checks if a Golden Egg Club NFT is still available to claim.
     * @return true if the Golden Egg Club NFT can still be used to claim the corresponding golden egg, and
     * false if it has already been used.
     */
    function isClaimed(uint256 goldenEggClubTokenId) public view onlySupportedGoldenEggClubToken(goldenEggClubTokenId) returns (bool) {
        return _claimedGoldenEggs[goldenEggClubTokenId - 1];
    }

    /**
     * @dev construct the fingerprint for a particular golden egg, so that it can be used to 
     * generate the Proof of Integrity using the {courtyardRegistry}.
     * This also serves as a helper for external applications to deterministically create the
     * fingerprint of the golden eggs.
     * 
     * Requirement: the {goldenEggClubTokenId} must be supported.
     */
    function getCourtyardFingerprint(uint256 goldenEggClubTokenId) public pure onlySupportedGoldenEggClubToken(goldenEggClubTokenId) returns (string memory) {
        return _courtyardFingerprint(goldenEggClubTokenId);
    }

    /**
     * @dev get the token id of a golden egg that has been minted in the {courtyardRegistry}, given the 
     * token id of the corresponding original Golden Egg Club NFT.
     * This also serves as a helper for external applications to expose that token id. 
     * 
     * Requirement: the {goldenEggClubTokenId} must be supported.
     */
    function getCourtyardTokenId(uint256 goldenEggClubTokenId) public view onlySupportedGoldenEggClubToken(goldenEggClubTokenId) returns (uint256) {
        return courtyardRegistry.getTokenId(_courtyardProofOfIntegrity(goldenEggClubTokenId));
    }


    /* ================================================== MINTING ================================================== */

    /**
     * @dev Claim a golden egg.
     * 
     * Requirements:
     *  - the claiming window must be open.
     *  - the caller must own the Golden Egg Club NFT used to claim the corresponding golden egg.
     *  - the Golden Egg Club NFT used for the claim must not have been already used to claim the corresponding golden egg.
     */
    function claimGoldenEgg(uint256 goldenEggClubTokenId) external nonReentrant onlyClaimingWindowOpen onlySupportedGoldenEggClubToken(goldenEggClubTokenId) {
        address caller = _msgSender();
        require(goldenEggClubContract.ownerOf(goldenEggClubTokenId) == caller, "GoldenEggClubXCourtyardDrop: Caller does not own the Golden Egg Club NFT claimed.");
        require(!isClaimed(goldenEggClubTokenId), "GoldenEggClubXCourtyardDrop: Golden Egg Club token already claimed.");
        courtyardRegistry.mintToken(caller, _courtyardProofOfIntegrity(goldenEggClubTokenId));
        _markAsClaimed(goldenEggClubTokenId);
        emit GoldenEggClaimed(goldenEggClubTokenId, caller);
    }

}