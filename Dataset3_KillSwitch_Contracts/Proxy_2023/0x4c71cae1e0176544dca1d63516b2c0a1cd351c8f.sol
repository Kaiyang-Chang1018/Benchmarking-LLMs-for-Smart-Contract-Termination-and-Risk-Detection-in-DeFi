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
// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/extensions/IERC20Permit.sol)

pragma solidity ^0.8.0;

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
// OpenZeppelin Contracts (last updated v4.9.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```solidity
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableSet.
 * ====
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {Ticket} from "./Ticket.sol";

/**
 * @title HMStakingNext Contract
 * @dev This contract allows users to stake tokens, earn rewards, and manage staking tiers.
 */
contract HMStakingNext is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.AddressSet;

    // Struct representing a staking tier
    struct Tier {
        uint256 id; // Tier ID
        uint256 duration; // Duration of the staking period in seconds
        uint256 ggBonusRate; // Bonus rate for staked GG tokens
        uint256 rewardMultiplier; // Multiplier for rewards
    }

    // Struct representing user information for staking
    struct UserInfo {
        uint256 amount; // Amount of tokens staked by the user
        uint256 currentRewardMultiplier; // Current reward multiplier for the user
        uint256 availableToClaimRewards; // Rewards available for the user to claim
        uint256 accumulatedBonuses; // Total bonuses accumulated by the user
        uint256 startStakeDate; // Start date of the staking period
        uint256 endStakeDate; // End date of the staking period
        uint256 lastRewardTime; // Last time rewards were calculated for the user
    }

    // Constants for calculations
    uint256 public constant DIVIDER = 1e6; // Divider for bonus calculations
    uint256 public constant PRECISION = 1e18; // Precision factor for calculations
    uint256 public constant maxTiers = 4; // Maximum number of tiers

    // Token addresses
    IERC20 public immutable stakingToken; // Staking token
    Ticket public immutable ticToken; // Ticket token

    // Variables for staking and rewards
    uint256 public rewardsPerSecondPerToken; // Rewards per second per staked token
    uint256 public ticketsPerSecondPerToken; // Tickets earned per second per staked token

    // Total staking
    uint256 public totalStaked; // Total amount of tokens staked
    uint256 public totalAvailableToClaimRewards; // Total rewards available to claim

    Tier[] private _tiers; // Array of staking tiers
    mapping(address => mapping(uint256 => UserInfo)) private _userInfo; // User information mapping
    mapping(address => uint256) public userNumberOfTiers; // Number of tiers a user has staked

    EnumerableSet.AddressSet private _stakers; // Set of stakers

    /**
     * @dev Emitted when the rewards per second per token is set.
     * @param value The new value for rewards per second per token.
     */
    event RewardsPerSecondPerTokenSetted(uint256 value);

    /**
     * @dev Emitted when the tickets per second per token is set.
     * @param value The new value for tickets per second per token.
     */
    event TicketsPerSecondPerTokenSetted(uint256 value);

    event TiersSetted(Tier[] tiers);

    /**
     * @dev Emitted when a user stakes tokens.
     * @param user The address of the user who staked.
     * @param tierId The ID of the staking tier.
     * @param amount The amount of tokens staked.
     */
    event Staked(address indexed user, uint256 indexed tierId, uint256 amount);

    /**
     * @dev Emitted when a user unstakes tokens.
     * @param user The address of the user who unstaked.
     * @param tierId The ID of the staking tier.
     * @param amount The amount of tokens unstaked.
     */
    event Unstaked(
        address indexed user,
        uint256 indexed tierId,
        uint256 amount
    );

    /**
     * @dev Emitted when a user claims rewards and tickets.
     * @param user The address of the user who claimed.
     * @param rewardAmount The amount of rewards claimed.
     * @param ticketAmount The amount of tickets claimed.
     */
    event ClaimedRewardsAndTickets(
        address indexed user,
        uint256 rewardAmount,
        uint256 ticketAmount
    );

    /**
     * @dev Emitted when a user performs an emergency unstake.
     * @param user The address of the user who emergency unstaked.
     * @param tierId The ID of the staking tier.
     * @param amount The amount of tokens emergency unstaked.
     */
    event EmergencyUnstaked(
        address indexed user,
        uint256 indexed tierId,
        uint256 amount
    );

    /**
     * @dev Error indicating an invalid address was provided.
     * @param account The invalid address.
     */
    error InvalidAddress(address account);

    /**
     * @dev Error indicating that the length of tiers exceeds the maximum allowed.
     */
    error TiersLengthGtMaxTiers();

    /**
     * @dev Error indicating that a tier parameter is invalid.
     */
    error TierParameterInvalid();

    /**
     * @dev Error indicating that the staking amount is zero.
     */
    error StakingAmountIsZero();

    /**
     * @dev Error indicating that the staking period has expired.
     */
    error StakingExpired();

    /**
     * @dev Error indicating that there are no rewards and tickets available to claim.
     */
    error NoRewardsAndTickets();

    /**
     * @dev Error indicating that the staking tier does not exist for the given user.
     * @param user The address of the user.
     * @param tierId The ID of the non-existent tier.
     */
    error StakingTierNotExist(address user, uint256 tierId);

    /**
     * @dev Error indicating that the staking period has not expired.
     * @param currentDate The current date.
     * @param endStakeDate The end date of the staking period.
     */
    error StakingPeriodNotExpired(uint256 currentDate, uint256 endStakeDate);

    /**
     * @dev Constructor for initializing the contract with required parameters.
     * @param ggToken_ The address of the GG token contract.
     * @param ticToken_ The address of the Ticket contract.
     * @param rewardsPerSecondPerToken_ The rewards to be distributed per second per token.
     * @param ticketsPerSecondPerToken_ The tickets to be distributed per second per token.
     * @param tiers_ An array of Tier objects defining the staking tiers.
     * @notice The constructor checks for valid token addresses.
     */
    constructor(
        IERC20 ggToken_,
        Ticket ticToken_,
        uint256 rewardsPerSecondPerToken_,
        uint256 ticketsPerSecondPerToken_,
        Tier[] memory tiers_
    ) {
        // Validate that none of the token addresses are zero
        if (
            address(ggToken_) == address(0) ||
            address(ticToken_) == address(0)
        ) revert InvalidAddress(address(0));

        // Assign the provided token to state variables
        ticToken = ticToken_;
        stakingToken = ggToken_; // Initialize stakingToken with ggToken

        // Set rates for rewards
        rewardsPerSecondPerToken = rewardsPerSecondPerToken_;
        ticketsPerSecondPerToken = ticketsPerSecondPerToken_;

        // Call the internal function to set tiers
        _setTiers(tiers_);
    }

    /**
     * @dev Sets the rewards per second per token for the staking mechanism.
     * The function can only be called by the contract owner.
     * Emits a {RewardsPerSecondPerTokenSetted} event upon successful update.
     * @param _rewardsPerSecondPerToken The new value for rewards distributed per second per token.
     * @return bool Returns true if the rewards per second per token were successfully set.
     */
    function setRewardsPerSecondPerToken(
        uint256 _rewardsPerSecondPerToken
    ) external onlyOwner returns (bool) {
        // Update the rewards per second per token
        rewardsPerSecondPerToken = _rewardsPerSecondPerToken;
        // Emit an event indicating the rewards per second per token has been set
        emit RewardsPerSecondPerTokenSetted(_rewardsPerSecondPerToken);
        return true; // Indicate successful execution
    }

    /**
     * @dev Sets the tickets per second per token for the staking mechanism.
     * The function can only be called by the contract owner.
     * Emits a {TicketsPerSecondPerTokenSetted} event upon successful update.
     * @param _ticketsPerSecondPerToken The new value for tickets distributed per second per token.
     * @return bool Returns true if the tickets per second per token were successfully set.
     */
    function setTicketsPerSecondPerToken(
        uint256 _ticketsPerSecondPerToken
    ) external onlyOwner returns (bool) {
        // Update the tickets per second per token
        ticketsPerSecondPerToken = _ticketsPerSecondPerToken;
        // Emit an event indicating the tickets per second per token has been set
        emit TicketsPerSecondPerTokenSetted(_ticketsPerSecondPerToken);
        return true; // Indicate successful execution
    }

    function setTiers(Tier[] memory tiers) external onlyOwner returns (bool) {
        _setTiers(tiers);
        emit TiersSetted(tiers);
        return true;
    }

    /**
     * @dev Allows a user to stake a specified amount of tokens at a given tier.
     * The function is non-reentrant and can only be called by users.
     * Emits a {Staked} event upon successful staking and a {ClaimedRewardsAndTickets} event if the user has previously staked.
     * @param tierId The ID of the staking tier.
     * @param amount The amount of tokens to stake.
     * @return bool Returns true if the staking was successful.
     * @notice This function reverts if the staking amount is zero or if the staking period has expired for existing stakes.
     */
    function stake(
        uint256 tierId,
        uint256 amount
    ) external nonReentrant returns (bool) {
        // Check if the staking amount is zero
        if (amount == 0) revert StakingAmountIsZero();

        Tier memory tier = tierById(tierId); // Retrieve the staking tier details
        UserInfo storage user = _userInfo[msg.sender][tierId]; // Get user info for the specified tier

        // uint256 bonus;
        uint256 ticketAmountToMint;

        // If the user is staking for the first time
        if (user.amount == 0) {
            _stakers.add(msg.sender); // Add user to the stakers list
            ++userNumberOfTiers[msg.sender]; // Increment the number of tiers for the user

            // Update user info
            user.amount += amount;
            user.currentRewardMultiplier = tier.rewardMultiplier;
            user.startStakeDate = block.timestamp;
            user.endStakeDate = block.timestamp + tier.duration;
        } else {
            // Check if the staking period has expired for the existing stake
            if (block.timestamp >= user.endStakeDate) revert StakingExpired();

            // Calculate the ticket amount to mint and available rewards
            ticketAmountToMint = getGeneratedTicket(msg.sender, tierId);
            uint256 availableToClaimRewardsAdd = getGeneratedReward(
                msg.sender,
                tierId
            );

            // Update user info with available rewards and new stake amount
            user.availableToClaimRewards += availableToClaimRewardsAdd;
            user.currentRewardMultiplier = _calculateRewardMultiplier(
                msg.sender,
                tierId,
                amount
            );
            user.amount += amount;

            // Update total available rewards
            totalAvailableToClaimRewards += availableToClaimRewardsAdd;

            // Emit an event for claimed rewards and tickets
            emit ClaimedRewardsAndTickets(msg.sender, 0, ticketAmountToMint);
        }

        // Update user last reward time
        user.lastRewardTime = block.timestamp;

        // Update total staked and bonuses
        totalStaked += amount;
        // totalBonuses += bonus;

        // Emit a staking event
        emit Staked(msg.sender, tierId, amount);

        // Transfer the staking tokens from the user to the contract
        stakingToken.safeTransferFrom(msg.sender, address(this), amount);

        // Mint tickets if applicable
        if (ticketAmountToMint > 0)
            ticToken.mint(msg.sender, ticketAmountToMint);

        return true; // Indicate successful execution
    }

    /**
     * @dev Allows a user to unstake their tokens from a specified tier.
     * The function is non-reentrant and can only be called by users.
     * Emits a {Unstaked} event upon successful unstaking and a {ClaimedRewardsAndTickets} event for any claimed rewards.
     * @param tierId The ID of the staking tier from which to unstake.
     * @return bool Returns true if the unstaking was successful.
     * @notice This function reverts if the user has no amount staked in the specified tier,
     *         or if the staking period has not expired.
     */
    function unstake(uint256 tierId) external nonReentrant returns (bool) {

        UserInfo memory user = _userInfo[msg.sender][tierId]; // Retrieve user info for the specified tier

        // Check if the user has staked tokens in the specified tier
        if (user.amount == 0) revert StakingTierNotExist(msg.sender, tierId);

        // Check if the staking period has expired
        if (block.timestamp < user.endStakeDate)
            revert StakingPeriodNotExpired(block.timestamp, user.endStakeDate);

        // Calculate the ticket amount to mint and total reward amount
        uint256 ticketAmountToMint = getGeneratedTicket(msg.sender, tierId);
        uint256 rewardAmount = getGeneratedReward(msg.sender, tierId) +
            user.availableToClaimRewards;

        // Update total available rewards if any
        if (rewardAmount > 0) {
            totalAvailableToClaimRewards -= user.availableToClaimRewards;
        }

        emit ClaimedRewardsAndTickets(
            msg.sender,
            rewardAmount,
            ticketAmountToMint
        ); // Emit claimed rewards event

        // Update total staked and emit unstaked event
        totalStaked -= user.amount;
        emit Unstaked(msg.sender, tierId, user.amount);

        // Calculate total amount to pay out
        uint256 amountToPay = rewardAmount + user.amount;
        delete _userInfo[msg.sender][tierId]; // Remove user info for the tier

        --userNumberOfTiers[msg.sender]; // Decrement the number of tiers for the user
        if (userNumberOfTiers[msg.sender] == 0) _stakers.remove(msg.sender); // Remove user from stakers if no tiers left

        _safeTokenTransfer(msg.sender, amountToPay); // Transfer tokens to the user
        if (ticketAmountToMint > 0)
            ticToken.mint(msg.sender, ticketAmountToMint); // Mint tickets if applicable

        return true; // Indicate successful execution
    }

    /**
     * @dev Allows a user to emergency unstake their tokens from a specified tier.
     * The function is non-reentrant and can only be called by users.
     * Emits an {EmergencyUnstaked} event upon successful emergency unstaking.
     * @param tierId The ID of the staking tier from which to emergency unstake.
     * @return bool Returns true if the emergency unstaking was successful.
     * @notice This function reverts if the user has no amount staked in the specified tier,
     *         or if the staking period has not expired.
     */
    function emergencyUnstake(
        uint256 tierId
    ) external nonReentrant returns (bool) {

        UserInfo memory user = _userInfo[msg.sender][tierId]; // Retrieve user info for the specified tier

        // Check if the user has staked tokens in the specified tier
        if (user.amount == 0) revert StakingTierNotExist(msg.sender, tierId);

        // Check if the staking period has expired
        if (block.timestamp < user.endStakeDate)
            revert StakingPeriodNotExpired(block.timestamp, user.endStakeDate);

        // Update total available rewards if any
        if (user.availableToClaimRewards > 0)
            totalAvailableToClaimRewards -= user.availableToClaimRewards;

        // Update total staked and emit emergency unstaked event
        totalStaked -= user.amount;
        emit EmergencyUnstaked(msg.sender, tierId, user.amount);

        // Calculate total amount to pay out
        uint256 amountToPay = user.amount;
        delete _userInfo[msg.sender][tierId]; // Remove user info for the tier

        --userNumberOfTiers[msg.sender]; // Decrement the number of tiers for the user
        if (userNumberOfTiers[msg.sender] == 0) _stakers.remove(msg.sender); // Remove user from stakers if no tiers left

        _safeTokenTransfer(msg.sender, amountToPay); // Transfer tokens to the user

        return true; // Indicate successful execution
    }

    /**
     * @dev Allows a user to claim their rewards and tickets from all tiers.
     * The function is non-reentrant and can only be called by users.
     * Emits a {ClaimedRewardsAndTickets} event upon successful claiming.
     * @return rewardAmount The total amount of rewards claimed.
     * @return ticketAmount The total number of tickets claimed.
     * @notice This function reverts if there are no rewards or tickets to claim.
     */
    function claimRewards() external nonReentrant returns (uint256, uint256) {

        uint256 rewardAmount; // Initialize total reward amount
        uint256 ticketAmount; // Initialize total ticket amount
        uint256 length = _tiers.length; // Get the number of tiers

        // Loop through all tiers and claim rewards
        for (uint256 i = 1; i <= length; ) {
            (uint256 rewardAmountAdd, uint256 ticketAmountAdd) = _claimRewards(
                msg.sender,
                i
            );
            rewardAmount += rewardAmountAdd; // Accumulate rewards
            ticketAmount += ticketAmountAdd; // Accumulate tickets

            unchecked {
                ++i; // Increment the tier index
            }
        }

        // Check if there are rewards or tickets to claim
        if (rewardAmount == 0 && ticketAmount == 0)
            revert NoRewardsAndTickets();

        emit ClaimedRewardsAndTickets(msg.sender, rewardAmount, ticketAmount); // Emit claimed rewards event
        _safeTokenTransfer(msg.sender, rewardAmount); // Transfer rewards to the user
        if (ticketAmount > 0) ticToken.mint(msg.sender, ticketAmount); // Mint tickets if applicable

        return (rewardAmount, ticketAmount); // Return the amounts claimed
    }

    /**
     * @dev Retrieves the user information for a specified tier.
     * @param user The address of the user.
     * @param tier The ID of the staking tier.
     * @return UserInfo Returns the user information for the specified tier.
     */
    function userInfo(
        address user,
        uint256 tier
    ) external view returns (UserInfo memory) {
        return _userInfo[user][tier]; // Return user info for the specified tier
    }

    /**
     * @dev Retrieves the staker's address at a specified index.
     * @param index The index of the staker.
     * @return address Returns the address of the staker at the specified index.
     */
    function stakers(uint256 index) external view returns (address) {
        return _stakers.at(index); // Return the staker's address at the specified index
    }

    /**
     * @dev Checks if a user is a staker.
     * @param user The address of the user to check.
     * @return bool Returns true if the user is a staker, false otherwise.
     */
    function stakersContains(address user) external view returns (bool) {
        return _stakers.contains(user); // Return whether the user is a staker
    }

    /**
     * @dev Retrieves the total number of stakers.
     * @return uint256 Returns the number of stakers.
     */
    function stakersLength() external view returns (uint256) {
        return _stakers.length(); // Return the total number of stakers
    }

    /**
     * @dev Retrieves the total number of tiers available.
     * @return uint256 Returns the number of tiers.
     */
    function tiersLength() external view returns (uint256) {
        return _tiers.length; // Return the total number of tiers
    }

    /**
     * @dev Retrieves the tier information by its ID.
     * @param id The ID of the tier.
     * @return Tier Returns the tier information.
     */
    function tierById(uint256 id) public view returns (Tier memory) {
        return _tiers[id - 1]; // Return the tier information for the specified ID
    }

    /**
     * @dev Calculates the pending rewards for a user in a specified tier.
     * @param account The address of the user.
     * @param tierId The ID of the staking tier.
     * @return uint256 Returns the total pending rewards for the user in the specified tier.
     */
    function pendingRewards(
        address account,
        uint256 tierId
    ) public view returns (uint256) {
        // Calculate total pending rewards by summing generated rewards and available rewards
        return
            getGeneratedReward(account, tierId) +
            _userInfo[account][tierId].availableToClaimRewards;
    }

    /**
     * @dev Calculates the generated reward for a user in a specified tier.
     * @param account The address of the user.
     * @param tierId The ID of the staking tier.
     * @return uint256 Returns the generated reward for the user in the specified tier.
     */
    function getGeneratedReward(
        address account,
        uint256 tierId
    ) public view returns (uint256) {
        UserInfo memory user = _userInfo[account][tierId]; // Retrieve user info for the specified tier
        uint256 toTime = block.timestamp; // Set the current time
        if (toTime > user.endStakeDate) toTime = user.endStakeDate; // Limit to the end stake date

        // Check if rewards can be generated
        if (toTime > user.lastRewardTime && totalStaked > 0) {
            uint256 _currentRewardsPerSecondPerToken = (rewardsPerSecondPerToken *
                    user.currentRewardMultiplier) / DIVIDER;
            // Calculate the generated reward based on the user's amount and time
            return
                (user.amount *
                    (toTime - user.lastRewardTime) *
                    _currentRewardsPerSecondPerToken) / PRECISION;
        }
        return 0; // Return 0 if no reward generated
    }

    /**
     * @dev Calculates the generated ticket for a user in a specified tier.
     * @param account The address of the user.
     * @param tierId The ID of the staking tier.
     * @return uint256 Returns the generated ticket for the user in the specified tier.
     */
    function getGeneratedTicket(
        address account,
        uint256 tierId
    ) public view returns (uint256) {
        UserInfo memory user = _userInfo[account][tierId]; // Retrieve user info for the specified tier
        uint256 toTime = block.timestamp; // Set the current time
        if (toTime > user.endStakeDate) toTime = user.endStakeDate; // Limit to the end stake date

        // Check if tickets can be generated
        if (toTime > user.lastRewardTime && totalStaked > 0) {
            // Calculate the generated ticket based on the user's amount and time
            return
                (user.amount *
                    (toTime - user.lastRewardTime) *
                    ticketsPerSecondPerToken) / PRECISION;
        }
        return 0; // Return 0 if no ticket generated
    }

    /**
     * @dev Sets the tiers for the staking system.
     * @param tiers An array of Tier structs to set.
     * @notice This function is private and can only be called internally.
     * @dev Reverts if the number of tiers exceeds the maximum allowed or if any tier parameters are invalid.
     */
    function _setTiers(Tier[] memory tiers) private {
        uint256 length = tiers.length; // Get the number of tiers
        if (length > maxTiers) revert TiersLengthGtMaxTiers(); // Check if the number of tiers exceeds the maximum

        // Loop through the provided tiers to validate and set them
        for (uint256 i; i < length; ) {
            Tier memory tier = tiers[i]; // Get the current tier
            // Validate tier parameters
            if (
                tier.id != i + 1 ||
                tier.duration == 0 ||
                (i > 0 &&
                    (tier.duration < tiers[i - 1].duration ||
                        tier.rewardMultiplier < tiers[i - 1].rewardMultiplier))
            ) revert TierParameterInvalid();

            _tiers.push(tier); // Add the valid tier to the list

            unchecked {
                ++i; // Increment the index
            }
        }
    }

    /**
     * @dev Calculates the reward multiplier for a user based on their stake and changes in amount.
     * @param account The address of the user.
     * @param tierId The ID of the staking tier.
     * @param amountDelta The change in the amount staked.
     * @return uint256 Returns the calculated reward multiplier.
     * @notice This function reverts if the staking period has expired.
     */
    function _calculateRewardMultiplier(
        address account,
        uint256 tierId,
        uint256 amountDelta
    ) private view returns (uint256) {
        Tier memory tier = tierById(tierId); // Get the tier information
        UserInfo memory user = _userInfo[account][tierId]; // Retrieve user information

        uint256 amountOld = user.amount; // The user's previous stake amount
        uint256 rewardMultiplierOld = user.currentRewardMultiplier; // The user's current reward multiplier
        uint256 timeFromStart = block.timestamp - user.startStakeDate; // Calculate time since the user started staking

        uint256 rangeId; // To determine which range the current time falls into
        // Determine the range ID based on the time elapsed
        for (uint256 i = 1; i <= tierId; ) {
            if (timeFromStart <= tierById(i).duration) {
                rangeId = i;
                break;
            }
            unchecked {
                ++i; // Increment the index
            }
        }
        if (rangeId == 0) revert StakingExpired(); // Revert if the staking period has expired

        uint256 timeFromStartRangeId = timeFromStart; // Time within the current range
        if (rangeId > 1) timeFromStartRangeId -= tierById(rangeId - 1).duration; // Adjust time for previous ranges

        uint256 multiplierAtMoment; // To calculate the multiplier at the current moment
        // Calculate the multiplier at the current moment
        for (uint256 i = 1; i <= tierId; ) {
            if (i == rangeId) {
                Tier memory info = tierById(i); // Get current tier info
                uint256 rangeMultiplierDelta = i == 1
                    ? info.rewardMultiplier
                    : info.rewardMultiplier - tierById(i - 1).rewardMultiplier; // Calculate the difference in multipliers
                uint256 rangeDurationDelta = i == 1
                    ? info.duration
                    : info.duration - tierById(i - 1).duration; // Calculate the difference in durations

                uint256 multiplierDelta = (rangeMultiplierDelta *
                    timeFromStartRangeId) / rangeDurationDelta; // Calculate the delta

                multiplierAtMoment = i == 1
                    ? tier.rewardMultiplier - multiplierDelta // Calculate the multiplier for the first tier
                    : tier.rewardMultiplier -
                        tierById(i - 1).rewardMultiplier -
                        multiplierDelta; // Calculate for subsequent tiers
                break; // Exit the loop after calculation
            }
            unchecked {
                ++i; // Increment the index
            }
        }
        // Return the adjusted reward multiplier based on the old amount and the new amount
        return
            (amountOld *
                rewardMultiplierOld +
                amountDelta *
                multiplierAtMoment) / (amountOld + amountDelta);
    }

    /**
     * @dev Claims rewards and tickets for a user in a specified tier.
     * @param _user The address of the user claiming rewards.
     * @param _tierId The ID of the staking tier.
     * @return (uint256, uint256) Returns the amount of rewards and tickets claimed.
     * @notice This function returns (0, 0) if the user has no staked amount.
     */
    function _claimRewards(
        address _user,
        uint256 _tierId
    ) private returns (uint256, uint256) {
        UserInfo storage user = _userInfo[_user][_tierId]; // Retrieve user information
        if (user.amount == 0) return (0, 0); // Return zero if no amount is staked

        uint256 ticketAmountToMint = getGeneratedTicket(msg.sender, _tierId); // Calculate tickets to mint
        uint256 rewardAmount = pendingRewards(_user, _tierId); // Calculate pending rewards
        totalAvailableToClaimRewards -= user.availableToClaimRewards; // Update total available rewards
        user.availableToClaimRewards = 0; // Reset available rewards for the user
        user.lastRewardTime = block.timestamp; // Update the last reward time
        return (rewardAmount, ticketAmountToMint); // Return the claimed amounts
    }

    /**
     * @dev Safely transfers tokens to a specified address.
     * @param to The address to which tokens will be transferred.
     * @param amount The amount of tokens to transfer.
     * @notice This function ensures that the transfer does not exceed the contract's balance.
     */
    function _safeTokenTransfer(address to, uint256 amount) private {
        IERC20 token = stakingToken;
        uint256 rewardBal = token.balanceOf(address(this)); // Get the contract's token balance
        if (rewardBal > 0) {
            // Transfer the amount or the available balance, whichever is smaller
            if (amount > rewardBal) token.safeTransfer(to, rewardBal);
            else token.safeTransfer(to, amount);
        }
    }

    /**
     * @dev Allows the owner to recover tokens that are mistakenly sent to the contract.
     * @param token The token contract to recover.
     * @param amount The amount of tokens to recover.
     * @param to The address to which the tokens will be sent.
     * @return bool Returns true if the recovery was successful.
     * @notice This function reverts if the address to send tokens to is invalid (zero address).
     */
    function foreignTokensRecover(
        IERC20 token,
        uint256 amount,
        address to
    ) external onlyOwner returns (bool) {
        if (to == address(0)) revert InvalidAddress(address(0)); // Revert if the address is invalid
        token.safeTransfer(to, amount); // Transfer the specified amount of tokens
        return true; // Indicate success
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {ERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title Ticket Token Contract
 * @dev This contract implements an ERC20 token named Ticket (TIC) with functionality
 * for managing minters who can create new tokens.
 */
contract Ticket is ERC20, Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;

    // Set to hold addresses authorized to mint tokens
    EnumerableSet.AddressSet private _minters;

    // Event emitted when new tokens are minted
    event Minted(address indexed to, uint256 value);

    // Event emitted when a new minter is added
    event MinterAdded(address indexed addedMinters);

    // Event emitted when a minter is removed
    event MinterRemoved(address indexed removedMinters);

    // Error thrown when a mint operation is called by an unauthorized address
    error MintCallerNotMinter(address caller);

    // Error thrown when the mint amount is zero
    error MintAmountZero();

    /**
     * @dev Constructor to initialize the Ticket contract and set authorized minters.
     * @param minters_ An array of addresses to be authorized as minters.
     */
    constructor(
        address[] memory minters_
    ) ERC20("Ticket", "TIC") {
        for (uint256 i = 0; i < minters_.length; i++) {
            _minters.add(minters_[i]); // Add each minter to the set
        }
    }

    /**
     * @dev Allows authorized minters to create new tokens.
     * @param to The address to which the newly minted tokens will be sent.
     * @param amount The amount of tokens to mint.
     * @return bool Returns true if the minting was successful.
     * @notice The caller must be an authorized minter and the amount must be greater than zero.
     */
    function mint(address to, uint256 amount) external returns (bool) {
        if (!_minters.contains(msg.sender))
            revert MintCallerNotMinter(msg.sender); // Check for valid caller
        if (amount == 0) revert MintAmountZero(); // Check for zero mint amount
        _mint(to, amount); // Mint the specified amount to the `to` address
        emit Minted(to, amount); // Emit minting event
        return true; // Indicate successful minting
    }

    /**
     * @dev Adds a list of addresses as authorized minters.
     * @param minters_ An array of addresses to be added as minters.
     * @return bool Returns true if the operation was successful.
     * @notice Only the contract owner can call this function.
     * Emits a {MinterAdded} event for each address successfully added.
     */
    function addMinters(
        address[] memory minters_
    ) external onlyOwner returns (bool) {
        for (uint256 i = 0; i < minters_.length; i++) {
            address minter_ = minters_[i];
            if (_minters.add(minter_)) emit MinterAdded(minter_); // Emit event if minter is added
        }
        return true; // Indicate successful addition of minters
    }

    /**
     * @dev Removes a list of addresses from the authorized minters.
     * @param minters_ An array of addresses to be removed as minters.
     * @return bool Returns true if the operation was successful.
     * @notice Only the contract owner can call this function.
     * Emits a {MinterRemoved} event for each address successfully removed.
     */
    function removeMinters(
        address[] memory minters_
    ) external onlyOwner returns (bool) {
        for (uint256 i = 0; i < minters_.length; i++) {
            address minter_ = minters_[i];
            if (_minters.remove(minter_)) emit MinterRemoved(minter_); // Emit event if minter is removed
        }
        return true; // Indicate successful removal of minters
    }

    /**
     * @dev Allows the owner to recover foreign ERC20 tokens sent to this contract.
     * @param token_ The address of the ERC20 token contract to recover.
     * @param amount_ The amount of tokens to recover.
     * @param to_ The address to which the recovered tokens will be sent.
     * @return bool Returns true if the operation was successful.
     * @notice Only the contract owner can call this function.
     */
    function foreignTokensRecover(
        IERC20 token_,
        uint256 amount_,
        address to_
    ) external onlyOwner returns (bool) {
        token_.transfer(to_, amount_); // Transfer the specified amount of tokens to the given address
        return true; // Indicate successful recovery of tokens
    }

    /**
     * @dev Returns the count of authorized minters.
     * @return uint256 The number of minters.
     */
    function mintersCount() external view returns (uint256) {
        return _minters.length();
    }

    /**
     * @dev Returns the address of a minter at a specific index.
     * @param index The index of the minter to retrieve.
     * @return address The address of the minter.
     * @notice Will revert if the index is out of bounds.
     */
    function minters(uint256 index) external view returns (address) {
        return _minters.at(index);
    }

    /**
     * @dev Checks if a specific address is an authorized minter.
     * @param minter The address to check.
     * @return bool Returns true if the address is a minter, false otherwise.
     */
    function mintersContains(address minter) external view returns (bool) {
        return _minters.contains(minter);
    }
}