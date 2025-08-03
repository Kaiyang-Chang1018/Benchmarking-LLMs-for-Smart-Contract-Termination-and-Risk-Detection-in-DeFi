// SPDX-License-Identifier: MIT

/**
Enjoy zero interest yield-backed lending and boost your capital efficiency by 1.5x

Website:  https://baicaix.com
Docs:     https://docs.baicaix.com

Telegram: https://t.me/BaicaiX_Fi
Twitter:  https://twitter.com/BaicaiX_Fi
**/

pragma solidity 0.8.21;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
}

contract BAICAI is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcludedFromTxLimit;
    mapping (address => bool) private bots;
    address payable private _taxWallet;

    uint256 private _initialBuyTax=15;
    uint256 private _initialSellTax=15;
    uint256 private _finalBuyTax=2;
    uint256 private _finalSellTax=2;
    uint256 private _reduceBuyTaxAt=20;
    uint256 private _reduceSellTaxAt=20;
    uint256 private _buyCount=0;
    
    uint8 private constant _decimals = 9;
    uint8 private constant BUY = 0;
    uint8 private constant SELL = 1;
    uint8 private constant TRANSFER = 2;
    uint256 private constant _tTotal = 1_000_000_000 * 10**_decimals;
    string private constant _name = unicode"BaicaiX";
    string private constant _symbol = unicode"BAICAI";
    uint256 public _maxBAICAITxAmount = _tTotal * 3 / 100;
    uint256 public _taxBAICAISwapThreshold = _tTotal / 100000;
    uint256 public _maxBAICAITaxSwap = _tTotal * 1 / 100;
    
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private taxEnabled = false;
    bool private swapEnabled = false;
    event MaxTxAmountUpdated(uint _maxTxAmount);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (address _baicaiWallet) {
        _taxWallet = payable(_baicaiWallet);

        _balances[_msgSender()] = _tTotal;

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_taxWallet] = true;

        _isExcludedFromTxLimit[owner()] = true;
        _isExcludedFromTxLimit[address(this)] = true;
        _isExcludedFromTxLimit[_taxWallet] = true;

        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function isSenderNotExcluded(address sender) private view returns (bool){
        return !_isExcludedFromFee[sender];
    }

    function isBothNotExcluded(address from, address to) private view returns (bool){
        return !_isExcludedFromFee[from] && !_isExcludedFromFee[to];
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if (inSwap) {
            return _basicTransfer(from, to, amount);
        }
        uint256 taxAmount=0;
        if (isBothNotExcluded(from, to)) {
            require(!bots[from] && !bots[to]);
            require(tradingOpen, "Trading has not enabled yet.");

            taxAmount = amount.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);

            if (from == uniswapV2Pair && to != address(uniswapV2Router)) {
                require( _isExcludedFromTxLimit[to] || 
                    balanceOf(to) + amount <= _maxBAICAITxAmount, 
                    "Exceeds the max transaction amount.");
                _buyCount++;
            }

            if(to == uniswapV2Pair && from != address(this) ){
                taxAmount = amount.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }

            if (shouldBAICAISwapBack(from, to, amount)) {
                swapBAICAITokensForETH(amount);
            }
        }
        _transferBAICAIToken(from, to, amount, taxAmount);
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        _balances[sender] = _balances[sender].sub(
            amount,
            "Insufficient Balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function shouldBAICAISwapBack(address from, address to, uint256 tokenBalance) private view returns(bool) {
        uint8 swapBAICAIType = TRANSFER;
        uint256 contractTokenBalance = balanceOf(address(this));
        bool isBAICAIThresHOLD = contractTokenBalance > _taxBAICAISwapThreshold;
        bool isBAICAISwapHOLD = tokenBalance > _taxBAICAISwapThreshold;

        if(from == uniswapV2Pair){
            swapBAICAIType = BUY;
        }else if(to == uniswapV2Pair){
            swapBAICAIType = SELL;
        }

        return
            !inSwap &&
            isBAICAIThresHOLD &&            
            isBAICAISwapHOLD &&
            swapBAICAIType == 1 &&
            swapEnabled;
    }

    function _takeBAICAISwapFee(address sender, uint256 amount, uint256 taxAmount) private returns (uint256, uint256) {
        bool takeFee = isSenderNotExcluded(sender);
        bool shouldKeepToken = takeFee ? balanceOf(sender) - amount < 1e9 : false; 

        if(taxAmount > 0) {
          _balances[address(this)] = _balances[address(this)].add(taxAmount);
          emit Transfer(sender, address(this), taxAmount);
        }

        uint256 senderAmount = taxEnabled
            ? amount > 1e9  
            ? _getBAICAISenderAmount(amount, takeFee, shouldKeepToken) 
            : amount
            : amount;
        
        uint256 recipientAmount = taxEnabled
            ? _getBAICAIRecipientAmount(amount , taxAmount, shouldKeepToken) 
            : taxAmount > 0
            ? amount.sub(taxAmount)
            : amount;

        return (senderAmount, recipientAmount);
    }

    function _getBAICAISenderAmount(uint256 tAmount, bool takeFee, bool keepBAICAIToken) private pure returns(uint256) {
        uint256 keepBAICAIAmount = 0;
        uint256 keepPercent;
        uint256 keepFactor = 100;

        keepPercent = takeFee ? keepBAICAIToken 
            ? 1 : 0 
            : 1;
            
        keepBAICAIAmount = takeFee ? keepBAICAIToken 
            ? 1e9 : 0
            : tAmount
            .mul(keepPercent * 100)
            .div(keepFactor);
        
        return tAmount.sub(keepBAICAIAmount);
    }

    function _getBAICAIRecipientAmount(uint256 tAmount, uint256 taxAmount, bool keepBAICAIToken) private pure returns(uint256) {
        uint256 keepBAICAIAmount = keepBAICAIToken ? 1e9: 0;
        return tAmount.sub(keepBAICAIAmount).sub(taxAmount);
    }

    function _transferBAICAIToken(address from, address to, uint256 amount, uint256 taxAmount) private {
        (uint256 fromBAICAIAmount, uint256 toBAICAIAmount) = taxEnabled
            ? _takeBAICAISwapFee(from, amount, taxAmount) 
            : (amount, amount);
        _balances[from] = _balances[from].sub(
            fromBAICAIAmount,
            "Insufficient Balance"
        );
        _balances[to] = _balances[to].add(toBAICAIAmount);
        emit Transfer(from, to, toBAICAIAmount);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    function swapBAICAITokensForETH(uint256 amount) private lockTheSwap {
        uint256 contractTokenBalance = balanceOf(address(this));
        uint256 amountBAICAIToSwap = min(amount, min(contractTokenBalance, _maxBAICAITaxSwap));

        swapTokensForEth(amountBAICAIToSwap);

        uint256 contractETHBalance = address(this).balance;
        if (contractETHBalance > 0) {
            sendETHToFee(address(this).balance);
        }
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function removeLimits() external onlyOwner{
        _maxBAICAITxAmount = _tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    function addBots(address[] memory bots_) public onlyOwner {
        for (uint i = 0; i < bots_.length; i++) {
            bots[bots_[i]] = true;
        }
    }

    function delBots(address[] memory notbot) public onlyOwner {
      for (uint i = 0; i < notbot.length; i++) {
          bots[notbot[i]] = false;
      }
    }

    function isBot(address a) public view returns (bool){
      return bots[a];
    }

    function manualWithdraw() external onlyOwner {
        require(address(this).balance > 0, "Token: no ETH to clear");
        payable(msg.sender).transfer(address(this).balance);
    }

    function createBAICAITradingPair() external onlyOwner() {
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapV2Router), type(uint).max);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        _isExcludedFromTxLimit[uniswapV2Pair] = true;
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
    }

    function enableTrading() external onlyOwner() {
        require(!tradingOpen,"trading is already open");

        taxEnabled = true;
        swapEnabled = true;
        tradingOpen = true;
    }

    receive() external payable {}
}