// SPDX-License-Identifier: UNLICENSED

// DEV-Telegram: @DevOctahedron


pragma solidity ^0.8.0;


interface IERC20 {
  function transfer(address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value) external returns (bool);
  function transferFrom(address from, address to, uint256 value) external returns (bool);
  function totalSupply() external view returns (uint256);
  function balanceOf(address account) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function decimals() external view returns (uint8);
  function burn(uint256 amount) external;
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


interface IPancakeRouter01 {
    function factory () external pure returns (address);
    function WETH () external pure returns (address);
    function WPLS () external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

pragma solidity >=0.6.2;

interface IRouter is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

pragma solidity >=0.6.2;

interface IFactory {
function getPair (address token1, address token2) external pure returns (address);
}




// DEV-Telegram: @DevOctahedron 

// contract for a 30 day auction token auctoon with:
//  - users acution token being vested after claim of auction shares



contract SpecialTitanXAuction {

    using SafeMath for uint256;

    string  public constant name = "10dayAuctionTest-TitanX";
    string  public constant symbol = "10DTX";
    uint256 public constant decimals = 18;

    address payable public _dev = payable (0x54Bb21ad10571d97fDb926E4c90bc5fC2a6B1101); // receives shares of teh depositToken and can set all the onlyDev functions
    address public _dev1 =  0x2096aFDaA68EEaE1EbF95DFdf565eE6d9B1fbA37; // additional setter for onlyDev functions for testing
    address public _feeRecipient = 0x54Bb21ad10571d97fDb926E4c90bc5fC2a6B1101; // receives the Transfer Tax

    address public _routerAddr = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;  // ETH uniswap V2 also testnet: 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D 
    IRouter public _router = IRouter(_routerAddr);

    address public depositToken = 0xF19308F923582A6f7c465e5CE7a9Dc1BEC6665B1; // TitanX on Etherscan

    uint256 public percentToReceiveAfterTax = 100; // 99 equals 1% tax, 98 = 2% tax and so on ...

    address public contrAddr;

    uint256 public overallVestedToken;
    uint256 public overallCollectedEarnings;

    /* Auction specifics */
    uint256 public LAUNCH_TIME = 1729533600;  // TODO   
    uint256 public currentDay;
    uint256 public oneDay = 1 days; //  // TODO ******************** set for tests, later: 1 days
    uint256 public auctionPeriod = 10 * oneDay; // TODO number of real days ************ set for tests
    uint32  public offDays; // stored as "real" days, not seconds,  ( 1 = 1 day) 

    bool    public isAuctionActive = true;
    uint256 public lastAuctionPauseTime = 0;
    uint256 public lastAuctionUnpauseTime = 0;
    uint256 public totalPauseTimeCounter;
    bool    public pausabilityPermanentlyDisabled = false;
    // this token/wei amount need to be accounted per second to have 1 ETH per day
    uint256 private weiPerSfor1perDay = 11574074074074;  
    // Token available per auction day // TODO
    uint256 private dayliAvailableToken = 77777777 ether; //  77.777777 Million


    event Transfer( address indexed from, address indexed to, uint256 value );
    event Approval( address indexed owner, address indexed spender, uint256 value );
    event ChangeSharesToToken ( address indexed user, uint256 aountShares, uint256 amountToken);
    event Vest( address indexed user, uint256 vestAmount, uint256 _vestIndex, uint256 vestTime );
    event EnterAuction ( address indexed user, uint256 rawAmount, uint256 auctionEntryDay, uint256 currentDay, uint256 entryTime );
    event ClaimVesting ( address indexed user, uint256 rewardAmount, uint256 claimTime );
    event LiqAdded (uint256 transferredToken, uint256 transferredDepositToken, uint256 timestamp);
    event BuybackAndBurn (uint256 day, uint256 collectedDepositTokenToBuyback, uint256 boughtTokens, uint256 timestamp);
    // event ErrorOccurred (string message, string reason);



    modifier onlyDev() {
        require(_dev == msg.sender || _dev1 == msg.sender , "Ownable: caller is not the dev");
        _;
    }


    uint256 private _totalSupply;
    
    mapping(address => uint256) private _Balances;

    
    struct VestData{
      uint256 vestTime;
      uint256 amount;
      uint256 claimed;
      uint256 lastUpdate;
      uint256 collected;
    }

    mapping(address => mapping (uint256 => VestData)) public vesting;


    /* a certain days total auction entry in depositToken */ 
    mapping (uint256 => uint256) public auctionEntry_thatDay;

    // total auction entry in depositToken of all auction days together
    uint256 public auctionEntry_allDays;

    // counting unique (unique for every day only) Auction enteries for each day
    mapping (uint256 => uint256) public usersCountDaily;

    // counting total unique (unique for every day only) users (if same user enters another day, it counts!)
    uint256 public usersCount = 0;

    // mapping for allowance
    mapping (address => mapping (address => uint256)) private _allowance;

    
    // Auction memebrs overall data 
    struct memberAuction_overallData{
        uint256 overall_collectedTokens;
        uint256 total_auctionEnteries;
    }

    // map for every user's overall data  
    mapping(address => memberAuction_overallData) public mapMemberAuction_overallData;
    
    /* Auction memebrs data */ 
    struct memberAuction{
        uint256 memberAuctionValue;
        bool hasChangedShareToToken;
    }

    /* new map for every entry (users are allowed to enter multiple times a day) */ 
    mapping(address => mapping(uint256 => memberAuction)) public mapMemberAuction;

    
    // Addresses that excluded from transferTax when receiving
    mapping(address => bool) private _excludedFromTaxReceiver;

    // ######################################################################
    // ######################################################################
    // ######################################################################
    // ######################################################################
    // ######################################################################

    constructor() {

        contrAddr = address(this);
        _excludedFromTaxReceiver[msg.sender] = true;
        _excludedFromTaxReceiver[contrAddr] = true;
        _excludedFromTaxReceiver[_dev] = true; 

        _mint(contrAddr, 1 ether);
    }
    
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _Balances[account];
    }

    function allowance(address owner_, address spender) external view returns (uint256) {
        return _allowance[owner_][spender];
    }

    function approve(address spender, uint256 value) public returns (bool) {
        _allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
        _allowance[msg.sender][spender] = _allowance[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowance[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
        uint256 oldValue = _allowance[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowance[msg.sender][spender] = 0;
        } else {
            _allowance[msg.sender][spender] = oldValue.sub(subtractedValue);
        }
        emit Approval(msg.sender, spender, _allowance[msg.sender][spender]);
        return true;
    }


    // function to set the amount of token to be recived vom taxed recepient
    function setPercentToReceiveAfterTax (uint256 percentToReceive) external onlyDev {
        require(percentToReceive < 101 && percentToReceive > 94, "Value not in allowed range!");
        percentToReceiveAfterTax = percentToReceive;
    }


    // Set addresses of dev and fee recipient
    function setDevs(address payable dev, address payable feeRecipient) external onlyDev {
        _dev = dev;
        _feeRecipient = feeRecipient;
    }

     
    // Set address to be in- or excluded from Tax when receiving
    function setExcludedFromTaxReceiver(address _account, bool _excluded) external onlyDev {
        _excludedFromTaxReceiver[_account] = _excluded;
    }
    

    // Returns if the address is excluded from Tax or not when receiving.    
    function isExcludedFromTaxReceiver(address _account) public view returns (bool) {
        return _excludedFromTaxReceiver[_account];
    }
    

   function transferToZero(uint256 amount) internal returns (bool) {
        _Balances[contrAddr] = _Balances[contrAddr].sub(amount, "Token: transfer amount exceeds balance");
        _Balances[address(0)] = _Balances[address(0)].add(amount);
        emit Transfer(contrAddr, address(0), amount);
        return true;
    }


    function transfer(address to, uint256 amount) public returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }  


    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        if( msg.sender != contrAddr ) {
          _allowance[from][msg.sender] = _allowance[from][msg.sender].sub(amount);
        }
        _transfer(from, to, amount);
        return true;
    }


    // internal transfer function to apply the transfer tax ONLY for buys from DEX liquidity
    function _transfer(address from, address to, uint256 amount) internal virtual {
        // For Taxed Transfer
        bool _isTaxedRecipient = !isExcludedFromTaxReceiver(to);

        if ( _isTaxedRecipient ) {   // if recipient is taxed (default case)  

            _Balances[from] = _Balances[from].sub(amount, "transfer amount exceeds balance");
            uint256 taxedAmount = amount.mul(percentToReceiveAfterTax).div(100);
            _Balances[to] = _Balances[to].add(taxedAmount);
            _Balances[_feeRecipient] = _Balances[_feeRecipient].add(amount.sub(taxedAmount));
            emit Transfer(from, to, taxedAmount);
            emit Transfer(from, _feeRecipient, amount.sub(taxedAmount));

        } else {
            _Balances[from] = _Balances[from].sub(amount, "transfer amount exceeds balance");
            _Balances[to] = _Balances[to].add(amount);
            emit Transfer(from, to, amount);
        }
    }


    function _mint(address _user, uint256 _amount) internal { 
      _Balances[_user] = _Balances[_user].add(_amount);
      _totalSupply = _totalSupply.add(_amount);
      emit Transfer(address(0), _user, _amount);
    }


    function _burn(address _user, uint256 _amount) internal {
      _Balances[_user] = _Balances[_user].sub(_amount);
      _totalSupply = _totalSupply.sub(_amount);
      emit Transfer(_user, address(0), _amount);
    }
    

    // internal function to vest user Token
    function vestInt (uint256 _amount, uint256 _vestIndex) internal {
      vesting[msg.sender][_vestIndex].amount = _amount;
      vesting[msg.sender][_vestIndex].vestTime = block.timestamp;
      vesting[msg.sender][_vestIndex].lastUpdate = block.timestamp;

      overallVestedToken += _amount;
      emit Vest(msg.sender, _amount, _vestIndex, block.timestamp);
    }
 

    function setLaunchTime (uint256 newTime) external onlyDev {
        require (LAUNCH_TIME + (offDays * oneDay) > block.timestamp, "Auctions have already started!");   // assure auctions have not already started
        require (newTime + (offDays * oneDay) > block.timestamp, "New Launchtime + offDays must be in the future!"); // assure new launctime is in the future
        LAUNCH_TIME = newTime; // set Launchtime to the new time
    }


    function setOffDays (uint32 _offDays) external onlyDev {
        require (LAUNCH_TIME + (offDays * oneDay) > block.timestamp, "Auctions have already started!");   // assure auctions have not already started
        require (LAUNCH_TIME + (_offDays * oneDay) > block.timestamp, "Number for offDays too small!");   // assure new offDays will start auctions in the future
        offDays = _offDays; // set offDays to new offDays
    }


    // function to see which is the actual auction day
    function thisDay() public view returns (uint256) {
        if ((LAUNCH_TIME + (offDays * oneDay) + totalPauseTimeCounter) > block.timestamp ) {
            return 0;
        } else {
          return 1 + (((block.timestamp - (LAUNCH_TIME + (offDays * oneDay) + totalPauseTimeCounter)) / oneDay));  
        }        
    }


    // to make the contract being able to receive ETH from Router
    receive() external payable {}


    // permanemtly disallow pausability of auctions
    function permanentlyDisableAuctionPause () external onlyDev {
        require(isAuctionActive, "Auctions are Paused! Unpause Auctions first!");
        pausabilityPermanentlyDisabled = true;
    }


    // switch pause and unpause Auction
    function pauseUnpauseAuctions () external onlyDev {
        require(!pausabilityPermanentlyDisabled, "Pausing Auctions was permanently disabled!");

      if (isAuctionActive) {  // if auction is running
        isAuctionActive = false; //  PAUSE it!
        lastAuctionPauseTime = block.timestamp;  // store timestamp of last pause start
      } else {  // if auction is paused
        isAuctionActive = true; // UNPAUSE it!
        lastAuctionUnpauseTime = block.timestamp;  // set switch ON time to NOW

        totalPauseTimeCounter += lastAuctionUnpauseTime - lastAuctionPauseTime; // update total pause time
      }
    }

 
    // function to add first days token to liquitidy
    function addFirstDaysLiq () internal {        

        // calc the amount of token that should be added to preserve the price!
        uint256 amountAuctionTokenToAdd = dayliAvailableToken * 85 / 100;

        // calc he amount to send to router to not losse tokens form tax!
        uint256 amountToSend = (amountAuctionTokenToAdd * 100) / percentToReceiveAfterTax;

        // mint the tokens into the contract to have them available
        _mint(contrAddr, amountToSend);

        // calc the amount of the deposit token to be added to liq
        uint256 collectedTokenToLiq = auctionEntry_thatDay[1] * 85 / 100;

        // get real balance and require balance
        uint256 collectedDepoistTokenBalance = IERC20(depositToken).balanceOf(contrAddr);
        require (collectedDepoistTokenBalance >= collectedTokenToLiq, "addFirstDaysLiq: not enough depositToken in contract"); 

        if (IERC20(depositToken).allowance(contrAddr, _routerAddr) == 0) {
            // Approve the router to spend depositToken from contrAddr
            IERC20(depositToken).approve(_routerAddr, type(uint256).max);
            IERC20(contrAddr).approve(_routerAddr, type(uint256).max);
        }

        // actual Liq adding to v2 Router:
        _router.addLiquidity(
        contrAddr, // address of this token
        depositToken, // address of collected token
        amountToSend, // amount of this token
        collectedTokenToLiq, // amount of deposit token
        0, // desired amount a
        0, // desired amount b
        address(0),
        block.timestamp + 100
        );

        // transfer remaining depositToken to fee addr (15%)
        IERC20(depositToken).transfer(_feeRecipient, auctionEntry_thatDay[1] - collectedTokenToLiq);        
        
        emit LiqAdded (amountToSend, collectedTokenToLiq, block.timestamp);
    }


    // function for the second and the following days, to buy back token with deposit token
        function buybackAndBurn(uint256 day) internal {
            uint256 collectedTokenToBuyback = auctionEntry_thatDay[day] * 85 / 100;

            // Check contract's balance of deposit token
            uint256 contractBalance = IERC20(depositToken).balanceOf(contrAddr);
            require(contractBalance >= collectedTokenToBuyback, "Insufficient deposit token balance");

            if (IERC20(depositToken).allowance(contrAddr, _routerAddr) == 0) {
                // Approve the router to spend depositToken from contrAddr
                IERC20(depositToken).approve(_routerAddr, type(uint256).max);
            }

            // Define the path for swapping
            address[] memory path = new address[](2);
            path[0] = depositToken;
            path[1] = contrAddr;

            // Get expected output amounts
            uint256[] memory amountsOut = _router.getAmountsOut(collectedTokenToBuyback, path);
            uint256 expectedAmountOut = amountsOut[1];

            // Calculate minimum expected amount (90% of expectedAmountOut to allow slippage)
            uint256 amountOutMin = (expectedAmountOut * 90) / 100;

            // Check the actual balance of the recipient wallet.
            uint256 tokenBalanceFeeBefore = IERC20(contrAddr).balanceOf(_feeRecipient);

            // Swap to _feeRecipient address
            _router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                collectedTokenToBuyback,
                amountOutMin,
                path,
                _feeRecipient,
                block.timestamp + 100
            );

            // Check the actual received amount after swap
            uint256 receivedAmount = IERC20(contrAddr).balanceOf(_feeRecipient) - tokenBalanceFeeBefore;

            // Check _feeRecipient balance of contract token
            require(receivedAmount > 0, "No tokens received from swap");

            // Transfer the received tokens from _feeRecipient to address(0) for burning
            IERC20(contrAddr).transferFrom(_feeRecipient, address(0), receivedAmount);

            // transfer remaining depositToken of day X to fee addr (15%)
            IERC20(depositToken).transfer(_feeRecipient, auctionEntry_thatDay[day] - collectedTokenToBuyback);

            emit BuybackAndBurn(day, collectedTokenToBuyback, receivedAmount, block.timestamp);
        }


    function dailyUpdate () public {

        if (thisDay() == 2 && currentDay == 1) {
            addFirstDaysLiq();
        }

        if (thisDay() >= 3 && currentDay == thisDay() - 1 && thisDay() < (auctionPeriod/oneDay + 2 )){
            buybackAndBurn(thisDay() - 1);
        }

        // update current day to assure that liq adding and buyback happens only once per day!
        currentDay = thisDay();     
    }
    

    // function for users to participate in the daily auctions
    function buyShareFromAuction (uint256 auctionDay, uint256 tokenAmount) external returns (bool) {        
        require (tokenAmount > 0, "No Token to buy Shares!");  // check if there is token to deposit
        require (isAuctionActive, "Auctions are currently Paused!"); // check if auctions are currently not paused
        require (block.timestamp >= LAUNCH_TIME + (offDays * oneDay) + totalPauseTimeCounter, "Auctions have not starded now!"); // check if auctions are still ongoing
        require (auctionDay >= thisDay() && (auctionDay * oneDay) <= auctionPeriod, "No valid day to enter Auctions!"); // check if day to enter is a valid day
        
        // Check if msg.sender has allowed contrAddr to spend depositToken
        require(IERC20(depositToken).allowance(msg.sender, contrAddr) >= tokenAmount, "Insufficient allowance for contrAddr to spend depositToken");

        // Transfer depositToken from msg.sender to contrAddr
        IERC20(depositToken).transferFrom(msg.sender, contrAddr, tokenAmount);
        

        auctionEntry_thatDay[auctionDay] += tokenAmount;  // update token deposit amount of deposit day!
        auctionEntry_allDays += tokenAmount;  // update total ever deposited token
        
    
        if (mapMemberAuction[msg.sender][auctionDay].memberAuctionValue == 0) { // check if user already made a depoist on that auction day
            usersCount++;  // UNIQUE users per day for ALL days
            usersCountDaily[auctionDay]++; // UNIQUE users per day for the ENTRANCE day
        }

        mapMemberAuction_overallData[msg.sender].total_auctionEnteries += tokenAmount;  // update total depositToken amount used for auction entries of the USER

        mapMemberAuction[msg.sender][auctionDay].memberAuctionValue += tokenAmount;    // total depositToken amount entries of the USER on THAT DAY

        dailyUpdate();

        emit EnterAuction (msg.sender, tokenAmount, auctionDay, currentDay, block.timestamp);
        return true;        
    }


    function calculateTokenPerShareOnDay (uint256 _day) public view returns (uint256) {
      uint256 collectedThatDay = auctionEntry_thatDay[_day];

      if (collectedThatDay == 0) { // avoid division by 0
        return 0;
      } else {
        uint256 tokenPerShare = dayliAvailableToken.mul(1e18).div(collectedThatDay);
        return tokenPerShare;
      }
    }


    // function for users to change their shares from ALL auction days into vested tokens
    function claimTokenFromSharesAndVest (uint256 auctionDay) external returns (bool) {
      require(thisDay() > auctionDay, "This auction days token are not ready to be accounted to users vesting!");

      uint256 userShares = mapMemberAuction[msg.sender][auctionDay].memberAuctionValue; // get amount of shares for the requested auction day

      require(userShares > 0, "User has never deposited depositToken to auctionDay!");
      require(mapMemberAuction[msg.sender][auctionDay].hasChangedShareToToken == false, "User has already Changed his Shares to Token");
      
      uint256 amountUserTokens = calculateTokenPerShareOnDay(auctionDay).mul(userShares).div(1e18);

      vestInt(amountUserTokens, auctionDay); // create Vesting data for the USER

      mapMemberAuction[msg.sender][auctionDay].hasChangedShareToToken = true;

      dailyUpdate();

      emit ChangeSharesToToken (msg.sender, userShares, amountUserTokens);

      return true;
    }


    // Only called when claim (collect) is called
    // Calculates the earned rewards since LAST UPDATE
    // Earning is 5% per day and lasts until 110% is reached (effectively 22 days)
    function calcVestingEmission(address _user, uint256 _vestIndex) public view returns (uint256) {
        if (vesting[_user][_vestIndex].vestTime == 0) {
            return 0; // No vest, no reward
        }

        // Multiplier that represents the amount earned per second
        // value 11574074074074 gives 1 ether per day as multiplier!
        // Factor 5 for 5% per day
        uint256 multiplier = (block.timestamp - vesting[_user][_vestIndex].lastUpdate).mul(weiPerSfor1perDay).mul(5);

        // Calculate the maximum reward (110% of the vesting amount)
        uint256 maxReward = vesting[_user][_vestIndex].amount.mul(110).div(100);

        // Check if the total earned (including previously collected) exceeds the maximum reward
        if (vesting[_user][_vestIndex].amount.mul(multiplier).div(100 ether).add(vesting[_user][_vestIndex].collected) > maxReward) {
            return maxReward.sub(vesting[_user][_vestIndex].collected);
        }

        // Otherwise, return the calculated reward for this period
        return vesting[_user][_vestIndex].amount.mul(multiplier).div(100 ether);
    }


    // Calculates claimable rewards for UI display
    function readVestingEmission(address _user, uint256 _vestIndex) public view returns (uint256) {
        if (vesting[_user][_vestIndex].vestTime == 0) {
            return 0;
        }

        uint256 multiplier = (block.timestamp - vesting[_user][_vestIndex].lastUpdate).mul(weiPerSfor1perDay).mul(5);
        uint256 maxReward = vesting[_user][_vestIndex].amount.mul(110).div(100);

        if (multiplier.mul(vesting[_user][_vestIndex].amount).div(100 ether).add(vesting[_user][_vestIndex].collected) > maxReward) {
            return maxReward.sub(vesting[_user][_vestIndex].claimed);
        }

        return vesting[_user][_vestIndex].amount.mul(multiplier).div(100 ether).add(vesting[_user][_vestIndex].collected)
            .sub(vesting[_user][_vestIndex].claimed);
    }



    // function to update the collected vesting emissions to user vestInt collected value and update the last updated value
    function _collect (address _user, uint256 _vestIndex) internal {
        vesting[_user][_vestIndex].collected = vesting[_user][_vestIndex].collected.add(calcVestingEmission(_user, _vestIndex)); // Add new rewards to the collected amount
        vesting[_user][_vestIndex].lastUpdate = block.timestamp; // Update the last time rewards were collected
    }



    // function for users to claim the vesting emissions 
    function claimVestingEmissions (uint256 _vestIndex) external {
        _collect(msg.sender, _vestIndex); // call collect to update users vest data by addind the newly earned rewards

        uint256 reward = vesting[msg.sender][_vestIndex].collected.sub(vesting[msg.sender][_vestIndex].claimed); // Calculate the unclaimed rewards

        vesting[msg.sender][_vestIndex].claimed = vesting[msg.sender][_vestIndex].collected; // Update the claimed amount to match collected

        _mint(msg.sender, reward); // Mint new tokens to reward the user

        mapMemberAuction_overallData[msg.sender].overall_collectedTokens += reward;  // update total amount of claimed vesting emissions

        overallCollectedEarnings += reward; // Increase overall dividends

        dailyUpdate();

        emit ClaimVesting (msg.sender, reward, block.timestamp); // Emit an event for transparency
    }

}