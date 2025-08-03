// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title IDaiLikePermit
 * @dev Interface for Dai-like permit function allowing token spending via signatures.
 */
interface IDaiLikePermit {
    /**
     * @notice Approves spending of tokens via off-chain signatures.
     * @param holder Token holder's address.
     * @param spender Spender's address.
     * @param nonce Current nonce of the holder.
     * @param expiry Time when the permit expires.
     * @param allowed True to allow, false to disallow spending.
     * @param v, r, s Signature components.
     */
    function permit(
        address holder,
        address spender,
        uint256 nonce,
        uint256 expiry,
        bool allowed,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title IERC7597Permit
 * @dev A new extension for ERC-2612 permit, which has already been added to USDC v2.2.
 */
interface IERC7597Permit {
    /**
     * @notice Update allowance with a signed permit.
     * @dev Signature bytes can be used for both EOA wallets and contract wallets.
     * @param owner Token owner's address (Authorizer).
     * @param spender Spender's address.
     * @param value Amount of allowance.
     * @param deadline The time at which the signature expires (unixtime).
     * @param signature Unstructured bytes signature signed by an EOA wallet or a contract wallet.
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        bytes memory signature
    ) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title IPermit2
 * @dev Interface for a flexible permit system that extends ERC20 tokens to support permits in tokens lacking native permit functionality.
 */
interface IPermit2 {
    /**
     * @dev Struct for holding permit details.
     * @param token ERC20 token address for which the permit is issued.
     * @param amount The maximum amount allowed to spend.
     * @param expiration Timestamp until which the permit is valid.
     * @param nonce An incrementing value for each signature, unique per owner, token, and spender.
     */
    struct PermitDetails {
        address token;
        uint160 amount;
        uint48 expiration;
        uint48 nonce;
    }

    /**
     * @dev Struct for a single token allowance permit.
     * @param details Permit details including token, amount, expiration, and nonce.
     * @param spender Address authorized to spend the tokens.
     * @param sigDeadline Deadline for the permit signature, ensuring timeliness of the permit.
     */
    struct PermitSingle {
        PermitDetails details;
        address spender;
        uint256 sigDeadline;
    }

    /**
     * @dev Struct for packed allowance data to optimize storage.
     * @param amount Amount allowed.
     * @param expiration Permission expiry timestamp.
     * @param nonce Unique incrementing value for tracking allowances.
     */
    struct PackedAllowance {
        uint160 amount;
        uint48 expiration;
        uint48 nonce;
    }

    /**
     * @notice Executes a token transfer from one address to another.
     * @param user The token owner's address.
     * @param spender The address authorized to spend the tokens.
     * @param amount The amount of tokens to transfer.
     * @param token The address of the token being transferred.
     */
    function transferFrom(address user, address spender, uint160 amount, address token) external;

    /**
     * @notice Issues a permit for spending tokens via a signed authorization.
     * @param owner The token owner's address.
     * @param permitSingle Struct containing the permit details.
     * @param signature The signature proving the owner authorized the permit.
     */
    function permit(address owner, PermitSingle memory permitSingle, bytes calldata signature) external;

    /**
     * @notice Retrieves the allowance details between a token owner and spender.
     * @param user The token owner's address.
     * @param token The token address.
     * @param spender The spender's address.
     * @return The packed allowance details.
     */
    function allowance(address user, address token, address spender) external view returns (PackedAllowance memory);

    /**
     * @notice Approves the spender to use up to amount of the specified token up until the expiration
     * @param token The token to approve
     * @param spender The spender address to approve
     * @param amount The approved amount of the token
     * @param expiration The timestamp at which the approval is no longer valid
     * @dev The packed allowance also holds a nonce, which will stay unchanged in approve
     * @dev Setting amount to type(uint160).max sets an unlimited approval
     */
    function approve(address token, address spender, uint160 amount, uint48 expiration) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title IWETH
 * @dev Interface for wrapper as WETH-like token.
 */
interface IWETH is IERC20 {
    /**
     * @notice Emitted when Ether is deposited to get wrapper tokens.
     */
    event Deposit(address indexed dst, uint256 wad);

    /**
     * @notice Emitted when wrapper tokens is withdrawn as Ether.
     */
    event Withdrawal(address indexed src, uint256 wad);

    /**
     * @notice Deposit Ether to get wrapper tokens.
     */
    function deposit() external payable;

    /**
     * @notice Withdraw wrapped tokens as Ether.
     * @param amount Amount of wrapped tokens to withdraw.
     */
    function withdraw(uint256 amount) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title RevertReasonForwarder
 * @notice Provides utilities for forwarding and retrieving revert reasons from failed external calls.
 */
library RevertReasonForwarder {
    /**
     * @dev Forwards the revert reason from the latest external call.
     * This method allows propagating the revert reason of a failed external call to the caller.
     */
    function reRevert() internal pure {
        // bubble up revert reason from latest external call
        assembly ("memory-safe") { // solhint-disable-line no-inline-assembly
            let ptr := mload(0x40)
            returndatacopy(ptr, 0, returndatasize())
            revert(ptr, returndatasize())
        }
    }

    /**
     * @dev Retrieves the revert reason from the latest external call.
     * This method enables capturing the revert reason of a failed external call for inspection or processing.
     * @return reason The latest external call revert reason.
     */
    function reReason() internal pure returns (bytes memory reason) {
        assembly ("memory-safe") { // solhint-disable-line no-inline-assembly
            reason := mload(0x40)
            let length := returndatasize()
            mstore(reason, length)
            returndatacopy(add(reason, 0x20), 0, length)
            mstore(0x40, add(reason, add(0x20, length)))
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";
import "../interfaces/IDaiLikePermit.sol";
import "../interfaces/IPermit2.sol";
import "../interfaces/IERC7597Permit.sol";
import "../interfaces/IWETH.sol";
import "../libraries/RevertReasonForwarder.sol";

/**
 * @title Implements efficient safe methods for ERC20 interface.
 * @notice Compared to the standard ERC20, this implementation offers several enhancements:
 * 1. more gas-efficient, providing significant savings in transaction costs.
 * 2. support for different permit implementations
 * 3. forceApprove functionality
 * 4. support for WETH deposit and withdraw
 */
library SafeERC20 {
    error SafeTransferFailed();
    error SafeTransferFromFailed();
    error ForceApproveFailed();
    error SafeIncreaseAllowanceFailed();
    error SafeDecreaseAllowanceFailed();
    error SafePermitBadLength();
    error Permit2TransferAmountTooHigh();

    // Uniswap Permit2 address
    address private constant _PERMIT2 = 0x000000000022D473030F116dDEE9F6B43aC78BA3;
    bytes4 private constant _PERMIT_LENGTH_ERROR = 0x68275857;  // SafePermitBadLength.selector
    uint256 private constant _RAW_CALL_GAS_LIMIT = 5000;

    /**
     * @notice Fetches the balance of a specific ERC20 token held by an account.
     * Consumes less gas then regular `ERC20.balanceOf`.
     * @dev Note that the implementation does not perform dirty bits cleaning, so it is the
     * responsibility of the caller to make sure that the higher 96 bits of the `account` parameter are clean.
     * @param token The IERC20 token contract for which the balance will be fetched.
     * @param account The address of the account whose token balance will be fetched.
     * @return tokenBalance The balance of the specified ERC20 token held by the account.
     */
    function safeBalanceOf(
        IERC20 token,
        address account
    ) internal view returns(uint256 tokenBalance) {
        bytes4 selector = IERC20.balanceOf.selector;
        assembly ("memory-safe") { // solhint-disable-line no-inline-assembly
            mstore(0x00, selector)
            mstore(0x04, account)
            let success := staticcall(gas(), token, 0x00, 0x24, 0x00, 0x20)
            tokenBalance := mload(0)

            if or(iszero(success), lt(returndatasize(), 0x20)) {
                let ptr := mload(0x40)
                returndatacopy(ptr, 0, returndatasize())
                revert(ptr, returndatasize())
            }
        }
    }

    /**
     * @notice Attempts to safely transfer tokens from one address to another.
     * @dev If permit2 is true, uses the Permit2 standard; otherwise uses the standard ERC20 transferFrom.
     * Either requires `true` in return data, or requires target to be smart-contract and empty return data.
     * Note that the implementation does not perform dirty bits cleaning, so it is the responsibility of
     * the caller to make sure that the higher 96 bits of the `from` and `to` parameters are clean.
     * @param token The IERC20 token contract from which the tokens will be transferred.
     * @param from The address from which the tokens will be transferred.
     * @param to The address to which the tokens will be transferred.
     * @param amount The amount of tokens to transfer.
     * @param permit2 If true, uses the Permit2 standard for the transfer; otherwise uses the standard ERC20 transferFrom.
     */
    function safeTransferFromUniversal(
        IERC20 token,
        address from,
        address to,
        uint256 amount,
        bool permit2
    ) internal {
        if (permit2) {
            safeTransferFromPermit2(token, from, to, amount);
        } else {
            safeTransferFrom(token, from, to, amount);
        }
    }

    /**
     * @notice Attempts to safely transfer tokens from one address to another using the ERC20 standard.
     * @dev Either requires `true` in return data, or requires target to be smart-contract and empty return data.
     * Note that the implementation does not perform dirty bits cleaning, so it is the responsibility of
     * the caller to make sure that the higher 96 bits of the `from` and `to` parameters are clean.
     * @param token The IERC20 token contract from which the tokens will be transferred.
     * @param from The address from which the tokens will be transferred.
     * @param to The address to which the tokens will be transferred.
     * @param amount The amount of tokens to transfer.
     */
    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        bytes4 selector = token.transferFrom.selector;
        bool success;
        assembly ("memory-safe") { // solhint-disable-line no-inline-assembly
            let data := mload(0x40)

            mstore(data, selector)
            mstore(add(data, 0x04), from)
            mstore(add(data, 0x24), to)
            mstore(add(data, 0x44), amount)
            success := call(gas(), token, 0, data, 100, 0x0, 0x20)
            if success {
                switch returndatasize()
                case 0 {
                    success := gt(extcodesize(token), 0)
                }
                default {
                    success := and(gt(returndatasize(), 31), eq(mload(0), 1))
                }
            }
        }
        if (!success) revert SafeTransferFromFailed();
    }

    /**
     * @notice Attempts to safely transfer tokens from one address to another using the Permit2 standard.
     * @dev Either requires `true` in return data, or requires target to be smart-contract and empty return data.
     * Note that the implementation does not perform dirty bits cleaning, so it is the responsibility of
     * the caller to make sure that the higher 96 bits of the `from` and `to` parameters are clean.
     * @param token The IERC20 token contract from which the tokens will be transferred.
     * @param from The address from which the tokens will be transferred.
     * @param to The address to which the tokens will be transferred.
     * @param amount The amount of tokens to transfer.
     */
    function safeTransferFromPermit2(
        IERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        if (amount > type(uint160).max) revert Permit2TransferAmountTooHigh();
        bytes4 selector = IPermit2.transferFrom.selector;
        bool success;
        assembly ("memory-safe") { // solhint-disable-line no-inline-assembly
            let data := mload(0x40)

            mstore(data, selector)
            mstore(add(data, 0x04), from)
            mstore(add(data, 0x24), to)
            mstore(add(data, 0x44), amount)
            mstore(add(data, 0x64), token)
            success := call(gas(), _PERMIT2, 0, data, 0x84, 0x0, 0x0)
            if success {
                success := gt(extcodesize(_PERMIT2), 0)
            }
        }
        if (!success) revert SafeTransferFromFailed();
    }

    /**
     * @notice Attempts to safely transfer tokens to another address.
     * @dev Either requires `true` in return data, or requires target to be smart-contract and empty return data.
     * Note that the implementation does not perform dirty bits cleaning, so it is the responsibility of
     * the caller to make sure that the higher 96 bits of the `to` parameter are clean.
     * @param token The IERC20 token contract from which the tokens will be transferred.
     * @param to The address to which the tokens will be transferred.
     * @param value The amount of tokens to transfer.
     */
    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        if (!_makeCall(token, token.transfer.selector, to, value)) {
            revert SafeTransferFailed();
        }
    }

    /**
     * @notice Attempts to approve a spender to spend a certain amount of tokens.
     * @dev If `approve(from, to, amount)` fails, it tries to set the allowance to zero, and retries the `approve` call.
     * Note that the implementation does not perform dirty bits cleaning, so it is the responsibility of
     * the caller to make sure that the higher 96 bits of the `spender` parameter are clean.
     * @param token The IERC20 token contract on which the call will be made.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     */
    function forceApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        if (!_makeCall(token, token.approve.selector, spender, value)) {
            if (
                !_makeCall(token, token.approve.selector, spender, 0) ||
                !_makeCall(token, token.approve.selector, spender, value)
            ) {
                revert ForceApproveFailed();
            }
        }
    }

    /**
     * @notice Safely increases the allowance of a spender.
     * @dev Increases with safe math check. Checks if the increased allowance will overflow, if yes, then it reverts the transaction.
     * Then uses `forceApprove` to increase the allowance.
     * Note that the implementation does not perform dirty bits cleaning, so it is the responsibility of
     * the caller to make sure that the higher 96 bits of the `spender` parameter are clean.
     * @param token The IERC20 token contract on which the call will be made.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to increase the allowance by.
     */
    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 allowance = token.allowance(address(this), spender);
        if (value > type(uint256).max - allowance) revert SafeIncreaseAllowanceFailed();
        forceApprove(token, spender, allowance + value);
    }

    /**
     * @notice Safely decreases the allowance of a spender.
     * @dev Decreases with safe math check. Checks if the decreased allowance will underflow, if yes, then it reverts the transaction.
     * Then uses `forceApprove` to increase the allowance.
     * Note that the implementation does not perform dirty bits cleaning, so it is the responsibility of
     * the caller to make sure that the higher 96 bits of the `spender` parameter are clean.
     * @param token The IERC20 token contract on which the call will be made.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to decrease the allowance by.
     */
    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 allowance = token.allowance(address(this), spender);
        if (value > allowance) revert SafeDecreaseAllowanceFailed();
        forceApprove(token, spender, allowance - value);
    }

    /**
     * @notice Attempts to execute the `permit` function on the provided token with the sender and contract as parameters.
     * Permit type is determined automatically based on permit calldata (IERC20Permit, IDaiLikePermit, and IPermit2).
     * @dev Wraps `tryPermit` function and forwards revert reason if permit fails.
     * @param token The IERC20 token to execute the permit function on.
     * @param permit The permit data to be used in the function call.
     */
    function safePermit(IERC20 token, bytes calldata permit) internal {
        if (!tryPermit(token, msg.sender, address(this), permit)) RevertReasonForwarder.reRevert();
    }

    /**
     * @notice Attempts to execute the `permit` function on the provided token with custom owner and spender parameters.
     * Permit type is determined automatically based on permit calldata (IERC20Permit, IDaiLikePermit, and IPermit2).
     * @dev Wraps `tryPermit` function and forwards revert reason if permit fails.
     * Note that the implementation does not perform dirty bits cleaning, so it is the responsibility of
     * the caller to make sure that the higher 96 bits of the `owner` and `spender` parameters are clean.
     * @param token The IERC20 token to execute the permit function on.
     * @param owner The owner of the tokens for which the permit is made.
     * @param spender The spender allowed to spend the tokens by the permit.
     * @param permit The permit data to be used in the function call.
     */
    function safePermit(IERC20 token, address owner, address spender, bytes calldata permit) internal {
        if (!tryPermit(token, owner, spender, permit)) RevertReasonForwarder.reRevert();
    }

    /**
     * @notice Attempts to execute the `permit` function on the provided token with the sender and contract as parameters.
     * @dev Invokes `tryPermit` with sender as owner and contract as spender.
     * @param token The IERC20 token to execute the permit function on.
     * @param permit The permit data to be used in the function call.
     * @return success Returns true if the permit function was successfully executed, false otherwise.
     */
    function tryPermit(IERC20 token, bytes calldata permit) internal returns(bool success) {
        return tryPermit(token, msg.sender, address(this), permit);
    }

    /**
     * @notice The function attempts to call the permit function on a given ERC20 token.
     * @dev The function is designed to support a variety of permit functions, namely: IERC20Permit, IDaiLikePermit, IERC7597Permit and IPermit2.
     * It accommodates both Compact and Full formats of these permit types.
     * Please note, it is expected that the `expiration` parameter for the compact Permit2 and the `deadline` parameter
     * for the compact Permit are to be incremented by one before invoking this function. This approach is motivated by
     * gas efficiency considerations; as the unlimited expiration period is likely to be the most common scenario, and
     * zeros are cheaper to pass in terms of gas cost. Thus, callers should increment the expiration or deadline by one
     * before invocation for optimized performance.
     * Note that the implementation does not perform dirty bits cleaning, so it is the responsibility of
     * the caller to make sure that the higher 96 bits of the `owner` and `spender` parameters are clean.
     * @param token The address of the ERC20 token on which to call the permit function.
     * @param owner The owner of the tokens. This address should have signed the off-chain permit.
     * @param spender The address which will be approved for transfer of tokens.
     * @param permit The off-chain permit data, containing different fields depending on the type of permit function.
     * @return success A boolean indicating whether the permit call was successful.
     */
    function tryPermit(IERC20 token, address owner, address spender, bytes calldata permit) internal returns(bool success) {
        // load function selectors for different permit standards
        bytes4 permitSelector = IERC20Permit.permit.selector;
        bytes4 daiPermitSelector = IDaiLikePermit.permit.selector;
        bytes4 permit2Selector = IPermit2.permit.selector;
        bytes4 erc7597PermitSelector = IERC7597Permit.permit.selector;
        assembly ("memory-safe") { // solhint-disable-line no-inline-assembly
            let ptr := mload(0x40)

            // Switch case for different permit lengths, indicating different permit standards
            switch permit.length
            // Compact IERC20Permit
            case 100 {
                mstore(ptr, permitSelector)     // store selector
                mstore(add(ptr, 0x04), owner)   // store owner
                mstore(add(ptr, 0x24), spender) // store spender

                // Compact IERC20Permit.permit(uint256 value, uint32 deadline, uint256 r, uint256 vs)
                {  // stack too deep
                    let deadline := shr(224, calldataload(add(permit.offset, 0x20))) // loads permit.offset 0x20..0x23
                    let vs := calldataload(add(permit.offset, 0x44))                 // loads permit.offset 0x44..0x63

                    calldatacopy(add(ptr, 0x44), permit.offset, 0x20)            // store value     = copy permit.offset 0x00..0x19
                    mstore(add(ptr, 0x64), sub(deadline, 1))                     // store deadline  = deadline - 1
                    mstore(add(ptr, 0x84), add(27, shr(255, vs)))                // store v         = most significant bit of vs + 27 (27 or 28)
                    calldatacopy(add(ptr, 0xa4), add(permit.offset, 0x24), 0x20) // store r         = copy permit.offset 0x24..0x43
                    mstore(add(ptr, 0xc4), shr(1, shl(1, vs)))                   // store s         = vs without most significant bit
                }
                // IERC20Permit.permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s)
                success := call(gas(), token, 0, ptr, 0xe4, 0, 0)
            }
            // Compact IDaiLikePermit
            case 72 {
                mstore(ptr, daiPermitSelector)  // store selector
                mstore(add(ptr, 0x04), owner)   // store owner
                mstore(add(ptr, 0x24), spender) // store spender

                // Compact IDaiLikePermit.permit(uint32 nonce, uint32 expiry, uint256 r, uint256 vs)
                {  // stack too deep
                    let expiry := shr(224, calldataload(add(permit.offset, 0x04))) // loads permit.offset 0x04..0x07
                    let vs := calldataload(add(permit.offset, 0x28))               // loads permit.offset 0x28..0x47

                    mstore(add(ptr, 0x44), shr(224, calldataload(permit.offset))) // store nonce   = copy permit.offset 0x00..0x03
                    mstore(add(ptr, 0x64), sub(expiry, 1))                        // store expiry  = expiry - 1
                    mstore(add(ptr, 0x84), true)                                  // store allowed = true
                    mstore(add(ptr, 0xa4), add(27, shr(255, vs)))                 // store v       = most significant bit of vs + 27 (27 or 28)
                    calldatacopy(add(ptr, 0xc4), add(permit.offset, 0x08), 0x20)  // store r       = copy permit.offset 0x08..0x27
                    mstore(add(ptr, 0xe4), shr(1, shl(1, vs)))                    // store s       = vs without most significant bit
                }
                // IDaiLikePermit.permit(address holder, address spender, uint256 nonce, uint256 expiry, bool allowed, uint8 v, bytes32 r, bytes32 s)
                success := call(gas(), token, 0, ptr, 0x104, 0, 0)
            }
            // IERC20Permit
            case 224 {
                mstore(ptr, permitSelector)
                calldatacopy(add(ptr, 0x04), permit.offset, permit.length) // copy permit calldata
                // IERC20Permit.permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s)
                success := call(gas(), token, 0, ptr, 0xe4, 0, 0)
            }
            // IDaiLikePermit
            case 256 {
                mstore(ptr, daiPermitSelector)
                calldatacopy(add(ptr, 0x04), permit.offset, permit.length) // copy permit calldata
                // IDaiLikePermit.permit(address holder, address spender, uint256 nonce, uint256 expiry, bool allowed, uint8 v, bytes32 r, bytes32 s)
                success := call(gas(), token, 0, ptr, 0x104, 0, 0)
            }
            // Compact IPermit2
            case 96 {
                // Compact IPermit2.permit(uint160 amount, uint32 expiration, uint32 nonce, uint32 sigDeadline, uint256 r, uint256 vs)
                mstore(ptr, permit2Selector)  // store selector
                mstore(add(ptr, 0x04), owner) // store owner
                mstore(add(ptr, 0x24), token) // store token

                calldatacopy(add(ptr, 0x50), permit.offset, 0x14)             // store amount = copy permit.offset 0x00..0x13
                // and(0xffffffffffff, ...) - conversion to uint48
                mstore(add(ptr, 0x64), and(0xffffffffffff, sub(shr(224, calldataload(add(permit.offset, 0x14))), 1))) // store expiration = ((permit.offset 0x14..0x17 - 1) & 0xffffffffffff)
                mstore(add(ptr, 0x84), shr(224, calldataload(add(permit.offset, 0x18)))) // store nonce = copy permit.offset 0x18..0x1b
                mstore(add(ptr, 0xa4), spender)                               // store spender
                // and(0xffffffffffff, ...) - conversion to uint48
                mstore(add(ptr, 0xc4), and(0xffffffffffff, sub(shr(224, calldataload(add(permit.offset, 0x1c))), 1))) // store sigDeadline = ((permit.offset 0x1c..0x1f - 1) & 0xffffffffffff)
                mstore(add(ptr, 0xe4), 0x100)                                 // store offset = 256
                mstore(add(ptr, 0x104), 0x40)                                 // store length = 64
                calldatacopy(add(ptr, 0x124), add(permit.offset, 0x20), 0x20) // store r      = copy permit.offset 0x20..0x3f
                calldatacopy(add(ptr, 0x144), add(permit.offset, 0x40), 0x20) // store vs     = copy permit.offset 0x40..0x5f
                // IPermit2.permit(address owner, PermitSingle calldata permitSingle, bytes calldata signature)
                success := call(gas(), _PERMIT2, 0, ptr, 0x164, 0, 0)
            }
            // IPermit2
            case 352 {
                mstore(ptr, permit2Selector)
                calldatacopy(add(ptr, 0x04), permit.offset, permit.length) // copy permit calldata
                // IPermit2.permit(address owner, PermitSingle calldata permitSingle, bytes calldata signature)
                success := call(gas(), _PERMIT2, 0, ptr, 0x164, 0, 0)
            }
            // Dynamic length
            default {
                mstore(ptr, erc7597PermitSelector)
                calldatacopy(add(ptr, 0x04), permit.offset, permit.length) // copy permit calldata
                // IERC7597Permit.permit(address owner, address spender, uint256 value, uint256 deadline, bytes memory signature)
                success := call(gas(), token, 0, ptr, add(permit.length, 4), 0, 0)
            }
        }
    }

    /**
     * @dev Executes a low level call to a token contract, making it resistant to reversion and erroneous boolean returns.
     * @param token The IERC20 token contract on which the call will be made.
     * @param selector The function signature that is to be called on the token contract.
     * @param to The address to which the token amount will be transferred.
     * @param amount The token amount to be transferred.
     * @return success A boolean indicating if the call was successful. Returns 'true' on success and 'false' on failure.
     * In case of success but no returned data, validates that the contract code exists.
     * In case of returned data, ensures that it's a boolean `true`.
     */
    function _makeCall(
        IERC20 token,
        bytes4 selector,
        address to,
        uint256 amount
    ) private returns (bool success) {
        assembly ("memory-safe") { // solhint-disable-line no-inline-assembly
            let data := mload(0x40)

            mstore(data, selector)
            mstore(add(data, 0x04), to)
            mstore(add(data, 0x24), amount)
            success := call(gas(), token, 0, data, 0x44, 0x0, 0x20)
            if success {
                switch returndatasize()
                case 0 {
                    success := gt(extcodesize(token), 0)
                }
                default {
                    success := and(gt(returndatasize(), 31), eq(mload(0), 1))
                }
            }
        }
    }

    /**
     * @notice Safely deposits a specified amount of Ether into the IWETH contract. Consumes less gas then regular `IWETH.deposit`.
     * @param weth The IWETH token contract.
     * @param amount The amount of Ether to deposit into the IWETH contract.
     */
    function safeDeposit(IWETH weth, uint256 amount) internal {
        if (amount > 0) {
            bytes4 selector = IWETH.deposit.selector;
            assembly ("memory-safe") { // solhint-disable-line no-inline-assembly
                mstore(0, selector)
                if iszero(call(gas(), weth, amount, 0, 4, 0, 0)) {
                    let ptr := mload(0x40)
                    returndatacopy(ptr, 0, returndatasize())
                    revert(ptr, returndatasize())
                }
            }
        }
    }

    /**
     * @notice Safely withdraws a specified amount of wrapped Ether from the IWETH contract. Consumes less gas then regular `IWETH.withdraw`.
     * @dev Uses inline assembly to interact with the IWETH contract.
     * @param weth The IWETH token contract.
     * @param amount The amount of wrapped Ether to withdraw from the IWETH contract.
     */
    function safeWithdraw(IWETH weth, uint256 amount) internal {
        bytes4 selector = IWETH.withdraw.selector;
        assembly ("memory-safe") {  // solhint-disable-line no-inline-assembly
            mstore(0, selector)
            mstore(4, amount)
            if iszero(call(gas(), weth, 0, 0, 0x24, 0, 0)) {
                let ptr := mload(0x40)
                returndatacopy(ptr, 0, returndatasize())
                revert(ptr, returndatasize())
            }
        }
    }

    /**
     * @notice Safely withdraws a specified amount of wrapped Ether from the IWETH contract to a specified recipient.
     * Consumes less gas then regular `IWETH.withdraw`.
     * @param weth The IWETH token contract.
     * @param amount The amount of wrapped Ether to withdraw from the IWETH contract.
     * @param to The recipient of the withdrawn Ether.
     */
    function safeWithdrawTo(IWETH weth, uint256 amount, address to) internal {
        safeWithdraw(weth, amount);
        if (to != address(this)) {
            assembly ("memory-safe") {  // solhint-disable-line no-inline-assembly
                if iszero(call(_RAW_CALL_GAS_LIMIT, to, amount, 0, 0, 0, 0)) {
                    let ptr := mload(0x40)
                    returndatacopy(ptr, 0, returndatasize())
                    revert(ptr, returndatasize())
                }
            }
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.20;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```solidity
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 *
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Storage of the initializable contract.
     *
     * It's implemented on a custom ERC-7201 namespace to reduce the risk of storage collisions
     * when using with upgradeable contracts.
     *
     * @custom:storage-location erc7201:openzeppelin.storage.Initializable
     */
    struct InitializableStorage {
        /**
         * @dev Indicates that the contract has been initialized.
         */
        uint64 _initialized;
        /**
         * @dev Indicates that the contract is in the process of being initialized.
         */
        bool _initializing;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.Initializable")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant INITIALIZABLE_STORAGE = 0xf0c57e16840df040f15088dc2f81fe391c3923bec73e23a9662efc9c229c6a00;

    /**
     * @dev The contract is already initialized.
     */
    error InvalidInitialization();

    /**
     * @dev The contract is not initializing.
     */
    error NotInitializing();

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint64 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that in the context of a constructor an `initializer` may be invoked any
     * number of times. This behavior in the constructor can be useful during testing and is not expected to be used in
     * production.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        // solhint-disable-next-line var-name-mixedcase
        InitializableStorage storage $ = _getInitializableStorage();

        // Cache values to avoid duplicated sloads
        bool isTopLevelCall = !$._initializing;
        uint64 initialized = $._initialized;

        // Allowed calls:
        // - initialSetup: the contract is not in the initializing state and no previous version was
        //                 initialized
        // - construction: the contract is initialized at version 1 (no reininitialization) and the
        //                 current contract is just being deployed
        bool initialSetup = initialized == 0 && isTopLevelCall;
        bool construction = initialized == 1 && address(this).code.length == 0;

        if (!initialSetup && !construction) {
            revert InvalidInitialization();
        }
        $._initialized = 1;
        if (isTopLevelCall) {
            $._initializing = true;
        }
        _;
        if (isTopLevelCall) {
            $._initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: Setting the version to 2**64 - 1 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint64 version) {
        // solhint-disable-next-line var-name-mixedcase
        InitializableStorage storage $ = _getInitializableStorage();

        if ($._initializing || $._initialized >= version) {
            revert InvalidInitialization();
        }
        $._initialized = version;
        $._initializing = true;
        _;
        $._initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        _checkInitializing();
        _;
    }

    /**
     * @dev Reverts if the contract is not in an initializing state. See {onlyInitializing}.
     */
    function _checkInitializing() internal view virtual {
        if (!_isInitializing()) {
            revert NotInitializing();
        }
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        // solhint-disable-next-line var-name-mixedcase
        InitializableStorage storage $ = _getInitializableStorage();

        if ($._initializing) {
            revert InvalidInitialization();
        }
        if ($._initialized != type(uint64).max) {
            $._initialized = type(uint64).max;
            emit Initialized(type(uint64).max);
        }
    }

    /**
     * @dev Returns the highest version that has been initialized. See {reinitializer}.
     */
    function _getInitializedVersion() internal view returns (uint64) {
        return _getInitializableStorage()._initialized;
    }

    /**
     * @dev Returns `true` if the contract is currently initializing. See {onlyInitializing}.
     */
    function _isInitializing() internal view returns (bool) {
        return _getInitializableStorage()._initializing;
    }

    /**
     * @dev Returns a pointer to the storage namespace.
     */
    // solhint-disable-next-line var-name-mixedcase
    function _getInitializableStorage() private pure returns (InitializableStorage storage $) {
        assembly {
            $.slot := INITIALIZABLE_STORAGE
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (proxy/utils/UUPSUpgradeable.sol)

pragma solidity ^0.8.20;

import {IERC1822Proxiable} from "@openzeppelin/contracts/interfaces/draft-IERC1822.sol";
import {ERC1967Utils} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol";
import {Initializable} from "./Initializable.sol";

/**
 * @dev An upgradeability mechanism designed for UUPS proxies. The functions included here can perform an upgrade of an
 * {ERC1967Proxy}, when this contract is set as the implementation behind such a proxy.
 *
 * A security mechanism ensures that an upgrade does not turn off upgradeability accidentally, although this risk is
 * reinstated if the upgrade retains upgradeability but removes the security mechanism, e.g. by replacing
 * `UUPSUpgradeable` with a custom implementation of upgrades.
 *
 * The {_authorizeUpgrade} function must be overridden to include access restriction to the upgrade mechanism.
 */
abstract contract UUPSUpgradeable is Initializable, IERC1822Proxiable {
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable
    address private immutable __self = address(this);

    /**
     * @dev The version of the upgrade interface of the contract. If this getter is missing, both `upgradeTo(address)`
     * and `upgradeToAndCall(address,bytes)` are present, and `upgradeTo` must be used if no function should be called,
     * while `upgradeToAndCall` will invoke the `receive` function if the second argument is the empty byte string.
     * If the getter returns `"5.0.0"`, only `upgradeToAndCall(address,bytes)` is present, and the second argument must
     * be the empty byte string if no function should be called, making it impossible to invoke the `receive` function
     * during an upgrade.
     */
    string public constant UPGRADE_INTERFACE_VERSION = "5.0.0";

    /**
     * @dev The call is from an unauthorized context.
     */
    error UUPSUnauthorizedCallContext();

    /**
     * @dev The storage `slot` is unsupported as a UUID.
     */
    error UUPSUnsupportedProxiableUUID(bytes32 slot);

    /**
     * @dev Check that the execution is being performed through a delegatecall call and that the execution context is
     * a proxy contract with an implementation (as defined in ERC1967) pointing to self. This should only be the case
     * for UUPS and transparent proxies that are using the current contract as their implementation. Execution of a
     * function through ERC1167 minimal proxies (clones) would not normally pass this test, but is not guaranteed to
     * fail.
     */
    modifier onlyProxy() {
        _checkProxy();
        _;
    }

    /**
     * @dev Check that the execution is not being performed through a delegate call. This allows a function to be
     * callable on the implementing contract but not through proxies.
     */
    modifier notDelegated() {
        _checkNotDelegated();
        _;
    }

    function __UUPSUpgradeable_init() internal onlyInitializing {
    }

    function __UUPSUpgradeable_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev Implementation of the ERC1822 {proxiableUUID} function. This returns the storage slot used by the
     * implementation. It is used to validate the implementation's compatibility when performing an upgrade.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy. This is guaranteed by the `notDelegated` modifier.
     */
    function proxiableUUID() external view virtual notDelegated returns (bytes32) {
        return ERC1967Utils.IMPLEMENTATION_SLOT;
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`, and subsequently execute the function call
     * encoded in `data`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     *
     * @custom:oz-upgrades-unsafe-allow-reachable delegatecall
     */
    function upgradeToAndCall(address newImplementation, bytes memory data) public payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, data);
    }

    /**
     * @dev Reverts if the execution is not performed via delegatecall or the execution
     * context is not of a proxy with an ERC1967-compliant implementation pointing to self.
     * See {_onlyProxy}.
     */
    function _checkProxy() internal view virtual {
        if (
            address(this) == __self || // Must be called through delegatecall
            ERC1967Utils.getImplementation() != __self // Must be called through an active proxy
        ) {
            revert UUPSUnauthorizedCallContext();
        }
    }

    /**
     * @dev Reverts if the execution is performed via delegatecall.
     * See {notDelegated}.
     */
    function _checkNotDelegated() internal view virtual {
        if (address(this) != __self) {
            // Must not be called through delegatecall
            revert UUPSUnauthorizedCallContext();
        }
    }

    /**
     * @dev Function that should revert when `msg.sender` is not authorized to upgrade the contract. Called by
     * {upgradeToAndCall}.
     *
     * Normally, this function will use an xref:access.adoc[access control] modifier such as {Ownable-onlyOwner}.
     *
     * ```solidity
     * function _authorizeUpgrade(address) internal onlyOwner {}
     * ```
     */
    function _authorizeUpgrade(address newImplementation) internal virtual;

    /**
     * @dev Performs an implementation upgrade with a security check for UUPS proxies, and additional setup call.
     *
     * As a security check, {proxiableUUID} is invoked in the new implementation, and the return value
     * is expected to be the implementation slot in ERC1967.
     *
     * Emits an {IERC1967-Upgraded} event.
     */
    function _upgradeToAndCallUUPS(address newImplementation, bytes memory data) private {
        try IERC1822Proxiable(newImplementation).proxiableUUID() returns (bytes32 slot) {
            if (slot != ERC1967Utils.IMPLEMENTATION_SLOT) {
                revert UUPSUnsupportedProxiableUUID(slot);
            }
            ERC1967Utils.upgradeToAndCall(newImplementation, data);
        } catch {
            // The implementation is not UUPS
            revert ERC1967Utils.ERC1967InvalidImplementation(newImplementation);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/AccessControl.sol)

pragma solidity ^0.8.20;

import {IAccessControl} from "./IAccessControl.sol";
import {Context} from "../utils/Context.sol";
import {ERC165} from "../utils/introspection/ERC165.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```solidity
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```solidity
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it. We recommend using {AccessControlDefaultAdminRules}
 * to enforce additional security measures for this role.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address account => bool) hasRole;
        bytes32 adminRole;
    }

    mapping(bytes32 role => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with an {AccessControlUnauthorizedAccount} error including the required role.
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual returns (bool) {
        return _roles[role].hasRole[account];
    }

    /**
     * @dev Reverts with an {AccessControlUnauthorizedAccount} error if `_msgSender()`
     * is missing `role`. Overriding this function changes the behavior of the {onlyRole} modifier.
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Reverts with an {AccessControlUnauthorizedAccount} error if `account`
     * is missing `role`.
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert AccessControlUnauthorizedAccount(account, role);
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleGranted} event.
     */
    function grantRole(bytes32 role, address account) public virtual onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleRevoked} event.
     */
    function revokeRole(bytes32 role, address account) public virtual onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `callerConfirmation`.
     *
     * May emit a {RoleRevoked} event.
     */
    function renounceRole(bytes32 role, address callerConfirmation) public virtual {
        if (callerConfirmation != _msgSender()) {
            revert AccessControlBadConfirmation();
        }

        _revokeRole(role, callerConfirmation);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Attempts to grant `role` to `account` and returns a boolean indicating if `role` was granted.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleGranted} event.
     */
    function _grantRole(bytes32 role, address account) internal virtual returns (bool) {
        if (!hasRole(role, account)) {
            _roles[role].hasRole[account] = true;
            emit RoleGranted(role, account, _msgSender());
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Attempts to revoke `role` to `account` and returns a boolean indicating if `role` was revoked.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual returns (bool) {
        if (hasRole(role, account)) {
            _roles[role].hasRole[account] = false;
            emit RoleRevoked(role, account, _msgSender());
            return true;
        } else {
            return false;
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/IAccessControl.sol)

pragma solidity ^0.8.20;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev The `account` is missing a role.
     */
    error AccessControlUnauthorizedAccount(address account, bytes32 neededRole);

    /**
     * @dev The caller of a function is not the expected one.
     *
     * NOTE: Don't confuse with {AccessControlUnauthorizedAccount}.
     */
    error AccessControlBadConfirmation();

    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `callerConfirmation`.
     */
    function renounceRole(bytes32 role, address callerConfirmation) external;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (governance/TimelockController.sol)

pragma solidity ^0.8.20;

import {AccessControl} from "../access/AccessControl.sol";
import {ERC721Holder} from "../token/ERC721/utils/ERC721Holder.sol";
import {ERC1155Holder} from "../token/ERC1155/utils/ERC1155Holder.sol";
import {Address} from "../utils/Address.sol";

/**
 * @dev Contract module which acts as a timelocked controller. When set as the
 * owner of an `Ownable` smart contract, it enforces a timelock on all
 * `onlyOwner` maintenance operations. This gives time for users of the
 * controlled contract to exit before a potentially dangerous maintenance
 * operation is applied.
 *
 * By default, this contract is self administered, meaning administration tasks
 * have to go through the timelock process. The proposer (resp executor) role
 * is in charge of proposing (resp executing) operations. A common use case is
 * to position this {TimelockController} as the owner of a smart contract, with
 * a multisig or a DAO as the sole proposer.
 */
contract TimelockController is AccessControl, ERC721Holder, ERC1155Holder {
    bytes32 public constant PROPOSER_ROLE = keccak256("PROPOSER_ROLE");
    bytes32 public constant EXECUTOR_ROLE = keccak256("EXECUTOR_ROLE");
    bytes32 public constant CANCELLER_ROLE = keccak256("CANCELLER_ROLE");
    uint256 internal constant _DONE_TIMESTAMP = uint256(1);

    mapping(bytes32 id => uint256) private _timestamps;
    uint256 private _minDelay;

    enum OperationState {
        Unset,
        Waiting,
        Ready,
        Done
    }

    /**
     * @dev Mismatch between the parameters length for an operation call.
     */
    error TimelockInvalidOperationLength(uint256 targets, uint256 payloads, uint256 values);

    /**
     * @dev The schedule operation doesn't meet the minimum delay.
     */
    error TimelockInsufficientDelay(uint256 delay, uint256 minDelay);

    /**
     * @dev The current state of an operation is not as required.
     * The `expectedStates` is a bitmap with the bits enabled for each OperationState enum position
     * counting from right to left.
     *
     * See {_encodeStateBitmap}.
     */
    error TimelockUnexpectedOperationState(bytes32 operationId, bytes32 expectedStates);

    /**
     * @dev The predecessor to an operation not yet done.
     */
    error TimelockUnexecutedPredecessor(bytes32 predecessorId);

    /**
     * @dev The caller account is not authorized.
     */
    error TimelockUnauthorizedCaller(address caller);

    /**
     * @dev Emitted when a call is scheduled as part of operation `id`.
     */
    event CallScheduled(
        bytes32 indexed id,
        uint256 indexed index,
        address target,
        uint256 value,
        bytes data,
        bytes32 predecessor,
        uint256 delay
    );

    /**
     * @dev Emitted when a call is performed as part of operation `id`.
     */
    event CallExecuted(bytes32 indexed id, uint256 indexed index, address target, uint256 value, bytes data);

    /**
     * @dev Emitted when new proposal is scheduled with non-zero salt.
     */
    event CallSalt(bytes32 indexed id, bytes32 salt);

    /**
     * @dev Emitted when operation `id` is cancelled.
     */
    event Cancelled(bytes32 indexed id);

    /**
     * @dev Emitted when the minimum delay for future operations is modified.
     */
    event MinDelayChange(uint256 oldDuration, uint256 newDuration);

    /**
     * @dev Initializes the contract with the following parameters:
     *
     * - `minDelay`: initial minimum delay in seconds for operations
     * - `proposers`: accounts to be granted proposer and canceller roles
     * - `executors`: accounts to be granted executor role
     * - `admin`: optional account to be granted admin role; disable with zero address
     *
     * IMPORTANT: The optional admin can aid with initial configuration of roles after deployment
     * without being subject to delay, but this role should be subsequently renounced in favor of
     * administration through timelocked proposals. Previous versions of this contract would assign
     * this admin to the deployer automatically and should be renounced as well.
     */
    constructor(uint256 minDelay, address[] memory proposers, address[] memory executors, address admin) {
        // self administration
        _grantRole(DEFAULT_ADMIN_ROLE, address(this));

        // optional admin
        if (admin != address(0)) {
            _grantRole(DEFAULT_ADMIN_ROLE, admin);
        }

        // register proposers and cancellers
        for (uint256 i = 0; i < proposers.length; ++i) {
            _grantRole(PROPOSER_ROLE, proposers[i]);
            _grantRole(CANCELLER_ROLE, proposers[i]);
        }

        // register executors
        for (uint256 i = 0; i < executors.length; ++i) {
            _grantRole(EXECUTOR_ROLE, executors[i]);
        }

        _minDelay = minDelay;
        emit MinDelayChange(0, minDelay);
    }

    /**
     * @dev Modifier to make a function callable only by a certain role. In
     * addition to checking the sender's role, `address(0)` 's role is also
     * considered. Granting a role to `address(0)` is equivalent to enabling
     * this role for everyone.
     */
    modifier onlyRoleOrOpenRole(bytes32 role) {
        if (!hasRole(role, address(0))) {
            _checkRole(role, _msgSender());
        }
        _;
    }

    /**
     * @dev Contract might receive/hold ETH as part of the maintenance process.
     */
    receive() external payable {}

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(AccessControl, ERC1155Holder) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns whether an id corresponds to a registered operation. This
     * includes both Waiting, Ready, and Done operations.
     */
    function isOperation(bytes32 id) public view returns (bool) {
        return getOperationState(id) != OperationState.Unset;
    }

    /**
     * @dev Returns whether an operation is pending or not. Note that a "pending" operation may also be "ready".
     */
    function isOperationPending(bytes32 id) public view returns (bool) {
        OperationState state = getOperationState(id);
        return state == OperationState.Waiting || state == OperationState.Ready;
    }

    /**
     * @dev Returns whether an operation is ready for execution. Note that a "ready" operation is also "pending".
     */
    function isOperationReady(bytes32 id) public view returns (bool) {
        return getOperationState(id) == OperationState.Ready;
    }

    /**
     * @dev Returns whether an operation is done or not.
     */
    function isOperationDone(bytes32 id) public view returns (bool) {
        return getOperationState(id) == OperationState.Done;
    }

    /**
     * @dev Returns the timestamp at which an operation becomes ready (0 for
     * unset operations, 1 for done operations).
     */
    function getTimestamp(bytes32 id) public view virtual returns (uint256) {
        return _timestamps[id];
    }

    /**
     * @dev Returns operation state.
     */
    function getOperationState(bytes32 id) public view virtual returns (OperationState) {
        uint256 timestamp = getTimestamp(id);
        if (timestamp == 0) {
            return OperationState.Unset;
        } else if (timestamp == _DONE_TIMESTAMP) {
            return OperationState.Done;
        } else if (timestamp > block.timestamp) {
            return OperationState.Waiting;
        } else {
            return OperationState.Ready;
        }
    }

    /**
     * @dev Returns the minimum delay in seconds for an operation to become valid.
     *
     * This value can be changed by executing an operation that calls `updateDelay`.
     */
    function getMinDelay() public view virtual returns (uint256) {
        return _minDelay;
    }

    /**
     * @dev Returns the identifier of an operation containing a single
     * transaction.
     */
    function hashOperation(
        address target,
        uint256 value,
        bytes calldata data,
        bytes32 predecessor,
        bytes32 salt
    ) public pure virtual returns (bytes32) {
        return keccak256(abi.encode(target, value, data, predecessor, salt));
    }

    /**
     * @dev Returns the identifier of an operation containing a batch of
     * transactions.
     */
    function hashOperationBatch(
        address[] calldata targets,
        uint256[] calldata values,
        bytes[] calldata payloads,
        bytes32 predecessor,
        bytes32 salt
    ) public pure virtual returns (bytes32) {
        return keccak256(abi.encode(targets, values, payloads, predecessor, salt));
    }

    /**
     * @dev Schedule an operation containing a single transaction.
     *
     * Emits {CallSalt} if salt is nonzero, and {CallScheduled}.
     *
     * Requirements:
     *
     * - the caller must have the 'proposer' role.
     */
    function schedule(
        address target,
        uint256 value,
        bytes calldata data,
        bytes32 predecessor,
        bytes32 salt,
        uint256 delay
    ) public virtual onlyRole(PROPOSER_ROLE) {
        bytes32 id = hashOperation(target, value, data, predecessor, salt);
        _schedule(id, delay);
        emit CallScheduled(id, 0, target, value, data, predecessor, delay);
        if (salt != bytes32(0)) {
            emit CallSalt(id, salt);
        }
    }

    /**
     * @dev Schedule an operation containing a batch of transactions.
     *
     * Emits {CallSalt} if salt is nonzero, and one {CallScheduled} event per transaction in the batch.
     *
     * Requirements:
     *
     * - the caller must have the 'proposer' role.
     */
    function scheduleBatch(
        address[] calldata targets,
        uint256[] calldata values,
        bytes[] calldata payloads,
        bytes32 predecessor,
        bytes32 salt,
        uint256 delay
    ) public virtual onlyRole(PROPOSER_ROLE) {
        if (targets.length != values.length || targets.length != payloads.length) {
            revert TimelockInvalidOperationLength(targets.length, payloads.length, values.length);
        }

        bytes32 id = hashOperationBatch(targets, values, payloads, predecessor, salt);
        _schedule(id, delay);
        for (uint256 i = 0; i < targets.length; ++i) {
            emit CallScheduled(id, i, targets[i], values[i], payloads[i], predecessor, delay);
        }
        if (salt != bytes32(0)) {
            emit CallSalt(id, salt);
        }
    }

    /**
     * @dev Schedule an operation that is to become valid after a given delay.
     */
    function _schedule(bytes32 id, uint256 delay) private {
        if (isOperation(id)) {
            revert TimelockUnexpectedOperationState(id, _encodeStateBitmap(OperationState.Unset));
        }
        uint256 minDelay = getMinDelay();
        if (delay < minDelay) {
            revert TimelockInsufficientDelay(delay, minDelay);
        }
        _timestamps[id] = block.timestamp + delay;
    }

    /**
     * @dev Cancel an operation.
     *
     * Requirements:
     *
     * - the caller must have the 'canceller' role.
     */
    function cancel(bytes32 id) public virtual onlyRole(CANCELLER_ROLE) {
        if (!isOperationPending(id)) {
            revert TimelockUnexpectedOperationState(
                id,
                _encodeStateBitmap(OperationState.Waiting) | _encodeStateBitmap(OperationState.Ready)
            );
        }
        delete _timestamps[id];

        emit Cancelled(id);
    }

    /**
     * @dev Execute an (ready) operation containing a single transaction.
     *
     * Emits a {CallExecuted} event.
     *
     * Requirements:
     *
     * - the caller must have the 'executor' role.
     */
    // This function can reenter, but it doesn't pose a risk because _afterCall checks that the proposal is pending,
    // thus any modifications to the operation during reentrancy should be caught.
    // slither-disable-next-line reentrancy-eth
    function execute(
        address target,
        uint256 value,
        bytes calldata payload,
        bytes32 predecessor,
        bytes32 salt
    ) public payable virtual onlyRoleOrOpenRole(EXECUTOR_ROLE) {
        bytes32 id = hashOperation(target, value, payload, predecessor, salt);

        _beforeCall(id, predecessor);
        _execute(target, value, payload);
        emit CallExecuted(id, 0, target, value, payload);
        _afterCall(id);
    }

    /**
     * @dev Execute an (ready) operation containing a batch of transactions.
     *
     * Emits one {CallExecuted} event per transaction in the batch.
     *
     * Requirements:
     *
     * - the caller must have the 'executor' role.
     */
    // This function can reenter, but it doesn't pose a risk because _afterCall checks that the proposal is pending,
    // thus any modifications to the operation during reentrancy should be caught.
    // slither-disable-next-line reentrancy-eth
    function executeBatch(
        address[] calldata targets,
        uint256[] calldata values,
        bytes[] calldata payloads,
        bytes32 predecessor,
        bytes32 salt
    ) public payable virtual onlyRoleOrOpenRole(EXECUTOR_ROLE) {
        if (targets.length != values.length || targets.length != payloads.length) {
            revert TimelockInvalidOperationLength(targets.length, payloads.length, values.length);
        }

        bytes32 id = hashOperationBatch(targets, values, payloads, predecessor, salt);

        _beforeCall(id, predecessor);
        for (uint256 i = 0; i < targets.length; ++i) {
            address target = targets[i];
            uint256 value = values[i];
            bytes calldata payload = payloads[i];
            _execute(target, value, payload);
            emit CallExecuted(id, i, target, value, payload);
        }
        _afterCall(id);
    }

    /**
     * @dev Execute an operation's call.
     */
    function _execute(address target, uint256 value, bytes calldata data) internal virtual {
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        Address.verifyCallResult(success, returndata);
    }

    /**
     * @dev Checks before execution of an operation's calls.
     */
    function _beforeCall(bytes32 id, bytes32 predecessor) private view {
        if (!isOperationReady(id)) {
            revert TimelockUnexpectedOperationState(id, _encodeStateBitmap(OperationState.Ready));
        }
        if (predecessor != bytes32(0) && !isOperationDone(predecessor)) {
            revert TimelockUnexecutedPredecessor(predecessor);
        }
    }

    /**
     * @dev Checks after execution of an operation's calls.
     */
    function _afterCall(bytes32 id) private {
        if (!isOperationReady(id)) {
            revert TimelockUnexpectedOperationState(id, _encodeStateBitmap(OperationState.Ready));
        }
        _timestamps[id] = _DONE_TIMESTAMP;
    }

    /**
     * @dev Changes the minimum timelock duration for future operations.
     *
     * Emits a {MinDelayChange} event.
     *
     * Requirements:
     *
     * - the caller must be the timelock itself. This can only be achieved by scheduling and later executing
     * an operation where the timelock is the target and the data is the ABI-encoded call to this function.
     */
    function updateDelay(uint256 newDelay) external virtual {
        address sender = _msgSender();
        if (sender != address(this)) {
            revert TimelockUnauthorizedCaller(sender);
        }
        emit MinDelayChange(_minDelay, newDelay);
        _minDelay = newDelay;
    }

    /**
     * @dev Encodes a `OperationState` into a `bytes32` representation where each bit enabled corresponds to
     * the underlying position in the `OperationState` enum. For example:
     *
     * 0x000...1000
     *   ^^^^^^----- ...
     *         ^---- Done
     *          ^--- Ready
     *           ^-- Waiting
     *            ^- Unset
     */
    function _encodeStateBitmap(OperationState operationState) internal pure returns (bytes32) {
        return bytes32(1 << uint8(operationState));
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC5267.sol)

pragma solidity ^0.8.20;

interface IERC5267 {
    /**
     * @dev MAY be emitted to signal that the domain could have changed.
     */
    event EIP712DomainChanged();

    /**
     * @dev returns the fields and values that describe the domain separator used by this contract for EIP-712
     * signature.
     */
    function eip712Domain()
        external
        view
        returns (
            bytes1 fields,
            string memory name,
            string memory version,
            uint256 chainId,
            address verifyingContract,
            bytes32 salt,
            uint256[] memory extensions
        );
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/draft-IERC1822.sol)

pragma solidity ^0.8.20;

/**
 * @dev ERC1822: Universal Upgradeable Proxy Standard (UUPS) documents a method for upgradeability through a simplified
 * proxy whose upgrades are fully controlled by the current implementation.
 */
interface IERC1822Proxiable {
    /**
     * @dev Returns the storage slot that the proxiable contract assumes is being used to store the implementation
     * address.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy.
     */
    function proxiableUUID() external view returns (bytes32);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/draft-IERC6093.sol)
pragma solidity ^0.8.20;

/**
 * @dev Standard ERC20 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC20 tokens.
 */
interface IERC20Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC20InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC20InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `spender`’s `allowance`. Used in transfers.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     * @param allowance Amount of tokens a `spender` is allowed to operate with.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC20InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `spender` to be approved. Used in approvals.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC20InvalidSpender(address spender);
}

/**
 * @dev Standard ERC721 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC721 tokens.
 */
interface IERC721Errors {
    /**
     * @dev Indicates that an address can't be an owner. For example, `address(0)` is a forbidden owner in EIP-20.
     * Used in balance queries.
     * @param owner Address of the current owner of a token.
     */
    error ERC721InvalidOwner(address owner);

    /**
     * @dev Indicates a `tokenId` whose `owner` is the zero address.
     * @param tokenId Identifier number of a token.
     */
    error ERC721NonexistentToken(uint256 tokenId);

    /**
     * @dev Indicates an error related to the ownership over a particular token. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param tokenId Identifier number of a token.
     * @param owner Address of the current owner of a token.
     */
    error ERC721IncorrectOwner(address sender, uint256 tokenId, address owner);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC721InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC721InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param tokenId Identifier number of a token.
     */
    error ERC721InsufficientApproval(address operator, uint256 tokenId);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC721InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC721InvalidOperator(address operator);
}

/**
 * @dev Standard ERC1155 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC1155 tokens.
 */
interface IERC1155Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     * @param tokenId Identifier number of a token.
     */
    error ERC1155InsufficientBalance(address sender, uint256 balance, uint256 needed, uint256 tokenId);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC1155InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC1155InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param owner Address of the current owner of a token.
     */
    error ERC1155MissingApprovalForAll(address operator, address owner);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC1155InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC1155InvalidOperator(address operator);

    /**
     * @dev Indicates an array length mismatch between ids and values in a safeBatchTransferFrom operation.
     * Used in batch transfers.
     * @param idsLength Length of the array of token identifiers
     * @param valuesLength Length of the array of token amounts
     */
    error ERC1155InvalidArrayLength(uint256 idsLength, uint256 valuesLength);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (proxy/ERC1967/ERC1967Proxy.sol)

pragma solidity ^0.8.20;

import {Proxy} from "../Proxy.sol";
import {ERC1967Utils} from "./ERC1967Utils.sol";

/**
 * @dev This contract implements an upgradeable proxy. It is upgradeable because calls are delegated to an
 * implementation address that can be changed. This address is stored in storage in the location specified by
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967], so that it doesn't conflict with the storage layout of the
 * implementation behind the proxy.
 */
contract ERC1967Proxy is Proxy {
    /**
     * @dev Initializes the upgradeable proxy with an initial implementation specified by `implementation`.
     *
     * If `_data` is nonempty, it's used as data in a delegate call to `implementation`. This will typically be an
     * encoded function call, and allows initializing the storage of the proxy like a Solidity constructor.
     *
     * Requirements:
     *
     * - If `data` is empty, `msg.value` must be zero.
     */
    constructor(address implementation, bytes memory _data) payable {
        ERC1967Utils.upgradeToAndCall(implementation, _data);
    }

    /**
     * @dev Returns the current implementation address.
     *
     * TIP: To get this value clients can read directly from the storage slot shown below (specified by EIP1967) using
     * the https://eth.wiki/json-rpc/API#eth_getstorageat[`eth_getStorageAt`] RPC call.
     * `0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc`
     */
    function _implementation() internal view virtual override returns (address) {
        return ERC1967Utils.getImplementation();
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (proxy/ERC1967/ERC1967Utils.sol)

pragma solidity ^0.8.20;

import {IBeacon} from "../beacon/IBeacon.sol";
import {Address} from "../../utils/Address.sol";
import {StorageSlot} from "../../utils/StorageSlot.sol";

/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 */
library ERC1967Utils {
    // We re-declare ERC-1967 events here because they can't be used directly from IERC1967.
    // This will be fixed in Solidity 0.8.21. At that point we should remove these events.
    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Emitted when the beacon is changed.
     */
    event BeaconUpgraded(address indexed beacon);

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1.
     */
    // solhint-disable-next-line private-vars-leading-underscore
    bytes32 internal constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev The `implementation` of the proxy is invalid.
     */
    error ERC1967InvalidImplementation(address implementation);

    /**
     * @dev The `admin` of the proxy is invalid.
     */
    error ERC1967InvalidAdmin(address admin);

    /**
     * @dev The `beacon` of the proxy is invalid.
     */
    error ERC1967InvalidBeacon(address beacon);

    /**
     * @dev An upgrade function sees `msg.value > 0` that may be lost.
     */
    error ERC1967NonPayable();

    /**
     * @dev Returns the current implementation address.
     */
    function getImplementation() internal view returns (address) {
        return StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        if (newImplementation.code.length == 0) {
            revert ERC1967InvalidImplementation(newImplementation);
        }
        StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value = newImplementation;
    }

    /**
     * @dev Performs implementation upgrade with additional setup call if data is nonempty.
     * This function is payable only if the setup call is performed, otherwise `msg.value` is rejected
     * to avoid stuck value in the contract.
     *
     * Emits an {IERC1967-Upgraded} event.
     */
    function upgradeToAndCall(address newImplementation, bytes memory data) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);

        if (data.length > 0) {
            Address.functionDelegateCall(newImplementation, data);
        } else {
            _checkNonPayable();
        }
    }

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1.
     */
    // solhint-disable-next-line private-vars-leading-underscore
    bytes32 internal constant ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Returns the current admin.
     *
     * TIP: To get this value clients can read directly from the storage slot shown below (specified by EIP1967) using
     * the https://eth.wiki/json-rpc/API#eth_getstorageat[`eth_getStorageAt`] RPC call.
     * `0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103`
     */
    function getAdmin() internal view returns (address) {
        return StorageSlot.getAddressSlot(ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        if (newAdmin == address(0)) {
            revert ERC1967InvalidAdmin(address(0));
        }
        StorageSlot.getAddressSlot(ADMIN_SLOT).value = newAdmin;
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {IERC1967-AdminChanged} event.
     */
    function changeAdmin(address newAdmin) internal {
        emit AdminChanged(getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.
     * This is the keccak-256 hash of "eip1967.proxy.beacon" subtracted by 1.
     */
    // solhint-disable-next-line private-vars-leading-underscore
    bytes32 internal constant BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    /**
     * @dev Returns the current beacon.
     */
    function getBeacon() internal view returns (address) {
        return StorageSlot.getAddressSlot(BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        if (newBeacon.code.length == 0) {
            revert ERC1967InvalidBeacon(newBeacon);
        }

        StorageSlot.getAddressSlot(BEACON_SLOT).value = newBeacon;

        address beaconImplementation = IBeacon(newBeacon).implementation();
        if (beaconImplementation.code.length == 0) {
            revert ERC1967InvalidImplementation(beaconImplementation);
        }
    }

    /**
     * @dev Change the beacon and trigger a setup call if data is nonempty.
     * This function is payable only if the setup call is performed, otherwise `msg.value` is rejected
     * to avoid stuck value in the contract.
     *
     * Emits an {IERC1967-BeaconUpgraded} event.
     *
     * CAUTION: Invoking this function has no effect on an instance of {BeaconProxy} since v5, since
     * it uses an immutable beacon without looking at the value of the ERC-1967 beacon slot for
     * efficiency.
     */
    function upgradeBeaconToAndCall(address newBeacon, bytes memory data) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);

        if (data.length > 0) {
            Address.functionDelegateCall(IBeacon(newBeacon).implementation(), data);
        } else {
            _checkNonPayable();
        }
    }

    /**
     * @dev Reverts if `msg.value` is not zero. It can be used to avoid `msg.value` stuck in the contract
     * if an upgrade doesn't perform an initialization call.
     */
    function _checkNonPayable() private {
        if (msg.value > 0) {
            revert ERC1967NonPayable();
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (proxy/Proxy.sol)

pragma solidity ^0.8.20;

/**
 * @dev This abstract contract provides a fallback function that delegates all calls to another contract using the EVM
 * instruction `delegatecall`. We refer to the second contract as the _implementation_ behind the proxy, and it has to
 * be specified by overriding the virtual {_implementation} function.
 *
 * Additionally, delegation to the implementation can be triggered manually through the {_fallback} function, or to a
 * different contract through the {_delegate} function.
 *
 * The success and return data of the delegated call will be returned back to the caller of the proxy.
 */
abstract contract Proxy {
    /**
     * @dev Delegates the current call to `implementation`.
     *
     * This function does not return to its internal call site, it will return directly to the external caller.
     */
    function _delegate(address implementation) internal virtual {
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    /**
     * @dev This is a virtual function that should be overridden so it returns the address to which the fallback
     * function and {_fallback} should delegate.
     */
    function _implementation() internal view virtual returns (address);

    /**
     * @dev Delegates the current call to the address returned by `_implementation()`.
     *
     * This function does not return to its internal call site, it will return directly to the external caller.
     */
    function _fallback() internal virtual {
        _delegate(_implementation());
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if no other
     * function in the contract matches the call data.
     */
    fallback() external payable virtual {
        _fallback();
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (proxy/beacon/IBeacon.sol)

pragma solidity ^0.8.20;

/**
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeacon {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {UpgradeableBeacon} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.20;

import {IERC165} from "../../utils/introspection/IERC165.sol";

/**
 * @dev Interface that must be implemented by smart contracts in order to receive
 * ERC-1155 token transfers.
 */
interface IERC1155Receiver is IERC165 {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC1155/utils/ERC1155Holder.sol)

pragma solidity ^0.8.20;

import {IERC165, ERC165} from "../../../utils/introspection/ERC165.sol";
import {IERC1155Receiver} from "../IERC1155Receiver.sol";

/**
 * @dev Simple implementation of `IERC1155Receiver` that will allow a contract to hold ERC1155 tokens.
 *
 * IMPORTANT: When inheriting this contract, you must include a way to use the received tokens, otherwise they will be
 * stuck.
 */
abstract contract ERC1155Holder is ERC165, IERC1155Receiver {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.20;

import {IERC20} from "./IERC20.sol";
import {IERC20Metadata} from "./extensions/IERC20Metadata.sol";
import {Context} from "../../utils/Context.sol";
import {IERC20Errors} from "../../interfaces/draft-IERC6093.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * The default value of {decimals} is 18. To change this, you should override
 * this function so it returns a different value.
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
 */
abstract contract ERC20 is Context, IERC20, IERC20Metadata, IERC20Errors {
    mapping(address account => uint256) private _balances;

    mapping(address account => mapping(address spender => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
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
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `value`.
     */
    function transfer(address to, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `value` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, value);
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
     * - `from` must have a balance of at least `value`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `value`.
     */
    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }

    /**
     * @dev Transfers a `value` amount of tokens from `from` to `to`, or alternatively mints (or burns) if `from`
     * (or `to`) is the zero address. All customizations to transfers, mints, and burns should be done by overriding
     * this function.
     *
     * Emits a {Transfer} event.
     */
    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            // Overflow check required: The rest of the code assumes that totalSupply never overflows
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                // Overflow not possible: value <= fromBalance <= totalSupply.
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                // Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
                _totalSupply -= value;
            }
        } else {
            unchecked {
                // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    /**
     * @dev Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0).
     * Relies on the `_update` mechanism
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }

    /**
     * @dev Destroys a `value` amount of tokens from `account`, lowering the total supply.
     * Relies on the `_update` mechanism.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead
     */
    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }

    /**
     * @dev Sets `value` as the allowance of `spender` over the `owner` s tokens.
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
     *
     * Overrides to this logic should be done to the variant with an additional `bool emitEvent` argument.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        _approve(owner, spender, value, true);
    }

    /**
     * @dev Variant of {_approve} with an optional flag to enable or disable the {Approval} event.
     *
     * By default (when calling {_approve}) the flag is set to true. On the other hand, approval changes made by
     * `_spendAllowance` during the `transferFrom` operation set the flag to false. This saves gas by not emitting any
     * `Approval` event during `transferFrom` operations.
     *
     * Anyone who wishes to continue emitting `Approval` events on the`transferFrom` operation can force the flag to
     * true using the following override:
     * ```
     * function _approve(address owner, address spender, uint256 value, bool) internal virtual override {
     *     super._approve(owner, spender, value, true);
     * }
     * ```
     *
     * Requirements are the same as {_approve}.
     */
    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual {
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        _allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `value`.
     *
     * Does not update the allowance value in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Does not emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

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
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
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
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/ERC20Permit.sol)

pragma solidity ^0.8.20;

import {IERC20Permit} from "./IERC20Permit.sol";
import {ERC20} from "../ERC20.sol";
import {ECDSA} from "../../../utils/cryptography/ECDSA.sol";
import {EIP712} from "../../../utils/cryptography/EIP712.sol";
import {Nonces} from "../../../utils/Nonces.sol";

/**
 * @dev Implementation of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on `{IERC20-approve}`, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
abstract contract ERC20Permit is ERC20, IERC20Permit, EIP712, Nonces {
    bytes32 private constant PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    /**
     * @dev Permit deadline has expired.
     */
    error ERC2612ExpiredSignature(uint256 deadline);

    /**
     * @dev Mismatched signature.
     */
    error ERC2612InvalidSigner(address signer, address owner);

    /**
     * @dev Initializes the {EIP712} domain separator using the `name` parameter, and setting `version` to `"1"`.
     *
     * It's a good idea to use the same `name` that is defined as the ERC20 token name.
     */
    constructor(string memory name) EIP712(name, "1") {}

    /**
     * @inheritdoc IERC20Permit
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        if (block.timestamp > deadline) {
            revert ERC2612ExpiredSignature(deadline);
        }

        bytes32 structHash = keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, _useNonce(owner), deadline));

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSA.recover(hash, v, r, s);
        if (signer != owner) {
            revert ERC2612InvalidSigner(signer, owner);
        }

        _approve(owner, spender, value);
    }

    /**
     * @inheritdoc IERC20Permit
     */
    function nonces(address owner) public view virtual override(IERC20Permit, Nonces) returns (uint256) {
        return super.nonces(owner);
    }

    /**
     * @inheritdoc IERC20Permit
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view virtual returns (bytes32) {
        return _domainSeparatorV4();
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Permit.sol)

pragma solidity ^0.8.20;

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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../IERC20.sol";
import {IERC20Permit} from "../extensions/IERC20Permit.sol";
import {Address} from "../../../utils/Address.sol";

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
     * @dev An operation with an ERC20 token failed.
     */
    error SafeERC20FailedOperation(address token);

    /**
     * @dev Indicates a failed `decreaseAllowance` request.
     */
    error SafeERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `requestedDecrease`. If `token` returns no
     * value, non-reverting calls are assumed to be successful.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 requestedDecrease) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(spender, currentAllowance, requestedDecrease);
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));
            _callOptionalReturn(token, approvalCall);
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
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data);
        if (returndata.length != 0 && !abi.decode(returndata, (bool))) {
            revert SafeERC20FailedOperation(address(token));
        }
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
        return success && (returndata.length == 0 || abi.decode(returndata, (bool))) && address(token).code.length > 0;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.20;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be
     * reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/utils/ERC721Holder.sol)

pragma solidity ^0.8.20;

import {IERC721Receiver} from "../IERC721Receiver.sol";

/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or
 * {IERC721-setApprovalForAll}.
 */
abstract contract ERC721Holder is IERC721Receiver {
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(address, address, uint256, bytes memory) public virtual returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Address.sol)

pragma solidity ^0.8.20;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev The ETH balance of the account is not enough to perform the operation.
     */
    error AddressInsufficientBalance(address account);

    /**
     * @dev There's no code at `target` (it is not a contract).
     */
    error AddressEmptyCode(address target);

    /**
     * @dev A call to an address target failed. The target may have reverted.
     */
    error FailedInnerCall();

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
     * https://solidity.readthedocs.io/en/v0.8.20/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        if (address(this).balance < amount) {
            revert AddressInsufficientBalance(address(this));
        }

        (bool success, ) = recipient.call{value: amount}("");
        if (!success) {
            revert FailedInnerCall();
        }
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason or custom error, it is bubbled
     * up by this function (like regular Solidity function calls). However, if
     * the call reverted with no returned reason, this function reverts with a
     * {FailedInnerCall} error.
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        if (address(this).balance < value) {
            revert AddressInsufficientBalance(address(this));
        }
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and reverts if the target
     * was not a contract or bubbling up the revert reason (falling back to {FailedInnerCall}) in case of an
     * unsuccessful call.
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata
    ) internal view returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            // only check if target is a contract if the call was successful and the return data is empty
            // otherwise we already know that it was a contract
            if (returndata.length == 0 && target.code.length == 0) {
                revert AddressEmptyCode(target);
            }
            return returndata;
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and reverts if it wasn't, either by bubbling the
     * revert reason or with a default {FailedInnerCall} error.
     */
    function verifyCallResult(bool success, bytes memory returndata) internal pure returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            return returndata;
        }
    }

    /**
     * @dev Reverts with returndata if present. Otherwise reverts with {FailedInnerCall}.
     */
    function _revert(bytes memory returndata) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert FailedInnerCall();
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

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

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Create2.sol)

pragma solidity ^0.8.20;

/**
 * @dev Helper to make usage of the `CREATE2` EVM opcode easier and safer.
 * `CREATE2` can be used to compute in advance the address where a smart
 * contract will be deployed, which allows for interesting new mechanisms known
 * as 'counterfactual interactions'.
 *
 * See the https://eips.ethereum.org/EIPS/eip-1014#motivation[EIP] for more
 * information.
 */
library Create2 {
    /**
     * @dev Not enough balance for performing a CREATE2 deploy.
     */
    error Create2InsufficientBalance(uint256 balance, uint256 needed);

    /**
     * @dev There's no code to deploy.
     */
    error Create2EmptyBytecode();

    /**
     * @dev The deployment failed.
     */
    error Create2FailedDeployment();

    /**
     * @dev Deploys a contract using `CREATE2`. The address where the contract
     * will be deployed can be known in advance via {computeAddress}.
     *
     * The bytecode for a contract can be obtained from Solidity with
     * `type(contractName).creationCode`.
     *
     * Requirements:
     *
     * - `bytecode` must not be empty.
     * - `salt` must have not been used for `bytecode` already.
     * - the factory must have a balance of at least `amount`.
     * - if `amount` is non-zero, `bytecode` must have a `payable` constructor.
     */
    function deploy(uint256 amount, bytes32 salt, bytes memory bytecode) internal returns (address addr) {
        if (address(this).balance < amount) {
            revert Create2InsufficientBalance(address(this).balance, amount);
        }
        if (bytecode.length == 0) {
            revert Create2EmptyBytecode();
        }
        /// @solidity memory-safe-assembly
        assembly {
            addr := create2(amount, add(bytecode, 0x20), mload(bytecode), salt)
        }
        if (addr == address(0)) {
            revert Create2FailedDeployment();
        }
    }

    /**
     * @dev Returns the address where a contract will be stored if deployed via {deploy}. Any change in the
     * `bytecodeHash` or `salt` will result in a new destination address.
     */
    function computeAddress(bytes32 salt, bytes32 bytecodeHash) internal view returns (address) {
        return computeAddress(salt, bytecodeHash, address(this));
    }

    /**
     * @dev Returns the address where a contract will be stored if deployed via {deploy} from a contract located at
     * `deployer`. If `deployer` is this contract's address, returns the same value as {computeAddress}.
     */
    function computeAddress(bytes32 salt, bytes32 bytecodeHash, address deployer) internal pure returns (address addr) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40) // Get free memory pointer

            // |                   | ↓ ptr ...  ↓ ptr + 0x0B (start) ...  ↓ ptr + 0x20 ...  ↓ ptr + 0x40 ...   |
            // |-------------------|---------------------------------------------------------------------------|
            // | bytecodeHash      |                                                        CCCCCCCCCCCCC...CC |
            // | salt              |                                      BBBBBBBBBBBBB...BB                   |
            // | deployer          | 000000...0000AAAAAAAAAAAAAAAAAAA...AA                                     |
            // | 0xFF              |            FF                                                             |
            // |-------------------|---------------------------------------------------------------------------|
            // | memory            | 000000...00FFAAAAAAAAAAAAAAAAAAA...AABBBBBBBBBBBBB...BBCCCCCCCCCCCCC...CC |
            // | keccak(start, 85) |            ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑ |

            mstore(add(ptr, 0x40), bytecodeHash)
            mstore(add(ptr, 0x20), salt)
            mstore(ptr, deployer) // Right-aligned with 12 preceding garbage bytes
            let start := add(ptr, 0x0b) // The hashed data starts at the final garbage byte which we will set to 0xff
            mstore8(start, 0xff)
            addr := keccak256(start, 85)
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.1) (utils/Multicall.sol)

pragma solidity ^0.8.20;

import {Address} from "./Address.sol";
import {Context} from "./Context.sol";

/**
 * @dev Provides a function to batch together multiple calls in a single external call.
 *
 * Consider any assumption about calldata validation performed by the sender may be violated if it's not especially
 * careful about sending transactions invoking {multicall}. For example, a relay address that filters function
 * selectors won't filter calls nested within a {multicall} operation.
 *
 * NOTE: Since 5.0.1 and 4.9.4, this contract identifies non-canonical contexts (i.e. `msg.sender` is not {_msgSender}).
 * If a non-canonical context is identified, the following self `delegatecall` appends the last bytes of `msg.data`
 * to the subcall. This makes it safe to use with {ERC2771Context}. Contexts that don't affect the resolution of
 * {_msgSender} are not propagated to subcalls.
 */
abstract contract Multicall is Context {
    /**
     * @dev Receives and executes a batch of function calls on this contract.
     * @custom:oz-upgrades-unsafe-allow-reachable delegatecall
     */
    function multicall(bytes[] calldata data) external virtual returns (bytes[] memory results) {
        bytes memory context = msg.sender == _msgSender()
            ? new bytes(0)
            : msg.data[msg.data.length - _contextSuffixLength():];

        results = new bytes[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            results[i] = Address.functionDelegateCall(address(this), bytes.concat(data[i], context));
        }
        return results;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Nonces.sol)
pragma solidity ^0.8.20;

/**
 * @dev Provides tracking nonces for addresses. Nonces will only increment.
 */
abstract contract Nonces {
    /**
     * @dev The nonce used for an `account` is not the expected current nonce.
     */
    error InvalidAccountNonce(address account, uint256 currentNonce);

    mapping(address account => uint256) private _nonces;

    /**
     * @dev Returns the next unused nonce for an address.
     */
    function nonces(address owner) public view virtual returns (uint256) {
        return _nonces[owner];
    }

    /**
     * @dev Consumes a nonce.
     *
     * Returns the current value and increments nonce.
     */
    function _useNonce(address owner) internal virtual returns (uint256) {
        // For each account, the nonce has an initial value of 0, can only be incremented by one, and cannot be
        // decremented or reset. This guarantees that the nonce never overflows.
        unchecked {
            // It is important to do x++ and not ++x here.
            return _nonces[owner]++;
        }
    }

    /**
     * @dev Same as {_useNonce} but checking that `nonce` is the next valid for `owner`.
     */
    function _useCheckedNonce(address owner, uint256 nonce) internal virtual {
        uint256 current = _useNonce(owner);
        if (nonce != current) {
            revert InvalidAccountNonce(owner, current);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/ShortStrings.sol)

pragma solidity ^0.8.20;

import {StorageSlot} from "./StorageSlot.sol";

// | string  | 0xAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA   |
// | length  | 0x                                                              BB |
type ShortString is bytes32;

/**
 * @dev This library provides functions to convert short memory strings
 * into a `ShortString` type that can be used as an immutable variable.
 *
 * Strings of arbitrary length can be optimized using this library if
 * they are short enough (up to 31 bytes) by packing them with their
 * length (1 byte) in a single EVM word (32 bytes). Additionally, a
 * fallback mechanism can be used for every other case.
 *
 * Usage example:
 *
 * ```solidity
 * contract Named {
 *     using ShortStrings for *;
 *
 *     ShortString private immutable _name;
 *     string private _nameFallback;
 *
 *     constructor(string memory contractName) {
 *         _name = contractName.toShortStringWithFallback(_nameFallback);
 *     }
 *
 *     function name() external view returns (string memory) {
 *         return _name.toStringWithFallback(_nameFallback);
 *     }
 * }
 * ```
 */
library ShortStrings {
    // Used as an identifier for strings longer than 31 bytes.
    bytes32 private constant FALLBACK_SENTINEL = 0x00000000000000000000000000000000000000000000000000000000000000FF;

    error StringTooLong(string str);
    error InvalidShortString();

    /**
     * @dev Encode a string of at most 31 chars into a `ShortString`.
     *
     * This will trigger a `StringTooLong` error is the input string is too long.
     */
    function toShortString(string memory str) internal pure returns (ShortString) {
        bytes memory bstr = bytes(str);
        if (bstr.length > 31) {
            revert StringTooLong(str);
        }
        return ShortString.wrap(bytes32(uint256(bytes32(bstr)) | bstr.length));
    }

    /**
     * @dev Decode a `ShortString` back to a "normal" string.
     */
    function toString(ShortString sstr) internal pure returns (string memory) {
        uint256 len = byteLength(sstr);
        // using `new string(len)` would work locally but is not memory safe.
        string memory str = new string(32);
        /// @solidity memory-safe-assembly
        assembly {
            mstore(str, len)
            mstore(add(str, 0x20), sstr)
        }
        return str;
    }

    /**
     * @dev Return the length of a `ShortString`.
     */
    function byteLength(ShortString sstr) internal pure returns (uint256) {
        uint256 result = uint256(ShortString.unwrap(sstr)) & 0xFF;
        if (result > 31) {
            revert InvalidShortString();
        }
        return result;
    }

    /**
     * @dev Encode a string into a `ShortString`, or write it to storage if it is too long.
     */
    function toShortStringWithFallback(string memory value, string storage store) internal returns (ShortString) {
        if (bytes(value).length < 32) {
            return toShortString(value);
        } else {
            StorageSlot.getStringSlot(store).value = value;
            return ShortString.wrap(FALLBACK_SENTINEL);
        }
    }

    /**
     * @dev Decode a string that was encoded to `ShortString` or written to storage using {setWithFallback}.
     */
    function toStringWithFallback(ShortString value, string storage store) internal pure returns (string memory) {
        if (ShortString.unwrap(value) != FALLBACK_SENTINEL) {
            return toString(value);
        } else {
            return store;
        }
    }

    /**
     * @dev Return the length of a string that was encoded to `ShortString` or written to storage using
     * {setWithFallback}.
     *
     * WARNING: This will return the "byte length" of the string. This may not reflect the actual length in terms of
     * actual characters as the UTF-8 encoding of a single character can span over multiple bytes.
     */
    function byteLengthWithFallback(ShortString value, string storage store) internal view returns (uint256) {
        if (ShortString.unwrap(value) != FALLBACK_SENTINEL) {
            return byteLength(value);
        } else {
            return bytes(store).length;
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/StorageSlot.sol)
// This file was procedurally generated from scripts/generate/templates/StorageSlot.js.

pragma solidity ^0.8.20;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```solidity
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(newImplementation.code.length > 0);
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
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

    struct StringSlot {
        string value;
    }

    struct BytesSlot {
        bytes value;
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

    /**
     * @dev Returns an `StringSlot` with member `value` located at `slot`.
     */
    function getStringSlot(bytes32 slot) internal pure returns (StringSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `StringSlot` representation of the string storage pointer `store`.
     */
    function getStringSlot(string storage store) internal pure returns (StringSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := store.slot
        }
    }

    /**
     * @dev Returns an `BytesSlot` with member `value` located at `slot`.
     */
    function getBytesSlot(bytes32 slot) internal pure returns (BytesSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BytesSlot` representation of the bytes storage pointer `store`.
     */
    function getBytesSlot(bytes storage store) internal pure returns (BytesSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := store.slot
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Strings.sol)

pragma solidity ^0.8.20;

import {Math} from "./math/Math.sol";
import {SignedMath} from "./math/SignedMath.sol";

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant HEX_DIGITS = "0123456789abcdef";
    uint8 private constant ADDRESS_LENGTH = 20;

    /**
     * @dev The `value` string doesn't fit in the specified `length`.
     */
    error StringsInsufficientHexLength(uint256 value, uint256 length);

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), HEX_DIGITS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `int256` to its ASCII `string` decimal representation.
     */
    function toStringSigned(int256 value) internal pure returns (string memory) {
        return string.concat(value < 0 ? "-" : "", toString(SignedMath.abs(value)));
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        uint256 localValue = value;
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = HEX_DIGITS[localValue & 0xf];
            localValue >>= 4;
        }
        if (localValue != 0) {
            revert StringsInsufficientHexLength(value, length);
        }
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal
     * representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), ADDRESS_LENGTH);
    }

    /**
     * @dev Returns true if the two strings are equal.
     */
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return bytes(a).length == bytes(b).length && keccak256(bytes(a)) == keccak256(bytes(b));
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.20;

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS
    }

    /**
     * @dev The signature derives the `address(0)`.
     */
    error ECDSAInvalidSignature();

    /**
     * @dev The signature has an invalid length.
     */
    error ECDSAInvalidSignatureLength(uint256 length);

    /**
     * @dev The signature has an S value that is in the upper half order.
     */
    error ECDSAInvalidSignatureS(bytes32 s);

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with `signature` or an error. This will not
     * return address(0) without also returning an error description. Errors are documented using an enum (error type)
     * and a bytes32 providing additional information about the error.
     *
     * If no error is returned, then the address can be used for verification purposes.
     *
     * The `ecrecover` EVM precompile allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {MessageHashUtils-toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError, bytes32) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength, bytes32(signature.length));
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM precompile allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {MessageHashUtils-toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, signature);
        _throwError(error, errorArg);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     */
    function tryRecover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address, RecoverError, bytes32) {
        unchecked {
            bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
            // We do not check for an overflow here since the shift operation results in 0 or 1.
            uint8 v = uint8((uint256(vs) >> 255) + 27);
            return tryRecover(hash, v, r, s);
        }
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     */
    function recover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address) {
        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, r, vs);
        _throwError(error, errorArg);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError, bytes32) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS, s);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature, bytes32(0));
        }

        return (signer, RecoverError.NoError, bytes32(0));
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, v, r, s);
        _throwError(error, errorArg);
        return recovered;
    }

    /**
     * @dev Optionally reverts with the corresponding custom error according to the `error` argument provided.
     */
    function _throwError(RecoverError error, bytes32 errorArg) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert ECDSAInvalidSignature();
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert ECDSAInvalidSignatureLength(uint256(errorArg));
        } else if (error == RecoverError.InvalidSignatureS) {
            revert ECDSAInvalidSignatureS(errorArg);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/cryptography/EIP712.sol)

pragma solidity ^0.8.20;

import {MessageHashUtils} from "./MessageHashUtils.sol";
import {ShortStrings, ShortString} from "../ShortStrings.sol";
import {IERC5267} from "../../interfaces/IERC5267.sol";

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding scheme specified in the EIP requires a domain separator and a hash of the typed structured data, whose
 * encoding is very generic and therefore its implementation in Solidity is not feasible, thus this contract
 * does not implement the encoding itself. Protocols need to implement the type-specific encoding they need in order to
 * produce the hash of their typed data using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * NOTE: In the upgradeable version of this contract, the cached values will correspond to the address, and the domain
 * separator of the implementation contract. This will cause the {_domainSeparatorV4} function to always rebuild the
 * separator from the immutable values, which is cheaper than accessing a cached version in cold storage.
 *
 * @custom:oz-upgrades-unsafe-allow state-variable-immutable
 */
abstract contract EIP712 is IERC5267 {
    using ShortStrings for *;

    bytes32 private constant TYPE_HASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to
    // invalidate the cached domain separator if the chain id changes.
    bytes32 private immutable _cachedDomainSeparator;
    uint256 private immutable _cachedChainId;
    address private immutable _cachedThis;

    bytes32 private immutable _hashedName;
    bytes32 private immutable _hashedVersion;

    ShortString private immutable _name;
    ShortString private immutable _version;
    string private _nameFallback;
    string private _versionFallback;

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     *
     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
     * contract upgrade].
     */
    constructor(string memory name, string memory version) {
        _name = name.toShortStringWithFallback(_nameFallback);
        _version = version.toShortStringWithFallback(_versionFallback);
        _hashedName = keccak256(bytes(name));
        _hashedVersion = keccak256(bytes(version));

        _cachedChainId = block.chainid;
        _cachedDomainSeparator = _buildDomainSeparator();
        _cachedThis = address(this);
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        if (address(this) == _cachedThis && block.chainid == _cachedChainId) {
            return _cachedDomainSeparator;
        } else {
            return _buildDomainSeparator();
        }
    }

    function _buildDomainSeparator() private view returns (bytes32) {
        return keccak256(abi.encode(TYPE_HASH, _hashedName, _hashedVersion, block.chainid, address(this)));
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return MessageHashUtils.toTypedDataHash(_domainSeparatorV4(), structHash);
    }

    /**
     * @dev See {IERC-5267}.
     */
    function eip712Domain()
        public
        view
        virtual
        returns (
            bytes1 fields,
            string memory name,
            string memory version,
            uint256 chainId,
            address verifyingContract,
            bytes32 salt,
            uint256[] memory extensions
        )
    {
        return (
            hex"0f", // 01111
            _EIP712Name(),
            _EIP712Version(),
            block.chainid,
            address(this),
            bytes32(0),
            new uint256[](0)
        );
    }

    /**
     * @dev The name parameter for the EIP712 domain.
     *
     * NOTE: By default this function reads _name which is an immutable value.
     * It only reads from storage if necessary (in case the value is too large to fit in a ShortString).
     */
    // solhint-disable-next-line func-name-mixedcase
    function _EIP712Name() internal view returns (string memory) {
        return _name.toStringWithFallback(_nameFallback);
    }

    /**
     * @dev The version parameter for the EIP712 domain.
     *
     * NOTE: By default this function reads _version which is an immutable value.
     * It only reads from storage if necessary (in case the value is too large to fit in a ShortString).
     */
    // solhint-disable-next-line func-name-mixedcase
    function _EIP712Version() internal view returns (string memory) {
        return _version.toStringWithFallback(_versionFallback);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/cryptography/MessageHashUtils.sol)

pragma solidity ^0.8.20;

import {Strings} from "../Strings.sol";

/**
 * @dev Signature message hash utilities for producing digests to be consumed by {ECDSA} recovery or signing.
 *
 * The library provides methods for generating a hash of a message that conforms to the
 * https://eips.ethereum.org/EIPS/eip-191[EIP 191] and https://eips.ethereum.org/EIPS/eip-712[EIP 712]
 * specifications.
 */
library MessageHashUtils {
    /**
     * @dev Returns the keccak256 digest of an EIP-191 signed data with version
     * `0x45` (`personal_sign` messages).
     *
     * The digest is calculated by prefixing a bytes32 `messageHash` with
     * `"\x19Ethereum Signed Message:\n32"` and hashing the result. It corresponds with the
     * hash signed when using the https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`] JSON-RPC method.
     *
     * NOTE: The `messageHash` parameter is intended to be the result of hashing a raw message with
     * keccak256, although any bytes32 value can be safely used because the final digest will
     * be re-hashed.
     *
     * See {ECDSA-recover}.
     */
    function toEthSignedMessageHash(bytes32 messageHash) internal pure returns (bytes32 digest) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, "\x19Ethereum Signed Message:\n32") // 32 is the bytes-length of messageHash
            mstore(0x1c, messageHash) // 0x1c (28) is the length of the prefix
            digest := keccak256(0x00, 0x3c) // 0x3c is the length of the prefix (0x1c) + messageHash (0x20)
        }
    }

    /**
     * @dev Returns the keccak256 digest of an EIP-191 signed data with version
     * `0x45` (`personal_sign` messages).
     *
     * The digest is calculated by prefixing an arbitrary `message` with
     * `"\x19Ethereum Signed Message:\n" + len(message)` and hashing the result. It corresponds with the
     * hash signed when using the https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`] JSON-RPC method.
     *
     * See {ECDSA-recover}.
     */
    function toEthSignedMessageHash(bytes memory message) internal pure returns (bytes32) {
        return
            keccak256(bytes.concat("\x19Ethereum Signed Message:\n", bytes(Strings.toString(message.length)), message));
    }

    /**
     * @dev Returns the keccak256 digest of an EIP-191 signed data with version
     * `0x00` (data with intended validator).
     *
     * The digest is calculated by prefixing an arbitrary `data` with `"\x19\x00"` and the intended
     * `validator` address. Then hashing the result.
     *
     * See {ECDSA-recover}.
     */
    function toDataWithIntendedValidatorHash(address validator, bytes memory data) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(hex"19_00", validator, data));
    }

    /**
     * @dev Returns the keccak256 digest of an EIP-712 typed data (EIP-191 version `0x01`).
     *
     * The digest is calculated from a `domainSeparator` and a `structHash`, by prefixing them with
     * `\x19\x01` and hashing the result. It corresponds to the hash signed by the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`] JSON-RPC method as part of EIP-712.
     *
     * See {ECDSA-recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32 digest) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, hex"19_01")
            mstore(add(ptr, 0x02), domainSeparator)
            mstore(add(ptr, 0x22), structHash)
            digest := keccak256(ptr, 0x42)
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/introspection/ERC165.sol)

pragma solidity ^0.8.20;

import {IERC165} from "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/introspection/IERC165.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/Math.sol)

pragma solidity ^0.8.20;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Muldiv operation overflow.
     */
    error MathOverflowedMulDiv();

    enum Rounding {
        Floor, // Toward negative infinity
        Ceil, // Toward positive infinity
        Trunc, // Toward zero
        Expand // Away from zero
    }

    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
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
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
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
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds towards infinity instead
     * of rounding towards zero.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b == 0) {
            // Guarantee the same behavior as in a regular Solidity division.
            return a / b;
        }

        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or
     * denominator == 0.
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv) with further edits by
     * Uniswap Labs also under MIT license.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0 = x * y; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                // Solidity will revert if denominator == 0, unlike the div opcode on its own.
                // The surrounding unchecked block does not change this fact.
                // See https://docs.soliditylang.org/en/latest/control-structures.html#checked-or-unchecked-arithmetic.
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            if (denominator <= prod1) {
                revert MathOverflowedMulDiv();
            }

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator.
            // Always >= 1. See https://cs.stackexchange.com/q/138556/92363.

            uint256 twos = denominator & (0 - denominator);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also
            // works in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (unsignedRoundsUp(rounding) && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded
     * towards zero.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (unsignedRoundsUp(rounding) && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (unsignedRoundsUp(rounding) && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (unsignedRoundsUp(rounding) && 10 ** result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 256, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (unsignedRoundsUp(rounding) && 1 << (result << 3) < value ? 1 : 0);
        }
    }

    /**
     * @dev Returns whether a provided rounding mode is considered rounding up for unsigned integers.
     */
    function unsignedRoundsUp(Rounding rounding) internal pure returns (bool) {
        return uint8(rounding) % 2 == 1;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/SafeCast.sol)
// This file was procedurally generated from scripts/generate/templates/SafeCast.js.

pragma solidity ^0.8.20;

/**
 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeCast {
    /**
     * @dev Value doesn't fit in an uint of `bits` size.
     */
    error SafeCastOverflowedUintDowncast(uint8 bits, uint256 value);

    /**
     * @dev An int value doesn't fit in an uint of `bits` size.
     */
    error SafeCastOverflowedIntToUint(int256 value);

    /**
     * @dev Value doesn't fit in an int of `bits` size.
     */
    error SafeCastOverflowedIntDowncast(uint8 bits, int256 value);

    /**
     * @dev An uint value doesn't fit in an int of `bits` size.
     */
    error SafeCastOverflowedUintToInt(uint256 value);

    /**
     * @dev Returns the downcasted uint248 from uint256, reverting on
     * overflow (when the input is greater than largest uint248).
     *
     * Counterpart to Solidity's `uint248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     */
    function toUint248(uint256 value) internal pure returns (uint248) {
        if (value > type(uint248).max) {
            revert SafeCastOverflowedUintDowncast(248, value);
        }
        return uint248(value);
    }

    /**
     * @dev Returns the downcasted uint240 from uint256, reverting on
     * overflow (when the input is greater than largest uint240).
     *
     * Counterpart to Solidity's `uint240` operator.
     *
     * Requirements:
     *
     * - input must fit into 240 bits
     */
    function toUint240(uint256 value) internal pure returns (uint240) {
        if (value > type(uint240).max) {
            revert SafeCastOverflowedUintDowncast(240, value);
        }
        return uint240(value);
    }

    /**
     * @dev Returns the downcasted uint232 from uint256, reverting on
     * overflow (when the input is greater than largest uint232).
     *
     * Counterpart to Solidity's `uint232` operator.
     *
     * Requirements:
     *
     * - input must fit into 232 bits
     */
    function toUint232(uint256 value) internal pure returns (uint232) {
        if (value > type(uint232).max) {
            revert SafeCastOverflowedUintDowncast(232, value);
        }
        return uint232(value);
    }

    /**
     * @dev Returns the downcasted uint224 from uint256, reverting on
     * overflow (when the input is greater than largest uint224).
     *
     * Counterpart to Solidity's `uint224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     */
    function toUint224(uint256 value) internal pure returns (uint224) {
        if (value > type(uint224).max) {
            revert SafeCastOverflowedUintDowncast(224, value);
        }
        return uint224(value);
    }

    /**
     * @dev Returns the downcasted uint216 from uint256, reverting on
     * overflow (when the input is greater than largest uint216).
     *
     * Counterpart to Solidity's `uint216` operator.
     *
     * Requirements:
     *
     * - input must fit into 216 bits
     */
    function toUint216(uint256 value) internal pure returns (uint216) {
        if (value > type(uint216).max) {
            revert SafeCastOverflowedUintDowncast(216, value);
        }
        return uint216(value);
    }

    /**
     * @dev Returns the downcasted uint208 from uint256, reverting on
     * overflow (when the input is greater than largest uint208).
     *
     * Counterpart to Solidity's `uint208` operator.
     *
     * Requirements:
     *
     * - input must fit into 208 bits
     */
    function toUint208(uint256 value) internal pure returns (uint208) {
        if (value > type(uint208).max) {
            revert SafeCastOverflowedUintDowncast(208, value);
        }
        return uint208(value);
    }

    /**
     * @dev Returns the downcasted uint200 from uint256, reverting on
     * overflow (when the input is greater than largest uint200).
     *
     * Counterpart to Solidity's `uint200` operator.
     *
     * Requirements:
     *
     * - input must fit into 200 bits
     */
    function toUint200(uint256 value) internal pure returns (uint200) {
        if (value > type(uint200).max) {
            revert SafeCastOverflowedUintDowncast(200, value);
        }
        return uint200(value);
    }

    /**
     * @dev Returns the downcasted uint192 from uint256, reverting on
     * overflow (when the input is greater than largest uint192).
     *
     * Counterpart to Solidity's `uint192` operator.
     *
     * Requirements:
     *
     * - input must fit into 192 bits
     */
    function toUint192(uint256 value) internal pure returns (uint192) {
        if (value > type(uint192).max) {
            revert SafeCastOverflowedUintDowncast(192, value);
        }
        return uint192(value);
    }

    /**
     * @dev Returns the downcasted uint184 from uint256, reverting on
     * overflow (when the input is greater than largest uint184).
     *
     * Counterpart to Solidity's `uint184` operator.
     *
     * Requirements:
     *
     * - input must fit into 184 bits
     */
    function toUint184(uint256 value) internal pure returns (uint184) {
        if (value > type(uint184).max) {
            revert SafeCastOverflowedUintDowncast(184, value);
        }
        return uint184(value);
    }

    /**
     * @dev Returns the downcasted uint176 from uint256, reverting on
     * overflow (when the input is greater than largest uint176).
     *
     * Counterpart to Solidity's `uint176` operator.
     *
     * Requirements:
     *
     * - input must fit into 176 bits
     */
    function toUint176(uint256 value) internal pure returns (uint176) {
        if (value > type(uint176).max) {
            revert SafeCastOverflowedUintDowncast(176, value);
        }
        return uint176(value);
    }

    /**
     * @dev Returns the downcasted uint168 from uint256, reverting on
     * overflow (when the input is greater than largest uint168).
     *
     * Counterpart to Solidity's `uint168` operator.
     *
     * Requirements:
     *
     * - input must fit into 168 bits
     */
    function toUint168(uint256 value) internal pure returns (uint168) {
        if (value > type(uint168).max) {
            revert SafeCastOverflowedUintDowncast(168, value);
        }
        return uint168(value);
    }

    /**
     * @dev Returns the downcasted uint160 from uint256, reverting on
     * overflow (when the input is greater than largest uint160).
     *
     * Counterpart to Solidity's `uint160` operator.
     *
     * Requirements:
     *
     * - input must fit into 160 bits
     */
    function toUint160(uint256 value) internal pure returns (uint160) {
        if (value > type(uint160).max) {
            revert SafeCastOverflowedUintDowncast(160, value);
        }
        return uint160(value);
    }

    /**
     * @dev Returns the downcasted uint152 from uint256, reverting on
     * overflow (when the input is greater than largest uint152).
     *
     * Counterpart to Solidity's `uint152` operator.
     *
     * Requirements:
     *
     * - input must fit into 152 bits
     */
    function toUint152(uint256 value) internal pure returns (uint152) {
        if (value > type(uint152).max) {
            revert SafeCastOverflowedUintDowncast(152, value);
        }
        return uint152(value);
    }

    /**
     * @dev Returns the downcasted uint144 from uint256, reverting on
     * overflow (when the input is greater than largest uint144).
     *
     * Counterpart to Solidity's `uint144` operator.
     *
     * Requirements:
     *
     * - input must fit into 144 bits
     */
    function toUint144(uint256 value) internal pure returns (uint144) {
        if (value > type(uint144).max) {
            revert SafeCastOverflowedUintDowncast(144, value);
        }
        return uint144(value);
    }

    /**
     * @dev Returns the downcasted uint136 from uint256, reverting on
     * overflow (when the input is greater than largest uint136).
     *
     * Counterpart to Solidity's `uint136` operator.
     *
     * Requirements:
     *
     * - input must fit into 136 bits
     */
    function toUint136(uint256 value) internal pure returns (uint136) {
        if (value > type(uint136).max) {
            revert SafeCastOverflowedUintDowncast(136, value);
        }
        return uint136(value);
    }

    /**
     * @dev Returns the downcasted uint128 from uint256, reverting on
     * overflow (when the input is greater than largest uint128).
     *
     * Counterpart to Solidity's `uint128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        if (value > type(uint128).max) {
            revert SafeCastOverflowedUintDowncast(128, value);
        }
        return uint128(value);
    }

    /**
     * @dev Returns the downcasted uint120 from uint256, reverting on
     * overflow (when the input is greater than largest uint120).
     *
     * Counterpart to Solidity's `uint120` operator.
     *
     * Requirements:
     *
     * - input must fit into 120 bits
     */
    function toUint120(uint256 value) internal pure returns (uint120) {
        if (value > type(uint120).max) {
            revert SafeCastOverflowedUintDowncast(120, value);
        }
        return uint120(value);
    }

    /**
     * @dev Returns the downcasted uint112 from uint256, reverting on
     * overflow (when the input is greater than largest uint112).
     *
     * Counterpart to Solidity's `uint112` operator.
     *
     * Requirements:
     *
     * - input must fit into 112 bits
     */
    function toUint112(uint256 value) internal pure returns (uint112) {
        if (value > type(uint112).max) {
            revert SafeCastOverflowedUintDowncast(112, value);
        }
        return uint112(value);
    }

    /**
     * @dev Returns the downcasted uint104 from uint256, reverting on
     * overflow (when the input is greater than largest uint104).
     *
     * Counterpart to Solidity's `uint104` operator.
     *
     * Requirements:
     *
     * - input must fit into 104 bits
     */
    function toUint104(uint256 value) internal pure returns (uint104) {
        if (value > type(uint104).max) {
            revert SafeCastOverflowedUintDowncast(104, value);
        }
        return uint104(value);
    }

    /**
     * @dev Returns the downcasted uint96 from uint256, reverting on
     * overflow (when the input is greater than largest uint96).
     *
     * Counterpart to Solidity's `uint96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     */
    function toUint96(uint256 value) internal pure returns (uint96) {
        if (value > type(uint96).max) {
            revert SafeCastOverflowedUintDowncast(96, value);
        }
        return uint96(value);
    }

    /**
     * @dev Returns the downcasted uint88 from uint256, reverting on
     * overflow (when the input is greater than largest uint88).
     *
     * Counterpart to Solidity's `uint88` operator.
     *
     * Requirements:
     *
     * - input must fit into 88 bits
     */
    function toUint88(uint256 value) internal pure returns (uint88) {
        if (value > type(uint88).max) {
            revert SafeCastOverflowedUintDowncast(88, value);
        }
        return uint88(value);
    }

    /**
     * @dev Returns the downcasted uint80 from uint256, reverting on
     * overflow (when the input is greater than largest uint80).
     *
     * Counterpart to Solidity's `uint80` operator.
     *
     * Requirements:
     *
     * - input must fit into 80 bits
     */
    function toUint80(uint256 value) internal pure returns (uint80) {
        if (value > type(uint80).max) {
            revert SafeCastOverflowedUintDowncast(80, value);
        }
        return uint80(value);
    }

    /**
     * @dev Returns the downcasted uint72 from uint256, reverting on
     * overflow (when the input is greater than largest uint72).
     *
     * Counterpart to Solidity's `uint72` operator.
     *
     * Requirements:
     *
     * - input must fit into 72 bits
     */
    function toUint72(uint256 value) internal pure returns (uint72) {
        if (value > type(uint72).max) {
            revert SafeCastOverflowedUintDowncast(72, value);
        }
        return uint72(value);
    }

    /**
     * @dev Returns the downcasted uint64 from uint256, reverting on
     * overflow (when the input is greater than largest uint64).
     *
     * Counterpart to Solidity's `uint64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        if (value > type(uint64).max) {
            revert SafeCastOverflowedUintDowncast(64, value);
        }
        return uint64(value);
    }

    /**
     * @dev Returns the downcasted uint56 from uint256, reverting on
     * overflow (when the input is greater than largest uint56).
     *
     * Counterpart to Solidity's `uint56` operator.
     *
     * Requirements:
     *
     * - input must fit into 56 bits
     */
    function toUint56(uint256 value) internal pure returns (uint56) {
        if (value > type(uint56).max) {
            revert SafeCastOverflowedUintDowncast(56, value);
        }
        return uint56(value);
    }

    /**
     * @dev Returns the downcasted uint48 from uint256, reverting on
     * overflow (when the input is greater than largest uint48).
     *
     * Counterpart to Solidity's `uint48` operator.
     *
     * Requirements:
     *
     * - input must fit into 48 bits
     */
    function toUint48(uint256 value) internal pure returns (uint48) {
        if (value > type(uint48).max) {
            revert SafeCastOverflowedUintDowncast(48, value);
        }
        return uint48(value);
    }

    /**
     * @dev Returns the downcasted uint40 from uint256, reverting on
     * overflow (when the input is greater than largest uint40).
     *
     * Counterpart to Solidity's `uint40` operator.
     *
     * Requirements:
     *
     * - input must fit into 40 bits
     */
    function toUint40(uint256 value) internal pure returns (uint40) {
        if (value > type(uint40).max) {
            revert SafeCastOverflowedUintDowncast(40, value);
        }
        return uint40(value);
    }

    /**
     * @dev Returns the downcasted uint32 from uint256, reverting on
     * overflow (when the input is greater than largest uint32).
     *
     * Counterpart to Solidity's `uint32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        if (value > type(uint32).max) {
            revert SafeCastOverflowedUintDowncast(32, value);
        }
        return uint32(value);
    }

    /**
     * @dev Returns the downcasted uint24 from uint256, reverting on
     * overflow (when the input is greater than largest uint24).
     *
     * Counterpart to Solidity's `uint24` operator.
     *
     * Requirements:
     *
     * - input must fit into 24 bits
     */
    function toUint24(uint256 value) internal pure returns (uint24) {
        if (value > type(uint24).max) {
            revert SafeCastOverflowedUintDowncast(24, value);
        }
        return uint24(value);
    }

    /**
     * @dev Returns the downcasted uint16 from uint256, reverting on
     * overflow (when the input is greater than largest uint16).
     *
     * Counterpart to Solidity's `uint16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        if (value > type(uint16).max) {
            revert SafeCastOverflowedUintDowncast(16, value);
        }
        return uint16(value);
    }

    /**
     * @dev Returns the downcasted uint8 from uint256, reverting on
     * overflow (when the input is greater than largest uint8).
     *
     * Counterpart to Solidity's `uint8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        if (value > type(uint8).max) {
            revert SafeCastOverflowedUintDowncast(8, value);
        }
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        if (value < 0) {
            revert SafeCastOverflowedIntToUint(value);
        }
        return uint256(value);
    }

    /**
     * @dev Returns the downcasted int248 from int256, reverting on
     * overflow (when the input is less than smallest int248 or
     * greater than largest int248).
     *
     * Counterpart to Solidity's `int248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     */
    function toInt248(int256 value) internal pure returns (int248 downcasted) {
        downcasted = int248(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(248, value);
        }
    }

    /**
     * @dev Returns the downcasted int240 from int256, reverting on
     * overflow (when the input is less than smallest int240 or
     * greater than largest int240).
     *
     * Counterpart to Solidity's `int240` operator.
     *
     * Requirements:
     *
     * - input must fit into 240 bits
     */
    function toInt240(int256 value) internal pure returns (int240 downcasted) {
        downcasted = int240(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(240, value);
        }
    }

    /**
     * @dev Returns the downcasted int232 from int256, reverting on
     * overflow (when the input is less than smallest int232 or
     * greater than largest int232).
     *
     * Counterpart to Solidity's `int232` operator.
     *
     * Requirements:
     *
     * - input must fit into 232 bits
     */
    function toInt232(int256 value) internal pure returns (int232 downcasted) {
        downcasted = int232(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(232, value);
        }
    }

    /**
     * @dev Returns the downcasted int224 from int256, reverting on
     * overflow (when the input is less than smallest int224 or
     * greater than largest int224).
     *
     * Counterpart to Solidity's `int224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     */
    function toInt224(int256 value) internal pure returns (int224 downcasted) {
        downcasted = int224(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(224, value);
        }
    }

    /**
     * @dev Returns the downcasted int216 from int256, reverting on
     * overflow (when the input is less than smallest int216 or
     * greater than largest int216).
     *
     * Counterpart to Solidity's `int216` operator.
     *
     * Requirements:
     *
     * - input must fit into 216 bits
     */
    function toInt216(int256 value) internal pure returns (int216 downcasted) {
        downcasted = int216(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(216, value);
        }
    }

    /**
     * @dev Returns the downcasted int208 from int256, reverting on
     * overflow (when the input is less than smallest int208 or
     * greater than largest int208).
     *
     * Counterpart to Solidity's `int208` operator.
     *
     * Requirements:
     *
     * - input must fit into 208 bits
     */
    function toInt208(int256 value) internal pure returns (int208 downcasted) {
        downcasted = int208(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(208, value);
        }
    }

    /**
     * @dev Returns the downcasted int200 from int256, reverting on
     * overflow (when the input is less than smallest int200 or
     * greater than largest int200).
     *
     * Counterpart to Solidity's `int200` operator.
     *
     * Requirements:
     *
     * - input must fit into 200 bits
     */
    function toInt200(int256 value) internal pure returns (int200 downcasted) {
        downcasted = int200(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(200, value);
        }
    }

    /**
     * @dev Returns the downcasted int192 from int256, reverting on
     * overflow (when the input is less than smallest int192 or
     * greater than largest int192).
     *
     * Counterpart to Solidity's `int192` operator.
     *
     * Requirements:
     *
     * - input must fit into 192 bits
     */
    function toInt192(int256 value) internal pure returns (int192 downcasted) {
        downcasted = int192(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(192, value);
        }
    }

    /**
     * @dev Returns the downcasted int184 from int256, reverting on
     * overflow (when the input is less than smallest int184 or
     * greater than largest int184).
     *
     * Counterpart to Solidity's `int184` operator.
     *
     * Requirements:
     *
     * - input must fit into 184 bits
     */
    function toInt184(int256 value) internal pure returns (int184 downcasted) {
        downcasted = int184(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(184, value);
        }
    }

    /**
     * @dev Returns the downcasted int176 from int256, reverting on
     * overflow (when the input is less than smallest int176 or
     * greater than largest int176).
     *
     * Counterpart to Solidity's `int176` operator.
     *
     * Requirements:
     *
     * - input must fit into 176 bits
     */
    function toInt176(int256 value) internal pure returns (int176 downcasted) {
        downcasted = int176(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(176, value);
        }
    }

    /**
     * @dev Returns the downcasted int168 from int256, reverting on
     * overflow (when the input is less than smallest int168 or
     * greater than largest int168).
     *
     * Counterpart to Solidity's `int168` operator.
     *
     * Requirements:
     *
     * - input must fit into 168 bits
     */
    function toInt168(int256 value) internal pure returns (int168 downcasted) {
        downcasted = int168(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(168, value);
        }
    }

    /**
     * @dev Returns the downcasted int160 from int256, reverting on
     * overflow (when the input is less than smallest int160 or
     * greater than largest int160).
     *
     * Counterpart to Solidity's `int160` operator.
     *
     * Requirements:
     *
     * - input must fit into 160 bits
     */
    function toInt160(int256 value) internal pure returns (int160 downcasted) {
        downcasted = int160(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(160, value);
        }
    }

    /**
     * @dev Returns the downcasted int152 from int256, reverting on
     * overflow (when the input is less than smallest int152 or
     * greater than largest int152).
     *
     * Counterpart to Solidity's `int152` operator.
     *
     * Requirements:
     *
     * - input must fit into 152 bits
     */
    function toInt152(int256 value) internal pure returns (int152 downcasted) {
        downcasted = int152(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(152, value);
        }
    }

    /**
     * @dev Returns the downcasted int144 from int256, reverting on
     * overflow (when the input is less than smallest int144 or
     * greater than largest int144).
     *
     * Counterpart to Solidity's `int144` operator.
     *
     * Requirements:
     *
     * - input must fit into 144 bits
     */
    function toInt144(int256 value) internal pure returns (int144 downcasted) {
        downcasted = int144(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(144, value);
        }
    }

    /**
     * @dev Returns the downcasted int136 from int256, reverting on
     * overflow (when the input is less than smallest int136 or
     * greater than largest int136).
     *
     * Counterpart to Solidity's `int136` operator.
     *
     * Requirements:
     *
     * - input must fit into 136 bits
     */
    function toInt136(int256 value) internal pure returns (int136 downcasted) {
        downcasted = int136(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(136, value);
        }
    }

    /**
     * @dev Returns the downcasted int128 from int256, reverting on
     * overflow (when the input is less than smallest int128 or
     * greater than largest int128).
     *
     * Counterpart to Solidity's `int128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     */
    function toInt128(int256 value) internal pure returns (int128 downcasted) {
        downcasted = int128(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(128, value);
        }
    }

    /**
     * @dev Returns the downcasted int120 from int256, reverting on
     * overflow (when the input is less than smallest int120 or
     * greater than largest int120).
     *
     * Counterpart to Solidity's `int120` operator.
     *
     * Requirements:
     *
     * - input must fit into 120 bits
     */
    function toInt120(int256 value) internal pure returns (int120 downcasted) {
        downcasted = int120(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(120, value);
        }
    }

    /**
     * @dev Returns the downcasted int112 from int256, reverting on
     * overflow (when the input is less than smallest int112 or
     * greater than largest int112).
     *
     * Counterpart to Solidity's `int112` operator.
     *
     * Requirements:
     *
     * - input must fit into 112 bits
     */
    function toInt112(int256 value) internal pure returns (int112 downcasted) {
        downcasted = int112(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(112, value);
        }
    }

    /**
     * @dev Returns the downcasted int104 from int256, reverting on
     * overflow (when the input is less than smallest int104 or
     * greater than largest int104).
     *
     * Counterpart to Solidity's `int104` operator.
     *
     * Requirements:
     *
     * - input must fit into 104 bits
     */
    function toInt104(int256 value) internal pure returns (int104 downcasted) {
        downcasted = int104(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(104, value);
        }
    }

    /**
     * @dev Returns the downcasted int96 from int256, reverting on
     * overflow (when the input is less than smallest int96 or
     * greater than largest int96).
     *
     * Counterpart to Solidity's `int96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     */
    function toInt96(int256 value) internal pure returns (int96 downcasted) {
        downcasted = int96(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(96, value);
        }
    }

    /**
     * @dev Returns the downcasted int88 from int256, reverting on
     * overflow (when the input is less than smallest int88 or
     * greater than largest int88).
     *
     * Counterpart to Solidity's `int88` operator.
     *
     * Requirements:
     *
     * - input must fit into 88 bits
     */
    function toInt88(int256 value) internal pure returns (int88 downcasted) {
        downcasted = int88(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(88, value);
        }
    }

    /**
     * @dev Returns the downcasted int80 from int256, reverting on
     * overflow (when the input is less than smallest int80 or
     * greater than largest int80).
     *
     * Counterpart to Solidity's `int80` operator.
     *
     * Requirements:
     *
     * - input must fit into 80 bits
     */
    function toInt80(int256 value) internal pure returns (int80 downcasted) {
        downcasted = int80(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(80, value);
        }
    }

    /**
     * @dev Returns the downcasted int72 from int256, reverting on
     * overflow (when the input is less than smallest int72 or
     * greater than largest int72).
     *
     * Counterpart to Solidity's `int72` operator.
     *
     * Requirements:
     *
     * - input must fit into 72 bits
     */
    function toInt72(int256 value) internal pure returns (int72 downcasted) {
        downcasted = int72(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(72, value);
        }
    }

    /**
     * @dev Returns the downcasted int64 from int256, reverting on
     * overflow (when the input is less than smallest int64 or
     * greater than largest int64).
     *
     * Counterpart to Solidity's `int64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     */
    function toInt64(int256 value) internal pure returns (int64 downcasted) {
        downcasted = int64(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(64, value);
        }
    }

    /**
     * @dev Returns the downcasted int56 from int256, reverting on
     * overflow (when the input is less than smallest int56 or
     * greater than largest int56).
     *
     * Counterpart to Solidity's `int56` operator.
     *
     * Requirements:
     *
     * - input must fit into 56 bits
     */
    function toInt56(int256 value) internal pure returns (int56 downcasted) {
        downcasted = int56(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(56, value);
        }
    }

    /**
     * @dev Returns the downcasted int48 from int256, reverting on
     * overflow (when the input is less than smallest int48 or
     * greater than largest int48).
     *
     * Counterpart to Solidity's `int48` operator.
     *
     * Requirements:
     *
     * - input must fit into 48 bits
     */
    function toInt48(int256 value) internal pure returns (int48 downcasted) {
        downcasted = int48(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(48, value);
        }
    }

    /**
     * @dev Returns the downcasted int40 from int256, reverting on
     * overflow (when the input is less than smallest int40 or
     * greater than largest int40).
     *
     * Counterpart to Solidity's `int40` operator.
     *
     * Requirements:
     *
     * - input must fit into 40 bits
     */
    function toInt40(int256 value) internal pure returns (int40 downcasted) {
        downcasted = int40(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(40, value);
        }
    }

    /**
     * @dev Returns the downcasted int32 from int256, reverting on
     * overflow (when the input is less than smallest int32 or
     * greater than largest int32).
     *
     * Counterpart to Solidity's `int32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     */
    function toInt32(int256 value) internal pure returns (int32 downcasted) {
        downcasted = int32(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(32, value);
        }
    }

    /**
     * @dev Returns the downcasted int24 from int256, reverting on
     * overflow (when the input is less than smallest int24 or
     * greater than largest int24).
     *
     * Counterpart to Solidity's `int24` operator.
     *
     * Requirements:
     *
     * - input must fit into 24 bits
     */
    function toInt24(int256 value) internal pure returns (int24 downcasted) {
        downcasted = int24(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(24, value);
        }
    }

    /**
     * @dev Returns the downcasted int16 from int256, reverting on
     * overflow (when the input is less than smallest int16 or
     * greater than largest int16).
     *
     * Counterpart to Solidity's `int16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     */
    function toInt16(int256 value) internal pure returns (int16 downcasted) {
        downcasted = int16(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(16, value);
        }
    }

    /**
     * @dev Returns the downcasted int8 from int256, reverting on
     * overflow (when the input is less than smallest int8 or
     * greater than largest int8).
     *
     * Counterpart to Solidity's `int8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits
     */
    function toInt8(int256 value) internal pure returns (int8 downcasted) {
        downcasted = int8(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(8, value);
        }
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        // Note: Unsafe cast below is okay because `type(int256).max` is guaranteed to be positive
        if (value > uint256(type(int256).max)) {
            revert SafeCastOverflowedUintToInt(value);
        }
        return int256(value);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/SignedMath.sol)

pragma solidity ^0.8.20;

/**
 * @dev Standard signed math utilities missing in the Solidity language.
 */
library SignedMath {
    /**
     * @dev Returns the largest of two signed numbers.
     */
    function max(int256 a, int256 b) internal pure returns (int256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two signed numbers.
     */
    function min(int256 a, int256 b) internal pure returns (int256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two signed numbers without overflow.
     * The result is rounded towards zero.
     */
    function average(int256 a, int256 b) internal pure returns (int256) {
        // Formula from the book "Hacker's Delight"
        int256 x = (a & b) + ((a ^ b) >> 1);
        return x + (int256(uint256(x) >> 255) & (a ^ b));
    }

    /**
     * @dev Returns the absolute unsigned value of a signed value.
     */
    function abs(int256 n) internal pure returns (uint256) {
        unchecked {
            // must be unchecked in order to support `n = type(int256).min`
            return uint256(n >= 0 ? n : -n);
        }
    }
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

interface IWETHMinimum {
    function deposit() external payable;

    function transfer(address dst, uint256 wad) external returns (bool);

    function withdraw(uint256) external;

    function approve(address guy, uint256 wad) external returns (bool);

    function balanceOf(address dst) external view returns (uint256);
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "../governance/GovernableUpgradeable.sol";
import "../libraries/ReentrancyGuard.sol";
import "../libraries/ConfigurableUtil.sol";

abstract contract ConfigurableUpgradeable is IConfigurable, GovernableUpgradeable, ReentrancyGuard {
    using ConfigurableUtil for mapping(IERC20 market => MarketConfig);

    /// @custom:storage-location erc7201:Purecash.storage.ConfigurableUpgradeable
    struct ConfigurableStorage {
        mapping(IERC20 market => MarketConfig) marketConfigs;
    }

    // keccak256(abi.encode(uint256(keccak256("Purecash.storage.ConfigurableUpgradeable")) - 1))
    // & ~bytes32(uint256(0xff))
    bytes32 private constant CONFIGURABLE_UPGRADEABLE_STORAGE =
        0x2e53c93cfb85b377c33c5881ea2e8ae1c7fa4b789e2a859438dc71474e045100;

    function __Configurable_init(address _initialGov) internal onlyInitializing {
        __Governable_init(_initialGov);
        __Configurable_init_unchained();
    }

    function __Configurable_init_unchained() internal onlyInitializing {}

    /// @inheritdoc IConfigurable
    function isEnabledMarket(IERC20 _market) external view override returns (bool) {
        return _isEnabledMarket(_market);
    }

    /// @inheritdoc IConfigurable
    function marketConfigs(IERC20 _market) external view override returns (MarketConfig memory) {
        return _configurableStorage().marketConfigs[_market];
    }

    /// @inheritdoc IConfigurable
    function enableMarket(IERC20 _market, string calldata _tokenSymbol, MarketConfig calldata _cfg) external override {
        _onlyGov();
        _configurableStorage().marketConfigs.enableMarket(_market, _cfg);

        afterMarketEnabled(_market, _tokenSymbol);
    }

    /// @inheritdoc IConfigurable
    function updateMarketConfig(IERC20 _market, MarketConfig calldata _newCfg) public override {
        _onlyGov();
        _configurableStorage().marketConfigs.updateMarketConfig(_market, _newCfg);
    }

    function afterMarketEnabled(IERC20 _market, string calldata _tokenSymbol) internal virtual {
        // solhint-disable-previous-line no-empty-blocks
    }

    function _onlyEnabled(IERC20 _market) internal view {
        if (_configurableStorage().marketConfigs[_market].liquidityCap == 0) revert MarketNotEnabled(_market);
    }

    function _isEnabledMarket(IERC20 _market) internal view returns (bool) {
        return _configurableStorage().marketConfigs[_market].liquidityCap != 0;
    }

    function _configurableStorage() internal pure returns (ConfigurableStorage storage $) {
        // prettier-ignore
        assembly { $.slot := CONFIGURABLE_UPGRADEABLE_STORAGE }
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.8.26;

import "../libraries/Constants.sol";
import "../governance/GovernableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";

contract FeeDistributorUpgradeable is GovernableUpgradeable {
    using SafeCast for *;

    struct FeeDistribution {
        uint128 protocolFee;
        uint128 ecosystemFee;
        uint128 developmentFund;
    }

    /// @notice The rate at which fees are distributed to the protocol,
    /// denominated in thousandths of a bip (i.e. 1e-7)
    uint24 public protocolFeeRate;
    /// @notice The rate at which fees are distributed to the ecosystem,
    /// denominated in thousandths of a bip (i.e. 1e-7)
    uint24 public ecosystemFeeRate;
    mapping(IERC20 market => FeeDistribution) public feeDistributions;

    event FeeRateUpdated(uint24 newProtocolFeeRate, uint24 newEcosystemFeeRate);
    event FeeDeposited(IERC20 indexed token, uint128 protocolFee, uint128 ecosystemFee, uint128 developmentFund);
    event ProtocolFeeWithdrawal(IERC20 indexed token, address indexed receiver, uint128 amount);
    event EcosystemFeeWithdrawal(IERC20 indexed token, address indexed receiver, uint128 amount);
    event DevelopmentFundWithdrawal(IERC20 indexed token, address indexed receiver, uint128 amount);

    error InvalidFeeRate(uint24 protocolFeeRate, uint24 ecosystemFeeRate);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address _initialGov, uint24 _protocolFeeRate, uint24 _ecosystemFeeRate) public initializer {
        GovernableUpgradeable.__Governable_init(_initialGov);
        _updateFeeRate(_protocolFeeRate, _ecosystemFeeRate);
    }

    function updateFeeRate(uint24 _protocolFeeRate, uint24 _ecosystemFeeRate) external onlyGov {
        _updateFeeRate(_protocolFeeRate, _ecosystemFeeRate);
    }

    function deposit(IERC20 _token) external {
        uint256 balance = _token.balanceOf(address(this));
        FeeDistribution storage feeDistribution = feeDistributions[_token];
        uint128 delta = (balance -
            feeDistribution.protocolFee -
            feeDistribution.developmentFund -
            feeDistribution.ecosystemFee).toUint128();
        unchecked {
            uint128 protocolFeeDelta = uint128((uint256(delta) * protocolFeeRate) / Constants.BASIS_POINTS_DIVISOR);
            uint128 ecosystemFeeDelta = uint128((uint256(delta) * ecosystemFeeRate) / Constants.BASIS_POINTS_DIVISOR);
            uint128 developmentFundDelta = delta - protocolFeeDelta - ecosystemFeeDelta;

            // overflow is desired
            feeDistribution.protocolFee += protocolFeeDelta;
            feeDistribution.ecosystemFee += ecosystemFeeDelta;
            feeDistribution.developmentFund += developmentFundDelta;

            emit FeeDeposited(_token, protocolFeeDelta, ecosystemFeeDelta, developmentFundDelta);
        }
    }

    function withdrawProtocolFee(IERC20 _token, address _receiver, uint128 _amount) external onlyGov {
        feeDistributions[_token].protocolFee -= _amount;
        _token.transfer(_receiver, _amount);
        emit ProtocolFeeWithdrawal(_token, _receiver, _amount);
    }

    function withdrawEcosystemFee(IERC20 _token, address _receiver, uint128 _amount) external onlyGov {
        feeDistributions[_token].ecosystemFee -= _amount;
        _token.transfer(_receiver, _amount);
        emit EcosystemFeeWithdrawal(_token, _receiver, _amount);
    }

    function withdrawDevelopmentFund(IERC20 _token, address _receiver, uint128 _amount) external onlyGov {
        feeDistributions[_token].developmentFund -= _amount;
        _token.transfer(_receiver, _amount);
        emit DevelopmentFundWithdrawal(_token, _receiver, _amount);
    }

    function _updateFeeRate(uint24 _protocolFeeRate, uint24 _ecosystemFeeRate) internal {
        unchecked {
            require(
                uint32(_protocolFeeRate) + _ecosystemFeeRate <= Constants.BASIS_POINTS_DIVISOR,
                InvalidFeeRate(_protocolFeeRate, _ecosystemFeeRate)
            );
        }
        protocolFeeRate = _protocolFeeRate;
        ecosystemFeeRate = _ecosystemFeeRate;
        emit FeeRateUpdated(_protocolFeeRate, _ecosystemFeeRate);
    }

    /// @inheritdoc UUPSUpgradeable
    function _authorizeUpgrade(address newImplementation) internal virtual override onlyGov {}
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.8.26;

import "../libraries/Constants.sol";
import "./interfaces/ILPToken.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract LPToken is ILPToken, ERC20Permit {
    address public immutable marketManager;

    IERC20 public market;
    string private _symbol;

    error Forbidden();
    error AlreadyInitialized();

    modifier onlyMarketManager() {
        if (marketManager != _msgSender()) revert Forbidden();
        _;
    }

    constructor() ERC20("Pure.cash LP", "") ERC20Permit("Pure.cash LP") {
        marketManager = _msgSender();
    }

    function initialize(IERC20 market_, string calldata symbol_) external onlyMarketManager {
        require(market == IERC20(address(0)), AlreadyInitialized());
        market = market_;
        _symbol = symbol_;
    }

    /// @inheritdoc ERC20
    function decimals() public pure virtual override returns (uint8) {
        return Constants.DECIMALS_6;
    }

    /// @inheritdoc ERC20
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function mint(address _to, uint256 _amount) external onlyMarketManager {
        _mint(_to, _amount);
    }

    function burn(uint256 _amount) external onlyMarketManager {
        _burn(msg.sender, _amount);
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "./ConfigurableUpgradeable.sol";
import "./FeeDistributorUpgradeable.sol";
import "../libraries/MarketUtil.sol";
import "../libraries/PUSDManagerUtil.sol";
import "../plugins/PluginManagerUpgradeable.sol";

abstract contract MarketManagerStatesUpgradeable is IMarketManager, ConfigurableUpgradeable, PluginManagerUpgradeable {
    using SafeCast for *;

    /// @custom:storage-location erc7201:Purecash.storage.MarketManagerStatesUpgradeable
    struct MarketManagerStatesStorage {
        mapping(IERC20 market => State) marketStates;
        FeeDistributorUpgradeable feeDistributor;
    }

    // keccak256(abi.encode(uint256(keccak256("Purecash.storage.MarketManagerStatesUpgradeable")) - 1))
    // & ~bytes32(uint256(0xff))
    bytes32 private constant MARKET_MANAGER_STATES_UPGRADEABLE_STORAGE =
        0x251c369f4ebdedc72c1498dbeb9b538f609b170856998c6e34e4ab95eaf53300;

    function __MarketManagerStates_init(
        address _initialGov,
        FeeDistributorUpgradeable _feeDistributor
    ) internal onlyInitializing {
        __Configurable_init(_initialGov);
        __MarketManagerStates_init_unchained(_feeDistributor);
    }

    function __MarketManagerStates_init_unchained(FeeDistributorUpgradeable _feeDistributor) internal onlyInitializing {
        MarketManagerStatesStorage storage $ = _statesStorage();
        $.feeDistributor = _feeDistributor;
    }

    /// @inheritdoc IMarketManager
    function packedStates(IERC20 _market) external view override returns (PackedState memory) {
        return _statesStorage().marketStates[_market].packedState;
    }

    /// @inheritdoc IMarketManager
    function protocolFees(IERC20 _market) external view override returns (uint128) {
        return _statesStorage().marketStates[_market].protocolFee;
    }

    /// @inheritdoc IMarketManager
    function tokenBalances(IERC20 _market) external view override returns (uint128) {
        return _statesStorage().marketStates[_market].tokenBalance;
    }

    /// @inheritdoc IMarketManager
    function liquidityBufferModules(IERC20 _market) external view override returns (LiquidityBufferModule memory) {
        return _statesStorage().marketStates[_market].liquidityBufferModule;
    }

    /// @inheritdoc IPUSDManager
    function globalPUSDPositions(IERC20 _market) external view returns (GlobalPUSDPosition memory) {
        return _statesStorage().marketStates[_market].globalPUSDPosition;
    }

    /// @inheritdoc IMarketPosition
    function longPositions(IERC20 _market, address _account) external view override returns (Position memory) {
        return _statesStorage().marketStates[_market].longPositions[_account];
    }

    /// @inheritdoc IMarketManager
    function globalStabilityFunds(IERC20 _market) external view override returns (uint256) {
        return _statesStorage().marketStates[_market].globalStabilityFund;
    }

    function pusd() external view returns (address) {
        return PUSDManagerUtil.computePUSDAddress();
    }

    function _statesStorage() internal pure returns (MarketManagerStatesStorage storage $) {
        // prettier-ignore
        assembly { $.slot := MARKET_MANAGER_STATES_UPGRADEABLE_STORAGE }
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.8.26;

import "./PSMUpgradeable.sol";
import "../libraries/LiquidityUtil.sol";
import "../plugins/PluginManagerUpgradeable.sol";
import "../oracle/PriceFeedUpgradeable.sol";

/// @custom:oz-upgrades-unsafe-allow external-library-linking
contract MarketManagerUpgradeable is PSMUpgradeable, PriceFeedUpgradeable {
    using SafeCast for *;
    using SafeERC20 for IERC20;
    using MarketUtil for State;
    using PositionUtil for State;
    using PUSDManagerUtil for State;
    using LiquidityUtil for State;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        address _initialGov,
        FeeDistributorUpgradeable _feeDistributor,
        bool _ignoreReferencePriceFeedError
    ) public initializer {
        PUSD pusd = PUSDManagerUtil.deployPUSD();
        emit IPUSDManager.PUSDDeployed(pusd);

        PSMUpgradeable.__PSM_init(_initialGov, _feeDistributor);
        PriceFeedUpgradeable.__PriceFeed_init_unchained(_ignoreReferencePriceFeedError);
    }

    /// @inheritdoc IMarketLiquidity
    function mintLPT(
        IERC20 _market,
        address _account,
        address _receiver
    ) external override nonReentrant returns (uint64 tokenValue) {
        _onlyPlugin();

        MarketManagerStatesStorage storage $ = _statesStorage();
        State storage state = $.marketStates[_market];

        uint128 balanceAfter = _market.balanceOf(address(this)).toUint128();
        uint96 liquidity = (balanceAfter - state.tokenBalance).toUint96();
        state.tokenBalance = balanceAfter;

        tokenValue = state.mintLPT(
            _configurableStorage().marketConfigs[_market],
            LiquidityUtil.MintParam({
                market: _market,
                account: _account,
                receiver: _receiver,
                liquidity: liquidity,
                indexPrice: _getMaxPrice(_market)
            })
        );
    }

    /// @inheritdoc IMarketLiquidity
    function burnLPT(
        IERC20 _market,
        address _account,
        address _receiver
    ) external override nonReentrant returns (uint96 liquidity) {
        _onlyPlugin();

        MarketManagerStatesStorage storage $ = _statesStorage();
        State storage state = $.marketStates[_market];

        liquidity = state.burnLPT(
            LiquidityUtil.BurnParam({
                market: _market,
                account: _account,
                receiver: _receiver,
                tokenValue: ILPToken(LiquidityUtil.computeLPTokenAddress(_market)).balanceOf(address(this)).toUint64(),
                indexPrice: _getMaxPrice(_market)
            })
        );

        state.tokenBalance -= liquidity;
        _market.safeTransfer(_receiver, liquidity);
    }

    /// @inheritdoc IMarketManager
    function govUseStabilityFund(
        IERC20 _market,
        address _receiver,
        uint128 _stabilityFundDelta
    ) external override nonReentrant {
        _onlyGov();

        State storage state = _statesStorage().marketStates[_market];

        state.govUseStabilityFund(_market, _stabilityFundDelta, _receiver);

        state.tokenBalance -= _stabilityFundDelta;
        _market.safeTransfer(_receiver, _stabilityFundDelta);
    }

    /// @inheritdoc IMarketPosition
    function increasePosition(
        IERC20 _market,
        address _account,
        uint96 _sizeDelta
    ) external override nonReentrant returns (uint96 spread) {
        _onlyPlugin();

        MarketManagerStatesStorage storage $ = _statesStorage();
        State storage state = $.marketStates[_market];

        uint128 balanceAfter = _market.balanceOf(address(this)).toUint128();
        uint96 marginDelta = (balanceAfter - state.tokenBalance).toUint96();
        state.tokenBalance = balanceAfter;

        (uint64 minIndexPrice, uint64 maxIndexPrice) = _getPrice(_market);
        spread = state.increasePosition(
            _configurableStorage().marketConfigs[_market],
            PositionUtil.IncreasePositionParam({
                market: _market,
                account: _account,
                marginDelta: marginDelta,
                sizeDelta: _sizeDelta,
                minIndexPrice: minIndexPrice,
                maxIndexPrice: maxIndexPrice
            })
        );
    }

    /// @inheritdoc IMarketPosition
    function decreasePosition(
        IERC20 _market,
        address _account,
        uint96 _marginDelta,
        uint96 _sizeDelta,
        address _receiver
    ) external override nonReentrant returns (uint96 spread, uint96 actualMarginDelta) {
        _onlyPlugin();

        MarketManagerStatesStorage storage $ = _statesStorage();
        State storage state = $.marketStates[_market];

        (uint64 minIndexPrice, uint64 maxIndexPrice) = _getPrice(_market);
        (spread, actualMarginDelta) = state.decreasePosition(
            _configurableStorage().marketConfigs[_market],
            PositionUtil.DecreasePositionParam({
                market: _market,
                account: _account,
                marginDelta: _marginDelta,
                sizeDelta: _sizeDelta,
                minIndexPrice: minIndexPrice,
                maxIndexPrice: maxIndexPrice,
                receiver: _receiver
            })
        );
        state.tokenBalance -= actualMarginDelta;
        _market.safeTransfer(_receiver, actualMarginDelta);
    }

    /// @inheritdoc IMarketPosition
    function liquidatePosition(IERC20 _market, address _account, address _feeReceiver) external override nonReentrant {
        _onlyPlugin();

        MarketManagerStatesStorage storage $ = _statesStorage();
        State storage state = $.marketStates[_market];

        uint64 executionFee;
        (uint64 minIndexPrice, uint64 maxIndexPrice) = _getPrice(_market);
        executionFee = state.liquidatePosition(
            _configurableStorage().marketConfigs[_market],
            PositionUtil.LiquidatePositionParam({
                market: _market,
                account: _account,
                minIndexPrice: minIndexPrice,
                maxIndexPrice: maxIndexPrice,
                feeReceiver: _feeReceiver
            })
        );

        state.tokenBalance -= executionFee;
        _market.safeTransfer(_feeReceiver, executionFee);
    }

    /// @inheritdoc IPUSDManager
    function mintPUSD(
        IERC20 _market,
        bool _exactIn,
        uint96 _amount,
        IPUSDManagerCallback _callback,
        bytes calldata _data,
        address _receiver
    ) external override nonReentrant returns (uint96 payAmount, uint64 receiveAmount) {
        _onlyPlugin();

        MarketManagerStatesStorage storage $ = _statesStorage();
        State storage state = $.marketStates[_market];

        (payAmount, receiveAmount) = state.mint(
            _configurableStorage().marketConfigs[_market],
            PUSDManagerUtil.MintParam({
                market: _market,
                exactIn: _exactIn,
                amount: _amount,
                callback: _callback,
                indexPrice: _getMinPrice(_market),
                receiver: _receiver
            }),
            _data
        );
    }

    /// @inheritdoc IPUSDManager
    function burnPUSD(
        IERC20 _market,
        bool _exactIn,
        uint96 _amount,
        IPUSDManagerCallback _callback,
        bytes calldata _data,
        address _receiver
    ) external override nonReentrant returns (uint64 payAmount, uint96 receiveAmount) {
        _onlyPlugin();

        MarketManagerStatesStorage storage $ = _statesStorage();
        State storage state = $.marketStates[_market];

        (payAmount, receiveAmount) = state.burn(
            _configurableStorage().marketConfigs[_market],
            PUSDManagerUtil.BurnParam({
                market: _market,
                exactIn: _exactIn,
                amount: _amount,
                callback: _callback,
                indexPrice: _getMaxPrice(_market),
                receiver: _receiver
            }),
            _data
        );
    }

    /// @inheritdoc IMarketManager
    function collectProtocolFee(IERC20 _market) external override nonReentrant {
        MarketManagerStatesStorage storage $ = _statesStorage();
        State storage state = $.marketStates[_market];

        uint128 protocolFee_ = state.protocolFee;
        state.protocolFee = 0;
        state.tokenBalance -= protocolFee_;

        FeeDistributorUpgradeable feeDistributor_ = $.feeDistributor;
        _market.safeTransfer(address(feeDistributor_), protocolFee_);
        feeDistributor_.deposit(_market);

        emit ProtocolFeeCollected(_market, protocolFee_);
    }

    /// @inheritdoc IMarketManager
    function repayLiquidityBufferDebt(
        IERC20 _market,
        address _account,
        address _receiver
    ) external override nonReentrant returns (uint128 receiveAmount) {
        _onlyPlugin();

        MarketManagerStatesStorage storage $ = _statesStorage();
        State storage state = $.marketStates[_market];

        return state.repayLiquidityBufferDebt(_market, _account, _receiver);
    }

    /// @inheritdoc ConfigurableUpgradeable
    function afterMarketEnabled(IERC20 _market, string calldata _tokenSymbol) internal override {
        ILPToken token = LiquidityUtil.deployLPToken(_market, _tokenSymbol);
        emit IMarketLiquidity.LPTokenDeployed(_market, token);
    }

    /// @inheritdoc UUPSUpgradeable
    function _authorizeUpgrade(address newImplementation) internal virtual override onlyGov {}
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "./MarketManagerStatesUpgradeable.sol";
import "../libraries/PUSDManagerUtil.sol";

abstract contract PSMUpgradeable is MarketManagerStatesUpgradeable {
    using PUSDManagerUtil for CollateralState;

    /// @custom:storage-location erc7201:Purecash.storage.PSMUpgradeable
    struct PSMStorage {
        mapping(IERC20 collateral => CollateralState) collaterals;
    }

    // keccak256(abi.encode(uint256(keccak256("Purecash.storage.PSMUpgradeable")) - 1))
    // & ~bytes32(uint256(0xff))
    bytes32 private constant PSM_UPGRADEABLE_STORAGE =
        0x9f37cc75d7cdaa7a198c13b92cf96b51104a2ab8d71dd4736b100ec4a2373c00;

    function __PSM_init(address _initialGov, FeeDistributorUpgradeable _feeDistributor) internal onlyInitializing {
        MarketManagerStatesUpgradeable.__MarketManagerStates_init(_initialGov, _feeDistributor);
    }

    /// @inheritdoc IPSM
    function psmCollateralStates(IERC20 _collateral) external view override returns (CollateralState memory state) {
        state = _psmStorage().collaterals[_collateral];
    }

    /// @inheritdoc IPSM
    function updatePSMCollateralCap(IERC20 _collateral, uint120 _cap) external override {
        _onlyGov();

        _psmStorage().collaterals[_collateral].updatePSMCollateralCap(_collateral, _cap);
    }

    /// @inheritdoc IPSM
    function psmMintPUSD(
        IERC20 _collateral,
        address _receiver
    ) external override nonReentrantToken(_collateral) returns (uint64 receiveAmount) {
        _onlyPlugin();

        receiveAmount = _psmStorage().collaterals[_collateral].psmMint(_collateral, _receiver);
    }

    /// @inheritdoc IPSM
    function psmBurnPUSD(
        IERC20 _collateral,
        address _receiver
    ) external override nonReentrantToken(_collateral) returns (uint96 receiveAmount) {
        _onlyPlugin();

        receiveAmount = _psmStorage().collaterals[_collateral].psmBurn(_collateral, _receiver);
    }

    function _psmStorage() internal pure returns (PSMStorage storage $) {
        // prettier-ignore
        assembly { $.slot := PSM_UPGRADEABLE_STORAGE }
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.8.26;

import "./interfaces/IPUSD.sol";
import "../libraries/Constants.sol";
import "../governance/Governable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract PUSD is ERC20, ERC20Permit, IPUSD {
    address public immutable marketManager;

    constructor() ERC20("Pure USD", "PUSD") ERC20Permit("Pure USD") {
        marketManager = msg.sender;
    }

    /// @inheritdoc ERC20
    function decimals() public view virtual override returns (uint8) {
        return Constants.DECIMALS_6;
    }

    /// @inheritdoc IPUSD
    function mint(address _to, uint256 _value) external override {
        require(msg.sender == marketManager, Governable.Forbidden());

        _mint(_to, _value);
    }

    /// @inheritdoc IPUSD
    function burn(uint256 _value) external override {
        require(msg.sender == marketManager, Governable.Forbidden());

        _burn(msg.sender, _value);
    }
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title Configurable Interface
/// @notice This interface defines the functions for manage market configurations
interface IConfigurable {
    struct MarketConfig {
        /// @notice The liquidation fee rate for per trader position,
        /// denominated in thousandths of a bip (i.e. 1e-7)
        uint24 liquidationFeeRatePerPosition;
        /// @notice The maximum size rate for per position, denominated in thousandths of a bip (i.e. 1e-7)
        uint24 maxSizeRatePerPosition;
        /// @notice If the balance rate after increasing a long position is greater than this parameter,
        /// then the trading fee rate will be changed to the floating fee rate,
        /// denominated in thousandths of a bip (i.e. 1e-7)
        uint24 openPositionThreshold;
        /// @notice The trading fee rate for taker increase or decrease positions,
        /// denominated in thousandths of a bip (i.e. 1e-7)
        uint24 tradingFeeRate;
        /// @notice The maximum leverage for per trader position, for example, 100 means the maximum leverage
        /// is 100 times
        uint8 maxLeveragePerPosition;
        /// @notice The market token decimals
        uint8 decimals;
        /// @notice A system variable to calculate the `spread`
        uint120 liquidityScale;
        /// @notice The protocol fee rate as a percentage of trading fee,
        /// denominated in thousandths of a bip (i.e. 1e-7)
        uint24 protocolFeeRate;
        /// @notice The maximum floating fee rate for increasing long position,
        /// denominated in thousandths of a bip (i.e. 1e-7)
        uint24 maxFeeRate;
        /// @notice A system variable to calculate the `spreadFactor`, in seconds
        uint24 riskFreeTime;
        /// @notice The minimum entry margin required for per trader position
        uint64 minMarginPerPosition;
        /// @notice If balance rate is less than minMintingRate, the minting is disabled,
        /// denominated in thousandths of a bip (i.e. 1e-7)
        uint24 minMintingRate;
        /// @notice If balance rate is greater than maxBurningRate, the burning is disabled,
        /// denominated in thousandths of a bip (i.e. 1e-7)
        uint24 maxBurningRate;
        /// @notice The liquidation execution fee for LP and trader positions
        uint64 liquidationExecutionFee;
        /// @notice Whether the liquidity buffer module is enabled when decreasing position
        bool liquidityBufferModuleEnabled;
        /// @notice If the total supply of the stable coin reach stableCoinSupplyCap, the minting is disabled.
        uint64 stableCoinSupplyCap;
        /// @notice The capacity of the liquidity
        uint120 liquidityCap;
    }

    /// @notice Emitted when the market is enabled
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param cfg The new market configuration
    event MarketConfigEnabled(IERC20 indexed market, MarketConfig cfg);

    /// @notice Emitted when a market configuration is changed
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param cfg The new market configuration
    event MarketConfigChanged(IERC20 indexed market, MarketConfig cfg);

    /// @notice Market is already enabled
    error MarketAlreadyEnabled(IERC20 market);
    /// @notice Market is not enabled
    error MarketNotEnabled(IERC20 market);
    /// @notice Invalid maximum leverage for trader positions
    error InvalidMaxLeveragePerPosition(uint8 maxLeveragePerPosition);
    /// @notice Invalid liquidation fee rate for trader positions
    error InvalidLiquidationFeeRatePerPosition(uint24 liquidationFeeRatePerPosition);
    /// @notice Invalid max size per rate for per position
    error InvalidMaxSizeRatePerPosition(uint24 maxSizeRatePerPosition);
    /// @notice Invalid liquidity capacity
    error InvalidLiquidityCap(uint120 liquidityCap);
    /// @notice Invalid trading fee rate
    error InvalidTradingFeeRate(uint24 tradingFeeRate);
    /// @notice Invalid protocol fee rate
    error InvalidProtocolFeeRate(uint24 protocolFeeRate);
    /// @notice Invalid min minting rate
    error InvalidMinMintingRate(uint24 minMintingRate);
    /// @notice Invalid max burning rate
    error InvalidMaxBurningRate(uint24 maxBurnningRate);
    /// @notice Invalid open position threshold
    error InvalidOpenPositionThreshold(uint24 openPositionThreshold);
    /// @notice Invalid max fee rate
    error InvalidMaxFeeRate(uint24 maxFeeRate);
    /// @notice The risk free time is zero, which is not allowed
    error ZeroRiskFreeTime();
    /// @notice The liquidity scale is zero, which is not allowed
    error ZeroLiquidityScale();
    /// @notice Invalid stable coin supply capacity
    error InvalidStableCoinSupplyCap(uint256 stablecoinSupplyCap);
    /// @notice Invalid decimals
    error InvalidDecimals(uint8 decimals);

    /// @notice Checks if a market is enabled
    /// @param market The target market contract address, such as the contract address of WETH
    /// @return True if the market is enabled, false otherwise
    function isEnabledMarket(IERC20 market) external view returns (bool);

    /// @notice Get the information of market configuration
    /// @param market The target market contract address, such as the contract address of WETH
    function marketConfigs(IERC20 market) external view returns (MarketConfig memory);

    /// @notice Enable the market
    /// @dev The call will fail if caller is not the governor or the market is already enabled
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param tokenSymbol The symbol of the LP token
    /// @param cfg The market configuration
    function enableMarket(IERC20 market, string calldata tokenSymbol, MarketConfig calldata cfg) external;

    /// @notice Update a market configuration
    /// @dev The call will fail if caller is not the governor or the market is not enabled
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param newCfg The new market configuration
    function updateMarketConfig(IERC20 market, MarketConfig calldata newCfg) external;
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ILPToken is IERC20 {
    function mint(address to, uint256 amount) external;

    function burn(uint256 amount) external;
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

interface IMarketErrors {
    /// @notice Failed to transfer ETH
    error FailedTransferETH();
    /// @notice Invalid caller
    error InvalidCaller(address requiredCaller);
    /// @notice Insufficient size to decrease
    error InsufficientSizeToDecrease(uint128 requiredSize, uint128 size);
    /// @notice Insufficient margin
    error InsufficientMargin();
    /// @notice Position not found
    error PositionNotFound(address requiredAccount);
    /// @notice Size exceeds max size per position
    error SizeExceedsMaxSizePerPosition(uint256 requiredSize, uint256 maxSizePerPosition);
    /// @notice Size exceeds max size
    error SizeExceedsMaxSize(uint256 requiredSize, uint256 maxSize);
    /// @notice Insufficient liquidity to decrease
    error InsufficientLiquidityToDecrease(uint256 liquidity, uint128 requiredLiquidity);
    /// @notice Liquidity Cap exceeded
    error LiquidityCapExceeded(uint128 liquidityBefore, uint96 liquidityDelta, uint120 liquidityCap);
    /// @notice Balance Rate Cap exceeded
    error BalanceRateCapExceeded();
    /// @notice Error thrown when min minting size cap is not met
    error MinMintingSizeCapNotMet(uint128 netSize, uint128 sizeDelta, uint128 minMintingSizeCap);
    /// @notice Error thrown when max burning size cap is exceeded
    error MaxBurningSizeCapExceeded(uint128 netSize, uint128 sizeDelta, uint256 maxBurningSizeCap);
    /// @notice Insufficient balance
    error InsufficientBalance(uint256 balance, uint256 requiredAmount);
    /// @notice Leverage is too high
    error LeverageTooHigh(uint256 margin, uint128 size, uint8 maxLeverage);
    /// @notice Position margin rate is too low
    error MarginRateTooLow(int256 margin, uint256 maintenanceMargin);
    /// @notice Position margin rate is too high
    error MarginRateTooHigh(int256 margin, uint256 maintenanceMargin);
    error InvalidAmount(uint128 requiredAmount, uint128 pusdBalance);
    error InvalidSize();
    /// @notice Stable Coin Supply Cap exceeded
    error StableCoinSupplyCapExceeded(uint256 supplyCap, uint256 totalSupply, uint256 amountDelta);
    /// @notice Error thrown when the pay amount is less than the required amount
    error TooLittlePayAmount(uint128 requiredAmount, uint128 payAmount);
    /// @notice Error thrown when the pay amount is not equal to the required amount
    error UnexpectedPayAmount(uint128 requiredAmount, uint128 payAmount);
    error NegativeReceiveAmount(int256 receiveAmount);
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "./ILPToken.sol";

/// @notice Interface for managing liquidity of the protocol
interface IMarketLiquidity {
    /// @notice Emitted when the global liquidity is increased by trading fee
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param liquidityFee The increased liquidity fee
    event GlobalLiquidityIncreasedByTradingFee(IERC20 indexed market, uint96 liquidityFee);

    /// @notice Emitted when the global liquidity is settled
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param sizeDelta The change in the global liquidity
    /// @param realizedPnL The realized PnL of the global liquidity
    /// @param entryPriceAfter The entry price after the settlement
    event GlobalLiquiditySettled(IERC20 indexed market, int256 sizeDelta, int256 realizedPnL, uint64 entryPriceAfter);

    /// @notice Emitted when a new LP Token is deployed
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param token The LP Token contract address
    event LPTokenDeployed(IERC20 indexed market, ILPToken indexed token);

    /// @notice Emitted when the LP Token is minted
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param account The owner of the LP Token
    /// @param receiver The address to receive the minted LP Token
    /// @param liquidity The liquidity provided by the LP
    /// @param tokenValue The LP Token to be minted
    event LPTMinted(
        IERC20 indexed market,
        address indexed account,
        address indexed receiver,
        uint96 liquidity,
        uint64 tokenValue
    );

    /// @notice Emitted when the LP Token is burned
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param account The owner of the LP Token
    /// @param receiver The address to receive the margin
    /// @param liquidity The liquidity to be returned to the LP
    /// @param tokenValue The LP Token to be burned
    event LPTBurned(
        IERC20 indexed market,
        address indexed account,
        address indexed receiver,
        uint96 liquidity,
        uint64 tokenValue
    );

    /// @notice Mint the LP Token
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param account The address to mint the liquidity. The parameter is only used for emitting event
    /// @param receiver The address to receive the minted LP Token
    /// @return tokenValue The LP Token to be minted
    function mintLPT(IERC20 market, address account, address receiver) external returns (uint64 tokenValue);

    /// @notice Burn the LP Token
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param account The address to burn the liquidity. The parameter is only used for emitting event
    /// @param receiver The address to receive the returned liquidity
    /// @return liquidity The liquidity to be returned to the LP
    function burnLPT(IERC20 market, address account, address receiver) external returns (uint96 liquidity);
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "./IPSM.sol";
import "./IConfigurable.sol";
import "./IMarketErrors.sol";
import "./IPUSDManager.sol";
import "./IMarketPosition.sol";
import "./IMarketLiquidity.sol";
import "../../oracle/interfaces/IPriceFeed.sol";
import "../../plugins/interfaces/IPluginManager.sol";
import "../../oracle/interfaces/IPriceFeed.sol";

interface IMarketManager is
    IMarketErrors,
    IMarketPosition,
    IMarketLiquidity,
    IPUSDManager,
    IConfigurable,
    IPluginManager,
    IPriceFeed,
    IPSM
{
    struct LiquidityBufferModule {
        /// @notice The debt of the liquidity buffer module
        uint128 pusdDebt;
        /// @notice The token payback of the liquidity buffer module
        uint128 tokenPayback;
    }

    struct PackedState {
        /// @notice The spread factor used to calculate spread
        int256 spreadFactorX96;
        /// @notice Last trading timestamp in seconds since Unix epoch
        uint64 lastTradingTimestamp;
        /// @notice The sum of long position sizes
        uint128 longSize;
        /// @notice The entry price of the net position
        uint64 lpEntryPrice;
        /// @notice The total liquidity of all LPs
        uint128 lpLiquidity;
        /// @notice The size of the net position held by all LPs
        uint128 lpNetSize;
    }

    struct State {
        /// @notice The packed state of the market
        PackedState packedState;
        /// @notice The value is used to track the global PUSD position
        GlobalPUSDPosition globalPUSDPosition;
        /// @notice Mapping of account to long position
        mapping(address account => Position) longPositions;
        /// @notice The value is used to track the liquidity buffer module status
        LiquidityBufferModule liquidityBufferModule;
        /// @notice The value is used to track the remaining protocol fee of the market
        uint128 protocolFee;
        /// @notice The value is used to track the token balance of the market
        uint128 tokenBalance;
        /// @notice The margin of the global stability fund
        uint256 globalStabilityFund;
    }

    /// @notice Emitted when the protocol fee is increased
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param amount The increased protocol fee
    event ProtocolFeeIncreased(IERC20 indexed market, uint96 amount);

    /// @notice Emitted when the protocol fee is collected
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param amount The collected protocol fee
    event ProtocolFeeCollected(IERC20 indexed market, uint128 amount);

    /// @notice Emitted when the stability fund is used by `Gov`
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param receiver The address that receives the stability fund
    /// @param stabilityFundDelta The amount of stability fund used
    event GlobalStabilityFundGovUsed(IERC20 indexed market, address indexed receiver, uint128 stabilityFundDelta);

    /// @notice Emitted when the liquidity of the stability fund is increased by liquidation
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param liquidationFee The amount of the liquidation fee that is added to the stability fund.
    event GlobalStabilityFundIncreasedByLiquidation(IERC20 indexed market, uint96 liquidationFee);

    /// @notice Emitted when the liquidity of the stability fund is increased by spread
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param spread The spread incurred by the position
    event GlobalStabilityFundIncreasedBySpread(IERC20 indexed market, uint96 spread);

    /// @notice Emitted when the liquidity buffer module debt is increased
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param account The address for debt repayment
    /// @param pusdDebtDelta The increase in the debt of the LBM module
    /// @param tokenPaybackDelta The increase in the token payback of the LBM module
    event LiquidityBufferModuleDebtIncreased(
        IERC20 market,
        address account,
        uint128 pusdDebtDelta,
        uint128 tokenPaybackDelta
    );

    /// @notice Emitted when the liquidity buffer module debt is repaid
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param account The address for debt repayment
    /// @param pusdDebtDelta The decrease in the debt of the LBM module
    /// @param tokenPaybackDelta The decrease in the token payback of the LBM module
    event LiquidityBufferModuleDebtRepaid(
        IERC20 market,
        address account,
        uint128 pusdDebtDelta,
        uint128 tokenPaybackDelta
    );

    /// @notice Emitted when the spread factor is changed
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param spreadFactorAfterX96 The spread factor after the trade, as a Q160.96
    event SpreadFactorChanged(IERC20 market, int256 spreadFactorAfterX96);

    /// @notice Get the packed state of the given market
    /// @param market The target market contract address, such as the contract address of WETH
    function packedStates(IERC20 market) external view returns (PackedState memory);

    /// @notice Get the remaining protocol fee of the given market
    /// @param market The target market contract address, such as the contract address of WETH
    function protocolFees(IERC20 market) external view returns (uint128);

    /// @notice Get the token balance of the given market
    /// @param market The target market contract address, such as the contract address of WETH
    function tokenBalances(IERC20 market) external view returns (uint128);

    /// @notice Collect the protocol fee of the given market
    /// @dev This function can be called without authorization
    /// @param market The target market contract address, such as the contract address of WETH
    function collectProtocolFee(IERC20 market) external;

    /// @notice Get the information of global stability fund
    /// @param market The target market contract address, such as the contract address of WETH
    function globalStabilityFunds(IERC20 market) external view returns (uint256);

    /// @notice `Gov` uses the stability fund
    /// @dev The call will fail if the caller is not the `Gov` or the stability fund is insufficient
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param receiver The address to receive the stability fund
    /// @param stabilityFundDelta The amount of stability fund to be used
    function govUseStabilityFund(IERC20 market, address receiver, uint128 stabilityFundDelta) external;

    /// @notice Repay the liquidity buffer debt of the given market
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param account The address for debt repayment
    /// @param receiver The address to receive the payback token
    /// @return receiveAmount The amount of payback token received
    function repayLiquidityBufferDebt(
        IERC20 market,
        address account,
        address receiver
    ) external returns (uint128 receiveAmount);

    /// @notice Get the liquidity buffer module of the given market
    /// @param market The target market contract address, such as the contract address of WETH
    /// @return liquidityBufferModule The liquidity buffer module data
    function liquidityBufferModules(
        IERC20 market
    ) external view returns (LiquidityBufferModule memory liquidityBufferModule);
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {Side} from "../../types/Side.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @notice Interface for managing market positions.
/// @dev The market position is the core component of the protocol, which stores the information of
/// all trader's positions.
interface IMarketPosition {
    struct Position {
        /// @notice The margin of the position
        uint96 margin;
        /// @notice The size of the position
        uint96 size;
        /// @notice The entry price of the position
        uint64 entryPrice;
    }

    /// @notice Emitted when the position is increased
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param account The owner of the position
    /// @param marginDelta The increased margin
    /// @param marginAfter The adjusted margin
    /// @param sizeDelta The increased size
    /// @param indexPrice The index price at which the position is increased.
    /// If only adding margin, it will be 0
    /// @param entryPriceAfter The adjusted entry price of the position
    /// @param tradingFee The trading fee paid by the position
    /// @param spread The spread incurred by the position
    event PositionIncreased(
        IERC20 indexed market,
        address indexed account,
        uint96 marginDelta,
        uint96 marginAfter,
        uint96 sizeDelta,
        uint64 indexPrice,
        uint64 entryPriceAfter,
        uint96 tradingFee,
        uint96 spread
    );

    /// @notice Emitted when the position is decreased
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param account The owner of the position
    /// @param marginDelta The decreased margin
    /// @param marginAfter The adjusted margin
    /// @param sizeDelta The decreased size
    /// @param indexPrice The index price at which the position is decreased
    /// @param realizedPnL The realized PnL
    /// @param tradingFee The trading fee paid by the position
    /// @param spread The spread incurred by the position
    /// @param receiver The address that receives the margin
    event PositionDecreased(
        IERC20 indexed market,
        address indexed account,
        uint96 marginDelta,
        uint96 marginAfter,
        uint96 sizeDelta,
        uint64 indexPrice,
        int256 realizedPnL,
        uint96 tradingFee,
        uint96 spread,
        address receiver
    );

    /// @notice Emitted when a position is liquidated
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param liquidator The address that executes the liquidation of the position
    /// @param account The owner of the position
    /// @param sizeDelta The liquidated size
    /// @param indexPrice The index price at which the position is liquidated
    /// @param liquidationPrice The liquidation price of the position
    /// @param tradingFee The trading fee paid by the position
    /// @param liquidationFee The liquidation fee paid by the position
    /// @param liquidationExecutionFee The liquidation execution fee paid by the position
    /// @param feeReceiver The address that receives the liquidation execution fee
    event PositionLiquidated(
        IERC20 indexed market,
        address indexed liquidator,
        address indexed account,
        uint96 sizeDelta,
        uint64 indexPrice,
        uint64 liquidationPrice,
        uint96 tradingFee,
        uint96 liquidationFee,
        uint64 liquidationExecutionFee,
        address feeReceiver
    );

    /// @notice Get the information of a long position
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param account The owner of the position
    function longPositions(IERC20 market, address account) external view returns (Position memory);

    /// @notice Increase the margin or size of a position
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param account The owner of the position
    /// @param sizeDelta The increase in size, which can be 0
    /// @return spread The spread incurred by the position
    function increasePosition(IERC20 market, address account, uint96 sizeDelta) external returns (uint96 spread);

    /// @notice Decrease the margin or size of a position
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param account The owner of the position
    /// @param marginDelta The decrease in margin, which can be 0. If the position size becomes zero after
    /// the decrease, the marginDelta will be ignored, and all remaining margin will be returned
    /// @param sizeDelta The decrease in size, which can be 0
    /// @param receiver The address to receive the margin
    /// @return spread The spread incurred by the position
    /// @return actualMarginDelta The actual decrease in margin
    function decreasePosition(
        IERC20 market,
        address account,
        uint96 marginDelta,
        uint96 sizeDelta,
        address receiver
    ) external returns (uint96 spread, uint96 actualMarginDelta);

    /// @notice Liquidate a position
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param account The owner of the position
    /// @param feeReceiver The address that receives the liquidation execution fee
    function liquidatePosition(IERC20 market, address account, address feeReceiver) external;
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @notice Peg Stability Module interface
interface IPSM {
    struct CollateralState {
        uint120 cap;
        uint8 decimals;
        uint128 balance;
    }

    /// @notice Emitted when the collateral cap is updated
    event PSMCollateralUpdated(IERC20 collateral, uint120 cap);

    /// @notice Emit when PUSD is minted through the PSM module
    /// @param collateral The collateral token
    /// @param receiver Address to receive PUSD
    /// @param payAmount The amount of collateral paid
    /// @param receiveAmount The amount of PUSD minted
    event PSMMinted(IERC20 indexed collateral, address indexed receiver, uint96 payAmount, uint64 receiveAmount);

    /// @notice Emitted when PUSD is burned through the PSM module
    /// @param collateral The collateral token
    /// @param receiver Address to receive collateral
    /// @param payAmount The amount of PUSD burned
    /// @param receiveAmount The amount of collateral received
    event PSMBurned(IERC20 indexed collateral, address indexed receiver, uint64 payAmount, uint96 receiveAmount);

    /// @notice Invalid collateral token
    error InvalidCollateral();

    /// @notice Invalid collateral decimals
    error InvalidCollateralDecimals(uint8 decimals);

    /// @notice The PSM balance is insufficient
    error InsufficientPSMBalance(uint96 receiveAmount, uint128 balance);

    /// @notice Get the collateral state
    function psmCollateralStates(IERC20 collateral) external view returns (CollateralState memory);

    /// @notice Update the collateral cap
    /// @param collateral The collateral token
    /// @param cap The new cap
    function updatePSMCollateralCap(IERC20 collateral, uint120 cap) external;

    /// @notice Mint PUSD
    /// @param collateral The collateral token
    /// @param receiver Address to receive PUSD
    /// @return receiveAmount The amount of PUSD minted
    function psmMintPUSD(IERC20 collateral, address receiver) external returns (uint64 receiveAmount);

    /// @notice Burn PUSD
    /// @param collateral The collateral token
    /// @param receiver Address to receive collateral
    /// @return receiveAmount The amount of collateral received
    function psmBurnPUSD(IERC20 collateral, address receiver) external returns (uint96 receiveAmount);
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IPUSD is IERC20 {
    function mint(address to, uint256 value) external;

    function burn(uint256 value) external;
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "./IPUSD.sol";
import "./IPUSDManagerCallback.sol";

/// @notice Interface for managing the minting and burning of PUSD.
interface IPUSDManager {
    struct GlobalPUSDPosition {
        /// @notice The total PUSD supply of the current market
        uint64 totalSupply;
        /// @notice The size of the position
        uint128 size;
        /// @notice The entry price of the position
        uint64 entryPrice;
    }

    /// @notice Emitted when PUSD is deployed
    event PUSDDeployed(IPUSD indexed pusd);

    /// @notice Emitted when the PUSD position is increased
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param receiver Address to receive PUSD
    /// @param sizeDelta The size of the position to increase
    /// @param indexPrice The index price at which the position is increased
    /// @param entryPriceAfter The adjusted entry price of the position
    /// @param payAmount The amount of token to pay
    /// @param receiveAmount The amount of PUSD to mint
    /// @param tradingFee The amount of trading fee to pay
    /// @param spread The spread incurred by the position
    event PUSDPositionIncreased(
        IERC20 indexed market,
        address indexed receiver,
        uint96 sizeDelta,
        uint64 indexPrice,
        uint64 entryPriceAfter,
        uint96 payAmount,
        uint64 receiveAmount,
        uint96 tradingFee,
        uint96 spread
    );

    /// @notice Emitted when the PUSD position is decreased
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param receiver Address to receive token
    /// @param sizeDelta The size of the position to decrease
    /// @param indexPrice The index price at which the position is decreased
    /// @param payAmount The amount of PUSD to burn
    /// @param receiveAmount The amount of token to receive
    /// @param realizedPnL The realized profit and loss of the position
    /// @param tradingFee The amount of trading fee to pay
    /// @param spread The spread incurred by the position
    event PUSDPositionDecreased(
        IERC20 indexed market,
        address indexed receiver,
        uint96 sizeDelta,
        uint64 indexPrice,
        uint64 payAmount,
        uint96 receiveAmount,
        int256 realizedPnL,
        uint96 tradingFee,
        uint96 spread
    );

    /// @notice Get the global PUSD position of the given market
    /// @param market The target market contract address, such as the contract address of WETH
    function globalPUSDPositions(IERC20 market) external view returns (GlobalPUSDPosition memory);

    /// @notice Mint PUSD
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param amount When `exactIn` is true, it is the amount of token to pay,
    /// otherwise, it is the amount of PUSD to mint
    /// @param callback Address to callback after minting
    /// @param data Any data to be passed to the callback
    /// @param receiver Address to receive PUSD
    /// @return payAmount The amount of token to pay
    /// @return receiveAmount The amount of PUSD to receive
    function mintPUSD(
        IERC20 market,
        bool exactIn,
        uint96 amount,
        IPUSDManagerCallback callback,
        bytes calldata data,
        address receiver
    ) external returns (uint96 payAmount, uint64 receiveAmount);

    /// @notice Burn PUSD
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param amount When `exactIn` is true, it is the amount of PUSD to burn,
    /// otherwise, it is the amount of token to receive
    /// @param callback Address to callback after burning
    /// @param data Any data to be passed to the callback
    /// @param receiver Address to receive token
    /// @return payAmount The amount of PUSD to pay
    /// @return receiveAmount The amount of token to receive
    function burnPUSD(
        IERC20 market,
        bool exactIn,
        uint96 amount,
        IPUSDManagerCallback callback,
        bytes calldata data,
        address receiver
    ) external returns (uint64 payAmount, uint96 receiveAmount);
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title Callback for IPUSDManager.mint and IPUSDManager.burn
interface IPUSDManagerCallback {
    /// @notice Called after executing a mint or burn operation
    /// @dev In this implementation, you are required to pay the amount of `payAmount` to the caller.
    /// @dev In this implementation, you MUST check that the caller is IPUSDManager.
    /// @param payToken The token to pay
    /// @param payAmount The amount of token to pay
    /// @param receiveAmount The amount of token to receive
    /// @param data The data passed to the original `mint` or `burn` function
    function PUSDManagerCallback(IERC20 payToken, uint96 payAmount, uint96 receiveAmount, bytes calldata data) external;
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.8.26;

contract Governable {
    address private _gov;
    address private _pendingGov;

    event ChangeGovStarted(address indexed previousGov, address indexed newGov);
    event GovChanged(address indexed previousGov, address indexed newGov);

    error Forbidden();

    modifier onlyGov() {
        _onlyGov();
        _;
    }

    constructor(address _initialGov) {
        _changeGov(_initialGov);
    }

    function gov() public view virtual returns (address) {
        return _gov;
    }

    function pendingGov() public view virtual returns (address) {
        return _pendingGov;
    }

    function changeGov(address _newGov) public virtual onlyGov {
        _pendingGov = _newGov;
        emit ChangeGovStarted(_gov, _newGov);
    }

    function acceptGov() public virtual {
        if (msg.sender != _pendingGov) revert Forbidden();

        delete _pendingGov;
        _changeGov(msg.sender);
    }

    function _changeGov(address _newGov) internal virtual {
        address previousGov = _gov;
        _gov = _newGov;
        emit GovChanged(previousGov, _newGov);
    }

    function _onlyGov() internal view {
        if (msg.sender != _gov) revert Forbidden();
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "./Governable.sol";

abstract contract GovernableProxy {
    Governable private _impl;

    error Forbidden();

    modifier onlyGov() {
        _onlyGov();
        _;
    }

    constructor(Governable _newImpl) {
        _impl = _newImpl;
    }

    function _changeImpl(Governable _newGov) public virtual onlyGov {
        _impl = _newGov;
    }

    function gov() public view virtual returns (address) {
        return _impl.gov();
    }

    function _onlyGov() internal view {
        if (msg.sender != _impl.gov()) revert Forbidden();
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

abstract contract GovernableUpgradeable is UUPSUpgradeable {
    /// @custom:storage-location erc7201:Purecash.storage.GovernableUpgradeable
    struct GovStorage {
        address gov;
        address pendingGov;
    }

    // keccak256(abi.encode(uint256(keccak256("Purecash.storage.GovernableUpgradeable")) - 1))
    // & ~bytes32(uint256(0xff))
    bytes32 private constant GOVERNABLE_UPGRADEABLE_STORAGE =
        0x71907d27e7f56436d282b33232af729b796faa4dde12f80868ee08b9116c5200;

    event ChangeGovStarted(address indexed previousGov, address indexed newGov);
    event GovChanged(address indexed previousGov, address indexed newGov);

    error Forbidden();

    modifier onlyGov() {
        _onlyGov();
        _;
    }

    function __Governable_init(address _initialGov) internal onlyInitializing {
        UUPSUpgradeable.__UUPSUpgradeable_init();
        __Governable_init_unchained(_initialGov);
    }

    function __Governable_init_unchained(address _initialGov) internal onlyInitializing {
        _changeGov(_initialGov);
    }

    function gov() public view virtual returns (address) {
        return _governableStorage().gov;
    }

    function pendingGov() public view virtual returns (address) {
        return _governableStorage().pendingGov;
    }

    function changeGov(address _newGov) public virtual onlyGov {
        GovStorage storage $ = _governableStorage();
        $.pendingGov = _newGov;
        emit ChangeGovStarted($.gov, _newGov);
    }

    function acceptGov() public virtual {
        GovStorage storage $ = _governableStorage();
        if (msg.sender != $.pendingGov) revert Forbidden();

        delete $.pendingGov;
        _changeGov(msg.sender);
    }

    function _changeGov(address _newGov) internal virtual {
        GovStorage storage $ = _governableStorage();
        address previousGov = $.gov;
        $.gov = _newGov;
        emit GovChanged(previousGov, _newGov);
    }

    function _onlyGov() internal view {
        if (msg.sender != _governableStorage().gov) revert Forbidden();
    }

    function _governableStorage() private pure returns (GovStorage storage $) {
        // prettier-ignore
        assembly { $.slot := GOVERNABLE_UPGRADEABLE_STORAGE }
    }
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.8.26;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/governance/TimelockController.sol";
import "./Governable.sol";

contract PurecashTimelockController is TimelockController {
    using Address for address;

    constructor(
        uint256 minDelay,
        address[] memory proposers,
        address[] memory executors,
        address admin
    ) TimelockController(minDelay, proposers, executors, admin) {}

    function acceptGov(Governable target) public onlyRole(EXECUTOR_ROLE) {
        target.acceptGov();
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "./Constants.sol";
import "../core/interfaces/IConfigurable.sol";

library ConfigurableUtil {
    function enableMarket(
        mapping(IERC20 => IConfigurable.MarketConfig) storage _self,
        IERC20 _market,
        IConfigurable.MarketConfig calldata _cfg
    ) public {
        if (_self[_market].liquidityCap > 0) revert IConfigurable.MarketAlreadyEnabled(_market);

        _validateConfig(_cfg);

        _self[_market] = _cfg;

        emit IConfigurable.MarketConfigEnabled(_market, _cfg);
    }

    function updateMarketConfig(
        mapping(IERC20 => IConfigurable.MarketConfig) storage _self,
        IERC20 _market,
        IConfigurable.MarketConfig calldata _newCfg
    ) public {
        if (_self[_market].liquidityCap == 0) revert IConfigurable.MarketNotEnabled(_market);

        _validateConfig(_newCfg);

        _self[_market] = _newCfg;

        emit IConfigurable.MarketConfigChanged(_market, _newCfg);
    }

    function _validateConfig(IConfigurable.MarketConfig calldata _newCfg) private pure {
        if (_newCfg.maxLeveragePerPosition == 0)
            revert IConfigurable.InvalidMaxLeveragePerPosition(_newCfg.maxLeveragePerPosition);

        if (_newCfg.liquidationFeeRatePerPosition > Constants.BASIS_POINTS_DIVISOR)
            revert IConfigurable.InvalidLiquidationFeeRatePerPosition(_newCfg.liquidationFeeRatePerPosition);

        if (_newCfg.maxSizeRatePerPosition == 0 || _newCfg.maxSizeRatePerPosition > Constants.BASIS_POINTS_DIVISOR)
            revert IConfigurable.InvalidMaxSizeRatePerPosition(_newCfg.maxSizeRatePerPosition);

        if (_newCfg.openPositionThreshold > Constants.BASIS_POINTS_DIVISOR)
            revert IConfigurable.InvalidOpenPositionThreshold(_newCfg.openPositionThreshold);

        if (_newCfg.liquidityCap == 0) revert IConfigurable.InvalidLiquidityCap(_newCfg.liquidityCap);

        if (_newCfg.decimals == 0 || _newCfg.decimals > 18) revert IConfigurable.InvalidDecimals(_newCfg.decimals);

        if (_newCfg.tradingFeeRate > Constants.BASIS_POINTS_DIVISOR)
            revert IConfigurable.InvalidTradingFeeRate(_newCfg.tradingFeeRate);

        if (_newCfg.protocolFeeRate > Constants.BASIS_POINTS_DIVISOR)
            revert IConfigurable.InvalidProtocolFeeRate(_newCfg.protocolFeeRate);

        if (_newCfg.maxFeeRate > Constants.BASIS_POINTS_DIVISOR)
            revert IConfigurable.InvalidMaxFeeRate(_newCfg.maxFeeRate);

        unchecked {
            if (uint64(_newCfg.maxFeeRate) + _newCfg.tradingFeeRate > Constants.BASIS_POINTS_DIVISOR)
                revert IConfigurable.InvalidMaxFeeRate(_newCfg.maxFeeRate);
        }

        if (_newCfg.minMintingRate > Constants.BASIS_POINTS_DIVISOR)
            revert IConfigurable.InvalidMinMintingRate(_newCfg.minMintingRate);

        if (_newCfg.maxBurningRate > Constants.BASIS_POINTS_DIVISOR)
            revert IConfigurable.InvalidMaxBurningRate(_newCfg.maxBurningRate);

        if (_newCfg.riskFreeTime == 0) revert IConfigurable.ZeroRiskFreeTime();

        if (_newCfg.liquidityScale == 0) revert IConfigurable.ZeroLiquidityScale();

        if (_newCfg.stableCoinSupplyCap == 0)
            revert IConfigurable.InvalidStableCoinSupplyCap(_newCfg.stableCoinSupplyCap);
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

library Constants {
    uint24 internal constant BASIS_POINTS_DIVISOR = 10_000_000;

    uint8 internal constant DECIMALS_6 = 6;
    uint8 internal constant PRICE_DECIMALS = 10;
    uint64 internal constant PRICE_1 = uint64(10 ** PRICE_DECIMALS);

    uint256 internal constant Q64 = 1 << 64;
    uint256 internal constant Q96 = 1 << 96;
    uint256 internal constant Q72 = 1 << 72;
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "../misc/interfaces/IReader.sol";
import "../core/MarketManagerUpgradeable.sol";

library LiquidityReader {
    using SafeCast for *;

    function calcLPTPrice(
        IReader.ReaderState storage _readerState,
        IERC20 _market,
        uint64 _indexPrice
    ) public returns (uint256 totalSupply_, uint128 liquidity, uint64 price) {
        IMarketManager marketManager = _readerState.marketManager;
        if (!marketManager.isEnabledMarket(_market)) revert IConfigurable.MarketNotEnabled(_market);

        totalSupply_ = ILPToken(LiquidityUtil.computeLPTokenAddress(_market, address(marketManager))).totalSupply();
        if (totalSupply_ == 0) return (0, 0, Constants.PRICE_1);

        IReader.MockState storage mockState = _readerState.mockState;
        IMarketManager.State storage state = mockState.state;
        state.packedState = marketManager.packedStates(_market);
        mockState.marketConfig = marketManager.marketConfigs(_market);
        IConfigurable.MarketConfig storage marketConfig = mockState.marketConfig;

        IMarketManager.PackedState storage packedState = state.packedState;
        liquidity = packedState.lpLiquidity;
        int256 pnl = PositionUtil.calcUnrealizedPnL(
            SHORT,
            packedState.lpNetSize,
            packedState.lpEntryPrice,
            _indexPrice
        );
        unchecked {
            uint256 liquidityWithPnL = (pnl + int256(uint256(liquidity))).toUint256().toUint128();
            if (marketConfig.decimals >= Constants.DECIMALS_6) {
                price = Math
                    .mulDiv(
                        liquidityWithPnL,
                        _indexPrice,
                        totalSupply_ * (10 ** (marketConfig.decimals - Constants.DECIMALS_6))
                    )
                    .toUint64();
            } else {
                price = Math
                    .mulDiv(
                        liquidityWithPnL * (10 ** (Constants.DECIMALS_6 - marketConfig.decimals)),
                        _indexPrice,
                        totalSupply_
                    )
                    .toUint64();
            }
        }

        delete _readerState.mockState;
    }

    function quoteBurnPUSDToMintLPT(
        IReader.ReaderState storage _readerState,
        IERC20 _market,
        uint96 _amountIn,
        uint64 _indexPrice
    ) public returns (uint96 burnPUSDReceiveAmount, uint64 mintLPTTokenValue) {
        IMarketManager marketManager = _readerState.marketManager;
        if (!marketManager.isEnabledMarket(_market)) revert IConfigurable.MarketNotEnabled(_market);

        IReader.MockState storage mockState = _readerState.mockState;
        IMarketManager.State storage state = mockState.state;
        mockState.marketConfig = marketManager.marketConfigs(_market);
        IConfigurable.MarketConfig storage marketConfig = mockState.marketConfig;

        IMarketManager.PackedState memory packedState = marketManager.packedStates(_market);
        state.packedState = packedState;
        IPUSDManager.GlobalPUSDPosition memory pusdPosition = marketManager.globalPUSDPositions(_market);
        state.globalPUSDPosition = pusdPosition;
        state.tokenBalance = marketManager.tokenBalances(_market);

        PUSD pusd = PUSDManagerUtil.deployPUSD();
        pusd.mint(address(this), pusdPosition.totalSupply - _amountIn); // for mock

        (, burnPUSDReceiveAmount) = PUSDManagerUtil.burn(
            state,
            marketConfig,
            PUSDManagerUtil.BurnParam({
                market: IERC20(address(this)), // for mock
                exactIn: true,
                amount: _amountIn,
                callback: IPUSDManagerCallback(address(this)), // for mock
                indexPrice: _indexPrice,
                receiver: address(this)
            }),
            bytes("")
        );

        uint256 totalSupply = ILPToken(LiquidityUtil.computeLPTokenAddress(_market, address(marketManager)))
            .totalSupply();
        LPToken token = LiquidityUtil.deployLPToken(IERC20(address(this)), "Mock");
        token.mint(address(this), totalSupply); // for mock

        mintLPTTokenValue = LiquidityUtil.mintLPT(
            state,
            marketConfig,
            LiquidityUtil.MintParam({
                market: IERC20(address(this)), // for mock
                account: address(this),
                receiver: address(this),
                liquidity: burnPUSDReceiveAmount,
                indexPrice: _indexPrice
            })
        );

        delete _readerState.mockState;
    }

    function quoteBurnLPTToMintPUSD(
        IReader.ReaderState storage _readerState,
        IERC20 _market,
        uint64 _amountIn,
        uint64 _indexPrice
    ) public returns (uint96 burnLPTReceiveAmount, uint64 mintPUSDTokenValue) {
        IMarketManager marketManager = _readerState.marketManager;
        if (!marketManager.isEnabledMarket(_market)) revert IConfigurable.MarketNotEnabled(_market);

        IReader.MockState storage mockState = _readerState.mockState;
        IMarketManager.State storage state = mockState.state;
        mockState.marketConfig = marketManager.marketConfigs(_market);
        IConfigurable.MarketConfig storage marketConfig = mockState.marketConfig;

        state.packedState = marketManager.packedStates(_market);
        IPUSDManager.GlobalPUSDPosition memory pusdPosition = marketManager.globalPUSDPositions(_market);
        state.globalPUSDPosition = marketManager.globalPUSDPositions(_market);
        state.tokenBalance = marketManager.tokenBalances(_market);

        uint256 totalSupply = ILPToken(LiquidityUtil.computeLPTokenAddress(_market, address(marketManager)))
            .totalSupply();
        LPToken token = LiquidityUtil.deployLPToken(IERC20(address(this)), "Mock");
        token.mint(address(this), totalSupply); // for mock

        burnLPTReceiveAmount = LiquidityUtil.burnLPT(
            state,
            LiquidityUtil.BurnParam({
                market: IERC20(address(this)), // for mock
                account: address(this),
                receiver: address(this),
                tokenValue: _amountIn,
                indexPrice: _indexPrice
            })
        );
        delete mockState.totalSupply; // reset totalSupply

        PUSD pusd = PUSDManagerUtil.deployPUSD();
        pusd.mint(address(this), pusdPosition.totalSupply); // for mock
        (, mintPUSDTokenValue) = PUSDManagerUtil.mint(
            state,
            marketConfig,
            PUSDManagerUtil.MintParam({
                market: IERC20(address(this)), // for mock
                exactIn: true,
                amount: burnLPTReceiveAmount,
                callback: IPUSDManagerCallback(address(this)), // for mock
                indexPrice: _indexPrice,
                receiver: address(this)
            }),
            msg.data // for mock
        );

        delete _readerState.mockState;
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "../core/LPToken.sol";
import "./MarketUtil.sol";
import "./PositionUtil.sol";
import {SHORT} from "../types/Side.sol";
import {M as Math} from "./Math.sol";
import "./UnsafeMath.sol";
import "@openzeppelin/contracts/utils/Create2.sol";

/// @notice Utility library for managing liquidity
library LiquidityUtil {
    using SafeCast for *;
    using UnsafeMath for *;

    bytes32 internal constant LP_TOKEN_INIT_CODE_HASH =
        0xf7ee18f8779e8a47b9fee2bf37816783fe8615833733cf03cc48cd8fc3e3128b;

    struct MintParam {
        IERC20 market;
        address account;
        address receiver;
        uint96 liquidity;
        uint64 indexPrice;
    }

    struct BurnParam {
        IERC20 market;
        address account;
        address receiver;
        uint64 tokenValue;
        uint64 indexPrice;
    }

    function deployLPToken(IERC20 _market, string calldata _tokenSymbol) public returns (LPToken token) {
        token = new LPToken{salt: bytes32(uint256(uint160(address(_market))))}();
        token.initialize(_market, _tokenSymbol);
    }

    function computeLPTokenAddress(IERC20 _market) internal view returns (address) {
        return computeLPTokenAddress(_market, address(this));
    }

    function computeLPTokenAddress(IERC20 _market, address _deployer) internal pure returns (address) {
        return Create2.computeAddress(bytes32(uint256(uint160(address(_market)))), LP_TOKEN_INIT_CODE_HASH, _deployer);
    }

    function mintLPT(
        IMarketManager.State storage _state,
        IConfigurable.MarketConfig storage _cfg,
        MintParam memory _param
    ) public returns (uint64 tokenValue) {
        unchecked {
            IMarketManager.PackedState storage packedState = _state.packedState;
            uint128 liquidityBefore = packedState.lpLiquidity;
            uint256 liquidityAfter = uint256(liquidityBefore) + _param.liquidity;
            if (liquidityAfter > _cfg.liquidityCap)
                revert IMarketErrors.LiquidityCapExceeded(liquidityBefore, _param.liquidity, _cfg.liquidityCap);
            packedState.lpLiquidity = uint128(liquidityAfter);

            ILPToken token = ILPToken(computeLPTokenAddress(_param.market));
            uint256 totalSupply = token.totalSupply();
            if (totalSupply == 0) {
                tokenValue = PositionUtil.calcDecimals6TokenValue(
                    _param.liquidity,
                    _param.indexPrice,
                    _cfg.decimals,
                    Math.Rounding.Down
                );
            } else {
                int256 pnl = PositionUtil.calcUnrealizedPnL(
                    SHORT,
                    packedState.lpNetSize,
                    packedState.lpEntryPrice,
                    _param.indexPrice
                );
                tokenValue = Math
                    .mulDiv(_param.liquidity, totalSupply, (pnl + int256(uint256(liquidityBefore))).toUint256())
                    .toUint64();
            }

            // mint LPT
            token.mint(_param.receiver, tokenValue);
        }
        emit IMarketLiquidity.LPTMinted(_param.market, _param.account, _param.receiver, _param.liquidity, tokenValue);
    }

    function burnLPT(IMarketManager.State storage _state, BurnParam memory _param) public returns (uint96 liquidity) {
        IMarketManager.PackedState storage packedState = _state.packedState;
        (uint128 liquidityBefore, uint128 netSize) = (packedState.lpLiquidity, packedState.lpNetSize);
        int256 pnl = PositionUtil.calcUnrealizedPnL(SHORT, netSize, packedState.lpEntryPrice, _param.indexPrice);
        ILPToken token = ILPToken(computeLPTokenAddress(_param.market));
        unchecked {
            liquidity = Math
                .mulDiv((pnl + int256(uint256(liquidityBefore))).toUint256(), _param.tokenValue, token.totalSupply())
                .toUint96();
            if (uint256(netSize) + liquidity > liquidityBefore) revert IMarketErrors.BalanceRateCapExceeded();

            packedState.lpLiquidity = liquidityBefore - liquidity;
        }
        // burn LPT
        token.burn(_param.tokenValue);

        emit IMarketLiquidity.LPTBurned(_param.market, _param.account, _param.receiver, liquidity, _param.tokenValue);
    }

    function settlePosition(
        IMarketManager.PackedState storage _packedState,
        IERC20 _market,
        Side _side,
        uint64 _indexPrice,
        uint96 _sizeDelta
    ) internal {
        (uint128 netSize, uint64 entryPrice) = (_packedState.lpNetSize, _packedState.lpEntryPrice);
        unchecked {
            if (_side.isLong()) {
                uint64 entryPriceAfter = PositionUtil.calcNextEntryPrice(
                    SHORT,
                    netSize,
                    entryPrice,
                    _sizeDelta,
                    _indexPrice
                );
                _packedState.lpNetSize = netSize + _sizeDelta;
                _packedState.lpEntryPrice = entryPriceAfter;
                emit IMarketLiquidity.GlobalLiquiditySettled(_market, int256(uint256(_sizeDelta)), 0, entryPriceAfter);
            } else {
                int256 realizedPnL = PositionUtil.calcUnrealizedPnL(SHORT, _sizeDelta, entryPrice, _indexPrice);
                _packedState.lpLiquidity = (int256(uint256(_packedState.lpLiquidity)) + realizedPnL)
                    .toUint256()
                    .toUint128();
                _packedState.lpNetSize = netSize - _sizeDelta;

                emit IMarketLiquidity.GlobalLiquiditySettled(
                    _market,
                    -int256(uint256(_sizeDelta)),
                    realizedPnL,
                    entryPrice
                );
            }
        }
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "./Constants.sol";
import "../core/interfaces/IMarketManager.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";
import {SafeERC20 as OneInchSafeERC20} from "@1inch/solidity-utils/contracts/libraries/SafeERC20.sol";

/// @notice Utility library for market manager
library MarketUtil {
    using SafeCast for *;

    /// @notice Transfer ETH from the contract to the receiver
    /// @param _receiver The address of the receiver
    /// @param _amount The amount of ETH to transfer
    /// @param _executionGasLimit The gas limit for the transfer
    function transferOutETH(address payable _receiver, uint256 _amount, uint256 _executionGasLimit) internal {
        if (_amount == 0) return;

        if (address(this).balance < _amount) revert IMarketErrors.InsufficientBalance(address(this).balance, _amount);

        (bool success, ) = _receiver.call{value: _amount, gas: _executionGasLimit}("");
        if (!success) revert IMarketErrors.FailedTransferETH();
    }

    /// @notice Check if the account is a deployed contract
    /// @param _account The address of the account
    /// @return true if the account is a deployed contract, false otherwise
    function isDeployedContract(address _account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        // prettier-ignore
        assembly { size := extcodesize(_account) }
        return size > 0;
    }

    /// @notice `Gov` uses the stability fund
    /// @param _state The state of the market
    /// @param _market The target market contract address, such as the contract address of WETH
    /// @param _stabilityFundDelta The amount of stability fund to be used
    /// @param _receiver The address to receive the stability fund
    function govUseStabilityFund(
        IMarketManager.State storage _state,
        IERC20 _market,
        uint128 _stabilityFundDelta,
        address _receiver
    ) public {
        _state.globalStabilityFund -= _stabilityFundDelta;
        emit IMarketManager.GlobalStabilityFundGovUsed(_market, _receiver, _stabilityFundDelta);
    }

    /// @notice Validate the leverage of a position
    /// @param _margin The margin of the position
    /// @param _size The size of the position
    /// @param _maxLeverage The maximum acceptable leverage of the position
    function validateLeverage(uint128 _margin, uint128 _size, uint8 _maxLeverage) internal pure {
        unchecked {
            if (uint256(_margin) * _maxLeverage < _size)
                revert IMarketErrors.LeverageTooHigh(_margin, _size, _maxLeverage);
        }
    }

    function safePermit(IERC20 _token, address _spender, bytes calldata _data) internal {
        if (_data.length == 0) return;
        OneInchSafeERC20.safePermit(_token, msg.sender, _spender, _data);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Math as _math} from "@openzeppelin/contracts/utils/math/Math.sol";

/// @title Math library
/// @dev Derived from OpenZeppelin's Math library. To avoid conflicts with OpenZeppelin's Math,
/// it has been renamed to `M` here. Import it using the following statement:
///      import {M as Math} from "path/to/Math.sol";
library M {
    enum Rounding {
        Up,
        Down
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /// @notice Calculate `a / b` with rounding up
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // Guarantee the same behavior as in a regular Solidity division
        if (b == 0) return a / b;

        // prettier-ignore
        unchecked { return a == 0 ? 0 : (a - 1) / b + 1; }
    }

    /// @notice Calculate `x * y / denominator` with rounding down
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256) {
        return _math.mulDiv(x, y, denominator);
    }

    /// @notice Calculate `x * y / denominator` with rounding up
    function mulDivUp(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256) {
        return _math.mulDiv(x, y, denominator, _math.Rounding.Ceil);
    }

    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        return _math.mulDiv(x, y, denominator, rounding == Rounding.Up ? _math.Rounding.Ceil : _math.Rounding.Floor);
    }

    /// @notice Calculate `x * y / denominator` with rounding down and up
    /// @return result Result with rounding down
    /// @return resultUp Result with rounding up
    function mulDiv2(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result, uint256 resultUp) {
        result = _math.mulDiv(x, y, denominator);
        resultUp = result;
        if (mulmod(x, y, denominator) > 0) resultUp += 1;
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "./SpreadUtil.sol";
import "./PositionUtil.sol";
import "./LiquidityUtil.sol";
import "./UnsafeMath.sol";
import "./SpreadUtil.sol";
import "../core/PUSD.sol";
import "../core/interfaces/IMarketManager.sol";
import {LONG, SHORT} from "../types/Side.sol";
import "@openzeppelin/contracts/utils/Create2.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

library PUSDManagerUtil {
    using SafeCast for *;
    using SafeERC20 for IERC20;
    using UnsafeMath for *;

    bytes32 internal constant PUSD_SALT = keccak256("Pure USD");
    bytes32 internal constant PUSD_INIT_CODE_HASH = 0x833a3129a7c49096ba2bc346ab64e2bbec674f4181bf8e6dedfa83aea7fb0fec;

    struct MintParam {
        IERC20 market;
        bool exactIn;
        uint96 amount;
        IPUSDManagerCallback callback;
        uint64 indexPrice;
        address receiver;
    }

    struct BurnParam {
        IERC20 market;
        bool exactIn;
        uint96 amount;
        IPUSDManagerCallback callback;
        uint64 indexPrice;
        address receiver;
    }

    struct LiquidityBufferModuleBurnParam {
        IERC20 market;
        address account;
        uint96 sizeDelta;
        uint64 indexPrice;
    }

    struct CalcBurnPUSDInputAmountParam {
        uint256 spreadX96;
        uint64 entryPrice;
        uint64 indexPrice;
        uint24 tradingFeeRate;
        uint96 outputAmount;
    }

    function deployPUSD() public returns (PUSD pusd) {
        pusd = new PUSD{salt: PUSD_SALT}();
    }

    function computePUSDAddress() internal view returns (address) {
        return computePUSDAddress(address(this));
    }

    function computePUSDAddress(address _deployer) internal pure returns (address) {
        return Create2.computeAddress(PUSD_SALT, PUSD_INIT_CODE_HASH, _deployer);
    }

    function mint(
        IMarketManager.State storage _state,
        IConfigurable.MarketConfig storage _cfg,
        MintParam memory _param,
        bytes calldata _data
    ) internal returns (uint96 payAmount, uint64 receiveAmount) {
        IMarketManager.PackedState storage packedState = _state.packedState;
        (int256 spreadFactorAfterX96, uint256 spreadX96) = SpreadUtil.refreshSpread(
            _cfg,
            SpreadUtil.CalcSpreadParam({
                side: SHORT,
                sizeDelta: 0,
                spreadFactorBeforeX96: packedState.spreadFactorX96,
                lastTradingTimestamp: packedState.lastTradingTimestamp
            })
        );
        uint96 sizeDelta;
        if (_param.exactIn) {
            // size = amount / (1 + spread + tradingFeeRate)
            unchecked {
                uint256 numeratorX96 = (uint256(_param.amount) << 96) * Constants.BASIS_POINTS_DIVISOR;
                uint256 denominatorX96 = (uint256(Constants.BASIS_POINTS_DIVISOR) + _cfg.tradingFeeRate) << 96;
                denominatorX96 += spreadX96 * Constants.BASIS_POINTS_DIVISOR;
                sizeDelta = (numeratorX96 / denominatorX96).toUint96();
            }
            payAmount = _param.amount;
            receiveAmount = PositionUtil.calcDecimals6TokenValue(
                sizeDelta,
                _param.indexPrice,
                _cfg.decimals,
                Math.Rounding.Down
            );
        } else {
            receiveAmount = _param.amount.toUint64();
            sizeDelta = PositionUtil.calcMarketTokenValue(_param.amount, _param.indexPrice, _cfg.decimals);
        }
        if (sizeDelta == 0) revert IMarketErrors.InvalidSize();

        IPUSDManager.GlobalPUSDPosition storage position = _state.globalPUSDPosition;
        uint64 totalSupplyAfter = _validateStableCoinSupplyCap(
            _cfg.stableCoinSupplyCap,
            position.totalSupply,
            receiveAmount
        );

        (uint128 lpNetSize, uint128 lpLiquidity) = (packedState.lpNetSize, packedState.lpLiquidity);
        if (sizeDelta > lpNetSize) revert IMarketErrors.InsufficientSizeToDecrease(sizeDelta, lpNetSize);

        unchecked {
            uint128 minMintingSizeCap = uint128(
                (uint256(_cfg.minMintingRate) * lpLiquidity) / Constants.BASIS_POINTS_DIVISOR
            );
            if (lpNetSize - sizeDelta < minMintingSizeCap)
                revert IMarketErrors.MinMintingSizeCapNotMet(lpNetSize, sizeDelta, minMintingSizeCap);
        }

        // settle liquidity
        LiquidityUtil.settlePosition(packedState, _param.market, SHORT, _param.indexPrice, sizeDelta);

        uint96 tradingFee = PositionUtil.distributeTradingFee(
            _state,
            PositionUtil.DistributeFeeParam({
                market: _param.market,
                size: sizeDelta,
                entryPrice: _param.indexPrice,
                indexPrice: _param.indexPrice,
                rounding: Math.Rounding.Down,
                tradingFeeRate: _cfg.tradingFeeRate,
                protocolFeeRate: _cfg.protocolFeeRate
            })
        );

        uint96 spread = _param.exactIn
            ? _param.amount.subU96(sizeDelta).subU96(tradingFee)
            : SpreadUtil.calcSpreadAmount(spreadX96, sizeDelta, Math.Rounding.Up);
        PositionUtil.distributeSpread(_state, _param.market, spread);

        if (!_param.exactIn) payAmount = sizeDelta + tradingFee + spread;

        // mint PUSD
        IPUSD(computePUSDAddress()).mint(_param.receiver, receiveAmount);
        // execute callback
        uint256 balanceBefore = _param.market.balanceOf(address(this));
        _param.callback.PUSDManagerCallback(_param.market, payAmount, receiveAmount, _data);
        uint96 actualPayAmount = (_param.market.balanceOf(address(this)) - balanceBefore).toUint96();
        if (actualPayAmount < payAmount) revert IMarketErrors.TooLittlePayAmount(actualPayAmount, payAmount);
        payAmount = actualPayAmount;
        _state.tokenBalance += payAmount;

        uint128 sizeBefore = position.size;
        uint64 entryPriceAfter = PositionUtil.calcNextEntryPrice(
            SHORT,
            sizeBefore,
            position.entryPrice,
            sizeDelta,
            _param.indexPrice
        );

        unchecked {
            position.totalSupply = totalSupplyAfter;
            // Because the short position is always less than or equal to the long position,
            // there will be no overflow
            position.size = sizeBefore + sizeDelta;
            position.entryPrice = entryPriceAfter;
        }

        spreadFactorAfterX96 = SpreadUtil.calcSpreadFactorAfterX96(spreadFactorAfterX96, SHORT, sizeDelta);
        _refreshSpreadFactor(packedState, _param.market, spreadFactorAfterX96);

        emit IPUSDManager.PUSDPositionIncreased(
            _param.market,
            _param.receiver,
            sizeDelta,
            _param.indexPrice,
            entryPriceAfter,
            payAmount,
            receiveAmount,
            tradingFee,
            spread
        );
    }

    function burn(
        IMarketManager.State storage _state,
        IConfigurable.MarketConfig storage _cfg,
        BurnParam memory _param,
        bytes calldata _data
    ) public returns (uint64 payAmount, uint96 receiveAmount) {
        IMarketManager.PackedState storage packedState = _state.packedState;
        (int256 spreadFactorAfterX96, uint256 spreadX96) = SpreadUtil.refreshSpread(
            _cfg,
            SpreadUtil.CalcSpreadParam({
                side: LONG,
                sizeDelta: 0,
                spreadFactorBeforeX96: packedState.spreadFactorX96,
                lastTradingTimestamp: packedState.lastTradingTimestamp
            })
        );

        IPUSDManager.GlobalPUSDPosition storage position = _state.globalPUSDPosition;
        IPUSDManager.GlobalPUSDPosition memory positionCache = position;
        uint96 sizeDelta;
        if (_param.exactIn) {
            if (_param.amount == 0 || _param.amount > positionCache.totalSupply)
                revert IMarketErrors.InvalidAmount(positionCache.totalSupply, _param.amount);

            unchecked {
                sizeDelta = ((uint256(_param.amount) * positionCache.size) / positionCache.totalSupply).toUint96();
            }
            payAmount = uint64(_param.amount);
        } else {
            sizeDelta = calcBurnPUSDSizeDelta(
                CalcBurnPUSDInputAmountParam({
                    spreadX96: spreadX96,
                    entryPrice: positionCache.entryPrice,
                    indexPrice: _param.indexPrice,
                    tradingFeeRate: _cfg.tradingFeeRate,
                    outputAmount: _param.amount
                })
            );
            if (sizeDelta > positionCache.size)
                revert IMarketErrors.InsufficientSizeToDecrease(sizeDelta, positionCache.size);

            receiveAmount = _param.amount;
        }

        validateDecreaseSize(packedState, _cfg.maxBurningRate, sizeDelta);

        // settle liquidity
        LiquidityUtil.settlePosition(packedState, _param.market, LONG, _param.indexPrice, sizeDelta);

        uint96 tradingFee = PositionUtil.distributeTradingFee(
            _state,
            PositionUtil.DistributeFeeParam({
                market: _param.market,
                size: sizeDelta,
                entryPrice: positionCache.entryPrice,
                indexPrice: _param.indexPrice,
                rounding: Math.Rounding.Down,
                tradingFeeRate: _cfg.tradingFeeRate,
                protocolFeeRate: _cfg.protocolFeeRate
            })
        );

        uint96 spread = SpreadUtil.calcSpreadAmount(spreadX96, sizeDelta, Math.Rounding.Down);
        PositionUtil.distributeSpread(_state, _param.market, spread);

        int256 realizedPnL = PositionUtil.calcUnrealizedPnL(
            SHORT,
            sizeDelta,
            positionCache.entryPrice,
            _param.indexPrice
        );

        if (_param.exactIn) {
            unchecked {
                int256 receiveAmountInt = int256(uint256(sizeDelta)) + realizedPnL;
                receiveAmountInt -= int256(uint256(tradingFee) + spread);
                if (receiveAmountInt < 0) revert IMarketErrors.NegativeReceiveAmount(receiveAmountInt);
                receiveAmount = uint256(receiveAmountInt).toUint96();
            }
        } else {
            // the amount of PUSD to burn
            payAmount = PositionUtil.calcDecimals6TokenValue(
                sizeDelta,
                _param.indexPrice,
                _cfg.decimals,
                Math.Rounding.Up
            );
        }

        // First pay the market token
        _state.tokenBalance -= receiveAmount;
        _param.market.safeTransfer(_param.receiver, receiveAmount);

        // Then execute the callback
        IPUSD usd = IPUSD(computePUSDAddress());
        uint256 balanceBefore = usd.balanceOf(address(this));
        _param.callback.PUSDManagerCallback(usd, payAmount, receiveAmount, _data);
        uint96 actualPayAmount = (usd.balanceOf(address(this)) - balanceBefore).toUint96();
        if (actualPayAmount != payAmount) revert IMarketErrors.UnexpectedPayAmount(payAmount, actualPayAmount);
        usd.burn(payAmount);

        // never underflow because of the validation above
        unchecked {
            position.size = positionCache.size - sizeDelta;
            position.totalSupply = positionCache.totalSupply - payAmount;
        }

        spreadFactorAfterX96 = SpreadUtil.calcSpreadFactorAfterX96(spreadFactorAfterX96, LONG, sizeDelta);
        _refreshSpreadFactor(packedState, _param.market, spreadFactorAfterX96);

        emit IPUSDManager.PUSDPositionDecreased(
            _param.market,
            _param.receiver,
            sizeDelta,
            _param.indexPrice,
            payAmount,
            receiveAmount,
            realizedPnL,
            tradingFee,
            spread
        );
    }

    function liquidityBufferModuleBurn(
        IMarketManager.State storage _state,
        IConfigurable.MarketConfig storage _cfg,
        IMarketManager.PackedState storage _packedState,
        LiquidityBufferModuleBurnParam memory _param
    ) internal {
        // settle liquidity
        LiquidityUtil.settlePosition(_packedState, _param.market, LONG, _param.indexPrice, _param.sizeDelta);

        IPUSDManager.GlobalPUSDPosition storage position = _state.globalPUSDPosition;
        IPUSDManager.GlobalPUSDPosition memory positionCache = position;
        uint96 tradingFee = PositionUtil.distributeTradingFee(
            _state,
            PositionUtil.DistributeFeeParam({
                market: _param.market,
                size: _param.sizeDelta,
                entryPrice: positionCache.entryPrice,
                indexPrice: _param.indexPrice,
                rounding: Math.Rounding.Down,
                tradingFeeRate: _cfg.tradingFeeRate,
                protocolFeeRate: _cfg.protocolFeeRate
            })
        );

        int256 realizedPnL = PositionUtil.calcUnrealizedPnL(
            SHORT,
            _param.sizeDelta,
            positionCache.entryPrice,
            _param.indexPrice
        );

        uint96 receiveAmount;
        uint64 pusdDebtDelta;
        unchecked {
            int256 receiveAmountInt = int256(uint256(_param.sizeDelta)) - int256(uint256(tradingFee)) + realizedPnL;
            if (receiveAmountInt < 0) revert IMarketErrors.NegativeReceiveAmount(receiveAmountInt);
            receiveAmount = uint256(receiveAmountInt).toUint96();

            pusdDebtDelta = uint64(
                Math.ceilDiv(uint256(_param.sizeDelta) * positionCache.totalSupply, positionCache.size)
            );

            position.size = positionCache.size - _param.sizeDelta;
            position.totalSupply = positionCache.totalSupply - pusdDebtDelta;
        }

        emit IPUSDManager.PUSDPositionDecreased(
            _param.market,
            address(this),
            _param.sizeDelta,
            _param.indexPrice,
            pusdDebtDelta,
            receiveAmount,
            realizedPnL,
            tradingFee,
            0
        );

        IMarketManager.LiquidityBufferModule storage module = _state.liquidityBufferModule;
        module.pusdDebt += pusdDebtDelta;
        module.tokenPayback += receiveAmount;
        emit IMarketManager.LiquidityBufferModuleDebtIncreased(
            _param.market,
            _param.account,
            pusdDebtDelta,
            receiveAmount
        );
    }

    function repayLiquidityBufferDebt(
        IMarketManager.State storage _state,
        IERC20 _market,
        address _account,
        address _receiver
    ) public returns (uint128 receiveAmount) {
        IMarketManager.LiquidityBufferModule storage module = _state.liquidityBufferModule;
        IMarketManager.LiquidityBufferModule memory moduleCache = module;

        IPUSD usd = IPUSD(computePUSDAddress());
        uint128 amount = usd.balanceOf(address(this)).toUint128();

        // if paid too much, only repay the debt.
        if (amount > moduleCache.pusdDebt) amount = moduleCache.pusdDebt;

        // avoid reentrancy attack
        // prettier-ignore
        unchecked { module.pusdDebt = moduleCache.pusdDebt - amount; }

        usd.burn(amount);

        unchecked {
            receiveAmount = uint128((uint256(moduleCache.tokenPayback) * amount) / moduleCache.pusdDebt);
            module.tokenPayback = moduleCache.tokenPayback - receiveAmount;
        }

        _state.tokenBalance -= receiveAmount;
        _market.safeTransfer(_receiver, receiveAmount);
        emit IMarketManager.LiquidityBufferModuleDebtRepaid(_market, _account, amount, receiveAmount);
    }

    function updatePSMCollateralCap(IPSM.CollateralState storage _state, IERC20 _collateral, uint120 _cap) public {
        address usd = computePUSDAddress();
        require(usd != address(0) && usd != address(_collateral), IPSM.InvalidCollateral());

        if (_state.decimals == 0) {
            uint8 decimals = IERC20Metadata(address(_collateral)).decimals();
            require(decimals <= 18, IPSM.InvalidCollateralDecimals(decimals));
            _state.decimals = decimals;
        }
        _state.cap = _cap;
        emit IPSM.PSMCollateralUpdated(_collateral, _cap);
    }

    function psmMint(
        IPSM.CollateralState storage _state,
        IERC20 _collateral,
        address _receiver
    ) public returns (uint64 receiveAmount) {
        uint128 balanceAfter = _collateral.balanceOf(address(this)).toUint128();
        if (balanceAfter > _state.cap) balanceAfter = _state.cap;

        uint96 payAmount = (balanceAfter - _state.balance).toUint96();
        _state.balance = balanceAfter;

        receiveAmount = PositionUtil.calcDecimals6TokenValue(
            payAmount,
            Constants.PRICE_1,
            _state.decimals,
            Math.Rounding.Down
        );
        IPUSD(computePUSDAddress()).mint(_receiver, receiveAmount);

        emit IPSM.PSMMinted(_collateral, _receiver, payAmount, receiveAmount);
    }

    function psmBurn(
        IPSM.CollateralState storage _state,
        IERC20 _collateral,
        address _receiver
    ) public returns (uint96 receiveAmount) {
        IPUSD usd = IPUSD(computePUSDAddress());
        uint64 payAmount = usd.balanceOf(address(this)).toUint64();
        usd.burn(payAmount);

        receiveAmount = PositionUtil.calcMarketTokenValue(payAmount, Constants.PRICE_1, _state.decimals);

        if (_state.balance < receiveAmount) revert IPSM.InsufficientPSMBalance(receiveAmount, _state.balance);
        // prettier-ignore
        unchecked { _state.balance -= receiveAmount; }

        _collateral.safeTransfer(_receiver, receiveAmount);

        emit IPSM.PSMBurned(_collateral, _receiver, payAmount, receiveAmount);
    }

    /// @notice Calculate the size delta of burning PUSD when output amount is specified
    function calcBurnPUSDSizeDelta(
        CalcBurnPUSDInputAmountParam memory _param
    ) internal pure returns (uint96 sizeDelta) {
        uint256 minuendX96;
        unchecked {
            uint256 numeratorX96 = uint256(Constants.BASIS_POINTS_DIVISOR - _param.tradingFeeRate) << 96;
            numeratorX96 *= _param.entryPrice;
            minuendX96 = numeratorX96 / (uint256(_param.indexPrice) * Constants.BASIS_POINTS_DIVISOR);
        }

        uint256 denominatorX96 = minuendX96 - _param.spreadX96;
        sizeDelta = Math.ceilDiv(uint256(_param.outputAmount) << 96, denominatorX96).toUint96();
    }

    function validateDecreaseSize(
        IMarketManager.PackedState storage _packedState,
        uint24 _maxBurningRate,
        uint128 _sizeDelta
    ) internal view {
        unchecked {
            (uint128 lpNetSize, uint128 lpLiquidity) = (_packedState.lpNetSize, _packedState.lpLiquidity);
            require(_sizeDelta > 0, IMarketErrors.InvalidSize());
            uint256 netSizeAfter = uint256(lpNetSize) + _sizeDelta;
            uint256 maxBurningSizeCap = (uint256(lpLiquidity) * _maxBurningRate) / Constants.BASIS_POINTS_DIVISOR;
            require(
                netSizeAfter <= maxBurningSizeCap,
                IMarketErrors.MaxBurningSizeCapExceeded(lpNetSize, _sizeDelta, maxBurningSizeCap)
            );
        }
    }

    function _refreshSpreadFactor(
        IMarketManager.PackedState storage _state,
        IERC20 _market,
        int256 _spreadFactorAfterX96
    ) private {
        _state.spreadFactorX96 = _spreadFactorAfterX96;
        _state.lastTradingTimestamp = uint64(block.timestamp); // overflow is desired
        emit IMarketManager.SpreadFactorChanged(_market, _spreadFactorAfterX96);
    }

    function _validateStableCoinSupplyCap(
        uint64 _stableCoinSupplyCap,
        uint64 _totalSupply,
        uint64 _amountDelta
    ) private pure returns (uint64 totalSupplyAfter) {
        unchecked {
            uint256 totalSupplyAfter_ = uint256(_totalSupply) + _amountDelta;
            if (totalSupplyAfter_ > _stableCoinSupplyCap)
                revert IMarketErrors.StableCoinSupplyCapExceeded(_stableCoinSupplyCap, _totalSupply, _amountDelta);
            totalSupplyAfter = uint64(totalSupplyAfter_); // there will be no overflow here
        }
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "../misc/interfaces/IReader.sol";
import "../core/MarketManagerUpgradeable.sol";

library PositionReader {
    using SafeCast for *;
    using UnsafeMath for *;

    /// @dev This struct is introduced to solve the stack too deep error during contract compilation
    struct DecreasePositionRes {
        uint96 decreasePositionReceiveAmount;
        uint96 marginAfter;
    }

    function quoteBurnPUSDToIncreasePosition(
        IReader.ReaderState storage _readerState,
        IERC20 _market,
        address _account,
        uint64 _amountIn,
        uint64 _indexPrice,
        uint32 _leverage
    ) public returns (uint96 burnPUSDReceiveAmount, uint96 size, IMarketPosition.Position memory position) {
        IMarketManager marketManager = _readerState.marketManager;
        if (!marketManager.isEnabledMarket(_market)) revert IConfigurable.MarketNotEnabled(_market);

        IReader.MockState storage mockState = _readerState.mockState;
        IMarketManager.State storage state = mockState.state;
        mockState.marketConfig = marketManager.marketConfigs(_market);
        IConfigurable.MarketConfig storage marketConfig = mockState.marketConfig;

        state.packedState = marketManager.packedStates(_market);
        IPUSDManager.GlobalPUSDPosition memory pusdPosition = marketManager.globalPUSDPositions(_market);
        state.globalPUSDPosition = pusdPosition;
        state.tokenBalance = marketManager.tokenBalances(_market);

        PUSD pusd = PUSDManagerUtil.deployPUSD();
        pusd.mint(address(this), pusdPosition.totalSupply - _amountIn); // for mock
        (, burnPUSDReceiveAmount) = PUSDManagerUtil.burn(
            state,
            marketConfig,
            PUSDManagerUtil.BurnParam({
                market: IERC20(address(this)), // for mock
                exactIn: true,
                amount: _amountIn,
                callback: IPUSDManagerCallback(address(this)), // for mock
                indexPrice: _indexPrice,
                receiver: address(this)
            }),
            bytes("")
        );

        mapping(address => IMarketPosition.Position) storage positions = state.longPositions;
        positions[address(this)] = marketManager.longPositions(_market, _account); // for mock

        IMarketManager.PackedState storage packedState = state.packedState;
        uint96 leverageSize = _mulLeverage(burnPUSDReceiveAmount, _leverage);
        uint96 spread = PositionUtil.refreshSpreadFactor(
            packedState,
            marketConfig,
            IERC20(address(this)), // for mock
            leverageSize,
            LONG
        );

        uint32 tradingFeeRate = PositionUtil.calcTradingFeeRate(
            marketConfig,
            packedState.lpLiquidity,
            packedState.lpNetSize + leverageSize
        );
        uint96 tradingFee;
        unchecked {
            tradingFee = Math
                .ceilDiv(uint256(leverageSize) * tradingFeeRate, Constants.BASIS_POINTS_DIVISOR)
                .toUint96();
            uint256 feeAmount = uint256(tradingFee) + spread;
            if (burnPUSDReceiveAmount <= feeAmount) revert IMarketErrors.InsufficientMargin();
            size = _mulLeverage(burnPUSDReceiveAmount - uint96(feeAmount), _leverage);
        }

        PositionUtil.increasePosition(
            state,
            marketConfig,
            PositionUtil.IncreasePositionParam({
                market: IERC20(address(this)), // for mock
                account: address(this),
                sizeDelta: size,
                marginDelta: burnPUSDReceiveAmount,
                minIndexPrice: _indexPrice,
                maxIndexPrice: _indexPrice
            })
        );

        position = positions[address(this)];

        delete positions[address(this)];
        delete _readerState.mockState;
    }

    function quoteDecreasePositionToMintPUSD(
        IReader.ReaderState storage _readerState,
        IERC20 _market,
        address _account,
        uint96 _size,
        uint64 _indexPrice
    ) public returns (uint96 decreasePositionReceiveAmount, uint64 mintPUSDTokenValue, uint96 marginAfter) {
        IMarketManager marketManager = _readerState.marketManager;
        if (!marketManager.isEnabledMarket(_market)) revert IConfigurable.MarketNotEnabled(_market);

        IReader.MockState storage mockState = _readerState.mockState;
        IMarketManager.State storage state = mockState.state;
        mockState.marketConfig = marketManager.marketConfigs(_market);
        IConfigurable.MarketConfig storage marketConfig = mockState.marketConfig;
        state.packedState = marketManager.packedStates(_market);
        IPUSDManager.GlobalPUSDPosition memory pusdPosition = marketManager.globalPUSDPositions(_market);
        state.globalPUSDPosition = pusdPosition;
        state.tokenBalance = marketManager.tokenBalances(_market);
        // settle position
        IMarketPosition.Position memory position = marketManager.longPositions(_market, _account);
        if (position.size == 0) revert IMarketErrors.PositionNotFound(_account);

        if (position.size < _size) revert IMarketErrors.InsufficientSizeToDecrease(position.size, _size);

        mapping(address => IMarketPosition.Position) storage positions = state.longPositions;
        positions[address(this)] = position; // for mock

        DecreasePositionRes memory res = _decreasePosition(_readerState, position, _size, _indexPrice);

        PUSD pusd = PUSDManagerUtil.deployPUSD();
        pusd.mint(address(this), pusdPosition.totalSupply); // for mock
        if (res.decreasePositionReceiveAmount > 0) {
            (, mintPUSDTokenValue) = PUSDManagerUtil.mint(
                state,
                marketConfig,
                PUSDManagerUtil.MintParam({
                    market: IERC20(address(this)), // for mock
                    exactIn: true,
                    amount: res.decreasePositionReceiveAmount,
                    callback: IPUSDManagerCallback(address(this)), // for mock
                    indexPrice: _indexPrice,
                    receiver: address(this)
                }),
                msg.data // for mock
            );
        }

        (decreasePositionReceiveAmount, marginAfter) = (res.decreasePositionReceiveAmount, res.marginAfter);

        delete positions[address(this)];
        delete _readerState.mockState;
    }

    function quoteIncreasePositionBySize(
        IReader.ReaderState storage _readerState,
        IERC20 _market,
        address _account,
        uint96 _size,
        uint32 _leverage,
        uint64 _indexPrice
    ) public returns (uint96 payAmount, uint96 marginAfter, uint96 spread, uint96 tradingFee, uint64 liquidationPrice) {
        IMarketManager marketManager = _readerState.marketManager;
        if (!marketManager.isEnabledMarket(_market)) revert IConfigurable.MarketNotEnabled(_market);

        IReader.MockState storage mockState = _readerState.mockState;
        IMarketManager.State storage state = mockState.state;
        mockState.marketConfig = marketManager.marketConfigs(_market);
        IConfigurable.MarketConfig storage marketConfig = mockState.marketConfig;

        state.packedState = marketManager.packedStates(_market);
        IMarketManager.PackedState storage packedState = state.packedState;

        IMarketPosition.Position memory position = marketManager.longPositions(_market, _account);
        (uint256 sizeAfter, uint128 lpNetSizeAfter) = PositionUtil.validateIncreaseSize(
            marketConfig,
            packedState,
            position.size,
            _size
        );

        spread = PositionUtil.refreshSpreadFactor(
            packedState,
            marketConfig,
            IERC20(address(this)), // for mock
            _size,
            LONG
        );

        uint32 tradingFeeRate = PositionUtil.calcTradingFeeRate(marketConfig, packedState.lpLiquidity, lpNetSizeAfter);
        unchecked {
            tradingFee = Math.ceilDiv(uint256(_size) * tradingFeeRate, Constants.BASIS_POINTS_DIVISOR).toUint96();
        }

        uint256 fees = uint256(tradingFee) + spread;
        payAmount = (Math.mulDivUp(_size, Constants.BASIS_POINTS_DIVISOR, _leverage) + fees).toUint96();
        if (position.size == 0 && payAmount < marketConfig.minMarginPerPosition)
            payAmount = marketConfig.minMarginPerPosition;
        marginAfter = (uint256(position.margin) + payAmount - fees).toUint96();

        unchecked {
            uint64 maxLeverage = marketConfig.maxLeveragePerPosition;
            if (uint256(marginAfter) * maxLeverage < sizeAfter) {
                uint256 minMargin = Math.ceilDiv(sizeAfter, maxLeverage);
                payAmount = (minMargin + fees - position.margin).toUint96();
                marginAfter = uint96(minMargin);
            }
        }

        uint64 entryPriceAfter = PositionUtil.calcNextEntryPrice(
            LONG,
            position.size,
            position.entryPrice,
            _size,
            _indexPrice
        );

        position.margin = marginAfter;
        position.size = uint96(sizeAfter);
        position.entryPrice = entryPriceAfter;

        // calculate the liquidation price
        liquidationPrice = PositionUtil.calcLiquidationPrice(
            position,
            marketConfig.liquidationFeeRatePerPosition,
            marketConfig.tradingFeeRate,
            marketConfig.liquidationExecutionFee
        );

        delete _readerState.mockState;
    }

    function _decreasePosition(
        IReader.ReaderState storage _readerState,
        IMarketPosition.Position memory _position,
        uint96 _size,
        uint64 _indexPrice
    ) internal returns (DecreasePositionRes memory res) {
        PositionUtil.DecreasePositionParam memory decreasePosition = PositionUtil.DecreasePositionParam({
            market: IERC20(address(this)), // for mock
            account: address(this),
            marginDelta: 0,
            sizeDelta: _size,
            minIndexPrice: _indexPrice,
            maxIndexPrice: _indexPrice,
            receiver: address(this)
        });

        IMarketManager.State storage state = _readerState.mockState.state;
        IConfigurable.MarketConfig storage marketConfig = _readerState.mockState.marketConfig;
        if (_position.size == _size) {
            (, res.decreasePositionReceiveAmount) = PositionUtil.decreasePosition(
                state,
                marketConfig,
                decreasePosition
            );
        } else {
            uint96 spread = PositionUtil.refreshSpreadFactor(
                state.packedState,
                marketConfig,
                IERC20(address(this)), // for mock
                _size,
                SHORT
            );
            uint96 tradingFee = PositionUtil.calcTradingFee(
                PositionUtil.DistributeFeeParam({
                    market: IERC20(address(this)),
                    size: _size,
                    entryPrice: _indexPrice,
                    indexPrice: _indexPrice,
                    rounding: Math.Rounding.Up,
                    tradingFeeRate: marketConfig.tradingFeeRate,
                    protocolFeeRate: 0
                })
            );
            int256 realizedPnL = PositionUtil.calcUnrealizedPnL(LONG, _size, _position.entryPrice, _indexPrice);
            // calculate the margin required for the remaining position
            unchecked {
                int256 marginDelta = int256((uint256(_position.margin) * _size) / _position.size);
                int256 pnl = realizedPnL - int256(uint256(tradingFee) + spread);
                if (marginDelta < -pnl) revert IMarketErrors.InsufficientMargin();
                res.decreasePositionReceiveAmount = uint256(marginDelta + pnl).toUint96();
                res.marginAfter = _position.margin - uint256(marginDelta).toUint96();
            }

            decreasePosition.marginDelta = res.decreasePositionReceiveAmount;
            PositionUtil.decreasePosition(state, marketConfig, decreasePosition);
        }
    }

    function _mulLeverage(uint96 _amount, uint32 _leverage) private pure returns (uint96 size) {
        return Math.mulDiv(_amount, _leverage, Constants.BASIS_POINTS_DIVISOR).toUint96();
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "./MarketUtil.sol";
import "./LiquidityUtil.sol";
import "./SpreadUtil.sol";
import "./UnsafeMath.sol";
import {LONG, SHORT} from "../types/Side.sol";
import "../core/interfaces/IPUSD.sol";
import "./PUSDManagerUtil.sol";

/// @notice Utility library for trader positions
library PositionUtil {
    using SafeCast for *;
    using UnsafeMath for *;

    struct IncreasePositionParam {
        IERC20 market;
        address account;
        uint96 marginDelta;
        uint96 sizeDelta;
        uint64 minIndexPrice;
        uint64 maxIndexPrice;
    }

    struct DecreasePositionParam {
        IERC20 market;
        address account;
        uint96 marginDelta;
        uint96 sizeDelta;
        uint64 minIndexPrice;
        uint64 maxIndexPrice;
        address receiver;
    }

    struct LiquidatePositionParam {
        IERC20 market;
        address account;
        uint64 minIndexPrice;
        uint64 maxIndexPrice;
        address feeReceiver;
    }

    struct MaintainMarginRateParam {
        int256 margin;
        uint96 size;
        uint64 entryPrice;
        uint64 decreaseIndexPrice;
        bool liquidatablePosition;
    }

    struct DistributeFeeParam {
        IERC20 market;
        uint96 size;
        uint64 entryPrice;
        uint64 indexPrice;
        Math.Rounding rounding;
        uint24 tradingFeeRate;
        uint24 protocolFeeRate;
    }

    function increasePosition(
        IMarketManager.State storage _state,
        IConfigurable.MarketConfig storage _cfg,
        IncreasePositionParam memory _param
    ) internal returns (uint96 spread) {
        IMarketManager.Position storage position = _state.longPositions[_param.account];
        IMarketManager.Position memory positionCache = position;
        if (positionCache.size == 0) {
            if (_param.sizeDelta == 0) revert IMarketErrors.PositionNotFound(_param.account);

            if (_param.marginDelta < _cfg.minMarginPerPosition) revert IMarketErrors.InsufficientMargin();
        }

        uint96 tradingFee;
        uint96 sizeAfter = positionCache.size;
        IMarketManager.PackedState storage packedState = _state.packedState;
        if (_param.sizeDelta > 0) {
            spread = refreshSpreadFactor(packedState, _cfg, _param.market, _param.sizeDelta, LONG);
            distributeSpread(_state, _param.market, spread);

            uint128 lpNetSizeAfter;
            (sizeAfter, lpNetSizeAfter) = validateIncreaseSize(_cfg, packedState, positionCache.size, _param.sizeDelta);
            packedState.longSize += _param.sizeDelta;

            // settle liquidity
            LiquidityUtil.settlePosition(packedState, _param.market, LONG, _param.maxIndexPrice, _param.sizeDelta);

            tradingFee = distributeTradingFee(
                _state,
                DistributeFeeParam({
                    market: _param.market,
                    size: _param.sizeDelta,
                    entryPrice: _param.maxIndexPrice,
                    indexPrice: _param.maxIndexPrice,
                    rounding: Math.Rounding.Up,
                    tradingFeeRate: calcTradingFeeRate(_cfg, packedState.lpLiquidity, lpNetSizeAfter),
                    protocolFeeRate: _cfg.protocolFeeRate
                })
            );
        }

        int256 marginAfter;
        unchecked {
            marginAfter = int256(uint256(positionCache.margin) + _param.marginDelta);
            marginAfter -= int256(uint256(tradingFee) + spread);
        }

        uint64 entryPriceAfter = calcNextEntryPrice(
            LONG,
            positionCache.size,
            positionCache.entryPrice,
            _param.sizeDelta,
            _param.maxIndexPrice
        );

        _validatePositionLiquidateMaintainMarginRate(
            _cfg,
            MaintainMarginRateParam({
                margin: marginAfter,
                size: sizeAfter,
                entryPrice: entryPriceAfter,
                decreaseIndexPrice: _param.minIndexPrice,
                liquidatablePosition: false
            })
        );
        uint96 marginAfterU96 = uint256(marginAfter).toUint96();

        if (_param.sizeDelta > 0) MarketUtil.validateLeverage(marginAfterU96, sizeAfter, _cfg.maxLeveragePerPosition);

        position.margin = marginAfterU96;
        if (_param.sizeDelta > 0) {
            position.size = sizeAfter;
            position.entryPrice = entryPriceAfter;
        }
        emit IMarketPosition.PositionIncreased(
            _param.market,
            _param.account,
            _param.marginDelta,
            marginAfterU96,
            _param.sizeDelta,
            _param.maxIndexPrice,
            entryPriceAfter,
            tradingFee,
            spread
        );
    }

    function decreasePosition(
        IMarketManager.State storage _state,
        IConfigurable.MarketConfig storage _cfg,
        DecreasePositionParam memory _param
    ) public returns (uint96 spread, uint96 adjustedMarginDelta) {
        IMarketManager.Position memory positionCache = _state.longPositions[_param.account];
        if (positionCache.size == 0) revert IMarketErrors.PositionNotFound(_param.account);

        uint96 tradingFee;
        uint96 sizeAfter = positionCache.size;
        int256 realizedPnL;
        IMarketManager.PackedState storage packedState = _state.packedState;
        if (_param.sizeDelta > 0) {
            if (positionCache.size < _param.sizeDelta)
                revert IMarketErrors.InsufficientSizeToDecrease(_param.sizeDelta, positionCache.size);

            spread = refreshSpreadFactor(packedState, _cfg, _param.market, _param.sizeDelta, SHORT);
            distributeSpread(_state, _param.market, spread);

            uint128 lpNetSize = packedState.lpNetSize;
            if (lpNetSize < _param.sizeDelta) {
                if (!_cfg.liquidityBufferModuleEnabled)
                    revert IMarketErrors.InsufficientSizeToDecrease(_param.sizeDelta, lpNetSize);

                PUSDManagerUtil.liquidityBufferModuleBurn(
                    _state,
                    _cfg,
                    packedState,
                    PUSDManagerUtil.LiquidityBufferModuleBurnParam({
                        market: _param.market,
                        account: _param.account,
                        sizeDelta: uint96(_param.sizeDelta.subU128(lpNetSize)),
                        indexPrice: _param.maxIndexPrice
                    })
                );
            }

            // never underflow because of the validation above
            unchecked {
                sizeAfter -= _param.sizeDelta;
                packedState.longSize -= _param.sizeDelta;
            }

            // If the position size becomes zero after the decrease, the marginDelta will be ignored
            if (sizeAfter == 0) _param.marginDelta = 0;

            // settle liquidity
            LiquidityUtil.settlePosition(packedState, _param.market, SHORT, _param.minIndexPrice, _param.sizeDelta);

            tradingFee = distributeTradingFee(
                _state,
                DistributeFeeParam({
                    market: _param.market,
                    size: _param.sizeDelta,
                    entryPrice: positionCache.entryPrice,
                    indexPrice: _param.minIndexPrice,
                    rounding: Math.Rounding.Up,
                    tradingFeeRate: _cfg.tradingFeeRate,
                    protocolFeeRate: _cfg.protocolFeeRate
                })
            );

            realizedPnL = calcUnrealizedPnL(LONG, _param.sizeDelta, positionCache.entryPrice, _param.minIndexPrice);
        }

        int256 marginAfter = int256(uint256(positionCache.margin));
        unchecked {
            marginAfter += realizedPnL - int256(uint256(tradingFee) + _param.marginDelta + spread);
            if (marginAfter < 0) revert IMarketErrors.InsufficientMargin();
        }

        uint96 marginAfterU96 = uint256(marginAfter).toUint96();
        if (sizeAfter > 0) {
            _validatePositionLiquidateMaintainMarginRate(
                _cfg,
                MaintainMarginRateParam({
                    margin: marginAfter,
                    size: sizeAfter,
                    entryPrice: positionCache.entryPrice,
                    decreaseIndexPrice: _param.minIndexPrice,
                    liquidatablePosition: false
                })
            );
            if (_param.marginDelta > 0)
                MarketUtil.validateLeverage(marginAfterU96, sizeAfter, _cfg.maxLeveragePerPosition);

            // Update position
            IMarketManager.Position storage position = _state.longPositions[_param.account];
            position.margin = marginAfterU96;
            if (_param.sizeDelta > 0) position.size = sizeAfter;
        } else {
            // Return all remaining margin if the position position size becomes zero after the decrease
            _param.marginDelta = marginAfterU96;
            marginAfterU96 = 0;

            // Delete position
            delete _state.longPositions[_param.account];
        }

        adjustedMarginDelta = _param.marginDelta;

        emit IMarketPosition.PositionDecreased(
            _param.market,
            _param.account,
            adjustedMarginDelta,
            marginAfterU96,
            _param.sizeDelta,
            _param.minIndexPrice,
            realizedPnL,
            tradingFee,
            spread,
            _param.receiver
        );
    }

    function liquidatePosition(
        IMarketManager.State storage _state,
        IConfigurable.MarketConfig storage _cfg,
        LiquidatePositionParam memory _param
    ) public returns (uint64 liquidationExecutionFee) {
        IMarketManager.Position memory positionCache = _state.longPositions[_param.account];
        if (positionCache.size == 0) revert IMarketErrors.PositionNotFound(_param.account);

        _validatePositionLiquidateMaintainMarginRate(
            _cfg,
            MaintainMarginRateParam({
                margin: int256(uint256(positionCache.margin)),
                size: positionCache.size,
                entryPrice: positionCache.entryPrice,
                decreaseIndexPrice: _param.minIndexPrice,
                liquidatablePosition: true
            })
        );

        IMarketManager.PackedState storage packedState = _state.packedState;
        uint128 lpNetSize = packedState.lpNetSize;
        if (lpNetSize < positionCache.size)
            PUSDManagerUtil.liquidityBufferModuleBurn(
                _state,
                _cfg,
                packedState,
                PUSDManagerUtil.LiquidityBufferModuleBurnParam({
                    market: _param.market,
                    account: _param.account,
                    sizeDelta: uint96(positionCache.size.subU128(lpNetSize)),
                    indexPrice: _param.maxIndexPrice
                })
            );

        liquidationExecutionFee = liquidatePosition(_state, _cfg, packedState, positionCache, _param);
    }

    function liquidatePosition(
        IMarketManager.State storage _state,
        IConfigurable.MarketConfig storage _cfg,
        IMarketManager.PackedState storage _packedState,
        IMarketManager.Position memory _positionCache,
        LiquidatePositionParam memory _param
    ) internal returns (uint64 liquidationExecutionFee) {
        liquidationExecutionFee = _cfg.liquidationExecutionFee;
        uint24 liquidationFeeRate = _cfg.liquidationFeeRatePerPosition;

        uint64 liquidationPrice = calcLiquidationPrice(
            _positionCache,
            liquidationFeeRate,
            _cfg.tradingFeeRate,
            liquidationExecutionFee
        );

        // settle liquidity
        LiquidityUtil.settlePosition(_packedState, _param.market, SHORT, liquidationPrice, _positionCache.size);

        uint96 liquidationFee = calcLiquidationFee(
            _positionCache.size,
            _positionCache.entryPrice,
            liquidationPrice,
            liquidationFeeRate
        );
        distributeLiquidationFee(_state, _param.market, liquidationFee);

        uint96 tradingFee = distributeTradingFee(
            _state,
            DistributeFeeParam({
                market: _param.market,
                size: _positionCache.size,
                entryPrice: _positionCache.entryPrice,
                indexPrice: liquidationPrice,
                rounding: Math.Rounding.Down,
                tradingFeeRate: _cfg.tradingFeeRate,
                protocolFeeRate: _cfg.protocolFeeRate
            })
        );

        _packedState.longSize = _packedState.longSize.subU128(_positionCache.size);

        delete _state.longPositions[_param.account];

        emit IMarketPosition.PositionLiquidated(
            _param.market,
            msg.sender,
            _param.account,
            _positionCache.size,
            _param.minIndexPrice,
            liquidationPrice,
            tradingFee,
            liquidationFee,
            liquidationExecutionFee,
            _param.feeReceiver
        );
    }

    /// @notice Calculate the liquidation fee of a position
    /// @param _size The size of the position
    /// @param _entryPrice The entry price of the position
    /// @param _indexPrice The index price
    /// @param _liquidationFeeRate The liquidation fee rate for trader positions,
    /// denominated in thousandths of a bip (i.e. 1e-7)
    /// @return liquidationFee The liquidation fee of the position
    function calcLiquidationFee(
        uint96 _size,
        uint64 _entryPrice,
        uint64 _indexPrice,
        uint24 _liquidationFeeRate
    ) internal pure returns (uint96 liquidationFee) {
        // liquidationFee = size * entryPrice * liquidationFeeRate / indexPrice
        unchecked {
            uint256 denominator = uint256(_indexPrice) * Constants.BASIS_POINTS_DIVISOR;
            liquidationFee = ((uint256(_size) * _liquidationFeeRate * _entryPrice) / denominator).toUint96();
        }
    }

    /// @notice Calculate the maintenance margin
    /// @dev maintenanceMargin = size * entryPrice * liquidationFeeRate / indexPrice
    ///                          + size * entryPrice * tradingFeeRate / indexPrice
    ///                          + liquidationExecutionFee
    ///                        = size * entryPrice * (liquidationFeeRate + tradingFeeRate) / indexPrice
    ///                          + liquidationExecutionFee
    /// @param _size The size of the position
    /// @param _entryPrice The entry price of the position
    /// @param _indexPrice The index price
    /// @param _liquidationFeeRate The liquidation fee rate for trader positions,
    /// denominated in thousandths of a bip (i.e. 1e-7)
    /// @param _tradingFeeRate The trading fee rate for trader increase or decrease positions,
    /// denominated in thousandths of a bip (i.e. 1e-7)
    /// @param _liquidationExecutionFee The liquidation execution fee paid by the position
    /// @return maintenanceMargin The maintenance margin
    function calcMaintenanceMargin(
        uint96 _size,
        uint64 _entryPrice,
        uint64 _indexPrice,
        uint24 _liquidationFeeRate,
        uint24 _tradingFeeRate,
        uint64 _liquidationExecutionFee
    ) internal pure returns (uint256 maintenanceMargin) {
        unchecked {
            uint256 numerator = uint256(_size) * _entryPrice * (uint64(_liquidationFeeRate) + _tradingFeeRate);
            maintenanceMargin = Math.ceilDiv(numerator, uint256(_indexPrice) * Constants.BASIS_POINTS_DIVISOR);
            maintenanceMargin += _liquidationExecutionFee;
        }
    }

    function refreshSpreadFactor(
        IMarketManager.PackedState storage _packedState,
        IConfigurable.MarketConfig storage _cfg,
        IERC20 _market,
        uint96 _sizeDelta,
        Side _side
    ) internal returns (uint96 spread) {
        int256 spreadFactorAfterX96;
        (spread, spreadFactorAfterX96) = SpreadUtil.calcSpread(
            _cfg,
            SpreadUtil.CalcSpreadParam({
                side: _side,
                sizeDelta: _sizeDelta,
                spreadFactorBeforeX96: _packedState.spreadFactorX96,
                lastTradingTimestamp: _packedState.lastTradingTimestamp
            })
        );
        _packedState.spreadFactorX96 = spreadFactorAfterX96;
        _packedState.lastTradingTimestamp = uint64(block.timestamp); // overflow is desired

        emit IMarketManager.SpreadFactorChanged(_market, spreadFactorAfterX96);
    }

    function distributeTradingFee(
        IMarketManager.State storage _state,
        DistributeFeeParam memory _param
    ) internal returns (uint96 tradingFee) {
        tradingFee = calcTradingFee(_param);

        uint96 liquidityFee;
        unchecked {
            uint96 _protocolFee = uint96(
                (uint256(tradingFee) * _param.protocolFeeRate) / Constants.BASIS_POINTS_DIVISOR
            );
            _state.protocolFee += _protocolFee; // overflow is desired
            emit IMarketManager.ProtocolFeeIncreased(_param.market, _protocolFee);

            liquidityFee = tradingFee - _protocolFee;
        }

        _state.packedState.lpLiquidity += liquidityFee;
        emit IMarketLiquidity.GlobalLiquidityIncreasedByTradingFee(_param.market, liquidityFee);
    }

    function calcTradingFee(DistributeFeeParam memory _param) internal pure returns (uint96 tradingFee) {
        unchecked {
            uint256 denominator = uint256(_param.indexPrice) * Constants.BASIS_POINTS_DIVISOR;
            uint256 numerator = uint256(_param.size) * _param.tradingFeeRate * _param.entryPrice;
            tradingFee = _param.rounding == Math.Rounding.Up
                ? Math.ceilDiv(numerator, denominator).toUint96()
                : (numerator / denominator).toUint96();
        }
    }

    function distributeSpread(IMarketManager.State storage _state, IERC20 _market, uint96 _spread) internal {
        if (_spread > 0) {
            unchecked {
                _state.globalStabilityFund += _spread; // overflow is desired
                emit IMarketManager.GlobalStabilityFundIncreasedBySpread(_market, _spread);
            }
        }
    }

    function distributeLiquidationFee(
        IMarketManager.State storage _state,
        IERC20 _market,
        uint96 _liquidationFee
    ) internal {
        unchecked {
            _state.globalStabilityFund += _liquidationFee; // overflow is desired
            emit IMarketManager.GlobalStabilityFundIncreasedByLiquidation(_market, _liquidationFee);
        }
    }

    /// @notice Calculate the next entry price of a position
    /// @param _side The side of the position (Long or Short)
    /// @param _sizeBefore The size of the position before the trade
    /// @param _entryPriceBefore The entry price of the position before the trade
    /// @param _sizeDelta The size of the trade
    /// @param _indexPrice The index price at which the position is changed
    /// @return nextEntryPrice The entry price of the position after the trade
    function calcNextEntryPrice(
        Side _side,
        uint128 _sizeBefore,
        uint64 _entryPriceBefore,
        uint128 _sizeDelta,
        uint64 _indexPrice
    ) internal pure returns (uint64 nextEntryPrice) {
        if (_sizeBefore == 0) nextEntryPrice = _indexPrice;
        else if (_sizeDelta == 0) nextEntryPrice = _entryPriceBefore;
        else {
            unchecked {
                uint256 liquidityAfter = uint256(_sizeBefore) * _entryPriceBefore;
                liquidityAfter += uint256(_sizeDelta) * _indexPrice;
                uint256 sizeAfter = uint256(_sizeBefore) + _sizeDelta;
                nextEntryPrice = uint64(
                    _side.isLong() ? Math.ceilDiv(liquidityAfter, sizeAfter) : liquidityAfter / sizeAfter
                );
            }
        }
    }

    /// @notice Calculate the quantity of tokens with 6 decimal precision that can be exchanged
    /// at the index price using the market token amount
    /// @param _marketTokenAmount The amount of market tokens
    /// @param _indexPrice The index price
    /// @param _marketDecimals The decimal places of the market token
    /// @param _rounding The rounding mode
    /// @return value The quantity of tokens represented with 6 decimal precision
    function calcDecimals6TokenValue(
        uint96 _marketTokenAmount,
        uint64 _indexPrice,
        uint8 _marketDecimals,
        Math.Rounding _rounding
    ) internal pure returns (uint64 value) {
        unchecked {
            uint256 denominator = 10 ** (Constants.PRICE_DECIMALS - Constants.DECIMALS_6 + _marketDecimals);
            value = _rounding == Math.Rounding.Up
                ? Math.ceilDiv(uint256(_marketTokenAmount) * _indexPrice, denominator).toUint64()
                : ((uint256(_marketTokenAmount) * _indexPrice) / denominator).toUint64();
        }
    }

    /// @notice Calculate the quantity of market tokens that can be exchanged at the index price
    /// using the tokens with 6 decimal precision
    /// @param _decimals6TokenAmount The amount of tokens represented with 6 decimal precision
    /// @param _indexPrice The index price
    /// @param _marketDecimals The decimal places of the market token
    /// @return value The quantity of market tokens
    function calcMarketTokenValue(
        uint96 _decimals6TokenAmount,
        uint64 _indexPrice,
        uint8 _marketDecimals
    ) internal pure returns (uint96 value) {
        unchecked {
            uint256 numerator = uint256(_decimals6TokenAmount) *
                10 ** (Constants.PRICE_DECIMALS - Constants.DECIMALS_6 + _marketDecimals);
            value = (numerator / _indexPrice).toUint96();
        }
    }

    /// @notice Calculate the unrealized PnL of a position based on entry price
    /// @param _side The side of the position (Long or Short)
    /// @param _size The size of the position
    /// @param _entryPrice The entry price of the position
    /// @param _price The trade price or index price, caller should ensure that the price is not zero
    /// @return unrealizedPnL The unrealized PnL of the position, positive value means profit,
    /// negative value means loss
    function calcUnrealizedPnL(
        Side _side,
        uint128 _size,
        uint64 _entryPrice,
        uint64 _price
    ) internal pure returns (int256 unrealizedPnL) {
        unchecked {
            if (_side.isLong()) {
                if (_entryPrice > _price)
                    unrealizedPnL = -int256(Math.ceilDiv(uint256(_size) * (_entryPrice - _price), _price));
                else unrealizedPnL = int256((uint256(_size) * (_price - _entryPrice)) / _price);
            } else {
                if (_entryPrice < _price)
                    unrealizedPnL = -int256(Math.ceilDiv(uint256(_size) * (_price - _entryPrice), _price));
                else unrealizedPnL = int256((uint256(_size) * (_entryPrice - _price)) / _price);
            }
        }
    }

    /// @notice Calculate the liquidation price
    /// @dev Given the liquidation condition as:
    /// For long position: margin - size * (entryPrice - liquidationPrice) / liquidationPrice
    ///                     = entryPrice * size * liquidationFeeRate / liquidationPrice
    ///                         + entryPrice * size * tradingFeeRate / liquidationPrice + liquidationExecutionFee
    /// We can get:
    /// Long position liquidation price:
    ///     liquidationPrice
    ///       = size * entryPrice * (liquidationFeeRate + tradingFeeRate + 1)
    ///       / [margin + size - liquidationExecutionFee]
    /// @param _position The cache of position
    /// @param _liquidationFeeRate The liquidation fee rate for trader positions,
    /// denominated in thousandths of a bip (i.e. 1e-7)
    /// @param _tradingFeeRate The trading fee rate for trader increase or decrease positions,
    /// denominated in thousandths of a bip (i.e. 1e-7)
    /// @param _liquidationExecutionFee The liquidation execution fee paid by the position
    /// @return liquidationPrice The liquidation price of the position
    function calcLiquidationPrice(
        IMarketManager.Position memory _position,
        uint24 _liquidationFeeRate,
        uint24 _tradingFeeRate,
        uint64 _liquidationExecutionFee
    ) internal pure returns (uint64 liquidationPrice) {
        unchecked {
            int256 denominator = int256(uint256(_position.margin) + _position.size) -
                int256(uint256(_liquidationExecutionFee));
            assert(denominator > 0);
            denominator *= int256(uint256(Constants.BASIS_POINTS_DIVISOR));

            uint256 numerator = uint256(_position.size) * _position.entryPrice;
            numerator *= uint64(_liquidationFeeRate) + _tradingFeeRate + Constants.BASIS_POINTS_DIVISOR;
            liquidationPrice = (numerator / uint256(denominator)).toUint64();
        }
    }

    function calcTradingFeeRate(
        IConfigurable.MarketConfig storage _cfg,
        uint128 _lpLiquidity,
        uint128 _lpNetSizeAfter
    ) internal view returns (uint24 tradingFeeRate) {
        unchecked {
            uint256 floatingTradingFeeSize = (uint256(_lpLiquidity) * _cfg.openPositionThreshold) /
                Constants.BASIS_POINTS_DIVISOR;
            if (_lpNetSizeAfter > floatingTradingFeeSize) {
                uint256 floatingTradingFeeRate = (_cfg.maxFeeRate * (_lpNetSizeAfter - floatingTradingFeeSize)) /
                    (_lpLiquidity - floatingTradingFeeSize);
                return uint24(floatingTradingFeeRate) + _cfg.tradingFeeRate;
            } else {
                return _cfg.tradingFeeRate;
            }
        }
    }

    /// @notice Validate the increase position size
    /// @param _sizeBefore The size of the position before the trade
    /// @param _sizeDelta The size of the trade
    /// @return sizeAfter The size of the position after the trade
    /// @return lpNetSizeAfter The net size of the LP after the trade
    function validateIncreaseSize(
        IConfigurable.MarketConfig storage _cfg,
        IMarketManager.PackedState storage _packedState,
        uint96 _sizeBefore,
        uint96 _sizeDelta
    ) internal view returns (uint96 sizeAfter, uint128 lpNetSizeAfter) {
        unchecked {
            (uint128 lpNetSize, uint128 lpLiquidity) = (_packedState.lpNetSize, _packedState.lpLiquidity);
            uint256 lpNetSizeAfter_ = uint256(lpNetSize) + _sizeDelta;
            if (lpNetSizeAfter_ > lpLiquidity) revert IMarketErrors.SizeExceedsMaxSize(lpNetSizeAfter_, lpLiquidity);

            lpNetSizeAfter = uint128(lpNetSizeAfter_);

            sizeAfter = (uint256(_sizeBefore) + _sizeDelta).toUint96();
            uint256 maxSizePerPosition = (uint256(lpLiquidity) * _cfg.maxSizeRatePerPosition) /
                Constants.BASIS_POINTS_DIVISOR;
            if (sizeAfter > maxSizePerPosition)
                revert IMarketErrors.SizeExceedsMaxSizePerPosition(sizeAfter, maxSizePerPosition);
        }
    }

    /// @notice Validate the position has not reached the liquidation margin rate
    function _validatePositionLiquidateMaintainMarginRate(
        IConfigurable.MarketConfig storage _cfg,
        MaintainMarginRateParam memory _param
    ) private view {
        uint256 maintenanceMargin = calcMaintenanceMargin(
            _param.size,
            _param.entryPrice,
            _param.decreaseIndexPrice,
            _cfg.liquidationFeeRatePerPosition,
            _cfg.tradingFeeRate,
            _cfg.liquidationExecutionFee
        );
        int256 unrealizedPnL = calcUnrealizedPnL(LONG, _param.size, _param.entryPrice, _param.decreaseIndexPrice);
        unchecked {
            if (unrealizedPnL < 0) maintenanceMargin += uint256(-unrealizedPnL);
        }

        if (!_param.liquidatablePosition) {
            if (_param.margin <= 0 || maintenanceMargin >= uint256(_param.margin))
                revert IMarketErrors.MarginRateTooHigh(_param.margin, maintenanceMargin);
        } else {
            if (_param.margin > 0 && maintenanceMargin < uint256(_param.margin))
                revert IMarketErrors.MarginRateTooLow(_param.margin, maintenanceMargin);
        }
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "./Constants.sol";
import "./UnsafeMath.sol";
import "../oracle/interfaces/IPriceFeed.sol";
import "../oracle/interfaces/IChainLinkAggregator.sol";
import "solady/src/utils/FixedPointMathLib.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";

library PriceFeedUtil {
    using SafeCast for *;
    using UnsafeMath for *;
    using FixedPointMathLib for *;

    /// @dev value difference precision
    uint256 public constant DELTA_PRECISION = 1000 * 1000;

    function getReferencePrice(
        IPriceFeed.PriceFeedConfig memory _cfg,
        uint8 _priceDecimals
    ) internal view returns (uint64 latestRefPrice) {
        (, int256 refPrice, , uint256 timestamp, ) = _cfg.refPriceFeed.latestRoundData();
        if (refPrice <= 0) revert IPriceFeed.InvalidReferencePrice(refPrice);

        if (_cfg.refHeartbeatDuration != 0) {
            uint256 timeDiff = block.timestamp.dist(timestamp);
            if (timeDiff > _cfg.refHeartbeatDuration) revert IPriceFeed.ReferencePriceTimeout(timeDiff);
        }

        latestRefPrice = (
            _cfg.refPriceDecimals >= _priceDecimals
                ? uint256(refPrice).divU256(10 ** _cfg.refPriceDecimals.dist(_priceDecimals))
                : uint256(refPrice) * (10 ** _cfg.refPriceDecimals.dist(_priceDecimals))
        ).toUint64();
    }

    function calcMinAndMaxPrice(
        uint64 _price,
        uint64 _refPrice,
        uint24 _maxDeviationRatio,
        bool _reachMaxDeltaDiff
    ) internal pure returns (uint64 minPrice, uint64 maxPrice) {
        (minPrice, maxPrice) = (_price, _price);
        if (_reachMaxDeltaDiff || calcDiffBasisPoints(_price, _refPrice) > _maxDeviationRatio) {
            if (_price > _refPrice) minPrice = _refPrice;
            else maxPrice = _refPrice;
        }
    }

    function calcDiffBasisPoints(uint64 _price, uint64 _basisPrice) internal pure returns (uint64) {
        // prettier-ignore
        unchecked { return uint64((_price.dist(_basisPrice) * DELTA_PRECISION) / _basisPrice); }
    }

    function calcNewPriceDataItem(
        IPriceFeed.PriceDataItem memory _item,
        uint64 _price,
        uint64 _refPrice,
        uint48 _maxCumulativeDeltaDiffs,
        uint32 _cumulativeRoundDuration
    ) internal view returns (bool reachMaxDeltaDiff) {
        uint32 currentRound;
        // prettier-ignore
        unchecked { currentRound = uint32(block.timestamp / _cumulativeRoundDuration); }
        if (currentRound != _item.prevRound) {
            _item.cumulativePriceDelta = 0;
            _item.cumulativeRefPriceDelta = 0;
            _item.prevRefPrice = _refPrice;
            _item.prevPrice = _price;
            _item.prevRound = currentRound;
            return false;
        }
        uint64 cumulativeRefPriceDelta = calcDiffBasisPoints(_refPrice, _item.prevRefPrice);
        uint64 cumulativePriceDelta = calcDiffBasisPoints(_price, _item.prevPrice);

        _item.cumulativeRefPriceDelta = _item.cumulativeRefPriceDelta + cumulativeRefPriceDelta;
        _item.cumulativePriceDelta = _item.cumulativePriceDelta + cumulativePriceDelta;
        unchecked {
            if (
                _item.cumulativePriceDelta > _item.cumulativeRefPriceDelta &&
                _item.cumulativePriceDelta - _item.cumulativeRefPriceDelta > _maxCumulativeDeltaDiffs
            ) reachMaxDeltaDiff = true;

            _item.prevRefPrice = _refPrice;
            _item.prevPrice = _price;
            _item.prevRound = currentRound;
            return reachMaxDeltaDiff;
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

abstract contract ReentrancyGuard {
    bytes32 private constant STORAGE_SLOT = keccak256("solidity_reentrancy_guard.storage.slot");

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    modifier nonReentrant() {
        _nonReentrantBefore(STORAGE_SLOT);
        _;
        _nonReentrantAfter(STORAGE_SLOT);
    }

    modifier nonReentrantToken(IERC20 _token) {
        bytes32 slot = bytes32(uint256(uint160(address(_token))));
        _nonReentrantBefore(slot);
        _;
        _nonReentrantAfter(slot);
    }

    function _nonReentrantBefore(bytes32 _slot) private {
        uint256 state;
        // prettier-ignore
        assembly { state := tload(_slot) }
        require(state == 0, ReentrancyGuardReentrantCall());
        // prettier-ignore
        assembly { tstore(_slot, 1) }
    }

    function _nonReentrantAfter(bytes32 _slot) private {
        // prettier-ignore
        assembly { tstore(_slot, 0) }
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "./Constants.sol";
import "../core/interfaces/IMarketManager.sol";
import {M as Math} from "../libraries/Math.sol";
import "solady/src/utils/FixedPointMathLib.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";

library SpreadUtil {
    using SafeCast for *;
    using FixedPointMathLib for *;

    struct CalcSpreadParam {
        Side side;
        uint96 sizeDelta;
        int256 spreadFactorBeforeX96;
        uint64 lastTradingTimestamp;
    }

    /// @notice Calculate the trade spread when operating on positions or mint/burn PUSD
    /// @param _cfg The market configuration
    /// @return spreadAmount The amount of trade spread
    /// @return spreadFactorAfterX96 The spread factor after the trade, as a Q160.96
    function calcSpread(
        IConfigurable.MarketConfig storage _cfg,
        CalcSpreadParam memory _param
    ) internal view returns (uint96 spreadAmount, int256 spreadFactorAfterX96) {
        uint256 spreadX96;
        (spreadFactorAfterX96, spreadX96) = refreshSpread(_cfg, _param);

        spreadAmount = calcSpreadAmount(spreadX96, _param.sizeDelta, Math.Rounding.Up);

        spreadFactorAfterX96 = calcSpreadFactorAfterX96(spreadFactorAfterX96, _param.side, _param.sizeDelta);
    }

    function calcSpreadAmount(
        uint256 _spreadX96,
        uint96 _sizeDelta,
        Math.Rounding _rounding
    ) internal pure returns (uint96 spreadAmount) {
        spreadAmount = Math.mulDiv(_spreadX96, _sizeDelta, Constants.Q96, _rounding).toUint96();
    }

    function calcSpreadFactorAfterX96(
        int256 _spreadFactorBeforeX96,
        Side _side,
        uint96 _sizeDelta
    ) internal pure returns (int256 spreadFactorAfterX96) {
        unchecked {
            int256 sizeDeltaX96 = int256(uint256(_sizeDelta) << 96);
            spreadFactorAfterX96 = _side.isLong()
                ? _spreadFactorBeforeX96 + sizeDeltaX96
                : _spreadFactorBeforeX96 - sizeDeltaX96;
        }
    }

    /// @notice Refresh the spread factor since last trading and calculate the spread
    function refreshSpread(
        IConfigurable.MarketConfig storage _cfg,
        CalcSpreadParam memory _param
    ) internal view returns (int256 spreadFactorAfterX96, uint256 spreadX96) {
        unchecked {
            uint256 riskFreeTime = _cfg.riskFreeTime;
            uint256 timeInterval = block.timestamp - _param.lastTradingTimestamp;
            if (timeInterval >= riskFreeTime || _param.spreadFactorBeforeX96 == 0) return (0, 0);

            // Due to `Math.Rounding.Up`, if `spreadFactorBeforeX96Abs` > `0`, then `spreadFactorAfterX96Abs` > `0`
            uint256 spreadFactorAfterX96Abs = Math.ceilDiv(
                _param.spreadFactorBeforeX96.abs() * (riskFreeTime - timeInterval),
                riskFreeTime
            );

            spreadFactorAfterX96 = _param.spreadFactorBeforeX96 > 0
                ? int256(spreadFactorAfterX96Abs)
                : -int256(spreadFactorAfterX96Abs);

            spreadX96 = (_param.side.isLong() && spreadFactorAfterX96 > 0) ||
                (_param.side.isShort() && spreadFactorAfterX96 < 0)
                ? 0
                : Math.ceilDiv(spreadFactorAfterX96Abs, _cfg.liquidityScale);
        }
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

library TransferHelper {
    error TransferFailed(IERC20 token);

    function safeTransfer(IERC20 _token, address _receiver, uint256 _amount) internal {
        (bool success, bytes memory returnData) = address(_token).call(
            abi.encodeCall(_token.transfer, (_receiver, _amount))
        );
        _validateCallResult(_token, success, returnData);
    }

    function safeTransfer(IERC20 _token, address _receiver, uint256 _amount, uint256 _gasLimit) internal {
        (bool success, bytes memory returnData) = address(_token).call{gas: _gasLimit}(
            abi.encodeCall(_token.transfer, (_receiver, _amount))
        );
        _validateCallResult(_token, success, returnData);
    }

    function _validateCallResult(IERC20 _token, bool _success, bytes memory _returnData) private view {
        _returnData = Address.verifyCallResultFromTarget(address(_token), _success, _returnData);
        if (_returnData.length != 0 && !abi.decode(_returnData, (bool))) revert TransferFailed(_token);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library UnsafeMath {
    /// @notice Calculate `a + b` without overflow check
    function addU256(uint256 a, uint256 b) internal pure returns (uint256) {
        // prettier-ignore
        unchecked { return a + b; }
    }

    /// @notice Calculate `a + b` without overflow check
    function addU128(uint128 a, uint128 b) internal pure returns (uint128) {
        // prettier-ignore
        unchecked { return a + b; }
    }

    /// @notice Calculate `a - b` without underflow check
    function subU256(uint256 a, uint256 b) internal pure returns (uint256) {
        // prettier-ignore
        unchecked { return a - b; }
    }

    /// @notice Calculate `a - b` without underflow check
    function subU128(uint128 a, uint128 b) internal pure returns (uint128) {
        // prettier-ignore
        unchecked { return a - b; }
    }

    /// @notice Calculate `a - b` without underflow check
    function subU96(uint96 a, uint96 b) internal pure returns (uint96) {
        // prettier-ignore
        unchecked { return a - b; }
    }

    /// @notice Calculate `a * b` without overflow check
    function mulU256(uint256 a, uint256 b) internal pure returns (uint256) {
        // prettier-ignore
        unchecked { return a * b; }
    }

    /// @notice Calculate `a / b` without overflow check
    function divU256(uint256 a, uint256 b) internal pure returns (uint256) {
        // prettier-ignore
        unchecked { return a / b; }
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.8.26;

import "../types/PackedValue.sol";
import "../core/interfaces/IMarketManager.sol";
import "../plugins/interfaces/ILiquidator.sol";
import "../plugins/interfaces/IPositionRouter.sol";
import "../plugins/interfaces/IPositionRouter2.sol";
import "../governance/GovernableProxy.sol";
import "@openzeppelin/contracts/utils/Multicall.sol";
import "../plugins/interfaces/IBalanceRateBalancer.sol";

/// @notice MixedExecutor is a contract that executes multiple calls in a single transaction
contract MixedExecutor is Multicall, GovernableProxy {
    /// @notice The address of liquidator
    ILiquidator public immutable liquidator;
    /// @notice The address of position router
    IPositionRouter public immutable positionRouter;
    /// @notice The address of position router2
    IPositionRouter2 public immutable positionRouter2;
    /// @notice The address of market manager
    IMarketManager public immutable marketManager;
    /// @notice The address of balance rate balancer
    IBalanceRateBalancer public immutable balanceRateBalancer;

    /// @notice The executors
    mapping(address => bool) public executors;

    /// @notice Emitted when an executor is updated
    /// @param executor The address of executor to update
    /// @param active Updated status
    event ExecutorUpdated(address indexed executor, bool indexed active);

    /// @notice Emitted when the position liquidate failed
    /// @dev The event is emitted when the liquidate is failed after the execution error
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param account The address of account
    /// @param shortenedReason The shortened reason of the execution error
    event LiquidatePositionFailed(IERC20 indexed market, address indexed account, bytes4 shortenedReason);

    /// @notice Error thrown when the execution error and `requireSuccess` is set to true
    error ExecutionFailed(bytes reason);

    modifier onlyExecutor() {
        if (!executors[msg.sender]) revert Forbidden();
        _;
    }

    constructor(
        Governable _govImpl,
        ILiquidator _liquidator,
        IPositionRouter _positionRouter,
        IPositionRouter2 _positionRouter2,
        IMarketManager _marketManager,
        IBalanceRateBalancer _balanceRateBalancer
    ) GovernableProxy(_govImpl) {
        (liquidator, positionRouter, positionRouter2) = (_liquidator, _positionRouter, _positionRouter2);
        marketManager = _marketManager;
        balanceRateBalancer = _balanceRateBalancer;
    }

    /// @notice Set executor status active or not
    /// @param _executor Executor address
    /// @param _active Status of executor permission to set
    function setExecutor(address _executor, bool _active) external virtual onlyGov {
        executors[_executor] = _active;
        emit ExecutorUpdated(_executor, _active);
    }

    /// @notice Update price
    function updatePrice(PackedValue _packedValue) external virtual onlyExecutor {
        marketManager.updatePrice(_packedValue);
    }

    /// @notice Try to execute mint LP token request. If the request is not executable, cancel it.
    /// @param _param The mint LPT request id calculation param
    function executeOrCancelMintLPT(
        IPositionRouter2.MintLPTRequestIdParam calldata _param
    ) external virtual onlyExecutor {
        positionRouter2.executeOrCancelMintLPT(_param, payable(msg.sender));
    }

    /// @notice Try to execute burn LP token request. If the request is not executable, cancel it.
    /// @param _param The burn LPT request id calculation param
    function executeOrCancelBurnLPT(
        IPositionRouter2.BurnLPTRequestIdParam calldata _param
    ) external virtual onlyExecutor {
        positionRouter2.executeOrCancelBurnLPT(_param, payable(msg.sender));
    }

    /// @notice Try to execute increase position request. If the request is not executable, cancel it.
    /// @param _param The increase position request id calculation param
    function executeOrCancelIncreasePosition(
        IPositionRouter.IncreasePositionRequestIdParam calldata _param
    ) external virtual onlyExecutor {
        positionRouter.executeOrCancelIncreasePosition(_param, payable(msg.sender));
    }

    /// @notice Try to execute decrease position request. If the request is not executable, cancel it.
    /// @param _param The decrease position request id calculation param
    function executeOrCancelDecreasePosition(
        IPositionRouter.DecreasePositionRequestIdParam calldata _param
    ) external virtual onlyExecutor {
        positionRouter.executeOrCancelDecreasePosition(_param, payable(msg.sender));
    }

    /// @notice Try to Execute mint PUSD request. If the request is not executable, cancel it.
    /// @param _param The mint PUSD request id calculation param
    function executeOrCancelMintPUSD(
        IPositionRouter.MintPUSDRequestIdParam calldata _param
    ) external virtual onlyExecutor {
        positionRouter.executeOrCancelMintPUSD(_param, payable(msg.sender));
    }

    /// @notice Try to execute burn request. If the request is not executable, cancel it.
    /// @param _param The burn PUSD request id calculation param
    function executeOrCancelBurnPUSD(
        IPositionRouter.BurnPUSDRequestIdParam calldata _param
    ) external virtual onlyExecutor {
        positionRouter.executeOrCancelBurnPUSD(_param, payable(msg.sender));
    }

    /// @notice Collect protocol fee
    function collectProtocolFee(IERC20 _market) external virtual onlyExecutor {
        marketManager.collectProtocolFee(_market);
    }

    /// @notice Collect protocol fee batch
    /// @param _markets The array of market address to collect protocol fee
    function collectProtocolFeeBatch(IERC20[] calldata _markets) external virtual onlyExecutor {
        for (uint8 i; i < _markets.length; ++i) {
            marketManager.collectProtocolFee(_markets[i]);
        }
    }

    /// @notice Liquidate a position
    /// @param _market The market address
    /// @param _packedValue The packed values of the account and require success flag:
    /// bit 0-159 represent the account, and bit 160 represent the require success flag
    function liquidatePosition(IERC20 _market, PackedValue _packedValue) external virtual onlyExecutor {
        address account = _packedValue.unpackAddress(0);
        bool requireSuccess = _packedValue.unpackBool(160);

        try liquidator.liquidatePosition(_market, payable(account), payable(msg.sender)) {} catch (
            bytes memory reason
        ) {
            if (requireSuccess) revert ExecutionFailed(reason);

            emit LiquidatePositionFailed(_market, account, _decodeShortenedReason(reason));
        }
    }

    /// @notice Try to execute increase balance rate request. If the request is not executable, cancel it.
    /// @param _param The increase balance rate request id calculation param
    /// @param _shouldCancelOnFail should cancel request when execute failed
    function executeOrCancelIncreaseBalanceRate(
        IBalanceRateBalancer.IncreaseBalanceRateRequestIdParam calldata _param,
        bool _shouldCancelOnFail
    ) external virtual onlyExecutor {
        balanceRateBalancer.executeOrCancelIncreaseBalanceRate(_param, _shouldCancelOnFail, payable(msg.sender));
    }

    /// @notice Decode the shortened reason of the execution error
    /// @dev The default implementation is to return the first 4 bytes of the reason, which is typically the
    /// selector for the error type
    /// @param _reason The reason of the execution error
    /// @return The shortened reason of the execution error
    function _decodeShortenedReason(bytes memory _reason) internal pure virtual returns (bytes4) {
        return bytes4(_reason);
    }
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "./interfaces/IReader.sol";
import "../libraries/PositionReader.sol";
import "../libraries/LiquidityReader.sol";
import "../libraries/PriceFeedUtil.sol";

contract Reader is IReader {
    using SafeCast for *;
    using UnsafeMath for *;

    ReaderState readerState;

    constructor(MarketManagerUpgradeable _marketManager) {
        readerState.marketManager = _marketManager;
    }

    /// @inheritdoc IReader
    function calcLPTPrice(
        IERC20 _market,
        uint64 _indexPrice
    ) public override returns (uint256 totalSupply_, uint128 liquidity, uint64 price) {
        return LiquidityReader.calcLPTPrice(readerState, _market, _indexPrice);
    }

    /// @inheritdoc IReader
    function quoteMintPUSD(
        IERC20 _market,
        bool _exactIn,
        uint96 _amount,
        uint64 _indexPrice
    ) public override returns (uint96 payAmount, uint64 receiveAmount) {
        IMarketManager marketManager = readerState.marketManager;
        if (!marketManager.isEnabledMarket(_market)) revert IConfigurable.MarketNotEnabled(_market);

        MockState storage mockState = readerState.mockState;
        IMarketManager.State storage state = mockState.state;
        mockState.marketConfig = marketManager.marketConfigs(_market);
        IConfigurable.MarketConfig storage marketConfig = mockState.marketConfig;

        state.packedState = marketManager.packedStates(_market);
        IPUSDManager.GlobalPUSDPosition memory pusdPosition = marketManager.globalPUSDPositions(_market);
        state.globalPUSDPosition = pusdPosition;
        state.tokenBalance = marketManager.tokenBalances(_market);

        PUSD pusd = PUSDManagerUtil.deployPUSD();
        pusd.mint(address(this), pusdPosition.totalSupply); // for mock
        (payAmount, receiveAmount) = PUSDManagerUtil.mint(
            state,
            marketConfig,
            PUSDManagerUtil.MintParam({
                market: IERC20(address(this)), // for mock
                exactIn: _exactIn,
                amount: _amount,
                callback: IPUSDManagerCallback(address(this)), // for mock
                indexPrice: _indexPrice,
                receiver: address(this)
            }),
            msg.data // for mock
        );

        delete readerState.mockState;
    }

    /// @inheritdoc IReader
    function quoteBurnPUSD(
        IERC20 _market,
        bool _exactIn,
        uint96 _amount,
        uint64 _indexPrice
    ) public override returns (uint64 payAmount, uint96 receiveAmount) {
        IMarketManager marketManager = readerState.marketManager;
        if (!marketManager.isEnabledMarket(_market)) revert IConfigurable.MarketNotEnabled(_market);

        MockState storage mockState = readerState.mockState;
        IMarketManager.State storage state = mockState.state;
        mockState.marketConfig = marketManager.marketConfigs(_market);
        IConfigurable.MarketConfig storage marketConfig = mockState.marketConfig;

        state.packedState = marketManager.packedStates(_market);
        IPUSDManager.GlobalPUSDPosition memory pusdPosition = marketManager.globalPUSDPositions(_market);
        state.globalPUSDPosition = pusdPosition;
        state.tokenBalance = marketManager.tokenBalances(_market);

        PUSD pusd = PUSDManagerUtil.deployPUSD(); // for mock
        pusd.mint(address(this), pusdPosition.totalSupply);
        (payAmount, receiveAmount) = PUSDManagerUtil.burn(
            state,
            marketConfig,
            PUSDManagerUtil.BurnParam({
                market: IERC20(address(this)), // for mock
                exactIn: _exactIn,
                amount: _amount,
                callback: IPUSDManagerCallback(address(this)), // for mock
                indexPrice: _indexPrice,
                receiver: address(this)
            }),
            bytes("")
        );

        delete readerState.mockState;
    }

    /// @inheritdoc IReader
    function quoteBurnPUSDToMintLPT(
        IERC20 _market,
        uint96 _amountIn,
        uint64 _indexPrice
    ) public override returns (uint96 burnPUSDReceiveAmount, uint64 mintLPTTokenValue) {
        return LiquidityReader.quoteBurnPUSDToMintLPT(readerState, _market, _amountIn, _indexPrice);
    }

    /// @inheritdoc IReader
    function quoteBurnLPTToMintPUSD(
        IERC20 _market,
        uint64 _amountIn,
        uint64 _indexPrice
    ) public override returns (uint96 burnLPTReceiveAmount, uint64 mintPUSDTokenValue) {
        return LiquidityReader.quoteBurnLPTToMintPUSD(readerState, _market, _amountIn, _indexPrice);
    }

    /// @inheritdoc IReader
    function quoteBurnPUSDToIncreasePosition(
        IERC20 _market,
        address _account,
        uint64 _amountIn,
        uint64 _indexPrice,
        uint32 _leverage
    ) public override returns (uint96 burnPUSDReceiveAmount, uint96 size, IMarketPosition.Position memory position) {
        return
            PositionReader.quoteBurnPUSDToIncreasePosition(
                readerState,
                _market,
                _account,
                _amountIn,
                _indexPrice,
                _leverage
            );
    }

    /// @inheritdoc IReader
    function quoteDecreasePositionToMintPUSD(
        IERC20 _market,
        address _account,
        uint96 _size,
        uint64 _indexPrice
    ) public override returns (uint96 decreasePositionReceiveAmount, uint64 mintPUSDTokenValue, uint96 marginAfter) {
        return PositionReader.quoteDecreasePositionToMintPUSD(readerState, _market, _account, _size, _indexPrice);
    }

    /// @inheritdoc IReader
    function quoteIncreasePositionBySize(
        IERC20 _market,
        address _account,
        uint96 _size,
        uint32 _leverage,
        uint64 _indexPrice
    )
        public
        override
        returns (uint96 payAmount, uint96 marginAfter, uint96 spread, uint96 tradingFee, uint64 liquidationPrice)
    {
        return
            PositionReader.quoteIncreasePositionBySize(readerState, _market, _account, _size, _leverage, _indexPrice);
    }

    function longPositions(address _account) external view returns (IMarketPosition.Position memory) {
        return readerState.mockState.state.longPositions[_account];
    }

    /// @inheritdoc IReader
    function calcPrices(
        PackedValue[] calldata _marketPrices
    ) external view override returns (uint64[] memory minPrices, uint64[] memory maxPrices) {
        (uint24 maxDeviationRatio, uint32 cumulativeRoundDuration, , bool ignoreReferencePriceFeedError) = readerState
            .marketManager
            .globalPriceFeedConfig();

        uint256 pricesLength = _marketPrices.length;
        minPrices = new uint64[](pricesLength);
        maxPrices = new uint64[](pricesLength);
        for (uint256 i; i < pricesLength; ++i) {
            IERC20 market = IERC20(_marketPrices[i].unpackAddress(0));
            uint64 price = _marketPrices[i].unpackUint64(160);
            IPriceFeed.PriceFeedConfig memory cfg = readerState.marketManager.marketPriceFeedConfigs(market);
            if (address(cfg.refPriceFeed) == address(0)) {
                if (!ignoreReferencePriceFeedError) revert IPriceFeed.ReferencePriceFeedNotSet();
                minPrices[i] = price.toUint64();
                maxPrices[i] = price.toUint64();
                continue;
            }

            uint64 latestRefPrice = PriceFeedUtil.getReferencePrice(cfg, Constants.PRICE_DECIMALS);

            IPriceFeed.PricePack memory pack = readerState.marketManager.marketPricePacks(market);
            IPriceFeed.PriceDataItem memory dataItem = IPriceFeed.PriceDataItem({
                prevRound: pack.prevRound,
                prevRefPrice: pack.prevRefPrice,
                cumulativeRefPriceDelta: pack.cumulativePriceDelta,
                prevPrice: pack.prevPrice,
                cumulativePriceDelta: pack.cumulativePriceDelta
            });
            bool reachMaxDeltaDiff = PriceFeedUtil.calcNewPriceDataItem(
                dataItem,
                price,
                latestRefPrice,
                cfg.maxCumulativeDeltaDiff,
                cumulativeRoundDuration
            );

            (uint256 minPrice, uint256 maxPrice) = PriceFeedUtil.calcMinAndMaxPrice(
                price,
                latestRefPrice,
                maxDeviationRatio,
                reachMaxDeltaDiff
            );
            (minPrices[i], maxPrices[i]) = (minPrice.toUint64(), maxPrice.toUint64());
        }
        return (minPrices, maxPrices);
    }

    // The following methods are mock methods for calculation

    function PUSDManagerCallback(IERC20 _token, uint96 _payAmount, uint96, bytes calldata) external {
        require(msg.sender == address(this));
        readerState.mockState.totalSupply = _payAmount;

        if (address(_token) == PUSDManagerUtil.computePUSDAddress())
            PUSD(address(_token)).mint(address(this), _payAmount);
    }

    function transfer(address, uint256) external view returns (bool) {
        require(msg.sender == address(this));
        return true;
    }

    function balanceOf(address) external view returns (uint256) {
        return readerState.mockState.totalSupply;
    }

    function totalSupply() external view returns (uint256) {
        return readerState.mockState.totalSupply;
    }
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "../../core/interfaces/IMarketManager.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IReader {
    struct ReaderState {
        IMarketManager marketManager;
        MockState mockState;
    }

    struct MockState {
        IMarketManager.State state;
        IConfigurable.MarketConfig marketConfig;
        uint256 totalSupply;
    }

    /// @notice Calculate the price of the LP Token
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param indexPrice The index price of the market
    /// @return totalSupply The total supply of the LP Token
    /// @return liquidity The liquidity of the LP Token
    /// @return price The price of the LP Token
    function calcLPTPrice(
        IERC20 market,
        uint64 indexPrice
    ) external returns (uint256 totalSupply, uint128 liquidity, uint64 price);

    /// @notice Calculates the amount when user minting PUSD
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param amount When `exactIn` is true, it is the amount of token to pay,
    /// otherwise, it is the amount of PUSD to mint
    /// @param indexPrice The index price of the market
    /// @return payAmount The amount of market tokens to pay
    /// @return receiveAmount The amount of PUSD to receive
    function quoteMintPUSD(
        IERC20 market,
        bool exactIn,
        uint96 amount,
        uint64 indexPrice
    ) external returns (uint96 payAmount, uint64 receiveAmount);

    /// @notice Calculates the amount when user burning PUSD
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param amount When `exactIn` is true, it is the amount of PUSD to burn,
    /// otherwise, it is the amount of token to receive
    /// @param indexPrice The index price of the market
    /// @return payAmount The amount of PUSD to pay
    /// @return receiveAmount The amount of market tokens to receive
    function quoteBurnPUSD(
        IERC20 market,
        bool exactIn,
        uint96 amount,
        uint64 indexPrice
    ) external returns (uint64 payAmount, uint96 receiveAmount);

    /// @notice Calculates the amount of LPT tokens that can be minted by burning a given amount of PUSD
    /// @dev Uses the provided index price to determine the conversion rates
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param amountIn The amount of PUSD to be burned
    /// @param indexPrice The index price of the market
    /// @return burnPUSDReceiveAmount The amount of market tokens received after burning the provided PUSD
    /// @return mintLPTTokenValue The amount of LPT tokens minted using `burnPUSDReceiveAmount`
    function quoteBurnPUSDToMintLPT(
        IERC20 market,
        uint96 amountIn,
        uint64 indexPrice
    ) external returns (uint96 burnPUSDReceiveAmount, uint64 mintLPTTokenValue);

    /// @notice Calculates the amount of PUSD tokens minted when burning a given amount of LPT tokens
    /// @dev Uses the provided index price to determine the conversion rates
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param amountIn The amount of LPT tokens to be burned
    /// @param indexPrice The index price of the market
    /// @return burnLPTReceiveAmount The amount of market tokens received after burning the provided LPT tokens
    /// @return mintPUSDTokenValue The amount of PUSD tokens minted using `burnLPTReceiveAmount`
    function quoteBurnLPTToMintPUSD(
        IERC20 market,
        uint64 amountIn,
        uint64 indexPrice
    ) external returns (uint96 burnLPTReceiveAmount, uint64 mintPUSDTokenValue);

    /// @notice Calculates the results of burning PUSD to increase a position in a given market
    /// @dev Uses the provided index price and leverage to determine the conversion rates
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param account The owner of the position
    /// @param amountIn The amount of PUSD to be burned
    /// @param indexPrice The index price of the market
    /// @param leverage The leverage to be applied for this position increase operation,
    /// denominated in thousandths of a bip (i.e. 1e-7)
    /// @return burnPUSDReceiveAmount The amount of market tokens received after burning the provided PUSD
    /// @return size The position size to increase
    /// @return position The updated position after the operation
    function quoteBurnPUSDToIncreasePosition(
        IERC20 market,
        address account,
        uint64 amountIn,
        uint64 indexPrice,
        uint32 leverage
    ) external returns (uint96 burnPUSDReceiveAmount, uint96 size, IMarketPosition.Position memory position);

    /// @notice Calculates the results of decreasing a position to mint PUSD tokens in a given market
    /// @dev Uses the provided index price to determine the conversion rates and position changes
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param account The owner of the position
    /// @param size The size of the position to be decreased
    /// @param indexPrice The index price of the market
    /// @return decreasePositionReceiveAmount The amount of market tokens received after decreasing the position
    /// @return mintPUSDTokenValue The amount of PUSD tokens minted using `decreasePositionReceiveAmount`
    /// @return marginAfter The margin remaining in the position after the operation
    function quoteDecreasePositionToMintPUSD(
        IERC20 market,
        address account,
        uint96 size,
        uint64 indexPrice
    ) external returns (uint96 decreasePositionReceiveAmount, uint64 mintPUSDTokenValue, uint96 marginAfter);

    /// @notice Calculate the market tokens required to pay based on the increase position size
    /// @dev Uses the provided index price and leverage to determine the conversion rates
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param account The owner of the position
    /// @param size The size of the position to be increased
    /// @param leverage The leverage to be applied for this position increase operation,
    /// denominated in thousandths of a bip (i.e. 1e-7)
    /// @param indexPrice The index price of the market
    /// @return payAmount The amount of market tokens to pay
    /// @return marginAfter The adjusted margin
    /// @return spread The spread incurred by the position
    /// @return tradingFee The trading fee paid by the position
    /// @return liquidationPrice The liquidation price after increasing position
    function quoteIncreasePositionBySize(
        IERC20 market,
        address account,
        uint96 size,
        uint32 leverage,
        uint64 indexPrice
    )
        external
        returns (uint96 payAmount, uint96 marginAfter, uint96 spread, uint96 tradingFee, uint64 liquidationPrice);

    /// @notice Calculate min and max price if passed a specific price value
    /// @param marketPrices Array of market addresses and prices to update for
    /// @return minPrices The minimum price for each market
    /// @return maxPrices The maximum price for each market
    function calcPrices(
        PackedValue[] calldata marketPrices
    ) external view returns (uint64[] memory minPrices, uint64[] memory maxPrices);
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.8.26;

import "./interfaces/IPriceFeed.sol";
import "../libraries/PriceFeedUtil.sol";
import "../governance/GovernableUpgradeable.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";

abstract contract PriceFeedUpgradeable is IPriceFeed, GovernableUpgradeable {
    using SafeCast for *;

    /// @custom:storage-location erc7201:Purecash.storage.PriceFeedUpgradeable
    struct PriceFeedStorage {
        /// @dev Ignore if reference price feed is not settled.
        bool ignoreReferencePriceFeedError;
        /// @dev Maximum deviation ratio between price and ChainLink price.
        uint24 maxDeviationRatio;
        /// @dev Period for calculating cumulative deviation ratio.
        uint32 cumulativeRoundDuration;
        /// @dev The timeout for price update transactions.
        uint32 updateTxTimeout;
        /// @dev The price updater address
        address updater;
        /// @dev Market price config
        mapping(IERC20 market => PriceFeedConfig) priceFeedConfigs;
        /// @dev Latest price
        mapping(IERC20 market => PricePack) latestPrices;
    }

    // keccak256(abi.encode(uint256(keccak256("Purecash.storage.PriceFeedUpgradeable")) - 1))
    // & ~bytes32(uint256(0xff))
    bytes32 private constant PRICE_FEED_UPGRADEABLE_STORAGE =
        0x58a0c8f0f88cec20fbd92b7b52b0d2d1fcf9b126fb78d3cc170d4a02c5be0900;

    function __PriceFeed_init(bool _ignoreReferencePriceFeedError, address _initialGov) internal onlyInitializing {
        __PriceFeed_init_unchained(_ignoreReferencePriceFeedError);
        __Governable_init(_initialGov);
    }

    function __PriceFeed_init_unchained(bool _ignoreReferencePriceFeedError) internal onlyInitializing {
        PriceFeedStorage storage $ = _priceFeedStorage();
        ($.maxDeviationRatio, $.cumulativeRoundDuration, $.updateTxTimeout) = (100e3, 1 minutes, 1 minutes);
        $.ignoreReferencePriceFeedError = _ignoreReferencePriceFeedError;
    }

    /// @inheritdoc IPriceFeed
    function updatePrice(PackedValue _packedValue) external override {
        PriceFeedStorage storage $ = _priceFeedStorage();
        if (msg.sender != $.updater) revert Forbidden();
        IERC20 _market = IERC20(_packedValue.unpackAddress(0));
        uint64 price = _packedValue.unpackUint64(160);
        uint32 timestamp = _packedValue.unpackUint32(224);
        PricePack storage pack = $.latestPrices[_market];
        if (!_updateMarketLastUpdated(pack, timestamp, $.updateTxTimeout)) return;
        PriceFeedConfig memory cfg = $.priceFeedConfigs[_market];
        if (address(cfg.refPriceFeed) == address(0)) {
            if (!$.ignoreReferencePriceFeedError) revert ReferencePriceFeedNotSet();
            pack.minPrice = price;
            pack.maxPrice = price;
            emit PriceUpdated(_market, price, price, price);
            return;
        }

        uint64 latestRefPrice = PriceFeedUtil.getReferencePrice(cfg, Constants.PRICE_DECIMALS);
        PriceDataItem memory dataItem = PriceDataItem({
            prevRound: pack.prevRound,
            prevRefPrice: pack.prevRefPrice,
            cumulativeRefPriceDelta: pack.cumulativeRefPriceDelta,
            prevPrice: pack.prevPrice,
            cumulativePriceDelta: pack.cumulativePriceDelta
        });
        bool reachMaxDeltaDiff = PriceFeedUtil.calcNewPriceDataItem(
            dataItem,
            price,
            latestRefPrice,
            cfg.maxCumulativeDeltaDiff,
            $.cumulativeRoundDuration
        );
        pack.prevRound = dataItem.prevRound;
        pack.prevRefPrice = dataItem.prevRefPrice;
        pack.cumulativeRefPriceDelta = dataItem.cumulativeRefPriceDelta;
        pack.prevPrice = dataItem.prevPrice;
        pack.cumulativePriceDelta = dataItem.cumulativePriceDelta;

        if (reachMaxDeltaDiff)
            emit MaxCumulativeDeltaDiffExceeded(
                _market,
                price,
                latestRefPrice,
                dataItem.cumulativePriceDelta,
                dataItem.cumulativeRefPriceDelta
            );
        (uint64 minPrice, uint64 maxPrice) = PriceFeedUtil.calcMinAndMaxPrice(
            price,
            latestRefPrice,
            $.maxDeviationRatio,
            reachMaxDeltaDiff
        );
        pack.minPrice = minPrice;
        pack.maxPrice = maxPrice;
        emit PriceUpdated(_market, price, minPrice, maxPrice);
    }

    /// @inheritdoc IPriceFeed
    function getPrice(IERC20 _market) external view override returns (uint64 minPrice, uint64 maxPrice) {
        (minPrice, maxPrice) = _getPrice(_market);
    }

    /// @inheritdoc IPriceFeed
    function updateUpdater(address _account) external override onlyGov {
        _priceFeedStorage().updater = _account;
    }

    /// @inheritdoc IPriceFeed
    function isUpdater(address _account) external view override returns (bool active) {
        return _priceFeedStorage().updater == _account;
    }

    /// @inheritdoc IPriceFeed
    function updateGlobalPriceFeedConfig(
        uint24 _maxDeviationRatio,
        uint32 _cumulativeRoundDuration,
        uint32 _updateTxTimeout,
        bool _ignoreReferencePriceFeedError
    ) external override onlyGov {
        PriceFeedStorage storage $ = _priceFeedStorage();
        ($.maxDeviationRatio, $.cumulativeRoundDuration, $.updateTxTimeout, $.ignoreReferencePriceFeedError) = (
            _maxDeviationRatio,
            _cumulativeRoundDuration,
            _updateTxTimeout,
            _ignoreReferencePriceFeedError
        );
    }

    /// @inheritdoc IPriceFeed
    function globalPriceFeedConfig()
        external
        view
        override
        returns (
            uint24 maxDeviationRatio,
            uint32 cumulativeRoundDuration,
            uint32 updateTxTimeout,
            bool ignoreReferencePriceFeedError
        )
    {
        PriceFeedStorage storage $ = _priceFeedStorage();
        return ($.maxDeviationRatio, $.cumulativeRoundDuration, $.updateTxTimeout, $.ignoreReferencePriceFeedError);
    }

    /// @inheritdoc IPriceFeed
    function updateMarketPriceFeedConfig(
        IERC20 _market,
        IChainLinkAggregator _priceFeed,
        uint32 _refHeartBeatDuration,
        uint48 _maxCumulativeDeltaDiff
    ) external override onlyGov {
        uint8 refPriceDecimals;
        if (address(_priceFeed) != address(0x0)) refPriceDecimals = _priceFeed.decimals();
        _priceFeedStorage().priceFeedConfigs[_market] = PriceFeedConfig({
            refPriceFeed: _priceFeed,
            refHeartbeatDuration: _refHeartBeatDuration,
            maxCumulativeDeltaDiff: _maxCumulativeDeltaDiff,
            refPriceDecimals: refPriceDecimals
        });
    }

    /// @inheritdoc IPriceFeed
    function marketPriceFeedConfigs(IERC20 _market) external view override returns (PriceFeedConfig memory config) {
        config = _priceFeedStorage().priceFeedConfigs[_market];
    }

    /// @inheritdoc IPriceFeed
    function marketPricePacks(IERC20 _market) external view override returns (PricePack memory pack) {
        pack = _priceFeedStorage().latestPrices[_market];
        return pack;
    }

    function _getPrice(IERC20 _market) internal view returns (uint64 minPrice, uint64 maxPrice) {
        PricePack storage price = _priceFeedStorage().latestPrices[_market];
        (minPrice, maxPrice) = (price.minPrice, price.maxPrice);
        if (minPrice | maxPrice == 0) revert NotInitialized();
    }

    function _getMinPrice(IERC20 _market) internal view returns (uint64 minPrice) {
        minPrice = _priceFeedStorage().latestPrices[_market].minPrice;
        if (minPrice == 0) revert NotInitialized();
    }

    function _getMaxPrice(IERC20 _market) internal view returns (uint64 maxPrice) {
        maxPrice = _priceFeedStorage().latestPrices[_market].maxPrice;
        if (maxPrice == 0) revert NotInitialized();
    }

    function _updateMarketLastUpdated(
        PricePack storage _latestPrice,
        uint32 _timestamp,
        uint32 _updateTxTimeout
    ) internal returns (bool) {
        // Execution delay may cause the update time to be out of order.
        if (_timestamp <= _latestPrice.updateTimestamp) return false;

        // timeout and revert
        if (_timestamp >= block.timestamp + _updateTxTimeout) revert InvalidUpdateTimestamp(_timestamp);

        _latestPrice.updateTimestamp = _timestamp;
        return true;
    }

    function _priceFeedStorage() internal pure returns (PriceFeedStorage storage $) {
        // prettier-ignore
        assembly { $.slot := PRICE_FEED_UPGRADEABLE_STORAGE }
    }
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

interface IChainLinkAggregator {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    // getRoundData and latestRoundData should both raise "No data present"
    // if they do not have data to report, instead of returning unset values
    // which could be misinterpreted as actual reported values.
    function getRoundData(
        uint80 _roundId
    )
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);

    function latestRoundData()
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "./IChainLinkAggregator.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "../../types/PackedValue.sol";

interface IPriceFeed {
    struct PriceFeedConfig {
        /// @notice ChainLink contract address for corresponding market
        IChainLinkAggregator refPriceFeed;
        /// @notice Expected update interval of chain link price feed
        uint32 refHeartbeatDuration;
        /// @notice Maximum cumulative change ratio difference between prices and ChainLink price
        /// within a period of time.
        uint48 maxCumulativeDeltaDiff;
        /// @notice Decimals of ChainLink price
        uint8 refPriceDecimals;
    }

    struct PriceDataItem {
        /// @notice previous round id
        uint32 prevRound;
        /// @notice previous ChainLink price
        uint64 prevRefPrice;
        /// @notice cumulative value of the ChainLink price change ratio in a round
        uint64 cumulativeRefPriceDelta;
        /// @notice previous market price
        uint64 prevPrice;
        /// @notice cumulative value of the market price change ratio in a round
        uint64 cumulativePriceDelta;
    }

    struct PricePack {
        /// @notice The timestamp when updater uploads the price
        uint32 updateTimestamp;
        /// @notice Calculated maximum price
        uint64 maxPrice;
        /// @notice Calculated minimum price
        uint64 minPrice;
        /// @notice previous round id
        uint32 prevRound;
        /// @notice previous ChainLink price
        uint64 prevRefPrice;
        /// @notice cumulative value of the ChainLink price change ratio in a round
        uint64 cumulativeRefPriceDelta;
        /// @notice previous market price
        uint64 prevPrice;
        /// @notice cumulative value of the market price change ratio in a round
        uint64 cumulativePriceDelta;
    }

    /// @notice Emitted when market price updated
    /// @param market Market address
    /// @param price The price passed in by updater
    /// @param maxPrice Calculated maximum price
    /// @param minPrice Calculated minimum price
    event PriceUpdated(IERC20 indexed market, uint64 price, uint64 minPrice, uint64 maxPrice);

    /// @notice Emitted when maxCumulativeDeltaDiff exceeded
    /// @param market Market address
    /// @param price The price passed in by updater
    /// @param refPrice The price provided by ChainLink
    /// @param cumulativeDelta The cumulative value of the price change ratio
    /// @param cumulativeRefDelta The cumulative value of the ChainLink price change ratio
    event MaxCumulativeDeltaDiffExceeded(
        IERC20 indexed market,
        uint64 price,
        uint64 refPrice,
        uint64 cumulativeDelta,
        uint64 cumulativeRefDelta
    );

    /// @notice Price not be initialized
    error NotInitialized();

    /// @notice Reference price feed not set
    error ReferencePriceFeedNotSet();

    /// @notice Invalid reference price
    /// @param referencePrice Reference price
    error InvalidReferencePrice(int256 referencePrice);

    /// @notice Reference price timeout
    /// @param elapsed The time elapsed since the last price update.
    error ReferencePriceTimeout(uint256 elapsed);

    /// @notice Invalid update timestamp
    /// @param timestamp Update timestamp
    error InvalidUpdateTimestamp(uint32 timestamp);

    /// @notice Update market price feed config
    /// @param market Market address
    /// @param priceFeed ChainLink price feed
    /// @param refHeartBeatDuration Expected update interval of chain link price feed
    /// @param maxCumulativeDeltaDiff Maximum cumulative change ratio difference between prices and ChainLink price
    function updateMarketPriceFeedConfig(
        IERC20 market,
        IChainLinkAggregator priceFeed,
        uint32 refHeartBeatDuration,
        uint48 maxCumulativeDeltaDiff
    ) external;

    /// @notice Get market price feed config
    /// @param market Market address
    /// @return config The price feed config
    function marketPriceFeedConfigs(IERC20 market) external view returns (PriceFeedConfig memory config);

    /// @notice update global price feed config
    /// @param maxDeviationRatio Maximum deviation ratio between ChainLink price and market price
    /// @param cumulativeRoundDuration The duration of the round for the cumulative value of the price change ratio
    /// @param updateTxTimeout The maximum time allowed for the transaction to update the price
    /// @param ignoreReferencePriceFeedError Whether to ignore the error of the reference price feed not settled
    function updateGlobalPriceFeedConfig(
        uint24 maxDeviationRatio,
        uint32 cumulativeRoundDuration,
        uint32 updateTxTimeout,
        bool ignoreReferencePriceFeedError
    ) external;

    /// @notice Get global price feed config
    /// @return maxDeviationRatio Maximum deviation ratio between ChainLink price and market price
    /// @return cumulativeRoundDuration The duration of the round for the cumulative value of the price change ratio
    /// @return updateTxTimeout The maximum time allowed for the transaction to update the price
    /// @return ignoreReferencePriceFeedError Whether to ignore the error of the reference price feed not settled
    function globalPriceFeedConfig()
        external
        view
        returns (
            uint24 maxDeviationRatio,
            uint32 cumulativeRoundDuration,
            uint32 updateTxTimeout,
            bool ignoreReferencePriceFeedError
        );

    /// @notice Update updater
    /// @param account The account to set
    function updateUpdater(address account) external;

    /// @notice Get market price
    /// @param market Market address
    /// @return minPrice Minimum price
    /// @return maxPrice Maximum price
    function getPrice(IERC20 market) external view returns (uint64 minPrice, uint64 maxPrice);

    /// @notice Check if the account is updater
    /// @param account The account to check
    /// @return active True if the account is updater
    function isUpdater(address account) external view returns (bool active);

    /// @notice Update market price
    /// @param packedValue The packed values of the order index and require success flag: bit 0-159 represent
    /// market address, bit 160-223 represent the price and bit 223-255 represent the update timestamp
    function updatePrice(PackedValue packedValue) external;

    /// @notice Get market price data packed data
    /// @param market Market address
    /// @return pack The price packed data
    function marketPricePacks(IERC20 market) external view returns (PricePack memory pack);
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.8.26;

import "./interfaces/IBalanceRateBalancer.sol";
import "./PositionRouterCommon.sol";
import "./interfaces/IDirectExecutablePlugin.sol";

contract BalanceRateBalancer is IBalanceRateBalancer, PositionRouterCommon {
    IDirectExecutablePlugin public immutable plugin;

    struct SwapCallbackData {
        IERC20 collateral;
        address[] targets;
        bytes[] calldatas;
    }

    constructor(
        Governable _govImpl,
        IMarketManager _marketManager,
        IDirectExecutablePlugin _plugin,
        EstimatedGasLimitType[] memory _estimatedGasLimitTypes,
        uint256[] memory _estimatedGasLimits
    )
        PositionRouterCommon(
            _govImpl,
            _marketManager,
            IWETHMinimum(address(0)),
            _estimatedGasLimitTypes,
            _estimatedGasLimits
        )
    {
        plugin = _plugin;
    }

    function createIncreaseBalanceRate(
        IERC20 _market,
        IERC20 _collateral,
        uint96 _amount,
        address[] calldata _targets,
        bytes[] calldata _calldatas
    ) public payable onlyGov returns (bytes32 id) {
        uint256 minExecutionFee = _estimateGasFees(EstimatedGasLimitType.IncreaseBalanceRate);
        if (msg.value < minExecutionFee) revert InsufficientExecutionFee(msg.value, minExecutionFee);
        if (_targets.length != _calldatas.length) revert InvalidCallbackData();

        id = _createIncreaseBalanceRate(
            IncreaseBalanceRateRequestIdParam({
                market: _market,
                collateral: _collateral,
                amount: _amount,
                executionFee: msg.value,
                account: msg.sender,
                targets: _targets,
                calldatas: _calldatas
            })
        );
    }

    function cancelIncreaseBalanceRate(
        IncreaseBalanceRateRequestIdParam calldata _param,
        address payable _executionFeeReceiver
    ) public onlyPositionExecutor returns (bool) {
        bytes32 id = _increaseBalanceRateId(_param);
        uint256 blockNumber = blockNumbers[id];
        if (blockNumber == 0) return true;

        bool shouldCancel = _shouldCancel(blockNumber, _param.account);
        if (!shouldCancel) return false;

        delete blockNumbers[id];

        _transferOutETH(_param.executionFee, _executionFeeReceiver);
        emit IncreaseBalanceRateCancelled(id, _executionFeeReceiver);

        return true;
    }

    function executeIncreaseBalanceRate(
        IncreaseBalanceRateRequestIdParam calldata _param,
        address payable _executionFeeReceiver
    ) public onlyPositionExecutor returns (bool) {
        bytes32 id = _increaseBalanceRateId(_param);
        uint256 blockNumber = blockNumbers[id];
        if (blockNumber == 0) return true;

        bool shouldExecute = _shouldExecute(blockNumber, _param.account);
        if (!shouldExecute) return false;

        delete blockNumbers[id];

        uint256 executionGasLimit_ = executionGasLimit;
        marketManager.burnPUSD{gas: executionGasLimit_}(
            _param.market,
            true,
            _param.amount,
            this,
            abi.encode(
                SwapCallbackData({targets: _param.targets, calldatas: _param.calldatas, collateral: _param.collateral})
            ),
            address(this)
        );

        uint256 actualExecutionFee = _refundExecutionFee(
            EstimatedGasLimitType.IncreaseBalanceRate,
            _param.executionFee,
            _param.account
        );
        _transferOutETH(actualExecutionFee, _executionFeeReceiver);

        emit IncreaseBalanceRateExecuted(id, _executionFeeReceiver, actualExecutionFee);
        return true;
    }

    function executeOrCancelIncreaseBalanceRate(
        IncreaseBalanceRateRequestIdParam calldata _param,
        bool _shouldCancelOnFail,
        address payable _executionFeeReceiver
    ) public onlyPositionExecutor {
        try this.executeIncreaseBalanceRate(_param, _executionFeeReceiver) returns (bool _executed) {
            if (!_executed) return;
        } catch (bytes memory reason) {
            bytes4 errorTypeSelector = _decodeShortenedReason(reason);
            bytes32 id = _increaseBalanceRateId(_param);
            emit ExecuteFailed(id, errorTypeSelector);

            if (_shouldCancelOnFail) {
                try this.cancelIncreaseBalanceRate(_param, _executionFeeReceiver) returns (bool _cancelled) {
                    if (!_cancelled) return;
                } catch {}
            }
        }
    }

    function PUSDManagerCallback(
        IERC20 /* _payToken */,
        // burn pusd amount
        uint96 _payAmount,
        uint96 /* _receiveAmount */,
        bytes calldata _data
    ) external override(PositionRouterCommon, IPUSDManagerCallback) {
        if (msg.sender != address(marketManager)) revert InvalidCaller(msg.sender);

        /**
        e.g. call PUSDManagerCallback, exchange from market token to pusd by curve exchange
        step1. approve market token to curve: calldatas[0] => abi.encodeWithSelector(IERC20.approve.selector, curve address, amount)
        // exchange(_route: address[], _swap_params: uint256[][], _amount: uint256, _min_dy: uint256, _pools: address[]=empty(address[]), _receiver: address=msg.sender)
        step2. swap: calldatas[1] => abi.encodeWithSelector(ICurve.exchange.selector, params)
        step3. approve dai to marketManager(optional): calldatas[2] => abi.encodeWithSelector(IERC20.approve.selector, marketManager address, amount)
        */
        SwapCallbackData memory data = abi.decode(_data, (SwapCallbackData));
        for (uint256 i; i < data.targets.length; i++) {
            Address.functionCall(data.targets[i], data.calldatas[i]);
        }
        plugin.psmMintPUSD(
            data.collateral,
            PositionUtil.calcMarketTokenValue(
                _payAmount,
                Constants.PRICE_1,
                marketManager.psmCollateralStates(data.collateral).decimals
            ),
            address(marketManager),
            ""
        );
    }

    function _createIncreaseBalanceRate(IncreaseBalanceRateRequestIdParam memory _param) private returns (bytes32 id) {
        id = _increaseBalanceRateId(_param);
        _validateRequestConflict(id);
        blockNumbers[id] = block.number;

        emit IncreaseBalanceRateCreated(
            _param.market,
            _param.collateral,
            _param.amount,
            _param.executionFee,
            _param.account,
            _param.targets,
            _param.calldatas,
            id
        );
    }

    function _increaseBalanceRateId(IncreaseBalanceRateRequestIdParam memory _param) private pure returns (bytes32 id) {
        return keccak256(abi.encode(_param));
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.8.26;

import "../IWETHMinimum.sol";
import "../libraries/MarketUtil.sol";
import "../libraries/PUSDManagerUtil.sol";
import "../governance/GovernableProxy.sol";
import "./interfaces/IDirectExecutablePlugin.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract DirectExecutablePlugin is IDirectExecutablePlugin, GovernableProxy {
    using MarketUtil for *;

    IMarketManager public immutable marketManager;
    IWETHMinimum public immutable weth;

    mapping(address => bool) public override psmMinters;
    mapping(address => bool) public override liquidityBufferDebtPayers;
    bool public override allowAnyoneRepayLiquidityBufferDebt;
    bool public override allowAnyoneUsePSM;

    /// @notice Used to receive ETH withdrawal from the WETH contract
    receive() external payable {
        if (msg.sender != address(weth)) revert IMarketErrors.InvalidCaller(address(weth));
    }

    constructor(Governable _govImpl, IMarketManager _marketManager, IWETHMinimum _weth) GovernableProxy(_govImpl) {
        (marketManager, weth) = (_marketManager, _weth);
    }

    /// @inheritdoc IDirectExecutablePlugin
    function updateLiquidityBufferDebtPayer(address _account, bool _active) external override onlyGov {
        liquidityBufferDebtPayers[_account] = _active;
        emit LiquidityBufferDebtPayerUpdated(_account, _active);
    }

    /// @inheritdoc IDirectExecutablePlugin
    function updateAllowAnyoneRepayLiquidityBufferDebt(bool _allowed) external override onlyGov {
        allowAnyoneRepayLiquidityBufferDebt = _allowed;
    }

    /// @inheritdoc IDirectExecutablePlugin
    function updatePSMMinters(address _account, bool _active) external override onlyGov {
        psmMinters[_account] = _active;
        emit PSMMinterUpdated(_account, _active);
    }

    /// @inheritdoc IDirectExecutablePlugin
    function updateAllowAnyoneUsePSM(bool _allowed) external override onlyGov {
        allowAnyoneUsePSM = _allowed;
    }

    /// @inheritdoc IDirectExecutablePlugin
    function repayLiquidityBufferDebt(
        IERC20 _market,
        uint128 _amount,
        address _receiver,
        bytes calldata _permitData
    ) external override {
        require(liquidityBufferDebtPayers[msg.sender] || allowAnyoneRepayLiquidityBufferDebt, Forbidden());

        IPUSD usd = IPUSD(PUSDManagerUtil.computePUSDAddress(address(marketManager)));
        IMarketManager.LiquidityBufferModule memory lbm = marketManager.liquidityBufferModules(_market);

        uint256 balance = usd.balanceOf(address(marketManager));
        if (_amount > 0 && balance + _amount > lbm.pusdDebt) revert TooMuchRepaid(balance, _amount, lbm.pusdDebt);
        usd.safePermit(address(marketManager), _permitData);
        marketManager.pluginTransfer(usd, msg.sender, address(marketManager), _amount);

        if (address(weth) == address(_market) && !MarketUtil.isDeployedContract(_receiver)) {
            uint128 receiveAmount = marketManager.repayLiquidityBufferDebt(_market, msg.sender, address(this));

            weth.withdraw(receiveAmount);
            Address.sendValue(payable(_receiver), receiveAmount);
        } else {
            marketManager.repayLiquidityBufferDebt(_market, msg.sender, _receiver);
        }
    }

    /// @inheritdoc IDirectExecutablePlugin
    function psmMintPUSD(
        IERC20 _collateral,
        uint120 _amount,
        address _receiver,
        bytes calldata _permitData
    ) external override returns (uint64 receiveAmount) {
        require(psmMinters[msg.sender] || allowAnyoneUsePSM, Forbidden());

        IPSM.CollateralState memory state = marketManager.psmCollateralStates(_collateral);

        uint256 balance = _collateral.balanceOf(address(marketManager));
        if (_amount > 0 && balance + _amount > state.cap) revert PSMCapExceeded(balance, _amount, state.cap);

        _collateral.safePermit(address(marketManager), _permitData);
        marketManager.pluginTransfer(_collateral, msg.sender, address(marketManager), _amount);
        receiveAmount = marketManager.psmMintPUSD(_collateral, _receiver);
    }

    /// @inheritdoc IDirectExecutablePlugin
    function psmBurnPUSD(
        IERC20 _collateral,
        uint64 _amount,
        address _receiver,
        bytes calldata _permitData
    ) external override returns (uint96 receiveAmount) {
        IERC20 usd = IERC20(PUSDManagerUtil.computePUSDAddress(address(marketManager)));
        usd.safePermit(address(marketManager), _permitData);
        marketManager.pluginTransfer(usd, msg.sender, address(marketManager), _amount);
        receiveAmount = marketManager.psmBurnPUSD(_collateral, _receiver);
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.8.26;

import "../core/MarketManagerUpgradeable.sol";
import "./interfaces/ILiquidator.sol";
import "../governance/GovernableProxy.sol";

contract Liquidator is ILiquidator, GovernableProxy {
    using SafeERC20 for IERC20;

    MarketManagerUpgradeable public immutable marketManager;

    uint256 public executionGasLimit;

    mapping(address => bool) public executors;

    constructor(Governable _govImpl, MarketManagerUpgradeable _marketManager) GovernableProxy(_govImpl) {
        (marketManager, executionGasLimit) = (_marketManager, 1_000_000 wei);
    }

    /// @inheritdoc ILiquidator
    function updateExecutor(address _account, bool _active) external override onlyGov {
        executors[_account] = _active;
        emit ExecutorUpdated(_account, _active);
    }

    /// @inheritdoc ILiquidator
    function updateExecutionGasLimit(uint256 _executionGasLimit) external override onlyGov {
        executionGasLimit = _executionGasLimit;
    }

    /// @inheritdoc ILiquidator
    function liquidatePosition(
        IERC20 _market,
        address payable _account,
        address payable _feeReceiver
    ) external override {
        _onlyExecutor();

        marketManager.liquidatePosition(_market, _account, _feeReceiver);
    }

    function _onlyExecutor() private view {
        if (!executors[msg.sender]) revert Forbidden();
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.8.26;

import "../governance/GovernableUpgradeable.sol";
import "./interfaces/IPluginManager.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

abstract contract PluginManagerUpgradeable is IPluginManager, GovernableUpgradeable {
    /// @custom:storage-location erc7201:Purecash.storage.PluginManagerUpgradeable
    struct PluginManagerStorage {
        mapping(address plugin => bool) activePlugins;
    }

    // keccak256(abi.encode(uint256(keccak256("Purecash.storage.PluginManagerUpgradeable")) - 1))
    // & ~bytes32(uint256(0xff))
    bytes32 private constant PLUGIN_MANAGER_UPGRADEABLE_STORAGE =
        0xbb40e86f68fafb11efed99ac959fcf9a51deeafbf5b56a45f87ae418cc6eb300;

    function __PluginManager_init(address _initialGov) internal onlyInitializing {
        __PluginManager_init_unchained();
        __Governable_init(_initialGov);
    }

    function __PluginManager_init_unchained() internal onlyInitializing {}

    /// @inheritdoc IPluginManager
    function updatePlugin(address _plugin, bool _active) external override onlyGov {
        PluginManagerStorage storage $ = _pluginManagerStorage();

        $.activePlugins[_plugin] = _active;

        emit PluginUpdated(_plugin, _active);
    }

    /// @inheritdoc IPluginManager
    function activePlugins(address _plugin) public view override returns (bool active) {
        active = _pluginManagerStorage().activePlugins[_plugin];
    }

    /// @inheritdoc IPluginManager
    function pluginTransfer(IERC20 _token, address _from, address _to, uint256 _amount) external override {
        _onlyPlugin();
        SafeERC20.safeTransferFrom(_token, _from, _to, _amount);
    }

    function _onlyPlugin() internal view {
        require(_pluginManagerStorage().activePlugins[msg.sender], PluginInactive(msg.sender));
    }

    function _pluginManagerStorage() internal pure returns (PluginManagerStorage storage $) {
        // prettier-ignore
        assembly { $.slot := PLUGIN_MANAGER_UPGRADEABLE_STORAGE }
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.8.26;

import "./PositionRouterCommon.sol";
import "./interfaces/IPositionRouter.sol";
import {LONG, SHORT} from "../types/Side.sol";
import {M as Math} from "../libraries/Math.sol";

contract PositionRouter is IPositionRouter, PositionRouterCommon {
    using SafeCast for uint256;
    using TransferHelper for *;
    using MarketUtil for *;

    constructor(
        Governable _govImpl,
        IMarketManager _marketManager,
        IWETHMinimum _weth,
        EstimatedGasLimitType[] memory _estimatedGasLimitTypes,
        uint256[] memory _estimatedGasLimits
    ) PositionRouterCommon(_govImpl, _marketManager, _weth, _estimatedGasLimitTypes, _estimatedGasLimits) {}

    /// @inheritdoc IPositionRouter
    function createIncreasePosition(
        IERC20 _market,
        uint96 _marginDelta,
        uint96 _sizeDelta,
        uint64 _acceptableIndexPrice,
        bytes calldata _permitData
    ) external payable override returns (bytes32 id) {
        uint256 minExecutionFee = _estimateGasFees(EstimatedGasLimitType.IncreasePosition);
        if (msg.value < minExecutionFee) revert InsufficientExecutionFee(msg.value, minExecutionFee);

        _market.safePermit(address(marketManager), _permitData);
        if (_marginDelta > 0) marketManager.pluginTransfer(_market, msg.sender, address(this), _marginDelta);

        id = _createIncreasePosition(
            IncreasePositionRequestIdParam({
                account: msg.sender,
                market: _market,
                marginDelta: _marginDelta,
                sizeDelta: _sizeDelta,
                acceptableIndexPrice: _acceptableIndexPrice,
                executionFee: msg.value,
                payPUSD: false
            })
        );
    }

    /// @inheritdoc IPositionRouter
    function createIncreasePositionETH(
        uint96 _sizeDelta,
        uint64 _acceptableIndexPrice,
        uint256 _executionFee
    ) external payable override returns (bytes32 id) {
        unchecked {
            _validateExecutionFee(_executionFee, EstimatedGasLimitType.IncreasePosition);

            uint96 marginDelta = (msg.value - _executionFee).toUint96();

            if (marginDelta > 0) weth.deposit{value: marginDelta}();

            id = _createIncreasePosition(
                IncreasePositionRequestIdParam({
                    account: msg.sender,
                    market: IERC20(address(weth)),
                    marginDelta: marginDelta,
                    sizeDelta: _sizeDelta,
                    acceptableIndexPrice: _acceptableIndexPrice,
                    executionFee: _executionFee,
                    payPUSD: false
                })
            );
        }
    }

    /// @inheritdoc IPositionRouter
    function createIncreasePositionPayPUSD(
        IERC20 _market,
        uint64 _pusdAmount,
        uint96 _sizeDelta,
        uint64 _acceptableIndexPrice,
        bytes calldata _permitData
    ) external payable override returns (bytes32 id) {
        uint256 minExecutionFee = _estimateGasFees(EstimatedGasLimitType.IncreasePositionPayPUSD);
        if (msg.value < minExecutionFee) revert InsufficientExecutionFee(msg.value, minExecutionFee);

        IERC20 usd = IERC20(PUSDManagerUtil.computePUSDAddress(address(marketManager)));
        usd.safePermit(address(marketManager), _permitData);
        if (_pusdAmount > 0) marketManager.pluginTransfer(usd, msg.sender, address(this), _pusdAmount);

        id = _createIncreasePosition(
            IncreasePositionRequestIdParam({
                account: msg.sender,
                market: _market,
                marginDelta: _pusdAmount,
                sizeDelta: _sizeDelta,
                acceptableIndexPrice: _acceptableIndexPrice,
                executionFee: msg.value,
                payPUSD: true
            })
        );
    }

    /// @inheritdoc IPositionRouter
    function cancelIncreasePosition(
        IncreasePositionRequestIdParam calldata _param,
        address payable _executionFeeReceiver
    ) external override returns (bool) {
        bytes32 id = _increasePositionRequestId(_param);
        uint256 blockNumber = blockNumbers[id];
        if (blockNumber == 0) return true;

        bool shouldCancel = _shouldCancel(blockNumber, _param.account);
        if (!shouldCancel) return false;

        delete blockNumbers[id];

        if (_param.payPUSD) {
            IERC20 usd = IERC20(PUSDManagerUtil.computePUSDAddress(address(marketManager)));
            usd.safeTransfer(_param.account, _param.marginDelta);
        } else {
            _transferRefund(_param.market, _param.account, _param.marginDelta);
        }

        // transfer out execution fee
        _transferOutETH(_param.executionFee, _executionFeeReceiver);

        emit IncreasePositionCancelled(id, _executionFeeReceiver);

        return true;
    }

    /// @inheritdoc IPositionRouter
    function executeIncreasePosition(
        IncreasePositionRequestIdParam calldata _param,
        address payable _executionFeeReceiver
    ) external override returns (bool) {
        bytes32 id = _increasePositionRequestId(_param);
        uint256 blockNumber = blockNumbers[id];
        if (blockNumber == 0) return true;

        bool shouldExecute = _shouldExecute(blockNumber, _param.account);
        if (!shouldExecute) return false;

        delete blockNumbers[id];

        (, uint64 maxIndexPrice) = marketManager.getPrice(_param.market);
        _validateIndexPrice(LONG, maxIndexPrice, _param.acceptableIndexPrice);

        uint256 executionGasLimit_ = executionGasLimit;
        uint96 _marginDelta = _param.marginDelta;
        if (_param.payPUSD) {
            (, uint96 receiveAmount) = marketManager.burnPUSD{gas: executionGasLimit_}(
                _param.market,
                true,
                _param.marginDelta,
                this,
                abi.encode(CallbackData({margin: _param.marginDelta, account: _param.account})),
                address(this)
            );
            _marginDelta = receiveAmount;
        }

        _param.market.safeTransfer(address(marketManager), _marginDelta, executionGasLimit_);
        marketManager.increasePosition{gas: executionGasLimit_}(_param.market, _param.account, _param.sizeDelta);

        uint256 actualExecutionFee = _refundExecutionFee(
            _param.payPUSD ? EstimatedGasLimitType.IncreasePositionPayPUSD : EstimatedGasLimitType.IncreasePosition,
            _param.executionFee,
            _param.account
        );
        _transferOutETH(actualExecutionFee, _executionFeeReceiver);

        emit IncreasePositionExecuted(id, _executionFeeReceiver, actualExecutionFee);
        return true;
    }

    /// @inheritdoc IPositionRouter
    function executeOrCancelIncreasePosition(
        IncreasePositionRequestIdParam calldata _param,
        address payable _executionFeeReceiver
    ) external override onlyPositionExecutor {
        try this.executeIncreasePosition(_param, _executionFeeReceiver) returns (bool _executed) {
            if (!_executed) return;
        } catch (bytes memory reason) {
            bytes4 errorTypeSelector = _decodeShortenedReason(reason);
            bytes32 id = _increasePositionRequestId(_param);
            emit ExecuteFailed(RequestType.IncreasePosition, id, errorTypeSelector);

            try this.cancelIncreasePosition(_param, _executionFeeReceiver) returns (bool _cancelled) {
                if (!_cancelled) return;
            } catch {}
        }
    }

    /// @inheritdoc IPositionRouter
    function createDecreasePosition(
        IERC20 _market,
        uint96 _marginDelta,
        uint96 _sizeDelta,
        uint64 _acceptableIndexPrice,
        address payable _receiver
    ) external payable override returns (bytes32 id) {
        uint256 minExecutionFee = _estimateGasFees(EstimatedGasLimitType.DecreasePosition);
        if (msg.value < minExecutionFee) revert InsufficientExecutionFee(msg.value, minExecutionFee);

        id = _createDecreasePosition(
            DecreasePositionRequestIdParam({
                account: msg.sender,
                market: _market,
                marginDelta: _marginDelta,
                sizeDelta: _sizeDelta,
                acceptableIndexPrice: _acceptableIndexPrice,
                receiver: _receiver,
                executionFee: msg.value,
                receivePUSD: false
            })
        );
    }

    function createDecreasePositionReceivePUSD(
        IERC20 _market,
        uint96 _marginDelta,
        uint96 _sizeDelta,
        uint64 _acceptableIndexPrice,
        address _receiver
    ) external payable override returns (bytes32 id) {
        uint256 minExecutionFee = _estimateGasFees(EstimatedGasLimitType.DecreasePositionReceivePUSD);
        if (msg.value < minExecutionFee) revert InsufficientExecutionFee(msg.value, minExecutionFee);

        id = _createDecreasePosition(
            DecreasePositionRequestIdParam({
                account: msg.sender,
                market: _market,
                marginDelta: _marginDelta,
                sizeDelta: _sizeDelta,
                acceptableIndexPrice: _acceptableIndexPrice,
                receiver: _receiver,
                executionFee: msg.value,
                receivePUSD: true
            })
        );
    }

    /// @inheritdoc IPositionRouter
    function cancelDecreasePosition(
        DecreasePositionRequestIdParam calldata _param,
        address payable _executionFeeReceiver
    ) external override returns (bool) {
        bytes32 id = _decreasePositionRequestId(_param);
        uint256 blockNumber = blockNumbers[id];
        if (blockNumber == 0) return true;

        bool shouldCancel = _shouldCancel(blockNumber, _param.account);
        if (!shouldCancel) return false;

        delete blockNumbers[id];

        _transferOutETH(_param.executionFee, _executionFeeReceiver);

        emit DecreasePositionCancelled(id, _executionFeeReceiver);

        return true;
    }

    /// @inheritdoc IPositionRouter
    function executeDecreasePosition(
        DecreasePositionRequestIdParam calldata _param,
        address payable _executionFeeReceiver
    ) external override returns (bool) {
        bytes32 id = _decreasePositionRequestId(_param);
        uint256 blockNumber = blockNumbers[id];
        if (blockNumber == 0) return true;

        bool shouldExecute = _shouldExecute(blockNumber, _param.account);
        if (!shouldExecute) return false;

        delete blockNumbers[id];

        bool receiveETH = address(weth) == address(_param.market) && !MarketUtil.isDeployedContract(_param.receiver);

        (uint64 minIndexPrice, ) = marketManager.getPrice(_param.market);
        _validateIndexPrice(SHORT, minIndexPrice, _param.acceptableIndexPrice);

        uint256 executionGasLimit_ = executionGasLimit;
        (, uint96 marginDelta) = marketManager.decreasePosition{gas: executionGasLimit_}(
            _param.market,
            _param.account,
            _param.marginDelta,
            _param.sizeDelta,
            (_param.receivePUSD || receiveETH) ? address(this) : _param.receiver
        );

        if (marginDelta > 0) {
            if (_param.receivePUSD) {
                marketManager.mintPUSD{gas: executionGasLimit_}(
                    _param.market,
                    true,
                    marginDelta,
                    this,
                    abi.encode(CallbackData({margin: marginDelta, account: _param.account})),
                    _param.receiver
                );
            } else if (receiveETH) {
                weth.withdraw(marginDelta);
                _transferOutETH(marginDelta, payable(_param.receiver));
            }
        }

        uint256 actualExecutionFee = _refundExecutionFee(
            _param.receivePUSD
                ? EstimatedGasLimitType.DecreasePositionReceivePUSD
                : EstimatedGasLimitType.DecreasePosition,
            _param.executionFee,
            _param.account
        );
        _transferOutETH(actualExecutionFee, _executionFeeReceiver);

        emit DecreasePositionExecuted(id, _executionFeeReceiver, actualExecutionFee);
        return true;
    }

    /// @inheritdoc IPositionRouter
    function executeOrCancelDecreasePosition(
        DecreasePositionRequestIdParam calldata _param,
        address payable _executionFeeReceiver
    ) external override onlyPositionExecutor {
        try this.executeDecreasePosition(_param, _executionFeeReceiver) returns (bool _executed) {
            if (!_executed) return;
        } catch (bytes memory reason) {
            bytes4 errorTypeSelector = _decodeShortenedReason(reason);
            bytes32 id = _decreasePositionRequestId(_param);
            emit ExecuteFailed(RequestType.DecreasePosition, id, errorTypeSelector);

            try this.cancelDecreasePosition(_param, _executionFeeReceiver) returns (bool _cancelled) {
                if (!_cancelled) return;
            } catch {}
        }
    }

    /// @inheritdoc IPositionRouter
    function createMintPUSD(
        IERC20 _market,
        bool _exactIn,
        uint96 _acceptableMaxPayAmount,
        uint64 _acceptableMinReceiveAmount,
        address _receiver,
        bytes calldata _permitData
    ) external payable override returns (bytes32 id) {
        uint256 minExecutionFee = _estimateGasFees(EstimatedGasLimitType.MintPUSD);
        if (msg.value < minExecutionFee) revert InsufficientExecutionFee(msg.value, minExecutionFee);

        _market.safePermit(address(marketManager), _permitData);
        marketManager.pluginTransfer(_market, msg.sender, address(this), _acceptableMaxPayAmount);

        id = _createMintPUSD(
            MintPUSDRequestIdParam({
                account: msg.sender,
                market: _market,
                exactIn: _exactIn,
                acceptableMaxPayAmount: _acceptableMaxPayAmount,
                acceptableMinReceiveAmount: _acceptableMinReceiveAmount,
                receiver: _receiver,
                executionFee: msg.value
            })
        );
    }

    /// @inheritdoc IPositionRouter
    function createMintPUSDETH(
        bool _exactIn,
        uint64 _acceptableMinReceiveAmount,
        address _receiver,
        uint256 _executionFee
    ) external payable override returns (bytes32 id) {
        unchecked {
            _validateExecutionFee(_executionFee, EstimatedGasLimitType.MintPUSD);

            uint256 acceptableMaxPayAmount = msg.value - _executionFee;
            weth.deposit{value: acceptableMaxPayAmount}();

            id = _createMintPUSD(
                MintPUSDRequestIdParam({
                    account: msg.sender,
                    market: IERC20(address(weth)),
                    exactIn: _exactIn,
                    acceptableMaxPayAmount: acceptableMaxPayAmount.toUint96(),
                    acceptableMinReceiveAmount: _acceptableMinReceiveAmount,
                    receiver: _receiver,
                    executionFee: _executionFee
                })
            );
        }
    }

    /// @inheritdoc IPositionRouter
    function cancelMintPUSD(
        MintPUSDRequestIdParam calldata _param,
        address payable _executionFeeReceiver
    ) external override returns (bool cancelled) {
        bytes32 id = _mintPUSDRequestId(_param);
        uint256 blockNumber = blockNumbers[id];
        if (blockNumber == 0) return true;

        bool shouldCancel = _shouldCancel(blockNumber, _param.account);
        if (!shouldCancel) return false;

        delete blockNumbers[id];

        _transferRefund(_param.market, _param.account, _param.acceptableMaxPayAmount);

        // transfer out execution fee
        _transferOutETH(_param.executionFee, _executionFeeReceiver);

        emit MintPUSDCancelled(id, _executionFeeReceiver);

        return true;
    }

    /// @inheritdoc IPositionRouter
    function executeMintPUSD(
        MintPUSDRequestIdParam calldata _param,
        address payable _executionFeeReceiver
    ) external override returns (bool executed) {
        bytes32 id = _mintPUSDRequestId(_param);
        uint256 blockNumber = blockNumbers[id];
        if (blockNumber == 0) return true;

        bool shouldExecute = _shouldExecute(blockNumber, _param.account);
        if (!shouldExecute) return false;

        delete blockNumbers[id];

        (, uint64 receiveAmount) = marketManager.mintPUSD{gas: executionGasLimit}(
            _param.market,
            _param.exactIn,
            _param.exactIn ? _param.acceptableMaxPayAmount : _param.acceptableMinReceiveAmount,
            this,
            abi.encode(CallbackData({margin: _param.acceptableMaxPayAmount, account: _param.account})),
            _param.receiver
        );
        if (receiveAmount < _param.acceptableMinReceiveAmount)
            revert TooLittleReceived(_param.acceptableMinReceiveAmount, receiveAmount);

        uint256 actualExecutionFee = _refundExecutionFee(
            EstimatedGasLimitType.MintPUSD,
            _param.executionFee,
            _param.account
        );
        _transferOutETH(actualExecutionFee, _executionFeeReceiver);

        emit MintPUSDExecuted(id, _executionFeeReceiver, actualExecutionFee);
        return true;
    }

    /// @inheritdoc IPositionRouter
    function executeOrCancelMintPUSD(
        MintPUSDRequestIdParam calldata _param,
        address payable _executionFeeReceiver
    ) external override onlyPositionExecutor {
        try this.executeMintPUSD(_param, _executionFeeReceiver) returns (bool _executed) {
            if (!_executed) return;
        } catch (bytes memory reason) {
            bytes4 errorTypeSelector = _decodeShortenedReason(reason);
            bytes32 id = _mintPUSDRequestId(_param);
            emit ExecuteFailed(RequestType.Mint, id, errorTypeSelector);

            try this.cancelMintPUSD(_param, _executionFeeReceiver) returns (bool _cancelled) {
                if (!_cancelled) return;
            } catch {}
        }
    }

    /// @inheritdoc IPositionRouter
    function createBurnPUSD(
        IERC20 _market,
        bool _exactIn,
        uint64 _acceptableMaxPayAmount,
        uint96 _acceptableMinReceiveAmount,
        address _receiver,
        bytes calldata _permitData
    ) external payable override returns (bytes32 id) {
        uint256 minExecutionFee = _estimateGasFees(EstimatedGasLimitType.BurnPUSD);
        if (msg.value < minExecutionFee) revert InsufficientExecutionFee(msg.value, minExecutionFee);

        IERC20 usd = IERC20(PUSDManagerUtil.computePUSDAddress(address(marketManager)));
        usd.safePermit(address(marketManager), _permitData);
        marketManager.pluginTransfer(usd, msg.sender, address(this), _acceptableMaxPayAmount);

        id = _burnPUSDRequestId(
            BurnPUSDRequestIdParam({
                account: msg.sender,
                market: _market,
                exactIn: _exactIn,
                acceptableMaxPayAmount: _acceptableMaxPayAmount,
                acceptableMinReceiveAmount: _acceptableMinReceiveAmount,
                receiver: _receiver,
                executionFee: msg.value
            })
        );
        _validateRequestConflict(id);
        blockNumbers[id] = block.number;

        emit BurnPUSDCreated(
            msg.sender,
            _market,
            _exactIn,
            _acceptableMaxPayAmount,
            _acceptableMinReceiveAmount,
            _receiver,
            msg.value,
            id
        );
    }

    /// @inheritdoc IPositionRouter
    function cancelBurnPUSD(
        BurnPUSDRequestIdParam calldata _param,
        address payable _executionFeeReceiver
    ) external override returns (bool cancelled) {
        bytes32 id = _burnPUSDRequestId(_param);
        uint256 blockNumber = blockNumbers[id];
        if (blockNumber == 0) return true;

        bool shouldCancel = _shouldCancel(blockNumber, _param.account);
        if (!shouldCancel) return false;

        delete blockNumbers[id];

        IERC20 usd = IERC20(PUSDManagerUtil.computePUSDAddress(address(marketManager)));
        usd.safeTransfer(_param.account, _param.acceptableMaxPayAmount);

        _transferOutETH(_param.executionFee, _executionFeeReceiver);

        emit BurnPUSDCancelled(id, _executionFeeReceiver);

        return true;
    }

    function executeBurnPUSD(
        BurnPUSDRequestIdParam calldata _param,
        address payable _executionFeeReceiver
    ) external override returns (bool executed) {
        bytes32 id = _burnPUSDRequestId(_param);
        uint256 blockNumber = blockNumbers[id];
        if (blockNumber == 0) return true;

        bool shouldExecute = _shouldExecute(blockNumber, _param.account);
        if (!shouldExecute) return false;

        delete blockNumbers[id];

        uint256 executionGasLimit_ = executionGasLimit;
        uint96 receiveAmount;
        uint96 amount = _param.exactIn ? _param.acceptableMaxPayAmount : _param.acceptableMinReceiveAmount;
        if (address(weth) == address(_param.market) && !MarketUtil.isDeployedContract(_param.receiver)) {
            (, receiveAmount) = marketManager.burnPUSD{gas: executionGasLimit_}(
                _param.market,
                _param.exactIn,
                amount,
                this,
                abi.encode(CallbackData({margin: _param.acceptableMaxPayAmount, account: _param.account})),
                address(this)
            );

            weth.withdraw(receiveAmount);
            _transferOutETH(receiveAmount, _param.receiver);
        } else {
            (, receiveAmount) = marketManager.burnPUSD{gas: executionGasLimit_}(
                _param.market,
                _param.exactIn,
                amount,
                this,
                abi.encode(CallbackData({margin: _param.acceptableMaxPayAmount, account: _param.account})),
                _param.receiver
            );
        }

        if (receiveAmount < _param.acceptableMinReceiveAmount)
            revert TooLittleReceived(_param.acceptableMinReceiveAmount, receiveAmount);

        uint256 actualExecutionFee = _refundExecutionFee(
            EstimatedGasLimitType.BurnPUSD,
            _param.executionFee,
            _param.account
        );

        _transferOutETH(actualExecutionFee, _executionFeeReceiver);

        emit BurnPUSDExecuted(id, _executionFeeReceiver, actualExecutionFee);
        return true;
    }

    /// @inheritdoc IPositionRouter
    function executeOrCancelBurnPUSD(
        BurnPUSDRequestIdParam calldata _param,
        address payable _executionFeeReceiver
    ) external override onlyPositionExecutor {
        try this.executeBurnPUSD(_param, _executionFeeReceiver) returns (bool _executed) {
            if (!_executed) return;
        } catch (bytes memory reason) {
            bytes4 errorTypeSelector = _decodeShortenedReason(reason);
            bytes32 id = _burnPUSDRequestId(_param);
            emit ExecuteFailed(RequestType.Burn, id, errorTypeSelector);

            try this.cancelBurnPUSD(_param, _executionFeeReceiver) returns (bool _cancelled) {
                if (!_cancelled) return;
            } catch {}
        }
    }

    function _createIncreasePosition(IncreasePositionRequestIdParam memory _param) private returns (bytes32 id) {
        id = _increasePositionRequestId(_param);
        _validateRequestConflict(id);
        blockNumbers[id] = block.number;

        emit IncreasePositionCreated(
            _param.account,
            _param.market,
            _param.marginDelta,
            _param.sizeDelta,
            _param.acceptableIndexPrice,
            _param.executionFee,
            _param.payPUSD,
            id
        );
    }

    function _createDecreasePosition(DecreasePositionRequestIdParam memory _param) private returns (bytes32 id) {
        id = _decreasePositionRequestId(_param);
        _validateRequestConflict(id);
        blockNumbers[id] = block.number;

        emit DecreasePositionCreated(
            _param.account,
            _param.market,
            _param.marginDelta,
            _param.sizeDelta,
            _param.acceptableIndexPrice,
            _param.receiver,
            _param.executionFee,
            _param.receivePUSD,
            id
        );
    }

    function _createMintPUSD(MintPUSDRequestIdParam memory _param) private returns (bytes32 id) {
        id = _mintPUSDRequestId(_param);
        _validateRequestConflict(id);
        blockNumbers[id] = block.number;

        emit MintPUSDCreated(
            _param.account,
            _param.market,
            _param.exactIn,
            _param.acceptableMaxPayAmount,
            _param.acceptableMinReceiveAmount,
            _param.receiver,
            _param.executionFee,
            id
        );
    }

    function _increasePositionRequestId(
        IncreasePositionRequestIdParam memory _param
    ) private pure returns (bytes32 id) {
        return keccak256(abi.encode(_param));
    }

    function _decreasePositionRequestId(
        DecreasePositionRequestIdParam memory _param
    ) private pure returns (bytes32 id) {
        return keccak256(abi.encode(_param));
    }

    function _mintPUSDRequestId(MintPUSDRequestIdParam memory _param) private pure returns (bytes32 id) {
        return keccak256(abi.encode(_param));
    }

    function _burnPUSDRequestId(BurnPUSDRequestIdParam memory _param) private pure returns (bytes32 id) {
        return keccak256(abi.encode(_param));
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.8.26;

import "./PositionRouterCommon.sol";
import "../libraries/LiquidityUtil.sol";
import "./interfaces/IPositionRouter2.sol";

contract PositionRouter2 is IPositionRouter2, PositionRouterCommon {
    using SafeCast for uint256;
    using TransferHelper for *;
    using MarketUtil for *;

    constructor(
        Governable _govImpl,
        IMarketManager _marketManager,
        IWETHMinimum _weth,
        EstimatedGasLimitType[] memory _estimatedGasLimitTypes,
        uint256[] memory _estimatedGasLimits
    ) PositionRouterCommon(_govImpl, _marketManager, _weth, _estimatedGasLimitTypes, _estimatedGasLimits) {}

    /// @inheritdoc IPositionRouter2
    function createMintLPT(
        IERC20 _market,
        uint96 _liquidityDelta,
        address _receiver,
        bytes calldata _permitData
    ) external payable override returns (bytes32 id) {
        uint256 minExecutionFee = _estimateGasFees(EstimatedGasLimitType.MintLPT);
        if (msg.value < minExecutionFee) revert InsufficientExecutionFee(msg.value, minExecutionFee);
        _market.safePermit(address(marketManager), _permitData);
        marketManager.pluginTransfer(_market, msg.sender, address(this), _liquidityDelta);
        id = _createMintLPT(
            MintLPTRequestIdParam({
                account: msg.sender,
                market: _market,
                liquidityDelta: _liquidityDelta,
                executionFee: msg.value,
                receiver: _receiver,
                payPUSD: false,
                minReceivedFromBurningPUSD: 0
            })
        );
    }

    /// @inheritdoc IPositionRouter2
    function createMintLPTPayPUSD(
        IERC20 _market,
        uint64 _pusdAmount,
        address _receiver,
        uint96 _minReceivedFromBurningPUSD,
        bytes calldata _permitData
    ) external payable override returns (bytes32 id) {
        uint256 minExecutionFee = _estimateGasFees(EstimatedGasLimitType.MintLPTPayPUSD);
        if (msg.value < minExecutionFee) revert InsufficientExecutionFee(msg.value, minExecutionFee);

        IERC20 usd = IERC20(PUSDManagerUtil.computePUSDAddress(address(marketManager)));
        usd.safePermit(address(marketManager), _permitData);
        marketManager.pluginTransfer(usd, msg.sender, address(this), _pusdAmount);

        id = _createMintLPT(
            MintLPTRequestIdParam({
                account: msg.sender,
                market: _market,
                liquidityDelta: _pusdAmount,
                executionFee: msg.value,
                receiver: _receiver,
                payPUSD: true,
                minReceivedFromBurningPUSD: _minReceivedFromBurningPUSD
            })
        );
    }

    /// @inheritdoc IPositionRouter2
    function createMintLPTETH(address _receiver, uint256 _executionFee) external payable override returns (bytes32 id) {
        unchecked {
            _validateExecutionFee(_executionFee, EstimatedGasLimitType.MintLPT);

            uint256 liquidityDelta = msg.value - _executionFee;

            weth.deposit{value: liquidityDelta}();

            id = _createMintLPT(
                MintLPTRequestIdParam({
                    account: msg.sender,
                    market: IERC20(address(weth)),
                    liquidityDelta: liquidityDelta.toUint96(),
                    executionFee: _executionFee,
                    receiver: _receiver,
                    payPUSD: false,
                    minReceivedFromBurningPUSD: 0
                })
            );
        }
    }

    /// @inheritdoc IPositionRouter2
    function cancelMintLPT(
        MintLPTRequestIdParam calldata _param,
        address payable _executionFeeReceiver
    ) external override returns (bool) {
        bytes32 id = _mintLPTRequestId(_param);

        uint256 blockNumber = blockNumbers[id];
        if (blockNumber == 0) return true;

        bool shouldCancel = _shouldCancel(blockNumber, _param.account);
        if (!shouldCancel) return false;

        delete blockNumbers[id];

        if (_param.payPUSD) {
            IERC20 usd = IERC20(PUSDManagerUtil.computePUSDAddress(address(marketManager)));
            usd.safeTransfer(_param.account, _param.liquidityDelta);
        } else {
            _transferRefund(_param.market, _param.account, _param.liquidityDelta);
        }

        // transfer out execution fee
        _transferOutETH(_param.executionFee, _executionFeeReceiver);

        emit MintLPTCancelled(id, _executionFeeReceiver);

        return true;
    }

    /// @inheritdoc IPositionRouter2
    function executeMintLPT(
        MintLPTRequestIdParam calldata _param,
        address payable _executionFeeReceiver
    ) external override returns (bool) {
        bytes32 id = _mintLPTRequestId(_param);

        uint256 blockNumber = blockNumbers[id];
        if (blockNumber == 0) return true;

        bool shouldExecute = _shouldExecute(blockNumber, _param.account);
        if (!shouldExecute) return false;

        delete blockNumbers[id];

        uint256 executionGasLimit_ = executionGasLimit;
        uint96 liquidityDeltaAfter = _param.liquidityDelta;
        if (_param.payPUSD) {
            (, uint96 receiveAmount) = marketManager.burnPUSD{gas: executionGasLimit_}(
                _param.market,
                true,
                _param.liquidityDelta,
                this,
                abi.encode(CallbackData({margin: _param.liquidityDelta, account: _param.account})),
                address(this)
            );
            if (receiveAmount < _param.minReceivedFromBurningPUSD)
                revert TooLittleReceived(_param.minReceivedFromBurningPUSD, receiveAmount);

            liquidityDeltaAfter = receiveAmount;
        }

        _param.market.safeTransfer(address(marketManager), liquidityDeltaAfter, executionGasLimit_);

        marketManager.mintLPT{gas: executionGasLimit_}(_param.market, _param.account, _param.receiver);

        uint256 actualExecutionFee = _refundExecutionFee(
            _param.payPUSD ? EstimatedGasLimitType.MintLPTPayPUSD : EstimatedGasLimitType.MintLPT,
            _param.executionFee,
            _param.account
        );

        _transferOutETH(actualExecutionFee, _executionFeeReceiver);

        emit MintLPTExecuted(id, _executionFeeReceiver, actualExecutionFee);

        return true;
    }

    /// @inheritdoc IPositionRouter2
    function executeOrCancelMintLPT(
        MintLPTRequestIdParam calldata _param,
        address payable _executionFeeReceiver
    ) external override onlyPositionExecutor {
        try this.executeMintLPT(_param, _executionFeeReceiver) returns (bool _executed) {
            if (!_executed) return;
        } catch (bytes memory reason) {
            bytes4 errorTypeSelector = _decodeShortenedReason(reason);
            emit ExecuteFailed(RequestType.MintLPT, _mintLPTRequestId(_param), errorTypeSelector);
            try this.cancelMintLPT(_param, _executionFeeReceiver) returns (bool _cancelled) {
                if (!_cancelled) return;
            } catch {}
        }
    }

    /// @inheritdoc IPositionRouter2
    function createBurnLPT(
        IERC20 _market,
        uint64 _amount,
        uint96 _acceptableMinLiquidity,
        address _receiver,
        bytes calldata _permitData
    ) external payable override returns (bytes32 id) {
        uint256 minExecutionFee = _estimateGasFees(EstimatedGasLimitType.BurnLPT);
        if (msg.value < minExecutionFee) revert InsufficientExecutionFee(msg.value, minExecutionFee);

        ILPToken lpToken = ILPToken(LiquidityUtil.computeLPTokenAddress(_market, address(marketManager)));
        lpToken.safePermit(address(marketManager), _permitData);
        marketManager.pluginTransfer(lpToken, msg.sender, address(this), uint256(_amount));
        id = _createBurnLPT(
            BurnLPTRequestIdParam({
                account: msg.sender,
                market: _market,
                amount: _amount,
                acceptableMinLiquidity: _acceptableMinLiquidity,
                receiver: _receiver,
                executionFee: msg.value,
                receivePUSD: false,
                minPUSDReceived: 0
            })
        );
    }

    /// @inheritdoc IPositionRouter2
    function createBurnLPTReceivePUSD(
        IERC20 _market,
        uint64 _amount,
        uint64 _minPUSDReceived,
        address _receiver,
        bytes calldata _permitData
    ) external payable override returns (bytes32 id) {
        uint256 minExecutionFee = _estimateGasFees(EstimatedGasLimitType.BurnLPTReceivePUSD);
        if (msg.value < minExecutionFee) revert InsufficientExecutionFee(msg.value, minExecutionFee);

        ILPToken lpToken = ILPToken(LiquidityUtil.computeLPTokenAddress(_market, address(marketManager)));
        lpToken.safePermit(address(marketManager), _permitData);
        marketManager.pluginTransfer(lpToken, msg.sender, address(this), uint256(_amount));
        id = _createBurnLPT(
            BurnLPTRequestIdParam({
                account: msg.sender,
                market: _market,
                amount: _amount,
                acceptableMinLiquidity: 0,
                receiver: _receiver,
                executionFee: msg.value,
                receivePUSD: true,
                minPUSDReceived: _minPUSDReceived
            })
        );
    }

    /// @inheritdoc IPositionRouter2
    function cancelBurnLPT(
        BurnLPTRequestIdParam calldata _param,
        address payable _executionFeeReceiver
    ) external override returns (bool) {
        bytes32 id = _burnLPTRequestId(_param);

        uint256 blockNumber = blockNumbers[id];
        if (blockNumber == 0) return true;

        bool shouldCancel = _shouldCancel(blockNumber, _param.account);
        if (!shouldCancel) return false;

        delete blockNumbers[id];

        ILPToken token = ILPToken(LiquidityUtil.computeLPTokenAddress(_param.market, address(marketManager)));
        token.safeTransfer(_param.account, _param.amount, executionGasLimit);

        _transferOutETH(_param.executionFee, _executionFeeReceiver);

        emit BurnLPTCancelled(id, _executionFeeReceiver);

        return true;
    }

    /// @inheritdoc IPositionRouter2
    function executeBurnLPT(
        BurnLPTRequestIdParam calldata _param,
        address payable _executionFeeReceiver
    ) external override returns (bool) {
        bytes32 id = _burnLPTRequestId(_param);

        uint256 blockNumber = blockNumbers[id];
        if (blockNumber == 0) return true;

        bool shouldExecute = _shouldExecute(blockNumber, _param.account);
        if (!shouldExecute) return false;

        delete blockNumbers[id];

        uint256 executionGasLimit_ = executionGasLimit;

        ILPToken token = ILPToken(LiquidityUtil.computeLPTokenAddress(_param.market, address(marketManager)));
        token.safeTransfer(address(marketManager), _param.amount, executionGasLimit_);

        bool receiveETH = address(weth) == address(_param.market) && !MarketUtil.isDeployedContract(_param.receiver);

        uint96 liquidity = marketManager.burnLPT{gas: executionGasLimit_}(
            _param.market,
            _param.account,
            (_param.receivePUSD || receiveETH) ? address(this) : _param.receiver
        );

        if (_param.receivePUSD) {
            uint64 receiveAmount;
            if (liquidity > 0) {
                (, receiveAmount) = marketManager.mintPUSD{gas: executionGasLimit_}(
                    _param.market,
                    true,
                    liquidity,
                    this,
                    abi.encode(CallbackData({margin: liquidity, account: _param.account})),
                    _param.receiver
                );
            }
            if (receiveAmount < _param.minPUSDReceived) revert TooLittleReceived(_param.minPUSDReceived, receiveAmount);
        } else {
            if (liquidity < _param.acceptableMinLiquidity)
                revert TooLittleReceived(_param.acceptableMinLiquidity, liquidity);
            if (receiveETH && liquidity > 0) {
                weth.withdraw(liquidity);
                _transferOutETH(liquidity, _param.receiver);
            }
        }
        uint256 actualExecutionFee = _refundExecutionFee(
            _param.receivePUSD ? EstimatedGasLimitType.BurnLPTReceivePUSD : EstimatedGasLimitType.BurnLPT,
            _param.executionFee,
            _param.account
        );

        _transferOutETH(actualExecutionFee, _executionFeeReceiver);

        emit BurnLPTExecuted(id, _executionFeeReceiver, actualExecutionFee);
        return true;
    }

    /// @inheritdoc IPositionRouter2
    function executeOrCancelBurnLPT(
        BurnLPTRequestIdParam calldata _param,
        address payable _executionFeeReceiver
    ) external override onlyPositionExecutor {
        try this.executeBurnLPT(_param, _executionFeeReceiver) returns (bool _executed) {
            if (!_executed) return;
        } catch (bytes memory reason) {
            bytes4 errorTypeSelector = _decodeShortenedReason(reason);
            emit ExecuteFailed(RequestType.BurnLPT, _burnLPTRequestId(_param), errorTypeSelector);

            try this.cancelBurnLPT(_param, _executionFeeReceiver) returns (bool _cancelled) {
                if (!_cancelled) return;
            } catch {}
        }
    }

    function _createMintLPT(MintLPTRequestIdParam memory _param) private returns (bytes32 id) {
        id = _mintLPTRequestId(_param);
        _validateRequestConflict(id);
        blockNumbers[id] = block.number;
        emit MintLPTCreated(
            _param.account,
            _param.market,
            _param.liquidityDelta,
            _param.executionFee,
            _param.receiver,
            _param.payPUSD,
            _param.minReceivedFromBurningPUSD,
            id
        );
    }

    function _createBurnLPT(BurnLPTRequestIdParam memory _param) private returns (bytes32 id) {
        id = _burnLPTRequestId(_param);
        _validateRequestConflict(id);
        blockNumbers[id] = block.number;
        emit BurnLPTCreated(
            _param.account,
            _param.market,
            _param.amount,
            _param.acceptableMinLiquidity,
            _param.receiver,
            _param.executionFee,
            _param.receivePUSD,
            _param.minPUSDReceived,
            id
        );
    }

    function _mintLPTRequestId(MintLPTRequestIdParam memory _param) private pure returns (bytes32 id) {
        id = keccak256(abi.encode(_param));
    }

    function _burnLPTRequestId(BurnLPTRequestIdParam memory _param) private pure returns (bytes32 id) {
        id = keccak256(abi.encode(_param));
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.8.26;

import "../IWETHMinimum.sol";
import "../libraries/MarketUtil.sol";
import "../libraries/PositionUtil.sol";
import "../libraries/TransferHelper.sol";
import "../governance/GovernableProxy.sol";
import "./interfaces/IPositionRouterCommon.sol";

abstract contract PositionRouterCommon is IPositionRouterCommon, GovernableProxy {
    using TransferHelper for *;

    IMarketManager public immutable marketManager;
    IWETHMinimum public immutable weth;

    mapping(EstimatedGasLimitType => uint256) public estimatedGasLimits;

    // pack into a single slot to save gas
    uint32 public minBlockDelayExecutor;
    uint32 public minBlockDelayPublic;
    uint32 public maxBlockDelay;
    uint32 public executionGasLimit;
    uint24 public estimatedGasFeeMultiplier = Constants.BASIS_POINTS_DIVISOR;
    uint24 public executionGasFeeMultiplier = Constants.BASIS_POINTS_DIVISOR;
    uint32 public etherTransferGasLimit = 10000 wei;

    mapping(address => bool) public positionExecutors;

    mapping(bytes32 id => uint256 blockNumber) public blockNumbers;

    modifier onlyPositionExecutor() {
        if (!positionExecutors[msg.sender]) revert Forbidden();
        _;
    }

    /// @notice Used to receive ETH withdrawal from the WETH contract
    receive() external payable {
        if (msg.sender != address(weth)) revert IMarketErrors.InvalidCaller(address(weth));
    }

    constructor(
        Governable _govImpl,
        IMarketManager _marketManager,
        IWETHMinimum _weth,
        EstimatedGasLimitType[] memory _estimatedGasLimitTypes,
        uint256[] memory _estimatedGasLimits
    ) GovernableProxy(_govImpl) {
        marketManager = _marketManager;
        weth = _weth;
        minBlockDelayPublic = 50; // 10 minutes
        maxBlockDelay = 300; // 60 minutes
        executionGasLimit = 1_000_000 wei;
        for (uint256 i; i < _estimatedGasLimitTypes.length; ++i) {
            estimatedGasLimits[_estimatedGasLimitTypes[i]] = _estimatedGasLimits[i];
            emit EstimatedGasLimitUpdated(_estimatedGasLimitTypes[i], _estimatedGasLimits[i]);
        }
    }

    /// @inheritdoc IPositionRouterCommon
    function updatePositionExecutor(address _account, bool _active) external override onlyGov {
        positionExecutors[_account] = _active;
        emit PositionExecutorUpdated(_account, _active);
    }

    /// @inheritdoc IPositionRouterCommon
    function updateDelayValues(
        uint32 _minBlockDelayExecutor,
        uint32 _minBlockDelayPublic,
        uint32 _maxBlockDelay
    ) external override onlyGov {
        minBlockDelayExecutor = _minBlockDelayExecutor;
        minBlockDelayPublic = _minBlockDelayPublic;
        maxBlockDelay = _maxBlockDelay;
        emit DelayValuesUpdated(_minBlockDelayExecutor, _minBlockDelayPublic, _maxBlockDelay);
    }

    /// @inheritdoc IPositionRouterCommon
    function updateEstimatedGasFeeMultiplier(uint24 _multiplier) external override onlyGov {
        estimatedGasFeeMultiplier = _multiplier;
        emit EstimatedGasFeeMultiplierUpdated(_multiplier);
    }

    /// @inheritdoc IPositionRouterCommon
    function updateExecutionGasFeeMultiplier(uint24 _multiplier) external override onlyGov {
        executionGasFeeMultiplier = _multiplier;
        emit ExecutionGasFeeMultiplierUpdated(_multiplier);
    }

    /// @inheritdoc IPositionRouterCommon
    function updateEstimatedGasLimit(
        EstimatedGasLimitType _estimatedGasLimitType,
        uint256 _estimatedGasLimit
    ) external override onlyGov {
        estimatedGasLimits[_estimatedGasLimitType] = _estimatedGasLimit;
        emit EstimatedGasLimitUpdated(_estimatedGasLimitType, _estimatedGasLimit);
    }

    /// @inheritdoc IPositionRouterCommon
    function updateExecutionGasLimit(uint32 _executionGasLimit) external override onlyGov {
        executionGasLimit = _executionGasLimit;
    }

    /// @inheritdoc IPositionRouterCommon
    function updateEtherTransferGasLimit(uint32 _etherTransferGasLimit) external override onlyGov {
        etherTransferGasLimit = _etherTransferGasLimit;
    }

    /// @inheritdoc IPUSDManagerCallback
    function PUSDManagerCallback(
        IERC20 _payToken,
        uint96 _payAmount,
        uint96 /* _receiveAmount */,
        bytes calldata _data
    ) external virtual override {
        if (msg.sender != address(marketManager)) revert Forbidden();

        CallbackData memory data = abi.decode(_data, (CallbackData));
        if (_payAmount > data.margin) revert TooMuchPaid(_payAmount, data.margin);

        unchecked {
            // transfer remaining margin back to the account
            uint96 remaining = data.margin - _payAmount;
            if (remaining > 0) _transferRefund(_payToken, data.account, remaining);
        }

        // transfer pay token to the market manager
        _payToken.safeTransfer(msg.sender, _payAmount);
    }

    // validation
    function _shouldCancel(uint256 _positionBlockNumber, address _account) internal view returns (bool) {
        return _shouldExecuteOrCancel(_positionBlockNumber, _account);
    }

    function _shouldExecute(uint256 _positionBlockNumber, address _account) internal view returns (bool) {
        uint32 _maxBlockDelay = maxBlockDelay;
        unchecked {
            // overflow is desired
            if (_positionBlockNumber + _maxBlockDelay <= block.number)
                revert Expired(_positionBlockNumber + _maxBlockDelay);
        }
        return _shouldExecuteOrCancel(_positionBlockNumber, _account);
    }

    function _shouldExecuteOrCancel(uint256 _positionBlockNumber, address _account) internal view returns (bool) {
        bool isExecutorCall = msg.sender == address(this) || positionExecutors[msg.sender];

        unchecked {
            // overflow is desired
            if (isExecutorCall) return _positionBlockNumber + minBlockDelayExecutor <= block.number;

            if (msg.sender != _account) revert Forbidden();

            if (_positionBlockNumber + minBlockDelayPublic > block.number)
                revert TooEarly(_positionBlockNumber + minBlockDelayPublic);
        }

        return true;
    }

    function _validateIndexPrice(Side _side, uint64 _indexPrice, uint64 _acceptableIndexPrice) internal pure {
        // long makes price up, short makes price down
        if (
            (_side.isLong() && (_indexPrice > _acceptableIndexPrice)) ||
            (_side.isShort() && (_indexPrice < _acceptableIndexPrice))
        ) revert InvalidIndexPrice(_indexPrice, _acceptableIndexPrice);
    }

    function _decodeShortenedReason(bytes memory _reason) internal pure virtual returns (bytes4) {
        return bytes4(_reason);
    }

    function _transferOutETH(uint256 _amountOut, address _receiver) internal {
        MarketUtil.transferOutETH(payable(_receiver), _amountOut, etherTransferGasLimit);
    }

    function _validateExecutionFee(uint256 _executionFee, EstimatedGasLimitType _estimatedGasLimitType) internal view {
        if (msg.value < _executionFee) revert InsufficientExecutionFee(msg.value, _executionFee);
        uint256 minExecutionFee = _estimateGasFees(_estimatedGasLimitType);
        if (_executionFee < minExecutionFee) revert InsufficientExecutionFee(_executionFee, minExecutionFee);
    }

    function _estimateGasFees(EstimatedGasLimitType _type) internal view returns (uint256 fee) {
        unchecked {
            fee = Math.ceilDiv(
                tx.gasprice * estimatedGasLimits[_type] * estimatedGasFeeMultiplier,
                Constants.BASIS_POINTS_DIVISOR
            );
        }
    }

    function _executionGasFees(EstimatedGasLimitType _type) internal view returns (uint256 fee) {
        unchecked {
            fee = Math.ceilDiv(
                tx.gasprice * estimatedGasLimits[_type] * executionGasFeeMultiplier,
                Constants.BASIS_POINTS_DIVISOR
            );
        }
    }

    function _refundExecutionFee(
        EstimatedGasLimitType _type,
        uint256 _executionFeePaid,
        address receiver
    ) internal returns (uint256 actualExecutionFee) {
        actualExecutionFee = _executionGasFees(_type);
        if (_executionFeePaid <= actualExecutionFee) {
            actualExecutionFee = _executionFeePaid;
        } else {
            // prettier-ignore
            unchecked { _transferOutETH(_executionFeePaid - actualExecutionFee, receiver); }
        }
    }

    function _transferRefund(IERC20 _market, address _account, uint128 _refund) internal {
        if (address(weth) == address(_market) && !MarketUtil.isDeployedContract(_account)) {
            weth.withdraw(_refund);
            MarketUtil.transferOutETH(payable(_account), _refund, etherTransferGasLimit);
        } else {
            _market.safeTransfer(_account, _refund, executionGasLimit);
        }
    }

    function _validateRequestConflict(bytes32 _id) internal view {
        require(blockNumbers[_id] == 0, ConflictRequests(_id));
    }
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "../../core/interfaces/IPUSDManagerCallback.sol";

interface IBalanceRateBalancer is IPUSDManagerCallback {
    struct IncreaseBalanceRateRequestIdParam {
        IERC20 market;
        IERC20 collateral;
        uint96 amount;
        uint256 executionFee;
        address account;
        address[] targets;
        bytes[] calldatas;
    }

    /// @notice Emitted when createIncreaseBalanceRate request created
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param collateral The target collateral contract address, such as the contract address of DAI
    /// @param amount The amount of pusd to burn
    /// @param executionFee Amount of fee for the executor to carry out the order
    /// @param account Owner of the request
    /// @param targets swap calldata target list
    /// @param calldatas swap calldata list
    /// @param id Id of the request
    event IncreaseBalanceRateCreated(
        IERC20 indexed market,
        IERC20 indexed collateral,
        uint128 amount,
        uint256 executionFee,
        address account,
        address[] targets,
        bytes[] calldatas,
        bytes32 id
    );

    /// @notice Emitted when createIncreaseBalanceRate request cancelled
    /// @param id Id of the cancelled request
    /// @param executionFeeReceiver Receiver of the cancelled request execution fee
    event IncreaseBalanceRateCancelled(bytes32 indexed id, address payable executionFeeReceiver);

    /// @notice Emitted when createIncreaseBalanceRate request executed
    /// @param id Id of the executed request
    /// @param executionFeeReceiver Receiver of the executed request execution fee
    /// @param executionFee Actual execution fee received
    event IncreaseBalanceRateExecuted(bytes32 indexed id, address payable executionFeeReceiver, uint256 executionFee);

    /// @notice Execute failed
    event ExecuteFailed(bytes32 indexed id, bytes4 shortenedReason);

    /// @notice Error thrown when caller is not the market manager
    error InvalidCaller(address caller);

    /// @notice Invalid callbackData
    error InvalidCallbackData();

    /// @notice create increase balance rate request
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param collateral The target collateral contract address, such as the contract address of DAI
    /// @param amount Amount of pusd to burn
    /// @param targets Address of contract to call
    /// @param data CallData to call
    /// @return id Id of the request
    function createIncreaseBalanceRate(
        IERC20 market,
        IERC20 collateral,
        uint96 amount,
        address[] calldata targets,
        bytes[] calldata data
    ) external payable returns (bytes32 id);

    /// @notice cancel increase balance rate request
    /// @param param The increase request id calculation param
    /// @param executionFeeReceiver Receiver of request execution fee
    /// @return cancelled True if the cancellation succeeds or request not exists
    function cancelIncreaseBalanceRate(
        IncreaseBalanceRateRequestIdParam calldata param,
        address payable executionFeeReceiver
    ) external returns (bool);

    /// @notice Execute increase balance rate request
    /// @param param The increase request id calculation param
    /// @param executionFeeReceiver Receiver of the request execution fee
    /// @return executed True if the execution succeeds or request not exists
    function executeIncreaseBalanceRate(
        IncreaseBalanceRateRequestIdParam calldata param,
        address payable executionFeeReceiver
    ) external returns (bool);

    /// @notice Execute multiple requests
    /// @param param The increase request id calculation param
    /// @param shouldCancelOnFail should cancel request when execute failed
    /// @param executionFeeReceiver Receiver of the request execution fees
    function executeOrCancelIncreaseBalanceRate(
        IncreaseBalanceRateRequestIdParam calldata param,
        bool shouldCancelOnFail,
        address payable executionFeeReceiver
    ) external;
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IDirectExecutablePlugin {
    /// @notice Emitted when liquidity buffer debt payer updated
    /// @param account Account to update
    /// @param active Whether active after the update
    event LiquidityBufferDebtPayerUpdated(address indexed account, bool active);

    /// @notice Emitted when PSM minter updated
    /// @param account Account to update
    /// @param active Whether active after the update
    event PSMMinterUpdated(address indexed account, bool active);

    /// @notice Error thrown when the cap is exceeded
    error PSMCapExceeded(uint256 balance, uint120 amount, uint120 cap);

    /// @notice Error thrown when the excess debt is repaid
    error TooMuchRepaid(uint256 balance, uint128 amount, uint128 cap);

    function liquidityBufferDebtPayers(address account) external view returns (bool);

    function allowAnyoneRepayLiquidityBufferDebt() external view returns (bool);

    function psmMinters(address account) external view returns (bool);

    function allowAnyoneUsePSM() external view returns (bool);

    /// @notice Update liquidity buffer debt payer
    /// @param account Account to update
    /// @param active Updated status
    function updateLiquidityBufferDebtPayer(address account, bool active) external;

    /// @notice Update allow anyone repay liquidity buffer debt status
    /// @param allowed Updated status
    function updateAllowAnyoneRepayLiquidityBufferDebt(bool allowed) external;

    /// @notice Update PSM minters
    /// @param account Account to update
    /// @param active Updated status
    function updatePSMMinters(address account, bool active) external;

    /// @notice Update allow anyone use PSM
    /// @param allowed Updated status
    function updateAllowAnyoneUsePSM(bool allowed) external;

    /// @notice Repay liquidity buffer debt
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param amount The amount of PUSD to repay
    /// @param receiver Address to receive repaid token
    /// @param permitData The permit data for the PUSD token, optional
    function repayLiquidityBufferDebt(
        IERC20 market,
        uint128 amount,
        address receiver,
        bytes calldata permitData
    ) external;

    /// @notice Mint PUSD through the PSM module
    /// @param collateral The collateral token
    /// @param amount The amount of collateral to mint
    /// @param receiver Address to receive PUSD
    /// @param permitData The permit data for the collateral token, optional
    /// @return receiveAmount The amount of PUSD minted
    function psmMintPUSD(
        IERC20 collateral,
        uint120 amount,
        address receiver,
        bytes memory permitData
    ) external returns (uint64 receiveAmount);

    /// @notice Burn PUSD through the PSM module
    /// @param collateral The collateral token
    /// @param amount The amount of PUSD to burn
    /// @param receiver Address to receive collateral
    /// @param permitData The permit data for the PUSD token, optional
    /// @return receiveAmount The amount of collateral received
    function psmBurnPUSD(
        IERC20 collateral,
        uint64 amount,
        address receiver,
        bytes calldata permitData
    ) external returns (uint96 receiveAmount);
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ILiquidator {
    /// @notice Emitted when executor updated
    /// @param account The account to update
    /// @param active Updated status
    event ExecutorUpdated(address account, bool active);

    /// @notice Update executor
    /// @param account Account to update
    /// @param active Updated status
    function updateExecutor(address account, bool active) external;

    /// @notice Update the gas limit for executing liquidation
    /// @param executionGasLimit New execution gas limit
    function updateExecutionGasLimit(uint256 executionGasLimit) external;

    /// @notice Liquidate a position
    /// @dev See `IMarketPosition#liquidatePosition` for more information
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param account The owner of the position
    /// @param feeReceiver The address to receive the liquidation execution fee
    function liquidatePosition(IERC20 market, address payable account, address payable feeReceiver) external;
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title Plugin Manager Interface
/// @notice The interface defines the functions to manage plugins
interface IPluginManager {
    /// @notice Emitted when a plugin is updated
    /// @param plugin The plugin to update
    /// @param active Whether active after the update
    event PluginUpdated(address indexed plugin, bool active);

    /// @notice Error thrown when the plugin is inactive
    error PluginInactive(address plugin);

    /// @notice Update plugin
    /// @param plugin The plugin to update
    /// @param active Whether active after the update
    function updatePlugin(address plugin, bool active) external;

    /// @notice Checks if a plugin is registered
    /// @param plugin The plugin to check
    /// @return True if the plugin is registered, false otherwise
    function activePlugins(address plugin) external view returns (bool);

    /// @notice Transfers `amount` of `token` from `from` to `to`
    /// @param token The address of the ERC20 token
    /// @param from The address to transfer the tokens from
    /// @param to The address to transfer the tokens to
    /// @param amount The amount of tokens to transfer
    function pluginTransfer(IERC20 token, address from, address to, uint256 amount) external;
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @notice PositionRouter contract interface
interface IPositionRouter {
    /// @notice The param used to calculate the increase position request id
    struct IncreasePositionRequestIdParam {
        address account;
        IERC20 market;
        uint96 marginDelta;
        uint96 sizeDelta;
        uint64 acceptableIndexPrice;
        uint256 executionFee;
        bool payPUSD;
    }

    /// @notice The param used to calculate the decrease position request id
    struct DecreasePositionRequestIdParam {
        address account;
        IERC20 market;
        uint96 marginDelta;
        uint96 sizeDelta;
        uint64 acceptableIndexPrice;
        address receiver;
        uint256 executionFee;
        bool receivePUSD;
    }

    /// @notice The param used to calculate the mint PUSD request id
    struct MintPUSDRequestIdParam {
        address account;
        IERC20 market;
        bool exactIn;
        uint96 acceptableMaxPayAmount;
        uint64 acceptableMinReceiveAmount;
        address receiver;
        uint256 executionFee;
    }

    /// @notice The param used to calculate the burn PUSD request id
    struct BurnPUSDRequestIdParam {
        IERC20 market;
        address account;
        bool exactIn;
        uint64 acceptableMaxPayAmount;
        uint96 acceptableMinReceiveAmount;
        address receiver;
        uint256 executionFee;
    }

    /// @notice Emitted when open or increase an existing position size request created
    /// @param account Owner of the request
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param marginDelta The increase in position margin, PUSD amount if `payUSD` is true
    /// @param sizeDelta The increase in position size
    /// @param acceptableIndexPrice The worst index price of the request
    /// @param executionFee Amount of fee for the executor to carry out the request
    /// @param payPUSD Whether to pay PUSD
    /// @param id Id of the request
    event IncreasePositionCreated(
        address indexed account,
        IERC20 indexed market,
        uint96 marginDelta,
        uint96 sizeDelta,
        uint64 acceptableIndexPrice,
        uint256 executionFee,
        bool payPUSD,
        bytes32 id
    );

    /// @notice Emitted when increase position request cancelled
    /// @param id Id of the request
    /// @param executionFeeReceiver Receiver of the cancelled request execution fee
    event IncreasePositionCancelled(bytes32 indexed id, address payable executionFeeReceiver);

    /// @notice Emitted when increase position request executed
    /// @param id Id of the request
    /// @param executionFeeReceiver Receiver of the executed request execution fee
    /// @param executionFee Actual execution fee received
    event IncreasePositionExecuted(bytes32 indexed id, address payable executionFeeReceiver, uint256 executionFee);

    /// @notice Emitted when close or decrease existing position size request created
    /// @param account Owner of the request
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param marginDelta The decrease in position margin
    /// @param sizeDelta The decrease in position size
    /// @param acceptableIndexPrice The worst index price of the request
    /// @param receiver Address of the margin receiver
    /// @param executionFee Amount of fee for the executor to carry out the order
    /// @param receivePUSD Whether to receive PUSD
    /// @param id Id of the request
    event DecreasePositionCreated(
        address indexed account,
        IERC20 indexed market,
        uint96 marginDelta,
        uint96 sizeDelta,
        uint64 acceptableIndexPrice,
        address receiver,
        uint256 executionFee,
        bool receivePUSD,
        bytes32 id
    );

    /// @notice Emitted when decrease position request cancelled
    /// @param id Id of the request
    /// @param executionFeeReceiver Receiver of the request execution fee
    event DecreasePositionCancelled(bytes32 indexed id, address payable executionFeeReceiver);

    /// @notice Emitted when decrease position request executed
    /// @param id Id of the request
    /// @param executionFeeReceiver Receiver of the request execution fee
    /// @param executionFee Actual execution fee received
    event DecreasePositionExecuted(bytes32 indexed id, address payable executionFeeReceiver, uint256 executionFee);

    /// @notice Emitted when mint PUSD request created
    /// @param account Owner of the request
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param acceptableMaxPayAmount The max amount of token to pay
    /// @param acceptableMinReceiveAmount The min amount of PUSD to mint
    /// @param receiver Address to receive PUSD
    /// @param executionFee Amount of the execution fee
    /// @param id Id of the request
    event MintPUSDCreated(
        address indexed account,
        IERC20 indexed market,
        bool exactIn,
        uint96 acceptableMaxPayAmount,
        uint64 acceptableMinReceiveAmount,
        address receiver,
        uint256 executionFee,
        bytes32 id
    );

    /// @notice Emitted when mint PUSD request cancelled
    /// @param id Id of the request
    /// @param executionFeeReceiver Receiver of the request execution fee
    event MintPUSDCancelled(bytes32 indexed id, address payable executionFeeReceiver);

    /// @notice Emitted when mint PUSD request executed
    /// @param id Id of the request
    /// @param executionFeeReceiver Receiver of the request execution fee
    /// @param executionFee Actual execution fee received
    event MintPUSDExecuted(bytes32 indexed id, address payable executionFeeReceiver, uint256 executionFee);

    /// @notice Emitted when burn PUSD request created
    /// @param account Owner of the request
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param acceptableMaxPayAmount The max amount of PUSD to burn
    /// @param acceptableMinReceiveAmount The min amount of token to receive
    /// @param receiver Address to receive ETH
    /// @param executionFee Amount of the execution fee
    /// @param id Id of the request
    event BurnPUSDCreated(
        address indexed account,
        IERC20 indexed market,
        bool exactIn,
        uint64 acceptableMaxPayAmount,
        uint96 acceptableMinReceiveAmount,
        address receiver,
        uint256 executionFee,
        bytes32 id
    );

    /// @notice Emitted when burn PUSD request cancelled
    /// @param id Id of the request
    /// @param executionFeeReceiver Receiver of the request execution fee
    event BurnPUSDCancelled(bytes32 indexed id, address payable executionFeeReceiver);

    /// @notice Emitted when burn PUSD request executed
    /// @param id Id of the request
    /// @param executionFeeReceiver Receiver of the request execution fee
    /// @param executionFee Actual execution fee received
    event BurnPUSDExecuted(bytes32 indexed id, address payable executionFeeReceiver, uint256 executionFee);

    /// @notice Create open or increase the size of existing position request
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param marginDelta The increase in position margin
    /// @param sizeDelta The increase in position size
    /// @param acceptableIndexPrice The worst index price of the request
    /// @param permitData The permit data for the market token, optional
    /// @param id Id of the request
    function createIncreasePosition(
        IERC20 market,
        uint96 marginDelta,
        uint96 sizeDelta,
        uint64 acceptableIndexPrice,
        bytes calldata permitData
    ) external payable returns (bytes32 id);

    /// @notice Create open or increase the size of existing position request by paying ETH
    /// @param sizeDelta The increase in position size
    /// @param acceptableIndexPrice The worst index price of the request
    /// @param executionFee Amount of the execution fee
    /// @param id Id of the request
    function createIncreasePositionETH(
        uint96 sizeDelta,
        uint64 acceptableIndexPrice,
        uint256 executionFee
    ) external payable returns (bytes32 id);

    /// @notice Create open or increase the size of existing position request, paying PUSD
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param pusdAmount The PUSD amount to pay
    /// @param sizeDelta The increase in position size
    /// @param acceptableIndexPrice The worst index price of the request
    /// @param permitData The permit data for the PUSD token, optional
    /// @param id Id of the request
    function createIncreasePositionPayPUSD(
        IERC20 market,
        uint64 pusdAmount,
        uint96 sizeDelta,
        uint64 acceptableIndexPrice,
        bytes calldata permitData
    ) external payable returns (bytes32 id);

    /// @notice Cancel increase position request
    /// @param param The increase position request id calculation param
    /// @param executionFeeReceiver Receiver of the request execution fee
    /// @return cancelled True if the cancellation succeeds or request not exists
    function cancelIncreasePosition(
        IncreasePositionRequestIdParam calldata param,
        address payable executionFeeReceiver
    ) external returns (bool cancelled);

    /// @notice Execute increase position request
    /// @param param The increase position request id calculation param
    /// @param executionFeeReceiver Receiver of the request execution fee
    /// @return executed True if the execution succeeds or request not exists
    function executeIncreasePosition(
        IncreasePositionRequestIdParam calldata param,
        address payable executionFeeReceiver
    ) external returns (bool executed);

    /// @notice Try to execute increase position request. If the request is not executable, cancel it.
    /// @param param The increase position request id calculation param
    /// @param executionFeeReceiver Receiver of the request execution fee
    function executeOrCancelIncreasePosition(
        IncreasePositionRequestIdParam calldata param,
        address payable executionFeeReceiver
    ) external;

    /// @notice Create decrease position request
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param marginDelta The decrease in position margin
    /// @param sizeDelta The decrease in position size
    /// @param acceptableIndexPrice The worst index price of the request
    /// @param receiver Margin recipient address
    /// @param id Id of the request
    function createDecreasePosition(
        IERC20 market,
        uint96 marginDelta,
        uint96 sizeDelta,
        uint64 acceptableIndexPrice,
        address payable receiver
    ) external payable returns (bytes32 id);

    /// @notice Create decrease position request, receiving PUSD
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param marginDelta The decrease in position margin
    /// @param sizeDelta The decrease in position size
    /// @param acceptableIndexPrice The worst index price of decreasing position of the request
    /// @param receiver Margin recipient address
    /// @param id Id of the request
    function createDecreasePositionReceivePUSD(
        IERC20 market,
        uint96 marginDelta,
        uint96 sizeDelta,
        uint64 acceptableIndexPrice,
        address receiver
    ) external payable returns (bytes32 id);

    /// @notice Cancel decrease position request
    /// @param param The decrease position request id calculation param
    /// @param executionFeeReceiver Receiver of the request execution fee
    /// @return cancelled True if the cancellation succeeds or request not exists
    function cancelDecreasePosition(
        DecreasePositionRequestIdParam calldata param,
        address payable executionFeeReceiver
    ) external returns (bool cancelled);

    /// @notice Execute decrease position request
    /// @param param The decrease position request id calculation param
    /// @param executionFeeReceiver Receiver of the request execution fee
    /// @return executed True if the execution succeeds or request not exists
    function executeDecreasePosition(
        DecreasePositionRequestIdParam calldata param,
        address payable executionFeeReceiver
    ) external returns (bool executed);

    /// @notice Try to execute decrease position request. If the request is not executable, cancel it.
    /// @param param The decrease position request id calculation param
    /// @param executionFeeReceiver Receiver of the request execution fee
    function executeOrCancelDecreasePosition(
        DecreasePositionRequestIdParam calldata param,
        address payable executionFeeReceiver
    ) external;

    /// @notice Create mint PUSD request
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param acceptableMaxPayAmount The max amount of token to pay
    /// @param acceptableMinReceiveAmount The min amount of PUSD to mint
    /// @param receiver Address to receive PUSD
    /// @param permitData The permit data for the market token, optional
    /// @param id Id of the request
    function createMintPUSD(
        IERC20 market,
        bool exactIn,
        uint96 acceptableMaxPayAmount,
        uint64 acceptableMinReceiveAmount,
        address receiver,
        bytes calldata permitData
    ) external payable returns (bytes32 id);

    /// @notice Create mint PUSD request by paying ETH
    /// @param acceptableMinReceiveAmount The min acceptable amount of PUSD to mint
    /// @param receiver Address to receive PUSD
    /// @param executionFee Amount of the execution fee
    /// @param id Id of the request
    function createMintPUSDETH(
        bool exactIn,
        uint64 acceptableMinReceiveAmount,
        address receiver,
        uint256 executionFee
    ) external payable returns (bytes32 id);

    /// @notice Cancel mint PUSD request
    /// @param param The mint PUSD request id calculation param
    /// @param executionFeeReceiver Receiver of the request execution fee
    /// @return cancelled True if the cancellation succeeds or request not exists
    function cancelMintPUSD(
        MintPUSDRequestIdParam calldata param,
        address payable executionFeeReceiver
    ) external returns (bool cancelled);

    /// @notice Execute mint PUSD request
    /// @param param The mint PUSD request id calculation param
    /// @param executionFeeReceiver Receiver of the request execution fee
    /// @return executed True if the execution succeeds or request not exists
    function executeMintPUSD(
        MintPUSDRequestIdParam calldata param,
        address payable executionFeeReceiver
    ) external returns (bool executed);

    /// @notice Try to Execute mint PUSD request. If the request is not executable, cancel it.
    /// @param param The mint PUSD request id calculation param
    /// @param executionFeeReceiver Receiver of the request execution fee
    function executeOrCancelMintPUSD(
        MintPUSDRequestIdParam calldata param,
        address payable executionFeeReceiver
    ) external;

    /// @notice Create burn PUSD request
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param acceptableMaxPayAmount The max amount of PUSD to burn
    /// @param acceptableMinReceiveAmount The min amount of token to receive
    /// @param receiver Address to receive ETH
    /// @param permitData The permit data for the PUSD token, optional
    /// @param id Id of the request
    function createBurnPUSD(
        IERC20 market,
        bool exactIn,
        uint64 acceptableMaxPayAmount,
        uint96 acceptableMinReceiveAmount,
        address receiver,
        bytes calldata permitData
    ) external payable returns (bytes32 id);

    /// @notice Cancel burn request
    /// @notice param The burn PUSD request id calculation param
    /// @param executionFeeReceiver Receiver of the request execution fee
    /// @return cancelled True if the cancellation succeeds or request not exists
    function cancelBurnPUSD(
        BurnPUSDRequestIdParam calldata param,
        address payable executionFeeReceiver
    ) external returns (bool cancelled);

    /// @notice Execute burn request
    /// @param param The burn PUSD request id calculation param
    /// @param executionFeeReceiver Receiver of the request execution fee
    /// @return executed True if the execution succeeds or request not exists
    function executeBurnPUSD(
        BurnPUSDRequestIdParam calldata param,
        address payable executionFeeReceiver
    ) external returns (bool executed);

    /// @notice Try to execute burn request. If the request is not executable, cancel it.
    /// @param param The burn PUSD request id calculation param
    /// @param executionFeeReceiver Receiver of the request execution fee
    function executeOrCancelBurnPUSD(
        BurnPUSDRequestIdParam calldata param,
        address payable executionFeeReceiver
    ) external;
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @notice PositionRouter2 contract interface
interface IPositionRouter2 {
    /// @notice The param used to calculate the mint LPT request id
    struct MintLPTRequestIdParam {
        address account;
        IERC20 market;
        uint96 liquidityDelta;
        uint256 executionFee;
        address receiver;
        bool payPUSD;
        uint96 minReceivedFromBurningPUSD;
    }

    /// @notice The param used to calculate the burn LPT request id
    struct BurnLPTRequestIdParam {
        address account;
        IERC20 market;
        uint64 amount;
        uint96 acceptableMinLiquidity;
        address receiver;
        uint256 executionFee;
        bool receivePUSD;
        uint64 minPUSDReceived;
    }

    /// @notice Emitted when mint LP token request created
    /// @param account Owner of the request
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param liquidityDelta The liquidity to be paid, PUSD amount if `payUSD` is true
    /// @param executionFee Amount of the execution fee
    /// @param receiver The address to receive the minted LP Token
    /// @param payPUSD Whether to pay PUSD
    /// @param minReceiveAmountFromBurningPUSD The minimum amount received from burning PUSD if `payPUSD` is true
    /// @param id Id of the request
    event MintLPTCreated(
        address indexed account,
        IERC20 indexed market,
        uint96 liquidityDelta,
        uint256 executionFee,
        address receiver,
        bool payPUSD,
        uint96 minReceiveAmountFromBurningPUSD,
        bytes32 id
    );

    /// @notice Emitted when mint LP token request cancelled
    /// @param id Id of the request
    /// @param receiver Receiver of the execution fee and margin
    event MintLPTCancelled(bytes32 indexed id, address payable receiver);

    /// @notice Emitted when mint LP token request executed
    /// @param id Id of the request
    /// @param executionFeeReceiver Receiver of the request execution fee
    /// @param executionFee Actual execution fee received
    event MintLPTExecuted(bytes32 indexed id, address payable executionFeeReceiver, uint256 executionFee);

    /// @notice Emitted when burn LP token request created
    /// @param account Owner of the request
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param amount The amount of LP token that will be burned
    /// @param acceptableMinLiquidity The min amount of liquidity to receive, valid if `receivePUSD` is false
    /// @param receiver Address of the liquidity receiver
    /// @param executionFee  Amount of fee for the executor to carry out the request
    /// @param receivePUSD Whether to receive PUSD
    /// @param minPUSDReceived The min PUSD to receive if `receivePUSD` is true
    /// @param id Id of the request
    event BurnLPTCreated(
        address indexed account,
        IERC20 indexed market,
        uint64 amount,
        uint96 acceptableMinLiquidity,
        address receiver,
        uint256 executionFee,
        bool receivePUSD,
        uint64 minPUSDReceived,
        bytes32 id
    );

    /// @notice Emitted when burn LP token request cancelled
    /// @param id Id of the request
    /// @param executionFeeReceiver Receiver of the request execution fee
    event BurnLPTCancelled(bytes32 indexed id, address payable executionFeeReceiver);

    /// @notice Emitted when burn LP token request executed
    /// @param id Id of the request
    /// @param executionFeeReceiver Receiver of the request execution fee
    // @param executionFee Actual execution fee received
    event BurnLPTExecuted(bytes32 indexed id, address payable executionFeeReceiver, uint256 executionFee);

    /// @notice Create mint LP token request by paying ERC20 token
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param liquidityDelta The liquidity to be paid
    /// @param receiver Address to receive the minted LP Token
    /// @param permitData The permit data for the market token, optional
    /// @return id Id of the request
    function createMintLPT(
        IERC20 market,
        uint96 liquidityDelta,
        address receiver,
        bytes calldata permitData
    ) external payable returns (bytes32 id);

    /// @notice Create mint LP token request by paying ETH
    /// @param receiver Address to receive the minted LP Token
    /// @param executionFee Amount of the execution fee
    /// @return id Id of the request
    function createMintLPTETH(address receiver, uint256 executionFee) external payable returns (bytes32 id);

    /// @notice Create mint LP token request by paying PUSD
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param pusdAmount The PUSD amount to pay
    /// @param receiver Address to receive the minted LP Token
    /// @param minReceivedFromBurningPUSD The minimum amount to receive from burning PUSD
    /// @param permitData The permit data for the PUSD token, optional
    /// @return id Id of the request
    function createMintLPTPayPUSD(
        IERC20 market,
        uint64 pusdAmount,
        address receiver,
        uint96 minReceivedFromBurningPUSD,
        bytes calldata permitData
    ) external payable returns (bytes32 id);

    /// @notice Cancel mint LP token request
    /// @param param The mint LPT request id calculation param
    /// @param executionFeeReceiver Receiver of request execution fee
    /// @return cancelled True if the cancellation succeeds or request not exists
    function cancelMintLPT(
        MintLPTRequestIdParam calldata param,
        address payable executionFeeReceiver
    ) external returns (bool cancelled);

    /// @notice Execute mint LP token request
    /// @param param The mint LPT request id calculation param
    /// @param executionFeeReceiver Receiver of request execution fee
    /// @return executed True if the execution succeeds or request not exists
    function executeMintLPT(
        MintLPTRequestIdParam calldata param,
        address payable executionFeeReceiver
    ) external returns (bool executed);

    /// @notice Try to execute mint LP token request. If the request is not executable, cancel it.
    /// @param param The mint LPT request id calculation param
    /// @param executionFeeReceiver Receiver of request execution fee
    function executeOrCancelMintLPT(
        MintLPTRequestIdParam calldata param,
        address payable executionFeeReceiver
    ) external;

    /// @notice Create burn LP token request
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param amount The amount of LP token that will be burned
    /// @param acceptableMinLiquidity The min amount of liquidity to receive
    /// @param receiver Address of the margin receiver
    /// @param permitData The permit data for the LPT token, optional
    /// @return id Id of the request
    function createBurnLPT(
        IERC20 market,
        uint64 amount,
        uint96 acceptableMinLiquidity,
        address receiver,
        bytes calldata permitData
    ) external payable returns (bytes32 id);

    /// @notice Create burn LP token request and receive PUSD
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param amount The amount of LP token that will be burned
    /// @param minPUSDReceived The min amount of PUSD to receive
    /// @param receiver Address of the margin receiver
    /// @param permitData The permit data for the LPT token, optional
    /// @return id Id of the request
    function createBurnLPTReceivePUSD(
        IERC20 market,
        uint64 amount,
        uint64 minPUSDReceived,
        address receiver,
        bytes calldata permitData
    ) external payable returns (bytes32 id);

    /// @notice Cancel burn LP token request
    /// @param param The burn LPT request id calculation param
    /// @param executionFeeReceiver Receiver of the request execution fee
    /// @return cancelled True if the cancellation succeeds or request not exists
    function cancelBurnLPT(
        BurnLPTRequestIdParam calldata param,
        address payable executionFeeReceiver
    ) external returns (bool cancelled);

    /// @notice Execute burn LP token request
    /// @param param The burn LPT request id calculation param
    /// @param executionFeeReceiver Receiver of the request execution fee
    /// @return executed True if the execution succeeds or request not exists
    function executeBurnLPT(
        BurnLPTRequestIdParam calldata param,
        address payable executionFeeReceiver
    ) external returns (bool executed);

    /// @notice Try to execute burn LP token request. If the request is not executable, cancel it.
    /// @param param The burn LPT request id calculation param
    /// @param executionFeeReceiver Receiver of the request execution fee
    function executeOrCancelBurnLPT(
        BurnLPTRequestIdParam calldata param,
        address payable executionFeeReceiver
    ) external;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../../core/interfaces/IPUSDManagerCallback.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IMarketManager} from "../../core/interfaces/IMarketManager.sol";

interface IPositionRouterCommon is IPUSDManagerCallback {
    enum RequestType {
        MintLPT,
        BurnLPT,
        IncreasePosition,
        DecreasePosition,
        Mint,
        Burn
    }

    enum EstimatedGasLimitType {
        MintLPT,
        MintLPTPayPUSD,
        BurnLPT,
        BurnLPTReceivePUSD,
        IncreasePosition,
        IncreasePositionPayPUSD,
        DecreasePosition,
        DecreasePositionReceivePUSD,
        MintPUSD,
        BurnPUSD,
        IncreaseBalanceRate
    }

    struct CallbackData {
        uint96 margin;
        address account;
    }

    /// @notice Emitted when estimated gas limit updated
    /// @param estimatedGasLimitType Type of the estimated gas limit,
    /// each kind of request has a different estimated gas limit
    /// @param estimatedGasLimit Updated estimated gas limit
    event EstimatedGasLimitUpdated(EstimatedGasLimitType estimatedGasLimitType, uint256 estimatedGasLimit);

    /// @notice Emitted when position executor updated
    /// @param account Account to update
    /// @param active Whether active after the update
    event PositionExecutorUpdated(address indexed account, bool active);

    /// @notice Emitted when delay parameter updated
    /// @param minBlockDelayExecutor The new min block delay for executor to execute requests
    /// @param minBlockDelayPublic The new min block delay for public to execute requests
    /// @param maxBlockDelay The new max block delay until request expires
    event DelayValuesUpdated(uint32 minBlockDelayExecutor, uint32 minBlockDelayPublic, uint32 maxBlockDelay);

    /// @notice Emitted when estimated gas fee multiplier updated
    /// @param estimatedGasMultiplier The new estimated gas fee multiplier
    event EstimatedGasFeeMultiplierUpdated(uint24 estimatedGasMultiplier);

    /// @notice Emitted when execution gas fee multiplier updated
    /// @param executionGasFeeMultiplier The new execution gas fee multiplier
    event ExecutionGasFeeMultiplierUpdated(uint24 executionGasFeeMultiplier);

    /// @notice Emitted when requests execution reverted
    /// @param reqType Request type
    /// @param id Id of the failed request
    /// @param shortenedReason The error selector for the failure
    event ExecuteFailed(RequestType indexed reqType, bytes32 indexed id, bytes4 shortenedReason);

    /// @notice Execution fee is insufficient
    /// @param available The available execution fee amount
    /// @param required The required minimum execution fee amount
    error InsufficientExecutionFee(uint256 available, uint256 required);

    /// @notice Request expired
    /// @param expiredAt When the request is expired
    error Expired(uint256 expiredAt);

    /// @notice Too early to execute request
    /// @param earliest The earliest block to execute the request
    error TooEarly(uint256 earliest);

    /// @notice Paid amount is more than acceptable max amount
    error TooMuchPaid(uint96 payAmount, uint96 acceptableMaxAmount);

    /// @notice Received amount is less than acceptable min amount
    error TooLittleReceived(uint96 acceptableMinAmount, uint96 receiveAmount);

    /// @notice Index price exceeds limit
    error InvalidIndexPrice(uint64 indexPrice, uint64 acceptableIndexPrice);

    /// @notice Request id conflicts
    error ConflictRequests(bytes32 id);

    /// @notice Update position executor
    /// @param account Account to update
    /// @param active Updated status
    function updatePositionExecutor(address account, bool active) external;

    /// @notice Update delay parameters
    /// @param minBlockDelayExecutor New min block delay for executor to execute requests
    /// @param minBlockDelayPublic New min block delay for public to execute requests
    /// @param maxBlockDelay New max block delay until request expires
    function updateDelayValues(uint32 minBlockDelayExecutor, uint32 minBlockDelayPublic, uint32 maxBlockDelay) external;

    /// @notice Update estimated gas fee multiplier
    /// @param multiplier New estimated gas multiplier
    function updateEstimatedGasFeeMultiplier(uint24 multiplier) external;

    /// @notice Update execution gas fee multiplier
    /// @param multiplier New execution gas multiplier
    function updateExecutionGasFeeMultiplier(uint24 multiplier) external;

    /// @notice Update estimated gas limit
    /// @param estimatedGasLimitType Type of the estimated gas limit,
    /// each kind of request has a different estimated gas limit
    /// @param estimatedGasLimit New estimated gas limit
    function updateEstimatedGasLimit(EstimatedGasLimitType estimatedGasLimitType, uint256 estimatedGasLimit) external;

    /// @notice Update the gas limit for executing requests
    /// @param executionGasLimit New execution gas limit
    function updateExecutionGasLimit(uint32 executionGasLimit) external;

    /// @notice Update the gas limit of ether transfer
    /// @param etherTransferGasLimit New gas limit of ether transfer
    function updateEtherTransferGasLimit(uint32 etherTransferGasLimit) external;

    /// @notice Get the status of the position executor
    /// @param account Account to check
    function positionExecutors(address account) external view returns (bool);

    /// @notice Get the block number of the hash id
    /// @param id The hash id
    /// @return blockNumber The block number of the hash id
    function blockNumbers(bytes32 id) external view returns (uint256 blockNumber);
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.8.26;

import "../libraries/MarketUtil.sol";
import "./interfaces/IStaking.sol";
import "../governance/GovernableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract StakingUpgradeable is IStaking, GovernableUpgradeable {
    using SafeERC20 for IERC20;
    using MarketUtil for *;

    mapping(IERC20 token => uint256) public balances;
    mapping(IERC20 token => uint256) public maxStakedLimit;
    mapping(address account => mapping(IERC20 token => uint256)) public balancesPerAccount;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address _initialGov) public initializer {
        GovernableUpgradeable.__Governable_init(_initialGov);
    }

    /// @inheritdoc IStaking
    function stake(IERC20 _token, address _receiver, uint128 _amount, bytes calldata _permitData) external override {
        uint256 balanceAfter = balances[_token] + _amount;
        if (balanceAfter > maxStakedLimit[_token]) revert ExceededMaxStakedLimit(_amount);

        _token.safePermit(address(this), _permitData);
        IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);
        balances[_token] = balanceAfter;
        unchecked {
            balancesPerAccount[_receiver][_token] += _amount;
        }
        emit Staked(_token, msg.sender, _receiver, _amount);
    }

    /// @inheritdoc IStaking
    function unstake(IERC20 _token, address _receiver, uint128 _amount) external override {
        uint256 balanceBefore = balancesPerAccount[msg.sender][_token];
        if (balanceBefore < _amount) revert InvalidInputAmount(_amount);

        unchecked {
            balances[_token] -= _amount;
            balancesPerAccount[msg.sender][_token] = balanceBefore - _amount;
        }
        IERC20(_token).safeTransfer(_receiver, _amount);
        emit Unstaked(_token, msg.sender, _receiver, _amount);
    }

    /// @inheritdoc IStaking
    function setMaxStakedLimit(IERC20 _token, uint256 _limit) external override onlyGov {
        if (_limit < balances[_token]) revert InvalidLimit(_limit);
        maxStakedLimit[_token] = _limit;
        emit MaxStakedLimitSet(_token, _limit);
    }

    /// @inheritdoc UUPSUpgradeable
    function _authorizeUpgrade(address newImplementation) internal virtual override onlyGov {}
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IStaking {
    /// @notice Emitted when the token is staked
    /// @param token The token contract address
    /// @param sender The address to call the function
    /// @param receiver The address to receive the staked token
    /// @param amount The token to stake
    event Staked(IERC20 indexed token, address sender, address receiver, uint256 amount);

    /// @notice Emitted when the token is unstaked
    /// @param token The token contract address
    /// @param account The address to unstake the token
    /// @param receiver The address to receive the unstaked token
    /// @param amount The token to unstake
    event Unstaked(IERC20 indexed token, address account, address receiver, uint128 amount);

    /// @notice Emitted when stableMarketPriceFeed set
    /// @param token The token contract address
    /// @param limit The maximum allowed amount of tokens for staking
    event MaxStakedLimitSet(IERC20 indexed token, uint256 limit);

    /// @notice Error thrown when the input amount is invalid
    error InvalidInputAmount(uint128 amount);

    /// @notice Error thrown when the staked amount exceeds the maximum allowed stake limit
    error ExceededMaxStakedLimit(uint256 amount);

    /// @notice Error thrown when the input limit is invalid
    error InvalidLimit(uint256 limit);

    /// @notice Stake the token
    /// @param token The token contract address
    /// @param receiver The address to receive the staked token
    /// @param amount The token to stake
    /// @param permitData The permit data for the token, optional
    function stake(IERC20 token, address receiver, uint128 amount, bytes calldata permitData) external;

    /// @notice Unstake the token
    /// @param token The token contract address
    /// @param receiver The address to receive the unstaked token
    /// @param amount The token to unstake
    function unstake(IERC20 token, address receiver, uint128 amount) external;

    /// @notice Set the the maximum allowed stake limit
    /// @param token The token contract address
    /// @param limit The maximum allowed amount of tokens for staking
    function setMaxStakedLimit(IERC20 token, uint256 limit) external;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.26;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract ERC20Test is ERC20, ERC20Permit {
    // Set the transfer result
    bool private transferRes;
    // To simulate an attack that drain the gas in transfer
    bool private drainGasInTransfer;
    uint8 private myDecimals;

    receive() external payable {}

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _initialSupply
    ) ERC20(_name, _symbol) ERC20Permit(_name) {
        myDecimals = _decimals;
        transferRes = true;
        drainGasInTransfer = false;

        _mint(_msgSender(), _initialSupply);
    }

    function setTransferRes(bool _transferRes) external {
        transferRes = _transferRes;
    }

    function setDrainGasInTransfer(bool _drainGas) external {
        drainGasInTransfer = _drainGas;
    }

    function decimals() public view override returns (uint8) {
        return myDecimals;
    }

    function mint(address _account, uint256 _amount) public {
        _mint(_account, _amount);
    }

    function transfer(address to, uint256 value) public virtual override returns (bool) {
        if (drainGasInTransfer) while (true) {}

        address owner = _msgSender();
        _transfer(owner, to, value);
        return transferRes;
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../libraries/LiquidityUtil.sol";

contract LiquidityUtilTest {
    function LP_TOKEN_INIT_CODE_HASH() public pure returns (bytes32) {
        return LiquidityUtil.LP_TOKEN_INIT_CODE_HASH;
    }

    function deployLPToken(IERC20 _market, string calldata _tokenSymbol) public returns (LPToken token) {
        return LiquidityUtil.deployLPToken(_market, _tokenSymbol);
    }

    function computeLPTokenAddress(IERC20 _market) public view returns (address) {
        return LiquidityUtil.computeLPTokenAddress(_market);
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity >0.8.0;

import "../oracle/interfaces/IPriceFeed.sol";

contract MockChainLinkPriceFeed {
    struct RoundData {
        uint80 roundId;
        int256 answer;
        uint256 startedAt;
        uint256 updatedAt;
        uint80 answeredInRound;
    }
    uint8 public decimals = 8;
    mapping(uint80 => RoundData) public roundDatas;
    uint80 public maxRound;

    function setDecimals(uint8 _decimals) external {
        decimals = _decimals;
    }

    // getRoundData and latestRoundData should both raise "No data present"
    // if they do not have data to report, instead of returning unset values
    // which could be misinterpreted as actual reported values.
    function getRoundData(
        uint80 _roundId
    )
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        RoundData memory data = roundDatas[_roundId];
        return (data.roundId, data.answer, data.startedAt, data.updatedAt, data.answeredInRound);
    }

    function setRoundData(
        uint80 _roundId,
        int256 _answer,
        uint256 _startedAt,
        uint256 _updatedAt,
        uint80 _answeredInRound
    ) external {
        RoundData memory data = RoundData({
            roundId: _roundId,
            answer: _answer,
            startedAt: _startedAt,
            updatedAt: _updatedAt,
            answeredInRound: _answeredInRound
        });
        if (_roundId > maxRound) {
            maxRound = _roundId;
        }
        roundDatas[_roundId] = data;
    }

    function latestRoundData()
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        RoundData memory data = roundDatas[maxRound];
        if (data.startedAt == 0) {
            return (data.roundId, data.answer, block.timestamp - 1, block.timestamp - 1, data.answeredInRound);
        }
        return (data.roundId, data.answer, data.startedAt, data.updatedAt, data.answeredInRound);
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.8.26;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MockCurveSwap {
    function exchange(
        address[4] memory _route,
        uint256[][] memory /*_swap_params*/,
        uint256 _amount,
        uint256 _min_dy,
        address[5] memory /*_pools*/,
        address _receiver
    ) public returns (uint256) {
        address input_token = _route[0];
        address output_token = address(0);
        uint256 amount = _amount;
        IERC20(input_token).transferFrom(msg.sender, address(this), _amount);

        for (uint i = 0; i < 1; i++) {
            output_token = _route[(i + 1) * 2];

            if (input_token == address(0)) {
                break;
            }

            // mock swap...
            amount = _min_dy;
            // if there is another swap, the output token becomes the input for the next round
            input_token = output_token;
        }

        IERC20(output_token).transfer(_receiver, amount);

        return amount;
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

/// @dev only used for importing ERC1967Proxy into compilation task
contract MockERC1967Proxy is ERC1967Proxy {
    constructor() ERC1967Proxy(address(0x0), bytes("")) {}
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.26;

import "../types/Side.sol";
import "../IWETHMinimum.sol";
import "../core/interfaces/IPSM.sol";
import "../libraries/LiquidityUtil.sol";
import "../libraries/PUSDManagerUtil.sol";
import {LPToken} from "../core/LPToken.sol";
import "../core/interfaces/IMarketLiquidity.sol";
import "../core/interfaces/IPUSDManagerCallback.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract MockMarketManager {
    LPToken public lpToken;
    PUSD public usd;
    IWETHMinimum public weth;

    uint64 public minPrice;
    uint64 public maxPrice;
    uint96 public payAmount;
    uint96 public receiveAmount;
    uint96 public spread;
    uint96 public actualMarginDelta;
    uint64 public tokenValue;
    uint96 public liquidity;
    bool public receivePUSD;
    mapping(IERC20 market => LPToken lpToken) public lpTokens;

    IPSM.CollateralState psmCollateralState;
    IMarketManager.LiquidityBufferModule public liquidityBufferModule;

    constructor(IWETHMinimum _weth) payable {
        usd = PUSDManagerUtil.deployPUSD();
        weth = _weth;
    }

    function deployLPToken(IERC20 _market, string calldata _tokenSymbol) external returns (LPToken) {
        lpToken = LiquidityUtil.deployLPToken(_market, _tokenSymbol);
        lpTokens[_market] = lpToken;
        return lpToken;
    }

    function setMinPrice(uint64 _minPrice) external {
        minPrice = _minPrice;
    }

    function setMaxPrice(uint64 _maxPrice) external {
        maxPrice = _maxPrice;
    }

    function setPSMCollateralState(IPSM.CollateralState calldata _state) external {
        psmCollateralState = _state;
    }

    function setPayAmount(uint96 _payAmount) external {
        payAmount = _payAmount;
    }

    function setReceiveAmount(uint96 _receiveAmount) external {
        receiveAmount = _receiveAmount;
    }

    function setSpread(uint96 _spread) external {
        spread = _spread;
    }

    function setActualMarginDelta(uint96 _actualMarginDelta) external {
        actualMarginDelta = _actualMarginDelta;
    }

    function setTokenValue(uint64 _tokenValue) external {
        tokenValue = _tokenValue;
    }

    function setLiquidity(uint96 _liquidity) external {
        liquidity = _liquidity;
    }

    function setReceivePUSD(bool _receivePUSD) external {
        receivePUSD = _receivePUSD;
    }

    function setLiquidityBufferModule(uint128 _pusdDebt, uint128 _tokenPayback) external {
        liquidityBufferModule.pusdDebt = _pusdDebt;
        liquidityBufferModule.tokenPayback = _tokenPayback;
    }

    function mintPUSD(
        IERC20 _market,
        bool /*_exactIn*/,
        uint96 /*_amount*/,
        IPUSDManagerCallback _callback,
        bytes calldata _data,
        address /*_receiver*/
    ) external returns (uint96, uint96) {
        _callback.PUSDManagerCallback(IERC20(address(_market)), payAmount, receiveAmount, _data);
        return (payAmount, receiveAmount);
    }

    function burnPUSD(
        IERC20 _market,
        bool /*_exactIn*/,
        uint96 /*_amount*/,
        IPUSDManagerCallback _callback,
        bytes calldata _data,
        address _receiver
    ) external returns (uint128, uint128) {
        _callback.PUSDManagerCallback(IERC20(address(usd)), payAmount, receiveAmount, _data);
        if (address(_market) == address(weth)) {
            weth.deposit{value: receiveAmount}();
            weth.transfer(_receiver, receiveAmount);
        }
        return (payAmount, receiveAmount);
    }

    function increasePosition(
        IERC20 /*_market*/,
        address /*_account*/,
        uint96 /*_sizeDelta*/
    ) external view returns (uint96) {
        return spread;
    }

    function decreasePosition(
        IERC20 _market,
        address /*_account*/,
        uint96 /*_marginDelta*/,
        uint96 /*_sizeDelta*/,
        address _receiver
    ) external returns (uint96, uint96) {
        if (address(_market) == address(weth)) {
            weth.deposit{value: actualMarginDelta}();
            weth.transfer(_receiver, actualMarginDelta);
        } else if (receivePUSD) {
            _market.transfer(_receiver, actualMarginDelta);
        }
        return (spread, actualMarginDelta);
    }

    function mintLPT(IERC20 /*_market*/, address /*_account*/, address /*_receiver*/) external view returns (uint128) {
        return tokenValue;
    }

    function burnLPT(IERC20 _market, address /*_account*/, address _receiver) external returns (uint128) {
        if (address(_market) == address(weth)) {
            weth.deposit{value: liquidity}();
            weth.transfer(_receiver, liquidity);
        } else if (receivePUSD) {
            _market.transfer(_receiver, liquidity);
        }
        return liquidity;
    }

    function pluginTransfer(IERC20 _token, address _from, address _to, uint256 _amount) external {
        SafeERC20.safeTransferFrom(_token, _from, _to, _amount);
    }

    function mintLPToken(IERC20 _market, address _to, uint256 _amount) external {
        lpTokens[_market].mint(_to, _amount);
    }

    function getPrice(IERC20 /* _market */) external view returns (uint64, uint64) {
        return (minPrice, maxPrice);
    }

    function psmCollateralStates(IERC20 /*_collateral*/) external view returns (IPSM.CollateralState memory state) {
        state = psmCollateralState;
    }

    function psmMintPUSD(IERC20 _collateral, address _receiver) external returns (uint64 /*receiveAmount*/) {
        usd.mint(_receiver, receiveAmount);
        uint128 balanceAfter = uint128(_collateral.balanceOf(address(this)));
        psmCollateralState.balance = balanceAfter;
        return uint64(receiveAmount);
    }

    function psmBurnPUSD(IERC20 /*_collateral*/, address /*_receiver*/) external returns (uint96 /*receiveAmount*/) {}

    function repayLiquidityBufferDebt(
        IERC20 _market,
        address /* _account */,
        address _receiver
    ) external returns (uint128 _receiveAmount) {
        uint128 amount = uint128(usd.balanceOf(address(this)));

        if (amount > liquidityBufferModule.pusdDebt) amount = liquidityBufferModule.pusdDebt;

        usd.burn(amount);
        unchecked {
            _receiveAmount = uint128(
                (uint256(liquidityBufferModule.tokenPayback) * amount) / liquidityBufferModule.pusdDebt
            );
            liquidityBufferModule.tokenPayback = liquidityBufferModule.tokenPayback - _receiveAmount;
            liquidityBufferModule.pusdDebt = liquidityBufferModule.pusdDebt - amount;
        }

        _market.transfer(_receiver, _receiveAmount);
        return _receiveAmount;
    }

    function liquidityBufferModules(
        IERC20 /* _market */
    ) external view returns (IMarketManager.LiquidityBufferModule memory) {
        return liquidityBufferModule;
    }

    function mintPUSDArbitrary(address to, uint256 amount) external {
        usd.mint(to, amount);
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.26;

import "../../contracts/plugins/interfaces/IPositionRouterCommon.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract MockPUSDManagerCallback {
    using SafeERC20 for *;

    IERC20 public payToken;
    uint96 public payAmount;
    uint96 public receiveAmount;
    uint96 public remaining;

    bool public ignoreTransfer;

    function setIgnoreTransfer() public {
        ignoreTransfer = true;
    }

    function PUSDManagerCallback(
        IERC20 _payToken,
        uint96 _payAmount,
        uint96 _receiveAmount,
        bytes calldata _data
    ) external {
        payToken = _payToken;
        payAmount = _payAmount;
        receiveAmount = _receiveAmount;

        IPositionRouterCommon.CallbackData memory data = abi.decode(_data, (IPositionRouterCommon.CallbackData));
        if (_payAmount > data.margin) revert IPositionRouterCommon.TooMuchPaid(_payAmount, data.margin);

        unchecked {
            // transfer remaining margin back to the account
            remaining = data.margin - _payAmount;
            if (remaining > 0) _payToken.safeTransfer(data.account, remaining);
        }

        // transfer pay token to the market manager
        if (!ignoreTransfer) _payToken.safeTransfer(msg.sender, _payAmount);
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.26;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MockPriceFeed {
    uint160 public minPriceX96;
    uint160 public maxPriceX96;

    function setMaxPriceX96(uint160 _maxPriceX96) external {
        maxPriceX96 = _maxPriceX96;
    }

    function setMinPriceX96(uint160 _minPriceX96) external {
        minPriceX96 = _minPriceX96;
    }

    function getMaxPriceX96(IERC20 /*_market*/) external view returns (uint160) {
        return maxPriceX96;
    }

    function getMinPriceX96(IERC20 /*_market*/) external view returns (uint160) {
        return minPriceX96;
    }

    function getPriceX96(IERC20 /*_market*/) external view returns (uint160, uint160) {
        return (minPriceX96, maxPriceX96);
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../libraries/PUSDManagerUtil.sol";

library PUSDManagerUtilTest {
    function mint(
        IMarketManager.State storage _state,
        IConfigurable.MarketConfig storage _cfg,
        PUSDManagerUtil.MintParam memory _param,
        bytes calldata _data
    ) public returns (uint96 payAmount, uint64 receiveAmount) {
        return PUSDManagerUtil.mint(_state, _cfg, _param, _data);
    }

    function burn(
        IMarketManager.State storage _state,
        IConfigurable.MarketConfig storage _cfg,
        PUSDManagerUtil.BurnParam memory _param,
        bytes calldata _data
    ) public returns (uint64 payAmount, uint96 receiveAmount) {
        return PUSDManagerUtil.burn(_state, _cfg, _param, _data);
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../libraries/PUSDManagerUtil.sol";

contract PUSDManagerUtilTest2 {
    function PUSD_INIT_CODE_HASH() public pure returns (bytes32) {
        return PUSDManagerUtil.PUSD_INIT_CODE_HASH;
    }

    function deployPUSD() public returns (PUSD pusd) {
        return PUSDManagerUtil.deployPUSD();
    }

    function computePUSDAddress() public view returns (address) {
        return PUSDManagerUtil.computePUSDAddress();
    }
}
/**
 *Submitted for verification at Etherscan.io on 2017-12-12
 */

// Copyright (C) 2015, 2016, 2017 Dapphub

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

pragma solidity ^0.8.0;

contract WETH9 {
    string public name = "Wrapped Ether";
    string public symbol = "WETH";
    uint8 public decimals = 18;

    event Approval(address indexed src, address indexed guy, uint wad);
    event Transfer(address indexed src, address indexed dst, uint wad);
    event Deposit(address indexed dst, uint wad);
    event Withdrawal(address indexed src, uint wad);

    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    receive() external payable {
        deposit();
    }

    function deposit() public payable {
        balanceOf[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint wad) public {
        require(balanceOf[msg.sender] >= wad);
        balanceOf[msg.sender] -= wad;
        payable(msg.sender).transfer(wad);
        emit Withdrawal(msg.sender, wad);
    }

    function totalSupply() public view returns (uint) {
        return address(this).balance;
    }

    function approve(address guy, uint wad) public returns (bool) {
        allowance[msg.sender][guy] = wad;
        emit Approval(msg.sender, guy, wad);
        return true;
    }

    function transfer(address dst, uint wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint wad) public returns (bool) {
        require(balanceOf[src] >= wad);

        if (src != msg.sender && allowance[src][msg.sender] != type(uint256).max) {
            require(allowance[src][msg.sender] >= wad);
            allowance[src][msg.sender] -= wad;
        }

        balanceOf[src] -= wad;
        balanceOf[dst] += wad;

        emit Transfer(src, dst, wad);

        return true;
    }
}

/*
                    GNU GENERAL PUBLIC LICENSE
                       Version 3, 29 June 2007

 Copyright (C) 2007 Free Software Foundation, Inc. <http://fsf.org/>
 Everyone is permitted to copy and distribute verbatim copies
 of this license document, but changing it is not allowed.

                            Preamble

  The GNU General Public License is a free, copyleft license for
software and other kinds of works.

  The licenses for most software and other practical works are designed
to take away your freedom to share and change the works.  By contrast,
the GNU General Public License is intended to guarantee your freedom to
share and change all versions of a program--to make sure it remains free
software for all its users.  We, the Free Software Foundation, use the
GNU General Public License for most of our software; it applies also to
any other work released this way by its authors.  You can apply it to
your programs, too.

  When we speak of free software, we are referring to freedom, not
price.  Our General Public Licenses are designed to make sure that you
have the freedom to distribute copies of free software (and charge for
them if you wish), that you receive source code or can get it if you
want it, that you can change the software or use pieces of it in new
free programs, and that you know you can do these things.

  To protect your rights, we need to prevent others from denying you
these rights or asking you to surrender the rights.  Therefore, you have
certain responsibilities if you distribute copies of the software, or if
you modify it: responsibilities to respect the freedom of others.

  For example, if you distribute copies of such a program, whether
gratis or for a fee, you must pass on to the recipients the same
freedoms that you received.  You must make sure that they, too, receive
or can get the source code.  And you must show them these terms so they
know their rights.

  Developers that use the GNU GPL protect your rights with two steps:
(1) assert copyright on the software, and (2) offer you this License
giving you legal permission to copy, distribute and/or modify it.

  For the developers' and authors' protection, the GPL clearly explains
that there is no warranty for this free software.  For both users' and
authors' sake, the GPL requires that modified versions be marked as
changed, so that their problems will not be attributed erroneously to
authors of previous versions.

  Some devices are designed to deny users access to install or run
modified versions of the software inside them, although the manufacturer
can do so.  This is fundamentally incompatible with the aim of
protecting users' freedom to change the software.  The systematic
pattern of such abuse occurs in the area of products for individuals to
use, which is precisely where it is most unacceptable.  Therefore, we
have designed this version of the GPL to prohibit the practice for those
products.  If such problems arise substantially in other domains, we
stand ready to extend this provision to those domains in future versions
of the GPL, as needed to protect the freedom of users.

  Finally, every program is threatened constantly by software patents.
States should not allow patents to restrict development and use of
software on general-purpose computers, but in those that do, we wish to
avoid the special danger that patents applied to a free program could
make it effectively proprietary.  To prevent this, the GPL assures that
patents cannot be used to render the program non-free.

  The precise terms and conditions for copying, distribution and
modification follow.

                       TERMS AND CONDITIONS

  0. Definitions.

  "This License" refers to version 3 of the GNU General Public License.

  "Copyright" also means copyright-like laws that apply to other kinds of
works, such as semiconductor masks.

  "The Program" refers to any copyrightable work licensed under this
License.  Each licensee is addressed as "you".  "Licensees" and
"recipients" may be individuals or organizations.

  To "modify" a work means to copy from or adapt all or part of the work
in a fashion requiring copyright permission, other than the making of an
exact copy.  The resulting work is called a "modified version" of the
earlier work or a work "based on" the earlier work.

  A "covered work" means either the unmodified Program or a work based
on the Program.

  To "propagate" a work means to do anything with it that, without
permission, would make you directly or secondarily liable for
infringement under applicable copyright law, except executing it on a
computer or modifying a private copy.  Propagation includes copying,
distribution (with or without modification), making available to the
public, and in some countries other activities as well.

  To "convey" a work means any kind of propagation that enables other
parties to make or receive copies.  Mere interaction with a user through
a computer network, with no transfer of a copy, is not conveying.

  An interactive user interface displays "Appropriate Legal Notices"
to the extent that it includes a convenient and prominently visible
feature that (1) displays an appropriate copyright notice, and (2)
tells the user that there is no warranty for the work (except to the
extent that warranties are provided), that licensees may convey the
work under this License, and how to view a copy of this License.  If
the interface presents a list of user commands or options, such as a
menu, a prominent item in the list meets this criterion.

  1. Source Code.

  The "source code" for a work means the preferred form of the work
for making modifications to it.  "Object code" means any non-source
form of a work.

  A "Standard Interface" means an interface that either is an official
standard defined by a recognized standards body, or, in the case of
interfaces specified for a particular programming language, one that
is widely used among developers working in that language.

  The "System Libraries" of an executable work include anything, other
than the work as a whole, that (a) is included in the normal form of
packaging a Major Component, but which is not part of that Major
Component, and (b) serves only to enable use of the work with that
Major Component, or to implement a Standard Interface for which an
implementation is available to the public in source code form.  A
"Major Component", in this context, means a major essential component
(kernel, window system, and so on) of the specific operating system
(if any) on which the executable work runs, or a compiler used to
produce the work, or an object code interpreter used to run it.

  The "Corresponding Source" for a work in object code form means all
the source code needed to generate, install, and (for an executable
work) run the object code and to modify the work, including scripts to
control those activities.  However, it does not include the work's
System Libraries, or general-purpose tools or generally available free
programs which are used unmodified in performing those activities but
which are not part of the work.  For example, Corresponding Source
includes interface definition files associated with source files for
the work, and the source code for shared libraries and dynamically
linked subprograms that the work is specifically designed to require,
such as by intimate data communication or control flow between those
subprograms and other parts of the work.

  The Corresponding Source need not include anything that users
can regenerate automatically from other parts of the Corresponding
Source.

  The Corresponding Source for a work in source code form is that
same work.

  2. Basic Permissions.

  All rights granted under this License are granted for the term of
copyright on the Program, and are irrevocable provided the stated
conditions are met.  This License explicitly affirms your unlimited
permission to run the unmodified Program.  The output from running a
covered work is covered by this License only if the output, given its
content, constitutes a covered work.  This License acknowledges your
rights of fair use or other equivalent, as provided by copyright law.

  You may make, run and propagate covered works that you do not
convey, without conditions so long as your license otherwise remains
in force.  You may convey covered works to others for the sole purpose
of having them make modifications exclusively for you, or provide you
with facilities for running those works, provided that you comply with
the terms of this License in conveying all material for which you do
not control copyright.  Those thus making or running the covered works
for you must do so exclusively on your behalf, under your direction
and control, on terms that prohibit them from making any copies of
your copyrighted material outside their relationship with you.

  Conveying under any other circumstances is permitted solely under
the conditions stated below.  Sublicensing is not allowed; section 10
makes it unnecessary.

  3. Protecting Users' Legal Rights From Anti-Circumvention Law.

  No covered work shall be deemed part of an effective technological
measure under any applicable law fulfilling obligations under article
11 of the WIPO copyright treaty adopted on 20 December 1996, or
similar laws prohibiting or restricting circumvention of such
measures.

  When you convey a covered work, you waive any legal power to forbid
circumvention of technological measures to the extent such circumvention
is effected by exercising rights under this License with respect to
the covered work, and you disclaim any intention to limit operation or
modification of the work as a means of enforcing, against the work's
users, your or third parties' legal rights to forbid circumvention of
technological measures.

  4. Conveying Verbatim Copies.

  You may convey verbatim copies of the Program's source code as you
receive it, in any medium, provided that you conspicuously and
appropriately publish on each copy an appropriate copyright notice;
keep intact all notices stating that this License and any
non-permissive terms added in accord with section 7 apply to the code;
keep intact all notices of the absence of any warranty; and give all
recipients a copy of this License along with the Program.

  You may charge any price or no price for each copy that you convey,
and you may offer support or warranty protection for a fee.

  5. Conveying Modified Source Versions.

  You may convey a work based on the Program, or the modifications to
produce it from the Program, in the form of source code under the
terms of section 4, provided that you also meet all of these conditions:

    a) The work must carry prominent notices stating that you modified
    it, and giving a relevant date.

    b) The work must carry prominent notices stating that it is
    released under this License and any conditions added under section
    7.  This requirement modifies the requirement in section 4 to
    "keep intact all notices".

    c) You must license the entire work, as a whole, under this
    License to anyone who comes into possession of a copy.  This
    License will therefore apply, along with any applicable section 7
    additional terms, to the whole of the work, and all its parts,
    regardless of how they are packaged.  This License gives no
    permission to license the work in any other way, but it does not
    invalidate such permission if you have separately received it.

    d) If the work has interactive user interfaces, each must display
    Appropriate Legal Notices; however, if the Program has interactive
    interfaces that do not display Appropriate Legal Notices, your
    work need not make them do so.

  A compilation of a covered work with other separate and independent
works, which are not by their nature extensions of the covered work,
and which are not combined with it such as to form a larger program,
in or on a volume of a storage or distribution medium, is called an
"aggregate" if the compilation and its resulting copyright are not
used to limit the access or legal rights of the compilation's users
beyond what the individual works permit.  Inclusion of a covered work
in an aggregate does not cause this License to apply to the other
parts of the aggregate.

  6. Conveying Non-Source Forms.

  You may convey a covered work in object code form under the terms
of sections 4 and 5, provided that you also convey the
machine-readable Corresponding Source under the terms of this License,
in one of these ways:

    a) Convey the object code in, or embodied in, a physical product
    (including a physical distribution medium), accompanied by the
    Corresponding Source fixed on a durable physical medium
    customarily used for software interchange.

    b) Convey the object code in, or embodied in, a physical product
    (including a physical distribution medium), accompanied by a
    written offer, valid for at least three years and valid for as
    long as you offer spare parts or customer support for that product
    model, to give anyone who possesses the object code either (1) a
    copy of the Corresponding Source for all the software in the
    product that is covered by this License, on a durable physical
    medium customarily used for software interchange, for a price no
    more than your reasonable cost of physically performing this
    conveying of source, or (2) access to copy the
    Corresponding Source from a network server at no charge.

    c) Convey individual copies of the object code with a copy of the
    written offer to provide the Corresponding Source.  This
    alternative is allowed only occasionally and noncommercially, and
    only if you received the object code with such an offer, in accord
    with subsection 6b.

    d) Convey the object code by offering access from a designated
    place (gratis or for a charge), and offer equivalent access to the
    Corresponding Source in the same way through the same place at no
    further charge.  You need not require recipients to copy the
    Corresponding Source along with the object code.  If the place to
    copy the object code is a network server, the Corresponding Source
    may be on a different server (operated by you or a third party)
    that supports equivalent copying facilities, provided you maintain
    clear directions next to the object code saying where to find the
    Corresponding Source.  Regardless of what server hosts the
    Corresponding Source, you remain obligated to ensure that it is
    available for as long as needed to satisfy these requirements.

    e) Convey the object code using peer-to-peer transmission, provided
    you inform other peers where the object code and Corresponding
    Source of the work are being offered to the general public at no
    charge under subsection 6d.

  A separable portion of the object code, whose source code is excluded
from the Corresponding Source as a System Library, need not be
included in conveying the object code work.

  A "User Product" is either (1) a "consumer product", which means any
tangible personal property which is normally used for personal, family,
or household purposes, or (2) anything designed or sold for incorporation
into a dwelling.  In determining whether a product is a consumer product,
doubtful cases shall be resolved in favor of coverage.  For a particular
product received by a particular user, "normally used" refers to a
typical or common use of that class of product, regardless of the status
of the particular user or of the way in which the particular user
actually uses, or expects or is expected to use, the product.  A product
is a consumer product regardless of whether the product has substantial
commercial, industrial or non-consumer uses, unless such uses represent
the only significant mode of use of the product.

  "Installation Information" for a User Product means any methods,
procedures, authorization keys, or other information required to install
and execute modified versions of a covered work in that User Product from
a modified version of its Corresponding Source.  The information must
suffice to ensure that the continued functioning of the modified object
code is in no case prevented or interfered with solely because
modification has been made.

  If you convey an object code work under this section in, or with, or
specifically for use in, a User Product, and the conveying occurs as
part of a transaction in which the right of possession and use of the
User Product is transferred to the recipient in perpetuity or for a
fixed term (regardless of how the transaction is characterized), the
Corresponding Source conveyed under this section must be accompanied
by the Installation Information.  But this requirement does not apply
if neither you nor any third party retains the ability to install
modified object code on the User Product (for example, the work has
been installed in ROM).

  The requirement to provide Installation Information does not include a
requirement to continue to provide support service, warranty, or updates
for a work that has been modified or installed by the recipient, or for
the User Product in which it has been modified or installed.  Access to a
network may be denied when the modification itself materially and
adversely affects the operation of the network or violates the rules and
protocols for communication across the network.

  Corresponding Source conveyed, and Installation Information provided,
in accord with this section must be in a format that is publicly
documented (and with an implementation available to the public in
source code form), and must require no special password or key for
unpacking, reading or copying.

  7. Additional Terms.

  "Additional permissions" are terms that supplement the terms of this
License by making exceptions from one or more of its conditions.
Additional permissions that are applicable to the entire Program shall
be treated as though they were included in this License, to the extent
that they are valid under applicable law.  If additional permissions
apply only to part of the Program, that part may be used separately
under those permissions, but the entire Program remains governed by
this License without regard to the additional permissions.

  When you convey a copy of a covered work, you may at your option
remove any additional permissions from that copy, or from any part of
it.  (Additional permissions may be written to require their own
removal in certain cases when you modify the work.)  You may place
additional permissions on material, added by you to a covered work,
for which you have or can give appropriate copyright permission.

  Notwithstanding any other provision of this License, for material you
add to a covered work, you may (if authorized by the copyright holders of
that material) supplement the terms of this License with terms:

    a) Disclaiming warranty or limiting liability differently from the
    terms of sections 15 and 16 of this License; or

    b) Requiring preservation of specified reasonable legal notices or
    author attributions in that material or in the Appropriate Legal
    Notices displayed by works containing it; or

    c) Prohibiting misrepresentation of the origin of that material, or
    requiring that modified versions of such material be marked in
    reasonable ways as different from the original version; or

    d) Limiting the use for publicity purposes of names of licensors or
    authors of the material; or

    e) Declining to grant rights under trademark law for use of some
    trade names, trademarks, or service marks; or

    f) Requiring indemnification of licensors and authors of that
    material by anyone who conveys the material (or modified versions of
    it) with contractual assumptions of liability to the recipient, for
    any liability that these contractual assumptions directly impose on
    those licensors and authors.

  All other non-permissive additional terms are considered "further
restrictions" within the meaning of section 10.  If the Program as you
received it, or any part of it, contains a notice stating that it is
governed by this License along with a term that is a further
restriction, you may remove that term.  If a license document contains
a further restriction but permits relicensing or conveying under this
License, you may add to a covered work material governed by the terms
of that license document, provided that the further restriction does
not survive such relicensing or conveying.

  If you add terms to a covered work in accord with this section, you
must place, in the relevant source files, a statement of the
additional terms that apply to those files, or a notice indicating
where to find the applicable terms.

  Additional terms, permissive or non-permissive, may be stated in the
form of a separately written license, or stated as exceptions;
the above requirements apply either way.

  8. Termination.

  You may not propagate or modify a covered work except as expressly
provided under this License.  Any attempt otherwise to propagate or
modify it is void, and will automatically terminate your rights under
this License (including any patent licenses granted under the third
paragraph of section 11).

  However, if you cease all violation of this License, then your
license from a particular copyright holder is reinstated (a)
provisionally, unless and until the copyright holder explicitly and
finally terminates your license, and (b) permanently, if the copyright
holder fails to notify you of the violation by some reasonable means
prior to 60 days after the cessation.

  Moreover, your license from a particular copyright holder is
reinstated permanently if the copyright holder notifies you of the
violation by some reasonable means, this is the first time you have
received notice of violation of this License (for any work) from that
copyright holder, and you cure the violation prior to 30 days after
your receipt of the notice.

  Termination of your rights under this section does not terminate the
licenses of parties who have received copies or rights from you under
this License.  If your rights have been terminated and not permanently
reinstated, you do not qualify to receive new licenses for the same
material under section 10.

  9. Acceptance Not Required for Having Copies.

  You are not required to accept this License in order to receive or
run a copy of the Program.  Ancillary propagation of a covered work
occurring solely as a consequence of using peer-to-peer transmission
to receive a copy likewise does not require acceptance.  However,
nothing other than this License grants you permission to propagate or
modify any covered work.  These actions infringe copyright if you do
not accept this License.  Therefore, by modifying or propagating a
covered work, you indicate your acceptance of this License to do so.

  10. Automatic Licensing of Downstream Recipients.

  Each time you convey a covered work, the recipient automatically
receives a license from the original licensors, to run, modify and
propagate that work, subject to this License.  You are not responsible
for enforcing compliance by third parties with this License.

  An "entity transaction" is a transaction transferring control of an
organization, or substantially all assets of one, or subdividing an
organization, or merging organizations.  If propagation of a covered
work results from an entity transaction, each party to that
transaction who receives a copy of the work also receives whatever
licenses to the work the party's predecessor in interest had or could
give under the previous paragraph, plus a right to possession of the
Corresponding Source of the work from the predecessor in interest, if
the predecessor has it or can get it with reasonable efforts.

  You may not impose any further restrictions on the exercise of the
rights granted or affirmed under this License.  For example, you may
not impose a license fee, royalty, or other charge for exercise of
rights granted under this License, and you may not initiate litigation
(including a cross-claim or counterclaim in a lawsuit) alleging that
any patent claim is infringed by making, using, selling, offering for
sale, or importing the Program or any portion of it.

  11. Patents.

  A "contributor" is a copyright holder who authorizes use under this
License of the Program or a work on which the Program is based.  The
work thus licensed is called the contributor's "contributor version".

  A contributor's "essential patent claims" are all patent claims
owned or controlled by the contributor, whether already acquired or
hereafter acquired, that would be infringed by some manner, permitted
by this License, of making, using, or selling its contributor version,
but do not include claims that would be infringed only as a
consequence of further modification of the contributor version.  For
purposes of this definition, "control" includes the right to grant
patent sublicenses in a manner consistent with the requirements of
this License.

  Each contributor grants you a non-exclusive, worldwide, royalty-free
patent license under the contributor's essential patent claims, to
make, use, sell, offer for sale, import and otherwise run, modify and
propagate the contents of its contributor version.

  In the following three paragraphs, a "patent license" is any express
agreement or commitment, however denominated, not to enforce a patent
(such as an express permission to practice a patent or covenant not to
sue for patent infringement).  To "grant" such a patent license to a
party means to make such an agreement or commitment not to enforce a
patent against the party.

  If you convey a covered work, knowingly relying on a patent license,
and the Corresponding Source of the work is not available for anyone
to copy, free of charge and under the terms of this License, through a
publicly available network server or other readily accessible means,
then you must either (1) cause the Corresponding Source to be so
available, or (2) arrange to deprive yourself of the benefit of the
patent license for this particular work, or (3) arrange, in a manner
consistent with the requirements of this License, to extend the patent
license to downstream recipients.  "Knowingly relying" means you have
actual knowledge that, but for the patent license, your conveying the
covered work in a country, or your recipient's use of the covered work
in a country, would infringe one or more identifiable patents in that
country that you have reason to believe are valid.

  If, pursuant to or in connection with a single transaction or
arrangement, you convey, or propagate by procuring conveyance of, a
covered work, and grant a patent license to some of the parties
receiving the covered work authorizing them to use, propagate, modify
or convey a specific copy of the covered work, then the patent license
you grant is automatically extended to all recipients of the covered
work and works based on it.

  A patent license is "discriminatory" if it does not include within
the scope of its coverage, prohibits the exercise of, or is
conditioned on the non-exercise of one or more of the rights that are
specifically granted under this License.  You may not convey a covered
work if you are a party to an arrangement with a third party that is
in the business of distributing software, under which you make payment
to the third party based on the extent of your activity of conveying
the work, and under which the third party grants, to any of the
parties who would receive the covered work from you, a discriminatory
patent license (a) in connection with copies of the covered work
conveyed by you (or copies made from those copies), or (b) primarily
for and in connection with specific products or compilations that
contain the covered work, unless you entered into that arrangement,
or that patent license was granted, prior to 28 March 2007.

  Nothing in this License shall be construed as excluding or limiting
any implied license or other defenses to infringement that may
otherwise be available to you under applicable patent law.

  12. No Surrender of Others' Freedom.

  If conditions are imposed on you (whether by court order, agreement or
otherwise) that contradict the conditions of this License, they do not
excuse you from the conditions of this License.  If you cannot convey a
covered work so as to satisfy simultaneously your obligations under this
License and any other pertinent obligations, then as a consequence you may
not convey it at all.  For example, if you agree to terms that obligate you
to collect a royalty for further conveying from those to whom you convey
the Program, the only way you could satisfy both those terms and this
License would be to refrain entirely from conveying the Program.

  13. Use with the GNU Affero General Public License.

  Notwithstanding any other provision of this License, you have
permission to link or combine any covered work with a work licensed
under version 3 of the GNU Affero General Public License into a single
combined work, and to convey the resulting work.  The terms of this
License will continue to apply to the part which is the covered work,
but the special requirements of the GNU Affero General Public License,
section 13, concerning interaction through a network will apply to the
combination as such.

  14. Revised Versions of this License.

  The Free Software Foundation may publish revised and/or new versions of
the GNU General Public License from time to time.  Such new versions will
be similar in spirit to the present version, but may differ in detail to
address new problems or concerns.

  Each version is given a distinguishing version number.  If the
Program specifies that a certain numbered version of the GNU General
Public License "or any later version" applies to it, you have the
option of following the terms and conditions either of that numbered
version or of any later version published by the Free Software
Foundation.  If the Program does not specify a version number of the
GNU General Public License, you may choose any version ever published
by the Free Software Foundation.

  If the Program specifies that a proxy can decide which future
versions of the GNU General Public License can be used, that proxy's
public statement of acceptance of a version permanently authorizes you
to choose that version for the Program.

  Later license versions may give you additional or different
permissions.  However, no additional obligations are imposed on any
author or copyright holder as a result of your choosing to follow a
later version.

  15. Disclaimer of Warranty.

  THERE IS NO WARRANTY FOR THE PROGRAM, TO THE EXTENT PERMITTED BY
APPLICABLE LAW.  EXCEPT WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT
HOLDERS AND/OR OTHER PARTIES PROVIDE THE PROGRAM "AS IS" WITHOUT WARRANTY
OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO,
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE.  THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE PROGRAM
IS WITH YOU.  SHOULD THE PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF
ALL NECESSARY SERVICING, REPAIR OR CORRECTION.

  16. Limitation of Liability.

  IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MODIFIES AND/OR CONVEYS
THE PROGRAM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES, INCLUDING ANY
GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE
USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED TO LOSS OF
DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD
PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER PROGRAMS),
EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

  17. Interpretation of Sections 15 and 16.

  If the disclaimer of warranty and limitation of liability provided
above cannot be given local legal effect according to their terms,
reviewing courts shall apply local law that most closely approximates
an absolute waiver of all civil liability in connection with the
Program, unless a warranty or assumption of liability accompanies a
copy of the Program in return for a fee.

                     END OF TERMS AND CONDITIONS

            How to Apply These Terms to Your New Programs

  If you develop a new program, and you want it to be of the greatest
possible use to the public, the best way to achieve this is to make it
free software which everyone can redistribute and change under these terms.

  To do so, attach the following notices to the program.  It is safest
to attach them to the start of each source file to most effectively
state the exclusion of warranty; and each file should have at least
the "copyright" line and a pointer to where the full notice is found.

    <one line to give the program's name and a brief idea of what it does.>
    Copyright (C) <year>  <name of author>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

Also add information on how to contact you by electronic and paper mail.

  If the program does terminal interaction, make it output a short
notice like this when it starts in an interactive mode:

    <program>  Copyright (C) <year>  <name of author>
    This program comes with ABSOLUTELY NO WARRANTY; for details type `show w'.
    This is free software, and you are welcome to redistribute it
    under certain conditions; type `show c' for details.

The hypothetical commands `show w' and `show c' should show the appropriate
parts of the General Public License.  Of course, your program's commands
might be different; for a GUI interface, you would use an "about box".

  You should also get your employer (if you work as a programmer) or school,
if any, to sign a "copyright disclaimer" for the program, if necessary.
For more information on this, and how to apply and follow the GNU GPL, see
<http://www.gnu.org/licenses/>.

  The GNU General Public License does not permit incorporating your program
into proprietary programs.  If your program is a subroutine library, you
may consider it more useful to permit linking proprietary applications with
the library.  If this is what you want to do, use the GNU Lesser General
Public License instead of this License.  But first, please read
<http://www.gnu.org/philosophy/why-not-lgpl.html>.

*/
// This file was procedurally generated from scripts/generate/PackedValue.template.js, DO NOT MODIFY MANUALLY
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

type PackedValue is uint256;

using {
    packAddress,
    unpackAddress,
    packBool,
    unpackBool,
    packUint8,
    unpackUint8,
    packUint16,
    unpackUint16,
    packUint24,
    unpackUint24,
    packUint32,
    unpackUint32,
    packUint40,
    unpackUint40,
    packUint48,
    unpackUint48,
    packUint56,
    unpackUint56,
    packUint64,
    unpackUint64,
    packUint72,
    unpackUint72,
    packUint80,
    unpackUint80,
    packUint88,
    unpackUint88,
    packUint96,
    unpackUint96,
    packUint104,
    unpackUint104,
    packUint112,
    unpackUint112,
    packUint120,
    unpackUint120,
    packUint128,
    unpackUint128,
    packUint136,
    unpackUint136,
    packUint144,
    unpackUint144,
    packUint152,
    unpackUint152,
    packUint160,
    unpackUint160,
    packUint168,
    unpackUint168,
    packUint176,
    unpackUint176,
    packUint184,
    unpackUint184,
    packUint192,
    unpackUint192,
    packUint200,
    unpackUint200,
    packUint208,
    unpackUint208,
    packUint216,
    unpackUint216,
    packUint224,
    unpackUint224,
    packUint232,
    unpackUint232,
    packUint240,
    unpackUint240,
    packUint248,
    unpackUint248
} for PackedValue global;

function packUint8(PackedValue self, uint8 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint8(PackedValue self, uint8 position) pure returns (uint8) {
    return uint8((PackedValue.unwrap(self) >> position) & 0xff);
}

function packUint16(PackedValue self, uint16 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint16(PackedValue self, uint8 position) pure returns (uint16) {
    return uint16((PackedValue.unwrap(self) >> position) & 0xffff);
}

function packUint24(PackedValue self, uint24 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint24(PackedValue self, uint8 position) pure returns (uint24) {
    return uint24((PackedValue.unwrap(self) >> position) & 0xffffff);
}

function packUint32(PackedValue self, uint32 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint32(PackedValue self, uint8 position) pure returns (uint32) {
    return uint32((PackedValue.unwrap(self) >> position) & 0xffffffff);
}

function packUint40(PackedValue self, uint40 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint40(PackedValue self, uint8 position) pure returns (uint40) {
    return uint40((PackedValue.unwrap(self) >> position) & 0xffffffffff);
}

function packUint48(PackedValue self, uint48 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint48(PackedValue self, uint8 position) pure returns (uint48) {
    return uint48((PackedValue.unwrap(self) >> position) & 0xffffffffffff);
}

function packUint56(PackedValue self, uint56 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint56(PackedValue self, uint8 position) pure returns (uint56) {
    return uint56((PackedValue.unwrap(self) >> position) & 0xffffffffffffff);
}

function packUint64(PackedValue self, uint64 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint64(PackedValue self, uint8 position) pure returns (uint64) {
    return uint64((PackedValue.unwrap(self) >> position) & 0xffffffffffffffff);
}

function packUint72(PackedValue self, uint72 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint72(PackedValue self, uint8 position) pure returns (uint72) {
    return uint72((PackedValue.unwrap(self) >> position) & 0xffffffffffffffffff);
}

function packUint80(PackedValue self, uint80 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint80(PackedValue self, uint8 position) pure returns (uint80) {
    return uint80((PackedValue.unwrap(self) >> position) & 0xffffffffffffffffffff);
}

function packUint88(PackedValue self, uint88 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint88(PackedValue self, uint8 position) pure returns (uint88) {
    return uint88((PackedValue.unwrap(self) >> position) & 0xffffffffffffffffffffff);
}

function packUint96(PackedValue self, uint96 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint96(PackedValue self, uint8 position) pure returns (uint96) {
    return uint96((PackedValue.unwrap(self) >> position) & 0xffffffffffffffffffffffff);
}

function packUint104(PackedValue self, uint104 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint104(PackedValue self, uint8 position) pure returns (uint104) {
    return uint104((PackedValue.unwrap(self) >> position) & 0xffffffffffffffffffffffffff);
}

function packUint112(PackedValue self, uint112 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint112(PackedValue self, uint8 position) pure returns (uint112) {
    return uint112((PackedValue.unwrap(self) >> position) & 0xffffffffffffffffffffffffffff);
}

function packUint120(PackedValue self, uint120 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint120(PackedValue self, uint8 position) pure returns (uint120) {
    return uint120((PackedValue.unwrap(self) >> position) & 0xffffffffffffffffffffffffffffff);
}

function packUint128(PackedValue self, uint128 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint128(PackedValue self, uint8 position) pure returns (uint128) {
    return uint128((PackedValue.unwrap(self) >> position) & 0xffffffffffffffffffffffffffffffff);
}

function packUint136(PackedValue self, uint136 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint136(PackedValue self, uint8 position) pure returns (uint136) {
    return uint136((PackedValue.unwrap(self) >> position) & 0xffffffffffffffffffffffffffffffffff);
}

function packUint144(PackedValue self, uint144 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint144(PackedValue self, uint8 position) pure returns (uint144) {
    return uint144((PackedValue.unwrap(self) >> position) & 0xffffffffffffffffffffffffffffffffffff);
}

function packUint152(PackedValue self, uint152 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint152(PackedValue self, uint8 position) pure returns (uint152) {
    return uint152((PackedValue.unwrap(self) >> position) & 0xffffffffffffffffffffffffffffffffffffff);
}

function packUint160(PackedValue self, uint160 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint160(PackedValue self, uint8 position) pure returns (uint160) {
    return uint160((PackedValue.unwrap(self) >> position) & 0x00ffffffffffffffffffffffffffffffffffffffff);
}

function packUint168(PackedValue self, uint168 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint168(PackedValue self, uint8 position) pure returns (uint168) {
    return uint168((PackedValue.unwrap(self) >> position) & 0xffffffffffffffffffffffffffffffffffffffffff);
}

function packUint176(PackedValue self, uint176 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint176(PackedValue self, uint8 position) pure returns (uint176) {
    return uint176((PackedValue.unwrap(self) >> position) & 0xffffffffffffffffffffffffffffffffffffffffffff);
}

function packUint184(PackedValue self, uint184 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint184(PackedValue self, uint8 position) pure returns (uint184) {
    return uint184((PackedValue.unwrap(self) >> position) & 0xffffffffffffffffffffffffffffffffffffffffffffff);
}

function packUint192(PackedValue self, uint192 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint192(PackedValue self, uint8 position) pure returns (uint192) {
    return uint192((PackedValue.unwrap(self) >> position) & 0xffffffffffffffffffffffffffffffffffffffffffffffff);
}

function packUint200(PackedValue self, uint200 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint200(PackedValue self, uint8 position) pure returns (uint200) {
    return uint200((PackedValue.unwrap(self) >> position) & 0xffffffffffffffffffffffffffffffffffffffffffffffffff);
}

function packUint208(PackedValue self, uint208 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint208(PackedValue self, uint8 position) pure returns (uint208) {
    return uint208((PackedValue.unwrap(self) >> position) & 0xffffffffffffffffffffffffffffffffffffffffffffffffffff);
}

function packUint216(PackedValue self, uint216 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint216(PackedValue self, uint8 position) pure returns (uint216) {
    return uint216((PackedValue.unwrap(self) >> position) & 0xffffffffffffffffffffffffffffffffffffffffffffffffffffff);
}

function packUint224(PackedValue self, uint224 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint224(PackedValue self, uint8 position) pure returns (uint224) {
    return uint224((PackedValue.unwrap(self) >> position) & 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
}

function packUint232(PackedValue self, uint232 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint232(PackedValue self, uint8 position) pure returns (uint232) {
    return
        uint232((PackedValue.unwrap(self) >> position) & 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
}

function packUint240(PackedValue self, uint240 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint240(PackedValue self, uint8 position) pure returns (uint240) {
    return
        uint240(
            (PackedValue.unwrap(self) >> position) & 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
        );
}

function packUint248(PackedValue self, uint248 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint248(PackedValue self, uint8 position) pure returns (uint248) {
    return
        uint248(
            (PackedValue.unwrap(self) >> position) & 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
        );
}

function packBool(PackedValue self, bool value, uint8 position) pure returns (PackedValue) {
    return packUint8(self, value ? 1 : 0, position);
}

function unpackBool(PackedValue self, uint8 position) pure returns (bool) {
    return ((PackedValue.unwrap(self) >> position) & 0x1) == 1;
}

function packAddress(PackedValue self, address value, uint8 position) pure returns (PackedValue) {
    return packUint160(self, uint160(value), position);
}

function unpackAddress(PackedValue self, uint8 position) pure returns (address) {
    return address(unpackUint160(self, position));
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

Side constant LONG = Side.wrap(1);
Side constant SHORT = Side.wrap(2);

type Side is uint8;

error InvalidSide(Side side);

using {requireValid, isLong, isShort, flip, eq as ==} for Side global;

function requireValid(Side self) pure {
    if (!isLong(self) && !isShort(self)) revert InvalidSide(self);
}

function isLong(Side self) pure returns (bool) {
    return Side.unwrap(self) == Side.unwrap(LONG);
}

function isShort(Side self) pure returns (bool) {
    return Side.unwrap(self) == Side.unwrap(SHORT);
}

function eq(Side self, Side other) pure returns (bool) {
    return Side.unwrap(self) == Side.unwrap(other);
}

function flip(Side self) pure returns (Side) {
    return isLong(self) ? SHORT : LONG;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Arithmetic library with operations for fixed-point numbers.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/FixedPointMathLib.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/FixedPointMathLib.sol)
library FixedPointMathLib {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       CUSTOM ERRORS                        */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The operation failed, as the output exceeds the maximum value of uint256.
    error ExpOverflow();

    /// @dev The operation failed, as the output exceeds the maximum value of uint256.
    error FactorialOverflow();

    /// @dev The operation failed, due to an overflow.
    error RPowOverflow();

    /// @dev The mantissa is too big to fit.
    error MantissaOverflow();

    /// @dev The operation failed, due to an multiplication overflow.
    error MulWadFailed();

    /// @dev The operation failed, due to an multiplication overflow.
    error SMulWadFailed();

    /// @dev The operation failed, either due to a multiplication overflow, or a division by a zero.
    error DivWadFailed();

    /// @dev The operation failed, either due to a multiplication overflow, or a division by a zero.
    error SDivWadFailed();

    /// @dev The operation failed, either due to a multiplication overflow, or a division by a zero.
    error MulDivFailed();

    /// @dev The division failed, as the denominator is zero.
    error DivFailed();

    /// @dev The full precision multiply-divide operation failed, either due
    /// to the result being larger than 256 bits, or a division by a zero.
    error FullMulDivFailed();

    /// @dev The output is undefined, as the input is less-than-or-equal to zero.
    error LnWadUndefined();

    /// @dev The input outside the acceptable domain.
    error OutOfDomain();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         CONSTANTS                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The scalar of ETH and most ERC20s.
    uint256 internal constant WAD = 1e18;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*              SIMPLIFIED FIXED POINT OPERATIONS             */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Equivalent to `(x * y) / WAD` rounded down.
    function mulWad(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Equivalent to `require(y == 0 || x <= type(uint256).max / y)`.
            if mul(y, gt(x, div(not(0), y))) {
                mstore(0x00, 0xbac65e5b) // `MulWadFailed()`.
                revert(0x1c, 0x04)
            }
            z := div(mul(x, y), WAD)
        }
    }

    /// @dev Equivalent to `(x * y) / WAD` rounded down.
    function sMulWad(int256 x, int256 y) internal pure returns (int256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := mul(x, y)
            // Equivalent to `require((x == 0 || z / x == y) && !(x == -1 && y == type(int256).min))`.
            if iszero(gt(or(iszero(x), eq(sdiv(z, x), y)), lt(not(x), eq(y, shl(255, 1))))) {
                mstore(0x00, 0xedcd4dd4) // `SMulWadFailed()`.
                revert(0x1c, 0x04)
            }
            z := sdiv(z, WAD)
        }
    }

    /// @dev Equivalent to `(x * y) / WAD` rounded down, but without overflow checks.
    function rawMulWad(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := div(mul(x, y), WAD)
        }
    }

    /// @dev Equivalent to `(x * y) / WAD` rounded down, but without overflow checks.
    function rawSMulWad(int256 x, int256 y) internal pure returns (int256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := sdiv(mul(x, y), WAD)
        }
    }

    /// @dev Equivalent to `(x * y) / WAD` rounded up.
    function mulWadUp(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Equivalent to `require(y == 0 || x <= type(uint256).max / y)`.
            if mul(y, gt(x, div(not(0), y))) {
                mstore(0x00, 0xbac65e5b) // `MulWadFailed()`.
                revert(0x1c, 0x04)
            }
            z := add(iszero(iszero(mod(mul(x, y), WAD))), div(mul(x, y), WAD))
        }
    }

    /// @dev Equivalent to `(x * y) / WAD` rounded up, but without overflow checks.
    function rawMulWadUp(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := add(iszero(iszero(mod(mul(x, y), WAD))), div(mul(x, y), WAD))
        }
    }

    /// @dev Equivalent to `(x * WAD) / y` rounded down.
    function divWad(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Equivalent to `require(y != 0 && (WAD == 0 || x <= type(uint256).max / WAD))`.
            if iszero(mul(y, iszero(mul(WAD, gt(x, div(not(0), WAD)))))) {
                mstore(0x00, 0x7c5f487d) // `DivWadFailed()`.
                revert(0x1c, 0x04)
            }
            z := div(mul(x, WAD), y)
        }
    }

    /// @dev Equivalent to `(x * WAD) / y` rounded down.
    function sDivWad(int256 x, int256 y) internal pure returns (int256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := mul(x, WAD)
            // Equivalent to `require(y != 0 && ((x * WAD) / WAD == x))`.
            if iszero(and(iszero(iszero(y)), eq(sdiv(z, WAD), x))) {
                mstore(0x00, 0x5c43740d) // `SDivWadFailed()`.
                revert(0x1c, 0x04)
            }
            z := sdiv(mul(x, WAD), y)
        }
    }

    /// @dev Equivalent to `(x * WAD) / y` rounded down, but without overflow and divide by zero checks.
    function rawDivWad(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := div(mul(x, WAD), y)
        }
    }

    /// @dev Equivalent to `(x * WAD) / y` rounded down, but without overflow and divide by zero checks.
    function rawSDivWad(int256 x, int256 y) internal pure returns (int256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := sdiv(mul(x, WAD), y)
        }
    }

    /// @dev Equivalent to `(x * WAD) / y` rounded up.
    function divWadUp(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Equivalent to `require(y != 0 && (WAD == 0 || x <= type(uint256).max / WAD))`.
            if iszero(mul(y, iszero(mul(WAD, gt(x, div(not(0), WAD)))))) {
                mstore(0x00, 0x7c5f487d) // `DivWadFailed()`.
                revert(0x1c, 0x04)
            }
            z := add(iszero(iszero(mod(mul(x, WAD), y))), div(mul(x, WAD), y))
        }
    }

    /// @dev Equivalent to `(x * WAD) / y` rounded up, but without overflow and divide by zero checks.
    function rawDivWadUp(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := add(iszero(iszero(mod(mul(x, WAD), y))), div(mul(x, WAD), y))
        }
    }

    /// @dev Equivalent to `x` to the power of `y`.
    /// because `x ** y = (e ** ln(x)) ** y = e ** (ln(x) * y)`.
    /// Note: This function is an approximation.
    function powWad(int256 x, int256 y) internal pure returns (int256) {
        // Using `ln(x)` means `x` must be greater than 0.
        return expWad((lnWad(x) * y) / int256(WAD));
    }

    /// @dev Returns `exp(x)`, denominated in `WAD`.
    /// Credit to Remco Bloemen under MIT license: https://2π.com/22/exp-ln
    /// Note: This function is an approximation. Monotonically increasing.
    function expWad(int256 x) internal pure returns (int256 r) {
        unchecked {
            // When the result is less than 0.5 we return zero.
            // This happens when `x <= (log(1e-18) * 1e18) ~ -4.15e19`.
            if (x <= -41446531673892822313) return r;

            /// @solidity memory-safe-assembly
            assembly {
                // When the result is greater than `(2**255 - 1) / 1e18` we can not represent it as
                // an int. This happens when `x >= floor(log((2**255 - 1) / 1e18) * 1e18) ≈ 135`.
                if iszero(slt(x, 135305999368893231589)) {
                    mstore(0x00, 0xa37bfec9) // `ExpOverflow()`.
                    revert(0x1c, 0x04)
                }
            }

            // `x` is now in the range `(-42, 136) * 1e18`. Convert to `(-42, 136) * 2**96`
            // for more intermediate precision and a binary basis. This base conversion
            // is a multiplication by 1e18 / 2**96 = 5**18 / 2**78.
            x = (x << 78) / 5 ** 18;

            // Reduce range of x to (-½ ln 2, ½ ln 2) * 2**96 by factoring out powers
            // of two such that exp(x) = exp(x') * 2**k, where k is an integer.
            // Solving this gives k = round(x / log(2)) and x' = x - k * log(2).
            int256 k = ((x << 96) / 54916777467707473351141471128 + 2 ** 95) >> 96;
            x = x - k * 54916777467707473351141471128;

            // `k` is in the range `[-61, 195]`.

            // Evaluate using a (6, 7)-term rational approximation.
            // `p` is made monic, we'll multiply by a scale factor later.
            int256 y = x + 1346386616545796478920950773328;
            y = ((y * x) >> 96) + 57155421227552351082224309758442;
            int256 p = y + x - 94201549194550492254356042504812;
            p = ((p * y) >> 96) + 28719021644029726153956944680412240;
            p = p * x + (4385272521454847904659076985693276 << 96);

            // We leave `p` in `2**192` basis so we don't need to scale it back up for the division.
            int256 q = x - 2855989394907223263936484059900;
            q = ((q * x) >> 96) + 50020603652535783019961831881945;
            q = ((q * x) >> 96) - 533845033583426703283633433725380;
            q = ((q * x) >> 96) + 3604857256930695427073651918091429;
            q = ((q * x) >> 96) - 14423608567350463180887372962807573;
            q = ((q * x) >> 96) + 26449188498355588339934803723976023;

            /// @solidity memory-safe-assembly
            assembly {
                // Div in assembly because solidity adds a zero check despite the unchecked.
                // The q polynomial won't have zeros in the domain as all its roots are complex.
                // No scaling is necessary because p is already `2**96` too large.
                r := sdiv(p, q)
            }

            // r should be in the range `(0.09, 0.25) * 2**96`.

            // We now need to multiply r by:
            // - The scale factor `s ≈ 6.031367120`.
            // - The `2**k` factor from the range reduction.
            // - The `1e18 / 2**96` factor for base conversion.
            // We do this all at once, with an intermediate result in `2**213`
            // basis, so the final right shift is always by a positive amount.
            r = int256(
                (uint256(r) * 3822833074963236453042738258902158003155416615667) >> uint256(195 - k)
            );
        }
    }

    /// @dev Returns `ln(x)`, denominated in `WAD`.
    /// Credit to Remco Bloemen under MIT license: https://2π.com/22/exp-ln
    /// Note: This function is an approximation. Monotonically increasing.
    function lnWad(int256 x) internal pure returns (int256 r) {
        /// @solidity memory-safe-assembly
        assembly {
            // We want to convert `x` from `10**18` fixed point to `2**96` fixed point.
            // We do this by multiplying by `2**96 / 10**18`. But since
            // `ln(x * C) = ln(x) + ln(C)`, we can simply do nothing here
            // and add `ln(2**96 / 10**18)` at the end.

            // Compute `k = log2(x) - 96`, `r = 159 - k = 255 - log2(x) = 255 ^ log2(x)`.
            r := shl(7, lt(0xffffffffffffffffffffffffffffffff, x))
            r := or(r, shl(6, lt(0xffffffffffffffff, shr(r, x))))
            r := or(r, shl(5, lt(0xffffffff, shr(r, x))))
            r := or(r, shl(4, lt(0xffff, shr(r, x))))
            r := or(r, shl(3, lt(0xff, shr(r, x))))
            // We place the check here for more optimal stack operations.
            if iszero(sgt(x, 0)) {
                mstore(0x00, 0x1615e638) // `LnWadUndefined()`.
                revert(0x1c, 0x04)
            }
            // forgefmt: disable-next-item
            r := xor(r, byte(and(0x1f, shr(shr(r, x), 0x8421084210842108cc6318c6db6d54be)),
                0xf8f9f9faf9fdfafbf9fdfcfdfafbfcfef9fafdfafcfcfbfefafafcfbffffffff))

            // Reduce range of x to (1, 2) * 2**96
            // ln(2^k * x) = k * ln(2) + ln(x)
            x := shr(159, shl(r, x))

            // Evaluate using a (8, 8)-term rational approximation.
            // `p` is made monic, we will multiply by a scale factor later.
            // forgefmt: disable-next-item
            let p := sub( // This heavily nested expression is to avoid stack-too-deep for via-ir.
                sar(96, mul(add(43456485725739037958740375743393,
                sar(96, mul(add(24828157081833163892658089445524,
                sar(96, mul(add(3273285459638523848632254066296,
                    x), x))), x))), x)), 11111509109440967052023855526967)
            p := sub(sar(96, mul(p, x)), 45023709667254063763336534515857)
            p := sub(sar(96, mul(p, x)), 14706773417378608786704636184526)
            p := sub(mul(p, x), shl(96, 795164235651350426258249787498))
            // We leave `p` in `2**192` basis so we don't need to scale it back up for the division.

            // `q` is monic by convention.
            let q := add(5573035233440673466300451813936, x)
            q := add(71694874799317883764090561454958, sar(96, mul(x, q)))
            q := add(283447036172924575727196451306956, sar(96, mul(x, q)))
            q := add(401686690394027663651624208769553, sar(96, mul(x, q)))
            q := add(204048457590392012362485061816622, sar(96, mul(x, q)))
            q := add(31853899698501571402653359427138, sar(96, mul(x, q)))
            q := add(909429971244387300277376558375, sar(96, mul(x, q)))

            // `p / q` is in the range `(0, 0.125) * 2**96`.

            // Finalization, we need to:
            // - Multiply by the scale factor `s = 5.549…`.
            // - Add `ln(2**96 / 10**18)`.
            // - Add `k * ln(2)`.
            // - Multiply by `10**18 / 2**96 = 5**18 >> 78`.

            // The q polynomial is known not to have zeros in the domain.
            // No scaling required because p is already `2**96` too large.
            p := sdiv(p, q)
            // Multiply by the scaling factor: `s * 5**18 * 2**96`, base is now `5**18 * 2**192`.
            p := mul(1677202110996718588342820967067443963516166, p)
            // Add `ln(2) * k * 5**18 * 2**192`.
            // forgefmt: disable-next-item
            p := add(mul(16597577552685614221487285958193947469193820559219878177908093499208371, sub(159, r)), p)
            // Add `ln(2**96 / 10**18) * 5**18 * 2**192`.
            p := add(600920179829731861736702779321621459595472258049074101567377883020018308, p)
            // Base conversion: mul `2**18 / 2**192`.
            r := sar(174, p)
        }
    }

    /// @dev Returns `W_0(x)`, denominated in `WAD`.
    /// See: https://en.wikipedia.org/wiki/Lambert_W_function
    /// a.k.a. Product log function. This is an approximation of the principal branch.
    /// Note: This function is an approximation. Monotonically increasing.
    function lambertW0Wad(int256 x) internal pure returns (int256 w) {
        // forgefmt: disable-next-item
        unchecked {
            if ((w = x) <= -367879441171442322) revert OutOfDomain(); // `x` less than `-1/e`.
            int256 wad = int256(WAD);
            int256 p = x;
            uint256 c; // Whether we need to avoid catastrophic cancellation.
            uint256 i = 4; // Number of iterations.
            if (w <= 0x1ffffffffffff) {
                if (-0x4000000000000 <= w) {
                    i = 1; // Inputs near zero only take one step to converge.
                } else if (w <= -0x3ffffffffffffff) {
                    i = 32; // Inputs near `-1/e` take very long to converge.
                }
            } else if (uint256(w >> 63) == uint256(0)) {
                /// @solidity memory-safe-assembly
                assembly {
                    // Inline log2 for more performance, since the range is small.
                    let v := shr(49, w)
                    let l := shl(3, lt(0xff, v))
                    l := add(or(l, byte(and(0x1f, shr(shr(l, v), 0x8421084210842108cc6318c6db6d54be)),
                        0x0706060506020504060203020504030106050205030304010505030400000000)), 49)
                    w := sdiv(shl(l, 7), byte(sub(l, 31), 0x0303030303030303040506080c13))
                    c := gt(l, 60)
                    i := add(2, add(gt(l, 53), c))
                }
            } else {
                int256 ll = lnWad(w = lnWad(w));
                /// @solidity memory-safe-assembly
                assembly {
                    // `w = ln(x) - ln(ln(x)) + b * ln(ln(x)) / ln(x)`.
                    w := add(sdiv(mul(ll, 1023715080943847266), w), sub(w, ll))
                    i := add(3, iszero(shr(68, x)))
                    c := iszero(shr(143, x))
                }
                if (c == uint256(0)) {
                    do { // If `x` is big, use Newton's so that intermediate values won't overflow.
                        int256 e = expWad(w);
                        /// @solidity memory-safe-assembly
                        assembly {
                            let t := mul(w, div(e, wad))
                            w := sub(w, sdiv(sub(t, x), div(add(e, t), wad)))
                        }
                        if (p <= w) break;
                        p = w;
                    } while (--i != uint256(0));
                    /// @solidity memory-safe-assembly
                    assembly {
                        w := sub(w, sgt(w, 2))
                    }
                    return w;
                }
            }
            do { // Otherwise, use Halley's for faster convergence.
                int256 e = expWad(w);
                /// @solidity memory-safe-assembly
                assembly {
                    let t := add(w, wad)
                    let s := sub(mul(w, e), mul(x, wad))
                    w := sub(w, sdiv(mul(s, wad), sub(mul(e, t), sdiv(mul(add(t, wad), s), add(t, t)))))
                }
                if (p <= w) break;
                p = w;
            } while (--i != c);
            /// @solidity memory-safe-assembly
            assembly {
                w := sub(w, sgt(w, 2))
            }
            // For certain ranges of `x`, we'll use the quadratic-rate recursive formula of
            // R. Iacono and J.P. Boyd for the last iteration, to avoid catastrophic cancellation.
            if (c == uint256(0)) return w;
            int256 t = w | 1;
            /// @solidity memory-safe-assembly
            assembly {
                x := sdiv(mul(x, wad), t)
            }
            x = (t * (wad + lnWad(x)));
            /// @solidity memory-safe-assembly
            assembly {
                w := sdiv(x, add(wad, t))
            }
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                  GENERAL NUMBER UTILITIES                  */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Calculates `floor(x * y / d)` with full precision.
    /// Throws if result overflows a uint256 or when `d` is zero.
    /// Credit to Remco Bloemen under MIT license: https://2π.com/21/muldiv
    function fullMulDiv(uint256 x, uint256 y, uint256 d) internal pure returns (uint256 result) {
        /// @solidity memory-safe-assembly
        assembly {
            // 512-bit multiply `[p1 p0] = x * y`.
            // Compute the product mod `2**256` and mod `2**256 - 1`
            // then use the Chinese Remainder Theorem to reconstruct
            // the 512 bit result. The result is stored in two 256
            // variables such that `product = p1 * 2**256 + p0`.

            // Temporarily use `result` as `p0` to save gas.
            result := mul(x, y) // Lower 256 bits of `x * y`.
            for {} 1 {} {
                // If overflows.
                if iszero(mul(or(iszero(x), eq(div(result, x), y)), d)) {
                    let mm := mulmod(x, y, not(0))
                    let p1 := sub(mm, add(result, lt(mm, result))) // Upper 256 bits of `x * y`.

                    /*------------------- 512 by 256 division --------------------*/

                    // Make division exact by subtracting the remainder from `[p1 p0]`.
                    let r := mulmod(x, y, d) // Compute remainder using mulmod.
                    let t := and(d, sub(0, d)) // The least significant bit of `d`. `t >= 1`.
                    // Make sure the result is less than `2**256`. Also prevents `d == 0`.
                    // Placing the check here seems to give more optimal stack operations.
                    if iszero(gt(d, p1)) {
                        mstore(0x00, 0xae47f702) // `FullMulDivFailed()`.
                        revert(0x1c, 0x04)
                    }
                    d := div(d, t) // Divide `d` by `t`, which is a power of two.
                    // Invert `d mod 2**256`
                    // Now that `d` is an odd number, it has an inverse
                    // modulo `2**256` such that `d * inv = 1 mod 2**256`.
                    // Compute the inverse by starting with a seed that is correct
                    // correct for four bits. That is, `d * inv = 1 mod 2**4`.
                    let inv := xor(2, mul(3, d))
                    // Now use Newton-Raphson iteration to improve the precision.
                    // Thanks to Hensel's lifting lemma, this also works in modular
                    // arithmetic, doubling the correct bits in each step.
                    inv := mul(inv, sub(2, mul(d, inv))) // inverse mod 2**8
                    inv := mul(inv, sub(2, mul(d, inv))) // inverse mod 2**16
                    inv := mul(inv, sub(2, mul(d, inv))) // inverse mod 2**32
                    inv := mul(inv, sub(2, mul(d, inv))) // inverse mod 2**64
                    inv := mul(inv, sub(2, mul(d, inv))) // inverse mod 2**128
                    result :=
                        mul(
                            // Divide [p1 p0] by the factors of two.
                            // Shift in bits from `p1` into `p0`. For this we need
                            // to flip `t` such that it is `2**256 / t`.
                            or(
                                mul(sub(p1, gt(r, result)), add(div(sub(0, t), t), 1)),
                                div(sub(result, r), t)
                            ),
                            mul(sub(2, mul(d, inv)), inv) // inverse mod 2**256
                        )
                    break
                }
                result := div(result, d)
                break
            }
        }
    }

    /// @dev Calculates `floor(x * y / d)` with full precision.
    /// Behavior is undefined if `d` is zero or the final result cannot fit in 256 bits.
    /// Performs the full 512 bit calculation regardless.
    function fullMulDivUnchecked(uint256 x, uint256 y, uint256 d)
        internal
        pure
        returns (uint256 result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            result := mul(x, y)
            let mm := mulmod(x, y, not(0))
            let p1 := sub(mm, add(result, lt(mm, result)))
            let t := and(d, sub(0, d))
            let r := mulmod(x, y, d)
            d := div(d, t)
            let inv := xor(2, mul(3, d))
            inv := mul(inv, sub(2, mul(d, inv)))
            inv := mul(inv, sub(2, mul(d, inv)))
            inv := mul(inv, sub(2, mul(d, inv)))
            inv := mul(inv, sub(2, mul(d, inv)))
            inv := mul(inv, sub(2, mul(d, inv)))
            result :=
                mul(
                    or(mul(sub(p1, gt(r, result)), add(div(sub(0, t), t), 1)), div(sub(result, r), t)),
                    mul(sub(2, mul(d, inv)), inv)
                )
        }
    }

    /// @dev Calculates `floor(x * y / d)` with full precision, rounded up.
    /// Throws if result overflows a uint256 or when `d` is zero.
    /// Credit to Uniswap-v3-core under MIT license:
    /// https://github.com/Uniswap/v3-core/blob/main/contracts/libraries/FullMath.sol
    function fullMulDivUp(uint256 x, uint256 y, uint256 d) internal pure returns (uint256 result) {
        result = fullMulDiv(x, y, d);
        /// @solidity memory-safe-assembly
        assembly {
            if mulmod(x, y, d) {
                result := add(result, 1)
                if iszero(result) {
                    mstore(0x00, 0xae47f702) // `FullMulDivFailed()`.
                    revert(0x1c, 0x04)
                }
            }
        }
    }

    /// @dev Returns `floor(x * y / d)`.
    /// Reverts if `x * y` overflows, or `d` is zero.
    function mulDiv(uint256 x, uint256 y, uint256 d) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := mul(x, y)
            // Equivalent to `require(d != 0 && (y == 0 || x <= type(uint256).max / y))`.
            if iszero(mul(or(iszero(x), eq(div(z, x), y)), d)) {
                mstore(0x00, 0xad251c27) // `MulDivFailed()`.
                revert(0x1c, 0x04)
            }
            z := div(z, d)
        }
    }

    /// @dev Returns `ceil(x * y / d)`.
    /// Reverts if `x * y` overflows, or `d` is zero.
    function mulDivUp(uint256 x, uint256 y, uint256 d) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := mul(x, y)
            // Equivalent to `require(d != 0 && (y == 0 || x <= type(uint256).max / y))`.
            if iszero(mul(or(iszero(x), eq(div(z, x), y)), d)) {
                mstore(0x00, 0xad251c27) // `MulDivFailed()`.
                revert(0x1c, 0x04)
            }
            z := add(iszero(iszero(mod(z, d))), div(z, d))
        }
    }

    /// @dev Returns `ceil(x / d)`.
    /// Reverts if `d` is zero.
    function divUp(uint256 x, uint256 d) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            if iszero(d) {
                mstore(0x00, 0x65244e4e) // `DivFailed()`.
                revert(0x1c, 0x04)
            }
            z := add(iszero(iszero(mod(x, d))), div(x, d))
        }
    }

    /// @dev Returns `max(0, x - y)`.
    function zeroFloorSub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := mul(gt(x, y), sub(x, y))
        }
    }

    /// @dev Returns `condition ? x : y`, without branching.
    function ternary(bool condition, uint256 x, uint256 y) internal pure returns (uint256 result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := xor(x, mul(xor(x, y), iszero(condition)))
        }
    }

    /// @dev Exponentiate `x` to `y` by squaring, denominated in base `b`.
    /// Reverts if the computation overflows.
    function rpow(uint256 x, uint256 y, uint256 b) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := mul(b, iszero(y)) // `0 ** 0 = 1`. Otherwise, `0 ** n = 0`.
            if x {
                z := xor(b, mul(xor(b, x), and(y, 1))) // `z = isEven(y) ? scale : x`
                let half := shr(1, b) // Divide `b` by 2.
                // Divide `y` by 2 every iteration.
                for { y := shr(1, y) } y { y := shr(1, y) } {
                    let xx := mul(x, x) // Store x squared.
                    let xxRound := add(xx, half) // Round to the nearest number.
                    // Revert if `xx + half` overflowed, or if `x ** 2` overflows.
                    if or(lt(xxRound, xx), shr(128, x)) {
                        mstore(0x00, 0x49f7642b) // `RPowOverflow()`.
                        revert(0x1c, 0x04)
                    }
                    x := div(xxRound, b) // Set `x` to scaled `xxRound`.
                    // If `y` is odd:
                    if and(y, 1) {
                        let zx := mul(z, x) // Compute `z * x`.
                        let zxRound := add(zx, half) // Round to the nearest number.
                        // If `z * x` overflowed or `zx + half` overflowed:
                        if or(xor(div(zx, x), z), lt(zxRound, zx)) {
                            // Revert if `x` is non-zero.
                            if x {
                                mstore(0x00, 0x49f7642b) // `RPowOverflow()`.
                                revert(0x1c, 0x04)
                            }
                        }
                        z := div(zxRound, b) // Return properly scaled `zxRound`.
                    }
                }
            }
        }
    }

    /// @dev Returns the square root of `x`, rounded down.
    function sqrt(uint256 x) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // `floor(sqrt(2**15)) = 181`. `sqrt(2**15) - 181 = 2.84`.
            z := 181 // The "correct" value is 1, but this saves a multiplication later.

            // This segment is to get a reasonable initial estimate for the Babylonian method. With a bad
            // start, the correct # of bits increases ~linearly each iteration instead of ~quadratically.

            // Let `y = x / 2**r`. We check `y >= 2**(k + 8)`
            // but shift right by `k` bits to ensure that if `x >= 256`, then `y >= 256`.
            let r := shl(7, lt(0xffffffffffffffffffffffffffffffffff, x))
            r := or(r, shl(6, lt(0xffffffffffffffffff, shr(r, x))))
            r := or(r, shl(5, lt(0xffffffffff, shr(r, x))))
            r := or(r, shl(4, lt(0xffffff, shr(r, x))))
            z := shl(shr(1, r), z)

            // Goal was to get `z*z*y` within a small factor of `x`. More iterations could
            // get y in a tighter range. Currently, we will have y in `[256, 256*(2**16))`.
            // We ensured `y >= 256` so that the relative difference between `y` and `y+1` is small.
            // That's not possible if `x < 256` but we can just verify those cases exhaustively.

            // Now, `z*z*y <= x < z*z*(y+1)`, and `y <= 2**(16+8)`, and either `y >= 256`, or `x < 256`.
            // Correctness can be checked exhaustively for `x < 256`, so we assume `y >= 256`.
            // Then `z*sqrt(y)` is within `sqrt(257)/sqrt(256)` of `sqrt(x)`, or about 20bps.

            // For `s` in the range `[1/256, 256]`, the estimate `f(s) = (181/1024) * (s+1)`
            // is in the range `(1/2.84 * sqrt(s), 2.84 * sqrt(s))`,
            // with largest error when `s = 1` and when `s = 256` or `1/256`.

            // Since `y` is in `[256, 256*(2**16))`, let `a = y/65536`, so that `a` is in `[1/256, 256)`.
            // Then we can estimate `sqrt(y)` using
            // `sqrt(65536) * 181/1024 * (a + 1) = 181/4 * (y + 65536)/65536 = 181 * (y + 65536)/2**18`.

            // There is no overflow risk here since `y < 2**136` after the first branch above.
            z := shr(18, mul(z, add(shr(r, x), 65536))) // A `mul()` is saved from starting `z` at 181.

            // Given the worst case multiplicative error of 2.84 above, 7 iterations should be enough.
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))

            // If `x+1` is a perfect square, the Babylonian method cycles between
            // `floor(sqrt(x))` and `ceil(sqrt(x))`. This statement ensures we return floor.
            // See: https://en.wikipedia.org/wiki/Integer_square_root#Using_only_integer_division
            z := sub(z, lt(div(x, z), z))
        }
    }

    /// @dev Returns the cube root of `x`, rounded down.
    /// Credit to bout3fiddy and pcaversaccio under AGPLv3 license:
    /// https://github.com/pcaversaccio/snekmate/blob/main/src/utils/Math.vy
    /// Formally verified by xuwinnie:
    /// https://github.com/vectorized/solady/blob/main/audits/xuwinnie-solady-cbrt-proof.pdf
    function cbrt(uint256 x) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            let r := shl(7, lt(0xffffffffffffffffffffffffffffffff, x))
            r := or(r, shl(6, lt(0xffffffffffffffff, shr(r, x))))
            r := or(r, shl(5, lt(0xffffffff, shr(r, x))))
            r := or(r, shl(4, lt(0xffff, shr(r, x))))
            r := or(r, shl(3, lt(0xff, shr(r, x))))
            // Makeshift lookup table to nudge the approximate log2 result.
            z := div(shl(div(r, 3), shl(lt(0xf, shr(r, x)), 0xf)), xor(7, mod(r, 3)))
            // Newton-Raphson's.
            z := div(add(add(div(x, mul(z, z)), z), z), 3)
            z := div(add(add(div(x, mul(z, z)), z), z), 3)
            z := div(add(add(div(x, mul(z, z)), z), z), 3)
            z := div(add(add(div(x, mul(z, z)), z), z), 3)
            z := div(add(add(div(x, mul(z, z)), z), z), 3)
            z := div(add(add(div(x, mul(z, z)), z), z), 3)
            z := div(add(add(div(x, mul(z, z)), z), z), 3)
            // Round down.
            z := sub(z, lt(div(x, mul(z, z)), z))
        }
    }

    /// @dev Returns the square root of `x`, denominated in `WAD`, rounded down.
    function sqrtWad(uint256 x) internal pure returns (uint256 z) {
        unchecked {
            if (x <= type(uint256).max / 10 ** 18) return sqrt(x * 10 ** 18);
            z = (1 + sqrt(x)) * 10 ** 9;
            z = (fullMulDivUnchecked(x, 10 ** 18, z) + z) >> 1;
        }
        /// @solidity memory-safe-assembly
        assembly {
            z := sub(z, gt(999999999999999999, sub(mulmod(z, z, x), 1))) // Round down.
        }
    }

    /// @dev Returns the cube root of `x`, denominated in `WAD`, rounded down.
    /// Formally verified by xuwinnie:
    /// https://github.com/vectorized/solady/blob/main/audits/xuwinnie-solady-cbrt-proof.pdf
    function cbrtWad(uint256 x) internal pure returns (uint256 z) {
        unchecked {
            if (x <= type(uint256).max / 10 ** 36) return cbrt(x * 10 ** 36);
            z = (1 + cbrt(x)) * 10 ** 12;
            z = (fullMulDivUnchecked(x, 10 ** 36, z * z) + z + z) / 3;
        }
        /// @solidity memory-safe-assembly
        assembly {
            let p := x
            for {} 1 {} {
                if iszero(shr(229, p)) {
                    if iszero(shr(199, p)) {
                        p := mul(p, 100000000000000000) // 10 ** 17.
                        break
                    }
                    p := mul(p, 100000000) // 10 ** 8.
                    break
                }
                if iszero(shr(249, p)) { p := mul(p, 100) }
                break
            }
            let t := mulmod(mul(z, z), z, p)
            z := sub(z, gt(lt(t, shr(1, p)), iszero(t))) // Round down.
        }
    }

    /// @dev Returns the factorial of `x`.
    function factorial(uint256 x) internal pure returns (uint256 result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := 1
            if iszero(lt(x, 58)) {
                mstore(0x00, 0xaba0f2a2) // `FactorialOverflow()`.
                revert(0x1c, 0x04)
            }
            for {} x { x := sub(x, 1) } { result := mul(result, x) }
        }
    }

    /// @dev Returns the log2 of `x`.
    /// Equivalent to computing the index of the most significant bit (MSB) of `x`.
    /// Returns 0 if `x` is zero.
    function log2(uint256 x) internal pure returns (uint256 r) {
        /// @solidity memory-safe-assembly
        assembly {
            r := shl(7, lt(0xffffffffffffffffffffffffffffffff, x))
            r := or(r, shl(6, lt(0xffffffffffffffff, shr(r, x))))
            r := or(r, shl(5, lt(0xffffffff, shr(r, x))))
            r := or(r, shl(4, lt(0xffff, shr(r, x))))
            r := or(r, shl(3, lt(0xff, shr(r, x))))
            // forgefmt: disable-next-item
            r := or(r, byte(and(0x1f, shr(shr(r, x), 0x8421084210842108cc6318c6db6d54be)),
                0x0706060506020504060203020504030106050205030304010505030400000000))
        }
    }

    /// @dev Returns the log2 of `x`, rounded up.
    /// Returns 0 if `x` is zero.
    function log2Up(uint256 x) internal pure returns (uint256 r) {
        r = log2(x);
        /// @solidity memory-safe-assembly
        assembly {
            r := add(r, lt(shl(r, 1), x))
        }
    }

    /// @dev Returns the log10 of `x`.
    /// Returns 0 if `x` is zero.
    function log10(uint256 x) internal pure returns (uint256 r) {
        /// @solidity memory-safe-assembly
        assembly {
            if iszero(lt(x, 100000000000000000000000000000000000000)) {
                x := div(x, 100000000000000000000000000000000000000)
                r := 38
            }
            if iszero(lt(x, 100000000000000000000)) {
                x := div(x, 100000000000000000000)
                r := add(r, 20)
            }
            if iszero(lt(x, 10000000000)) {
                x := div(x, 10000000000)
                r := add(r, 10)
            }
            if iszero(lt(x, 100000)) {
                x := div(x, 100000)
                r := add(r, 5)
            }
            r := add(r, add(gt(x, 9), add(gt(x, 99), add(gt(x, 999), gt(x, 9999)))))
        }
    }

    /// @dev Returns the log10 of `x`, rounded up.
    /// Returns 0 if `x` is zero.
    function log10Up(uint256 x) internal pure returns (uint256 r) {
        r = log10(x);
        /// @solidity memory-safe-assembly
        assembly {
            r := add(r, lt(exp(10, r), x))
        }
    }

    /// @dev Returns the log256 of `x`.
    /// Returns 0 if `x` is zero.
    function log256(uint256 x) internal pure returns (uint256 r) {
        /// @solidity memory-safe-assembly
        assembly {
            r := shl(7, lt(0xffffffffffffffffffffffffffffffff, x))
            r := or(r, shl(6, lt(0xffffffffffffffff, shr(r, x))))
            r := or(r, shl(5, lt(0xffffffff, shr(r, x))))
            r := or(r, shl(4, lt(0xffff, shr(r, x))))
            r := or(shr(3, r), lt(0xff, shr(r, x)))
        }
    }

    /// @dev Returns the log256 of `x`, rounded up.
    /// Returns 0 if `x` is zero.
    function log256Up(uint256 x) internal pure returns (uint256 r) {
        r = log256(x);
        /// @solidity memory-safe-assembly
        assembly {
            r := add(r, lt(shl(shl(3, r), 1), x))
        }
    }

    /// @dev Returns the scientific notation format `mantissa * 10 ** exponent` of `x`.
    /// Useful for compressing prices (e.g. using 25 bit mantissa and 7 bit exponent).
    function sci(uint256 x) internal pure returns (uint256 mantissa, uint256 exponent) {
        /// @solidity memory-safe-assembly
        assembly {
            mantissa := x
            if mantissa {
                if iszero(mod(mantissa, 1000000000000000000000000000000000)) {
                    mantissa := div(mantissa, 1000000000000000000000000000000000)
                    exponent := 33
                }
                if iszero(mod(mantissa, 10000000000000000000)) {
                    mantissa := div(mantissa, 10000000000000000000)
                    exponent := add(exponent, 19)
                }
                if iszero(mod(mantissa, 1000000000000)) {
                    mantissa := div(mantissa, 1000000000000)
                    exponent := add(exponent, 12)
                }
                if iszero(mod(mantissa, 1000000)) {
                    mantissa := div(mantissa, 1000000)
                    exponent := add(exponent, 6)
                }
                if iszero(mod(mantissa, 10000)) {
                    mantissa := div(mantissa, 10000)
                    exponent := add(exponent, 4)
                }
                if iszero(mod(mantissa, 100)) {
                    mantissa := div(mantissa, 100)
                    exponent := add(exponent, 2)
                }
                if iszero(mod(mantissa, 10)) {
                    mantissa := div(mantissa, 10)
                    exponent := add(exponent, 1)
                }
            }
        }
    }

    /// @dev Convenience function for packing `x` into a smaller number using `sci`.
    /// The `mantissa` will be in bits [7..255] (the upper 249 bits).
    /// The `exponent` will be in bits [0..6] (the lower 7 bits).
    /// Use `SafeCastLib` to safely ensure that the `packed` number is small
    /// enough to fit in the desired unsigned integer type:
    /// ```
    ///     uint32 packed = SafeCastLib.toUint32(FixedPointMathLib.packSci(777 ether));
    /// ```
    function packSci(uint256 x) internal pure returns (uint256 packed) {
        (x, packed) = sci(x); // Reuse for `mantissa` and `exponent`.
        /// @solidity memory-safe-assembly
        assembly {
            if shr(249, x) {
                mstore(0x00, 0xce30380c) // `MantissaOverflow()`.
                revert(0x1c, 0x04)
            }
            packed := or(shl(7, x), packed)
        }
    }

    /// @dev Convenience function for unpacking a packed number from `packSci`.
    function unpackSci(uint256 packed) internal pure returns (uint256 unpacked) {
        unchecked {
            unpacked = (packed >> 7) * 10 ** (packed & 0x7f);
        }
    }

    /// @dev Returns the average of `x` and `y`. Rounds towards zero.
    function avg(uint256 x, uint256 y) internal pure returns (uint256 z) {
        unchecked {
            z = (x & y) + ((x ^ y) >> 1);
        }
    }

    /// @dev Returns the average of `x` and `y`. Rounds towards negative infinity.
    function avg(int256 x, int256 y) internal pure returns (int256 z) {
        unchecked {
            z = (x >> 1) + (y >> 1) + (x & y & 1);
        }
    }

    /// @dev Returns the absolute value of `x`.
    function abs(int256 x) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := xor(sar(255, x), add(sar(255, x), x))
        }
    }

    /// @dev Returns the absolute distance between `x` and `y`.
    function dist(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := xor(mul(xor(sub(y, x), sub(x, y)), gt(x, y)), sub(y, x))
        }
    }

    /// @dev Returns the absolute distance between `x` and `y`.
    function dist(int256 x, int256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := xor(mul(xor(sub(y, x), sub(x, y)), sgt(x, y)), sub(y, x))
        }
    }

    /// @dev Returns the minimum of `x` and `y`.
    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := xor(x, mul(xor(x, y), lt(y, x)))
        }
    }

    /// @dev Returns the minimum of `x` and `y`.
    function min(int256 x, int256 y) internal pure returns (int256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := xor(x, mul(xor(x, y), slt(y, x)))
        }
    }

    /// @dev Returns the maximum of `x` and `y`.
    function max(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := xor(x, mul(xor(x, y), gt(y, x)))
        }
    }

    /// @dev Returns the maximum of `x` and `y`.
    function max(int256 x, int256 y) internal pure returns (int256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := xor(x, mul(xor(x, y), sgt(y, x)))
        }
    }

    /// @dev Returns `x`, bounded to `minValue` and `maxValue`.
    function clamp(uint256 x, uint256 minValue, uint256 maxValue)
        internal
        pure
        returns (uint256 z)
    {
        /// @solidity memory-safe-assembly
        assembly {
            z := xor(x, mul(xor(x, minValue), gt(minValue, x)))
            z := xor(z, mul(xor(z, maxValue), lt(maxValue, z)))
        }
    }

    /// @dev Returns `x`, bounded to `minValue` and `maxValue`.
    function clamp(int256 x, int256 minValue, int256 maxValue) internal pure returns (int256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := xor(x, mul(xor(x, minValue), sgt(minValue, x)))
            z := xor(z, mul(xor(z, maxValue), slt(maxValue, z)))
        }
    }

    /// @dev Returns greatest common divisor of `x` and `y`.
    function gcd(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            for { z := x } y {} {
                let t := y
                y := mod(z, y)
                z := t
            }
        }
    }

    /// @dev Returns `a + (b - a) * (t - begin) / (end - begin)`,
    /// with `t` clamped between `begin` and `end` (inclusive).
    /// Agnostic to the order of (`a`, `b`) and (`end`, `begin`).
    /// If `begins == end`, returns `t <= begin ? a : b`.
    function lerp(uint256 a, uint256 b, uint256 t, uint256 begin, uint256 end)
        internal
        pure
        returns (uint256)
    {
        if (begin > end) {
            t = ~t;
            begin = ~begin;
            end = ~end;
        }
        if (t <= begin) return a;
        if (t >= end) return b;
        unchecked {
            if (b >= a) return a + fullMulDiv(b - a, t - begin, end - begin);
            return a - fullMulDiv(a - b, t - begin, end - begin);
        }
    }

    /// @dev Returns `a + (b - a) * (t - begin) / (end - begin)`.
    /// with `t` clamped between `begin` and `end` (inclusive).
    /// Agnostic to the order of (`a`, `b`) and (`end`, `begin`).
    /// If `begins == end`, returns `t <= begin ? a : b`.
    function lerp(int256 a, int256 b, int256 t, int256 begin, int256 end)
        internal
        pure
        returns (int256)
    {
        if (begin > end) {
            t = int256(~uint256(t));
            begin = int256(~uint256(begin));
            end = int256(~uint256(end));
        }
        if (t <= begin) return a;
        if (t >= end) return b;
        // forgefmt: disable-next-item
        unchecked {
            if (b >= a) return int256(uint256(a) + fullMulDiv(uint256(b) - uint256(a),
                uint256(t) - uint256(begin), uint256(end) - uint256(begin)));
            return int256(uint256(a) - fullMulDiv(uint256(a) - uint256(b),
                uint256(t) - uint256(begin), uint256(end) - uint256(begin)));
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                   RAW NUMBER OPERATIONS                    */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns `x + y`, without checking for overflow.
    function rawAdd(uint256 x, uint256 y) internal pure returns (uint256 z) {
        unchecked {
            z = x + y;
        }
    }

    /// @dev Returns `x + y`, without checking for overflow.
    function rawAdd(int256 x, int256 y) internal pure returns (int256 z) {
        unchecked {
            z = x + y;
        }
    }

    /// @dev Returns `x - y`, without checking for underflow.
    function rawSub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        unchecked {
            z = x - y;
        }
    }

    /// @dev Returns `x - y`, without checking for underflow.
    function rawSub(int256 x, int256 y) internal pure returns (int256 z) {
        unchecked {
            z = x - y;
        }
    }

    /// @dev Returns `x * y`, without checking for overflow.
    function rawMul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        unchecked {
            z = x * y;
        }
    }

    /// @dev Returns `x * y`, without checking for overflow.
    function rawMul(int256 x, int256 y) internal pure returns (int256 z) {
        unchecked {
            z = x * y;
        }
    }

    /// @dev Returns `x / y`, returning 0 if `y` is zero.
    function rawDiv(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := div(x, y)
        }
    }

    /// @dev Returns `x / y`, returning 0 if `y` is zero.
    function rawSDiv(int256 x, int256 y) internal pure returns (int256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := sdiv(x, y)
        }
    }

    /// @dev Returns `x % y`, returning 0 if `y` is zero.
    function rawMod(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := mod(x, y)
        }
    }

    /// @dev Returns `x % y`, returning 0 if `y` is zero.
    function rawSMod(int256 x, int256 y) internal pure returns (int256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := smod(x, y)
        }
    }

    /// @dev Returns `(x + y) % d`, return 0 if `d` if zero.
    function rawAddMod(uint256 x, uint256 y, uint256 d) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := addmod(x, y, d)
        }
    }

    /// @dev Returns `(x * y) % d`, return 0 if `d` if zero.
    function rawMulMod(uint256 x, uint256 y, uint256 d) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := mulmod(x, y, d)
        }
    }
}