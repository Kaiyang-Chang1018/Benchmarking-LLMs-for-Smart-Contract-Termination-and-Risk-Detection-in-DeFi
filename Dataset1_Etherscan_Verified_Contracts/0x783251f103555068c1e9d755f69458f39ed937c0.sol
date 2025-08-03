// SPDX-License-Identifier: BSD
pragma solidity ^0.8.4;

/// @title Clone
/// @author zefram.eth
/// @notice Provides helper functions for reading immutable args from calldata
contract Clone {
    /// @notice Reads an immutable arg with type address
    /// @param argOffset The offset of the arg in the packed data
    /// @return arg The arg value
    function _getArgAddress(uint256 argOffset)
        internal
        pure
        returns (address arg)
    {
        uint256 offset = _getImmutableArgsOffset();
        assembly {
            arg := shr(0x60, calldataload(add(offset, argOffset)))
        }
    }

    /// @notice Reads an immutable arg with type uint256
    /// @param argOffset The offset of the arg in the packed data
    /// @return arg The arg value
    function _getArgUint256(uint256 argOffset)
        internal
        pure
        returns (uint256 arg)
    {
        uint256 offset = _getImmutableArgsOffset();
        // solhint-disable-next-line no-inline-assembly
        assembly {
            arg := calldataload(add(offset, argOffset))
        }
    }

    /// @notice Reads an immutable arg with type uint64
    /// @param argOffset The offset of the arg in the packed data
    /// @return arg The arg value
    function _getArgUint64(uint256 argOffset)
        internal
        pure
        returns (uint64 arg)
    {
        uint256 offset = _getImmutableArgsOffset();
        // solhint-disable-next-line no-inline-assembly
        assembly {
            arg := shr(0xc0, calldataload(add(offset, argOffset)))
        }
    }

    /// @notice Reads an immutable arg with type uint8
    /// @param argOffset The offset of the arg in the packed data
    /// @return arg The arg value
    function _getArgUint8(uint256 argOffset) internal pure returns (uint8 arg) {
        uint256 offset = _getImmutableArgsOffset();
        // solhint-disable-next-line no-inline-assembly
        assembly {
            arg := shr(0xf8, calldataload(add(offset, argOffset)))
        }
    }

    /// @return offset The offset of the packed immutable args in calldata
    function _getImmutableArgsOffset() internal pure returns (uint256 offset) {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            offset := sub(
                calldatasize(),
                add(shr(240, calldataload(sub(calldatasize(), 2))), 2)
            )
        }
    }
}
// SPDX-License-Identifier: BSD

pragma solidity ^0.8.4;

/// @title ClonesWithImmutableArgs
/// @author wighawag, zefram.eth
/// @notice Enables creating clone contracts with immutable args
library ClonesWithImmutableArgs {
    error CreateFail();

    /// @notice Creates a clone proxy of the implementation contract, with immutable args
    /// @dev data cannot exceed 65535 bytes, since 2 bytes are used to store the data length
    /// @param implementation The implementation contract to clone
    /// @param data Encoded immutable args
    /// @return instance The address of the created clone
    function clone(address implementation, bytes memory data)
        internal
        returns (address instance)
    {
        // unrealistic for memory ptr or data length to exceed 256 bits
        unchecked {
            uint256 extraLength = data.length + 2; // +2 bytes for telling how much data there is appended to the call
            uint256 creationSize = 0x43 + extraLength;
            uint256 runSize = creationSize - 11;
            uint256 dataPtr;
            uint256 ptr;
            // solhint-disable-next-line no-inline-assembly
            assembly {
                ptr := mload(0x40)

                // -------------------------------------------------------------------------------------------------------------
                // CREATION (11 bytes)
                // -------------------------------------------------------------------------------------------------------------

                // 3d          | RETURNDATASIZE        | 0                       | –
                // 61 runtime  | PUSH2 runtime (r)     | r 0                     | –
                mstore(
                    ptr,
                    0x3d61000000000000000000000000000000000000000000000000000000000000
                )
                mstore(add(ptr, 0x02), shl(240, runSize)) // size of the contract running bytecode (16 bits)

                // creation size = 0b
                // 80          | DUP1                  | r r 0                   | –
                // 60 creation | PUSH1 creation (c)    | c r r 0                 | –
                // 3d          | RETURNDATASIZE        | 0 c r r 0               | –
                // 39          | CODECOPY              | r 0                     | [0-2d]: runtime code
                // 81          | DUP2                  | 0 c  0                  | [0-2d]: runtime code
                // f3          | RETURN                | 0                       | [0-2d]: runtime code
                mstore(
                    add(ptr, 0x04),
                    0x80600b3d3981f300000000000000000000000000000000000000000000000000
                )

                // -------------------------------------------------------------------------------------------------------------
                // RUNTIME
                // -------------------------------------------------------------------------------------------------------------

                // 36          | CALLDATASIZE          | cds                     | –
                // 3d          | RETURNDATASIZE        | 0 cds                   | –
                // 3d          | RETURNDATASIZE        | 0 0 cds                 | –
                // 37          | CALLDATACOPY          | –                       | [0, cds] = calldata
                // 61          | PUSH2 extra           | extra                   | [0, cds] = calldata
                mstore(
                    add(ptr, 0x0b),
                    0x363d3d3761000000000000000000000000000000000000000000000000000000
                )
                mstore(add(ptr, 0x10), shl(240, extraLength))

                // 60 0x38     | PUSH1 0x38            | 0x38 extra              | [0, cds] = calldata // 0x38 (56) is runtime size - data
                // 36          | CALLDATASIZE          | cds 0x38 extra          | [0, cds] = calldata
                // 39          | CODECOPY              | _                       | [0, cds] = calldata
                // 3d          | RETURNDATASIZE        | 0                       | [0, cds] = calldata
                // 3d          | RETURNDATASIZE        | 0 0                     | [0, cds] = calldata
                // 3d          | RETURNDATASIZE        | 0 0 0                   | [0, cds] = calldata
                // 36          | CALLDATASIZE          | cds 0 0 0               | [0, cds] = calldata
                // 61 extra    | PUSH2 extra           | extra cds 0 0 0         | [0, cds] = calldata
                mstore(
                    add(ptr, 0x12),
                    0x603836393d3d3d36610000000000000000000000000000000000000000000000
                )
                mstore(add(ptr, 0x1b), shl(240, extraLength))

                // 01          | ADD                   | cds+extra 0 0 0         | [0, cds] = calldata
                // 3d          | RETURNDATASIZE        | 0 cds 0 0 0             | [0, cds] = calldata
                // 73 addr     | PUSH20 0x123…         | addr 0 cds 0 0 0        | [0, cds] = calldata
                mstore(
                    add(ptr, 0x1d),
                    0x013d730000000000000000000000000000000000000000000000000000000000
                )
                mstore(add(ptr, 0x20), shl(0x60, implementation))

                // 5a          | GAS                   | gas addr 0 cds 0 0 0    | [0, cds] = calldata
                // f4          | DELEGATECALL          | success 0               | [0, cds] = calldata
                // 3d          | RETURNDATASIZE        | rds success 0           | [0, cds] = calldata
                // 82          | DUP3                  | 0 rds success 0         | [0, cds] = calldata
                // 80          | DUP1                  | 0 0 rds success 0       | [0, cds] = calldata
                // 3e          | RETURNDATACOPY        | success 0               | [0, rds] = return data (there might be some irrelevant leftovers in memory [rds, cds] when rds < cds)
                // 90          | SWAP1                 | 0 success               | [0, rds] = return data
                // 3d          | RETURNDATASIZE        | rds 0 success           | [0, rds] = return data
                // 91          | SWAP2                 | success 0 rds           | [0, rds] = return data
                // 60 0x36     | PUSH1 0x36            | 0x36 sucess 0 rds       | [0, rds] = return data
                // 57          | JUMPI                 | 0 rds                   | [0, rds] = return data
                // fd          | REVERT                | –                       | [0, rds] = return data
                // 5b          | JUMPDEST              | 0 rds                   | [0, rds] = return data
                // f3          | RETURN                | –                       | [0, rds] = return data

                mstore(
                    add(ptr, 0x34),
                    0x5af43d82803e903d91603657fd5bf30000000000000000000000000000000000
                )
            }

            // -------------------------------------------------------------------------------------------------------------
            // APPENDED DATA (Accessible from extcodecopy)
            // (but also send as appended data to the delegatecall)
            // -------------------------------------------------------------------------------------------------------------

            extraLength -= 2;
            uint256 counter = extraLength;
            uint256 copyPtr = ptr + 0x43;
            // solhint-disable-next-line no-inline-assembly
            assembly {
                dataPtr := add(data, 32)
            }
            for (; counter >= 32; counter -= 32) {
                // solhint-disable-next-line no-inline-assembly
                assembly {
                    mstore(copyPtr, mload(dataPtr))
                }

                copyPtr += 32;
                dataPtr += 32;
            }
            uint256 mask = ~(256**(32 - counter) - 1);
            // solhint-disable-next-line no-inline-assembly
            assembly {
                mstore(copyPtr, and(mload(dataPtr), mask))
            }
            copyPtr += counter;
            // solhint-disable-next-line no-inline-assembly
            assembly {
                mstore(copyPtr, shl(240, extraLength))
            }
            // solhint-disable-next-line no-inline-assembly
            assembly {
                instance := create(0, ptr, creationSize)
            }
            if (instance == address(0)) {
                revert CreateFail();
            }
        }
    }
}
// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.16;

library CommandBuilder {
    uint256 constant IDX_VARIABLE_LENGTH = 0x80;
    uint256 constant IDX_VALUE_MASK = 0x7f;
    uint256 constant IDX_END_OF_ARGS = 0xff;
    uint256 constant IDX_USE_STATE = 0xfe;
    uint256 constant IDX_ARRAY_START = 0xfd;
    uint256 constant IDX_TUPLE_START = 0xfc;
    uint256 constant IDX_DYNAMIC_END = 0xfb;

    function buildInputs(
        bytes[] memory state,
        bytes4 selector,
        bytes32 indices,
        uint256 indicesLength
    ) internal view returns (bytes memory ret) {
        uint256 idx; // The current command index
        uint256 offsetIdx; // The index of the current free offset

        uint256 count; // Number of bytes in whole ABI encoded message
        uint256 free; // Pointer to first free byte in tail part of message
        uint256[] memory dynamicLengths = new uint256[](10); // Optionally store the length of all dynamic types (a command cannot fit more than 10 dynamic types)

        bytes memory stateData; // Optionally encode the current state if the call requires it

        // Determine the length of the encoded data
        for (uint256 i; i < indicesLength; ) {
            idx = uint8(indices[i]);
            if (idx == IDX_END_OF_ARGS) {
                indicesLength = i;
                break;
            }
            if (idx & IDX_VARIABLE_LENGTH != 0) {
                if (idx == IDX_USE_STATE) {
                    if (stateData.length == 0) {
                        stateData = abi.encode(state);
                    }
                    unchecked {
                        count += stateData.length;
                    }
                } else {
                    (dynamicLengths, offsetIdx, count, i) = setupDynamicType(
                        state,
                        indices,
                        dynamicLengths,
                        idx,
                        offsetIdx,
                        count,
                        i
                    );
                }
            } else {
                count = setupStaticVariable(state, count, idx);
            }
            unchecked {
                free += 32;
                ++i;
            }
        }

        // Encode it
        ret = new bytes(count + 4);
        assembly {
            mstore(add(ret, 32), selector)
        }
        offsetIdx = 0;
        // Use count to track current memory slot
        assembly {
            count := add(ret, 36)
        }
        for (uint256 i; i < indicesLength; ) {
            idx = uint8(indices[i]);
            if (idx & IDX_VARIABLE_LENGTH != 0) {
                if (idx == IDX_USE_STATE) {
                    assembly {
                        mstore(count, free)
                    }
                    memcpy(stateData, 32, ret, free + 4, stateData.length - 32);
                    unchecked {
                        free += stateData.length - 32;
                    }
                } else if (idx == IDX_ARRAY_START) {
                    // Start of dynamic type, put pointer in current slot
                    assembly {
                        mstore(count, free)
                    }
                    (offsetIdx, free, i, ) = encodeDynamicArray(
                        ret,
                        state,
                        indices,
                        dynamicLengths,
                        offsetIdx,
                        free,
                        i
                    );
                } else if (idx == IDX_TUPLE_START) {
                    // Start of dynamic type, put pointer in current slot
                    assembly {
                        mstore(count, free)
                    }
                    (offsetIdx, free, i, ) = encodeDynamicTuple(
                        ret,
                        state,
                        indices,
                        dynamicLengths,
                        offsetIdx,
                        free,
                        i
                    );
                } else {
                    // Variable length data
                    uint256 argLen = state[idx & IDX_VALUE_MASK].length;
                    // Put a pointer in the current slot and write the data to first free slot
                    assembly {
                        mstore(count, free)
                    }
                    memcpy(
                        state[idx & IDX_VALUE_MASK],
                        0,
                        ret,
                        free + 4,
                        argLen
                    );
                    unchecked {
                        free += argLen;
                    }
                }
            } else {
                // Fixed length data (length previously checked to be 32 bytes)
                bytes memory stateVar = state[idx & IDX_VALUE_MASK];
                // Write the data to current slot
                assembly {
                    mstore(count, mload(add(stateVar, 32)))
                }
            }
            unchecked {
                count += 32;
                ++i;
            }
        }
    }

    function setupStaticVariable(
        bytes[] memory state,
        uint256 count,
        uint256 idx
    ) internal pure returns (uint256 newCount) {
        require(
            state[idx & IDX_VALUE_MASK].length == 32,
            "Static state variables must be 32 bytes"
        );
        unchecked {
            newCount = count + 32;
        }
    }

    function setupDynamicVariable(
        bytes[] memory state,
        uint256 count,
        uint256 idx
    ) internal pure returns (uint256 newCount) {
        bytes memory arg = state[idx & IDX_VALUE_MASK];
        // Validate the length of the data in state is a multiple of 32
        uint256 argLen = arg.length;
        require(
            argLen != 0 && argLen % 32 == 0,
            "Dynamic state variables must be a multiple of 32 bytes"
        );
        // Add the length of the value, rounded up to the next word boundary, plus space for pointer
        unchecked {
            newCount = count + argLen + 32;
        }
    }

    function setupDynamicType(
        bytes[] memory state,
        bytes32 indices,
        uint256[] memory dynamicLengths,
        uint256 idx,
        uint256 offsetIdx,
        uint256 count,
        uint256 index
    ) internal view returns (
        uint256[] memory newDynamicLengths,
        uint256 newOffsetIdx,
        uint256 newCount,
        uint256 newIndex
    ) {
        if (idx == IDX_ARRAY_START) {
            (newDynamicLengths, newOffsetIdx, newCount, newIndex) = setupDynamicArray(
                state,
                indices,
                dynamicLengths,
                offsetIdx,
                count,
                index
            );
        } else if (idx == IDX_TUPLE_START) {
            (newDynamicLengths, newOffsetIdx, newCount, newIndex) = setupDynamicTuple(
                state,
                indices,
                dynamicLengths,
                offsetIdx,
                count,
                index
            );
        } else {
            newDynamicLengths = dynamicLengths;
            newOffsetIdx = offsetIdx;
            newIndex = index;
            newCount = setupDynamicVariable(state, count, idx);
        }
    }

    function setupDynamicArray(
        bytes[] memory state,
        bytes32 indices,
        uint256[] memory dynamicLengths,
        uint256 offsetIdx,
        uint256 count,
        uint256 index
    ) internal view returns (
        uint256[] memory newDynamicLengths,
        uint256 newOffsetIdx,
        uint256 newCount,
        uint256 newIndex
    ) {
        // Current idx is IDX_ARRAY_START, next idx will contain the array length
        unchecked {
            newIndex = index + 1;
            newCount = count + 32;
        }
        uint256 idx = uint8(indices[newIndex]);
        require(
            state[idx & IDX_VALUE_MASK].length == 32,
            "Array length must be 32 bytes"
        );
        (newDynamicLengths, newOffsetIdx, newCount, newIndex) = setupDynamicTuple(
            state,
            indices,
            dynamicLengths,
            offsetIdx,
            newCount,
            newIndex
        );
    }

    function setupDynamicTuple(
        bytes[] memory state,
        bytes32 indices,
        uint256[] memory dynamicLengths,
        uint256 offsetIdx,
        uint256 count,
        uint256 index
    ) internal view returns (
        uint256[] memory newDynamicLengths,
        uint256 newOffsetIdx,
        uint256 newCount,
        uint256 newIndex
    ) {
        uint256 idx;
        uint256 offset;
        newDynamicLengths = dynamicLengths;
        // Progress to first index of the data and progress the next offset idx
        unchecked {
            newIndex = index + 1;
            newOffsetIdx = offsetIdx + 1;
            newCount = count + 32;
        }
        while (newIndex < 32) {
            idx = uint8(indices[newIndex]);
            if (idx & IDX_VARIABLE_LENGTH != 0) {
                if (idx == IDX_DYNAMIC_END) {
                    newDynamicLengths[offsetIdx] = offset;
                    // explicit return saves gas ¯\_(ツ)_/¯
                    return (newDynamicLengths, newOffsetIdx, newCount, newIndex);
                } else {
                    require(idx != IDX_USE_STATE, "Cannot use state from inside dynamic type");
                    (newDynamicLengths, newOffsetIdx, newCount, newIndex) = setupDynamicType(
                        state,
                        indices,
                        newDynamicLengths,
                        idx,
                        newOffsetIdx,
                        newCount,
                        newIndex
                    );
                }
            } else {
                newCount = setupStaticVariable(state, newCount, idx);
            }
            unchecked {
                offset += 32;
                ++newIndex;
            }
        }
        revert("Dynamic type was not properly closed");
    }

    function encodeDynamicArray(
        bytes memory ret,
        bytes[] memory state,
        bytes32 indices,
        uint256[] memory dynamicLengths,
        uint256 offsetIdx,
        uint256 currentSlot,
        uint256 index
    ) internal view returns (
        uint256 newOffsetIdx,
        uint256 newSlot,
        uint256 newIndex,
        uint256 length
    ) {
        // Progress to array length metadata
        unchecked {
            newIndex = index + 1;
            newSlot = currentSlot + 32;
        }
        // Encode array length
        uint256 idx = uint8(indices[newIndex]);
        // Array length value previously checked to be 32 bytes
        bytes memory stateVar = state[idx & IDX_VALUE_MASK];
        assembly {
            mstore(add(add(ret, 36), currentSlot), mload(add(stateVar, 32)))
        }
        (newOffsetIdx, newSlot, newIndex, length) = encodeDynamicTuple(
            ret,
            state,
            indices,
            dynamicLengths,
            offsetIdx,
            newSlot,
            newIndex
        );
        unchecked {
            length += 32; // Increase length to account for array length metadata
        }
    }

    function encodeDynamicTuple(
        bytes memory ret,
        bytes[] memory state,
        bytes32 indices,
        uint256[] memory dynamicLengths,
        uint256 offsetIdx,
        uint256 currentSlot,
        uint256 index
    ) internal view returns (
        uint256 newOffsetIdx,
        uint256 newSlot,
        uint256 newIndex,
        uint256 length
    ) {
        uint256 idx;
        uint256 argLen;
        uint256 freePointer = dynamicLengths[offsetIdx]; // The pointer to the next free slot
        unchecked {
            newSlot = currentSlot + freePointer; // Update the next slot
            newOffsetIdx = offsetIdx + 1; // Progress to next offsetIdx
            newIndex = index + 1; // Progress to first index of the data
        }
        // Shift currentSlot to correct location in memory
        assembly {
            currentSlot := add(add(ret, 36), currentSlot)
        }
        while (newIndex < 32) {
            idx = uint8(indices[newIndex]);
            if (idx & IDX_VARIABLE_LENGTH != 0) {
                if (idx == IDX_DYNAMIC_END) {
                    break;
                } else if (idx == IDX_ARRAY_START) {
                    // Start of dynamic type, put pointer in current slot
                    assembly {
                        mstore(currentSlot, freePointer)
                    }
                    (newOffsetIdx, newSlot, newIndex, argLen) = encodeDynamicArray(
                        ret,
                        state,
                        indices,
                        dynamicLengths,
                        newOffsetIdx,
                        newSlot,
                        newIndex
                    );
                    unchecked {
                        freePointer += argLen;
                        length += (argLen + 32); // data + pointer
                    }
                } else if (idx == IDX_TUPLE_START) {
                    // Start of dynamic type, put pointer in current slot
                    assembly {
                        mstore(currentSlot, freePointer)
                    }
                    (newOffsetIdx, newSlot, newIndex, argLen) = encodeDynamicTuple(
                        ret,
                        state,
                        indices,
                        dynamicLengths,
                        newOffsetIdx,
                        newSlot,
                        newIndex
                    );
                    unchecked {
                        freePointer += argLen;
                        length += (argLen + 32); // data + pointer
                    }
                } else  {
                    // Variable length data
                    argLen = state[idx & IDX_VALUE_MASK].length;
                    // Start of dynamic type, put pointer in current slot
                    assembly {
                        mstore(currentSlot, freePointer)
                    }
                    memcpy(
                        state[idx & IDX_VALUE_MASK],
                        0,
                        ret,
                        newSlot + 4,
                        argLen
                    );
                    unchecked {
                        newSlot += argLen;
                        freePointer += argLen;
                        length += (argLen + 32); // data + pointer
                    }
                }
            } else {
                // Fixed length data (length previously checked to be 32 bytes)
                bytes memory stateVar = state[idx & IDX_VALUE_MASK];
                // Write to first free slot
                assembly {
                    mstore(currentSlot, mload(add(stateVar, 32)))
                }
                unchecked {
                    length += 32;
                }
            }
            unchecked {
                currentSlot += 32;
                ++newIndex;
            }
        }
    }

    function writeOutputs(
        bytes[] memory state,
        bytes1 index,
        bytes memory output
    ) internal pure returns (bytes[] memory) {
        uint256 idx = uint8(index);
        if (idx == IDX_END_OF_ARGS) return state;

        if (idx & IDX_VARIABLE_LENGTH != 0) {
            if (idx == IDX_USE_STATE) {
                state = abi.decode(output, (bytes[]));
            } else {
                require(idx & IDX_VALUE_MASK < state.length, "Index out-of-bounds");
                // Check the first field is 0x20 (because we have only a single return value)
                uint256 argPtr;
                assembly {
                    argPtr := mload(add(output, 32))
                }
                require(
                    argPtr == 32,
                    "Only one return value permitted (variable)"
                );

                assembly {
                    // Overwrite the first word of the return data with the length - 32
                    mstore(add(output, 32), sub(mload(output), 32))
                    // Insert a pointer to the return data, starting at the second word, into state
                    mstore(
                        add(add(state, 32), mul(and(idx, IDX_VALUE_MASK), 32)),
                        add(output, 32)
                    )
                }
            }
        } else {
            require(idx & IDX_VALUE_MASK < state.length, "Index out-of-bounds");
            // Single word
            require(
                output.length == 32,
                "Only one return value permitted (static)"
            );

            state[idx & IDX_VALUE_MASK] = output;
        }

        return state;
    }

    function writeTuple(
        bytes[] memory state,
        bytes1 index,
        bytes memory output
    ) internal view {
        uint256 idx = uint8(index);
        if (idx == IDX_END_OF_ARGS) return;

        bytes memory entry = state[idx & IDX_VALUE_MASK] = new bytes(output.length + 32);
        memcpy(output, 0, entry, 32, output.length);
        assembly {
            let l := mload(output)
            mstore(add(entry, 32), l)
        }
    }

    function memcpy(
        bytes memory src,
        uint256 srcIdx,
        bytes memory dest,
        uint256 destIdx,
        uint256 len
    ) internal view {
        assembly {
            pop(
                staticcall(
                    gas(),
                    4,
                    add(add(src, 32), srcIdx),
                    len,
                    add(add(dest, 32), destIdx),
                    len
                )
            )
        }
    }
}
// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.16;

import "./CommandBuilder.sol";

abstract contract VM {
    using CommandBuilder for bytes[];

    uint256 constant FLAG_CT_DELEGATECALL = 0x00; // Delegate call not currently supported
    uint256 constant FLAG_CT_CALL = 0x01;
    uint256 constant FLAG_CT_STATICCALL = 0x02;
    uint256 constant FLAG_CT_VALUECALL = 0x03;
    uint256 constant FLAG_CT_MASK = 0x03;
    uint256 constant FLAG_DATA = 0x20;
    uint256 constant FLAG_EXTENDED_COMMAND = 0x40;
    uint256 constant FLAG_TUPLE_RETURN = 0x80;

    uint256 constant SHORT_COMMAND_FILL =
        0x000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    error ExecutionFailed(
        uint256 command_index,
        address target,
        string message
    );

    function _execute(bytes32[] calldata commands, bytes[] memory state)
        internal
        returns (bytes[] memory)
    {
        bytes32 command;
        uint256 flags;
        bytes32 indices;

        bool success;
        bytes memory outData;

        uint256 commandsLength = commands.length;
        uint256 indicesLength;
        for (uint256 i; i < commandsLength; i = _uncheckedIncrement(i)) {
            command = commands[i];
            flags = uint256(uint8(bytes1(command << 32)));

            if (flags & FLAG_EXTENDED_COMMAND != 0) {
                i = _uncheckedIncrement(i);
                indices = commands[i];
                indicesLength = 32;
            } else {
                indices = bytes32(uint256(command << 40) | SHORT_COMMAND_FILL);
                indicesLength = 6;
            }

            if (flags & FLAG_CT_MASK == FLAG_CT_CALL) {
                (success, outData) = address(uint160(uint256(command))).call( // target
                    // inputs
                    flags & FLAG_DATA == 0
                        ? state.buildInputs(
                            bytes4(command), // selector
                            indices,
                            indicesLength
                        )
                        : state[
                            uint8(bytes1(indices)) &
                            CommandBuilder.IDX_VALUE_MASK
                        ]
                );
            } else if (flags & FLAG_CT_MASK == FLAG_CT_STATICCALL) {
                (success, outData) = address(uint160(uint256(command))) // target
                    .staticcall(
                        // inputs
                        flags & FLAG_DATA == 0
                            ? state.buildInputs(
                                bytes4(command), // selector
                                indices,
                                indicesLength
                            )
                            : state[
                                uint8(bytes1(indices)) &
                                CommandBuilder.IDX_VALUE_MASK
                            ]
                    );
            } else if (flags & FLAG_CT_MASK == FLAG_CT_VALUECALL) {
                bytes memory v = state[
                    uint8(bytes1(indices)) &
                    CommandBuilder.IDX_VALUE_MASK
                ];
                require(v.length == 32, "Value must be 32 bytes");
                uint256 callEth = uint256(bytes32(v));
                (success, outData) = address(uint160(uint256(command))).call{ // target
                    value: callEth
                }(
                    // inputs
                    flags & FLAG_DATA == 0
                        ? state.buildInputs(
                            bytes4(command), // selector
                            indices << 8, // skip value input
                            indicesLength - 1 // max indices length reduced by value input
                        )
                        : state[
                            uint8(bytes1(indices << 8)) & // first byte after value input
                            CommandBuilder.IDX_VALUE_MASK
                        ]
                );
            } else {
                revert("Invalid calltype");
            }

            if (!success) {
                string memory message = "Unknown";
                if (outData.length > 68) {
                    // This might be an error message, parse the outData
                    // Estimate the bytes length of the possible error message
                    uint256 estimatedLength = _estimateBytesLength(outData, 68);
                    // Remove selector. First 32 bytes should be a pointer that indicates the start of data in memory
                    assembly {
                        outData := add(outData, 4)
                    }
                    uint256 pointer = uint256(bytes32(outData));
                    if (pointer == 32) {
                        // Remove pointer. If it is a string, the next 32 bytes will hold the size
                        assembly {
                            outData := add(outData, 32)
                        }
                        uint256 size = uint256(bytes32(outData));
                        // If the size variable is the same as the estimated bytes length, we can be fairly certain
                        // this is a dynamic string, so convert the bytes to a string and emit the message. While an
                        // error function with 3 static parameters is capable of producing a similar output, there is
                        // low risk of a contract unintentionally emitting a message.
                        if (size == estimatedLength) {
                            // Remove size. The remaining data should be the string content
                            assembly {
                                outData := add(outData, 32)
                            }
                            message = string(outData);
                        }
                    }
                }
                revert ExecutionFailed({
                    command_index: flags & FLAG_EXTENDED_COMMAND == 0
                        ? i
                        : i - 1,
                    target: address(uint160(uint256(command))),
                    message: message
                });
            }

            if (flags & FLAG_TUPLE_RETURN != 0) {
                state.writeTuple(bytes1(command << 88), outData);
            } else {
                state = state.writeOutputs(bytes1(command << 88), outData);
            }
        }
        return state;
    }

    function _estimateBytesLength(bytes memory data, uint256 pos) internal pure returns (uint256 estimate) {
        uint256 length = data.length;
        estimate = length - pos; // Assume length equals alloted space
        for (uint256 i = pos; i < length; ) {
            if (data[i] == 0) {
                // Zero bytes found, adjust estimated length
                estimate = i - pos;
                break;
            }
            unchecked {
                ++i;
            }
        }
    }

    function _uncheckedIncrement(uint256 i) private pure returns (uint256) {
        unchecked {
            ++i;
        }
        return i;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;

import {Context} from "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
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
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
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
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
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
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable2Step.sol)

pragma solidity ^0.8.20;

import {Ownable} from "./Ownable.sol";

/**
 * @dev Contract module which provides access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This extension of the {Ownable} contract includes a two-step mechanism to transfer
 * ownership, where the new owner must call {acceptOwnership} in order to replace the
 * old one. This can help prevent common mistakes, such as transfers of ownership to
 * incorrect accounts, or to contracts that are unable to interact with the
 * permission system.
 *
 * The initial owner is specified at deployment time in the constructor for `Ownable`. This
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
     *
     * Setting `newOwner` to the zero address is allowed; this can be used to cancel an initiated ownership transfer.
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
        if (pendingOwner() != sender) {
            revert OwnableUnauthorizedAccount(sender);
        }
        _transferOwnership(sender);
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

pragma solidity ^0.8.24;

import {StorageSlot} from "./StorageSlot.sol";

/**
 * @dev Variant of {ReentrancyGuard} that uses transient storage.
 *
 * NOTE: This variant only works on networks where EIP-1153 is available.
 */
abstract contract ReentrancyGuardTransient {
    using StorageSlot for *;

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.ReentrancyGuard")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant REENTRANCY_GUARD_STORAGE =
        0x9b779b17422d0df92223018b32b4d1fa46e071723d6817e2486d003becc55f00;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_reentrancyGuardEntered()) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        REENTRANCY_GUARD_STORAGE.asBoolean().tstore(true);
    }

    function _nonReentrantAfter() private {
        REENTRANCY_GUARD_STORAGE.asBoolean().tstore(false);
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return REENTRANCY_GUARD_STORAGE.asBoolean().tload();
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/StorageSlot.sol)
// This file was procedurally generated from scripts/generate/templates/StorageSlot.js.

pragma solidity ^0.8.24;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC-1967 implementation slot:
 * ```solidity
 * contract ERC1967 {
 *     // Define the slot. Alternatively, use the SlotDerivation library to derive the slot.
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
 *
 * Since version 5.1, this library also support writing and reading value types to and from transient storage.
 *
 *  * Example using transient storage:
 * ```solidity
 * contract Lock {
 *     // Define the slot. Alternatively, use the SlotDerivation library to derive the slot.
 *     bytes32 internal constant _LOCK_SLOT = 0xf4678858b2b588224636b8522b729e7722d32fc491da849ed75b3fdf3c84f542;
 *
 *     modifier locked() {
 *         require(!_LOCK_SLOT.asBoolean().tload());
 *
 *         _LOCK_SLOT.asBoolean().tstore(true);
 *         _;
 *         _LOCK_SLOT.asBoolean().tstore(false);
 *     }
 * }
 * ```
 *
 * TIP: Consider using this library along with {SlotDerivation}.
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

    struct Int256Slot {
        int256 value;
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
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns a `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns a `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns a `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns a `Int256Slot` with member `value` located at `slot`.
     */
    function getInt256Slot(bytes32 slot) internal pure returns (Int256Slot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns a `StringSlot` with member `value` located at `slot`.
     */
    function getStringSlot(bytes32 slot) internal pure returns (StringSlot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `StringSlot` representation of the string storage pointer `store`.
     */
    function getStringSlot(string storage store) internal pure returns (StringSlot storage r) {
        assembly ("memory-safe") {
            r.slot := store.slot
        }
    }

    /**
     * @dev Returns a `BytesSlot` with member `value` located at `slot`.
     */
    function getBytesSlot(bytes32 slot) internal pure returns (BytesSlot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BytesSlot` representation of the bytes storage pointer `store`.
     */
    function getBytesSlot(bytes storage store) internal pure returns (BytesSlot storage r) {
        assembly ("memory-safe") {
            r.slot := store.slot
        }
    }

    /**
     * @dev UDVT that represent a slot holding a address.
     */
    type AddressSlotType is bytes32;

    /**
     * @dev Cast an arbitrary slot to a AddressSlotType.
     */
    function asAddress(bytes32 slot) internal pure returns (AddressSlotType) {
        return AddressSlotType.wrap(slot);
    }

    /**
     * @dev UDVT that represent a slot holding a bool.
     */
    type BooleanSlotType is bytes32;

    /**
     * @dev Cast an arbitrary slot to a BooleanSlotType.
     */
    function asBoolean(bytes32 slot) internal pure returns (BooleanSlotType) {
        return BooleanSlotType.wrap(slot);
    }

    /**
     * @dev UDVT that represent a slot holding a bytes32.
     */
    type Bytes32SlotType is bytes32;

    /**
     * @dev Cast an arbitrary slot to a Bytes32SlotType.
     */
    function asBytes32(bytes32 slot) internal pure returns (Bytes32SlotType) {
        return Bytes32SlotType.wrap(slot);
    }

    /**
     * @dev UDVT that represent a slot holding a uint256.
     */
    type Uint256SlotType is bytes32;

    /**
     * @dev Cast an arbitrary slot to a Uint256SlotType.
     */
    function asUint256(bytes32 slot) internal pure returns (Uint256SlotType) {
        return Uint256SlotType.wrap(slot);
    }

    /**
     * @dev UDVT that represent a slot holding a int256.
     */
    type Int256SlotType is bytes32;

    /**
     * @dev Cast an arbitrary slot to a Int256SlotType.
     */
    function asInt256(bytes32 slot) internal pure returns (Int256SlotType) {
        return Int256SlotType.wrap(slot);
    }

    /**
     * @dev Load the value held at location `slot` in transient storage.
     */
    function tload(AddressSlotType slot) internal view returns (address value) {
        assembly ("memory-safe") {
            value := tload(slot)
        }
    }

    /**
     * @dev Store `value` at location `slot` in transient storage.
     */
    function tstore(AddressSlotType slot, address value) internal {
        assembly ("memory-safe") {
            tstore(slot, value)
        }
    }

    /**
     * @dev Load the value held at location `slot` in transient storage.
     */
    function tload(BooleanSlotType slot) internal view returns (bool value) {
        assembly ("memory-safe") {
            value := tload(slot)
        }
    }

    /**
     * @dev Store `value` at location `slot` in transient storage.
     */
    function tstore(BooleanSlotType slot, bool value) internal {
        assembly ("memory-safe") {
            tstore(slot, value)
        }
    }

    /**
     * @dev Load the value held at location `slot` in transient storage.
     */
    function tload(Bytes32SlotType slot) internal view returns (bytes32 value) {
        assembly ("memory-safe") {
            value := tload(slot)
        }
    }

    /**
     * @dev Store `value` at location `slot` in transient storage.
     */
    function tstore(Bytes32SlotType slot, bytes32 value) internal {
        assembly ("memory-safe") {
            tstore(slot, value)
        }
    }

    /**
     * @dev Load the value held at location `slot` in transient storage.
     */
    function tload(Uint256SlotType slot) internal view returns (uint256 value) {
        assembly ("memory-safe") {
            value := tload(slot)
        }
    }

    /**
     * @dev Store `value` at location `slot` in transient storage.
     */
    function tstore(Uint256SlotType slot, uint256 value) internal {
        assembly ("memory-safe") {
            tstore(slot, value)
        }
    }

    /**
     * @dev Load the value held at location `slot` in transient storage.
     */
    function tload(Int256SlotType slot) internal view returns (int256 value) {
        assembly ("memory-safe") {
            value := tload(slot)
        }
    }

    /**
     * @dev Store `value` at location `slot` in transient storage.
     */
    function tstore(Int256SlotType slot, int256 value) internal {
        assembly ("memory-safe") {
            tstore(slot, value)
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Gas optimized ECDSA wrapper.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/ECDSA.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/ECDSA.sol)
/// @author Modified from OpenZeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/cryptography/ECDSA.sol)
///
/// @dev Note:
/// - The recovery functions use the ecrecover precompile (0x1).
/// - As of Solady version 0.0.68, the `recover` variants will revert upon recovery failure.
///   This is for more safety by default.
///   Use the `tryRecover` variants if you need to get the zero address back
///   upon recovery failure instead.
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
library ECDSA {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                        CUSTOM ERRORS                       */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The signature is invalid.
    error InvalidSignature();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                    RECOVERY OPERATIONS                     */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Recovers the signer's address from a message digest `hash`, and the `signature`.
    function recover(bytes32 hash, bytes memory signature) internal view returns (address result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := 1
            let m := mload(0x40) // Cache the free memory pointer.
            for {} 1 {} {
                mstore(0x00, hash)
                mstore(0x40, mload(add(signature, 0x20))) // `r`.
                if eq(mload(signature), 64) {
                    let vs := mload(add(signature, 0x40))
                    mstore(0x20, add(shr(255, vs), 27)) // `v`.
                    mstore(0x60, shr(1, shl(1, vs))) // `s`.
                    break
                }
                if eq(mload(signature), 65) {
                    mstore(0x20, byte(0, mload(add(signature, 0x60)))) // `v`.
                    mstore(0x60, mload(add(signature, 0x40))) // `s`.
                    break
                }
                result := 0
                break
            }
            result :=
                mload(
                    staticcall(
                        gas(), // Amount of gas left for the transaction.
                        result, // Address of `ecrecover`.
                        0x00, // Start of input.
                        0x80, // Size of input.
                        0x01, // Start of output.
                        0x20 // Size of output.
                    )
                )
            // `returndatasize()` will be `0x20` upon success, and `0x00` otherwise.
            if iszero(returndatasize()) {
                mstore(0x00, 0x8baa579f) // `InvalidSignature()`.
                revert(0x1c, 0x04)
            }
            mstore(0x60, 0) // Restore the zero slot.
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Recovers the signer's address from a message digest `hash`, and the `signature`.
    function recoverCalldata(bytes32 hash, bytes calldata signature)
        internal
        view
        returns (address result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            result := 1
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x00, hash)
            for {} 1 {} {
                if eq(signature.length, 64) {
                    let vs := calldataload(add(signature.offset, 0x20))
                    mstore(0x20, add(shr(255, vs), 27)) // `v`.
                    mstore(0x40, calldataload(signature.offset)) // `r`.
                    mstore(0x60, shr(1, shl(1, vs))) // `s`.
                    break
                }
                if eq(signature.length, 65) {
                    mstore(0x20, byte(0, calldataload(add(signature.offset, 0x40)))) // `v`.
                    calldatacopy(0x40, signature.offset, 0x40) // Copy `r` and `s`.
                    break
                }
                result := 0
                break
            }
            result :=
                mload(
                    staticcall(
                        gas(), // Amount of gas left for the transaction.
                        result, // Address of `ecrecover`.
                        0x00, // Start of input.
                        0x80, // Size of input.
                        0x01, // Start of output.
                        0x20 // Size of output.
                    )
                )
            // `returndatasize()` will be `0x20` upon success, and `0x00` otherwise.
            if iszero(returndatasize()) {
                mstore(0x00, 0x8baa579f) // `InvalidSignature()`.
                revert(0x1c, 0x04)
            }
            mstore(0x60, 0) // Restore the zero slot.
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Recovers the signer's address from a message digest `hash`,
    /// and the EIP-2098 short form signature defined by `r` and `vs`.
    function recover(bytes32 hash, bytes32 r, bytes32 vs) internal view returns (address result) {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x00, hash)
            mstore(0x20, add(shr(255, vs), 27)) // `v`.
            mstore(0x40, r)
            mstore(0x60, shr(1, shl(1, vs))) // `s`.
            result :=
                mload(
                    staticcall(
                        gas(), // Amount of gas left for the transaction.
                        1, // Address of `ecrecover`.
                        0x00, // Start of input.
                        0x80, // Size of input.
                        0x01, // Start of output.
                        0x20 // Size of output.
                    )
                )
            // `returndatasize()` will be `0x20` upon success, and `0x00` otherwise.
            if iszero(returndatasize()) {
                mstore(0x00, 0x8baa579f) // `InvalidSignature()`.
                revert(0x1c, 0x04)
            }
            mstore(0x60, 0) // Restore the zero slot.
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Recovers the signer's address from a message digest `hash`,
    /// and the signature defined by `v`, `r`, `s`.
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s)
        internal
        view
        returns (address result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x00, hash)
            mstore(0x20, and(v, 0xff))
            mstore(0x40, r)
            mstore(0x60, s)
            result :=
                mload(
                    staticcall(
                        gas(), // Amount of gas left for the transaction.
                        1, // Address of `ecrecover`.
                        0x00, // Start of input.
                        0x80, // Size of input.
                        0x01, // Start of output.
                        0x20 // Size of output.
                    )
                )
            // `returndatasize()` will be `0x20` upon success, and `0x00` otherwise.
            if iszero(returndatasize()) {
                mstore(0x00, 0x8baa579f) // `InvalidSignature()`.
                revert(0x1c, 0x04)
            }
            mstore(0x60, 0) // Restore the zero slot.
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                   TRY-RECOVER OPERATIONS                   */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // WARNING!
    // These functions will NOT revert upon recovery failure.
    // Instead, they will return the zero address upon recovery failure.
    // It is critical that the returned address is NEVER compared against
    // a zero address (e.g. an uninitialized address variable).

    /// @dev Recovers the signer's address from a message digest `hash`, and the `signature`.
    function tryRecover(bytes32 hash, bytes memory signature)
        internal
        view
        returns (address result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            result := 1
            let m := mload(0x40) // Cache the free memory pointer.
            for {} 1 {} {
                mstore(0x00, hash)
                mstore(0x40, mload(add(signature, 0x20))) // `r`.
                if eq(mload(signature), 64) {
                    let vs := mload(add(signature, 0x40))
                    mstore(0x20, add(shr(255, vs), 27)) // `v`.
                    mstore(0x60, shr(1, shl(1, vs))) // `s`.
                    break
                }
                if eq(mload(signature), 65) {
                    mstore(0x20, byte(0, mload(add(signature, 0x60)))) // `v`.
                    mstore(0x60, mload(add(signature, 0x40))) // `s`.
                    break
                }
                result := 0
                break
            }
            pop(
                staticcall(
                    gas(), // Amount of gas left for the transaction.
                    result, // Address of `ecrecover`.
                    0x00, // Start of input.
                    0x80, // Size of input.
                    0x40, // Start of output.
                    0x20 // Size of output.
                )
            )
            mstore(0x60, 0) // Restore the zero slot.
            // `returndatasize()` will be `0x20` upon success, and `0x00` otherwise.
            result := mload(xor(0x60, returndatasize()))
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Recovers the signer's address from a message digest `hash`, and the `signature`.
    function tryRecoverCalldata(bytes32 hash, bytes calldata signature)
        internal
        view
        returns (address result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            result := 1
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x00, hash)
            for {} 1 {} {
                if eq(signature.length, 64) {
                    let vs := calldataload(add(signature.offset, 0x20))
                    mstore(0x20, add(shr(255, vs), 27)) // `v`.
                    mstore(0x40, calldataload(signature.offset)) // `r`.
                    mstore(0x60, shr(1, shl(1, vs))) // `s`.
                    break
                }
                if eq(signature.length, 65) {
                    mstore(0x20, byte(0, calldataload(add(signature.offset, 0x40)))) // `v`.
                    calldatacopy(0x40, signature.offset, 0x40) // Copy `r` and `s`.
                    break
                }
                result := 0
                break
            }
            pop(
                staticcall(
                    gas(), // Amount of gas left for the transaction.
                    result, // Address of `ecrecover`.
                    0x00, // Start of input.
                    0x80, // Size of input.
                    0x40, // Start of output.
                    0x20 // Size of output.
                )
            )
            mstore(0x60, 0) // Restore the zero slot.
            // `returndatasize()` will be `0x20` upon success, and `0x00` otherwise.
            result := mload(xor(0x60, returndatasize()))
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Recovers the signer's address from a message digest `hash`,
    /// and the EIP-2098 short form signature defined by `r` and `vs`.
    function tryRecover(bytes32 hash, bytes32 r, bytes32 vs)
        internal
        view
        returns (address result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x00, hash)
            mstore(0x20, add(shr(255, vs), 27)) // `v`.
            mstore(0x40, r)
            mstore(0x60, shr(1, shl(1, vs))) // `s`.
            pop(
                staticcall(
                    gas(), // Amount of gas left for the transaction.
                    1, // Address of `ecrecover`.
                    0x00, // Start of input.
                    0x80, // Size of input.
                    0x40, // Start of output.
                    0x20 // Size of output.
                )
            )
            mstore(0x60, 0) // Restore the zero slot.
            // `returndatasize()` will be `0x20` upon success, and `0x00` otherwise.
            result := mload(xor(0x60, returndatasize()))
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Recovers the signer's address from a message digest `hash`,
    /// and the signature defined by `v`, `r`, `s`.
    function tryRecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s)
        internal
        view
        returns (address result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x00, hash)
            mstore(0x20, and(v, 0xff))
            mstore(0x40, r)
            mstore(0x60, s)
            pop(
                staticcall(
                    gas(), // Amount of gas left for the transaction.
                    1, // Address of `ecrecover`.
                    0x00, // Start of input.
                    0x80, // Size of input.
                    0x40, // Start of output.
                    0x20 // Size of output.
                )
            )
            mstore(0x60, 0) // Restore the zero slot.
            // `returndatasize()` will be `0x20` upon success, and `0x00` otherwise.
            result := mload(xor(0x60, returndatasize()))
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                     HASHING OPERATIONS                     */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns an Ethereum Signed Message, created from a `hash`.
    /// This produces a hash corresponding to the one signed with the
    /// [`eth_sign`](https://ethereum.org/en/developers/docs/apis/json-rpc/#eth_sign)
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
    /// [`eth_sign`](https://ethereum.org/en/developers/docs/apis/json-rpc/#eth_sign)
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
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Simple single owner authorization mixin.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/auth/Owned.sol)
abstract contract Owned {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event OwnershipTransferred(address indexed user, address indexed newOwner);

    /*//////////////////////////////////////////////////////////////
                            OWNERSHIP STORAGE
    //////////////////////////////////////////////////////////////*/

    address public owner;

    modifier onlyOwner() virtual {
        require(msg.sender == owner, "UNAUTHORIZED");

        _;
    }

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

    function transferOwnership(address newOwner) public virtual onlyOwner {
        owner = newOwner;

        emit OwnershipTransferred(msg.sender, newOwner);
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Modern and gas efficient ERC20 + EIP-2612 implementation.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC20.sol)
/// @author Modified from Uniswap (https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/UniswapV2ERC20.sol)
/// @dev Do not manually set balances without updating totalSupply, as the sum of all user balances must not exceed it.
abstract contract ERC20 {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    /*//////////////////////////////////////////////////////////////
                            METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

    string public name;

    string public symbol;

    uint8 public immutable decimals;

    /*//////////////////////////////////////////////////////////////
                              ERC20 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    /*//////////////////////////////////////////////////////////////
                            EIP-2612 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 internal immutable INITIAL_CHAIN_ID;

    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;

    mapping(address => uint256) public nonces;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        INITIAL_CHAIN_ID = block.chainid;
        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();
    }

    /*//////////////////////////////////////////////////////////////
                               ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        balanceOf[msg.sender] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(msg.sender, to, amount);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;

        balanceOf[from] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);

        return true;
    }

    /*//////////////////////////////////////////////////////////////
                             EIP-2612 LOGIC
    //////////////////////////////////////////////////////////////*/

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

        // Unchecked because the only math done is incrementing
        // the owner's nonce which cannot realistically overflow.
        unchecked {
            address recoveredAddress = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19\x01",
                        DOMAIN_SEPARATOR(),
                        keccak256(
                            abi.encode(
                                keccak256(
                                    "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                                ),
                                owner,
                                spender,
                                value,
                                nonces[owner]++,
                                deadline
                            )
                        )
                    )
                ),
                v,
                r,
                s
            );

            require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_SIGNER");

            allowance[recoveredAddress][spender] = value;
        }

        emit Approval(owner, spender, value);
    }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();
    }

    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                    keccak256(bytes(name)),
                    keccak256("1"),
                    block.chainid,
                    address(this)
                )
            );
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        balanceOf[from] -= amount;

        // Cannot underflow because a user's balance
        // will never be larger than the total supply.
        unchecked {
            totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ERC20} from "../tokens/ERC20.sol";
import {SafeTransferLib} from "../utils/SafeTransferLib.sol";
import {FixedPointMathLib} from "../utils/FixedPointMathLib.sol";

/// @notice Minimal ERC4626 tokenized Vault implementation.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC4626.sol)
abstract contract ERC4626 is ERC20 {
    using SafeTransferLib for ERC20;
    using FixedPointMathLib for uint256;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Deposit(address indexed caller, address indexed owner, uint256 assets, uint256 shares);

    event Withdraw(
        address indexed caller,
        address indexed receiver,
        address indexed owner,
        uint256 assets,
        uint256 shares
    );

    /*//////////////////////////////////////////////////////////////
                               IMMUTABLES
    //////////////////////////////////////////////////////////////*/

    ERC20 public immutable asset;

    constructor(
        ERC20 _asset,
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol, _asset.decimals()) {
        asset = _asset;
    }

    /*//////////////////////////////////////////////////////////////
                        DEPOSIT/WITHDRAWAL LOGIC
    //////////////////////////////////////////////////////////////*/

    function deposit(uint256 assets, address receiver) public virtual returns (uint256 shares) {
        // Check for rounding error since we round down in previewDeposit.
        require((shares = previewDeposit(assets)) != 0, "ZERO_SHARES");

        // Need to transfer before minting or ERC777s could reenter.
        asset.safeTransferFrom(msg.sender, address(this), assets);

        _mint(receiver, shares);

        emit Deposit(msg.sender, receiver, assets, shares);

        afterDeposit(assets, shares);
    }

    function mint(uint256 shares, address receiver) public virtual returns (uint256 assets) {
        assets = previewMint(shares); // No need to check for rounding error, previewMint rounds up.

        // Need to transfer before minting or ERC777s could reenter.
        asset.safeTransferFrom(msg.sender, address(this), assets);

        _mint(receiver, shares);

        emit Deposit(msg.sender, receiver, assets, shares);

        afterDeposit(assets, shares);
    }

    function withdraw(
        uint256 assets,
        address receiver,
        address owner
    ) public virtual returns (uint256 shares) {
        shares = previewWithdraw(assets); // No need to check for rounding error, previewWithdraw rounds up.

        if (msg.sender != owner) {
            uint256 allowed = allowance[owner][msg.sender]; // Saves gas for limited approvals.

            if (allowed != type(uint256).max) allowance[owner][msg.sender] = allowed - shares;
        }

        beforeWithdraw(assets, shares);

        _burn(owner, shares);

        emit Withdraw(msg.sender, receiver, owner, assets, shares);

        asset.safeTransfer(receiver, assets);
    }

    function redeem(
        uint256 shares,
        address receiver,
        address owner
    ) public virtual returns (uint256 assets) {
        if (msg.sender != owner) {
            uint256 allowed = allowance[owner][msg.sender]; // Saves gas for limited approvals.

            if (allowed != type(uint256).max) allowance[owner][msg.sender] = allowed - shares;
        }

        // Check for rounding error since we round down in previewRedeem.
        require((assets = previewRedeem(shares)) != 0, "ZERO_ASSETS");

        beforeWithdraw(assets, shares);

        _burn(owner, shares);

        emit Withdraw(msg.sender, receiver, owner, assets, shares);

        asset.safeTransfer(receiver, assets);
    }

    /*//////////////////////////////////////////////////////////////
                            ACCOUNTING LOGIC
    //////////////////////////////////////////////////////////////*/

    function totalAssets() public view virtual returns (uint256);

    function convertToShares(uint256 assets) public view virtual returns (uint256) {
        uint256 supply = totalSupply; // Saves an extra SLOAD if totalSupply is non-zero.

        return supply == 0 ? assets : assets.mulDivDown(supply, totalAssets());
    }

    function convertToAssets(uint256 shares) public view virtual returns (uint256) {
        uint256 supply = totalSupply; // Saves an extra SLOAD if totalSupply is non-zero.

        return supply == 0 ? shares : shares.mulDivDown(totalAssets(), supply);
    }

    function previewDeposit(uint256 assets) public view virtual returns (uint256) {
        return convertToShares(assets);
    }

    function previewMint(uint256 shares) public view virtual returns (uint256) {
        uint256 supply = totalSupply; // Saves an extra SLOAD if totalSupply is non-zero.

        return supply == 0 ? shares : shares.mulDivUp(totalAssets(), supply);
    }

    function previewWithdraw(uint256 assets) public view virtual returns (uint256) {
        uint256 supply = totalSupply; // Saves an extra SLOAD if totalSupply is non-zero.

        return supply == 0 ? assets : assets.mulDivUp(supply, totalAssets());
    }

    function previewRedeem(uint256 shares) public view virtual returns (uint256) {
        return convertToAssets(shares);
    }

    /*//////////////////////////////////////////////////////////////
                     DEPOSIT/WITHDRAWAL LIMIT LOGIC
    //////////////////////////////////////////////////////////////*/

    function maxDeposit(address) public view virtual returns (uint256) {
        return type(uint256).max;
    }

    function maxMint(address) public view virtual returns (uint256) {
        return type(uint256).max;
    }

    function maxWithdraw(address owner) public view virtual returns (uint256) {
        return convertToAssets(balanceOf[owner]);
    }

    function maxRedeem(address owner) public view virtual returns (uint256) {
        return balanceOf[owner];
    }

    /*//////////////////////////////////////////////////////////////
                          INTERNAL HOOKS LOGIC
    //////////////////////////////////////////////////////////////*/

    function beforeWithdraw(uint256 assets, uint256 shares) internal virtual {}

    function afterDeposit(uint256 assets, uint256 shares) internal virtual {}
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Arithmetic library with operations for fixed-point numbers.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/FixedPointMathLib.sol)
/// @author Inspired by USM (https://github.com/usmfum/USM/blob/master/contracts/WadMath.sol)
library FixedPointMathLib {
    /*//////////////////////////////////////////////////////////////
                    SIMPLIFIED FIXED POINT OPERATIONS
    //////////////////////////////////////////////////////////////*/

    uint256 internal constant MAX_UINT256 = 2**256 - 1;

    uint256 internal constant WAD = 1e18; // The scalar of ETH and most ERC20s.

    function mulWadDown(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulDivDown(x, y, WAD); // Equivalent to (x * y) / WAD rounded down.
    }

    function mulWadUp(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulDivUp(x, y, WAD); // Equivalent to (x * y) / WAD rounded up.
    }

    function divWadDown(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulDivDown(x, WAD, y); // Equivalent to (x * WAD) / y rounded down.
    }

    function divWadUp(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulDivUp(x, WAD, y); // Equivalent to (x * WAD) / y rounded up.
    }

    /*//////////////////////////////////////////////////////////////
                    LOW LEVEL FIXED POINT OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function mulDivDown(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Equivalent to require(denominator != 0 && (y == 0 || x <= type(uint256).max / y))
            if iszero(mul(denominator, iszero(mul(y, gt(x, div(MAX_UINT256, y)))))) {
                revert(0, 0)
            }

            // Divide x * y by the denominator.
            z := div(mul(x, y), denominator)
        }
    }

    function mulDivUp(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Equivalent to require(denominator != 0 && (y == 0 || x <= type(uint256).max / y))
            if iszero(mul(denominator, iszero(mul(y, gt(x, div(MAX_UINT256, y)))))) {
                revert(0, 0)
            }

            // If x * y modulo the denominator is strictly greater than 0,
            // 1 is added to round up the division of x * y by the denominator.
            z := add(gt(mod(mul(x, y), denominator), 0), div(mul(x, y), denominator))
        }
    }

    function rpow(
        uint256 x,
        uint256 n,
        uint256 scalar
    ) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            switch x
            case 0 {
                switch n
                case 0 {
                    // 0 ** 0 = 1
                    z := scalar
                }
                default {
                    // 0 ** n = 0
                    z := 0
                }
            }
            default {
                switch mod(n, 2)
                case 0 {
                    // If n is even, store scalar in z for now.
                    z := scalar
                }
                default {
                    // If n is odd, store x in z for now.
                    z := x
                }

                // Shifting right by 1 is like dividing by 2.
                let half := shr(1, scalar)

                for {
                    // Shift n right by 1 before looping to halve it.
                    n := shr(1, n)
                } n {
                    // Shift n right by 1 each iteration to halve it.
                    n := shr(1, n)
                } {
                    // Revert immediately if x ** 2 would overflow.
                    // Equivalent to iszero(eq(div(xx, x), x)) here.
                    if shr(128, x) {
                        revert(0, 0)
                    }

                    // Store x squared.
                    let xx := mul(x, x)

                    // Round to the nearest number.
                    let xxRound := add(xx, half)

                    // Revert if xx + half overflowed.
                    if lt(xxRound, xx) {
                        revert(0, 0)
                    }

                    // Set x to scaled xxRound.
                    x := div(xxRound, scalar)

                    // If n is even:
                    if mod(n, 2) {
                        // Compute z * x.
                        let zx := mul(z, x)

                        // If z * x overflowed:
                        if iszero(eq(div(zx, x), z)) {
                            // Revert if x is non-zero.
                            if iszero(iszero(x)) {
                                revert(0, 0)
                            }
                        }

                        // Round to the nearest number.
                        let zxRound := add(zx, half)

                        // Revert if zx + half overflowed.
                        if lt(zxRound, zx) {
                            revert(0, 0)
                        }

                        // Return properly scaled zxRound.
                        z := div(zxRound, scalar)
                    }
                }
            }
        }
    }

    /*//////////////////////////////////////////////////////////////
                        GENERAL NUMBER UTILITIES
    //////////////////////////////////////////////////////////////*/

    function sqrt(uint256 x) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            let y := x // We start y at x, which will help us make our initial estimate.

            z := 181 // The "correct" value is 1, but this saves a multiplication later.

            // This segment is to get a reasonable initial estimate for the Babylonian method. With a bad
            // start, the correct # of bits increases ~linearly each iteration instead of ~quadratically.

            // We check y >= 2^(k + 8) but shift right by k bits
            // each branch to ensure that if x >= 256, then y >= 256.
            if iszero(lt(y, 0x10000000000000000000000000000000000)) {
                y := shr(128, y)
                z := shl(64, z)
            }
            if iszero(lt(y, 0x1000000000000000000)) {
                y := shr(64, y)
                z := shl(32, z)
            }
            if iszero(lt(y, 0x10000000000)) {
                y := shr(32, y)
                z := shl(16, z)
            }
            if iszero(lt(y, 0x1000000)) {
                y := shr(16, y)
                z := shl(8, z)
            }

            // Goal was to get z*z*y within a small factor of x. More iterations could
            // get y in a tighter range. Currently, we will have y in [256, 256*2^16).
            // We ensured y >= 256 so that the relative difference between y and y+1 is small.
            // That's not possible if x < 256 but we can just verify those cases exhaustively.

            // Now, z*z*y <= x < z*z*(y+1), and y <= 2^(16+8), and either y >= 256, or x < 256.
            // Correctness can be checked exhaustively for x < 256, so we assume y >= 256.
            // Then z*sqrt(y) is within sqrt(257)/sqrt(256) of sqrt(x), or about 20bps.

            // For s in the range [1/256, 256], the estimate f(s) = (181/1024) * (s+1) is in the range
            // (1/2.84 * sqrt(s), 2.84 * sqrt(s)), with largest error when s = 1 and when s = 256 or 1/256.

            // Since y is in [256, 256*2^16), let a = y/65536, so that a is in [1/256, 256). Then we can estimate
            // sqrt(y) using sqrt(65536) * 181/1024 * (a + 1) = 181/4 * (y + 65536)/65536 = 181 * (y + 65536)/2^18.

            // There is no overflow risk here since y < 2^136 after the first branch above.
            z := shr(18, mul(z, add(y, 65536))) // A mul() is saved from starting z at 181.

            // Given the worst case multiplicative error of 2.84 above, 7 iterations should be enough.
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))

            // If x+1 is a perfect square, the Babylonian method cycles between
            // floor(sqrt(x)) and ceil(sqrt(x)). This statement ensures we return floor.
            // See: https://en.wikipedia.org/wiki/Integer_square_root#Using_only_integer_division
            // Since the ceil is rare, we save gas on the assignment and repeat division in the rare case.
            // If you don't care whether the floor or ceil square root is returned, you can remove this statement.
            z := sub(z, lt(div(x, z), z))
        }
    }

    function unsafeMod(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Mod x by y. Note this will return
            // 0 instead of reverting if y is zero.
            z := mod(x, y)
        }
    }

    function unsafeDiv(uint256 x, uint256 y) internal pure returns (uint256 r) {
        /// @solidity memory-safe-assembly
        assembly {
            // Divide x by y. Note this will return
            // 0 instead of reverting if y is zero.
            r := div(x, y)
        }
    }

    function unsafeDivUp(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Add 1 to x * y if x % y > 0. Note this will
            // return 0 instead of reverting if y is zero.
            z := add(gt(mod(x, y), 0), div(x, y))
        }
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ERC20} from "../tokens/ERC20.sol";

/// @notice Safe ETH and ERC20 transfer library that gracefully handles missing return values.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/SafeTransferLib.sol)
/// @dev Use with caution! Some functions in this library knowingly create dirty bits at the destination of the free memory pointer.
/// @dev Note that none of the functions in this library check that a token has code at all! That responsibility is delegated to the caller.
library SafeTransferLib {
    /*//////////////////////////////////////////////////////////////
                             ETH OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferETH(address to, uint256 amount) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Transfer the ETH and store if it succeeded or not.
            success := call(gas(), to, amount, 0, 0, 0, 0)
        }

        require(success, "ETH_TRANSFER_FAILED");
    }

    /*//////////////////////////////////////////////////////////////
                            ERC20 OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferFrom(
        ERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x23b872dd00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(from, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "from" argument.
            mstore(add(freeMemoryPointer, 36), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "to" argument.
            mstore(add(freeMemoryPointer, 68), amount) // Append the "amount" argument. Masking not required as it's a full 32 byte type.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 100 because the length of our calldata totals up like so: 4 + 32 * 3.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 100, 0, 32)
            )
        }

        require(success, "TRANSFER_FROM_FAILED");
    }

    function safeTransfer(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument. Masking not required as it's a full 32 byte type.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        require(success, "TRANSFER_FAILED");
    }

    function safeApprove(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x095ea7b300000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument. Masking not required as it's a full 32 byte type.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        require(success, "APPROVE_FAILED");
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import { PointsFactory } from "src/PointsFactory.sol";
import { Ownable2Step, Ownable } from "lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol";

/// @title Points
/// @author CopyPaste, Jack Corddry, Shivaansh Kapoor
/// @dev A simple contract for running Points Programs
contract Points is Ownable2Step {
    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    /// @param _name The name of the points program
    /// @param _symbol The symbol for the points program
    /// @param _decimals The amount of decimals to use for accounting with points
    /// @param _owner The owner of the points program
    constructor(string memory _name, string memory _symbol, uint256 _decimals, address _owner) Ownable(_owner) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        // Enforces that the Points Program deployer is a factory
        pointsFactory = PointsFactory(msg.sender);
    }

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/
    event Award(address indexed to, uint256 indexed amount, address indexed awardedBy);
    event AllowedVaultAdded(address indexed vault);
    event AllowedIPAdded(address indexed ip);
    event VaultRemoved(address indexed vault);
    /*//////////////////////////////////////////////////////////////
                                STORAGE
    //////////////////////////////////////////////////////////////*/
    /// @dev Maps a vault to if the vault is allowed to call this contract
    mapping(address => bool) public isAllowedVault;

    /// @dev The PointsFactory used to create this program
    PointsFactory public immutable pointsFactory;

    /// @dev The name of the points program
    string public name;
    /// @dev The symbol for the points program
    string public symbol;
    /// @dev We track all points logic using base 1
    uint256 public decimals;
    /// @dev Track which RecipeMarketHub IPs are allowed to mint
    mapping(address => bool) public allowedIPs;

    /*//////////////////////////////////////////////////////////////
                              POINTS AUTH
    //////////////////////////////////////////////////////////////*/
    error VaultIsDuplicate();

    /// @param vault The address to add to the allowed vaults for the points program
    function addAllowedVault(address vault) external onlyOwner {
        if (isAllowedVault[vault]) {
            revert VaultIsDuplicate();
        }

        isAllowedVault[vault] = true;

        emit AllowedVaultAdded(vault);
    }

    /// @param ip The incentive provider address to allow to mint points on RecipeMarketHub
    function addAllowedIP(address ip) external onlyOwner {
        allowedIPs[ip] = true;

        emit AllowedIPAdded(ip);
    }

    error OnlyAllowedVaults();
    error OnlyRecipeMarketHub();
    error NotAllowedIP();

    modifier onlyAllowedVaults() {
        if (!isAllowedVault[msg.sender]) {
            revert OnlyAllowedVaults();
        }
        _;
    }

    /// @dev only the RecipeMarketHub can call this function
    /// @param ip The address to check if allowed
    modifier onlyRecipeMarketHubAllowedIP(address ip) {
        if (!pointsFactory.isRecipeMarketHub(msg.sender)) {
            revert OnlyRecipeMarketHub();
        }
        if (!allowedIPs[ip]) {
            revert NotAllowedIP();
        }
        _;
    }

    /*//////////////////////////////////////////////////////////////
                                 POINTS
    //////////////////////////////////////////////////////////////*/

    /// @param to The address to mint points to
    /// @param amount  The amount of points to award to the `to` address
    function award(address to, uint256 amount) external onlyAllowedVaults {
        emit Award(to, amount, msg.sender);
    }

    /// @param to The address to mint points to
    /// @param amount  The amount of points to award to the `to` address
    /// @param ip The incentive provider attempting to mint the points
    function award(address to, uint256 amount, address ip) external onlyRecipeMarketHubAllowedIP(ip) {
        emit Award(to, amount, ip);
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import { Points } from "src/Points.sol";
import { Ownable2Step, Ownable } from "lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol";

/// @title PointsFactory
/// @author CopyPaste, Jack Corddry, Shivaansh Kapoor
/// @dev A simple factory for creating Points Programs
contract PointsFactory is Ownable2Step {
    /// @notice Mapping of Points Program address => bool (indicator of if Points Program was deployed using this factory)
    mapping(address => bool) public isPointsProgram;

    /// @notice Mapping of RecipeMarketHub address => bool (indicator of if the address is of a Royco RecipeMarketHub)
    mapping(address => bool) public isRecipeMarketHub;

    /// @notice Emitted when creating a points program using this factory
    event NewPointsProgram(Points indexed points, string indexed name, string indexed symbol);

    /// @notice Emitted when adding an RecipeMarketHub to this Points Factory
    event RecipeMarketHubAdded(address indexed recipeMarketHub);

    /// @param _owner The owner of the points factory - responsible for adding valid RecipeMarketHub(s) to the PointsFactory
    constructor(address _owner) Ownable(_owner) { }

    /// @param _recipeMarketHub The RecipeMarketHub to mark as valid in the Points Factory
    function addRecipeMarketHub(address _recipeMarketHub) external onlyOwner {
        isRecipeMarketHub[_recipeMarketHub] = true;
        emit RecipeMarketHubAdded(_recipeMarketHub);
    }

    /// @param _name The name for the new points program
    /// @param _symbol The symbol for the new points program
    /// @param _decimals The amount of decimals per point
    /// @param _owner The owner of the new points program
    function createPointsProgram(string memory _name, string memory _symbol, uint256 _decimals, address _owner) external returns (Points points) {
        bytes32 salt = keccak256(abi.encode(_name, _symbol, _decimals, _owner));
        points = new Points{ salt: salt }(_name, _symbol, _decimals, _owner);
        isPointsProgram[address(points)] = true;

        emit NewPointsProgram(points, _name, _symbol);
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import { RecipeMarketHubBase, RewardStyle, WeirollWallet } from "src/base/RecipeMarketHubBase.sol";
import { ERC20 } from "lib/solmate/src/tokens/ERC20.sol";
import { ERC4626 } from "lib/solmate/src/tokens/ERC4626.sol";
import { ClonesWithImmutableArgs } from "lib/clones-with-immutable-args/src/ClonesWithImmutableArgs.sol";
import { SafeTransferLib } from "lib/solmate/src/utils/SafeTransferLib.sol";
import { FixedPointMathLib } from "lib/solmate/src/utils/FixedPointMathLib.sol";
import { Points } from "src/Points.sol";
import { PointsFactory } from "src/PointsFactory.sol";
import { Owned } from "lib/solmate/src/auth/Owned.sol";

/// @title RecipeMarketHub
/// @author Jack Corddry, CopyPaste, Shivaansh Kapoor
/// @notice RecipeMarketHub contract for Incentivizing AP/IPs to participate in "recipe" markets which perform arbitrary actions
contract RecipeMarketHub is RecipeMarketHubBase {
    using ClonesWithImmutableArgs for address;
    using SafeTransferLib for ERC20;
    using FixedPointMathLib for uint256;

    /// @param _weirollWalletImplementation The address of the WeirollWallet implementation contract
    /// @param _protocolFee The percent deducted from the IP's incentive amount and claimable by protocolFeeClaimant
    /// @param _minimumFrontendFee The minimum frontend fee that a market can set
    /// @param _owner The address that will be set as the owner of the contract
    constructor(
        address _weirollWalletImplementation,
        uint256 _protocolFee,
        uint256 _minimumFrontendFee,
        address _owner,
        address _pointsFactory
    )
        payable
        Owned(_owner)
    {
        WEIROLL_WALLET_IMPLEMENTATION = _weirollWalletImplementation;
        POINTS_FACTORY = _pointsFactory;
        protocolFee = _protocolFee;
        protocolFeeClaimant = _owner;
        minimumFrontendFee = _minimumFrontendFee;
    }

    /// @notice Create a new recipe market
    /// @param inputToken The token that will be deposited into the user's weiroll wallet for use in the recipe
    /// @param lockupTime The time in seconds that the user's weiroll wallet will be locked up for after deposit
    /// @param frontendFee The fee that the frontend will take from the user's weiroll wallet, 1e18 == 100% fee
    /// @param depositRecipe The weiroll script that will be executed after the inputToken is transferred to the wallet
    /// @param withdrawRecipe The weiroll script that may be executed after lockupTime has passed to unwind a user's position
    /// @custom:field rewardStyle Whether the rewards are paid at the beginning, locked until the end, or forfeitable until the end
    /// @return marketHash The hash of the newly created market
    function createMarket(
        address inputToken,
        uint256 lockupTime,
        uint256 frontendFee,
        Recipe calldata depositRecipe,
        Recipe calldata withdrawRecipe,
        RewardStyle rewardStyle
    )
        external
        payable
        returns (bytes32 marketHash)
    {
        // Check that the input token is not the zero address
        if (inputToken == address(0)) {
            revert InvalidMarketInputToken();
        }
        // Check that the frontend fee is at least the global minimum
        if (frontendFee < minimumFrontendFee) {
            revert FrontendFeeTooLow();
        }
        // Check that the sum of fees isn't too high
        if ((frontendFee + protocolFee) > 1e18) {
            revert TotalFeeTooHigh();
        }

        WeirollMarket memory market = WeirollMarket(numMarkets, ERC20(inputToken), lockupTime, frontendFee, depositRecipe, withdrawRecipe, rewardStyle);
        marketHash = getMarketHash(market);
        marketHashToWeirollMarket[marketHash] = market;

        emit MarketCreated(numMarkets, marketHash, inputToken, lockupTime, frontendFee, rewardStyle);

        numMarkets++;
    }

    /// @notice Create a new AP offer. Offer params will be emitted in an event while only the hash of the offer and offer quantity is stored onchain
    /// @dev AP offers are funded via approvals to ensure multiple offers can be placed off of a single input
    /// @dev Setting an expiry of 0 means the offer never expires
    /// @param targetMarketHash The hash of the weiroll market to create the AP offer for
    /// @param fundingVault The address of the vault where the input tokens will be withdrawn from, if set to 0, the AP will deposit the base asset directly
    /// @param quantity The total amount of input tokens to be deposited
    /// @param expiry The timestamp after which the offer is considered expired
    /// @param incentivesRequested The addresses of the incentives requested by the AP to satisfy the offer
    /// @param incentiveAmountsRequested The amount of each incentive requested by the AP to satisfy the offer
    /// @return offerHash The hash of the AP offer created
    function createAPOffer(
        bytes32 targetMarketHash,
        address fundingVault,
        uint256 quantity,
        uint256 expiry,
        address[] calldata incentivesRequested,
        uint256[] calldata incentiveAmountsRequested
    )
        external
        payable
        returns (bytes32 offerHash)
    {
        // Retrieve the target market
        WeirollMarket storage targetMarket = marketHashToWeirollMarket[targetMarketHash];

        // Check that the market exists
        if (address(targetMarket.inputToken) == address(0)) {
            revert MarketDoesNotExist();
        }
        // Check offer isn't expired (expiries of 0 live forever)
        if (expiry != 0 && expiry < block.timestamp) {
            revert CannotPlaceExpiredOffer();
        }
        // Check offer isn't empty
        if (quantity < MINIMUM_QUANTITY) {
            revert CannotPlaceZeroQuantityOffer();
        }
        // Check incentive and amounts arrays are the same length
        if (incentivesRequested.length != incentiveAmountsRequested.length) {
            revert ArrayLengthMismatch();
        }
        address lastIncentive;
        for (uint256 i; i < incentivesRequested.length; i++) {
            address incentive = incentivesRequested[i];
            if (uint256(bytes32(bytes20(incentive))) <= uint256(bytes32(bytes20(lastIncentive)))) {
                revert OfferCannotContainDuplicates();
            }
            lastIncentive = incentive;
        }

        // NOTE: The cool use of short-circuit means this call can't revert if fundingVault doesn't support asset()
        if (fundingVault != address(0) && targetMarket.inputToken != ERC4626(fundingVault).asset()) {
            revert MismatchedBaseAsset();
        }

        // Map the offer hash to the offer quantity
        APOffer memory offer =
            APOffer(numAPOffers, targetMarketHash, msg.sender, fundingVault, quantity, expiry, incentivesRequested, incentiveAmountsRequested);
        offerHash = getAPOfferHash(offer);
        offerHashToRemainingQuantity[offerHash] = quantity;

        /// @dev APOffer events are stored in events and do not exist onchain outside of the offerHashToRemainingQuantity mapping
        emit APOfferCreated(numAPOffers, targetMarketHash, msg.sender, fundingVault, quantity, incentivesRequested, incentiveAmountsRequested, expiry);

        // Increment the number of AP offers created
        numAPOffers++;
    }

    /// @notice Create a new IP offer, transferring the IP's incentives to the RecipeMarketHub and putting all the offer params in contract storage
    /// @dev IP must approve all incentives to be spent by the RecipeMarketHub before calling this function
    /// @param targetMarketHash The hash of the weiroll market to create the IP offer for
    /// @param quantity The total amount of input tokens to be deposited
    /// @param expiry The timestamp after which the offer is considered expired
    /// @param incentivesOffered The addresses of the incentives offered by the IP
    /// @param incentiveAmountsPaid The amount of each incentives paid by the IP (including fees)
    /// @return offerHash The hash of the IP offer created
    function createIPOffer(
        bytes32 targetMarketHash,
        uint256 quantity,
        uint256 expiry,
        address[] calldata incentivesOffered,
        uint256[] calldata incentiveAmountsPaid
    )
        external
        payable
        nonReentrant
        returns (bytes32 offerHash)
    {
        // Retrieve the target market
        WeirollMarket storage targetMarket = marketHashToWeirollMarket[targetMarketHash];

        // Check that the market exists
        if (address(targetMarket.inputToken) == address(0)) {
            revert MarketDoesNotExist();
        }
        // Check that the offer isn't expired
        if (expiry != 0 && expiry < block.timestamp) {
            revert CannotPlaceExpiredOffer();
        }

        // Check that the incentives and amounts arrays are the same length
        if (incentivesOffered.length != incentiveAmountsPaid.length) {
            revert ArrayLengthMismatch();
        }

        // Check offer isn't empty
        if (quantity < MINIMUM_QUANTITY) {
            revert CannotPlaceZeroQuantityOffer();
        }

        // To keep track of incentives allocated to the AP and fees (per incentive)
        uint256[] memory incentiveAmountsOffered = new uint256[](incentivesOffered.length);
        uint256[] memory protocolFeesToBePaid = new uint256[](incentivesOffered.length);
        uint256[] memory frontendFeesToBePaid = new uint256[](incentivesOffered.length);

        // Transfer the IP's incentives to the RecipeMarketHub and set aside fees
        address lastIncentive;
        for (uint256 i = 0; i < incentivesOffered.length; ++i) {
            // Get the incentive offered
            address incentive = incentivesOffered[i];

            // Check that the sorted incentive array has no duplicates
            if (uint256(bytes32(bytes20(incentive))) <= uint256(bytes32(bytes20(lastIncentive)))) {
                revert OfferCannotContainDuplicates();
            }
            lastIncentive = incentive;

            // Total amount IP is paying in this incentive including fees
            uint256 amount = incentiveAmountsPaid[i];

            // Get the frontend fee for the target weiroll market
            uint256 frontendFee = targetMarket.frontendFee;

            // Calculate incentive and fee breakdown
            uint256 incentiveAmount = amount.divWadDown(1e18 + protocolFee + frontendFee);
            uint256 protocolFeeAmount = incentiveAmount.mulWadDown(protocolFee);
            uint256 frontendFeeAmount = incentiveAmount.mulWadDown(frontendFee);

            // Use a scoping block to avoid stack to deep errors
            {
                // Track incentive amounts and fees (per incentive)
                incentiveAmountsOffered[i] = incentiveAmount;
                protocolFeesToBePaid[i] = protocolFeeAmount;
                frontendFeesToBePaid[i] = frontendFeeAmount;
            }

            // Check if incentive is a points program
            if (PointsFactory(POINTS_FACTORY).isPointsProgram(incentive)) {
                // If points incentive, make sure:
                // 1. The points factory used to create the program is the same as this RecipeMarketHubs PF
                // 2. IP placing the offer can award points
                // 3. Points factory has this RecipeMarketHub marked as a valid RO - can be assumed true
                if (POINTS_FACTORY != address(Points(incentive).pointsFactory()) || !Points(incentive).allowedIPs(msg.sender)) {
                    revert InvalidPointsProgram();
                }
            } else {
                // SafeTransferFrom does not check if a incentive address has any code, so we need to check it manually to prevent incentive deployment
                // frontrunning
                if (incentive.code.length == 0) revert TokenDoesNotExist();
                // Transfer frontend fee + protocol fee + incentiveAmount of the incentive to RecipeMarketHub
                ERC20(incentive).safeTransferFrom(msg.sender, address(this), incentiveAmount + protocolFeeAmount + frontendFeeAmount);
            }
        }

        // Set the offer hash
        offerHash = getIPOfferHash(numIPOffers, targetMarketHash, msg.sender, expiry, quantity, incentivesOffered, incentiveAmountsOffered);
        // Create and store the offer
        IPOffer storage offer = offerHashToIPOffer[offerHash];
        offer.offerID = numIPOffers;
        offer.targetMarketHash = targetMarketHash;
        offer.ip = msg.sender;
        offer.quantity = quantity;
        offer.remainingQuantity = quantity;
        offer.expiry = expiry;
        offer.incentivesOffered = incentivesOffered;

        // Set incentives and fees in the offer mapping
        for (uint256 i = 0; i < incentivesOffered.length; ++i) {
            address incentive = incentivesOffered[i];

            offer.incentiveAmountsOffered[incentive] = incentiveAmountsOffered[i];
            offer.incentiveToProtocolFeeAmount[incentive] = protocolFeesToBePaid[i];
            offer.incentiveToFrontendFeeAmount[incentive] = frontendFeesToBePaid[i];
        }

        // Emit IP offer creation event
        emit IPOfferCreated(
            numIPOffers,
            offerHash,
            targetMarketHash,
            msg.sender,
            quantity,
            incentivesOffered,
            incentiveAmountsOffered,
            protocolFeesToBePaid,
            frontendFeesToBePaid,
            expiry
        );

        // Increment the number of IP offers created
        numIPOffers++;
    }

    /// @param incentiveToken The incentive token to claim fees for
    /// @param to The address to send fees claimed to
    function claimFees(address incentiveToken, address to) external payable {
        uint256 amount = feeClaimantToTokenToAmount[msg.sender][incentiveToken];
        delete feeClaimantToTokenToAmount[msg.sender][incentiveToken];
        ERC20(incentiveToken).safeTransfer(to, amount);
        emit FeesClaimed(msg.sender, incentiveToken, amount);
    }

    /// @notice Filling multiple IP offers
    /// @param ipOfferHashes The hashes of the IP offers to fill
    /// @param fillAmounts The amounts of input tokens to fill the corresponding offers with
    /// @param fundingVault The address of the vault where the input tokens will be withdrawn from (vault not used if set to address(0))
    /// @param frontendFeeRecipient The address that will receive the frontend fee
    function fillIPOffers(
        bytes32[] calldata ipOfferHashes,
        uint256[] calldata fillAmounts,
        address fundingVault,
        address frontendFeeRecipient
    )
        external
        payable
        nonReentrant
        offersNotPaused
    {
        if (ipOfferHashes.length != fillAmounts.length) {
            revert ArrayLengthMismatch();
        }

        for (uint256 i = 0; i < ipOfferHashes.length; ++i) {
            _fillIPOffer(ipOfferHashes[i], fillAmounts[i], fundingVault, frontendFeeRecipient);
        }
    }

    /// @notice Fill an IP offer, transferring the IP's incentives to the AP, withdrawing the AP from their funding vault into a fresh weiroll wallet, and
    /// executing the weiroll recipe
    /// @param offerHash The hash of the IP offer to fill
    /// @param fillAmount The amount of input tokens to fill the offer with
    /// @param fundingVault The address of the vault where the input tokens will be withdrawn from (vault not used if set to address(0))
    /// @param frontendFeeRecipient The address that will receive the frontend fee
    function _fillIPOffer(bytes32 offerHash, uint256 fillAmount, address fundingVault, address frontendFeeRecipient) internal {
        // Retreive the IPOffer and WeirollMarket structs
        IPOffer storage offer = offerHashToIPOffer[offerHash];
        WeirollMarket storage market = marketHashToWeirollMarket[offer.targetMarketHash];

        // Check that the offer isn't expired
        if (offer.expiry != 0 && block.timestamp > offer.expiry) {
            revert OfferExpired();
        }
        // Check that the offer has enough remaining quantity
        if (offer.remainingQuantity < fillAmount && fillAmount != type(uint256).max) {
            revert NotEnoughRemainingQuantity();
        }
        if (fillAmount == type(uint256).max) {
            fillAmount = offer.remainingQuantity;
        }
        // Check that the offer's base asset matches the market's base asset
        if (fundingVault != address(0) && market.inputToken != ERC4626(fundingVault).asset()) {
            revert MismatchedBaseAsset();
        }
        // Check that the offer isn't empty
        if (fillAmount == 0) {
            revert CannotPlaceZeroQuantityOffer();
        }

        // Update the offer's remaining quantity before interacting with external contracts
        offer.remainingQuantity -= fillAmount;

        WeirollWallet wallet;
        {
            // Use a scoping block to avoid stack too deep
            bool forfeitable = market.rewardStyle == RewardStyle.Forfeitable;
            uint256 unlockTime = block.timestamp + market.lockupTime;

            // Create weiroll wallet to lock assets for recipe execution(s)
            wallet = WeirollWallet(
                payable(
                    WEIROLL_WALLET_IMPLEMENTATION.clone(
                        abi.encodePacked(msg.sender, address(this), fillAmount, unlockTime, forfeitable, offer.targetMarketHash)
                    )
                )
            );
        }

        // Number of incentives offered by the IP
        uint256 numIncentives = offer.incentivesOffered.length;

        // Arrays to store incentives and fee amounts to be paid
        uint256[] memory incentiveAmountsPaid = new uint256[](numIncentives);
        uint256[] memory protocolFeesPaid = new uint256[](numIncentives);
        uint256[] memory frontendFeesPaid = new uint256[](numIncentives);

        // Perform incentive accounting on a per incentive basis
        for (uint256 i = 0; i < numIncentives; ++i) {
            // Calculate the percentage of the offer the AP is filling
            uint256 fillPercentage = fillAmount.divWadDown(offer.quantity);
            // Incentive address
            address incentive = offer.incentivesOffered[i];

            // Calculate fees to take based on percentage of fill
            protocolFeesPaid[i] = offer.incentiveToProtocolFeeAmount[incentive].mulWadDown(fillPercentage);
            frontendFeesPaid[i] = offer.incentiveToFrontendFeeAmount[incentive].mulWadDown(fillPercentage);

            // Calculate incentives to give based on percentage of fill
            incentiveAmountsPaid[i] = offer.incentiveAmountsOffered[incentive].mulWadDown(fillPercentage);

            if (market.rewardStyle == RewardStyle.Upfront) {
                // Push incentives to AP and account fees on fill in an upfront market
                _pushIncentivesAndAccountFees(
                    incentive, msg.sender, incentiveAmountsPaid[i], protocolFeesPaid[i], frontendFeesPaid[i], offer.ip, frontendFeeRecipient
                );
            }
        }

        if (market.rewardStyle != RewardStyle.Upfront) {
            // If RewardStyle is either Forfeitable or Arrear
            // Create locked rewards params to account for payouts upon wallet unlocking
            LockedRewardParams storage params = weirollWalletToLockedIncentivesParams[address(wallet)];
            params.incentives = offer.incentivesOffered;
            params.amounts = incentiveAmountsPaid;
            params.ip = offer.ip;
            params.frontendFeeRecipient = frontendFeeRecipient;
            params.wasIPOffer = true;
            params.offerHash = offerHash;
        }

        // Fund the weiroll wallet with the specified amount of the market's input token
        // Will use the funding vault if specified or will fund directly from the AP
        _fundWeirollWallet(fundingVault, msg.sender, market.inputToken, fillAmount, address(wallet));

        // Execute deposit recipe
        wallet.executeWeiroll(market.depositRecipe.weirollCommands, market.depositRecipe.weirollState);

        emit IPOfferFilled(offerHash, msg.sender, fillAmount, address(wallet), incentiveAmountsPaid, protocolFeesPaid, frontendFeesPaid);
    }

    /// @dev Fill multiple AP offers
    /// @param offers The AP offers to fill
    /// @param fillAmounts The amount of input tokens to fill the corresponding offer with
    /// @param frontendFeeRecipient The address that will receive the frontend fee
    function fillAPOffers(
        APOffer[] calldata offers,
        uint256[] calldata fillAmounts,
        address frontendFeeRecipient
    )
        external
        payable
        nonReentrant
        offersNotPaused
    {
        if (offers.length != fillAmounts.length) {
            revert ArrayLengthMismatch();
        }

        for (uint256 i = 0; i < offers.length; ++i) {
            _fillAPOffer(offers[i], fillAmounts[i], frontendFeeRecipient);
        }
    }

    /// @dev Fill an AP offer
    /// @dev IP must approve all incentives to be spent (both fills + fees!) by the RecipeMarketHub before calling this function.
    /// @param offer The AP offer to fill
    /// @param fillAmount The amount of input tokens to fill the offer with
    /// @param frontendFeeRecipient The address that will receive the frontend fee
    function _fillAPOffer(APOffer calldata offer, uint256 fillAmount, address frontendFeeRecipient) internal {
        if (offer.expiry != 0 && block.timestamp > offer.expiry) {
            revert OfferExpired();
        }

        bytes32 offerHash = getAPOfferHash(offer);

        uint256 remaining = offerHashToRemainingQuantity[offerHash];
        if (fillAmount > remaining) {
            if (fillAmount != type(uint256).max) {
                revert NotEnoughRemainingQuantity();
            }
            fillAmount = remaining;
        }

        if (fillAmount == 0) {
            revert CannotFillZeroQuantityOffer();
        }

        // Adjust remaining offer quantity by amount filled
        offerHashToRemainingQuantity[offerHash] -= fillAmount;

        // Calculate percentage of AP oder that IP is filling (IP gets this percantage of the offer quantity in a Weiroll wallet specified by the market)
        uint256 fillPercentage = fillAmount.divWadDown(offer.quantity);

        if (fillPercentage < MIN_FILL_PERCENT && fillAmount != remaining) revert InsufficientFillPercent();

        // Get Weiroll market
        WeirollMarket storage market = marketHashToWeirollMarket[offer.targetMarketHash];

        WeirollWallet wallet;
        {
            // Create weiroll wallet to lock assets for recipe execution(s)
            uint256 unlockTime = block.timestamp + market.lockupTime;
            bool forfeitable = market.rewardStyle == RewardStyle.Forfeitable;
            wallet = WeirollWallet(
                payable(
                    WEIROLL_WALLET_IMPLEMENTATION.clone(abi.encodePacked(offer.ap, address(this), fillAmount, unlockTime, forfeitable, offer.targetMarketHash))
                )
            );
        }

        // Number of incentives requested by the AP
        uint256 numIncentives = offer.incentivesRequested.length;

        // Arrays to store incentives and fee amounts to be paid
        uint256[] memory incentiveAmountsPaid = new uint256[](numIncentives);
        uint256[] memory protocolFeesPaid = new uint256[](numIncentives);
        uint256[] memory frontendFeesPaid = new uint256[](numIncentives);

        // Fees at the time of fill
        uint256 protocolFeeAtFill = protocolFee;
        uint256 marketFrontendFee = market.frontendFee;

        for (uint256 i = 0; i < numIncentives; ++i) {
            // Incentive requested by AP
            address incentive = offer.incentivesRequested[i];

            // This is the incentive amount allocated to the AP
            uint256 incentiveAmount = offer.incentiveAmountsRequested[i].mulWadDown(fillPercentage);
            // Check that the incentives allocated to the AP are non-zero
            if (incentiveAmount == 0) {
                revert NoIncentivesPaidOnFill();
            }
            incentiveAmountsPaid[i] = incentiveAmount;

            // Calculate fees based on fill percentage. These fees will be taken on top of the AP's requested amount.
            protocolFeesPaid[i] = incentiveAmount.mulWadDown(protocolFeeAtFill);
            frontendFeesPaid[i] = incentiveAmount.mulWadDown(marketFrontendFee);

            // Pull incentives from IP and account fees
            _pullIncentivesOnAPFill(incentive, incentiveAmount, protocolFeesPaid[i], frontendFeesPaid[i], offer.ap, frontendFeeRecipient, market.rewardStyle);
        }

        if (market.rewardStyle != RewardStyle.Upfront) {
            // If RewardStyle is either Forfeitable or Arrear
            // Create locked rewards params to account for payouts upon wallet unlocking
            LockedRewardParams storage params = weirollWalletToLockedIncentivesParams[address(wallet)];
            params.incentives = offer.incentivesRequested;
            params.amounts = incentiveAmountsPaid;
            params.ip = msg.sender;
            params.frontendFeeRecipient = frontendFeeRecipient;
            params.protocolFeeAtFill = protocolFeeAtFill;
            // Redundant: Make sure this is set to false in case of a forfeit
            delete params.wasIPOffer;
        }

        // Fund the weiroll wallet with the specified amount of the market's input token
        // Will use the funding vault if specified or will fund directly from the AP
        _fundWeirollWallet(offer.fundingVault, offer.ap, market.inputToken, fillAmount, address(wallet));

        // Execute deposit recipe
        wallet.executeWeiroll(market.depositRecipe.weirollCommands, market.depositRecipe.weirollState);

        emit APOfferFilled(offer.offerID, msg.sender, fillAmount, address(wallet), incentiveAmountsPaid, protocolFeesPaid, frontendFeesPaid);
    }

    /// @notice Cancel an AP offer, setting the remaining quantity available to fill to 0
    function cancelAPOffer(APOffer calldata offer) external payable {
        // Check that the cancelling party is the offer's owner
        if (offer.ap != msg.sender) revert NotOwner();

        // Check that the offer isn't already filled, hasn't been cancelled already, or never existed
        bytes32 offerHash = getAPOfferHash(offer);
        if (offerHashToRemainingQuantity[offerHash] == 0) {
            revert NotEnoughRemainingQuantity();
        }

        // Set remaining quantity to 0 - effectively cancelling the offer
        delete offerHashToRemainingQuantity[offerHash];

        emit APOfferCancelled(offer.offerID);
    }

    /// @notice Cancel an IP offer, setting the remaining quantity available to fill to 0 and returning the IP's incentives
    function cancelIPOffer(bytes32 offerHash) external payable nonReentrant {
        IPOffer storage offer = offerHashToIPOffer[offerHash];

        // Check that the cancelling party is the offer's owner
        if (offer.ip != msg.sender) revert NotOwner();

        // Check that the offer isn't already filled, hasn't been cancelled already, or never existed
        if (offer.remainingQuantity == 0) revert NotEnoughRemainingQuantity();

        RewardStyle marketRewardStyle = marketHashToWeirollMarket[offer.targetMarketHash].rewardStyle;
        // Check the percentage of the offer not filled to calculate incentives to return
        uint256 percentNotFilled = offer.remainingQuantity.divWadDown(offer.quantity);

        // Transfer the remaining incentives back to the IP
        for (uint256 i = 0; i < offer.incentivesOffered.length; ++i) {
            address incentive = offer.incentivesOffered[i];
            if (!PointsFactory(POINTS_FACTORY).isPointsProgram(offer.incentivesOffered[i])) {
                // Calculate the incentives which are still available for refunding the IP
                uint256 incentivesRemaining = offer.incentiveAmountsOffered[incentive].mulWadDown(percentNotFilled);

                // Calculate the unused fee amounts to refunding to the IP
                uint256 unchargedFrontendFeeAmount = offer.incentiveToFrontendFeeAmount[incentive].mulWadDown(percentNotFilled);
                uint256 unchargedProtocolFeeAmount = offer.incentiveToProtocolFeeAmount[incentive].mulWadDown(percentNotFilled);

                // Transfer reimbursements to the IP
                ERC20(incentive).safeTransfer(offer.ip, (incentivesRemaining + unchargedFrontendFeeAmount + unchargedProtocolFeeAmount));
            }

            /// Delete cancelled fields of dynamic arrays and mappings
            delete offer.incentivesOffered[i];
            delete offer.incentiveAmountsOffered[incentive];

            if (marketRewardStyle == RewardStyle.Upfront) {
                // Need these on forfeit and claim for forfeitable and arrear markets
                // Safe to delete for Upfront markets
                delete offer.incentiveToProtocolFeeAmount[incentive];
                delete offer.incentiveToFrontendFeeAmount[incentive];
            }
        }

        if (marketRewardStyle != RewardStyle.Upfront) {
            // Need quantity to take the fees on forfeit and claim - don't delete
            // Need expiry to check offer expiry status on forfeit - don't delete
            // Delete the rest of the fields to indicate the offer was cancelled on forfeit
            delete offerHashToIPOffer[offerHash].targetMarketHash;
            delete offerHashToIPOffer[offerHash].ip;
            delete offerHashToIPOffer[offerHash].remainingQuantity;
        } else {
            // Delete cancelled offer completely from mapping if the market's RewardStyle is Upfront
            delete offerHashToIPOffer[offerHash];
        }

        emit IPOfferCancelled(offerHash);
    }

    /// @notice For wallets of Forfeitable markets, an AP can call this function to forgo their rewards and unlock their wallet
    function forfeit(address weirollWallet, bool executeWithdrawal) external payable isWeirollOwner(weirollWallet) nonReentrant {
        // Instantiate a weiroll wallet for the specified address
        WeirollWallet wallet = WeirollWallet(payable(weirollWallet));

        // Check that the wallet is forfeitable
        if (!wallet.isForfeitable()) {
            revert WalletNotForfeitable();
        }

        // Get locked reward params
        LockedRewardParams storage params = weirollWalletToLockedIncentivesParams[weirollWallet];

        // Forfeit wallet
        wallet.forfeit();

        // Setting this option to false allows the AP to be able to forfeit even when the withdrawal script is reverting
        if (executeWithdrawal) {
            // Execute the withdrawal script if flag set to true
            _executeWithdrawalScript(weirollWallet);
        }

        // Check if IP offer
        // If not, the forfeited amount won't be replenished to the offer
        if (params.wasIPOffer) {
            // Retrieve IP offer if it was one
            IPOffer storage offer = offerHashToIPOffer[params.offerHash];

            // Get amount filled by AP
            uint256 filledAmount = wallet.amount();

            // If IP address is 0, offer has been cancelled
            if (offer.ip == address(0) || (offer.expiry != 0 && offer.expiry < block.timestamp)) {
                // Cancelled or expired offer - return incentives that were originally held for the AP to the IP and take the fees
                uint256 fillPercentage = filledAmount.divWadDown(offer.quantity);

                // Get the ip from locked reward params
                address ip = params.ip;

                for (uint256 i = 0; i < params.incentives.length; ++i) {
                    address incentive = params.incentives[i];

                    // Calculate protocol fee to take based on percentage of fill
                    uint256 protocolFeeAmount = offer.incentiveToProtocolFeeAmount[incentive].mulWadDown(fillPercentage);
                    // Take protocol fee
                    _accountFee(protocolFeeClaimant, incentive, protocolFeeAmount, ip);

                    if (!PointsFactory(POINTS_FACTORY).isPointsProgram(incentive)) {
                        // Calculate frontend fee to refund to the IP on forfeit
                        uint256 frontendFeeAmount = offer.incentiveToFrontendFeeAmount[incentive].mulWadDown(fillPercentage);
                        // Refund incentive tokens and frontend fee to IP. Points don't need to be refunded.
                        ERC20(incentive).safeTransfer(ip, params.amounts[i] + frontendFeeAmount);
                    }

                    // Delete forfeited incentives and corresponding amounts from locked reward params
                    delete params.incentives[i];
                    delete params.amounts[i];

                    // Can't delete since there might be more forfeitable wallets still locked and we need to take fees on claim
                    // delete offer.incentiveToProtocolFeeAmount[incentive];
                    // delete offer.incentiveToFrontendFeeAmount[incentive];
                }
                // Can't delete since there might be more forfeitable wallets still locked
                // delete offerHashToIPOffer[params.offerHash];
            } else {
                // If not cancelled, add the filledAmount back to remaining quantity
                // Correct incentive amounts are still in this contract
                offer.remainingQuantity += filledAmount;

                // Delete forfeited incentives and corresponding amounts from locked reward params
                for (uint256 i = 0; i < params.incentives.length; ++i) {
                    delete params.incentives[i];
                    delete params.amounts[i];
                }
            }
        } else {
            // Get the protocol fee at fill and market frontend fee
            uint256 protocolFeeAtFill = params.protocolFeeAtFill;
            uint256 marketFrontendFee = marketHashToWeirollMarket[wallet.marketHash()].frontendFee;
            // Get the ip from locked reward params
            address ip = params.ip;

            // If offer was an AP offer, return the incentives to the IP and take the fee
            for (uint256 i = 0; i < params.incentives.length; ++i) {
                address incentive = params.incentives[i];
                uint256 amount = params.amounts[i];

                // Calculate fees to take based on percentage of fill
                uint256 protocolFeeAmount = amount.mulWadDown(protocolFeeAtFill);
                // Take fees
                _accountFee(protocolFeeClaimant, incentive, protocolFeeAmount, ip);

                if (!PointsFactory(POINTS_FACTORY).isPointsProgram(incentive)) {
                    // Calculate frontend fee to refund to the IP on forfeit
                    uint256 frontendFeeAmount = amount.mulWadDown(marketFrontendFee);
                    // Refund incentive tokens and frontend fee to IP. Points don't need to be refunded.
                    ERC20(incentive).safeTransfer(ip, amount + frontendFeeAmount);
                }

                // Delete forfeited incentives and corresponding amounts from locked reward params
                delete params.incentives[i];
                delete params.amounts[i];
            }
        }

        // Zero out the mapping
        delete weirollWalletToLockedIncentivesParams[weirollWallet];

        emit WeirollWalletForfeited(weirollWallet);
    }

    /// @notice Execute the withdrawal script in the weiroll wallet
    function executeWithdrawalScript(address weirollWallet) external payable isWeirollOwner(weirollWallet) weirollIsUnlocked(weirollWallet) nonReentrant {
        _executeWithdrawalScript(weirollWallet);
    }

    /// @param weirollWallet The wallet to claim for
    /// @param to The address to send the incentive to
    function claim(address weirollWallet, address to) external payable isWeirollOwner(weirollWallet) weirollIsUnlocked(weirollWallet) nonReentrant {
        // Get locked reward details to facilitate claim
        LockedRewardParams storage params = weirollWalletToLockedIncentivesParams[weirollWallet];

        // Instantiate a weiroll wallet for the specified address
        WeirollWallet wallet = WeirollWallet(payable(weirollWallet));

        // Get the frontend fee recipient and ip from locked reward params
        address frontendFeeRecipient = params.frontendFeeRecipient;
        address ip = params.ip;

        if (params.wasIPOffer) {
            // If it was an ipoffer, get the offer so we can retrieve the fee amounts and fill quantity
            IPOffer storage offer = offerHashToIPOffer[params.offerHash];

            uint256 fillAmount = wallet.amount();
            uint256 fillPercentage = fillAmount.divWadDown(offer.quantity);

            for (uint256 i = 0; i < params.incentives.length; ++i) {
                address incentive = params.incentives[i];

                // Calculate fees to take based on percentage of fill
                uint256 protocolFeeAmount = offer.incentiveToProtocolFeeAmount[incentive].mulWadDown(fillPercentage);
                uint256 frontendFeeAmount = offer.incentiveToFrontendFeeAmount[incentive].mulWadDown(fillPercentage);

                // Reward incentives to AP upon claim and account fees
                _pushIncentivesAndAccountFees(incentive, to, params.amounts[i], protocolFeeAmount, frontendFeeAmount, ip, frontendFeeRecipient);

                emit WeirollWalletClaimedIncentive(weirollWallet, to, incentive);

                /// Delete fields of dynamic arrays and mappings
                delete params.incentives[i];
                delete params.amounts[i];
            }
        } else {
            // Get the protocol fee at fill and market frontend fee
            uint256 protocolFeeAtFill = params.protocolFeeAtFill;
            uint256 marketFrontendFee = marketHashToWeirollMarket[wallet.marketHash()].frontendFee;

            for (uint256 i = 0; i < params.incentives.length; ++i) {
                address incentive = params.incentives[i];
                uint256 amount = params.amounts[i];

                // Calculate fees to take based on percentage of fill
                uint256 protocolFeeAmount = amount.mulWadDown(protocolFeeAtFill);
                uint256 frontendFeeAmount = amount.mulWadDown(marketFrontendFee);

                // Reward incentives to AP upon claim and account fees
                _pushIncentivesAndAccountFees(incentive, to, amount, protocolFeeAmount, frontendFeeAmount, ip, frontendFeeRecipient);

                emit WeirollWalletClaimedIncentive(weirollWallet, to, incentive);

                /// Delete fields of dynamic arrays and mappings
                delete params.incentives[i];
                delete params.amounts[i];
            }
        }

        // Zero out the mapping
        delete weirollWalletToLockedIncentivesParams[weirollWallet];
    }

    /// @param weirollWallet The wallet to claim for
    /// @param incentiveToken The incentiveToken to claim
    /// @param to The address to send the incentive to
    function claim(
        address weirollWallet,
        address incentiveToken,
        address to
    )
        external
        payable
        isWeirollOwner(weirollWallet)
        weirollIsUnlocked(weirollWallet)
        nonReentrant
    {
        // Get locked reward details to facilitate claim
        LockedRewardParams storage params = weirollWalletToLockedIncentivesParams[weirollWallet];

        // Instantiate a weiroll wallet for the specified address
        WeirollWallet wallet = WeirollWallet(payable(weirollWallet));

        // Get the frontend fee recipient and ip from locked reward params
        address frontendFeeRecipient = params.frontendFeeRecipient;
        address ip = params.ip;

        if (params.wasIPOffer) {
            // If it was an ipoffer, get the offer so we can retrieve the fee amounts and fill quantity
            IPOffer storage offer = offerHashToIPOffer[params.offerHash];

            // Calculate percentage of offer quantity this offer filled
            uint256 fillAmount = wallet.amount();
            uint256 fillPercentage = fillAmount.divWadDown(offer.quantity);

            for (uint256 i = 0; i < params.incentives.length; ++i) {
                address incentive = params.incentives[i];
                if (incentiveToken == incentive) {
                    // Calculate fees to take based on percentage of fill
                    uint256 protocolFeeAmount = offer.incentiveToProtocolFeeAmount[incentive].mulWadDown(fillPercentage);
                    uint256 frontendFeeAmount = offer.incentiveToFrontendFeeAmount[incentive].mulWadDown(fillPercentage);

                    // Reward incentives to AP upon claim and account fees
                    _pushIncentivesAndAccountFees(incentive, to, params.amounts[i], protocolFeeAmount, frontendFeeAmount, ip, frontendFeeRecipient);

                    emit WeirollWalletClaimedIncentive(weirollWallet, to, incentiveToken);

                    /// Delete fields of dynamic arrays and mappings once claimed
                    delete params.incentives[i];
                    delete params.amounts[i];

                    // Return upon claiming the incentive
                    return;
                }
            }
        } else {
            // Get the market frontend fee
            uint256 marketFrontendFee = marketHashToWeirollMarket[wallet.marketHash()].frontendFee;

            for (uint256 i = 0; i < params.incentives.length; ++i) {
                address incentive = params.incentives[i];
                if (incentiveToken == incentive) {
                    uint256 amount = params.amounts[i];

                    // Calculate fees to take based on percentage of fill
                    uint256 protocolFeeAmount = amount.mulWadDown(params.protocolFeeAtFill);
                    uint256 frontendFeeAmount = amount.mulWadDown(marketFrontendFee);

                    // Reward incentives to AP upon wallet unlock and account fees
                    _pushIncentivesAndAccountFees(incentive, to, amount, protocolFeeAmount, frontendFeeAmount, ip, frontendFeeRecipient);

                    emit WeirollWalletClaimedIncentive(weirollWallet, to, incentiveToken);

                    /// Delete fields of dynamic arrays and mappings
                    delete params.incentives[i];
                    delete params.amounts[i];

                    // Return upon claiming the incentive
                    return;
                }
            }
        }

        // This block will never get hit since array size doesn't get updated on delete
        // if (params.incentives.length == 0) {
        //     // Zero out the mapping if no more locked incentives to claim
        //     delete weirollWalletToLockedIncentivesParams[weirollWallet];
        // }
    }

    /// @param recipient The address to send fees to
    /// @param incentive The incentive address where fees are accrued in
    /// @param amount The amount of fees to award
    /// @param ip The incentive provider if awarding points
    function _accountFee(address recipient, address incentive, uint256 amount, address ip) internal {
        //check to see the incentive is actually a points campaign
        if (PointsFactory(POINTS_FACTORY).isPointsProgram(incentive)) {
            // Points cannot be claimed and are rather directly awarded
            Points(incentive).award(recipient, amount, ip);
        } else {
            feeClaimantToTokenToAmount[recipient][incentive] += amount;
        }
    }

    /// @param fundingVault The ERC4626 vault to fund the weiroll wallet with - if address(0) fund directly via AP
    /// @param ap The address of the AP to fund the weiroll wallet if no funding vault specified
    /// @param token The market input token to fund the weiroll wallet with
    /// @param amount The amount of market input token to fund the weiroll wallet with
    /// @param weirollWallet The weiroll wallet to fund with the specified amount of the market input token
    function _fundWeirollWallet(address fundingVault, address ap, ERC20 token, uint256 amount, address weirollWallet) internal {
        if (fundingVault == address(0)) {
            // If no fundingVault specified, fund the wallet directly from AP
            token.safeTransferFrom(ap, weirollWallet, amount);
        } else {
            // Withdraw the tokens from the funding vault into the wallet
            ERC4626(fundingVault).withdraw(amount, weirollWallet, ap);
            // Ensure that the Weiroll wallet received at least fillAmount of the inputToken from the AP provided vault
            if (token.balanceOf(weirollWallet) < amount) {
                revert WeirollWalletFundingFailed();
            }
        }
    }

    /**
     * @notice Handles the transfer and accounting of fees and incentives.
     * @dev This function is called internally to account fees and push incentives.
     * @param incentive The address of the incentive.
     * @param to The address of incentive recipient.
     * @param incentiveAmount The amount of the incentive token to be transferred.
     * @param protocolFeeAmount The protocol fee amount taken at fill.
     * @param frontendFeeAmount The frontend fee amount taken for this market.
     * @param ip The address of the action provider.
     * @param frontendFeeRecipient The address that will receive the frontend fee.
     */
    function _pushIncentivesAndAccountFees(
        address incentive,
        address to,
        uint256 incentiveAmount,
        uint256 protocolFeeAmount,
        uint256 frontendFeeAmount,
        address ip,
        address frontendFeeRecipient
    )
        internal
    {
        // Take fees
        _accountFee(protocolFeeClaimant, incentive, protocolFeeAmount, ip);
        _accountFee(frontendFeeRecipient, incentive, frontendFeeAmount, ip);

        // Push incentives to AP
        if (PointsFactory(POINTS_FACTORY).isPointsProgram(incentive)) {
            Points(incentive).award(to, incentiveAmount, ip);
        } else {
            ERC20(incentive).safeTransfer(to, incentiveAmount);
        }
    }

    /**
     * @notice Handles the transfer and accounting of fees and incentives for an AP offer fill.
     * @dev This function is called internally by `fillAPOffer` to manage the incentives.
     * @param incentive The address of the incentive.
     * @param incentiveAmount The amount of the incentive to be transferred.
     * @param protocolFeeAmount The protocol fee amount taken at fill.
     * @param frontendFeeAmount The frontend fee amount taken for this market.
     * @param ap The address of the action provider.
     * @param frontendFeeRecipient The address that will receive the frontend fee.
     * @param rewardStyle The style of reward distribution (Upfront, Arrear, Forfeitable).
     */
    function _pullIncentivesOnAPFill(
        address incentive,
        uint256 incentiveAmount,
        uint256 protocolFeeAmount,
        uint256 frontendFeeAmount,
        address ap,
        address frontendFeeRecipient,
        RewardStyle rewardStyle
    )
        internal
    {
        // msg.sender will always be IP
        if (rewardStyle == RewardStyle.Upfront) {
            // Take fees immediately from IP upon filling AP offers
            _accountFee(protocolFeeClaimant, incentive, protocolFeeAmount, msg.sender);
            _accountFee(frontendFeeRecipient, incentive, frontendFeeAmount, msg.sender);

            // Give incentives to AP immediately in an Upfront market
            if (PointsFactory(POINTS_FACTORY).isPointsProgram(incentive)) {
                // Award points on fill
                Points(incentive).award(ap, incentiveAmount, msg.sender);
            } else {
                // SafeTransferFrom does not check if a incentive address has any code, so we need to check it manually to prevent incentive deployment
                // frontrunning
                if (incentive.code.length == 0) {
                    revert TokenDoesNotExist();
                }
                // Transfer protcol and frontend fees to RecipeMarketHub for the claimants to withdraw them on-demand
                ERC20(incentive).safeTransferFrom(msg.sender, address(this), protocolFeeAmount + frontendFeeAmount);
                // Transfer AP's incentives to them on fill if token
                ERC20(incentive).safeTransferFrom(msg.sender, ap, incentiveAmount);
            }
        } else {
            // RewardStyle is Forfeitable or Arrear
            // If incentives will be paid out later, only handle the incentive case. Points will be awarded on claim.
            if (PointsFactory(POINTS_FACTORY).isPointsProgram(incentive)) {
                // If points incentive, make sure:
                // 1. The points factory used to create the program is the same as this RecipeMarketHubs PF
                // 2. IP placing the offer can award points
                // 3. Points factory has this RecipeMarketHub marked as a valid RO - can be assumed true
                if (POINTS_FACTORY != address(Points(incentive).pointsFactory()) || !Points(incentive).allowedIPs(msg.sender)) {
                    revert InvalidPointsProgram();
                }
            } else {
                // SafeTransferFrom does not check if a incentive address has any code, so we need to check it manually to prevent incentive deployment
                // frontrunning
                if (incentive.code.length == 0) {
                    revert TokenDoesNotExist();
                }
                // If not a points program, transfer amount requested (based on fill percentage) to the RecipeMarketHub in addition to protocol and frontend
                // fees.
                ERC20(incentive).safeTransferFrom(msg.sender, address(this), incentiveAmount + protocolFeeAmount + frontendFeeAmount);
            }
        }
    }

    /// @notice executes the withdrawal script for the provided weiroll wallet
    function _executeWithdrawalScript(address weirollWallet) internal {
        // Instantiate the WeirollWallet from the wallet address
        WeirollWallet wallet = WeirollWallet(payable(weirollWallet));

        // Get the market in offer to get the withdrawal recipe
        WeirollMarket storage market = marketHashToWeirollMarket[wallet.marketHash()];

        // Execute the withdrawal recipe
        wallet.executeWeiroll(market.withdrawRecipe.weirollCommands, market.withdrawRecipe.weirollState);

        emit WeirollWalletExecutedWithdrawal(weirollWallet);
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import { VM } from "lib/enso-weiroll/contracts/VM.sol";
import { Clone } from "lib/clones-with-immutable-args/src/Clone.sol";
import { IERC1271 } from "src/interfaces/IERC1271.sol";
import { ECDSA } from "lib/solady/src/utils/ECDSA.sol";

/// @title WeirollWallet
/// @author Jack Corddry, Shivaansh Kapoor, CopyPaste
/// @notice WeirollWallet implementation contract.
/// @notice Implements a simple smart contract wallet that can execute Weiroll VM commands
contract WeirollWallet is IERC1271, Clone, VM {
    // Returned to indicate a valid ERC1271 signature
    bytes4 internal constant ERC1271_MAGIC_VALUE = 0x1626ba7e; // bytes4(keccak256("isValidSignature(bytes32,bytes)")

    // Returned to indicate an invalid ERC1271 signature
    bytes4 internal constant INVALID_SIGNATURE = 0x00000000;

    /// @notice Let the Weiroll Wallet receive ether directly if needed
    receive() external payable { }
    /// @notice Also allow a fallback with no logic if erroneous data is provided
    fallback() external payable { }
    /*//////////////////////////////////////////////////////////////
                               MODIFIERS
    //////////////////////////////////////////////////////////////*/

    // Emit when owner executes an arbitrary script (not a market script)
    event WeirollWalletExecutedManually();

    error NotOwner();
    error NotRecipeMarketHub();
    error WalletLocked();
    error WalletNotForfeitable();
    error OfferUnfilled();
    error RawExecutionFailed();

    /// @notice Only the owner of the contract can call the function
    modifier onlyOwner() {
        if (msg.sender != owner()) {
            revert NotOwner();
        }
        _;
    }

    /// @notice Only the recipeMarketHub contract can call the function
    modifier onlyRecipeMarketHub() {
        if (msg.sender != recipeMarketHub()) {
            revert NotRecipeMarketHub();
        }
        _;
    }

    /// @notice The wallet can be locked
    modifier notLocked() {
        if (!forfeited && lockedUntil() > block.timestamp) {
            revert WalletLocked();
        }
        _;
    }

    /*//////////////////////////////////////////////////////////////
                               STATE VARIABLES
    //////////////////////////////////////////////////////////////*/

    /// @dev Whether or not this offer has been executed
    bool public executed;
    /// @dev Whether or not the wallet has been forfeited
    bool public forfeited;

    /// @notice Forfeit all rewards to get control of the wallet back
    function forfeit() public onlyRecipeMarketHub {
        if (!isForfeitable() || block.timestamp >= lockedUntil()) {
            // Can't forfeit if:
            // 1. Wallet not created through a forfeitable market
            // 2. Lock time has passed and claim window has started
            revert WalletNotForfeitable();
        }

        forfeited = true;
    }

    /// @notice The address of the offer creator (owner)
    function owner() public pure returns (address) {
        return _getArgAddress(0);
    }

    /// @notice The address of the RecipeMarketHub contract
    function recipeMarketHub() public pure returns (address) {
        return _getArgAddress(20);
    }

    /// @notice The amount of tokens deposited into this wallet from the recipeMarketHub
    function amount() public pure returns (uint256) {
        return _getArgUint256(40);
    }

    /// @notice The timestamp after which the wallet may be interacted with
    function lockedUntil() public pure returns (uint256) {
        return _getArgUint256(72);
    }

    /// @notice Returns whether or not the wallet is forfeitable
    function isForfeitable() public pure returns (bool) {
        return _getArgUint8(104) != 0;
    }

    /// @notice Returns the hash of the market associated with this weiroll wallet
    function marketHash() public pure returns (bytes32) {
        return bytes32(_getArgUint256(105));
    }

    /*//////////////////////////////////////////////////////////////
                               EXECUTION LOGIC
    //////////////////////////////////////////////////////////////*/
    /// @notice Execute the Weiroll VM with the given commands.
    /// @param commands The commands to be executed by the Weiroll VM.
    function executeWeiroll(bytes32[] calldata commands, bytes[] calldata state) public payable onlyRecipeMarketHub returns (bytes[] memory) {
        executed = true;
        // Execute the Weiroll VM.
        return _execute(commands, state);
    }

    /// @notice Execute the Weiroll VM with the given commands.
    /// @param commands The commands to be executed by the Weiroll VM.
    function manualExecuteWeiroll(bytes32[] calldata commands, bytes[] calldata state) public payable onlyOwner notLocked returns (bytes[] memory) {
        // Prevent people from approving w/e then rugging during vesting
        if (!executed) revert OfferUnfilled();

        emit WeirollWalletExecutedManually();
        // Execute the Weiroll VM.
        return _execute(commands, state);
    }

    /// @notice Execute a generic call to another contract.
    /// @param to The address to call
    /// @param value The ether value of the execution
    /// @param data The data to pass along with the call
    function execute(address to, uint256 value, bytes memory data) public payable onlyOwner notLocked returns (bytes memory) {
        // Prevent people from approving w/e then rugging during vesting
        if (!executed) revert OfferUnfilled();

        // Execute the call.
        (bool success, bytes memory result) = to.call{ value: value }(data);
        if (!success) revert RawExecutionFailed();

        emit WeirollWalletExecutedManually();
        return result;
    }

    /// @notice Check if signature is valid for this contract
    /// @dev Signature is valid if the signer is the owner of this wallet
    /// @param digest Hash of the message to validate the signature against
    /// @param signature Signature produced for the provided digest
    function isValidSignature(bytes32 digest, bytes calldata signature) external view returns (bytes4) {
        // Modify digest to include the chainId and address of this wallet to prevent replay attacks
        bytes32 walletSpecificDigest = keccak256(abi.encode(digest, block.chainid, address(this)));
        // Check if signature was produced by owner of this wallet
        // Don't revert on failure. Simply return INVALID_SIGNATURE.
        if (ECDSA.tryRecover(walletSpecificDigest, signature) == owner()) return ERC1271_MAGIC_VALUE;
        else return INVALID_SIGNATURE;
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import { ERC20 } from "lib/solmate/src/tokens/ERC20.sol";
import { WeirollWallet } from "src/WeirollWallet.sol";
import { ReentrancyGuardTransient } from "lib/openzeppelin-contracts/contracts/utils/ReentrancyGuardTransient.sol";
import { Owned } from "lib/solmate/src/auth/Owned.sol";

enum RewardStyle {
    Upfront,
    Arrear,
    Forfeitable
}

/// @title RecipeMarketHubBase
/// @author Shivaansh Kapoor, Jack Corddry, CopyPaste
/// @notice Base contract for the RecipeMarketHub
abstract contract RecipeMarketHubBase is Owned, ReentrancyGuardTransient {
    /// @notice The address of the WeirollWallet implementation contract for use with ClonesWithImmutableArgs
    address public immutable WEIROLL_WALLET_IMPLEMENTATION;

    /// @notice The address of the PointsFactory contract
    address public immutable POINTS_FACTORY;

    /// @notice The minimum percent you can fill an AP offer with, to prevent griefing attacks
    uint256 public constant MIN_FILL_PERCENT = 0.1e18; // == 10%

    /// @dev The minimum quantity of tokens for an offer
    uint256 internal constant MINIMUM_QUANTITY = 1e6;

    /// @notice The number of AP offers that have been created
    uint256 public numAPOffers;
    /// @notice The number of IP offers that have been created
    uint256 public numIPOffers;
    /// @notice The number of unique weiroll markets added
    uint256 public numMarkets;

    /// @notice whether offer fills are paused
    bool offersPaused;

    /// @notice The percent deducted from the IP's incentive amount and claimable by protocolFeeClaimant
    uint256 public protocolFee; // 1e18 == 100% fee
    address public protocolFeeClaimant;

    /// @notice Markets can opt into a higher frontend fee to incentivize quick discovery but cannot go below this minimum
    uint256 public minimumFrontendFee; // 1e18 == 100% fee

    /// @notice Holds all WeirollMarket structs
    mapping(bytes32 => WeirollMarket) public marketHashToWeirollMarket;

    /// @notice Holds all IPOffer structs
    mapping(bytes32 => IPOffer) public offerHashToIPOffer;
    /// @notice Tracks the unfilled quantity of each AP offer
    mapping(bytes32 => uint256) public offerHashToRemainingQuantity;

    // Tracks the locked incentives associated with a weiroll wallet
    mapping(address => LockedRewardParams) public weirollWalletToLockedIncentivesParams;

    // Structure to store each fee claimant's accrued fees for a particular incentive token (claimant => incentive token => feesAccrued)
    mapping(address => mapping(address => uint256)) public feeClaimantToTokenToAmount;

    /// @custom:field weirollCommands The weiroll script that will be executed on an AP's weiroll wallet after receiving the inputToken
    /// @custom:field weirollState State of the weiroll VM, necessary for executing the weiroll script
    struct Recipe {
        bytes32[] weirollCommands;
        bytes[] weirollState;
    }

    /// @custom:field marketID The ID of the Weiroll Market
    /// @custom:field inputToken The token that will be deposited into the user's weiroll wallet for use in the recipe
    /// @custom:field lockupTime The time in seconds that the user's weiroll wallet will be locked up for after deposit
    /// @custom:field frontendFee The fee that the frontend will take from IP incentives, 1e18 == 100% fee
    /// @custom:field depositRecipe The weiroll recipe that will be executed after the inputToken is transferred to the wallet
    /// @custom:field withdrawRecipe The weiroll recipe that may be executed after lockupTime has passed to unwind a user's position
    struct WeirollMarket {
        uint256 marketID;
        ERC20 inputToken;
        uint256 lockupTime;
        uint256 frontendFee;
        Recipe depositRecipe;
        Recipe withdrawRecipe;
        RewardStyle rewardStyle;
    }

    /// @custom:field offerID Set to numAPOffers (zero-indexed) - ordered separately for AP and IP offers
    /// @custom:field targetMarketHash The hash of the weiroll market which the IP offer is for
    /// @custom:field ip The address of the incentive provider
    /// @custom:field expiry The timestamp after which the offer is considered expired
    /// @custom:field quantity The total quantity of the market's input token requested by the IP
    /// @custom:field incentivesOffered The incentives offered by the IP
    /// @custom:field incentiveAmountsOffered Mapping of incentive to the amount of the incentive allocated to APs
    /// @custom:field incentiveToProtocolFeeAmount Mapping of incentive to the amount of the incentive allocated to the protocol fee
    /// @custom:field incentiveToFrontendFeeAmount Mapping of incentive to the amount of the incentive allocated to frontend fee recipients
    struct IPOffer {
        uint256 offerID;
        bytes32 targetMarketHash;
        address ip;
        uint256 expiry;
        uint256 quantity;
        uint256 remainingQuantity;
        address[] incentivesOffered;
        mapping(address => uint256) incentiveAmountsOffered; // amounts to be allocated to APs (per incentive)
        mapping(address => uint256) incentiveToProtocolFeeAmount; // amounts to be allocated to protocolFeeClaimant (per incentive)
        mapping(address => uint256) incentiveToFrontendFeeAmount; // amounts to be allocated to frontend provider (per incentive)
    }

    /// @custom:field offerID Set to numAPOffers (zero-indexed) - ordered separately for AP and IP offers
    /// @custom:field targetMarketHash The hash of the weiroll market which the AP offer is for
    /// @custom:field ap The address of the action provider
    /// @custom:field fundingVault The address of the vault where the input tokens will be withdrawn from
    /// @custom:field expiry The timestamp after which the offer is considered expired
    /// @custom:field quantity The total quantity of the market's input token offered by the AP
    /// @custom:field incentivesRequested The incentives requested by the AP
    /// @custom:field incentiveAmountsRequested The desired incentives per input token
    struct APOffer {
        uint256 offerID;
        bytes32 targetMarketHash;
        address ap;
        address fundingVault;
        uint256 quantity;
        uint256 expiry;
        address[] incentivesRequested;
        uint256[] incentiveAmountsRequested;
    }

    /// @custom:field incentives Tokens offered as incentives
    /// @custom:field amounts The amount of incentives offered for each incentive
    /// @custom:field ip The incentives provider
    struct LockedRewardParams {
        address[] incentives;
        uint256[] amounts;
        address ip;
        address frontendFeeRecipient;
        bool wasIPOffer;
        bytes32 offerHash; // For IP offer identification
        uint256 protocolFeeAtFill; // Used to keep track of protocol fee charged on fill for AP offers.
    }

    /// @custom:field marketID The ID of the newly created market
    /// @custom:field marketHash The hash of the newly created market
    /// @custom:field inputToken The token that will be deposited into the user's weiroll wallet for use in the recipe
    /// @custom:field lockupTime The time in seconds that the user's weiroll wallet will be locked up for after deposit
    /// @custom:field frontendFee The fee paid to the frontend out of IP incentives
    /// @custom:field rewardStyle Whether the rewards are paid at the beginning, locked until the end, or forfeitable until the end
    event MarketCreated(
        uint256 indexed marketID, bytes32 indexed marketHash, address indexed inputToken, uint256 lockupTime, uint256 frontendFee, RewardStyle rewardStyle
    );

    /// @param offerID Set to numAPOffers (zero-indexed) - ordered separately for AP and IP offers
    /// @param marketHash The hash of the weiroll market which the AP offer is for
    /// @param ap The address of the AP that created this offer.
    /// @param fundingVault The address of the vault where the input tokens will be withdrawn from
    /// @param quantity The total amount of input tokens to be deposited
    /// @param incentiveAddresses The requested rewards
    /// @param incentiveAmounts The requested rewards per input token
    /// @param expiry The timestamp after which the offer is considered expired
    event APOfferCreated(
        uint256 indexed offerID,
        bytes32 indexed marketHash,
        address indexed ap,
        address fundingVault,
        uint256 quantity,
        address[] incentiveAddresses,
        uint256[] incentiveAmounts,
        uint256 expiry
    );

    /// @param offerID Set to numIPOffers (zero-indexed) - ordered separately for AP and IP offers
    /// @param offerHash Set to the hash of the offer (used to identify IP offers)
    /// @param marketHash The hash of the weiroll market which the IP offer is for
    /// @param ip The address of the IP that created this offer.
    /// @param quantity The total amount of input tokens to be deposited
    /// @param incentivesOffered The offered rewards
    /// @param incentiveAmounts The offered rewards per input token
    /// @param protocolFeeAmounts The offered rewards protocol fee per input token
    /// @param frontendFeeAmounts The offered rewards frontend fee per input token
    /// @param expiry The timestamp after which the offer is considered expired
    event IPOfferCreated(
        uint256 offerID,
        bytes32 indexed offerHash,
        bytes32 indexed marketHash,
        address indexed ip,
        uint256 quantity,
        address[] incentivesOffered,
        uint256[] incentiveAmounts,
        uint256[] protocolFeeAmounts,
        uint256[] frontendFeeAmounts,
        uint256 expiry
    );

    /// @param offerHash Hash of the offer (used to identify IP offers)
    /// @param ap The address of the AP that filled this offer.
    /// @param fillAmount The amount of the offer that was filled in the market input token
    /// @param weirollWallet The address of the weiroll wallet containing the AP's funds, created on fill, used to execute the recipes
    /// @param incentiveAmounts The amount of incentives allocated to the AP on fill (claimable as per the market's reward type)
    /// @param protocolFeeAmounts The protocol fee per incentive on fill (claimable as per the market's reward type)
    /// @param frontendFeeAmounts The rewards frontend fee per incentive on fill (claimable as per the market's reward type)
    event IPOfferFilled(
        bytes32 indexed offerHash,
        address indexed ap,
        uint256 fillAmount,
        address weirollWallet,
        uint256[] incentiveAmounts,
        uint256[] protocolFeeAmounts,
        uint256[] frontendFeeAmounts
    );

    /// @param offerID The ID of the AP offer filled
    /// @param ip The address of the IP that filled this offer.
    /// @param fillAmount The amount of the offer that was filled in the market input token
    /// @param weirollWallet The address of the weiroll wallet containing the AP's funds, created on fill, used to execute the recipes
    /// @param incentiveAmounts The amount of incentives allocated to the AP on fill (claimable as per the market's reward type)
    /// @param protocolFeeAmounts The amount taken as the protocol fee per incentive on fill (claimable as per the market's reward type)
    /// @param frontendFeeAmounts The amount taken as the frontend fee per incentive on fill (claimable as per the market's reward type)
    event APOfferFilled(
        uint256 indexed offerID,
        address indexed ip,
        uint256 fillAmount,
        address weirollWallet,
        uint256[] incentiveAmounts,
        uint256[] protocolFeeAmounts,
        uint256[] frontendFeeAmounts
    );

    /// @param offerHash The hash of the IP offer that was cancelled
    event IPOfferCancelled(bytes32 indexed offerHash);

    /// @param offerID The ID of the AP offer that was cancelled
    event APOfferCancelled(uint256 indexed offerID);

    /// @param claimant The address that claimed the fees
    /// @param incentive The address of the incentive claimed as a fee
    /// @param amount The amount of fees claimed
    event FeesClaimed(address indexed claimant, address indexed incentive, uint256 amount);

    /// @param weirollWallet The address of the weiroll wallet that forfeited
    event WeirollWalletForfeited(address indexed weirollWallet);

    /// @param weirollWallet The address of the weiroll wallet that claimed incentives
    /// @param recipient The address of the incentive recipient
    /// @param incentive The incentive claimed by the AP
    event WeirollWalletClaimedIncentive(address indexed weirollWallet, address recipient, address incentive);

    /// @param weirollWallet The address of the weiroll wallet that executed the withdrawal recipe
    event WeirollWalletExecutedWithdrawal(address indexed weirollWallet);

    /// @notice emitted when trying to create a market with address(0) as the input token
    error InvalidMarketInputToken();
    /// @notice emitted when trying to fill an offer that has expired
    error OfferExpired();
    /// @notice emitted when creating an offer with duplicate incentives
    error OfferCannotContainDuplicates();
    /// @notice emitted when trying to fill an offer with more input tokens than the remaining offer quantity
    error NotEnoughRemainingQuantity();
    /// @notice emitted when the base asset of the target vault and the funding vault do not match
    error MismatchedBaseAsset();
    /// @notice emitted if a market with the given ID does not exist
    error MarketDoesNotExist();
    /// @notice emitted when trying to place an offer with an expiry in the past
    error CannotPlaceExpiredOffer();
    /// @notice emitted when trying to place an offer with a quantity of 0
    error CannotPlaceZeroQuantityOffer();
    /// @notice emitted when incentives and amounts offered/requested arrays are not the same length
    error ArrayLengthMismatch();
    /// @notice emitted when the frontend fee is below the minimum
    error FrontendFeeTooLow();
    /// @notice emitted when trying to forfeit a wallet that is not owned by the caller
    error NotOwner();
    /// @notice emitted when trying to claim rewards of a wallet that is locked
    error WalletLocked();
    /// @notice Emitted when trying to start a rewards campaign with a non-existent incentive
    error TokenDoesNotExist();
    /// @notice Emitted when sum of protocolFee and frontendFee is greater than 100% (1e18)
    error TotalFeeTooHigh();
    /// @notice emitted when trying to fill an offer that doesn't exist anymore/yet
    error CannotFillZeroQuantityOffer();
    /// @notice emitted when funding the weiroll wallet with the market's input token failed
    error WeirollWalletFundingFailed();
    /// @notice emitted when creating an offer with an invalid points program
    error InvalidPointsProgram();
    /// @notice emitted when APOfferFill charges a trivial incentive amount
    error NoIncentivesPaidOnFill();
    /// @notice emitted when trying to fill offers while offers are paused
    error OffersPaused();
    /// @notice emitted when trying to forfeit a wallet where rewards are not forfeitable
    error WalletNotForfeitable();
    /// @notice emitted when trying to fill an offer with a quantity below the minimum fill percent
    error InsufficientFillPercent();

    /// @notice Modifier to check if msg.sender is owner of a weirollWallet
    modifier isWeirollOwner(address weirollWallet) {
        if (WeirollWallet(payable(weirollWallet)).owner() != msg.sender) {
            revert NotOwner();
        }
        _;
    }

    /// @notice Modifier to check if the weiroll wallet is unlocked
    modifier weirollIsUnlocked(address weirollWallet) {
        if (WeirollWallet(payable(weirollWallet)).lockedUntil() > block.timestamp) {
            revert WalletLocked();
        }
        _;
    }

    /// @notice Check if offer fills have been paused
    modifier offersNotPaused() {
        if (offersPaused) {
            revert OffersPaused();
        }
        _;
    }

    /// @notice Setter to pause and unpause fills
    function setOffersPaused(bool _offersPaused) external onlyOwner {
        offersPaused = _offersPaused;
    }

    /// @notice sets the protocol fee recipient, taken on all fills
    /// @param _protocolFeeClaimant The address allowed to claim protocol fees
    function setProtocolFeeClaimant(address _protocolFeeClaimant) external payable onlyOwner {
        protocolFeeClaimant = _protocolFeeClaimant;
    }

    /// @notice sets the protocol fee rate, taken on all fills
    /// @param _protocolFee The percent deducted from the IP's incentive amount and claimable by protocolFeeClaimant, 1e18 == 100% fee
    function setProtocolFee(uint256 _protocolFee) external payable onlyOwner {
        protocolFee = _protocolFee;
    }

    /// @notice sets the minimum frontend fee that a market can set and is paid to whoever fills the offer
    /// @param _minimumFrontendFee The minimum frontend fee for a market, 1e18 == 100% fee
    function setMinimumFrontendFee(uint256 _minimumFrontendFee) external payable onlyOwner {
        minimumFrontendFee = _minimumFrontendFee;
    }

    /// @notice Calculates the hash of a Weiroll Market
    function getMarketHash(WeirollMarket memory market) public pure returns (bytes32) {
        return keccak256(abi.encode(market));
    }

    /// @notice Calculates the hash of an AP offer
    function getAPOfferHash(APOffer memory offer) public pure returns (bytes32) {
        return keccak256(abi.encode(offer));
    }

    /// @notice Calculates the hash of an IP offer
    function getIPOfferHash(
        uint256 offerID,
        bytes32 targetMarketHash,
        address ip,
        uint256 expiry,
        uint256 quantity,
        address[] calldata incentivesOffered,
        uint256[] memory incentiveAmountsOffered
    )
        public
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(offerID, targetMarketHash, ip, expiry, quantity, incentivesOffered, incentiveAmountsOffered));
    }
}
/// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title IERC1271
/// @notice Interface defined by EIP-1271
/// @dev Interface for verifying contract account signatures
interface IERC1271 {
    /// @notice Returns whether the provided signature is valid for the provided data
    /// @dev Returns 0x1626ba7e (magic value) when function passes.
    /// @param digest Hash of the message to validate the signature against
    /// @param signature Signature produced for the provided digest
    function isValidSignature(bytes32 digest, bytes memory signature) external view returns (bytes4);
}