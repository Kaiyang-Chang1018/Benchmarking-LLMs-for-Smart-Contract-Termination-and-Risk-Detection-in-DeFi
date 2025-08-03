// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Ownable2Step} from "openzeppelin-solidity/contracts/access/Ownable2Step.sol";
import {Pausable} from "openzeppelin-solidity/contracts/security/Pausable.sol";
import {Address} from "openzeppelin-solidity/contracts/utils/Address.sol";
import {IMagpieStargateBridgeV3} from "./interfaces/IMagpieStargateBridgeV3.sol";
import {LibAsset} from "./libraries/LibAsset.sol";
import {LibBridge, DepositData, SwapData} from "./libraries/LibBridge.sol";
import {LibRouter, SwapData} from "./libraries/LibRouter.sol";
import {IStargate, MessagingFee, Ticket} from "./interfaces/stargate/IStargate.sol";
import {MessagingFee, OFTReceipt, SendParam} from "./interfaces/stargate/IOFT.sol";

error InvalidCaller();
error ReentrancyError();
error DepositIsNotFound();
error InvalidFrom();
error InvalidStargateAddress();
error InvalidAddress();

contract MagpieStargateBridgeV3 is IMagpieStargateBridgeV3, Ownable2Step, Pausable {
    using LibAsset for address;

    mapping(address => bool) public internalCaller;
    address public weth;
    bytes32 public networkIdAndRouterAddress;
    uint64 public swapSequence;
    mapping(bytes32 => mapping(address => uint256)) public deposit;
    mapping(address => address) public assetToStargate;
    mapping(address => address) public stargateToAsset;
    address public swapFeeAddress;
    address public lzAddress;

    /// @dev Restricts swap functions with signatures to only be called by whitelisted internal caller.
    modifier onlyInternalCaller() {
        if (!internalCaller[msg.sender]) {
            revert InvalidCaller();
        }
        _;
    }

    /// @dev See {IMagpieStargateBridgeV3-updateInternalCaller}
    function updateInternalCaller(address caller, bool value) external onlyOwner {
        internalCaller[caller] = value;

        emit UpdateInternalCaller(msg.sender, caller, value);
    }

    /// @dev See {IMagpieStargateBridgeV3-updateWeth}
    function updateWeth(address value) external onlyOwner {
        weth = value;
    }

    /// @dev See {IMagpieStargateBridgeV3-updateNetworkIdAndRouterAddress}
    function updateNetworkIdAndRouterAddress(bytes32 value) external onlyOwner {
        networkIdAndRouterAddress = value;
    }

    /// @dev See {IMagpieStargateBridgeV3-updateAssetToStargate}
    function updateAssetToStargate(address assetAddress, address stargateAddress) external onlyOwner {
        assetToStargate[assetAddress] = stargateAddress;

        emit UpdateAssetToStargate(msg.sender, assetAddress, stargateAddress);
    }

    /// @dev See {IMagpieStargateBridgeV3-updateStargateToAsset}
    function updateStargateToAsset(address stargateAddress, address assetAddress) external onlyOwner {
        stargateToAsset[stargateAddress] = assetAddress;

        emit UpdateStargateToAsset(msg.sender, stargateAddress, assetAddress);
    }

    /// @dev See {IMagpieStargateBridgeV3-updateSwapFeeAddress}
    function updateSwapFeeAddress(address value) external onlyOwner {
        swapFeeAddress = value;
    }

    /// @dev See {IMagpieStargateBridgeV3-updateLzAddress}
    function updateLzAddress(address value) external onlyOwner {
        lzAddress = value;
    }

    /// @dev See {IMagpieStargateBridgeV3-pause}
    function pause() public onlyOwner whenNotPaused {
        _pause();
    }

    /// @dev See {IMagpieStargateBridgeV3-unpause}
    function unpause() public onlyOwner whenPaused {
        _unpause();
    }

    /// @dev See {IMagpieStargateBridgeV3-swapInWithMagpieSignature}
    function swapInWithMagpieSignature(bytes calldata) external payable whenNotPaused returns (uint256 amountOut) {
        SwapData memory swapData = LibRouter.getData();
        amountOut = swapIn(swapData, true);
    }

    /// @dev See {IMagpieStargateBridgeV3-swapInWithUserSignature}
    function swapInWithUserSignature(bytes calldata) external payable onlyInternalCaller returns (uint256 amountOut) {
        SwapData memory swapData = LibRouter.getData();
        if (swapData.fromAssetAddress.isNative()) {
            revert InvalidAddress();
        }
        amountOut = swapIn(swapData, false);
    }

    /// @dev Verifies the signature for a swap operation.
    /// @param swapData The SwapData struct containing swap details.
    /// @param useCaller Flag indicating whether to use the caller's address for verification.
    /// @return signer The address of the signer if the signature is valid.
    function verifySignature(SwapData memory swapData, bool useCaller) private view returns (address) {
        uint256 messagePtr;
        bool hasAffiliate = swapData.hasAffiliate;
        uint256 swapMessageLength = hasAffiliate ? 384 : 320;
        uint256 messageLength = swapMessageLength + 288;
        assembly {
            messagePtr := mload(0x40)
            mstore(0x40, add(messagePtr, messageLength))
            // hasAffiliate
            switch hasAffiliate
            case 1 {
                // keccak256("Swap(address srcBridge,address srcSender,address srcRecipient,address srcFromAsset,address srcToAsset,uint256 srcDeadline,uint256 srcAmountOutMin,uint256 srcSwapFee,uint256 srcAmountIn,address affiliate,uint256 affiliateFee,bytes32 dstRecipient,bytes32 dstFromAsset,bytes32 dstToAsset,uint256 dstAmountOutMin,uint256 dstSwapFee,uint16 dstNetworkId,bytes32 dstBridge,uint32 bridgeEid,uint128 bridgeGasLimit)")
                mstore(messagePtr, 0x07027edd06d933ad801aa68db7f468ac156371697ee92619cb7c9fc17182dd5d)
            }
            default {
                // keccak256("Swap(address srcBridge,address srcSender,address srcRecipient,address srcFromAsset,address srcToAsset,uint256 srcDeadline,uint256 srcAmountOutMin,uint256 srcSwapFee,uint256 srcAmountIn,bytes32 dstRecipient,bytes32 dstFromAsset,bytes32 dstToAsset,uint256 dstAmountOutMin,uint256 dstSwapFee,uint16 dstNetworkId,bytes32 dstBridge,uint32 bridgeEid,uint128 bridgeGasLimit)")
                mstore(messagePtr, 0x1db1b92ed04ecdb7f72b6c3262412f537c913b3092d701262b450e81e0ea1298)
            }

            let bridgeDataPosition := shr(240, calldataload(add(66, calldataload(36))))
            let currentMessagePtr := add(messagePtr, swapMessageLength)
            mstore(currentMessagePtr, calldataload(bridgeDataPosition)) // toAddress
            currentMessagePtr := add(currentMessagePtr, 32)
            mstore(currentMessagePtr, calldataload(add(bridgeDataPosition, 32))) // fromAssetAddress
            currentMessagePtr := add(currentMessagePtr, 32)
            mstore(currentMessagePtr, calldataload(add(bridgeDataPosition, 64))) // toAssetAddress
            currentMessagePtr := add(currentMessagePtr, 32)
            mstore(currentMessagePtr, calldataload(add(bridgeDataPosition, 96))) // amountOutMin
            currentMessagePtr := add(currentMessagePtr, 32)
            mstore(currentMessagePtr, calldataload(add(bridgeDataPosition, 128))) // swapFee
            currentMessagePtr := add(currentMessagePtr, 32)
            mstore(currentMessagePtr, shr(240, calldataload(add(bridgeDataPosition, 160)))) // recipientNetworkId
            currentMessagePtr := add(currentMessagePtr, 32)
            mstore(currentMessagePtr, calldataload(add(bridgeDataPosition, 162))) // recipientAddress

            currentMessagePtr := add(currentMessagePtr, 32)
            mstore(currentMessagePtr, shr(224, calldataload(add(bridgeDataPosition, 194)))) // dstEid
            currentMessagePtr := add(currentMessagePtr, 32)
            mstore(currentMessagePtr, shr(128, calldataload(add(bridgeDataPosition, 198)))) // gasLimit
        }

        return
            LibRouter.verifySignature(
                // keccak256(bytes("Magpie Stargate Bridge")),
                0x5849a3e6bffd5f0e36a7aae05a726cce29f47268bb265a1987242a08e94dc59e,
                // keccak256(bytes("3")),
                0x2a80e1ef1d7842f27f2e6be0972bb708b9a135c38860dbe73c27c3486c34f4de,
                swapData,
                messagePtr,
                messageLength,
                useCaller,
                2
            );
    }

    /// @dev Executes an inbound swap operation.
    /// @param useCaller Flag indicating whether to use the caller's address for the swap.
    /// @return amountOut The amount received as output from the swap operation.
    function swapIn(SwapData memory swapData, bool useCaller) private returns (uint256 amountOut) {
        swapSequence++;
        uint64 currentSwapSequence = swapSequence;

        uint16 networkId;
        address routerAddress;

        assembly {
            let currentNetworkIdAndRouterAddress := sload(networkIdAndRouterAddress.slot)
            networkId := shr(240, currentNetworkIdAndRouterAddress)
            routerAddress := shr(16, shl(16, currentNetworkIdAndRouterAddress))
        }

        address fromAddress = verifySignature(swapData, useCaller);

        if (swapData.hasPermit) {
            LibRouter.permit(swapData, fromAddress);
        }
        LibRouter.transferFees(swapData, fromAddress, swapData.swapFee == 0 ? address(0) : swapFeeAddress);

        bytes memory encodedDepositData = new bytes(236); // 194 + 42
        LibBridge.fillEncodedDepositData(encodedDepositData, networkId, currentSwapSequence);
        bytes32 depositDataHash = keccak256(encodedDepositData);

        amountOut = LibBridge.swapIn(swapData, encodedDepositData, fromAddress, routerAddress, weth);

        bridgeIn(
            LibBridge.getFee(swapData),
            fromAddress,
            swapData.toAssetAddress,
            amountOut,
            swapData.amountOutMin,
            depositDataHash
        );

        if (currentSwapSequence != swapSequence) {
            revert ReentrancyError();
        }
    }

    /// @dev Retrieves extra options for SendParam, encoded as bytes.
    /// @param gasLimit The gas limit to be included in the extra options.
    /// @return optionsBytes The encoded extra options as bytes.
    function getExtraOptions(uint128 gasLimit) private pure returns (bytes memory) {
        uint16 type3 = 3;
        uint8 workerId = 1;
        uint16 index = 0;
        uint8 optionType = 3;
        uint16 optionLength = 19; // uint16 + uint128 + 1
        return abi.encodePacked(type3, workerId, optionLength, optionType, index, gasLimit);
    }

    /// @dev Constructs a SendParam struct with specified amount and encoded deposit data.
    /// @param amount The amount to be sent.
    /// @param amountMin The minimum amount to be sent.
    /// @param depositDataHash Encoded hash related to the crosschain transaction.
    /// @return sendParam The constructed SendParam struct.
    function getSendParam(
        uint256 amount,
        uint256 amountMin,
        bytes32 depositDataHash
    ) private pure returns (SendParam memory) {
        bytes32 receiver;
        uint32 dstEid;
        uint128 gasLimit;
        assembly {
            let bridgeDataPosition := shr(240, calldataload(add(66, calldataload(36))))

            receiver := calldataload(add(bridgeDataPosition, 162))
            dstEid := shr(224, calldataload(add(bridgeDataPosition, 194)))
            gasLimit := shr(128, calldataload(add(bridgeDataPosition, 198)))
        }

        return
            SendParam({
                dstEid: dstEid,
                to: receiver,
                amountLD: amount,
                minAmountLD: amountMin,
                extraOptions: getExtraOptions(gasLimit),
                composeMsg: LibBridge.encodeDepositDataHash(depositDataHash),
                oftCmd: ""
            });
    }

    /// @dev Bridges an inbound asset transfer into the contract.
    /// @param bridgeFee Bridge fee that has to be payed in native token.
    /// @param refundAddress If the operation fails, tokens will be transferred to this address.
    /// @param toAssetAddress The address of the asset being bridged into the contract.
    /// @param amount The amount of the asset being transferred into the contract.
    /// @param amountMin The minimum amount of the asset being transferred into the contract.
    /// @param depositDataHash Encoded hash related to the crosschain transaction.
    function bridgeIn(
        uint256 bridgeFee,
        address refundAddress,
        address toAssetAddress,
        uint256 amount,
        uint256 amountMin,
        bytes32 depositDataHash
    ) private {
        address currentStargateAddress = assetToStargate[toAssetAddress];

        if (currentStargateAddress == address(0)) {
            revert InvalidStargateAddress();
        }

        uint256 valueToSend = bridgeFee;

        if (toAssetAddress.isNative()) {
            valueToSend += amount;
        } else {
            toAssetAddress.approve(currentStargateAddress, amount);
        }

        SendParam memory sendParam = getSendParam(amount, amountMin, depositDataHash);
        IStargate(currentStargateAddress).sendToken{value: valueToSend}(
            sendParam,
            MessagingFee({nativeFee: bridgeFee, lzTokenFee: 0}),
            refundAddress
        );
    }

    /// @dev See {IMagpieStargateBridgeV3-swapOut}
    function swapOut(bytes calldata) external onlyInternalCaller returns (uint256 amountOut) {
        address routerAddress;
        uint16 networkId;
        assembly {
            let currentNetworkIdAndRouterAddress := sload(networkIdAndRouterAddress.slot)
            networkId := shr(240, currentNetworkIdAndRouterAddress)
            routerAddress := shr(16, shl(16, currentNetworkIdAndRouterAddress))
        }

        SwapData memory swapData = LibRouter.getData();
        bytes32 depositDataHash = LibBridge.getDepositDataHash(swapData, networkId, address(this));
        uint256 depositAmount = deposit[depositDataHash][swapData.fromAssetAddress];

        if (depositAmount == 0) {
            revert DepositIsNotFound();
        }

        deposit[depositDataHash][swapData.fromAssetAddress] = 0;

        amountOut = LibBridge.swapOut(swapData, depositAmount, depositDataHash, routerAddress, weth, swapFeeAddress);
    }

    // @dev Extracts and returns the deposit amount from the encoded bytes.
    // @param encodedAmount The bytes array containing the encoded amount.
    // @return amount The decoded uint256 deposit amount.
    function getDepositAmount(bytes memory encodedAmount) private pure returns (uint256 amount) {
        assembly {
            amount := mload(add(encodedAmount, 32))
        }
    }

    event Deposit(bytes32 depositDataHash, uint256 amount);

    /// @dev See {IMagpieStargateBridgeV3-lzCompose}
    function lzCompose(address from, bytes32, bytes calldata message, address, bytes calldata) external payable {
        address assetAddress = stargateToAsset[from];
        if (assetToStargate[assetAddress] != from) {
            revert InvalidFrom();
        }
        if (msg.sender != lzAddress) {
            revert InvalidCaller();
        }

        bytes32 depositDataHash = LibBridge.decodeDepositDataHash(message[76:]);
        uint256 currentDeposit = deposit[depositDataHash][assetAddress] + getDepositAmount(message[12:44]);

        deposit[depositDataHash][assetAddress] += currentDeposit;

        emit Deposit(depositDataHash, currentDeposit);
    }

    /// @dev See {IMagpieStargateBridgeV3-multicall}
    function multicall(bytes[] calldata data) external onlyOwner returns (bytes[] memory results) {
        results = new bytes[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            results[i] = Address.functionDelegateCall(address(this), data[i]);
        }
        return results;
    }

    /// @dev Used to receive ethers
    receive() external payable {}
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

interface IBridge {
    event SwapIn(
        address indexed fromAddress,
        address indexed toAddress,
        address fromAssetAddress,
        address toAssetAddress,
        uint256 amountIn,
        uint256 amountOut,
        bytes encodedDepositData
    );

    event SwapOut(
        address indexed fromAddress,
        address indexed toAddress,
        address fromAssetAddress,
        address toAssetAddress,
        uint256 amountIn,
        uint256 amountOut,
        bytes32 depositDataHash
    );

    event UpdateInternalCaller(address indexed sender, address caller, bool value);

    /// @dev Allows the owner to update the whitelisted internal callers.
    /// @param caller Caller address.
    /// @param value Disable or enable the related caller.
    function updateInternalCaller(address caller, bool value) external;

    /// @dev Allows the owner to update weth.
    /// @param value New weth address.
    function updateWeth(address value) external;

    /// @dev Allows the owner to update Magpie networkId and routerAddress.
    /// @param value Compressed networkId and routerAddress.
    function updateNetworkIdAndRouterAddress(bytes32 value) external;

    /// @dev Makes it possible to execute multiple functions in the same transaction.
    function multicall(bytes[] calldata data) external returns (bytes[] memory results);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

interface IMagpieRouterV3 {
    event UpdateInternalCaller(address indexed sender, address caller, bool value);

    /// @dev Allows the owner to update the whitelisted internal callers.
    /// @param caller Caller address.
    /// @param value Disable or enable the related caller.
    function updateInternalCaller(address caller, bool value) external;

    event UpdateBridge(address indexed sender, address caller, bool value);

    /// @dev Allows the owner to update the whitelisted bridges.
    /// @param caller Caller address.
    /// @param value Disable or enable the related caller.
    function updateBridge(address caller, bool value) external;

    /// @dev Allows the owner to update the swap fee receiver.
    /// @param value Swap fee receiver address.
    function updateSwapFeeAddress(address value) external;

    /// @dev Called by the owner to pause, triggers stopped state.
    function pause() external;

    /// @dev Called by the owner to unpause, returns to normal state.
    function unpause() external;

    event Swap(
        address indexed fromAddress,
        address indexed toAddress,
        address fromAssetAddress,
        address toAssetAddress,
        uint256 amountIn,
        uint256 amountOut
    );

    /// @dev Makes it possible to execute multiple functions in the same transaction.
    function multicall(bytes[] calldata data) external returns (bytes[] memory results);

    /// @dev Provides an external interface to estimate the gas cost of the last hop in a route.
    /// @return amountOut The amount received after swapping.
    /// @return gasUsed The cost of gas while performing the swap.
    function estimateSwapGas(bytes calldata swapArgs) external payable returns (uint256 amountOut, uint256 gasUsed);

    /// @dev Performs token swap with magpie signature.
    /// @return amountOut The amount received after swapping.
    function swapWithMagpieSignature(bytes calldata swapArgs) external payable returns (uint256 amountOut);

    /// @dev Performs token swap with a user signature.
    /// @return amountOut The amount received after swapping.
    function swapWithUserSignature(bytes calldata swapArgs) external payable returns (uint256 amountOut);

    /// @dev Performs token swap without a signature (data will be validated in the bridge) without triggering event.
    /// @return amountOut The amount received after swapping.
    function swapWithoutSignature(bytes calldata swapArgs) external payable returns (uint256 amountOut);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {IMessageBus} from "./celer/IMessageBus.sol";
import {IBridge} from "./IBridge.sol";

interface IMagpieStargateBridgeV3 is IBridge {
    event UpdateAssetToStargate(address indexed sender, address assetAddress, address stargateAddress);

    /// @dev Allows the owner to update asset to stargate mapping.
    /// @param assetAddress Asset of the specified stargate pool.
    /// @param stargateAddress Stargate address.
    function updateAssetToStargate(address assetAddress, address stargateAddress) external;

    event UpdateStargateToAsset(address indexed sender, address stargateAddress, address assetAddress);

    /// @dev Allows the owner to update stargate to asset mapping.
    /// @param stargateAddress Stargate address.
    /// @param assetAddress Asset of the specified stargate pool.
    function updateStargateToAsset(address stargateAddress, address assetAddress) external;

    /// @dev Allows the owner to update the swap fee receiver.
    /// @param value Swap fee receiver address.
    function updateSwapFeeAddress(address value) external;

    /// @dev Allows the owner to update LayerZero address.
    /// @param value New lzAddress.
    function updateLzAddress(address value) external;

    /// @dev Called by the owner to pause, triggers stopped state.
    function pause() external;

    /// @dev Called by the owner to unpause, returns to normal state.
    function unpause() external;

    /// @dev Allows Stargate to transfer and update the deposited amounts accordingly.
    function lzCompose(address from, bytes32, bytes calldata message, address, bytes calldata) external payable;
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

interface IWETH {
    function deposit() external payable;

    function transfer(address to, uint256 value) external returns (bool);

    function withdraw(uint256) external;
}
// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.24;

interface IMessageBus {
    struct SwapInfo {
        address[] path;
        address dex;
        uint256 deadline;
        uint256 minRecvAmt;
    }

    struct SwapRequest {
        SwapInfo swap;
        address receiver;
        uint64 nonce;
        bool nativeOut;
    }

    enum BridgeSendType {
        Null,
        Liquidity,
        PegDeposit,
        PegBurn,
        PegV2Deposit,
        PegV2Burn,
        PegV2BurnFrom
    }

    enum TransferType {
        Null,
        LqRelay,
        LqWithdraw,
        PegMint,
        PegWithdraw,
        PegV2Mint,
        PegV2Withdraw
    }

    enum MsgType {
        MessageWithTransfer,
        MessageOnly
    }

    enum TxStatus {
        Null,
        Success,
        Fail,
        Fallback,
        Pending
    }

    struct TransferInfo {
        TransferType t;
        address sender;
        address receiver;
        address token;
        uint256 amount;
        uint64 wdseq;
        uint64 srcChainId;
        bytes32 refId;
        bytes32 srcTxHash;
    }

    function sendMessageWithTransfer(
        address _receiver,
        uint256 _dstChainId,
        address _srcBridge,
        bytes32 _srcTransferId,
        bytes calldata _message
    ) external payable;

    function executeMessageWithTransfer(
        bytes calldata _message,
        TransferInfo calldata _transfer,
        bytes[] calldata _sigs,
        address[] calldata _signers,
        uint256[] calldata _powers
    ) external payable;

    function executeMessageWithTransferRefund(
        bytes calldata _message,
        TransferInfo calldata _transfer,
        bytes[] calldata _sigs,
        address[] calldata _signers,
        uint256[] calldata _powers
    ) external payable;

    function calcFee(bytes calldata _message) external view returns (uint256);

    function liquidityBridge() external view returns (address);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

struct MessagingReceipt {
    bytes32 guid;
    uint64 nonce;
    MessagingFee fee;
}

struct MessagingFee {
    uint256 nativeFee;
    uint256 lzTokenFee;
}

struct SendParam {
    uint32 dstEid;
    bytes32 to;
    uint256 amountLD;
    uint256 minAmountLD;
    bytes extraOptions;
    bytes composeMsg;
    bytes oftCmd;
}

struct OFTLimit {
    uint256 minAmountLD;
    uint256 maxAmountLD;
}

struct OFTReceipt {
    uint256 amountSentLD;
    uint256 amountReceivedLD;
}

struct OFTFeeDetail {
    int256 feeAmountLD;
    string description;
}

interface IOFT {
    error InvalidLocalDecimals();
    error SlippageExceeded(uint256 amountLD, uint256 minAmountLD);

    event OFTSent(
        bytes32 indexed guid, // GUID of the OFT message.
        uint32 dstEid, // Destination Endpoint ID.
        address indexed fromAddress, // Address of the sender on the src chain.
        uint256 amountSentLD, // Amount of tokens sent in local decimals.
        uint256 amountReceivedLD // Amount of tokens received in local decimals.
    );
    event OFTReceived(
        bytes32 indexed guid, // GUID of the OFT message.
        uint32 srcEid, // Source Endpoint ID.
        address indexed toAddress, // Address of the recipient on the dst chain.
        uint256 amountReceivedLD // Amount of tokens received in local decimals.
    );

    function oftVersion() external view returns (bytes4 interfaceId, uint64 version);

    function token() external view returns (address);

    function approvalRequired() external view returns (bool);

    function sharedDecimals() external view returns (uint8);

    function quoteOFT(
        SendParam calldata _sendParam
    ) external view returns (OFTLimit memory, OFTFeeDetail[] memory oftFeeDetails, OFTReceipt memory);

    function quoteSend(SendParam calldata _sendParam, bool _payInLzToken) external view returns (MessagingFee memory);

    function send(
        SendParam calldata _sendParam,
        MessagingFee calldata _fee,
        address _refundAddress
    ) external payable returns (MessagingReceipt memory, OFTReceipt memory);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

// Solidity does not support splitting import across multiple lines
// solhint-disable-next-line max-line-length
import {IOFT, SendParam, MessagingFee, MessagingReceipt, OFTReceipt} from "./IOFT.sol";

/// @notice Stargate implementation type.
enum StargateType {
    Pool,
    OFT
}

/// @notice Ticket data for bus ride.
struct Ticket {
    uint72 ticketId;
    bytes passengerBytes;
}

/// @title Interface for Stargate.
/// @notice Defines an API for sending tokens to destination chains.
interface IStargate is IOFT {
    /// @dev This function is same as `send` in OFT interface but returns the ticket data if in the bus ride mode,
    /// which allows the caller to ride and drive the bus in the same transaction.
    function sendToken(
        SendParam calldata _sendParam,
        MessagingFee calldata _fee,
        address _refundAddress
    ) external payable returns (MessagingReceipt memory msgReceipt, OFTReceipt memory oftReceipt, Ticket memory ticket);

    /// @notice Returns the Stargate implementation type.
    function stargateType() external pure returns (StargateType);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "../interfaces/IWETH.sol";

error AssetNotReceived();
error ApprovalFailed();
error TransferFromFailed();
error TransferFailed();
error FailedWrap();
error FailedUnwrap();

library LibAsset {
    using LibAsset for address;

    address constant NATIVE_ASSETID = address(0);

    /// @dev Checks if the given address (self) represents a native asset (Ether).
    /// @param self The asset that will be checked for a native token.
    /// @return Flag to identify if the asset is native or not.
    function isNative(address self) internal pure returns (bool) {
        return self == NATIVE_ASSETID;
    }

    /// @dev Wraps the specified asset.
    /// @param self The asset that will be wrapped.
    function wrap(address self, uint256 amount) internal {
        uint256 ptr;
        assembly {
            ptr := mload(0x40)
            mstore(0x40, add(ptr, 4))
            mstore(ptr, 0xd0e30db000000000000000000000000000000000000000000000000000000000)
        }

        if (!execute(self, amount, ptr, 4, 0, 0)) {
            revert FailedWrap();
        }
    }

    /// @dev Unwraps the specified asset.
    /// @param self The asset that will be unwrapped.
    function unwrap(address self, uint256 amount) internal {
        uint256 ptr;
        assembly {
            ptr := mload(0x40)
            mstore(0x40, add(ptr, 36))
            mstore(ptr, 0x2e1a7d4d00000000000000000000000000000000000000000000000000000000)
            mstore(add(ptr, 4), amount)
        }

        if (!execute(self, 0, ptr, 36, 0, 0)) {
            revert FailedUnwrap();
        }
    }

    /// @dev Retrieves the balance of the current contract for a given asset (self).
    /// @param self Asset whose balance needs to be found.
    /// @return Balance of the specific asset.
    function getBalance(address self) internal view returns (uint256) {
        return getBalanceOf(self, address(this));
    }

    /// @dev Retrieves the balance of the target address for a given asset (self).
    /// @param self Asset whose balance needs to be found.
    /// @param targetAddress The address where the balance is checked from.
    /// @return amount Balance of the specific asset.
    function getBalanceOf(address self, address targetAddress) internal view returns (uint256 amount) {
        assembly {
            switch self
            case 0 {
                amount := balance(targetAddress)
            }
            default {
                let currentInputPtr := mload(0x40)
                mstore(0x40, add(currentInputPtr, 68))
                mstore(currentInputPtr, 0x70a0823100000000000000000000000000000000000000000000000000000000)
                mstore(add(currentInputPtr, 4), targetAddress)
                let currentOutputPtr := add(currentInputPtr, 36)
                if iszero(staticcall(gas(), self, currentInputPtr, 36, currentOutputPtr, 32)) {
                    returndatacopy(0, 0, returndatasize())
                    revert(0, returndatasize())
                }

                amount := mload(currentOutputPtr)
            }
        }
    }

    /// @dev Performs a safe transferFrom operation for a given asset (self) from one address (from) to another address (to).
    /// @param self Asset that will be transferred.
    /// @param from Address that will send the asset.
    /// @param to Address that will receive the asset.
    /// @param amount Transferred amount.
    function transferFrom(address self, address from, address to, uint256 amount) internal {
        uint256 ptr;
        assembly {
            ptr := mload(0x40)
            mstore(0x40, add(ptr, 100))
            mstore(ptr, 0x23b872dd00000000000000000000000000000000000000000000000000000000)
            mstore(add(ptr, 4), from)
            mstore(add(ptr, 36), to)
            mstore(add(ptr, 68), amount)
        }

        if (!execute(self, 0, ptr, 100, 0, 0)) {
            revert TransferFromFailed();
        }
    }

    /// @dev Transfers a given amount of an asset (self) to a recipient address (recipient).
    /// @param self Asset that will be transferred.
    /// @param recipient Address that will receive the transferred asset.
    /// @param amount Transferred amount.
    function transfer(address self, address recipient, uint256 amount) internal {
        if (self.isNative()) {
            (bool success, ) = payable(recipient).call{value: amount}("");
            if (!success) {
                revert TransferFailed();
            }
        } else {
            uint256 ptr;
            assembly {
                ptr := mload(0x40)
                mstore(0x40, add(ptr, 68))
                mstore(ptr, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
                mstore(add(ptr, 4), recipient)
                mstore(add(ptr, 36), amount)
            }
            if (!execute(self, 0, ptr, 68, 0, 0)) {
                revert TransferFailed();
            }
        }
    }

    /// @dev Approves a spender address (spender) to spend a specified amount of an asset (self).
    /// @param self The asset that will be approved.
    /// @param spender Address of a contract that will spend the owners asset.
    /// @param amount Asset amount that can be spent.
    function approve(address self, address spender, uint256 amount) internal {
        uint256 ptr;
        assembly {
            ptr := mload(0x40)
            mstore(0x40, add(ptr, 68))
            mstore(ptr, 0x095ea7b300000000000000000000000000000000000000000000000000000000)
            mstore(add(ptr, 4), spender)
            mstore(add(ptr, 36), amount)
        }

        if (!execute(self, 0, ptr, 68, 0, 0)) {
            assembly {
                mstore(add(ptr, 36), 0)
            }
            if (!execute(self, 0, ptr, 68, 0, 0)) {
                revert ApprovalFailed();
            }
            assembly {
                mstore(add(ptr, 36), amount)
            }
            if (!execute(self, 0, ptr, 68, 0, 0)) {
                revert ApprovalFailed();
            }
        }
    }

    function permit(
        address self,
        address owner,
        address spender,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        assembly {
            let ptr := mload(0x40)
            mstore(0x40, add(ptr, 228))
            mstore(ptr, 0xd505accf00000000000000000000000000000000000000000000000000000000)
            mstore(add(ptr, 4), owner)
            mstore(add(ptr, 36), spender)
            mstore(add(ptr, 68), amount)
            mstore(add(ptr, 100), deadline)
            mstore(add(ptr, 132), v)
            mstore(add(ptr, 164), r)
            mstore(add(ptr, 196), s)
            let success := call(gas(), self, 0, ptr, 228, 0, 0)
        }
    }

    /// @dev Determines if a call was successful.
    /// @param target Address of the target contract.
    /// @param success To check if the call to the contract was successful or not.
    /// @param data The data was sent while calling the target contract.
    /// @return result The success of the call.
    function isSuccessful(address target, bool success, bytes memory data) private view returns (bool result) {
        if (success) {
            if (data.length == 0) {
                // isContract
                if (target.code.length > 0) {
                    result = true;
                }
            } else {
                assembly {
                    result := mload(add(data, 32))
                }
            }
        }
    }

    /// @dev Executes a low level call.
    function execute(
        address self,
        uint256 currentNativeAmount,
        uint256 currentInputPtr,
        uint256 currentInputLength,
        uint256 currentOutputPtr,
        uint256 outputLength
    ) internal returns (bool result) {
        assembly {
            function isSuccessfulCall(targetAddress) -> isSuccessful {
                switch iszero(returndatasize())
                case 1 {
                    if gt(extcodesize(targetAddress), 0) {
                        isSuccessful := 1
                    }
                }
                case 0 {
                    returndatacopy(0, 0, 32)
                    isSuccessful := gt(mload(0), 0)
                }
            }

            if iszero(
                call(
                    gas(),
                    self,
                    currentNativeAmount,
                    currentInputPtr,
                    currentInputLength,
                    currentOutputPtr,
                    outputLength
                )
            ) {
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }

            result := isSuccessfulCall(self)
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {IMagpieRouterV3} from "../interfaces/IMagpieRouterV3.sol";
import {IBridge} from "../interfaces/IBridge.sol";
import {LibAsset} from "./LibAsset.sol";
import {LibRouter, SwapData} from "./LibRouter.sol";

struct DepositData {
    address toAddress;
    address fromAssetAddress;
    address toAssetAddress;
    uint256 amountOutMin;
    uint256 swapFee;
    uint256 amountIn;
    uint16 networkId; // Source network id that is defined by Magpie protocol for each chain
    bytes32 senderAddress; // The sender address in bytes32
    uint64 swapSequence; // Swap sequence (unique identifier) of the crosschain swap
}

error InvalidSwapData();
error InvalidSignature();
error InvalidToAddress();
error InvalidAmountIn();
error InvalidSwapFee();
error InvalidDepositAmount();

library LibBridge {
    using LibAsset for address;

    function getFee(SwapData memory swapData) internal view returns (uint256 bridgeFee) {
        bridgeFee = swapData.fromAssetAddress.isNative()
            ? msg.value - (swapData.amountIn + swapData.swapFee + swapData.affiliateFee)
            : msg.value;
    }

    function decodeDepositDataHash(bytes memory payload) internal pure returns (bytes32 depositDataHash) {
        assembly {
            depositDataHash := mload(add(payload, 32))
        }
    }

    function encodeDepositDataHash(bytes32 depositDataHash) internal pure returns (bytes memory payload) {
        payload = new bytes(32);
        assembly {
            mstore(add(payload, 32), depositDataHash)
        }
    }

    function getDepositDataHash(
        SwapData memory swapData,
        uint16 recipientNetworkId,
        address recipientAddress
    ) internal pure returns (bytes32 depositDataHash) {
        assembly {
            let depositDataPtr := mload(0x40)
            mstore(0x40, add(depositDataPtr, 236))

            mstore(depositDataPtr, mload(swapData)) // toAddress
            mstore(add(depositDataPtr, 32), mload(add(swapData, 32))) // fromAssetAddress
            mstore(add(depositDataPtr, 64), mload(add(swapData, 64))) // toAssetAddress
            mstore(add(depositDataPtr, 96), mload(add(swapData, 128))) // amountOutMin
            mstore(add(depositDataPtr, 128), mload(add(swapData, 160))) // swapFee
            mstore(add(depositDataPtr, 160), shl(240, recipientNetworkId)) // recipientNetworkId
            mstore(add(depositDataPtr, 162), recipientAddress) // recipientAddress
            calldatacopy(add(depositDataPtr, 194), shr(240, calldataload(add(66, calldataload(36)))), 42) // networkId, senderAddress, swapSequence
            depositDataHash := keccak256(depositDataPtr, 236)
        }
    }

    /// @dev Fills the specified variable with encoded deposit data.
    /// @param encodedDepositData Variable / Placeholder that will be filled with the deposit data.
    /// @param networkId The identifier of the sender network.
    /// @param swapSequence The current swap sequence number.
    function fillEncodedDepositData(
        bytes memory encodedDepositData,
        uint16 networkId,
        uint64 swapSequence
    ) internal view {
        assembly {
            // DepositData
            calldatacopy(add(encodedDepositData, 32), shr(240, calldataload(add(66, calldataload(36)))), 194)

            // TransferKey
            mstore(add(encodedDepositData, 226), shl(240, networkId)) // 194 + 32
            mstore(add(encodedDepositData, 228), address()) // 194 + 32 + 2
            mstore(add(encodedDepositData, 260), shl(192, swapSequence)) // 194 + 32 + 34
        }
    }

    /// @dev Executes a swap operation using a specified router and native amount.
    /// @param routerAddress The address of the router contract for the swap.
    /// @param nativeAmount The amount of native currency to be swapped.
    /// @return amountOut The amount received as output from the swap operation.
    function swap(address routerAddress, uint256 nativeAmount) private returns (uint256 amountOut, bool success) {
        assembly {
            let inputPtr := mload(0x40)
            let inputLength := shr(240, calldataload(add(66, calldataload(36)))) // bridgeDataPosition
            let payloadLength := sub(inputLength, 68)
            mstore(0x40, add(inputPtr, inputLength))
            mstore(inputPtr, 0x158f689400000000000000000000000000000000000000000000000000000000) // swapWithoutSignature
            mstore(add(inputPtr, 4), 32)
            mstore(add(inputPtr, 36), payloadLength)
            let outputPtr := mload(0x40)
            mstore(0x40, add(outputPtr, 32))
            calldatacopy(add(inputPtr, 68), 68, payloadLength)
            success := call(gas(), routerAddress, nativeAmount, inputPtr, inputLength, outputPtr, 32)

            if eq(success, 1) {
                amountOut := mload(outputPtr)
            }
        }
    }

    /// @dev Executes an inbound swap operation using provided data and addresses.
    /// @param swapData The SwapData struct containing swap details.
    /// @param encodedDepositData Encoded data related to the deposit.
    /// @param fromAddress The address from which the swap originates.
    /// @param routerAddress The address of the router contract for the swap.
    /// @param weth The address of the Wrapped Ether contract.
    /// @return amountOut The amount received as output from the swap operation.
    function swapIn(
        SwapData memory swapData,
        bytes memory encodedDepositData,
        address fromAddress,
        address routerAddress,
        address weth
    ) internal returns (uint256 amountOut) {
        if (swapData.toAddress != address(this)) {
            revert InvalidToAddress();
        }

        if (swapData.fromAssetAddress.isNative()) {
            if (msg.value < (swapData.amountIn + swapData.swapFee + swapData.affiliateFee)) {
                revert InvalidAmountIn();
            }
        }

        if (swapData.fromAssetAddress.isNative() && swapData.toAssetAddress == weth) {
            weth.wrap(swapData.amountIn);
            amountOut = swapData.amountIn;
        } else if (swapData.fromAssetAddress == weth && swapData.toAssetAddress.isNative()) {
            swapData.fromAssetAddress.transferFrom(fromAddress, address(this), swapData.amountIn);
            weth.unwrap(swapData.amountIn);
            amountOut = swapData.amountIn;
        } else if (swapData.fromAssetAddress == swapData.toAssetAddress) {
            swapData.fromAssetAddress.transferFrom(fromAddress, address(this), swapData.amountIn);
            amountOut = swapData.amountIn;
        } else {
            uint256 nativeAmount = 0;
            if (swapData.fromAssetAddress.isNative()) {
                nativeAmount = swapData.amountIn;
            } else {
                swapData.fromAssetAddress.transferFrom(fromAddress, address(this), swapData.amountIn);
                swapData.fromAssetAddress.approve(routerAddress, swapData.amountIn);
            }
            bool success = false;
            (amountOut, success) = swap(routerAddress, nativeAmount);
            if (!success) {
                assembly {
                    returndatacopy(0, 0, returndatasize())
                    revert(0, returndatasize())
                }
            }
        }

        emit IBridge.SwapIn(
            fromAddress,
            swapData.toAddress,
            swapData.fromAssetAddress,
            swapData.toAssetAddress,
            swapData.amountIn + swapData.swapFee + swapData.affiliateFee,
            amountOut,
            encodedDepositData
        );
    }

    /// @dev Executes an outbound swap operation using provided swap and deposit data.
    /// @param swapData The SwapData struct containing swap details.
    /// @param depositAmount The bridged amount that will be swapped.
    /// @param routerAddress The address of the router contract for the swap.
    /// @param weth The address of the Wrapped Ether contract.
    /// @return amountOut The amount received as output from the swap operation.
    function swapOut(
        SwapData memory swapData,
        uint256 depositAmount,
        bytes32 depositDataHash,
        address routerAddress,
        address weth,
        address swapFeeAddress
    ) internal returns (uint256 amountOut) {
        if (depositAmount != swapData.amountIn + swapData.swapFee) {
            revert InvalidDepositAmount();
        }

        if (swapData.swapFee > 0) {
            swapData.fromAssetAddress.transfer(swapFeeAddress, swapData.swapFee);
        }

        if (swapData.amountIn > 0) {
            if (swapData.fromAssetAddress == weth && swapData.toAssetAddress.isNative()) {
                weth.unwrap(swapData.amountIn);
                swapData.fromAssetAddress.transfer(swapData.toAddress, swapData.amountIn);
            } else if (swapData.fromAssetAddress.isNative() && swapData.toAssetAddress == weth) {
                weth.wrap(swapData.amountIn);
                swapData.fromAssetAddress.transfer(swapData.toAddress, swapData.amountIn);

                amountOut = swapData.amountIn;
            } else if (swapData.fromAssetAddress == swapData.toAssetAddress) {
                swapData.fromAssetAddress.transfer(swapData.toAddress, swapData.amountIn);

                amountOut = swapData.amountIn;
            } else {
                // We dont need signature, we validate against crosschain message
                uint256 nativeAmount = 0;
                if (swapData.fromAssetAddress.isNative()) {
                    nativeAmount = swapData.amountIn;
                } else {
                    swapData.fromAssetAddress.approve(routerAddress, swapData.amountIn);
                }

                bool success = false;
                (amountOut, success) = swap(routerAddress, nativeAmount);
                if (!success) {
                    if (!swapData.fromAssetAddress.isNative()) {
                        swapData.fromAssetAddress.approve(routerAddress, 0);
                    }
                    swapData.fromAssetAddress.transfer(swapData.toAddress, swapData.amountIn);
                    swapData.toAssetAddress = swapData.fromAssetAddress;
                    amountOut = swapData.amountIn;
                }
            }
        }

        emit IBridge.SwapOut(
            msg.sender,
            swapData.toAddress,
            swapData.fromAssetAddress,
            swapData.toAssetAddress,
            swapData.amountIn + swapData.swapFee,
            amountOut,
            depositDataHash
        );
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {LibAsset} from "../libraries/LibAsset.sol";

struct SwapData {
    address toAddress;
    address fromAssetAddress;
    address toAssetAddress;
    uint256 deadline;
    uint256 amountOutMin;
    uint256 swapFee;
    uint256 amountIn;
    bool hasPermit;
    bool hasAffiliate;
    address affiliateAddress;
    uint256 affiliateFee;
}

error InvalidSignature();
error ExpiredTransaction();

library LibRouter {
    using LibAsset for address;

    /// @dev Prepares SwapData from calldata
    function getData() internal view returns (SwapData memory swapData) {
        // dataOffset: 68 + 2
        assembly {
            let deadline := shr(
                shr(248, calldataload(132)), // dataOffset + 62
                calldataload(shr(240, calldataload(133))) // dataOffset + 62 + 1
            )

            if lt(deadline, timestamp()) {
                // ExpiredTransaction
                mstore(0, 0x931997cf00000000000000000000000000000000000000000000000000000000)
                revert(0, 4)
            }

            mstore(swapData, shr(96, calldataload(72))) // toAddress / dataOffset + 2
            mstore(add(swapData, 32), shr(96, calldataload(92))) // fromAssetAddress / dataOffset + 22
            mstore(add(swapData, 64), shr(96, calldataload(112))) // toAssetAddress / dataOffset + 42
            mstore(add(swapData, 96), deadline)
            mstore(
                add(swapData, 128),
                shr(
                    shr(248, calldataload(135)), // dataOffset + 62 + 3
                    calldataload(shr(240, calldataload(136))) // dataOffset + 62 + 4
                )
            ) // amountOutMin
            mstore(
                add(swapData, 160),
                shr(
                    shr(248, calldataload(138)), // dataOffset + 62 + 6
                    calldataload(shr(240, calldataload(139))) // dataOffset + 62 + 7
                )
            ) // swapFee
            mstore(
                add(swapData, 192),
                shr(
                    shr(248, calldataload(141)), // dataOffset + 62 + 9
                    calldataload(shr(240, calldataload(142))) // dataOffset + 62 + 10
                )
            ) // amountIn
            // calldataload(144) // r
            // calldataload(176) // s
            // shr(248, calldataload(208)) // v
            let hasPermit := gt(shr(248, calldataload(209)), 0) // permit v
            mstore(add(swapData, 224), hasPermit) // hasPermit
            // calldataload(210) // permit r
            // calldataload(242) // permit s
            // calldataload(274) // permit deadline
            switch hasPermit
            case 1 {
                let hasAffiliate := shr(248, calldataload(277))
                mstore(add(swapData, 256), hasAffiliate) // hasAffiliate
                if eq(hasAffiliate, 1) {
                    mstore(add(swapData, 288), shr(96, calldataload(278))) // affiliateAddress
                    mstore(
                        add(swapData, 320),
                        shr(shr(248, calldataload(298)), calldataload(shr(240, calldataload(299))))
                    ) // affiliateFee
                }
            }
            default {
                let hasAffiliate := shr(248, calldataload(210))
                mstore(add(swapData, 256), hasAffiliate) // hasAffiliate
                if eq(hasAffiliate, 1) {
                    mstore(add(swapData, 288), shr(96, calldataload(211))) // affiliateAddress
                    mstore(
                        add(swapData, 320),
                        shr(shr(248, calldataload(231)), calldataload(shr(240, calldataload(232))))
                    ) // affiliateFee
                }
            }
        }
    }

    /// @dev Transfers the required fees for the swap operation from the user's account.
    /// @param swapData The data structure containing the details of the swap operation, including fee information.
    /// @param fromAddress The address of the user from whom the fees will be deducted.
    /// @param swapFeeAddress The address of the swap fee receiver.
    function transferFees(SwapData memory swapData, address fromAddress, address swapFeeAddress) internal {
        if (swapData.swapFee > 0) {
            if (swapData.fromAssetAddress.isNative()) {
                swapData.fromAssetAddress.transfer(swapFeeAddress, swapData.swapFee);
            } else {
                swapData.fromAssetAddress.transferFrom(fromAddress, swapFeeAddress, swapData.swapFee);
            }
        }
        if (swapData.affiliateFee > 0) {
            if (swapData.fromAssetAddress.isNative()) {
                swapData.fromAssetAddress.transfer(swapData.affiliateAddress, swapData.affiliateFee);
            } else {
                swapData.fromAssetAddress.transferFrom(fromAddress, swapData.affiliateAddress, swapData.affiliateFee);
            }
        }
    }

    /// @dev Grants permission for the user's asset to be used in a swap operation.
    /// @param swapData The data structure containing the details of the swap operation.
    /// @param fromAddress The address of the user who is granting permission for their asset to be used.
    function permit(SwapData memory swapData, address fromAddress) internal {
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint256 deadline;
        assembly {
            v := shr(248, calldataload(209))
            r := calldataload(210)
            s := calldataload(242)
            deadline := shr(shr(248, calldataload(274)), calldataload(shr(240, calldataload(275))))
        }

        swapData.fromAssetAddress.permit(
            fromAddress,
            address(this),
            swapData.amountIn + swapData.swapFee + swapData.affiliateFee,
            deadline,
            v,
            r,
            s
        );
    }

    /// @dev Recovers the signer's address from a hashed message and signature components.
    /// @param hash The hash of the message that was signed.
    /// @param r The `r` component of the signature.
    /// @param s The `s` component of the signature.
    /// @param v The `v` component of the signature.
    /// @return signer The address of the signer recovered from the signature.
    function recoverSigner(bytes32 hash, bytes32 r, bytes32 s, uint8 v) private pure returns (address signer) {
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
            revert InvalidSignature();
        }
        if (v != 27 && v != 28) {
            revert InvalidSignature();
        }

        signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            revert InvalidSignature();
        }
    }

    function getDomainSeparator(bytes32 name, bytes32 version) private view returns (bytes32) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }

        return
            keccak256(
                abi.encode(
                    // keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)")
                    0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f,
                    name,
                    version,
                    chainId,
                    address(this)
                )
            );
    }

    /// @dev Verifies the signature for a swap operation.
    /// @param swapData The SwapData struct containing swap details.
    /// @param messagePtr Pointer to the message data in memory.
    /// @param messageLength Length of the message data.
    /// @param useCaller Flag indicating whether to use the caller's address for verification.
    /// @param internalCallersSlot Slot in the internal callers storage for verification.
    /// @return fromAddress The address of the signer / or caller if the signature is valid.
    function verifySignature(
        bytes32 name,
        bytes32 version,
        SwapData memory swapData,
        uint256 messagePtr,
        uint256 messageLength,
        bool useCaller,
        uint8 internalCallersSlot
    ) internal view returns (address fromAddress) {
        bytes32 domainSeparator = getDomainSeparator(name, version);
        bytes32 digest;
        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            mstore(add(messagePtr, 32), address())
            mstore(add(messagePtr, 64), caller())
            mstore(add(messagePtr, 96), mload(swapData))
            mstore(add(messagePtr, 128), mload(add(swapData, 32)))
            mstore(add(messagePtr, 160), mload(add(swapData, 64)))
            mstore(add(messagePtr, 192), mload(add(swapData, 96)))
            mstore(add(messagePtr, 224), mload(add(swapData, 128)))
            mstore(add(messagePtr, 256), mload(add(swapData, 160)))
            mstore(add(messagePtr, 288), mload(add(swapData, 192)))
            // hasAffiliate
            if eq(mload(add(swapData, 256)), 1) {
                mstore(add(messagePtr, 320), mload(add(swapData, 288)))
                mstore(add(messagePtr, 352), mload(add(swapData, 320)))
            }
            let hash := keccak256(messagePtr, messageLength)

            messagePtr := mload(0x40)
            mstore(0x40, add(messagePtr, 66))
            mstore(messagePtr, "\x19\x01")
            mstore(add(messagePtr, 2), domainSeparator)
            mstore(add(messagePtr, 34), hash)
            digest := keccak256(messagePtr, 66)

            r := calldataload(144)
            s := calldataload(176)
            v := shr(248, calldataload(208))
        }
        if (useCaller) {
            address internalCaller = recoverSigner(digest, r, s, v);
            assembly {
                fromAddress := caller()
                mstore(0, internalCaller)
                mstore(0x20, internalCallersSlot)
                if iszero(eq(sload(keccak256(0, 0x40)), 1)) {
                    // InvalidSignature
                    mstore(0, 0x8baa579f00000000000000000000000000000000000000000000000000000000)
                    revert(0, 4)
                }
            }
        } else {
            fromAddress = recoverSigner(digest, r, s, v);
            if (fromAddress == address(this)) {
                revert InvalidSignature();
            }
        }
    }
}
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
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
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
// OpenZeppelin Contracts (last updated v4.8.0) (access/Ownable2Step.sol)

pragma solidity ^0.8.0;

import "./Ownable.sol";

/**
 * @dev Contract module which provides access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership} and {acceptOwnership}.
 *
 * This module is used through inheritance. It will make available all functions
 * from parent (Ownable).
 */
abstract contract Ownable2Step is Ownable {
    address private _pendingOwner;

    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Returns the address of the pending owner.
     */
    function pendingOwner() public view virtual returns (address) {
        return _pendingOwner;
    }

    /**
     * @dev Starts the ownership transfer of the contract to a new account. Replaces the pending transfer if there is one.
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual override onlyOwner {
        _pendingOwner = newOwner;
        emit OwnershipTransferStarted(owner(), newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`) and deletes any pending owner.
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual override {
        delete _pendingOwner;
        super._transferOwnership(newOwner);
    }

    /**
     * @dev The new owner accepts the ownership transfer.
     */
    function acceptOwnership() public virtual {
        address sender = _msgSender();
        require(pendingOwner() == sender, "Ownable2Step: caller is not the new owner");
        _transferOwnership(sender);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
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