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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

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
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
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
        }
        _balances[to] += amount;

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
        _balances[account] += amount;
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
        }
        _totalSupply -= amount;

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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
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
     *
     * _Available since v3.4._
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
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
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
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
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
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
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
}
//www.vitablock.ai
//twitter: @VitaBlock

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

error ERC20_OnlyVB();
error ERC20_OnlyOwner();
error ERC20_PleaseOnboard();
error ERC20_PreEquinox();
error ERC20_PostEquinox();
error ERC20_UniswapV2PairAddress();
error ERC20_InvalidTransfer();
error ERC20_TradingNotOpen();
error ERC20_ExceedsBuyLimit();
error ERC20_ExceedsWalletLimit();
error ERC20_ExceedsSellLimit();
error ERC20_RecipientWillExceedLimit();
error ERC20_Invalid();
error ERC20_InsufficientTokens();
error ERC20_SwapInProgress();

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

library HashGetter {
    function _getHash(bytes32 _lastHash, address _address) internal view returns (bytes32) {
        string memory _str = string.concat(
            Strings.toString(uint256(_lastHash)),
            Strings.toString(block.timestamp),
            Strings.toHexString(_address)
        );
        return keccak256(abi.encodePacked(_str));
    }
}

library AddressArrays {
    function _selectWinner(
        address[] memory _addresses,
        bytes32 _hash
    ) internal pure returns (address) {
        uint256 _length = _addresses.length;
        if (_length == 0) return address(0xdead);
        return _addresses[_getPseudorandomNumber(_hash, _length)];
    }

    function _getPseudorandomNumber(
        bytes32 _hash,
        uint256 _length
    ) internal pure returns (uint256) {
        return uint256(_hash) % _length;
    }
}

contract VBlock is ERC20, Ownable {
    using HashGetter for bytes32;
    using AddressArrays for address[];

    address private constant VB = address(0xAb5801a7D398351b8bE11C439e05C5B3259aeC9B); //Vitalik Buterin's public address (Vb)
    uint256 private constant AUTUMN_EQUINOX_2023_TIMESTAMP = 1695427200; //	Sat Sep 23 2023 00:00:00 UTC
    uint256 private constant MIN_HODL_BLOCKS = 400000; //must hold for four hundred thousand ethereum block confirmations (~55.5 days @ ~12 seconds per block) to be a HODLER

    IUniswapV2Router02 private immutable uniswapV2Router;
    address private immutable uniswapV2Pair;

    uint256 private immutable txMax;
    uint256 private immutable sellMax;
    uint256 private immutable walletMax;

    bool private isEthRaffleDone;
    bool private isVbShareFilled;
    bool private isTradingOpen;
    bool private isVbOnboard;
    bool private isSwapping;

    uint256 private buyTotalFees;
    uint256 private buyTrustFee;
    uint256 private buyRaffleFee;

    uint256 private sellTotalFees;
    uint256 private sellTrustFee;
    uint256 private sellRaffleFee;

    uint256 private trustTokens;
    uint256 private raffleTokens;
    uint256 private trustTokensTreasury;
    uint256 private swapTrustTokensAt;
    uint256 private swapRaffleTokensAt;

    bytes32 private lastHash;
    uint256 private minEligibility;

    address[] private contestants;
    address[] private hodlers;

    mapping(address => bool) private isExcludedFromFees;
    mapping(address => bool) private isExcludedFromMaxTx;
    mapping(address => bool) private isAMM;
    mapping(address => bool) private isConfirmedHodler;
    mapping(address => bool) private isHodling;
    mapping(address => bool) private isHodlEthRaffleWinner;
    mapping(address => uint256) private contestantsIndexes;
    mapping(address => uint256) private buyBlocks;
    mapping(address => uint256) private addressToRaffleCount;

    uint256 private currentRaffleCount;

    event Attaboy(address indexed _vb);
    event TransferedVbShare(address indexed _address);
    event SetAsAMM(address indexed _pair, bool _value);
    event UpdatedBuyFees(uint256 _trust, uint256 _raffle);
    event UpdatedSellFees(uint256 _trust, uint256 _raffle);
    event UpdatedSwapRaffleAt(uint256 _swapAt);
    event UpdatedSwapTrustAt(uint256 _swapAt);
    event TransferedToDeadAddress(address indexed _from, uint256 _amount);
    event SwappedForEth(uint256 _tokens, uint256 _eth);
    event TokenContestantsWinner(address indexed _winner, uint256 _tokens, uint256 _timestamp);
    event EthContestantsWinner(address indexed _winner, uint256 _eth);
    event EthHodlersWinner(address _winner, uint256 _eth);
    event WithdrewEth(address indexed _address, uint256 _amount, uint256 _timestamp);
    event AddedToContestants(address indexed _address);
    event AddedToHodlers(address indexed _address, uint256 _buyBlock, uint256 _blocksHodled);

    constructor() ERC20("VitaBlock AI", "VBlock") {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );

        uniswapV2Router = _uniswapV2Router;

        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(
            address(this),
            _uniswapV2Router.WETH()
        );
        _setAsAMM(address(uniswapV2Pair), true);

        uint256 _totalSupply = 1_000_000_000 * 10 ** decimals(); //one billion
        uint256 _twoPercentOfTotal = _totalSupply / 50;
        txMax = _twoPercentOfTotal; // 2% of supply transaction limit
        sellMax = _totalSupply / 100; // 1% of supply sell limit
        walletMax = _twoPercentOfTotal; // 2% of supply max wallet size

        uint256 _swapAt = _totalSupply / 1000; // 0.1% of total supply
        swapTrustTokensAt = _swapAt;
        swapRaffleTokensAt = _swapAt;

        minEligibility = _totalSupply / 10000; // 0.01%

        // The 5+5=10% early fees will be used to fill VB's 2% share, after which the fees will be automatically reduced to 2+2=4%
        _updateBuyFees(5, 5);
        _updateSellFees(5, 5);

        isExcludedFromFees[owner()] = true;
        isExcludedFromFees[address(this)] = true;

        isExcludedFromMaxTx[owner()] = true;
        isExcludedFromMaxTx[address(this)] = true;

        isExcludedFromMaxTx[address(_uniswapV2Router)] = true;
        isExcludedFromMaxTx[address(uniswapV2Pair)] = true;

        _mint(msg.sender, _totalSupply);

        currentRaffleCount = 1;
        lastHash = lastHash._getHash(msg.sender);
    }

    receive() external payable {}

    /**
     *
     * @notice This function would need to be invoked by VB before AUTUMN_EQUINOX_2023_TIMESTAMP
     * for full access to contract's onlyOwner functions. Please read "ETHICAL PLEDGE" prior to invoking.
     */
    function vbOnboard() external {
        /**
         * ETHICAL PLEDGE:
         * By executing this function, I, Vitalik Buterin, hereby proclaim my approval of this project
         * and pledge to ensure that the ETH and tokens collected in the treasuries of this contract will
         * be used only for purposes meant for the development of technologies, AI or otherwise, that will
         * help create a more secure crypto ecosystem.
         *
         * Furtheremore, I promise to swap the VBlock tokens collected in trustTokensTreasury in a manner that
         * would not jeapordise the overall health of this project.
         *
         * Where applicable, I shall ensure that privileged access will be granted to holders of VBlock tokens
         * to technologies/projects that receive funding through this contract.
         *
         * I understand that this is an ethical pledge between the VitaBlock community and I and, hence, not a legally binding contract.
         *
         */

        if (msg.sender != VB) revert ERC20_OnlyVB();
        if (block.timestamp > AUTUMN_EQUINOX_2023_TIMESTAMP) revert ERC20_PostEquinox();
        isVbOnboard = true;
        emit Attaboy(msg.sender);
    }

    function openTrading() external onlyOwner {
        isTradingOpen = true;
        isSwapping = false;
    }

    function updateBuyFees(uint256 _trust, uint256 _raffle) external onlyOwner {
        _updateBuyFees(_trust, _raffle);
    }

    function updateSellFees(uint256 _trust, uint256 _raffle) external onlyOwner {
        _updateSellFees(_trust, _raffle);
    }

    function getUintVars()
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            swapTrustTokensAt,
            swapRaffleTokensAt,
            minEligibility,
            raffleTokens,
            trustTokens,
            trustTokensTreasury,
            buyTrustFee,
            buyRaffleFee,
            sellTrustFee,
            sellRaffleFee
        );
    }

    function setAsAMM(address _address, bool _value) external onlyOwner {
        _setAsAMM(_address, _value);
    }

    function getBuyBlockAndBlocksCount(address _address) external view returns (uint256, uint256) {
        if (!isHodling[_address]) {
            return (0, 0);
        }
        return (buyBlocks[_address], block.number - buyBlocks[_address]);
    }

    function getRaffleEntrantsCounts() external view returns (uint256, uint256) {
        return (contestants.length, hodlers.length);
    }

    function getRaffleInfo(address _address) external view returns (uint256, bool, bool, bool) {
        return (
            currentRaffleCount,
            addressToRaffleCount[_address] == currentRaffleCount,
            isConfirmedHodler[_address],
            isHodling[_address]
        );
    }

    function checkBools() external view returns (bool, bool) {
        return (isSwapping, isVbOnboard);
    }

    function _setAsAMM(address _address, bool _value) internal {
        isAMM[_address] = _value;
        emit SetAsAMM(_address, _value);
    }

    function _updateBuyFees(uint256 _trust, uint256 _raffle) internal {
        if (_trust + _raffle > 10 || _raffle < 1) revert ERC20_Invalid();
        buyTrustFee = _trust;
        buyRaffleFee = _raffle;
        buyTotalFees = _trust + _raffle;
        emit UpdatedBuyFees(_trust, _raffle);
    }

    function _updateSellFees(uint256 _trust, uint256 _raffle) internal {
        if (_trust + _raffle > 10 || _raffle < 1) revert ERC20_Invalid();
        sellTrustFee = _trust;
        sellRaffleFee = _raffle;
        sellTotalFees = _trust + _raffle;
        emit UpdatedSellFees(_trust, _raffle);
    }

    function _transferToDeadAddress(address _from, uint256 _amount) internal {
        super._transfer(_from, address(0xdead), _amount);
        emit TransferedToDeadAddress(_from, _amount);
    }

    function _burn(address _account, uint256 _amount) internal override {
        if (msg.sender != owner()) revert ERC20_OnlyOwner();
        if (_account == address(this)) {
            if (_amount > trustTokensTreasury) revert ERC20_InsufficientTokens();
            super._burn(_account, _amount);
            trustTokensTreasury -= _amount;
        }
    }

    function _transfer(address _from, address _to, uint256 _amount) internal override {
        if (_from == address(0) || _to == address(0) || _amount == 0)
            revert ERC20_InvalidTransfer();
        if (_from == VB && !isVbOnboard) revert ERC20_PleaseOnboard();
        if (_to == address(0xdead)) {
            _transferToDeadAddress(_from, _amount);
            return;
        }
        bool _ranTrust;
        bool _ranRaffle;
        bool _isFromAMM = isAMM[_from];
        bool _isToAMM = isAMM[_to];
        if (block.timestamp > AUTUMN_EQUINOX_2023_TIMESTAMP && !_isFromAMM && !isEthRaffleDone) {
            _removeFromContestants(_from, false);
            if (!isVbOnboard) {
                //eliminate trust fees and double raffle fees
                _updateBuyFees(0, 2);
                _updateSellFees(0, 2);
            }
            isSwapping = true;
            _runEthRaffle();
            isSwapping = false;
            isEthRaffleDone = true;
            _ranTrust = true;
            _ranRaffle = true;
        }

        uint256 _initialBalanceOfTo = balanceOf(_to);
        uint256 _fees;
        uint256 _buyTotalFees;
        uint256 _walletMax = walletMax;
        bool _shouldReduceFees;
        uint256 _finalBalance;

        if (!isExcludedFromFees[_from] && !isExcludedFromFees[_to]) {
            if (!isTradingOpen || isSwapping) revert ERC20_TradingNotOpen();

            //buy
            if (_isFromAMM && !isExcludedFromMaxTx[_to]) {
                if (_amount > txMax) revert ERC20_ExceedsBuyLimit();
                _buyTotalFees = buyTotalFees;
                _fees = (_amount * _buyTotalFees) / 100;

                unchecked {
                    _finalBalance = _initialBalanceOfTo + _amount - _fees;
                }
                if (_finalBalance > _walletMax) revert ERC20_ExceedsWalletLimit();
            }
            //sell
            else if (!isExcludedFromMaxTx[_from] && _isToAMM && _amount > sellMax)
                revert ERC20_ExceedsSellLimit();
            //transfer
            else if (!_isFromAMM && !_isToAMM && _amount + _initialBalanceOfTo > _walletMax)
                revert ERC20_RecipientWillExceedLimit();
        }

        if (
            ((trustTokens >= swapTrustTokensAt) || (raffleTokens >= swapRaffleTokensAt)) &&
            !_isFromAMM &&
            !isExcludedFromFees[_from] &&
            !isExcludedFromFees[_to] &&
            isVbShareFilled
        ) {
            _removeFromContestants(_from, false);

            isSwapping = true;
            (_ranTrust, _ranRaffle) = _swapBack();
            isSwapping = false;
        }

        bool _hasFees = !isSwapping;

        if (isExcludedFromFees[_from] || isExcludedFromFees[_to]) _hasFees = false;

        //Only buys/sell fees. No fees for transfers between wallets
        if (_hasFees) {
            uint256 _trustTokens;
            // on sell
            if (_isToAMM && sellTotalFees > 0) {
                uint256 _sellTotalFees = sellTotalFees;

                unchecked {
                    _fees = (_amount * _sellTotalFees) / 100;
                    _trustTokens = (_fees * sellTrustFee) / _sellTotalFees;
                    raffleTokens += _fees - _trustTokens;
                }
            }
            // on buy
            else if (_isFromAMM && _buyTotalFees > 0) {
                unchecked {
                    _trustTokens = (_fees * buyTrustFee) / _buyTotalFees;
                    raffleTokens += _fees - _trustTokens;
                }
            }
            if (_trustTokens > 0) {
                uint256 _half;
                unchecked {
                    _half = _trustTokens / 2;
                    trustTokensTreasury += _half;
                    trustTokens += _trustTokens - _half;
                }
            }
            if (_fees > 0) {
                super._transfer(_from, address(this), _fees);
                if (!isVbShareFilled) {
                    _resetTokenCounters();
                    if (balanceOf(address(this)) >= _walletMax) {
                        uint256 _burnTokens = balanceOf(address(this)) - _walletMax;
                        if (balanceOf(VB) > 0) {
                            unchecked {
                                _walletMax = _walletMax - balanceOf(VB);
                                _burnTokens += balanceOf(VB);
                            }
                        }
                        super._transfer(address(this), VB, _walletMax);
                        emit TransferedVbShare(VB);
                        _transferToDeadAddress(address(this), _burnTokens);
                        isVbShareFilled = true;
                        _shouldReduceFees = true;
                    }
                }
                unchecked {
                    _amount -= _fees;
                }
            }
        }
        super._transfer(_from, _to, _amount);

        //buy
        if (_isFromAMM && !isExcludedFromMaxTx[_to] && _amount >= minEligibility)
            _addToContestants(_to);

            //sell or transfer
        else if ((!isExcludedFromMaxTx[_from] && _isToAMM) || (!_isFromAMM && !_isToAMM))
            _removeFromContestants(_from, true);

        //if transfering to contract
        if (_to == address(this)) {
            unchecked {
                trustTokensTreasury += _amount;
            }
        }
        if (_ranRaffle || _ranTrust) {
            uint256 _tokensInUniswap = balanceOf(address(uniswapV2Pair));
            uint _swapAt = _tokensInUniswap / 1000;
            if (_ranRaffle) {
                swapRaffleTokensAt = _swapAt;
                minEligibility = _tokensInUniswap / 10000;
                emit UpdatedSwapRaffleAt(_swapAt);
            }
            if (_ranTrust) {
                swapTrustTokensAt = _swapAt;
                emit UpdatedSwapTrustAt(_swapAt);
            }
        }
        //reduce buy/sell fees down to 4%
        if (_shouldReduceFees) {
            _updateBuyFees(2, 2);
            _updateSellFees(2, 2);
        }
    }

    function _addToContestants(address _address) internal {
        if (addressToRaffleCount[_address] == currentRaffleCount) return;

        uint256 _length = contestants.length;
        contestants.push(_address);
        contestantsIndexes[_address] = _length;
        addressToRaffleCount[_address] = currentRaffleCount;
        emit AddedToContestants(_address);

        if (!isEthRaffleDone && !isHodling[_address] && !isConfirmedHodler[_address]) {
            isHodling[_address] = true;
            if (buyBlocks[_address] == 0) {
                buyBlocks[_address] = block.number;
            }
        }
    }

    function _removeFromContestants(address _address, bool _shouldGetHash) internal {
        if (_shouldGetHash) {
            bool _isZero;
            unchecked {
                _isZero = block.timestamp % 2 == 0;
            }
            if (_isZero) {
                lastHash = lastHash._getHash(msg.sender);
            }
        }
        if (addressToRaffleCount[_address] == currentRaffleCount) {
            address[] memory _contestants = contestants;
            address _last = _contestants[_contestants.length - 1];
            uint256 _updateIndex = contestantsIndexes[_address];
            contestants[_updateIndex] = _last;
            contestantsIndexes[_last] = _updateIndex;
            contestants.pop();
            addressToRaffleCount[_address] = 0;
        }

        if (!isEthRaffleDone && isHodling[_address] && !isConfirmedHodler[_address]) {
            uint256 _blocksHodled;

            unchecked {
                _blocksHodled = block.number - buyBlocks[_address];
            }
            if (_blocksHodled >= MIN_HODL_BLOCKS) {
                hodlers.push(_address);
                isConfirmedHodler[_address] = true;
                emit AddedToHodlers(_address, block.number, _blocksHodled);
            }
            isHodling[_address] = false;
            buyBlocks[_address] = 0;
        }
    }

    function _resetContestants() internal {
        contestants = new address[](0);
        unchecked {
            currentRaffleCount++;
        }
    }

    function _resetTokenCounters() internal {
        trustTokens = 0;
        raffleTokens = 0;
        trustTokensTreasury = 0;
    }

    function _swapForEth(uint256 _tokens) internal {
        address[] memory _path = new address[](2);
        _path[0] = address(this);
        _path[1] = uniswapV2Router.WETH();
        uint256 _initialEth = address(this).balance;

        _approve(address(this), address(uniswapV2Router), _tokens);
        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            _tokens,
            0,
            _path,
            address(this),
            block.timestamp
        );
        uint256 _currentEth = address(this).balance;
        uint256 _ethGained;

        if (_currentEth > _initialEth) {
            unchecked {
                _ethGained = _currentEth - _initialEth;
            }
        }
        emit SwappedForEth(_tokens, _ethGained);
    }

    function _swapBack() internal returns (bool _ranTrust, bool _ranRaffle) {
        uint256 _burnTokens;
        uint256 _trustTokens = trustTokens;
        uint256 _raffleTokens = raffleTokens;
        uint256 _swapTrustTokensAt = swapTrustTokensAt;
        uint256 _swapRaffleTokensAt = swapRaffleTokensAt;

        if (
            balanceOf(address(this)) == 0 ||
            (_trustTokens < _swapTrustTokensAt && _raffleTokens < _swapRaffleTokensAt)
        ) return (false, false);

        if (_trustTokens >= _swapTrustTokensAt) {
            //swap for ETH treasury
            unchecked {
                _burnTokens += _trustTokens - _swapTrustTokensAt;
            }

            _swapForEth(_swapTrustTokensAt);

            trustTokens = 0;
            _ranTrust = true;
        }
        if (_raffleTokens >= _swapRaffleTokensAt) {
            //run raffle
            unchecked {
                _burnTokens += _raffleTokens - _swapRaffleTokensAt;
            }

            lastHash = lastHash._getHash(msg.sender);
            address _winner = contestants._selectWinner(lastHash);

            uint256 _transferAmount = _swapRaffleTokensAt;
            if (_winner != address(0xdead)) {
                uint256 _winnerBalance = balanceOf(_winner);
                uint256 _walletMax = walletMax;

                if (_winnerBalance + _transferAmount > _walletMax) {
                    unchecked {
                        _transferAmount = _walletMax - _winnerBalance;
                        _burnTokens += _swapRaffleTokensAt - _transferAmount;
                    }
                }
                super._transfer(address(this), _winner, _transferAmount);
            } else {
                unchecked {
                    _burnTokens += _transferAmount;
                }
            }
            _resetContestants();
            emit TokenContestantsWinner(_winner, _transferAmount, block.timestamp);
            raffleTokens = 0;
            _ranRaffle = true;
        }

        if (_burnTokens > 0) _transferToDeadAddress(address(this), _burnTokens);
        return (_ranTrust, _ranRaffle);
    }

    function _runEthRaffle() internal {
        if (address(this).balance > 0) {
            address[] memory _hodlers = hodlers;
            address[] memory _contestants = contestants;
            bool _success;
            bool _noContestants;
            uint256 _hodlersCount = _hodlers.length;
            uint256 _contestantsCount = _contestants.length;
            uint256 _rewardsCount = 5;
            uint256 _participantsCount;

            unchecked {
                _participantsCount = _hodlersCount + _contestantsCount;
            }

            uint256 _equinoxRafflePercentage = 25; // If Vitalik is onboard, 25% of contract ETH balance will be up for the raffle
            if (!isVbOnboard) _equinoxRafflePercentage = 100; //If Vitalik is not onboard, 100% of contract ETH balance will be up for the raffle

            uint256 _ethRewardTotal = (address(this).balance * _equinoxRafflePercentage) / 100;

            if (_participantsCount < _rewardsCount) {
                if (_participantsCount != 0) _rewardsCount = _participantsCount;
                else {
                    _noContestants = true;

                    if (!isVbOnboard) {
                        //In the highly unlikely event that there are zero contestants and hodlers and isVbOnboard == false, VB will reap all the rewards.
                        (_success, ) = payable(VB).call{value: _ethRewardTotal}("");
                        emit EthContestantsWinner(msg.sender, _ethRewardTotal / 2);
                        emit EthHodlersWinner(msg.sender, _ethRewardTotal / 2);
                    }
                }
            }

            if (!_noContestants) {
                address _winner;
                uint256 _ethRewardPerWinner = _ethRewardTotal / _rewardsCount;
                if (_contestantsCount != 0) {
                    lastHash = lastHash._getHash(msg.sender);
                    _winner = _contestants._selectWinner(lastHash);
                    (_success, ) = payable(_winner).call{value: _ethRewardPerWinner}("");
                    emit EthContestantsWinner(_winner, _ethRewardPerWinner);

                    unchecked {
                        _rewardsCount--;
                    }
                }

                if (_hodlersCount != 0) {
                    for (uint256 _i = 1; _i <= _rewardsCount; ) {
                        lastHash = lastHash._getHash(msg.sender);
                        _winner = _hodlers._selectWinner(lastHash);

                        if (!isHodlEthRaffleWinner[_winner]) {
                            isHodlEthRaffleWinner[_winner] = true;
                            if (_i == _rewardsCount && !isVbOnboard)
                                _ethRewardPerWinner = address(this).balance;

                            (_success, ) = payable(_winner).call{value: _ethRewardPerWinner}("");
                            emit EthHodlersWinner(_winner, _ethRewardPerWinner);

                            unchecked {
                                _i++;
                            }
                        }
                    }
                }
            }

            _transferToDeadAddress(
                address(this),
                (balanceOf(address(this)) * _equinoxRafflePercentage) / 100
            );
            _resetContestants();

            if (isVbOnboard) {
                trustTokensTreasury = balanceOf(address(this));
                trustTokens = 0;
                raffleTokens = 0;
            } else {
                _resetTokenCounters();
            }
        }
    }

    function withdrawContractEth(address _to, uint256 _eth) external onlyOwner {
        if (!isVbOnboard) revert ERC20_PleaseOnboard();
        if (!isEthRaffleDone) revert ERC20_PreEquinox();
        if (_eth == 0) _eth = address(this).balance;
        bool _success;
        (_success, ) = payable(_to).call{value: _eth}("");
        emit WithdrewEth(_to, _eth, block.timestamp);
    }

    function withdrawOrBurnTreasuryTokens(address _to, uint256 _amount) external onlyOwner {
        if (!isVbOnboard) revert ERC20_PleaseOnboard();
        if (!isEthRaffleDone) revert ERC20_PreEquinox();
        if (_amount > trustTokensTreasury) revert ERC20_InsufficientTokens();
        if (isSwapping) revert ERC20_SwapInProgress();
        if (_amount == 0) _amount = trustTokensTreasury;
        if (_to == address(0xdead) || _to == address(0)) {
            _transferToDeadAddress(address(this), _amount);
        } else {
            super._transfer(address(this), _to, _amount);
        }
        unchecked {
            trustTokensTreasury -= _amount;
        }
    }
}