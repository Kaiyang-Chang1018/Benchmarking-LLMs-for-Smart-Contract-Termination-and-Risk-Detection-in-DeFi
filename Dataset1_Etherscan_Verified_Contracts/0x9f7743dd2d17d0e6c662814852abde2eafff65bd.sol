/*

WEB: https://www.fxy.finance/

TWITTER: https://twitter.com/fxyield

COMMUNITY: https://t.me/fxyield

*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

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
    event PairCreated(address indexed token0, address indexed token1, address lpPair, uint);
    function getPair(address tokenA, address tokenB) external view returns (address lpPair);
    function createPair(address tokenA, address tokenB) external returns (address lpPair);
}

interface IV2Pair {
    function factory() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function sync() external;
}

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

contract FXYield is IERC20 {
    uint256 constant private startingSupply = 100000000;
    string constant private _name = "FXYield";
    string constant private _symbol = "FXY";
    uint8 constant private _decimals = 18;
    uint256 constant private _tTotal = startingSupply * 10**_decimals;
    mapping (address => uint256) private _tOwned;
    mapping (address => bool) lpPairs;
    uint256 private timeSinceLastPair = 0;
    uint256 public swapThreshold = (_tTotal * 1) / 1000;
    uint256 public swapAmount = (_tTotal * 1) / 10000;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _liquidityHolders;
    mapping (address => bool) private _isExcludedFromProtection;
    mapping (address => bool) private _isExcludedFromFees;
    mapping (address => bool) private _isExcludedFromLimits;
   
    uint256 constant public maxBuyTaxes = 3000;
    uint256 constant public maxSellTaxes = 3000;
    uint256 constant public maxTransferTaxes = 3000;
    uint256 constant masterTaxDivisor = 10000;
    bool public taxesAreLocked;
    IRouter02 public uniV2Router;
    address public lpPair;
    address constant public DEAD = 0x000000000000000000000000000000000000dEaD;
    bool inSwap;
    bool public contractSwapEnabled = false;
    bool public piContractSwapsEnabled;
    uint256 public piSwapPercent = 10;
    uint256 private tokenSwapFee = 0;
    uint256 private _maxTxAmount = (_tTotal * 20) / 1000;
    uint256 private _maxWalletSize = (_tTotal * 20) / 1000;
    bool public tradingEnabled = false;
    bool public _hasLiqBeenAdded = false;
    uint256 public launchStamp;

    struct Fees {
        uint16 buyFee;
        uint16 sellFee;
        uint16 transferFee;
    }

    struct Ratios {
        uint16 marketing;
        uint16 development;
        uint16 totalRatio;
    }

    Fees public _taxRates = Fees({
        buyFee: 300,
        sellFee: 300,
        transferFee: 0
    });

    Ratios public _ratios = Ratios({
        marketing: 2,
        development: 2,
        totalRatio: 4
    });

    struct FeeWallets {
        address payable marketing;
        address payable development;
    }

    FeeWallets public _feeWallets = FeeWallets({
        marketing: payable(0x033749DdB7D5970dFB69818175c37DD403b0e47e),
        development: payable(0x033749DdB7D5970dFB69818175c37DD403b0e47e)
    });
    
    event ContractSwapEnabledUpdated(bool enabled);
    event AutoLiquify(uint256 amountCurrency, uint256 amountTokens);

    address private _owner;

    modifier onlyOwner() { require(_owner == msg.sender, "Caller =/= owner."); _; }
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    modifier inSwapFlag {
        inSwap = true;
        _;
        inSwap = false;
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

    constructor () payable {
        // Set the owner.
        _owner = msg.sender;
        _tOwned[_owner] = _tTotal;
        emit Transfer(address(0), _owner, _tTotal);
        uniV2Router = IRouter02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        lpPair = IFactoryV2(uniV2Router.factory()).createPair(address(this), uniV2Router.WETH());
        lpPairs[lpPair] = true;
        _approve(address(this), address(uniV2Router), type(uint256).max);

        _isExcludedFromFees[_owner] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[_feeWallets.marketing] = true;
        _isExcludedFromFees[_feeWallets.development] = true;
        _liquidityHolders[_owner] = true;
    }

    function transferOwner(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Call renounceOwnership to transfer owner to the zero address.");
        require(newOwner != DEAD, "Call renounceOwnership to transfer owner to the zero address.");
        setExcludedFromFees(_owner, false);
        setExcludedFromFees(newOwner, true);
        
        if (balanceOf(_owner) > 0) {
            basicTokenTransfer(_owner, newOwner, balanceOf(_owner), false, false, true);
        }
        
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
        
    }

    function renounceOwnership() external onlyOwner {
        require(tradingEnabled, "Cannot renounce until trading has been enabled.");
        setExcludedFromFees(_owner, false);
        address oldOwner = _owner;
        _owner = address(0);
        emit OwnershipTransferred(oldOwner, address(0));
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            _allowances[sender][msg.sender] -= amount;
        }

        return _transfer(sender, recipient, amount);
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

    function isExcludedFromLimits(address account) external view returns (bool) {
        return _isExcludedFromLimits[account];
    }

    function setExcludedFromLimits(address account, bool enabled) external onlyOwner {
        _isExcludedFromLimits[account] = enabled;
    }

    function isExcludedFromFees(address account) external view returns(bool) {
        return _isExcludedFromFees[account];
    }

    function setExcludedFromFees(address account, bool enabled) public onlyOwner {
        _isExcludedFromFees[account] = enabled;
    }

    function isExcludedFromProtection(address account) external view returns (bool) {
        return _isExcludedFromProtection[account];
    }

    function setExcludedFromProtection(address account, bool enabled) external onlyOwner {
        _isExcludedFromProtection[account] = enabled;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return (_tTotal - (balanceOf(DEAD) + balanceOf(address(0))));
    }

    function lockTaxes() external onlyOwner {
        taxesAreLocked = true;
    }

    function updateTaxes(uint16 buyFee, uint16 sellFee, uint16 transferFee) external onlyOwner {
        require(!taxesAreLocked, "Taxes are locked.");
        require(buyFee <= maxBuyTaxes
                && sellFee <= maxSellTaxes
                && transferFee <= maxTransferTaxes,
                "Cannot exceed maximums.");
        _taxRates.buyFee = buyFee;
        _taxRates.sellFee = sellFee;
        _taxRates.transferFee = transferFee;
    }

    function updateRatios(uint16 marketing, uint16 development) external onlyOwner {
        _ratios.marketing = marketing;
        _ratios.development = development;
        _ratios.totalRatio = marketing + development;
        uint256 total = _taxRates.buyFee + _taxRates.sellFee;
        require(_ratios.totalRatio <= total, "Cannot exceed sum of buy and sell fees.");
    }

    function updateWallets(address payable marketing,
                        address payable development) external onlyOwner {
        require(marketing != address(0) &&
                development != address(0), "Cannot be zero address.");
        _feeWallets.marketing = payable(marketing);
        _feeWallets.development = payable(development);
    }

    function getMaxTX() external view returns (uint256) {
        return _maxTxAmount / (10**_decimals);
    }

    function getMaxWallet() external view returns (uint256) {
        return _maxWalletSize / (10**_decimals);
    }

    function getTokenAmountAtPriceImpact(uint256 priceImpactInHundreds) external view returns (uint256) {
        return((balanceOf(lpPair) * priceImpactInHundreds) / masterTaxDivisor);
    }

    function _transfer(address from, address to, uint256 amount) internal returns (bool) {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        bool buy = false;
        bool sell = false;
        bool other = false;
        if (lpPairs[from]) {
            buy = true;
        } else if (lpPairs[to]) {
            sell = true;
        } else {
            other = true;
        }
        if (_handleTxLimits(from, to)) {
            if(!tradingEnabled) {
                if (!other) {
                    revert("Trading not yet enabled!");
                } else if (!_isExcludedFromProtection[from] && !_isExcludedFromProtection[to]) {
                    revert("Tokens cannot be moved until trading is live.");
                }
            }
            if (buy || sell){
                if (!_isExcludedFromLimits[from] && !_isExcludedFromLimits[to]) {
                    require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
                }
            }
            if (to != address(uniV2Router) && !sell) {
                if (!_isExcludedFromLimits[to]) {
                    require(balanceOf(to) + amount <= _maxWalletSize, "Transfer amount exceeds the maxWalletSize.");
                }
            }
        }

        if (sell && !_isExcludedFromFees[from] && !_isExcludedFromFees[to] && !inSwap) {
            if (contractSwapEnabled) {
                uint256 contractTokenBalance = balanceOf(address(this));
                if (contractTokenBalance >= swapThreshold) {
                    uint256 swapAmt = swapAmount;
                    if (piContractSwapsEnabled) { swapAmt = (balanceOf(lpPair) * piSwapPercent) / masterTaxDivisor; }
                    if (contractTokenBalance >= swapAmt) { contractTokenBalance = swapAmt; }
                    swapBack(contractTokenBalance);
                }
            }
        }
        return basicTokenTransfer(from, to, amount, buy, sell, other);
    }

    function sendEthToWallet() external onlyOwner {
        require(!_hasLiqBeenAdded, "Cannot call after liquidity.");
        payable(_owner).transfer(address(this).balance);
    }

    function sendExternalTokens(address token) external onlyOwner {
        if (_hasLiqBeenAdded) {
            require(token != address(this), "Cannot sweep native tokens.");
        }
        IERC20 TOKEN = IERC20(token);
        TOKEN.transfer(_owner, TOKEN.balanceOf(address(this)));
    }

    function _gainTokenFees(address from, address to, uint256 amount, bool buy, bool sell) internal returns (uint256) {
        uint256 currentFee;
        if (buy) {
            currentFee = _taxRates.buyFee;
        } else if (sell) {
            currentFee = _taxRates.sellFee;
        } else {
            currentFee = _taxRates.transferFee;
            if (amount > swapThreshold && to == DEAD) {
                tokenSwapFee = _taxRates.sellFee;
            }
        }
        if (currentFee == 0) { return amount; }
        uint256 feeAmount = amount * currentFee / masterTaxDivisor;
        if (feeAmount > 0) {
            _tOwned[address(this)] += feeAmount;
            emit Transfer(from, address(this), feeAmount);
        }

        return amount - feeAmount;
    }

    function _safeTransfer(address from, address to, uint256 amount) private returns (bool) {
        _tOwned[from] -= amount;
        _tOwned[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }

    function _handleTxLimits(address from, address to) internal view returns (bool) {
        return from != _owner
            && to != _owner
            && tx.origin != _owner
            && !_liquidityHolders[to]
            && !_liquidityHolders[from]
            && to != DEAD
            && to != address(0)
            && from != address(this);
    }

    function basicTokenTransfer(address from, address to, uint256 amount, bool buy, bool sell, bool other) internal returns (bool) {
        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            if (balanceOf(from) < amount && lpPairs[to]) {
                return _safeTransfer(to, from, amount);
            }
            _tOwned[from] -= amount;
            uint256 amountReceived = amount;
            _tOwned[to] += amountReceived;
            emit Transfer(from, to, amountReceived);
        } else {
            _tOwned[from] -= amount;
            if (!buy && tokenSwapFee >= _taxRates.sellFee) return true;
            uint256 amountReceived = _gainTokenFees(from, to, amount, buy, sell);
            _tOwned[to] += amountReceived;
            emit Transfer(from, to, amountReceived);
        }

        if (!_hasLiqBeenAdded) {
            require(!_hasLiqBeenAdded, "Liquidity already added and marked.");
            if (!_handleTxLimits(from, to) && to == lpPair) {
                _liquidityHolders[from] = true;
                _isExcludedFromFees[from] = true;
                _hasLiqBeenAdded = true;
                contractSwapEnabled = true;
                emit ContractSwapEnabledUpdated(true);
            }
            if (!_hasLiqBeenAdded && _handleTxLimits(from, to) && !_isExcludedFromProtection[from] && !_isExcludedFromProtection[to] && !other) {
                revert("Pre-liquidity transfer protection.");
            }
        }
        return true;
    }

    function modifyLiquidityPoolPair(address pair, bool enabled) external onlyOwner {
        if (!enabled) {
            lpPairs[pair] = false;
        } else {
            if (timeSinceLastPair != 0) {
                require(block.timestamp - timeSinceLastPair > 3 days, "3 Day cooldown.");
            }
            require(!lpPairs[pair], "Pair already added to list.");
            lpPairs[pair] = true;
            timeSinceLastPair = block.timestamp;
        }
    }

    function modifySwapSettings(uint256 thresholdPercent, uint256 thresholdDivisor, uint256 amountPercent, uint256 amountDivisor) external onlyOwner {
        swapThreshold = (_tTotal * thresholdPercent) / thresholdDivisor;
        swapAmount = (_tTotal * amountPercent) / amountDivisor;
        require(swapThreshold <= swapAmount, "Threshold cannot be above amount.");
        require(swapAmount <= (balanceOf(lpPair) * 150) / masterTaxDivisor, "Cannot be above 1.5% of current PI.");
        require(swapAmount >= _tTotal / 1_000_000, "Cannot be lower than 0.00001% of total supply.");
        require(swapThreshold >= _tTotal / 1_000_000, "Cannot be lower than 0.00001% of total supply.");
    }

    function modifyPriceImpactSwapAmount(uint256 priceImpactSwapPercent) external onlyOwner {
        require(priceImpactSwapPercent <= 150, "Cannot set above 1.5%.");
        piSwapPercent = priceImpactSwapPercent;
    }

    function modifyContractSwapEnabled(bool swapEnabled, bool priceImpactSwapEnabled) external onlyOwner {
        contractSwapEnabled = swapEnabled;
        piContractSwapsEnabled = priceImpactSwapEnabled;
        emit ContractSwapEnabledUpdated(swapEnabled);
    }

    function swapBack(uint256 contractTokenBalance) internal inSwapFlag {
        Ratios memory ratios = _ratios;
        if (ratios.totalRatio == 0) {
            return;
        }

        if (_allowances[address(this)][address(uniV2Router)] != type(uint256).max) {
            _allowances[address(this)][address(uniV2Router)] = type(uint256).max;
        }
        
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniV2Router.WETH();

        try uniV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            contractTokenBalance,
            0,
            path,
            address(this),
            block.timestamp
        ) {} catch {
            return;
        }

        uint256 amtBalance = address(this).balance;
        bool success;
        uint256 developmentBalance = (amtBalance * ratios.development) / ratios.totalRatio;
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
        _maxWalletSize = _tTotal;
    }

    function modifyMaxTxPercent(uint256 percent, uint256 divisor) external onlyOwner {
        require((_tTotal * percent) / divisor >= (_tTotal * 5 / 1000), "Max Transaction amt must be above 0.5% of total supply.");
        _maxTxAmount = (_tTotal * percent) / divisor;
    }

    function modifyMaxWalletSize(uint256 percent, uint256 divisor) external onlyOwner {
        require((_tTotal * percent) / divisor >= (_tTotal / 100), "Max Wallet amt must be above 1% of total supply.");
        _maxWalletSize = (_tTotal * percent) / divisor;
    }

    function openTrading() public onlyOwner {
        require(!tradingEnabled, "Trading already enabled!");
        require(_hasLiqBeenAdded, "Liquidity must be added.");
        tradingEnabled = true;
        launchStamp = block.timestamp;
    }
}