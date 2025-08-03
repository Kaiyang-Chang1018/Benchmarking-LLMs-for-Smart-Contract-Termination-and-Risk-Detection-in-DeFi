/*
* Security Contact: support@storme.io
*/

// SPDX-License-Identifier: MIT

pragma solidity =0.8.7;

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
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
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

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
}

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
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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

contract OwnerWithdrawable is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    receive() external payable {}

    fallback() external payable {}

    function withdraw(address token, uint256 amt) public onlyOwner {
        IERC20(token).safeTransfer(msg.sender, amt);
    }

    function withdrawAll(address token) public onlyOwner {
        uint256 amt = IERC20(token).balanceOf(address(this));
        withdraw(token, amt);
    }

    function withdrawCurrency(uint256 amt) public onlyOwner {
        payable(msg.sender).transfer(amt);
    }

    // function deposit(address token, uint256 amt) public onlyOwner {
    //     uint256 allowance = IERC20(token).allowance(msg.sender, address(this));
    //     require(allowance >= amt, "Check the token allowance");
    //     IERC20(token).transferFrom(owner(), address(this), amt);
    // }
}

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
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
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

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

contract StormePresale is OwnerWithdrawable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using SafeERC20 for IERC20Metadata;

    uint256 public rate;
    address public saleToken;
    uint public saleTokenDec;
    uint256 public totalTokensforSale;
    uint256 public maxBuyLimit = 7_918_825_433 * 10**18; // 1% 
    uint256 public minBuyLimit = 0;
    address public presaleWallet = 0x60004297d3128f07deb5E04f7e3434f49Ebc8A7e;
    //address public DAI = 0x3Cf204795c4995cCf9C1a0B3191F00c01B03C56C; // testnet
    address public DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F; // mainnet

    // Whitelist of tokens to buy from
    mapping(address => bool) public tokenWL;

    // 1 Token price in terms of WL tokens
    mapping(address => uint256) public tokenPrices;

    address[] public buyers;

    bool public isUnlockingStarted;
    bool public isPresaleStarted;
    uint public presalePhase;
    
    mapping(address => BuyerTokenDetails) public buyersAmount;
    mapping(address => uint256) public presaleData;

    uint256 public totalTokensSold;

    struct BuyerTokenDetails {
        uint amount;
        bool isClaimed;
        uint256 distribution1;
        uint256 distribution2;
        uint256 distribution3;
        uint256 distribution4;
    }

    struct Stage {
        uint256 endTime;
        uint256 ethPrice; // price per token in wei
        uint256 tokenPrice;  // price per token in wei
        uint256 tokensAvailable; // tokens available for sale in this stage
        uint256 tokensSold;
    }

    Stage[45] public stages;
    uint256 public currentStage;

    uint256 public unlockTime;

    constructor() {
        // Initialize the stages - Total for presale 197,970,635,836 STORME at 1 ETH = $2550
        stages[0] = Stage(1723326659, 0.0000000087 ether, 0.0000222 ether, 45_045_045_045 * 10**18, 0);
        stages[1] = Stage(1723326779, 0.0000000174 ether, 0.0000444 ether, 22_522_522_523 * 10**18, 0);
        stages[2] = Stage(1723326899, 0.0000000261 ether, 0.0000666 ether, 15_015_015_015 * 10**18, 0);
        stages[3] = Stage(1723326899, 0.0000000348 ether, 0.0000888 ether, 11_261_261_261 * 10**18, 0);
        stages[4] = Stage(1723326899, 0.0000000435 ether, 0.0001110 ether, 9_009_009_009 * 10**18, 0);
        stages[5] = Stage(1723326899, 0.0000000522 ether, 0.0001332 ether, 7_507_507_508 * 10**18, 0);
        stages[6] = Stage(1723326899, 0.0000000609 ether, 0.0001554 ether, 6_435_006_436 * 10**18, 0);
        stages[7] = Stage(1723326899, 0.0000000696 ether, 0.0001776 ether, 5_630_630_631 * 10**18, 0);
        stages[8] = Stage(1723326899, 0.0000000784 ether, 0.0001998 ether, 5_005_005_005 * 10**18, 0);
        stages[9] = Stage(1723326899, 0.0000000871 ether, 0.0002220 ether, 4_504_504_505 * 10**18, 0);
        stages[10] = Stage(1723326899, 0.0000000958 ether, 0.0002442 ether, 4_095_004_095 * 10**18, 0);
        stages[11] = Stage(1723326899, 0.0000001045 ether, 0.0002664 ether, 3_753_753_754 * 10**18, 0);
        stages[12] = Stage(1723326899, 0.0000001132 ether, 0.0002886 ether, 3_465_003_465 * 10**18, 0);
        stages[13] = Stage(1723326899, 0.0000001219 ether, 0.0003108 ether, 3_217_503_218 * 10**18, 0);
        stages[14] = Stage(1723326899, 0.0000001306 ether, 0.0003330 ether, 3_003_003_003 * 10**18, 0);
        stages[15] = Stage(1723326899, 0.0000001393 ether, 0.0003552 ether, 2_815_315_315 * 10**18, 0);
        stages[16] = Stage(1723326899, 0.0000001480 ether, 0.0003774 ether, 2_649_709_650 * 10**18, 0);
        stages[17] = Stage(1723326899, 0.0000001567 ether, 0.0003996 ether, 2_502_502_503 * 10**18, 0);
        stages[18] = Stage(1723326899, 0.0000001654 ether, 0.0004218 ether, 2_370_792_371 * 10**18, 0);
        stages[19] = Stage(1723326899, 0.0000001741 ether, 0.0004440 ether, 2_252_252_252 * 10**18, 0);
        stages[20] = Stage(1723326899, 0.0000001828 ether, 0.0004662 ether, 2_145_002_145 * 10**18, 0);
        stages[21] = Stage(1723326899, 0.0000001915 ether, 0.0004884 ether, 2_047_502_048 * 10**18, 0);
        stages[22] = Stage(1723326899, 0.0000002002 ether, 0.0005106 ether, 1_958_480_244 * 10**18, 0);
        stages[23] = Stage(1723326899, 0.0000002089 ether, 0.0005328 ether, 1_876_876_877 * 10**18, 0);
        stages[24] = Stage(1723326899, 0.0000002176 ether, 0.0005550 ether, 1_801_801_802 * 10**18, 0);
        stages[25] = Stage(1723326899, 0.0000002264 ether, 0.0005772 ether, 1_732_502_174 * 10**18, 0);
        stages[26] = Stage(1723326899, 0.0000002351 ether, 0.0005994 ether, 1_668_334_950 * 10**18, 0);
        stages[27] = Stage(1723326899, 0.0000002438 ether, 0.0006216 ether, 1_608_751_876 * 10**18, 0);
        stages[28] = Stage(1723326899, 0.0000002525 ether, 0.0006438 ether, 1_553_276_977 * 10**18, 0);
        stages[29] = Stage(1723326899, 0.0000002612 ether, 0.0006660 ether, 1_501_501_502 * 10**18, 0);
        stages[30] = Stage(1723326899, 0.0000002699 ether, 0.0006882 ether, 1_453_066_667 * 10**18, 0);
        stages[31] = Stage(1723326899, 0.0000002786 ether, 0.0007104 ether, 1_407_657_658 * 10**18, 0);
        stages[32] = Stage(1723326899, 0.0000002873 ether, 0.0007326 ether, 1_365_000_683 * 10**18, 0);
        stages[33] = Stage(1723326899, 0.0000002960 ether, 0.0007548 ether, 1_324_853_522 * 10**18, 0);
        stages[34] = Stage(1723326899, 0.0000003047 ether, 0.0007770 ether, 1_287_001_287 * 10**18, 0);
        stages[35] = Stage(1723326899, 0.0000003134 ether, 0.0007992 ether, 1_251_251_251 * 10**18, 0);
        stages[36] = Stage(1723326899, 0.0000003221 ether, 0.0008214 ether, 1_217_434_469 * 10**18, 0);
        stages[37] = Stage(1723326899, 0.0000003308 ether, 0.0008436 ether, 1_185_396_040 * 10**18, 0);
        stages[38] = Stage(1723326899, 0.0000003395 ether, 0.0008658 ether, 1_155_001_156 * 10**18, 0);
        stages[39] = Stage(1723326899, 0.0000003482 ether, 0.0008880 ether, 1_126_126_126 * 10**18, 0);
        stages[40] = Stage(1723326899, 0.0000003569 ether, 0.0009102 ether, 1_098_659_854 * 10**18, 0);
        stages[41] = Stage(1723326899, 0.0000003656 ether, 0.0009324 ether, 1_072_501_073 * 10**18, 0);
        stages[42] = Stage(1723326899, 0.0000003744 ether, 0.0009546 ether, 1_047_558_817 * 10**18, 0);
        stages[43] = Stage(1723326899, 0.0000003831 ether, 0.0009768 ether, 1_023_751_024 * 10**18, 0);
        stages[44] = Stage(1723326899, 0.0000003918 ether, 0.0009990 ether, 1_001_001_001 * 10**18, 0);

        currentStage = 0;

        totalTokensforSale = stages[currentStage].tokensAvailable;
        tokenWL[DAI] = true;
        rate = stages[currentStage].ethPrice;
        tokenPrices[DAI] = stages[currentStage].tokenPrice;
     }

    modifier saleStarted(){
        require (!isPresaleStarted, "PreSale: Sale has already started");
        _;
    }

    function updateNextStage() public onlyOwner{
        currentStage = currentStage.add(1);
        tokenPrices[DAI] = stages[currentStage].tokenPrice;
        rate = stages[currentStage].ethPrice;
        totalTokensSold = 0;
        totalTokensforSale = stages[currentStage].tokensAvailable;
    }

    function updateEthPrice(uint256 _phaseId, uint256 _pricePerToken)
        public
        onlyOwner
    {
        stages[_phaseId].tokenPrice = _pricePerToken;
    }

    function updatePrice(uint256 _phaseId, uint256 _pricePerToken)
        public
        onlyOwner
    {
        stages[_phaseId].tokenPrice = _pricePerToken;
    }

    //function to set information of Token sold in Pre-Sale and its rate in Native currency
    function setSaleTokenParams(
        address _saleToken
    ) external onlyOwner saleStarted{
        saleToken = _saleToken;
        saleTokenDec = IERC20Metadata(saleToken).decimals();
    }

    // Add a token to buy presale token from, with price
    function addWhiteListedToken(
        address _token
    ) external onlyOwner {
        tokenWL[_token] = true;
        tokenPrices[_token] = stages[currentStage].tokenPrice;
    }

    function updateEthRate(uint256 _rate) external  onlyOwner {
        rate = _rate;
    }

    function updateTokenRate(
        address _token,
        uint256 _price
    )external onlyOwner{
        require(tokenWL[_token], "Presale: Token not whitelisted");
        require(_price != 0, "Presale: Cannot set price to 0");
        tokenPrices[_token] = _price;
    }

    function startPresale() external onlyOwner {
        require(!isPresaleStarted, "PreSale: Sale has already started");
        isPresaleStarted = true;
    }

    function stopPresale() external onlyOwner {
        require(isPresaleStarted, "PreSale: Sale hasn't started yet!");
        isPresaleStarted = false;
    }

    function startUnlocking() external onlyOwner {
        require(!isUnlockingStarted, "PreSale: Unlocking has already started");
        isUnlockingStarted = true;
        unlockTime = block.timestamp;
    }

    function stopUnlocking() external onlyOwner {
        require(isUnlockingStarted, "PreSale: Unlocking hasn't started yet!");
        isUnlockingStarted = false;
    }

    // Public view function to calculate amount of sale tokens returned if you buy using "amount" of "token"
    function getTokenAmount(address token, uint256 amount)
        public
        view
        returns (uint256)
    {
        if(!isPresaleStarted) {
            return 0;
        }
        uint256 amtOut;
        if(token != address(0)){
            require(tokenWL[token] == true, "Presale: Token not whitelisted");
            uint256 price = stages[currentStage].tokenPrice;
            amtOut = amount.mul(10**saleTokenDec).div(price);
        }
        else{
            uint256 priceEth = stages[currentStage].ethPrice;
            amtOut = amount.mul(10**saleTokenDec).div(priceEth);
        }
        return amtOut;
    }

    // Public Function to buy tokens. APPROVAL needs to be done first
    function buyToken(address _token, uint256 _amount) external payable{
        require(isPresaleStarted, "PreSale: Sale stopped!");
    
        uint256 saleTokenAmt;
        if(_token != address(0)){
            require(_amount > 0, "Presale: Cannot buy with zero amount");
            require(tokenWL[_token] == true, "Presale: Token not whitelisted");

            saleTokenAmt = getTokenAmount(_token, _amount);

            // check if saleTokenAmt is greater than minBuyLimit
            require(saleTokenAmt >= minBuyLimit, "Presale: Min buy limit not reached");
            require(presaleData[msg.sender] + saleTokenAmt <= maxBuyLimit, "Presale: Max buy limit reached for this phase");
            //require((totalTokensSold + saleTokenAmt) <= totalTokensforSale, "PreSale: Total Token Sale Reached!");
            require((stages[currentStage].tokensSold + saleTokenAmt) <= stages[currentStage].tokensAvailable, "PreSale: Total Token Sale Reached!");

            IERC20(_token).safeTransferFrom(msg.sender, presaleWallet, _amount);
        }
        else{
            saleTokenAmt = getTokenAmount(address(0), msg.value);

            // check if saleTokenAmt is greater than minBuyLimit
            require(saleTokenAmt >= minBuyLimit, "Presale: Min buy limit not reached");
            require(presaleData[msg.sender] + saleTokenAmt <= maxBuyLimit, "Presale: Max buy limit reached for this phase");
            //require((totalTokensSold + saleTokenAmt) <= totalTokensforSale, "PreSale: Total Token Sale Reached!");
            require((stages[currentStage].tokensSold + saleTokenAmt) <= stages[currentStage].tokensAvailable, "PreSale: Total Token Sale Reached!");

            payable(presaleWallet).transfer(_amount);
        }

        //IERC20(saleToken).safeTransfer(msg.sender, saleTokenAmt); // To allow investor to receive tokens on purchase
 
        totalTokensSold += saleTokenAmt;
        stages[currentStage].tokensSold += saleTokenAmt;
        buyersAmount[msg.sender].amount += saleTokenAmt;
        presaleData[msg.sender] += saleTokenAmt; 
        /*
        if (stages[currentStage].tokensAvailable == 0 || block.timestamp > stages[currentStage].endTime) {
            currentStage = currentStage.add(1);
            stages[currentStage].tokensSold = 0;
            if(_token != address(0)){
                tokenPrices[DAI] = stages[currentStage].tokenPrice;
            } else {
                rate = stages[currentStage].ethPrice;
            }
        }
        */
        buyersAmount[msg.sender].distribution1 += saleTokenAmt / 4;
        buyersAmount[msg.sender].distribution2 += saleTokenAmt / 4;
        buyersAmount[msg.sender].distribution3 += saleTokenAmt / 4;
        buyersAmount[msg.sender].distribution4 += saleTokenAmt / 4;
    }

    function claimPurchasedTokens() external {
        uint256 tokensforWithdraw;
        require(buyersAmount[msg.sender].isClaimed == false, "Presale: Already claimed");
        require(isUnlockingStarted, "Presale: Locking period not over yet");
        tokensforWithdraw = buyersAmount[msg.sender].amount;

        if (unlockTime < block.timestamp + 7 days) {
            require(isUnlockingStarted, "Presale: Locking period not over yet");
        } else if (unlockTime >= block.timestamp + 7 days) {
            tokensforWithdraw = buyersAmount[msg.sender].distribution1;
        } else if (unlockTime >= block.timestamp + 30 days) {
            tokensforWithdraw = buyersAmount[msg.sender].distribution2;
        } else if (unlockTime >= block.timestamp + 60 days) {
            tokensforWithdraw = buyersAmount[msg.sender].distribution3;
        } else if (unlockTime >= block.timestamp + 90 days) {
            tokensforWithdraw = buyersAmount[msg.sender].distribution4;
        } else {
            tokensforWithdraw = buyersAmount[msg.sender].distribution1 + buyersAmount[msg.sender].distribution2 + buyersAmount[msg.sender].distribution3 + buyersAmount[msg.sender].distribution4;
        }

        if (tokensforWithdraw == 0) {
            buyersAmount[msg.sender].isClaimed = true;
        }

        //buyersAmount[msg.sender].isClaimed = true;
        IERC20(saleToken).safeTransfer(msg.sender, tokensforWithdraw);
    }

    function changeClaim (address _investorsWallet, bool _value ) public onlyOwner {
        buyersAmount[_investorsWallet].isClaimed = _value;
    }

    function setMinBuyLimit(uint _minBuyLimit) external onlyOwner {
        minBuyLimit = _minBuyLimit;
    }

    function setMaxBuyLimit(uint _maxBuyLimit) external onlyOwner {
        maxBuyLimit = _maxBuyLimit;
    }

    function updatePresaleWallet(address wallet) external onlyOwner {
        require(wallet != presaleWallet, "Address is already presale wallet");
        presaleWallet = wallet;
     }
}