// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Ownable2Step} from "openzeppelin-solidity/contracts/access/Ownable2Step.sol";
import {Pausable} from "openzeppelin-solidity/contracts/security/Pausable.sol";
import {Address} from "openzeppelin-solidity/contracts/utils/Address.sol";
import {IMagpieRouterV3} from "./interfaces/IMagpieRouterV3.sol";
import {LibAsset} from "./libraries/LibAsset.sol";
import {LibRouter, SwapData} from "./libraries/LibRouter.sol";

error ExpiredTransaction();
error InsufficientAmountOut();
error InvalidCall();
error InvalidCommand();
error InvalidTransferFromCall();
error ApprovalFailed();
error TransferFromFailed();
error TransferFailed();
error UniswapV3InvalidAmount();
error InvalidCaller();
error InvalidAmountIn();
error InvalidSignature();
error InvalidOutput();
error InvalidNativeAmount();

enum CommandAction {
    Call, // Represents a generic call to a function within a contract.
    Approval, // Represents an approval operation.
    TransferFrom, // Indicates a transfer-from operation.
    Transfer, // Represents a direct transfer operation.
    Wrap, // This action is used for wrapping native tokens.
    Unwrap, // This action is used for unwrapping native tokens.
    Balance, // Checks the balance of an account or contract for a specific asset.
    Math,
    Comparison,
    EstimateGasStart,
    EstimateGasEnd
}

contract MagpieRouterV3 is IMagpieRouterV3, Ownable2Step, Pausable {
    using LibAsset for address;

    mapping(address => bool) public internalCaller;
    mapping(address => bool) public bridge;
    address public swapFeeAddress;

    /// @dev Restricts swap functions with signatures to only be called by whitelisted internal caller.
    modifier onlyInternalCaller() {
        if (!internalCaller[msg.sender]) {
            revert InvalidCaller();
        }
        _;
    }

    /// @dev Restricts swap functions with signatures to be called only by bridge.
    modifier onlyBridge() {
        if (!bridge[msg.sender]) {
            revert InvalidCaller();
        }
        _;
    }

    /// @dev See {IMagpieRouterV3-updateInternalCaller}
    function updateInternalCaller(address caller, bool value) external onlyOwner {
        internalCaller[caller] = value;

        emit UpdateInternalCaller(msg.sender, caller, value);
    }

    /// @dev See {IMagpieRouterV3-updateBridge}
    function updateBridge(address caller, bool value) external onlyOwner {
        bridge[caller] = value;

        emit UpdateBridge(msg.sender, caller, value);
    }

    /// @dev See {IMagpieRouterV3-updateSwapFeeAddress}
    function updateSwapFeeAddress(address value) external onlyOwner {
        swapFeeAddress = value;
    }

    /// @dev See {IMagpieRouterV3-pause}
    function pause() public onlyOwner whenNotPaused {
        _pause();
    }

    /// @dev See {IMagpieRouterV3-unpause}
    function unpause() public onlyOwner whenPaused {
        _unpause();
    }

    /// @dev See {IMagpieRouterV3-multicall}
    function multicall(bytes[] calldata data) external onlyOwner returns (bytes[] memory results) {
        results = new bytes[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            results[i] = Address.functionDelegateCall(address(this), data[i]);
        }
        return results;
    }

    /// @dev Handle uniswapV3SwapCallback requests from any protocol that is based on UniswapV3. We dont check for factory since this contract is not supposed to store tokens. We protect the user by handling amountOutMin check at the end of execution by comparing starting and final balance at the destination address.
    fallback() external {
        int256 amount0Delta;
        int256 amount1Delta;
        address assetIn;
        uint256 callDataSize;
        assembly {
            amount0Delta := calldataload(4)
            amount1Delta := calldataload(36)
            assetIn := shr(96, calldataload(132))
            callDataSize := calldatasize()
        }

        if (callDataSize != 164) {
            revert InvalidCall();
        }

        if (amount0Delta <= 0 && amount1Delta <= 0) {
            revert UniswapV3InvalidAmount();
        }

        uint256 amount = amount0Delta > 0 ? uint256(amount0Delta) : uint256(amount1Delta);

        assetIn.transfer(msg.sender, amount);
    }

    /// @dev Retrieves the address to be used for a swap operation.
    /// @param swapData The data structure containing information about the swap.
    /// @param useCaller Boolean indicating whether to use the caller's address.
    /// @param checkSignature Boolean indicating whether to validate the signature.
    /// @return fromAddress The address to be used for the swap operation.
    function getFromAddress(
        SwapData memory swapData,
        bool useCaller,
        bool checkSignature
    ) private view returns (address fromAddress) {
        if (checkSignature) {
            bool hasAffiliate = swapData.hasAffiliate;
            uint256 messagePtr;
            uint256 messageLength = hasAffiliate ? 384 : 320;
            assembly {
                messagePtr := mload(0x40)
                mstore(0x40, add(messagePtr, messageLength))
                switch hasAffiliate
                case 1 {
                    // keccak256("Swap(address router,address sender,address recipient,address fromAsset,address toAsset,uint256 deadline,uint256 amountOutMin,uint256 swapFee,uint256 amountIn,address affiliate,uint256 affiliateFee)")
                    mstore(messagePtr, 0x64d67eff2ff010acba1b1df82fb327ba0dc6d2965ba6b0b472bc14c494c8b4f6)
                }
                default {
                    // keccak256("Swap(address router,address sender,address recipient,address fromAsset,address toAsset,uint256 deadline,uint256 amountOutMin,uint256 swapFee,uint256 amountIn)")
                    mstore(messagePtr, 0x783528850c43ab6adcc3a843186a6558aa806707dd0abb3d2909a2a70b7f22a3)
                }
            }
            fromAddress = LibRouter.verifySignature(
                // keccak256(bytes("Magpie Router")),
                0x86af987965544521ef5b52deabbeb812d3353977e11a2dbe7e0f4905d1e60721,
                // keccak256(bytes("3")),
                0x2a80e1ef1d7842f27f2e6be0972bb708b9a135c38860dbe73c27c3486c34f4de,
                swapData,
                messagePtr,
                messageLength,
                useCaller,
                2
            );
        } else {
            if (useCaller) {
                fromAddress = msg.sender;
            } else {
                revert InvalidCall();
            }
        }
    }

    /// @dev Swaps tokens based on the provided swap data.
    /// @param swapData The data structure containing information about the swap operation.
    /// @param fromAddress The address initiating the swap. This address is responsible for the input assets.
    /// @param fullAmountIn The full amount that was used for the operation. If its 0 then event wont be emited.
    /// @return amountOut The amount of tokens or assets received after the swap.
    /// @return gasUsed The amount of gas consumed by the recorded operation.
    function swap(
        SwapData memory swapData,
        address fromAddress,
        uint256 fullAmountIn
    ) private returns (uint256 amountOut, uint256 gasUsed) {
        address fromAssetAddress = swapData.fromAssetAddress;
        address toAssetAddress = swapData.toAssetAddress;
        address toAddress = swapData.toAddress;
        uint256 amountOutMin = swapData.amountOutMin;
        uint256 amountIn = swapData.amountIn;
        uint256 transferFromAmount;

        amountOut = toAssetAddress.getBalanceOf(toAddress);

        (transferFromAmount, gasUsed) = execute(fromAddress, fromAssetAddress);

        amountOut = toAssetAddress.getBalanceOf(toAddress) - amountOut;

        if (amountOut < amountOutMin) {
            revert InsufficientAmountOut();
        }

        if (!fromAssetAddress.isNative() && amountIn != transferFromAmount) {
            revert InvalidAmountIn();
        }

        if (fullAmountIn > 0) {
            emit Swap(fromAddress, toAddress, fromAssetAddress, toAssetAddress, fullAmountIn, amountOut);
        }
    }

    /// @dev See {IMagpieRouterV3-estimateSwapGas}
    function estimateSwapGas(
        bytes calldata
    ) external payable whenNotPaused returns (uint256 amountOut, uint256 gasUsed) {
        SwapData memory swapData = LibRouter.getData();
        address fromAddress = getFromAddress(swapData, true, true);
        if (swapData.hasPermit) {
            LibRouter.permit(swapData, fromAddress);
        }
        LibRouter.transferFees(swapData, fromAddress, swapData.swapFee == 0 ? address(0) : swapFeeAddress);
        (amountOut, gasUsed) = swap(
            swapData,
            fromAddress,
            swapData.amountIn + swapData.swapFee + swapData.affiliateFee
        );
    }

    /// @dev See {IMagpieRouterV3-swapWithMagpieSignature}
    function swapWithMagpieSignature(bytes calldata) external payable whenNotPaused returns (uint256 amountOut) {
        SwapData memory swapData = LibRouter.getData();
        address fromAddress = getFromAddress(swapData, true, true);
        if (swapData.hasPermit) {
            LibRouter.permit(swapData, fromAddress);
        }
        LibRouter.transferFees(swapData, fromAddress, swapData.swapFee == 0 ? address(0) : swapFeeAddress);
        (amountOut, ) = swap(swapData, fromAddress, swapData.amountIn + swapData.swapFee + swapData.affiliateFee);
    }

    /// @dev See {IMagpieRouterV3-swapWithUserSignature}
    function swapWithUserSignature(bytes calldata) external payable onlyInternalCaller returns (uint256 amountOut) {
        SwapData memory swapData = LibRouter.getData();
        if (msg.value > 0) {
            revert InvalidNativeAmount();
        }
        address fromAddress = getFromAddress(swapData, false, true);
        if (swapData.hasPermit) {
            LibRouter.permit(swapData, fromAddress);
        }
        LibRouter.transferFees(swapData, fromAddress, swapData.swapFee == 0 ? address(0) : swapFeeAddress);
        (amountOut, ) = swap(swapData, fromAddress, swapData.amountIn + swapData.swapFee + swapData.affiliateFee);
    }

    /// @dev See {IMagpieRouterV3-swapWithoutSignature}
    function swapWithoutSignature(bytes calldata) external payable onlyBridge returns (uint256 amountOut) {
        SwapData memory swapData = LibRouter.getData();
        address fromAddress = getFromAddress(swapData, true, false);
        (amountOut, ) = swap(swapData, fromAddress, 0);
    }

    /// @dev Prepares CommandData for command iteration.
    function getCommandData()
        private
        pure
        returns (uint16 commandsOffset, uint16 commandsOffsetEnd, uint16 outputsLength)
    {
        assembly {
            commandsOffset := add(70, shr(240, calldataload(68))) // dataOffset + dataLength
            commandsOffsetEnd := add(68, calldataload(36)) // commandsOffsetEnd / swapArgsOffset + swapArgsLength (swapArgsOffset - 32)
            outputsLength := shr(240, calldataload(70)) // dataOffset + 32
        }
    }

    /// @dev Handles the execution of a sequence of commands for the swap operation.
    /// @param fromAddress The address from which the assets will be swapped.
    /// @param fromAssetAddress The address of the asset to be swapped.
    /// @return transferFromAmount The amount transferred from the specified address.
    /// @return gasUsed The amount of gas used during the execution of the swap.
    function execute(
        address fromAddress,
        address fromAssetAddress
    ) private returns (uint256 transferFromAmount, uint256 gasUsed) {
        (uint16 commandsOffset, uint16 commandsOffsetEnd, uint16 outputsLength) = getCommandData();

        uint256 outputPtr;
        assembly {
            outputPtr := mload(0x40)
            mstore(0x40, add(outputPtr, outputsLength))
        }

        uint256 outputOffsetPtr = outputPtr;

        unchecked {
            for (uint256 i = commandsOffset; i < commandsOffsetEnd; ) {
                (transferFromAmount, gasUsed, outputOffsetPtr) = executeCommand(
                    i,
                    fromAddress,
                    fromAssetAddress,
                    outputPtr,
                    outputOffsetPtr,
                    transferFromAmount,
                    gasUsed
                );
                i += 9;
            }
        }

        if (outputOffsetPtr > outputPtr + outputsLength) {
            revert InvalidOutput();
        }
    }

    /// @dev Builds the input for a specific command.
    /// @param i Command data position.
    /// @param outputPtr Memory pointer of the currently available output.
    /// @return input Calculated input data.
    /// @return nativeAmount Native token amount.
    function getInput(uint256 i, uint256 outputPtr) private view returns (bytes memory input, uint256 nativeAmount) {
        assembly {
            let sequencesPositionEnd := shr(240, calldataload(add(i, 5)))

            input := mload(0x40)
            nativeAmount := 0

            let j := shr(240, calldataload(add(i, 3))) // sequencesPosition
            let inputOffsetPtr := add(input, 32)

            for {

            } lt(j, sequencesPositionEnd) {

            } {
                let sequenceType := shr(248, calldataload(j))

                switch sequenceType
                // NativeAmount
                case 0 {
                    switch shr(240, calldataload(add(j, 3)))
                    case 1 {
                        nativeAmount := mload(add(outputPtr, shr(240, calldataload(add(j, 1)))))
                    }
                    default {
                        let p := shr(240, calldataload(add(j, 1)))
                        nativeAmount := shr(shr(248, calldataload(p)), calldataload(add(p, 1)))
                    }
                    j := add(j, 5)
                }
                // Selector
                case 1 {
                    mstore(inputOffsetPtr, calldataload(shr(240, calldataload(add(j, 1)))))
                    inputOffsetPtr := add(inputOffsetPtr, 4)
                    j := add(j, 3)
                }
                // Address
                case 2 {
                    mstore(inputOffsetPtr, shr(96, calldataload(shr(240, calldataload(add(j, 1))))))
                    inputOffsetPtr := add(inputOffsetPtr, 32)
                    j := add(j, 3)
                }
                // Amount
                case 3 {
                    let p := shr(240, calldataload(add(j, 1)))
                    mstore(inputOffsetPtr, shr(shr(248, calldataload(p)), calldataload(add(p, 1))))
                    inputOffsetPtr := add(inputOffsetPtr, 32)
                    j := add(j, 3)
                }
                // Data
                case 4 {
                    let l := shr(240, calldataload(add(j, 3)))
                    calldatacopy(inputOffsetPtr, shr(240, calldataload(add(j, 1))), l)
                    inputOffsetPtr := add(inputOffsetPtr, l)
                    j := add(j, 5)
                }
                // CommandOutput
                case 5 {
                    mstore(inputOffsetPtr, mload(add(outputPtr, shr(240, calldataload(add(j, 1))))))
                    inputOffsetPtr := add(inputOffsetPtr, 32)
                    j := add(j, 3)
                }
                // RouterAddress
                case 6 {
                    mstore(inputOffsetPtr, address())
                    inputOffsetPtr := add(inputOffsetPtr, 32)
                    j := add(j, 1)
                }
                // SenderAddress
                case 7 {
                    mstore(inputOffsetPtr, caller())
                    inputOffsetPtr := add(inputOffsetPtr, 32)
                    j := add(j, 1)
                }
                default {
                    // InvalidSequenceType
                    mstore(0, 0xa90b6fde00000000000000000000000000000000000000000000000000000000)
                    revert(0, 4)
                }
            }

            mstore(input, sub(inputOffsetPtr, add(input, 32)))
            mstore(0x40, inputOffsetPtr)
        }
    }

    /// @dev Executes a command call with the given parameters.
    /// @param i The command data position.
    /// @param outputPtr The pointer to the output location in memory.
    /// @param outputOffsetPtr The pointer to the offset of the output in memory.
    /// @return New outputOffsetPtr position.
    function executeCommandCall(uint256 i, uint256 outputPtr, uint256 outputOffsetPtr) private returns (uint256) {
        bytes memory input;
        uint256 nativeAmount;
        (input, nativeAmount) = getInput(i, outputPtr);
        uint256 outputLength;
        assembly {
            outputLength := shr(240, calldataload(add(i, 1)))

            switch shr(224, mload(add(input, 32))) // selector
            case 0 {
                // InvalidSelector
                mstore(0, 0x7352d91c00000000000000000000000000000000000000000000000000000000)
                revert(0, 4)
            }
            case 0x23b872dd {
                // Blacklist transferFrom in custom calls
                // InvalidTransferFromCall
                mstore(0, 0x1751a8e400000000000000000000000000000000000000000000000000000000)
                revert(0, 4)
            }
            default {
                let targetAddress := shr(96, calldataload(shr(240, calldataload(add(i, 7))))) // targetPosition
                if eq(targetAddress, address()) {
                    // InvalidCall
                    mstore(0, 0xae962d4e00000000000000000000000000000000000000000000000000000000)
                    revert(0, 4)
                }
                if iszero(
                    call(
                        gas(),
                        targetAddress,
                        nativeAmount,
                        add(input, 32),
                        mload(input),
                        outputOffsetPtr,
                        outputLength
                    )
                ) {
                    returndatacopy(0, 0, returndatasize())
                    revert(0, returndatasize())
                }
            }
        }
        outputOffsetPtr += outputLength;

        return outputOffsetPtr;
    }

    /// @dev Executes a command approval with the given parameters.
    /// @param i The command data position.
    /// @param outputPtr The pointer to the output location in memory.
    function executeCommandApproval(uint256 i, uint256 outputPtr) private {
        (bytes memory input, ) = getInput(i, outputPtr);

        address self;
        address spender;
        uint256 amount;
        assembly {
            self := mload(add(input, 32))
            spender := mload(add(input, 64))
            amount := mload(add(input, 96))
        }
        self.approve(spender, amount);
    }

    /// @dev Executes a transfer command from a specific address and asset.
    /// @param i The command position.
    /// @param outputPtr The pointer to the output location in memory.
    /// @param fromAssetAddress The address of the asset to transfer from.
    /// @param fromAddress The address to transfer the asset from.
    /// @param transferFromAmount The accumulated amount of the asset to transfer.
    /// @return Accumulated transfer amount.
    function executeCommandTransferFrom(
        uint256 i,
        uint256 outputPtr,
        address fromAssetAddress,
        address fromAddress,
        uint256 transferFromAmount
    ) private returns (uint256) {
        (bytes memory input, ) = getInput(i, outputPtr);

        uint256 amount;
        assembly {
            amount := mload(add(input, 64))
        }
        if (amount > 0) {
            address to;
            assembly {
                to := mload(add(input, 32))
            }
            fromAssetAddress.transferFrom(fromAddress, to, amount);
            transferFromAmount += amount;
        }

        return transferFromAmount;
    }

    /// @dev Executes a transfer command with the given parameters.
    /// @param i The command data position.
    /// @param outputPtr The pointer to the output location in memory.
    function executeCommandTransfer(uint256 i, uint256 outputPtr) private {
        (bytes memory input, ) = getInput(i, outputPtr);

        uint256 amount;
        assembly {
            amount := mload(add(input, 96))
        }
        if (amount > 0) {
            address self;
            address recipient;
            assembly {
                self := mload(add(input, 32))
                recipient := mload(add(input, 64))
            }
            self.transfer(recipient, amount);
        }
    }

    /// @dev Executes a wrap command with the given parameters.
    /// @param i The command data position.
    /// @param outputPtr The pointer to the output location in memory.
    function executeCommandWrap(uint256 i, uint256 outputPtr) private {
        (bytes memory input, ) = getInput(i, outputPtr);

        address self;
        uint256 amount;
        assembly {
            self := mload(add(input, 32))
            amount := mload(add(input, 64))
        }
        self.wrap(amount);
    }

    /// @dev Executes an unwrap command with the given parameters.
    /// @param i The command data position.
    /// @param outputPtr The pointer to the output location in memory.
    function executeCommandUnwrap(uint256 i, uint256 outputPtr) private {
        (bytes memory input, ) = getInput(i, outputPtr);

        address self;
        uint256 amount;
        assembly {
            self := mload(add(input, 32))
            amount := mload(add(input, 64))
        }
        self.unwrap(amount);
    }

    /// @dev Executes a balance command and returns the resulting balance.
    /// @param i The command data position.
    /// @param outputPtr The pointer to the output location in memory.
    /// @param outputOffsetPtr The pointer to the offset of the output in memory.
    /// @return New outputOffsetPtr position.
    function executeCommandBalance(
        uint256 i,
        uint256 outputPtr,
        uint256 outputOffsetPtr
    ) private view returns (uint256) {
        (bytes memory input, ) = getInput(i, outputPtr);

        address self;
        uint256 amount;
        assembly {
            self := mload(add(input, 32))
        }

        amount = self.getBalance();

        assembly {
            mstore(outputOffsetPtr, amount)
        }

        outputOffsetPtr += 32;

        return outputOffsetPtr;
    }

    /// @dev Executes a mathematical command.
    /// @param i The command data position.
    /// @param outputPtr The pointer to the output location in memory.
    /// @param outputOffsetPtr The pointer to the offset of the output in memory.
    /// @return New outputOffsetPtr position.
    function executeCommandMath(uint256 i, uint256 outputPtr, uint256 outputOffsetPtr) private view returns (uint256) {
        (bytes memory input, ) = getInput(i, outputPtr);

        assembly {
            function math(currentInputPtr) -> amount {
                let currentOutputPtr := mload(0x40)
                let j := 0
                let amount0 := 0
                let amount1 := 0
                let operator := 0

                for {

                } lt(j, 10) {

                } {
                    let pos := add(currentInputPtr, mul(j, 3))
                    let amount0Index := shr(248, mload(add(pos, 1)))
                    switch lt(amount0Index, 10)
                    case 1 {
                        amount0 := mload(add(currentOutputPtr, mul(amount0Index, 32)))
                    }
                    default {
                        amount0Index := sub(amount0Index, 10)
                        amount0 := mload(add(add(currentInputPtr, 32), mul(amount0Index, 32)))
                    }
                    let amount1Index := shr(248, mload(add(pos, 2)))
                    switch lt(amount1Index, 10)
                    case 1 {
                        amount1 := mload(add(currentOutputPtr, mul(amount1Index, 32)))
                    }
                    default {
                        amount1Index := sub(amount1Index, 10)
                        amount1 := mload(add(add(currentInputPtr, 32), mul(amount1Index, 32)))
                    }
                    operator := shr(248, mload(pos))

                    switch operator
                    // None
                    case 0 {
                        let finalPtr := add(currentOutputPtr, mul(sub(j, 1), 32))
                        amount := mload(finalPtr)
                        mstore(0x40, add(finalPtr, 32))
                        leave
                    }
                    // Add
                    case 1 {
                        mstore(add(currentOutputPtr, mul(j, 32)), add(amount0, amount1))
                    }
                    // Sub
                    case 2 {
                        mstore(add(currentOutputPtr, mul(j, 32)), sub(amount0, amount1))
                    }
                    // Mul
                    case 3 {
                        mstore(add(currentOutputPtr, mul(j, 32)), mul(amount0, amount1))
                    }
                    // Div
                    case 4 {
                        mstore(add(currentOutputPtr, mul(j, 32)), div(amount0, amount1))
                    }
                    // Pow
                    case 5 {
                        mstore(add(currentOutputPtr, mul(j, 32)), exp(amount0, amount1))
                    }
                    // Abs128
                    case 6 {
                        if gt(amount0, 170141183460469231731687303715884105727) {
                            let mask := sar(127, amount0)
                            amount0 := xor(amount0, mask)
                            amount0 := sub(amount0, mask)
                        }
                        mstore(add(currentOutputPtr, mul(j, 32)), amount0)
                    }
                    // Abs256
                    case 7 {
                        if gt(amount0, 57896044618658097711785492504343953926634992332820282019728792003956564819967) {
                            let mask := sar(255, amount0)
                            amount0 := xor(amount0, mask)
                            amount0 := sub(amount0, mask)
                        }
                        mstore(add(currentOutputPtr, mul(j, 32)), amount0)
                    }
                    // Shr
                    case 8 {
                        mstore(add(currentOutputPtr, mul(j, 32)), shr(amount0, amount1))
                    }
                    // Shl
                    case 9 {
                        mstore(add(currentOutputPtr, mul(j, 32)), shl(amount0, amount1))
                    }

                    j := add(j, 1)
                }

                let finalPtr := add(currentOutputPtr, mul(9, 32))
                amount := mload(finalPtr)
                mstore(0x40, add(finalPtr, 32))
            }

            mstore(outputOffsetPtr, math(add(input, 32)))
        }

        outputOffsetPtr += 32;

        return outputOffsetPtr;
    }

    /// @dev Executes a comparison command.
    /// @param i The command data position.
    /// @param outputPtr The pointer to the output location in memory.
    /// @param outputOffsetPtr The pointer to the offset of the output in memory.
    /// @return New outputOffsetPtr position.
    function executeCommandComparison(
        uint256 i,
        uint256 outputPtr,
        uint256 outputOffsetPtr
    ) private view returns (uint256) {
        (bytes memory input, ) = getInput(i, outputPtr);

        assembly {
            function comparison(currentInputPtr) -> amount {
                let currentOutputPtr := mload(0x40)
                let j := 0
                let amount0 := 0
                let amount1 := 0
                let amount2 := 0
                let amount3 := 0
                let operator := 0

                for {

                } lt(j, 6) {

                } {
                    let pos := add(currentInputPtr, mul(j, 5))
                    let amount0Index := shr(248, mload(add(pos, 1)))
                    switch lt(amount0Index, 6)
                    case 1 {
                        amount0 := mload(add(currentOutputPtr, mul(amount0Index, 32)))
                    }
                    default {
                        amount0Index := sub(amount0Index, 6)
                        amount0 := mload(add(add(currentInputPtr, 32), mul(amount0Index, 32)))
                    }
                    let amount1Index := shr(248, mload(add(pos, 2)))
                    switch lt(amount1Index, 6)
                    case 1 {
                        amount1 := mload(add(currentOutputPtr, mul(amount1Index, 32)))
                    }
                    default {
                        amount1Index := sub(amount1Index, 6)
                        amount1 := mload(add(add(currentInputPtr, 32), mul(amount1Index, 32)))
                    }
                    let amount2Index := shr(248, mload(add(pos, 3)))
                    switch lt(amount2Index, 6)
                    case 1 {
                        amount2 := mload(add(currentOutputPtr, mul(amount2Index, 32)))
                    }
                    default {
                        amount2Index := sub(amount2Index, 6)
                        amount2 := mload(add(add(currentInputPtr, 32), mul(amount2Index, 32)))
                    }
                    let amount3Index := shr(248, mload(add(pos, 4)))
                    switch lt(amount3Index, 6)
                    case 1 {
                        amount3 := mload(add(currentOutputPtr, mul(amount3Index, 32)))
                    }
                    default {
                        amount3Index := sub(amount3Index, 6)
                        amount3 := mload(add(add(currentInputPtr, 32), mul(amount3Index, 32)))
                    }
                    operator := shr(248, mload(pos))

                    switch operator
                    // None
                    case 0 {
                        let finalPtr := add(currentOutputPtr, mul(sub(j, 1), 32))
                        amount := mload(finalPtr)
                        mstore(0x40, add(finalPtr, 32))
                        leave
                    }
                    // Lt
                    case 1 {
                        switch lt(amount0, amount1)
                        case 1 {
                            mstore(add(currentOutputPtr, mul(j, 32)), amount2)
                        }
                        default {
                            mstore(add(currentOutputPtr, mul(j, 32)), amount3)
                        }
                    }
                    // Lte
                    case 2 {
                        switch or(lt(amount0, amount1), eq(amount0, amount1))
                        case 1 {
                            mstore(add(currentOutputPtr, mul(j, 32)), amount2)
                        }
                        default {
                            mstore(add(currentOutputPtr, mul(j, 32)), amount3)
                        }
                    }
                    // Gt
                    case 3 {
                        switch gt(amount0, amount1)
                        case 1 {
                            mstore(add(currentOutputPtr, mul(j, 32)), amount2)
                        }
                        default {
                            mstore(add(currentOutputPtr, mul(j, 32)), amount3)
                        }
                    }
                    // Gte
                    case 4 {
                        switch or(gt(amount0, amount1), eq(amount0, amount1))
                        case 1 {
                            mstore(add(currentOutputPtr, mul(j, 32)), amount2)
                        }
                        default {
                            mstore(add(currentOutputPtr, mul(j, 32)), amount3)
                        }
                    }
                    // Eq
                    case 5 {
                        switch eq(amount0, amount1)
                        case 1 {
                            mstore(add(currentOutputPtr, mul(j, 32)), amount2)
                        }
                        default {
                            mstore(add(currentOutputPtr, mul(j, 32)), amount3)
                        }
                    }
                    // Ne
                    case 6 {
                        switch eq(amount0, amount1)
                        case 1 {
                            mstore(add(currentOutputPtr, mul(j, 32)), amount3)
                        }
                        default {
                            mstore(add(currentOutputPtr, mul(j, 32)), amount2)
                        }
                    }

                    j := add(j, 1)
                }

                let finalPtr := add(currentOutputPtr, mul(5, 32))
                amount := mload(finalPtr)
                mstore(0x40, add(finalPtr, 32))
            }

            mstore(outputOffsetPtr, comparison(add(input, 32)))
        }

        outputOffsetPtr += 32;

        return outputOffsetPtr;
    }

    /// @dev Handles the execution of the specified command commands for the swap operation.
    /// @param i The command data position.
    /// @param fromAddress The wallet / contract of the fromAssetAddress.
    /// @param fromAssetAddress The asset will be transfered from the user.
    /// @param outputPtr Starting position of the output memory pointer.
    /// @param outputOffsetPtr Current position of the output memory pointer.
    /// @param transferFromAmount Accumulated transferred amount.
    /// @param gasUsed Recorded gas between commands.
    function executeCommand(
        uint256 i,
        address fromAddress,
        address fromAssetAddress,
        uint256 outputPtr,
        uint256 outputOffsetPtr,
        uint256 transferFromAmount,
        uint256 gasUsed
    ) private returns (uint256, uint256, uint256) {
        CommandAction commandAction;
        assembly {
            commandAction := shr(248, calldataload(i))
        }

        if (commandAction == CommandAction.Call) {
            outputOffsetPtr = executeCommandCall(i, outputPtr, outputOffsetPtr);
        } else if (commandAction == CommandAction.Approval) {
            executeCommandApproval(i, outputPtr);
        } else if (commandAction == CommandAction.TransferFrom) {
            transferFromAmount = executeCommandTransferFrom(
                i,
                outputPtr,
                fromAssetAddress,
                fromAddress,
                transferFromAmount
            );
        } else if (commandAction == CommandAction.Transfer) {
            executeCommandTransfer(i, outputPtr);
        } else if (commandAction == CommandAction.Wrap) {
            executeCommandWrap(i, outputPtr);
        } else if (commandAction == CommandAction.Unwrap) {
            executeCommandUnwrap(i, outputPtr);
        } else if (commandAction == CommandAction.Balance) {
            outputOffsetPtr = executeCommandBalance(i, outputPtr, outputOffsetPtr);
        } else if (commandAction == CommandAction.Math) {
            outputOffsetPtr = executeCommandMath(i, outputPtr, outputOffsetPtr);
        } else if (commandAction == CommandAction.Comparison) {
            outputOffsetPtr = executeCommandComparison(i, outputPtr, outputOffsetPtr);
        } else if (commandAction == CommandAction.EstimateGasStart) {
            gasUsed = gasleft();
        } else if (commandAction == CommandAction.EstimateGasEnd) {
            gasUsed -= gasleft();
        } else {
            revert InvalidCommand();
        }

        return (transferFromAmount, gasUsed, outputOffsetPtr);
    }

    /// @dev Used to receive ethers
    receive() external payable {}
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

interface IWETH {
    function deposit() external payable;

    function transfer(address to, uint256 value) external returns (bool);

    function withdraw(uint256) external;
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