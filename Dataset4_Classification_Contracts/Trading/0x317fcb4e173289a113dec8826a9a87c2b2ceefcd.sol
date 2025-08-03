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

pragma solidity ^0.8.19;
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./libraries/SafeMath.sol";
import "./interfaces/LDNWealthTrackerInterface.sol";

interface IPair {
    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function token0() external view returns (address);
}

interface IFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);

    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);
}

interface IUniswapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    )
        external
        payable
        returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract LDNWealthTracker is ERC20, LDNWealthTrackerInterface, Ownable {
    using SafeMath for uint256;
    using SafeMathUint for uint256;
    using SafeMathInt for int256;

    address public lpToken;
    address public platformToken;

    // With `magnitude`, we can properly distribute dividends even if the amount of received ether is small.
    // For more discussion about choosing the value of `magnitude`,
    //  see https://github.com/ethereum/EIPs/issues/1726#issuecomment-472352728
    uint256 internal constant magnitude = 2 ** 128;

    uint256 internal MagnifiedDividendPerShareLP;
    uint256 internal MagnifiedDividendPerShareToken;

    // About dividendCorrection:
    // If the token balance of a `_user` is never changed, the dividend of `_user` can be computed with:
    //   `dividendOf(_user) = dividendPerShare * balanceOf(_user)`.
    // When `balanceOf(_user)` is changed (via minting/burning/transferring tokens),
    //   `dividendOf(_user)` should not be changed,
    //   but the computed value of `dividendPerShare * balanceOf(_user)` is changed.
    // To keep the `dividendOf(_user)` unchanged, we add a correction term:
    //   `dividendOf(_user) = dividendPerShare * balanceOf(_user) + dividendCorrectionOf(_user)`,
    //   where `dividendCorrectionOf(_user)` is updated whenever `balanceOf(_user)` is changed:
    //   `dividendCorrectionOf(_user) = dividendPerShare * (old balanceOf(_user)) - (new balanceOf(_user))`.
    // So now `dividendOf(_user)` returns the same value before and after `balanceOf(_user)` is changed.
    mapping(address => int256) internal magnifiedDividendCorrectionsLP;
    mapping(address => int256) internal magnifiedDividendCorrectionsToken;

    mapping(address => uint256) internal withdrawnDividendsLP;
    mapping(address => uint256) internal withdrawnDividendsToken;




    uint256 public totalDividendsDistributedLP;
    uint256 public totalDividendsDistributedToken;

    uint256 public totalDividendsWithdrawnLP;
    uint256 public totalDividendsWithdrawnToken;

    constructor(
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol) {}

    function distributeDividends(uint256 amountLP, uint256 amountToken) public onlyOwner {
        require(totalSupply() > 0, "Total supply must be greater than zero");

        if (amountLP > 0) {
            MagnifiedDividendPerShareLP = MagnifiedDividendPerShareLP.add(
                (amountLP).mul(magnitude) / totalSupply()
            );
            emit DividendsDistributed(msg.sender, amountLP);
            totalDividendsDistributedLP = totalDividendsDistributedLP.add(amountLP);
        }

        if (amountToken > 0) {
            MagnifiedDividendPerShareToken = MagnifiedDividendPerShareToken.add(
                (amountToken).mul(magnitude) / totalSupply()
            );
            emit DividendsDistributed(msg.sender, amountToken);
            totalDividendsDistributedToken = totalDividendsDistributedToken.add(amountToken);
        }
    }

    /// @notice Withdraws the ether distributed to the sender.
    /// @dev It emits a `DividendWithdrawn` event if the amount of withdrawn ether is greater than 0.
    function withdrawDividend() public 
    // virtual override 
    {
        _withdrawDividendOfUser(msg.sender);
    }

    /// @notice Withdraws the ether distributed to the sender.
    /// @dev It emits a `DividendWithdrawn` event if the amount of withdrawn ether is greater than 0.
    function _withdrawDividendOfUser(
        address user
    ) internal returns (uint256, uint256) {
        uint256 withdrawableLP;
        uint256 withdrawableToken;
        (uint256 _withdrawableDividendLP, uint256 _withdrawableDividendToken) = withdrawableDividendOf(user);
        if (_withdrawableDividendLP > 0) {
            withdrawnDividendsLP[user] = withdrawnDividendsLP[user].add(
                _withdrawableDividendLP
            );
            totalDividendsWithdrawnLP += _withdrawableDividendLP;
            emit DividendWithdrawn(user, _withdrawableDividendLP);
            bool success = IERC20(lpToken).transfer(
                user,
                _withdrawableDividendLP
            );

            if (!success) {
                withdrawnDividendsLP[user] = withdrawnDividendsLP[user].sub(
                    _withdrawableDividendLP
                );
                totalDividendsWithdrawnLP -= _withdrawableDividendLP;
            } else {
                withdrawableLP = _withdrawableDividendLP;
            }
        }

        if (_withdrawableDividendToken > 0) {
            withdrawnDividendsToken[user] = withdrawnDividendsToken[user].add(
                _withdrawableDividendToken
            );
            totalDividendsWithdrawnToken += _withdrawableDividendToken;
            emit DividendWithdrawn(user, _withdrawableDividendToken);
            bool success = IERC20(platformToken).transfer(
                user,
                _withdrawableDividendToken
            );

            if (!success) {
                withdrawnDividendsToken[user] = withdrawnDividendsToken[user].sub(
                    _withdrawableDividendToken
                );
                totalDividendsWithdrawnToken -= _withdrawableDividendToken;
            } else {
                withdrawableToken = _withdrawableDividendToken;}
        }

        return (withdrawableLP, withdrawableToken);
    }

    /// @notice View the amount of dividend in wei that an address can withdraw.
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` can withdraw.
    function dividendOf(address _owner) public view 
    override 
    returns (uint256, uint256) {
        return withdrawableDividendOf(_owner);
    }

    /// @notice View the amount of dividend in wei that an address can withdraw.
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` can withdraw.
    function withdrawableDividendOf(
        address _owner
    ) public view 
    override 
    returns (uint256, uint256) {
        (uint256 dividendOfLP, uint256 dividendOfShareToken) = accumulativeDividendOf(_owner);
        return (dividendOfLP.sub(withdrawnDividendsLP[_owner]),
            dividendOfShareToken.sub(withdrawnDividendsToken[_owner])
        );
    }

    /// @notice View the amount of dividend in wei that an address has withdrawn.
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` has withdrawn.
    function withdrawnDividendOf(
        address _owner
    ) public view 
    override 
    returns (uint256, uint256) {
        return (withdrawnDividendsLP[_owner], withdrawnDividendsToken[_owner]);
    }

    /// @notice View the amount of dividend in wei that an address has earned in total.
    /// @dev accumulativeDividendOf(_owner) = withdrawableDividendOf(_owner) + withdrawnDividendOf(_owner)
    /// = (magnifiedDividendPerShare * balanceOf(_owner) + magnifiedDividendCorrections[_owner]) / magnitude
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` has earned in total.
    function accumulativeDividendOf(
        address _owner
    ) public view 
    override 
    returns (uint256, uint256) {
        uint256 lpShare = 
            MagnifiedDividendPerShareLP
                .mul(balanceOf(_owner))
                .toInt256Safe()
                .add(magnifiedDividendCorrectionsLP[_owner])
                .toUint256Safe() / magnitude;
        uint256 tokenShare = 
            MagnifiedDividendPerShareToken
                .mul(balanceOf(_owner))
                .toInt256Safe()
                .add(magnifiedDividendCorrectionsToken[_owner])
                .toUint256Safe() / magnitude;
        return (lpShare, tokenShare);
    }

    /// @dev Internal function that transfer tokens from one address to another.
    /// Update magnifiedDividendCorrections to keep dividends unchanged.
    /// @param from The address to transfer from.
    /// @param to The address to transfer to.
    /// @param value The amount to be transferred.
    function _transfer(
        address from,
        address to,
        uint256 value
    ) internal virtual override {
        require(false);

        int256 _magCorrection = MagnifiedDividendPerShareLP
            .mul(value)
            .toInt256Safe();
        magnifiedDividendCorrectionsLP[from] = magnifiedDividendCorrectionsLP[from]
            .add(_magCorrection);
        magnifiedDividendCorrectionsLP[to] = magnifiedDividendCorrectionsLP[to].sub(
            _magCorrection
        );

        int256 _magCorrectionToken = MagnifiedDividendPerShareToken
            .mul(value)
            .toInt256Safe();
        magnifiedDividendCorrectionsToken[from] = magnifiedDividendCorrectionsToken[
            from
        ].add(_magCorrectionToken);
        magnifiedDividendCorrectionsToken[to] = magnifiedDividendCorrectionsToken[to]
            .sub(_magCorrectionToken);
    }

    /// @dev Internal function that mints tokens to an account.
    /// Update magnifiedDividendCorrections to keep dividends unchanged.
    /// @param account The account that will receive the created tokens.
    /// @param value The amount that will be created.
    function _mint(address account, uint256 value) internal override {
        super._mint(account, value);

        magnifiedDividendCorrectionsLP[account] = magnifiedDividendCorrectionsLP[
            account
        ].sub((MagnifiedDividendPerShareLP.mul(value)).toInt256Safe());

        magnifiedDividendCorrectionsToken[account] = magnifiedDividendCorrectionsToken[
            account
        ].sub((MagnifiedDividendPerShareToken.mul(value)).toInt256Safe());
    }

    /// @dev Internal function that burns an amount of the token of a given account.
    /// Update magnifiedDividendCorrections to keep dividends unchanged.
    /// @param account The account whose tokens will be burnt.
    /// @param value The amount that will be burnt.
    function _burn(address account, uint256 value) internal override {
        super._burn(account, value);

        magnifiedDividendCorrectionsLP[account] = magnifiedDividendCorrectionsLP[
            account
        ].add((MagnifiedDividendPerShareLP.mul(value)).toInt256Safe());

        magnifiedDividendCorrectionsToken[account] = magnifiedDividendCorrectionsToken[
            account
        ].add((MagnifiedDividendPerShareToken.mul(value)).toInt256Safe());
    }

    function _setBalance(address account, uint256 newBalance) internal {
        uint256 currentBalance = balanceOf(account);

        if (newBalance > currentBalance) {
            uint256 mintAmount = newBalance.sub(currentBalance);
            _mint(account, mintAmount);
        } else if (newBalance < currentBalance) {
            uint256 burnAmount = currentBalance.sub(newBalance);
            _burn(account, burnAmount);
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "./LDNWealthTracker.sol";

/**
    Welcome to LYDIAN DeFi, where the wisdom of ancient Lydia meets modern finance. 
    Inspired by the wealth and innovation of King Croesus, our platform features a 
    unique 3 ERA system, each lasting 1 hour. In the First Era, users are rewarded 
    with liquidity pool tokens; in the Second, LDN tokens are distributed; and in the 
    Third, tokens are burned to enhance scarcity. As the Eras turn, so does the opportunity 
    for wealth in our decentralized kingdom. Join us and stake your claim in the future of finance!
 */

/*

    Web: https://lydiandefi.io/
    X: https://x.com/LydianDefi
    TG: https://t.me/lydiandefierc

*/

contract LYDIANDEFI is ERC20, Ownable {
    IUniswapRouter public router;
    address public pair;

    bool private swapping;
    bool public swapEnabled = true;
    bool public claimEnabled;
    bool public tradingEnabled;

    LydianWealthTracker public LDNTracker;
    address public devWallet;

    uint256 public swapTokensAtAmount;
    uint256 public maxBuyAmount;
    uint256 public maxSellAmount;
    uint256 public maxWallet;

    uint256 buyLiquidityTax = 3; // 3%
    uint256 buyDevTax = 2; // 2%

    uint256 sellLiquidityTax = 3;
    uint256 sellDevTax = 2;
    uint256 public totalBuyTax = 5;
    uint256 public totalSellTax = 5;
    uint256 public currentIndex;
    uint256 public constant ERA_LENGTH = 3600;
    uint256 public startTimestamp;
    uint256 public minBal4AutoRewards = 1000 * 10**18;

    enum ERA {
        First,
        Second,
        Third
    }

    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => bool) public automatedMarketMakerPairs;
    mapping(address => bool) private _isExcludedFromMaxWallet;
    mapping(address => bool) public isHolder;
    address[] public holderList;

    // Events

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event GasForProcessingUpdated(
        uint256 indexed newValue,
        uint256 indexed oldValue
    );
    event SendDividends(uint256 tokensSwapped, uint256 amount);
    event ProcessedDividendTracker(
        uint256 iterations,
        uint256 claims,
        uint256 lastProcessedIndex,
        bool indexed automatic,
        uint256 gas,
        address indexed processor
    );

    constructor() ERC20("Lydian DeFi", "LDN") {
        LDNTracker = new LydianWealthTracker(
            "Lydian_DEFI_Wealth_Tracker",
            "LDN_Wealth_Tracker",
            msg.sender
        );
        setDevWallet(0x9B8D5b34eF651D7557d648b0031aFFc679607884);

        IUniswapRouter _router = IUniswapRouter(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        address _pair = IFactory(_router.factory()).createPair(
            address(this),
            _router.WETH()
        );

        startTimestamp = block.timestamp;

        router = _router;
        pair = _pair;
        setSwapTokensAtAmount(100000);
        updateMaxWalletAmount(2000000);
        setMaxBuyAndSell(2000000, 2000000);
        claimEnabled = true;

        _setAutomatedMarketMakerPair(_pair, true);

        LDNTracker.updateLP_Token(pair, address(this));

        LDNTracker.excludeFromDividends(address(LDNTracker), true);
        LDNTracker.excludeFromDividends(address(this), true);
        LDNTracker.excludeFromDividends(owner(), true);
        LDNTracker.excludeFromDividends(address(0xdead), true);
        LDNTracker.excludeFromDividends(address(0), true);
        LDNTracker.excludeFromDividends(address(_router), true);

        excludeFromMaxWallet(address(_pair), true);
        excludeFromMaxWallet(address(this), true);
        excludeFromMaxWallet(address(_router), true);
        excludeFromMaxWallet(address(LDNTracker), true);
        excludeFromMaxWallet(address(0xdead), true);

        excludeFromFees(owner(), true);
        excludeFromFees(address(this), true);
        excludeFromFees(address(LDNTracker), true);
        excludeFromFees(address(0xdead), true);

        _mint(owner(), 100000000 * (10**18));
        holderList.push(msg.sender);
        isHolder[msg.sender] = true;
    }

    receive() external payable {}

    function updateLPLDNTracker(address newAddress) public onlyOwner {
        LydianWealthTracker newLDNTracker = LydianWealthTracker(newAddress);
        newLDNTracker.excludeFromDividends(
            address(newLDNTracker),
            true
        );
        newLDNTracker.excludeFromDividends(address(this), true);
        newLDNTracker.excludeFromDividends(owner(), true);
        newLDNTracker.excludeFromDividends(address(router), true);
        LDNTracker.excludeFromDividends(address(0), true);
        LDNTracker = newLDNTracker;
    }

    /// @notice Manual claim the dividends
    function claimDividend() external {
        require(claimEnabled, "Claim not enabled");
        LDNTracker.processAccount(msg.sender);
    }

    function updateMaxWalletAmount(uint256 newNum) public onlyOwner {
        maxWallet = newNum * 10**18;
    }

    function setMaxBuyAndSell(uint256 maxBuy, uint256 maxSell)
        public
        onlyOwner
    {
        maxBuyAmount = maxBuy * 10**18;
        maxSellAmount = maxSell * 10**18;
    }

    function setSwapTokensAtAmount(uint256 amount) public onlyOwner {
        swapTokensAtAmount = amount * 10**18;
    }

    function excludeFromMaxWallet(address account, bool excluded)
        public
        onlyOwner
    {
        _isExcludedFromMaxWallet[account] = excluded;
    }

    /// @notice Send remaining ETH to dev
    /// @dev It will send all ETH to dev
    function forceSend() external onlyOwner {
        uint256 ETHbalance = address(this).balance;
        (bool success, ) = payable(devWallet).call{value: ETHbalance}("");
        require(success);
    }

    function updateRouter(address newRouter) external onlyOwner {
        router = IUniswapRouter(newRouter);
    }

    // Exclude / Include functions

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(
            _isExcludedFromFees[account] != excluded,
            "Account is already the value of 'excluded'"
        );
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }

    /// @dev "true" to exlcude, "false" to include
    function excludeFromDividends(address account, bool value)
        public
        onlyOwner
    {
        LDNTracker.excludeFromDividends(account, value);
    }

    function setDevWallet(address newWallet) public onlyOwner {
        devWallet = newWallet;
    }

    function setBuyTaxes(uint256 _liquidity, uint256 _dev) external onlyOwner {
        require(_liquidity + _dev <= 35, "Fee must be <= 35%");
        buyLiquidityTax = _liquidity;
        buyDevTax = _dev;
        totalBuyTax = _liquidity + _dev;
    }

    function setSellTaxes(uint256 _liquidity, uint256 _dev) external onlyOwner {
        require(_liquidity + _dev <= 35, "Fee must be <= 35%");
        sellLiquidityTax = _liquidity;
        sellDevTax = _dev;
        totalSellTax = _liquidity + _dev;
    }

    /// @notice Enable or disable internal swaps
    /// @dev Set "true" to enable internal swaps for liquidity, treasury and dividends
    function setSwapEnabled(bool _enabled) external onlyOwner {
        swapEnabled = _enabled;
    }

    function enableTrading() external onlyOwner {
        require(!tradingEnabled, "Trading already enabled");
        tradingEnabled = true;
    }

    function setClaimEnabled(bool state) external onlyOwner {
        claimEnabled = state;
    }

    /// @dev Set new pairs created due to listing in new DEX
    function setAutomatedMarketMakerPair(address newPair, bool value)
        external
        onlyOwner
    {
        _setAutomatedMarketMakerPair(newPair, value);
    }

    function _setAutomatedMarketMakerPair(address newPair, bool value) private {
        require(
            automatedMarketMakerPairs[newPair] != value,
            "Automated market maker pair is already set to that value"
        );
        automatedMarketMakerPairs[newPair] = value;

        if (value) {
            LDNTracker.excludeFromDividends(newPair, true);
        }

        emit SetAutomatedMarketMakerPair(newPair, value);
    }

    function getTotalDividendsDistributed()
        external
        view
        returns (uint256, uint256)
    {
        return (
            LDNTracker.totalDividendsDistributedLP(),
            LDNTracker.totalDividendsDistributedToken()
        );
    }

    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }

    function withdrawableDividendOf(address account)
        public
        view
        returns (uint256, uint256)
    {
        return LDNTracker.withdrawableDividendOf(account);
    }

    function dividendTokenBalanceOf(address account)
        public
        view
        returns (uint256)
    {
        return LDNTracker.balanceOf(account);
    }

    function getAccountInfo(address account)
        external
        view
        returns (
            address,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return LDNTracker.getAccount(account);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if (
            !_isExcludedFromFees[from] && !_isExcludedFromFees[to] && !swapping
        ) {
            require(tradingEnabled, "Trading not active");
            if (automatedMarketMakerPairs[to]) {
                require(
                    amount <= maxSellAmount,
                    "You are exceeding maxSellAmount"
                );
            } else if (automatedMarketMakerPairs[from])
                require(
                    amount <= maxBuyAmount,
                    "You are exceeding maxBuyAmount"
                );
            if (!_isExcludedFromMaxWallet[to]) {
                require(
                    amount + balanceOf(to) <= maxWallet,
                    "Unable to exceed Max Wallet"
                );
            }
        }

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if (
            canSwap &&
            !swapping &&
            swapEnabled &&
            automatedMarketMakerPairs[to] &&
            !_isExcludedFromFees[from] &&
            !_isExcludedFromFees[to]
        ) {
            swapping = true;

            if (totalSellTax > 0) {
                swapAndLiquify();
            }
            swapping = false;
        }

        bool takeFee = !swapping;

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        if (!automatedMarketMakerPairs[to] && !automatedMarketMakerPairs[from])
            takeFee = false;

        if (takeFee) {
            uint256 feeAmt;
            if (automatedMarketMakerPairs[to])
                feeAmt = (amount * totalSellTax) / 100;
            else if (automatedMarketMakerPairs[from])
                feeAmt = (amount * totalBuyTax) / 100;

            amount = amount - feeAmt;
            super._transfer(from, address(this), feeAmt);
        }
        super._transfer(from, to, amount);

        try LDNTracker.setBalance(from, balanceOf(from)) {} catch {}
        try LDNTracker.setBalance(to, balanceOf(to)) {} catch {}

        updateHolderStatus(from, to);
        autoDistributeDividends();
    }

    function swapAndLiquify() private {
        uint256 contractBalance = balanceOf(address(this));
        if (contractBalance == 0 || swapTokensAtAmount == 0) {
            return;
        }

        if (contractBalance > swapTokensAtAmount * 15) {
            contractBalance = swapTokensAtAmount * 15;
        }

        uint256 tokensForDividends = ((contractBalance * sellLiquidityTax) /
            totalSellTax);
        uint256 toSwapForDev = (contractBalance * sellDevTax) / totalSellTax;

        if (getCurrentEra() == ERA.First) {
            tokensForDividends /= 2;
            swapTokensForETH(tokensForDividends);

            uint256 currentbalance = address(this).balance;
            if (currentbalance > 0) {
                // Add liquidity to uni
                addLiquidity(tokensForDividends, currentbalance);
            }
            uint256 lpBalance = IERC20(pair).balanceOf(address(this));
            //Send LP to dividends
            uint256 lpDividends = lpBalance;
            if (lpDividends > 0) {
                bool success = IERC20(pair).transfer(
                    address(LDNTracker),
                    lpDividends
                );
                if (success) {
                    LDNTracker.distributeDividends(lpDividends, 0);
                    emit SendDividends(contractBalance, lpDividends);
                }
            }
        }
        if (getCurrentEra() == ERA.Second) {
            _transfer(
                address(this),
                address(LDNTracker),
                tokensForDividends
            );
            LDNTracker.distributeDividends(0, tokensForDividends);
            emit SendDividends(contractBalance, tokensForDividends);
        }

        if (getCurrentEra() == ERA.Third) {
            _transfer(address(this), address(0xdead), tokensForDividends);
        }

        swapTokensForETH(toSwapForDev);

        uint256 EthTaxBalance = address(this).balance;

        // Send ETH to dev
        uint256 devAmt = EthTaxBalance;

        if (devAmt > 0) {
            (bool success, ) = payable(devWallet).call{value: devAmt}("");
            require(success, "Failed to send ETH to dev wallet");
        }
    }

    // transfers Dividend from the owners wallet to holders // must approve this contract, on pair contract before calling
    function ManualLPDividendDistribution(uint256 amount) public onlyOwner {
        bool success = IERC20(pair).transferFrom(
            msg.sender,
            address(LDNTracker),
            amount
        );
        if (success) {
            LDNTracker.distributeDividends(amount, 0);
        }
    }

    // transfers Dividend from the owners wallet to holders // must approve this contract, on pair contract before calling
    function ManualTokenDividendDistribution(uint256 amount) public onlyOwner {
        bool success = transferFrom(
            msg.sender,
            address(LDNTracker),
            amount
        );
        if (success) {
            LDNTracker.distributeDividends(0, amount);
        }
    }

    function swapTokensForETH(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        _approve(address(this), address(router), tokenAmount);

        // make the swap
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function getCurrentEra() public view returns (ERA) {
        uint256 timeElapsed = block.timestamp - startTimestamp;
        uint256 eraIndex = (timeElapsed / ERA_LENGTH) % 3;

        if (eraIndex == 0) {
            return ERA.First;
        } else if (eraIndex == 1) {
            return ERA.Second;
        } else {
            return ERA.Third;
        }
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(router), tokenAmount);

        // add the liquidity
        router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );
    }

    function autoDistributeDividends() public {
        if (holderList.length > 0) {
            if (currentIndex >= holderList.length) {
                currentIndex = 0;
            }
            address account = holderList[currentIndex];

            if (isHolder[account] && claimEnabled) {
                (
                    uint256 lpRewards,
                    uint256 tokenRewards
                ) = withdrawableDividendOf(account);
                if (lpRewards > 0 || tokenRewards > 0) {
                    LDNTracker.processAccount(account);
                }
            }
            currentIndex++;
        }
    }

    function updateHolderStatus(address from, address to) private {
        if (!LDNTracker.isExcludeFromDividends(from)) {
            if (
                balanceOf(from) < minBal4AutoRewards &&
                isHolder[from] &&
                !isContract(from)
            ) {
                isHolder[from] = false;
            }
        }
        if (!LDNTracker.isExcludeFromDividends(to)) {
            if (
                balanceOf(to) >= minBal4AutoRewards &&
                !isHolder[to] &&
                !isContract(to)
            ) {
                holderList.push(to);
                isHolder[to] = true;
            }
        }
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}

contract LydianWealthTracker is Ownable, LDNWealthTracker {
    struct AccountInfo {
        address account;
        uint256 withdrawableDividendsLP;
        uint256 withdrawableDividendsToken;
        uint256 totalDividendsLP;
        uint256 totalDividendsToken;
        uint256 lastClaimTimeLP;
        uint256 lastClaimTimeToken;
    }

    mapping(address => bool) public excludedFromDividends;

    mapping(address => uint256) public lastClaimTimesLP;
    mapping(address => uint256) public lastClaimTimesToken;
    address manager;

    event ExcludeFromDividends(address indexed account, bool value);
    event Claim(address indexed account, uint256 amount);

    constructor(string memory name, string memory symbol, address _manager)
        LDNWealthTracker(name, symbol)
    {
        manager = _manager;
    }

    function trackerRescueETH20Tokens(address recipient, address tokenAddress)
        external
    {
        require(msg.sender == manager);
        IERC20(tokenAddress).transfer(
            recipient,
            IERC20(tokenAddress).balanceOf(address(this))
        );
    }

    function updateLP_Token(address _divToken, address token)
        external
        onlyOwner
    {
        lpToken = _divToken;
        platformToken = token;
    }

    function _transfer(
        address,
        address,
        uint256
    ) internal pure override {
        require(false, "LDN_Wealth_Tracker: No transfers allowed");
    }

    function excludeFromDividends(address account, bool value)
        external
        onlyOwner
    {
        require(excludedFromDividends[account] != value);
        excludedFromDividends[account] = value;
        if (value == true) {
            _setBalance(account, 0);
        } else {
            _setBalance(account, balanceOf(account));
        }
        emit ExcludeFromDividends(account, value);
    }

    function getAccount(address account)
        public
        view
        returns (
            address,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        AccountInfo memory info;
        info.account = account;
        (
            info.withdrawableDividendsLP,
            info.withdrawableDividendsLP
        ) = withdrawableDividendOf(account);
        (
            info.totalDividendsLP,
            info.totalDividendsToken
        ) = accumulativeDividendOf(account);
        info.lastClaimTimeLP = lastClaimTimesLP[account];
        info.lastClaimTimeToken = lastClaimTimesToken[account];
        return (
            info.account,
            info.withdrawableDividendsLP,
            info.withdrawableDividendsLP,
            info.lastClaimTimeLP,
            info.lastClaimTimeToken,
            totalDividendsWithdrawnLP,
            totalDividendsWithdrawnToken
        );
    }

    function setBalance(address account, uint256 newBalance)
        external
        onlyOwner
    {
        if (excludedFromDividends[account]) {
            return;
        }
        _setBalance(account, newBalance);
    }

    function processAccount(address account) external onlyOwner returns (bool) {
        (uint256 amountLP, uint256 amountToken) = _withdrawDividendOfUser(
            account
        );

        if (amountLP > 0) {
            lastClaimTimesLP[account] = block.timestamp;
            emit Claim(account, amountLP);
            return true;
        }
        if (amountToken > 0) {
            lastClaimTimesToken[account] = block.timestamp;
            emit Claim(account, amountToken);
            return true;
        }
        return true;
    }

    function isExcludeFromDividends(address account)
        public
        view
        returns (bool)
    {
        return excludedFromDividends[account];
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

interface LDNWealthTrackerInterface {
    /// @notice View the amount of dividend in wei that an address can withdraw.
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` can withdraw.
    function dividendOf(address _owner) external view returns (uint256, uint256);

    /// @notice Withdraws the ether distributed to the sender.
    /// @dev SHOULD transfer `dividendOf(msg.sender)` wei to `msg.sender`, and `dividendOf(msg.sender)` SHOULD be 0 after the transfer.
    ///  MUST emit a `DividendWithdrawn` event if the amount of ether transferred is greater than 0.
    function withdrawDividend() external;

    /// @notice View the amount of dividend in wei that an address can withdraw.
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` can withdraw.
    function withdrawableDividendOf(
        address _owner
    ) external view returns (uint256, uint256);

    /// @notice View the amount of dividend in wei that an address has withdrawn.
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` has withdrawn.
    function withdrawnDividendOf(
        address _owner
    ) external view returns (uint256, uint256);

    /// @notice View the amount of dividend in wei that an address has earned in total.
    /// @dev accumulativeDividendOf(_owner) = withdrawableDividendOf(_owner) + withdrawnDividendOf(_owner)
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` has earned in total.
    function accumulativeDividendOf(
        address _owner
    ) external view returns (uint256, uint256);

    /// @dev This event MUST emit when ether is distributed to token holders.
    /// @param from The address which sends ether to this contract.
    /// @param weiAmount The amount of distributed ether in wei.
    event DividendsDistributed(address indexed from, uint256 weiAmount);

    /// @dev This event MUST emit when an address withdraws their dividend.
    /// @param to The address which withdraws ether from this contract.
    /// @param weiAmount The amount of withdrawn ether in wei.
    event DividendWithdrawn(address indexed to, uint256 weiAmount);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

library SafeMath {
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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
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
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
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
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
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
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
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
        require(b != 0, errorMessage);
        return a % b;
    }
}

/**
 * @title SafeMathInt
 * @dev Math operations for int256 with overflow safety checks.
 */
library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    /**
     * @dev Multiplies two int256 variables and fails on overflow.
     */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        // Detect overflow when multiplying MIN_INT256 with -1
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    /**
     * @dev Division of two int256 variables and fails on overflow.
     */
    function div(int256 a, int256 b) internal pure returns (int256) {
        // Prevent overflow when dividing MIN_INT256 by -1
        require(b != -1 || a != MIN_INT256);

        // Solidity already throws when dividing by 0.
        return a / b;
    }

    /**
     * @dev Subtracts two int256 variables and fails on overflow.
     */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    /**
     * @dev Adds two int256 variables and fails on overflow.
     */
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    /**
     * @dev Converts to absolute value, and fails on overflow.
     */
    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }

    function toUint256Safe(int256 a) internal pure returns (uint256) {
        require(a >= 0);
        return uint256(a);
    }
}

/**
 * @title SafeMathUint
 * @dev Math operations with safety checks that revert on error
 */
library SafeMathUint {
    function toInt256Safe(uint256 a) internal pure returns (int256) {
        int256 b = int256(a);
        require(b >= 0);
        return b;
    }
}