// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IEIP712} from "./IEIP712.sol";

/// @title AllowanceTransfer
/// @notice Handles ERC20 token permissions through signature based allowance setting and ERC20 token transfers by checking allowed amounts
/// @dev Requires user's token approval on the Permit2 contract
interface IAllowanceTransfer is IEIP712 {
    /// @notice Thrown when an allowance on a token has expired.
    /// @param deadline The timestamp at which the allowed amount is no longer valid
    error AllowanceExpired(uint256 deadline);

    /// @notice Thrown when an allowance on a token has been depleted.
    /// @param amount The maximum amount allowed
    error InsufficientAllowance(uint256 amount);

    /// @notice Thrown when too many nonces are invalidated.
    error ExcessiveInvalidation();

    /// @notice Emits an event when the owner successfully invalidates an ordered nonce.
    event NonceInvalidation(
        address indexed owner, address indexed token, address indexed spender, uint48 newNonce, uint48 oldNonce
    );

    /// @notice Emits an event when the owner successfully sets permissions on a token for the spender.
    event Approval(
        address indexed owner, address indexed token, address indexed spender, uint160 amount, uint48 expiration
    );

    /// @notice Emits an event when the owner successfully sets permissions using a permit signature on a token for the spender.
    event Permit(
        address indexed owner,
        address indexed token,
        address indexed spender,
        uint160 amount,
        uint48 expiration,
        uint48 nonce
    );

    /// @notice Emits an event when the owner sets the allowance back to 0 with the lockdown function.
    event Lockdown(address indexed owner, address token, address spender);

    /// @notice The permit data for a token
    struct PermitDetails {
        // ERC20 token address
        address token;
        // the maximum amount allowed to spend
        uint160 amount;
        // timestamp at which a spender's token allowances become invalid
        uint48 expiration;
        // an incrementing value indexed per owner,token,and spender for each signature
        uint48 nonce;
    }

    /// @notice The permit message signed for a single token allownce
    struct PermitSingle {
        // the permit data for a single token alownce
        PermitDetails details;
        // address permissioned on the allowed tokens
        address spender;
        // deadline on the permit signature
        uint256 sigDeadline;
    }

    /// @notice The permit message signed for multiple token allowances
    struct PermitBatch {
        // the permit data for multiple token allowances
        PermitDetails[] details;
        // address permissioned on the allowed tokens
        address spender;
        // deadline on the permit signature
        uint256 sigDeadline;
    }

    /// @notice The saved permissions
    /// @dev This info is saved per owner, per token, per spender and all signed over in the permit message
    /// @dev Setting amount to type(uint160).max sets an unlimited approval
    struct PackedAllowance {
        // amount allowed
        uint160 amount;
        // permission expiry
        uint48 expiration;
        // an incrementing value indexed per owner,token,and spender for each signature
        uint48 nonce;
    }

    /// @notice A token spender pair.
    struct TokenSpenderPair {
        // the token the spender is approved
        address token;
        // the spender address
        address spender;
    }

    /// @notice Details for a token transfer.
    struct AllowanceTransferDetails {
        // the owner of the token
        address from;
        // the recipient of the token
        address to;
        // the amount of the token
        uint160 amount;
        // the token to be transferred
        address token;
    }

    /// @notice A mapping from owner address to token address to spender address to PackedAllowance struct, which contains details and conditions of the approval.
    /// @notice The mapping is indexed in the above order see: allowance[ownerAddress][tokenAddress][spenderAddress]
    /// @dev The packed slot holds the allowed amount, expiration at which the allowed amount is no longer valid, and current nonce thats updated on any signature based approvals.
    function allowance(address user, address token, address spender)
        external
        view
        returns (uint160 amount, uint48 expiration, uint48 nonce);

    /// @notice Approves the spender to use up to amount of the specified token up until the expiration
    /// @param token The token to approve
    /// @param spender The spender address to approve
    /// @param amount The approved amount of the token
    /// @param expiration The timestamp at which the approval is no longer valid
    /// @dev The packed allowance also holds a nonce, which will stay unchanged in approve
    /// @dev Setting amount to type(uint160).max sets an unlimited approval
    function approve(address token, address spender, uint160 amount, uint48 expiration) external;

    /// @notice Permit a spender to a given amount of the owners token via the owner's EIP-712 signature
    /// @dev May fail if the owner's nonce was invalidated in-flight by invalidateNonce
    /// @param owner The owner of the tokens being approved
    /// @param permitSingle Data signed over by the owner specifying the terms of approval
    /// @param signature The owner's signature over the permit data
    function permit(address owner, PermitSingle memory permitSingle, bytes calldata signature) external;

    /// @notice Permit a spender to the signed amounts of the owners tokens via the owner's EIP-712 signature
    /// @dev May fail if the owner's nonce was invalidated in-flight by invalidateNonce
    /// @param owner The owner of the tokens being approved
    /// @param permitBatch Data signed over by the owner specifying the terms of approval
    /// @param signature The owner's signature over the permit data
    function permit(address owner, PermitBatch memory permitBatch, bytes calldata signature) external;

    /// @notice Transfer approved tokens from one address to another
    /// @param from The address to transfer from
    /// @param to The address of the recipient
    /// @param amount The amount of the token to transfer
    /// @param token The token address to transfer
    /// @dev Requires the from address to have approved at least the desired amount
    /// of tokens to msg.sender.
    function transferFrom(address from, address to, uint160 amount, address token) external;

    /// @notice Transfer approved tokens in a batch
    /// @param transferDetails Array of owners, recipients, amounts, and tokens for the transfers
    /// @dev Requires the from addresses to have approved at least the desired amount
    /// of tokens to msg.sender.
    function transferFrom(AllowanceTransferDetails[] calldata transferDetails) external;

    /// @notice Enables performing a "lockdown" of the sender's Permit2 identity
    /// by batch revoking approvals
    /// @param approvals Array of approvals to revoke.
    function lockdown(TokenSpenderPair[] calldata approvals) external;

    /// @notice Invalidate nonces for a given (token, spender) pair
    /// @param token The token to invalidate nonces for
    /// @param spender The spender to invalidate nonces for
    /// @param newNonce The new nonce to set. Invalidates all nonces less than it.
    /// @dev Can't invalidate more than 2**16 nonces per transaction.
    function invalidateNonces(address token, address spender, uint48 newNonce) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IEIP712 {
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ISignatureTransfer} from "./ISignatureTransfer.sol";
import {IAllowanceTransfer} from "./IAllowanceTransfer.sol";

/// @notice Permit2 handles signature-based transfers in SignatureTransfer and allowance-based transfers in AllowanceTransfer.
/// @dev Users must approve Permit2 before calling any of the transfer functions.
interface IPermit2 is ISignatureTransfer, IAllowanceTransfer {
// IPermit2 unifies the two interfaces so users have maximal flexibility with their approval.
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IEIP712} from "./IEIP712.sol";

/// @title SignatureTransfer
/// @notice Handles ERC20 token transfers through signature based actions
/// @dev Requires user's token approval on the Permit2 contract
interface ISignatureTransfer is IEIP712 {
    /// @notice Thrown when the requested amount for a transfer is larger than the permissioned amount
    /// @param maxAmount The maximum amount a spender can request to transfer
    error InvalidAmount(uint256 maxAmount);

    /// @notice Thrown when the number of tokens permissioned to a spender does not match the number of tokens being transferred
    /// @dev If the spender does not need to transfer the number of tokens permitted, the spender can request amount 0 to be transferred
    error LengthMismatch();

    /// @notice Emits an event when the owner successfully invalidates an unordered nonce.
    event UnorderedNonceInvalidation(address indexed owner, uint256 word, uint256 mask);

    /// @notice The token and amount details for a transfer signed in the permit transfer signature
    struct TokenPermissions {
        // ERC20 token address
        address token;
        // the maximum amount that can be spent
        uint256 amount;
    }

    /// @notice The signed permit message for a single token transfer
    struct PermitTransferFrom {
        TokenPermissions permitted;
        // a unique value for every token owner's signature to prevent signature replays
        uint256 nonce;
        // deadline on the permit signature
        uint256 deadline;
    }

    /// @notice Specifies the recipient address and amount for batched transfers.
    /// @dev Recipients and amounts correspond to the index of the signed token permissions array.
    /// @dev Reverts if the requested amount is greater than the permitted signed amount.
    struct SignatureTransferDetails {
        // recipient address
        address to;
        // spender requested amount
        uint256 requestedAmount;
    }

    /// @notice Used to reconstruct the signed permit message for multiple token transfers
    /// @dev Do not need to pass in spender address as it is required that it is msg.sender
    /// @dev Note that a user still signs over a spender address
    struct PermitBatchTransferFrom {
        // the tokens and corresponding amounts permitted for a transfer
        TokenPermissions[] permitted;
        // a unique value for every token owner's signature to prevent signature replays
        uint256 nonce;
        // deadline on the permit signature
        uint256 deadline;
    }

    /// @notice A map from token owner address and a caller specified word index to a bitmap. Used to set bits in the bitmap to prevent against signature replay protection
    /// @dev Uses unordered nonces so that permit messages do not need to be spent in a certain order
    /// @dev The mapping is indexed first by the token owner, then by an index specified in the nonce
    /// @dev It returns a uint256 bitmap
    /// @dev The index, or wordPosition is capped at type(uint248).max
    function nonceBitmap(address, uint256) external view returns (uint256);

    /// @notice Transfers a token using a signed permit message
    /// @dev Reverts if the requested amount is greater than the permitted signed amount
    /// @param permit The permit data signed over by the owner
    /// @param owner The owner of the tokens to transfer
    /// @param transferDetails The spender's requested transfer details for the permitted token
    /// @param signature The signature to verify
    function permitTransferFrom(
        PermitTransferFrom memory permit,
        SignatureTransferDetails calldata transferDetails,
        address owner,
        bytes calldata signature
    ) external;

    /// @notice Transfers a token using a signed permit message
    /// @notice Includes extra data provided by the caller to verify signature over
    /// @dev The witness type string must follow EIP712 ordering of nested structs and must include the TokenPermissions type definition
    /// @dev Reverts if the requested amount is greater than the permitted signed amount
    /// @param permit The permit data signed over by the owner
    /// @param owner The owner of the tokens to transfer
    /// @param transferDetails The spender's requested transfer details for the permitted token
    /// @param witness Extra data to include when checking the user signature
    /// @param witnessTypeString The EIP-712 type definition for remaining string stub of the typehash
    /// @param signature The signature to verify
    function permitWitnessTransferFrom(
        PermitTransferFrom memory permit,
        SignatureTransferDetails calldata transferDetails,
        address owner,
        bytes32 witness,
        string calldata witnessTypeString,
        bytes calldata signature
    ) external;

    /// @notice Transfers multiple tokens using a signed permit message
    /// @param permit The permit data signed over by the owner
    /// @param owner The owner of the tokens to transfer
    /// @param transferDetails Specifies the recipient and requested amount for the token transfer
    /// @param signature The signature to verify
    function permitTransferFrom(
        PermitBatchTransferFrom memory permit,
        SignatureTransferDetails[] calldata transferDetails,
        address owner,
        bytes calldata signature
    ) external;

    /// @notice Transfers multiple tokens using a signed permit message
    /// @dev The witness type string must follow EIP712 ordering of nested structs and must include the TokenPermissions type definition
    /// @notice Includes extra data provided by the caller to verify signature over
    /// @param permit The permit data signed over by the owner
    /// @param owner The owner of the tokens to transfer
    /// @param transferDetails Specifies the recipient and requested amount for the token transfer
    /// @param witness Extra data to include when checking the user signature
    /// @param witnessTypeString The EIP-712 type definition for remaining string stub of the typehash
    /// @param signature The signature to verify
    function permitWitnessTransferFrom(
        PermitBatchTransferFrom memory permit,
        SignatureTransferDetails[] calldata transferDetails,
        address owner,
        bytes32 witness,
        string calldata witnessTypeString,
        bytes calldata signature
    ) external;

    /// @notice Invalidates the bits specified in mask for the bitmap at the word position
    /// @dev The wordPos is maxed at type(uint248).max
    /// @param wordPos A number to index the nonceBitmap at
    /// @param mask A bitmap masked against msg.sender's current bitmap at the word position
    function invalidateUnorderedNonces(uint256 wordPos, uint256 mask) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Simple ERC20 + EIP-2612 implementation.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/tokens/ERC20.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC20.sol)
/// @author Modified from OpenZeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol)
///
/// @dev Note:
/// - The ERC20 standard allows minting and transferring to and from the zero address,
///   minting and transferring zero tokens, as well as self-approvals.
///   For performance, this implementation WILL NOT revert for such actions.
///   Please add any checks with overrides if desired.
/// - The `permit` function uses the ecrecover precompile (0x1).
///
/// If you are overriding:
/// - NEVER violate the ERC20 invariant:
///   the total sum of all balances must be equal to `totalSupply()`.
/// - Check that the overridden function is actually used in the function you want to
///   change the behavior of. Much of the code has been manually inlined for performance.
abstract contract ERC20 {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       CUSTOM ERRORS                        */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The total supply has overflowed.
    error TotalSupplyOverflow();

    /// @dev The allowance has overflowed.
    error AllowanceOverflow();

    /// @dev The allowance has underflowed.
    error AllowanceUnderflow();

    /// @dev Insufficient balance.
    error InsufficientBalance();

    /// @dev Insufficient allowance.
    error InsufficientAllowance();

    /// @dev The permit is invalid.
    error InvalidPermit();

    /// @dev The permit has expired.
    error PermitExpired();

    /// @dev The allowance of Permit2 is fixed at infinity.
    error Permit2AllowanceIsFixedAtInfinity();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                           EVENTS                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Emitted when `amount` tokens is transferred from `from` to `to`.
    event Transfer(address indexed from, address indexed to, uint256 amount);

    /// @dev Emitted when `amount` tokens is approved by `owner` to be used by `spender`.
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    /// @dev `keccak256(bytes("Transfer(address,address,uint256)"))`.
    uint256 private constant _TRANSFER_EVENT_SIGNATURE =
        0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef;

    /// @dev `keccak256(bytes("Approval(address,address,uint256)"))`.
    uint256 private constant _APPROVAL_EVENT_SIGNATURE =
        0x8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                          STORAGE                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The storage slot for the total supply.
    uint256 private constant _TOTAL_SUPPLY_SLOT = 0x05345cdf77eb68f44c;

    /// @dev The balance slot of `owner` is given by:
    /// ```
    ///     mstore(0x0c, _BALANCE_SLOT_SEED)
    ///     mstore(0x00, owner)
    ///     let balanceSlot := keccak256(0x0c, 0x20)
    /// ```
    uint256 private constant _BALANCE_SLOT_SEED = 0x87a211a2;

    /// @dev The allowance slot of (`owner`, `spender`) is given by:
    /// ```
    ///     mstore(0x20, spender)
    ///     mstore(0x0c, _ALLOWANCE_SLOT_SEED)
    ///     mstore(0x00, owner)
    ///     let allowanceSlot := keccak256(0x0c, 0x34)
    /// ```
    uint256 private constant _ALLOWANCE_SLOT_SEED = 0x7f5e9f20;

    /// @dev The nonce slot of `owner` is given by:
    /// ```
    ///     mstore(0x0c, _NONCES_SLOT_SEED)
    ///     mstore(0x00, owner)
    ///     let nonceSlot := keccak256(0x0c, 0x20)
    /// ```
    uint256 private constant _NONCES_SLOT_SEED = 0x38377508;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         CONSTANTS                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev `(_NONCES_SLOT_SEED << 16) | 0x1901`.
    uint256 private constant _NONCES_SLOT_SEED_WITH_SIGNATURE_PREFIX = 0x383775081901;

    /// @dev `keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)")`.
    bytes32 private constant _DOMAIN_TYPEHASH =
        0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f;

    /// @dev `keccak256("1")`.
    /// If you need to use a different version, override `_versionHash`.
    bytes32 private constant _DEFAULT_VERSION_HASH =
        0xc89efdaa54c0f20c7adf612882df0950f5a951637e0307cdcb4c672f298b8bc6;

    /// @dev `keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)")`.
    bytes32 private constant _PERMIT_TYPEHASH =
        0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;

    /// @dev The canonical Permit2 address.
    /// For signature-based allowance granting for single transaction ERC20 `transferFrom`.
    /// To enable, override `_givePermit2InfiniteAllowance()`.
    /// [Github](https://github.com/Uniswap/permit2)
    /// [Etherscan](https://etherscan.io/address/0x000000000022D473030F116dDEE9F6B43aC78BA3)
    address internal constant _PERMIT2 = 0x000000000022D473030F116dDEE9F6B43aC78BA3;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       ERC20 METADATA                       */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns the name of the token.
    function name() public view virtual returns (string memory);

    /// @dev Returns the symbol of the token.
    function symbol() public view virtual returns (string memory);

    /// @dev Returns the decimals places of the token.
    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                           ERC20                            */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns the amount of tokens in existence.
    function totalSupply() public view virtual returns (uint256 result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := sload(_TOTAL_SUPPLY_SLOT)
        }
    }

    /// @dev Returns the amount of tokens owned by `owner`.
    function balanceOf(address owner) public view virtual returns (uint256 result) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x0c, _BALANCE_SLOT_SEED)
            mstore(0x00, owner)
            result := sload(keccak256(0x0c, 0x20))
        }
    }

    /// @dev Returns the amount of tokens that `spender` can spend on behalf of `owner`.
    function allowance(address owner, address spender)
        public
        view
        virtual
        returns (uint256 result)
    {
        if (_givePermit2InfiniteAllowance()) {
            if (spender == _PERMIT2) return type(uint256).max;
        }
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x20, spender)
            mstore(0x0c, _ALLOWANCE_SLOT_SEED)
            mstore(0x00, owner)
            result := sload(keccak256(0x0c, 0x34))
        }
    }

    /// @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
    ///
    /// Emits a {Approval} event.
    function approve(address spender, uint256 amount) public virtual returns (bool) {
        if (_givePermit2InfiniteAllowance()) {
            /// @solidity memory-safe-assembly
            assembly {
                // If `spender == _PERMIT2 && amount != type(uint256).max`.
                if iszero(or(xor(shr(96, shl(96, spender)), _PERMIT2), iszero(not(amount)))) {
                    mstore(0x00, 0x3f68539a) // `Permit2AllowanceIsFixedAtInfinity()`.
                    revert(0x1c, 0x04)
                }
            }
        }
        /// @solidity memory-safe-assembly
        assembly {
            // Compute the allowance slot and store the amount.
            mstore(0x20, spender)
            mstore(0x0c, _ALLOWANCE_SLOT_SEED)
            mstore(0x00, caller())
            sstore(keccak256(0x0c, 0x34), amount)
            // Emit the {Approval} event.
            mstore(0x00, amount)
            log3(0x00, 0x20, _APPROVAL_EVENT_SIGNATURE, caller(), shr(96, mload(0x2c)))
        }
        return true;
    }

    /// @dev Transfer `amount` tokens from the caller to `to`.
    ///
    /// Requirements:
    /// - `from` must at least have `amount`.
    ///
    /// Emits a {Transfer} event.
    function transfer(address to, uint256 amount) public virtual returns (bool) {
        _beforeTokenTransfer(msg.sender, to, amount);
        /// @solidity memory-safe-assembly
        assembly {
            // Compute the balance slot and load its value.
            mstore(0x0c, _BALANCE_SLOT_SEED)
            mstore(0x00, caller())
            let fromBalanceSlot := keccak256(0x0c, 0x20)
            let fromBalance := sload(fromBalanceSlot)
            // Revert if insufficient balance.
            if gt(amount, fromBalance) {
                mstore(0x00, 0xf4d678b8) // `InsufficientBalance()`.
                revert(0x1c, 0x04)
            }
            // Subtract and store the updated balance.
            sstore(fromBalanceSlot, sub(fromBalance, amount))
            // Compute the balance slot of `to`.
            mstore(0x00, to)
            let toBalanceSlot := keccak256(0x0c, 0x20)
            // Add and store the updated balance of `to`.
            // Will not overflow because the sum of all user balances
            // cannot exceed the maximum uint256 value.
            sstore(toBalanceSlot, add(sload(toBalanceSlot), amount))
            // Emit the {Transfer} event.
            mstore(0x20, amount)
            log3(0x20, 0x20, _TRANSFER_EVENT_SIGNATURE, caller(), shr(96, mload(0x0c)))
        }
        _afterTokenTransfer(msg.sender, to, amount);
        return true;
    }

    /// @dev Transfers `amount` tokens from `from` to `to`.
    ///
    /// Note: Does not update the allowance if it is the maximum uint256 value.
    ///
    /// Requirements:
    /// - `from` must at least have `amount`.
    /// - The caller must have at least `amount` of allowance to transfer the tokens of `from`.
    ///
    /// Emits a {Transfer} event.
    function transferFrom(address from, address to, uint256 amount) public virtual returns (bool) {
        _beforeTokenTransfer(from, to, amount);
        // Code duplication is for zero-cost abstraction if possible.
        if (_givePermit2InfiniteAllowance()) {
            /// @solidity memory-safe-assembly
            assembly {
                let from_ := shl(96, from)
                if iszero(eq(caller(), _PERMIT2)) {
                    // Compute the allowance slot and load its value.
                    mstore(0x20, caller())
                    mstore(0x0c, or(from_, _ALLOWANCE_SLOT_SEED))
                    let allowanceSlot := keccak256(0x0c, 0x34)
                    let allowance_ := sload(allowanceSlot)
                    // If the allowance is not the maximum uint256 value.
                    if not(allowance_) {
                        // Revert if the amount to be transferred exceeds the allowance.
                        if gt(amount, allowance_) {
                            mstore(0x00, 0x13be252b) // `InsufficientAllowance()`.
                            revert(0x1c, 0x04)
                        }
                        // Subtract and store the updated allowance.
                        sstore(allowanceSlot, sub(allowance_, amount))
                    }
                }
                // Compute the balance slot and load its value.
                mstore(0x0c, or(from_, _BALANCE_SLOT_SEED))
                let fromBalanceSlot := keccak256(0x0c, 0x20)
                let fromBalance := sload(fromBalanceSlot)
                // Revert if insufficient balance.
                if gt(amount, fromBalance) {
                    mstore(0x00, 0xf4d678b8) // `InsufficientBalance()`.
                    revert(0x1c, 0x04)
                }
                // Subtract and store the updated balance.
                sstore(fromBalanceSlot, sub(fromBalance, amount))
                // Compute the balance slot of `to`.
                mstore(0x00, to)
                let toBalanceSlot := keccak256(0x0c, 0x20)
                // Add and store the updated balance of `to`.
                // Will not overflow because the sum of all user balances
                // cannot exceed the maximum uint256 value.
                sstore(toBalanceSlot, add(sload(toBalanceSlot), amount))
                // Emit the {Transfer} event.
                mstore(0x20, amount)
                log3(0x20, 0x20, _TRANSFER_EVENT_SIGNATURE, shr(96, from_), shr(96, mload(0x0c)))
            }
        } else {
            /// @solidity memory-safe-assembly
            assembly {
                let from_ := shl(96, from)
                // Compute the allowance slot and load its value.
                mstore(0x20, caller())
                mstore(0x0c, or(from_, _ALLOWANCE_SLOT_SEED))
                let allowanceSlot := keccak256(0x0c, 0x34)
                let allowance_ := sload(allowanceSlot)
                // If the allowance is not the maximum uint256 value.
                if not(allowance_) {
                    // Revert if the amount to be transferred exceeds the allowance.
                    if gt(amount, allowance_) {
                        mstore(0x00, 0x13be252b) // `InsufficientAllowance()`.
                        revert(0x1c, 0x04)
                    }
                    // Subtract and store the updated allowance.
                    sstore(allowanceSlot, sub(allowance_, amount))
                }
                // Compute the balance slot and load its value.
                mstore(0x0c, or(from_, _BALANCE_SLOT_SEED))
                let fromBalanceSlot := keccak256(0x0c, 0x20)
                let fromBalance := sload(fromBalanceSlot)
                // Revert if insufficient balance.
                if gt(amount, fromBalance) {
                    mstore(0x00, 0xf4d678b8) // `InsufficientBalance()`.
                    revert(0x1c, 0x04)
                }
                // Subtract and store the updated balance.
                sstore(fromBalanceSlot, sub(fromBalance, amount))
                // Compute the balance slot of `to`.
                mstore(0x00, to)
                let toBalanceSlot := keccak256(0x0c, 0x20)
                // Add and store the updated balance of `to`.
                // Will not overflow because the sum of all user balances
                // cannot exceed the maximum uint256 value.
                sstore(toBalanceSlot, add(sload(toBalanceSlot), amount))
                // Emit the {Transfer} event.
                mstore(0x20, amount)
                log3(0x20, 0x20, _TRANSFER_EVENT_SIGNATURE, shr(96, from_), shr(96, mload(0x0c)))
            }
        }
        _afterTokenTransfer(from, to, amount);
        return true;
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                          EIP-2612                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev For more performance, override to return the constant value
    /// of `keccak256(bytes(name()))` if `name()` will never change.
    function _constantNameHash() internal view virtual returns (bytes32 result) {}

    /// @dev If you need a different value, override this function.
    function _versionHash() internal view virtual returns (bytes32 result) {
        result = _DEFAULT_VERSION_HASH;
    }

    /// @dev For inheriting contracts to increment the nonce.
    function _incrementNonce(address owner) internal virtual {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x0c, _NONCES_SLOT_SEED)
            mstore(0x00, owner)
            let nonceSlot := keccak256(0x0c, 0x20)
            sstore(nonceSlot, add(1, sload(nonceSlot)))
        }
    }

    /// @dev Returns the current nonce for `owner`.
    /// This value is used to compute the signature for EIP-2612 permit.
    function nonces(address owner) public view virtual returns (uint256 result) {
        /// @solidity memory-safe-assembly
        assembly {
            // Compute the nonce slot and load its value.
            mstore(0x0c, _NONCES_SLOT_SEED)
            mstore(0x00, owner)
            result := sload(keccak256(0x0c, 0x20))
        }
    }

    /// @dev Sets `value` as the allowance of `spender` over the tokens of `owner`,
    /// authorized by a signed approval by `owner`.
    ///
    /// Emits a {Approval} event.
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        if (_givePermit2InfiniteAllowance()) {
            /// @solidity memory-safe-assembly
            assembly {
                // If `spender == _PERMIT2 && value != type(uint256).max`.
                if iszero(or(xor(shr(96, shl(96, spender)), _PERMIT2), iszero(not(value)))) {
                    mstore(0x00, 0x3f68539a) // `Permit2AllowanceIsFixedAtInfinity()`.
                    revert(0x1c, 0x04)
                }
            }
        }
        bytes32 nameHash = _constantNameHash();
        //  We simply calculate it on-the-fly to allow for cases where the `name` may change.
        if (nameHash == bytes32(0)) nameHash = keccak256(bytes(name()));
        bytes32 versionHash = _versionHash();
        /// @solidity memory-safe-assembly
        assembly {
            // Revert if the block timestamp is greater than `deadline`.
            if gt(timestamp(), deadline) {
                mstore(0x00, 0x1a15a3cc) // `PermitExpired()`.
                revert(0x1c, 0x04)
            }
            let m := mload(0x40) // Grab the free memory pointer.
            // Clean the upper 96 bits.
            owner := shr(96, shl(96, owner))
            spender := shr(96, shl(96, spender))
            // Compute the nonce slot and load its value.
            mstore(0x0e, _NONCES_SLOT_SEED_WITH_SIGNATURE_PREFIX)
            mstore(0x00, owner)
            let nonceSlot := keccak256(0x0c, 0x20)
            let nonceValue := sload(nonceSlot)
            // Prepare the domain separator.
            mstore(m, _DOMAIN_TYPEHASH)
            mstore(add(m, 0x20), nameHash)
            mstore(add(m, 0x40), versionHash)
            mstore(add(m, 0x60), chainid())
            mstore(add(m, 0x80), address())
            mstore(0x2e, keccak256(m, 0xa0))
            // Prepare the struct hash.
            mstore(m, _PERMIT_TYPEHASH)
            mstore(add(m, 0x20), owner)
            mstore(add(m, 0x40), spender)
            mstore(add(m, 0x60), value)
            mstore(add(m, 0x80), nonceValue)
            mstore(add(m, 0xa0), deadline)
            mstore(0x4e, keccak256(m, 0xc0))
            // Prepare the ecrecover calldata.
            mstore(0x00, keccak256(0x2c, 0x42))
            mstore(0x20, and(0xff, v))
            mstore(0x40, r)
            mstore(0x60, s)
            let t := staticcall(gas(), 1, 0x00, 0x80, 0x20, 0x20)
            // If the ecrecover fails, the returndatasize will be 0x00,
            // `owner` will be checked if it equals the hash at 0x00,
            // which evaluates to false (i.e. 0), and we will revert.
            // If the ecrecover succeeds, the returndatasize will be 0x20,
            // `owner` will be compared against the returned address at 0x20.
            if iszero(eq(mload(returndatasize()), owner)) {
                mstore(0x00, 0xddafbaef) // `InvalidPermit()`.
                revert(0x1c, 0x04)
            }
            // Increment and store the updated nonce.
            sstore(nonceSlot, add(nonceValue, t)) // `t` is 1 if ecrecover succeeds.
            // Compute the allowance slot and store the value.
            // The `owner` is already at slot 0x20.
            mstore(0x40, or(shl(160, _ALLOWANCE_SLOT_SEED), spender))
            sstore(keccak256(0x2c, 0x34), value)
            // Emit the {Approval} event.
            log3(add(m, 0x60), 0x20, _APPROVAL_EVENT_SIGNATURE, owner, spender)
            mstore(0x40, m) // Restore the free memory pointer.
            mstore(0x60, 0) // Restore the zero pointer.
        }
    }

    /// @dev Returns the EIP-712 domain separator for the EIP-2612 permit.
    function DOMAIN_SEPARATOR() public view virtual returns (bytes32 result) {
        bytes32 nameHash = _constantNameHash();
        //  We simply calculate it on-the-fly to allow for cases where the `name` may change.
        if (nameHash == bytes32(0)) nameHash = keccak256(bytes(name()));
        bytes32 versionHash = _versionHash();
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Grab the free memory pointer.
            mstore(m, _DOMAIN_TYPEHASH)
            mstore(add(m, 0x20), nameHash)
            mstore(add(m, 0x40), versionHash)
            mstore(add(m, 0x60), chainid())
            mstore(add(m, 0x80), address())
            result := keccak256(m, 0xa0)
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                  INTERNAL MINT FUNCTIONS                   */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Mints `amount` tokens to `to`, increasing the total supply.
    ///
    /// Emits a {Transfer} event.
    function _mint(address to, uint256 amount) internal virtual {
        _beforeTokenTransfer(address(0), to, amount);
        /// @solidity memory-safe-assembly
        assembly {
            let totalSupplyBefore := sload(_TOTAL_SUPPLY_SLOT)
            let totalSupplyAfter := add(totalSupplyBefore, amount)
            // Revert if the total supply overflows.
            if lt(totalSupplyAfter, totalSupplyBefore) {
                mstore(0x00, 0xe5cfe957) // `TotalSupplyOverflow()`.
                revert(0x1c, 0x04)
            }
            // Store the updated total supply.
            sstore(_TOTAL_SUPPLY_SLOT, totalSupplyAfter)
            // Compute the balance slot and load its value.
            mstore(0x0c, _BALANCE_SLOT_SEED)
            mstore(0x00, to)
            let toBalanceSlot := keccak256(0x0c, 0x20)
            // Add and store the updated balance.
            sstore(toBalanceSlot, add(sload(toBalanceSlot), amount))
            // Emit the {Transfer} event.
            mstore(0x20, amount)
            log3(0x20, 0x20, _TRANSFER_EVENT_SIGNATURE, 0, shr(96, mload(0x0c)))
        }
        _afterTokenTransfer(address(0), to, amount);
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                  INTERNAL BURN FUNCTIONS                   */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Burns `amount` tokens from `from`, reducing the total supply.
    ///
    /// Emits a {Transfer} event.
    function _burn(address from, uint256 amount) internal virtual {
        _beforeTokenTransfer(from, address(0), amount);
        /// @solidity memory-safe-assembly
        assembly {
            // Compute the balance slot and load its value.
            mstore(0x0c, _BALANCE_SLOT_SEED)
            mstore(0x00, from)
            let fromBalanceSlot := keccak256(0x0c, 0x20)
            let fromBalance := sload(fromBalanceSlot)
            // Revert if insufficient balance.
            if gt(amount, fromBalance) {
                mstore(0x00, 0xf4d678b8) // `InsufficientBalance()`.
                revert(0x1c, 0x04)
            }
            // Subtract and store the updated balance.
            sstore(fromBalanceSlot, sub(fromBalance, amount))
            // Subtract and store the updated total supply.
            sstore(_TOTAL_SUPPLY_SLOT, sub(sload(_TOTAL_SUPPLY_SLOT), amount))
            // Emit the {Transfer} event.
            mstore(0x00, amount)
            log3(0x00, 0x20, _TRANSFER_EVENT_SIGNATURE, shr(96, shl(96, from)), 0)
        }
        _afterTokenTransfer(from, address(0), amount);
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                INTERNAL TRANSFER FUNCTIONS                 */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Moves `amount` of tokens from `from` to `to`.
    function _transfer(address from, address to, uint256 amount) internal virtual {
        _beforeTokenTransfer(from, to, amount);
        /// @solidity memory-safe-assembly
        assembly {
            let from_ := shl(96, from)
            // Compute the balance slot and load its value.
            mstore(0x0c, or(from_, _BALANCE_SLOT_SEED))
            let fromBalanceSlot := keccak256(0x0c, 0x20)
            let fromBalance := sload(fromBalanceSlot)
            // Revert if insufficient balance.
            if gt(amount, fromBalance) {
                mstore(0x00, 0xf4d678b8) // `InsufficientBalance()`.
                revert(0x1c, 0x04)
            }
            // Subtract and store the updated balance.
            sstore(fromBalanceSlot, sub(fromBalance, amount))
            // Compute the balance slot of `to`.
            mstore(0x00, to)
            let toBalanceSlot := keccak256(0x0c, 0x20)
            // Add and store the updated balance of `to`.
            // Will not overflow because the sum of all user balances
            // cannot exceed the maximum uint256 value.
            sstore(toBalanceSlot, add(sload(toBalanceSlot), amount))
            // Emit the {Transfer} event.
            mstore(0x20, amount)
            log3(0x20, 0x20, _TRANSFER_EVENT_SIGNATURE, shr(96, from_), shr(96, mload(0x0c)))
        }
        _afterTokenTransfer(from, to, amount);
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                INTERNAL ALLOWANCE FUNCTIONS                */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Updates the allowance of `owner` for `spender` based on spent `amount`.
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        if (_givePermit2InfiniteAllowance()) {
            if (spender == _PERMIT2) return; // Do nothing, as allowance is infinite.
        }
        /// @solidity memory-safe-assembly
        assembly {
            // Compute the allowance slot and load its value.
            mstore(0x20, spender)
            mstore(0x0c, _ALLOWANCE_SLOT_SEED)
            mstore(0x00, owner)
            let allowanceSlot := keccak256(0x0c, 0x34)
            let allowance_ := sload(allowanceSlot)
            // If the allowance is not the maximum uint256 value.
            if not(allowance_) {
                // Revert if the amount to be transferred exceeds the allowance.
                if gt(amount, allowance_) {
                    mstore(0x00, 0x13be252b) // `InsufficientAllowance()`.
                    revert(0x1c, 0x04)
                }
                // Subtract and store the updated allowance.
                sstore(allowanceSlot, sub(allowance_, amount))
            }
        }
    }

    /// @dev Sets `amount` as the allowance of `spender` over the tokens of `owner`.
    ///
    /// Emits a {Approval} event.
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        if (_givePermit2InfiniteAllowance()) {
            /// @solidity memory-safe-assembly
            assembly {
                // If `spender == _PERMIT2 && amount != type(uint256).max`.
                if iszero(or(xor(shr(96, shl(96, spender)), _PERMIT2), iszero(not(amount)))) {
                    mstore(0x00, 0x3f68539a) // `Permit2AllowanceIsFixedAtInfinity()`.
                    revert(0x1c, 0x04)
                }
            }
        }
        /// @solidity memory-safe-assembly
        assembly {
            let owner_ := shl(96, owner)
            // Compute the allowance slot and store the amount.
            mstore(0x20, spender)
            mstore(0x0c, or(owner_, _ALLOWANCE_SLOT_SEED))
            sstore(keccak256(0x0c, 0x34), amount)
            // Emit the {Approval} event.
            mstore(0x00, amount)
            log3(0x00, 0x20, _APPROVAL_EVENT_SIGNATURE, shr(96, owner_), shr(96, mload(0x2c)))
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                     HOOKS TO OVERRIDE                      */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Hook that is called before any transfer of tokens.
    /// This includes minting and burning.
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    /// @dev Hook that is called after any transfer of tokens.
    /// This includes minting and burning.
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                          PERMIT2                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns whether to fix the Permit2 contract's allowance at infinity.
    ///
    /// This value should be kept constant after contract initialization,
    /// or else the actual allowance values may not match with the {Approval} events.
    /// For best performance, return a compile-time constant for zero-cost abstraction.
    function _givePermit2InfiniteAllowance() internal view virtual returns (bool) {
        return false;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {ERC20} from "./ERC20.sol";

/// @notice Simple Wrapped Ether implementation.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/tokens/WETH.sol)
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/WETH.sol)
/// @author Inspired by WETH9 (https://github.com/dapphub/ds-weth/blob/master/src/weth9.sol)
contract WETH is ERC20 {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       CUSTOM ERRORS                        */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The ETH transfer has failed.
    error ETHTransferFailed();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       ERC20 METADATA                       */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns the name of the token.
    function name() public view virtual override returns (string memory) {
        return "Wrapped Ether";
    }

    /// @dev Returns the symbol of the token.
    function symbol() public view virtual override returns (string memory) {
        return "WETH";
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                            WETH                            */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Deposits `amount` ETH of the caller and mints `amount` WETH to the caller.
    function deposit() public payable virtual {
        _mint(msg.sender, msg.value);
    }

    /// @dev Burns `amount` WETH of the caller and sends `amount` ETH to the caller.
    function withdraw(uint256 amount) public virtual {
        _burn(msg.sender, amount);
        /// @solidity memory-safe-assembly
        assembly {
            // Transfer the ETH and check if it succeeded or not.
            if iszero(call(gas(), caller(), amount, codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, 0xb12d13eb) // `ETHTransferFailed()`.
                revert(0x1c, 0x04)
            }
        }
    }

    /// @dev Equivalent to `deposit()`.
    receive() external payable virtual {
        deposit();
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Safe ETH and ERC20 transfer library that gracefully handles missing return values.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/SafeTransferLib.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/SafeTransferLib.sol)
/// @author Permit2 operations from (https://github.com/Uniswap/permit2/blob/main/src/libraries/Permit2Lib.sol)
///
/// @dev Note:
/// - For ETH transfers, please use `forceSafeTransferETH` for DoS protection.
library SafeTransferLib {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       CUSTOM ERRORS                        */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The ETH transfer has failed.
    error ETHTransferFailed();

    /// @dev The ERC20 `transferFrom` has failed.
    error TransferFromFailed();

    /// @dev The ERC20 `transfer` has failed.
    error TransferFailed();

    /// @dev The ERC20 `approve` has failed.
    error ApproveFailed();

    /// @dev The ERC20 `totalSupply` query has failed.
    error TotalSupplyQueryFailed();

    /// @dev The Permit2 operation has failed.
    error Permit2Failed();

    /// @dev The Permit2 amount must be less than `2**160 - 1`.
    error Permit2AmountOverflow();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         CONSTANTS                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Suggested gas stipend for contract receiving ETH that disallows any storage writes.
    uint256 internal constant GAS_STIPEND_NO_STORAGE_WRITES = 2300;

    /// @dev Suggested gas stipend for contract receiving ETH to perform a few
    /// storage reads and writes, but low enough to prevent griefing.
    uint256 internal constant GAS_STIPEND_NO_GRIEF = 100000;

    /// @dev The unique EIP-712 domain domain separator for the DAI token contract.
    bytes32 internal constant DAI_DOMAIN_SEPARATOR =
        0xdbb8cf42e1ecb028be3f3dbc922e1d878b963f411dc388ced501601c60f7c6f7;

    /// @dev The address for the WETH9 contract on Ethereum mainnet.
    address internal constant WETH9 = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    /// @dev The canonical Permit2 address.
    /// [Github](https://github.com/Uniswap/permit2)
    /// [Etherscan](https://etherscan.io/address/0x000000000022D473030F116dDEE9F6B43aC78BA3)
    address internal constant PERMIT2 = 0x000000000022D473030F116dDEE9F6B43aC78BA3;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       ETH OPERATIONS                       */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // If the ETH transfer MUST succeed with a reasonable gas budget, use the force variants.
    //
    // The regular variants:
    // - Forwards all remaining gas to the target.
    // - Reverts if the target reverts.
    // - Reverts if the current contract has insufficient balance.
    //
    // The force variants:
    // - Forwards with an optional gas stipend
    //   (defaults to `GAS_STIPEND_NO_GRIEF`, which is sufficient for most cases).
    // - If the target reverts, or if the gas stipend is exhausted,
    //   creates a temporary contract to force send the ETH via `SELFDESTRUCT`.
    //   Future compatible with `SENDALL`: https://eips.ethereum.org/EIPS/eip-4758.
    // - Reverts if the current contract has insufficient balance.
    //
    // The try variants:
    // - Forwards with a mandatory gas stipend.
    // - Instead of reverting, returns whether the transfer succeeded.

    /// @dev Sends `amount` (in wei) ETH to `to`.
    function safeTransferETH(address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            if iszero(call(gas(), to, amount, codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, 0xb12d13eb) // `ETHTransferFailed()`.
                revert(0x1c, 0x04)
            }
        }
    }

    /// @dev Sends all the ETH in the current contract to `to`.
    function safeTransferAllETH(address to) internal {
        /// @solidity memory-safe-assembly
        assembly {
            // Transfer all the ETH and check if it succeeded or not.
            if iszero(call(gas(), to, selfbalance(), codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, 0xb12d13eb) // `ETHTransferFailed()`.
                revert(0x1c, 0x04)
            }
        }
    }

    /// @dev Force sends `amount` (in wei) ETH to `to`, with a `gasStipend`.
    function forceSafeTransferETH(address to, uint256 amount, uint256 gasStipend) internal {
        /// @solidity memory-safe-assembly
        assembly {
            if lt(selfbalance(), amount) {
                mstore(0x00, 0xb12d13eb) // `ETHTransferFailed()`.
                revert(0x1c, 0x04)
            }
            if iszero(call(gasStipend, to, amount, codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, to) // Store the address in scratch space.
                mstore8(0x0b, 0x73) // Opcode `PUSH20`.
                mstore8(0x20, 0xff) // Opcode `SELFDESTRUCT`.
                if iszero(create(amount, 0x0b, 0x16)) { revert(codesize(), codesize()) } // For gas estimation.
            }
        }
    }

    /// @dev Force sends all the ETH in the current contract to `to`, with a `gasStipend`.
    function forceSafeTransferAllETH(address to, uint256 gasStipend) internal {
        /// @solidity memory-safe-assembly
        assembly {
            if iszero(call(gasStipend, to, selfbalance(), codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, to) // Store the address in scratch space.
                mstore8(0x0b, 0x73) // Opcode `PUSH20`.
                mstore8(0x20, 0xff) // Opcode `SELFDESTRUCT`.
                if iszero(create(selfbalance(), 0x0b, 0x16)) { revert(codesize(), codesize()) } // For gas estimation.
            }
        }
    }

    /// @dev Force sends `amount` (in wei) ETH to `to`, with `GAS_STIPEND_NO_GRIEF`.
    function forceSafeTransferETH(address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            if lt(selfbalance(), amount) {
                mstore(0x00, 0xb12d13eb) // `ETHTransferFailed()`.
                revert(0x1c, 0x04)
            }
            if iszero(call(GAS_STIPEND_NO_GRIEF, to, amount, codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, to) // Store the address in scratch space.
                mstore8(0x0b, 0x73) // Opcode `PUSH20`.
                mstore8(0x20, 0xff) // Opcode `SELFDESTRUCT`.
                if iszero(create(amount, 0x0b, 0x16)) { revert(codesize(), codesize()) } // For gas estimation.
            }
        }
    }

    /// @dev Force sends all the ETH in the current contract to `to`, with `GAS_STIPEND_NO_GRIEF`.
    function forceSafeTransferAllETH(address to) internal {
        /// @solidity memory-safe-assembly
        assembly {
            // forgefmt: disable-next-item
            if iszero(call(GAS_STIPEND_NO_GRIEF, to, selfbalance(), codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, to) // Store the address in scratch space.
                mstore8(0x0b, 0x73) // Opcode `PUSH20`.
                mstore8(0x20, 0xff) // Opcode `SELFDESTRUCT`.
                if iszero(create(selfbalance(), 0x0b, 0x16)) { revert(codesize(), codesize()) } // For gas estimation.
            }
        }
    }

    /// @dev Sends `amount` (in wei) ETH to `to`, with a `gasStipend`.
    function trySafeTransferETH(address to, uint256 amount, uint256 gasStipend)
        internal
        returns (bool success)
    {
        /// @solidity memory-safe-assembly
        assembly {
            success := call(gasStipend, to, amount, codesize(), 0x00, codesize(), 0x00)
        }
    }

    /// @dev Sends all the ETH in the current contract to `to`, with a `gasStipend`.
    function trySafeTransferAllETH(address to, uint256 gasStipend)
        internal
        returns (bool success)
    {
        /// @solidity memory-safe-assembly
        assembly {
            success := call(gasStipend, to, selfbalance(), codesize(), 0x00, codesize(), 0x00)
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      ERC20 OPERATIONS                      */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Sends `amount` of ERC20 `token` from `from` to `to`.
    /// Reverts upon failure.
    ///
    /// The `from` account must have at least `amount` approved for
    /// the current contract to manage.
    function safeTransferFrom(address token, address from, address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x60, amount) // Store the `amount` argument.
            mstore(0x40, to) // Store the `to` argument.
            mstore(0x2c, shl(96, from)) // Store the `from` argument.
            mstore(0x0c, 0x23b872dd000000000000000000000000) // `transferFrom(address,address,uint256)`.
            let success := call(gas(), token, 0, 0x1c, 0x64, 0x00, 0x20)
            if iszero(and(eq(mload(0x00), 1), success)) {
                if iszero(lt(or(iszero(extcodesize(token)), returndatasize()), success)) {
                    mstore(0x00, 0x7939f424) // `TransferFromFailed()`.
                    revert(0x1c, 0x04)
                }
            }
            mstore(0x60, 0) // Restore the zero slot to zero.
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Sends `amount` of ERC20 `token` from `from` to `to`.
    ///
    /// The `from` account must have at least `amount` approved for the current contract to manage.
    function trySafeTransferFrom(address token, address from, address to, uint256 amount)
        internal
        returns (bool success)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x60, amount) // Store the `amount` argument.
            mstore(0x40, to) // Store the `to` argument.
            mstore(0x2c, shl(96, from)) // Store the `from` argument.
            mstore(0x0c, 0x23b872dd000000000000000000000000) // `transferFrom(address,address,uint256)`.
            success := call(gas(), token, 0, 0x1c, 0x64, 0x00, 0x20)
            if iszero(and(eq(mload(0x00), 1), success)) {
                success := lt(or(iszero(extcodesize(token)), returndatasize()), success)
            }
            mstore(0x60, 0) // Restore the zero slot to zero.
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Sends all of ERC20 `token` from `from` to `to`.
    /// Reverts upon failure.
    ///
    /// The `from` account must have their entire balance approved for the current contract to manage.
    function safeTransferAllFrom(address token, address from, address to)
        internal
        returns (uint256 amount)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x40, to) // Store the `to` argument.
            mstore(0x2c, shl(96, from)) // Store the `from` argument.
            mstore(0x0c, 0x70a08231000000000000000000000000) // `balanceOf(address)`.
            // Read the balance, reverting upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    gt(returndatasize(), 0x1f), // At least 32 bytes returned.
                    staticcall(gas(), token, 0x1c, 0x24, 0x60, 0x20)
                )
            ) {
                mstore(0x00, 0x7939f424) // `TransferFromFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x00, 0x23b872dd) // `transferFrom(address,address,uint256)`.
            amount := mload(0x60) // The `amount` is already at 0x60. We'll need to return it.
            // Perform the transfer, reverting upon failure.
            let success := call(gas(), token, 0, 0x1c, 0x64, 0x00, 0x20)
            if iszero(and(eq(mload(0x00), 1), success)) {
                if iszero(lt(or(iszero(extcodesize(token)), returndatasize()), success)) {
                    mstore(0x00, 0x7939f424) // `TransferFromFailed()`.
                    revert(0x1c, 0x04)
                }
            }
            mstore(0x60, 0) // Restore the zero slot to zero.
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Sends `amount` of ERC20 `token` from the current contract to `to`.
    /// Reverts upon failure.
    function safeTransfer(address token, address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x14, to) // Store the `to` argument.
            mstore(0x34, amount) // Store the `amount` argument.
            mstore(0x00, 0xa9059cbb000000000000000000000000) // `transfer(address,uint256)`.
            // Perform the transfer, reverting upon failure.
            let success := call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
            if iszero(and(eq(mload(0x00), 1), success)) {
                if iszero(lt(or(iszero(extcodesize(token)), returndatasize()), success)) {
                    mstore(0x00, 0x90b8ec18) // `TransferFailed()`.
                    revert(0x1c, 0x04)
                }
            }
            mstore(0x34, 0) // Restore the part of the free memory pointer that was overwritten.
        }
    }

    /// @dev Sends all of ERC20 `token` from the current contract to `to`.
    /// Reverts upon failure.
    function safeTransferAll(address token, address to) internal returns (uint256 amount) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, 0x70a08231) // Store the function selector of `balanceOf(address)`.
            mstore(0x20, address()) // Store the address of the current contract.
            // Read the balance, reverting upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    gt(returndatasize(), 0x1f), // At least 32 bytes returned.
                    staticcall(gas(), token, 0x1c, 0x24, 0x34, 0x20)
                )
            ) {
                mstore(0x00, 0x90b8ec18) // `TransferFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x14, to) // Store the `to` argument.
            amount := mload(0x34) // The `amount` is already at 0x34. We'll need to return it.
            mstore(0x00, 0xa9059cbb000000000000000000000000) // `transfer(address,uint256)`.
            // Perform the transfer, reverting upon failure.
            let success := call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
            if iszero(and(eq(mload(0x00), 1), success)) {
                if iszero(lt(or(iszero(extcodesize(token)), returndatasize()), success)) {
                    mstore(0x00, 0x90b8ec18) // `TransferFailed()`.
                    revert(0x1c, 0x04)
                }
            }
            mstore(0x34, 0) // Restore the part of the free memory pointer that was overwritten.
        }
    }

    /// @dev Sets `amount` of ERC20 `token` for `to` to manage on behalf of the current contract.
    /// Reverts upon failure.
    function safeApprove(address token, address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x14, to) // Store the `to` argument.
            mstore(0x34, amount) // Store the `amount` argument.
            mstore(0x00, 0x095ea7b3000000000000000000000000) // `approve(address,uint256)`.
            let success := call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
            if iszero(and(eq(mload(0x00), 1), success)) {
                if iszero(lt(or(iszero(extcodesize(token)), returndatasize()), success)) {
                    mstore(0x00, 0x3e3f8f73) // `ApproveFailed()`.
                    revert(0x1c, 0x04)
                }
            }
            mstore(0x34, 0) // Restore the part of the free memory pointer that was overwritten.
        }
    }

    /// @dev Sets `amount` of ERC20 `token` for `to` to manage on behalf of the current contract.
    /// If the initial attempt to approve fails, attempts to reset the approved amount to zero,
    /// then retries the approval again (some tokens, e.g. USDT, requires this).
    /// Reverts upon failure.
    function safeApproveWithRetry(address token, address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x14, to) // Store the `to` argument.
            mstore(0x34, amount) // Store the `amount` argument.
            mstore(0x00, 0x095ea7b3000000000000000000000000) // `approve(address,uint256)`.
            // Perform the approval, retrying upon failure.
            let success := call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
            if iszero(and(eq(mload(0x00), 1), success)) {
                if iszero(lt(or(iszero(extcodesize(token)), returndatasize()), success)) {
                    mstore(0x34, 0) // Store 0 for the `amount`.
                    mstore(0x00, 0x095ea7b3000000000000000000000000) // `approve(address,uint256)`.
                    pop(call(gas(), token, 0, 0x10, 0x44, codesize(), 0x00)) // Reset the approval.
                    mstore(0x34, amount) // Store back the original `amount`.
                    // Retry the approval, reverting upon failure.
                    success := call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                    if iszero(and(eq(mload(0x00), 1), success)) {
                        // Check the `extcodesize` again just in case the token selfdestructs lol.
                        if iszero(lt(or(iszero(extcodesize(token)), returndatasize()), success)) {
                            mstore(0x00, 0x3e3f8f73) // `ApproveFailed()`.
                            revert(0x1c, 0x04)
                        }
                    }
                }
            }
            mstore(0x34, 0) // Restore the part of the free memory pointer that was overwritten.
        }
    }

    /// @dev Returns the amount of ERC20 `token` owned by `account`.
    /// Returns zero if the `token` does not exist.
    function balanceOf(address token, address account) internal view returns (uint256 amount) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x14, account) // Store the `account` argument.
            mstore(0x00, 0x70a08231000000000000000000000000) // `balanceOf(address)`.
            amount :=
                mul( // The arguments of `mul` are evaluated from right to left.
                    mload(0x20),
                    and( // The arguments of `and` are evaluated from right to left.
                        gt(returndatasize(), 0x1f), // At least 32 bytes returned.
                        staticcall(gas(), token, 0x10, 0x24, 0x20, 0x20)
                    )
                )
        }
    }

    /// @dev Returns the total supply of the `token`.
    /// Reverts if the token does not exist or does not implement `totalSupply()`.
    function totalSupply(address token) internal view returns (uint256 result) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, 0x18160ddd) // `totalSupply()`.
            if iszero(
                and(gt(returndatasize(), 0x1f), staticcall(gas(), token, 0x1c, 0x04, 0x00, 0x20))
            ) {
                mstore(0x00, 0x54cd9435) // `TotalSupplyQueryFailed()`.
                revert(0x1c, 0x04)
            }
            result := mload(0x00)
        }
    }

    /// @dev Sends `amount` of ERC20 `token` from `from` to `to`.
    /// If the initial attempt fails, try to use Permit2 to transfer the token.
    /// Reverts upon failure.
    ///
    /// The `from` account must have at least `amount` approved for the current contract to manage.
    function safeTransferFrom2(address token, address from, address to, uint256 amount) internal {
        if (!trySafeTransferFrom(token, from, to, amount)) {
            permit2TransferFrom(token, from, to, amount);
        }
    }

    /// @dev Sends `amount` of ERC20 `token` from `from` to `to` via Permit2.
    /// Reverts upon failure.
    function permit2TransferFrom(address token, address from, address to, uint256 amount)
        internal
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40)
            mstore(add(m, 0x74), shr(96, shl(96, token)))
            mstore(add(m, 0x54), amount)
            mstore(add(m, 0x34), to)
            mstore(add(m, 0x20), shl(96, from))
            // `transferFrom(address,address,uint160,address)`.
            mstore(m, 0x36c78516000000000000000000000000)
            let p := PERMIT2
            let exists := eq(chainid(), 1)
            if iszero(exists) { exists := iszero(iszero(extcodesize(p))) }
            if iszero(
                and(
                    call(gas(), p, 0, add(m, 0x10), 0x84, codesize(), 0x00),
                    lt(iszero(extcodesize(token)), exists) // Token has code and Permit2 exists.
                )
            ) {
                mstore(0x00, 0x7939f4248757f0fd) // `TransferFromFailed()` or `Permit2AmountOverflow()`.
                revert(add(0x18, shl(2, iszero(iszero(shr(160, amount))))), 0x04)
            }
        }
    }

    /// @dev Permit a user to spend a given amount of
    /// another user's tokens via native EIP-2612 permit if possible, falling
    /// back to Permit2 if native permit fails or is not implemented on the token.
    function permit2(
        address token,
        address owner,
        address spender,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        bool success;
        /// @solidity memory-safe-assembly
        assembly {
            for {} shl(96, xor(token, WETH9)) {} {
                mstore(0x00, 0x3644e515) // `DOMAIN_SEPARATOR()`.
                if iszero(
                    and( // The arguments of `and` are evaluated from right to left.
                        lt(iszero(mload(0x00)), eq(returndatasize(), 0x20)), // Returns 1 non-zero word.
                        // Gas stipend to limit gas burn for tokens that don't refund gas when
                        // an non-existing function is called. 5K should be enough for a SLOAD.
                        staticcall(5000, token, 0x1c, 0x04, 0x00, 0x20)
                    )
                ) { break }
                // After here, we can be sure that token is a contract.
                let m := mload(0x40)
                mstore(add(m, 0x34), spender)
                mstore(add(m, 0x20), shl(96, owner))
                mstore(add(m, 0x74), deadline)
                if eq(mload(0x00), DAI_DOMAIN_SEPARATOR) {
                    mstore(0x14, owner)
                    mstore(0x00, 0x7ecebe00000000000000000000000000) // `nonces(address)`.
                    mstore(add(m, 0x94), staticcall(gas(), token, 0x10, 0x24, add(m, 0x54), 0x20))
                    mstore(m, 0x8fcbaf0c000000000000000000000000) // `IDAIPermit.permit`.
                    // `nonces` is already at `add(m, 0x54)`.
                    // `1` is already stored at `add(m, 0x94)`.
                    mstore(add(m, 0xb4), and(0xff, v))
                    mstore(add(m, 0xd4), r)
                    mstore(add(m, 0xf4), s)
                    success := call(gas(), token, 0, add(m, 0x10), 0x104, codesize(), 0x00)
                    break
                }
                mstore(m, 0xd505accf000000000000000000000000) // `IERC20Permit.permit`.
                mstore(add(m, 0x54), amount)
                mstore(add(m, 0x94), and(0xff, v))
                mstore(add(m, 0xb4), r)
                mstore(add(m, 0xd4), s)
                success := call(gas(), token, 0, add(m, 0x10), 0xe4, codesize(), 0x00)
                break
            }
        }
        if (!success) simplePermit2(token, owner, spender, amount, deadline, v, r, s);
    }

    /// @dev Simple permit on the Permit2 contract.
    function simplePermit2(
        address token,
        address owner,
        address spender,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40)
            mstore(m, 0x927da105) // `allowance(address,address,address)`.
            {
                let addressMask := shr(96, not(0))
                mstore(add(m, 0x20), and(addressMask, owner))
                mstore(add(m, 0x40), and(addressMask, token))
                mstore(add(m, 0x60), and(addressMask, spender))
                mstore(add(m, 0xc0), and(addressMask, spender))
            }
            let p := mul(PERMIT2, iszero(shr(160, amount)))
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    gt(returndatasize(), 0x5f), // Returns 3 words: `amount`, `expiration`, `nonce`.
                    staticcall(gas(), p, add(m, 0x1c), 0x64, add(m, 0x60), 0x60)
                )
            ) {
                mstore(0x00, 0x6b836e6b8757f0fd) // `Permit2Failed()` or `Permit2AmountOverflow()`.
                revert(add(0x18, shl(2, iszero(p))), 0x04)
            }
            mstore(m, 0x2b67b570) // `Permit2.permit` (PermitSingle variant).
            // `owner` is already `add(m, 0x20)`.
            // `token` is already at `add(m, 0x40)`.
            mstore(add(m, 0x60), amount)
            mstore(add(m, 0x80), 0xffffffffffff) // `expiration = type(uint48).max`.
            // `nonce` is already at `add(m, 0xa0)`.
            // `spender` is already at `add(m, 0xc0)`.
            mstore(add(m, 0xe0), deadline)
            mstore(add(m, 0x100), 0x100) // `signature` offset.
            mstore(add(m, 0x120), 0x41) // `signature` length.
            mstore(add(m, 0x140), r)
            mstore(add(m, 0x160), s)
            mstore(add(m, 0x180), shl(248, v))
            if iszero( // Revert if token does not have code, or if the call fails.
            mul(extcodesize(token), call(gas(), p, 0, add(m, 0x1c), 0x184, codesize(), 0x00))) {
                mstore(0x00, 0x6b836e6b) // `Permit2Failed()`.
                revert(0x1c, 0x04)
            }
        }
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

/// @dev used to rescue funds
bytes32 constant RESCUE_ROLE = keccak256("RESCUE_ROLE");

/// @dev used to update configs on protocol contracts
bytes32 constant CONFIG_ROLE = keccak256("CONFIG_ROLE");

/// @dev used to update Socket DL configs
bytes32 constant SOCKET_CONFIG_ROLE = keccak256("SOCKET_CONFIG_ROLE");

/// @dev used to allow cancellation of requests
bytes32 constant CANCEL_ROLE = keccak256("CANCEL_ROLE");
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/*//////////////////////////////////////////////////////////////
                         BUNGEE ERRORS
//////////////////////////////////////////////////////////////*/

error MofaSignatureInvalid();
error InsufficientNativeAmount();
error UnsupportedRequest();
error RouterNotRegistered();
error CallerNotBungeeGateway();
error CallerNotEntrypoint();
error SwapOutputInsufficient();
error MinOutputNotMet();
error InvalidRequest();
error FulfilmentDeadlineNotMet();
error CallerNotDelegate();
error InvalidMsg();
error RequestProcessed();
error RequestNotProcessed();
error InvalidSwitchboard();
error PromisedAmountNotMet();
error MsgReceiveFailed();
error RouterAlreadyRegistered();
error InvalidFulfil();
error NotImplemented();
error OnlyOwner();
error OnlyNominee();
error InvalidReceiver();
error ImplAlreadyRegistered();
error InvalidAddress();

/*//////////////////////////////////////////////////////////////
                       SWITCHBOARD ERRORS
//////////////////////////////////////////////////////////////*/

error NotSiblingBungeeGateway();
error NotSocket();
error NotSwitchboardRouter();
error NotSwitchboardPlug();
error SwitchboardPlugZero();
error ConnectionAlreadyInitialised();
error IncorrectSwitchboard();
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

// Basic details in the request
struct BasicRequest {
    // src chain id
    uint256 originChainId;
    // dest chain id
    uint256 destinationChainId;
    // deadline of the request
    uint256 deadline;
    // nonce used for uniqueness in signature
    uint256 nonce;
    // address of the user placing the request.
    address sender;
    // address of the receiver on destination chain
    address receiver;
    // delegate address that has some rights over the request signed eg. cancellation
    address delegate;
    // address of bungee gateway, this address will have access to pull funds from the sender.
    address bungeeGateway;
    // id of the switchboard for settlement
    uint32 switchboardId;
    // address of the input token
    address inputToken;
    // amount of the input token
    uint256 inputAmount;
    // output token to be received on the destination.
    address outputToken;
    // minimum amount of output token to be received on the destination
    uint256 minOutputAmount;
    // native token refuel amount on the destination chain
    uint256 refuelAmount;
}

// The Request which user signs
struct Request {
    // basic details in the request.
    BasicRequest basicReq;
    // swap output token that the user is permitting to swap input token to.
    address swapOutputToken;
    // minimum swap output the user is okay with swapping the input token to.
    // Transmitter can choose or not choose to swap tokens.
    uint256 minSwapOutput;
    // any sort of metadata to be passed with the request
    bytes32 metadata;
    // fees of the affiliate if any
    bytes affiliateFees;
    // calldata execution parameter. Only to be used when execution is required on destination.
    // minimum dest gas limit to execute calldata on destination
    uint256 minDestGas;
    // calldata to be executed on the destination
    // calldata can only be executed on the receiver in the request.
    bytes destinationPayload;
    /// @dev address of the only transmitter that is permitted to execute the request.
    /// If the transmitter is not set, anyone can execute the request.
    /// This validation would be done off-chain by the auction house.
    address exclusiveTransmitter;
}

// Transmitter's origin chain execution details for a request
struct ExtractExec {
    // User signed Request
    Request request;
    // address of the router being used for executing the request
    address router;
    // amount of output token promised by transmitter on the destination
    uint256 promisedAmount;
    // encoded data to be used by router: RouterPayload + RouterValue (value required by the router) etc.
    bytes routerData;
    // encoded calldata to be used for swap 0x00 if no swap is involved.
    bytes swapPayload;
    // contract address to execute swap on
    address swapRouter;
    // user signature against the request
    bytes userSignature;
    // address of the beneficiary submitted by the transmitter.
    // the beneficiary will be the one receiving locked tokens when a request is settled.
    address beneficiary;
    // stake related information for the request used off-chain but emitted on-chain.
    // can include info like address stakeToken, uint256 lockedStake etc.
    bytes stakeData;
}

// Transmitter's destination chain execution details with fulfil amounts.
struct FulfilExec {
    // User Signed Request
    Request request;
    // address of the router being used for fulfilling the request
    address fulfilRouter;
    // amount of output token to be sent to the receiver
    uint256 fulfilAmount;
    // encoded data to be used by router: RouterPayload + RouterValue (value required by the router) etc.
    bytes routerData;
    // total msg.value to be sent to fulfil native token output token + refuel amount
    uint256 msgValue;
}

struct ExtractedRequest {
    // address of the router being used for executing the request
    address router;
    // address of the user placing the request.
    address sender;
    // delegate address that has some rights over the request signed eg. cancellation
    address delegate;
    // id of the switchboard for settlement
    uint32 switchboardId;
    // final input token used on the src chain. can be the intermediate swap output token
    address token;
    // address of the transmitter
    address transmitter;
    // address of the beneficiary submitted by the transmitter.
    address beneficiary;
    // final input token amount used on the src chain. can be the intermediate swap output token amount
    uint256 amount;
    // amount of output token promised by transmitter on the destination
    uint256 promisedAmount;
}

/* enum FulfilmentStatus {
    Pending, = 0
    Cancelled, = 1
    WithdrawnOnDestination = 2
    Fulfilled, = 3
} */

struct FulfilledRequest {
    // amount of output token fulfilled by transmitter on the destination
    uint256 fulfilledAmount;
    // flag indicating if the request has been processed - fulfilled or cancelled
    uint256 status;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

// Basic details in the request
struct BasicRequest {
    // chain id
    uint256 chainId;
    // deadline of the request
    uint256 deadline;
    // nonce used for uniqueness in signature
    uint256 nonce;
    // address of the user placing the request.
    address sender;
    // address of the receiver on destination chain
    address receiver;
    // address of bungee gateway, this address will have access to pull funds from the sender.
    address bungeeGateway;
    // address of the input token
    address inputToken;
    // amount of the input token
    uint256 inputAmount;
    // output token to be received
    address outputToken;
    // minimum amount of output token to be received on the destination
    uint256 minOutputAmount;
}

// The Request which user signs
struct Request {
    // basic details in the request.
    BasicRequest basicReq;
    // any sort of metadata to be passed with the request
    bytes32 metadata;
    // fees of the affiliate if any
    bytes affiliateFees;
    // calldata execution parameter. Only to be used when execution is required on destination.
    // minimum dest gas limit to execute calldata on destination
    uint256 minDestGas;
    // calldata to be executed
    // calldata can only be executed on the receiver in the request.
    bytes destinationPayload;
    /// @dev address of the only transmitter that is permitted to execute the request.
    /// If the transmitter is not set, anyone can execute the request.
    /// This validation would be done off-chain by the auction house.
    address exclusiveTransmitter;
}

// Transmitter's origin chain execution details for a request with fulfilAmounts.
struct SwapExec {
    // User signed Request
    Request request;
    // amount of output token to be sent to the receiver
    uint256 fulfilAmount;
    // calldata used by transmitter during callback
    bytes callbackPayload;
    // user signature against the request
    bytes userSignature;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {ISignatureTransfer} from "permit2/src/interfaces/ISignatureTransfer.sol";

import {IEntrypoint} from "../interfaces/IEntrypoint.sol";
import {AccessControl} from "../utils/AccessControl.sol";
import {ISwapExecutor} from "../interfaces/ISwapExecutor.sol";
import {ICalldataExecutor} from "../interfaces/ICalldataExecutor.sol";
import {ISwitchboardRouter} from "../interfaces/ISwitchboardRouter.sol";
import {IFeeCollector} from "../interfaces/IFeeCollector.sol";

/**
 * @notice WithdrawnRequest struct
 * @dev This struct is used to store info about withdrawn requests on the origin chain
 */
struct WithdrawnRequest {
    address token;
    uint256 amount;
    address receiver;
}

abstract contract BungeeGatewayStorage is AccessControl {
    /// @dev address used to identify native token
    address public constant NATIVE_TOKEN_ADDRESS = address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    /// @notice address of the permit 2 contract
    ISignatureTransfer public immutable PERMIT2;

    /// @notice address of the Entrypoint
    /// @dev Entrypoint for Bungee, all extraction requests are sent to this contract.
    IEntrypoint public ENTRYPOINT;

    /// @notice address of the SwitchboardRouter
    /// @dev BungeeGateway uses this contract to handle cross-chain messages via Socket
    ISwitchboardRouter public SWITCHBOARD_ROUTER;

    /// @notice address of the SwapExecutor
    /// @dev BungeeGateway delegates swap executions to this contract.
    ISwapExecutor public SWAP_EXECUTOR;

    /// @notice address of the CalldataExecutor
    /// @dev BungeeGateway delegates calldata execution at destination chain to this contract.
    ICalldataExecutor public CALLDATA_EXECUTOR;

    /// @notice address of the FeeCollector
    /// @dev BungeeGateway collects affiliate fees from the users and transfers them to this contract.
    IFeeCollector public FEE_COLLECTOR;

    /// @notice this mapping holds all implementation contract addresses against their implId
    mapping(uint8 implId => address impl) internal _impls;

    /// @notice this mapping tracks whether an implId has been used & removed
    /// @dev used to prevent reusing an implId
    mapping(uint8 implId => bool removed) internal _removedImpls;

    /// @notice this mapping holds all the receiver contracts, these contracts will receive funds on the destination chain.
    /// @dev bridged funds would reach receiver contracts first and then transmitter uses these funds to fulfil order.
    mapping(address router => mapping(uint256 toChainId => address whitelistedReceiver)) internal whitelistedReceivers;

    /// @notice this mapping holds all the addresses that are routers.
    /// @dev bungee sends funds from the users to these routers.
    /// @dev bungee calls these when fulfilment happens on the destination.
    mapping(address routers => bool supported) internal bungeeRouters;

    /// @notice this mapping stores orders that have been withdrawn on the originChain
    /// @dev Requests are deleted from the extractedRequests mapping when withdrawn on the origin chain
    /// @dev Can be used by external contracts to track & use withdrawal info about requests
    mapping(bytes32 requestHash => WithdrawnRequest request) internal _withdrawnRequests;

    /// @notice this mapping stores the settlement amounts collected for the beneficiaries
    /// @dev not all routers would have settlement, so these amounts may not be cleared for some routers
    mapping(address beneficiary => mapping(address router => mapping(address token => uint256 amount)))
        public beneficiarySettlements;

    /**
     * @notice Constructor.
     * @dev Defines all immutable variables & owner
     * @param _owner owner of the contract.
     * @param _permit2 address of the permit 2 contract.
     */
    constructor(address _owner, address _permit2) AccessControl(_owner) {
        PERMIT2 = ISignatureTransfer(_permit2);
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {WETH} from "solady/src/tokens/WETH.sol";
import {IPermit2} from "permit2/src/interfaces/IPermit2.sol";
import {AccessControl} from "../utils/AccessControl.sol";
import {IBungeeGateway} from "../interfaces/IBungeeGateway.sol";
import {RESCUE_ROLE} from "../common/AccessRoles.sol";
import {RescueFundsLib} from "../lib/RescueFundsLib.sol";
import {CurrencyLib} from "../lib/CurrencyLib.sol";

abstract contract BaseInbox is AccessControl {
    /// @dev reverts if the request sender is not set to inbox contract
    error InvalidSender();

    /// @dev reverts if the withdrawal receiver is not set to inbox contract
    error InvalidReceiver();

    /// @dev reverts when chainId does not match block.chainid
    error InvalidChainId();

    /// @dev reverts if the msg.value and Request inputAmount do not match
    error InvalidMsgValue();

    /// @dev reverts if the nonce has already been used
    error InvalidNonce();

    ///@dev reverts if native / ERC-20 transfer fails
    error TransferFailed();

    /// @dev reverts if Request does not exist on the Inbox contract
    error RequestDoesNotExist();

    /// @dev reverts if Request has already been withdrawn by the user post-extraction
    error RequestAlreadyWithdraw();

    /// @dev reverts if Request has already been extracted
    error RequestAlreadyFulfilled();

    /// @dev reverts if Request has not been withdrawn by the user post-extraction
    error RequestNotWithdrawn();

    /*//////////////////////////////////////////////////////////////////////////
                                    STRUCTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Struct used to store received requests against request nonce
    /// @param ogSender sender of the request
    /// @param typedDataHash typedDataHash of the Request's hash
    struct ReceivedRequest {
        address ogSender;
        bytes32 typedDataHash;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTANTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Permit2 contract address
    IPermit2 public immutable PERMIT2;

    /// @notice Wrapped native token address
    WETH public immutable WRAPPED_NATIVE_TOKEN;

    /// @notice bungeeGateway contract address
    IBungeeGateway public immutable BUNGEE_GATEWAY;

    /// @notice Address used to denote native tokens on Bungee Protocol
    address public constant NATIVE_TOKEN_ADDRESS = address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    /// @notice MAGIC_VALUE returned for valid signatures according to EIP-1271
    /// @dev https://eips.ethereum.org/EIPS/eip-1271
    bytes4 internal constant MAGIC_VALUE = 0x1626ba7e;

    /// @notice MAGIC_VALUE returned for valid signatures according to EIP-1271
    /// @dev https://eips.ethereum.org/EIPS/eip-1271
    bytes4 internal constant NON_MAGIC_VALUE = 0xffffffff;

    /*//////////////////////////////////////////////////////////////////////////
                                    PUBLIC STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice stores requests created by users
    mapping(uint256 nonce => ReceivedRequest receivedRequest) public requestInbox;

    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev constructor sets immutable variables and gives infinite WETH/Wrapped Native Token approval to Permit2
    /// @param _owner owner address
    /// @param _permit2 permit2 contract address
    /// @param _bungeeGateway swapRequest BungeeGateway
    /// @param _wrappedNativeToken wrapped native token address
    constructor(
        address _owner,
        address _permit2,
        address _bungeeGateway,
        address payable _wrappedNativeToken
    ) AccessControl(_owner) {
        _grantRole(RESCUE_ROLE, _owner);

        PERMIT2 = IPermit2(_permit2);
        BUNGEE_GATEWAY = IBungeeGateway(_bungeeGateway);
        WRAPPED_NATIVE_TOKEN = WETH(_wrappedNativeToken);

        // Gives max Wrapped-NativeToken approval to Permit2 contract
        WRAPPED_NATIVE_TOKEN.approve(address(PERMIT2), type(uint256).max);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                Signature Verification
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Called by PERMIT2 to verify the validity of witness data signed against the nonce for transfer
    /// @param _hash PERMIT2 typedData hash
    /// @param _signature Encoded Request Details passed from PERMIT2
    function isValidSignature(bytes32 _hash, bytes calldata _signature) external view returns (bytes4 magicValue) {
        // Decodes nonce from signature
        uint256 nonce = abi.decode(_signature, (uint256));

        // Checks if hashTypedData (_hash) from PERMIT2 does not match the order stored against nonce
        if (requestInbox[nonce].typedDataHash == _hash) {
            return MAGIC_VALUE;
        } else {
            return NON_MAGIC_VALUE;
        }
    }

    /// @dev withdraws funds for a request from the contract to the user
    /// @dev unwraps native token if the token is Wrapped Native Token
    /// @param token address of the token
    /// @param amount amount to be withdrawn
    /// @param ogSender address of the original sender
    function _withdraw(address token, uint256 amount, address ogSender) internal {
        if (token == address(WRAPPED_NATIVE_TOKEN)) {
            // unwrap native token
            WRAPPED_NATIVE_TOKEN.withdraw(amount);

            // transfers funds to user
            CurrencyLib.transfer({token: NATIVE_TOKEN_ADDRESS, recipient: ogSender, amount: amount});
        } else {
            CurrencyLib.transfer({token: token, recipient: ogSender, amount: amount});
        }
    }

    /*//////////////////////////////////////////////////////////////////////////
                                ADMIN FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @notice send funds to the provided address if stuck, can be called only by owner.
     * @param token address of the token
     * @param amount amount to be rescued
     * @param to address, funds will be transferred to this address.
     */
    function rescue(address token, address to, uint256 amount) external onlyRole(RESCUE_ROLE) {
        RescueFundsLib.rescueFunds(token, to, amount);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                RECEIVE FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    receive() external payable {}
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {BaseInbox} from "./BaseInbox.sol";
import {SORInbox} from "./SORInbox.sol";
import {SRInbox} from "./SRInbox.sol";

/**
 * @title BungeeInbox
 * @notice An Inbox contract for Bungee Protocol that enables creating requests via traditional approval flow
 * @dev Supports both SingleOutputRequest & SwapRequest
 * @dev Supports both ERC20 & native tokens
 */
contract BungeeInbox is BaseInbox, SORInbox, SRInbox {
    constructor(
        address _owner,
        address _permit2,
        address _bungeeGateway,
        address payable _wrappedNativeToken
    ) BaseInbox(_owner, _permit2, _bungeeGateway, _wrappedNativeToken) {}
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {ERC20} from "solady/src/tokens/ERC20.sol";
import {SafeTransferLib} from "solady/src/utils/SafeTransferLib.sol";
import {Permit2HashHelper} from "../lib/Permit2HashHelper.sol";
import {CurrencyLib} from "../lib/CurrencyLib.sol";
import {Permit2Lib} from "../lib/Permit2Lib.sol";
import {RequestLib as SingleOutputRequestLib} from "../lib/SingleOutputRequestLib.sol";
import {BasicRequest, Request as SingleOutputRequest} from "../common/SingleOutputStructs.sol";
import {WithdrawnRequest} from "../interfaces/IBungeeGateway.sol";
import {BaseInbox} from "./BaseInbox.sol";
import {AffiliateFeesLib} from "../lib/AffiliateFeesLib.sol";

/// @title SORInbox
/// @notice Enables users to send SingleOutputRequests to Bungee Protocol auction
/// @dev To send Requests to Bungee Protocol, users are required to sign on a Request (EIP-712)
/// @dev Then submit Request + signed message to Bungee Protocol's off-chain auction service
/// @dev To enable creating orders on-chain, users can use Inboxes where request details are stored
/// @dev Request creation event is emitted which is picked up by Bungee Protocol's auction house
/// @dev Bungee Protocol uses PERMIT-2, which uses EIP-1271 to validate stored requests on the Inbox
/// @author tech@socket.tech
abstract contract SORInbox is BaseInbox {
    /// @notice Emitted when the user creates a Request on the SORInbox
    /// @param requestHash Hash of the request
    /// @param ogSender Address of the user who created the request
    /// @param request Encoded Request details
    event SingleOutputRequestCreated(bytes32 indexed requestHash, address ogSender, bytes request);

    /// @notice Emitted when the user withdraws a Request
    /// @param requestHash Hash of the request
    event SingleOutputRequestWithdrawn(bytes32 indexed requestHash);

    /*//////////////////////////////////////////////////////////////////////////
                                    LIBS
    //////////////////////////////////////////////////////////////////////////*/

    using SingleOutputRequestLib for SingleOutputRequest;

    /*//////////////////////////////////////////////////////////////////////////
                                    STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice stores requests withdrawn by users post-extraction
    mapping(bytes32 typedDataHash => bool withdrawn) public withdrawnInbox;

    /*//////////////////////////////////////////////////////////////////////////
                                EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice called by the user to create a SingleOutputRequest deposit request
    /// @dev Creates SingleOutputRequest, Wraps native token, escrows input token, stores typedDataHash
    /// @dev emits Request creation event
    /// @param singleOutputRequest singleOutputRequest struct
    function createRequest(SingleOutputRequest calldata singleOutputRequest) external payable {
        // Validates Request and reverts if there are invalid details in the Request
        _checkRequestValidity(singleOutputRequest.basicReq);

        // Creates RequestHash and TypedDataHash for the Request
        (bytes32 requestHash, bytes32 typedDataHash) = _createTypedDataHash(singleOutputRequest);

        // Store the hash against the nonce
        requestInbox[singleOutputRequest.basicReq.nonce] = ReceivedRequest({
            ogSender: msg.sender,
            typedDataHash: typedDataHash
        });

        if (singleOutputRequest.basicReq.inputToken == address(WRAPPED_NATIVE_TOKEN)) {
            // reverts if inputAmount does not match msg.value
            if (msg.value != singleOutputRequest.basicReq.inputAmount) revert InvalidMsgValue();

            // Wraps native asset to WETH
            WRAPPED_NATIVE_TOKEN.deposit{value: msg.value}();
        } else {
            // Transfer input token from user to contract
            CurrencyLib.transferFrom({
                from: msg.sender,
                token: singleOutputRequest.basicReq.inputToken,
                recipient: address(this),
                amount: singleOutputRequest.basicReq.inputAmount
            });

            // Approve if allowance is not enough
            if (
                singleOutputRequest.basicReq.inputAmount >
                ERC20(singleOutputRequest.basicReq.inputToken).allowance(address(this), address(PERMIT2))
            ) {
                SafeTransferLib.safeApprove(
                    singleOutputRequest.basicReq.inputToken,
                    address(PERMIT2),
                    type(uint256).max
                );
            }
        }

        // Emit event
        emit SingleOutputRequestCreated(requestHash, msg.sender, abi.encode(singleOutputRequest));
    }

    /// @notice called by the user to unlock/withdraw funds if Request is not fulfilled
    /// @dev supports both pre-extraction and post-extraction withdrawals
    /// @dev if post-extraction, user has to first withdraw funds from BungeeGateway
    /// @param singleOutputRequest singleOutputRequest struct
    function withdrawFunds(SingleOutputRequest calldata singleOutputRequest) external {
        // creates requestHash and typedDataHash for the Request
        (bytes32 requestHash, bytes32 typedDataHash) = _createTypedDataHash(singleOutputRequest);

        // checks if the request was created on Inbox
        if (requestInbox[singleOutputRequest.basicReq.nonce].typedDataHash != typedDataHash)
            revert RequestDoesNotExist();

        address ogSender = requestInbox[singleOutputRequest.basicReq.nonce].ogSender;

        // if nonce is valid, request hasn't been extracted and funds are unlocked to the user from Inbox
        // if invalid, request has been extracted and funds are withdrawn from BungeeGateway and sent to user
        if (Permit2Lib.isNonceValid(PERMIT2, singleOutputRequest.basicReq.nonce)) {
            // deletes request from storage
            delete requestInbox[singleOutputRequest.basicReq.nonce];

            // Stores Withdrawn Requests
            withdrawnInbox[typedDataHash] = true;

            // CASE - PRE EXTRACTION
            _withdraw(singleOutputRequest.basicReq.inputToken, singleOutputRequest.basicReq.inputAmount, ogSender);
        } else {
            // CASE - POST EXTRACTION
            // checks if the request has already been withdrawn
            if (withdrawnInbox[typedDataHash]) revert RequestAlreadyWithdraw();

            /// @dev post-extraction, request has to be first withdrawn from BungeeGateway
            WithdrawnRequest memory withdrawnRequest = BUNGEE_GATEWAY.withdrawnRequests(requestHash);
            // If Request has not been withdrawn, revert
            if (withdrawnRequest.token == address(0)) revert RequestNotWithdrawn();
            // If withdrawal receiver is not set to inbox contract, revert
            if (withdrawnRequest.receiver != address(this)) revert InvalidReceiver();

            // Calculate total amount including fee
            // Since fee is always collected in the escrowed token (either inputToken or swapOutputToken),
            // we can easily calculate the total amount including fee by passing in the bridged amount tracked on BungeeGateway
            /// @dev fee would've been refunded back to Inbox
            uint256 totalAmount = AffiliateFeesLib.calculateTotalAmount(
                withdrawnRequest.amount,
                singleOutputRequest.affiliateFees
            );

            // Stores Withdrawn Requests
            withdrawnInbox[typedDataHash] = true;

            _withdraw(withdrawnRequest.token, totalAmount, ogSender);
        }

        // emits event
        emit SingleOutputRequestWithdrawn(requestHash);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev validates request details and reverts if any of the conditions are not met
    /// @param basicRequest BasicRequest struct details
    function _checkRequestValidity(BasicRequest calldata basicRequest) internal view {
        // reverts if originChainId is not the current chainId
        if (basicRequest.originChainId != block.chainid) revert InvalidChainId();

        // reverts if the nonce has already been used
        if (requestInbox[basicRequest.nonce].typedDataHash != bytes32(0)) revert InvalidNonce();

        // reverts if the sender is not set to inbox contract
        if (basicRequest.sender != address(this)) revert InvalidSender();
    }

    /// @dev creates typedDataHash which is the hash the user signs on for permit2
    /// @param singleOutputRequest singleOutputRequest struct
    function _createTypedDataHash(
        SingleOutputRequest calldata singleOutputRequest
    ) internal view returns (bytes32 requestHash, bytes32 typedDataHash) {
        // Creates Request Hash
        requestHash = singleOutputRequest.hashOriginRequest();

        // Hash with witness
        bytes32 hashWithWitness = Permit2HashHelper.returnHashWithWitness(
            singleOutputRequest.basicReq.inputToken,
            singleOutputRequest.basicReq.inputAmount,
            singleOutputRequest.basicReq.nonce,
            singleOutputRequest.basicReq.deadline,
            requestHash,
            SingleOutputRequestLib.PERMIT2_ORDER_TYPE,
            singleOutputRequest.basicReq.bungeeGateway
        );

        // Typed Data Hash
        typedDataHash = Permit2HashHelper._hashTypedData(address(PERMIT2), hashWithWitness);
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {ERC20} from "solady/src/tokens/ERC20.sol";
import {SafeTransferLib} from "solady/src/utils/SafeTransferLib.sol";
import {Permit2HashHelper} from "../lib/Permit2HashHelper.sol";
import {RequestLib as SwapRequestLib} from "../lib/SwapRequestLib.sol";
import {CurrencyLib} from "../lib/CurrencyLib.sol";
import {Permit2Lib} from "../lib/Permit2Lib.sol";
import {BasicRequest, Request as SwapRequest} from "../common/SwapRequestStructs.sol";
import {BaseInbox} from "./BaseInbox.sol";

/// @title SRInbox
/// @notice Enables users to send same chain SwapRequest to Bungee Protocol auction
/// @dev To send Requests to Bungee Protocol, users are required to sign on a Request (EIP-712)
/// @dev Then submit Request + signed message to Bungee Protocol's off-chain auction service
/// @dev To enable creating orders on-chain, users can use Inboxes where request details are stored
/// @dev Request creation event is emitted which is picked up by BP's auction
/// @dev Bungee Protocol uses PERMIT-2, which uses EIP-1271 to validate stored requests on the Inbox
/// @author tech@socket.tech
abstract contract SRInbox is BaseInbox {
    /// @notice Emitted when the user creates a Swap Request on the SRInbox
    /// @param requestHash Hash of the request
    /// @param ogSender Address of the user who created the request
    /// @param request Encoded Request details
    event SwapRequestCreated(bytes32 indexed requestHash, address ogSender, bytes request);

    /// @notice Emitted when the user withdraws a Swap Request
    /// @param requestHash Hash of the request
    event SwapRequestWithdrawn(bytes32 indexed requestHash);

    /*//////////////////////////////////////////////////////////////////////////
                                    LIBS
    //////////////////////////////////////////////////////////////////////////*/

    using SwapRequestLib for SwapRequest;

    /*//////////////////////////////////////////////////////////////////////////
                                EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice called by the user to create a SwapRequest from native token
    /// @dev Creates SwapRequest, Wraps native token, stores typedDataHash, emits Request creation event
    /// @param swapRequest swapRequest struct
    function createRequest(SwapRequest calldata swapRequest) external payable {
        // Validates Request and reverts if there are invalid details in the Request
        _checkRequestValidity(swapRequest.basicReq);

        // Creates RequestHash and TypedDataHash for the Request
        (bytes32 requestHash, bytes32 typedDataHash) = _createTypedDataHash(swapRequest);

        // Store the hash against the nonce
        requestInbox[swapRequest.basicReq.nonce] = ReceivedRequest({
            ogSender: msg.sender,
            typedDataHash: typedDataHash
        });

        if (swapRequest.basicReq.inputToken == address(WRAPPED_NATIVE_TOKEN)) {
            // reverts if inputAmount does not match msg.value
            if (msg.value != swapRequest.basicReq.inputAmount) revert InvalidMsgValue();

            // Wraps native asset to WETH
            WRAPPED_NATIVE_TOKEN.deposit{value: msg.value}();
        } else {
            // Transfer input token from user to contract
            CurrencyLib.transferFrom({
                from: msg.sender,
                token: swapRequest.basicReq.inputToken,
                recipient: address(this),
                amount: swapRequest.basicReq.inputAmount
            });

            // Approve if allowance is not enough
            if (
                swapRequest.basicReq.inputAmount >
                ERC20(swapRequest.basicReq.inputToken).allowance(address(this), address(PERMIT2))
            ) {
                SafeTransferLib.safeApprove(swapRequest.basicReq.inputToken, address(PERMIT2), type(uint256).max);
            }
        }

        // Emit event
        emit SwapRequestCreated(requestHash, msg.sender, abi.encode(swapRequest));
    }

    /// @notice called by the user to unlock/withdraw funds if Request is not fulfilled
    /// @param swapRequest swapRequest struct
    function withdrawFunds(SwapRequest calldata swapRequest) external {
        // creates requestHash and typedDataHash for the Request
        (bytes32 requestHash, bytes32 typedDataHash) = _createTypedDataHash(swapRequest);

        // checks if the request was created on Inbox
        if (requestInbox[swapRequest.basicReq.nonce].typedDataHash != typedDataHash) revert RequestDoesNotExist();

        address ogSender = requestInbox[swapRequest.basicReq.nonce].ogSender;

        // if nonce is valid, request hasn't been extracted and funds are unlocked to the user from Inbox
        // if invalid, request has been extracted and funds are already used and swapped
        if (Permit2Lib.isNonceValid(PERMIT2, swapRequest.basicReq.nonce)) {
            // deletes request from storage
            delete requestInbox[swapRequest.basicReq.nonce];

            // CASE - PRE EXTRACTION
            _withdraw(swapRequest.basicReq.inputToken, swapRequest.basicReq.inputAmount, ogSender);
        } else {
            /// @dev there is no post-extraction case in SwapRequests since extraction and swapping are done in one step
            revert RequestAlreadyFulfilled();
        }

        // emits event
        emit SwapRequestWithdrawn(requestHash);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev validates request details and reverts if any of the conditions are not met
    /// @param basicRequest BasicRequest struct details
    function _checkRequestValidity(BasicRequest calldata basicRequest) internal view {
        // reverts if chainId is not the current chainId
        if (basicRequest.chainId != block.chainid) revert InvalidChainId();

        // reverts if the nonce has already been used
        if (requestInbox[basicRequest.nonce].typedDataHash != bytes32(0)) revert InvalidNonce();

        // reverts if the sender is not set to inbox contract
        if (basicRequest.sender != address(this)) revert InvalidSender();
    }

    /// @dev creates typedDataHash which is the hash the user signs on for permit2
    /// @param swapRequest swapRequest struct
    function _createTypedDataHash(
        SwapRequest calldata swapRequest
    ) internal view returns (bytes32 requestHash, bytes32 typedDataHash) {
        // Creates Request Hash
        requestHash = swapRequest.hashRequest();

        // Hash with witness
        bytes32 hashWithWitness = Permit2HashHelper.returnHashWithWitness(
            swapRequest.basicReq.inputToken,
            swapRequest.basicReq.inputAmount,
            swapRequest.basicReq.nonce,
            swapRequest.basicReq.deadline,
            requestHash,
            SwapRequestLib.PERMIT2_ORDER_TYPE,
            swapRequest.basicReq.bungeeGateway
        );

        // Typed Data Hash
        typedDataHash = Permit2HashHelper._hashTypedData(address(PERMIT2), hashWithWitness);
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {WithdrawnRequest} from "../core/BungeeGatewayStorage.sol";

interface IBungeeGateway {
    function setWhitelistedReceiver(address receiver, uint256 destinationChainId, address router) external;

    function getWhitelistedReceiver(address router, uint256 destinationChainId) external view returns (address);

    function inboundMsgFromSwitchboard(uint8 msgId, uint32 switchboardId, bytes calldata payload) external;

    function isBungeeRouter(address router) external view returns (bool);

    function withdrawnRequests(bytes32 requestHash) external view returns (WithdrawnRequest memory);

    function executeImpl(uint8 implId, bytes calldata data) external payable returns (bytes memory);
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

interface ICalldataExecutor {
    function executeCalldata(address to, bytes memory encodedData, uint256 msgGasLimit) external returns (bool);
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

interface IEntrypoint {
    function executeSOR(bytes calldata data, bytes calldata mofaSignature) external payable returns (bytes memory);
    function executeSR(bytes calldata data, bytes calldata mofaSignature) external payable returns (bytes memory);
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

interface IFeeCollector {
    function registerFee(address feeTaker, uint256 feeAmount, address feeToken) external;
    function registerLockedFee(address feeTaker, uint256 feeAmount, address feeToken, bytes32 requestHash) external;
    function settleFee(bytes32 requestHash) external;
    function refundFee(bytes32 requestHash, address to) external;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

interface ISwapExecutor {
    function executeSwap(address token, uint256 amount, address swapRouter, bytes memory swapPayload) external payable;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

interface ISwitchboardRouter {
    function sendOutboundMsg(
        uint32 originChainId,
        uint32 switchboardId,
        uint8 msgId,
        uint256 destGasLimit,
        bytes calldata payload
    ) external payable;

    function receiveAndDeliverMsg(uint32 switchboardId, uint32 siblingChainId, bytes calldata payload) external;
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.19;

import {BytesLib} from "./BytesLib.sol";

/// @notice helpers for AffiliateFees struct
library AffiliateFeesLib {
    /// @notice SafeTransferLib - library for safe and optimized operations on ERC20 tokens

    /// @notice error when affiliate fee length is wrong
    error WrongAffiliateFeeLength();

    /// @notice event emitted when affiliate fee is deducted
    event AffiliateFeeDeducted(address feeToken, address feeTakerAddress, uint256 feeAmount);

    // Precision used for affiliate fee calculation
    uint256 internal constant PRECISION = 10000000000000000;

    /**
     * @dev calculates & transfers fee to feeTakerAddress
     * @param bridgingAmount amount to be bridged
     * @param affiliateFees packed bytes containing feeTakerAddress and feeInBps
     *                      ensure the affiliateFees is packed as follows:
     *                      address feeTakerAddress (20 bytes) + uint56 feeInBps (7 bytes) = 27 bytes
     * @return bridgingAmount after deducting affiliate fees
     */
    function getAffiliateFees(
        uint256 bridgingAmount,
        bytes memory affiliateFees
    ) internal pure returns (uint256, uint256, address) {
        address feeTakerAddress;
        uint256 feeAmount = 0;
        if (affiliateFees.length > 0) {
            uint56 feeInBps;

            if (affiliateFees.length != 27) revert WrongAffiliateFeeLength();

            feeInBps = BytesLib.toUint56(affiliateFees, 20);
            feeTakerAddress = BytesLib.toAddress(affiliateFees, 0);

            if (feeInBps > 0) {
                // calculate fee
                feeAmount = ((bridgingAmount * feeInBps) / PRECISION);
                bridgingAmount -= feeAmount;
            }
        }

        return (bridgingAmount, feeAmount, feeTakerAddress);
    }

    /// @notice calculates the total amount from the bridged amount and the affiliate fees
    function calculateTotalAmount(uint256 bridgedAmount, bytes memory affiliateFees) internal pure returns (uint256) {
        if (affiliateFees.length > 0) {
            if (affiliateFees.length != 27) revert WrongAffiliateFeeLength();
            uint56 feeInBps = BytesLib.toUint56(affiliateFees, 20);

            // totalAmount = bridgedAmount / (1 - feeInBps / PRECISION)
            uint256 totalAmount = (bridgedAmount * PRECISION) / (PRECISION - feeInBps);
            return totalAmount;
        }
        return bridgedAmount;
    }
}
// SPDX-License-Identifier: Unlicense
/*
 * @title Solidity Bytes Arrays Utils
 * @author Gonçalo Sá <goncalo.sa@consensys.net>
 *
 * @dev Bytes tightly packed arrays utility library for ethereum contracts written in Solidity.
 *      The library lets you concatenate, slice and type cast bytes arrays both in memory and storage.
 */
pragma solidity ^0.8.19;

library BytesLib {
    function concat(bytes memory _preBytes, bytes memory _postBytes) internal pure returns (bytes memory) {
        bytes memory tempBytes;

        assembly {
            // Get a location of some free memory and store it in tempBytes as
            // Solidity does for memory variables.
            tempBytes := mload(0x40)

            // Store the length of the first bytes array at the beginning of
            // the memory for tempBytes.
            let length := mload(_preBytes)
            mstore(tempBytes, length)

            // Maintain a memory counter for the current write location in the
            // temp bytes array by adding the 32 bytes for the array length to
            // the starting location.
            let mc := add(tempBytes, 0x20)
            // Stop copying when the memory counter reaches the length of the
            // first bytes array.
            let end := add(mc, length)

            for {
                // Initialize a copy counter to the start of the _preBytes data,
                // 32 bytes into its memory.
                let cc := add(_preBytes, 0x20)
            } lt(mc, end) {
                // Increase both counters by 32 bytes each iteration.
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                // Write the _preBytes data into the tempBytes memory 32 bytes
                // at a time.
                mstore(mc, mload(cc))
            }

            // Add the length of _postBytes to the current length of tempBytes
            // and store it as the new length in the first 32 bytes of the
            // tempBytes memory.
            length := mload(_postBytes)
            mstore(tempBytes, add(length, mload(tempBytes)))

            // Move the memory counter back from a multiple of 0x20 to the
            // actual end of the _preBytes data.
            mc := end
            // Stop copying when the memory counter reaches the new combined
            // length of the arrays.
            end := add(mc, length)

            for {
                let cc := add(_postBytes, 0x20)
            } lt(mc, end) {
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                mstore(mc, mload(cc))
            }

            // Update the free-memory pointer by padding our last write location
            // to 32 bytes: add 31 bytes to the end of tempBytes to move to the
            // next 32 byte block, then round down to the nearest multiple of
            // 32. If the sum of the length of the two arrays is zero then add
            // one before rounding down to leave a blank 32 bytes (the length block with 0).
            mstore(
                0x40,
                and(
                    add(add(end, iszero(add(length, mload(_preBytes)))), 31),
                    not(31) // Round down to the nearest 32 bytes.
                )
            )
        }

        return tempBytes;
    }

    function concatStorage(bytes storage _preBytes, bytes memory _postBytes) internal {
        assembly {
            // Read the first 32 bytes of _preBytes storage, which is the length
            // of the array. (We don't need to use the offset into the slot
            // because arrays use the entire slot.)
            let fslot := sload(_preBytes.slot)
            // Arrays of 31 bytes or less have an even value in their slot,
            // while longer arrays have an odd value. The actual length is
            // the slot divided by two for odd values, and the lowest order
            // byte divided by two for even values.
            // If the slot is even, bitwise and the slot with 255 and divide by
            // two to get the length. If the slot is odd, bitwise and the slot
            // with -1 and divide by two.
            let slength := div(and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)), 2)
            let mlength := mload(_postBytes)
            let newlength := add(slength, mlength)
            // slength can contain both the length and contents of the array
            // if length < 32 bytes so let's prepare for that
            // v. http://solidity.readthedocs.io/en/latest/miscellaneous.html#layout-of-state-variables-in-storage
            switch add(lt(slength, 32), lt(newlength, 32))
            case 2 {
                // Since the new array still fits in the slot, we just need to
                // update the contents of the slot.
                // uint256(bytes_storage) = uint256(bytes_storage) + uint256(bytes_memory) + new_length
                sstore(
                    _preBytes.slot,
                    // all the modifications to the slot are inside this
                    // next block
                    add(
                        // we can just add to the slot contents because the
                        // bytes we want to change are the LSBs
                        fslot,
                        add(
                            mul(
                                div(
                                    // load the bytes from memory
                                    mload(add(_postBytes, 0x20)),
                                    // zero all bytes to the right
                                    exp(0x100, sub(32, mlength))
                                ),
                                // and now shift left the number of bytes to
                                // leave space for the length in the slot
                                exp(0x100, sub(32, newlength))
                            ),
                            // increase length by the double of the memory
                            // bytes length
                            mul(mlength, 2)
                        )
                    )
                )
            }
            case 1 {
                // The stored value fits in the slot, but the combined value
                // will exceed it.
                // get the keccak hash to get the contents of the array
                mstore(0x0, _preBytes.slot)
                let sc := add(keccak256(0x0, 0x20), div(slength, 32))

                // save new length
                sstore(_preBytes.slot, add(mul(newlength, 2), 1))

                // The contents of the _postBytes array start 32 bytes into
                // the structure. Our first read should obtain the `submod`
                // bytes that can fit into the unused space in the last word
                // of the stored array. To get this, we read 32 bytes starting
                // from `submod`, so the data we read overlaps with the array
                // contents by `submod` bytes. Masking the lowest-order
                // `submod` bytes allows us to add that value directly to the
                // stored value.

                let submod := sub(32, slength)
                let mc := add(_postBytes, submod)
                let end := add(_postBytes, mlength)
                let mask := sub(exp(0x100, submod), 1)

                sstore(
                    sc,
                    add(
                        and(fslot, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00),
                        and(mload(mc), mask)
                    )
                )

                for {
                    mc := add(mc, 0x20)
                    sc := add(sc, 1)
                } lt(mc, end) {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } {
                    sstore(sc, mload(mc))
                }

                mask := exp(0x100, sub(mc, end))

                sstore(sc, mul(div(mload(mc), mask), mask))
            }
            default {
                // get the keccak hash to get the contents of the array
                mstore(0x0, _preBytes.slot)
                // Start copying to the last used word of the stored array.
                let sc := add(keccak256(0x0, 0x20), div(slength, 32))

                // save new length
                sstore(_preBytes.slot, add(mul(newlength, 2), 1))

                // Copy over the first `submod` bytes of the new data as in
                // case 1 above.
                let slengthmod := mod(slength, 32)
                let mlengthmod := mod(mlength, 32)
                let submod := sub(32, slengthmod)
                let mc := add(_postBytes, submod)
                let end := add(_postBytes, mlength)
                let mask := sub(exp(0x100, submod), 1)

                sstore(sc, add(sload(sc), and(mload(mc), mask)))

                for {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } lt(mc, end) {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } {
                    sstore(sc, mload(mc))
                }

                mask := exp(0x100, sub(mc, end))

                sstore(sc, mul(div(mload(mc), mask), mask))
            }
        }
    }

    function slice(bytes memory _bytes, uint256 _start, uint256 _length) internal pure returns (bytes memory) {
        require(_length + 31 >= _length, "slice_overflow");
        require(_bytes.length >= _start + _length, "slice_outOfBounds");

        bytes memory tempBytes;

        assembly {
            switch iszero(_length)
            case 0 {
                // Get a location of some free memory and store it in tempBytes as
                // Solidity does for memory variables.
                tempBytes := mload(0x40)

                // The first word of the slice result is potentially a partial
                // word read from the original array. To read it, we calculate
                // the length of that partial word and start copying that many
                // bytes into the array. The first word we copy will start with
                // data we don't care about, but the last `lengthmod` bytes will
                // land at the beginning of the contents of the new array. When
                // we're done copying, we overwrite the full first word with
                // the actual length of the slice.
                let lengthmod := and(_length, 31)

                // The multiplication in the next line is necessary
                // because when slicing multiples of 32 bytes (lengthmod == 0)
                // the following copy loop was copying the origin's length
                // and then ending prematurely not copying everything it should.
                let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                let end := add(mc, _length)

                for {
                    // The multiplication in the next line has the same exact purpose
                    // as the one above.
                    let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    mstore(mc, mload(cc))
                }

                mstore(tempBytes, _length)

                //update free-memory pointer
                //allocating the array padded to 32 bytes like the compiler does now
                mstore(0x40, and(add(mc, 31), not(31)))
            }
            //if we want a zero-length slice let's just return a zero-length array
            default {
                tempBytes := mload(0x40)
                //zero out the 32 bytes slice we are about to return
                //we need to do it because Solidity does not garbage collect
                mstore(tempBytes, 0)

                mstore(0x40, add(tempBytes, 0x20))
            }
        }

        return tempBytes;
    }

    function toAddress(bytes memory _bytes, uint256 _start) internal pure returns (address) {
        require(_bytes.length >= _start + 20, "toAddress_outOfBounds");
        address tempAddress;

        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
        }

        return tempAddress;
    }

    function toUint8(bytes memory _bytes, uint256 _start) internal pure returns (uint8) {
        require(_bytes.length >= _start + 1, "toUint8_outOfBounds");
        uint8 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x1), _start))
        }

        return tempUint;
    }

    function toUint16(bytes memory _bytes, uint256 _start) internal pure returns (uint16) {
        require(_bytes.length >= _start + 2, "toUint16_outOfBounds");
        uint16 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x2), _start))
        }

        return tempUint;
    }

    function toUint32(bytes memory _bytes, uint256 _start) internal pure returns (uint32) {
        require(_bytes.length >= _start + 4, "toUint32_outOfBounds");
        uint32 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x4), _start))
        }

        return tempUint;
    }

    // @audit this function was not originally present in the library
    // we added it to support the uint56 type used in AffiliateFeesLib
    function toUint56(bytes memory _bytes, uint256 _start) internal pure returns (uint56) {
        require(_bytes.length >= _start + 7, "toUint56_outOfBounds");
        uint56 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x7), _start))
        }

        return tempUint;
    }

    function toUint64(bytes memory _bytes, uint256 _start) internal pure returns (uint64) {
        require(_bytes.length >= _start + 8, "toUint64_outOfBounds");
        uint64 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x8), _start))
        }

        return tempUint;
    }

    function toUint96(bytes memory _bytes, uint256 _start) internal pure returns (uint96) {
        require(_bytes.length >= _start + 12, "toUint96_outOfBounds");
        uint96 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0xc), _start))
        }

        return tempUint;
    }

    function toUint128(bytes memory _bytes, uint256 _start) internal pure returns (uint128) {
        require(_bytes.length >= _start + 16, "toUint128_outOfBounds");
        uint128 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x10), _start))
        }

        return tempUint;
    }

    function toUint256(bytes memory _bytes, uint256 _start) internal pure returns (uint256) {
        require(_bytes.length >= _start + 32, "toUint256_outOfBounds");
        uint256 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x20), _start))
        }

        return tempUint;
    }

    function toBytes32(bytes memory _bytes, uint256 _start) internal pure returns (bytes32) {
        require(_bytes.length >= _start + 32, "toBytes32_outOfBounds");
        bytes32 tempBytes32;

        assembly {
            tempBytes32 := mload(add(add(_bytes, 0x20), _start))
        }

        return tempBytes32;
    }

    function equal(bytes memory _preBytes, bytes memory _postBytes) internal pure returns (bool) {
        bool success = true;

        assembly {
            let length := mload(_preBytes)

            // if lengths don't match the arrays are not equal
            switch eq(length, mload(_postBytes))
            case 1 {
                // cb is a circuit breaker in the for loop since there's
                //  no said feature for inline assembly loops
                // cb = 1 - don't breaker
                // cb = 0 - break
                let cb := 1

                let mc := add(_preBytes, 0x20)
                let end := add(mc, length)

                for {
                    let cc := add(_postBytes, 0x20)
                    // the next line is the loop condition:
                    // while(uint256(mc < end) + cb == 2)
                } eq(add(lt(mc, end), cb), 2) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    // if any of these checks fails then arrays are not equal
                    if iszero(eq(mload(mc), mload(cc))) {
                        // unsuccess:
                        success := 0
                        cb := 0
                    }
                }
            }
            default {
                // unsuccess:
                success := 0
            }
        }

        return success;
    }

    function equal_nonAligned(bytes memory _preBytes, bytes memory _postBytes) internal pure returns (bool) {
        bool success = true;

        assembly {
            let length := mload(_preBytes)

            // if lengths don't match the arrays are not equal
            switch eq(length, mload(_postBytes))
            case 1 {
                // cb is a circuit breaker in the for loop since there's
                //  no said feature for inline assembly loops
                // cb = 1 - don't breaker
                // cb = 0 - break
                let cb := 1

                let endMinusWord := add(_preBytes, length)
                let mc := add(_preBytes, 0x20)
                let cc := add(_postBytes, 0x20)

                for {
                    // the next line is the loop condition:
                    // while(uint256(mc < endWord) + cb == 2)
                } eq(add(lt(mc, endMinusWord), cb), 2) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    // if any of these checks fails then arrays are not equal
                    if iszero(eq(mload(mc), mload(cc))) {
                        // unsuccess:
                        success := 0
                        cb := 0
                    }
                }

                // Only if still successful
                // For <1 word tail bytes
                if gt(success, 0) {
                    // Get the remainder of length/32
                    // length % 32 = AND(length, 32 - 1)
                    let numTailBytes := and(length, 0x1f)
                    let mcRem := mload(mc)
                    let ccRem := mload(cc)
                    for {
                        let i := 0
                        // the next line is the loop condition:
                        // while(uint256(i < numTailBytes) + cb == 2)
                    } eq(add(lt(i, numTailBytes), cb), 2) {
                        i := add(i, 1)
                    } {
                        if iszero(eq(byte(i, mcRem), byte(i, ccRem))) {
                            // unsuccess:
                            success := 0
                            cb := 0
                        }
                    }
                }
            }
            default {
                // unsuccess:
                success := 0
            }
        }

        return success;
    }

    function equalStorage(bytes storage _preBytes, bytes memory _postBytes) internal view returns (bool) {
        bool success = true;

        assembly {
            // we know _preBytes_offset is 0
            let fslot := sload(_preBytes.slot)
            // Decode the length of the stored array like in concatStorage().
            let slength := div(and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)), 2)
            let mlength := mload(_postBytes)

            // if lengths don't match the arrays are not equal
            switch eq(slength, mlength)
            case 1 {
                // slength can contain both the length and contents of the array
                // if length < 32 bytes so let's prepare for that
                // v. http://solidity.readthedocs.io/en/latest/miscellaneous.html#layout-of-state-variables-in-storage
                if iszero(iszero(slength)) {
                    switch lt(slength, 32)
                    case 1 {
                        // blank the last byte which is the length
                        fslot := mul(div(fslot, 0x100), 0x100)

                        if iszero(eq(fslot, mload(add(_postBytes, 0x20)))) {
                            // unsuccess:
                            success := 0
                        }
                    }
                    default {
                        // cb is a circuit breaker in the for loop since there's
                        //  no said feature for inline assembly loops
                        // cb = 1 - don't breaker
                        // cb = 0 - break
                        let cb := 1

                        // get the keccak hash to get the contents of the array
                        mstore(0x0, _preBytes.slot)
                        let sc := keccak256(0x0, 0x20)

                        let mc := add(_postBytes, 0x20)
                        let end := add(mc, mlength)

                        // the next line is the loop condition:
                        // while(uint256(mc < end) + cb == 2)
                        for {

                        } eq(add(lt(mc, end), cb), 2) {
                            sc := add(sc, 1)
                            mc := add(mc, 0x20)
                        } {
                            if iszero(eq(sload(sc), mload(mc))) {
                                // unsuccess:
                                success := 0
                                cb := 0
                            }
                        }
                    }
                }
            }
            default {
                // unsuccess:
                success := 0
            }
        }

        return success;
    }
}
// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.19;

// @audit need to check if Solady usage is correct across the codebase
import {ERC20} from "solady/src/tokens/ERC20.sol";
import {SafeTransferLib} from "solady/src/utils/SafeTransferLib.sol";

error TransferFailed();

library CurrencyLib {
    /// @dev address used to identify native token
    address public constant NATIVE_TOKEN_ADDRESS = address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    function balanceOf(address token, address addr) internal view returns (uint256 balance) {
        if (token == NATIVE_TOKEN_ADDRESS) {
            balance = addr.balance;
        } else {
            balance = ERC20(token).balanceOf(addr);
        }
    }

    function transferFrom(address from, address token, address recipient, uint256 amount) internal {
        if (token == NATIVE_TOKEN_ADDRESS) {
            _transferNative(recipient, amount);
        } else {
            SafeTransferLib.safeTransferFrom(token, from, recipient, amount);
        }
    }

    function transfer(address token, address recipient, uint256 amount) internal {
        if (token == NATIVE_TOKEN_ADDRESS) {
            _transferNative(recipient, amount);
        } else {
            SafeTransferLib.safeTransfer(token, recipient, amount);
        }
    }

    function _transferNative(address recipient, uint256 amount) internal {
        // @audit Does setting gas to 5000 for native token transfer here potentially cause issues in case of smart contracts?
        (bool success, ) = recipient.call{value: amount, gas: 5000}("");
        if (!success) revert TransferFailed();
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {IPermit2} from "permit2/src/interfaces/IPermit2.sol";
import {ISignatureTransfer} from "permit2/src/interfaces/ISignatureTransfer.sol";

/// @title Permit2HashHelper
/// @notice Helper library to generate the WitnessHash used by Permit2
/// @dev We receive hashTypedData from Permit2 in isValidSignature function, used to verify the Commande details.
/// @dev This lib helps generate the witness hash which is used to create the hashTypedData
/// @dev reference : https://github.com/Uniswap/permit2/blob/cc56ad0f3439c502c246fc5cfcc3db92bb8b7219/src/libraries/PermitHash.sol#L85
/// @dev reference : https://github.com/Uniswap/permit2/blob/cc56ad0f3439c502c246fc5cfcc3db92bb8b7219/src/EIP712.sol#L38
library Permit2HashHelper {
    string public constant _PERMIT_TRANSFER_FROM_WITNESS_TYPEHASH_STUB =
        "PermitWitnessTransferFrom(TokenPermissions permitted,address spender,uint256 nonce,uint256 deadline,";

    bytes32 public constant _TOKEN_PERMISSIONS_TYPEHASH = keccak256("TokenPermissions(address token,uint256 amount)");

    function returnHashWithWitness(
        address token,
        uint256 amount,
        uint256 nonce,
        uint256 deadline,
        bytes32 commandHash,
        string memory witnessTypeString,
        address bungeeGateway
    ) internal pure returns (bytes32) {
        ISignatureTransfer.TokenPermissions memory tokenPermissions = ISignatureTransfer.TokenPermissions(
            token,
            amount
        );
        ISignatureTransfer.PermitTransferFrom memory permit = ISignatureTransfer.PermitTransferFrom(
            tokenPermissions,
            nonce,
            deadline
        );
        return hashWithWitness(permit, commandHash, witnessTypeString, bungeeGateway);
    }

    function hashWithWitness(
        ISignatureTransfer.PermitTransferFrom memory permit,
        bytes32 witness,
        string memory witnessTypeString,
        address bungeeGateway
    ) internal pure returns (bytes32) {
        bytes32 typeHash = keccak256(abi.encodePacked(_PERMIT_TRANSFER_FROM_WITNESS_TYPEHASH_STUB, witnessTypeString));

        bytes32 tokenPermissionsHash = _hashTokenPermissions(permit.permitted);
        return
            keccak256(
                abi.encode(typeHash, tokenPermissionsHash, bungeeGateway, permit.nonce, permit.deadline, witness)
            );
    }

    function _hashTokenPermissions(
        ISignatureTransfer.TokenPermissions memory permitted
    ) private pure returns (bytes32) {
        return keccak256(abi.encode(_TOKEN_PERMISSIONS_TYPEHASH, permitted));
    }

    /// @notice Creates an EIP-712 typed data hash
    function _hashTypedData(address permit2, bytes32 dataHash) internal view returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", IPermit2(permit2).DOMAIN_SEPARATOR(), dataHash));
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;
import {ISignatureTransfer} from "permit2/src/interfaces/ISignatureTransfer.sol";
import {IPermit2} from "permit2/src/interfaces/IPermit2.sol";

// Library to get Permit 2 related data.
library Permit2Lib {
    string public constant TOKEN_PERMISSIONS_TYPE = "TokenPermissions(address token,uint256 amount)";

    function toPermit(
        address inputToken,
        uint256 inputAmount,
        uint256 nonce,
        uint256 deadline
    ) internal pure returns (ISignatureTransfer.PermitTransferFrom memory) {
        return
            ISignatureTransfer.PermitTransferFrom({
                permitted: ISignatureTransfer.TokenPermissions({token: inputToken, amount: inputAmount}),
                nonce: nonce,
                deadline: deadline
            });
    }

    function transferDetails(
        uint256 amount,
        address spender
    ) internal pure returns (ISignatureTransfer.SignatureTransferDetails memory) {
        return ISignatureTransfer.SignatureTransferDetails({to: spender, requestedAmount: amount});
    }

    /// @notice Checks if the unordered nonce has been used on Permit2
    /// @param nonce nonce value on Permit2 whose validity is to be checked
    function isNonceValid(IPermit2 PERMIT2, uint256 nonce) internal view returns (bool) {
        (uint256 wordPos, uint256 bitPos) = _bitmapPositions(nonce);

        // fetches the nonceBitmap value from PERMIT2
        uint256 bitmap = PERMIT2.nonceBitmap(address(this), wordPos);

        uint256 bit = 1 << bitPos;
        uint256 flipped = bitmap ^ bit;

        // checks if the nonce has been used
        if (flipped & bit == 0) return false;
        return true;
    }

    /// @notice Bit shifts nonce and returns wordPos and bitPos
    /// @param nonce nonce value
    function _bitmapPositions(uint256 nonce) private pure returns (uint256 wordPos, uint256 bitPos) {
        wordPos = uint248(nonce >> 8);
        bitPos = uint8(nonce);
    }
}
// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.19;

// @audit Audited before by Zellic: https://github.com/SocketDotTech/audits/blob/main/Socket-DL/07-2023%20-%20Data%20Layer%20-%20Zellic.pdf
import {SafeTransferLib} from "solady/src/utils/SafeTransferLib.sol";

error ZeroAddress();

/**
 * @title RescueFundsLib
 * @dev A library that provides a function to rescue funds from a contract.
 */

library RescueFundsLib {
    /**
     * @dev The address used to identify ETH.
     */
    address public constant ETH_ADDRESS = address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    /**
     * @dev thrown when the given token address don't have any code
     */
    error InvalidTokenAddress();

    /**
     * @dev Rescues funds from a contract.
     * @param token_ The address of the token contract.
     * @param rescueTo_ The address of the user.
     * @param amount_ The amount of tokens to be rescued.
     */
    function rescueFunds(address token_, address rescueTo_, uint256 amount_) internal {
        if (rescueTo_ == address(0)) revert ZeroAddress();

        if (token_ == ETH_ADDRESS) {
            SafeTransferLib.safeTransferETH(rescueTo_, amount_);
        } else {
            if (token_.code.length == 0) revert InvalidTokenAddress();
            SafeTransferLib.safeTransfer(token_, rescueTo_, amount_);
        }
    }
}
// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.19;

import {BasicRequest, Request, ExtractExec} from "../common/SingleOutputStructs.sol";
import {Permit2Lib} from "./Permit2Lib.sol";
import {ISignatureTransfer} from "permit2/src/interfaces/ISignatureTransfer.sol";

/// @notice helpers for handling BasicRequest
library BasicRequestLib {
    bytes internal constant BASIC_REQUEST_TYPE =
        abi.encodePacked(
            "BasicRequest(",
            "uint256 originChainId,",
            "uint256 destinationChainId,",
            "uint256 deadline,",
            "uint256 nonce,",
            "address sender,",
            "address receiver,",
            "address delegate,",
            "address bungeeGateway,",
            "uint32 switchboardId,",
            "address inputToken,",
            "uint256 inputAmount,",
            "address outputToken,",
            "uint256 minOutputAmount,"
            "uint256 refuelAmount)"
        );
    bytes32 internal constant BASIC_REQUEST_TYPE_HASH = keccak256(BASIC_REQUEST_TYPE);

    /// @notice Hash of BasicRequest struct on the origin chain
    /// @dev enforces originChainId to be the current chainId. Resulting hash would be the same on all chains.
    /// @dev helps avoid extra checking of chainId in the contract
    /// @param basicReq BasicRequest object to be hashed
    function originHash(BasicRequest memory basicReq) internal view returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    BASIC_REQUEST_TYPE_HASH,
                    abi.encode(
                        block.chainid,
                        basicReq.destinationChainId,
                        basicReq.deadline,
                        basicReq.nonce,
                        basicReq.sender,
                        basicReq.receiver,
                        basicReq.delegate,
                        basicReq.bungeeGateway,
                        basicReq.switchboardId,
                        basicReq.inputToken,
                        basicReq.inputAmount,
                        basicReq.outputToken,
                        basicReq.minOutputAmount,
                        basicReq.refuelAmount
                    )
                )
            );
    }

    /// @notice Hash of BasicRequest struct on the destination chain
    /// @dev enforces destinationChain to be the current chainId. Resulting hash would be the same on all chains.
    /// @dev helps avoid extra checking of chainId in the contract
    /// @param basicReq BasicRequest object to be hashed
    function destinationHash(BasicRequest memory basicReq) internal view returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    BASIC_REQUEST_TYPE_HASH,
                    abi.encode(
                        basicReq.originChainId,
                        block.chainid,
                        basicReq.deadline,
                        basicReq.nonce,
                        basicReq.sender,
                        basicReq.receiver,
                        basicReq.delegate,
                        basicReq.bungeeGateway,
                        basicReq.switchboardId,
                        basicReq.inputToken,
                        basicReq.inputAmount,
                        basicReq.outputToken,
                        basicReq.minOutputAmount,
                        basicReq.refuelAmount
                    )
                )
            );
    }
}

/// @title Bungee Request Library.
/// @author bungee protocol
/// @notice This library is responsible for all the hashing related to Request object.
library RequestLib {
    using BasicRequestLib for BasicRequest;

    // Permit 2 Witness Order Type.
    string internal constant PERMIT2_ORDER_TYPE =
        string(
            abi.encodePacked(
                "Request witness)",
                abi.encodePacked(BasicRequestLib.BASIC_REQUEST_TYPE, REQUEST_TYPE),
                Permit2Lib.TOKEN_PERMISSIONS_TYPE
            )
        );

    // REQUEST TYPE encode packed
    bytes internal constant REQUEST_TYPE =
        abi.encodePacked(
            "Request(",
            "BasicRequest basicReq,",
            "address swapOutputToken,",
            "uint256 minSwapOutput,",
            "bytes32 metadata,",
            "bytes affiliateFees,",
            "uint256 minDestGas,",
            "bytes destinationPayload,",
            "address exclusiveTransmitter)"
        );

    // EXTRACT EXEC TYPE.
    bytes internal constant EXTRACT_EXEC_TYPE =
        abi.encodePacked(
            "ExtractExec(",
            "Request request,",
            "address router,",
            "uint256 promisedAmount,",
            "bytes routerData,",
            "bytes swapPayload,",
            "address swapRouter,",
            "bytes userSignature,",
            "address beneficiary,",
            "bytes stakeData)"
        );

    // BUNGEE_REQUEST_TYPE
    bytes internal constant BUNGEE_REQUEST_TYPE = abi.encodePacked(REQUEST_TYPE, BasicRequestLib.BASIC_REQUEST_TYPE);

    // Keccak Hash of BUNGEE_REQUEST_TYPE
    bytes32 internal constant BUNGEE_REQUEST_TYPE_HASH = keccak256(BUNGEE_REQUEST_TYPE);

    // Exec Type.
    bytes internal constant EXEC_TYPE = abi.encodePacked(EXTRACT_EXEC_TYPE, REQUEST_TYPE);

    // Keccak Hash of Exec Type.
    bytes32 internal constant EXTRACT_EXEC_TYPE_HASH = keccak256(EXEC_TYPE);

    /// @notice Hash of request on the origin chain
    /// @param request request that is signe by the user
    function hashOriginRequest(Request memory request) internal view returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    BUNGEE_REQUEST_TYPE_HASH,
                    request.basicReq.originHash(),
                    request.swapOutputToken,
                    request.minSwapOutput,
                    request.metadata,
                    keccak256(request.affiliateFees),
                    request.minDestGas,
                    keccak256(request.destinationPayload),
                    request.exclusiveTransmitter
                )
            );
    }

    /// @notice Hash of request on the destination chain
    /// @param request request signed by the user
    function hashDestinationRequest(Request memory request) internal view returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    BUNGEE_REQUEST_TYPE_HASH,
                    request.basicReq.destinationHash(),
                    request.swapOutputToken,
                    request.minSwapOutput,
                    request.metadata,
                    keccak256(request.affiliateFees),
                    request.minDestGas,
                    keccak256(request.destinationPayload),
                    request.exclusiveTransmitter
                )
            );
    }

    /// @notice Hash of Extract Exec on the origin chain
    /// @param execution Transmitter submitted extract exec object
    function hashOriginExtractExec(ExtractExec memory execution) internal view returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    EXTRACT_EXEC_TYPE_HASH,
                    hashOriginRequest(execution.request),
                    execution.router,
                    execution.promisedAmount,
                    keccak256(execution.routerData),
                    keccak256(execution.swapPayload),
                    execution.swapRouter,
                    keccak256(execution.userSignature),
                    execution.beneficiary,
                    keccak256(execution.stakeData)
                )
            );
    }

    /// @notice hash a batch of extract execs
    /// @param extractExecs batch of extract execs to be hashed
    function hashOriginBatch(ExtractExec[] memory extractExecs) internal view returns (bytes32) {
        unchecked {
            bytes32 outputHash = keccak256("BUNGEE_EXTRACT_EXEC");
            // Hash all of the extract execs present in the batch.
            for (uint256 i = 0; i < extractExecs.length; i++) {
                outputHash = keccak256(abi.encode(outputHash, hashOriginExtractExec(extractExecs[i])));
            }

            return outputHash;
        }
    }
}

library Permit2TransferLib {
    function permitWitnessTransferFrom(
        ISignatureTransfer PERMIT2,
        bytes32 requestHash,
        ExtractExec memory extractExec,
        address to
    ) internal {
        // Calls Permit2 to transfer funds from user to swap executor.
        PERMIT2.permitWitnessTransferFrom(
            Permit2Lib.toPermit(
                extractExec.request.basicReq.inputToken,
                extractExec.request.basicReq.inputAmount,
                extractExec.request.basicReq.nonce,
                extractExec.request.basicReq.deadline
            ),
            /// @dev transfer tokens to SwapExecutor
            Permit2Lib.transferDetails(extractExec.request.basicReq.inputAmount, to),
            extractExec.request.basicReq.sender,
            requestHash,
            RequestLib.PERMIT2_ORDER_TYPE,
            extractExec.userSignature
        );
    }
}
// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.19;

import {BasicRequest, Request, SwapExec} from "../common/SwapRequestStructs.sol";
import {Permit2Lib} from "./Permit2Lib.sol";
import {ISignatureTransfer} from "permit2/src/interfaces/ISignatureTransfer.sol";

/// @notice helpers for handling CommandInfo objects
library BasicRequestLib {
    bytes internal constant BASIC_REQUEST_TYPE =
        abi.encodePacked(
            "BasicRequest(",
            "uint256 chainId,",
            "uint256 deadline,",
            "uint256 nonce,",
            "address sender,",
            "address receiver,",
            "address bungeeGateway,",
            "address inputToken,",
            "uint256 inputAmount,",
            "address outputToken,",
            "uint256 minOutputAmount)"
        );
    bytes32 internal constant BASIC_REQUEST_TYPE_HASH = keccak256(BASIC_REQUEST_TYPE);

    /// @notice Hash of BasicRequest struct on the swap chain
    /// @dev enforces chainId to be the current chainId
    /// @dev helps avoid extra checking of chainId in the contract
    /// @param basicReq BasicRequest object to be hashed
    function hash(BasicRequest memory basicReq) internal view returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    BASIC_REQUEST_TYPE_HASH,
                    block.chainid,
                    basicReq.deadline,
                    basicReq.nonce,
                    basicReq.sender,
                    basicReq.receiver,
                    basicReq.bungeeGateway,
                    basicReq.inputToken,
                    basicReq.inputAmount,
                    basicReq.outputToken,
                    basicReq.minOutputAmount
                )
            );
    }
}

/// @title Bungee Request Library.
/// @author bungee protocol
/// @notice This library is responsible for all the hashing related to Request object.
library RequestLib {
    using BasicRequestLib for BasicRequest;

    // Permit 2 Witness Order Type.
    string internal constant PERMIT2_ORDER_TYPE =
        string(
            abi.encodePacked(
                "Request witness)",
                abi.encodePacked(BasicRequestLib.BASIC_REQUEST_TYPE, REQUEST_TYPE),
                Permit2Lib.TOKEN_PERMISSIONS_TYPE
            )
        );

    // REQUEST TYPE encode packed
    bytes internal constant REQUEST_TYPE =
        abi.encodePacked(
            "Request(",
            "BasicRequest basicReq,",
            "bytes32 metadata,",
            "bytes affiliateFees,",
            "uint256 minDestGas,",
            "bytes destinationPayload,",
            "address exclusiveTransmitter)"
        );

    // SWAP EXEC TYPE.
    // @review this lib again, make sure things are solid
    bytes internal constant SWAP_EXEC_TYPE =
        abi.encodePacked(
            "SwapExec(",
            "Request request,",
            "uint256 fulfilAmount,",
            "bytes callbackPayload,",
            "bytes userSignature)"
        );

    // BUNGEE_REQUEST_TYPE
    bytes internal constant BUNGEE_REQUEST_TYPE = abi.encodePacked(REQUEST_TYPE, BasicRequestLib.BASIC_REQUEST_TYPE);

    // Keccak Hash of BUNGEE_REQUEST_TYPE
    bytes32 internal constant BUNGEE_REQUEST_TYPE_HASH = keccak256(BUNGEE_REQUEST_TYPE);

    // Exec Type.
    bytes internal constant EXEC_TYPE = abi.encodePacked(SWAP_EXEC_TYPE, REQUEST_TYPE);

    // Keccak Hash of Exec Type.
    bytes32 internal constant SWAP_EXEC_TYPE_HASH = keccak256(EXEC_TYPE);

    /// @notice Hash of request on the swap chain
    /// @param request request that is signe by the user
    function hashRequest(Request memory request) internal view returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    BUNGEE_REQUEST_TYPE_HASH,
                    request.basicReq.hash(),
                    request.metadata,
                    keccak256(request.affiliateFees),
                    request.minDestGas,
                    keccak256(request.destinationPayload),
                    request.exclusiveTransmitter
                )
            );
    }

    /// @notice Hash of Swap Exec on the swap chain
    /// @param execution Transmitter submitted swap exec object
    function hashSwapExec(SwapExec memory execution) internal view returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    SWAP_EXEC_TYPE_HASH,
                    hashRequest(execution.request),
                    execution.fulfilAmount,
                    keccak256(execution.callbackPayload),
                    keccak256(execution.userSignature)
                )
            );
    }

    /// @notice hash a batch of swap execs
    /// @param swapExecs batch of swap execs to be hashed
    function hashBatch(SwapExec[] memory swapExecs) internal view returns (bytes32) {
        unchecked {
            bytes32 outputHash = keccak256("BUNGEE_SWAP_EXEC");
            // Hash all of the swap execs present in the batch.
            for (uint256 i = 0; i < swapExecs.length; i++) {
                outputHash = keccak256(abi.encode(outputHash, hashSwapExec(swapExecs[i])));
            }

            return outputHash;
        }
    }
}

library Permit2TransferLib {
    function permitWitnessTransferFrom(
        ISignatureTransfer PERMIT2,
        bytes32 requestHash,
        SwapExec memory swapExec,
        address to
    ) internal {
        // Calls Permit2 to transfer funds from user to swap executor.
        PERMIT2.permitWitnessTransferFrom(
            Permit2Lib.toPermit(
                swapExec.request.basicReq.inputToken,
                swapExec.request.basicReq.inputAmount,
                swapExec.request.basicReq.nonce,
                swapExec.request.basicReq.deadline
            ),
            /// @dev transfer tokens to SwapExecutor
            Permit2Lib.transferDetails(swapExec.request.basicReq.inputAmount, to),
            swapExec.request.basicReq.sender,
            requestHash,
            RequestLib.PERMIT2_ORDER_TYPE,
            swapExec.userSignature
        );
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Ownable} from "./Ownable.sol";

/**
 * @title AccessControl
 * @dev This abstract contract implements access control mechanism based on roles.
 * Each role can have one or more addresses associated with it, which are granted
 * permission to execute functions with the onlyRole modifier.
 */
abstract contract AccessControl is Ownable {
    /**
     * @dev A mapping of roles to a mapping of addresses to boolean values indicating whether or not they have the role.
     */
    mapping(bytes32 => mapping(address => bool)) private _permits;

    /**
     * @dev Emitted when a role is granted to an address.
     */
    event RoleGranted(bytes32 indexed role, address indexed grantee);

    /**
     * @dev Emitted when a role is revoked from an address.
     */
    event RoleRevoked(bytes32 indexed role, address indexed revokee);

    /**
     * @dev Error message thrown when an address does not have permission to execute a function with onlyRole modifier.
     */
    error NoPermit(bytes32 role);

    /**
     * @dev Constructor that sets the owner of the contract.
     */
    constructor(address owner_) Ownable(owner_) {}

    /**
     * @dev Modifier that restricts access to addresses having roles
     * Throws an error if the caller do not have permit
     */
    modifier onlyRole(bytes32 role) {
        if (!_permits[role][msg.sender]) revert NoPermit(role);
        _;
    }

    /**
     * @dev Checks and reverts if an address do not have a specific role.
     * @param role_ The role to check.
     * @param address_ The address to check.
     */
    function _checkRole(bytes32 role_, address address_) internal virtual {
        if (!_hasRole(role_, address_)) revert NoPermit(role_);
    }

    /**
     * @dev Grants a role to a given address.
     * @param role_ The role to grant.
     * @param grantee_ The address to grant the role to.
     * Emits a RoleGranted event.
     * Can only be called by the owner of the contract.
     */
    function grantRole(bytes32 role_, address grantee_) external virtual onlyOwner {
        _grantRole(role_, grantee_);
    }

    /**
     * @dev Revokes a role from a given address.
     * @param role_ The role to revoke.
     * @param revokee_ The address to revoke the role from.
     * Emits a RoleRevoked event.
     * Can only be called by the owner of the contract.
     */
    function revokeRole(bytes32 role_, address revokee_) external virtual onlyOwner {
        _revokeRole(role_, revokee_);
    }

    /**
     * @dev Internal function to grant a role to a given address.
     * @param role_ The role to grant.
     * @param grantee_ The address to grant the role to.
     * Emits a RoleGranted event.
     */
    function _grantRole(bytes32 role_, address grantee_) internal {
        _permits[role_][grantee_] = true;
        emit RoleGranted(role_, grantee_);
    }

    /**
     * @dev Internal function to revoke a role from a given address.
     * @param role_ The role to revoke.
     * @param revokee_ The address to revoke the role from.
     * Emits a RoleRevoked event.
     */
    function _revokeRole(bytes32 role_, address revokee_) internal {
        _permits[role_][revokee_] = false;
        emit RoleRevoked(role_, revokee_);
    }

    /**
     * @dev Checks whether an address has a specific role.
     * @param role_ The role to check.
     * @param address_ The address to check.
     * @return A boolean value indicating whether or not the address has the role.
     */
    function hasRole(bytes32 role_, address address_) public view returns (bool) {
        return _hasRole(role_, address_);
    }

    function _hasRole(bytes32 role_, address address_) internal view returns (bool) {
        return _permits[role_][address_];
    }
}
// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.19;

import {OnlyOwner, OnlyNominee} from "../common/Errors.sol";

// @audit Audited before by Zellic: https://github.com/SocketDotTech/audits/blob/main/Socket-DL/07-2023%20-%20Data%20Layer%20-%20Zellic.pdf
abstract contract Ownable {
    address private _owner;
    address private _nominee;

    event OwnerNominated(address indexed nominee);
    event OwnerClaimed(address indexed claimer);

    constructor(address owner_) {
        _claimOwner(owner_);
    }

    modifier onlyOwner() {
        if (msg.sender != _owner) {
            revert OnlyOwner();
        }
        _;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function nominee() public view returns (address) {
        return _nominee;
    }

    function nominateOwner(address nominee_) external {
        if (msg.sender != _owner) {
            revert OnlyOwner();
        }
        _nominee = nominee_;
        emit OwnerNominated(_nominee);
    }

    function claimOwner() external {
        if (msg.sender != _nominee) {
            revert OnlyNominee();
        }
        _claimOwner(msg.sender);
    }

    function _claimOwner(address claimer_) internal {
        _owner = claimer_;
        _nominee = address(0);
        emit OwnerClaimed(claimer_);
    }
}