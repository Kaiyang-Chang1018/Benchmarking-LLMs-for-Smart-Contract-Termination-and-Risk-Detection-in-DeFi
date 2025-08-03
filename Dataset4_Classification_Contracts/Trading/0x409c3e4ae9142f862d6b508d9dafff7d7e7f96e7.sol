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
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * The default value of {decimals} is 18. To change this, you should override
 * this function so it returns a different value.
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
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
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
pragma solidity >=0.5.0;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

interface ITreasury {
	function mint(address to_, uint256 amount_) external;

	function TOKEN() external view returns (address);

	function excessReserves() external view returns (uint256);
}

interface IDistributor {
	function distribute() external;

	function nextRewardAt(uint256 _rate) external view returns (uint256);

	function nextReward() external view returns (uint256);
}

interface IStaking {
	function stake(address _to, uint256 _amount) external;

	function unstake(address _to, uint256 _amount, bool _rebase) external;

	function rebase() external;

	function index() external view returns (uint256);
}

interface ITOKEN is IERC20Metadata {
	function mint(address to_, uint256 amount_) external;

	function burnFrom(address account_, uint256 amount_) external;

	function burn(uint256 amount_) external;

	function uniswapV2Pair() external view returns (address);
}

interface IsStakingProtocol is IERC20 {
	function rebase(uint256 amount_, uint epoch_) external returns (uint256);

	function circulatingSupply() external view returns (uint256);

	function gonsForBalance(uint amount) external view returns (uint);

	function balanceForGons(uint gons) external view returns (uint);

	function index() external view returns (uint);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
pragma experimental ABIEncoderV2;

/*



(Website) https://xxx.xxx
(Telegram) https://t.me/xxx
(Twitter) https://twitter.com/xxx

*/

import "./Interfaces.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IWETH.sol";

contract Token is ERC20, Ownable {
	/// STATE VARIABLES ///

	/// @notice Address of UniswapV2Router
	IUniswapV2Router02 public immutable uniswapV2Router;
	/// @notice Address of /ETH LP - cannot be immutable as we only want to define it when enabling trading.
	address public uniswapV2Pair;
	/// @notice Burn address
	address public constant deadAddress = address(0xdead);
	/// @notice  treasury
	address public treasury;
	/// @notice Team wallet address
	address public teamWallet;

	bool private swapping;

	/// @notice Bool if trading is active
	bool public tradingActive = false;
	/// @notice Bool if swap is enabled
	bool public swapEnabled = false;
	/// @notice Bool if limits are in effect
	bool public limitsInEffect = true;

	/// @notice Current max wallet amount (If limits in effect)
	uint256 public maxWallet;
	/// @notice Current max transaction amount (If limits in effect)
	uint256 public maxTransactionAmount;
	/// @notice Current percent of supply to swap tokens at (i.e. 5 = 0.05%)
	uint256 public swapPercent;

	/// @notice Current buy side total fees
	uint256 public buyTotalFees;
	/// @notice Current buy side backing fee
	uint256 public buyBackingFee;
	/// @notice Current buy side liquidity fee
	uint256 public buyLiquidityFee;
	/// @notice Current buy side team fee
	uint256 public buyTeamFee;

	/// @notice Current sell side total fees
	uint256 public sellTotalFees;
	/// @notice Current sell side backing fee
	uint256 public sellBackingFee;
	/// @notice Current sell side liquidity fee
	uint256 public sellLiquidityFee;
	/// @notice Current sell side team fee
	uint256 public sellTeamFee;

	/// @notice Current tokens going for backing
	uint256 public tokensForBacking;
	/// @notice Current tokens going for liquidity
	uint256 public tokensForLiquidity;
	/// @notice Current tokens going for tean
	uint256 public tokensForTeam;

	/// MAPPINGS ///

	/// @dev Bool if address is excluded from fees
	mapping(address => bool) private _isExcludedFromFees;

	/// @notice Bool if address is excluded from max transaction amount
	mapping(address => bool) public _isExcludedMaxTransactionAmount;

	/// @notice Bool if address is AMM pair
	mapping(address => bool) public automatedMarketMakerPairs;

	/// EVENTS ///

	event TradingStarted(address indexed pair, uint256 liquidityTokens, uint256 liquidityWeth);

	event ExcludeFromFees(address indexed account, bool isExcluded);

	event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

	event teamWalletUpdated(address indexed newWallet, address indexed oldWallet);

	event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiquidity);

	/// CONSTRUCTOR ///
	/// @param _teamWallet   Address of team wallet
	constructor(address _teamWallet) ERC20("KONG Token", "KONG") {
		address _uniAddr;
		if (block.chainid == 1 || block.chainid == 31337) {
			_uniAddr = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; // Ethereum: Uniswap V2
		} else if (block.chainid == 11155111) {
			_uniAddr = 0xC532a74256D3Db42D0Bf7a0400fEFDbad7694008; // Ethereum: Uniswap V2
		} else {
			revert("Chain cannot work with Uniswap");
		}

		uniswapV2Router = IUniswapV2Router02(_uniAddr);

		uint256 startingSupply_ = 1_000_000 * 10 ** 9;

		maxWallet = 10_000 * 1e9; // 1%
		maxTransactionAmount = 10_000 * 1e9; // 1%
		swapPercent = 10; // 0.10%

		buyBackingFee = 3;
		buyLiquidityFee = 0;
		buyTeamFee = 7;
		buyTotalFees = buyBackingFee + buyLiquidityFee + buyTeamFee;

		sellBackingFee = 10;
		sellLiquidityFee = 0;
		sellTeamFee = 25;
		sellTotalFees = sellBackingFee + sellLiquidityFee + sellTeamFee;

		teamWallet = _teamWallet; // set as team wallet
		treasury = _teamWallet; // until we deploy the treasury

		// exclude from paying fees or having max transaction amount
		excludeFromFees(owner(), true);
		excludeFromFees(teamWallet, true);
		excludeFromFees(address(this), true);
		excludeFromFees(address(0xdead), true);

		excludeFromMaxTransaction(owner(), true);
		excludeFromMaxTransaction(teamWallet, true);
		excludeFromMaxTransaction(address(this), true);
		excludeFromMaxTransaction(address(0xdead), true);

		_mint(address(this), startingSupply_);
		_transfer(address(this), msg.sender, (totalSupply() * 10) / 100);
	}

	receive() external payable {}

	/// AMM PAIR ///

	/// @notice       Sets if address is AMM pair
	/// @param pair   Address of pair
	/// @param value  Bool if AMM pair
	function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
		require(pair != uniswapV2Pair, "The pair cannot be removed from automatedMarketMakerPairs");

		_setAutomatedMarketMakerPair(pair, value);
	}

	/// @dev Internal function to set `vlaue` of `pair`
	function _setAutomatedMarketMakerPair(address pair, bool value) private {
		automatedMarketMakerPairs[pair] = value;

		emit SetAutomatedMarketMakerPair(pair, value);
	}

	/// INTERNAL TRANSFER ///

	/// @dev Internal function to burn `amount` from `account`
	function _burnFrom(address account, uint256 amount) internal {
		uint256 decreasedAllowance_ = allowance(account, msg.sender) - amount;

		_approve(account, msg.sender, decreasedAllowance_);
		_burn(account, amount);
	}

	/// @dev Internal function to transfer - handles fee logic
	function _transfer(address from, address to, uint256 amount) internal override {
		require(from != address(0), "ERC20: transfer from the zero address");
		require(to != address(0), "ERC20: transfer to the zero address");

		if (amount == 0) {
			super._transfer(from, to, 0);
			return;
		}

		if (limitsInEffect) {
			if (from != owner() && to != owner() && to != address(0) && to != address(0xdead) && !swapping) {
				if (!tradingActive) {
					require(_isExcludedFromFees[from] || _isExcludedFromFees[to], "Trading is not active.");
				}

				//when buy
				if (automatedMarketMakerPairs[from] && !_isExcludedMaxTransactionAmount[to]) {
					require(amount <= maxTransactionAmount, "Buy transfer amount exceeds the maxTransactionAmount.");
					require(amount + balanceOf(to) <= maxWallet, "Max wallet exceeded");
				}
				//when sell
				else if (automatedMarketMakerPairs[to] && !_isExcludedMaxTransactionAmount[from]) {
					require(amount <= maxTransactionAmount, "Sell transfer amount exceeds the maxTransactionAmount.");
				} else if (!_isExcludedMaxTransactionAmount[to]) {
					require(amount + balanceOf(to) <= maxWallet, "Max wallet exceeded");
				}
			}
		}

		uint256 contractTokenBalance = balanceOf(address(this));

		bool canSwap = contractTokenBalance >= swapTokensAtAmount();

		if (
			canSwap &&
			swapEnabled &&
			!swapping &&
			!automatedMarketMakerPairs[from] &&
			!_isExcludedFromFees[from] &&
			!_isExcludedFromFees[to]
		) {
			swapping = true;

			swapBack();

			swapping = false;
		}

		bool takeFee = !swapping;

		// if any account belongs to _isExcludedFromFee account then remove the fee
		if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
			takeFee = false;
		}

		uint256 fees = 0;
		// only take fees on buys/sells, do not take on wallet transfers
		if (takeFee) {
			// on sell
			if (automatedMarketMakerPairs[to] && sellTotalFees > 0) {
				fees = (amount * sellTotalFees) / 100;
				tokensForLiquidity += (fees * sellLiquidityFee) / sellTotalFees;
				tokensForTeam += (fees * sellTeamFee) / sellTotalFees;
				tokensForBacking += (fees * sellBackingFee) / sellTotalFees;
			}
			// on buy
			else if (automatedMarketMakerPairs[from] && buyTotalFees > 0) {
				fees = (amount * buyTotalFees) / 100;
				tokensForLiquidity += (fees * buyLiquidityFee) / buyTotalFees;
				tokensForTeam += (fees * buyTeamFee) / buyTotalFees;
				tokensForBacking += (fees * buyBackingFee) / buyTotalFees;
			}

			if (fees > 0) {
				super._transfer(from, address(this), fees);
			}

			amount -= fees;
		}

		super._transfer(from, to, amount);
	}

	// #region INTERNAL FUNCTION

	/// @dev INTERNAL function to swap `tokenAmount` for ETH
	/// @dev Invoked in `swapBack()`
	function swapTokensForEth(uint256 tokenAmount) internal {
		// generate the uniswap pair path of token -> weth
		address[] memory path = new address[](2);
		path[0] = address(this);
		path[1] = uniswapV2Router.WETH();

		_approve(address(this), address(uniswapV2Router), tokenAmount);

		// make the swap
		uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
			tokenAmount,
			0, // accept any amount of ETH
			path,
			address(this),
			block.timestamp
		);
	}

	/// @dev INTERNAL function to add `tokenAmount` and `ethAmount` to LP
	/// @dev Invoked in `swapBack()`
	function addLiquidity(uint256 tokenAmount, uint256 ethAmount) internal {
		// approve token transfer to cover all possible scenarios
		_approve(address(this), address(uniswapV2Router), tokenAmount);

		// add the liquidity
		uniswapV2Router.addLiquidityETH{value: ethAmount}(
			address(this),
			tokenAmount,
			0, // slippage is unavoidable
			0, // slippage is unavoidable
			treasury,
			block.timestamp
		);
	}

	/// @dev INTERNAL function to transfer fees properly
	/// @dev Invoked in `_transfer()`
	function swapBack() internal {
		uint256 contractBalance = balanceOf(address(this));
		uint256 totalTokensToSwap = tokensForLiquidity + tokensForBacking + tokensForTeam;
		bool success;

		if (contractBalance == 0 || totalTokensToSwap == 0) {
			return;
		}

		if (contractBalance > swapTokensAtAmount() * 20) {
			contractBalance = swapTokensAtAmount() * 20;
		}

		// Halve the amount of liquidity tokens
		uint256 liquidityTokens = (contractBalance * tokensForLiquidity) / totalTokensToSwap / 2;
		uint256 amountToSwapForETH = contractBalance - liquidityTokens;

		uint256 initialETHBalance = address(this).balance;

		swapTokensForEth(amountToSwapForETH);

		uint256 ethBalance = address(this).balance - initialETHBalance;

		uint256 ethForBacking = (ethBalance * tokensForBacking) / totalTokensToSwap - (tokensForLiquidity / 2);

		uint256 ethForTeam = (ethBalance * tokensForTeam) / totalTokensToSwap - (tokensForLiquidity / 2);

		uint256 ethForLiquidity = ethBalance - ethForBacking - ethForTeam;

		tokensForLiquidity = 0;
		tokensForBacking = 0;
		tokensForTeam = 0;

		(success, ) = address(teamWallet).call{value: ethForTeam}("");

		if (liquidityTokens > 0 && ethForLiquidity > 0) {
			addLiquidity(liquidityTokens, ethForLiquidity);
			emit SwapAndLiquify(amountToSwapForETH, ethForLiquidity, tokensForLiquidity);
		}

		uint256 _balance = address(this).balance;
		IWETH(uniswapV2Router.WETH()).deposit{value: _balance}();
		IERC20(uniswapV2Router.WETH()).transfer(treasury, _balance);
	}

	/// VIEW FUNCTION ///

	/// @notice Returns decimals
	function decimals() public view virtual override returns (uint8) {
		return 9;
	}

	/// @notice Returns if address is excluded from fees
	function isExcludedFromFees(address account) public view returns (bool) {
		return _isExcludedFromFees[account];
	}

	/// @notice Returns at what percent of supply to swap tokens at
	function swapTokensAtAmount() public view returns (uint256 amount_) {
		amount_ = (totalSupply() * swapPercent) / 10000;
	}

	/// TREASURY FUNCTION ///

	/// @notice         Mint (Only by treasury)
	/// @param account  Address to mint to
	/// @param amount   Amount to mint
	function mint(address account, uint256 amount) external {
		require(msg.sender == treasury, "msg.sender not treasury");
		_mint(account, amount);
	}

	/// USER FUNCTIONS ///

	/// @notice         Burn
	/// @param account  Address to burn from
	/// @param amount   Amount to to burn
	function burnFrom(address account, uint256 amount) external {
		_burnFrom(account, amount);
	}

	/// @notice         Burn
	/// @param amount   Amount to to burn
	function burn(uint256 amount) external {
		_burn(msg.sender, amount);
	}

	/// OWNER FUNCTIONS ///

	/// @notice Set address of treasury
	function setTreasury(address _treasury) external onlyOwner {
		treasury = _treasury;
		excludeFromFees(_treasury, true);
		excludeFromMaxTransaction(_treasury, true);
	}

	/// @notice Enable trading - once enabled, can never be turned off. Send in LP amount here and mint so you don't get rekt.
	function enableTrading() external payable onlyOwner {
		require(!tradingActive, "Trading is active already");
		require(msg.value > 0, "Send liquidity eth");

		uint256 liquidityTokens = balanceOf(address(this)); // 100% of the balance assigned to this contract
		require(liquidityTokens > 0, "No tokens!");

		// create pair and pool
		uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
		excludeFromMaxTransaction(address(uniswapV2Pair), true);
		_setAutomatedMarketMakerPair(address(uniswapV2Pair), true);

		IERC20Metadata weth = IERC20Metadata(uniswapV2Router.WETH());
		weth.approve(address(uniswapV2Router), type(uint256).max);
		_approve(address(this), address(uniswapV2Router), type(uint256).max);

		// add the liquidity
		uniswapV2Router.addLiquidityETH{value: msg.value}(
			address(this),
			liquidityTokens,
			0,
			0,
			owner(),
			block.timestamp
		);

		tradingActive = true;
		swapEnabled = true;
		emit TradingStarted(uniswapV2Pair, liquidityTokens, msg.value);
	}

	/// @notice Update percent of supply to swap tokens at
	function updateSwapTokensAtPercent(uint256 newPercent) external onlyOwner returns (bool) {
		require(newPercent >= 1, "Swap amount cannot be lower than 0.01% total supply.");
		require(newPercent <= 50, "Swap amount cannot be higher than 0.50% total supply.");
		swapPercent = newPercent;
		return true;
	}

	/// @notice Update swap enabled
	/// @dev    Only use to disable contract sales if absolutely necessary (emergency use only)
	function updateSwapEnabled(bool enabled) external onlyOwner {
		swapEnabled = enabled;
	}

	/// @notice Update buy side fees
	function updateBuyFees(uint256 _backingFee, uint256 _liquidityFee, uint256 _teamFee) external onlyOwner {
		buyBackingFee = _backingFee;
		buyLiquidityFee = _liquidityFee;
		buyTeamFee = _teamFee;
		buyTotalFees = buyBackingFee + buyLiquidityFee + buyTeamFee;
	}

	/// @notice Update sell side fees
	function updateSellFees(uint256 _backingFee, uint256 _liquidityFee, uint256 _teamFee) external onlyOwner {
		sellBackingFee = _backingFee;
		sellLiquidityFee = _liquidityFee;
		sellTeamFee = _teamFee;
		sellTotalFees = sellBackingFee + sellLiquidityFee + sellTeamFee;
	}

	/// @notice Set if an address is excluded from fees
	function excludeFromFees(address account, bool excluded) public onlyOwner {
		_isExcludedFromFees[account] = excluded;
		emit ExcludeFromFees(account, excluded);
	}

	/// @notice Set if an address is excluded from max transaction
	function excludeFromMaxTransaction(address updAds, bool isEx) public onlyOwner {
		_isExcludedMaxTransactionAmount[updAds] = isEx;
	}

	/// @notice Update team wallet
	function updateTeamWallet(address newWallet) external onlyOwner {
		teamWallet = newWallet;
		excludeFromFees(newWallet, true);
		excludeFromMaxTransaction(newWallet, true);
		emit teamWalletUpdated(newWallet, teamWallet);
	}

	/// @notice Remove limits in palce
	function removeLimits() external onlyOwner returns (bool) {
		limitsInEffect = false;
		return true;
	}

	/// @notice Withdraw stuck tokens from contract
	function withdrawStuck() external onlyOwner {
		uint256 balance = IERC20(address(this)).balanceOf(address(this));
		IERC20(address(this)).transfer(msg.sender, balance);
		payable(msg.sender).transfer(address(this).balance);
	}

	/// @notice Withdraw stuck token from contract
	function withdrawStuckToken(address _token, address _to) external onlyOwner {
		require(_token != address(0), "_token address cannot be 0");
		uint256 _contractBalance = IERC20(_token).balanceOf(address(this));
		IERC20(_token).transfer(_to, _contractBalance);
	}

	/// @notice Withdraw stuck ETH from contract
	function withdrawStuckEth(address toAddr) external onlyOwner {
		(bool success, ) = toAddr.call{value: address(this).balance}("");
		require(success);
	}
}