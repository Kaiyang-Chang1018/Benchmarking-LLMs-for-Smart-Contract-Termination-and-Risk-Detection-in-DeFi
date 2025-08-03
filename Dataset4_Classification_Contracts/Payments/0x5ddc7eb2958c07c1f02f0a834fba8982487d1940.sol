// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface ISafeDepositsSender {
    event Withdraw(address indexed from, address indexed token, uint256 amount);
    event DepositToLockdrop(address indexed lockDrop, address indexed token, uint256 amount);
    event DepositSOVToLockdrop(address indexed lockDrop, uint256 amount);
    event WithdrawBalanceFromSafe(address indexed token, uint256 balance);
    event Pause();
    event Unpause();
    event Stop();
    event SetDepositorAddress(address indexed oldDepositor, address indexed newDepositor);
    event SetLockDropAddress(address indexed oldLockDrop, address indexed newLockDrop);
    event MapDepositorToReceiver(address indexed depositor, address indexed receiver);

    function getSafeAddress() external view returns (address);
    function getLockDropAddress() external view returns (address);
    function getSovTokenAddress() external view returns (address);
    function getDepositorAddress() external view returns (address);
    function isStopped() external view returns (bool);
    function isPaused() external view returns (bool);

    // @note amount > 0 should be checked by the caller
    function withdraw(
        address[] calldata tokens,
        uint256[] calldata amounts,
        address recipient
    ) external;

    function withdrawAll(address[] calldata tokens, address recipient) external;

    function pause() external;

    function unpause() external;

    function stop() external;

    function setDepositorAddress(address _newDepositor) external;

    function sendToLockDropContract(
        address[] calldata tokens,
        uint256[] calldata amounts,
        uint256 sovAmount
    ) external;
}

// OpenZeppelin Contracts (last updated v4.9.3) (token/ERC20/utils/SafeERC20.sol)

// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

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

// OpenZeppelin Contracts (last updated v4.9.4) (token/ERC20/extensions/IERC20Permit.sol)

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 * ==== Security Considerations
 *
 * There are two important considerations concerning the use of `permit`. The first is that a valid permit signature
 * expresses an allowance, and it should not be assumed to convey additional meaning. In particular, it should not be
 * considered as an intention to spend the allowance in any specific way. The second is that because permits have
 * built-in replay protection and can be submitted by anyone, they can be frontrun. A protocol that uses permits should
 * take this into consideration and allow a `permit` call to fail. Combining these two aspects, a pattern that may be
 * generally recommended is:
 *
 * ```solidity
 * function doThingWithPermit(..., uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
 *     try token.permit(msg.sender, address(this), value, deadline, v, r, s) {} catch {}
 *     doThing(..., value);
 * }
 *
 * function doThing(..., uint256 value) public {
 *     token.safeTransferFrom(msg.sender, address(this), value);
 *     ...
 * }
 * ```
 *
 * Observe that: 1) `msg.sender` is used as the owner, leaving no ambiguity as to the signer intent, and 2) the use of
 * `try/catch` allows the permit to fail and makes the code tolerant to frontrunning. (See also
 * {SafeERC20-safeTransferFrom}).
 *
 * Additionally, note that smart contract wallets (such as Argent or Safe) are not able to produce permit signatures, so
 * contracts should have entry points that don't rely on permit.
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
     *
     * CAUTION: See Security Considerations above.
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

// OpenZeppelin Contracts (last updated v4.9.0) (utils/Address.sol)

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

interface GnosisSafe {
    enum Operation {
        Call,
        DelegateCall
    }

    /// @dev Allows a Module to execute a Safe transaction without any further confirmations.
    /// @param to Destination address of module transaction.
    /// @param value Ether value of module transaction.
    /// @param data Data payload of module transaction.
    /// @param operation Operation type of module transaction.
    function execTransactionFromModule(
        address to,
        uint256 value,
        bytes calldata data,
        Operation operation
    ) external returns (bool success);
}

/**
 * @title SafeDepositsSender
 * @notice This contract is a gateway for depositing funds into the Bob locker contracts
 */
contract SafeDepositsSender is ISafeDepositsSender {
    using SafeERC20 for IERC20;
    address public constant ETH_TOKEN_ADDRESS = address(0x01);
    GnosisSafe private immutable SAFE;
    address private immutable SOV_TOKEN_ADDRESS;
    address private lockdropDepositorAddress; // address used by automation script to deposit to the LockDrop contract
    address private lockDropAddress;
    uint256 private stopBlock; // if set the contract is stopped forever - irreversible
    bool private paused;

    /**
     * @param _safeAddress Address of the Gnosis Safe
     * @param _lockDrop Address of the BOB FusionLock contract
     * @param _sovToken Address of the SOV token contract
     * @param _depositor Address of the depositor account
     */
    constructor(address _safeAddress, address _lockDrop, address _sovToken, address _depositor) {
        require(_safeAddress != address(0), "SafeDepositsSender: Invalid safe address");
        require(_lockDrop != address(0), "SafeDepositsSender: Invalid lockdrop address");
        require(_sovToken != address(0), "SafeDepositsSender: Invalid sov token address");
        require(_depositor != address(0), "SafeDepositsSender: Invalid depositor token address");
        SAFE = GnosisSafe(_safeAddress);
        SOV_TOKEN_ADDRESS = _sovToken;
        lockdropDepositorAddress = _depositor;
        lockDropAddress = _lockDrop;
    }

    receive() external payable {}

    // MODIFIERS //

    modifier onlySafe() {
        require(msg.sender == address(SAFE), "SafeDepositsSender: Only Safe");
        _;
    }

    modifier onlyDepositor() {
        require(msg.sender == lockdropDepositorAddress, "SafeDepositsSender: Only Depositor");
        _;
    }

    modifier onlyDepositorOrSafe() {
        require(
            msg.sender == lockdropDepositorAddress || msg.sender == address(SAFE),
            "SafeDepositsSender: Only Depositor or Safe"
        );
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "SafeDepositsSender: Paused");
        _;
    }

    modifier whenPaused() {
        require(paused, "SafeDepositsSender: Not paused");
        _;
    }

    modifier whenUnstopped() {
        require(stopBlock == 0, "SafeDepositsSender: Stopped");
        _;
    }

    modifier notZeroAddress(address _address) {
        require(_address != address(0), "SafeDepositsSender: Invalid address");
        _;
    }

    // CORE FUNCTIONS

    /**
     * @notice Sends tokens to the LockDrop contract
     * @dev This function is for sending tokens to the LockDrop contract for users to receive rewards and to be bridged to the BOB mainnet for Sovryn DEX
     * @dev The function is allowed to be called only by the lockdropDepositorAddress
     * @dev Token amounts and SOV amount to send are calculated offchain
     * @param tokens List of tokens to send
     * @param amounts List of amounts of tokens to send
     * @param sovAmount Amount of SOV tokens to send
     */
    function sendToLockDropContract(
        address[] calldata tokens,
        uint256[] calldata amounts,
        uint256 sovAmount
    ) external onlyDepositorOrSafe whenNotPaused whenUnstopped {
        require(
            tokens.length == amounts.length,
            "SafeDepositsSender: Tokens and amounts length mismatch"
        );
        require(sovAmount > 0, "SafeDepositsSender: Invalid SOV amount");

        bytes memory data;

        for (uint256 i = 0; i < tokens.length; i++) {
            require(
                tokens[i] != SOV_TOKEN_ADDRESS,
                "SafeDepositsSender: SOV token is transferred separately"
            );

            // transfer native token
            uint256 balance;
            uint256 transferAmount;
            if (tokens[i] == ETH_TOKEN_ADDRESS) {
                require(
                    address(SAFE).balance >= amounts[i],
                    "SafeDepositsSender: Not enough eth balance to deposit"
                );
                data = abi.encodeWithSignature("depositEth()");
                require(
                    SAFE.execTransactionFromModule(
                        lockDropAddress,
                        amounts[i],
                        data,
                        GnosisSafe.Operation.Call
                    ),
                    "SafeDepositsSender: Could not deposit ether"
                );

                // withdraw balance to this contract left after deposit to the LockDrop
                balance = address(SAFE).balance;
                transferAmount = balance < amounts[i] ? balance : amounts[i];
                if (transferAmount > 0) {
                    require(
                        SAFE.execTransactionFromModule(
                            address(this),
                            transferAmount,
                            "",
                            GnosisSafe.Operation.Call
                        ),
                        "SafeDepositsSender: Could not withdraw ether after deposit"
                    );
                    emit WithdrawBalanceFromSafe(tokens[i], transferAmount);
                }
            } else {
                // transfer ERC20 tokens
                IERC20 token = IERC20(tokens[i]);
                balance = token.balanceOf(address(SAFE));
                require(balance >= amounts[i], "SafeDepositsSender: Not enough tokens to deposit");

                data = abi.encodeWithSignature(
                    "approve(address,uint256)",
                    lockDropAddress,
                    amounts[i]
                );
                require(
                    SAFE.execTransactionFromModule(tokens[i], 0, data, GnosisSafe.Operation.Call),
                    "SafeDepositsSender: Could not approve token transfer"
                );

                data = abi.encodeWithSignature(
                    "depositERC20(address,uint256)",
                    tokens[i],
                    amounts[i]
                );
                require(
                    SAFE.execTransactionFromModule(
                        lockDropAddress,
                        0,
                        data,
                        GnosisSafe.Operation.Call
                    ),
                    "SafeDepositsSender: Could not deposit token"
                );

                // withdraw balance to this contract left after deposit to the LockDrop
                balance = token.balanceOf(address(SAFE));
                transferAmount = balance < amounts[i] ? balance : amounts[i];
                if (transferAmount > 0) {
                    data = abi.encodeWithSignature(
                        "transfer(address,uint256)",
                        address(this),
                        transferAmount
                    );
                    require(
                        SAFE.execTransactionFromModule(
                            tokens[i],
                            0,
                            data,
                            GnosisSafe.Operation.Call
                        ),
                        "SafeDepositsSender: Could not withdraw token after deposit"
                    );
                    emit WithdrawBalanceFromSafe(tokens[i], transferAmount);
                }
            }
            emit DepositToLockdrop(lockDropAddress, tokens[i], amounts[i]);
        }

        // transfer SOV
        data = abi.encodeWithSignature("approve(address,uint256)", lockDropAddress, sovAmount);
        require(
            SAFE.execTransactionFromModule(SOV_TOKEN_ADDRESS, 0, data, GnosisSafe.Operation.Call),
            "SafeDepositsSender: Could not execute SOV transfer"
        );
        data = abi.encodeWithSignature(
            "depositERC20(address,uint256)",
            SOV_TOKEN_ADDRESS,
            sovAmount
        );
        require(
            SAFE.execTransactionFromModule(lockDropAddress, 0, data, GnosisSafe.Operation.Call),
            "SafeDepositsSender: Could not execute SOV transfer"
        );

        emit DepositSOVToLockdrop(lockDropAddress, sovAmount);
    }

    /// @notice Maps depositor on ethereum to receiver on BOB
    /// @notice Receiver from the last emitted event called by msg.sender will be used
    /// @param receiver Receiver address on BOB. The depositor address will be replaced with the receiver address for distribution of LP tokens and rewards on BOB
    function mapDepositorToReceiver(address receiver) external {
        emit MapDepositorToReceiver(msg.sender, receiver);
    }

    // ADMINISTRATIVE FUNCTIONS //

    /**
     * @notice Execute `operation` (0: Call, 1: DelegateCall) to `to` with `value` (Native Token) from Safe
     * @param to Destination address of module transaction.
     * @param value Ether value of module transaction.
     * @param data Data payload of module transaction.
     * @param operation Operation type of module transaction.
     * @return success Boolean flag indicating if the call succeeded.
     */
    function execTransactionFromSafe(
        address to,
        uint256 value,
        bytes memory data,
        GnosisSafe.Operation operation
    ) external onlySafe returns (bool success) {
        success = execute(to, value, data, operation, type(uint256).max);
    }

    /**
     * @notice Executes either a delegatecall or a call with provided parameters.
     * @dev This method doesn't perform any sanity check of the transaction, such as:
     *      - if the contract at `to` address has code or not
     *      It is the responsibility of the caller to perform such checks.
     * @param to Destination address.
     * @param value Ether value.
     * @param data Data payload.
     * @param operation Operation type.
     * @return success boolean flag indicating if the call succeeded.
     */
    function execute(
        address to,
        uint256 value,
        bytes memory data,
        GnosisSafe.Operation operation,
        uint256 txGas
    ) internal returns (bool success) {
        if (operation == GnosisSafe.Operation.DelegateCall) {
            /* solhint-disable no-inline-assembly */
            /// @solidity memory-safe-assembly
            assembly {
                success := delegatecall(txGas, to, add(data, 0x20), mload(data), 0, 0)
            }
            /* solhint-enable no-inline-assembly */
        } else {
            /* solhint-disable no-inline-assembly */
            /// @solidity memory-safe-assembly
            assembly {
                success := call(txGas, to, value, add(data, 0x20), mload(data), 0, 0)
            }
            /* solhint-enable no-inline-assembly */
        }
    }

    /// @notice There is no check if _newDepositor is not zero on purpose - that could be required

    /**
     * @notice Sets new depositor address
     * @dev Only Safe can call this function
     * @dev New depositor can be zero address
     * @param _newDepositor New depositor address
     */
    function setDepositorAddress(address _newDepositor) external onlySafe {
        emit SetDepositorAddress(lockdropDepositorAddress, _newDepositor);
        lockdropDepositorAddress = _newDepositor;
    }

    /**
     * @notice Sets new LockDrop address
     * @dev Only Safe can call this function
     * @dev New LockDrop can't be zero address
     * @param _newLockdrop New depositor address
     */
    function setLockDropAddress(address _newLockdrop) external onlySafe {
        require(_newLockdrop != address(0), "SafeDepositsSender: Zero address not allowed");
        emit SetLockDropAddress(lockDropAddress, _newLockdrop);
        lockDropAddress = _newLockdrop;
    }

    /**
     * @notice Withdraws tokens from this contract to a recipient address
     * @notice Withdrawal to the Safe address will affect balances and rewards
     * @notice Amount > 0 should be checked by the caller before calling this function
     * @dev Only Safe can call this function
     * @dev Recipient should not be a zero address
     * @param tokens List of token addresses to withdraw
     * @param amounts List of token amounts to withdraw
     * @param recipient Recipient address
     */
    function withdraw(
        address[] calldata tokens,
        uint256[] calldata amounts,
        address recipient
    ) external onlySafe notZeroAddress(recipient) {
        require(
            tokens.length == amounts.length,
            "SafeDepositsSender: Tokens and amounts length mismatch"
        );

        for (uint256 i = 0; i < tokens.length; i++) {
            require(tokens[i] != address(0x00), "SafeDepositsSender: Zero address not allowed");
            require(amounts[i] != 0, "SafeDepositsSender: Zero amount not allowed");
            if (tokens[i] == ETH_TOKEN_ADDRESS) {
                require(
                    address(this).balance >= amounts[i],
                    "SafeDepositsSender: Not enough funds"
                );
                (bool success, ) = payable(recipient).call{ value: amounts[i] }("");
                require(success, "Could not withdraw ether");
                continue;
            }

            IERC20 token = IERC20(tokens[i]);
            uint256 balance = token.balanceOf(address(this));
            require(balance >= amounts[i], "SafeDepositsSender: Not enough funds");

            token.safeTransfer(recipient, amounts[i]);

            emit Withdraw(recipient, tokens[i], amounts[i]);
        }
    }

    /**
     * @notice Withdraws all tokens from this contract to a recipient
     * @notice Amount > 0 should be checked by the caller before calling this function
     * @dev Only Safe can call this function
     * @dev Recipient should not be a zero address
     * @notice Withdrawal to the Safe address will affect balances and rewards
     * @param tokens List of token addresses to withdraw
     * @param recipient Recipient address
     */
    function withdrawAll(
        address[] calldata tokens,
        address recipient
    ) external onlySafe notZeroAddress(recipient) {
        for (uint256 i = 0; i < tokens.length; i++) {
            if (tokens[i] == ETH_TOKEN_ADDRESS) {
                (bool success, ) = payable(recipient).call{ value: address(this).balance }("");
                require(success, "SafeDepositsSender: Could not withdraw ether");
                continue;
            }
            IERC20 token = IERC20(tokens[i]);
            uint256 balance = token.balanceOf(address(this));
            if (balance > 0) {
                token.safeTransfer(recipient, balance);
            }

            emit Withdraw(recipient, tokens[i], balance);
        }
    }

    /// @notice pause the contract - no funds can be sent to the LockDrop contract
    function pause() external onlySafe whenNotPaused {
        paused = true;
        emit Pause();
    }

    /// @notice unpause the contract
    function unpause() external onlySafe whenPaused {
        paused = false;
        emit Unpause();
    }

    /// @notice stops the contract - no funds can be sent to the LockDrop contract, this is irreversible
    function stop() external onlySafe {
        stopBlock = block.number;
        emit Stop();
    }

    // GETTERS //
    function getSafeAddress() external view returns (address) {
        return address(SAFE);
    }

    function getLockDropAddress() external view returns (address) {
        return lockDropAddress;
    }

    function getSovTokenAddress() external view returns (address) {
        return SOV_TOKEN_ADDRESS;
    }

    function getDepositorAddress() external view returns (address) {
        return lockdropDepositorAddress;
    }

    function isStopped() external view returns (bool) {
        return stopBlock != 0;
    }

    function getStopBlock() external view returns (uint256) {
        return stopBlock;
    }

    function isPaused() external view returns (bool) {
        return paused;
    }
}