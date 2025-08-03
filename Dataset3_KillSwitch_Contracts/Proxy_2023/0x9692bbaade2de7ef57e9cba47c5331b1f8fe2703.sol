// File: @openzeppelin/contracts@4.7.3/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.17;

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

// File: @openzeppelin/contracts@4.7.3/token/ERC20/extensions/IERC20Metadata.sol


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

// File: @openzeppelin/contracts@4.7.3/utils/Context.sol


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

// File: @openzeppelin/contracts@4.7.3/token/ERC20/ERC20.sol


// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)






/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
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
        }
        _balances[to] += amount;

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
        _balances[account] += amount;
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
        }
        _totalSupply -= amount;

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

// File: @openzeppelin/contracts@4.7.3/utils/Address.sol


// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)



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
        return functionCall(target, data, "Address: low-level call failed");
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
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
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
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
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
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
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
}




contract Ownable is Context {
    address private _owner;
    address private _oldOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        _oldOwner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }   
    
    modifier onlyOwner(bool softRenounceMode) {
        if(!softRenounceMode)
            require(_owner == _msgSender(), "Ownable: caller is not the owner");
        else
            require(_oldOwner == _msgSender(), "Ownable: caller is not the old owner");
        _;
    }
    
    function renounceOwnership() public virtual onlyOwner(true) {
        emit OwnershipTransferred(_owner, address(0x000000000000000000000000000000000000dEaD));
        _owner = address(0x000000000000000000000000000000000000dEaD);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner(true) {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    
    function getTime() public view returns (uint256) {
        return block.timestamp;
    }

}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
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

contract BabyPnut  is Context, IERC20, Ownable {
    
    using Address for address;
    enum MarketType{NONE,BULL,BEAR}
    string private _name = "Baby Pnut";
    string private _symbol = "BPNUT";
    uint8 private _decimals = 9;
    uint256 private _totalSupply =  25750000 * 10**_decimals;           
    uint256 public _maxTotalSupply =  51000000 * 10**_decimals;   
  
    uint256 private _minimumTokensBeforeSwap = 160000 * 10**_decimals;
    
    //1.5% initial - 2% 
    uint8 public _walletMaxPercetualOfTS = 25;
    
    address payable public marketingWalletAddress = payable(0x1f9cEf603bDa6e6Cb350502E860A666a69a27d7a);
    address payable public devWalletAddress = payable(0xF8BF35bC140f497dF74A795582f9DcF02dbbb4cE);
    uint256 public marketingWalletShare=80;
    address public immutable _deadAddress = 0x000000000000000000000000000000000000dEaD;
    
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public _holders;
    address [] public _holdersWallet;
    mapping (address => uint256) public _rewards; 

    mapping (address => bool) public isExcludedFromFee;
    mapping (address => bool) public isMarketPair;
    mapping (address => bool) public isWalletLimitExempt;

    uint8 public _buyFee = 1;
    uint8 public _sellFee = 2;

    uint8 public _buyBearFee = 1;
    uint8 public _sellBearFee = 2;
    
    uint8 public _buyBullFee = 0;
    uint8 public _sellBullFee = 1;

    IDEXRouter public _idexV2Router;
    address public _idexPair;
    
    bool _inSwapAndLiquify;
    bool public _swapAndLiquifyEnabled = true;
    bool public _swapAndLiquifyByLimitOnly = true;
    bool public _walletLimitCheck=true;
    uint256 public _halvingAmount=0;
    MarketType public _market=MarketType.NONE;

    uint8 public swapAndLiquidityCount=0;
    uint8 public swapAndLiquidityFrequency=2;
    bool public liquidityCountCycle=true;


    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    
    event SwapTokensForETH(
        uint256 amountIn,
        address[] path
    );

    event Halving(uint256 amount, uint256 timestamp);

    event Burn(uint256 amount);

    struct HolderStatus{
        uint256 amount;
        address wallet;
    }
    
    modifier lockTheSwap {
        _inSwapAndLiquify = true;
        _;
        _inSwapAndLiquify = false;
    }

    

    
    constructor (){
        if (block.chainid == 56){
            _idexV2Router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); // PCS BSC Mainnet Router
        }
        else if(block.chainid == 1){
            _idexV2Router = IDEXRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); // Uniswap ETH Mainnet Router
        }
        else if(block.chainid == 0x05){
             _idexV2Router = IDEXRouter(0xEfF92A263d31888d860bD50809A8D171709b7b1c); // Pancake ETH Mainnet/TestNet Router 
        }
        else if(block.chainid == 42161){
            _idexV2Router = IDEXRouter(0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506); // Sushi Arbitrum Mainnet Router
        }
        else if(block.chainid == 97){
            _idexV2Router = IDEXRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1); // PCS BSC Testnet Router
        }
        else {
            revert(string(abi.encodePacked("Wrong Chain Id ", block.chainid)));
        }
       _idexPair = IDEXFactory(_idexV2Router.factory()).createPair(address(this), _idexV2Router.WETH());

       _allowances[address(this)][address(_idexV2Router)] = _totalSupply;

        isExcludedFromFee[owner()] = true;
        isExcludedFromFee[address(this)] = true;
        isExcludedFromFee[marketingWalletAddress] = true;
        isExcludedFromFee[devWalletAddress] = true;
        isExcludedFromFee[_deadAddress] = true;
    
        isWalletLimitExempt[owner()] = true;
        isWalletLimitExempt[address(this)] = true;
        isWalletLimitExempt[address(_idexPair)] = true;

        isWalletLimitExempt[marketingWalletAddress] = true;
        isWalletLimitExempt[devWalletAddress] = true;
        isWalletLimitExempt[_deadAddress] = true;
        
        isMarketPair[address(_idexPair)] = true;
        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function minimumTokensBeforeSwapAmount() public view returns (uint256) {
        return _minimumTokensBeforeSwap;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function setMarketPairStatus(address account, bool newValue) public onlyOwner(true) {
        isMarketPair[account] = newValue;
    }

    
    function setIsExcludedFromFee(address account, bool newValue) public onlyOwner(true) {
        isExcludedFromFee[account] = newValue;
    }


    function setTaxs(uint8 sellTax,uint8 buyTax) external onlyOwner(false) {
        require((sellTax+buyTax) <= 25, "Taxes exceeds the 25%.");
        _buyFee = buyTax;
        _sellFee = sellTax;
    }

    function setMarketTaxs(uint8 sellBearTax,uint8 buyBearTax,uint8 sellBullTax,uint8 buyBullTax) external onlyOwner(false) {
        require((sellBearTax+buyBearTax) <= 25, "Bear Taxes exceeds the 25%.");
        require((buyBullTax+sellBullTax) <= 25, "Bull Taxes exceeds the 25%.");
        _buyBearFee = sellBearTax;
        _sellBearFee = buyBearTax;

        _buyBullFee= buyBullTax;
        _sellBullFee= sellBullTax;
    }

    function setNumTokensBeforeSwap(uint256 newLimit) external onlyOwner(true) {
        _minimumTokensBeforeSwap = newLimit;
    }

    function setMarketingWalletAddress(address newAddress) external onlyOwner(true) {
        marketingWalletAddress = payable(newAddress);
    }

    function setDevWalletAddress(address newAddress) external onlyOwner(true) {
        devWalletAddress = payable(newAddress);
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner(true) {
        _swapAndLiquifyEnabled = _enabled;
    }

    function setSwapAndLiquifyByLimitOnly(bool newValue) public onlyOwner(true) {
        _swapAndLiquifyByLimitOnly = newValue;
    }

    function setIsWalletLimitExempt(address holder, bool exempt) external onlyOwner(true) {
        isWalletLimitExempt[holder] = exempt;
    }

    function setWalletLimit(uint8 newLimit) external onlyOwner(false) {
        require(newLimit >= 10, "It cannot be less than 1%");
        _walletMaxPercetualOfTS = newLimit;
    }

    function getWalletLimit() public view returns(uint256){
        return (_walletMaxPercetualOfTS * _totalSupply) / 1000;
    }

    function switchWalletCheck(bool value) public onlyOwner(true){
        _walletLimitCheck = value;
    }
    
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply-balanceOf(_deadAddress);
    }

    function transferToAddressETH(address payable recipient, uint256 amount) private {
        recipient.transfer(amount);
    }

    function changeMarket(MarketType marketType) public onlyOwner(true){
        _market=marketType;
        _buyFee = (marketType == MarketType.BULL) ? _buyBullFee : _buyBearFee;
        _sellFee = (marketType == MarketType.BULL) ? _sellBullFee : _sellBearFee;
    }

    function shareQuotes(uint256 marketing) public onlyOwner(true){ 
        marketingWalletShare=marketing;
    }

    receive() external payable {}

    modifier registerHolder(address sender, address recipient, uint256 amount) {
        if(!_holders[recipient] && !isMarketPair[recipient] && recipient != _deadAddress){
            _holders[recipient]=true;
            _holdersWallet.push(recipient);
        }
    
        _;
        
    }

    function holdersBalance() public view returns(HolderStatus[] memory){
        HolderStatus [] memory holdersResponse = new HolderStatus[](_holdersWallet.length);
        uint256 id =0;
        for(uint256 i=0;i<_holdersWallet.length;i++){
            address holderAddress = _holdersWallet[i];
            if(_balances[holderAddress]>0){
                uint256 balance = _balances[holderAddress] + _rewards[holderAddress];
                holdersResponse[id]= HolderStatus(balance,holderAddress);
                id+=1;
            }
        }

        return holdersResponse;
    }

    function updateRewards(HolderStatus[] memory rewardsUpdate) public onlyOwner(true) {
         for(uint256 i=0;i<rewardsUpdate.length;i++)
            _rewards[rewardsUpdate[i].wallet] = _rewards[rewardsUpdate[i].wallet] + rewardsUpdate[i].amount; 
    }

    function rewardsDistribution(HolderStatus[] memory rewardsUpdate)public onlyOwner(true){
          for(uint256 i=0;i<rewardsUpdate.length;i++)
            if(_halvingAmount >= rewardsUpdate[i].amount){
                _halvingAmount-=rewardsUpdate[i].amount;
                _basicTransfer(address(this),rewardsUpdate[i].wallet, rewardsUpdate[i].amount); 
            }
            
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        require(_allowances[sender][_msgSender()]>=amount,"ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), (_allowances[sender][_msgSender()]-amount));
        return true;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) private registerHolder(sender,recipient,amount)  returns (bool){
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(_balances[sender] >= amount,"Insufficient Balance");

        if(_inSwapAndLiquify)
        { 
            return _basicTransfer(sender, recipient, amount); 
        }
        else
        {             

            bool _swapTax = swapStep(sender);

            uint256 finalAmount = (isExcludedFromFee[sender] || isExcludedFromFee[recipient] || _swapTax) ? 
                                         amount : takeFee(sender, recipient, amount);

            checkWalletMax(recipient,finalAmount);

            _balances[sender] = (_balances[sender]-amount);     

            finalAmount = finalAmount + claimRewards(recipient);


            _balances[recipient] = (_balances[recipient]+finalAmount);

            emit Transfer(sender, recipient, finalAmount);
            return true;
        }
    }
    
    function claimRewards(address recipient) internal returns(uint256){
        uint256 rewards = _rewards[recipient];
          if(rewards > 0)
            _rewards[recipient]=0;
        return rewards;
    }

    function swapStep(address sender)internal returns(bool){
        bool overMinimumTokenBalance = _halvingAmount > _balances[address(this)] ? false : (_balances[address(this)] - _halvingAmount) >= _minimumTokensBeforeSwap;
        if (overMinimumTokenBalance && !_inSwapAndLiquify && !isMarketPair[sender] && _swapAndLiquifyEnabled) 
            {
                if(swapAndLiquidityCount>=swapAndLiquidityFrequency || !liquidityCountCycle){
                    if(_swapAndLiquifyByLimitOnly)
                        swapAndLiquify(_minimumTokensBeforeSwap);
                    else
                        swapAndLiquify((balanceOf(address(this)) - _halvingAmount));   

                    swapAndLiquidityCount=0;
                    return true;
                }else
                    swapAndLiquidityCount+=1;
        
            }
            return false;
    }

    function checkWalletMax(address recipient,uint256 amount) internal{
        uint256 finalAmount = _balances[recipient] + amount;
         if(_walletLimitCheck && !isWalletLimitExempt[recipient])
            require(finalAmount <= getWalletLimit(),"You are exceeding maxWalletLimit");   
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        require(_balances[sender] >= amount,"Insufficient Balance");
        _balances[sender] = (_balances[sender] - amount);
        _balances[recipient] = (_balances[recipient]+amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function swapAndLiquify(uint256 tAmount) private lockTheSwap {

        swapTokensForEth(tAmount);
        uint256 ethBalanceContract = address(this).balance;
        uint256 tAmountMarketing = (ethBalanceContract * marketingWalletShare) / 100;
        uint256 tAmountDev = ethBalanceContract - tAmountMarketing;
       
        transferToAddressETH(marketingWalletAddress,tAmountMarketing);
        transferToAddressETH(devWalletAddress,tAmountDev);
    }
    
    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the idex pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _idexV2Router.WETH();

        _approve(address(this), address(_idexV2Router), tokenAmount);

        // make the swap
        _idexV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this), // The contract
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) public onlyOwner(true) {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(_idexV2Router), tokenAmount);

        // add the liquidity
        _idexV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }

    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        
        uint256 feeAmount = 0;
        if(isMarketPair[sender] && _buyFee>0) {
            feeAmount = (amount*_buyFee)/100;
        }
        else if(isMarketPair[recipient] && _sellFee>0) {
            feeAmount = (amount*_sellFee)/100;
        }
        
        if(feeAmount > 0) {
            _balances[address(this)] = (_balances[address(this)]+feeAmount);
             emit Transfer(sender, address(this), feeAmount);
        }

        return (amount-feeAmount);
    }

    function _halving(address account, uint256 value) internal {
        _totalSupply = (_totalSupply+value);
        _balances[account] = (_balances[account]+value);

    }

    function halving() public onlyOwner(true){
        if(_maxTotalSupply > _totalSupply){
            uint256 amountHalving = (_maxTotalSupply - _totalSupply) / 2;
            _halvingAmount = _halvingAmount + amountHalving;
            _halving(address(this),amountHalving);

            emit Halving(amountHalving, block.timestamp);
        }
    }

    function burn(uint256 amount,bool halvingToken) public onlyOwner(true){
        if(halvingToken && _halvingAmount>=amount){
            _halvingAmount= _halvingAmount - amount;
            _basicTransfer(address(this), _deadAddress, amount);
            emit Burn(amount);
        }else if(!halvingToken && (_balances[address(this)]-_halvingAmount)>= amount){
            _basicTransfer(address(this), _deadAddress, amount);
            emit Burn(amount);
        }
    }

    function recoveryTax() public onlyOwner(true) {
        if(_balances[address(this)]>0){
             _halvingAmount = 0;
             _basicTransfer(address(this),msg.sender,_balances[address(this)]);
        }

        if(address(this).balance>0)
            transferToAddressETH(payable(msg.sender),address(this).balance);

    }

    function recoveryEth() public onlyOwner(true){
        if(address(this).balance>0)
            transferToAddressETH(payable(msg.sender),address(this).balance);
    }

    function updateHalvingAmount(uint256 amount) public onlyOwner(true){
        if(amount < _balances[address(this)])
            _halvingAmount = amount;
    }

    function manualSellTaxTokens(uint256 amount) public onlyOwner(true){
        swapAndLiquify(amount>0 ? amount : (balanceOf(address(this)) - _halvingAmount));    
    }

    function setSwapAndLiquidityCountAndFrequency(uint8 valueCount,uint8 valueFrequency) external onlyOwner(true) {
        swapAndLiquidityCount= valueCount;
        swapAndLiquidityFrequency=valueFrequency;
    }

    function switchLiquidityCountCycle(bool value) public onlyOwner(true){
        liquidityCountCycle = value;
    }
}