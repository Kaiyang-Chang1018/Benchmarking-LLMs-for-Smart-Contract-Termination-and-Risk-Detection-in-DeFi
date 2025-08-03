// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ISoulsLocker {
    function getSoulsInHero(uint256 heroId) external view returns (uint16[] memory);
}

interface IWrapper {
    function transferFromBatch(address from, address to, uint256[] calldata tokenId) external;
}

interface IEditions1155 {
    function mint(address to, uint256 id, uint256 amount, bytes calldata data, uint256 minterIdx) external;
}

abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(msg.sender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract SpiritsToEdition is Ownable {

    // Le Anime v2 tokenId offset (tokenId = editionNr + OFFSETAN2)
    uint256 private constant OFFSETAN2 = 100000;

    uint256 private constant MINTER_ID = 1;

    uint256 private constant EDITION_ID = 2;

    uint256 private constant editionSizeSpirits = 20;

    uint256 private constant editionSizeEth = 20;

    address private constant leAnimeAddress = 0x03BEbcf3D62C1e7465f8a095BFA08a79CA2892A1;

    address private constant locker = 0x1eb4490091bd0fFF6c3973623C014D082936EA03;

    address private constant talanjiAddress = 0x78C7ac5D41bE409453e3B32E79B7f832D7c0A372;

    address private constant erc1155editions = 0xfb0EcD5d5cAD8E498f49000A6CE5423763b039EC;

    uint256 public editionCounterSpirits;
    uint256 public editionCounterEth;
    
    uint256 public ethPrice;
    uint256 public spiritsPrice;

    bool public dropActive;

    constructor(){
        ethPrice = 0.1 ether;
        spiritsPrice = 3;
    }

    /////////
    // OWNER FUNCTIONS
    /////////

    // Withdraw all ETH to owner address
    function withdrawEth() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    // Activate / Deactivate drop
    function activateDrop(bool activeState) public onlyOwner {
        dropActive = activeState;
    }

    // Set the prices in ETH and Nr of spirits to sacrifice
    function setPrices(uint256 ethPrice_, uint256 spiritsPrice_) public onlyOwner {
        ethPrice = ethPrice_;
        spiritsPrice = spiritsPrice_;
    }

    /////////
    // SALE
    /////////

    function buyWithEth() payable external {
        require(dropActive, "Not Active");
        require(editionCounterEth < editionSizeEth, "Sold Out");
        require(msg.value == ethPrice, "Price Not Matching");

        editionCounterEth++;

        IEditions1155(erc1155editions).mint(msg.sender, EDITION_ID, 1, "", MINTER_ID);
    }

    function buyWithSpirits(uint256[] calldata tokenId) external {
        require(dropActive, "Not Active");
        require(editionCounterSpirits < editionSizeSpirits, "Sold out");
        require(tokenId.length == spiritsPrice, "Spirits Not Matching");

        // temporary variable to store current tokenId
        uint16 currTokenId;

        for (uint256 i = 0; i < tokenId.length; ++i) {
            currTokenId = uint16(tokenId[i] - OFFSETAN2);

            // needs to be a Spirit NFT (tokenId >= 1574)
            require(currTokenId > 1573, "Not a Spirit");

            // check that the NFT is not a Hero - it needs to contain 0 NFTs
            require(ISoulsLocker(locker).getSoulsInHero(currTokenId).length == 0, "Cannot sacrifice a Hero");
        }

        // transfer and lock all the sacrificed spirits into talanji
        IWrapper(leAnimeAddress).transferFromBatch(msg.sender, talanjiAddress, tokenId);

        // add edition to counter
        editionCounterSpirits++;

        // mint here
        IEditions1155(erc1155editions).mint(msg.sender, EDITION_ID, 1, "", MINTER_ID);

    }

}