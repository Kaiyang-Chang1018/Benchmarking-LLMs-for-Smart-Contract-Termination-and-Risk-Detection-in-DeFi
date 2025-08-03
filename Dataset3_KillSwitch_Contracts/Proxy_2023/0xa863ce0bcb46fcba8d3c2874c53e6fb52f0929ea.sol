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
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

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
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
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
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
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
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface ICustomToken {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool); 
    function balanceOf(address account) external view returns (uint256);
    function burn(uint256 amount) external;
    function mint(address to, uint256 amount) external;
    function totalSupply() external view returns (uint256); 
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IToken.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface IOwnable2Step {
	function acceptOwnership() external;
}

contract StakingBondContract is Ownable, ReentrancyGuard {
	using SafeERC20 for IERC20;

	ICustomToken public token;
	IERC20 public usdcToken;

	struct StakeInfo {
		uint256 amount;
		uint256 pendingRewards;
		uint256 lastUpdated;
		uint256 epoch;
	}

	struct Bond {
		uint256 id;
		uint256 tokenAmount;
		uint256 pricePerToken;
		uint256 closeEpoch;
		bool isActive;
		bool isCanceled;
	}

	struct UserBondInfo {
		uint256 amountPurchased;
		bool claimed;
	}

	struct BondClaimDetails {
		uint256 bondId;
		uint256 amountToClaim;
	}

	mapping(address => StakeInfo) public userStakes;
	mapping(uint256 => Bond) public bonds;
	mapping(address => mapping(uint256 => UserBondInfo)) public userBonds;

	uint256 public constant SECONDS_IN_YEAR = 31536000;
	uint256 public bondCounter;
	uint256 public APR;
	uint256 public UNSTAKE_TAX;
	uint256 public epochDuration;
	uint256 public totalStaked;
	uint256 public totalBurned;
	uint256 public deploymentTime;
	uint256 public CLAIM_DELAY_EPOCHS;

	event Staked(address indexed user, uint256 amount);
	event Unstaked(address indexed user, uint256 amount);
	event RewardsMinted(address indexed user, uint256 amount);
	event BondOffered(
		uint256 bondId,
		uint256 tokenAmount,
		uint256 pricePerToken
	);
	event BondPurchased(
		address indexed buyer,
		uint256 bondId,
		uint256 amount,
		uint256 cost
	);
	event BondOfferCancelled(uint256 bondId, uint256 remainingTokenAmount);
	event BondClaimed(address indexed buyer, uint256 bondId, uint256 amount);
	event BondClosed(uint256 bondId);
	event USDCWithdrawn(uint256 amount);

	constructor(address _tokenAddress, address _usdcTokenAddress) {
		token = ICustomToken(_tokenAddress);
		usdcToken = IERC20(_usdcTokenAddress);
		deploymentTime = block.timestamp;
		epochDuration = 6 hours;
		CLAIM_DELAY_EPOCHS = 12;
		UNSTAKE_TAX = 10;
		APR = 1000;
	}

	function acceptTokenOwnership() external onlyOwner {
		IOwnable2Step(address(token)).acceptOwnership();
	}

	function offerBond(
		uint256 _tokenAmount,
		uint256 _pricePerToken
	) external onlyOwner {
		require(_tokenAmount > 0, "Invalid bond parameters");

		bondCounter += 1;
		bonds[bondCounter] = Bond({
			id: bondCounter,
			tokenAmount: _tokenAmount,
			pricePerToken: _pricePerToken,
			closeEpoch: 0,
			isActive: true,
			isCanceled: false
		});

		emit BondOffered(bondCounter, _tokenAmount, _pricePerToken);
	}

	function purchaseBond(
		uint256 _bondId,
		uint256 amountInUSDC
	) external nonReentrant {
		Bond storage bond = bonds[_bondId];
		require(bond.isActive, "No active bond offer");
		require(amountInUSDC > 0, "Amount must be greater than zero");
		uint256 amountDecimaled = amountInUSDC * 1e6;

		uint256 bondsToPurchase = (amountDecimaled) / bond.pricePerToken;

		require(
			bondsToPurchase <= bond.tokenAmount,
			"Not enough tokens in bond offer"
		);

		usdcToken.safeTransferFrom(msg.sender, address(this), amountDecimaled);

		bond.tokenAmount -= bondsToPurchase;

		if (bond.tokenAmount == 0) {
			bond.isActive = false;
			bond.closeEpoch = getCurrentEpoch();
			emit BondClosed(_bondId);
		}

		UserBondInfo storage userBond = userBonds[msg.sender][_bondId];
		userBond.amountPurchased += bondsToPurchase;

		emit BondPurchased(
			msg.sender,
			_bondId,
			bondsToPurchase,
			amountDecimaled
		);
	}

	function claimBonds(uint256[] calldata bondIds) external nonReentrant {
		uint256 currentEpoch = getCurrentEpoch();

		for (uint256 i = 0; i < bondIds.length; i++) {
			uint256 _bondId = bondIds[i];
			UserBondInfo storage userBond = userBonds[msg.sender][_bondId];
			Bond storage bond = bonds[_bondId];

			if (bond.isCanceled) {
				continue;
			}

			if (userBond.amountPurchased == 0) {
				continue;
			}

			if (userBond.claimed) {
				continue;
			}

			uint256 requiredEpoch = bond.closeEpoch + CLAIM_DELAY_EPOCHS;

			if (bond.closeEpoch == 0 || currentEpoch < requiredEpoch) {
				continue;
			}

			userBond.claimed = true;
			uint256 toMint = userBond.amountPurchased * 1e18;
			token.mint(msg.sender, toMint);

			emit BondClaimed(msg.sender, _bondId, toMint);
		}
	}

	function cancelBondOffer(uint256 _bondId) external onlyOwner {
		Bond storage bond = bonds[_bondId];
		require(!bond.isCanceled, "Bond offer already canceled");
		bond.isCanceled = true;
		bond.isActive = false;

		emit BondOfferCancelled(_bondId, bond.tokenAmount);
	}

	function withdrawUSDC(uint256 _amount) external onlyOwner {
		uint256 balance = usdcToken.balanceOf(address(this));
		require(_amount <= balance, "Amount exceeds balance");
		usdcToken.safeTransfer(owner(), _amount);
		emit USDCWithdrawn(_amount);
	}

	function stake(uint256 amount) external nonReentrant {
		require(amount > 0, "Amount must be greater than zero");

		token.transferFrom(msg.sender, address(this), amount);
		token.burn(amount);
		totalBurned += amount;

		StakeInfo storage stakeInfo = userStakes[msg.sender];
		uint256 currentTimestamp = block.timestamp;

		uint256 timeElapsed = currentTimestamp - stakeInfo.lastUpdated;

		if (stakeInfo.amount > 0 && timeElapsed > 0) {
			uint256 rewards = (stakeInfo.amount * APR * timeElapsed) /
				(100 * SECONDS_IN_YEAR);
			stakeInfo.pendingRewards += rewards;
		}

		stakeInfo.amount += amount;
		stakeInfo.lastUpdated = currentTimestamp;
		stakeInfo.epoch = getCurrentEpoch();
		totalStaked += amount;

		emit Staked(msg.sender, amount);
	}

	function unstake() external nonReentrant {
		StakeInfo storage stakeInfo = userStakes[msg.sender];
		uint256 amount = stakeInfo.amount;
		require(amount > 0, "No staked amount to unstake");

		uint256 currentEpoch = getCurrentEpoch();
		require(
			currentEpoch > stakeInfo.epoch,
			"Cannot unstake before the next epoch"
		);

		uint256 currentTimestamp = block.timestamp;
		uint256 timeElapsed = currentTimestamp - stakeInfo.lastUpdated;

		if (timeElapsed > 0) {
			uint256 rewards = (stakeInfo.amount * APR * timeElapsed) /
				(100 * SECONDS_IN_YEAR);
			stakeInfo.pendingRewards += rewards;
			stakeInfo.lastUpdated = currentTimestamp;
		}

		uint256 rewardsToClaim = stakeInfo.pendingRewards;

		stakeInfo.pendingRewards = 0;
		stakeInfo.lastUpdated = currentTimestamp;

		if (rewardsToClaim > 0) {
			token.mint(msg.sender, rewardsToClaim);
			emit RewardsMinted(msg.sender, rewardsToClaim);
		}

		stakeInfo.amount -= amount;
		totalStaked -= amount;

		uint256 taxAmount = (amount * UNSTAKE_TAX) / 100;
		uint256 amountAfterTax = amount - taxAmount;

		if (amountAfterTax > 0) {
			token.mint(msg.sender, amountAfterTax);
			totalBurned = totalBurned >= amountAfterTax
				? totalBurned - amountAfterTax
				: 0;
			emit Unstaked(msg.sender, amountAfterTax);
		}
	}

	function calculateRewards(address user) public view returns (uint256) {
		StakeInfo storage stakeInfo = userStakes[user];
		if (stakeInfo.amount == 0) {
			return stakeInfo.pendingRewards;
		}

		uint256 timeElapsed = block.timestamp - stakeInfo.lastUpdated;
		if (timeElapsed == 0) {
			return stakeInfo.pendingRewards;
		}

		uint256 rewards = (stakeInfo.amount * APR * timeElapsed) /
			(100 * SECONDS_IN_YEAR);

		uint256 totalRewards = stakeInfo.pendingRewards + rewards;

		return totalRewards;
	}

	function claimRewards() external nonReentrant {
		StakeInfo storage stakeInfo = userStakes[msg.sender];
		require(stakeInfo.amount > 0, "No staked amount");

		uint256 currentTimestamp = block.timestamp;
		uint256 timeElapsed = currentTimestamp - stakeInfo.lastUpdated;

		if (timeElapsed > 0) {
			uint256 rewards = (stakeInfo.amount * APR * timeElapsed) /
				(100 * SECONDS_IN_YEAR);
			stakeInfo.pendingRewards += rewards;
		}

		uint256 rewardsToClaim = stakeInfo.pendingRewards;
		require(rewardsToClaim > 0, "No rewards to claim");

		stakeInfo.pendingRewards = 0;
		stakeInfo.lastUpdated = currentTimestamp;

		token.mint(msg.sender, rewardsToClaim);

		totalBurned = totalBurned >= rewardsToClaim
			? totalBurned - rewardsToClaim
			: 0;

		emit RewardsMinted(msg.sender, rewardsToClaim);
	}

	function compound() external nonReentrant {
		StakeInfo storage stakeInfo = userStakes[msg.sender];
		require(stakeInfo.amount > 0, "No staked amount to compound");

		uint256 currentTimestamp = block.timestamp;
		uint256 timeElapsed = currentTimestamp - stakeInfo.lastUpdated;

		if (timeElapsed > 0) {
			uint256 rewards = (stakeInfo.amount * APR * timeElapsed) /
				(100 * SECONDS_IN_YEAR);
			stakeInfo.pendingRewards += rewards;
		}

		uint256 rewardsToCompound = stakeInfo.pendingRewards;
		require(rewardsToCompound > 0, "No rewards to compound");

		stakeInfo.pendingRewards = 0;
		stakeInfo.lastUpdated = currentTimestamp;
		stakeInfo.epoch = getCurrentEpoch();

		stakeInfo.amount += rewardsToCompound;
		totalStaked += rewardsToCompound;

		emit Staked(msg.sender, rewardsToCompound);
	}

	// Setters
	function setAPR(uint256 _newAPR) external onlyOwner {
		APR = _newAPR;
	}

	function setUnstakeTax(uint256 _newTax) external onlyOwner {
		UNSTAKE_TAX = _newTax;
	}

	function setEpochDuration(uint256 _newEpochDuration) external onlyOwner {
		epochDuration = _newEpochDuration;
	}

	function setClaimDelayEpochs(uint256 _newClaimDelay) external onlyOwner {
		CLAIM_DELAY_EPOCHS = _newClaimDelay;
	}

	function setTokenAddress(address _newTokenAddress) external onlyOwner {
		token = ICustomToken(_newTokenAddress);
	}

	function setUsdcTokenAddress(address _newUSDCAddress) external onlyOwner {
		usdcToken = IERC20(_newUSDCAddress);
	}

	// Getters Bond

	function getBondDetails(
		uint256 _bondId
	)
		external
		view
		returns (
			uint256 tokenAmount,
			uint256 pricePerToken,
			uint256 closeEpoch,
			bool isActive
		)
	{
		Bond storage bond = bonds[_bondId];
		return (
			bond.tokenAmount,
			bond.pricePerToken,
			bond.closeEpoch,
			bond.isActive
		);
	}

	// Getters Staking

	function getCurrentEpoch() public view returns (uint256) {
		return (block.timestamp - deploymentTime) / epochDuration;
	}

	function timeUntilNextEpoch() public view returns (uint256) {
		unchecked {
			uint256 timeInCurrentEpoch = (block.timestamp - deploymentTime) %
				epochDuration;
			return epochDuration - timeInCurrentEpoch;
		}
	}

	function getTotalUserStake(address user) public view returns (uint256) {
		return userStakes[user].amount;
	}

	function getNextEpochYield() external view returns (uint256) {
		uint256 numerator = APR * epochDuration * 1e6;
		uint256 denominator = 100 * SECONDS_IN_YEAR;
		uint256 yieldPercentage = numerator / denominator;
		return yieldPercentage;
	}

	function calculateDailyRewards(
		address user
	) external view returns (uint256) {
		StakeInfo storage stakeInfo = userStakes[user];
		if (stakeInfo.amount == 0) {
			return 0;
		}

		uint256 dayInSeconds = 1 days;
		uint256 rewards = (stakeInfo.amount * APR * dayInSeconds) /
			(100 * SECONDS_IN_YEAR);
		return rewards;
	}

	function calculateNextEpochRewards(
		address user
	) external view returns (uint256) {
		StakeInfo storage stakeInfo = userStakes[user];
		if (stakeInfo.amount == 0) {
			return 0;
		}

		uint256 epochTime = epochDuration;
		uint256 rewards = (stakeInfo.amount * APR * epochTime) /
			(100 * SECONDS_IN_YEAR);
		return rewards;
	}

	function getBondInfo(
		address user,
		bool onlyClaimable
	) external view returns (BondClaimDetails[] memory) {
		uint256 count = 0;
		uint256 currentEpoch = getCurrentEpoch();
		BondClaimDetails[] memory tempBonds = new BondClaimDetails[](
			bondCounter
		);

		for (uint256 i = 1; i <= bondCounter; i++) {
			UserBondInfo storage userBond = userBonds[user][i];
			Bond storage bond = bonds[i];

			if (userBond.amountPurchased > 0 && !userBond.claimed) {
				bool isClaimable = (bond.closeEpoch > 0 &&
					currentEpoch >= bond.closeEpoch + CLAIM_DELAY_EPOCHS);

				if (!onlyClaimable || isClaimable) {
					tempBonds[count] = BondClaimDetails({
						bondId: i,
						amountToClaim: userBond.amountPurchased
					});
					count++;
				}
			}
		}

		BondClaimDetails[] memory result = new BondClaimDetails[](count);
		for (uint256 j = 0; j < count; j++) {
			result[j] = tempBonds[j];
		}

		return result;
	}
}