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
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC721.sol)

pragma solidity ^0.8.20;

import {IERC721} from "../token/ERC721/IERC721.sol";
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
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
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.20;

import {IERC165} from "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC-721 compliant contract.
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
     * are aware of the ERC-721 protocol to prevent tokens from being forever locked.
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
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC-721
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
// OpenZeppelin Contracts (last updated v5.1.0) (utils/introspection/IERC165.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC-165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[ERC].
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
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[ERC section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
// SPDX_License-Identifier: MIT
pragma solidity ^0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IPostMortemGardener} from "./interfaces/IPostMortemGardener.sol";
import {IPostMortemGardenerOps} from "./interfaces/IPostMortemGardenerOps.sol";
import {IERC721} from "@openzeppelin/contracts/interfaces/IERC721.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {PostMortemStructs} from "./structs/PostMortemStructs.sol";
import {GardenerStructs} from "./structs/GardenerStructs.sol";

contract PostMortemGardener is Ownable, IPostMortemGardener {
    // Configuration
    IPostMortemGardenerOps public postMortem;
    uint256 public maxSeeds;
    uint256 public maxSeedsPerTx;
    uint256 public pricePerSeed;

    // Time periods
    uint256 public reservationStart;
    uint256 public reservationEnd;
    uint256 public mintStart;
    uint256 public mintEnd;

    // Reservation state
    uint256 public totalReservedSeeds;
    mapping(uint256 => address) public seedHolders;

    // Errors
    error InsufficientDepositAmount();
    error NoSeedsRequested();
    error NotEnoughSeedsLeft();
    error TooManySeedsRequested();
    error ReservationClosed();
    error InvalidTimePeriod();
    error InvalidSeedId();
    error MintClosed();
    error SeedAlreadyReserved();
    error WithdrawFailed();
    error InvalidPayload();
    error NotSeedHolder();
    error IndexOutOfBounds();

    // Modifiers
    modifier whenReservationIsOpen() {
        if (block.timestamp < reservationStart || block.timestamp >= reservationEnd) {
            revert ReservationClosed();
        }
        _;
    }

    modifier whenMintIsOpen() {
        if (block.timestamp < mintStart || block.timestamp >= mintEnd) {
            revert MintClosed();
        }
        _;
    }

    modifier onlySeedHolder(uint256 seedId) {
        if (seedHolders[seedId] != msg.sender) {
            revert NotSeedHolder();
        }
        _;
    }

    // Constructor
    constructor(address initialOwner, address _postMortem, uint256 _maxSeedsPerTx, uint256 _pricePerSeed)
        Ownable(initialOwner)
    {
        maxSeedsPerTx = _maxSeedsPerTx;
        pricePerSeed = _pricePerSeed;
        postMortem = IPostMortemGardenerOps(_postMortem);
        maxSeeds = postMortem.MAX_SUPPLY();
    }

    // External Functions
    function getInfo() external view returns (GardenerStructs.Info memory) {
        return GardenerStructs.Info({
            maxSeeds: maxSeeds,
            maxSeedsPerTx: maxSeedsPerTx,
            pricePerSeed: pricePerSeed,
            totalReservedSeeds: totalReservedSeeds,
            reservationStart: reservationStart,
            reservationEnd: reservationEnd,
            mintStart: mintStart,
            mintEnd: mintEnd
        });
    }

    function getSeedInfos() external view returns (GardenerStructs.SeedInfo[] memory seedInfos) {
        PostMortemStructs.TokenInfo[] memory tokenInfos = postMortem.lookupAll();

        seedInfos = new GardenerStructs.SeedInfo[](tokenInfos.length);
        for (uint256 i = 0; i < tokenInfos.length;) {
            PostMortemStructs.TokenInfo memory tokenInfo = tokenInfos[i];

            seedInfos[i] = _getSeedInfo(i, tokenInfo);

            unchecked {
                ++i;
            }
        }
    }

    function getSeedInfo(uint256 seedId) external view returns (GardenerStructs.SeedInfo memory seedInfo) {
        PostMortemStructs.TokenInfo memory tokenInfo = postMortem.lookup(seedId);
        seedInfo = _getSeedInfo(seedId, tokenInfo);
    }

    function getUnmintedReservedSeedCount() external view returns (uint256 count) {
        PostMortemStructs.TokenInfo[] memory tokenInfos = postMortem.lookupAll();

        count = 0;
        for (uint256 i = 0; i < tokenInfos.length;) {
            PostMortemStructs.TokenInfo memory tokenInfo = tokenInfos[i];
            if (seedHolders[i] != address(0) && tokenInfo.owner == address(0)) {
                unchecked {
                    ++count;
                }
            }

            unchecked {
                ++i;
            }
        }
    }

    function getUnmintedReservedSeedIdByIndex(uint256 index) external view returns (uint256 seedId) {
        PostMortemStructs.TokenInfo[] memory tokenInfos = postMortem.lookupAll();

        uint256 count = 0;
        for (uint256 i = 0; i < tokenInfos.length;) {
            PostMortemStructs.TokenInfo memory tokenInfo = tokenInfos[i];
            if (seedHolders[i] != address(0) && tokenInfo.owner == address(0)) {
                if (index == count) {
                    return i;
                }

                unchecked {
                    ++count;
                }
            }

            unchecked {
                ++i;
            }
        }

        revert IndexOutOfBounds();
    }

    function reserve(uint256[] calldata seedIds) external payable whenReservationIsOpen {
        uint256 seeds = seedIds.length;
        uint256 requiredPrice = pricePerSeed * seeds;

        if (seeds == 0) {
            revert NoSeedsRequested();
        }
        if (seeds > maxSeedsPerTx) {
            revert TooManySeedsRequested();
        }
        if (msg.value < requiredPrice) {
            revert InsufficientDepositAmount();
        }
        if (totalReservedSeeds + seeds > maxSeeds) {
            revert NotEnoughSeedsLeft();
        }

        for (uint256 i = 0; i < seeds;) {
            _reserveSeed(seedIds[i], msg.sender);
            unchecked {
                ++i;
            }
        }

        unchecked {
            totalReservedSeeds += seeds;
        }
    }

    function mint(uint256 seedId, uint16 morality) external whenMintIsOpen onlySeedHolder(seedId) {
        postMortem.gardenerCommitMoralityAndMint(seedId, msg.sender, morality);
    }

    function ownerCommitMoralities(uint256[] calldata seedIds, uint16[] calldata moralities) external onlyOwner {
        if (seedIds.length == 0) {
            revert NoSeedsRequested();
        }
        if (seedIds.length != moralities.length) {
            revert InvalidPayload();
        }

        postMortem.gardenerCommitMoralities(seedIds, moralities);
    }

    function ownerMint(uint256[] calldata seedIds) external onlyOwner {
        if (seedIds.length == 0) {
            revert NoSeedsRequested();
        }

        address[] memory _seedHolders = new address[](seedIds.length);
        for (uint256 i = 0; i < seedIds.length;) {
            _seedHolders[i] = seedHolders[seedIds[i]];

            unchecked {
                ++i;
            }
        }

        postMortem.gardenerMint(seedIds, _seedHolders);
    }

    function ownerReshape(uint256[] memory seedIds) external onlyOwner {
        uint256 seeds = seedIds.length;

        if (seeds == 0) {
            revert NoSeedsRequested();
        }

        IPostMortemGardenerOps _postMortem = postMortem;
        IERC721 _postMortemERC721 = IERC721(address(_postMortem));
        for (uint256 i = 0; i < seeds;) {
            uint256 seedId = seedIds[i];
            address seedHolder = seedHolders[seedId];
            address tokenOwner = _postMortemERC721.ownerOf(seedId);
            if (seedHolder != tokenOwner) {
                seedHolders[seedId] = tokenOwner;
            }

            unchecked {
                ++i;
            }
        }

        _postMortem.gardenerReshape(seedIds);
    }

    function scheduleReservation(uint256 _reservationStart, uint256 _reservationEnd) external onlyOwner {
        if (_reservationStart >= _reservationEnd) {
            revert InvalidTimePeriod();
        }

        reservationStart = _reservationStart;
        reservationEnd = _reservationEnd;
    }

    function scheduleMint(uint256 _mintStart, uint256 _mintEnd) external onlyOwner {
        if (_mintStart >= _mintEnd) {
            revert InvalidTimePeriod();
        }

        mintStart = _mintStart;
        mintEnd = _mintEnd;
    }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        (bool success,) = payable(owner()).call{value: balance}("");
        if (!success) {
            revert WithdrawFailed();
        }
    }

    function withdrawERC20(IERC20 token, address to) external onlyOwner {
        uint256 balance = token.balanceOf(address(this));
        token.transfer(to, balance);
    }

    // Internal Functions
    function _reserveSeed(uint256 seedId, address to) internal {
        if (seedId >= maxSeeds) {
            revert InvalidSeedId();
        }
        if (seedHolders[seedId] != address(0)) {
            revert SeedAlreadyReserved();
        }
        seedHolders[seedId] = to;
        postMortem.gardenerReserve(seedId);
    }

    function _getSeedInfo(uint256 seedId, PostMortemStructs.TokenInfo memory tokenInfo)
        internal
        view
        returns (GardenerStructs.SeedInfo memory)
    {
        return GardenerStructs.SeedInfo({
            seedHolder: seedHolders[seedId],
            tokenOwner: tokenInfo.owner,
            tokenHash: tokenInfo.tokenHash,
            tokenMorality: tokenInfo.tokenMorality
        });
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {PostMortemStructs} from "../structs/PostMortemStructs.sol";
import {GardenerStructs} from "../structs/GardenerStructs.sol";

interface IPostMortemGardener {
    function getInfo() external view returns (GardenerStructs.Info memory);
    function getSeedInfos() external view returns (GardenerStructs.SeedInfo[] memory seedInfos);
    function getSeedInfo(uint256 seedId) external view returns (GardenerStructs.SeedInfo memory seedInfo);
    function getUnmintedReservedSeedCount() external view returns (uint256 count);
    function getUnmintedReservedSeedIdByIndex(uint256 index) external view returns (uint256 seedId);
    function ownerCommitMoralities(uint256[] calldata seedIds, uint16[] calldata moralities) external;
    function ownerMint(uint256[] calldata seedIds) external;
    function ownerReshape(uint256[] memory seedIds) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {PostMortemStructs} from "../structs/PostMortemStructs.sol";

interface IPostMortemGardenerOps {
    function MAX_SUPPLY() external view returns (uint256);
    function gardenerReserve(uint256 tokenId) external;
    function gardenerCommitMoralityAndMint(uint256 tokenId, address to, uint16 tokenMorality) external;
    function gardenerCommitMoralities(uint256[] calldata tokenIds, uint16[] calldata _tokenMoralities) external;
    function gardenerMint(uint256[] calldata tokenIds, address[] calldata toAddrs) external;
    function gardenerReshape(uint256[] calldata tokenIds) external;
    function lookup(uint256 tokenId) external view returns (PostMortemStructs.TokenInfo memory);
    function lookupAll() external view returns (PostMortemStructs.TokenInfo[] memory);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library GardenerStructs {
    struct Info {
        uint256 maxSeeds;
        uint256 maxSeedsPerTx;
        uint256 pricePerSeed;
        uint256 totalReservedSeeds;
        uint256 reservationStart;
        uint256 reservationEnd;
        uint256 mintStart;
        uint256 mintEnd;
    }

    struct SeedInfo {
        address seedHolder;
        address tokenOwner;
        uint256 tokenHash;
        uint16 tokenMorality;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library PostMortemStructs {
    struct TokenInfo {
        address owner;
        uint256 tokenHash;
        uint16 tokenMorality;
        uint8 x;
        uint8 y;
    }
}