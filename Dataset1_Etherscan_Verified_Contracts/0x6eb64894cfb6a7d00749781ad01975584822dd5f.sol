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
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title The Wally Group Token
 * @dev ERC20 token with vesting, transaction limits, and tax mechanisms
 */
contract TWGToken is ERC20, Ownable {
    // Constants
    uint256 public constant TOTAL_SUPPLY = 10_000_000_000 * 10**18; // 10 billion tokens
    uint256 public constant MAX_TX_AMOUNT = 150_000_000 * 10**18;   // 1.5% of total supply
    uint256 public constant MIN_TX_AMOUNT = 1_000 * 10**18;         // 1,000 tokens
    uint256 public constant SELL_TAX_RATE = 30;                     // 30% sell tax initially
    
    // Time constants
    uint256 public constant TAX_DURATION = 24 hours;
    
    // State variables
    uint256 public tradingEnabledTimestamp;
    bool public tradingEnabled;
    address public taxCollector;
    mapping(address => bool) public isExcludedFromTax;
    mapping(address => bool) public isExcludedFromTxLimits;
    
    // Vesting related variables
    mapping(address => uint256) public vestedAmount;
    mapping(address => uint256) public vestingEndTime;
    mapping(address => uint256) public vestingStartTime;
    
    // Uniswap variables
    address public uniswapV2Pair;
    address public uniswapV2Router;
    
    // Events
    event TradingEnabled(uint256 timestamp);
    event AddedToTaxExclusion(address indexed account);
    event RemovedFromTaxExclusion(address indexed account);
    event AddedToTxLimitsExclusion(address indexed account);
    event RemovedFromTxLimitsExclusion(address indexed account);
    event TaxCollectorUpdated(address indexed newTaxCollector);
    event TokensVested(address indexed beneficiary, uint256 amount, uint256 endTime);
    event TokensReleased(address indexed beneficiary, uint256 amount);
    event LiquidityAdded(uint256 tokenAmount, uint256 ethAmount);

    /**
     * @dev Constructor to initialize the token
     * @param _taxCollector Address where collected taxes will be sent
     */
    constructor(address _taxCollector) ERC20("The Wally Group Token", "TWG") Ownable() {
        require(_taxCollector != address(0), "Tax collector cannot be zero address");
        taxCollector = _taxCollector;
        
        // Mint total supply to contract itself for distribution
        _mint(address(this), TOTAL_SUPPLY);
        
        // Exclude owner and contract from tax
        isExcludedFromTax[owner()] = true;
        isExcludedFromTax[address(this)] = true;
        isExcludedFromTax[_taxCollector] = true;
        
        // Exclude from transaction limits
        isExcludedFromTxLimits[owner()] = true;
        isExcludedFromTxLimits[address(this)] = true;
        isExcludedFromTxLimits[_taxCollector] = true;
    }
    
    /**
     * @dev Transfer override to check restrictions and apply tax
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        // Apply transaction limits if not excluded
        if (!isExcludedFromTxLimits[from] && !isExcludedFromTxLimits[to]) {
            require(amount >= MIN_TX_AMOUNT, "Transfer amount below minimum");
            require(amount <= MAX_TX_AMOUNT, "Transfer amount exceeds maximum");
        }
        
        // Check trading status
        if (!tradingEnabled) {
            require(
                isExcludedFromTxLimits[from] || isExcludedFromTxLimits[to],
                "Trading not yet enabled"
            );
        }
        
        // Apply sell tax if applicable
        if (
            to == uniswapV2Pair && // Sell to the pair
            tradingEnabled &&
            block.timestamp <= (tradingEnabledTimestamp + TAX_DURATION) && // Within tax period
            !isExcludedFromTax[from] // Not excluded from tax
        ) {
            uint256 taxAmount = (amount * SELL_TAX_RATE) / 100;
            uint256 transferAmount = amount - taxAmount;
            
            super._transfer(from, taxCollector, taxAmount);
            super._transfer(from, to, transferAmount);
        } else {
            super._transfer(from, to, amount);
        }
    }
    
    /**
     * @dev Calculate available vested tokens for an address
     * @param beneficiary Address to check vested tokens for
     * @return The amount of available vested tokens
     */
    function calculateAvailableVested(address beneficiary) public view returns (uint256) {
        if (block.timestamp < vestingStartTime[beneficiary]) {
            return 0;
        }
        
        if (block.timestamp >= vestingEndTime[beneficiary]) {
            return vestedAmount[beneficiary];
        }
        
        // Calculate linear vesting amount
        uint256 totalVestingDuration = vestingEndTime[beneficiary] - vestingStartTime[beneficiary];
        uint256 elapsedTime = block.timestamp - vestingStartTime[beneficiary];
        
        return (vestedAmount[beneficiary] * elapsedTime) / totalVestingDuration;
    }
    
    /**
     * @dev Release vested tokens to a beneficiary
     * @param beneficiary Address to release tokens to
     * @return The amount of tokens released
     */
    function releaseVestedTokens(address beneficiary) external returns (uint256) {
        uint256 available = calculateAvailableVested(beneficiary);
        require(available > 0, "No tokens available for release");
        
        // Update vested amount
        vestedAmount[beneficiary] = 0;
        
        // Transfer tokens to beneficiary
        _transfer(address(this), beneficiary, available);
        
        emit TokensReleased(beneficiary, available);
        return available;
    }
    
    /**
     * @dev Create a vesting schedule for a beneficiary
     * @param beneficiary Address to vest tokens for
     * @param amount Amount of tokens to vest
     * @param durationInDays Vesting duration in days
     */
    function createVesting(
        address beneficiary,
        uint256 amount,
        uint256 durationInDays
    ) external onlyOwner {
        require(beneficiary != address(0), "Beneficiary cannot be zero address");
        require(amount > 0, "Vesting amount must be greater than zero");
        require(durationInDays > 0, "Vesting duration must be greater than zero");
        
        // Set vesting details
        vestedAmount[beneficiary] = amount;
        vestingStartTime[beneficiary] = block.timestamp;
        vestingEndTime[beneficiary] = block.timestamp + (durationInDays * 1 days);
        
        emit TokensVested(beneficiary, amount, vestingEndTime[beneficiary]);
    }
    
    /**
     * @dev Enable trading and start the tax period
     */
    function enableTrading() external onlyOwner {
        require(!tradingEnabled, "Trading already enabled");
        tradingEnabled = true;
        tradingEnabledTimestamp = block.timestamp;
        emit TradingEnabled(tradingEnabledTimestamp);
    }
    
    /**
     * @dev Set tax collector address
     * @param _taxCollector New tax collector address
     */
    function setTaxCollector(address _taxCollector) external onlyOwner {
        require(_taxCollector != address(0), "Tax collector cannot be zero address");
        taxCollector = _taxCollector;
        isExcludedFromTax[_taxCollector] = true;
        isExcludedFromTxLimits[_taxCollector] = true;
        emit TaxCollectorUpdated(_taxCollector);
    }
    
    /**
     * @dev Add an address to tax exclusion list
     * @param account Address to exclude from tax
     */
    function excludeFromTax(address account) external onlyOwner {
        require(!isExcludedFromTax[account], "Account already excluded from tax");
        isExcludedFromTax[account] = true;
        emit AddedToTaxExclusion(account);
    }
    
    /**
     * @dev Remove an address from tax exclusion list
     * @param account Address to include in tax
     */
    function includeInTax(address account) external onlyOwner {
        require(isExcludedFromTax[account], "Account already included in tax");
        isExcludedFromTax[account] = false;
        emit RemovedFromTaxExclusion(account);
    }
    
    /**
     * @dev Add an address to transaction limits exclusion list
     * @param account Address to exclude from transaction limits
     */
    function excludeFromTxLimits(address account) external onlyOwner {
        require(!isExcludedFromTxLimits[account], "Account already excluded from limits");
        isExcludedFromTxLimits[account] = true;
        emit AddedToTxLimitsExclusion(account);
    }
    
    /**
     * @dev Remove an address from transaction limits exclusion list
     * @param account Address to include in transaction limits
     */
    function includeInTxLimits(address account) external onlyOwner {
        require(isExcludedFromTxLimits[account], "Account already included in limits");
        isExcludedFromTxLimits[account] = false;
        emit RemovedFromTxLimitsExclusion(account);
    }
    
    /**
     * @dev Add liquidity to Uniswap
     * @param tokenAmount Amount of tokens to add to liquidity
     */
    function addLiquidity(uint256 tokenAmount, address _uniswapRouter) external payable onlyOwner {
        require(tokenAmount > 0, "Token amount must be greater than zero");
        require(msg.value > 0, "ETH amount must be greater than zero");
        require(uniswapV2Pair == address(0), "Liquidity already added");
        require(_uniswapRouter != address(0), "Router cannot be zero address");
        
        uniswapV2Router = _uniswapRouter;
        
        // Created via interface to avoid direct dependency
        // Interface of IERC20 transfer and approve functions
        (bool success,) = address(this).call(
            abi.encodeWithSignature(
                "approve(address,uint256)", 
                _uniswapRouter, 
                tokenAmount
            )
        );
        require(success, "Approve failed");
        
        // Add liquidity - minimal interface interaction to avoid dependencies
        (bool addSuccess,) = _uniswapRouter.call{value: msg.value}(
            abi.encodeWithSignature(
                "addLiquidityETH(address,uint256,uint256,uint256,address,uint256)", 
                address(this), 
                tokenAmount,
                0,
                0,
                owner(),
                block.timestamp + 300
            )
        );
        require(addSuccess, "Add liquidity failed");
        
        // Get pair address from factory - minimal interface interaction
        (bool getPairSuccess, bytes memory data) = _uniswapRouter.call(
            abi.encodeWithSignature("factory()")
        );
        require(getPairSuccess, "Get factory failed");
        
        address factory = abi.decode(data, (address));
        
        (bool getPairSuccess2, bytes memory data2) = factory.call(
            abi.encodeWithSignature(
                "getPair(address,address)", 
                address(this),
                address(0) // WETH - placeholder, real implementation would get from router
            )
        );
        require(getPairSuccess2, "Get pair failed");
        
        uniswapV2Pair = abi.decode(data2, (address));
        
        emit LiquidityAdded(tokenAmount, msg.value);
    }
    
    /**
     * @dev Distribute tokens to multiple addresses
     * @param addresses Array of recipient addresses
     * @param amounts Array of token amounts
     */
    function distributeTokens(
        address[] calldata addresses,
        uint256[] calldata amounts
    ) external onlyOwner {
        require(addresses.length == amounts.length, "Arrays must have same length");
        require(addresses.length > 0, "Must distribute to at least one address");
        
        for (uint256 i = 0; i < addresses.length; i++) {
            require(addresses[i] != address(0), "Cannot distribute to zero address");
            require(amounts[i] > 0, "Amount must be greater than zero");
            
            _transfer(address(this), addresses[i], amounts[i]);
        }
    }
    
    /**
     * @dev Emergency token recovery function
     * @param tokenAddress Address of token to recover
     * @param tokenAmount Amount of tokens to recover
     */
    function recoverTokens(
        address tokenAddress,
        uint256 tokenAmount
    ) external onlyOwner {
        require(tokenAddress != address(this), "Cannot recover TWG tokens");
        
        // Created via interface to avoid direct dependency
        // Interface of IERC20 transfer function
        (bool success,) = tokenAddress.call(
            abi.encodeWithSignature(
                "transfer(address,uint256)", 
                owner(), 
                tokenAmount
            )
        );
        require(success, "Transfer failed");
    }
}