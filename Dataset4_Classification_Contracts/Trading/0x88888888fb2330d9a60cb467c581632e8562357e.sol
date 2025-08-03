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
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IUniswapV2Pair {
    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1);

    function swap(
        uint amount0Out,
        uint amount1Out,
        address to,
        bytes calldata data
    ) external;

    function mint(address to) external;
}

interface IUniswapV2Factory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

interface IERC20 {
    function transferFrom(address from, address to, uint amount) external;

    function balanceOf(address account) external view returns (uint);

    function approve(address spender, uint256 amount) external;
}

interface IWETH {
    function deposit() external payable;
}

/**
 * @notice UniswapV2Pair does not allow to receive to token0 or token1.
 * As a workaround, this contract can receive tokens and has max approval
 * for the creator.
 */
contract ERC20HolderWithApproval {
    constructor(address token) {
        IERC20(token).approve(msg.sender, type(uint256).max);
    }
}

/**
 * @notice Gas optimized ERC20 token based on solmate's ERC20 contract.
 * @dev Optimizations assume a UniswapV2 WETH pair as main liquidity.
 */
abstract contract ERC20UniswapV2InternalSwaps {
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private constant FACTORY =
        0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address private immutable wethReceiver;
    address public immutable pair;

    error InvalidAddress();

    constructor() {
        // assumption to save additional gas
        if (address(this) >= WETH) {
            revert InvalidAddress();
        }
        pair = IUniswapV2Factory(FACTORY).createPair(address(this), WETH);
        wethReceiver = address(new ERC20HolderWithApproval(WETH));
    }

    /**
     * @dev Swap tokens to WETH directly on pair, to save gas.
     * No check for minimal return, susceptible to price manipulation!
     */
    function _swapForWETH(uint amountToken, address to) internal {
        uint amountWeth = _getAmountWeth(amountToken);
        _transferFromContractBalance(pair, amountToken);
        // Pair prevents receiving tokens to one of the pairs addresses
        IUniswapV2Pair(pair).swap(0, amountWeth, wethReceiver, new bytes(0));
        IERC20(WETH).transferFrom(wethReceiver, to, amountWeth);
    }

    /**
     * @dev Add tokens and WETH to liquidity, directly on pair, to save gas.
     * No check for minimal return, susceptible to price manipulation!
     * Sufficient WETH in contract balancee assumed!
     */
    function _addLiquidity(
        uint amountToken,
        address to
    ) internal returns (uint amountWeth) {
        amountWeth = _quoteToken(amountToken);
        _transferFromContractBalance(pair, amountToken);
        IERC20(WETH).transferFrom(address(this), pair, amountWeth);
        IUniswapV2Pair(pair).mint(to);
    }

    /**
     * @dev Add tokens and WETH as initial liquidity, directly on pair, to save gas.
     * No checks performed. Caller has to make sure to have access to the token before public!
     * Sufficient WETH in contract balancee assumed!
     */
    function _addInitialLiquidity(
        uint amountToken,
        uint amountWeth,
        address to
    ) internal {
        _transferFromContractBalance(pair, amountToken);
        IERC20(WETH).transferFrom(address(this), pair, amountWeth);
        IUniswapV2Pair(pair).mint(to);
    }

    /**
     * @dev Add tokens and ETH as initial liquidity, directly on pair, to save gas.
     * No checks performed. Caller has to make sure to have access to the token before public!
     * Sufficient ETH in contract balancee assumed!
     */
    function _addInitialLiquidityEth(
        uint amountToken,
        uint amountEth,
        address to
    ) internal {
        IWETH(WETH).deposit{value: amountEth}();
        _addInitialLiquidity(amountToken, amountEth, to);
    }

    /** @dev Transfer all WETH from contract balance to `to`. */
    function _sweepWeth(address to) internal returns (uint amountWeth) {
        amountWeth = IERC20(WETH).balanceOf(address(this));
        IERC20(WETH).transferFrom(address(this), to, amountWeth);
    }

    /** @dev Transfer all ETH from contract balance to `to`. */
    function _sweepEth(address to) internal {
        _safeTransferETH(to, address(this).balance);
    }

    /** @dev Quote `amountToken` in ETH, assuming no fees (used for liquidity). */
    function _quoteToken(
        uint amountToken
    ) internal view returns (uint amountEth) {
        (uint reserveToken, uint reserveEth) = IUniswapV2Pair(pair)
            .getReserves();
        amountEth = (amountToken * reserveEth) / reserveToken;
    }

    /** @dev Quote `amountToken` in WETH, assuming 0.3% uniswap fees (used for swap). */
    function _getAmountWeth(
        uint amounToken
    ) internal view returns (uint amountWeth) {
        (uint reserveToken, uint reserveWeth) = IUniswapV2Pair(pair)
            .getReserves();
        uint amountTokenWithFee = amounToken * 997;
        uint numerator = amountTokenWithFee * reserveWeth;
        uint denominator = (reserveToken * 1000) + amountTokenWithFee;
        amountWeth = numerator / denominator;
    }

    /** @dev Quote `amountWeth` in tokens, assuming 0.3% uniswap fees (used for swap). */
    function _getAmountToken(
        uint amounWeth,
        uint reserveToken,
        uint reserveWeth
    ) internal pure returns (uint amountToken) {
        uint numerator = reserveToken * amounWeth * 1000;
        uint denominator = (reserveWeth - amounWeth) * 997;
        amountToken = (numerator / denominator) + 1;
    }

    /** @dev Get reserves of pair. */
    function _getReserve()
        internal
        view
        returns (uint reserveToken, uint reserveWeth)
    {
        (reserveToken, reserveWeth) = IUniswapV2Pair(pair).getReserves();
    }

    /** @dev Transfer `amount` ETH to `to` gas efficiently. */
    function _safeTransferETH(address to, uint256 amount) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly { // solhint-disable-line no-inline-assembly
            // Transfer the ETH and store if it succeeded or not.
            success := call(gas(), to, amount, 0, 0, 0, 0)
        }

        require(success, "ETH_TRANSFER_FAILED");
    }

    /** @dev Returns true if `_address` is a contract. */
    function _isContract(address _address) internal view returns (bool) {
        uint32 size;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            size := extcodesize(_address)
        }
        return (size > 0);
    }

    /** @dev Transfeer `amount` tokens from contract balance to `to`. */
    function _transferFromContractBalance(
        address to,
        uint256 amount
    ) internal virtual;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20UniswapV2InternalSwaps} from "./ERC20UniswapV2InternalSwaps.sol";

contract Pepeland is ERC20, Ownable, ERC20UniswapV2InternalSwaps {
    /** @notice Minimum threshold in ETH to trigger #swapTokensAndAddLiquidity. */
    uint256 public constant SWAP_THRESHOLD_ETH_MIN = 0.005 ether;
    /** @notice Maximum threshold in ETH to trigger #swapTokensAndAddLiquidity. */
    uint256 public constant SWAP_THRESHOLD_ETH_MAX = 50 ether;

    uint256 private constant _SHARE_LIQUIDITY = 70;
    uint256 private constant _MAX_SUPPLY = 8_888_888_888 ether;
    uint256 private constant _SUPPLY_LIQUIDITY =
        (_MAX_SUPPLY * _SHARE_LIQUIDITY) / 100;
    uint256 private constant _LAUNCH_BUY_TAX = 0;
    uint256 private constant _LAUNCH_SELL_TAX = 69_00;
    uint256 private constant _LAUNCH_TAX_WINDOW = 15 minutes;

    /** @notice Tax recipient wallet. */
    address public taxRecipient;
    /** @notice Whether address is extempt from transfer tax. */
    mapping(address => bool) public taxFreeAccount;
    /** @notice Whether address is an exchange pool. */
    mapping(address => bool) public isExchangePool;
    /** @notice Threshold in ETH of tokens to collect before triggering #swapTokensAndAddLiquidity. */
    uint256 public swapThresholdEth = 0.1 ether;
    /** @notice Tax manager. @dev Can **NOT** change transfer taxes. */
    address public taxManager;
    /** @notice Buy tax in bps (4.20%). In first hour after adding liquidity, buy tax will be #_LAUNCH_BUY_TAX. */
    uint256 public buyTax = 4_20;
    /** @notice Sell tax in bps (6.9%). In first hour after adding liquidity, sell tax will be #_LAUNCH_SELL_TAX. */
    uint256 public sellTax = 6_90;

    uint256 private _launchTaxEndsAt = type(uint256).max;

    event TaxRecipientChanged(address indexed taxRecipient);
    event SwapThresholdChanged(uint256 swapThresholdEth);
    event TaxFreeStateChanged(address indexed account, bool indexed taxFree);
    event ExchangePoolStateChanged(
        address indexed account,
        bool indexed isExchangePool
    );
    event TaxManagerChanged(address indexed taxManager);
    event TaxesChanged(uint256 newBuyTax, uint256 newSellTax);
    event TaxesWithdrawn(uint256 amount);

    error Unauthorized();
    error InvalidParameters();
    error InvalidSwapThreshold();
    error InvalidTax();

    modifier onlyTaxManager() {
        if (msg.sender != taxManager) {
            revert Unauthorized();
        }
        _;
    }

    constructor(
        address _owner,
        address _taxRecipient,
        address _taxManager
    ) ERC20("Pepeland", "Pepeland") {
        _transferOwnership(_owner);

        taxManager = _taxManager;
        emit TaxManagerChanged(_taxManager);
        taxRecipient = _taxRecipient;
        emit TaxRecipientChanged(_taxRecipient);

        taxFreeAccount[_taxRecipient] = true;
        emit TaxFreeStateChanged(_taxRecipient, true);
        taxFreeAccount[address(this)] = true;
        emit TaxFreeStateChanged(address(this), true);
        isExchangePool[pair] = true;
        emit ExchangePoolStateChanged(pair, true);
        emit TaxesChanged(buyTax, sellTax);

        _mint(address(this), _SUPPLY_LIQUIDITY);
        _mint(_taxRecipient, _MAX_SUPPLY - _SUPPLY_LIQUIDITY);
    }

    // *** Owner Interface ***

    /**
     * @notice Launch the token by providing liquidity.
     * @dev Only callable by owner, renounces ownership.
     */
    function launch() external payable onlyOwner {
        _addInitialLiquidityEth(_SUPPLY_LIQUIDITY, msg.value, msg.sender);

        _launchTaxEndsAt = block.timestamp + _LAUNCH_TAX_WINDOW;

        renounceOwnership();
    }

    // *** Tax Manager Interface ***

    /**
     * @notice Set `taxFree` state of `account`.
     * @param account account
     * @param taxFree true if `account` should be extempt from transfer taxes.
     * @dev Only callable by taxManager.
     */
    function setTaxFreeAccount(
        address account,
        bool taxFree
    ) external onlyTaxManager {
        if (taxFreeAccount[account] == taxFree) {
            revert InvalidParameters();
        }
        taxFreeAccount[account] = taxFree;
        emit TaxFreeStateChanged(account, taxFree);
    }

    /**
     * @notice Set `exchangePool` state of `account`
     * @param account account
     * @param exchangePool whether `account` is an exchangePool
     * @dev ExchangePool state is used to decide if transfer is a swap
     * and should trigger #swapTokensAndAddLiquidity.
     */
    function setExchangePool(
        address account,
        bool exchangePool
    ) external onlyTaxManager {
        if (isExchangePool[account] == exchangePool) {
            revert InvalidParameters();
        }
        isExchangePool[account] = exchangePool;
        emit ExchangePoolStateChanged(account, exchangePool);
    }

    /**
     * @notice Transfer taxManager role to `newTaxManager`.
     * @param newTaxManager new taxManager
     * @dev Only callable by taxManager.
     */
    function transferTaxManager(address newTaxManager) external onlyTaxManager {
        if (newTaxManager == taxManager) {
            revert InvalidParameters();
        }
        taxManager = newTaxManager;
        emit TaxManagerChanged(newTaxManager);
    }

    /**
     * @notice Set taxRecipient address to `newTaxRecipient`.
     * @param newTaxRecipient new taxRecipient
     * @dev Only callable by taxManager.
     */
    function setTaxRecipient(address newTaxRecipient) external onlyTaxManager {
        if (newTaxRecipient == taxRecipient) {
            revert InvalidParameters();
        }
        taxRecipient = newTaxRecipient;
        emit TaxRecipientChanged(newTaxRecipient);
    }

    /**
     * @notice Withdraw tax collected (which would usually be automatically swapped to weth) to taxRecipient
     * @dev Only callable by taxManager.
     */
    function withdrawTaxes() external onlyTaxManager {
        uint256 balance = balanceOf(address(this));
        if (balance > 0) {
            super._transfer(address(this), taxRecipient, balance);
            emit TaxesWithdrawn(balance);
        }
    }

    /**
     * @notice Change the amount of tokens collected via tax before a swap is triggered.
     * @param newSwapThresholdEth new threshold received in ETH
     * @dev Only callable by taxManager
     */
    function setSwapThresholdEth(
        uint256 newSwapThresholdEth
    ) external onlyTaxManager {
        if (
            newSwapThresholdEth < SWAP_THRESHOLD_ETH_MIN ||
            newSwapThresholdEth > SWAP_THRESHOLD_ETH_MAX ||
            newSwapThresholdEth == swapThresholdEth
        ) {
            revert InvalidSwapThreshold();
        }
        swapThresholdEth = newSwapThresholdEth;
        emit SwapThresholdChanged(newSwapThresholdEth);
    }

    /**
     * @notice Set tax for buying and selling the token
     * @param newBuyTax new buy tax in bps
     * @param newSellTax new sell tax in bps
     * @dev Only callable by taxManager
     */
    function lowerTaxes(
        uint256 newBuyTax,
        uint256 newSellTax
    ) external onlyTaxManager {
        if (newBuyTax >= buyTax || newSellTax >= sellTax) {
            revert InvalidTax();
        }
        buyTax = newBuyTax;
        sellTax = newSellTax;
        emit TaxesChanged(newBuyTax, newSellTax);
    }

    /**
     * @notice Threshold of how many tokens to collect from tax before calling #swapTokens.
     * @dev Depends on swapThresholdEth which can be configured by taxManager.
     * Restricted to 5% of liquidity.
     */
    function swapThresholdToken() public view returns (uint256) {
        (uint reserveToken, uint reserveWeth) = _getReserve();
        uint256 maxSwapEth = (reserveWeth * 5) / 100;
        return
            _getAmountToken(
                swapThresholdEth > maxSwapEth ? maxSwapEth : swapThresholdEth,
                reserveToken,
                reserveWeth
            );
    }

    /** @notice Get current buy tax depending on current timestamp. */
    function currentBuyTax() public view returns (uint256) {
        return _getTax(true);
    }

    /** @notice Get current buy tax depending on current timestamp. */
    function currentSellTax() public view returns (uint256) {
        return _getTax(false);
    }


    // *** Internal Interface ***

    /** @notice IERC20#_transfer */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        if (
            !taxFreeAccount[from] &&
            !taxFreeAccount[to] &&
            !taxFreeAccount[msg.sender]
        ) {
            uint256 fee = amount * _getTax(isExchangePool[from]) / 100_00;
            super._transfer(from, address(this), fee);
            unchecked {
                amount -= fee;
            }

            if (isExchangePool[to]) /* selling */ {
                _swapTokens(swapThresholdToken());
            }
        }
        super._transfer(from, to, amount);
    }


    /** @dev Get transfer tax depending on current timestamp and `isBuy`. */
    function _getTax(bool isBuy) private view returns (uint256) {
        return
            isBuy
                ? (
                    block.timestamp < _launchTaxEndsAt
                        ? _LAUNCH_BUY_TAX
                        : buyTax
                )
                : (
                    block.timestamp < _launchTaxEndsAt
                        ? _LAUNCH_SELL_TAX
                        : sellTax
                );
    }

    /** @dev Transfer `amount` tokens from contract balance to `to`. */
    function _transferFromContractBalance(
        address to,
        uint256 amount
    ) internal override {
        super._transfer(address(this), to, amount);
    }

    /**
     * @notice Swap `amountToken` collected from tax to WETH to add to send to taxRecipient.
     */
    function _swapTokens(uint256 amountToken) internal {
        if (balanceOf(address(this)) < amountToken) {
            return;
        }

        _swapForWETH(amountToken, taxRecipient);
    }
}