// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC1271.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC1271 standard signature validation method for
 * contracts as defined in https://eips.ethereum.org/EIPS/eip-1271[ERC-1271].
 *
 * _Available since v4.1._
 */
interface IERC1271 {
    /**
     * @dev Should return whether the signature provided is valid for the provided data
     * @param hash      Hash of the data to be signed
     * @param signature Signature byte array associated with _data
     */
    function isValidSignature(bytes32 hash, bytes memory signature) external view returns (bytes4 magicValue);
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
// OpenZeppelin Contracts (last updated v4.9.0) (utils/cryptography/SignatureChecker.sol)

pragma solidity ^0.8.0;

import "./ECDSA.sol";
import "../../interfaces/IERC1271.sol";

/**
 * @dev Signature verification helper that can be used instead of `ECDSA.recover` to seamlessly support both ECDSA
 * signatures from externally owned accounts (EOAs) as well as ERC1271 signatures from smart contract wallets like
 * Argent and Gnosis Safe.
 *
 * _Available since v4.1._
 */
library SignatureChecker {
    /**
     * @dev Checks if a signature is valid for a given signer and data hash. If the signer is a smart contract, the
     * signature is validated against that smart contract using ERC1271, otherwise it's validated using `ECDSA.recover`.
     *
     * NOTE: Unlike ECDSA signatures, contract signatures are revocable, and the outcome of this function can thus
     * change through time. It could return true at block N and false at block N+1 (or the opposite).
     */
    function isValidSignatureNow(address signer, bytes32 hash, bytes memory signature) internal view returns (bool) {
        (address recovered, ECDSA.RecoverError error) = ECDSA.tryRecover(hash, signature);
        return
            (error == ECDSA.RecoverError.NoError && recovered == signer) ||
            isValidERC1271SignatureNow(signer, hash, signature);
    }

    /**
     * @dev Checks if a signature is valid for a given signer and data hash. The signature is validated
     * against the signer smart contract using ERC1271.
     *
     * NOTE: Unlike ECDSA signatures, contract signatures are revocable, and the outcome of this function can thus
     * change through time. It could return true at block N and false at block N+1 (or the opposite).
     */
    function isValidERC1271SignatureNow(
        address signer,
        bytes32 hash,
        bytes memory signature
    ) internal view returns (bool) {
        (bool success, bytes memory result) = signer.staticcall(
            abi.encodeWithSelector(IERC1271.isValidSignature.selector, hash, signature)
        );
        return (success &&
            result.length >= 32 &&
            abi.decode(result, (bytes32)) == bytes32(IERC1271.isValidSignature.selector));
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
// Metadrop Contracts (v2.1.0)

pragma solidity 0.8.21;

import {IConfigStructures} from "../../Global/IConfigStructures.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20ConfigByMetadrop} from "./IERC20ConfigByMetadrop.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

/**
 * @dev Metadrop core ERC-20 contract, interface
 */
interface IERC20ByMetadrop is
  IConfigStructures,
  IERC20,
  IERC20ConfigByMetadrop,
  IERC20Metadata
{
  event AutoSwapThresholdUpdated(uint256 oldThreshold, uint256 newThreshold);

  event ExternalCallError(uint256 identifier);

  event InitialLiquidityAdded(uint256 tokenA, uint256 tokenB, uint256 lpToken);

  event LimitsUpdated(
    uint256 oldMaxTokensPerTransaction,
    uint256 newMaxTokensPerTransaction,
    uint256 oldMaxTokensPerWallet,
    uint256 newMaxTokensPerWallet
  );

  event LiquidityLocked(uint256 lpTokens, uint256 lpLockupInDays);

  event LiquidityBurned(uint256 lpTokens);

  event LiquidityPoolCreated(address addedPool);

  event LiquidityPoolAdded(address addedPool);

  event LiquidityPoolRemoved(address removedPool);

  event MetadropTaxBasisPointsChanged(
    uint256 oldBuyBasisPoints,
    uint256 newBuyBasisPoints,
    uint256 oldSellBasisPoints,
    uint256 newSellBasisPoints
  );

  event ProjectTaxBasisPointsChanged(
    uint256 oldBuyBasisPoints,
    uint256 newBuyBasisPoints,
    uint256 oldSellBasisPoints,
    uint256 newSellBasisPoints
  );

  event RevenueAutoSwap();

  event ProjectTaxRecipientUpdated(address treasury);

  event UnlimitedAddressAdded(address addedUnlimted);

  event UnlimitedAddressRemoved(address removedUnlimted);

  event ValidCallerAdded(bytes32 addedValidCaller);

  event ValidCallerRemoved(bytes32 removedValidCaller);

  /**
   * @dev function {addInitialLiquidity}
   *
   * Add initial liquidity to the uniswap pair
   *
   * @param vaultFee_ The vault fee in wei. This must match the required fee from the external vault contract.
   * @param lpLockupInDaysOverride_ The number of days to lock liquidity NOTE you can pass 0 to use the stored value.
   * This value is an override, and will override a stored value which is LOWER that it. If the value you are passing is
   * LOWER than the stored value the stored value will not be reduced.
   *
   * Example usage 1: When creating the coin the lpLockupInDays is set to 0. This means that on this call the
   * user can set the lockup to any value they like, as all integer values greater than zero will be used to override
   * that set in storage.
   *
   * Example usage 2: When using a DRI Pool the lockup period is set on this contract and the pool need not know anything
   * about this setting. The pool can pass back a 0 on this call and know that the existing value stored on this contract
   * will be used.
   * @param burnLPTokensOverride_ If the LP tokens should be burned (otherwise they are locked). This is an override field
   * that can ONLY be used to override a held value of FALSE with a new value of TRUE.
   *
   * Example usage 1: When creating the coin the user didn't add liquidity, or specify that the LP tokens were to be burned.
   * So burnLPTokens is held as FALSE. When they add liquidity they want to lock tokens, so they pass this in as FALSE again,
   * and it remains FALSE.
   *
   * Example usage 2: As above, but when later adding liquidity the user wants to burn the LP. So the stored value is FALSE
   * and the user passes TRUE into this method. The TRUE overrides the held value of FALSE and the tokens are burned.
   *
   * Example uusage 3: The user is using a DRI pool and they have specified on the coin creation that the LP tokens are to
   * be burned. This contract therefore holds TRUE for burnLPTokens. The DRI pool does not need to know what the user has
   * selected. It can safely pass back FALSE to this method call and the stored value of TRUE will remain, resulting in the
   * LP tokens being burned.
   */
  function addInitialLiquidity(
    uint256 vaultFee_,
    uint256 lpLockupInDaysOverride_,
    bool burnLPTokensOverride_
  ) external payable;

  /**
   * @dev function {isLiquidityPool}
   *
   * Return if an address is a liquidity pool
   *
   * @param queryAddress_ The address being queried
   * @return bool The address is / isn't a liquidity pool
   */
  function isLiquidityPool(address queryAddress_) external view returns (bool);

  /**
   * @dev function {liquidityPools}
   *
   * Returns a list of all liquidity pools
   *
   * @return liquidityPools_ a list of all liquidity pools
   */
  function liquidityPools()
    external
    view
    returns (address[] memory liquidityPools_);

  /**
   * @dev function {addLiquidityPool} onlyOwner
   *
   * Allows the manager to add a liquidity pool to the pool enumerable set
   *
   * @param newLiquidityPool_ The address of the new liquidity pool
   */
  function addLiquidityPool(address newLiquidityPool_) external;

  /**
   * @dev function {removeLiquidityPool} onlyOwner
   *
   * Allows the manager to remove a liquidity pool
   *
   * @param removedLiquidityPool_ The address of the old removed liquidity pool
   */
  function removeLiquidityPool(address removedLiquidityPool_) external;

  /**
   * @dev function {isUnlimited}
   *
   * Return if an address is unlimited (is not subject to per txn and per wallet limits)
   *
   * @param queryAddress_ The address being queried
   * @return bool The address is / isn't unlimited
   */
  function isUnlimited(address queryAddress_) external view returns (bool);

  /**
   * @dev function {unlimitedAddresses}
   *
   * Returns a list of all unlimited addresses
   *
   * @return unlimitedAddresses_ a list of all unlimited addresses
   */
  function unlimitedAddresses()
    external
    view
    returns (address[] memory unlimitedAddresses_);

  /**
   * @dev function {addUnlimited} onlyOwner
   *
   * Allows the manager to add an unlimited address
   *
   * @param newUnlimited_ The address of the new unlimited address
   */
  function addUnlimited(address newUnlimited_) external;

  /**
   * @dev function {removeUnlimited} onlyOwner
   *
   * Allows the manager to remove an unlimited address
   *
   * @param removedUnlimited_ The address of the old removed unlimited address
   */
  function removeUnlimited(address removedUnlimited_) external;

  /**
   * @dev function {isValidCaller}
   *
   * Return if an address is a valid caller
   *
   * @param queryHash_ The code hash being queried
   * @return bool The address is / isn't a valid caller
   */
  function isValidCaller(bytes32 queryHash_) external view returns (bool);

  /**
   * @dev function {validCallers}
   *
   * Returns a list of all valid caller code hashes
   *
   * @return validCallerHashes_ a list of all valid caller code hashes
   */
  function validCallers()
    external
    view
    returns (bytes32[] memory validCallerHashes_);

  /**
   * @dev function {addValidCaller} onlyOwner
   *
   * Allows the owner to add the hash of a valid caller
   *
   * @param newValidCallerHash_ The hash of the new valid caller
   */
  function addValidCaller(bytes32 newValidCallerHash_) external;

  /**
   * @dev function {removeValidCaller} onlyOwner
   *
   * Allows the owner to remove a valid caller
   *
   * @param removedValidCallerHash_ The hash of the old removed valid caller
   */
  function removeValidCaller(bytes32 removedValidCallerHash_) external;

  /**
   * @dev function {setProjectTaxRecipient} onlyOwner
   *
   * Allows the manager to set the project tax recipient address
   *
   * @param projectTaxRecipient_ New recipient address
   */
  function setProjectTaxRecipient(address projectTaxRecipient_) external;

  /**
   * @dev function {setSwapThresholdBasisPoints} onlyOwner
   *
   * Allows the manager to set the autoswap threshold
   *
   * @param swapThresholdBasisPoints_ New swap threshold in basis points
   */
  function setSwapThresholdBasisPoints(
    uint16 swapThresholdBasisPoints_
  ) external;

  /**
   * @dev function {setProjectTaxRates} onlyOwner
   *
   * Change the tax rates, subject to only ever decreasing
   *
   * @param newProjectBuyTaxBasisPoints_ The new buy tax rate
   * @param newProjectSellTaxBasisPoints_ The new sell tax rate
   */
  function setProjectTaxRates(
    uint16 newProjectBuyTaxBasisPoints_,
    uint16 newProjectSellTaxBasisPoints_
  ) external;

  /**
   * @dev function {setLimits} onlyOwner
   *
   * Change the limits on transactions and holdings
   *
   * @param newMaxTokensPerTransaction_ The new per txn limit
   * @param newMaxTokensPerWallet_ The new tokens per wallet limit
   */
  function setLimits(
    uint256 newMaxTokensPerTransaction_,
    uint256 newMaxTokensPerWallet_
  ) external;

  /**
   * @dev function {limitsEnforced}
   *
   * Return if limits are enforced on this contract
   *
   * @return bool : they are / aren't
   */
  function limitsEnforced() external view returns (bool);

  /**
   * @dev getMetadropBuyTaxBasisPoints
   *
   * Return the metadrop buy tax basis points given the timed expiry
   */
  function getMetadropBuyTaxBasisPoints() external view returns (uint256);

  /**
   * @dev getMetadropSellTaxBasisPoints
   *
   * Return the metadrop sell tax basis points given the timed expiry
   */
  function getMetadropSellTaxBasisPoints() external view returns (uint256);

  /**
   * @dev totalBuyTaxBasisPoints
   *
   * Provide easy to view tax total:
   */
  function totalBuyTaxBasisPoints() external view returns (uint256);

  /**
   * @dev totalSellTaxBasisPoints
   *
   * Provide easy to view tax total:
   */
  function totalSellTaxBasisPoints() external view returns (uint256);

  /**
   * @dev distributeTaxTokens
   *
   * Allows the distribution of tax tokens to the designated recipient(s)
   *
   * As part of standard processing the tax token balance being above the threshold
   * will trigger an autoswap to ETH and distribution of this ETH to the designated
   * recipients. This is automatic and there is no need for user involvement.
   *
   * As part of this swap there are a number of calculations performed, particularly
   * if the tax balance is above MAX_SWAP_THRESHOLD_MULTIPLE.
   *
   * Testing indicates that these calculations are safe. But given the data / code
   * interactions it remains possible that some edge case set of scenarios may cause
   * an issue with these calculations.
   *
   * This method is therefore provided as a 'fallback' option to safely distribute
   * accumulated taxes from the contract, with a direct transfer of the ERC20 tokens
   * themselves.
   */
  function distributeTaxTokens() external;

  /**
   * @dev function {rescueETH} onlyOwner
   *
   * A withdraw function to allow ETH to be rescued.
   *
   * This contract should never hold ETH. The only envisaged scenario where
   * it might hold ETH is a failed autoswap where the uniswap swap has completed,
   * the recipient of ETH reverts, the contract then wraps to WETH and the
   * wrap to WETH fails.
   *
   * This feels unlikely. But, for safety, we include this method.
   *
   * @param amount_ The amount to withdraw
   */
  function rescueETH(uint256 amount_) external;

  /**
   * @dev function {rescueERC20}
   *
   * A withdraw function to allow ERC20s (except address(this)) to be rescued.
   *
   * This contract should never hold ERC20s other than tax tokens. The only envisaged
   * scenario where it might hold an ERC20 is a failed autoswap where the uniswap swap
   * has completed, the recipient of ETH reverts, the contract then wraps to WETH, the
   * wrap to WETH succeeds, BUT then the transfer of WETH fails.
   *
   * This feels even less likely than the scenario where ETH is held on the contract.
   * But, for safety, we include this method.
   *
   * @param token_ The ERC20 contract
   * @param amount_ The amount to withdraw
   */
  function rescueERC20(address token_, uint256 amount_) external;

  /**
   * @dev function {rescueExcessToken}
   *
   * A withdraw function to allow ERC20s from this address that are above
   * the accrued tax balance to be rescued.
   */
  function rescueExcessToken(uint256 amount_) external;

  /**
   * @dev Destroys a `value` amount of tokens from the caller.
   *
   * See {ERC20-_burn}.
   */
  function burn(uint256 value) external;

  /**
   * @dev Destroys a `value` amount of tokens from `account`, deducting from
   * the caller's allowance.
   *
   * See {ERC20-_burn} and {ERC20-allowance}.
   *
   * Requirements:
   *
   * - the caller must have allowance for ``accounts``'s tokens of at least
   * `value`.
   */
  function burnFrom(address account, uint256 value) external;
}
// SPDX-License-Identifier: MIT
// Metadrop Contracts (v2.1.0)

/**
 *
 * @title IERC20ByMetadrop.sol. Interface for metadrop ERC20 standard
 *
 * @author metadrop https://metadrop.com/
 *
 */

pragma solidity 0.8.21;

interface IERC20ConfigByMetadrop {
  enum DRIPoolType {
    fundingLP,
    initialBuy
  }

  enum VaultType {
    unicrypt,
    metavault
  }

  struct ERC20Config {
    bytes baseParameters;
    bytes supplyParameters;
    bytes taxParameters;
    bytes poolParameters;
  }

  struct ERC20BaseParameters {
    string name;
    string symbol;
    bool addLiquidityOnCreate;
    bool usesDRIPool;
  }

  struct ERC20SupplyParameters {
    uint256 maxSupply;
    uint256 lpSupply;
    uint256 projectSupply;
    uint256 maxTokensPerWallet;
    uint256 maxTokensPerTxn;
    uint256 lpLockupInDays;
    uint256 botProtectionDurationInSeconds;
    address projectSupplyRecipient;
    address projectLPOwner;
    bool burnLPTokens;
  }

  struct ERC20TaxParameters {
    uint256 projectBuyTaxBasisPoints;
    uint256 projectSellTaxBasisPoints;
    uint256 taxSwapThresholdBasisPoints;
    uint256 metadropBuyTaxBasisPoints;
    uint256 metadropSellTaxBasisPoints;
    uint256 metadropTaxPeriodInDays;
    address projectTaxRecipient;
    address metadropTaxRecipient;
    uint256 metadropMinBuyTaxBasisPoints;
    uint256 metadropMinSellTaxBasisPoints;
    uint256 metadropBuyTaxProportionBasisPoints;
    uint256 metadropSellTaxProportionBasisPoints;
    uint256 autoBurnDurationInBlocks;
    uint256 autoBurnBasisPoints;
  }

  struct ERC20PoolParameters {
    uint256 poolType;
    uint256 poolSupply;
    uint256 poolStartDate;
    uint256 poolEndDate;
    uint256 poolVestingInSeconds;
    uint256 poolMaxETH;
    uint256 poolPerAddressMaxETH;
    uint256 poolMinETH;
    uint256 poolPerTransactionMinETH;
    uint256 poolContributionFeeBasisPoints;
    uint256 poolMaxInitialBuy;
    uint256 poolMaxInitialLiquidity;
    address poolFeeRecipient;
  }
}
// SPDX-License-Identifier: BUSL-1.1
// Metadrop Contracts (v2.1.0)

pragma solidity 0.8.21;
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20ByMetadrop} from "../ERC20/IERC20ByMetadrop.sol";
import {IERC20DRIPoolByMetadrop} from "./IERC20DRIPoolByMetadrop.sol";
import {IUniswapV2Router02} from "../../ThirdParty/Uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import {Revert} from "../../Global/Revert.sol";
import {SafeERC20, IERC20} from "../../Global/OZ/SafeERC20.sol";
import {SignatureChecker} from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";

/**
 * @dev Metadrop ERC-20 Decentralised Rationalised Incentive Pool (DRIP)
 *
 * @dev Implementation of the {IERC20DRIPoolByMetadrop} interface.
 */

contract ERC20DRIPoolByMetadrop is ERC20, IERC20DRIPoolByMetadrop, Revert {
  using SafeERC20 for IERC20ByMetadrop;
  using SafeERC20 for IERC20;

  // Multiplier constant: you receive 1,000,000 DRIP for every ETH contributed:
  uint256 private constant ETH_TO_DRIP_MULTIPLIER = 1000000;

  // DRIP are burned to the 0x...dEaD address (not address(0)) in order to maintain a constant total
  // supply value during claims and refunds:
  address private constant DEAD_ADDRESS =
    0x000000000000000000000000000000000000dEaD;

  // Proportions are held in basis points, this is the basis point denominator:
  uint256 internal constant CONST_BP_DENOM = 10000;

  // The oracle signed message validity period:
  uint256 internal constant MSG_VALIDITY_SECONDS = 30 minutes;

  // The DP we use to truncate the fee amount. We truncate this many positions of WEI
  // from the fee. For example, is this is 10 ** 12 we are truncating to 6 DP of ETH, i.e.
  // we are setting the final 12 figures of the fee to zeros (ETH having 18 decimal places).
  uint256 internal constant FEE_DP_OF_ETH_FACTOR = 10 ** 12;

  // Address of the uniswap router on this chain:
  IUniswapV2Router02 public immutable uniswapRouter;

  // Metadrop Oracle Address:
  address public immutable metadropOracleAddress;

  // Slot 1: accessed when contributing to the pool
  //     96
  //     80
  //     64
  //     16
  // ------
  //    256
  // ------
  // What is the max pooled ETH? Contributions that would exceed this amount will not
  // be accepted: If this is ZERO there is no no limits, won't give up the fight.
  uint96 public poolMaxETH;

  // What is the max contribution per address? If this is ZERO there is no no limits,
  // we'll reach for the sky
  uint80 public poolPerAddressMaxETH;

  // What is the minimum contribution per transaction?:
  uint64 public poolPerTransactionMinETH;

  // Contribution fee in basis points - how much is automatically deducted from contribution. Note
  // that this is applied irrespective of whether EXCESS ETH is refunded at a point in the future
  // (for example if the pool is oversubscribed and only a portion of the contributed ETH is
  // converted to token ownership).
  // However - if the pool falls below the minimum contributions are refunded 100% i.e. no fee.
  uint16 public poolContributionFeeBasisPoints;

  // Slot 2: accessed when contributing to the pool:
  //     32
  //     32
  //     96
  //     96
  // ------
  //    256
  // ------
  // When does the pool phase start? Contributions to the DRIP will not be accepted
  // before this date:
  uint32 public poolStartDate;

  // When does the pool phase end? Contributions to the DRIP will not be accepted
  // after this date:
  uint32 public poolEndDate;

  // How many fees have accumulated:
  uint96 public accumulatedFees;

  // Store of the amount of ETH funded into LP / token buy:
  uint96 public totalETHFundedToLPAndTokenBuy;

  // Slot 3: accessed when claiming from the pool:
  //      8
  //     16
  //     16
  //    120
  //     96
  // ------
  //    256
  // ------
  // Pool type:
  DRIPoolType private _driPoolType;

  // If there is a vesting period for token claims this var will be that period in DAYS:
  uint32 public poolVestingInSeconds;

  // The supply of the pooled token in this pool (this is the token that pool participants
  // will claim, not the DRIP token):
  uint120 public supplyInThePool;

  // An accumulator for the total excess ETH refunded:
  uint96 public totalExcessETHRefunded;

  // Slot 4: accessed when claiming from the pool
  //    160
  //     96
  // ------
  //    256
  // ------
  // This is the contract address of the metadrop ERC20 that is being placed in this
  // pool:
  IERC20ByMetadrop public createdERC20;

  // Minimum amount for the pool to proceed:
  uint96 public poolMinETH;

  // Slot 5: accessed as part of claims / refunds
  //    160
  //     96
  // ------
  //    256
  // ------
  // The address that seeded the project ETH:
  address public projectSeedContributionAddress;

  // The amount of ETH seeded:
  uint96 public projectSeedContributionETH;

  // Slot 6: accessed as part of the supply funding / intitial buy process
  //    160
  //     96
  // ------
  //    256
  // ------
  // Recipient of accumulated fees
  address public poolFeeRecipient;

  // Max initial buy size. ETH above this will be refunded on a pro-rata basis
  uint96 public maxInitialBuy;

  // Slot 7: accessed as part of the supply funding / intitial buy process (if this is
  // an intial funding type pool)
  //     96
  //      8
  // ------
  //    104
  // ------
  // Max initial liquidity size. ETH above this will be refunded on a pro-rata basis
  uint96 public maxInitialLiquidity;

  // Bool that controls initialisation and only allows it to occur ONCE. This is
  // needed as this contract is clonable, threfore the constructor is not called
  // on cloned instances. We setup state of this contract through the initialise
  // function.
  bool public initialised;

  // Slot 8 to n:
  // ------
  //    256
  // ------
  // The name of this DRIP token:
  string private _dripName;

  // The symbol of this DRIP token:
  string private _dripSymbol;

  // Store the details of every participant, being the ETH they have contributed
  // (less the fee, if any), and any refund they have already received.
  mapping(address => Participant) public participant;

  /**
   * @dev {constructor}
   *
   * The constructor is not called when the contract is cloned.
   *
   * In this we just set the router address and the template contract
   * itself to initialised.
   *
   * @param router_ The address of the uniswap router on this chain.
   */
  constructor(
    address router_,
    address oracle_
  ) ERC20("Metadrop DRI Pool Token", "DRIP") {
    initialised = true;
    if (router_ == address(0)) {
      _revert(RouterCannotBeZeroAddress.selector);
    }
    if (oracle_ == address(0)) {
      _revert(MetadropOracleCannotBeAddressZero.selector);
    }
    uniswapRouter = IUniswapV2Router02(router_);
    metadropOracleAddress = oracle_;
  }

  /**
   * @dev {onlyDuringPoolPhase}
   *
   * Throws if NOT during the pool phase
   */
  modifier onlyDuringPoolPhase() {
    if (_poolPhaseStatus() != PhaseStatus.open) {
      _revert(PoolPhaseIsNotOpen.selector);
    }
    _;
  }

  /**
   * @dev {onlyAfterSuccessfulPoolPhase}
   *
   * Throws if NOT after the pool phase AND the phase succeeded
   */
  modifier onlyAfterSuccessfulPoolPhase() {
    if (_poolPhaseStatus() != PhaseStatus.succeeded) {
      _revert(PoolPhaseIsNotSucceeded.selector);
    }
    _;
  }

  /**
   * @dev {onlyAfterFailedPoolPhase}
   *
   * Throws if NOT after the pool phase AND the phase failed
   */
  modifier onlyAfterFailedPoolPhase() {
    if (_poolPhaseStatus() != PhaseStatus.failed) {
      _revert(PoolPhaseIsNotFailed.selector);
    }
    _;
  }

  /**
   * @dev {onlyWhenTokensVested}
   *
   * Throws if NOT after the token vesting date
   */
  modifier onlyWhenTokensVested() {
    if (block.timestamp < vestingEndDate()) {
      _revert(PoolVestingNotYetComplete.selector);
    }
    _;
  }

  /**
   * @dev {onlyFeeRecipient}
   *
   * Throws if NOT called by the fee recipient
   */
  modifier onlyFeeRecipient() {
    _checkFeeRecipient();
    _;
  }

  /**
   * @dev Throws if the sender is not the manager.
   */
  function _checkFeeRecipient() internal view virtual {
    if (poolFeeRecipient != _msgSender()) {
      _revert(CallerIsNotTheFeeRecipient.selector);
    }
  }

  /**
   * @dev {name}
   *
   * Returns the name of the token.
   */
  function name() public view override returns (string memory) {
    return _dripName;
  }

  /**
   * @dev {symbol}
   *
   * Returns the symbol of the token, usually a shorter version of the name.
   */
  function symbol() public view override returns (string memory) {
    return _dripSymbol;
  }

  /**
   * @dev {driType}
   *
   * Returns the type of this DRI pool
   */
  function driType() external view returns (DRIPoolType) {
    return _driPoolType;
  }

  /**
   * @dev {initialiseDRIP}
   *
   * Initalise configuration on a new minimal proxy clone
   *
   * @param poolParams_ bytes parameter object that will be decoded into configuration items.
   * @param name_ the name of the associated ERC20 token
   * @param symbol_ the symbol of the associated ERC20 token
   */
  function initialiseDRIP(
    bytes calldata poolParams_,
    string calldata name_,
    string calldata symbol_
  ) external {
    _initialisationControl();

    _setNameAndSymbol(name_, symbol_);

    _processPoolParams(poolParams_);

    emit DRIPoolCreatedAndInitialised();
  }

  /**
   * @dev {_initialisationControl}
   *
   * Check and set the initialistion boolean
   */
  function _initialisationControl() internal {
    if (initialised) {
      _revert(AlreadyInitialised.selector);
    }
    initialised = true;
  }

  /**
   * @dev {_setNameAndSymbol}
   *
   * Set the name and the symbol
   *
   * @param name_ The name of token
   * @param symbol_ The symbol token
   */
  function _setNameAndSymbol(
    string calldata name_,
    string calldata symbol_
  ) internal {
    _dripName = string.concat(name_, " - Metadrop Launch Pool Token");
    _dripSymbol = _getDripSymbol(symbol_);
  }

  /**
   * @dev Get the drip symbol, being the first six chars of the token symbol + '-DRIP'
   * We get just the first six chars as metamask has a default limit of 11 chars per token
   * symbol. You can get around this by manually editing the symbol when adding the token,
   * but it seems prudent to avoid the user having to do this.
   *
   * @param erc20Symbol_ The symbol of the ERC20
   * @return dripSymbol_ the symbol of our DRIP token
   */
  function _getDripSymbol(
    string memory erc20Symbol_
  ) internal pure returns (string memory dripSymbol_) {
    bytes memory erc20SymbolBytes = bytes(erc20Symbol_);

    if (erc20SymbolBytes.length < 6) {
      return string(abi.encodePacked(erc20SymbolBytes, "-DRIP"));
    } else {
      bytes memory result = new bytes(6);
      for (uint i = 0; i < 6; i++) {
        result[i] = erc20SymbolBytes[i];
      }
      return string(abi.encodePacked(result, "-DRIP"));
    }
  }

  /**
   * @dev {_processPoolParams}
   *
   * Validate and set pool parameters
   *
   * @param poolParams_ bytes parameter object that will be decoded into configuration items.
   */
  function _processPoolParams(bytes calldata poolParams_) internal {
    ERC20PoolParameters memory poolParams = _validatePoolParams(poolParams_);

    _setPoolParams(poolParams);
  }

  /**
   * @dev Decode and validate pool parameters
   *
   * @param poolParams_ Bytes parameters
   * @return poolParamsDecoded_ the decoded pool params
   */
  function _validatePoolParams(
    bytes calldata poolParams_
  ) internal pure returns (ERC20PoolParameters memory poolParamsDecoded_) {
    poolParamsDecoded_ = abi.decode(poolParams_, (ERC20PoolParameters));

    if (poolParamsDecoded_.poolPerAddressMaxETH > type(uint80).max) {
      _revert(ParamTooLargePerAddressMax.selector);
    }
    if (poolParamsDecoded_.poolMaxETH > type(uint96).max) {
      _revert(ParamTooLargePoolMaxETH.selector);
    }
    if (poolParamsDecoded_.poolPerTransactionMinETH > type(uint64).max) {
      _revert(ParamTooLargePoolPerTxnMinETH.selector);
    }
    if (poolParamsDecoded_.poolStartDate > type(uint32).max) {
      _revert(ParamTooLargeStartDate.selector);
    }
    if (poolParamsDecoded_.poolEndDate > type(uint32).max) {
      _revert(ParamTooLargeEndDate.selector);
    }
    if (poolParamsDecoded_.poolType > 1) {
      _revert(UnrecognisedType.selector);
    }
    if (poolParamsDecoded_.poolContributionFeeBasisPoints > type(uint16).max) {
      _revert(ParamTooLargeContributionFee.selector);
    }
    if (poolParamsDecoded_.poolVestingInSeconds > type(uint32).max) {
      _revert(ParamTooLargeVestingDays.selector);
    }
    if (poolParamsDecoded_.poolSupply > type(uint120).max) {
      _revert(ParamTooLargePoolSupply.selector);
    }
    if (poolParamsDecoded_.poolMinETH > type(uint96).max) {
      _revert(ParamTooLargeMinETH.selector);
    }
    if (poolParamsDecoded_.poolMaxInitialBuy > type(uint96).max) {
      _revert(ParamTooLargeMaxInitialBuy.selector);
    }
    if (poolParamsDecoded_.poolMaxInitialLiquidity > type(uint96).max) {
      _revert(ParamTooLargeMaxInitialLiquidity.selector);
    }
    if (
      poolParamsDecoded_.poolMaxInitialBuy != 0 &&
      poolParamsDecoded_.poolMinETH > poolParamsDecoded_.poolMaxInitialBuy
    ) {
      _revert(MinETHCannotExceedMaxBuy.selector);
    }
    if (
      poolParamsDecoded_.poolMaxInitialLiquidity != 0 &&
      poolParamsDecoded_.poolMinETH > poolParamsDecoded_.poolMaxInitialLiquidity
    ) {
      _revert(MinETHCannotExceedMaxLiquidity.selector);
    }
    return (poolParamsDecoded_);
  }

  /**
   * @dev {_setPoolParams}
   *
   * Load the pool params to storage
   *
   * @param poolParamsDecoded_ the decoded pool params
   */
  function _setPoolParams(
    ERC20PoolParameters memory poolParamsDecoded_
  ) internal {
    _driPoolType = DRIPoolType(poolParamsDecoded_.poolType);
    poolStartDate = uint32(poolParamsDecoded_.poolStartDate);
    poolEndDate = uint32(poolParamsDecoded_.poolEndDate);
    poolMaxETH = uint96(poolParamsDecoded_.poolMaxETH);
    poolMinETH = uint96(poolParamsDecoded_.poolMinETH);
    poolPerAddressMaxETH = uint80(poolParamsDecoded_.poolPerAddressMaxETH);
    poolVestingInSeconds = uint32(poolParamsDecoded_.poolVestingInSeconds);
    supplyInThePool = uint120(
      poolParamsDecoded_.poolSupply * (10 ** decimals())
    );
    poolPerTransactionMinETH = uint64(
      poolParamsDecoded_.poolPerTransactionMinETH
    );
    poolContributionFeeBasisPoints = uint16(
      poolParamsDecoded_.poolContributionFeeBasisPoints
    );
    maxInitialBuy = uint96(poolParamsDecoded_.poolMaxInitialBuy);
    maxInitialLiquidity = uint96(poolParamsDecoded_.poolMaxInitialLiquidity);
    poolContributionFeeBasisPoints = uint16(
      poolParamsDecoded_.poolContributionFeeBasisPoints
    );
    poolFeeRecipient = poolParamsDecoded_.poolFeeRecipient;
  }

  /**
   * @dev {supplyForLP}
   *
   * Convenience function to return the LP supply from the ERC-20 token contract.
   *
   * @return supplyForLP_ The total supply for LP creation.
   */
  function supplyForLP() public view returns (uint256 supplyForLP_) {
    return (createdERC20.balanceOf(address(createdERC20)));
  }

  /**
   * @dev {poolPhaseStatus}
   *
   * Convenience function to return the pool status in string format.
   *
   * @return poolPhaseStatus_ The pool phase status as a string
   */
  function poolPhaseStatus()
    external
    view
    returns (string memory poolPhaseStatus_)
  {
    // BEFORE the pool phase has started:
    if (_poolPhaseStatus() == PhaseStatus.before) {
      return ("before");
    }

    // AFTER the pool phase has ended successfully:
    if (_poolPhaseStatus() == PhaseStatus.succeeded) {
      return ("succeeded");
    }

    // AFTER the pool phase has ended but failed:
    if (_poolPhaseStatus() == PhaseStatus.failed) {
      return ("failed");
    }

    // DURING the pool phase:
    return ("open");
  }

  /**
   * @dev {_poolPhaseStatus}
   *
   * Internal function to return the pool phase status as an enum
   *
   * @return poolPhaseStatus_ The pool phase status as an enum
   */
  function _poolPhaseStatus()
    internal
    view
    returns (PhaseStatus poolPhaseStatus_)
  {
    // BEFORE the pool phase has started:
    if (block.timestamp < poolStartDate) {
      return (PhaseStatus.before);
    }

    // AFTER the pool phase has ended:
    if (block.timestamp >= poolEndDate) {
      if (poolIsAboveMinimum()) {
        // Successful:
        return (PhaseStatus.succeeded);
      } else {
        // Failed:
        return (PhaseStatus.failed);
      }
    }

    // DURING the pool phase:
    return (PhaseStatus.open);
  }

  /**
   * @dev {vestingEndDate}
   *
   * The vesting end date, being the end of the pool phase plus number of days vesting, if any.
   *
   * @return vestingEndDate_ The vesting end date as a timestamp
   */
  function vestingEndDate() public view returns (uint256 vestingEndDate_) {
    return poolEndDate + poolVestingInSeconds;
  }

  /**
   * @dev Return if the pool total has exceeded the minimum:
   *
   * @return poolIsAboveMinimum_ If the pool is above the minimum (or not)
   */
  function poolIsAboveMinimum() public view returns (bool poolIsAboveMinimum_) {
    return totalETHContributed() >= poolMinETH;
  }

  /**
   * @dev Return if the pool is at the maximum.
   *
   * @return poolIsAtMaximum_ If the pool is at the maximum ETH.
   */
  function poolIsAtMaximum() public view returns (bool poolIsAtMaximum_) {
    // A maximum of 0 signifies unlimited, therefore this can never be at the maximum:
    if (poolMaxETH == 0) {
      return false;
    }
    return totalETHContributed() == poolMaxETH;
  }

  /**
   * @dev Return the total ETH pooled (whether in the balance of this contract
   * or supplied as LP / token buy already).
   *
   * Note that this INCLUDES any seed ETH from the project on create.
   *
   * @return totalETHPooled_ the total ETH pooled in this contract
   */
  function totalETHPooled() public view returns (uint256 totalETHPooled_) {
    // This metric has an interesting characteristic where there can be negative ETH contributed:
    //  * The pool has failed
    //  * Fees have accumulated (but won't be paid)
    //  * All refunds have been made (or, at least, the vast majority have been made)
    //
    // We have a negative contributed amount because we deduct the fees still (we have to, in order
    // to see that the pool has failed). This then leaved the pooled amount lower than the deductions.
    //
    // We therefore have the concept that totalETHPooled must always be 0 or higher.
    uint256 positiveItems = address(this).balance +
      totalETHFundedToLPAndTokenBuy +
      totalExcessETHRefunded;

    if (positiveItems > accumulatedFees) {
      return positiveItems - accumulatedFees;
    } else {
      return (0);
    }
  }

  /**
   * @dev Return the total ETH contributed (whether in the balance of this contract
   * or supplied as LP already).
   *
   * Note that this EXCLUDES any seed ETH from the project on create.
   *
   * @return totalETHContributed_ the total ETH pooled in this contract
   */
  function totalETHContributed()
    public
    view
    returns (uint256 totalETHContributed_)
  {
    // This metric has an interesting characteristic where there can be negative ETH contributed:
    //  * The pool has failed
    //  * There is seed ETH provided
    //  * Fees have accumulated (but won't be paid)
    //  * All normal refunds have been made (or, at least, the vast majority have been made)
    //    leaving just the seed ETH (and maybe a small balance of normal refunds)
    //
    // We have a negative contributed amount because the deduct the fees still (we have to, in order
    // to see that the pool has failed). This then leaved the contribution amount lower than the seed
    // ETH amount.
    //
    // We therefore have the concept that totalETHContributed must always be 0 or higher.
    //
    if (projectSeedContributionETH < totalETHPooled()) {
      return totalETHPooled() - projectSeedContributionETH;
    } else {
      return (0);
    }
  }

  /**
   * @dev Return the total ETH pooled that is in excess of requirements
   *
   * @return totalExcessETHPooled_ the total ETH pooled in this contract
   * that is not needed for the initial lp / buy
   */
  function totalExcessETHPooled()
    public
    view
    returns (uint256 totalExcessETHPooled_)
  {
    if (_driPoolType == DRIPoolType.fundingLP) {
      if (maxInitialLiquidityExceeded()) {
        totalExcessETHPooled_ = totalETHContributed() - maxInitialLiquidity;
      } else {
        totalExcessETHPooled_ = 0;
      }
    } else {
      if (maxInitialBuyExceeded()) {
        totalExcessETHPooled_ = totalETHContributed() - maxInitialBuy;
      } else {
        totalExcessETHPooled_ = 0;
      }
    }

    return totalExcessETHPooled_;
  }

  /**
   * @dev Return the ETH pooled for this recipient
   *
   * @return participantETHPooled_ the total ETH pooled for this address
   */
  function participantETHPooled(
    address participant_
  ) public view returns (uint256 participantETHPooled_) {
    return participant[participant_].contribution;
  }

  /**
   * @dev Return the excess ETH already refunded for this recipient
   *
   * @return participantExcessETHRefunded_ the total excess ETH refunded for this participant
   */
  function participantExcessETHRefunded(
    address participant_
  ) public view returns (uint256 participantExcessETHRefunded_) {
    return participant[participant_].excessRefunded;
  }

  /**
   * @dev Return the excess refund currently owing for the query address
   *
   * Note that this EXCLUDES any seed ETH from the project on create.
   *
   * @return participantExcessRefund_ the total ETH pooled in this contract
   */
  function participantExcessRefundAvailable(
    address participant_
  ) public view returns (uint256 participantExcessRefund_) {
    if (totalETHContributed() == 0) {
      return 0;
    }
    return
      ((totalExcessETHPooled() * participant[participant_].contribution) /
        totalETHContributed()) - participant[participant_].excessRefunded;
  }

  /**
   * @dev Return if the max initial buy has been exceeded
   *
   * @return maxInitialBuyExceeded_
   */
  function maxInitialBuyExceeded()
    public
    view
    returns (bool maxInitialBuyExceeded_)
  {
    return maxInitialBuy != 0 && maxInitialBuy < totalETHContributed();
  }

  /**
   * @dev Return if the max initial lp funding has been exceeded
   *
   * @return maxInitialLiquidityExceeded_
   */
  function maxInitialLiquidityExceeded()
    public
    view
    returns (bool maxInitialLiquidityExceeded_)
  {
    return
      maxInitialLiquidity != 0 && maxInitialLiquidity < totalETHContributed();
  }

  /**
   * @dev {loadERC20AddressAndSeedETH}
   *
   * Load the target ERC-20 address. This is called by the factory in the same transaction as the clone
   * is instantiated
   *
   * @param createdERC20_ The ERC-20 address
   * @param poolCreator_ The creator of this pool
   */
  function loadERC20AddressAndSeedETH(
    address createdERC20_,
    address poolCreator_
  ) external payable {
    if (address(createdERC20) != address(0)) {
      _revert(AddressAlreadySet.selector);
    }

    // If there is ETH on this call then it is the ETH amount that the project team
    // is seeding into the pool. This seed amount does NOT mint DRIP token to the team,
    // as will be the case with any contributions to an open pool.
    //
    // IN A FUNDING LP POOL:
    //
    // It will be included in the ETH paired with the token when the pool closes,
    // if it closes above the minimum contribution threshold.
    //
    // In the event that the pool closes below the minimum contribution threshold the project
    // team will be able to claim a refund of the seeded amount, in just the same way
    // that contributors can get a refund of ETH when the pool closes below the minimum.
    //
    // IN AN INITIAL BUY POOL:
    //
    // When the pool closes this contract will fund the liquidity using the ETH that the team
    // has provided for liquicity and them IMMEDIATELY make the intitial purchase
    //
    // Tokens for users to claim are then held on this contract in the same way as for a liquidity pool

    // If this is an initial buy pool then we must have some seed ETH from the project as this is what
    // we will use to load liquidity. The ETH contributed to this contract is used as an initial buy.
    if (_driPoolType == DRIPoolType.initialBuy && msg.value == 0) {
      _revert(PoolMustBeSeededWithETHForInitialLiquidity.selector);
    }

    if (msg.value > 0) {
      if (msg.value > type(uint96).max) {
        _revert(ValueExceedsMaximum.selector);
      }
      projectSeedContributionETH = uint96(msg.value);
      projectSeedContributionAddress = poolCreator_;
    }
    createdERC20 = IERC20ByMetadrop(createdERC20_);
  }

  /**
   * @dev {addToPool}
   *
   * A user calls this to contribute to the pool
   *
   * Note that we could have used the receive method for this, and processed any ETH send to the
   * contract as a contribution to the pool. We've opted for the clarity of a specific method,
   * with the recieve method reverting an unidentified ETH.
   *
   * @param signedMessage_ The signed message object
   */
  function addToPool(
    SignedDropMessageDetails calldata signedMessage_
  ) external payable onlyDuringPoolPhase {
    _verifyMessage(signedMessage_);

    uint256 poolFee;

    // Deduct the pool fee if the fee is set:
    if (poolContributionFeeBasisPoints != 0) {
      // Fee is truncated to a given dp of ETH:
      poolFee =
        (((msg.value * poolContributionFeeBasisPoints) / CONST_BP_DENOM) /
          FEE_DP_OF_ETH_FACTOR) *
        FEE_DP_OF_ETH_FACTOR;
      accumulatedFees += uint96(poolFee);
    }

    _checkLimits(msg.value);

    // Mint DRIP to the participant:
    _mint(_msgSender(), msg.value * ETH_TO_DRIP_MULTIPLIER);

    // Record their ETH contribution:
    participant[_msgSender()].contribution += uint128(msg.value - poolFee);

    if (poolIsAtMaximum()) {
      poolEndDate = uint32(block.timestamp);
    }

    // Emit the event:
    emit AddToPool(_msgSender(), msg.value, poolFee);
  }

  /**
   * @dev function {_verifyMessage}
   *
   * Check the signature and expiry of the passed message
   *
   * @param signedMessage_ The signed message object
   */
  function _verifyMessage(
    SignedDropMessageDetails calldata signedMessage_
  ) internal view {
    // Check that this signature is from the oracle signer:
    if (
      !_validSignature(
        signedMessage_.messageHash,
        signedMessage_.messageSignature
      )
    ) {
      _revert(InvalidOracleSignature.selector);
    }

    // Check that the signature has not expired:
    unchecked {
      if (
        (signedMessage_.messageTimeStamp + MSG_VALIDITY_SECONDS) <
        block.timestamp
      ) {
        _revert(OracleSignatureHasExpired.selector);
      }
    }

    // Check that the message is from this sender and for this amount:
    if (
      createMessageHash(_msgSender(), msg.value) != signedMessage_.messageHash
    ) {
      _revert(PassedConfigDoesNotMatchApproved.selector);
    }
  }

  /**
   * @dev function {_validSignature}
   *
   * Checks the the signature on the signed message is from the metadrop oracle
   *
   * @param messageHash_ The message hash signed by the trusted oracle signer. This will be the
   * keccack256 hash of received data about this token.
   * @param messageSignature_ The signed message from the backend oracle signer for validation.
   * @return messageIsValid_ If the message is valid (or not)
   */
  function _validSignature(
    bytes32 messageHash_,
    bytes memory messageSignature_
  ) internal view returns (bool messageIsValid_) {
    bytes32 ethSignedMessageHash = keccak256(
      abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash_)
    );

    // Check the signature is valid:
    return (
      SignatureChecker.isValidSignatureNow(
        metadropOracleAddress,
        ethSignedMessageHash,
        messageSignature_
      )
    );
  }

  /**
   * @dev function {createMessageHash}
   *
   * Create the message hash
   *
   * @param sender_ The sender of the transcation
   * @param value_ The value of the transaction
   * @return messageHash_ The hash for the signed message
   */
  function createMessageHash(
    address sender_,
    uint256 value_
  ) public pure returns (bytes32 messageHash_) {
    return (keccak256(abi.encodePacked(sender_, value_)));
  }

  /**
   * @dev {_checkLimits}
   *
   * Check limits that apply to additions to the pool.
   *
   * @param ethValue_ The value of the ETH being contributed.
   */
  function _checkLimits(uint256 ethValue_) internal view {
    // Check the overall pool limit:
    if (poolMaxETH > 0 && (totalETHContributed() > poolMaxETH)) {
      _revert(AdditionToPoolWouldExceedPoolCap.selector);
    }

    // Check the per address limit:
    if (
      poolPerAddressMaxETH > 0 &&
      (balanceOf(_msgSender()) + (ethValue_ * ETH_TO_DRIP_MULTIPLIER) >
        (poolPerAddressMaxETH * ETH_TO_DRIP_MULTIPLIER))
    ) {
      _revert(AdditionToPoolWouldExceedPerAddressCap.selector);
    }

    // Check the contribution meets the minimium contribution size:
    if (ethValue_ < poolPerTransactionMinETH) {
      _revert(AdditionToPoolIsBelowPerTransactionMinimum.selector);
    }
  }

  /**
   * @dev {claimFromPool}
   *
   * A user calls this to burn their DRIP and claim their ERC-20 tokens
   *
   */
  function claimFromPool()
    external
    onlyAfterSuccessfulPoolPhase
    onlyWhenTokensVested
  {
    if (_driPoolType == DRIPoolType.initialBuy && supplyInThePool <= 0) {
      _revert(InitialLiquidityNotYetAdded.selector);
    }

    uint256 holdersDRIP = balanceOf(_msgSender());

    // Calculate the holders share of the pooled token:
    uint256 holdersClaim = ((supplyInThePool * holdersDRIP) / totalSupply());

    // If they are getting no tokens, there is nothing to do here:
    if (holdersClaim == 0) {
      _revert(NothingToClaim.selector);
    }

    // Burn the holders DRIP to the dead address. We do this so that the totalSupply()
    // figure remains constant allowing us to calculate subsequent shares of the total
    // ERC20 pool
    _burnToDead(_msgSender(), holdersDRIP);

    // Send them their createdERC20 token:
    createdERC20.safeTransfer(_msgSender(), holdersClaim);

    uint256 ethToRefundClaimer = _processExcessRefund(_msgSender());

    // Emit the event:
    emit ClaimFromPool(
      _msgSender(),
      holdersDRIP,
      holdersClaim,
      ethToRefundClaimer
    );
  }

  /**
   * @dev {refundExcess}
   *
   * Can be called at any time by a participant to claim and ETH refund of any
   * ETH that will not be used to either fund the pool or for an initial buy
   *
   */
  function refundExcess() external {
    uint256 ethToRefundClaimer = _processExcessRefund(_msgSender());

    if (ethToRefundClaimer == 0) {
      _revert(NothingToClaim.selector);
    }

    // Emit the event:
    emit ExcessRefunded(_msgSender(), ethToRefundClaimer);
  }

  /**
   * @dev {_processExcessRefund}
   *
   * Unified processing of excess refund
   *
   * @param participant_ The address being refunded.
   * @return ethToRefundParticipant_ The amount of ETH refunded.
   */
  function _processExcessRefund(
    address participant_
  ) internal returns (uint256 ethToRefundParticipant_) {
    if (totalExcessETHPooled() > 0) {
      ethToRefundParticipant_ = participantExcessRefundAvailable(participant_);

      if (ethToRefundParticipant_ > 0) {
        // Send them their ETH refund
        participant[participant_].excessRefunded += uint128(
          ethToRefundParticipant_
        );
        totalExcessETHRefunded += uint96(ethToRefundParticipant_);

        (bool success, ) = participant_.call{value: ethToRefundParticipant_}(
          ""
        );
        if (!success) {
          _revert(TransferFailed.selector);
        }
      }
      return (ethToRefundParticipant_);
    }
  }

  /**
   * @dev {_burnToDead}
   *
   * Burn DRIP token to the DEAD address.
   *
   * @param caller_ The address burning the token.
   * @param callersDRIP_ The amount of DRIP being burned.
   */
  function _burnToDead(address caller_, uint256 callersDRIP_) internal {
    _transfer(caller_, DEAD_ADDRESS, callersDRIP_);
  }

  /**
   * @dev {refundFromFailedPool}
   *
   * A user calls this to burn their DRIP and claim an ETH refund where the
   * minimum ETH pooled amount was not exceeded.
   *
   */
  function refundFromFailedPool() external onlyAfterFailedPoolPhase {
    // This looks for standard contributions based on balance of DRIP:
    uint256 holdersDRIP = balanceOf(_msgSender());

    // Calculate the holders share of the pooled ETH.
    uint256 refundAmount = holdersDRIP / ETH_TO_DRIP_MULTIPLIER;

    // Add on the project seed ETH amount if relevant:
    if (_msgSender() == projectSeedContributionAddress) {
      // This was a project seed contribution. We include the project seed ETH in any
      // refund to this address. We combine this with any refund they are owed
      // for a DRIP balance as it is possible (although unlikely) that the seed
      // contributor also made a standard contribution to the launch pool and minted
      // DRIP.

      // Add the seed ETH contribution to the refund amount:
      refundAmount += projectSeedContributionETH;

      // Zero out the contribution as this is being refunded:
      projectSeedContributionETH = 0;
    }

    // If they are getting no ETH, there is nothing to do here:
    if (refundAmount == 0) {
      _revert(NothingToClaim.selector);
    }

    // Burn tokens if the holder's DRIP is greater than 0. We need this check for zero
    // here as this could be a seed ETH refund:
    if (holdersDRIP > 0) {
      // Burn the holders DRIP to the dead address. We do this so that the totalSupply()
      // figure remains constant allowing us to calculate subsequent shares of the total
      // ERC20 pool
      _burnToDead(_msgSender(), holdersDRIP);
    }

    // Send them their ETH refund
    (bool success, ) = _msgSender().call{value: refundAmount}("");
    if (!success) {
      _revert(TransferFailed.selector);
    }

    // Emit the event:
    emit RefundFromFailedPool(_msgSender(), holdersDRIP, refundAmount);
  }

  /**
   * @dev {supplyLiquidity}
   *
   * When the pool phase is over this can be called to supply the pooled ETH to
   * the token contract. There it will be forwarded along with the LP supply of
   * tokens to uniswap to create the funded pair
   *
   * Note that this function can be called by anyone. While clearly it is likely
   * that this will be the project team, having this method open to anyone ensures that
   * liquidity will not be trapped in this contract if the team as unable to perform
   * this action.
   *
   * This method behaves differently depending on the pool type:
   *
   * IN A FUNDING LP POOL:
   *
   * All of the ETH held on this contract is provided to fund the LP
   *
   * IN AN INITIAL BUY POOL:
   *
   * ONLY the project supplied ETH is used to fund the liquidity. The remaining ETH
   * on this contract will fall into two possible categories:
   *
   * 1) ETH used to perform an initial token purchase immediately after the funding of
   * the LP. This will be the total remaining ETH on this contract IF that amount is
   * below the maximum initial buy amount. Otherwise it will be the max initial buy amount and the
   * remaining ETH will remain for refunds.
   *
   * 2) If the ETH on this contract is above the max initial buy amount there will be a
   * proportion of ETH remaining on this contract for refunds.
   *
   * @param lockerFee_ The ETH fee required to lock LP tokens
   *
   */
  function supplyLiquidity(
    uint256 lockerFee_
  ) external payable onlyAfterSuccessfulPoolPhase {
    // The caller can elect to send the locker fee with this call, or the locker
    // fee will automatically taken from the supplied ETH. In either scenario the only
    // acceptable values that can be passed to this method are a) 0 or b) the locker fee
    if (msg.value > 0 && msg.value != lockerFee_) {
      _revert(IncorrectPayment.selector);
    }

    uint256 ethForLiquidity;

    if (_driPoolType == DRIPoolType.fundingLP) {
      // If the locker fee was passed in it is in the balance of this contract, BUT is
      // not contributed ETH. Deduct this from the stored total:
      uint256 ethAvailableForLiquidity = totalETHPooled() - msg.value;
      if (
        maxInitialLiquidity != 0 &&
        maxInitialLiquidity < ethAvailableForLiquidity
      ) {
        ethForLiquidity = maxInitialLiquidity;
      } else {
        ethForLiquidity = ethAvailableForLiquidity;
      }
    } else {
      // For an initial buy pool this is the ETH that the project has contributed for the
      // liquidity pool setup
      ethForLiquidity = projectSeedContributionETH;
    }

    totalETHFundedToLPAndTokenBuy += uint96(ethForLiquidity);

    createdERC20.addInitialLiquidity{value: ethForLiquidity + msg.value}(
      lockerFee_,
      0,
      false
    );

    // If this is a initial buy pool we now perform the intial buy:
    if (_driPoolType == DRIPoolType.initialBuy) {
      uint256 ethAvailableForBuy = totalETHContributed();

      // We don't proceed with the initial buy if there is ZERO ETH in this pool.
      // In this instance we can't know the intention of the team, as they may
      // very well want to proceed with this token even if the pool has not
      // resulted in any pooled ETH. Note that we CANNOT reach this point in the code
      // if the team has specified a minimum ETH amount for the pool, i.e. we know that
      // the minimum ETH amount must have been ZERO to reach this position with zero
      // ETH in the pool. This is equivalent to saying that they token should proceed
      // to a funded state regardless of the performance of this pool. Therefore we
      // supply liquidity in this transation (earlier in the call stack), but do not
      // try and make an initial buy with 0 ETH as that would fail and revert.
      if (ethAvailableForBuy > 0) {
        uint256 ethForBuy;

        // If the total ETH in this contract exceeds the max initial buy, the buy we make
        // will be the max initial buy, with all excess ETH available to DRIP holders
        // as a refund on a pro-rata basis:
        if (maxInitialBuyExceeded()) {
          ethForBuy = maxInitialBuy;
        } else {
          ethForBuy = uint128(ethAvailableForBuy);
        }

        // Buy from DEX:
        address[] memory path = new address[](2);
        path[0] = address(uniswapRouter.WETH());
        path[1] = address(createdERC20);

        uniswapRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{
          value: ethForBuy
        }(0, path, address(this), block.timestamp + 600);

        // We need to update the var supplyInThePool to the balance held at this
        // contract:
        supplyInThePool = uint120(createdERC20.balanceOf(address(this)));

        // We also need to record the ETH used in the buy:
        totalETHFundedToLPAndTokenBuy += uint96(ethForBuy);

        // Emit the event:
        emit InitialBuyMade(ethForBuy);
      }
    }

    // Emit the total pooled and the accumulated fees:
    emit PoolClosedSuccessfully(totalETHPooled(), accumulatedFees);

    // Disburse fees (if any)
    if (accumulatedFees > 0) {
      uint256 feesToDisburse = accumulatedFees;
      accumulatedFees = 0;
      (bool success, ) = poolFeeRecipient.call{value: feesToDisburse}("");
      if (!success) {
        _revert(TransferFailed.selector);
      }
    }
  }

  /**
   * @dev function {rescueETH}
   *
   * A withdraw function to allow ETH to be rescued.
   *
   * Fallback safety method, only callable by the fee recipient.
   *
   * @param amount_ The amount to withdraw
   */
  function rescueETH(uint256 amount_) external onlyFeeRecipient {
    (bool success, ) = poolFeeRecipient.call{value: amount_}("");
    if (!success) {
      _revert(TransferFailed.selector);
    }
  }

  /**
   * @dev function {rescueERC20}
   *
   * A withdraw function to allow ERC20s to be rescued.
   *
   * Fallback safety method, only callable by the fee recipient.
   *
   * @param token_ The ERC20 contract
   * @param amount_ The amount to withdraw
   */
  function rescueERC20(
    address token_,
    uint256 amount_
  ) external onlyFeeRecipient {
    IERC20(token_).safeTransfer(poolFeeRecipient, amount_);
  }

  /**
   * @dev {receive}
   *
   * Revert any unidentified ETH
   *
   */
  receive() external payable {
    revert();
  }

  /**
   * @dev {fallback}
   *
   * No fallback allowed
   *
   */
  fallback() external payable {
    revert();
  }
}
// SPDX-License-Identifier: BUSL-1.1
// Metadrop Contracts (v2.1.0)

pragma solidity 0.8.21;

import {IConfigStructures} from "../../Global/IConfigStructures.sol";
import {IERC20ConfigByMetadrop} from "../ERC20/IERC20ConfigByMetadrop.sol";
import {IErrors} from "../../Global/IErrors.sol";

interface IERC20DRIPoolByMetadrop is
  IConfigStructures,
  IERC20ConfigByMetadrop,
  IErrors
{
  enum PhaseStatus {
    before,
    open,
    succeeded,
    failed
  }

  struct Participant {
    uint128 contribution;
    uint128 excessRefunded;
  }

  event DRIPoolCreatedAndInitialised();

  event AddToPool(address dripHolder, uint256 ethPooled, uint256 ethFee);

  event ClaimFromPool(
    address participant,
    uint256 dripTokenBurned,
    uint256 pooledTokenClaimed,
    uint256 ethRefunded
  );

  event ExcessRefunded(address participant, uint256 ethRefunded);

  event RefundFromFailedPool(
    address participant,
    uint256 dripTokenBurned,
    uint256 ethRefunded
  );

  event InitialBuyMade(uint256 ethBuy);

  event UnexpectedTotalETHPooled(
    uint256 totalETHPooled,
    uint256 contractBalance,
    uint256 totalETHFundedToLPAndTokenBuy,
    uint256 totalExcessETHRefunded,
    uint256 projectSeedContributionETH,
    uint256 accumulatedFees
  );

  event PoolClosedSuccessfully(uint256 totalETHPooled, uint256 totalETHFee);

  /**
   * @dev {driType}
   *
   * Returns the type of this DRI pool
   */
  function driType() external view returns (DRIPoolType);

  /**
   * @dev {initialiseDRIP}
   *
   * Initalise configuration on a new minimal proxy clone
   *
   * @param poolParams_ bytes parameter object that will be decoded into configuration items.
   * @param name_ the name of the associated ERC20 token
   * @param symbol_ the symbol of the associated ERC20 token
   */
  function initialiseDRIP(
    bytes calldata poolParams_,
    string calldata name_,
    string calldata symbol_
  ) external;

  /**
   * @dev {supplyForLP}
   *
   * Convenience function to return the LP supply from the ERC-20 token contract.
   *
   * @return supplyForLP_ The total supply for LP creation.
   */
  function supplyForLP() external view returns (uint256 supplyForLP_);

  /**
   * @dev {poolPhaseStatus}
   *
   * Convenience function to return the pool status in string format.
   *
   * @return poolPhaseStatus_ The pool phase status as a string
   */
  function poolPhaseStatus()
    external
    view
    returns (string memory poolPhaseStatus_);

  /**
   * @dev {vestingEndDate}
   *
   * The vesting end date, being the end of the pool phase plus number of days vesting, if any.
   *
   * @return vestingEndDate_ The vesting end date as a timestamp
   */
  function vestingEndDate() external view returns (uint256 vestingEndDate_);

  /**
   * @dev Return if the pool total has exceeded the minimum:
   *
   * @return poolIsAboveMinimum_ If the pool is above the minimum (or not)
   */
  function poolIsAboveMinimum()
    external
    view
    returns (bool poolIsAboveMinimum_);

  /**
   * @dev Return if the pool is at the maximum.
   *
   * @return poolIsAtMaximum_ If the pool is at the maximum ETH.
   */
  function poolIsAtMaximum() external view returns (bool poolIsAtMaximum_);

  /**
   * @dev Return the total ETH pooled (whether in the balance of this contract
   * or supplied as LP / token buy already).
   *
   * Note that this INCLUDES any seed ETH from the project on create.
   *
   * @return totalETHPooled_ the total ETH pooled in this contract
   */
  function totalETHPooled() external view returns (uint256 totalETHPooled_);

  /**
   * @dev Return the total ETH contributed (whether in the balance of this contract
   * or supplied as LP already).
   *
   * Note that this EXCLUDES any seed ETH from the project on create.
   *
   * @return totalETHContributed_ the total ETH pooled in this contract
   */
  function totalETHContributed()
    external
    view
    returns (uint256 totalETHContributed_);

  /**
   * @dev Return the total ETH pooled that is in excess of requirements
   *
   * @return totalExcessETHPooled_ the total ETH pooled in this contract
   * that is not needed for the initial lp / buy
   */
  function totalExcessETHPooled()
    external
    view
    returns (uint256 totalExcessETHPooled_);

  /**
   * @dev Return the ETH pooled for this recipient
   *
   * @return participantETHPooled_ the total ETH pooled for this address
   */
  function participantETHPooled(
    address participant_
  ) external view returns (uint256 participantETHPooled_);

  /**
   * @dev Return the excess ETH already refunded for this recipient
   *
   * @return participantExcessETHRefunded_ the total excess ETH refunded for this participant
   */
  function participantExcessETHRefunded(
    address participant_
  ) external view returns (uint256 participantExcessETHRefunded_);

  /**
   * @dev Return the excess refund currently owing for the query address
   *
   * Note that this EXCLUDES any seed ETH from the project on create.
   *
   * @return participantExcessRefund_ the total ETH pooled in this contract
   */
  function participantExcessRefundAvailable(
    address participant_
  ) external view returns (uint256 participantExcessRefund_);

  /**
   * @dev Return if the max initial buy has been exceeded
   *
   * @return maxInitialBuyExceeded_
   */
  function maxInitialBuyExceeded()
    external
    view
    returns (bool maxInitialBuyExceeded_);

  /**
   * @dev Return if the max initial lp funding has been exceeded
   *
   * @return maxInitialLiquidityExceeded_
   */
  function maxInitialLiquidityExceeded()
    external
    view
    returns (bool maxInitialLiquidityExceeded_);

  /**
   * @dev {loadERC20AddressAndSeedETH}
   *
   * Load the target ERC-20 address. This is called by the factory in the same transaction as the clone
   * is instantiated
   *
   * @param createdERC20_ The ERC-20 address
   * @param poolCreator_ The creator of this pool
   */
  function loadERC20AddressAndSeedETH(
    address createdERC20_,
    address poolCreator_
  ) external payable;

  /**
   * @dev {addToPool}
   *
   * A user calls this to contribute to the pool
   *
   * Note that we could have used the receive method for this, and processed any ETH send to the
   * contract as a contribution to the pool. We've opted for the clarity of a specific method,
   * with the recieve method reverting an unidentified ETH.
   *
   * @param signedMessage_ The signed message object
   */
  function addToPool(
    SignedDropMessageDetails calldata signedMessage_
  ) external payable;

  /**
   * @dev function {createMessageHash}
   *
   * Create the message hash
   *
   * @param sender_ The sender of the transcation
   * @param value_ The value of the transaction
   * @return messageHash_ The hash for the signed message
   */
  function createMessageHash(
    address sender_,
    uint256 value_
  ) external pure returns (bytes32 messageHash_);

  /**
   * @dev {claimFromPool}
   *
   * A user calls this to burn their DRIP and claim their ERC-20 tokens
   *
   */
  function claimFromPool() external;

  /**
   * @dev {refundExcess}
   *
   * Can be called at any time by a participant to claim and ETH refund of any
   * ETH that will not be used to either fund the pool or for an initial buy
   *
   */
  function refundExcess() external;

  /**
   * @dev {refundFromFailedPool}
   *
   * A user calls this to burn their DRIP and claim an ETH refund where the
   * minimum ETH pooled amount was not exceeded.
   *
   */
  function refundFromFailedPool() external;

  /**
   * @dev {supplyLiquidity}
   *
   * When the pool phase is over this can be called to supply the pooled ETH to
   * the token contract. There it will be forwarded along with the LP supply of
   * tokens to uniswap to create the funded pair
   *
   * Note that this function can be called by anyone. While clearly it is likely
   * that this will be the project team, having this method open to anyone ensures that
   * liquidity will not be trapped in this contract if the team as unable to perform
   * this action.
   *
   * This method behaves differently depending on the pool type:
   *
   * IN A FUNDING LP POOL:
   *
   * All of the ETH held on this contract is provided to fund the LP
   *
   * IN AN INITIAL BUY POOL:
   *
   * ONLY the project supplied ETH is used to fund the liquidity. The remaining ETH
   * on this contract will fall into two possible categories:
   *
   * 1) ETH used to perform an initial token purchase immediately after the funding of
   * the LP. This will be the total remaining ETH on this contract IF that amount is
   * below the maximum initial buy amount. Otherwise it will be the max initial buy amount and the
   * remaining ETH will remain for refunds.
   *
   * 2) If the ETH on this contract is above the max initial buy amount there will be a
   * proportion of ETH remaining on this contract for refunds.
   *
   * @param lockerFee_ The ETH fee required to lock LP tokens
   *
   */
  function supplyLiquidity(uint256 lockerFee_) external payable;

  /**
   * @dev function {rescueETH}
   *
   * A withdraw function to allow ETH to be rescued.
   *
   * Fallback safety method, only callable by the fee recipient.
   *
   * @param amount_ The amount to withdraw
   */
  function rescueETH(uint256 amount_) external;

  /**
   * @dev function {rescueERC20}
   *
   * A withdraw function to allow ERC20s to be rescued.
   *
   * Fallback safety method, only callable by the fee recipient.
   *
   * @param token_ The ERC20 contract
   * @param amount_ The amount to withdraw
   */
  function rescueERC20(address token_, uint256 amount_) external;
}
// SPDX-License-Identifier: MIT
// Metadrop Contracts (v2.1.0)

/**
 *
 * @title IConfigStructures.sol. Interface for common config structures used accross the platform
 *
 * @author metadrop https://metadrop.com/
 *
 */

pragma solidity 0.8.21;

interface IConfigStructures {
  enum DropStatus {
    approved,
    deployed,
    cancelled
  }

  enum TemplateStatus {
    live,
    terminated
  }

  // The current status of the mint:
  //   - notEnabled: This type of mint is not part of this drop
  //   - notYetOpen: This type of mint is part of the drop, but it hasn't started yet
  //   - open: it's ready for ya, get in there.
  //   - finished: been and gone.
  //   - unknown: theoretically impossible.
  enum MintStatus {
    notEnabled,
    notYetOpen,
    open,
    finished,
    unknown
  }

  struct SubListConfig {
    uint256 start;
    uint256 end;
    uint256 phaseMaxSupply;
  }

  struct PrimarySaleModuleInstance {
    address instanceAddress;
    string instanceDescription;
  }

  struct NFTModuleConfig {
    uint256 templateId;
    bytes configData;
    bytes vestingData;
  }

  struct PrimarySaleModuleConfig {
    uint256 templateId;
    bytes configData;
  }

  struct ProjectBeneficiary {
    address payable payeeAddress;
    uint256 payeeShares;
  }

  struct VestingConfig {
    uint256 start;
    uint256 projectUpFrontShare;
    uint256 projectVestedShare;
    uint256 vestingPeriodInDays;
    uint256 vestingCliff;
    ProjectBeneficiary[] projectPayees;
  }

  struct RoyaltySplitterModuleConfig {
    uint256 templateId;
    bytes configData;
  }

  struct InLifeModuleConfig {
    uint256 templateId;
    bytes configData;
  }

  struct InLifeModules {
    InLifeModuleConfig[] modules;
  }

  struct NFTConfig {
    uint256 supply;
    string name;
    string symbol;
    bytes32 positionProof;
    bool includePriorPhasesInMintTracking;
    bool singleMetadataCollection;
    uint256 reservedAllocation;
    uint256 assistanceRequestWindowInSeconds;
  }

  struct Template {
    TemplateStatus status;
    uint16 templateNumber;
    uint32 loadedDate;
    address payable templateAddress;
    string templateDescription;
  }

  struct RoyaltyDetails {
    address newRoyaltyPaymentSplitterInstance;
    uint96 royaltyFromSalesInBasisPoints;
  }

  struct SignedDropMessageDetails {
    uint256 messageTimeStamp;
    bytes32 messageHash;
    bytes messageSignature;
  }
}
// SPDX-License-Identifier: MIT
// Metadrop Contracts (v2.1.0)

/**
 *
 * @title IErrors.sol. Interface for error definitions used across the platform
 *
 * @author metadrop https://metadrop.com/
 *
 */

pragma solidity 0.8.21;

interface IErrors {
  enum BondingCurveErrorType {
    OK, //                                                  No error
    INVALID_NUMITEMS, //                                    The numItem value is 0
    SPOT_PRICE_OVERFLOW //                                  The updated spot price doesn't fit into 128 bits
  }

  error AdapterParamsMustBeEmpty(); //                      The adapter parameters on this LZ call must be empty.

  error AdditionToPoolIsBelowPerTransactionMinimum(); //    The contribution amount is less than the minimum.

  error AdditionToPoolWouldExceedPoolCap(); //              This addition to the pool would exceed the pool cap.

  error AdditionToPoolWouldExceedPerAddressCap(); //        This addition to the pool would exceed the per address cap.

  error AddressAlreadySet(); //                             The address being set can only be set once, and is already non-0.

  error AllowanceDecreasedBelowZero(); //                   You cannot decrease the allowance below zero.

  error AlreadyInitialised(); //                            The contract is already initialised: it cannot be initialised twice!

  error AmountExceedsAvailable(); //                        You are requesting more token than is available.

  error ApprovalCallerNotOwnerNorApproved(); //             The caller must own the token or be an approved operator.

  error ApproveFromTheZeroAddress(); //                     Approval cannot be called from the zero address (indeed, how have you??).

  error ApproveToTheZeroAddress(); //                       Approval cannot be given to the zero address.

  error ApprovalQueryForNonexistentToken(); //              The token does not exist.

  error AuctionStatusIsNotEnded(); //                       Throw if the action required the auction to be closed, and it isn't.

  error AuctionStatusIsNotOpen(); //                        Throw if the action requires the auction to be open, and it isn't.

  error AuxCallFailed(
    address[] modules,
    uint256 value,
    bytes data,
    uint256 txGas
  ); //                                                     An auxilliary call from the drop factory failed.

  error BalanceMismatch(); //                               An error when comparing balance amounts.

  error BalanceQueryForZeroAddress(); //                    Cannot query the balance for the zero address.

  error BidMustBeBelowTheFloorWhenReducingQuantity(); //    Only bids that are below the floor can reduce the quantity of the bid.

  error BidMustBeBelowTheFloorForRefundDuringAuction(); //  Only bids that are below the floor can be refunded during the auction.

  error BondingCurveError(BondingCurveErrorType error); //  An error of the type specified has occured in bonding curve processing.

  error botProtectionDurationInSecondsMustFitUint128(); //  botProtectionDurationInSeconds cannot be too large.

  error BurnExceedsBalance(); //                            The amount you have selected to burn exceeds the addresses balance.

  error BurnFromTheZeroAddress(); //                        Tokens cannot be burned from the zero address. (Also, how have you called this!?!)

  error CallerIsNotDepositBoxOwner(); //                    The caller is not the owner of the deposit box.

  error CallerIsNotFactory(); //                            The caller of this function must match the factory address in storage.

  error CallerIsNotFactoryOrProjectOwner(); //              The caller of this function must match the factory address OR project owner address.

  error CallerIsNotFactoryProjectOwnerOrPool(); //          The caller of this function must match the factory address, project owner or pool address.

  error CallerIsNotTheFeeRecipient(); //                    The caller is not the fee recipient.

  error CallerIsNotTheOwner(); //                           The caller is not the owner of this contract.

  error CallerIsNotTheManager(); //                         The caller is not the manager of this contract.

  error CallerMustBeLzApp(); //                             The caller must be an LZ application.

  error CallerIsNotPlatformAdmin(address caller); //        The caller of this function must be part of the platformAdmin group.

  error CallerIsNotSuperAdmin(address caller); //           The caller of this function must match the superAdmin address in storage.

  error CannotAddLiquidityOnCreateAndUseDRIPool(); //       Cannot use both liquidity added on create and a DRIPool in the same token.

  error CannotManuallyFundLPWhenUsingADRIPool(); //         Cannot add liquidity manually when using a DRI pool.

  error CannotPerformDuringAutoswap(); //                   Cannot call this function during an autoswap.

  error CannotSetNewOwnerToTheZeroAddress(); //             You can't set the owner of this contract to the zero address (address(0)).

  error CannotSetToZeroAddress(); //                        The corresponding address cannot be set to the zero address (address(0)).

  error CannotSetNewManagerToTheZeroAddress(); //           Cannot transfer the manager to the zero address (address(0)).

  error CannotWithdrawThisToken(); //                       Cannot withdraw the specified token.

  error CanOnlyReduce(); //                                 The given operation can only reduce the value specified.

  error CollectionAlreadyRevealed(); //                     The collection is already revealed; you cannot call reveal again.

  error ContractIsDecommissioned(); //                      This contract is decommissioned!

  error ContractIsPaused(); //                              The call requires the contract to be unpaused, and it is paused.

  error ContractIsNotPaused(); //                           The call required the contract to be paused, and it is NOT paused.

  error DecreasedAllowanceBelowZero(); //                   The request would decrease the allowance below zero, and that is not allowed.

  error DestinationIsNotTrustedSource(); //                 The destination that is being called through LZ has not been set as trusted.

  error DeductionsOnBuyExceedOrEqualOneHundredPercent(); // The total of all buy deductions cannot equal or exceed 100%.

  error DeployerOnly(); //                                  This method can only be called by the deployer address.

  error DeploymentError(); //                               Error on deployment.

  error DepositBoxIsNotOpen(); //                           This action cannot complete as the deposit box is not open.

  error DriPoolAddressCannotBeAddressZero(); //             The Dri Pool address cannot be the zero address.

  error GasLimitIsTooLow(); //                              The gas limit for the LayerZero call is too low.

  error IncorrectConfirmationValue(); //                    You need to enter the right confirmation value to call this funtion (usually 69420).

  error IncorrectPayment(); //                              The function call did not include passing the correct payment.

  error InitialLiquidityAlreadyAdded(); //                  Initial liquidity has already been added. You can't do it again.

  error InitialLiquidityNotYetAdded(); //                   Initial liquidity needs to have been added for this to succedd.

  error InsufficientAllowance(); //                         There is not a high enough allowance for this operation.

  error InvalidAdapterParams(); //                          The current adapter params for LayerZero on this contract won't work :(.

  error InvalidAddress(); //                                An address being processed in the function is not valid.

  error InvalidEndpointCaller(); //                         The calling address is not a valid LZ endpoint. The LZ endpoint was set at contract creation
  //                                                        and cannot be altered after. Check the address LZ endpoint address on the contract.

  error InvalidHash(); //                                   The passed hash does not meet requirements.

  error InvalidMinGas(); //                                 The minimum gas setting for LZ in invalid.

  error InvalidOracleSignature(); //                        The signature provided with the contract call is not valid, either in format or signer.

  error InvalidPayload(); //                                The LZ payload is invalid

  error InvalidReceiver(); //                               The address used as a target for funds is not valid.

  error InvalidSourceSendingContract(); //                  The LZ message is being related from a source contract on another chain that is NOT trusted.

  error InvalidTotalShares(); //                            Total shares must equal 100 percent in basis points.

  error LimitsCanOnlyBeRaised(); //                         Limits are UP ONLY.

  error LimitTooHigh(); //                                  The limit has been set too high.

  error ListLengthMismatch(); //                            Two or more lists were compared and they did not match length.

  error LiquidityPoolMustBeAContractAddress(); //           Cannot add a non-contract as a liquidity pool.

  error LiquidityPoolCannotBeAddressZero(); //              Cannot add a liquidity pool from the zero address.

  error LPLockUpMustFitUint88(); //                         LP lockup is held in a uint88, so must fit.

  error NoTrustedPathRecord(); //                           LZ needs a trusted path record for this to work. What's that, you ask?

  error MachineAddressCannotBeAddressZero(); //             Cannot set the machine address to the zero address.

  error ManagerUnauthorizedAccount(); //                    The caller is not the pending manager.

  error MaxBidQuantityIs255(); //                           Validation: as we use a uint8 array to track bid positions the max bid quantity is 255.

  error MaxBuysPerBlockExceeded(); //                       You have exceeded the max buys per block.

  error MaxPublicMintAllowanceExceeded(
    uint256 requested,
    uint256 alreadyMinted,
    uint256 maxAllowance
  ); //                                                     The calling address has requested a quantity that would exceed the max allowance.

  error MaxSupplyTooHigh(); //                              Max supply must fit in a uint128.

  error MaxTokensPerWalletExceeded(); //                    The transfer would exceed the max tokens per wallet limit.

  error MaxTokensPerTxnExceeded(); //                       The transfer would exceed the max tokens per transaction limit.

  error MetadataIsLocked(); //                              The metadata on this contract is locked; it cannot be altered!

  error MetadropFactoryOnlyOncePerReveal(); //              This function can only be called (a) by the factory and, (b) just one time!

  error MetadropModulesOnly(); //                           Can only be called from a metadrop contract.

  error MetadropOracleCannotBeAddressZero(); //             The metadrop Oracle cannot be the zero address (address(0)).

  error MinETHCannotExceedMaxBuy(); //                      The min ETH amount cannot exceed the max buy amount.

  error MinETHCannotExceedMaxLiquidity(); //                The min ETH amount cannot exceed the max liquidity amount.

  error MinGasLimitNotSet(); //                             The minimum gas limit for LayerZero has not been set.

  error MintERC2309QuantityExceedsLimit(); //               The `quantity` minted with ERC2309 exceeds the safety limit.

  error MintingIsClosedForever(); //                        Minting is, as the error suggests, so over (and locked forever).

  error MintToZeroAddress(); //                             Cannot mint to the zero address.

  error MintZeroQuantity(); //                              The quantity of tokens minted must be more than zero.

  error NewBuyTaxBasisPointsExceedsMaximum(); //            Project owner trying to set the tax rate too high.

  error NewSellTaxBasisPointsExceedsMaximum(); //           Project owner trying to set the tax rate too high.

  error NoETHForLiquidityPair(); //                         No ETH has been provided for the liquidity pair.

  error TaxPeriodStillInForce(); //                         The minimum tax period has not yet expired.

  error NoPaymentDue(); //                                  No payment is due for this address.

  error NoRefundForCaller(); //                             Error thrown when the calling address has no refund owed.

  error NoStoredMessage(); //                               There is no stored message matching the passed parameters.

  error NothingToClaim(); //                                The calling address has nothing to claim.

  error NoTokenForLiquidityPair(); //                       There is no token to add to the LP.

  error OperationDidNotSucceed(); //                        The operation failed (vague much?).

  error OracleSignatureHasExpired(); //                     A signature has been provided but it is too old.

  error OwnableUnauthorizedAccount(); //                    The caller is not the pending owner.

  error OwnershipNotInitializedForExtraData(); //           The `extraData` cannot be set on an uninitialized ownership slot.

  error OwnerQueryForNonexistentToken(); //                 The token does not exist.

  error ParametersDoNotMatchSignedMessage(); //             The parameters passed with the signed message do not match the message itself.

  error ParamTooLargeStartDate(); //                        The passed parameter exceeds the var type max.

  error ParamTooLargeEndDate(); //                          The passed parameter exceeds the var type max.

  error ParamTooLargeMinETH(); //                           The passed parameter exceeds the var type max.

  error ParamTooLargePerAddressMax(); //                    The passed parameter exceeds the var type max.

  error ParamTooLargeVestingDays(); //                      The passed parameter exceeds the var type max.

  error ParamTooLargePoolSupply(); //                       The passed parameter exceeds the var type max.

  error ParamTooLargePoolMaxETH(); //                       The passed parameter exceeds the var type max.

  error ParamTooLargePoolPerTxnMinETH(); //                 The passed parameter exceeds the var type max.

  error ParamTooLargeContributionFee(); //                  The passed parameter exceeds the var type max.

  error ParamTooLargeMaxInitialBuy(); //                    The passed parameter exceeds the var type max.

  error ParamTooLargeMaxInitialLiquidity(); //              The passed parameter exceeds the var type max.

  error PassedConfigDoesNotMatchApproved(); //              The config provided on the call does not match the approved config.

  error PauseCutOffHasPassed(); //                          The time period in which we can pause has passed; this contract can no longer be paused.

  error PaymentMustCoverPerMintFee(); //                    The payment passed must at least cover the per mint fee for the quantity requested.

  error PermitDidNotSucceed(); //                           The safeERC20 permit failed.

  error PlatformAdminCannotBeAddressZero(); //              We cannot use the zero address (address(0)) as a platformAdmin.

  error PlatformTreasuryCannotBeAddressZero(); //           The treasury address cannot be set to the zero address.

  error PoolIsAboveMinimum(); //                            You required the pool to be below the minimum, and it is not

  error PoolIsBelowMinimum(); //                            You required the pool to be above the minimum, and it is not

  error PoolMustBeSeededWithETHForInitialLiquidity(); //    You must pass ETH for liquidity with this type of pool.

  error PoolPhaseIsNotOpen(); //                            The block.timestamp is either before the pool is open or after it is closed.

  error PoolPhaseIsNotFailed(); //                          The pool status must be failed.

  error PoolPhaseIsNotSucceeded(); //                       The pool status must be succeeded.

  error PoolVestingNotYetComplete(); //                     Tokens in the pool are not yet vested.

  error ProjectOwnerCannotBeAddressZero(); //               The project owner has to be a non zero address.

  error ProofInvalid(); //                                  The provided proof is not valid with the provided arguments.

  error QuantityExceedsRemainingCollectionSupply(); //      The requested quantity would breach the collection supply.

  error QuantityExceedsRemainingPhaseSupply(); //           The requested quantity would breach the phase supply.

  error QuantityExceedsMaxPossibleCollectionSupply(); //    The requested quantity would breach the maximum trackable supply

  error ReferralIdAlreadyUsed(); //                         This referral ID has already been used; they are one use only.

  error RequestingMoreThanAvailableBalance(); //             The request exceeds the available balance.

  error RequestingMoreThanRemainingAllocation(
    uint256 previouslyMinted,
    uint256 requested,
    uint256 remainingAllocation
  ); //                                                     Number of tokens requested for this mint exceeds the remaining allocation (taking the
  //                                                        original allocation from the list and deducting minted tokens).

  error RouterCannotBeZeroAddress(); //                     The router address cannot be Zero.

  error RoyaltyFeeWillExceedSalePrice(); //                 The ERC2981 royalty specified will exceed the sale price.

  error ShareTotalCannotBeZero(); //                        The total of all the shares cannot be nothing.

  error SliceOutOfBounds(); //                              The bytes slice operation was out of bounds.

  error SliceOverflow(); //                                 The bytes slice operation overlowed.

  error SuperAdminCannotBeAddressZero(); //                 The superAdmin cannot be the sero address (address(0)).

  error SupplyTotalMismatch(); //                           The sum of the team supply and lp supply does not match.

  error SupportWindowIsNotOpen(); //                        The project owner has not requested support within the support request expiry window.

  error SwapThresholdTooLow(); // The select swap threshold is below the minimum.

  error TaxFreeAddressCannotBeAddressZero(); //             A tax free address cannot be address(0)

  error TemplateCannotBeAddressZero(); //                   The address for a template cannot be address zero (address(0)).

  error TemplateNotFound(); //                              There is no template that matches the passed template Id.

  error ThisMintIsClosed(); //                              It's over (well, this mint is, anyway).

  error TotalSharesMustMatchDenominator(); //               The total of all shares must equal the denominator value.

  error TransferAmountExceedsBalance(); //                  The transfer amount exceeds the accounts available balance.

  error TransferCallerNotOwnerNorApproved(); //             The caller must own the token or be an approved operator.

  error TransferFailed(); //                                The transfer has failed.

  error TransferFromIncorrectOwner(); //                    The token must be owned by `from`.

  error TransferToNonERC721ReceiverImplementer(); //        Cannot safely transfer to a contract that does not implement the ERC721Receiver interface.

  error TransferFromZeroAddress(); //                       Cannot transfer from the zero address. Indeed, this surely is impossible, and likely a waste to check??

  error TransferToZeroAddress(); //                         Cannot transfer to the zero address.

  error UnrecognisedVRFMode(); //                           Currently supported VRF modes are 0: chainlink and 1: arrng

  error UnrecognisedType(); //                              Pool type not found.

  error URIQueryForNonexistentToken(); //                   The token does not exist.

  error ValueExceedsMaximum(); //                           The value sent exceeds the maximum allowed (super useful explanation huh?).

  error VRFCoordinatorCannotBeAddressZero(); //             The VRF coordinator cannot be the zero address (address(0)).
}
// SPDX-License-Identifier: MIT
// Metadrop Contracts (v2.1.0)
// Metadrop based on OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity 0.8.21;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {IErrors} from "../IErrors.sol";

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
    _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
  }

  /**
   * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
   * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
   */
  function safeTransferFrom(
    IERC20 token,
    address from,
    address to,
    uint256 value
  ) internal {
    _callOptionalReturn(
      token,
      abi.encodeCall(token.transferFrom, (from, to, value))
    );
  }

  /**
   * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
   * non-reverting calls are assumed to be successful.
   */
  function safeIncreaseAllowance(
    IERC20 token,
    address spender,
    uint256 value
  ) internal {
    uint256 oldAllowance = token.allowance(address(this), spender);
    forceApprove(token, spender, oldAllowance + value);
  }

  /**
   * @dev Decrease the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
   * non-reverting calls are assumed to be successful.
   */
  function safeDecreaseAllowance(
    IERC20 token,
    address spender,
    uint256 value
  ) internal {
    unchecked {
      uint256 oldAllowance = token.allowance(address(this), spender);
      if (oldAllowance < value) {
        revert IErrors.DecreasedAllowanceBelowZero();
      }
      forceApprove(token, spender, oldAllowance - value);
    }
  }

  /**
   * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
   * non-reverting calls are assumed to be successful. Compatible with tokens that require the approval to be set to
   * 0 before setting it to a non-zero value.
   */
  function forceApprove(IERC20 token, address spender, uint256 value) internal {
    bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));

    if (!_callOptionalReturnBool(token, approvalCall)) {
      _callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));
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
    if (nonceAfter != (nonceBefore + 1)) {
      revert IErrors.PermitDidNotSucceed();
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

    bytes memory returndata = address(token).functionCall(data, "call fail");
    if ((returndata.length != 0) && !abi.decode(returndata, (bool))) {
      revert IErrors.OperationDidNotSucceed();
    }
  }

  /**
   * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
   * on the return value: the return value is optional (but if data is returned, it must not be false).
   * @param token The token targeted by the call.
   * @param data The call data (encoded using abi.encode or one of its variants).
   *
   * This is a variant of {_callOptionalReturn} that silents catches all reverts and returns a bool instead.
   */
  function _callOptionalReturnBool(
    IERC20 token,
    bytes memory data
  ) private returns (bool) {
    // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
    // we're implementing it ourselves. We cannot use {Address-functionCall} here since this should return false
    // and not revert is the subcall reverts.

    (bool success, bytes memory returndata) = address(token).call(data);
    return
      success &&
      (returndata.length == 0 || abi.decode(returndata, (bool))) &&
      address(token).code.length > 0;
  }
}
// SPDX-License-Identifier: MIT
// Metadrop Contracts (v2.1.0)

/**
 *
 * @title Revert.sol. For efficient reverts
 *
 * @author metadrop https://metadrop.com/
 *
 */

pragma solidity 0.8.21;

abstract contract Revert {
  /**
   * @dev For more efficient reverts.
   */
  function _revert(bytes4 errorSelector) internal pure {
    assembly {
      mstore(0x00, errorSelector)
      revert(0x00, 0x04)
    }
  }
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
  function factory() external pure returns (address);

  function WETH() external pure returns (address);

  function addLiquidity(
    address tokenA,
    address tokenB,
    uint amountADesired,
    uint amountBDesired,
    uint amountAMin,
    uint amountBMin,
    address to,
    uint deadline
  ) external returns (uint amountA, uint amountB, uint liquidity);

  function addLiquidityETH(
    address token,
    uint amountTokenDesired,
    uint amountTokenMin,
    uint amountETHMin,
    address to,
    uint deadline
  ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

  function removeLiquidity(
    address tokenA,
    address tokenB,
    uint liquidity,
    uint amountAMin,
    uint amountBMin,
    address to,
    uint deadline
  ) external returns (uint amountA, uint amountB);

  function removeLiquidityETH(
    address token,
    uint liquidity,
    uint amountTokenMin,
    uint amountETHMin,
    address to,
    uint deadline
  ) external returns (uint amountToken, uint amountETH);

  function removeLiquidityWithPermit(
    address tokenA,
    address tokenB,
    uint liquidity,
    uint amountAMin,
    uint amountBMin,
    address to,
    uint deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint amountA, uint amountB);

  function removeLiquidityETHWithPermit(
    address token,
    uint liquidity,
    uint amountTokenMin,
    uint amountETHMin,
    address to,
    uint deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint amountToken, uint amountETH);

  function swapExactTokensForTokens(
    uint amountIn,
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
  ) external returns (uint[] memory amounts);

  function swapTokensForExactTokens(
    uint amountOut,
    uint amountInMax,
    address[] calldata path,
    address to,
    uint deadline
  ) external returns (uint[] memory amounts);

  function swapExactETHForTokens(
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
  ) external payable returns (uint[] memory amounts);

  function swapTokensForExactETH(
    uint amountOut,
    uint amountInMax,
    address[] calldata path,
    address to,
    uint deadline
  ) external returns (uint[] memory amounts);

  function swapExactTokensForETH(
    uint amountIn,
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
  ) external returns (uint[] memory amounts);

  function swapETHForExactTokens(
    uint amountOut,
    address[] calldata path,
    address to,
    uint deadline
  ) external payable returns (uint[] memory amounts);

  function quote(
    uint amountA,
    uint reserveA,
    uint reserveB
  ) external pure returns (uint amountB);

  function getAmountOut(
    uint amountIn,
    uint reserveIn,
    uint reserveOut
  ) external pure returns (uint amountOut);

  function getAmountIn(
    uint amountOut,
    uint reserveIn,
    uint reserveOut
  ) external pure returns (uint amountIn);

  function getAmountsOut(
    uint amountIn,
    address[] calldata path
  ) external view returns (uint[] memory amounts);

  function getAmountsIn(
    uint amountOut,
    address[] calldata path
  ) external view returns (uint[] memory amounts);
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.6.2;

import "./IUniswapV2Router01.sol";

interface IUniswapV2Router02 is IUniswapV2Router01 {
  function removeLiquidityETHSupportingFeeOnTransferTokens(
    address token,
    uint liquidity,
    uint amountTokenMin,
    uint amountETHMin,
    address to,
    uint deadline
  ) external returns (uint amountETH);

  function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
    address token,
    uint liquidity,
    uint amountTokenMin,
    uint amountETHMin,
    address to,
    uint deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint amountETH);

  function swapExactTokensForTokensSupportingFeeOnTransferTokens(
    uint amountIn,
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
  ) external;

  function swapExactETHForTokensSupportingFeeOnTransferTokens(
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
  ) external payable;

  function swapExactTokensForETHSupportingFeeOnTransferTokens(
    uint amountIn,
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
  ) external;
}