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
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./IWETH9.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";

/*  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    @@@@@@@@@@@@@@@@@@@@@@@@@@&&#BBBGGGBBB#&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    @@@@@@@@@@@@@@@@@@@@@&BPY?7!~~^^^^^^^^~!7JPB&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    @@@@@@@@@@@@@@@@@&B5?!^^^^^^^^^^^^^^^^^^^^^^!JG&@@@@@@@@@@@@@&&&@@@@@@@@@@@@@@@@@@@@@@&&&@@@@@@@@@@@
    @@@@@@@@@@@@@@@#57^^:^^~~^^^^^^^^^^^^^^^^^^^^^^!YB@@@@@@#PJ7!~~!!?YG&@@@@@@@@@@@@&GY?!~~~!?YG&@@@@@@
    @@@@@@@@@@@@&G?~^^^~!7????7~^^^^^^^^^^^^^^^^^^^^^~JB@@G7^:.:::::::^^~Y#@@@@@@@@#Y~:::::::^~~~75&@@@@
    @@@@@@@@@@&P7^^^^^~????????!^^^^^^^^^^^^^^^^^^^^^^^~BJ:::::::::!????7~~G@@@@@@B~.:::::::!?JYY?!7#@@@
    @@@@@@@@@G7^^^^^^^^!7????7!^^^^^^^^^^^^^^^^^^^^^^^^YJ.::::::::~??5BGY?^^B@@@@#~.:::::::^??5##Y?:7&@@
    @@@@@@@#J^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^~P^:::::::::~??5##5?~.Y@@@@P::::::::::!?J55J7:^B@@
    @@@@@@B7^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^~P:::::::::::!??JJ?!::Y@@@@G:::::::::::^!!!~::~#@@
    @@@@@B!^^^^^^^^^^^^^^^^^^^^^^^^^^^^!777~^^^^^^^^^^^P?.::::::::::^^~~^:.~B@@@@&J:::::::::::::::::P@@@
    @@@@&?^^^^^~~~^^^^^^^^^^^^^^^^^^^^7?????7^^^^^^^^^^!G?:::::::::::::::.~G@@@@@@&5~:::::::::::::!G@@@@
    @@@&P^^^^!????~^^^^^^^^^^^^^^^^^^^!??????!^^^^^^^^^^~557^:::::::::::~Y#@@@@@@@@@#57~^:::::^~?P&@@@@@
    @@@#!^^^~????7^^^^^^^^^^^^^^^^^^^^^~7????!^^^^^^^^^^^^!Y5YJ7!~!!7?Y5#@@@@@@@@@@@@@@#G5YYYPB&@@@@@@@@
    @@&P^^^^^777~^^^^^^^^^^^^^^^^^^^^^^^^~~~~^^^^^^^^^^^^^^^^!?JP#GYY?77B@@@@@@@@@@@@@@@#7~!!G@@@@@@@@@@
    @@&J^^^^^^^^^^^^^^^~!!!!!~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^:~BB?^^~~G@@@@@@@@@@@@@@@&?^^7#@@@@@@@@@@
    @@#7^^^^^^^^^^^^^7YPPPPPPP5J7~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^5&#?^~^Y&@@@@@@@@@@@@@@&J^^J&@@@@@@@@@@
    @@#!^^~!!!^^^^^~YPPPPPPPPPPPP5?~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^J&&B7~~7#@@@@@@@@@@@@@@&J^~P&@@@@@@@@@@
    @@#~^~????7^^^~YPPPPPPPPPPPPPPP57^^^^^^^^^^^^~~~^^^^^^^^^^^^^?#@@G~~~G@@@@@@@@@@@@@@&J^!B@@@@@@@@@@@
    @@#!^~?????~^^JGPPP5J??J5PPPPPPPPJ^^^^^^^^^^7???7^^^^^^^^^^^^?#&@&Y^^Y&@@@@@@@@@@@@@&?^7#@@@@@@@@@@@
    @@&J^^~7?7~^^~PPPP?^^^^^^!YPPPPPPGJ^^^^^^^^^7????7^^^^^^^^^^^?#@@@#7^7#@@@@@@@@@@@@@#7^J&@@@@@@@@@@@
    @@&P^^^^^^^^^7PPPY^^^^^^^^^?PPPPPPP?^^^^^^^^^7????^^^^^^^^^^^Y&@@@@G~~P&@@@@@@@@@@@@#!^5&@@@@@@@@@@@
    @@@#!^^^^^^^^7PPPJ^^^^^^^^^^?PPPPPPP!^^^^^^^^^~!!~^^^^^^^^^^^P&@@@@&J^?#@@@@@@@@@@@@B~~G&@@@@@@@@@@@
    @@@&5^^^^^^^^!PPPY^^^^^^^^^^^YPPPPPPY^^^^^^^^^^^^^^^^^^^^^^^~G&@@@@@G~~G&@@@@@@@@@@@G~!B@@@@@@@@@@@@
    @@@@#7^^^^^^^^YPPP!^^^7~^^^^^!PPPPPPP7^^^^^^^^^^^^^^^^^^^^^^!#&@@@@@#?^J&@@@@@@@@@@@P^?#@@@@@@@@@@@@
    @@@@&G~^^^^^^^7PPP5!^^55~^^^^^?PPPPPP5^^^^^^^^^^^^^^^^^^^^^^J#@@@@@@&5^!B@@@@@@@@@@@5^J&@@@@@@@@@@@@
    @@@@@&P^^^^^^^^?PPPPY5PPY^^^^^~5PPPPPP7^^^^^^^^^^^^^^^^^^^^^5&@@@@@@&G~^5&@@@@@@@@@&J^5&@@@@@@@@@@@@
    @@@@@@&5^^^^^^^^?PPPPPPPG?^^^^^?PPPPPP5^^^^^^^^^^^^^^^^^^^^~B&@@@@@@@#7^7#@@@@@@@@@&?^P&@@@@@@@@@@@@
    @@@@@@@&Y^^^^^^^^!YPPPPGP!^^^^^~5PPPPPP!^^^^^^^^^^^^^^^^^^^7#@@@@@@@@&Y^~P&@@@@@@@@#!~G@@@@@@@@@@@@@
    @@@@@@@@#Y^^^^^^^^^!JYJ?~^^^^^^^JPPPPPP?^^^^^^^^^^^^^^^^^^^5&@@@@@@@@&G~^J#@@@@@@@@G~!B@@@@@@@@@@@@@
    @@@@@@@@@#Y^^^^^^^^^^^^^^^^^^^^^!PPPPPPY^^^^^^^^^^^^^^^^^^~B&@@@@@@@@&B!~~G&@@@@@@@5^7#@@@@@@@@@@@@@
    @@@@@@@@@@&5^^^^^^^^^^^^^^^^^^^^~5PPPPPY^^^^^^^^^^^^^^^^^^7#@@@@@@@@@&B!~~?#@@@@@@&J^?#@@@@@@@@@@@@@
    @@@@@@@@@@@&P~^^^^^^^^^^^^^^^^^^^5PPPPPY^^^^^^^^^^^^^^^^^^Y@@@@@@@@@@&#7~~~Y&@@@@@#7^?&@@@@@@@@@@@@@
    @@@@@@@@@@@@&B7^^^^^^^^^^^^^^^^^!PPPPPPJ^^^^^^^^^^^^^^^^^^7J5B&@@@@@@@#!~~~~P@@@@@B!^?&@@@@@@@@@@@@@
    @@@@@@@@@@@@@@#Y^^^^^^^^^^^^^^^^YPPPPPP!^^^^^^^^^^^^^^^^^^^::^!5&@@@@@B!~~~~!G@@@&Y^^7#@@@@@@@@@@@@@
    @@@@@@@@@@@@@@@&G!^^^^^^^^^^^^^?PPPPPPY^^^^^^^^^^^^^^^^~!??JJJJYB&&&&&P~~~~~~!G@@B7!!!B@@@@@@@@@@@@@
    @@@@@@@@@@@@@@@&G~^^^^^^~~~^^^?PPPPPPP!^^^^^^^^^^^^^~7Y5Y?7!!77???77!77~~~~~~~!JJJJYY5G#&@@@@@@@@@@@
    @@@@@@@@@@@@@@@@BJJJJYYYYYYYY5GGGGGGGJ~~~^^^^^^~!7?YYJ7~^~~~~~~~^^~~~~~~~~~~~~~^^^^~~~~!5#&@@@@@@@@@
    @@@@@@@@@&&#BGPY??7!!~~~~~~~~~!!77????JJJJJ???????7~~^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~^!YG&@@@@@@@
    @@@@@@@@&#Y^::::::^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~^^^^:::::::::^^^^~~~~~^^::::.^!7?5&@@@
    @@@@@@@@@&#BGGBBGJ^:::::^^^:::::^::::::::::::::::^^::::::::::::::::::::....:::::.::^~!!!~^::!JG&@@@@
    @@@@@@@@@@@@@@@@@&#GGGGBBBGPY7~^::::^~!7?Y55YJ7!!!7?JYY55Y?!^^::::^~!7?JJ??7!!!7J5GB#&@@&BGB&@@@@@@@
    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@&&BGGGB##&@@@@@@@&&&&@@@@@@@@@&#BGGGB#&&@@@@@@&&&&@@@@@@@@@@@@@@@@@@@@@
    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  */

contract Gary is ERC20 {
    address immutable Gensler;
    IUniswapV2Pair immutable Exemption;

    bool internal _renounced;
    uint256 internal _launch;

    bool constant IS_SECURITY = false;

    uint256 constant GARYS = 650_000_000_000_000 * 1e18;
    uint256 constant A_NIBBLE = 65_000_000_000 * 1e18;

    mapping(address => bool) private _securities;
    mapping(address => bool) private _participants;

    error NotAuthorized();
    error NoGarysForYou();
    error ReportingError();
    error FilingExemption();
    error ComeInAndRegisterWithUs();

    event Renounced();

    IWETH9 immutable WETH = IWETH9(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IUniswapV2Factory immutable Factory =
        IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);

    modifier isAuthorized() {
        if (msg.sender != Gensler && !_renounced) revert NotAuthorized();

        _;
    }

    constructor() ERC20("Gary", "GARY") {
        Gensler = msg.sender;
        _renounced = false;
        _launch = block.number + 75;
        _mint(address(this), GARYS);
        _transfer(address(this), msg.sender, GARYS / 25);

        Exemption = IUniswapV2Pair(
            Factory.createPair(
                address(this),
                0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
            )
        );
    }

    function renounce() external isAuthorized {
        _renounced = true;

        emit Renounced();
    }

    function COMPLY(uint256 _nibbles) external payable {
        if (
            block.number >= _launch ||
            _nibbles >= 10 ||
            msg.value < 0.1 ether * _nibbles ||
            balanceOf(address(this)) < A_NIBBLE * 2 * _nibbles ||
            _securities[msg.sender] ||
            _participants[msg.sender]
        ) revert NoGarysForYou();

        _participants[msg.sender] = true;

        uint256 _balance = address(this).balance;
        WETH.deposit{value: _balance}();

        WETH.transfer(address(Exemption), _balance);
        _transfer(address(this), address(Exemption), A_NIBBLE * _nibbles);

        // Explicity forbid the movement of these tokens
        Exemption.mint(address(this));

        _transfer(address(this), msg.sender, A_NIBBLE * _nibbles);
    }

    function security() external pure returns (bool) {
        // %%%&&&&&&&&&&&&&%/.........................................,,,,,,,,,,,**/#&@@@@&&&&&&%%%%%%%%##%%%%%%%%%%%%#####%%%%%%%%(.           *#&&&&%%%&&&&&&&&%##((((######(((####%%%%%%%&&&@@@&&&&&&@@@@@@&%%%&
        // %%%&&&&&&&&&&&%(,,.,.......................................,,,,,,,,,,,**/**/#%%%%%%%%%%%%%%%####%%%%%%%%%%%#####%%%%%%%%%/.        ,/%&&&&&&%%&&&&@@&&&%##((((#####((######%%%%%%&&&@@@&&&&&&@@@@@@&%&&&
        // %%%%&&&&&&&&&#*,,,..,,....................................,,,,,,,,,,,,*/////*,/###%%%%%%%%%#####%%%%%%%%%%%######%%%%%%%%%/,     .*/#&&&&&&&%%&&&&@@@&&%#(((((######(#######%%%%%&&&@@@&&&&&%%&%%(#%####
        // %%%&&&&&&&&%#****,,..,,,......       ..............  .........,,,,,,,,***/////*,/#%%%%%%%%%######%%###############%%%%%%%%#(/*,,,/(%&&&&&&&&%%%&&@@@&&%##((((###############%%%%%&&&@@@&&&(%//%#(((/%(((
        // %%%%&&&&&&#/**,,,,,,,.......................................,,,,,,,,,,***//(((***/#%%%%%%%########################%%%%%%%%%%#(//(#%&&&&&&&&&%%%&&@@&&&%##(((((##############%%%%%%&&@@@&&&&&&&&&&&&&&@@&
        // %%%&&&&&&(*,***,,,,,.......,,,,.......,.............,.,,,,,,,,,,.,,,,,**///((((//**#%%%%%%########%%##############%%%%%%%%%%%%#%%%&@&&&&&&&&&%&&&&@@&&%##(((((##############%%%%%%&&@@&&&&&&&&&&&&&&&&&&
        // &&&&@@@@#/******,,,,.................,,,.,,......,,,,,,,,,,,,,,,..,,,,*///(((((//(((%%%%%%########################%%%%%%%%%%%%%%&&&@&&&&&&&&&&&&&@@@@&&%#(((((###############%%%%%&&&@@&&&&&&&&&&&&&&&&&
        // &&&&&@@&****/****,....,,,***//(##((//*/*,,,,,,**/(##%%&%%#(/*/*/****,,,*/(((##(((/(((%%#%##########################%%%%%%%%%%%%%%&&&&&&&&&&&&&&&&&@@@@&%#((((################%%%%%&&&@@&&&%&&&&&&&&&&&&&
        // @@@@&&&%****//**,,,*//(/((#%%&%%%%%%##(/////***/(####%%%%%%##(/*,,///////((####(((//(%################################%%%%%%%%%%%%&&&&&&&&&&&&&&&&&&&&&%##((#################%%%%%&&&@@&&&&&&&@@@&&&&&&&
        // @@@@&&&(****//****//*,*****/((#((//((#((*,..,,,/((((((((((//****//*///((((((##(###(/(########((########################%%%%%%%%%%%&&&&&&&&&&&&&&&&&&&&&%##((#################%%%%%&&&@@&&&%&&@@@@@@@&&&&
        // @@@@@@&**//*****/(/*/(//(#%##(//(#(#%#((*,....,///((((/((%%@@@@@&#(((/((((((((###%#(#########((########################%%%%%%%%%%&&&&&&&&&&&&&&&&@@@@@&%##((#################%%%%%&&&&@&&&&&&@@@@@@@&&&&
        // @@@@@@&//#(//***//(#(%%%@@@@@&((##(//(//,.. .,*//*/*//((///#%&&&&#%%#(((/(######%%%#(%%%####(((((######################%%%%%%%%%&&&&&&&&&&@@@@@@@@@@@@@&%###################%%%%%%&&&@@&&&&&&@@@@@@@&&&&
        // @@@@@@&*/#(//***//(#//////**********//**.   ..*//****/////****,******(#(/(#((###%%%%##%%%%###((((#####################%%%%%%%%%%&&&@@&&&@@@@@@@@@@@@@@&%%#######%%##########%%%%%%&&&@@&&&&&&&@@@@&&&&&&
        // @@@@@@@(###(/****//**********////******,..  .,*///**,,**//*****////////**/((((##%%%&%%%%%%####(((####(###############%%%%%%%%%%%%&&&@&&&&&&@&&&&&&&&&&%%#((###################%%%%%&&&@&&&&&&&&&&&&&&&&&
        // @@@@@@@%%##(/*****///(((//*****,,,,,,**,......,,*/***,,,,,********,,,,,,**/((((#%%%&%%#######((((((((################%%%%%%%%%%%%%&&&&&&&&&&&&&&&&&%%%##((((######((##########%%%%%%&&&&&%%%%%%%%%%%%%%%
        // @@@@@@@%###(/***,,,,,**,,,.......,,**,,.......,,**/**,,,,,,,,,,,,.,,,,****/(((((#%%%%&%#####(((((((((((((#########################%%%&&&&&&&&&%%%%%%%%##((########(####%%#####%%%%%%&&&%%%####%%%%%%%%%%
        // @@@@@@&###((***,,,,,,,,,,........,***,.........,,*//*,,,,,,,.....,,,,****//((#(#####%%#######(((//////((((((#############%%%%%%%#####%%%%%%&&&%%%%%%%#################%%%%%%%%%%%%%%%%%######%%%%%%%%%%%
        // @@@@@%//(#(/**/***,,,,,,,,....,,,,,,,,,,......,*///*//*,,,...,....,,,****/(###########(#####((((///****/(((#######%%%%%%%%%%%%%%%%%%%####%%%%%%%%%%%##################%%%%%%%%%%&&&&%%########%%%%%%%%%%
        // @@@@&(#(/(((/////***,*,,,,,,,,,****/((//******/(%&&#(//***,,,,.,,,,*****//((#########(/(####((//*,,,,,*/(#%%%%%%%%%%%%%&&%%%%&&%%%%%%%%%##%%%%%%%%%###################%%%%%%%%%%&&&&%%########%%%%%%%%%%
        // @@@@%((((///(/(///**/*****,,,,*****(#%&&#(#####%%&&%#///*,,/**,,,***/////(((######/*((//(((#(/*,....,*/#%%&&&%%&&&&&&&&&&&&&&&&&&&&&&%%%%%%%%%%%%%################%###%%%%%%%%%%%&&&%%%%%%%%%%%%%%%%%%%%
        // @@@@%////*,,///////////****,***,,,,,/((##(#%%%#(#(((/*,,,,,,,*/****///////(##(###(**/#(//(((/,.      ,(&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&%%%%%%%%%######################%%%%%%%%%%%&&&%%%%%%%%%%%%%%%%%%&%
        // @@@@#*//*,.,*/////**////*****,,,,,,**//////***//*////*****,,,,**/*////////((((##(/*//((/*//*.        ,(&&@&&&&&&&@&&&&&&&&&&&&&&&&&&&&&%%%%%%%%%%######################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%&&&&
        // @@@@%*/***,,***//**/******,*****,*,******************************/*///////((((##(((/*///*//.        ./%&&&&&&&&&@@&&&&&&&&&&&&&&&&&&&&&&%%%%%%%%#######################%%%%%%%%%%%%%%%%%%%%%%&&&%%%&&&&%
        // @@@@&/,,,****/*//********,*********,,*********************////*/*//*/////(((((##(/////((//,        /%&&&@@@@&&&&@&@@@@&&&&&&&&&&&&&&&&&&&%%%%%%%#######################%%%%%%%%%%&&&&&&&%&&&&&&%%%%&&&&&
        // @@@@@%*,.,*//////*******,**///////(((#########%%%%%######(//******/*//*///((((#%#/*///(//(.       ,(&&&&@@@@&&&&&&@@@@&&&&&&&&@@&&&&&&&&&%%%%%%%#####################%%%&&&&&&&&&&@@@&&&&&&&&&&&&&&&&&&@
        // @@@@@@(,*/**,*//********,**/((#%%%%%&%((/*,******//#%&&&%%#(/*,***(///*///(((##@@#/////(((.       (%&&&@@@@@&&&&&&@@@@@&&@@&@@@@@@&&&&&&%%%%%%%%############%%%%###%%%%&&&&&&@@@@@@@@@&&&&&&&&&&&&&&&&@@
        // @@@@@@@/,*,**/////**///**,**/#(/*,,,,,,,,,,,,,,********///((**,,*/((/**//((((#%@@@%#(//(##*       /%&&&@@@@@&&&&&@@@@@@@@@@@@@@@@@&&&&&%%%%%%%%%######%%%%%%%%%%%%%%%&&&@@@@@@@@@@@@@@@&&&&&%&&&&&&&&&@@
        // &&@@@@@@%///(#(/////////**,*//****,****,,****,*********/*///**,*/##(////((#(##%@@&%#(//(#%/.      (&&&@@@@@@@&&&&@@@@@@@@@@@@@@&&&&&&&&%%%%%%%%#######%%%%%%%%%%%%&&&@@@@@@@@@@@@@@@@@@@@&%%%&&&&%%%%%&@
        // %%%&@@@@@@%###((((////(((/*,**///////***************////(/(/***(##(///(((####%@&&&%#(///(#(*.   ,#&@@@@&@@@@@@@&&@@@@@@@@@@@&&&&%%%%&&&%%%%%%%%######%%%%%%%%%%%%%&@@@@@@@@@@@@@@@@@@@@@@&%%&&&&&%%#%%&@
        // %%%%%%&%%&%%%##(((((((((((/////((((/////////////////((((((///((##(//((((#((##&&##%##(//((##(/*/(%&@@&&&&&&@&@&@@&&&&%%%##&&&&&&%%%%%&&&%%%%%%%#(##(##%%%%###%%%&&&@@@@@&&@@@@@@@@@@@@@@@@@%%%&&&&%%%%%&@
        // %%%%&&&&&&@@@@&##(((((((((((/(((((((((((////((////((((((/(/*/(#(////((((###%%%#(###* *(. ##(((%&&&@@&%&@@@@&%&@@&%%/ (#..%#%&&&%#%%&%&%%%%%&%#( /(/(###(#####%&%%&@@@@@ ,@&@@@@&&@@@@@&@@&#%%&&&&&%%%%%&
        // %%%&&&&&@@@@@@@@%##((((((/////////(//////********//////****//((/////(####%%%%#///(((/  ,#( ,#( // &@..@@@% /&( %, &( %&..@% // %&,.% *&&&&# *%/ ** *, /#. ###%#%&..@@@@ ,@% #* &@..& /@# (&( #&&&&&%%%%&
        // &&&&&@@@@@@@@@@@@@####(((/////*************///***////******//(///(((##%%%%%%/,,,,,,**. (## ./, (/ #%..@@@& ,&%/@, @# #&..&% /( /&##& /@@@&% .(, ,, ., ,///###/ (&. @@@@ ,@& #( #@(%& (@% *%, %%#&&&%%%%&
        // &&&&&&&&&&&&@@@@@@%&&%%##((((//******//////*///////******//((((##%%%&&&&%%%,,,,.....,*/((###((#%@@@@@@@@@@@@@@&@@@@@@@@&&&&&&@@@@@@@@@@@@@@@&%#(*,...,/((((##%&@@@@@@@@@@@@@@@@@@@@@@@@@@@&%%&,,&&&&%%%%
        // &&&&&&&&&&&&&&&&&&&@@@&&&%%##(///****///////(////*******/((###%%%&&&&&&%%%&*,//*,,,*//(##%%%%%%&@@@@@@@@@@@@@@@@@@@@@@&&&%%&&&&@@@@@@@@@@@@@@&&%(*...,/((((#%&@@@@@@@@@@@@@@@@@@@@@@@@@@@@&%%&&&&&&&%%#%
        // &&&&&&&&&&&&@@@@@@@@@@@@@@&&&%##(((/////(((((/////////((###%%%%%%&&&&&&%%*****%##((##%%%%&&&&&&@@@@@@@@@@@@@@@@@@@@@@@# (# /&&&@@@@@@@@@@@@@ *@@%(*,**(((#%&&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&%%&&&&&&&&/ (
        // @@@@@@@@@@@@@@@@@@@@@@@@@@@@& *&&%####((((((((((((####%%%%%%%%&&%&&&%%(****//.(%&&&#    %%   (@@# #@..@.   /@..@@ *@@@# (% // && *@.   #@@@& *@*   .#,    /@,    #&&&%    #(    ,@(   .@# %%, &*    */
        // @@@@@@@@@@@@@@@@@@@@@@@@@@@&/ ,(%&@@@@&&%%%%%%%%%%%%%%%%%%&&&&&&&&%*****/////*,&&&@ ,@@..% /@@@@@( , @/ @@# %..@@ *@@@# #& (@,.,,@/ ,,,,@@@@ *# %@% /* %@.,# (#/ (%%%. ...,( #@, & /@@ *# %%, # *%( ** *
        // @@@@@@@@@@&%#(((#%%%%%%%%%%&  ,*(#%&&@@@@@@&&&&&&&&&&&&&&&&&&&%///*///////////,&&&&%/..(@&,#@@@@@@* &@@%,.*&@&,./,/@@@%,#&,#@@,,@@@%,.,&@@@@,/&%,.,%&/,&@,*&(.., (%%%%/..,#(.#&*,@@*..#@@/.,*,%#,.* */./
        // @&#((((#########((###%%%%%&# .,,*(#%%%%%&@&&@&&&&&&&&&&&&&#////////////////////@&&&&&%%@@@@@@@@@@,*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&&&&&&@@@@@@&#,.*#%%%%%%%%%%%%%%&@@@@@@@@@@@&&&&%*,*#&&&%
        // #####%%%%%#%######%%%%&&&%&*,,,,,/(##%%%%##%&&&&&&&&&&#(/////***//////////////#@@@@&&&&%%#&@@@@@@@@@@@&&&&&&&&&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&%@&%((%%%%%%%%%%%%%%%&@@@@@@@@@@@&&%%%%%%%&&&&
        // %%%%%%%########%%%%%%&%%%&@(******(((######%&&%####(((///////////////////////(@@@@&/ /%%#((######((%&@@@%#&@@&%#%@@@@&%@@&%@@&%&@@&&@@%&@%&%@@%%&@@@&%&@@, @( /&@&%%&&&&%%%%%###%%%%%%%%%%#######%%%%%%%
        // %%%%%%@%%%%%%%%%%%%%%%%%%@@%,****////(#@@@@@@@@@@@@@#////////////////////////%@@@@&( #% *%% ,###* ,/((, */../ /%/ &@@@..% /( %@( %* @@ *% (@@ .#&&% *%( %, @% (@@&&&&%%%%%####((((((((###((((#####%%%%##
        // %%%%%%&@&&&%%%%&%%%%%%%%@@@%..,,***/@@@@@@@@@@@@&@@&@@@#////////////////////(@@@@@@( /% .(* /%%%, #( /( ,/,*( ./*,(((((  ,%% ,%. @* #( *% #@% /%..@..##,@, @% (@@@@&&%%%%%%%%################%%%%%%%%%##
        // &&&&&&%&&&&&&&&&&&%%%%&@@@@(.,,.,/@@@@@&@@@@@@@@@@&@@@@@&&//////////////////&@@@@@@@@@&&&&&%%%%%%%%%%%%&&&&%%%%%%%%%%#/..###((((((((%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&&&&&%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
        // &&&&&&&&&&&&&&&&&&&&&&&@@@&/....%&@@@@@@@@@@@@@@@@@@@&#%%&&&#//////////////#@@@@@@@@@@@@@&&&&&&&&&&&&@@&&&&&&&%%%%%%%%%%%%#####&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&&%%%######((((((((((((((///
        // @@@@@@@@@&&&&&&&&&&&&&@@@&&*..(@&&&&&&&@&@@@@@@@@@@&%%%%%&&&@@%///////////(&@@@@@@@, @@@@@&&&@@&&&@@@@@&&&&&&&&&&&&&&&&&&&%%%&@@@@@&%&@@@@@@%#&@@@%%@@@@#%@@&%@@#@@(&#@(@% /@/&@%(@///////**************
        // @@@@@@@@@@&&&&&&&&&&&@@@&%%,*&&&%%&&&&&&&&@@@@&@@@&%%%#%%%%%%%&&%/////////(@@@@@@@@, .. #@. , ,@* ,..&/ ,. %( .,  .. #%. , ,&@@@@@@(*.*@@@@( ./@# ,, ##.@@@@(*@@ @@ @@@ @@ &@& @ @@@((((((((((//////////
        // @@@@@@@@@@@@@@@@@@&@@@@@%%%%&&###%%&&&&@&&@@@@@@@&%####%%%%%%%%%%&&(//////%@@@@@@@@, @@..( ,///% /@@@& *@@ ,( #@* && */ ,***%&@@@@#.,(*@@@@%..,@@%..(@@(..&@@*,%*@@/@@@(@@%/@@% @@@@##########((((((((##

        return IS_SECURITY;
    }

    function crackdown(address violator) external isAuthorized {
        _securities[violator] = true;
    }

    function allow(address violator) external isAuthorized {
        _securities[violator] = false;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256
    ) internal virtual override {
        if (_launch > block.number) {
            if (!(from == address(this) || from == address(0))) {
                revert FilingExemption();
            }
        } else {
            if (_securities[from] || _securities[to])
                revert ComeInAndRegisterWithUs();
        }
    }

    function finalize() external isAuthorized {
        if (_launch > block.number) revert ReportingError();

        _burn(address(this), balanceOf(address(this)));
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IWETH9 is IERC20 {
    function deposit() external payable;

    function withdraw(uint256) external;
}