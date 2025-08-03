// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

/**
 * @dev Standard ERC20 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC20 tokens.
 */
interface IERC20Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientBalance(
        address sender,
        uint256 balance,
        uint256 needed
    );

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC20InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC20InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `spender`’s `allowance`. Used in transfers.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     * @param allowance Amount of tokens a `spender` is allowed to operate with.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientAllowance(
        address spender,
        uint256 allowance,
        uint256 needed
    );

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC20InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `spender` to be approved. Used in approvals.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC20InvalidSpender(address spender);
}

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

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
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
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
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
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
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
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
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

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
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
 */
abstract contract ERC20 is Context, IERC20, IERC20Metadata, IERC20Errors {
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
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
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
    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `value`.
     */
    function transfer(address to, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender)
        public
        view
        virtual
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `value` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, value);
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
     * - `from` must have a balance of at least `value`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `value`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token taxes, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _transfer(
        address from,
        address to,
        uint256 value
    ) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }

    /**
     * @dev Transfers a `value` amount of tokens from `from` to `to`, or alternatively mints (or burns) if `from`
     * (or `to`) is the zero address. All customizations to transfers, mints, and burns should be done by overriding
     * this function.
     *
     * Emits a {Transfer} event.
     */
    function _update(
        address from,
        address to,
        uint256 value
    ) internal virtual {
        if (from == address(0)) {
            // Overflow check required: The rest of the code assumes that totalSupply never overflows
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                // Overflow not possible: value <= fromBalance <= totalSupply.
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                // Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
                _totalSupply -= value;
            }
        } else {
            unchecked {
                // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    /**
     * @dev Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0).
     * Relies on the `_update` mechanism
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }

    /**
     * @dev Destroys a `value` amount of tokens from `account`, lowering the total supply.
     * Relies on the `_update` mechanism.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead
     */
    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }

    /**
     * @dev Sets `value` as the allowance of `spender` over the `owner` s tokens.
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
     *
     * Overrides to this logic should be done to the variant with an additional `bool emitEvent` argument.
     */
    function _approve(
        address owner,
        address spender,
        uint256 value
    ) internal {
        _approve(owner, spender, value, true);
    }

    /**
     * @dev Variant of {_approve} with an optional flag to enable or disable the {Approval} event.
     *
     * By default (when calling {_approve}) the flag is set to true. On the other hand, approval changes made by
     * `_spendAllowance` during the `transferFrom` operation set the flag to false. This saves gas by not emitting any
     * `Approval` event during `transferFrom` operations.
     *
     * Anyone who wishes to continue emitting `Approval` events on the`transferFrom` operation can force the flag to
     * true using the following override:
     * ```
     * function _approve(address owner, address spender, uint256 value, bool) internal virtual override {
     *     super._approve(owner, spender, value, true);
     * }
     * ```
     *
     * Requirements are the same as {_approve}.
     */
    function _approve(
        address owner,
        address spender,
        uint256 value,
        bool emitEvent
    ) internal virtual {
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        _allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `value`.
     *
     * Does not update the allowance value in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Does not emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 value
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(
                    spender,
                    currentAllowance,
                    value
                );
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }
}

/// Uniswap factory interface
interface IFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

/// Uniswap Router interface
interface IUniswapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract MAGAA is ERC20, Ownable {

    //Wallets 
    //owner Wallet and
    /// marketing buy wallet = TaxWallet1
    address public taxWallet1;
    /// marketing sell wallet = TaxWallet2
    address public taxWallet2;

    /// MAX AMOUNT PER BUY / SELL
    uint256 public constant maxAmountPerTx = MAX_SUPPLY / 100;
    /// MAX WALLET AMOUNT
    uint256 public constant maxWalletAmount = MAX_SUPPLY / 100;
    
    /// MAX SUPPLY
    uint256 private constant MAX_SUPPLY = 1_000_000_000 * 1e18;
    /// PERCENT_DIVISOR
    uint256 private constant PERCENT_DIVISOR = 10000;
    
    /// mapping for managing users which are excluded from taxes
    mapping(address => bool) public isExcludedFromTaxes;

    /// Trading flag
    bool public trading;
    
    ////// TAX STRUCTS //
    struct BuyTax {
        uint256 marketing;
    }

    struct SellTax {
        uint256 marketing;
    }

    BuyTax public buyTax;
    SellTax public sellTax;

    uint256 public totalBuyTax;
    uint256 public totalSellTax;
    
    /// @notice uniswapV2Router
    IUniswapRouter public immutable uniswapV2Router;
    /// @notice uniswapPair
    address public immutable uniswapPair;
        
    //// EVENTS

    event TaxWallet1Transferred(address indexed oldTaxWallet1,address indexed newTaxWallet1);
    event TaxWallet2Transferred(address indexed oldTaxWallet2,address indexed newTaxWallet2);

    event enabledTrading();
    event disabledTrading();

    event SellTaxesUpdated(uint256 indexed sellTaxTax);
    event BuyTaxesUpdated(uint256 indexed buyTaxTax);

    event EthClaimed(address indexed wallet, uint256 indexed amount);


    //// MODIFIER 

    /**
     * @dev Throws if the sender is not the marketing wallet.
     */

    modifier onlyTaxWallet1() {
        require(taxWallet1 == msg.sender, "Only Tax Wallet 1 can call this function");
        _;
    }

    modifier onlyTaxWallet2() {
        require(taxWallet2 == msg.sender, "Only Tax Wallet 2 can call this function");
        _;
    }

    modifier onlyTaxWallets() {
        require(taxWallet1 == msg.sender || taxWallet2 == msg.sender, "Only Tax Wallets can call this function");
        _;
    }

    /** @notice create an erc20, initialize all required variables
     *         like owner, uniswap v2 router, taxes values and wallets values.
     *        excludes the owner and token address from taxes and limits.
     *        mints the total supply to the owner wallet.
     */

    constructor(address taxWallet1Address, address taxWallet2Address) 
        ERC20("Trump", "MAGA") Ownable(msg.sender) {

        require(taxWallet1Address != address(0), "Tax Wallet 1 must not be 0x0 address");
        require(taxWallet2Address != address(0), "Tax Wallet 2 must not be 0x0 address");

        //0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        uniswapV2Router = IUniswapRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        
        uniswapPair = IFactory(uniswapV2Router.factory()).createPair(
            address(this),
            uniswapV2Router.WETH()
        );
        
        // 100 = 1%  10 = 0.1%  1 = 0.01%
        buyTax = BuyTax ({
            marketing: 100
        });

        totalBuyTax = buyTax.marketing;

        sellTax = SellTax ({
            marketing: 100
        });

        totalSellTax = sellTax.marketing;

        taxWallet1 = taxWallet1Address; 
        taxWallet2 = taxWallet2Address; 

        isExcludedFromTaxes[address(this)] = true;
        isExcludedFromTaxes[msg.sender] = true;
        isExcludedFromTaxes[taxWallet1Address] = true;
        isExcludedFromTaxes[taxWallet2Address] = true;

        trading = false;

        _mint(msg.sender, MAX_SUPPLY);
    }

    /**
     * @notice to recieve ETH from uniswapV2Router when swapping
     */

    receive() external payable  {
    }

    /**
     * @notice Allows the marketing wallet to claim stuck ERC20 tokens
     * @dev Only the marketing wallet can call this function
     * @param token The address of the ERC20 token to claim
     * @param value The amount of tokens to claim
     * @param wallet The address to transfer the claimed tokens to
     */

    function claimStuckERC20(
        address token,
        uint256 value,
        address wallet
    ) external onlyTaxWallets {
        ERC20 ERC20Token = ERC20(token);
        bool success = ERC20Token.transfer(wallet, value);
        require(success, "ERC20 transfer failed");
    }

    /**
     * @notice Allows the marketing wallet to claim stuck ERC20 tokens
     * @dev Only the marketing wallet can call this function
     * @param wallet The address to transfer the claimed tokens to
     */

    function claimStuckEth(address wallet) external onlyTaxWallets {
        require(wallet != address(0), "Wallet must not be 0x0 address");
        uint256 balance = address(this).balance;
        require(balance > 0, "No ETH to transfer");

        payable(wallet).transfer(balance);
        emit EthClaimed(wallet, balance);
    }

    /**
     * @notice Exclude or include an account from taxes.
     *
     * @param account The address of the account to be excluded or included.
     * @param value Boolean value indicating whether the account should
     *        be excluded (true) or included (false).
     */

    function setExcludeFromTaxes(address account, bool value) external onlyOwner {
        require(account != address(0), "Account must not be 0x0 address");
        isExcludedFromTaxes[account] = value;
    }


   /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     * To ensure no mishap when renouncing the ownership, we guarantee that trading will be enabled regardless.
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public override onlyOwner {
        enableTrading();
        super.renounceOwnership();
    }

    /**
     * @notice Enable Trading
     */

    function enableTrading() public onlyOwner {
        trading = true;
        emit enabledTrading();
    }

    /**
     * @notice Disable Trading
     */

    function disableTrading() external onlyOwner {
        trading = false;
        emit disabledTrading();
    }

    /**
     * @notice Update the Tax Wallet 1 wallet address
     * @param newTaxWallet1: The new address for the Tax wallet 1
     */

    function transferTaxWallet1(address newTaxWallet1) external onlyTaxWallet1 {
        require(newTaxWallet1 != address(0x0), "New Tax Wallet 1 must not be 0x0 address");
        isExcludedFromTaxes[taxWallet1] = false;
        isExcludedFromTaxes[newTaxWallet1] = true;
        emit TaxWallet1Transferred(taxWallet1, newTaxWallet1);
        taxWallet1 = newTaxWallet1;

    }

    /**
     * @notice Update the Tax Wallet 2 wallet address
     * @param newTaxWallet2: The new address for the Tax wallet 2
     */

    function transferTaxWallet2(address newTaxWallet2) external onlyTaxWallet2 {
        require(newTaxWallet2 != address(0x0), "New Tax Wallet 2 must not be 0x0 address");
        isExcludedFromTaxes[taxWallet2] = false;
        isExcludedFromTaxes[newTaxWallet2] = true;
        emit TaxWallet2Transferred(taxWallet2, newTaxWallet2);
        taxWallet2 = newTaxWallet2;
    }


    /**
     * @notice Renounce the Tax Wallet 1 
     */

    function renounceTaxWallet1() external onlyTaxWallet1 {
        isExcludedFromTaxes[taxWallet1] = false;
        taxWallet1 = address(0x0);
        buyTax.marketing = 0;
        totalBuyTax = 0;
    }

    /**
     * @notice Renounce the Tax Wallet 2 
     */

    function renounceTaxWallet2() external onlyTaxWallet2 {
        isExcludedFromTaxes[taxWallet2] = false;
        taxWallet2 = address(0x0);
        sellTax.marketing = 0;
        totalSellTax = 0;
    }

    /**
     * @notice Update the wallets for taxes distribution.
     *
     * @param newTaxWallet1 The address of the marketing wallet.
     * @param newTaxWallet2 The address of the marketing wallet.
     *
     */

    function setWallets(address newTaxWallet1, address newTaxWallet2) external onlyOwner {
        require(newTaxWallet1 != address(0x0), "New Tax Wallet 1 must not be 0x0 address");
        require(newTaxWallet2 != address(0x0), "New Tax Wallet 2 must not be 0x0 address");
        emit TaxWallet1Transferred(taxWallet1, newTaxWallet1);
        taxWallet1 = newTaxWallet1;
        emit TaxWallet2Transferred(taxWallet2, newTaxWallet2);
        taxWallet2 = newTaxWallet2;
    }

    /**
     * @notice override required by solidity
     * @dev see{IERC20}
     * manage taxes on buy/sell and maxTxAmount/MaxWalletLimit
     *
     */

    function _update(
        address from,
        address to,
        uint256 amount
    ) internal override {

        require(trading || from == owner() || to == owner() || from == address(0x0), "Trading disabled, only owner can transfer");

        if (to != owner() && from != owner() && from != address(0x0) && to != uniswapPair){
            require(amount <= maxAmountPerTx, "Max amount per Tx exceeded");
            require(amount + balanceOf(to) <= maxWalletAmount, "Max limit per wallet reached");
        }

        if (!isExcludedFromTaxes[from] && !isExcludedFromTaxes[to]) {
            uint256 tax = 0;

            if (from == uniswapPair) {
                if (totalBuyTax > 0) {
                    tax = (amount * totalBuyTax) / PERCENT_DIVISOR;
                    uint256 taxForMarketing = (amount * buyTax.marketing) /
                    PERCENT_DIVISOR;
                    if (taxForMarketing > 0) {
                       _transfer(from, taxWallet1, taxForMarketing);
                    }
                }
            } 
            else if (to == uniswapPair) {
               if (totalSellTax > 0) {
                    tax = (amount * totalSellTax) / PERCENT_DIVISOR;
                    uint256 taxForMarketing = (amount * sellTax.marketing) /
                    PERCENT_DIVISOR;
                    if (taxForMarketing > 0) {
                       _transfer(from, taxWallet2, taxForMarketing);
                    }
                }
            }
            amount = amount - tax;
        }

        super._update(from, to, amount);
    }
}