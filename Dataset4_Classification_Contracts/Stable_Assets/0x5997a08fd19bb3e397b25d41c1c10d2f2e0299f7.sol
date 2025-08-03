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
// OpenZeppelin Contracts (last updated v4.9.4) (utils/Context.sol)

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

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/SafeMath.sol)

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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../XSD/XSDStablecoin.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract BankXToken is ERC20Custom {

    /* ========== STATE VARIABLES ========== */

    string public symbol;
    string public name;
    uint8 public constant decimals = 18;
    
    
    uint256 public genesis_supply; // 2B is printed upon genesis
    address public pool_address; //points to BankX pool address
    address public treasury; //stores the genesis supply
    address public router;
    XSDStablecoin private XSD; //XSD stablecoin instance
    address public smartcontract_owner;
    /* ========== MODIFIERS ========== */

    modifier onlyPools() {
       require(XSD.xsd_pools(msg.sender) == true, "BANKX:FORBIDDEN");
        _;
    } 
    
    modifier onlyByOwner() {
        require(msg.sender == smartcontract_owner, "BANKX:FORBIDDEN");
        _;
    }

    /* ========== CONSTRUCTOR ========== */

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _pool_amount, 
        uint256 _genesis_supply,
        address _treasury,
        address _smartcontract_owner
    ) {
        require((_treasury != address(0)), "BANKX:ZEROCHECK"); 
        name = _name;
        symbol = _symbol;
        genesis_supply = _genesis_supply + _pool_amount;
        treasury = _treasury;
        _mint(_msgSender(), _pool_amount);
        _mint(treasury, _genesis_supply);
        smartcontract_owner = _smartcontract_owner;

    
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    function setPool(address new_pool) external onlyByOwner {
        require(new_pool != address(0), "BANKX:ZEROCHECK");

        pool_address = new_pool;
    }

    function setTreasury(address new_treasury) external onlyByOwner {
        require(new_treasury != address(0), "BANKX:ZEROCHECK");
        treasury = new_treasury;
    }

    function setRouterAddress(address _router) external onlyByOwner {
        require(_router != address(0), "BANKX:ZEROCHECK");
        router = _router;
    }
    
    function setXSDAddress(address xsd_contract_address) external onlyByOwner {
        require(xsd_contract_address != address(0), "BANKX:ZEROCHECK");

        XSD = XSDStablecoin(xsd_contract_address);

        emit XSDAddressSet(xsd_contract_address);
    }
    
    function mint(address to, uint256 amount) public onlyPools {
        _mint(to, amount);
        emit BankXMinted(address(this), to, amount);
    }
    
    function genesisSupply() public view returns(uint256){
        return genesis_supply;
    }

    // This function is what other xsd pools will call to mint new BankX (similar to the XSD mint) 
    function pool_mint(address m_address, uint256 m_amount) external onlyPools  {        
        super._mint(m_address, m_amount);
        emit BankXMinted(address(this), m_address, m_amount);
    }

    // This function is what other xsd pools will call to burn BankX 
    function pool_burn_from(address b_address, uint256 b_amount) external onlyPools {

        super._burnFrom(b_address, b_amount);
        emit BankXBurned(b_address, address(this), b_amount);
    }
    //burn bankx from the pool when bankx is inflationary
    function burnpoolBankX(uint _bankx_amount) public {
        require(msg.sender == router, "BANKX:FORBIDDEN");
        require(totalSupply()>genesis_supply,"BankX must be deflationary");
        super._burn(pool_address, _bankx_amount);
        IBankXWETHpool(pool_address).sync();
        emit BankXBurned(msg.sender, address(this), _bankx_amount);
    }

    function setSmartContractOwner(address _smartcontract_owner) external{
        require(msg.sender == smartcontract_owner, "BANKX:FORBIDDEN");
        require(_smartcontract_owner != address(0), "BANKX:ZEROCHECK");
        smartcontract_owner = _smartcontract_owner;
    }

    function renounceOwnership() external{
        require(msg.sender == smartcontract_owner, "BANKX:FORBIDDEN");
        smartcontract_owner = address(0);
    }
    /* ========== EVENTS ========== */

    // Track BankX burned
    event BankXBurned(address indexed from, address indexed to, uint256 amount);

    // Track BankX minted
    event BankXMinted(address indexed from, address indexed to, uint256 amount);
    event XSDAddressSet(address addr);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// Due to compiling issues, _name, _symbol, and _decimals were removed


/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20Mintable}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
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
contract ERC20Custom is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) internal _balances;

    mapping (address => mapping (address => uint256)) internal _allowances;

    uint256 private _totalSupply;
    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
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
     * Requirements:
     *
     * - `spender` cannot be the zero address.approve(address spender, uint256 amount)
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
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address from, address to, uint256 amount) internal virtual {
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
     * Requirements
     *
     * - `to` cannot be the zero address.
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
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for `accounts`'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public virtual {
        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(amount, "ERC20: burn amount exceeds allowance");

        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
    }


    /**
     * @dev Transfers 'tokens' from 'account' to origin address, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
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
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
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
     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint256 amount) internal virtual {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of `from`'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of `from`'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:using-hooks.adoc[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
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
pragma solidity ^0.8.0;

interface AggregatorV3Interface {

  function decimals() external view returns (uint8);
  function description() external view returns (string memory);
  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./AggregatorV3Interface.sol";

contract ChainlinkETHUSDPriceConsumer {

    AggregatorV3Interface internal priceFeed;
    
    constructor() {
        priceFeed = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
    }

    /**
     * Returns the latest price
     */
    function getLatestPrice() public view returns (int) {
        (
            uint80 roundID
            , 
            int price,
            ,
            ,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        require(answeredInRound >= roundID);
        return price;
    }
    
    function getDecimals() public view returns (uint8) {
        return priceFeed.decimals();
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./AggregatorV3Interface.sol";

contract ChainlinkXAGUSDPriceConsumer {

    AggregatorV3Interface internal priceFeed;

    constructor() {
        priceFeed = AggregatorV3Interface(0x379589227b15F1a12195D3f2d90bBc9F31f95235);
    }

    /**
     * Returns the latest price
     */
    function getLatestPrice() public view returns (int) {
        (
            uint80 roundID
            , 
            int price,
            ,
            ,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        require(answeredInRound >= roundID);
        return price;
    }
    
    function getDecimals() public view returns (uint8) {
        return priceFeed.decimals();
    }
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

interface BankXInterface {

    function balanceOf(address account) external view returns (uint256);

    function pool_mint(address _entity, uint _amount) external;

    function pool_burn_from(address _entity, uint _amount) external;

    function genesis_supply() external returns (uint);

    function totalSupply() external view returns (uint);

    function updateTVLReached() external;

}
// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

interface ICD{
    function allocatedSupply() external view returns (uint256);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../XSD/XSDStablecoin.sol";
import "../BankX/BankXToken.sol";
import "../UniswapFork/BankXLibrary.sol";
import "../XSD/Pools/Interfaces/ICollateralPool.sol";
import "../XSD/Pools/Interfaces/IBankXWETHpool.sol";
import "../XSD/Pools/Interfaces/IXSDWETHpool.sol";
import "../Utils/Initializable.sol";
import "./Interfaces/BankXNFTInterface.sol";
import "./Interfaces/ICD.sol";


contract PIDController is Initializable {

    // Instances
    XSDStablecoin public XSD;
    BankXToken public BankX;
    IBankXWETHpool public bankxwethpool;
    IXSDWETHpool public xsdwethpool;
    ICollateralPool public collateralpool;
    
    // XSD and BankX addresses
    address public xsdwethpool_address;
    address public bankxwethpool_address;
    address public collateralpool_address;
    address public smartcontract_owner;
    address public BankXNFT_address;
    address public cd_address;
    uint public NFT_timestamp;
    address public reward_manager_address;
    address public WETH;

    // 6 decimals of precision
    uint256 public growth_ratio;
    uint256 public xsd_step;
    uint256 public internal_xsd_step;
    uint256 public GR_top_band;
    uint256 public GR_bottom_band;
    uint256 public pool_precision;

    // Time-related
    uint256 public internal_cooldown;
    uint256 public price_last_update;
    uint256 public collateral_ratio_cooldown;
    uint256 public ratio_last_update;
    
    // Booleans
    bool public is_active;
    bool public use_growth_ratio;
    bool public collateral_ratio_paused;
    bool public FIP_6;
    
    //deficit related variables
    bool public bucket1;
    bool public bucket2;
    bool public bucket3;

    uint public diff1;
    uint public diff2;
    uint public diff3;

    uint public timestamp1;
    uint public timestamp2;
    uint public timestamp3;

    uint public amountpaid1;
    uint public amountpaid2;
    uint public amountpaid3;

    //arbitrage relate variables
    uint256 public xsd_percent;
    uint256 public xsd_percentage_target;
    uint256 public bankx_percentage_target;
    uint256 public cd_allocated_supply;

    //price variables
    uint256 public bankx_updated_price;
    uint256 public xsd_updated_price;
    struct PriceCheck{
        uint256 lastpricecheck;
        bool pricecheck;
    }
    mapping (address => PriceCheck) public lastPriceCheck;
    uint256 public price_band;
    uint256 public price_target;
    enum PriceChoice { XSD, BankX }
    uint256 public global_collateral_ratio;
    uint256 public interest_rate;
    uint256 public neededWETH; // WETH needed to mint 1 XSD
    uint256 public neededBankX; // BankX needed to mint 1 XSD
    /* ========== MODIFIERS ========== */

    modifier onlyByOwner() {
        require(msg.sender == smartcontract_owner, "PID:FORBIDDEN");
        _;
    }
    modifier onlyByRewardManager() {
        require(msg.sender == reward_manager_address, "PID:FORBIDDEN");
        _;
    }
    modifier zeroCheck(address _address) {
        require(_address != address(0), "PID:ZEROCHECK");
        _;
    }
    modifier timeDelay(uint256 lastUpdate) {
        uint256 time_elapsed = block.timestamp - lastUpdate;
        require(time_elapsed >= internal_cooldown, "PID:COOLDOWN");
        _;
    }
    /* ========== CONSTRUCTOR ========== */
    function initialize(address _xsd_contract_address,address _bankx_contract_address,address _xsd_weth_pool_address, address _bankx_weth_pool_address,address _collateralpool_contract_address,address _WETHaddress,address _smartcontract_owner, uint _collateral_ratio_cooldown, uint _xsd_percentage_target, uint _bankx_percentage_target) public initializer{
        require(
            (_xsd_contract_address != address(0))
            && (_bankx_contract_address != address(0))
            && (_xsd_weth_pool_address != address(0))
            && (_bankx_weth_pool_address != address(0))
            && (_collateralpool_contract_address != address(0))
            && (_WETHaddress != address(0))
        , "BANKX:ZEROCHECK"); 
        xsdwethpool_address = _xsd_weth_pool_address;
        bankxwethpool_address = _bankx_weth_pool_address;
        xsdwethpool = IXSDWETHpool(_xsd_weth_pool_address);
        bankxwethpool = IBankXWETHpool(_bankx_weth_pool_address);
        smartcontract_owner = _smartcontract_owner;
        xsd_step = 2500;
        collateralpool_address = _collateralpool_contract_address;
        collateralpool = ICollateralPool(_collateralpool_contract_address);
        XSD = XSDStablecoin(_xsd_contract_address);
        BankX = BankXToken(_bankx_contract_address);
        WETH = _WETHaddress;
        xsd_percentage_target = _xsd_percentage_target;
        bankx_percentage_target = _bankx_percentage_target;
        collateral_ratio_cooldown = _collateral_ratio_cooldown;
        // Upon genesis, if GR changes by more than 1% percent, enable change of collateral ratio
        GR_top_band = 1000;
        GR_bottom_band = 1000; 
        is_active = true;
        pool_precision = 1000000;
        xsd_step = 2500; // 6 decimals of precision, equal to 0.25%
        global_collateral_ratio = 1000000; // XSD system starts off fully collateralized (6 decimals of precision)
        interest_rate = 52800; //interest rate starts off at 5%
        price_band = 5000; // Collateral ratio will not adjust if 0.005 off target at genesis
    }

    /* ========== PUBLIC MUTATIVE FUNCTIONS ========== */
    function systemCalculations() public {
    	require(collateral_ratio_paused == false, "PID:PAUSED");
        uint256 bankx_reserves = BankX.balanceOf(bankxwethpool_address);
        uint256 bankxprice = bankx_price();
        uint256 bankx_liquidity = bankx_reserves*bankxprice; // Has 6 decimals of precision
        uint256 xsd_supply = XSD.totalSupply();
        // Get the XSD price
        uint256 xsdprice = xsd_price();
        uint256 new_growth_ratio = (bankx_liquidity/(xsd_supply-collateralpool.collat_XSD())); // (E18 + E6) / E18
        uint256 last_collateral_ratio = global_collateral_ratio;
        uint256 new_collateral_ratio = last_collateral_ratio;
        uint256 silver_price = (XSD.xag_usd_price()*(1e4))/(311035); //31.1034768
        uint256 XSD_top_band = silver_price + (xsd_percent*silver_price)/100;
        uint256 XSD_bottom_band = silver_price - (xsd_percent*silver_price)/100;
        // make the top band and bottom band a percentage of silver price.
        if(FIP_6){
            require(xsdprice > XSD_top_band || xsdprice < XSD_bottom_band, "Use PIDController when XSD is outside of peg");
        }

       if((NFT_timestamp == 0) || ((block.timestamp - NFT_timestamp)>43200)){
            BankXInterface(BankXNFT_address).updateTVLReached();
            NFT_timestamp = block.timestamp;
        }

        // First, check if the price is out of the band
        // disable this if ratio is zero
        if(xsdprice > XSD_top_band){
            if(last_collateral_ratio<xsd_step){
                new_collateral_ratio = 0;
            }
            else{
                new_collateral_ratio = last_collateral_ratio - xsd_step;
            }
            
        } else if (xsdprice < XSD_bottom_band){
            new_collateral_ratio = last_collateral_ratio + xsd_step;
            

        // Else, check if the growth ratio has increased or decreased since last update
        } else if(use_growth_ratio){
            if(new_growth_ratio > ((growth_ratio*(1e6 + GR_top_band))/1e6)){
                new_collateral_ratio = last_collateral_ratio - xsd_step;
            } else if (new_growth_ratio < (growth_ratio*(1e6 - GR_bottom_band)/1e6)){
                new_collateral_ratio = last_collateral_ratio + xsd_step;
            }
        }
        growth_ratio = new_growth_ratio;
        // No need for checking CR under 0 as the last_collateral_ratio.sub(xsd_step) will throw 
        // an error above in that case
        if(new_collateral_ratio > 1e6){
            new_collateral_ratio = 1e6;
        }
        incentiveChecker1();
        incentiveChecker2();
        incentiveChecker3();
        // The code snippet below is responsible for safely updating the global collateral ratio. Only the local variable is updated above.
        uint256 time_elapsed = block.timestamp - ratio_last_update;
        if(is_active && (time_elapsed>= collateral_ratio_cooldown)){
            uint256 delta_collateral_ratio;
            if(new_collateral_ratio > last_collateral_ratio){
                delta_collateral_ratio = new_collateral_ratio - last_collateral_ratio;
                setInternalPriceTarget(1000e6); // Set to high value to decrease CR
                emit XSDdecollateralize(new_collateral_ratio);
            } else if (new_collateral_ratio < last_collateral_ratio){
                delta_collateral_ratio = last_collateral_ratio - new_collateral_ratio;
                setInternalPriceTarget(0); // Set to zero to increase CR
                emit XSDrecollateralize(new_collateral_ratio);
            }

            setInternalXSDStep(delta_collateral_ratio); // Change by the delta
            // interest rate
            // Step increments are 0.25% (upon genesis, changable by setXSDStep()) 
            if (xsdprice > price_target+price_band) { //decrease collateral ratio
                if(global_collateral_ratio <= internal_xsd_step){ //if within a step of 0, go to 0
                global_collateral_ratio = 0;
                } else {
                    global_collateral_ratio = global_collateral_ratio-internal_xsd_step;
                }
            } else if (xsdprice < price_target-price_band) { //increase collateral ratio
                if(global_collateral_ratio+internal_xsd_step >= 1000000){
                    global_collateral_ratio = 1000000; // cap collateral ratio at 1.000000
                } else {
                global_collateral_ratio = global_collateral_ratio+internal_xsd_step;
                }
            }
            uint256 _interest_rate = (1000000-global_collateral_ratio)/(2);
            //update interest rate
            if(_interest_rate>52800){
                interest_rate = _interest_rate;
            }
            else{
                interest_rate = 52800;
            }
            // Reset params
            setInternalXSDStep(0);
            //change price target to that of one ounce/gram of silver.
            setInternalPriceTarget((XSD.xag_usd_price()*(1e4))/(311035)); 
            ratio_last_update = block.timestamp;   
            emit PIDCollateralRatioRefreshed(global_collateral_ratio);       
        }
        priceCheck();
    }

    function priceCheck() public timeDelay(price_last_update){
        uint silver_price = (XSD.xag_usd_price()*(1e4))/(311035);
        uint weth_dollar_needed = (silver_price*global_collateral_ratio);
        uint bankx_dollar_needed = (silver_price*1e6 - weth_dollar_needed);
        bankx_updated_price = bankx_price();
        xsd_updated_price = xsd_price();
        neededWETH = weth_dollar_needed/XSD.eth_usd_price(); // precision of 1e6
        neededBankX = bankx_dollar_needed/bankx_price(); // precision of 1e6
        lastPriceCheck[msg.sender].lastpricecheck = block.number;
        lastPriceCheck[msg.sender].pricecheck = true;
        price_last_update = block.timestamp;
    }

    function setPriceCheck(address sender) public zeroCheck(sender){
        lastPriceCheck[sender].pricecheck = false;
    }

    //checks the XSD liquidity pool for a deficit.
    //bucket and difference variables should return values only if changed.
    // difference is calculated only every week.
    function incentiveChecker1() internal{
        uint silver_price = (XSD.xag_usd_price()*(1e4))/(311035);
        uint XSDvalue = (XSD.totalSupply()*(silver_price))/(1e6);
        uint _reserve1;
        (,_reserve1,) = IXSDWETHpool(xsdwethpool_address).getReserves();
        uint reserve = (_reserve1*(XSD.eth_usd_price())*2)/(1e6);
        if(((block.timestamp - timestamp1)>=64800)||(amountpaid1 >= diff3)){
            timestamp1 = 0;
            bucket1 = false;
            diff1 = 0;
            amountpaid1 = 0;
        }
        if(timestamp1 == 0){
        if(reserve<((XSDvalue*xsd_percentage_target)/100)){
            bucket1 = true;
            diff1 = (((XSDvalue*xsd_percentage_target)/100)-reserve)/2;
            timestamp1 = block.timestamp;
        }
        }
    }

    //checks the BankX liquidity pool for a deficit.
    //bucket and difference variables should return values only if changed.
    function incentiveChecker2() internal{
        cd_allocated_supply = ICD(cd_address).allocatedSupply();
        uint BankXvalue = (cd_allocated_supply*(bankx_price()))/(1e6);
        uint _reserve1;
        (, _reserve1,) = IBankXWETHpool(bankxwethpool_address).getReserves();
        uint reserve = (_reserve1*(XSD.eth_usd_price())*2)/(1e6);
        if(((block.timestamp - timestamp2)>=64800)|| (amountpaid2 >= diff2)){
            timestamp2 = 0;
            bucket2 = false;
            diff2 = 0;
            amountpaid2 = 0;
        }
        if(timestamp2 == 0){
        if(reserve<((BankXvalue*bankx_percentage_target)/100)){
            bucket2 = true;
            diff2 = (((BankXvalue*bankx_percentage_target)/100) - reserve)/2;
            timestamp2 = block.timestamp;
        }
        }
    }

    //checks the Collateral pool for a deficit
    // return system collateral as a public global variable
    function incentiveChecker3() internal{
        uint silver_price = (XSD.xag_usd_price()*(1e4))/(311035);
        uint XSDvalue = (collateralpool.collat_XSD()*(silver_price))/(1e6);//use gram of silver price
        uint collatValue = collateralpool.collatDollarBalance();// eth value in the collateral pool
        XSDvalue = (XSDvalue * global_collateral_ratio)/(1e6);
        if(((block.timestamp-timestamp3)>=604800) || (amountpaid3 >= diff3)){
            timestamp3 = 0;
            bucket3 = false;
            diff3 = 0;
            amountpaid3 = 0;
        }
        if(timestamp3 == 0 && collatValue != 0){
        if((collatValue*400)<=(3*XSDvalue)){ //posted collateral - actual collateral <= 0.25% posted collateral
            bucket3 = true;
            diff3 = (3*XSDvalue) - (collatValue*400); 
            timestamp3 = block.timestamp;
        }
        }
    }

    function pool_price(PriceChoice choice) internal view returns (uint256) {
        // Get the ETH / USD price first, and cut it down to 1e6 precision
        uint256 _eth_usd_price = XSD.eth_usd_price();
        uint256 price_vs_eth = 0;
        uint256 reserve0;
        uint256 reserve1;
        if (choice == PriceChoice.XSD) {
            (reserve0, reserve1, ) = xsdwethpool.getReserves();
        }
        else if (choice == PriceChoice.BankX) {
            (reserve0, reserve1, ) = bankxwethpool.getReserves();
        }
        else revert("INVALID PRICE CHOICE. Needs to be either 0 (XSD) or 1 (BankX)");
         if(reserve0 == 0 || reserve1 == 0){
                return 1;
            }
        price_vs_eth = ((reserve0*pool_precision)/reserve1);
        // Will be in 1e6 format
        uint256 price = ((_eth_usd_price*pool_precision)/price_vs_eth);
        return price;
    }

    function xsd_price() public view returns (uint256) {
        return pool_price(PriceChoice.XSD);
    }

    function bankx_price()  public view returns (uint256) {
        return pool_price(PriceChoice.BankX);
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    //functions to change amountpaid variables
    function amountPaidXSDWETH(uint ethvalue) external onlyByRewardManager() {
        amountpaid1 += ethvalue;
    }

    function amountPaidBankXWETH(uint ethvalue) external onlyByRewardManager(){
        amountpaid2 += ethvalue;
    }
    
    function amountPaidCollateralPool(uint ethvalue) external onlyByRewardManager(){
        amountpaid3 += ethvalue;
    }

    function setInternalPriceTarget(uint256 _new_price_target) internal {
         price_target = _new_price_target;

        emit InternalPriceTargetSet(_new_price_target);
    }

    function setInternalXSDStep(uint256 _new_step) internal {
        internal_xsd_step = _new_step;

        emit InternalXSDStepSet(_new_step);
    }  

    /* ========== ADMIN FUNCTIONS ========== */
    function activate(bool _state) external onlyByOwner {
        is_active = _state;
    }

    function useGrowthRatio(bool _use_growth_ratio) external onlyByOwner {
        use_growth_ratio = _use_growth_ratio;
    }

    // As a percentage added/subtracted from the previous; e.g. top_band = 4000 = 0.4% -> will decollat if GR increases by 0.4% or more
    function setGrowthRatioBands(uint256 _GR_top_band, uint256 _GR_bottom_band) external onlyByOwner {
        GR_top_band = _GR_top_band;
        GR_bottom_band = _GR_bottom_band;
    }

    function setInternalCooldown(uint256 _internal_cooldown) external onlyByOwner {
        internal_cooldown = _internal_cooldown;
    }

    function setPriceBandPercentage(uint256 percent) external onlyByOwner {
        require(percent!=0,"PID:ZEROCHECK");
        xsd_percent = percent;
    }

    function toggleCollateralRatio(bool _is_paused) external onlyByOwner {
    	collateral_ratio_paused = _is_paused;
    }

    function activateFIP6(bool _activate) external onlyByOwner {
        FIP_6 = _activate;
    }

    function setSmartContractOwner(address _smartcontract_owner) external onlyByOwner zeroCheck(_smartcontract_owner){
        smartcontract_owner = _smartcontract_owner;
    }

    function renounceOwnership() external onlyByOwner{
        smartcontract_owner = address(0);
    }
    
    function setXSDPoolAddress(address _xsd_weth_pool_address) external onlyByOwner{
        xsdwethpool_address = _xsd_weth_pool_address;
        xsdwethpool = IXSDWETHpool(_xsd_weth_pool_address);
    }

    function setBankXPoolAddress(address _bankx_weth_pool_address) external onlyByOwner{
        bankxwethpool_address = _bankx_weth_pool_address;
        bankxwethpool = IBankXWETHpool(_bankx_weth_pool_address);
    }
    
    function setRewardManagerAddress(address _reward_manager_address) external onlyByOwner{
        reward_manager_address = _reward_manager_address;
    }

    function setCollateralPoolAddress(address payable _collateralpool_contract_address) external onlyByOwner{
        collateralpool_address = _collateralpool_contract_address;
        collateralpool = ICollateralPool(_collateralpool_contract_address);
    }

    function setXSDAddress(address _xsd_contract_address) external onlyByOwner{
        XSD = XSDStablecoin(_xsd_contract_address);
    }

    function setBankXAddress(address _bankx_contract_address) external onlyByOwner{
        BankX = BankXToken(_bankx_contract_address);
    }

    function setWETHAddress(address _WETHaddress) external onlyByOwner{
        WETH = _WETHaddress;
    }

    function setBankXNFTAddress(address _BankXNFT_address) external onlyByOwner{
        BankXNFT_address = _BankXNFT_address;
    }

    function setCDAddress(address _cd_address) external onlyByOwner{
        cd_address = _cd_address;
    }

    function setPercentageTarget(uint256 _xsd_percentage_target, uint256 _bankx_percentage_target) external onlyByOwner{
        xsd_percentage_target = _xsd_percentage_target;
        bankx_percentage_target = _bankx_percentage_target;
    }

    function setPriceTarget(uint256 _new_price_target) external onlyByOwner {
        price_target = _new_price_target;
        emit PriceTargetSet(_new_price_target);
    }

    function setXSDStep(uint256 _new_step) external onlyByOwner {
        xsd_step = _new_step;
        emit XSDStepSet(_new_step);
    }

    function setPoolPrecision(uint256 _pool_precision) external onlyByOwner {
        require(_pool_precision!= 0, "Zero value detected");
        pool_precision = _pool_precision;
    }

    function setPriceBand(uint256 _price_band) external onlyByOwner {
        price_band = _price_band;
    }

    function setInterestRate(uint256 _interest_rate) external onlyByOwner{
        interest_rate = _interest_rate;
    }

    function setRatioCooldown(uint256 _ratio_cooldown) external onlyByOwner{
        collateral_ratio_cooldown = _ratio_cooldown;
    }
    /* ========== EVENTS ========== */  
    event XSDdecollateralize(uint256 new_collateral_ratio);
    event XSDrecollateralize(uint256 new_collateral_ratio);
    event InternalPriceTargetSet(uint256 new_price_target);
    event InternalXSDStepSet(uint256 _new_step);
    event PriceTargetSet(uint256 _new_price_target);
    event XSDStepSet(uint256 _new_step);
    event PIDCollateralRatioRefreshed(uint256 global_collateral_ratio);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


library BankXLibrary {

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, 'BankXLibrary: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'BankXLibrary: INSUFFICIENT_LIQUIDITY');
        amountB = (amountA*reserveB) / reserveA;
    }
   
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.4.24;


/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBankXWETHpool {
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);
    function collatDollarBalance() external returns(uint);
    function swap(uint amount0Out, uint amount1Out, address to) external;
    function skim(address to) external;
    function sync() external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICollateralPool{
    function userProvideLiquidity(address to, uint amount1) external;
    function collat_XSD() external returns(uint);
    function mintAlgorithmicXSD(uint256 bankx_amount_d18, uint256 XSD_out_min) external;
    function collatDollarBalance() external returns(uint);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IXSDWETHpool {
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);
    function collatDollarBalance() external returns (uint);
    function swap(uint amount0Out, uint amount1Out, address to) external;
    function skim(address to) external;
    function sync() external;
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "../ERC20/ERC20Custom.sol";
import "./Pools/Interfaces/IXSDWETHpool.sol";
import "./Pools/Interfaces/IBankXWETHpool.sol";
import "./Pools/Interfaces/ICollateralPool.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "../Oracle/ChainlinkETHUSDPriceConsumer.sol";
import "../Oracle/ChainlinkXAGUSDPriceConsumer.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract XSDStablecoin is ERC20Custom {

    /* ========== STATE VARIABLES ========== */
    enum PriceChoice { XSD, BankX }
    ChainlinkETHUSDPriceConsumer private eth_usd_pricer;
    ChainlinkXAGUSDPriceConsumer private xag_usd_pricer;
    uint8 private eth_usd_pricer_decimals;
    uint8 private xag_usd_pricer_decimals;
    string public symbol;
    string public name;
    uint8 public constant decimals = 18;
    address public treasury; 
    address public collateral_pool_address;
    address public router;
    address public eth_usd_oracle_address;
    address public xag_usd_oracle_address;
    address public smartcontract_owner;
    IBankXWETHpool private bankxEthPool;
    IXSDWETHpool private xsdEthPool;
    uint256 public cap_rate;
    uint256 public genesis_supply; 

    // The addresses in this array are added by the oracle and these contracts are able to mint xsd
    address[] public xsd_pools_array;

    // Mapping is also used for faster verification
    mapping(address => bool) public xsd_pools; 

    // Constants for various precisions
    uint256 private constant PRICE_PRECISION = 1e6;

    /* ========== MODIFIERS ========== */

    modifier onlyPools() {
       require(xsd_pools[msg.sender] == true, "Only xsd pools can call this function");
        _;//check happens before the function is executed 
    } 

    modifier onlyByOwner(){
        require(msg.sender == smartcontract_owner, "You are not the owner");
        _;
    }

    modifier onlyByOwnerOrPool() {
        require(
            msg.sender == smartcontract_owner  
            || xsd_pools[msg.sender] == true, 
            "You are not the owner or a pool");
        _;
    }

    /* ========== CONSTRUCTOR ========== */

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _pool_amount,
        uint256 _genesis_supply,
        address _smartcontract_owner,
        address _treasury,
        uint256 _cap_rate
    ) {
        require((_smartcontract_owner != address(0))
                && (_treasury != address(0)), "Zero address detected"); 
        name = _name;
        symbol = _symbol;
        genesis_supply = _genesis_supply + _pool_amount;
        treasury = _treasury;
        _mint(_smartcontract_owner, _pool_amount);
        _mint(treasury, _genesis_supply);
        smartcontract_owner = _smartcontract_owner;
        cap_rate = _cap_rate;// Maximum mint amount
    }
    /* ========== VIEWS ========== */

    function eth_usd_price() public view returns (uint256) {
        return (uint256(eth_usd_pricer.getLatestPrice())*PRICE_PRECISION)/(uint256(10) ** eth_usd_pricer_decimals);
    }
    //silver price
    //hard coded value for testing on goerli
    function xag_usd_price() public view returns (uint256) {
        return (uint256(xag_usd_pricer.getLatestPrice())*PRICE_PRECISION)/(uint256(10) ** xag_usd_pricer_decimals);
    }

    /* ========== PUBLIC FUNCTIONS ========== */

    function creatorMint(uint256 amount) public onlyByOwner{
        require(genesis_supply+amount<cap_rate,"cap limit reached");
        super._mint(treasury,amount);
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    // Used by pools when user redeems
    function pool_burn_from(address b_address, uint256 b_amount) public onlyPools {
        super._burnFrom(b_address, b_amount);
        emit XSDBurned(b_address, msg.sender, b_amount);
    }

    // This function is what other xsd pools will call to mint new XSD 
    function pool_mint(address m_address, uint256 m_amount) public onlyPools {
        super._mint(m_address, m_amount);
        emit XSDMinted(msg.sender, m_address, m_amount);
    }
    

    // Adds collateral addresses supported, such as tether and busd, must be ERC20 
    function addPool(address pool_address) public onlyByOwner {
        require(pool_address != address(0), "Zero address detected");

        require(xsd_pools[pool_address] == false, "Address already exists");
        xsd_pools[pool_address] = true; 
        xsd_pools_array.push(pool_address);

        emit PoolAdded(pool_address);
    }

    // Remove a pool 
    function removePool(address pool_address) public onlyByOwner {
        require(pool_address != address(0), "Zero address detected");

        require(xsd_pools[pool_address] == true, "Address nonexistant");
        
        // Delete from the mapping
        delete xsd_pools[pool_address];

        // 'Delete' from the array by setting the address to 0x0
        for (uint i = 0; i < xsd_pools_array.length; i++){ 
            if (xsd_pools_array[i] == pool_address) {
                xsd_pools_array[i] = address(0); // This will leave a null in the array and keep the indices the same
                break;
            }
        }

        emit PoolRemoved(pool_address);
    }
// create a seperate function for users and the pool
    function burnpoolXSD(uint _xsdamount) public {
        require(msg.sender == router, "Only the router can access this function");
        require(totalSupply()-ICollateralPool(payable(collateral_pool_address)).collat_XSD()>_xsdamount, "uXSD has to be positive");
        super._burn(address(xsdEthPool),_xsdamount);
        xsdEthPool.sync();
        emit XSDBurned(msg.sender, address(this), _xsdamount);
    }
    // add burn function for users
    function burnUserXSD(uint _xsdamount) public {
        require(totalSupply()-ICollateralPool(payable(collateral_pool_address)).collat_XSD()>_xsdamount, "uXSD has to be positive");
        super._burn(msg.sender, _xsdamount);
        emit XSDBurned(msg.sender, address(this), _xsdamount);
    }

    function setTreasury(address _new_treasury) public onlyByOwner {
        require(_new_treasury != address(0), "Zero address detected");
        treasury = _new_treasury;
    }

    function setETHUSDOracle(address _eth_usd_oracle_address) public onlyByOwner {
        require(_eth_usd_oracle_address != address(0), "Zero address detected");

        eth_usd_oracle_address = _eth_usd_oracle_address;
        eth_usd_pricer = ChainlinkETHUSDPriceConsumer(eth_usd_oracle_address);
        eth_usd_pricer_decimals = eth_usd_pricer.getDecimals();

        emit ETHUSDOracleSet(_eth_usd_oracle_address);
    }
    
    function setXAGUSDOracle(address _xag_usd_oracle_address) public onlyByOwner {
        require(_xag_usd_oracle_address != address(0), "Zero address detected");

        xag_usd_oracle_address = _xag_usd_oracle_address;
        xag_usd_pricer = ChainlinkXAGUSDPriceConsumer(xag_usd_oracle_address);
        xag_usd_pricer_decimals = xag_usd_pricer.getDecimals();

        emit XAGUSDOracleSet(_xag_usd_oracle_address);
    }

    function setRouterAddress(address _router) external onlyByOwner {
        require(_router != address(0), "Zero address detected");
        router = _router;
    }

    // Sets the XSD_ETH Uniswap oracle address 
    function setXSDEthPool(address _xsd_pool_addr) public onlyByOwner {
        require(_xsd_pool_addr != address(0), "Zero address detected");
        xsdEthPool = IXSDWETHpool(_xsd_pool_addr); 

        emit XSDETHPoolSet(_xsd_pool_addr);
    }

    // Sets the BankX_ETH Uniswap oracle address 
    function setBankXEthPool(address _bankx_pool_addr) public onlyByOwner {
        require(_bankx_pool_addr != address(0), "Zero address detected");
        bankxEthPool = IBankXWETHpool(_bankx_pool_addr);

        emit BankXEthPoolSet(_bankx_pool_addr);
    }

    //sets the collateral pool address
    function setCollateralEthPool(address _collateral_pool_address) public onlyByOwner {
        require(_collateral_pool_address != address(0), "Zero address detected");
        collateral_pool_address = payable(_collateral_pool_address);
    }

    function setSmartContractOwner(address _smartcontract_owner) external{
        require(msg.sender == smartcontract_owner, "Only the smart contract owner can access this function");
        require(_smartcontract_owner != address(0), "Zero address detected");
        smartcontract_owner = _smartcontract_owner;
    }

    function renounceOwnership() external{
        require(msg.sender == smartcontract_owner, "Only the smart contract owner can access this function");
        smartcontract_owner = address(0);
    }

    
    /* ========== EVENTS ========== */

    // Track XSD burned
    event XSDBurned(address indexed from, address indexed to, uint256 amount);
    // Track XSD minted
    event XSDMinted(address indexed from, address indexed to, uint256 amount);
    event PoolAdded(address pool_address);
    event PoolRemoved(address pool_address);
    event RedemptionFeeSet(uint256 red_fee);
    event MintingFeeSet(uint256 min_fee);
    event ETHUSDOracleSet(address eth_usd_oracle_address);
    event XAGUSDOracleSet(address xag_usd_oracle_address);
    event PIDControllerSet(address _pid_controller);
    event XSDETHPoolSet(address xsd_pool_addr);
    event BankXEthPoolSet(address bankx_pool_addr);
}