// SPDX-License-Identifier: LGPL-3.0-or-later
pragma solidity >=0.7.6 <0.9.0;

library GPv2EIP1271 {
    /// @dev Value returned by a call to `isValidSignature` if the signature
    /// was verified successfully. The value is defined in EIP-1271 as:
    /// bytes4(keccak256("isValidSignature(bytes32,bytes)"))
    bytes4 internal constant MAGICVALUE = 0x1626ba7e;
}

/// @title EIP1271 Interface
/// @dev Standardized interface for an implementation of smart contract
/// signatures as described in EIP-1271. The code that follows is identical to
/// the code in the standard with the exception of formatting and syntax
/// changes to adapt the code to our Solidity version.
interface EIP1271Verifier {
    /// @dev Should return whether the signature provided is valid for the
    /// provided data
    /// @param _hash      Hash of the data to be signed
    /// @param _signature Signature byte array associated with _data
    ///
    /// MUST return the bytes4 magic value 0x1626ba7e when function passes.
    /// MUST NOT modify state (using STATICCALL for solc < 0.5, view modifier for
    /// solc > 0.5)
    /// MUST allow external calls
    ///
    function isValidSignature(
        bytes32 _hash,
        bytes memory _signature
    ) external view returns (bytes4 magicValue);
}
// SPDX-License-Identifier: MIT

// Vendored from OpenZeppelin contracts with minor modifications:
// - Modified Solidity version
// - Formatted code
// - Added `name`, `symbol` and `decimals` function declarations
// <https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/token/ERC20/IERC20.sol>

pragma solidity >=0.7.6 <0.9.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the number of decimals the token uses.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}
// SPDX-License-Identifier: LGPL-3.0-or-later
pragma solidity >=0.7.6 <0.9.0;

/// @title Gnosis Protocol v2 Interaction Library
/// @author Gnosis Developers
library GPv2Interaction {
    /// @dev Interaction data for performing arbitrary contract interactions.
    /// Submitted to [`GPv2Settlement.settle`] for code execution.
    struct Data {
        address target;
        uint256 value;
        bytes callData;
    }

    /// @dev Execute an arbitrary contract interaction.
    ///
    /// @param interaction Interaction data.
    function execute(Data calldata interaction) internal {
        address target = interaction.target;
        uint256 value = interaction.value;
        bytes calldata callData = interaction.callData;

        // NOTE: Use assembly to call the interaction instead of a low level
        // call for two reasons:
        // - We don't want to copy the return data, since we discard it for
        // interactions.
        // - Solidity will under certain conditions generate code to copy input
        // calldata twice to memory (the second being a "memcopy loop").
        // <https://github.com/gnosis/gp-v2-contracts/pull/417#issuecomment-775091258>
        // solhint-disable-next-line no-inline-assembly
        assembly {
            let freeMemoryPointer := mload(0x40)
            calldatacopy(freeMemoryPointer, callData.offset, callData.length)
            if iszero(
                call(
                    gas(),
                    target,
                    value,
                    freeMemoryPointer,
                    callData.length,
                    0,
                    0
                )
            ) {
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }
        }
    }

    /// @dev Extracts the Solidity ABI selector for the specified interaction.
    ///
    /// @param interaction Interaction data.
    /// @return result The 4 byte function selector of the call encoded in
    /// this interaction.
    function selector(
        Data calldata interaction
    ) internal pure returns (bytes4 result) {
        bytes calldata callData = interaction.callData;
        if (callData.length >= 4) {
            // NOTE: Read the first word of the interaction's calldata. The
            // value does not need to be shifted since `bytesN` values are left
            // aligned, and the value does not need to be masked since masking
            // occurs when the value is accessed and not stored:
            // <https://docs.soliditylang.org/en/v0.7.6/abi-spec.html#encoding-of-indexed-event-parameters>
            // <https://docs.soliditylang.org/en/v0.7.6/assembly.html#access-to-external-variables-functions-and-libraries>
            // solhint-disable-next-line no-inline-assembly
            assembly {
                result := calldataload(callData.offset)
            }
        }
    }
}
// SPDX-License-Identifier: LGPL-3.0-or-later
pragma solidity >=0.7.6 <0.9.0;

import "../interfaces/IERC20.sol";

/// @title Gnosis Protocol v2 Order Library
/// @author Gnosis Developers
library GPv2Order {
    /// @dev The complete data for a Gnosis Protocol order. This struct contains
    /// all order parameters that are signed for submitting to GP.
    struct Data {
        IERC20 sellToken;
        IERC20 buyToken;
        address receiver;
        uint256 sellAmount;
        uint256 buyAmount;
        uint32 validTo;
        bytes32 appData;
        uint256 feeAmount;
        bytes32 kind;
        bool partiallyFillable;
        bytes32 sellTokenBalance;
        bytes32 buyTokenBalance;
    }

    /// @dev The order EIP-712 type hash for the [`GPv2Order.Data`] struct.
    ///
    /// This value is pre-computed from the following expression:
    /// ```
    /// keccak256(
    ///     "Order(" +
    ///         "address sellToken," +
    ///         "address buyToken," +
    ///         "address receiver," +
    ///         "uint256 sellAmount," +
    ///         "uint256 buyAmount," +
    ///         "uint32 validTo," +
    ///         "bytes32 appData," +
    ///         "uint256 feeAmount," +
    ///         "string kind," +
    ///         "bool partiallyFillable," +
    ///         "string sellTokenBalance," +
    ///         "string buyTokenBalance" +
    ///     ")"
    /// )
    /// ```
    bytes32 internal constant TYPE_HASH =
        hex"d5a25ba2e97094ad7d83dc28a6572da797d6b3e7fc6663bd93efb789fc17e489";

    /// @dev The marker value for a sell order for computing the order struct
    /// hash. This allows the EIP-712 compatible wallets to display a
    /// descriptive string for the order kind (instead of 0 or 1).
    ///
    /// This value is pre-computed from the following expression:
    /// ```
    /// keccak256("sell")
    /// ```
    bytes32 internal constant KIND_SELL =
        hex"f3b277728b3fee749481eb3e0b3b48980dbbab78658fc419025cb16eee346775";

    /// @dev The OrderKind marker value for a buy order for computing the order
    /// struct hash.
    ///
    /// This value is pre-computed from the following expression:
    /// ```
    /// keccak256("buy")
    /// ```
    bytes32 internal constant KIND_BUY =
        hex"6ed88e868af0a1983e3886d5f3e95a2fafbd6c3450bc229e27342283dc429ccc";

    /// @dev The TokenBalance marker value for using direct ERC20 balances for
    /// computing the order struct hash.
    ///
    /// This value is pre-computed from the following expression:
    /// ```
    /// keccak256("erc20")
    /// ```
    bytes32 internal constant BALANCE_ERC20 =
        hex"5a28e9363bb942b639270062aa6bb295f434bcdfc42c97267bf003f272060dc9";

    /// @dev The TokenBalance marker value for using Balancer Vault external
    /// balances (in order to re-use Vault ERC20 approvals) for computing the
    /// order struct hash.
    ///
    /// This value is pre-computed from the following expression:
    /// ```
    /// keccak256("external")
    /// ```
    bytes32 internal constant BALANCE_EXTERNAL =
        hex"abee3b73373acd583a130924aad6dc38cfdc44ba0555ba94ce2ff63980ea0632";

    /// @dev The TokenBalance marker value for using Balancer Vault internal
    /// balances for computing the order struct hash.
    ///
    /// This value is pre-computed from the following expression:
    /// ```
    /// keccak256("internal")
    /// ```
    bytes32 internal constant BALANCE_INTERNAL =
        hex"4ac99ace14ee0a5ef932dc609df0943ab7ac16b7583634612f8dc35a4289a6ce";

    /// @dev Marker address used to indicate that the receiver of the trade
    /// proceeds should the owner of the order.
    ///
    /// This is chosen to be `address(0)` for gas efficiency as it is expected
    /// to be the most common case.
    address internal constant RECEIVER_SAME_AS_OWNER = address(0);

    /// @dev The byte length of an order unique identifier.
    uint256 internal constant UID_LENGTH = 56;

    /// @dev Returns the actual receiver for an order. This function checks
    /// whether or not the [`receiver`] field uses the marker value to indicate
    /// it is the same as the order owner.
    ///
    /// @return receiver The actual receiver of trade proceeds.
    function actualReceiver(
        Data memory order,
        address owner
    ) internal pure returns (address receiver) {
        if (order.receiver == RECEIVER_SAME_AS_OWNER) {
            receiver = owner;
        } else {
            receiver = order.receiver;
        }
    }

    /// @dev Return the EIP-712 signing hash for the specified order.
    ///
    /// @param order The order to compute the EIP-712 signing hash for.
    /// @param domainSeparator The EIP-712 domain separator to use.
    /// @return orderDigest The 32 byte EIP-712 struct hash.
    function hash(
        Data memory order,
        bytes32 domainSeparator
    ) internal pure returns (bytes32 orderDigest) {
        bytes32 structHash;

        // NOTE: Compute the EIP-712 order struct hash in place. As suggested
        // in the EIP proposal, noting that the order struct has 12 fields, and
        // prefixing the type hash `(1 + 12) * 32 = 416` bytes to hash.
        // <https://github.com/ethereum/EIPs/blob/master/EIPS/eip-712.md#rationale-for-encodedata>
        // solhint-disable-next-line no-inline-assembly
        assembly {
            let dataStart := sub(order, 32)
            let temp := mload(dataStart)
            mstore(dataStart, TYPE_HASH)
            structHash := keccak256(dataStart, 416)
            mstore(dataStart, temp)
        }

        // NOTE: Now that we have the struct hash, compute the EIP-712 signing
        // hash using scratch memory past the free memory pointer. The signing
        // hash is computed from `"\x19\x01" || domainSeparator || structHash`.
        // <https://docs.soliditylang.org/en/v0.7.6/internals/layout_in_memory.html#layout-in-memory>
        // <https://github.com/ethereum/EIPs/blob/master/EIPS/eip-712.md#specification>
        // solhint-disable-next-line no-inline-assembly
        assembly {
            let freeMemoryPointer := mload(0x40)
            mstore(freeMemoryPointer, "\x19\x01")
            mstore(add(freeMemoryPointer, 2), domainSeparator)
            mstore(add(freeMemoryPointer, 34), structHash)
            orderDigest := keccak256(freeMemoryPointer, 66)
        }
    }

    /// @dev Packs order UID parameters into the specified memory location. The
    /// result is equivalent to `abi.encodePacked(...)` with the difference that
    /// it allows re-using the memory for packing the order UID.
    ///
    /// This function reverts if the order UID buffer is not the correct size.
    ///
    /// @param orderUid The buffer pack the order UID parameters into.
    /// @param orderDigest The EIP-712 struct digest derived from the order
    /// parameters.
    /// @param owner The address of the user who owns this order.
    /// @param validTo The epoch time at which the order will stop being valid.
    function packOrderUidParams(
        bytes memory orderUid,
        bytes32 orderDigest,
        address owner,
        uint32 validTo
    ) internal pure {
        require(orderUid.length == UID_LENGTH, "GPv2: uid buffer overflow");

        // NOTE: Write the order UID to the allocated memory buffer. The order
        // parameters are written to memory in **reverse order** as memory
        // operations write 32-bytes at a time and we want to use a packed
        // encoding. This means, for example, that after writing the value of
        // `owner` to bytes `20:52`, writing the `orderDigest` to bytes `0:32`
        // will **overwrite** bytes `20:32`. This is desirable as addresses are
        // only 20 bytes and `20:32` should be `0`s:
        //
        //        |           1111111111222222222233333333334444444444555555
        //   byte | 01234567890123456789012345678901234567890123456789012345
        // -------+---------------------------------------------------------
        //  field | [.........orderDigest..........][......owner.......][vT]
        // -------+---------------------------------------------------------
        // mstore |                         [000000000000000000000000000.vT]
        //        |                     [00000000000.......owner.......]
        //        | [.........orderDigest..........]
        //
        // Additionally, since Solidity `bytes memory` are length prefixed,
        // 32 needs to be added to all the offsets.
        //
        // solhint-disable-next-line no-inline-assembly
        assembly {
            mstore(add(orderUid, 56), validTo)
            mstore(add(orderUid, 52), owner)
            mstore(add(orderUid, 32), orderDigest)
        }
    }

    /// @dev Extracts specific order information from the standardized unique
    /// order id of the protocol.
    ///
    /// @param orderUid The unique identifier used to represent an order in
    /// the protocol. This uid is the packed concatenation of the order digest,
    /// the validTo order parameter and the address of the user who created the
    /// order. It is used by the user to interface with the contract directly,
    /// and not by calls that are triggered by the solvers.
    /// @return orderDigest The EIP-712 signing digest derived from the order
    /// parameters.
    /// @return owner The address of the user who owns this order.
    /// @return validTo The epoch time at which the order will stop being valid.
    function extractOrderUidParams(
        bytes calldata orderUid
    )
        internal
        pure
        returns (bytes32 orderDigest, address owner, uint32 validTo)
    {
        require(orderUid.length == UID_LENGTH, "GPv2: invalid uid");

        // Use assembly to efficiently decode packed calldata.
        // solhint-disable-next-line no-inline-assembly
        assembly {
            orderDigest := calldataload(orderUid.offset)
            owner := shr(96, calldataload(add(orderUid.offset, 32)))
            validTo := shr(224, calldataload(add(orderUid.offset, 52)))
        }
    }
}
// SPDX-License-Identifier: LGPL-3.0-or-later
pragma solidity >=0.7.6 <0.9.0;

import "../interfaces/IERC20.sol";
import "../mixins/GPv2Signing.sol";
import "./GPv2Order.sol";

/// @title Gnosis Protocol v2 Trade Library.
/// @author Gnosis Developers
library GPv2Trade {
    using GPv2Order for GPv2Order.Data;
    using GPv2Order for bytes;

    /// @dev A struct representing a trade to be executed as part a batch
    /// settlement.
    struct Data {
        uint256 sellTokenIndex;
        uint256 buyTokenIndex;
        address receiver;
        uint256 sellAmount;
        uint256 buyAmount;
        uint32 validTo;
        bytes32 appData;
        uint256 feeAmount;
        uint256 flags;
        uint256 executedAmount;
        bytes signature;
    }

    /// @dev Extracts the order data and signing scheme for the specified trade.
    ///
    /// @param trade The trade.
    /// @param tokens The list of tokens included in the settlement. The token
    /// indices in the trade parameters map to tokens in this array.
    /// @param order The memory location to extract the order data to.
    function extractOrder(
        Data calldata trade,
        IERC20[] calldata tokens,
        GPv2Order.Data memory order
    ) internal pure returns (GPv2Signing.Scheme signingScheme) {
        order.sellToken = tokens[trade.sellTokenIndex];
        order.buyToken = tokens[trade.buyTokenIndex];
        order.receiver = trade.receiver;
        order.sellAmount = trade.sellAmount;
        order.buyAmount = trade.buyAmount;
        order.validTo = trade.validTo;
        order.appData = trade.appData;
        order.feeAmount = trade.feeAmount;
        (
            order.kind,
            order.partiallyFillable,
            order.sellTokenBalance,
            order.buyTokenBalance,
            signingScheme
        ) = extractFlags(trade.flags);
    }

    /// @dev Decodes trade flags.
    ///
    /// Trade flags are used to tightly encode information on how to decode
    /// an order. Examples that directly affect the structure of an order are
    /// the kind of order (either a sell or a buy order) as well as whether the
    /// order is partially fillable or if it is a "fill-or-kill" order. It also
    /// encodes the signature scheme used to validate the order. As the most
    /// likely values are fill-or-kill sell orders by an externally owned
    /// account, the flags are chosen such that `0x00` represents this kind of
    /// order. The flags byte uses the following format:
    ///
    /// ```
    /// bit | 31 ...   | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
    /// ----+----------+-------+---+-------+---+---+
    ///     | reserved | *   * | * | *   * | * | * |
    ///                  |   |   |   |   |   |   |
    ///                  |   |   |   |   |   |   +---- order kind bit, 0 for a sell order
    ///                  |   |   |   |   |   |         and 1 for a buy order
    ///                  |   |   |   |   |   |
    ///                  |   |   |   |   |   +-------- order fill bit, 0 for fill-or-kill
    ///                  |   |   |   |   |             and 1 for a partially fillable order
    ///                  |   |   |   |   |
    ///                  |   |   |   +---+------------ use internal sell token balance bit:
    ///                  |   |   |                     0x: ERC20 token balance
    ///                  |   |   |                     10: external Balancer Vault balance
    ///                  |   |   |                     11: internal Balancer Vault balance
    ///                  |   |   |
    ///                  |   |   +-------------------- use buy token balance bit
    ///                  |   |                         0: ERC20 token balance
    ///                  |   |                         1: internal Balancer Vault balance
    ///                  |   |
    ///                  +---+------------------------ signature scheme bits:
    ///                                                00: EIP-712
    ///                                                01: eth_sign
    ///                                                10: EIP-1271
    ///                                                11: pre_sign
    /// ```
    function extractFlags(
        uint256 flags
    )
        internal
        pure
        returns (
            bytes32 kind,
            bool partiallyFillable,
            bytes32 sellTokenBalance,
            bytes32 buyTokenBalance,
            GPv2Signing.Scheme signingScheme
        )
    {
        if (flags & 0x01 == 0) {
            kind = GPv2Order.KIND_SELL;
        } else {
            kind = GPv2Order.KIND_BUY;
        }
        partiallyFillable = flags & 0x02 != 0;
        if (flags & 0x08 == 0) {
            sellTokenBalance = GPv2Order.BALANCE_ERC20;
        } else if (flags & 0x04 == 0) {
            sellTokenBalance = GPv2Order.BALANCE_EXTERNAL;
        } else {
            sellTokenBalance = GPv2Order.BALANCE_INTERNAL;
        }
        if (flags & 0x10 == 0) {
            buyTokenBalance = GPv2Order.BALANCE_ERC20;
        } else {
            buyTokenBalance = GPv2Order.BALANCE_INTERNAL;
        }

        // NOTE: Take advantage of the fact that Solidity will revert if the
        // following expression does not produce a valid enum value. This means
        // we check here that the leading reserved bits must be 0.
        signingScheme = GPv2Signing.Scheme(flags >> 5);
    }
}
// SPDX-License-Identifier: LGPL-3.0-or-later
pragma solidity >=0.7.6 <0.9.0;

import "../interfaces/GPv2EIP1271.sol";
import "../libraries/GPv2Order.sol";
import "../libraries/GPv2Trade.sol";

/// @title Gnosis Protocol v2 Signing Library.
/// @author Gnosis Developers
abstract contract GPv2Signing {
    using GPv2Order for GPv2Order.Data;
    using GPv2Order for bytes;

    /// @dev Recovered trade data containing the extracted order and the
    /// recovered owner address.
    struct RecoveredOrder {
        GPv2Order.Data data;
        bytes uid;
        address owner;
        address receiver;
    }

    /// @dev Signing scheme used for recovery.
    enum Scheme {
        Eip712,
        EthSign,
        Eip1271,
        PreSign
    }

    /// @dev The EIP-712 domain type hash used for computing the domain
    /// separator.
    bytes32 private constant DOMAIN_TYPE_HASH =
        keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );

    /// @dev The EIP-712 domain name used for computing the domain separator.
    bytes32 private constant DOMAIN_NAME = keccak256("Gnosis Protocol");

    /// @dev The EIP-712 domain version used for computing the domain separator.
    bytes32 private constant DOMAIN_VERSION = keccak256("v2");

    /// @dev Marker value indicating an order is pre-signed.
    uint256 private constant PRE_SIGNED =
        uint256(keccak256("GPv2Signing.Scheme.PreSign"));

    /// @dev The domain separator used for signing orders that gets mixed in
    /// making signatures for different domains incompatible. This domain
    /// separator is computed following the EIP-712 standard and has replay
    /// protection mixed in so that signed orders are only valid for specific
    /// GPv2 contracts.
    bytes32 public immutable domainSeparator;

    /// @dev Storage indicating whether or not an order has been signed by a
    /// particular address.
    mapping(bytes => uint256) public preSignature;

    /// @dev Event that is emitted when an account either pre-signs an order or
    /// revokes an existing pre-signature.
    event PreSignature(address indexed owner, bytes orderUid, bool signed);

    constructor() {
        // NOTE: Currently, the only way to get the chain ID in solidity is
        // using assembly.
        uint256 chainId;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            chainId := chainid()
        }

        domainSeparator = keccak256(
            abi.encode(
                DOMAIN_TYPE_HASH,
                DOMAIN_NAME,
                DOMAIN_VERSION,
                chainId,
                address(this)
            )
        );
    }

    /// @dev Sets a presignature for the specified order UID.
    ///
    /// @param orderUid The unique identifier of the order to pre-sign.
    /// @param signed True to set the order as tradable with pre-sign, false to
    /// false to unset it.
    function setPreSignature(bytes calldata orderUid, bool signed) external {
        (, address owner, ) = orderUid.extractOrderUidParams();
        require(owner == msg.sender, "GPv2: cannot presign order");
        if (signed) {
            preSignature[orderUid] = PRE_SIGNED;
        } else {
            preSignature[orderUid] = 0;
        }
        emit PreSignature(owner, orderUid, signed);
    }

    /// @dev Returns an empty recovered order with a pre-allocated buffer for
    /// packing the unique identifier.
    ///
    /// @return recoveredOrder The empty recovered order data.
    function allocateRecoveredOrder()
        internal
        pure
        returns (RecoveredOrder memory recoveredOrder)
    {
        recoveredOrder.uid = new bytes(GPv2Order.UID_LENGTH);
    }

    /// @dev Extracts order data and recovers the signer from the specified
    /// trade.
    ///
    /// @param recoveredOrder Memory location used for writing the recovered order data.
    /// @param tokens The list of tokens included in the settlement. The token
    /// indices in the trade parameters map to tokens in this array.
    /// @param trade The trade data to recover the order data from.
    function recoverOrderFromTrade(
        RecoveredOrder memory recoveredOrder,
        IERC20[] calldata tokens,
        GPv2Trade.Data calldata trade
    ) internal view {
        GPv2Order.Data memory order = recoveredOrder.data;

        Scheme signingScheme = GPv2Trade.extractOrder(trade, tokens, order);
        (bytes32 orderDigest, address owner) = recoverOrderSigner(
            order,
            signingScheme,
            trade.signature
        );

        recoveredOrder.uid.packOrderUidParams(
            orderDigest,
            owner,
            order.validTo
        );
        recoveredOrder.owner = owner;
        recoveredOrder.receiver = order.actualReceiver(owner);
    }

    /// @dev The length of any signature from an externally owned account.
    uint256 private constant ECDSA_SIGNATURE_LENGTH = 65;

    /// @dev Recovers an order's signer from the specified order and signature.
    ///
    /// @param order The order to recover a signature for.
    /// @param signingScheme The signing scheme.
    /// @param signature The signature bytes.
    /// @return orderDigest The computed order hash.
    /// @return owner The recovered address from the specified signature.
    function recoverOrderSigner(
        GPv2Order.Data memory order,
        Scheme signingScheme,
        bytes calldata signature
    ) internal view returns (bytes32 orderDigest, address owner) {
        orderDigest = order.hash(domainSeparator);
        if (signingScheme == Scheme.Eip712) {
            owner = recoverEip712Signer(orderDigest, signature);
        } else if (signingScheme == Scheme.EthSign) {
            owner = recoverEthsignSigner(orderDigest, signature);
        } else if (signingScheme == Scheme.Eip1271) {
            owner = recoverEip1271Signer(orderDigest, signature);
        } else {
            // signingScheme == Scheme.PreSign
            owner = recoverPreSigner(orderDigest, signature, order.validTo);
        }
    }

    /// @dev Perform an ECDSA recover for the specified message and calldata
    /// signature.
    ///
    /// The signature is encoded by tighyly packing the following struct:
    /// ```
    /// struct EncodedSignature {
    ///     bytes32 r;
    ///     bytes32 s;
    ///     uint8 v;
    /// }
    /// ```
    ///
    /// @param message The signed message.
    /// @param encodedSignature The encoded signature.
    function ecdsaRecover(
        bytes32 message,
        bytes calldata encodedSignature
    ) internal pure returns (address signer) {
        require(
            encodedSignature.length == ECDSA_SIGNATURE_LENGTH,
            "GPv2: malformed ecdsa signature"
        );

        bytes32 r;
        bytes32 s;
        uint8 v;

        // NOTE: Use assembly to efficiently decode signature data.
        // solhint-disable-next-line no-inline-assembly
        assembly {
            // r = uint256(encodedSignature[0:32])
            r := calldataload(encodedSignature.offset)
            // s = uint256(encodedSignature[32:64])
            s := calldataload(add(encodedSignature.offset, 32))
            // v = uint8(encodedSignature[64])
            v := shr(248, calldataload(add(encodedSignature.offset, 64)))
        }

        signer = ecrecover(message, v, r, s);
        require(signer != address(0), "GPv2: invalid ecdsa signature");
    }

    /// @dev Decodes signature bytes originating from an EIP-712-encoded
    /// signature.
    ///
    /// EIP-712 signs typed data. The specifications are described in the
    /// related EIP (<https://eips.ethereum.org/EIPS/eip-712>).
    ///
    /// EIP-712 signatures are encoded as standard ECDSA signatures as described
    /// in the corresponding decoding function [`ecdsaRecover`].
    ///
    /// @param orderDigest The EIP-712 signing digest derived from the order
    /// parameters.
    /// @param encodedSignature Calldata pointing to tightly packed signature
    /// bytes.
    /// @return owner The address of the signer.
    function recoverEip712Signer(
        bytes32 orderDigest,
        bytes calldata encodedSignature
    ) internal pure returns (address owner) {
        owner = ecdsaRecover(orderDigest, encodedSignature);
    }

    /// @dev Decodes signature bytes originating from the output of the eth_sign
    /// RPC call.
    ///
    /// The specifications are described in the Ethereum documentation
    /// (<https://eth.wiki/json-rpc/API#eth_sign>).
    ///
    /// eth_sign signatures are encoded as standard ECDSA signatures as
    /// described in the corresponding decoding function
    /// [`ecdsaRecover`].
    ///
    /// @param orderDigest The EIP-712 signing digest derived from the order
    /// parameters.
    /// @param encodedSignature Calldata pointing to tightly packed signature
    /// bytes.
    /// @return owner The address of the signer.
    function recoverEthsignSigner(
        bytes32 orderDigest,
        bytes calldata encodedSignature
    ) internal pure returns (address owner) {
        // The signed message is encoded as:
        // `"\x19Ethereum Signed Message:\n" || length || data`, where
        // the length is a constant (32 bytes) and the data is defined as:
        // `orderDigest`.
        bytes32 ethsignDigest = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", orderDigest)
        );

        owner = ecdsaRecover(ethsignDigest, encodedSignature);
    }

    /// @dev Verifies the input calldata as an EIP-1271 contract signature and
    /// returns the address of the signer.
    ///
    /// The encoded signature tightly packs the following struct:
    ///
    /// ```
    /// struct EncodedEip1271Signature {
    ///     address owner;
    ///     bytes signature;
    /// }
    /// ```
    ///
    /// This function enforces that the encoded data stores enough bytes to
    /// cover the full length of the decoded signature.
    ///
    /// @param encodedSignature The encoded EIP-1271 signature.
    /// @param orderDigest The EIP-712 signing digest derived from the order
    /// parameters.
    /// @return owner The address of the signer.
    function recoverEip1271Signer(
        bytes32 orderDigest,
        bytes calldata encodedSignature
    ) internal view returns (address owner) {
        // NOTE: Use assembly to read the verifier address from the encoded
        // signature bytes.
        // solhint-disable-next-line no-inline-assembly
        assembly {
            // owner = address(encodedSignature[0:20])
            owner := shr(96, calldataload(encodedSignature.offset))
        }

        // NOTE: Configure prettier to ignore the following line as it causes
        // a panic in the Solidity plugin.
        // prettier-ignore
        bytes calldata signature = encodedSignature[20:];

        require(
            EIP1271Verifier(owner).isValidSignature(orderDigest, signature) ==
                GPv2EIP1271.MAGICVALUE,
            "GPv2: invalid eip1271 signature"
        );
    }

    /// @dev Verifies the order has been pre-signed. The signature is the
    /// address of the signer of the order.
    ///
    /// @param orderDigest The EIP-712 signing digest derived from the order
    /// parameters.
    /// @param encodedSignature The pre-sign signature reprenting the order UID.
    /// @param validTo The order expiry timestamp.
    /// @return owner The address of the signer.
    function recoverPreSigner(
        bytes32 orderDigest,
        bytes calldata encodedSignature,
        uint32 validTo
    ) internal view returns (address owner) {
        require(encodedSignature.length == 20, "GPv2: malformed presignature");
        // NOTE: Use assembly to read the owner address from the encoded
        // signature bytes.
        // solhint-disable-next-line no-inline-assembly
        assembly {
            // owner = address(encodedSignature[0:20])
            owner := shr(96, calldataload(encodedSignature.offset))
        }

        bytes memory orderUid = new bytes(GPv2Order.UID_LENGTH);
        orderUid.packOrderUidParams(orderDigest, owner, validTo);

        require(
            preSignature[orderUid] == PRE_SIGNED,
            "GPv2: order not presigned"
        );
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC1271.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC1271 standard signature validation method for
 * contracts as defined in https://eips.ethereum.org/EIPS/eip-1271[ERC-1271].
 */
interface IERC1271 {
    /**
     * @dev Should return whether the signature provided is valid for the provided data
     * @param hash      Hash of the data to be signed
     * @param signature Signature byte array associated with _data
     */
    function isValidSignature(bytes32 hash, bytes memory signature) external view returns (bytes4 magicValue);
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
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

/**
 * @title BCoWConst
 * @notice Constants used in the scope of the BCoWPool contract.
 */
contract BCoWConst {
  /**
   * @notice The largest possible duration of any AMM order, starting from the
   * current block timestamp.
   * @return _maxOrderDuration The maximum order duration.
   */
  uint32 public constant MAX_ORDER_DURATION = 5 minutes;
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

/*

Coded for Balancer and CoW Swap with ♥ by

░██╗░░░░░░░██╗░█████╗░███╗░░██╗██████╗░███████╗██████╗░██╗░░░░░░█████╗░███╗░░██╗██████╗░
░██║░░██╗░░██║██╔══██╗████╗░██║██╔══██╗██╔════╝██╔══██╗██║░░░░░██╔══██╗████╗░██║██╔══██╗
░╚██╗████╗██╔╝██║░░██║██╔██╗██║██║░░██║█████╗░░██████╔╝██║░░░░░███████║██╔██╗██║██║░░██║
░░████╔═████║░██║░░██║██║╚████║██║░░██║██╔══╝░░██╔══██╗██║░░░░░██╔══██║██║╚████║██║░░██║
░░╚██╔╝░╚██╔╝░╚█████╔╝██║░╚███║██████╔╝███████╗██║░░██║███████╗██║░░██║██║░╚███║██████╔╝
░░░╚═╝░░░╚═╝░░░╚════╝░╚═╝░░╚══╝╚═════╝░╚══════╝╚═╝░░╚═╝╚══════╝╚═╝░░╚═╝╚═╝░░╚══╝╚═════╝░

https://defi.sucks

*/

import {BCoWConst} from './BCoWConst.sol';
import {BPool} from './BPool.sol';
import {GPv2Order} from '@cowprotocol/libraries/GPv2Order.sol';
import {IERC1271} from '@openzeppelin/contracts/interfaces/IERC1271.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {SafeERC20} from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';

import {IBCoWFactory} from 'interfaces/IBCoWFactory.sol';
import {IBCoWPool} from 'interfaces/IBCoWPool.sol';
import {ISettlement} from 'interfaces/ISettlement.sol';

/**
 * @title BCoWPool
 * @notice Pool contract that holds tokens, allows to swap, add and remove liquidity.
 * @dev Inherits BPool contract functionalities, and can trade on CoW Swap Protocol.
 */
contract BCoWPool is IERC1271, IBCoWPool, BPool, BCoWConst {
  using GPv2Order for GPv2Order.Data;
  using SafeERC20 for IERC20;

  /// @inheritdoc IBCoWPool
  address public immutable VAULT_RELAYER;

  /// @inheritdoc IBCoWPool
  bytes32 public immutable SOLUTION_SETTLER_DOMAIN_SEPARATOR;

  /// @inheritdoc IBCoWPool
  ISettlement public immutable SOLUTION_SETTLER;

  /// @inheritdoc IBCoWPool
  bytes32 public immutable APP_DATA;

  constructor(
    address cowSolutionSettler,
    bytes32 appData,
    // solhint-disable-next-line no-unused-vars
    string memory name,
    // solhint-disable-next-line no-unused-vars
    string memory symbol
  ) BPool(name, symbol) {
    SOLUTION_SETTLER = ISettlement(cowSolutionSettler);
    SOLUTION_SETTLER_DOMAIN_SEPARATOR = ISettlement(cowSolutionSettler).domainSeparator();
    VAULT_RELAYER = ISettlement(cowSolutionSettler).vaultRelayer();
    APP_DATA = appData;
  }

  /// @inheritdoc IBCoWPool
  function commit(bytes32 orderHash) external _viewlock_ {
    if (msg.sender != address(SOLUTION_SETTLER)) {
      revert CommitOutsideOfSettlement();
    }
    _setLock(orderHash);
  }

  /**
   * @inheritdoc IERC1271
   * @dev this function reverts if the order hash does not match the current commitment
   */
  function isValidSignature(bytes32 orderHash, bytes memory signature) external view returns (bytes4 magicValue) {
    (GPv2Order.Data memory order) = abi.decode(signature, (GPv2Order.Data));

    if (order.appData != APP_DATA) {
      revert AppDataDoesNotMatch();
    }

    bytes32 orderHash_ = order.hash(SOLUTION_SETTLER_DOMAIN_SEPARATOR);
    if (orderHash_ != orderHash) {
      revert OrderDoesNotMatchMessageHash();
    }

    if (orderHash_ != _getLock()) {
      revert OrderDoesNotMatchCommitmentHash();
    }

    verify(order);

    // A signature is valid according to EIP-1271 if this function returns
    // its selector as the so-called "magic value".
    magicValue = this.isValidSignature.selector;
  }

  /// @inheritdoc IBCoWPool
  function verify(GPv2Order.Data memory order) public view virtual {
    Record memory inRecord = _records[address(order.buyToken)];
    Record memory outRecord = _records[address(order.sellToken)];

    if (!inRecord.bound || !outRecord.bound) {
      revert BPool_TokenNotBound();
    }
    if (order.receiver != GPv2Order.RECEIVER_SAME_AS_OWNER) {
      revert BCoWPool_ReceiverIsNotBCoWPool();
    }
    if (order.validTo > block.timestamp + MAX_ORDER_DURATION) {
      revert BCoWPool_OrderValidityTooLong();
    }
    if (order.feeAmount != 0) {
      revert BCoWPool_FeeMustBeZero();
    }
    if (order.kind != GPv2Order.KIND_SELL) {
      revert BCoWPool_InvalidOperation();
    }
    if (order.buyTokenBalance != GPv2Order.BALANCE_ERC20 || order.sellTokenBalance != GPv2Order.BALANCE_ERC20) {
      revert BCoWPool_InvalidBalanceMarker();
    }

    uint256 buyTokenBalance = order.buyToken.balanceOf(address(this));
    if (order.buyAmount > bmul(buyTokenBalance, MAX_IN_RATIO)) {
      revert BPool_TokenAmountInAboveMaxRatio();
    }

    uint256 tokenAmountOut = calcOutGivenIn({
      tokenBalanceIn: buyTokenBalance,
      tokenWeightIn: inRecord.denorm,
      tokenBalanceOut: order.sellToken.balanceOf(address(this)),
      tokenWeightOut: outRecord.denorm,
      tokenAmountIn: order.buyAmount,
      swapFee: 0
    });

    if (tokenAmountOut < order.sellAmount) {
      revert BPool_TokenAmountOutBelowMinOut();
    }
  }

  /**
   * @inheritdoc BPool
   * @dev Grants infinite approval to the vault relayer for all tokens in the
   * pool after the finalization of the setup. Also emits COWAMMPoolCreated() event.
   */
  function _afterFinalize() internal override {
    uint256 tokensLength = _tokens.length;
    for (uint256 i; i < tokensLength; i++) {
      IERC20(_tokens[i]).forceApprove(VAULT_RELAYER, type(uint256).max);
    }

    // Make the factory emit the event, to be easily indexed by off-chain agents
    // If this pool was not deployed using a bCoWFactory, this will revert and catch
    // And the event will be emitted by this contract instead
    // solhint-disable-next-line no-empty-blocks
    try IBCoWFactory(FACTORY).logBCoWPool() {}
    catch {
      emit IBCoWFactory.COWAMMPoolCreated(address(this));
    }
  }
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

/**
 * @title BConst
 * @notice Constants used in the scope of the BPool contract.
 */
contract BConst {
  /// @notice The unit of precision used in the calculations.
  uint256 public constant BONE = 10 ** 18;

  /// @notice The minimum number of bound tokens in a pool.
  uint256 public constant MIN_BOUND_TOKENS = 2;
  /// @notice The maximum number of bound tokens in a pool.
  uint256 public constant MAX_BOUND_TOKENS = 8;

  /// @notice The minimum swap fee that can be set.
  uint256 public constant MIN_FEE = BONE / 10 ** 6;
  /// @notice The maximum swap fee that can be set.
  uint256 public constant MAX_FEE = BONE - MIN_FEE;
  /// @notice The immutable exit fee percentage
  uint256 public constant EXIT_FEE = 0;

  /// @notice The minimum weight that a token can have.
  uint256 public constant MIN_WEIGHT = BONE;
  /// @notice The maximum weight that a token can have.
  uint256 public constant MAX_WEIGHT = BONE * 50;
  /// @notice The maximum sum of weights of all tokens in a pool.
  uint256 public constant MAX_TOTAL_WEIGHT = BONE * 50;
  /// @notice The minimum balance that a token must have.
  uint256 public constant MIN_BALANCE = BONE / 10 ** 12;

  /// @notice The initial total supply of the pool tokens (minted to the pool creator).
  uint256 public constant INIT_POOL_SUPPLY = BONE * 100;

  /// @notice The minimum base value for the bpow calculation.
  uint256 public constant MIN_BPOW_BASE = 1 wei;
  /// @notice The maximum base value for the bpow calculation.
  uint256 public constant MAX_BPOW_BASE = (2 * BONE) - 1 wei;
  /// @notice The precision of the bpow calculation.
  uint256 public constant BPOW_PRECISION = BONE / 10 ** 10;

  /// @notice The maximum ratio of input tokens vs the current pool balance.
  uint256 public constant MAX_IN_RATIO = BONE >> 1;
  /// @notice The maximum ratio of output tokens vs the current pool balance.
  uint256 public constant MAX_OUT_RATIO = (BONE / 3) + 1 wei;

  /**
   * @notice The storage slot used to write transient data.
   * @dev Using an arbitrary storage slot to prevent possible future
   * transient variables defined by solidity from overriding it.
   * @dev Value is: uint256(keccak256('BPool.transientStorageLock')) - 1;
   */
  uint256 internal constant _MUTEX_TRANSIENT_STORAGE_SLOT =
    0x3f8f4c536ce1b925b469af1b09a44da237dab5bbc584585648c12be1ca25a8c4;
  /// @notice The value representing an unlocked state of the mutex.
  bytes32 internal constant _MUTEX_FREE = bytes32(uint256(0));
  /// @notice The value representing a locked state of the mutex.
  bytes32 internal constant _MUTEX_TAKEN = bytes32(uint256(1));
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

import {BConst} from './BConst.sol';
import {BNum} from './BNum.sol';

/**
 * @title BMath
 * @notice Includes functions for calculating the BPool related math.
 */
contract BMath is BConst, BNum {
  /**
   * @notice Calculate the spot price of a token in terms of another one
   * @dev The price denomination depends on the decimals of the tokens.
   * @dev To obtain the price with 18 decimals the next formula should be applied to the result
   * @dev spotPrice = spotPrice ÷ (10^tokenInDecimals) × (10^tokenOutDecimals)
   * @param tokenBalanceIn The balance of the input token in the pool
   * @param tokenWeightIn The weight of the input token in the pool
   * @param tokenBalanceOut The balance of the output token in the pool
   * @param tokenWeightOut The weight of the output token in the pool
   * @param swapFee The swap fee of the pool
   * @return spotPrice The spot price of a token in terms of another one
   * @dev Formula:
   * sP = spotPrice
   * bI = tokenBalanceIn                ( bI / wI )         1
   * bO = tokenBalanceOut         sP =  -----------  *  ----------
   * wI = tokenWeightIn                 ( bO / wO )     ( 1 - sF )
   * wO = tokenWeightOut
   * sF = swapFee
   */
  function calcSpotPrice(
    uint256 tokenBalanceIn,
    uint256 tokenWeightIn,
    uint256 tokenBalanceOut,
    uint256 tokenWeightOut,
    uint256 swapFee
  ) public pure returns (uint256 spotPrice) {
    uint256 numer = bdiv(tokenBalanceIn, tokenWeightIn);
    uint256 denom = bdiv(tokenBalanceOut, tokenWeightOut);
    uint256 ratio = bdiv(numer, denom);
    uint256 scale = bdiv(BONE, bsub(BONE, swapFee));
    return (spotPrice = bmul(ratio, scale));
  }

  /**
   * @notice Calculate the amount of token out given the amount of token in for a swap
   * @param tokenBalanceIn The balance of the input token in the pool
   * @param tokenWeightIn The weight of the input token in the pool
   * @param tokenBalanceOut The balance of the output token in the pool
   * @param tokenWeightOut The weight of the output token in the pool
   * @param tokenAmountIn The amount of the input token
   * @param swapFee The swap fee of the pool
   * @return tokenAmountOut The amount of token out given the amount of token in for a swap
   * @dev Formula:
   * aO = tokenAmountOut
   * bO = tokenBalanceOut
   * bI = tokenBalanceIn              /      /            bI             \    (wI / wO) \
   * aI = tokenAmountIn    aO = bO * |  1 - | --------------------------  | ^            |
   * wI = tokenWeightIn               \      \ ( bI + ( aI * ( 1 - sF )) /              /
   * wO = tokenWeightOut
   * sF = swapFee
   */
  function calcOutGivenIn(
    uint256 tokenBalanceIn,
    uint256 tokenWeightIn,
    uint256 tokenBalanceOut,
    uint256 tokenWeightOut,
    uint256 tokenAmountIn,
    uint256 swapFee
  ) public pure returns (uint256 tokenAmountOut) {
    uint256 weightRatio = bdiv(tokenWeightIn, tokenWeightOut);
    uint256 adjustedIn = bsub(BONE, swapFee);
    adjustedIn = bmul(tokenAmountIn, adjustedIn);
    uint256 y = bdiv(tokenBalanceIn, badd(tokenBalanceIn, adjustedIn));
    uint256 foo = bpow(y, weightRatio);
    uint256 bar = bsub(BONE, foo);
    tokenAmountOut = bmul(tokenBalanceOut, bar);
    return tokenAmountOut;
  }

  /**
   * @notice Calculate the amount of token in given the amount of token out for a swap
   * @param tokenBalanceIn The balance of the input token in the pool
   * @param tokenWeightIn The weight of the input token in the pool
   * @param tokenBalanceOut The balance of the output token in the pool
   * @param tokenWeightOut The weight of the output token in the pool
   * @param tokenAmountOut The amount of the output token
   * @param swapFee The swap fee of the pool
   * @return tokenAmountIn The amount of token in given the amount of token out for a swap
   * @dev Formula:
   * aI = tokenAmountIn
   * bO = tokenBalanceOut               /  /     bO      \    (wO / wI)      \
   * bI = tokenBalanceIn          bI * |  | ------------  | ^            - 1  |
   * aO = tokenAmountOut    aI =        \  \ ( bO - aO ) /                   /
   * wI = tokenWeightIn           --------------------------------------------
   * wO = tokenWeightOut                          ( 1 - sF )
   * sF = swapFee
   */
  function calcInGivenOut(
    uint256 tokenBalanceIn,
    uint256 tokenWeightIn,
    uint256 tokenBalanceOut,
    uint256 tokenWeightOut,
    uint256 tokenAmountOut,
    uint256 swapFee
  ) public pure returns (uint256 tokenAmountIn) {
    uint256 weightRatio = bdiv(tokenWeightOut, tokenWeightIn);
    uint256 diff = bsub(tokenBalanceOut, tokenAmountOut);
    uint256 y = bdiv(tokenBalanceOut, diff);
    uint256 foo = bpow(y, weightRatio);
    foo = bsub(foo, BONE);
    tokenAmountIn = bsub(BONE, swapFee);
    tokenAmountIn = bdiv(bmul(tokenBalanceIn, foo), tokenAmountIn);
    return tokenAmountIn;
  }
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

import {BConst} from './BConst.sol';

/**
 * @title BNum
 * @notice Includes functions for arithmetic operations with fixed-point numbers.
 * @dev The arithmetic operations are implemented with a precision of BONE.
 */
// solhint-disable private-vars-leading-underscore
// solhint-disable named-return-values
contract BNum is BConst {
  /**
   * @notice Thrown when an overflow is encountered inside the add function
   */
  error BNum_AddOverflow();

  /**
   * @notice Thrown when an underflow is encountered inside the sub function
   */
  error BNum_SubUnderflow();

  /**
   * @notice Thrown when an overflow is encountered inside the mul function
   */
  error BNum_MulOverflow();

  /**
   * @notice Thrown when attempting to divide by zero
   */
  error BNum_DivZero();

  /**
   * @notice Thrown when an internal error occurs inside div function
   */
  error BNum_DivInternal();

  /**
   * @notice Thrown when the base is too low in the bpow function
   */
  error BNum_BPowBaseTooLow();

  /**
   * @notice Thrown when the base is too high in the bpow function
   */
  error BNum_BPowBaseTooHigh();

  function btoi(uint256 a) internal pure returns (uint256) {
    unchecked {
      return a / BONE;
    }
  }

  function bfloor(uint256 a) internal pure returns (uint256) {
    unchecked {
      return btoi(a) * BONE;
    }
  }

  function badd(uint256 a, uint256 b) internal pure returns (uint256) {
    unchecked {
      uint256 c = a + b;
      if (c < a) {
        revert BNum_AddOverflow();
      }
      return c;
    }
  }

  function bsub(uint256 a, uint256 b) internal pure returns (uint256) {
    unchecked {
      (uint256 c, bool flag) = bsubSign(a, b);
      if (flag) {
        revert BNum_SubUnderflow();
      }
      return c;
    }
  }

  function bsubSign(uint256 a, uint256 b) internal pure returns (uint256, bool) {
    unchecked {
      if (a >= b) {
        return (a - b, false);
      } else {
        return (b - a, true);
      }
    }
  }

  function bmul(uint256 a, uint256 b) internal pure returns (uint256) {
    unchecked {
      uint256 c0 = a * b;
      if (a != 0 && c0 / a != b) {
        revert BNum_MulOverflow();
      }
      // NOTE: using >> 1 instead of / 2
      uint256 c1 = c0 + (BONE >> 1);
      if (c1 < c0) {
        revert BNum_MulOverflow();
      }
      uint256 c2 = c1 / BONE;
      return c2;
    }
  }

  function bdiv(uint256 a, uint256 b) internal pure returns (uint256) {
    unchecked {
      if (b == 0) {
        revert BNum_DivZero();
      }
      uint256 c0 = a * BONE;
      if (a != 0 && c0 / a != BONE) {
        revert BNum_DivInternal(); // bmul overflow
      }
      // NOTE: using >> 1 instead of / 2
      uint256 c1 = c0 + (b >> 1);
      if (c1 < c0) {
        revert BNum_DivInternal(); //  badd require
      }
      uint256 c2 = c1 / b;
      return c2;
    }
  }

  // DSMath.wpow
  function bpowi(uint256 a, uint256 n) internal pure returns (uint256) {
    unchecked {
      uint256 z = n % 2 != 0 ? a : BONE;

      for (n /= 2; n != 0; n /= 2) {
        a = bmul(a, a);

        if (n % 2 != 0) {
          z = bmul(z, a);
        }
      }
      return z;
    }
  }

  // Compute b^(e.w) by splitting it into (b^e)*(b^0.w).
  // Use `bpowi` for `b^e` and `bpowK` for k iterations
  // of approximation of b^0.w
  function bpow(uint256 base, uint256 exp) internal pure returns (uint256) {
    unchecked {
      if (base < MIN_BPOW_BASE) {
        revert BNum_BPowBaseTooLow();
      }
      if (base > MAX_BPOW_BASE) {
        revert BNum_BPowBaseTooHigh();
      }

      uint256 whole = bfloor(exp);
      uint256 remain = bsub(exp, whole);

      uint256 wholePow = bpowi(base, btoi(whole));

      if (remain == 0) {
        return wholePow;
      }

      uint256 partialResult = bpowApprox(base, remain, BPOW_PRECISION);
      return bmul(wholePow, partialResult);
    }
  }

  function bpowApprox(uint256 base, uint256 exp, uint256 precision) internal pure returns (uint256) {
    unchecked {
      // term 0:
      uint256 a = exp;
      (uint256 x, bool xneg) = bsubSign(base, BONE);
      uint256 term = BONE;
      uint256 sum = term;
      bool negative = false;

      // term(k) = numer / denom
      //         = (product(a - i - 1, i=1-->k) * x^k) / (k!)
      // each iteration, multiply previous term by (a-(k-1)) * x / k
      // continue until term is less than precision
      for (uint256 i = 1; term >= precision; i++) {
        uint256 bigK = i * BONE;
        (uint256 c, bool cneg) = bsubSign(a, bsub(bigK, BONE));
        term = bmul(term, bmul(c, x));
        term = bdiv(term, bigK);
        if (term == 0) break;

        if (xneg) negative = !negative;
        if (cneg) negative = !negative;
        if (negative) {
          sum = bsub(sum, term);
        } else {
          sum = badd(sum, term);
        }
      }

      return sum;
    }
  }
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

import {BMath} from './BMath.sol';
import {BToken} from './BToken.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {SafeERC20} from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import {IBPool} from 'interfaces/IBPool.sol';

/**
 * @title BPool
 * @notice Pool contract that holds tokens, allows to swap, add and remove liquidity.
 */
contract BPool is BToken, BMath, IBPool {
  using SafeERC20 for IERC20;
  /// @dev BFactory address to push token exitFee to

  /// @inheritdoc IBPool
  address public immutable FACTORY;
  /// @dev Has CONTROL role
  address internal _controller;
  /// @dev Fee for swapping
  uint256 internal _swapFee;
  /// @dev Status of the pool. True if finalized, False otherwise
  bool internal _finalized;
  /// @dev Array of bound tokens
  address[] internal _tokens;
  /// @dev Metadata for each bound token
  mapping(address => Record) internal _records;
  /// @dev Sum of all token weights
  uint256 internal _totalWeight;

  /// @dev Logs the call data
  modifier _logs_() {
    emit LOG_CALL(msg.sig, msg.sender, msg.data);
    _;
  }

  /// @dev Prevents reentrancy in non-view functions
  modifier _lock_() {
    if (_getLock() != _MUTEX_FREE) {
      revert BPool_Reentrancy();
    }
    _setLock(_MUTEX_TAKEN);
    _;
    _setLock(_MUTEX_FREE);
  }

  /// @dev Throws an error when the reentrancy mutex is taken. Doesn't modify it.
  modifier _viewlock_() {
    if (_getLock() != _MUTEX_FREE) {
      revert BPool_Reentrancy();
    }
    _;
  }

  /// @dev Throws an error if pool is not finalized
  modifier _finalized_() {
    if (!_finalized) {
      revert BPool_PoolNotFinalized();
    }
    _;
  }

  /// @dev Throws an error if pool is finalized
  modifier _notFinalized_() {
    if (_finalized) {
      revert BPool_PoolIsFinalized();
    }
    _;
  }

  /**
   * @notice Throws an error if caller is not controller
   */
  modifier _controller_() {
    if (msg.sender != _controller) {
      revert BPool_CallerIsNotController();
    }
    _;
  }

  // solhint-disable-next-line no-unused-vars
  constructor(string memory name, string memory symbol) BToken(name, symbol) {
    _controller = msg.sender;
    FACTORY = msg.sender;
    _swapFee = MIN_FEE;
    _finalized = false;
  }

  /// @inheritdoc IBPool
  function setSwapFee(uint256 swapFee) external _logs_ _lock_ _controller_ _notFinalized_ {
    if (swapFee < MIN_FEE) {
      revert BPool_FeeBelowMinimum();
    }
    if (swapFee > MAX_FEE) {
      revert BPool_FeeAboveMaximum();
    }
    _swapFee = swapFee;
  }

  /// @inheritdoc IBPool
  function setController(address newController) external _logs_ _lock_ _controller_ {
    if (newController == address(0)) {
      revert BPool_AddressZero();
    }

    _controller = newController;
  }

  /// @inheritdoc IBPool
  function finalize() external _logs_ _lock_ _controller_ _notFinalized_ {
    if (_tokens.length < MIN_BOUND_TOKENS) {
      revert BPool_TokensBelowMinimum();
    }

    _finalized = true;

    _mintPoolShare(INIT_POOL_SUPPLY);
    _pushPoolShare(msg.sender, INIT_POOL_SUPPLY);
    _afterFinalize();
  }

  /// @inheritdoc IBPool
  function bind(address token, uint256 balance, uint256 denorm) external _logs_ _lock_ _controller_ _notFinalized_ {
    if (_records[token].bound) {
      revert BPool_TokenAlreadyBound();
    }
    if (_tokens.length >= MAX_BOUND_TOKENS) {
      revert BPool_TokensAboveMaximum();
    }
    if (denorm < MIN_WEIGHT) {
      revert BPool_WeightBelowMinimum();
    }
    if (denorm > MAX_WEIGHT) {
      revert BPool_WeightAboveMaximum();
    }
    if (balance < MIN_BALANCE) {
      revert BPool_BalanceBelowMinimum();
    }

    _totalWeight = badd(_totalWeight, denorm);
    if (_totalWeight > MAX_TOTAL_WEIGHT) {
      revert BPool_TotalWeightAboveMaximum();
    }

    _records[token] = Record({bound: true, index: _tokens.length, denorm: denorm});
    _tokens.push(token);

    _pullUnderlying(token, msg.sender, balance);
  }

  /// @inheritdoc IBPool
  function unbind(address token) external _logs_ _lock_ _controller_ _notFinalized_ {
    if (!_records[token].bound) {
      revert BPool_TokenNotBound();
    }

    _totalWeight = bsub(_totalWeight, _records[token].denorm);

    // Swap the token-to-unbind with the last token,
    // then delete the last token
    uint256 index = _records[token].index;
    uint256 last = _tokens.length - 1;
    _tokens[index] = _tokens[last];
    _records[_tokens[index]].index = index;
    _tokens.pop();
    _records[token] = Record({bound: false, index: 0, denorm: 0});

    _pushUnderlying(token, msg.sender, IERC20(token).balanceOf(address(this)));
  }

  /// @inheritdoc IBPool
  function joinPool(uint256 poolAmountOut, uint256[] calldata maxAmountsIn) external _logs_ _lock_ _finalized_ {
    uint256 poolTotal = totalSupply();
    uint256 ratio = bdiv(poolAmountOut, poolTotal);
    if (ratio == 0) {
      revert BPool_InvalidPoolRatio();
    }

    uint256 tokensLength = _tokens.length;
    for (uint256 i = 0; i < tokensLength; i++) {
      address t = _tokens[i];
      uint256 bal = IERC20(t).balanceOf(address(this));
      uint256 tokenAmountIn = bmul(ratio, bal);
      if (tokenAmountIn == 0) {
        revert BPool_InvalidTokenAmountIn();
      }
      if (tokenAmountIn > maxAmountsIn[i]) {
        revert BPool_TokenAmountInAboveMaxAmountIn();
      }
      emit LOG_JOIN(msg.sender, t, tokenAmountIn);
      _pullUnderlying(t, msg.sender, tokenAmountIn);
    }
    _mintPoolShare(poolAmountOut);
    _pushPoolShare(msg.sender, poolAmountOut);
  }

  /// @inheritdoc IBPool
  function exitPool(uint256 poolAmountIn, uint256[] calldata minAmountsOut) external _logs_ _lock_ _finalized_ {
    uint256 poolTotal = totalSupply();
    uint256 exitFee = bmul(poolAmountIn, EXIT_FEE);
    uint256 pAiAfterExitFee = bsub(poolAmountIn, exitFee);
    uint256 ratio = bdiv(pAiAfterExitFee, poolTotal);
    if (ratio == 0) {
      revert BPool_InvalidPoolRatio();
    }

    _pullPoolShare(msg.sender, poolAmountIn);
    _pushPoolShare(FACTORY, exitFee);
    _burnPoolShare(pAiAfterExitFee);

    uint256 tokensLength = _tokens.length;
    for (uint256 i = 0; i < tokensLength; i++) {
      address t = _tokens[i];
      uint256 bal = IERC20(t).balanceOf(address(this));
      uint256 tokenAmountOut = bmul(ratio, bal);
      if (tokenAmountOut == 0) {
        revert BPool_InvalidTokenAmountOut();
      }
      if (tokenAmountOut < minAmountsOut[i]) {
        revert BPool_TokenAmountOutBelowMinAmountOut();
      }
      emit LOG_EXIT(msg.sender, t, tokenAmountOut);
      _pushUnderlying(t, msg.sender, tokenAmountOut);
    }
  }

  /// @inheritdoc IBPool
  function swapExactAmountIn(
    address tokenIn,
    uint256 tokenAmountIn,
    address tokenOut,
    uint256 minAmountOut,
    uint256 maxPrice
  ) external _logs_ _lock_ _finalized_ returns (uint256 tokenAmountOut, uint256 spotPriceAfter) {
    if (!_records[tokenIn].bound) {
      revert BPool_TokenNotBound();
    }
    if (!_records[tokenOut].bound) {
      revert BPool_TokenNotBound();
    }

    Record storage inRecord = _records[address(tokenIn)];
    Record storage outRecord = _records[address(tokenOut)];

    uint256 tokenInBalance = IERC20(tokenIn).balanceOf(address(this));
    uint256 tokenOutBalance = IERC20(tokenOut).balanceOf(address(this));

    if (tokenAmountIn > bmul(tokenInBalance, MAX_IN_RATIO)) {
      revert BPool_TokenAmountInAboveMaxRatio();
    }

    uint256 spotPriceBefore =
      calcSpotPrice(tokenInBalance, inRecord.denorm, tokenOutBalance, outRecord.denorm, _swapFee);
    if (spotPriceBefore > maxPrice) {
      revert BPool_SpotPriceAboveMaxPrice();
    }

    tokenAmountOut =
      calcOutGivenIn(tokenInBalance, inRecord.denorm, tokenOutBalance, outRecord.denorm, tokenAmountIn, _swapFee);
    if (tokenAmountOut < minAmountOut) {
      revert BPool_TokenAmountOutBelowMinOut();
    }

    tokenInBalance = badd(tokenInBalance, tokenAmountIn);
    tokenOutBalance = bsub(tokenOutBalance, tokenAmountOut);

    spotPriceAfter = calcSpotPrice(tokenInBalance, inRecord.denorm, tokenOutBalance, outRecord.denorm, _swapFee);
    if (spotPriceAfter < spotPriceBefore) {
      revert BPool_SpotPriceAfterBelowSpotPriceBefore();
    }
    if (spotPriceAfter > maxPrice) {
      revert BPool_SpotPriceAboveMaxPrice();
    }
    if (spotPriceBefore > bdiv(tokenAmountIn, tokenAmountOut)) {
      revert BPool_SpotPriceBeforeAboveTokenRatio();
    }

    emit LOG_SWAP(msg.sender, tokenIn, tokenOut, tokenAmountIn, tokenAmountOut);

    _pullUnderlying(tokenIn, msg.sender, tokenAmountIn);
    _pushUnderlying(tokenOut, msg.sender, tokenAmountOut);
  }

  /// @inheritdoc IBPool
  function swapExactAmountOut(
    address tokenIn,
    uint256 maxAmountIn,
    address tokenOut,
    uint256 tokenAmountOut,
    uint256 maxPrice
  ) external _logs_ _lock_ _finalized_ returns (uint256 tokenAmountIn, uint256 spotPriceAfter) {
    if (!_records[tokenIn].bound) {
      revert BPool_TokenNotBound();
    }
    if (!_records[tokenOut].bound) {
      revert BPool_TokenNotBound();
    }

    Record storage inRecord = _records[address(tokenIn)];
    Record storage outRecord = _records[address(tokenOut)];

    uint256 tokenInBalance = IERC20(tokenIn).balanceOf(address(this));
    uint256 tokenOutBalance = IERC20(tokenOut).balanceOf(address(this));

    if (tokenAmountOut > bmul(tokenOutBalance, MAX_OUT_RATIO)) {
      revert BPool_TokenAmountOutAboveMaxOut();
    }

    uint256 spotPriceBefore =
      calcSpotPrice(tokenInBalance, inRecord.denorm, tokenOutBalance, outRecord.denorm, _swapFee);
    if (spotPriceBefore > maxPrice) {
      revert BPool_SpotPriceAboveMaxPrice();
    }

    tokenAmountIn =
      calcInGivenOut(tokenInBalance, inRecord.denorm, tokenOutBalance, outRecord.denorm, tokenAmountOut, _swapFee);
    if (tokenAmountIn > maxAmountIn) {
      revert BPool_TokenAmountInAboveMaxAmountIn();
    }

    tokenInBalance = badd(tokenInBalance, tokenAmountIn);
    tokenOutBalance = bsub(tokenOutBalance, tokenAmountOut);

    spotPriceAfter = calcSpotPrice(tokenInBalance, inRecord.denorm, tokenOutBalance, outRecord.denorm, _swapFee);
    if (spotPriceAfter < spotPriceBefore) {
      revert BPool_SpotPriceAfterBelowSpotPriceBefore();
    }
    if (spotPriceAfter > maxPrice) {
      revert BPool_SpotPriceAboveMaxPrice();
    }
    if (spotPriceBefore > bdiv(tokenAmountIn, tokenAmountOut)) {
      revert BPool_SpotPriceBeforeAboveTokenRatio();
    }

    emit LOG_SWAP(msg.sender, tokenIn, tokenOut, tokenAmountIn, tokenAmountOut);

    _pullUnderlying(tokenIn, msg.sender, tokenAmountIn);
    _pushUnderlying(tokenOut, msg.sender, tokenAmountOut);
  }

  /// @inheritdoc IBPool
  function getSpotPrice(address tokenIn, address tokenOut) external view _viewlock_ returns (uint256) {
    if (!_records[tokenIn].bound) {
      revert BPool_TokenNotBound();
    }
    if (!_records[tokenOut].bound) {
      revert BPool_TokenNotBound();
    }
    Record storage inRecord = _records[tokenIn];
    Record storage outRecord = _records[tokenOut];

    return calcSpotPrice(
      IERC20(tokenIn).balanceOf(address(this)),
      inRecord.denorm,
      IERC20(tokenOut).balanceOf(address(this)),
      outRecord.denorm,
      _swapFee
    );
  }

  /// @inheritdoc IBPool
  function getSpotPriceSansFee(address tokenIn, address tokenOut) external view _viewlock_ returns (uint256) {
    if (!_records[tokenIn].bound) {
      revert BPool_TokenNotBound();
    }
    if (!_records[tokenOut].bound) {
      revert BPool_TokenNotBound();
    }
    Record storage inRecord = _records[tokenIn];
    Record storage outRecord = _records[tokenOut];

    return calcSpotPrice(
      IERC20(tokenIn).balanceOf(address(this)),
      inRecord.denorm,
      IERC20(tokenOut).balanceOf(address(this)),
      outRecord.denorm,
      0
    );
  }

  /// @inheritdoc IBPool
  function isFinalized() external view returns (bool) {
    return _finalized;
  }

  /// @inheritdoc IBPool
  function isBound(address token) external view returns (bool) {
    return _records[token].bound;
  }

  /// @inheritdoc IBPool
  function getNumTokens() external view returns (uint256) {
    return _tokens.length;
  }

  /// @inheritdoc IBPool
  function getCurrentTokens() external view _viewlock_ returns (address[] memory) {
    return _tokens;
  }

  /// @inheritdoc IBPool
  function getFinalTokens() external view _viewlock_ _finalized_ returns (address[] memory) {
    return _tokens;
  }

  /// @inheritdoc IBPool
  function getDenormalizedWeight(address token) external view _viewlock_ returns (uint256) {
    if (!_records[token].bound) {
      revert BPool_TokenNotBound();
    }
    return _records[token].denorm;
  }

  /// @inheritdoc IBPool
  function getTotalDenormalizedWeight() external view _viewlock_ returns (uint256) {
    return _totalWeight;
  }

  /// @inheritdoc IBPool
  function getNormalizedWeight(address token) external view _viewlock_ returns (uint256) {
    if (!_records[token].bound) {
      revert BPool_TokenNotBound();
    }
    uint256 denorm = _records[token].denorm;
    return bdiv(denorm, _totalWeight);
  }

  /// @inheritdoc IBPool
  function getBalance(address token) external view _viewlock_ returns (uint256) {
    if (!_records[token].bound) {
      revert BPool_TokenNotBound();
    }
    return IERC20(token).balanceOf(address(this));
  }

  /// @inheritdoc IBPool
  function getSwapFee() external view _viewlock_ returns (uint256) {
    return _swapFee;
  }

  /// @inheritdoc IBPool
  function getController() external view _viewlock_ returns (address) {
    return _controller;
  }

  /**
   * @notice Sets the value of the transient storage slot used for reentrancy locks
   * @param value The value of the transient storage slot used for reentrancy locks.
   * @dev Should be set to _MUTEX_FREE after a call, any other value will
   * be interpreted as locked
   */
  function _setLock(bytes32 value) internal virtual {
    assembly ("memory-safe") {
      tstore(_MUTEX_TRANSIENT_STORAGE_SLOT, value)
    }
  }

  /**
   * @dev Pulls tokens from the sender. Tokens needs to be approved first. Calls are not locked.
   * @param token The address of the token to pull
   * @param from The address to pull the tokens from
   * @param amount The amount of tokens to pull
   */
  function _pullUnderlying(address token, address from, uint256 amount) internal virtual {
    IERC20(token).safeTransferFrom(from, address(this), amount);
  }

  /**
   * @dev Pushes tokens to the receiver. Calls are not locked.
   * @param token The address of the token to push
   * @param to The address to push the tokens to
   * @param amount The amount of tokens to push
   */
  function _pushUnderlying(address token, address to, uint256 amount) internal virtual {
    IERC20(token).safeTransfer(to, amount);
  }

  /**
   * @dev Hook for extensions to execute custom logic when a pool is finalized,
   * e.g. Setting infinite allowance on BCoWPool
   */
  // solhint-disable-next-line no-empty-blocks
  function _afterFinalize() internal virtual {}

  /**
   * @dev Pulls pool tokens from the sender.
   * @param from The address to pull the pool tokens from
   * @param amount The amount of pool tokens to pull
   */
  function _pullPoolShare(address from, uint256 amount) internal virtual {
    _pull(from, amount);
  }

  /**
   * @dev Pushes pool tokens to the receiver.
   * @param to The address to push the pool tokens to
   * @param amount The amount of pool tokens to push
   */
  function _pushPoolShare(address to, uint256 amount) internal virtual {
    _push(to, amount);
  }

  /**
   * @dev Mints an amount of pool tokens.
   * @param amount The amount of pool tokens to mint
   */
  function _mintPoolShare(uint256 amount) internal virtual {
    _mint(address(this), amount);
  }

  /**
   * @dev Burns an amount of pool tokens.
   * @param amount The amount of pool tokens to burn
   */
  function _burnPoolShare(uint256 amount) internal virtual {
    _burn(address(this), amount);
  }

  /**
   * @notice Gets the value of the transient storage slot used for reentrancy locks
   * @return value Contents of transient storage slot used for reentrancy locks.
   * @dev Should only be compared against _MUTEX_FREE for the purposes of
   * allowing calls
   */
  function _getLock() internal view virtual returns (bytes32 value) {
    assembly ("memory-safe") {
      value := tload(_MUTEX_TRANSIENT_STORAGE_SLOT)
    }
  }
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

import {ERC20} from '@openzeppelin/contracts/token/ERC20/ERC20.sol';

/**
 * @title BToken
 * @notice Balancer Pool Token base contract, providing ERC20 functionality.
 */
contract BToken is ERC20 {
  constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

  /**
   * @notice Increase the allowance of the spender.
   * @param spender The address which will spend the funds.
   * @param amount The amount of tokens to increase the allowance by.
   * @return success True if the operation is successful.
   */
  function increaseApproval(address spender, uint256 amount) external returns (bool success) {
    _approve(msg.sender, spender, allowance(msg.sender, spender) + amount);
    success = true;
  }

  /**
   * @notice Decrease the allowance of the spender.
   * @param spender The address which will spend the funds.
   * @param amount The amount of tokens to decrease the allowance by.
   * @return success True if the operation is successful.
   */
  function decreaseApproval(address spender, uint256 amount) external returns (bool success) {
    uint256 oldValue = allowance(msg.sender, spender);
    if (amount > oldValue) {
      _approve(msg.sender, spender, 0);
    } else {
      _approve(msg.sender, spender, oldValue - amount);
    }
    success = true;
  }

  /**
   * @notice Transfer tokens from one this contract to another.
   * @param to The address which you want to transfer to.
   * @param amount The amount of tokens to be transferred.
   */
  function _push(address to, uint256 amount) internal virtual {
    _transfer(address(this), to, amount);
  }

  /**
   * @notice Pull tokens from another address to this contract.
   * @param from The address which you want to transfer from.
   * @param amount The amount of tokens to be transferred.
   */
  function _pull(address from, uint256 amount) internal virtual {
    _transfer(from, address(this), amount);
  }
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

import {IBFactory} from 'interfaces/IBFactory.sol';

interface IBCoWFactory is IBFactory {
  /**
   * @notice Emitted when a bCoWPool created by this factory is finalized
   * @param bCoWPool The pool just finalized
   */
  event COWAMMPoolCreated(address indexed bCoWPool);

  /**
   * @notice thrown when the caller of `logBCoWPool()` is not a bCoWPool created by this factory
   */
  error BCoWFactory_NotValidBCoWPool();

  /**
   * @notice Emits the COWAMMPoolCreated event if the caller is a bCoWPool, to be indexed by off-chain agents
   */
  function logBCoWPool() external;

  /**
   * @notice The address of the CoW Protocol settlement contract. It is the
   * only address that can set commitments.
   * @return solutionSettler The address of the solution settler.
   */
  // solhint-disable-next-line style-guide-casing
  function SOLUTION_SETTLER() external view returns (address solutionSettler);

  /**
   * @notice The identifier describing which `GPv2Order.AppData` currently
   * apply to this AMM.
   * @return appData The 32 bytes identifier of the allowed GPv2Order AppData.
   */
  // solhint-disable-next-line style-guide-casing
  function APP_DATA() external view returns (bytes32 appData);
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

import {GPv2Order} from '@cowprotocol/libraries/GPv2Order.sol';
import {IERC1271} from '@openzeppelin/contracts/interfaces/IERC1271.sol';
import {IBPool} from 'interfaces/IBPool.sol';
import {ISettlement} from 'interfaces/ISettlement.sol';

interface IBCoWPool is IERC1271, IBPool {
  /**
   * @notice Thrown when a CoW order has a non-zero fee
   */
  error BCoWPool_FeeMustBeZero();

  /**
   * @notice Thrown when a CoW order is executed after its deadline
   */
  error BCoWPool_OrderValidityTooLong();

  /**
   * @notice Thrown when a CoW order has an unknown type (must be GPv2Order.KIND_SELL)
   */
  error BCoWPool_InvalidOperation();

  /**
   * @notice Thrown when a CoW order has an invalid balance marker. BCoWPool
   * only supports BALANCE_ERC20, instructing to use the underlying ERC20
   * balance directly instead of balancer's internal accounting
   */
  error BCoWPool_InvalidBalanceMarker();

  /**
   * @notice The `commit` function can only be called inside a CoW Swap
   * settlement. This error is thrown when the function is called from another
   * context.
   */
  error CommitOutsideOfSettlement();

  /**
   * @notice Error thrown when a solver tries to settle an AMM order on CoW
   * Protocol whose hash doesn't match the one that has been committed to.
   */
  error OrderDoesNotMatchCommitmentHash();

  /**
   * @notice On signature verification, the hash of the order supplied as part
   * of the signature does not match the provided message hash.
   * This usually means that the verification function is being provided a
   * signature that belongs to a different order.
   */
  error OrderDoesNotMatchMessageHash();

  /**
   * @notice Thrown when AppData that was provided during signature verification
   * does not match the one stored in this contract.
   */
  error AppDataDoesNotMatch();

  /**
   * @notice Thrown when the receiver of the order is not the bCoWPool itself.
   */
  error BCoWPool_ReceiverIsNotBCoWPool();

  /**
   * @notice Restricts a specific AMM to being able to trade only the order
   * with the specified hash.
   * @dev The commitment is used to enforce that exactly one AMM order is
   * valid when a CoW Protocol batch is settled.
   * @param orderHash the order hash that will be enforced by the order
   * verification function.
   */
  function commit(bytes32 orderHash) external;

  /**
   * @notice The address that can pull funds from the AMM vault to execute an order
   * @return vaultRelayer The address of the vault relayer.
   */
  // solhint-disable-next-line style-guide-casing
  function VAULT_RELAYER() external view returns (address vaultRelayer);

  /**
   * @notice The domain separator used for hashing CoW Protocol orders.
   * @return solutionSettlerDomainSeparator The domain separator.
   */
  // solhint-disable-next-line style-guide-casing
  function SOLUTION_SETTLER_DOMAIN_SEPARATOR() external view returns (bytes32 solutionSettlerDomainSeparator);

  /**
   * @notice The address of the CoW Protocol settlement contract. It is the
   * only address that can set commitments.
   * @return solutionSettler The address of the solution settler.
   */
  // solhint-disable-next-line style-guide-casing
  function SOLUTION_SETTLER() external view returns (ISettlement solutionSettler);

  /**
   * @notice The identifier describing which `GPv2Order.AppData` currently
   * apply to this AMM.
   * @return appData The 32 bytes identifier of the allowed GPv2Order AppData.
   */
  // solhint-disable-next-line style-guide-casing
  function APP_DATA() external view returns (bytes32 appData);

  /**
   * @notice This function checks that the input order is admissible for the
   * constant-product curve for the given trading parameters.
   * @param order `GPv2Order.Data` of a discrete order to be verified.
   */
  function verify(GPv2Order.Data memory order) external view;
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

import {IBPool} from 'interfaces/IBPool.sol';

interface IBFactory {
  /**
   * @notice Emitted when creating a new pool
   * @param caller The caller of the function that will be set as the controller
   * @param bPool The address of the new pool
   */
  event LOG_NEW_POOL(address indexed caller, address indexed bPool);

  /**
   * @notice Emitted when setting the BDao address
   * @param caller The caller of the set BDao function
   * @param bDao The address of the new BDao
   */
  event LOG_BDAO(address indexed caller, address indexed bDao);

  /**
   * @notice Thrown when setting a variable to address zero
   */
  error BFactory_AddressZero();

  /**
   * @notice Thrown when caller is not BDao address
   */
  error BFactory_NotBDao();

  /**
   * @notice Creates a new BPool, assigning the caller as the pool controller
   * @param name The name of the Pool ERC20 token
   * @param symbol The symbol of the Pool ERC20 token
   * @return bPool The new BPool
   */
  function newBPool(string memory name, string memory symbol) external returns (IBPool bPool);

  /**
   * @notice Sets the BDao address in the factory
   * @param bDao The new BDao address
   */
  function setBDao(address bDao) external;

  /**
   * @notice Collects the fees of a pool and transfers it to BDao address
   * @param bPool The address of the pool to collect fees from
   */
  function collect(IBPool bPool) external;

  /**
   * @notice Checks if an address is a BPool created from this factory
   * @param bPool The address to check
   * @return isBPool True if the address is a BPool, False otherwise
   */
  function isBPool(address bPool) external view returns (bool isBPool);

  /**
   * @notice Gets the BDao address
   * @return bDao The address of the BDao
   */
  function getBDao() external view returns (address bDao);
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';

interface IBPool is IERC20 {
  /**
   * @dev Struct for token records.
   * @param bound If token is bound to pool.
   * @param index Internal index of token array.
   * @param denorm Denormalized weight of token.
   */
  struct Record {
    bool bound;
    uint256 index;
    uint256 denorm;
  }

  /**
   * @notice Emitted when a swap is executed
   * @param caller The caller of the swap function
   * @param tokenIn The address of the token being swapped in
   * @param tokenOut The address of the token being swapped out
   * @param tokenAmountIn The amount of tokenIn being swapped in
   * @param tokenAmountOut The amount of tokenOut being swapped out
   */
  event LOG_SWAP(
    address indexed caller,
    address indexed tokenIn,
    address indexed tokenOut,
    uint256 tokenAmountIn,
    uint256 tokenAmountOut
  );

  /**
   * @notice Emitted when a join operation is executed
   * @param caller The caller of the function
   * @param tokenIn The address of the token being sent to the pool
   * @param tokenAmountIn The balance of the token being sent to the pool
   */
  event LOG_JOIN(address indexed caller, address indexed tokenIn, uint256 tokenAmountIn);

  /**
   * @notice Emitted when a token amount is removed from the pool
   * @param caller The caller of the function
   * @param tokenOut The address of the token being removed from the pool
   * @param tokenAmountOut The amount of the token being removed from the pool
   */
  event LOG_EXIT(address indexed caller, address indexed tokenOut, uint256 tokenAmountOut);

  /**
   * @notice Emitted when a call is executed on the pool
   * @param sig The signature of the function selector being called
   * @param caller The caller of the function
   * @param data The complete data of the call
   */
  event LOG_CALL(bytes4 indexed sig, address indexed caller, bytes data) anonymous;

  /**
   * @notice Thrown when setting a variable to address zero
   */
  error BPool_AddressZero();

  /**
   * @notice Thrown when a reentrant call is made
   */
  error BPool_Reentrancy();

  /**
   * @notice Thrown when the pool is finalized
   */
  error BPool_PoolIsFinalized();

  /**
   * @notice Thrown when the caller is not the controller
   */
  error BPool_CallerIsNotController();

  /**
   * @notice Thrown when the pool is not finalized
   */
  error BPool_FeeBelowMinimum();

  /**
   * @notice Thrown when the fee to set is above the maximum
   */
  error BPool_FeeAboveMaximum();

  /**
   * @notice Thrown when the tokens array is below the minimum
   */
  error BPool_TokensBelowMinimum();

  /**
   * @notice Thrown when the token is already bound in the pool
   */
  error BPool_TokenAlreadyBound();

  /**
   * @notice Thrown when the tokens array is above the maximum
   */
  error BPool_TokensAboveMaximum();

  /**
   * @notice Thrown when the weight to set is below the minimum
   */
  error BPool_WeightBelowMinimum();

  /**
   * @notice Thrown when the weight to set is above the maximum
   */
  error BPool_WeightAboveMaximum();

  /**
   * @notice Thrown when the balance to add is below the minimum
   */
  error BPool_BalanceBelowMinimum();

  /**
   * @notice Thrown when the total weight is above the maximum
   */
  error BPool_TotalWeightAboveMaximum();

  /**
   * @notice Thrown when the ratio between the pool token amount and the total supply is zero
   */
  error BPool_InvalidPoolRatio();

  /**
   * @notice Thrown when the calculated token amount in is zero
   */
  error BPool_InvalidTokenAmountIn();

  /**
   * @notice Thrown when the token amount in is above maximum amount in allowed by the caller
   */
  error BPool_TokenAmountInAboveMaxAmountIn();

  /**
   * @notice Thrown when the calculated token amount out is zero
   */
  error BPool_InvalidTokenAmountOut();

  /**
   * @notice Thrown when the token amount out is below minimum amount out allowed by the caller
   */
  error BPool_TokenAmountOutBelowMinAmountOut();

  /**
   * @notice Thrown when the token is not bound in the pool
   */
  error BPool_TokenNotBound();

  /**
   * @notice Thrown when the pool is not finalized
   */
  error BPool_PoolNotFinalized();

  /**
   * @notice Thrown when the token amount in surpasses the maximum in ratio allowed by the pool
   */
  error BPool_TokenAmountInAboveMaxRatio();

  /**
   * @notice Thrown when the spot price before or after the swap is above the max allowed by the caller
   */
  error BPool_SpotPriceAboveMaxPrice();

  /**
   * @notice Thrown when the token amount out is below the minimum out allowed by the caller
   */
  error BPool_TokenAmountOutBelowMinOut();

  /**
   * @notice Thrown when the spot price after the swap is below the spot price before the swap
   */
  error BPool_SpotPriceAfterBelowSpotPriceBefore();

  /**
   * @notice Thrown when the spot price before the swap is above the ratio between the two tokens in the pool
   */
  error BPool_SpotPriceBeforeAboveTokenRatio();

  /**
   * @notice Thrown when the token amount out surpasses the maximum out allowed by the pool
   */
  error BPool_TokenAmountOutAboveMaxOut();

  /**
   * @notice Thrown when the pool token amount out is below the minimum pool token amount out allowed by the caller
   */
  error BPool_PoolAmountOutBelowMinPoolAmountOut();

  /**
   * @notice Thrown when the calculated pool token amount in is zero
   */
  error BPool_InvalidPoolAmountIn();

  /**
   * @notice Thrown when the pool token amount in is above the maximum amount in allowed by the caller
   */
  error BPool_PoolAmountInAboveMaxPoolAmountIn();

  /**
   * @notice Sets the new swap fee
   * @param swapFee The new swap fee
   */
  function setSwapFee(uint256 swapFee) external;

  /**
   * @notice Sets the new controller
   * @param manager The new controller
   */
  function setController(address manager) external;

  /**
   * @notice Finalize the pool, removing the restrictions on the pool
   */
  function finalize() external;

  /**
   * @notice Binds a token to the pool
   * @param token The address of the token to bind
   * @param balance The balance of the token to bind
   * @param denorm The denormalized weight of the token to bind
   */
  function bind(address token, uint256 balance, uint256 denorm) external;

  /**
   * @notice Unbinds a token from the pool
   * @param token The address of the token to unbind
   */
  function unbind(address token) external;

  /**
   * @notice Joins a pool, providing each token in the pool with a proportional amount
   * @param poolAmountOut The amount of pool tokens to mint
   * @param maxAmountsIn The maximum amount of tokens to send to the pool
   */
  function joinPool(uint256 poolAmountOut, uint256[] calldata maxAmountsIn) external;

  /**
   * @notice Exits a pool, receiving each token in the pool with a proportional amount
   * @param poolAmountIn The amount of pool tokens to burn
   * @param minAmountsOut The minimum amount of tokens to receive from the pool
   */
  function exitPool(uint256 poolAmountIn, uint256[] calldata minAmountsOut) external;

  /**
   * @notice Swaps an exact amount of tokens in for an amount of tokens out
   * @param tokenIn The address of the token to swap in
   * @param tokenAmountIn The amount of token to swap in
   * @param tokenOut The address of the token to swap out
   * @param minAmountOut The minimum amount of token to receive from the swap
   * @param maxPrice The maximum price to pay for the swap
   * @return tokenAmountOut The amount of token swapped out
   * @return spotPriceAfter The spot price after the swap
   */
  function swapExactAmountIn(
    address tokenIn,
    uint256 tokenAmountIn,
    address tokenOut,
    uint256 minAmountOut,
    uint256 maxPrice
  ) external returns (uint256 tokenAmountOut, uint256 spotPriceAfter);

  /**
   * @notice Swaps as many tokens in as needed for an exact amount of tokens out
   * @param tokenIn The address of the token to swap in
   * @param maxAmountIn The maximum amount of token to swap in
   * @param tokenOut The address of the token to swap out
   * @param tokenAmountOut The amount of token to swap out
   * @param maxPrice The maximum price to pay for the swap
   * @return tokenAmountIn The amount of token swapped in
   * @return spotPriceAfter The spot price after the swap
   */
  function swapExactAmountOut(
    address tokenIn,
    uint256 maxAmountIn,
    address tokenOut,
    uint256 tokenAmountOut,
    uint256 maxPrice
  ) external returns (uint256 tokenAmountIn, uint256 spotPriceAfter);

  /**
   * @notice Gets the spot price of tokenIn in terms of tokenOut
   * @param tokenIn The address of the token to swap in
   * @param tokenOut The address of the token to swap out
   * @return spotPrice The spot price of the swap
   */
  function getSpotPrice(address tokenIn, address tokenOut) external view returns (uint256 spotPrice);

  /**
   * @notice Gets the spot price of tokenIn in terms of tokenOut without the fee
   * @param tokenIn The address of the token to swap in
   * @param tokenOut The address of the token to swap out
   * @return spotPrice The spot price of the swap without the fee
   */
  function getSpotPriceSansFee(address tokenIn, address tokenOut) external view returns (uint256 spotPrice);

  /**
   * @notice Gets the finalized status of the pool
   * @return isFinalized True if the pool is finalized, False otherwise
   */
  function isFinalized() external view returns (bool isFinalized);

  /**
   * @notice Gets the bound status of a token
   * @param t The address of the token to check
   * @return isBound True if the token is bound, False otherwise
   */
  function isBound(address t) external view returns (bool isBound);

  /**
   * @notice Gets the number of tokens in the pool
   * @return numTokens The number of tokens in the pool
   */
  function getNumTokens() external view returns (uint256 numTokens);

  /**
   * @notice Gets the current array of tokens in the pool, while the pool is not finalized
   * @return tokens The array of tokens in the pool
   */
  function getCurrentTokens() external view returns (address[] memory tokens);

  /**
   * @notice Gets the final array of tokens in the pool, after finalization
   * @return tokens The array of tokens in the pool
   */
  function getFinalTokens() external view returns (address[] memory tokens);

  /**
   * @notice Gets the denormalized weight of a token in the pool
   * @param token The address of the token to check
   * @return denormWeight The denormalized weight of the token in the pool
   */
  function getDenormalizedWeight(address token) external view returns (uint256 denormWeight);

  /**
   * @notice Gets the total denormalized weight of the pool
   * @return totalDenormWeight The total denormalized weight of the pool
   */
  function getTotalDenormalizedWeight() external view returns (uint256 totalDenormWeight);

  /**
   * @notice Gets the normalized weight of a token in the pool
   * @param token The address of the token to check
   * @return normWeight The normalized weight of the token in the pool
   */
  function getNormalizedWeight(address token) external view returns (uint256 normWeight);

  /**
   * @notice Gets the Pool's ERC20 balance of a token
   * @param token The address of the token to check
   * @return balance The Pool's ERC20 balance of the token
   */
  function getBalance(address token) external view returns (uint256 balance);

  /**
   * @notice Gets the swap fee of the pool
   * @return swapFee The swap fee of the pool
   */
  function getSwapFee() external view returns (uint256 swapFee);

  /**
   * @notice Gets the controller of the pool
   * @return controller The controller of the pool
   */
  function getController() external view returns (address controller);

  /**
   * @notice Gets the BFactory address that deployed the pool
   * @return factory The address of the factory
   */
  // solhint-disable-next-line style-guide-casing
  function FACTORY() external view returns (address factory);
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

import {IERC20} from '@cowprotocol/interfaces/IERC20.sol';
import {GPv2Interaction} from '@cowprotocol/libraries/GPv2Interaction.sol';
import {GPv2Trade} from '@cowprotocol/libraries/GPv2Trade.sol';

/**
 * @title ISettlement
 * @notice External interface of CoW Protocol's SolutionSettler contract.
 */
interface ISettlement {
  /**
   * @notice Settles a batch of trades.
   * @param tokens The tokens that are traded in the batch.
   * @param clearingPrices The clearing prices of the trades.
   * @param trades The trades to settle.
   * @param interactions The interactions to execute.
   */
  function settle(
    IERC20[] calldata tokens,
    uint256[] calldata clearingPrices,
    GPv2Trade.Data[] calldata trades,
    GPv2Interaction.Data[][3] calldata interactions
  ) external;

  /**
   * @return domainSeparator The domain separator for IERC1271 signature
   * @dev Immutable value, would not change on chain forks
   */
  function domainSeparator() external view returns (bytes32 domainSeparator);

  /**
   * @return vaultRelayer The address that'll use the pool liquidity in CoWprotocol swaps
   * @dev Address that will transfer and transferFrom the pool. Has an infinite allowance.
   */
  function vaultRelayer() external view returns (address vaultRelayer);
}