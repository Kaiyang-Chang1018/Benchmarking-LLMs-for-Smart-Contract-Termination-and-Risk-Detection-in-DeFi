// SPDX-License-Identifier: GPL-3.0-only
pragma solidity =0.8.24;

/// @title IERC7683
/// @notice Standard type definitions for ERC-7683 compliant settlement contracts
/// @dev See https://github.com/ethereum/ERCs/blob/master/ERCS/erc-7683.md
interface IERC7683 {
    /// @notice Signals that an order has been opened
    /// @param orderId a unique order identifier within this settlement system
    /// @param resolvedOrder resolved order that would be returned by resolve if called instead of Open
    event Open(bytes32 indexed orderId, ResolvedCrossChainOrder resolvedOrder);

    /// @title GaslessCrossChainOrder CrossChainOrder type
    /// @notice Standard order struct to be signed by users, disseminated to fillers, and submitted to origin settler contracts
    struct GaslessCrossChainOrder {
        /// @dev The contract address that the order is meant to be settled by.
        /// Fillers send this order to this contract address on the origin chain
        address originSettler;
        /// @dev The address of the user who is initiating the swap,
        /// whose input tokens will be taken and escrowed
        address user;
        /// @dev Nonce to be used as replay protection for the order
        uint256 nonce;
        /// @dev The chainId of the origin chain
        uint256 originChainId;
        /// @dev The timestamp by which the order must be opened
        uint32 openDeadline;
        /// @dev The timestamp by which the order must be filled on the destination chain
        uint32 fillDeadline;
        /// @dev Type identifier for the order data. This is an EIP-712 typehash.
        bytes32 orderDataType;
        /// @dev Arbitrary implementation-specific data
        /// Can be used to define tokens, amounts, destination chains, fees, settlement parameters,
        /// or any other order-type specific information
        bytes orderData;
    }

    /// @title OnchainCrossChainOrder CrossChainOrder type
    /// @notice Standard order struct for user-opened orders, where the user is the msg.sender.
    struct OnchainCrossChainOrder {
        /// @dev The timestamp by which the order must be filled on the destination chain
        uint32 fillDeadline;
        /// @dev Type identifier for the order data. This is an EIP-712 typehash.
        bytes32 orderDataType;
        /// @dev Arbitrary implementation-specific data
        /// Can be used to define tokens, amounts, destination chains, fees, settlement parameters,
        /// or any other order-type specific information
        bytes orderData;
    }

    /// @title ResolvedCrossChainOrder type
    /// @notice An implementation-generic representation of an order intended for filler consumption
    /// @dev Defines all requirements for filling an order by unbundling the implementation-specific orderData.
    /// @dev Intended to improve integration generalization by allowing fillers to compute the exact input and output information of any order
    struct ResolvedCrossChainOrder {
        /// @dev The address of the user who is initiating the transfer
        address user;
        /// @dev The chainId of the origin chain
        uint256 originChainId;
        /// @dev The timestamp by which the order must be opened
        uint32 openDeadline;
        /// @dev The timestamp by which the order must be filled on the destination chain(s)
        uint32 fillDeadline;
        /// @dev The unique identifier for this order within this settlement system
        bytes32 orderId;
        /// @dev The max outputs that the filler will send. It's possible the actual amount depends on the state of the destination
        ///      chain (destination dutch auction, for instance), so these outputs should be considered a cap on filler liabilities.
        Output[] maxSpent;
        /// @dev The minimum outputs that must to be given to the filler as part of order settlement. Similar to maxSpent, it's possible
        ///      that special order types may not be able to guarantee the exact amount at open time, so this should be considered
        ///      a floor on filler receipts.
        Output[] minReceived;
        /// @dev Each instruction in this array is parameterizes a single leg of the fill. This provides the filler with the information
        ///      necessary to perform the fill on the destination(s).
        FillInstruction[] fillInstructions;
    }

    /// @notice Tokens that must be receive for a valid order fulfillment
    struct Output {
        /// @dev The address of the ERC20 token on the destination chain
        /// @dev address(0) used as a sentinel for the native token
        bytes32 token;
        /// @dev The amount of the token to be sent
        uint256 amount;
        /// @dev The address to receive the output tokens
        bytes32 recipient;
        /// @dev The destination chain for this output
        uint256 chainId;
    }

    /// @title FillInstruction type
    /// @notice Instructions to parameterize each leg of the fill
    /// @dev Provides all the origin-generated information required to produce a valid fill leg
    struct FillInstruction {
        /// @dev The contract address that the order is meant to be settled by
        uint64 destinationChainId;
        /// @dev The contract address that the order is meant to be filled on
        bytes32 destinationSettler;
        /// @dev The data generated on the origin chain needed by the destinationSettler to process the fill
        bytes originData;
    }
}
// SPDX-License-Identifier: GPL-3.0-only
pragma solidity =0.8.24;

import { IERC7683 } from "./IERC7683.sol";

/// @title IOriginSettler
/// @notice Standard interface for settlement contracts on the origin chain
/// @dev See https://github.com/ethereum/ERCs/blob/master/ERCS/erc-7683.md
interface IOriginSettler is IERC7683 {
    /// @notice Opens a gasless cross-chain order on behalf of a user.
    /// @dev To be called by the filler.
    /// @dev This method must emit the Open event
    /// @param order The GaslessCrossChainOrder definition
    /// @param signature The user's signature over the order
    /// @param originFillerData Any filler-defined data required by the settler
    // function openFor(GaslessCrossChainOrder calldata order, bytes calldata signature, bytes calldata originFillerData) external;

    /// @notice Opens a cross-chain order
    /// @dev To be called by the user
    /// @dev This method must emit the Open event
    /// @param order The OnchainCrossChainOrder definition
    function open(OnchainCrossChainOrder calldata order) external payable;

    /// @notice Resolves a specific GaslessCrossChainOrder into a generic ResolvedCrossChainOrder
    /// @dev Intended to improve standardized integration of various order types and settlement contracts
    /// @param order The GaslessCrossChainOrder definition
    /// @param originFillerData Any filler-defined data required by the settler
    /// @return ResolvedCrossChainOrder hydrated order data including the inputs and outputs of the order
    // function resolveFor(GaslessCrossChainOrder calldata order, bytes calldata originFillerData) external view returns (ResolvedCrossChainOrder memory);

    /// @notice Resolves a specific OnchainCrossChainOrder into a generic ResolvedCrossChainOrder
    /// @dev Intended to improve standardized integration of various order types and settlement contracts
    /// @param order The OnchainCrossChainOrder definition
    /// @return ResolvedCrossChainOrder hydrated order data including the inputs and outputs of the order
    function resolve(OnchainCrossChainOrder calldata order) external view returns (ResolvedCrossChainOrder memory);
}
// SPDX-License-Identifier: GPL-3.0-only
pragma solidity =0.8.24;

library SolverNet {
    /**
     * @notice OrderData is the SolverNet's ERC7683 order data encoding, used when opening an order.
     *  It describes the calls to execute, the expenses required, and the deposit backing the order.
     *
     *  Note that expenses only includes ERC20 expenses, native expenses are inferred from the calls.
     *  This reduces the order data size, saving gas.
     *
     *  Order expenses (both token expenses and required call values) should be exact. If expenses are underestimated,
     *  the order will be rejected. If expenses are overestimated, the excess will be refunded to the solver.
     *
     *  Order deposits must cover expenses + solver fees. If they do not, the order will be rejected. To
     *  determine required deposits, use Omni's solver /quote API, or Omni's SolverNet SDK. (TODO link to docs)
     *
     * @custom:field owner          The address that can close the order. Defaults to msg.sender if zero.
     * @custom:field destChainId    The chain on which to execute calls.
     * @custom:field deposit        The deposit paid by the user on the source chain when opening the order.
     * @custom:field calls          The calls to be executed on the destination chain.
     * @custom:field expenses       The token expenses required to fill the order, paid by the solver.
     */
    struct OrderData {
        address owner;
        uint64 destChainId;
        Deposit deposit;
        Call[] calls;
        TokenExpense[] expenses;
    }

    /**
     * @notice Order is a convenience struct that fully describes an order.
     * @dev It is not written to storage, but rather built on view.
     */
    struct Order {
        Header header;
        Deposit deposit;
        Call[] calls;
        TokenExpense[] expenses;
    }

    /**
     * @notice Header is an "order header", containing order data not related to deposit, calls, or expenses.
     * @dev This struct is used to pack loose order data fields into a single slot.
     */
    struct Header {
        address owner;
        uint64 destChainId;
        uint32 fillDeadline;
    }

    /**
     * @notice Deposit describes a deposit (native or ERC20) paid by the user on the source chain when opening an order.
     * @custom:field token   The address of the token, address(0) if native.
     * @custom:field amount  The amount of the token deposited.
     */
    struct Deposit {
        address token;
        uint96 amount;
    }

    /**
     * @notice Call describes a call to execute.
     *  If the call is a native transfer, `target` is the recipient address, and `selector` / `params` are empty.
     * @dev Full call data is built from `selector` and `params`: abi.encodePacked(call.selector, call.params).
     * @custom:field target    The address to execute the call against
     * @custom:field selector  The function selector to call
     * @custom:field value     The amount of native token to send with the call
     * @custom:field params    The call parameters
     */
    struct Call {
        address target;
        bytes4 selector;
        uint256 value;
        bytes params;
    }

    /**
     * @notice TokenExpense describes an ERC20 expense to be paid by the solver on destination chain when filling an
     *  order. Native expenses are inferred from the calls, and are not included in the order data.
     * @custom:field spender  The address that will do token.transferFrom(...) on fill. Required to set allowance.
     * @custom:field token    The address of the token on the destination chain.
     * @custom:field amount   The amount of the token to be spent.
     */
    struct TokenExpense {
        address spender;
        address token;
        uint96 amount;
    }

    /**
     * @notice FillOriginData is the SolverNet's ERC7683 fill instruction data encoding, used when filling an order.
     * @dev The hash(orderId, fillOriginData) is used to prove that a solver properly filled an order.
     * @custom:field srcChainId     The chain on which the order was opened.
     * @custom:field destChainId    The chain on which to execute calls.
     * @custom:field fillDeadline   The deadline by which the order must be filled.
     * @custom:field calls          The calls to execute on the destination chain.
     * @custom:field expenses       The token expenses required to fill the order, paid by the solver.
     */
    struct FillOriginData {
        uint64 srcChainId;
        uint64 destChainId;
        uint32 fillDeadline;
        Call[] calls;
        TokenExpense[] expenses;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Simple single owner authorization mixin.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/auth/Ownable.sol)
///
/// @dev Note:
/// This implementation does NOT auto-initialize the owner to `msg.sender`.
/// You MUST call the `_initializeOwner` in the constructor / initializer.
///
/// While the ownable portion follows
/// [EIP-173](https://eips.ethereum.org/EIPS/eip-173) for compatibility,
/// the nomenclature for the 2-step ownership handover may be unique to this codebase.
abstract contract Ownable {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       CUSTOM ERRORS                        */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The caller is not authorized to call the function.
    error Unauthorized();

    /// @dev The `newOwner` cannot be the zero address.
    error NewOwnerIsZeroAddress();

    /// @dev The `pendingOwner` does not have a valid handover request.
    error NoHandoverRequest();

    /// @dev Cannot double-initialize.
    error AlreadyInitialized();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                           EVENTS                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The ownership is transferred from `oldOwner` to `newOwner`.
    /// This event is intentionally kept the same as OpenZeppelin's Ownable to be
    /// compatible with indexers and [EIP-173](https://eips.ethereum.org/EIPS/eip-173),
    /// despite it not being as lightweight as a single argument event.
    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);

    /// @dev An ownership handover to `pendingOwner` has been requested.
    event OwnershipHandoverRequested(address indexed pendingOwner);

    /// @dev The ownership handover to `pendingOwner` has been canceled.
    event OwnershipHandoverCanceled(address indexed pendingOwner);

    /// @dev `keccak256(bytes("OwnershipTransferred(address,address)"))`.
    uint256 private constant _OWNERSHIP_TRANSFERRED_EVENT_SIGNATURE =
        0x8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e0;

    /// @dev `keccak256(bytes("OwnershipHandoverRequested(address)"))`.
    uint256 private constant _OWNERSHIP_HANDOVER_REQUESTED_EVENT_SIGNATURE =
        0xdbf36a107da19e49527a7176a1babf963b4b0ff8cde35ee35d6cd8f1f9ac7e1d;

    /// @dev `keccak256(bytes("OwnershipHandoverCanceled(address)"))`.
    uint256 private constant _OWNERSHIP_HANDOVER_CANCELED_EVENT_SIGNATURE =
        0xfa7b8eab7da67f412cc9575ed43464468f9bfbae89d1675917346ca6d8fe3c92;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                          STORAGE                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The owner slot is given by:
    /// `bytes32(~uint256(uint32(bytes4(keccak256("_OWNER_SLOT_NOT")))))`.
    /// It is intentionally chosen to be a high value
    /// to avoid collision with lower slots.
    /// The choice of manual storage layout is to enable compatibility
    /// with both regular and upgradeable contracts.
    bytes32 internal constant _OWNER_SLOT =
        0xffffffffffffffffffffffffffffffffffffffffffffffffffffffff74873927;

    /// The ownership handover slot of `newOwner` is given by:
    /// ```
    ///     mstore(0x00, or(shl(96, user), _HANDOVER_SLOT_SEED))
    ///     let handoverSlot := keccak256(0x00, 0x20)
    /// ```
    /// It stores the expiry timestamp of the two-step ownership handover.
    uint256 private constant _HANDOVER_SLOT_SEED = 0x389a75e1;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                     INTERNAL FUNCTIONS                     */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Override to return true to make `_initializeOwner` prevent double-initialization.
    function _guardInitializeOwner() internal pure virtual returns (bool guard) {}

    /// @dev Initializes the owner directly without authorization guard.
    /// This function must be called upon initialization,
    /// regardless of whether the contract is upgradeable or not.
    /// This is to enable generalization to both regular and upgradeable contracts,
    /// and to save gas in case the initial owner is not the caller.
    /// For performance reasons, this function will not check if there
    /// is an existing owner.
    function _initializeOwner(address newOwner) internal virtual {
        if (_guardInitializeOwner()) {
            /// @solidity memory-safe-assembly
            assembly {
                let ownerSlot := _OWNER_SLOT
                if sload(ownerSlot) {
                    mstore(0x00, 0x0dc149f0) // `AlreadyInitialized()`.
                    revert(0x1c, 0x04)
                }
                // Clean the upper 96 bits.
                newOwner := shr(96, shl(96, newOwner))
                // Store the new value.
                sstore(ownerSlot, or(newOwner, shl(255, iszero(newOwner))))
                // Emit the {OwnershipTransferred} event.
                log3(0, 0, _OWNERSHIP_TRANSFERRED_EVENT_SIGNATURE, 0, newOwner)
            }
        } else {
            /// @solidity memory-safe-assembly
            assembly {
                // Clean the upper 96 bits.
                newOwner := shr(96, shl(96, newOwner))
                // Store the new value.
                sstore(_OWNER_SLOT, newOwner)
                // Emit the {OwnershipTransferred} event.
                log3(0, 0, _OWNERSHIP_TRANSFERRED_EVENT_SIGNATURE, 0, newOwner)
            }
        }
    }

    /// @dev Sets the owner directly without authorization guard.
    function _setOwner(address newOwner) internal virtual {
        if (_guardInitializeOwner()) {
            /// @solidity memory-safe-assembly
            assembly {
                let ownerSlot := _OWNER_SLOT
                // Clean the upper 96 bits.
                newOwner := shr(96, shl(96, newOwner))
                // Emit the {OwnershipTransferred} event.
                log3(0, 0, _OWNERSHIP_TRANSFERRED_EVENT_SIGNATURE, sload(ownerSlot), newOwner)
                // Store the new value.
                sstore(ownerSlot, or(newOwner, shl(255, iszero(newOwner))))
            }
        } else {
            /// @solidity memory-safe-assembly
            assembly {
                let ownerSlot := _OWNER_SLOT
                // Clean the upper 96 bits.
                newOwner := shr(96, shl(96, newOwner))
                // Emit the {OwnershipTransferred} event.
                log3(0, 0, _OWNERSHIP_TRANSFERRED_EVENT_SIGNATURE, sload(ownerSlot), newOwner)
                // Store the new value.
                sstore(ownerSlot, newOwner)
            }
        }
    }

    /// @dev Throws if the sender is not the owner.
    function _checkOwner() internal view virtual {
        /// @solidity memory-safe-assembly
        assembly {
            // If the caller is not the stored owner, revert.
            if iszero(eq(caller(), sload(_OWNER_SLOT))) {
                mstore(0x00, 0x82b42900) // `Unauthorized()`.
                revert(0x1c, 0x04)
            }
        }
    }

    /// @dev Returns how long a two-step ownership handover is valid for in seconds.
    /// Override to return a different value if needed.
    /// Made internal to conserve bytecode. Wrap it in a public function if needed.
    function _ownershipHandoverValidFor() internal view virtual returns (uint64) {
        return 48 * 3600;
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                  PUBLIC UPDATE FUNCTIONS                   */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Allows the owner to transfer the ownership to `newOwner`.
    function transferOwnership(address newOwner) public payable virtual onlyOwner {
        /// @solidity memory-safe-assembly
        assembly {
            if iszero(shl(96, newOwner)) {
                mstore(0x00, 0x7448fbae) // `NewOwnerIsZeroAddress()`.
                revert(0x1c, 0x04)
            }
        }
        _setOwner(newOwner);
    }

    /// @dev Allows the owner to renounce their ownership.
    function renounceOwnership() public payable virtual onlyOwner {
        _setOwner(address(0));
    }

    /// @dev Request a two-step ownership handover to the caller.
    /// The request will automatically expire in 48 hours (172800 seconds) by default.
    function requestOwnershipHandover() public payable virtual {
        unchecked {
            uint256 expires = block.timestamp + _ownershipHandoverValidFor();
            /// @solidity memory-safe-assembly
            assembly {
                // Compute and set the handover slot to `expires`.
                mstore(0x0c, _HANDOVER_SLOT_SEED)
                mstore(0x00, caller())
                sstore(keccak256(0x0c, 0x20), expires)
                // Emit the {OwnershipHandoverRequested} event.
                log2(0, 0, _OWNERSHIP_HANDOVER_REQUESTED_EVENT_SIGNATURE, caller())
            }
        }
    }

    /// @dev Cancels the two-step ownership handover to the caller, if any.
    function cancelOwnershipHandover() public payable virtual {
        /// @solidity memory-safe-assembly
        assembly {
            // Compute and set the handover slot to 0.
            mstore(0x0c, _HANDOVER_SLOT_SEED)
            mstore(0x00, caller())
            sstore(keccak256(0x0c, 0x20), 0)
            // Emit the {OwnershipHandoverCanceled} event.
            log2(0, 0, _OWNERSHIP_HANDOVER_CANCELED_EVENT_SIGNATURE, caller())
        }
    }

    /// @dev Allows the owner to complete the two-step ownership handover to `pendingOwner`.
    /// Reverts if there is no existing ownership handover requested by `pendingOwner`.
    function completeOwnershipHandover(address pendingOwner) public payable virtual onlyOwner {
        /// @solidity memory-safe-assembly
        assembly {
            // Compute and set the handover slot to 0.
            mstore(0x0c, _HANDOVER_SLOT_SEED)
            mstore(0x00, pendingOwner)
            let handoverSlot := keccak256(0x0c, 0x20)
            // If the handover does not exist, or has expired.
            if gt(timestamp(), sload(handoverSlot)) {
                mstore(0x00, 0x6f5e8818) // `NoHandoverRequest()`.
                revert(0x1c, 0x04)
            }
            // Set the handover slot to 0.
            sstore(handoverSlot, 0)
        }
        _setOwner(pendingOwner);
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                   PUBLIC READ FUNCTIONS                    */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns the owner of the contract.
    function owner() public view virtual returns (address result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := sload(_OWNER_SLOT)
        }
    }

    /// @dev Returns the expiry timestamp for the two-step ownership handover to `pendingOwner`.
    function ownershipHandoverExpiresAt(address pendingOwner)
        public
        view
        virtual
        returns (uint256 result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            // Compute the handover slot.
            mstore(0x0c, _HANDOVER_SLOT_SEED)
            mstore(0x00, pendingOwner)
            // Load the handover slot.
            result := sload(keccak256(0x0c, 0x20))
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         MODIFIERS                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Marks a function as only callable by the owner.
    modifier onlyOwner() virtual {
        _checkOwner();
        _;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Contract for EIP-712 typed structured data hashing and signing.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/EIP712.sol)
/// @author Modified from Solbase (https://github.com/Sol-DAO/solbase/blob/main/src/utils/EIP712.sol)
/// @author Modified from OpenZeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/cryptography/EIP712.sol)
///
/// @dev Note, this implementation:
/// - Uses `address(this)` for the `verifyingContract` field.
/// - Does NOT use the optional EIP-712 salt.
/// - Does NOT use any EIP-712 extensions.
/// This is for simplicity and to save gas.
/// If you need to customize, please fork / modify accordingly.
abstract contract EIP712 {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                  CONSTANTS AND IMMUTABLES                  */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev `keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)")`.
    bytes32 internal constant _DOMAIN_TYPEHASH =
        0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f;

    /// @dev `keccak256("EIP712Domain(string name,string version,address verifyingContract)")`.
    /// This is only used in `_hashTypedDataSansChainId`.
    bytes32 internal constant _DOMAIN_TYPEHASH_SANS_CHAIN_ID =
        0x91ab3d17e3a50a9d89e63fd30b92be7f5336b03b287bb946787a83a9d62a2766;

    uint256 private immutable _cachedThis;
    uint256 private immutable _cachedChainId;
    bytes32 private immutable _cachedNameHash;
    bytes32 private immutable _cachedVersionHash;
    bytes32 private immutable _cachedDomainSeparator;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                        CONSTRUCTOR                         */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Cache the hashes for cheaper runtime gas costs.
    /// In the case of upgradeable contracts (i.e. proxies),
    /// or if the chain id changes due to a hard fork,
    /// the domain separator will be seamlessly calculated on-the-fly.
    constructor() {
        _cachedThis = uint256(uint160(address(this)));
        _cachedChainId = block.chainid;

        string memory name;
        string memory version;
        if (!_domainNameAndVersionMayChange()) (name, version) = _domainNameAndVersion();
        bytes32 nameHash = _domainNameAndVersionMayChange() ? bytes32(0) : keccak256(bytes(name));
        bytes32 versionHash =
            _domainNameAndVersionMayChange() ? bytes32(0) : keccak256(bytes(version));
        _cachedNameHash = nameHash;
        _cachedVersionHash = versionHash;

        bytes32 separator;
        if (!_domainNameAndVersionMayChange()) {
            /// @solidity memory-safe-assembly
            assembly {
                let m := mload(0x40) // Load the free memory pointer.
                mstore(m, _DOMAIN_TYPEHASH)
                mstore(add(m, 0x20), nameHash)
                mstore(add(m, 0x40), versionHash)
                mstore(add(m, 0x60), chainid())
                mstore(add(m, 0x80), address())
                separator := keccak256(m, 0xa0)
            }
        }
        _cachedDomainSeparator = separator;
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                   FUNCTIONS TO OVERRIDE                    */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Please override this function to return the domain name and version.
    /// ```
    ///     function _domainNameAndVersion()
    ///         internal
    ///         pure
    ///         virtual
    ///         returns (string memory name, string memory version)
    ///     {
    ///         name = "Solady";
    ///         version = "1";
    ///     }
    /// ```
    ///
    /// Note: If the returned result may change after the contract has been deployed,
    /// you must override `_domainNameAndVersionMayChange()` to return true.
    function _domainNameAndVersion()
        internal
        view
        virtual
        returns (string memory name, string memory version);

    /// @dev Returns if `_domainNameAndVersion()` may change
    /// after the contract has been deployed (i.e. after the constructor).
    /// Default: false.
    function _domainNameAndVersionMayChange() internal pure virtual returns (bool result) {}

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                     HASHING OPERATIONS                     */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns the EIP-712 domain separator.
    function _domainSeparator() internal view virtual returns (bytes32 separator) {
        if (_domainNameAndVersionMayChange()) {
            separator = _buildDomainSeparator();
        } else {
            separator = _cachedDomainSeparator;
            if (_cachedDomainSeparatorInvalidated()) separator = _buildDomainSeparator();
        }
    }

    /// @dev Returns the hash of the fully encoded EIP-712 message for this domain,
    /// given `structHash`, as defined in
    /// https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct.
    ///
    /// The hash can be used together with {ECDSA-recover} to obtain the signer of a message:
    /// ```
    ///     bytes32 digest = _hashTypedData(keccak256(abi.encode(
    ///         keccak256("Mail(address to,string contents)"),
    ///         mailTo,
    ///         keccak256(bytes(mailContents))
    ///     )));
    ///     address signer = ECDSA.recover(digest, signature);
    /// ```
    function _hashTypedData(bytes32 structHash) internal view virtual returns (bytes32 digest) {
        // We will use `digest` to store the domain separator to save a bit of gas.
        if (_domainNameAndVersionMayChange()) {
            digest = _buildDomainSeparator();
        } else {
            digest = _cachedDomainSeparator;
            if (_cachedDomainSeparatorInvalidated()) digest = _buildDomainSeparator();
        }
        /// @solidity memory-safe-assembly
        assembly {
            // Compute the digest.
            mstore(0x00, 0x1901000000000000) // Store "\x19\x01".
            mstore(0x1a, digest) // Store the domain separator.
            mstore(0x3a, structHash) // Store the struct hash.
            digest := keccak256(0x18, 0x42)
            // Restore the part of the free memory slot that was overwritten.
            mstore(0x3a, 0)
        }
    }

    /// @dev Variant of `_hashTypedData` that excludes the chain ID.
    /// We expect that most contracts will use `_hashTypedData` as the main hash,
    /// and `_hashTypedDataSansChainId` only occasionally for cross-chain workflows.
    /// Thus this is optimized for smaller bytecode size over runtime gas.
    function _hashTypedDataSansChainId(bytes32 structHash)
        internal
        view
        virtual
        returns (bytes32 digest)
    {
        (string memory name, string memory version) = _domainNameAndVersion();
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Load the free memory pointer.
            mstore(0x00, _DOMAIN_TYPEHASH_SANS_CHAIN_ID)
            mstore(0x20, keccak256(add(name, 0x20), mload(name)))
            mstore(0x40, keccak256(add(version, 0x20), mload(version)))
            mstore(0x60, address())
            // Compute the digest.
            mstore(0x20, keccak256(0x00, 0x80)) // Store the domain separator.
            mstore(0x00, 0x1901) // Store "\x19\x01".
            mstore(0x40, structHash) // Store the struct hash.
            digest := keccak256(0x1e, 0x42)
            mstore(0x40, m) // Restore the free memory pointer.
            mstore(0x60, 0) // Restore the zero pointer.
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                    EIP-5267 OPERATIONS                     */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev See: https://eips.ethereum.org/EIPS/eip-5267
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
        fields = hex"0f"; // `0b01111`.
        (name, version) = _domainNameAndVersion();
        chainId = block.chainid;
        verifyingContract = address(this);
        salt = salt; // `bytes32(0)`.
        extensions = extensions; // `new uint256[](0)`.
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      PRIVATE HELPERS                       */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns the EIP-712 domain separator.
    function _buildDomainSeparator() private view returns (bytes32 separator) {
        // We will use `separator` to store the name hash to save a bit of gas.
        bytes32 versionHash;
        if (_domainNameAndVersionMayChange()) {
            (string memory name, string memory version) = _domainNameAndVersion();
            separator = keccak256(bytes(name));
            versionHash = keccak256(bytes(version));
        } else {
            separator = _cachedNameHash;
            versionHash = _cachedVersionHash;
        }
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Load the free memory pointer.
            mstore(m, _DOMAIN_TYPEHASH)
            mstore(add(m, 0x20), separator) // Name hash.
            mstore(add(m, 0x40), versionHash)
            mstore(add(m, 0x60), chainid())
            mstore(add(m, 0x80), address())
            separator := keccak256(m, 0xa0)
        }
    }

    /// @dev Returns if the cached domain separator has been invalidated.
    function _cachedDomainSeparatorInvalidated() private view returns (bool result) {
        uint256 cachedChainId = _cachedChainId;
        uint256 cachedThis = _cachedThis;
        /// @solidity memory-safe-assembly
        assembly {
            result := iszero(and(eq(chainid(), cachedChainId), eq(address(), cachedThis)))
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Library for bit twiddling and boolean operations.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/LibBit.sol)
/// @author Inspired by (https://graphics.stanford.edu/~seander/bithacks.html)
library LibBit {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                  BIT TWIDDLING OPERATIONS                  */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Find last set.
    /// Returns the index of the most significant bit of `x`,
    /// counting from the least significant bit position.
    /// If `x` is zero, returns 256.
    function fls(uint256 x) internal pure returns (uint256 r) {
        /// @solidity memory-safe-assembly
        assembly {
            r := or(shl(8, iszero(x)), shl(7, lt(0xffffffffffffffffffffffffffffffff, x)))
            r := or(r, shl(6, lt(0xffffffffffffffff, shr(r, x))))
            r := or(r, shl(5, lt(0xffffffff, shr(r, x))))
            r := or(r, shl(4, lt(0xffff, shr(r, x))))
            r := or(r, shl(3, lt(0xff, shr(r, x))))
            // forgefmt: disable-next-item
            r := or(r, byte(and(0x1f, shr(shr(r, x), 0x8421084210842108cc6318c6db6d54be)),
                0x0706060506020504060203020504030106050205030304010505030400000000))
        }
    }

    /// @dev Count leading zeros.
    /// Returns the number of zeros preceding the most significant one bit.
    /// If `x` is zero, returns 256.
    function clz(uint256 x) internal pure returns (uint256 r) {
        /// @solidity memory-safe-assembly
        assembly {
            r := shl(7, lt(0xffffffffffffffffffffffffffffffff, x))
            r := or(r, shl(6, lt(0xffffffffffffffff, shr(r, x))))
            r := or(r, shl(5, lt(0xffffffff, shr(r, x))))
            r := or(r, shl(4, lt(0xffff, shr(r, x))))
            r := or(r, shl(3, lt(0xff, shr(r, x))))
            // forgefmt: disable-next-item
            r := add(xor(r, byte(and(0x1f, shr(shr(r, x), 0x8421084210842108cc6318c6db6d54be)),
                0xf8f9f9faf9fdfafbf9fdfcfdfafbfcfef9fafdfafcfcfbfefafafcfbffffffff)), iszero(x))
        }
    }

    /// @dev Find first set.
    /// Returns the index of the least significant bit of `x`,
    /// counting from the least significant bit position.
    /// If `x` is zero, returns 256.
    /// Equivalent to `ctz` (count trailing zeros), which gives
    /// the number of zeros following the least significant one bit.
    function ffs(uint256 x) internal pure returns (uint256 r) {
        /// @solidity memory-safe-assembly
        assembly {
            // Isolate the least significant bit.
            x := and(x, add(not(x), 1))
            // For the upper 3 bits of the result, use a De Bruijn-like lookup.
            // Credit to adhusson: https://blog.adhusson.com/cheap-find-first-set-evm/
            // forgefmt: disable-next-item
            r := shl(5, shr(252, shl(shl(2, shr(250, mul(x,
                0xb6db6db6ddddddddd34d34d349249249210842108c6318c639ce739cffffffff))),
                0x8040405543005266443200005020610674053026020000107506200176117077)))
            // For the lower 5 bits of the result, use a De Bruijn lookup.
            // forgefmt: disable-next-item
            r := or(r, byte(and(div(0xd76453e0, shr(r, x)), 0x1f),
                0x001f0d1e100c1d070f090b19131c1706010e11080a1a141802121b1503160405))
        }
    }

    /// @dev Returns the number of set bits in `x`.
    function popCount(uint256 x) internal pure returns (uint256 c) {
        /// @solidity memory-safe-assembly
        assembly {
            let max := not(0)
            let isMax := eq(x, max)
            x := sub(x, and(shr(1, x), div(max, 3)))
            x := add(and(x, div(max, 5)), and(shr(2, x), div(max, 5)))
            x := and(add(x, shr(4, x)), div(max, 17))
            c := or(shl(8, isMax), shr(248, mul(x, div(max, 255))))
        }
    }

    /// @dev Returns whether `x` is a power of 2.
    function isPo2(uint256 x) internal pure returns (bool result) {
        /// @solidity memory-safe-assembly
        assembly {
            // Equivalent to `x && !(x & (x - 1))`.
            result := iszero(add(and(x, sub(x, 1)), iszero(x)))
        }
    }

    /// @dev Returns `x` reversed at the bit level.
    function reverseBits(uint256 x) internal pure returns (uint256 r) {
        uint256 m0 = 0x0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f;
        uint256 m1 = m0 ^ (m0 << 2);
        uint256 m2 = m1 ^ (m1 << 1);
        r = reverseBytes(x);
        r = (m2 & (r >> 1)) | ((m2 & r) << 1);
        r = (m1 & (r >> 2)) | ((m1 & r) << 2);
        r = (m0 & (r >> 4)) | ((m0 & r) << 4);
    }

    /// @dev Returns `x` reversed at the byte level.
    function reverseBytes(uint256 x) internal pure returns (uint256 r) {
        unchecked {
            // Computing masks on-the-fly reduces bytecode size by about 200 bytes.
            uint256 m0 = 0x100000000000000000000000000000001 * (~toUint(x == uint256(0)) >> 192);
            uint256 m1 = m0 ^ (m0 << 32);
            uint256 m2 = m1 ^ (m1 << 16);
            uint256 m3 = m2 ^ (m2 << 8);
            r = (m3 & (x >> 8)) | ((m3 & x) << 8);
            r = (m2 & (r >> 16)) | ((m2 & r) << 16);
            r = (m1 & (r >> 32)) | ((m1 & r) << 32);
            r = (m0 & (r >> 64)) | ((m0 & r) << 64);
            r = (r >> 128) | (r << 128);
        }
    }

    /// @dev Returns the common prefix of `x` and `y` at the bit level.
    function commonBitPrefix(uint256 x, uint256 y) internal pure returns (uint256) {
        unchecked {
            uint256 s = 256 - clz(x ^ y);
            return (x >> s) << s;
        }
    }

    /// @dev Returns the common prefix of `x` and `y` at the nibble level.
    function commonNibblePrefix(uint256 x, uint256 y) internal pure returns (uint256) {
        unchecked {
            uint256 s = (64 - (clz(x ^ y) >> 2)) << 2;
            return (x >> s) << s;
        }
    }

    /// @dev Returns the common prefix of `x` and `y` at the byte level.
    function commonBytePrefix(uint256 x, uint256 y) internal pure returns (uint256) {
        unchecked {
            uint256 s = (32 - (clz(x ^ y) >> 3)) << 3;
            return (x >> s) << s;
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                     BOOLEAN OPERATIONS                     */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // A Solidity bool on the stack or memory is represented as a 256-bit word.
    // Non-zero values are true, zero is false.
    // A clean bool is either 0 (false) or 1 (true) under the hood.
    // Usually, if not always, the bool result of a regular Solidity expression,
    // or the argument of a public/external function will be a clean bool.
    // You can usually use the raw variants for more performance.
    // If uncertain, test (best with exact compiler settings).
    // Or use the non-raw variants (compiler can sometimes optimize out the double `iszero`s).

    /// @dev Returns `x & y`. Inputs must be clean.
    function rawAnd(bool x, bool y) internal pure returns (bool z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := and(x, y)
        }
    }

    /// @dev Returns `x & y`.
    function and(bool x, bool y) internal pure returns (bool z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := and(iszero(iszero(x)), iszero(iszero(y)))
        }
    }

    /// @dev Returns `x | y`. Inputs must be clean.
    function rawOr(bool x, bool y) internal pure returns (bool z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := or(x, y)
        }
    }

    /// @dev Returns `x | y`.
    function or(bool x, bool y) internal pure returns (bool z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := or(iszero(iszero(x)), iszero(iszero(y)))
        }
    }

    /// @dev Returns 1 if `b` is true, else 0. Input must be clean.
    function rawToUint(bool b) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := b
        }
    }

    /// @dev Returns 1 if `b` is true, else 0.
    function toUint(bool b) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := iszero(iszero(b))
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {LibBit} from "./LibBit.sol";

/// @notice Library for storage of packed unsigned booleans.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/LibBitmap.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/LibBitmap.sol)
/// @author Modified from Solidity-Bits (https://github.com/estarriolvetch/solidity-bits/blob/main/contracts/BitMaps.sol)
library LibBitmap {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         CONSTANTS                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The constant returned when a bitmap scan does not find a result.
    uint256 internal constant NOT_FOUND = type(uint256).max;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                          STRUCTS                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev A bitmap in storage.
    struct Bitmap {
        mapping(uint256 => uint256) map;
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         OPERATIONS                         */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns the boolean value of the bit at `index` in `bitmap`.
    function get(Bitmap storage bitmap, uint256 index) internal view returns (bool isSet) {
        // It is better to set `isSet` to either 0 or 1, than zero vs non-zero.
        // Both cost the same amount of gas, but the former allows the returned value
        // to be reused without cleaning the upper bits.
        uint256 b = (bitmap.map[index >> 8] >> (index & 0xff)) & 1;
        /// @solidity memory-safe-assembly
        assembly {
            isSet := b
        }
    }

    /// @dev Updates the bit at `index` in `bitmap` to true.
    function set(Bitmap storage bitmap, uint256 index) internal {
        bitmap.map[index >> 8] |= (1 << (index & 0xff));
    }

    /// @dev Updates the bit at `index` in `bitmap` to false.
    function unset(Bitmap storage bitmap, uint256 index) internal {
        bitmap.map[index >> 8] &= ~(1 << (index & 0xff));
    }

    /// @dev Flips the bit at `index` in `bitmap`.
    /// Returns the boolean result of the flipped bit.
    function toggle(Bitmap storage bitmap, uint256 index) internal returns (bool newIsSet) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x20, bitmap.slot)
            mstore(0x00, shr(8, index))
            let storageSlot := keccak256(0x00, 0x40)
            let shift := and(index, 0xff)
            let storageValue := xor(sload(storageSlot), shl(shift, 1))
            // It makes sense to return the `newIsSet`,
            // as it allow us to skip an additional warm `sload`,
            // and it costs minimal gas (about 15),
            // which may be optimized away if the returned value is unused.
            newIsSet := and(1, shr(shift, storageValue))
            sstore(storageSlot, storageValue)
        }
    }

    /// @dev Updates the bit at `index` in `bitmap` to `shouldSet`.
    function setTo(Bitmap storage bitmap, uint256 index, bool shouldSet) internal {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x20, bitmap.slot)
            mstore(0x00, shr(8, index))
            let storageSlot := keccak256(0x00, 0x40)
            let storageValue := sload(storageSlot)
            let shift := and(index, 0xff)
            sstore(
                storageSlot,
                // Unsets the bit at `shift` via `and`, then sets its new value via `or`.
                or(and(storageValue, not(shl(shift, 1))), shl(shift, iszero(iszero(shouldSet))))
            )
        }
    }

    /// @dev Consecutively sets `amount` of bits starting from the bit at `start`.
    function setBatch(Bitmap storage bitmap, uint256 start, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            let max := not(0)
            let shift := and(start, 0xff)
            mstore(0x20, bitmap.slot)
            mstore(0x00, shr(8, start))
            if iszero(lt(add(shift, amount), 257)) {
                let storageSlot := keccak256(0x00, 0x40)
                sstore(storageSlot, or(sload(storageSlot), shl(shift, max)))
                let bucket := add(mload(0x00), 1)
                let bucketEnd := add(mload(0x00), shr(8, add(amount, shift)))
                amount := and(add(amount, shift), 0xff)
                shift := 0
                for {} iszero(eq(bucket, bucketEnd)) { bucket := add(bucket, 1) } {
                    mstore(0x00, bucket)
                    sstore(keccak256(0x00, 0x40), max)
                }
                mstore(0x00, bucket)
            }
            let storageSlot := keccak256(0x00, 0x40)
            sstore(storageSlot, or(sload(storageSlot), shl(shift, shr(sub(256, amount), max))))
        }
    }

    /// @dev Consecutively unsets `amount` of bits starting from the bit at `start`.
    function unsetBatch(Bitmap storage bitmap, uint256 start, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            let shift := and(start, 0xff)
            mstore(0x20, bitmap.slot)
            mstore(0x00, shr(8, start))
            if iszero(lt(add(shift, amount), 257)) {
                let storageSlot := keccak256(0x00, 0x40)
                sstore(storageSlot, and(sload(storageSlot), not(shl(shift, not(0)))))
                let bucket := add(mload(0x00), 1)
                let bucketEnd := add(mload(0x00), shr(8, add(amount, shift)))
                amount := and(add(amount, shift), 0xff)
                shift := 0
                for {} iszero(eq(bucket, bucketEnd)) { bucket := add(bucket, 1) } {
                    mstore(0x00, bucket)
                    sstore(keccak256(0x00, 0x40), 0)
                }
                mstore(0x00, bucket)
            }
            let storageSlot := keccak256(0x00, 0x40)
            sstore(
                storageSlot, and(sload(storageSlot), not(shl(shift, shr(sub(256, amount), not(0)))))
            )
        }
    }

    /// @dev Returns number of set bits within a range by
    /// scanning `amount` of bits starting from the bit at `start`.
    function popCount(Bitmap storage bitmap, uint256 start, uint256 amount)
        internal
        view
        returns (uint256 count)
    {
        unchecked {
            uint256 bucket = start >> 8;
            uint256 shift = start & 0xff;
            if (!(amount + shift < 257)) {
                count = LibBit.popCount(bitmap.map[bucket] >> shift);
                uint256 bucketEnd = bucket + ((amount + shift) >> 8);
                amount = (amount + shift) & 0xff;
                shift = 0;
                for (++bucket; bucket != bucketEnd; ++bucket) {
                    count += LibBit.popCount(bitmap.map[bucket]);
                }
            }
            count += LibBit.popCount((bitmap.map[bucket] >> shift) << (256 - amount));
        }
    }

    /// @dev Returns the index of the most significant set bit in `[0..upTo]`.
    /// If no set bit is found, returns `NOT_FOUND`.
    function findLastSet(Bitmap storage bitmap, uint256 upTo)
        internal
        view
        returns (uint256 setBitIndex)
    {
        setBitIndex = NOT_FOUND;
        uint256 bucket = upTo >> 8;
        uint256 bits;
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, bucket)
            mstore(0x20, bitmap.slot)
            let offset := and(0xff, not(upTo)) // `256 - (255 & upTo) - 1`.
            bits := shr(offset, shl(offset, sload(keccak256(0x00, 0x40))))
            if iszero(or(bits, iszero(bucket))) {
                for {} 1 {} {
                    bucket := add(bucket, setBitIndex) // `sub(bucket, 1)`.
                    mstore(0x00, bucket)
                    bits := sload(keccak256(0x00, 0x40))
                    if or(bits, iszero(bucket)) { break }
                }
            }
        }
        if (bits != 0) {
            setBitIndex = (bucket << 8) | LibBit.fls(bits);
            /// @solidity memory-safe-assembly
            assembly {
                setBitIndex := or(setBitIndex, sub(0, gt(setBitIndex, upTo)))
            }
        }
    }

    /// @dev Returns the index of the least significant unset bit in `[begin..upTo]`.
    /// If no unset bit is found, returns `NOT_FOUND`.
    function findFirstUnset(Bitmap storage bitmap, uint256 begin, uint256 upTo)
        internal
        view
        returns (uint256 unsetBitIndex)
    {
        unsetBitIndex = NOT_FOUND;
        uint256 bucket = begin >> 8;
        uint256 negBits;
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, bucket)
            mstore(0x20, bitmap.slot)
            let offset := and(0xff, begin)
            negBits := shl(offset, shr(offset, not(sload(keccak256(0x00, 0x40)))))
            if iszero(negBits) {
                let lastBucket := shr(8, upTo)
                for {} 1 {} {
                    bucket := add(bucket, 1)
                    mstore(0x00, bucket)
                    negBits := not(sload(keccak256(0x00, 0x40)))
                    if or(negBits, gt(bucket, lastBucket)) { break }
                }
                if gt(bucket, lastBucket) {
                    negBits := shl(and(0xff, not(upTo)), shr(and(0xff, not(upTo)), negBits))
                }
            }
        }
        if (negBits != 0) {
            uint256 r = (bucket << 8) | LibBit.ffs(negBits);
            /// @solidity memory-safe-assembly
            assembly {
                unsetBitIndex := or(r, sub(0, or(gt(r, upTo), lt(r, begin))))
            }
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Gas optimized verification of proof of inclusion for a leaf in a Merkle tree.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/MerkleProofLib.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/MerkleProofLib.sol)
/// @author Modified from OpenZeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/cryptography/MerkleProof.sol)
library MerkleProofLib {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*            MERKLE PROOF VERIFICATION OPERATIONS            */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns whether `leaf` exists in the Merkle tree with `root`, given `proof`.
    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf)
        internal
        pure
        returns (bool isValid)
    {
        /// @solidity memory-safe-assembly
        assembly {
            if mload(proof) {
                // Initialize `offset` to the offset of `proof` elements in memory.
                let offset := add(proof, 0x20)
                // Left shift by 5 is equivalent to multiplying by 0x20.
                let end := add(offset, shl(5, mload(proof)))
                // Iterate over proof elements to compute root hash.
                for {} 1 {} {
                    // Slot of `leaf` in scratch space.
                    // If the condition is true: 0x20, otherwise: 0x00.
                    let scratch := shl(5, gt(leaf, mload(offset)))
                    // Store elements to hash contiguously in scratch space.
                    // Scratch space is 64 bytes (0x00 - 0x3f) and both elements are 32 bytes.
                    mstore(scratch, leaf)
                    mstore(xor(scratch, 0x20), mload(offset))
                    // Reuse `leaf` to store the hash to reduce stack operations.
                    leaf := keccak256(0x00, 0x40)
                    offset := add(offset, 0x20)
                    if iszero(lt(offset, end)) { break }
                }
            }
            isValid := eq(leaf, root)
        }
    }

    /// @dev Returns whether `leaf` exists in the Merkle tree with `root`, given `proof`.
    function verifyCalldata(bytes32[] calldata proof, bytes32 root, bytes32 leaf)
        internal
        pure
        returns (bool isValid)
    {
        /// @solidity memory-safe-assembly
        assembly {
            if proof.length {
                // Left shift by 5 is equivalent to multiplying by 0x20.
                let end := add(proof.offset, shl(5, proof.length))
                // Initialize `offset` to the offset of `proof` in the calldata.
                let offset := proof.offset
                // Iterate over proof elements to compute root hash.
                for {} 1 {} {
                    // Slot of `leaf` in scratch space.
                    // If the condition is true: 0x20, otherwise: 0x00.
                    let scratch := shl(5, gt(leaf, calldataload(offset)))
                    // Store elements to hash contiguously in scratch space.
                    // Scratch space is 64 bytes (0x00 - 0x3f) and both elements are 32 bytes.
                    mstore(scratch, leaf)
                    mstore(xor(scratch, 0x20), calldataload(offset))
                    // Reuse `leaf` to store the hash to reduce stack operations.
                    leaf := keccak256(0x00, 0x40)
                    offset := add(offset, 0x20)
                    if iszero(lt(offset, end)) { break }
                }
            }
            isValid := eq(leaf, root)
        }
    }

    /// @dev Returns whether all `leaves` exist in the Merkle tree with `root`,
    /// given `proof` and `flags`.
    ///
    /// Note:
    /// - Breaking the invariant `flags.length == (leaves.length - 1) + proof.length`
    ///   will always return false.
    /// - The sum of the lengths of `proof` and `leaves` must never overflow.
    /// - Any non-zero word in the `flags` array is treated as true.
    /// - The memory offset of `proof` must be non-zero
    ///   (i.e. `proof` is not pointing to the scratch space).
    function verifyMultiProof(
        bytes32[] memory proof,
        bytes32 root,
        bytes32[] memory leaves,
        bool[] memory flags
    ) internal pure returns (bool isValid) {
        // Rebuilds the root by consuming and producing values on a queue.
        // The queue starts with the `leaves` array, and goes into a `hashes` array.
        // After the process, the last element on the queue is verified
        // to be equal to the `root`.
        //
        // The `flags` array denotes whether the sibling
        // should be popped from the queue (`flag == true`), or
        // should be popped from the `proof` (`flag == false`).
        /// @solidity memory-safe-assembly
        assembly {
            // Cache the lengths of the arrays.
            let leavesLength := mload(leaves)
            let proofLength := mload(proof)
            let flagsLength := mload(flags)

            // Advance the pointers of the arrays to point to the data.
            leaves := add(0x20, leaves)
            proof := add(0x20, proof)
            flags := add(0x20, flags)

            // If the number of flags is correct.
            for {} eq(add(leavesLength, proofLength), add(flagsLength, 1)) {} {
                // For the case where `proof.length + leaves.length == 1`.
                if iszero(flagsLength) {
                    // `isValid = (proof.length == 1 ? proof[0] : leaves[0]) == root`.
                    isValid := eq(mload(xor(leaves, mul(xor(proof, leaves), proofLength))), root)
                    break
                }

                // The required final proof offset if `flagsLength` is not zero, otherwise zero.
                let proofEnd := add(proof, shl(5, proofLength))
                // We can use the free memory space for the queue.
                // We don't need to allocate, since the queue is temporary.
                let hashesFront := mload(0x40)
                // Copy the leaves into the hashes.
                // Sometimes, a little memory expansion costs less than branching.
                // Should cost less, even with a high free memory offset of 0x7d00.
                leavesLength := shl(5, leavesLength)
                for { let i := 0 } iszero(eq(i, leavesLength)) { i := add(i, 0x20) } {
                    mstore(add(hashesFront, i), mload(add(leaves, i)))
                }
                // Compute the back of the hashes.
                let hashesBack := add(hashesFront, leavesLength)
                // This is the end of the memory for the queue.
                // We recycle `flagsLength` to save on stack variables (sometimes save gas).
                flagsLength := add(hashesBack, shl(5, flagsLength))

                for {} 1 {} {
                    // Pop from `hashes`.
                    let a := mload(hashesFront)
                    // Pop from `hashes`.
                    let b := mload(add(hashesFront, 0x20))
                    hashesFront := add(hashesFront, 0x40)

                    // If the flag is false, load the next proof,
                    // else, pops from the queue.
                    if iszero(mload(flags)) {
                        // Loads the next proof.
                        b := mload(proof)
                        proof := add(proof, 0x20)
                        // Unpop from `hashes`.
                        hashesFront := sub(hashesFront, 0x20)
                    }

                    // Advance to the next flag.
                    flags := add(flags, 0x20)

                    // Slot of `a` in scratch space.
                    // If the condition is true: 0x20, otherwise: 0x00.
                    let scratch := shl(5, gt(a, b))
                    // Hash the scratch space and push the result onto the queue.
                    mstore(scratch, a)
                    mstore(xor(scratch, 0x20), b)
                    mstore(hashesBack, keccak256(0x00, 0x40))
                    hashesBack := add(hashesBack, 0x20)
                    if iszero(lt(hashesBack, flagsLength)) { break }
                }
                isValid :=
                    and(
                        // Checks if the last value in the queue is same as the root.
                        eq(mload(sub(hashesBack, 0x20)), root),
                        // And whether all the proofs are used, if required.
                        eq(proofEnd, proof)
                    )
                break
            }
        }
    }

    /// @dev Returns whether all `leaves` exist in the Merkle tree with `root`,
    /// given `proof` and `flags`.
    ///
    /// Note:
    /// - Breaking the invariant `flags.length == (leaves.length - 1) + proof.length`
    ///   will always return false.
    /// - Any non-zero word in the `flags` array is treated as true.
    /// - The calldata offset of `proof` must be non-zero
    ///   (i.e. `proof` is from a regular Solidity function with a 4-byte selector).
    function verifyMultiProofCalldata(
        bytes32[] calldata proof,
        bytes32 root,
        bytes32[] calldata leaves,
        bool[] calldata flags
    ) internal pure returns (bool isValid) {
        // Rebuilds the root by consuming and producing values on a queue.
        // The queue starts with the `leaves` array, and goes into a `hashes` array.
        // After the process, the last element on the queue is verified
        // to be equal to the `root`.
        //
        // The `flags` array denotes whether the sibling
        // should be popped from the queue (`flag == true`), or
        // should be popped from the `proof` (`flag == false`).
        /// @solidity memory-safe-assembly
        assembly {
            // If the number of flags is correct.
            for {} eq(add(leaves.length, proof.length), add(flags.length, 1)) {} {
                // For the case where `proof.length + leaves.length == 1`.
                if iszero(flags.length) {
                    // `isValid = (proof.length == 1 ? proof[0] : leaves[0]) == root`.
                    // forgefmt: disable-next-item
                    isValid := eq(
                        calldataload(
                            xor(leaves.offset, mul(xor(proof.offset, leaves.offset), proof.length))
                        ),
                        root
                    )
                    break
                }

                // The required final proof offset if `flagsLength` is not zero, otherwise zero.
                let proofEnd := add(proof.offset, shl(5, proof.length))
                // We can use the free memory space for the queue.
                // We don't need to allocate, since the queue is temporary.
                let hashesFront := mload(0x40)
                // Copy the leaves into the hashes.
                // Sometimes, a little memory expansion costs less than branching.
                // Should cost less, even with a high free memory offset of 0x7d00.
                calldatacopy(hashesFront, leaves.offset, shl(5, leaves.length))
                // Compute the back of the hashes.
                let hashesBack := add(hashesFront, shl(5, leaves.length))
                // This is the end of the memory for the queue.
                // We recycle `flagsLength` to save on stack variables (sometimes save gas).
                flags.length := add(hashesBack, shl(5, flags.length))

                // We don't need to make a copy of `proof.offset` or `flags.offset`,
                // as they are pass-by-value (this trick may not always save gas).

                for {} 1 {} {
                    // Pop from `hashes`.
                    let a := mload(hashesFront)
                    // Pop from `hashes`.
                    let b := mload(add(hashesFront, 0x20))
                    hashesFront := add(hashesFront, 0x40)

                    // If the flag is false, load the next proof,
                    // else, pops from the queue.
                    if iszero(calldataload(flags.offset)) {
                        // Loads the next proof.
                        b := calldataload(proof.offset)
                        proof.offset := add(proof.offset, 0x20)
                        // Unpop from `hashes`.
                        hashesFront := sub(hashesFront, 0x20)
                    }

                    // Advance to the next flag offset.
                    flags.offset := add(flags.offset, 0x20)

                    // Slot of `a` in scratch space.
                    // If the condition is true: 0x20, otherwise: 0x00.
                    let scratch := shl(5, gt(a, b))
                    // Hash the scratch space and push the result onto the queue.
                    mstore(scratch, a)
                    mstore(xor(scratch, 0x20), b)
                    mstore(hashesBack, keccak256(0x00, 0x40))
                    hashesBack := add(hashesBack, 0x20)
                    if iszero(lt(hashesBack, flags.length)) { break }
                }
                isValid :=
                    and(
                        // Checks if the last value in the queue is same as the root.
                        eq(mload(sub(hashesBack, 0x20)), root),
                        // And whether all the proofs are used, if required.
                        eq(proofEnd, proof.offset)
                    )
                break
            }
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                   EMPTY CALLDATA HELPERS                   */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns an empty calldata bytes32 array.
    function emptyProof() internal pure returns (bytes32[] calldata proof) {
        /// @solidity memory-safe-assembly
        assembly {
            proof.length := 0
        }
    }

    /// @dev Returns an empty calldata bytes32 array.
    function emptyLeaves() internal pure returns (bytes32[] calldata leaves) {
        /// @solidity memory-safe-assembly
        assembly {
            leaves.length := 0
        }
    }

    /// @dev Returns an empty calldata bool array.
    function emptyFlags() internal pure returns (bool[] calldata flags) {
        /// @solidity memory-safe-assembly
        assembly {
            flags.length := 0
        }
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

    /// @dev The Permit2 approve operation has failed.
    error Permit2ApproveFailed();

    /// @dev The Permit2 lockdown operation has failed.
    error Permit2LockdownFailed();

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
                    mstore(
                        add(m, 0x94),
                        lt(iszero(amount), staticcall(gas(), token, 0x10, 0x24, add(m, 0x54), 0x20))
                    )
                    mstore(m, 0x8fcbaf0c000000000000000000000000) // `IDAIPermit.permit`.
                    // `nonces` is already at `add(m, 0x54)`.
                    // `amount != 0` is already stored at `add(m, 0x94)`.
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

    /// @dev Approves `spender` to spend `amount` of `token` for `address(this)`.
    function permit2Approve(address token, address spender, uint160 amount, uint48 expiration)
        internal
    {
        /// @solidity memory-safe-assembly
        assembly {
            let addressMask := shr(96, not(0))
            let m := mload(0x40)
            mstore(m, 0x87517c45) // `approve(address,address,uint160,uint48)`.
            mstore(add(m, 0x20), and(addressMask, token))
            mstore(add(m, 0x40), and(addressMask, spender))
            mstore(add(m, 0x60), and(addressMask, amount))
            mstore(add(m, 0x80), and(0xffffffffffff, expiration))
            if iszero(call(gas(), PERMIT2, 0, add(m, 0x1c), 0xa0, codesize(), 0x00)) {
                mstore(0x00, 0x324f14ae) // `Permit2ApproveFailed()`.
                revert(0x1c, 0x04)
            }
        }
    }

    /// @dev Revokes an approval for `token` and `spender` for `address(this)`.
    function permit2Lockdown(address token, address spender) internal {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40)
            mstore(m, 0xcc53287f) // `Permit2.lockdown`.
            mstore(add(m, 0x20), 0x20) // Offset of the `approvals`.
            mstore(add(m, 0x40), 1) // `approvals.length`.
            mstore(add(m, 0x60), shr(96, shl(96, token)))
            mstore(add(m, 0x80), shr(96, shl(96, spender)))
            if iszero(call(gas(), PERMIT2, 0, add(m, 0x1c), 0xa0, codesize(), 0x00)) {
                mstore(0x00, 0x96b3de23) // `Permit2LockdownFailed()`.
                revert(0x1c, 0x04)
            }
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Signature verification helper that supports both ECDSA signatures from EOAs
/// and ERC1271 signatures from smart contract wallets like Argent and Gnosis safe.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/SignatureCheckerLib.sol)
/// @author Modified from OpenZeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/cryptography/SignatureChecker.sol)
///
/// @dev Note:
/// - The signature checking functions use the ecrecover precompile (0x1).
/// - The `bytes memory signature` variants use the identity precompile (0x4)
///   to copy memory internally.
/// - Unlike ECDSA signatures, contract signatures are revocable.
/// - As of Solady version 0.0.134, all `bytes signature` variants accept both
///   regular 65-byte `(r, s, v)` and EIP-2098 `(r, vs)` short form signatures.
///   See: https://eips.ethereum.org/EIPS/eip-2098
///   This is for calldata efficiency on smart accounts prevalent on L2s.
///
/// WARNING! Do NOT use signatures as unique identifiers:
/// - Use a nonce in the digest to prevent replay attacks on the same contract.
/// - Use EIP-712 for the digest to prevent replay attacks across different chains and contracts.
///   EIP-712 also enables readable signing of typed data for better user safety.
/// This implementation does NOT check if a signature is non-malleable.
library SignatureCheckerLib {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*               SIGNATURE CHECKING OPERATIONS                */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns whether `signature` is valid for `signer` and `hash`.
    /// If `signer.code.length == 0`, then validate with `ecrecover`, else
    /// it will validate with ERC1271 on `signer`.
    function isValidSignatureNow(address signer, bytes32 hash, bytes memory signature)
        internal
        view
        returns (bool isValid)
    {
        if (signer == address(0)) return isValid;
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40)
            for {} 1 {} {
                if iszero(extcodesize(signer)) {
                    switch mload(signature)
                    case 64 {
                        let vs := mload(add(signature, 0x40))
                        mstore(0x20, add(shr(255, vs), 27)) // `v`.
                        mstore(0x60, shr(1, shl(1, vs))) // `s`.
                    }
                    case 65 {
                        mstore(0x20, byte(0, mload(add(signature, 0x60)))) // `v`.
                        mstore(0x60, mload(add(signature, 0x40))) // `s`.
                    }
                    default { break }
                    mstore(0x00, hash)
                    mstore(0x40, mload(add(signature, 0x20))) // `r`.
                    let recovered := mload(staticcall(gas(), 1, 0x00, 0x80, 0x01, 0x20))
                    isValid := gt(returndatasize(), shl(96, xor(signer, recovered)))
                    mstore(0x60, 0) // Restore the zero slot.
                    mstore(0x40, m) // Restore the free memory pointer.
                    break
                }
                let f := shl(224, 0x1626ba7e)
                mstore(m, f) // `bytes4(keccak256("isValidSignature(bytes32,bytes)"))`.
                mstore(add(m, 0x04), hash)
                let d := add(m, 0x24)
                mstore(d, 0x40) // The offset of the `signature` in the calldata.
                // Copy the `signature` over.
                let n := add(0x20, mload(signature))
                let copied := staticcall(gas(), 4, signature, n, add(m, 0x44), n)
                isValid := staticcall(gas(), signer, m, add(returndatasize(), 0x44), d, 0x20)
                isValid := and(eq(mload(d), f), and(isValid, copied))
                break
            }
        }
    }

    /// @dev Returns whether `signature` is valid for `signer` and `hash`.
    /// If `signer.code.length == 0`, then validate with `ecrecover`, else
    /// it will validate with ERC1271 on `signer`.
    function isValidSignatureNowCalldata(address signer, bytes32 hash, bytes calldata signature)
        internal
        view
        returns (bool isValid)
    {
        if (signer == address(0)) return isValid;
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40)
            for {} 1 {} {
                if iszero(extcodesize(signer)) {
                    switch signature.length
                    case 64 {
                        let vs := calldataload(add(signature.offset, 0x20))
                        mstore(0x20, add(shr(255, vs), 27)) // `v`.
                        mstore(0x40, calldataload(signature.offset)) // `r`.
                        mstore(0x60, shr(1, shl(1, vs))) // `s`.
                    }
                    case 65 {
                        mstore(0x20, byte(0, calldataload(add(signature.offset, 0x40)))) // `v`.
                        calldatacopy(0x40, signature.offset, 0x40) // `r`, `s`.
                    }
                    default { break }
                    mstore(0x00, hash)
                    let recovered := mload(staticcall(gas(), 1, 0x00, 0x80, 0x01, 0x20))
                    isValid := gt(returndatasize(), shl(96, xor(signer, recovered)))
                    mstore(0x60, 0) // Restore the zero slot.
                    mstore(0x40, m) // Restore the free memory pointer.
                    break
                }
                let f := shl(224, 0x1626ba7e)
                mstore(m, f) // `bytes4(keccak256("isValidSignature(bytes32,bytes)"))`.
                mstore(add(m, 0x04), hash)
                let d := add(m, 0x24)
                mstore(d, 0x40) // The offset of the `signature` in the calldata.
                mstore(add(m, 0x44), signature.length)
                // Copy the `signature` over.
                calldatacopy(add(m, 0x64), signature.offset, signature.length)
                isValid := staticcall(gas(), signer, m, add(signature.length, 0x64), d, 0x20)
                isValid := and(eq(mload(d), f), isValid)
                break
            }
        }
    }

    /// @dev Returns whether the signature (`r`, `vs`) is valid for `signer` and `hash`.
    /// If `signer.code.length == 0`, then validate with `ecrecover`, else
    /// it will validate with ERC1271 on `signer`.
    function isValidSignatureNow(address signer, bytes32 hash, bytes32 r, bytes32 vs)
        internal
        view
        returns (bool isValid)
    {
        if (signer == address(0)) return isValid;
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40)
            for {} 1 {} {
                if iszero(extcodesize(signer)) {
                    mstore(0x00, hash)
                    mstore(0x20, add(shr(255, vs), 27)) // `v`.
                    mstore(0x40, r) // `r`.
                    mstore(0x60, shr(1, shl(1, vs))) // `s`.
                    let recovered := mload(staticcall(gas(), 1, 0x00, 0x80, 0x01, 0x20))
                    isValid := gt(returndatasize(), shl(96, xor(signer, recovered)))
                    mstore(0x60, 0) // Restore the zero slot.
                    mstore(0x40, m) // Restore the free memory pointer.
                    break
                }
                let f := shl(224, 0x1626ba7e)
                mstore(m, f) // `bytes4(keccak256("isValidSignature(bytes32,bytes)"))`.
                mstore(add(m, 0x04), hash)
                let d := add(m, 0x24)
                mstore(d, 0x40) // The offset of the `signature` in the calldata.
                mstore(add(m, 0x44), 65) // Length of the signature.
                mstore(add(m, 0x64), r) // `r`.
                mstore(add(m, 0x84), shr(1, shl(1, vs))) // `s`.
                mstore8(add(m, 0xa4), add(shr(255, vs), 27)) // `v`.
                isValid := staticcall(gas(), signer, m, 0xa5, d, 0x20)
                isValid := and(eq(mload(d), f), isValid)
                break
            }
        }
    }

    /// @dev Returns whether the signature (`v`, `r`, `s`) is valid for `signer` and `hash`.
    /// If `signer.code.length == 0`, then validate with `ecrecover`, else
    /// it will validate with ERC1271 on `signer`.
    function isValidSignatureNow(address signer, bytes32 hash, uint8 v, bytes32 r, bytes32 s)
        internal
        view
        returns (bool isValid)
    {
        if (signer == address(0)) return isValid;
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40)
            for {} 1 {} {
                if iszero(extcodesize(signer)) {
                    mstore(0x00, hash)
                    mstore(0x20, and(v, 0xff)) // `v`.
                    mstore(0x40, r) // `r`.
                    mstore(0x60, s) // `s`.
                    let recovered := mload(staticcall(gas(), 1, 0x00, 0x80, 0x01, 0x20))
                    isValid := gt(returndatasize(), shl(96, xor(signer, recovered)))
                    mstore(0x60, 0) // Restore the zero slot.
                    mstore(0x40, m) // Restore the free memory pointer.
                    break
                }
                let f := shl(224, 0x1626ba7e)
                mstore(m, f) // `bytes4(keccak256("isValidSignature(bytes32,bytes)"))`.
                mstore(add(m, 0x04), hash)
                let d := add(m, 0x24)
                mstore(d, 0x40) // The offset of the `signature` in the calldata.
                mstore(add(m, 0x44), 65) // Length of the signature.
                mstore(add(m, 0x64), r) // `r`.
                mstore(add(m, 0x84), s) // `s`.
                mstore8(add(m, 0xa4), v) // `v`.
                isValid := staticcall(gas(), signer, m, 0xa5, d, 0x20)
                isValid := and(eq(mload(d), f), isValid)
                break
            }
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                     ERC1271 OPERATIONS                     */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // Note: These ERC1271 operations do NOT have an ECDSA fallback.

    /// @dev Returns whether `signature` is valid for `hash` for an ERC1271 `signer` contract.
    function isValidERC1271SignatureNow(address signer, bytes32 hash, bytes memory signature)
        internal
        view
        returns (bool isValid)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40)
            let f := shl(224, 0x1626ba7e)
            mstore(m, f) // `bytes4(keccak256("isValidSignature(bytes32,bytes)"))`.
            mstore(add(m, 0x04), hash)
            let d := add(m, 0x24)
            mstore(d, 0x40) // The offset of the `signature` in the calldata.
            // Copy the `signature` over.
            let n := add(0x20, mload(signature))
            let copied := staticcall(gas(), 4, signature, n, add(m, 0x44), n)
            isValid := staticcall(gas(), signer, m, add(returndatasize(), 0x44), d, 0x20)
            isValid := and(eq(mload(d), f), and(isValid, copied))
        }
    }

    /// @dev Returns whether `signature` is valid for `hash` for an ERC1271 `signer` contract.
    function isValidERC1271SignatureNowCalldata(
        address signer,
        bytes32 hash,
        bytes calldata signature
    ) internal view returns (bool isValid) {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40)
            let f := shl(224, 0x1626ba7e)
            mstore(m, f) // `bytes4(keccak256("isValidSignature(bytes32,bytes)"))`.
            mstore(add(m, 0x04), hash)
            let d := add(m, 0x24)
            mstore(d, 0x40) // The offset of the `signature` in the calldata.
            mstore(add(m, 0x44), signature.length)
            // Copy the `signature` over.
            calldatacopy(add(m, 0x64), signature.offset, signature.length)
            isValid := staticcall(gas(), signer, m, add(signature.length, 0x64), d, 0x20)
            isValid := and(eq(mload(d), f), isValid)
        }
    }

    /// @dev Returns whether the signature (`r`, `vs`) is valid for `hash`
    /// for an ERC1271 `signer` contract.
    function isValidERC1271SignatureNow(address signer, bytes32 hash, bytes32 r, bytes32 vs)
        internal
        view
        returns (bool isValid)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40)
            let f := shl(224, 0x1626ba7e)
            mstore(m, f) // `bytes4(keccak256("isValidSignature(bytes32,bytes)"))`.
            mstore(add(m, 0x04), hash)
            let d := add(m, 0x24)
            mstore(d, 0x40) // The offset of the `signature` in the calldata.
            mstore(add(m, 0x44), 65) // Length of the signature.
            mstore(add(m, 0x64), r) // `r`.
            mstore(add(m, 0x84), shr(1, shl(1, vs))) // `s`.
            mstore8(add(m, 0xa4), add(shr(255, vs), 27)) // `v`.
            isValid := staticcall(gas(), signer, m, 0xa5, d, 0x20)
            isValid := and(eq(mload(d), f), isValid)
        }
    }

    /// @dev Returns whether the signature (`v`, `r`, `s`) is valid for `hash`
    /// for an ERC1271 `signer` contract.
    function isValidERC1271SignatureNow(address signer, bytes32 hash, uint8 v, bytes32 r, bytes32 s)
        internal
        view
        returns (bool isValid)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40)
            let f := shl(224, 0x1626ba7e)
            mstore(m, f) // `bytes4(keccak256("isValidSignature(bytes32,bytes)"))`.
            mstore(add(m, 0x04), hash)
            let d := add(m, 0x24)
            mstore(d, 0x40) // The offset of the `signature` in the calldata.
            mstore(add(m, 0x44), 65) // Length of the signature.
            mstore(add(m, 0x64), r) // `r`.
            mstore(add(m, 0x84), s) // `s`.
            mstore8(add(m, 0xa4), v) // `v`.
            isValid := staticcall(gas(), signer, m, 0xa5, d, 0x20)
            isValid := and(eq(mload(d), f), isValid)
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                     ERC6492 OPERATIONS                     */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // Note: These ERC6492 operations now include an ECDSA fallback at the very end.
    // The calldata variants are excluded for brevity.

    /// @dev Returns whether `signature` is valid for `hash`.
    /// If the signature is postfixed with the ERC6492 magic number, it will attempt to
    /// deploy / prepare the `signer` smart account before doing a regular ERC1271 check.
    /// Note: This function is NOT reentrancy safe.
    /// The verifier must be deployed.
    /// Otherwise, the function will return false if `signer` is not yet deployed / prepared.
    /// See: https://gist.github.com/Vectorized/011d6becff6e0a73e42fe100f8d7ef04
    /// With a dedicated verifier, this function is safe to use in contracts
    /// that have been granted special permissions.
    function isValidERC6492SignatureNowAllowSideEffects(
        address signer,
        bytes32 hash,
        bytes memory signature
    ) internal returns (bool isValid) {
        /// @solidity memory-safe-assembly
        assembly {
            function callIsValidSignature(signer_, hash_, signature_) -> _isValid {
                let m_ := mload(0x40)
                let f_ := shl(224, 0x1626ba7e)
                mstore(m_, f_) // `bytes4(keccak256("isValidSignature(bytes32,bytes)"))`.
                mstore(add(m_, 0x04), hash_)
                let d_ := add(m_, 0x24)
                mstore(d_, 0x40) // The offset of the `signature` in the calldata.
                let n_ := add(0x20, mload(signature_))
                let copied_ := staticcall(gas(), 4, signature_, n_, add(m_, 0x44), n_)
                _isValid := staticcall(gas(), signer_, m_, add(returndatasize(), 0x44), d_, 0x20)
                _isValid := and(eq(mload(d_), f_), and(_isValid, copied_))
            }
            let noCode := iszero(extcodesize(signer))
            let n := mload(signature)
            for {} 1 {} {
                if iszero(eq(mload(add(signature, n)), mul(0x6492, div(not(isValid), 0xffff)))) {
                    if iszero(noCode) { isValid := callIsValidSignature(signer, hash, signature) }
                    break
                }
                if iszero(noCode) {
                    let o := add(signature, 0x20) // Signature bytes.
                    isValid := callIsValidSignature(signer, hash, add(o, mload(add(o, 0x40))))
                    if isValid { break }
                }
                let m := mload(0x40)
                mstore(m, signer)
                mstore(add(m, 0x20), hash)
                pop(
                    call(
                        gas(), // Remaining gas.
                        0x0000bc370E4DC924F427d84e2f4B9Ec81626ba7E, // Non-reverting verifier.
                        0, // Send zero ETH.
                        m, // Start of memory.
                        add(returndatasize(), 0x40), // Length of calldata in memory.
                        staticcall(gas(), 4, add(signature, 0x20), n, add(m, 0x40), n), // 1.
                        0x00 // Length of returndata to write.
                    )
                )
                isValid := returndatasize()
                break
            }
            // Do `ecrecover` fallback if `noCode && !isValid`.
            for {} gt(noCode, isValid) {} {
                switch n
                case 64 {
                    let vs := mload(add(signature, 0x40))
                    mstore(0x20, add(shr(255, vs), 27)) // `v`.
                    mstore(0x60, shr(1, shl(1, vs))) // `s`.
                }
                case 65 {
                    mstore(0x20, byte(0, mload(add(signature, 0x60)))) // `v`.
                    mstore(0x60, mload(add(signature, 0x40))) // `s`.
                }
                default { break }
                let m := mload(0x40)
                mstore(0x00, hash)
                mstore(0x40, mload(add(signature, 0x20))) // `r`.
                let recovered := mload(staticcall(gas(), 1, 0x00, 0x80, 0x01, 0x20))
                isValid := gt(returndatasize(), shl(96, xor(signer, recovered)))
                mstore(0x60, 0) // Restore the zero slot.
                mstore(0x40, m) // Restore the free memory pointer.
                break
            }
        }
    }

    /// @dev Returns whether `signature` is valid for `hash`.
    /// If the signature is postfixed with the ERC6492 magic number, it will attempt
    /// to use a reverting verifier to deploy / prepare the `signer` smart account
    /// and do a `isValidSignature` check via the reverting verifier.
    /// Note: This function is reentrancy safe.
    /// The reverting verifier must be deployed.
    /// Otherwise, the function will return false if `signer` is not yet deployed / prepared.
    /// See: https://gist.github.com/Vectorized/846a474c855eee9e441506676800a9ad
    function isValidERC6492SignatureNow(address signer, bytes32 hash, bytes memory signature)
        internal
        returns (bool isValid)
    {
        /// @solidity memory-safe-assembly
        assembly {
            function callIsValidSignature(signer_, hash_, signature_) -> _isValid {
                let m_ := mload(0x40)
                let f_ := shl(224, 0x1626ba7e)
                mstore(m_, f_) // `bytes4(keccak256("isValidSignature(bytes32,bytes)"))`.
                mstore(add(m_, 0x04), hash_)
                let d_ := add(m_, 0x24)
                mstore(d_, 0x40) // The offset of the `signature` in the calldata.
                let n_ := add(0x20, mload(signature_))
                let copied_ := staticcall(gas(), 4, signature_, n_, add(m_, 0x44), n_)
                _isValid := staticcall(gas(), signer_, m_, add(returndatasize(), 0x44), d_, 0x20)
                _isValid := and(eq(mload(d_), f_), and(_isValid, copied_))
            }
            let noCode := iszero(extcodesize(signer))
            let n := mload(signature)
            for {} 1 {} {
                if iszero(eq(mload(add(signature, n)), mul(0x6492, div(not(isValid), 0xffff)))) {
                    if iszero(noCode) { isValid := callIsValidSignature(signer, hash, signature) }
                    break
                }
                if iszero(noCode) {
                    let o := add(signature, 0x20) // Signature bytes.
                    isValid := callIsValidSignature(signer, hash, add(o, mload(add(o, 0x40))))
                    if isValid { break }
                }
                let m := mload(0x40)
                mstore(m, signer)
                mstore(add(m, 0x20), hash)
                let willBeZeroIfRevertingVerifierExists :=
                    call(
                        gas(), // Remaining gas.
                        0x00007bd799e4A591FeA53f8A8a3E9f931626Ba7e, // Reverting verifier.
                        0, // Send zero ETH.
                        m, // Start of memory.
                        add(returndatasize(), 0x40), // Length of calldata in memory.
                        staticcall(gas(), 4, add(signature, 0x20), n, add(m, 0x40), n), // 1.
                        0x00 // Length of returndata to write.
                    )
                isValid := gt(returndatasize(), willBeZeroIfRevertingVerifierExists)
                break
            }
            // Do `ecrecover` fallback if `noCode && !isValid`.
            for {} gt(noCode, isValid) {} {
                switch n
                case 64 {
                    let vs := mload(add(signature, 0x40))
                    mstore(0x20, add(shr(255, vs), 27)) // `v`.
                    mstore(0x60, shr(1, shl(1, vs))) // `s`.
                }
                case 65 {
                    mstore(0x20, byte(0, mload(add(signature, 0x60)))) // `v`.
                    mstore(0x60, mload(add(signature, 0x40))) // `s`.
                }
                default { break }
                let m := mload(0x40)
                mstore(0x00, hash)
                mstore(0x40, mload(add(signature, 0x20))) // `r`.
                let recovered := mload(staticcall(gas(), 1, 0x00, 0x80, 0x01, 0x20))
                isValid := gt(returndatasize(), shl(96, xor(signer, recovered)))
                mstore(0x60, 0) // Restore the zero slot.
                mstore(0x40, m) // Restore the free memory pointer.
                break
            }
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                     HASHING OPERATIONS                     */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns an Ethereum Signed Message, created from a `hash`.
    /// This produces a hash corresponding to the one signed with the
    /// [`eth_sign`](https://eth.wiki/json-rpc/API#eth_sign)
    /// JSON-RPC method as part of EIP-191.
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32 result) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x20, hash) // Store into scratch space for keccak256.
            mstore(0x00, "\x00\x00\x00\x00\x19Ethereum Signed Message:\n32") // 28 bytes.
            result := keccak256(0x04, 0x3c) // `32 * 2 - (32 - 28) = 60 = 0x3c`.
        }
    }

    /// @dev Returns an Ethereum Signed Message, created from `s`.
    /// This produces a hash corresponding to the one signed with the
    /// [`eth_sign`](https://eth.wiki/json-rpc/API#eth_sign)
    /// JSON-RPC method as part of EIP-191.
    /// Note: Supports lengths of `s` up to 999999 bytes.
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32 result) {
        /// @solidity memory-safe-assembly
        assembly {
            let sLength := mload(s)
            let o := 0x20
            mstore(o, "\x19Ethereum Signed Message:\n") // 26 bytes, zero-right-padded.
            mstore(0x00, 0x00)
            // Convert the `s.length` to ASCII decimal representation: `base10(s.length)`.
            for { let temp := sLength } 1 {} {
                o := sub(o, 1)
                mstore8(o, add(48, mod(temp, 10)))
                temp := div(temp, 10)
                if iszero(temp) { break }
            }
            let n := sub(0x3a, o) // Header length: `26 + 32 - o`.
            // Throw an out-of-offset error (consumes all gas) if the header exceeds 32 bytes.
            returndatacopy(returndatasize(), returndatasize(), gt(n, 0x20))
            mstore(s, or(mload(0x00), mload(n))) // Temporarily store the header.
            result := keccak256(add(s, sub(0x20, n)), add(n, sLength))
            mstore(s, sLength) // Restore the length.
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                   EMPTY CALLDATA HELPERS                   */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns an empty calldata bytes.
    function emptySignature() internal pure returns (bytes calldata signature) {
        /// @solidity memory-safe-assembly
        assembly {
            signature.length := 0
        }
    }
}
// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.24;

interface IGenesisStake {
    /**
     * @notice Stake `amount` tokens.
     * @param amount    The amount of tokens to stake.
     */
    function stake(uint256 amount) external;

    /**
     * @notice Stake `amount` tokens for `recipient`, paid by the caller.
     * @param recipient The recipient to stake tokens for.
     * @param amount    The amount of tokens to stake.
     */
    function stakeFor(address recipient, uint256 amount) external;

    /**
     * @notice Unstake your entire balance, starting the unbonding period.
     */
    function unstake() external;

    /**
     * @notice Withdraw your entire balance after the unbonding period.
     */
    function withdraw() external;

    /**
     * @notice Migrate a user's stake to the rewards distributor.
     * @param addr The address of the user to migrate.
     * @return The amount of tokens migrated.
     */
    function migrateStake(address addr) external returns (uint256);

    /**
     * @notice Returns timestamp at which `account` can withdraw.
     *         Reverts if the account has not staked & unstaked.
     */
    function canWithdrawAt(address account) external view returns (uint256);
}
// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.24;

interface IMerkleDistributor {
    // This event is triggered whenever a call to #claim succeeds.
    event Claimed(uint256 index, address account, uint256 amount);

    // Returns the address of the token distributed by this contract.
    function token() external view returns (address);
    // Returns the merkle root of the merkle tree containing account balances available to claim.
    function merkleRoot() external view returns (bytes32);
    // Returns true if the index has been marked claimed.
    function isClaimed(uint256 index) external view returns (bool);
    // Claim the given amount of the token to the given address. Reverts if the inputs are invalid.
    function claim(uint256 index, address account, uint256 amount, bytes32[] calldata merkleProof) external;
}
// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.12;

import { XTypes } from "../libraries/XTypes.sol";

/**
 * @title IOmniPortal
 * @notice The OmniPortal is the on-chain interface to Omni's cross-chain
 *         messaging protocol. It is used to initiate and execute cross-chain calls.
 */
interface IOmniPortal {
    /**
     * @notice Emitted when an xcall is made to a contract on another chain
     * @param destChainId   Destination chain ID
     * @param offset        Offset this XMsg in the source -> dest XStream
     * @param sender        msg.sender of the source xcall
     * @param to            Address of the contract to call on the destination chain
     * @param data          Encoded function calldata
     * @param gasLimit      Gas limit for execution on destination chain
     * @param fees          Fees paid for the xcall
     */
    event XMsg(
        uint64 indexed destChainId,
        uint64 indexed shardId,
        uint64 indexed offset,
        address sender,
        address to,
        bytes data,
        uint64 gasLimit,
        uint256 fees
    );

    /**
     * @notice Emitted when an XMsg is executed on its destination chain
     * @param sourceChainId Source chain ID
     * @param shardId       Shard ID of the XStream (last byte is the confirmation level)
     * @param offset        Offset the XMsg in the source -> dest XStream
     * @param gasUsed       Gas used in execution of the XMsg
     * @param relayer       Address of the relayer who submitted the XMsg
     * @param success       Whether the execution succeeded
     * @param err           Result of XMsg execution, if success == false. Limited to
     *                      xreceiptMaxErrorBytes(). Empty if success == true.
     */
    event XReceipt(
        uint64 indexed sourceChainId,
        uint64 indexed shardId,
        uint64 indexed offset,
        uint256 gasUsed,
        address relayer,
        bool success,
        bytes err
    );

    /**
     * @notice Maximum allowed xmsg gas limit
     */
    function xmsgMaxGasLimit() external view returns (uint64);

    /**
     * @notice Minimum allowed xmsg gas limit
     */
    function xmsgMinGasLimit() external view returns (uint64);

    /**
     * @notice Maximum number of bytes allowed in xmsg data
     */
    function xmsgMaxDataSize() external view returns (uint16);

    /**
     * @notice Maximum number of bytes allowed in xreceipt result
     */
    function xreceiptMaxErrorSize() external view returns (uint16);

    /**
     * @notice Returns the fee oracle address
     */
    function feeOracle() external view returns (address);

    /**
     * @notice Returns the chain ID of the chain to which this portal is deployed
     */
    function chainId() external view returns (uint64);

    /**
     * @notice Returns the chain ID of Omni's EVM execution chain
     */
    function omniChainId() external view returns (uint64);

    /**
     * @notice Returns the offset of the last outbound XMsg sent to destChainId in shardId
     */
    function outXMsgOffset(uint64 destChainId, uint64 shardId) external view returns (uint64);

    /**
     * @notice Returns the offset of the last inbound XMsg received from srcChainId in shardId
     */
    function inXMsgOffset(uint64 srcChainId, uint64 shardId) external view returns (uint64);

    /**
     * @notice Returns the offset of the last inbound XBlock received from srcChainId in shardId
     */
    function inXBlockOffset(uint64 srcChainId, uint64 shardId) external view returns (uint64);

    /**
     * @notice Returns the current XMsg being executed via this portal.
     *          - xmsg().sourceChainId  Chain ID of the source xcall
     *          - xmsg().sender         msg.sender of the source xcall
     *         If no XMsg is being executed, all fields will be zero.
     *          - xmsg().sourceChainId  == 0
     *          - xmsg().sender         == address(0)
     */
    function xmsg() external view returns (XTypes.MsgContext memory);

    /**
     * @notice Returns true the current transaction is an xcall, false otherwise
     */
    function isXCall() external view returns (bool);

    /**
     * @notice Returns the shard ID is supported by this portal
     */
    function isSupportedShard(uint64 shardId) external view returns (bool);

    /**
     * @notice Returns the destination chain ID is supported by this portal
     */
    function isSupportedDest(uint64 destChainId) external view returns (bool);

    /**
     * @notice Calculate the fee for calling a contract on another chain
     *         Fees denominated in wei.
     * @param destChainId   Destination chain ID
     * @param data          Encoded function calldata
     * @param gasLimit      Execution gas limit, enforced on destination chain
     */
    function feeFor(uint64 destChainId, bytes calldata data, uint64 gasLimit) external view returns (uint256);

    /**
     * @notice Call a contract on another chain.
     * @param destChainId   Destination chain ID
     * @param conf          Confirmation level;
     * @param to            Address of contract to call on destination chain
     * @param data          ABI Encoded function calldata
     * @param gasLimit      Execution gas limit, enforced on destination chain
     */
    function xcall(uint64 destChainId, uint8 conf, address to, bytes calldata data, uint64 gasLimit) external payable;

    /**
     * @notice Submit a batch of XMsgs to be executed on this chain
     * @param xsub  An xchain submission, including an attestation root w/ validator signatures,
     *              and a block header and message batch, proven against the attestation root.
     */
    function xsubmit(XTypes.Submission calldata xsub) external;

    /**
     * @notice Returns the current network (supported chain IDs and shards)
     */
    function network() external view returns (XTypes.Chain[] memory);
}
// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.24;

interface IStaking {
    /**
     * @notice Delegate tokens to a validator for another address
     * @param delegator The address of the delegator
     * @param validator The address of the validator to delegate to
     */
    function delegateFor(address delegator, address validator) external payable;
}
// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.12;

/**
 * @title XTypes
 * @dev Defines xchain types, core to Omni's xchain messaging protocol. These
 *      types mirror those defined in omni/lib/xchain/types.go.
 */
library XTypes {
    /**
     * @notice A cross chain message - the product of an xcall. This matches the XMsg type used
     *        throughout Omni's cross-chain messaging protocol. Msg is used to construct and verify
     *        XSubmission merkle trees / proofs.
     * @custom:field destChainId    Chain ID of the destination chain
     * @custom:field shardId        Shard ID of the XStream (last byte is the confirmation level)
     * @custom:field offset         Monotonically incremented offset of Msg in source -> dest Stream
     * @custom:field sender         msg.sender of xcall on source chain
     * @custom:field to             Target address to call on destination chain
     * @custom:field data           Data to provide to call on destination chain
     * @custom:field gasLimit       Gas limit to use for call execution on destination chain
     */
    struct Msg {
        uint64 destChainId;
        uint64 shardId;
        uint64 offset;
        address sender;
        address to;
        bytes data;
        uint64 gasLimit;
    }

    /**
     * @notice Msg context exposed during its execution to consuming xapps.
     * @custom:field sourceChainId  Chain ID of the source chain
     * @custom:field sender         msg.sender of xcall on source chain
     */
    struct MsgContext {
        uint64 sourceChainId;
        address sender;
    }

    /**
     * @notice BlockHeader of an XBlock.
     * @custom:field sourceChainId      Chain ID of the source chain
     * @custom:field consensusChainId   Chain ID of the Omni consensus chain
     * @custom:field confLevel          Confirmation level of the cross chain block
     * @custom:field offset             Offset of the cross chain block
     * @custom:field sourceBlockHeight  Height of the source chain block
     * @custom:field sourceBlockHash    Hash of the source chain block
     */
    struct BlockHeader {
        uint64 sourceChainId;
        uint64 consensusChainId;
        uint8 confLevel;
        uint64 offset;
        uint64 sourceBlockHeight;
        bytes32 sourceBlockHash;
    }

    /**
     * @notice The required parameters to submit xmsgs to an OmniPortal. Constructed by the relayer
     *         by watching Omni's consensus chain, and source chain blocks.
     * @custom:field attestationRoot  Merkle root of xchain block (XBlockRoot), attested to and signed by validators
     * @custom:field validatorSetId   Unique identifier of the validator set that attested to this root
     * @custom:field blockHeader      Block header, identifies xchain block
     * @custom:field msgs             Messages to execute
     * @custom:field proof            Multi proof of block header and messages, proven against attestationRoot
     * @custom:field proofFlags       Multi proof flags
     * @custom:field signatures       Array of validator signatures of the attestationRoot, and their public keys
     */
    struct Submission {
        bytes32 attestationRoot;
        uint64 validatorSetId;
        BlockHeader blockHeader;
        Msg[] msgs;
        bytes32[] proof;
        bool[] proofFlags;
        SigTuple[] signatures;
    }

    /**
     * @notice A tuple of a validator's ethereum address and signature over some digest.
     * @custom:field validatorAddr  Validator ethereum address
     * @custom:field signature      Validator signature over some digest; Ethereum 65 bytes [R || S || V] format.
     */
    struct SigTuple {
        address validatorAddr;
        bytes signature;
    }

    /**
     * @notice An Omni validator, specified by their ethereum address and voting power.
     * @custom:field addr   Validator ethereum address
     * @custom:field power  Validator voting power
     */
    struct Validator {
        address addr;
        uint64 power;
    }

    /**
     * @notice A chain in the "omni network" specified by its chain ID and supported shards.
     * @custom:field chainId  Chain ID
     * @custom:field shards   Supported shards
     */
    struct Chain {
        uint64 chainId;
        uint64[] shards;
    }
}
// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.24;

import { IMerkleDistributor } from "../interfaces/IMerkleDistributor.sol";
import { LibBitmap } from "solady/src/utils/LibBitmap.sol";
import { MerkleProofLib } from "solady/src/utils/MerkleProofLib.sol";
import { SafeTransferLib } from "solady/src/utils/SafeTransferLib.sol";

contract MerkleDistributor is IMerkleDistributor {
    using LibBitmap for LibBitmap.Bitmap;
    using SafeTransferLib for address;

    error AlreadyClaimed();
    error InvalidProof();

    address public immutable override token;
    bytes32 public immutable override merkleRoot;

    // This is a packed array of booleans.
    LibBitmap.Bitmap internal claimedBitMap;

    constructor(address token_, bytes32 merkleRoot_) {
        token = token_;
        merkleRoot = merkleRoot_;
    }

    function isClaimed(uint256 index) public view virtual override returns (bool) {
        return claimedBitMap.get(index);
    }

    function claim(uint256 index, address account, uint256 amount, bytes32[] calldata merkleProof)
        public
        virtual
        override
    {
        if (isClaimed(index)) revert AlreadyClaimed();

        // Verify the merkle proof.
        bytes32 node = keccak256(abi.encodePacked(index, account, amount));
        if (!MerkleProofLib.verifyCalldata(merkleProof, merkleRoot, node)) revert InvalidProof();

        // Mark it claimed and send the token.
        claimedBitMap.set(index);
        token.safeTransfer(account, amount);

        emit Claimed(index, account, amount);
    }
}
// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.24;

import { MerkleDistributor } from "./MerkleDistributor.sol";
import { Ownable } from "solady/src/auth/Ownable.sol";
import { EIP712 } from "solady/src/utils/EIP712.sol";
import { SignatureCheckerLib } from "solady/src/utils/SignatureCheckerLib.sol";
import { SafeTransferLib } from "solady/src/utils/SafeTransferLib.sol";
import { MerkleProofLib } from "solady/src/utils/MerkleProofLib.sol";
import { LibBitmap } from "solady/src/utils/LibBitmap.sol";
import { IStaking } from "../interfaces/IStaking.sol";
import { IOmniPortal } from "../interfaces/IOmniPortal.sol";
import { IGenesisStake } from "../interfaces/IGenesisStake.sol";
import { IERC7683, IOriginSettler } from "solve/src/erc7683/IOriginSettler.sol";
import { SolverNet } from "solve/src/lib/SolverNet.sol";

contract MerkleDistributorWithDeadline is MerkleDistributor, Ownable, EIP712 {
    using LibBitmap for LibBitmap.Bitmap;
    using SafeTransferLib for address;

    error Expired();
    error ZeroAddress();
    error EndTimeInPast();
    error InvalidSignature();
    error InsufficientAmount();
    error ClaimWindowFinished();
    error NoWithdrawDuringClaim();

    bytes32 internal constant ORDERDATA_TYPEHASH = keccak256(
        "OrderData(address owner,uint64 destChainId,Deposit deposit,Call[] calls,TokenExpense[] expenses)Deposit(address token,uint96 amount)Call(address target,bytes4 selector,uint256 value,bytes params)TokenExpense(address spender,address token,uint96 amount)"
    );
    bytes32 internal constant UPGRADE_TYPEHASH =
        keccak256("Upgrade(address user,address validator,uint256 nonce,uint256 expiry)");

    address internal constant STAKING = 0xCCcCcC0000000000000000000000000000000001;

    uint256 public immutable endTime;
    IOmniPortal public immutable omniPortal;
    IGenesisStake public immutable genesisStaking;
    IOriginSettler public immutable solvernetInbox;

    mapping(address account => uint256) public nonces;

    constructor(
        address admin,
        address token_,
        bytes32 merkleRoot_,
        uint256 endTime_,
        address omniPortal_,
        address genesisStaking_,
        address solverNetInbox_
    ) MerkleDistributor(token_, merkleRoot_) {
        if (endTime_ <= block.timestamp) revert EndTimeInPast();

        _initializeOwner(admin);
        token_.safeApprove(solverNetInbox_, type(uint256).max);

        endTime = endTime_;
        omniPortal = IOmniPortal(omniPortal_);
        genesisStaking = IGenesisStake(genesisStaking_);
        solvernetInbox = IOriginSettler(solverNetInbox_);
    }

    /**
     * @notice Get the EIP-712 digest for a stake upgrade signature
     * @param account   Address of the user upgrading
     * @param validator Validator to delegate to
     * @param expiry    Signature expiry
     * @return _        Upgrade digest
     */
    function getUpgradeDigest(address account, address validator, uint256 expiry) public view returns (bytes32) {
        if (expiry != 0 && block.timestamp > expiry) revert Expired();
        bytes32 migrationHash = keccak256(abi.encode(UPGRADE_TYPEHASH, account, validator, nonces[account], expiry));
        return _hashTypedData(migrationHash);
    }

    /**
     * @notice Claim rewards
     * @dev Does not trigger any changes on the GenesisStake contract
     * @param index        Index of the claim
     * @param account      Address of the user claiming
     * @param amount       Amount of tokens to claim
     * @param merkleProof  Merkle proof for the claim
     */
    function claim(uint256 index, address account, uint256 amount, bytes32[] calldata merkleProof) public override {
        if (block.timestamp > endTime) revert ClaimWindowFinished();
        super.claim(index, account, amount, merkleProof);
    }

    /**
     * @notice Claim rewards and upgrade stake to Omni
     * @dev Triggers a SolverNet order to generate a subsidized order for deposited tokens on Omni 1:1
     *      If the user has already claimed rewards, they can still upgrade their stake to Omni
     * @param validator    Validator to delegate to
     * @param index        Index of the claim
     * @param amount       Amount of tokens to claim
     * @param merkleProof  Merkle proof for the claim
     */
    function upgradeStake(address validator, uint256 index, uint256 amount, bytes32[] calldata merkleProof) external {
        unchecked {
            ++nonces[msg.sender];
        }
        _upgrade(msg.sender, validator, index, amount, merkleProof);
    }

    /**
     * @notice Claim rewards and upgrade stake to Omni on behalf of a user
     * @dev Triggers a SolverNet order to generate a subsidized order for deposited tokens on Omni 1:1
     *      If the user has already claimed rewards, they can still upgrade their stake to Omni
     * @param account      Address of the user upgrading
     * @param validator    Validator to delegate to
     * @param index        Index of the claim
     * @param amount       Amount of tokens to claim
     * @param merkleProof  Merkle proof for the claim
     * @param v            Signature v
     * @param r            Signature r
     * @param s            Signature s
     * @param expiry       Signature expiry
     */
    function upgradeUserStake(
        address account,
        address validator,
        uint256 index,
        uint256 amount,
        bytes32[] calldata merkleProof,
        uint8 v,
        bytes32 r,
        bytes32 s,
        uint256 expiry
    ) external {
        // If the user isn't the caller, verify the signature
        if (account != msg.sender) {
            bytes32 digest = getUpgradeDigest(account, validator, expiry);

            if (!SignatureCheckerLib.isValidSignatureNow(account, digest, v, r, s)) {
                if (!SignatureCheckerLib.isValidERC1271SignatureNow(account, digest, v, r, s)) {
                    revert InvalidSignature();
                }
            }

            unchecked {
                ++nonces[account];
            }
        }

        _upgrade(account, validator, index, amount, merkleProof);
    }

    /**
     * @notice Withdraw tokens from the contract
     * @dev Reverts if called before the claim window has ended
     * @param to Address to send the tokens to
     */
    function withdraw(address to) external onlyOwner {
        if (block.timestamp < endTime) revert NoWithdrawDuringClaim();
        token.safeTransfer(to, token.balanceOf(address(this)));
    }

    /**
     * @notice Upgrade stake to Omni
     * @param account      Address of the user upgrading
     * @param validator    Validator to delegate to
     * @param index        Index of the claim
     * @param amount       Amount of tokens to claim
     * @param merkleProof  Merkle proof for the claim
     */
    function _upgrade(address account, address validator, uint256 index, uint256 amount, bytes32[] calldata merkleProof)
        internal
    {
        if (block.timestamp > endTime) revert ClaimWindowFinished();
        if (validator == address(0)) revert ZeroAddress();

        // Migrate user's stake, if any
        uint256 stake = IGenesisStake(genesisStaking).migrateStake(account);

        // If proofs are provided, check if the user is eligible for rewards and add them to their stake
        if (merkleProof.length > 0) {
            if (_claimRewards(account, index, amount, merkleProof)) {
                unchecked {
                    stake += amount;
                }
            }
        }

        // Block insufficient stake migrations
        if (stake < 1 ether) revert InsufficientAmount();

        // Generate and send the order
        IERC7683.OnchainCrossChainOrder memory order = _generateOrder(account, validator, stake);
        solvernetInbox.open(order);
    }

    /**
     * @notice Claim rewards
     * @dev Reverts if merkle proofs are invalid
     * @param account  Address of the user claiming
     * @param index    Index of the claim
     * @param amount   Amount of tokens to claim
     * @return _       True if the claim was processed, false if already claimed
     */
    function _claimRewards(address account, uint256 index, uint256 amount, bytes32[] calldata merkleProof)
        internal
        returns (bool)
    {
        // If rewards are unclaimed, verify the proof and process the claim
        if (!isClaimed(index)) {
            bytes32 leaf = keccak256(abi.encodePacked(index, account, amount));
            if (!MerkleProofLib.verifyCalldata(merkleProof, merkleRoot, leaf)) revert InvalidProof();
            claimedBitMap.set(index);
            return true;
        }
        return false;
    }

    /**
     * @notice Generate a SolverNet order that generates a subsidized order for deposited tokens on Omni 1:1
     * @param account   Address of the user claiming
     * @param validator Validator to delegate to
     * @param amount    Amount of tokens to claim
     * @return         SolverNet order
     */
    function _generateOrder(address account, address validator, uint256 amount)
        internal
        view
        returns (IERC7683.OnchainCrossChainOrder memory)
    {
        SolverNet.Deposit memory deposit = SolverNet.Deposit({ token: token, amount: uint96(amount) });

        SolverNet.Call[] memory call = new SolverNet.Call[](1);
        call[0] = SolverNet.Call({
            target: STAKING,
            selector: IStaking.delegateFor.selector,
            value: amount,
            params: abi.encode(account, validator)
        });

        SolverNet.OrderData memory orderData = SolverNet.OrderData({
            owner: account,
            destChainId: omniPortal.omniChainId(),
            deposit: deposit,
            calls: call,
            expenses: new SolverNet.TokenExpense[](0)
        });

        return IERC7683.OnchainCrossChainOrder({
            fillDeadline: uint32(block.timestamp + 24 hours),
            orderDataType: ORDERDATA_TYPEHASH,
            orderData: abi.encode(orderData)
        });
    }

    function _domainNameAndVersion() internal pure override returns (string memory name, string memory version) {
        name = "MerkleDistributorWithDeadline";
        version = "1";
    }
}