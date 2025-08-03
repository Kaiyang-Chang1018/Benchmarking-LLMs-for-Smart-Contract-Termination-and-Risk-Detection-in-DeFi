// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import "./lib/IRouter02.sol";
import "./lib/IERC20.sol";
import "./lib/IFactoryV2.sol";
import "./lib/IV2Pair.sol";

// Byte - The First All-in-One Layer-2 Social App for Crypto

// Byte combines social features, trading tools, and project growth solutions into one seamless TG layer-2 platform.

// TG https://t.me/BytePort
// X https://x.com/byteapperc
// Bot/APP @ByteSocialBot
// Website https://bytechain.social/

contract Token is IERC20 {

    uint256 public constant buyTaxLimit = 2500;    
    bool inSwap;
    uint256 public constant sellTaxLimit = 2500;
    uint256 public constant maxTransferTaxes = 2500;
    uint256 constant taxDivisor = 10000;
    uint256 internal _tSupply = 1000000000000000000000000000;
    address private _owner;
    
    mapping(address => uint256) internal _tokenOwned;
    mapping(address => bool) allLiquidityPoolPairs;
    mapping(address => mapping(address => uint256)) internal _allowances;
    mapping(address => bool) internal _isExcludedFromFees;
    mapping(address => bool) internal _isExcludedFromLimits;
    mapping(address => bool) internal _liquidityHolders;

    Fees public _taxRates =
        Fees({buyFee: 500, sellFee: 1500, transferFee: 0});

    TaxPercentages public _taxPercentages =
        TaxPercentages({marketing: 60, dev: 40});

    uint256 internal lastSwap;

    uint256 internal _maxTxAmount = (_tSupply * 5) / 100;
    uint256 internal _maxWalletSize = (_tSupply * 5) / 100;
    TaxWallets public _taxWallets;

    bool public contractSwapEnabled = false;
    uint256 public contractSwapTimer = 0 seconds;

    uint256 public swapThreshold;

    bool public tradingEnabled = false;
    bool public _hasLiquidityBeenAdded = false;

    mapping(address => bool) public isDexRouter;
    mapping(address => address) public routers;

    address public lpPair;
    address public constant DEAD = 0x000000000000000000000000000000000000dEaD;

    bool public liquidityPoolInitialized = false;

    struct Fees {
        uint16 buyFee;
        uint16 sellFee;
        uint16 transferFee;
    }

    struct TaxPercentages {
        uint16 marketing;
        uint16 dev;
    }

    struct TaxWallets {
        address payable marketing;
        address payable dev;
    }

    event OwnershipTransferred(
        address indexed pastOwner,
        address indexed newOwner
    );
    event ContractSwapStatusUpdated(bool enabled);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event TaxUpdated(uint256 buy, uint256 sell, uint256 transfer);
    event TaxDistributionPercentageUpdated(uint256 marketing, uint256 dev);
    event MaxTransactionAmountUpdated(uint256 amount);
    event SwapSettingsUpdated(uint256 threshold, uint256 time);


    modifier lockSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Caller must be the owner");
        _;
    }
    string internal _name;
    string internal _symbol;
    uint8 internal _decimals = 18;

    constructor(string memory tName, string memory tSymbol) payable {
        // Set the owner.
        _owner = address(msg.sender);

        _tokenOwned[msg.sender] = _tSupply;
        emit Transfer(address(0), msg.sender, _tSupply);

        isDexRouter[0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D]=true;
        routers[IRouter02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D).factory()]=0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
        
        _taxWallets.marketing=payable(0xc44D65a1314cAaC6bc1684F39b9B98273B6F1A8B);
        _taxWallets.dev=payable(0xcBE9559B6Fd48139dEf5A392231559133e622a82);

        _name = tName;
        _symbol = tSymbol;
        _isExcludedFromFees[_owner] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[DEAD] = true;
        _isExcludedFromFees[_taxWallets.marketing] = true;
        _isExcludedFromFees[_taxWallets.dev] = true;
        _isExcludedFromLimits[_taxWallets.marketing] = true;
        _isExcludedFromLimits[_taxWallets.dev] = true;
        _liquidityHolders[_owner] = true;
    }

    function balanceOf(address account) public view override(IERC20)  returns (uint256) {
        return _tokenOwned[account];
    }
    
    function confirmLP(
    ) public onlyOwner{
        require(!liquidityPoolInitialized, 'LP already confirmed');
        lpPair = IFactoryV2(IRouter02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D).factory()).getPair(address(this), IRouter02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D).WETH());
        setLiquidityPoolPair(lpPair, true);
        liquidityPoolInitialized = true;
        _checkLiquidityAdd(msg.sender);
        setMaxTxPercent(19,10000) ;
        enableTrading();
    }

    function addPairAddress (address pair
    ) public onlyOwner{
        require(pair!=address(0),'Invalid address');
        setLiquidityPoolPair(pair, true);
    }

    function isContract(address _addr) public view returns (bool){
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

    function preInitializedTransfer(
        address to,
        uint256 amount
    ) public onlyOwner {
        require(!liquidityPoolInitialized,'Liquidity pool must not be confirmed');
        amount = amount * 10 ** _decimals;
        _finalizeTransfer(msg.sender, to, amount, false, false, false, true);
    }


    // Ownable removed as a lib and added here to allow for custom transfers and renouncements.
    // This allows for removal of ownership privileges from the owner once renounced or transferred.
    function transferOwner(address newOwner) external onlyOwner(){
        require(
            newOwner != address(0),
            "Call renounceOwnership to transfer owner to the zero address"
        );
        require(
            newOwner != DEAD,
            "Call renounceOwnership to transfer owner to the zero address"
        );
        setExcludedFromFees(_owner, false);
        setExcludedFromFees(newOwner, true);

        if (balanceOf(_owner) > 0) {
            _transfer(_owner, newOwner, balanceOf(_owner));
        }

        _owner = newOwner;
        emit OwnershipTransferred(_owner, newOwner);
    }

    function renounceOwnership() public onlyOwner {
        setExcludedFromFees(_owner, false);
        _owner = address(0);
        emit OwnershipTransferred(_owner, address(0));
    }

    //===============================================================================================================

    function totalSupply() external view override returns (uint256) {
        if (_tSupply == 0) {
            revert();
        }
        return _tSupply;
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function getOwner() external view override returns (address) {
        return _owner;
    }

    function allowance(
        address holder,
        address spender
    ) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    
    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function approveContractContingency(IRouter02 _dexRouter) public onlyOwner returns (bool) {
        _approve(address(this), address(_dexRouter), type(uint256).max);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            _allowances[sender][msg.sender] -= amount;
        }

        return _transfer(sender, recipient, amount);
    }

    function setNewRouter(address newRouter, address token1) public onlyOwner {
        require(newRouter!=address(0),'Invalid address');
        require(isDexRouter[newRouter]==false,'Router already exists');
        IRouter02 _newRouter = IRouter02(newRouter);

        address get_pair = IFactoryV2(_newRouter.factory()).getPair(
            address(this),
            token1
        );
        if (get_pair == address(0)) {
            lpPair = IFactoryV2(_newRouter.factory()).createPair(
                address(this),
                token1
            );
        } else {
            lpPair = get_pair;
        }
        isDexRouter[address(_newRouter)]=true;
        routers[_newRouter.factory()]=newRouter;
        setLiquidityPoolPair(lpPair, true);
        _approve(address(this), address(_newRouter), type(uint256).max);
    }

    function setLiquidityPoolPair(
        address pair,
        bool enabled
    ) internal onlyOwner {
        require(pair!=address(0),'Invalid address');
        if (!enabled) {
            allLiquidityPoolPairs[pair] = false;
        } else {
            allLiquidityPoolPairs[pair] = true;
        }
    }
    
    function setTaxes(
        uint16 buyFee,
        uint16 sellFee,
        uint16 transferFee
    ) external onlyOwner {
        require(
            buyFee <= buyTaxLimit &&
                sellFee <= sellTaxLimit &&
                transferFee <= maxTransferTaxes,
            "Cannot exceed maximum"
        );
        _taxRates.buyFee = buyFee;
        _taxRates.sellFee = sellFee;
        _taxRates.transferFee = transferFee;
        emit TaxUpdated(buyFee, sellFee, transferFee);
    }

    function setTaxPercentages(
        uint16 marketing
    ) external onlyOwner {
        require(marketing>=0 && marketing<=100,'Percentage should be between 0 - 100');
        _taxPercentages.marketing = marketing;
        _taxPercentages.dev = 100-marketing;
        emit TaxDistributionPercentageUpdated(marketing, _taxPercentages.dev);
    }

    function setMaxTxPercent(
        uint256 percent,
        uint256 divisor
    ) public onlyOwner {
        _maxTxAmount = (_tSupply * percent) / divisor;
        emit MaxTransactionAmountUpdated(_maxTxAmount);
    }


    function setSwapSettings(
        uint256 threshold,
        uint256 thresholdDivisor,
        uint256 time
    ) external onlyOwner {
        require(threshold > 0,'Threshold has to be higher than 0');
        require(thresholdDivisor%10 == 0 && thresholdDivisor > 0,'thresholdDivisor has to be higher than 0 and divisible by 10');
        swapThreshold = (_tSupply * threshold) / thresholdDivisor;
        contractSwapTimer = time;
        emit SwapSettingsUpdated(swapThreshold, time);
    }

    function setContractSwapEnabled(bool enabled) external onlyOwner {
        contractSwapEnabled = enabled;
        emit ContractSwapStatusUpdated(enabled);
    }

    function setWallets(
        address payable marketing,
        address payable dev
    ) external onlyOwner {
        require(!isContract(marketing),'Cannot be a contract');
        require(!isContract(dev),'Cannot be a contract');
        _taxWallets.marketing = payable(marketing);
        _taxWallets.dev = payable(dev);
    }

    function preInitializedTransferMultiple(
        address[] memory accounts,
        uint256[] memory amounts
    ) external onlyOwner {
        require(accounts.length == amounts.length, "Accounts != Amounts");
        for (uint8 i = 0; i < accounts.length; i++) {
            require(balanceOf(msg.sender) >= amounts[i] * 10 ** _decimals,'Account have lower token balance than needed');
            preInitializedTransfer(accounts[i], amounts[i]);
        }
    }




    function enableTrading() internal {
        require(!tradingEnabled, "Trading already enabled!");
        require(_hasLiquidityBeenAdded, "Liquidity must be added");
        tradingEnabled = true;
        swapThreshold = (_tSupply * 25) / 100000 ;
    }

    function takeTax(
        address from,
        bool buy,
        bool sell,
        uint256 amount
    ) internal returns (uint256) {
        uint256 currentFee;
        if (buy) {
            currentFee = _taxRates.buyFee;
        } else if (sell) {
            currentFee = _taxRates.sellFee;
        } else {
            currentFee = _taxRates.transferFee;
        }

        uint256 feeAmount = (amount * currentFee) / taxDivisor;

        _tokenOwned[address(this)] += feeAmount;
        emit Transfer(from, address(this), feeAmount);

        return amount - feeAmount;
    }


    function setMaxWalletSize(
        uint256 percent,
        uint256 divisor
    ) public onlyOwner {
        require(
            (_tSupply * percent) / divisor >= (_tSupply / 1000),
            "Max Wallet amount must be above 0.1% of total supply"
        );
        _maxWalletSize = (_tSupply * percent) / divisor;
    }

    function setExcludedFromLimits(
        address account,
        bool enabled
    ) external onlyOwner {
        _isExcludedFromLimits[account] = enabled;
    }


    function sweepContingency() external onlyOwner {
        require(!_hasLiquidityBeenAdded, "Cannot call after liquidity");
        payable(_owner).transfer(address(this).balance);
    }

    function contractSwap(uint256 contractTokenBalance, address exchange, bool direct) internal lockSwap {
        require((isDexRouter[exchange] && !direct)|| (direct && msg.sender == _owner),"You don't have sufficient permision to make this call");
        IRouter02 _dexRouter = IRouter02(exchange);
        TaxPercentages memory taxPercentages = _taxPercentages;

        if (
            _allowances[address(this)][address(_dexRouter)] != type(uint256).max
        ) {
            _allowances[address(this)][address(_dexRouter)] = type(uint256).max;
        }

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _dexRouter.WETH();

        _dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            contractTokenBalance,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amtBalance = address(this).balance;

        uint256 devBalance = (amtBalance * taxPercentages.dev) / 100;
        uint256 marketingBalance = amtBalance - devBalance;
        if (taxPercentages.dev > 0) {
            _taxWallets.dev.transfer(devBalance);
        }
        if (taxPercentages.marketing > 0) {
            _taxWallets.marketing.transfer(marketingBalance);
        }
    }

    function isExcludedFromLimits(address account) public view returns (bool) {
        return _isExcludedFromLimits[account];
    }

    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }

    function setExcludedFromFees(
        address account,
        bool enabled
    ) public onlyOwner {
        _isExcludedFromFees[account] = enabled;
    }

    function getMaxTransaction() public view returns (uint256) {
        return _maxTxAmount / (10 ** _decimals);
    }

    function getMaxWallet() public view returns (uint256) {
        return _maxWalletSize / (10 ** _decimals);
    }

    function _finalizeTransfer(
        address from,
        address to,
        uint256 amount,
        bool takeFee,
        bool buy,
        bool sell,
        bool other
    ) internal returns (bool) {

        _tokenOwned[from] -= amount;
        uint256 amountReceived = (takeFee)
            ? takeTax(from, buy, sell, amount)
            : amount;
        _tokenOwned[to] += amountReceived;

        emit Transfer(from, to, amountReceived);
        return true;
    }

    function _hasLimits(address from, address to) internal view returns (bool) {
        return
            from != _owner &&
            to != _owner &&
            tx.origin != _owner &&
            !_liquidityHolders[to] &&
            !_liquidityHolders[from] &&
            to != DEAD &&
            to != address(0) &&
            from != address(this);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal returns (bool) {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        // require(liquidityPoolInitialized, "LP must be intiialized first!");


        bool buy = false;
        bool sell = false;
        bool other = false;
        if (allLiquidityPoolPairs[from]) {
            buy = true;
        } else if (allLiquidityPoolPairs[to]) {
            sell = true;
        } else {
            other = true;
        }
        
        if (_hasLimits(from, to)) {
            if (!tradingEnabled) {
                revert("Trading not yet enabled!");
            }
            if (buy || sell) {
                if (
                    !_isExcludedFromLimits[from] && !_isExcludedFromLimits[to]
                ) {
                    require(
                        amount <= _maxTxAmount,
                        "Transfer amount exceeds the maxTransactionAmount"
                    );
                }
            }
            if (!isDexRouter[to] && !sell) {
                if (!_isExcludedFromLimits[to]) {
                    require(
                        balanceOf(to) + amount <= _maxWalletSize,
                        "Transfer amount exceeds the maxWalletSize."
                    );
                }
            }
        }

        bool takeFee = true;

        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        if (sell) {
            if (!inSwap && contractSwapEnabled) {
                if (lastSwap + contractSwapTimer < block.timestamp) {
                    uint256 contractTokenBalance = balanceOf(address(this));
                    if (contractTokenBalance >= swapThreshold) {
                        contractTokenBalance = swapThreshold; 
                        contractSwap(contractTokenBalance,routers[IV2Pair(to).factory()],false);
                        lastSwap = block.timestamp;
                    }
                }
            }
        }
        return _finalizeTransfer(from, to, amount, takeFee, buy, sell, other);
    }

    function distributeTax(address exchange, uint maxAmount) public onlyOwner(){
         if (lastSwap + contractSwapTimer < block.timestamp) {
                    uint256 contractTokenBalance = balanceOf(address(this));
                    if (maxAmount<contractTokenBalance){
                        contractTokenBalance = maxAmount;
                    }
                    if (contractTokenBalance >= swapThreshold) {
                        contractTokenBalance = swapThreshold;
                        contractSwap(contractTokenBalance,exchange,true);
                        lastSwap = block.timestamp;
                    }
                }
    }

    function _approve(
        address sender,
        address spender,
        uint256 amount
    ) internal {
        require(sender != address(0), "ERC20: Zero Address");
        require(spender != address(0), "ERC20: Zero Address");

        _allowances[sender][spender] = amount;
        emit Approval(sender, spender, amount);
    }

    function _checkLiquidityAdd(address from) internal {
        require(!_hasLiquidityBeenAdded, "Liquidity already added and marked");
            _liquidityHolders[from] = true;
            _hasLiquidityBeenAdded = true;

            contractSwapEnabled = true;
            emit ContractSwapStatusUpdated(true);
    }
    receive() payable external {}
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address _owner,
        address spender
    ) external view returns (uint256);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    // event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

interface IFactoryV2 {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address lpPair,
        uint
    );

    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address lpPair);

    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address lpPair);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

interface IRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    )
        external
        payable
        returns (uint amountToken, uint amountETH, uint liquidity);

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

    function getAmountsOut(
        uint amountIn,
        address[] calldata path
    ) external view returns (uint[] memory amounts);

    function getAmountsIn(
        uint amountOut,
        address[] calldata path
    ) external view returns (uint[] memory amounts);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

import "./IRouter01.sol";

interface IRouter02 is IRouter01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
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

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactTokensForETH(
        uint amountIn, 
        uint amountOutMin, 
        address[] calldata path, 
        address to, uint deadline)
    external returns (uint[] memory amounts);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

interface IV2Pair {
    function sync() external;

    function factory() external view returns (address);

    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}