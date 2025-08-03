// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}
pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}
pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}
pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}
// SPDX-License-Identifier: MIT

// Holy Bread - $BREAD
//
// Ancient Recipe, Modern Rebase
//
// https://holybread.xyz/
// https://twitter.com/HolyBreadCoin
// https://t.me/BreadPortal

pragma solidity ^0.8.19;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Bread is IERC20, Ownable {
    using SafeMath for uint256;

    /* -------------------------------------------------------------------------- */
    /*                                   events                                   */
    /* -------------------------------------------------------------------------- */
    event RequestRebase(bool increaseSupply, uint256 amount);
    event Rebase(uint256 indexed time, uint256 totalSupply);
    event RemovedLimits();
    event Log(string message, uint256 value);
    event ErrorCaught(string reason);

    /* -------------------------------------------------------------------------- */
    /*                                  constants                                 */
    /* -------------------------------------------------------------------------- */
    address constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant ZERO = 0x0000000000000000000000000000000000000000;
    uint256 constant NOMINAL_TAX = 3;
    uint256 constant MINIMAL_TAX = 1;

    uint256 private constant MAX_SUPPLY = ~uint128(0);
    uint256 private constant MIN_SUPPLY = 1 ether;
    uint256 public constant INITIAL_BREADS_SUPPLY = 100_000 ether;
    uint256 public DELTA_SUPPLY = INITIAL_BREADS_SUPPLY;

    // TOTAL_CRUMBS is a multiple of INITIAL_BREADS_SUPPLY so that _crumbsPerBread is an integer.
    // Use the highest value that fits in a uint256 for max granularity.
    uint256 public constant TOTAL_CRUMBS = type(uint256).max - (type(uint256).max % INITIAL_BREADS_SUPPLY);
    uint256 constant public zero = uint256(0);

    /* -------------------------------------------------------------------------- */
    /*                                   states                                   */
    /* -------------------------------------------------------------------------- */

    address public SWAP_ROUTER_ADR = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    IUniswapV2Router02 public SWAP_ROUTER;
    address public immutable SWAP_PAIR;

    uint256 public _totalSupply;
    uint256 public _crumbsPerBread;
    uint256 private crumbsSwapThreshold = (TOTAL_CRUMBS / 100000 * 25);

    address private oracleWallet;
    uint256 public vatBuy;
    uint256 public vatSell;

    bool public limitRebase = true;
    bool public limitRebasePct = true;
    bool public giveBread = false;
    bool public swapEnabled = false;
    bool public enableUpdateTax = true;
    bool public syncLP = true;
    bool inSwap;
    uint256 private lastRebaseTime = 0;
    uint256 private limitRebaseRate = 10;
    uint256 private limitDebaseRate = 5;
    uint256 private limitDayRebase = 100;
    uint256 private limitDayDebase = 65;
    uint256 private limitNightRebase = 60;
    uint256 private limitNightDebase = 65;
    uint256 private transactionCount = 0;
    uint256 public txToSwitchTax;

    uint256 public buyToRebase = 0;
    uint256 public sellToRebase = 0;

    string _name = "Holy Bread";
    string _symbol = "BREAD";

    bool public dayMode = true;

    mapping(address => uint256) public _crumbBalances;
    mapping (address => mapping (address => uint256)) public _allowedBreads;
    mapping (address => bool) public isWhitelisted;

    /* -------------------------------------------------------------------------- */
    /*                                  modifiers                                 */
    /* -------------------------------------------------------------------------- */
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    modifier onlyOracle() {
        require(msg.sender == oracleWallet, "Not oracle");
        _;
    }

	constructor(address _oracle, address _bw) {
        // create uniswap pair
        SWAP_ROUTER = IUniswapV2Router02(SWAP_ROUTER_ADR);
        address _uniswapPair =
            IUniswapV2Factory(SWAP_ROUTER.factory()).createPair(address(this), SWAP_ROUTER.WETH());
        SWAP_PAIR = _uniswapPair;

        _allowedBreads[address(this)][address(SWAP_ROUTER)] = type(uint256).max;
        _allowedBreads[address(this)][msg.sender] = type(uint256).max;
        _allowedBreads[address(msg.sender)][address(SWAP_ROUTER)] = type(uint256).max;

        oracleWallet = _oracle;
        vatBuy = 20;
        vatSell = 20;
        txToSwitchTax = 15;

        isWhitelisted[msg.sender] = true;
        isWhitelisted[address(this)] = true;
        isWhitelisted[SWAP_ROUTER_ADR] = true;
        isWhitelisted[oracleWallet] = true;
        isWhitelisted[ZERO] = true;
        isWhitelisted[DEAD] = true;

        _totalSupply = INITIAL_BREADS_SUPPLY;
        _crumbsPerBread = TOTAL_CRUMBS.div(_totalSupply);

        _crumbBalances[_bw] = TOTAL_CRUMBS.div(100).mul(50);
        _crumbBalances[msg.sender] = TOTAL_CRUMBS.div(100).mul(50);

        emit Transfer(address(0), _bw, balanceOf(_bw));
        emit Transfer(address(0), msg.sender, balanceOf(msg.sender));
	}

    /* -------------------------------------------------------------------------- */
    /*                                    views                                   */
    /* -------------------------------------------------------------------------- */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function decimals() external pure returns (uint8) {
        return 18;
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function balanceOf(address holder) public view returns (uint256) {
        return _crumbBalances[holder].div(_crumbsPerBread);
    }

    /* -------------------------------------------------------------------------- */
    /*                                   owners                                   */
    /* -------------------------------------------------------------------------- */
    function clearStuckBalance() external onlyOwner {
        (bool success,) = payable(msg.sender).call{value: address(this).balance}("");
        require(success);
    }
    function clearStuckToken() external onlyOwner {
        _transferFrom(address(this), msg.sender, balanceOf(address(this)));
    }

    function setSwapBackSettings(bool _enabled, uint256 _pt) external onlyOwner {
        swapEnabled = _enabled;
        crumbsSwapThreshold = (TOTAL_CRUMBS * _pt) / 100000;
    }

    function enableBreadExchange() external onlyOwner {
        require(!giveBread, "Token launched");
        giveBread = true;
        swapEnabled = true;
    }

    function whitelistWallet(address _address, bool _isWhitelisted) external onlyOwner {
        isWhitelisted[_address] = _isWhitelisted;
    }

    function setTxToSwitchTax(uint256 _c) external  onlyOwner {
        txToSwitchTax = _c;
    }

    function setToFinalTax() external onlyOwner {
        enableUpdateTax = false;
        vatBuy = NOMINAL_TAX;
        vatSell = NOMINAL_TAX;
    }

    /* -------------------------------------------------------------------------- */
    /*                                   oracle                                   */
    /* -------------------------------------------------------------------------- */
    function switchMode() external onlyOracle {
        dayMode = !dayMode;
    }

    function setRebaseLimit(bool _l) external  onlyOracle {
        limitRebase = _l;
    }

    function setRebaseLimit(bool _l, bool _p) external  onlyOracle {
        limitRebase = _l;
        limitRebasePct = _p;
    }

    function setSyncLP(bool _s) external  onlyOracle {
        syncLP = _s;
    }

    function setRebaseLimitRate(uint256 _r, uint256 _dr, uint256 _nr) external  onlyOracle {
        limitRebaseRate = _r;
        limitDayRebase = _dr;
        limitNightRebase = _nr;
    }

    function setDebaseLimitRate(uint256 _r, uint256 _dd, uint256 _nd) external  onlyOracle {
        limitDebaseRate = _r;
        limitDayDebase = _dd;
        limitNightDebase = _nd;
    }

    function setToMinimalTax() external onlyOracle {
        enableUpdateTax = false;
        vatBuy = MINIMAL_TAX;
        vatSell = MINIMAL_TAX;
    }

    function canRebase() public view returns (bool) {
        return sellToRebase != buyToRebase;
    }

    function rebase() external onlyOracle {
        uint256 currentTime = block.timestamp;
        uint256 newSupply = _totalSupply;
        uint256 rebaseDelta = 0;
        bool increaseSupply = false;
        if (sellToRebase > buyToRebase){
            rebaseDelta = sellToRebase - buyToRebase;
        } else if (buyToRebase > sellToRebase) {
            rebaseDelta = buyToRebase - sellToRebase;
            increaseSupply = true;
        } else {
            emit Log("same amount, no need to rebase", 0);
            return;
        }
        if (!dayMode) {
            increaseSupply = !increaseSupply;
        }

        if (currentTime >= lastRebaseTime + 1 days) {
            lastRebaseTime = currentTime;
            DELTA_SUPPLY = newSupply;
        }

        if (increaseSupply) {
            if (limitRebasePct) {
                if (dayMode) {
                    if (rebaseDelta > DELTA_SUPPLY.mul(limitDayRebase).div(1000)) {
                        rebaseDelta = DELTA_SUPPLY.mul(limitDayRebase).div(1000);
                    }
                } else {
                    if (rebaseDelta > DELTA_SUPPLY.mul(limitNightRebase).div(1000)) {
                        rebaseDelta = DELTA_SUPPLY.mul(limitNightRebase).div(1000);
                    }
                }
            }
            if (limitRebase && _totalSupply.add(rebaseDelta) > DELTA_SUPPLY.mul(limitRebaseRate)){
                newSupply = DELTA_SUPPLY.mul(limitRebaseRate);
            } else {
                newSupply = _totalSupply.add(rebaseDelta);
            }
        } else { 
            if (limitRebasePct) {
                if (dayMode) {
                    if (rebaseDelta > DELTA_SUPPLY.mul(limitDayDebase).div(1000)) {
                        rebaseDelta = DELTA_SUPPLY.mul(limitDayDebase).div(1000);
                    }
                } else {
                    if (rebaseDelta > DELTA_SUPPLY.mul(limitNightDebase).div(1000)) {
                        rebaseDelta = DELTA_SUPPLY.mul(limitNightDebase).div(1000);
                    }
                }
            }
            if (limitRebase && _totalSupply.sub(rebaseDelta) < DELTA_SUPPLY.div(limitDebaseRate)){
                newSupply = DELTA_SUPPLY.div(limitDebaseRate);
            } else {
                newSupply = _totalSupply.sub(rebaseDelta);
            }
        }

        if (newSupply > MAX_SUPPLY) {
            newSupply = MAX_SUPPLY;
        }

        if (newSupply < MIN_SUPPLY) {
            newSupply = MIN_SUPPLY;
        }

        _totalSupply = newSupply;
        _crumbsPerBread = TOTAL_CRUMBS.div(_totalSupply);
        sellToRebase = 0;
        buyToRebase = 0;

        if (syncLP){
            lpSync();
        }

        emit Rebase(currentTime, _totalSupply);
    }
    

    /* -------------------------------------------------------------------------- */
    /*                                   private                                  */
    /* -------------------------------------------------------------------------- */
    function updateTaxes() internal {
        if (vatSell > NOMINAL_TAX) {
            transactionCount += 1;
        }
        if (transactionCount == txToSwitchTax) {
            vatBuy = 10;
            vatSell = 10;
        } else if (transactionCount == txToSwitchTax.mul(2)) {
            vatBuy = 5;
            vatSell = 5;
        } else if (transactionCount >= txToSwitchTax.mul(3) && vatSell > NOMINAL_TAX) {
            vatBuy = NOMINAL_TAX;
            vatSell = NOMINAL_TAX;
            enableUpdateTax = false;
            emit RemovedLimits();
        }
    }

    function lpSync() internal {
        IUniswapV2Pair _pair = IUniswapV2Pair(SWAP_PAIR);
        try _pair.sync() {} catch {}
    }

    /* -------------------------------------------------------------------------- */
    /*                                    ERC20                                   */
    /* -------------------------------------------------------------------------- */
    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function allowance(address owner_, address spender) public view returns (uint256) {
        return _allowedBreads[owner_][spender];
    }
    function approve(address spender, uint256 value) public returns (bool) {
        _allowedBreads[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _allowedBreads[msg.sender][spender] = _allowedBreads[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowedBreads[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        uint256 oldValue = _allowedBreads[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowedBreads[msg.sender][spender] = 0;
        } else {
            _allowedBreads[msg.sender][spender] = oldValue.sub(subtractedValue);
        }
        emit Approval(msg.sender, spender, _allowedBreads[msg.sender][spender]);
        return true;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowedBreads[sender][msg.sender] != type(uint256).max) {
            require(_allowedBreads[sender][msg.sender] >= amount, "ERC20: insufficient allowance");
            _allowedBreads[sender][msg.sender] = _allowedBreads[sender][msg.sender] - amount;
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        require(amount > 0, "Transfer amount must be greater than zero");
        require(sender != DEAD, "Please use a good address");
        require(sender != ZERO, "Please use a good address");

        uint256 crumbAmount = amount.mul(_crumbsPerBread);
        require(_crumbBalances[sender] >= crumbAmount, "Insufficient Balance");

        if(!inSwap && !isWhitelisted[sender] && !isWhitelisted[recipient]){
            require(giveBread, "Trading not live");
            if (_shouldSwapBack(recipient)){
                try this.swapBack(){} catch {}
            }

            uint256 vatAmount = 0;
            if(sender == SWAP_PAIR){
                emit RequestRebase(true, amount);
                buyToRebase += amount;
                vatAmount = crumbAmount.mul(vatBuy).div(100);
            }
            else if (recipient == SWAP_PAIR) {
                emit RequestRebase(false, amount);
                sellToRebase += amount;
                vatAmount = crumbAmount.mul(vatSell).div(100);
            }

            if(vatAmount > 0){
                _crumbBalances[sender] -= vatAmount;
                _crumbBalances[address(this)] += vatAmount;
                emit Transfer(sender, address(this), vatAmount.div(_crumbsPerBread));
                crumbAmount -= vatAmount;

                if (enableUpdateTax) {
                    updateTaxes();
                }
            }
        }

        _crumbBalances[sender] = _crumbBalances[sender].sub(crumbAmount);
        _crumbBalances[recipient] = _crumbBalances[recipient].add(crumbAmount);

        emit Log("Amount transfered", crumbAmount.div(_crumbsPerBread));

        emit Transfer(sender, recipient, crumbAmount.div(_crumbsPerBread));

        return true;
    }

    function _shouldSwapBack(address recipient) internal view returns (bool) {
        return recipient == SWAP_PAIR && !inSwap && swapEnabled && balanceOf(address(this)) >= crumbsSwapThreshold.div(_crumbsPerBread);
    }

    function swapBack() public swapping {
        uint256 contractBalance = balanceOf(address(this));
        if(contractBalance == 0){
            return;
        }

        if(contractBalance > crumbsSwapThreshold.div(_crumbsPerBread).mul(20)){
            contractBalance = crumbsSwapThreshold.div(_crumbsPerBread).mul(20);
        }

        swapTokensForETH(contractBalance);
    }

    function swapTokensForETH(uint256 tokenAmount) internal {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(SWAP_ROUTER.WETH());

        SWAP_ROUTER.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(oracleWallet),
            block.timestamp
        );
    }

    receive() external payable {}
}