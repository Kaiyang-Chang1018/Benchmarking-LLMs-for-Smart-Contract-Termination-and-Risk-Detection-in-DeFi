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
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./IERC246.sol";

/**
 * @title ERC246
 * @dev ERC20 token with governance capabilities. Token holders can create and vote on proposals.
 * Proposals can execute multiple functions via encoded function calls, such as minting tokens, changing the name, airdrops, etc.
 */
abstract contract ERC246 is ERC20, IERC246, ReentrancyGuard {
    using Address for address;
    using Counters for Counters.Counter;

    /// @notice A struct representing a proposal.
    struct Proposal {
        address proposer;
        string title;
        address[] targets; // Target contract addresses to call
        bytes[] data; // Encoded function call data for each target
        uint256[] values;    // ETH values to send with each call
        uint256 deadlineBlock; // Proposal voting deadline in block numbers
        uint256 enqueueBlock; // Proposal voting deadline in block numbers
        bool executed; // Whether the proposal has been executed
        bool accepted; // Whether the proposal has been accepted
        bool enqueued; // Whether the proposal has been enqueued for execution
        bool terminatedWithRejection; // Whether the proposal has been definitively rejected
        address[] voters; // List of voters
        mapping(address => bool) hasVoted; // Track voters to prevent double voting
        mapping(address => bool) voteSupport; // Track whether voter voted for (true) or against (false)
    }

    /// @notice Mapping from proposal ID to Proposal struct.
    mapping(uint256 => Proposal) public proposals;

    /// @notice Counter to keep track of proposal IDs.
    Counters.Counter public proposalIdCounter;

    /// @notice Minimum voting duration in blocks (initially set to 1 day, e.g., 5760 blocks)
    uint256 public minimumVotingDurationBlocks = 5760;

    /// @notice Minimum allowed voting duration in blocks.
    uint256 public constant MINIMUM_ALLOWED_PROPOSAL_DURATION_BLOCKS = 750; // Approximately 2.5 hours on Ethereum

    /// @notice Delay between proposal enqueueing and execution in blocks.
    uint256 public executionDelayInBlocks = 1200; //(~4 hours at 12s per block)

    /// @notice Minimum allowed proposal execution delay in blocks.
    uint256 public constant MINIMUM_ALLOWED_EXECUTION_DELAY_BLOCKS = 750; // Approximately 2.5 hours on Ethereum

    /// @notice The quorum needed for a proposal to be accepted expressed as a percentage of the supply in basis points
    uint256 public quorumSupplyPercentageBps = 400;

    /// @notice Minimum allowed quorum supply percentage basis points
    uint256 public constant MINIMUM_ALLOWED_QUORUM_SUPPLY_PERCENTAGE_BPS = 100;

    /// @notice Transfer fee in basis points (100 bps = 1%)
    uint256 public transferFeeBps = 0;
    
    /// @notice Max cap of 5% transfer fee
    uint256 public constant MAX_TRANSFER_FEE_BPS = 500; // Max 5% fee

    /// @notice Maximum percentage of the supply that can be minted via proposal expressed in basis points.
    uint256 public constant MAXIMUM_MINT_SUPPLY_PERCENTAGE_BPS = 500;

    /// @notice Mapping to track the block in which each user last received tokens.
    mapping(address => uint256) public lastTokenAcquisitionBlock;

    // Mapping to track the last block in which a function was executed
    mapping(bytes4 => uint256) public lastExecutionBlock;

    /// @notice Mapping to store minting airdrop allocations for each recipient.
    mapping(address => uint256) public mintAirdropAllocations;

    /// @notice Mapping to store treasury airdrop allocations for each recipient.
    mapping(address => uint256) public airdropAllocationsFromTreasury;

    /// @notice Total amount of tokens locked in the treasury for airdrop claims.
    uint256 public lockedTreasuryTokens;

    /// @notice The name of the token
    string private _name;

    /// @notice The symbol of the token
    string private _symbol;

    /**
     * @notice Modifier to restrict function access to only the governance contract (i.e., only callable via a proposal).
     */
    modifier onlyGovernanceProposal() {
        require(msg.sender == address(this), "ERC246: Only callable via governance proposal");
        _;
    }

    /**
     * @notice Modifier to ensure the function is only executed once per block (so, also once per proposal).
     * @dev Uses `msg.sig` to identify the function by its signature, regardless of parameters.
     */
    modifier onlyOncePerBlock() {
        require(lastExecutionBlock[msg.sig] != block.number, "ERC246: Function already executed in this block");
        lastExecutionBlock[msg.sig] = block.number;
        _;
    }

    /**
     * @notice Constructor to initialize the governance token.
     * @param name_ The name of the ERC20 token.
     * @param symbol_ The symbol of the ERC20 token.
     */
    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {
        _name = name_;
        _symbol = symbol_;
    }


    // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ Core governance functions ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    

    /**
     * @notice Create a new proposal with multiple function calls.
     * @param _targets The target contract addresses for the proposal.
     * @param _data The encoded function calls (signature + parameters) to be executed if the proposal passes.
     * @param _votingDurationInBlocks The duration (in blocks) for which the proposal will be open for voting.
     */
    function createProposal(
        string calldata _title,
        address[] memory _targets,
        bytes[] memory _data,
        uint256[] memory _values,
        uint256 _votingDurationInBlocks
    ) external override {
        require(balanceOf(msg.sender) > 0, "ERC246: Only token holders can create proposals");
        require(_targets.length == _data.length && _data.length == _values.length, "ERC246: Targets, data and values length mismatch");
        require(_votingDurationInBlocks >= minimumVotingDurationBlocks, "ERC246: Voting duration too short");
        require(bytes(_title).length <= 50, "ERC246: Title cannot be longer than 50 characters");

        uint256 proposalId = proposalIdCounter.current();

        Proposal storage newProposal = proposals[proposalId];
        newProposal.proposer = msg.sender;
        newProposal.title = _title;
        newProposal.deadlineBlock = block.number + _votingDurationInBlocks;
        newProposal.targets = _targets;
        newProposal.data = _data;
        newProposal.values = _values;

        proposalIdCounter.increment();

        emit ProposalCreated(proposalId, _targets, _data, _values, newProposal.deadlineBlock);
    }

    /**
     * @notice Vote on an active proposal.
     * @param _proposalId The ID of the proposal to vote on.
     * @param _support A boolean indicating whether the vote is in favor (true) or against (false).
     */
    function vote(uint256 _proposalId, bool _support) override external nonReentrant {
        Proposal storage proposal = _getProposal(_proposalId);
        require(block.number < proposal.deadlineBlock, "ERC246: Voting period has ended");
        require(!proposal.hasVoted[msg.sender], "ERC246: You have already voted on this proposal");

        // Register the voter's address
        proposal.voters.push(msg.sender);
        proposal.hasVoted[msg.sender] = true;
        proposal.voteSupport[msg.sender] = _support;

        emit VoteCast(msg.sender, _proposalId, _support);
    }

    /**
     * @notice Enqueue a proposal for execution after voting ends.
     * @dev After voting ends, anyone can call this to signal that the proposal should be executed after the time-lock.
     */
    function enqueueProposal(uint256 _proposalId) override external {
        Proposal storage proposal = _getProposal(_proposalId);
        require(block.number >= proposal.deadlineBlock, "ERC246: Voting period not yet ended");
        require(!proposal.enqueued, "ERC246: Proposal already enqueued");
        require(!proposal.executed, "ERC246: Proposal already executed");
        require(!proposal.terminatedWithRejection, "ERC246: Proposal has been rejected");

        uint256 quorumThreshold = (totalSupply() * quorumSupplyPercentageBps) / 10000;

        (uint256 votesFor, uint256 votesAgainst) = getProposalCurrentOutcome(_proposalId);

        proposal.accepted = (votesFor + votesAgainst >= quorumThreshold) && (votesFor > votesAgainst);

        if (proposal.accepted) {
            proposal.enqueued = true;
            proposal.enqueueBlock = block.number;
            emit ProposalEnqueued(_proposalId, proposal.accepted);
        }
        else {
            proposal.terminatedWithRejection = true;
            emit ProposalRejected(_proposalId);
        }
    }


    /**
     * @notice Execute a proposal after the time-lock has passed.
     * @dev This uses the outcome snapshot stored during the `enqueueProposal` call.
     */
    function executeProposal(uint256 _proposalId) external override nonReentrant {
        Proposal storage proposal = _getProposal(_proposalId);
        require(proposal.accepted, "ERC246: Cannot execute rejected proposal");
        require(proposal.enqueued, "ERC246: Proposal must be enqueued first");
        require(!proposal.executed, "ERC246: Proposal already executed");
        require(!proposal.terminatedWithRejection, "ERC246: Proposal has been rejected");

        uint256 executionBlock = proposal.enqueueBlock + executionDelayInBlocks;
        require(block.number >= executionBlock, "ERC246: Time-lock has not passed");

        proposal.executed = true;


        for (uint256 i = 0; i < proposal.targets.length;) {
            (bool success, bytes memory returnData) = proposal.targets[i].call{value: proposal.values[i]}(proposal.data[i]);
            
            if (!success) {
                // If the call fails, try to decode the revert reason
                if (returnData.length > 0) {
                    // The call reverted with a message, decode and revert with it
                    assembly {
                        let returndata_size := mload(returnData)
                        revert(add(32, returnData), returndata_size)
                    }
                } else {
                    // No revert reason, fallback to generic error
                    revert("ERC246: Execution failed for one of the targets");
                }
            }
            unchecked { ++i; }
        }

        emit ProposalExecuted(_proposalId, true);
    }

    /**
     * @notice Allows the proposer or governance to delete a proposal.
     * @param _proposalId The ID of the proposal to delete.
     */
    function deleteProposal(uint256 _proposalId) override external {
        Proposal storage proposal = _getProposal(_proposalId);

        // Ensure only proposer or governance can delete the proposal
        require(msg.sender == proposal.proposer || msg.sender == address(this), "ERC246: Only proposer or governance can delete");

        require(!proposal.enqueued, "ERC246: Cannot delete an enqueued proposal");
        require(!proposal.executed, "ERC246: Cannot delete an executed proposal");

        // Delete the proposal from storage
        delete proposals[_proposalId];

        emit ProposalDeleted(_proposalId);
    }


    // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ Functions callable only via accepted proposal ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


    /**
     * @notice Update the token name (only callable via a governance proposal).
     * @param newName The new name of the token.
     */
    function updateName(string calldata newName) external onlyGovernanceProposal {
        _name = newName;
    }

    /**
     * @notice Update the token symbol (only callable via a governance proposal).
     * @param newSymbol The new symbol of the token.
     */
    function updateSymbol(string calldata newSymbol) external onlyGovernanceProposal {
        _symbol = newSymbol;
    }

    /**
     * @notice Update the minimum voting duration in blocks.
     * @dev This function can only be called via a governance proposal (using the `onlyGovernanceProposal` modifier).
     * @param _newMinimumDuration The new minimum voting duration in blocks.
     */
    function updateMinimumVotingDurationBlocks(uint256 _newMinimumDuration) external onlyGovernanceProposal {
        require(_newMinimumDuration >= MINIMUM_ALLOWED_PROPOSAL_DURATION_BLOCKS, "ERC246: Minimum voting duration must be greater than MINIMUM_ALLOWED_PROPOSAL_DURATION_BLOCKS");
        minimumVotingDurationBlocks = _newMinimumDuration;
    }

    /**
     * @notice Update the proposal execution delay in blocks.
     * @dev This function can only be called via a governance proposal (using the `onlyGovernanceProposal` modifier).
     * @param _newDelay The new proposal execution delay in blocks.
     */
    function updateProposalExecutionDelayBlocks(uint256 _newDelay) external onlyGovernanceProposal {
        require(_newDelay >= MINIMUM_ALLOWED_EXECUTION_DELAY_BLOCKS, "ERC246: Proposal execution delay must be greater than MINIMUM_ALLOWED_EXECUTION_DELAY_BLOCKS");
        executionDelayInBlocks = _newDelay;
    }

    /**
     * @notice Update the quorum supply percentage.
     * @dev This function can only be called via a governance proposal (using the `onlyGovernanceProposal` modifier).
     * @param _newQuorumSupplyPercentage The new proposal execution delay in blocks.
     */
    function updateQuorumSupplyPercentage(uint256 _newQuorumSupplyPercentage) external onlyGovernanceProposal {
        require(_newQuorumSupplyPercentage >= MINIMUM_ALLOWED_QUORUM_SUPPLY_PERCENTAGE_BPS, "ERC246: Quorum supply percentage must be greater than MINIMUM_ALLOWED_QUORUM_SUPPLY_PERCENTAGE_BPS");
        quorumSupplyPercentageBps = _newQuorumSupplyPercentage;
    }

    /**
     * @notice Update the transfer fee percentage (in basis points) via governance proposal.
     * @param newTransferFeeBps The new transfer fee (in basis points).
     */
    function updateTransferFeeBps(uint256 newTransferFeeBps) external onlyGovernanceProposal {
        require(newTransferFeeBps <= MAX_TRANSFER_FEE_BPS, "ERC246: Transfer fee exceeds max limit");
        transferFeeBps = newTransferFeeBps;
    }

    /**
     * @notice Transfer tokens from the contract's balance to a given recipient (only callable via a governance proposal).
     * @dev This function transfers tokens from the contract balance to the specified recipient. 
     *      It can only be called via an approved governance proposal.
     * @param _recipient The address to receive the transferred tokens.
     * @param _amount The amount of tokens to transfer from the contract's balance.
     */
    function transferFromTreasury(address _recipient, uint256 _amount) external onlyGovernanceProposal {
        require(_recipient != address(0), "ERC246: Cannot transfer to the zero address");
        require(balanceOf(address(this)) >= _amount, "ERC246: Insufficient contract balance");

        _transfer(address(this), _recipient, _amount);
    }

    /**
     * @notice Mint new tokens (only callable via a governance proposal).
     * @dev This function mints tokens and ensures the total supply does not exceed
     *      a certain percentage increase from the current supply.
     * @param _recipient The address to receive the newly minted tokens.
     * @param _amount The amount of tokens to mint.
     */
    function mint(address _recipient, uint256 _amount) external onlyGovernanceProposal onlyOncePerBlock {
        require(_amount <= totalSupply() * MAXIMUM_MINT_SUPPLY_PERCENTAGE_BPS / 10000, "ERC246: Cannot mint a percentage of the supply greater than MAXIMUM_MINT_SUPPLY_PERCENTAGE");
        _mint(_recipient, _amount);
    }

    /**
     * @notice Allocate tokens to a list of recipients for future airdrop claims (only callable via a governance proposal).
     * @dev This function sets up an airdrop allocation, which can be claimed by recipients later.
     * @param recipients The list of addresses to receive the airdropped tokens.
     * @param amounts The corresponding list of amounts of tokens allocated to each recipient.
     */
    function airdropByMinting(address[] calldata recipients, uint256[] calldata amounts) external onlyGovernanceProposal onlyOncePerBlock{
        require(recipients.length == amounts.length, "ERC246: Recipients and amounts length mismatch");

        // Calculate the total amount of tokens to be minted
        uint256 totalMintAmount = 0;
        for (uint256 i = 0; i < amounts.length; i++) {
            totalMintAmount += amounts[i];
        }

        require(totalMintAmount <= (totalSupply() * MAXIMUM_MINT_SUPPLY_PERCENTAGE_BPS) / 10000, "ERC246: Minting amount exceeds maximum supply percentage");

        for (uint256 i = 0; i < recipients.length; i++) {
            mintAirdropAllocations[recipients[i]] += amounts[i];
        }
    }

    /**
     * @notice Allocate tokens to a list of recipients for future claims using the contract’s treasury (only callable via governance proposal).
     * @dev This function sets up an airdrop allocation using treasury funds.
     * @param recipients The list of addresses to receive the airdropped tokens.
     * @param amounts The corresponding list of amounts of tokens allocated to each recipient.
     */
    function airdropFromTreasury(address[] calldata recipients, uint256[] calldata amounts) external onlyGovernanceProposal {
        require(recipients.length == amounts.length, "ERC246: Recipients and amounts length mismatch");

        uint256 totalAirdropAmount = 0;
        for (uint256 i = 0; i < recipients.length; i++) {
            totalAirdropAmount += amounts[i];
            airdropAllocationsFromTreasury[recipients[i]] += amounts[i];
        }

        require(balanceOf(address(this)) >= totalAirdropAmount, "ERC246: Insufficient contract balance for airdrop");

        lockedTreasuryTokens += totalAirdropAmount;
    }

    /**
     * @notice Burn tokens from the contract's treasury (only callable via a governance proposal).
     * @dev This function burns tokens from the contract balance, reducing the total supply.
     * @param _amount The amount of tokens to burn from the contract's treasury.
     */
    function burnFromTreasury(uint256 _amount) external onlyGovernanceProposal {
        _burn(address(this), _amount);
    }



    // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ Other utility functions ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


    /**
     * @notice Claim allocated airdrop tokens that were minted.
     * @dev This function allows recipients to claim their allocated airdrop tokens from minting.
     */
    function claimMintAirdrop() external nonReentrant {
        uint256 amount = mintAirdropAllocations[msg.sender];
        require(amount > 0, "ERC246: No airdrop tokens available to claim from mint");

        mintAirdropAllocations[msg.sender] = 0;

        _mint(msg.sender, amount);
    }

    /**
     * @notice Claim allocated airdrop tokens from the contract's balance (treasury).
     * @dev This function allows recipients to claim their allocated airdrop tokens from treasury.
     */
    function claimAirdropFromTreasury() external nonReentrant {
        uint256 amount = airdropAllocationsFromTreasury[msg.sender];
        require(amount > 0, "ERC246: No airdrop tokens available to claim from treasury");

        airdropAllocationsFromTreasury[msg.sender] = 0;

        lockedTreasuryTokens -= amount;

        _transfer(address(this), msg.sender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override {
        // If the contract itself is the sender (i.e., tokens are being transferred from the treasury)
        if (from == address(this)) {
            // Ensure that the amount being transferred does not exceed the unlocked balance
            require(balanceOf(address(this)) - lockedTreasuryTokens >= amount, "ERC246: Insufficient unlocked treasury balance");
        }

        if (to != address(0) && from != address(0)) {
            // Track the block number for token acquisition (for governance voting purposes)
            lastTokenAcquisitionBlock[to] = block.number;
        }

        super._beforeTokenTransfer(from, to, amount);
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        // Apply transfer fee if applicable
        if (transferFeeBps > 0 && from != address(0) && to != address(0)) {
            uint256 feeAmount = (amount * transferFeeBps) / 10000;
            uint256 transferAmount = amount - feeAmount;

            // Transfer the fee to the treasury
            super._transfer(from, address(this), feeAmount);

            // Transfer the remaining amount to the recipient
            super._transfer(from, to, transferAmount);
        } else {
            // Perform the regular transfer if no fees
            super._transfer(from, to, amount);
        }
    }



    // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ View/pure functions ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


    /**
     * @notice Calculate the available voting power for an account.
     * @param _account The address of the voter.
     * @return The available voting power based on token balance.
     */
    function _getVotingPower(address _account) internal view returns (uint256) {
        if (block.number == lastTokenAcquisitionBlock[_account]) {return 0;}
        return balanceOf(_account);
    }

    /**
     * @notice Get the current voting outcome of a proposal.
     * @dev This function calculates the total votes for and against a proposal based on the current token balances of voters.
     * It loops through all voters of the proposal and calculates their voting power.
     * @param _proposalId The ID of the proposal for which to retrieve the voting outcome.
     * @return votesFor The total votes in favor of the proposal, calculated from the voting power of supporting voters.
     * @return votesAgainst The total votes against the proposal, calculated from the voting power of opposing voters.
     */
    function getProposalCurrentOutcome(uint256 _proposalId) override public view returns (uint256 votesFor, uint256 votesAgainst) {
        Proposal storage proposal = _getProposal(_proposalId);
        
        // Initialize votes for and against
        uint256 totalVotesFor = 0;
        uint256 totalVotesAgainst = 0;
        
        // Calculate voting power based on current token balances
        address[] memory voters = proposal.voters;
        uint256 numVoters = voters.length;
        for (uint256 i = 0; i < numVoters;) {
            address voter = voters[i];
            uint256 currentVotingPower = _getVotingPower(voter); // Snapshot based on current balance
            
            if (proposal.voteSupport[voter]) {
                unchecked { totalVotesFor += currentVotingPower; }
            } else {
                unchecked { totalVotesAgainst += currentVotingPower; }
            }
            unchecked { ++i; }
        }
        
        return (totalVotesFor, totalVotesAgainst);
    }

    /**
     * @dev Internal function to retrieve a proposal and ensure it hasn't been deleted.
     * @param _proposalId The ID of the proposal to retrieve.
     * @return proposal The retrieved proposal.
     */
    function _getProposal(uint256 _proposalId) private view returns (Proposal storage) {
        Proposal storage proposal = proposals[_proposalId];
        require(proposal.proposer != address(0), "ERC246: Proposal does not exist or has been deleted");
        return proposal;
    }

    /**
     * @notice Override the `name` function from ERC20 to allow dynamic updates via governance proposal.
     * @return The name of the token.
     */
    function name() public view override returns (string memory) {
        return _name;
    }

    /**
     * @notice Override the `symbol` function from ERC20 to allow dynamic updates via governance proposal.
     * @return The symbol of the token.
     */
    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    /**
     * @notice Get target contract addresses of a proposal
     * @return An array of target contract addresses
     */
    function getProposalTargets(uint256 _proposalId) public view returns (address[] memory) {
        return _getProposal(_proposalId).targets;
    }

    /**
     * @notice Get encoded functions call data of a proposal
     * @return An array of encoded functions call data
     */
    function getProposalFunctionsData(uint256 _proposalId) public view returns (bytes[] memory) {
        return _getProposal(_proposalId).data;
    }

    /**
     * @notice Get ETH values of a proposal
     * @return An array of ETH values
     */
    function getProposalETHValues(uint256 _proposalId) public view returns (uint256[] memory) {
        return _getProposal(_proposalId).values;
    }

    /**
     * @notice Get addresses who voted in a proposal
     * @return An array voter addresses
     */
    function getProposalVoters(uint256 _proposalId) public view returns (address[] memory) {
        return _getProposal(_proposalId).voters;
    }

    /**
     * @notice Checks if a address has voted in a proposal
     * @return Boolean indicating if the address has voted
     */
    function hasVoted(address _voter, uint256 _proposalId) public view returns (bool) {
        return _getProposal(_proposalId).hasVoted[_voter];
    }

    /**
     * @notice Checks if a address has voted for or against a proposal
     * @return Boolean indicating voter's support
     */
    function gatVoteSupport(address _voter, uint256 _proposalId) public view returns (bool) {
        return _getProposal(_proposalId).voteSupport[_voter];
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IERC246
 * @dev Interface for the ERCX governance token with proposal and voting functionality.
 */
interface IERC246 {

    /**
     * @notice Create a new proposal with multiple function calls.
     * @param _targets The target contract addresses for the proposal.
     * @param _data The encoded function calls (signature + parameters) to be executed if the proposal passes.
     * @param _values The amount of Ether to send with each function call.
     * @param _votingDurationInBlocks The duration (in blocks) for which the proposal will be open for voting.
     */
    function createProposal(string memory title, address[] memory _targets, bytes[] memory _data, uint256[] memory _values, uint256 _votingDurationInBlocks) external;

    /**
     * @notice Vote on an active proposal.
     * @param _proposalId The ID of the proposal to vote on.
     * @param _support A boolean indicating whether the vote is in favor (true) or against (false).
     */
    function vote(uint256 _proposalId, bool _support) external;

    /**
     * @notice Enqueue a proposal for execution after voting ends.
     * @param _proposalId The ID of the proposal to enqueue.
     */
    function enqueueProposal(uint256 _proposalId) external;

    /**
     * @notice Execute the proposal if the voting period has ended and the proposal passed.
     * @param _proposalId The ID of the proposal to execute.
     */
    function executeProposal(uint256 _proposalId) external;

    /**
     * @notice Allows the proposer or governance to delete a proposal.
     * @param _proposalId The ID of the proposal to delete.
     */
    function deleteProposal(uint256 _proposalId) external;

    /**
     * @notice Get the current voting outcome of a proposal.
     * @param _proposalId The ID of the proposal to check.
     * @return votesFor The total votes in favor of the proposal.
     * @return votesAgainst The total votes against the proposal.
     */
    function getProposalCurrentOutcome(uint256 _proposalId) external view returns (uint256 votesFor, uint256 votesAgainst);

    /**
     * @notice Event emitted when a new proposal is created.
     * @param proposalId The ID of the proposal.
     * @param targets The target contract addresses.
     * @param data The encoded function calls.
     * @param values The amount of Ether to send with each function call.
     * @param deadlineBlock The block number at which voting will end.
     */
    event ProposalCreated(uint256 indexed proposalId, address[] targets, bytes[] data, uint256[] values, uint256 deadlineBlock);

    /**
     * @notice Event emitted when a vote is cast.
     * @param voter The address of the voter.
     * @param proposalId The ID of the proposal.
     * @param support Whether the vote was in favor or against the proposal.
     */
    event VoteCast(address indexed voter, uint256 indexed proposalId, bool support);

    /**
     * @notice Event emitted when a proposal is enqueued for execution.
     * @param proposalId The ID of the proposal.
     * @param accepted Whether the proposal was accepted (true) or rejected (false).
     */
    event ProposalEnqueued(uint256 indexed proposalId, bool indexed accepted);

    /**
     * @notice Event emitted when a proposal is executed.
     * @param proposalId The ID of the proposal.
     * @param accepted Whether the proposal was accepted (true) or rejected (false).
     */
    event ProposalExecuted(uint256 indexed proposalId, bool indexed accepted);

    /**
     * @notice Event emitted when a proposal is rejected.
     * @param proposalId The ID of the proposal.
     */
    event ProposalRejected(uint256 indexed proposalId);

    /**
     * @notice Event emitted when a proposal is deleted.
     * @param proposalId The ID of the proposal.
     */
    event ProposalDeleted(uint256 indexed proposalId);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ERC246.sol";

contract Vote is ERC246 {
    /**
     * @notice Constructor to initialize the governance token.
     * @param name_ The name of the ERC20 token.
     * @param symbol_ The symbol of the ERC20 token.
     * @param _initialSupply The initial token supply to be minted.
     */
    constructor(string memory name_, string memory symbol_, uint256 _initialSupply) ERC246(name_, symbol_) {
        _mint(msg.sender, _initialSupply);
    }
}