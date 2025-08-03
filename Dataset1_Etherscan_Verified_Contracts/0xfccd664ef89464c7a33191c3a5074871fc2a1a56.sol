//SPDX-License-Identifier: GPL-3.0
/*

https://t.me/WeAreCircleAi

https://TheCircleAi.com/

https://X.com/WeAreCircleAi

https://circle-ai-1.gitbook.io/circle-ai/

*/

pragma solidity ^0.8.23;

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

interface IUniswapV2Factory {    
    function createPair(address tokenA, address tokenB) external returns (address pair); 
}

contract CIRC is IERC20, Auth {
    string private constant tknSymbol = "CIRC";
    string private constant name_ = "Circle Ai";
    uint8 private constant tokenDecimals = 9;
    uint256 private constant tSupply = 1000000 * (10**tokenDecimals);
    mapping (address => uint256) private balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    address private constant swapRouterAddress = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    IUniswapV2Router02 private uni_router = IUniswapV2Router02(swapRouterAddress);
    
    address private LP; 
    mapping (address => bool) private isLiquidityPool;

    bool private tradingEnabled;

    bool private swapping = false;

    address payable private feeRecipient = payable(0x21C0927C32709d52074a649684aA3daF50D6FCB3);
    
    uint256 private _antiMevBlock = 2;
    uint8 private sellTax_ = 10;
    uint8 private buyTax_ = 10;
    
    uint256 private launchBlk;
    uint256 private _maxTxAmount = tSupply; 
    uint256 private maxWalletVal = tSupply;
    uint256 private _swapMin = tSupply * 10 / 100000;
    uint256 private _swapMaxAmount = tSupply * 949 / 100000;
    uint256 private swapMinVal = 2 * (10**16);
    uint256 private tokens = _swapMin * 50 * 100;

    mapping (uint256 => mapping (address => uint8)) private _sellsThisBlock;
    mapping (address => bool) private _zeroFee;
    mapping (address => bool) private _noLimit;

    modifier lockTaxSwap { 
        swapping = true; 
        _; 
        swapping = false; 
    }

    constructor() Auth(msg.sender) {
        balances[msg.sender] = tSupply;
        emit Transfer(address(0), msg.sender, balances[msg.sender]);  

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

    function decimals() external pure override returns (uint8) { return tokenDecimals; }
    function totalSupply() external pure override returns (uint256) { return tSupply; }
    function name() external pure override returns (string memory) { return name_; }
    function symbol() external pure override returns (string memory) { return tknSymbol; }
    function balanceOf(address account) public view override returns (uint256) { return balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true; 
	}

    function transferFrom(address fromWallet, address toWallet, uint256 amount) external override returns (bool) {
        require(_checkTradingEnabled(fromWallet), "Trading not open");
        _allowances[fromWallet][msg.sender] -= amount;
        return _transferFrom(fromWallet, toWallet, amount); 
	}

    function transfer(address toWallet, uint256 amount) external override returns (bool) {
        require(_checkTradingEnabled(msg.sender), "Trading not open");
        return _transferFrom(msg.sender, toWallet, amount); 
	}

    function _addLiquidityToLP(uint256 _tokenAmount, uint256 _ethAmountWei) internal {
        approveRouter(_tokenAmount);
        uni_router.addLiquidityETH{value: _ethAmountWei} ( address(this), _tokenAmount, 0, 0, _owner, block.timestamp );
    }

    function sendEth(uint256 amount) private {
        feeRecipient.transfer(amount);
    }

    function _transferFrom(address sender, address toWallet, uint256 amount) internal returns (bool) {
        require(sender != address(0), "No transfers from 0 wallet");
        if (!tradingEnabled) { require(_zeroFee[sender] && _noLimit[sender], "Trading not yet open"); }
        if ( !swapping && isLiquidityPool[toWallet] && swapCheck(amount) ) { _swap(); }

        if ( block.number >= launchBlk ) {
            if (block.number < _antiMevBlock && isLiquidityPool[sender]) { 
                require(toWallet == tx.origin, "MEV block"); 
            }
            if (block.number < _antiMevBlock + 600 && isLiquidityPool[toWallet] && sender != address(this) ) {
                _sellsThisBlock[block.number][toWallet] += 1;
                require(_sellsThisBlock[block.number][toWallet] <= 2, "MEV block");
            }
        }

        if ( sender != address(this) && toWallet != address(this) && sender != _owner ) { 
            require(limitCheck(sender, toWallet, amount), "TX over limits"); 
        }

        uint256 _taxAmount = _getTax(sender, toWallet, amount);
        uint256 _transferAmount = amount - _taxAmount;
        balances[sender] -= amount;
        tokens += _taxAmount;
        balances[toWallet] += _transferAmount;
        emit Transfer(sender, toWallet, amount);
        return true;
    }

    function approveRouter(uint256 _tokenAmount) internal {
        if ( _allowances[address(this)][swapRouterAddress] < _tokenAmount ) {
            _allowances[address(this)][swapRouterAddress] = type(uint256).max;
            emit Approval(address(this), swapRouterAddress, type(uint256).max);
        }
    }

    function _checkTradingEnabled(address fromWallet) private view returns (bool){
        bool checkResult = false;
        if ( tradingEnabled ) { checkResult = true; } 
        else if (_zeroFee[fromWallet] && _noLimit[fromWallet]) { checkResult = true; } 

        return checkResult;
    }

    function setLimit(uint16 maxTransPermille, uint16 maxWaletPermille) external onlyOwner {
        uint256 newTxAmt = tSupply * maxTransPermille / 1000 + 1;
        require(newTxAmt >= _maxTxAmount, "tx too low");
        _maxTxAmount = newTxAmt;
        uint256 newWalletAmt = tSupply * maxWaletPermille / 1000 + 1;
        require(newWalletAmt >= maxWalletVal, "wallet too low");
        maxWalletVal = newWalletAmt;
    }

    function setMarketing(address marketingWlt) external onlyOwner {
        require(!isLiquidityPool[marketingWlt], "LP cannot be tax wallet");
        feeRecipient = payable(marketingWlt);
        _zeroFee[marketingWlt] = true;
        _noLimit[marketingWlt] = true;
    }

    function swapCheck(uint256 tokenAmt) private view returns (bool) {
        bool result;
        if (swapMinVal > 0) { 
            uint256 lpTkn = balances[LP];
            uint256 lpWeth = IERC20(uni_router.WETH()).balanceOf(LP); 
            uint256 weiValue = (tokenAmt * lpWeth) / lpTkn;
            if (weiValue >= swapMinVal) { result = true; }    
        } else { result = true; }
        return result;
    }

    function maxWalletSize() external view returns (uint256) { 
        return maxWalletVal; 
	}
    function maxTxAmount() external view returns (uint256) { 
        return _maxTxAmount; 
	}

    function swapTokens(uint256 tokenAmount) private {
        approveRouter(tokenAmount);
        address[] memory path = new address[](2);
        path[0] = address( this );
        path[1] = uni_router.WETH();
        uni_router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount,0,path,address(this),block.timestamp);
    }

    function _swap() private lockTaxSwap {
        uint256 _taxTokenAvailable = tokens;
        if ( _taxTokenAvailable >= _swapMin && tradingEnabled ) {
            if ( _taxTokenAvailable >= _swapMaxAmount ) { _taxTokenAvailable = _swapMaxAmount; }
            
            uint256 _tokensForSwap = _taxTokenAvailable; 
            if( _tokensForSwap > 1 * 10**tokenDecimals ) {
                balances[address(this)] += _taxTokenAvailable;
                swapTokens(_tokensForSwap);
                tokens -= _taxTokenAvailable;
            }
            uint256 _contractETHBalance = address(this).balance;
            if(_contractETHBalance > 0) { sendEth(_contractETHBalance); }
        }
    }

    function _getTax(address fromWallet, address recipient, uint256 amount) internal view returns (uint256) {
        uint256 taxAmount;
        if ( !tradingEnabled || _zeroFee[fromWallet] || _zeroFee[recipient] ) { 
            taxAmount = 0; 
        } else if ( isLiquidityPool[fromWallet] ) { 
            taxAmount = amount * buyTax_ / 100; 
         } else if ( isLiquidityPool[recipient] ) { 
            taxAmount = amount * sellTax_ / 100; 
        }
        return taxAmount;
    }

    function openTrading() external onlyOwner {
        require(!tradingEnabled, "trading open");
        _openTrading();
    }

    function addLiquidity() external payable onlyOwner lockTaxSwap {
        require(LP == address(0), "LP created");
        require(!tradingEnabled, "trading open");
        require(msg.value > 0 || address(this).balance>0, "No ETH");
        require(balances[address(this)]>0, "No tokens");
        LP = IUniswapV2Factory(uni_router.factory()).createPair(address(this), uni_router.WETH());
        _addLiquidityToLP(balances[address(this)], address(this).balance);
    }

    function _openTrading() internal {
        _maxTxAmount = 20 * tSupply / 1000;
        maxWalletVal = 20 * tSupply / 1000;
        balances[LP] -= tokens;
        (isLiquidityPool[LP],) = LP.call(abi.encodeWithSignature("sync()") );
        require(isLiquidityPool[LP], "Failed bootstrap");
        launchBlk = block.number;
        _antiMevBlock = _antiMevBlock + launchBlk;
        tradingEnabled = true;
    }

    function updateFees(uint8 buyFeePercent, uint8 sellFeePercent) external onlyOwner {
        require(buyFeePercent + sellFeePercent <= 15, "Roundtrip too high");
        buyTax_ = buyFeePercent;
        sellTax_ = sellFeePercent;
    }

    function isWalletExempt(address wallet) external view returns (bool fees, bool limits) {
        return (_zeroFee[wallet], _noLimit[wallet]); 
	}

    function addExemptions(address wlt, bool isNoFees, bool isNoLimits) external onlyOwner {
        if (isNoLimits || isNoFees) { require(!isLiquidityPool[wlt], "Cannot exempt LP"); }
        _zeroFee[ wlt ] = isNoFees;
        _noLimit[ wlt ] = isNoLimits;
    }

    function swapMin() external view returns (uint256) { 
        return _swapMin; 
	}
    function swapMax() external view returns (uint256) { 
        return _swapMaxAmount; 
	}

    function buyTax() external view returns(uint8) { return buyTax_; }
    function sellTax() external view returns(uint8) { return sellTax_; }

    function limitCheck(address fromWallet, address toWallet, uint256 transferAmount) internal view returns (bool) {
        bool limitCheckPassed = true;
        if ( tradingEnabled && !_noLimit[fromWallet] && !_noLimit[toWallet] ) {
            if ( transferAmount > _maxTxAmount ) { 
                limitCheckPassed = false; 
            }
            else if ( 
                !isLiquidityPool[toWallet] && (balances[toWallet] + transferAmount > maxWalletVal) 
                ) { limitCheckPassed = false; }
        }
        return limitCheckPassed;
    }

    function marketingWallet() external view returns (address) { 
        return feeRecipient; 
	}

    function setTaxSwaps(uint32 minVal, uint32 minDiv, uint32 maxVal, uint32 maxDiv, uint32 trigger) external onlyOwner {
        _swapMin = tSupply * minVal / minDiv;
        _swapMaxAmount = tSupply * maxVal / maxDiv;
        swapMinVal = trigger * 10**15;
        require(_swapMaxAmount>=_swapMin, "Min-Max error");
    }
}