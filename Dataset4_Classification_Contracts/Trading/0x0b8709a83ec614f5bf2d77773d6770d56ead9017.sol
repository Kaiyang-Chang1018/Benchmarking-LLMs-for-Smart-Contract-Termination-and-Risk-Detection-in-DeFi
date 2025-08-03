//SPDX-License-Identifier: MIT

/*
    Website: https://virtuai.cloud/
    Twitter: https://twitter.com/virtucloud_ai
    Gitbook: https://virtuai.gitbook.io/virtuai-the-all-in-one-ai-tool/

    VirtuAi encompasses a wide range of different Al bots in one place, that's intuitive and easy to understand.  
    The Bots we currently have integrated are conversation, code generation, music generation, video generation, and image generation.
*/
pragma solidity 0.8.25;

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

contract VirtuAI is Context, IERC20, Ownable {
    using SafeMath for uint256;

    uint256 public _buyFees = 25;
    uint256 public _sellFees = 25;
    
    uint256 public revenueSharePart = 65;
    uint256 public marketingPart = 35;

    address public _revenueShareWallet;

    string private constant _name = unicode"VirtuAI";
    string private constant _symbol = unicode"VAI";

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 100_000_000 * 10 ** _decimals;

    mapping (address => bool) private _excludedFromFee;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) private _balances;
    bool public tradingEnabled;
    uint256 private _swapTokensAtAmount = _tTotal / 750;
    uint256 private _maxTaxSwap = _tTotal / 50;
    bool private inSwap;
    IUniswapV2Router02 uniswapV2Router;

    uint256 public _maxWallet = _tTotal * 2 / 100;
    address payable public _marketingWallet;

    address public uniswapV2Pair;
    bool private swapEnabled = true;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor () {
        _marketingWallet = payable(_msgSender());
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); // 0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24
        _excludedFromFee[address(uniswapV2Router)] = true;
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        _excludedFromFee[address(this)] = true;
        _excludedFromFee[msg.sender] = true;
        _balances[msg.sender] = _tTotal;
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
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        uint256 taxAmount=0;
        if (!_excludedFromFee[from] && !_excludedFromFee[to]) {
            require(tradingEnabled ,"Trading has not been started yet!");

            taxAmount = amount * _buyFees / 100;

            if (to != uniswapV2Pair) {
                require(balanceOf(to) + amount <= _maxWallet, "Over max wallet.");
            }

            if(to == uniswapV2Pair){
                taxAmount = amount * _sellFees  / 100;
                require(_swapTokensAtAmount < _tTotal);
            }

            if (from == uniswapV2Pair) {
                require(balanceOf(to) + amount <= _maxWallet, "Over max wallet.");
            }

            uint256 contractBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled && contractBalance>_swapTokensAtAmount) {
                swapTokensForEth(min(amount,min(contractBalance,_maxTaxSwap)));
            }
        }

        if(taxAmount > 0){
          _balances[address(this)] = _balances[address(this)].add(taxAmount);
          emit Transfer(from, address(this),taxAmount);
        }
        _balances[from] -= (amount);
        _balances[to] += amount - taxAmount;
        emit Transfer(from, to, amount - (taxAmount));
    }

    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
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
            _marketingWallet,
            block.timestamp
        );
    }

    function enableTrading() external onlyOwner {
        tradingEnabled = true;
    }

    function manualSwap() external onlyOwner {
        uint256 contractBalance = balanceOf(address(this));
        swapTokensForEth(min(contractBalance,_maxTaxSwap));
    }
    
    function setMaxWallet(uint amount) external onlyOwner {
        require(amount >= _tTotal / 500);
        _maxWallet = amount;
    }

    function setSwapEnabled(bool status) external onlyOwner {
        swapEnabled = status;
    }

    function setSwapTokensAtAmount(uint amount) external onlyOwner {
        _swapTokensAtAmount = amount;
    }

    function setFees(uint newBuyFee, uint newSellFee) external onlyOwner {
        _buyFees = newBuyFee;
        _sellFees  = newSellFee;
        require(newBuyFee <= 30);
        require(newSellFee <= 30);
    }

    function setVAIRevShareWallet(address wallet) external onlyOwner {
        _revenueShareWallet = wallet;
    }

    function removeFees() external onlyOwner {
        _buyFees=3;
        _sellFees=3;
    }

    function removeLimits() external onlyOwner {
        _maxWallet = _tTotal;
    }

    function excludeFromFees(address account, bool status) external onlyOwner {
        _excludedFromFee[account] = status;
    }

    function setMarketingWallet(address payable _wallet) external onlyOwner {
        _marketingWallet = _wallet;
    }

    receive() external payable {}
}