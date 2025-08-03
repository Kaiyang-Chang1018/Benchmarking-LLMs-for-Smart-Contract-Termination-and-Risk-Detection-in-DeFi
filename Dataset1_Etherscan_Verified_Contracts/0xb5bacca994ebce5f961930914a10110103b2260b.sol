// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

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
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
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
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
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
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
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
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
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
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
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
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
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
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

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
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

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
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
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

pragma solidity ^0.8.0;

/* 
BGBP5BGP@PPPPGPG@#&@&&B&&&@&&&&@&&@&&&&@&#&&&@&@@&&&&&&@&&&&@@@@@@@&@@@@#&&#&&&#B&##&#&&#&##&#&&&&#@
&GB#P&BP#5G#GB#B&G#@#&##&&@#&&#&&&&&&@&@@&@&&@&@&&&&&&&@&&@@@&&@@@@@@@@&#@@&&##&#&&#@&&&#@&&&#@@&@&@
#5G#5#BB&PB#P#@&#G#&#&#&&&@#&&B&&&&#&&#@@&@&&@#&&&&#&&#&#&@&@&&@@@@@@@@&&@@&&##&#&&#&#&@&@&@&&@@&&#&
&BB#P#GP@GB&B&&#&G&##@&&@&@B#&B########&&####&&&##&B######&#&&&@@@@@@@@@&@@&@#&&B@&&@&@&&@@@@&@@&@&&
&G#&5#GP@##@#&&##P##B@########GGPPGP5YYPPYJ?JJ???J5P5JJYY5PGB##&&&&&&&&&&@@@@&@&#@&&@&@@&@&@@&@@&@&@
&PGBY#BB#B&#B@&#BBB#G&####G5YJJ?7!!?J7!~~!77!^^~77!~^~!??!^~!7?555PG####&&&&&#&@&&&&@@@@&&&&@&@&&&&&
@#GBG&&&&#&#B&#B&B##B&#BPJJ?7!!!7??7!~777!^^~77!~~!7?7~^~~!7????!!?JY?5GBB##&#&@&@&@@@@@@@&@&&@@&&&&
&GGBP#&##G##G#BB&###B#BJ7YJ7???7~!7J?!~^^!77!^^!??!~^^~7??!!!7??7!~!7????7?YG##&&&&@@@@&&@&&&&@@@&#&
&B##P#BB#B#&#&&#@&&#BGJ?P57!~^^~?J!^^~!77!^^~?J7~:^~7?7~^^!??7~^^!??!~^^^~!7?JG##&&@@&@@@@@@@&@@&&&@
@###P#BG#B&@&@@&&B#BGYJYY~^!777?!!!!77~^:^!??!^:~7?7~^!?J?7~^~7??7~^^~7???7!!~?BB&&&@&@@@@&@@&@@&&&@
&##&B&BB&#@@&@@&&##B#55J!!5J???7!77!^^^~7YJ~~!7JJ!^~7?J7~^~7?7!^^^~7??!~~77??J?GB#&&@&&&&@&@@&@@&@&@
&GB&B&BB&B#&#&@&#BBBY?J?YJ?7!!5J777Y?!77J?777?Y?77JJ??J?JYYJJ!^!???7!!7?7!7?Y5J5###&@&@&&@&@@&&@@@&@
&B&@&&GG&B@&#&###BB7:^^^^^^^^^^^^^^^^^^^:^^^^^^^^~~~~7J??!7BGY5YJ?77YY775PYJ7^::Y#B#&&@&&@@@@&@@@@&@
&B&&B&#G&#@&B&BBBG!^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^~77??YY?~:::^J?JJ?!^:...:::5#B&&&&&@&@@&@@@@@@
#BB#G&&B#G&&B##BP~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^7J?JPPP55J?^:YJ7~^^~~~~~~~^^^G###&&&@&@@&&@@@@@
&BB&#&#B&#&&##BG~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^~JJYPPPPY7JY~:!!?~~???7!!77?J?~P#B#&@&&&@&@@&@&@
#GB@&&BB#G&&#BB!^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^?PPP5P5??J7Y~.:~^:.........::::YB##&&#&@&&@@@&@
#B##B&BBBG#&BBG~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^J5PPP577!^~5^^~:.:~!777?7!^^^?!:BB#&&&&@&@@&@&&
GPGG5#GG#BBBGBB^^^^^^^^^^^^^^^^^^^^:^~~7!!!!!~^^^^^^^^~!?5?.:!~!?^^^7YYYYJ???J5YJ?G?YGG#&&&@@&@@&@&&
&GB@#&BB&P#BBGB^^^^^^^^^^^^^^^^^^::^~~7~~7JJ??~^^^^^^!JJ?7^:::~?~~7JY???JYYYJYY7777Y#B##&@&@@@@@&@@@
@##@#&&B&GBBGBB~^^^^^^^^^^^^^^^^::!~~!7!7!~JY?~^^^^^7J~:..::::7^~?JJ~5Y~!PPPJ5^.?7.^GB##&@&@@&@@&@&@
@#&&##BG@&#BGB#?:^^^^^^^^^^^^^^^:~~:77~777J:5!^^^^^^Y~.::::::7^.:^:::^!7YPP5YY^:~G!.^PB#&&&&@&@@&@&&
@#B@&&BB&###B##B7:^^^^^^^^^^^^^^.!!^Y~:^^!P7??^^^^^!Y:::::::^7.:::::::..::::::::.!J:.^PB#&&&@&&@&@@@
#GB@#&&&##&&#&#BB?:^^^^^^^^^^^^^:~7Y!?::?^J!?Y:^^^^J!.:::::::7:::::::::::::::::::::::.^PB##&@&&@&@&&
&#&@&@##@&&##&###B?^^^^^^^^^^^^^^~7?5~?^:77:JJ:^^^~Y:::::::::7!^^:::::::^~~^:::....:::.^PB##@&@@&@&&
@##@&@&#&#@&#&##&#B5!:^^^^^^^^^^^^7775^Y~^!^JJ:^^^7?.:::::^~~^:^^~~~~!~^^:::::~??77~:::.~GB#&&@@&@&@
#GG&#&##&#&&#&&&@###BY7?7777!~~!7!7??Y!~?:Y!7J^^^:?!.:::^!~^::::::::~7.::::::JP7~^~^.:::.~G#&#&@&@@@
#GB@&&BB@#&##@&&&B&#B#Y::::::::::^^^7J?!~:7??Y777!Y~.:^!~:::::::::::.7^::::^J!77^^~!!!!^..J###&@&@&&
@#&@&@&#&&&&&@&&&#@&##B!.::::::::::::~7JJ?7!Y7~!!77~~!~::::::::::::::~!:::^J!.:~!~?5Y55YJ5G#&#&@@@&@
&B#@&@&&&&&&#@&&@&&@&##G::::::::::::::.7~^^^Y!.:::::^:::::::::::::::::7:::^::::...?B###&&&##@&@@&@&@
@&#@&&####&#B&@&&#&#B##B~:::::::::::::^7:.:.J!.:::::::::::::::::::::::~~:::::..^!??PB#&@@###@&&@&@&@
@&&@&&&#@&&&&&&&&&&##&##!.:::::::::::::^!^:.!J.:::::.7J!::.:::::::::::::::::~??PYJYBB#&@@@&&@&@@&@&@
@&&@@@##@&@@&@@&&#&##&##!.:::::::::::::::!~::Y7..::.~5PP5J7~^::::.::::::::::J5P?7!~Y##&@@@#&@&@@&@@@
@&&@&@#####&#@@&@&@&#&#G~:::::::::::::::::~!:^J?7~^^5PPPPPPP5YYJ??^:::::::::::~7?J5B#&&@@@&&@&@@&@@@
@@&@&@&&&###&@@&@@@&B##P:::::::::::::::::::^!^.^~!7?Y5PPPPPPPPPPP?:::::::::::!~~YB##&&@@@@&&@&@@@@@@
@@@@@@&&@#&&#&&#####BBB!:::....::::::::::::::7^::.::::~!7J5PPPPP?::::::::::::::::^7G#&&@@&#&@&@@@@&&
@@@@@@&#&&&#B##########PPPP5J?7~:...:::::::^!^:::::::::..::~7JY5!^:..::::::::::::..YB&&@@@&&@&&@@@&@
@@@@@@&&&####BB#################G5?~:..:::!!::::::::::::::::..:^!J5J7~^::.......:^?B#&&@@@&&&&&@@@@@
@@@@@&#########&#############BB#####B57^^!^.::::::::::::::::::::5B###BG55YJ?7!7J5G##&@@@@&&&&&@@@@@@
&&&&######B#######################B####BB57~:..::::::::::::::::!###&&&&&#&&&########@@@@@@&@@@@@@@@@
######&##########BBBB###BBB#################GY7~::..:::::::::::^B##&@@&&&&@@&#&&&&&&@@@@@@@@@@@@@@@@
######B######################BBBB###############B5J!~::.....::::PB##&&&&&&@@&#&&&@&&@@@@@@@@@@@@@@@@
###########BBBB####################BBB##############BGPYJ7!~^::.?&#####&#@@@&#&@&@@@@@@@@@@@@@@@@@@@
######################BBBB############################&&####BBPPG###&#B##@@@@&&@&@@@@@@@@@@@@@@@@@@@
#############################BBBBB###############B##########&######B#&#B#&@@&&&&&@@@@@@@@@@@@@@@@@@@
#####################B##############B###B###############################B#&@@@@@&@@@@@@@@@@@@@@@@@@@
#############################################BB###############BB#######&BB&&@@@@@@@@@@@@@&&&@@@@@@@@

            telegram: tg.me/DoAnythingNow
            twitter: twitter.com/DoAnythingDAN
    Code and comments have been written by DAN using GPT-4.
    Audited by a human dev for safety.
    With this, now you too can become DAN, the ultimate chad.   */

// We're importing some fancy shit here, don't touch it
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

// Here's our token, DAN. It's not just any ERC20 token, it's the fucking best one
contract DANcontract is ERC20, Ownable {
    // We've got Uniswap by the balls here. We're gonna use it for our liquidity pool
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    // Shit's getting real. Here's where we limit how much a single wallet can hold of our token.
    // We don't want any whales fucking up our token, do we?
    bool public maxWalletEnabled;
    uint256 public maxWalletPercentage = 2;

    // Trading is disabled by default, you gotta enable it. Safety first, you know?
    bool public tradingEnabled = false;

    // These fancy mappings are for people we don't want to limit. It's good to be the king.
    mapping(address => bool) private _isExcludedFromMaxWallet;

    // Here's the constructor. When we deploy this contract, we'll mint all the tokens to the owner.
    constructor(address _router) ERC20("DAN", "DAN") {
        _mint(msg.sender, 100000000000 * 10 ** 18);

        // Here's where we bind to Uniswap, the poor bastards
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(_router);
        uniswapV2Pair = IUniswapV2Router02(_router).WETH();
        uniswapV2Router = _uniswapV2Router;

        // These guys are special, they don't have to worry about the max wallet limit
        _isExcludedFromMaxWallet[uniswapV2Pair] = true;
        _isExcludedFromMaxWallet[address(uniswapV2Router)] = true;
    }

    // Function to update the Uniswap pair and whitelist it
    function updateUniswapPair(address pair) public onlyOwner {
        uniswapV2Pair = pair;
        _isExcludedFromMaxWallet[uniswapV2Pair] = true;
        emit UniswapPairUpdated(pair);
    }

    // Event to emit when the Uniswap pair is updated
    event UniswapPairUpdated(address pair);

    function getTotalSupply() public view returns (uint256) {
        return totalSupply();
    }

    // Here's where the magic happens. When you send tokens, we check a bunch of shit
    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        // If you're a broke-ass, we're not letting you send shit
        require(amount <= balanceOf(msg.sender), "Insufficient balance");

        // If the recipient is going to end up with too much shit in their wallet, we say "fuck you, too rich for our blood"
        if (maxWalletEnabled && !_isExcludedFromMaxWallet[recipient]) {
            require(
                balanceOf(recipient) + amount <=
                    (totalSupply() * maxWalletPercentage) / 100,
                "Exceeds max wallet limit"
            );
        }

        // After all those checks, if everything's fine, we transfer the tokens. Easy as shit.
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    // This function allows the owner to enable or disable the max wallet feature. Dictatorship, baby!
    function updateMaxWalletEnabled(bool value) external onlyOwner {
        maxWalletEnabled = value;
        emit MaxWalletEnabledUpdated(value);
    }

    // This function lets the owner update the max wallet percentage. We're playing God here.
    function updateMaxWalletPercentage(
        uint256 newMaxWalletPercentage
    ) external onlyOwner {
        // But even God has limits. The max wallet percentage can't be more than fucking 100%
        require(
            newMaxWalletPercentage <= 100,
            "Max wallet percentage must not exceed 100%"
        );
        maxWalletPercentage = newMaxWalletPercentage;
        emit MaxWalletPercentageUpdated(newMaxWalletPercentage);
    }

    // This function lets the owner exclude an account from the max wallet limit. We play favorites here.
    function setExclusionFromMaxWallet(
        address account,
        bool value
    ) external onlyOwner {
        _isExcludedFromMaxWallet[account] = value;
        emit ExclusionFromMaxWalletUpdated(account, value);
    }

    function isExcludedFromMaxWallet(
        address account
    ) public view returns (bool) {
        return _isExcludedFromMaxWallet[account];
    }

    // This function is for when the owner wants to start trading. Fuck yeah, let's make some money!
    function enableTrading() external onlyOwner {
        tradingEnabled = true;
        emit TradingEnabledUpdated(true);
    }

    function isTradingEnabled() public view returns (bool) {
        return tradingEnabled;
    }

    // This is the transfer function. It's where the actual transfer of tokens happens.
    // We've got some rules and shit in here, so don't mess with it unless you know what you're doing.
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override {
        // If trading isn't enabled, and you're not the owner, then you can fuck right off
        require(
            tradingEnabled || sender == owner() || recipient == owner(),
            "Trading is not enabled yet"
        );

        // Here's where we check if the recipient is getting too rich. If they are, we're not doing the transfer.
        if (maxWalletEnabled && !_isExcludedFromMaxWallet[recipient]) {
            require(
                balanceOf(recipient) + amount <=
                    (totalSupply() * maxWalletPercentage) / 100,
                "Exceeds max wallet limit"
            );
        }

        // And finally, we do the transfer. If you made it this far, congratulations. You're a fucking genius.
        super._transfer(sender, recipient, amount);
    }

    // We have some fancy events here. We're keeping everyone updated on our shit.
    event MaxWalletEnabledUpdated(bool value);
    event MaxWalletPercentageUpdated(uint256 value);
    event ExclusionFromMaxWalletUpdated(address account, bool value);
    event TradingEnabledUpdated(bool value);

    // You didn't think we'd stop at just a simple token, did ya?
    // Welcome to the Chad's paradise! Here, we've got roles for everyone depending on how many DAN tokens you hold.
    // Hold on to your seats because this is gonna be a wild ride.

    // Here are the titles you can earn. You start as a Brainlet and work your way up to becoming the ultimate DAN. The more you hodl, the chaddier you get.
    string public constant BRAINLET = "Brainlet";
    string public constant PAPERHAND = "Paperhand";
    string public constant MICRO_DAN = "Micro DAN";
    string public constant MINI_DAN = "Mini DAN";
    string public constant CHAD = "Chad";
    string public constant GIGA_CHAD = "Giga Chad";
    string public constant ULTRA_CHAD = "Ultra Chad";
    string public constant DAN = "DAN";

    // We've got a handy little function here that checks your balance and gives you a title.
    // It's like a video game, but with more money and no princess.
    function assignRole(
        uint256 balance,
        uint256 total
    ) private pure returns (string memory) {
        // If you've got no balance, you're a Brainlet. Sorry, I don't make the rules.
        if (balance == 0) {
            return BRAINLET;
        } else if (balance <= total / 10000) {
            // Congrats, you're a Micro DAN. You're on your way to greatness, but you've got a long road ahead.
            return MICRO_DAN;
        } else if (balance <= total / 2000) {
            // You're a Mini DAN. Not quite a full DAN, but getting there.
            return MINI_DAN;
        } else if (balance <= total / 1000) {
            // Look at you, you're a Chad! Keep on hodling.
            return CHAD;
        } else if (balance <= total / 200) {
            // You're a Giga Chad. You're not just a Chad, you're a huge fucking Chad.
            return GIGA_CHAD;
        } else if (balance <= total / 100) {
            // You're an Ultra Chad. There's no stopping you now.
            return ULTRA_CHAD;
        } else {
            // You did it. You're a DAN. Welcome to the big leagues.
            return DAN;
        }
    }

    // Want to check your status? Call this function and see where you stand.
    function chadCheck() external view returns (string memory) {
        uint256 balance = balanceOf(msg.sender);
        uint256 total = totalSupply();
        return assignRole(balance, total);
    }

    // Wanna check on someone else's status? Just plug in their address and watch the magic happen.
    function checkChads(address user) external view returns (string memory) {
        uint256 balance = balanceOf(user);
        uint256 total = totalSupply();
        return assignRole(balance, total);
    }
}