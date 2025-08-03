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
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./libs/Initialize.sol";
import "./libs/ERC721AManager.sol";
import "./libs/ShareProxy.sol";
import "./libs/AuctionMulti.sol";
import "./libs/Pause.sol";

contract ChainZokuAuctions is AuctionMulti, ERC721AManager, Initialize, ShareProxy, Pause, ReentrancyGuard {

    event EndAuction(uint256 auctionId, uint256 count);

    function init(address _resolverAddress, address _zokuByChainZoku, address _shareContract, address _multiSigContract) public onlyOwner isNotInitialized {
        AuctionMulti.setResolverAddress(_resolverAddress);
        ERC721AManager._setERC721Address(_zokuByChainZoku);
        ShareProxy._setShareContract(_shareContract);
        MultiSigProxy._setMultiSigContract(_multiSigContract);
    }

    function SendBid(uint256 _auctionId, uint256 _count) public payable override notPaused nonReentrant {
        super.SendBid(_auctionId, _count);
    }

    function ResolveAuction(uint256 _currentAuctionId) public onlyOwnerOrAdminsOrResolver {
        AuctionMulti.closeAuction(_currentAuctionId);

        uint256 count = 0;
        for(uint256 i = 0; i < auctions[_currentAuctionId].count; i++){
            if(bids[_currentAuctionId][i].bidder != address(this)){
                ERC721AManager._mint(bids[_currentAuctionId][i].bidder, 1);
                count += 1;
            }
        }

        ShareProxy.withdraw();

        emit EndAuction(_currentAuctionId, count);
    }

}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

// @author: miinded.com

abstract contract Admins is Ownable{

    mapping(address => bool) private admins;

    /**
    @dev check if the address is admin or not
    **/
    function isAdmin(address _admin) public view returns(bool) {
        return admins[_admin];
    }

    /**
    @dev Set the wallet address who can pass the onlyAdmin modifier
    **/
    function setAdminAddress(address _admin, bool _active) public virtual onlyOwner {
        admins[_admin] = _active;
    }

    /**
    @notice Check if the sender is owner() or admin
    **/
    modifier onlyOwnerOrAdmins() {
        require(admins[_msgSender()] == true || owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./Admins.sol";

error WithdrawBidFailed();
error BidWithValueTooLow();
error BidWithStepTooLow();
error BidWithBadAmount();
error BidWithBadCount();
error AuctionNotInit();
error AuctionNotOpen();
error AuctionClosed();
error AuctionAlreadyInit();
error NewAuctionNotInit();

contract AuctionMulti is Admins {

    struct Bid {
        address bidder;
        uint256 amount;
    }

    struct Auction {
        uint64 startAt;
        uint64 endAt;
        uint256 count;
        uint256 minBid;
        bool closed;
        bool initialized;
    }

    mapping(uint256 => Auction) public auctions;
    mapping(uint256 => Bid[50]) public bids;

    event NewBid(uint256 auctionId, address wallet, uint256 amount);
    event RefundBid(uint256 auctionId, address wallet, uint256 amount);

    address public resolverAddress;

    modifier onlyOwnerOrAdminsOrResolver() {
        require(isAdmin(_msgSender()) || owner() == _msgSender() || resolverAddress == _msgSender(), "Sender: is not resolverAddress");
        _;
    }

    modifier auctionAvailable(uint256 _auctionId){
        if(!isAuctionInitialized(_auctionId)){
            revert AuctionNotInit();
        }
        if(isAuctionClosed(_auctionId)){
            revert AuctionClosed();
        }
        if(!isAuctionOpen(_auctionId)){
            revert AuctionNotOpen();
        }
        _;
    }

    function configureAuction(uint256 _auctionId, Auction memory _newAuction) public virtual onlyOwnerOrAdminsOrResolver {
        if(auctions[_auctionId].initialized){
            revert AuctionAlreadyInit();
        }
        if(!_newAuction.initialized){
            revert NewAuctionNotInit();
        }

        auctions[_auctionId] = _newAuction;

        for(uint256 i = 0; i < _newAuction.count; i++){
            bids[_auctionId][i].bidder = address(this);
            bids[_auctionId][i].amount = _newAuction.minBid;
        }
    }

    function editAuction(uint256 _auctionId, Auction memory _auction) public virtual onlyOwnerOrAdminsOrResolver {
        if(!auctions[_auctionId].initialized){
            revert AuctionNotInit();
        }
        if(auctions[_auctionId].closed || _auction.closed){
            revert AuctionClosed();
        }
        if(!_auction.initialized){
            revert NewAuctionNotInit();
        }

        auctions[_auctionId] = _auction;
    }

    function closeAuction(uint256 _auctionId) public virtual onlyOwnerOrAdminsOrResolver {
        if(!auctions[_auctionId].initialized){
            revert AuctionNotInit();
        }
        if(auctions[_auctionId].closed){
            revert AuctionClosed();
        }

        auctions[_auctionId].closed = true;
    }

    function SendBid(uint256 _auctionId, uint256 _count) public payable virtual auctionAvailable(_auctionId) {
        uint256 amount = msg.value;

        if(_count > auctions[_auctionId].count || _count <= 0){
            revert BidWithBadCount();
        }

        unchecked{
            uint256 value = amount / _count;

            for(uint256 i = 0; i < _count; i++){
                _sendBid(_auctionId, value);
            }
        }

    }

    function _sendBid(uint256 _auctionId, uint256 _amount) internal virtual {

        uint256 minBidValue = getMinBid(_auctionId);

        if(minBidValue >= _amount){
            revert BidWithValueTooLow();
        }

        uint256 currentIndex = _getBidIndex(_auctionId, _amount);

        if(currentIndex >= auctions[_auctionId].count){
            revert BidWithValueTooLow();
        }

        if(_amount < bids[_auctionId][currentIndex].amount + 0.001 ether){
            revert BidWithStepTooLow();
        }

        if(_amount % 0.001 ether != 0){
            revert BidWithBadAmount();
        }

        // save the last bidder before moving
        Bid memory lastBider = bids[_auctionId][auctions[_auctionId].count - 1];

        // moving old auctions in the bids array
        for (uint256 i = auctions[_auctionId].count - 1 ; i > currentIndex; i--) {
            bids[_auctionId][i] = bids[_auctionId][i - 1];
        }

        // add new bidder in the bids array
        bids[_auctionId][currentIndex] = Bid(_msgSender(), _amount);

        emit NewBid(_auctionId, _msgSender(), _amount);

        // refund the last bidder of the auction
        if(lastBider.bidder != address(this)){
            emit RefundBid(_auctionId, lastBider.bidder, lastBider.amount);

            _withdraw(lastBider.bidder, lastBider.amount);
        }

    }

    function _getBidIndex(uint256 _auctionId,uint256 _amount) private view returns(uint256){
        uint256 currentIndex = 0;
        for (uint256 i = 0; i < auctions[_auctionId].count; i++) {
            if(_amount > bids[_auctionId][i].amount) {
                currentIndex = i;
                break;
            }
            if(_amount == bids[_auctionId][i].amount){
                currentIndex += 1;
            }
        }
        return currentIndex;
    }

    function getBids(uint256 _auctionId) public view returns (Bid[] memory) {
        Bid[] memory currentBids = new Bid[](auctions[_auctionId].count);
        for(uint256 i = 0; i < auctions[_auctionId].count; i++){
            currentBids[i] = bids[_auctionId][i];
        }
        return currentBids;
    }

    function getMinBid(uint256 _auctionId) public view returns(uint256){
        return bids[_auctionId][auctions[_auctionId].count - 1].amount;
    }

    function isBidValid(uint256 _auctionId, uint256 _count, uint256 _totalAmount) public view returns(bool){
        if(_count > auctions[_auctionId].count || _count <= 0){
            return false;
        }

        unchecked{
            uint256 amount = _totalAmount / _count;

            Bid[] memory _bids = new Bid[](50);
            for(uint256 i = 0; i < auctions[_auctionId].count; i++){
                _bids[i] = bids[_auctionId][i];
            }

            for(uint256 j = 0; j < _count; j++){

                uint256 minBidValue = _bids[auctions[_auctionId].count - 1].amount;

                if(minBidValue >= amount){
                    return false;
                }

                uint256 currentIndex = 0;
                for (uint256 i = 0; i < auctions[_auctionId].count; i++) {
                    if(amount > _bids[i].amount) {
                        currentIndex = i;
                        break;
                    }
                    if(amount == _bids[i].amount){
                        currentIndex += 1;
                    }
                }

                if(currentIndex >= auctions[_auctionId].count || amount < _bids[currentIndex].amount + 0.001 ether || amount % 0.001 ether != 0){
                    return false;
                }

                // moving old auctions in the bids array
                for (uint256 i = auctions[_auctionId].count - 1 ; i > currentIndex; i--) {
                    _bids[i] = _bids[i - 1];
                }

                // add new bidder in the bids array
                _bids[currentIndex] = Bid(_msgSender(), amount);
            }
        }
        return true;
    }

    function isAuctionInitialized(uint256 _auctionId) public view returns(bool){
        return auctions[_auctionId].initialized;
    }

    function isAuctionClosed(uint256 _auctionId) public view returns(bool){
        return auctions[_auctionId].closed;
    }

    function isAuctionOpen(uint256 _auctionId) public view returns(bool){
        return block.timestamp >= auctions[_auctionId].startAt && block.timestamp <= auctions[_auctionId].endAt;
    }

    function setResolverAddress(address _resolverAddress) public onlyOwnerOrAdmins {
        resolverAddress = _resolverAddress;
    }

    function _withdraw(address _address, uint256 _amount) private {
        (bool success, ) = _address.call{value: _amount}("");
        if(!success){
            revert WithdrawBidFailed();
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "./interfaces/IERC721Manager.sol";
import "./interfaces/IERC721AProxy.sol";
import "./MultiSigProxy.sol";

// @author: miinded.com

abstract contract ERC721AManager is IERC721Manager, MultiSigProxy {

    IERC721AProxy public ERC721Address;

    function setERC721Address(address _ERC721Address) public onlyOwnerOrAdmins{
        MultiSigProxy.validate("setERC721Address");

        _setERC721Address(_ERC721Address);
    }
    function _setERC721Address(address _ERC721Address) internal {
        ERC721Address = IERC721AProxy(_ERC721Address);
    }
    function _mint(address _wallet, uint256 _count) internal{
        ERC721Address.mint(_wallet, _count);
    }
    function _safeMint(address _wallet, uint256 _count) internal{
        ERC721Address.mint(_wallet, _count);
    }
    function _burn(uint256 _tokenId) internal{
        ERC721Address.burn(_tokenId);
    }
    function _totalSupply() internal view returns(uint256){
        return ERC721Address.totalSupply();
    }
    function _totalMinted() internal view returns(uint256){
        return ERC721Address.totalMinted();
    }
    function _totalBurned() internal view returns(uint256){
        return ERC721Address.totalBurned();
    }
    function balanceOf(address _wallet) internal view returns(uint256){
        return ERC721Address.balanceOf(_wallet);
    }
    function ownerOf(uint256 _tokenId) internal view returns(address){
        return ERC721Address.ownerOf(_tokenId);
    }
    function tokensOfOwner(address _wallet) internal view returns(uint256[] memory){
        return ERC721Address.tokensOfOwner(_wallet);
    }
    function transferFrom(address, address, uint256) public override virtual returns(bool) {
        return true;
    }

}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// @author: miinded.com

abstract contract Initialize {

    bool private _initialized = false;

    modifier isNotInitialized() {
        require(_initialized == false, "Already Initialized");
        _;
        _initialized = true;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./interfaces/IMultiSig.sol";
import "./Admins.sol";

// @author: miinded.com

abstract contract MultiSigProxy is Admins{

    address public multiSigContract;

    function _setMultiSigContract(address _contract) internal {
        multiSigContract = _contract;
    }

    function setMultiSigContract(address _contract) public onlyOwnerOrAdmins {
        IMultiSig(multiSigContract).validate("setMultiSigContract");

        _setMultiSigContract(_contract);
    }

    function validate(string memory _method) internal {
        IMultiSig(multiSigContract).validate(_method);
    }

}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Admins.sol";

// @author: miinded.com

abstract contract Pause is Admins{

    bool public pause = false;

    modifier notPaused(){
        if(_msgSender() != owner()){
            require(pause == false, "Contract paused");
        }
        _;
    }

    function setPause(bool _pause) public onlyOwnerOrAdmins {
        pause = _pause;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./MultiSigProxy.sol";

// @author: miinded.com

abstract contract ShareProxy is MultiSigProxy {

    address public shareContract;

    function setShareContract(address _shareContract) public onlyOwnerOrAdmins {
        MultiSigProxy.validate("setShareContract");

        _setShareContract(_shareContract);
    }

    function _setShareContract(address _shareContract) internal {
        shareContract = _shareContract;
    }
    function withdraw() public onlyOwnerOrAdmins {
        (bool success, ) = shareContract.call{value: address(this).balance}("");
        require(success, "Transfer failed.");
    }

}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "erc721a/contracts/extensions/IERC721AQueryable.sol";

// @author: miinded.com

interface IERC721AProxy is IERC721AQueryable{
    function mint(address _wallet, uint256 _count) external;
    function burn(uint256 _tokenId) external;
    function totalMinted() external view returns(uint256);
    function totalBurned() external view returns(uint256);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// @author: miinded.com

interface IERC721Manager{
    function transferFrom(address from, address to, uint256 tokenId) external returns(bool);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// @author: miinded.com

interface IMultiSig {
    function validate(string memory) external;
}
// SPDX-License-Identifier: MIT
// ERC721A Contracts v4.2.3
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
// ERC721A Contracts v4.2.3
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