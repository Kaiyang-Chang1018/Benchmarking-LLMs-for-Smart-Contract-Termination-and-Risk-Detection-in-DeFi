// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;

// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/ERC20.sol)

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

// OpenZeppelin Contracts (last updated v4.9.4) (utils/Context.sol)

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

// TokenizedStrategy interface used for internal view delegateCalls.

// OpenZeppelin Contracts (last updated v4.9.0) (interfaces/IERC4626.sol)

/**
 * @dev Interface of the ERC4626 "Tokenized Vault Standard", as defined in
 * https://eips.ethereum.org/EIPS/eip-4626[ERC-4626].
 *
 * _Available since v4.7._
 */
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

// OpenZeppelin Contracts (last updated v4.9.4) (token/ERC20/extensions/IERC20Permit.sol)

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 * ==== Security Considerations
 *
 * There are two important considerations concerning the use of `permit`. The first is that a valid permit signature
 * expresses an allowance, and it should not be assumed to convey additional meaning. In particular, it should not be
 * considered as an intention to spend the allowance in any specific way. The second is that because permits have
 * built-in replay protection and can be submitted by anyone, they can be frontrun. A protocol that uses permits should
 * take this into consideration and allow a `permit` call to fail. Combining these two aspects, a pattern that may be
 * generally recommended is:
 *
 * ```solidity
 * function doThingWithPermit(..., uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
 *     try token.permit(msg.sender, address(this), value, deadline, v, r, s) {} catch {}
 *     doThing(..., value);
 * }
 *
 * function doThing(..., uint256 value) public {
 *     token.safeTransferFrom(msg.sender, address(this), value);
 *     ...
 * }
 * ```
 *
 * Observe that: 1) `msg.sender` is used as the owner, leaving no ambiguity as to the signer intent, and 2) the use of
 * `try/catch` allows the permit to fail and makes the code tolerant to frontrunning. (See also
 * {SafeERC20-safeTransferFrom}).
 *
 * Additionally, note that smart contract wallets (such as Argent or Safe) are not able to produce permit signatures, so
 * contracts should have entry points that don't rely on permit.
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
     *
     * CAUTION: See Security Considerations above.
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

// Interface that implements the 4626 standard and the implementation functions
interface ITokenizedStrategy is IERC4626, IERC20Permit {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event StrategyShutdown();

    event NewTokenizedStrategy(
        address indexed strategy,
        address indexed asset,
        string apiVersion
    );

    event Reported(
        uint256 profit,
        uint256 loss,
        uint256 protocolFees,
        uint256 performanceFees
    );

    event UpdatePerformanceFeeRecipient(
        address indexed newPerformanceFeeRecipient
    );

    event UpdateKeeper(address indexed newKeeper);

    event UpdatePerformanceFee(uint16 newPerformanceFee);

    event UpdateManagement(address indexed newManagement);

    event UpdateEmergencyAdmin(address indexed newEmergencyAdmin);

    event UpdateProfitMaxUnlockTime(uint256 newProfitMaxUnlockTime);

    event UpdatePendingManagement(address indexed newPendingManagement);

    /*//////////////////////////////////////////////////////////////
                           INITIALIZATION
    //////////////////////////////////////////////////////////////*/

    function initialize(
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
                        MODIFIER HELPERS
    //////////////////////////////////////////////////////////////*/

    function requireManagement(address _sender) external view;

    function requireKeeperOrManagement(address _sender) external view;

    function requireEmergencyAuthorized(address _sender) external view;

    /*//////////////////////////////////////////////////////////////
                        KEEPERS FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function tend() external;

    function report() external returns (uint256 _profit, uint256 _loss);

    /*//////////////////////////////////////////////////////////////
                        CONSTANTS
    //////////////////////////////////////////////////////////////*/

    function MAX_FEE() external view returns (uint16);

    function FACTORY() external view returns (address);

    /*//////////////////////////////////////////////////////////////
                            GETTERS
    //////////////////////////////////////////////////////////////*/

    function apiVersion() external view returns (string memory);

    function pricePerShare() external view returns (uint256);

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
}

/**
 * @title YearnV3 Base Strategy
 * @author yearn.finance
 * @notice
 *  BaseStrategy implements all of the required functionality to
 *  seamlessly integrate with the `TokenizedStrategy` implementation contract
 *  allowing anyone to easily build a fully permissionless ERC-4626 compliant
 *  Vault by inheriting this contract and overriding three simple functions.

 *  It utilizes an immutable proxy pattern that allows the BaseStrategy
 *  to remain simple and small. All standard logic is held within the
 *  `TokenizedStrategy` and is reused over any n strategies all using the
 *  `fallback` function to delegatecall the implementation so that strategists
 *  can only be concerned with writing their strategy specific code.
 *
 *  This contract should be inherited and the three main abstract methods
 *  `_deployFunds`, `_freeFunds` and `_harvestAndReport` implemented to adapt
 *  the Strategy to the particular needs it has to generate yield. There are
 *  other optional methods that can be implemented to further customize
 *  the strategy if desired.
 *
 *  All default storage for the strategy is controlled and updated by the
 *  `TokenizedStrategy`. The implementation holds a storage struct that
 *  contains all needed global variables in a manual storage slot. This
 *  means strategists can feel free to implement their own custom storage
 *  variables as they need with no concern of collisions. All global variables
 *  can be viewed within the Strategy by a simple call using the
 *  `TokenizedStrategy` variable. IE: TokenizedStrategy.globalVariable();.
 */
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
        TokenizedStrategy.requireManagement(msg.sender);
        _;
    }

    /**
     * @dev Use to assure that the call is coming from either the strategies
     * management or the keeper.
     */
    modifier onlyKeepers() {
        TokenizedStrategy.requireKeeperOrManagement(msg.sender);
        _;
    }

    /**
     * @dev Use to assure that the call is coming from either the strategies
     * management or the emergency admin.
     */
    modifier onlyEmergencyAuthorized() {
        TokenizedStrategy.requireEmergencyAuthorized(msg.sender);
        _;
    }

    /**
     * @dev Require that the msg.sender is this address.
     */
    function _onlySelf() internal view {
        require(msg.sender == address(this), "!self");
    }

    /*//////////////////////////////////////////////////////////////
                            CONSTANTS
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev This is the address of the TokenizedStrategy implementation
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
        0xBB51273D6c746910C7C06fe718f30c936170feD0;

    /*//////////////////////////////////////////////////////////////
                            IMMUTABLES
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Underlying asset the Strategy is earning yield on.
     * Stored here for cheap retrievals within the strategy.
     */
    ERC20 internal immutable asset;

    /**
     * @dev This variable is set to address(this) during initialization of each strategy.
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
                ITokenizedStrategy.initialize,
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
     * @dev Can deploy up to '_amount' of 'asset' in the yield source.
     *
     * This function is called at the end of a {deposit} or {mint}
     * call. Meaning that unless a whitelist is implemented it will
     * be entirely permissionless and thus can be sandwiched or otherwise
     * manipulated.
     *
     * @param _amount The amount of 'asset' that the strategy can attempt
     * to deposit in the yield source.
     */
    function _deployFunds(uint256 _amount) internal virtual;

    /**
     * @dev Should attempt to free the '_amount' of 'asset'.
     *
     * NOTE: The amount of 'asset' that is already loose has already
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
     * This will have no effect on PPS of the strategy till report() is called.
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
     * @notice Can deploy up to '_amount' of 'asset' in yield source.
     * @dev Callback for the TokenizedStrategy to call during a {deposit}
     * or {mint} to tell the strategy it can deploy funds.
     *
     * Since this can only be called after a {deposit} or {mint}
     * delegateCall to the TokenizedStrategy msg.sender == address(this).
     *
     * Unless a whitelist is implemented this will be entirely permissionless
     * and thus can be sandwiched or otherwise manipulated.
     *
     * @param _amount The amount of 'asset' that the strategy can
     * attempt to deposit in the yield source.
     */
    function deployFunds(uint256 _amount) external virtual onlySelf {
        _deployFunds(_amount);
    }

    /**
     * @notice Should attempt to free the '_amount' of 'asset'.
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
     * the TokenizedStrategy.

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
     * calls are forwarded to the TokenizedStrategy.
     *
     * @param _amount The amount of asset to attempt to free.
     */
    function shutdownWithdraw(uint256 _amount) external virtual onlySelf {
        _emergencyWithdraw(_amount);
    }

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

    /**
     * @dev Execute a function on the TokenizedStrategy and return any value.
     *
     * This fallback function will be executed when any of the standard functions
     * defined in the TokenizedStrategy are called since they wont be defined in
     * this contract.
     *
     * It will delegatecall the TokenizedStrategy implementation with the exact
     * calldata and return any relevant values.
     *
     */
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

/**
 *   @title Base Health Check
 *   @author Yearn.finance
 *   @notice This contract can be inherited by any Yearn
 *   V3 strategy wishing to implement a health check during
 *   the `report` function in order to prevent any unexpected
 *   behavior from being permanently recorded as well as the
 *   `checkHealth` modifier.
 *
 *   A strategist simply needs to inherit this contract. Set
 *   the limit ratios to the desired amounts and then
 *   override `_harvestAndReport()` just as they otherwise
 *  would. If the profit or loss that would be recorded is
 *   outside the acceptable bounds the tx will revert.
 *
 *   The healthcheck does not prevent a strategy from reporting
 *   losses, but rather can make sure manual intervention is
 *   needed before reporting an unexpected loss or profit.
 */
abstract contract BaseHealthCheck is BaseStrategy {
    // Can be used to determine if a healthcheck should be called.
    // Defaults to true;
    bool public doHealthCheck = true;

    uint256 internal constant MAX_BPS = 10_000;

    // Default profit limit to 100%.
    uint16 private _profitLimitRatio = uint16(MAX_BPS);

    // Defaults loss limit to 0.
    uint16 private _lossLimitRatio;

    constructor(
        address _asset,
        string memory _name
    ) BaseStrategy(_asset, _name) {}

    /**
     * @notice Returns the current profit limit ratio.
     * @dev Use a getter function to keep the variable private.
     * @return . The current profit limit ratio.
     */
    function profitLimitRatio() public view returns (uint256) {
        return _profitLimitRatio;
    }

    /**
     * @notice Returns the current loss limit ratio.
     * @dev Use a getter function to keep the variable private.
     * @return . The current loss limit ratio.
     */
    function lossLimitRatio() public view returns (uint256) {
        return _lossLimitRatio;
    }

    /**
     * @notice Set the `profitLimitRatio`.
     * @dev Denominated in basis points. I.E. 1_000 == 10%.
     * @param _newProfitLimitRatio The mew profit limit ratio.
     */
    function setProfitLimitRatio(
        uint256 _newProfitLimitRatio
    ) external onlyManagement {
        _setProfitLimitRatio(_newProfitLimitRatio);
    }

    /**
     * @dev Internally set the profit limit ratio. Denominated
     * in basis points. I.E. 1_000 == 10%.
     * @param _newProfitLimitRatio The mew profit limit ratio.
     */
    function _setProfitLimitRatio(uint256 _newProfitLimitRatio) internal {
        require(_newProfitLimitRatio > 0, "!zero profit");
        require(_newProfitLimitRatio <= type(uint16).max, "!too high");
        _profitLimitRatio = uint16(_newProfitLimitRatio);
    }

    /**
     * @notice Set the `lossLimitRatio`.
     * @dev Denominated in basis points. I.E. 1_000 == 10%.
     * @param _newLossLimitRatio The new loss limit ratio.
     */
    function setLossLimitRatio(
        uint256 _newLossLimitRatio
    ) external onlyManagement {
        _setLossLimitRatio(_newLossLimitRatio);
    }

    /**
     * @dev Internally set the loss limit ratio. Denominated
     * in basis points. I.E. 1_000 == 10%.
     * @param _newLossLimitRatio The new loss limit ratio.
     */
    function _setLossLimitRatio(uint256 _newLossLimitRatio) internal {
        require(_newLossLimitRatio < MAX_BPS, "!loss limit");
        _lossLimitRatio = uint16(_newLossLimitRatio);
    }

    /**
     * @notice Turns the healthcheck on and off.
     * @dev If turned off the next report will auto turn it back on.
     * @param _doHealthCheck Bool if healthCheck should be done.
     */
    function setDoHealthCheck(bool _doHealthCheck) public onlyManagement {
        doHealthCheck = _doHealthCheck;
    }

    /**
     * @notice OVerrides the default {harvestAndReport} to include a healthcheck.
     * @return _totalAssets New totalAssets post report.
     */
    function harvestAndReport()
        external
        override
        onlySelf
        returns (uint256 _totalAssets)
    {
        // Let the strategy report.
        _totalAssets = _harvestAndReport();

        // Run the healthcheck on the amount returned.
        _executeHealthCheck(_totalAssets);
    }

    /**
     * @dev To be called during a report to make sure the profit
     * or loss being recorded is within the acceptable bound.
     *
     * @param _newTotalAssets The amount that will be reported.
     */
    function _executeHealthCheck(uint256 _newTotalAssets) internal virtual {
        if (!doHealthCheck) {
            doHealthCheck = true;
            return;
        }

        // Get the current total assets from the implementation.
        uint256 currentTotalAssets = TokenizedStrategy.totalAssets();

        if (_newTotalAssets > currentTotalAssets) {
            require(
                ((_newTotalAssets - currentTotalAssets) <=
                    (currentTotalAssets * uint256(_profitLimitRatio)) /
                        MAX_BPS),
                "healthCheck"
            );
        } else if (currentTotalAssets > _newTotalAssets) {
            require(
                (currentTotalAssets - _newTotalAssets <=
                    ((currentTotalAssets * uint256(_lossLimitRatio)) /
                        MAX_BPS)),
                "healthCheck"
            );
        }
    }
}

// OpenZeppelin Contracts (last updated v4.9.3) (token/ERC20/utils/SafeERC20.sol)

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

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
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

interface IPendleMarket {
    function readTokens() external view returns (address _SY, address _PT, address _YT);
    function swapSyForExactPt(address receiver, uint256 exactPtOut, bytes calldata data) external returns (uint256 netSyIn, uint256 netSyFee);
    function isExpired() external view returns (bool);
}

interface IPendleStaking {
    function masterPenpie() external view returns (address);
    function marketDepositHelper() external view returns (address);
}

interface IMarketDepositHelper {
    function depositMarket(address market, uint256 amount) external;
    function withdrawMarket(address market, uint256 amount) external;
    function withdrawMarketWithClaim(address market, uint256 amount, bool doClaim) external;
    function balance(address market, address user) external view returns (uint256);
}

interface IMasterPenpie {
    function multiclaim(address[] calldata _stakingTokens) external;
}

interface ISY {
    function deposit(
        address receiver,
        address tokenIn,
        uint256 amountTokenToDeposit,
        uint256 minSharesOut) external payable returns (uint256 amountSharesOut);
    
 
    function getTokensIn() external view returns (address[] calldata);
    function redeem(
        address receiver,
        uint256 amountSharesToRedeem,
        address tokenOut,
        uint256 minTokenOut,
        bool burnFromInternalBalance) external payable returns (uint256 amountTokenOut);
    function isValidTokenIn(address) external view returns (bool);
}

interface IPendleRouter {
    struct ApproxParams {
        uint256 guessMin;
        uint256 guessMax;
        uint256 guessOffchain; // pass 0 in to skip this variable
        uint256 maxIteration; // every iteration, the diff between guessMin and guessMax will be divided by 2
        uint256 eps; // the max eps between the returned result & the correct result, base 1e18. Normally this number will be set
        // to 1e15 (1e18/1000 = 0.1%)
    }

    struct LimitOrderData {
        address limitRouter;
        uint256 epsSkipMarket; // only used for swap operations, will be ignored otherwise
        FillOrderParams[] normalFills;
        FillOrderParams[] flashFills;
        bytes optData;
    }

    struct FillOrderParams {
       Order order;
        bytes signature;
        uint256 makingAmount;
    }

    struct Order {
        uint256 salt;
        uint256 expiry;
        uint256 nonce;
        OrderType orderType;
        address token;
        address YT;
        address maker;
        address receiver;
        uint256 makingAmount;
        uint256 lnImpliedRate;
        uint256 failSafeRate;
        bytes permit;
    }

    enum OrderType {
        SY_FOR_PT,
        PT_FOR_SY,
        SY_FOR_YT,
        YT_FOR_SY
    }

    function addLiquiditySingleSy(
        address receiver,
        address market,
        uint256 netSyIn,
        uint256 minLpOut,
        ApproxParams calldata guessPtReceivedFromSy,
        LimitOrderData calldata limit
    ) external returns (uint256 netLpOut, uint256 netSyFee);

    function removeLiquiditySingleSy(
        address receiver, 
        address market, 
        uint256 netLPToRemove, 
        uint256 minSyOut, 
        LimitOrderData calldata limit
    ) external returns (uint256 netSyOut, uint256 netSyFee);
}

interface IWETH {
    function withdraw(uint256) external;
    function deposit() external payable;
}

/// @title Callback for IUniswapV3PoolActions#swap
/// @notice Any contract that calls IUniswapV3PoolActions#swap must implement this interface
interface IUniswapV3SwapCallback {
    /// @notice Called to `msg.sender` after executing a swap via IUniswapV3Pool#swap.
    /// @dev In the implementation you must pay the pool tokens owed for the swap.
    /// The caller of this method must be checked to be a UniswapV3Pool deployed by the canonical UniswapV3Factory.
    /// amount0Delta and amount1Delta can both be 0 if no tokens were swapped.
    /// @param amount0Delta The amount of token0 that was sent (negative) or must be received (positive) by the pool by
    /// the end of the swap. If positive, the callback must send that amount of token0 to the pool.
    /// @param amount1Delta The amount of token1 that was sent (negative) or must be received (positive) by the pool by
    /// the end of the swap. If positive, the callback must send that amount of token1 to the pool.
    /// @param data Any data passed through by the caller via the IUniswapV3PoolActions#swap call
    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external;
}

/// @title Router token swapping functionality
/// @notice Functions for swapping tokens via Uniswap V3
interface ISwapRouter is IUniswapV3SwapCallback {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps `amountIn` of one token for as much as possible of another token
    /// @param params The parameters necessary for the swap, encoded as `ExactInputSingleParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInputSingle(
        ExactInputSingleParams calldata params
    ) external payable returns (uint256 amountOut);

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    /// @notice Swaps `amountIn` of one token for as much as possible of another along the specified path
    /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactInputParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInput(
        ExactInputParams calldata params
    ) external payable returns (uint256 amountOut);

    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps as little as possible of one token for `amountOut` of another token
    /// @param params The parameters necessary for the swap, encoded as `ExactOutputSingleParams` in calldata
    /// @return amountIn The amount of the input token
    function exactOutputSingle(
        ExactOutputSingleParams calldata params
    ) external payable returns (uint256 amountIn);

    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    /// @notice Swaps as little as possible of one token for `amountOut` of another along the specified path (reversed)
    /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactOutputParams` in calldata
    /// @return amountIn The amount of the input token
    function exactOutput(
        ExactOutputParams calldata params
    ) external payable returns (uint256 amountIn);

    // Taken from https://soliditydeveloper.com/uniswap3
    // Manually added to the interface
    function refundETH() external payable;
}

/**
 *   @title UniswapV3Swapper
 *   @author Yearn.finance
 *   @dev This is a simple contract that can be inherited by any tokenized
 *   strategy that would like to use Uniswap V3 for swaps. It hold all needed
 *   logic to perform both exact input and exact output swaps.
 *
 *   The global address variables default to the ETH mainnet addresses but
 *   remain settable by the inheriting contract to allow for customization
 *   based on needs or chain its used on.
 *
 *   The only variables that are required to be set are the specific fees
 *   for each token pair. The inheriting contract can use the {_setUniFees}
 *   function to easily set this for any token pairs needed.
 */
contract UniswapV3Swapper {
    using SafeERC20 for ERC20;

    // Optional Variable to be set to not sell dust.
    uint256 public minAmountToSell;
    // Defaults to WETH on mainnet.
    address public base = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    // Defaults to Uniswap V3 router on mainnet.
    address public router = 0xE592427A0AEce92De3Edee1F18E0157C05861564;

    // Fees for the Uni V3 pools. Each fee should get set each way in
    // the mapping so no matter the direction the correct fee will get
    // returned for any two tokens.
    mapping(address => mapping(address => uint24)) public uniFees;

    /**
     * @dev All fess will default to 0 on creation. A strategist will need
     * To set the mapping for the tokens expected to swap. This function
     * is to help set the mapping. It can be called internally during
     * initialization, through permissioned functions etc.
     */
    function _setUniFees(
        address _token0,
        address _token1,
        uint24 _fee
    ) internal virtual {
        uniFees[_token0][_token1] = _fee;
        uniFees[_token1][_token0] = _fee;
    }

    /**
     * @dev Used to swap a specific amount of `_from` to `_to`.
     * This will check and handle all allowances as well as not swapping
     * unless `_amountIn` is greater than the set `_minAmountOut`
     *
     * If one of the tokens matches with the `base` token it will do only
     * one jump, otherwise will do two jumps.
     *
     * The corresponding uniFees for each token pair will need to be set
     * other wise this function will revert.
     *
     * @param _from The token we are swapping from.
     * @param _to The token we are swapping to.
     * @param _amountIn The amount of `_from` we will swap.
     * @param _minAmountOut The min of `_to` to get out.
     * @return _amountOut The actual amount of `_to` that was swapped to
     */
    function _swapFrom(
        address _from,
        address _to,
        uint256 _amountIn,
        uint256 _minAmountOut
    ) internal virtual returns (uint256 _amountOut) {
        if (_amountIn > minAmountToSell) {
            _checkAllowance(router, _from, _amountIn);
            if (_from == base || _to == base) {
                ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
                    .ExactInputSingleParams(
                        _from, // tokenIn
                        _to, // tokenOut
                        uniFees[_from][_to], // from-to fee
                        address(this), // recipient
                        block.timestamp, // deadline
                        _amountIn, // amountIn
                        _minAmountOut, // amountOut
                        0 // sqrtPriceLimitX96
                    );

                _amountOut = ISwapRouter(router).exactInputSingle(params);
            } else {
                bytes memory path = abi.encodePacked(
                    _from, // tokenIn
                    uniFees[_from][base], // from-base fee
                    base, // base token
                    uniFees[base][_to], // base-to fee
                    _to // tokenOut
                );

                _amountOut = ISwapRouter(router).exactInput(
                    ISwapRouter.ExactInputParams(
                        path,
                        address(this),
                        block.timestamp,
                        _amountIn,
                        _minAmountOut
                    )
                );
            }
        }
    }

    /**
     * @dev Used to swap a specific amount of `_to` from `_from` unless
     * it takes more than `_maxAmountFrom`.
     *
     * This will check and handle all allowances as well as not swapping
     * unless `_maxAmountFrom` is greater than the set `minAmountToSell`
     *
     * If one of the tokens matches with the `base` token it will do only
     * one jump, otherwise will do two jumps.
     *
     * The corresponding uniFees for each token pair will need to be set
     * other wise this function will revert.
     *
     * @param _from The token we are swapping from.
     * @param _to The token we are swapping to.
     * @param _amountTo The amount of `_to` we need out.
     * @param _maxAmountFrom The max of `_from` we will swap.
     * @return _amountIn The actual amount of `_from` swapped.
     */
    function _swapTo(
        address _from,
        address _to,
        uint256 _amountTo,
        uint256 _maxAmountFrom
    ) internal virtual returns (uint256 _amountIn) {
        if (_maxAmountFrom > minAmountToSell) {
            _checkAllowance(router, _from, _maxAmountFrom);
            if (_from == base || _to == base) {
                ISwapRouter.ExactOutputSingleParams memory params = ISwapRouter
                    .ExactOutputSingleParams(
                        _from, // tokenIn
                        _to, // tokenOut
                        uniFees[_from][_to], // from-to fee
                        address(this), // recipient
                        block.timestamp, // deadline
                        _amountTo, // amountOut
                        _maxAmountFrom, // maxAmountIn
                        0 // sqrtPriceLimitX96
                    );

                _amountIn = ISwapRouter(router).exactOutputSingle(params);
            } else {
                bytes memory path = abi.encodePacked(
                    _to,
                    uniFees[base][_to], // base-to fee
                    base,
                    uniFees[_from][base], // from-base fee
                    _from
                );

                _amountIn = ISwapRouter(router).exactOutput(
                    ISwapRouter.ExactOutputParams(
                        path,
                        address(this),
                        block.timestamp,
                        _amountTo, // How much we want out
                        _maxAmountFrom
                    )
                );
            }
        }
    }

    /**
     * @dev Internal safe function to make sure the contract you want to
     * interact with has enough allowance to pull the desired tokens.
     *
     * @param _contract The address of the contract that will move the token.
     * @param _token The ERC-20 token that will be getting spent.
     * @param _amount The amount of `_token` to be spent.
     */
    function _checkAllowance(
        address _contract,
        address _token,
        uint256 _amount
    ) internal virtual {
        if (ERC20(_token).allowance(address(this), _contract) < _amount) {
            ERC20(_token).safeApprove(_contract, 0);
            ERC20(_token).safeApprove(_contract, _amount);
        }
    }
}

interface ITradeFactory {
    function enable(address, address) external;

    function disable(address, address) external;
}

/**
 * @title Trade Factory Swapper
 * @dev Inherit to use a Trade Factory for token swapping.
 *   External functions with the proper modifiers should be
 *   declared in the strategy that inherits this to add a
 *   Trade Factory and the tokens to sell.
 */
abstract contract TradeFactorySwapper {
    using SafeERC20 for ERC20;

    // Address of the trade factory in use if any.
    address private _tradeFactory;

    // Array of any tokens added to be sold.
    address[] private _rewardTokens;

    /**
     * @notice Get the current Trade Factory.
     * @dev We use a getter so trade factory can only be set through the
     *   proper functions to avoid issues.
     * @return The current trade factory in use if any.
     */
    function tradeFactory() public view returns (address) {
        return _tradeFactory;
    }

    /**
     * @notice Get the current tokens being sold through the Trade Factory.
     * @dev We use a getter so the array can only be set through the
     *   proper functions to avoid issues.
     * @return The current array of tokens being sold if any.
     */
    function rewardTokens() public view returns (address[] memory) {
        return _rewardTokens;
    }

    /**
     * @dev Add an array of tokens to sell to its corresponding `_to_.
     */
    function _addTokens(address[] memory _from, address[] memory _to) internal {
        for (uint256 i; i < _from.length; ++i) {
            _addToken(_from[i], _to[i]);
        }
    }

    /**
     * @dev Add the `_tokenFrom` to be sold to `_tokenTo` through the Trade Factory
     */
    function _addToken(address _tokenFrom, address _tokenTo) internal {
        address _tf = tradeFactory();
        if (_tf != address(0)) {
            ERC20(_tokenFrom).forceApprove(_tf, type(uint256).max);
            ITradeFactory(_tf).enable(_tokenFrom, _tokenTo);
        }

        _rewardTokens.push(_tokenFrom);
    }

    /**
     * @dev Remove a specific `_tokenFrom` that was previously added to not be
     * sold through the Trade Factory any more.
     */
    function _removeToken(address _tokenFrom, address _tokenTo) internal {
        address _tf = tradeFactory();
        address[] memory _rewardTokensLocal = rewardTokens();
        for (uint256 i; i < _rewardTokensLocal.length; ++i) {
            if (_rewardTokensLocal[i] == _tokenFrom) {
                if (i != _rewardTokensLocal.length - 1) {
                    // if it isn't the last token, swap with the last one/
                    _rewardTokensLocal[i] = _rewardTokensLocal[
                        _rewardTokensLocal.length - 1
                    ];
                }

                if (_tf != address(0)) {
                    ERC20(_tokenFrom).forceApprove(_tf, 0);
                    ITradeFactory(_tf).disable(_tokenFrom, _tokenTo);
                }

                // Set to storage
                _rewardTokens = _rewardTokensLocal;
                _rewardTokens.pop();
            }
        }
    }

    /**
     * @dev Removes all reward tokens and delete the Trade Factory.
     */
    function _deleteRewardTokens() internal {
        _removeTradeFactoryPermissions();
        delete _rewardTokens;
    }

    /**
     * @dev Set a new instance of the Trade Factory.
     *   This will remove any old approvals for current factory if any.
     *   Then will add the new approvals for the new Trade Factory.
     *   Can pass in address(0) for `tradeFactory_` to remove all permissions.
     */
    function _setTradeFactory(
        address tradeFactory_,
        address _tokenTo
    ) internal {
        address _tf = tradeFactory();

        // Remove any old Trade Factory
        if (_tf != address(0)) {
            _removeTradeFactoryPermissions();
        }

        // If setting to address(0) we are done.
        if (tradeFactory_ == address(0)) return;

        address[] memory _rewardTokensLocal = _rewardTokens;

        for (uint256 i; i < _rewardTokensLocal.length; ++i) {
            address token = _rewardTokensLocal[i];

            ERC20(token).forceApprove(tradeFactory_, type(uint256).max);
            ITradeFactory(tradeFactory_).enable(token, _tokenTo);
        }

        // Set to storage
        _tradeFactory = tradeFactory_;
    }

    /**
     * @dev Remove any active approvals and set the trade factory to address(0).
     */
    function _removeTradeFactoryPermissions() internal {
        address _tf = tradeFactory();
        address[] memory rewardTokensLocal = rewardTokens();
        for (uint256 i; i < rewardTokensLocal.length; ++i) {
            ERC20(rewardTokensLocal[i]).forceApprove(_tf, 0);
        }

        _tradeFactory = address(0);
    }

    /**
     * @notice Used for TradeFactory to claim rewards.
     */
    function claimRewards() external {
        require(msg.sender == _tradeFactory, "!authorized");
        _claimRewards();
    }

    /**
     * @dev Need to be overridden to claim rewards mid report cycles.
     */
    function _claimRewards() internal virtual;
}

// Math library from https://github.com/ajna-finance/ajna-core/blob/master/src/libraries/internal/Maths.sol

/**
    @title  Maths library
    @notice Internal library containing common maths.
 */
library Maths {
    uint256 internal constant WAD = 1e18;
    uint256 internal constant RAY = 1e27;

    function wmul(uint256 x, uint256 y) internal pure returns (uint256) {
        return (x * y + WAD / 2) / WAD;
    }

    function floorWmul(uint256 x, uint256 y) internal pure returns (uint256) {
        return (x * y) / WAD;
    }

    function ceilWmul(uint256 x, uint256 y) internal pure returns (uint256) {
        return (x * y + WAD - 1) / WAD;
    }

    function wdiv(uint256 x, uint256 y) internal pure returns (uint256) {
        return (x * WAD + y / 2) / y;
    }

    function floorWdiv(uint256 x, uint256 y) internal pure returns (uint256) {
        return (x * WAD) / y;
    }

    function ceilWdiv(uint256 x, uint256 y) internal pure returns (uint256) {
        return (x * WAD + y - 1) / y;
    }

    function ceilDiv(uint256 x, uint256 y) internal pure returns (uint256) {
        return (x + y - 1) / y;
    }

    function max(uint256 x, uint256 y) internal pure returns (uint256) {
        return x >= y ? x : y;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256) {
        return x <= y ? x : y;
    }

    function wad(uint256 x) internal pure returns (uint256) {
        return x * WAD;
    }

    function rmul(uint256 x, uint256 y) internal pure returns (uint256) {
        return (x * y + RAY / 2) / RAY;
    }

    function rpow(uint256 x, uint256 n) internal pure returns (uint256 z) {
        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }

    /*************************/
    /*** Integer Functions ***/
    /*************************/

    function maxInt(int256 x, int256 y) internal pure returns (int256) {
        return x >= y ? x : y;
    }

    function minInt(int256 x, int256 y) internal pure returns (int256) {
        return x <= y ? x : y;
    }
}

contract Governance {
    /// @notice Emitted when the governance address is updated.
    event GovernanceTransferred(
        address indexed previousGovernance,
        address indexed newGovernance
    );

    modifier onlyGovernance() {
        _checkGovernance();
        _;
    }

    /// @notice Checks if the msg sender is the governance.
    function _checkGovernance() internal view virtual {
        require(governance == msg.sender, "!governance");
    }

    /// @notice Address that can set the default base fee and provider
    address public governance;

    constructor(address _governance) {
        governance = _governance;

        emit GovernanceTransferred(address(0), _governance);
    }

    /**
     * @notice Sets a new address as the governance of the contract.
     * @dev Throws if the caller is not current governance.
     * @param _newGovernance The new governance address.
     */
    function transferGovernance(
        address _newGovernance
    ) external virtual onlyGovernance {
        require(_newGovernance != address(0), "ZERO ADDRESS");
        address oldGovernance = governance;
        governance = _newGovernance;

        emit GovernanceTransferred(oldGovernance, _newGovernance);
    }
}

// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
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

interface ITaker {
    function auctionTakeCallback(
        bytes32 _auctionId,
        address _sender,
        uint256 _amountTaken,
        uint256 _amountNeeded,
        bytes calldata _data
    ) external;
}

/// @notice Interface that the optional `hook` contract should implement if the non-standard logic is desired.
interface IHook {
    function kickable(address _fromToken) external view returns (uint256);

    function auctionKicked(address _fromToken) external returns (uint256);

    function preTake(
        address _fromToken,
        uint256 _amountToTake,
        uint256 _amountToPay
    ) external;

    function postTake(
        address _toToken,
        uint256 _amountTaken,
        uint256 _amountPayed
    ) external;
}

/**
 *   @title Auction
 *   @author yearn.fi
 *   @notice General use dutch auction contract for token sales.
 */
contract Auction is Governance, ReentrancyGuard {
    using SafeERC20 for ERC20;

    /// @notice Emitted when a new auction is enabled
    event AuctionEnabled(
        bytes32 auctionId,
        address indexed from,
        address indexed to,
        address indexed auctionAddress
    );

    /// @notice Emitted when an auction is disabled.
    event AuctionDisabled(
        bytes32 auctionId,
        address indexed from,
        address indexed to,
        address indexed auctionAddress
    );

    /// @notice Emitted when auction has been kicked.
    event AuctionKicked(bytes32 auctionId, uint256 available);

    /// @notice Emitted when any amount of an active auction was taken.
    event AuctionTaken(
        bytes32 auctionId,
        uint256 amountTaken,
        uint256 amountLeft
    );

    /// @dev Store address and scaler in one slot.
    struct TokenInfo {
        address tokenAddress;
        uint96 scaler;
    }

    /// @notice Store all the auction specific information.
    struct AuctionInfo {
        TokenInfo fromInfo;
        uint96 kicked;
        address receiver;
        uint128 initialAvailable;
        uint128 currentAvailable;
    }

    /// @notice Store the hook address and each flag in one slot.
    struct Hook {
        address hook;
        bool kickable;
        bool kick;
        bool preTake;
        bool postTake;
    }

    uint256 internal constant WAD = 1e18;

    /// @notice Used for the price decay.
    uint256 internal constant MINUTE_HALF_LIFE =
        0.988514020352896135_356867505 * 1e27; // 0.5^(1/60)

    /// @notice Struct to hold the info for `want`.
    TokenInfo internal wantInfo;

    /// @notice Contract to call during write functions.
    Hook internal hook_;

    /// @notice The amount to start the auction at.
    uint256 public startingPrice;

    /// @notice The time that each auction lasts.
    uint256 public auctionLength;

    /// @notice The minimum time to wait between auction 'kicks'.
    uint256 public auctionCooldown;

    /// @notice Mapping from an auction ID to its struct.
    mapping(bytes32 => AuctionInfo) public auctions;

    /// @notice Array of all the enabled auction for this contract.
    bytes32[] public enabledAuctions;

    constructor() Governance(msg.sender) {}

    /**
     * @notice Initializes the Auction contract with initial parameters.
     * @param _want Address this auction is selling to.
     * @param _hook Address of the hook contract (optional).
     * @param _governance Address of the contract governance.
     * @param _auctionLength Duration of each auction in seconds.
     * @param _auctionCooldown Cooldown period between auctions in seconds.
     * @param _startingPrice Starting price for each auction.
     */
    function initialize(
        address _want,
        address _hook,
        address _governance,
        uint256 _auctionLength,
        uint256 _auctionCooldown,
        uint256 _startingPrice
    ) external virtual {
        require(auctionLength == 0, "initialized");
        require(_want != address(0), "ZERO ADDRESS");
        require(_auctionLength != 0, "length");
        require(_auctionLength < _auctionCooldown, "cooldown");
        require(_startingPrice != 0, "starting price");

        // Cannot have more than 18 decimals.
        uint256 decimals = ERC20(_want).decimals();
        require(decimals <= 18, "unsupported decimals");

        // Set variables
        wantInfo = TokenInfo({
            tokenAddress: _want,
            scaler: uint96(WAD / 10 ** decimals)
        });

        // If we are using a hook.
        if (_hook != address(0)) {
            // All flags default to true.
            hook_ = Hook({
                hook: _hook,
                kickable: true,
                kick: true,
                preTake: true,
                postTake: true
            });
        }

        governance = _governance;
        auctionLength = _auctionLength;
        auctionCooldown = _auctionCooldown;
        startingPrice = _startingPrice;
    }

    /*//////////////////////////////////////////////////////////////
                         VIEW METHODS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Get the address of this auctions want token.
     * @return . The want token.
     */
    function want() public view virtual returns (address) {
        return wantInfo.tokenAddress;
    }

    /**
     * @notice Get the address of the hook if any.
     * @return . The hook.
     */
    function hook() external view virtual returns (address) {
        return hook_.hook;
    }

    /**
     * @notice Get the current status of which hooks are being used.
     * @return . If the kickable hook is used.
     * @return . If the kick hook is used.
     * @return . If the preTake hook is used.
     * @return . If the postTake hook is used.
     */
    function getHookFlags()
        external
        view
        virtual
        returns (bool, bool, bool, bool)
    {
        Hook memory _hook = hook_;
        return (_hook.kickable, _hook.kick, _hook.preTake, _hook.postTake);
    }

    /**
     * @notice Get the length of the enabled auctions array.
     */
    function numberOfEnabledAuctions() external view virtual returns (uint256) {
        return enabledAuctions.length;
    }

    /**
     * @notice Get the unique auction identifier.
     * @param _from The address of the token to sell.
     * @return bytes32 A unique auction identifier.
     */
    function getAuctionId(address _from) public view virtual returns (bytes32) {
        return keccak256(abi.encodePacked(_from, want(), address(this)));
    }

    /**
     * @notice Retrieves information about a specific auction.
     * @param _auctionId The unique identifier of the auction.
     * @return _from The address of the token to sell.
     * @return _to The address of the token to buy.
     * @return _kicked The timestamp of the last kick.
     * @return _available The current available amount for the auction.
     */
    function auctionInfo(
        bytes32 _auctionId
    )
        public
        view
        virtual
        returns (
            address _from,
            address _to,
            uint256 _kicked,
            uint256 _available
        )
    {
        AuctionInfo memory auction = auctions[_auctionId];

        return (
            auction.fromInfo.tokenAddress,
            want(),
            auction.kicked,
            auction.kicked + auctionLength > block.timestamp
                ? auction.currentAvailable
                : 0
        );
    }

    /**
     * @notice Get the pending amount available for the next auction.
     * @dev Defaults to the auctions balance of the from token if no hook.
     * @param _auctionId The unique identifier of the auction.
     * @return uint256 The amount that can be kicked into the auction.
     */
    function kickable(
        bytes32 _auctionId
    ) external view virtual returns (uint256) {
        // If not enough time has passed then `kickable` is 0.
        if (auctions[_auctionId].kicked + auctionCooldown > block.timestamp) {
            return 0;
        }

        // Check if we have a hook to call.
        Hook memory _hook = hook_;
        if (_hook.kickable) {
            // If so default to the hooks logic.
            return
                IHook(_hook.hook).kickable(
                    auctions[_auctionId].fromInfo.tokenAddress
                );
        } else {
            // Else just use the full balance of this contract.
            return
                ERC20(auctions[_auctionId].fromInfo.tokenAddress).balanceOf(
                    address(this)
                );
        }
    }

    /**
     * @notice Gets the amount of `want` needed to buy a specific amount of `from`.
     * @param _auctionId The unique identifier of the auction.
     * @param _amountToTake The amount of `from` to take in the auction.
     * @return . The amount of `want` needed to fulfill the take amount.
     */
    function getAmountNeeded(
        bytes32 _auctionId,
        uint256 _amountToTake
    ) external view virtual returns (uint256) {
        return
            _getAmountNeeded(
                auctions[_auctionId],
                _amountToTake,
                block.timestamp
            );
    }

    /**
     * @notice Gets the amount of `want` needed to buy a specific amount of `from` at a specific timestamp.
     * @param _auctionId The unique identifier of the auction.
     * @param _amountToTake The amount `from` to take in the auction.
     * @param _timestamp The specific timestamp for calculating the amount needed.
     * @return . The amount of `want` needed to fulfill the take amount.
     */
    function getAmountNeeded(
        bytes32 _auctionId,
        uint256 _amountToTake,
        uint256 _timestamp
    ) external view virtual returns (uint256) {
        return
            _getAmountNeeded(auctions[_auctionId], _amountToTake, _timestamp);
    }

    /**
     * @dev Return the amount of `want` needed to buy `_amountToTake`.
     */
    function _getAmountNeeded(
        AuctionInfo memory _auction,
        uint256 _amountToTake,
        uint256 _timestamp
    ) internal view virtual returns (uint256) {
        return
            // Scale _amountToTake to 1e18
            (_amountToTake *
                _auction.fromInfo.scaler *
                // Price is always 1e18
                _price(
                    _auction.kicked,
                    _auction.initialAvailable * _auction.fromInfo.scaler,
                    _timestamp
                )) /
            1e18 /
            // Scale back down to want.
            wantInfo.scaler;
    }

    /**
     * @notice Gets the price of the auction at the current timestamp.
     * @param _auctionId The unique identifier of the auction.
     * @return . The price of the auction.
     */
    function price(bytes32 _auctionId) external view virtual returns (uint256) {
        return price(_auctionId, block.timestamp);
    }

    /**
     * @notice Gets the price of the auction at a specific timestamp.
     * @param _auctionId The unique identifier of the auction.
     * @param _timestamp The specific timestamp for calculating the price.
     * @return . The price of the auction.
     */
    function price(
        bytes32 _auctionId,
        uint256 _timestamp
    ) public view virtual returns (uint256) {
        // Get unscaled price and scale it down.
        return
            _price(
                auctions[_auctionId].kicked,
                auctions[_auctionId].initialAvailable *
                    auctions[_auctionId].fromInfo.scaler,
                _timestamp
            ) / wantInfo.scaler;
    }

    /**
     * @dev Internal function to calculate the scaled price based on auction parameters.
     * @param _kicked The timestamp the auction was kicked.
     * @param _available The initial available amount scaled 1e18.
     * @param _timestamp The specific timestamp for calculating the price.
     * @return . The calculated price scaled to 1e18.
     */
    function _price(
        uint256 _kicked,
        uint256 _available,
        uint256 _timestamp
    ) internal view virtual returns (uint256) {
        if (_available == 0) return 0;

        uint256 secondsElapsed = _timestamp - _kicked;

        if (secondsElapsed > auctionLength) return 0;

        // Exponential decay from https://github.com/ajna-finance/ajna-core/blob/master/src/libraries/helpers/PoolHelper.sol
        uint256 hoursComponent = 1e27 >> (secondsElapsed / 3600);
        uint256 minutesComponent = Maths.rpow(
            MINUTE_HALF_LIFE,
            (secondsElapsed % 3600) / 60
        );
        uint256 initialPrice = Maths.wdiv(startingPrice * 1e18, _available);

        return
            (initialPrice * Maths.rmul(hoursComponent, minutesComponent)) /
            1e27;
    }

    /*//////////////////////////////////////////////////////////////
                            SETTERS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Enables a new auction.
     * @dev Uses governance as the receiver.
     * @param _from The address of the token to be auctioned.
     * @return . The unique identifier of the enabled auction.
     */
    function enable(address _from) external virtual returns (bytes32) {
        return enable(_from, msg.sender);
    }

    /**
     * @notice Enables a new auction.
     * @param _from The address of the token to be auctioned.
     * @param _receiver The address that will receive the funds in the auction.
     * @return _auctionId The unique identifier of the enabled auction.
     */
    function enable(
        address _from,
        address _receiver
    ) public virtual onlyGovernance returns (bytes32 _auctionId) {
        address _want = want();
        require(_from != address(0) && _from != _want, "ZERO ADDRESS");
        require(
            _receiver != address(0) && _receiver != address(this),
            "receiver"
        );
        // Cannot have more than 18 decimals.
        uint256 decimals = ERC20(_from).decimals();
        require(decimals <= 18, "unsupported decimals");

        // Calculate the id.
        _auctionId = getAuctionId(_from);

        require(
            auctions[_auctionId].fromInfo.tokenAddress == address(0),
            "already enabled"
        );

        // Store all needed info.
        auctions[_auctionId].fromInfo = TokenInfo({
            tokenAddress: _from,
            scaler: uint96(WAD / 10 ** decimals)
        });
        auctions[_auctionId].receiver = _receiver;

        // Add to the array.
        enabledAuctions.push(_auctionId);

        emit AuctionEnabled(_auctionId, _from, _want, address(this));
    }

    /**
     * @notice Disables an existing auction.
     * @dev Only callable by governance.
     * @param _from The address of the token being sold.
     */
    function disable(address _from) external virtual {
        disable(_from, 0);
    }

    /**
     * @notice Disables an existing auction.
     * @dev Only callable by governance.
     * @param _from The address of the token being sold.
     * @param _index The index the auctionId is at in the array.
     */
    function disable(
        address _from,
        uint256 _index
    ) public virtual onlyGovernance {
        bytes32 _auctionId = getAuctionId(_from);

        // Make sure the auction was enabled.
        require(
            auctions[_auctionId].fromInfo.tokenAddress != address(0),
            "not enabled"
        );

        // Remove the struct.
        delete auctions[_auctionId];

        // Remove the auction ID from the array.
        bytes32[] memory _enabledAuctions = enabledAuctions;
        if (_enabledAuctions[_index] != _auctionId) {
            // If the _index given is not the id find it.
            for (uint256 i = 0; i < _enabledAuctions.length; ++i) {
                if (_enabledAuctions[i] == _auctionId) {
                    _index = i;
                    break;
                }
            }
        }

        // Move the id to the last spot if not there.
        if (_index < _enabledAuctions.length - 1) {
            _enabledAuctions[_index] = _enabledAuctions[
                _enabledAuctions.length - 1
            ];
            // Update the array.
            enabledAuctions = _enabledAuctions;
        }

        // Pop the id off the array.
        enabledAuctions.pop();

        emit AuctionDisabled(_auctionId, _from, want(), address(this));
    }

    /**
     * @notice Set the flags to be used with hook.
     * @param _kickable If the kickable hook should be used.
     * @param _kick If the kick hook should be used.
     * @param _preTake If the preTake hook should be used.
     * @param _postTake If the postTake should be used.
     */
    function setHookFlags(
        bool _kickable,
        bool _kick,
        bool _preTake,
        bool _postTake
    ) external virtual onlyGovernance {
        address _hook = hook_.hook;
        require(_hook != address(0), "no hook set");

        hook_ = Hook({
            hook: _hook,
            kickable: _kickable,
            kick: _kick,
            preTake: _preTake,
            postTake: _postTake
        });
    }

    /*//////////////////////////////////////////////////////////////
                      PARTICIPATE IN AUCTION
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Kicks off an auction, updating its status and making funds available for bidding.
     * @param _auctionId The unique identifier of the auction.
     * @return available The available amount for bidding on in the auction.
     */
    function kick(
        bytes32 _auctionId
    ) external virtual nonReentrant returns (uint256 available) {
        address _fromToken = auctions[_auctionId].fromInfo.tokenAddress;
        require(_fromToken != address(0), "not enabled");
        require(
            block.timestamp > auctions[_auctionId].kicked + auctionCooldown,
            "too soon"
        );

        Hook memory _hook = hook_;
        // Use hook if defined.
        if (_hook.kick) {
            available = IHook(_hook.hook).auctionKicked(_fromToken);
        } else {
            // Else just use current balance.
            available = ERC20(_fromToken).balanceOf(address(this));
        }

        require(available != 0, "nothing to kick");

        // Update the auctions status.
        auctions[_auctionId].kicked = uint96(block.timestamp);
        auctions[_auctionId].initialAvailable = uint128(available);
        auctions[_auctionId].currentAvailable = uint128(available);

        emit AuctionKicked(_auctionId, available);
    }

    /**
     * @notice Take the token being sold in a live auction.
     * @dev Defaults to taking the full amount and sending to the msg sender.
     * @param _auctionId The unique identifier of the auction.
     * @return . The amount of fromToken taken in the auction.
     */
    function take(bytes32 _auctionId) external virtual returns (uint256) {
        return _take(_auctionId, type(uint256).max, msg.sender, new bytes(0));
    }

    /**
     * @notice Take the token being sold in a live auction with a specified maximum amount.
     * @dev Uses the sender's address as the receiver.
     * @param _auctionId The unique identifier of the auction.
     * @param _maxAmount The maximum amount of fromToken to take in the auction.
     * @return . The amount of fromToken taken in the auction.
     */
    function take(
        bytes32 _auctionId,
        uint256 _maxAmount
    ) external virtual returns (uint256) {
        return _take(_auctionId, _maxAmount, msg.sender, new bytes(0));
    }

    /**
     * @notice Take the token being sold in a live auction.
     * @param _auctionId The unique identifier of the auction.
     * @param _maxAmount The maximum amount of fromToken to take in the auction.
     * @param _receiver The address that will receive the fromToken.
     * @return _amountTaken The amount of fromToken taken in the auction.
     */
    function take(
        bytes32 _auctionId,
        uint256 _maxAmount,
        address _receiver
    ) external virtual returns (uint256) {
        return _take(_auctionId, _maxAmount, _receiver, new bytes(0));
    }

    /**
     * @notice Take the token being sold in a live auction.
     * @param _auctionId The unique identifier of the auction.
     * @param _maxAmount The maximum amount of fromToken to take in the auction.
     * @param _receiver The address that will receive the fromToken.
     * @param _data The data signify the callback should be used and sent with it.
     * @return _amountTaken The amount of fromToken taken in the auction.
     */
    function take(
        bytes32 _auctionId,
        uint256 _maxAmount,
        address _receiver,
        bytes calldata _data
    ) external virtual returns (uint256) {
        return _take(_auctionId, _maxAmount, _receiver, _data);
    }

    /// @dev Implements the take of the auction.
    function _take(
        bytes32 _auctionId,
        uint256 _maxAmount,
        address _receiver,
        bytes memory _data
    ) internal virtual nonReentrant returns (uint256 _amountTaken) {
        AuctionInfo memory auction = auctions[_auctionId];
        // Make sure the auction is active.
        require(
            auction.kicked + auctionLength >= block.timestamp,
            "not kicked"
        );

        // Max amount that can be taken.
        _amountTaken = auction.currentAvailable > _maxAmount
            ? _maxAmount
            : auction.currentAvailable;

        // Get the amount needed
        uint256 needed = _getAmountNeeded(
            auction,
            _amountTaken,
            block.timestamp
        );

        require(needed != 0, "zero needed");

        // How much is left in this auction.
        uint256 left;
        unchecked {
            left = auction.currentAvailable - _amountTaken;
        }
        auctions[_auctionId].currentAvailable = uint128(left);

        Hook memory _hook = hook_;
        if (_hook.preTake) {
            // Use hook if defined.
            IHook(_hook.hook).preTake(
                auction.fromInfo.tokenAddress,
                _amountTaken,
                needed
            );
        }

        // Send `from`.
        ERC20(auction.fromInfo.tokenAddress).safeTransfer(
            _receiver,
            _amountTaken
        );

        // If the caller has specified data.
        if (_data.length != 0) {
            // Do the callback.
            ITaker(_receiver).auctionTakeCallback(
                _auctionId,
                msg.sender,
                _amountTaken,
                needed,
                _data
            );
        }

        // Cache the want address.
        address _want = want();

        // Pull `want`.
        ERC20(_want).safeTransferFrom(msg.sender, auction.receiver, needed);

        // Post take hook if defined.
        if (_hook.postTake) {
            IHook(_hook.hook).postTake(_want, _amountTaken, needed);
        }

        emit AuctionTaken(_auctionId, _amountTaken, left);
    }
}

contract Clonable {
    /// @notice Set to the address to auto clone from.
    address public original;

    /**
     * @notice Clone the contracts default `original` contract.
     * @return Address of the new Minimal Proxy clone.
     */
    function _clone() internal virtual returns (address) {
        return _clone(original);
    }

    /**
     * @notice Clone any `_original` contract.
     * @return _newContract Address of the new Minimal Proxy clone.
     */
    function _clone(
        address _original
    ) internal virtual returns (address _newContract) {
        // Copied from https://github.com/optionality/clone-factory/blob/master/contracts/CloneFactory.sol
        bytes20 addressBytes = bytes20(_original);
        assembly {
            // EIP-1167 bytecode
            let clone_code := mload(0x40)
            mstore(
                clone_code,
                0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
            )
            mstore(add(clone_code, 0x14), addressBytes)
            mstore(
                add(clone_code, 0x28),
                0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
            )
            _newContract := create(0, clone_code, 0x37)
        }
    }
}

/// @title AuctionFactory
/// @notice Deploy a new Auction.
contract AuctionFactory is Clonable {
    event DeployedNewAuction(address indexed auction, address indexed want);

    /// @notice The time that each auction lasts.
    uint256 public constant DEFAULT_AUCTION_LENGTH = 1 days;

    /// @notice The minimum time to wait between auction 'kicks'.
    uint256 public constant DEFAULT_AUCTION_COOLDOWN = 5 days;

    /// @notice The amount to start the auction with.
    uint256 public constant DEFAULT_STARTING_PRICE = 1_000_000;

    /// @notice Full array of all auctions deployed through this factory.
    address[] public auctions;

    constructor() {
        // Deploy the original
        original = address(new Auction());
    }

    /**
     * @notice Creates a new auction contract.
     * @param _want Address of the token users will bid with.
     * @return _newAuction Address of the newly created auction contract.
     */
    function createNewAuction(address _want) external returns (address) {
        return
            _createNewAuction(
                _want,
                address(0),
                msg.sender,
                DEFAULT_AUCTION_LENGTH,
                DEFAULT_AUCTION_COOLDOWN,
                DEFAULT_STARTING_PRICE
            );
    }

    /**
     * @notice Creates a new auction contract.
     * @param _want Address of the token users will bid with.
     * @param _hook Address of the hook contract if any.
     * @return _newAuction Address of the newly created auction contract.
     */
    function createNewAuction(
        address _want,
        address _hook
    ) external returns (address) {
        return
            _createNewAuction(
                _want,
                _hook,
                msg.sender,
                DEFAULT_AUCTION_LENGTH,
                DEFAULT_AUCTION_COOLDOWN,
                DEFAULT_STARTING_PRICE
            );
    }

    /**
     * @notice Creates a new auction contract.
     * @param _want Address of the token users will bid with.
     * @param _hook Address of the hook contract if any.
     * @param _governance Address allowed to enable and disable auctions.
     * @return _newAuction Address of the newly created auction contract.
     */
    function createNewAuction(
        address _want,
        address _hook,
        address _governance
    ) external returns (address) {
        return
            _createNewAuction(
                _want,
                _hook,
                _governance,
                DEFAULT_AUCTION_LENGTH,
                DEFAULT_AUCTION_COOLDOWN,
                DEFAULT_STARTING_PRICE
            );
    }

    /**
     * @notice Creates a new auction contract.
     * @param _want Address of the token users will bid with.
     * @param _hook Address of the hook contract if any.
     * @param _governance Address allowed to enable and disable auctions.
     * @param _auctionLength Length of the auction in seconds.
     * @return _newAuction Address of the newly created auction contract.
     */
    function createNewAuction(
        address _want,
        address _hook,
        address _governance,
        uint256 _auctionLength
    ) external returns (address) {
        return
            _createNewAuction(
                _want,
                _hook,
                _governance,
                _auctionLength,
                DEFAULT_AUCTION_COOLDOWN,
                DEFAULT_STARTING_PRICE
            );
    }

    /**
     * @notice Creates a new auction contract.
     * @param _want Address of the token users will bid with.
     * @param _hook Address of the hook contract if any.
     * @param _governance Address allowed to enable and disable auctions.
     * @param _auctionLength Length of the auction in seconds.
     * @param _auctionCooldown Minimum time period between kicks in seconds.
     * @return _newAuction Address of the newly created auction contract.
     */
    function createNewAuction(
        address _want,
        address _hook,
        address _governance,
        uint256 _auctionLength,
        uint256 _auctionCooldown
    ) external returns (address) {
        return
            _createNewAuction(
                _want,
                _hook,
                _governance,
                _auctionLength,
                _auctionCooldown,
                DEFAULT_STARTING_PRICE
            );
    }

    /**
     * @notice Creates a new auction contract.
     * @param _want Address of the token users will bid with.
     * @param _hook Address of the hook contract if any.
     * @param _governance Address allowed to enable and disable auctions.
     * @param _auctionLength Length of the auction in seconds.
     * @param _auctionCooldown Minimum time period between kicks in seconds.
     * @param _startingPrice Starting price for the auction (no decimals).
     *  NOTE: The starting price should be without decimals (1k == 1_000).
     * @return _newAuction Address of the newly created auction contract.
     */
    function createNewAuction(
        address _want,
        address _hook,
        address _governance,
        uint256 _auctionLength,
        uint256 _auctionCooldown,
        uint256 _startingPrice
    ) external returns (address) {
        return
            _createNewAuction(
                _want,
                _hook,
                _governance,
                _auctionLength,
                _auctionCooldown,
                _startingPrice
            );
    }

    /**
     * @dev Deploys and initializes a new Auction
     */
    function _createNewAuction(
        address _want,
        address _hook,
        address _governance,
        uint256 _auctionLength,
        uint256 _auctionCooldown,
        uint256 _startingPrice
    ) internal returns (address _newAuction) {
        _newAuction = _clone();

        Auction(_newAuction).initialize(
            _want,
            _hook,
            _governance,
            _auctionLength,
            _auctionCooldown,
            _startingPrice
        );

        auctions.push(_newAuction);

        emit DeployedNewAuction(_newAuction, _want);
    }

    /**
     * @notice Get the full list of auctions deployed through this factory.
     */
    function getAllAuctions() external view returns (address[] memory) {
        return auctions;
    }

    /**
     * @notice Get the total number of auctions deployed through this factory.
     */
    function numberOfAuctions() external view returns (uint256) {
        return auctions.length;
    }
}

/**
 *   @title AuctionSwapper
 *   @author yearn.fi
 *   @dev Helper contract for a strategy to use dutch auctions for token sales.
 *
 *   This contract is meant to be inherited by a V3 strategy in order
 *   to easily integrate dutch auctions into a contract for token swaps.
 *
 *   The strategist will need to implement a way to call `_enableAuction`
 *   for an token pair they want to use, or a setter to manually set the
 *   `auction` contract.
 *
 *   The contract comes with all of the needed function to act as a `hook`
 *   contract for the specific auction contract with the ability to override
 *   any of the functions to implement custom hooks.
 *
 *   NOTE: If any hooks are not desired, the strategist should also
 *   implement a way to call the {setHookFlags} on the auction contract
 *   to avoid unnecessary gas for unused functions.
 */
contract AuctionSwapper {
    using SafeERC20 for ERC20;

    modifier onlyAuction() {
        _isAuction();
        _;
    }

    /**
     * @dev Check the caller is the auction contract for hooks.
     */
    function _isAuction() internal view virtual {
        require(msg.sender == auction, "!auction");
    }

    /// @notice The pre-deployed Auction factory for cloning.
    address public constant auctionFactory =
        0xE6aB098E8582178A76DC80d55ca304d1Dec11AD8;

    /// @notice Address of the specific Auction this strategy uses.
    address public auction;

    /*//////////////////////////////////////////////////////////////
                    AUCTION STARTING AND STOPPING
    //////////////////////////////////////////////////////////////*/

    function _enableAuction(
        address _from,
        address _want
    ) internal virtual returns (bytes32) {
        return _enableAuction(_from, _want, 1 days, 3 days, 1e6);
    }

    /**
     * @dev Used to enable a new Auction to sell `_from` to `_want`.
     *   If this is the first auction enabled it will deploy a new `auction`
     *   contract to use from the factory.
     *
     * NOTE: This only supports one `_want` token per strategy.
     *
     * @param _from Token to sell
     * @param _want Token to buy.
     * @return .The auction ID.
     */
    function _enableAuction(
        address _from,
        address _want,
        uint256 _auctionLength,
        uint256 _auctionCooldown,
        uint256 _startingPrice
    ) internal virtual returns (bytes32) {
        address _auction = auction;

        // If this is the first auction.
        if (_auction == address(0)) {
            // Deploy a new auction
            _auction = AuctionFactory(auctionFactory).createNewAuction(
                _want,
                address(this),
                address(this),
                _auctionLength,
                _auctionCooldown,
                _startingPrice
            );
            // Store it for future use.
            auction = _auction;
        } else {
            // Can only use one `want` per auction contract.
            require(Auction(_auction).want() == _want, "wrong want");
        }

        // Enable new auction for `_from` token.
        return Auction(_auction).enable(_from);
    }

    /**
     * @dev Disable an auction for a given token.
     * @param _from The token that was being sold.
     */
    function _disableAuction(address _from) internal virtual {
        Auction(auction).disable(_from);
    }

    /*//////////////////////////////////////////////////////////////
                        OPTIONAL AUCTION HOOKS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Return how much `_token` could currently be kicked into auction.
     * @dev This can be overridden by a strategist to implement custom logic.
     * @param _token Address of the `_from` token.
     * @return . The amount of `_token` ready to be auctioned off.
     */
    function kickable(address _token) public view virtual returns (uint256) {
        return ERC20(_token).balanceOf(address(this));
    }

    /**
     * @dev To override if something other than just sending the loose balance
     *  of `_token` to the auction is desired, such as accruing and and claiming rewards.
     *
     * @param _token Address of the token being auctioned off
     */
    function _auctionKicked(address _token) internal virtual returns (uint256) {
        // Send any loose balance to the auction.
        uint256 balance = ERC20(_token).balanceOf(address(this));
        if (balance != 0) ERC20(_token).safeTransfer(auction, balance);
        return ERC20(_token).balanceOf(auction);
    }

    /**
     * @dev To override if something needs to be done before a take is completed.
     *   This can be used if the auctioned token only will be freed up when a `take`
     *   occurs.
     * @param _token Address of the token being taken.
     * @param _amountToTake Amount of `_token` needed.
     * @param _amountToPay Amount of `want` that will be payed.
     */
    function _preTake(
        address _token,
        uint256 _amountToTake,
        uint256 _amountToPay
    ) internal virtual {}

    /**
     * @dev To override if a post take action is desired.
     *
     * This could be used to re-deploy the bought token back into the yield source,
     * or in conjunction with {_preTake} to check that the price sold at was within
     * some allowed range.
     *
     * @param _token Address of the token that the strategy was sent.
     * @param _amountTaken Amount of the from token taken.
     * @param _amountPayed Amount of `_token` that was sent to the strategy.
     */
    function _postTake(
        address _token,
        uint256 _amountTaken,
        uint256 _amountPayed
    ) internal virtual {}

    /*//////////////////////////////////////////////////////////////
                            AUCTION HOOKS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice External hook for the auction to call during a `kick`.
     * @dev Will call the internal version for the strategist to override.
     * @param _token Token being kicked into auction.
     * @return . The amount of `_token` to be auctioned off.
     */
    function auctionKicked(
        address _token
    ) external virtual onlyAuction returns (uint256) {
        return _auctionKicked(_token);
    }

    /**
     * @notice External hook for the auction to call before a `take`.
     * @dev Will call the internal version for the strategist to override.
     * @param _token Token being taken in the auction.
     * @param _amountToTake The amount of `_token` to be sent to the taker.
     * @param _amountToPay Amount of `want` that will be payed.
     */
    function preTake(
        address _token,
        uint256 _amountToTake,
        uint256 _amountToPay
    ) external virtual onlyAuction {
        _preTake(_token, _amountToTake, _amountToPay);
    }

    /**
     * @notice External hook for the auction to call after a `take` completed.
     * @dev Will call the internal version for the strategist to override.
     * @param _token The `want` token that was sent to the strategy.
     * @param _amountTaken Amount of the from token taken.
     * @param _amountPayed Amount of `_token` that was sent to the strategy.
     */
    function postTake(
        address _token,
        uint256 _amountTaken,
        uint256 _amountPayed
    ) external virtual onlyAuction {
        _postTake(_token, _amountTaken, _amountPayed);
    }
}

/// @title yearn-v3-Pendle
/// @author mil0x
/// @notice yearn-v3 Strategy that autocompounds Pendle LP positions.
contract PendleLPCompounder is BaseHealthCheck, UniswapV3Swapper, TradeFactorySwapper, AuctionSwapper {
    using SafeERC20 for ERC20;

    // Bool to keep autocompounding the strategy. Defaults to true. Set this to false to deactivate the strategy completely after a shutdown & emergencyWithdraw to leave everything withdrawable in asset.
    bool public autocompound = true;

    // If rewards should be sold through TradeFactory.
    bool public useTradeFactory;

    // If rewards should be sold through Auctions.
    bool public useAuction;

    // Mapping to be set by management for any reward tokens.
    // This can be used to set different mins for different tokens
    // or to set to uin256.max if selling a reward token is reverting
    // to allow for reports to still work properly.
    mapping(address => uint256) public minAmountToSellMapping;

    address internal constant pendleRouter = 0x00000000005BBB0EF59571E58418F9a4357b68A0;
    IPendleRouter.ApproxParams public routerParams;

    address internal immutable pendleStaking;
    address internal immutable marketDepositHelper;
    address internal immutable masterPenpie;
    address internal immutable PENDLE;

    address internal immutable SY;
    address public immutable targetToken;
    
    // Bool wether or not its necessary to unwrap asset before depositing into SY.
    bool public immutable unwrapTargetTokenToSY;

    address public immutable GOV; //yearn governance
    uint256 private constant WAD = 1e18;

    constructor(address _asset, address _pendleStaking, address _PENDLE, uint24 _feePENDLEtoBase, address _base, uint24 _feeBaseToTargetToken, address _targetToken, address _GOV, string memory _name) BaseHealthCheck(_asset, _name) {
        require(!_isExpired(), "expired");

        (SY, , ) = IPendleMarket(_asset).readTokens();
        unwrapTargetTokenToSY = !ISY(SY).isValidTokenIn(_targetToken); //if targetToken is invalid tokenIn, unwrapping is necessary.
        if (unwrapTargetTokenToSY) {
            require(ISY(SY).isValidTokenIn(address(0)), "!valid"); //if targetToken & address(0) are both invalid tokenIn --> revert
        }

        targetToken = _targetToken;
        pendleStaking = _pendleStaking;
        marketDepositHelper = IPendleStaking(pendleStaking).marketDepositHelper();
        masterPenpie = IPendleStaking(_pendleStaking).masterPenpie();
        PENDLE = _PENDLE;
        GOV = _GOV;

        routerParams.guessMin = 0;
        routerParams.guessMax = type(uint256).max;
        routerParams.guessOffchain = 0; // strictly 0
        routerParams.maxIteration = 256;
        routerParams.eps = 1e15; // max 0.1% unused

        // Set uni swapper values
        base = _base;
        _setUniFees(PENDLE, base, _feePENDLEtoBase);
        _setUniFees(_base, _targetToken, _feeBaseToTargetToken);

        //approvals:
        ERC20(_asset).safeApprove(pendleStaking, type(uint).max);
        ERC20(_targetToken).safeApprove(SY, type(uint).max);
        ERC20(SY).safeApprove(pendleRouter, type(uint).max);
    }

    /*//////////////////////////////////////////////////////////////
                INTERNAL
    //////////////////////////////////////////////////////////////*/

    function _deployFunds(uint256 _amount) internal override {
        IMarketDepositHelper(marketDepositHelper).depositMarket(address(asset), _amount);
    }

    function _freeFunds(uint256 _amount) internal override {
        IMarketDepositHelper(marketDepositHelper).withdrawMarket(address(asset), _amount);
    }

    function _harvestAndReport() internal override returns (uint256 _totalAssets) {
        if (autocompound) {
            _claimAndSellRewards();

            uint256 assetBalance = _balanceAsset();
            if (assetBalance > 0) {
                _deployFunds(assetBalance); //stake LP
            }
        }

        _totalAssets = _balanceAsset() + _balanceStaked();
    }

    function _claimRewards() internal override {
        address[] memory stakingTokens = new address[](1);
        stakingTokens[0] = address(asset);
        IMasterPenpie(masterPenpie).multiclaim(stakingTokens);
    }

    function _claimAndSellRewards() internal {
        _claimRewards();
        uint256 rewardBalance;

        // If both tradeFactory and Auction are not being used, we sell rewards here:
        if (!useTradeFactory && !useAuction) {
            //PENDLE --> targetToken
            if (PENDLE != targetToken) {
                rewardBalance = _balancePENDLE();
                if (rewardBalance > minAmountToSellMapping[PENDLE]) {
                    _swapFrom(PENDLE, targetToken, rewardBalance, 0);
                }
            }

            //Other rewards --> targetToken
            address[] memory _rewardTokens = rewardTokens();
            uint256 rewardsLength = _rewardTokens.length;
            if (rewardsLength > 0) {
                address currentReward;
                for (uint256 i; i < rewardsLength; ++i) {
                    currentReward = _rewardTokens[i];
                    if (currentReward != targetToken) {
                        rewardBalance = ERC20(currentReward).balanceOf(address(this));
                        if (rewardBalance > minAmountToSellMapping[currentReward]) {
                            _swapFrom(currentReward, targetToken, rewardBalance, 0);
                        }
                    }
                }
            }
        }

        // If the maturity of the Pendle LP is reached, we cannot compound anymore.
        if (_isExpired()) return;

        //Create asset from targetToken:
        //targetToken --> SY
        rewardBalance = ERC20(targetToken).balanceOf(address(this));
        if (rewardBalance <= minAmountToSellMapping[targetToken]) return; //set minAmountToSell for targetToken in case of deposit minimum in SY
        uint256 payableBalance;
        address depositToken;
        if (unwrapTargetTokenToSY) { //for pools that require unwrapped gas as SY deposit asset
            IWETH(targetToken).withdraw(rewardBalance);
            payableBalance = rewardBalance;
            depositToken = address(0); //unwrapped
        } else {
            depositToken = targetToken;
        }
        ISY(SY).deposit{value: payableBalance}(address(this), depositToken, rewardBalance, 0);
        rewardBalance = ERC20(SY).balanceOf(address(this));

        //SY --> asset
        if (rewardBalance == 0) return;
        IPendleRouter.LimitOrderData memory limit; //skip limit order by passing zero address
        IPendleRouter(pendleRouter).addLiquiditySingleSy(address(this), address(asset), rewardBalance, 0, routerParams, limit);
    }

    function _balanceAsset() internal view returns (uint256) {
        return ERC20(asset).balanceOf(address(this));
    }

    function _balanceStaked() internal view returns (uint256) {
        return IMarketDepositHelper(marketDepositHelper).balance(address(asset), address(this));
    }
    
    function _balancePENDLE() internal view returns (uint256) {
        return ERC20(PENDLE).balanceOf(address(this));
    }

    function _isExpired() internal view returns (bool) {
        return IPendleMarket(address(asset)).isExpired();
    }

    /*//////////////////////////////////////////////////////////////
                EXTERNAL:
    //////////////////////////////////////////////////////////////*/

    function balanceAsset() external view returns (uint256) {
        return _balanceAsset();
    }

    function balanceStaked() external view returns (uint256) {
        return _balanceStaked();
    }

    function isExpired() external view returns (bool) {
        return _isExpired();
    }

    /**
     * @notice Set wether or not to keep autocompounding the strategy. Defaults to true. Set this to false to deactivate the strategy completely after a shutdown & emergencyWithdraw to leave everything withdrawable in asset.
     * @param _autocompound Wether or not to deactivate the autocompounding of the strategy.
     */
    function setAutocompound(bool _autocompound) external onlyManagement {
        autocompound = _autocompound;
    }

    /**
     * @notice Set wether to use the trade factory contract address.
     * @param _useTradeFactory wether to use the trade factory or not.
     */
    function setUseTradeFactory(bool _useTradeFactory) external onlyManagement {
        require(tradeFactory() != address(0));
        useTradeFactory = _useTradeFactory;
    }

    /**
     * @notice Remove all the permissions of the tradeFactory and set its address to zero.
     */
    function removeTradeFactory() external onlyManagement {
        require(tradeFactory() != address(0));
        _removeTradeFactoryPermissions();
        useTradeFactory = false;
    }

    /**
     * @notice Add a reward address that will be sold to autocompound the LP.
     * @param _rewardToken address of the reward token to be sold.
     * @param _feeRewardTokenToBase automatic swapping fee tier between rewardToken and base (0.01% = 100, 0.05% = 500, 0.3% = 3000, 1% = 10000).
     */
    function addReward(address _rewardToken, uint24 _feeRewardTokenToBase) external onlyManagement {
        require(_rewardToken != address(asset));
        _setUniFees(_rewardToken, base, _feeRewardTokenToBase);
        _addToken(_rewardToken, address(asset));
        if (targetToken != address(asset)) {
            _addToken(_rewardToken, targetToken);
        }
    }

    /**
     * @notice Remove a reward token to stop it being autocompounded to the LP.
     * @param _rewardToken address of the reward token to be removed.
     */
    function removeReward(address _rewardToken) external onlyManagement {
        _removeToken(_rewardToken, address(asset));
        if (targetToken != address(asset)) {
            _removeToken(_rewardToken, targetToken);
        }
    }

    /**
     * @notice Set the uni fees for swaps.
     * Any incentivized tokens will need a fee to be set for each
     * reward token that it wishes to swap on reports.
     *
     * @param _token0 The first token of the pair.
     * @param _token1 The second token of the pair.
     * @param _fee The fee to be used for the pair.
     */
    function setUniFees(
        address _token0,
        address _token1,
        uint24 _fee
    ) external onlyManagement {
        _setUniFees(_token0, _token1, _fee);
    }

    /**
     * @notice Set the `minAmountToSellMapping` for a specific `_token`.
     * @dev This can be used by management to adjust wether or not the
     * _claimAndSellRewards() function will attempt to sell a specific
     * reward token. This can be used if liquidity is too low, amounts
     * are too low or any other reason that may cause reverts.
     *
     * @param _token The address of the token to adjust.
     * @param _amount Min required amount to sell.
     */
    function setMinAmountToSellMapping(
        address _token,
        uint256 _amount
    ) external onlyManagement {
        minAmountToSellMapping[_token] = _amount;
    }

    /**
     * @notice Set the routerParams for the pendleRouter. Pendle's AMM only supports the built-in swapSyForExactPt. To execute a swapExactSyForPt, the router will conduct a binary search to determine the amount of PT to swap.
     * @param _guessMin The minimum value for binary search. Default: 0.
     * @param _guessMax The maximum value for binary search. Default: type(uint256).max.
     * @param _maxIteration The maximum number of times binary search will be performed. Default: 256.
     * @param _eps The precision of binary search - the maximum proportion of the input that can be unused. Default: 1e15 == max 0.1% unused. Alternatively: 1e14 implies that no more than 0.01% unused.     
     */
    function setRouterParams(uint256 _guessMin, uint256 _guessMax, uint256 _maxIteration, uint256 _eps) external onlyManagement {
        routerParams.guessMin = _guessMin; // default: 0
        routerParams.guessMax = _guessMax; // default: type(uint256).max
        routerParams.maxIteration = _maxIteration; // default: 256
        routerParams.eps = _eps; // default: 1e15 == max 0.1% unused. Alternatively: 1e14 implies that no more than 0.01% unused.
    }

    ///////////// DUTCH AUCTION FUNCTIONS \\\\\\\\\\\\\\\\\\
    function setAuction(address _auction) external onlyEmergencyAuthorized {
        if (_auction != address(0)) {
            address want = Auction(_auction).want();
            require(want == targetToken || want == address(asset), "wrong want");
        }
        auction = _auction;
    }

    function _auctionKicked(address _token) internal virtual override returns (uint256 _kicked) {
        require(_token != address(asset), "asset");
        _kicked = super._auctionKicked(_token);
        require(_kicked >= minAmountToSellMapping[_token], "< minAmount");
    }

    /**
     * @notice Set if tokens should be sold through the dutch auction contract.
     */
    function setUseAuction(bool _useAuction) external onlyManagement {
        useAuction = _useAuction;
    }

    /*//////////////////////////////////////////////////////////////
                EMERGENCY & GOVERNANCE:
    //////////////////////////////////////////////////////////////*/

    function _emergencyWithdraw(uint256 _amount) internal override {
        uint256 stakedBalance = _balanceStaked();
        if (_amount > stakedBalance) {
            _amount = stakedBalance;
        }
        _freeFunds(_amount);
    }

    /**
     * @notice Set the trade factory contract address.
     * @dev For disabling, call removeTradeFactory.
     * @param _tradeFactory The address of the trade factory contract.
     */
    function setTradeFactory(address _tradeFactory, bool _useTradeFactory) external onlyGovernance {
        _setTradeFactory(_tradeFactory, address(asset));
        if (targetToken != address(asset)) { //enable tradeFactory also for targetToken for all rewardTokens 
            address[] memory _rewardTokensLocal = rewardTokens();
            uint256 rewardsLength = _rewardTokensLocal.length;
            for (uint256 i; i < rewardsLength; ++i) {
                address reward = _rewardTokensLocal[i];
                ITradeFactory(_tradeFactory).enable(reward, targetToken);
            }
        }
        useTradeFactory = _useTradeFactory;
    }

    /// @notice Sweep of non-asset ERC20 tokens to governance (onlyGovernance)
    /// @param _token The ERC20 token to sweep
    function sweep(address _token) external onlyGovernance {
        require(_token != address(asset), "!asset");
        ERC20(_token).safeTransfer(GOV, ERC20(_token).balanceOf(address(this)));
    }

    modifier onlyGovernance() {
        require(msg.sender == GOV, "!gov");
        _;
    }

    receive() external payable {}
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
}

interface IStrategy is IBaseStrategy, ITokenizedStrategy {}

interface IStrategyInterface is IStrategy {

    function reportTrigger(
        address _strategy
    ) external view returns (bool, bytes memory);

    function sweep(address _token) external;

    function balanceAsset() external view returns (uint256);
    function balanceStaked() external view returns (uint256);

    function addReward(address _rewardToken, uint24 _feeRewardTokenToBase) external;
    function setProfitLimitRatio(uint256) external;
    function setDoHealthCheck(bool) external;
    function setAutocompound(bool) external;
    function setMinAmountToSellMapping(address, uint256) external;
    function setRouterParams(uint256 _guessMin, uint256 _guessMax, uint256 _maxIteration, uint256 _eps) external;

    function isExpired() external view returns (bool);

    function setTradeFactory(address, bool) external;
    function claimRewards() external;
}

contract PendleLPCompounderFactory {
    event NewPendleLPCompounder(address indexed strategy, address indexed asset);

    address public management;
    address public performanceFeeRecipient;
    address public keeper;

    address internal immutable pendleStaking;
    address internal immutable PENDLE;
    address internal immutable emergencyAdmin;
    address internal immutable GOV;

    mapping(address => address) public assetToStrategy;

    constructor(
        address _management,
        address _peformanceFeeRecipient,
        address _keeper, 
        address _pendleStaking,
        address _PENDLE,
        address _emergencyAdmin,
        address _GOV
    ) {
        management = _management;
        performanceFeeRecipient = _peformanceFeeRecipient;
        keeper = _keeper;
        pendleStaking = _pendleStaking;
        PENDLE = _PENDLE;
        emergencyAdmin = _emergencyAdmin;
        GOV = _GOV;
    }

    modifier onlyManagement() {
        require(msg.sender == management, "!management");
        _;
    }

    /**
     * @notice Deploy a new Gamma Stable LP Compounder Strategy.
     * @return . The address of the new lender.
     */
    function newPendleLPCompounder(
        address _asset,
        uint24 _feePENDLEtoBase, 
        address _base, 
        uint24 _feeBaseToTargetToken, 
        address _targetToken,
        string memory _name
    ) external onlyManagement returns (address) {

        IStrategyInterface newStrategy = IStrategyInterface(address(new PendleLPCompounder(_asset, pendleStaking, PENDLE, _feePENDLEtoBase, _base, _feeBaseToTargetToken, _targetToken, GOV, _name)));

        newStrategy.setPerformanceFeeRecipient(performanceFeeRecipient);

        newStrategy.setKeeper(keeper);

        newStrategy.setPendingManagement(management);

        newStrategy.setEmergencyAdmin(emergencyAdmin);

        emit NewPendleLPCompounder(address(newStrategy), _asset);

        assetToStrategy[_asset] = address(newStrategy);

        return address(newStrategy);
    }

    /**
     * @notice Retrieve the address of a strategy by LP address
     * @param _asset LP address
     * @return strategy address
     */
    function getStrategyByAsset(address _asset) external view returns (address) {
        return assetToStrategy[_asset];
    }

    /**
     * @notice Check if a strategy has been deployed by this Factory
     * @param _strategy strategy address
     */
    function isDeployedStrategy(address _strategy) external view returns (bool) {
        address _asset = IStrategyInterface(_strategy).asset();
        return assetToStrategy[_asset] == _strategy;
    }

    function setStrategyByAsset(address _asset, address _strategy) external onlyManagement {
        assetToStrategy[_asset] = _strategy;
    }

    /**
     * @notice Set the management address.
     * @dev This is the address that can call the management functions.
     * @param _management The address to set as the management address.
     */
    function setManagement(address _management) external onlyManagement {
        require(_management != address(0), "ZERO_ADDRESS");
        management = _management;
    }

    /**
     * @notice Set the performance fee recipient address.
     * @dev This is the address that will receive the performance fee.
     * @param _performanceFeeRecipient The address to set as the performance fee recipient address.
     */
    function setPerformanceFeeRecipient(
        address _performanceFeeRecipient
    ) external onlyManagement {
        require(_performanceFeeRecipient != address(0), "ZERO_ADDRESS");
        performanceFeeRecipient = _performanceFeeRecipient;
    }

    /**
     * @notice Set the keeper address.
     * @dev This is the address that will be able to call the keeper functions.
     * @param _keeper The address to set as the keeper address.
     */
    function setKeeper(address _keeper) external onlyManagement {
        keeper = _keeper;
    }
}