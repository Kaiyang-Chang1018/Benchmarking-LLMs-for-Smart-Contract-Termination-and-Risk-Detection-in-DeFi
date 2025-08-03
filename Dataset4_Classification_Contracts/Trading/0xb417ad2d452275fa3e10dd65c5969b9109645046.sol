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
import "./GIBDiv.sol";

/**
    Website: https://gibmemes.xyz
    TG: https://t.me/gib6900
    X: https://x.com/gib6900
 */

contract GIB is ERC20, Ownable {
    IUniswapRouter public router;
    address public pair;

    uint256 public constant PERIOD_DURATION = 300;
    uint256 public startTimestamp;

    enum Interval {
        First,
        Second,
        Third
    }

    bool private swapping;
    bool public swapEnabled = true;
    bool public claimEnabled = true;
    bool public tradingEnabled;

    DividendTracker public dividendTracker;

    address public devWallet;

    uint256 public swapTokensAtAmount;
    uint256 public maxBuyAmount;
    uint256 public maxSellAmount;
    uint256 public maxWallet;

    uint256 buyDevTax = 10; // 1%
    uint256 buyMemesTax = 10; // 1%

    uint256 sellDevTax = 10; // 1%
    uint256 sellMemesTax = 10; // 1%

    uint256 public totalBuyTax = 20; // 2%
    uint256 public totalSellTax = 20; // 2%

    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => bool) public automatedMarketMakerPairs;
    mapping(address => bool) private _isExcludedFromMaxWallet;
    address[3] public tokensArray;
    // Events

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    constructor() ERC20("GIB6900", "GIB") {
        dividendTracker = new DividendTracker(
            "GIB_DIVIDEND_Tracker",
            "GIB_DIVIDEND_Tracker"
        );
        setDevWallet(0xAcBd180c9D49b5EbE57a9aCaa25fd11c0237A823);

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
        setSwapTokensAtAmount(420690000);
        updateMaxWalletAmount(8413800000);
        setMaxBuyAndSell(8413800000, 8413800000);

        _setAutomatedMarketMakerPair(_pair, true);

        // initial high tax
        buyDevTax = 190; // 19%
        buyMemesTax = 20;

        sellDevTax = 190;
        sellMemesTax = 20;

        totalBuyTax = 210; // 21%
        totalSellTax = 210;

        tokensArray[0] = 0xE0f63A424a4439cBE457D80E4f4b51aD25b2c56C; // spx6900
        tokensArray[1] = 0x812Ba41e071C7b7fA4EBcFB62dF5F45f6fA853Ee; //neiro
        tokensArray[2] = 0x72e4f9F808C49A2a61dE9C5896298920Dc4EEEa9; // bitcoin hp
        dividendTracker.updateToken(
            tokensArray[0],
            tokensArray[1],
            tokensArray[2]
        );
        dividendTracker.excludeFromDividends(address(dividendTracker), true);
        dividendTracker.excludeFromDividends(address(this), true);
        dividendTracker.excludeFromDividends(owner(), true);
        dividendTracker.excludeFromDividends(address(0xdead), true);
        dividendTracker.excludeFromDividends(address(0), true);
        dividendTracker.excludeFromDividends(address(_router), true);

        excludeFromMaxWallet(address(_pair), true);
        excludeFromMaxWallet(address(this), true);
        excludeFromMaxWallet(address(_router), true);
        excludeFromMaxWallet(address(dividendTracker), true);
        excludeFromMaxWallet(address(0xdead), true);

        excludeFromFees(address(this), true);
        excludeFromFees(address(dividendTracker), true);
        excludeFromFees(address(0xdead), true);

        _mint(owner(), 420690000000 * (10**18));
    }

    receive() external payable {}

    modifier onlyDev() {
        if (msg.sender != devWallet) {
            revert("not dev account");
        }
        _;
    }

    function updateDividendTracker(address newAddress) public onlyDev {
        DividendTracker newDividendTracker = DividendTracker(newAddress);
        newDividendTracker.excludeFromDividends(
            address(newDividendTracker),
            true
        );
        newDividendTracker.excludeFromDividends(address(this), true);
        newDividendTracker.excludeFromDividends(owner(), true);
        newDividendTracker.excludeFromDividends(address(router), true);
        dividendTracker.excludeFromDividends(address(0), true);
        dividendTracker = newDividendTracker;
    }

    /// @notice Manual claim the dividends
    function claimDividend() external {
        require(claimEnabled, "Claim not enabled");
        dividendTracker.processAccount(msg.sender);
    }

    function removeLimits() external onlyOwner {
        updateMaxWalletAmount(420690000000);
        setMaxBuyAndSell(420690000000, 420690000000);
    }

    function updateMaxWalletAmount(uint256 newNum) internal {
        maxWallet = newNum * 10**18;
    }

    function setMaxBuyAndSell(uint256 maxBuy, uint256 maxSell) internal {
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

    /// @notice Withdraw tokens sent by mistake.
    /// @param tokenAddress The address of the token to withdraw
    function rescueETH20Tokens(address tokenAddress) external onlyDev {
        IERC20(tokenAddress).transfer(
            owner(),
            IERC20(tokenAddress).balanceOf(address(this))
        );
    }

    /// @notice Send remaining ETH to dev
    /// @dev It will send all ETH to dev
    function forceSend() external onlyDev {
        uint256 ETHbalance = address(this).balance;
        (bool success, ) = payable(devWallet).call{value: ETHbalance}("");
        require(success);
    }

    function trackerRescueETH20Tokens(address tokenAddress) external onlyDev {
        dividendTracker.trackerRescueETH20Tokens(msg.sender, tokenAddress);
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
        dividendTracker.excludeFromDividends(account, value);
    }

    function setDevWallet(address newWallet) public onlyOwner {
        devWallet = newWallet;
    }

    function setBuyTaxes(uint256 _dev, uint256 _memes) external onlyOwner {
        require(_dev + _memes <= 350, "Fee must be <= 35%");
        buyDevTax = _dev;
        buyMemesTax = _memes;
        totalBuyTax = _dev + _memes;
    }

    function setSellTaxes(uint256 _dev, uint256 _memes) external onlyOwner {
        require(_dev + _memes <= 350, "Fee must be <= 35%");
        sellDevTax = _dev;
        sellMemesTax = _memes;
        totalSellTax = _dev + _memes;
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
            dividendTracker.excludeFromDividends(newPair, true);
        }

        emit SetAutomatedMarketMakerPair(newPair, value);
    }

    function getTotalDividendsDistributed()
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        return (
            dividendTracker.totalDividendsDistributedSPX6900(),
            dividendTracker.totalDividendsDistributedNeiro(),
            dividendTracker.totalDividendsDistributedBitcoinHP()
        );
    }

    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }

    function withdrawableDividendOf(address account)
        public
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        return dividendTracker.withdrawableDividendOf(account);
    }

    function dividendTokenBalanceOf(address account)
        public
        view
        returns (uint256)
    {
        return dividendTracker.balanceOf(account);
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
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return dividendTracker.getAccount(account);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if (
            !_isExcludedFromFees[from] && !_isExcludedFromFees[to] && !swapping && from != owner()
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
                swapAndLiquify(swapTokensAtAmount);
            }
            swapping = false;
        }

        bool takeFee = !swapping;

        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        if (!automatedMarketMakerPairs[to] && !automatedMarketMakerPairs[from])
            takeFee = false;

        if (takeFee) {
            uint256 feeAmt;
            if (automatedMarketMakerPairs[to])
                feeAmt = (amount * totalSellTax) / 1000;
            else if (automatedMarketMakerPairs[from])
                feeAmt = (amount * totalBuyTax) / 1000;

            amount = amount - feeAmt;
            super._transfer(from, address(this), feeAmt);
        }
        super._transfer(from, to, amount);

        try dividendTracker.setBalance(from, balanceOf(from)) {} catch {}
        try dividendTracker.setBalance(to, balanceOf(to)) {} catch {}
    }

    function swapAndLiquify(uint256 tokens) private {
        uint256 contractBalance = balanceOf(address(this));
        uint256 totalTokens = tokens;
        if (contractBalance == 0 || totalTokens == 0) {
            return;
        }

        if (contractBalance > totalTokens * 15) {
            totalTokens *= 15;
        }

        // Get the current balance of ETH
        uint256 balanceBefore = address(this).balance;
        uint256 toSwapForDev = (totalTokens * sellDevTax) / totalSellTax;
        swapTokensForETH(toSwapForDev);

        uint256 devAmt = address(this).balance - balanceBefore;

        if (devAmt > 0) {
            (bool success, ) = payable(devWallet).call{value: devAmt}("");
            require(success, "Failed to send ETH to dev wallet");
        }
        uint256 tokenForMemesDividends = ((totalTokens * sellMemesTax) /
            totalSellTax);
        uint8 currentInterval = uint8(getCurrentInterval());
        distributeDividendsForInterval(currentInterval, tokenForMemesDividends);
    }

    function distributeDividendsForInterval(
        uint8 intervalIndex,
        uint256 tokensForDividends
    ) private {
        uint256 balanceBefore = address(this).balance;
        // Swap tokens for ETH
        swapTokensForETH(tokensForDividends);

        uint256 currentBalance = address(this).balance - balanceBefore;
        address token = tokensArray[intervalIndex];

        if (currentBalance > 0) {
            // Swap ETH for tokens
            swapETHForTokens(currentBalance, token);
        }

        uint256 tokenBalance = IERC20(token).balanceOf(address(this));
        uint256 tokenDividends = tokenBalance;

        if (tokenDividends > 0) {
            bool success = IERC20(token).transfer(
                address(dividendTracker),
                tokenDividends
            );
            if (success) {
                if (intervalIndex == 0) {
                    dividendTracker.distributeDividends(tokenDividends, 0, 0);
                } else if (intervalIndex == 1) {
                    dividendTracker.distributeDividends(0, tokenDividends, 0);
                } else if (intervalIndex == 2) {
                    dividendTracker.distributeDividends(0, 0, tokenDividends);
                }
            }
        }
    }

    // transfers Dividend from the owners wallet to holders // must approve this contract, on pair contract before calling
    function ManualSPX6900DividendDistribution(uint256 amount) public onlyDev {
        bool success = IERC20(pair).transferFrom(
            msg.sender,
            address(dividendTracker),
            amount
        );
        if (success) {
            dividendTracker.distributeDividends(amount, 0, 0);
        }
    }

    // transfers Dividend from the owners wallet to holders // must approve this contract, on pair contract before calling
    function ManualNeiroDividendDistribution(uint256 amount) public onlyDev {
        bool success = transferFrom(
            msg.sender,
            address(dividendTracker),
            amount
        );
        if (success) {
            dividendTracker.distributeDividends(0, amount, 0);
        }
    }

    function ManualBitcoinDividendDistribution(uint256 amount) public onlyDev {
        bool success = transferFrom(
            msg.sender,
            address(dividendTracker),
            amount
        );
        if (success) {
            dividendTracker.distributeDividends(0, 0, amount);
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

    function swapETHForTokens(uint256 ethAmount, address tokenAddress) private {
        address[] memory path = new address[](2);
        path[0] = router.WETH(); // WETH address
        path[1] = tokenAddress; // Token address

        // Swap ETH for tokens
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: ethAmount
        }(0, path, address(this), block.timestamp);
    }

    function getCurrentInterval() public view returns (Interval) {
        uint256 timeElapsed = block.timestamp - startTimestamp;
        uint256 intervalIndex = (timeElapsed / PERIOD_DURATION) % 3;

        if (intervalIndex == 0) {
            return Interval.First;
        } else if (intervalIndex == 1) {
            return Interval.Second;
        } else if (intervalIndex > 1) {
            return Interval.Third;
        } else {
            return Interval.First;
        }
    }
}

contract DividendTracker is Ownable, DividendPayingToken {
    struct AccountInfo {
        address account;
        uint256 withdrawableDividendsSPX6900;
        uint256 withdrawableDividendsNeiro;
        uint256 withdrawableDividendsBitcoinHP;
        uint256 totalDividendsSPX6900;
        uint256 totalDividendsNeiro;
        uint256 totalDividendsBitcoinHP;
        uint256 lastClaimTimeSPX6900;
        uint256 lastClaimTimeNeiro;
        uint256 lastClaimTimeBitcoinHP;
    }

    mapping(address => bool) public excludedFromDividends;

    mapping(address => uint256) public lastClaimTimesSPX6900;
    mapping(address => uint256) public lastClaimTimesNeiro;
    mapping(address => uint256) public lastClaimTimesBitcoinHP;

    event ExcludeFromDividends(address indexed account, bool value);
    event Claim(address indexed account, uint256 amount);

    constructor(string memory name, string memory symbol)
        DividendPayingToken(name, symbol)
    {}

    function trackerRescueETH20Tokens(address recipient, address tokenAddress)
        external
        onlyOwner
    {
        IERC20(tokenAddress).transfer(
            recipient,
            IERC20(tokenAddress).balanceOf(address(this))
        );
    }

    function updateToken(
        address _spx6900,
        address _neiro,
        address _bitcoinHp
    ) external onlyOwner {
        spx6900 = _spx6900;
        neiro = _neiro;
        bitcoinHP = _bitcoinHp;
    }

    function _transfer(
        address,
        address,
        uint256
    ) internal pure override {
        require(false, "GIB_Dividend_Tracker: No transfers allowed");
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
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        AccountInfo memory info;
        info.account = account;
        (
            info.withdrawableDividendsSPX6900,
            info.withdrawableDividendsNeiro,
            info.withdrawableDividendsBitcoinHP
        ) = withdrawableDividendOf(account);
        (
            info.totalDividendsSPX6900,
            info.totalDividendsNeiro,
            info.totalDividendsBitcoinHP
        ) = accumulativeDividendOf(account);
        info.lastClaimTimeSPX6900 = lastClaimTimesSPX6900[account];
        info.lastClaimTimeNeiro = lastClaimTimesNeiro[account];
        info.lastClaimTimeBitcoinHP = lastClaimTimesBitcoinHP[account];

        return (
            info.account,
            info.withdrawableDividendsSPX6900,
            info.withdrawableDividendsNeiro,
            info.withdrawableDividendsBitcoinHP,
            info.lastClaimTimeSPX6900,
            info.lastClaimTimeNeiro,
            info.lastClaimTimeBitcoinHP,
            totalDividendsWithdrawnSPX6900,
            totalDividendsWithdrawnNeiro,
            totalDividendsWithdrawnBitcoinHP
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
        (
            uint256 amountSPX6900,
            uint256 amountNeiro,
            uint256 amountBitcoinHP
        ) = _withdrawDividendOfUser(account);

        if (amountSPX6900 > 0) {
            lastClaimTimesSPX6900[account] = block.timestamp;
            emit Claim(account, amountSPX6900);
            return true;
        }
        if (amountNeiro > 0) {
            lastClaimTimesNeiro[account] = block.timestamp;
            emit Claim(account, amountNeiro);
            return true;
        }
        if (amountBitcoinHP > 0) {
            lastClaimTimesBitcoinHP[account] = block.timestamp;
            emit Claim(account, amountBitcoinHP);
            return true;
        }

        return true;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./libraries/SafeMath.sol";
import "./interfaces/IGIBDiv.sol";

interface IPair {
    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function token0() external view returns (address);
}

interface IFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);
}

interface IUniswapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint256 amountTokensDesired,
        uint256 amountTokensMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

contract DividendPayingToken is ERC20, DividendPayingTokenInterface, Ownable {
    using SafeMath for uint256;
    using SafeMathUint for uint256;
    using SafeMathInt for int256;

    address public spx6900;
    address public neiro;
    address public bitcoinHP;

    uint256 internal constant magnitude = 2**128;

    uint256 internal MagnifiedDividendPerShareSPX6900;
    uint256 internal MagnifiedDividendPerShareNeiro;
    uint256 internal MagnifiedDividendPerShareBitcoinHP;

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
    mapping(address => int256) internal magnifiedDividendCorrectionsSPX6900;
    mapping(address => int256) internal magnifiedDividendCorrectionsNeiro;
    mapping(address => int256) internal magnifiedDividendCorrectionsBitcoinHP;

    mapping(address => uint256) internal withdrawnDividendsSPX6900;
    mapping(address => uint256) internal withdrawnDividendsNeiro;
    mapping(address => uint256) internal withdrawnDividendsBitcoinHP;

    uint256 public totalDividendsDistributedSPX6900;
    uint256 public totalDividendsDistributedNeiro;
    uint256 public totalDividendsDistributedBitcoinHP;

    uint256 public totalDividendsWithdrawnSPX6900;
    uint256 public totalDividendsWithdrawnNeiro;
    uint256 public totalDividendsWithdrawnBitcoinHP;

    constructor(string memory _name, string memory _symbol)
        ERC20(_name, _symbol)
    {}

    function distributeDividends(
        uint256 amountSPX6900,
        uint256 amountNeiro,
        uint256 amountBitcoinHP
    ) public onlyOwner {
        require(totalSupply() > 0, "Total supply must be greater than zero");

        if (amountSPX6900 > 0) {
            MagnifiedDividendPerShareSPX6900 = MagnifiedDividendPerShareSPX6900.add(
                (amountSPX6900).mul(magnitude) / totalSupply()
            );
            emit DividendsDistributed(msg.sender, amountSPX6900);
            totalDividendsDistributedSPX6900 = totalDividendsDistributedSPX6900.add(
                amountSPX6900
            );
        }

        if (amountNeiro > 0) {
            MagnifiedDividendPerShareNeiro = MagnifiedDividendPerShareNeiro.add(
                (amountNeiro).mul(magnitude) / totalSupply()
            );
            emit DividendsDistributed(msg.sender, amountNeiro);
            totalDividendsDistributedNeiro = totalDividendsDistributedNeiro.add(
                amountNeiro
            );
        }

        if (amountBitcoinHP > 0) {
            MagnifiedDividendPerShareBitcoinHP = MagnifiedDividendPerShareBitcoinHP.add(
                (amountBitcoinHP).mul(magnitude) / totalSupply()
            );
            emit DividendsDistributed(msg.sender, amountBitcoinHP);
            totalDividendsDistributedBitcoinHP = totalDividendsDistributedBitcoinHP.add(
                amountBitcoinHP
            );
        }

       
    }

    /// @notice Withdraws the ether distributed to the sender.
    /// @dev It emits a `DividendWithdrawn` event if the amount of withdrawn ether is greater than 0.
    function withdrawDividend() public // virtual override
    {
        _withdrawDividendOfUser(msg.sender);
    }

    /// @notice Withdraws the ether distributed to the sender.
    /// @dev It emits a `DividendWithdrawn` event if the amount of withdrawn ether is greater than 0.
    function _withdrawDividendOfUser(address user)
        internal
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 withdrawableSPX6900;
        uint256 withdrawableNeiro;
        uint256 withdrawableBitcoinHP;

        (
            uint256 _withdrawableDividendSPx6900,
            uint256 _withdrawableDividendNeiro,
            uint256 _withdrawableDividendBitcoinHP

        ) = withdrawableDividendOf(user);
        if (_withdrawableDividendSPx6900 > 0) {
            withdrawnDividendsSPX6900[user] = withdrawnDividendsSPX6900[user].add(
                _withdrawableDividendSPx6900
            );
            totalDividendsWithdrawnSPX6900 += _withdrawableDividendSPx6900;
            emit DividendWithdrawn(user, _withdrawableDividendSPx6900);
            bool success = IERC20(spx6900).transfer(
                user,
                _withdrawableDividendSPx6900
            );

            if (!success) {
                withdrawnDividendsSPX6900[user] = withdrawnDividendsSPX6900[user]
                    .sub(_withdrawableDividendSPx6900);
                totalDividendsWithdrawnSPX6900 -= _withdrawableDividendSPx6900;
            } else {
                withdrawableSPX6900 = _withdrawableDividendSPx6900;
            }
        }

        if (_withdrawableDividendNeiro > 0) {
            withdrawnDividendsNeiro[user] = withdrawnDividendsNeiro[user].add(
                _withdrawableDividendNeiro
            );
            totalDividendsWithdrawnNeiro += _withdrawableDividendNeiro;
            emit DividendWithdrawn(user, _withdrawableDividendNeiro);
            bool success = IERC20(neiro).transfer(
                user,
                _withdrawableDividendNeiro
            );

            if (!success) {
                withdrawnDividendsNeiro[user] = withdrawnDividendsNeiro[user].sub(
                    _withdrawableDividendNeiro
                );
                totalDividendsWithdrawnNeiro -= _withdrawableDividendNeiro;
            } else {
                withdrawableNeiro = _withdrawableDividendNeiro;
            }
        }
        if (_withdrawableDividendBitcoinHP > 0) {
            withdrawnDividendsBitcoinHP[user] = withdrawnDividendsBitcoinHP[user].add(
                _withdrawableDividendBitcoinHP
            );
            totalDividendsWithdrawnBitcoinHP += _withdrawableDividendBitcoinHP;
            emit DividendWithdrawn(user, _withdrawableDividendBitcoinHP);
            bool success = IERC20(bitcoinHP).transfer(
                user,
                _withdrawableDividendBitcoinHP
            );

            if (!success) {
                withdrawnDividendsBitcoinHP[user] = withdrawnDividendsBitcoinHP[user].sub(
                    _withdrawableDividendBitcoinHP
                );
                totalDividendsWithdrawnBitcoinHP -= _withdrawableDividendBitcoinHP;
            } else {
                withdrawableBitcoinHP = _withdrawableDividendBitcoinHP;
            }
        }

        return (withdrawableSPX6900, withdrawableNeiro, withdrawableBitcoinHP);
    }



    /// @notice View the amount of dividend in wei that an address can withdraw.
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` can withdraw.
    function dividendOf(address _owner)
        public
        view
        override
        returns (
            uint256,
            uint256,
            uint256
  
        )
    {
        return withdrawableDividendOf(_owner);
    }

    /// @notice View the amount of dividend in wei that an address can withdraw.
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` can withdraw.
    function withdrawableDividendOf(address _owner)
        public
        view
        override
        returns (
            uint256,
            uint256,
            uint256
            
        )
    {
        (
            uint256 dividendOfSPX6900,
            uint256 dividendOfNeiro,
            uint256 dividendOfBitcoinHP
        ) = accumulativeDividendOf(_owner);
        return (
            dividendOfSPX6900.sub(withdrawnDividendsSPX6900[_owner]),
            dividendOfNeiro.sub(withdrawnDividendsNeiro[_owner]),
            dividendOfBitcoinHP.sub(withdrawnDividendsBitcoinHP[_owner])
        );
    }

    /// @notice View the amount of dividend in wei that an address has withdrawn.
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` has withdrawn.
    function withdrawnDividendOf(address _owner)
        public
        view
        override
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        return (
            withdrawnDividendsSPX6900[_owner],
            withdrawnDividendsNeiro[_owner],
            withdrawnDividendsBitcoinHP[_owner]
        );
    }

    /// @notice View the amount of dividend in wei that an address has earned in total.
    /// @dev accumulativeDividendOf(_owner) = withdrawableDividendOf(_owner) + withdrawnDividendOf(_owner)
    /// = (magnifiedDividendPerShare * balanceOf(_owner) + magnifiedDividendCorrections[_owner]) / magnitude
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` has earned in total.
    function accumulativeDividendOf(address _owner)
        public
        view
        override
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 spx6900Share = MagnifiedDividendPerShareSPX6900
            .mul(balanceOf(_owner))
            .toInt256Safe()
            .add(magnifiedDividendCorrectionsSPX6900[_owner])
            .toUint256Safe() / magnitude;
        uint256 neiroShare = MagnifiedDividendPerShareNeiro
            .mul(balanceOf(_owner))
            .toInt256Safe()
            .add(magnifiedDividendCorrectionsNeiro[_owner])
            .toUint256Safe() / magnitude;

        uint256 bitcoinShare = MagnifiedDividendPerShareBitcoinHP
            .mul(balanceOf(_owner))
            .toInt256Safe()
            .add(magnifiedDividendCorrectionsBitcoinHP[_owner])
            .toUint256Safe() / magnitude;
       
        return (spx6900Share, neiroShare, bitcoinShare);
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

        int256 _magCorrection = MagnifiedDividendPerShareSPX6900
            .mul(value)
            .toInt256Safe();
        magnifiedDividendCorrectionsSPX6900[
            from
        ] = magnifiedDividendCorrectionsSPX6900[from].add(_magCorrection);
        magnifiedDividendCorrectionsSPX6900[
            to
        ] = magnifiedDividendCorrectionsSPX6900[to].sub(_magCorrection);

        int256 _magCorrectionToken = MagnifiedDividendPerShareNeiro
            .mul(value)
            .toInt256Safe();
        magnifiedDividendCorrectionsNeiro[
            from
        ] = magnifiedDividendCorrectionsNeiro[from].add(_magCorrectionToken);

        magnifiedDividendCorrectionsNeiro[to] = magnifiedDividendCorrectionsNeiro[
            to
        ].sub(_magCorrectionToken);

         int256 _magCorrectionBitcoin = MagnifiedDividendPerShareBitcoinHP
            .mul(value)
            .toInt256Safe();
        magnifiedDividendCorrectionsBitcoinHP[
            from
        ] = magnifiedDividendCorrectionsBitcoinHP[from].add(_magCorrectionToken);
        magnifiedDividendCorrectionsBitcoinHP[to] = magnifiedDividendCorrectionsBitcoinHP[
            to
        ].sub(_magCorrectionBitcoin);
    }

    /// @dev Internal function that mints tokens to an account.
    /// Update magnifiedDividendCorrections to keep dividends unchanged.
    /// @param account The account that will receive the created tokens.
    /// @param value The amount that will be created.
    function _mint(address account, uint256 value) internal override {
        super._mint(account, value);
        magnifiedDividendCorrectionsSPX6900[
            account
        ] = magnifiedDividendCorrectionsSPX6900[account].sub(
            (MagnifiedDividendPerShareSPX6900.mul(value)).toInt256Safe()
        );

        magnifiedDividendCorrectionsNeiro[
            account
        ] = magnifiedDividendCorrectionsNeiro[account].sub(
            (MagnifiedDividendPerShareNeiro.mul(value)).toInt256Safe()
        );

         magnifiedDividendCorrectionsBitcoinHP[
            account
        ] = magnifiedDividendCorrectionsBitcoinHP[account].sub(
            (MagnifiedDividendPerShareBitcoinHP.mul(value)).toInt256Safe()
        );
    }

    /// @dev Internal function that burns an amount of the token of a given account.
    /// Update magnifiedDividendCorrections to keep dividends unchanged.
    /// @param account The account whose tokens will be burnt.
    /// @param value The amount that will be burnt.
    function _burn(address account, uint256 value) internal override {
        super._burn(account, value);

        magnifiedDividendCorrectionsSPX6900[
            account
        ] = magnifiedDividendCorrectionsSPX6900[account].add(
            (MagnifiedDividendPerShareSPX6900.mul(value)).toInt256Safe()
        );

        magnifiedDividendCorrectionsNeiro[
            account
        ] = magnifiedDividendCorrectionsNeiro[account].add(
            (MagnifiedDividendPerShareNeiro.mul(value)).toInt256Safe()
        );

          magnifiedDividendCorrectionsBitcoinHP[
            account
        ] = magnifiedDividendCorrectionsBitcoinHP[account].add(
            (MagnifiedDividendPerShareBitcoinHP.mul(value)).toInt256Safe()
        );
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

interface DividendPayingTokenInterface {
    /// @notice View the amount of dividend in wei that an address can withdraw.
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` can withdraw.
    function dividendOf(address _owner)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        
        );

    /// @notice Withdraws the ether distributed to the sender.
    /// @dev SHOULD transfer `dividendOf(msg.sender)` wei to `msg.sender`, and `dividendOf(msg.sender)` SHOULD be 0 after the transfer.
    ///  MUST emit a `DividendWithdrawn` event if the amount of ether transferred is greater than 0.
    function withdrawDividend() external;

    /// @notice View the amount of dividend in wei that an address can withdraw.
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` can withdraw.
    function withdrawableDividendOf(address _owner)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );

    /// @notice View the amount of dividend in wei that an address has withdrawn.
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` has withdrawn.
    function withdrawnDividendOf(address _owner)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
            
        );

    /// @notice View the amount of dividend in wei that an address has earned in total.
    /// @dev accumulativeDividendOf(_owner) = withdrawableDividendOf(_owner) + withdrawnDividendOf(_owner)
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` has earned in total.
    function accumulativeDividendOf(address _owner)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
            
        );

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