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
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable2Step.sol)

pragma solidity ^0.8.0;

import "./Ownable.sol";

/**
 * @dev Contract module which provides access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership} and {acceptOwnership}.
 *
 * This module is used through inheritance. It will make available all functions
 * from parent (Ownable).
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (interfaces/IERC5267.sol)

pragma solidity ^0.8.0;

interface IERC5267 {
    /**
     * @dev MAY be emitted to signal that the domain could have changed.
     */
    event EIP712DomainChanged();

    /**
     * @dev returns the fields and values that describe the domain separator used by this contract for EIP-712
     * signature.
     */
    function eip712Domain()
        external
        view
        returns (
            bytes1 fields,
            string memory name,
            string memory version,
            uint256 chainId,
            address verifyingContract,
            bytes32 salt,
            uint256[] memory extensions
        );
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
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
// OpenZeppelin Contracts (last updated v4.9.4) (token/ERC20/extensions/IERC20Permit.sol)

pragma solidity ^0.8.0;

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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.3) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/IERC20Permit.sol";
import "../../../utils/Address.sol";

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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
// OpenZeppelin Contracts (last updated v4.9.0) (utils/ShortStrings.sol)

pragma solidity ^0.8.8;

import "./StorageSlot.sol";

// | string  | 0xAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA   |
// | length  | 0x                                                              BB |
type ShortString is bytes32;

/**
 * @dev This library provides functions to convert short memory strings
 * into a `ShortString` type that can be used as an immutable variable.
 *
 * Strings of arbitrary length can be optimized using this library if
 * they are short enough (up to 31 bytes) by packing them with their
 * length (1 byte) in a single EVM word (32 bytes). Additionally, a
 * fallback mechanism can be used for every other case.
 *
 * Usage example:
 *
 * ```solidity
 * contract Named {
 *     using ShortStrings for *;
 *
 *     ShortString private immutable _name;
 *     string private _nameFallback;
 *
 *     constructor(string memory contractName) {
 *         _name = contractName.toShortStringWithFallback(_nameFallback);
 *     }
 *
 *     function name() external view returns (string memory) {
 *         return _name.toStringWithFallback(_nameFallback);
 *     }
 * }
 * ```
 */
library ShortStrings {
    // Used as an identifier for strings longer than 31 bytes.
    bytes32 private constant _FALLBACK_SENTINEL = 0x00000000000000000000000000000000000000000000000000000000000000FF;

    error StringTooLong(string str);
    error InvalidShortString();

    /**
     * @dev Encode a string of at most 31 chars into a `ShortString`.
     *
     * This will trigger a `StringTooLong` error is the input string is too long.
     */
    function toShortString(string memory str) internal pure returns (ShortString) {
        bytes memory bstr = bytes(str);
        if (bstr.length > 31) {
            revert StringTooLong(str);
        }
        return ShortString.wrap(bytes32(uint256(bytes32(bstr)) | bstr.length));
    }

    /**
     * @dev Decode a `ShortString` back to a "normal" string.
     */
    function toString(ShortString sstr) internal pure returns (string memory) {
        uint256 len = byteLength(sstr);
        // using `new string(len)` would work locally but is not memory safe.
        string memory str = new string(32);
        /// @solidity memory-safe-assembly
        assembly {
            mstore(str, len)
            mstore(add(str, 0x20), sstr)
        }
        return str;
    }

    /**
     * @dev Return the length of a `ShortString`.
     */
    function byteLength(ShortString sstr) internal pure returns (uint256) {
        uint256 result = uint256(ShortString.unwrap(sstr)) & 0xFF;
        if (result > 31) {
            revert InvalidShortString();
        }
        return result;
    }

    /**
     * @dev Encode a string into a `ShortString`, or write it to storage if it is too long.
     */
    function toShortStringWithFallback(string memory value, string storage store) internal returns (ShortString) {
        if (bytes(value).length < 32) {
            return toShortString(value);
        } else {
            StorageSlot.getStringSlot(store).value = value;
            return ShortString.wrap(_FALLBACK_SENTINEL);
        }
    }

    /**
     * @dev Decode a string that was encoded to `ShortString` or written to storage using {setWithFallback}.
     */
    function toStringWithFallback(ShortString value, string storage store) internal pure returns (string memory) {
        if (ShortString.unwrap(value) != _FALLBACK_SENTINEL) {
            return toString(value);
        } else {
            return store;
        }
    }

    /**
     * @dev Return the length of a string that was encoded to `ShortString` or written to storage using {setWithFallback}.
     *
     * WARNING: This will return the "byte length" of the string. This may not reflect the actual length in terms of
     * actual characters as the UTF-8 encoding of a single character can span over multiple bytes.
     */
    function byteLengthWithFallback(ShortString value, string storage store) internal view returns (uint256) {
        if (ShortString.unwrap(value) != _FALLBACK_SENTINEL) {
            return byteLength(value);
        } else {
            return bytes(store).length;
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/StorageSlot.sol)
// This file was procedurally generated from scripts/generate/templates/StorageSlot.js.

pragma solidity ^0.8.0;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```solidity
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, `uint256`._
 * _Available since v4.9 for `string`, `bytes`._
 */
library StorageSlot {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    struct StringSlot {
        string value;
    }

    struct BytesSlot {
        bytes value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `StringSlot` with member `value` located at `slot`.
     */
    function getStringSlot(bytes32 slot) internal pure returns (StringSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `StringSlot` representation of the string storage pointer `store`.
     */
    function getStringSlot(string storage store) internal pure returns (StringSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := store.slot
        }
    }

    /**
     * @dev Returns an `BytesSlot` with member `value` located at `slot`.
     */
    function getBytesSlot(bytes32 slot) internal pure returns (BytesSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BytesSlot` representation of the bytes storage pointer `store`.
     */
    function getBytesSlot(bytes storage store) internal pure returns (BytesSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := store.slot
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

import "./math/Math.sol";
import "./math/SignedMath.sol";

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `int256` to its ASCII `string` decimal representation.
     */
    function toString(int256 value) internal pure returns (string memory) {
        return string(abi.encodePacked(value < 0 ? "-" : "", toString(SignedMath.abs(value))));
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
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

    /**
     * @dev Returns true if the two strings are equal.
     */
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../Strings.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV // Deprecated in v4.8
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32 message) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, "\x19Ethereum Signed Message:\n32")
            mstore(0x1c, hash)
            message := keccak256(0x00, 0x3c)
        }
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32 data) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, "\x19\x01")
            mstore(add(ptr, 0x02), domainSeparator)
            mstore(add(ptr, 0x22), structHash)
            data := keccak256(ptr, 0x42)
        }
    }

    /**
     * @dev Returns an Ethereum Signed Data with intended validator, created from a
     * `validator` and `data` according to the version 0 of EIP-191.
     *
     * See {recover}.
     */
    function toDataWithIntendedValidatorHash(address validator, bytes memory data) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x00", validator, data));
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/cryptography/EIP712.sol)

pragma solidity ^0.8.8;

import "./ECDSA.sol";
import "../ShortStrings.sol";
import "../../interfaces/IERC5267.sol";

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding specified in the EIP is very generic, and such a generic implementation in Solidity is not feasible,
 * thus this contract does not implement the encoding itself. Protocols need to implement the type-specific encoding
 * they need in their contracts using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * NOTE: In the upgradeable version of this contract, the cached values will correspond to the address, and the domain
 * separator of the implementation contract. This will cause the `_domainSeparatorV4` function to always rebuild the
 * separator from the immutable values, which is cheaper than accessing a cached version in cold storage.
 *
 * _Available since v3.4._
 *
 * @custom:oz-upgrades-unsafe-allow state-variable-immutable state-variable-assignment
 */
abstract contract EIP712 is IERC5267 {
    using ShortStrings for *;

    bytes32 private constant _TYPE_HASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to
    // invalidate the cached domain separator if the chain id changes.
    bytes32 private immutable _cachedDomainSeparator;
    uint256 private immutable _cachedChainId;
    address private immutable _cachedThis;

    bytes32 private immutable _hashedName;
    bytes32 private immutable _hashedVersion;

    ShortString private immutable _name;
    ShortString private immutable _version;
    string private _nameFallback;
    string private _versionFallback;

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     *
     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
     * contract upgrade].
     */
    constructor(string memory name, string memory version) {
        _name = name.toShortStringWithFallback(_nameFallback);
        _version = version.toShortStringWithFallback(_versionFallback);
        _hashedName = keccak256(bytes(name));
        _hashedVersion = keccak256(bytes(version));

        _cachedChainId = block.chainid;
        _cachedDomainSeparator = _buildDomainSeparator();
        _cachedThis = address(this);
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        if (address(this) == _cachedThis && block.chainid == _cachedChainId) {
            return _cachedDomainSeparator;
        } else {
            return _buildDomainSeparator();
        }
    }

    function _buildDomainSeparator() private view returns (bytes32) {
        return keccak256(abi.encode(_TYPE_HASH, _hashedName, _hashedVersion, block.chainid, address(this)));
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
    }

    /**
     * @dev See {EIP-5267}.
     *
     * _Available since v4.9._
     */
    function eip712Domain()
        public
        view
        virtual
        override
        returns (
            bytes1 fields,
            string memory name,
            string memory version,
            uint256 chainId,
            address verifyingContract,
            bytes32 salt,
            uint256[] memory extensions
        )
    {
        return (
            hex"0f", // 01111
            _name.toStringWithFallback(_nameFallback),
            _version.toStringWithFallback(_versionFallback),
            block.chainid,
            address(this),
            bytes32(0),
            new uint256[](0)
        );
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/SafeCast.sol)
// This file was procedurally generated from scripts/generate/templates/SafeCast.js.

pragma solidity ^0.8.0;

/**
 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 *
 * Can be combined with {SafeMath} and {SignedSafeMath} to extend it to smaller types, by performing
 * all math on `uint256` and `int256` and then downcasting.
 */
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/SignedMath.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard signed math utilities missing in the Solidity language.
 */
library SignedMath {
    /**
     * @dev Returns the largest of two signed numbers.
     */
    function max(int256 a, int256 b) internal pure returns (int256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two signed numbers.
     */
    function min(int256 a, int256 b) internal pure returns (int256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two signed numbers without overflow.
     * The result is rounded towards zero.
     */
    function average(int256 a, int256 b) internal pure returns (int256) {
        // Formula from the book "Hacker's Delight"
        int256 x = (a & b) + ((a ^ b) >> 1);
        return x + (int256(uint256(x) >> 255) & (a ^ b));
    }

    /**
     * @dev Returns the absolute unsigned value of a signed value.
     */
    function abs(int256 n) internal pure returns (uint256) {
        unchecked {
            // must be unchecked in order to support `n = type(int256).min`
            return uint256(n >= 0 ? n : -n);
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IEIP712 {
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IEIP712} from "./IEIP712.sol";

/// @title SignatureTransfer
/// @notice Handles ERC20 token transfers through signature based actions
/// @dev Requires user's token approval on the Permit2 contract
interface ISignatureTransfer is IEIP712 {
    /// @notice Thrown when the requested amount for a transfer is larger than the permissioned amount
    /// @param maxAmount The maximum amount a spender can request to transfer
    error InvalidAmount(uint256 maxAmount);

    /// @notice Thrown when the number of tokens permissioned to a spender does not match the number of tokens being transferred
    /// @dev If the spender does not need to transfer the number of tokens permitted, the spender can request amount 0 to be transferred
    error LengthMismatch();

    /// @notice Emits an event when the owner successfully invalidates an unordered nonce.
    event UnorderedNonceInvalidation(address indexed owner, uint256 word, uint256 mask);

    /// @notice The token and amount details for a transfer signed in the permit transfer signature
    struct TokenPermissions {
        // ERC20 token address
        address token;
        // the maximum amount that can be spent
        uint256 amount;
    }

    /// @notice The signed permit message for a single token transfer
    struct PermitTransferFrom {
        TokenPermissions permitted;
        // a unique value for every token owner's signature to prevent signature replays
        uint256 nonce;
        // deadline on the permit signature
        uint256 deadline;
    }

    /// @notice Specifies the recipient address and amount for batched transfers.
    /// @dev Recipients and amounts correspond to the index of the signed token permissions array.
    /// @dev Reverts if the requested amount is greater than the permitted signed amount.
    struct SignatureTransferDetails {
        // recipient address
        address to;
        // spender requested amount
        uint256 requestedAmount;
    }

    /// @notice Used to reconstruct the signed permit message for multiple token transfers
    /// @dev Do not need to pass in spender address as it is required that it is msg.sender
    /// @dev Note that a user still signs over a spender address
    struct PermitBatchTransferFrom {
        // the tokens and corresponding amounts permitted for a transfer
        TokenPermissions[] permitted;
        // a unique value for every token owner's signature to prevent signature replays
        uint256 nonce;
        // deadline on the permit signature
        uint256 deadline;
    }

    /// @notice A map from token owner address and a caller specified word index to a bitmap. Used to set bits in the bitmap to prevent against signature replay protection
    /// @dev Uses unordered nonces so that permit messages do not need to be spent in a certain order
    /// @dev The mapping is indexed first by the token owner, then by an index specified in the nonce
    /// @dev It returns a uint256 bitmap
    /// @dev The index, or wordPosition is capped at type(uint248).max
    function nonceBitmap(address, uint256) external view returns (uint256);

    /// @notice Transfers a token using a signed permit message
    /// @dev Reverts if the requested amount is greater than the permitted signed amount
    /// @param permit The permit data signed over by the owner
    /// @param owner The owner of the tokens to transfer
    /// @param transferDetails The spender's requested transfer details for the permitted token
    /// @param signature The signature to verify
    function permitTransferFrom(
        PermitTransferFrom memory permit,
        SignatureTransferDetails calldata transferDetails,
        address owner,
        bytes calldata signature
    ) external;

    /// @notice Transfers a token using a signed permit message
    /// @notice Includes extra data provided by the caller to verify signature over
    /// @dev The witness type string must follow EIP712 ordering of nested structs and must include the TokenPermissions type definition
    /// @dev Reverts if the requested amount is greater than the permitted signed amount
    /// @param permit The permit data signed over by the owner
    /// @param owner The owner of the tokens to transfer
    /// @param transferDetails The spender's requested transfer details for the permitted token
    /// @param witness Extra data to include when checking the user signature
    /// @param witnessTypeString The EIP-712 type definition for remaining string stub of the typehash
    /// @param signature The signature to verify
    function permitWitnessTransferFrom(
        PermitTransferFrom memory permit,
        SignatureTransferDetails calldata transferDetails,
        address owner,
        bytes32 witness,
        string calldata witnessTypeString,
        bytes calldata signature
    ) external;

    /// @notice Transfers multiple tokens using a signed permit message
    /// @param permit The permit data signed over by the owner
    /// @param owner The owner of the tokens to transfer
    /// @param transferDetails Specifies the recipient and requested amount for the token transfer
    /// @param signature The signature to verify
    function permitTransferFrom(
        PermitBatchTransferFrom memory permit,
        SignatureTransferDetails[] calldata transferDetails,
        address owner,
        bytes calldata signature
    ) external;

    /// @notice Transfers multiple tokens using a signed permit message
    /// @dev The witness type string must follow EIP712 ordering of nested structs and must include the TokenPermissions type definition
    /// @notice Includes extra data provided by the caller to verify signature over
    /// @param permit The permit data signed over by the owner
    /// @param owner The owner of the tokens to transfer
    /// @param transferDetails Specifies the recipient and requested amount for the token transfer
    /// @param witness Extra data to include when checking the user signature
    /// @param witnessTypeString The EIP-712 type definition for remaining string stub of the typehash
    /// @param signature The signature to verify
    function permitWitnessTransferFrom(
        PermitBatchTransferFrom memory permit,
        SignatureTransferDetails[] calldata transferDetails,
        address owner,
        bytes32 witness,
        string calldata witnessTypeString,
        bytes calldata signature
    ) external;

    /// @notice Invalidates the bits specified in mask for the bitmap at the word position
    /// @dev The wordPos is maxed at type(uint248).max
    /// @param wordPos A number to index the nonceBitmap at
    /// @param mask A bitmap masked against msg.sender's current bitmap at the word position
    function invalidateUnorderedNonces(uint256 wordPos, uint256 mask) external;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {EIP712, ECDSA} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";

import "./libraries/ConstantsLib.sol";
import {ErrorsLib} from "./libraries/ErrorsLib.sol";
import {SafeERC20} from "./libraries/SafeERC20.sol";
import {ICreditVault} from "./interfaces/ICreditVault.sol";
import {ReentrancyGuardTransient} from "./libraries/ReentrancyGuardTransient.sol";

import {NativeLPToken} from "./NativeLPToken.sol";

/// @title CreditVault - Manages trader positions and collateral
/// @notice Handles asset custody, position settlement, and LP token integration
contract CreditVault is ICreditVault, EIP712, Ownable2Step, ReentrancyGuardTransient {
    using SafeERC20 for IERC20;
    using SafeCast for uint256;
    using SafeCast for int256;

    /*//////////////////////////////////////////////////////////////////////////
                                     STATE VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Address that can withdraw protocol fees
    address public feeWithdrawer;

    /// @notice signer for permissioned functions: liquidate, settle, removeCollateral, etc.
    address public signer;

    /// @notice epoch updater address
    address public epochUpdater;

    /// @notice A list of all markets
    NativeLPToken[] public allLPTokens;

    /// @notice Authorized Native Pool, enable market makers to lend funds from this vault for quoting
    /// @dev The credit pool lends tokens from the credit vault and must update the trader's position via a callback.
    mapping(address => bool) public creditPools;

    /// @notice Mapping of accumulated reserveFees per token (token => fee amount)
    mapping(address => uint256) public reserveFees;

    /// @notice (trader => timestamp)
    mapping(address => uint256) public lastEpochUpdateTimestamp;

    /// @notice map from underlying address to LP token
    mapping(address => NativeLPToken) public lpTokens;

    // @notice Mapping to track used nonces for preventing replay attacks
    mapping(uint256 => bool) public nonces;

    /// @notice  trader_address => underlying token => amount (positive for long, negative for short)
    mapping(address => mapping(address => int256)) public positions;

    /// @notice traders' collateral trader => token => amount
    mapping(address => mapping(address => uint256)) public collateral;

    /// @dev If a LP token is supported
    mapping(address => bool) public supportedMarkets;

    /// @notice whitelist for traders (Market Makers)
    mapping(address => bool) public traders;

    /// @notice Maps trader address to settler address which can settle positions on behalf of trader
    mapping(address => address) public traderToSettler;

    /// @notice maps trader to their recipient address
    /// @dev Address receives tokens from settlements and collateral operations
    mapping(address => address) public traderToRecipient;

    /// @notice whitelist traders that can bypass the credit check
    mapping(address => bool) public whitelistTraders;

    /// @notice whitelist for liquidators
    mapping(address => bool) public liquidators;

    /// @notice maps liquidator to their recipient address for liquidations
    mapping(address => address) public liquidatorToRecipient;

    /// @notice Tracks rebalance caps for each trader/liquidator and token
    mapping(address => mapping(address => RebalanceCap)) public rebalanceCaps;

    /*//////////////////////////////////////////////////////////////////////////
                                     CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    constructor() EIP712("Native Credit Vault", "1") {}

    /// @notice Callback function called by NativeRFQPool after swap execution to update trader positions
    /// @dev Only callable by whitelisted NativePools, it's called after the swap is executed
    /// @param trader The address of the market maker
    /// @param tokenIn The address of the token that is selling
    /// @param amountIn The amount of the token that is selling
    /// @param tokenOut The address of the token that is buying
    /// @param amountOut The amount of the token that is buying
    function swapCallback(
        address trader,
        address tokenIn,
        int256 amountIn,
        address tokenOut,
        int256 amountOut
    ) external {
        require(creditPools[msg.sender], ErrorsLib.OnlyCreditPool());
        require(
            address(lpTokens[tokenIn]) != address(0) && address(lpTokens[tokenOut]) != address(0),
            ErrorsLib.InvalidUnderlying()
        );

        positions[trader][tokenIn] += amountIn;
        positions[trader][tokenOut] -= amountOut;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    PERMISSIONED FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Updates funding fees for traders at the end of each epoch
    /// @dev Only callable by the epoch updater
    /// @param accruedFees Array of funding fee updates for different traders
    function epochUpdate(AccruedFundingFee[] calldata accruedFees) external {
        require(msg.sender == epochUpdater, ErrorsLib.OnlyEpochUpdater());

        for (uint256 i; i < accruedFees.length; ++i) {
            address trader = accruedFees[i].trader;

            if (block.timestamp - lastEpochUpdateTimestamp[trader] < EPOCH_UPDATE_INTERVAL) {
                revert ErrorsLib.EpochUpdateInCoolDown();
            }

            for (uint256 j; j < accruedFees[i].feeUpdates.length; ++j) {
                address token = accruedFees[i].feeUpdates[j].token;
                uint256 fundingFee = accruedFees[i].feeUpdates[j].fundingFee;
                uint256 reserveFee = accruedFees[i].feeUpdates[j].reserveFee;

                // Check if the underlying token is supported
                require(address(lpTokens[token]) != address(0), ErrorsLib.InvalidUnderlying());

                if (fundingFee > 0) {
                    uint256 beforeExchangeRate = lpTokens[token].exchangeRate();

                    // Distribute funding fee to all LPToken holders
                    lpTokens[token].distributeYield(fundingFee);

                    // Verify the exchange rate increase is not more than 1%
                    if (((lpTokens[token].exchangeRate() - beforeExchangeRate) * 10_000) > beforeExchangeRate * 100) {
                        revert ErrorsLib.ExchangeRateIncreaseTooMuch();
                    }
                }

                if (reserveFee > 0) {
                    reserveFees[token] += reserveFee;
                }
                // Subtract reserve fee and funding fee from the trader's position
                positions[trader][token] -= (reserveFee + fundingFee).toInt256();
            }

            lastEpochUpdateTimestamp[trader] = block.timestamp;
        }

        emit EpochUpdated(accruedFees);
    }

    /// @notice Called by traders to settle the positions
    /// @dev This transaction requires off-chain calculation to verify if the trader's credit meets the criteria.
    /// @param request The struct of the settlement request containing info of long and short positions to settle
    /// @param signature The signature of the settlement request
    function settle(
        SettlementRequest calldata request,
        bytes calldata signature
    ) external onlyTraderOrSettler(request.trader) nonReentrant {
        _verifySettleSignature(request, signature);

        _updatePositions(request.positionUpdates, request.trader);

        address recipient = traderToRecipient[request.trader];

        // execute token transfers
        for (uint256 i; i < request.positionUpdates.length; ++i) {
            address token = request.positionUpdates[i].token;
            int256 amount = request.positionUpdates[i].amount;

            if (amount > 0) {
                IERC20(token).safeTransferFrom(msg.sender, address(this), amount.toUint256());
            } else {
                /// Enforce rebalance cap before funds leave vault to ensure limit compliance
                _updateRebalanceCap(request.trader, token, (-amount).toUint256());

                IERC20(token).safeTransfer(recipient, (-amount).toUint256());
            }
        }

        emit Settled(request.trader, request.positionUpdates);
    }

    /// @notice Called by traders to remove collateral
    /// @dev This transaction requires off-chain calculation to verify if the trader's credit meets the criteria.
    /// @param request The struct of the remove collateral request containing info of collateral to remove
    /// @param signature The signature of the remove collateral request
    function removeCollateral(
        RemoveCollateralRequest calldata request,
        bytes calldata signature
    ) external onlyTraderOrSettler(request.trader) nonReentrant {
        _verifyRemoveCollateralSignature(request, signature);

        for (uint256 i; i < request.tokens.length; ++i) {
            collateral[request.trader][request.tokens[i].token] -= request.tokens[i].amount;
        }

        address recipient = traderToRecipient[request.trader];
        for (uint256 i; i < request.tokens.length; ++i) {
            address token = request.tokens[i].token;
            uint256 amount = request.tokens[i].amount;

            /// Enforce rebalance cap before funds leave vault
            _updateRebalanceCap(request.trader, token, amount);

            IERC20(token).safeTransfer(recipient, amount);
        }

        emit CollateralRemoved(request.trader, request.tokens);
    }

    /// @notice Repays trader's short positions
    /// @param positionUpdates Array of {token, amount} structs representing positions to repay
    /// @param trader Address of the trader whose positions are being repaid
    function repay(
        TokenAmountInt[] calldata positionUpdates,
        address trader
    ) external onlyTraderOrSettler(trader) nonReentrant {
        _updatePositions(positionUpdates, trader);

        // the safeCast to Uint256 will revert if the repayments amount is negative
        for (uint256 i; i < positionUpdates.length; ++i) {
            IERC20(positionUpdates[i].token).safeTransferFrom(
                msg.sender, address(this), positionUpdates[i].amount.toUint256()
            );
        }

        emit Repaid(trader, positionUpdates);
    }

    /// @notice Called by liquidators to liquidate the underwater positions
    /// @dev This transaction requires off-chain calculation to verify if the trader's credit meets the criteria.
    /// @param request The struct of the liquidation request containing info of long and short positions to liquidate
    /// @param signature The signature of the liquidation request
    function liquidate(
        LiquidationRequest calldata request,
        bytes calldata signature
    ) external onlyLiquidator nonReentrant {
        _verifyLiquidationSignature(request, signature);

        _updatePositions(request.positionUpdates, request.trader);

        address recipient = liquidatorToRecipient[msg.sender];

        for (uint256 i; i < request.claimCollaterals.length; ++i) {
            collateral[request.trader][request.claimCollaterals[i].token] -= request.claimCollaterals[i].amount;
        }

        for (uint256 i; i < request.positionUpdates.length; ++i) {
            address token = request.positionUpdates[i].token;
            int256 amount = request.positionUpdates[i].amount;

            if (amount > 0) {
                IERC20(token).safeTransferFrom(msg.sender, address(this), amount.toUint256());
            } else {
                /// Enforce rebalance cap before underlying token leave vault
                _updateRebalanceCap(msg.sender, token, (-amount).toUint256());

                IERC20(token).safeTransfer(recipient, (-amount).toUint256());
            }
        }

        for (uint256 i; i < request.claimCollaterals.length; ++i) {
            address token = request.claimCollaterals[i].token;

            /// Enforce rebalance cap before collateral token leave vault
            _updateRebalanceCap(msg.sender, token, request.claimCollaterals[i].amount);

            IERC20(token).safeTransfer(recipient, request.claimCollaterals[i].amount);
        }

        emit Liquidated(request.trader, msg.sender, request.positionUpdates, request.claimCollaterals);
    }

    /// @notice Transfers underlying assets from vault to recipient
    /// @dev Only callable by supported LP tokens
    /// @param to Recipient of the underlying assets
    /// @param amount Amount of underlying assets to transfer
    function pay(address to, uint256 amount) external {
        require(supportedMarkets[msg.sender], ErrorsLib.OnlyLpToken());
        require(amount <= NativeLPToken(msg.sender).totalUnderlying(), ErrorsLib.InsufficientUnderlying());

        // Each LP token can only transfer its own underlying token
        IERC20(NativeLPToken(msg.sender).underlying()).safeTransfer(to, amount);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    PERMISSIONLESS FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Adds collateral for a trader's position
    /// @dev PERMISSIONLESS: Anyone can add collateral for any trader
    /// @dev Off-chain system will update trader's credit limit off-chain via event emission
    /// @param tokens Array of {token, amount} structs to be added as collateral
    /// @param trader Address of the trader receiving the collateral
    function addCollateral(TokenAmountUint[] calldata tokens, address trader) external nonReentrant {
        require(traders[trader], ErrorsLib.OnlyTrader());

        for (uint256 i; i < tokens.length; ++i) {
            address token = tokens[i].token;
            require(supportedMarkets[token], ErrorsLib.OnlyLpToken());

            uint256 amount = tokens[i].amount;
            collateral[trader][token] += amount;

            IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        }

        emit CollateralAdded(trader, tokens);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                ADMIN FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Lists a new market (LP token)
    /// @dev Only callable by owner
    /// @param lpToken Address of the LP token to be listed
    function supportMarket(NativeLPToken lpToken) external onlyOwner {
        // Check if market is already listed
        require(!supportedMarkets[address(lpToken)], ErrorsLib.TokenAlreadyListed());

        address underlying = address(lpToken.underlying());

        // Verify market configuration
        require(
            address(lpTokens[underlying]) == address(0) && lpToken.creditVault() == address(this),
            ErrorsLib.InvalidMarket()
        );

        // Sanity check to make sure its really LPToken
        require(address(underlying) != address(0), ErrorsLib.InvalidLPToken());

        // Update storage
        lpTokens[underlying] = lpToken;
        supportedMarkets[address(lpToken)] = true;
        allLPTokens.push(lpToken);

        emit MarketListed(address(lpToken));
    }

    /// @notice Allows fee withdrawer to claim accumulated funding fees
    /// @dev Only callable by feeWithdrawer
    /// @param underlying The token address of the fees to withdraw
    /// @param recipient The address that will receive the fees
    /// @param amount The amount of fees to withdraw
    function withdrawReserve(address underlying, address recipient, uint256 amount) external {
        require(recipient != address(0), ErrorsLib.ZeroAddress());
        require(msg.sender == feeWithdrawer, ErrorsLib.OnlyFeeWithdrawer());
        require(amount <= reserveFees[underlying], ErrorsLib.InsufficientFundingFees());

        reserveFees[underlying] -= amount;

        // Withdraw underlying from vault
        IERC20(underlying).safeTransfer(recipient, amount);

        emit ReserveWithdrawn(underlying, recipient, amount);
    }

    /// @notice Updates credit pool status
    /// @param pool The address of credit pool
    /// @param isActive to whitelist, false to remove from whitelist
    function setCreditPool(address pool, bool isActive) external onlyOwner {
        require(pool != address(0), ErrorsLib.ZeroAddress());

        creditPools[pool] = isActive;

        emit CreditPoolUpdated(pool, isActive);
    }

    /// @notice Approves native pool to spend vault's underlying tokens
    /// @dev Only callable by owner
    /// @dev Pool must be whitelisted as native pool
    /// @param tokens Array of {token, amount} structs to approve
    /// @param pool Address of native pool to receive approval
    function setAllowance(TokenAmountUint[] calldata tokens, address pool) external onlyOwner {
        for (uint256 i; i < tokens.length; ++i) {
            require(address(lpTokens[tokens[i].token]) != address(0), ErrorsLib.InvalidUnderlying());

            IERC20(tokens[i].token).safeApprove(pool, tokens[i].amount);
        }
    }

    /// @notice Set or update the daily rebalance limit for a specific trader or liquidator and token
    /// @dev A limit of 0 means unlimited rebalancing is allowed
    /// @param operator The address of the trader or liquidator whose limit is being set
    /// @param token The token address for which the limit applies
    /// @param limit The maximum amount of tokens that can be rebalanced per day (0 for unlimited)
    function setRebalanceCap(address operator, address token, uint256 limit) external onlyOwner {
        require(token != address(0), ErrorsLib.ZeroAddress());
        require(traders[operator] || liquidators[operator], ErrorsLib.NotTraderOrLiquidator());

        // used will be reset to 0
        rebalanceCaps[operator][token] = RebalanceCap({limit: limit, used: 0, lastDay: block.timestamp / 86_400});

        emit RebalanceCapUpdated(operator, token, limit);
    }

    /// @notice Manages trader permissions and settlement addresses
    /// @dev Only callable by owner
    /// @param trader Address to configure trading permissions for
    /// @param settler Address authorized to settle positions on trader's behalf
    /// @param recipient Address authorized to receive tokens from settlements and collateral operations
    /// @param isTrader True to enable trading, false to revoke permissions
    /// @param isWhitelistTrader True to enable whitelist which can bypass credit check
    function setTrader(
        address trader,
        address settler,
        address recipient,
        bool isTrader,
        bool isWhitelistTrader
    ) external onlyOwner {
        require(trader != address(0) && settler != address(0) && recipient != address(0), ErrorsLib.ZeroAddress());
        require(recipient != trader && recipient != settler, ErrorsLib.TraderRecipientConflict());

        traders[trader] = isTrader;
        traderToSettler[trader] = settler;
        traderToRecipient[trader] = recipient;

        whitelistTraders[trader] = isWhitelistTrader;

        emit TraderSet(trader, isTrader, isWhitelistTrader, settler, recipient);
    }

    /// @notice Set or remove liquidator permissions
    /// @dev Only callable by owner
    /// @param liquidator The address to grant/revoke liquidator permissions
    /// @param recipient Address authorized to receive tokens from liquidations
    /// @param status True to whitelist, false to remove from whitelist
    function setLiquidator(address liquidator, address recipient, bool status) external onlyOwner {
        require(liquidator != address(0) && recipient != address(0), ErrorsLib.ZeroAddress());
        require(liquidator != recipient, ErrorsLib.LiquidatorRecipientConflict());

        liquidators[liquidator] = status;
        liquidatorToRecipient[liquidator] = recipient;

        emit LiquidatorSet(liquidator, status);
    }

    /// @notice Updates the authorized signer for permissioned operations
    /// @dev Only callable by owner
    /// @dev Signer verifies signatures for settlements, liquidations, and collateral removals
    /// @param _signer New signer address (cannot be zero address)
    function setSigner(address _signer) external onlyOwner {
        require(_signer != address(0), ErrorsLib.ZeroAddress());

        signer = _signer;

        emit SignerSet(_signer);
    }

    /// @notice Updates the authorized epoch updater address
    /// @dev Only callable by owner
    /// @dev Epoch updater is responsible for funding fee updates and distributions
    /// @param _epochUpdater New epoch updater address (cannot be zero address)
    function setEpochUpdater(address _epochUpdater) external onlyOwner {
        require(_epochUpdater != address(0), ErrorsLib.ZeroAddress());

        epochUpdater = _epochUpdater;

        emit EpochUpdaterSet(_epochUpdater);
    }

    /// @notice Updates the authorized fee withdrawer address
    /// @dev Only callable by owner
    /// @dev Fee withdrawer can claim accumulated funding fees from the vault
    /// @param _feeWithdrawer New fee withdrawer address (cannot be zero address)
    function setFeeWithdrawer(address payable _feeWithdrawer) external onlyOwner {
        require(_feeWithdrawer != address(0), ErrorsLib.ZeroAddress());

        feeWithdrawer = _feeWithdrawer;

        emit FeeWithdrawerSet(_feeWithdrawer);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                     INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    function _updateNonce(uint256 nonce) internal {
        require(!nonces[nonce], ErrorsLib.NonceUsed());

        nonces[nonce] = true;
    }

    function _updatePositions(ICreditVault.TokenAmountInt[] memory positionUpdates, address trader) internal {
        uint256 updatesLength = positionUpdates.length;
        for (uint256 i; i < updatesLength; ++i) {
            address token = positionUpdates[i].token;
            int256 amount = positionUpdates[i].amount;
            int256 newPosition = positions[trader][token] + amount;
            // Make sure the token is supported underlying token
            require(address(lpTokens[token]) != address(0), ErrorsLib.InvalidLPToken());

            // Position must decrease without flipping its sign (e.g. long 100 -> long 50, not long 100 -> short 20)
            if (positions[trader][token] * amount >= 0 || positions[trader][token] * newPosition < 0) {
                revert ErrorsLib.InvalidPositionUpdateAmount();
            }

            positions[trader][token] = newPosition;
        }
    }

    /// @notice Check and update daily rebalance tracking for a trader's token position
    /// @param trader The address of the trader attempting to rebalance
    /// @param token The token address being rebalanced, can be underlying token or collateral token
    /// @param amount The amount of tokens being rebalanced
    function _updateRebalanceCap(address trader, address token, uint256 amount) internal {
        RebalanceCap storage cap = rebalanceCaps[trader][token];
        uint256 currentDay = block.timestamp / 86_400;
        uint256 newUsed;

        // Reset daily used amount if it's a new day, otherwise add to existing
        if (currentDay > cap.lastDay) {
            newUsed = amount;
        } else {
            newUsed = cap.used + amount;
        }

        // Check if rebalance would exceed daily limit, skip check if limit is 0 (unlimited)
        require(cap.limit == 0 || newUsed <= cap.limit, ErrorsLib.RebalanceLimitExceeded());

        // Update storage in a single write
        rebalanceCaps[trader][token] = RebalanceCap({limit: cap.limit, used: newUsed, lastDay: currentDay});
    }

    function _verifySettleSignature(
        ICreditVault.SettlementRequest calldata request,
        bytes calldata signature
    ) internal {
        require(request.deadline >= block.timestamp, ErrorsLib.RequestExpired());

        _updateNonce(request.nonce);

        bytes32 msgHash = keccak256(
            abi.encode(
                SETTLEMENT_REQUEST_SIGNATURE_HASH,
                request.nonce,
                request.deadline,
                request.trader,
                keccak256(abi.encode(request.positionUpdates)),
                traderToRecipient[request.trader]
            )
        );
        bytes32 digest = _hashTypedDataV4(msgHash);
        address recoveredSigner = ECDSA.recover(digest, signature);

        require(recoveredSigner == signer, ErrorsLib.InvalidSignature());
    }

    function _verifyRemoveCollateralSignature(
        ICreditVault.RemoveCollateralRequest calldata request,
        bytes calldata signature
    ) internal {
        require(request.deadline >= block.timestamp, ErrorsLib.RequestExpired());

        _updateNonce(request.nonce);

        bytes32 msgHash = keccak256(
            abi.encode(
                REMOVE_COLLATERAL_REQUEST_SIGNATURE_HASH,
                request.nonce,
                request.deadline,
                request.trader,
                keccak256(abi.encode(request.tokens)),
                traderToRecipient[request.trader]
            )
        );
        bytes32 digest = _hashTypedDataV4(msgHash);
        address recoveredSigner = ECDSA.recover(digest, signature);

        require(recoveredSigner == signer, ErrorsLib.InvalidSignature());
    }

    function _verifyLiquidationSignature(
        ICreditVault.LiquidationRequest calldata request,
        bytes calldata signature
    ) internal {
        require(request.deadline >= block.timestamp, ErrorsLib.RequestExpired());

        _updateNonce(request.nonce);

        bytes32 msgHash = keccak256(
            abi.encode(
                LIQUIDATION_REQUEST_SIGNATURE_HASH,
                request.nonce,
                request.deadline,
                request.trader,
                keccak256(abi.encode(request.positionUpdates)),
                keccak256(abi.encode(request.claimCollaterals)),
                liquidatorToRecipient[msg.sender]
            )
        );
        bytes32 digest = _hashTypedDataV4(msgHash);
        address recoveredSigner = ECDSA.recover(digest, signature);

        require(recoveredSigner == signer, ErrorsLib.InvalidSignature());
    }

    /*//////////////////////////////////////////////////////////////////////////
                                     MODIFIERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Separate the trader and settler accounts, they have different operation frequency and security setup requirements
    modifier onlyTraderOrSettler(address trader) {
        require(
            (traders[trader] && trader == msg.sender) // Make sure a trader can only dispose of their own position
                || (traders[trader] && msg.sender == traderToSettler[trader]), // Trader's settler can also settle their own position
            ErrorsLib.OnlyTrader()
        );
        _;
    }

    modifier onlyLiquidator() {
        require(liquidators[msg.sender], ErrorsLib.OnlyLiquidator());
        _;
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import "./libraries/ConstantsLib.sol";
import {CreditVault} from "./CreditVault.sol";
import {ErrorsLib} from "./libraries/ErrorsLib.sol";
import {ReentrancyGuardTransient} from "./libraries/ReentrancyGuardTransient.sol";

/// @title NativeLPToken - Yield-bearing LP token contract
/// @notice A token contract that represents liquidity provider positions and distributes yield
/// @dev This contract manages LP shares and underlying assets, accruing yield based on protocol revenue
contract NativeLPToken is ERC20, Ownable, ReentrancyGuardTransient {
    using SafeERC20 for IERC20Metadata;

    /*//////////////////////////////////////////////////////////////////////////
                                     STATE VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Whether deposit operations are paused
    bool public depositPaused;

    /// @notice Whether redeem operations are paused
    bool public redeemPaused;

    /// @notice The underlying token that this LP token represents
    IERC20Metadata public underlying;

    /// @notice The address of the credit vault contract
    address public creditVault;

    /// @notice The number of decimals for this token, matching the underlying token's decimals
    uint8 private _decimals;

    /// @notice Early withdrawal fee in basis points (1 bip = 0.01%)
    /// @dev Applied to prevent front-running by users who deposit right before yield distribution and immediately redeem after
    uint256 public earlyWithdrawFeeBips;

    /// @notice Total amount of underlying assets deposited by LPs
    uint256 public totalUnderlying;

    /// @notice Total number of shares issued
    uint256 public totalShares;

    /// @notice Minimum time interval between deposit and redeem (in seconds)
    uint256 public minRedeemInterval = 8 hours;

    /// @notice Minimum amount required for deposits
    uint256 public minDeposit;

    /// @notice Mapping of user addresses to their share balances
    mapping(address => uint256) public shares;

    /// @notice Mapping of user addresses to their last deposit timestamp
    mapping(address => uint256) public lastDepositTimestamp;

    /// @notice Mapping of addresses to their whitelist status for cooldown and early withdraw bypass
    mapping(address => bool) public whitelist;

    /*//////////////////////////////////////////////////////////////////////////
                                        EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Event emitted when deposit operation is paused
    event DepositPaused();

    /// @notice Event emitted when deposit operation is unpaused
    event DepositUnpaused();

    /// @notice Event emitted when redeem operation is paused
    event RedeemPaused();

    /// @notice Event emitted when redeem operation is unpaused
    event RedeemUnpaused();

    /// @notice Event emitted when yield is distributed to LP holders
    event YieldDistributed(uint256 yieldAmount);

    /// @notice Event emitted when minimum redeem interval is updated
    event MinRedeemIntervalUpdated(uint256 newInterval);

    /// @notice Event emitted when shares are transferred between addresses
    event TransferShares(address indexed from, address indexed to, uint256 shares);

    /// @notice Event emitted when new shares are minted
    event SharesMinted(address indexed user, uint256 shares, uint256 underlyingAmount);

    /// @notice Event emitted when shares are burned
    event SharesBurned(address indexed user, uint256 shares, uint256 underlyingAmount);

    /// @notice Event emitted when minimum deposit amount is updated
    event MinDepositUpdated(uint256 oldAmount, uint256 newAmount);

    /// @notice Event emitted when early withdraw fee is updated
    event EarlyWithdrawFeeBipsUpdated(uint256 oldFeeBips, uint256 newFeeBips);

    /// @notice Event emitted when an address's whitelist status is updated
    event WhitelistUpdated(address indexed account, bool status);

    /*//////////////////////////////////////////////////////////////////////////
                                     CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    constructor(
        string memory _name,
        string memory _symbol,
        address _underlying,
        address _creditVault
    ) ERC20(_name, _symbol) {
        underlying = IERC20Metadata(_underlying);
        creditVault = _creditVault;

        _decimals = IERC20Metadata(address(underlying)).decimals();
    }

    /// @notice Deposit underlying tokens to mint LP tokens
    /// @param amount Amount of underlying tokens to deposit
    /// @return sharesToMint Amount of LP tokens minted
    function deposit(uint256 amount)
        external
        nonReentrant
        whenNotPaused(depositPaused)
        returns (uint256 sharesToMint)
    {
        require(amount >= minDeposit && amount > 0, ErrorsLib.BelowMinimumDeposit());

        // Transfer underlying to vault
        uint256 balanceBefore = underlying.balanceOf(creditVault);
        underlying.safeTransferFrom(msg.sender, creditVault, amount);
        amount = underlying.balanceOf(creditVault) - balanceBefore;

        // Calculate shares to mint
        if (totalShares == 0) {
            sharesToMint = amount; // Initial shares 1:1
        } else {
            sharesToMint = (amount * totalShares) / totalUnderlying;
        }

        // Mint shares
        _mintShares(msg.sender, sharesToMint);

        // Update total underlying
        totalUnderlying += amount;

        lastDepositTimestamp[msg.sender] = block.timestamp;

        emit SharesMinted(msg.sender, sharesToMint, amount);
    }

    /// @notice Redeem LP tokens for underlying tokens
    /// @param sharesToBurn Amount of LP tokens to burn
    /// @return underlyingAmount Amount of underlying tokens received
    function redeem(uint256 sharesToBurn)
        external
        nonReentrant
        whenNotPaused(redeemPaused)
        returns (uint256 underlyingAmount)
    {
        require(sharesToBurn > 0, ErrorsLib.ZeroAmount());
        require(shares[msg.sender] >= sharesToBurn, ErrorsLib.InsufficientShares());

        // Calculate underlying amount
        underlyingAmount = (sharesToBurn * totalUnderlying) / totalShares;

        if (
            block.timestamp < lastDepositTimestamp[msg.sender] + minRedeemInterval && earlyWithdrawFeeBips > 0
                && !whitelist[msg.sender]
        ) {
            underlyingAmount -= (underlyingAmount * earlyWithdrawFeeBips) / 10_000;
        }

        // Burn shares first
        _burnShares(msg.sender, sharesToBurn);

        // Transfer underlying from vault to msg.sender
        uint256 balanceBefore = underlying.balanceOf(creditVault);
        CreditVault(creditVault).pay(msg.sender, underlyingAmount);
        underlyingAmount = balanceBefore - underlying.balanceOf(creditVault);

        // Update total underlying
        totalUnderlying -= underlyingAmount;

        emit SharesBurned(msg.sender, sharesToBurn, underlyingAmount);
    }

    /// @notice Distributes yield to LP token holders
    /// @param yieldAmount Amount of yield to distribute
    /// @dev Can only be called by the credit vault
    function distributeYield(uint256 yieldAmount) external {
        require(totalShares > 0, ErrorsLib.PoolNotInitialized());
        require(yieldAmount > 0, ErrorsLib.NoYieldToDistribute());
        require(msg.sender == creditVault, ErrorsLib.OnlyCreditVault());

        totalUnderlying += yieldAmount;

        emit YieldDistributed(yieldAmount);
    }

    /// @notice Gets the underlying token balance of an account
    /// @param account The address to check the balance for
    /// @return The amount of underlying tokens the account effectively owns
    function balanceOf(address account) public view override returns (uint256) {
        return getUnderlyingByShares(shares[account]);
    }

    /// @notice Gets the total supply of underlying tokens in the pool
    /// @return The total amount of underlying tokens managed by this contract
    function totalSupply() public view override returns (uint256) {
        return totalUnderlying;
    }

    /// @notice Gets the number of shares owned by an account
    /// @param account The address to check shares for
    /// @return The number of shares owned by the account
    function sharesOf(address account) public view returns (uint256) {
        return shares[account];
    }

    /// @notice Calculates the underlying token amount for a given number of shares
    /// @param sharesAmount The number of shares to convert
    /// @return The corresponding amount of underlying tokens
    function getUnderlyingByShares(uint256 sharesAmount) public view returns (uint256) {
        if (totalShares == 0) {
            return sharesAmount;
        }
        return (sharesAmount * totalUnderlying) / totalShares;
    }

    /// @notice Calculates the number of shares for a given amount of underlying tokens
    /// @param underlyingAmount The amount of underlying tokens to convert
    /// @return The corresponding number of shares
    function getSharesByUnderlying(uint256 underlyingAmount) public view returns (uint256) {
        if (totalShares == 0) {
            return underlyingAmount;
        }
        return (underlyingAmount * totalShares) / totalUnderlying;
    }

    /// @notice Gets the current exchange rate between shares and underlying tokens
    /// @return The exchange rate scaled by 1e18 (1:1 = 1e18)
    function exchangeRate() public view returns (uint256) {
        if (totalShares == 0) {
            return 1e18; // Initial exchange rate 1:1
        }
        return (totalUnderlying * 1e18) / totalShares;
    }

    /// @notice Gets the number of decimals for this token
    /// @return The number of decimals, matching the underlying token
    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    /// @notice Sets the minimum deposit amount
    /// @param _minDeposit New minimum deposit amount
    /// @dev Can only be called by the owner
    function setMinDeposit(uint256 _minDeposit) external onlyOwner {
        uint256 oldAmount = minDeposit;
        minDeposit = _minDeposit;
        emit MinDepositUpdated(oldAmount, _minDeposit);
    }

    /// @notice Sets the minimum time interval required between deposit and redeem
    /// @param _interval New minimum interval in seconds
    /// @dev Can only be called by the owner
    function setMinRedeemInterval(uint256 _interval) external onlyOwner {
        minRedeemInterval = _interval;

        emit MinRedeemIntervalUpdated(_interval);
    }

    /// @notice Sets the early withdrawal fee in basis points (BIPs)
    /// @param _earlyWithdrawFeeBips New early withdrawal fee in BIPs
    /// @dev Can only be called by the owner
    function setEarlyWithdrawFeeBips(uint256 _earlyWithdrawFeeBips) external onlyOwner {
        require(_earlyWithdrawFeeBips <= MAX_EARLY_WITHDRAW_FEE_BIPS, ErrorsLib.InvalidFeeBips());

        uint256 oldFeeBips = earlyWithdrawFeeBips;
        earlyWithdrawFeeBips = _earlyWithdrawFeeBips;

        emit EarlyWithdrawFeeBipsUpdated(oldFeeBips, _earlyWithdrawFeeBips);
    }

    /// @notice Sets the whitelist status for an address to bypass cooldown and early withdraw
    /// @param account The address to update
    /// @param status The new whitelist status
    function setWhitelist(address account, bool status) external onlyOwner {
        require(account != address(0), ErrorsLib.ZeroAddress());

        whitelist[account] = status;
        emit WhitelistUpdated(account, status);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                     PAUSE OPERATIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Function to pause deposit operation
    function pauseDeposit() external onlyOwner {
        depositPaused = true;
        emit DepositPaused();
    }

    /// @notice Function to unpause deposit operation
    function unpauseDeposit() external onlyOwner {
        depositPaused = false;
        emit DepositUnpaused();
    }

    /// @notice Function to pause redeem operation
    function pauseRedeem() external onlyOwner {
        redeemPaused = true;
        emit RedeemPaused();
    }

    /// @notice Function to unpause redeem operation
    function unpauseRedeem() external onlyOwner {
        redeemPaused = false;
        emit RedeemUnpaused();
    }

    modifier whenNotPaused(bool feature) {
        if (feature) {
            revert ErrorsLib.FeaturePaused();
        }
        _;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    function _mintShares(address to, uint256 shareAmount) internal {
        require(shareAmount > 0, ErrorsLib.ZeroAmount());
        require(to != address(0), ErrorsLib.ZeroAddress());

        shares[to] += shareAmount;
        totalShares += shareAmount;
    }

    function _burnShares(address from, uint256 shareAmount) internal {
        require(shareAmount > 0, ErrorsLib.ZeroAmount());
        require(from != address(0), ErrorsLib.ZeroAddress());

        shares[from] -= shareAmount;
        totalShares -= shareAmount;
    }

    function _transferShares(address from, address to, uint256 _shares) internal {
        require(from != address(0) && to != address(0), ErrorsLib.ZeroAddress());
        require(from != to, ErrorsLib.TransferSelf());
        require(to != address(this), ErrorsLib.TransferToContract());
        require(_shares <= shares[from], ErrorsLib.InsufficientShares());

        shares[from] -= _shares;
        shares[to] += _shares;
    }

    /// @notice Override ERC20's _transfer to handle yield-bearing LP token transfers
    /// @dev Since this is a yield-bearing token, the actual transfer is done by transferring shares
    ///      rather than token amounts directly. The shares represent the user's proportion of the
    ///      total underlying assets including yield.
    /// @param from The address to transfer from
    /// @param to The address to transfer to
    /// @param amount The underlying token amount to transfer
    function _transfer(address from, address to, uint256 amount) internal override {
        // During cooldown period, user can't transfer shares, but can still redeem
        require(
            lastDepositTimestamp[from] + minRedeemInterval <= block.timestamp || whitelist[from],
            ErrorsLib.TransferInCooldown()
        );

        uint256 sharesToTransfer = getSharesByUnderlying(amount);
        _transferShares(from, to, sharesToTransfer);
        emit Transfer(from, to, amount);
        emit TransferShares(from, to, sharesToTransfer);
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {EIP712, ECDSA} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";

import "./libraries/ConstantsLib.sol";
import {ErrorsLib} from "./libraries/ErrorsLib.sol";

import {IWETH9} from "./interfaces/IWETH9.sol";
import {ICreditVault} from "./interfaces/ICreditVault.sol";
import {INativeRFQPool} from "./interfaces/INativeRFQPool.sol";

contract NativeRFQPool is INativeRFQPool, Ownable2Step, EIP712 {
    using SafeERC20 for IERC20;
    using SafeCast for int256;
    using SafeCast for uint256;
    using Address for address payable;

    /// @notice Flag to indicate if this pool uses credit vault funds for market making
    /// @dev If true, market maker uses credit vault funds for quotes. If false, market maker uses their own funds
    bool public immutable isCreditPool;

    /// @notice The Pool name
    /// @dev Every market maker has their own pool if they use their own funds to quote
    string public name;

    /// @notice Address of the router contract that can execute trades
    address public router;

    /// @dev Address of the Wrapped Ether (WETH9) contract
    address public immutable WETH9;

    /// @notice Address that holds and manages tokens - points to CreditVault if isCreditPool is true, otherwise points to market maker's own account
    address public treasury;

    /// @notice Mapping to track used nonces for preventing replay attacks
    mapping(uint256 => bool) public nonces;

    /// @notice Mapping of authorized market makers who can sign RFQ quotes
    mapping(address => bool) public isSigner;

    /*//////////////////////////////////////////////////////////////////////////
                                     RECEIVE FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    receive() external payable {
        require(msg.sender == WETH9, ErrorsLib.OnlyWETH9());
    }

    /*//////////////////////////////////////////////////////////////////////////
                                     CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    constructor(
        bool _isCreditPool,
        address _WETH9,
        address _router,
        address _treasury,
        string memory _name
    ) EIP712("Native RFQ Pool", "1") {
        require(
            _WETH9 != address(0) && _router != address(0) && _treasury != address(0) && bytes(_name).length > 0,
            ErrorsLib.ZeroInput()
        );

        isCreditPool = _isCreditPool;
        name = _name;
        router = _router;
        WETH9 = _WETH9;
        treasury = _treasury;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      RFQ TRADING
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice See NativeRouter.tradeRFQT for detailed documentation
    /// @dev Called by NativeRouter to execute RFQ trades in the pool
    function tradeRFQT(uint256 effectiveSellerTokenAmount, RFQTQuote memory quote) external override onlyRouter {
        // Prevent replay attacks
        require(!nonces[quote.nonce], ErrorsLib.NonceUsed());

        // Mark nonce as used
        nonces[quote.nonce] = true;

        // Store original buyerToken address to handle ETH unwrapping if buyerToken is zero address
        address originalBuyerToken = quote.buyerToken;

        // Handle ETH case: convert zero address to WETH9 for buyer or seller token
        quote.buyerToken = quote.buyerToken == address(0) ? WETH9 : quote.buyerToken;
        quote.sellerToken = quote.sellerToken == address(0) ? WETH9 : quote.sellerToken;

        // Verify market maker signature
        _verifyPMMSignature(quote);

        uint256 buyerTokenAmount = _transferAndCallback(
            quote.signer,
            quote.recipient,
            quote.buyerToken,
            originalBuyerToken,
            quote.sellerToken,
            quote.buyerTokenAmount,
            quote.sellerTokenAmount,
            effectiveSellerTokenAmount
        );

        emit RFQTrade(
            quote.recipient,
            quote.sellerToken,
            quote.buyerToken,
            effectiveSellerTokenAmount,
            buyerTokenAmount,
            quote.quoteId,
            quote.signer
        );
    }

    /// @notice See {NativeRouter-fillOrder} for detailed documentation
    /// @dev Called by NativeRouter to execute fill order trades in the pool
    function fillOrder(uint256 effectiveAmountIn, PermitQuote memory quote) external override onlyRouter {
        // Prevent replay attacks
        require(!nonces[quote.nonce], ErrorsLib.NonceUsed());

        // Store original tokenOut address to handle ETH unwrapping if tokenOut is zero address
        address originalTokenOut = quote.tokenOut;

        // Handle ETH case: convert zero address to WETH9 for buyer or seller token
        quote.tokenOut = quote.tokenOut == address(0) ? WETH9 : quote.tokenOut;
        quote.tokenIn = quote.tokenIn == address(0) ? WETH9 : quote.tokenIn;

        uint256 tokenOutAmount = _transferAndCallback(
            quote.marketMaker,
            quote.recipient,
            quote.tokenOut,
            originalTokenOut,
            quote.tokenIn,
            quote.amountOut,
            quote.amountIn,
            effectiveAmountIn
        );

        // Mark nonce as used
        nonces[quote.nonce] = true;

        emit OrderFilled(
            quote.recipient,
            quote.tokenIn,
            quote.tokenOut,
            effectiveAmountIn,
            tokenOutAmount,
            quote.marketMaker,
            quote.orderBookSig,
            quote.orderBookDigest
        );
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    ADMIN FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Updates the treasury address that receives token
    /// @param newTreasury The new treasury address
    function setTreasury(address newTreasury) public onlyOwner {
        require(newTreasury != address(0), ErrorsLib.ZeroAddress());

        treasury = newTreasury;
        emit TreasurySet(newTreasury);
    }

    /// @notice Adds or removes a market maker's authorization to sign quotes
    /// @param signer The market maker's address
    /// @param _isSigner True to authorize, false to revoke
    function setSigner(address signer, bool _isSigner) external onlyOwner {
        require(signer != address(0), ErrorsLib.ZeroAddress());

        isSigner[signer] = _isSigner;
        emit SignerUpdated(signer, _isSigner);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    function _transferAndCallback(
        address signer,
        address recipient,
        address buyerToken,
        address originalBuyerToken,
        address sellerToken,
        uint256 buyerTokenAmount,
        uint256 sellerTokenAmount,
        uint256 effectiveSellerTokenAmount
    ) internal returns (uint256 _buyerTokenAmount) {
        _buyerTokenAmount = effectiveSellerTokenAmount < sellerTokenAmount
            ? (effectiveSellerTokenAmount * buyerTokenAmount) / sellerTokenAmount
            : buyerTokenAmount;

        if (isCreditPool) {
            require(
                effectiveSellerTokenAmount <= (type(int256).max).toUint256()
                    && _buyerTokenAmount <= (type(int256).max).toUint256(),
                ErrorsLib.Overflow()
            );

            ICreditVault(treasury).swapCallback(
                signer, sellerToken, effectiveSellerTokenAmount.toInt256(), buyerToken, _buyerTokenAmount.toInt256()
            );
        }

        _transferFromTreasury(originalBuyerToken, recipient, _buyerTokenAmount);
    }

    /// @dev Helper function to transfer buyerToken from external account.
    function _transferFromTreasury(address token, address receiver, uint256 value) private {
        if (token == address(0)) {
            // slither-disable-next-line arbitrary-send-erc20
            IERC20(WETH9).safeTransferFrom(treasury, address(this), value);
            IWETH9(WETH9).withdraw(value);

            // Skip ETH initial balance check for saving gas
            payable(receiver).sendValue(value);
        } else {
            // slither-disable-next-line arbitrary-send-erc20
            IERC20(token).safeTransferFrom(treasury, receiver, value);
        }
    }

    function _verifyPMMSignature(RFQTQuote memory quote) internal view {
        require(isSigner[quote.signer], ErrorsLib.InvalidSigner());

        bytes32 digest = _hashTypedDataV4(
            keccak256(
                abi.encode(
                    ORDER_SIGNATURE_HASH,
                    quote.nonce,
                    quote.signer,
                    address(this),
                    quote.recipient,
                    quote.buyerToken,
                    quote.sellerToken,
                    quote.buyerTokenAmount,
                    quote.sellerTokenAmount,
                    quote.deadlineTimestamp,
                    quote.recipient,
                    quote.quoteId
                )
            )
        );

        require(quote.signer == ECDSA.recover(digest, quote.signature), ErrorsLib.InvalidSignature());
    }

    modifier onlyRouter() {
        require(msg.sender == router, ErrorsLib.OnlyNativeRouter());
        _;
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import {ISignatureTransfer} from "@permit2/interfaces/ISignatureTransfer.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {EIP712, ECDSA} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";

import {IWETH9} from "./interfaces/IWETH9.sol";
import {INativeRouter} from "./interfaces/INativeRouter.sol";

import "./libraries/ConstantsLib.sol";
import {Orders} from "./libraries/Order.sol";
import {Multicall} from "./libraries/Multicall.sol";
import {ErrorsLib} from "./libraries/ErrorsLib.sol";
import {TransferHelper} from "./libraries/TransferHelper.sol";
import {ReentrancyGuardTransient} from "./libraries/ReentrancyGuardTransient.sol";

import {CreditVault} from "./CreditVault.sol";
import {NativeRFQPool} from "./NativeRFQPool.sol";
import {ExternalSwap} from "./libraries/ExternalSwap.sol";

contract NativeRouter is INativeRouter, EIP712, Ownable, Pausable, Multicall, ReentrancyGuardTransient {
    using SafeERC20 for IERC20;
    using SafeCast for uint256;

    /// @dev Address of the Wrapped Ether (WETH9) contract
    address public immutable WETH9;

    /// @dev Uniswap Permit2 contract address
    address constant PERMIT2 = 0x000000000022D473030F116dDEE9F6B43aC78BA3;

    /// @dev Address of the CreditVault contract that manages credit and native pools
    address public vault;

    /// @notice Mapping of all trusted Native pools
    mapping(address => bool) public isNativePools;

    /// @dev Address of signer authorized to sign tradeRFQT and fillOrder signatures
    mapping(address => bool) public signers;

    /// @dev Mapping to track which external routers are whitelisted for swaps
    mapping(address => bool) public whitelistRouter;

    /*//////////////////////////////////////////////////////////////////////////
                                     RECEIVE FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    receive() external payable {
        require(msg.sender == WETH9, ErrorsLib.OnlyWETH9());
    }

    /*//////////////////////////////////////////////////////////////////////////
                                     CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    constructor(address _vault, address _WETH9, address _signer) EIP712("Native Router", "1") {
        require(_vault != address(0) && _WETH9 != address(0), ErrorsLib.ZeroAddress());

        vault = _vault;
        WETH9 = _WETH9;

        setSigner(_signer, true);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Execute a Request for Quote (RFQ) trade based on market maker's signed quote
    /// @dev This function facilitates trades between swappers and Native's partnered market makers:
    function tradeRFQT(RFQTQuote memory quote) external payable override nonReentrant whenNotPaused {
        require(quote.widgetFee.feeRate <= MAX_WIDGET_FEE_BIPS, ErrorsLib.InvalidWidgetFeeRate());
        require(block.timestamp <= quote.deadlineTimestamp, ErrorsLib.QuoteExpired());

        _verifyRFQSignature(quote);

        bool isNativePool = isNativePools[quote.pool];
        // address(this) is used for externalSwap
        address payee = isNativePool ? NativeRFQPool(payable(quote.pool)).treasury() : address(this);

        uint256 effectiveSellerTokenAmount =
            _transferSellerToken(quote.multiHop, payee, quote.sellerToken, quote.sellerTokenAmount, quote.widgetFee);

        if (isNativePool) {
            NativeRFQPool(payable(quote.pool)).tradeRFQT(effectiveSellerTokenAmount, quote);
        } else if (whitelistRouter[quote.pool]) {
            Orders.Order memory order = Orders.Order({
                id: 0, // not used
                signer: address(0), // not used
                buyer: quote.pool,
                seller: address(0), // not used
                buyerToken: quote.buyerToken,
                sellerToken: quote.sellerToken,
                buyerTokenAmount: quote.buyerTokenAmount,
                sellerTokenAmount: quote.sellerTokenAmount,
                deadlineTimestamp: quote.deadlineTimestamp,
                caller: msg.sender,
                quoteId: quote.quoteId
            });

            uint256 actualAmountOut = ExternalSwap.externalSwap(
                order, effectiveSellerTokenAmount, quote.recipient, address(this), quote.externalSwapCalldata
            );

            require(
                actualAmountOut >= quote.amountOutMinimum,
                ErrorsLib.NotEnoughAmountOut(actualAmountOut, quote.amountOutMinimum)
            );
        } else {
            revert ErrorsLib.InvalidNativePool();
        }
    }

    /// @notice Executes a trade where the swapper uses Permit2 to authorize token transfer
    /// @param quote The quote details containing trade parameters (amounts, tokens, deadlines)
    /// @param swapperPermit Permit2 transfer authorization details
    /// @param swapperSig Signature from the swapper authorizing the transfer via Permit2
    function fillOrder(
        PermitQuote memory quote,
        ISignatureTransfer.PermitTransferFrom calldata swapperPermit,
        bytes calldata swapperSig
    ) external nonReentrant whenNotPaused {
        // Validate widget fee rate
        require(quote.widgetFee.feeRate <= MAX_WIDGET_FEE_BIPS, ErrorsLib.InvalidWidgetFeeRate());
        require(
            block.timestamp <= quote.deadline && block.timestamp <= swapperPermit.deadline, ErrorsLib.QuoteExpired()
        );

        // Verify permit2 token details match the quote
        require(
            swapperPermit.permitted.token == quote.tokenIn && swapperPermit.permitted.amount == quote.amountIn,
            ErrorsLib.Permit2TokenMismatch()
        );

        // Verify pool is valid
        require(isNativePools[quote.pool], ErrorsLib.InvalidNativePool());

        // Verify order signature
        _verifyOrderSignature(quote);

        // Note: Since router will charges widget fee, can't transfer directly to recipient
        // Execute permit2 transfer: swapper -> router
        ISignatureTransfer(PERMIT2).permitTransferFrom(
            swapperPermit,
            ISignatureTransfer.SignatureTransferDetails({to: address(this), requestedAmount: quote.amountIn}),
            quote.swapper,
            swapperSig
        );

        // Calculate and handle widget fee if applicable
        uint256 widgetFee = quote.widgetFee.feeRate > 0 ? (quote.amountIn * quote.widgetFee.feeRate) / 10_000 : 0;
        uint256 effectiveAmountIn = quote.amountIn;

        if (widgetFee > 0) {
            effectiveAmountIn -= widgetFee;
            // Transfer widget fee to fee recipient
            IERC20(quote.tokenIn).safeTransfer(quote.widgetFee.feeRecipient, widgetFee);
        }

        // Transfer tokens to market maker's treasury
        IERC20(quote.tokenIn).safeTransfer(NativeRFQPool(payable(quote.pool)).treasury(), effectiveAmountIn);

        // Execute the trade on the RFQ pool
        NativeRFQPool(payable(quote.pool)).fillOrder(effectiveAmountIn, quote);
    }

    /// @notice Unwraps WETH9 to ETH by unwrapping all WETH currently in this contract
    /// @dev SECURITY CONSIDERATION: This function is permissionless and will unwrap ALL WETH in the contract
    /// @dev Must be called immediately after receiving WETH in the same multicall transaction
    /// @dev Typical usage flow:
    ///      1. Call tradeRFQ/fillOrder to receive WETH (in multicall)
    ///      2. Call this function immediately in the same multicall to unwrap received WETH
    ///      3. Never leave WETH in this contract between transactions
    /// @param recipient The address that will receive the unwrapped ETH
    function unwrapWETH9(address recipient) public payable nonReentrant {
        require(recipient != address(0), ErrorsLib.ZeroAddress());
        uint256 balanceWETH9 = IWETH9(WETH9).balanceOf(address(this));
        require(balanceWETH9 > 0, ErrorsLib.InsufficientWETH9());

        uint256 beforeBalance = address(this).balance;
        IWETH9(WETH9).withdraw(balanceWETH9);
        balanceWETH9 = address(this).balance - beforeBalance;

        TransferHelper.safeTransferETH(recipient, balanceWETH9);

        emit UnwrapWETH9(recipient, balanceWETH9);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                     ADMIN FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Emergency function to refund stuck ETH from the contract
    /// @dev Can only be called by contract owner in emergency situations
    /// @param recipient The address to receive the refunded ETH
    /// @param amount The amount of ETH to refund
    function refundETH(address recipient, uint256 amount) public payable onlyOwner nonReentrant {
        amount = Math.min(address(this).balance, amount);

        TransferHelper.safeTransferETH(recipient, amount);
        emit RefundETH(recipient, amount);
    }

    /// @notice Emergency function to refund stuck ERC20 tokens from the contract
    /// @dev Can only be called by contract owner in emergency situations
    /// @param token The address of the ERC20 token to refund
    /// @param recipient The address to receive the refunded tokens
    /// @param amount The amount of tokens to refund
    function refundERC20(address token, address recipient, uint256 amount) public payable onlyOwner nonReentrant {
        amount = Math.min(IERC20(token).balanceOf(address(this)), amount);

        TransferHelper.safeTransfer(token, recipient, amount);

        emit RefundERC20(token, recipient, amount);
    }

    /// @notice Set the authorized signer for widget fee and auto-sign messages
    /// @dev Can only be called by contract owner
    /// @param signer The new signer address to be set
    /// @param isSigner Whether the signer is authorized to sign RFQ trade and fillOrder signatures
    function setSigner(address signer, bool isSigner) public onlyOwner {
        require(signer != address(0), ErrorsLib.ZeroAddress());

        signers[signer] = isSigner;
        emit SignerUpdated(signer, isSigner);
    }

    /// @notice Batch set whitelist status for external routers
    /// @dev Can only be called by contract owner
    /// @param routers Array of router addresses to be whitelisted/blacklisted
    /// @param values Array of boolean values corresponding to each router
    function setWhitelistRouter(address[] calldata routers, bool[] calldata values) external onlyOwner {
        require(routers.length == values.length, ErrorsLib.ArraysLengthMismatch());

        for (uint256 i; i < routers.length; ++i) {
            whitelistRouter[routers[i]] = values[i];

            emit WhitelistRouterSet(routers[i], values[i]);
        }
    }

    /// @notice Updates native pool whitelist status
    /// @dev Only callable by owner
    /// @param isActive to whitelist, false to remove from whitelist
    function setNativePool(address pool, bool isActive) external onlyOwner {
        require(pool != address(0), ErrorsLib.ZeroAddress());

        isNativePools[pool] = isActive;

        emit NativePoolUpdated(pool, isActive);
    }

    /// @notice Pauses all RFQ and fillOrder operations
    function pause() external onlyOwner {
        _pause();
    }

    /// @notice Unpauses all RFQ and fillOrder operations
    function unpause() external onlyOwner {
        _unpause();
    }

    /*//////////////////////////////////////////////////////////////////////////
                                     INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    function _transferSellerToken(
        bool multiHop,
        address payee,
        address sellerToken,
        uint256 sellerTokenAmount,
        WidgetFee memory widgetFee
    ) internal returns (uint256 effectiveSellerTokenAmount) {
        if (msg.value > 0 && !multiHop) {
            require(sellerToken == address(0), ErrorsLib.UnexpectedMsgValue());
            require(sellerTokenAmount == msg.value, ErrorsLib.InvalidAmount());

            // slither-disable-next-line arbitrary-send-eth
            IWETH9(WETH9).deposit{value: sellerTokenAmount}();

            effectiveSellerTokenAmount = _chargeWidgetFee(widgetFee, sellerTokenAmount, WETH9, true);

            TransferHelper.safeTransfer(WETH9, payee, effectiveSellerTokenAmount);
        } else {
            effectiveSellerTokenAmount = _chargeWidgetFee(widgetFee, sellerTokenAmount, sellerToken, false);

            if (multiHop) {
                TransferHelper.safeTransfer(sellerToken, payee, effectiveSellerTokenAmount);
            } else {
                TransferHelper.safeTransferFrom(sellerToken, msg.sender, payee, effectiveSellerTokenAmount);
            }
        }
    }

    function _chargeWidgetFee(
        WidgetFee memory widgetFee,
        uint256 amountIn,
        address sellerToken,
        bool hasAlreadyPaid
    ) internal returns (uint256) {
        uint256 fee = widgetFee.feeRate > 0 ? (amountIn * widgetFee.feeRate) / 10_000 : 0;

        if (fee > 0) {
            TransferHelper.safeTransferFrom(
                sellerToken, hasAlreadyPaid ? address(this) : msg.sender, widgetFee.feeRecipient, fee
            );
            emit WidgetFeeTransfer(widgetFee.feeRecipient, widgetFee.feeRate, fee, sellerToken);

            amountIn -= fee;
        }

        return amountIn;
    }

    function _verifyRFQSignature(RFQTQuote memory quote) internal view {
        bytes32 quoteHash = keccak256(
            abi.encode(
                quote.pool,
                quote.signer,
                quote.recipient,
                quote.sellerToken,
                quote.buyerToken,
                quote.sellerTokenAmount,
                quote.buyerTokenAmount,
                quote.deadlineTimestamp,
                quote.nonce,
                quote.multiHop,
                quote.signature,
                quote.externalSwapCalldata,
                msg.sender
            )
        );

        bytes32 digest = _hashTypedDataV4(
            keccak256(
                abi.encode(
                    RFQ_QUOTE_WIDGET_SIGNATURE_HASH, quoteHash, quote.widgetFee.feeRecipient, quote.widgetFee.feeRate
                )
            )
        );

        address recoveredSigner = ECDSA.recover(digest, quote.widgetFeeSignature);

        require(signers[recoveredSigner], ErrorsLib.InvalidSignature());
    }

    function _verifyOrderSignature(PermitQuote memory quote) internal view {
        bytes32 digest = _hashTypedDataV4(
            keccak256(
                abi.encode(
                    FILL_ORDER_SIGNATURE_HASH,
                    quote.nonce,
                    quote.recipient,
                    quote.tokenIn,
                    quote.tokenOut,
                    quote.amountIn,
                    quote.amountOut,
                    quote.deadline,
                    quote.widgetFee.feeRecipient,
                    quote.widgetFee.feeRate
                )
            )
        );

        address recoveredSigner = ECDSA.recover(digest, quote.signature);
        address recoveredMMSigner = ECDSA.recover(quote.orderBookDigest, quote.orderBookSig);

        require(signers[recoveredSigner] && quote.marketMaker == recoveredMMSigner, ErrorsLib.InvalidSignature());
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

interface ICreditVault {
    function swapCallback(
        address signer,
        address sellerToken,
        int256 amount0Delta,
        address buyerToken,
        int256 amount1Delta
    ) external;

    /// @notice Struct for tracking daily rebalance limits per trader/liquidator and token
    /// @param limit Daily rebalance limit
    /// @param used Amount rebalanced today
    /// @param lastDay Last rebalance day timestamp
    struct RebalanceCap {
        uint256 limit;
        uint256 used;
        uint256 lastDay;
    }

    /// @notice Epoch Funding fee updates for a specific trader
    /// @param trader The address of the trader
    /// @param feeUpdates Array of funding fee updates for different tokens
    struct AccruedFundingFee {
        address trader;
        FundingFeeAmount[] feeUpdates;
    }

    /// @notice Details of funding and reserve fees for a specific token
    /// @param token The unerlying token address
    /// @param fundingFee  Amount of fee distributed to LP holders
    /// @param reserveFee Amount of fee reserved for the protocol
    struct FundingFeeAmount {
        address token;
        uint256 fundingFee;
        uint256 reserveFee;
    }

    /// @notice Represents a token amount with unsigned integer value
    /// @param token The address of underlying token
    /// @param amount The unsigned amount of tokens
    struct TokenAmountUint {
        address token;
        uint256 amount;
    }

    /// @notice Represents a token amount with signed integer value (for positions)
    /// @param token The address of underlying token
    /// @param amount The signed amount (positive for long, negative for short)
    struct TokenAmountInt {
        address token;
        int256 amount;
    }

    /// @notice Request parameters for position settlement
    /// @param nonce Unique identifier to prevent replay attacks
    /// @param deadline Timestamp after which the request expires
    /// @param trader Address of the trader whose positions are being settled
    /// @param positionUpdates Array of position changes to be settled
    struct SettlementRequest {
        uint256 nonce;
        uint256 deadline;
        address trader;
        TokenAmountInt[] positionUpdates;
    }

    /// @notice Request parameters for collateral removal
    /// @param nonce Unique identifier to prevent replay attacks
    /// @param deadline Timestamp after which the request expires
    /// @param trader Address of the trader removing collateral
    /// @param tokens Array of collateral tokens to be removed
    struct RemoveCollateralRequest {
        uint256 nonce;
        uint256 deadline;
        address trader;
        TokenAmountUint[] tokens;
    }

    /// @notice Request parameters for position liquidation
    /// @param nonce Unique identifier to prevent replay attacks
    /// @param deadline Timestamp after which the request expires
    /// @param trader Address of the trader being liquidated
    /// @param positionUpdates Array of position changes from liquidation
    /// @param claimCollaterals Array of collateral tokens to be claimed
    struct LiquidationRequest {
        uint256 nonce;
        uint256 deadline;
        address trader;
        TokenAmountInt[] positionUpdates;
        TokenAmountUint[] claimCollaterals;
    }

    /// @notice Emitted when a new market (LP token) is listed
    /// @param lpToken The address of the newly listed LP token
    event MarketListed(address lpToken);

    /// @notice Emitted when epoch funding fees are updated for traders
    /// @param accruedFundingFees Array of funding fee updates for different traders
    event EpochUpdated(AccruedFundingFee[] accruedFundingFees);

    /// @notice Emitted when a trader's positions are repaid
    /// @param trader The address of the trader whose positions are being repaid
    /// @param repayments Array of token amounts being repaid
    event Repaid(address trader, TokenAmountInt[] repayments);

    /// @notice Emitted when a trader's positions are settled
    /// @param trader The address of the trader whose positions are being settled
    /// @param positionUpdates Array of position changes
    event Settled(address trader, TokenAmountInt[] positionUpdates);

    /// @notice Emitted when collateral is added for a trader
    /// @param trader The address of the trader receiving collateral
    /// @param collateralUpdates Array of collateral token amounts added
    event CollateralAdded(address trader, TokenAmountUint[] collateralUpdates);

    /// @notice Emitted when collateral is removed for a trader
    /// @param trader The address of the trader removing collateral
    /// @param collateralUpdates Array of collateral token amounts removed
    event CollateralRemoved(address trader, TokenAmountUint[] collateralUpdates);

    /// @notice Emitted when a trader's positions are liquidated
    /// @param trader The address of the trader being liquidated
    /// @param liquidator The address performing the liquidation
    /// @param positionUpdates Array of position changes from liquidation
    /// @param claimCollaterals Array of collateral tokens claimed by liquidator
    event Liquidated(
        address trader, address liquidator, TokenAmountInt[] positionUpdates, TokenAmountUint[] claimCollaterals
    );

    /// @notice Emitted when a credit pool's status is updated
    /// @param pool The address of the credit pool
    /// @param isActive The new status of the pool
    event CreditPoolUpdated(address indexed pool, bool isActive);

    /// @notice Emitted when a trader or liquidator's rebalance limit is updated for a token
    /// @param operator The trader or liquidator address
    /// @param token The token address
    /// @param limit The new daily limit (0 means unlimited)
    event RebalanceCapUpdated(address indexed operator, address indexed token, uint256 limit);

    /// @notice Emitted when a trader's info is updated
    /// @param trader The address of the trader whose info is being updated
    /// @param isTrader Whether the address is enabled for trading
    /// @param isWhitelistTrader Whether the trader can bypass credit checks
    /// @param settler The address authorized to settle positions for this trader
    /// @param recipient The address authorized to receive tokens from settlements

    event TraderSet(address indexed trader, bool isTrader, bool isWhitelistTrader, address settler, address recipient);

    /// @notice Emitted when liquidator is set
    event LiquidatorSet(address liquidator, bool status);

    /// @notice Emitted when signer is set
    event SignerSet(address signer);

    /// @notice Emitted when epoch updater is set
    event EpochUpdaterSet(address epochUpdater);

    /// @notice Emitted when fee withdrawer is set
    event FeeWithdrawerSet(address feeWithdrawer);

    /// @notice Emitted when reserve fees are withdrawn
    event ReserveWithdrawn(address underlying, address recipient, uint256 amount);
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {IQuote} from "./IQuote.sol";

/// @title Native RFQ Pool Interface
interface INativeRFQPool is IQuote {
    /// @notice Execute an RFQ trade with a signed quote
    /// @notice The amount of sellerToken sold in this trade
    /// @param quote The RFQ quote containing trade details
    function tradeRFQT(uint256 effectiveSellerTokenAmount, RFQTQuote memory quote) external;

    /// @notice Fill an order with permit2 authorization
    /// @notice The amount of tokenIn sold in this trade
    /// @param quote The quote containing trade parameters
    function fillOrder(uint256 effectiveAmountIn, PermitQuote memory quote) external;

    /// @notice Emitted when a signer's status is updated
    event SignerUpdated(address signer, bool isSigner);

    /// @notice Emitted when treasury address is set
    event TreasurySet(address treasury);

    /// @notice Emitted when callback is enabled or disabled
    event EnableCallbackSet(bool value);

    /// @notice Emitted when an RFQ trade is executed
    event RFQTrade(
        address recipient,
        address sellerToken,
        address buyerToken,
        uint256 sellerTokenAmount,
        uint256 buyerTokenAmount,
        bytes16 quoteId,
        address signer
    );

    /// @notice Emitted when an order is filled
    event OrderFilled(
        address recipient,
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOut,
        address marketMaker,
        bytes orderBookSig,
        bytes32 orderBookDigest
    );
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {IQuote} from "./IQuote.sol";
import {ISignatureTransfer} from "@permit2/interfaces/ISignatureTransfer.sol";

/// @title Native Router Interface
interface INativeRouter is IQuote {
    /// @notice Execute an RFQ trade with a signed quote
    /// @param quote The RFQ quote containing trade details
    function tradeRFQT(RFQTQuote memory quote) external payable;

    /// @notice Execute a trade using permit2 signature for token transfer
    /// @param quote The quote containing trade parameters
    /// @param swapperPermit The permit2 transfer authorization
    /// @param swapperSig The signature authorizing the transfer
    function fillOrder(
        PermitQuote memory quote,
        ISignatureTransfer.PermitTransferFrom calldata swapperPermit,
        bytes calldata swapperSig
    ) external;

    /// @notice Emitted when ETH is refunded
    event RefundETH(address recipient, uint256 amount);

    /// @notice Emitted when ERC20 tokens are refunded
    event RefundERC20(address token, address recipient, uint256 amount);

    // @notice Emitted when a signer's status is updated
    event SignerUpdated(address signer, bool isSigner);

    /// @notice Emitted when a native pool's status is updated
    /// @param pool The address of the native pool
    /// @param isActive The new status of the pool
    event NativePoolUpdated(address indexed pool, bool isActive);

    /// @notice Emitted when RFQ trade widget fee is transferred
    event WidgetFeeTransfer(
        address widgetFeeRecipient, uint256 widgetFeeRate, uint256 widgetFeeAmount, address widgetFeeToken
    );

    /// @notice Emitted when permit widget fees are withdrawn
    event WidgetFeesWithdrawn(address indexed recipient, address token, uint256 amount);

    /// @notice Emitted when WETH9 is unwrapped
    event UnwrapWETH9(address indexed recipient, uint256 amount);

    /// @notice Emitted when router is whitelisted or blacklisted
    event WhitelistRouterSet(address indexed router, bool isWhitelisted);
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

interface IQuote {
    struct WidgetFee {
        address feeRecipient;
        uint256 feeRate;
    }

    struct RFQTQuote {
        /*//////////////////////////////////////////////////////////////////////////
                            RFQ QUOTE ONLY FIELDS
        //////////////////////////////////////////////////////////////////////////*/
        /// @notice RFQ pool address or external swap router address
        address pool;
        /// @notice market maker
        address signer;
        /// @notice The recipient of the buyerToken at the end of the trade.
        address recipient;
        /// @notice The token that the trader sells.
        address sellerToken;
        /// @notice The token that the trader buys.
        address buyerToken;
        /// @notice The max amount of sellerToken sold.
        uint256 sellerTokenAmount;
        /// @notice The amount of buyerToken bought when sellerTokenAmount is sold.
        uint256 buyerTokenAmount;
        /// @notice The Unix timestamp (in seconds) when the quote expires.
        /// @dev This gets checked against block.timestamp.
        uint256 deadlineTimestamp;
        /// @notice Nonces are used to protect against replay.
        uint256 nonce;
        /// @notice Unique identifier for the quote.
        /// @dev Generated off-chain via a distributed UUID generator.
        bytes16 quoteId;
        /// @dev  false if this quote is for the 1st hop of a multi-hop or a single-hop, in which case msg.sender is the payer.
        ///       true if this quote is for 2nd or later hop of a multi-hop, in which case router is the payer.
        bool multiHop;
        /// @notice Signature provided by the market maker (EIP-191).
        bytes signature;
        /// @notice Widget fee information
        WidgetFee widgetFee;
        /// @notice Widget fee signature
        bytes widgetFeeSignature;
        /*//////////////////////////////////////////////////////////////////////////
                            EXTERNAL SWAP ONLY FIELDS
        //////////////////////////////////////////////////////////////////////////*/

        /// @notice External swap calldata, different external swap router have different calldata
        bytes externalSwapCalldata;
        /// @notice Minimum amount out for external swap (AMM)
        uint256 amountOutMinimum;
    }

    struct PermitQuote {
        /// @notice The address of the user who want to the swap
        address swapper;
        /// @notice The address of the market maker providing liquidity
        address marketMaker;
        /// @notice The token being sold by the swapper
        address tokenIn;
        /// @notice The token being bought by the swapper
        address tokenOut;
        /// @notice The maximum amount of tokenIn that can be sold
        uint256 amountIn;
        /// @notice The maximum amount of tokenOut that will be received by the swapper
        uint256 amountOut;
        /// @notice The recipient of the tokenOut
        address recipient;
        /// @notice RFQ pool address
        address pool;
        /// @notice Nonces are used to protect against replay.
        uint256 nonce;
        /// @notice market maker's auto-sign orderbook deadline
        uint256 deadline;
        /// @notice Signature signed by off-chain
        bytes signature;
        /// @notice Signature generated by market maker for their pushed auto-sign orderbook
        bytes orderBookSig;
        /// @notice Digest generated by market maker for their pushed auto-sign orderbook
        bytes32 orderBookDigest;
        /// @notice Widget fee info
        WidgetFee widgetFee;
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title Interface for WETH9
interface IWETH9 is IERC20 {
    event Deposit(address indexed dst, uint256 wad);
    event Withdrawal(address indexed src, uint256 wad);

    /// @notice Deposit ether to get wrapped ether
    function deposit() external payable;

    /// @notice Withdraw wrapped ether to get ether
    function withdraw(uint256) external;

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}
// SPDX-License-Identifier: GPL-3.0
/*
 * @title Solidity Bytes Arrays Utils
 * @author Gonçalo Sá <goncalo.sa@consensys.net>
 *
 * @dev Bytes tightly packed arrays utility library for ethereum contracts written in Solidity.
 *      The library lets you concatenate, slice and type cast bytes arrays both in memory and storage.
 */
pragma solidity 0.8.28;

library BytesLib {
    function slice(bytes memory _bytes, uint256 _start, uint256 _length) internal pure returns (bytes memory) {
        require(_length + 31 >= _length, "slice_overflow");
        require(_bytes.length >= _start + _length, "slice_outOfBounds");

        bytes memory tempBytes;

        assembly {
            switch iszero(_length)
            case 0 {
                // Get a location of some free memory and store it in tempBytes as
                // Solidity does for memory variables.
                tempBytes := mload(0x40)

                // The first word of the slice result is potentially a partial
                // word read from the original array. To read it, we calculate
                // the length of that partial word and start copying that many
                // bytes into the array. The first word we copy will start with
                // data we don't care about, but the last `lengthmod` bytes will
                // land at the beginning of the contents of the new array. When
                // we're done copying, we overwrite the full first word with
                // the actual length of the slice.
                let lengthmod := and(_length, 31)

                // The multiplication in the next line is necessary
                // because when slicing multiples of 32 bytes (lengthmod == 0)
                // the following copy loop was copying the origin's length
                // and then ending prematurely not copying everything it should.
                let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                let end := add(mc, _length)

                for {
                    // The multiplication in the next line has the same exact purpose
                    // as the one above.
                    let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } { mstore(mc, mload(cc)) }

                mstore(tempBytes, _length)

                //update free-memory pointer
                //allocating the array padded to 32 bytes like the compiler does now
                mstore(0x40, and(add(mc, 31), not(31)))
            }
            //if we want a zero-length slice let's just return a zero-length array
            default {
                tempBytes := mload(0x40)
                //zero out the 32 bytes slice we are about to return
                //we need to do it because Solidity does not garbage collect
                mstore(tempBytes, 0)

                mstore(0x40, add(tempBytes, 0x20))
            }
        }

        return tempBytes;
    }

    function toAddress(bytes memory _bytes, uint256 _start) internal pure returns (address) {
        require(_bytes.length >= _start + 20, "toAddress_outOfBounds");
        address tempAddress;

        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
        }

        return tempAddress;
    }

    function toUint24(bytes memory _bytes, uint256 _start) internal pure returns (uint24) {
        require(_bytes.length >= _start + 3, "toUint24_outOfBounds");
        uint24 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x3), _start))
        }

        return tempUint;
    }

    function toUint256(bytes memory _bytes, uint256 _start) internal pure returns (uint256) {
        require(_bytes.length >= _start + 32, "toUint256_outOfBounds");
        uint256 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x20), _start))
        }

        return tempUint;
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

/// @dev Every interval, the system performs an epoch update to calculate and settle funding fees between traders
uint256 constant EPOCH_UPDATE_INTERVAL = 8 hours;

/// @dev Maximum early withdrawal fee in basis points (10%)
uint256 constant MAX_EARLY_WITHDRAW_FEE_BIPS = 1000;

/// @dev Maximum widget fee in basis points (20%)
uint256 constant MAX_WIDGET_FEE_BIPS = 2000;

/// @dev The EIP-712 typeHash for Settle Market Maker Position Authorization.
bytes32 constant SETTLEMENT_REQUEST_SIGNATURE_HASH = keccak256(
    "SettlementRequest(uint256 nonce,uint256 deadline,address trader,bytes32 positionUpdates,address recipient)"
);

/// @dev The EIP-712 typeHash for Remove Collateral Authorization.
bytes32 constant REMOVE_COLLATERAL_REQUEST_SIGNATURE_HASH =
    keccak256("RemoveCollateralRequest(uint256 nonce,uint256 deadline,address trader,bytes32 tokens,address recipient)");

/// @dev The EIP-712 typeHash for Liquidation Authorization.
bytes32 constant LIQUIDATION_REQUEST_SIGNATURE_HASH = keccak256(
    "LiquidationRequest(uint256 nonce,uint256 deadline,address trader,bytes32 positionUpdates,bytes32 claimCollaterals,address recipient)"
);

/// @dev The EIP-712 typeHash for Market Maker RFQ Quote Authorization.
bytes32 constant ORDER_SIGNATURE_HASH = keccak256(
    "Order(uint256 id,address signer,address buyer,address seller,address buyerToken,address sellerToken,uint256 buyerTokenAmount,uint256 sellerTokenAmount,uint256 deadlineTimestamp,address caller,bytes16 quoteId)"
);

/// @dev The EIP-712 typeHash for RFQ Quote Widget Authorization.
bytes32 constant RFQ_QUOTE_WIDGET_SIGNATURE_HASH =
    keccak256("RFQTQuote(bytes32 quote,address widgetFeeRecipient,uint256 widgetFeeRate)");

/// @dev The EIP-712 typeHash for Fill Order Authorization.
bytes32 constant FILL_ORDER_SIGNATURE_HASH = keccak256(
    "fillOrder(uint256 nonce,address recipient,address tokenIn,address tokenOut,uint256 amountIn,uint256 amountOut,uint256 deadline,address widgetFeeRecipient,uint256 widgetFeeRate)"
);
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

/// @title Custom error definitions for the protocol
/// @notice This library contains all the error definitions used throughout the contract
/// @dev The errors are arranged in alphabetical order
library ErrorsLib {
    /// @notice Thrown when array lengths don't match in a function requiring equal-length arrays
    error ArraysLengthMismatch();

    /// @notice Thrown when deposit amount is below minimum required
    error BelowMinimumDeposit();

    /// @notice Thrown when caller is not the authorized epoch updater
    error CallerNotEpochUpdater();

    /// @notice Thrown when caller is not an authorized liquidator
    error CallerNotLiquidator();

    /// @notice Thrown when caller is not a trader or authorized settler
    error CallerNotTraderSettler();

    /// @notice Thrown when caller is not the WETH9 contract
    error CallerNotWETH9();

    /// @notice Thrown when epoch update is attempted before minimum interval
    error EpochUpdateInCoolDown();

    /// @notice Thrown when LP token exchange rate increases more than allowed
    error ExchangeRateIncreaseTooMuch();

    /// @notice Thrown when an external contract call fails
    error ExternalCallFailed(address target, bytes4 selector);

    /// @notice Thrown when feature is paused
    error FeaturePaused();

    /// @notice Thrown when there are insufficient funding fees to withdraw
    error InsufficientFundingFees();

    /// @notice Thrown when LP token shares are insufficient
    error InsufficientShares();

    /// @notice Thrown when LP token underlying is insufficient
    error InsufficientUnderlying();

    /// @notice Thrown when there is insufficient WETH9 to unwrap
    error InsufficientWETH9();

    /// @notice Thrown when an amount parameter is invalid
    error InvalidAmount();

    /// @notice Thrown when fee rate in basis points exceeds maximum (10000)
    error InvalidFeeBips();

    /// @notice Thrown when LP token address is invalid
    error InvalidLPToken();

    /// @notice Thrown when underlying are not supported in the credit vault
    error InvalidUnderlying();

    /// @notice Thrown when market (LP token) is invalid
    error InvalidMarket();

    /// @notice Thrown when position update amount is invalid
    error InvalidPositionUpdateAmount();

    /// @notice Thrown when the pool address is invalid Native pool
    error InvalidNativePool();

    /// @notice Thrown when signature verification fails
    error InvalidSignature();

    /// @notice Thrown when signer is not authorized
    error InvalidSigner();

    /// @notice Thrown when WETH9 unwrap amount is zero or exceeds balance
    error InvalidWETH9Amount();

    /// @notice Thrown when widget fee rate is invalid
    error InvalidWidgetFeeRate();

    /// @notice Thrown when liquidator and recipient are the same
    error LiquidatorRecipientConflict();

    /// @notice Thrown when nonce is used
    error NonceUsed();

    /// @notice Thrown when there is no yield to distribute
    error NoYieldToDistribute();

    /// @notice Thrown when output amount is less than minimum required
    error NotEnoughAmountOut(uint256 amountOut, uint256 amountOutMinimum);

    /// @notice Thrown when insufficient token output received
    error NotEnoughTokenReceived();

    /// @notice Thrown the address is not a trader or liquidator
    error NotTraderOrLiquidator();

    /// @notice Thrown when caller is not the credit pool
    error OnlyCreditPool();

    /// @notice Thrown when caller is not the credit vault
    error OnlyCreditVault();

    /// @notice Thrown when caller is not the epoch updater
    error OnlyEpochUpdater();

    /// @notice Thrown when caller is not the fee withdrawer
    error OnlyFeeWithdrawer();

    /// @notice Thrown when caller is not an authorized liquidator
    error OnlyLiquidator();

    /// @notice Thrown when caller is not an LP token
    error OnlyLpToken();

    /// @notice Thrown when caller is not the native router
    error OnlyNativeRouter();

    /// @notice Thrown when caller is not the owner
    error OnlyOwner();

    /// @notice Thrown when caller is not an authorized trader
    error OnlyTrader();

    /// @notice Thrown when caller is not the WETH9 contract
    error OnlyWETH9();

    /// @notice Thrown when order has expired
    error OrderExpired();

    /// @notice Thrown when arithmetic operation would overflow
    error Overflow();

    /// @notice Thrown when permit2 token mismatch quote
    error Permit2TokenMismatch();

    /// @notice Thrown when LP pool has no deposits yet
    error PoolNotInitialized();

    /// @notice Thrown when quote has expired
    error QuoteExpired();

    /// @notice Thrown when rebalance limit is exceeded
    error RebalanceLimitExceeded();

    /// @notice Thrown when request has expired
    error RequestExpired();

    /// @notice Thrown when token is already listed
    error TokenAlreadyListed();

    /// @notice Thrown when trader, settler and recipient are the same
    error TraderRecipientConflict();

    /// @notice Thrown when transfer is in cooldown period
    error TransferInCooldown();

    /// @notice Thrown when transfer to self
    error TransferSelf();

    /// @notice Thrown when transfer to current contract
    error TransferToContract();

    /// @notice Thrown when unexpected msg.value is sent
    error UnexpectedMsgValue();

    /// @notice Thrown when zero address is provided
    error ZeroAddress();

    /// @notice Thrown when amount is zero
    error ZeroAmount();

    /// @notice Thrown when input is zero or empty
    error ZeroInput();
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {ErrorsLib} from "./ErrorsLib.sol";
import {Orders} from "./Order.sol";
import {FullMath} from "./FullMath.sol";

library ExternalSwap {
    using SafeERC20 for IERC20;

    struct SwapState {
        uint256 buyerTokenAmount;
        uint256 sellerTokenAmount;
    }

    event ExternalSwapExecuted(
        address externalRouter,
        address sender,
        address tokenIn,
        address tokenOut,
        int256 amountIn,
        int256 amountOut,
        bytes16 quoteId
    );

    function externalSwap(
        Orders.Order memory order,
        uint256 flexibleAmount,
        address recipient,
        address payer,
        bytes memory fallbackCalldata
    ) internal returns (uint256 amountOut) {
        require(flexibleAmount > 0, ErrorsLib.ZeroAmount());
        require(order.deadlineTimestamp >= block.timestamp, ErrorsLib.OrderExpired());

        SwapState memory state;
        (state.buyerTokenAmount, state.sellerTokenAmount) = _calculateTokenAmount(flexibleAmount, order);

        // prepare token for external call
        if (payer != address(this)) {
            IERC20(order.sellerToken).safeTransferFrom(payer, address(this), state.sellerTokenAmount);
        }
        IERC20(order.sellerToken).safeIncreaseAllowance(order.buyer, state.sellerTokenAmount);

        uint256 routerTokenOutBalanceBefore = IERC20(order.buyerToken).balanceOf(address(this));
        uint256 recipientTokenOutBalanceBefore = IERC20(order.buyerToken).balanceOf(recipient);

        {
            // call to external contract
            (bool success,) = order.buyer.call(fallbackCalldata);

            require(success, ErrorsLib.ExternalCallFailed(order.buyer, bytes4(fallbackCalldata)));
        }

        {
            // assume the tokenOut is sent to "recipient" by external call directly
            uint256 recipientDiff = IERC20(order.buyerToken).balanceOf(recipient) - recipientTokenOutBalanceBefore;
            uint256 routerDiff = IERC20(order.buyerToken).balanceOf(address(this)) - routerTokenOutBalanceBefore;

            // if routerDiff is more, router has the tokens, so router transfers it out to recipient
            if (recipientDiff < routerDiff) {
                IERC20(order.buyerToken).safeTransfer(recipient, routerDiff);
                amountOut = IERC20(order.buyerToken).balanceOf(recipient) - recipientTokenOutBalanceBefore;
            } else {
                // otherwise, recipient has the tokens, so we can use recipientDiff
                amountOut = recipientDiff;
            }

            // amountOut is always the difference in after - before of recipient balance, to account for fee on transfer tokens
            require(amountOut >= state.buyerTokenAmount, ErrorsLib.NotEnoughTokenReceived());
        }

        emit ExternalSwapExecuted(
            order.buyer,
            order.caller,
            order.sellerToken,
            order.buyerToken,
            int256(state.sellerTokenAmount),
            -int256(amountOut),
            order.quoteId
        );
    }

    function _calculateTokenAmount(
        uint256 flexibleAmount,
        Orders.Order memory _order
    ) internal pure returns (uint256, uint256) {
        uint256 buyerTokenAmount = _order.buyerTokenAmount;
        uint256 sellerTokenAmount = _order.sellerTokenAmount;

        require(sellerTokenAmount > 0 && buyerTokenAmount > 0 && flexibleAmount > 0, ErrorsLib.ZeroAmount());

        if (flexibleAmount < sellerTokenAmount) {
            buyerTokenAmount = FullMath.mulDiv(flexibleAmount, buyerTokenAmount, sellerTokenAmount);
            sellerTokenAmount = flexibleAmount;
        }

        require(buyerTokenAmount > 0, ErrorsLib.ZeroAmount());

        return (buyerTokenAmount, sellerTokenAmount);
    }
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.28;

/// @title Contains 512-bit math functions
/// @notice Facilitates multiplication and division that can have overflow of an intermediate value without any loss of precision
/// @dev Handles "phantom overflow" i.e., allows multiplication and division where an intermediate value overflows 256 bits
library FullMath {
    /// @notice Calculates floor(a×b÷denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
    /// @param a The multiplicand
    /// @param b The multiplier
    /// @param denominator The divisor
    /// @return result The 256-bit result
    /// @dev Credit to Remco Bloemen under MIT license https://xn--2-umb.com/21/muldiv
    function mulDiv(uint256 a, uint256 b, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = a * b
            // Compute the product mod 2**256 and mod 2**256 - 1
            // then use the Chinese Remainder Theorem to reconstruct
            // the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2**256 + prod0
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(a, b, not(0))
                prod0 := mul(a, b)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division
            if (prod1 == 0) {
                require(denominator > 0, "FullMath: mulDiv: denominator must be greater then zero");
                assembly {
                    result := div(prod0, denominator)
                }
                return result;
            }

            // Make sure the result is less than 2**256.
            // Also prevents denominator == 0
            require(denominator > prod1, "FullMath: mulDiv: result greater than 2**256");

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0]
            // Compute remainder using mulmod
            uint256 remainder;
            assembly {
                remainder := mulmod(a, b, denominator)
            }
            // Subtract 256 bit number from 512 bit number
            assembly {
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator
            // Compute largest power of two divisor of denominator.
            // Always >= 1.
            // uint256 twos = -denominator & denominator;
            uint256 twos = denominator & (~denominator + 1);
            // Divide denominator by power of two
            assembly {
                denominator := div(denominator, twos)
            }

            // Divide [prod1 prod0] by the factors of two
            assembly {
                prod0 := div(prod0, twos)
            }
            // Shift in bits from prod1 into prod0. For this we need
            // to flip `twos` such that it is 2**256 / twos.
            // If twos is zero, then it becomes one
            assembly {
                twos := add(div(sub(0, twos), twos), 1)
            }
            prod0 |= prod1 * twos;

            // Invert denominator mod 2**256
            // Now that denominator is an odd number, it has an inverse
            // modulo 2**256 such that denominator * inv = 1 mod 2**256.
            // Compute the inverse by starting with a seed that is correct
            // correct for four bits. That is, denominator * inv = 1 mod 2**4
            uint256 inv = (3 * denominator) ^ 2;
            // Now use Newton-Raphson iteration to improve the precision.
            // Thanks to Hensel's lifting lemma, this also works in modular
            // arithmetic, doubling the correct bits in each step.
            inv *= 2 - denominator * inv; // inverse mod 2**8
            inv *= 2 - denominator * inv; // inverse mod 2**16
            inv *= 2 - denominator * inv; // inverse mod 2**32
            inv *= 2 - denominator * inv; // inverse mod 2**64
            inv *= 2 - denominator * inv; // inverse mod 2**128
            inv *= 2 - denominator * inv; // inverse mod 2**256

            // Because the division is now exact we can divide by multiplying
            // with the modular inverse of denominator. This will give us the
            // correct result modulo 2**256. Since the precoditions guarantee
            // that the outcome is less than 2**256, this is the final result.
            // We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inv;
            return result;
        }
    }

    /// @notice Calculates ceil(a×b÷denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
    /// @param a The multiplicand
    /// @param b The multiplier
    /// @param denominator The divisor
    /// @return result The 256-bit result
    function mulDivRoundingUp(uint256 a, uint256 b, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            result = mulDiv(a, b, denominator);
            if (mulmod(a, b, denominator) > 0) {
                require(result < type(uint256).max, "FullMath: mulDivRoundingUp: result greater than 2**256");
                result++;
            }
        }
    }
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.28;

/// @title Multicall
/// @notice Enables calling multiple methods in a single call to the contract
abstract contract Multicall {
    function multicall(bytes[] calldata data) public payable returns (bytes[] memory results) {
        results = new bytes[](data.length);
        for (uint256 i = 0; i < data.length;) {
            (bool success, bytes memory result) = address(this).delegatecall(data[i]);

            if (!success) {
                // Next 5 lines from https://ethereum.stackexchange.com/a/83577
                if (result.length < 68) revert();
                assembly {
                    result := add(result, 0x04)
                }
                revert(abi.decode(result, (string)));
            }

            results[i] = result;
            unchecked {
                i++;
            }
        }
    }

    function multicall(uint256 deadline, bytes[] calldata data) external payable returns (bytes[] memory) {
        require(block.timestamp <= deadline, "Transaction too old");
        return multicall(data);
    }
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.28;

import "./BytesLib.sol";

library Orders {
    using BytesLib for bytes;

    struct Order {
        uint256 id;
        address signer;
        address buyer;
        address seller;
        address buyerToken;
        address sellerToken;
        uint256 buyerTokenAmount;
        uint256 sellerTokenAmount;
        uint256 deadlineTimestamp;
        address caller;
        bytes16 quoteId;
    }

    uint256 private constant ADDR_SIZE = 20;
    uint256 private constant UINT256_SIZE = 32;
    uint256 private constant UUID_SIZE = 16;
    uint256 private constant ORDER_SIZE = ADDR_SIZE * 6 + UINT256_SIZE * 4 + UUID_SIZE;
    uint256 private constant SIG_SIZE = 65;
    uint256 private constant HOP_SIZE = SIG_SIZE + ORDER_SIZE;

    function hasMultiplePools(bytes memory orders) internal pure returns (bool) {
        return orders.length > HOP_SIZE;
    }

    function numPools(bytes memory orders) internal pure returns (uint256) {
        // Ignore the first token address. From then on every fee and token offset indicates a pool.
        return (orders.length / HOP_SIZE);
    }

    function decodeFirstOrder(bytes memory orders) internal pure returns (Order memory order, bytes memory signature) {
        require(orders.length != 0 && orders.length % HOP_SIZE == 0, "Orders: decodeFirstOrder: invalid bytes length");
        order.id = orders.toUint256(0);
        order.signer = orders.toAddress(UINT256_SIZE);
        order.buyer = orders.toAddress(UINT256_SIZE + ADDR_SIZE);
        order.seller = orders.toAddress(UINT256_SIZE + ADDR_SIZE * 2);
        order.buyerToken = orders.toAddress(UINT256_SIZE + ADDR_SIZE * 3);
        order.sellerToken = orders.toAddress(UINT256_SIZE + ADDR_SIZE * 4);
        order.buyerTokenAmount = orders.toUint256(UINT256_SIZE + ADDR_SIZE * 5);
        order.sellerTokenAmount = orders.toUint256(UINT256_SIZE * 2 + ADDR_SIZE * 5);
        order.deadlineTimestamp = orders.toUint256(UINT256_SIZE * 3 + ADDR_SIZE * 5);
        order.caller = orders.toAddress(UINT256_SIZE * 4 + ADDR_SIZE * 5);
        order.quoteId = bytes16(orders.slice(UINT256_SIZE * 4 + ADDR_SIZE * 6, UUID_SIZE));
        signature = orders.slice(ORDER_SIZE, SIG_SIZE);
    }

    function getFirstOrder(bytes memory orders) internal pure returns (bytes memory) {
        return orders.slice(0, HOP_SIZE);
    }

    function skipOrder(bytes memory orders) internal pure returns (bytes memory) {
        require(orders.length != 0 && orders.length % HOP_SIZE == 0, "Orders: decodeFirstOrder: invalid bytes length");
        return orders.slice(HOP_SIZE, orders.length - HOP_SIZE);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {TStorage} from "./TStorage.sol";

// Refer from OpenZeppelin https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v5.1/contracts/utils/ReentrancyGuardTransient.sol

/**
 * @dev Variant of {ReentrancyGuard} that uses transient storage.
 */
abstract contract ReentrancyGuardTransient {
    using TStorage for bytes32;

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.ReentrancyGuard")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant REENTRANCY_GUARD_STORAGE =
        0x9b779b17422d0df92223018b32b4d1fa46e071723d6817e2486d003becc55f00;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

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
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_reentrancyGuardEntered()) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        REENTRANCY_GUARD_STORAGE.tstore(true);
    }

    function _nonReentrantAfter() private {
        REENTRANCY_GUARD_STORAGE.tstore(false);
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return REENTRANCY_GUARD_STORAGE.tload();
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

// Copy from: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.6/contracts/token/ERC20/utils/SafeERC20.sol

// NOTE: We disable 'SafeApprove' function beblow feature
// same with uniswap v3 transferHelper: https://github.com/Uniswap/v3-periphery/blob/main/contracts/libraries/TransferHelper.sol
// require(
//     (value == 0) || (token.allowance(address(this), spender) == 0),
//     "SafeERC20: approve from non-zero to non-zero allowance"
// );

import "openzeppelin/token/ERC20/IERC20.sol";
import "openzeppelin/utils/Address.sol";

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

        // NOTE: we disable this
        // require(
        //     (value == 0) || (token.allowance(address(this), spender) == 0),
        //     "SafeERC20: approve from non-zero to non-zero allowance"
        // );

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
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

/// @title Transient storage utils
library TStorage {
    /// @notice Loads a boolean value from transient storage at a given slot.
    /// @param slot The storage slot to read from.
    /// @return value The boolean value stored at the specified slot.
    function tload(bytes32 slot) internal view returns (bool value) {
        assembly {
            value := tload(slot)
        }
    }

    /// @notice Stores a boolean value in transient storage at a given slot.
    /// @param slot The storage slot to write to.
    /// @param value The boolean value to store at the specified slot.
    function tstore(bytes32 slot, bool value) internal {
        assembly {
            tstore(slot, value)
        }
    }
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

library TransferHelper {
    using SafeERC20 for IERC20;

    /// @notice Transfers tokens from the targeted address to the given destination
    /// @notice Errors with 'STF' if transfer fails
    /// @param token The contract address of the token to be transferred
    /// @param from The originating address from which the tokens will be transferred
    /// @param to The destination address of the transfer
    /// @param value The amount to be transferred
    function safeTransferFrom(address token, address from, address to, uint256 value) internal {
        IERC20(token).safeTransferFrom(from, to, value);
    }

    /// @notice Transfers tokens from msg.sender to a recipient
    /// @dev Errors with ST if transfer fails
    /// @param token The contract address of the token which will be transferred
    /// @param to The recipient of the transfer
    /// @param value The value of the transfer
    function safeTransfer(address token, address to, uint256 value) internal {
        IERC20(token).safeTransfer(to, value);
    }

    function safeIncreaseAllowance(address token, address to, uint256 value) internal {
        IERC20(token).safeIncreaseAllowance(to, value);
    }

    function safeDecreaseAllowance(address token, address to, uint256 value) internal {
        IERC20(token).safeDecreaseAllowance(to, value);
    }

    /// @notice Transfers ETH to the recipient address
    /// @dev Fails with `STE`
    /// @param to The destination of the transfer
    /// @param value The value to be transferred
    function safeTransferETH(address to, uint256 value) internal {
        (bool success,) = to.call{value: value}(new bytes(0));
        require(success, "STE");
    }
}