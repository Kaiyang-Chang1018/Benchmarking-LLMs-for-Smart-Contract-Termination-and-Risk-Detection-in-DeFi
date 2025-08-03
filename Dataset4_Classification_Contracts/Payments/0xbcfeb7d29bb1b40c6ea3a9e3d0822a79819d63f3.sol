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
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "./interfaces/V3SpokePoolInterface.sol";

/**
 * @notice SpokePoolVerifier is a contract that verifies that the SpokePool exists on this chain before sending ETH to it.
 * @dev This contract must be deployed via Create2 to the same address on all chains. That way, an errant transaction sent
 * to the wrong chain will be blocked by this contract rather than hitting a dead address. This means that this contract
 * will not work to protect chains, like zkSync, where Create2 address derivations don't match other chains.
 * Source: https://era.zksync.io/docs/reference/architecture/differences-with-ethereum.html#create-create2
 */
contract SpokePoolVerifier {
    using Address for address;

    /**
     * @notice Passthrough function to `depositV3()` on the SpokePool contract.
     * @dev Protects the caller from losing their ETH (or other native token) by reverting if the SpokePool address
     * they intended to call does not exist on this chain. Because this contract can be deployed at the same address
     * everywhere callers should be protected even if the transaction is submitted to an unintended network.
     * This contract should only be used for native token deposits, as this problem only exists for native tokens.
     * @param spokePool Address of the SpokePool contract that the user is intending to call.
     * @param recipient Address to receive funds at on destination chain.
     * @param inputToken Token to lock into this contract to initiate deposit.
     * @param outputToken Token to receive on destination chain.
     * @param inputAmount Amount of tokens to deposit.
     * @param outputAmount Amount of tokens to receive on destination chain.
     * @param destinationChainId Denotes network where user will receive funds from SpokePool by a relayer.
     * @param exclusiveRelayer Address of relayer who can fill this deposit before exclusivityDeadline.
     * @param fillDeadline Timestamp after which this deposit can no longer be filled.
     * @param quoteTimestamp Timestamp used by Across to compute this deposit's fee based on HubPool state. This is
     * passed in because this contract is unaware of current timestamp on HubPool chain (i.e. Ethereum).
     * @param message Arbitrary data that can be used to pass additional information to the recipient along with the tokens.
     * Note: this is intended to be used to pass along instructions for how a contract should use or allocate the tokens.
     */
    function deposit(
        V3SpokePoolInterface spokePool,
        address recipient,
        address inputToken,
        address outputToken,
        uint256 inputAmount,
        uint256 outputAmount,
        uint256 destinationChainId,
        address exclusiveRelayer,
        uint32 quoteTimestamp,
        uint32 fillDeadline,
        uint32 exclusivityDeadline,
        bytes calldata message
    ) external payable {
        require(msg.value == inputAmount, "msg.value != amount");
        require(address(spokePool).isContract(), "spokePool is not a contract");
        // Set msg.sender as the depositor so that msg.sender can speed up the deposit.
        spokePool.depositV3{ value: msg.value }(
            msg.sender,
            recipient,
            inputToken,
            outputToken,
            inputAmount,
            outputAmount,
            destinationChainId,
            exclusiveRelayer,
            quoteTimestamp,
            fillDeadline,
            exclusivityDeadline,
            message
        );
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

// Contains structs and functions used by SpokePool contracts to facilitate universal settlement.
interface V3SpokePoolInterface {
    /**************************************
     *              ENUMS                 *
     **************************************/

    // Fill status tracks on-chain state of deposit, uniquely identified by relayHash.
    enum FillStatus {
        Unfilled,
        RequestedSlowFill,
        Filled
    }
    // Fill type is emitted in the FilledRelay event to assist Dataworker with determining which types of
    // fills to refund (e.g. only fast fills) and whether a fast fill created a sow fill excess.
    enum FillType {
        FastFill,
        // Fast fills are normal fills that do not replace a slow fill request.
        ReplacedSlowFill,
        // Replaced slow fills are fast fills that replace a slow fill request. This type is used by the Dataworker
        // to know when to send excess funds from the SpokePool to the HubPool because they can no longer be used
        // for a slow fill execution.
        SlowFill
        // Slow fills are requested via requestSlowFill and executed by executeSlowRelayLeaf after a bundle containing
        // the slow fill is validated.
    }

    /**************************************
     *              STRUCTS               *
     **************************************/

    // This struct represents the data to fully specify a **unique** relay submitted on this chain.
    // This data is hashed with the chainId() and saved by the SpokePool to prevent collisions and protect against
    // replay attacks on other chains. If any portion of this data differs, the relay is considered to be
    // completely distinct.
    struct V3RelayData {
        // The address that made the deposit on the origin chain.
        address depositor;
        // The recipient address on the destination chain.
        address recipient;
        // This is the exclusive relayer who can fill the deposit before the exclusivity deadline.
        address exclusiveRelayer;
        // Token that is deposited on origin chain by depositor.
        address inputToken;
        // Token that is received on destination chain by recipient.
        address outputToken;
        // The amount of input token deposited by depositor.
        uint256 inputAmount;
        // The amount of output token to be received by recipient.
        uint256 outputAmount;
        // Origin chain id.
        uint256 originChainId;
        // The id uniquely identifying this deposit on the origin chain.
        uint32 depositId;
        // The timestamp on the destination chain after which this deposit can no longer be filled.
        uint32 fillDeadline;
        // The timestamp on the destination chain after which any relayer can fill the deposit.
        uint32 exclusivityDeadline;
        // Data that is forwarded to the recipient.
        bytes message;
    }

    // Contains parameters passed in by someone who wants to execute a slow relay leaf.
    struct V3SlowFill {
        V3RelayData relayData;
        uint256 chainId;
        uint256 updatedOutputAmount;
    }

    // Contains information about a relay to be sent along with additional information that is not unique to the
    // relay itself but is required to know how to process the relay. For example, "updatedX" fields can be used
    // by the relayer to modify fields of the relay with the depositor's permission, and "repaymentChainId" is specified
    // by the relayer to determine where to take a relayer refund, but doesn't affect the uniqueness of the relay.
    struct V3RelayExecutionParams {
        V3RelayData relay;
        bytes32 relayHash;
        uint256 updatedOutputAmount;
        address updatedRecipient;
        bytes updatedMessage;
        uint256 repaymentChainId;
    }

    // Packs together parameters emitted in FilledV3Relay because there are too many emitted otherwise.
    // Similar to V3RelayExecutionParams, these parameters are not used to uniquely identify the deposit being
    // filled so they don't have to be unpacked by all clients.
    struct V3RelayExecutionEventInfo {
        address updatedRecipient;
        bytes updatedMessage;
        uint256 updatedOutputAmount;
        FillType fillType;
    }

    /**************************************
     *              EVENTS                *
     **************************************/

    event V3FundsDeposited(
        address inputToken,
        address outputToken,
        uint256 inputAmount,
        uint256 outputAmount,
        uint256 indexed destinationChainId,
        uint32 indexed depositId,
        uint32 quoteTimestamp,
        uint32 fillDeadline,
        uint32 exclusivityDeadline,
        address indexed depositor,
        address recipient,
        address exclusiveRelayer,
        bytes message
    );

    event RequestedSpeedUpV3Deposit(
        uint256 updatedOutputAmount,
        uint32 indexed depositId,
        address indexed depositor,
        address updatedRecipient,
        bytes updatedMessage,
        bytes depositorSignature
    );

    event FilledV3Relay(
        address inputToken,
        address outputToken,
        uint256 inputAmount,
        uint256 outputAmount,
        uint256 repaymentChainId,
        uint256 indexed originChainId,
        uint32 indexed depositId,
        uint32 fillDeadline,
        uint32 exclusivityDeadline,
        address exclusiveRelayer,
        address indexed relayer,
        address depositor,
        address recipient,
        bytes message,
        V3RelayExecutionEventInfo relayExecutionInfo
    );

    event RequestedV3SlowFill(
        address inputToken,
        address outputToken,
        uint256 inputAmount,
        uint256 outputAmount,
        uint256 indexed originChainId,
        uint32 indexed depositId,
        uint32 fillDeadline,
        uint32 exclusivityDeadline,
        address exclusiveRelayer,
        address depositor,
        address recipient,
        bytes message
    );

    /**************************************
     *              FUNCTIONS             *
     **************************************/

    function depositV3(
        address depositor,
        address recipient,
        address inputToken,
        address outputToken,
        uint256 inputAmount,
        uint256 outputAmount,
        uint256 destinationChainId,
        address exclusiveRelayer,
        uint32 quoteTimestamp,
        uint32 fillDeadline,
        uint32 exclusivityDeadline,
        bytes calldata message
    ) external payable;

    function depositV3Now(
        address depositor,
        address recipient,
        address inputToken,
        address outputToken,
        uint256 inputAmount,
        uint256 outputAmount,
        uint256 destinationChainId,
        address exclusiveRelayer,
        uint32 fillDeadlineOffset,
        uint32 exclusivityDeadline,
        bytes calldata message
    ) external payable;

    function speedUpV3Deposit(
        address depositor,
        uint32 depositId,
        uint256 updatedOutputAmount,
        address updatedRecipient,
        bytes calldata updatedMessage,
        bytes calldata depositorSignature
    ) external;

    function fillV3Relay(V3RelayData calldata relayData, uint256 repaymentChainId) external;

    function fillV3RelayWithUpdatedDeposit(
        V3RelayData calldata relayData,
        uint256 repaymentChainId,
        uint256 updatedOutputAmount,
        address updatedRecipient,
        bytes calldata updatedMessage,
        bytes calldata depositorSignature
    ) external;

    function requestV3SlowFill(V3RelayData calldata relayData) external;

    function executeV3SlowRelayLeaf(
        V3SlowFill calldata slowFillLeaf,
        uint32 rootBundleId,
        bytes32[] calldata proof
    ) external;

    /**************************************
     *              ERRORS                *
     **************************************/

    error DisabledRoute();
    error InvalidQuoteTimestamp();
    error InvalidFillDeadline();
    error InvalidExclusiveRelayer();
    error InvalidExclusivityDeadline();
    error MsgValueDoesNotMatchInputAmount();
    error NotExclusiveRelayer();
    error NoSlowFillsInExclusivityWindow();
    error RelayFilled();
    error InvalidSlowFillRequest();
    error ExpiredFillDeadline();
    error InvalidMerkleProof();
    error InvalidChainId();
    error InvalidMerkleLeaf();
    error ClaimedMerkleLeaf();
    error InvalidPayoutAdjustmentPct();
}