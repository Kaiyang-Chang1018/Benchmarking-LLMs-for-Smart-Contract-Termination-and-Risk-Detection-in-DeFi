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
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

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
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
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
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.20;

import {IERC165} from "../../utils/introspection/IERC165.sol";

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
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or
     *   {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

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
    function transferFrom(address from, address to, uint256 tokenId) external;

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
     * - The `operator` cannot be the address zero.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool approved) external;

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
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.20;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be
     * reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/ReentrancyGuard.sol)

pragma solidity ^0.8.20;

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
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
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
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/introspection/IERC165.sol)

pragma solidity ^0.8.20;

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
pragma solidity ^0.8.20;

import "erc721a/contracts/interfaces/IERC721AQueryable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

/**
 * @dev Interface of ERC721 token receiver.
 */
interface ERC721A__IERC721Receiver {
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external returns (bytes4);
}

contract NFTExchange is ReentrancyGuard, Ownable, IERC721Receiver {
    IERC721AQueryable public nft;
    IERC20 public token;

    enum Rarity {
        // Token IDs: 1200-1999 (800 total)
        Common,
        // Token IDs: 550-1199 (650 total)
        Rare,
        // Token IDs: 100-549 (450 total)
        Epic,
        // Token IDs: 0-99 (100 total)
        Legendary
    }

    uint256 constant public legendaryTokenIdStart = 0;
    uint256 constant public epicTokenIdStart = 100;
    uint256 constant public rareTokenIdStart = 550;
    uint256 constant public commonTokenIdStart = 1200;

    mapping(Rarity => uint256[]) internal availableNftsByRarity;
    mapping(Rarity => uint256) internal availableNftsCountByRarity;
    Rarity[] internal availableRarities;

    address public feesRecipient;

    // Fee structure based on rarity (in Ether)
    mapping(Rarity => uint256) public rarityExchangeFees;

    // Price for exchanging ERC20 to NFT
    uint256 public nftPrice = 3_450_000_000 * 10 ** 18;

    // Fee for exchanging ERC20 to NFT. It should discourage "fishing" for rare NFTs instead of using the exchangeNFT function.
    uint256 public exchangeFee = 250_000_000 * 10 ** 18;

    // Fee for exchanging to the same or lower tier
    uint256 public feeSameLower = 0.02 ether;

    bool public initialized = false;

    event NFTForNFT(
        uint256 indexed tokenIdGiven,
        uint256 indexed tokenIdReceived,
        address indexed exchanger
    );
    event NFTForERC20(uint256 indexed tokenId, address indexed exchanger);
    event ERC20ForNFT(uint256 indexed tokenId, address indexed exchanger);

    /// ------------------------
    /// ---- INITIALIZATION ----
    /// ------------------------

    constructor(address _feesRecipient, address _tokenAddress) Ownable(msg.sender) {
        token = IERC20(_tokenAddress);

        feesRecipient = _feesRecipient;

        // Initialize fees for each rarity tier (in Ether)
        rarityExchangeFees[Rarity.Common] = 0.02 ether;
        rarityExchangeFees[Rarity.Rare] = 0.1 ether;
        rarityExchangeFees[Rarity.Epic] = 0.3 ether;
        rarityExchangeFees[Rarity.Legendary] = 0.6 ether;
    }

    function setNFTAddress(address nftAddress) external onlyOwner {
        require(!initialized, "NFT Exchange already initialized");
        require(address(nftAddress) != address(0), "NFT address cannot be zero address");
        nft = IERC721AQueryable(nftAddress);
    }

    function initializeNftsOfRarity(Rarity rarity, uint256 start, uint256 stop) external onlyOwner {
        require(!initialized, "NFT Exchange already initialized");
        require(address(nft) != address(0), "NFT address not set");

        uint256[] memory nfts = nft.tokensOfOwnerIn(address(this), start, stop);

        availableNftsByRarity[rarity] = nfts;
        availableNftsCountByRarity[rarity] = nfts.length;

        addRarity(rarity);

        if (availableRarities.length == 4) {
            initialized = true;
        }
    }

    /// -----------------
    /// ---- HELPERS ----
    /// -----------------

    function getFullNftPrice() public view returns (uint256) {
        return nftPrice + exchangeFee;
    }

    function getTotalAvailableNfts() public view returns (uint256) {
        return availableNftsCountByRarity[Rarity.Legendary] + availableNftsCountByRarity[Rarity.Epic] + availableNftsCountByRarity[Rarity.Rare] + availableNftsCountByRarity[Rarity.Common];
    }

    function getRarity(uint256 tokenId) public view returns (Rarity) {
        if (tokenId >= legendaryTokenIdStart && tokenId < epicTokenIdStart) {
            return Rarity.Legendary;
        } else if (tokenId >= epicTokenIdStart && tokenId < rareTokenIdStart) {
            return Rarity.Epic;
        } else if (tokenId >= rareTokenIdStart && tokenId < commonTokenIdStart) {
            return Rarity.Rare;
        } else if (tokenId >= commonTokenIdStart && tokenId < nft.totalSupply()) {
            return Rarity.Common;
        } else {
            revert("Invalid tokenId");
        }
    }

    function calculateExchangeFee(Rarity currentRarity, Rarity targetRarity) public view returns (uint256) {
        if (targetRarity <= currentRarity) {
            return feeSameLower;
        } else if (targetRarity == Rarity.Rare) {
            return rarityExchangeFees[Rarity.Rare];
        } else if (targetRarity == Rarity.Epic) {
            return rarityExchangeFees[Rarity.Epic];
        } else if (targetRarity == Rarity.Legendary) {
            return rarityExchangeFees[Rarity.Legendary];
        } else {
            // Handle the case when targetRarity is not recognized (e.g., invalid input)
            revert("Invalid target rarity");
        }
    }

    // Removes a selected rarity from the `availableRarities` array while maintaining correct order
    function removeRarity(Rarity _rarity) internal {
        uint256 length = availableRarities.length;
        uint256 index = length;
        bool found = false;

        for (uint256 i = 0; i < length; i++) {
            if (availableRarities[i] == _rarity) {
                index = i;
                found = true;
                break;
            }
        }

        require(found, "Rarity does not exist");

        for (uint256 j = index; j < length - 1; j++) {
            availableRarities[j] = availableRarities[j + 1];
        }
        availableRarities.pop();
    }

    // Adds a selected rarity to the `availableRarities` array while maintaining correct order
    function addRarity(Rarity _rarity) internal {
        uint256 length = availableRarities.length;
        uint256 index = length;

        for (uint256 i = 0; i < length; i++) {
            require(availableRarities[i] != _rarity, "Rarity already exists");

            if (uint256(availableRarities[i]) > uint256(_rarity)) {
                index = i;
                break;
            }
        }

        availableRarities.push();  // Increase the array length by 1

        for (uint256 j = length; j > index; j--) {
            availableRarities[j] = availableRarities[j - 1];
        }
        availableRarities[index] = _rarity;
    }

    // Pseudo-random number generator - should be sufficient based on that the number of NFTs in the pool is limited
    function random() internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender)));
    }

    function removeNftFromAvailableNftsByRarityArray(Rarity rarity, uint256 index) internal {
        uint256 arrayLength = availableNftsCountByRarity[rarity];
        require(index < arrayLength);

        // If there is only one NFT left, it means the last NFT was already exchanged
        // and we can safely remove the rarity from the available rarities array
        if (arrayLength == 1) {
            removeRarity(rarity);
        }

        availableNftsByRarity[rarity][index] = availableNftsByRarity[rarity][arrayLength-1];
        availableNftsByRarity[rarity].pop();
        availableNftsCountByRarity[rarity]--;
    }

    function getRarityAndParsedIndexOfRandomNftIndex(uint256 randomIndex) internal view returns (Rarity, uint256) {
        uint256 legendaryNfts = availableNftsCountByRarity[Rarity.Legendary];
        uint256 epicNfts = availableNftsCountByRarity[Rarity.Epic];
        uint256 rareNfts = availableNftsCountByRarity[Rarity.Rare];

        if (randomIndex < legendaryNfts) {
            return (Rarity.Legendary, randomIndex);
        } else if (randomIndex < legendaryNfts + epicNfts) {
            return (Rarity.Epic, randomIndex - legendaryNfts);
        } else if (randomIndex < legendaryNfts + epicNfts + rareNfts) {
            return (Rarity.Rare, randomIndex - legendaryNfts - epicNfts);
        } else {
            return (Rarity.Common, randomIndex - legendaryNfts - epicNfts - rareNfts);
        }
    }

    function getRandomNftTokenId() internal returns (uint256) {
        uint256 availableNfts = getTotalAvailableNfts();
        require(availableNfts > 0, "No NFTs available for exchange");

        uint256 randomNftIndex = random() % availableNfts;
        (Rarity rarity, uint256 parsedRandomNftIndex) = getRarityAndParsedIndexOfRandomNftIndex(randomNftIndex);

        return getTokenIdFromIndex(rarity, parsedRandomNftIndex);
    }

    function getRandomNftTokenIdOfRarity(Rarity rarity) internal returns (uint256) {
        uint256 availableNfts = availableNftsCountByRarity[rarity];
        require(availableNfts > 0, "No NFTs of given rarity available for exchange");

        uint256 randomNftIndex = random() % availableNfts;

        return getTokenIdFromIndex(rarity, randomNftIndex);
    }

    function getTokenIdFromIndex(Rarity rarity, uint256 randomNftIndex) internal returns (uint256) {
        uint256 tokenId = availableNftsByRarity[rarity][randomNftIndex];

        removeNftFromAvailableNftsByRarityArray(rarity, randomNftIndex);

        return tokenId;
    }

    /// ------------------------
    /// ---- CORE FUNCTIONS ----
    /// ------------------------

    modifier onlyEOA() {
        require(msg.sender == tx.origin, "No contracts");
        _;
    }

    // Exchange ERC20 for a random ERC721
    function exchangeERC20ForNFT() external onlyEOA nonReentrant {
        require(initialized, "NFT Exchange not initialized");

        require(availableRarities.length > 0, "No NFTs available for exchange");

        // Ensure that the sender has approved the contract to spend the ERC20 tokens
        require(token.allowance(msg.sender, address(this)) >= getFullNftPrice(), "Not enough allowance for exchange");

        uint256 tokenId = getRandomNftTokenId();

        token.transferFrom(msg.sender, feesRecipient, exchangeFee);
        token.transferFrom(msg.sender, address(this), nftPrice);

        require(nft.ownerOf(tokenId) == address(this), "NFT not owned by contract");
        nft.safeTransferFrom(address(this), msg.sender, tokenId);

        emit ERC20ForNFT(tokenId, msg.sender);
    }

    // Exchange ERC721 for ERC20
    function exchangeNFTForERC20(uint256 tokenId) external onlyEOA nonReentrant {
        require(initialized, "NFT Exchange not initialized");

        require(nft.ownerOf(tokenId) == msg.sender, "You do not own this NFT");

        require(token.balanceOf(address(this)) >= nftPrice, "Not enough ERC20 tokens in the contract");

        nft.safeTransferFrom(msg.sender, address(this), tokenId);

        token.transfer(feesRecipient, exchangeFee);
        token.transfer(msg.sender, nftPrice - exchangeFee);

        emit NFTForERC20(tokenId, msg.sender);
    }

    // NFT for NFT exchange function with rarity consideration
    function exchangeNFT(uint256 tokenId, Rarity targetRarity) external payable onlyEOA nonReentrant {
        require(initialized, "NFT Exchange not initialized");

        require(nft.ownerOf(tokenId) == msg.sender, "You do not own this NFT");

        Rarity currentRarity = getRarity(tokenId);

        // Calculate fee based on target rarity
        uint256 exchangeFeeRarity = calculateExchangeFee(currentRarity, targetRarity);
        require(msg.value >= exchangeFeeRarity, "Insufficient Ether sent for fee");

        require(availableNftsByRarity[targetRarity].length > 0, "No NFTs available for exchange in target rarity");

        // Get a random NFT of the target rarity
        uint256 newTokenId = getRandomNftTokenIdOfRarity(targetRarity);

        // Transfer the NFT to the contract
        nft.safeTransferFrom(msg.sender, address(this), tokenId);

        // Transfer the new NFT to the msg.sender
        nft.safeTransferFrom(address(this), msg.sender, newTokenId);

        payable(feesRecipient).transfer(exchangeFeeRarity);

        // Refund excess Ether back to the sender
        if (msg.value > exchangeFeeRarity) {
            msg.sender.call{value: msg.value - exchangeFeeRarity}("");
        }

        emit NFTForNFT(tokenId, newTokenId, msg.sender);
    }

    /// -------------------------
    /// ---- ADMIN FUNCTIONS ----
    /// -------------------------

    // Function to set exchange mint fee
    function updateNftPrice(uint256 newNftPrice) external onlyOwner {
        nftPrice = newNftPrice;
    }

    // Function to set exchange mint fee
    function updateExchangeFee(uint256 newExchangeFee) external onlyOwner {
        exchangeFee = newExchangeFee;
    }

    // Function to update the fixed fee amount for same and lower rarity exchanges
    function updateFeeSameLower(uint256 newFee) external onlyOwner {
        feeSameLower = newFee;
    }

    // Function to update the fee for a specific rarity
    function updateFeeForRarity(Rarity rarity, uint256 newFee) external onlyOwner {
        require(rarity >= Rarity.Common && rarity <= Rarity.Legendary, "Invalid rarity");
        rarityExchangeFees[rarity] = newFee;
    }

    // Function to update the fee receiver
    function updateFeeReceiver(address newFeeReceiver) external onlyOwner {
        feesRecipient = newFeeReceiver;
    }

    // Withdraw any ERC20 token
    function withdrawERC20(address _tokenAddress) external onlyOwner {
        require(_tokenAddress != address(token), "Cannot withdraw the main ERC-20 token");

        uint256 balance = IERC20(_tokenAddress).balanceOf(address(this));
        IERC20(_tokenAddress).transfer(owner(), balance);
    }

    // Function to withdraw a specific ERC721 token
    function withdrawNFT(address _nftAddress, uint256 _tokenId) external onlyOwner {
        bool isIndexedNft = false;

        // Check if the NFT is indexed. If it's not, then it means that this NFT is "stuck" in the contract
        // and can be withdrawn by the owner without bricking the contract
        if (_nftAddress == address(nft)) {
            Rarity rarity = getRarity(_tokenId);
            for(uint256 i = 0; i < availableNftsByRarity[rarity].length; i++) {
                if (availableNftsByRarity[rarity][i] == _tokenId) {
                    isIndexedNft = true;
                    break;
                }
            }
        }

        if (isIndexedNft) {
            require(_nftAddress != address(nft), "Cannot withdraw the main NFT");
        }

        // Ensure that the contract owns the token
        require(IERC721(_nftAddress).ownerOf(_tokenId) == address(this), "Contract does not own this token");

        // Transfer the NFT token to the owner
        IERC721(_nftAddress).transferFrom(address(this), owner(), _tokenId);
    }

    /// ------------------------
    /// ------ RECEIVERS -------
    /// ------------------------

    function onERC721Received(
        address,
        address,
        uint256 tokenId,
        bytes calldata
    ) external override returns (bytes4) {
        Rarity rarity = getRarity(tokenId);

        if (availableNftsCountByRarity[rarity] == 0) {
            addRarity(rarity);
        }

        availableNftsByRarity[rarity].push(tokenId);
        availableNftsCountByRarity[rarity]++;

        // Return the function selector to confirm the transfer
        return this.onERC721Received.selector;
    }
}
// SPDX-License-Identifier: MIT
// ERC721A Contracts v4.3.0
// Creator: Chiru Labs

pragma solidity ^0.8.4;

/**
 * @dev Interface of ERC721A.
 */
interface IERC721A {
    /**
     * The caller must own the token or be an approved operator.
     */
    error ApprovalCallerNotOwnerNorApproved();

    /**
     * The token does not exist.
     */
    error ApprovalQueryForNonexistentToken();

    /**
     * Cannot query the balance for the zero address.
     */
    error BalanceQueryForZeroAddress();

    /**
     * Cannot mint to the zero address.
     */
    error MintToZeroAddress();

    /**
     * The quantity of tokens minted must be more than zero.
     */
    error MintZeroQuantity();

    /**
     * The token does not exist.
     */
    error OwnerQueryForNonexistentToken();

    /**
     * The caller must own the token or be an approved operator.
     */
    error TransferCallerNotOwnerNorApproved();

    /**
     * The token must be owned by `from`.
     */
    error TransferFromIncorrectOwner();

    /**
     * Cannot safely transfer to a contract that does not implement the
     * ERC721Receiver interface.
     */
    error TransferToNonERC721ReceiverImplementer();

    /**
     * Cannot transfer to the zero address.
     */
    error TransferToZeroAddress();

    /**
     * The token does not exist.
     */
    error URIQueryForNonexistentToken();

    /**
     * The `quantity` minted with ERC2309 exceeds the safety limit.
     */
    error MintERC2309QuantityExceedsLimit();

    /**
     * The `extraData` cannot be set on an unintialized ownership slot.
     */
    error OwnershipNotInitializedForExtraData();

    /**
     * `_sequentialUpTo()` must be greater than `_startTokenId()`.
     */
    error SequentialUpToTooSmall();

    /**
     * The `tokenId` of a sequential mint exceeds `_sequentialUpTo()`.
     */
    error SequentialMintExceedsLimit();

    /**
     * Spot minting requires a `tokenId` greater than `_sequentialUpTo()`.
     */
    error SpotMintTokenIdTooSmall();

    /**
     * Cannot mint over a token that already exists.
     */
    error TokenAlreadyExists();

    /**
     * The feature is not compatible with spot mints.
     */
    error NotCompatibleWithSpotMints();

    // =============================================================
    //                            STRUCTS
    // =============================================================

    struct TokenOwnership {
        // The address of the owner.
        address addr;
        // Stores the start time of ownership with minimal overhead for tokenomics.
        uint64 startTimestamp;
        // Whether the token has been burned.
        bool burned;
        // Arbitrary data similar to `startTimestamp` that can be set via {_extraData}.
        uint24 extraData;
    }

    // =============================================================
    //                         TOKEN COUNTERS
    // =============================================================

    /**
     * @dev Returns the total number of tokens in existence.
     * Burned tokens will reduce the count.
     * To get the total number of tokens minted, please see {_totalMinted}.
     */
    function totalSupply() external view returns (uint256);

    // =============================================================
    //                            IERC165
    // =============================================================

    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * [EIP section](https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified)
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);

    // =============================================================
    //                            IERC721
    // =============================================================

    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables
     * (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in `owner`'s account.
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
     * @dev Safely transfers `tokenId` token from `from` to `to`,
     * checking first that contract recipients are aware of the ERC721 protocol
     * to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move
     * this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement
     * {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external payable;

    /**
     * @dev Equivalent to `safeTransferFrom(from, to, tokenId, '')`.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external payable;

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom}
     * whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token
     * by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external payable;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the
     * zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external payable;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom}
     * for any token owned by the caller.
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
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    // =============================================================
    //                        IERC721Metadata
    // =============================================================

    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);

    // =============================================================
    //                           IERC2309
    // =============================================================

    /**
     * @dev Emitted when tokens in `fromTokenId` to `toTokenId`
     * (inclusive) is transferred from `from` to `to`, as defined in the
     * [ERC2309](https://eips.ethereum.org/EIPS/eip-2309) standard.
     *
     * See {_mintERC2309} for more details.
     */
    event ConsecutiveTransfer(uint256 indexed fromTokenId, uint256 toTokenId, address indexed from, address indexed to);
}
// SPDX-License-Identifier: MIT
// ERC721A Contracts v4.3.0
// Creator: Chiru Labs

pragma solidity ^0.8.4;

import '../IERC721A.sol';

/**
 * @dev Interface of ERC721AQueryable.
 */
interface IERC721AQueryable is IERC721A {
    /**
     * Invalid query range (`start` >= `stop`).
     */
    error InvalidQueryRange();

    /**
     * @dev Returns the `TokenOwnership` struct at `tokenId` without reverting.
     *
     * If the `tokenId` is out of bounds:
     *
     * - `addr = address(0)`
     * - `startTimestamp = 0`
     * - `burned = false`
     * - `extraData = 0`
     *
     * If the `tokenId` is burned:
     *
     * - `addr = <Address of owner before token was burned>`
     * - `startTimestamp = <Timestamp when token was burned>`
     * - `burned = true`
     * - `extraData = <Extra data when token was burned>`
     *
     * Otherwise:
     *
     * - `addr = <Address of owner>`
     * - `startTimestamp = <Timestamp of start of ownership>`
     * - `burned = false`
     * - `extraData = <Extra data at start of ownership>`
     */
    function explicitOwnershipOf(uint256 tokenId) external view returns (TokenOwnership memory);

    /**
     * @dev Returns an array of `TokenOwnership` structs at `tokenIds` in order.
     * See {ERC721AQueryable-explicitOwnershipOf}
     */
    function explicitOwnershipsOf(uint256[] memory tokenIds) external view returns (TokenOwnership[] memory);

    /**
     * @dev Returns an array of token IDs owned by `owner`,
     * in the range [`start`, `stop`)
     * (i.e. `start <= tokenId < stop`).
     *
     * This function allows for tokens to be queried if the collection
     * grows too big for a single call of {ERC721AQueryable-tokensOfOwner}.
     *
     * Requirements:
     *
     * - `start < stop`
     */
    function tokensOfOwnerIn(
        address owner,
        uint256 start,
        uint256 stop
    ) external view returns (uint256[] memory);

    /**
     * @dev Returns an array of token IDs owned by `owner`.
     *
     * This function scans the ownership mapping and is O(`totalSupply`) in complexity.
     * It is meant to be called off-chain.
     *
     * See {ERC721AQueryable-tokensOfOwnerIn} for splitting the scan into
     * multiple smaller scans if the collection is large enough to cause
     * an out-of-gas error (10K collections should be fine).
     */
    function tokensOfOwner(address owner) external view returns (uint256[] memory);
}
// SPDX-License-Identifier: MIT
// ERC721A Contracts v4.3.0
// Creator: Chiru Labs

pragma solidity ^0.8.4;

import '../extensions/IERC721AQueryable.sol';