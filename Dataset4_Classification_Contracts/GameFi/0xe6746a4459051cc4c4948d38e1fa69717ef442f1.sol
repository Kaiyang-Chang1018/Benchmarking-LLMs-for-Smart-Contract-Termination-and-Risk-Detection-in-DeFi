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
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

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
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

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
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

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
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
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
// Archetype ParallelAutoAuctionExtension
//
//        d8888                 888               888
//       d88888                 888               888
//      d88P888                 888               888
//     d88P 888 888d888 .d8888b 88888b.   .d88b.  888888 888  888 88888b.   .d88b.
//    d88P  888 888P"  d88P"    888 "88b d8P  Y8b 888    888  888 888 "88b d8P  Y8b
//   d88P   888 888    888      888  888 88888888 888    888  888 888  888 88888888
//  d8888888888 888    Y88b.    888  888 Y8b.     Y88b.  Y88b 888 888 d88P Y8b.
// d88P     888 888     "Y8888P 888  888  "Y8888   "Y888  "Y88888 88888P"   "Y8888
//                                                            888 888
//                                                       Y8b d88P 888
//                                                        "Y88P"  888

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./interfaces/ISharesHolder.sol";
import "./ParallelAutoAuction.sol";


error NotVip();

struct Options {
    bool sharesUpdaterUpdatingLocked;
    bool vipRequiredTokensLocked;
    bool vipIdsLocked;
}


contract AuraAuction is ParallelAutoAuction, ISharesHolder {

    mapping(address => uint256) private _rewardTokenShares;
	mapping(address => bool) private _allowSharesUpdate;
    mapping(uint24 => bool) private _tokenIdIsVip;

    address[] public tokensRequiredToOwnToBeVip;

    Options public options;

    function createBid(uint24 nftId) override public payable {

        if (_tokenIdIsVip[nftId] && !userIsVip(msg.sender))
            revert NotVip();

		super.createBid(nftId);
		_rewardTokenShares[msg.sender] += msg.value;
	}

    /* ----------------------- *\
    |* Vip token configuration *|
    \* ----------------------- */
    function setVipIds(uint24[] memory ids, bool areVip) external onlyOwner {
        if (options.vipIdsLocked) revert OptionLocked();
        for (uint256 i = 0; i < ids.length; i++) _tokenIdIsVip[ids[i]] = areVip;
    }

    function isVipId(uint24 id) external view returns (bool) {
        return _tokenIdIsVip[id];
    }

    function setTokensRequiredToHoldToBeVip(address[] memory tokens) external onlyOwner {
        if (options.vipRequiredTokensLocked) revert OptionLocked(); 
        tokensRequiredToOwnToBeVip = tokens;
    }

    /**
     * @return itIs Only if `user` holds at least one `tokensRequiredToOwnToBeVip`.
     */
    function userIsVip(address user) public view returns (bool itIs) {
        for (uint256 i = 0; i < tokensRequiredToOwnToBeVip.length; i++)
            if (IERC721(tokensRequiredToOwnToBeVip[i]).balanceOf(user) > 0)
                return true;
    }


    /* ---------------------------- *\
    |* ISharesHolder implementation *|
    \* ---------------------------- */
	function getAndClearSharesFor(address user) external returns (uint256 shares) {
		require(_allowSharesUpdate[msg.sender]);
		shares = _rewardTokenShares[user];
		delete _rewardTokenShares[user];
	}

	function addSharesUpdater(address updater) external onlyOwner {
        if (options.sharesUpdaterUpdatingLocked) revert OptionLocked();
		_allowSharesUpdate[updater] = true;
	}

	function removeSharesUpdater(address updater) external onlyOwner {
        if (options.sharesUpdaterUpdatingLocked) revert OptionLocked();
		_allowSharesUpdate[updater] = false;
	}

	function getIsSharesUpdater(address updater) external view returns (bool) {
		return _allowSharesUpdate[updater];
	}

	function getTokenShares(address user) external view returns (uint256) {
		return _rewardTokenShares[user];
	}

    /* ---------------------------------- *\
    |* Contract locking and configuration *|
    \* ---------------------------------- */
    function lockSharesUpdaterUpdatingForever() external onlyOwner {
        options.sharesUpdaterUpdatingLocked = true;
    }
    
    function lockTokensRequiredToHoldToBeVipForever() external onlyOwner {
        options.vipRequiredTokensLocked = true;
    }

    function lockVipIdsForever() external onlyOwner {
        options.vipIdsLocked = true;
    }

}
// SPDX-License-Identifier: MIT
// Archetype ParallelAutoAuction
//
//        d8888                 888               888
//       d88888                 888               888
//      d88P888                 888               888
//     d88P 888 888d888 .d8888b 88888b.   .d88b.  888888 888  888 88888b.   .d88b.
//    d88P  888 888P"  d88P"    888 "88b d8P  Y8b 888    888  888 888 "88b d8P  Y8b
//   d88P   888 888    888      888  888 88888888 888    888  888 888  888 88888888
//  d8888888888 888    Y88b.    888  888 Y8b.     Y88b.  Y88b 888 888 d88P Y8b.
// d88P     888 888     "Y8888P 888  888  "Y8888   "Y888  "Y88888 88888P"   "Y8888
//                                                            888 888
//                                                       Y8b d88P 888
//                                                        "Y88P"  888

pragma solidity ^0.8.4;

import "./interfaces/IParallelAutoAuction.sol";
import "./interfaces/IExternallyMintable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "solady/src/utils/SafeTransferLib.sol";


error WrongTokenId();
error WrongBidAmount();
error AuctionPaused();
error OptionLocked();

struct StateLocks {
    bool initializationLocked;
    bool baseDurationLocked;
    bool timeBufferLocked;
    bool startingPriceLocked;
    bool bidIncrementLocked;
}


contract ParallelAutoAuction is IParallelAutoAuction, Ownable {
    
    // @notice The config for the auction should be immutable.
    AuctionConfig private _auctionConfig;
    
    StateLocks private _stateLocks;

    // @notice `_lineToState[i]` should only be mutable from the line `i`. 
    mapping(uint8 => LineState) private _lineToState;

    function initialize(
        address nftToAuction,
        uint8 lines,
        uint32 baseDuration,
        uint32 timeBuffer,
        uint96 startingPrice,
        uint96 bidIncrement
    ) external onlyOwner {
        require(!_stateLocks.initializationLocked); 
        _stateLocks.initializationLocked = true;

        require(bidIncrement > 0);

        _auctionConfig.auctionedNft = nftToAuction;
        _auctionConfig.lines = lines;
        _auctionConfig.baseDuration = baseDuration;
        _auctionConfig.timeBuffer = timeBuffer;
        _auctionConfig.startingPrice = startingPrice;
        _auctionConfig.bidIncrement = bidIncrement;
    }

    /* ------------- *\
    |* Bidding logic *|
    \* ------------- */
    /**
     * @dev Create a bid for a NFT, with a given amount.
     * This contract only accepts payment in ETH.
     */
    function createBid(uint24 nftId) public payable virtual {
        
        uint8 lineNumber = tokenIdToLineNumber(nftId);
        LineState storage line = _lineToState[lineNumber];
        IExternallyMintable token = IExternallyMintable(_auctionConfig.auctionedNft);
        
        if (!token.isMinter(address(this)))
            revert AuctionPaused();

        /* ---------- AUCTION UPDATING AND SETTLEMENT ---------- */
        if (block.timestamp > line.endTime) {
            if (!token.exists(line.head) && line.head > 0) _settleAuction(line);
            _updateLine(line, lineNumber);
        }

        if (line.head != nftId || nftId > token.maxSupply())
            revert WrongTokenId();
        
        /* ------------------ BIDDING LOGIC ------------------ */
        bool winnerExists = line.currentWinner != address(0);
        if (
            (!winnerExists && _auctionConfig.startingPrice > msg.value) ||
            (winnerExists && line.currentPrice + _auctionConfig.bidIncrement > msg.value)
        ) revert WrongBidAmount();

        if (line.currentPrice != 0)
            SafeTransferLib.forceSafeTransferETH(line.currentWinner, line.currentPrice);

        line.currentPrice = uint96(msg.value);
        line.currentWinner = msg.sender;

        emit Bid(nftId, msg.sender, msg.value);
        
        uint40 extendedTime = uint40(block.timestamp + _auctionConfig.timeBuffer);
        if (extendedTime > line.endTime)
            line.endTime = extendedTime;

    }

    function settleAuction(uint24 nftId) external {
        LineState memory line = _lineToState[tokenIdToLineNumber(nftId)];
        IExternallyMintable token = IExternallyMintable(_auctionConfig.auctionedNft);
        require(block.timestamp > line.endTime, "Auction still ongoing.");
        require(line.head != 0, "Auction not started.");
        require(!token.exists(nftId), "Token already settled.");
        _settleAuction(line);
    }

    function _settleAuction(LineState memory line) private {
        emit Won(line.head, line.currentWinner, line.currentPrice);
        address nftContract = _auctionConfig.auctionedNft;
        IExternallyMintable(nftContract).mint(line.head, line.currentWinner);
        payable(nftContract).transfer(line.currentPrice);
    }
    
    /**
     * @dev `line.head` will be the current token id auctioned at the
     * `line`. If is the first auction for this line (if `line.head == 0`)
     * then the token id should be the line number itself. Otherwise
     * increment the id by the number of lines. For more info about the 
     * second case check the `AuctionConfig.lines` doc.
     * @notice This function should be the only one allowed to change
     * `line.startTime`, `line.endTime` and `line.head` state, and it should
     * do so only when the dev is sure thats its time to auction the next
     * token id.
     */
    function _updateLine(LineState storage line, uint8 lineNumber) private {
        line.startTime = uint40(block.timestamp);
        line.endTime = uint40(block.timestamp + _auctionConfig.baseDuration);

        if (line.head == 0) line.head = lineNumber; 
        else {
            line.head += _auctionConfig.lines;
            line.currentPrice = 0;
            line.currentWinner = address(0);
        }
    }

    /* --------------------------- *\
    |* IAuctionInfo implementation *|
    \* --------------------------- */
    function getIdsToAuction() external view returns (uint24[] memory) {
        uint24[] memory ids = new uint24[](_auctionConfig.lines);
        for (uint8 i = 0; i < _auctionConfig.lines; i++) {
            LineState memory line = _lineToState[i+1];
            uint24 lineId = line.head;
            if (lineId == 0) lineId = i + 1;
            else if (block.timestamp > line.endTime) lineId += _auctionConfig.lines;
            ids[i] = lineId;
        }
        return ids;
    }

    function getAuctionedToken() external view returns (address) {
        return _auctionConfig.auctionedNft;
    }
    
    // TODO it should revert if `tokenId != expectedHead`
    function getMinPriceFor(uint24 tokenId) external view returns (uint96) {
        uint8 lineNumber = uint8(tokenId % _auctionConfig.lines);
        LineState memory line = _lineToState[lineNumber];
        if (block.timestamp > line.endTime) return _auctionConfig.startingPrice;
        else return line.currentPrice + _auctionConfig.bidIncrement;
    }
    

    /* -------------------------------------------- *\
    |* IHoldsParallelAutoAuctionData implementation *|
    \* -------------------------------------------- */
    function auctionConfig() external view returns (AuctionConfig memory) {
        return _auctionConfig;    
    }

    function lineState(uint24 tokenId) external view returns (LineState memory) {
        return _lineState(tokenId);
    }

    function lineStates() external view returns (LineState[] memory lines) {
        lines = new LineState[](_auctionConfig.lines);
        for (uint8 i = 0; i < _auctionConfig.lines; i++)
            lines[i] = _lineState(i+1);
    }
    
    function _lineState(uint24 tokenId) private view returns (LineState memory line) {
        uint8 lineNumber = tokenIdToLineNumber(tokenId);
        line = _lineToState[lineNumber];
        
        if (block.timestamp > line.endTime) {
            line.head += line.head == 0 ? lineNumber : _auctionConfig.lines;
            line.startTime = uint40(block.timestamp);
            line.endTime = uint40(block.timestamp + _auctionConfig.baseDuration);
            line.currentWinner = address(0);
            line.currentPrice = 0;
        }
    }

    /**
     * @return A value that will always be in {1, 2, ..., _auctionConfig.lines}.
     * So the returned value will always be a valid line number.
     */
    function tokenIdToLineNumber(uint24 tokenId) public view returns (uint8) {
        return uint8((tokenId - 1) % _auctionConfig.lines) + 1;
    }


    /* ----------------------------------- *\
    |* General contract state manipulation *|
    \* ----------------------------------- */
    /**
     * @dev Updating `baseDuration` will only affect to future auctions.
     */
    function setBaseDuration(uint32 baseDuration) external onlyOwner {
        if (_stateLocks.baseDurationLocked) revert OptionLocked();
        _auctionConfig.baseDuration = baseDuration;
    }

    /**
     * @dev Updating `timeBuffer` will only affect to future bufferings.
     */
    function setTimeBuffer(uint32 timeBuffer) external onlyOwner {
        if (_stateLocks.timeBufferLocked) revert OptionLocked();
        _auctionConfig.timeBuffer = timeBuffer; 
    }

    /**
     * @dev Updating `startingPrice` will only affect to future auctions.
     */
    function setStartingPrice(uint96 startingPrice) external onlyOwner {
        if (_stateLocks.startingPriceLocked) revert OptionLocked();
        _auctionConfig.startingPrice = startingPrice;
    }

    /**
     * @dev Updating `bidIncrement` will only affect to future increments.
     */
    function setBidIncrement(uint96 bidIncrement) external onlyOwner {
        if (_stateLocks.bidIncrementLocked) revert OptionLocked();
        _auctionConfig.bidIncrement = bidIncrement;
    }
    

    /* ---------------- *\
    |* Contract locking *|
    \* ---------------- */
    function lockBaseDurationForever() external onlyOwner {
        _stateLocks.baseDurationLocked = true;
    }

    function lockTimeBufferForever() external onlyOwner {
        _stateLocks.timeBufferLocked = true;
    }

    function lockStartingPriceForever() external onlyOwner {
        _stateLocks.startingPriceLocked = true;
    }

    function lockBidIncrementForever() external onlyOwner {
        _stateLocks.bidIncrementLocked = true;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IAuctionInfo {
    /**
     * @return The auctioned NFT (or maybe any other type of token).
     */
    function getAuctionedToken() external view returns (address);

    /**
     * @return An array with all the token ids that 
     * can currently get auctioned.
     */
    function getIdsToAuction() external view returns (uint24[] memory);

    /**
     * @return The current minimum bid price for an auctionable `tokenId`.
     * If `tokenId` not in `this.getIdsToAuction()`, it should revert.
     */
    function getMinPriceFor(uint24 tokenId) external view returns (uint96);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./IAuctionInfo.sol";

interface IEthAuction is IAuctionInfo {
    /**
     * @dev Create a `msg.value` bid for a NFT.
     */
    function createBid(uint24 nftId) external payable;
}
// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IExternallyMintable is IERC721 {
    /**
     * @dev Allows the minter to mint a NFT to `to`.
     */
    function mint(uint24 tokenId, address to) external;
    
    /**
     * @return If `tokenId` was already minted (ie, if it exists).
     */
    function exists(uint24 tokenId) external view returns (bool);
    
    /**
     * @dev Sets a `minter` so it can use the `mint` method.
     */
    function addMinter(address minter) external;

    /**
     * @dev Disallow `minter` from using the `mint` method.
     */
    function removeMinter(address minter) external;

    /**
     * @return If `minter` is allowed to call the `mint` function.
     */
    function isMinter(address minter) external view returns (bool);

    /**
     * @return The max supply of the token, so the auction that will
     * use it knows wheres the mints limit.
     */
    function maxSupply() external view returns (uint24);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

struct AuctionConfig {
    address auctionedNft;
    /**
     * @notice The number of auctions that can happen at the same time. For
     * example, if `lines == 3`, those will be the auctioned token ids over
     * time:
     *
     * --- TIME --->
     * 
     *  line 1: |--- 1 ---|---- 4 ----|--- 7 ---|---- 10 ---- ...
     *  line 2: |-- 2 --|----- 5 -----|-- 8 --|---- 11 ---- ...
     *  line 3: |---- 3 ----|-- 6 --|---- 9 ----|----- 12 ----- ...
     *
     * Then, from the front-end, you only need to call `lineToState[l].head`
     * to query the current auctioned nft at line `l`. For example, in the
     * graph above, `lineToState[2].head == 11`.
     */
    uint8 lines;
    // @notice The base duration is the time that takes a single auction
    // without considering time buffering.
    uint32 baseDuration;
    // @notice Extra auction time if a bid happens close to the auction end.
    uint32 timeBuffer;
    // @notice The minimum price accepted in an auction.
    uint96 startingPrice;
    // @notice The minimum bid increment.
    uint96 bidIncrement;
}

    
/**
 * @dev LineState represents a single auction line, so there will be
 * exactly `_auctionConfig.lines` LineStates.
 */
struct LineState {
    // @notice head Is the current auctioned token id at the line.
    uint24 head;
    uint40 startTime;
    uint40 endTime;
    address currentWinner;
    uint96 currentPrice;
}

interface IHoldsParallelAutoAuctionData {
    function auctionConfig() external view returns (AuctionConfig memory);
    /**
     * @return Current line state at `tokenId`, with data updated if the
     * auction for that line should get settled.
     */
    function lineState(uint24 tokenId) external view returns (LineState memory);
    /**
     * @return All `LineState`s.
     */
    function lineStates() external view returns (LineState[] memory);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./IEthAuction.sol";
import "./IHoldsParallelAutoAuctionData.sol";

interface IParallelAutoAuction is IEthAuction, IHoldsParallelAutoAuctionData {
    
    event Bid(uint24 indexed tokenId, address bidder, uint256 value);
    event Won(uint24 indexed tokenId, address bidder, uint256 value);

    /**
     * @dev This method lets a `nftId` winner to claim it after an aunction ends,
     * It can also be used to claim the last auctioned `nftIds`s. Note that this
     * has to do with the original `BonklerAuction` contract, which automatically
     * settles auction when the auction for the next `nftId` starts.
     */
    function settleAuction(uint24 nftId) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface ISharesHolder {

	/**
	 * @param updater Should be an IRewardClaimer.
	 */
	function addSharesUpdater(address updater) external;

	/**
	 * @dev An IRewardClaimer will use this function to calculate rewards for
	 * a bidder.
	 */
	function getAndClearSharesFor(address user) external returns (uint256);

	function getTokenShares(address user) external view returns (uint256);

	function getIsSharesUpdater(address updater) external view returns (bool);

}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Safe ETH and ERC20 transfer library that gracefully handles missing return values.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/SafeTransferLib.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/SafeTransferLib.sol)
/// @dev Caution! This library won't check that a token has code, responsibility is delegated to the caller.
library SafeTransferLib {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       CUSTOM ERRORS                        */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The ETH transfer has failed.
    error ETHTransferFailed();

    /// @dev The ERC20 `transferFrom` has failed.
    error TransferFromFailed();

    /// @dev The ERC20 `transfer` has failed.
    error TransferFailed();

    /// @dev The ERC20 `approve` has failed.
    error ApproveFailed();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         CONSTANTS                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Suggested gas stipend for contract receiving ETH
    /// that disallows any storage writes.
    uint256 internal constant _GAS_STIPEND_NO_STORAGE_WRITES = 2300;

    /// @dev Suggested gas stipend for contract receiving ETH to perform a few
    /// storage reads and writes, but low enough to prevent griefing.
    /// Multiply by a small constant (e.g. 2), if needed.
    uint256 internal constant _GAS_STIPEND_NO_GRIEF = 100000;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       ETH OPERATIONS                       */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Sends `amount` (in wei) ETH to `to`.
    /// Reverts upon failure.
    function safeTransferETH(address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            // Transfer the ETH and check if it succeeded or not.
            if iszero(call(gas(), to, amount, 0, 0, 0, 0)) {
                // Store the function selector of `ETHTransferFailed()`.
                mstore(0x00, 0xb12d13eb)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }
        }
    }

    /// @dev Force sends `amount` (in wei) ETH to `to`, with a `gasStipend`.
    /// The `gasStipend` can be set to a low enough value to prevent
    /// storage writes or gas griefing.
    ///
    /// If sending via the normal procedure fails, force sends the ETH by
    /// creating a temporary contract which uses `SELFDESTRUCT` to force send the ETH.
    ///
    /// Reverts if the current contract has insufficient balance.
    function forceSafeTransferETH(address to, uint256 amount, uint256 gasStipend) internal {
        /// @solidity memory-safe-assembly
        assembly {
            // If insufficient balance, revert.
            if lt(selfbalance(), amount) {
                // Store the function selector of `ETHTransferFailed()`.
                mstore(0x00, 0xb12d13eb)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }
            // Transfer the ETH and check if it succeeded or not.
            if iszero(call(gasStipend, to, amount, 0, 0, 0, 0)) {
                mstore(0x00, to) // Store the address in scratch space.
                mstore8(0x0b, 0x73) // Opcode `PUSH20`.
                mstore8(0x20, 0xff) // Opcode `SELFDESTRUCT`.
                // We can directly use `SELFDESTRUCT` in the contract creation.
                // Compatible with `SENDALL`: https://eips.ethereum.org/EIPS/eip-4758
                if iszero(create(amount, 0x0b, 0x16)) {
                    // For better gas estimation.
                    if iszero(gt(gas(), 1000000)) { revert(0, 0) }
                }
            }
        }
    }

    /// @dev Force sends `amount` (in wei) ETH to `to`, with a gas stipend
    /// equal to `_GAS_STIPEND_NO_GRIEF`. This gas stipend is a reasonable default
    /// for 99% of cases and can be overriden with the three-argument version of this
    /// function if necessary.
    ///
    /// If sending via the normal procedure fails, force sends the ETH by
    /// creating a temporary contract which uses `SELFDESTRUCT` to force send the ETH.
    ///
    /// Reverts if the current contract has insufficient balance.
    function forceSafeTransferETH(address to, uint256 amount) internal {
        // Manually inlined because the compiler doesn't inline functions with branches.
        /// @solidity memory-safe-assembly
        assembly {
            // If insufficient balance, revert.
            if lt(selfbalance(), amount) {
                // Store the function selector of `ETHTransferFailed()`.
                mstore(0x00, 0xb12d13eb)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }
            // Transfer the ETH and check if it succeeded or not.
            if iszero(call(_GAS_STIPEND_NO_GRIEF, to, amount, 0, 0, 0, 0)) {
                mstore(0x00, to) // Store the address in scratch space.
                mstore8(0x0b, 0x73) // Opcode `PUSH20`.
                mstore8(0x20, 0xff) // Opcode `SELFDESTRUCT`.
                // We can directly use `SELFDESTRUCT` in the contract creation.
                // Compatible with `SENDALL`: https://eips.ethereum.org/EIPS/eip-4758
                if iszero(create(amount, 0x0b, 0x16)) {
                    // For better gas estimation.
                    if iszero(gt(gas(), 1000000)) { revert(0, 0) }
                }
            }
        }
    }

    /// @dev Sends `amount` (in wei) ETH to `to`, with a `gasStipend`.
    /// The `gasStipend` can be set to a low enough value to prevent
    /// storage writes or gas griefing.
    ///
    /// Simply use `gasleft()` for `gasStipend` if you don't need a gas stipend.
    ///
    /// Note: Does NOT revert upon failure.
    /// Returns whether the transfer of ETH is successful instead.
    function trySafeTransferETH(address to, uint256 amount, uint256 gasStipend)
        internal
        returns (bool success)
    {
        /// @solidity memory-safe-assembly
        assembly {
            // Transfer the ETH and check if it succeeded or not.
            success := call(gasStipend, to, amount, 0, 0, 0, 0)
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      ERC20 OPERATIONS                      */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Sends `amount` of ERC20 `token` from `from` to `to`.
    /// Reverts upon failure.
    ///
    /// The `from` account must have at least `amount` approved for
    /// the current contract to manage.
    function safeTransferFrom(address token, address from, address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.

            mstore(0x60, amount) // Store the `amount` argument.
            mstore(0x40, to) // Store the `to` argument.
            mstore(0x2c, shl(96, from)) // Store the `from` argument.
            // Store the function selector of `transferFrom(address,address,uint256)`.
            mstore(0x0c, 0x23b872dd000000000000000000000000)

            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    // Set success to whether the call reverted, if not we check it either
                    // returned exactly 1 (can't just be non-zero data), or had no return data.
                    or(eq(mload(0x00), 1), iszero(returndatasize())),
                    call(gas(), token, 0, 0x1c, 0x64, 0x00, 0x20)
                )
            ) {
                // Store the function selector of `TransferFromFailed()`.
                mstore(0x00, 0x7939f424)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }

            mstore(0x60, 0) // Restore the zero slot to zero.
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Sends all of ERC20 `token` from `from` to `to`.
    /// Reverts upon failure.
    ///
    /// The `from` account must have at least `amount` approved for
    /// the current contract to manage.
    function safeTransferAllFrom(address token, address from, address to)
        internal
        returns (uint256 amount)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.

            mstore(0x40, to) // Store the `to` argument.
            mstore(0x2c, shl(96, from)) // Store the `from` argument.
            // Store the function selector of `balanceOf(address)`.
            mstore(0x0c, 0x70a08231000000000000000000000000)
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    gt(returndatasize(), 0x1f), // At least 32 bytes returned.
                    staticcall(gas(), token, 0x1c, 0x24, 0x60, 0x20)
                )
            ) {
                // Store the function selector of `TransferFromFailed()`.
                mstore(0x00, 0x7939f424)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }

            // Store the function selector of `transferFrom(address,address,uint256)`.
            mstore(0x00, 0x23b872dd)
            // The `amount` argument is already written to the memory word at 0x6c.
            amount := mload(0x60)

            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    // Set success to whether the call reverted, if not we check it either
                    // returned exactly 1 (can't just be non-zero data), or had no return data.
                    or(eq(mload(0x00), 1), iszero(returndatasize())),
                    call(gas(), token, 0, 0x1c, 0x64, 0x00, 0x20)
                )
            ) {
                // Store the function selector of `TransferFromFailed()`.
                mstore(0x00, 0x7939f424)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }

            mstore(0x60, 0) // Restore the zero slot to zero.
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Sends `amount` of ERC20 `token` from the current contract to `to`.
    /// Reverts upon failure.
    function safeTransfer(address token, address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x14, to) // Store the `to` argument.
            mstore(0x34, amount) // Store the `amount` argument.
            // Store the function selector of `transfer(address,uint256)`.
            mstore(0x00, 0xa9059cbb000000000000000000000000)

            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    // Set success to whether the call reverted, if not we check it either
                    // returned exactly 1 (can't just be non-zero data), or had no return data.
                    or(eq(mload(0x00), 1), iszero(returndatasize())),
                    call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                )
            ) {
                // Store the function selector of `TransferFailed()`.
                mstore(0x00, 0x90b8ec18)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }
            // Restore the part of the free memory pointer that was overwritten.
            mstore(0x34, 0)
        }
    }

    /// @dev Sends all of ERC20 `token` from the current contract to `to`.
    /// Reverts upon failure.
    function safeTransferAll(address token, address to) internal returns (uint256 amount) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, 0x70a08231) // Store the function selector of `balanceOf(address)`.
            mstore(0x20, address()) // Store the address of the current contract.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    gt(returndatasize(), 0x1f), // At least 32 bytes returned.
                    staticcall(gas(), token, 0x1c, 0x24, 0x34, 0x20)
                )
            ) {
                // Store the function selector of `TransferFailed()`.
                mstore(0x00, 0x90b8ec18)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }

            mstore(0x14, to) // Store the `to` argument.
            // The `amount` argument is already written to the memory word at 0x34.
            amount := mload(0x34)
            // Store the function selector of `transfer(address,uint256)`.
            mstore(0x00, 0xa9059cbb000000000000000000000000)

            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    // Set success to whether the call reverted, if not we check it either
                    // returned exactly 1 (can't just be non-zero data), or had no return data.
                    or(eq(mload(0x00), 1), iszero(returndatasize())),
                    call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                )
            ) {
                // Store the function selector of `TransferFailed()`.
                mstore(0x00, 0x90b8ec18)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }
            // Restore the part of the free memory pointer that was overwritten.
            mstore(0x34, 0)
        }
    }

    /// @dev Sets `amount` of ERC20 `token` for `to` to manage on behalf of the current contract.
    /// Reverts upon failure.
    function safeApprove(address token, address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x14, to) // Store the `to` argument.
            mstore(0x34, amount) // Store the `amount` argument.
            // Store the function selector of `approve(address,uint256)`.
            mstore(0x00, 0x095ea7b3000000000000000000000000)

            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    // Set success to whether the call reverted, if not we check it either
                    // returned exactly 1 (can't just be non-zero data), or had no return data.
                    or(eq(mload(0x00), 1), iszero(returndatasize())),
                    call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                )
            ) {
                // Store the function selector of `ApproveFailed()`.
                mstore(0x00, 0x3e3f8f73)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }
            // Restore the part of the free memory pointer that was overwritten.
            mstore(0x34, 0)
        }
    }

    /// @dev Returns the amount of ERC20 `token` owned by `account`.
    /// Returns zero if the `token` does not exist.
    function balanceOf(address token, address account) internal view returns (uint256 amount) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x14, account) // Store the `account` argument.
            // Store the function selector of `balanceOf(address)`.
            mstore(0x00, 0x70a08231000000000000000000000000)
            amount :=
                mul(
                    mload(0x20),
                    and( // The arguments of `and` are evaluated from right to left.
                        gt(returndatasize(), 0x1f), // At least 32 bytes returned.
                        staticcall(gas(), token, 0x10, 0x24, 0x20, 0x20)
                    )
                )
        }
    }
}