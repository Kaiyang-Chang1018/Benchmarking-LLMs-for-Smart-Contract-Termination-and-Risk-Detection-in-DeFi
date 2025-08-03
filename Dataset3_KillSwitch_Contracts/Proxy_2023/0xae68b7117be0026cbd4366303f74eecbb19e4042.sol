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

/// @notice Reentrancy guard mixin.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/ReentrancyGuard.sol)
abstract contract ReentrancyGuard {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       CUSTOM ERRORS                        */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Unauthorized reentrant call.
    error Reentrancy();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                          STORAGE                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Equivalent to: `uint72(bytes9(keccak256("_REENTRANCY_GUARD_SLOT")))`.
    /// 9 bytes is large enough to avoid collisions with lower slots,
    /// but not too large to result in excessive bytecode bloat.
    uint256 private constant _REENTRANCY_GUARD_SLOT = 0x929eee149b4bd21268;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      REENTRANCY GUARD                      */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Guards a function from reentrancy.
    modifier nonReentrant() virtual {
        /// @solidity memory-safe-assembly
        assembly {
            if eq(sload(_REENTRANCY_GUARD_SLOT), address()) {
                mstore(0x00, 0xab143c06) // `Reentrancy()`.
                revert(0x1c, 0x04)
            }
            sstore(_REENTRANCY_GUARD_SLOT, address())
        }
        _;
        /// @solidity memory-safe-assembly
        assembly {
            sstore(_REENTRANCY_GUARD_SLOT, codesize())
        }
    }

    /// @dev Guards a view function from read-only reentrancy.
    modifier nonReadReentrant() virtual {
        /// @solidity memory-safe-assembly
        assembly {
            if eq(sload(_REENTRANCY_GUARD_SLOT), address()) {
                mstore(0x00, 0xab143c06) // `Reentrancy()`.
                revert(0x1c, 0x04)
            }
        }
        _;
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

import {ISwapExecutor} from "../interfaces/ISwapExecutor.sol";
import {ICalldataExecutor} from "../interfaces/ICalldataExecutor.sol";
import {ISwitchboardRouter} from "../interfaces/ISwitchboardRouter.sol";
import {IEntrypoint} from "../interfaces/IEntrypoint.sol";

import {RESCUE_ROLE, CONFIG_ROLE} from "../common/AccessRoles.sol";

import {BungeeGatewayBase} from "./BungeeGatewayBase.sol";
import {BungeeGatewayStorage} from "./BungeeGatewayStorage.sol";

import {InvalidMsg, InvalidAddress} from "../common/Errors.sol";

contract BungeeGateway is BungeeGatewayStorage, BungeeGatewayBase {
    bytes4 internal immutable RECEIVE_MSG_FUNCTION_SIG = bytes4(keccak256("receiveMsg(bytes)"));

    /**
     * @notice Constructor.
     * @param _owner owner of the contract.
     * @param _entrypoint address of the Entrypoint contract that guards extraction with mofa sig
     * @param _switchboardRouter address of the switchboard router.
        Switchboard router is responsible for routing, sending and delivering messages between chains.
     * @param _swapExecutor address of the swap executor contract.
     * @param _calldataRouter address of the calldata executor contract.
     * @param _permit2 address of the permit 2 contract.
     */
    constructor(
        address _owner,
        address _entrypoint,
        address _switchboardRouter,
        address _swapExecutor,
        address _calldataRouter,
        address _permit2
    ) BungeeGatewayStorage(_owner, _permit2) {
        _grantRole(RESCUE_ROLE, _owner);
        _grantRole(CONFIG_ROLE, _owner);

        ENTRYPOINT = IEntrypoint(_entrypoint);
        SWITCHBOARD_ROUTER = ISwitchboardRouter(_switchboardRouter);
        SWAP_EXECUTOR = ISwapExecutor(_swapExecutor);
        CALLDATA_EXECUTOR = ICalldataExecutor(_calldataRouter);
    }

    /**
     * @notice Execute a request using the provided implementation.
     * @param implId id of the implementation to use.
     * @param data data to be executed.
     * @return result of the execution
     */
    function executeImpl(uint8 implId, bytes calldata data) external payable nonReentrant returns (bytes memory) {
        address implAddress = _impls[implId];
        if (implAddress == address(0)) revert InvalidAddress();

        (bool success, bytes memory result) = implAddress.delegatecall(data);

        if (!success) {
            assembly {
                revert(add(result, 32), mload(result))
            }
        }

        return result;
    }

    /**
     * @notice Accept inbound message from another chain via Switchboard
     * @dev delegatecalls the receiveMsg function of the implementation contract
     * @param implId id of the implementation to use.
     * @param payload data to be executed.
     */
    function inboundMsgFromSwitchboard(uint8 implId, uint32, bytes calldata payload) external payable nonReentrant {
        address implAddress = _impls[implId];
        if (implAddress == address(0)) revert InvalidMsg();

        (bool success, bytes memory result) = implAddress.delegatecall(
            abi.encodeWithSelector(RECEIVE_MSG_FUNCTION_SIG, payload)
        );

        if (!success)
            assembly {
                revert(add(result, 32), mload(result))
            }
    }

    /**
     * @notice fallback function to handle request execution
     * @dev ensure implId is converted to uint8 and sent as msg.sig in the transaction
     */
    fallback() external payable nonReentrant {
        address implAddress = _impls[uint8(uint32(msg.sig))];
        if (implAddress == address(0)) revert InvalidAddress();

        bytes memory result;

        assembly {
            // copy function selector and any arguments
            calldatacopy(0, 4, sub(calldatasize(), 4))
            // execute function call using the facet
            result := delegatecall(gas(), implAddress, 0, sub(calldatasize(), 4), 0, 0)
            // get any return value
            returndatacopy(0, 0, returndatasize())
            // return any return value or error back to the caller
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    /**
     * @dev fallback function to receive native tokens
     * @dev especially useful for receiving native token swap output in SwapRequest
     * @dev this will be applied to BungeeGateway as a whole
     */
    receive() external payable {}
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {ReentrancyGuard} from "solady/src/utils/ReentrancyGuard.sol";

import {IBungeeExecutor} from "../interfaces/IBungeeExecutor.sol";
import {IBaseRouter} from "../interfaces/IBaseRouter.sol";
import {ISwapExecutor} from "../interfaces/ISwapExecutor.sol";
import {ICalldataExecutor} from "../interfaces/ICalldataExecutor.sol";
import {ISwitchboardRouter} from "../interfaces/ISwitchboardRouter.sol";
import {IFeeCollector} from "../interfaces/IFeeCollector.sol";
import {IEntrypoint} from "../interfaces/IEntrypoint.sol";
import {RESCUE_ROLE, CONFIG_ROLE} from "../common/AccessRoles.sol";
import {RouterAlreadyRegistered, InvalidMsg, ImplAlreadyRegistered} from "../common/Errors.sol";

import {RescueFundsLib} from "../lib/RescueFundsLib.sol";
import {BungeeGatewayStorage, WithdrawnRequest} from "./BungeeGatewayStorage.sol";

abstract contract BungeeGatewayBase is BungeeGatewayStorage, ReentrancyGuard {
    /// @notice Emitted when a new implementation is added
    /// @param implId id of the implementation
    /// @param implAddress address of the implementation
    event ImplAdded(uint32 indexed implId, address implAddress);

    /// @notice Emitted when an implementation is removed
    /// @param implId id of the implementation
    /// @param prevImplAddress address of the previous implementation
    event ImplRemoved(uint32 indexed implId, address prevImplAddress);

    /// @notice Emitted when a request is extracted
    /// @param requestHash hash of the request
    /// @param transmitter address of the transmitter
    /// @param execution encoded execution data
    event RequestExtracted(bytes32 indexed requestHash, uint8 implId, address transmitter, bytes execution);

    /// @notice Emitted when a request is fulfilled
    /// @param requestHash hash of the request
    /// @param fulfiller address of the fulfiller
    /// @param execution encoded execution data
    event RequestFulfilled(bytes32 indexed requestHash, uint8 implId, address fulfiller, bytes execution);

    // emitted on the source once settlement completes
    /// @param requestHash hash of the request
    event RequestSettled(bytes32 indexed requestHash);

    // emitted on the source once cancellation completes
    /// @param requestHash hash of the request
    event RequestCancelled(bytes32 indexed requestHash, address token, uint256 amount, address to);

    /// @notice Emitted when a settlement fails
    /// @param requestHash hash of the request
    /// @param _error error selector
    event RequestSettlementFailed(bytes32 indexed requestHash, bytes4 _error);

    /// @notice Emitted when settlement is initiated on the destination chain
    /// @param requestHashes array of request hashes
    /// @param implId id of the implementation
    /// @param transmitter address of the transmitter
    /// @param outboundFees fees to be used for the inbound txn via Socket DL
    event RequestsSettledOnDestination(
        bytes32[] requestHashes,
        uint8 implId,
        address transmitter,
        uint256 outboundFees
    );

    /// @notice Emitted when a request cancellation is initiated on the destination
    /// @param requestHash hash of the request
    /// @param implId id of the implementation
    /// @param transmitter address of the transmitter
    /// @param outboundFees fees to be used for the inbound txn via Socket DL
    event RequestCancelledOnDestination(bytes32 requestHash, uint8 implId, address transmitter, uint256 outboundFees);

    /// @notice Emitted if calldata execution on destination fails during fulfilment
    /// @param requestHash hash of the request
    /// @param to destination address
    /// @param encodedData encoded calldata
    /// @param minDestGasLimit minimum gas limit for the destination execution
    event CalldataExecutionFailed(bytes32 requestHash, address to, bytes encodedData, uint256 minDestGasLimit);

    /*//////////////////////////////////////////////////////////////////////////
                                ADMIN FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @notice sets the new Entrypoint address.
     * @dev Can only be called by CONFIG_ROLE
     * @param _entrypoint address of the new Entrypoint
     */
    function setEntrypoint(address _entrypoint) external onlyRole(CONFIG_ROLE) {
        ENTRYPOINT = IEntrypoint(_entrypoint);
    }

    /**
     * @notice sets the new switchboard router.
     * @dev Can only be called by CONFIG_ROLE
     * @param _switchboardRouter address of the new switchboard router.
     */
    function setSwitchboardRouter(address _switchboardRouter) external onlyRole(CONFIG_ROLE) {
        SWITCHBOARD_ROUTER = ISwitchboardRouter(_switchboardRouter);
    }

    /**
     * @notice sets the new fee collector.
     * @dev Can only be called by CONFIG_ROLE
     * @param _feeCollector address of the new fee collector.
     */
    function setFeeCollector(address _feeCollector) external onlyRole(CONFIG_ROLE) {
        FEE_COLLECTOR = IFeeCollector(_feeCollector);
    }

    /**
     * @notice sets the new swap executor contract.
     * @dev Can only be called by CONFIG_ROLE
     * @param _swapExecutor address of the new swap executor.
     */
    function setSwapExecutor(address _swapExecutor) external onlyRole(CONFIG_ROLE) {
        SWAP_EXECUTOR = ISwapExecutor(_swapExecutor);
    }

    /**
     * @notice sets the new calldata executor contract.
     * @dev Can only be called by CONFIG_ROLE
     * @param _calldataExecutor address of the new calldata executor.
     */
    function setCalldataExecutor(address _calldataExecutor) external onlyRole(CONFIG_ROLE) {
        CALLDATA_EXECUTOR = ICalldataExecutor(_calldataExecutor);
    }

    /**
     * @notice Adds a new router to the protocol
     * @dev Can only be called by CONFIG_ROLE
     * @param _bungeeRouter address of the new router
     */
    function addBungeeRouter(address _bungeeRouter) external onlyRole(CONFIG_ROLE) {
        if (bungeeRouters[_bungeeRouter]) revert RouterAlreadyRegistered();

        bungeeRouters[_bungeeRouter] = true;
    }

    /**
     * @notice Returns if the router is registered or not
     * @param router address of the router to be removed
     */
    function isBungeeRouter(address router) public view returns (bool) {
        return bungeeRouters[router];
    }

    /**
     * @notice adds new whitelisted receiver address against a router.
     * @dev Can only be called by CONFIG_ROLE
     * @param receiver address of the new whitelisted receiver contract.
     * @param destinationChainId destination chain id where the receiver will exist.
     * @param router router address from which the functions will be routed from.
     */
    function setWhitelistedReceiver(
        address receiver,
        uint256 destinationChainId,
        address router
    ) external onlyRole(CONFIG_ROLE) {
        whitelistedReceivers[router][destinationChainId] = receiver;
    }

    /**
     * @notice gets the receiver address set for the router on the destination chain.
     * @param destinationChainId destination chain id where the receiver will exist.
     * @param router router address from which the funds will be routed from.
     */
    function getWhitelistedReceiver(address router, uint256 destinationChainId) external view returns (address) {
        return whitelistedReceivers[router][destinationChainId];
    }

    /**
     * @notice returns the implementation address for the given id.
     */
    function getImpl(uint8 _implId) external view returns (address) {
        return _impls[_implId];
    }

    /**
     * @notice add a new request type implementation.
     * @dev Can only be called by CONFIG_ROLE
     * @dev Only allowed to set a impl id once. Will revert if the impl id is already set. Or it was removed before.
     * @param _implId id of the implementation
     * @param _newImplAddress address of the new implementation
     */
    function addImpl(uint8 _implId, address _newImplAddress) external onlyRole(CONFIG_ROLE) returns (uint8, address) {
        address _currentImplAddress = _impls[_implId];

        // allow only setting new impl
        if (_currentImplAddress != address(0) || _removedImpls[_implId]) revert ImplAlreadyRegistered();

        _impls[_implId] = _newImplAddress;

        emit ImplAdded(_implId, _newImplAddress);

        return (_implId, _newImplAddress);
    }

    /**
     * @notice remove a request type implementation.
     * @dev Can only be called by CONFIG_ROLE
     * @param _implId id of the implementation
     */
    function removeImpl(uint8 _implId) external onlyRole(CONFIG_ROLE) {
        address _prevImplAddress = _impls[_implId];

        _impls[_implId] = address(0);
        _removedImpls[_implId] = true;

        emit ImplRemoved(_implId, _prevImplAddress);
    }

    /**
     * @notice withdraw settlement funds collected by a beneficiary.
     * @param beneficiary address of the beneficiary
     * @param router address of the router via which the funds were collected
     * @param token address of the token
     */
    function withdrawBeneficiarySettlement(address beneficiary, address router, address token) external nonReentrant {
        uint256 amount = beneficiarySettlements[beneficiary][router][token];
        if (amount > 0) {
            beneficiarySettlements[beneficiary][router][token] = 0;
            // Transfer the tokens to the beneficiary
            IBaseRouter(router).releaseFunds(token, amount, beneficiary);
        }
    }

    /**
     * @dev Utility function that returns the WithdrawnRequest struct for a given request hash.
     */
    function withdrawnRequests(bytes32 requestHash) external view returns (WithdrawnRequest memory) {
        return _withdrawnRequests[requestHash];
    }

    /**
     * @notice Accept inbound message from another chain via Switchboard
     * @dev Can only be called by the switchboard router
     * @dev _receiveMsg has to be implemented by the request implementation contract
     * @param payload msg payload sent.
     */
    function receiveMsg(bytes calldata payload) external payable {
        // If the msg sender is not switchboard router, revert.
        if (msg.sender != address(SWITCHBOARD_ROUTER)) revert InvalidMsg();
        _receiveMsg(payload);
    }

    function _receiveMsg(bytes calldata payload) internal virtual {}

    /**
     * @dev delegates calldata execution to the CalldataExecutor contract
     * @param to destination address
     * @param minDestGasLimit minimum gas limit that should be used for the destination execution
     * @param executionData calldata to be executed on the destination
     * @param requestHash hash of the request
     * @param fulfilledAmount amount fulfilled on the destination in the request
     * @param outputToken output token in the request
     */
    function _executeCalldataSingleOutput(
        address to,
        uint256 minDestGasLimit,
        bytes memory executionData,
        bytes32 requestHash,
        uint256 fulfilledAmount,
        address outputToken
    ) internal {
        // Check and return with no action if the data is empty
        // Check and return with no action if the destination is invalid
        if (executionData.length == 0 || to == address(0) || to == address(this)) return;

        // Create the memory arrays only if the data is not empty
        uint256[] memory fulfilledAmounts = new uint256[](1);
        fulfilledAmounts[0] = fulfilledAmount;
        address[] memory outputTokens = new address[](1);
        outputTokens[0] = outputToken;

        _executeCalldata(to, minDestGasLimit, executionData, requestHash, fulfilledAmounts, outputTokens);
    }

    /**
     * @dev delegates calldata execution to the CalldataExecutor contract
     * @param to destination address
     * @param minDestGasLimit minimum gas limit that should be used for the destination execution
     * @param executionData calldata to be executed on the destination
     * @param requestHash hash of the request
     * @param fulfilledAmounts array of amounts fulfilled on the destination in the request
     * @param outputTokens array of output tokens in the request
     */
    function _executeCalldataMultiOutput(
        address to,
        uint256 minDestGasLimit,
        bytes memory executionData,
        bytes32 requestHash,
        uint256[] memory fulfilledAmounts,
        address[] memory outputTokens
    ) internal {
        // Check and return with no action if the data is empty
        // Check and return with no action if the destination is invalid
        if (executionData.length == 0 || to == address(0) || to == address(this)) return;

        _executeCalldata(to, minDestGasLimit, executionData, requestHash, fulfilledAmounts, outputTokens);
    }

    function _executeCalldata(
        address to,
        uint256 minDestGasLimit,
        bytes memory executionData,
        bytes32 requestHash,
        uint256[] memory fulfilledAmounts,
        address[] memory outputTokens
    ) internal {
        // Encodes request data in the payload
        bytes memory encodedData = abi.encodeCall(
            IBungeeExecutor.executeData,
            (requestHash, fulfilledAmounts, outputTokens, executionData)
        );

        // Execute calldata
        bool success = CALLDATA_EXECUTOR.executeCalldata(to, encodedData, minDestGasLimit);
        if (!success) emit CalldataExecutionFailed(requestHash, to, encodedData, minDestGasLimit);
    }

    /**
     * @notice send funds to the provided address if stuck.
     * @dev can be called only by RESCUE_ROLE
     * @param token address of the token
     * @param amount amount to be rescued
     * @param to address, funds will be transferred to this address.
     */
    function rescue(address token, address to, uint256 amount) external onlyRole(RESCUE_ROLE) {
        RescueFundsLib.rescueFunds(token, to, amount);
    }
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

import {IBaseRouterSingleOutput as IBaseRouter} from "../interfaces/IBaseRouterSingleOutput.sol";
import {
    InsufficientNativeAmount,
    RouterNotRegistered,
    MinOutputNotMet,
    InvalidRequest,
    CallerNotDelegate,
    RequestProcessed,
    InvalidSwitchboard,
    InvalidRequest,
    PromisedAmountNotMet,
    RequestNotProcessed,
    CallerNotEntrypoint
} from "../common/Errors.sol";
import {RequestLib, Permit2TransferLib} from "../lib/SingleOutputRequestLib.sol";
import {Request, FulfilExec, ExtractExec, ExtractedRequest, FulfilledRequest} from "../common/SingleOutputStructs.sol";
import {BungeeGatewayBase} from "./BungeeGatewayBase.sol";
import {BungeeGatewayStorage, WithdrawnRequest} from "./BungeeGatewayStorage.sol";
import {CANCEL_ROLE} from "../common/AccessRoles.sol";

/**
 * @title SingleOutputRequestImpl
 * @notice Implementation contract that facilitates SingleOutputRequests
 * @dev BungeeGateway delegatecalls to this implementation contract
 */
contract SingleOutputRequestImpl is BungeeGatewayStorage, BungeeGatewayBase {
    using RequestLib for Request;
    using RequestLib for ExtractExec[];

    /// @dev id used to identify single output implementation
    uint8 public constant SINGLE_OUTPUT_IMPL_ID = 1;

    /// @notice ERC721 storage struct for SingleOutputRequestImpl
    /// @dev Tracks extracted and fulfilled requests
    /// @custom:storage-location erc7201:bungeeprotocol.storage.SingleOutputRequestImpl
    struct SingleOutputRequestImplStorage {
        /// @notice this holds all the requests that have been extracted.
        mapping(bytes32 requestHash => ExtractedRequest request) extractedRequests;
        /// @notice this holds all the requests that have been fulfilled.
        mapping(bytes32 requestHash => FulfilledRequest request) fulfilledRequests;
    }

    /// @dev storage slot for SingleOutputRequestImplStorage struct
    // keccak256(abi.encode(uint256(keccak256("bungeeprotocol.storage.SingleOutputRequestImpl")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant SingleOutputRequestImplStorageLocation =
        0x79b06a356cc9b4ff989730c568e8098eadbcb882c69316f29a17e156b9f21f00;

    /**
     * @dev Internal function to get the storage struct
     */
    function _getSingleOutputRequestImplStorage() private pure returns (SingleOutputRequestImplStorage storage $) {
        assembly {
            $.slot := SingleOutputRequestImplStorageLocation
        }
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    GETTERS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @notice Get the extracted request details
     */
    function getExtractedRequest(bytes32 requestHash) public view returns (ExtractedRequest memory) {
        SingleOutputRequestImplStorage storage $ = _getSingleOutputRequestImplStorage();
        return $.extractedRequests[requestHash];
    }

    /**
     * @notice Get the fulfilled request details
     */
    function getFulfilledRequest(bytes32 requestHash) public view returns (FulfilledRequest memory) {
        SingleOutputRequestImplStorage storage $ = _getSingleOutputRequestImplStorage();
        return $.fulfilledRequests[requestHash];
    }

    constructor(address _owner, address _permit2) BungeeGatewayStorage(_owner, _permit2) {}

    /*//////////////////////////////////////////////////////////////////////////
                                SOURCE FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @notice extract the user requests and routes it via the respective routers.
     * @notice entry to this function is guarded by the Entrypoint contract.
     * @notice each request can be routed via a different router.
     * @notice it would be assumed as a successful execution if the router call does not revert.
     * @dev state of the request would be saved against the requestHash.
     * @dev funds from the user wallet will be pulled and sent to the router.
     * @param extractExecs batch of extractions submitted by the transmitter.
     * @param transmitter address of the transmitter.
     */
    function extractRequests(ExtractExec[] calldata extractExecs, address transmitter) external {
        // Revert if the caller is not the Entrypoint
        if (msg.sender != address(ENTRYPOINT)) revert CallerNotEntrypoint();

        // Iterate through extractExec
        unchecked {
            for (uint256 i = 0; i < extractExecs.length; i++) {
                // Check if the promised amount is more than the minOutputAmount
                if (extractExecs[i].promisedAmount < extractExecs[i].request.basicReq.minOutputAmount)
                    revert MinOutputNotMet();

                _callRouter(extractExecs[i], transmitter);
            }
        }
    }

    /**
     * @notice Accept inbound message from another chain via Switchboard
     * @dev Can only be called by the switchboard router
     * @dev _receiveMsg has to be implemented by the request implementation contract
     * @dev identifies withdrawal message from destination by fulfilledAmount = 0
     * @dev settles requests if message is not withdrawal
     * @param payload msg payload sent.
     */
    function _receiveMsg(bytes calldata payload) internal override {
        uint32 switchboardId = uint32(bytes4(payload));
        /// @dev fulfilledAmounts would be output token fulfilled for each request in the batch. hence a 1d array
        (bytes32[] memory requestHashes, uint256[] memory fulfilledAmounts) = abi.decode(
            payload[4:],
            (bytes32[], uint256[])
        );

        unchecked {
            for (uint256 i = 0; i < requestHashes.length; i++) {
                if (fulfilledAmounts[i] == 0) {
                    // handle withdrawal
                    /// @dev not checking individual failures, since cancellation is expected to be singular
                    _validateAndWithdrawRequest(requestHashes[i]);
                } else {
                    // handle settlement
                    (bool success, bytes4 _error) = _validateAndSettleRequest(
                        switchboardId,
                        requestHashes[i],
                        fulfilledAmounts[i]
                    );
                    if (!success) emit RequestSettlementFailed(requestHashes[i], _error);
                }
            }
        }
    }

    /*//////////////////////////////////////////////////////////////////////////
                            INTERNAL SOURCE FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @notice this function is used when the transmitter submits a request that does not involve a swap.
     * @dev funds would be transferred to the router directly from the user.
     * @dev any swap would be routed and executed by the router
     * @dev Saves the extraction details against the requestHash.
     * @param extractExec execution submitted by the transmitter for the request.
     * @param transmitter address of the transmitter.
     */
    function _callRouter(ExtractExec memory extractExec, address transmitter) internal {
        // Validate if the router is part of the protocol
        if (!isBungeeRouter(extractExec.router)) revert RouterNotRegistered();

        // Create the request hash for the submitted request.
        bytes32 requestHash = extractExec.request.hashOriginRequest();

        // Calls Permit2 to transfer funds from user to the router.
        Permit2TransferLib.permitWitnessTransferFrom(PERMIT2, requestHash, extractExec, extractExec.router);

        // Call the router with relevant details
        // Address Zero check for whitelistedReceivers should be inside routers and should revert if necessary
        (uint256 extractedAmount, address extractedToken) = IBaseRouter(extractExec.router).execute(
            requestHash,
            whitelistedReceivers[extractExec.router][extractExec.request.basicReq.destinationChainId],
            extractExec
        );

        // Save the extraction details
        SingleOutputRequestImplStorage storage $ = _getSingleOutputRequestImplStorage();
        $.extractedRequests[requestHash] = ExtractedRequest({
            router: extractExec.router,
            sender: extractExec.request.basicReq.sender,
            delegate: extractExec.request.basicReq.delegate,
            switchboardId: extractExec.request.basicReq.switchboardId,
            token: extractedToken,
            amount: extractedAmount,
            transmitter: transmitter,
            beneficiary: extractExec.beneficiary,
            promisedAmount: extractExec.promisedAmount
        });

        // Emits Extraction Event
        emit RequestExtracted(requestHash, SINGLE_OUTPUT_IMPL_ID, transmitter, abi.encode(extractExec));
    }

    /**
     * @notice validates & settles a request.
     * @dev unlocks fees on FeeCollector
     * @dev updates beneficiary settlement amounts
     * @param switchboardId id of the switchboard that received the msg.
     * @param requestHash hash of the request that needs to be settled.
     * @param fulfilledAmount amount sent to the receiver on the destination.
     */
    function _validateAndSettleRequest(
        uint32 switchboardId,
        bytes32 requestHash,
        uint256 fulfilledAmount
    ) internal returns (bool, bytes4) {
        // Check if the extraction exists and the switchboard id is correct.
        SingleOutputRequestImplStorage storage $ = _getSingleOutputRequestImplStorage();
        ExtractedRequest memory eReq = $.extractedRequests[requestHash];
        // Check if the request is valid.
        // Check if request has already been settled.
        if (eReq.sender == address(0)) return (false, InvalidRequest.selector);

        if (eReq.switchboardId != switchboardId) return (false, InvalidSwitchboard.selector);

        // Check if the fulfilment was done correctly.
        // Check if the request was fulfilled: output token
        if (eReq.promisedAmount > fulfilledAmount) return (false, PromisedAmountNotMet.selector);

        // track the beneficiary amount to be settled
        /// @dev eReq.amount is net amount after affiliate fees
        beneficiarySettlements[eReq.beneficiary][eReq.router][eReq.token] += eReq.amount;

        // Delete the origin execution.
        delete $.extractedRequests[requestHash];

        // Unlock locked fee if any
        FEE_COLLECTOR.settleFee(requestHash);

        // Emits Settlement event
        emit RequestSettled(requestHash);

        return (true, bytes4(0));
    }

    /**
     * @notice Validates and withdraws a request
     * @dev Refunds locked fee if any
     * @dev Asks router to transfer funds back to the user
     * @dev Deletes the origin execution
     * @dev Tracks the withdrawn request info
     * @param requestHash hash of the request to be withdrawn
     */
    function _validateAndWithdrawRequest(bytes32 requestHash) internal {
        SingleOutputRequestImplStorage storage $ = _getSingleOutputRequestImplStorage();
        ExtractedRequest memory eReq = $.extractedRequests[requestHash];
        // Check if the request is valid.
        if (eReq.sender == address(0)) revert InvalidRequest();

        // Stores WithdrawnRequest
        _withdrawnRequests[requestHash] = WithdrawnRequest({
            token: eReq.token,
            amount: eReq.amount,
            receiver: eReq.sender
        });

        // Delete the origin execution
        delete $.extractedRequests[requestHash];

        // Refund locked fee if any
        FEE_COLLECTOR.refundFee(requestHash, eReq.sender);

        // Ask router to transfer funds back to the user
        /// @dev eReq.amount is net amount after affiliate fees
        IBaseRouter(eReq.router).releaseFunds(eReq.token, eReq.amount, eReq.sender);

        // Emits Cancellation event
        emit RequestCancelled(requestHash, eReq.token, eReq.amount, eReq.sender);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                DESTINATION FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @notice Performs fulfilment of a batch of requests
     * @dev Called by transmitter to fulfil a request
     * @dev Calculates and tracks destination hash of fulfilled requests
     * @dev Can fulfil a batch of requests
     * @dev Checks if provided router contract is registered with Bungee protocol
     * @param fulfilExecs Array of FulfilExec
     */
    function fulfilRequests(FulfilExec[] calldata fulfilExecs) external payable {
        // Will be used to check if the msg value was sufficient at the end.
        uint256 nativeAmount = 0;

        // Iterate through the array of fulfil execs.
        for (uint256 i = 0; i < fulfilExecs.length; i++) {
            FulfilExec memory fulfilExec = fulfilExecs[i];

            // Calculate the request hash. Being tracked on singleOutputFulfilledRequests
            bytes32 requestHash = fulfilExec.request.hashDestinationRequest();

            // 1.a Allow fulfil only if the request is pending
            SingleOutputRequestImplStorage storage $ = _getSingleOutputRequestImplStorage();
            if ($.fulfilledRequests[requestHash].status != 0) revert RequestProcessed();

            // 1.b Check if the provided router address is part of the Bungee protocol
            if (!isBungeeRouter(fulfilExec.fulfilRouter)) revert RouterNotRegistered();

            // 1.c Check if promisedOutput amounts are more than minOutput amounts
            if (fulfilExec.fulfilAmount < fulfilExec.request.basicReq.minOutputAmount) revert MinOutputNotMet();

            // 2. Call the fulfil function on the router
            IBaseRouter(fulfilExec.fulfilRouter).fulfil{value: fulfilExec.msgValue}(
                requestHash,
                fulfilExec,
                msg.sender
            );

            nativeAmount += fulfilExec.msgValue;

            // 3. BungeeGateway stores the fulfilment details with status as Fulfilled
            $.fulfilledRequests[requestHash] = FulfilledRequest({fulfilledAmount: fulfilExec.fulfilAmount, status: 3});

            // Emits Fulfilment Event
            emit RequestFulfilled(requestHash, SINGLE_OUTPUT_IMPL_ID, msg.sender, abi.encode(fulfilExec));

            // 4. calldata execution via Calldata Executor using Request.destinationPayload, Request.minDestGas
            _executeCalldataSingleOutput(
                fulfilExec.request.basicReq.receiver,
                fulfilExec.request.minDestGas,
                fulfilExec.request.destinationPayload,
                requestHash,
                fulfilExec.fulfilAmount,
                fulfilExec.request.basicReq.outputToken
            );
        }

        if (msg.value < nativeAmount) revert InsufficientNativeAmount();
    }

    /**
     * @notice Sends a settlement message back towards source to settle the requests.
     * @param requestHashes Array of request hashes to be settled.
     * @param gasLimit Gas limit to be used on the message receiving chain.
     * @param chainSlug Chain slug used in Socket to send the message towards i.e, source chain id
     * @param switchboardId id of the switchboard to use. switchboardIds of all requests in the batch must match
     */
    function settleRequests(
        bytes32[] calldata requestHashes,
        uint256 gasLimit,
        uint32 chainSlug,
        uint32 switchboardId
    ) external payable {
        // Create an empty array of fulfilled amounts.
        /// @dev fulfilledAmounts would be output token fulfilled for each request in the batch. hence a 1d array
        uint256[] memory fulfilledAmounts = new uint256[](requestHashes.length);

        // Loop through the requestHashes and set fulfilled amounts
        SingleOutputRequestImplStorage storage $ = _getSingleOutputRequestImplStorage();
        unchecked {
            for (uint256 i = 0; i < requestHashes.length; i++) {
                FulfilledRequest memory fReq = $.fulfilledRequests[requestHashes[i]];

                // Allow settle only if the request is fulfilled
                if (fReq.status != 3) revert RequestNotProcessed();

                // Get the amount send to the receiver of the request and push into array
                fulfilledAmounts[i] = fReq.fulfilledAmount;
            }
        }

        // Call the switchboard router to  send the message.
        SWITCHBOARD_ROUTER.sendOutboundMsg{value: msg.value}(
            chainSlug,
            switchboardId,
            SINGLE_OUTPUT_IMPL_ID,
            gasLimit,
            abi.encode(requestHashes, fulfilledAmounts)
        );

        emit RequestsSettledOnDestination(requestHashes, SINGLE_OUTPUT_IMPL_ID, msg.sender, msg.value);
    }

    /**
     * @notice Initiates cancellation of request on destination
     * @dev When a request is not fulfilled by the transmitter on the destination chain,
     *      the user can initiate cancellation of the request
     * @dev This sends a cancellation message back to the originChain where the funds are released back to the user
     * @param request Request signed by the user
     * @param gasLimit gasLimit required to execute the cancelled
     */
    function cancelRequest(Request calldata request, uint256 gasLimit) external payable {
        // generate the requestHash
        bytes32 requestHash = request.hashDestinationRequest();

        // checks if the caller is the delegate
        if (msg.sender != request.basicReq.delegate && !hasRole(CANCEL_ROLE, msg.sender)) revert CallerNotDelegate();

        // Allow cancel only if request is pending
        SingleOutputRequestImplStorage storage $ = _getSingleOutputRequestImplStorage();
        if ($.fulfilledRequests[requestHash].status != 0) revert RequestProcessed();

        // mark request as cancelled
        $.fulfilledRequests[requestHash] = FulfilledRequest({fulfilledAmount: 0, status: 1});

        // prepare payload
        bytes32[] memory requestHashes = new bytes32[](1);
        requestHashes[0] = requestHash;
        /// @dev cancellation is detected by 0 fulfilledAmount
        uint256[] memory fulfilledAmounts = new uint256[](1);
        fulfilledAmounts[0] = 0;

        // call the switchboard router with the cancellation payload
        SWITCHBOARD_ROUTER.sendOutboundMsg{value: msg.value}(
            uint32(request.basicReq.originChainId),
            request.basicReq.switchboardId,
            SINGLE_OUTPUT_IMPL_ID,
            gasLimit,
            abi.encode(requestHashes, fulfilledAmounts)
        );

        emit RequestCancelledOnDestination(requestHash, SINGLE_OUTPUT_IMPL_ID, msg.sender, msg.value);
    }

    /**
     * @notice Withdraws the request on the destination chain
     * @dev Depends on the router to support this functionality eg. CCTPRouter
     * @param router Router contract address
     * @param request Request signed by the user
     * @param withdrawRequestData Data required to withdraw the request
     */
    function withdrawRequestOnDestination(
        address router,
        Request calldata request,
        bytes calldata withdrawRequestData
    ) external payable {
        // check router is in system
        if (!isBungeeRouter(router)) revert RouterNotRegistered();

        // generate the requestHash
        bytes32 requestHash = request.hashDestinationRequest();

        // checks if the caller is the delegate
        if (msg.sender != request.basicReq.delegate) revert CallerNotDelegate();

        // Allow withdraw on destination only if the request is pending or cancelled
        /// @dev allowing withdraw on destination after cancellation, because not all routers support cancellation
        SingleOutputRequestImplStorage storage $ = _getSingleOutputRequestImplStorage();
        if ($.fulfilledRequests[requestHash].status > 1) revert RequestProcessed();

        // mark request as withdrawn on destination
        $.fulfilledRequests[requestHash] = FulfilledRequest({fulfilledAmount: 0, status: 2});

        /// @dev router should know if the request hash is not supposed to be handled by it
        IBaseRouter(router).withdrawRequestOnDestination(request, withdrawRequestData);
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

interface IBaseRouter {
    function releaseFunds(address token, uint256 amount, address recipient) external;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;
import {IBaseRouter} from "./IBaseRouter.sol";
import {FulfilExec, ExtractExec, Request} from "../common/SingleOutputStructs.sol";

interface IBaseRouterSingleOutput is IBaseRouter {
    function execute(
        bytes32 requestHash,
        address receiverContract,
        ExtractExec memory exec
    ) external returns (uint256 extractedAmount, address extractedToken);

    function fulfil(bytes32 requestHash, FulfilExec calldata fulfilExec, address transmitter) external payable;

    function withdrawRequestOnDestination(Request calldata request, bytes calldata withdrawRequestData) external;
}
// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.19;

interface IBungeeExecutor {
    function executeData(
        bytes32 requestHash,
        uint256[] calldata amounts,
        address[] calldata tokens,
        bytes memory callData
    ) external payable;
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
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

// Library to authenticate the signer address.
library AuthenticationLib {
    /// @notice authenticate a message hash signed by Bungee Protocol
    /// @param messageHash hash of the message
    /// @param signature signature of the message
    /// @return true if signature is valid
    function authenticate(bytes32 messageHash, bytes memory signature) internal pure returns (address) {
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
        return recoverSigner(ethSignedMessageHash, signature);
    }

    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32) {
        /*
        Signature is produced by signing a keccak256 hash with the following format:
        "\x19Ethereum Signed Message\n" + len(msg) + msg
        */
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
    }

    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature) public pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig) public pure returns (bytes32 r, bytes32 s, uint8 v) {
        require(sig.length == 65, "invalid signature length");
        assembly {
            /*
            First 32 bytes stores the length of the signature

            add(sig, 32) = pointer of sig + 32
            effectively, skips first 32 bytes of signature

            mload(p) loads next 32 bytes starting at the memory address p into memory
            */

            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        // implicitly return (r, s, v)
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

import {Ownable} from "../utils/Ownable.sol";
import {RescueFundsLib} from "../lib/RescueFundsLib.sol";
import {SafeTransferLib} from "solady/src/utils/SafeTransferLib.sol";
import {AuthenticationLib} from "./../lib/AuthenticationLib.sol";
import {CurrencyLib} from "./../lib/CurrencyLib.sol";
import {BungeeGateway} from "../core/BungeeGateway.sol";
import {FulfilExec as SingleOutputFulfilExec, SingleOutputRequestImpl} from "../core/SingleOutputRequestImpl.sol";

contract Solver is Ownable {
    struct Action {
        address target;
        uint256 value;
        bytes data;
    }

    struct SwapAction {
        uint256 fulfilExecIndex;
        Action swapActionData;
    }

    // @todo standardize errors
    error ActionFailed();
    error ActionsFailed(uint256 index);
    error InvalidSigner();
    error InvalidNonce();
    error InvalidSwapActions();
    error SwapActionFailed(uint256 index);
    error SwapOutputInsufficient(uint256 index);
    error TransferFailed();
    error InvalidCaller();

    uint8 public constant SINGLE_OUTPUT_IMPL_ID = 1;
    uint8 public constant SWAP_REQUEST_IMPL_ID = 2;

    address public constant NATIVE_TOKEN_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    /// @notice address of the signer
    address internal SOLVER_SIGNER;

    /// @notice mapping to track used nonces of SOLVER_SIGNER
    mapping(uint256 nonce => bool isNonceUsed) public nonceUsed;

    /**
     * @notice Constructor.
     * @param _owner address of the contract owner
     * @param _solverSigner address of the signer
     */
    constructor(address _owner, address _solverSigner) Ownable(_owner) {
        SOLVER_SIGNER = _solverSigner;
    }

    function setSolverSigner(address _solverSigner) external onlyOwner {
        SOLVER_SIGNER = _solverSigner;
    }

    /// @dev separate specific functions for extract, fulfil, settle
    /// so that easier to index and track costs
    function performExtraction(uint256 nonce, Action calldata action, bytes calldata signature) external {
        // @todo assembly encode and hash - can look at solady
        verifySignature(keccak256(abi.encode(block.chainid, address(this), nonce, action)), signature);

        // verify nonce
        assembly {
            // load data slot from mapping
            mstore(0, nonce)
            mstore(0x20, nonceUsed.slot)
            let dataSlot := keccak256(0, 0x40)

            // check if nonce is used
            if and(sload(dataSlot), 0xff) {
                mstore(0x00, 0x756688fe) // revert InvalidNonce();
                revert(0x1c, 0x04)
            }

            // if not used mark as used
            /// @dev not cleaning all the bits, just setting the first bit to 1
            sstore(dataSlot, 0x01)
        }

        /// @dev no need for approvals in extraction

        bool success = _performAction(action);
        assembly {
            /// @dev not cleaning all the bits, just using success as is
            if iszero(success) {
                mstore(0x00, 0x080a1c27) // revert ActionFailed();
                revert(0x1c, 0x04)
            }
        }
    }

    function performSettlement(uint256 nonce, Action calldata action, bytes calldata signature) external {
        verifySignature(keccak256(abi.encode(block.chainid, address(this), nonce, action)), signature);

        // verify nonce
        assembly {
            // load data slot from mapping
            mstore(0, nonce)
            mstore(0x20, nonceUsed.slot)
            let dataSlot := keccak256(0, 0x40)

            // check if nonce is used
            if and(sload(dataSlot), 0xff) {
                mstore(0x00, 0x756688fe) // revert InvalidNonce();
                revert(0x1c, 0x04)
            }

            // if not used mark as used
            /// @dev not cleaning all the bits, just setting the first bit to 1
            sstore(dataSlot, 0x01)
        }

        /// @dev no need for approvals in settlement

        bool success = _performAction(action);
        assembly {
            /// @dev not cleaning all the bits, just using success as is
            if iszero(success) {
                mstore(0x00, 0x080a1c27) // revert ActionFailed();
                revert(0x1c, 0x04)
            }
        }
    }

    /**
     * @notice Convenience function that helps perform a destination swap and fulfil the request.
     * @dev Can be used to perform a single swap and single fulfilment
     * @dev Modifies the fulfilAmount of the fulfilExec to the received amount from the swap
     */
    function performFulfilment(
        uint256 nonce,
        bytes[] calldata approvals,
        address bungeeGateway,
        uint256 value,
        Action calldata swapActionData,
        SingleOutputFulfilExec memory fulfilExec,
        bytes calldata signature
    ) external {
        verifySignature(
            keccak256(
                abi.encode(
                    block.chainid,
                    address(this),
                    nonce,
                    approvals,
                    bungeeGateway,
                    value,
                    swapActionData,
                    fulfilExec
                )
            ),
            signature
        );

        // verify nonce
        assembly {
            // load data slot from mapping
            mstore(0, nonce)
            mstore(0x20, nonceUsed.slot)
            let dataSlot := keccak256(0, 0x40)

            // check if nonce is used
            if and(sload(dataSlot), 0xff) {
                mstore(0x00, 0x756688fe) // revert InvalidNonce();
                revert(0x1c, 0x04)
            }

            // if not used mark as used
            /// @dev not cleaning all the bits, just setting the first bit to 1
            sstore(dataSlot, 0x01)
        }

        // _setApprovals(approvals);
        if (approvals.length > 0) {
            for (uint256 i = 0; i < approvals.length; i++) {
                // @todo assembly
                (address token, address spender, uint256 amount) = abi.decode(
                    approvals[i],
                    (address, address, uint256)
                );
                SafeTransferLib.safeApprove(token, spender, amount);
            }
        }

        if (swapActionData.target != address(0)) {
            // check pre balance
            // @todo assembly
            bool isNativeToken = fulfilExec.request.basicReq.outputToken == NATIVE_TOKEN_ADDRESS;
            uint256 beforeBalance = CurrencyLib.balanceOf(fulfilExec.request.basicReq.outputToken, address(this));

            // Perform swap action
            bool success = _performAction(swapActionData);
            if (!success) {
                // @todo replace with assembly
                revert SwapActionFailed(0);
            }

            // check post balance
            uint256 swapActionOutput = CurrencyLib.balanceOf(fulfilExec.request.basicReq.outputToken, address(this)) -
                beforeBalance;
            if (fulfilExec.fulfilAmount > swapActionOutput) {
                revert SwapOutputInsufficient(0);
            }

            // Overwrite the fulfilAmount with the received amount
            fulfilExec.fulfilAmount = swapActionOutput;
            // also update fulfilExec.msgValue & value sent to gateway if native token
            if (isNativeToken) {
                fulfilExec.msgValue = swapActionOutput;
                value = swapActionOutput;
            }
        }

        // perform fulfilment
        SingleOutputFulfilExec[] memory fulfilExecs = new SingleOutputFulfilExec[](1);
        fulfilExecs[0] = fulfilExec;
        BungeeGateway(payable(bungeeGateway)).executeImpl{value: value}(
            SINGLE_OUTPUT_IMPL_ID,
            abi.encodeCall(SingleOutputRequestImpl.fulfilRequests, (fulfilExecs))
        );
    }

    /**
     * @notice Convenience function that helps perform a destination swap and fulfil the request.
     * @dev Can be used to perform a batch of (swap & fulfilment)
     * @dev Modifies the fulfilAmounts of each fulfilExecs to the received amount from the swap
     */
    function performBatchFulfilment(
        uint256 nonce,
        bytes[] calldata approvals,
        address bungeeGateway,
        uint256 value,
        SwapAction[] calldata swapActions,
        SingleOutputFulfilExec[] memory fulfilExecs,
        bytes calldata signature
    ) external {
        verifySignature(
            keccak256(
                abi.encode(
                    block.chainid,
                    address(this),
                    nonce,
                    approvals,
                    bungeeGateway,
                    value,
                    swapActions,
                    fulfilExecs
                )
            ),
            signature
        );

        // verify nonce
        assembly {
            // load data slot from mapping
            mstore(0, nonce)
            mstore(0x20, nonceUsed.slot)
            let dataSlot := keccak256(0, 0x40)

            // check if nonce is used
            if and(sload(dataSlot), 0xff) {
                mstore(0x00, 0x756688fe) // revert InvalidNonce();
                revert(0x1c, 0x04)
            }

            // if not used mark as used
            /// @dev not cleaning all the bits, just setting the first bit to 1
            sstore(dataSlot, 0x01)
        }

        // _setApprovals(approvals);
        if (approvals.length > 0) {
            for (uint256 i = 0; i < approvals.length; i++) {
                (address token, address spender, uint256 amount) = abi.decode(
                    approvals[i],
                    (address, address, uint256)
                );
                SafeTransferLib.safeApprove(token, spender, amount);
            }
        }

        // if there are swap actions, they should be equal to the number of fulfilExecs
        assembly {
            // if (swapActions.length > 0 && swapActions.length != fulfilExecs.length)
            if and(
                gt(swapActions.length, 0),
                iszero(
                    eq(
                        swapActions.length, // swapActions is calldata
                        mload(fulfilExecs) // fulfilExecs is memory
                    )
                )
            ) {
                mstore(0x00, 0x91433bb2) // revert InvalidSwapActions()
                revert(0x1c, 0x04)
            }
        }

        for (uint256 i = 0; i < swapActions.length; i++) {
            SwapAction calldata swapAction = swapActions[i];

            // check pre balance
            bool isNativeToken = fulfilExecs[swapAction.fulfilExecIndex].request.basicReq.outputToken ==
                NATIVE_TOKEN_ADDRESS;
            uint256 beforeBalance = CurrencyLib.balanceOf(
                fulfilExecs[swapAction.fulfilExecIndex].request.basicReq.outputToken,
                address(this)
            );

            // Perform swap action
            bool success = _performAction(swapAction.swapActionData);
            if (!success) {
                revert SwapActionFailed(i);
            }

            // check post balance
            uint256 swapActionOutput = CurrencyLib.balanceOf(
                fulfilExecs[swapAction.fulfilExecIndex].request.basicReq.outputToken,
                address(this)
            ) - beforeBalance;
            if (fulfilExecs[swapAction.fulfilExecIndex].fulfilAmount > swapActionOutput) {
                revert SwapOutputInsufficient(i);
            }

            // Overwrite the fulfilAmount with the received amount
            fulfilExecs[swapAction.fulfilExecIndex].fulfilAmount = swapActionOutput;
            // also update fulfilExec.msgValue & value sent to gateway if native token
            if (isNativeToken) {
                // update total value based on the difference bw old and new balance
                value = value + (swapActionOutput - fulfilExecs[swapAction.fulfilExecIndex].msgValue); // new value - old value
                fulfilExecs[swapAction.fulfilExecIndex].msgValue = fulfilExecs[swapAction.fulfilExecIndex].fulfilAmount;
            }
        }

        // perform fulfilment
        BungeeGateway(payable(bungeeGateway)).executeImpl{value: value}(
            SINGLE_OUTPUT_IMPL_ID,
            abi.encodeCall(SingleOutputRequestImpl.fulfilRequests, (fulfilExecs))
        );
    }

    function performActions(
        uint256 nonce,
        bytes[] calldata approvals,
        Action[] calldata actions,
        bytes calldata signature
    ) external {
        verifySignature(keccak256(abi.encode(block.chainid, address(this), nonce, approvals, actions)), signature);

        // verify nonce
        assembly {
            // load data slot from mapping
            mstore(0, nonce)
            mstore(0x20, nonceUsed.slot)
            let dataSlot := keccak256(0, 0x40)

            // check if nonce is used
            if and(sload(dataSlot), 0xff) {
                mstore(0x00, 0x756688fe) // revert InvalidNonce();
                revert(0x1c, 0x04)
            }

            // if not used mark as used
            /// @dev not cleaning all the bits, just setting the first bit to 1
            sstore(dataSlot, 0x01)
        }

        // _setApprovals(approvals);
        if (approvals.length > 0) {
            for (uint256 i = 0; i < approvals.length; i++) {
                (address token, address spender, uint256 amount) = abi.decode(
                    approvals[i],
                    (address, address, uint256)
                );
                SafeTransferLib.safeApprove(token, spender, amount);
            }
        }

        for (uint256 i = 0; i < actions.length; i++) {
            bool success = _performAction(actions[i]);
            if (!success) {
                // TODO: should we bubble up the revert reasons? slightly hard to debug. need to run the txn with traces
                revert ActionsFailed(i);
            }
        }
    }

    /// @dev Does not revert on failure. Caller should check the return value.
    function _performAction(Action calldata action) internal returns (bool success) {
        assembly {
            // Load the data offset and length from the calldata
            let action_dataLength := calldataload(add(action, 96))

            // load calldata to memory to use for call()
            let freeMemPtr := mload(64)
            calldatacopy(
                freeMemPtr,
                add(
                    add(action, 32),
                    calldataload(add(action, 64)) // action_dataOffset - offset of action.data data part
                ), // action_dataStart - start of action.data data part
                action_dataLength
            )

            // Perform the call
            success := call(
                gas(), // Forward all available gas
                calldataload(action), // Target address - first 32 bytes starting from action offset
                calldataload(add(action, 32)), // call value to send - second 32 bytes starting from action offset
                freeMemPtr, // Input data start
                action_dataLength, // Input data length
                0, // Output data start (not needed)
                0 // Output data length (not needed)
            )
        }
    }

    function verifySignature(bytes32 messageHash, bytes calldata signature) public view {
        if (!(SOLVER_SIGNER == AuthenticationLib.authenticate(messageHash, signature))) {
            assembly {
                mstore(0x00, 0x815e1d64) // revert InvalidSigner();
                revert(0x1c, 0x04)
            }
        }
    }

    /*//////////////////////////////////////////////////////////////
                            ADMIN FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Rescues funds from the contract if they are locked by mistake.
     * @param token_ The address of the token contract.
     * @param rescueTo_ The address where rescued tokens need to be sent.
     * @param amount_ The amount of tokens to be rescued.
     */
    function rescueFunds(address token_, address rescueTo_, uint256 amount_) external onlyOwner {
        RescueFundsLib.rescueFunds(token_, rescueTo_, amount_);
    }

    /*//////////////////////////////////////////////////////////////
                             RECEIVE ETHER
    //////////////////////////////////////////////////////////////*/

    receive() external payable {}

    fallback() external payable {}
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