// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/vectorized/solady/blob/main/src/utils/SafeTransferLib.sol";
import "https://github.com/Vectorized/solady/blob/main/src/utils/MerkleProofLib.sol";

contract ArtMarketplaceV7 is Ownable {
    uint256 private constant BPS = 10_000;
    uint256 private constant BID_INCREASE_THRESHOLD_ETH = 0.2 ether;
    uint256 private constant BID_INCREASE_THRESHOLD_USDC = 300 * USDC_CONSTANT;
    uint8 private constant DEFAULT_PLATFORM_FEE = 30; // whole % points
    uint256 private constant EXTENSION_TIME = 5 minutes;
    uint256 private constant INIT_AUCTION_DURATION = 72 hours;
    uint256 private constant MIN_BID_ETH = 0.1 ether;
    uint256 private constant MIN_BID_USDC = 30 * USDC_CONSTANT;
    uint256 private constant MIN_BID_INCREASE_PRE = 2_000;
    uint256 private constant MIN_BID_INCREASE_POST = 1_000;
    uint256 private constant SAFE_GAS_LIMIT = 30_000;
    // Mainnet USDC: 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
    // Sepolia USDC: 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238
    address private immutable USDC;
    uint256 private constant USDC_CONSTANT = 10**6; // USDC uses 6 decimals instead of eth's 18
    IDelegationRegistry private constant DELEGATE_REGISTRY = IDelegationRegistry(
        address(0x00000000000000447e69651d841bD8D104Bed493)
    );

    address public accessRole;
    address public beneficiary;
    bool public paused;

    struct Auction {
        uint24 offsetFromEnd;
        uint72 amount;
        address bidder;
    }

    struct AuctionStatus {
        uint256 endTime;
        uint256 currentBid;
        address highestBidder;
        uint256 buyNowPrice;
        uint256 reservePrice;
    }

    struct AuctionConfig {
        address artist;
        uint8 platformFee; // in whole % points (30 = 30%)
        uint8 royalty; // in whole % points, should be 0 for primary sales
        uint80 buyNowStartTime;
        uint80 auctionStartTime;
        uint88 buyNowPrice;
        uint88 reservePrice;
        uint88 preBidPrice;
        address seller; // when seller is schedueled as 0x0, seller defaults to the artist (i.e. primary sale)
        bool usdcFlag; // true for usdc, false for eth
        bytes32 accessListRoot;
    }

    struct AccessListConfig {
        uint80 accessListDuration;
        uint8 buyNowLimit;
    }

    mapping(bytes32 => AuctionConfig) public auctionConfig;
    mapping(uint256 => Auction) public auctionIdToAuction;
    mapping(uint256 => bytes32) public auctionIdToConfigHash;
    mapping(bytes32 => mapping(address => uint256)) public buyNowCount;
    mapping(bytes32 => AccessListConfig) public accessListConfig;
    mapping(bytes32 => mapping(address => bool)) public accessListConf;

    event BidMade(
        uint256 indexed auctionId,
        address indexed collectionAddress,
        uint256 indexed tokenId,
        address bidder,
        uint256 amount,
        uint256 timestamp
    );
    struct Receipt {
        address orderMaker;
        address orderTaker;
        address collection;
        uint256 tokenId;
        address currency; // 0x0 when ETH sale
        address artist;
        address platform;
        uint256 salePrice; // in wei (salePrice = funds to seller + platformFee + royalty = price buyer paid)
        uint256 platformFee; // in wei
        uint256 royalty; // in wei
    }
    event Sale(Receipt[] receipts);

    constructor(
        address _contractOwner,
        address _beneficiary,
        address _usdcAddress,
        address _accessRole
    ) Ownable(_contractOwner) {
        beneficiary = _beneficiary;
        USDC = _usdcAddress;
        accessRole = _accessRole;
    }

    function bid(
        uint256[] calldata auctionIds,
        uint256[] calldata expectedPrices
    ) public payable {
        _bid(auctionIds, expectedPrices, msg.sender);
    }

    function buyNow(
        uint256[] calldata auctionIds
    ) public payable {
        _buyNow(auctionIds, msg.sender);
    }

    function bid(
        uint256[] calldata auctionIds,
        uint256[] calldata expectedPrices,
        address delegator
    ) public payable {
        _bid(auctionIds, expectedPrices, delegator);
    }

    function buyNow(
        uint256[] calldata auctionIds,
        address delegator
    ) public payable {
        _buyNow(auctionIds, delegator);
    }

    function grantAccessAndBid(
        bytes32[] calldata proof,
        bytes32 accessListRoot,
        uint256[] calldata auctionIds,
        uint256[] calldata expectedPrices
    ) external payable {
        grantAccess(proof, accessListRoot, msg.sender);
        bid(auctionIds, expectedPrices);
    }

    function grantAccessAndBuyNow(
        bytes32[] calldata proof,
        bytes32 accessListRoot,
        uint256[] calldata auctionIds
    ) external payable {
        grantAccess(proof, accessListRoot, msg.sender);
        buyNow(auctionIds);
    }

    function grantAccessAndBid(
        bytes32[] calldata proof,
        bytes32 accessListRoot,
        uint256[] calldata auctionIds,
        uint256[] calldata expectedPrices,
        address delegator
    ) external payable {
        grantAccess(proof, accessListRoot, delegator);
        bid(auctionIds, expectedPrices, delegator);
    }

    function grantAccessAndBuyNow(
        bytes32[] calldata proof,
        bytes32 accessListRoot,
        uint256[] calldata auctionIds,
        address delegator
    ) external payable {
        grantAccess(proof, accessListRoot, delegator);
        buyNow(auctionIds, delegator);
    }

    struct BidVars {
        uint256 totalETH;
        uint256 totalUSDC;
    }

    function _bid(
        uint256[] calldata auctionIds,
        uint256[] calldata expectedPrices,
        address authedBuyer
    ) internal {
        require(!paused, "Bidding is paused");
        require(auctionIds.length == expectedPrices.length);
        if (authedBuyer != msg.sender) {
            require(
                DELEGATE_REGISTRY.checkDelegateForContract(
                    msg.sender,
                    authedBuyer,
                    address(this),
                    ""
            ));
        }
        BidVars memory vars = BidVars(0,0);
        for (uint256 i; i < auctionIds.length; ++i) {
            uint256 auctionId = auctionIds[i];
            uint256 expectedPrice = expectedPrices[i];
            AuctionConfig memory config = getConfig(auctionId);
            AccessListConfig memory accessConfig = accessListConfig[config.accessListRoot];

            // kickstart auction functionality
            bytes32 oldConfigHash;
            if (config.auctionStartTime == type(uint80).max) {
                oldConfigHash = auctionIdToConfigHash[auctionId];
                config.auctionStartTime = uint80(block.timestamp);
                bytes32 configHash = keccak256(abi.encode(config));
                if (auctionConfig[configHash].auctionStartTime == 0) {
                    auctionConfig[configHash] = config;
                }
                auctionIdToConfigHash[auctionId] = configHash;
            }

            if (
                !(isAuctionActive(auctionId) ||
                    (config.preBidPrice > 0 && expectedPrice >= config.preBidPrice && !isAuctionOver(auctionId))
                ) ||
                (config.accessListRoot != bytes32(0x0)
                    && accessListConf[config.accessListRoot][authedBuyer] == false
                    && block.timestamp < config.auctionStartTime + accessConfig.accessListDuration
                )
            ) {
                if (oldConfigHash != bytes32(0x0)) {
                    auctionIdToConfigHash[auctionId] = oldConfigHash;
                }
                continue;
            }

            Auction memory highestBid = auctionIdToAuction[auctionId];
            uint256 bidIncrease = highestBid.amount >=
                getBidIncreaseThreshold(config.usdcFlag)
                ? MIN_BID_INCREASE_POST
                : MIN_BID_INCREASE_PRE;

            if (
                expectedPrice >=
                ((highestBid.amount * (BPS + bidIncrease)) / BPS) &&
                expectedPrice >= getReservePrice(auctionId)
            ) {
                uint256 refundAmount;
                address refundBidder;
                uint256 offset = highestBid.offsetFromEnd;
                uint256 endTime = getAuctionEndTime(auctionId);

                if (highestBid.amount > 0) {
                    refundAmount = highestBid.amount;
                    refundBidder = highestBid.bidder;
                }

                if (endTime - block.timestamp < EXTENSION_TIME) {
                    offset += block.timestamp + EXTENSION_TIME - endTime;
                }

                auctionIdToAuction[auctionId] = Auction(
                    uint24(offset),
                    uint72(expectedPrice),
                    msg.sender
                );

                if (config.usdcFlag) {
                    vars.totalUSDC += expectedPrice;
                } else {
                    vars.totalETH += expectedPrice;
                }

                emit BidMade(
                    auctionId,
                    getCollectionFromId(auctionId),
                    getArtTokenIdFromId(auctionId),
                    msg.sender,
                    expectedPrice,
                    block.timestamp
                );

                if (refundAmount > 0) {
                    if (config.usdcFlag) {
                        ERC20(USDC).transfer(refundBidder, refundAmount);
                    } else {
                        SafeTransferLib.forceSafeTransferETH(
                            refundBidder,
                            refundAmount,
                            SAFE_GAS_LIMIT
                        );
                    }
                }
            } else {
                if (oldConfigHash != bytes32(0x0)) {
                    auctionIdToConfigHash[auctionId] = oldConfigHash;
                }
            }
        }
        if (vars.totalUSDC > 0) {
            ERC20(USDC).transferFrom(msg.sender, address(this), vars.totalUSDC);
        }
        require(vars.totalETH > 0, "All bids failed.");
        require(msg.value >= vars.totalETH, "Incorrect amount of ETH sent");
        uint256 totalFailedETH = msg.value - vars.totalETH;
        if (totalFailedETH > 0) {
            SafeTransferLib.forceSafeTransferETH(
                msg.sender,
                totalFailedETH,
                SAFE_GAS_LIMIT
            );
        }
    }

    struct BuyNowVars {
        uint256 totalETH;
        uint256 amountForBeneETH;
        uint256 amountForBeneUSDC;
    }

    function _buyNow(
        uint256[] calldata auctionIds,
        address authedBuyer
    ) internal {
        require(!paused, "Buying is paused");
        if (authedBuyer != msg.sender) {
            require(
                DELEGATE_REGISTRY.checkDelegateForContract(
                    msg.sender,
                    authedBuyer,
                    address(this),
                    ""
            ));
        }

        BuyNowVars memory vars = BuyNowVars(0,0,0);

        // Create a dynamic array to store tokenIds of successfully purchased tokens
        Receipt[] memory successfulAuctions = new Receipt[](auctionIds.length);
        uint256 successfulCount = 0;

        for (uint256 i = 0; i < auctionIds.length; ++i) {
            uint256 auctionId = auctionIds[i];
            AuctionConfig memory config = getConfig(auctionId);
            uint256 amountToPay = config.buyNowPrice;
            AccessListConfig memory accessConfig = accessListConfig[config.accessListRoot];

            if (
                (block.timestamp < config.buyNowStartTime) ||
                auctionIdToAuction[auctionId].amount > 0 ||
                amountToPay == 0 ||
                (accessConfig.buyNowLimit != 0 && buyNowCount[config.accessListRoot][authedBuyer] >= accessConfig.buyNowLimit) ||
                (config.accessListRoot != bytes32(0x0) 
                    && accessListConf[config.accessListRoot][authedBuyer] == false
                    && block.timestamp < config.buyNowStartTime + accessConfig.accessListDuration
                )
            ) {
                continue;
            }

            buyNowCount[config.accessListRoot][authedBuyer] += 1;

            // Mark the auction as settled and store the amount paid
            config.auctionStartTime = uint80(block.timestamp - INIT_AUCTION_DURATION);
            bytes32 configHash = keccak256(abi.encode(config));
            if (auctionConfig[configHash].auctionStartTime == 0) {
                auctionConfig[configHash] = config;
            }
            auctionIdToConfigHash[auctionId] = configHash;
            auctionIdToAuction[auctionId] = Auction(
                0,
                uint72(amountToPay),
                msg.sender
            );

            if (!config.usdcFlag) {
                vars.totalETH += amountToPay;
            }

            // Mint the token to the buyer
            _mintOrTransfer(msg.sender, auctionId);
            
            uint256 amountForPlatform = (amountToPay * config.platformFee) / 100;
            uint256 royalty = (amountToPay * config.royalty) / 100;
            uint256 amountForSeller = amountToPay - amountForPlatform - royalty;

            successfulAuctions[successfulCount] = Receipt(
                config.seller,
                msg.sender,
                getCollectionFromId(auctionId),
                getArtTokenIdFromId(auctionId),
                config.usdcFlag ? USDC : address(0),
                config.artist,
                beneficiary,
                amountToPay,
                amountForPlatform,
                royalty
            );
            successfulCount++;

            if (config.usdcFlag) {
                vars.amountForBeneUSDC += amountForPlatform;
                ERC20(USDC).transferFrom(msg.sender, config.seller, amountForSeller);
                if (royalty > 0) {
                    ERC20(USDC).transferFrom(msg.sender, config.artist, royalty);
                }
            } else {
                vars.amountForBeneETH += amountForPlatform;
                SafeTransferLib.forceSafeTransferETH(
                    config.seller,
                    amountForSeller,
                    SAFE_GAS_LIMIT
                );
                if (royalty > 0) {
                    SafeTransferLib.forceSafeTransferETH(
                        config.artist,
                        royalty,
                        SAFE_GAS_LIMIT
                    );
                }
            }
        }

        if (vars.amountForBeneUSDC > 0) {
            ERC20(USDC).transferFrom(msg.sender, beneficiary, vars.amountForBeneUSDC);
        }
        require(msg.value >= vars.totalETH, "Incorrect amount of ETH sent");
        uint256 totalFailedETH = msg.value - vars.totalETH;
        if (totalFailedETH > 0) {
            SafeTransferLib.forceSafeTransferETH(
                msg.sender,
                totalFailedETH,
                SAFE_GAS_LIMIT
            );
        }
        if (vars.amountForBeneETH > 0) {
            SafeTransferLib.forceSafeTransferETH(
                beneficiary,
                vars.amountForBeneETH,
                SAFE_GAS_LIMIT
            );
        }

        // Emit Sale event for all successful token purchases
        if (successfulCount > 0) {
            // Create a resized array with only the successfully bought tokenIds
            Receipt[] memory sales = new Receipt[](successfulCount);
            for (uint256 i = 0; i < successfulCount; ++i) {
                sales[i] = successfulAuctions[i];
            }

            emit Sale(sales);
        } else {
            revert("All buys failed.");
        }
    }

    function grantAccess(
        bytes32[] calldata proof,
        bytes32 accessListRoot,
        address account
    ) public {
        if (MerkleProofLib.verifyCalldata(proof, accessListRoot, keccak256(abi.encodePacked(account))) == true) {
            accessListConf[accessListRoot][account] = true;
        }
    }

    function settleAuctions(uint256[] calldata auctionIds) external {
        uint256 amountForBeneETH;
        uint256 amountForBeneUSDC;
        Receipt[] memory successfulAuctions = new Receipt[](auctionIds.length);
        uint256 successfulCount = 0;

        for (uint256 i; i < auctionIds.length; ++i) {
            uint256 auctionId = auctionIds[i];
            Auction memory highestBid = auctionIdToAuction[auctionId];
            require(isAuctionOver(auctionId), "Auction is still active");

            uint256 amountToPay = highestBid.amount;
            require(amountToPay > 0);
            _mintOrTransfer(highestBid.bidder, auctionId);
            AuctionConfig memory config = getConfig(auctionId);

            uint256 amountForPlatform = (amountToPay * config.platformFee) / 100;
            uint256 royalty = (amountToPay * config.royalty) / 100;
            uint256 amountForSeller = amountToPay - amountForPlatform - royalty;

            successfulAuctions[successfulCount] = Receipt(
                config.seller,
                highestBid.bidder,
                getCollectionFromId(auctionId),
                getArtTokenIdFromId(auctionId),
                config.usdcFlag ? USDC : address(0),
                config.artist,
                beneficiary,
                amountToPay,
                amountForPlatform,
                royalty
            );
            successfulCount++;

            if (config.usdcFlag) {
                amountForBeneUSDC += amountForPlatform;
                ERC20(USDC).transfer(config.seller, amountForSeller);
                if (royalty > 0) {
                    ERC20(USDC).transfer(config.artist, royalty);
                }
            } else {
                amountForBeneETH += amountForPlatform;
                SafeTransferLib.forceSafeTransferETH(
                    config.seller,
                    amountForSeller,
                    SAFE_GAS_LIMIT
                );
                if (royalty > 0) {
                    SafeTransferLib.forceSafeTransferETH(
                        config.artist,
                        royalty,
                        SAFE_GAS_LIMIT
                    );
                }
            }
        }

        emit Sale(successfulAuctions);

        if (amountForBeneUSDC > 0) {
            ERC20(USDC).transfer(beneficiary, amountForBeneUSDC);
        }
        if (amountForBeneETH > 0) {
            SafeTransferLib.forceSafeTransferETH(
                beneficiary,
                amountForBeneETH,
                SAFE_GAS_LIMIT
            );
        }
    }

    // INTERNAL

    function _mintOrTransfer(address to, uint256 auctionId) internal {
        address collection = getCollectionFromId(auctionId);
        uint256 tokenId = getArtTokenIdFromId(auctionId);
        try INFT(collection).ownerOf(tokenId) returns (address _owner) {
            if (_owner == address(0)) {
                INFT(collection).mint(to, tokenId);
            } else {
                INFT(collection).transferFrom(_owner, to, tokenId);
            }
        } catch {
            INFT(collection).mint(to, tokenId);
        }
    }

    function _resetAuction(address collectionAddress, uint256 tokenId)
        internal
    {
        uint256 auctionId = artTokentoAuctionId(collectionAddress, tokenId);
        if (!isAuctionOver(auctionId)) {
            Auction memory auctionData = auctionIdToAuction[auctionId];
            if (auctionData.amount > 0) {
                SafeTransferLib.forceSafeTransferETH(
                    auctionData.bidder,
                    auctionData.amount,
                    SAFE_GAS_LIMIT
                );
            }
        }
        auctionIdToConfigHash[auctionId] = bytes32(0);
        auctionIdToAuction[auctionId] = Auction(0, 0, address(0));
    }

    function _schedule(
        address collectionAddress,
        uint256 tokenId,
        uint256 buyNowStartTime,
        uint256 auctionStartTime,
        address artist,
        address seller,
        uint256 platformFee,
        uint256 royalty,
        uint256 buyNowPrice,
        uint256 reserve,
        uint256 preBidPrice,
        bool usdcFlag,
        bytes32 accessListRoot
    ) internal {
        uint256 auctionId = artTokentoAuctionId(collectionAddress, tokenId);
        require(auctionIdToConfigHash[auctionId] == bytes32(0));

        uint256 adjAucStartTime = auctionStartTime;
        if (adjAucStartTime == 0) {
            adjAucStartTime = type(uint80).max;
        }

        AuctionConfig memory config = AuctionConfig(
            artist,
            platformFee == 0 ? DEFAULT_PLATFORM_FEE : uint8(platformFee),
            uint8(royalty),
            uint80(buyNowStartTime),
            uint80(adjAucStartTime),
            uint88(buyNowPrice),
            uint88(reserve),
            uint88(preBidPrice),
            seller == address(0) ? artist : seller,
            usdcFlag,
            accessListRoot

        );
        bytes32 configHash = keccak256(abi.encode(config));
        if (auctionConfig[configHash].auctionStartTime == 0) {
            auctionConfig[configHash] = config;
        }
        auctionIdToConfigHash[auctionId] = configHash;
    }

    // ONLY ACCESS or OWNER ROLE

    function grantAccess(bytes32 accessListRoot, address[] calldata accounts) external {
        require(msg.sender == owner() || msg.sender == accessRole);
        for (uint256 i = 0; i < accounts.length; ++i) {
            accessListConf[accessListRoot][accounts[i]] = true;
        }
    }

    // ONLY OWNER

    function configureAccessList(
        bytes32 accessListRoot,
        uint256 accessListDuration,
        uint256 buyNowLimit
    ) external onlyOwner {
        require(accessListRoot != bytes32(0x0));
        accessListConfig[accessListRoot] = AccessListConfig(
            uint80(accessListDuration),
            uint8(buyNowLimit)
        );
    }

    function scheduleAuctionsLight(
        address collection,
        uint256[] calldata tokenIds,
        uint256 buyNowStartTime,
        uint256 auctionStartTime,
        address artist,
        address seller,
        uint256 platformFee,
        uint256 royalty,
        uint256 buyNowPrice,
        uint256 reservePrice,
        uint256 preBidPrice,
        bool usdcFlag,
        bytes32 accessListRoot,
        uint256 accessListDuration,
        uint256 buyNowLimit
    ) external onlyOwner {
        if(accessListRoot != bytes32(0x0)) {
            accessListConfig[accessListRoot] = AccessListConfig(
                uint80(accessListDuration),
                uint8(buyNowLimit)
            );
        }
        for (uint256 i; i < tokenIds.length; ++i) {
            _schedule(
                collection,
                tokenIds[i],
                buyNowStartTime,
                auctionStartTime,
                artist,
                seller,
                platformFee,
                royalty,
                buyNowPrice,
                reservePrice,
                preBidPrice,
                usdcFlag,
                accessListRoot
            );
        }
    }

    function resetAuctions(
        address[] calldata collections,
        uint256[] calldata tokenIds
    ) external onlyOwner {
        for (uint256 i; i < collections.length; ++i) {
            _resetAuction(collections[i], tokenIds[i]);
        }
    }

    function setAccessRole (address newAccessManager) external onlyOwner {
        accessRole = newAccessManager;
    }

    function setBeneficiary(address _beneficiary) public onlyOwner {
        beneficiary = _beneficiary;
    }

    function setPaused(bool _paused) external onlyOwner {
        paused = _paused;
    }

    // GETTERS

    function artTokentoAuctionId(address collection, uint256 tokenId)
        public
        pure
        returns (uint256)
    {
        return (uint256(uint160(collection)) << 96) | uint96(tokenId);
    }

    function isAuctionActive(uint256 auctionId) public view returns (bool) {
        uint256 startTime = getConfig(auctionId).auctionStartTime;
        uint256 endTime = getAuctionEndTime(auctionId);
        return (startTime > 0 &&
            block.timestamp >= startTime &&
            block.timestamp < endTime);
    }

    function isAuctionOver(uint256 auctionId) public view returns (bool) {
        uint256 startTime = getConfig(auctionId).auctionStartTime;
        uint256 endTime = getAuctionEndTime(auctionId);
        return (startTime > 0 && block.timestamp >= endTime);
    }

    function getAuctionEndTime(uint256 auctionId)
        public
        view
        returns (uint256)
    {
        return
            getConfig(auctionId).auctionStartTime +
            INIT_AUCTION_DURATION +
            auctionIdToAuction[auctionId].offsetFromEnd;
    }

    function getAuctionStartTime(uint256 auctionId)
        public
        view
        returns (uint256)
    {
        return getConfig(auctionId).auctionStartTime;
    }

    function getCollectionFromId(uint256 id) public pure returns (address) {
        return address(uint160(id >> 96));
    }

    function getConfig(uint256 id) public view returns (AuctionConfig memory) {
        return auctionConfig[auctionIdToConfigHash[id]];
    }

    function getArtTokenIdFromId(uint256 id) public pure returns (uint256) {
        return uint256(uint96(id));
    }

    function getReservePrice(uint256 auctionId) public view returns (uint256) {
        AuctionConfig memory config = getConfig(auctionId);
        uint256 reserve = config.reservePrice;
        return reserve != 0 ? reserve : getMinBid(config.usdcFlag);
    }

    function getBidIncreaseThreshold(bool isUSDC)
        internal
        pure
        returns (uint256)
    {
        return
            isUSDC ? BID_INCREASE_THRESHOLD_USDC : BID_INCREASE_THRESHOLD_ETH;
    }

    function getMinBid(bool isUSDC) internal pure returns (uint256) {
        return isUSDC ? MIN_BID_USDC : MIN_BID_ETH;
    }

    function getAuctionStatusBulk(uint256[] calldata auctionIds) external view returns (AuctionStatus[] memory) {
        AuctionStatus[] memory statuses = new AuctionStatus[](auctionIds.length);
        for(uint256 i; i < auctionIds.length; i++){
            uint256 auctionId = auctionIds[i];
            Auction memory auc = auctionIdToAuction[auctionId];
            AuctionConfig memory aucConfig = getConfig(auctionId);
            statuses[i] = AuctionStatus(
                getAuctionEndTime(auctionId),
                auc.amount,
                auc.bidder,
                aucConfig.buyNowPrice,
                getReservePrice(auctionId)
            );
        }
        return statuses;
    }
    
}

interface IDelegationRegistry {
    function checkDelegateForContract(address to, address from, address contract_, bytes32 rights) external view returns (bool);
}

interface ERC20 {
    function transfer(address recipient, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
}

interface INFT {
    function mint(address to, uint256 tokenId) external;
    function ownerOf(uint256 tokenId) external view returns (address);
    function transferFrom(address from, address to, uint256 tokenId) external;
}
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
pragma solidity ^0.8.4;

/// @notice Gas optimized verification of proof of inclusion for a leaf in a Merkle tree.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/MerkleProofLib.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/MerkleProofLib.sol)
/// @author Modified from OpenZeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/cryptography/MerkleProof.sol)
library MerkleProofLib {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*            MERKLE PROOF VERIFICATION OPERATIONS            */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns whether `leaf` exists in the Merkle tree with `root`, given `proof`.
    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf)
        internal
        pure
        returns (bool isValid)
    {
        /// @solidity memory-safe-assembly
        assembly {
            if mload(proof) {
                // Initialize `offset` to the offset of `proof` elements in memory.
                let offset := add(proof, 0x20)
                // Left shift by 5 is equivalent to multiplying by 0x20.
                let end := add(offset, shl(5, mload(proof)))
                // Iterate over proof elements to compute root hash.
                for {} 1 {} {
                    // Slot of `leaf` in scratch space.
                    // If the condition is true: 0x20, otherwise: 0x00.
                    let scratch := shl(5, gt(leaf, mload(offset)))
                    // Store elements to hash contiguously in scratch space.
                    // Scratch space is 64 bytes (0x00 - 0x3f) and both elements are 32 bytes.
                    mstore(scratch, leaf)
                    mstore(xor(scratch, 0x20), mload(offset))
                    // Reuse `leaf` to store the hash to reduce stack operations.
                    leaf := keccak256(0x00, 0x40)
                    offset := add(offset, 0x20)
                    if iszero(lt(offset, end)) { break }
                }
            }
            isValid := eq(leaf, root)
        }
    }

    /// @dev Returns whether `leaf` exists in the Merkle tree with `root`, given `proof`.
    function verifyCalldata(bytes32[] calldata proof, bytes32 root, bytes32 leaf)
        internal
        pure
        returns (bool isValid)
    {
        /// @solidity memory-safe-assembly
        assembly {
            if proof.length {
                // Left shift by 5 is equivalent to multiplying by 0x20.
                let end := add(proof.offset, shl(5, proof.length))
                // Initialize `offset` to the offset of `proof` in the calldata.
                let offset := proof.offset
                // Iterate over proof elements to compute root hash.
                for {} 1 {} {
                    // Slot of `leaf` in scratch space.
                    // If the condition is true: 0x20, otherwise: 0x00.
                    let scratch := shl(5, gt(leaf, calldataload(offset)))
                    // Store elements to hash contiguously in scratch space.
                    // Scratch space is 64 bytes (0x00 - 0x3f) and both elements are 32 bytes.
                    mstore(scratch, leaf)
                    mstore(xor(scratch, 0x20), calldataload(offset))
                    // Reuse `leaf` to store the hash to reduce stack operations.
                    leaf := keccak256(0x00, 0x40)
                    offset := add(offset, 0x20)
                    if iszero(lt(offset, end)) { break }
                }
            }
            isValid := eq(leaf, root)
        }
    }

    /// @dev Returns whether all `leaves` exist in the Merkle tree with `root`,
    /// given `proof` and `flags`.
    ///
    /// Note:
    /// - Breaking the invariant `flags.length == (leaves.length - 1) + proof.length`
    ///   will always return false.
    /// - The sum of the lengths of `proof` and `leaves` must never overflow.
    /// - Any non-zero word in the `flags` array is treated as true.
    /// - The memory offset of `proof` must be non-zero
    ///   (i.e. `proof` is not pointing to the scratch space).
    function verifyMultiProof(
        bytes32[] memory proof,
        bytes32 root,
        bytes32[] memory leaves,
        bool[] memory flags
    ) internal pure returns (bool isValid) {
        // Rebuilds the root by consuming and producing values on a queue.
        // The queue starts with the `leaves` array, and goes into a `hashes` array.
        // After the process, the last element on the queue is verified
        // to be equal to the `root`.
        //
        // The `flags` array denotes whether the sibling
        // should be popped from the queue (`flag == true`), or
        // should be popped from the `proof` (`flag == false`).
        /// @solidity memory-safe-assembly
        assembly {
            // Cache the lengths of the arrays.
            let leavesLength := mload(leaves)
            let proofLength := mload(proof)
            let flagsLength := mload(flags)

            // Advance the pointers of the arrays to point to the data.
            leaves := add(0x20, leaves)
            proof := add(0x20, proof)
            flags := add(0x20, flags)

            // If the number of flags is correct.
            for {} eq(add(leavesLength, proofLength), add(flagsLength, 1)) {} {
                // For the case where `proof.length + leaves.length == 1`.
                if iszero(flagsLength) {
                    // `isValid = (proof.length == 1 ? proof[0] : leaves[0]) == root`.
                    isValid := eq(mload(xor(leaves, mul(xor(proof, leaves), proofLength))), root)
                    break
                }

                // The required final proof offset if `flagsLength` is not zero, otherwise zero.
                let proofEnd := add(proof, shl(5, proofLength))
                // We can use the free memory space for the queue.
                // We don't need to allocate, since the queue is temporary.
                let hashesFront := mload(0x40)
                // Copy the leaves into the hashes.
                // Sometimes, a little memory expansion costs less than branching.
                // Should cost less, even with a high free memory offset of 0x7d00.
                leavesLength := shl(5, leavesLength)
                for { let i := 0 } iszero(eq(i, leavesLength)) { i := add(i, 0x20) } {
                    mstore(add(hashesFront, i), mload(add(leaves, i)))
                }
                // Compute the back of the hashes.
                let hashesBack := add(hashesFront, leavesLength)
                // This is the end of the memory for the queue.
                // We recycle `flagsLength` to save on stack variables (sometimes save gas).
                flagsLength := add(hashesBack, shl(5, flagsLength))

                for {} 1 {} {
                    // Pop from `hashes`.
                    let a := mload(hashesFront)
                    // Pop from `hashes`.
                    let b := mload(add(hashesFront, 0x20))
                    hashesFront := add(hashesFront, 0x40)

                    // If the flag is false, load the next proof,
                    // else, pops from the queue.
                    if iszero(mload(flags)) {
                        // Loads the next proof.
                        b := mload(proof)
                        proof := add(proof, 0x20)
                        // Unpop from `hashes`.
                        hashesFront := sub(hashesFront, 0x20)
                    }

                    // Advance to the next flag.
                    flags := add(flags, 0x20)

                    // Slot of `a` in scratch space.
                    // If the condition is true: 0x20, otherwise: 0x00.
                    let scratch := shl(5, gt(a, b))
                    // Hash the scratch space and push the result onto the queue.
                    mstore(scratch, a)
                    mstore(xor(scratch, 0x20), b)
                    mstore(hashesBack, keccak256(0x00, 0x40))
                    hashesBack := add(hashesBack, 0x20)
                    if iszero(lt(hashesBack, flagsLength)) { break }
                }
                isValid :=
                    and(
                        // Checks if the last value in the queue is same as the root.
                        eq(mload(sub(hashesBack, 0x20)), root),
                        // And whether all the proofs are used, if required.
                        eq(proofEnd, proof)
                    )
                break
            }
        }
    }

    /// @dev Returns whether all `leaves` exist in the Merkle tree with `root`,
    /// given `proof` and `flags`.
    ///
    /// Note:
    /// - Breaking the invariant `flags.length == (leaves.length - 1) + proof.length`
    ///   will always return false.
    /// - Any non-zero word in the `flags` array is treated as true.
    /// - The calldata offset of `proof` must be non-zero
    ///   (i.e. `proof` is from a regular Solidity function with a 4-byte selector).
    function verifyMultiProofCalldata(
        bytes32[] calldata proof,
        bytes32 root,
        bytes32[] calldata leaves,
        bool[] calldata flags
    ) internal pure returns (bool isValid) {
        // Rebuilds the root by consuming and producing values on a queue.
        // The queue starts with the `leaves` array, and goes into a `hashes` array.
        // After the process, the last element on the queue is verified
        // to be equal to the `root`.
        //
        // The `flags` array denotes whether the sibling
        // should be popped from the queue (`flag == true`), or
        // should be popped from the `proof` (`flag == false`).
        /// @solidity memory-safe-assembly
        assembly {
            // If the number of flags is correct.
            for {} eq(add(leaves.length, proof.length), add(flags.length, 1)) {} {
                // For the case where `proof.length + leaves.length == 1`.
                if iszero(flags.length) {
                    // `isValid = (proof.length == 1 ? proof[0] : leaves[0]) == root`.
                    // forgefmt: disable-next-item
                    isValid := eq(
                        calldataload(
                            xor(leaves.offset, mul(xor(proof.offset, leaves.offset), proof.length))
                        ),
                        root
                    )
                    break
                }

                // The required final proof offset if `flagsLength` is not zero, otherwise zero.
                let proofEnd := add(proof.offset, shl(5, proof.length))
                // We can use the free memory space for the queue.
                // We don't need to allocate, since the queue is temporary.
                let hashesFront := mload(0x40)
                // Copy the leaves into the hashes.
                // Sometimes, a little memory expansion costs less than branching.
                // Should cost less, even with a high free memory offset of 0x7d00.
                calldatacopy(hashesFront, leaves.offset, shl(5, leaves.length))
                // Compute the back of the hashes.
                let hashesBack := add(hashesFront, shl(5, leaves.length))
                // This is the end of the memory for the queue.
                // We recycle `flagsLength` to save on stack variables (sometimes save gas).
                flags.length := add(hashesBack, shl(5, flags.length))

                // We don't need to make a copy of `proof.offset` or `flags.offset`,
                // as they are pass-by-value (this trick may not always save gas).

                for {} 1 {} {
                    // Pop from `hashes`.
                    let a := mload(hashesFront)
                    // Pop from `hashes`.
                    let b := mload(add(hashesFront, 0x20))
                    hashesFront := add(hashesFront, 0x40)

                    // If the flag is false, load the next proof,
                    // else, pops from the queue.
                    if iszero(calldataload(flags.offset)) {
                        // Loads the next proof.
                        b := calldataload(proof.offset)
                        proof.offset := add(proof.offset, 0x20)
                        // Unpop from `hashes`.
                        hashesFront := sub(hashesFront, 0x20)
                    }

                    // Advance to the next flag offset.
                    flags.offset := add(flags.offset, 0x20)

                    // Slot of `a` in scratch space.
                    // If the condition is true: 0x20, otherwise: 0x00.
                    let scratch := shl(5, gt(a, b))
                    // Hash the scratch space and push the result onto the queue.
                    mstore(scratch, a)
                    mstore(xor(scratch, 0x20), b)
                    mstore(hashesBack, keccak256(0x00, 0x40))
                    hashesBack := add(hashesBack, 0x20)
                    if iszero(lt(hashesBack, flags.length)) { break }
                }
                isValid :=
                    and(
                        // Checks if the last value in the queue is same as the root.
                        eq(mload(sub(hashesBack, 0x20)), root),
                        // And whether all the proofs are used, if required.
                        eq(proofEnd, proof.offset)
                    )
                break
            }
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                   EMPTY CALLDATA HELPERS                   */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns an empty calldata bytes32 array.
    function emptyProof() internal pure returns (bytes32[] calldata proof) {
        /// @solidity memory-safe-assembly
        assembly {
            proof.length := 0
        }
    }

    /// @dev Returns an empty calldata bytes32 array.
    function emptyLeaves() internal pure returns (bytes32[] calldata leaves) {
        /// @solidity memory-safe-assembly
        assembly {
            leaves.length := 0
        }
    }

    /// @dev Returns an empty calldata bool array.
    function emptyFlags() internal pure returns (bool[] calldata flags) {
        /// @solidity memory-safe-assembly
        assembly {
            flags.length := 0
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Safe ETH and ERC20 transfer library that gracefully handles missing return values.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/SafeTransferLib.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/SafeTransferLib.sol)
/// @author Permit2 operations from (https://github.com/Uniswap/permit2/blob/main/src/libraries/Permit2Lib.sol)
///
/// @dev Note:
/// - For ETH transfers, please use `forceSafeTransferETH` for DoS protection.
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

    /// @dev The ERC20 `totalSupply` query has failed.
    error TotalSupplyQueryFailed();

    /// @dev The Permit2 operation has failed.
    error Permit2Failed();

    /// @dev The Permit2 amount must be less than `2**160 - 1`.
    error Permit2AmountOverflow();

    /// @dev The Permit2 approve operation has failed.
    error Permit2ApproveFailed();

    /// @dev The Permit2 lockdown operation has failed.
    error Permit2LockdownFailed();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         CONSTANTS                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Suggested gas stipend for contract receiving ETH that disallows any storage writes.
    uint256 internal constant GAS_STIPEND_NO_STORAGE_WRITES = 2300;

    /// @dev Suggested gas stipend for contract receiving ETH to perform a few
    /// storage reads and writes, but low enough to prevent griefing.
    uint256 internal constant GAS_STIPEND_NO_GRIEF = 100000;

    /// @dev The unique EIP-712 domain domain separator for the DAI token contract.
    bytes32 internal constant DAI_DOMAIN_SEPARATOR =
        0xdbb8cf42e1ecb028be3f3dbc922e1d878b963f411dc388ced501601c60f7c6f7;

    /// @dev The address for the WETH9 contract on Ethereum mainnet.
    address internal constant WETH9 = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    /// @dev The canonical Permit2 address.
    /// [Github](https://github.com/Uniswap/permit2)
    /// [Etherscan](https://etherscan.io/address/0x000000000022D473030F116dDEE9F6B43aC78BA3)
    address internal constant PERMIT2 = 0x000000000022D473030F116dDEE9F6B43aC78BA3;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       ETH OPERATIONS                       */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // If the ETH transfer MUST succeed with a reasonable gas budget, use the force variants.
    //
    // The regular variants:
    // - Forwards all remaining gas to the target.
    // - Reverts if the target reverts.
    // - Reverts if the current contract has insufficient balance.
    //
    // The force variants:
    // - Forwards with an optional gas stipend
    //   (defaults to `GAS_STIPEND_NO_GRIEF`, which is sufficient for most cases).
    // - If the target reverts, or if the gas stipend is exhausted,
    //   creates a temporary contract to force send the ETH via `SELFDESTRUCT`.
    //   Future compatible with `SENDALL`: https://eips.ethereum.org/EIPS/eip-4758.
    // - Reverts if the current contract has insufficient balance.
    //
    // The try variants:
    // - Forwards with a mandatory gas stipend.
    // - Instead of reverting, returns whether the transfer succeeded.

    /// @dev Sends `amount` (in wei) ETH to `to`.
    function safeTransferETH(address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            if iszero(call(gas(), to, amount, codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, 0xb12d13eb) // `ETHTransferFailed()`.
                revert(0x1c, 0x04)
            }
        }
    }

    /// @dev Sends all the ETH in the current contract to `to`.
    function safeTransferAllETH(address to) internal {
        /// @solidity memory-safe-assembly
        assembly {
            // Transfer all the ETH and check if it succeeded or not.
            if iszero(call(gas(), to, selfbalance(), codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, 0xb12d13eb) // `ETHTransferFailed()`.
                revert(0x1c, 0x04)
            }
        }
    }

    /// @dev Force sends `amount` (in wei) ETH to `to`, with a `gasStipend`.
    function forceSafeTransferETH(address to, uint256 amount, uint256 gasStipend) internal {
        /// @solidity memory-safe-assembly
        assembly {
            if lt(selfbalance(), amount) {
                mstore(0x00, 0xb12d13eb) // `ETHTransferFailed()`.
                revert(0x1c, 0x04)
            }
            if iszero(call(gasStipend, to, amount, codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, to) // Store the address in scratch space.
                mstore8(0x0b, 0x73) // Opcode `PUSH20`.
                mstore8(0x20, 0xff) // Opcode `SELFDESTRUCT`.
                if iszero(create(amount, 0x0b, 0x16)) { revert(codesize(), codesize()) } // For gas estimation.
            }
        }
    }

    /// @dev Force sends all the ETH in the current contract to `to`, with a `gasStipend`.
    function forceSafeTransferAllETH(address to, uint256 gasStipend) internal {
        /// @solidity memory-safe-assembly
        assembly {
            if iszero(call(gasStipend, to, selfbalance(), codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, to) // Store the address in scratch space.
                mstore8(0x0b, 0x73) // Opcode `PUSH20`.
                mstore8(0x20, 0xff) // Opcode `SELFDESTRUCT`.
                if iszero(create(selfbalance(), 0x0b, 0x16)) { revert(codesize(), codesize()) } // For gas estimation.
            }
        }
    }

    /// @dev Force sends `amount` (in wei) ETH to `to`, with `GAS_STIPEND_NO_GRIEF`.
    function forceSafeTransferETH(address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            if lt(selfbalance(), amount) {
                mstore(0x00, 0xb12d13eb) // `ETHTransferFailed()`.
                revert(0x1c, 0x04)
            }
            if iszero(call(GAS_STIPEND_NO_GRIEF, to, amount, codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, to) // Store the address in scratch space.
                mstore8(0x0b, 0x73) // Opcode `PUSH20`.
                mstore8(0x20, 0xff) // Opcode `SELFDESTRUCT`.
                if iszero(create(amount, 0x0b, 0x16)) { revert(codesize(), codesize()) } // For gas estimation.
            }
        }
    }

    /// @dev Force sends all the ETH in the current contract to `to`, with `GAS_STIPEND_NO_GRIEF`.
    function forceSafeTransferAllETH(address to) internal {
        /// @solidity memory-safe-assembly
        assembly {
            // forgefmt: disable-next-item
            if iszero(call(GAS_STIPEND_NO_GRIEF, to, selfbalance(), codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, to) // Store the address in scratch space.
                mstore8(0x0b, 0x73) // Opcode `PUSH20`.
                mstore8(0x20, 0xff) // Opcode `SELFDESTRUCT`.
                if iszero(create(selfbalance(), 0x0b, 0x16)) { revert(codesize(), codesize()) } // For gas estimation.
            }
        }
    }

    /// @dev Sends `amount` (in wei) ETH to `to`, with a `gasStipend`.
    function trySafeTransferETH(address to, uint256 amount, uint256 gasStipend)
        internal
        returns (bool success)
    {
        /// @solidity memory-safe-assembly
        assembly {
            success := call(gasStipend, to, amount, codesize(), 0x00, codesize(), 0x00)
        }
    }

    /// @dev Sends all the ETH in the current contract to `to`, with a `gasStipend`.
    function trySafeTransferAllETH(address to, uint256 gasStipend)
        internal
        returns (bool success)
    {
        /// @solidity memory-safe-assembly
        assembly {
            success := call(gasStipend, to, selfbalance(), codesize(), 0x00, codesize(), 0x00)
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
            mstore(0x0c, 0x23b872dd000000000000000000000000) // `transferFrom(address,address,uint256)`.
            let success := call(gas(), token, 0, 0x1c, 0x64, 0x00, 0x20)
            if iszero(and(eq(mload(0x00), 1), success)) {
                if iszero(lt(or(iszero(extcodesize(token)), returndatasize()), success)) {
                    mstore(0x00, 0x7939f424) // `TransferFromFailed()`.
                    revert(0x1c, 0x04)
                }
            }
            mstore(0x60, 0) // Restore the zero slot to zero.
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Sends `amount` of ERC20 `token` from `from` to `to`.
    ///
    /// The `from` account must have at least `amount` approved for the current contract to manage.
    function trySafeTransferFrom(address token, address from, address to, uint256 amount)
        internal
        returns (bool success)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x60, amount) // Store the `amount` argument.
            mstore(0x40, to) // Store the `to` argument.
            mstore(0x2c, shl(96, from)) // Store the `from` argument.
            mstore(0x0c, 0x23b872dd000000000000000000000000) // `transferFrom(address,address,uint256)`.
            success := call(gas(), token, 0, 0x1c, 0x64, 0x00, 0x20)
            if iszero(and(eq(mload(0x00), 1), success)) {
                success := lt(or(iszero(extcodesize(token)), returndatasize()), success)
            }
            mstore(0x60, 0) // Restore the zero slot to zero.
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Sends all of ERC20 `token` from `from` to `to`.
    /// Reverts upon failure.
    ///
    /// The `from` account must have their entire balance approved for the current contract to manage.
    function safeTransferAllFrom(address token, address from, address to)
        internal
        returns (uint256 amount)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x40, to) // Store the `to` argument.
            mstore(0x2c, shl(96, from)) // Store the `from` argument.
            mstore(0x0c, 0x70a08231000000000000000000000000) // `balanceOf(address)`.
            // Read the balance, reverting upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    gt(returndatasize(), 0x1f), // At least 32 bytes returned.
                    staticcall(gas(), token, 0x1c, 0x24, 0x60, 0x20)
                )
            ) {
                mstore(0x00, 0x7939f424) // `TransferFromFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x00, 0x23b872dd) // `transferFrom(address,address,uint256)`.
            amount := mload(0x60) // The `amount` is already at 0x60. We'll need to return it.
            // Perform the transfer, reverting upon failure.
            let success := call(gas(), token, 0, 0x1c, 0x64, 0x00, 0x20)
            if iszero(and(eq(mload(0x00), 1), success)) {
                if iszero(lt(or(iszero(extcodesize(token)), returndatasize()), success)) {
                    mstore(0x00, 0x7939f424) // `TransferFromFailed()`.
                    revert(0x1c, 0x04)
                }
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
            mstore(0x00, 0xa9059cbb000000000000000000000000) // `transfer(address,uint256)`.
            // Perform the transfer, reverting upon failure.
            let success := call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
            if iszero(and(eq(mload(0x00), 1), success)) {
                if iszero(lt(or(iszero(extcodesize(token)), returndatasize()), success)) {
                    mstore(0x00, 0x90b8ec18) // `TransferFailed()`.
                    revert(0x1c, 0x04)
                }
            }
            mstore(0x34, 0) // Restore the part of the free memory pointer that was overwritten.
        }
    }

    /// @dev Sends all of ERC20 `token` from the current contract to `to`.
    /// Reverts upon failure.
    function safeTransferAll(address token, address to) internal returns (uint256 amount) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, 0x70a08231) // Store the function selector of `balanceOf(address)`.
            mstore(0x20, address()) // Store the address of the current contract.
            // Read the balance, reverting upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    gt(returndatasize(), 0x1f), // At least 32 bytes returned.
                    staticcall(gas(), token, 0x1c, 0x24, 0x34, 0x20)
                )
            ) {
                mstore(0x00, 0x90b8ec18) // `TransferFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x14, to) // Store the `to` argument.
            amount := mload(0x34) // The `amount` is already at 0x34. We'll need to return it.
            mstore(0x00, 0xa9059cbb000000000000000000000000) // `transfer(address,uint256)`.
            // Perform the transfer, reverting upon failure.
            let success := call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
            if iszero(and(eq(mload(0x00), 1), success)) {
                if iszero(lt(or(iszero(extcodesize(token)), returndatasize()), success)) {
                    mstore(0x00, 0x90b8ec18) // `TransferFailed()`.
                    revert(0x1c, 0x04)
                }
            }
            mstore(0x34, 0) // Restore the part of the free memory pointer that was overwritten.
        }
    }

    /// @dev Sets `amount` of ERC20 `token` for `to` to manage on behalf of the current contract.
    /// Reverts upon failure.
    function safeApprove(address token, address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x14, to) // Store the `to` argument.
            mstore(0x34, amount) // Store the `amount` argument.
            mstore(0x00, 0x095ea7b3000000000000000000000000) // `approve(address,uint256)`.
            let success := call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
            if iszero(and(eq(mload(0x00), 1), success)) {
                if iszero(lt(or(iszero(extcodesize(token)), returndatasize()), success)) {
                    mstore(0x00, 0x3e3f8f73) // `ApproveFailed()`.
                    revert(0x1c, 0x04)
                }
            }
            mstore(0x34, 0) // Restore the part of the free memory pointer that was overwritten.
        }
    }

    /// @dev Sets `amount` of ERC20 `token` for `to` to manage on behalf of the current contract.
    /// If the initial attempt to approve fails, attempts to reset the approved amount to zero,
    /// then retries the approval again (some tokens, e.g. USDT, requires this).
    /// Reverts upon failure.
    function safeApproveWithRetry(address token, address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x14, to) // Store the `to` argument.
            mstore(0x34, amount) // Store the `amount` argument.
            mstore(0x00, 0x095ea7b3000000000000000000000000) // `approve(address,uint256)`.
            // Perform the approval, retrying upon failure.
            let success := call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
            if iszero(and(eq(mload(0x00), 1), success)) {
                if iszero(lt(or(iszero(extcodesize(token)), returndatasize()), success)) {
                    mstore(0x34, 0) // Store 0 for the `amount`.
                    mstore(0x00, 0x095ea7b3000000000000000000000000) // `approve(address,uint256)`.
                    pop(call(gas(), token, 0, 0x10, 0x44, codesize(), 0x00)) // Reset the approval.
                    mstore(0x34, amount) // Store back the original `amount`.
                    // Retry the approval, reverting upon failure.
                    success := call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                    if iszero(and(eq(mload(0x00), 1), success)) {
                        // Check the `extcodesize` again just in case the token selfdestructs lol.
                        if iszero(lt(or(iszero(extcodesize(token)), returndatasize()), success)) {
                            mstore(0x00, 0x3e3f8f73) // `ApproveFailed()`.
                            revert(0x1c, 0x04)
                        }
                    }
                }
            }
            mstore(0x34, 0) // Restore the part of the free memory pointer that was overwritten.
        }
    }

    /// @dev Returns the amount of ERC20 `token` owned by `account`.
    /// Returns zero if the `token` does not exist.
    function balanceOf(address token, address account) internal view returns (uint256 amount) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x14, account) // Store the `account` argument.
            mstore(0x00, 0x70a08231000000000000000000000000) // `balanceOf(address)`.
            amount :=
                mul( // The arguments of `mul` are evaluated from right to left.
                    mload(0x20),
                    and( // The arguments of `and` are evaluated from right to left.
                        gt(returndatasize(), 0x1f), // At least 32 bytes returned.
                        staticcall(gas(), token, 0x10, 0x24, 0x20, 0x20)
                    )
                )
        }
    }

    /// @dev Returns the total supply of the `token`.
    /// Reverts if the token does not exist or does not implement `totalSupply()`.
    function totalSupply(address token) internal view returns (uint256 result) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, 0x18160ddd) // `totalSupply()`.
            if iszero(
                and(gt(returndatasize(), 0x1f), staticcall(gas(), token, 0x1c, 0x04, 0x00, 0x20))
            ) {
                mstore(0x00, 0x54cd9435) // `TotalSupplyQueryFailed()`.
                revert(0x1c, 0x04)
            }
            result := mload(0x00)
        }
    }

    /// @dev Sends `amount` of ERC20 `token` from `from` to `to`.
    /// If the initial attempt fails, try to use Permit2 to transfer the token.
    /// Reverts upon failure.
    ///
    /// The `from` account must have at least `amount` approved for the current contract to manage.
    function safeTransferFrom2(address token, address from, address to, uint256 amount) internal {
        if (!trySafeTransferFrom(token, from, to, amount)) {
            permit2TransferFrom(token, from, to, amount);
        }
    }

    /// @dev Sends `amount` of ERC20 `token` from `from` to `to` via Permit2.
    /// Reverts upon failure.
    function permit2TransferFrom(address token, address from, address to, uint256 amount)
        internal
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40)
            mstore(add(m, 0x74), shr(96, shl(96, token)))
            mstore(add(m, 0x54), amount)
            mstore(add(m, 0x34), to)
            mstore(add(m, 0x20), shl(96, from))
            // `transferFrom(address,address,uint160,address)`.
            mstore(m, 0x36c78516000000000000000000000000)
            let p := PERMIT2
            let exists := eq(chainid(), 1)
            if iszero(exists) { exists := iszero(iszero(extcodesize(p))) }
            if iszero(
                and(
                    call(gas(), p, 0, add(m, 0x10), 0x84, codesize(), 0x00),
                    lt(iszero(extcodesize(token)), exists) // Token has code and Permit2 exists.
                )
            ) {
                mstore(0x00, 0x7939f4248757f0fd) // `TransferFromFailed()` or `Permit2AmountOverflow()`.
                revert(add(0x18, shl(2, iszero(iszero(shr(160, amount))))), 0x04)
            }
        }
    }

    /// @dev Permit a user to spend a given amount of
    /// another user's tokens via native EIP-2612 permit if possible, falling
    /// back to Permit2 if native permit fails or is not implemented on the token.
    function permit2(
        address token,
        address owner,
        address spender,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        bool success;
        /// @solidity memory-safe-assembly
        assembly {
            for {} shl(96, xor(token, WETH9)) {} {
                mstore(0x00, 0x3644e515) // `DOMAIN_SEPARATOR()`.
                if iszero(
                    and( // The arguments of `and` are evaluated from right to left.
                        lt(iszero(mload(0x00)), eq(returndatasize(), 0x20)), // Returns 1 non-zero word.
                        // Gas stipend to limit gas burn for tokens that don't refund gas when
                        // an non-existing function is called. 5K should be enough for a SLOAD.
                        staticcall(5000, token, 0x1c, 0x04, 0x00, 0x20)
                    )
                ) { break }
                // After here, we can be sure that token is a contract.
                let m := mload(0x40)
                mstore(add(m, 0x34), spender)
                mstore(add(m, 0x20), shl(96, owner))
                mstore(add(m, 0x74), deadline)
                if eq(mload(0x00), DAI_DOMAIN_SEPARATOR) {
                    mstore(0x14, owner)
                    mstore(0x00, 0x7ecebe00000000000000000000000000) // `nonces(address)`.
                    mstore(
                        add(m, 0x94),
                        lt(iszero(amount), staticcall(gas(), token, 0x10, 0x24, add(m, 0x54), 0x20))
                    )
                    mstore(m, 0x8fcbaf0c000000000000000000000000) // `IDAIPermit.permit`.
                    // `nonces` is already at `add(m, 0x54)`.
                    // `amount != 0` is already stored at `add(m, 0x94)`.
                    mstore(add(m, 0xb4), and(0xff, v))
                    mstore(add(m, 0xd4), r)
                    mstore(add(m, 0xf4), s)
                    success := call(gas(), token, 0, add(m, 0x10), 0x104, codesize(), 0x00)
                    break
                }
                mstore(m, 0xd505accf000000000000000000000000) // `IERC20Permit.permit`.
                mstore(add(m, 0x54), amount)
                mstore(add(m, 0x94), and(0xff, v))
                mstore(add(m, 0xb4), r)
                mstore(add(m, 0xd4), s)
                success := call(gas(), token, 0, add(m, 0x10), 0xe4, codesize(), 0x00)
                break
            }
        }
        if (!success) simplePermit2(token, owner, spender, amount, deadline, v, r, s);
    }

    /// @dev Simple permit on the Permit2 contract.
    function simplePermit2(
        address token,
        address owner,
        address spender,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40)
            mstore(m, 0x927da105) // `allowance(address,address,address)`.
            {
                let addressMask := shr(96, not(0))
                mstore(add(m, 0x20), and(addressMask, owner))
                mstore(add(m, 0x40), and(addressMask, token))
                mstore(add(m, 0x60), and(addressMask, spender))
                mstore(add(m, 0xc0), and(addressMask, spender))
            }
            let p := mul(PERMIT2, iszero(shr(160, amount)))
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    gt(returndatasize(), 0x5f), // Returns 3 words: `amount`, `expiration`, `nonce`.
                    staticcall(gas(), p, add(m, 0x1c), 0x64, add(m, 0x60), 0x60)
                )
            ) {
                mstore(0x00, 0x6b836e6b8757f0fd) // `Permit2Failed()` or `Permit2AmountOverflow()`.
                revert(add(0x18, shl(2, iszero(p))), 0x04)
            }
            mstore(m, 0x2b67b570) // `Permit2.permit` (PermitSingle variant).
            // `owner` is already `add(m, 0x20)`.
            // `token` is already at `add(m, 0x40)`.
            mstore(add(m, 0x60), amount)
            mstore(add(m, 0x80), 0xffffffffffff) // `expiration = type(uint48).max`.
            // `nonce` is already at `add(m, 0xa0)`.
            // `spender` is already at `add(m, 0xc0)`.
            mstore(add(m, 0xe0), deadline)
            mstore(add(m, 0x100), 0x100) // `signature` offset.
            mstore(add(m, 0x120), 0x41) // `signature` length.
            mstore(add(m, 0x140), r)
            mstore(add(m, 0x160), s)
            mstore(add(m, 0x180), shl(248, v))
            if iszero( // Revert if token does not have code, or if the call fails.
            mul(extcodesize(token), call(gas(), p, 0, add(m, 0x1c), 0x184, codesize(), 0x00))) {
                mstore(0x00, 0x6b836e6b) // `Permit2Failed()`.
                revert(0x1c, 0x04)
            }
        }
    }

    /// @dev Approves `spender` to spend `amount` of `token` for `address(this)`.
    function permit2Approve(address token, address spender, uint160 amount, uint48 expiration)
        internal
    {
        /// @solidity memory-safe-assembly
        assembly {
            let addressMask := shr(96, not(0))
            let m := mload(0x40)
            mstore(m, 0x87517c45) // `approve(address,address,uint160,uint48)`.
            mstore(add(m, 0x20), and(addressMask, token))
            mstore(add(m, 0x40), and(addressMask, spender))
            mstore(add(m, 0x60), and(addressMask, amount))
            mstore(add(m, 0x80), and(0xffffffffffff, expiration))
            if iszero(call(gas(), PERMIT2, 0, add(m, 0x1c), 0xa0, codesize(), 0x00)) {
                mstore(0x00, 0x324f14ae) // `Permit2ApproveFailed()`.
                revert(0x1c, 0x04)
            }
        }
    }

    /// @dev Revokes an approval for `token` and `spender` for `address(this)`.
    function permit2Lockdown(address token, address spender) internal {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40)
            mstore(m, 0xcc53287f) // `Permit2.lockdown`.
            mstore(add(m, 0x20), 0x20) // Offset of the `approvals`.
            mstore(add(m, 0x40), 1) // `approvals.length`.
            mstore(add(m, 0x60), shr(96, shl(96, token)))
            mstore(add(m, 0x80), shr(96, shl(96, spender)))
            if iszero(call(gas(), PERMIT2, 0, add(m, 0x1c), 0xa0, codesize(), 0x00)) {
                mstore(0x00, 0x96b3de23) // `Permit2LockdownFailed()`.
                revert(0x1c, 0x04)
            }
        }
    }
}