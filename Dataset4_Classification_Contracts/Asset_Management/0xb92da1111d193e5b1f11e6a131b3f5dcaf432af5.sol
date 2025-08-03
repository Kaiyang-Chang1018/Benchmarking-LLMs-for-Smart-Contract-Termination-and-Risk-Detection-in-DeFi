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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SignedSafeMath.sol)

pragma solidity ^0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SignedSafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */
library SignedSafeMath {
    /**
     * @dev Returns the multiplication of two signed integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two signed integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(int256 a, int256 b) internal pure returns (int256) {
        return a / b;
    }

    /**
     * @dev Returns the subtraction of two signed integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        return a - b;
    }

    /**
     * @dev Returns the addition of two signed integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(int256 a, int256 b) internal pure returns (int256) {
        return a + b;
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
//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/math/SignedSafeMath.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "./Pool.sol";

contract Stakify is IERC20, Ownable {
    using SafeMath for uint256;
    using SignedSafeMath for int256;

    event LogRebase(uint256 indexed epoch, uint256 totalSupply);
    event RepellentFeeActivated(uint256 activatedAmount);
    event RepellentFeeDisabled(uint256 disabledAmount);

    IUniswapV2Pair public pairContract;
    mapping(address => bool) _isFeeExempt;
    mapping(address => bool) isAuthorized;
    mapping(address => bool) isMaxWalletExcluded;
    mapping(address => bool) isMaxTxExcluded;

    modifier validRecipient(address to) {
        require(to != address(0x0));
        _;
    }

    string constant _name = "Stakify";
    string constant _symbol = "SIFY";
    uint8 constant _decimals = 18;

    uint256 public constant DECIMALS = 18;
    uint256 public constant MAX_UINT256 = ~uint256(0);
    uint8 public constant RATE_DECIMALS = 11;

    uint256 private constant INITIAL_FRAGMENTS_SUPPLY =
        100 * 10 ** 6 * 10 ** DECIMALS;

    uint256 public autoBurnFee = 0;
    uint256 public liquidityFee = 0;
    uint256 public treasuryFee = 0;
    uint256 public totalFee = 0;

    uint256 public repellentSellAutoBurnFee = 15;
    uint256 public repellentSellLiquidityFee = 5;
    uint256 public repellentSellTreasuryFee = 10;
    uint256 public repellentSellTotalFee = 30;

    uint256 public repellentBuyAutoBurnFee = 1;
    uint256 public repellentBuyLiquidityFee = 1;
    uint256 public repellentBuyTreasuryFee = 1;
    uint256 public repellentBuyTotalFee = 3;

    uint256 public firstTax = 30;

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    address BUSD = 0xdAC17F958D2ee523a2206206994597C13D831ec7;

    address public treasuryFeeWallet =
        0xdAb6280d5a87c10250F454EE3AD3b3b0C1A274C0;

    bool public swapEnabled = true;

    IUniswapV2Router02 public router;

    enum LPLevels {
        Level1,
        Level2,
        Level3,
        Level4,
        Level5
    }

    LPLevels public currentLpLevel;

    ReferalPool public referalPool;

    uint256 public lastLPCheckedAt;
    uint256 public lastLPAmount;
    uint256 public lpCheckFrequency = 24 hours;

    struct LPRange {
        uint256 minLimit;
        uint256 maxLimit;
        uint256 dropLimit;
        uint256 recoverLimit;
    }

    mapping(LPLevels => LPRange) public lpRanges;

    address public pair;
    bool inSwap = false;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    uint256 private constant TOTAL_GONS =
        MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);

    bool public tradingOpen = false;

    bool public isRepellentFee;

    uint256 public repellentFeeActivatedAt;
    uint256 public repellentFeeActivatedAmount;
    uint256 public repellentFeeRecoverAmount;

    uint256 public lastRepellentFeeActivatedAt;
    uint256 public lastRepellentFeeRecoveredAt;

    bool public _autoRebase;
    uint256 public _initRebaseStartTime;
    uint256 public _lastRebasedTime;
    uint256 public _lastAddLiquidityTime;
    uint256 public launchBlock;
    uint256 public launchTime;
    uint256 public _totalSupply;
    uint256 private _gonsPerFragment;

    uint256 public maxWallet = 2;
    uint256 public maxTransaction = 2;

    mapping(uint256 => uint256) public rebaseRates;

    mapping(address => uint256) private _gonBalances;
    mapping(address => mapping(address => uint256)) private _allowedFragments;

    constructor() {
        router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        pair = IUniswapV2Factory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );

        address _newOwner = 0x64Ab7F64187AF212007A3EE9fdF990101DE4Bc16;

        isMaxWalletExcluded[_newOwner] = true;
        isMaxTxExcluded[_newOwner] = true;

        _allowedFragments[address(this)][address(router)] = type(uint256).max;
        pairContract = IUniswapV2Pair(pair);

        isAuthorized[_newOwner] = true;

        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
        _gonBalances[_newOwner] = TOTAL_GONS;
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);

        _isFeeExempt[_newOwner] = true;
        _isFeeExempt[address(this)] = true;

        lpRanges[LPLevels.Level1].minLimit = 0;
        lpRanges[LPLevels.Level1].maxLimit = 100000 ether;
        lpRanges[LPLevels.Level1].dropLimit = 1000;
        lpRanges[LPLevels.Level1].recoverLimit = 2000;

        lpRanges[LPLevels.Level2].minLimit = 100000 ether;
        lpRanges[LPLevels.Level2].maxLimit = 200000 ether;
        lpRanges[LPLevels.Level2].dropLimit = 750;
        lpRanges[LPLevels.Level2].recoverLimit = 1500;

        lpRanges[LPLevels.Level3].minLimit = 200000 ether;
        lpRanges[LPLevels.Level3].maxLimit = 500000 ether;
        lpRanges[LPLevels.Level3].dropLimit = 500;
        lpRanges[LPLevels.Level3].recoverLimit = 1000;

        lpRanges[LPLevels.Level4].minLimit = 500000 ether;
        lpRanges[LPLevels.Level4].maxLimit = 1000000 ether;
        lpRanges[LPLevels.Level4].dropLimit = 250;
        lpRanges[LPLevels.Level4].recoverLimit = 500;

        lpRanges[LPLevels.Level5].minLimit = 1000000 ether;
        lpRanges[LPLevels.Level5].maxLimit = 600000 ether;
        lpRanges[LPLevels.Level5].dropLimit = 100;
        lpRanges[LPLevels.Level5].recoverLimit = 200;

        referalPool = new ReferalPool(_newOwner, address(this));

        rebaseRates[0] = 1990454926;
        rebaseRates[1] = 197041366050627;
        rebaseRates[2] = 194889257616765;
        rebaseRates[3] = 19256552122506;
        rebaseRates[4] = 190040343656622;
        rebaseRates[5] = 187275393171979;
        rebaseRates[6] = 18422022807982;
        rebaseRates[7] = 180806586722789;
        rebaseRates[8] = 176938855799049;
        rebaseRates[9] = 172477165745424;
        rebaseRates[10] = 167204993319412;
        rebaseRates[11] = 160760319411521;
        rebaseRates[12] = 152466421092887;
        rebaseRates[13] = 140811084880022;
        rebaseRates[14] = 121016398099906;

        _transferOwnership(_newOwner);
        emit Transfer(address(0x0), _newOwner, _totalSupply);
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

    function rebase() internal {
        if (inSwap) return;
        uint256 rebaseRate;
        uint256 deltaTimeFromInit = block.timestamp - _initRebaseStartTime;
        uint256 deltaTime = block.timestamp - _lastRebasedTime;
        uint256 times = deltaTime.div(900);

        if (deltaTimeFromInit <= 10 days) {
            rebaseRate = rebaseRates[0];
        } else if (deltaTimeFromInit < 150 days) {
            uint256 numberOf10Days = deltaTimeFromInit / 10 days;
            rebaseRate = rebaseRates[numberOf10Days];
        } else {
            rebaseRate = 272039454237335;
        }

        for (uint256 i = 0; i < times; i++) {
            if (deltaTimeFromInit >= 150 days) {
                uint256 increaseSupply = _totalSupply.mul(rebaseRate).div(
                    10 ** 18
                );
                _totalSupply = _totalSupply.add(increaseSupply);
            } else {
                uint256 increaseSupply = _totalSupply.mul(rebaseRate).div(
                    10 ** 11
                );
                _totalSupply = _totalSupply.add(increaseSupply);
            }
        }

        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
        _lastRebasedTime = _lastRebasedTime.add(times.mul(900));

        pairContract.sync();

        emit LogRebase(block.timestamp, _totalSupply);
    }

    function transfer(
        address to,
        uint256 value
    ) external override validRecipient(to) returns (bool) {
        _transferFrom(msg.sender, to, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external override validRecipient(to) returns (bool) {
        if (_allowedFragments[from][msg.sender] != type(uint256).max) {
            _allowedFragments[from][msg.sender] = _allowedFragments[from][
                msg.sender
            ].sub(value, "Insufficient Allowance");
        }
        _transferFrom(from, to, value);
        return true;
    }

    function _basicTransfer(
        address from,
        address to,
        uint256 amount
    ) internal returns (bool) {
        uint256 gonAmount = amount.mul(_gonsPerFragment);
        _gonBalances[from] = _gonBalances[from].sub(gonAmount);
        _gonBalances[to] = _gonBalances[to].add(gonAmount);
        return true;
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        if (!isAuthorized[sender]) {
            require(tradingOpen, "Trading not open yet");
        }

        if (inSwap || sender == address(referalPool)) {
            return _basicTransfer(sender, recipient, amount);
        }

        if (
            !isMaxWalletExcluded[recipient] &&
            recipient != address(pair) &&
            tradingOpen
        ) {
            uint256 _balaceAfter = balanceOf(recipient) + amount;

            require(
                _balaceAfter <= ((_totalSupply * maxWallet) / 100),
                "Max Wallet Exceeded"
            );
        }

        if (!isMaxTxExcluded[sender]) {
            require(
                amount <= ((_totalSupply * maxTransaction) / 100),
                "Max transaction exceeded"
            );
        }

        if (
            (lastLPCheckedAt + lpCheckFrequency) < block.timestamp &&
            !isRepellentFee &&
            tradingOpen
        ) {
            uint256 lpBnbBalance = IERC20(router.WETH()).balanceOf(
                address(pair)
            );
            lastLPAmount = getBnbPrice(lpBnbBalance);
            lastLPCheckedAt = block.timestamp;
        }

        if (sender == pair) {
            if (referalPool.userReferal(recipient) != ZERO) {
                referalPool.setReferalBonus(recipient, amount);
            }
        }
        if (tradingOpen) {
            calculateLPStatus();
        }

        if (shouldRebase()) {
            rebase();
        }

        if (shouldSwapBack()) {
            swapBack();
        }

        uint256 gonAmount = amount.mul(_gonsPerFragment);
        _gonBalances[sender] = _gonBalances[sender].sub(gonAmount);
        uint256 gonAmountReceived = shouldTakeFee(sender, recipient)
            ? takeFee(sender, recipient, gonAmount)
            : gonAmount;
        _gonBalances[recipient] = _gonBalances[recipient].add(
            gonAmountReceived
        );

        emit Transfer(
            sender,
            recipient,
            gonAmountReceived.div(_gonsPerFragment)
        );
        return true;
    }

    function takeFee(
        address sender,
        address recipient,
        uint256 gonAmount
    ) internal returns (uint256) {
        uint256 feeAmount = 0;

        uint256 tokensToBurn = 0;

        if (!isRepellentFee) {
            if (recipient == pair) {
                if (block.number < (launchBlock + 2))
                    feeAmount = gonAmount.div(100).mul(45);
                else if (block.timestamp < (launchTime + 24 hours))
                    feeAmount = gonAmount.div(100).mul(firstTax);
                else {
                    feeAmount = gonAmount.div(100).mul(totalFee);
                    tokensToBurn = feeAmount.mul(autoBurnFee).div(totalFee);
                }
            } else {
                feeAmount = gonAmount.div(100).mul(totalFee);

                tokensToBurn = feeAmount.mul(autoBurnFee).div(totalFee);
            }
        } else {
            if (recipient == pair) {
                feeAmount = gonAmount.div(100).mul(repellentSellTotalFee);

                tokensToBurn = feeAmount.mul(repellentSellAutoBurnFee).div(
                    repellentSellTotalFee
                );
            } else {
                feeAmount = gonAmount.div(100).mul(repellentBuyTotalFee);

                tokensToBurn = feeAmount.mul(repellentBuyAutoBurnFee).div(
                    repellentBuyTotalFee
                );
            }
        }

        feeAmount = feeAmount.sub(tokensToBurn);

        _gonBalances[DEAD] = _gonBalances[DEAD].add(tokensToBurn);

        emit Transfer(sender, DEAD, tokensToBurn.div(_gonsPerFragment));
        _gonBalances[address(this)] = _gonBalances[address(this)].add(
            feeAmount
        );

        emit Transfer(sender, address(this), feeAmount.div(_gonsPerFragment));
        return gonAmount.sub(feeAmount + tokensToBurn);
    }

    function swapAndLiquify(uint256 tokens) private {
        // split the contract balance into halves
        uint256 half = tokens.div(2);
        uint256 otherHalf = tokens.sub(half);

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        // make the swap
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
        // add the liquidity
        router.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(DEAD),
            block.timestamp
        );
    }

    function swapBack() internal swapping {
        uint256 contractTokenBalance = balanceOf(address(this));

        if (contractTokenBalance == 0 && totalFee == 0) return;

        uint256 _totalSwapFees = liquidityFee + treasuryFee;

        uint256 _tokensToTreasury = (contractTokenBalance * treasuryFee) /
            _totalSwapFees;

        if (_tokensToTreasury > 0) {
            swapTokensForEth(_tokensToTreasury);
            payable(treasuryFeeWallet).transfer(address(this).balance);
        }
        if ((contractTokenBalance - _tokensToTreasury) > 0)
            swapAndLiquify(contractTokenBalance - _tokensToTreasury);
    }

    function shouldTakeFee(
        address from,
        address to
    ) internal view returns (bool) {
        return (pair == from || pair == to) && !_isFeeExempt[from];
    }

    function shouldRebase() internal view returns (bool) {
        return
            _autoRebase &&
            msg.sender != pair &&
            !inSwap &&
            tradingOpen &&
            block.timestamp >= (_lastRebasedTime + 15 minutes);
    }

    function shouldSwapBack() internal view returns (bool) {
        return !inSwap && msg.sender != pair && swapEnabled;
    }

    function enableSwap(bool status) external onlyOwner {
        swapEnabled = status;
    }

    function setAutoRebase(bool _flag) external onlyOwner {
        if (_flag) {
            _autoRebase = _flag;
            _lastRebasedTime = block.timestamp;
        } else {
            _autoRebase = _flag;
        }
    }

    function allowance(
        address owner_,
        address spender
    ) external view override returns (uint256) {
        return _allowedFragments[owner_][spender];
    }

    function enableTrading() external onlyOwner {
        require(!tradingOpen, "Already Enabaled");
        tradingOpen = true;
        launchBlock = block.number;
        launchTime = block.timestamp;
        _initRebaseStartTime = block.timestamp;
        _lastRebasedTime = block.timestamp;
        _autoRebase = true;
    }

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) external returns (bool) {
        uint256 oldValue = _allowedFragments[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowedFragments[msg.sender][spender] = 0;
        } else {
            _allowedFragments[msg.sender][spender] = oldValue.sub(
                subtractedValue
            );
        }
        emit Approval(
            msg.sender,
            spender,
            _allowedFragments[msg.sender][spender]
        );
        return true;
    }

    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) external returns (bool) {
        _allowedFragments[msg.sender][spender] = _allowedFragments[msg.sender][
            spender
        ].add(addedValue);
        emit Approval(
            msg.sender,
            spender,
            _allowedFragments[msg.sender][spender]
        );
        return true;
    }

    function approve(
        address spender,
        uint256 value
    ) external override returns (bool) {
        _allowedFragments[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function checkFeeExempt(address _addr) external view returns (bool) {
        return _isFeeExempt[_addr];
    }

    function getCirculatingSupply() public view returns (uint256) {
        return
            (TOTAL_GONS.sub(_gonBalances[DEAD]).sub(_gonBalances[ZERO])).div(
                _gonsPerFragment
            );
    }

    function isNotInSwap() external view returns (bool) {
        return !inSwap;
    }

    function manualSync() external {
        IUniswapV2Pair(pair).sync();
    }

    function setFeeReceivers(address _treasuryFeeWallet) external onlyOwner {
        treasuryFeeWallet = _treasuryFeeWallet;
    }

    function getLiquidityBacking(
        uint256 accuracy
    ) public view returns (uint256) {
        uint256 liquidityBalance = _gonBalances[pair].div(_gonsPerFragment);
        return
            accuracy.mul(liquidityBalance.mul(2)).div(getCirculatingSupply());
    }

    function setWhitelist(address _addr, bool _status) external onlyOwner {
        _isFeeExempt[_addr] = _status;
    }

    function setLP(address _address) external onlyOwner {
        pairContract = IUniswapV2Pair(_address);
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _gonBalances[account].div(_gonsPerFragment);
    }

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    function _transferBNBToWallet(
        address payable recipient,
        uint256 amount
    ) private {
        recipient.transfer(amount);
    }

    function calculateLPStatus() internal {
        uint256 lpBnbBalance = IERC20(router.WETH()).balanceOf(address(pair));
        uint256 lpBalance = getBnbPrice(lpBnbBalance);

        if (
            lpBalance >= lpRanges[LPLevels.Level1].minLimit &&
            lpBalance <= lpRanges[LPLevels.Level1].maxLimit
        ) currentLpLevel = LPLevels.Level1;

        if (
            lpBalance >= lpRanges[LPLevels.Level2].minLimit &&
            lpBalance <= lpRanges[LPLevels.Level2].maxLimit
        ) currentLpLevel = LPLevels.Level2;

        if (
            lpBalance >= lpRanges[LPLevels.Level3].minLimit &&
            lpBalance <= lpRanges[LPLevels.Level3].maxLimit
        ) currentLpLevel = LPLevels.Level3;

        if (
            lpBalance >= lpRanges[LPLevels.Level4].minLimit &&
            lpBalance <= lpRanges[LPLevels.Level4].maxLimit
        ) currentLpLevel = LPLevels.Level4;

        if (lpBalance >= lpRanges[LPLevels.Level5].minLimit)
            currentLpLevel = LPLevels.Level5;

        if (lastLPAmount > lpBalance && !isRepellentFee) {
            uint256 lpDifference = lastLPAmount - lpBalance;

            uint256 differencePercentage = ((lpDifference * 10000) /
                lastLPAmount);

            if (differencePercentage > lpRanges[currentLpLevel].dropLimit) {
                isRepellentFee = true;
                repellentFeeActivatedAt = block.timestamp;
                lastRepellentFeeActivatedAt = block.timestamp;
                repellentFeeActivatedAmount = lpBalance;
                repellentFeeRecoverAmount =
                    lpBalance +
                    ((lpBalance * lpRanges[currentLpLevel].recoverLimit) /
                        10000);

                emit RepellentFeeActivated(lpBalance);
            }
        }
        if (isRepellentFee && lpBalance > repellentFeeRecoverAmount) {
            isRepellentFee = false;
            repellentFeeActivatedAt = 0;
            repellentFeeActivatedAmount = 0;
            repellentFeeRecoverAmount = 0;

            lastRepellentFeeRecoveredAt = block.timestamp;

            lastLPAmount = lpBalance;

            emit RepellentFeeDisabled(lpBalance);
        }
    }

    function getBnbPrice(uint256 _amount) public view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = BUSD;

        uint256[] memory amounts = router.getAmountsOut(_amount, path);

        return amounts[1];
    }

    function setLpRange(
        LPLevels _level,
        uint256 _min,
        uint256 _max,
        uint256 _drop,
        uint256 _recover
    ) external onlyOwner {
        LPRange storage currentRange = lpRanges[_level];

        currentRange.minLimit = _min;
        currentRange.maxLimit = _max;
        currentRange.dropLimit = _drop;
        currentRange.recoverLimit = _recover;
    }

    function changeNormalFees(
        uint256 _autoBurnFee,
        uint256 _liquidityFee,
        uint256 _treasuryFee
    ) external onlyOwner {
        autoBurnFee = _autoBurnFee;
        liquidityFee = _liquidityFee;
        treasuryFee = _treasuryFee;

        totalFee = _autoBurnFee + _liquidityFee + _treasuryFee;

        require(totalFee <= 20, "Fees can not be grater than 20%");
    }

    function changeRepellentSellFees(
        uint256 _autoBurnFee,
        uint256 _liquidityFee,
        uint256 _treasuryFee
    ) external onlyOwner {
        repellentSellAutoBurnFee = _autoBurnFee;
        repellentSellLiquidityFee = _liquidityFee;
        repellentSellTreasuryFee = _treasuryFee;

        repellentSellTotalFee = _autoBurnFee + _liquidityFee + _treasuryFee;

        require(repellentSellTotalFee <= 30, "Fees can not be grater than 30%");
    }

    function changeRepellentBuyFees(
        uint256 _autoBurnFee,
        uint256 _liquidityFee,
        uint256 _treasuryFee
    ) external onlyOwner {
        repellentBuyAutoBurnFee = _autoBurnFee;
        repellentBuyLiquidityFee = _liquidityFee;
        repellentBuyTreasuryFee = _treasuryFee;

        repellentBuyTotalFee = _autoBurnFee + _liquidityFee + _treasuryFee;

        require(repellentSellTotalFee <= 20, "Fees can not be grater than 20%");
    }

    function setAuthorizedWallet(
        address _wallet,
        bool _status
    ) external onlyOwner {
        isAuthorized[_wallet] = _status;
    }

    function changeLpCheckFrequency(uint256 _hours) external onlyOwner {
        lpCheckFrequency = _hours;
    }

    function excludeFromMaxTx(
        address _wallet,
        bool _status
    ) external onlyOwner {
        isMaxTxExcluded[_wallet] = _status;
    }

    function excludeFromMaxWallet(
        address _wallet,
        bool _status
    ) external onlyOwner {
        isMaxWalletExcluded[_wallet] = _status;
    }

    function changeFirst24HourTax(uint256 _tax) external onlyOwner {
        require(_tax <= 30, "Tax can not exceed 30%");
        firstTax = _tax;
    }

    receive() external payable {}
}
//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ReferalPool is Ownable {
    enum ReferalLevels {
        Basic,
        Advanced,
        Pro
    }
    struct Referals {
        ReferalLevels level;
        uint256 totalRewards;
        uint256 claimedRewards;
        uint256 lastClaimedAt;
        uint256 lastRewardsAt;
        address lastRewardFrom;
        bool isAtMaxLevel;
        uint256 referalCount;
    }

    struct TierStructure {
        uint256 minReferals;
        uint256 rewardPercentage;
    }

    uint256 constant DEVIDE_FACTOR = 10000;

    address public superAdmin;
    IERC20 public Token;

    uint256 public totalRewardsSent;

    mapping(ReferalLevels => TierStructure) public levelDetails;

    mapping(address => Referals) public referalDetails;

    mapping(address => address) public userReferal;

    event NewReferalAdded(address referee, address referal);
    event NewReferalBonusAdded(address from, address to, uint256 amount);

    modifier onlySuper() {
        require(
            msg.sender == superAdmin,
            "Ownable: caller is not the Super admin"
        );
        _;
    }

    constructor(address _superAdmin, address _token) {
        TierStructure storage _level1 = levelDetails[ReferalLevels.Basic];
        TierStructure storage _level2 = levelDetails[ReferalLevels.Advanced];
        TierStructure storage _level3 = levelDetails[ReferalLevels.Pro];

        _level1.minReferals = 1;
        _level1.rewardPercentage = 100;

        _level2.minReferals = 4;
        _level2.rewardPercentage = 200;

        _level3.minReferals = 7;
        _level3.rewardPercentage = 300;

        superAdmin = _superAdmin;
        Token = IERC20(_token);
    }

    function setReferal(address _referal) external {
        require(
            userReferal[msg.sender] == address(0),
            "Referal address already set"
        );

        require(msg.sender != _referal, "Can not set own address");

        userReferal[msg.sender] = _referal;

        Referals storage referal = referalDetails[_referal];

        referal.referalCount++;

        if (!referal.isAtMaxLevel) {
            updateReferalLevel(_referal);
        }

        emit NewReferalAdded(msg.sender, _referal);
    }

    function setReferalBonus(
        address from,
        uint256 buyAmount
    ) external onlyOwner {
        if (userReferal[from] == address(0)) return;
        Referals storage referal = referalDetails[userReferal[from]];
        TierStructure memory tier = levelDetails[referal.level];

        uint256 _bonus = (buyAmount * tier.rewardPercentage) / DEVIDE_FACTOR;

        referal.lastRewardFrom = from;
        referal.lastRewardsAt = block.timestamp;
        referal.totalRewards += _bonus;

        Token.transfer(userReferal[from], _bonus);

        emit NewReferalBonusAdded(from, userReferal[from], _bonus);
    }

    function changeTiers(
        ReferalLevels level,
        uint256 newMinReferals,
        uint256 newRewardPercentage
    ) external onlySuper {
        TierStructure storage tier = levelDetails[level];

        // Check that the provided values are valid
        require(newMinReferals > 0, "Minimum referrals must be greater than 0");
        require(
            newRewardPercentage > 0,
            "Reward percentage must be greater than 0"
        );

        // Update the tier structure with the new values
        tier.minReferals = newMinReferals;
        tier.rewardPercentage = newRewardPercentage;
    }

    function withdrawErc20(address _token, uint256 _amount) external onlySuper {
        IERC20(_token).transfer(msg.sender, _amount);
    }

    function updateReferalLevel(address _user) internal {
        Referals storage referal = referalDetails[_user];

        uint256 referalCount = referal.referalCount;
        ReferalLevels newLevel;

        if (referalCount >= levelDetails[ReferalLevels.Pro].minReferals) {
            newLevel = ReferalLevels.Pro;
        } else if (
            referalCount >= levelDetails[ReferalLevels.Advanced].minReferals
        ) {
            newLevel = ReferalLevels.Advanced;
        } else {
            newLevel = ReferalLevels.Basic;
        }

        // Update the referral's level if it has changed
        if (referal.level != newLevel) {
            referal.level = newLevel;
            if (newLevel == ReferalLevels.Pro) referal.isAtMaxLevel = true;
        }
    }

    function claimRewards() external {
        Referals storage referal = referalDetails[msg.sender];

        require(referal.totalRewards > 0, "you didn't start earning yet");

        uint256 claimabaleRewards = referal.totalRewards -
            referal.claimedRewards;

        require(claimabaleRewards > 0, "you don't have any claiamble rewards");

        referal.claimedRewards += claimabaleRewards;

        referal.lastClaimedAt = block.timestamp;
        Token.transfer(msg.sender, claimabaleRewards);

        totalRewardsSent += claimabaleRewards;
    }
}