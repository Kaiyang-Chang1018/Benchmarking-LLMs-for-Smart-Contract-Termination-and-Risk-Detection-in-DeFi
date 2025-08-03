// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
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
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

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
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
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
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
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
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
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
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
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
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
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
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
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
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

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
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

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
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

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
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
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
// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}


contract Kabosu2 is ERC20, Ownable {
    // Info? are you sure?
    uint256 private ReflactionaryTotal;

    // Routing to nowhere
    IUniswapV2Router02 public UniswapV2Router;

    // Important addresses
    address payable private DevAddress =
    payable(0x3D6EFB8C3B880397D412316104527471081AB8a8);
    address payable private MarketingAddress =
    payable(0x6B20eA0228f5e810a9210774bEa6c7576E26FFC1);

    uint256 public HardCap;
    uint256 public HardCapBuy;
    uint256 public HardCapSell;

    uint256 private LiquidityThreshold;

    mapping(address => uint256) private BalancesRefraccionarios;
    mapping(address => uint256) private BalancesReales;
    mapping(address => bool) public Bots;

    mapping(address => bool) public WalletsExcludedFromFee;
    mapping(address => bool) public WalletsExcludedFromHardCap;
    mapping(address => bool) public AutomatedMarketMakerPairs;

    uint256 public TotalFee;
    uint256 public TotalSwapped;
    uint256 public TotalTokenBurn;

    bool private AreWeLive = false;

    bool private InSwap = false;
    bool private SwapEnabled = true;
    bool private AutoLiquidity = true;

    // Tax rates
    struct TaxRates {
        uint256 BurnTax;
        uint256 LiquidityTax;
        uint256 MarketingTax;
        uint256 DevelopmentTax;
        uint256 RewardTax;
    }

    // Fees, which are amounts calculated based on tax
    struct TransactionFees {
        uint256 TransactionFee;
        uint256 BurnFee;
        uint256 DevFee;
        uint256 MarketingFee;
        uint256 LiquidityFee;
        uint256 TransferrableFee;
        uint256 TotalFee;
    }

    TaxRates public BuyingTaxes =
    TaxRates({
        RewardTax: 0,
        BurnTax: 0,
        DevelopmentTax: 0,
        MarketingTax: 9,
        LiquidityTax: 1
    });

    TaxRates public SellTaxes =
    TaxRates({
        RewardTax: 0,
        BurnTax: 0,
        DevelopmentTax: 0,
        MarketingTax: 28,
        LiquidityTax: 2
    });

    TaxRates public AppliedRatesPercentage = BuyingTaxes;

    TransactionFees private AccumulatedFeeForDistribution =
    TransactionFees({
        DevFee: 0,
        MarketingFee: 0,
        LiquidityFee: 0,
        BurnFee: 0,
        TransferrableFee: 0,
        TotalFee: 0,
        TransactionFee: 0
    });

    // Events
    event setDevAddress(address indexed previous, address indexed adr);
    event setMktAddress(address indexed previous, address indexed adr);
    event LiquidityAdded(uint256 tokenAmount, uint256 ETHAmount);
    event TreasuryAndDevFeesAdded(uint256 devFee, uint256 treasuryFee);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event BlacklistedUser(address botAddress, bool indexed value);
    event MaxWalletAmountUpdated(uint256 amount);
    event ExcludeFromMaxWallet(address account, bool indexed isExcluded);
    event SwapAndLiquifyEnabledUpdated(bool _enabled);

    constructor(
        address swap,
        string memory name,
        string memory symbol
    ) ERC20(name, symbol) {
        UniswapV2Router = IUniswapV2Router02(swap);

        address PancakeSwapAddress = IUniswapV2Factory(
            UniswapV2Router.factory()
        ).createPair(address(this), UniswapV2Router.WETH());

        AutomatedMarketMakerPairs[PancakeSwapAddress] = true;

        WalletsExcludedFromFee[address(this)] = true;
        WalletsExcludedFromFee[DevAddress] = true;
        WalletsExcludedFromFee[MarketingAddress] = true;
        WalletsExcludedFromFee[swap] = true;
        WalletsExcludedFromFee[msg.sender] = true;
        WalletsExcludedFromFee[
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        ] = true;

        WalletsExcludedFromHardCap[address(this)] = true;
        WalletsExcludedFromHardCap[DevAddress] = true;
        WalletsExcludedFromHardCap[MarketingAddress] = true;
        WalletsExcludedFromHardCap[PancakeSwapAddress] = true;
        WalletsExcludedFromHardCap[swap] = true;
        WalletsExcludedFromHardCap[
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        ] = true;
        WalletsExcludedFromHardCap[msg.sender] = true;

        // Minting total supply
        _mint(msg.sender, 100_000_000*10**18);
        // Approving swap for LP
        _approve(address(this), address(UniswapV2Router), ~uint256(0));

        ReflactionaryTotal = (~uint256(0) - (~uint256(0) % totalSupply()));
        BalancesRefraccionarios[msg.sender] = ReflactionaryTotal;

        HardCap = totalSupply();
        HardCapSell = totalSupply();
        HardCapBuy =  totalSupply();
        LiquidityThreshold = (totalSupply() * 5) / 10_000;
    }

    function ChangeTaxes(TaxRates memory newTaxes, bool buying)
    public
    onlyOwner
    {
        if (buying) {
            BuyingTaxes = newTaxes;
            return;
        }
        SellTaxes = newTaxes;
    }

    function SetAutoLiquidity(bool newFlag) public {
        require(
            msg.sender == DevAddress || msg.sender == owner(),
            "Only developers can change this flag"
        );
        AutoLiquidity = newFlag;
    }

    function swapTokensForETH(uint256 tokenAmount) private {
        // generate the pair path of token
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = UniswapV2Router.WETH();

        // make the swap
        UniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function withdraw() public {
        uint256 ethBalance = address(this).balance;
        bool success;
        (success, ) = address(DevAddress).call{value: ethBalance}("");
    }

    function WeAreLive() public onlyOwner {
        AreWeLive = true;
    }

    function ChangeExcludeFromFeeToForWallet(address add, bool isExcluded)
    public
    onlyOwner
    {
        WalletsExcludedFromFee[add] = isExcluded;
    }

    function ChangeDevAddress(address payable newDevAddress) public onlyOwner {
        address oldAddress = DevAddress;
        emit setDevAddress(oldAddress, newDevAddress);
        ChangeExcludeFromFeeToForWallet(DevAddress, false);
        DevAddress = newDevAddress;
        ChangeExcludeFromFeeToForWallet(DevAddress, true);
    }

    function ChangeMarketingAddress(address payable marketingAddress)
    public
    onlyOwner
    {
        address oldAddress = MarketingAddress;
        emit setMktAddress(oldAddress, marketingAddress);
        ChangeExcludeFromFeeToForWallet(MarketingAddress, false);
        MarketingAddress = marketingAddress;
        ChangeExcludeFromFeeToForWallet(MarketingAddress, true);
    }

    function balanceOf(address account) public view override returns (uint256) {
        return tokenFromReflection(BalancesRefraccionarios[account]);
    }

    function MarkBot(address targetAddress, bool isBot) public onlyOwner {
        Bots[targetAddress] = isBot;
        emit BlacklistedUser(targetAddress, isBot);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(!Bots[sender], "ERC20: address blacklisted (bot)");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(
            amount <= balanceOf(sender),
            "You are trying to transfer more than your balance"
        );

        bool takeFee = !(WalletsExcludedFromFee[sender] || WalletsExcludedFromFee[recipient]);

        if (takeFee) {

            if (AutomatedMarketMakerPairs[sender]) {
                // Not so fast ma boi
                if (!AreWeLive) {
                    Bots[recipient] = true;
                }

                AppliedRatesPercentage = BuyingTaxes;
                require(
                    amount <= HardCapBuy,
                    "amount must be <= maxTxAmountBuy"
                );
            } else {
                AppliedRatesPercentage = SellTaxes;
                require(
                    amount <= HardCapSell,
                    "amount must be <= maxTxAmountSell"
                );
            }
        }

        if (
            !InSwap &&
        !AutomatedMarketMakerPairs[sender] &&
        SwapEnabled &&
        sender != owner() &&
        recipient != owner() &&
        sender != address(UniswapV2Router) &&
        balanceOf(address(this)) >= LiquidityThreshold
        ) {
            InSwap = true;
            SwapAccumulatedFees();
            InSwap = false;
        }

        _tokenTransfer(sender, recipient, amount, takeFee);
    }

    // This method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 cantidadBruta,
        bool takeFee
    ) private {
        TransactionFees memory feesReales;
        TransactionFees memory feesRefracionarios;
        (feesReales, feesRefracionarios) = CalcularTasasRealesYRefracionarias(
            cantidadBruta,
            takeFee
        );

        uint256 cantidadNeta = cantidadBruta - feesReales.TotalFee;
        uint256 cantidadBrutaRefracionaria = cantidadBruta *
        GetConversionRate();
        uint256 cantidadNetaRefracionaria = cantidadBrutaRefracionaria -
        feesRefracionarios.TotalFee;

        // Comprobando que el receptor de la transferencia no supere el hard cap de tokens
        require(
            WalletsExcludedFromHardCap[recipient] ||
            (balanceOf(recipient) + cantidadNeta) <= HardCap,
            "Recipient cannot hold more than maxWalletAmount"
        );

        BalancesRefraccionarios[sender] -= cantidadBrutaRefracionaria;
        BalancesRefraccionarios[recipient] += cantidadNetaRefracionaria;

        if (takeFee) {
            ReflactionaryTotal -= feesRefracionarios.TransactionFee;
            TotalFee += feesReales.TransactionFee;

            AccumulateFee(feesReales, feesRefracionarios);

            if (AppliedRatesPercentage.BurnTax > 0) {
                TotalTokenBurn += feesReales.BurnFee;
                BalancesRefraccionarios[address(0)] += feesRefracionarios
                .BurnFee;
                emit Transfer(address(this), address(0), feesReales.BurnFee);
            }

            emit Transfer(sender, address(this), feesReales.TransferrableFee);
        }

        emit Transfer(sender, recipient, cantidadNeta);
    }

    function CalcularTasasRealesYRefracionarias(
        uint256 grossAmount,
        bool takeFee
    )
    private
    view
    returns (
        TransactionFees memory realFees,
        TransactionFees memory refFees
    )
    {
        if (takeFee) {
            uint256 currentRate = GetConversionRate();

            realFees.TransactionFee =
            (grossAmount * AppliedRatesPercentage.RewardTax) /
            100;
            realFees.BurnFee =
            (grossAmount * AppliedRatesPercentage.BurnTax) /
            100;
            realFees.DevFee =
            (grossAmount * AppliedRatesPercentage.DevelopmentTax) /
            100;
            realFees.MarketingFee =
            (grossAmount * AppliedRatesPercentage.MarketingTax) /
            100;
            realFees.LiquidityFee =
            (grossAmount * AppliedRatesPercentage.LiquidityTax) /
            100;

            realFees.TransferrableFee =
            realFees.DevFee +
            realFees.MarketingFee +
            realFees.LiquidityFee;
            realFees.TotalFee =
            realFees.TransactionFee +
            realFees.BurnFee +
            realFees.TransferrableFee;

            refFees.TransactionFee = realFees.TransactionFee * currentRate;
            refFees.BurnFee = realFees.BurnFee * currentRate;
            refFees.DevFee = realFees.DevFee * currentRate;
            refFees.MarketingFee = realFees.MarketingFee * currentRate;
            refFees.LiquidityFee = realFees.LiquidityFee * currentRate;

            refFees.TotalFee = realFees.TotalFee * currentRate;
            refFees.TransferrableFee = realFees.TransferrableFee * currentRate;
        }
    }

    function AccumulateFee(
        TransactionFees memory realFees,
        TransactionFees memory refractionaryFees
    ) private {
        BalancesRefraccionarios[address(this)] += refractionaryFees
        .TransferrableFee;
        AccumulatedFeeForDistribution.LiquidityFee += realFees.LiquidityFee;
        AccumulatedFeeForDistribution.DevFee += realFees.DevFee;
        AccumulatedFeeForDistribution.MarketingFee += realFees.MarketingFee;
    }

    function SwapPct(uint256 pct) public {
        uint256 balance = (balanceOf(address(this)) * pct) / 100;
        if (balance > 0) {
            SwapTokens(balance);
        }
    }

    function SwapTokens(uint256 tokensToSwap) internal {
        uint256 totalTokensToSwap = AccumulatedFeeForDistribution.DevFee +
        AccumulatedFeeForDistribution.MarketingFee +
        AccumulatedFeeForDistribution.LiquidityFee;

        bool success;

        uint256 liquidityTokens = (tokensToSwap *
            AccumulatedFeeForDistribution.LiquidityFee) /
        totalTokensToSwap /
        2;
        uint256 amountToSwapForETH = tokensToSwap - (liquidityTokens);
        uint256 initialETHBalance = address(this).balance;
        swapTokensForETH(amountToSwapForETH);

        uint256 ethBalance = address(this).balance - (initialETHBalance);

        uint256 ethForMarketing = (ethBalance *
            (AccumulatedFeeForDistribution.MarketingFee)) / (totalTokensToSwap);
        uint256 ethForDev = (ethBalance *
            (AccumulatedFeeForDistribution.DevFee)) / (totalTokensToSwap);

        uint256 ethForLiquidity = ethBalance - ethForMarketing - ethForDev;

        TotalSwapped += AccumulatedFeeForDistribution.LiquidityFee;
        AccumulatedFeeForDistribution.LiquidityFee = 0;
        AccumulatedFeeForDistribution.DevFee = 0;
        AccumulatedFeeForDistribution.MarketingFee = 0;

        (success, ) = address(DevAddress).call{value: ethForDev}("");

        if (
            liquidityTokens > 0 && ethForLiquidity > 0 && AutoLiquidity == true
        ) {
            UniswapV2Router.addLiquidityETH{value: ethForLiquidity}(
                address(this),
                liquidityTokens,
                0, // slippage is unavoidable
                0, // slippage is unavoidable
                DevAddress,
                block.timestamp
            );
            emit LiquidityAdded(liquidityTokens, ethForLiquidity);
        }

        (success, ) = address(MarketingAddress).call{value: ethForMarketing}(
            ""
        );
    }

    function SwapAccumulatedFees() private {
        uint256 tokensToSwap = balanceOf(address(this));
        if (tokensToSwap > LiquidityThreshold) {
            if (tokensToSwap > LiquidityThreshold * 20) {
                tokensToSwap = LiquidityThreshold * 20;
            }
            SwapTokens(balanceOf(address(this)));
        }
    }

    function tokenFromReflection(uint256 reflactionaryAmount)
    public
    view
    returns (uint256)
    {
        require(
            reflactionaryAmount <= ReflactionaryTotal,
            "Amount must be less than total reflections"
        );
        return reflactionaryAmount / GetConversionRate();
    }

    function GetConversionRate() private view returns (uint256) {
        return ReflactionaryTotal / totalSupply();
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        SwapEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    receive() external payable {}
}