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
// OpenZeppelin Contracts (last updated v4.9.3) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/IERC20Permit.sol";
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

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance + value));
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance - value));
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeWithSelector(token.approve.selector, spender, value);

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, 0));
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
        require(returndata.length == 0 || abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silents catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We cannot use {Address-functionCall} here since this should return false
        // and not revert is the subcall reverts.

        (bool success, bytes memory returndata) = address(token).call(data);
        return
            success && (returndata.length == 0 || abi.decode(returndata, (bool))) && Address.isContract(address(token));
    }
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
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.19;

// Structs
import {UserRequest} from "./core/Structs.sol";

/// Utils /////
import {BaseChecker} from "./utils/BaseChecker.sol";
import {Ownable} from "./utils/Ownable.sol";

//Interfaces
import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "openzeppelin-contracts/token/ERC20/utils/SafeERC20.sol";
import {IFyde} from "./interfaces/IFyde.sol";
import {IGovernanceModule} from "./interfaces/IGovernanceModule.sol";
import {IOracle} from "./interfaces/IOracle.sol";
import {IRelayer} from "./interfaces/IRelayer.sol";

///@title PooledDepositEscrow
///@notice The purpose of this contract is to pool assets from different users to be deposited into
/// fyde at
/// once in order to bootstrap the pool and/or save deposit taxes.
///@dev Following flow -> owner deploys Escrow with whitelisted assets/govAssets -> owner whitelists
/// users -> user deposit assets with/without governance -> escrow period is over and deposits are
/// disabled, start of freeze period -> owner decides how much of the deposited assets they want to
/// keep (setConcentrations) -> freeze period ends -> depositToFyde() requestDeposits on the relayer
/// to transfer funds into fyde (works in batches of 5 assets, has to be called multiple times due
/// to gas limitations) -> wait until fyde has processed transactions -> updateInternalAccounting
/// gets the correct TRSY price after calculated by gelato -> user claim assets, gets TRSY sTRSY and
/// refunds (can claim whenever they want)
/// REVOKE: If owner decides that something is wrong after escrow period, can revoke. Users can then
/// get 100% of deposits refunded
contract PooledDepositEscrow is Ownable, BaseChecker {
  using SafeERC20 for IERC20;

  error CannotClaimForAsset(address);
  error EscrowPeriodEnded();
  error InvalidTimePeriod();
  error InsufficientBalance(address);
  error OnlyDuringFreeze();
  error FydeDepositCompleted();
  error FydeDepositNotCompleted();
  error Revoked();
  error NotRevoked();
  error NotSupportedAsset(address);
  error InternalAccountingNotUpdated();
  error DepositsMightStillBeProcessed();
  error ConcentrationsNotSet();
  error TaxFactorNotZero();
  error PriceNotAvailable(address asset);

  ///@notice Used for precision of division
  uint256 constant SCALING_FACTOR = 1e18;

  ///@notice Max number assets accepted in one request
  uint128 public constant MAX_ASSET_TO_REQUEST = 5;

  ///@notice max gas required for deposit, should correspondent to gov deposit of 5 assets + proxy
  /// creation
  uint128 public constant GAS_TO_FORWARD = 2e6;

  ///@notice timestamp until which users can deposit
  uint128 public immutable ESCROW_PERIOD;

  ///@notice timestamp until owner can set concentrations or revoke
  uint128 public immutable FREEZE_PERIOD;

  ///@notice fyde interface
  IFyde public immutable FYDE;
  ///@notice relayer interface
  IRelayer public immutable RELAYER;
  ///@notice governance module interface
  IGovernanceModule public immutable GOVERNANCE_MODULE;
  ///@notice oracle module interface
  IOracle public immutable ORACLE;

  /// -----------------------------
  ///         Storage
  /// -----------------------------

  // bools used to ensure actions are called in correct order

  ///@notice owner has set concentration
  bool public concentrationsSet;
  ///@notice requested deposit on relayer for all assets
  bool public fydeDepositCompleted;
  ///@notice owner has abborted escrow process
  bool public revoked;
  ///@notice trsy price updated after deposits are processed
  bool public internalAccountingUpdated;
  ///@notice amount of assets deposited to fyde (since done in multiple tx)
  uint256 public assetsTransferred;
  ///@notice measure of expected TRSY when requesting depositing, rescaled to correct value
  uint256 public totalExpectedTrsy;
  ///notice assets allowed for deposit
  address[] public assets;

  ///@dev splits slot into uint128 for std and gov deposit values
  struct Slot {
    uint128 std;
    uint128 gov;
  }

  ///@notice user authorization, can use deposit
  mapping(address => bool) public isUser;

  ///@notice is asset allowed in escrow
  mapping(address => bool) public supportedAssets;
  ///@notice is asset allowed in governance
  mapping(address => bool) public keepGovAllowed;
  ///@notice total token balance in escrow
  mapping(address => Slot) public totalBalance;
  ///@notice amount of token to be deposited into fyde (chosen by escrow owner)
  mapping(address => Slot) public concentrationAmounts;
  ///@notice token amount accepted for fyde / amount deposited into escrow
  mapping(address => Slot) public finalPercentages;
  ///@notice TRSY received for each asset
  mapping(address => Slot) public TRSYBalancesPerAsset;
  ///@notice escrow deposits per user and asset;
  mapping(address => mapping(address => Slot)) public deposits;

  /// -----------------------------
  ///         Events
  /// -----------------------------

  event AssetDeposited(address indexed account, address indexed asset, uint256 amount);
  event ClaimedAndRefunded(address indexed account);
  event ConcentrationAmountsSet(uint128[] amounts, uint128[] govAmounts);
  event FydeDeposit();
  event Refunded(address indexed account, address indexed asset, uint256 refund);
  event EscrowRevoked();
  event InternalAccountingUpdated();

  ///@notice Deploys escrow and sets the assets for deposit and the timing for the scrow.
  ///@param _assets Addresses of whitelisted assets
  ///@param _keepGovAllowed is asset whitelisted for gov deposit true/false
  ///@param _fyde Address of fyde contract
  ///@param _relayer Address of relayer contract
  ///@param _governanceModule Address of governance Module contract
  ///@param _oracle Address of oracle module contract
  ///@param _escrowPeriod length of escrow period in seconds after depoyment
  ///@param _freezePeriod length of freeze period in seconds after freeze period
  constructor(
    address[] memory _assets,
    bool[] memory _keepGovAllowed,
    address _fyde,
    address _relayer,
    address _governanceModule,
    address _oracle,
    uint128 _escrowPeriod,
    uint128 _freezePeriod
  ) Ownable(msg.sender) {
    if (_assets.length != _keepGovAllowed.length) revert InconsistentLengths();

    FYDE = IFyde(_fyde);
    RELAYER = IRelayer(_relayer);
    GOVERNANCE_MODULE = IGovernanceModule(_governanceModule);
    ORACLE = IOracle(_oracle);

    ESCROW_PERIOD = uint128(block.timestamp) + _escrowPeriod;
    FREEZE_PERIOD = ESCROW_PERIOD + _freezePeriod;

    assets = _assets;

    // Activate supported assets
    for (uint256 i = 0; i < _assets.length; ++i) {
      supportedAssets[_assets[i]] = true;
      if (_keepGovAllowed[i]) keepGovAllowed[_assets[i]] = true;
    }
  }

  ///@notice Adds users to whitelist of allwoed depositors
  ///@param _user addresses to whitelist
  function addUser(address[] calldata _user) external onlyOwner {
    for (uint256 i; i < _user.length; ++i) {
      isUser[_user[i]] = true;
    }
  }

  ///@notice Removes users from whitelist
  ///@param _user addresses to remove from
  function removeUser(address[] calldata _user) external onlyOwner {
    for (uint256 i; i < _user.length; ++i) {
      isUser[_user[i]] = false;
    }
  }

  ///@notice Collect ETH from the contract, in case extra eth
  function collectEth(address payable _recipient) external onlyOwner {
    uint256 ethBalance = address(this).balance;
    (bool sent,) = _recipient.call{value: ethBalance}("");
    require(sent);
  }

  ///@notice Deposits asset into escrow
  ///@param asset Asset to deposit
  ///@param amount Amount to deposit
  ///@param keepGovRights standard or governance deposit
  function deposit(address asset, uint128 amount, bool keepGovRights) external onlyUser {
    if (amount == 0) revert ZeroParameter();
    if (uint128(block.timestamp) > ESCROW_PERIOD) revert EscrowPeriodEnded();
    if ((keepGovRights && !keepGovAllowed[asset]) || !supportedAssets[asset]) {
      revert NotSupportedAsset(asset);
    }
    IERC20(asset).safeTransferFrom(msg.sender, address(this), amount);
    if (keepGovRights) {
      deposits[msg.sender][asset].gov += amount;
      totalBalance[asset].gov += amount;
    } else {
      deposits[msg.sender][asset].std += amount;
      totalBalance[asset].std += amount;
    }

    emit AssetDeposited(msg.sender, asset, amount);
  }

  ///@notice Sets amount of tokens to accept into fyde
  ///@param amounts Amount of tokens for standard deposit
  ///@param govAmounts Amount of tokens for governance deposit
  ///@dev inputs have to be of same length and order as storage variable assets
  function setConcentrationAmounts(uint128[] calldata amounts, uint128[] calldata govAmounts)
    external
    onlyOwner
  {
    if (amounts.length != assets.length || govAmounts.length != assets.length) {
      revert InconsistentLengths();
    }
    uint128 time = uint128(block.timestamp);
    if (time < ESCROW_PERIOD || time > FREEZE_PERIOD) revert InvalidTimePeriod();
    for (uint256 i = 0; i < amounts.length; ++i) {
      address asset = assets[i];

      uint128 assetAmount = amounts[i];
      uint128 govAmount = govAmounts[i];

      if (assetAmount == 0 && govAmount == 0) continue;

      uint128 balance = totalBalance[asset].std;
      uint128 govBalance = totalBalance[asset].gov;

      if (assetAmount > balance || govAmount > govBalance) revert InsufficientBalance(asset);

      if (assetAmount != 0) {
        finalPercentages[asset].std =
          uint128(uint256(assetAmount) * SCALING_FACTOR / uint256(balance));
        concentrationAmounts[asset].std = assetAmount;
      }

      if (govAmount != 0) {
        finalPercentages[asset].gov =
          uint128(uint256(govAmount) * SCALING_FACTOR / uint256(govBalance));
        concentrationAmounts[asset].gov = govAmount;
      }
    }
    concentrationsSet = true;
    emit ConcentrationAmountsSet(amounts, govAmounts);
  }

  ///@notice Requests deposit of assets into fyde
  ///@dev due to gas limitations deposits a maximum of 5 assets with and without governance, has to
  /// be called multiple times until all assets are transferred
  function depositToFyde() external payable {
    if (uint128(block.timestamp) <= FREEZE_PERIOD) revert InvalidTimePeriod();
    if (!concentrationsSet) revert ConcentrationsNotSet();
    if (fydeDepositCompleted) revert FydeDepositCompleted();
    if (revoked) revert Revoked();
    (, uint72 taxFactor,,,,) = FYDE.protocolData();
    if (taxFactor != 0) revert TaxFactorNotZero();

    address[] memory assetsList = assets;

    uint256 assetsToTransfer = assetsList.length - assetsTransferred;
    assetsToTransfer =
      assetsToTransfer < MAX_ASSET_TO_REQUEST ? assetsToTransfer : MAX_ASSET_TO_REQUEST;

    uint256 stdRequestLength;
    uint256 govRequestLength;
    for (uint256 i = assetsTransferred; i < assetsTransferred + assetsToTransfer; ++i) {
      if (keepGovAllowed[assetsList[i]] && concentrationAmounts[assetsList[i]].gov != 0) {
        govRequestLength += 1;
      }
      if (concentrationAmounts[assetsList[i]].std != 0) stdRequestLength += 1;
    }

    UserRequest[] memory stdRequest = new UserRequest[](stdRequestLength);
    UserRequest[] memory govRequest = new UserRequest[](govRequestLength);

    uint256 sIdx;
    uint256 gIdx;
    uint256 totalUSDValue;
    for (uint256 i = assetsTransferred; i < assetsTransferred + assetsToTransfer; ++i) {
      uint256 totalAmount = 0;
      if (concentrationAmounts[assetsList[i]].std != 0) {
        // populate request array
        stdRequest[sIdx].asset = assetsList[i];
        stdRequest[sIdx].amount = concentrationAmounts[assetsList[i]].std;
        totalAmount += stdRequest[sIdx].amount;
        // track deposited value
        uint256 usdValue = FYDE.getQuote(stdRequest[sIdx].asset, stdRequest[sIdx].amount);
        if (usdValue == 0) revert PriceNotAvailable(assetsList[i]);
        totalUSDValue += usdValue;
        TRSYBalancesPerAsset[stdRequest[sIdx].asset].std = uint128(usdValue);

        sIdx += 1;
      }

      if (keepGovAllowed[assetsList[i]] && concentrationAmounts[assetsList[i]].gov != 0) {
        govRequest[gIdx].asset = assetsList[i];
        govRequest[gIdx].amount = concentrationAmounts[assetsList[i]].gov;
        totalAmount += govRequest[gIdx].amount;
        gIdx += 1;
      }

      IERC20(assetsList[i]).forceApprove(address(FYDE), totalAmount);
    }

    totalExpectedTrsy += totalUSDValue;

    uint256 ETHToForward = ORACLE.getGweiPrice() * GAS_TO_FORWARD;
    if (stdRequestLength != 0) RELAYER.requestDeposit{value: ETHToForward}(stdRequest, false, 0);
    if (govRequestLength != 0) RELAYER.requestDeposit{value: ETHToForward}(govRequest, true, 0);

    assetsTransferred += assetsToTransfer;
    if (assetsTransferred == assetsList.length) {
      fydeDepositCompleted = true;
      emit FydeDeposit();
    }
  }

  ///@notice Rescale TrsyBalance to be correct. Has to be called after bootstrapLiquidity and before
  /// claiming
  ///@dev At the time of transferring funds into fyde, we dont know the current AUM/TRSY price to
  /// get the amount of trsy we got per asset.
  /// We therefore only store the USD values which are proportional to the correct TRSY balance in
  /// TRSYBalancesPerAsset. After the deposit has been processed,
  /// This function is called to check the actual amount of TRSY minted and rescale the balances
  function updateInternalAccounting() external {
    if (!fydeDepositCompleted) revert FydeDepositNotCompleted();
    // make sure rescale is not called when processing still in progress by checking queue is empty
    if (RELAYER.getNumPendingRequest() != 0) revert DepositsMightStillBeProcessed();

    uint256 actualTrsyBalance = IERC20(address(FYDE)).balanceOf(address(this));

    // SCALING_FACTOR to ensure precision when dividing
    uint256 scalingFactor;
    if (totalExpectedTrsy != 0) {
      scalingFactor = SCALING_FACTOR * actualTrsyBalance / totalExpectedTrsy;
    }

    for (uint256 i; i < assets.length; ++i) {
      address asset = assets[i];
      uint128 rescaledTrsy =
        uint128(uint256(TRSYBalancesPerAsset[asset].std) * scalingFactor / SCALING_FACTOR);
      TRSYBalancesPerAsset[asset].std = rescaledTrsy;
      // for governance we exactly know the balance for each asset - the sTRSY.balanceOf
      if (keepGovAllowed[asset]) {
        TRSYBalancesPerAsset[asset].gov =
          uint128(GOVERNANCE_MODULE.strsyBalance(address(this), asset));
      }
    }

    internalAccountingUpdated = true;
    emit InternalAccountingUpdated();
  }

  ///@notice User claim their TRSY, sTRSY and refund
  ///@param assetsToClaim Assets for which to claim
  function claimAndRefund(address[] calldata assetsToClaim) external {
    if (revoked) revert Revoked();
    if (!fydeDepositCompleted) revert FydeDepositNotCompleted();
    if (!internalAccountingUpdated) revert InternalAccountingNotUpdated();
    uint256 totalClaimedTrsy;
    for (uint256 i; i < assetsToClaim.length; ++i) {
      address asset = assetsToClaim[i];
      uint256 standardDeposit = deposits[msg.sender][asset].std;
      uint256 govDeposit = deposits[msg.sender][asset].gov;
      uint256 totalDeposit = standardDeposit + govDeposit;
      if (totalDeposit == 0) revert CannotClaimForAsset(asset);
      // Update their orginal deposit balance
      uint256 refundAmount = totalDeposit;

      if (standardDeposit > 0) {
        deposits[msg.sender][asset].std = 0;
        uint256 standardFundsUsed =
          standardDeposit * uint256(finalPercentages[asset].std) / SCALING_FACTOR;
        uint256 claimTRSY;
        if (concentrationAmounts[asset].std != 0) {
          claimTRSY = standardFundsUsed * uint256(TRSYBalancesPerAsset[asset].std)
            / uint256(concentrationAmounts[asset].std);
        }
        totalClaimedTrsy += claimTRSY;
        refundAmount -= standardFundsUsed;
      }

      if (govDeposit > 0) {
        deposits[msg.sender][asset].gov = 0;
        uint256 govFundsUsed = govDeposit * uint256(finalPercentages[asset].gov) / SCALING_FACTOR;
        uint256 claimStakedTRSY;
        if (concentrationAmounts[asset].gov != 0) {
          claimStakedTRSY = govFundsUsed * uint256(TRSYBalancesPerAsset[asset].gov)
            / uint256(concentrationAmounts[asset].gov);
        }
        refundAmount -= govFundsUsed;
        IERC20(GOVERNANCE_MODULE.assetToStrsy(asset)).transfer(msg.sender, claimStakedTRSY);
      }
      // Refund user, make sure balance not exceeded in case of rounding error
      if (refundAmount > 0) {
        uint256 escrowBalance = IERC20(asset).balanceOf(address(this));
        refundAmount = escrowBalance > refundAmount ? refundAmount : escrowBalance;
        IERC20(asset).safeTransfer(msg.sender, refundAmount);
      }
    }

    // send all standard TRSY
    IERC20(address(FYDE)).transfer(msg.sender, totalClaimedTrsy);

    emit ClaimedAndRefunded(msg.sender);
  }

  ///@notice User claim their refund if escrow has been revoked
  function refund(address[] calldata assetsToRefund) external {
    if (!revoked) revert NotRevoked();
    for (uint256 i; i < assetsToRefund.length; ++i) {
      address asset = assetsToRefund[i];
      uint256 totalDeposit = deposits[msg.sender][asset].std + deposits[msg.sender][asset].gov;
      deposits[msg.sender][asset].std = 0;
      deposits[msg.sender][asset].gov = 0;
      IERC20(asset).safeTransfer(msg.sender, totalDeposit);
      emit Refunded(msg.sender, asset, totalDeposit);
    }
  }

  ///@notice Abort escrow period and allows user to claim their refund
  function revoke() external onlyOwner {
    uint128 time = uint128(block.timestamp);
    if (time < ESCROW_PERIOD || time > FREEZE_PERIOD) revert OnlyDuringFreeze();
    revoked = true;
    emit EscrowRevoked();
  }

  ///@notice Recovers funds in case something goes wrong
  function returnStuckFunds(address _asset, address _to, uint256 _amount) external onlyOwner {
    IERC20(_asset).safeTransfer(_to, _amount);
  }

  function get_assets() external view returns (address[] memory) {
    return assets;
  }

  ///@notice Returns estimated TRSY for user
  ///@dev Have to be call for front end purpose after updateInternalAccounting
  function getEstimatedTrsy(address _user, address _asset) public view returns (uint256, uint256) {
    Slot memory balance = totalBalance[_asset];
    Slot memory trsy = TRSYBalancesPerAsset[_asset];
    Slot memory dep = deposits[_user][_asset];

    uint256 stdExpTrsy =
      trsy.std != 0 ? uint256(trsy.std) * uint256(dep.std) / (uint256(balance.std)) : 0;
    uint256 govExpTrsy =
      trsy.gov != 0 ? uint256(trsy.gov) * uint256(dep.gov) / (uint256(balance.gov)) : 0;

    return (stdExpTrsy, govExpTrsy);
  }

  ///@dev checks whitelist to allow deposits
  modifier onlyUser() {
    if (!isUser[address(0x0)] && !isUser[msg.sender]) revert Unauthorized();
    _;
  }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.19;

struct AssetInfo {
  uint72 targetConcentration;
  address uniswapPool;
  int72 incentiveFactor;
  uint8 assetDecimals;
  uint8 quoteTokenDecimals;
  address uniswapQuoteToken;
  bool isSupported;
}

struct ProtocolData {
  ///@notice Protocol AUM in USD
  uint256 aum;
  ///@notice multiplicator for the tax equation, 100% = 100e18
  uint72 taxFactor;
  ///@notice Max deviation allowed between AUM from keeper and registry
  uint16 maxAumDeviationAllowed; // Default val 200 == 2 %
  ///@notice block number where AUM was last updated
  uint48 lastAUMUpdateBlock;
  ///@notice annual fee on AUM, in % per year 100% = 100e18
  uint72 managementFee;
  ///@notice last block.timestamp when fee was collected
  uint48 lastFeeCollectionTime;
}

struct UserRequest {
  address asset;
  uint256 amount;
}

struct RequestData {
  uint32 id;
  address requestor;
  address[] assetIn;
  uint256[] amountIn;
  address[] assetOut;
  uint256[] amountOut;
  bool keepGovRights;
  uint256 slippageChecker;
}

struct RequestQ {
  uint64 start;
  uint64 end;
  mapping(uint64 => RequestData) requestData;
}

struct ProcessParam {
  uint256 targetConc;
  uint256 currentConc;
  uint256 usdValue;
  uint256 taxableAmount;
  uint256 taxInUSD;
  uint256 sharesBeforeTax;
  uint256 sharesAfterTax;
}

struct RebalanceParam {
  address asset;
  uint256 assetTotalAmount;
  uint256 assetProxyAmount;
  uint256 assetPrice;
  uint256 sTrsyTotalSupply;
  uint256 trsyPrice;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {RequestData, RebalanceParam, ProcessParam} from "src/core/Structs.sol";

interface IFyde {
  function protocolData() external view returns (uint256, uint72, uint16, uint48, uint72, uint48);

  function isAnyNotSupported(address[] calldata _assets) external view returns (address);

  function isSwapAllowed(address[] calldata _assets) external view returns (address);

  function computeProtocolAUM() external view returns (uint256);

  function getProtocolAUM() external view returns (uint256);

  function updateProtocolAUM(uint256) external;

  function processDeposit(uint256, RequestData calldata) external returns (uint256);

  function processWithdraw(uint256, RequestData calldata) external returns (uint256);

  function totalAssetAccounting(address) external view returns (uint256);

  function proxyAssetAccounting(address) external view returns (uint256);

  function standardAssetAccounting(address) external view returns (uint256);

  function getQuote(address, uint256) external view returns (uint256);

  function getAssetDecimals(address) external view returns (uint8);

  function collectManagementFee() external;

  function processSwap(uint256, RequestData calldata) external returns (int256);

  function getProcessParamDeposit(RequestData memory _req, uint256 _protocolAUM)
    external
    view
    returns (
      ProcessParam[] memory processParam,
      uint256 sharesToMint,
      uint256 taxInTRSY,
      uint256 totalUsdDeposit
    );

  // GOVERNANCE ACCESS FUNCTIONS

  function transferAsset(address _asset, address _recipient, uint256 _amount) external;

  function getRebalanceParams(address _asset) external view returns (RebalanceParam memory);

  function updateAssetProxyAmount(address _asset, uint256 _amount) external;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

interface IGovernanceModule {
  function fyde() external view returns (address);

  function proxyImplementation() external view returns (address);

  function proxyBalance(address proxy, address asset) external view returns (uint256);

  function strsyBalance(address _user, address _govToken) external view returns (uint256 balance);

  function assetToStrsy(address _asset) external view returns (address);

  function userToProxy(address _user) external view returns (address);

  function proxyToUser(address _proxy) external view returns (address);

  function isOnGovernanceWhitelist(address _asset) external view returns (bool);

  function getAllGovUsers() external view returns (address[] memory);

  function isAnyNotOnGovWhitelist(address[] calldata _assets) external view returns (address);

  function getUserGTAllowance(uint256 _TRSYAmount, address _token) external view returns (uint256);

  function govDeposit(
    address _depositor,
    address[] calldata _govToken,
    uint256[] calldata _amount,
    uint256[] calldata _amountTRSY,
    uint256 _totalTRSY
  ) external returns (address proxy);

  function govWithdraw(
    address _user,
    address _asset,
    uint256 _amountToWithdraw,
    uint256 _trsyToBurn
  ) external;

  function onStrsyTransfer(address sender, address _recipient) external;

  function unstakeGov(uint256 _amount, address _asset) external;

  function rebalanceProxy(address _proxy, address _asset, address[] memory _usersToRebalance)
    external;
}
//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {AssetInfo} from "../core/Structs.sol";

interface IOracle {
  function getPriceInUSD(address, AssetInfo calldata) external view returns (uint256);

  function getGweiPrice() external view returns (uint256);
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {RequestData, UserRequest} from "../core/Structs.sol";

interface IRelayer {
  function getNumPendingRequest() external view returns (uint256);

  function getRequest(uint64 idx) external view returns (RequestData memory);

  function requestGovernanceWithdraw(
    UserRequest memory _userRequest,
    address _user,
    uint256 _maxTRSYToPay
  ) external payable;

  function requestWithdraw(UserRequest[] memory _userRequest, uint256 _maxTRSYToPay)
    external
    payable;

  function requestDeposit(
    UserRequest[] memory _userRequest,
    bool _keepGovRights,
    uint256 _minTRSYExpected
  ) external payable;

  function requestSwap(
    address _assetIn,
    uint256 _amountIn,
    address _assetOut,
    uint256 _minAmountOut
  ) external payable;

  function processRequests(uint256 _protocolAUM) external;

  function isQuarantined(address _asset) external view returns (bool);

  function isIncentiveManager(address _incentiveManager) external view returns (bool);

  function MAX_ASSET_TO_REQUEST() external view returns (uint8);

  function actionToGasUsage(bytes32 _actionHash) external view returns (uint256);

  function isUser(address _asset) external view returns (bool);

  function isAnyQuarantined(address[] memory _assets) external view returns (address);
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.19;

abstract contract BaseChecker {
  error ZeroParameter();
  error InconsistentLengths();

  function _checkZeroValue(uint256 val) internal pure {
    if (val == 0) revert ZeroParameter();
  }

  function _checkZeroAddress(address addr) internal pure {
    if (addr == address(0x0)) revert ZeroParameter();
  }

  function _checkForConsistentLength(address[] memory arr1, uint256[] memory arr2) internal pure {
    if (arr1.length != arr2.length) revert InconsistentLengths();
  }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

///@title Ownable contract
/// @notice Simple 2step owner authorization combining solmate and OZ implementation
abstract contract Ownable {
  /*//////////////////////////////////////////////////////////////
                             STORAGE
    //////////////////////////////////////////////////////////////*/

  ///@notice Address of the owner
  address public owner;

  ///@notice Address of the pending owner
  address public pendingOwner;

  /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

  event OwnershipTransferred(address indexed user, address indexed newOner);
  event OwnershipTransferStarted(address indexed user, address indexed newOwner);
  event OwnershipTransferCanceled(address indexed pendingOwner);

  /*//////////////////////////////////////////////////////////////
                                 ERROR
    //////////////////////////////////////////////////////////////*/

  error Unauthorized();

  /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

  constructor(address _owner) {
    owner = _owner;

    emit OwnershipTransferred(address(0), _owner);
  }

  /*//////////////////////////////////////////////////////////////
                             OWNERSHIP LOGIC
    //////////////////////////////////////////////////////////////*/

  ///@notice Transfer ownership to a new address
  ///@param newOwner address of the new owner
  ///@dev newOwner have to acceptOwnership
  function transferOwnership(address newOwner) external onlyOwner {
    pendingOwner = newOwner;
    emit OwnershipTransferStarted(msg.sender, pendingOwner);
  }

  ///@notice NewOwner accept the ownership, it transfer the ownership to newOwner
  function acceptOwnership() external {
    if (msg.sender != pendingOwner) revert Unauthorized();
    address oldOwner = owner;
    owner = pendingOwner;
    delete pendingOwner;
    emit OwnershipTransferred(oldOwner, owner);
  }

  ///@notice Cancel the ownership transfer
  function cancelTransferOwnership() external onlyOwner {
    emit OwnershipTransferCanceled(pendingOwner);
    delete pendingOwner;
  }

  modifier onlyOwner() {
    if (msg.sender != owner) revert Unauthorized();
    _;
  }
}