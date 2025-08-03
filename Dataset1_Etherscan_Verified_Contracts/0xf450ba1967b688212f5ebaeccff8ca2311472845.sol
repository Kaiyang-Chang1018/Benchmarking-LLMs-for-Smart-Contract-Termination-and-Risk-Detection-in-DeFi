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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

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
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/StorageSlot.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
 */
library StorageSlot {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./library/ProxyConfigUtils.sol";
import "./library/Registry.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

abstract contract Base is ReentrancyGuard {

  function _initBase(IConfig config_) internal {
    ProxyConfigUtils._setConfig(config_);
  }

  function getConfig() public view returns(IConfig config){
    return ProxyConfigUtils._getConfig();
  }

  function hasRole(bytes32 role, address account) internal view returns(bool has){
    return ProxyConfigUtils._getConfig().hasRole(role, account);
  }

  modifier isSuperAdmin() {
    require(hasRole(Registry.SUPER_ADMIN_ROLE, msg.sender), "only super admin can do");
    _;
  }

  modifier isAdmin() {
    require(hasRole(Registry.ADMIN_ROLE, msg.sender), "only super admin can do");
    _;
  }

  modifier isMinter() {
    require(hasRole(Registry.MINTER_ROLE, msg.sender), "only minter role can do");
    _;
  }

  modifier isDepositer() {
    require(hasRole(Registry.DEPOSIT_ROLE, msg.sender), "only depositer role can do");
    _;
  }

  modifier isOperator() {
    require(hasRole(Registry.OPERATOR_ROLE, msg.sender), "only operator role can do");
    _;
  }

  modifier isSuperAdminOrMinter() {
    require(hasRole(Registry.SUPER_ADMIN_ROLE, msg.sender) || hasRole(Registry.MINTER_ROLE, msg.sender), "only super admin or minter role can do");
    _;
  }
}
// SPDX-License-Identifier: LGPL-3.0-only
//IERC20.sol
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/IGenArt721CoreContractV3.sol";
import "./interfaces/IMinterFilterV0.sol";
import "./interfaces/IFilteredMinterV0.sol";
import "./utils/EnumerableMap.sol";
import "./Base.sol";

pragma solidity 0.8.9;

contract MinterSetPrice is Base, IFilteredMinterV0 {
    using SafeERC20 for IERC20;
    using EnumerableMap for EnumerableMap.AddressToBoolMap;

    /// Core contract address this minter interacts with
    address public immutable genArt721CoreAddress;

    /// This contract handles cores with interface IV1
    IGenArt721CoreContractV3 private immutable genArtCoreContract;

    /// Minter filter address this minter interacts with
    address public immutable minterFilterAddress;

    /// Minter filter this minter may interact with.
    IMinterFilterV0 private immutable minterFilter;

    /// minterType for this minter
    string public constant minterType = "MinterSetPrice";

    uint256 constant ONE_MILLION = 1_000_000;

    uint256 constant TEN_THOUSAND = 10_000;

    uint256 public MAX_WHITE_LENGTH = 1_000;

    uint256 public MAX_ADDITIONAL_FEE = 10;

    /// projectId => has project reached its maximum number of invocations?
    mapping(uint256 => bool) public projectMaxHasBeenInvoked;
    /// projectId => project's maximum number of invocations
    mapping(uint256 => uint256) public projectMaxInvocations;
    /// projectId => price per token in wei - supersedes any defined core price
    mapping(uint256 => uint256) private projectIdToPricePerTokenInWei;
    /// projectId => price per token has been configured on this minter
    mapping(uint256 => bool) private projectIdToPriceIsConfigured;
    // projectId => mint startTime
    mapping(uint256 => uint256) private projectIdToStartTime;
    // projectId => pause
    mapping(uint256 => bool) private projectIdToDisable;
    // projectId => address => bool
    mapping(uint256 => EnumerableMap.AddressToBoolMap)
        private projectIdToWhitelists;
    // projectId => uint256
    mapping(uint256 => uint256) private projectIdToWhitePrice;
    // projectId => percentage
    mapping(uint256 => uint256) public projectIdToAdditionalPayeePercentage;
    // projectId => address
    mapping(uint256 => address payable) public projectIdToAdditionalPayee;
    // projectId => mint currency
    mapping (uint256 => address) public projectIdToMintCurrency;
    // projectId => white list mint count
    mapping(uint256 => uint256) public projectIdWhiteListMintCounts;

    uint256 public defaultAdditionalPayee = 8;
    bool public canArtistModify;
    uint8 public maxBatchMintCount = 20;
    uint8 public defaultWhiteListMintCount = 1;

    modifier onlyArtist(uint256 _projectId) {
        require(
            msg.sender ==
                genArtCoreContract.projectIdToArtistAddress(_projectId),
            "Only Artist"
        );
        _;
    }

    modifier onlyArtistOrOperator(uint256 _projectId, bool _flag) {
        require(
            (_flag && msg.sender ==
            genArtCoreContract.projectIdToArtistAddress(_projectId)) ||
            hasRole(Registry.OPERATOR_ROLE, msg.sender),
            "Only Artist"
        );
        _;
    }

    modifier onlyOperator() {
        require(hasRole(Registry.OPERATOR_ROLE, msg.sender), "Only Operator");
        _;
    }

    modifier onlyProjectMaxNotHasBeenInvoked(uint256 _projectId) {
        require(
            !projectMaxHasBeenInvoked[_projectId],
            "Project has been invoked"
        );
        _;
    }

    modifier onlyProjectInvocationsIsZero(uint256 _projectId) {
        uint256 invocations;
        address artistAddress;
        (artistAddress, invocations, , , , ) = genArtCoreContract.projectInfo(
            _projectId
        );
        require(
            artistAddress != address(0) && invocations == 0,
            "Project not exist or Project has invocation"
        );
        _;
    }

    modifier onlyBeforeStartTime(uint256 _projectId) {
        uint256 startTime = projectIdToStartTime[_projectId];
        require(block.timestamp < startTime, "Current time after startTime");
        _;
    }

    /**
     * @notice Initializes contract to be a Filtered Minter for
     * `_minterFilter`, integrated with Art Blocks core contract
     * at address `_genArt721Address`.
     * @param _genArt721Address Art Blocks core contract address for
     * which this contract will be a minter.
     * @param _minterFilter Minter filter for whichccthis will a
     * filtered minter.
     */
    constructor(address _genArt721Address, address _minterFilter, IConfig _config)
    {
        genArt721CoreAddress = _genArt721Address;
        genArtCoreContract = IGenArt721CoreContractV3(_genArt721Address);
        minterFilterAddress = _minterFilter;
        minterFilter = IMinterFilterV0(_minterFilter);
        require(
            minterFilter.genArt721CoreAddress() == _genArt721Address,
            "Illegal contract pairing"
        );
        _initBase(_config);
    }

    /**
     * @notice Sets the maximum invocations of project `_projectId` based
     * on the value currently defined in the core contract.
     * @param _projectId Project ID to set the maximum invocations for.
     * @dev also checks and may refresh projectMaxHasBeenInvoked for project
     * @dev this enables gas reduction after maxInvocations have been reached -
     * core contracts shall still enforce a maxInvocation check during mint.
     */
    function setProjectMintInfo(
        uint256 _projectId,
        address _token,
        uint256 _pricePerTokenInWei,
        uint256 _maxInvocations,
        uint256 _startTime,
        bool _disable,
        address[] memory _addrs,
        uint256[] memory _rates
    ) external onlyArtist(_projectId) onlyProjectInvocationsIsZero(_projectId) {
        require(
            _startTime > block.timestamp,
            "Start time must > current block time"
        );

        {
            uint256 invocations;
            (, invocations, , , , ) = genArtCoreContract.projectInfo(_projectId);

            require(
                _maxInvocations <= ONE_MILLION,
                "Max invocations must <= 1000000"
            );

            require(
                _maxInvocations >= invocations,
                "Max invocations must > current invocations"
            );

            projectIdToPricePerTokenInWei[_projectId] = _pricePerTokenInWei;
            projectIdToPriceIsConfigured[_projectId] = true;

            projectMaxInvocations[_projectId] = _maxInvocations;
            if (invocations < _maxInvocations) {
                projectMaxHasBeenInvoked[_projectId] = false;
            }
        }

        projectIdToStartTime[_projectId] = _startTime;

        projectIdToDisable[_projectId] = _disable;

        projectIdToMintCurrency[_projectId] = _token;

        minterFilter.setMinterForProject(_projectId, address(this));

        genArtCoreContract.setProjectMinterType(_projectId, minterType);

        emit SetProjectMintInfo(
            _projectId,
            _token,
            _pricePerTokenInWei,
            _maxInvocations,
            _startTime,
            _disable
        );
    }

    function updateMaxBatchMintCount(uint8 _count) external onlyOperator {
        require(_count > 0, "mint count must > 0");
        maxBatchMintCount = _count;
    }

    function updateProjectIdWhiteListMintCounts(uint256 _projectId, uint256 _count) external onlyArtistOrOperator(_projectId, true) {
        require(_count <= maxBatchMintCount, "count must < max batch count");
        projectIdWhiteListMintCounts[_projectId] = _count;
    }

    /**
     * @notice Warning: Disabling purchaseTo is not supported on this minter.
     * This method exists purely for interface-conformance purposes.
     */
    function togglePurchaseToDisabled(uint256 _projectId)
        external
        onlyArtistOrOperator(_projectId, true)
        onlyProjectMaxNotHasBeenInvoked(_projectId)
    {
        projectIdToDisable[_projectId] = !projectIdToDisable[_projectId];
        emit PurchaseToDisabledUpdated(
            _projectId,
            !projectIdToDisable[_projectId]
        );
    }

    function updatePricePerTokenInWei(
        uint256 _projectId,
        uint256 _pricePerTokenInWei
    )
        external
        onlyArtistOrOperator(_projectId, true)
        onlyProjectMaxNotHasBeenInvoked(_projectId)
        onlyProjectInvocationsIsZero(_projectId)
    {
        projectIdToPricePerTokenInWei[_projectId] = _pricePerTokenInWei;
        projectIdToPriceIsConfigured[_projectId] = true;
        emit PricePerTokenInWeiUpdated(_projectId, _pricePerTokenInWei);
    }

    function updateMaxInvocations(uint256 _projectId, uint256 _maxInvocations)
        external
        onlyArtistOrOperator(_projectId, true)
        onlyProjectMaxNotHasBeenInvoked(_projectId)
    {
        uint256 invocations;
        (, invocations, , , , ) = genArtCoreContract.projectInfo(_projectId);

        require(
            _maxInvocations <= ONE_MILLION,
            "Max invocations must <= 1000000"
        );

        require(
            _maxInvocations >= invocations,
            "Max invocations must > current invocations"
        );

        projectMaxInvocations[_projectId] = _maxInvocations;

        emit UpdateProjectMaxInvocations(_projectId, _maxInvocations);
    }

    function updateStartTime(uint256 _projectId, uint256 _startTime)
        external
        onlyArtistOrOperator(_projectId, true)
        onlyProjectMaxNotHasBeenInvoked(_projectId)
    {
        require(
            _startTime > block.timestamp,
            "Start time must > current block time"
        );

        projectIdToStartTime[_projectId] = _startTime;
        emit UpdateProjectStartTime(_projectId, _startTime);
    }

    function updateMaxMintBatchCount(uint8 _count) external isOperator {
        maxBatchMintCount = _count;
    }

    function updateDefaultWhiteListMintCount(uint8 _count) external isOperator {
        defaultWhiteListMintCount = _count;
    }

    function updateCanArtistModify(bool _flag) external isOperator {
        canArtistModify = _flag;
    }

    function updateDefaultAdditionalPayee(uint256 _fee) external isOperator {
        require(_fee <= MAX_ADDITIONAL_FEE, "must < MAX_ADDITIONAL_FEE");
        defaultAdditionalPayee = _fee;
    }

    function updateProjectAdditionalPayeePercentage(uint256 _projectId, uint256 _percentage) external onlyArtistOrOperator(_projectId, canArtistModify) {
        require(_percentage <= MAX_ADDITIONAL_FEE, "must < MAX_ADDITIONAL_FEE");
        projectIdToAdditionalPayeePercentage[_projectId] = _percentage;
    }

    function updateProjectIdToAdditionalPayee(uint256 _projectId, address payable _additionalAddr) external onlyArtistOrOperator(_projectId, canArtistModify) {
        projectIdToAdditionalPayee[_projectId] = _additionalAddr;
    }

    function addProjectWhitelist(uint256 _projectId, address[] memory _addrs)
        public
        onlyArtistOrOperator(_projectId, true)
        onlyBeforeStartTime(_projectId)
    {
        EnumerableMap.AddressToBoolMap storage whiteSet = projectIdToWhitelists[
            _projectId
        ];
        require(
            _addrs.length + whiteSet.length() <= MAX_WHITE_LENGTH,
            "white length > MAX_WHITE_LENGTH"
        );
        for (uint256 i = 0; i < _addrs.length; i++) {
            require(_addrs[i] != address(0), "invalid address");
            whiteSet.set(_addrs[i], true);
        }
    }

    function updateProjectWhitelistPrice(uint256 _projectId, uint256 _price)
        public
        onlyArtistOrOperator(_projectId, true)
        onlyBeforeStartTime(_projectId)
    {
        projectIdToWhitePrice[_projectId] = _price;
    }

    function updateProjectWhitelistMaxLength(uint256 _num)
        public
        isAdmin
    {
        MAX_WHITE_LENGTH = _num;
    }

    function purchase(uint256 _projectId, uint8 mintCount)
        external
        payable
    {
        require(mintCount > 0 && mintCount <= maxBatchMintCount, "invalid mint count");
        purchaseTo(msg.sender, _projectId, mintCount);
    }

    function purchaseTo(address _to, uint256 _projectId, uint8 _mintCount)
        public
        payable
        nonReentrant
    {
        // CHECKS
        require(
            !projectMaxHasBeenInvoked[_projectId],
            "Maximum number of invocations reached"
        );

        (,uint256 invocations,,,,) = genArtCoreContract.projectInfo(_projectId);
        require(invocations + _mintCount <= projectMaxInvocations[_projectId], "not enough to mint");

        // require artist to have configured price of token on this minter
        require(
            projectIdToPriceIsConfigured[_projectId],
            "Price not configured"
        );

        require(!projectIdToDisable[_projectId], "Project is disable");

        // whiteList mint
        uint256 price = getPrice(_projectId);
        price = price * _mintCount;

        if (block.timestamp < projectIdToStartTime[_projectId]) {
            uint256 allowCount = defaultWhiteListMintCount;
            if (projectIdWhiteListMintCounts[_projectId] != 0) {
                allowCount = projectIdWhiteListMintCounts[_projectId];
            }
            require(_mintCount <= allowCount, "white list only can mint allow count");
            EnumerableMap.AddressToBoolMap
                storage whiteSet = projectIdToWhitelists[_projectId];
            (bool exist, ) = whiteSet.tryGet(msg.sender);
            require(exist, "msg sender not in white list");
            whiteSet.remove(msg.sender);
        }

        address mintCurrency = projectIdToMintCurrency[_projectId];
        if (mintCurrency == address(0)) {
            require(msg.value >= price, "Must send minimum value to mint!");
        }
    
        uint256 tokenId;
        for (uint i; i<_mintCount; i++) {
            tokenId = minterFilter.mint(_to, _projectId, msg.sender);
        }
        if (
            projectMaxInvocations[_projectId] > 0 &&
            tokenId % ONE_MILLION == projectMaxInvocations[_projectId] - 1
        ) {
            projectMaxHasBeenInvoked[_projectId] = true;
        }

        // INTERACTIONS
        if (mintCurrency == address(0)) {
            _splitFundsETH(_projectId, price);
        } else {
            _splitFundsERC20(_projectId, price, mintCurrency);
        }

        emit Purchase(_projectId, mintCurrency, msg.sender, _mintCount, price);
    }

    function _splitFundsETH(uint256 _projectId, uint256 _price) internal {
        if (msg.value > 0) {
            uint256 pricePerTokenInWei = _price;
            uint256 refund = msg.value - pricePerTokenInWei;
            if (refund > 0) {
                (bool success_, ) = msg.sender.call{value: refund}("");
                require(success_, "Refund failed");
            }
            uint256 foundationAmount = (pricePerTokenInWei *
                genArtCoreContract.alleriaPercentage()) / 100;
            if (foundationAmount > 0) {
                (bool success_, ) = genArtCoreContract.alleriaAddress().call{
                    value: foundationAmount
                }("");
                require(success_, "Foundation payment failed");
            }
            uint256 projectFunds = pricePerTokenInWei - foundationAmount;
            uint256 additionalPayeeAmount;
            uint256 payeeFee = defaultAdditionalPayee;
            if (
                projectIdToAdditionalPayee[_projectId] != address(0)
            ) {
                uint256 useFee = projectIdToAdditionalPayeePercentage[_projectId];
                if (useFee != 0) {
                    payeeFee = useFee;
                }
                additionalPayeeAmount =
                    (projectFunds * payeeFee) / 100;
                if (additionalPayeeAmount > 0) {
                    (bool success_, ) = projectIdToAdditionalPayee[_projectId]
                        .call{value: additionalPayeeAmount}("");
                    require(success_, "Additional payment failed");
                }
            }
            uint256 creatorFunds = projectFunds - additionalPayeeAmount;
            if (creatorFunds > 0) {
                (bool success_, ) = genArtCoreContract
                    .projectIdToArtistAddress(_projectId)
                    .call{value: creatorFunds}("");
                require(success_, "Artist payment failed");
            }
        }
    }

    function _splitFundsERC20(uint256 _projectId, uint256 _price, address _currency) internal {
        uint256 pricePerTokenInWei = _price;
        IERC20(_currency).safeTransferFrom(msg.sender, address(this), pricePerTokenInWei);

        uint256 foundationAmount = (pricePerTokenInWei *
            genArtCoreContract.alleriaPercentage()) / 100;
        if (foundationAmount > 0) {
            IERC20(_currency).safeTransfer(genArtCoreContract.alleriaAddress(), foundationAmount);
        }
        uint256 projectFunds = pricePerTokenInWei - foundationAmount;
        uint256 additionalPayeeAmount;
        uint256 payeeFee = defaultAdditionalPayee;
        if (
            projectIdToAdditionalPayee[_projectId] != address(0)
        ) {
            uint256 useFee = projectIdToAdditionalPayeePercentage[_projectId];
            if (useFee != 0) {
                payeeFee = useFee;
            }
            additionalPayeeAmount =
                (projectFunds * payeeFee) / 100;
            if (additionalPayeeAmount > 0) {
                IERC20(_currency).safeTransfer(projectIdToAdditionalPayee[_projectId], additionalPayeeAmount);
            }
        }
        uint256 creatorFunds = projectFunds - additionalPayeeAmount;
        if (creatorFunds > 0) {
            IERC20(_currency).safeTransfer(genArtCoreContract.projectIdToArtistAddress(_projectId), creatorFunds);
        }
    }

    function getPriceInfo(uint256 _projectId)
        external
        view
        returns (
            bool isConfigured,
            uint256 tokenPriceInWei,
            uint256 whitePriceInWei,
            address currencyAddress
        )
    {
        isConfigured = projectIdToPriceIsConfigured[_projectId];
        tokenPriceInWei = projectIdToPricePerTokenInWei[_projectId];
        whitePriceInWei = projectIdToWhitePrice[_projectId];
        currencyAddress = projectIdToMintCurrency[_projectId];
    }

    function getMintInfo(uint256 _projectId)
        external
        view
        returns (
            uint256 pricePerTokenInWei,
            uint256 whitePerTokenInWei,
            uint256 invocations,
            uint256 maxInvocations,
            uint256 startTime,
            bool disable
        )
    {
        (, invocations, , , , ) = genArtCoreContract.projectInfo(_projectId);
        pricePerTokenInWei = projectIdToPricePerTokenInWei[_projectId];
        whitePerTokenInWei = projectIdToWhitePrice[_projectId];
        maxInvocations = projectMaxInvocations[_projectId];
        startTime = projectIdToStartTime[_projectId];
        disable = projectIdToDisable[_projectId];
    }

    function getPrice(uint256 _projectId)
        internal
        view
        returns (uint256 price)
    {
        if (block.timestamp < projectIdToStartTime[_projectId]) {
            price = projectIdToWhitePrice[_projectId];
        } else {
            price = projectIdToPricePerTokenInWei[_projectId];
        }
        return price;
    }

    function getWhitelists(uint256 _projectId)
        external
        view
        returns (address[] memory)
    {
        EnumerableMap.AddressToBoolMap storage set = projectIdToWhitelists[
            _projectId
        ];
        return set.values();
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

interface IConfig {

  function version() external pure returns (uint256 v);

  function getAddressByKey(bytes32 _key) external view returns (address);

  function getUint256ByKey(bytes32 _key) external view returns (uint256);

  function hasRole(bytes32 role, address account) external view returns(bool has);

  function supportsInterface(bytes4 interfaceId) external view returns (bool);
  
}
// SPDX-License-Identifier: LGPL-3.0-only

pragma solidity ^0.8.0;

interface IFilteredMinterV0 {
    /**
     * @notice Price per token in wei updated for project `_projectId` to
     * `_pricePerTokenInWei`.
     */
    event PricePerTokenInWeiUpdated(
        uint256 indexed _projectId,
        uint256 indexed _pricePerTokenInWei
    );

    /**
     * @notice Currency updated for project `_projectId` to symbol
     * `_currencySymbol` and address `_currencyAddress`.
     */
    event ProjectCurrencyInfoUpdated(
        uint256 indexed _projectId,
        address indexed _currencyAddress,
        string _currencySymbol
    );

    /// togglePurchaseToDisabled updated
    event PurchaseToDisabledUpdated(
        uint256 indexed _projectId,
        bool _purchaseToDisabled
    );

    event SetProjectMintInfo(
        uint256 projectId,
        address token,
        uint256 price,
        uint256 maxInvocations,
        uint256 startTime,
        bool disable
    );

    event UpdateProjectMaxInvocations(
        uint256 projectId,
        uint256 maxInvocations
    );

    event Purchase(
        uint256 projectId,
        address currency,
        address minter,
        uint256 mintCount,
        uint256 total
    );

    event UpdateProjectStartTime(uint256 projectId, uint256 startTime);

    // getter function of public variable
    function minterType() external view returns (string memory);

    function genArt721CoreAddress() external returns (address);

    function minterFilterAddress() external returns (address);

    // Triggers a purchase of a token from the desired project, to the
    // TX-sending address.
    function purchase(uint256 _projectId, uint8 mintCount)
        external
        payable;

    // Triggers a purchase of a token from the desired project, to the specified
    // receiving address.
    function purchaseTo(address _to, uint256 _projectId, uint8 _mintCount)
        external
        payable;

    // Toggles the ability for `purchaseTo` to be called directly with a
    // specified receiving address that differs from the TX-sending address.
    function togglePurchaseToDisabled(uint256 _projectId) external;

    // Called to make the minter contract aware of the max invocations for a
    // given project.
    //    function setProjectMaxInvocations(uint256 _projectId) external;

    // Gets if token price is configured, token price in wei, currency symbol,
    // and currency address, assuming this is project's minter.
    // Supersedes any defined core price.
    function getPriceInfo(uint256 _projectId)
        external
        view
        returns (
            bool isConfigured,
            uint256 tokenPriceInWei,
            uint256 whitePriceInWei,
            address currencyAddress
        );
}
// SPDX-License-Identifier: LGPL-3.0-only

pragma solidity ^0.8.0;

interface IGenArt721CoreContractV3 {
    /**
     * @notice Token ID `_tokenId` minted to `_to`.
     */
    event Mint(
        address indexed _to,
        uint256 indexed _tokenId,
        bytes32 indexed _hash
    );

    /**
     * @notice currentMinter updated to `_currentMinter`.
     * @dev Implemented starting with V3 core
     */
    event MinterUpdated(address indexed _currentMinter);

    // getter function of public variable
    function admin() external view returns (address);

    // getter function of public variable
    function nextProjectId() external view returns (uint256);

    // getter function of public mapping
    function tokenIdToProjectId(uint256 tokenId)
        external
        view
        returns (uint256 projectId);

    function isWhitelisted(address sender) external view returns (bool);

    // @dev this is not available in V0
    function isMintWhitelisted(address minter) external view returns (bool);

    function projectIdToArtistAddress(uint256 _projectId)
        external
        view
        returns (address payable);

    function projectIdToAdditionalPayee(uint256 _projectId)
        external
        view
        returns (address payable);

    function projectIdToAdditionalPayeePercentage(uint256 _projectId)
        external
        view
        returns (uint256);

    // @dev new function in V3 (deprecated projectTokenInfo)
    function projectInfo(uint256 _projectId)
        external
        view
        returns (
            address,
            uint256,
            uint256,
            bool,
            address,
            uint256
        );

    function alleriaAddress() external view returns (address payable);

    function alleriaPercentage() external view returns (uint256);

    function mint(
        address _to,
        uint256 _projectId,
        address _by
    ) external returns (uint256 tokenId);

    function updateProjectRoyaltyData(
        uint256 _projectId,
        address[] memory _addrs,
        uint256[] memory _rates
    ) external;

    function setProjectMinterType(uint256 _projectId, string memory _type)
        external;
}
// SPDX-License-Identifier: LGPL-3.0-only

pragma solidity ^0.8.0;

interface IMinterFilterV0 {
    /**
     * @notice Approved minter `_minterAddress`.
     */
    event MinterApproved(address indexed _minterAddress, string _minterType);

    /**
     * @notice Revoked approval for minter `_minterAddress`
     */
    event MinterRevoked(address indexed _minterAddress);

    /**
     * @notice Minter `_minterAddress` of type `_minterType`
     * registered for project `_projectId`.
     */
    event ProjectMinterRegistered(
        uint256 indexed _projectId,
        address indexed _minterAddress,
        string _minterType
    );

    /**
     * @notice Any active minter removed for project `_projectId`.
     */
    event ProjectMinterRemoved(uint256 indexed _projectId);

    function genArt721CoreAddress() external returns (address);

    function setMinterForProject(uint256, address) external;

    function removeMinterForProject(uint256) external;

    function mint(
        address _to,
        uint256 _projectId,
        address sender
    ) external returns (uint256);

    function getMinterForProject(uint256) external view returns (address);

    function projectHasMinter(uint256) external view returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "../interfaces/IConfig.sol";

library ConfigUtils {

    function _checkConfig(IConfig config) internal view {
        require(config.version() > 0 || config.supportsInterface(type(IConfig).interfaceId), "SC130: not a valid config contract");
    }

}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./ConfigUtils.sol";

import "@openzeppelin/contracts/utils/StorageSlot.sol";

library ProxyConfigUtils{
    using ConfigUtils for IConfig;
    
    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.config" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _CONFIG_SLOT = 0x54c601f62ced84cb3960726428d8409adc363a3fa5c7abf6dba0c198dcc43c14;

    function _getConfig() internal view returns(IConfig addr){
        address configAddr = StorageSlot.getAddressSlot(_CONFIG_SLOT).value;
        require(configAddr != address(0x0), "SC133: config not set");
        return IConfig(configAddr);
    }

    function _setConfig(IConfig config) internal{
        ConfigUtils._checkConfig(config);
        StorageSlot.getAddressSlot(_CONFIG_SLOT).value = address(config);
    }

    function _getContractAddress(bytes32 key) internal view returns(address){
        return _getConfig().getAddressByKey(key);
    }

    function _getValueOfUint256(bytes32 key) internal view returns(uint256){
        return _getConfig().getUint256ByKey(key);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

library Registry {

  /***************************** ROLE NAME CONSTANT VARIABLES  ***********************************/

  // SUPER_ADMIN_ROLE
  bytes32 internal constant SUPER_ADMIN_ROLE = 0x0000000000000000000000000000000000000000000000000000000000000000;

  bytes32 internal constant MINTER_ROLE = keccak256("minter.role");

  bytes32 internal constant ADMIN_ROLE = keccak256("admin.role");

  bytes32 internal constant DEPOSIT_ROLE = keccak256("deposit.role");

  bytes32 internal constant OPERATOR_ROLE = keccak256("operator.role");

  bytes32 internal constant POOL_CENTER = keccak256("pool.center");

  bytes32 internal constant ALLERIA = keccak256("alleria.address");

  bytes32 internal constant PLATFORM = keccak256("platform.address");

  bytes32 internal constant OTHER = keccak256("other.address");

  bytes32 internal constant CURATOR_CENTER = keccak256("curator.center");

  bytes32 internal constant ARTIST_RATE = keccak256("artist.rate");

  bytes32 internal constant CURATOR_RATE = keccak256("curator.rate");

  bytes32 internal constant GLOBAL_POOL_RATE = keccak256("global.pool.rate");

  bytes32 internal constant COLLECTION_POOL_RATE = keccak256("collection.pool.rate");

  bytes32 internal constant OTHER_RATE = keccak256("other.rate");

  address internal constant SENTIENT_ADDRESS = 0x0000000000000000000000000000000000000001;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/structs/EnumerableMap.sol)

pragma solidity ^0.8.0;

import "./EnumerableSet.sol";

/**
 * @dev Library for managing an enumerable variant of Solidity's
 * https://solidity.readthedocs.io/en/latest/types.html#mapping-types[`mapping`]
 * type.
 *
 * Maps have the following properties:
 *
 * - Entries are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Entries are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableMap for EnumerableMap.UintToAddressMap;
 *
 *     // Declare a set state variable
 *     EnumerableMap.UintToAddressMap private myMap;
 * }
 * ```
 *
 * As of v3.0.0, only maps of type `uint256 -> address` (`UintToAddressMap`) are
 * supported.
 */
library EnumerableMap {
    using EnumerableSet for EnumerableSet.Bytes32Set;

    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Map type with
    // bytes32 keys and values.
    // The Map implementation uses private functions, and user-facing
    // implementations (such as Uint256ToAddressMap) are just wrappers around
    // the underlying Map.
    // This means that we can only create new EnumerableMaps for types that fit
    // in bytes32.

    struct Map {
        // Storage of keys
        EnumerableSet.Bytes32Set _keys;
        mapping(bytes32 => bytes32) _values;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function _set(
        Map storage map,
        bytes32 key,
        bytes32 value
    ) private returns (bool) {
        map._values[key] = value;
        return map._keys.add(key);
    }

    /**
     * @dev Removes a key-value pair from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function _remove(Map storage map, bytes32 key) private returns (bool) {
        delete map._values[key];
        return map._keys.remove(key);
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function _contains(Map storage map, bytes32 key)
        private
        view
        returns (bool)
    {
        return map._keys.contains(key);
    }

    /**
     * @dev Returns the number of key-value pairs in the map. O(1).
     */
    function _length(Map storage map) private view returns (uint256) {
        return map._keys.length();
    }

    /**
     * @dev Returns the key-value pair stored at position `index` in the map. O(1).
     *
     * Note that there are no guarantees on the ordering of entries inside the
     * array, and it may change when more entries are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Map storage map, uint256 index)
        private
        view
        returns (bytes32, bytes32)
    {
        bytes32 key = map._keys.at(index);
        return (key, map._values[key]);
    }

    /**
     * @dev Tries to returns the value associated with `key`.  O(1).
     * Does not revert if `key` is not in the map.
     */
    function _tryGet(Map storage map, bytes32 key)
        private
        view
        returns (bool, bytes32)
    {
        bytes32 value = map._values[key];
        if (value == bytes32(0)) {
            return (_contains(map, key), bytes32(0));
        } else {
            return (true, value);
        }
    }

    /**
     * @dev Returns the value associated with `key`.  O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function _get(Map storage map, bytes32 key) private view returns (bytes32) {
        bytes32 value = map._values[key];
        require(
            value != 0 || _contains(map, key),
            "EnumerableMap: nonexistent key"
        );
        return value;
    }

    /**
     * @dev Same as {_get}, with a custom error message when `key` is not in the map.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {_tryGet}.
     */
    function _get(
        Map storage map,
        bytes32 key,
        string memory errorMessage
    ) private view returns (bytes32) {
        bytes32 value = map._values[key];
        require(value != 0 || _contains(map, key), errorMessage);
        return value;
    }

    // UintToAddressMap

    struct UintToAddressMap {
        Map _inner;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(
        UintToAddressMap storage map,
        uint256 key,
        address value
    ) internal returns (bool) {
        return _set(map._inner, bytes32(key), bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(UintToAddressMap storage map, uint256 key)
        internal
        returns (bool)
    {
        return _remove(map._inner, bytes32(key));
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(UintToAddressMap storage map, uint256 key)
        internal
        view
        returns (bool)
    {
        return _contains(map._inner, bytes32(key));
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(UintToAddressMap storage map)
        internal
        view
        returns (uint256)
    {
        return _length(map._inner);
    }

    /**
     * @dev Returns the element stored at position `index` in the set. O(1).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintToAddressMap storage map, uint256 index)
        internal
        view
        returns (uint256, address)
    {
        (bytes32 key, bytes32 value) = _at(map._inner, index);
        return (uint256(key), address(uint160(uint256(value))));
    }

    /**
     * @dev Tries to returns the value associated with `key`.  O(1).
     * Does not revert if `key` is not in the map.
     *
     * _Available since v3.4._
     */
    function tryGet(UintToAddressMap storage map, uint256 key)
        internal
        view
        returns (bool, address)
    {
        (bool success, bytes32 value) = _tryGet(map._inner, bytes32(key));
        return (success, address(uint160(uint256(value))));
    }

    /**
     * @dev Returns the value associated with `key`.  O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(UintToAddressMap storage map, uint256 key)
        internal
        view
        returns (address)
    {
        return address(uint160(uint256(_get(map._inner, bytes32(key)))));
    }

    /**
     * @dev Same as {get}, with a custom error message when `key` is not in the map.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryGet}.
     */
    function get(
        UintToAddressMap storage map,
        uint256 key,
        string memory errorMessage
    ) internal view returns (address) {
        return
            address(
                uint160(uint256(_get(map._inner, bytes32(key), errorMessage)))
            );
    }

    struct AddressToBoolMap {
        Map _inner;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(
        AddressToBoolMap storage map,
        address key,
        bool value
    ) internal returns (bool) {
        uint256 _value;
        assembly {
            _value := value
        }
        return
            _set(map._inner, bytes32(uint256(uint160(key))), bytes32(_value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(AddressToBoolMap storage map, address key)
        internal
        returns (bool)
    {
        return _remove(map._inner, bytes32(uint256(uint160(key))));
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(AddressToBoolMap storage map, address key)
        internal
        view
        returns (bool)
    {
        return _contains(map._inner, bytes32(uint256(uint160(key))));
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(AddressToBoolMap storage map)
        internal
        view
        returns (uint256)
    {
        return _length(map._inner);
    }

    /**
     * @dev Returns the element stored at position `index` in the set. O(1).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressToBoolMap storage map, uint256 index)
        internal
        view
        returns (address, bool)
    {
        (bytes32 key, bytes32 value) = _at(map._inner, index);
        bool _value;
        uint256 tValue = uint256(value);
        assembly {
            _value := tValue
        }
        return (address(uint160(uint256(key))), _value);
    }

    /**
     * @dev Tries to returns the value associated with `key`.  O(1).
     * Does not revert if `key` is not in the map.
     *
     * _Available since v3.4._
     */
    function tryGet(AddressToBoolMap storage map, address key)
        internal
        view
        returns (bool, bool)
    {
        (bool success, bytes32 value) = _tryGet(
            map._inner,
            bytes32(uint256(uint160(key)))
        );
        bool _value;
        uint256 tValue = uint256(value);
        assembly {
            _value := tValue
        }
        return (success, _value);
    }

    /**
     * @dev Returns the value associated with `key`.  O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(AddressToBoolMap storage map, address key)
        internal
        view
        returns (bool)
    {
        bool _value;
        uint256 tValue = uint256(
            _get(map._inner, bytes32(uint256(uint160(key))))
        );
        assembly {
            _value := tValue
        }
        return _value;
    }

    /**
     * @dev Same as {get}, with a custom error message when `key` is not in the map.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryGet}.
     */
    function get(
        AddressToBoolMap storage map,
        address key,
        string memory errorMessage
    ) internal view returns (bool) {
        bool _value;
        uint256 tValue = uint256(
            _get(map._inner, bytes32(uint256(uint160(key))), errorMessage)
        );
        assembly {
            _value := tValue
        }
        return _value;
    }

    function values(AddressToBoolMap storage map)
        internal
        view
        returns (address[] memory)
    {
        bytes32[] memory values = map._inner._keys.values();
        address[] memory addrs;

        assembly {
            addrs := values
        }

        return addrs;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/structs/EnumerableSet.sol)

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
 * ```
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
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
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
    function _contains(Set storage set, bytes32 value)
        private
        view
        returns (bool)
    {
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
    function _at(Set storage set, uint256 index)
        private
        view
        returns (bytes32)
    {
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
    function add(Bytes32Set storage set, bytes32 value)
        internal
        returns (bool)
    {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value)
        internal
        returns (bool)
    {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value)
        internal
        view
        returns (bool)
    {
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
    function at(Bytes32Set storage set, uint256 index)
        internal
        view
        returns (bytes32)
    {
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
    function values(Bytes32Set storage set)
        internal
        view
        returns (bytes32[] memory)
    {
        return _values(set._inner);
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
    function add(AddressSet storage set, address value)
        internal
        returns (bool)
    {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value)
        internal
        returns (bool)
    {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value)
        internal
        view
        returns (bool)
    {
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
    function at(AddressSet storage set, uint256 index)
        internal
        view
        returns (address)
    {
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
    function values(AddressSet storage set)
        internal
        view
        returns (address[] memory)
    {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

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
    function remove(UintSet storage set, uint256 value)
        internal
        returns (bool)
    {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value)
        internal
        view
        returns (bool)
    {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
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
    function at(UintSet storage set, uint256 index)
        internal
        view
        returns (uint256)
    {
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
    function values(UintSet storage set)
        internal
        view
        returns (uint256[] memory)
    {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}