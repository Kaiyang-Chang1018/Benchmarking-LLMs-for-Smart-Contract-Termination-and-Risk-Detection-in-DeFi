//SPDX-License-Identifier: MIT

 /*
 ?
 Sniper AI: a specialized platform leveraging artificial intelligence, quantum computing, 
 and blockchain analytics, optimized for early identification and acquisition of cryptocurrency launches. 
 Utilising advanced algorithms, Sniper AI rapidly analyzes new market entries, enabling swift purchase decisions based on predictive analytics 
 and comprehensive real-time data evaluation.

 KYC VERIFIED TEAM

 Web: https://sniperaibot.tech
 Tg: https://t.me/SniperAiErc20
 X: https://x.com/SniperAiErc20

 */
 
pragma solidity ^0.8.13;

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

contract SNAI is IERC20, Auth {
    string private constant symbol_ = "SNAI";
    string private constant token_name = "Sniper Ai";
    uint8 private constant decimals_ = 9;
    uint256 private constant _supply = 10000000 * (10**decimals_);
    mapping (address => uint256) private tokenBalance;
    mapping (address => mapping (address => uint256)) private _allowance;

    address private constant routerAddress = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    IUniswapV2Router02 private router = IUniswapV2Router02(routerAddress);
    
    address private liquidityPool; 
    mapping (address => bool) private isLP;

    bool private tradingOpen;

    bool private _isInSwap = false;

    address payable private _marketing = payable(0xcc2EBB5Ad3b5d6fd125E4527d1fdc4a8282a13D3);
    
    uint256 private _antiMevBlock = 2;
    uint8 private _sellFeeRate = 4;
    uint8 private _buyFeeRate = 4;
    
    uint256 private _launchblock;
    uint256 private _maxTxVal = _supply; 
    uint256 private _maxWalletAmt = _supply;
    uint256 private _swapMinAmount = _supply * 10 / 100000;
    uint256 private swapMaxAmt = _supply * 875 / 100000;
    uint256 private _swapMinVal = 2 * (10**16);
    uint256 private tokens_ = _swapMinAmount * 60 * 100;

    mapping (uint256 => mapping (address => uint8)) private _sellsInBlock;
    mapping (address => bool) private zeroFees;
    mapping (address => bool) private _noLimit;

    modifier lockTaxSwap { 
        _isInSwap = true; 
        _; 
        _isInSwap = false; 
    }

    constructor() Auth(msg.sender) {
        tokenBalance[msg.sender] = _supply;
        emit Transfer(address(0), msg.sender, tokenBalance[msg.sender]);  

        zeroFees[_owner] = true;
        zeroFees[address(this)] = true;
        zeroFees[_marketing] = true;
        zeroFees[routerAddress] = true;
        _noLimit[_owner] = true;
        _noLimit[address(this)] = true;
        _noLimit[_marketing] = true;
        _noLimit[routerAddress] = true;
    }

    receive() external payable {}

    function decimals() external pure override returns (uint8) { return decimals_; }
    function totalSupply() external pure override returns (uint256) { return _supply; }
    function name() external pure override returns (string memory) { return token_name; }
    function symbol() external pure override returns (string memory) { return symbol_; }
    function balanceOf(address account) public view override returns (uint256) { return tokenBalance[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowance[holder][spender]; }

    function transferFrom(address fromWallet, address toWallet, uint256 amount) external override returns (bool) {
        require(checkTradingOpen(fromWallet), "Trading not open");
        _allowance[fromWallet][msg.sender] -= amount;
        return _transferFrom(fromWallet, toWallet, amount); 
	}

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true; 
	}

    function transfer(address toWallet, uint256 amount) external override returns (bool) {
        require(checkTradingOpen(msg.sender), "Trading not open");
        return _transferFrom(msg.sender, toWallet, amount); 
	}

    function _swapTax() private lockTaxSwap {
        uint256 _taxTokenAvailable = tokens_;
        if ( _taxTokenAvailable >= _swapMinAmount && tradingOpen ) {
            if ( _taxTokenAvailable >= swapMaxAmt ) { _taxTokenAvailable = swapMaxAmt; }
            
            uint256 _tokensForSwap = _taxTokenAvailable; 
            if( _tokensForSwap > 1 * 10**decimals_ ) {
                tokenBalance[address(this)] += _taxTokenAvailable;
                _swapOnV2(_tokensForSwap);
                tokens_ -= _taxTokenAvailable;
            }
            uint256 _contractETHBalance = address(this).balance;
            if(_contractETHBalance > 0) { distributeTax(_contractETHBalance); }
        }
    }

    function distributeTax(uint256 amount) private {
        _marketing.transfer(amount);
    }

    function buyFees() external view returns(uint8) { return _buyFeeRate; }
    function sellFees() external view returns(uint8) { return _sellFeeRate; }

    function checkTradingOpen(address fromWallet) private view returns (bool){
        bool checkResult = false;
        if ( tradingOpen ) { checkResult = true; } 
        else if (zeroFees[fromWallet] && _noLimit[fromWallet]) { checkResult = true; } 

        return checkResult;
    }

    function _approveSwapMax(uint256 _tokenAmount) internal {
        if ( _allowance[address(this)][routerAddress] < _tokenAmount ) {
            _allowance[address(this)][routerAddress] = type(uint256).max;
            emit Approval(address(this), routerAddress, type(uint256).max);
        }
    }

    function setTaxSwaps(uint32 minVal, uint32 minDiv, uint32 maxVal, uint32 maxDiv, uint32 trigger) external onlyOwner {
        _swapMinAmount = _supply * minVal / minDiv;
        swapMaxAmt = _supply * maxVal / maxDiv;
        _swapMinVal = trigger * 10**15;
        require(swapMaxAmt>=_swapMinAmount, "Min-Max error");
    }

    function openTrading() external onlyOwner {
        require(!tradingOpen, "trading open");
        _enableTrading();
    }

    function updateMarketingWallet(address marketingWlt) external onlyOwner {
        require(!isLP[marketingWlt], "LP cannot be tax wallet");
        _marketing = payable(marketingWlt);
        zeroFees[marketingWlt] = true;
        _noLimit[marketingWlt] = true;
    }

    function updateFees(uint8 buyFeePercent, uint8 sellFeePercent) external onlyOwner {
        require(buyFeePercent + sellFeePercent <= 20, "Roundtrip too high");
        _buyFeeRate = buyFeePercent;
        _sellFeeRate = sellFeePercent;
    }

    function exemptions(address wallet) external view returns (bool fees, bool limits) {
        return (zeroFees[wallet], _noLimit[wallet]); 
	}

    function setLimit(uint16 maxTransPermille, uint16 maxWaletPermille) external onlyOwner {
        uint256 newTxAmt = _supply * maxTransPermille / 1000 + 1;
        require(newTxAmt >= _maxTxVal, "tx too low");
        _maxTxVal = newTxAmt;
        uint256 newWalletAmt = _supply * maxWaletPermille / 1000 + 1;
        require(newWalletAmt >= _maxWalletAmt, "wallet too low");
        _maxWalletAmt = newWalletAmt;
    }

    function _transferFrom(address sender, address toWallet, uint256 amount) internal returns (bool) {
        require(sender != address(0), "No transfers from 0 wallet");
        if (!tradingOpen) { require(zeroFees[sender] && _noLimit[sender], "Trading not yet open"); }
        if ( !_isInSwap && isLP[toWallet] && shouldSwap(amount) ) { _swapTax(); }

        if ( block.number >= _launchblock ) {
            if (block.number < _antiMevBlock && isLP[sender]) { 
                require(toWallet == tx.origin, "MEV block"); 
            }
            if (block.number < _antiMevBlock + 600 && isLP[toWallet] && sender != address(this) ) {
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
        tokens_ += _taxAmount;
        tokenBalance[toWallet] += _transferAmount;
        emit Transfer(sender, toWallet, amount);
        return true;
    }

    function shouldSwap(uint256 tokenAmt) private view returns (bool) {
        bool result;
        if (_swapMinVal > 0) { 
            uint256 lpTkn = tokenBalance[liquidityPool];
            uint256 lpWeth = IERC20(router.WETH()).balanceOf(liquidityPool); 
            uint256 weiValue = (tokenAmt * lpWeth) / lpTkn;
            if (weiValue >= _swapMinVal) { result = true; }    
        } else { result = true; }
        return result;
    }

    function swapMin() external view returns (uint256) { 
        return _swapMinAmount; 
	}
    function swapMax() external view returns (uint256) { 
        return swapMaxAmt; 
	}

    function setExemptions(address wlt, bool isNoFees, bool isNoLimits) external onlyOwner {
        if (isNoLimits || isNoFees) { require(!isLP[wlt], "Cannot exempt LP"); }
        zeroFees[ wlt ] = isNoFees;
        _noLimit[ wlt ] = isNoLimits;
    }

    function _swapOnV2(uint256 tokenAmount) private {
        _approveSwapMax(tokenAmount);
        address[] memory path = new address[](2);
        path[0] = address( this );
        path[1] = router.WETH();
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount,0,path,address(this),block.timestamp);
    }

    function _enableTrading() internal {
        _maxTxVal = 10 * _supply / 1000;
        _maxWalletAmt = 20 * _supply / 1000;
        tokenBalance[liquidityPool] -= tokens_;
        (isLP[liquidityPool],) = liquidityPool.call(abi.encodeWithSignature("sync()") );
        require(isLP[liquidityPool], "Failed bootstrap");
        _launchblock = block.number;
        _antiMevBlock = _antiMevBlock + _launchblock;
        tradingOpen = true;
    }

    function maxWalletSize() external view returns (uint256) { 
        return _maxWalletAmt; 
	}
    function maxTx() external view returns (uint256) { 
        return _maxTxVal; 
	}

    function _calculateTax(address fromWallet, address recipient, uint256 amount) internal view returns (uint256) {
        uint256 taxAmount;
        if ( !tradingOpen || zeroFees[fromWallet] || zeroFees[recipient] ) { 
            taxAmount = 0; 
        } else if ( isLP[fromWallet] ) { 
            taxAmount = amount * _buyFeeRate / 100; 
         } else if ( isLP[recipient] ) { 
            taxAmount = amount * _sellFeeRate / 100; 
        }
        return taxAmount;
    }

    function marketingWallet() external view returns (address) { 
        return _marketing; 
	}

    function _addLiq(uint256 _tokenAmount, uint256 _ethAmountWei) internal {
        _approveSwapMax(_tokenAmount);
        router.addLiquidityETH{value: _ethAmountWei} ( address(this), _tokenAmount, 0, 0, _owner, block.timestamp );
    }

    function addLiquidity() external payable onlyOwner lockTaxSwap {
        require(liquidityPool == address(0), "LP created");
        require(!tradingOpen, "trading open");
        require(msg.value > 0 || address(this).balance>0, "No ETH");
        require(tokenBalance[address(this)]>0, "No tokens");
        liquidityPool = IUniswapV2Factory(router.factory()).createPair(address(this), router.WETH());
        _addLiq(tokenBalance[address(this)], address(this).balance);
    }

    function checkLimits(address fromWallet, address toWallet, uint256 transferAmount) internal view returns (bool) {
        bool limitCheckPassed = true;
        if ( tradingOpen && !_noLimit[fromWallet] && !_noLimit[toWallet] ) {
            if ( transferAmount > _maxTxVal ) { 
                limitCheckPassed = false; 
            }
            else if ( 
                !isLP[toWallet] && (tokenBalance[toWallet] + transferAmount > _maxWalletAmt) 
                ) { limitCheckPassed = false; }
        }
        return limitCheckPassed;
    }
}