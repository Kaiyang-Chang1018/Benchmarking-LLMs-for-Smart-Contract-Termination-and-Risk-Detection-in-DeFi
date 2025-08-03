// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.21;


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)
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

// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)
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

// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)
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

interface IERC4626 is IERC20, IERC20Metadata {
    event Deposit(address indexed sender, address indexed owner, uint256 assets, uint256 shares);

    event Withdraw(
        address indexed sender,
        address indexed receiver,
        address indexed owner,
        uint256 assets,
        uint256 shares
    );

    /**
     * @dev Returns the address of the underlying token used for the Vault for accounting, depositing, and withdrawing.
     *
     * - MUST be an ERC-20 token contract.
     * - MUST NOT revert.
     */
    function asset() external view returns (address assetTokenAddress);

    /**
     * @dev Returns the total amount of the underlying asset that is “managed” by Vault.
     *
     * - SHOULD include any compounding that occurs from yield.
     * - MUST be inclusive of any fees that are charged against assets in the Vault.
     * - MUST NOT revert.
     */
    function totalAssets() external view returns (uint256 totalManagedAssets);

    /**
     * @dev Returns the amount of shares that the Vault would exchange for the amount of assets provided, in an ideal
     * scenario where all the conditions are met.
     *
     * - MUST NOT be inclusive of any fees that are charged against assets in the Vault.
     * - MUST NOT show any variations depending on the caller.
     * - MUST NOT reflect slippage or other on-chain conditions, when performing the actual exchange.
     * - MUST NOT revert.
     *
     * NOTE: This calculation MAY NOT reflect the “per-user” price-per-share, and instead should reflect the
     * “average-user’s” price-per-share, meaning what the average user should expect to see when exchanging to and
     * from.
     */
    function convertToShares(uint256 assets) external view returns (uint256 shares);

    /**
     * @dev Returns the amount of assets that the Vault would exchange for the amount of shares provided, in an ideal
     * scenario where all the conditions are met.
     *
     * - MUST NOT be inclusive of any fees that are charged against assets in the Vault.
     * - MUST NOT show any variations depending on the caller.
     * - MUST NOT reflect slippage or other on-chain conditions, when performing the actual exchange.
     * - MUST NOT revert.
     *
     * NOTE: This calculation MAY NOT reflect the “per-user” price-per-share, and instead should reflect the
     * “average-user’s” price-per-share, meaning what the average user should expect to see when exchanging to and
     * from.
     */
    function convertToAssets(uint256 shares) external view returns (uint256 assets);

    /**
     * @dev Returns the maximum amount of the underlying asset that can be deposited into the Vault for the receiver,
     * through a deposit call.
     *
     * - MUST return a limited value if receiver is subject to some deposit limit.
     * - MUST return 2 ** 256 - 1 if there is no limit on the maximum amount of assets that may be deposited.
     * - MUST NOT revert.
     */
    function maxDeposit(address receiver) external view returns (uint256 maxAssets);

    /**
     * @dev Allows an on-chain or off-chain user to simulate the effects of their deposit at the current block, given
     * current on-chain conditions.
     *
     * - MUST return as close to and no more than the exact amount of Vault shares that would be minted in a deposit
     *   call in the same transaction. I.e. deposit should return the same or more shares as previewDeposit if called
     *   in the same transaction.
     * - MUST NOT account for deposit limits like those returned from maxDeposit and should always act as though the
     *   deposit would be accepted, regardless if the user has enough tokens approved, etc.
     * - MUST be inclusive of deposit fees. Integrators should be aware of the existence of deposit fees.
     * - MUST NOT revert.
     *
     * NOTE: any unfavorable discrepancy between convertToShares and previewDeposit SHOULD be considered slippage in
     * share price or some other type of condition, meaning the depositor will lose assets by depositing.
     */
    function previewDeposit(uint256 assets) external view returns (uint256 shares);

    /**
     * @dev Mints shares Vault shares to receiver by depositing exactly amount of underlying tokens.
     *
     * - MUST emit the Deposit event.
     * - MAY support an additional flow in which the underlying tokens are owned by the Vault contract before the
     *   deposit execution, and are accounted for during deposit.
     * - MUST revert if all of assets cannot be deposited (due to deposit limit being reached, slippage, the user not
     *   approving enough underlying tokens to the Vault contract, etc).
     *
     * NOTE: most implementations will require pre-approval of the Vault with the Vault’s underlying asset token.
     */
    function deposit(uint256 assets, address receiver) external returns (uint256 shares);

    /**
     * @dev Returns the maximum amount of the Vault shares that can be minted for the receiver, through a mint call.
     * - MUST return a limited value if receiver is subject to some mint limit.
     * - MUST return 2 ** 256 - 1 if there is no limit on the maximum amount of shares that may be minted.
     * - MUST NOT revert.
     */
    function maxMint(address receiver) external view returns (uint256 maxShares);

    /**
     * @dev Allows an on-chain or off-chain user to simulate the effects of their mint at the current block, given
     * current on-chain conditions.
     *
     * - MUST return as close to and no fewer than the exact amount of assets that would be deposited in a mint call
     *   in the same transaction. I.e. mint should return the same or fewer assets as previewMint if called in the
     *   same transaction.
     * - MUST NOT account for mint limits like those returned from maxMint and should always act as though the mint
     *   would be accepted, regardless if the user has enough tokens approved, etc.
     * - MUST be inclusive of deposit fees. Integrators should be aware of the existence of deposit fees.
     * - MUST NOT revert.
     *
     * NOTE: any unfavorable discrepancy between convertToAssets and previewMint SHOULD be considered slippage in
     * share price or some other type of condition, meaning the depositor will lose assets by minting.
     */
    function previewMint(uint256 shares) external view returns (uint256 assets);

    /**
     * @dev Mints exactly shares Vault shares to receiver by depositing amount of underlying tokens.
     *
     * - MUST emit the Deposit event.
     * - MAY support an additional flow in which the underlying tokens are owned by the Vault contract before the mint
     *   execution, and are accounted for during mint.
     * - MUST revert if all of shares cannot be minted (due to deposit limit being reached, slippage, the user not
     *   approving enough underlying tokens to the Vault contract, etc).
     *
     * NOTE: most implementations will require pre-approval of the Vault with the Vault’s underlying asset token.
     */
    function mint(uint256 shares, address receiver) external returns (uint256 assets);

    /**
     * @dev Returns the maximum amount of the underlying asset that can be withdrawn from the owner balance in the
     * Vault, through a withdraw call.
     *
     * - MUST return a limited value if owner is subject to some withdrawal limit or timelock.
     * - MUST NOT revert.
     */
    function maxWithdraw(address owner) external view returns (uint256 maxAssets);

    /**
     * @dev Allows an on-chain or off-chain user to simulate the effects of their withdrawal at the current block,
     * given current on-chain conditions.
     *
     * - MUST return as close to and no fewer than the exact amount of Vault shares that would be burned in a withdraw
     *   call in the same transaction. I.e. withdraw should return the same or fewer shares as previewWithdraw if
     *   called
     *   in the same transaction.
     * - MUST NOT account for withdrawal limits like those returned from maxWithdraw and should always act as though
     *   the withdrawal would be accepted, regardless if the user has enough shares, etc.
     * - MUST be inclusive of withdrawal fees. Integrators should be aware of the existence of withdrawal fees.
     * - MUST NOT revert.
     *
     * NOTE: any unfavorable discrepancy between convertToShares and previewWithdraw SHOULD be considered slippage in
     * share price or some other type of condition, meaning the depositor will lose assets by depositing.
     */
    function previewWithdraw(uint256 assets) external view returns (uint256 shares);

    /**
     * @dev Burns shares from owner and sends exactly assets of underlying tokens to receiver.
     *
     * - MUST emit the Withdraw event.
     * - MAY support an additional flow in which the underlying tokens are owned by the Vault contract before the
     *   withdraw execution, and are accounted for during withdraw.
     * - MUST revert if all of assets cannot be withdrawn (due to withdrawal limit being reached, slippage, the owner
     *   not having enough shares, etc).
     *
     * Note that some implementations will require pre-requesting to the Vault before a withdrawal may be performed.
     * Those methods should be performed separately.
     */
    function withdraw(uint256 assets, address receiver, address owner) external returns (uint256 shares);

    /**
     * @dev Returns the maximum amount of Vault shares that can be redeemed from the owner balance in the Vault,
     * through a redeem call.
     *
     * - MUST return a limited value if owner is subject to some withdrawal limit or timelock.
     * - MUST return balanceOf(owner) if owner is not subject to any withdrawal limit or timelock.
     * - MUST NOT revert.
     */
    function maxRedeem(address owner) external view returns (uint256 maxShares);

    /**
     * @dev Allows an on-chain or off-chain user to simulate the effects of their redeemption at the current block,
     * given current on-chain conditions.
     *
     * - MUST return as close to and no more than the exact amount of assets that would be withdrawn in a redeem call
     *   in the same transaction. I.e. redeem should return the same or more assets as previewRedeem if called in the
     *   same transaction.
     * - MUST NOT account for redemption limits like those returned from maxRedeem and should always act as though the
     *   redemption would be accepted, regardless if the user has enough shares, etc.
     * - MUST be inclusive of withdrawal fees. Integrators should be aware of the existence of withdrawal fees.
     * - MUST NOT revert.
     *
     * NOTE: any unfavorable discrepancy between convertToAssets and previewRedeem SHOULD be considered slippage in
     * share price or some other type of condition, meaning the depositor will lose assets by redeeming.
     */
    function previewRedeem(uint256 shares) external view returns (uint256 assets);

    /**
     * @dev Burns exactly shares from owner and sends assets of underlying tokens to receiver.
     *
     * - MUST emit the Withdraw event.
     * - MAY support an additional flow in which the underlying tokens are owned by the Vault contract before the
     *   redeem execution, and are accounted for during redeem.
     * - MUST revert if all of shares cannot be redeemed (due to withdrawal limit being reached, slippage, the owner
     *   not having enough shares, etc).
     *
     * NOTE: some implementations will require pre-requesting to the Vault before a withdrawal may be performed.
     * Those methods should be performed separately.
     */
    function redeem(uint256 shares, address receiver, address owner) external returns (uint256 assets);
}

// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/extensions/IERC20Permit.sol)
/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

interface ITokenizedStrategy is IERC4626, IERC20Permit {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event UpdatePendingManagement(address indexed newPendingManagement);

    event UpdateManagement(address indexed newManagement);

    event UpdateKeeper(address indexed newKeeper);

    event UpdateEmergencyAdmin(address indexed newEmergencyAdmin);

    event UpdatePerformanceFee(uint16 newPerformanceFee);

    event UpdatePerformanceFeeRecipient(
        address indexed newPerformanceFeeRecipient
    );

    event UpdateProfitMaxUnlockTime(uint256 newProfitMaxUnlockTime);

    event StrategyShutdown();

    event Reported(
        uint256 profit,
        uint256 loss,
        uint256 protocolFees,
        uint256 performanceFees
    );

    /*//////////////////////////////////////////////////////////////
                           INITIALIZATION
    //////////////////////////////////////////////////////////////*/

    function init(
        address _asset,
        string memory _name,
        address _management,
        address _performanceFeeRecipient,
        address _keeper
    ) external;

    /*//////////////////////////////////////////////////////////////
                    NON-STANDARD 4626 OPTIONS
    //////////////////////////////////////////////////////////////*/

    function withdraw(
        uint256 assets,
        address receiver,
        address owner,
        uint256 maxLoss
    ) external returns (uint256);

    function redeem(
        uint256 shares,
        address receiver,
        address owner,
        uint256 maxLoss
    ) external returns (uint256);

    /*//////////////////////////////////////////////////////////////
                            MODIFIERS
    //////////////////////////////////////////////////////////////*/

    function isManagement(address _sender) external view returns (bool);

    function isKeeperOrManagement(address _sender) external view returns (bool);

    function isEmergencyAuthorized(
        address _sender
    ) external view returns (bool);

    /*//////////////////////////////////////////////////////////////
                        KEEPERS FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function tend() external;

    function report() external returns (uint256 _profit, uint256 _loss);

    /*//////////////////////////////////////////////////////////////
                        CONSTANTS
    //////////////////////////////////////////////////////////////*/

    function MIN_FEE() external view returns (uint16);

    function MAX_FEE() external view returns (uint16);

    function FACTORY() external view returns (address);

    /*//////////////////////////////////////////////////////////////
                            GETTERS
    //////////////////////////////////////////////////////////////*/

    function apiVersion() external view returns (string memory);

    function pricePerShare() external view returns (uint256);

    function totalIdle() external view returns (uint256);

    function totalDebt() external view returns (uint256);

    function management() external view returns (address);

    function pendingManagement() external view returns (address);

    function keeper() external view returns (address);

    function emergencyAdmin() external view returns (address);

    function performanceFee() external view returns (uint16);

    function performanceFeeRecipient() external view returns (address);

    function fullProfitUnlockDate() external view returns (uint256);

    function profitUnlockingRate() external view returns (uint256);

    function profitMaxUnlockTime() external view returns (uint256);

    function lastReport() external view returns (uint256);

    function isShutdown() external view returns (bool);

    function unlockedShares() external view returns (uint256);

    /*//////////////////////////////////////////////////////////////
                            SETTERS
    //////////////////////////////////////////////////////////////*/

    function setPendingManagement(address) external;

    function acceptManagement() external;

    function setKeeper(address _keeper) external;

    function setEmergencyAdmin(address _emergencyAdmin) external;

    function setPerformanceFee(uint16 _performanceFee) external;

    function setPerformanceFeeRecipient(
        address _performanceFeeRecipient
    ) external;

    function setProfitMaxUnlockTime(uint256 _profitMaxUnlockTime) external;

    function shutdownStrategy() external;

    function emergencyWithdraw(uint256 _amount) external;

    /*//////////////////////////////////////////////////////////////
                           ERC20 ADD ONS
    //////////////////////////////////////////////////////////////*/

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) external returns (bool);

    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) external returns (bool);
}

interface IBaseStrategy {
    function tokenizedStrategyAddress() external view returns (address);

    /*//////////////////////////////////////////////////////////////
                            IMMUTABLE FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function availableDepositLimit(
        address _owner
    ) external view returns (uint256);

    function availableWithdrawLimit(
        address _owner
    ) external view returns (uint256);

    function deployFunds(uint256 _assets) external;

    function freeFunds(uint256 _amount) external;

    function harvestAndReport() external returns (uint256);

    function tendThis(uint256 _totalIdle) external;

    function shutdownWithdraw(uint256 _amount) external;

    function tendTrigger() external view returns (bool, bytes memory);

    function maxLTV() external view returns (uint256);

    function collateral() external view returns (address);
}

interface IStrategy is IBaseStrategy, ITokenizedStrategy {}

interface IAprOracle {
    function getExpectedApr(
        address _strategy,
        int256 _debtChange
    ) external view returns (uint256);

    function getUtilizationInfo(
        address _strategy
    ) external view returns (uint256, uint256);

    function oracles(address _strategy) external view returns (address);
}

interface IAggregatorDataProvider {
    function addVault(address _vault) external;

    function addVaults(address[] memory vaults_) external;

    function addStrategy(address _strategy) external;

    function addStrategies(address[] memory strategies_) external;

    function addVaultStrategy(address _vault, address _strategy) external;

    function addVaultStrategies(address _vault, address[] memory strategies_) external;


    struct StrategyPairData {
        address asset;
        string assetSymbol;
        uint256 assetDecimals;
        address collateral;
        string collateralSymbol;
        uint256 collateralDecimals;

        address rateContract;
        address oracle;
        uint256 depositLimit;
        // currentRateInfo
        uint64 ratePerSec;
        uint64 fullUtilizationRate;
        uint32 feeToProtocolRate;
        // exchangeRateInfo
        uint32 maxOacleDeviation;
        uint256 lowExchangeRate;
        uint256 highExchangeRate;

        uint256 maxLTV;

        uint256 protocolLiquidationFee;

        uint256 totalAsset;
        uint256 totalCollateral;
        uint256 totalBorrow;
        uint256 version;
    }

    struct StrategyData {
        address deployedAt;
        address pair;
        StrategyPairData pairData;
    }

    struct VaultStrategyData {
        uint256 maxDebt; // The max assets the strategy can hold. 
        uint256 currentDebt; // The current assets the strategy holds.
        address collateral;
        string collateralSymbol;
        uint256 collateralDecimals;
        StrategyData strategyData;
    }

    struct AggregatedVaultData {
        address deployedAt;
        bool isShutdown;
        address asset;
        string assetSymbol;
        uint256 assetDecimals;        
        string name;
        uint256 totalAssets;
        uint256 totalDebt;
        VaultStrategyData[] vaultStrategyData;
    }

    struct UserVaultData {
        address vault;
        uint256 balance;
    }

    struct UserStrategyData {
        address strategy;
        uint256 assetBalance;
        uint256 borrowBalance;
        uint256 collateralBalance;
    }

    struct AggregatedUserData {
        UserVaultData[] userVaultData;
        UserStrategyData[] userStrategyData;
    }
}

interface IFraxLend {
    function deposit(
        uint256 _amount,
        address _receiver
    ) external returns (uint256 _sharesReceived);

    function redeem(
        uint256 _shares,
        address _receiver,
        address _owner
    ) external returns (uint256 _amountToReturn);

    function balanceOf(address) external view returns (uint256);

    function addInterest() external;

    function addCollateral(uint256 _collateralAmount, address _borrower) external;

    function removeCollateral(uint256 _collateralAmount, address _receiver) external;

    /// @notice The ```toAssetAmount``` function converts a given number of shares to an asset amount
    /// @param _shares Shares of asset (fToken)
    /// @param _roundUp Whether to round up after division
    /// @return The amount of asset
    function toAssetAmount(
        uint256 _shares,
        bool _roundUp
    ) external view returns (uint256);

    /// @notice The ```toAssetShares``` function converts a given asset amount to a number of asset shares (fTokens)
    /// @param _amount The amount of asset
    /// @param _roundUp Whether to round up after division
    /// @return The number of shares (fTokens)
    function toAssetShares(
        uint256 _amount,
        bool _roundUp
    ) external view returns (uint256);

    function toBorrowAmount(uint256 _shares, bool _roundUp) external view returns (uint256);

    function toBorrowShares(uint256 _amount, bool _roundUp) external view returns (uint256);

    function exchangeRateInfo() external view returns (uint32 lastTimestamp, uint224 exchangeRate);

    function currentRateInfo()
        external
        view
        returns (
            uint64 lastBlock,
            uint64 feeToProtocolRate,
            uint64 lastTimestamp,
            uint64 ratePerSec
        );

    function totalAsset()
        external
        view
        returns (uint128 amount, uint128 shares);

    function totalBorrow()
        external
        view
        returns (uint128 amount, uint128 shares);

    function totalCollateral() external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function paused() external view returns (bool);

    function maturityDate() external view returns (uint256);

    function penaltyRate() external view returns (uint256);

    function rateContract() external view returns (address);

    function rateInitCallData() external view returns (bytes calldata);

    function maxLTV() external view returns (uint256);

    function collateralContract() external view returns (address);

    function getUserSnapshot(
        address _address
    ) external view returns (uint256 _userAssetShares, uint256 _userBorrowShares, uint256 _userCollateralBalance);

    function getConstants()
        external
        pure
        returns (
            uint256 _LTV_PRECISION,
            uint256 _LIQ_PRECISION,
            uint256 _UTIL_PREC,
            uint256 _FEE_PRECISION,
            uint256 _EXCHANGE_PRECISION,
            uint64 _DEFAULT_INT,
            uint16 _DEFAULT_PROTOCOL_FEE,
            uint256 _MAX_PROTOCOL_FEE
        );
    
    function borrowAsset(uint256 _borrowAmount, uint256 _collateralAmount, address _receiver) external returns (uint256 _shares);

    function repayAsset(uint256 _shares, address _borrower) external returns (uint256 _amountToRepay);

    function userBorrowShares(address) external view returns (uint256);

    function userCollateralBalance(address) external view returns (uint256);

    function version() external pure returns (uint256 _major, uint256 _minor, uint256 _patch);
}

interface IVault is IERC4626 {
    // STRATEGY EVENTS
    event StrategyChanged(address indexed strategy, uint256 change_type);
    event StrategyReported(
        address indexed strategy,
        uint256 gain,
        uint256 loss,
        uint256 current_debt,
        uint256 protocol_fees,
        uint256 total_fees,
        uint256 total_refunds
    );
    // DEBT MANAGEMENT EVENTS
    event DebtUpdated(
        address indexed strategy,
        uint256 current_debt,
        uint256 new_debt
    );
    // ROLE UPDATES
    event RoleSet(address indexed account, uint256 role);
    event RoleStatusChanged(uint256 role, uint256 status);
    event UpdateRoleManager(address indexed role_manager);

    event UpdateAccountant(address indexed accountant);
    event UpdateDefaultQueue(address[] new_default_queue);
    event UpdateUseDefaultQueue(bool use_default_queue);
    event UpdatedMaxDebtForStrategy(
        address indexed sender,
        address indexed strategy,
        uint256 new_debt
    );
    event UpdateDepositLimit(uint256 deposit_limit);
    event UpdateMinimumTotalIdle(uint256 minimum_total_idle);
    event UpdateProfitMaxUnlockTime(uint256 profit_max_unlock_time);
    event DebtPurchased(address indexed strategy, uint256 amount);
    event Shutdown();

    struct StrategyParams {
        uint256 activation;
        uint256 last_report;
        uint256 current_debt;
        uint256 max_debt;
    }

    function FACTORY() external view returns (uint256);

    function strategies(address) external view returns (StrategyParams memory);

    function default_queue(uint256) external view returns (address);

    function use_default_queue() external view returns (bool);

    function total_supply() external view returns (uint256);

    function minimum_total_idle() external view returns (uint256);

    function deposit_limit() external view returns (uint256);

    function deposit_limit_module() external view returns (address);

    function withdraw_limit_module() external view returns (address);

    function accountant() external view returns (address);

    function roles(address) external view returns (uint256);

    function open_roles(uint256) external view returns (bool);

    function role_manager() external view returns (address);

    function future_role_manager() external view returns (address);

    function isShutdown() external view returns (bool);

    function nonces(address) external view returns (uint256);

    function set_accountant(address new_accountant) external;

    function set_default_queue(address[] memory new_default_queue) external;

    function set_use_default_queue(bool) external;

    function set_deposit_limit(uint256 deposit_limit) external;

    function set_deposit_limit_module(
        address new_deposit_limit_module
    ) external;

    function set_withdraw_limit_module(
        address new_withdraw_limit_module
    ) external;

    function set_minimum_total_idle(uint256 minimum_total_idle) external;

    function setProfitMaxUnlockTime(
        uint256 new_profit_max_unlock_time
    ) external;

    function set_role(address account, uint256 role) external;

    function add_role(address account, uint256 role) external;

    function remove_role(address account, uint256 role) external;

    function set_open_role(uint256 role) external;

    function close_open_role(uint256 role) external;

    function transfer_role_manager(address role_manager) external;

    function accept_role_manager() external;

    function unlockedShares() external view returns (uint256);

    function pricePerShare() external view returns (uint256);

    function get_default_queue() external view returns (address[] memory);

    function process_report(
        address strategy
    ) external returns (uint256, uint256);

    function buy_debt(address strategy, uint256 amount) external;

    function add_strategy(address new_strategy) external;

    function revoke_strategy(address strategy) external;

    function force_revoke_strategy(address strategy) external;

    function update_max_debt_for_strategy(
        address strategy,
        uint256 new_max_debt
    ) external;

    function update_debt(
        address strategy,
        uint256 target_debt
    ) external returns (uint256);

    function shutdown_vault() external;

    function totalIdle() external view returns (uint256);

    function totalDebt() external view returns (uint256);

    function apiVersion() external view returns (string memory);

    function assess_share_of_unrealised_losses(
        address strategy,
        uint256 assets_needed
    ) external view returns (uint256);

    function profitMaxUnlockTime() external view returns (uint256);

    function fullProfitUnlockDate() external view returns (uint256);

    function profitUnlockingRate() external view returns (uint256);

    function lastProfitUpdate() external view returns (uint256);

    //// NON-STANDARD ERC-4626 FUNCTIONS \\\\

    function withdraw(
        uint256 assets,
        address receiver,
        address owner,
        uint256 max_loss
    ) external returns (uint256);

    function withdraw(
        uint256 assets,
        address receiver,
        address owner,
        uint256 max_loss,
        address[] memory strategies
    ) external returns (uint256);

    function redeem(
        uint256 shares,
        address receiver,
        address owner,
        uint256 max_loss
    ) external returns (uint256);

    function redeem(
        uint256 shares,
        address receiver,
        address owner,
        uint256 max_loss,
        address[] memory strategies
    ) external returns (uint256);

    function maxWithdraw(
        address owner,
        uint256 max_loss
    ) external view returns (uint256);

    function maxWithdraw(
        address owner,
        uint256 max_loss,
        address[] memory strategies
    ) external view returns (uint256);

    function maxRedeem(
        address owner,
        uint256 max_loss
    ) external view returns (uint256);

    function maxRedeem(
        address owner,
        uint256 max_loss,
        address[] memory strategies
    ) external view returns (uint256);

    //// NON-STANDARD ERC-20 FUNCTIONS \\\\

    function increaseAllowance(
        address spender,
        uint256 amount
    ) external returns (bool);

    function decreaseAllowance(
        address spender,
        uint256 amount
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function permit(
        address owner,
        address spender,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (bool);
}

abstract contract BaseStrategy {
    /*//////////////////////////////////////////////////////////////
                            MODIFIERS
    //////////////////////////////////////////////////////////////*/
    /**
     * @dev Used on TokenizedStrategy callback functions to make sure it is post
     * a delegateCall from this address to the TokenizedStrategy.
     */
    modifier onlySelf() {
        _onlySelf();
        _;
    }

    /**
     * @dev Use to assure that the call is coming from the strategies management.
     */
    modifier onlyManagement() {
        TokenizedStrategy.isManagement(msg.sender);
        _;
    }

    /**
     * @dev Use to assure that the call is coming from either the strategies
     * management or the keeper.
     */
    modifier onlyKeepers() {
        TokenizedStrategy.isKeeperOrManagement(msg.sender);
        _;
    }

    /**
     * @dev Use to assure that the call is coming from either the strategies
     * management or the emergency admin.
     */
    modifier onlyEmergencyAuthorized() {
        TokenizedStrategy.isEmergencyAuthorized(msg.sender);
        _;
    }

    function _onlySelf() internal view {
        require(msg.sender == address(this), "!self");
    }

    /*//////////////////////////////////////////////////////////////
                            CONSTANTS
    //////////////////////////////////////////////////////////////*/

    /**
     * This is the address of the TokenizedStrategy implementation
     * contract that will be used by all strategies to handle the
     * accounting, logic, storage etc.
     *
     * Any external calls to the that don't hit one of the functions
     * defined in this base or the strategy will end up being forwarded
     * through the fallback function, which will delegateCall this address.
     *
     * This address should be the same for every strategy, never be adjusted
     * and always be checked before any integration with the Strategy.
     */
    address public constant tokenizedStrategyAddress =
        0xDFC8cD9F2f2d306b7C0d109F005DF661E14f4ff2;

    /*//////////////////////////////////////////////////////////////
                            IMMUTABLES
    //////////////////////////////////////////////////////////////*/

    /**
     * This variable is set to address(this) during initialization of each strategy.
     *
     * This can be used to retrieve storage data within the strategy
     * contract as if it were a linked library.
     *
     *       i.e. uint256 totalAssets = TokenizedStrategy.totalAssets()
     *
     * Using address(this) will mean any calls using this variable will lead
     * to a call to itself. Which will hit the fallback function and
     * delegateCall that to the actual TokenizedStrategy.
     */
    ITokenizedStrategy internal immutable TokenizedStrategy;

    // Underlying asset the Strategy is earning yield on.
    // Stored here for cheap retrievals within the strategy.
    ERC20 internal immutable asset;

    /**
     * @notice Used to initialize the strategy on deployment.
     *
     * This will set the `TokenizedStrategy` variable for easy
     * internal view calls to the implementation. As well as
     * initializing the default storage variables based on the
     * parameters and using the deployer for the permissioned roles.
     *
     * @param _asset Address of the underlying asset.
     * @param _name Name the strategy will use.
     */
    constructor(address _asset, string memory _name) {
        asset = ERC20(_asset);

        // Set instance of the implementation for internal use.
        TokenizedStrategy = ITokenizedStrategy(address(this));

        // Initialize the strategy's storage variables.
        _delegateCall(
            abi.encodeCall(
                ITokenizedStrategy.init,
                (_asset, _name, msg.sender, msg.sender, msg.sender)
            )
        );

        // Store the tokenizedStrategyAddress at the standard implementation
        // address storage slot so etherscan picks up the interface. This gets
        // stored on initialization and never updated.
        assembly {
            sstore(
                // keccak256('eip1967.proxy.implementation' - 1)
                0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc,
                tokenizedStrategyAddress
            )
        }
    }

    /*//////////////////////////////////////////////////////////////
                NEEDED TO BE OVERRIDDEN BY STRATEGIST
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Should deploy up to '_amount' of 'asset' in the yield source.
     *
     * This function is called at the end of a {deposit} or {mint}
     * call. Meaning that unless a whitelist is implemented it will
     * be entirely permissionless and thus can be sandwiched or otherwise
     * manipulated.
     *
     * @param _amount The amount of 'asset' that the strategy should attempt
     * to deposit in the yield source.
     */
    function _deployFunds(uint256 _amount) internal virtual;

    /**
     * @dev Will attempt to free the '_amount' of 'asset'.
     *
     * The amount of 'asset' that is already loose has already
     * been accounted for.
     *
     * This function is called during {withdraw} and {redeem} calls.
     * Meaning that unless a whitelist is implemented it will be
     * entirely permissionless and thus can be sandwiched or otherwise
     * manipulated.
     *
     * Should not rely on asset.balanceOf(address(this)) calls other than
     * for diff accounting purposes.
     *
     * Any difference between `_amount` and what is actually freed will be
     * counted as a loss and passed on to the withdrawer. This means
     * care should be taken in times of illiquidity. It may be better to revert
     * if withdraws are simply illiquid so not to realize incorrect losses.
     *
     * @param _amount, The amount of 'asset' to be freed.
     */
    function _freeFunds(uint256 _amount) internal virtual;

    /**
     * @dev Internal function to harvest all rewards, redeploy any idle
     * funds and return an accurate accounting of all funds currently
     * held by the Strategy.
     *
     * This should do any needed harvesting, rewards selling, accrual,
     * redepositing etc. to get the most accurate view of current assets.
     *
     * NOTE: All applicable assets including loose assets should be
     * accounted for in this function.
     *
     * Care should be taken when relying on oracles or swap values rather
     * than actual amounts as all Strategy profit/loss accounting will
     * be done based on this returned value.
     *
     * This can still be called post a shutdown, a strategist can check
     * `TokenizedStrategy.isShutdown()` to decide if funds should be
     * redeployed or simply realize any profits/losses.
     *
     * @return _totalAssets A trusted and accurate account for the total
     * amount of 'asset' the strategy currently holds including idle funds.
     */
    function _harvestAndReport()
        internal
        virtual
        returns (uint256 _totalAssets);

    /*//////////////////////////////////////////////////////////////
                    OPTIONAL TO OVERRIDE BY STRATEGIST
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Optional function for strategist to override that can
     *  be called in between reports.
     *
     * If '_tend' is used tendTrigger() will also need to be overridden.
     *
     * This call can only be called by a permissioned role so may be
     * through protected relays.
     *
     * This can be used to harvest and compound rewards, deposit idle funds,
     * perform needed position maintenance or anything else that doesn't need
     * a full report for.
     *
     *   EX: A strategy that can not deposit funds without getting
     *       sandwiched can use the tend when a certain threshold
     *       of idle to totalAssets has been reached.
     *
     * The TokenizedStrategy contract will do all needed debt and idle updates
     * after this has finished and will have no effect on PPS of the strategy
     * till report() is called.
     *
     * @param _totalIdle The current amount of idle funds that are available to deploy.
     */
    function _tend(uint256 _totalIdle) internal virtual {}

    /**
     * @dev Optional trigger to override if tend() will be used by the strategy.
     * This must be implemented if the strategy hopes to invoke _tend().
     *
     * @return . Should return true if tend() should be called by keeper or false if not.
     */
    function _tendTrigger() internal view virtual returns (bool) {
        return false;
    }

    /**
     * @notice Returns if tend() should be called by a keeper.
     *
     * @return . Should return true if tend() should be called by keeper or false if not.
     * @return . Calldata for the tend call.
     */
    function tendTrigger() external view virtual returns (bool, bytes memory) {
        return (
            // Return the status of the tend trigger.
            _tendTrigger(),
            // And the needed calldata either way.
            abi.encodeWithSelector(ITokenizedStrategy.tend.selector)
        );
    }

    /**
     * @notice Gets the max amount of `asset` that an address can deposit.
     * @dev Defaults to an unlimited amount for any address. But can
     * be overridden by strategists.
     *
     * This function will be called before any deposit or mints to enforce
     * any limits desired by the strategist. This can be used for either a
     * traditional deposit limit or for implementing a whitelist etc.
     *
     *   EX:
     *      if(isAllowed[_owner]) return super.availableDepositLimit(_owner);
     *
     * This does not need to take into account any conversion rates
     * from shares to assets. But should know that any non max uint256
     * amounts may be converted to shares. So it is recommended to keep
     * custom amounts low enough as not to cause overflow when multiplied
     * by `totalSupply`.
     *
     * @param . The address that is depositing into the strategy.
     * @return . The available amount the `_owner` can deposit in terms of `asset`
     */
    function availableDepositLimit(
        address /*_owner*/
    ) public view virtual returns (uint256) {
        return type(uint256).max;
    }

    /**
     * @notice Gets the max amount of `asset` that can be withdrawn.
     * @dev Defaults to an unlimited amount for any address. But can
     * be overridden by strategists.
     *
     * This function will be called before any withdraw or redeem to enforce
     * any limits desired by the strategist. This can be used for illiquid
     * or sandwichable strategies. It should never be lower than `totalIdle`.
     *
     *   EX:
     *       return TokenIzedStrategy.totalIdle();
     *
     * This does not need to take into account the `_owner`'s share balance
     * or conversion rates from shares to assets.
     *
     * @param . The address that is withdrawing from the strategy.
     * @return . The available amount that can be withdrawn in terms of `asset`
     */
    function availableWithdrawLimit(
        address /*_owner*/
    ) public view virtual returns (uint256) {
        return type(uint256).max;
    }

    /**
     * @dev Optional function for a strategist to override that will
     * allow management to manually withdraw deployed funds from the
     * yield source if a strategy is shutdown.
     *
     * This should attempt to free `_amount`, noting that `_amount` may
     * be more than is currently deployed.
     *
     * NOTE: This will not realize any profits or losses. A separate
     * {report} will be needed in order to record any profit/loss. If
     * a report may need to be called after a shutdown it is important
     * to check if the strategy is shutdown during {_harvestAndReport}
     * so that it does not simply re-deploy all funds that had been freed.
     *
     * EX:
     *   if(freeAsset > 0 && !TokenizedStrategy.isShutdown()) {
     *       depositFunds...
     *    }
     *
     * @param _amount The amount of asset to attempt to free.
     */
    function _emergencyWithdraw(uint256 _amount) internal virtual {}

    /*//////////////////////////////////////////////////////////////
                        TokenizedStrategy HOOKS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Should deploy up to '_amount' of 'asset' in yield source.
     * @dev Callback for the TokenizedStrategy to call during a {deposit}
     * or {mint} to tell the strategy it can deploy funds.
     *
     * Since this can only be called after a {deposit} or {mint}
     * delegateCall to the TokenizedStrategy msg.sender == address(this).
     *
     * Unless a whitelist is implemented this will be entirely permissionless
     * and thus can be sandwiched or otherwise manipulated.
     *
     * @param _amount The amount of 'asset' that the strategy should
     * attempt to deposit in the yield source.
     */
    function deployFunds(uint256 _amount) external virtual onlySelf {
        _deployFunds(_amount);
    }

    /**
     * @notice Will attempt to free the '_amount' of 'asset'.
     * @dev Callback for the TokenizedStrategy to call during a withdraw
     * or redeem to free the needed funds to service the withdraw.
     *
     * This can only be called after a 'withdraw' or 'redeem' delegateCall
     * to the TokenizedStrategy so msg.sender == address(this).
     *
     * @param _amount The amount of 'asset' that the strategy should attempt to free up.
     */
    function freeFunds(uint256 _amount) external virtual onlySelf {
        _freeFunds(_amount);
    }

    /**
     * @notice Returns the accurate amount of all funds currently
     * held by the Strategy.
     * @dev Callback for the TokenizedStrategy to call during a report to
     * get an accurate accounting of assets the strategy controls.
     *
     * This can only be called after a report() delegateCall to the
     * TokenizedStrategy so msg.sender == address(this).
     *
     * @return . A trusted and accurate account for the total amount
     * of 'asset' the strategy currently holds including idle funds.
     */
    function harvestAndReport() external virtual onlySelf returns (uint256) {
        return _harvestAndReport();
    }

    /**
     * @notice Will call the internal '_tend' when a keeper tends the strategy.
     * @dev Callback for the TokenizedStrategy to initiate a _tend call in the strategy.
     *
     * This can only be called after a tend() delegateCall to the TokenizedStrategy
     * so msg.sender == address(this).
     *
     * We name the function `tendThis` so that `tend` calls are forwarded to
     * the TokenizedStrategy so it can do the necessary accounting.

     * @param _totalIdle The amount of current idle funds that can be
     * deployed during the tend
     */
    function tendThis(uint256 _totalIdle) external virtual onlySelf {
        _tend(_totalIdle);
    }

    /**
     * @notice Will call the internal '_emergencyWithdraw' function.
     * @dev Callback for the TokenizedStrategy during an emergency withdraw.
     *
     * This can only be called after a emergencyWithdraw() delegateCall to
     * the TokenizedStrategy so msg.sender == address(this).
     *
     * We name the function `shutdownWithdraw` so that `emergencyWithdraw`
     * calls are forwarded to the TokenizedStrategy so it can do the necessary
     * accounting after the withdraw.
     *
     * @param _amount The amount of asset to attempt to free.
     */
    function shutdownWithdraw(uint256 _amount) external virtual onlySelf {
        _emergencyWithdraw(_amount);
    }

    function maxLTV() external view virtual returns (uint256);

    function collateral() external view virtual returns (address);

    /**
     * @dev Function used to delegate call the TokenizedStrategy with
     * certain `_calldata` and return any return values.
     *
     * This is used to setup the initial storage of the strategy, and
     * can be used by strategist to forward any other call to the
     * TokenizedStrategy implementation.
     *
     * @param _calldata The abi encoded calldata to use in delegatecall.
     * @return . The return value if the call was successful in bytes.
     */
    function _delegateCall(
        bytes memory _calldata
    ) internal returns (bytes memory) {
        // Delegate call the tokenized strategy with provided calldata.
        (bool success, bytes memory result) = tokenizedStrategyAddress
            .delegatecall(_calldata);

        // If the call reverted. Return the error.
        if (!success) {
            assembly {
                let ptr := mload(0x40)
                let size := returndatasize()
                returndatacopy(ptr, 0, size)
                revert(ptr, size)
            }
        }

        // Return the result.
        return result;
    }

    // execute a function on the TokenizedStrategy and return any value.
    fallback() external {
        // load our target address
        address _tokenizedStrategyAddress = tokenizedStrategyAddress;
        // Execute external function using delegatecall and return any value.
        assembly {
            // Copy function selector and any arguments.
            calldatacopy(0, 0, calldatasize())
            // Execute function delegatecall.
            let result := delegatecall(
                gas(),
                _tokenizedStrategyAddress,
                0,
                calldatasize(),
                0,
                0
            )
            // Get any return value
            returndatacopy(0, 0, returndatasize())
            // Return any return value or error back to the caller
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }
}

// OpenZeppelin Contracts (last updated v4.9.0) (utils/Address.sol)
/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     *
     * Furthermore, `isContract` will also return true if the target contract within
     * the same transaction is already scheduled for destruction by `SELFDESTRUCT`,
     * which only has an effect at the end of a transaction.
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.0/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

library SafeERC20 {
    using Address for address;

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance + value));
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance - value));
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeWithSelector(token.approve.selector, spender, value);

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, 0));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Use a ERC-2612 signature to set the `owner` approval toward `spender` on `token`.
     * Revert on invalid signature.
     */
    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        require(returndata.length == 0 || abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silents catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We cannot use {Address-functionCall} here since this should return false
        // and not revert is the subcall reverts.

        (bool success, bytes memory returndata) = address(token).call(data);
        return
            success && (returndata.length == 0 || abi.decode(returndata, (bool))) && Address.isContract(address(token));
    }
}

library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                // Solidity will revert if denominator == 0, unlike the div opcode on its own.
                // The surrounding unchecked block does not change this fact.
                // See https://docs.soliditylang.org/en/latest/control-structures.html#checked-or-unchecked-arithmetic.
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1, "Math: mulDiv overflow");

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10 ** result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 256, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result << 3) < value ? 1 : 0);
        }
    }
}

struct VaultAccount {
    uint128 amount; // Total amount, analogous to market cap
    uint128 shares; // Total shares, analogous to shares outstanding
}

interface ISturdyPair {
    struct CurrentRateInfo {
        uint32 lastBlock;
        uint32 feeToProtocolRate; // Fee amount 1e5 precision
        uint64 lastTimestamp;
        uint64 ratePerSec;
        uint64 fullUtilizationRate;
    }

    function CIRCUIT_BREAKER_ADDRESS() external view returns (address);

    function COMPTROLLER_ADDRESS() external view returns (address);

    function DEPLOYER_ADDRESS() external view returns (address);

    function FRAXLEND_WHITELIST_ADDRESS() external view returns (address);

    function timelockAddress() external view returns (address);

    function addCollateral(uint256 _collateralAmount, address _borrower) external;
    
    function addInterest(
        bool _returnAccounting
    )
        external
        returns (
            uint256 _interestEarned,
            uint256 _feesAmount,
            uint256 _feesShare,
            CurrentRateInfo memory _currentRateInfo,
            VaultAccount memory _totalAsset,
            VaultAccount memory _totalBorrow
        );

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function approvedBorrowers(address) external view returns (bool);

    function approvedLenders(address) external view returns (bool);

    function approveBorrowDelegation(address _delegatee, uint256 _amount) external;

    function asset() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function borrowAsset(
        uint256 _borrowAmount,
        uint256 _collateralAmount,
        address _receiver
    ) external returns (uint256 _shares);

    function borrowAssetOnBehalfOf(
        uint256 _borrowAmount,
        address _onBehalfOf
    ) external returns (uint256 _shares);

    function borrowerWhitelistActive() external view returns (bool);

    function changeFee(uint32 _newFee) external;

    function cleanLiquidationFee() external view returns (uint256);

    function collateralContract() external view returns (address);

    function currentRateInfo()
        external
        view
        returns (
            uint32 lastBlock,
            uint32 feeToProtocolRate,
            uint64 lastTimestamp,
            uint64 ratePerSec,
            uint64 fullUtilizationRate
        );

    function decimals() external view returns (uint8);

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);

    function deposit(uint256 _amount, address _receiver) external returns (uint256 _sharesReceived);

    function dirtyLiquidationFee() external view returns (uint256);

    function exchangeRateInfo() external view returns (address oracle, uint32 maxOracleDeviation, uint184 lastTimestamp, uint256 lowExchangeRate, uint256 highExchangeRate);

    function getConstants()
        external
        pure
        returns (
            uint256 _LTV_PRECISION,
            uint256 _LIQ_PRECISION,
            uint256 _UTIL_PREC,
            uint256 _FEE_PRECISION,
            uint256 _EXCHANGE_PRECISION,
            uint256 _DEVIATION_PRECISION,
            uint256 _RATE_PRECISION,
            uint256 _MAX_PROTOCOL_FEE
        );

    function getImmutableAddressBool()
        external
        view
        returns (
            address _assetContract,
            address _collateralContract,
            address _oracleMultiply,
            address _oracleDivide,
            address _rateContract,
            address _DEPLOYER_CONTRACT,
            address _COMPTROLLER_ADDRESS,
            address _FRAXLEND_WHITELIST,
            bool _borrowerWhitelistActive,
            bool _lenderWhitelistActive
        );

    function getImmutableUint256()
        external
        view
        returns (
            uint256 _oracleNormalization,
            uint256 _maxLTV,
            uint256 _cleanLiquidationFee,
            uint256 _maturityDate,
            uint256 _penaltyRate
        );

    function getPairAccounting()
        external
        view
        returns (
            uint128 _totalAssetAmount,
            uint128 _totalAssetShares,
            uint128 _totalBorrowAmount,
            uint128 _totalBorrowShares,
            uint256 _totalCollateral
        );

    function getUserSnapshot(
        address _address
    ) external view returns (uint256 _userAssetShares, uint256 _userBorrowShares, uint256 _userCollateralBalance);

    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);

    function lenderWhitelistActive() external view returns (bool);

    function leveragedPosition(
        address _swapperAddress,
        uint256 _borrowAmount,
        uint256 _initialCollateralAmount,
        uint256 _amountCollateralOutMin,
        address[] memory _path
    ) external returns (uint256 _totalCollateralBalance);

    function liquidate(
        uint128 _sharesToLiquidate,
        uint256 _deadline,
        address _borrower
    ) external returns (uint256 _collateralForLiquidator);

    function maturityDate() external view returns (uint256);

    function maxLTV() external view returns (uint256);

    function maxOracleDelay() external view returns (uint256);

    function name() external view returns (string memory);

    function oracleDivide() external view returns (address);

    function oracleMultiply() external view returns (address);

    function oracleNormalization() external view returns (uint256);

    function owner() external view returns (address);

    function pause() external;

    function paused() external view returns (bool);

    function penaltyRate() external view returns (uint256);

    function rateContract() external view returns (address);

    function redeem(uint256 _shares, address _receiver, address _owner) external returns (uint256 _amountToReturn);

    function removeCollateral(uint256 _collateralAmount, address _receiver) external;

    function removeCollateralFrom(
        uint256 _collateralAmount,
        address _receiver,
        address _borrower
    ) external;

    function setWhitelistedDelegators(address _delegator, bool _enabled) external;

    function renounceOwnership() external;

    function repayAsset(uint256 _shares, address _borrower) external returns (uint256 _amountToRepay);

    function repayAssetWithCollateral(
        address _swapperAddress,
        uint256 _collateralToSwap,
        uint256 _amountAssetOutMin,
        address[] memory _path
    ) external returns (uint256 _amountAssetOut);

    function setApprovedBorrowers(address[] memory _borrowers, bool _approval) external;

    function setApprovedLenders(address[] memory _lenders, bool _approval) external;

    function setMaxOracleDelay(uint256 _newDelay) external;

    function setSwapper(address _swapper, bool _approval) external;

    function setTimelock(address _newAddress) external;

    function swappers(address) external view returns (bool);

    function symbol() external view returns (string memory);

    function toAssetAmount(
        uint256 _shares,
        bool _roundUp,
        bool _previewInterest
    ) external view returns (uint256);

    function toAssetShares(
        uint256 _amount,
        bool _roundUp,
        bool _previewInterest
    ) external view returns (uint256);

    function toBorrowAmount(
        uint256 _shares,
        bool _roundUp,
        bool _previewInterest
    ) external view returns (uint256 _amount);

    function toBorrowShares(
        uint256 _amount,
        bool _roundUp,
        bool _previewInterest
    ) external view returns (uint256 _shares);

    function totalAsset() external view returns (uint128 amount, uint128 shares);

    function totalBorrow() external view returns (uint128 amount, uint128 shares);

    function totalCollateral() external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    function transferOwnership(address newOwner) external;

    function unpause() external;

    function updateExchangeRate()
        external
        returns (bool _isBorrowAllowed, uint256 _lowExchangeRate, uint256 _highExchangeRate);

    function userBorrowShares(address) external view returns (uint256);

    function userCollateralBalance(address) external view returns (uint256);

    function version() external pure returns (uint256 _major, uint256 _minor, uint256 _patch);

    function withdrawFees(uint128 _shares, address _recipient) external returns (uint256 _amountToTransfer);

    function isInterestPaused() external view returns (bool);
}

contract SturdySiloStrategy is BaseStrategy {
    using SafeERC20 for ERC20;

    ISturdyPair public immutable pair;

    // Amount of deposits we need before depositing
    uint256 public immutable depositThreshold;
    // Bool if we have met the depositThreshold
    bool public thresholdMet;

    // Timestamp of when withdraws will be enabled
    uint256 public timeToUnlock;
    // If the timeToUnlock is still able to be set. (false == can still be set.)
    bool public freezeTimeToUnlock;

    constructor(
        address _asset,
        address _pair,
        string memory _name,
        uint256 _depositThreshold,
        uint256 _timeToUnlock
    ) BaseStrategy(_asset, _name) {
        // Set pair address
        pair = ISturdyPair(_pair);
        // Set depositThreshold value
        depositThreshold = _depositThreshold;
        // Set initial time to unlock
        timeToUnlock = _timeToUnlock;
        // Approve the pair for FRAX
        ERC20(_asset).safeApprove(address(pair), type(uint256).max);
    }

    /*//////////////////////////////////////////////////////////////
                NEEDED TO BE OVERRIDEN BY STRATEGIST
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Should deploy up to '_amount' of 'asset' in the yield source.
     *
     * This function is called at the end of a {deposit} or {mint}
     * call. Meaning that unless a whitelist is implemented it will
     * be entirely permsionless and thus can be sandwhiched or otherwise
     * manipulated.
     *
     * @param _amount The amount of 'asset' that the strategy should attemppt
     * to deposit in the yield source.
     */
    function _deployFunds(uint256 _amount) internal override {
        // We don't deposit until the threshold is met.
        if (thresholdMet) {
            pair.deposit(_amount, address(this));

            // Amount will include all idle funds if not deposited yet.
        } else if (_amount > depositThreshold) {
            // Set the bool for easy checks in the future.
            thresholdMet = true;
            pair.deposit(_amount, address(this));
        }
    }

    /**
     * @dev Will attempt to free the '_amount' of 'asset'.
     *
     * The amount of 'asset' that is already loose has already
     * been accounted for.
     *
     * This function is called during {withdraw} and {redeem} calls.
     * Meaning that unless a whitelist is implemented it will be
     * entirely permsionless and thus can be sandwhiched or otherwise
     * manipulated.
     *
     * Should not rely on asset.balanceOf(address(this)) calls other than
     * for diff accounting puroposes.
     *
     * Any difference between `_amount` and what is actually freed will be
     * counted as a loss and passed on to the withdrawer. This means
     * care should be taken in times of illiquidity. It may be better to revert
     * if withdraws are simply illiquid so not to realize incorrect losses.
     *
     * @param _amount, The amount of 'asset' to be freed.
     */
    function _freeFunds(uint256 _amount) internal override {
        // Only proccess withdraws if we have unlocked the stratey
        if (block.timestamp >= timeToUnlock) {
            // Accrue interest for conversion.
            pair.addInterest(false);
            pair.redeem(
                pair.toAssetShares(_amount, false, false),
                address(this),
                address(this)
            );
        } else {
            // This should never happen but we check just in case and
            // revert so we don't record an incorrect loss.
            require(false, "Locked!");
        }
    }

    /**
     * @dev Internal function to harvest all rewards, redeploy any idle
     * funds and return an accurate accounting of all funds currently
     * held by the Strategy.
     *
     * This should do any needed harvesting, rewards selling, accrual,
     * redepositing etc. to get the most accurate view of current assets.
     *
     * NOTE: All applicable assets including loose assets should be
     * accounted for in this function.
     *
     * Care should be taken when relying on oracles or swap values rather
     * than actual amounts as all Strategy profit/loss accounting will
     * be done based on this returned value.
     *
     * This can still be called post a shutdown, a strategist can check
     * `TokenizedStrategy.isShutdown()` to decide if funds should be
     * redeployed or simply realize any profits/losses.
     *
     * @return _totalAssets A trusted and accurate account for the total
     * amount of 'asset' the strategy currently holds including idle funds.
     */
    function _harvestAndReport()
        internal
        override
        returns (uint256 _totalAssets)
    {
        // Acccrue interest
        pair.addInterest(false);

        _totalAssets =
            // Return total balance including idle.
            asset.balanceOf(address(this)) +
            pair.toAssetAmount(pair.balanceOf(address(this)), false, false);
    }

    /*//////////////////////////////////////////////////////////////
                    OPTIONAL TO OVERRIDE BY STRATEGIST
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Gets the max amount of `asset` that can be withdrawn.
     * @dev Defaults to an unlimited amount for any address. But can
     * be overriden by strategists.
     *
     * This function will be called before any withdraw or redeem to enforce
     * any limits desired by the strategist. This can be used for illiquid
     * or sandwhichable strategies. It should never be lower than `totalIdle`.
     *
     *   EX:
     *       return TokenIzedStrategy.totalIdle();
     *
     * This does not need to take into account the `_owner`'s share balance
     * or conversion rates from shares to assets.
     *
     * @param . The address that is withdrawing from the strategy.
     * @return . The avialable amount that can be withdrawn in terms of `asset`
     */
    function availableWithdrawLimit(
        address _owner
    ) public view override returns (uint256) {
        // If we have passed the unlock time we have no limit.
        if (block.timestamp >= timeToUnlock) {
            return
                TokenizedStrategy.totalIdle() +
                asset.balanceOf(address(pair));
        } else {
            // Otherwise just the amount of idle can be withdrawn.
            return TokenizedStrategy.totalIdle();
        }
    }

    /**
     * @dev Optional function for a strategist to override that will
     * allow management to manually withdraw deployed funds from the
     * yield source if a strategy is shutdown.
     *
     * This should attempt to free `_amount`, noting that `_amount` may
     * be more than is currently deployed.
     *
     * NOTE: This will not realize any profits or losses. A seperate
     * {report} will be needed in order to record any profit/loss. If
     * a report may need to be called after a shutdown it is important
     * to check if the strategy is shutdown during {_harvestAndReport}
     * so that it does not simply re-deploy all funds that had been freed.
     *
     * EX:
     *   if(freeAsset > 0 && !TokenizedStrategy.isShutdown()) {
     *       depositFunds...
     *    }
     *
     * @param _amount The amount of asset to attempt to free.
     */
    function _emergencyWithdraw(uint256 _amount) internal override {
        pair.addInterest(false);
        // Round up and check against actual balance
        uint256 shares = pair.toAssetShares(_amount, true, false);

        shares = Math.min(shares, pair.balanceOf(address(this)));
        pair.redeem(shares, address(this), address(this));
    }

    // Management can update the unlock time unless it has been frozen.
    function setTimeToUnlock(uint256 _newTime) external onlyManagement {
        require(!freezeTimeToUnlock, "lock frozen");
        timeToUnlock = _newTime;
    }

    // One way switch to freeze the unlock time.
    function freezeUnlock() external onlyManagement {
        freezeTimeToUnlock = true;
    }

    function maxLTV() external view override returns (uint256) {
        return pair.maxLTV();
    }

    function collateral() external view override returns (address) {
        return pair.collateralContract();
    }
}

library SafeCast {
    /**
     * @dev Returns the downcasted uint248 from uint256, reverting on
     * overflow (when the input is greater than largest uint248).
     *
     * Counterpart to Solidity's `uint248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     *
     * _Available since v4.7._
     */
    function toUint248(uint256 value) internal pure returns (uint248) {
        require(value <= type(uint248).max, "SafeCast: value doesn't fit in 248 bits");
        return uint248(value);
    }

    /**
     * @dev Returns the downcasted uint240 from uint256, reverting on
     * overflow (when the input is greater than largest uint240).
     *
     * Counterpart to Solidity's `uint240` operator.
     *
     * Requirements:
     *
     * - input must fit into 240 bits
     *
     * _Available since v4.7._
     */
    function toUint240(uint256 value) internal pure returns (uint240) {
        require(value <= type(uint240).max, "SafeCast: value doesn't fit in 240 bits");
        return uint240(value);
    }

    /**
     * @dev Returns the downcasted uint232 from uint256, reverting on
     * overflow (when the input is greater than largest uint232).
     *
     * Counterpart to Solidity's `uint232` operator.
     *
     * Requirements:
     *
     * - input must fit into 232 bits
     *
     * _Available since v4.7._
     */
    function toUint232(uint256 value) internal pure returns (uint232) {
        require(value <= type(uint232).max, "SafeCast: value doesn't fit in 232 bits");
        return uint232(value);
    }

    /**
     * @dev Returns the downcasted uint224 from uint256, reverting on
     * overflow (when the input is greater than largest uint224).
     *
     * Counterpart to Solidity's `uint224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     *
     * _Available since v4.2._
     */
    function toUint224(uint256 value) internal pure returns (uint224) {
        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }

    /**
     * @dev Returns the downcasted uint216 from uint256, reverting on
     * overflow (when the input is greater than largest uint216).
     *
     * Counterpart to Solidity's `uint216` operator.
     *
     * Requirements:
     *
     * - input must fit into 216 bits
     *
     * _Available since v4.7._
     */
    function toUint216(uint256 value) internal pure returns (uint216) {
        require(value <= type(uint216).max, "SafeCast: value doesn't fit in 216 bits");
        return uint216(value);
    }

    /**
     * @dev Returns the downcasted uint208 from uint256, reverting on
     * overflow (when the input is greater than largest uint208).
     *
     * Counterpart to Solidity's `uint208` operator.
     *
     * Requirements:
     *
     * - input must fit into 208 bits
     *
     * _Available since v4.7._
     */
    function toUint208(uint256 value) internal pure returns (uint208) {
        require(value <= type(uint208).max, "SafeCast: value doesn't fit in 208 bits");
        return uint208(value);
    }

    /**
     * @dev Returns the downcasted uint200 from uint256, reverting on
     * overflow (when the input is greater than largest uint200).
     *
     * Counterpart to Solidity's `uint200` operator.
     *
     * Requirements:
     *
     * - input must fit into 200 bits
     *
     * _Available since v4.7._
     */
    function toUint200(uint256 value) internal pure returns (uint200) {
        require(value <= type(uint200).max, "SafeCast: value doesn't fit in 200 bits");
        return uint200(value);
    }

    /**
     * @dev Returns the downcasted uint192 from uint256, reverting on
     * overflow (when the input is greater than largest uint192).
     *
     * Counterpart to Solidity's `uint192` operator.
     *
     * Requirements:
     *
     * - input must fit into 192 bits
     *
     * _Available since v4.7._
     */
    function toUint192(uint256 value) internal pure returns (uint192) {
        require(value <= type(uint192).max, "SafeCast: value doesn't fit in 192 bits");
        return uint192(value);
    }

    /**
     * @dev Returns the downcasted uint184 from uint256, reverting on
     * overflow (when the input is greater than largest uint184).
     *
     * Counterpart to Solidity's `uint184` operator.
     *
     * Requirements:
     *
     * - input must fit into 184 bits
     *
     * _Available since v4.7._
     */
    function toUint184(uint256 value) internal pure returns (uint184) {
        require(value <= type(uint184).max, "SafeCast: value doesn't fit in 184 bits");
        return uint184(value);
    }

    /**
     * @dev Returns the downcasted uint176 from uint256, reverting on
     * overflow (when the input is greater than largest uint176).
     *
     * Counterpart to Solidity's `uint176` operator.
     *
     * Requirements:
     *
     * - input must fit into 176 bits
     *
     * _Available since v4.7._
     */
    function toUint176(uint256 value) internal pure returns (uint176) {
        require(value <= type(uint176).max, "SafeCast: value doesn't fit in 176 bits");
        return uint176(value);
    }

    /**
     * @dev Returns the downcasted uint168 from uint256, reverting on
     * overflow (when the input is greater than largest uint168).
     *
     * Counterpart to Solidity's `uint168` operator.
     *
     * Requirements:
     *
     * - input must fit into 168 bits
     *
     * _Available since v4.7._
     */
    function toUint168(uint256 value) internal pure returns (uint168) {
        require(value <= type(uint168).max, "SafeCast: value doesn't fit in 168 bits");
        return uint168(value);
    }

    /**
     * @dev Returns the downcasted uint160 from uint256, reverting on
     * overflow (when the input is greater than largest uint160).
     *
     * Counterpart to Solidity's `uint160` operator.
     *
     * Requirements:
     *
     * - input must fit into 160 bits
     *
     * _Available since v4.7._
     */
    function toUint160(uint256 value) internal pure returns (uint160) {
        require(value <= type(uint160).max, "SafeCast: value doesn't fit in 160 bits");
        return uint160(value);
    }

    /**
     * @dev Returns the downcasted uint152 from uint256, reverting on
     * overflow (when the input is greater than largest uint152).
     *
     * Counterpart to Solidity's `uint152` operator.
     *
     * Requirements:
     *
     * - input must fit into 152 bits
     *
     * _Available since v4.7._
     */
    function toUint152(uint256 value) internal pure returns (uint152) {
        require(value <= type(uint152).max, "SafeCast: value doesn't fit in 152 bits");
        return uint152(value);
    }

    /**
     * @dev Returns the downcasted uint144 from uint256, reverting on
     * overflow (when the input is greater than largest uint144).
     *
     * Counterpart to Solidity's `uint144` operator.
     *
     * Requirements:
     *
     * - input must fit into 144 bits
     *
     * _Available since v4.7._
     */
    function toUint144(uint256 value) internal pure returns (uint144) {
        require(value <= type(uint144).max, "SafeCast: value doesn't fit in 144 bits");
        return uint144(value);
    }

    /**
     * @dev Returns the downcasted uint136 from uint256, reverting on
     * overflow (when the input is greater than largest uint136).
     *
     * Counterpart to Solidity's `uint136` operator.
     *
     * Requirements:
     *
     * - input must fit into 136 bits
     *
     * _Available since v4.7._
     */
    function toUint136(uint256 value) internal pure returns (uint136) {
        require(value <= type(uint136).max, "SafeCast: value doesn't fit in 136 bits");
        return uint136(value);
    }

    /**
     * @dev Returns the downcasted uint128 from uint256, reverting on
     * overflow (when the input is greater than largest uint128).
     *
     * Counterpart to Solidity's `uint128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     *
     * _Available since v2.5._
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    /**
     * @dev Returns the downcasted uint120 from uint256, reverting on
     * overflow (when the input is greater than largest uint120).
     *
     * Counterpart to Solidity's `uint120` operator.
     *
     * Requirements:
     *
     * - input must fit into 120 bits
     *
     * _Available since v4.7._
     */
    function toUint120(uint256 value) internal pure returns (uint120) {
        require(value <= type(uint120).max, "SafeCast: value doesn't fit in 120 bits");
        return uint120(value);
    }

    /**
     * @dev Returns the downcasted uint112 from uint256, reverting on
     * overflow (when the input is greater than largest uint112).
     *
     * Counterpart to Solidity's `uint112` operator.
     *
     * Requirements:
     *
     * - input must fit into 112 bits
     *
     * _Available since v4.7._
     */
    function toUint112(uint256 value) internal pure returns (uint112) {
        require(value <= type(uint112).max, "SafeCast: value doesn't fit in 112 bits");
        return uint112(value);
    }

    /**
     * @dev Returns the downcasted uint104 from uint256, reverting on
     * overflow (when the input is greater than largest uint104).
     *
     * Counterpart to Solidity's `uint104` operator.
     *
     * Requirements:
     *
     * - input must fit into 104 bits
     *
     * _Available since v4.7._
     */
    function toUint104(uint256 value) internal pure returns (uint104) {
        require(value <= type(uint104).max, "SafeCast: value doesn't fit in 104 bits");
        return uint104(value);
    }

    /**
     * @dev Returns the downcasted uint96 from uint256, reverting on
     * overflow (when the input is greater than largest uint96).
     *
     * Counterpart to Solidity's `uint96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     *
     * _Available since v4.2._
     */
    function toUint96(uint256 value) internal pure returns (uint96) {
        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }

    /**
     * @dev Returns the downcasted uint88 from uint256, reverting on
     * overflow (when the input is greater than largest uint88).
     *
     * Counterpart to Solidity's `uint88` operator.
     *
     * Requirements:
     *
     * - input must fit into 88 bits
     *
     * _Available since v4.7._
     */
    function toUint88(uint256 value) internal pure returns (uint88) {
        require(value <= type(uint88).max, "SafeCast: value doesn't fit in 88 bits");
        return uint88(value);
    }

    /**
     * @dev Returns the downcasted uint80 from uint256, reverting on
     * overflow (when the input is greater than largest uint80).
     *
     * Counterpart to Solidity's `uint80` operator.
     *
     * Requirements:
     *
     * - input must fit into 80 bits
     *
     * _Available since v4.7._
     */
    function toUint80(uint256 value) internal pure returns (uint80) {
        require(value <= type(uint80).max, "SafeCast: value doesn't fit in 80 bits");
        return uint80(value);
    }

    /**
     * @dev Returns the downcasted uint72 from uint256, reverting on
     * overflow (when the input is greater than largest uint72).
     *
     * Counterpart to Solidity's `uint72` operator.
     *
     * Requirements:
     *
     * - input must fit into 72 bits
     *
     * _Available since v4.7._
     */
    function toUint72(uint256 value) internal pure returns (uint72) {
        require(value <= type(uint72).max, "SafeCast: value doesn't fit in 72 bits");
        return uint72(value);
    }

    /**
     * @dev Returns the downcasted uint64 from uint256, reverting on
     * overflow (when the input is greater than largest uint64).
     *
     * Counterpart to Solidity's `uint64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     *
     * _Available since v2.5._
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    /**
     * @dev Returns the downcasted uint56 from uint256, reverting on
     * overflow (when the input is greater than largest uint56).
     *
     * Counterpart to Solidity's `uint56` operator.
     *
     * Requirements:
     *
     * - input must fit into 56 bits
     *
     * _Available since v4.7._
     */
    function toUint56(uint256 value) internal pure returns (uint56) {
        require(value <= type(uint56).max, "SafeCast: value doesn't fit in 56 bits");
        return uint56(value);
    }

    /**
     * @dev Returns the downcasted uint48 from uint256, reverting on
     * overflow (when the input is greater than largest uint48).
     *
     * Counterpart to Solidity's `uint48` operator.
     *
     * Requirements:
     *
     * - input must fit into 48 bits
     *
     * _Available since v4.7._
     */
    function toUint48(uint256 value) internal pure returns (uint48) {
        require(value <= type(uint48).max, "SafeCast: value doesn't fit in 48 bits");
        return uint48(value);
    }

    /**
     * @dev Returns the downcasted uint40 from uint256, reverting on
     * overflow (when the input is greater than largest uint40).
     *
     * Counterpart to Solidity's `uint40` operator.
     *
     * Requirements:
     *
     * - input must fit into 40 bits
     *
     * _Available since v4.7._
     */
    function toUint40(uint256 value) internal pure returns (uint40) {
        require(value <= type(uint40).max, "SafeCast: value doesn't fit in 40 bits");
        return uint40(value);
    }

    /**
     * @dev Returns the downcasted uint32 from uint256, reverting on
     * overflow (when the input is greater than largest uint32).
     *
     * Counterpart to Solidity's `uint32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     *
     * _Available since v2.5._
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    /**
     * @dev Returns the downcasted uint24 from uint256, reverting on
     * overflow (when the input is greater than largest uint24).
     *
     * Counterpart to Solidity's `uint24` operator.
     *
     * Requirements:
     *
     * - input must fit into 24 bits
     *
     * _Available since v4.7._
     */
    function toUint24(uint256 value) internal pure returns (uint24) {
        require(value <= type(uint24).max, "SafeCast: value doesn't fit in 24 bits");
        return uint24(value);
    }

    /**
     * @dev Returns the downcasted uint16 from uint256, reverting on
     * overflow (when the input is greater than largest uint16).
     *
     * Counterpart to Solidity's `uint16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     *
     * _Available since v2.5._
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    /**
     * @dev Returns the downcasted uint8 from uint256, reverting on
     * overflow (when the input is greater than largest uint8).
     *
     * Counterpart to Solidity's `uint8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits
     *
     * _Available since v2.5._
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     *
     * _Available since v3.0._
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    /**
     * @dev Returns the downcasted int248 from int256, reverting on
     * overflow (when the input is less than smallest int248 or
     * greater than largest int248).
     *
     * Counterpart to Solidity's `int248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     *
     * _Available since v4.7._
     */
    function toInt248(int256 value) internal pure returns (int248 downcasted) {
        downcasted = int248(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 248 bits");
    }

    /**
     * @dev Returns the downcasted int240 from int256, reverting on
     * overflow (when the input is less than smallest int240 or
     * greater than largest int240).
     *
     * Counterpart to Solidity's `int240` operator.
     *
     * Requirements:
     *
     * - input must fit into 240 bits
     *
     * _Available since v4.7._
     */
    function toInt240(int256 value) internal pure returns (int240 downcasted) {
        downcasted = int240(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 240 bits");
    }

    /**
     * @dev Returns the downcasted int232 from int256, reverting on
     * overflow (when the input is less than smallest int232 or
     * greater than largest int232).
     *
     * Counterpart to Solidity's `int232` operator.
     *
     * Requirements:
     *
     * - input must fit into 232 bits
     *
     * _Available since v4.7._
     */
    function toInt232(int256 value) internal pure returns (int232 downcasted) {
        downcasted = int232(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 232 bits");
    }

    /**
     * @dev Returns the downcasted int224 from int256, reverting on
     * overflow (when the input is less than smallest int224 or
     * greater than largest int224).
     *
     * Counterpart to Solidity's `int224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     *
     * _Available since v4.7._
     */
    function toInt224(int256 value) internal pure returns (int224 downcasted) {
        downcasted = int224(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 224 bits");
    }

    /**
     * @dev Returns the downcasted int216 from int256, reverting on
     * overflow (when the input is less than smallest int216 or
     * greater than largest int216).
     *
     * Counterpart to Solidity's `int216` operator.
     *
     * Requirements:
     *
     * - input must fit into 216 bits
     *
     * _Available since v4.7._
     */
    function toInt216(int256 value) internal pure returns (int216 downcasted) {
        downcasted = int216(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 216 bits");
    }

    /**
     * @dev Returns the downcasted int208 from int256, reverting on
     * overflow (when the input is less than smallest int208 or
     * greater than largest int208).
     *
     * Counterpart to Solidity's `int208` operator.
     *
     * Requirements:
     *
     * - input must fit into 208 bits
     *
     * _Available since v4.7._
     */
    function toInt208(int256 value) internal pure returns (int208 downcasted) {
        downcasted = int208(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 208 bits");
    }

    /**
     * @dev Returns the downcasted int200 from int256, reverting on
     * overflow (when the input is less than smallest int200 or
     * greater than largest int200).
     *
     * Counterpart to Solidity's `int200` operator.
     *
     * Requirements:
     *
     * - input must fit into 200 bits
     *
     * _Available since v4.7._
     */
    function toInt200(int256 value) internal pure returns (int200 downcasted) {
        downcasted = int200(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 200 bits");
    }

    /**
     * @dev Returns the downcasted int192 from int256, reverting on
     * overflow (when the input is less than smallest int192 or
     * greater than largest int192).
     *
     * Counterpart to Solidity's `int192` operator.
     *
     * Requirements:
     *
     * - input must fit into 192 bits
     *
     * _Available since v4.7._
     */
    function toInt192(int256 value) internal pure returns (int192 downcasted) {
        downcasted = int192(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 192 bits");
    }

    /**
     * @dev Returns the downcasted int184 from int256, reverting on
     * overflow (when the input is less than smallest int184 or
     * greater than largest int184).
     *
     * Counterpart to Solidity's `int184` operator.
     *
     * Requirements:
     *
     * - input must fit into 184 bits
     *
     * _Available since v4.7._
     */
    function toInt184(int256 value) internal pure returns (int184 downcasted) {
        downcasted = int184(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 184 bits");
    }

    /**
     * @dev Returns the downcasted int176 from int256, reverting on
     * overflow (when the input is less than smallest int176 or
     * greater than largest int176).
     *
     * Counterpart to Solidity's `int176` operator.
     *
     * Requirements:
     *
     * - input must fit into 176 bits
     *
     * _Available since v4.7._
     */
    function toInt176(int256 value) internal pure returns (int176 downcasted) {
        downcasted = int176(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 176 bits");
    }

    /**
     * @dev Returns the downcasted int168 from int256, reverting on
     * overflow (when the input is less than smallest int168 or
     * greater than largest int168).
     *
     * Counterpart to Solidity's `int168` operator.
     *
     * Requirements:
     *
     * - input must fit into 168 bits
     *
     * _Available since v4.7._
     */
    function toInt168(int256 value) internal pure returns (int168 downcasted) {
        downcasted = int168(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 168 bits");
    }

    /**
     * @dev Returns the downcasted int160 from int256, reverting on
     * overflow (when the input is less than smallest int160 or
     * greater than largest int160).
     *
     * Counterpart to Solidity's `int160` operator.
     *
     * Requirements:
     *
     * - input must fit into 160 bits
     *
     * _Available since v4.7._
     */
    function toInt160(int256 value) internal pure returns (int160 downcasted) {
        downcasted = int160(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 160 bits");
    }

    /**
     * @dev Returns the downcasted int152 from int256, reverting on
     * overflow (when the input is less than smallest int152 or
     * greater than largest int152).
     *
     * Counterpart to Solidity's `int152` operator.
     *
     * Requirements:
     *
     * - input must fit into 152 bits
     *
     * _Available since v4.7._
     */
    function toInt152(int256 value) internal pure returns (int152 downcasted) {
        downcasted = int152(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 152 bits");
    }

    /**
     * @dev Returns the downcasted int144 from int256, reverting on
     * overflow (when the input is less than smallest int144 or
     * greater than largest int144).
     *
     * Counterpart to Solidity's `int144` operator.
     *
     * Requirements:
     *
     * - input must fit into 144 bits
     *
     * _Available since v4.7._
     */
    function toInt144(int256 value) internal pure returns (int144 downcasted) {
        downcasted = int144(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 144 bits");
    }

    /**
     * @dev Returns the downcasted int136 from int256, reverting on
     * overflow (when the input is less than smallest int136 or
     * greater than largest int136).
     *
     * Counterpart to Solidity's `int136` operator.
     *
     * Requirements:
     *
     * - input must fit into 136 bits
     *
     * _Available since v4.7._
     */
    function toInt136(int256 value) internal pure returns (int136 downcasted) {
        downcasted = int136(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 136 bits");
    }

    /**
     * @dev Returns the downcasted int128 from int256, reverting on
     * overflow (when the input is less than smallest int128 or
     * greater than largest int128).
     *
     * Counterpart to Solidity's `int128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     *
     * _Available since v3.1._
     */
    function toInt128(int256 value) internal pure returns (int128 downcasted) {
        downcasted = int128(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 128 bits");
    }

    /**
     * @dev Returns the downcasted int120 from int256, reverting on
     * overflow (when the input is less than smallest int120 or
     * greater than largest int120).
     *
     * Counterpart to Solidity's `int120` operator.
     *
     * Requirements:
     *
     * - input must fit into 120 bits
     *
     * _Available since v4.7._
     */
    function toInt120(int256 value) internal pure returns (int120 downcasted) {
        downcasted = int120(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 120 bits");
    }

    /**
     * @dev Returns the downcasted int112 from int256, reverting on
     * overflow (when the input is less than smallest int112 or
     * greater than largest int112).
     *
     * Counterpart to Solidity's `int112` operator.
     *
     * Requirements:
     *
     * - input must fit into 112 bits
     *
     * _Available since v4.7._
     */
    function toInt112(int256 value) internal pure returns (int112 downcasted) {
        downcasted = int112(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 112 bits");
    }

    /**
     * @dev Returns the downcasted int104 from int256, reverting on
     * overflow (when the input is less than smallest int104 or
     * greater than largest int104).
     *
     * Counterpart to Solidity's `int104` operator.
     *
     * Requirements:
     *
     * - input must fit into 104 bits
     *
     * _Available since v4.7._
     */
    function toInt104(int256 value) internal pure returns (int104 downcasted) {
        downcasted = int104(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 104 bits");
    }

    /**
     * @dev Returns the downcasted int96 from int256, reverting on
     * overflow (when the input is less than smallest int96 or
     * greater than largest int96).
     *
     * Counterpart to Solidity's `int96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     *
     * _Available since v4.7._
     */
    function toInt96(int256 value) internal pure returns (int96 downcasted) {
        downcasted = int96(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 96 bits");
    }

    /**
     * @dev Returns the downcasted int88 from int256, reverting on
     * overflow (when the input is less than smallest int88 or
     * greater than largest int88).
     *
     * Counterpart to Solidity's `int88` operator.
     *
     * Requirements:
     *
     * - input must fit into 88 bits
     *
     * _Available since v4.7._
     */
    function toInt88(int256 value) internal pure returns (int88 downcasted) {
        downcasted = int88(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 88 bits");
    }

    /**
     * @dev Returns the downcasted int80 from int256, reverting on
     * overflow (when the input is less than smallest int80 or
     * greater than largest int80).
     *
     * Counterpart to Solidity's `int80` operator.
     *
     * Requirements:
     *
     * - input must fit into 80 bits
     *
     * _Available since v4.7._
     */
    function toInt80(int256 value) internal pure returns (int80 downcasted) {
        downcasted = int80(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 80 bits");
    }

    /**
     * @dev Returns the downcasted int72 from int256, reverting on
     * overflow (when the input is less than smallest int72 or
     * greater than largest int72).
     *
     * Counterpart to Solidity's `int72` operator.
     *
     * Requirements:
     *
     * - input must fit into 72 bits
     *
     * _Available since v4.7._
     */
    function toInt72(int256 value) internal pure returns (int72 downcasted) {
        downcasted = int72(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 72 bits");
    }

    /**
     * @dev Returns the downcasted int64 from int256, reverting on
     * overflow (when the input is less than smallest int64 or
     * greater than largest int64).
     *
     * Counterpart to Solidity's `int64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     *
     * _Available since v3.1._
     */
    function toInt64(int256 value) internal pure returns (int64 downcasted) {
        downcasted = int64(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 64 bits");
    }

    /**
     * @dev Returns the downcasted int56 from int256, reverting on
     * overflow (when the input is less than smallest int56 or
     * greater than largest int56).
     *
     * Counterpart to Solidity's `int56` operator.
     *
     * Requirements:
     *
     * - input must fit into 56 bits
     *
     * _Available since v4.7._
     */
    function toInt56(int256 value) internal pure returns (int56 downcasted) {
        downcasted = int56(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 56 bits");
    }

    /**
     * @dev Returns the downcasted int48 from int256, reverting on
     * overflow (when the input is less than smallest int48 or
     * greater than largest int48).
     *
     * Counterpart to Solidity's `int48` operator.
     *
     * Requirements:
     *
     * - input must fit into 48 bits
     *
     * _Available since v4.7._
     */
    function toInt48(int256 value) internal pure returns (int48 downcasted) {
        downcasted = int48(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 48 bits");
    }

    /**
     * @dev Returns the downcasted int40 from int256, reverting on
     * overflow (when the input is less than smallest int40 or
     * greater than largest int40).
     *
     * Counterpart to Solidity's `int40` operator.
     *
     * Requirements:
     *
     * - input must fit into 40 bits
     *
     * _Available since v4.7._
     */
    function toInt40(int256 value) internal pure returns (int40 downcasted) {
        downcasted = int40(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 40 bits");
    }

    /**
     * @dev Returns the downcasted int32 from int256, reverting on
     * overflow (when the input is less than smallest int32 or
     * greater than largest int32).
     *
     * Counterpart to Solidity's `int32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     *
     * _Available since v3.1._
     */
    function toInt32(int256 value) internal pure returns (int32 downcasted) {
        downcasted = int32(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 32 bits");
    }

    /**
     * @dev Returns the downcasted int24 from int256, reverting on
     * overflow (when the input is less than smallest int24 or
     * greater than largest int24).
     *
     * Counterpart to Solidity's `int24` operator.
     *
     * Requirements:
     *
     * - input must fit into 24 bits
     *
     * _Available since v4.7._
     */
    function toInt24(int256 value) internal pure returns (int24 downcasted) {
        downcasted = int24(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 24 bits");
    }

    /**
     * @dev Returns the downcasted int16 from int256, reverting on
     * overflow (when the input is less than smallest int16 or
     * greater than largest int16).
     *
     * Counterpart to Solidity's `int16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     *
     * _Available since v3.1._
     */
    function toInt16(int256 value) internal pure returns (int16 downcasted) {
        downcasted = int16(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 16 bits");
    }

    /**
     * @dev Returns the downcasted int8 from int256, reverting on
     * overflow (when the input is less than smallest int8 or
     * greater than largest int8).
     *
     * Counterpart to Solidity's `int8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits
     *
     * _Available since v3.1._
     */
    function toInt8(int256 value) internal pure returns (int8 downcasted) {
        downcasted = int8(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 8 bits");
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     *
     * _Available since v3.0._
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        // Note: Unsafe cast below is okay because `type(int256).max` is guaranteed to be positive
        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}

abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)
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

abstract contract Ownable2Step is Ownable {
    address private _pendingOwner;

    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Returns the address of the pending owner.
     */
    function pendingOwner() public view virtual returns (address) {
        return _pendingOwner;
    }

    /**
     * @dev Starts the ownership transfer of the contract to a new account. Replaces the pending transfer if there is one.
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual override onlyOwner {
        _pendingOwner = newOwner;
        emit OwnershipTransferStarted(owner(), newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`) and deletes any pending owner.
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual override {
        delete _pendingOwner;
        super._transferOwnership(newOwner);
    }

    /**
     * @dev The new owner accepts the ownership transfer.
     */
    function acceptOwnership() public virtual {
        address sender = _msgSender();
        require(pendingOwner() == sender, "Ownable2Step: caller is not the new owner");
        _transferOwnership(sender);
    }
}

abstract contract Timelock2Step {
    /// @notice The pending timelock address
    address public pendingTimelockAddress;

    /// @notice The current timelock address
    address public timelockAddress;

    constructor() {
        timelockAddress = msg.sender;
    }

    /// @notice Emitted when timelock is transferred
    error OnlyTimelock();

    /// @notice Emitted when pending timelock is transferred
    error OnlyPendingTimelock();

    /// @notice The ```TimelockTransferStarted``` event is emitted when the timelock transfer is initiated
    /// @param previousTimelock The address of the previous timelock
    /// @param newTimelock The address of the new timelock
    event TimelockTransferStarted(address indexed previousTimelock, address indexed newTimelock);

    /// @notice The ```TimelockTransferred``` event is emitted when the timelock transfer is completed
    /// @param previousTimelock The address of the previous timelock
    /// @param newTimelock The address of the new timelock
    event TimelockTransferred(address indexed previousTimelock, address indexed newTimelock);

    /// @notice The ```_isSenderTimelock``` function checks if msg.sender is current timelock address
    /// @return Whether or not msg.sender is current timelock address
    function _isSenderTimelock() internal view returns (bool) {
        return msg.sender == timelockAddress;
    }

    /// @notice The ```_requireTimelock``` function reverts if msg.sender is not current timelock address
    function _requireTimelock() internal view {
        if (msg.sender != timelockAddress) revert OnlyTimelock();
    }

    /// @notice The ```_isSenderPendingTimelock``` function checks if msg.sender is pending timelock address
    /// @return Whether or not msg.sender is pending timelock address
    function _isSenderPendingTimelock() internal view returns (bool) {
        return msg.sender == pendingTimelockAddress;
    }

    /// @notice The ```_requirePendingTimelock``` function reverts if msg.sender is not pending timelock address
    function _requirePendingTimelock() internal view {
        if (msg.sender != pendingTimelockAddress) revert OnlyPendingTimelock();
    }

    /// @notice The ```_transferTimelock``` function initiates the timelock transfer
    /// @dev This function is to be implemented by a public function
    /// @param _newTimelock The address of the nominated (pending) timelock
    function _transferTimelock(address _newTimelock) internal {
        pendingTimelockAddress = _newTimelock;
        emit TimelockTransferStarted(timelockAddress, _newTimelock);
    }

    /// @notice The ```_acceptTransferTimelock``` function completes the timelock transfer
    /// @dev This function is to be implemented by a public function
    function _acceptTransferTimelock() internal {
        pendingTimelockAddress = address(0);
        _setTimelock(msg.sender);
    }

    /// @notice The ```_setTimelock``` function sets the timelock address
    /// @dev This function is to be implemented by a public function
    /// @param _newTimelock The address of the new timelock
    function _setTimelock(address _newTimelock) internal {
        emit TimelockTransferred(timelockAddress, _newTimelock);
        timelockAddress = _newTimelock;
    }

    /// @notice The ```transferTimelock``` function initiates the timelock transfer
    /// @dev Must be called by the current timelock
    /// @param _newTimelock The address of the nominated (pending) timelock
    function transferTimelock(address _newTimelock) external virtual {
        _requireTimelock();
        _transferTimelock(_newTimelock);
    }

    /// @notice The ```acceptTransferTimelock``` function completes the timelock transfer
    /// @dev Must be called by the pending timelock
    function acceptTransferTimelock() external virtual {
        _requirePendingTimelock();
        _acceptTransferTimelock();
    }

    /// @notice The ```renounceTimelock``` function renounces the timelock after setting pending timelock to current timelock
    /// @dev Pending timelock must be set to current timelock before renouncing, creating a 2-step renounce process
    function renounceTimelock() external virtual {
        _requireTimelock();
        _requirePendingTimelock();
        _transferTimelock(address(0));
        _setTimelock(address(0));
    }
}

abstract contract SturdyPairAccessControlErrors {
    error OnlyProtocolOrOwner();
    error OnlyTimelockOrOwner();
    error ExceedsBorrowLimit();
    error AccessControlRevoked();
    error RepayPaused();
    error ExceedsDepositLimit();
    error WithdrawPaused();
    error LiquidatePaused();
    error InterestPaused();
}

abstract contract SturdyPairAccessControl is Timelock2Step, Ownable2Step, SturdyPairAccessControlErrors {
    // Deployer
    address public immutable DEPLOYER_ADDRESS;

    // Admin contracts
    address public circuitBreakerAddress;

    // access control
    uint256 public borrowLimit = type(uint256).max;

    uint256 public depositLimit = type(uint256).max;

    bool public isRepayPaused;
    bool public isRepayAccessControlRevoked;

    bool public isWithdrawPaused;
    bool public isWithdrawAccessControlRevoked;

    bool public isLiquidatePaused;
    bool public isLiquidateAccessControlRevoked;

    bool public isInterestPaused;

    /// @param _immutables abi.encode(address _circuitBreakerAddress, address _comptrollerAddress, address _timelockAddress)
    constructor(bytes memory _immutables) Timelock2Step() Ownable2Step() {
        // Handle Immutables Configuration
        (address _circuitBreakerAddress, address _comptrollerAddress, address _timelockAddress) = abi.decode(
            _immutables,
            (address, address, address)
        );
        _setTimelock(_timelockAddress);
        _transferOwnership(_comptrollerAddress);

        // Deployer contract
        DEPLOYER_ADDRESS = msg.sender;
        circuitBreakerAddress = _circuitBreakerAddress;
    }

    // ============================================================================================
    // Functions: Access Control
    // ============================================================================================

    function _requireProtocolOrOwner() internal view {
        if (
            msg.sender != circuitBreakerAddress &&
            msg.sender != owner() &&
            msg.sender != DEPLOYER_ADDRESS &&
            msg.sender != timelockAddress
        ) {
            revert OnlyProtocolOrOwner();
        }
    }

    function _requireTimelockOrOwner() internal view {
        if (msg.sender != owner() && msg.sender != timelockAddress) {
            revert OnlyTimelockOrOwner();
        }
    }

    /// @notice The ```SetBorrowLimit``` event is emitted when the borrow limit is set
    /// @param limit The new borrow limit
    event SetBorrowLimit(uint256 limit);

    function _setBorrowLimit(uint256 _limit) internal {
        borrowLimit = _limit;
        emit SetBorrowLimit(_limit);
    }

    /// @notice The ```SetDepositLimit``` event is emitted when the deposit limit is set
    /// @param limit The new deposit limit
    event SetDepositLimit(uint256 limit);

    function _setDepositLimit(uint256 _limit) internal {
        depositLimit = _limit;
        emit SetDepositLimit(_limit);
    }

    /// @notice The ```RevokeRepayAccessControl``` event is emitted when repay access control is revoked
    event RevokeRepayAccessControl();

    function _revokeRepayAccessControl() internal {
        isRepayAccessControlRevoked = true;
        emit RevokeRepayAccessControl();
    }

    /// @notice The ```PauseRepay``` event is emitted when repay is paused or unpaused
    /// @param isPaused The new paused state
    event PauseRepay(bool isPaused);

    function _pauseRepay(bool _isPaused) internal {
        isRepayPaused = _isPaused;
        emit PauseRepay(_isPaused);
    }

    /// @notice The ```RevokeWithdrawAccessControl``` event is emitted when withdraw access control is revoked
    event RevokeWithdrawAccessControl();

    function _revokeWithdrawAccessControl() internal {
        isWithdrawAccessControlRevoked = true;
        emit RevokeWithdrawAccessControl();
    }

    /// @notice The ```PauseWithdraw``` event is emitted when withdraw is paused or unpaused
    /// @param isPaused The new paused state
    event PauseWithdraw(bool isPaused);

    function _pauseWithdraw(bool _isPaused) internal {
        isWithdrawPaused = _isPaused;
        emit PauseWithdraw(_isPaused);
    }

    /// @notice The ```RevokeLiquidateAccessControl``` event is emitted when liquidate access control is revoked
    event RevokeLiquidateAccessControl();

    function _revokeLiquidateAccessControl() internal {
        isLiquidateAccessControlRevoked = true;
        emit RevokeLiquidateAccessControl();
    }

    /// @notice The ```PauseLiquidate``` event is emitted when liquidate is paused or unpaused
    /// @param isPaused The new paused state
    event PauseLiquidate(bool isPaused);

    function _pauseLiquidate(bool _isPaused) internal {
        isLiquidatePaused = _isPaused;
        emit PauseLiquidate(_isPaused);
    }

    /// @notice The ```PauseInterest``` event is emitted when interest is paused or unpaused
    /// @param isPaused The new paused state
    event PauseInterest(bool isPaused);

    function _pauseInterest(bool _isPaused) internal {
        isInterestPaused = _isPaused;
        emit PauseInterest(_isPaused);
    }

    /// @notice The ```SetCircuitBreaker``` event is emitted when the circuit breaker address is set
    /// @param oldCircuitBreaker The old circuit breaker address
    /// @param newCircuitBreaker The new circuit breaker address
    event SetCircuitBreaker(address oldCircuitBreaker, address newCircuitBreaker);

    /// @notice The ```_setCircuitBreaker``` function is called to set the circuit breaker address
    /// @param _newCircuitBreaker The new circuit breaker address
    function _setCircuitBreaker(address _newCircuitBreaker) internal {
        address oldCircuitBreaker = circuitBreakerAddress;
        circuitBreakerAddress = _newCircuitBreaker;
        emit SetCircuitBreaker(oldCircuitBreaker, _newCircuitBreaker);
    }

    /// @notice The ```setCircuitBreaker``` function is called to set the circuit breaker address
    /// @param _newCircuitBreaker The new circuit breaker address
    function setCircuitBreaker(address _newCircuitBreaker) external virtual {
        _requireTimelock();
        _setCircuitBreaker(_newCircuitBreaker);
    }
}

abstract contract SturdyPairConstants {
    // ============================================================================================
    // Constants
    // ============================================================================================

    // Precision settings
    uint256 internal constant LTV_PRECISION = 1e5; // 5 decimals
    uint256 internal constant LIQ_PRECISION = 1e5;
    uint256 internal constant UTIL_PREC = 1e5;
    uint256 internal constant FEE_PRECISION = 1e5;
    uint256 internal constant EXCHANGE_PRECISION = 1e18;
    uint256 internal constant DEVIATION_PRECISION = 1e5;
    uint256 internal constant RATE_PRECISION = 1e18;

    // Protocol Fee
    uint256 internal constant MAX_PROTOCOL_FEE = 5e4; // 50% 1e5 precision

    error Insolvent(uint256 _borrow, uint256 _collateral, uint256 _exchangeRate);
    error BorrowerSolvent();
    error InsufficientAssetsInContract(uint256 _assets, uint256 _request);
    error SlippageTooHigh(uint256 _minOut, uint256 _actual);
    error BadSwapper();
    error InvalidPath(address _expected, address _actual);
    error BadProtocolFee();
    error PastDeadline(uint256 _blockTimestamp, uint256 _deadline);
    error SetterRevoked();
    error ExceedsMaxOracleDeviation();
    error InvalidReceiver();
    error InvalidOnBehalfOf();
    error InvalidApproveBorrowDelegation();
    error InvalidBorrower();
    error InvalidDelegator();
}

library VaultAccountingLibrary {
    /// @notice Calculates the shares value in relationship to `amount` and `total`
    /// @dev Given an amount, return the appropriate number of shares
    function toShares(VaultAccount memory total, uint256 amount, bool roundUp) internal pure returns (uint256 shares) {
        if (total.amount == 0) {
            shares = amount;
        } else {
            shares = (amount * total.shares) / total.amount;
            if (roundUp && (shares * total.amount) / total.shares < amount) {
                shares = shares + 1;
            }
        }
    }

    /// @notice Calculates the amount value in relationship to `shares` and `total`
    /// @dev Given a number of shares, returns the appropriate amount
    function toAmount(VaultAccount memory total, uint256 shares, bool roundUp) internal pure returns (uint256 amount) {
        if (total.shares == 0) {
            amount = shares;
        } else {
            amount = (shares * total.amount) / total.shares;
            if (roundUp && (amount * total.shares) / total.amount < shares) {
                amount = amount + 1;
            }
        }
    }
}

library OZSafeERC20 {
    using Address for address;

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance + value));
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance - value));
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeWithSelector(token.approve.selector, spender, value);

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, 0));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Use a ERC-2612 signature to set the `owner` approval toward `spender` on `token`.
     * Revert on invalid signature.
     */
    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        require(returndata.length == 0 || abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silents catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We cannot use {Address-functionCall} here since this should return false
        // and not revert is the subcall reverts.

        (bool success, bytes memory returndata) = address(token).call(data);
        return
            success && (returndata.length == 0 || abi.decode(returndata, (bool))) && Address.isContract(address(token));
    }
}

interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IDualOracle is IERC165 {
    function ORACLE_PRECISION() external view returns (uint256);

    function BASE_TOKEN_0() external view returns (address);

    function BASE_TOKEN_0_DECIMALS() external view returns (uint256);

    function BASE_TOKEN_1() external view returns (address);

    function BASE_TOKEN_1_DECIMALS() external view returns (uint256);

    function decimals() external view returns (uint8);

    function getPricesNormalized() external view returns (bool _isBadData, uint256 _priceLow, uint256 _priceHigh);

    function getPrices() external view returns (bool _isBadData, uint256 _priceLow, uint256 _priceHigh);

    function name() external view returns (string memory);

    function NORMALIZATION_0() external view returns (int256);

    function NORMALIZATION_1() external view returns (int256);

    function QUOTE_TOKEN_0() external view returns (address);

    function QUOTE_TOKEN_0_DECIMALS() external view returns (uint256);

    function QUOTE_TOKEN_1() external view returns (address);

    function QUOTE_TOKEN_1_DECIMALS() external view returns (uint256);
}

interface IRateCalculatorV2 {
    function name() external view returns (string memory);

    function version() external view returns (uint256, uint256, uint256);

    function getNewRate(
        uint256 _deltaTime,
        uint256 _utilization,
        uint64 _maxInterest
    ) external view returns (uint64 _newRatePerSec, uint64 _newMaxInterest);
}

interface ISwapper {
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}

abstract contract SturdyPairCore is SturdyPairAccessControl, SturdyPairConstants, ERC20, ReentrancyGuard {
    using VaultAccountingLibrary for VaultAccount;
    using SafeERC20 for IERC20;
    using SafeCast for uint256;

    function version() external pure returns (uint256 _major, uint256 _minor, uint256 _patch) {
        _major = 3;
        _minor = 0;
        _patch = 0;
    }

    // ============================================================================================
    // Settings set by constructor()
    // ============================================================================================

    // Asset and collateral contracts
    IERC20 internal immutable assetContract;
    IERC20 public immutable collateralContract;

    // LTV Settings
    /// @notice The maximum LTV allowed for this pair
    /// @dev 1e5 precision
    uint256 public maxLTV;

    // Liquidation Fees
    /// @notice The liquidation fee, given as a % of repayment amount, when all collateral is consumed in liquidation
    /// @dev 1e5 precision
    uint256 public cleanLiquidationFee;
    /// @notice The liquidation fee, given as % of repayment amount, when some collateral remains for borrower
    /// @dev 1e5 precision
    uint256 public dirtyLiquidationFee;
    /// @notice The portion of the liquidation fee given to protocol
    /// @dev 1e5 precision
    uint256 public protocolLiquidationFee;

    // Interest Rate Calculator Contract
    IRateCalculatorV2 public rateContract; // For complex rate calculations

    // Swapper
    mapping(address => bool) public swappers; // approved swapper addresses

    // ERC20 Metadata
    string internal nameOfContract;
    string internal symbolOfContract;
    uint8 internal immutable decimalsOfContract;

    // ============================================================================================
    // Storage
    // ============================================================================================

    /// @notice Stores information about the current interest rate
    /// @dev struct is packed to reduce SLOADs. feeToProtocolRate is 1e5 precision, ratePerSec & fullUtilizationRate is 1e18 precision
    CurrentRateInfo public currentRateInfo;

    struct CurrentRateInfo {
        uint32 lastBlock;
        uint32 feeToProtocolRate; // Fee amount 1e5 precision
        uint64 lastTimestamp;
        uint64 ratePerSec;
        uint64 fullUtilizationRate;
    }

    /// @notice Stores information about the current exchange rate. Collateral:Asset ratio
    /// @dev Struct packed to save SLOADs. Amount of Collateral Token to buy 1e18 Asset Token
    ExchangeRateInfo public exchangeRateInfo;

    struct ExchangeRateInfo {
        address oracle;
        uint32 maxOracleDeviation; // % of larger number, 1e5 precision
        uint184 lastTimestamp;
        uint256 lowExchangeRate;
        uint256 highExchangeRate;
    }

    // Contract Level Accounting
    VaultAccount public totalAsset; // amount = total amount of assets, shares = total shares outstanding
    VaultAccount public totalBorrow; // amount = total borrow amount with interest accrued, shares = total shares outstanding
    uint256 public totalCollateral; // total amount of collateral in contract

    // User Level Accounting
    /// @notice Stores the balance of collateral for each user
    mapping(address => uint256) public userCollateralBalance; // amount of collateral each user is backed
    /// @notice Stores the balance of borrow shares for each user
    mapping(address => uint256) public userBorrowShares; // represents the shares held by individuals
    /// @notice Stores the borrow allowance of the user
    mapping(address => mapping(address => uint256)) public userBorrowAllowances;  // represent the borrowable amount on behalfof user
    /// @notice Stores the whitelisted delegators who call the removeCollateralFrom(), ex: Leverage contracts
    mapping(address => bool) public whitelistedDelegators;  // represent the leverage contract who call the removeCollateralFrom()

    // NOTE: user shares of assets are represented as ERC-20 tokens and accessible via balanceOf()

    // ============================================================================================
    // Constructor
    // ============================================================================================

    /// @notice The ```constructor``` function is called on deployment
    /// @param _configData abi.encode(address _asset, address _collateral, address _oracle, uint32 _maxOracleDeviation, address _rateContract, uint64 _fullUtilizationRate, uint256 _maxLTV, uint256 _cleanLiquidationFee, uint256 _dirtyLiquidationFee, uint256 _protocolLiquidationFee)
    /// @param _immutables abi.encode(address _circuitBreakerAddress, address _comptrollerAddress, address _timelockAddress)
    /// @param _customConfigData abi.encode(string memory _nameOfContract, string memory _symbolOfContract, uint8 _decimalsOfContract)
    constructor(
        bytes memory _configData,
        bytes memory _immutables,
        bytes memory _customConfigData
    ) SturdyPairAccessControl(_immutables) ERC20("", "") {
        {
            (
                address _asset,
                address _collateral,
                address _oracle,
                uint32 _maxOracleDeviation,
                address _rateContract,
                uint64 _fullUtilizationRate,
                uint256 _maxLTV,
                uint256 _liquidationFee,
                uint256 _protocolLiquidationFee
            ) = abi.decode(
                    _configData,
                    (address, address, address, uint32, address, uint64, uint256, uint256, uint256)
                );

            // Pair Settings
            assetContract = IERC20(_asset);
            collateralContract = IERC20(_collateral);

            currentRateInfo.feeToProtocolRate = 0;
            currentRateInfo.fullUtilizationRate = _fullUtilizationRate;
            currentRateInfo.lastTimestamp = uint64(block.timestamp - 1);
            currentRateInfo.lastBlock = uint32(block.number - 1);

            exchangeRateInfo.oracle = _oracle;
            exchangeRateInfo.maxOracleDeviation = _maxOracleDeviation;

            rateContract = IRateCalculatorV2(_rateContract);

            //Liquidation Fee Settings
            cleanLiquidationFee = _liquidationFee;
            dirtyLiquidationFee = (_liquidationFee * 90_000) / LIQ_PRECISION; // 90% of clean fee
            protocolLiquidationFee = _protocolLiquidationFee;

            // set maxLTV
            maxLTV = _maxLTV;
        }

        {
            (string memory _nameOfContract, string memory _symbolOfContract, uint8 _decimalsOfContract) = abi.decode(
                _customConfigData,
                (string, string, uint8)
            );

            // ERC20 Metadata
            nameOfContract = _nameOfContract;
            symbolOfContract = _symbolOfContract;
            decimalsOfContract = _decimalsOfContract;

            // Instantiate Interest
            _addInterest();
            // Instantiate Exchange Rate
            _updateExchangeRate();
        }
    }

    // ============================================================================================
    // Internal Helpers
    // ============================================================================================

    /// @notice The ```_totalAssetAvailable``` function returns the total balance of Asset Tokens in the contract
    /// @param _totalAsset VaultAccount struct which stores total amount and shares for assets
    /// @param _totalBorrow VaultAccount struct which stores total amount and shares for borrows
    /// @return The balance of Asset Tokens held by contract
    function _totalAssetAvailable(
        VaultAccount memory _totalAsset,
        VaultAccount memory _totalBorrow
    ) internal pure returns (uint256) {
        return _totalAsset.amount - _totalBorrow.amount;
    }

    /// @notice The ```_isSolvent``` function determines if a given borrower is solvent given an exchange rate
    /// @param _borrower The borrower address to check
    /// @param _exchangeRate The exchange rate, i.e. the amount of collateral to buy 1e18 asset
    /// @return Whether borrower is solvent
    function _isSolvent(address _borrower, uint256 _exchangeRate) internal view returns (bool) {
        if (maxLTV == 0) return true;
        uint256 _borrowerAmount = totalBorrow.toAmount(userBorrowShares[_borrower], true);
        if (_borrowerAmount == 0) return true;
        uint256 _collateralAmount = userCollateralBalance[_borrower];
        if (_collateralAmount == 0) return false;

        uint256 _ltv = (((_borrowerAmount * _exchangeRate) / EXCHANGE_PRECISION) * LTV_PRECISION) / _collateralAmount;
        return _ltv <= maxLTV;
    }

    // ============================================================================================
    // Modifiers
    // ============================================================================================

    /// @notice Checks for solvency AFTER executing contract code
    /// @param _borrower The borrower whose solvency we will check
    modifier isSolvent(address _borrower) {
        _;
        ExchangeRateInfo memory _exchangeRateInfo = exchangeRateInfo;

        if (!_isSolvent(_borrower, exchangeRateInfo.highExchangeRate)) {
            revert Insolvent(
                totalBorrow.toAmount(userBorrowShares[_borrower], true),
                userCollateralBalance[_borrower],
                exchangeRateInfo.highExchangeRate
            );
        }
    }

    // ============================================================================================
    // Functions: Interest Accumulation and Adjustment
    // ============================================================================================

    /// @notice The ```AddInterest``` event is emitted when interest is accrued by borrowers
    /// @param interestEarned The total interest accrued by all borrowers
    /// @param rate The interest rate used to calculate accrued interest
    /// @param feesAmount The amount of fees paid to protocol
    /// @param feesShare The amount of shares distributed to protocol
    event AddInterest(uint256 interestEarned, uint256 rate, uint256 feesAmount, uint256 feesShare);

    /// @notice The ```UpdateRate``` event is emitted when the interest rate is updated
    /// @param oldRatePerSec The old interest rate (per second)
    /// @param oldFullUtilizationRate The old full utilization rate
    /// @param newRatePerSec The new interest rate (per second)
    /// @param newFullUtilizationRate The new full utilization rate
    event UpdateRate(
        uint256 oldRatePerSec,
        uint256 oldFullUtilizationRate,
        uint256 newRatePerSec,
        uint256 newFullUtilizationRate
    );

    /// @notice The ```addInterest``` function is a public implementation of _addInterest and allows 3rd parties to trigger interest accrual
    /// @return _interestEarned The amount of interest accrued by all borrowers
    /// @return _feesAmount The amount of fees paid to protocol
    /// @return _feesShare The amount of shares distributed to protocol
    /// @return _currentRateInfo The new rate info struct
    /// @return _totalAsset The new total asset struct
    /// @return _totalBorrow The new total borrow struct
    function addInterest(
        bool _returnAccounting
    )
        external
        nonReentrant
        returns (
            uint256 _interestEarned,
            uint256 _feesAmount,
            uint256 _feesShare,
            CurrentRateInfo memory _currentRateInfo,
            VaultAccount memory _totalAsset,
            VaultAccount memory _totalBorrow
        )
    {
        (, _interestEarned, _feesAmount, _feesShare, _currentRateInfo) = _addInterest();
        if (_returnAccounting) {
            _totalAsset = totalAsset;
            _totalBorrow = totalBorrow;
        }
    }

    /// @notice The ```previewAddInterest``` function
    /// @return _interestEarned The amount of interest accrued by all borrowers
    /// @return _feesAmount The amount of fees paid to protocol
    /// @return _feesShare The amount of shares distributed to protocol
    /// @return _newCurrentRateInfo The new rate info struct
    /// @return _totalAsset The new total asset struct
    /// @return _totalBorrow The new total borrow struct
    function previewAddInterest()
        public
        view
        returns (
            uint256 _interestEarned,
            uint256 _feesAmount,
            uint256 _feesShare,
            CurrentRateInfo memory _newCurrentRateInfo,
            VaultAccount memory _totalAsset,
            VaultAccount memory _totalBorrow
        )
    {
        _newCurrentRateInfo = currentRateInfo;
        // Write return values
        InterestCalculationResults memory _results = _calculateInterest(_newCurrentRateInfo);

        if (_results.isInterestUpdated) {
            _interestEarned = _results.interestEarned;
            _feesAmount = _results.feesAmount;
            _feesShare = _results.feesShare;

            _newCurrentRateInfo.ratePerSec = _results.newRate;
            _newCurrentRateInfo.fullUtilizationRate = _results.newFullUtilizationRate;

            _totalAsset = _results.totalAsset;
            _totalBorrow = _results.totalBorrow;
        } else {
            _totalAsset = totalAsset;
            _totalBorrow = totalBorrow;
        }
    }

    struct InterestCalculationResults {
        bool isInterestUpdated;
        uint64 newRate;
        uint64 newFullUtilizationRate;
        uint256 interestEarned;
        uint256 feesAmount;
        uint256 feesShare;
        VaultAccount totalAsset;
        VaultAccount totalBorrow;
    }

    /// @notice The ```_calculateInterest``` function calculates the interest to be accrued and the new interest rate info
    /// @param _currentRateInfo The current rate info
    /// @return _results The results of the interest calculation
    function _calculateInterest(
        CurrentRateInfo memory _currentRateInfo
    ) internal view returns (InterestCalculationResults memory _results) {
        // Short circuit if interest already calculated this block OR if interest is paused
        if (_currentRateInfo.lastTimestamp != block.timestamp && !isInterestPaused) {
            // Indicate that interest is updated and calculated
            _results.isInterestUpdated = true;

            // Write return values and use these to save gas
            _results.totalAsset = totalAsset;
            _results.totalBorrow = totalBorrow;

            // Time elapsed since last interest update
            uint256 _deltaTime = block.timestamp - _currentRateInfo.lastTimestamp;

            // Get the utilization rate
            uint256 _utilizationRate = _results.totalAsset.amount == 0
                ? 0
                : (UTIL_PREC * _results.totalBorrow.amount) / _results.totalAsset.amount;

            // Request new interest rate and full utilization rate from the rate calculator
            (_results.newRate, _results.newFullUtilizationRate) = IRateCalculatorV2(rateContract).getNewRate(
                _deltaTime,
                _utilizationRate,
                _currentRateInfo.fullUtilizationRate
            );

            // Calculate interest accrued
            _results.interestEarned = (_deltaTime * _results.totalBorrow.amount * _results.newRate) / RATE_PRECISION;

            // Accrue interest (if any) and fees iff no overflow
            if (
                _results.interestEarned > 0 &&
                _results.interestEarned + _results.totalBorrow.amount <= type(uint128).max &&
                _results.interestEarned + _results.totalAsset.amount <= type(uint128).max
            ) {
                // Increment totalBorrow and totalAsset by interestEarned
                _results.totalBorrow.amount += uint128(_results.interestEarned);
                _results.totalAsset.amount += uint128(_results.interestEarned);
                if (_currentRateInfo.feeToProtocolRate > 0) {
                    _results.feesAmount =
                        (_results.interestEarned * _currentRateInfo.feeToProtocolRate) /
                        FEE_PRECISION;

                    _results.feesShare =
                        (_results.feesAmount * _results.totalAsset.shares) /
                        (_results.totalAsset.amount - _results.feesAmount);

                    // Effects: Give new shares to this contract, effectively diluting lenders an amount equal to the fees
                    // We can safely cast because _feesShare < _feesAmount < interestEarned which is always less than uint128
                    _results.totalAsset.shares += uint128(_results.feesShare);
                }
            }
        }
    }

    /// @notice The ```_addInterest``` function is invoked prior to every external function and is used to accrue interest and update interest rate
    /// @dev Can only called once per block
    /// @return _isInterestUpdated True if interest was calculated
    /// @return _interestEarned The amount of interest accrued by all borrowers
    /// @return _feesAmount The amount of fees paid to protocol
    /// @return _feesShare The amount of shares distributed to protocol
    /// @return _currentRateInfo The new rate info struct
    function _addInterest()
        internal
        returns (
            bool _isInterestUpdated,
            uint256 _interestEarned,
            uint256 _feesAmount,
            uint256 _feesShare,
            CurrentRateInfo memory _currentRateInfo
        )
    {
        // Pull from storage and set default return values
        _currentRateInfo = currentRateInfo;

        // Calc interest
        InterestCalculationResults memory _results = _calculateInterest(_currentRateInfo);

        // Write return values only if interest was updated and calculated
        if (_results.isInterestUpdated) {
            _isInterestUpdated = _results.isInterestUpdated;
            _interestEarned = _results.interestEarned;
            _feesAmount = _results.feesAmount;
            _feesShare = _results.feesShare;

            // emit here so that we have access to the old values
            emit UpdateRate(
                _currentRateInfo.ratePerSec,
                _currentRateInfo.fullUtilizationRate,
                _results.newRate,
                _results.newFullUtilizationRate
            );
            emit AddInterest(_interestEarned, _results.newRate, _feesAmount, _feesShare);

            // overwrite original values
            _currentRateInfo.ratePerSec = _results.newRate;
            _currentRateInfo.fullUtilizationRate = _results.newFullUtilizationRate;
            _currentRateInfo.lastTimestamp = uint64(block.timestamp);
            _currentRateInfo.lastBlock = uint32(block.number);

            // Effects: write to state
            currentRateInfo = _currentRateInfo;
            totalAsset = _results.totalAsset;
            totalBorrow = _results.totalBorrow;
            if (_feesShare > 0) _mint(address(this), _feesShare);
        }
    }

    // ============================================================================================
    // Functions: ExchangeRate
    // ============================================================================================

    /// @notice The ```UpdateExchangeRate``` event is emitted when the Collateral:Asset exchange rate is updated
    /// @param lowExchangeRate The low exchange rate
    /// @param highExchangeRate The high exchange rate
    event UpdateExchangeRate(uint256 lowExchangeRate, uint256 highExchangeRate);

    /// @notice The ```WarnOracleData``` event is emitted when one of the oracles has stale or otherwise problematic data
    /// @param oracle The oracle address
    event WarnOracleData(address oracle);

    /// @notice The ```updateExchangeRate``` function is the external implementation of _updateExchangeRate.
    /// @dev This function is invoked at most once per block as these queries can be expensive
    /// @return _isBorrowAllowed True if deviation is within bounds
    /// @return _lowExchangeRate The low exchange rate
    /// @return _highExchangeRate The high exchange rate
    function updateExchangeRate()
        external
        nonReentrant
        returns (bool _isBorrowAllowed, uint256 _lowExchangeRate, uint256 _highExchangeRate)
    {
        return _updateExchangeRate();
    }

    /// @notice The ```_updateExchangeRate``` function retrieves the latest exchange rate. i.e how much collateral to buy 1e18 asset.
    /// @dev This function is invoked at most once per block as these queries can be expensive
    /// @return _isBorrowAllowed True if deviation is within bounds
    /// @return _lowExchangeRate The low exchange rate
    /// @return _highExchangeRate The high exchange rate

    function _updateExchangeRate()
        internal
        returns (bool _isBorrowAllowed, uint256 _lowExchangeRate, uint256 _highExchangeRate)
    {
        // Pull from storage to save gas and set default return values
        ExchangeRateInfo memory _exchangeRateInfo = exchangeRateInfo;

        // Short circuit if already updated this block
        if (_exchangeRateInfo.lastTimestamp != block.timestamp) {
            // Get the latest exchange rate from the dual oracle
            bool _oneOracleBad;
            (_oneOracleBad, _lowExchangeRate, _highExchangeRate) = IDualOracle(_exchangeRateInfo.oracle).getPrices();

            // If one oracle is bad data, emit an event for off-chain monitoring
            if (_oneOracleBad) emit WarnOracleData(_exchangeRateInfo.oracle);

            // Effects: Bookkeeping and write to storage
            _exchangeRateInfo.lastTimestamp = uint184(block.timestamp);
            _exchangeRateInfo.lowExchangeRate = _lowExchangeRate;
            _exchangeRateInfo.highExchangeRate = _highExchangeRate;
            exchangeRateInfo = _exchangeRateInfo;
            emit UpdateExchangeRate(_lowExchangeRate, _highExchangeRate);
        } else {
            // Use default return values if already updated this block
            _lowExchangeRate = _exchangeRateInfo.lowExchangeRate;
            _highExchangeRate = _exchangeRateInfo.highExchangeRate;
        }

        uint256 _deviation = (DEVIATION_PRECISION *
            (_exchangeRateInfo.highExchangeRate - _exchangeRateInfo.lowExchangeRate)) /
            _exchangeRateInfo.highExchangeRate;
        if (_deviation <= _exchangeRateInfo.maxOracleDeviation) {
            _isBorrowAllowed = true;
        }
    }

    // ============================================================================================
    // Functions: Lending
    // ============================================================================================

    /// @notice The ```Deposit``` event fires when a user deposits assets to the pair
    /// @param caller the msg.sender
    /// @param owner the account the fTokens are sent to
    /// @param assets the amount of assets deposited
    /// @param shares the number of fTokens minted
    event Deposit(address indexed caller, address indexed owner, uint256 assets, uint256 shares);

    /// @notice The ```_deposit``` function is the internal implementation for lending assets
    /// @dev Caller must invoke ```ERC20.approve``` on the Asset Token contract prior to calling function
    /// @param _totalAsset An in memory VaultAccount struct representing the total amounts and shares for the Asset Token
    /// @param _amount The amount of Asset Token to be transferred
    /// @param _shares The amount of Asset Shares (fTokens) to be minted
    /// @param _receiver The address to receive the Asset Shares (fTokens)
    function _deposit(VaultAccount memory _totalAsset, uint128 _amount, uint128 _shares, address _receiver) internal {
        // Effects: bookkeeping
        _totalAsset.amount += _amount;
        _totalAsset.shares += _shares;

        // Effects: write back to storage
        _mint(_receiver, _shares);
        totalAsset = _totalAsset;

        // Interactions
        assetContract.safeTransferFrom(msg.sender, address(this), _amount);
        emit Deposit(msg.sender, _receiver, _amount, _shares);
    }

    function previewDeposit(uint256 _assets) external view returns (uint256 _sharesReceived) {
        (, , , , VaultAccount memory _totalAsset, ) = previewAddInterest();
        _sharesReceived = _totalAsset.toShares(_assets, false);
    }

    /// @notice The ```deposit``` function allows a user to Lend Assets by specifying the amount of Asset Tokens to lend
    /// @dev Caller must invoke ```ERC20.approve``` on the Asset Token contract prior to calling function
    /// @param _amount The amount of Asset Token to transfer to Pair
    /// @param _receiver The address to receive the Asset Shares (fTokens)
    /// @return _sharesReceived The number of fTokens received for the deposit
    function deposit(uint256 _amount, address _receiver) external nonReentrant returns (uint256 _sharesReceived) {
        if (_receiver == address(0)) revert InvalidReceiver();

        // Accrue interest if necessary
        _addInterest();

        // Pull from storage to save gas
        VaultAccount memory _totalAsset = totalAsset;

        // Check if this deposit will violate the deposit limit
        if (depositLimit < _totalAsset.amount + _amount) revert ExceedsDepositLimit();

        // Calculate the number of fTokens to mint
        _sharesReceived = _totalAsset.toShares(_amount, false);

        // Execute the deposit effects
        _deposit(_totalAsset, _amount.toUint128(), _sharesReceived.toUint128(), _receiver);
    }

    function previewMint(uint256 _shares) external view returns (uint256 _amount) {
        (, , , , VaultAccount memory _totalAsset, ) = previewAddInterest();
        _amount = _totalAsset.toAmount(_shares, false);
    }

    function mint(uint256 _shares, address _receiver) external nonReentrant returns (uint256 _amount) {
        if (_receiver == address(0)) revert InvalidReceiver();

        // Accrue interest if necessary
        _addInterest();

        // Pull from storage to save gas
        VaultAccount memory _totalAsset = totalAsset;

        // Calculate the number of assets to transfer based on the shares to mint
        _amount = _totalAsset.toAmount(_shares, false);

        // Check if this deposit will violate the deposit limit
        if (depositLimit < _totalAsset.amount + _amount) revert ExceedsDepositLimit();

        // Execute the deposit effects
        _deposit(_totalAsset, _amount.toUint128(), _shares.toUint128(), _receiver);
    }

    /// @notice The ```Withdraw``` event fires when a user redeems their fTokens for the underlying asset
    /// @param caller the msg.sender
    /// @param receiver The address to which the underlying asset will be transferred to
    /// @param owner The owner of the fTokens
    /// @param assets The assets transferred
    /// @param shares The number of fTokens burned
    event Withdraw(
        address indexed caller,
        address indexed receiver,
        address indexed owner,
        uint256 assets,
        uint256 shares
    );

    /// @notice The ```_redeem``` function is an internal implementation which allows a Lender to pull their Asset Tokens out of the Pair
    /// @dev Caller must invoke ```ERC20.approve``` on the Asset Token contract prior to calling function
    /// @param _totalAsset An in-memory VaultAccount struct which holds the total amount of Asset Tokens and the total number of Asset Shares (fTokens)
    /// @param _amountToReturn The number of Asset Tokens to return
    /// @param _shares The number of Asset Shares (fTokens) to burn
    /// @param _receiver The address to which the Asset Tokens will be transferred
    /// @param _owner The owner of the Asset Shares (fTokens)
    function _redeem(
        VaultAccount memory _totalAsset,
        uint128 _amountToReturn,
        uint128 _shares,
        address _receiver,
        address _owner
    ) internal {
        // Check for sufficient allowance/approval if necessary
        if (msg.sender != _owner) {
            uint256 allowed = allowance(_owner, msg.sender);
            // NOTE: This will revert on underflow ensuring that allowance > shares
            if (allowed != type(uint256).max) _approve(_owner, msg.sender, allowed - _shares);
        }

        // Check for sufficient withdraw liquidity (not strictly necessary because balance will underflow)
        uint256 _assetsAvailable = _totalAssetAvailable(_totalAsset, totalBorrow);
        if (_assetsAvailable < _amountToReturn) {
            revert InsufficientAssetsInContract(_assetsAvailable, _amountToReturn);
        }

        // Effects: bookkeeping
        _totalAsset.amount -= _amountToReturn;
        _totalAsset.shares -= _shares;

        // Effects: write to storage
        totalAsset = _totalAsset;
        _burn(_owner, _shares);

        // Interactions
        assetContract.safeTransfer(_receiver, _amountToReturn);
        emit Withdraw(msg.sender, _receiver, _owner, _amountToReturn, _shares);
    }

    function previewRedeem(uint256 _shares) external view returns (uint256 _assets) {
        (, , , , VaultAccount memory _totalAsset, ) = previewAddInterest();
        _assets = _totalAsset.toAmount(_shares, false);
    }

    /// @notice The ```redeem``` function allows the caller to redeem their Asset Shares for Asset Tokens
    /// @param _shares The number of Asset Shares (fTokens) to burn for Asset Tokens
    /// @param _receiver The address to which the Asset Tokens will be transferred
    /// @param _owner The owner of the Asset Shares (fTokens)
    /// @return _amountToReturn The amount of Asset Tokens to be transferred
    function redeem(
        uint256 _shares,
        address _receiver,
        address _owner
    ) external nonReentrant returns (uint256 _amountToReturn) {
        if (_receiver == address(0)) revert InvalidReceiver();

        // Check if withdraw is paused and revert if necessary
        if (isWithdrawPaused) revert WithdrawPaused();

        // Accrue interest if necessary
        _addInterest();

        // Pull from storage to save gas
        VaultAccount memory _totalAsset = totalAsset;

        // Calculate the number of assets to transfer based on the shares to burn
        _amountToReturn = _totalAsset.toAmount(_shares, false);

        // Execute the withdraw effects
        _redeem(_totalAsset, _amountToReturn.toUint128(), _shares.toUint128(), _receiver, _owner);
    }

    /// @notice The ```previewWithdraw``` function returns the number of Asset Shares (fTokens) that would be burned for a given amount of Asset Tokens
    /// @param _amount The amount of Asset Tokens to be withdrawn
    /// @return _sharesToBurn The number of shares that would be burned
    function previewWithdraw(uint256 _amount) external view returns (uint256 _sharesToBurn) {
        (, , , , VaultAccount memory _totalAsset, ) = previewAddInterest();
        _sharesToBurn = _totalAsset.toShares(_amount, true);
    }

    /// @notice The ```withdraw``` function allows the caller to withdraw their Asset Tokens for a given amount of fTokens
    /// @param _amount The amount to withdraw
    /// @param _receiver The address to which the Asset Tokens will be transferred
    /// @param _owner The owner of the Asset Shares (fTokens)
    /// @return _sharesToBurn The number of shares (fTokens) that were burned
    function withdraw(
        uint256 _amount,
        address _receiver,
        address _owner
    ) external nonReentrant returns (uint256 _sharesToBurn) {
        if (_receiver == address(0)) revert InvalidReceiver();

        // Check if withdraw is paused and revert if necessary
        if (isWithdrawPaused) revert WithdrawPaused();

        // Accrue interest if necessary
        _addInterest();

        // Pull from storage to save gas
        VaultAccount memory _totalAsset = totalAsset;

        // Calculate the number of shares to burn based on the amount to withdraw
        _sharesToBurn = _totalAsset.toShares(_amount, true);

        // Execute the withdraw effects
        _redeem(_totalAsset, _amount.toUint128(), _sharesToBurn.toUint128(), _receiver, _owner);
    }

    // ============================================================================================
    // Functions: Borrowing
    // ============================================================================================

    /// @notice The ```BorrowAsset``` event is emitted when a borrower increases their position
    /// @param _borrower The borrower whose account was debited
    /// @param _receiver The address to which the Asset Tokens were transferred
    /// @param _borrowAmount The amount of Asset Tokens transferred
    /// @param _sharesAdded The number of Borrow Shares the borrower was debited
    event BorrowAsset(
        address indexed _borrower,
        address indexed _receiver,
        uint256 _borrowAmount,
        uint256 _sharesAdded
    );

    /// @notice The ```_borrowAsset``` function is the internal implementation for borrowing assets
    /// @param _borrowAmount The amount of the Asset Token to borrow
    /// @param _receiver The address to receive the Asset Tokens
    /// @return _sharesAdded The amount of borrow shares the msg.sender will be debited
    function _borrowAsset(uint128 _borrowAmount, address _receiver) internal returns (uint256 _sharesAdded) {
        // Get borrow accounting from storage to save gas
        VaultAccount memory _totalBorrow = totalBorrow;

        // Check available capital (not strictly necessary because balance will underflow, but better revert message)
        uint256 _assetsAvailable = _totalAssetAvailable(totalAsset, _totalBorrow);
        if (_assetsAvailable < _borrowAmount) {
            revert InsufficientAssetsInContract(_assetsAvailable, _borrowAmount);
        }

        // Calculate the number of shares to add based on the amount to borrow
        _sharesAdded = _totalBorrow.toShares(_borrowAmount, true);

        // Effects: Bookkeeping to add shares & amounts to total Borrow accounting
        _totalBorrow.amount += _borrowAmount;
        _totalBorrow.shares += uint128(_sharesAdded);
        // NOTE: we can safely cast here because shares are always less than amount and _borrowAmount is uint128

        // Effects: write back to storage
        totalBorrow = _totalBorrow;
        userBorrowShares[msg.sender] += _sharesAdded;

        // Interactions
        if (_receiver != address(this)) {
            assetContract.safeTransfer(_receiver, _borrowAmount);
        }
        emit BorrowAsset(msg.sender, _receiver, _borrowAmount, _sharesAdded);
    }

    /// @notice The ```_borrowAssetOnBehalfOf``` function is the internal implementation for borrowing assets on behalf of borrower
    /// @dev msg.sender will receive the Asset Tokens
    /// @param _borrowAmount The amount of the Asset Token to borrow
    /// @param _onBehalfOf The address which will receive the debt. Should be the address of the borrower itself
    /// @return _sharesAdded The amount of borrow shares the _onBehalfOf will be debited
    function _borrowAssetOnBehalfOf(uint128 _borrowAmount, address _onBehalfOf) internal returns (uint256 _sharesAdded) {
        // Get borrow accounting from storage to save gas
        VaultAccount memory _totalBorrow = totalBorrow;

        // Check available capital (not strictly necessary because balance will underflow, but better revert message)
        uint256 _assetsAvailable = _totalAssetAvailable(totalAsset, _totalBorrow);
        if (_assetsAvailable < _borrowAmount) {
            revert InsufficientAssetsInContract(_assetsAvailable, _borrowAmount);
        }

        // decrease borrowAllowance (borrowing power)
        uint256 newAllowance = userBorrowAllowances[_onBehalfOf][msg.sender] - _borrowAmount;
        userBorrowAllowances[_onBehalfOf][msg.sender] = newAllowance;
        emit UserBorrowAllowanceDelegated(_onBehalfOf, msg.sender, newAllowance);

        // Calculate the number of shares to add based on the amount to borrow
        _sharesAdded = _totalBorrow.toShares(_borrowAmount, true);

        // Effects: Bookkeeping to add shares & amounts to total Borrow accounting
        _totalBorrow.amount += _borrowAmount;
        _totalBorrow.shares += uint128(_sharesAdded);
        // NOTE: we can safely cast here because shares are always less than amount and _borrowAmount is uint128

        // Effects: write back to storage
        totalBorrow = _totalBorrow;
        userBorrowShares[_onBehalfOf] += _sharesAdded;

        // Interactions
        assetContract.safeTransfer(msg.sender, _borrowAmount);

        emit BorrowAsset(_onBehalfOf, msg.sender, _borrowAmount, _sharesAdded);
    }

    /// @notice The ```borrowAsset``` function allows a user to open/increase a borrow position
    /// @dev Borrower must call ```ERC20.approve``` on the Collateral Token contract if applicable
    /// @param _borrowAmount The amount of Asset Token to borrow
    /// @param _collateralAmount The amount of Collateral Token to transfer to Pair
    /// @param _receiver The address which will receive the Asset Tokens
    /// @return _shares The number of borrow Shares the msg.sender will be debited
    function borrowAsset(
        uint256 _borrowAmount,
        uint256 _collateralAmount,
        address _receiver
    ) external nonReentrant isSolvent(msg.sender) returns (uint256 _shares) {
        if (_receiver == address(0)) revert InvalidReceiver();

        // Accrue interest if necessary
        _addInterest();

        // Check if borrow will violate the borrow limit and revert if necessary
        if (borrowLimit < totalBorrow.amount + _borrowAmount) revert ExceedsBorrowLimit();

        // Update _exchangeRate and check if borrow is allowed based on deviation
        (bool _isBorrowAllowed, , ) = _updateExchangeRate();
        if (!_isBorrowAllowed) revert ExceedsMaxOracleDeviation();

        // Only add collateral if necessary
        if (_collateralAmount > 0) {
            _addCollateral(msg.sender, _collateralAmount, msg.sender);
        }

        // Effects: Call internal borrow function
        _shares = _borrowAsset(_borrowAmount.toUint128(), _receiver);
    }

    /// @notice The ```borrowAssetOnBehalfOf``` function allows a user to open/increase a borrow position on behalf of borrower
    /// @dev msg.sender will receive the Asset Tokens
    /// @param _borrowAmount The amount of Asset Token to borrow
    /// @param _onBehalfOf The address which will receive the debt. Should be the address of the borrower itself
    /// @return _shares The number of borrow Shares the _onBehalfOf will be debited
    function borrowAssetOnBehalfOf(
        uint256 _borrowAmount,
        address _onBehalfOf
    ) external nonReentrant isSolvent(_onBehalfOf) returns (uint256 _shares) {
        if (_onBehalfOf == address(0) || msg.sender == _onBehalfOf) revert InvalidOnBehalfOf();

        // Accrue interest if necessary
        _addInterest();

        // Check if borrow will violate the borrow limit and revert if necessary
        if (borrowLimit < totalBorrow.amount + _borrowAmount) revert ExceedsBorrowLimit();

        // Update _exchangeRate and check if borrow is allowed based on deviation
        (bool _isBorrowAllowed, , ) = _updateExchangeRate();
        if (!_isBorrowAllowed) revert ExceedsMaxOracleDeviation();

        // Effects: Call internal borrow function
        _shares = _borrowAssetOnBehalfOf(_borrowAmount.toUint128(), _onBehalfOf);
    }

    /// @notice The ```UserBorrowAllowanceDelegated``` event is emitted when a borrower delegates borrowing power to a user
    /// @param _fromUser The borrower who delegates borrowing power
    /// @param _toUser The user who receive the borrowing power from borrower
    /// @param _amount The max amount being delegated
    event UserBorrowAllowanceDelegated(
        address indexed _fromUser,
        address indexed _toUser,
        uint256 _amount
    );

    /// @notice The ```approveBorrowDelegation``` function delegates borrowing power to a user
    /// @param _delegatee the address receiving the delegated borrowing power
    /// @param _amount the maximum amount being delegated.
    function approveBorrowDelegation(address _delegatee, uint256 _amount) external {
        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling `approveBorrowDelegation(_delegatee, 0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        if ((_amount != 0) && (userBorrowAllowances[msg.sender][_delegatee] != 0)) {
            revert InvalidApproveBorrowDelegation();
        }

        userBorrowAllowances[msg.sender][_delegatee] = _amount;
        emit UserBorrowAllowanceDelegated(msg.sender, _delegatee, _amount);
    }

    /// @notice The ```AddCollateral``` event is emitted when a borrower adds collateral to their position
    /// @param sender The source of funds for the new collateral
    /// @param borrower The borrower account for which the collateral should be credited
    /// @param collateralAmount The amount of Collateral Token to be transferred
    event AddCollateral(address indexed sender, address indexed borrower, uint256 collateralAmount);

    /// @notice The ```_addCollateral``` function is an internal implementation for adding collateral to a borrowers position
    /// @param _sender The source of funds for the new collateral
    /// @param _collateralAmount The amount of Collateral Token to be transferred
    /// @param _borrower The borrower account for which the collateral should be credited
    function _addCollateral(address _sender, uint256 _collateralAmount, address _borrower) internal {
        // Effects: write to state
        userCollateralBalance[_borrower] += _collateralAmount;
        totalCollateral += _collateralAmount;

        // Interactions
        if (_sender != address(this)) {
            collateralContract.safeTransferFrom(_sender, address(this), _collateralAmount);
        }
        emit AddCollateral(_sender, _borrower, _collateralAmount);
    }

    /// @notice The ```addCollateral``` function allows the caller to add Collateral Token to a borrowers position
    /// @dev msg.sender must call ERC20.approve() on the Collateral Token contract prior to invocation
    /// @param _collateralAmount The amount of Collateral Token to be added to borrower's position
    /// @param _borrower The account to be credited
    function addCollateral(uint256 _collateralAmount, address _borrower) external nonReentrant {
        if (_borrower == address(0)) revert InvalidReceiver();

        _addInterest();
        _addCollateral(msg.sender, _collateralAmount, _borrower);
    }

    /// @notice The ```RemoveCollateral``` event is emitted when collateral is removed from a borrower's position
    /// @param _sender The account from which funds are transferred
    /// @param _collateralAmount The amount of Collateral Token to be transferred
    /// @param _receiver The address to which Collateral Tokens will be transferred
    event RemoveCollateral(
        address indexed _sender,
        uint256 _collateralAmount,
        address indexed _receiver,
        address indexed _borrower
    );

    /// @notice The ```_removeCollateral``` function is the internal implementation for removing collateral from a borrower's position
    /// @param _collateralAmount The amount of Collateral Token to remove from the borrower's position
    /// @param _receiver The address to receive the Collateral Token transferred
    /// @param _borrower The borrower whose account will be debited the Collateral amount
    function _removeCollateral(uint256 _collateralAmount, address _receiver, address _borrower) internal {
        // Effects: write to state
        // NOTE: Following line will revert on underflow if _collateralAmount > userCollateralBalance
        userCollateralBalance[_borrower] -= _collateralAmount;
        // NOTE: Following line will revert on underflow if totalCollateral < _collateralAmount
        totalCollateral -= _collateralAmount;

        // Interactions
        if (_receiver != address(this)) {
            collateralContract.safeTransfer(_receiver, _collateralAmount);
        }
        emit RemoveCollateral(msg.sender, _collateralAmount, _receiver, _borrower);
    }

    /// @notice The ```removeCollateral``` function is used to remove collateral from msg.sender's borrow position
    /// @dev msg.sender must be solvent after invocation or transaction will revert
    /// @param _collateralAmount The amount of Collateral Token to transfer
    /// @param _receiver The address to receive the transferred funds
    function removeCollateral(
        uint256 _collateralAmount,
        address _receiver
    ) external nonReentrant isSolvent(msg.sender) {
        if (_receiver == address(0)) revert InvalidReceiver();

        _addInterest();
        // Note: exchange rate is irrelevant when borrower has no debt shares
        if (userBorrowShares[msg.sender] > 0) {
            (bool _isBorrowAllowed, , ) = _updateExchangeRate();
            if (!_isBorrowAllowed) revert ExceedsMaxOracleDeviation();
        }
        _removeCollateral(_collateralAmount, _receiver, msg.sender);
    }

    /// @notice The ```SetWhitelistedDelegators``` event is emitted when admin enable/disable delegator who can call removeCollateralFrom()
    /// @param _delegator the address of contract who can call the removeCollateralFrom()
    /// @param _enabled the enable/disable flag.
    event SetWhitelistedDelegators(
        address indexed _delegator,
        bool _enabled
    );

    /// @notice The ```setWhitelistedDelegators``` function enable/disable the delegators who can call the removeCollateralFrom()
    /// @param _delegator the address of contract who can call the removeCollateralFrom()
    /// @param _enabled the enable/disable flag.
    function setWhitelistedDelegators(address _delegator, bool _enabled) external payable onlyOwner {
        whitelistedDelegators[_delegator] = _enabled;
        emit SetWhitelistedDelegators(_delegator, _enabled);
    }

    /// @notice The ```removeCollateralFrom``` function is used to remove collateral from the borrower
    /// @dev caller must be delegator(ex: leverage contract) and borrower must be solvent after invocation or transaction will revert
    /// @param _collateralAmount The amount of Collateral Token to transfer
    /// @param _receiver The address to receive the transferred funds
    /// @param _borrower The address removing collateral from
    function removeCollateralFrom(
        uint256 _collateralAmount,
        address _receiver,
        address _borrower
    ) external payable nonReentrant isSolvent(_borrower) {
        if(whitelistedDelegators[msg.sender] == false) revert InvalidDelegator();
        if (_receiver == address(0)) revert InvalidReceiver();
        if (_borrower == address(0)) revert InvalidBorrower();

        _addInterest();
        // Note: exchange rate is irrelevant when borrower has no debt shares
        if (userBorrowShares[_borrower] > 0) {
            (bool _isBorrowAllowed, , ) = _updateExchangeRate();
            if (!_isBorrowAllowed) revert ExceedsMaxOracleDeviation();
        }
        _removeCollateral(_collateralAmount, _receiver, _borrower);
    }

    /// @notice The ```RepayAsset``` event is emitted whenever a debt position is repaid
    /// @param payer The address paying for the repayment
    /// @param borrower The borrower whose account will be credited
    /// @param amountToRepay The amount of Asset token to be transferred
    /// @param shares The amount of Borrow Shares which will be debited from the borrower after repayment
    event RepayAsset(address indexed payer, address indexed borrower, uint256 amountToRepay, uint256 shares);

    /// @notice The ```_repayAsset``` function is the internal implementation for repaying a borrow position
    /// @dev The payer must have called ERC20.approve() on the Asset Token contract prior to invocation
    /// @param _totalBorrow An in memory copy of the totalBorrow VaultAccount struct
    /// @param _amountToRepay The amount of Asset Token to transfer
    /// @param _shares The number of Borrow Shares the sender is repaying
    /// @param _payer The address from which funds will be transferred
    /// @param _borrower The borrower account which will be credited
    function _repayAsset(
        VaultAccount memory _totalBorrow,
        uint128 _amountToRepay,
        uint128 _shares,
        address _payer,
        address _borrower
    ) internal {
        // Effects: Bookkeeping
        _totalBorrow.amount -= _amountToRepay;
        _totalBorrow.shares -= _shares;

        // Effects: write to state
        userBorrowShares[_borrower] -= _shares;
        totalBorrow = _totalBorrow;

        // Interactions
        if (_payer != address(this)) {
            assetContract.safeTransferFrom(_payer, address(this), _amountToRepay);
        }
        emit RepayAsset(_payer, _borrower, _amountToRepay, _shares);
    }

    /// @notice The ```repayAsset``` function allows the caller to pay down the debt for a given borrower.
    /// @dev Caller must first invoke ```ERC20.approve()``` for the Asset Token contract
    /// @param _shares The number of Borrow Shares which will be repaid by the call
    /// @param _borrower The account for which the debt will be reduced
    /// @return _amountToRepay The amount of Asset Tokens which were transferred in order to repay the Borrow Shares
    function repayAsset(uint256 _shares, address _borrower) external nonReentrant returns (uint256 _amountToRepay) {
        if (_borrower == address(0)) revert InvalidReceiver();

        // Check if repay is paused revert if necessary
        if (isRepayPaused) revert RepayPaused();

        // Accrue interest if necessary
        _addInterest();

        // Calculate amount to repay based on shares
        VaultAccount memory _totalBorrow = totalBorrow;
        _amountToRepay = _totalBorrow.toAmount(_shares, true);

        // Execute repayment effects
        _repayAsset(_totalBorrow, _amountToRepay.toUint128(), _shares.toUint128(), msg.sender, _borrower);
    }

    // ============================================================================================
    // Functions: Liquidations
    // ============================================================================================
    /// @notice The ```Liquidate``` event is emitted when a liquidation occurs
    /// @param _borrower The borrower account for which the liquidation occurred
    /// @param _collateralForLiquidator The amount of Collateral Token transferred to the liquidator
    /// @param _sharesToLiquidate The number of Borrow Shares the liquidator repaid on behalf of the borrower
    /// @param _sharesToAdjust The number of Borrow Shares that were adjusted on liabilities and assets (a writeoff)
    event Liquidate(
        address indexed _borrower,
        uint256 _collateralForLiquidator,
        uint256 _sharesToLiquidate,
        uint256 _amountLiquidatorToRepay,
        uint256 _feesAmount,
        uint256 _sharesToAdjust,
        uint256 _amountToAdjust
    );

    /// @notice The ```liquidate``` function allows a third party to repay a borrower's debt if they have become insolvent
    /// @dev Caller must invoke ```ERC20.approve``` on the Asset Token contract prior to calling ```Liquidate()```
    /// @param _sharesToLiquidate The number of Borrow Shares repaid by the liquidator
    /// @param _deadline The timestamp after which tx will revert
    /// @param _borrower The account for which the repayment is credited and from whom collateral will be taken
    /// @return _collateralForLiquidator The amount of Collateral Token transferred to the liquidator
    function liquidate(
        uint128 _sharesToLiquidate,
        uint256 _deadline,
        address _borrower
    ) external nonReentrant returns (uint256 _collateralForLiquidator) {
        if (_borrower == address(0)) revert InvalidReceiver();

        // Check if liquidate is paused revert if necessary
        if (isLiquidatePaused) revert LiquidatePaused();

        // Ensure deadline has not passed
        if (block.timestamp > _deadline) revert PastDeadline(block.timestamp, _deadline);

        // accrue interest if necessary
        _addInterest();

        // Update exchange rate and use the lower rate for liquidations
        (, uint256 _exchangeRate, ) = _updateExchangeRate();

        // Check if borrower is solvent, revert if they are
        if (_isSolvent(_borrower, _exchangeRate)) {
            revert BorrowerSolvent();
        }

        // Read from state
        VaultAccount memory _totalBorrow = totalBorrow;
        uint256 _userCollateralBalance = userCollateralBalance[_borrower];
        uint128 _borrowerShares = userBorrowShares[_borrower].toUint128();

        // Prevent stack-too-deep
        int256 _leftoverCollateral;
        uint256 _feesAmount;
        {
            // Checks & Calculations
            // Determine the liquidation amount in collateral units (i.e. how much debt liquidator is going to repay)
            uint256 _liquidationAmountInCollateralUnits = ((_totalBorrow.toAmount(_sharesToLiquidate, false) *
                _exchangeRate) / EXCHANGE_PRECISION);

            // We first optimistically calculate the amount of collateral to give the liquidator based on the higher clean liquidation fee
            // This fee only applies if the liquidator does a full liquidation
            uint256 _optimisticCollateralForLiquidator = (_liquidationAmountInCollateralUnits *
                (LIQ_PRECISION + cleanLiquidationFee)) / LIQ_PRECISION;

            // Because interest accrues every block, _liquidationAmountInCollateralUnits from a few lines up is an ever increasing value
            // This means that leftoverCollateral can occasionally go negative by a few hundred wei (cleanLiqFee premium covers this for liquidator)
            _leftoverCollateral = (_userCollateralBalance.toInt256() - _optimisticCollateralForLiquidator.toInt256());

            // If cleanLiquidation fee results in no leftover collateral, give liquidator all the collateral
            // This will only be true when there liquidator is cleaning out the position
            _collateralForLiquidator = _leftoverCollateral <= 0
                ? _userCollateralBalance
                : (_liquidationAmountInCollateralUnits * (LIQ_PRECISION + dirtyLiquidationFee)) / LIQ_PRECISION;

            if (protocolLiquidationFee > 0) {
                _feesAmount = (protocolLiquidationFee * _collateralForLiquidator) / LIQ_PRECISION;
                _collateralForLiquidator = _collateralForLiquidator - _feesAmount;
            }
        }

        // Calculated here for use during repayment, grouped with other calcs before effects start
        uint128 _amountLiquidatorToRepay = (_totalBorrow.toAmount(_sharesToLiquidate, true)).toUint128();

        // Determine if and how much debt to adjust
        uint128 _sharesToAdjust = 0;
        {
            uint128 _amountToAdjust = 0;
            if (_leftoverCollateral <= 0) {
                // Determine if we need to adjust any shares
                _sharesToAdjust = _borrowerShares - _sharesToLiquidate;
                if (_sharesToAdjust > 0) {
                    // Write off bad debt
                    _amountToAdjust = (_totalBorrow.toAmount(_sharesToAdjust, false)).toUint128();

                    // Note: Ensure this memory struct will be passed to _repayAsset for write to state
                    _totalBorrow.amount -= _amountToAdjust;

                    // Effects: write to state
                    totalAsset.amount -= _amountToAdjust;
                }
            }
            emit Liquidate(
                _borrower,
                _collateralForLiquidator,
                _sharesToLiquidate,
                _amountLiquidatorToRepay,
                _feesAmount,
                _sharesToAdjust,
                _amountToAdjust
            );
        }

        // Effects & Interactions
        // NOTE: reverts if _shares > userBorrowShares
        _repayAsset(
            _totalBorrow,
            _amountLiquidatorToRepay,
            _sharesToLiquidate + _sharesToAdjust,
            msg.sender,
            _borrower
        ); // liquidator repays shares on behalf of borrower
        // NOTE: reverts if _collateralForLiquidator > userCollateralBalance
        // Collateral is removed on behalf of borrower and sent to liquidator
        // NOTE: reverts if _collateralForLiquidator > userCollateralBalance
        _removeCollateral(_collateralForLiquidator, msg.sender, _borrower);
        // Adjust bookkeeping only (decreases collateral held by borrower)
        _removeCollateral(_feesAmount, address(this), _borrower);
        // Adjusts bookkeeping only (increases collateral held by protocol)
        _addCollateral(address(this), _feesAmount, address(this));
    }

    // ============================================================================================
    // Functions: Leverage
    // ============================================================================================

    /// @notice The ```RepayAssetWithCollateral``` event is emitted whenever ```repayAssetWithCollateral()``` is invoked
    /// @param _borrower The borrower account for which the repayment is taking place
    /// @param _swapperAddress The address of the whitelisted swapper to use for token swaps
    /// @param _collateralToSwap The amount of Collateral Token to swap and use for repayment
    /// @param _amountAssetOut The amount of Asset Token which was repaid
    /// @param _sharesRepaid The number of Borrow Shares which were repaid
    event RepayAssetWithCollateral(
        address indexed _borrower,
        address _swapperAddress,
        uint256 _collateralToSwap,
        uint256 _amountAssetOut,
        uint256 _sharesRepaid
    );

    /// @notice The ```repayAssetWithCollateral``` function allows a borrower to repay their debt using existing collateral in contract
    /// @param _swapperAddress The address of the whitelisted swapper to use for token swaps
    /// @param _collateralToSwap The amount of Collateral Tokens to swap for Asset Tokens
    /// @param _amountAssetOutMin The minimum amount of Asset Tokens to receive during the swap
    /// @param _path An array containing the addresses of ERC20 tokens to swap.  Adheres to UniV2 style path params.
    /// @return _amountAssetOut The amount of Asset Tokens received for the Collateral Tokens, the amount the borrowers account was credited
    function repayAssetWithCollateral(
        address _swapperAddress,
        uint256 _collateralToSwap,
        uint256 _amountAssetOutMin,
        address[] calldata _path
    ) external nonReentrant isSolvent(msg.sender) returns (uint256 _amountAssetOut) {
        // Accrue interest if necessary
        _addInterest();

        // Update exchange rate and check if borrow is allowed, revert if not
        (bool _isBorrowAllowed, , ) = _updateExchangeRate();
        if (!_isBorrowAllowed) revert ExceedsMaxOracleDeviation();

        IERC20 _assetContract = assetContract;
        IERC20 _collateralContract = collateralContract;

        if (!swappers[_swapperAddress]) {
            revert BadSwapper();
        }
        if (_path[0] != address(_collateralContract)) {
            revert InvalidPath(address(_collateralContract), _path[0]);
        }
        if (_path[_path.length - 1] != address(_assetContract)) {
            revert InvalidPath(address(_assetContract), _path[_path.length - 1]);
        }

        // Effects: bookkeeping & write to state
        // Debit users collateral balance in preparation for swap, setting _recipient to address(this) means no transfer occurs
        _removeCollateral(_collateralToSwap, address(this), msg.sender);

        // Interactions
        _collateralContract.approve(_swapperAddress, _collateralToSwap);

        // Even though swappers are trusted, we verify the balance before and after swap
        uint256 _initialAssetBalance = _assetContract.balanceOf(address(this));
        ISwapper(_swapperAddress).swapExactTokensForTokens(
            _collateralToSwap,
            _amountAssetOutMin,
            _path,
            address(this),
            block.timestamp
        );
        uint256 _finalAssetBalance = _assetContract.balanceOf(address(this));

        // Note: VIOLATES CHECKS-EFFECTS-INTERACTION pattern, make sure function is NONREENTRANT
        // Effects: bookkeeping
        _amountAssetOut = _finalAssetBalance - _initialAssetBalance;
        if (_amountAssetOut < _amountAssetOutMin) {
            revert SlippageTooHigh(_amountAssetOutMin, _amountAssetOut);
        }

        VaultAccount memory _totalBorrow = totalBorrow;
        uint256 _sharesToRepay = _totalBorrow.toShares(_amountAssetOut, false);

        // Effects: write to state
        // Note: setting _payer to address(this) means no actual transfer will occur.  Contract already has funds
        _repayAsset(_totalBorrow, _amountAssetOut.toUint128(), _sharesToRepay.toUint128(), address(this), msg.sender);

        emit RepayAssetWithCollateral(msg.sender, _swapperAddress, _collateralToSwap, _amountAssetOut, _sharesToRepay);
    }
}

contract SturdyPair is IERC20Metadata, SturdyPairCore {
    using VaultAccountingLibrary for VaultAccount;
    using SafeERC20 for IERC20;
    using SafeCast for uint256;

    /// @param _configData abi.encode(address _asset, address _collateral, address _oracle, uint32 _maxOracleDeviation, address _rateContract, uint64 _fullUtilizationRate, uint256 _maxLTV, uint256 _cleanLiquidationFee, uint256 _dirtyLiquidationFee, uint256 _protocolLiquidationFee)
    /// @param _immutables abi.encode(address _circuitBreakerAddress, address _comptrollerAddress, address _timelockAddress)
    /// @param _customConfigData abi.encode(string memory _nameOfContract, string memory _symbolOfContract, uint8 _decimalsOfContract)
    constructor(
        bytes memory _configData,
        bytes memory _immutables,
        bytes memory _customConfigData
    ) SturdyPairCore(_configData, _immutables, _customConfigData) {}

    // ============================================================================================
    // ERC20 Metadata
    // ============================================================================================

    function name() public view override(ERC20, IERC20Metadata) returns (string memory) {
        return nameOfContract;
    }

    function symbol() public view override(ERC20, IERC20Metadata) returns (string memory) {
        return symbolOfContract;
    }

    function decimals() public view override(ERC20, IERC20Metadata) returns (uint8) {
        return decimalsOfContract;
    }

    // totalSupply for fToken ERC20 compatibility
    function totalSupply() public view override(ERC20, IERC20) returns (uint256) {
        return totalAsset.shares;
    }

    // ============================================================================================
    // Functions: Helpers
    // ============================================================================================

    function asset() external view returns (address) {
        return address(assetContract);
    }

    function getConstants()
        external
        pure
        returns (
            uint256 _LTV_PRECISION,
            uint256 _LIQ_PRECISION,
            uint256 _UTIL_PREC,
            uint256 _FEE_PRECISION,
            uint256 _EXCHANGE_PRECISION,
            uint256 _DEVIATION_PRECISION,
            uint256 _RATE_PRECISION,
            uint256 _MAX_PROTOCOL_FEE
        )
    {
        _LTV_PRECISION = LTV_PRECISION;
        _LIQ_PRECISION = LIQ_PRECISION;
        _UTIL_PREC = UTIL_PREC;
        _FEE_PRECISION = FEE_PRECISION;
        _EXCHANGE_PRECISION = EXCHANGE_PRECISION;
        _DEVIATION_PRECISION = DEVIATION_PRECISION;
        _RATE_PRECISION = RATE_PRECISION;
        _MAX_PROTOCOL_FEE = MAX_PROTOCOL_FEE;
    }

    /// @notice The ```getUserSnapshot``` function gets user level accounting data
    /// @param _address The user address
    /// @return _userAssetShares The user fToken balance
    /// @return _userBorrowShares The user borrow shares
    /// @return _userCollateralBalance The user collateral balance
    function getUserSnapshot(
        address _address
    ) external view returns (uint256 _userAssetShares, uint256 _userBorrowShares, uint256 _userCollateralBalance) {
        _userAssetShares = balanceOf(_address);
        _userBorrowShares = userBorrowShares[_address];
        _userCollateralBalance = userCollateralBalance[_address];
    }

    /// @notice The ```getPairAccounting``` function gets all pair level accounting numbers
    /// @return _totalAssetAmount Total assets deposited and interest accrued, total claims
    /// @return _totalAssetShares Total fTokens
    /// @return _totalBorrowAmount Total borrows
    /// @return _totalBorrowShares Total borrow shares
    /// @return _totalCollateral Total collateral
    function getPairAccounting()
        external
        view
        returns (
            uint128 _totalAssetAmount,
            uint128 _totalAssetShares,
            uint128 _totalBorrowAmount,
            uint128 _totalBorrowShares,
            uint256 _totalCollateral
        )
    {
        (, , , , VaultAccount memory _totalAsset, VaultAccount memory _totalBorrow) = previewAddInterest();
        _totalAssetAmount = _totalAsset.amount;
        _totalAssetShares = _totalAsset.shares;
        _totalBorrowAmount = _totalBorrow.amount;
        _totalBorrowShares = _totalBorrow.shares;
        _totalCollateral = totalCollateral;
    }

    /// @notice The ```toBorrowShares``` function converts a given amount of borrow debt into the number of shares
    /// @param _amount Amount of borrow
    /// @param _roundUp Whether to roundup during division
    /// @param _previewInterest Whether to simulate interest accrual
    /// @return _shares The number of shares
    function toBorrowShares(
        uint256 _amount,
        bool _roundUp,
        bool _previewInterest
    ) external view returns (uint256 _shares) {
        if (_previewInterest) {
            (, , , , , VaultAccount memory _totalBorrow) = previewAddInterest();
            _shares = _totalBorrow.toShares(_amount, _roundUp);
        } else {
            _shares = totalBorrow.toShares(_amount, _roundUp);
        }
    }

    /// @notice The ```toBorrowAmount``` function converts a given amount of borrow debt into the number of shares
    /// @param _shares Shares of borrow
    /// @param _roundUp Whether to roundup during division
    /// @param _previewInterest Whether to simulate interest accrual
    /// @return _amount The amount of asset
    function toBorrowAmount(
        uint256 _shares,
        bool _roundUp,
        bool _previewInterest
    ) external view returns (uint256 _amount) {
        if (_previewInterest) {
            (, , , , , VaultAccount memory _totalBorrow) = previewAddInterest();
            _amount = _totalBorrow.toAmount(_shares, _roundUp);
        } else {
            _amount = totalBorrow.toAmount(_shares, _roundUp);
        }
    }

    /// @notice The ```toAssetAmount``` function converts a given number of shares to an asset amount
    /// @param _shares Shares of asset (fToken)
    /// @param _roundUp Whether to round up after division
    /// @param _previewInterest Whether to preview interest accrual before calculation
    /// @return _amount The amount of asset
    function toAssetAmount(
        uint256 _shares,
        bool _roundUp,
        bool _previewInterest
    ) public view returns (uint256 _amount) {
        if (_previewInterest) {
            (, , , , VaultAccount memory _totalAsset, ) = previewAddInterest();
            _amount = _totalAsset.toAmount(_shares, _roundUp);
        } else {
            _amount = totalAsset.toAmount(_shares, _roundUp);
        }
    }

    /// @notice The ```toAssetShares``` function converts a given asset amount to a number of asset shares (fTokens)
    /// @param _amount The amount of asset
    /// @param _roundUp Whether to round up after division
    /// @param _previewInterest Whether to preview interest accrual before calculation
    /// @return _shares The number of shares (fTokens)
    function toAssetShares(
        uint256 _amount,
        bool _roundUp,
        bool _previewInterest
    ) public view returns (uint256 _shares) {
        if (_previewInterest) {
            (, , , , VaultAccount memory _totalAsset, ) = previewAddInterest();
            _shares = _totalAsset.toShares(_amount, _roundUp);
        } else {
            _shares = totalAsset.toShares(_amount, _roundUp);
        }
    }

    function convertToAssets(uint256 _shares) external view returns (uint256 _assets) {
        _assets = toAssetAmount(_shares, false, true);
    }

    function convertToShares(uint256 _assets) external view returns (uint256 _shares) {
        _shares = toAssetShares(_assets, false, true);
    }

    function pricePerShare() external view returns (uint256 _amount) {
        _amount = toAssetAmount(1e18, false, true);
    }

    function totalAssets() external view returns (uint256) {
        (, , , , VaultAccount memory _totalAsset, ) = previewAddInterest();
        return _totalAsset.amount;
    }

    function maxDeposit(address _receiver) public view returns (uint256 _maxAssets) {
        (, , , , VaultAccount memory _totalAsset, ) = previewAddInterest();
        _maxAssets = _totalAsset.amount >= depositLimit ? 0 : depositLimit - _totalAsset.amount;
    }

    function maxMint(address _receiver) external view returns (uint256 _maxShares) {
        (, , , , VaultAccount memory _totalAsset, ) = previewAddInterest();
        uint256 _maxDeposit = _totalAsset.amount >= depositLimit ? 0 : depositLimit - _totalAsset.amount;
        _maxShares = _totalAsset.toShares(_maxDeposit, false);
    }

    function maxWithdraw(address _owner) external view returns (uint256 _maxAssets) {
        if (isWithdrawPaused) return 0;
        (
            ,
            ,
            uint256 _feesShare,
            ,
            VaultAccount memory _totalAsset,
            VaultAccount memory _totalBorrow
        ) = previewAddInterest();
        // Get the owner balance and include the fees share if owner is this contract
        uint256 _ownerBalance = _owner == address(this) ? balanceOf(_owner) + _feesShare : balanceOf(_owner);

        // Return the lower of total assets in contract or total assets available to _owner
        uint256 _totalAssetsAvailable = _totalAssetAvailable(_totalAsset, _totalBorrow);
        uint256 _totalUserWithdraw = _totalAsset.toAmount(_ownerBalance, false);
        _maxAssets = _totalAssetsAvailable < _totalUserWithdraw ? _totalAssetsAvailable : _totalUserWithdraw;
    }

    function maxRedeem(address _owner) external view returns (uint256 _maxShares) {
        if (isWithdrawPaused) return 0;
        (
            ,
            ,
            uint256 _feesShare,
            ,
            VaultAccount memory _totalAsset,
            VaultAccount memory _totalBorrow
        ) = previewAddInterest();

        // Calculate the total shares available
        uint256 _totalAssetsAvailable = _totalAssetAvailable(_totalAsset, _totalBorrow);
        uint256 _totalSharesAvailable = _totalAsset.toShares(_totalAssetsAvailable, false);

        // Get the owner balance and include the fees share if owner is this contract
        uint256 _ownerBalance = _owner == address(this) ? balanceOf(_owner) + _feesShare : balanceOf(_owner);
        _maxShares = _totalSharesAvailable < _ownerBalance ? _totalSharesAvailable : _ownerBalance;
    }

    // ============================================================================================
    // Functions: Configuration
    // ============================================================================================

    /// @notice The ```SetOracleInfo``` event is emitted when the oracle info (address and max deviation) is set
    /// @param oldOracle The old oracle address
    /// @param oldMaxOracleDeviation The old max oracle deviation
    /// @param newOracle The new oracle address
    /// @param newMaxOracleDeviation The new max oracle deviation
    event SetOracleInfo(
        address oldOracle,
        uint32 oldMaxOracleDeviation,
        address newOracle,
        uint32 newMaxOracleDeviation
    );

    /// @notice The ```setOracleInfo``` function sets the oracle data
    /// @param _newOracle The new oracle address
    /// @param _newMaxOracleDeviation The new max oracle deviation
    function setOracle(address _newOracle, uint32 _newMaxOracleDeviation) external {
        _requireTimelock();
        ExchangeRateInfo memory _exchangeRateInfo = exchangeRateInfo;
        emit SetOracleInfo(
            _exchangeRateInfo.oracle,
            _exchangeRateInfo.maxOracleDeviation,
            _newOracle,
            _newMaxOracleDeviation
        );
        _exchangeRateInfo.oracle = _newOracle;
        _exchangeRateInfo.maxOracleDeviation = _newMaxOracleDeviation;
        exchangeRateInfo = _exchangeRateInfo;
    }

    bool public isMaxLTVSetterRevoked;

    /// @notice The ```RevokeMaxLTVSetter``` event is emitted when the max LTV setter is revoked
    event RevokeMaxLTVSetter();

    /// @notice The ```revokeMaxLTVSetter``` function revokes the max LTV setter
    function revokeMaxLTVSetter() external {
        _requireTimelock();
        isMaxLTVSetterRevoked = true;
        emit RevokeMaxLTVSetter();
    }

    /// @notice The ```SetMaxLTV``` event is emitted when the max LTV is set
    /// @param oldMaxLTV The old max LTV
    /// @param newMaxLTV The new max LTV
    event SetMaxLTV(uint256 oldMaxLTV, uint256 newMaxLTV);

    /// @notice The ```setMaxLTV``` function sets the max LTV
    /// @param _newMaxLTV The new max LTV
    function setMaxLTV(uint256 _newMaxLTV) external {
        _requireTimelock();
        if (isMaxLTVSetterRevoked) revert SetterRevoked();
        emit SetMaxLTV(maxLTV, _newMaxLTV);
        maxLTV = _newMaxLTV;
    }

    /// @notice The ```SetRateContract``` event is emitted when the rate contract is set
    /// @param oldRateContract The old rate contract
    /// @param newRateContract The new rate contract
    event SetRateContract(address oldRateContract, address newRateContract);

    /// @notice The ```setRateContract``` function sets the rate contract address
    /// @param _newRateContract The new rate contract address
    function setRateContract(address _newRateContract) external {
        _requireTimelock();
        emit SetRateContract(address(rateContract), _newRateContract);
        rateContract = IRateCalculatorV2(_newRateContract);
    }

    /// @notice The ```SetLiquidationFees``` event is emitted when the liquidation fees are set
    /// @param oldCleanLiquidationFee The old clean liquidation fee
    /// @param oldDirtyLiquidationFee The old dirty liquidation fee
    /// @param oldProtocolLiquidationFee The old protocol liquidation fee
    /// @param newCleanLiquidationFee The new clean liquidation fee
    /// @param newDirtyLiquidationFee The new dirty liquidation fee
    /// @param newProtocolLiquidationFee The new protocol liquidation fee
    event SetLiquidationFees(
        uint256 oldCleanLiquidationFee,
        uint256 oldDirtyLiquidationFee,
        uint256 oldProtocolLiquidationFee,
        uint256 newCleanLiquidationFee,
        uint256 newDirtyLiquidationFee,
        uint256 newProtocolLiquidationFee
    );

    /// @notice The ```setLiquidationFees``` function sets the liquidation fees
    /// @param _newCleanLiquidationFee The new clean liquidation fee
    /// @param _newDirtyLiquidationFee The new dirty liquidation fee
    function setLiquidationFees(
        uint256 _newCleanLiquidationFee,
        uint256 _newDirtyLiquidationFee,
        uint256 _newProtocolLiquidationFee
    ) external {
        _requireTimelock();
        emit SetLiquidationFees(
            cleanLiquidationFee,
            dirtyLiquidationFee,
            protocolLiquidationFee,
            _newCleanLiquidationFee,
            _newDirtyLiquidationFee,
            _newProtocolLiquidationFee
        );
        cleanLiquidationFee = _newCleanLiquidationFee;
        dirtyLiquidationFee = _newDirtyLiquidationFee;
        protocolLiquidationFee = _newProtocolLiquidationFee;
    }

    /// @notice The ```ChangeFee``` event first when the fee is changed
    /// @param newFee The new fee
    event ChangeFee(uint32 newFee);

    /// @notice The ```changeFee``` function changes the protocol fee, max 50%
    /// @param _newFee The new fee
    function changeFee(uint32 _newFee) external {
        _requireTimelock();
        if (isInterestPaused) revert InterestPaused();
        if (_newFee > MAX_PROTOCOL_FEE) {
            revert BadProtocolFee();
        }
        _addInterest();
        currentRateInfo.feeToProtocolRate = _newFee;
        emit ChangeFee(_newFee);
    }

    /// @notice The ```WithdrawFees``` event fires when the fees are withdrawn
    /// @param shares Number of shares (fTokens) redeemed
    /// @param recipient To whom the assets were sent
    /// @param amountToTransfer The amount of fees redeemed
    event WithdrawFees(uint128 shares, address recipient, uint256 amountToTransfer, uint256 collateralAmount);

    /// @notice The ```withdrawFees``` function withdraws fees accumulated
    /// @param _shares Number of fTokens to redeem
    /// @param _recipient Address to send the assets
    /// @return _amountToTransfer Amount of assets sent to recipient
    function withdrawFees(uint128 _shares, address _recipient) external onlyOwner returns (uint256 _amountToTransfer) {
        if (_recipient == address(0)) revert InvalidReceiver();

        // Grab some data from state to save gas
        VaultAccount memory _totalAsset = totalAsset;

        // Take all available if 0 value passed
        if (_shares == 0) _shares = uint128(balanceOf(address(this)));

        // We must calculate this before we subtract from _totalAsset or invoke _burn
        _amountToTransfer = _totalAsset.toAmount(_shares, true);

        _approve(address(this), msg.sender, _shares);
        _redeem(_totalAsset, _amountToTransfer.toUint128(), _shares, _recipient, address(this));
        uint256 _collateralAmount = userCollateralBalance[address(this)];
        _removeCollateral(_collateralAmount, _recipient, address(this));
        emit WithdrawFees(_shares, _recipient, _amountToTransfer, _collateralAmount);
    }

    /// @notice The ```SetSwapper``` event fires whenever a swapper is black or whitelisted
    /// @param swapper The swapper address
    /// @param approval The approval
    event SetSwapper(address swapper, bool approval);

    /// @notice The ```setSwapper``` function is called to black or whitelist a given swapper address
    /// @dev
    /// @param _swapper The swapper address
    /// @param _approval The approval
    function setSwapper(address _swapper, bool _approval) external onlyOwner {
        swappers[_swapper] = _approval;
        emit SetSwapper(_swapper, _approval);
    }

    // ============================================================================================
    // Functions: Access Control
    // ============================================================================================

    /// @notice The ```pause``` function is called to pause all contract functionality
    function pause() external {
        _requireProtocolOrOwner();

        _setBorrowLimit(0);
        _setDepositLimit(0);
        if (!isRepayAccessControlRevoked) _pauseRepay(true);
        if (!isWithdrawAccessControlRevoked) _pauseWithdraw(true);
        if (!isLiquidateAccessControlRevoked) _pauseLiquidate(true);

        _addInterest();
        _pauseInterest(true);
    }

    /// @notice The ```unpause``` function is called to unpause all contract functionality
    function unpause() external {
        _requireTimelockOrOwner();

        _setBorrowLimit(type(uint256).max);
        _setDepositLimit(type(uint256).max);
        if (!isRepayAccessControlRevoked) _pauseRepay(false);
        if (!isWithdrawAccessControlRevoked) _pauseWithdraw(false);
        if (!isLiquidateAccessControlRevoked) _pauseLiquidate(false);

        _addInterest();
        _pauseInterest(false);
    }

    /// @notice The ```pauseBorrow``` function sets borrow limit to 0
    function pauseBorrow() external {
        _requireProtocolOrOwner();
        _setBorrowLimit(0);
    }

    /// @notice The ```setBorrowLimit``` function sets the borrow limit
    /// @param _limit The new borrow limit
    function setBorrowLimit(uint256 _limit) external {
        _requireTimelockOrOwner();
        _setBorrowLimit(_limit);
    }

    /// @notice The ```pauseDeposit``` function pauses deposit functionality
    function pauseDeposit() external {
        _requireProtocolOrOwner();
        _setDepositLimit(0);
    }

    /// @notice The ```setDepositLimit``` function sets the deposit limit
    /// @param _limit The new deposit limit
    function setDepositLimit(uint256 _limit) external {
        _requireTimelockOrOwner();
        _setDepositLimit(_limit);
    }

    /// @notice The ```pauseRepay``` function pauses repay functionality
    /// @param _isPaused The new pause state
    function pauseRepay(bool _isPaused) external {
        if (_isPaused) {
            _requireProtocolOrOwner();
        } else {
            _requireTimelockOrOwner();
        }
        if (isRepayAccessControlRevoked) revert AccessControlRevoked();
        _pauseRepay(_isPaused);
    }

    /// @notice The ```revokeRepayAccessControl``` function revokes repay access control
    function revokeRepayAccessControl() external {
        _requireTimelock();
        _revokeRepayAccessControl();
    }

    /// @notice The ```pauseWithdraw``` function pauses withdraw functionality
    /// @param _isPaused The new pause state
    function pauseWithdraw(bool _isPaused) external {
        if (_isPaused) {
            _requireProtocolOrOwner();
        } else {
            _requireTimelockOrOwner();
        }
        if (isWithdrawAccessControlRevoked) revert AccessControlRevoked();
        _pauseWithdraw(_isPaused);
    }

    /// @notice The ```revokeWithdrawAccessControl``` function revokes withdraw access control
    function revokeWithdrawAccessControl() external {
        _requireTimelock();
        _revokeWithdrawAccessControl();
    }

    /// @notice The ```pauseLiquidate``` function pauses liquidate functionality
    /// @param _isPaused The new pause state
    function pauseLiquidate(bool _isPaused) external {
        if (_isPaused) {
            _requireProtocolOrOwner();
        } else {
            _requireTimelockOrOwner();
        }
        if (isLiquidateAccessControlRevoked) revert AccessControlRevoked();
        _pauseLiquidate(_isPaused);
    }

    /// @notice The ```revokeLiquidateAccessControl``` function revokes liquidate access control
    function revokeLiquidateAccessControl() external {
        _requireTimelock();
        _revokeLiquidateAccessControl();
    }

    /// @notice The ```pauseInterest``` function pauses interest functionality
    /// @param _isPaused The new pause state
    function pauseInterest(bool _isPaused) external {
        if (_isPaused) {
            _requireProtocolOrOwner();
        } else {
            _requireTimelockOrOwner();
        }
        // Resets the lastTimestamp which has the effect of no interest accruing over the pause period
        _addInterest();
        _pauseInterest(_isPaused);
    }
}

contract AggregatorDataProvider is Ownable, IAggregatorDataProvider {
    // vault addresses
    address[] private _vaults;
    mapping(address => bool) private _vaultFlags;
    // strategy addresses of vault
    mapping(address => address[]) private _strategiesOfVault;
    // all strategy addresses
    address[] private _strategies;
    mapping(address => bool) private _strategyFlags;
    // vault factory address
    address private _factory;

    error AG_CALLER_NOT_ADMIN();

    event AddVault(address vault);
    event RemoveVault(address vault);
    event AddStrategy(address strategy);
    event RemoveStrategy(address strategy);

    modifier onlyAdmin() {
        if (msg.sender != owner() && msg.sender != _factory)
            revert AG_CALLER_NOT_ADMIN();
        _;
    }

    /**
     * @dev Add new vault to list
     * - Caller is owner or factory
     * @param _vault The new vault address
     */
    function addVault(address _vault) external onlyAdmin {
        _addVault(_vault);
    }

    /**
     * @dev Remove the specified vault from the list
     * @param _vault The address of the vault
     */
    function removeVault(address _vault) external onlyAdmin {
        _removeVault(_vault);
    }

    /**
     * @dev Add multiple new vaults to list
     * - Caller is owner or factory
     * @param vaults_ The new vault addresses
     */
    function addVaults(address[] memory vaults_) external onlyAdmin {
        uint256 count = vaults_.length;
        for (uint256 i; i < count; ++i) {
            _addVault(vaults_[i]);
        }
    }

    /**
     * @dev Add new strategy to vault
     * - Caller is owner or factory
     * @param _vault The vault address
     * @param _strategy The strategy address
     */
    function addVaultStrategy(
        address _vault,
        address _strategy
    ) external onlyAdmin {
        _linkStrategyToVault(_vault, _strategy);
    }

    function removeStrategyFromVault(
        address _vault,
        address _strategy
    ) external onlyAdmin {
        _unlinkStrategyFromVault(_vault, _strategy);
    }

    /**
     * @dev Add multiple new strategies to vault
     * - Caller is owner or factory
     * @param _vault The new vault addresse
     * @param strategies_ The new strategy addresses
     */
    function addVaultStrategies(
        address _vault,
        address[] memory strategies_
    ) external onlyAdmin {
        uint256 count = strategies_.length;
        for (uint256 i; i < count; ++i) {
            _addStrategy(strategies_[i]);
            _linkStrategyToVault(_vault, strategies_[i]);
        }
    }

    /**
     * @dev Add new strategy to the list
     * - Caller is owner or factory
     * @param _strategy The new strategy address
     */
    function addStrategy(address _strategy) external onlyAdmin {
        _addStrategy(_strategy);
    }

    /**
     * @dev Remove strategy from the list
     * - Caller is owner or factory
     * @param _strategy The new strategy address
     */
    function removeStrategy(address _strategy) external onlyAdmin {
        _removeStrategy(_strategy);
    }

    /**
     * @dev Add multiple new strategies to list
     * - Caller is owner or factory
     * @param strategies_ The new strategy addresses
     */
    function addStrategies(address[] memory strategies_) external onlyAdmin {
        uint256 count = strategies_.length;
        for (uint256 i; i < count; ++i) {
            _addStrategy(strategies_[i]);
        }
    }

    function _addVault(address _vault) internal {
        if (!_vaultFlags[_vault]) {
            _vaults.push(_vault);
            _vaultFlags[_vault] = true;

            emit AddVault(_vault);
        }
    }

    function _removeVault(address _vault) internal {
        uint256 length = _vaults.length;
        if (_vaultFlags[_vault]) {
            for (uint i = 0; i < length; i++) {
                if (_vault == _vaults[i]) {
                    if (i < length - 1) {
                        _vaults[i] = _vaults[length - 1];
                    }
                    _vaults.pop();
                    break;
                }
            }
            _vaultFlags[_vault] = false;

            emit RemoveVault(_vault);
        }
    }

    function _addStrategy(address _strategy) internal {
        if (!_strategyFlags[_strategy]) {
            _strategies.push(_strategy);
            _strategyFlags[_strategy] = true;

            emit AddStrategy(_strategy);
        }
    }

    function _removeStrategy(address _strategy) internal {
        uint256 length = _strategies.length;
        if (_strategyFlags[_strategy]) {
            for (uint i = 0; i < length; i++) {
                if (_strategy == _strategies[i]) {
                    if (i < length - 1) {
                        _strategies[i] = _strategies[length - 1];
                    }
                    _strategies.pop();
                    break;
                }
            }
            _strategyFlags[_strategy] = false;

            emit RemoveStrategy(_strategy);
        }
    }

    function _linkStrategyToVault(address _vault, address _strategy) internal {
        address[] memory _alreadyLinked = _strategiesOfVault[_vault];
        for (uint256 i = 0; i < _alreadyLinked.length; i++) {
            if (_strategy == _alreadyLinked[i]) {
                return;
            }
        }
        _strategiesOfVault[_vault].push(_strategy);
    }

    function _unlinkStrategyFromVault(
        address _vault,
        address _strategy
    ) internal {
        uint256 length = _strategiesOfVault[_vault].length;
        for (uint i = 0; i < length; i++) {
            if (_strategy == _strategiesOfVault[_vault][i]) {
                if (i < length - 1) {
                    _strategiesOfVault[_vault][i] = _strategiesOfVault[_vault][
                        length - 1
                    ];
                }
                _strategiesOfVault[_vault].pop();
                return;
            }
        }
    }

    /**
     * @dev Set vault factory contract address
     * - Caller is owner
     * @param factory_ The factory contract address
     */
    function setFactory(address factory_) external onlyOwner {
        _factory = factory_;
    }

    /**
     * @dev Get the factory contract address
     * @return the factory contract address
     */
    function getFactory() external view returns (address) {
        return _factory;
    }

    /**
     * @dev Get the vault information
     * @return the detailed information of the vault
     */
    function getVault(
        address _vault
    ) external view returns (AggregatedVaultData memory) {
        bool isValidVault = false;
        for (uint256 i = 0; i < _vaults.length; i++) {
            if (_vaults[i] == _vault) {
                isValidVault = true;
            }
        }

        require(isValidVault, "Invalid Address");

        AggregatedVaultData memory vaultData = _getVaultDetail(_vault);

        return vaultData;
    }

    /**
     * @dev Get the all registered vault list
     * @return the list of vaults
     */
    function getVaults() external view returns (AggregatedVaultData[] memory) {
        AggregatedVaultData[] memory vaultsData = new AggregatedVaultData[](
            _vaults.length
        );

        for (uint256 i = 0; i < _vaults.length; i++) {
            address _vault = _vaults[i];
            vaultsData[i] = _getVaultDetail(_vault);
        }
        return vaultsData;
    }

    function getStrategy(
        address _strategy
    ) external view returns (StrategyData memory) {
        require(_strategyFlags[_strategy], "Invalid Address");

        return _getStrategyDetail(_strategy);
    }

    /**
     * @dev Get the all registered strategy list
     * @return the list of strategy
     */
    function getStrategies() external view returns (StrategyData[] memory) {
        StrategyData[] memory strategiesData = new StrategyData[](
            _strategies.length
        );

        for (uint256 i = 0; i < _strategies.length; i++) {
            address _strategy = _strategies[i];
            strategiesData[i] = _getStrategyDetail(_strategy);
        }

        return strategiesData;
    }

    function getUserPositions(
        address user
    ) external view returns (AggregatedUserData memory) {
        AggregatedUserData memory userData;

        userData.userVaultData = new UserVaultData[](
            user != address(0) ? _vaults.length : 0
        );
        userData.userStrategyData = new UserStrategyData[](
            user != address(0) ? _strategies.length : 0
        );

        if (user != address(0)) {
            for (uint256 i = 0; i < _vaults.length; i++) {
                userData.userVaultData[i].vault = _vaults[i];
                uint256 balance = IVault(_vaults[i]).balanceOf(user);
                userData.userVaultData[i].balance = IVault(_vaults[i])
                    .convertToAssets(balance);
            }
            for (uint256 i = 0; i < _strategies.length; i++) {
                userData.userStrategyData[i].strategy = _strategies[i];

                ISturdyPair pair = SturdySiloStrategy(_strategies[i]).pair();
                (
                    uint256 _assetShares,
                    uint256 _borrowShares,
                    uint256 _collateralBalance
                ) = pair.getUserSnapshot(user);
                userData.userStrategyData[i].assetBalance = pair.toAssetAmount(
                    _assetShares,
                    false,
                    true
                );
                userData.userStrategyData[i].borrowBalance = pair
                    .toBorrowAmount(_borrowShares, true, false);
                userData
                    .userStrategyData[i]
                    .collateralBalance = _collateralBalance;
            }
        }

        return userData;
    }

    function _getVaultDetail(
        address _vault
    ) internal view returns (AggregatedVaultData memory) {
        AggregatedVaultData memory vaultData;

        vaultData.deployedAt = _vault;
        vaultData.isShutdown = IVault(_vault).isShutdown();
        address asset = IVault(_vault).asset();
        vaultData.asset = asset;
        vaultData.assetSymbol = ERC20(asset).symbol();
        vaultData.assetDecimals = ERC20(asset).decimals();        
        vaultData.name = IVault(_vault).name();
        vaultData.totalAssets = IVault(_vault).totalAssets();
        vaultData.totalDebt = IVault(_vault).totalDebt();

        address[] memory _linkedStrategies = _strategiesOfVault[_vault];
        vaultData.vaultStrategyData = new VaultStrategyData[](
            _linkedStrategies.length
        );
        for (uint256 i = 0; i < _linkedStrategies.length; i++) {
            vaultData.vaultStrategyData[i] = _getVaultStrategyDetail(
                _vault,
                _linkedStrategies[i]
            );
        }

        return vaultData;
    }

    function _getVaultStrategyDetail(
        address _vault,
        address _strategy
    ) internal view returns (VaultStrategyData memory) {
        VaultStrategyData memory vaultStrategyData;

        IVault.StrategyParams memory strategy_params = IVault(_vault)
            .strategies(_strategy);
        vaultStrategyData.maxDebt = strategy_params.max_debt;
        vaultStrategyData.currentDebt = strategy_params.current_debt;

        vaultStrategyData.strategyData = _getStrategyDetail(_strategy);

        vaultStrategyData.collateral = vaultStrategyData.strategyData.pairData.collateral;
        vaultStrategyData.collateralSymbol =  vaultStrategyData.strategyData.pairData.collateralSymbol;
        vaultStrategyData.collateralDecimals =  vaultStrategyData.strategyData.pairData.collateralDecimals;

        return vaultStrategyData;
    }

    function _getStrategyDetail(
        address _strategy
    ) internal view returns (StrategyData memory) {
        StrategyData memory strategyData;

        strategyData.deployedAt = _strategy;
        strategyData.pair = address(SturdySiloStrategy(_strategy).pair());

        // Fill pair data
        ISturdyPair pair = SturdySiloStrategy(_strategy).pair();
        address asset = pair.asset();
        strategyData.pairData.asset = asset;
        strategyData.pairData.assetSymbol = ERC20(asset).symbol();
        strategyData.pairData.assetDecimals = ERC20(asset).decimals();
        
        address collateral = pair.collateralContract();
        strategyData.pairData.collateral = collateral;
        strategyData.pairData.collateralSymbol = ERC20(collateral).symbol();
        strategyData.pairData.collateralDecimals = ERC20(collateral).decimals();

        strategyData.pairData.rateContract = pair.rateContract();
        (
            strategyData.pairData.oracle,
            strategyData.pairData.maxOacleDeviation,
            ,
            strategyData.pairData.lowExchangeRate,
            strategyData.pairData.highExchangeRate
        ) = pair.exchangeRateInfo();
        (
            ,
            strategyData.pairData.feeToProtocolRate,
            ,
            strategyData.pairData.ratePerSec,
            strategyData.pairData.fullUtilizationRate
        ) = pair.currentRateInfo();

        strategyData.pairData.maxLTV = pair.maxLTV();

        strategyData.pairData.protocolLiquidationFee = SturdyPair(address(pair))
            .protocolLiquidationFee();
        strategyData.pairData.depositLimit = SturdyPair(address(pair))
            .depositLimit();

        (strategyData.pairData.totalAsset, ) = pair.totalAsset();
        (strategyData.pairData.totalBorrow, ) = pair.totalBorrow();
        strategyData.pairData.totalCollateral = pair.totalCollateral();

        (strategyData.pairData.version, , ) = pair.version();

        return strategyData;
    }
}