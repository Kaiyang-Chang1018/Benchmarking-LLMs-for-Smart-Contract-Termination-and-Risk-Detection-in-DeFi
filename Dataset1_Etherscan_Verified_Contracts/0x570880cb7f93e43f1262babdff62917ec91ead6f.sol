// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;

import {Context} from "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
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
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
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
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
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
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
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
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
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
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC-20 standard.
 */
interface IERC20Metadata is IERC20 {
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

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

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
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

pragma solidity 0.8.20;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        // Detect overflow when multiplying MIN_INT256 with -1
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        // Prevent overflow when dividing MIN_INT256 by -1
        require(b != - 1 || a != MIN_INT256);

        // Solidity already throws when dividing by 0.
        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? - a : a;
    }

    function toUint256Safe(int256 a) internal pure returns (uint256) {
        require(a >= 0);
        return uint256(a);
    }
}

library SafeMathUint {
    function toInt256Safe(uint256 a) internal pure returns (int256) {
        int256 b = int256(a);
        require(b >= 0);
        return b;
    }
}

interface IWETH is IERC20 {
    function deposit() external payable;
    function withdraw(uint) external;
}

interface DividendPayingTokenOptionalInterface {
    function withdrawableDividendOf(address _owner, address _rewardToken) external view returns (uint256);
    function withdrawnDividendOf(address _owner, address _rewardToken) external view returns (uint256);
    function accumulativeDividendOf(address _owner, address _rewardToken) external view returns (uint256);
}

interface DividendPayingTokenInterface {
    function dividendOf(address _owner, address _rewardToken) external view returns (uint256);
    function distributeDividends() external payable;
    function withdrawDividend(address _rewardToken) external;

    event DividendsDistributed(address indexed from, uint256 weiAmount);
    event DividendWithdrawn(address indexed to, uint256 weiAmount);
}

contract DividendPayingToken is DividendPayingTokenInterface, DividendPayingTokenOptionalInterface, Ownable(msg.sender) {
    using SafeMath for uint256;
    using SafeMathUint for uint256;
    using SafeMathInt for int256;

    IUniswapV2Router02 public immutable uniswapV2Router;

    uint256 public totalBalance;
    uint256 public rewardTokenCounter;
    uint256 internal constant magnitude = 2 ** 128;

    address public nextRewardToken;
    address[] public rewardTokens;

    mapping(address => bool) public customDistributions;

    mapping(address => uint256) public holderBalance;
    mapping(address => uint256) public standardDistributions;
    mapping(address => uint256) public totalDividendsDistributed;
    mapping(address => uint256) internal magnifiedDividendPerShare;
    mapping(address => mapping(address => uint256)) internal userDistributions;
    mapping(address => mapping(address => uint256)) internal withdrawnDividends;
    mapping(address => mapping(address => int256)) internal magnifiedDividendCorrections;

    constructor() {
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

        standardDistributions[address(0x6982508145454Ce325dDbE47a25d4ec3d2311933)] = 15;  // PEPE
        rewardTokens.push(address(0x6982508145454Ce325dDbE47a25d4ec3d2311933));

        standardDistributions[address(0x812Ba41e071C7b7fA4EBcFB62dF5F45f6fA853Ee)] = 15;  // NEIRO
        rewardTokens.push(address(0x812Ba41e071C7b7fA4EBcFB62dF5F45f6fA853Ee));

        standardDistributions[address(0xE0f63A424a4439cBE457D80E4f4b51aD25b2c56C)] = 15;  // SPX
        rewardTokens.push(address(0xE0f63A424a4439cBE457D80E4f4b51aD25b2c56C));

        standardDistributions[address(0xaaeE1A9723aaDB7afA2810263653A34bA2C21C7a)] = 15;  // MOG
        rewardTokens.push(address(0xaaeE1A9723aaDB7afA2810263653A34bA2C21C7a));

        standardDistributions[address(0xB90B2A35C65dBC466b04240097Ca756ad2005295)] = 15;  // BOBO
        rewardTokens.push(address(0xB90B2A35C65dBC466b04240097Ca756ad2005295));

        standardDistributions[address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2)] = 15;  // ETH
        rewardTokens.push(address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2));

        standardDistributions[address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48)] = 10;  // USDC
        rewardTokens.push(address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48));

        nextRewardToken = rewardTokens[0];
    }

    function dividendOf(address _owner, address _rewardToken) external view override returns (uint256) {
        return withdrawableDividendOf(_owner, _rewardToken);
    }

    function withdrawableDividendOf(address _owner, address _rewardToken) public view override returns (uint256) {
        return accumulativeDividendOf(_owner, _rewardToken).sub(withdrawnDividends[_owner][_rewardToken]);
    }

    function withdrawnDividendOf(address _owner, address _rewardToken) external view override returns (uint256) {
        return withdrawnDividends[_owner][_rewardToken];
    }

    function accumulativeDividendOf(address _owner, address _rewardToken) public view override returns (uint256) {
        return magnifiedDividendPerShare[_rewardToken].mul(holderBalance[_owner]).toInt256Safe()
        .add(magnifiedDividendCorrections[_rewardToken][_owner]).toUint256Safe() / magnitude;
    }

    function distributionsOf(address _owner) external view returns (uint256[] memory) {
        uint256[] memory currentDistributions = new uint256[](rewardTokens.length);
        if (customDistributions[_owner])
            for (uint256 i = 0; i < rewardTokens.length; i++)
                currentDistributions[i] = userDistributions[_owner][rewardTokens[i]];
        else
            for (uint256 i = 0; i < rewardTokens.length; i++)
                currentDistributions[i] = standardDistributions[rewardTokens[i]];
        return currentDistributions;
    }

    function _setBalance(address account, uint256 newBalance) internal {
        uint256 currentBalance = holderBalance[account];
        holderBalance[account] = newBalance;

        if (newBalance > currentBalance) {
            uint256 increaseAmount = newBalance.sub(currentBalance);
            _increase(account, increaseAmount);
            totalBalance += increaseAmount;
        }
        else if (newBalance < currentBalance) {
            uint256 reduceAmount = currentBalance.sub(newBalance);
            _reduce(account, reduceAmount);
            totalBalance -= reduceAmount;
        }
    }

    function setDistributionPercentages(uint256[] calldata percentages) external {
        require(percentages.length == rewardTokens.length, "ARRAY MISMATCH: Percentages total must match rewards tokens total!");
        uint256 totalPercentage = 0;
        for (uint256 i = 0; i < percentages.length; i++) {
            require(percentages[i] <= 100, "PERCENTAGE EXCEEDED: Percentage must not exceed 100%!");
            userDistributions[msg.sender][rewardTokens[i]] = percentages[i];
            totalPercentage += percentages[i];
        }
        require(totalPercentage == 100, " TOTAL PERCENTAGE EXCEEDED: Total percentage must equal 100%!");
        customDistributions[msg.sender] = true;
    }

    function distributeDividends() public payable override {
        require(totalBalance > 0);

        uint256 initialBalance = IERC20(nextRewardToken).balanceOf(address(this));
        buyTokens(msg.value, nextRewardToken);
        uint256 newBalance = IERC20(nextRewardToken).balanceOf(address(this)).sub(initialBalance);

        if (newBalance > 0) {
            magnifiedDividendPerShare[nextRewardToken] = magnifiedDividendPerShare[nextRewardToken].add((newBalance).mul(magnitude) / totalBalance);

            emit DividendsDistributed(msg.sender, newBalance);
            totalDividendsDistributed[nextRewardToken] = totalDividendsDistributed[nextRewardToken].add(newBalance);
        }

        rewardTokenCounter = (rewardTokenCounter + 1) % (rewardTokens.length - 1);
        nextRewardToken = rewardTokens[rewardTokenCounter];
    }

    function buyTokens(uint256 ethAmount, address rewardToken) internal {
        if (rewardToken != uniswapV2Router.WETH()) {
            address[] memory path = new address[](2);
            path[0] = uniswapV2Router.WETH();
            path[1] = rewardToken;

            uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: ethAmount}(
                0,
                path,
                address(this),
                block.timestamp
            );
        }
        else
            IWETH(uniswapV2Router.WETH()).deposit{value: ethAmount}();
    }

    function withdrawDividend(address _rewardToken) external virtual override {
        _withdrawDividendOfUser(payable(msg.sender), _rewardToken);
    }

    function _withdrawDividendOfUser(address payable user, address _rewardToken) internal returns (uint256) {
        uint256 _withdrawableDividend = withdrawableDividendOf(user, _rewardToken);
        uint256 _dividendSupplyAvailable = IERC20(_rewardToken).balanceOf(address(this));
        _withdrawableDividend = _withdrawableDividend < _dividendSupplyAvailable ? _withdrawableDividend : _dividendSupplyAvailable;

        if (_withdrawableDividend > 0) {
            withdrawnDividends[user][_rewardToken] = withdrawnDividends[user][_rewardToken].add(_withdrawableDividend);

            uint256 distribution = customDistributions[user] ? userDistributions[user][_rewardToken] : standardDistributions[_rewardToken];
            uint256 withdrawal = _withdrawableDividend.mul(distribution).div(100);
            IERC20(_rewardToken).transfer(user, withdrawal);

            emit DividendWithdrawn(user, withdrawal);
            return _withdrawableDividend;
        }

        return 0;
    }

    function _increase(address account, uint256 value) internal {
        for (uint256 i; i < rewardTokens.length; i++)
            magnifiedDividendCorrections[rewardTokens[i]][account] = magnifiedDividendCorrections[rewardTokens[i]][account]
                .sub((magnifiedDividendPerShare[rewardTokens[i]].mul(value)).toInt256Safe());
    }

    function _reduce(address account, uint256 value) internal {
        for (uint256 i; i < rewardTokens.length; i++)
            magnifiedDividendCorrections[rewardTokens[i]][account] = magnifiedDividendCorrections[rewardTokens[i]][account]
                .add((magnifiedDividendPerShare[rewardTokens[i]].mul(value)).toInt256Safe());
    }

    receive() external payable {
        distributeDividends();
    }
}

contract DividendTracker is DividendPayingToken {
    using SafeMath for uint256;
    using SafeMathInt for int256;

    struct Map {
        address[] keys;
        mapping(address => uint256) values;
        mapping(address => uint256) indexOf;
        mapping(address => bool) inserted;
    }

    Map private tokenHoldersMap;
    uint256 public lastProcessedIndex;

    uint256 public claimWait;
    uint256 public immutable minimumTokenBalanceForDividends;

    mapping(address => bool) public excludedFromDividends;
    mapping(address => uint256) public lastClaimTimes;

    event ExcludeFromDividends(address indexed account);
    event IncludeInDividends(address indexed account);
    event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);
    event Claim(address indexed account, uint256 amount, bool indexed automatic);

    constructor() {
        claimWait = 86400;
        minimumTokenBalanceForDividends = 347102102 * (10 ** 18); //0.0005%
    }

    function get(address key) private view returns (uint) {
        return tokenHoldersMap.values[key];
    }

    function getIndexOfKey(address key) private view returns (int) {
        if (!tokenHoldersMap.inserted[key])
            return - 1;
        return int(tokenHoldersMap.indexOf[key]);
    }

    function getKeyAtIndex(uint index) private view returns (address) {
        return tokenHoldersMap.keys[index];
    }

    function size() private view returns (uint) {
        return tokenHoldersMap.keys.length;
    }

    function set(address key, uint val) private {
        if (tokenHoldersMap.inserted[key])
            tokenHoldersMap.values[key] = val;
        else {
            tokenHoldersMap.inserted[key] = true;
            tokenHoldersMap.values[key] = val;
            tokenHoldersMap.indexOf[key] = tokenHoldersMap.keys.length;
            tokenHoldersMap.keys.push(key);
        }
    }

    function remove(address key) private {
        if (!tokenHoldersMap.inserted[key])
            return;

        delete tokenHoldersMap.inserted[key];
        delete tokenHoldersMap.values[key];

        uint index = tokenHoldersMap.indexOf[key];
        uint lastIndex = tokenHoldersMap.keys.length - 1;
        address lastKey = tokenHoldersMap.keys[lastIndex];

        tokenHoldersMap.indexOf[lastKey] = index;
        delete tokenHoldersMap.indexOf[key];

        tokenHoldersMap.keys[index] = lastKey;
        tokenHoldersMap.keys.pop();
    }

    function excludeFromDividends(address account) external onlyOwner() {
        excludedFromDividends[account] = true;

        _setBalance(account, 0);
        remove(account);
        emit ExcludeFromDividends(account);
    }

    function includeInDividends(address account) external onlyOwner() {
        require(excludedFromDividends[account]);

        excludedFromDividends[account] = false;
        emit IncludeInDividends(account);
    }

    function updateClaimWait(uint256 newClaimWait) external onlyOwner() {
        require(newClaimWait >= 0 && newClaimWait <= 86400, "Dividend_Tracker: claimWait must be updated to between 1 and 24 hours");
        require(newClaimWait != claimWait, "Dividend_Tracker: Cannot update claimWait to same value");

        claimWait = newClaimWait;
        emit ClaimWaitUpdated(newClaimWait, claimWait);
    }

    function getLastProcessedIndex() external view returns (uint256) {
        return lastProcessedIndex;
    }

    function getNumberOfTokenHolders() external view returns (uint256) {
        return tokenHoldersMap.keys.length;
    }

    function getAccount(address _account, address _rewardToken) public view returns (address account, int256 index, int256 iterationsUntilProcessed, uint256 withdrawableDividends, uint256 totalDividends, uint256 lastClaimTime, uint256 nextClaimTime, uint256 secondsUntilAutoClaimAvailable) {
        account = _account;
        index = getIndexOfKey(account);
        iterationsUntilProcessed = - 1;

        if (index >= 0) {
            if (uint256(index) > lastProcessedIndex)
                iterationsUntilProcessed = index.sub(int256(lastProcessedIndex));
            else {
                uint256 processesUntilEndOfArray = tokenHoldersMap.keys.length >
                lastProcessedIndex ? tokenHoldersMap.keys.length.sub(lastProcessedIndex) : 0;

                iterationsUntilProcessed = index.add(int256(processesUntilEndOfArray));
            }
        }

        withdrawableDividends = withdrawableDividendOf(account, _rewardToken);
        totalDividends = accumulativeDividendOf(account, _rewardToken);

        lastClaimTime = lastClaimTimes[account];
        nextClaimTime = lastClaimTime > 0 ? lastClaimTime.add(claimWait) : 0;
        secondsUntilAutoClaimAvailable = nextClaimTime > block.timestamp ? nextClaimTime.sub(block.timestamp) : 0;
    }

    function getAccountAtIndex(uint256 index, address _rewardToken) external view returns (address, int256, int256, uint256, uint256, uint256, uint256, uint256) {
        if (index >= size())
            return (0x0000000000000000000000000000000000000000, - 1, - 1, 0, 0, 0, 0, 0);
        address account = getKeyAtIndex(index);
        return getAccount(account, _rewardToken);
    }

    function canAutoClaim(uint256 lastClaimTime) private view returns (bool) {
        if (lastClaimTime > block.timestamp)
            return false;
        return block.timestamp.sub(lastClaimTime) >= claimWait;
    }

    function setBalance(address payable account, uint256 newBalance) external onlyOwner() {
        if (excludedFromDividends[account])
            return;

        if (newBalance >= minimumTokenBalanceForDividends) {
            _setBalance(account, newBalance);
            set(account, newBalance);
        }
        else {
            _setBalance(account, 0);
            remove(account);
        }

        processAccount(account, true);
    }

    function process(uint256 gas) external returns (uint256, uint256, uint256) {
        uint256 numberOfTokenHolders = tokenHoldersMap.keys.length;

        if (numberOfTokenHolders == 0)
            return (0, 0, lastProcessedIndex);

        uint256 _lastProcessedIndex = lastProcessedIndex;

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;
        uint256 claims = 0;

        while (gasUsed < gas && iterations < numberOfTokenHolders) {
            _lastProcessedIndex++;
            if (_lastProcessedIndex >= tokenHoldersMap.keys.length)
                _lastProcessedIndex = 0;

            address account = tokenHoldersMap.keys[_lastProcessedIndex];
            if (canAutoClaim(lastClaimTimes[account]))
                if (processAccount(payable(account), true))
                    claims++;

            iterations++;

            uint256 newGasLeft = gasleft();
            if (gasLeft > newGasLeft)
                gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));

            gasLeft = newGasLeft;
        }

        lastProcessedIndex = _lastProcessedIndex;
        return (iterations, claims, lastProcessedIndex);
    }

    function processAccount(address payable account, bool automatic) public onlyOwner() returns (bool) {
        uint256 amount;
        bool paid;

        for (uint256 i; i < rewardTokens.length; i++) {
            amount = _withdrawDividendOfUser(account, rewardTokens[i]);

            if (amount > 0) {
                lastClaimTimes[account] = block.timestamp;
                emit Claim(account, amount, automatic);
                paid = true;
            }
        }

        return paid;
    }
}

/*
 * 
 *
 * ██╗███╗░░██╗███████╗██╗███╗░░██╗██╗████████╗███████╗  ███╗░░░███╗░█████╗░███╗░░██╗███████╗██╗░░░██╗
 * ██║████╗░██║██╔════╝██║████╗░██║██║╚══██╔══╝██╔════╝  ████╗░████║██╔══██╗████╗░██║██╔════╝╚██╗░██╔╝
 * ██║██╔██╗██║█████╗░░██║██╔██╗██║██║░░░██║░░░█████╗░░  ██╔████╔██║██║░░██║██╔██╗██║█████╗░░░╚████╔╝░
 * ██║██║╚████║██╔══╝░░██║██║╚████║██║░░░██║░░░██╔══╝░░  ██║╚██╔╝██║██║░░██║██║╚████║██╔══╝░░░░╚██╔╝░░
 * ██║██║░╚███║██║░░░░░██║██║░╚███║██║░░░██║░░░███████╗  ██║░╚═╝░██║╚█████╔╝██║░╚███║███████╗░░░██║░░░
 * ╚═╝╚═╝░░╚══╝╚═╝░░░░░╚═╝╚═╝░░╚══╝╚═╝░░░╚═╝░░░╚══════╝  ╚═╝░░░░░╚═╝░╚════╝░╚═╝░░╚══╝╚══════╝░░░╚═╝░░░
 * ░██████╗░██╗░░░░░██╗████████╗░█████╗░██╗░░██╗
 * ██╔════╝░██║░░░░░██║╚══██╔══╝██╔══██╗██║░░██║
 * ██║░░██╗░██║░░░░░██║░░░██║░░░██║░░╚═╝███████║
 * ██║░░╚██╗██║░░░░░██║░░░██║░░░██║░░██╗██╔══██║
 * ╚██████╔╝███████╗██║░░░██║░░░╚█████╔╝██║░░██║
 * ░╚═════╝░╚══════╝╚═╝░░░╚═╝░░░░╚════╝░╚═╝░░╚═╝
 * Description: The Infinite Meme-conomy Awaits. The Protocol doesn’t just distribute tokens — it distributes culture.
 *
 * Telegram: https://t.me/TheInfiniteMoneyGlitch
 * Twitter: https://x.com/MoneyGlitchERC
 * Website: https://www.theglitch.money
 */
contract IMG is Context, IERC20, Ownable(msg.sender) {
    string public constant name = "Infinite Money Glitch";
    string public constant symbol = "IMG";

    uint public constant decimals = 18;
    uint public constant totalSupply = 69420420420420 * 10 ** decimals;

    uint public maxTokenBalance;
    uint public maxTokenTransfer;

    address public constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address public constant ZERO = 0x0000000000000000000000000000000000000000;

    address public immutable dexPair;
    IUniswapV2Router02 public immutable dexRouter;

    mapping (address => uint) private balances;
    mapping (address => mapping (address => uint)) private allowances;

    mapping(address => bool) public isFeeExempt;
    mapping(address => bool) public isMarketPair;
    mapping(address => bool) public isBalanceLimitExempt;
    mapping(address => bool) public isTransferLimitExempt;

    address private operationsWallet;
    DividendTracker public dividendTracker;

    struct InFees
    {
        uint rewards;
        uint operations;
        uint burn;
    }

    struct OutFees
    {
        uint rewards;
        uint operations;
        uint burn;
    }

    InFees public inFees;
    OutFees public outFees;

    bool public trading;
    bool public feesStatus;
    bool private inSwap;
    bool private swapAndLiquify;
    bool private swapByLimitEnabled;

    uint private immutable feeDivisor = 10000;
    uint private gasForProcessing = 300000;
    uint private swapLowerThreshold;
    uint private swapUpperThreshold;

    event FeeStatusChanged(address indexed account, bool indexed newStatus);
    event BulkFeeStatusChanged(address[] accounts, bool indexed newStatus);
    event MaxBalanceStatusChanged(address indexed account, bool indexed newStatus);
    event MaxTransferStatusChanged(address indexed account, bool indexed newStatus);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed newStatus);
    event FeesForBuysChanged(uint newOperations, uint newRewards, uint newBurn);
    event FeesForSellsChanged(uint newOperations, uint newRewards, uint newBurn);
    event FeesCollectionStatusChanged(bool newStatus);
    event TokenBalanceAndTransferLimitsChanged(uint newBalance, uint newTransfer);
    event SwapAndLiquifyStatusChanged(bool newStatus);
    event SwapAndLiquifyByLimitStatusChanged(bool newStatus);
    event SwapAndLiquifyThresholdsChanged(uint newLower, uint newUpper);
    event GasForProcessingChanged(uint newGas);
    event ProcessedDividendTracker(uint iterations, uint claims, uint lastProcessedIndex, bool indexed automatic, uint gas, address indexed processor);

    modifier lockSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
        dexRouter = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        dexPair = IUniswapV2Factory(dexRouter.factory()).createPair(dexRouter.WETH(), address(this));

        allowances[address(this)][address(dexRouter)] = type(uint).max;

        dividendTracker = new DividendTracker();
        operationsWallet = address(0x07E5c17e8385a378D2B80F656E1e3E809F86A19F);

        _setMarketPair(dexPair, true);

        maxTokenBalance = (totalSupply * 200) / 10000;
        maxTokenTransfer = (totalSupply * 200) / 10000;
        swapLowerThreshold = (totalSupply * 1) / 10000;
        swapUpperThreshold = (totalSupply * 100) / 10000;

        inFees.rewards = 0;
        inFees.operations = 2000;
        inFees.burn = 0;
        outFees.rewards = 0;
        outFees.operations = 2000;
        outFees.burn = 0;
        feesStatus = true;

        isFeeExempt[DEAD] = true;
        isFeeExempt[owner()] = true;
        isFeeExempt[address(this)] = true;

        isBalanceLimitExempt[DEAD] = true;
        isBalanceLimitExempt[owner()] = true;
        isBalanceLimitExempt[address(this)] = true;
        isBalanceLimitExempt[address(dexPair)] = true;
        isBalanceLimitExempt[address(dividendTracker)] = true;

        isTransferLimitExempt[DEAD] = true;
        isTransferLimitExempt[owner()] = true;
        isTransferLimitExempt[address(this)] = true;
        isTransferLimitExempt[address(dividendTracker)] = true;

        dividendTracker.excludeFromDividends(DEAD);
        dividendTracker.excludeFromDividends(owner());
        dividendTracker.excludeFromDividends(address(this));
        dividendTracker.excludeFromDividends(address(dexRouter));
        dividendTracker.excludeFromDividends(address(dividendTracker));

        balances[owner()] = totalSupply;
        emit Transfer(address(0), owner(), totalSupply);
    }

    function balanceOf(address account) public view override returns (uint) {
        return balances[account];
    }

    function allowance(address holder, address spender) external view override returns (uint) {
        return allowances[holder][spender];
    }

    function getCirculatingSupply() public view returns (uint) {
        return totalSupply - balanceOf(DEAD) - balanceOf(ZERO);
    }

    function setDividendsExemption(address account) external onlyOwner() {
        dividendTracker.excludeFromDividends(account);
    }

    function setDividendsInclusion(address account) external onlyOwner() {
        dividendTracker.includeInDividends(account);
    }

    function setMarketPair(address pair, bool value) external onlyOwner() {
        require(pair != dexPair, "ERROR: Cannot mutate core dex pair!");
        _setMarketPair(pair, value);
    }

    function _setMarketPair(address pair, bool value) private {
        isMarketPair[pair] = value;
        isBalanceLimitExempt[pair] = value;
        if (value)
            dividendTracker.excludeFromDividends(pair);
        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function setFeeExempt(address account, bool status) public onlyOwner() {
        isFeeExempt[account] = status;
        emit FeeStatusChanged(account, status);
    }

    function setBalanceLimitExempt(address account, bool status) public onlyOwner() {
        isBalanceLimitExempt[account] = status;
        emit MaxBalanceStatusChanged(account, status);
    }

    function setTransferLimitExempt(address account, bool status) public onlyOwner() {
        isTransferLimitExempt[account] = status;
        emit MaxTransferStatusChanged(account, status);
    }

    function setBulkFeeExemption(address[] calldata accounts, bool status) external onlyOwner() {
        for (uint i = 0; i < accounts.length; i++)
            isFeeExempt[accounts[i]] = status;
        emit BulkFeeStatusChanged(accounts, status);
    }

    function updateBuyFees(uint newOperations, uint newRewards, uint newBurn) external onlyOwner() {
        require(!feesStatus || (newOperations + newRewards + newBurn > 0 && newOperations + newRewards + newBurn <= 4000), "ERROR: Total fees must be >0% and <= 40%!");

        inFees.operations = newOperations;
        inFees.rewards = newRewards;
        inFees.burn = newBurn;
        emit FeesForBuysChanged(newOperations, newRewards, newBurn);
    }

    function updateSellFees(uint newOperations, uint newRewards, uint newBurn) external onlyOwner() {
        require(!feesStatus || (newOperations + newRewards + newBurn > 0 && newOperations + newRewards + newBurn <= 4000), "ERROR: Total fees must be >0% and <= 40%!");

        outFees.operations = newOperations;
        outFees.rewards = newRewards;
        outFees.burn = newBurn;
        emit FeesForSellsChanged(newOperations, newRewards, newBurn);
    }

    function updateFeesStatus(bool status) external onlyOwner() {
        require(status != feesStatus, "ERROR: New status matches existing status!");
        if (status) {
            require(outFees.operations + outFees.rewards + outFees.burn > 0, "ERROR: Total out fees must be >0%");
            require(inFees.operations + inFees.rewards + inFees.burn > 0, "ERROR: Total in fees must be >0%");
        }

        feesStatus = status;
        emit FeesCollectionStatusChanged(status);
    }

    function updateTokenLimits(uint newBalance, uint newTransfer) external onlyOwner() {
        require(newBalance >= totalSupply / 500, "ERROR: New balance threshold must be >=0.2% total supply!");
        require(newTransfer >= totalSupply / 500, "ERROR: New transfer threshold must be >=0.2% total supply!");

        maxTokenBalance = newBalance * (10 ** decimals);
        maxTokenTransfer = newTransfer * (10 ** decimals);
        emit TokenBalanceAndTransferLimitsChanged(maxTokenBalance, maxTokenTransfer);
    }

    function updateSwapStatus(bool status) external onlyOwner() {
        require(status != swapAndLiquify, "ERROR: New status matches existing status!");

        swapAndLiquify = status;
        emit SwapAndLiquifyStatusChanged(swapAndLiquify);
    }

    function updateSwapByLimitStatus(bool status) external onlyOwner() {
        require(status != swapByLimitEnabled, "ERROR: New status matches existing status!");

        swapByLimitEnabled = status;
        emit SwapAndLiquifyByLimitStatusChanged(swapAndLiquify);
    }

    function updateSwapThresholds(uint lowerThreshold, uint upperThreshold, uint divisor) external onlyOwner() {
        require(lowerThreshold > 0, "ERROR: Lower threshold must be greater than zero!");
        require(upperThreshold > 0, "ERROR: Upper threshold must be greater than zero!");

        swapLowerThreshold = (totalSupply * lowerThreshold) / (divisor);
        swapUpperThreshold = (totalSupply * upperThreshold) / (divisor);
        emit SwapAndLiquifyThresholdsChanged(swapLowerThreshold, swapUpperThreshold);
    }

    function updateGasForProcessing(uint newValue) external onlyOwner() {
        require(newValue >= 200000 && newValue <= 500000, "ERROR: Gas must be between 200,000 and 500,000 WEI!");
        require(newValue != gasForProcessing, "ERROR: New gas value matches existing value!");

        gasForProcessing = newValue;
        emit GasForProcessingChanged(gasForProcessing);
    }

    function updateClaimWait(uint claimWait) external onlyOwner() {
        dividendTracker.updateClaimWait(claimWait);
    }

    function claim() external {
        dividendTracker.processAccount(payable(msg.sender), false);
    }

    function openLaunch() external payable onlyOwner() {
        require(!trading, "ERROR: Cannot open trading more than once!");
        isFeeExempt[owner()] = false;

        address[] memory path = new address[](2);
        path[0] = dexRouter.WETH();
        path[1] = address(this);

        dexRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0,
            path,
            owner(),
            block.timestamp
        );

        trading = true;
        swapAndLiquify = true;
        swapByLimitEnabled = true;
        isFeeExempt[owner()] = true;
    }

    function increaseAllowance(address spender, uint addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint subtractedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, allowances[_msgSender()][spender] - subtractedValue);
        return true;
    }

    function approve(address spender, uint amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint amount) private {
        require(owner != address(0), "ERROR: Approve from the zero address!");
        require(spender != address(0), "ERROR: Approve to the zero address!");

        allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transfer(address to, uint amount) public override returns (bool) {
        _transferFrom(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint amount) public override returns (bool) {
        _transferFrom(from, to, amount);
        _approve(from, msg.sender, allowances[from][msg.sender] - amount);
        return true;
    }

    function _transferFrom(address from, address to, uint amount) internal {
        if (inSwap) {
            balances[from] -= amount;
            balances[to] += amount;
            emit Transfer(from, to, amount);
        }
        else {
            if (from != owner() && to != owner()) {
                if (!isFeeExempt[from] && !isFeeExempt[to])
                    require(trading, "ERROR: Trading is closed!");
                if (!isTransferLimitExempt[from] && !isTransferLimitExempt[to])
                    require(amount <= maxTokenTransfer, "ERROR: Transfer amount exceeds maximum limit!");
            }

            uint contractTokenBalance = balanceOf(address(this));
            if (contractTokenBalance >= swapLowerThreshold && !inSwap && !isMarketPair[from] && isMarketPair[to] && swapAndLiquify) {
                if (swapByLimitEnabled)
                    contractTokenBalance = contractTokenBalance > swapUpperThreshold ? swapUpperThreshold : contractTokenBalance;
                swapBack(contractTokenBalance);
            }

            balances[from] -= amount;

            uint finalAmount = (isFeeExempt[from] || isFeeExempt[to]) ? amount : takeFee(from, to, amount);
            if (!isBalanceLimitExempt[to])
                require(balances[to] + finalAmount <= maxTokenBalance, "ERROR: New balance exceeds maximum limit!");

            balances[to] += finalAmount;
            emit Transfer(from, to, finalAmount);

            dividendTracker.setBalance(payable(from), balanceOf(from));
            dividendTracker.setBalance(payable(to), balanceOf(to));

            if (gasForProcessing > 0)
                try dividendTracker.process(gasForProcessing) returns (uint iterations, uint claims, uint lastProcessedIndex) {
                    emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, true, gasForProcessing, tx.origin);
                } catch {}
        }
    }

    function takeFee(address from, address to, uint amount) internal returns (uint) {
        uint feeTotal = 0;

        if (feesStatus) {
            if (isMarketPair[from])
                feeTotal = amount * (inFees.rewards + inFees.operations + inFees.burn) / feeDivisor;
            else if (isMarketPair[to])
                feeTotal = amount * (outFees.rewards + outFees.operations + outFees.burn) / feeDivisor;
            if (feeTotal > 0) {
                balances[address(this)] += feeTotal;
                emit Transfer(from, address(this), feeTotal);
            }
        }

        return amount - feeTotal;
    }

    function swapBack(uint amount) private lockSwap() {
        uint totalFees = inFees.rewards + inFees.operations + inFees.burn + outFees.rewards + outFees.operations + outFees.burn;
        uint totalEthFees = totalFees - inFees.burn - outFees.burn;

        uint burnTokens = amount * (inFees.burn + outFees.burn) / totalFees;
        uint amountToSwapForETH = amount - burnTokens;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = dexRouter.WETH();

        try dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwapForETH,
            0,
            path,
            address(this),
            block.timestamp
        ){
            payable(address(dividendTracker)).call{ value: address(this).balance * (inFees.rewards + outFees.rewards) / totalEthFees }("");
            payable(operationsWallet).call{ value: address(this).balance * (inFees.operations + outFees.operations) / totalEthFees }("");
        } catch {}

        _transferFrom(address(this), DEAD, burnTokens);
    }

    function withdrawStuckEth() external onlyOwner() {
        payable(msg.sender).call{ value: address(this).balance }("");
    }

    receive() external payable {}
}