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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

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
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./interfaces/IUniswapV2Factory.sol";
import "./interfaces/IUniswapV2Router.sol";
import "./libraries/Utils.sol";

contract Communism is Context, IERC20, Ownable, ReentrancyGuard {
  using SafeMath for uint256;
  using Address for address payable;

  mapping(address => uint256) private _balances;
  mapping(address => mapping(address => uint256)) private _allowances;
  mapping(address => bool) private _isExcludedFromFee;
  mapping(address => bool) private _isExcludedFromMaxTx;

  mapping(address => bool) public isBlacklisted;
  mapping(address => uint256) public nextAvailableClaimDate;
  mapping(address => uint256) public personalETHClaimed;

  uint256 private _totalSupply = 100000000 * 10 ** 18;
  uint8 private _decimals = 18;
  string private _name = "Communism";
  string private _symbol = "COMMUNISM";

  uint256 public rewardCycleBlock = 12 hours;
  uint256 public easyRewardCycleBlock = 3 hours;
  uint256 public _maxTxAmount = _totalSupply;
  uint256 public disableEasyRewardFrom = 0;
  uint256 public enableRedReservePurgeFrom = 0;
  uint256 public totalETHClaimed = 0;
  uint256 public claimDelay = 1 hours;
  uint256 public purgeRewardPercent = 2;

  bool public tradingEnabled = false;

  IUniswapV2Router02 public immutable uniswapV2Router;

  address public immutable uniswapV2Pair;
  address public marketingAddress;

  Taxes public taxes;
  Taxes public sellTaxes;

  uint256 public _totalMarketing;
  uint256 public _totalReward;

  struct Taxes {
    uint256 marketing;
    uint256 reward;
  }

  event ClaimETHSuccessfully(
    address recipient,
    uint256 ethReceived,
    uint256 nextAvailableClaimDate
  );

  event ClaimETHGambleSuccessfully(
    address recipient,
    uint256 ethReceived,
    uint256 nextAvailableClaimDate,
    bool isLotteryWon
  );

  event RedReservePurged(address recipient, uint256 tokensSwapped);

  constructor(address payable routerAddress) {
    _balances[_msgSender()] = _totalSupply;

    IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(routerAddress);
    // Create a uniswap v2 pair for this new token
    uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(
      address(this),
      _uniswapV2Router.WETH()
    );

    uniswapV2Router = _uniswapV2Router;

    _isExcludedFromFee[owner()] = true;
    _isExcludedFromFee[address(this)] = true;

    _isExcludedFromMaxTx[owner()] = true;
    _isExcludedFromMaxTx[address(this)] = true;
    _isExcludedFromMaxTx[
      address(0x000000000000000000000000000000000000dEaD)
    ] = true;
    _isExcludedFromMaxTx[address(0)] = true;

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

  function allowance(
    address owner,
    address spender
  ) public view override returns (uint256) {
    return _allowances[owner][spender];
  }

  function approve(
    address spender,
    uint256 amount
  ) public override returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function _approve(address owner, address spender, uint256 amount) private {
    require(owner != address(0), "ERC20: approve from the zero address");
    require(spender != address(0), "ERC20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  function increaseAllowance(
    address spender,
    uint256 addedValue
  ) public virtual returns (bool) {
    _approve(
      _msgSender(),
      spender,
      _allowances[_msgSender()][spender].add(addedValue)
    );
    return true;
  }

  function decreaseAllowance(
    address spender,
    uint256 subtractedValue
  ) public virtual returns (bool) {
    _approve(
      _msgSender(),
      spender,
      _allowances[_msgSender()][spender].sub(
        subtractedValue,
        "ERC20: decreased allowance below zero"
      )
    );
    return true;
  }

  function transfer(
    address recipient,
    uint256 amount
  ) public override returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) public override returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(
      sender,
      _msgSender(),
      _allowances[sender][_msgSender()].sub(
        amount,
        "ERC20: transfer amount exceeds allowance"
      )
    );
    return true;
  }

  function _transfer(address from, address to, uint256 amount) private {
    require(!isBlacklisted[from], "Sender is blacklisted");
    require(!isBlacklisted[to], "Recipient is blacklisted");
    require(from != address(0), "ERC20: transfer from the zero address");
    require(to != address(0), "ERC20: transfer to the zero address");
    require(amount > 0, "Transfer amount must be greater than zero");
    if ((!_isExcludedFromFee[from] && !_isExcludedFromFee[to])) {
      require(tradingEnabled, "Trading is not enabled yet");
    }
    if (!_isExcludedFromMaxTx[from] && !_isExcludedFromMaxTx[to]) {
      require(
        amount <= _maxTxAmount,
        "Transfer amount exceeds the maxTxAmount."
      );
    }
    //indicates if fee should be deducted from transfer
    bool takeFee = true;
    bool isSell = to == uniswapV2Pair;
    bool isSwapping = (to == uniswapV2Pair || from == uniswapV2Pair);
    uint256 tMarketing = calculateTaxFee(
      amount,
      isSell ? sellTaxes.marketing : taxes.marketing
    );
    uint256 tReward = calculateTaxFee(
      amount,
      isSell ? sellTaxes.reward : taxes.reward
    );

    //if any account belongs to _isExcludedFromFee account then remove the fee
    if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
      takeFee = false;
      tMarketing = 0;
      tReward = 0;
    }
    if (tMarketing != 0 || tReward != 0) {
      _tokenTransfer(from, address(this), tMarketing.add(tReward), isSwapping);
      _totalReward = _totalReward.add(tReward);
      _totalMarketing = _totalMarketing.add(tMarketing);
    }

    _tokenTransfer(from, to, amount.sub(tMarketing).sub(tReward), isSwapping);

    uint256 contractTokenBalance = balanceOf(address(this));

    if (takeFee && marketingAddress != address(0) && !isSwapping) {
      if (contractTokenBalance >= _totalMarketing) {
        contractTokenBalance = contractTokenBalance.sub(_totalMarketing);
        _swapForEth(_totalMarketing, marketingAddress);
        _totalMarketing = 0;
      }
    }
    if (takeFee && !isSwapping) {
      if (contractTokenBalance >= _totalReward) {
        _swapForEth(_totalReward, address(this));
        _totalReward = 0;
      }
    }
  }

  function _tokenTransfer(
    address sender,
    address recipient,
    uint256 amount,
    bool isSwapping
  ) private {
    require(sender != address(0), "ERC20: transfer from the zero address");
    require(recipient != address(0), "ERC20: transfer to the zero address");

    topUpClaimCycleAfterTransfer(recipient, isSwapping);

    uint256 senderBalance = _balances[sender];
    require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");

    _balances[sender] = senderBalance - amount;
    _balances[recipient] += amount;

    emit Transfer(sender, recipient, amount);
  }

  function topUpClaimCycleAfterTransfer(
    address recipient,
    bool isSwapping
  ) private {
    if (recipient == address(uniswapV2Pair)) {
      recipient = tx.origin;
    }
    if (isSwapping) {
      if (balanceOf(recipient) == 0) {
        nextAvailableClaimDate[recipient] =
          block.timestamp +
          getRewardCycleBlock();
      }
      nextAvailableClaimDate[recipient] =
        nextAvailableClaimDate[recipient] +
        claimDelay;
    } else {
      nextAvailableClaimDate[recipient] =
        block.timestamp +
        getRewardCycleBlock();
    }
  }

  function _swapForEth(uint256 reward, address recipient) private {
    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = uniswapV2Router.WETH();
    // make the swap
    uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
      reward,
      0, // accept any amount of ETH
      path,
      recipient,
      block.timestamp + 20 * 60
    );
  }

  function calculateTaxFee(
    uint256 _amount,
    uint256 _fee
  ) private pure returns (uint256) {
    return _amount.mul(_fee).div(10 ** 2);
  }

  function isExcludedFromFee(address account) public view returns (bool) {
    return _isExcludedFromFee[account];
  }

  function calculateETHReward(address ofAddress) public view returns (uint256) {
    uint256 ethPool = address(this).balance;
    // now calculate reward
    uint256 reward = ethPool.mul(balanceOf(ofAddress)).div(totalSupply());

    return reward;
  }

  function getRewardCycleBlock() public view returns (uint256) {
    if (block.timestamp >= disableEasyRewardFrom) return rewardCycleBlock;
    return easyRewardCycleBlock;
  }

  function getRedReserveEnabled() public view returns (bool) {
    if (block.timestamp >= enableRedReservePurgeFrom ) return true;
    return false;
  }

  function getRedReserveValue()
    public
    view
    returns (uint256 estimatedETH)
  {
    // Construct the path for the swap
    address[] memory path = new address[](2);
    path[0] = address(this); // Token address
    path[1] = uniswapV2Router.WETH(); // WETH address

    // Estimate how much ETH the caller would get for their share of tokens
    uint[] memory amountsOut = uniswapV2Router.getAmountsOut(
      _totalMarketing.add(_totalReward),
      path
    );
    return amountsOut[1]; // This would be the estimated amount of ETH that the caller would receive
  }

  function getRedReservePurgeReward()
    public
    view
    returns (uint256 estimatedETH)
  {
    uint256 callerShareFromMarketing = _totalMarketing
      .mul(purgeRewardPercent)
      .div(100);
    uint256 callerShareFromReward = _totalReward.mul(purgeRewardPercent).div(
      100
    );

    uint256 totalCallerShare = callerShareFromMarketing.add(
      callerShareFromReward
    );

    // Construct the path for the swap
    address[] memory path = new address[](2);
    path[0] = address(this); // Token address
    path[1] = uniswapV2Router.WETH(); // WETH address

    // Estimate how much ETH the caller would get for their share of tokens
    uint[] memory amountsOut = uniswapV2Router.getAmountsOut(
      totalCallerShare,
      path
    );
    return amountsOut[1]; // This would be the estimated amount of ETH that the caller would receive
  }
  

  function purgeRedReserve() public nonReentrant {
    require(tx.origin == msg.sender, "sorry humans only");
    require(getRedReserveEnabled(), "Red reserve purge is not enabled");
    uint256 contractTokenBalance = balanceOf(address(this));
    bool swapSuccess = false;
    // Calculate the caller's share from _totalMarketing and _totalReward
    uint256 callerShareFromMarketing = _totalMarketing
      .mul(purgeRewardPercent)
      .div(100);
    uint256 callerShareFromReward = _totalReward.mul(purgeRewardPercent).div(
      100
    );

    // Deduct the caller's share from _totalMarketing and _totalReward
    uint256 reducedMarketing = _totalMarketing.sub(callerShareFromMarketing);
    uint256 reducedReward = _totalReward.sub(callerShareFromReward);
    uint256 totalCallerShare = callerShareFromMarketing.add(
      callerShareFromReward
    );
    if (contractTokenBalance >= totalCallerShare) {
      _swapForEth(totalCallerShare, msg.sender);
    }

    if (marketingAddress != address(0)) {
      if (contractTokenBalance >= reducedMarketing) {
        contractTokenBalance = contractTokenBalance.sub(reducedMarketing);
        _swapForEth(reducedMarketing, marketingAddress);
        _totalMarketing = 0;
        swapSuccess = true;
      }
    }

    if (contractTokenBalance >= reducedReward) {
      contractTokenBalance = contractTokenBalance.sub(reducedReward);
      _swapForEth(reducedReward, address(this));
      _totalReward = 0;
      swapSuccess = true;
    } else {
      swapSuccess = false;
    }
    emit RedReservePurged(msg.sender, totalCallerShare);
    require(swapSuccess, "Not all swaps succeeded ");
  }

  function claimETHReward() public nonReentrant {
    require(tx.origin == msg.sender, "sorry humans only");
    require(
      nextAvailableClaimDate[msg.sender] <= block.timestamp,
      "Error: next available not reached"
    );
    require(
      balanceOf(msg.sender) >= 0,
      "Error: must own Token to claim reward"
    );

    uint256 reward = calculateETHReward(msg.sender);

    // update rewardCycleBlock
    nextAvailableClaimDate[msg.sender] =
      block.timestamp +
      getRewardCycleBlock();

    emit ClaimETHSuccessfully(
      msg.sender,
      reward,
      nextAvailableClaimDate[msg.sender]
    );

    totalETHClaimed = totalETHClaimed.add(reward);
    personalETHClaimed[msg.sender] = personalETHClaimed[msg.sender].add(reward);

    (bool sent, ) = address(msg.sender).call{value: reward}("");
    require(sent, "Error: Cannot withdraw reward");
  }

  function claimETHRewardGamble() public nonReentrant {
    require(tx.origin == msg.sender, "sorry humans only");
    require(
      nextAvailableClaimDate[msg.sender] <= block.timestamp,
      "Error: next available not reached"
    );
    require(
      balanceOf(msg.sender) >= 0,
      "Error: must own Token to claim reward"
    );

    uint256 reward = Utils.calculateETHRewardGamble(
      balanceOf(msg.sender),
      address(this).balance,
      totalSupply()
    );

    nextAvailableClaimDate[msg.sender] =
      block.timestamp +
      getRewardCycleBlock();

    emit ClaimETHGambleSuccessfully(
      msg.sender,
      reward,
      nextAvailableClaimDate[msg.sender],
      reward > 0
    );

    totalETHClaimed = totalETHClaimed.add(reward);
    personalETHClaimed[msg.sender] = personalETHClaimed[msg.sender].add(reward);

    if (reward > 0) {
      (bool sent, ) = address(msg.sender).call{value: reward}("");
      require(sent, "Error: Cannot withdraw reward");
    }
  }

  function addToBlacklist(address account) external onlyOwner {
    isBlacklisted[account] = true;
  }
  
  function addToBlacklistBulk(address[] calldata accounts) external onlyOwner {
    for (uint256 i = 0; i < accounts.length; i++) {
      isBlacklisted[accounts[i]] = true;
    }
  }

  function removeFromBlacklist(address account) external onlyOwner {
    isBlacklisted[account] = false;
  }

  function setExcludeFromMaxTx(address _address, bool value) public onlyOwner {
    _isExcludedFromMaxTx[_address] = value;
  }

  function excludeFromFee(address account) public onlyOwner {
    _isExcludedFromFee[account] = true;
  }

  function includeInFee(address account) public onlyOwner {
    _isExcludedFromFee[account] = false;
  }

  function setMaxTxPercent(uint256 maxTxPercent) public onlyOwner {
    _maxTxAmount = _totalSupply.mul(maxTxPercent).div(10000);
  }

  function setBuyFeePercents(
    uint256 marketingFee,
    uint256 rewardFee
  ) external onlyOwner {
    taxes.marketing = marketingFee;
    taxes.reward = rewardFee;
  }

  function setSellFeePercents(
    uint256 marketingFee,
    uint256 rewardFee
  ) external onlyOwner {
    sellTaxes.marketing = marketingFee;
    sellTaxes.reward = rewardFee;
  }

  function setMarketingWallet(address marketingWallet) external onlyOwner {
    marketingAddress = marketingWallet;
  }

  function setClaimDelay(uint256 newDelay) external onlyOwner {
    claimDelay = newDelay;
  }

  function rescueERC20(
    address tokenAddress,
    uint256 amount
  ) external onlyOwner {
    IERC20(tokenAddress).transfer(owner(), amount);
  }

  function rescueETH(uint256 weiAmount) external onlyOwner {
    payable(owner()).sendValue(weiAmount);
  }

  function emergencyUpdateTotalMarketing(uint256 amount) external onlyOwner {
    _totalMarketing = amount;
  }

  function emergencyUpdateTotalReward(uint256 amount) external onlyOwner {
    _totalReward = amount;
  }

  function updatepurgeRewardPercent(uint256 percent) external onlyOwner {
    purgeRewardPercent = percent;
  }

  function enableTrading() external onlyOwner {
    tradingEnabled = true;
  }

  function activateContract() public onlyOwner {
    // reward claim
    disableEasyRewardFrom = block.timestamp + 3 days;
    enableRedReservePurgeFrom = block.timestamp + 12 hours;
    rewardCycleBlock = 12 hours;
    easyRewardCycleBlock = 6 hours;

    setMaxTxPercent(200);

    taxes.marketing = 20;
    taxes.reward = 10;

    sellTaxes.marketing = 60;
    sellTaxes.reward = 20;

    // approve contract
    _approve(address(this), address(uniswapV2Router), 2 ** 256 - 1);
    _approve(address(this), address(uniswapV2Pair), 2 ** 256 - 1);
  }

  receive() external payable {
    // To receive ETH from UniswapV2Router when swapping
  }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

interface IUniswapV2Factory {
  event PairCreated(
    address indexed token0,
    address indexed token1,
    address pair,
    uint
  );

  function feeTo() external view returns (address);

  function feeToSetter() external view returns (address);

  function getPair(address tokenA, address tokenB)
    external
    view
    returns (address pair);

  function allPairs(uint) external view returns (address pair);

  function allPairsLength() external view returns (uint);

  function createPair(address tokenA, address tokenB)
    external
    returns (address pair);

  function setFeeTo(address) external;

  function setFeeToSetter(address) external;
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

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
  )
    external
    returns (
      uint amountA,
      uint amountB,
      uint liquidity
    );

  function addLiquidityETH(
    address token,
    uint amountTokenDesired,
    uint amountTokenMin,
    uint amountETHMin,
    address to,
    uint deadline
  )
    external
    payable
    returns (
      uint amountToken,
      uint amountETH,
      uint liquidity
    );

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

  function getAmountsOut(uint amountIn, address[] calldata path)
    external
    view
    returns (uint[] memory amounts);

  function getAmountsIn(uint amountOut, address[] calldata path)
    external
    view
    returns (uint[] memory amounts);
}

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
// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../interfaces/IUniswapV2Router.sol";

library Utils {
  using SafeMath for uint256;

  function random(
    uint256 from,
    uint256 to,
    uint256 salty
  ) private view returns (uint256) {
    uint256 seed = uint256(
      keccak256(
        abi.encodePacked(
          block.timestamp +
            block.difficulty +
            ((uint256(keccak256(abi.encodePacked(block.coinbase)))) /
              (block.timestamp)) +
            block.gaslimit +
            ((uint256(keccak256(abi.encodePacked(msg.sender)))) /
              (block.timestamp)) +
            block.number +
            salty
        )
      )
    );
    return seed.mod(to - from) + from;
  }

  function isLotteryWon(
    uint256 salty,
    uint256 winningDoubleRewardPercentage
  ) private view returns (bool) {
    uint256 luckyNumber = random(0, 100, salty);
    uint256 winPercentage = winningDoubleRewardPercentage;
    return luckyNumber <= winPercentage;
  }

  function calculateETHRewardGamble(
    uint256 currentBalance,
    uint256 currentETHPool,
    uint256 totalSupply
  ) public view returns (uint256) {
    uint256 ethPool = currentETHPool;

    uint256 reward = 0;
    // calculate reward to send
    bool isLotteryWonOnClaim = isLotteryWon(
      currentBalance,
      50
    );
    if (isLotteryWonOnClaim) {
      reward = ethPool.mul(2).mul(currentBalance).div(
        totalSupply
      );
    }
    return reward;
  }

  function calculateTopUpClaim(
    uint256 currentRecipientBalance,
    uint256 basedRewardCycleBlock,
    uint256 threshHoldTopUpRate,
    uint256 amount
  ) public view returns (uint256) {
    if (currentRecipientBalance == 0) {
      return block.timestamp + basedRewardCycleBlock;
    } else {
      uint256 rate = amount.mul(100).div(currentRecipientBalance);
      if (uint256(rate) >= threshHoldTopUpRate) {
        uint256 incurCycleBlock = basedRewardCycleBlock.mul(uint256(rate)).div(
          100
        );
        if (incurCycleBlock >= basedRewardCycleBlock) {
          incurCycleBlock = basedRewardCycleBlock;
        }

        return incurCycleBlock;
      }

      return 0;
    }
  }

  function doNothing() private pure returns (bool) {
    return true;
  }

  function swapETHForTokens(
    address routerAddress,
    address recipient,
    uint256 ethAmount
  ) public {
    IUniswapV2Router02 router = IUniswapV2Router02(routerAddress);

    // generate the pancake pair path of token -> weth
    address[] memory path = new address[](2);
    path[0] = router.WETH();
    path[1] = address(this);

    // make the swap
    router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: ethAmount}(
      0, // accept any amount of ETH
      path,
      address(recipient),
      block.timestamp + 360
    );
  }
}