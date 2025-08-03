// SPDX-License-Identifier: UNLICENSED
/**                           
        /@#(@@@@@              
       @@      @@@             
        @@                      
        .@@@#                  
        ##@@@@@@,              
      @@@      /@@@&            
    .@@@  @   @  @@@@           
    @@@@  @@@@@  @@@@           
    @@@@  @   @  @@@/           
     @@@@       @@@             
       (@@@@#@@@      
    THE AORI PROTOCOL                           
 */
pragma solidity ^0.8.13;

import "./OpenZeppelin/ERC20.sol";
import "./OpenZeppelin/Ownable.sol";
import "./Chainlink/AggregatorV3Interface.sol";
import "./OpenZeppelin/IERC20.sol";
import "./OpenZeppelin/ReentrancyGuard.sol";
import "./AoriSeats.sol";
import "./OpenZeppelin/SafeERC20.sol";
import "./Margin/MarginManager.sol";

contract AoriCall is ERC20, ReentrancyGuard {
    address public immutable factory;
    address public immutable manager;
    address public oracle; //Must be USD Denominated Chainlink Oracle with 8 decimals
    uint256 public immutable strikeInUSDC;
    uint256 public immutable endingTime;
    uint256 public immutable duration; //duration in blocks
    IERC20 public immutable UNDERLYING;
    uint256 public immutable UNDERLYING_DECIMALS;
    IERC20 public immutable USDC;
    uint256 public immutable USDC_DECIMALS;
    uint256 public settlementPrice;
    uint256 public immutable feeMultiplier;
    uint256 public immutable decimalDiff;
    uint256 immutable tolerance = 2 hours;
    bool public hasEnded = false;
    AoriSeats public immutable AORISEATSADD;
    mapping (address => uint256) public optionSellers;
    uint256 public immutable BPS_DIVISOR = 10000;


    constructor(
        address _manager,
        uint256 _feeMultiplier,
        uint256 _strikeInUSDC,
        uint256 _duration, //in blocks
        IERC20 _UNDERLYING,
        IERC20 _USDC,
        address _oracle,
        AoriSeats _AORISEATSADD,
        string memory name_,
        string memory symbol_
    ) ERC20(name_, symbol_, 18) {
        factory = msg.sender;
        manager = _manager;
        feeMultiplier = _feeMultiplier;
        strikeInUSDC = _strikeInUSDC; 
        duration = _duration; //in seconds
        endingTime = block.timestamp + duration;
        UNDERLYING = _UNDERLYING;
        UNDERLYING_DECIMALS = UNDERLYING.decimals();
        USDC = _USDC;
        USDC_DECIMALS = USDC.decimals();
        decimalDiff = (10**UNDERLYING_DECIMALS) / (10**USDC_DECIMALS); //The underlying decimals must be greater than or equal to USDC's decimals.
        oracle = _oracle;
        AORISEATSADD = _AORISEATSADD;
    }

    event CallMinted(uint256 optionsMinted, address minter);
    event CallBuyerITMSettled(uint256 optionsRedeemed, address settler);
    event CallSellerITMSettled(uint256 optionsRedeemed, address settler);
    event CallSellerOTMSettled(uint256 optionsRedeemed, address settler);
    event SellerRetrievedFunds(uint256 tokensRetrieved, address seller);

    function setOracle(address newOracle) public returns(address) {
        require(msg.sender == AORISEATSADD.owner());
        oracle = newOracle;
        return oracle;
    }
    /**
        Mints a call option equivalent to the quantity of the underlying asset divided by
        the strike price as quoted in USDC. 
        Note that this does NOT sell the option for you.
        You must list the option in an OptionSwap orderbook to actually be paid for selling this option.
        The Receiver will receive the options ERC20's but the option seller will be stored as the msg.sender
     */
    function mintCall(uint256 quantityOfUNDERLYING, address receiver, uint256 seatId) public nonReentrant returns (uint256) {
        //confirming the user has enough of the UNDERLYING
        require(UNDERLYING_DECIMALS == UNDERLYING.decimals(), "Decimal disagreement");
        require(block.timestamp < endingTime, "This option has already matured"); //safety check
        require(UNDERLYING.balanceOf(msg.sender) >= quantityOfUNDERLYING, "Not enough of the underlying");
        require(AORISEATSADD.confirmExists(seatId) && AORISEATSADD.ownerOf(seatId) != address(0x0), "Seat does not exist");

        uint256 mintingFee;
        uint256 refRate;
        uint256 feeToSeat;
        uint256 optionsToMint;
        //Checks seat ownership, and assigns fees and transfers accordingly
        if (receiver == AORISEATSADD.ownerOf(seatId)) {
            //If the owner of the seat IS the caller, fees are 0
            mintingFee = 0;
            refRate = 0;
            feeToSeat = 0;
            optionsToMint = (quantityOfUNDERLYING * (10**6)) / strikeInUSDC;
            //transfer the UNDERLYING
            SafeERC20.safeTransferFrom(UNDERLYING, msg.sender, address(this), quantityOfUNDERLYING);
            _mint(receiver, optionsToMint);
        } else {
            //If the owner of the seat is not the caller, calculate and transfer the fees
            mintingFee = callUNDERLYINGFeeCalculator(quantityOfUNDERLYING, AORISEATSADD.getOptionMintingFee());
            // Calculating the fees to go to the seat owner
            refRate = (AORISEATSADD.getSeatScore(seatId) * 500) + 3500;
            feeToSeat = (refRate * mintingFee) / BPS_DIVISOR; 
            optionsToMint = ((quantityOfUNDERLYING - mintingFee) * (10**6)) / strikeInUSDC;

            //transfer the UNDERLYING and route fees
            SafeERC20.safeTransferFrom(UNDERLYING, msg.sender, address(this), quantityOfUNDERLYING - mintingFee);
            SafeERC20.safeTransferFrom(UNDERLYING, msg.sender, Ownable(factory).owner(), mintingFee - feeToSeat);
            SafeERC20.safeTransferFrom(UNDERLYING, msg.sender, AORISEATSADD.ownerOf(seatId), feeToSeat);
            //mint the user LP tokens
            _mint(receiver, optionsToMint);
        }

        //storing this option seller's information for future settlement
        uint256 currentOptionsSold = optionSellers[msg.sender];
        uint256 newOptionsSold = currentOptionsSold + optionsToMint;
        optionSellers[msg.sender] = newOptionsSold;

        emit CallMinted(optionsToMint, msg.sender);

        return (optionsToMint);
    }

    /**
        Sets the settlement price immediately upon the maturation
        of this option. Anyone can set the settlement into motion.
        Note the settlement price is converted to USDC Scale via getPrice();
     */
    function _setSettlementPrice() internal returns (uint256) {
        require(block.timestamp >= endingTime, "Option has not matured");
        if(hasEnded == false) {
            settlementPrice = uint256(getPrice());
            hasEnded = true;
        }
        return settlementPrice;
    }

    /**
        Gets the option minting fee from AoriSeats and
        Calculates the minting fee in BPS of the underlying token
     */
    function callUNDERLYINGFeeCalculator(uint256 optionsToSettle, uint256 fee) internal view returns (uint256) {
        require(UNDERLYING_DECIMALS == UNDERLYING.decimals());
        uint256 txFee = (optionsToSettle * fee) / BPS_DIVISOR;
        return txFee;
    }

    /**
        Takes the quantity of options the user wishes to settle then
        calculates the quantity of USDC the user must pay the contract
        Note this calculation only occurs for in the money options.
     */
    function scaleToUSDCAtStrike(uint256 optionsToSettle) internal view returns (uint256) {
        uint256 tokenDecimals = 10**UNDERLYING_DECIMALS;
        uint256 scaledVal = (optionsToSettle * strikeInUSDC) / tokenDecimals; //(1e18 * 1e6) / 1e18
        return scaledVal;
    }

    /**
        In the money settlement procedures for an option purchaser.
        The settlement price must exceed the strike price for this function to be callable
        Then the user must transfer USDC according to the following calculation: (USDC * strikeprice) * optionsToSettle;
        Then the user receives the underlying ERC20 at the strike price.
     */
    function buyerSettlementITM(uint256 optionsToSettle) public nonReentrant returns (uint256) {
        _setSettlementPrice();
        require(balanceOf(msg.sender) >= optionsToSettle, "You are attempting to settle more options than you have purhased");
        require(balanceOf(msg.sender) >= 0, "You have not purchased any options");
        require(settlementPrice > strikeInUSDC  && settlementPrice != 0, "Option did not expire ITM");
        require(optionsToSettle <= totalSupply() && optionsToSettle != 0);
        
        //Calculating the profit using a ratio of settlement price
        //minus the strikeInUSDC, then dividing by the settlement price.
        //This gives us the total number of underlying tokens to give the settler.
        uint256 profitPerOption = ((settlementPrice - strikeInUSDC) * 10**6) / settlementPrice; // (1e6 * 1e6) / 1e6
        uint256 UNDERLYINGOwed = (profitPerOption * optionsToSettle) / 10**6; //1e6 * 1e18 / 1e6 
        
        _burn(msg.sender, optionsToSettle);
        SafeERC20.safeTransfer(UNDERLYING, msg.sender, UNDERLYINGOwed); //sending 1e18 scale tokens to user
        emit CallBuyerITMSettled(optionsToSettle, msg.sender);

        return (optionsToSettle);
    }

    /**
        In the money settlement procedures for an option seller.
        The option seller receives USDC equivalent to the strike price * the number of options they sold.
     */
    function sellerSettlementITM() public nonReentrant returns (uint256) {
        _setSettlementPrice();
        uint256 optionsToSettle = optionSellers[msg.sender];
        require(optionsToSettle > 0);
        require(settlementPrice > strikeInUSDC && hasEnded == true, "Option did not settle ITM");

        uint256 UNDERLYINGToReceive = ((strikeInUSDC * 10**6) / settlementPrice) * optionsToSettle; // (1e6*1e6/1e6) * 1e18
        //store the settlement
        optionSellers[msg.sender] = 0;
    
        //settle
        SafeERC20.safeTransfer(UNDERLYING, msg.sender, UNDERLYINGToReceive / 10**6);
        emit CallSellerITMSettled(optionsToSettle, msg.sender);

        return optionsToSettle;
    }   

    /**
        Settlement procedures for an option sold that expired out of the money.
        The seller receives all of their underlying assets back while retaining the premium from selling.
     */
    function sellerSettlementOTM() public nonReentrant returns (uint256) {
        _setSettlementPrice();
        require(optionSellers[msg.sender] > 0 && settlementPrice <= strikeInUSDC, "Option did not settle OTM or you did not sell any");
        uint256 optionsSold = optionSellers[msg.sender];

        //store the settlement
        optionSellers[msg.sender] = 0;

        //settle
        SafeERC20.safeTransfer(UNDERLYING, msg.sender, optionsSold);

        emit CallSellerOTMSettled(optionsSold, msg.sender);

        return optionsSold;
    }

    /**
        Early settlement exclusively for liquidations via the margin manager
     */
    function liquidationSettlement(uint256 optionsToSettle) public nonReentrant returns (uint256) {
        require(msg.sender == MarginManager(manager).vaultAdd(ERC20(address(UNDERLYING))));

        _burn(msg.sender, optionsToSettle);
        optionSellers[manager] -= optionsToSettle;
        uint256 UNDERLYINGToReceive = (optionsToSettle * strikeInUSDC) / 10**UNDERLYING_DECIMALS;
        UNDERLYING.transferFrom(address(this), manager, UNDERLYINGToReceive);
        return UNDERLYINGToReceive;
    }

    /**
     *  VIEW FUNCTIONS
    */

    /** 
        Get the price converted from Chainlink format to USDC
    */
    function getPrice() public view returns (uint256) {
        (, int256 price,  ,uint256 updatedAt,  ) = AggregatorV3Interface(oracle).latestRoundData();
        require(price >= 0, "Negative Prices are not allowed");
        require(block.timestamp <= updatedAt + tolerance, "Price is too stale to be trustworthy"); // also works if updatedAt is 0
        if (price == 0) {
            return strikeInUSDC;
        } else {
            //8 is the decimals() of chainlink oracles
            return (uint256(price) / (10**(8 - USDC_DECIMALS)));
        }
    }
    /** 
        For frontend ease. If a uint then the option is ITM, if 0 then it is OTM. 
    */
    function getITM() public view returns (uint256) {
        if (getPrice() >= strikeInUSDC) {
            return getPrice() - strikeInUSDC;
        } else {
            return 0;
        }
    }

    function getOptionsSold(address seller_) public view returns (uint256) {
        return optionSellers[seller_];
    }
}
// SPDX-License-Identifier: UNLICENSED
/**                           
        /@#(@@@@@              
       @@      @@@             
        @@                      
        .@@@#                  
        ##@@@@@@,              
      @@@      /@@@&            
    .@@@  @   @  @@@@           
    @@@@  @@@@@  @@@@           
    @@@@  @   @  @@@/           
     @@@@       @@@             
       (@@@@#@@@      
    THE AORI PROTOCOL                           
 */
pragma solidity ^0.8.13;

import "./OpenZeppelin/ERC20.sol";
import "./OpenZeppelin/Ownable.sol";
import "./Chainlink/AggregatorV3Interface.sol";
import "./OpenZeppelin/IERC20.sol";
import "./OpenZeppelin/ReentrancyGuard.sol";
import "./AoriSeats.sol";
import "./Margin/MarginManager.sol";


contract AoriPut is ERC20, ReentrancyGuard {
    address public immutable factory;
    address public immutable manager;
    address public oracle; //Must be USD Denominated Chainlink Oracle with 8 decimals
    uint256 public immutable strikeInUSDC; //This is in 1e6 scale
    uint256 public immutable endingTime;
    uint256 public immutable duration; //duration in blocks
    uint256 public settlementPrice; //price to be set at expiration
    uint256 public immutable feeMultiplier;
    uint256 public immutable decimalDiff;
    uint256 immutable tolerance = 2 hours;
    bool public hasEnded = false;
    IERC20 public immutable USDC;
    IERC20 public immutable UNDERLYING;
    uint256 public immutable USDC_DECIMALS;
    AoriSeats public immutable AORISEATSADD;
    uint256 public immutable BPS_DIVISOR = 10000;

    mapping (address => uint256) optionSellers; 
    

    constructor(
        address _manager,
        uint256 _feeMultiplier,
        uint256 _strikeInUSDC,
        uint256 _duration, //in blocks
        IERC20 _USDC,
        IERC20 _UNDERLYING,
        address _oracle,
        AoriSeats _AORISEATSADD,
        string memory name_,
        string memory symbol_
    ) ERC20(name_, symbol_, 18) {
        factory = msg.sender;
        manager = _manager;
        feeMultiplier = _feeMultiplier;
        strikeInUSDC = _strikeInUSDC; 
        duration = _duration; //in blocks
        USDC = _USDC;
        UNDERLYING = _UNDERLYING;
        USDC_DECIMALS = USDC.decimals();
        endingTime = block.timestamp + duration;
        oracle = _oracle;
        AORISEATSADD = _AORISEATSADD;
        decimalDiff = (10**decimals()) / (10**USDC_DECIMALS);
    }

    event PutMinted(uint256 optionsMinted, address minter);
    event PutBuyerITMSettled(uint256 optionsRedeemed, address settler);
    event PutSellerITMSettled(uint256 optionsRedeemed, address settler);
    event PutSellerOTMSettled(uint256 optionsRedeemed, address settler);
    event SellerRetrievedFunds(uint256 tokensRetrieved, address seller);


    function setOracle(address newOracle) public returns(address) {
        require(msg.sender == AORISEATSADD.owner());
        oracle = newOracle;
        return oracle;
    }

    /**
        Mints a Put option equivalent to the USDC being deposited divided by the strike price.
        Note that this does NOT sell the option for you.
        You must list the option in an OptionSwap orderbook to actually be paid for selling this option.
        The Receiver will receive the options ERC20's but the option seller will be stored as the msg.sender
     */
    function mintPut(uint256 quantityOfUSDC, address receiver, uint256 seatId) public nonReentrant returns (uint256) {
        //confirming the user has enough USDC
        require(block.timestamp < endingTime, "This option has already matured"); //safety check
        require(USDC.balanceOf(msg.sender) >= quantityOfUSDC, "Not enough USDC");
        require(AORISEATSADD.confirmExists(seatId) && AORISEATSADD.ownerOf(seatId) != address(0x0), "Seat does not exist");
        
        uint256 mintingFee;
        uint256 refRate;
        uint256 feeToSeat;
        uint256 optionsToMint;
        uint256 optionsToMintScaled;
        if (receiver == AORISEATSADD.ownerOf(seatId)) {
            //If the owner of the seat IS the caller, fees are 0
            mintingFee = 0;
            feeToSeat = 0;
            optionsToMint = (quantityOfUSDC * 1e6) / strikeInUSDC;
            optionsToMintScaled = optionsToMint * decimalDiff; //convert the USDC to 1e18 scale to mint LP tokens
            //transfer the USDC
            USDC.transferFrom(msg.sender, address(this), quantityOfUSDC);
            _mint(receiver, optionsToMintScaled);
        } else {
            //If the owner of the seat is not the caller, calculate and transfer the fees
            mintingFee = putUSDCFeeCalculator(quantityOfUSDC, AORISEATSADD.getOptionMintingFee());
            refRate = (AORISEATSADD.getSeatScore(seatId) * 500) + 3500;
            feeToSeat = (refRate * mintingFee) / BPS_DIVISOR; 
            optionsToMint = ((quantityOfUSDC - mintingFee) * 10**USDC_DECIMALS) / strikeInUSDC; //(1e6*1e6) / 1e6
            optionsToMintScaled = optionsToMint * decimalDiff;

            //transfer the USDC and route fees
            USDC.transferFrom(msg.sender, address(this), quantityOfUSDC - mintingFee);
            USDC.transferFrom(msg.sender, Ownable(factory).owner(), mintingFee - feeToSeat);
            USDC.transferFrom(msg.sender, AORISEATSADD.ownerOf(seatId), feeToSeat);
            //mint the user LP tokens
            _mint(receiver, optionsToMintScaled);
        }

        //storing this option seller's information for future settlement
        uint256 currentOptionsSold = optionSellers[msg.sender];
        uint256 newOptionsSold = currentOptionsSold + optionsToMintScaled;
        optionSellers[msg.sender] = newOptionsSold;

        emit PutMinted(optionsToMintScaled, msg.sender);

        return (optionsToMintScaled);
    }

    /**
        Sets the settlement price immediately upon the maturation
        of this option. Anyone can set the settlement into motion.
        Note the settlement price is converted to USDC Scale via getPrice();
     */
    function _setSettlementPrice() internal returns (uint256) {
        require(block.timestamp >= endingTime, "Option has not matured");
        if(hasEnded == false) {
            settlementPrice = uint256(getPrice());
            hasEnded = true;
        }
        return settlementPrice;
    }

    /**
        Essentially a MulDiv functio but for calculating BPS conversions
     */
    function putUSDCFeeCalculator(uint256 quantityOfUSDC, uint256 fee) internal pure returns (uint256) {
        uint256 txFee = (quantityOfUSDC * fee) / BPS_DIVISOR;
        return txFee;
    }
     /**
     * IN THE MONEY SETTLEMENT PROCEDURES
     * FOR IN THE MONEY OPTIONS SETTLEMENT
     * 
     */

    //Buyer Settlement ITM
    function buyerSettlementITM(uint256 optionsToSettle) public nonReentrant returns (uint256) {
        _setSettlementPrice();
        require(balanceOf(msg.sender) >= 0, "You have not purchased any options");
        require(balanceOf(msg.sender) >= optionsToSettle, "You are attempting to settle more options than you have purhased");
        require(strikeInUSDC > settlementPrice && settlementPrice != 0, "Option did not expire ITM");
        require(optionsToSettle <= totalSupply() && optionsToSettle != 0);

        uint256 profitPerOption = strikeInUSDC - settlementPrice;
        //Normalize the optionsToSettle to USDC scale then multiply by profit per option to get USDC Owed to the settler.
        uint256 USDCOwed = ((optionsToSettle / decimalDiff) * profitPerOption) / 10**USDC_DECIMALS; //((1e18 / 1e12) * 1e6) / 1e6
        //transfers
        _burn(msg.sender, optionsToSettle);
        USDC.transfer(msg.sender, USDCOwed);

        emit PutBuyerITMSettled(optionsToSettle, msg.sender);
        return (optionsToSettle);
    }


    /**
        Settlement procedures for an option sold that expired in of the money.
        The seller receives a portion of their underlying assets back relative to the
        strike price and settlement price. 
     */

    function sellerSettlementITM() public nonReentrant returns (uint256) {
        _setSettlementPrice();
        uint256 optionsToSettle = optionSellers[msg.sender];
        require(optionsToSettle >= 0);
        require(strikeInUSDC > settlementPrice && hasEnded == true, "Option did not expire OTM");

        //Calculating the USDC to receive ()
        uint256 USDCToReceive = ((optionsToSettle * settlementPrice) / decimalDiff) / 10**USDC_DECIMALS; //((1e18 / 1e12) * 1e6) / 1e6
        //store the settlement
        optionSellers[msg.sender] = 0;
    
        //settle
        USDC.transfer(msg.sender, USDCToReceive);
        
        emit PutSellerITMSettled(optionsToSettle, msg.sender);

        return optionsToSettle;
    }   

    /**
        Settlement procedures for an option sold that expired out of the money.
        The seller receives all of their underlying assets back while retaining the premium from selling.
     */
    function sellerSettlementOTM() public nonReentrant returns (uint256) {
        _setSettlementPrice();
        require(optionSellers[msg.sender] > 0 && settlementPrice >= strikeInUSDC, "Option did not expire OTM");
        uint256 optionsSold = optionSellers[msg.sender];

        //store the settlement
        optionSellers[msg.sender] = 0;

        //settle
        uint256 USDCOwed = ((optionsSold / decimalDiff) * strikeInUSDC) / 10**USDC_DECIMALS; //((1e18 / 1e12) * 1e6) / 1e6
        USDC.transfer(msg.sender, USDCOwed);

        emit PutSellerOTMSettled(optionsSold, msg.sender);

        return optionsSold;
    }

    /**
        Early settlement exclusively for liquidations via the margin manager
     */
    function liquidationSettlement(uint256 optionsToSettle) public nonReentrant returns (uint256) {
        require(msg.sender == MarginManager(manager).vaultAdd(ERC20(address(USDC))));
        
        _burn(msg.sender, optionsToSettle);
        optionSellers[manager] -= optionsToSettle;
        uint256 USDCToReceive = (optionsToSettle * strikeInUSDC) / 10**USDC_DECIMALS;
        USDC.transferFrom(address(this), manager, USDCToReceive);
        return USDCToReceive;
    }

    /**
     *  VIEW FUNCTIONS
    */

    /** 
        Get the price of the underlying converted from Chainlink format to USDC.
    */
    function getPrice() public view returns (uint256) {
        (, int256 price,  ,uint256 updatedAt,  ) = AggregatorV3Interface(oracle).latestRoundData();
        require(price >= 0, "Negative Prices are not allowed");
        require(block.timestamp <= updatedAt + tolerance, "Price is too stale to be trustworthy"); // also works if updatedAt is 0
        if (price == 0) {
            return strikeInUSDC;
        } else {
            //8 is the decimals() of chainlink oracles
            return (uint256(price) / (10**(8 - USDC_DECIMALS)));
        }
    }

    /** 
        For frontend ease. If a uint then the option is ITM, if 0 then it is OTM. 
    */
    function getITM() public view returns (uint256) {
        if (getPrice() <= strikeInUSDC) {
            return strikeInUSDC - getPrice();
        } else {
            return 0;
        }
    }
    
    function getOptionsSold(address seller_) public view returns (uint256) {
        return optionSellers[seller_];
    }
}
// SPDX-License-Identifier: UNLICENSED
/**                           
        /@#(@@@@@              
       @@      @@@             
        @@                      
        .@@@#                  
        ##@@@@@@,              
      @@@      /@@@&            
    .@@@  @   @  @@@@           
    @@@@  @@@@@  @@@@           
    @@@@  @   @  @@@/           
     @@@@       @@@             
       (@@@@#@@@      
    THE AORI PROTOCOL                           
 */
pragma solidity ^0.8.19;

import "./OpenZeppelin/ERC721Enumerable.sol";
import "./OpenZeppelin/IERC20.sol";
import "./OpenZeppelin/Ownable.sol";
import "./OpenZeppelin/ERC2981.sol";
import "./OpenZeppelin/ReentrancyGuardUpgradeable.sol";
import "./CallFactory.sol";
import "./PutFactory.sol";
import "./OrderbookFactory.sol";

/**
    Storage for all Seat NFT management and fee checking
 */
contract AoriSeats is ERC721Enumerable, ERC2981, Ownable, ReentrancyGuard {

     uint256 maxSeats;
     uint256 public currentSeatId;
     uint256 mintFee;
     uint256 tradingFee;
     uint256 public maxSeatScore;
     uint256 public feeMultiplier;
     CallFactory public CALLFACTORY;
     PutFactory public PUTFACTORY;
     address public minter;
     address public seatRoyaltyReceiver;
     uint256 public defaultSeatScore;
     OrderbookFactory public ORDERBOOKFACTORY;
     mapping(address => uint256) pointsTotal;
     mapping(uint256 => uint256) totalVolumeBySeat;

     constructor(
         string memory name_,
         string memory symbol_,
         uint256 maxSeats_,
         uint256 mintFee_,
         uint256 tradingFee_,
         uint256 maxSeatScore_,
         uint256 feeMultiplier_
     ) ERC721(name_, symbol_) {
         maxSeats = maxSeats_;
         mintFee = mintFee_;
         tradingFee = tradingFee_;
         maxSeatScore = maxSeatScore_;
         feeMultiplier = feeMultiplier_;

         _setDefaultRoyalty(owner(), 350);
         setSeatRoyaltyReceiver(owner());
         setDefaultSeatScore(5);
     }

    event FeeSetForSeat (uint256 seatId, address SeatOwner);
    event MaxSeatChange (uint256 NewMaxSeats);
    event MintFeeChange (uint256 NewMintFee);
    event TradingFeeChange (uint256 NewTradingFee);

    /** 
    Admin control functions
    */

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Enumerable, ERC2981) returns (bool) {
            return super.supportsInterface(interfaceId);
    }

    function setMinter(address _minter) public onlyOwner {
        minter = _minter;
    }
    
    function setSeatRoyaltyReceiver(address newSeatRoyaltyReceiver) public onlyOwner {
        seatRoyaltyReceiver = newSeatRoyaltyReceiver;
    }

    function setCallFactory(CallFactory newCALLFACTORY) public onlyOwner returns (CallFactory) {
        CALLFACTORY = newCALLFACTORY;
        return CALLFACTORY;
    }

    function setPutFactory(PutFactory newPUTFACTORY) public onlyOwner returns (PutFactory) {
        PUTFACTORY = newPUTFACTORY;
        return PUTFACTORY;
    }
    
    function setOrderbookFactory(OrderbookFactory newORDERBOOKFACTORY) public onlyOwner returns (OrderbookFactory) {
        ORDERBOOKFACTORY = newORDERBOOKFACTORY;
        return ORDERBOOKFACTORY;
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        _setBaseURI(baseURI);
    }

    function setDefaultSeatScore(uint256 score) public onlyOwner returns(uint256) {
        defaultSeatScore = score;
        return score;
    }

    function mintSeat() external returns (uint256) {
        require(msg.sender == minter);

        uint256 currentSeatIdLocal = currentSeatId;

        if (currentSeatId % 10 == 0) {
            seatScore[currentSeatIdLocal] = 1;
            _mint(seatRoyaltyReceiver, currentSeatIdLocal);
            currentSeatIdLocal++;
        }
        seatScore[currentSeatIdLocal] = defaultSeatScore;
        _mint(minter, currentSeatIdLocal);
        currentSeatId = currentSeatIdLocal + 1; //prepare seat id for future mint calls
        return currentSeatIdLocal; //return the id of the seat we just minted
    }

    /** 
        Combines two seats and adds their scores together
        Enabling the user to retain a higher portion of the fees collected from their seat
    */
    function combineSeats(uint256 seatIdOne, uint256 seatIdTwo) public returns(uint256) {
        require(msg.sender == ownerOf(seatIdOne) && msg.sender == ownerOf(seatIdTwo));
        uint256 newSeatScore = seatScore[seatIdOne] + seatScore[seatIdTwo];
        require(newSeatScore <= maxSeatScore);
        _burn(seatIdOne);
        _burn(seatIdTwo);
        uint256 newSeatId = currentSeatId++;
        _safeMint(msg.sender, newSeatId);
        seatScore[newSeatId] = newSeatScore;
        return seatScore[newSeatId];
    }

    /**
        Mints the user a series of one score seats
     */
    function separateSeats(uint256 seatId) public {
        require(msg.sender == ownerOf(seatId));
        uint256 currentSeatScore = seatScore[seatId];
        seatScore[seatId] = 1; //Reset the original seat
        _burn(seatId); //Burn the original seat
        //Mint the new seats
        for(uint i = 0; i < currentSeatScore; i++) {
            uint mintIndex = currentSeatId++;
            _safeMint(msg.sender, mintIndex);
            seatScore[mintIndex] = 1;
        }
    }

    /** 
        Volume = total notional trading volume through the seat
        For data tracking purposes.
    */
    function addTakerVolume(uint256 volumeToAdd, uint256 seatId, address Orderbook_) public nonReentrant {
        //confirms via Orderbook contract that the msg.sender is a call or put market created by the OPTIONTROLLER
        require(ORDERBOOKFACTORY.checkIsOrder(Orderbook_, msg.sender));
        
        uint256 currentVolume = totalVolumeBySeat[seatId];
        totalVolumeBySeat[seatId] = currentVolume + volumeToAdd;
    }


    /**
        Change the total number of seats
     */
    function setMaxSeats(uint256 newMaxSeats) public onlyOwner returns (uint256) {
        maxSeats = newMaxSeats;
        emit MaxSeatChange(newMaxSeats);
        return maxSeats;
    }
     /**
        Change the number of points for taking bids/asks and minting options
     */
    function setFeeMultiplier(uint256 newFeeMultiplier) public onlyOwner returns (uint256) {
        feeMultiplier = newFeeMultiplier;
        return feeMultiplier;
    }

    /**
        Change the maximum number of seats that can be combined
        Currently if this number exceeds 12 the Orderbook will break
     */
    function setMaxSeatScore(uint256 newMaxScore) public onlyOwner returns(uint256) {
        require(newMaxScore > maxSeatScore);
        maxSeatScore = newMaxScore;
        return maxSeatScore;
    }
    /** 
        Change the mintingfee in BPS
        For example a fee of 100 would be equivalent to a 1% fee (100 / 10_000)
    */
    function setMintFee(uint256 newMintFee) public onlyOwner returns (uint256) {
        mintFee = newMintFee;
        emit MintFeeChange(newMintFee);
        return mintFee;
    }
    /** 
        Change the mintingfee in BPS
        For example a fee of 100 would be equivalent to a 1% fee (100 / 10_000)
    */
    function setTradingFee(uint256 newTradingFee) public onlyOwner returns (uint256) {
        tradingFee = newTradingFee;
        emit TradingFeeChange(newTradingFee);
        return tradingFee;
    }
    /**
        Set an individual seat URI
     */
    function setSeatIdURI(uint256 seatId, string memory _seatURI) public {
        require(msg.sender == owner());
        _setTokenURI(seatId, _seatURI);
    }

    /**
    VIEW FUNCTIONS
     */
    function getOptionMintingFee() public view returns (uint256) {
        return mintFee;
    }
    function getTradingFee() public view returns (uint256) {
        return tradingFee;
    }

    function confirmExists(uint256 seatId) public view returns (bool) {
        return _exists(seatId);
    }

    function getPoints(address user) public view returns (uint256) {
        return pointsTotal[user];
    }

    function getSeatScore(uint256 seatId) public view returns (uint256) {
        return seatScore[seatId];
    }
    
    function getFeeMultiplier() public view returns (uint256) {
        return feeMultiplier;
    }

    function getSeatVolume(uint256 seatId) public view returns (uint256) {
        return totalVolumeBySeat[seatId];
    }
}
// SPDX-License-Identifier: UNLICENSED
/**                           
        /@#(@@@@@              
       @@      @@@             
        @@                      
        .@@@#                  
        ##@@@@@@,              
      @@@      /@@@&            
    .@@@  @   @  @@@@           
    @@@@  @@@@@  @@@@           
    @@@@  @   @  @@@/           
     @@@@       @@@             
       (@@@@#@@@      
    THE AORI PROTOCOL                           
 */
pragma solidity ^0.8.13;

import "./OpenZeppelin/IERC20.sol";
import "./AoriSeats.sol";
import "./OpenZeppelin/Ownable.sol";
import "./OpenZeppelin/ReentrancyGuard.sol";
import "./Chainlink/AggregatorV3Interface.sol";

contract Ask is ReentrancyGuard {
    address public immutable factory;
    address public immutable factoryOwner;
    address public immutable maker;
    uint256 public immutable USDCPerOPTION;
    uint256 public immutable OPTIONSize;
    uint256 public immutable fee; // in bps, default is 30 bps
    uint256 public immutable feeMultiplier;
    uint256 public immutable duration;
    uint256 public endingTime;
    AoriSeats public immutable AORISEATSADD;
    bool public hasEnded = false;
    bool public hasBeenFunded = false;
    IERC20 public OPTION;
    IERC20 public USDC; 
    uint256 public OPTIONDecimals = 18;
    uint256 public USDCDecimals = 6;
    uint256 public decimalDiff = (10**OPTIONDecimals) / (10**USDCDecimals);
    uint256 public immutable BPS_DIVISOR = 10000;
    uint256 public USDCFilled;

    event OfferFunded(address maker, uint256 OPTIONSize, uint256 duration);
    event Filled(address buyer, uint256 OPTIONAmount, uint256 AmountFilled, bool hasEnded);
    event OfferCanceled(address maker, uint256 OPTIONAmount);

    constructor(
        IERC20 _OPTION,
        IERC20 _USDC,
        AoriSeats _AORISEATSADD,
        address _maker,
        uint256 _USDCPerOPTION,
        uint256 _fee,
        uint256 _feeMultiplier,
        uint256 _duration, //in blocks
        uint256 _OPTIONSize
    ) {
        factory = msg.sender;
        factoryOwner = Ownable(factory).owner();
        OPTION = _OPTION;
        USDC = _USDC;
        AORISEATSADD = _AORISEATSADD;
        maker = _maker;
        USDCPerOPTION = _USDCPerOPTION;
        fee = _fee;
        feeMultiplier = _feeMultiplier;
        duration = _duration;
        OPTIONSize = _OPTIONSize;
    }
    
    // release trapped funds
    function withdrawTokens(address token) public {
        require(msg.sender == factoryOwner);
        if (token == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE) {
            payable(factoryOwner).transfer(address(this).balance);
        } else {
            uint256 balance = IERC20(token).balanceOf(address(this));
            safeTransfer(token, factoryOwner, balance);
        }
    }

    /**
        Fund the Ask with Aori option ERC20's
     */
    function fundContract() public nonReentrant {
        require(msg.sender == factory);
        hasBeenFunded = true;
        //officially begin the countdown
        endingTime = block.timestamp + duration;
        emit OfferFunded(maker, OPTIONSize, duration);
    }
    /**
        Partial or complete fill of the offer, with the requirement of trading through a seat
        regardless of whether the seat is owned or not.
        In the case of not owning the seat, a fee is charged in USDC.
     */
    function fill(uint256 amountOfUSDC, uint256 seatId) public nonReentrant {
        require(isFunded(), "no option balance");
        require(msg.sender != maker && msg.sender != factory, "Cannot take one's own order");
        require(!hasEnded, "offer has been previously been cancelled");
        require(block.timestamp <= endingTime, "This offer has expired");
        require(USDC.balanceOf(msg.sender) >= amountOfUSDC, "Not enough USDC");
        require(AORISEATSADD.confirmExists(seatId) && AORISEATSADD.ownerOf(seatId) != address(0x0), "Seat does not exist");
        uint256 USDCAfterFee;
        uint256 OPTIONToReceive;
        uint256 refRate;

        if(msg.sender == AORISEATSADD.ownerOf(seatId)) {
            //Seat holders receive 0 fees for trading
            USDCAfterFee = amountOfUSDC;
            OPTIONToReceive = mulDiv(USDCAfterFee, 10**OPTIONDecimals, USDCPerOPTION); //1eY = (1eX * 1eY) / 1eX
            //transfers To the msg.sender
            USDC.transferFrom(msg.sender, maker, USDCAfterFee);
            //transfer to the Msg.sender
            OPTION.transfer(msg.sender, OPTIONToReceive);
        } else {
            //What the user will receive out of 100 percent in referral fees with a floor of 40
            refRate = (AORISEATSADD.getSeatScore(seatId) * 500) + 3500;
            //This means for Aori seat governance they should not allow more than 12 seats to be combined at once
            uint256 seatScoreFeeInBPS = mulDiv(fee, refRate, BPS_DIVISOR);
            //calculating the fee breakdown 
            uint256 seatTxFee = mulDiv(amountOfUSDC, seatScoreFeeInBPS, BPS_DIVISOR);
            uint256 ownerTxFee = mulDiv(amountOfUSDC, fee - seatScoreFeeInBPS, BPS_DIVISOR);
            //Calcualting the base tokens to transfer after fees
            USDCAfterFee = (amountOfUSDC - (ownerTxFee + seatTxFee));
            //And the amount of the quote currency the msg.sender will receive
            OPTIONToReceive = mulDiv(USDCAfterFee, 10**OPTIONDecimals, USDCPerOPTION); //(1e6 * 1e18) / 1e6 = 1e18
            //Transfers from the msg.sender
            USDC.transferFrom(msg.sender, factoryOwner, ownerTxFee);
            USDC.transferFrom(msg.sender, AORISEATSADD.ownerOf(seatId), seatTxFee);
            USDC.transferFrom(msg.sender, maker, USDCAfterFee);
            //Transfers to the msg.sender
            OPTION.transfer(msg.sender, OPTIONToReceive);
            //Tracking the volume in the NFT
            AORISEATSADD.addTakerVolume(amountOfUSDC, seatId, factory);
        }
        //Storage
        USDCFilled += USDCAfterFee;
        if(OPTION.balanceOf(address(this)) == 0) {
            hasEnded = true;
        }
        emit Filled(msg.sender, USDCAfterFee, amountOfUSDC, hasEnded);
    }
    /**
        Cancel this order and refund all remaining tokens
    */
    function cancel() public nonReentrant {
        require(isFunded(), "no OPTION balance");
        require(msg.sender == maker);
        uint256 balance = OPTION.balanceOf(address(this));
        
        OPTION.transfer(msg.sender, balance);
        hasEnded = true;
        emit OfferCanceled(maker, balance);
    }
    
    //Check if the contract is funded still.
    function isFunded() public view returns (bool) {
        if (OPTION.balanceOf(address(this)) > 0 && hasBeenFunded) {
            return true;
        } else {
            return false;
        }
    }
    //View function to see if this offer still holds one USDC
    function isFundedOverOne() public view returns (bool) {
        if (OPTION.balanceOf(address(this)) > (10 ** OPTION.decimals())) {
            return true;
        } else {
            return false;
        }
    }

    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 z
    ) public pure returns (uint256) {
        return (x * y) / z;
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "safeTransfer: failed");
    }


    /**
        Additional view functions 
    */
    function getCurrentBalance() public view returns (uint256) {
        if (OPTION.balanceOf(address(this)) >= 1) {
            return OPTION.balanceOf(address(this));
        } else {
            return 0;
        }
    }
   function totalUSDCWanted() public view returns (uint256) {
        return (USDCPerOPTION * OPTIONSize) / 10**OPTIONDecimals;
    }
}
// SPDX-License-Identifier: UNLICENSED
/**                           
        /@#(@@@@@              
       @@      @@@             
        @@                      
        .@@@#                  
        ##@@@@@@,              
      @@@      /@@@&            
    .@@@  @   @  @@@@           
    @@@@  @@@@@  @@@@           
    @@@@  @   @  @@@/           
     @@@@       @@@             
       (@@@@#@@@      
    THE AORI PROTOCOL                           
 */
pragma solidity ^0.8.13;

import "./OpenZeppelin/IERC20.sol";
import "./AoriSeats.sol";
import "./OpenZeppelin/Ownable.sol";
import "./OpenZeppelin/ReentrancyGuard.sol";
import "./Chainlink/AggregatorV3Interface.sol";

contract Bid is ReentrancyGuard {
    address public immutable factory;
    address public immutable factoryOwner;
    address public immutable maker;
    uint256 public immutable OPTIONPerUSDC;
    uint256 public immutable USDCSize;
    uint256 public immutable fee; // in bps, default is 30 bps
    uint256 public immutable feeMultiplier;
    uint256 public immutable duration;
    uint256 public endingTime;
    AoriSeats public immutable AORISEATSADD;
    bool public hasEnded = false;
    bool public hasBeenFunded = false;
    IERC20 public USDC;
    IERC20 public OPTION;
    uint256 public USDCDecimals = 6;
    uint256 public OPTIONDecimals = 18;
    uint256 public decimalDiff = (10**OPTIONDecimals) / (10**USDCDecimals);
    uint256 public immutable BPS_DIVISOR = 10000;


    event OfferFunded(address maker, uint256 USDCSize, uint256 duration);
    event Filled(address buyer, uint256 USDCAmount, uint256 AmountFilled, bool hasEnded);
    event OfferCanceled(address maker, uint256 USDCAmount);

    constructor(
        IERC20 _USDC,
        IERC20 _OPTION,
        AoriSeats _AORISEATSADD,
        address _maker,
        uint256 _OPTIONPerUSDC,
        uint256 _fee,
        uint256 _feeMultiplier,
        uint256 _duration, //in blocks
        uint256 _USDCSize
    ) {
        factory = msg.sender;
        factoryOwner = Ownable(factory).owner();
        USDC = _USDC;
        OPTION = _OPTION;
        AORISEATSADD = _AORISEATSADD;
        maker = _maker;
        OPTIONPerUSDC = _OPTIONPerUSDC;
        fee = _fee;
        feeMultiplier = _feeMultiplier;
        duration = _duration;
        USDCSize = _USDCSize;
    }
    

    
    // release trapped funds
    function withdrawTokens(address token) public {
        require(msg.sender == factoryOwner);
        if (token == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE) {
            payable(factoryOwner).transfer(address(this).balance);
        } else {
            uint256 balance = IERC20(token).balanceOf(address(this));
            safeTransfer(token, factoryOwner, balance);
        }
    }
    
    /**
        Fund the Ask with Aori option ERC20's
     */
    function fundContract() public nonReentrant {
        require(msg.sender == factory);
        //officially begin the countdown
        endingTime = endingTime + duration;
        hasBeenFunded = true;
        emit OfferFunded(maker, USDCSize, duration);
    }
    /**
        Partial or complete fill of the offer, with the requirement of trading through a seat
        regardless of whether the seat is owned or not.
        In the case of not owning the seat, a fee is charged in USDC.
    */
    function fill(uint256 amountOfOPTION, uint256 seatId) public nonReentrant {
        require(isFunded(), "no usdc balance");
        require(msg.sender != maker && msg.sender != factory, "Cannot take one's own order");
        require(!hasEnded, "offer has been previously been cancelled");
        require(block.timestamp <= endingTime, "This offer has expired");
        require(OPTION.balanceOf(msg.sender) >= amountOfOPTION, "Not enough USDC");
        require(AORISEATSADD.confirmExists(seatId) && AORISEATSADD.ownerOf(seatId) != address(0x0), "Seat does not exist");

        uint256 OPTIONAfterFee;
        uint256 USDCToReceive;
        uint256 refRate;

        if(msg.sender == AORISEATSADD.ownerOf(seatId)) {
            //Seat holders receive 0 fees for trading
            OPTIONAfterFee = amountOfOPTION;
            USDCToReceive = mulDiv(OPTIONAfterFee, 10**USDCDecimals, OPTIONPerUSDC); //1eY = (1eX * 1eY) / 1eX
            //Transfers
            OPTION.transferFrom(msg.sender, maker, OPTIONAfterFee);
            USDC.transfer(msg.sender, USDCToReceive);
        } else {
            //Deducts the fee from the options the taker will receive
            OPTIONAfterFee = amountOfOPTION;            
            USDCToReceive = mulDiv(amountOfOPTION, 10**USDCDecimals, OPTIONPerUSDC); //1eY = (1eX * 1eY) / 1eX
            //What the user will receive out of 100 percent in referral fees with a floor of 40
            refRate = (AORISEATSADD.getSeatScore(seatId) * 500) + 3500;
            //This means for Aori seat governance they should not allow more than 12 seats to be combined at once
            uint256 seatScoreFeeInBPS = mulDiv(fee, refRate, BPS_DIVISOR); //(10 * 4000) / 10000 (min)
            uint256 seatTxFee = mulDiv(USDCToReceive, seatScoreFeeInBPS, BPS_DIVISOR); //(10**6 * 10**6 / 10**4)
            uint256 ownerTxFee = mulDiv(USDCToReceive, fee - seatScoreFeeInBPS, BPS_DIVISOR);
            //Transfers from the msg.sender
            OPTION.transferFrom(msg.sender, maker, OPTIONAfterFee);
            //Fee transfers are all in USDC, so for Bids they're routed here
            //These are to the Factory, the Aori seatholder, then the buyer respectively.
            USDC.transfer(factoryOwner, ownerTxFee);
            USDC.transfer(AORISEATSADD.ownerOf(seatId), seatTxFee);
            USDC.transfer(msg.sender, USDCToReceive - (ownerTxFee + seatTxFee));
            //Tracking the volume in the NFT
            AORISEATSADD.addTakerVolume(USDCToReceive + ownerTxFee + seatTxFee, seatId, factory);
        }
        if(USDC.balanceOf(address(this)) == 0) {
            hasEnded = true;
        }
        emit Filled(msg.sender, OPTIONAfterFee, amountOfOPTION, hasEnded);
    }

    /**
        Cancel this order and refund all remaining tokens
    */
    function cancel() public nonReentrant {
        require(isFunded(), "no USDC balance");
        require(msg.sender == maker);
        uint256 balance = USDC.balanceOf(address(this));
        
        USDC.transfer(msg.sender, balance);
        hasEnded = true;
        emit OfferCanceled(maker, balance);
    }

    //Check if the contract is funded still.
    function isFunded() public view returns (bool) {
        if (USDC.balanceOf(address(this)) > 0 && hasBeenFunded) {
            return true;
        } else {
            return false;
        }
    }
    //View function to see if this offer still holds one USDC
    function isFundedOverOne() public view returns (bool) {
        if (USDC.balanceOf(address(this)) > (10 ** USDC.decimals())) {
            return true;
        } else {
            return false;
        }
    }

    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 z
    ) public pure returns (uint256) {
        return (x * y) / z;
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "safeTransfer: failed");
    }

    /**
        Additional view functions 
    */
    function getCurrentBalance() public view returns (uint256) {
        if (USDC.balanceOf(address(this)) >= 1) {
            return USDC.balanceOf(address(this));
        } else {
            return 0;
        }
    }

    function totalUSDCWanted() public view returns (uint256) {
        return (OPTIONPerUSDC * USDCSize) / 10**OPTIONDecimals;
    }
}
// SPDX-License-Identifier: UNLICENSED
/**                           
        /@#(@@@@@              
       @@      @@@             
        @@                      
        .@@@#                  
        ##@@@@@@,              
      @@@      /@@@&            
    .@@@  @   @  @@@@           
    @@@@  @@@@@  @@@@           
    @@@@  @   @  @@@/           
     @@@@       @@@             
       (@@@@#@@@      
    THE AORI PROTOCOL                           
 */
pragma solidity ^0.8.13;

import "./OpenZeppelin/Ownable.sol";
import "./Interfaces/IAoriSeats.sol";
import "./AoriCall.sol";
import "./AoriSeats.sol";
import "./OpenZeppelin/IERC20.sol";
import "./Margin/MarginManager.sol";

contract CallFactory is Ownable {

    mapping(address => bool) isListed;
    AoriCall[] callMarkets;
    address public keeper;
    uint256 public fee;
    AoriSeats public AORISEATSADD;
    MarginManager public manager;

    constructor(AoriSeats _AORISEATSADD, MarginManager _manager) {
        AORISEATSADD = _AORISEATSADD;
        manager = _manager;
    }

    event AoriCallCreated(
            address AoriCallAdd,
            uint256 strike, 
            uint256 duration, 
            IERC20 underlying, 
            IERC20 usdc,
            address oracle, 
            string name, 
            string symbol
        );

    /**
        Set the keeper of the Optiontroller.
        The keeper controls and deploys all new markets and orderbooks.
    */
    function setKeeper(address newKeeper) external onlyOwner returns(address) {
        keeper = newKeeper;
        return newKeeper;
    }

    function setAORISEATSADD(AoriSeats newAORISEATSADD) external onlyOwner returns(AoriSeats) {
        AORISEATSADD = newAORISEATSADD;
        return AORISEATSADD;
    }
    /**
        Deploys a new call option token at a designated strike and maturation block.
        Additionally deploys an orderbook to pair with the new ERC20 option token.
    */
    function createCallMarket(
            uint256 strikeInUSDC, 
            uint256 duration, 
            IERC20 UNDERLYING, 
            IERC20 USDC,
            address oracle,
            string memory name_, 
            string memory symbol_
            ) public returns (AoriCall) {

        require(msg.sender == keeper);

        AoriCall callMarket = new AoriCall(address(manager), AoriSeats(AORISEATSADD).getFeeMultiplier(), strikeInUSDC, duration, UNDERLYING, USDC, oracle, AoriSeats(AORISEATSADD), name_, symbol_);
        
        isListed[address(callMarket)] = true;
        callMarkets.push(callMarket);

        emit AoriCallCreated(address(callMarket), strikeInUSDC, duration, UNDERLYING, USDC, oracle, name_, symbol_);
        return (callMarket);
    }

    //Checks if an individual Call/Put is listed
    function checkIsListed(address market) external view returns(bool) {
        return isListed[market];
    }
    
    function getAORISEATSADD() external view returns(address) {
        return address(AORISEATSADD);
    }
    
    function getAllCallMarkets() external view returns(AoriCall[] memory) {
        return callMarkets;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}
// SPDX-License-Identifier: UNLICENSED
/**
           :=*#%%@@@@@@@%%#*=-.         
        =#@@#+==--=+*@@@@@@@@@@@#-      
      :@@%-           :*@@@@@@@@@@@-    
      @@%                =@@@@@@@@@@    
     .@@%                  +@@@@@@@%    
      #@@*                   -+##*=     
       *@@@+:                           
        :#@@@%=.                        
          :#@@@@%=.                     
            .+@@@@@%+.                  
               =%@@@@@%+:               
                 :#@@@@@@%+.            
                   -%@@@@@@@%=          
            .-+#%@@@@%#@@@@@@@@*:       
         -*%@@@@#=:    .*@@@@@@@@#:     
      .+@@@@@%-          .%@@@@@@@@*    
    .#@@@@@@-              +@@@@@@@@%.  
   +@@@@@@%.                =@@@@@@@@@. 
  #@@@@@@@.                  =@@@@@@@@% 
 #@@@@@@@+                    #@@@@@@@@+
=@@@@@@@@.     %        #.    .@@@@@@@@%
#@@@@@@@@      @*-....:+@.     %@@@@@@@@
@@@@@@@@%      @@@@@@@@@@.     *@@@@@@@@
@@@@@@@@%      @@%#**##@@.     *@@@@@@@#
%@@@@@@@@      @.       %.     #@@@@@@@-
=@@@@@@@@-     =        -      @@@@@@@* 
 %@@@@@@@%                    +@@@@@@#  
 .%@@@@@@@#                  :@@@@@@=   
  .#@@@@@@@#.               -@@@@@#.    
    -%@@@@@@@+            .*@@@@#:      
      -#@@@@@@@*=:    .:=#@@@%+.        
         -*%@@@@@@@@@@@@@%*=. 
              &@@@@@@@@%
 */
pragma solidity 0.8.19;

import "../OpenZeppelin/IERC20.sol";

interface IAoriSeats {

    function setMinter(address _minter) external returns (address);

    function setAORITOKEN(IERC20 newAORITOKEN) external returns (IERC20);

    function setBaseURI(string memory baseURI) external returns(string memory);

    function mintSeat() external returns (uint256);

    function combineSeats(uint256 seatIdOne, uint256 seatIdTwo) external returns(uint256);

    function separateSeats(uint256 seatId) external;

    function addPoints(uint256 pointsToAdd, address userAdd) external;

    function addTakerPoints(uint256 pointsToAdd, address userAdd, address Orderbook_) external;

    function addTakerVolume(uint256 volumeToAdd, uint256 seatId, address Orderbook_) external;

    function claimAORI(address claimer) external;

    function setMaxSeats(uint256 newMaxSeats) external  returns (uint256);
 
    function setFeeMultiplier(uint256 newFeeMultiplier) external  returns (uint256);

    function setMaxSeatScore(uint256 newMaxScore) external  returns(uint256);

    function setMinFee(uint256 newMintFee) external  returns (uint256);

    function getOptionMintingFee() external view returns (uint256);

    function confirmExists(uint256 seatId) external view returns (bool);

    function getTotalPoints(address user) external view returns (uint256);
    
    function getClaimablePoints(address user) external view returns (uint256);

    function getSeatScore(uint256 seatId) external view returns (uint256);

    function getmaxSeatScore() external view returns (uint256);
    
    function getFeeMultiplier() external view returns (uint256);

    function getSeatVolume(uint256 seatId) external view returns (uint256);
}
// SPDX-License-Identifier: UNLICENSED
/**                           
        /@#(@@@@@              
       @@      @@@             
        @@                      
        .@@@#                  
        ##@@@@@@,              
      @@@      /@@@&            
    .@@@  @   @  @@@@           
    @@@@  @@@@@  @@@@           
    @@@@  @   @  @@@/           
     @@@@       @@@             
       (@@@@#@@@      
    THE AORI PROTOCOL                           
 */
pragma solidity 0.8.19;

import "../OpenZeppelin/Ownable.sol";
import "../Chainlink/AggregatorV3Interface.sol";
import "./PositionRouter.sol";
import "../OpenZeppelin/Ownable.sol";
import "../OpenZeppelin/ReentrancyGuard.sol";
import "./Vault.sol";

contract MarginManager is Ownable, ReentrancyGuard {
    
    // Storage variables
    PositionRouter public positionRouter;
    uint256 public immutable BPS_DIVISOR = 10000;
    uint256 public collateralRatio; //12000 by default, or 120%
    uint256 immutable expScale = 1e18;
    uint256 immutable USDCScale = 10**6;
    
    //Necessary mappings to store user data and open position/option data
    mapping(ERC20 => bool) public whitelistedAssets;
    mapping(ERC20 => Vault) public lpTokens;
    mapping(ERC20 => AggregatorV3Interface) public oracles;
    mapping(bytes32 => Position) public positions;
    //add address => position mapping for frontend

    struct Position {
        address account;
        bool isCall;
        address token;
        address option;
        uint256 strikeInUSDC;
        uint256 optionSize;
        uint256 collateral;
        uint256 entryMarginRate;
        uint256 lastAccrueTime;
        address orderbook;
        uint256 endingTime;
    }

    constructor(
        PositionRouter _positionRouter
    ){
        positionRouter = _positionRouter;
    }

    event PositionCreated(bytes32 key_, address _account, uint256 _optionSize, address _orderbook, bool _isCall);
    event PositionUpdated(bytes32 key_, address _account, uint256 _optionSize, address _orderbook, bool _isCall);

    /**
        Good
     */
    function openShortPosition(
        address account_,
        uint256 collateral,
        address orderbook,
        bool isCall,
        uint256 amountOfUnderlying,
        uint256 seatId
    ) public nonReentrant returns (bytes32){
        require(msg.sender == address(positionRouter));
        bytes32 key;
        Structs.Vars memory localVars;
        address option = address(Orderbook(orderbook).OPTION());
        ERC20 token;
        if(isCall) {
            token = ERC20(address(AoriCall(option).UNDERLYING()));
            //mint options
            localVars.optionsMinted = lpTokens[token].mintOptions(amountOfUnderlying, option, seatId, account_, true);
            //store position data
            key = getPositionKey(account_, localVars.optionsMinted, orderbook, true);
            Position storage position = positions[key];
            position.account = account_;
            position.isCall = true;
            position.option = option;
            position.strikeInUSDC = AoriCall(option).strikeInUSDC();
            position.optionSize = localVars.optionsMinted;
            position.collateral = collateral;
            position.entryMarginRate = positionRouter.getBorrowRate(token); //1e8 per block, 
            position.lastAccrueTime = block.timestamp;
            position.orderbook = orderbook;
            position.endingTime = AoriCall(option).endingTime();
            emit PositionCreated(key, account_, position.optionSize, position.orderbook, true);
        } else if(!isCall) {
            token = ERC20(address(AoriPut(option).USDC()));

            //mint options
            localVars.optionsMinted = lpTokens[token].mintOptions(amountOfUnderlying, option, seatId, account_, false);
            //store position data
            key = getPositionKey(account_, localVars.optionsMinted, orderbook, true);
            Position storage position = positions[key];
            position.account = account_;
            position.isCall = false;
            position.option = option;
            position.strikeInUSDC = AoriPut(option).strikeInUSDC();
            position.optionSize = localVars.optionsMinted;
            position.collateral = collateral;
            position.entryMarginRate = positionRouter.getBorrowRate(token);
            position.lastAccrueTime = block.timestamp;
            position.orderbook = orderbook;
            position.endingTime = AoriPut(option).endingTime();
            emit PositionCreated(key, account_, position.optionSize, position.orderbook, false);
        }
        return key;
    }

    /**
        Good
     */
    function settlePosition(address account, bytes32 key) public nonReentrant {
        Position memory position = positions[key];
        uint256 collateralMinusLoss;
        ERC20 underlying;
        if(position.isCall) {
            AoriCall(position.option).endingTime();
            require(block.timestamp >= AoriCall(position.option).endingTime(), "Option has not reached expiry");
            underlying = ERC20(address(AoriCall(position.option).UNDERLYING()));
            if(AoriCall(position.option).getITM() > 0) {
                lpTokens[underlying].settleITMOption(position.option, true);
                collateralMinusLoss = position.collateral - positionRouter.mulDiv(AoriCall(position.option).settlementPrice() - position.strikeInUSDC, position.optionSize, USDCScale); 
                underlying.approve(account, collateralMinusLoss);
                underlying.transfer(account, collateralMinusLoss);
                underlying.decreaseAllowance(account, underlying.allowance(address(this), account));
                delete positions[key];
                emit PositionUpdated(key, account, position.optionSize, position.orderbook, position.isCall);
            } else {
                lpTokens[underlying].settleOTMOption(position.option, true);
                underlying.approve(account, position.collateral);
                underlying.transfer(account, position.collateral);
                underlying.decreaseAllowance(account, underlying.allowance(address(this), account));
                delete positions[key];
                emit PositionUpdated(key, account, position.optionSize, position.orderbook, position.isCall);
            }
        } else {
            require(block.timestamp >= AoriCall(position.option).endingTime(), "Option has not reached expiry");
            underlying = ERC20(address(AoriPut(position.option).USDC()));
            if(AoriPut(position.option).getITM() > 0) {
                lpTokens[underlying].settleITMOption(position.option, false);
                collateralMinusLoss = position.collateral - positionRouter.mulDiv(position.strikeInUSDC - AoriPut(position.option).settlementPrice(), position.optionSize, expScale);
                doTransferOut(underlying, account, collateralMinusLoss);
                delete positions[key];
                emit PositionUpdated(key, account, position.optionSize, position.orderbook, position.isCall);
            } else {
                lpTokens[underlying].settleOTMOption(position.option, false);
                doTransferOut(underlying, account, collateralMinusLoss);
                delete positions[key];
                emit PositionUpdated(key, account, position.optionSize, position.orderbook, position.isCall);
            }
        }
    }
    /**
        Good
     */
    function addCollateral(bytes32 key, uint256 collateralToAdd) public nonReentrant returns (uint256) {
        Position memory position = positions[key];
        ERC20 underlying;        
        if(position.isCall) {
            underlying = ERC20(address(AoriCall(position.option).UNDERLYING()));
            underlying.transferFrom(msg.sender, address(this), collateralToAdd);
            position.collateral += collateralToAdd;
            emit PositionUpdated(key, position.account, position.optionSize, position.orderbook, true);
        } else {
            underlying = ERC20(address(AoriPut(position.option).UNDERLYING()));
            underlying.transferFrom(msg.sender, address(this), collateralToAdd);
            position.collateral += collateralToAdd;
            emit PositionUpdated(key, position.account, position.optionSize, position.orderbook, true);
        }
        return position.collateral;
    }
    /**
        Good
     */
    function liquidatePosition(bytes32 key, uint256 fairValueOfOption, address liquidator) public returns (uint256) {
        require(positionRouter.isLiquidator(msg.sender));
        Position memory position = positions[key];
        accruePositionInterest(key);
        Structs.Vars memory localVars;
        ERC20 underlying;
        if(position.isCall) {
            underlying = ERC20(address(AoriCall(position.option).UNDERLYING()));
            require(whitelistedAssets[underlying], "Asset it not whitelisted");
            (localVars.collateralVal, localVars.portfolioVal, localVars.isLiquidatable) = positionRouter.isLiquidatable(underlying, fairValueOfOption, position.optionSize, position.collateral, true);
            require(localVars.isLiquidatable, "Portfolio is not liquidatable");

            localVars.profit = localVars.collateralVal - localVars.portfolioVal;
            localVars.profitInUnderlying = positionRouter.mulDiv(localVars.profit, 10**underlying.decimals(), positionRouter.getPrice(oracles[underlying]));
            uint256 fairValueInUnderlying = positionRouter.mulDiv(fairValueOfOption, position.optionSize, positionRouter.getPrice(oracles[underlying]));
            localVars.collateralToLiquidator = fairValueInUnderlying + positionRouter.mulDiv(localVars.profitInUnderlying, positionRouter.liquidatorFee(), BPS_DIVISOR);
            //Liquidator sells us options
            doTransferOut(ERC20(position.option), address(lpTokens[underlying]), position.optionSize);
            lpTokens[underlying].closeHedgedPosition(position.option, true, position.optionSize);
            //transfer the profit to the liquidator
            doTransferOut(underlying, liquidator, localVars.collateralToLiquidator);
            //and profit to the vault
            doTransferOut(underlying, address(lpTokens[underlying]), position.collateral - localVars.collateralToLiquidator);
            //storage
            delete positions[key];
            emit PositionUpdated(key, position.account, position.optionSize, position.orderbook, true);
        } else {
            underlying = ERC20(address(AoriPut(position.option).USDC()));
            require(whitelistedAssets[underlying], "Asset it not whitelisted");
            (localVars.collateralVal, localVars.portfolioVal, localVars.isLiquidatable) = positionRouter.isLiquidatable(underlying, fairValueOfOption, position.optionSize, position.collateral, false);
            require(localVars.isLiquidatable, "Portfolio is not liquidatable");
            //Calculate the fees
            localVars.profit = localVars.collateralVal - localVars.portfolioVal;
            localVars.profitInUnderlying = positionRouter.mulDiv(localVars.profit, 10**USDCScale, positionRouter.getPrice(oracles[underlying]));
            localVars.collateralToLiquidator = fairValueOfOption + positionRouter.mulDiv(localVars.profitInUnderlying, positionRouter.liquidatorFee(), BPS_DIVISOR);
            //Liquidator sells the vault the options
            doTransferOut(AoriPut(position.option), address(lpTokens[underlying]), position.optionSize);
            lpTokens[underlying].closeHedgedPosition(position.option, true, position.optionSize);
            //transfer the profit to the liquidator
            doTransferOut(underlying, liquidator, localVars.collateralToLiquidator);
            //and profit to the vault
            doTransferOut(underlying, address(lpTokens[underlying]), position.collateral - localVars.collateralToLiquidator);
            
            AoriPut(position.option).liquidationSettlement(position.optionSize);
            //storage
            delete positions[key];
            emit PositionUpdated(key, position.account, position.optionSize, position.orderbook, false);
        }
    }
    /**
        Good
     */
    function accruePositionInterest(bytes32 key) public returns (bool) {
        Position memory position = positions[key];
        ERC20 underlying;
        //irm calc
        AoriCall call;
        AoriPut put;
        uint256 interestOwed;
        require(block.timestamp - position.lastAccrueTime > 0, "cannot accrue position interest at the moment of deployment");
        
        if(position.isCall) {
            call = AoriCall(position.option);
            underlying = ERC20(address(call.UNDERLYING()));
            uint256 interestFactor = ((positionRouter.getBorrowRate(underlying) + position.entryMarginRate) / 2) * (block.timestamp - position.lastAccrueTime);
            interestOwed = positionRouter.mulDiv(interestFactor, position.optionSize, expScale);
            doTransferOut(underlying, address(lpTokens[underlying]), interestOwed);
        } else {
            put = AoriPut(position.option);
            underlying = ERC20(address(put.UNDERLYING()));
            uint256 interestFactor = ((positionRouter.getBorrowRate(underlying) + position.entryMarginRate) / 2) * (block.timestamp - position.lastAccrueTime);
            uint256 USDCUnderlying = positionRouter.mulDiv(position.optionSize, position.strikeInUSDC, expScale);
            interestOwed = positionRouter.mulDiv(interestFactor, USDCUnderlying, expScale);
            doTransferOut(underlying, address(lpTokens[underlying]), interestOwed);
        }
        if(position.collateral > interestOwed) {
            position.collateral -= interestOwed;
            position.lastAccrueTime = block.timestamp;
            lpTokens[underlying].repaid(interestOwed);
            return true;
        } else {
            return false;
        }
    }
    /**
        Good
     */
    function whitelistAsset(ERC20 token, AggregatorV3Interface oracle) public onlyOwner nonReentrant returns(ERC20) {
        whitelistedAssets[token] = true;
        Vault lpToken = new Vault(token, string.concat("Aori Vault for",string(token.name())), string.concat("a",string(token.name())), MarginManager(address(this)));
        lpTokens[token] = lpToken;
        oracles[token] = oracle;
        return token;
    }

    function getPosition(address _account, uint256 _optionSize, address _orderbook, bool _isCall) public view returns (address, bool, address, uint256, uint256, uint256, uint256, uint256, address, uint256) {
        bytes32 key = getPositionKey(_account, _optionSize, _orderbook, _isCall);
        Position memory position = positions[key];
        return (
            position.account,
            position.isCall,
            position.option,
            position.strikeInUSDC,
            position.optionSize,
            position.collateral,
            position.entryMarginRate,
            position.lastAccrueTime,
            position.orderbook,
            position.endingTime
        );
    }

    function getPositionWithKey(bytes32 key) public view returns (address, bool, address, uint256, uint256, uint256, uint256, uint256, address, uint256) {
        Position memory position = positions[key];
        return (
            position.account,
            position.isCall,
            position.option,
            position.strikeInUSDC,
            position.optionSize,
            position.collateral,
            position.entryMarginRate,
            position.lastAccrueTime,
            position.orderbook,
            position.endingTime
        );
    }

    function getPositionKey(address _account, uint256 _optionSize, address _orderbook, bool _isCall) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(
            _account,
            _optionSize,
            _orderbook,
            _isCall
        ));
    }

    function vaultAdd(ERC20 token) public view returns (address) {
        require(whitelistedAssets[token], "Unsupported market");
        return address(lpTokens[token]);
    }

    function doTransferOut(ERC20 token, address receiver, uint256 amount) internal returns (bool) {
        token.approve(receiver, amount);
        token.transfer(receiver, amount);
        token.decreaseAllowance(receiver, token.allowance(address(this), receiver));
    }
}
// SPDX-License-Identifier: UNLICENSED
/**                           
        /@#(@@@@@              
       @@      @@@             
        @@                      
        .@@@#                  
        ##@@@@@@,              
      @@@      /@@@&            
    .@@@  @   @  @@@@           
    @@@@  @@@@@  @@@@           
    @@@@  @   @  @@@/           
     @@@@       @@@             
       (@@@@#@@@      
    THE AORI PROTOCOL                           
 */
pragma solidity 0.8.19;

import "../OpenZeppelin/Ownable.sol";
import "./MarginManager.sol";
import "../OpenZeppelin/ERC20.sol";
import "./Vault.sol";
import "./Structs.sol";
import "../AoriCall.sol";
import "../AoriPut.sol";
import "../Orderbook.sol";
import "../CallFactory.sol";
import "../PutFactory.sol";

contract PositionRouter is Ownable {

    address public callFactory;
    address public putFactory;
    MarginManager public manager;
    uint256 immutable tolerance = 2 hours;
    uint256 public immutable BPS_DIVISOR = 10000;
    uint256 immutable expScale = 1e18;
    uint256 immutable USDCScale = 1e6;
    mapping(address => bool) public isLiquidator;
    mapping(address => bool) public keeper;
    uint256 public liquidatorFee; //In BPS, 2500
    uint256 public liquidationRatio; //in bps over 10000, default 20000
    uint256 public initialMarginRatio; //20% of underlying, so 2000 base.
    uint256 public liquidatorSeatId; //seat held by this address
    mapping(ERC20 => IRM) public interestRateModels;

    mapping(bytes32 => Structs.OpenPositionRequest) public openPositionRequests;
    bytes32[] public openPositionRequestKeys;
    uint256 indexPosition;

    struct IRM { //All in 1e4 scale
        uint256 baseRate;
        uint256 kinkUtil;
        uint256 rateBeforeUtil;
        uint256 rateAfterUtil;
    }

    event RequestCreated(bytes32 key, address account, uint256 index);
    event OrderApproved(bytes32 key, address account, uint256 index);
    event OrderDenied(uint256 index);

    function initialize(
            address callFactory_, 
            address putFactory_, 
            MarginManager manager_, 
            uint256 liquidatorFee_, 
            uint256 liquidationRatio_, 
            uint256 initialMarginRatio_, 
            uint256 liquidatorSeatId_,
            address keeper_
        ) public onlyOwner {
        callFactory = callFactory_;
        putFactory = putFactory_;
        manager = manager_;
        liquidatorFee = liquidatorFee_;
        liquidationRatio = liquidationRatio_;
        initialMarginRatio = initialMarginRatio_;
        setLiquidatorSeatId(liquidatorSeatId_);
        setKeeper(keeper_);
    }
    

    function setLiquidator(address liquidator) public onlyOwner {
        isLiquidator[liquidator] = true;
    }
    function setKeeper(address _keeper) public onlyOwner {
        keeper[_keeper] = true;
    }
    function setLiquidatorFee(uint256 newFee) public onlyOwner returns(uint256) {
        liquidatorFee = newFee;
        return newFee;
    }
    function setLiquidatorSeatId(uint256 newLiquidatorSeatId) public onlyOwner returns(uint256) {
        liquidatorSeatId = newLiquidatorSeatId;
        return liquidatorSeatId;
    }
    function setLiquidatonThreshold(uint256 newThreshold) public onlyOwner returns(uint256) {
        liquidationRatio = newThreshold;
        return newThreshold;
    }
    function setInitialMarginRatio(uint256 newInitialMarginRatio) public onlyOwner returns(uint256) {
        initialMarginRatio = newInitialMarginRatio;
        return initialMarginRatio;
    }

    function openShortPositionRequest(
            address _account,
            address option,
            uint256 collateral,
            address orderbook,
            bool isCall,
            uint256 amountOfUnderlying,
            uint256 seatId
            ) 
        public returns (uint256) {
        require(amountOfUnderlying > 0, "Must request some borrow");
        address token;
        bytes32 requestKey;
        uint256 optionsToMint;
        uint256 currentIndex;
        if(isCall) {
            token = address(AoriCall(option).UNDERLYING());
            require(CallFactory(callFactory).checkIsListed(option), "Not a valid call market");
            require(AoriCall(option).endingTime() != 0, "Invalid maturity");

            optionsToMint = mulDiv(amountOfUnderlying, USDCScale, AoriCall(option).strikeInUSDC());
            ERC20(token).transferFrom(msg.sender, address(this), collateral);
            
            currentIndex = indexPosition;
            requestKey = getRequestKey(_account, indexPosition);
            indexPosition++;

            Structs.OpenPositionRequest storage positionRequest = openPositionRequests[requestKey];
            positionRequest.account = _account;
            positionRequest.collateral = collateral;
            positionRequest.seatId = seatId;
            positionRequest.orderbook = orderbook;
            positionRequest.isCall = true;
            positionRequest.amountOfUnderlying = amountOfUnderlying;
            positionRequest.endingTime = AoriCall(option).endingTime();

            openPositionRequestKeys.push(requestKey);
            emit RequestCreated(requestKey, _account, currentIndex);
            return currentIndex;
        } else {
            token = address(AoriPut(option).USDC());
            require(PutFactory(putFactory).checkIsListed(option), "Not a valid put market");
            require(AoriPut(option).endingTime() != 0, "Invalid maturity");

            optionsToMint = 10**(12) * mulDiv(amountOfUnderlying, USDCScale, AoriPut(option).strikeInUSDC());            
            ERC20(token).transferFrom(msg.sender, address(this), collateral);

            currentIndex = indexPosition;
            requestKey = getRequestKey(_account, currentIndex);
            indexPosition++;

            Structs.OpenPositionRequest storage positionRequest = openPositionRequests[requestKey];
            positionRequest.account = _account;
            positionRequest.collateral = collateral;
            positionRequest.seatId = seatId;
            positionRequest.orderbook = orderbook;
            positionRequest.isCall = false;
            positionRequest.amountOfUnderlying = amountOfUnderlying;
            positionRequest.endingTime = AoriPut(option).endingTime();
        
            openPositionRequestKeys.push(requestKey);
            emit RequestCreated(requestKey, _account, currentIndex);
            return currentIndex;
        }
        
    }

    function executeOpenPosition(uint256 indexToExecute) public returns (bytes32) {
        require(keeper[msg.sender]);
        bytes32 key = openPositionRequestKeys[indexToExecute];
        Structs.OpenPositionRequest memory positionRequest = openPositionRequests[key];
        ERC20 underlying;
        if(positionRequest.isCall) {
            underlying = AoriCall(address(Orderbook(positionRequest.orderbook).UNDERLYING(true)));
            underlying.approve(address(manager), positionRequest.collateral);
        } else if (!positionRequest.isCall){
            underlying = ERC20(address(Orderbook(positionRequest.orderbook).USDC()));
            underlying.approve(address(manager), positionRequest.collateral);
        }
        underlying.transfer(address(manager), positionRequest.collateral);
        bytes32 keyToEmit = manager.openShortPosition(
            positionRequest.account, 
            positionRequest.collateral, 
            positionRequest.orderbook, 
            positionRequest.isCall, 
            positionRequest.amountOfUnderlying, 
            positionRequest.seatId
        );

        emit OrderApproved(keyToEmit, positionRequest.account, indexToExecute);
        delete openPositionRequestKeys[indexToExecute];
        return keyToEmit;
    }

    function rejectIncreasePosition(uint256 indexToReject) public {
        require(keeper[msg.sender]);
        emit OrderDenied(indexToReject);
        delete openPositionRequestKeys[indexToReject];
    }

    /**
        Get the interest rate based on an inputted util
        @notice util is inputted in BPS
     */
    function getBorrowRate(ERC20 token) public view returns (uint256) {
        require(manager.whitelistedAssets(token),  "Unsupported vault");
        Vault vault = manager.lpTokens(token);
        uint256 util = mulDiv(vault.totalBorrows(), expScale, token.balanceOf(address(vault)) + vault.totalBorrows()); //1e18
        IRM memory irm = interestRateModels[token];
        if (util <= irm.kinkUtil) {
            return irm.baseRate + mulDiv(util, irm.rateBeforeUtil, expScale); //1e18 + 1e18 * 1e18 / 1e18
        } else {
            //1e18 * 1e18 / 1e18 + (1e18 - 1e18) * 1e18 / 1e18
            uint256 prePlusPost = mulDiv(irm.kinkUtil, irm.rateBeforeUtil, expScale) + mulDiv((util - irm.kinkUtil), irm.rateAfterUtil, expScale);
            return (prePlusPost + irm.baseRate);
        }
    }

    function isLiquidatable(ERC20 token, uint256 fairValueOfOption, uint256 optionSize, uint256 collateral, bool isCall) public view returns(uint256, uint256, bool) {
        uint256 collateralVal;
        uint256 positionVal;
        uint256 liquidationThreshold;
        if(isCall) {
            collateralVal = mulDiv(getPrice(manager.oracles(token)), collateral, 10**token.decimals());
            positionVal = mulDiv(fairValueOfOption, optionSize, expScale);
            liquidationThreshold = mulDiv(positionVal, liquidationRatio, BPS_DIVISOR);
            if(liquidationThreshold >= collateralVal) {
                return (collateralVal, positionVal, true);
            } else {
                return (collateralVal, positionVal, false);
            }
        } else {
            collateralVal = mulDiv(getPrice(manager.oracles(token)), optionSize, expScale);
            positionVal = mulDiv(fairValueOfOption, optionSize, expScale);
            liquidationThreshold = mulDiv(positionVal, liquidationRatio, BPS_DIVISOR);
            if(liquidationThreshold >= collateralVal) {
                return (collateralVal, positionVal, true);
            } else {
                return (collateralVal, positionVal, false);
            }
        }
    }

    function getInitialMargin(ERC20 token, uint256 fairValueInUSDCScale, uint256 optionSize, bool isCall) public view returns(uint256) {
        uint256 positionVal;
        if(isCall) {
            positionVal = mulDiv(fairValueInUSDCScale, optionSize, expScale); //1e6 * 1e18 / 1e18
            return mulDiv(positionVal, expScale, getPrice(manager.oracles(token))) + mulDiv(optionSize, initialMarginRatio, BPS_DIVISOR); 
        } else {
            // .2 underlying plus fair val
            positionVal = fairValueInUSDCScale + mulDiv(getPrice(manager.oracles(token)), initialMarginRatio, BPS_DIVISOR);
            return mulDiv(positionVal, optionSize, expScale);
        }
    }
 

    function updateIRM(ERC20 token, uint256 _baseRate, uint256 _kinkUtil, uint256 _rateBeforeUtil, uint256 _rateAfterUtil) public onlyOwner returns (IRM memory) {
        IRM memory irm;
        irm.baseRate = _baseRate;
        irm.kinkUtil = _kinkUtil;
        irm.rateBeforeUtil = _rateBeforeUtil;
        irm.rateAfterUtil = _rateAfterUtil;
        interestRateModels[token] = irm;
        return interestRateModels[token];
    }

    /** 
        Get the price converted from Chainlink format to USDC
    */
    function getPrice(AggregatorV3Interface oracle) public view returns (uint256) {
        (, int256 price,  ,uint256 updatedAt,  ) = oracle.latestRoundData();
        require(price >= 0, "Negative Prices are not allowed");
        require(block.timestamp <= updatedAt + tolerance, "Price is too stale to be trustworthy"); // also works if updatedAt is 0
        if (price == 0) {
            return 0;
        } else {
            //8 is the decimals() of chainlink oracles, return USDC scale
            return (uint256(price) / (10**2));
        }
    }

    function getPosition(address _account, uint256 _index) public view returns (address, uint256, uint256, address, bool, uint256, uint256) {
        bytes32 key = getRequestKey(_account, _index);
        Structs.OpenPositionRequest memory positionRequest = openPositionRequests[key];
        return (
            positionRequest.account,
            positionRequest.collateral,
            positionRequest.seatId,
            positionRequest.orderbook,
            positionRequest.isCall,
            positionRequest.amountOfUnderlying,
            positionRequest.endingTime
        );
    }

    function getRequestKey(address _account, uint256 _index) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_account, _index));
    }

    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 z
    ) public pure returns (uint256) {
        return (x * y) / z;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;
import "../OpenZeppelin/ERC20.sol";

library Structs {
    struct OpenPositionRequest {
        address account;
        uint256 collateral;
        address orderbook;
        bool isCall;
        uint256 amountOfUnderlying;
        uint256 seatId;
        uint256 endingTime;
    }
    
    struct Vars {
        uint256 optionsMinted;
        uint256 collateralVal;
        uint256 portfolioVal;
        uint256 collateralToLiquidator;
        uint256 profit;
        uint256 profitInUnderlying;
        bool isLiquidatable;
    }
    
    struct settleVars {
        uint256 tokenBalBefore;
        uint256 tokenDiff;
        uint256 optionsSold;
    }
}
// SPDX-License-Identifier: UNLICENSED
/**                           
        /@#(@@@@@              
       @@      @@@             
        @@                      
        .@@@#                  
        ##@@@@@@,              
      @@@      /@@@&            
    .@@@  @   @  @@@@           
    @@@@  @@@@@  @@@@           
    @@@@  @   @  @@@/           
     @@@@       @@@             
       (@@@@#@@@      
    THE AORI PROTOCOL                           
 */
pragma solidity 0.8.19;

import "../OpenZeppelin/Ownable.sol";
import "../OpenZeppelin/ERC20.sol";
import "../Chainlink/AggregatorV3Interface.sol";
import "./MarginManager.sol";
import "../AoriCall.sol";
import "../AoriPut.sol";
import "../OpenZeppelin/Ownable.sol";
import "../OpenZeppelin/ReentrancyGuard.sol";
import "../OpenZeppelin/ERC4626.sol";
import "./Structs.sol";

contract Vault is Ownable, ReentrancyGuard, ERC4626 {

    ERC20 token;
    MarginManager manager;
    mapping(address => bool) public isSettled;
    uint256 USDCScale = 10**6;

    // struct settleVars {
    //     uint256 tokenBalBefore;
    //     uint256 tokenDiff;
    //     uint256 optionsSold;
    // }
    
    constructor(ERC20 asset, string memory name, string memory symbol, MarginManager manager_
    )  ERC4626(asset, name, symbol) {
        manager = manager_;
        token = ERC20(asset);
    }

    function depositAssets(uint256 assets, address receiver) public nonReentrant {
        deposit(assets, receiver);
    }

    function withdrawAssets(uint256 assets, address receiver) public nonReentrant {
        withdraw(assets, receiver, receiver);
    }

    // mintOptions(amountOfUnderlying, option, seatId, _account, true);
    function mintOptions(uint256 amountOfUnderlying, address option, uint256 seatId, address account, bool isCall) public nonReentrant returns (uint256) {
        require(msg.sender == address(manager));
        totalBorrows += amountOfUnderlying;
        uint256 optionsMinted;
        if(isCall) {
            AoriCall(option).UNDERLYING().approve(option, amountOfUnderlying);
            optionsMinted = AoriCall(option).mintCall(amountOfUnderlying, account, seatId);
            return optionsMinted;
        } else {
            AoriPut(option).USDC().approve(option, amountOfUnderlying);
            optionsMinted = AoriPut(option).mintPut(amountOfUnderlying, account, seatId);
            return optionsMinted;
        }
    }

    function settleITMOption(address option, bool isCall) public nonReentrant returns (uint256) {
        Structs.settleVars memory vars;
        if(isSettled[option]) {
            return 0;
        } else {
            require(AoriCall(option).endingTime() <= block.timestamp || AoriPut(option).endingTime() <= block.timestamp, "Option has not expired");
            vars.tokenBalBefore = token.balanceOf(address(this));
            if(isCall) {
                vars.optionsSold = AoriCall(option).getOptionsSold(address(this));
                AoriCall(option).sellerSettlementITM();
                isSettled[option] = true;
            } else {                
                vars.optionsSold = AoriPut(option).getOptionsSold(address(this));
                AoriPut(option).sellerSettlementITM();
                isSettled[option] = true;
            }
            vars.tokenDiff = token.balanceOf(address(this)) - vars.tokenBalBefore;
            totalBorrows -= vars.tokenDiff;
            return vars.tokenDiff;
        }
    }

    function settleOTMOption(address option, bool isCall) public nonReentrant returns (uint256) {
        Structs.settleVars memory vars;
        if(isSettled[option]) {
            return 0;
        } else {
            if(isCall) {
                vars.tokenBalBefore = token.balanceOf(address(this));            
                AoriCall(option).sellerSettlementOTM();
                isSettled[option] = true;
            } else {
                vars.tokenBalBefore = token.balanceOf(address(this));
                AoriPut(option).sellerSettlementOTM();
                isSettled[option] = true;
            }
            vars.tokenDiff = token.balanceOf(address(this)) - vars.tokenBalBefore;
            totalBorrows -= vars.tokenDiff;
            return vars.tokenDiff;
        }
    }

    function closeHedgedPosition(address option, bool isCall, uint256 optionsToSettle) public {
        require(msg.sender == address(manager));
        if(isCall) {
            AoriCall(option).liquidationSettlement(optionsToSettle);
        } else {
            AoriPut(option).liquidationSettlement(optionsToSettle);
        }
    }

    function repaid(uint256 assets) public returns (uint256) {
        require(msg.sender == address(manager));
        totalBorrows -= assets;
        return assets;    
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./IERC20Metadata.sol";
import "./Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * The default value of {decimals} is 18. To change this, you should override
 * this function so it returns a different value.
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_, uint8 decimals_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override(IERC20, IERC20Metadata) returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/common/ERC2981.sol)

pragma solidity ^0.8.0;

import "./IERC2981.sol";
import "./ERC165.sol";

/**
 * @dev Implementation of the NFT Royalty Standard, a standardized way to retrieve royalty payment information.
 *
 * Royalty information can be specified globally for all token ids via {_setDefaultRoyalty}, and/or individually for
 * specific token ids via {_setTokenRoyalty}. The latter takes precedence over the first.
 *
 * Royalty is specified as a fraction of sale price. {_feeDenominator} is overridable but defaults to 10000, meaning the
 * fee is specified in basis points by default.
 *
 * IMPORTANT: ERC-2981 only specifies a way to signal royalty information and does not enforce its payment. See
 * https://eips.ethereum.org/EIPS/eip-2981#optional-royalty-payments[Rationale] in the EIP. Marketplaces are expected to
 * voluntarily pay royalties together with sales, but note that this standard is not yet widely supported.
 *
 * _Available since v4.5._
 */
abstract contract ERC2981 is IERC2981, ERC165 {
    struct RoyaltyInfo {
        address receiver;
        uint96 royaltyFraction;
    }

    RoyaltyInfo private _defaultRoyaltyInfo;
    mapping(uint256 => RoyaltyInfo) private _tokenRoyaltyInfo;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC165) returns (bool) {
        return interfaceId == type(IERC2981).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @inheritdoc IERC2981
     */
    function royaltyInfo(uint256 tokenId, uint256 salePrice) public view virtual override returns (address, uint256) {
        RoyaltyInfo memory royalty = _tokenRoyaltyInfo[tokenId];

        if (royalty.receiver == address(0)) {
            royalty = _defaultRoyaltyInfo;
        }

        uint256 royaltyAmount = (salePrice * royalty.royaltyFraction) / _feeDenominator();

        return (royalty.receiver, royaltyAmount);
    }

    /**
     * @dev The denominator with which to interpret the fee set in {_setTokenRoyalty} and {_setDefaultRoyalty} as a
     * fraction of the sale price. Defaults to 10000 so fees are expressed in basis points, but may be customized by an
     * override.
     */
    function _feeDenominator() internal pure virtual returns (uint96) {
        return 10000;
    }

    /**
     * @dev Sets the royalty information that all ids in this contract will default to.
     *
     * Requirements:
     *
     * - `receiver` cannot be the zero address.
     * - `feeNumerator` cannot be greater than the fee denominator.
     */
    function _setDefaultRoyalty(address receiver, uint96 feeNumerator) internal virtual {
        require(feeNumerator <= _feeDenominator(), "ERC2981: royalty fee will exceed salePrice");
        require(receiver != address(0), "ERC2981: invalid receiver");

        _defaultRoyaltyInfo = RoyaltyInfo(receiver, feeNumerator);
    }

    /**
     * @dev Removes default royalty information.
     */
    function _deleteDefaultRoyalty() internal virtual {
        delete _defaultRoyaltyInfo;
    }

    /**
     * @dev Sets the royalty information for a specific token id, overriding the global default.
     *
     * Requirements:
     *
     * - `receiver` cannot be the zero address.
     * - `feeNumerator` cannot be greater than the fee denominator.
     */
    function _setTokenRoyalty(uint256 tokenId, address receiver, uint96 feeNumerator) internal virtual {
        require(feeNumerator <= _feeDenominator(), "ERC2981: royalty fee will exceed salePrice");
        require(receiver != address(0), "ERC2981: Invalid parameters");

        _tokenRoyaltyInfo[tokenId] = RoyaltyInfo(receiver, feeNumerator);
    }

    /**
     * @dev Resets royalty information for the token id back to the global default.
     */
    function _resetTokenRoyalty(uint256 tokenId) internal virtual {
        delete _tokenRoyaltyInfo[tokenId];
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.1) (token/ERC20/extensions/ERC4626.sol)

pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./SafeERC20.sol";
import "./IERC4626.sol";
import "./Math.sol";

/**
 * @dev Implementation of the ERC4626 "Tokenized Vault Standard" as defined in
 * https://eips.ethereum.org/EIPS/eip-4626[EIP-4626].
 *
 * This extension allows the minting and burning of "shares" (represented using the ERC20 inheritance) in exchange for
 * underlying "assets" through standardized {deposit}, {mint}, {redeem} and {burn} workflows. This contract extends
 * the ERC20 standard. Any additional extensions included along it would affect the "shares" token represented by this
 * contract and not the "assets" token which is an independent contract.
 *
 * [CAUTION]
 * ====
 * In empty (or nearly empty) ERC-4626 vaults, deposits are at high risk of being stolen through frontrunning
 * with a "donation" to the vault that inflates the price of a share. This is variously known as a donation or inflation
 * attack and is essentially a problem of slippage. Vault deployers can protect against this attack by making an initial
 * deposit of a non-trivial amount of the asset, such that price manipulation becomes infeasible. Withdrawals may
 * similarly be affected by slippage. Users can protect against this attack as well as unexpected slippage in general by
 * verifying the amount received is as expected, using a wrapper that performs these checks such as
 * https://github.com/fei-protocol/ERC4626#erc4626router-and-base[ERC4626Router].
 *
 * Since v4.9, this implementation uses virtual assets and shares to mitigate that risk. The `_decimalsOffset()`
 * corresponds to an offset in the decimal representation between the underlying asset's decimals and the vault
 * decimals. This offset also determines the rate of virtual shares to virtual assets in the vault, which itself
 * determines the initial exchange rate. While not fully preventing the attack, analysis shows that the default offset
 * (0) makes it non-profitable, as a result of the value being captured by the virtual shares (out of the attacker's
 * donation) matching the attacker's expected gains. With a larger offset, the attack becomes orders of magnitude more
 * expensive than it is profitable. More details about the underlying math can be found
 * xref:erc4626.adoc#inflation-attack[here].
 *
 * The drawback of this approach is that the virtual shares do capture (a very small) part of the value being accrued
 * to the vault. Also, if the vault experiences losses, the users try to exit the vault, the virtual shares and assets
 * will cause the first user to exit to experience reduced losses in detriment to the last users that will experience
 * bigger losses. Developers willing to revert back to the pre-v4.9 behavior just need to override the
 * `_convertToShares` and `_convertToAssets` functions.
 *
 * To learn more, check out our xref:ROOT:erc4626.adoc[ERC-4626 guide].
 * ====
 *
 * _Available since v4.7._
 */
abstract contract ERC4626 is ERC20, IERC4626 {
    using Math for uint256;

    IERC20 private immutable _asset;
    uint8 private immutable _underlyingDecimals;
    uint256 public totalBorrows;

    /**
     * @dev Set the underlying asset contract. This must be an ERC20-compatible contract (ERC20 or ERC777).
     */
    constructor(IERC20 asset_, string memory _name, string memory _symbol) ERC20(_name, _symbol, 18){
        (bool success, uint8 assetDecimals) = _tryGetAssetDecimals(asset_);
        _underlyingDecimals = success ? assetDecimals : 18;
        _asset = asset_;
    }

    /**
     * @dev Attempts to fetch the asset decimals. A return value of false indicates that the attempt failed in some way.
     */
    function _tryGetAssetDecimals(IERC20 asset_) private view returns (bool, uint8) {
        (bool success, bytes memory encodedDecimals) = address(asset_).staticcall(
            abi.encodeWithSelector(IERC20Metadata.decimals.selector)
        );
        if (success && encodedDecimals.length >= 32) {
            uint256 returnedDecimals = abi.decode(encodedDecimals, (uint256));
            if (returnedDecimals <= type(uint8).max) {
                return (true, uint8(returnedDecimals));
            }
        }
        return (false, 0);
    }

    /**
     * @dev Decimals are computed by adding the decimal offset on top of the underlying asset's decimals. This
     * "original" value is cached during construction of the vault contract. If this read operation fails (e.g., the
     * asset has not been created yet), a default of 18 is used to represent the underlying asset's decimals.
     *
     * See {IERC20Metadata-decimals}.
     */
    function decimals() public view virtual override(IERC20Metadata, IERC20, ERC20) returns (uint8) {
        return _underlyingDecimals + _decimalsOffset();
    }

    /** @dev See {IERC4626-asset}. */
    function asset() public view virtual override returns (address) {
        return address(_asset);
    }

    /** @dev See {IERC4626-totalAssets}. */
    function totalAssets() public view virtual override returns (uint256) {
        return _asset.balanceOf(address(this)) + totalBorrows;
    }

    /** @dev See {IERC4626-convertToShares}. */
    function convertToShares(uint256 assets) public view virtual override returns (uint256) {
        return _convertToShares(assets, Math.Rounding.Down);
    }

    /** @dev See {IERC4626-convertToAssets}. */
    function convertToAssets(uint256 shares) public view virtual override returns (uint256) {
        return _convertToAssets(shares, Math.Rounding.Down);
    }

    /** @dev See {IERC4626-maxDeposit}. */
    function maxDeposit(address) public view virtual override returns (uint256) {
        return type(uint256).max;
    }

    /** @dev See {IERC4626-maxMint}. */
    function maxMint(address) public view virtual override returns (uint256) {
        return type(uint256).max;
    }

    /** @dev See {IERC4626-maxWithdraw}. */
    function maxWithdraw(address owner) public view virtual override returns (uint256) {
        return _convertToAssets(balanceOf(owner), Math.Rounding.Down);
    }

    /** @dev See {IERC4626-maxRedeem}. */
    function maxRedeem(address owner) public view virtual override returns (uint256) {
        return balanceOf(owner);
    }

    /** @dev See {IERC4626-previewDeposit}. */
    function previewDeposit(uint256 assets) public view virtual override returns (uint256) {
        return _convertToShares(assets, Math.Rounding.Down);
    }

    /** @dev See {IERC4626-previewMint}. */
    function previewMint(uint256 shares) public view virtual override returns (uint256) {
        return _convertToAssets(shares, Math.Rounding.Up);
    }

    /** @dev See {IERC4626-previewWithdraw}. */
    function previewWithdraw(uint256 assets) public view virtual override returns (uint256) {
        return _convertToShares(assets, Math.Rounding.Up);
    }

    /** @dev See {IERC4626-previewRedeem}. */
    function previewRedeem(uint256 shares) public view virtual override returns (uint256) {
        return _convertToAssets(shares, Math.Rounding.Down);
    }

    /** @dev See {IERC4626-deposit}. */
    function deposit(uint256 assets, address receiver) public virtual override returns (uint256) {
        require(assets <= maxDeposit(receiver), "ERC4626: deposit more than max");

        uint256 shares = previewDeposit(assets);
        _deposit(_msgSender(), receiver, assets, shares);

        return shares;
    }

    /** @dev See {IERC4626-mint}.
     *
     * As opposed to {deposit}, minting is allowed even if the vault is in a state where the price of a share is zero.
     * In this case, the shares will be minted without requiring any assets to be deposited.
     */
    function mint(uint256 shares, address receiver) public virtual override returns (uint256) {
        require(shares <= maxMint(receiver), "ERC4626: mint more than max");

        uint256 assets = previewMint(shares);
        _deposit(_msgSender(), receiver, assets, shares);

        return assets;
    }

    /** @dev See {IERC4626-withdraw}. */
    function withdraw(uint256 assets, address receiver, address owner) public virtual override returns (uint256) {
        require(assets <= maxWithdraw(owner), "ERC4626: withdraw more than max");

        uint256 shares = previewWithdraw(assets);
        _withdraw(_msgSender(), receiver, owner, assets, shares);

        return shares;
    }

    /** @dev See {IERC4626-redeem}. */
    function redeem(uint256 shares, address receiver, address owner) public virtual override returns (uint256) {
        require(shares <= maxRedeem(owner), "ERC4626: redeem more than max");

        uint256 assets = previewRedeem(shares);
        _withdraw(_msgSender(), receiver, owner, assets, shares);

        return assets;
    }

    /**
     * @dev Internal conversion function (from assets to shares) with support for rounding direction.
     */
    function _convertToShares(uint256 assets, Math.Rounding rounding) internal view virtual returns (uint256) {
        return assets.mulDiv(totalSupply() + 10 ** _decimalsOffset(), totalAssets() + 1, rounding);
    }

    /**
     * @dev Internal conversion function (from shares to assets) with support for rounding direction.
     */
    function _convertToAssets(uint256 shares, Math.Rounding rounding) internal view virtual returns (uint256) {
        return shares.mulDiv(totalAssets() + 1, totalSupply() + 10 ** _decimalsOffset(), rounding);
    }

    /**
     * @dev Deposit/mint common workflow.
     */
    function _deposit(address caller, address receiver, uint256 assets, uint256 shares) internal virtual {
        // If _asset is ERC777, `transferFrom` can trigger a reentrancy BEFORE the transfer happens through the
        // `tokensToSend` hook. On the other hand, the `tokenReceived` hook, that is triggered after the transfer,
        // calls the vault, which is assumed not malicious.
        //
        // Conclusion: we need to do the transfer before we mint so that any reentrancy would happen before the
        // assets are transferred and before the shares are minted, which is a valid state.
        // slither-disable-next-line reentrancy-no-eth
        SafeERC20.safeTransferFrom(_asset, caller, address(this), assets);
        _mint(receiver, shares);

        emit Deposit(caller, receiver, assets, shares);
    }

    /**
     * @dev Withdraw/redeem common workflow.
     */
    function _withdraw(
        address caller,
        address receiver,
        address owner,
        uint256 assets,
        uint256 shares
    ) internal virtual {
        if (caller != owner) {
            _spendAllowance(owner, caller, shares);
        }

        // If _asset is ERC777, `transfer` can trigger a reentrancy AFTER the transfer happens through the
        // `tokensReceived` hook. On the other hand, the `tokensToSend` hook, that is triggered before the transfer,
        // calls the vault, which is assumed not malicious.
        //
        // Conclusion: we need to do the transfer after the burn so that any reentrancy would happen after the
        // shares are burned and after the assets are transferred, which is a valid state.
        _burn(owner, shares);
        SafeERC20.safeTransfer(_asset, receiver, assets);

        emit Withdraw(caller, receiver, owner, assets, shares);
    }

    function _decimalsOffset() internal view virtual returns (uint8) {
        return 0;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./IERC721Metadata.sol";
import "./Address.sol";
import "./Context.sol";
import "./Strings.sol";
import "./ERC165.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    //Base URI
    string private _baseURI;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Optional mapping for token URIs
    mapping (uint256 => string) private _tokenURIs;

    //Mapping of tokenId to seatScore;
    mapping(uint256 => uint256) seatScore;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _ownerOf(tokenId);
        require(owner != address(0), "ERC721: invalid token ID");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }
        // If there is a baseURI but no tokenURI, concatenate the seatScore to the baseURI.
        string memory seatURI = string.concat(seatScore[tokenId].toString(), ".json");
        return string(abi.encodePacked(base, seatURI));
    }

    /**
    * @dev Returns the base URI set via {_setBaseURI}. This will be
    * automatically added as a prefix in {tokenURI} to each token's URI, or
    * to the token ID if no specific URI is set for that token ID.
    */
    function baseURI() public view virtual returns (string memory) {
        return _baseURI;
    }


    function _setBaseURI(string memory baseURI_) internal virtual {
        _baseURI = baseURI_;
    }


    /**
     * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not token owner or approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        _requireMinted(tokenId);

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");
        _safeTransfer(from, to, tokenId, data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns the owner of the `tokenId`. Does NOT revert if token doesn't exist
     */
    function _ownerOf(uint256 tokenId) internal view virtual returns (address) {
        return _owners[tokenId];
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(address to, uint256 tokenId, bytes memory data) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId, 1);

        // Check that tokenId was not minted by `_beforeTokenTransfer` hook
        require(!_exists(tokenId), "ERC721: token already minted");

        unchecked {
            // Will not overflow unless all 2**256 token ids are minted to the same owner.
            // Given that tokens are minted one by one, it is impossible in practice that
            // this ever happens. Might change if we allow batch minting.
            // The ERC fails to describe this case.
            _balances[to] += 1;
        }

        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId, 1);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     * This is an internal function that does not check if the sender is authorized to operate on the token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId, 1);

        // Update ownership in case tokenId was transferred by `_beforeTokenTransfer` hook
        owner = ERC721.ownerOf(tokenId);

        // Clear approvals
        delete _tokenApprovals[tokenId];

                // Clear metadata (if any)
        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }

        unchecked {
            // Cannot overflow, as that would require more tokens to be burned/transferred
            // out than the owner initially received through minting and transferring in.
            _balances[owner] -= 1;
        }
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId, 1);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId, 1);

        // Check that tokenId was not transferred by `_beforeTokenTransfer` hook
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");

        // Clear approvals from the previous owner
        delete _tokenApprovals[tokenId];

        unchecked {
            // `_balances[from]` cannot overflow for the same reason as described in `_burn`:
            // `from`'s balance is the number of token held, which is at least one before the current
            // transfer.
            // `_balances[to]` could overflow in the conditions described in `_mint`. That would require
            // all 2**256 token ids to be minted, which in practice is impossible.
            _balances[from] -= 1;
            _balances[to] += 1;
        }
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId, 1);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits an {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
     */
    function _setApprovalForAll(address owner, address operator, bool approved) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Reverts if the `tokenId` has not been minted yet.
     */
    function _requireMinted(uint256 tokenId) internal view virtual {
        require(_exists(tokenId), "ERC721: invalid token ID");
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting and burning. If {ERC721Consecutive} is
     * used, the hook may be called as part of a consecutive (batch) mint, as indicated by `batchSize` greater than 1.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s tokens will be transferred to `to`.
     * - When `from` is zero, the tokens will be minted for `to`.
     * - When `to` is zero, ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     * - `batchSize` is non-zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 /* firstTokenId */,
        uint256 batchSize
    ) internal virtual {
        if (batchSize > 1) {
            if (from != address(0)) {
                _balances[from] -= batchSize;
            }
            if (to != address(0)) {
                _balances[to] += batchSize;
            }
        }
    }

    /**
     * @dev Hook that is called after any token transfer. This includes minting and burning. If {ERC721Consecutive} is
     * used, the hook may be called as part of a consecutive (batch) mint, as indicated by `batchSize` greater than 1.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s tokens were transferred to `to`.
     * - When `from` is zero, the tokens were minted for `to`.
     * - When `to` is zero, ``from``'s tokens were burned.
     * - `from` and `to` are never both zero.
     * - `batchSize` is non-zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(address from, address to, uint256 firstTokenId, uint256 batchSize) internal virtual {}
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/extensions/ERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "./ERC721.sol";
import "./IERC721Enumerable.sol";

/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */
abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    /**
     * @dev See {ERC721-_beforeTokenTransfer}.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);

        if (batchSize > 1) {
            // Will only trigger during construction. Batch transferring (minting) is not available afterwards.
            revert("ERC721Enumerable: consecutive transfers not supported");
        }

        uint256 tokenId = firstTokenId;

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
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
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function decimals() external view returns (uint8);

}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (interfaces/IERC2981.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Interface for the NFT Royalty Standard.
 *
 * A standardized way to retrieve royalty payment information for non-fungible tokens (NFTs) to enable universal
 * support for royalty payments across all NFT marketplaces and ecosystem participants.
 *
 * _Available since v4.5._
 */
interface IERC2981 is IERC165 {
    /**
     * @dev Returns how much royalty is owed and to whom, based on a sale price that may be denominated in any unit of
     * exchange. The royalty amount is denominated and should be paid in that same unit of exchange.
     */
    function royaltyInfo(
        uint256 tokenId,
        uint256 salePrice
    ) external view returns (address receiver, uint256 royaltyAmount);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (interfaces/IERC4626.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./IERC20Metadata.sol";

/**
 * @dev Interface of the ERC4626 "Tokenized Vault Standard", as defined in
 * https://eips.ethereum.org/EIPS/eip-4626[ERC-4626].
 *
 * _Available since v4.7._
 */
interface IERC4626 is IERC20, IERC20Metadata {
    event Deposit(address indexed sender, address indexed owner, uint256 assets, uint256 shares);

    event Withdraw(
        address indexed sender,
        address indexed receiver,
        address indexed owner,
        uint256 assets,
        uint256 shares
    );

    /**
     * @dev Returns the address of the underlying token used for the Vault for accounting, depositing, and withdrawing.
     *
     * - MUST be an ERC-20 token contract.
     * - MUST NOT revert.
     */
    function asset() external view returns (address assetTokenAddress);

    /**
     * @dev Returns the total amount of the underlying asset that is “managed” by Vault.
     *
     * - SHOULD include any compounding that occurs from yield.
     * - MUST be inclusive of any fees that are charged against assets in the Vault.
     * - MUST NOT revert.
     */
    function totalAssets() external view returns (uint256 totalManagedAssets);

    /**
     * @dev Returns the amount of shares that the Vault would exchange for the amount of assets provided, in an ideal
     * scenario where all the conditions are met.
     *
     * - MUST NOT be inclusive of any fees that are charged against assets in the Vault.
     * - MUST NOT show any variations depending on the caller.
     * - MUST NOT reflect slippage or other on-chain conditions, when performing the actual exchange.
     * - MUST NOT revert.
     *
     * NOTE: This calculation MAY NOT reflect the “per-user” price-per-share, and instead should reflect the
     * “average-user’s” price-per-share, meaning what the average user should expect to see when exchanging to and
     * from.
     */
    function convertToShares(uint256 assets) external view returns (uint256 shares);

    /**
     * @dev Returns the amount of assets that the Vault would exchange for the amount of shares provided, in an ideal
     * scenario where all the conditions are met.
     *
     * - MUST NOT be inclusive of any fees that are charged against assets in the Vault.
     * - MUST NOT show any variations depending on the caller.
     * - MUST NOT reflect slippage or other on-chain conditions, when performing the actual exchange.
     * - MUST NOT revert.
     *
     * NOTE: This calculation MAY NOT reflect the “per-user” price-per-share, and instead should reflect the
     * “average-user’s” price-per-share, meaning what the average user should expect to see when exchanging to and
     * from.
     */
    function convertToAssets(uint256 shares) external view returns (uint256 assets);

    /**
     * @dev Returns the maximum amount of the underlying asset that can be deposited into the Vault for the receiver,
     * through a deposit call.
     *
     * - MUST return a limited value if receiver is subject to some deposit limit.
     * - MUST return 2 ** 256 - 1 if there is no limit on the maximum amount of assets that may be deposited.
     * - MUST NOT revert.
     */
    function maxDeposit(address receiver) external view returns (uint256 maxAssets);

    /**
     * @dev Allows an on-chain or off-chain user to simulate the effects of their deposit at the current block, given
     * current on-chain conditions.
     *
     * - MUST return as close to and no more than the exact amount of Vault shares that would be minted in a deposit
     *   call in the same transaction. I.e. deposit should return the same or more shares as previewDeposit if called
     *   in the same transaction.
     * - MUST NOT account for deposit limits like those returned from maxDeposit and should always act as though the
     *   deposit would be accepted, regardless if the user has enough tokens approved, etc.
     * - MUST be inclusive of deposit fees. Integrators should be aware of the existence of deposit fees.
     * - MUST NOT revert.
     *
     * NOTE: any unfavorable discrepancy between convertToShares and previewDeposit SHOULD be considered slippage in
     * share price or some other type of condition, meaning the depositor will lose assets by depositing.
     */
    function previewDeposit(uint256 assets) external view returns (uint256 shares);

    /**
     * @dev Mints shares Vault shares to receiver by depositing exactly amount of underlying tokens.
     *
     * - MUST emit the Deposit event.
     * - MAY support an additional flow in which the underlying tokens are owned by the Vault contract before the
     *   deposit execution, and are accounted for during deposit.
     * - MUST revert if all of assets cannot be deposited (due to deposit limit being reached, slippage, the user not
     *   approving enough underlying tokens to the Vault contract, etc).
     *
     * NOTE: most implementations will require pre-approval of the Vault with the Vault’s underlying asset token.
     */
    function deposit(uint256 assets, address receiver) external returns (uint256 shares);

    /**
     * @dev Returns the maximum amount of the Vault shares that can be minted for the receiver, through a mint call.
     * - MUST return a limited value if receiver is subject to some mint limit.
     * - MUST return 2 ** 256 - 1 if there is no limit on the maximum amount of shares that may be minted.
     * - MUST NOT revert.
     */
    function maxMint(address receiver) external view returns (uint256 maxShares);

    /**
     * @dev Allows an on-chain or off-chain user to simulate the effects of their mint at the current block, given
     * current on-chain conditions.
     *
     * - MUST return as close to and no fewer than the exact amount of assets that would be deposited in a mint call
     *   in the same transaction. I.e. mint should return the same or fewer assets as previewMint if called in the
     *   same transaction.
     * - MUST NOT account for mint limits like those returned from maxMint and should always act as though the mint
     *   would be accepted, regardless if the user has enough tokens approved, etc.
     * - MUST be inclusive of deposit fees. Integrators should be aware of the existence of deposit fees.
     * - MUST NOT revert.
     *
     * NOTE: any unfavorable discrepancy between convertToAssets and previewMint SHOULD be considered slippage in
     * share price or some other type of condition, meaning the depositor will lose assets by minting.
     */
    function previewMint(uint256 shares) external view returns (uint256 assets);

    /**
     * @dev Mints exactly shares Vault shares to receiver by depositing amount of underlying tokens.
     *
     * - MUST emit the Deposit event.
     * - MAY support an additional flow in which the underlying tokens are owned by the Vault contract before the mint
     *   execution, and are accounted for during mint.
     * - MUST revert if all of shares cannot be minted (due to deposit limit being reached, slippage, the user not
     *   approving enough underlying tokens to the Vault contract, etc).
     *
     * NOTE: most implementations will require pre-approval of the Vault with the Vault’s underlying asset token.
     */
    function mint(uint256 shares, address receiver) external returns (uint256 assets);

    /**
     * @dev Returns the maximum amount of the underlying asset that can be withdrawn from the owner balance in the
     * Vault, through a withdraw call.
     *
     * - MUST return a limited value if owner is subject to some withdrawal limit or timelock.
     * - MUST NOT revert.
     */
    function maxWithdraw(address owner) external view returns (uint256 maxAssets);

    /**
     * @dev Allows an on-chain or off-chain user to simulate the effects of their withdrawal at the current block,
     * given current on-chain conditions.
     *
     * - MUST return as close to and no fewer than the exact amount of Vault shares that would be burned in a withdraw
     *   call in the same transaction. I.e. withdraw should return the same or fewer shares as previewWithdraw if
     *   called
     *   in the same transaction.
     * - MUST NOT account for withdrawal limits like those returned from maxWithdraw and should always act as though
     *   the withdrawal would be accepted, regardless if the user has enough shares, etc.
     * - MUST be inclusive of withdrawal fees. Integrators should be aware of the existence of withdrawal fees.
     * - MUST NOT revert.
     *
     * NOTE: any unfavorable discrepancy between convertToShares and previewWithdraw SHOULD be considered slippage in
     * share price or some other type of condition, meaning the depositor will lose assets by depositing.
     */
    function previewWithdraw(uint256 assets) external view returns (uint256 shares);

    /**
     * @dev Burns shares from owner and sends exactly assets of underlying tokens to receiver.
     *
     * - MUST emit the Withdraw event.
     * - MAY support an additional flow in which the underlying tokens are owned by the Vault contract before the
     *   withdraw execution, and are accounted for during withdraw.
     * - MUST revert if all of assets cannot be withdrawn (due to withdrawal limit being reached, slippage, the owner
     *   not having enough shares, etc).
     *
     * Note that some implementations will require pre-requesting to the Vault before a withdrawal may be performed.
     * Those methods should be performed separately.
     */
    function withdraw(uint256 assets, address receiver, address owner) external returns (uint256 shares);

    /**
     * @dev Returns the maximum amount of Vault shares that can be redeemed from the owner balance in the Vault,
     * through a redeem call.
     *
     * - MUST return a limited value if owner is subject to some withdrawal limit or timelock.
     * - MUST return balanceOf(owner) if owner is not subject to any withdrawal limit or timelock.
     * - MUST NOT revert.
     */
    function maxRedeem(address owner) external view returns (uint256 maxShares);

    /**
     * @dev Allows an on-chain or off-chain user to simulate the effects of their redeemption at the current block,
     * given current on-chain conditions.
     *
     * - MUST return as close to and no more than the exact amount of assets that would be withdrawn in a redeem call
     *   in the same transaction. I.e. redeem should return the same or more assets as previewRedeem if called in the
     *   same transaction.
     * - MUST NOT account for redemption limits like those returned from maxRedeem and should always act as though the
     *   redemption would be accepted, regardless if the user has enough shares, etc.
     * - MUST be inclusive of withdrawal fees. Integrators should be aware of the existence of withdrawal fees.
     * - MUST NOT revert.
     *
     * NOTE: any unfavorable discrepancy between convertToAssets and previewRedeem SHOULD be considered slippage in
     * share price or some other type of condition, meaning the depositor will lose assets by redeeming.
     */
    function previewRedeem(uint256 shares) external view returns (uint256 assets);

    /**
     * @dev Burns exactly shares from owner and sends assets of underlying tokens to receiver.
     *
     * - MUST emit the Withdraw event.
     * - MAY support an additional flow in which the underlying tokens are owned by the Vault contract before the
     *   redeem execution, and are accounted for during redeem.
     * - MUST revert if all of shares cannot be redeemed (due to withdrawal limit being reached, slippage, the owner
     *   not having enough shares, etc).
     *
     * NOTE: some implementations will require pre-requesting to the Vault before a withdrawal may be performed.
     * Those methods should be performed separately.
     */
    function redeem(uint256 shares, address receiver, address owner) external returns (uint256 assets);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

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
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
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
     * - The `operator` cannot be the caller.
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "./IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "./IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
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
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

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
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
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
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "./AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1, "Math: mulDiv overflow");

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10**64) {
                value /= 10**64;
                result += 64;
            }
            if (value >= 10**32) {
                value /= 10**32;
                result += 32;
            }
            if (value >= 10**16) {
                value /= 10**16;
                result += 16;
            }
            if (value >= 10**8) {
                value /= 10**8;
                result += 8;
            }
            if (value >= 10**4) {
                value /= 10**4;
                result += 4;
            }
            if (value >= 10**2) {
                value /= 10**2;
                result += 2;
            }
            if (value >= 10**1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10**result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result << 3) < value ? 1 : 0);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "./Context.sol";

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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "./Initializable.sol";

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
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./IERC20Permit.sol";
import "./Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/SignedMath.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard signed math utilities missing in the Solidity language.
 */
library SignedMath {
    /**
     * @dev Returns the largest of two signed numbers.
     */
    function max(int256 a, int256 b) internal pure returns (int256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two signed numbers.
     */
    function min(int256 a, int256 b) internal pure returns (int256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two signed numbers without overflow.
     * The result is rounded towards zero.
     */
    function average(int256 a, int256 b) internal pure returns (int256) {
        // Formula from the book "Hacker's Delight"
        int256 x = (a & b) + ((a ^ b) >> 1);
        return x + (int256(uint256(x) >> 255) & (a ^ b));
    }

    /**
     * @dev Returns the absolute unsigned value of a signed value.
     */
    function abs(int256 n) internal pure returns (uint256) {
        unchecked {
            // must be unchecked in order to support `n = type(int256).min`
            return uint256(n >= 0 ? n : -n);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

import "./Math.sol";
import "./SignedMath.sol";

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `int256` to its ASCII `string` decimal representation.
     */
    function toString(int256 value) internal pure returns (string memory) {
        return string(abi.encodePacked(value < 0 ? "-" : "", toString(SignedMath.abs(value))));
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }

    /**
     * @dev Returns true if the two strings are equal.
     */
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }
}
// SPDX-License-Identifier: UNLICENSED
/**                           
        /@#(@@@@@              
       @@      @@@             
        @@                      
        .@@@#                  
        ##@@@@@@,              
      @@@      /@@@&            
    .@@@  @   @  @@@@           
    @@@@  @@@@@  @@@@           
    @@@@  @   @  @@@/           
     @@@@       @@@             
       (@@@@#@@@      
    THE AORI PROTOCOL                           
 */
pragma solidity ^0.8.13;

import "./OpenZeppelin/Ownable.sol";
import "./AoriSeats.sol";
import "./Bid.sol";
import "./Ask.sol";
import "./AoriCall.sol";

contract Orderbook is Ownable {
    address public ORDERBOOKFACTORY;
    AoriSeats public immutable AORISEATSADD;

    IERC20 public immutable OPTION;
    IERC20 public immutable USDC;
    uint256 public immutable fee_; //In BPS
    uint256 public duration;
    uint256 public endingTime;
    Ask[] public asks;
    Bid[] public bids;
    mapping(address => bool) isAsk;
    mapping(address => bool) isBid;

    constructor(
        uint256 _fee,
        IERC20 _OPTION,
        IERC20 _USDC,
        AoriSeats _AORISEATSADD,
        uint256 _duration
    ) {
        ORDERBOOKFACTORY = msg.sender;
        duration = _duration;
        endingTime = block.timestamp + duration;
        AORISEATSADD = _AORISEATSADD;
        OPTION = _OPTION;
        USDC = _USDC;
        fee_ = _fee;
    }

    event AskCreated(address ask, uint256 , uint256 duration, uint256 OPTIONSize);
    event BidCreated(address bid, uint256 , uint256 duration, uint256 _USDCSize);
    /**
        Deploys an Ask.sol with the following parameters.    
     */
    function createAsk(uint256 _USDCPerOPTION, uint256 _duration, uint256 _OPTIONSize) public returns (Ask) {
        Ask ask = new Ask(OPTION, USDC, AORISEATSADD, msg.sender, _USDCPerOPTION, fee_, AoriSeats(AORISEATSADD).getFeeMultiplier() , _duration, _OPTIONSize);
        asks.push(ask);
        //transfer before storing the results
        OPTION.transferFrom(msg.sender, address(ask), _OPTIONSize);
        //storage
        isAsk[address(ask)] = true;
        ask.fundContract();
        emit AskCreated(address(ask), _USDCPerOPTION, _duration, _OPTIONSize);
        return ask;
    }
    /**
        Deploys an Bid.sol with the following parameters.    
     */
    function createBid(uint256 _OPTIONPerUSDC, uint256 _duration, uint256 _USDCSize) public returns (Bid) {
        Bid bid = new Bid(USDC, OPTION, AORISEATSADD, msg.sender, _OPTIONPerUSDC, fee_, AoriSeats(AORISEATSADD).getFeeMultiplier() , _duration, _USDCSize);
        bids.push(bid);
        //transfer before storing the results
        USDC.transferFrom(msg.sender, address(bid), _USDCSize);
        //storage
        isBid[address(bid)] = true;
        bid.fundContract();
        emit BidCreated(address(bid), _OPTIONPerUSDC, _duration, _USDCSize);
        return bid;
    }

    /**
        Accessory view functions to get data about active bids and asks of this orderbook
     */

    function getActiveAsks() external view returns (Ask[] memory) {
        Ask[] memory activeAsks = new Ask[](asks.length);
        uint256 count;
        for (uint256 i; i < asks.length; i++) {
            Ask ask = Ask(asks[i]);
            if (ask.isFunded() && !ask.hasEnded() && address(ask) != address(0)) {
                activeAsks[count++] = ask;
            }
        }

        return activeAsks;
    }
    
    function getActiveBids() external view returns (Bid[] memory) {
        Bid[] memory activeBids = new Bid[](bids.length);
        uint256 count;
        for (uint256 i; i < bids.length; i++) {
            Bid bid = Bid(bids[i]);
            if (bid.isFunded() && !bid.hasEnded() && address(bid) != address(0)) {
                activeBids[count++] = bid;
            }
        }

        return activeBids;
    }

    function getIsAsk(address ask) external view returns (bool) {
        return isAsk[ask];
    }
    
    function getIsBid(address bid) external view returns (bool) {
        return isBid[bid];
    }

    function UNDERLYING(bool isCall) external view returns (address) {
        if(isCall) {
            return address(AoriCall(address(OPTION)).UNDERLYING());
        } else {
            return address(USDC);
        }
    }
}
// SPDX-License-Identifier: UNLICENSED
/**                           
        /@#(@@@@@              
       @@      @@@             
        @@                      
        .@@@#                  
        ##@@@@@@,              
      @@@      /@@@&            
    .@@@  @   @  @@@@           
    @@@@  @@@@@  @@@@           
    @@@@  @   @  @@@/           
     @@@@       @@@             
       (@@@@#@@@      
    THE AORI PROTOCOL                           
 */
pragma solidity ^0.8.19;

import "./OpenZeppelin/Ownable.sol";
import "./AoriSeats.sol";
import "./OpenZeppelin/IERC20.sol";
import "./Orderbook.sol";

contract OrderbookFactory is Ownable {

    mapping(address => bool) isListedOrderbook;
    Orderbook[] public orderbookAdds;
    address public keeper;
    AoriSeats public AORISEATSADD;
    
    constructor(AoriSeats _AORISEATSADD) {
        AORISEATSADD = _AORISEATSADD;
    }

    event AoriOrderbookCreated(
        address AoriCallMarketAdd,
        uint256 fee,
        IERC20 underlyingAsset
    );

    /**
        Set the keeper of the Optiontroller.
        The keeper controls and deploys all new markets and orderbooks.
    */
    function setKeeper(address newKeeper) external onlyOwner returns(address) {
        keeper = newKeeper;
        return keeper;
    }
    
    function setAORISEATSADD(AoriSeats newAORISEATSADD) external onlyOwner returns(AoriSeats) {
        AORISEATSADD = newAORISEATSADD;
        return AORISEATSADD;
    }
    /**
        Gets the trading fee for the protocol.
     */
    function getTradingFee() internal view returns(uint256) {
        return AORISEATSADD.getTradingFee();
    }
    
    /**
        Deploys a new call option token at a designated strike and maturation block.
        Additionally deploys an orderbook to pair with the new ERC20 option token.
    */
    function createOrderbook(
            IERC20 OPTION_,
            IERC20 USDC,
            uint256 _duration
            ) public returns (Orderbook) {

        require(msg.sender == keeper);

        Orderbook orderbook =  new Orderbook(getTradingFee(), OPTION_, USDC, AORISEATSADD, _duration); 
        
        isListedOrderbook[address(orderbook)] = true;
        orderbookAdds.push(orderbook);

        emit AoriOrderbookCreated(address(orderbook), getTradingFee(), OPTION_);
        return (orderbook);
    }

    //Checks if an individual Orderbook is listed
    function checkIsListedOrderbook(address Orderbook_) public view returns(bool) {
        return isListedOrderbook[Orderbook_];
    }
    //Confirms for points that the Orderbook is a listed orderbook, THEN that the order is a listed order.
    function checkIsOrder(address Orderbook_, address order_) public view returns(bool) {
        require(checkIsListedOrderbook(Orderbook_), "Orderbook is not listed"); 
        require(Orderbook(Orderbook_).getIsBid(order_) == true || Orderbook(Orderbook_).getIsAsk(order_) == true, "Is not a confirmed order");

        return true;
    }

    function withdrawFees(IERC20 token, uint256 amount_) external onlyOwner returns(uint256) {
            IERC20(token).transfer(owner(), amount_);
            return amount_;
    }
    
    function getAllOrderbooks() external view returns(Orderbook[] memory) {
        return orderbookAdds;
    }
}
// SPDX-License-Identifier: UNLICENSED
/**                           
        /@#(@@@@@              
       @@      @@@             
        @@                      
        .@@@#                  
        ##@@@@@@,              
      @@@      /@@@&            
    .@@@  @   @  @@@@           
    @@@@  @@@@@  @@@@           
    @@@@  @   @  @@@/           
     @@@@       @@@             
       (@@@@#@@@      
    THE AORI PROTOCOL                           
 */
pragma solidity 0.8.19;

import "./OpenZeppelin/Ownable.sol";
import "./AoriSeats.sol";
import "./AoriPut.sol";
import "./OpenZeppelin/IERC20.sol";
import "./Margin/MarginManager.sol";

contract PutFactory is Ownable {

    mapping(address => bool) isListed;
    AoriPut[] putMarkets;
    address public keeper;
    uint256 public fee;
    AoriSeats public AORISEATSADD;
    MarginManager public manager;
    
    constructor(AoriSeats _AORISEATSADD, MarginManager _manager) {
        AORISEATSADD = _AORISEATSADD;
        manager = _manager;
    }

    event AoriPutCreated(
            IERC20 AoriPutAdd,
            uint256 strike, 
            uint256 duration, 
            IERC20 USDC,
            address oracle, 
            string name, 
            string symbol
        );

    /**
        Set the keeper of the Optiontroller.
        The keeper controls and deploys all new markets and orderbooks.
    */
    function setKeeper(address newKeeper) public onlyOwner returns(address) {
        keeper = newKeeper;
        return newKeeper;
    }

    function setAORISEATSADD(AoriSeats newAORISEATSADD) external onlyOwner returns(AoriSeats) {
        AORISEATSADD = newAORISEATSADD;
        return AORISEATSADD;
    }

    /**
        Deploys a new put option token at a designated strike and maturation block.
        Additionally deploys an orderbook to pair with the new ERC20 option token.
    */
    
    function createPutMarket(
            uint256 strikeInUSDC, 
            uint256 duration, 
            IERC20 USDC,
            IERC20 UNDERLYING,
            address oracle,
            string memory name_, 
            string memory symbol_
            ) public returns (AoriPut) {

        require(msg.sender == keeper);

        AoriPut putMarket = new AoriPut(address(manager), AoriSeats(AORISEATSADD).getFeeMultiplier(), strikeInUSDC, duration, USDC, UNDERLYING, oracle, AoriSeats(AORISEATSADD), name_, symbol_);

        isListed[address(putMarket)] = true;
        putMarkets.push(putMarket);

        emit AoriPutCreated(IERC20(address(putMarket)), strikeInUSDC, duration, USDC, oracle, name_, symbol_);
        return (putMarket);
    }

    //Checks if an individual Call/Put is listed
    function checkIsListed(address market) public view returns(bool) {
        return isListed[market];
    }
    
    function getAORISEATSADD() external view returns(AoriSeats) {
        return AORISEATSADD;
    }
    
    function getAllPutMarkets() external view returns(AoriPut[] memory) {
        return putMarkets;
    }
}