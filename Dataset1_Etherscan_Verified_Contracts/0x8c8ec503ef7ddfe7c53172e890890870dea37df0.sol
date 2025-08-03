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
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20.sol";
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
pragma solidity >=0.5.0;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}
// SPDX-License-Identifier: NONE
pragma solidity ^0.8.15;


/**
 * @title vETH
 * @author Riley - Two Brothers Crypto (riley@twobrotherscrypto.dev)
 * @notice Holds Ethereum on behalf of end users to be used in ToadSwap operations without subsequent approvals being required.
 * In essence, a privileged version of WETH9. Implements the WETH9 spec, but with extra functions.
 */
abstract contract IvETH {



    function balanceOf(address account) public virtual view returns (uint);

    function deposit() external virtual payable;

    function withdraw(uint wad) public virtual;

    function convertFromWETH9(uint256 amount, address recipient) external virtual;

    function convertToWETH9(uint256 amount, address recipient) external virtual;

    function addToFullApproval(address account) external virtual;

    function removeFromFullApproval(address account) external virtual;

    /**
     * Performs a WETH9->vETH conversion with pre-deposited WETH9
     * @param amount amount to convert 
     * @param recipient recipient to credit
     */
    function approvedConvertFromWETH9(uint256 amount, address recipient) external virtual;
    /**
     * Performs a vETH->WETH9 conversion on behalf of a user. Approved contracts only.
     * @param user user to perform on behalf of
     * @param amount amount to convert
     * @param recipient recipient wallet to send to
     */
    function approvedConvertToWETH9(address user, uint256 amount, address recipient) external virtual;
    /**
     * Performs a withdrawal on behalf of a user. Approved contracts only.
     * @param user user to perform on behalf of
     * @param amount amount to withdraw
     * @param recipient recipient wallet to send to
     */
    function approvedWithdraw(address user, uint256 amount, address recipient) external virtual;

    function approvedTransferFrom(address user, uint256 amount, address recipient) external virtual;

    function transfer(address to, uint value) public virtual;


}
// SPDX-License-Identifier: NONE
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IWETH.sol";
import "./IvETH.sol";

/**
 * @title vETH
 * @author Riley - Two Brothers Crypto (riley@twobrotherscrypto.dev)
 * @notice Holds Ethereum on behalf of end users to be used in ToadSwap operations without subsequent approvals being required.
 * In essence, a privileged version of WETH9. Implements the WETH9 spec, but with extra functions.
 */
contract vETH is Ownable, IvETH {

    mapping(address => uint256) amounts;

    mapping(address => bool) fullApprovals;

    address public immutable WETH9;

    modifier onlyApproved {
        require(fullApprovals[msg.sender], "Not approved.");
        _;
    }

    constructor(address weth) {
        WETH9 = weth;
        
    }
    receive() external payable {
        // Attempt to reject contracts from sending ETH
        require(!Address.isContract(msg.sender), "Contracts cannot deposit to vETH via receive fallback.");
        amounts[msg.sender] += msg.value;
    }

    function balanceOf(address account) public view override returns (uint) {
        return amounts[account];
    }

    function deposit() external payable override {
        // Allow contracts to send ETH via this method, because if you're doing this you should know how to withdraw (and this technically fulfils the IWETH interface)
        amounts[msg.sender] += msg.value;
    }

    function withdraw(uint wad) public override {
        // Because of Solidity 0.8 SafeMath we can require then do an unchecked subtract
        require(amounts[msg.sender] >= wad, "Not enough balance to withdraw.");
        unchecked {
            amounts[msg.sender] -= wad;
        }
        // Use Address senders 
        Address.sendValue(payable(msg.sender), wad);
    }

    function convertFromWETH9(uint256 amount, address recipient) external override {
        bool resp = IERC20(WETH9).transferFrom(msg.sender, address(this), amount);
        require(resp, "Failed to transfer.");
        // Withdraw
        IWETH(WETH9).withdraw(amount);
        // Now add the correct amount to balance
        amounts[recipient] += amount;
    }

    function convertToWETH9(uint256 amount, address recipient) external override {
        // Subtract balance now
        require(amounts[msg.sender] >= amount, "Not enough balance to withdraw.");
        unchecked {
            amounts[msg.sender] -= amount;
        }
        // Deposit into WETH9
        IWETH(WETH9).deposit{value: amount}();
        // Send to recipient
        bool resp = IERC20(WETH9).transfer(recipient, amount);
        require(resp, "Failed to transfer.");
    }

    function addToFullApproval(address account) external override onlyOwner {
        fullApprovals[account] = true;
    }

    function removeFromFullApproval(address account) external override onlyOwner {
        fullApprovals[account] = false;
    }

    /**
     * Performs a WETH9->vETH conversion with pre-deposited WETH9
     * @param amount amount to convert 
     * @param recipient recipient to credit
     */
    function approvedConvertFromWETH9(uint256 amount, address recipient) external override onlyApproved {
        IERC20 w9 = IERC20(WETH9);
        require(w9.balanceOf(address(this)) >= amount, "Can't convert what we don't have.");
        IWETH(WETH9).withdraw(amount);
        amounts[recipient] += amount; 
    }
    /**
     * Performs a vETH->WETH9 conversion on behalf of a user. Approved contracts only.
     * @param user user to perform on behalf of
     * @param amount amount to convert
     * @param recipient recipient wallet to send to
     */
    function approvedConvertToWETH9(address user, uint256 amount, address recipient) external override onlyApproved {
        // Subtract balance now
        require(amounts[user] >= amount, "Not enough balance to withdraw.");
        unchecked {
            amounts[user] -= amount;
        }
        IWETH w9 = IWETH(WETH9);
        w9.deposit{value: amount}();
        bool resp = w9.transfer(recipient, amount);
        require(resp, "Failed to transfer.");

    }

    function approvedTransferFrom(address user, uint256 amount, address recipient) external override onlyApproved {
        require(amounts[user] >= amount, "Not enough balance to transfer.");
        unchecked {
            amounts[user] -= amount;
            amounts[recipient] += amount;
        }
    }

    function transfer(address to, uint value) public override {
        require(amounts[_msgSender()] >= value, "Not enough balance to transfer.");
        unchecked {
            amounts[_msgSender()] -= value;
            amounts[to] += value;
        }
    }

    /**
     * Performs a withdrawal on behalf of a user. Approved contracts only.
     * @param user user to perform on behalf of
     * @param amount amount to withdraw
     * @param recipient recipient wallet to send to
     */
    function approvedWithdraw(address user, uint256 amount, address recipient) external override onlyApproved {
         // Because of Solidity 0.8 SafeMath we can require then do an unchecked subtract
        require(amounts[user] >= amount, "Not enough balance to withdraw.");
        unchecked {
            amounts[user] -= amount;
        }
        // Use Address senders 
        Address.sendValue(payable(recipient), amount);
    }




}