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
pragma solidity 0.8.19;

interface IQWAFee {
    function convertFees() external;
}
// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.19;

interface IQWAFactory {
    function WETH() external view returns (address);
    function QWN() external view returns (address);
    function sQWN() external view returns (address);
    function QWNStaking() external view returns (address);
    function feeAddress() external view returns (address);
    function feeDiscount(address _user) external view returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
pragma experimental ABIEncoderV2;

import "../interface/IQWAFee.sol";
import "../interface/factory/IQWAFactory.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface IUniswapV3Router {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);
}

interface IWETH {
    function deposit() external payable;

    function withdraw(uint) external;
}

/// @title   QuantumWealthAcceleratorToken
/// @notice  Quantum Wealth Accelerator Token
contract QuantumWealthAcceleratorTokenNonRebase is ERC20, Ownable {
    /// STATE VARIABLES ///

    /// @notice Address of UniswapV2Router
    IUniswapV2Router02 private immutable uniswapV2Router;
    /// @notice Address of QWN/ETH LP
    address public immutable uniswapV2Pair;
    /// @notice Address of UniswapV3Router
    address private immutable uniswapV3Router;
    /// @notice WETH address
    address private immutable WETH;
    /// @notice Address of Treasury
    address public treasury;
    /// @notice Address QWA Factory address
    address private QWAFactory;
    /// @notice Address of staking where rev share fees go
    address public staking;

    bool private swapping;

    /// @notice Current percent of supply to swap tokens at (i.e. 50 = 0.05%)
    uint256 private swapPercent;

    /// @notice Current total fees
    uint256 public totalFees;
    /// @notice Current backing fee
    uint256 public backingFee;
    /// @notice Current liquidity fee
    uint256 public liquidityFee;
    /// @notice Current rev share fee
    uint256 public revFee;
    /// @notice 1% QWA fee
    uint256 public constant QWA_FEE = 100;
    /// @notice Current team fee
    uint256 public teamFee;

    /// @notice Backing token addresses
    address[] public backingTokens;
    /// @notice Backing token V3 pool fee to swap (if 0 - v2)
    uint24[] private backingTokensV3Fee;

    /// @notice Current tokens going for backing
    uint256 public tokensForBacking;
    /// @notice Current tokens going for liquidity
    uint256 public tokensForLiquidity;
    /// @notice Current tokens going for team
    uint256 public tokensForTeam;
    /// @notice Current tokens going towards fee
    uint256 public tokensForFee;
    /// @notice Current tokens going rev share
    uint256 public tokensForRev;

    uint256 private immutable blockDeployed;

    uint256 private backingSwapping;

    /// MAPPINGS ///

    /// @dev Bool if address is excluded from fees
    mapping(address => bool) private _isExcludedFromFees;

    /// @notice Bool if address is AMM pair
    mapping(address => bool) public automatedMarketMakerPairs;

    /// EVENTS ///

    event ExcludeFromFees(address indexed account, bool isExcluded);

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    /// CONSTRUCTOR ///

    constructor(
        address[] memory _backingTokens,
        uint24[] memory _backingTokensV3Fee,
        uint256 _supply,
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol) {
        blockDeployed = block.number;
        QWAFactory = msg.sender;
        WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        backingTokens = _backingTokens;
        backingTokensV3Fee = _backingTokensV3Fee;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

        _approve(address(this), address(_uniswapV2Router), type(uint256).max);

        uniswapV2Router = _uniswapV2Router;

        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), WETH);
        _setAutomatedMarketMakerPair(address(uniswapV2Pair), true);

        uniswapV3Router = 0xE592427A0AEce92De3Edee1F18E0157C05861564;

        swapPercent = 250; // 0.25%

        revFee = 100;
        liquidityFee = 100;
        backingFee = 100;
        teamFee = 100;
        totalFees = 500;

        // exclude from paying fees
        _isExcludedFromFees[msg.sender] = true;
        _isExcludedFromFees[address(this)] = true;

        _mint(msg.sender, _supply);
    }

    /// RECEIVE ///

    receive() external payable {}

    /// AMM PAIR ///

    /// @notice       Sets if address is AMM pair
    /// @param pair   Address of pair
    /// @param value  Bool if AMM pair
    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != uniswapV2Pair);

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

        (bool _limits, uint256 _maxWallet, uint256 _taxMultiplier) = limits();
        if (_limits) {
            if (from != owner() && to != owner() && to != address(0) && to != address(0xdead) && !swapping) {
                //when buy
                if (automatedMarketMakerPairs[from]) {
                    require(amount + balanceOf(to) <= _maxWallet, "Max wallet exceeded");
                }
            }
        }

        uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance >= swapTokensAtAmount();

        if (
            canSwap &&
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

        uint256 fees;
        // only take fees on buys/sells, do not take on wallet transfers
        if (takeFee) {
            // on buy or sell
            if ((automatedMarketMakerPairs[from] || automatedMarketMakerPairs[to]) && totalFees > 0) {
                fees = (amount * totalFees) / 10000;
                if (_limits) fees = fees * _taxMultiplier;
                if (IQWAFactory(QWAFactory).feeDiscount(tx.origin)) fees = (fees * 3) / 4;
                tokensForLiquidity += (fees * liquidityFee) / totalFees;
                tokensForTeam += (fees * teamFee) / totalFees;
                tokensForBacking += (fees * backingFee) / totalFees;
                tokensForFee += (fees * QWA_FEE) / totalFees;
                tokensForRev += (fees * revFee) / totalFees;
            }

            if (fees > 0) {
                super._transfer(from, address(this), fees);
            }

            amount -= fees;
        }

        super._transfer(from, to, amount);
    }

    /// VIEW FUNCTION ///

    /// @notice Returns decimals for QWA (9)
    function decimals() public view virtual override returns (uint8) {
        return 9;
    }

    /// @notice Returns if address is excluded from fees
    function isExcludedFromFees(address account) external view returns (bool) {
        return _isExcludedFromFees[account];
    }

    /// @notice Returns at what percent of supply to swap tokens at
    function swapTokensAtAmount() public view returns (uint256 amount_) {
        amount_ = (totalSupply() * swapPercent) / 100000;
    }

    /// @dev Returns limits if limit in effect
    function limits() public view returns (bool limits_, uint256 maxAmount_, uint256 taxMultiplier_) {
        if (block.number > blockDeployed) return (false, 0, 0);
        limits_ = true;
        maxAmount_ = (totalSupply() * 5) / 1000; //  0.5% max during block 0 - 10
        if (block.number <= blockDeployed + 3)
            taxMultiplier_ = 6; //  30% tax blocks 0 - 3
        else if (block.number <= blockDeployed + 6)
            taxMultiplier_ = 4; //  20% tax blocks 4 - 7
        else taxMultiplier_ = 2; //  10% tax blocks 7 - 10
    }

    /// USER FUNCTIONS ///

    /// @notice         Burn QWA
    /// @param account  Address to burn QWA from
    /// @param amount   Amount to QWA to burn
    function burnFrom(address account, uint256 amount) external {
        _burnFrom(account, amount);
    }

    /// @notice         Burn QWA
    /// @param amount   Amount to QWA to burn
    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    /// PRIVATE FUNCTIONS ///

    /// @dev PRIVATE function to swap `ethTokenAmount` for ETH
    /// @dev Invoked in `swapBack()`
    function swapTokens(
        uint256 ethTokenAmount,
        uint256 totalTokensToSwap
    ) private returns (uint256 ethBalance_, uint256 ethForBacking_) {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WETH;
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            ethTokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );

        ethBalance_ = address(this).balance;

        ethForBacking_ = (ethBalance_ * tokensForBacking) / (totalTokensToSwap - tokensForLiquidity / 2);

        address backingToken = backingTokens[backingSwapping];

        if (backingToken == WETH) {
            IWETH(WETH).deposit{value: ethForBacking_}();
            IERC20(WETH).transfer(treasury, ethForBacking_);
        } else {
            if (backingTokensV3Fee[backingSwapping] == 0) {
                path[0] = WETH;
                path[1] = backingToken;

                uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: ethForBacking_}(
                    0,
                    path,
                    treasury,
                    block.timestamp
                );
            } else {
                IUniswapV3Router.ExactInputSingleParams memory params = IUniswapV3Router.ExactInputSingleParams({
                    tokenIn: WETH,
                    tokenOut: backingToken,
                    fee: backingTokensV3Fee[backingSwapping],
                    recipient: treasury,
                    deadline: block.timestamp,
                    amountIn: ethForBacking_,
                    amountOutMinimum: 0,
                    sqrtPriceLimitX96: 0
                });

                IUniswapV3Router(uniswapV3Router).exactInputSingle{value: ethForBacking_}(params);
            }
        }

        if (backingSwapping == backingTokens.length - 1) backingSwapping = 0;
        else ++backingSwapping;
    }

    /// @dev PRIVATE function to add `tokenAmount` and `ethAmount` to LP
    /// @dev Invoked in `swapBack()`
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        uniswapV2Router.addLiquidityETH{value: ethAmount}(address(this), tokenAmount, 0, 0, treasury, block.timestamp);
    }

    /// SWAP ///

    /// @dev Function to transfer fees properly
    /// @dev Invoked in `_transfer()`
    function swapBack() private {
        uint256 contractBalance = balanceOf(address(this));
        uint256 totalTokensToSwap = tokensForLiquidity + tokensForBacking + tokensForTeam + tokensForRev + tokensForFee;
        bool success;

        if (contractBalance == 0 || totalTokensToSwap == 0) {
            return;
        }

        uint256 liquidityTokens = (contractBalance * tokensForLiquidity) / totalTokensToSwap / 2;

        uint256 amountToSwapForETH = contractBalance - liquidityTokens;

        (uint256 ethBalance, uint256 ethForBacking) = swapTokens(amountToSwapForETH, totalTokensToSwap);

        uint256 ethForTeam = (ethBalance * tokensForTeam) / (totalTokensToSwap - tokensForLiquidity / 2);

        uint256 ethForFee = (ethBalance * tokensForFee) / (totalTokensToSwap - tokensForLiquidity / 2);

        uint256 ethForRev = (ethBalance * tokensForRev) / (totalTokensToSwap - tokensForLiquidity / 2);

        uint256 ethForLiquidity = ethBalance - ethForTeam - ethForFee - ethForRev - ethForBacking;

        tokensForLiquidity = 0;
        tokensForBacking = 0;
        tokensForTeam = 0;
        tokensForFee = 0;
        tokensForRev = 0;

        (success, ) = address(owner()).call{value: ethForTeam}("");
        (success, ) = address(staking).call{value: ethForRev}("");

        if (liquidityTokens > 0 && ethForLiquidity > 0) {
            addLiquidity(liquidityTokens, ethForLiquidity);
        }

        address feeAddress = IQWAFactory(QWAFactory).feeAddress();

        (success, ) = address(feeAddress).call{value: address(this).balance}("");
        IQWAFee(feeAddress).convertFees();
    }

    /// OWNER FUNCTIONS ///

    /// @notice Set address of treasury
    function setTreasuryAndStaking(address _treasury, address _staking) external onlyOwner {
        require(treasury == address(0));
        treasury = _treasury;
        staking = _staking;
        excludeFromFees(_treasury, true);
    }

    /// @notice Update percent of supply to swap tokens at
    function updateSwapTokensAtPercent(uint256 newPercent) external onlyOwner {
        require(newPercent >= 1, "Can not be < 0.001%");
        require(newPercent <= 500, "Can not be > 0.50%");
        swapPercent = newPercent;
    }

    /// @notice Update fees
    function updateFees(
        uint256 _backingFee,
        uint256 _liquidityFee,
        uint256 _teamFee,
        uint256 _revFee
    ) external onlyOwner {
        backingFee = _backingFee;
        liquidityFee = _liquidityFee;
        teamFee = _teamFee;
        revFee = _revFee;
        totalFees = backingFee + liquidityFee + teamFee + QWA_FEE + revFee;
        require(teamFee <= 200, "Team fee can not be > 2%");
        require(totalFees <= 500, "Total fee can not be > 5%");
    }

    /// @notice Set if an address is excluded from fees
    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }
}