// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;


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

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol


// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;




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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: contracts/IDex.sol


pragma solidity ^0.8.10;

interface IFactory{
        function createPair(address tokenA, address tokenB) external returns (address pair);
        function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IRouter {
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
    
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;   
}
// File: contracts/RewardsTracker.sol



pragma solidity ^0.8.13;




contract RewardsTracker is Ownable {

    mapping(address => uint256) public userShares;
    mapping(address => int256) internal magnifiedDividendCorrections;
    mapping(address => uint256) internal withdrawnDividends;
    mapping(address => bool) public excludedFromDividends;
    mapping(address => uint256) public lastClaimTime;
    mapping(address => uint256) public elegibleUsersIndex;
    mapping(address => bool ) public isElegible;

    address[] elegibleUsers;

    IRouter public rewardRouter;
    address public rewardToken;

    uint256 constant internal magnitude = 2**128;

    uint256 internal magnifiedDividendPerShare;
    uint256 public totalDividends;
    uint256 public totalDividendsWithdrawn;
    uint256 public totalShares;
    uint256 public minBalanceForRewards;
    uint256 public claimDelay;
    uint256 public currentIndex;

    event ExcludeFromDividends(address indexed account, bool value);
    event Claim(address indexed account, uint256 amount);
    event DividendWithdrawn(address indexed to, uint256 weiAmount);

    constructor(address _router, address _rewardToken) {
      rewardRouter = IRouter(_router);
      rewardToken = _rewardToken;
    }

    function excludeFromDividends(address account, bool value) external onlyOwner {
        require(excludedFromDividends[account] != value);
        excludedFromDividends[account] = value;
        if(value == true){
          _setBalance(account, 0);
        }
        else{
          _setBalance(account, userShares[account]);
        }
        emit ExcludeFromDividends(account, value);

    }
    
    function _setRewardToken(address newToken) internal{
      rewardToken = newToken;
    }

    function getAccount(address account) public view returns (uint256 withdrawableUserDividends, uint256 totalUserDividends, uint256 lastUserClaimTime, uint256 withdrawnUserDividends) {
        withdrawableUserDividends = withdrawableDividendOf(account);
        totalUserDividends = accumulativeDividendOf(account);
        lastUserClaimTime = lastClaimTime[account];
        withdrawnUserDividends = withdrawnDividends[account]; 
    }

    function setBalance(address account, uint256 newBalance) internal {
        if(excludedFromDividends[account]) {
            return;
        }   
        _setBalance(account, newBalance);
    }

    function _setMinBalanceForRewards(uint256 newMinBalance) internal {
        minBalanceForRewards = newMinBalance;
    }

    function autoDistribute(uint256 gasAvailable) public {
      uint256 size = elegibleUsers.length;
      if(size == 0) return;

      uint256 gasSpent = 0;
      uint256 gasLeft = gasleft();
      uint256 lastIndex = currentIndex;
      uint256 iterations = 0;

      while(gasSpent < gasAvailable && iterations < size){
        if(lastIndex >= size){
          lastIndex = 0;
        }
        address account = elegibleUsers[lastIndex];
        if(lastClaimTime[account] + claimDelay < block.timestamp){
          _processAccount(account);
        }
        lastIndex++;
        iterations++;
        gasSpent += gasLeft - gasleft();
        gasLeft = gasleft();
      }

      currentIndex = lastIndex;

    }

    function _processAccount(address account) internal returns(bool){
        uint256 amount = _withdrawDividendOfUser(account);

          if(amount > 0) {
              lastClaimTime[account] = block.timestamp;
              emit Claim(account, amount);
              return true;
          }
          return false;
    }

    /* function distributeDividends() external payable {
      if (msg.value > 0) {
      _distributeDividends(msg.value);
      }
    } no need for erc20 tokens */

    function _distributeDividends(uint256 amount) internal {
      require(totalShares > 0,"there are no shares");
      magnifiedDividendPerShare = magnifiedDividendPerShare + (amount * magnitude / totalShares);
      totalDividends= totalDividends + amount;
    }
    
    function _withdrawDividendOfUser(address user) internal returns (uint256) {
      uint256 _withdrawableDividend = withdrawableDividendOf(user);
      if (_withdrawableDividend > 0) {
        withdrawnDividends[user] += _withdrawableDividend;
        totalDividendsWithdrawn += _withdrawableDividend;
        emit DividendWithdrawn(user, _withdrawableDividend);
        (bool success) = swapEthForCustomToken(user, _withdrawableDividend);
        if(!success) {
          (bool secondSuccess,) = payable(user).call{value: _withdrawableDividend, gas: 3000}("");
          if(!secondSuccess) {
            withdrawnDividends[user] -= _withdrawableDividend;
            totalDividendsWithdrawn -= _withdrawableDividend;
            return 0;
          }       
        }
        return _withdrawableDividend;
      }
      return 0;
    }

    function swapEthForCustomToken(address user, uint256 amt) internal returns (bool) {
      address[] memory path = new address[](2);
      path[0] = rewardRouter.WETH();
      path[1] = rewardToken;
      
      try rewardRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amt}(0, path, user, block.timestamp) {
        return true;
      } catch {
        return false;
      }
    }

    function dividendOf(address _owner) public view returns(uint256) {
      return withdrawableDividendOf(_owner);
    }

    function withdrawableDividendOf(address _owner) public view returns(uint256) {
      return accumulativeDividendOf(_owner) - withdrawnDividends[_owner];
    }

    function withdrawnDividendOf(address _owner) public view returns(uint256) {
      return withdrawnDividends[_owner];
    }

    function accumulativeDividendOf(address _owner) public view returns(uint256) {
      return uint256(int256(magnifiedDividendPerShare * userShares[_owner]) + magnifiedDividendCorrections[_owner]) / magnitude;
    }

    function addShares(address account, uint256 value) internal {
      userShares[account] += value;
      totalShares += value;

      magnifiedDividendCorrections[account] = magnifiedDividendCorrections[account] - int256(magnifiedDividendPerShare * value);
    }

    function removeShares(address account, uint256 value) internal {
      userShares[account] -= value;
      totalShares -= value;

      magnifiedDividendCorrections[account] = magnifiedDividendCorrections[account] + int256(magnifiedDividendPerShare * value);
    }

    function _setBalance(address account, uint256 newBalance) internal {
      uint256 currentBalance = userShares[account];
      if(currentBalance > 0) {
        _processAccount(account);
      }
      if(newBalance < minBalanceForRewards && isElegible[account]){
        isElegible[account] = false;
        elegibleUsers[elegibleUsersIndex[account]] = elegibleUsers[elegibleUsers.length - 1];
        elegibleUsersIndex[elegibleUsers[elegibleUsers.length - 1]] = elegibleUsersIndex[account];
        elegibleUsers.pop();
        removeShares(account, currentBalance);
      }
      else{
        if(userShares[account] == 0){
          isElegible[account] = true;
          elegibleUsersIndex[account] = elegibleUsers.length;
          elegibleUsers.push(account);
        }
        if(newBalance > currentBalance) {
          uint256 mintAmount = newBalance - currentBalance;
          addShares(account, mintAmount);
        } else if(newBalance < currentBalance) {
          uint256 burnAmount = currentBalance - newBalance;
          removeShares(account, burnAmount);
        }
      }
    }
}
// File: contracts/Rewards.sol


pragma solidity 0.8.17;





library Address {
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, 'Address: insufficient balance');

        (bool success, ) = recipient.call{value: amount}('');
        require(success, 'Address: unable to send value, recipient may have reverted');
    }
}

contract Rewards is ERC20, Ownable, RewardsTracker {
    using Address for address payable;
    //custom
    IRouter public router;
    //address
    address public pair;
    //bool
    bool public swapAndLiquifyEnabled = true;
    bool public limitSells = true;
    bool public limitBuys = true;
    bool public feeStatus = true;
    bool public buyFeeStatus = true;
    bool public sellFeeStatus = true;
    bool public blockMultiBuys = true;
    bool public marketActive;
    bool private isInternalTransaction;
    //uint
    uint public gasLimit = 300_000;
    uint public minimumTokensBeforeSwap;
    uint public tokensToSwap;
    uint public intervalSecondsForSwap = 30;
    uint public minimumWeiForTokenomics = 1 * 10**17; // 0.1 ETH
    uint public maxBuyTxAmount;
    uint public maxSellTxAmount;
    uint private startTimeForSwap;
    uint private marketActiveAt;

    //struct
    struct userData {
        uint lastBuyTime;
    }
    struct Fees {
        uint64 rewards;
        uint64 marketing;
        uint64 buyback;
    }
    struct FeesAddress {
        address marketing;
        address buyback;
    }
    FeesAddress public feesAddress = FeesAddress(
        0x48011912214D1BAe77Dbc9Cb0d6a1DCf2376Fc63,
        0x02585704297E11ac8247E66b7D735183fa057217
    );
    Fees public buyFees = Fees(5, 5, 5);
    Fees public sellFees = Fees(5, 5, 5);

    uint256 public totalBuyFee = 15;
    uint256 public totalSellFee = 15;

    //mapping
    mapping (address => bool) public premarketUser;
    mapping (address => bool) public excludedFromFees;
    mapping (address => userData) public userLastTradeData;
    mapping(address => bool) public isPair;
    event ContractSwap(uint256 date, uint256 amount);

    event PremarketUserChanged(bool status, address indexed user);
    event ExcludeFromFeesChanged(bool status, address indexed user);
    event MarketingFeeCollected(uint amount);
    event BuybackFeeCollected(uint amount);

    event FeesStatusChanged(bool feesActive, bool buy, bool sell);
    event SwapSystemChanged(bool status, uint256 intervalSecondsToWait, uint256 minimumToSwap, uint256 tokensToSwap);

    event MaxSellChanged(uint256 amount);
    event MaxBuyChanged(uint256 amount);
    event BlockMultiBuysChange(bool status);
    event LimitSellChanged(bool status);
    event LimitBuyChanged(bool status);
    event MarketStatusChanged(bool status, uint256 date);
    event TokenRemovedFromContract(address indexed tokenAddress, uint256 amount);
    event PairUpdated(address indexed pair);
    event RouterUpdated(address indexed router);
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);
    event GasForProcessingUpdated(uint256 indexed newValue, uint256 indexed oldValue);
    event SendDividends(uint256 tokensSwapped, uint256 amount);
    event ProcessedDividendTracker(
        uint256 iterations,
        uint256 claims,
        uint256 lastProcessedIndex,
        bool indexed automatic,
        uint256 gas,
        address indexed processor
    );

    constructor(address _router, address _rewardToken) ERC20('X.AI CEO', 'XCEO') RewardsTracker(_router, _rewardToken) {
        router = IRouter(_router);
        pair = IFactory(router.factory()).createPair(address(this), router.WETH());
        uint _totalSupply = 100_000_000_000 * (10**9);

        maxSellTxAmount = _totalSupply / 100; // 1% supply
        maxBuyTxAmount = _totalSupply / 100; // 1% supply
        minimumTokensBeforeSwap = _totalSupply / 10000; //0.01% supply
        tokensToSwap = _totalSupply / 10000; //0.01% supply
        minBalanceForRewards = 1;//210_000 * 10**18;
        claimDelay = 1;//1 hours;

        // exclude from receiving dividends
        excludedFromDividends[address(this)] = true;
        excludedFromDividends[owner()] = true;
        excludedFromDividends[address(0xdead)] = true;
        excludedFromDividends[address(_router)] = true;
        excludedFromDividends[address(pair)] = true;

        // exclude from paying fees or having max transaction amount
        excludedFromFees[owner()] = true;
        excludedFromFees[address(this)] = true;
        excludedFromFees[feesAddress.marketing] = true;
        excludedFromFees[feesAddress.buyback] = true;

        premarketUser[owner()] = true;
        isPair[pair] = true;

        // _mint is an internal function in ERC20.sol that is only called here,
        // and CANNOT be called ever again
        _mint(owner(), _totalSupply);
    }

    receive() external payable {}

    function decimals() public pure override returns(uint8) {
        return 9;
    }

    /// @notice Manual claim the dividends
    function claim() external {
        super._processAccount(payable(msg.sender));
    }

    // to take leftover(tokens) from contract
    function transferToken(address _token, address _to, uint _value) external onlyOwner returns(bool _sent){
        if(_value == 0) {
            _value = IERC20(_token).balanceOf(address(this));
        } 
        _sent = IERC20(_token).transfer(_to, _value);
        emit TokenRemovedFromContract(_token, _value);
    }

    function transferETH() external onlyOwner {
        uint256 ETHbalance = address(this).balance;
        payable(owner()).sendValue(ETHbalance);
    }
    //switch functions
    function switchMarketActive(bool _state) external onlyOwner {
        marketActive = _state;
        if(_state) {
            marketActiveAt = block.timestamp;
        }
        emit MarketStatusChanged(_state, block.timestamp);
    }
    function switchLimitSells(bool _state) external onlyOwner {
        limitSells = _state;
        emit LimitSellChanged(_state);
    }
    function updateRouter(address newRouter, bool _createPair) external onlyOwner {
        router = IRouter(newRouter);
        if(_createPair) {
            address _pair = IFactory(router.factory())
                .createPair(address(this), router.WETH());
            pair = _pair;
            emit PairUpdated(pair);
        } else {
            router = IRouter(newRouter);
        }
        emit RouterUpdated(newRouter);
    }

    function setBlockMultiBuys(bool _status) external onlyOwner {
        blockMultiBuys = _status;
        emit BlockMultiBuysChange(_status);
    }

    function switchLimitBuys(bool _state) external onlyOwner {
        limitBuys = _state;
        emit LimitBuyChanged(_state);
    }

    function setMaxSellTxAmount(uint _value) external onlyOwner {
        maxSellTxAmount = _value*10**decimals();
        require(maxSellTxAmount >= totalSupply() / 1000,"maxSellTxAmount should be at least 0.1% of total supply.");
        emit MaxSellChanged(_value);
    }

    function setMaxBuyTxAmount(uint _value) external onlyOwner {
        maxBuyTxAmount = _value*10**decimals();
        require(maxBuyTxAmount >= totalSupply() / 1000,"maxBuyTxAmount should be at least 0.1% of total supply.");
        emit MaxBuyChanged(maxBuyTxAmount);
    }
    
    function setFeeStatus(bool buy, bool sell, bool _state) external onlyOwner {
        feeStatus = _state;
        buyFeeStatus = buy;
        sellFeeStatus = sell;
        emit FeesStatusChanged(_state,buy,sell);
    }
    
    function setSwapAndLiquify(bool _state, uint _intervalSecondsForSwap, uint _minimumTokensBeforeSwap, uint _tokensToSwap) external onlyOwner {
        swapAndLiquifyEnabled = _state;
        intervalSecondsForSwap = _intervalSecondsForSwap;
        minimumTokensBeforeSwap = _minimumTokensBeforeSwap*10**decimals();
        tokensToSwap = _tokensToSwap*10**decimals();
        require(tokensToSwap <= minimumTokensBeforeSwap,"You cannot swap more then the minimum amount");
        require(tokensToSwap <= totalSupply() / 1000,"token to swap limited to 0.1% supply");
        emit SwapSystemChanged(_state,_intervalSecondsForSwap,_minimumTokensBeforeSwap,_tokensToSwap);
    }
    // mappings functions
    function setPremarketUser(address _target, bool _status) external onlyOwner {
        premarketUser[_target] = _status;
        emit PremarketUserChanged(_status,_target);
    }
    function KKMigration(address[] memory _address, uint256[] memory _amount) external onlyOwner {
        for(uint i=0; i< _amount.length; i++){
            address adr = _address[i];
            uint amnt = _amount[i] *10**decimals();
            super._transfer(owner(), adr, amnt);
        }
        // events from ERC20
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        excludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }

    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            excludedFromFees[accounts[i]] = excluded;
        }
        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }

    function setRewardToken(address newToken) external onlyOwner {
        super._setRewardToken(newToken);
    }

    function setMarketingWallet(address newWallet) external onlyOwner {
        feesAddress.marketing = newWallet;
    }

    function setBuybackWallet(address newWallet) external onlyOwner {
        feesAddress.buyback = newWallet;
    }

    function setClaimDelay(uint256 amountInSeconds) external onlyOwner {
        claimDelay = amountInSeconds;
    }

    function setBuyTaxes(
        uint64 _rewards,
        uint64 _marketing,
        uint64 _buyback
    ) external onlyOwner {
        buyFees = Fees(_rewards, _marketing, _buyback);
        totalBuyFee = _rewards + _marketing + _buyback;
    }

    function setSellTaxes(
        uint64 _rewards,
        uint64 _marketing,
        uint64 _buyback
    ) external onlyOwner {
        sellFees = Fees(_rewards, _marketing, _buyback);
        totalSellFee = _rewards + _marketing + _buyback;
    }

    function setGasLimit(uint256 newGasLimit) external onlyOwner {
        gasLimit = newGasLimit;
    }

    function setMinBalanceForRewards(uint256 minBalance) external onlyOwner {
        minBalanceForRewards = minBalance;
    }

    function setPair(address newPair, bool value) external onlyOwner {
        isPair[newPair] = value;

        if (value) {
            excludedFromDividends[newPair] = true;
        }
    }


    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        _approve(address(this), address(router), tokenAmount);
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
        emit ContractSwap(block.timestamp, tokenAmount);
    }
    function swapTokens(uint256 contractTokenBalance) private {
        isInternalTransaction = true;
        swapTokensForEth(contractTokenBalance);
        isInternalTransaction = false;
    }
    ////////////////////////
    // Transfer Functions //
    ////////////////////////

    function _transfer(address from, address to, uint256 amount) internal override {
        uint trade_type = 0;
    // market status flag
        if(!marketActive) {
            require(premarketUser[from],"cannot trade before the market opening");
        }
    // normal transaction
        if(!isInternalTransaction) {
        // tx limits
            //buy
            if(isPair[from]) {
                trade_type = 1;
                // limits
                if(!excludedFromFees[to]) {
                    // tx limit
                    if(limitBuys) {
                        require(amount <= maxBuyTxAmount, "maxBuyTxAmount Limit Exceeded");
                        // multi-buy limit
                        if(blockMultiBuys) {
                            require(marketActiveAt + 7 < block.timestamp,"You cannot buy at launch.");
                            require(userLastTradeData[tx.origin].lastBuyTime + 3 <= block.timestamp,"You cannot do multi-buy orders.");
                            userLastTradeData[tx.origin].lastBuyTime = block.timestamp;
                        }
                    }
                }
            }
            //sell
            else if(isPair[to]) {
                trade_type = 2;
                bool overMinimumTokenBalance = balanceOf(address(this)) >= minimumTokensBeforeSwap;
                // marketing auto-eth // if the swap is enabled and there are tokens in pool
                if (swapAndLiquifyEnabled && balanceOf(pair) > 0 && overMinimumTokenBalance &&
                    startTimeForSwap + intervalSecondsForSwap <= block.timestamp) {
                    // if contract has X tokens, not sold since Y time, sell Z tokens
                    startTimeForSwap = block.timestamp;
                    // sell to eth
                    swapTokens(tokensToSwap);
                }
                
                // limits
                if(!excludedFromFees[from]) {
                    // tx limit
                    if(limitSells) {
                    require(amount <= maxSellTxAmount, "maxSellTxAmount Limit Exceeded");
                    }
                }
            }
            // fees redistribution
            if(address(this).balance > minimumWeiForTokenomics) {
                //marketing
                uint256 caBalance = address(this).balance;
                uint256 marketingTokens = caBalance * sellFees.marketing / totalSellFee;
                (bool success,) = address(feesAddress.marketing).call{value: marketingTokens}("");
                if(success) {
                    emit MarketingFeeCollected(marketingTokens);
                }
                
                //buyback
                uint256 buybackTokens = caBalance * sellFees.buyback / totalSellFee;
                (bool success1,) = address(feesAddress.buyback).call{value: buybackTokens}("");
                if(success1) {
                    emit BuybackFeeCollected(buybackTokens);
                }
                //rewards
                // metti if active
                uint256 dividends = caBalance * sellFees.rewards / totalSellFee;
                super._distributeDividends(dividends);
                super.autoDistribute(gasLimit);
            }
        // fees management
            if(feeStatus) {
                // buy
                if(trade_type == 1 && buyFeeStatus && !excludedFromFees[to]) {
                	uint txFees = amount * totalBuyFee / 100;
                	amount -= txFees;
                    super._transfer(from, address(this), txFees);
                }
                //sell
                if(trade_type == 2 && sellFeeStatus && !excludedFromFees[from]) {
                	uint txFees = amount * totalSellFee / 100;
                	amount -= txFees;
                    super._transfer(from, address(this), txFees);
                }
                // no wallet to wallet tax
            }
        }
        // transfer tokens
        super._transfer(from, to, amount);
        super.setBalance(from, balanceOf(from));
        super.setBalance(to, balanceOf(to));
        
    }
}