// SPDX-License-Identifier: BSD
pragma solidity ^0.8.4;

/// @title Clone
/// @author zefram.eth
/// @notice Provides helper functions for reading immutable args from calldata
contract Clone {
    /// @notice Reads an immutable arg with type address
    /// @param argOffset The offset of the arg in the packed data
    /// @return arg The arg value
    function _getArgAddress(
        uint256 argOffset
    ) internal pure returns (address arg) {
        uint256 offset = _getImmutableArgsOffset();
        // solhint-disable-next-line no-inline-assembly
        assembly {
            arg := shr(0x60, calldataload(add(offset, argOffset)))
        }
    }

    /// @notice Reads an immutable arg with type uint256
    /// @param argOffset The offset of the arg in the packed data
    /// @return arg The arg value
    function _getArgUint256(
        uint256 argOffset
    ) internal pure returns (uint256 arg) {
        uint256 offset = _getImmutableArgsOffset();
        // solhint-disable-next-line no-inline-assembly
        assembly {
            arg := calldataload(add(offset, argOffset))
        }
    }

    /// @notice Reads a uint256 array stored in the immutable args.
    /// @param argOffset The offset of the arg in the packed data
    /// @param arrLen Number of elements in the array
    /// @return arr The array
    function _getArgUint256Array(
        uint256 argOffset,
        uint64 arrLen
    ) internal pure returns (uint256[] memory arr) {
        uint256 offset = _getImmutableArgsOffset();
        uint256 el;
        arr = new uint256[](arrLen);
        for (uint64 i = 0; i < arrLen; i++) {
            // solhint-disable-next-line no-inline-assembly
            assembly {
                el := calldataload(add(add(offset, argOffset), mul(i, 32)))
            }
            arr[i] = el;
        }
        return arr;
    }

    /// @notice Reads an immutable arg with type uint64
    /// @param argOffset The offset of the arg in the packed data
    /// @return arg The arg value
    function _getArgUint64(
        uint256 argOffset
    ) internal pure returns (uint64 arg) {
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
/// @author wighawag, zefram.eth, nick.eth
/// @notice Enables creating clone contracts with immutable args
library ClonesWithImmutableArgs {
    /// @dev The CREATE3 proxy bytecode.
    uint256 private constant _CREATE3_PROXY_BYTECODE =
        0x67363d3d37363d34f03d5260086018f3;

    /// @dev Hash of the `_CREATE3_PROXY_BYTECODE`.
    /// Equivalent to `keccak256(abi.encodePacked(hex"67363d3d37363d34f03d5260086018f3"))`.
    bytes32 private constant _CREATE3_PROXY_BYTECODE_HASH =
        0x21c35dbe1b344a2488cf3321d6ce542f8e9f305544ff09e4993a62319a497c1f;

    error CreateFail();
    error InitializeFail();

    enum CloneType {
        CREATE,
        CREATE2,
        PREDICT_CREATE2
    }

    /// @notice Creates a clone proxy of the implementation contract, with immutable args
    /// @dev data cannot exceed 65535 bytes, since 2 bytes are used to store the data length
    /// @param implementation The implementation contract to clone
    /// @param data Encoded immutable args
    /// @return instance The address of the created clone
    function clone(
        address implementation,
        bytes memory data
    ) internal returns (address payable instance) {
        return clone(implementation, data, 0);
    }

    /// @notice Creates a clone proxy of the implementation contract, with immutable args
    /// @dev data cannot exceed 65535 bytes, since 2 bytes are used to store the data length
    /// @param implementation The implementation contract to clone
    /// @param data Encoded immutable args
    /// @param value The amount of wei to transfer to the created clone
    /// @return instance The address of the created clone
    function clone(
        address implementation,
        bytes memory data,
        uint256 value
    ) internal returns (address payable instance) {
        bytes memory creationcode = getCreationBytecode(implementation, data);
        // solhint-disable-next-line no-inline-assembly
        assembly {
            instance := create(
                value,
                add(creationcode, 0x20),
                mload(creationcode)
            )
        }
        if (instance == address(0)) {
            revert CreateFail();
        }
    }

    /// @notice Creates a clone proxy of the implementation contract, with immutable args,
    ///         using CREATE2
    /// @dev data cannot exceed 65535 bytes, since 2 bytes are used to store the data length
    /// @param implementation The implementation contract to clone
    /// @param data Encoded immutable args
    /// @return instance The address of the created clone
    function clone2(
        address implementation,
        bytes memory data
    ) internal returns (address payable instance) {
        return clone2(implementation, data, 0);
    }

    /// @notice Creates a clone proxy of the implementation contract, with immutable args,
    ///         using CREATE2
    /// @dev data cannot exceed 65535 bytes, since 2 bytes are used to store the data length
    /// @param implementation The implementation contract to clone
    /// @param data Encoded immutable args
    /// @param value The amount of wei to transfer to the created clone
    /// @return instance The address of the created clone
    function clone2(
        address implementation,
        bytes memory data,
        uint256 value
    ) internal returns (address payable instance) {
        bytes memory creationcode = getCreationBytecode(implementation, data);
        // solhint-disable-next-line no-inline-assembly
        assembly {
            instance := create2(
                value,
                add(creationcode, 0x20),
                mload(creationcode),
                0
            )
        }
        if (instance == address(0)) {
            revert CreateFail();
        }
    }

    /// @notice Computes the address of a clone created using CREATE2
    /// @dev data cannot exceed 65535 bytes, since 2 bytes are used to store the data length
    /// @param implementation The implementation contract to clone
    /// @param data Encoded immutable args
    /// @return instance The address of the clone
    function addressOfClone2(
        address implementation,
        bytes memory data
    ) internal view returns (address payable instance) {
        bytes memory creationcode = getCreationBytecode(implementation, data);
        bytes32 bytecodeHash = keccak256(creationcode);
        instance = payable(
            address(
                uint160(
                    uint256(
                        keccak256(
                            abi.encodePacked(
                                bytes1(0xff),
                                address(this),
                                bytes32(0),
                                bytecodeHash
                            )
                        )
                    )
                )
            )
        );
    }

    /// @notice Computes bytecode for a clone
    /// @dev data cannot exceed 65535 bytes, since 2 bytes are used to store the data length
    /// @param implementation The implementation contract to clone
    /// @param data Encoded immutable args
    /// @return ret Creation bytecode for the clone contract
    function getCreationBytecode(
        address implementation,
        bytes memory data
    ) internal pure returns (bytes memory ret) {
        // unrealistic for memory ptr or data length to exceed 256 bits
        unchecked {
            uint256 extraLength = data.length + 2; // +2 bytes for telling how much data there is appended to the call
            uint256 creationSize = 0x41 + extraLength;
            uint256 runSize = creationSize - 10;
            uint256 dataPtr;
            uint256 ptr;

            // solhint-disable-next-line no-inline-assembly
            assembly {
                ret := mload(0x40)
                mstore(ret, creationSize)
                mstore(0x40, add(ret, creationSize))
                ptr := add(ret, 0x20)

                // -------------------------------------------------------------------------------------------------------------
                // CREATION (10 bytes)
                // -------------------------------------------------------------------------------------------------------------

                // 61 runtime  | PUSH2 runtime (r)     | r                             | –
                mstore(
                    ptr,
                    0x6100000000000000000000000000000000000000000000000000000000000000
                )
                mstore(add(ptr, 0x01), shl(240, runSize)) // size of the contract running bytecode (16 bits)

                // creation size = 0a
                // 3d          | RETURNDATASIZE        | 0 r                           | –
                // 81          | DUP2                  | r 0 r                         | –
                // 60 creation | PUSH1 creation (c)    | c r 0 r                       | –
                // 3d          | RETURNDATASIZE        | 0 c r 0 r                     | –
                // 39          | CODECOPY              | 0 r                           | [0-runSize): runtime code
                // f3          | RETURN                |                               | [0-runSize): runtime code

                // -------------------------------------------------------------------------------------------------------------
                // RUNTIME (55 bytes + extraLength)
                // -------------------------------------------------------------------------------------------------------------

                // 3d          | RETURNDATASIZE        | 0                             | –
                // 3d          | RETURNDATASIZE        | 0 0                           | –
                // 3d          | RETURNDATASIZE        | 0 0 0                         | –
                // 3d          | RETURNDATASIZE        | 0 0 0 0                       | –
                // 36          | CALLDATASIZE          | cds 0 0 0 0                   | –
                // 3d          | RETURNDATASIZE        | 0 cds 0 0 0 0                 | –
                // 3d          | RETURNDATASIZE        | 0 0 cds 0 0 0 0               | –
                // 37          | CALLDATACOPY          | 0 0 0 0                       | [0, cds) = calldata
                // 61          | PUSH2 extra           | extra 0 0 0 0                 | [0, cds) = calldata
                mstore(
                    add(ptr, 0x03),
                    0x3d81600a3d39f33d3d3d3d363d3d376100000000000000000000000000000000
                )
                mstore(add(ptr, 0x13), shl(240, extraLength))

                // 60 0x37     | PUSH1 0x37            | 0x37 extra 0 0 0 0            | [0, cds) = calldata // 0x37 (55) is runtime size - data
                // 36          | CALLDATASIZE          | cds 0x37 extra 0 0 0 0        | [0, cds) = calldata
                // 39          | CODECOPY              | 0 0 0 0                       | [0, cds) = calldata, [cds, cds+extra) = extraData
                // 36          | CALLDATASIZE          | cds 0 0 0 0                   | [0, cds) = calldata, [cds, cds+extra) = extraData
                // 61 extra    | PUSH2 extra           | extra cds 0 0 0 0             | [0, cds) = calldata, [cds, cds+extra) = extraData
                mstore(
                    add(ptr, 0x15),
                    0x6037363936610000000000000000000000000000000000000000000000000000
                )
                mstore(add(ptr, 0x1b), shl(240, extraLength))

                // 01          | ADD                   | cds+extra 0 0 0 0             | [0, cds) = calldata, [cds, cds+extra) = extraData
                // 3d          | RETURNDATASIZE        | 0 cds+extra 0 0 0 0           | [0, cds) = calldata, [cds, cds+extra) = extraData
                // 73 addr     | PUSH20 0x123…         | addr 0 cds+extra 0 0 0 0      | [0, cds) = calldata, [cds, cds+extra) = extraData
                mstore(
                    add(ptr, 0x1d),
                    0x013d730000000000000000000000000000000000000000000000000000000000
                )
                mstore(add(ptr, 0x20), shl(0x60, implementation))

                // 5a          | GAS                   | gas addr 0 cds+extra 0 0 0 0  | [0, cds) = calldata, [cds, cds+extra) = extraData
                // f4          | DELEGATECALL          | success 0 0                   | [0, cds) = calldata, [cds, cds+extra) = extraData
                // 3d          | RETURNDATASIZE        | rds success 0 0               | [0, cds) = calldata, [cds, cds+extra) = extraData
                // 3d          | RETURNDATASIZE        | rds rds success 0 0           | [0, cds) = calldata, [cds, cds+extra) = extraData
                // 93          | SWAP4                 | 0 rds success 0 rds           | [0, cds) = calldata, [cds, cds+extra) = extraData
                // 80          | DUP1                  | 0 0 rds success 0 rds         | [0, cds) = calldata, [cds, cds+extra) = extraData
                // 3e          | RETURNDATACOPY        | success 0 rds                 | [0, rds) = return data (there might be some irrelevant leftovers in memory [rds, cds+0x37) when rds < cds+0x37)
                // 60 0x35     | PUSH1 0x35            | 0x35 sucess 0 rds             | [0, rds) = return data
                // 57          | JUMPI                 | 0 rds                         | [0, rds) = return data
                // fd          | REVERT                | –                             | [0, rds) = return data
                // 5b          | JUMPDEST              | 0 rds                         | [0, rds) = return data
                // f3          | RETURN                | –                             | [0, rds) = return data
                mstore(
                    add(ptr, 0x34),
                    0x5af43d3d93803e603557fd5bf300000000000000000000000000000000000000
                )
            }

            // -------------------------------------------------------------------------------------------------------------
            // APPENDED DATA (Accessible from extcodecopy)
            // (but also send as appended data to the delegatecall)
            // -------------------------------------------------------------------------------------------------------------

            extraLength -= 2;
            uint256 counter = extraLength;
            uint256 copyPtr = ptr + 0x41;
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
            uint256 mask = ~(256 ** (32 - counter) - 1);
            // solhint-disable-next-line no-inline-assembly
            assembly {
                mstore(copyPtr, and(mload(dataPtr), mask))
            }
            copyPtr += counter;
            // solhint-disable-next-line no-inline-assembly
            assembly {
                mstore(copyPtr, shl(240, extraLength))
            }
        }
    }

    /// @notice Creates a clone proxy of the implementation contract, with immutable args. Uses CREATE3
    /// to implement deterministic deployment.
    /// @dev data cannot exceed 65535 bytes, since 2 bytes are used to store the data length
    /// @param implementation The implementation contract to clone
    /// @param data Encoded immutable args
    /// @param salt The salt used by the CREATE3 deployment
    /// @return deployed The address of the created clone
    function clone3(
        address implementation,
        bytes memory data,
        bytes32 salt
    ) internal returns (address deployed) {
        return clone3(implementation, data, salt, 0);
    }

    /// @notice Creates a clone proxy of the implementation contract, with immutable args. Uses CREATE3
    /// to implement deterministic deployment.
    /// @dev data cannot exceed 65535 bytes, since 2 bytes are used to store the data length
    /// @param implementation The implementation contract to clone
    /// @param data Encoded immutable args
    /// @param salt The salt used by the CREATE3 deployment
    /// @param value The amount of wei to transfer to the created clone
    /// @return deployed The address of the created clone
    function clone3(
        address implementation,
        bytes memory data,
        bytes32 salt,
        uint256 value
    ) internal returns (address deployed) {
        // unrealistic for memory ptr or data length to exceed 256 bits
        unchecked {
            uint256 extraLength = data.length + 2; // +2 bytes for telling how much data there is appended to the call
            uint256 creationSize = 0x43 + extraLength;
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
                mstore(add(ptr, 0x02), shl(240, sub(creationSize, 11))) // size of the contract running bytecode (16 bits)

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
            uint256 dataPtr;
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
            uint256 mask = ~(256 ** (32 - counter) - 1);
            // solhint-disable-next-line no-inline-assembly
            assembly {
                mstore(copyPtr, and(mload(dataPtr), mask))
            }
            copyPtr += counter;
            // solhint-disable-next-line no-inline-assembly
            assembly {
                mstore(copyPtr, shl(240, extraLength))
            }

            /// @solidity memory-safe-assembly
            // solhint-disable-next-line no-inline-assembly
            assembly {
                // Store the `_PROXY_BYTECODE` into scratch space.
                mstore(0x00, _CREATE3_PROXY_BYTECODE)
                // Deploy a new contract with our pre-made bytecode via CREATE2.
                let proxy := create2(0, 0x10, 0x10, salt)

                // If the result of `create2` is the zero address, revert.
                if iszero(proxy) {
                    // Store the function selector of `CreateFail()`.
                    mstore(0x00, 0xebfef188)
                    // Revert with (offset, size).
                    revert(0x1c, 0x04)
                }

                // Store the proxy's address.
                mstore(0x14, proxy)
                // 0xd6 = 0xc0 (short RLP prefix) + 0x16 (length of: 0x94 ++ proxy ++ 0x01).
                // 0x94 = 0x80 + 0x14 (0x14 = the length of an address, 20 bytes, in hex).
                mstore(0x00, 0xd694)
                // Nonce of the proxy contract (1).
                mstore8(0x34, 0x01)

                deployed := and(
                    keccak256(0x1e, 0x17),
                    0xffffffffffffffffffffffffffffffffffffffff
                )

                // If the `call` fails or the code size of `deployed` is zero, revert.
                // The second argument of the or() call is evaluated first, which is important
                // here because extcodesize(deployed) is only non-zero after the call() to the proxy
                // is made and the contract is successfully deployed.
                if or(
                    iszero(extcodesize(deployed)),
                    iszero(
                        call(
                            gas(), // Gas remaining.
                            proxy, // Proxy's address.
                            value, // Ether value.
                            ptr, // Pointer to the creation code
                            creationSize, // Size of the creation code
                            0x00, // Offset of output.
                            0x00 // Length of output.
                        )
                    )
                ) {
                    // Store the function selector of `InitializeFail()`.
                    mstore(0x00, 0x8f86d2f1)
                    // Revert with (offset, size).
                    revert(0x1c, 0x04)
                }
            }
        }
    }

    /// @notice Returns the CREATE3 deterministic address of the contract deployed via cloneDeterministic().
    /// @dev Forked from https://github.com/Vectorized/solady/blob/main/src/utils/CREATE3.sol
    /// @param salt The salt used by the CREATE3 deployment
    function addressOfClone3(
        bytes32 salt
    ) internal view returns (address deployed) {
        /// @solidity memory-safe-assembly
        // solhint-disable-next-line no-inline-assembly
        assembly {
            // Cache the free memory pointer.
            let m := mload(0x40)
            // Store `address(this)`.
            mstore(0x00, address())
            // Store the prefix.
            mstore8(0x0b, 0xff)
            // Store the salt.
            mstore(0x20, salt)
            // Store the bytecode hash.
            mstore(0x40, _CREATE3_PROXY_BYTECODE_HASH)

            // Store the proxy's address.
            mstore(0x14, keccak256(0x0b, 0x55))
            // Restore the free memory pointer.
            mstore(0x40, m)
            // 0xd6 = 0xc0 (short RLP prefix) + 0x16 (length of: 0x94 ++ proxy ++ 0x01).
            // 0x94 = 0x80 + 0x14 (0x14 = the length of an address, 20 bytes, in hex).
            mstore(0x00, 0xd694)
            // Nonce of the proxy contract (1).
            mstore8(0x34, 0x01)

            deployed := and(
                keccak256(0x1e, 0x17),
                0xffffffffffffffffffffffffffffffffffffffff
            )
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
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

pragma solidity ^0.8.20;

/**
 * @dev Helper library for emitting standardized panic codes.
 *
 * ```solidity
 * contract Example {
 *      using Panic for uint256;
 *
 *      // Use any of the declared internal constants
 *      function foo() { Panic.GENERIC.panic(); }
 *
 *      // Alternatively
 *      function foo() { Panic.panic(Panic.GENERIC); }
 * }
 * ```
 *
 * Follows the list from https://github.com/ethereum/solidity/blob/v0.8.24/libsolutil/ErrorCodes.h[libsolutil].
 */
// slither-disable-next-line unused-state
library Panic {
    /// @dev generic / unspecified error
    uint256 internal constant GENERIC = 0x00;
    /// @dev used by the assert() builtin
    uint256 internal constant ASSERT = 0x01;
    /// @dev arithmetic underflow or overflow
    uint256 internal constant UNDER_OVERFLOW = 0x11;
    /// @dev division or modulo by zero
    uint256 internal constant DIVISION_BY_ZERO = 0x12;
    /// @dev enum conversion error
    uint256 internal constant ENUM_CONVERSION_ERROR = 0x21;
    /// @dev invalid encoding in storage
    uint256 internal constant STORAGE_ENCODING_ERROR = 0x22;
    /// @dev empty array pop
    uint256 internal constant EMPTY_ARRAY_POP = 0x31;
    /// @dev array out of bounds access
    uint256 internal constant ARRAY_OUT_OF_BOUNDS = 0x32;
    /// @dev resource error (too large allocation or too large array)
    uint256 internal constant RESOURCE_ERROR = 0x41;
    /// @dev calling invalid internal function
    uint256 internal constant INVALID_INTERNAL_FUNCTION = 0x51;

    /// @dev Reverts with a panic code. Recommended to use with
    /// the internal constants with predefined codes.
    function panic(uint256 code) internal pure {
        assembly ("memory-safe") {
            mstore(0x00, 0x4e487b71)
            mstore(0x20, code)
            revert(0x1c, 0x24)
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
            assembly ("memory-safe") {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                assembly ("memory-safe") {
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
     * @dev Converts an `address` with fixed length of 20 bytes to its checksummed ASCII `string` hexadecimal
     * representation, according to EIP-55.
     */
    function toChecksumHexString(address addr) internal pure returns (string memory) {
        bytes memory buffer = bytes(toHexString(addr));

        // hash the hex part of buffer (skip length + 2 bytes, length 40)
        uint256 hashValue;
        assembly ("memory-safe") {
            hashValue := shr(96, keccak256(add(buffer, 0x22), 40))
        }

        for (uint256 i = 41; i > 1; --i) {
            // possible values for buffer[i] are 48 (0) to 57 (9) and 97 (a) to 102 (f)
            if (hashValue & 0xf > 7 && uint8(buffer[i]) > 96) {
                // case shift by xoring with 0x20
                buffer[i] ^= 0x20;
            }
            hashValue >>= 4;
        }
        return string(buffer);
    }

    /**
     * @dev Returns true if the two strings are equal.
     */
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return bytes(a).length == bytes(b).length && keccak256(bytes(a)) == keccak256(bytes(b));
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/Math.sol)

pragma solidity ^0.8.20;

import {Panic} from "../Panic.sol";
import {SafeCast} from "./SafeCast.sol";

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Floor, // Toward negative infinity
        Ceil, // Toward positive infinity
        Trunc, // Toward zero
        Expand // Away from zero
    }

    /**
     * @dev Returns the addition of two unsigned integers, with an success flag (no overflow).
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool success, uint256 result) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an success flag (no overflow).
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool success, uint256 result) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an success flag (no overflow).
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool success, uint256 result) {
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
     * @dev Returns the division of two unsigned integers, with a success flag (no division by zero).
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool success, uint256 result) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a success flag (no division by zero).
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool success, uint256 result) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Branchless ternary evaluation for `a ? b : c`. Gas costs are constant.
     *
     * IMPORTANT: This function may reduce bytecode size and consume less gas when used standalone.
     * However, the compiler may optimize Solidity ternary operations (i.e. `a ? b : c`) to only compute
     * one branch when needed, making this function more expensive.
     */
    function ternary(bool condition, uint256 a, uint256 b) internal pure returns (uint256) {
        unchecked {
            // branchless ternary works because:
            // b ^ (a ^ b) == a
            // b ^ 0 == b
            return b ^ ((a ^ b) * SafeCast.toUint(condition));
        }
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return ternary(a > b, a, b);
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return ternary(a < b, a, b);
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
            Panic.panic(Panic.DIVISION_BY_ZERO);
        }

        // The following calculation ensures accurate ceiling division without overflow.
        // Since a is non-zero, (a - 1) / b will not overflow.
        // The largest possible result occurs when (a - 1) / b is type(uint256).max,
        // but the largest value we can obtain is type(uint256).max - 1, which happens
        // when a = type(uint256).max and b = 1.
        unchecked {
            return SafeCast.toUint(a > 0) * ((a - 1) / b + 1);
        }
    }

    /**
     * @dev Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or
     * denominator == 0.
     *
     * Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv) with further edits by
     * Uniswap Labs also under MIT license.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2²⁵⁶ and mod 2²⁵⁶ - 1, then use
            // the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2²⁵⁶ + prod0.
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

            // Make sure the result is less than 2²⁵⁶. Also prevents denominator == 0.
            if (denominator <= prod1) {
                Panic.panic(ternary(denominator == 0, Panic.DIVISION_BY_ZERO, Panic.UNDER_OVERFLOW));
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

                // Flip twos such that it is 2²⁵⁶ / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2²⁵⁶. Now that denominator is an odd number, it has an inverse modulo 2²⁵⁶ such
            // that denominator * inv ≡ 1 mod 2²⁵⁶. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv ≡ 1 mod 2⁴.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also
            // works in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2⁸
            inverse *= 2 - denominator * inverse; // inverse mod 2¹⁶
            inverse *= 2 - denominator * inverse; // inverse mod 2³²
            inverse *= 2 - denominator * inverse; // inverse mod 2⁶⁴
            inverse *= 2 - denominator * inverse; // inverse mod 2¹²⁸
            inverse *= 2 - denominator * inverse; // inverse mod 2²⁵⁶

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2²⁵⁶. Since the preconditions guarantee that the outcome is
            // less than 2²⁵⁶, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @dev Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        return mulDiv(x, y, denominator) + SafeCast.toUint(unsignedRoundsUp(rounding) && mulmod(x, y, denominator) > 0);
    }

    /**
     * @dev Calculate the modular multiplicative inverse of a number in Z/nZ.
     *
     * If n is a prime, then Z/nZ is a field. In that case all elements are inversible, except 0.
     * If n is not a prime, then Z/nZ is not a field, and some elements might not be inversible.
     *
     * If the input value is not inversible, 0 is returned.
     *
     * NOTE: If you know for sure that n is (big) a prime, it may be cheaper to use Fermat's little theorem and get the
     * inverse using `Math.modExp(a, n - 2, n)`. See {invModPrime}.
     */
    function invMod(uint256 a, uint256 n) internal pure returns (uint256) {
        unchecked {
            if (n == 0) return 0;

            // The inverse modulo is calculated using the Extended Euclidean Algorithm (iterative version)
            // Used to compute integers x and y such that: ax + ny = gcd(a, n).
            // When the gcd is 1, then the inverse of a modulo n exists and it's x.
            // ax + ny = 1
            // ax = 1 + (-y)n
            // ax ≡ 1 (mod n) # x is the inverse of a modulo n

            // If the remainder is 0 the gcd is n right away.
            uint256 remainder = a % n;
            uint256 gcd = n;

            // Therefore the initial coefficients are:
            // ax + ny = gcd(a, n) = n
            // 0a + 1n = n
            int256 x = 0;
            int256 y = 1;

            while (remainder != 0) {
                uint256 quotient = gcd / remainder;

                (gcd, remainder) = (
                    // The old remainder is the next gcd to try.
                    remainder,
                    // Compute the next remainder.
                    // Can't overflow given that (a % gcd) * (gcd // (a % gcd)) <= gcd
                    // where gcd is at most n (capped to type(uint256).max)
                    gcd - remainder * quotient
                );

                (x, y) = (
                    // Increment the coefficient of a.
                    y,
                    // Decrement the coefficient of n.
                    // Can overflow, but the result is casted to uint256 so that the
                    // next value of y is "wrapped around" to a value between 0 and n - 1.
                    x - y * int256(quotient)
                );
            }

            if (gcd != 1) return 0; // No inverse exists.
            return ternary(x < 0, n - uint256(-x), uint256(x)); // Wrap the result if it's negative.
        }
    }

    /**
     * @dev Variant of {invMod}. More efficient, but only works if `p` is known to be a prime greater than `2`.
     *
     * From https://en.wikipedia.org/wiki/Fermat%27s_little_theorem[Fermat's little theorem], we know that if p is
     * prime, then `a**(p-1) ≡ 1 mod p`. As a consequence, we have `a * a**(p-2) ≡ 1 mod p`, which means that
     * `a**(p-2)` is the modular multiplicative inverse of a in Fp.
     *
     * NOTE: this function does NOT check that `p` is a prime greater than `2`.
     */
    function invModPrime(uint256 a, uint256 p) internal view returns (uint256) {
        unchecked {
            return Math.modExp(a, p - 2, p);
        }
    }

    /**
     * @dev Returns the modular exponentiation of the specified base, exponent and modulus (b ** e % m)
     *
     * Requirements:
     * - modulus can't be zero
     * - underlying staticcall to precompile must succeed
     *
     * IMPORTANT: The result is only valid if the underlying call succeeds. When using this function, make
     * sure the chain you're using it on supports the precompiled contract for modular exponentiation
     * at address 0x05 as specified in https://eips.ethereum.org/EIPS/eip-198[EIP-198]. Otherwise,
     * the underlying function will succeed given the lack of a revert, but the result may be incorrectly
     * interpreted as 0.
     */
    function modExp(uint256 b, uint256 e, uint256 m) internal view returns (uint256) {
        (bool success, uint256 result) = tryModExp(b, e, m);
        if (!success) {
            Panic.panic(Panic.DIVISION_BY_ZERO);
        }
        return result;
    }

    /**
     * @dev Returns the modular exponentiation of the specified base, exponent and modulus (b ** e % m).
     * It includes a success flag indicating if the operation succeeded. Operation will be marked as failed if trying
     * to operate modulo 0 or if the underlying precompile reverted.
     *
     * IMPORTANT: The result is only valid if the success flag is true. When using this function, make sure the chain
     * you're using it on supports the precompiled contract for modular exponentiation at address 0x05 as specified in
     * https://eips.ethereum.org/EIPS/eip-198[EIP-198]. Otherwise, the underlying function will succeed given the lack
     * of a revert, but the result may be incorrectly interpreted as 0.
     */
    function tryModExp(uint256 b, uint256 e, uint256 m) internal view returns (bool success, uint256 result) {
        if (m == 0) return (false, 0);
        assembly ("memory-safe") {
            let ptr := mload(0x40)
            // | Offset    | Content    | Content (Hex)                                                      |
            // |-----------|------------|--------------------------------------------------------------------|
            // | 0x00:0x1f | size of b  | 0x0000000000000000000000000000000000000000000000000000000000000020 |
            // | 0x20:0x3f | size of e  | 0x0000000000000000000000000000000000000000000000000000000000000020 |
            // | 0x40:0x5f | size of m  | 0x0000000000000000000000000000000000000000000000000000000000000020 |
            // | 0x60:0x7f | value of b | 0x<.............................................................b> |
            // | 0x80:0x9f | value of e | 0x<.............................................................e> |
            // | 0xa0:0xbf | value of m | 0x<.............................................................m> |
            mstore(ptr, 0x20)
            mstore(add(ptr, 0x20), 0x20)
            mstore(add(ptr, 0x40), 0x20)
            mstore(add(ptr, 0x60), b)
            mstore(add(ptr, 0x80), e)
            mstore(add(ptr, 0xa0), m)

            // Given the result < m, it's guaranteed to fit in 32 bytes,
            // so we can use the memory scratch space located at offset 0.
            success := staticcall(gas(), 0x05, ptr, 0xc0, 0x00, 0x20)
            result := mload(0x00)
        }
    }

    /**
     * @dev Variant of {modExp} that supports inputs of arbitrary length.
     */
    function modExp(bytes memory b, bytes memory e, bytes memory m) internal view returns (bytes memory) {
        (bool success, bytes memory result) = tryModExp(b, e, m);
        if (!success) {
            Panic.panic(Panic.DIVISION_BY_ZERO);
        }
        return result;
    }

    /**
     * @dev Variant of {tryModExp} that supports inputs of arbitrary length.
     */
    function tryModExp(
        bytes memory b,
        bytes memory e,
        bytes memory m
    ) internal view returns (bool success, bytes memory result) {
        if (_zeroBytes(m)) return (false, new bytes(0));

        uint256 mLen = m.length;

        // Encode call args in result and move the free memory pointer
        result = abi.encodePacked(b.length, e.length, mLen, b, e, m);

        assembly ("memory-safe") {
            let dataPtr := add(result, 0x20)
            // Write result on top of args to avoid allocating extra memory.
            success := staticcall(gas(), 0x05, dataPtr, mload(result), dataPtr, mLen)
            // Overwrite the length.
            // result.length > returndatasize() is guaranteed because returndatasize() == m.length
            mstore(result, mLen)
            // Set the memory pointer after the returned data.
            mstore(0x40, add(dataPtr, mLen))
        }
    }

    /**
     * @dev Returns whether the provided byte array is zero.
     */
    function _zeroBytes(bytes memory byteArray) private pure returns (bool) {
        for (uint256 i = 0; i < byteArray.length; ++i) {
            if (byteArray[i] != 0) {
                return false;
            }
        }
        return true;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded
     * towards zero.
     *
     * This method is based on Newton's method for computing square roots; the algorithm is restricted to only
     * using integer operations.
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        unchecked {
            // Take care of easy edge cases when a == 0 or a == 1
            if (a <= 1) {
                return a;
            }

            // In this function, we use Newton's method to get a root of `f(x) := x² - a`. It involves building a
            // sequence x_n that converges toward sqrt(a). For each iteration x_n, we also define the error between
            // the current value as `ε_n = | x_n - sqrt(a) |`.
            //
            // For our first estimation, we consider `e` the smallest power of 2 which is bigger than the square root
            // of the target. (i.e. `2**(e-1) ≤ sqrt(a) < 2**e`). We know that `e ≤ 128` because `(2¹²⁸)² = 2²⁵⁶` is
            // bigger than any uint256.
            //
            // By noticing that
            // `2**(e-1) ≤ sqrt(a) < 2**e → (2**(e-1))² ≤ a < (2**e)² → 2**(2*e-2) ≤ a < 2**(2*e)`
            // we can deduce that `e - 1` is `log2(a) / 2`. We can thus compute `x_n = 2**(e-1)` using a method similar
            // to the msb function.
            uint256 aa = a;
            uint256 xn = 1;

            if (aa >= (1 << 128)) {
                aa >>= 128;
                xn <<= 64;
            }
            if (aa >= (1 << 64)) {
                aa >>= 64;
                xn <<= 32;
            }
            if (aa >= (1 << 32)) {
                aa >>= 32;
                xn <<= 16;
            }
            if (aa >= (1 << 16)) {
                aa >>= 16;
                xn <<= 8;
            }
            if (aa >= (1 << 8)) {
                aa >>= 8;
                xn <<= 4;
            }
            if (aa >= (1 << 4)) {
                aa >>= 4;
                xn <<= 2;
            }
            if (aa >= (1 << 2)) {
                xn <<= 1;
            }

            // We now have x_n such that `x_n = 2**(e-1) ≤ sqrt(a) < 2**e = 2 * x_n`. This implies ε_n ≤ 2**(e-1).
            //
            // We can refine our estimation by noticing that the middle of that interval minimizes the error.
            // If we move x_n to equal 2**(e-1) + 2**(e-2), then we reduce the error to ε_n ≤ 2**(e-2).
            // This is going to be our x_0 (and ε_0)
            xn = (3 * xn) >> 1; // ε_0 := | x_0 - sqrt(a) | ≤ 2**(e-2)

            // From here, Newton's method give us:
            // x_{n+1} = (x_n + a / x_n) / 2
            //
            // One should note that:
            // x_{n+1}² - a = ((x_n + a / x_n) / 2)² - a
            //              = ((x_n² + a) / (2 * x_n))² - a
            //              = (x_n⁴ + 2 * a * x_n² + a²) / (4 * x_n²) - a
            //              = (x_n⁴ + 2 * a * x_n² + a² - 4 * a * x_n²) / (4 * x_n²)
            //              = (x_n⁴ - 2 * a * x_n² + a²) / (4 * x_n²)
            //              = (x_n² - a)² / (2 * x_n)²
            //              = ((x_n² - a) / (2 * x_n))²
            //              ≥ 0
            // Which proves that for all n ≥ 1, sqrt(a) ≤ x_n
            //
            // This gives us the proof of quadratic convergence of the sequence:
            // ε_{n+1} = | x_{n+1} - sqrt(a) |
            //         = | (x_n + a / x_n) / 2 - sqrt(a) |
            //         = | (x_n² + a - 2*x_n*sqrt(a)) / (2 * x_n) |
            //         = | (x_n - sqrt(a))² / (2 * x_n) |
            //         = | ε_n² / (2 * x_n) |
            //         = ε_n² / | (2 * x_n) |
            //
            // For the first iteration, we have a special case where x_0 is known:
            // ε_1 = ε_0² / | (2 * x_0) |
            //     ≤ (2**(e-2))² / (2 * (2**(e-1) + 2**(e-2)))
            //     ≤ 2**(2*e-4) / (3 * 2**(e-1))
            //     ≤ 2**(e-3) / 3
            //     ≤ 2**(e-3-log2(3))
            //     ≤ 2**(e-4.5)
            //
            // For the following iterations, we use the fact that, 2**(e-1) ≤ sqrt(a) ≤ x_n:
            // ε_{n+1} = ε_n² / | (2 * x_n) |
            //         ≤ (2**(e-k))² / (2 * 2**(e-1))
            //         ≤ 2**(2*e-2*k) / 2**e
            //         ≤ 2**(e-2*k)
            xn = (xn + a / xn) >> 1; // ε_1 := | x_1 - sqrt(a) | ≤ 2**(e-4.5)  -- special case, see above
            xn = (xn + a / xn) >> 1; // ε_2 := | x_2 - sqrt(a) | ≤ 2**(e-9)    -- general case with k = 4.5
            xn = (xn + a / xn) >> 1; // ε_3 := | x_3 - sqrt(a) | ≤ 2**(e-18)   -- general case with k = 9
            xn = (xn + a / xn) >> 1; // ε_4 := | x_4 - sqrt(a) | ≤ 2**(e-36)   -- general case with k = 18
            xn = (xn + a / xn) >> 1; // ε_5 := | x_5 - sqrt(a) | ≤ 2**(e-72)   -- general case with k = 36
            xn = (xn + a / xn) >> 1; // ε_6 := | x_6 - sqrt(a) | ≤ 2**(e-144)  -- general case with k = 72

            // Because e ≤ 128 (as discussed during the first estimation phase), we know have reached a precision
            // ε_6 ≤ 2**(e-144) < 1. Given we're operating on integers, then we can ensure that xn is now either
            // sqrt(a) or sqrt(a) + 1.
            return xn - SafeCast.toUint(xn > a / xn);
        }
    }

    /**
     * @dev Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + SafeCast.toUint(unsignedRoundsUp(rounding) && result * result < a);
        }
    }

    /**
     * @dev Return the log in base 2 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        uint256 exp;
        unchecked {
            exp = 128 * SafeCast.toUint(value > (1 << 128) - 1);
            value >>= exp;
            result += exp;

            exp = 64 * SafeCast.toUint(value > (1 << 64) - 1);
            value >>= exp;
            result += exp;

            exp = 32 * SafeCast.toUint(value > (1 << 32) - 1);
            value >>= exp;
            result += exp;

            exp = 16 * SafeCast.toUint(value > (1 << 16) - 1);
            value >>= exp;
            result += exp;

            exp = 8 * SafeCast.toUint(value > (1 << 8) - 1);
            value >>= exp;
            result += exp;

            exp = 4 * SafeCast.toUint(value > (1 << 4) - 1);
            value >>= exp;
            result += exp;

            exp = 2 * SafeCast.toUint(value > (1 << 2) - 1);
            value >>= exp;
            result += exp;

            result += SafeCast.toUint(value > 1);
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
            return result + SafeCast.toUint(unsignedRoundsUp(rounding) && 1 << result < value);
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
            return result + SafeCast.toUint(unsignedRoundsUp(rounding) && 10 ** result < value);
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
        uint256 isGt;
        unchecked {
            isGt = SafeCast.toUint(value > (1 << 128) - 1);
            value >>= isGt * 128;
            result += isGt * 16;

            isGt = SafeCast.toUint(value > (1 << 64) - 1);
            value >>= isGt * 64;
            result += isGt * 8;

            isGt = SafeCast.toUint(value > (1 << 32) - 1);
            value >>= isGt * 32;
            result += isGt * 4;

            isGt = SafeCast.toUint(value > (1 << 16) - 1);
            value >>= isGt * 16;
            result += isGt * 2;

            result += SafeCast.toUint(value > (1 << 8) - 1);
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
            return result + SafeCast.toUint(unsignedRoundsUp(rounding) && 1 << (result << 3) < value);
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
 * @dev Wrappers over Solidity's uintXX/intXX/bool casting operators with added overflow
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

    /**
     * @dev Cast a boolean (false or true) to a uint256 (0 or 1) with no jump.
     */
    function toUint(bool b) internal pure returns (uint256 u) {
        assembly ("memory-safe") {
            u := iszero(iszero(b))
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/SignedMath.sol)

pragma solidity ^0.8.20;

import {SafeCast} from "./SafeCast.sol";

/**
 * @dev Standard signed math utilities missing in the Solidity language.
 */
library SignedMath {
    /**
     * @dev Branchless ternary evaluation for `a ? b : c`. Gas costs are constant.
     *
     * IMPORTANT: This function may reduce bytecode size and consume less gas when used standalone.
     * However, the compiler may optimize Solidity ternary operations (i.e. `a ? b : c`) to only compute
     * one branch when needed, making this function more expensive.
     */
    function ternary(bool condition, int256 a, int256 b) internal pure returns (int256) {
        unchecked {
            // branchless ternary works because:
            // b ^ (a ^ b) == a
            // b ^ 0 == b
            return b ^ ((a ^ b) * int256(SafeCast.toUint(condition)));
        }
    }

    /**
     * @dev Returns the largest of two signed numbers.
     */
    function max(int256 a, int256 b) internal pure returns (int256) {
        return ternary(a > b, a, b);
    }

    /**
     * @dev Returns the smallest of two signed numbers.
     */
    function min(int256 a, int256 b) internal pure returns (int256) {
        return ternary(a < b, a, b);
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
            // Formula from the "Bit Twiddling Hacks" by Sean Eron Anderson.
            // Since `n` is a signed integer, the generated bytecode will use the SAR opcode to perform the right shift,
            // taking advantage of the most significant (or "sign" bit) in two's complement representation.
            // This opcode adds new most significant bits set to the value of the previous most significant bit. As a result,
            // the mask will either be `bytes32(0)` (if n is positive) or `~bytes32(0)` (if n is negative).
            int256 mask = n >> 255;

            // A `bytes32(0)` mask leaves the input unchanged, while a `~bytes32(0)` mask complements it.
            return uint256((n + mask) ^ mask);
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

// Common.sol
//
// Common mathematical functions used in both SD59x18 and UD60x18. Note that these global functions do not
// always operate with SD59x18 and UD60x18 numbers.

/*//////////////////////////////////////////////////////////////////////////
                                CUSTOM ERRORS
//////////////////////////////////////////////////////////////////////////*/

/// @notice Thrown when the resultant value in {mulDiv} overflows uint256.
error PRBMath_MulDiv_Overflow(uint256 x, uint256 y, uint256 denominator);

/// @notice Thrown when the resultant value in {mulDiv18} overflows uint256.
error PRBMath_MulDiv18_Overflow(uint256 x, uint256 y);

/// @notice Thrown when one of the inputs passed to {mulDivSigned} is `type(int256).min`.
error PRBMath_MulDivSigned_InputTooSmall();

/// @notice Thrown when the resultant value in {mulDivSigned} overflows int256.
error PRBMath_MulDivSigned_Overflow(int256 x, int256 y);

/*//////////////////////////////////////////////////////////////////////////
                                    CONSTANTS
//////////////////////////////////////////////////////////////////////////*/

/// @dev The maximum value a uint128 number can have.
uint128 constant MAX_UINT128 = type(uint128).max;

/// @dev The maximum value a uint40 number can have.
uint40 constant MAX_UINT40 = type(uint40).max;

/// @dev The maximum value a uint64 number can have.
uint64 constant MAX_UINT64 = type(uint64).max;

/// @dev The unit number, which the decimal precision of the fixed-point types.
uint256 constant UNIT = 1e18;

/// @dev The unit number inverted mod 2^256.
uint256 constant UNIT_INVERSE = 78156646155174841979727994598816262306175212592076161876661_508869554232690281;

/// @dev The the largest power of two that divides the decimal value of `UNIT`. The logarithm of this value is the least significant
/// bit in the binary representation of `UNIT`.
uint256 constant UNIT_LPOTD = 262144;

/*//////////////////////////////////////////////////////////////////////////
                                    FUNCTIONS
//////////////////////////////////////////////////////////////////////////*/

/// @notice Calculates the binary exponent of x using the binary fraction method.
/// @dev Has to use 192.64-bit fixed-point numbers. See https://ethereum.stackexchange.com/a/96594/24693.
/// @param x The exponent as an unsigned 192.64-bit fixed-point number.
/// @return result The result as an unsigned 60.18-decimal fixed-point number.
/// @custom:smtchecker abstract-function-nondet
function exp2(uint256 x) pure returns (uint256 result) {
    unchecked {
        // Start from 0.5 in the 192.64-bit fixed-point format.
        result = 0x800000000000000000000000000000000000000000000000;

        // The following logic multiplies the result by $\sqrt{2^{-i}}$ when the bit at position i is 1. Key points:
        //
        // 1. Intermediate results will not overflow, as the starting point is 2^191 and all magic factors are under 2^65.
        // 2. The rationale for organizing the if statements into groups of 8 is gas savings. If the result of performing
        // a bitwise AND operation between x and any value in the array [0x80; 0x40; 0x20; 0x10; 0x08; 0x04; 0x02; 0x01] is 1,
        // we know that `x & 0xFF` is also 1.
        if (x & 0xFF00000000000000 > 0) {
            if (x & 0x8000000000000000 > 0) {
                result = (result * 0x16A09E667F3BCC909) >> 64;
            }
            if (x & 0x4000000000000000 > 0) {
                result = (result * 0x1306FE0A31B7152DF) >> 64;
            }
            if (x & 0x2000000000000000 > 0) {
                result = (result * 0x1172B83C7D517ADCE) >> 64;
            }
            if (x & 0x1000000000000000 > 0) {
                result = (result * 0x10B5586CF9890F62A) >> 64;
            }
            if (x & 0x800000000000000 > 0) {
                result = (result * 0x1059B0D31585743AE) >> 64;
            }
            if (x & 0x400000000000000 > 0) {
                result = (result * 0x102C9A3E778060EE7) >> 64;
            }
            if (x & 0x200000000000000 > 0) {
                result = (result * 0x10163DA9FB33356D8) >> 64;
            }
            if (x & 0x100000000000000 > 0) {
                result = (result * 0x100B1AFA5ABCBED61) >> 64;
            }
        }

        if (x & 0xFF000000000000 > 0) {
            if (x & 0x80000000000000 > 0) {
                result = (result * 0x10058C86DA1C09EA2) >> 64;
            }
            if (x & 0x40000000000000 > 0) {
                result = (result * 0x1002C605E2E8CEC50) >> 64;
            }
            if (x & 0x20000000000000 > 0) {
                result = (result * 0x100162F3904051FA1) >> 64;
            }
            if (x & 0x10000000000000 > 0) {
                result = (result * 0x1000B175EFFDC76BA) >> 64;
            }
            if (x & 0x8000000000000 > 0) {
                result = (result * 0x100058BA01FB9F96D) >> 64;
            }
            if (x & 0x4000000000000 > 0) {
                result = (result * 0x10002C5CC37DA9492) >> 64;
            }
            if (x & 0x2000000000000 > 0) {
                result = (result * 0x1000162E525EE0547) >> 64;
            }
            if (x & 0x1000000000000 > 0) {
                result = (result * 0x10000B17255775C04) >> 64;
            }
        }

        if (x & 0xFF0000000000 > 0) {
            if (x & 0x800000000000 > 0) {
                result = (result * 0x1000058B91B5BC9AE) >> 64;
            }
            if (x & 0x400000000000 > 0) {
                result = (result * 0x100002C5C89D5EC6D) >> 64;
            }
            if (x & 0x200000000000 > 0) {
                result = (result * 0x10000162E43F4F831) >> 64;
            }
            if (x & 0x100000000000 > 0) {
                result = (result * 0x100000B1721BCFC9A) >> 64;
            }
            if (x & 0x80000000000 > 0) {
                result = (result * 0x10000058B90CF1E6E) >> 64;
            }
            if (x & 0x40000000000 > 0) {
                result = (result * 0x1000002C5C863B73F) >> 64;
            }
            if (x & 0x20000000000 > 0) {
                result = (result * 0x100000162E430E5A2) >> 64;
            }
            if (x & 0x10000000000 > 0) {
                result = (result * 0x1000000B172183551) >> 64;
            }
        }

        if (x & 0xFF00000000 > 0) {
            if (x & 0x8000000000 > 0) {
                result = (result * 0x100000058B90C0B49) >> 64;
            }
            if (x & 0x4000000000 > 0) {
                result = (result * 0x10000002C5C8601CC) >> 64;
            }
            if (x & 0x2000000000 > 0) {
                result = (result * 0x1000000162E42FFF0) >> 64;
            }
            if (x & 0x1000000000 > 0) {
                result = (result * 0x10000000B17217FBB) >> 64;
            }
            if (x & 0x800000000 > 0) {
                result = (result * 0x1000000058B90BFCE) >> 64;
            }
            if (x & 0x400000000 > 0) {
                result = (result * 0x100000002C5C85FE3) >> 64;
            }
            if (x & 0x200000000 > 0) {
                result = (result * 0x10000000162E42FF1) >> 64;
            }
            if (x & 0x100000000 > 0) {
                result = (result * 0x100000000B17217F8) >> 64;
            }
        }

        if (x & 0xFF000000 > 0) {
            if (x & 0x80000000 > 0) {
                result = (result * 0x10000000058B90BFC) >> 64;
            }
            if (x & 0x40000000 > 0) {
                result = (result * 0x1000000002C5C85FE) >> 64;
            }
            if (x & 0x20000000 > 0) {
                result = (result * 0x100000000162E42FF) >> 64;
            }
            if (x & 0x10000000 > 0) {
                result = (result * 0x1000000000B17217F) >> 64;
            }
            if (x & 0x8000000 > 0) {
                result = (result * 0x100000000058B90C0) >> 64;
            }
            if (x & 0x4000000 > 0) {
                result = (result * 0x10000000002C5C860) >> 64;
            }
            if (x & 0x2000000 > 0) {
                result = (result * 0x1000000000162E430) >> 64;
            }
            if (x & 0x1000000 > 0) {
                result = (result * 0x10000000000B17218) >> 64;
            }
        }

        if (x & 0xFF0000 > 0) {
            if (x & 0x800000 > 0) {
                result = (result * 0x1000000000058B90C) >> 64;
            }
            if (x & 0x400000 > 0) {
                result = (result * 0x100000000002C5C86) >> 64;
            }
            if (x & 0x200000 > 0) {
                result = (result * 0x10000000000162E43) >> 64;
            }
            if (x & 0x100000 > 0) {
                result = (result * 0x100000000000B1721) >> 64;
            }
            if (x & 0x80000 > 0) {
                result = (result * 0x10000000000058B91) >> 64;
            }
            if (x & 0x40000 > 0) {
                result = (result * 0x1000000000002C5C8) >> 64;
            }
            if (x & 0x20000 > 0) {
                result = (result * 0x100000000000162E4) >> 64;
            }
            if (x & 0x10000 > 0) {
                result = (result * 0x1000000000000B172) >> 64;
            }
        }

        if (x & 0xFF00 > 0) {
            if (x & 0x8000 > 0) {
                result = (result * 0x100000000000058B9) >> 64;
            }
            if (x & 0x4000 > 0) {
                result = (result * 0x10000000000002C5D) >> 64;
            }
            if (x & 0x2000 > 0) {
                result = (result * 0x1000000000000162E) >> 64;
            }
            if (x & 0x1000 > 0) {
                result = (result * 0x10000000000000B17) >> 64;
            }
            if (x & 0x800 > 0) {
                result = (result * 0x1000000000000058C) >> 64;
            }
            if (x & 0x400 > 0) {
                result = (result * 0x100000000000002C6) >> 64;
            }
            if (x & 0x200 > 0) {
                result = (result * 0x10000000000000163) >> 64;
            }
            if (x & 0x100 > 0) {
                result = (result * 0x100000000000000B1) >> 64;
            }
        }

        if (x & 0xFF > 0) {
            if (x & 0x80 > 0) {
                result = (result * 0x10000000000000059) >> 64;
            }
            if (x & 0x40 > 0) {
                result = (result * 0x1000000000000002C) >> 64;
            }
            if (x & 0x20 > 0) {
                result = (result * 0x10000000000000016) >> 64;
            }
            if (x & 0x10 > 0) {
                result = (result * 0x1000000000000000B) >> 64;
            }
            if (x & 0x8 > 0) {
                result = (result * 0x10000000000000006) >> 64;
            }
            if (x & 0x4 > 0) {
                result = (result * 0x10000000000000003) >> 64;
            }
            if (x & 0x2 > 0) {
                result = (result * 0x10000000000000001) >> 64;
            }
            if (x & 0x1 > 0) {
                result = (result * 0x10000000000000001) >> 64;
            }
        }

        // In the code snippet below, two operations are executed simultaneously:
        //
        // 1. The result is multiplied by $(2^n + 1)$, where $2^n$ represents the integer part, and the additional 1
        // accounts for the initial guess of 0.5. This is achieved by subtracting from 191 instead of 192.
        // 2. The result is then converted to an unsigned 60.18-decimal fixed-point format.
        //
        // The underlying logic is based on the relationship $2^{191-ip} = 2^{ip} / 2^{191}$, where $ip$ denotes the,
        // integer part, $2^n$.
        result *= UNIT;
        result >>= (191 - (x >> 64));
    }
}

/// @notice Finds the zero-based index of the first 1 in the binary representation of x.
///
/// @dev See the note on "msb" in this Wikipedia article: https://en.wikipedia.org/wiki/Find_first_set
///
/// Each step in this implementation is equivalent to this high-level code:
///
/// ```solidity
/// if (x >= 2 ** 128) {
///     x >>= 128;
///     result += 128;
/// }
/// ```
///
/// Where 128 is replaced with each respective power of two factor. See the full high-level implementation here:
/// https://gist.github.com/PaulRBerg/f932f8693f2733e30c4d479e8e980948
///
/// The Yul instructions used below are:
///
/// - "gt" is "greater than"
/// - "or" is the OR bitwise operator
/// - "shl" is "shift left"
/// - "shr" is "shift right"
///
/// @param x The uint256 number for which to find the index of the most significant bit.
/// @return result The index of the most significant bit as a uint256.
/// @custom:smtchecker abstract-function-nondet
function msb(uint256 x) pure returns (uint256 result) {
    // 2^128
    assembly ("memory-safe") {
        let factor := shl(7, gt(x, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF))
        x := shr(factor, x)
        result := or(result, factor)
    }
    // 2^64
    assembly ("memory-safe") {
        let factor := shl(6, gt(x, 0xFFFFFFFFFFFFFFFF))
        x := shr(factor, x)
        result := or(result, factor)
    }
    // 2^32
    assembly ("memory-safe") {
        let factor := shl(5, gt(x, 0xFFFFFFFF))
        x := shr(factor, x)
        result := or(result, factor)
    }
    // 2^16
    assembly ("memory-safe") {
        let factor := shl(4, gt(x, 0xFFFF))
        x := shr(factor, x)
        result := or(result, factor)
    }
    // 2^8
    assembly ("memory-safe") {
        let factor := shl(3, gt(x, 0xFF))
        x := shr(factor, x)
        result := or(result, factor)
    }
    // 2^4
    assembly ("memory-safe") {
        let factor := shl(2, gt(x, 0xF))
        x := shr(factor, x)
        result := or(result, factor)
    }
    // 2^2
    assembly ("memory-safe") {
        let factor := shl(1, gt(x, 0x3))
        x := shr(factor, x)
        result := or(result, factor)
    }
    // 2^1
    // No need to shift x any more.
    assembly ("memory-safe") {
        let factor := gt(x, 0x1)
        result := or(result, factor)
    }
}

/// @notice Calculates x*y÷denominator with 512-bit precision.
///
/// @dev Credits to Remco Bloemen under MIT license https://xn--2-umb.com/21/muldiv.
///
/// Notes:
/// - The result is rounded toward zero.
///
/// Requirements:
/// - The denominator must not be zero.
/// - The result must fit in uint256.
///
/// @param x The multiplicand as a uint256.
/// @param y The multiplier as a uint256.
/// @param denominator The divisor as a uint256.
/// @return result The result as a uint256.
/// @custom:smtchecker abstract-function-nondet
function mulDiv(uint256 x, uint256 y, uint256 denominator) pure returns (uint256 result) {
    // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
    // use the Chinese Remainder Theorem to reconstruct the 512-bit result. The result is stored in two 256
    // variables such that product = prod1 * 2^256 + prod0.
    uint256 prod0; // Least significant 256 bits of the product
    uint256 prod1; // Most significant 256 bits of the product
    assembly ("memory-safe") {
        let mm := mulmod(x, y, not(0))
        prod0 := mul(x, y)
        prod1 := sub(sub(mm, prod0), lt(mm, prod0))
    }

    // Handle non-overflow cases, 256 by 256 division.
    if (prod1 == 0) {
        unchecked {
            return prod0 / denominator;
        }
    }

    // Make sure the result is less than 2^256. Also prevents denominator == 0.
    if (prod1 >= denominator) {
        revert PRBMath_MulDiv_Overflow(x, y, denominator);
    }

    ////////////////////////////////////////////////////////////////////////////
    // 512 by 256 division
    ////////////////////////////////////////////////////////////////////////////

    // Make division exact by subtracting the remainder from [prod1 prod0].
    uint256 remainder;
    assembly ("memory-safe") {
        // Compute remainder using the mulmod Yul instruction.
        remainder := mulmod(x, y, denominator)

        // Subtract 256 bit number from 512-bit number.
        prod1 := sub(prod1, gt(remainder, prod0))
        prod0 := sub(prod0, remainder)
    }

    unchecked {
        // Calculate the largest power of two divisor of the denominator using the unary operator ~. This operation cannot overflow
        // because the denominator cannot be zero at this point in the function execution. The result is always >= 1.
        // For more detail, see https://cs.stackexchange.com/q/138556/92363.
        uint256 lpotdod = denominator & (~denominator + 1);
        uint256 flippedLpotdod;

        assembly ("memory-safe") {
            // Factor powers of two out of denominator.
            denominator := div(denominator, lpotdod)

            // Divide [prod1 prod0] by lpotdod.
            prod0 := div(prod0, lpotdod)

            // Get the flipped value `2^256 / lpotdod`. If the `lpotdod` is zero, the flipped value is one.
            // `sub(0, lpotdod)` produces the two's complement version of `lpotdod`, which is equivalent to flipping all the bits.
            // However, `div` interprets this value as an unsigned value: https://ethereum.stackexchange.com/q/147168/24693
            flippedLpotdod := add(div(sub(0, lpotdod), lpotdod), 1)
        }

        // Shift in bits from prod1 into prod0.
        prod0 |= prod1 * flippedLpotdod;

        // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
        // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
        // four bits. That is, denominator * inv = 1 mod 2^4.
        uint256 inverse = (3 * denominator) ^ 2;

        // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
        // in modular arithmetic, doubling the correct bits in each step.
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
    }
}

/// @notice Calculates x*y÷1e18 with 512-bit precision.
///
/// @dev A variant of {mulDiv} with constant folding, i.e. in which the denominator is hard coded to 1e18.
///
/// Notes:
/// - The body is purposely left uncommented; to understand how this works, see the documentation in {mulDiv}.
/// - The result is rounded toward zero.
/// - We take as an axiom that the result cannot be `MAX_UINT256` when x and y solve the following system of equations:
///
/// $$
/// \begin{cases}
///     x * y = MAX\_UINT256 * UNIT \\
///     (x * y) \% UNIT \geq \frac{UNIT}{2}
/// \end{cases}
/// $$
///
/// Requirements:
/// - Refer to the requirements in {mulDiv}.
/// - The result must fit in uint256.
///
/// @param x The multiplicand as an unsigned 60.18-decimal fixed-point number.
/// @param y The multiplier as an unsigned 60.18-decimal fixed-point number.
/// @return result The result as an unsigned 60.18-decimal fixed-point number.
/// @custom:smtchecker abstract-function-nondet
function mulDiv18(uint256 x, uint256 y) pure returns (uint256 result) {
    uint256 prod0;
    uint256 prod1;
    assembly ("memory-safe") {
        let mm := mulmod(x, y, not(0))
        prod0 := mul(x, y)
        prod1 := sub(sub(mm, prod0), lt(mm, prod0))
    }

    if (prod1 == 0) {
        unchecked {
            return prod0 / UNIT;
        }
    }

    if (prod1 >= UNIT) {
        revert PRBMath_MulDiv18_Overflow(x, y);
    }

    uint256 remainder;
    assembly ("memory-safe") {
        remainder := mulmod(x, y, UNIT)
        result :=
            mul(
                or(
                    div(sub(prod0, remainder), UNIT_LPOTD),
                    mul(sub(prod1, gt(remainder, prod0)), add(div(sub(0, UNIT_LPOTD), UNIT_LPOTD), 1))
                ),
                UNIT_INVERSE
            )
    }
}

/// @notice Calculates x*y÷denominator with 512-bit precision.
///
/// @dev This is an extension of {mulDiv} for signed numbers, which works by computing the signs and the absolute values separately.
///
/// Notes:
/// - The result is rounded toward zero.
///
/// Requirements:
/// - Refer to the requirements in {mulDiv}.
/// - None of the inputs can be `type(int256).min`.
/// - The result must fit in int256.
///
/// @param x The multiplicand as an int256.
/// @param y The multiplier as an int256.
/// @param denominator The divisor as an int256.
/// @return result The result as an int256.
/// @custom:smtchecker abstract-function-nondet
function mulDivSigned(int256 x, int256 y, int256 denominator) pure returns (int256 result) {
    if (x == type(int256).min || y == type(int256).min || denominator == type(int256).min) {
        revert PRBMath_MulDivSigned_InputTooSmall();
    }

    // Get hold of the absolute values of x, y and the denominator.
    uint256 xAbs;
    uint256 yAbs;
    uint256 dAbs;
    unchecked {
        xAbs = x < 0 ? uint256(-x) : uint256(x);
        yAbs = y < 0 ? uint256(-y) : uint256(y);
        dAbs = denominator < 0 ? uint256(-denominator) : uint256(denominator);
    }

    // Compute the absolute value of x*y÷denominator. The result must fit in int256.
    uint256 resultAbs = mulDiv(xAbs, yAbs, dAbs);
    if (resultAbs > uint256(type(int256).max)) {
        revert PRBMath_MulDivSigned_Overflow(x, y);
    }

    // Get the signs of x, y and the denominator.
    uint256 sx;
    uint256 sy;
    uint256 sd;
    assembly ("memory-safe") {
        // "sgt" is the "signed greater than" assembly instruction and "sub(0,1)" is -1 in two's complement.
        sx := sgt(x, sub(0, 1))
        sy := sgt(y, sub(0, 1))
        sd := sgt(denominator, sub(0, 1))
    }

    // XOR over sx, sy and sd. What this does is to check whether there are 1 or 3 negative signs in the inputs.
    // If there are, the result should be negative. Otherwise, it should be positive.
    unchecked {
        result = sx ^ sy ^ sd == 0 ? -int256(resultAbs) : int256(resultAbs);
    }
}

/// @notice Calculates the square root of x using the Babylonian method.
///
/// @dev See https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method.
///
/// Notes:
/// - If x is not a perfect square, the result is rounded down.
/// - Credits to OpenZeppelin for the explanations in comments below.
///
/// @param x The uint256 number for which to calculate the square root.
/// @return result The result as a uint256.
/// @custom:smtchecker abstract-function-nondet
function sqrt(uint256 x) pure returns (uint256 result) {
    if (x == 0) {
        return 0;
    }

    // For our first guess, we calculate the biggest power of 2 which is smaller than the square root of x.
    //
    // We know that the "msb" (most significant bit) of x is a power of 2 such that we have:
    //
    // $$
    // msb(x) <= x <= 2*msb(x)$
    // $$
    //
    // We write $msb(x)$ as $2^k$, and we get:
    //
    // $$
    // k = log_2(x)
    // $$
    //
    // Thus, we can write the initial inequality as:
    //
    // $$
    // 2^{log_2(x)} <= x <= 2*2^{log_2(x)+1} \\
    // sqrt(2^k) <= sqrt(x) < sqrt(2^{k+1}) \\
    // 2^{k/2} <= sqrt(x) < 2^{(k+1)/2} <= 2^{(k/2)+1}
    // $$
    //
    // Consequently, $2^{log_2(x) /2} is a good first approximation of sqrt(x) with at least one correct bit.
    uint256 xAux = uint256(x);
    result = 1;
    if (xAux >= 2 ** 128) {
        xAux >>= 128;
        result <<= 64;
    }
    if (xAux >= 2 ** 64) {
        xAux >>= 64;
        result <<= 32;
    }
    if (xAux >= 2 ** 32) {
        xAux >>= 32;
        result <<= 16;
    }
    if (xAux >= 2 ** 16) {
        xAux >>= 16;
        result <<= 8;
    }
    if (xAux >= 2 ** 8) {
        xAux >>= 8;
        result <<= 4;
    }
    if (xAux >= 2 ** 4) {
        xAux >>= 4;
        result <<= 2;
    }
    if (xAux >= 2 ** 2) {
        result <<= 1;
    }

    // At this point, `result` is an estimation with at least one bit of precision. We know the true value has at
    // most 128 bits, since it is the square root of a uint256. Newton's method converges quadratically (precision
    // doubles at every iteration). We thus need at most 7 iteration to turn our partial result with one bit of
    // precision into the expected uint128 result.
    unchecked {
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;

        // If x is not a perfect square, round the result toward zero.
        uint256 roundedResult = x / result;
        if (result >= roundedResult) {
            result = roundedResult;
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

/*

██████╗ ██████╗ ██████╗ ███╗   ███╗ █████╗ ████████╗██╗  ██╗
██╔══██╗██╔══██╗██╔══██╗████╗ ████║██╔══██╗╚══██╔══╝██║  ██║
██████╔╝██████╔╝██████╔╝██╔████╔██║███████║   ██║   ███████║
██╔═══╝ ██╔══██╗██╔══██╗██║╚██╔╝██║██╔══██║   ██║   ██╔══██║
██║     ██║  ██║██████╔╝██║ ╚═╝ ██║██║  ██║   ██║   ██║  ██║
╚═╝     ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝

██╗   ██╗██████╗  ██████╗  ██████╗ ██╗  ██╗ ██╗ █████╗
██║   ██║██╔══██╗██╔════╝ ██╔═████╗╚██╗██╔╝███║██╔══██╗
██║   ██║██║  ██║███████╗ ██║██╔██║ ╚███╔╝ ╚██║╚█████╔╝
██║   ██║██║  ██║██╔═══██╗████╔╝██║ ██╔██╗  ██║██╔══██╗
╚██████╔╝██████╔╝╚██████╔╝╚██████╔╝██╔╝ ██╗ ██║╚█████╔╝
 ╚═════╝ ╚═════╝  ╚═════╝  ╚═════╝ ╚═╝  ╚═╝ ╚═╝ ╚════╝

*/

import "./ud60x18/Casting.sol";
import "./ud60x18/Constants.sol";
import "./ud60x18/Conversions.sol";
import "./ud60x18/Errors.sol";
import "./ud60x18/Helpers.sol";
import "./ud60x18/Math.sol";
import "./ud60x18/ValueType.sol";
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "../Common.sol" as Common;
import "./Errors.sol" as CastingErrors;
import { SD59x18 } from "../sd59x18/ValueType.sol";
import { UD60x18 } from "../ud60x18/ValueType.sol";
import { SD1x18 } from "./ValueType.sol";

/// @notice Casts an SD1x18 number into SD59x18.
/// @dev There is no overflow check because SD1x18 ⊆ SD59x18.
function intoSD59x18(SD1x18 x) pure returns (SD59x18 result) {
    result = SD59x18.wrap(int256(SD1x18.unwrap(x)));
}

/// @notice Casts an SD1x18 number into UD60x18.
/// @dev Requirements:
/// - x ≥ 0
function intoUD60x18(SD1x18 x) pure returns (UD60x18 result) {
    int64 xInt = SD1x18.unwrap(x);
    if (xInt < 0) {
        revert CastingErrors.PRBMath_SD1x18_ToUD60x18_Underflow(x);
    }
    result = UD60x18.wrap(uint64(xInt));
}

/// @notice Casts an SD1x18 number into uint128.
/// @dev Requirements:
/// - x ≥ 0
function intoUint128(SD1x18 x) pure returns (uint128 result) {
    int64 xInt = SD1x18.unwrap(x);
    if (xInt < 0) {
        revert CastingErrors.PRBMath_SD1x18_ToUint128_Underflow(x);
    }
    result = uint128(uint64(xInt));
}

/// @notice Casts an SD1x18 number into uint256.
/// @dev Requirements:
/// - x ≥ 0
function intoUint256(SD1x18 x) pure returns (uint256 result) {
    int64 xInt = SD1x18.unwrap(x);
    if (xInt < 0) {
        revert CastingErrors.PRBMath_SD1x18_ToUint256_Underflow(x);
    }
    result = uint256(uint64(xInt));
}

/// @notice Casts an SD1x18 number into uint40.
/// @dev Requirements:
/// - x ≥ 0
/// - x ≤ MAX_UINT40
function intoUint40(SD1x18 x) pure returns (uint40 result) {
    int64 xInt = SD1x18.unwrap(x);
    if (xInt < 0) {
        revert CastingErrors.PRBMath_SD1x18_ToUint40_Underflow(x);
    }
    if (xInt > int64(uint64(Common.MAX_UINT40))) {
        revert CastingErrors.PRBMath_SD1x18_ToUint40_Overflow(x);
    }
    result = uint40(uint64(xInt));
}

/// @notice Alias for {wrap}.
function sd1x18(int64 x) pure returns (SD1x18 result) {
    result = SD1x18.wrap(x);
}

/// @notice Unwraps an SD1x18 number into int64.
function unwrap(SD1x18 x) pure returns (int64 result) {
    result = SD1x18.unwrap(x);
}

/// @notice Wraps an int64 number into SD1x18.
function wrap(int64 x) pure returns (SD1x18 result) {
    result = SD1x18.wrap(x);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { SD1x18 } from "./ValueType.sol";

/// @dev Euler's number as an SD1x18 number.
SD1x18 constant E = SD1x18.wrap(2_718281828459045235);

/// @dev The maximum value an SD1x18 number can have.
int64 constant uMAX_SD1x18 = 9_223372036854775807;
SD1x18 constant MAX_SD1x18 = SD1x18.wrap(uMAX_SD1x18);

/// @dev The minimum value an SD1x18 number can have.
int64 constant uMIN_SD1x18 = -9_223372036854775808;
SD1x18 constant MIN_SD1x18 = SD1x18.wrap(uMIN_SD1x18);

/// @dev PI as an SD1x18 number.
SD1x18 constant PI = SD1x18.wrap(3_141592653589793238);

/// @dev The unit number, which gives the decimal precision of SD1x18.
SD1x18 constant UNIT = SD1x18.wrap(1e18);
int64 constant uUNIT = 1e18;
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { SD1x18 } from "./ValueType.sol";

/// @notice Thrown when trying to cast an SD1x18 number that doesn't fit in UD60x18.
error PRBMath_SD1x18_ToUD60x18_Underflow(SD1x18 x);

/// @notice Thrown when trying to cast an SD1x18 number that doesn't fit in uint128.
error PRBMath_SD1x18_ToUint128_Underflow(SD1x18 x);

/// @notice Thrown when trying to cast an SD1x18 number that doesn't fit in uint256.
error PRBMath_SD1x18_ToUint256_Underflow(SD1x18 x);

/// @notice Thrown when trying to cast an SD1x18 number that doesn't fit in uint40.
error PRBMath_SD1x18_ToUint40_Overflow(SD1x18 x);

/// @notice Thrown when trying to cast an SD1x18 number that doesn't fit in uint40.
error PRBMath_SD1x18_ToUint40_Underflow(SD1x18 x);
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "./Casting.sol" as Casting;

/// @notice The signed 1.18-decimal fixed-point number representation, which can have up to 1 digit and up to 18
/// decimals. The values of this are bound by the minimum and the maximum values permitted by the underlying Solidity
/// type int64. This is useful when end users want to use int64 to save gas, e.g. with tight variable packing in contract
/// storage.
type SD1x18 is int64;

/*//////////////////////////////////////////////////////////////////////////
                                    CASTING
//////////////////////////////////////////////////////////////////////////*/

using {
    Casting.intoSD59x18,
    Casting.intoUD60x18,
    Casting.intoUint128,
    Casting.intoUint256,
    Casting.intoUint40,
    Casting.unwrap
} for SD1x18 global;
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "../Common.sol" as Common;
import "./Errors.sol" as CastingErrors;
import { SD59x18 } from "../sd59x18/ValueType.sol";
import { UD60x18 } from "../ud60x18/ValueType.sol";
import { SD21x18 } from "./ValueType.sol";

/// @notice Casts an SD21x18 number into SD59x18.
/// @dev There is no overflow check because SD21x18 ⊆ SD59x18.
function intoSD59x18(SD21x18 x) pure returns (SD59x18 result) {
    result = SD59x18.wrap(int256(SD21x18.unwrap(x)));
}

/// @notice Casts an SD21x18 number into UD60x18.
/// @dev Requirements:
/// - x ≥ 0
function intoUD60x18(SD21x18 x) pure returns (UD60x18 result) {
    int128 xInt = SD21x18.unwrap(x);
    if (xInt < 0) {
        revert CastingErrors.PRBMath_SD21x18_ToUD60x18_Underflow(x);
    }
    result = UD60x18.wrap(uint128(xInt));
}

/// @notice Casts an SD21x18 number into uint128.
/// @dev Requirements:
/// - x ≥ 0
function intoUint128(SD21x18 x) pure returns (uint128 result) {
    int128 xInt = SD21x18.unwrap(x);
    if (xInt < 0) {
        revert CastingErrors.PRBMath_SD21x18_ToUint128_Underflow(x);
    }
    result = uint128(xInt);
}

/// @notice Casts an SD21x18 number into uint256.
/// @dev Requirements:
/// - x ≥ 0
function intoUint256(SD21x18 x) pure returns (uint256 result) {
    int128 xInt = SD21x18.unwrap(x);
    if (xInt < 0) {
        revert CastingErrors.PRBMath_SD21x18_ToUint256_Underflow(x);
    }
    result = uint256(uint128(xInt));
}

/// @notice Casts an SD21x18 number into uint40.
/// @dev Requirements:
/// - x ≥ 0
/// - x ≤ MAX_UINT40
function intoUint40(SD21x18 x) pure returns (uint40 result) {
    int128 xInt = SD21x18.unwrap(x);
    if (xInt < 0) {
        revert CastingErrors.PRBMath_SD21x18_ToUint40_Underflow(x);
    }
    if (xInt > int128(uint128(Common.MAX_UINT40))) {
        revert CastingErrors.PRBMath_SD21x18_ToUint40_Overflow(x);
    }
    result = uint40(uint128(xInt));
}

/// @notice Alias for {wrap}.
function sd21x18(int128 x) pure returns (SD21x18 result) {
    result = SD21x18.wrap(x);
}

/// @notice Unwraps an SD21x18 number into int128.
function unwrap(SD21x18 x) pure returns (int128 result) {
    result = SD21x18.unwrap(x);
}

/// @notice Wraps an int128 number into SD21x18.
function wrap(int128 x) pure returns (SD21x18 result) {
    result = SD21x18.wrap(x);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { SD21x18 } from "./ValueType.sol";

/// @dev Euler's number as an SD21x18 number.
SD21x18 constant E = SD21x18.wrap(2_718281828459045235);

/// @dev The maximum value an SD21x18 number can have.
int128 constant uMAX_SD21x18 = 170141183460469231731_687303715884105727;
SD21x18 constant MAX_SD21x18 = SD21x18.wrap(uMAX_SD21x18);

/// @dev The minimum value an SD21x18 number can have.
int128 constant uMIN_SD21x18 = -170141183460469231731_687303715884105728;
SD21x18 constant MIN_SD21x18 = SD21x18.wrap(uMIN_SD21x18);

/// @dev PI as an SD21x18 number.
SD21x18 constant PI = SD21x18.wrap(3_141592653589793238);

/// @dev The unit number, which gives the decimal precision of SD21x18.
SD21x18 constant UNIT = SD21x18.wrap(1e18);
int128 constant uUNIT = 1e18;
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { SD21x18 } from "./ValueType.sol";

/// @notice Thrown when trying to cast an SD21x18 number that doesn't fit in uint128.
error PRBMath_SD21x18_ToUint128_Underflow(SD21x18 x);

/// @notice Thrown when trying to cast an SD21x18 number that doesn't fit in UD60x18.
error PRBMath_SD21x18_ToUD60x18_Underflow(SD21x18 x);

/// @notice Thrown when trying to cast an SD21x18 number that doesn't fit in uint256.
error PRBMath_SD21x18_ToUint256_Underflow(SD21x18 x);

/// @notice Thrown when trying to cast an SD21x18 number that doesn't fit in uint40.
error PRBMath_SD21x18_ToUint40_Overflow(SD21x18 x);

/// @notice Thrown when trying to cast an SD21x18 number that doesn't fit in uint40.
error PRBMath_SD21x18_ToUint40_Underflow(SD21x18 x);
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "./Casting.sol" as Casting;

/// @notice The signed 21.18-decimal fixed-point number representation, which can have up to 21 digits and up to 18
/// decimals. The values of this are bound by the minimum and the maximum values permitted by the underlying Solidity
/// type int128. This is useful when end users want to use int128 to save gas, e.g. with tight variable packing in contract
/// storage.
type SD21x18 is int128;

/*//////////////////////////////////////////////////////////////////////////
                                    CASTING
//////////////////////////////////////////////////////////////////////////*/

using {
    Casting.intoSD59x18,
    Casting.intoUD60x18,
    Casting.intoUint128,
    Casting.intoUint256,
    Casting.intoUint40,
    Casting.unwrap
} for SD21x18 global;
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "./Errors.sol" as CastingErrors;
import { MAX_UINT128, MAX_UINT40 } from "../Common.sol";
import { uMAX_SD1x18, uMIN_SD1x18 } from "../sd1x18/Constants.sol";
import { SD1x18 } from "../sd1x18/ValueType.sol";
import { uMAX_SD21x18, uMIN_SD21x18 } from "../sd21x18/Constants.sol";
import { SD21x18 } from "../sd21x18/ValueType.sol";
import { uMAX_UD2x18 } from "../ud2x18/Constants.sol";
import { UD2x18 } from "../ud2x18/ValueType.sol";
import { uMAX_UD21x18 } from "../ud21x18/Constants.sol";
import { UD21x18 } from "../ud21x18/ValueType.sol";
import { UD60x18 } from "../ud60x18/ValueType.sol";
import { SD59x18 } from "./ValueType.sol";

/// @notice Casts an SD59x18 number into int256.
/// @dev This is basically a functional alias for {unwrap}.
function intoInt256(SD59x18 x) pure returns (int256 result) {
    result = SD59x18.unwrap(x);
}

/// @notice Casts an SD59x18 number into SD1x18.
/// @dev Requirements:
/// - x ≥ uMIN_SD1x18
/// - x ≤ uMAX_SD1x18
function intoSD1x18(SD59x18 x) pure returns (SD1x18 result) {
    int256 xInt = SD59x18.unwrap(x);
    if (xInt < uMIN_SD1x18) {
        revert CastingErrors.PRBMath_SD59x18_IntoSD1x18_Underflow(x);
    }
    if (xInt > uMAX_SD1x18) {
        revert CastingErrors.PRBMath_SD59x18_IntoSD1x18_Overflow(x);
    }
    result = SD1x18.wrap(int64(xInt));
}

/// @notice Casts an SD59x18 number into SD21x18.
/// @dev Requirements:
/// - x ≥ uMIN_SD21x18
/// - x ≤ uMAX_SD21x18
function intoSD21x18(SD59x18 x) pure returns (SD21x18 result) {
    int256 xInt = SD59x18.unwrap(x);
    if (xInt < uMIN_SD21x18) {
        revert CastingErrors.PRBMath_SD59x18_IntoSD21x18_Underflow(x);
    }
    if (xInt > uMAX_SD21x18) {
        revert CastingErrors.PRBMath_SD59x18_IntoSD21x18_Overflow(x);
    }
    result = SD21x18.wrap(int128(xInt));
}

/// @notice Casts an SD59x18 number into UD2x18.
/// @dev Requirements:
/// - x ≥ 0
/// - x ≤ uMAX_UD2x18
function intoUD2x18(SD59x18 x) pure returns (UD2x18 result) {
    int256 xInt = SD59x18.unwrap(x);
    if (xInt < 0) {
        revert CastingErrors.PRBMath_SD59x18_IntoUD2x18_Underflow(x);
    }
    if (xInt > int256(uint256(uMAX_UD2x18))) {
        revert CastingErrors.PRBMath_SD59x18_IntoUD2x18_Overflow(x);
    }
    result = UD2x18.wrap(uint64(uint256(xInt)));
}

/// @notice Casts an SD59x18 number into UD21x18.
/// @dev Requirements:
/// - x ≥ 0
/// - x ≤ uMAX_UD21x18
function intoUD21x18(SD59x18 x) pure returns (UD21x18 result) {
    int256 xInt = SD59x18.unwrap(x);
    if (xInt < 0) {
        revert CastingErrors.PRBMath_SD59x18_IntoUD21x18_Underflow(x);
    }
    if (xInt > int256(uint256(uMAX_UD21x18))) {
        revert CastingErrors.PRBMath_SD59x18_IntoUD21x18_Overflow(x);
    }
    result = UD21x18.wrap(uint128(uint256(xInt)));
}

/// @notice Casts an SD59x18 number into UD60x18.
/// @dev Requirements:
/// - x ≥ 0
function intoUD60x18(SD59x18 x) pure returns (UD60x18 result) {
    int256 xInt = SD59x18.unwrap(x);
    if (xInt < 0) {
        revert CastingErrors.PRBMath_SD59x18_IntoUD60x18_Underflow(x);
    }
    result = UD60x18.wrap(uint256(xInt));
}

/// @notice Casts an SD59x18 number into uint256.
/// @dev Requirements:
/// - x ≥ 0
function intoUint256(SD59x18 x) pure returns (uint256 result) {
    int256 xInt = SD59x18.unwrap(x);
    if (xInt < 0) {
        revert CastingErrors.PRBMath_SD59x18_IntoUint256_Underflow(x);
    }
    result = uint256(xInt);
}

/// @notice Casts an SD59x18 number into uint128.
/// @dev Requirements:
/// - x ≥ 0
/// - x ≤ uMAX_UINT128
function intoUint128(SD59x18 x) pure returns (uint128 result) {
    int256 xInt = SD59x18.unwrap(x);
    if (xInt < 0) {
        revert CastingErrors.PRBMath_SD59x18_IntoUint128_Underflow(x);
    }
    if (xInt > int256(uint256(MAX_UINT128))) {
        revert CastingErrors.PRBMath_SD59x18_IntoUint128_Overflow(x);
    }
    result = uint128(uint256(xInt));
}

/// @notice Casts an SD59x18 number into uint40.
/// @dev Requirements:
/// - x ≥ 0
/// - x ≤ MAX_UINT40
function intoUint40(SD59x18 x) pure returns (uint40 result) {
    int256 xInt = SD59x18.unwrap(x);
    if (xInt < 0) {
        revert CastingErrors.PRBMath_SD59x18_IntoUint40_Underflow(x);
    }
    if (xInt > int256(uint256(MAX_UINT40))) {
        revert CastingErrors.PRBMath_SD59x18_IntoUint40_Overflow(x);
    }
    result = uint40(uint256(xInt));
}

/// @notice Alias for {wrap}.
function sd(int256 x) pure returns (SD59x18 result) {
    result = SD59x18.wrap(x);
}

/// @notice Alias for {wrap}.
function sd59x18(int256 x) pure returns (SD59x18 result) {
    result = SD59x18.wrap(x);
}

/// @notice Unwraps an SD59x18 number into int256.
function unwrap(SD59x18 x) pure returns (int256 result) {
    result = SD59x18.unwrap(x);
}

/// @notice Wraps an int256 number into SD59x18.
function wrap(int256 x) pure returns (SD59x18 result) {
    result = SD59x18.wrap(x);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { SD59x18 } from "./ValueType.sol";

// NOTICE: the "u" prefix stands for "unwrapped".

/// @dev Euler's number as an SD59x18 number.
SD59x18 constant E = SD59x18.wrap(2_718281828459045235);

/// @dev The maximum input permitted in {exp}.
int256 constant uEXP_MAX_INPUT = 133_084258667509499440;
SD59x18 constant EXP_MAX_INPUT = SD59x18.wrap(uEXP_MAX_INPUT);

/// @dev Any value less than this returns 0 in {exp}.
int256 constant uEXP_MIN_THRESHOLD = -41_446531673892822322;
SD59x18 constant EXP_MIN_THRESHOLD = SD59x18.wrap(uEXP_MIN_THRESHOLD);

/// @dev The maximum input permitted in {exp2}.
int256 constant uEXP2_MAX_INPUT = 192e18 - 1;
SD59x18 constant EXP2_MAX_INPUT = SD59x18.wrap(uEXP2_MAX_INPUT);

/// @dev Any value less than this returns 0 in {exp2}.
int256 constant uEXP2_MIN_THRESHOLD = -59_794705707972522261;
SD59x18 constant EXP2_MIN_THRESHOLD = SD59x18.wrap(uEXP2_MIN_THRESHOLD);

/// @dev Half the UNIT number.
int256 constant uHALF_UNIT = 0.5e18;
SD59x18 constant HALF_UNIT = SD59x18.wrap(uHALF_UNIT);

/// @dev $log_2(10)$ as an SD59x18 number.
int256 constant uLOG2_10 = 3_321928094887362347;
SD59x18 constant LOG2_10 = SD59x18.wrap(uLOG2_10);

/// @dev $log_2(e)$ as an SD59x18 number.
int256 constant uLOG2_E = 1_442695040888963407;
SD59x18 constant LOG2_E = SD59x18.wrap(uLOG2_E);

/// @dev The maximum value an SD59x18 number can have.
int256 constant uMAX_SD59x18 = 57896044618658097711785492504343953926634992332820282019728_792003956564819967;
SD59x18 constant MAX_SD59x18 = SD59x18.wrap(uMAX_SD59x18);

/// @dev The maximum whole value an SD59x18 number can have.
int256 constant uMAX_WHOLE_SD59x18 = 57896044618658097711785492504343953926634992332820282019728_000000000000000000;
SD59x18 constant MAX_WHOLE_SD59x18 = SD59x18.wrap(uMAX_WHOLE_SD59x18);

/// @dev The minimum value an SD59x18 number can have.
int256 constant uMIN_SD59x18 = -57896044618658097711785492504343953926634992332820282019728_792003956564819968;
SD59x18 constant MIN_SD59x18 = SD59x18.wrap(uMIN_SD59x18);

/// @dev The minimum whole value an SD59x18 number can have.
int256 constant uMIN_WHOLE_SD59x18 = -57896044618658097711785492504343953926634992332820282019728_000000000000000000;
SD59x18 constant MIN_WHOLE_SD59x18 = SD59x18.wrap(uMIN_WHOLE_SD59x18);

/// @dev PI as an SD59x18 number.
SD59x18 constant PI = SD59x18.wrap(3_141592653589793238);

/// @dev The unit number, which gives the decimal precision of SD59x18.
int256 constant uUNIT = 1e18;
SD59x18 constant UNIT = SD59x18.wrap(1e18);

/// @dev The unit number squared.
int256 constant uUNIT_SQUARED = 1e36;
SD59x18 constant UNIT_SQUARED = SD59x18.wrap(uUNIT_SQUARED);

/// @dev Zero as an SD59x18 number.
SD59x18 constant ZERO = SD59x18.wrap(0);
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { SD59x18 } from "./ValueType.sol";

/// @notice Thrown when taking the absolute value of `MIN_SD59x18`.
error PRBMath_SD59x18_Abs_MinSD59x18();

/// @notice Thrown when ceiling a number overflows SD59x18.
error PRBMath_SD59x18_Ceil_Overflow(SD59x18 x);

/// @notice Thrown when converting a basic integer to the fixed-point format overflows SD59x18.
error PRBMath_SD59x18_Convert_Overflow(int256 x);

/// @notice Thrown when converting a basic integer to the fixed-point format underflows SD59x18.
error PRBMath_SD59x18_Convert_Underflow(int256 x);

/// @notice Thrown when dividing two numbers and one of them is `MIN_SD59x18`.
error PRBMath_SD59x18_Div_InputTooSmall();

/// @notice Thrown when dividing two numbers and one of the intermediary unsigned results overflows SD59x18.
error PRBMath_SD59x18_Div_Overflow(SD59x18 x, SD59x18 y);

/// @notice Thrown when taking the natural exponent of a base greater than 133_084258667509499441.
error PRBMath_SD59x18_Exp_InputTooBig(SD59x18 x);

/// @notice Thrown when taking the binary exponent of a base greater than 192e18.
error PRBMath_SD59x18_Exp2_InputTooBig(SD59x18 x);

/// @notice Thrown when flooring a number underflows SD59x18.
error PRBMath_SD59x18_Floor_Underflow(SD59x18 x);

/// @notice Thrown when taking the geometric mean of two numbers and their product is negative.
error PRBMath_SD59x18_Gm_NegativeProduct(SD59x18 x, SD59x18 y);

/// @notice Thrown when taking the geometric mean of two numbers and multiplying them overflows SD59x18.
error PRBMath_SD59x18_Gm_Overflow(SD59x18 x, SD59x18 y);

/// @notice Thrown when trying to cast an SD59x18 number that doesn't fit in SD1x18.
error PRBMath_SD59x18_IntoSD1x18_Overflow(SD59x18 x);

/// @notice Thrown when trying to cast an SD59x18 number that doesn't fit in SD1x18.
error PRBMath_SD59x18_IntoSD1x18_Underflow(SD59x18 x);

/// @notice Thrown when trying to cast an SD59x18 number that doesn't fit in SD21x18.
error PRBMath_SD59x18_IntoSD21x18_Overflow(SD59x18 x);

/// @notice Thrown when trying to cast an SD59x18 number that doesn't fit in SD21x18.
error PRBMath_SD59x18_IntoSD21x18_Underflow(SD59x18 x);

/// @notice Thrown when trying to cast an SD59x18 number that doesn't fit in UD2x18.
error PRBMath_SD59x18_IntoUD2x18_Overflow(SD59x18 x);

/// @notice Thrown when trying to cast an SD59x18 number that doesn't fit in UD2x18.
error PRBMath_SD59x18_IntoUD2x18_Underflow(SD59x18 x);

/// @notice Thrown when trying to cast an SD59x18 number that doesn't fit in UD21x18.
error PRBMath_SD59x18_IntoUD21x18_Overflow(SD59x18 x);

/// @notice Thrown when trying to cast an SD59x18 number that doesn't fit in UD21x18.
error PRBMath_SD59x18_IntoUD21x18_Underflow(SD59x18 x);

/// @notice Thrown when trying to cast an SD59x18 number that doesn't fit in UD60x18.
error PRBMath_SD59x18_IntoUD60x18_Underflow(SD59x18 x);

/// @notice Thrown when trying to cast an SD59x18 number that doesn't fit in uint128.
error PRBMath_SD59x18_IntoUint128_Overflow(SD59x18 x);

/// @notice Thrown when trying to cast an SD59x18 number that doesn't fit in uint128.
error PRBMath_SD59x18_IntoUint128_Underflow(SD59x18 x);

/// @notice Thrown when trying to cast an SD59x18 number that doesn't fit in uint256.
error PRBMath_SD59x18_IntoUint256_Underflow(SD59x18 x);

/// @notice Thrown when trying to cast an SD59x18 number that doesn't fit in uint40.
error PRBMath_SD59x18_IntoUint40_Overflow(SD59x18 x);

/// @notice Thrown when trying to cast an SD59x18 number that doesn't fit in uint40.
error PRBMath_SD59x18_IntoUint40_Underflow(SD59x18 x);

/// @notice Thrown when taking the logarithm of a number less than or equal to zero.
error PRBMath_SD59x18_Log_InputTooSmall(SD59x18 x);

/// @notice Thrown when multiplying two numbers and one of the inputs is `MIN_SD59x18`.
error PRBMath_SD59x18_Mul_InputTooSmall();

/// @notice Thrown when multiplying two numbers and the intermediary absolute result overflows SD59x18.
error PRBMath_SD59x18_Mul_Overflow(SD59x18 x, SD59x18 y);

/// @notice Thrown when raising a number to a power and the intermediary absolute result overflows SD59x18.
error PRBMath_SD59x18_Powu_Overflow(SD59x18 x, uint256 y);

/// @notice Thrown when taking the square root of a negative number.
error PRBMath_SD59x18_Sqrt_NegativeInput(SD59x18 x);

/// @notice Thrown when the calculating the square root overflows SD59x18.
error PRBMath_SD59x18_Sqrt_Overflow(SD59x18 x);
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { wrap } from "./Casting.sol";
import { SD59x18 } from "./ValueType.sol";

/// @notice Implements the checked addition operation (+) in the SD59x18 type.
function add(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    return wrap(x.unwrap() + y.unwrap());
}

/// @notice Implements the AND (&) bitwise operation in the SD59x18 type.
function and(SD59x18 x, int256 bits) pure returns (SD59x18 result) {
    return wrap(x.unwrap() & bits);
}

/// @notice Implements the AND (&) bitwise operation in the SD59x18 type.
function and2(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    return wrap(x.unwrap() & y.unwrap());
}

/// @notice Implements the equal (=) operation in the SD59x18 type.
function eq(SD59x18 x, SD59x18 y) pure returns (bool result) {
    result = x.unwrap() == y.unwrap();
}

/// @notice Implements the greater than operation (>) in the SD59x18 type.
function gt(SD59x18 x, SD59x18 y) pure returns (bool result) {
    result = x.unwrap() > y.unwrap();
}

/// @notice Implements the greater than or equal to operation (>=) in the SD59x18 type.
function gte(SD59x18 x, SD59x18 y) pure returns (bool result) {
    result = x.unwrap() >= y.unwrap();
}

/// @notice Implements a zero comparison check function in the SD59x18 type.
function isZero(SD59x18 x) pure returns (bool result) {
    result = x.unwrap() == 0;
}

/// @notice Implements the left shift operation (<<) in the SD59x18 type.
function lshift(SD59x18 x, uint256 bits) pure returns (SD59x18 result) {
    result = wrap(x.unwrap() << bits);
}

/// @notice Implements the lower than operation (<) in the SD59x18 type.
function lt(SD59x18 x, SD59x18 y) pure returns (bool result) {
    result = x.unwrap() < y.unwrap();
}

/// @notice Implements the lower than or equal to operation (<=) in the SD59x18 type.
function lte(SD59x18 x, SD59x18 y) pure returns (bool result) {
    result = x.unwrap() <= y.unwrap();
}

/// @notice Implements the unchecked modulo operation (%) in the SD59x18 type.
function mod(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    result = wrap(x.unwrap() % y.unwrap());
}

/// @notice Implements the not equal operation (!=) in the SD59x18 type.
function neq(SD59x18 x, SD59x18 y) pure returns (bool result) {
    result = x.unwrap() != y.unwrap();
}

/// @notice Implements the NOT (~) bitwise operation in the SD59x18 type.
function not(SD59x18 x) pure returns (SD59x18 result) {
    result = wrap(~x.unwrap());
}

/// @notice Implements the OR (|) bitwise operation in the SD59x18 type.
function or(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    result = wrap(x.unwrap() | y.unwrap());
}

/// @notice Implements the right shift operation (>>) in the SD59x18 type.
function rshift(SD59x18 x, uint256 bits) pure returns (SD59x18 result) {
    result = wrap(x.unwrap() >> bits);
}

/// @notice Implements the checked subtraction operation (-) in the SD59x18 type.
function sub(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    result = wrap(x.unwrap() - y.unwrap());
}

/// @notice Implements the checked unary minus operation (-) in the SD59x18 type.
function unary(SD59x18 x) pure returns (SD59x18 result) {
    result = wrap(-x.unwrap());
}

/// @notice Implements the unchecked addition operation (+) in the SD59x18 type.
function uncheckedAdd(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    unchecked {
        result = wrap(x.unwrap() + y.unwrap());
    }
}

/// @notice Implements the unchecked subtraction operation (-) in the SD59x18 type.
function uncheckedSub(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    unchecked {
        result = wrap(x.unwrap() - y.unwrap());
    }
}

/// @notice Implements the unchecked unary minus operation (-) in the SD59x18 type.
function uncheckedUnary(SD59x18 x) pure returns (SD59x18 result) {
    unchecked {
        result = wrap(-x.unwrap());
    }
}

/// @notice Implements the XOR (^) bitwise operation in the SD59x18 type.
function xor(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    result = wrap(x.unwrap() ^ y.unwrap());
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "../Common.sol" as Common;
import "./Errors.sol" as Errors;
import {
    uEXP_MAX_INPUT,
    uEXP2_MAX_INPUT,
    uEXP_MIN_THRESHOLD,
    uEXP2_MIN_THRESHOLD,
    uHALF_UNIT,
    uLOG2_10,
    uLOG2_E,
    uMAX_SD59x18,
    uMAX_WHOLE_SD59x18,
    uMIN_SD59x18,
    uMIN_WHOLE_SD59x18,
    UNIT,
    uUNIT,
    uUNIT_SQUARED,
    ZERO
} from "./Constants.sol";
import { wrap } from "./Helpers.sol";
import { SD59x18 } from "./ValueType.sol";

/// @notice Calculates the absolute value of x.
///
/// @dev Requirements:
/// - x > MIN_SD59x18.
///
/// @param x The SD59x18 number for which to calculate the absolute value.
/// @return result The absolute value of x as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function abs(SD59x18 x) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap();
    if (xInt == uMIN_SD59x18) {
        revert Errors.PRBMath_SD59x18_Abs_MinSD59x18();
    }
    result = xInt < 0 ? wrap(-xInt) : x;
}

/// @notice Calculates the arithmetic average of x and y.
///
/// @dev Notes:
/// - The result is rounded toward zero.
///
/// @param x The first operand as an SD59x18 number.
/// @param y The second operand as an SD59x18 number.
/// @return result The arithmetic average as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function avg(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap();
    int256 yInt = y.unwrap();

    unchecked {
        // This operation is equivalent to `x / 2 +  y / 2`, and it can never overflow.
        int256 sum = (xInt >> 1) + (yInt >> 1);

        if (sum < 0) {
            // If at least one of x and y is odd, add 1 to the result, because shifting negative numbers to the right
            // rounds toward negative infinity. The right part is equivalent to `sum + (x % 2 == 1 || y % 2 == 1)`.
            assembly ("memory-safe") {
                result := add(sum, and(or(xInt, yInt), 1))
            }
        } else {
            // Add 1 if both x and y are odd to account for the double 0.5 remainder truncated after shifting.
            result = wrap(sum + (xInt & yInt & 1));
        }
    }
}

/// @notice Yields the smallest whole number greater than or equal to x.
///
/// @dev Optimized for fractional value inputs, because every whole value has (1e18 - 1) fractional counterparts.
/// See https://en.wikipedia.org/wiki/Floor_and_ceiling_functions.
///
/// Requirements:
/// - x ≤ MAX_WHOLE_SD59x18
///
/// @param x The SD59x18 number to ceil.
/// @return result The smallest whole number greater than or equal to x, as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function ceil(SD59x18 x) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap();
    if (xInt > uMAX_WHOLE_SD59x18) {
        revert Errors.PRBMath_SD59x18_Ceil_Overflow(x);
    }

    int256 remainder = xInt % uUNIT;
    if (remainder == 0) {
        result = x;
    } else {
        unchecked {
            // Solidity uses C fmod style, which returns a modulus with the same sign as x.
            int256 resultInt = xInt - remainder;
            if (xInt > 0) {
                resultInt += uUNIT;
            }
            result = wrap(resultInt);
        }
    }
}

/// @notice Divides two SD59x18 numbers, returning a new SD59x18 number.
///
/// @dev This is an extension of {Common.mulDiv} for signed numbers, which works by computing the signs and the absolute
/// values separately.
///
/// Notes:
/// - Refer to the notes in {Common.mulDiv}.
/// - The result is rounded toward zero.
///
/// Requirements:
/// - Refer to the requirements in {Common.mulDiv}.
/// - None of the inputs can be `MIN_SD59x18`.
/// - The denominator must not be zero.
/// - The result must fit in SD59x18.
///
/// @param x The numerator as an SD59x18 number.
/// @param y The denominator as an SD59x18 number.
/// @return result The quotient as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function div(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap();
    int256 yInt = y.unwrap();
    if (xInt == uMIN_SD59x18 || yInt == uMIN_SD59x18) {
        revert Errors.PRBMath_SD59x18_Div_InputTooSmall();
    }

    // Get hold of the absolute values of x and y.
    uint256 xAbs;
    uint256 yAbs;
    unchecked {
        xAbs = xInt < 0 ? uint256(-xInt) : uint256(xInt);
        yAbs = yInt < 0 ? uint256(-yInt) : uint256(yInt);
    }

    // Compute the absolute value (x*UNIT÷y). The resulting value must fit in SD59x18.
    uint256 resultAbs = Common.mulDiv(xAbs, uint256(uUNIT), yAbs);
    if (resultAbs > uint256(uMAX_SD59x18)) {
        revert Errors.PRBMath_SD59x18_Div_Overflow(x, y);
    }

    // Check if x and y have the same sign using two's complement representation. The left-most bit represents the sign (1 for
    // negative, 0 for positive or zero).
    bool sameSign = (xInt ^ yInt) > -1;

    // If the inputs have the same sign, the result should be positive. Otherwise, it should be negative.
    unchecked {
        result = wrap(sameSign ? int256(resultAbs) : -int256(resultAbs));
    }
}

/// @notice Calculates the natural exponent of x using the following formula:
///
/// $$
/// e^x = 2^{x * log_2{e}}
/// $$
///
/// @dev Notes:
/// - Refer to the notes in {exp2}.
///
/// Requirements:
/// - Refer to the requirements in {exp2}.
/// - x < 133_084258667509499441.
///
/// @param x The exponent as an SD59x18 number.
/// @return result The result as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function exp(SD59x18 x) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap();

    // Any input less than the threshold returns zero.
    // This check also prevents an overflow for very small numbers.
    if (xInt < uEXP_MIN_THRESHOLD) {
        return ZERO;
    }

    // This check prevents values greater than 192e18 from being passed to {exp2}.
    if (xInt > uEXP_MAX_INPUT) {
        revert Errors.PRBMath_SD59x18_Exp_InputTooBig(x);
    }

    unchecked {
        // Inline the fixed-point multiplication to save gas.
        int256 doubleUnitProduct = xInt * uLOG2_E;
        result = exp2(wrap(doubleUnitProduct / uUNIT));
    }
}

/// @notice Calculates the binary exponent of x using the binary fraction method using the following formula:
///
/// $$
/// 2^{-x} = \frac{1}{2^x}
/// $$
///
/// @dev See https://ethereum.stackexchange.com/q/79903/24693.
///
/// Notes:
/// - If x < -59_794705707972522261, the result is zero.
///
/// Requirements:
/// - x < 192e18.
/// - The result must fit in SD59x18.
///
/// @param x The exponent as an SD59x18 number.
/// @return result The result as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function exp2(SD59x18 x) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap();
    if (xInt < 0) {
        // The inverse of any number less than the threshold is truncated to zero.
        if (xInt < uEXP2_MIN_THRESHOLD) {
            return ZERO;
        }

        unchecked {
            // Inline the fixed-point inversion to save gas.
            result = wrap(uUNIT_SQUARED / exp2(wrap(-xInt)).unwrap());
        }
    } else {
        // Numbers greater than or equal to 192e18 don't fit in the 192.64-bit format.
        if (xInt > uEXP2_MAX_INPUT) {
            revert Errors.PRBMath_SD59x18_Exp2_InputTooBig(x);
        }

        unchecked {
            // Convert x to the 192.64-bit fixed-point format.
            uint256 x_192x64 = uint256((xInt << 64) / uUNIT);

            // It is safe to cast the result to int256 due to the checks above.
            result = wrap(int256(Common.exp2(x_192x64)));
        }
    }
}

/// @notice Yields the greatest whole number less than or equal to x.
///
/// @dev Optimized for fractional value inputs, because for every whole value there are (1e18 - 1) fractional
/// counterparts. See https://en.wikipedia.org/wiki/Floor_and_ceiling_functions.
///
/// Requirements:
/// - x ≥ MIN_WHOLE_SD59x18
///
/// @param x The SD59x18 number to floor.
/// @return result The greatest whole number less than or equal to x, as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function floor(SD59x18 x) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap();
    if (xInt < uMIN_WHOLE_SD59x18) {
        revert Errors.PRBMath_SD59x18_Floor_Underflow(x);
    }

    int256 remainder = xInt % uUNIT;
    if (remainder == 0) {
        result = x;
    } else {
        unchecked {
            // Solidity uses C fmod style, which returns a modulus with the same sign as x.
            int256 resultInt = xInt - remainder;
            if (xInt < 0) {
                resultInt -= uUNIT;
            }
            result = wrap(resultInt);
        }
    }
}

/// @notice Yields the excess beyond the floor of x for positive numbers and the part of the number to the right.
/// of the radix point for negative numbers.
/// @dev Based on the odd function definition. https://en.wikipedia.org/wiki/Fractional_part
/// @param x The SD59x18 number to get the fractional part of.
/// @return result The fractional part of x as an SD59x18 number.
function frac(SD59x18 x) pure returns (SD59x18 result) {
    result = wrap(x.unwrap() % uUNIT);
}

/// @notice Calculates the geometric mean of x and y, i.e. $\sqrt{x * y}$.
///
/// @dev Notes:
/// - The result is rounded toward zero.
///
/// Requirements:
/// - x * y must fit in SD59x18.
/// - x * y must not be negative, since complex numbers are not supported.
///
/// @param x The first operand as an SD59x18 number.
/// @param y The second operand as an SD59x18 number.
/// @return result The result as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function gm(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap();
    int256 yInt = y.unwrap();
    if (xInt == 0 || yInt == 0) {
        return ZERO;
    }

    unchecked {
        // Equivalent to `xy / x != y`. Checking for overflow this way is faster than letting Solidity do it.
        int256 xyInt = xInt * yInt;
        if (xyInt / xInt != yInt) {
            revert Errors.PRBMath_SD59x18_Gm_Overflow(x, y);
        }

        // The product must not be negative, since complex numbers are not supported.
        if (xyInt < 0) {
            revert Errors.PRBMath_SD59x18_Gm_NegativeProduct(x, y);
        }

        // We don't need to multiply the result by `UNIT` here because the x*y product picked up a factor of `UNIT`
        // during multiplication. See the comments in {Common.sqrt}.
        uint256 resultUint = Common.sqrt(uint256(xyInt));
        result = wrap(int256(resultUint));
    }
}

/// @notice Calculates the inverse of x.
///
/// @dev Notes:
/// - The result is rounded toward zero.
///
/// Requirements:
/// - x must not be zero.
///
/// @param x The SD59x18 number for which to calculate the inverse.
/// @return result The inverse as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function inv(SD59x18 x) pure returns (SD59x18 result) {
    result = wrap(uUNIT_SQUARED / x.unwrap());
}

/// @notice Calculates the natural logarithm of x using the following formula:
///
/// $$
/// ln{x} = log_2{x} / log_2{e}
/// $$
///
/// @dev Notes:
/// - Refer to the notes in {log2}.
/// - The precision isn't sufficiently fine-grained to return exactly `UNIT` when the input is `E`.
///
/// Requirements:
/// - Refer to the requirements in {log2}.
///
/// @param x The SD59x18 number for which to calculate the natural logarithm.
/// @return result The natural logarithm as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function ln(SD59x18 x) pure returns (SD59x18 result) {
    // Inline the fixed-point multiplication to save gas. This is overflow-safe because the maximum value that
    // {log2} can return is ~195_205294292027477728.
    result = wrap(log2(x).unwrap() * uUNIT / uLOG2_E);
}

/// @notice Calculates the common logarithm of x using the following formula:
///
/// $$
/// log_{10}{x} = log_2{x} / log_2{10}
/// $$
///
/// However, if x is an exact power of ten, a hard coded value is returned.
///
/// @dev Notes:
/// - Refer to the notes in {log2}.
///
/// Requirements:
/// - Refer to the requirements in {log2}.
///
/// @param x The SD59x18 number for which to calculate the common logarithm.
/// @return result The common logarithm as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function log10(SD59x18 x) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap();
    if (xInt < 0) {
        revert Errors.PRBMath_SD59x18_Log_InputTooSmall(x);
    }

    // Note that the `mul` in this block is the standard multiplication operation, not {SD59x18.mul}.
    // prettier-ignore
    assembly ("memory-safe") {
        switch x
        case 1 { result := mul(uUNIT, sub(0, 18)) }
        case 10 { result := mul(uUNIT, sub(1, 18)) }
        case 100 { result := mul(uUNIT, sub(2, 18)) }
        case 1000 { result := mul(uUNIT, sub(3, 18)) }
        case 10000 { result := mul(uUNIT, sub(4, 18)) }
        case 100000 { result := mul(uUNIT, sub(5, 18)) }
        case 1000000 { result := mul(uUNIT, sub(6, 18)) }
        case 10000000 { result := mul(uUNIT, sub(7, 18)) }
        case 100000000 { result := mul(uUNIT, sub(8, 18)) }
        case 1000000000 { result := mul(uUNIT, sub(9, 18)) }
        case 10000000000 { result := mul(uUNIT, sub(10, 18)) }
        case 100000000000 { result := mul(uUNIT, sub(11, 18)) }
        case 1000000000000 { result := mul(uUNIT, sub(12, 18)) }
        case 10000000000000 { result := mul(uUNIT, sub(13, 18)) }
        case 100000000000000 { result := mul(uUNIT, sub(14, 18)) }
        case 1000000000000000 { result := mul(uUNIT, sub(15, 18)) }
        case 10000000000000000 { result := mul(uUNIT, sub(16, 18)) }
        case 100000000000000000 { result := mul(uUNIT, sub(17, 18)) }
        case 1000000000000000000 { result := 0 }
        case 10000000000000000000 { result := uUNIT }
        case 100000000000000000000 { result := mul(uUNIT, 2) }
        case 1000000000000000000000 { result := mul(uUNIT, 3) }
        case 10000000000000000000000 { result := mul(uUNIT, 4) }
        case 100000000000000000000000 { result := mul(uUNIT, 5) }
        case 1000000000000000000000000 { result := mul(uUNIT, 6) }
        case 10000000000000000000000000 { result := mul(uUNIT, 7) }
        case 100000000000000000000000000 { result := mul(uUNIT, 8) }
        case 1000000000000000000000000000 { result := mul(uUNIT, 9) }
        case 10000000000000000000000000000 { result := mul(uUNIT, 10) }
        case 100000000000000000000000000000 { result := mul(uUNIT, 11) }
        case 1000000000000000000000000000000 { result := mul(uUNIT, 12) }
        case 10000000000000000000000000000000 { result := mul(uUNIT, 13) }
        case 100000000000000000000000000000000 { result := mul(uUNIT, 14) }
        case 1000000000000000000000000000000000 { result := mul(uUNIT, 15) }
        case 10000000000000000000000000000000000 { result := mul(uUNIT, 16) }
        case 100000000000000000000000000000000000 { result := mul(uUNIT, 17) }
        case 1000000000000000000000000000000000000 { result := mul(uUNIT, 18) }
        case 10000000000000000000000000000000000000 { result := mul(uUNIT, 19) }
        case 100000000000000000000000000000000000000 { result := mul(uUNIT, 20) }
        case 1000000000000000000000000000000000000000 { result := mul(uUNIT, 21) }
        case 10000000000000000000000000000000000000000 { result := mul(uUNIT, 22) }
        case 100000000000000000000000000000000000000000 { result := mul(uUNIT, 23) }
        case 1000000000000000000000000000000000000000000 { result := mul(uUNIT, 24) }
        case 10000000000000000000000000000000000000000000 { result := mul(uUNIT, 25) }
        case 100000000000000000000000000000000000000000000 { result := mul(uUNIT, 26) }
        case 1000000000000000000000000000000000000000000000 { result := mul(uUNIT, 27) }
        case 10000000000000000000000000000000000000000000000 { result := mul(uUNIT, 28) }
        case 100000000000000000000000000000000000000000000000 { result := mul(uUNIT, 29) }
        case 1000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 30) }
        case 10000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 31) }
        case 100000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 32) }
        case 1000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 33) }
        case 10000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 34) }
        case 100000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 35) }
        case 1000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 36) }
        case 10000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 37) }
        case 100000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 38) }
        case 1000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 39) }
        case 10000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 40) }
        case 100000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 41) }
        case 1000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 42) }
        case 10000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 43) }
        case 100000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 44) }
        case 1000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 45) }
        case 10000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 46) }
        case 100000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 47) }
        case 1000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 48) }
        case 10000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 49) }
        case 100000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 50) }
        case 1000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 51) }
        case 10000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 52) }
        case 100000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 53) }
        case 1000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 54) }
        case 10000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 55) }
        case 100000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 56) }
        case 1000000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 57) }
        case 10000000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 58) }
        default { result := uMAX_SD59x18 }
    }

    if (result.unwrap() == uMAX_SD59x18) {
        unchecked {
            // Inline the fixed-point division to save gas.
            result = wrap(log2(x).unwrap() * uUNIT / uLOG2_10);
        }
    }
}

/// @notice Calculates the binary logarithm of x using the iterative approximation algorithm:
///
/// $$
/// log_2{x} = n + log_2{y}, \text{ where } y = x*2^{-n}, \ y \in [1, 2)
/// $$
///
/// For $0 \leq x \lt 1$, the input is inverted:
///
/// $$
/// log_2{x} = -log_2{\frac{1}{x}}
/// $$
///
/// @dev See https://en.wikipedia.org/wiki/Binary_logarithm#Iterative_approximation.
///
/// Notes:
/// - Due to the lossy precision of the iterative approximation, the results are not perfectly accurate to the last decimal.
///
/// Requirements:
/// - x > 0
///
/// @param x The SD59x18 number for which to calculate the binary logarithm.
/// @return result The binary logarithm as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function log2(SD59x18 x) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap();
    if (xInt <= 0) {
        revert Errors.PRBMath_SD59x18_Log_InputTooSmall(x);
    }

    unchecked {
        int256 sign;
        if (xInt >= uUNIT) {
            sign = 1;
        } else {
            sign = -1;
            // Inline the fixed-point inversion to save gas.
            xInt = uUNIT_SQUARED / xInt;
        }

        // Calculate the integer part of the logarithm.
        uint256 n = Common.msb(uint256(xInt / uUNIT));

        // This is the integer part of the logarithm as an SD59x18 number. The operation can't overflow
        // because n is at most 255, `UNIT` is 1e18, and the sign is either 1 or -1.
        int256 resultInt = int256(n) * uUNIT;

        // Calculate $y = x * 2^{-n}$.
        int256 y = xInt >> n;

        // If y is the unit number, the fractional part is zero.
        if (y == uUNIT) {
            return wrap(resultInt * sign);
        }

        // Calculate the fractional part via the iterative approximation.
        // The `delta >>= 1` part is equivalent to `delta /= 2`, but shifting bits is more gas efficient.
        int256 DOUBLE_UNIT = 2e18;
        for (int256 delta = uHALF_UNIT; delta > 0; delta >>= 1) {
            y = (y * y) / uUNIT;

            // Is y^2 >= 2e18 and so in the range [2e18, 4e18)?
            if (y >= DOUBLE_UNIT) {
                // Add the 2^{-m} factor to the logarithm.
                resultInt = resultInt + delta;

                // Halve y, which corresponds to z/2 in the Wikipedia article.
                y >>= 1;
            }
        }
        resultInt *= sign;
        result = wrap(resultInt);
    }
}

/// @notice Multiplies two SD59x18 numbers together, returning a new SD59x18 number.
///
/// @dev Notes:
/// - Refer to the notes in {Common.mulDiv18}.
///
/// Requirements:
/// - Refer to the requirements in {Common.mulDiv18}.
/// - None of the inputs can be `MIN_SD59x18`.
/// - The result must fit in SD59x18.
///
/// @param x The multiplicand as an SD59x18 number.
/// @param y The multiplier as an SD59x18 number.
/// @return result The product as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function mul(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap();
    int256 yInt = y.unwrap();
    if (xInt == uMIN_SD59x18 || yInt == uMIN_SD59x18) {
        revert Errors.PRBMath_SD59x18_Mul_InputTooSmall();
    }

    // Get hold of the absolute values of x and y.
    uint256 xAbs;
    uint256 yAbs;
    unchecked {
        xAbs = xInt < 0 ? uint256(-xInt) : uint256(xInt);
        yAbs = yInt < 0 ? uint256(-yInt) : uint256(yInt);
    }

    // Compute the absolute value (x*y÷UNIT). The resulting value must fit in SD59x18.
    uint256 resultAbs = Common.mulDiv18(xAbs, yAbs);
    if (resultAbs > uint256(uMAX_SD59x18)) {
        revert Errors.PRBMath_SD59x18_Mul_Overflow(x, y);
    }

    // Check if x and y have the same sign using two's complement representation. The left-most bit represents the sign (1 for
    // negative, 0 for positive or zero).
    bool sameSign = (xInt ^ yInt) > -1;

    // If the inputs have the same sign, the result should be positive. Otherwise, it should be negative.
    unchecked {
        result = wrap(sameSign ? int256(resultAbs) : -int256(resultAbs));
    }
}

/// @notice Raises x to the power of y using the following formula:
///
/// $$
/// x^y = 2^{log_2{x} * y}
/// $$
///
/// @dev Notes:
/// - Refer to the notes in {exp2}, {log2}, and {mul}.
/// - Returns `UNIT` for 0^0.
///
/// Requirements:
/// - Refer to the requirements in {exp2}, {log2}, and {mul}.
///
/// @param x The base as an SD59x18 number.
/// @param y Exponent to raise x to, as an SD59x18 number
/// @return result x raised to power y, as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function pow(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap();
    int256 yInt = y.unwrap();

    // If both x and y are zero, the result is `UNIT`. If just x is zero, the result is always zero.
    if (xInt == 0) {
        return yInt == 0 ? UNIT : ZERO;
    }
    // If x is `UNIT`, the result is always `UNIT`.
    else if (xInt == uUNIT) {
        return UNIT;
    }

    // If y is zero, the result is always `UNIT`.
    if (yInt == 0) {
        return UNIT;
    }
    // If y is `UNIT`, the result is always x.
    else if (yInt == uUNIT) {
        return x;
    }

    // Calculate the result using the formula.
    result = exp2(mul(log2(x), y));
}

/// @notice Raises x (an SD59x18 number) to the power y (an unsigned basic integer) using the well-known
/// algorithm "exponentiation by squaring".
///
/// @dev See https://en.wikipedia.org/wiki/Exponentiation_by_squaring.
///
/// Notes:
/// - Refer to the notes in {Common.mulDiv18}.
/// - Returns `UNIT` for 0^0.
///
/// Requirements:
/// - Refer to the requirements in {abs} and {Common.mulDiv18}.
/// - The result must fit in SD59x18.
///
/// @param x The base as an SD59x18 number.
/// @param y The exponent as a uint256.
/// @return result The result as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function powu(SD59x18 x, uint256 y) pure returns (SD59x18 result) {
    uint256 xAbs = uint256(abs(x).unwrap());

    // Calculate the first iteration of the loop in advance.
    uint256 resultAbs = y & 1 > 0 ? xAbs : uint256(uUNIT);

    // Equivalent to `for(y /= 2; y > 0; y /= 2)`.
    uint256 yAux = y;
    for (yAux >>= 1; yAux > 0; yAux >>= 1) {
        xAbs = Common.mulDiv18(xAbs, xAbs);

        // Equivalent to `y % 2 == 1`.
        if (yAux & 1 > 0) {
            resultAbs = Common.mulDiv18(resultAbs, xAbs);
        }
    }

    // The result must fit in SD59x18.
    if (resultAbs > uint256(uMAX_SD59x18)) {
        revert Errors.PRBMath_SD59x18_Powu_Overflow(x, y);
    }

    unchecked {
        // Is the base negative and the exponent odd? If yes, the result should be negative.
        int256 resultInt = int256(resultAbs);
        bool isNegative = x.unwrap() < 0 && y & 1 == 1;
        if (isNegative) {
            resultInt = -resultInt;
        }
        result = wrap(resultInt);
    }
}

/// @notice Calculates the square root of x using the Babylonian method.
///
/// @dev See https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method.
///
/// Notes:
/// - Only the positive root is returned.
/// - The result is rounded toward zero.
///
/// Requirements:
/// - x ≥ 0, since complex numbers are not supported.
/// - x ≤ MAX_SD59x18 / UNIT
///
/// @param x The SD59x18 number for which to calculate the square root.
/// @return result The result as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function sqrt(SD59x18 x) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap();
    if (xInt < 0) {
        revert Errors.PRBMath_SD59x18_Sqrt_NegativeInput(x);
    }
    if (xInt > uMAX_SD59x18 / uUNIT) {
        revert Errors.PRBMath_SD59x18_Sqrt_Overflow(x);
    }

    unchecked {
        // Multiply x by `UNIT` to account for the factor of `UNIT` picked up when multiplying two SD59x18 numbers.
        // In this case, the two numbers are both the square root.
        uint256 resultUint = Common.sqrt(uint256(xInt * uUNIT));
        result = wrap(int256(resultUint));
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "./Casting.sol" as Casting;
import "./Helpers.sol" as Helpers;
import "./Math.sol" as Math;

/// @notice The signed 59.18-decimal fixed-point number representation, which can have up to 59 digits and up to 18
/// decimals. The values of this are bound by the minimum and the maximum values permitted by the underlying Solidity
/// type int256.
type SD59x18 is int256;

/*//////////////////////////////////////////////////////////////////////////
                                    CASTING
//////////////////////////////////////////////////////////////////////////*/

using {
    Casting.intoInt256,
    Casting.intoSD1x18,
    Casting.intoSD21x18,
    Casting.intoUD2x18,
    Casting.intoUD21x18,
    Casting.intoUD60x18,
    Casting.intoUint256,
    Casting.intoUint128,
    Casting.intoUint40,
    Casting.unwrap
} for SD59x18 global;

/*//////////////////////////////////////////////////////////////////////////
                            MATHEMATICAL FUNCTIONS
//////////////////////////////////////////////////////////////////////////*/

using {
    Math.abs,
    Math.avg,
    Math.ceil,
    Math.div,
    Math.exp,
    Math.exp2,
    Math.floor,
    Math.frac,
    Math.gm,
    Math.inv,
    Math.log10,
    Math.log2,
    Math.ln,
    Math.mul,
    Math.pow,
    Math.powu,
    Math.sqrt
} for SD59x18 global;

/*//////////////////////////////////////////////////////////////////////////
                                HELPER FUNCTIONS
//////////////////////////////////////////////////////////////////////////*/

using {
    Helpers.add,
    Helpers.and,
    Helpers.eq,
    Helpers.gt,
    Helpers.gte,
    Helpers.isZero,
    Helpers.lshift,
    Helpers.lt,
    Helpers.lte,
    Helpers.mod,
    Helpers.neq,
    Helpers.not,
    Helpers.or,
    Helpers.rshift,
    Helpers.sub,
    Helpers.uncheckedAdd,
    Helpers.uncheckedSub,
    Helpers.uncheckedUnary,
    Helpers.xor
} for SD59x18 global;

/*//////////////////////////////////////////////////////////////////////////
                                    OPERATORS
//////////////////////////////////////////////////////////////////////////*/

// The global "using for" directive makes it possible to use these operators on the SD59x18 type.
using {
    Helpers.add as +,
    Helpers.and2 as &,
    Math.div as /,
    Helpers.eq as ==,
    Helpers.gt as >,
    Helpers.gte as >=,
    Helpers.lt as <,
    Helpers.lte as <=,
    Helpers.mod as %,
    Math.mul as *,
    Helpers.neq as !=,
    Helpers.not as ~,
    Helpers.or as |,
    Helpers.sub as -,
    Helpers.unary as -,
    Helpers.xor as ^
} for SD59x18 global;
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "../Common.sol" as Common;
import "./Errors.sol" as Errors;
import { SD59x18 } from "../sd59x18/ValueType.sol";
import { UD60x18 } from "../ud60x18/ValueType.sol";
import { UD21x18 } from "./ValueType.sol";

/// @notice Casts a UD21x18 number into SD59x18.
/// @dev There is no overflow check because UD21x18 ⊆ SD59x18.
function intoSD59x18(UD21x18 x) pure returns (SD59x18 result) {
    result = SD59x18.wrap(int256(uint256(UD21x18.unwrap(x))));
}

/// @notice Casts a UD21x18 number into UD60x18.
/// @dev There is no overflow check because UD21x18 ⊆ UD60x18.
function intoUD60x18(UD21x18 x) pure returns (UD60x18 result) {
    result = UD60x18.wrap(UD21x18.unwrap(x));
}

/// @notice Casts a UD21x18 number into uint128.
/// @dev This is basically an alias for {unwrap}.
function intoUint128(UD21x18 x) pure returns (uint128 result) {
    result = UD21x18.unwrap(x);
}

/// @notice Casts a UD21x18 number into uint256.
/// @dev There is no overflow check because UD21x18 ⊆ uint256.
function intoUint256(UD21x18 x) pure returns (uint256 result) {
    result = uint256(UD21x18.unwrap(x));
}

/// @notice Casts a UD21x18 number into uint40.
/// @dev Requirements:
/// - x ≤ MAX_UINT40
function intoUint40(UD21x18 x) pure returns (uint40 result) {
    uint128 xUint = UD21x18.unwrap(x);
    if (xUint > uint128(Common.MAX_UINT40)) {
        revert Errors.PRBMath_UD21x18_IntoUint40_Overflow(x);
    }
    result = uint40(xUint);
}

/// @notice Alias for {wrap}.
function ud21x18(uint128 x) pure returns (UD21x18 result) {
    result = UD21x18.wrap(x);
}

/// @notice Unwrap a UD21x18 number into uint128.
function unwrap(UD21x18 x) pure returns (uint128 result) {
    result = UD21x18.unwrap(x);
}

/// @notice Wraps a uint128 number into UD21x18.
function wrap(uint128 x) pure returns (UD21x18 result) {
    result = UD21x18.wrap(x);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { UD21x18 } from "./ValueType.sol";

/// @dev Euler's number as a UD21x18 number.
UD21x18 constant E = UD21x18.wrap(2_718281828459045235);

/// @dev The maximum value a UD21x18 number can have.
uint128 constant uMAX_UD21x18 = 340282366920938463463_374607431768211455;
UD21x18 constant MAX_UD21x18 = UD21x18.wrap(uMAX_UD21x18);

/// @dev PI as a UD21x18 number.
UD21x18 constant PI = UD21x18.wrap(3_141592653589793238);

/// @dev The unit number, which gives the decimal precision of UD21x18.
uint256 constant uUNIT = 1e18;
UD21x18 constant UNIT = UD21x18.wrap(1e18);
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { UD21x18 } from "./ValueType.sol";

/// @notice Thrown when trying to cast a UD21x18 number that doesn't fit in uint40.
error PRBMath_UD21x18_IntoUint40_Overflow(UD21x18 x);
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "./Casting.sol" as Casting;

/// @notice The unsigned 21.18-decimal fixed-point number representation, which can have up to 21 digits and up to 18
/// decimals. The values of this are bound by the minimum and the maximum values permitted by the underlying Solidity
/// type uint128. This is useful when end users want to use uint128 to save gas, e.g. with tight variable packing in contract
/// storage.
type UD21x18 is uint128;

/*//////////////////////////////////////////////////////////////////////////
                                    CASTING
//////////////////////////////////////////////////////////////////////////*/

using {
    Casting.intoSD59x18,
    Casting.intoUD60x18,
    Casting.intoUint128,
    Casting.intoUint256,
    Casting.intoUint40,
    Casting.unwrap
} for UD21x18 global;
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "../Common.sol" as Common;
import "./Errors.sol" as Errors;
import { SD59x18 } from "../sd59x18/ValueType.sol";
import { UD60x18 } from "../ud60x18/ValueType.sol";
import { UD2x18 } from "./ValueType.sol";

/// @notice Casts a UD2x18 number into SD59x18.
/// @dev There is no overflow check because UD2x18 ⊆ SD59x18.
function intoSD59x18(UD2x18 x) pure returns (SD59x18 result) {
    result = SD59x18.wrap(int256(uint256(UD2x18.unwrap(x))));
}

/// @notice Casts a UD2x18 number into UD60x18.
/// @dev There is no overflow check because UD2x18 ⊆ UD60x18.
function intoUD60x18(UD2x18 x) pure returns (UD60x18 result) {
    result = UD60x18.wrap(UD2x18.unwrap(x));
}

/// @notice Casts a UD2x18 number into uint128.
/// @dev There is no overflow check because UD2x18 ⊆ uint128.
function intoUint128(UD2x18 x) pure returns (uint128 result) {
    result = uint128(UD2x18.unwrap(x));
}

/// @notice Casts a UD2x18 number into uint256.
/// @dev There is no overflow check because UD2x18 ⊆ uint256.
function intoUint256(UD2x18 x) pure returns (uint256 result) {
    result = uint256(UD2x18.unwrap(x));
}

/// @notice Casts a UD2x18 number into uint40.
/// @dev Requirements:
/// - x ≤ MAX_UINT40
function intoUint40(UD2x18 x) pure returns (uint40 result) {
    uint64 xUint = UD2x18.unwrap(x);
    if (xUint > uint64(Common.MAX_UINT40)) {
        revert Errors.PRBMath_UD2x18_IntoUint40_Overflow(x);
    }
    result = uint40(xUint);
}

/// @notice Alias for {wrap}.
function ud2x18(uint64 x) pure returns (UD2x18 result) {
    result = UD2x18.wrap(x);
}

/// @notice Unwrap a UD2x18 number into uint64.
function unwrap(UD2x18 x) pure returns (uint64 result) {
    result = UD2x18.unwrap(x);
}

/// @notice Wraps a uint64 number into UD2x18.
function wrap(uint64 x) pure returns (UD2x18 result) {
    result = UD2x18.wrap(x);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { UD2x18 } from "./ValueType.sol";

/// @dev Euler's number as a UD2x18 number.
UD2x18 constant E = UD2x18.wrap(2_718281828459045235);

/// @dev The maximum value a UD2x18 number can have.
uint64 constant uMAX_UD2x18 = 18_446744073709551615;
UD2x18 constant MAX_UD2x18 = UD2x18.wrap(uMAX_UD2x18);

/// @dev PI as a UD2x18 number.
UD2x18 constant PI = UD2x18.wrap(3_141592653589793238);

/// @dev The unit number, which gives the decimal precision of UD2x18.
UD2x18 constant UNIT = UD2x18.wrap(1e18);
uint64 constant uUNIT = 1e18;
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { UD2x18 } from "./ValueType.sol";

/// @notice Thrown when trying to cast a UD2x18 number that doesn't fit in uint40.
error PRBMath_UD2x18_IntoUint40_Overflow(UD2x18 x);
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "./Casting.sol" as Casting;

/// @notice The unsigned 2.18-decimal fixed-point number representation, which can have up to 2 digits and up to 18
/// decimals. The values of this are bound by the minimum and the maximum values permitted by the underlying Solidity
/// type uint64. This is useful when end users want to use uint64 to save gas, e.g. with tight variable packing in contract
/// storage.
type UD2x18 is uint64;

/*//////////////////////////////////////////////////////////////////////////
                                    CASTING
//////////////////////////////////////////////////////////////////////////*/

using {
    Casting.intoSD59x18,
    Casting.intoUD60x18,
    Casting.intoUint128,
    Casting.intoUint256,
    Casting.intoUint40,
    Casting.unwrap
} for UD2x18 global;
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "./Errors.sol" as CastingErrors;
import { MAX_UINT128, MAX_UINT40 } from "../Common.sol";
import { uMAX_SD1x18 } from "../sd1x18/Constants.sol";
import { SD1x18 } from "../sd1x18/ValueType.sol";
import { uMAX_SD21x18 } from "../sd21x18/Constants.sol";
import { SD21x18 } from "../sd21x18/ValueType.sol";
import { uMAX_SD59x18 } from "../sd59x18/Constants.sol";
import { SD59x18 } from "../sd59x18/ValueType.sol";
import { uMAX_UD2x18 } from "../ud2x18/Constants.sol";
import { uMAX_UD21x18 } from "../ud21x18/Constants.sol";
import { UD2x18 } from "../ud2x18/ValueType.sol";
import { UD21x18 } from "../ud21x18/ValueType.sol";
import { UD60x18 } from "./ValueType.sol";

/// @notice Casts a UD60x18 number into SD1x18.
/// @dev Requirements:
/// - x ≤ uMAX_SD1x18
function intoSD1x18(UD60x18 x) pure returns (SD1x18 result) {
    uint256 xUint = UD60x18.unwrap(x);
    if (xUint > uint256(int256(uMAX_SD1x18))) {
        revert CastingErrors.PRBMath_UD60x18_IntoSD1x18_Overflow(x);
    }
    result = SD1x18.wrap(int64(uint64(xUint)));
}

/// @notice Casts a UD60x18 number into SD21x18.
/// @dev Requirements:
/// - x ≤ uMAX_SD21x18
function intoSD21x18(UD60x18 x) pure returns (SD21x18 result) {
    uint256 xUint = UD60x18.unwrap(x);
    if (xUint > uint256(int256(uMAX_SD21x18))) {
        revert CastingErrors.PRBMath_UD60x18_IntoSD21x18_Overflow(x);
    }
    result = SD21x18.wrap(int128(uint128(xUint)));
}

/// @notice Casts a UD60x18 number into UD2x18.
/// @dev Requirements:
/// - x ≤ uMAX_UD2x18
function intoUD2x18(UD60x18 x) pure returns (UD2x18 result) {
    uint256 xUint = UD60x18.unwrap(x);
    if (xUint > uMAX_UD2x18) {
        revert CastingErrors.PRBMath_UD60x18_IntoUD2x18_Overflow(x);
    }
    result = UD2x18.wrap(uint64(xUint));
}

/// @notice Casts a UD60x18 number into UD21x18.
/// @dev Requirements:
/// - x ≤ uMAX_UD21x18
function intoUD21x18(UD60x18 x) pure returns (UD21x18 result) {
    uint256 xUint = UD60x18.unwrap(x);
    if (xUint > uMAX_UD21x18) {
        revert CastingErrors.PRBMath_UD60x18_IntoUD21x18_Overflow(x);
    }
    result = UD21x18.wrap(uint128(xUint));
}

/// @notice Casts a UD60x18 number into SD59x18.
/// @dev Requirements:
/// - x ≤ uMAX_SD59x18
function intoSD59x18(UD60x18 x) pure returns (SD59x18 result) {
    uint256 xUint = UD60x18.unwrap(x);
    if (xUint > uint256(uMAX_SD59x18)) {
        revert CastingErrors.PRBMath_UD60x18_IntoSD59x18_Overflow(x);
    }
    result = SD59x18.wrap(int256(xUint));
}

/// @notice Casts a UD60x18 number into uint128.
/// @dev This is basically an alias for {unwrap}.
function intoUint256(UD60x18 x) pure returns (uint256 result) {
    result = UD60x18.unwrap(x);
}

/// @notice Casts a UD60x18 number into uint128.
/// @dev Requirements:
/// - x ≤ MAX_UINT128
function intoUint128(UD60x18 x) pure returns (uint128 result) {
    uint256 xUint = UD60x18.unwrap(x);
    if (xUint > MAX_UINT128) {
        revert CastingErrors.PRBMath_UD60x18_IntoUint128_Overflow(x);
    }
    result = uint128(xUint);
}

/// @notice Casts a UD60x18 number into uint40.
/// @dev Requirements:
/// - x ≤ MAX_UINT40
function intoUint40(UD60x18 x) pure returns (uint40 result) {
    uint256 xUint = UD60x18.unwrap(x);
    if (xUint > MAX_UINT40) {
        revert CastingErrors.PRBMath_UD60x18_IntoUint40_Overflow(x);
    }
    result = uint40(xUint);
}

/// @notice Alias for {wrap}.
function ud(uint256 x) pure returns (UD60x18 result) {
    result = UD60x18.wrap(x);
}

/// @notice Alias for {wrap}.
function ud60x18(uint256 x) pure returns (UD60x18 result) {
    result = UD60x18.wrap(x);
}

/// @notice Unwraps a UD60x18 number into uint256.
function unwrap(UD60x18 x) pure returns (uint256 result) {
    result = UD60x18.unwrap(x);
}

/// @notice Wraps a uint256 number into the UD60x18 value type.
function wrap(uint256 x) pure returns (UD60x18 result) {
    result = UD60x18.wrap(x);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { UD60x18 } from "./ValueType.sol";

// NOTICE: the "u" prefix stands for "unwrapped".

/// @dev Euler's number as a UD60x18 number.
UD60x18 constant E = UD60x18.wrap(2_718281828459045235);

/// @dev The maximum input permitted in {exp}.
uint256 constant uEXP_MAX_INPUT = 133_084258667509499440;
UD60x18 constant EXP_MAX_INPUT = UD60x18.wrap(uEXP_MAX_INPUT);

/// @dev The maximum input permitted in {exp2}.
uint256 constant uEXP2_MAX_INPUT = 192e18 - 1;
UD60x18 constant EXP2_MAX_INPUT = UD60x18.wrap(uEXP2_MAX_INPUT);

/// @dev Half the UNIT number.
uint256 constant uHALF_UNIT = 0.5e18;
UD60x18 constant HALF_UNIT = UD60x18.wrap(uHALF_UNIT);

/// @dev $log_2(10)$ as a UD60x18 number.
uint256 constant uLOG2_10 = 3_321928094887362347;
UD60x18 constant LOG2_10 = UD60x18.wrap(uLOG2_10);

/// @dev $log_2(e)$ as a UD60x18 number.
uint256 constant uLOG2_E = 1_442695040888963407;
UD60x18 constant LOG2_E = UD60x18.wrap(uLOG2_E);

/// @dev The maximum value a UD60x18 number can have.
uint256 constant uMAX_UD60x18 = 115792089237316195423570985008687907853269984665640564039457_584007913129639935;
UD60x18 constant MAX_UD60x18 = UD60x18.wrap(uMAX_UD60x18);

/// @dev The maximum whole value a UD60x18 number can have.
uint256 constant uMAX_WHOLE_UD60x18 = 115792089237316195423570985008687907853269984665640564039457_000000000000000000;
UD60x18 constant MAX_WHOLE_UD60x18 = UD60x18.wrap(uMAX_WHOLE_UD60x18);

/// @dev PI as a UD60x18 number.
UD60x18 constant PI = UD60x18.wrap(3_141592653589793238);

/// @dev The unit number, which gives the decimal precision of UD60x18.
uint256 constant uUNIT = 1e18;
UD60x18 constant UNIT = UD60x18.wrap(uUNIT);

/// @dev The unit number squared.
uint256 constant uUNIT_SQUARED = 1e36;
UD60x18 constant UNIT_SQUARED = UD60x18.wrap(uUNIT_SQUARED);

/// @dev Zero as a UD60x18 number.
UD60x18 constant ZERO = UD60x18.wrap(0);
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { uMAX_UD60x18, uUNIT } from "./Constants.sol";
import { PRBMath_UD60x18_Convert_Overflow } from "./Errors.sol";
import { UD60x18 } from "./ValueType.sol";

/// @notice Converts a UD60x18 number to a simple integer by dividing it by `UNIT`.
/// @dev The result is rounded toward zero.
/// @param x The UD60x18 number to convert.
/// @return result The same number in basic integer form.
function convert(UD60x18 x) pure returns (uint256 result) {
    result = UD60x18.unwrap(x) / uUNIT;
}

/// @notice Converts a simple integer to UD60x18 by multiplying it by `UNIT`.
///
/// @dev Requirements:
/// - x ≤ MAX_UD60x18 / UNIT
///
/// @param x The basic integer to convert.
/// @return result The same number converted to UD60x18.
function convert(uint256 x) pure returns (UD60x18 result) {
    if (x > uMAX_UD60x18 / uUNIT) {
        revert PRBMath_UD60x18_Convert_Overflow(x);
    }
    unchecked {
        result = UD60x18.wrap(x * uUNIT);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { UD60x18 } from "./ValueType.sol";

/// @notice Thrown when ceiling a number overflows UD60x18.
error PRBMath_UD60x18_Ceil_Overflow(UD60x18 x);

/// @notice Thrown when converting a basic integer to the fixed-point format overflows UD60x18.
error PRBMath_UD60x18_Convert_Overflow(uint256 x);

/// @notice Thrown when taking the natural exponent of a base greater than 133_084258667509499441.
error PRBMath_UD60x18_Exp_InputTooBig(UD60x18 x);

/// @notice Thrown when taking the binary exponent of a base greater than 192e18.
error PRBMath_UD60x18_Exp2_InputTooBig(UD60x18 x);

/// @notice Thrown when taking the geometric mean of two numbers and multiplying them overflows UD60x18.
error PRBMath_UD60x18_Gm_Overflow(UD60x18 x, UD60x18 y);

/// @notice Thrown when trying to cast a UD60x18 number that doesn't fit in SD1x18.
error PRBMath_UD60x18_IntoSD1x18_Overflow(UD60x18 x);

/// @notice Thrown when trying to cast a UD60x18 number that doesn't fit in SD21x18.
error PRBMath_UD60x18_IntoSD21x18_Overflow(UD60x18 x);

/// @notice Thrown when trying to cast a UD60x18 number that doesn't fit in SD59x18.
error PRBMath_UD60x18_IntoSD59x18_Overflow(UD60x18 x);

/// @notice Thrown when trying to cast a UD60x18 number that doesn't fit in UD2x18.
error PRBMath_UD60x18_IntoUD2x18_Overflow(UD60x18 x);

/// @notice Thrown when trying to cast a UD60x18 number that doesn't fit in UD21x18.
error PRBMath_UD60x18_IntoUD21x18_Overflow(UD60x18 x);

/// @notice Thrown when trying to cast a UD60x18 number that doesn't fit in uint128.
error PRBMath_UD60x18_IntoUint128_Overflow(UD60x18 x);

/// @notice Thrown when trying to cast a UD60x18 number that doesn't fit in uint40.
error PRBMath_UD60x18_IntoUint40_Overflow(UD60x18 x);

/// @notice Thrown when taking the logarithm of a number less than UNIT.
error PRBMath_UD60x18_Log_InputTooSmall(UD60x18 x);

/// @notice Thrown when calculating the square root overflows UD60x18.
error PRBMath_UD60x18_Sqrt_Overflow(UD60x18 x);
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { wrap } from "./Casting.sol";
import { UD60x18 } from "./ValueType.sol";

/// @notice Implements the checked addition operation (+) in the UD60x18 type.
function add(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    result = wrap(x.unwrap() + y.unwrap());
}

/// @notice Implements the AND (&) bitwise operation in the UD60x18 type.
function and(UD60x18 x, uint256 bits) pure returns (UD60x18 result) {
    result = wrap(x.unwrap() & bits);
}

/// @notice Implements the AND (&) bitwise operation in the UD60x18 type.
function and2(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    result = wrap(x.unwrap() & y.unwrap());
}

/// @notice Implements the equal operation (==) in the UD60x18 type.
function eq(UD60x18 x, UD60x18 y) pure returns (bool result) {
    result = x.unwrap() == y.unwrap();
}

/// @notice Implements the greater than operation (>) in the UD60x18 type.
function gt(UD60x18 x, UD60x18 y) pure returns (bool result) {
    result = x.unwrap() > y.unwrap();
}

/// @notice Implements the greater than or equal to operation (>=) in the UD60x18 type.
function gte(UD60x18 x, UD60x18 y) pure returns (bool result) {
    result = x.unwrap() >= y.unwrap();
}

/// @notice Implements a zero comparison check function in the UD60x18 type.
function isZero(UD60x18 x) pure returns (bool result) {
    // This wouldn't work if x could be negative.
    result = x.unwrap() == 0;
}

/// @notice Implements the left shift operation (<<) in the UD60x18 type.
function lshift(UD60x18 x, uint256 bits) pure returns (UD60x18 result) {
    result = wrap(x.unwrap() << bits);
}

/// @notice Implements the lower than operation (<) in the UD60x18 type.
function lt(UD60x18 x, UD60x18 y) pure returns (bool result) {
    result = x.unwrap() < y.unwrap();
}

/// @notice Implements the lower than or equal to operation (<=) in the UD60x18 type.
function lte(UD60x18 x, UD60x18 y) pure returns (bool result) {
    result = x.unwrap() <= y.unwrap();
}

/// @notice Implements the checked modulo operation (%) in the UD60x18 type.
function mod(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    result = wrap(x.unwrap() % y.unwrap());
}

/// @notice Implements the not equal operation (!=) in the UD60x18 type.
function neq(UD60x18 x, UD60x18 y) pure returns (bool result) {
    result = x.unwrap() != y.unwrap();
}

/// @notice Implements the NOT (~) bitwise operation in the UD60x18 type.
function not(UD60x18 x) pure returns (UD60x18 result) {
    result = wrap(~x.unwrap());
}

/// @notice Implements the OR (|) bitwise operation in the UD60x18 type.
function or(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    result = wrap(x.unwrap() | y.unwrap());
}

/// @notice Implements the right shift operation (>>) in the UD60x18 type.
function rshift(UD60x18 x, uint256 bits) pure returns (UD60x18 result) {
    result = wrap(x.unwrap() >> bits);
}

/// @notice Implements the checked subtraction operation (-) in the UD60x18 type.
function sub(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    result = wrap(x.unwrap() - y.unwrap());
}

/// @notice Implements the unchecked addition operation (+) in the UD60x18 type.
function uncheckedAdd(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    unchecked {
        result = wrap(x.unwrap() + y.unwrap());
    }
}

/// @notice Implements the unchecked subtraction operation (-) in the UD60x18 type.
function uncheckedSub(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    unchecked {
        result = wrap(x.unwrap() - y.unwrap());
    }
}

/// @notice Implements the XOR (^) bitwise operation in the UD60x18 type.
function xor(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    result = wrap(x.unwrap() ^ y.unwrap());
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "../Common.sol" as Common;
import "./Errors.sol" as Errors;
import { wrap } from "./Casting.sol";
import {
    uEXP_MAX_INPUT,
    uEXP2_MAX_INPUT,
    uHALF_UNIT,
    uLOG2_10,
    uLOG2_E,
    uMAX_UD60x18,
    uMAX_WHOLE_UD60x18,
    UNIT,
    uUNIT,
    uUNIT_SQUARED,
    ZERO
} from "./Constants.sol";
import { UD60x18 } from "./ValueType.sol";

/*//////////////////////////////////////////////////////////////////////////
                            MATHEMATICAL FUNCTIONS
//////////////////////////////////////////////////////////////////////////*/

/// @notice Calculates the arithmetic average of x and y using the following formula:
///
/// $$
/// avg(x, y) = (x & y) + ((xUint ^ yUint) / 2)
/// $$
///
/// In English, this is what this formula does:
///
/// 1. AND x and y.
/// 2. Calculate half of XOR x and y.
/// 3. Add the two results together.
///
/// This technique is known as SWAR, which stands for "SIMD within a register". You can read more about it here:
/// https://devblogs.microsoft.com/oldnewthing/20220207-00/?p=106223
///
/// @dev Notes:
/// - The result is rounded toward zero.
///
/// @param x The first operand as a UD60x18 number.
/// @param y The second operand as a UD60x18 number.
/// @return result The arithmetic average as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function avg(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    uint256 xUint = x.unwrap();
    uint256 yUint = y.unwrap();
    unchecked {
        result = wrap((xUint & yUint) + ((xUint ^ yUint) >> 1));
    }
}

/// @notice Yields the smallest whole number greater than or equal to x.
///
/// @dev This is optimized for fractional value inputs, because for every whole value there are (1e18 - 1) fractional
/// counterparts. See https://en.wikipedia.org/wiki/Floor_and_ceiling_functions.
///
/// Requirements:
/// - x ≤ MAX_WHOLE_UD60x18
///
/// @param x The UD60x18 number to ceil.
/// @return result The smallest whole number greater than or equal to x, as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function ceil(UD60x18 x) pure returns (UD60x18 result) {
    uint256 xUint = x.unwrap();
    if (xUint > uMAX_WHOLE_UD60x18) {
        revert Errors.PRBMath_UD60x18_Ceil_Overflow(x);
    }

    assembly ("memory-safe") {
        // Equivalent to `x % UNIT`.
        let remainder := mod(x, uUNIT)

        // Equivalent to `UNIT - remainder`.
        let delta := sub(uUNIT, remainder)

        // Equivalent to `x + remainder > 0 ? delta : 0`.
        result := add(x, mul(delta, gt(remainder, 0)))
    }
}

/// @notice Divides two UD60x18 numbers, returning a new UD60x18 number.
///
/// @dev Uses {Common.mulDiv} to enable overflow-safe multiplication and division.
///
/// Notes:
/// - Refer to the notes in {Common.mulDiv}.
///
/// Requirements:
/// - Refer to the requirements in {Common.mulDiv}.
///
/// @param x The numerator as a UD60x18 number.
/// @param y The denominator as a UD60x18 number.
/// @return result The quotient as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function div(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    result = wrap(Common.mulDiv(x.unwrap(), uUNIT, y.unwrap()));
}

/// @notice Calculates the natural exponent of x using the following formula:
///
/// $$
/// e^x = 2^{x * log_2{e}}
/// $$
///
/// @dev Requirements:
/// - x ≤ 133_084258667509499440
///
/// @param x The exponent as a UD60x18 number.
/// @return result The result as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function exp(UD60x18 x) pure returns (UD60x18 result) {
    uint256 xUint = x.unwrap();

    // This check prevents values greater than 192e18 from being passed to {exp2}.
    if (xUint > uEXP_MAX_INPUT) {
        revert Errors.PRBMath_UD60x18_Exp_InputTooBig(x);
    }

    unchecked {
        // Inline the fixed-point multiplication to save gas.
        uint256 doubleUnitProduct = xUint * uLOG2_E;
        result = exp2(wrap(doubleUnitProduct / uUNIT));
    }
}

/// @notice Calculates the binary exponent of x using the binary fraction method.
///
/// @dev See https://ethereum.stackexchange.com/q/79903/24693
///
/// Requirements:
/// - x < 192e18
/// - The result must fit in UD60x18.
///
/// @param x The exponent as a UD60x18 number.
/// @return result The result as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function exp2(UD60x18 x) pure returns (UD60x18 result) {
    uint256 xUint = x.unwrap();

    // Numbers greater than or equal to 192e18 don't fit in the 192.64-bit format.
    if (xUint > uEXP2_MAX_INPUT) {
        revert Errors.PRBMath_UD60x18_Exp2_InputTooBig(x);
    }

    // Convert x to the 192.64-bit fixed-point format.
    uint256 x_192x64 = (xUint << 64) / uUNIT;

    // Pass x to the {Common.exp2} function, which uses the 192.64-bit fixed-point number representation.
    result = wrap(Common.exp2(x_192x64));
}

/// @notice Yields the greatest whole number less than or equal to x.
/// @dev Optimized for fractional value inputs, because every whole value has (1e18 - 1) fractional counterparts.
/// See https://en.wikipedia.org/wiki/Floor_and_ceiling_functions.
/// @param x The UD60x18 number to floor.
/// @return result The greatest whole number less than or equal to x, as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function floor(UD60x18 x) pure returns (UD60x18 result) {
    assembly ("memory-safe") {
        // Equivalent to `x % UNIT`.
        let remainder := mod(x, uUNIT)

        // Equivalent to `x - remainder > 0 ? remainder : 0)`.
        result := sub(x, mul(remainder, gt(remainder, 0)))
    }
}

/// @notice Yields the excess beyond the floor of x using the odd function definition.
/// @dev See https://en.wikipedia.org/wiki/Fractional_part.
/// @param x The UD60x18 number to get the fractional part of.
/// @return result The fractional part of x as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function frac(UD60x18 x) pure returns (UD60x18 result) {
    assembly ("memory-safe") {
        result := mod(x, uUNIT)
    }
}

/// @notice Calculates the geometric mean of x and y, i.e. $\sqrt{x * y}$, rounding down.
///
/// @dev Requirements:
/// - x * y must fit in UD60x18.
///
/// @param x The first operand as a UD60x18 number.
/// @param y The second operand as a UD60x18 number.
/// @return result The result as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function gm(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    uint256 xUint = x.unwrap();
    uint256 yUint = y.unwrap();
    if (xUint == 0 || yUint == 0) {
        return ZERO;
    }

    unchecked {
        // Checking for overflow this way is faster than letting Solidity do it.
        uint256 xyUint = xUint * yUint;
        if (xyUint / xUint != yUint) {
            revert Errors.PRBMath_UD60x18_Gm_Overflow(x, y);
        }

        // We don't need to multiply the result by `UNIT` here because the x*y product picked up a factor of `UNIT`
        // during multiplication. See the comments in {Common.sqrt}.
        result = wrap(Common.sqrt(xyUint));
    }
}

/// @notice Calculates the inverse of x.
///
/// @dev Notes:
/// - The result is rounded toward zero.
///
/// Requirements:
/// - x must not be zero.
///
/// @param x The UD60x18 number for which to calculate the inverse.
/// @return result The inverse as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function inv(UD60x18 x) pure returns (UD60x18 result) {
    unchecked {
        result = wrap(uUNIT_SQUARED / x.unwrap());
    }
}

/// @notice Calculates the natural logarithm of x using the following formula:
///
/// $$
/// ln{x} = log_2{x} / log_2{e}
/// $$
///
/// @dev Notes:
/// - Refer to the notes in {log2}.
/// - The precision isn't sufficiently fine-grained to return exactly `UNIT` when the input is `E`.
///
/// Requirements:
/// - Refer to the requirements in {log2}.
///
/// @param x The UD60x18 number for which to calculate the natural logarithm.
/// @return result The natural logarithm as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function ln(UD60x18 x) pure returns (UD60x18 result) {
    unchecked {
        // Inline the fixed-point multiplication to save gas. This is overflow-safe because the maximum value that
        // {log2} can return is ~196_205294292027477728.
        result = wrap(log2(x).unwrap() * uUNIT / uLOG2_E);
    }
}

/// @notice Calculates the common logarithm of x using the following formula:
///
/// $$
/// log_{10}{x} = log_2{x} / log_2{10}
/// $$
///
/// However, if x is an exact power of ten, a hard coded value is returned.
///
/// @dev Notes:
/// - Refer to the notes in {log2}.
///
/// Requirements:
/// - Refer to the requirements in {log2}.
///
/// @param x The UD60x18 number for which to calculate the common logarithm.
/// @return result The common logarithm as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function log10(UD60x18 x) pure returns (UD60x18 result) {
    uint256 xUint = x.unwrap();
    if (xUint < uUNIT) {
        revert Errors.PRBMath_UD60x18_Log_InputTooSmall(x);
    }

    // Note that the `mul` in this assembly block is the standard multiplication operation, not {UD60x18.mul}.
    // prettier-ignore
    assembly ("memory-safe") {
        switch x
        case 1 { result := mul(uUNIT, sub(0, 18)) }
        case 10 { result := mul(uUNIT, sub(1, 18)) }
        case 100 { result := mul(uUNIT, sub(2, 18)) }
        case 1000 { result := mul(uUNIT, sub(3, 18)) }
        case 10000 { result := mul(uUNIT, sub(4, 18)) }
        case 100000 { result := mul(uUNIT, sub(5, 18)) }
        case 1000000 { result := mul(uUNIT, sub(6, 18)) }
        case 10000000 { result := mul(uUNIT, sub(7, 18)) }
        case 100000000 { result := mul(uUNIT, sub(8, 18)) }
        case 1000000000 { result := mul(uUNIT, sub(9, 18)) }
        case 10000000000 { result := mul(uUNIT, sub(10, 18)) }
        case 100000000000 { result := mul(uUNIT, sub(11, 18)) }
        case 1000000000000 { result := mul(uUNIT, sub(12, 18)) }
        case 10000000000000 { result := mul(uUNIT, sub(13, 18)) }
        case 100000000000000 { result := mul(uUNIT, sub(14, 18)) }
        case 1000000000000000 { result := mul(uUNIT, sub(15, 18)) }
        case 10000000000000000 { result := mul(uUNIT, sub(16, 18)) }
        case 100000000000000000 { result := mul(uUNIT, sub(17, 18)) }
        case 1000000000000000000 { result := 0 }
        case 10000000000000000000 { result := uUNIT }
        case 100000000000000000000 { result := mul(uUNIT, 2) }
        case 1000000000000000000000 { result := mul(uUNIT, 3) }
        case 10000000000000000000000 { result := mul(uUNIT, 4) }
        case 100000000000000000000000 { result := mul(uUNIT, 5) }
        case 1000000000000000000000000 { result := mul(uUNIT, 6) }
        case 10000000000000000000000000 { result := mul(uUNIT, 7) }
        case 100000000000000000000000000 { result := mul(uUNIT, 8) }
        case 1000000000000000000000000000 { result := mul(uUNIT, 9) }
        case 10000000000000000000000000000 { result := mul(uUNIT, 10) }
        case 100000000000000000000000000000 { result := mul(uUNIT, 11) }
        case 1000000000000000000000000000000 { result := mul(uUNIT, 12) }
        case 10000000000000000000000000000000 { result := mul(uUNIT, 13) }
        case 100000000000000000000000000000000 { result := mul(uUNIT, 14) }
        case 1000000000000000000000000000000000 { result := mul(uUNIT, 15) }
        case 10000000000000000000000000000000000 { result := mul(uUNIT, 16) }
        case 100000000000000000000000000000000000 { result := mul(uUNIT, 17) }
        case 1000000000000000000000000000000000000 { result := mul(uUNIT, 18) }
        case 10000000000000000000000000000000000000 { result := mul(uUNIT, 19) }
        case 100000000000000000000000000000000000000 { result := mul(uUNIT, 20) }
        case 1000000000000000000000000000000000000000 { result := mul(uUNIT, 21) }
        case 10000000000000000000000000000000000000000 { result := mul(uUNIT, 22) }
        case 100000000000000000000000000000000000000000 { result := mul(uUNIT, 23) }
        case 1000000000000000000000000000000000000000000 { result := mul(uUNIT, 24) }
        case 10000000000000000000000000000000000000000000 { result := mul(uUNIT, 25) }
        case 100000000000000000000000000000000000000000000 { result := mul(uUNIT, 26) }
        case 1000000000000000000000000000000000000000000000 { result := mul(uUNIT, 27) }
        case 10000000000000000000000000000000000000000000000 { result := mul(uUNIT, 28) }
        case 100000000000000000000000000000000000000000000000 { result := mul(uUNIT, 29) }
        case 1000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 30) }
        case 10000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 31) }
        case 100000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 32) }
        case 1000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 33) }
        case 10000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 34) }
        case 100000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 35) }
        case 1000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 36) }
        case 10000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 37) }
        case 100000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 38) }
        case 1000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 39) }
        case 10000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 40) }
        case 100000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 41) }
        case 1000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 42) }
        case 10000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 43) }
        case 100000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 44) }
        case 1000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 45) }
        case 10000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 46) }
        case 100000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 47) }
        case 1000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 48) }
        case 10000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 49) }
        case 100000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 50) }
        case 1000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 51) }
        case 10000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 52) }
        case 100000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 53) }
        case 1000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 54) }
        case 10000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 55) }
        case 100000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 56) }
        case 1000000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 57) }
        case 10000000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 58) }
        case 100000000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 59) }
        default { result := uMAX_UD60x18 }
    }

    if (result.unwrap() == uMAX_UD60x18) {
        unchecked {
            // Inline the fixed-point division to save gas.
            result = wrap(log2(x).unwrap() * uUNIT / uLOG2_10);
        }
    }
}

/// @notice Calculates the binary logarithm of x using the iterative approximation algorithm:
///
/// $$
/// log_2{x} = n + log_2{y}, \text{ where } y = x*2^{-n}, \ y \in [1, 2)
/// $$
///
/// For $0 \leq x \lt 1$, the input is inverted:
///
/// $$
/// log_2{x} = -log_2{\frac{1}{x}}
/// $$
///
/// @dev See https://en.wikipedia.org/wiki/Binary_logarithm#Iterative_approximation
///
/// Notes:
/// - Due to the lossy precision of the iterative approximation, the results are not perfectly accurate to the last decimal.
///
/// Requirements:
/// - x ≥ UNIT
///
/// @param x The UD60x18 number for which to calculate the binary logarithm.
/// @return result The binary logarithm as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function log2(UD60x18 x) pure returns (UD60x18 result) {
    uint256 xUint = x.unwrap();

    if (xUint < uUNIT) {
        revert Errors.PRBMath_UD60x18_Log_InputTooSmall(x);
    }

    unchecked {
        // Calculate the integer part of the logarithm.
        uint256 n = Common.msb(xUint / uUNIT);

        // This is the integer part of the logarithm as a UD60x18 number. The operation can't overflow because n
        // n is at most 255 and UNIT is 1e18.
        uint256 resultUint = n * uUNIT;

        // Calculate $y = x * 2^{-n}$.
        uint256 y = xUint >> n;

        // If y is the unit number, the fractional part is zero.
        if (y == uUNIT) {
            return wrap(resultUint);
        }

        // Calculate the fractional part via the iterative approximation.
        // The `delta >>= 1` part is equivalent to `delta /= 2`, but shifting bits is more gas efficient.
        uint256 DOUBLE_UNIT = 2e18;
        for (uint256 delta = uHALF_UNIT; delta > 0; delta >>= 1) {
            y = (y * y) / uUNIT;

            // Is y^2 >= 2e18 and so in the range [2e18, 4e18)?
            if (y >= DOUBLE_UNIT) {
                // Add the 2^{-m} factor to the logarithm.
                resultUint += delta;

                // Halve y, which corresponds to z/2 in the Wikipedia article.
                y >>= 1;
            }
        }
        result = wrap(resultUint);
    }
}

/// @notice Multiplies two UD60x18 numbers together, returning a new UD60x18 number.
///
/// @dev Uses {Common.mulDiv} to enable overflow-safe multiplication and division.
///
/// Notes:
/// - Refer to the notes in {Common.mulDiv}.
///
/// Requirements:
/// - Refer to the requirements in {Common.mulDiv}.
///
/// @dev See the documentation in {Common.mulDiv18}.
/// @param x The multiplicand as a UD60x18 number.
/// @param y The multiplier as a UD60x18 number.
/// @return result The product as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function mul(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    result = wrap(Common.mulDiv18(x.unwrap(), y.unwrap()));
}

/// @notice Raises x to the power of y.
///
/// For $1 \leq x \leq \infty$, the following standard formula is used:
///
/// $$
/// x^y = 2^{log_2{x} * y}
/// $$
///
/// For $0 \leq x \lt 1$, since the unsigned {log2} is undefined, an equivalent formula is used:
///
/// $$
/// i = \frac{1}{x}
/// w = 2^{log_2{i} * y}
/// x^y = \frac{1}{w}
/// $$
///
/// @dev Notes:
/// - Refer to the notes in {log2} and {mul}.
/// - Returns `UNIT` for 0^0.
/// - It may not perform well with very small values of x. Consider using SD59x18 as an alternative.
///
/// Requirements:
/// - Refer to the requirements in {exp2}, {log2}, and {mul}.
///
/// @param x The base as a UD60x18 number.
/// @param y The exponent as a UD60x18 number.
/// @return result The result as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function pow(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    uint256 xUint = x.unwrap();
    uint256 yUint = y.unwrap();

    // If both x and y are zero, the result is `UNIT`. If just x is zero, the result is always zero.
    if (xUint == 0) {
        return yUint == 0 ? UNIT : ZERO;
    }
    // If x is `UNIT`, the result is always `UNIT`.
    else if (xUint == uUNIT) {
        return UNIT;
    }

    // If y is zero, the result is always `UNIT`.
    if (yUint == 0) {
        return UNIT;
    }
    // If y is `UNIT`, the result is always x.
    else if (yUint == uUNIT) {
        return x;
    }

    // If x is > UNIT, use the standard formula.
    if (xUint > uUNIT) {
        result = exp2(mul(log2(x), y));
    }
    // Conversely, if x < UNIT, use the equivalent formula.
    else {
        UD60x18 i = wrap(uUNIT_SQUARED / xUint);
        UD60x18 w = exp2(mul(log2(i), y));
        result = wrap(uUNIT_SQUARED / w.unwrap());
    }
}

/// @notice Raises x (a UD60x18 number) to the power y (an unsigned basic integer) using the well-known
/// algorithm "exponentiation by squaring".
///
/// @dev See https://en.wikipedia.org/wiki/Exponentiation_by_squaring.
///
/// Notes:
/// - Refer to the notes in {Common.mulDiv18}.
/// - Returns `UNIT` for 0^0.
///
/// Requirements:
/// - The result must fit in UD60x18.
///
/// @param x The base as a UD60x18 number.
/// @param y The exponent as a uint256.
/// @return result The result as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function powu(UD60x18 x, uint256 y) pure returns (UD60x18 result) {
    // Calculate the first iteration of the loop in advance.
    uint256 xUint = x.unwrap();
    uint256 resultUint = y & 1 > 0 ? xUint : uUNIT;

    // Equivalent to `for(y /= 2; y > 0; y /= 2)`.
    for (y >>= 1; y > 0; y >>= 1) {
        xUint = Common.mulDiv18(xUint, xUint);

        // Equivalent to `y % 2 == 1`.
        if (y & 1 > 0) {
            resultUint = Common.mulDiv18(resultUint, xUint);
        }
    }
    result = wrap(resultUint);
}

/// @notice Calculates the square root of x using the Babylonian method.
///
/// @dev See https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method.
///
/// Notes:
/// - The result is rounded toward zero.
///
/// Requirements:
/// - x ≤ MAX_UD60x18 / UNIT
///
/// @param x The UD60x18 number for which to calculate the square root.
/// @return result The result as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function sqrt(UD60x18 x) pure returns (UD60x18 result) {
    uint256 xUint = x.unwrap();

    unchecked {
        if (xUint > uMAX_UD60x18 / uUNIT) {
            revert Errors.PRBMath_UD60x18_Sqrt_Overflow(x);
        }
        // Multiply x by `UNIT` to account for the factor of `UNIT` picked up when multiplying two UD60x18 numbers.
        // In this case, the two numbers are both the square root.
        result = wrap(Common.sqrt(xUint * uUNIT));
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "./Casting.sol" as Casting;
import "./Helpers.sol" as Helpers;
import "./Math.sol" as Math;

/// @notice The unsigned 60.18-decimal fixed-point number representation, which can have up to 60 digits and up to 18
/// decimals. The values of this are bound by the minimum and the maximum values permitted by the Solidity type uint256.
/// @dev The value type is defined here so it can be imported in all other files.
type UD60x18 is uint256;

/*//////////////////////////////////////////////////////////////////////////
                                    CASTING
//////////////////////////////////////////////////////////////////////////*/

using {
    Casting.intoSD1x18,
    Casting.intoSD21x18,
    Casting.intoSD59x18,
    Casting.intoUD2x18,
    Casting.intoUD21x18,
    Casting.intoUint128,
    Casting.intoUint256,
    Casting.intoUint40,
    Casting.unwrap
} for UD60x18 global;

/*//////////////////////////////////////////////////////////////////////////
                            MATHEMATICAL FUNCTIONS
//////////////////////////////////////////////////////////////////////////*/

// The global "using for" directive makes the functions in this library callable on the UD60x18 type.
using {
    Math.avg,
    Math.ceil,
    Math.div,
    Math.exp,
    Math.exp2,
    Math.floor,
    Math.frac,
    Math.gm,
    Math.inv,
    Math.ln,
    Math.log10,
    Math.log2,
    Math.mul,
    Math.pow,
    Math.powu,
    Math.sqrt
} for UD60x18 global;

/*//////////////////////////////////////////////////////////////////////////
                                HELPER FUNCTIONS
//////////////////////////////////////////////////////////////////////////*/

// The global "using for" directive makes the functions in this library callable on the UD60x18 type.
using {
    Helpers.add,
    Helpers.and,
    Helpers.eq,
    Helpers.gt,
    Helpers.gte,
    Helpers.isZero,
    Helpers.lshift,
    Helpers.lt,
    Helpers.lte,
    Helpers.mod,
    Helpers.neq,
    Helpers.not,
    Helpers.or,
    Helpers.rshift,
    Helpers.sub,
    Helpers.uncheckedAdd,
    Helpers.uncheckedSub,
    Helpers.xor
} for UD60x18 global;

/*//////////////////////////////////////////////////////////////////////////
                                    OPERATORS
//////////////////////////////////////////////////////////////////////////*/

// The global "using for" directive makes it possible to use these operators on the UD60x18 type.
using {
    Helpers.add as +,
    Helpers.and2 as &,
    Math.div as /,
    Helpers.eq as ==,
    Helpers.gt as >,
    Helpers.gte as >=,
    Helpers.lt as <,
    Helpers.lte as <=,
    Helpers.or as |,
    Helpers.mod as %,
    Math.mul as *,
    Helpers.neq as !=,
    Helpers.not as ~,
    Helpers.sub as -,
    Helpers.xor as ^
} for UD60x18 global;
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Minimalist and gas efficient standard ERC1155 implementation.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC1155.sol)
abstract contract ERC1155 {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event TransferSingle(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 amount
    );

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] amounts
    );

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    /*//////////////////////////////////////////////////////////////
                             ERC1155 STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(address => mapping(uint256 => uint256)) public balanceOf;

    mapping(address => mapping(address => bool)) public isApprovedForAll;

    /*//////////////////////////////////////////////////////////////
                             METADATA LOGIC
    //////////////////////////////////////////////////////////////*/

    function uri(uint256 id) public view virtual returns (string memory);

    /*//////////////////////////////////////////////////////////////
                              ERC1155 LOGIC
    //////////////////////////////////////////////////////////////*/

    function setApprovalForAll(address operator, bool approved) public virtual {
        isApprovedForAll[msg.sender][operator] = approved;

        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) public virtual {
        require(msg.sender == from || isApprovedForAll[from][msg.sender], "NOT_AUTHORIZED");

        balanceOf[from][id] -= amount;
        balanceOf[to][id] += amount;

        emit TransferSingle(msg.sender, from, to, id, amount);

        require(
            to.code.length == 0
                ? to != address(0)
                : ERC1155TokenReceiver(to).onERC1155Received(msg.sender, from, id, amount, data) ==
                    ERC1155TokenReceiver.onERC1155Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) public virtual {
        require(ids.length == amounts.length, "LENGTH_MISMATCH");

        require(msg.sender == from || isApprovedForAll[from][msg.sender], "NOT_AUTHORIZED");

        // Storing these outside the loop saves ~15 gas per iteration.
        uint256 id;
        uint256 amount;

        for (uint256 i = 0; i < ids.length; ) {
            id = ids[i];
            amount = amounts[i];

            balanceOf[from][id] -= amount;
            balanceOf[to][id] += amount;

            // An array can't have a total length
            // larger than the max uint256 value.
            unchecked {
                ++i;
            }
        }

        emit TransferBatch(msg.sender, from, to, ids, amounts);

        require(
            to.code.length == 0
                ? to != address(0)
                : ERC1155TokenReceiver(to).onERC1155BatchReceived(msg.sender, from, ids, amounts, data) ==
                    ERC1155TokenReceiver.onERC1155BatchReceived.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function balanceOfBatch(address[] calldata owners, uint256[] calldata ids)
        public
        view
        virtual
        returns (uint256[] memory balances)
    {
        require(owners.length == ids.length, "LENGTH_MISMATCH");

        balances = new uint256[](owners.length);

        // Unchecked because the only math done is incrementing
        // the array index counter which cannot possibly overflow.
        unchecked {
            for (uint256 i = 0; i < owners.length; ++i) {
                balances[i] = balanceOf[owners[i]][ids[i]];
            }
        }
    }

    /*//////////////////////////////////////////////////////////////
                              ERC165 LOGIC
    //////////////////////////////////////////////////////////////*/

    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return
            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
            interfaceId == 0xd9b67a26 || // ERC165 Interface ID for ERC1155
            interfaceId == 0x0e89341c; // ERC165 Interface ID for ERC1155MetadataURI
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        balanceOf[to][id] += amount;

        emit TransferSingle(msg.sender, address(0), to, id, amount);

        require(
            to.code.length == 0
                ? to != address(0)
                : ERC1155TokenReceiver(to).onERC1155Received(msg.sender, address(0), id, amount, data) ==
                    ERC1155TokenReceiver.onERC1155Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function _batchMint(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        uint256 idsLength = ids.length; // Saves MLOADs.

        require(idsLength == amounts.length, "LENGTH_MISMATCH");

        for (uint256 i = 0; i < idsLength; ) {
            balanceOf[to][ids[i]] += amounts[i];

            // An array can't have a total length
            // larger than the max uint256 value.
            unchecked {
                ++i;
            }
        }

        emit TransferBatch(msg.sender, address(0), to, ids, amounts);

        require(
            to.code.length == 0
                ? to != address(0)
                : ERC1155TokenReceiver(to).onERC1155BatchReceived(msg.sender, address(0), ids, amounts, data) ==
                    ERC1155TokenReceiver.onERC1155BatchReceived.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function _batchBurn(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {
        uint256 idsLength = ids.length; // Saves MLOADs.

        require(idsLength == amounts.length, "LENGTH_MISMATCH");

        for (uint256 i = 0; i < idsLength; ) {
            balanceOf[from][ids[i]] -= amounts[i];

            // An array can't have a total length
            // larger than the max uint256 value.
            unchecked {
                ++i;
            }
        }

        emit TransferBatch(msg.sender, from, address(0), ids, amounts);
    }

    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal virtual {
        balanceOf[from][id] -= amount;

        emit TransferSingle(msg.sender, from, address(0), id, amount);
    }
}

/// @notice A generic interface for a contract which properly accepts ERC1155 tokens.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC1155.sol)
abstract contract ERC1155TokenReceiver {
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external virtual returns (bytes4) {
        return ERC1155TokenReceiver.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) external virtual returns (bytes4) {
        return ERC1155TokenReceiver.onERC1155BatchReceived.selector;
    }
}
pragma solidity >=0.5.0;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title The interface for the Uniswap V3 Factory
/// @notice The Uniswap V3 Factory facilitates creation of Uniswap V3 pools and control over the protocol fees
interface IUniswapV3Factory {
    /// @notice Emitted when the owner of the factory is changed
    /// @param oldOwner The owner before the owner was changed
    /// @param newOwner The owner after the owner was changed
    event OwnerChanged(address indexed oldOwner, address indexed newOwner);

    /// @notice Emitted when a pool is created
    /// @param token0 The first token of the pool by address sort order
    /// @param token1 The second token of the pool by address sort order
    /// @param fee The fee collected upon every swap in the pool, denominated in hundredths of a bip
    /// @param tickSpacing The minimum number of ticks between initialized ticks
    /// @param pool The address of the created pool
    event PoolCreated(
        address indexed token0,
        address indexed token1,
        uint24 indexed fee,
        int24 tickSpacing,
        address pool
    );

    /// @notice Emitted when a new fee amount is enabled for pool creation via the factory
    /// @param fee The enabled fee, denominated in hundredths of a bip
    /// @param tickSpacing The minimum number of ticks between initialized ticks for pools created with the given fee
    event FeeAmountEnabled(uint24 indexed fee, int24 indexed tickSpacing);

    /// @notice Returns the current owner of the factory
    /// @dev Can be changed by the current owner via setOwner
    /// @return The address of the factory owner
    function owner() external view returns (address);

    /// @notice Returns the tick spacing for a given fee amount, if enabled, or 0 if not enabled
    /// @dev A fee amount can never be removed, so this value should be hard coded or cached in the calling context
    /// @param fee The enabled fee, denominated in hundredths of a bip. Returns 0 in case of unenabled fee
    /// @return The tick spacing
    function feeAmountTickSpacing(uint24 fee) external view returns (int24);

    /// @notice Returns the pool address for a given pair of tokens and a fee, or address 0 if it does not exist
    /// @dev tokenA and tokenB may be passed in either token0/token1 or token1/token0 order
    /// @param tokenA The contract address of either token0 or token1
    /// @param tokenB The contract address of the other token
    /// @param fee The fee collected upon every swap in the pool, denominated in hundredths of a bip
    /// @return pool The pool address
    function getPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external view returns (address pool);

    /// @notice Creates a pool for the given two tokens and fee
    /// @param tokenA One of the two tokens in the desired pool
    /// @param tokenB The other of the two tokens in the desired pool
    /// @param fee The desired fee for the pool
    /// @dev tokenA and tokenB may be passed in either order: token0/token1 or token1/token0. tickSpacing is retrieved
    /// from the fee. The call will revert if the pool already exists, the fee is invalid, or the token arguments
    /// are invalid.
    /// @return pool The address of the newly created pool
    function createPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external returns (address pool);

    /// @notice Updates the owner of the factory
    /// @dev Must be called by the current owner
    /// @param _owner The new owner of the factory
    function setOwner(address _owner) external;

    /// @notice Enables a fee amount with the given tickSpacing
    /// @dev Fee amounts may never be removed once enabled
    /// @param fee The fee amount to enable, denominated in hundredths of a bip (i.e. 1e-6)
    /// @param tickSpacing The spacing between ticks to be enforced for all pools created with the given fee amount
    function enableFeeAmount(uint24 fee, int24 tickSpacing) external;
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

import {IUniswapV3PoolImmutables} from './pool/IUniswapV3PoolImmutables.sol';
import {IUniswapV3PoolState} from './pool/IUniswapV3PoolState.sol';
import {IUniswapV3PoolDerivedState} from './pool/IUniswapV3PoolDerivedState.sol';
import {IUniswapV3PoolActions} from './pool/IUniswapV3PoolActions.sol';
import {IUniswapV3PoolOwnerActions} from './pool/IUniswapV3PoolOwnerActions.sol';
import {IUniswapV3PoolErrors} from './pool/IUniswapV3PoolErrors.sol';
import {IUniswapV3PoolEvents} from './pool/IUniswapV3PoolEvents.sol';

/// @title The interface for a Uniswap V3 Pool
/// @notice A Uniswap pool facilitates swapping and automated market making between any two assets that strictly conform
/// to the ERC20 specification
/// @dev The pool interface is broken up into many smaller pieces
interface IUniswapV3Pool is
    IUniswapV3PoolImmutables,
    IUniswapV3PoolState,
    IUniswapV3PoolDerivedState,
    IUniswapV3PoolActions,
    IUniswapV3PoolOwnerActions,
    IUniswapV3PoolErrors,
    IUniswapV3PoolEvents
{

}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Permissionless pool actions
/// @notice Contains pool methods that can be called by anyone
interface IUniswapV3PoolActions {
    /// @notice Sets the initial price for the pool
    /// @dev Price is represented as a sqrt(amountToken1/amountToken0) Q64.96 value
    /// @param sqrtPriceX96 the initial sqrt price of the pool as a Q64.96
    function initialize(uint160 sqrtPriceX96) external;

    /// @notice Adds liquidity for the given recipient/tickLower/tickUpper position
    /// @dev The caller of this method receives a callback in the form of IUniswapV3MintCallback#uniswapV3MintCallback
    /// in which they must pay any token0 or token1 owed for the liquidity. The amount of token0/token1 due depends
    /// on tickLower, tickUpper, the amount of liquidity, and the current price.
    /// @param recipient The address for which the liquidity will be created
    /// @param tickLower The lower tick of the position in which to add liquidity
    /// @param tickUpper The upper tick of the position in which to add liquidity
    /// @param amount The amount of liquidity to mint
    /// @param data Any data that should be passed through to the callback
    /// @return amount0 The amount of token0 that was paid to mint the given amount of liquidity. Matches the value in the callback
    /// @return amount1 The amount of token1 that was paid to mint the given amount of liquidity. Matches the value in the callback
    function mint(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount,
        bytes calldata data
    ) external returns (uint256 amount0, uint256 amount1);

    /// @notice Collects tokens owed to a position
    /// @dev Does not recompute fees earned, which must be done either via mint or burn of any amount of liquidity.
    /// Collect must be called by the position owner. To withdraw only token0 or only token1, amount0Requested or
    /// amount1Requested may be set to zero. To withdraw all tokens owed, caller may pass any value greater than the
    /// actual tokens owed, e.g. type(uint128).max. Tokens owed may be from accumulated swap fees or burned liquidity.
    /// @param recipient The address which should receive the fees collected
    /// @param tickLower The lower tick of the position for which to collect fees
    /// @param tickUpper The upper tick of the position for which to collect fees
    /// @param amount0Requested How much token0 should be withdrawn from the fees owed
    /// @param amount1Requested How much token1 should be withdrawn from the fees owed
    /// @return amount0 The amount of fees collected in token0
    /// @return amount1 The amount of fees collected in token1
    function collect(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);

    /// @notice Burn liquidity from the sender and account tokens owed for the liquidity to the position
    /// @dev Can be used to trigger a recalculation of fees owed to a position by calling with an amount of 0
    /// @dev Fees must be collected separately via a call to #collect
    /// @param tickLower The lower tick of the position for which to burn liquidity
    /// @param tickUpper The upper tick of the position for which to burn liquidity
    /// @param amount How much liquidity to burn
    /// @return amount0 The amount of token0 sent to the recipient
    /// @return amount1 The amount of token1 sent to the recipient
    function burn(
        int24 tickLower,
        int24 tickUpper,
        uint128 amount
    ) external returns (uint256 amount0, uint256 amount1);

    /// @notice Swap token0 for token1, or token1 for token0
    /// @dev The caller of this method receives a callback in the form of IUniswapV3SwapCallback#uniswapV3SwapCallback
    /// @param recipient The address to receive the output of the swap
    /// @param zeroForOne The direction of the swap, true for token0 to token1, false for token1 to token0
    /// @param amountSpecified The amount of the swap, which implicitly configures the swap as exact input (positive), or exact output (negative)
    /// @param sqrtPriceLimitX96 The Q64.96 sqrt price limit. If zero for one, the price cannot be less than this
    /// value after the swap. If one for zero, the price cannot be greater than this value after the swap
    /// @param data Any data to be passed through to the callback
    /// @return amount0 The delta of the balance of token0 of the pool, exact when negative, minimum when positive
    /// @return amount1 The delta of the balance of token1 of the pool, exact when negative, minimum when positive
    function swap(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata data
    ) external returns (int256 amount0, int256 amount1);

    /// @notice Receive token0 and/or token1 and pay it back, plus a fee, in the callback
    /// @dev The caller of this method receives a callback in the form of IUniswapV3FlashCallback#uniswapV3FlashCallback
    /// @dev Can be used to donate underlying tokens pro-rata to currently in-range liquidity providers by calling
    /// with 0 amount{0,1} and sending the donation amount(s) from the callback
    /// @param recipient The address which will receive the token0 and token1 amounts
    /// @param amount0 The amount of token0 to send
    /// @param amount1 The amount of token1 to send
    /// @param data Any data to be passed through to the callback
    function flash(
        address recipient,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external;

    /// @notice Increase the maximum number of price and liquidity observations that this pool will store
    /// @dev This method is no-op if the pool already has an observationCardinalityNext greater than or equal to
    /// the input observationCardinalityNext.
    /// @param observationCardinalityNext The desired minimum number of observations for the pool to store
    function increaseObservationCardinalityNext(uint16 observationCardinalityNext) external;
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Pool state that is not stored
/// @notice Contains view functions to provide information about the pool that is computed rather than stored on the
/// blockchain. The functions here may have variable gas costs.
interface IUniswapV3PoolDerivedState {
    /// @notice Returns the cumulative tick and liquidity as of each timestamp `secondsAgo` from the current block timestamp
    /// @dev To get a time weighted average tick or liquidity-in-range, you must call this with two values, one representing
    /// the beginning of the period and another for the end of the period. E.g., to get the last hour time-weighted average tick,
    /// you must call it with secondsAgos = [3600, 0].
    /// @dev The time weighted average tick represents the geometric time weighted average price of the pool, in
    /// log base sqrt(1.0001) of token1 / token0. The TickMath library can be used to go from a tick value to a ratio.
    /// @param secondsAgos From how long ago each cumulative tick and liquidity value should be returned
    /// @return tickCumulatives Cumulative tick values as of each `secondsAgos` from the current block timestamp
    /// @return secondsPerLiquidityCumulativeX128s Cumulative seconds per liquidity-in-range value as of each `secondsAgos` from the current block
    /// timestamp
    function observe(uint32[] calldata secondsAgos)
        external
        view
        returns (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s);

    /// @notice Returns a snapshot of the tick cumulative, seconds per liquidity and seconds inside a tick range
    /// @dev Snapshots must only be compared to other snapshots, taken over a period for which a position existed.
    /// I.e., snapshots cannot be compared if a position is not held for the entire period between when the first
    /// snapshot is taken and the second snapshot is taken.
    /// @param tickLower The lower tick of the range
    /// @param tickUpper The upper tick of the range
    /// @return tickCumulativeInside The snapshot of the tick accumulator for the range
    /// @return secondsPerLiquidityInsideX128 The snapshot of seconds per liquidity for the range
    /// @return secondsInside The snapshot of seconds per liquidity for the range
    function snapshotCumulativesInside(int24 tickLower, int24 tickUpper)
        external
        view
        returns (
            int56 tickCumulativeInside,
            uint160 secondsPerLiquidityInsideX128,
            uint32 secondsInside
        );
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Errors emitted by a pool
/// @notice Contains all events emitted by the pool
interface IUniswapV3PoolErrors {
    error LOK();
    error TLU();
    error TLM();
    error TUM();
    error AI();
    error M0();
    error M1();
    error AS();
    error IIA();
    error L();
    error F0();
    error F1();
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Events emitted by a pool
/// @notice Contains all events emitted by the pool
interface IUniswapV3PoolEvents {
    /// @notice Emitted exactly once by a pool when #initialize is first called on the pool
    /// @dev Mint/Burn/Swap cannot be emitted by the pool before Initialize
    /// @param sqrtPriceX96 The initial sqrt price of the pool, as a Q64.96
    /// @param tick The initial tick of the pool, i.e. log base 1.0001 of the starting price of the pool
    event Initialize(uint160 sqrtPriceX96, int24 tick);

    /// @notice Emitted when liquidity is minted for a given position
    /// @param sender The address that minted the liquidity
    /// @param owner The owner of the position and recipient of any minted liquidity
    /// @param tickLower The lower tick of the position
    /// @param tickUpper The upper tick of the position
    /// @param amount The amount of liquidity minted to the position range
    /// @param amount0 How much token0 was required for the minted liquidity
    /// @param amount1 How much token1 was required for the minted liquidity
    event Mint(
        address sender,
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    /// @notice Emitted when fees are collected by the owner of a position
    /// @dev Collect events may be emitted with zero amount0 and amount1 when the caller chooses not to collect fees
    /// @param owner The owner of the position for which fees are collected
    /// @param tickLower The lower tick of the position
    /// @param tickUpper The upper tick of the position
    /// @param amount0 The amount of token0 fees collected
    /// @param amount1 The amount of token1 fees collected
    event Collect(
        address indexed owner,
        address recipient,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount0,
        uint128 amount1
    );

    /// @notice Emitted when a position's liquidity is removed
    /// @dev Does not withdraw any fees earned by the liquidity position, which must be withdrawn via #collect
    /// @param owner The owner of the position for which liquidity is removed
    /// @param tickLower The lower tick of the position
    /// @param tickUpper The upper tick of the position
    /// @param amount The amount of liquidity to remove
    /// @param amount0 The amount of token0 withdrawn
    /// @param amount1 The amount of token1 withdrawn
    event Burn(
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    /// @notice Emitted by the pool for any swaps between token0 and token1
    /// @param sender The address that initiated the swap call, and that received the callback
    /// @param recipient The address that received the output of the swap
    /// @param amount0 The delta of the token0 balance of the pool
    /// @param amount1 The delta of the token1 balance of the pool
    /// @param sqrtPriceX96 The sqrt(price) of the pool after the swap, as a Q64.96
    /// @param liquidity The liquidity of the pool after the swap
    /// @param tick The log base 1.0001 of price of the pool after the swap
    event Swap(
        address indexed sender,
        address indexed recipient,
        int256 amount0,
        int256 amount1,
        uint160 sqrtPriceX96,
        uint128 liquidity,
        int24 tick
    );

    /// @notice Emitted by the pool for any flashes of token0/token1
    /// @param sender The address that initiated the swap call, and that received the callback
    /// @param recipient The address that received the tokens from flash
    /// @param amount0 The amount of token0 that was flashed
    /// @param amount1 The amount of token1 that was flashed
    /// @param paid0 The amount of token0 paid for the flash, which can exceed the amount0 plus the fee
    /// @param paid1 The amount of token1 paid for the flash, which can exceed the amount1 plus the fee
    event Flash(
        address indexed sender,
        address indexed recipient,
        uint256 amount0,
        uint256 amount1,
        uint256 paid0,
        uint256 paid1
    );

    /// @notice Emitted by the pool for increases to the number of observations that can be stored
    /// @dev observationCardinalityNext is not the observation cardinality until an observation is written at the index
    /// just before a mint/swap/burn.
    /// @param observationCardinalityNextOld The previous value of the next observation cardinality
    /// @param observationCardinalityNextNew The updated value of the next observation cardinality
    event IncreaseObservationCardinalityNext(
        uint16 observationCardinalityNextOld,
        uint16 observationCardinalityNextNew
    );

    /// @notice Emitted when the protocol fee is changed by the pool
    /// @param feeProtocol0Old The previous value of the token0 protocol fee
    /// @param feeProtocol1Old The previous value of the token1 protocol fee
    /// @param feeProtocol0New The updated value of the token0 protocol fee
    /// @param feeProtocol1New The updated value of the token1 protocol fee
    event SetFeeProtocol(uint8 feeProtocol0Old, uint8 feeProtocol1Old, uint8 feeProtocol0New, uint8 feeProtocol1New);

    /// @notice Emitted when the collected protocol fees are withdrawn by the factory owner
    /// @param sender The address that collects the protocol fees
    /// @param recipient The address that receives the collected protocol fees
    /// @param amount0 The amount of token0 protocol fees that is withdrawn
    /// @param amount0 The amount of token1 protocol fees that is withdrawn
    event CollectProtocol(address indexed sender, address indexed recipient, uint128 amount0, uint128 amount1);
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Pool state that never changes
/// @notice These parameters are fixed for a pool forever, i.e., the methods will always return the same values
interface IUniswapV3PoolImmutables {
    /// @notice The contract that deployed the pool, which must adhere to the IUniswapV3Factory interface
    /// @return The contract address
    function factory() external view returns (address);

    /// @notice The first of the two tokens of the pool, sorted by address
    /// @return The token contract address
    function token0() external view returns (address);

    /// @notice The second of the two tokens of the pool, sorted by address
    /// @return The token contract address
    function token1() external view returns (address);

    /// @notice The pool's fee in hundredths of a bip, i.e. 1e-6
    /// @return The fee
    function fee() external view returns (uint24);

    /// @notice The pool tick spacing
    /// @dev Ticks can only be used at multiples of this value, minimum of 1 and always positive
    /// e.g.: a tickSpacing of 3 means ticks can be initialized every 3rd tick, i.e., ..., -6, -3, 0, 3, 6, ...
    /// This value is an int24 to avoid casting even though it is always positive.
    /// @return The tick spacing
    function tickSpacing() external view returns (int24);

    /// @notice The maximum amount of position liquidity that can use any tick in the range
    /// @dev This parameter is enforced per tick to prevent liquidity from overflowing a uint128 at any point, and
    /// also prevents out-of-range liquidity from being used to prevent adding in-range liquidity to a pool
    /// @return The max amount of liquidity per tick
    function maxLiquidityPerTick() external view returns (uint128);
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Permissioned pool actions
/// @notice Contains pool methods that may only be called by the factory owner
interface IUniswapV3PoolOwnerActions {
    /// @notice Set the denominator of the protocol's % share of the fees
    /// @param feeProtocol0 new protocol fee for token0 of the pool
    /// @param feeProtocol1 new protocol fee for token1 of the pool
    function setFeeProtocol(uint8 feeProtocol0, uint8 feeProtocol1) external;

    /// @notice Collect the protocol fee accrued to the pool
    /// @param recipient The address to which collected protocol fees should be sent
    /// @param amount0Requested The maximum amount of token0 to send, can be 0 to collect fees in only token1
    /// @param amount1Requested The maximum amount of token1 to send, can be 0 to collect fees in only token0
    /// @return amount0 The protocol fee collected in token0
    /// @return amount1 The protocol fee collected in token1
    function collectProtocol(
        address recipient,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Pool state that can change
/// @notice These methods compose the pool's state, and can change with any frequency including multiple times
/// per transaction
interface IUniswapV3PoolState {
    /// @notice The 0th storage slot in the pool stores many values, and is exposed as a single method to save gas
    /// when accessed externally.
    /// @return sqrtPriceX96 The current price of the pool as a sqrt(token1/token0) Q64.96 value
    /// @return tick The current tick of the pool, i.e. according to the last tick transition that was run.
    /// This value may not always be equal to SqrtTickMath.getTickAtSqrtRatio(sqrtPriceX96) if the price is on a tick
    /// boundary.
    /// @return observationIndex The index of the last oracle observation that was written,
    /// @return observationCardinality The current maximum number of observations stored in the pool,
    /// @return observationCardinalityNext The next maximum number of observations, to be updated when the observation.
    /// @return feeProtocol The protocol fee for both tokens of the pool.
    /// Encoded as two 4 bit values, where the protocol fee of token1 is shifted 4 bits and the protocol fee of token0
    /// is the lower 4 bits. Used as the denominator of a fraction of the swap fee, e.g. 4 means 1/4th of the swap fee.
    /// unlocked Whether the pool is currently locked to reentrancy
    function slot0()
        external
        view
        returns (
            uint160 sqrtPriceX96,
            int24 tick,
            uint16 observationIndex,
            uint16 observationCardinality,
            uint16 observationCardinalityNext,
            uint8 feeProtocol,
            bool unlocked
        );

    /// @notice The fee growth as a Q128.128 fees of token0 collected per unit of liquidity for the entire life of the pool
    /// @dev This value can overflow the uint256
    function feeGrowthGlobal0X128() external view returns (uint256);

    /// @notice The fee growth as a Q128.128 fees of token1 collected per unit of liquidity for the entire life of the pool
    /// @dev This value can overflow the uint256
    function feeGrowthGlobal1X128() external view returns (uint256);

    /// @notice The amounts of token0 and token1 that are owed to the protocol
    /// @dev Protocol fees will never exceed uint128 max in either token
    function protocolFees() external view returns (uint128 token0, uint128 token1);

    /// @notice The currently in range liquidity available to the pool
    /// @dev This value has no relationship to the total liquidity across all ticks
    /// @return The liquidity at the current price of the pool
    function liquidity() external view returns (uint128);

    /// @notice Look up information about a specific tick in the pool
    /// @param tick The tick to look up
    /// @return liquidityGross the total amount of position liquidity that uses the pool either as tick lower or
    /// tick upper
    /// @return liquidityNet how much liquidity changes when the pool price crosses the tick,
    /// @return feeGrowthOutside0X128 the fee growth on the other side of the tick from the current tick in token0,
    /// @return feeGrowthOutside1X128 the fee growth on the other side of the tick from the current tick in token1,
    /// @return tickCumulativeOutside the cumulative tick value on the other side of the tick from the current tick
    /// @return secondsPerLiquidityOutsideX128 the seconds spent per liquidity on the other side of the tick from the current tick,
    /// @return secondsOutside the seconds spent on the other side of the tick from the current tick,
    /// @return initialized Set to true if the tick is initialized, i.e. liquidityGross is greater than 0, otherwise equal to false.
    /// Outside values can only be used if the tick is initialized, i.e. if liquidityGross is greater than 0.
    /// In addition, these values are only relative and must be used only in comparison to previous snapshots for
    /// a specific position.
    function ticks(int24 tick)
        external
        view
        returns (
            uint128 liquidityGross,
            int128 liquidityNet,
            uint256 feeGrowthOutside0X128,
            uint256 feeGrowthOutside1X128,
            int56 tickCumulativeOutside,
            uint160 secondsPerLiquidityOutsideX128,
            uint32 secondsOutside,
            bool initialized
        );

    /// @notice Returns 256 packed tick initialized boolean values. See TickBitmap for more information
    function tickBitmap(int16 wordPosition) external view returns (uint256);

    /// @notice Returns the information about a position by the position's key
    /// @param key The position's key is a hash of a preimage composed by the owner, tickLower and tickUpper
    /// @return liquidity The amount of liquidity in the position,
    /// @return feeGrowthInside0LastX128 fee growth of token0 inside the tick range as of the last mint/burn/poke,
    /// @return feeGrowthInside1LastX128 fee growth of token1 inside the tick range as of the last mint/burn/poke,
    /// @return tokensOwed0 the computed amount of token0 owed to the position as of the last mint/burn/poke,
    /// @return tokensOwed1 the computed amount of token1 owed to the position as of the last mint/burn/poke
    function positions(bytes32 key)
        external
        view
        returns (
            uint128 liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        );

    /// @notice Returns data about a specific observation index
    /// @param index The element of the observations array to fetch
    /// @dev You most likely want to use #observe() instead of this method to get an observation as of some amount of time
    /// ago, rather than at a specific index in the array.
    /// @return blockTimestamp The timestamp of the observation,
    /// @return tickCumulative the tick multiplied by seconds elapsed for the life of the pool as of the observation timestamp,
    /// @return secondsPerLiquidityCumulativeX128 the seconds per in range liquidity for the life of the pool as of the observation timestamp,
    /// @return initialized whether the observation has been initialized and the values are safe to use
    function observations(uint256 index)
        external
        view
        returns (
            uint32 blockTimestamp,
            int56 tickCumulative,
            uint160 secondsPerLiquidityCumulativeX128,
            bool initialized
        );
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

/// @title Math library for computing sqrt prices from ticks and vice versa
/// @notice Computes sqrt price for ticks of size 1.0001, i.e. sqrt(1.0001^tick) as fixed point Q64.96 numbers. Supports
/// prices between 2**-128 and 2**128
library TickMath {
    error T();
    error R();

    /// @dev The minimum tick that may be passed to #getSqrtRatioAtTick computed from log base 1.0001 of 2**-128
    int24 internal constant MIN_TICK = -887272;
    /// @dev The maximum tick that may be passed to #getSqrtRatioAtTick computed from log base 1.0001 of 2**128
    int24 internal constant MAX_TICK = -MIN_TICK;

    /// @dev The minimum value that can be returned from #getSqrtRatioAtTick. Equivalent to getSqrtRatioAtTick(MIN_TICK)
    uint160 internal constant MIN_SQRT_RATIO = 4295128739;
    /// @dev The maximum value that can be returned from #getSqrtRatioAtTick. Equivalent to getSqrtRatioAtTick(MAX_TICK)
    uint160 internal constant MAX_SQRT_RATIO = 1461446703485210103287273052203988822378723970342;

    /// @notice Calculates sqrt(1.0001^tick) * 2^96
    /// @dev Throws if |tick| > max tick
    /// @param tick The input tick for the above formula
    /// @return sqrtPriceX96 A Fixed point Q64.96 number representing the sqrt of the ratio of the two assets (token1/token0)
    /// at the given tick
    function getSqrtRatioAtTick(int24 tick) internal pure returns (uint160 sqrtPriceX96) {
        unchecked {
            uint256 absTick = tick < 0 ? uint256(-int256(tick)) : uint256(int256(tick));
            if (absTick > uint256(int256(MAX_TICK))) revert T();

            uint256 ratio = absTick & 0x1 != 0
                ? 0xfffcb933bd6fad37aa2d162d1a594001
                : 0x100000000000000000000000000000000;
            if (absTick & 0x2 != 0) ratio = (ratio * 0xfff97272373d413259a46990580e213a) >> 128;
            if (absTick & 0x4 != 0) ratio = (ratio * 0xfff2e50f5f656932ef12357cf3c7fdcc) >> 128;
            if (absTick & 0x8 != 0) ratio = (ratio * 0xffe5caca7e10e4e61c3624eaa0941cd0) >> 128;
            if (absTick & 0x10 != 0) ratio = (ratio * 0xffcb9843d60f6159c9db58835c926644) >> 128;
            if (absTick & 0x20 != 0) ratio = (ratio * 0xff973b41fa98c081472e6896dfb254c0) >> 128;
            if (absTick & 0x40 != 0) ratio = (ratio * 0xff2ea16466c96a3843ec78b326b52861) >> 128;
            if (absTick & 0x80 != 0) ratio = (ratio * 0xfe5dee046a99a2a811c461f1969c3053) >> 128;
            if (absTick & 0x100 != 0) ratio = (ratio * 0xfcbe86c7900a88aedcffc83b479aa3a4) >> 128;
            if (absTick & 0x200 != 0) ratio = (ratio * 0xf987a7253ac413176f2b074cf7815e54) >> 128;
            if (absTick & 0x400 != 0) ratio = (ratio * 0xf3392b0822b70005940c7a398e4b70f3) >> 128;
            if (absTick & 0x800 != 0) ratio = (ratio * 0xe7159475a2c29b7443b29c7fa6e889d9) >> 128;
            if (absTick & 0x1000 != 0) ratio = (ratio * 0xd097f3bdfd2022b8845ad8f792aa5825) >> 128;
            if (absTick & 0x2000 != 0) ratio = (ratio * 0xa9f746462d870fdf8a65dc1f90e061e5) >> 128;
            if (absTick & 0x4000 != 0) ratio = (ratio * 0x70d869a156d2a1b890bb3df62baf32f7) >> 128;
            if (absTick & 0x8000 != 0) ratio = (ratio * 0x31be135f97d08fd981231505542fcfa6) >> 128;
            if (absTick & 0x10000 != 0) ratio = (ratio * 0x9aa508b5b7a84e1c677de54f3e99bc9) >> 128;
            if (absTick & 0x20000 != 0) ratio = (ratio * 0x5d6af8dedb81196699c329225ee604) >> 128;
            if (absTick & 0x40000 != 0) ratio = (ratio * 0x2216e584f5fa1ea926041bedfe98) >> 128;
            if (absTick & 0x80000 != 0) ratio = (ratio * 0x48a170391f7dc42444e8fa2) >> 128;

            if (tick > 0) ratio = type(uint256).max / ratio;

            // this divides by 1<<32 rounding up to go from a Q128.128 to a Q128.96.
            // we then downcast because we know the result always fits within 160 bits due to our tick input constraint
            // we round up in the division so getTickAtSqrtRatio of the output price is always consistent
            sqrtPriceX96 = uint160((ratio >> 32) + (ratio % (1 << 32) == 0 ? 0 : 1));
        }
    }

    /// @notice Calculates the greatest tick value such that getRatioAtTick(tick) <= ratio
    /// @dev Throws in case sqrtPriceX96 < MIN_SQRT_RATIO, as MIN_SQRT_RATIO is the lowest value getRatioAtTick may
    /// ever return.
    /// @param sqrtPriceX96 The sqrt ratio for which to compute the tick as a Q64.96
    /// @return tick The greatest tick for which the ratio is less than or equal to the input ratio
    function getTickAtSqrtRatio(uint160 sqrtPriceX96) internal pure returns (int24 tick) {
        unchecked {
            // second inequality must be < because the price can never reach the price at the max tick
            if (!(sqrtPriceX96 >= MIN_SQRT_RATIO && sqrtPriceX96 < MAX_SQRT_RATIO)) revert R();
            uint256 ratio = uint256(sqrtPriceX96) << 32;

            uint256 r = ratio;
            uint256 msb = 0;

            assembly {
                let f := shl(7, gt(r, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF))
                msb := or(msb, f)
                r := shr(f, r)
            }
            assembly {
                let f := shl(6, gt(r, 0xFFFFFFFFFFFFFFFF))
                msb := or(msb, f)
                r := shr(f, r)
            }
            assembly {
                let f := shl(5, gt(r, 0xFFFFFFFF))
                msb := or(msb, f)
                r := shr(f, r)
            }
            assembly {
                let f := shl(4, gt(r, 0xFFFF))
                msb := or(msb, f)
                r := shr(f, r)
            }
            assembly {
                let f := shl(3, gt(r, 0xFF))
                msb := or(msb, f)
                r := shr(f, r)
            }
            assembly {
                let f := shl(2, gt(r, 0xF))
                msb := or(msb, f)
                r := shr(f, r)
            }
            assembly {
                let f := shl(1, gt(r, 0x3))
                msb := or(msb, f)
                r := shr(f, r)
            }
            assembly {
                let f := gt(r, 0x1)
                msb := or(msb, f)
            }

            if (msb >= 128) r = ratio >> (msb - 127);
            else r = ratio << (127 - msb);

            int256 log_2 = (int256(msb) - 128) << 64;

            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                log_2 := or(log_2, shl(63, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                log_2 := or(log_2, shl(62, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                log_2 := or(log_2, shl(61, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                log_2 := or(log_2, shl(60, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                log_2 := or(log_2, shl(59, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                log_2 := or(log_2, shl(58, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                log_2 := or(log_2, shl(57, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                log_2 := or(log_2, shl(56, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                log_2 := or(log_2, shl(55, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                log_2 := or(log_2, shl(54, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                log_2 := or(log_2, shl(53, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                log_2 := or(log_2, shl(52, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                log_2 := or(log_2, shl(51, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                log_2 := or(log_2, shl(50, f))
            }

            int256 log_sqrt10001 = log_2 * 255738958999603826347141; // 128.128 number

            int24 tickLow = int24((log_sqrt10001 - 3402992956809132418596140100660247210) >> 128);
            int24 tickHi = int24((log_sqrt10001 + 291339464771989622907027621153398088495) >> 128);

            tick = tickLow == tickHi ? tickLow : getSqrtRatioAtTick(tickHi) <= sqrtPriceX96 ? tickHi : tickLow;
        }
    }
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.6.0;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

library TransferHelper {
    /// @notice Transfers tokens from the targeted address to the given destination
    /// @notice Errors with 'STF' if transfer fails
    /// @param token The contract address of the token to be transferred
    /// @param from The originating address from which the tokens will be transferred
    /// @param to The destination address of the transfer
    /// @param value The amount to be transferred
    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, value)
        );
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'STF');
    }

    /// @notice Transfers tokens from msg.sender to a recipient
    /// @dev Errors with ST if transfer fails
    /// @param token The contract address of the token which will be transferred
    /// @param to The recipient of the transfer
    /// @param value The value of the transfer
    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.transfer.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'ST');
    }

    /// @notice Approves the stipulated contract to spend the given allowance in the given token
    /// @dev Errors with 'SA' if transfer fails
    /// @param token The contract address of the token to be approved
    /// @param to The target of the approval
    /// @param value The amount of the given token the target will be allowed to spend
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.approve.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'SA');
    }

    /// @notice Transfers ETH to the recipient address
    /// @dev Fails with `STE`
    /// @param to The destination of the transfer
    /// @param value The value to be transferred
    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'STE');
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

// Libraries
import {Fees} from "./libraries/Fees.sol";
import {FullMath} from "./libraries/FullMath.sol";
import {SirStructs} from "./libraries/SirStructs.sol";
import {Clone} from "lib/clones-with-immutable-args/src/Clone.sol";

// Contracts
import {Vault} from "./Vault.sol";

/**
 * @notice Every APE token from every vault is its own ERC-20 token.
 * It is deployed during the initialization of the vault.
 * @dev To minimize gas cost we use the ClonesWithImmutableArgs library to replicate the contract.
 * APE is a mod from Solmate's ERC20.sol
 */
contract APE is Clone {
    error PermitDeadlineExpired();
    error InvalidSigner();

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    address public debtToken;
    address public collateralToken;

    string public name;
    string public symbol;
    uint8 public decimals;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    uint256 private immutable INITIAL_CHAIN_ID;

    mapping(address => uint256) public nonces;

    /*///////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    modifier onlyVault() {
        address vault = _getArgAddress(1);
        require(vault == msg.sender);
        _;
    }

    constructor() {
        INITIAL_CHAIN_ID = block.chainid;
    }

    /**
     * @dev Initializes the contract. It is called by the vault.
     */
    function initialize(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        address debtToken_,
        address collateralToken_
    ) external onlyVault {
        name = name_;
        symbol = symbol_;
        decimals = decimals_;

        debtToken = debtToken_;
        collateralToken = collateralToken_;
    }

    /**
     * @notice Returns the current leverage tier.
     */
    function leverageTier() public pure returns (int8) {
        return int8(_getArgUint8(0));
    }

    /*///////////////////////////////////////////////////////////////
                              IERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Sets the allowance of `spender` to `amount`.
     */
    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    /**
     * @notice Transfers `amount` tokens to `to`.
     */
    function transfer(address to, uint256 amount) external returns (bool) {
        balanceOf[msg.sender] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(msg.sender, to, amount);

        return true;
    }

    /**
     * @notice Transfers `amount` tokens from `from` to `to`.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
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

    /*///////////////////////////////////////////////////////////////
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
    ) external {
        if (deadline < block.timestamp) revert PermitDeadlineExpired();

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

            if (recoveredAddress == address(0) || recoveredAddress != owner) revert InvalidSigner();

            allowance[recoveredAddress][spender] = value;
        }

        emit Approval(owner, spender, value);
    }

    function DOMAIN_SEPARATOR() public view returns (bytes32) {
        return block.chainid == INITIAL_CHAIN_ID ? bytes32(_getArgUint256(21)) : _computeDomainSeparator();
    }

    function _computeDomainSeparator() private view returns (bytes32) {
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

    /*///////////////////////////////////////////////////////////////
                       MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev The vault contract calls this function to mint APE.
     * It splits the collateral amount between the minter, stakers and POL and updates the total supply and balances.
     */
    function mint(
        address to,
        uint16 baseFee,
        uint8 tax,
        SirStructs.Reserves memory reserves,
        uint144 collateralDeposited
    ) external onlyVault returns (SirStructs.Reserves memory newReserves, SirStructs.Fees memory fees, uint256 amount) {
        // Loads supply of APE
        uint256 supplyAPE = totalSupply;

        // Substract fees
        fees = Fees.feeAPE(collateralDeposited, baseFee, leverageTier(), tax);

        unchecked {
            // Mint APE
            amount = supplyAPE == 0 // By design reserveApes can never be 0 unless it is the first mint ever
                ? fees.collateralInOrWithdrawn + reserves.reserveApes // Any ownless APE reserve is minted by the first ape
                : FullMath.mulDiv(supplyAPE, fees.collateralInOrWithdrawn, reserves.reserveApes);
            balanceOf[to] += amount; // If it OF, so will totalSupply
        }

        reserves.reserveApes += fees.collateralInOrWithdrawn;
        totalSupply = supplyAPE + amount; // Checked math to ensure totalSupply never overflows
        emit Transfer(address(0), to, amount);

        newReserves = reserves; // Important because memory is not persistent across external calls
    }

    /**
     * @dev The vault contract calls this function when a user burns APE.
     * It splits the collateral amount between the minter, stakers and POL and updates the total supply and balances.
     */
    function burn(
        address from,
        uint16 baseFee,
        uint8 tax,
        SirStructs.Reserves memory reserves,
        uint256 amount
    ) external onlyVault returns (SirStructs.Reserves memory newReserves, SirStructs.Fees memory fees) {
        // Loads supply of APE
        uint256 supplyAPE = totalSupply;

        // Burn APE
        uint144 collateralOut = uint144(FullMath.mulDiv(reserves.reserveApes, amount, supplyAPE)); // Compute amount of collateral
        balanceOf[from] -= amount; // Checks for underflow
        unchecked {
            totalSupply = supplyAPE - amount;
            reserves.reserveApes -= collateralOut;

            // Substract fees
            fees = Fees.feeAPE(collateralOut, baseFee, leverageTier(), tax);

            newReserves = reserves; // Important because memory is not persistent across external calls
        }
        emit Transfer(from, address(0), amount);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Interfaces
import {IUniswapV3Factory} from "v3-core/interfaces/IUniswapV3Factory.sol";
import {IUniswapV3Pool} from "v3-core/interfaces/IUniswapV3Pool.sol";

// Libraries
import {UniswapPoolAddress} from "./libraries/UniswapPoolAddress.sol";
import {SirStructs} from "./libraries/SirStructs.sol";

/**
 * @notice The Oracle contract is our interface to Uniswap v3 pools and their oracle data.
 * It allows the SIR protocol to retrieve the TWAP of any pair of tokens,
 * without worrying about which fee tier to use, nor whether the pool exists,
 * nor if the TWAP is initialized to the proper length.
 * This oracle is permissionless and requires no administrative access.
 */
contract Oracle {
    error NoUniswapPool();
    error UniswapFeeTierIndexOutOfBounds();
    error OracleAlreadyInitialized();
    error OracleNotInitialized();

    event UniswapFeeTierAdded(uint24 fee);
    event OracleInitialized(
        address indexed token0,
        address indexed token1,
        uint24 feeTierSelected,
        uint136 avLiquidity,
        uint40 period
    );
    event PriceUpdated(address indexed token0, address indexed token1, bool priceTruncated, int64 priceTickX42);

    event UniswapOracleProbed(
        uint24 fee,
        int56 aggPriceTick,
        uint136 avLiquidity,
        uint40 period,
        uint16 cardinalityToIncrease
    );
    event OracleFeeTierChanged(uint24 feeTierPrevious, uint24 feeTierSelected);

    // This struct is used to pass data between functions.
    struct UniswapOracleData {
        IUniswapV3Pool uniswapPool; // Uniswap v3 pool
        int56 aggPriceTick; // Aggregated log price over the period
        uint136 avLiquidity; // Aggregated in-range liquidity over period
        uint40 period; // Duration of the current TWAP
        uint16 cardinalityToIncrease; // Cardinality suggested for increase
    }

    // Constants
    address private immutable UNISWAPV3_FACTORY;
    uint256 internal constant DURATION_UPDATE_FEE_TIER = 25 hours; // No need to test if there is a better fee tier more often than this
    int64 internal constant MAX_TICK_INC_PER_SEC = 1 << 42;
    uint40 internal constant TWAP_DELTA = 1 minutes; // When a new fee tier has larger liquidity, the TWAP array is increased in intervals of TWAP_DELTA.
    uint16 internal constant CARDINALITY_DELTA = uint16((TWAP_DELTA - 1) / (12 seconds)) + 1;
    uint40 public constant TWAP_DURATION = 30 minutes;

    // State variables
    mapping(address token0 => mapping(address token1 => SirStructs.OracleState)) internal _state;

    // Least significant 8 bits represent the length of this tightly packed array, 48 bits for each extra fee tier, which implies a maximum of 5 extra fee tiers.
    uint private _uniswapExtraFeeTiers;

    constructor(address uniswapV3Factory) {
        UNISWAPV3_FACTORY = uniswapV3Factory;
    }

    /*////////////////////////////////////////////////////////////////
                            READ-ONLY FUNCTIONS
    /////////////////////////////////////////////////////////////////*/

    /**
     * @notice Returns the state of the oracle for the pair of tokens.
     * @dev The tokens must be sorted lexicographically.
     */
    function state(address token0, address token1) external view returns (SirStructs.OracleState memory) {
        require(token0 < token1);
        return _state[token0][token1];
    }

    /**
     * @notice Returns the uniswap fee tier of the pair of tokens.
     * @dev The order of the tokens does not matter.
     */
    function uniswapFeeTierOf(address tokenA, address tokenB) external view returns (uint24) {
        (tokenA, tokenB) = _orderTokens(tokenA, tokenB);
        return _state[tokenA][tokenB].uniswapFeeTier.fee;
    }

    /**
     * @notice Returns the address of the uniswap pool for the pair of tokens.
     * @dev The order of the tokens does not matter.
     */
    function uniswapFeeTierAddressOf(address tokenA, address tokenB) external view returns (address) {
        (tokenA, tokenB) = _orderTokens(tokenA, tokenB);
        return
            UniswapPoolAddress.computeAddress(
                UNISWAPV3_FACTORY,
                UniswapPoolAddress.getPoolKey(tokenA, tokenB, _state[tokenA][tokenB].uniswapFeeTier.fee)
            );
    }

    /**
     * @notice Function for getting all the uniswap fee tiers.
     * @dev If a new fee tier is added, anyone can add it using the 'newUniswapFeeTier' function.
     */
    function getUniswapFeeTiers() public view returns (SirStructs.UniswapFeeTier[] memory uniswapFeeTiers) {
        unchecked {
            // Find out # of all possible fee tiers
            uint uniswapExtraFeeTiers_ = _uniswapExtraFeeTiers;
            uint numUniswapExtraFeeTiers = uint(uint8(uniswapExtraFeeTiers_));

            uniswapFeeTiers = new SirStructs.UniswapFeeTier[](4 + numUniswapExtraFeeTiers); // Unchecked is safe because 4+numUniswapExtraFeeTiers ≤ 4+5 ≤ 2^256-1
            uniswapFeeTiers[0] = SirStructs.UniswapFeeTier(100, 1);
            uniswapFeeTiers[1] = SirStructs.UniswapFeeTier(500, 10);
            uniswapFeeTiers[2] = SirStructs.UniswapFeeTier(3000, 60);
            uniswapFeeTiers[3] = SirStructs.UniswapFeeTier(10000, 200);

            // Extra fee tiers
            if (numUniswapExtraFeeTiers > 0) {
                uniswapExtraFeeTiers_ >>= 8;
                for (uint i = 0; i < numUniswapExtraFeeTiers; ++i) {
                    uniswapFeeTiers[4 + i] = SirStructs.UniswapFeeTier(
                        uint24(uniswapExtraFeeTiers_),
                        int24(uint24(uniswapExtraFeeTiers_ >> 24))
                    );
                    uniswapExtraFeeTiers_ >>= 48;
                }
            }
        }
    }

    /// @notice Returns the TWAP price for the collateralToken-debtToken pair.
    function getPrice(address collateralToken, address debtToken) external view returns (int64) {
        unchecked {
            (address token0, address token1) = _orderTokens(collateralToken, debtToken);

            // Get oracle _state
            SirStructs.OracleState memory oracleState = _state[token0][token1];
            if (!oracleState.initialized) revert OracleNotInitialized();

            // Get latest price if not stored
            if (oracleState.timeStampPrice != block.timestamp) {
                // Update price
                UniswapOracleData memory oracleData = _uniswapOracleData(
                    token0,
                    token1,
                    oracleState.uniswapFeeTier.fee
                );

                // oracleData.period == 0 is not possible because it would mean the pool is not initialized
                if (oracleData.period == 1) {
                    /** If the fee tier has been updated this block
                    AND the cardinality of the selected fee tier is 1,
                    THEN the price is unavailable as TWAP.
                */
                    (, int24 tick, , , , , ) = oracleData.uniswapPool.slot0();
                    oracleData.aggPriceTick = tick;
                }

                _updatePrice(oracleState, oracleData);
            }

            // Invert price if necessary
            return collateralToken == token1 ? -oracleState.tickPriceX42 : oracleState.tickPriceX42; // Unchecked is safe because |tickPriceX42| ≤ MAX_TICK_X42
        }
    }

    /*////////////////////////////////////////////////////////////////
                            WRITE FUNCTIONS
    /////////////////////////////////////////////////////////////////*/

    /**
     * @notice Initializes the oracleState for a pair of tokens.
     * @dev Anyone can call it, but it's a no-op if already initialized.
     */
    function initialize(address tokenA, address tokenB) external {
        unchecked {
            (tokenA, tokenB) = _orderTokens(tokenA, tokenB);

            // Get oracle _state
            SirStructs.OracleState memory oracleState = _state[tokenA][tokenB];
            if (oracleState.initialized) return; // No-op return because reverting would cause SIR to fail creating new vaults

            // Get all fee tiers
            SirStructs.UniswapFeeTier[] memory uniswapFeeTiers = getUniswapFeeTiers();
            uint256 numUniswapFeeTiers = uniswapFeeTiers.length;

            // Find the best fee tier by weighted liquidity
            uint256 score;
            UniswapOracleData memory oracleData;
            UniswapOracleData memory bestOracleData;
            for (uint i = 0; i < numUniswapFeeTiers; ++i) {
                // Retrieve average liquidity
                oracleData = _uniswapOracleData(tokenA, tokenB, uniswapFeeTiers[i].fee);
                emit UniswapOracleProbed(
                    uniswapFeeTiers[i].fee,
                    oracleData.aggPriceTick,
                    oracleData.avLiquidity,
                    oracleData.period,
                    oracleData.cardinalityToIncrease
                );

                if (oracleData.avLiquidity > 0) {
                    /** Compute scores.
                        We weight the average liquidity by the duration of the TWAP because
                        we do not want to select a fee tier whose liquidity is easy manipulated.
                            avLiquidity * period = aggregate Liquidity
                    */
                    uint256 scoreTemp = _feeTierScore(
                        uint256(oracleData.avLiquidity) * oracleData.period, // Safe because avLiquidity * period < 2^136 * 2^40 = 2^170
                        uniswapFeeTiers[i]
                    );

                    // Update best score
                    if (scoreTemp > score) {
                        oracleState.indexFeeTier = uint8(i);
                        bestOracleData = oracleData;
                        score = scoreTemp;
                    }
                }
            }

            if (score == 0) revert NoUniswapPool();
            oracleState.indexFeeTierProbeNext = (oracleState.indexFeeTier + 1) % uint8(numUniswapFeeTiers); // Safe because indexFeeTier+1 < 9+1 < 2^8-1
            oracleState.initialized = true;
            oracleState.uniswapFeeTier = uniswapFeeTiers[oracleState.indexFeeTier];
            oracleState.timeStampFeeTier = uint40(block.timestamp);

            // We increase the cardinality of the selected tier if necessary
            if (bestOracleData.cardinalityToIncrease > 0) {
                bestOracleData.uniswapPool.increaseObservationCardinalityNext(bestOracleData.cardinalityToIncrease);
            }

            // Update oracle _state
            _state[tokenA][tokenB] = oracleState;

            emit OracleInitialized(
                tokenA,
                tokenB,
                oracleState.uniswapFeeTier.fee,
                bestOracleData.avLiquidity,
                bestOracleData.period
            );
        }
    }

    /// @notice Anyone can let SIR know that a new fee tier exists in Uniswap V3
    function newUniswapFeeTier(uint24 fee) external {
        require(fee > 0);

        // Get all fee tiers
        SirStructs.UniswapFeeTier[] memory uniswapFeeTiers = getUniswapFeeTiers();
        uint256 numUniswapFeeTiers = uniswapFeeTiers.length;

        // Check there is space to add a new fee tier
        require(numUniswapFeeTiers < 9); // 4 basic fee tiers + 5 extra fee tiers max

        // Check fee tier actually exists in Uniswap v3
        int24 tickSpacing = IUniswapV3Factory(UNISWAPV3_FACTORY).feeAmountTickSpacing(fee);
        require(tickSpacing > 0);

        // Check fee tier has not been added yet
        for (uint256 i = 0; i < numUniswapFeeTiers; ++i) {
            require(fee != uniswapFeeTiers[i].fee);
        }

        // Add new fee tier
        _uniswapExtraFeeTiers |= (uint(fee) | (uint(uint24(tickSpacing)) << 24)) << (8 + 48 * (numUniswapFeeTiers - 4)); // Safe because uniswapFeeTiers's min length is 4 and it is a uint256

        // Increase count
        uint numUniswapExtraFeeTiers = uint(uint8(_uniswapExtraFeeTiers));
        _uniswapExtraFeeTiers &= (2 ** 240 - 1) << 8;
        _uniswapExtraFeeTiers |= numUniswapExtraFeeTiers + 1;

        emit UniswapFeeTierAdded(fee);
    }

    /**
     * @notice Updates the oracle price for a pair of tokens, so that calls in the same block don't need to call Uniswap again.
     * @dev This function also checks periodically if there is a better fee tier.
     * @return tickPriceX42 TWAP price of the pair of tokens
     * @return uniswapPoolAddress address of the pool
     */
    function updateOracleState(
        address collateralToken,
        address debtToken
    ) external returns (int64 tickPriceX42, address uniswapPoolAddress) {
        (address token0, address token1) = _orderTokens(collateralToken, debtToken);

        // Get oracle _state
        SirStructs.OracleState memory oracleState = _state[token0][token1];
        if (!oracleState.initialized) revert OracleNotInitialized();

        // Price is updated once per block at most
        if (oracleState.timeStampPrice != block.timestamp) {
            // Update price
            UniswapOracleData memory oracleData = _uniswapOracleData(token0, token1, oracleState.uniswapFeeTier.fee);
            uniswapPoolAddress = address(oracleData.uniswapPool);
            emit UniswapOracleProbed(
                oracleState.uniswapFeeTier.fee,
                oracleData.aggPriceTick,
                oracleData.avLiquidity,
                oracleData.period,
                oracleData.cardinalityToIncrease
            );

            // oracleData.period == 0 is not possible because it would mean the pool is not initialized
            if (oracleData.period == 1) {
                /** If the fee tier has been updated this block
                    AND the cardinality of the selected fee tier is 1,
                    THEN the price is unavailable as TWAP.
                */
                (, int24 tick, , , , , ) = oracleData.uniswapPool.slot0();
                oracleData.aggPriceTick = tick;
            }

            // Updates price and emits event
            bool priceTruncated = _updatePrice(oracleState, oracleData);
            emit PriceUpdated(token0, token1, priceTruncated, oracleState.tickPriceX42);

            // Update timestamp
            oracleState.timeStampPrice = uint40(block.timestamp);

            // Fee tier is updated once per DURATION_UPDATE_FEE_TIER at most
            if (block.timestamp >= oracleState.timeStampFeeTier + DURATION_UPDATE_FEE_TIER) {
                // No OF because timeStampFeeTier is uint40 and constant DURATION_UPDATE_FEE_TIER is a small number
                bool checkCardinalityCurrentFeeTier;
                if (oracleData.period > 0 && oracleState.indexFeeTier != oracleState.indexFeeTierProbeNext) {
                    /** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** /
                     ** ** THIS SECTION PROBES OTHER FEE TIERS IN CASE THEIR PRICE IS MORE RELIABLE THAN THE CURRENT ONE ** ** **
                     ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** */

                    // Get current fee tier and the one we wish to probe
                    SirStructs.UniswapFeeTier memory uniswapFeeTierProbed = _uniswapFeeTier(
                        oracleState.indexFeeTierProbeNext
                    );

                    // Retrieve oracle data
                    UniswapOracleData memory oracleDataProbed = _uniswapOracleData(
                        token0,
                        token1,
                        uniswapFeeTierProbed.fee
                    );
                    emit UniswapOracleProbed(
                        uniswapFeeTierProbed.fee,
                        oracleDataProbed.aggPriceTick,
                        oracleDataProbed.avLiquidity,
                        oracleDataProbed.period,
                        oracleDataProbed.cardinalityToIncrease
                    );

                    if (oracleDataProbed.avLiquidity > 0) {
                        /** Compute scores.
                
                            Check the scores for the current fee tier and the probed one.
                            We do now weight the average liquidity by the duration of the TWAP because
                            we do not want to discard fee tiers with short TWAPs.

                            This is different than done in initialize() because a fee tier will not be selected until
                            its average liquidity is the best AND the TWAP is fully initialized.
                        */

                        // oracleData.period == 0 is not possible because it can only happen if the pool is not initialized
                        uint256 score = _feeTierScore(oracleData.avLiquidity, oracleState.uniswapFeeTier);
                        // oracleDataProbed.period == 0 is not possible because it would have filtered out by condition oracleDataProbed.avLiquidity > 0
                        uint256 scoreProbed = _feeTierScore(oracleDataProbed.avLiquidity, uniswapFeeTierProbed);

                        if (scoreProbed > score) {
                            // If the probed fee tier is better than the current one, then we increase its cardinality if necessary
                            if (oracleDataProbed.cardinalityToIncrease > 0) {
                                oracleDataProbed.uniswapPool.increaseObservationCardinalityNext(
                                    oracleDataProbed.cardinalityToIncrease
                                );
                            } else if (oracleDataProbed.period >= TWAP_DURATION) {
                                // If the probed fee tier is better than the current one AND the cardinality is sufficient, switch to the probed tier
                                oracleState.indexFeeTier = oracleState.indexFeeTierProbeNext;
                                emit OracleFeeTierChanged(oracleState.uniswapFeeTier.fee, uniswapFeeTierProbed.fee);
                                oracleState.uniswapFeeTier = uniswapFeeTierProbed;
                                uniswapPoolAddress = address(oracleDataProbed.uniswapPool);
                            }
                        } else {
                            // If the current tier is still better, then we increase its cardinality if necessary
                            checkCardinalityCurrentFeeTier = true;
                        }
                    } else {
                        // If the probed tier is not even initialized, then we increase the cardinality of the current tier if necessary
                        checkCardinalityCurrentFeeTier = true;
                    }
                } else {
                    checkCardinalityCurrentFeeTier = true;
                }

                if (checkCardinalityCurrentFeeTier && oracleData.cardinalityToIncrease > 0) {
                    // We increase the cardinality of the current tier if necessary
                    oracleData.uniswapPool.increaseObservationCardinalityNext(oracleData.cardinalityToIncrease);
                }

                // Point to the next fee tier to probe
                uint numUniswapFeeTiers = 4 + uint8(_uniswapExtraFeeTiers); // Safe because _uniswapExtraFeeTiers's length at most is 5
                oracleState.indexFeeTierProbeNext = (oracleState.indexFeeTierProbeNext + 1) % uint8(numUniswapFeeTiers);

                // Update timestamp
                oracleState.timeStampFeeTier = uint40(block.timestamp);
            }

            // Save new oracle _state to storage
            _state[token0][token1] = oracleState;
        } else {
            uniswapPoolAddress = address(_getUniswapPool(token0, token1, oracleState.uniswapFeeTier.fee));
        }

        // Invert price if necessary
        tickPriceX42 = collateralToken == token1 ? -oracleState.tickPriceX42 : oracleState.tickPriceX42; // Safe to take negative because |tickPriceX42| ≤ MAX_TICK_X42
    }

    /*////////////////////////////////////////////////////////////////
                        PRIVATE FUNCTIONS
    ////////////////////////////////////////////////////////////////*/

    function _uniswapOracleData(
        address token0,
        address token1,
        uint24 fee
    ) private view returns (UniswapOracleData memory oracleData) {
        // Retrieve Uniswap pool
        oracleData.uniswapPool = _getUniswapPool(token0, token1, fee);

        // If pool does not exist, no-op, return all parameters 0.
        if (address(oracleData.uniswapPool).code.length == 0) return oracleData;

        // Retrieve oracle info from Uniswap v3
        uint32[] memory interval = new uint32[](2);
        interval[0] = uint32(TWAP_DURATION);
        interval[1] = 0;
        int56[] memory tickCumulatives;
        uint160[] memory secondsPerLiquidityCumulatives;

        try oracleData.uniswapPool.observe(interval) returns (
            int56[] memory tickCumulatives_,
            uint160[] memory secondsPerLiquidityCumulatives_
        ) {
            tickCumulatives = tickCumulatives_;
            secondsPerLiquidityCumulatives = secondsPerLiquidityCumulatives_;
        } catch Error(string memory reason) {
            // If pool is not initialized (or other unexpected errors), no-op, return all parameters 0.
            if (keccak256(bytes(reason)) != keccak256(bytes("OLD"))) return oracleData;

            /* 
                If Uniswap v3 Pool reverts with the message 'OLD' then
                ...the cardinality of Uniswap v3 oracle is insufficient
                ...or the TWAP storage is not yet filled with price data
             */

            /** About Uni v3 Cardinality
                "cardinalityNow" is the current oracle array length with populated price information
                "cardinalityNext" is the future cardinality
                The oracle array is updated circularly.
                The array's cardinality is not bumped to cardinalityNext until the last element in the array
                (of length cardinalityNow) is updated just before a mint/swap/burn.
             */
            (, , uint16 observationIndex, uint16 cardinalityNow, uint16 cardinalityNext, , ) = oracleData
                .uniswapPool
                .slot0();

            // Get oracle data at the current timestamp
            (tickCumulatives, secondsPerLiquidityCumulatives) = oracleData.uniswapPool.observe(new uint32[](1)); // It should never fail
            int56 tickCumulative_ = tickCumulatives[0];
            uint160 secondsPerLiquidityCumulative_ = secondsPerLiquidityCumulatives[0];

            // Expand arrays to two slots
            tickCumulatives = new int56[](2);
            secondsPerLiquidityCumulatives = new uint160[](2);
            tickCumulatives[1] = tickCumulative_;
            secondsPerLiquidityCumulatives[1] = secondsPerLiquidityCumulative_;

            // Get oracle data for the oldest observation possible
            uint32 blockTimestampOldest;
            {
                bool initialized;
                if (cardinalityNow > 1) {
                    // If cardinalityNow is 1, oldest (and newest) observations are at index 0.
                    (blockTimestampOldest, tickCumulative_, secondsPerLiquidityCumulative_, initialized) = oracleData
                        .uniswapPool
                        .observations((observationIndex + 1) % cardinalityNow);
                    // Safe from OF because observationIndex < cardinalityNow by https://github.com/Uniswap/v3-core/blob/d8b1c635c275d2a9450bd6a78f3fa2484fef73eb/contracts/libraries/Oracle.sol#L99
                }

                /** The next index might not be populated if the cardinality is in the process of increasing.
                    In this case the oldest observation is always in index 0.
                    Observation at index 0 is always initialized.
                */
                if (!initialized) {
                    (blockTimestampOldest, tickCumulative_, secondsPerLiquidityCumulative_, ) = oracleData
                        .uniswapPool
                        .observations(0);
                    cardinalityNow = observationIndex + 1;
                    // The 1st element of observations is always initialized
                }
            }

            // Current TWAP duration
            interval[0] = uint32(block.timestamp - blockTimestampOldest); // Safe because blockTimestampOldest < block.timestamp

            // This can only occur if the fee tier has cardinalityNow 1
            if (interval[0] == 0) {
                // We get the instant liquidity because TWAP liquidity is not available
                oracleData.avLiquidity = oracleData.uniswapPool.liquidity();
                if (oracleData.avLiquidity == 0) oracleData.avLiquidity = 1;
                oracleData.period = 1;
                oracleData.cardinalityToIncrease = 1 + CARDINALITY_DELTA; // No OF because it's a constant
                return oracleData;
            }

            /**
             * Check if cardinality must increase,
             * ...and if so, increment by CARDINALITY_DELTA.
             */
            uint256 cardinalityNeeded = (uint256(cardinalityNow) * TWAP_DURATION - 1) / interval[0] + 1; // Estimate necessary length of the oracle
            if (cardinalityNeeded > cardinalityNext) {
                oracleData.cardinalityToIncrease = cardinalityNext + CARDINALITY_DELTA;
                // OF doesn't matter because it means cardinalityNext is already very close to 2^16
            }

            tickCumulatives[0] = tickCumulative_;
            secondsPerLiquidityCumulatives[0] = secondsPerLiquidityCumulative_;
        }

        // Compute average liquidity which is >=1
        oracleData.avLiquidity = uint136( // Safe conversion because diffSecondsPerLiquidityCumulatives is equal to or greater than interval[0]
            (uint160(interval[0]) << 128) / (secondsPerLiquidityCumulatives[1] - secondsPerLiquidityCumulatives[0])
        ); // It will not divide by 0 because liquidity cumulatives always increase

        // Aggregated price from Uniswap v3 are given as token1/token0
        oracleData.aggPriceTick = tickCumulatives[1] - tickCumulatives[0];

        // Duration of the observation
        oracleData.period = interval[0];
    }

    function _updatePrice(
        SirStructs.OracleState memory oracleState,
        UniswapOracleData memory oracleData
    ) internal view returns (bool truncated) {
        // Compute price (buy operating with int256 we do not need to check for of/uf)
        int256 tickPriceX42 = (int256(oracleData.aggPriceTick) << 42); // Safe because uint56 << 42 < 2^256-1

        /** When period==0, aggPriceTick is in fact the instantaneous price
            When period==1, dividing by period does not change tickPriceX42
        */
        if (oracleData.period > 1) tickPriceX42 /= int256(uint256(oracleData.period));

        if (oracleState.timeStampPrice == 0) oracleState.tickPriceX42 = int64(tickPriceX42);
        else {
            // Truncate price if necessary
            int256 tickMaxIncrement = int256((block.timestamp - oracleState.timeStampPrice)) * MAX_TICK_INC_PER_SEC;
            if (tickPriceX42 > int256(oracleState.tickPriceX42) + tickMaxIncrement) {
                oracleState.tickPriceX42 += int64(tickMaxIncrement); // Cannot OF cuz it is less than tickPriceX42
                truncated = true;
            } else if (tickPriceX42 + tickMaxIncrement < int256(oracleState.tickPriceX42)) {
                oracleState.tickPriceX42 -= int64(tickMaxIncrement); // Cannot UF cuz it is greater than tickPriceX42
                truncated = true;
            } else oracleState.tickPriceX42 = int64(tickPriceX42);
        }
    }

    function _uniswapFeeTier(
        uint8 indexFeeTier
    ) internal view returns (SirStructs.UniswapFeeTier memory uniswapFeeTier) {
        if (indexFeeTier == 0) return SirStructs.UniswapFeeTier(100, 1);
        if (indexFeeTier == 1) return SirStructs.UniswapFeeTier(500, 10);
        if (indexFeeTier == 2) return SirStructs.UniswapFeeTier(3000, 60);
        if (indexFeeTier == 3) return SirStructs.UniswapFeeTier(10000, 200);
        else {
            // Extra fee tiers
            uint uniswapExtraFeeTiers_ = _uniswapExtraFeeTiers;
            uint numUniswapExtraFeeTiers = uint(uint8(uniswapExtraFeeTiers_));
            if (indexFeeTier >= numUniswapExtraFeeTiers + 4) revert UniswapFeeTierIndexOutOfBounds(); // Cannot OF because numUniswapExtraFeeTiers is max 5

            uniswapExtraFeeTiers_ >>= 8 + 48 * (indexFeeTier - 4);
            return SirStructs.UniswapFeeTier(uint24(uniswapExtraFeeTiers_), int24(uint24(uniswapExtraFeeTiers_ >> 24)));
        }
    }

    /**
        The tick TVL (liquidity in Uniswap v3) is a good criteria for selecting the best pool.
        We use the time-weighted tickTVL to score fee tiers.
        However, fee tiers with small weighting period are more susceptible to manipulation.
        Thus, instead we weight the time-weighted tickTVL by the weighting period:
            twTickTVL * period * feeTier = avLiquidity
        
        However, it may be a good idea to weight the score by the fee tier, because it is harder to move the
        price of a pool with higher fee tier.

     */
    function _feeTierScore(
        uint256 aggOrAvLiquidity, // 0 < aggOrAvLiquidity < 2^136
        SirStructs.UniswapFeeTier memory uniswapFeeTier
    ) private pure returns (uint256) {
        // The score is rounded up to ensure it is always >1
        // Safe because (aggOrAvLiquidity*fee)<<72 < 2^(136+24+72) = 2^228
        return (((aggOrAvLiquidity * uniswapFeeTier.fee) << 72) - 1) / uint24(uniswapFeeTier.tickSpacing) + 1;
    }

    function _getUniswapPool(address tokenA, address tokenB, uint24 fee) private view returns (IUniswapV3Pool) {
        return
            IUniswapV3Pool(
                UniswapPoolAddress.computeAddress(UNISWAPV3_FACTORY, UniswapPoolAddress.getPoolKey(tokenA, tokenB, fee))
            );
    }

    function _orderTokens(address tokenA, address tokenB) private pure returns (address, address) {
        if (tokenA > tokenB) (tokenA, tokenB) = (tokenB, tokenA);
        return (tokenA, tokenB);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Contracts
import {SystemConstants} from "./libraries/SystemConstants.sol";
import {Contributors} from "./libraries/Contributors.sol";
import {Staker} from "./Staker.sol";
import {SystemControlAccess} from "./SystemControlAccess.sol";

/**
 * @notice The SIR ERC-20 token is managed between this contractand the Staker contract.
 * In particular this contract handles the external functions for minting SIR by contributors,
 * who have a fixed allocation for the first 3 years, and LPers.
 */
contract SIR is Staker, SystemControlAccess {
    event RewardsClaimed(address indexed contributor, uint256 indexed vaultId, uint80 rewards);

    mapping(address => uint40) internal timestampLastMint;

    bool private _mintingAllowed = true;

    constructor(address weth, address systemControl) Staker(weth) SystemControlAccess(systemControl) {}

    /*////////////////////////////////////////////////////////////////
                        READ-ONLY FUNCTIONS
    ////////////////////////////////////////////////////////////////*/

    /**
     * @notice Returns unclaimed SIR rewards of a contributor.
     * @param contributor whose unclaimed SIR rewards are to be checked.
     * @return unclaimed SIR rewards of a contributor.
     */
    function contributorUnclaimedSIR(address contributor) public view returns (uint80) {
        unchecked {
            // Get the contributor's allocation
            uint256 allocation = Contributors.getAllocation(contributor);

            // No allocation, no rewards
            if (allocation == 0) return 0;

            // First issuance date
            uint40 timestampIssuanceStart = vault.TIMESTAMP_ISSUANCE_START();

            // Last issuance date
            uint256 timestampIssuanceEnd = timestampIssuanceStart + SystemConstants.THREE_YEARS;

            // Get last mint time stamp
            uint256 timestampLastMint_ = timestampLastMint[contributor];

            // Contributor has already claimed all rewards
            if (timestampLastMint_ >= timestampIssuanceEnd) return 0;

            // If timestampLastMint[contributor] had never been set
            if (timestampLastMint_ == 0) timestampLastMint_ = timestampIssuanceStart;

            // Calculate the contributor's issuance
            uint256 issuance = (allocation * (SystemConstants.ISSUANCE - SystemConstants.LP_ISSUANCE_FIRST_3_YEARS)) /
                type(uint56).max;

            // Update unclaimed rewards
            uint256 timestampNow = block.timestamp >= timestampIssuanceEnd ? timestampIssuanceEnd : block.timestamp;

            // Return unclaimed rewards
            return uint80(issuance * (timestampNow - timestampLastMint_));
        }
    }

    /**
     * @notice Returns the total SIR issuance rate [sir/s].
     */
    function ISSUANCE_RATE() external pure returns (uint72) {
        return SystemConstants.ISSUANCE;
    }

    /**
     * @notice Returns the SIR issuance rate [sir/s] to LPers for the first 3 years.
     */
    function LP_ISSUANCE_FIRST_3_YEARS() external pure returns (uint72) {
        return SystemConstants.LP_ISSUANCE_FIRST_3_YEARS;
    }

    /*////////////////////////////////////////////////////////////////
                            WRITE FUNCTIONS
    ////////////////////////////////////////////////////////////////*/

    /**
     * @notice Mints SIR rewards for a contributor.
     * @return rewards in SIR received by a contributor.
     */
    function contributorMint() public returns (uint80 rewards) {
        require(_mintingAllowed);

        // Get contributor's unclaimed rewards
        rewards = contributorUnclaimedSIR(msg.sender);

        // Mint if there are any unclaimed rewards
        require(rewards > 0);
        _mint(msg.sender, rewards);

        // Update time stamp
        timestampLastMint[msg.sender] = uint40(block.timestamp);
    }

    /**
     * @notice Mints SIR rewards for an LPer.
     * @param vaultId of the vault for which the LPer wants to claim SIR.
     * @return rewards in SIR received by an LPer.
     */
    function lPerMint(uint256 vaultId) public returns (uint80 rewards) {
        require(_mintingAllowed);

        // Get LPer issuance parameters
        rewards = vault.claimSIR(vaultId, msg.sender);

        // Mint if there are any unclaimed rewards
        require(rewards > 0);
        _mint(msg.sender, rewards);

        emit RewardsClaimed(msg.sender, vaultId, rewards);
    }

    /**
     * @notice Auxiliary function for minting SIR rewards for a contributor and staking them immediately in one call.
     */
    function contributorMintAndStake() external returns (uint80 rewards) {
        // Get unclaimed rewards
        rewards = contributorMint();

        // Stake them immediately
        stake(rewards);
    }

    /**
     * @notice Auxiliary function for minting SIR rewards for an LPer and staking them immediately in one call.
     */
    function lPerMintAndStake(uint256 vaultId) external returns (uint80 rewards) {
        // Get unclaimed rewards
        rewards = lPerMint(vaultId);

        // Stake them immediately
        stake(rewards);
    }

    /*////////////////////////////////////////////////////////////////
                        SYSTEM CONTROL FUNCTIONS
    ////////////////////////////////////////////////////////////////*/

    /**
     * @dev This function can only be called by the SystemControl contract.
     */
    function allowMinting(bool mintingOfSIRHalted_) external onlySystemControl {
        _mintingAllowed = mintingOfSIRHalted_;
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {SystemConstants} from "./libraries/SystemConstants.sol";
import {Vault} from "./Vault.sol";
import {IWETH9} from "./interfaces/IWETH9.sol";
import {SirStructs} from "./libraries/SirStructs.sol";
import {UD60x18, uEXP2_MAX_INPUT, uUNIT, convert} from "prb/UD60x18.sol";
import {exp2} from "prb/Common.sol";

/**
 * @notice The Staker contract handles mostly the staking of SIR tokens, and the token auctions.\n
 * Collection of fees from the vault can be triggered by anyone and also start an auction to convert them to ETH.\n
 * Stakers only receive dividends in the form of ETH.
 * @dev Mod of Solmate's ERC20.
 */
contract Staker {
    error NewAuctionCannotStartYet();
    error NoAuctionLot();
    error NoFeesCollected();
    error AuctionIsNotOver();
    error NoAuction();
    error BidTooLow();
    error InvalidSigner();
    error PermitDeadlineExpired();
    error NotTheAuctionWinner();
    error InsufficientUnlockedStake();

    event AuctionStarted(address indexed token, uint256 feesToBeAuctioned);
    event AuctionedTokensSentToWinner(
        address indexed winner,
        address indexed beneficiary,
        address indexed token,
        uint256 reward
    );
    event DividendsPaid(uint96 amountETH, uint80 amountStakedSIR);
    event BidReceived(address indexed bidder, address indexed token, uint96 previousBid, uint96 newBid);
    event DividendsClaimed(address indexed staker, uint96 amount);

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
    event Staked(address indexed staker, uint256 amount);
    event Unstaked(address indexed staker, uint256 amount);

    address immutable deployer; // Just used to make sure function initialize() is not called by anyone else.
    IWETH9 private immutable _WETH;
    Vault internal vault;

    string public constant name = "Synthetics Implemented Right";
    string public constant symbol = "SIR";
    uint8 public immutable decimals = SystemConstants.SIR_DECIMALS;

    struct Balance {
        uint80 balanceOfSIR; // Amount of transferable SIR
        uint96 unclaimedETH; // Amount of ETH owed to the staker(s)
    }

    SirStructs.StakingParams internal stakingParams; // Total staked SIR and cumulative ETH per SIR
    Balance private _supply; // Total unstaked SIR and ETH owed to the stakers
    uint96 internal totalWinningBids; // Total amount of WETH deposited by the bidders
    bool private _initialized;

    mapping(address token => SirStructs.Auction) internal _auctions;
    mapping(address user => Balance) internal balances;
    mapping(address user => SirStructs.StakerParams) internal _stakersParams;

    mapping(address => mapping(address => uint256)) public allowance;

    uint256 internal immutable INITIAL_CHAIN_ID;
    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;

    mapping(address => uint256) public nonces;

    constructor(address weth) {
        _WETH = IWETH9(payable(weth));

        deployer = msg.sender;

        INITIAL_CHAIN_ID = block.chainid;
        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();
    }

    /// @dev Necessary so the contract can unwrap WETH to ETH
    receive() external payable {}

    /**
     * @dev Initializes the contract with the vault contract address.
     */
    function initialize(address vault_) external {
        require(!_initialized && msg.sender == deployer);

        vault = Vault(vault_);

        _initialized = true;
    }

    /*//////////////////////////////////////////////////////////////
                            CUSTOM ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Returns transferable (unstaked) SIR.
     */
    function balanceOf(address account) external view returns (uint256) {
        return balances[account].balanceOfSIR;
    }

    /**
     * @notice Returns staked SIR + transferable (unstaked) SIR.
     */
    function totalBalanceOf(address account) external view returns (uint256) {
        return _stakersParams[account].stake + balances[account].balanceOfSIR;
    }

    /**
     * @notice Return supply of transferable (unstaked) SIR only.
     */
    function supply() external view returns (uint256) {
        return _supply.balanceOfSIR;
    }

    /**
     * @notice Return supply of staked SIR + transferable (unstaked) SIR
     */
    function totalSupply() external view returns (uint256) {
        return stakingParams.stake + _supply.balanceOfSIR;
    }

    /**
     * @notice Return supply as if all tokens were in circulation
     * (i.e., unclaimed SIR from LPers and contributors, staked SIR and unstaked SIR)
     */
    function maxTotalSupply() external view returns (uint256) {
        return SystemConstants.ISSUANCE * (block.timestamp - vault.TIMESTAMP_ISSUANCE_START());
    }

    /*//////////////////////////////////////////////////////////////
                               ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Sets the amount of tokens that `spender` will be allowed to spend on behalf of `owner`.
     */
    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    /**
     * @notice Transfers `amount` tokens to `to`.
     */
    function transfer(address to, uint256 amount) public returns (bool) {
        unchecked {
            uint80 balance = balances[msg.sender].balanceOfSIR;
            require(amount <= balance);
            balances[msg.sender].balanceOfSIR = balance - uint80(amount);

            balances[to].balanceOfSIR += uint80(amount);

            emit Transfer(msg.sender, to, amount);

            return true;
        }
    }

    /**
     * @notice Transfers `amount` tokens from `from` to `to`.
     */
    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.
        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;

        unchecked {
            uint80 balance = balances[from].balanceOfSIR;
            require(amount <= balance);
            balances[from].balanceOfSIR = balance - uint80(amount);

            balances[to].balanceOfSIR += uint80(amount);

            emit Transfer(from, to, amount);

            return true;
        }
    }

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        if (deadline < block.timestamp) revert PermitDeadlineExpired();

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

            if (recoveredAddress == address(0) || recoveredAddress != owner) revert InvalidSigner();

            allowance[recoveredAddress][spender] = value;
        }

        emit Approval(owner, spender, value);
    }

    function DOMAIN_SEPARATOR() public view returns (bytes32) {
        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();
    }

    function computeDomainSeparator() internal view returns (bytes32) {
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

    function _mint(address to, uint80 amount) internal {
        unchecked {
            _supply.balanceOfSIR += uint80(amount);
            balances[to].balanceOfSIR += uint80(amount);

            emit Transfer(address(0), to, amount);
        }
    }

    /*////////////////////////////////////////////////////////////////
                            STAKING FUNCTIONS 
    ////////////////////////////////////////////////////////////////*/

    /**
     * @notice Stakes SIR tokens. Tokens can be unstaked at any time.
     * @param amount of SIR to stake.
     */
    function stake(uint80 amount) public {
        Balance memory balance = balances[msg.sender];
        SirStructs.StakingParams memory stakingParams_ = stakingParams;
        SirStructs.StakerParams memory stakerParams = getStakerParams(msg.sender);

        uint80 newBalanceOfSIR = balance.balanceOfSIR - amount;

        unchecked {
            // Update balance
            balances[msg.sender] = Balance(newBalanceOfSIR, _dividends(balance, stakingParams_, stakerParams));

            // Update staker info
            stakerParams.stake += amount;
            stakerParams.lockedStake += amount;
            stakerParams.cumulativeETHPerSIRx80 = stakingParams_.cumulativeETHPerSIRx80;
            _stakersParams[msg.sender] = stakerParams;

            // Update _supply
            _supply.balanceOfSIR -= amount;

            // Update total stake
            stakingParams.stake = stakingParams_.stake + amount;

            emit Staked(msg.sender, amount);
        }
    }

    /**
     * @notice Unstakes SIR tokens.
     * @param amount of SIR to unstake.
     */
    function unstake(uint80 amount) public {
        unchecked {
            Balance memory balance = balances[msg.sender];
            SirStructs.StakingParams memory stakingParams_ = stakingParams;
            SirStructs.StakerParams memory stakerParams = getStakerParams(msg.sender);

            // Check user has enough unlocked SIR to unstake
            if (amount > stakerParams.stake - stakerParams.lockedStake) revert InsufficientUnlockedStake();

            // Update balance of SIR and ETH dividends
            balances[msg.sender] = Balance(
                balance.balanceOfSIR + amount,
                _dividends(balance, stakingParams_, stakerParams)
            );

            // Update staker info
            stakerParams.stake -= amount;
            stakerParams.cumulativeETHPerSIRx80 = stakingParams_.cumulativeETHPerSIRx80;
            _stakersParams[msg.sender] = stakerParams;

            // Update _supply of SIR
            _supply.balanceOfSIR += amount;

            // Update total stake
            stakingParams.stake = stakingParams_.stake - amount;

            emit Unstaked(msg.sender, amount);
        }
    }

    /**
     * @notice Claim ETH dividends. You can still claim even if you already unstaked you SIR.
     * @return dividends_ of ETH received.
     */
    function claim() public returns (uint96 dividends_) {
        unchecked {
            SirStructs.StakingParams memory stakingParams_ = stakingParams;
            dividends_ = _dividends(balances[msg.sender], stakingParams_, _stakersParams[msg.sender]);

            // Null the unclaimed dividends
            balances[msg.sender].unclaimedETH = 0;

            // Update staker info
            _stakersParams[msg.sender].cumulativeETHPerSIRx80 = stakingParams_.cumulativeETHPerSIRx80;

            // Update ETH _supply in the contract
            _supply.unclaimedETH -= dividends_;

            // Emit event
            emit DividendsClaimed(msg.sender, dividends_);

            // Transfer dividends
            (bool success, bytes memory data) = msg.sender.call{value: dividends_}("");
            if (!success) revert(string(data));
        }
    }

    /**
     * @notice Convenient function for unstaking SIR and claim ETH dividens in one call.
     * @param amount of SIR to unstake.
     * @return dividends_ received in ETH.
     */
    function unstakeAndClaim(uint80 amount) external returns (uint96 dividends_) {
        unstake(amount);
        return claim();
    }

    /**
     * @notice Returns the amount of unclaimed ETH for a staker.
     * @return amount of unclaimed ETH
     */
    function unclaimedDividends(address staker) external view returns (uint96) {
        return _dividends(balances[staker], stakingParams, _stakersParams[staker]);
    }

    function _dividends(
        Balance memory balance,
        SirStructs.StakingParams memory stakingParams_,
        SirStructs.StakerParams memory stakerParams
    ) private pure returns (uint96 dividends_) {
        unchecked {
            dividends_ = balance.unclaimedETH;
            if (stakerParams.stake > 0) {
                dividends_ += uint96( // Safe to cast to uint96 because _supply.unclaimedETH is uint96
                    (uint256(stakingParams_.cumulativeETHPerSIRx80 - stakerParams.cumulativeETHPerSIRx80) *
                        stakerParams.stake) >> 80
                );
            }
        }
    }

    /*////////////////////////////////////////////////////////////////
                        DIVIDEND PAYING FUNCTIONS
    ////////////////////////////////////////////////////////////////*/

    /**
     * @notice Bid on an auction.
     * @param token of the auction.
     * @param amount of WETH to bid.
     */
    function bid(address token, uint96 amount) external {
        unchecked {
            SirStructs.Auction memory auction = _auctions[token];

            // Unchecked because time stamps cannot overflow
            if (block.timestamp >= auction.startTime + SystemConstants.AUCTION_DURATION) revert NoAuction();

            // Transfer the bid to the contract
            _WETH.transferFrom(msg.sender, address(this), amount);

            if (msg.sender == auction.bidder) {
                // If the bidder is the current winner, we just increase the bid
                totalWinningBids += amount;
                amount += auction.bid;
            } else {
                // Return the previous bid to the previous bidder
                totalWinningBids += amount - auction.bid;
                _WETH.transfer(auction.bidder, auction.bid);
            }

            /** If the bidder is not the current winner, we check if the bid is higher.
                Null bids are no possible because auction.bid >=0 always.
             */
            if (amount <= auction.bid) revert BidTooLow();

            // Update bidder & bid
            _auctions[token] = SirStructs.Auction({bidder: msg.sender, bid: amount, startTime: auction.startTime});

            emit BidReceived(msg.sender, token, auction.bid, amount);
        }
    }

    /**
     * @notice Collect `token` fees and starts an auction.
     * @param token of the auction.
     */
    function collectFeesAndStartAuction(address token) external returns (uint256 totalFees) {
        unchecked {
            uint96 totalWinningBids_ = totalWinningBids;

            // Because ETH is the dividend paying token, we do not need to start an auction if fees are in WETH.
            if (token != address(_WETH)) {
                SirStructs.Auction memory auction = _auctions[token];

                uint40 newStartTime = auction.startTime + SystemConstants.AUCTION_COOLDOWN;
                if (block.timestamp < newStartTime) revert NewAuctionCannotStartYet();

                // Start a new auction
                _auctions[token] = SirStructs.Auction({
                    bidder: address(0),
                    bid: 0,
                    startTime: uint40(block.timestamp) // This automatically aborts any reentrancy attack
                });

                // Last bid is converted to dividends
                totalWinningBids_ -= auction.bid;
                totalWinningBids = totalWinningBids_;

                // Distribute dividends collected from the previous auction if there were any
                _distributeDividends(totalWinningBids_);

                // The winner of the previous auction is paid after all state changes have been made to avoid reentrancy attacks.
                _payAuctionWinner(token, auction, address(0));

                /** Retrieve fees from the vault to be auctioned next.
                    This function must come after _payAuctionWinner to avoid paying the previous auction winner twice.
                */
                totalFees = vault.withdrawFees(token);

                // Do not start a new auction if there are no fees to auction
                if (totalFees == 0) revert NoFeesCollected();

                // Emit event with the new auction's details
                emit AuctionStarted(token, totalFees);
            } else {
                //  Retrieve WETH from the vault to be distributed as dividends.
                totalFees = vault.withdrawFees(token);

                // Distribute WETH as ETH dividends
                bool noDividends = _distributeDividends(totalWinningBids_);

                //  Revert if there is no (W)ETH be to distributed.
                if (noDividends) revert NoFeesCollected();
            }
        }
    }

    /**
     * @notice Winner of the auction can call this function to get the auction lot.
     * If the transfer of the auction lot fails, the function reverts and the dividends (WETH) are not distributed, allowing the bidder to try again later.
     * @param token of the auction lot
     * @param beneficiary address of the auction lot. If it is 0, the auction lot is sent to the bidder address.
     */
    function getAuctionLot(address token, address beneficiary) external {
        SirStructs.Auction memory auction = _auctions[token];
        if (block.timestamp < auction.startTime + SystemConstants.AUCTION_DURATION) revert AuctionIsNotOver();
        if (msg.sender != auction.bidder) revert NotTheAuctionWinner();

        // Update auction
        _auctions[token].bid = 0;

        // Last bid is converted to dividends
        uint96 totalWinningBids_ = totalWinningBids - auction.bid;
        totalWinningBids = totalWinningBids_;

        // Distribute dividends.
        _distributeDividends(totalWinningBids_);

        /** The auction winner is paid last because
            it makes external calls that could be used for reentrancy attacks. 
        */
        if (!_payAuctionWinner(token, auction, beneficiary)) revert NoAuctionLot();
    }

    function _distributeDividends(uint96 totalWinningBids_) private returns (bool noDividends) {
        unchecked {
            // Any excess WETH in the contract will be distributed.
            uint256 excessWETH = _WETH.balanceOf(address(this)) - totalWinningBids_;

            // Any excess ETH from when stake was 0, or from donations
            uint96 unclaimedETH = _supply.unclaimedETH;
            uint256 excessETH = address(this).balance - unclaimedETH;

            // Compute dividends
            uint256 dividends_ = excessWETH + excessETH;
            if (dividends_ == 0) return true;

            // Unwrap WETH dividends to ETH
            _WETH.withdraw(excessWETH);

            SirStructs.StakingParams memory stakingParams_ = stakingParams;
            if (stakingParams_.stake == 0) return true;

            // Update cumulativeETHPerSIRx80
            stakingParams.cumulativeETHPerSIRx80 =
                stakingParams_.cumulativeETHPerSIRx80 +
                uint176((dividends_ << 80) / stakingParams_.stake);

            // Update _supply
            _supply.unclaimedETH = unclaimedETH + uint96(dividends_);

            // Dividends are considered paid after unclaimedETH is updated
            emit DividendsPaid(uint96(dividends_), stakingParams_.stake);
        }
    }

    /// @dev This function never reverts, instead it returns false.
    function _payAuctionWinner(
        address token,
        SirStructs.Auction memory auction,
        address beneficiary
    ) private returns (bool success) {
        // Only pay if there is any bid
        if (auction.bid == 0) return false;

        /** Obtain reward amount
            Low-level call to avoid revert if the ERC20 token has some problems.
         */
        bytes memory data;
        (success, data) = token.call(abi.encodeWithSignature("balanceOf(address)", address(this)));

        // balanceOf failed and we cannot continue
        if (!success || data.length != 32) return false;

        // Prize is 0, so the claim is successful but without a transfer
        uint256 tokenAmount = abi.decode(data, (uint256));
        if (tokenAmount == 0) return true;

        /** Pay the winner if tokenAmount > 0
            Low-level call to avoid revert in case the destination has been banned from receiving tokens.
         */
        if (beneficiary == address(0)) beneficiary = auction.bidder;
        (success, data) = token.call(abi.encodeWithSignature("transfer(address,uint256)", beneficiary, tokenAmount));

        /** By the ERC20 standard, the transfer may go through without reverting (success == true),
            but if it returns a boolean that is false, the transfer actually failed.
         */
        if (!success || (data.length > 0 && !abi.decode(data, (bool)))) return false;

        emit AuctionedTokensSentToWinner(auction.bidder, beneficiary, token, tokenAmount);
        return true;
    }

    /**
     * @dev Returns the staking parameters of a staker at the present time.\n
     * This function is responsible for unlocking stake and updating tsLastUpdate in stakerParams.
     */
    function getStakerParams(address staker) internal view returns (SirStructs.StakerParams memory stakerParams) {
        unchecked {
            stakerParams = _stakersParams[staker];

            uint256 elapsedTime = block.timestamp - stakerParams.tsLastUpdate;
            stakerParams.tsLastUpdate = uint40(block.timestamp);

            /** If no time has passed since the stake parameters were last updated
                or there is no locked stake, then locked stake remains unchanged.
             */
            if (elapsedTime == 0 || stakerParams.lockedStake == 0) return stakerParams;

            /** Compute (t-t0)/T where
                    t-t0 is the elapsed time since last update
                    and T is period of time it takes for the locked stake to halve
             */
            UD60x18 exponent = UD60x18.wrap(elapsedTime * uUNIT).div( // Cannot overflow because 2^40 < 10^60
                    UD60x18.wrap(SystemConstants.HALVING_PERIOD * uUNIT)
                );

            // Compute 2^[(t-t0)/T]
            uint256 exponentUint = exponent.unwrap();
            if (exponentUint > uEXP2_MAX_INPUT) {
                // Too large, so we just round it to 0
                stakerParams.lockedStake = 0;
            } else {
                // Convert x to the 192.64-bit fixed-point format.
                uint256 exponent_192x64 = (exponentUint << 64) / uUNIT;

                // decay ≥ 1 always because exponent_192x64 is positive
                UD60x18 decay = UD60x18.wrap(exp2(exponent_192x64));

                /** Converting lockedStake to UD60x18 does not overflow because 2^80 < 10^60
                    Computes lockedStake/2^[(t-t0)/T]
                 */
                stakerParams.lockedStake = uint80(convert(UD60x18.wrap(stakerParams.lockedStake * uUNIT).div(decay)));
            }
        }
    }

    /*////////////////////////////////////////////////////////////////
                                GETTERS
    ////////////////////////////////////////////////////////////////*/

    /**
     * @notice Returns the auction for `token`.
     */
    function auctions(address token) external view returns (SirStructs.Auction memory) {
        return _auctions[token];
    }

    /**
     * @notice Returns the unlocked and locked stake of `staker`.
     */
    function stakeOf(address staker) external view returns (uint80 unlockedStake, uint80 lockedStake) {
        SirStructs.StakerParams memory stakerParams = getStakerParams(staker);

        return (stakerParams.stake - stakerParams.lockedStake, stakerParams.lockedStake);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import {SystemConstants} from "./libraries/SystemConstants.sol";

contract SystemControlAccess {
    address internal immutable SYSTEM_CONTROL;

    modifier onlySystemControl() {
        require(msg.sender == SYSTEM_CONTROL);
        _;
    }

    constructor(address systemControl) {
        SYSTEM_CONTROL = systemControl;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Contracts
import {SirStructs} from "./libraries/SirStructs.sol";
import {SystemControlAccess} from "./SystemControlAccess.sol";
import {SystemConstants} from "./libraries/SystemConstants.sol";

/**
 * @dev Contract handling the few protocol-wide parameters,
 * and some of the functions for keeping track of the SIR rewards allocated to LPers.
 */
abstract contract SystemState is SystemControlAccess {
    event VaultNewTax(uint48 indexed vault, uint8 tax, uint16 cumulativeTax);

    struct LPerIssuanceParams {
        uint176 cumulativeSIRPerTEAx96; // Q80.96, cumulative SIR minted by an LPer per unit of TEA
        uint80 unclaimedRewards; // SIR owed to the LPer. 80 bits is enough to store the balance even if all SIR issued in +1000 years went to a single LPer
    }

    struct LPersBalances {
        address lper0;
        uint256 balance0;
        address lper1;
        uint256 balance1;
    }

    uint40 public immutable TIMESTAMP_ISSUANCE_START;

    address internal immutable _SIR;

    mapping(uint256 vaultId => SirStructs.VaultIssuanceParams) internal vaultIssuanceParams;
    mapping(uint256 vaultId => mapping(address => LPerIssuanceParams)) private _lpersIssuances;

    SirStructs.SystemParameters internal _systemParams;

    constructor(address systemControl, address sir_) SystemControlAccess(systemControl) {
        TIMESTAMP_ISSUANCE_START = uint40(block.timestamp);

        _SIR = sir_;

        /*  Apes pay fees to the gentlemen for their liquidity when minting or burning APE. They are paid twice to encourage LPers to
            continue to provide liqduidity after a mint of APE.

            Gentlemen pay a fee when minting TEA given to the protocol. Protocol will never touch these fees and act as its own pool of liquidity.
            These fee is very important because it mitigate an LP sandwich attack. If there were no fees charge to the gentlemen, when an ape mints
            (or burns) APE, the attacker could mint before the ape and burn after the ape, earning the fees risk-free.
         */
        _systemParams = SirStructs.SystemParameters({
            baseFee: SirStructs.FeeStructure({fee: 3000, feeNew: 0, timestampUpdate: 0}), // At 1.5 leverage, apes would pay 24% of their deposit as upfront fee.
            lpFee: SirStructs.FeeStructure({fee: 989, feeNew: 0, timestampUpdate: 0}), // To mitigate LP sandwich attacks. LPers would pay 9% of their deposit as upfront fee.
            mintingStopped: false,
            cumulativeTax: 0
        });
    }

    /*////////////////////////////////////////////////////////////////
                        READ-ONLY FUNCTIONS
    ////////////////////////////////////////////////////////////////*/

    function cumulativeSIRPerTEA(
        uint16 cumulativeTax,
        SirStructs.VaultIssuanceParams memory vaultIssuanceParams_,
        uint256 supplyExcludeVault_
    ) internal view returns (uint176 cumulativeSIRPerTEAx96) {
        unchecked {
            // Get the vault issuance parameters
            cumulativeSIRPerTEAx96 = vaultIssuanceParams_.cumulativeSIRPerTEAx96;

            // Do nothing if no new SIR has been issued, or it has already been updated
            if (
                vaultIssuanceParams_.tax != 0 &&
                vaultIssuanceParams_.timestampLastUpdate != uint40(block.timestamp) &&
                supplyExcludeVault_ != 0
            ) {
                assert(vaultIssuanceParams_.tax <= cumulativeTax);

                // Starting time for the issuance in this vault
                uint40 timestampStart = vaultIssuanceParams_.timestampLastUpdate;

                // Aggregate SIR issued before the first 3 years. Issuance is slightly lower during the first 3 years because some is diverged to contributors.
                uint40 timestamp3Years = TIMESTAMP_ISSUANCE_START + SystemConstants.THREE_YEARS;
                if (timestampStart < timestamp3Years) {
                    uint256 issuance = (uint256(SystemConstants.LP_ISSUANCE_FIRST_3_YEARS) * vaultIssuanceParams_.tax) /
                        cumulativeTax;
                    // Cannot OF because 80 bits for the non-decimal part is enough to store the balance even if all SIR issued in 599 years went to a single LPer
                    cumulativeSIRPerTEAx96 += uint176(
                        ((issuance *
                            ((block.timestamp > timestamp3Years ? timestamp3Years : block.timestamp) -
                                timestampStart)) << 96) / supplyExcludeVault_
                    );
                }

                // Aggregate SIR issued after the first 3 years
                if (uint40(block.timestamp) > timestamp3Years) {
                    uint256 issuance = (uint256(SystemConstants.ISSUANCE) * vaultIssuanceParams_.tax) / cumulativeTax;
                    cumulativeSIRPerTEAx96 += uint176(
                        (((issuance *
                            (block.timestamp -
                                (timestampStart > timestamp3Years ? timestampStart : timestamp3Years))) << 96) /
                            supplyExcludeVault_)
                    );
                }
            }
        }
    }

    /**
        @param vaultId The id of the vault to query.
        @param lper The address of the LPer to query.
        @param cumulativeSIRPerTEAx96 The current cumulative SIR minted by the vaultId per unit of TEA.
     */
    function unclaimedRewards(
        uint256 vaultId,
        address lper,
        uint256 balance,
        uint176 cumulativeSIRPerTEAx96
    ) internal view returns (uint80) {
        unchecked {
            if (lper == address(this)) return 0;

            // Get the lper issuance parameters
            LPerIssuanceParams memory lperIssuanceParams_ = _lpersIssuances[vaultId][lper];

            // If LPer has no TEA
            if (balance == 0) return lperIssuanceParams_.unclaimedRewards;

            // It does not OF because uint80 is chosen so that it can stored all issued SIR for almost 600 years.
            return
                lperIssuanceParams_.unclaimedRewards +
                uint80((balance * uint256(cumulativeSIRPerTEAx96 - lperIssuanceParams_.cumulativeSIRPerTEAx96)) >> 96);
        }
    }

    /**
     * @notice Returns the amount of SIR owed to the LPer in vault `vaultId`.
     * @param vaultId The id of the vault to query.
     * @param lper The address of the LPer to query.
     */
    function unclaimedRewards(uint256 vaultId, address lper) external view returns (uint80) {
        return unclaimedRewards(vaultId, lper, balanceOf(lper, vaultId), cumulativeSIRPerTEA(vaultId));
    }

    /**
     * @notice Returns the tax charged to the vault which is equal to
     * 10% * tax / type(uint8).max
     */
    function vaultTax(uint48 vaultId) external view returns (uint8) {
        return vaultIssuanceParams[vaultId].tax;
    }

    /**
     * @notice Returns the system parameters.
     */
    function systemParams() public view returns (SirStructs.SystemParameters memory systemParams_) {
        systemParams_ = _systemParams;

        // Check if baseFee needs to be updated
        if (
            systemParams_.baseFee.timestampUpdate != 0 &&
            block.timestamp >= systemParams_.baseFee.timestampUpdate + SystemConstants.FEE_CHANGE_DELAY
        ) {
            systemParams_.baseFee.fee = systemParams_.baseFee.feeNew;
            systemParams_.baseFee.timestampUpdate = 0;
        }

        // Check if lpFee needs to be updated
        if (
            systemParams_.lpFee.timestampUpdate != 0 &&
            block.timestamp >= systemParams_.lpFee.timestampUpdate + SystemConstants.FEE_CHANGE_DELAY
        ) {
            systemParams_.lpFee.fee = systemParams_.lpFee.feeNew;
            systemParams_.lpFee.timestampUpdate = 0;
        }
    }

    /*////////////////////////////////////////////////////////////////
                            WRITE FUNCTIONS
    ////////////////////////////////////////////////////////////////*/

    /**
     * @dev Mints SIR rewards for `lper` in vault `vaultId`.
     * Only callable by the SIR contract.
     */
    function claimSIR(uint256 vaultId, address lper) external returns (uint80) {
        require(msg.sender == _SIR);

        return
            updateLPerIssuanceParams(
                true,
                vaultId,
                _systemParams.cumulativeTax,
                vaultIssuanceParams[vaultId],
                supplyExcludeVault(vaultId),
                LPersBalances(lper, balanceOf(lper, vaultId), address(0), 0)
            );
    }

    function updateLPerIssuanceParams(
        bool sirIsCaller,
        uint256 vaultId,
        uint16 cumulativeTax,
        SirStructs.VaultIssuanceParams memory vaultIssuanceParams_,
        uint256 supplyExcludeVault_,
        LPersBalances memory lpersBalances
    ) internal returns (uint80 unclaimedRewards0) {
        // Retrieve cumulative SIR per unit of TEA
        uint176 cumulativeSIRPerTEAx96 = cumulativeSIRPerTEA(cumulativeTax, vaultIssuanceParams_, supplyExcludeVault_);

        // Retrieve updated LPer0 issuance parameters
        unclaimedRewards0 = unclaimedRewards(
            vaultId,
            lpersBalances.lper0,
            lpersBalances.balance0,
            cumulativeSIRPerTEAx96
        );

        // Update LPer0 issuance parameters
        _lpersIssuances[vaultId][lpersBalances.lper0] = LPerIssuanceParams(
            cumulativeSIRPerTEAx96,
            sirIsCaller ? 0 : unclaimedRewards0
        );

        // Protocol owned liquidity (POL) in the vault does not receive SIR rewards
        if (lpersBalances.lper1 != address(this)) {
            /** Transfer/mint of TEA
                Must update the 2nd user's issuance parameters too
             */
            _lpersIssuances[vaultId][lpersBalances.lper1] = LPerIssuanceParams(
                cumulativeSIRPerTEAx96,
                unclaimedRewards(vaultId, lpersBalances.lper1, lpersBalances.balance1, cumulativeSIRPerTEAx96)
            );
        }

        /** Update the vault's issuance
            We may be tempted to skip updating the vault's issuance if the vault's issuance has not changed (i.e. totalSupply has not changed),
            like in the case of a Transfer of TEA. However, this could result in rounding errors causing SIR issuance to be larger than expected.
         */
        vaultIssuanceParams[vaultId].cumulativeSIRPerTEAx96 = cumulativeSIRPerTEAx96;
        vaultIssuanceParams[vaultId].timestampLastUpdate = uint40(block.timestamp);
    }

    /*////////////////////////////////////////////////////////////////
                        SYSTEM CONTROL FUNCTIONS
    ////////////////////////////////////////////////////////////////*/

    /**
     * @dev This function can only be called by the SystemControl contract.\n
     * It updates the base fee charge to apes, the fee charged to LPers when minting or haults all minting.\n
     * All these parameters are updated in a single function for bytecode efficiency.\n
     * All checks and balances are done at the SystemControl contract.
     */
    function updateSystemState(uint16 baseFee, uint16 lpFee, bool mintingStopped) external onlySystemControl {
        SirStructs.SystemParameters memory systemParams_ = systemParams();

        if (baseFee != 0) {
            systemParams_.baseFee.timestampUpdate = uint40(block.timestamp);
            systemParams_.baseFee.feeNew = baseFee;
        } else if (lpFee != 0) {
            systemParams_.lpFee.timestampUpdate = uint40(block.timestamp);
            systemParams_.lpFee.feeNew = lpFee;
        } else {
            systemParams_.mintingStopped = mintingStopped;
        }

        _systemParams = systemParams_;
    }

    /**
     * @dev This function can only be called by the SystemControl contract.\n
     * Updates the tax of the vaults whose fees are distributed to stakers of SIR.\n
     * The amount of SIR rewards received by LPers of a vault is proportional to the tax of the vault. 0 tax implies no SIR rewards.\n
     * All checks and balances are done at the SystemControl contract.
     */
    function updateVaults(
        uint48[] calldata oldVaults,
        uint48[] calldata newVaults,
        uint8[] calldata newTaxes,
        uint16 cumulativeTax
    ) external onlySystemControl {
        // Stop old issuances
        for (uint256 i = 0; i < oldVaults.length; ++i) {
            // Update vault issuance parameters
            vaultIssuanceParams[oldVaults[i]] = SirStructs.VaultIssuanceParams({
                tax: 0, // Nul tax, and consequently nul SIR issuance
                timestampLastUpdate: uint40(block.timestamp),
                cumulativeSIRPerTEAx96: cumulativeSIRPerTEA(oldVaults[i]) // Retrieve the vault's current cumulative SIR per unit of TEA
            });

            emit VaultNewTax(oldVaults[i], 0, 0);
        }

        // Start new issuances
        for (uint256 i = 0; i < newVaults.length; ++i) {
            // Update vault issuance parameters
            vaultIssuanceParams[newVaults[i]] = SirStructs.VaultIssuanceParams({
                tax: newTaxes[i],
                timestampLastUpdate: uint40(block.timestamp),
                cumulativeSIRPerTEAx96: cumulativeSIRPerTEA(newVaults[i]) // Retrieve the vault's current cumulative SIR per unit of TEA
            });

            emit VaultNewTax(newVaults[i], newTaxes[i], cumulativeTax);
        }

        // Update cumulative taxes
        _systemParams.cumulativeTax = cumulativeTax;
    }

    /*////////////////////////////////////////////////////////////////
                        FUNCTION TO BE IMPLEMENTED BY TEA
    ////////////////////////////////////////////////////////////////*/

    function cumulativeSIRPerTEA(uint256 vaultId) public view virtual returns (uint176 cumulativeSIRPerTEAx96);

    function balanceOf(address owner, uint256 vaultId) public view virtual returns (uint256);

    function supplyExcludeVault(uint256 vaultId) internal view virtual returns (uint256);
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

// Interfaces
import {IERC20} from "v2-core/interfaces/IERC20.sol";

// Libraries
import {SirStructs} from "./libraries/SirStructs.sol";
import {VaultExternal} from "./libraries/VaultExternal.sol";
import {FullMath} from "./libraries/FullMath.sol";
import {Fees} from "./libraries/Fees.sol";
import {SystemConstants} from "./libraries/SystemConstants.sol";

// Contracts
import {ERC1155TokenReceiver} from "solmate/tokens/ERC1155.sol";
import {SystemState} from "./SystemState.sol";

/** @dev Highly modified contract version from Solmate's ERC-1155.\n
    This contract manages all the LP tokens of all vaults in the protocol.
 */
contract TEA is SystemState {
    error TEAMaxSupplyExceeded();
    error NotAuthorized();
    error LengthMismatch();
    error UnsafeRecipient();

    event TransferSingle(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 amount
    );

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] vaultIds,
        uint256[] amounts
    );

    struct TotalSupplyAndBalanceVault {
        uint128 totalSupply;
        uint128 balanceVault;
    }

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);
    event URI(string value, uint256 indexed id);

    mapping(address => mapping(uint256 => uint256)) internal balances;

    /*  Because the protocol owned liquidity (POL) is updated on every mint/burn of TEA, we packed both values,
        totalSupply and the POL balance, into a single uint256 to save gas on SLOADs.
        POL is TEA owned by this same contract.
        Fortunately, the max supply of TEA fits in 128 bits, so we can use the other 128 bits for POL.
     */
    mapping(uint256 vaultId => TotalSupplyAndBalanceVault) internal totalSupplyAndBalanceVault;

    SirStructs.VaultParameters[] internal _paramsById; // Never used in Vault.sol. Just for users to access vault parameters by vault ID.
    mapping(address => mapping(address => bool)) public isApprovedForAll;

    constructor(address systemControl, address sir) SystemState(systemControl, sir) {}

    /*////////////////////////////////////////////////////////////////
                            READ-ONLY FUNCTIONS
    ////////////////////////////////////////////////////////////////*/

    /// @notice Returns vault parameters by vault ID.
    function paramsById(uint48 vaultId) external view returns (SirStructs.VaultParameters memory) {
        return _paramsById[vaultId];
    }

    /// @notice Returns the number of initialized vaults.
    function numberOfVaults() external view returns (uint48) {
        return uint48(_paramsById.length - 1);
    }

    /// @notice The total circulating supply of TEA.
    function totalSupply(uint256 vaultId) external view returns (uint256) {
        return totalSupplyAndBalanceVault[vaultId].totalSupply;
    }

    /// @notice The total circulating supply of TEA excluding POL.
    function supplyExcludeVault(uint256 vaultId) internal view override returns (uint256) {
        TotalSupplyAndBalanceVault memory totalSupplyAndBalanceVault_ = totalSupplyAndBalanceVault[vaultId];
        return totalSupplyAndBalanceVault_.totalSupply - totalSupplyAndBalanceVault_.balanceVault;
    }

    function uri(uint256 vaultId) external view returns (string memory) {
        return VaultExternal.teaURI(_paramsById, vaultId, totalSupplyAndBalanceVault[vaultId].totalSupply);
    }

    /// @notice Returns the balance of the given `account` for the given `vaultId`.
    function balanceOf(address account, uint256 vaultId) public view override returns (uint256) {
        return account == address(this) ? totalSupplyAndBalanceVault[vaultId].balanceVault : balances[account][vaultId];
    }

    /// @notice Returns the balances of multiple vault ID's
    function balanceOfBatch(
        address[] calldata owners,
        uint256[] calldata vaultIds
    ) external view returns (uint256[] memory balances_) {
        if (owners.length != vaultIds.length) revert LengthMismatch();

        balances_ = new uint256[](owners.length);

        // Unchecked because the only math done is incrementing
        // the array index counter which cannot possibly overflow.
        unchecked {
            for (uint256 i = 0; i < owners.length; ++i) {
                balances_[i] = balanceOf(owners[i], vaultIds[i]);
            }
        }
    }

    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        return
            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
            interfaceId == 0xd9b67a26 || // ERC165 Interface ID for ERC1155
            interfaceId == 0x0e89341c; // ERC165 Interface ID for ERC1155MetadataURI
    }

    /*////////////////////////////////////////////////////////////////
                            WRITE FUNCTIONS
    ////////////////////////////////////////////////////////////////*/

    /**
     * @notice Grants or revokes permission for `operator` to delegate token transfers on behalf of `account`.
     */
    function setApprovalForAll(address operator, bool approved) external {
        isApprovedForAll[msg.sender][operator] = approved;

        emit ApprovalForAll(msg.sender, operator, approved);
    }

    /**
     * @notice Transfers `amount` tokens in `vaultId` from `from` to `to`.
     */
    function safeTransferFrom(address from, address to, uint256 vaultId, uint256 amount, bytes calldata data) external {
        assert(from != address(this));
        if (msg.sender != from && !isApprovedForAll[from][msg.sender]) revert NotAuthorized();

        // Update balances
        _updateBalances(from, to, vaultId, amount);

        emit TransferSingle(msg.sender, from, to, vaultId, amount);

        if (
            to.code.length == 0
                ? to == address(0)
                : (to != address(this) &&
                    ERC1155TokenReceiver(to).onERC1155Received(msg.sender, from, vaultId, amount, data) !=
                    ERC1155TokenReceiver.onERC1155Received.selector)
        ) revert UnsafeRecipient();
    }

    /**
     * @notice Transfers `amounts` tokens in `vaultIds` from `from` to `to`.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata vaultIds,
        uint256[] calldata amounts,
        bytes calldata data
    ) external {
        unchecked {
            assert(from != address(this));
            if (vaultIds.length != amounts.length) revert LengthMismatch();
            if (msg.sender != from && !isApprovedForAll[from][msg.sender]) revert NotAuthorized();

            for (uint256 i = 0; i < vaultIds.length; ++i) {
                // Update balances
                _updateBalances(from, to, vaultIds[i], amounts[i]);
            }

            emit TransferBatch(msg.sender, from, to, vaultIds, amounts);

            if (
                to.code.length == 0
                    ? to == address(0)
                    : (to != address(this) &&
                        ERC1155TokenReceiver(to).onERC1155BatchReceived(msg.sender, from, vaultIds, amounts, data) !=
                        ERC1155TokenReceiver.onERC1155BatchReceived.selector)
            ) revert UnsafeRecipient();
        }
    }

    /**
     * @dev This function is called when a user mints TEA.
     * It splits the collateral amount between the minter and POL.
     * It also updates SIR rewards in case this vault is elligible for them.
     */
    function mint(
        address minter,
        address collateral,
        uint48 vaultId,
        SirStructs.SystemParameters memory systemParams_,
        SirStructs.VaultIssuanceParams memory vaultIssuanceParams_,
        SirStructs.Reserves memory reserves,
        uint144 collateralDeposited
    ) internal returns (SirStructs.Fees memory fees, uint256 amount) {
        uint256 amountToPOL;
        unchecked {
            // Loads supply and balance of TEA
            TotalSupplyAndBalanceVault memory totalSupplyAndBalanceVault_ = totalSupplyAndBalanceVault[vaultId];
            uint256 balanceOfTo = balances[minter][vaultId];

            // Update SIR issuance of gentlemen
            LPersBalances memory lpersBalances = LPersBalances(minter, balanceOfTo, address(this), 0);
            updateLPerIssuanceParams(
                false,
                vaultId,
                systemParams_.cumulativeTax,
                vaultIssuanceParams_,
                totalSupplyAndBalanceVault_.totalSupply - totalSupplyAndBalanceVault_.balanceVault,
                lpersBalances
            );

            // Total amount of TEA to mint (to split between minter and POL)
            // We use variable amountToPOL for efficiency, not because it is just for POL
            amountToPOL = totalSupplyAndBalanceVault_.totalSupply == 0 // By design reserveLPers can never be 0 unless it is the first mint ever
                ? _amountFirstMint(collateral, collateralDeposited + reserves.reserveLPers) // In the first mint, reserveLPers contains orphaned fees from apes
                : FullMath.mulDiv(totalSupplyAndBalanceVault_.totalSupply, collateralDeposited, reserves.reserveLPers);

            // Check that total supply does not overflow
            if (amountToPOL > SystemConstants.TEA_MAX_SUPPLY - totalSupplyAndBalanceVault_.totalSupply) {
                revert TEAMaxSupplyExceeded();
            }

            // Split collateralDeposited between minter and POL
            fees = Fees.feeMintTEA(collateralDeposited, systemParams_.lpFee.fee);

            // Minter's share of TEA
            amount = FullMath.mulDiv(
                amountToPOL,
                fees.collateralInOrWithdrawn,
                totalSupplyAndBalanceVault_.totalSupply == 0
                    ? collateralDeposited + reserves.reserveLPers // In the first mint, reserveLPers contains orphaned fees from apes
                    : collateralDeposited
            );

            // POL's share of TEA
            amountToPOL -= amount;

            // Update total supply and protocol balance
            balances[minter][vaultId] = balanceOfTo + amount;
            totalSupplyAndBalanceVault_.balanceVault += uint128(amountToPOL);
            totalSupplyAndBalanceVault_.totalSupply += uint128(amount + amountToPOL);

            // Store total supply
            totalSupplyAndBalanceVault[vaultId] = totalSupplyAndBalanceVault_;
        }

        // Update reserves
        reserves.reserveLPers += collateralDeposited;

        // Emit (mint) transfer events
        emit TransferSingle(minter, address(0), minter, vaultId, amount);
        emit TransferSingle(minter, address(0), address(this), vaultId, amountToPOL);
    }

    /**
     * @dev This function is called when a user burns TEA.
     * @dev It also updates SIR rewards in case this vault is elligible for them.
     */
    function burn(
        uint48 vaultId,
        SirStructs.SystemParameters memory systemParams_,
        SirStructs.VaultIssuanceParams memory vaultIssuanceParams_,
        SirStructs.Reserves memory reserves,
        uint256 amount
    ) internal returns (SirStructs.Fees memory fees) {
        unchecked {
            // Loads supply and balance of TEA
            TotalSupplyAndBalanceVault memory totalSupplyAndBalanceVault_ = totalSupplyAndBalanceVault[vaultId];
            uint256 balanceOfFrom = balances[msg.sender][vaultId];

            // Check we are not burning more than the balance
            require(amount <= balanceOfFrom);

            // Update SIR issuance
            updateLPerIssuanceParams(
                false,
                vaultId,
                systemParams_.cumulativeTax,
                vaultIssuanceParams_,
                totalSupplyAndBalanceVault_.totalSupply - totalSupplyAndBalanceVault_.balanceVault,
                LPersBalances(msg.sender, balanceOfFrom, address(this), 0)
            );

            // Compute amount of collateral
            fees.collateralInOrWithdrawn = uint144(
                FullMath.mulDiv(reserves.reserveLPers, amount, totalSupplyAndBalanceVault_.totalSupply)
            );

            // Update balance and total supply
            balances[msg.sender][vaultId] = balanceOfFrom - amount;
            totalSupplyAndBalanceVault_.totalSupply -= uint128(amount);

            // Update reserves
            reserves.reserveLPers -= fees.collateralInOrWithdrawn;

            // Update total supply and vault balance
            totalSupplyAndBalanceVault[vaultId] = totalSupplyAndBalanceVault_;

            // Emit transfer event
            emit TransferSingle(msg.sender, msg.sender, address(0), vaultId, amount);
        }
    }

    /*////////////////////////////////////////////////////////////////
                            PRIVATE FUNCTIONS
    ////////////////////////////////////////////////////////////////*/

    /**
     * @dev Makes sure that even if the entire supply of the collateral token was deposited into the vault,
     * the amount of TEA minted is less than the maximum supply of TEA.
     */
    function _amountFirstMint(address collateral, uint144 collateralDeposited) private view returns (uint256 amount) {
        uint256 collateralTotalSupply = IERC20(collateral).totalSupply();
        /** When possible assign siz 0's to the TEA balance per unit of collateral to mitigate inflation attacks.
            If not possible mint as much as TEA as possible while forcing that if all collateral was minted, it would not overflow the TEA maximum supply.
         */
        amount = collateralTotalSupply > SystemConstants.TEA_MAX_SUPPLY / 1e6
            ? FullMath.mulDiv(SystemConstants.TEA_MAX_SUPPLY, collateralDeposited, collateralTotalSupply)
            : collateralDeposited * 1e6;
    }

    /**'
     * @dev This helper function ensures that the balance of the vault (POL)
     * is not stored in the regular variable balances.
     */
    function _setBalance(address account, uint256 vaultId, uint256 balance) private {
        if (account == address(this)) totalSupplyAndBalanceVault[vaultId].balanceVault = uint128(balance);
        else balances[account][vaultId] = balance;
    }

    /**
     * @dev Helper function for updating balances and SIR rewards when transfering TEA between accounts.
     */
    function _updateBalances(address from, address to, uint256 vaultId, uint256 amount) private {
        // Update SIR issuances
        LPersBalances memory lpersBalances = LPersBalances(from, balances[from][vaultId], to, balanceOf(to, vaultId));
        updateLPerIssuanceParams(
            false,
            vaultId,
            _systemParams.cumulativeTax,
            vaultIssuanceParams[vaultId],
            supplyExcludeVault(vaultId),
            lpersBalances
        );

        // Update balances
        lpersBalances.balance0 -= amount;
        if (from != to) {
            balances[from][vaultId] = lpersBalances.balance0;
            unchecked {
                _setBalance(to, vaultId, lpersBalances.balance1 + amount);
            }
        }
    }

    /*////////////////////////////////////////////////////////////////
                        SYSTEM STATE VIRTUAL FUNCTIONS
    ////////////////////////////////////////////////////////////////*/

    function cumulativeSIRPerTEA(uint256 vaultId) public view override returns (uint176 cumulativeSIRPerTEAx96) {
        return
            cumulativeSIRPerTEA(_systemParams.cumulativeTax, vaultIssuanceParams[vaultId], supplyExcludeVault(vaultId));
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%%%%%%%%%%%%%%
//             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%%%%%%%%%%%%%%%             ____              _   _          _   _
//              @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%%%%%%%%%%%%%%%            / ___| _   _ _ __ | |_| |__   ___| |_(_) ___ ___
//              @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%%%%%%%%%%%%%%%             \___ \| | | | '_ \| __| '_ \ / _ \ __| |/ __/ __|
//               @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%%%%%%%%%%%%%%               ___) | |_| | | | | |_| | | |  __/ |_| | (__\__ \
//               @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%%%%%%%%%%%%%%%              |____/ \__, |_| |_|\__|_| |_|\___|\__|_|\___|___/
//                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%%%%%%%%%%%%%%                      |___/
//                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%%%%%%%%%%%%%%%                ___                 _                           _           _
//                 @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%%%%%%%%%%%%%%                |_ _|_ __ ___  _ __ | | ___ _ __ ___   ___ _ __ | |_ ___  __| |
//                 @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%%%%%%%%%%%%%%%                 | || '_ ` _ \| '_ \| |/ _ \ '_ ` _ \ / _ \ '_ \| __/ _ \/ _` |
//                  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%%%%%%%%%%%%%%%                 | || | | | | | |_) | |  __/ | | | | |  __/ | | | ||  __/ (_| |
//                  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%%%%%%%%%%%%%%                 |___|_| |_| |_| .__/|_|\___|_| |_| |_|\___|_| |_|\__\___|\__,_|
//                  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%%%%%%%%%%%%%%%                               |_|
//                  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%%%%%%%%%%%%%%%                  ____  _       _     _
//                  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%%%%%%%%%%%%%%%                 |  _ \(_) __ _| |__ | |_
//                  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%%%%%%%%%%%%%%%                 | |_) | |/ _` | '_ \| __|
//                 ==============================-::::::::::::::::                |  _ <| | (_| | | | | |_
//                 ==============================-::::::::::::::::                |_| \_\_|\__, |_| |_|\__|
//                ===============================-:::::::::::::::::                        |___/
//                ===============================-::::::::::::::::::
// @@@@@@@@@@@@@@@%##***++=======================-::::::::--===++**#%%%%%%%%%%%%%%
//  @@@@@@@@@@@@@@@@@@@@@@@@@@@%%%################****####%%%%%%%%%%%%%%%%%%%%%%%
//     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%%%%%%%%%%%%%%%%%%%%%%%
//                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%%%%%%%%%@@

// Interfaces
import {IERC20} from "v2-core/interfaces/IERC20.sol";
import {IUniswapV3Pool} from "v3-core/interfaces/IUniswapV3Pool.sol";
import {IWETH9} from "src/interfaces/IWETH9.sol";

// Libraries
import {VaultExternal} from "./libraries/VaultExternal.sol";
import {TransferHelper} from "v3-periphery/libraries/TransferHelper.sol";
import {TickMathPrecision} from "./libraries/TickMathPrecision.sol";
import {SirStructs} from "./libraries/SirStructs.sol";
import {TickMath} from "v3-core/libraries/TickMath.sol";

// Contracts
import {ERC1155TokenReceiver} from "solmate/tokens/ERC1155.sol";
import {APE} from "./APE.sol";
import {Oracle} from "./Oracle.sol";
import {TEA} from "./TEA.sol";

/**
 * @notice Users can mint or burn the synthetic assets (TEA or APE) of the protocol
 * @dev Vaultall vaults for maximum efficiency using a singleton architecture.\n
 * A bogus collateral token (doing reentrancy attacks or returning face values)
 * means that all vaults using that type of collateral are compromised,
 * but vaults using OTHER collateral types are safe.\n
 * VaultExternal is an external library used for unloading bytecode and meeting the maximum contract size requirement.
 */
contract Vault is TEA {
    error AmountTooLow();
    error InsufficientCollateralReceivedFromUniswap();
    error Locked();
    error NotAWETHVault();

    /*  
        collateralFeeToLPers also includes protocol owned liquidity (POL),
        i.e., collateralFeeToLPers = collateralFeeToLPers + collateralFeeToProtocol
     */
    event Mint(
        uint48 indexed vaultId,
        bool isAPE,
        uint144 collateralIn,
        uint144 collateralFeeToStakers,
        uint144 collateralFeeToLPers
    );
    event Burn(
        uint48 indexed vaultId,
        bool isAPE,
        uint144 collateralWithdrawn,
        uint144 collateralFeeToStakers,
        uint144 collateralFeeToLPers
    );

    Oracle private immutable _ORACLE;
    address private immutable _APE_IMPLEMENTATION;
    address private immutable _WETH;

    mapping(address debtToken => mapping(address collateralToken => mapping(int8 leverageTier => SirStructs.VaultState)))
        internal _vaultStates; // Do not use vaultId 0

    mapping(address collateral => uint256) public totalReserves;

    constructor(
        address systemControl,
        address sir,
        address oracle,
        address apeImplementation,
        address weth
    ) TEA(systemControl, sir) {
        // Price _ORACLE
        _ORACLE = Oracle(oracle);

        // Save the address of the APE implementation
        _APE_IMPLEMENTATION = apeImplementation;

        // WETH
        _WETH = weth;

        // Push empty parameters to avoid vaultId 0
        _paramsById.push(SirStructs.VaultParameters(address(0), address(0), 0));
    }

    /**
     * @notice Initialization is always necessary because we must deploy the APE contract for each vault,
     * and possibly initialize the Oracle.
     */
    function initialize(SirStructs.VaultParameters memory vaultParams) external {
        VaultExternal.deploy(
            _ORACLE,
            _vaultStates[vaultParams.debtToken][vaultParams.collateralToken][vaultParams.leverageTier],
            _paramsById,
            vaultParams,
            _APE_IMPLEMENTATION
        );
    }

    modifier nonReentrant() {
        {
            uint256 locked;
            assembly {
                locked := tload(0)
            }

            if (locked != 0) revert Locked();

            // Lock
            locked = 1;
            assembly {
                tstore(0, locked)
            }
        }

        _;

        // Unlock
        assembly {
            tstore(0, 0)
        }
    }

    /*////////////////////////////////////////////////////////////////
                            MINT/BURN FUNCTIONS
    ////////////////////////////////////////////////////////////////*/

    /**
     * @notice Function for minting APE or TEA, the protocol's synthetic tokens.\n
     * You can mint by depositing collateral token or debt token dependening by setting collateralToDepositMin to 0 or not, respectively.\n
     * You have the option to mint with vanilla ETH when the token is WETH by simply sending ETH with the call. In this case, amountToDeposit is ignored.
     * @dev When minting APE, the user will give away a portion of his deposited collateral to the LPers.\n
     * When minting TEA, the user will give away a portion of his deposited collateral to protocol owned liquidity.
     * @param isAPE If true, mint APE. If false, mint TEA
     * @param vaultParams The 3 parameters identifying a vault: collateral token, debt token, and leverage tier.
     * @param amountToDeposit Collateral amount to deposit if collateralToDepositMin == 0, debt token to deposit if collateralToDepositMin > 0
     * @param collateralToDepositMin Ignored when minting with collateral token, otherwise it specifies the minimum amount of collateral to receive from Uniswap when swapping the debt token.
     * @return amount of tokens TEA/APE obtained
     */
    function mint(
        bool isAPE,
        SirStructs.VaultParameters memory vaultParams,
        uint256 amountToDeposit, // Collateral amount to deposit if collateralToDepositMin == 0, debt token to deposit if collateralToDepositMin > 0
        uint144 collateralToDepositMin
    ) external payable nonReentrant returns (uint256 amount) {
        // Check if user sent vanilla ETH
        bool isETH = msg.value != 0;
        if (isETH) {
            // Minter sent ETH, so we need to check that this is a WETH vault
            if ((collateralToDepositMin == 0 ? vaultParams.collateralToken : vaultParams.debtToken) != _WETH)
                revert NotAWETHVault();

            // msg.value is the amount to deposit
            amountToDeposit = msg.value;

            // We must wrap it to WETH
            IWETH9(_WETH).deposit{value: msg.value}();
        }

        // Cannot deposit 0
        if (amountToDeposit == 0) revert AmountTooLow();

        // Get reserves
        (
            SirStructs.VaultState memory vaultState,
            SirStructs.Reserves memory reserves,
            address ape,
            address uniswapPool
        ) = VaultExternal.getReserves(isAPE, _vaultStates, _ORACLE, vaultParams);

        if (collateralToDepositMin == 0) {
            // Minter deposited collateral

            // Check amount does not exceed max
            require(amountToDeposit <= type(uint144).max);

            // Rest of the mint logic
            amount = _mint(msg.sender, ape, vaultParams, uint144(amountToDeposit), vaultState, reserves);

            // If the user didn't send ETH, transfer the ERC20 collateral from the minter
            if (msg.value == 0) {
                TransferHelper.safeTransferFrom(
                    vaultParams.collateralToken,
                    msg.sender,
                    address(this),
                    amountToDeposit
                );
            }
        } else {
            // Minter deposited debt token and requires a Uniswap V3 swap

            // Store Uniswap v3 pool in transient storage so we can use it in the callback function
            assembly {
                tstore(1, uniswapPool)
            }

            // Check amount does not exceed max
            require(amountToDeposit <= uint256(type(int256).max));

            // Encode data for swap callback
            bool zeroForOne = vaultParams.collateralToken > vaultParams.debtToken;
            bytes memory data = abi.encode(msg.sender, ape, vaultParams, vaultState, reserves, zeroForOne, isETH);

            // Swap
            (int256 amount0, int256 amount1) = IUniswapV3Pool(uniswapPool).swap(
                address(this),
                zeroForOne,
                int256(amountToDeposit),
                zeroForOne ? TickMath.MIN_SQRT_RATIO + 1 : TickMath.MAX_SQRT_RATIO - 1,
                data
            );

            // Retrieve amount of collateral received from the Uniswap pool
            uint256 collateralToDeposit = zeroForOne ? uint256(-amount1) : uint256(-amount0);

            // Check collateral received is sufficient
            if (collateralToDeposit < collateralToDepositMin) revert InsufficientCollateralReceivedFromUniswap();

            // Get amount of tokens
            assembly {
                amount := tload(1)
            }
        }
    }

    /**
     * @dev This callback function is required by Uniswap pools when making a swap.\n
     * This function is exectuted when the user decides to mint TEA or APE with debt token.\n
     * This function is in charge of sending the debt token to the uniswwap pool.\n
     * It will revert if any external actor that is not a Uniswap pool calls this function.
     */
    function uniswapV3SwapCallback(int256 amount0Delta, int256 amount1Delta, bytes calldata data) external {
        // Check caller is the legit Uniswap pool
        address uniswapPool;
        assembly {
            uniswapPool := tload(1)
        }
        require(msg.sender == uniswapPool);

        // Decode data
        (
            address minter,
            address ape,
            SirStructs.VaultParameters memory vaultParams,
            SirStructs.VaultState memory vaultState,
            SirStructs.Reserves memory reserves,
            bool zeroForOne,
            bool isETH
        ) = abi.decode(
                data,
                (address, address, SirStructs.VaultParameters, SirStructs.VaultState, SirStructs.Reserves, bool, bool)
            );

        // Retrieve amount of collateral to deposit and check it does not exceed max
        (uint256 collateralToDeposit, uint256 debtTokenToSwap) = zeroForOne
            ? (uint256(-amount1Delta), uint256(amount0Delta))
            : (uint256(-amount0Delta), uint256(amount1Delta));

        // If this is an ETH mint, transfer WETH to the pool asap
        if (isETH) {
            TransferHelper.safeTransfer(vaultParams.debtToken, uniswapPool, debtTokenToSwap);
        }

        // Rest of the mint logic
        require(collateralToDeposit <= type(uint144).max);
        uint256 amount = _mint(minter, ape, vaultParams, uint144(collateralToDeposit), vaultState, reserves);

        // Transfer debt token to the pool
        // This is done last to avoid reentrancy attack from a bogus debt token contract
        if (!isETH) {
            TransferHelper.safeTransferFrom(vaultParams.debtToken, minter, uniswapPool, debtTokenToSwap);
        }

        // Use the transient storage to return amount of tokens minted to the mint function
        assembly {
            tstore(1, amount)
        }
    }

    /**
     * @dev Remainer mint logic of the mint function above.
     * It is apart from the mint function because this logic needs to be executed in uniswapV3SwapCallback when minting with debt token
     * to ensure there is no reentrancy attack when minting with debt token.
     */
    function _mint(
        address minter,
        address ape, // If ape is 0, minting TEA
        SirStructs.VaultParameters memory vaultParams,
        uint144 collateralToDeposit,
        SirStructs.VaultState memory vaultState,
        SirStructs.Reserves memory reserves
    ) internal returns (uint256 amount) {
        SirStructs.SystemParameters memory systemParams_ = systemParams();
        require(!systemParams_.mintingStopped);

        SirStructs.VaultIssuanceParams memory vaultIssuanceParams_ = vaultIssuanceParams[vaultState.vaultId];
        SirStructs.Fees memory fees;
        bool isAPE = ape != address(0);
        if (isAPE) {
            // Mint APE
            (reserves, fees, amount) = APE(ape).mint(
                minter,
                systemParams_.baseFee.fee,
                vaultIssuanceParams_.tax,
                reserves,
                collateralToDeposit
            );

            // Distribute APE fees to LPers. Checks that it does not overflow
            reserves.reserveLPers += fees.collateralFeeToLPers;
        } else {
            // Mint TEA and distribute fees to protocol owned liquidity (POL)
            (fees, amount) = mint(
                minter,
                vaultParams.collateralToken,
                vaultState.vaultId,
                systemParams_,
                vaultIssuanceParams_,
                reserves,
                collateralToDeposit
            );
        }

        // For the sake of the user, do not let users deposit collateral in exchange for nothing
        if (amount == 0) revert AmountTooLow();

        // Update _vaultStates from new reserves
        _updateVaultState(vaultState, reserves, vaultParams);

        // Update total reserves
        totalReserves[vaultParams.collateralToken] += collateralToDeposit - fees.collateralFeeToStakers;

        // Emit event
        emit Mint(
            vaultState.vaultId,
            isAPE,
            fees.collateralInOrWithdrawn,
            fees.collateralFeeToStakers,
            fees.collateralFeeToLPers
        );

        /** Check if recipient is enabled for receiving TEA.
            This check is done last to avoid reentrancy attacks because it may call an external contract.
        */
        if (
            !isAPE &&
            minter.code.length > 0 &&
            ERC1155TokenReceiver(minter).onERC1155Received(minter, address(0), vaultState.vaultId, amount, "") !=
            ERC1155TokenReceiver.onERC1155Received.selector
        ) revert UnsafeRecipient();
    }

    /**
     * @notice Function for burning APE or TEA, the protocol's synthetic tokens.
     * @dev When burning APE, the user will give away a portion of his collateral to the LPers.
     * @param isAPE If true, burn APE. If false, burn TEA
     * @param vaultParams The 3 parameters identifying a vault: collateral token, debt token, and leverage tier.
     * @param amount Amount of tokens to burn
     * @return amount of collateral obtained for burning APE or TEA.
     */
    function burn(
        bool isAPE,
        SirStructs.VaultParameters calldata vaultParams,
        uint256 amount
    ) external nonReentrant returns (uint144) {
        if (amount == 0) revert AmountTooLow();

        SirStructs.SystemParameters memory systemParams_ = systemParams();

        // Get reserves
        (SirStructs.VaultState memory vaultState, SirStructs.Reserves memory reserves, address ape, ) = VaultExternal
            .getReserves(isAPE, _vaultStates, _ORACLE, vaultParams);

        SirStructs.VaultIssuanceParams memory vaultIssuanceParams_ = vaultIssuanceParams[vaultState.vaultId];
        SirStructs.Fees memory fees;
        if (isAPE) {
            // Burn APE
            (reserves, fees) = APE(ape).burn(
                msg.sender,
                systemParams_.baseFee.fee,
                vaultIssuanceParams_.tax,
                reserves,
                amount
            );

            // Distribute APE fees to LPers
            reserves.reserveLPers += fees.collateralFeeToLPers;
        } else {
            // Burn TEA (no fees are actually paid)
            fees = burn(vaultState.vaultId, systemParams_, vaultIssuanceParams_, reserves, amount);
        }

        // Update vault state from new reserves
        _updateVaultState(vaultState, reserves, vaultParams);

        // Update total reserves
        unchecked {
            totalReserves[vaultParams.collateralToken] -= fees.collateralInOrWithdrawn + fees.collateralFeeToStakers;
        }

        // Emit event
        emit Burn(
            vaultState.vaultId,
            isAPE,
            fees.collateralInOrWithdrawn,
            fees.collateralFeeToStakers,
            fees.collateralFeeToLPers
        );

        // Send collateral to the user
        TransferHelper.safeTransfer(vaultParams.collateralToken, msg.sender, fees.collateralInOrWithdrawn);

        return fees.collateralInOrWithdrawn;
    }

    /*////////////////////////////////////////////////////////////////
                            READ ONLY FUNCTIONS
    ////////////////////////////////////////////////////////////////*/

    /** @notice Returns the reserves of the vault meaning (1) the amount of collateral in the vault belonging to apes,
        @notice (2) the amount of collateral belonging to LPers, and (3) the current collateral-debt-token price.
     */
    function getReserves(
        SirStructs.VaultParameters calldata vaultParams
    ) external view returns (SirStructs.Reserves memory) {
        return VaultExternal.getReservesReadOnly(_vaultStates, _ORACLE, vaultParams);
    }

    /*////////////////////////////////////////////////////////////////
                            PRIVATE FUNCTIONS
    ////////////////////////////////////////////////////////////////*/

    /*  This function stores the state of the vault ass efficiently as possible.
        Connections Between VaultState Variables (R,priceSat) & Reserves (A,L)
        where R = Total reserve, A = Apes reserve, L = LP reserve
            (R,priceSat) ⇔ (A,L)
            (R,  ∞  ) ⇔ (0,L)
            (R,  0  ) ⇔ (A,0)
     */
    function _updateVaultState(
        SirStructs.VaultState memory vaultState,
        SirStructs.Reserves memory reserves,
        SirStructs.VaultParameters memory vaultParams
    ) private {
        // Checks that the reserve does not overflow uint144
        vaultState.reserve = reserves.reserveApes + reserves.reserveLPers;

        unchecked {
            /** We enforce that the reserve must be at least 10^6 to avoid division by zero, and
                to mitigate inflation attacks.
             */
            require(vaultState.reserve >= 1e6);

            // Compute tickPriceSatX42
            if (reserves.reserveApes == 0) {
                vaultState.tickPriceSatX42 = type(int64).max;
            } else if (reserves.reserveLPers == 0) {
                vaultState.tickPriceSatX42 = type(int64).min;
            } else {
                bool isLeverageTierNonNegative = vaultParams.leverageTier >= 0;

                /**
                 * Decide if we are in the power or saturation zone
                 * Condition for power zone: A < (l-1) L where l=1+2^leverageTier
                 */
                uint8 absLeverageTier = isLeverageTierNonNegative
                    ? uint8(vaultParams.leverageTier)
                    : uint8(-vaultParams.leverageTier);
                bool isPowerZone;
                if (isLeverageTierNonNegative) {
                    if (
                        uint256(reserves.reserveApes) << absLeverageTier < reserves.reserveLPers
                    ) // Cannot OF because reserveApes is an uint144, and |leverageTier|<=3
                    {
                        isPowerZone = true;
                    } else {
                        isPowerZone = false;
                    }
                } else {
                    if (
                        reserves.reserveApes < uint256(reserves.reserveLPers) << absLeverageTier
                    ) // Cannot OF because reserveApes is an uint144, and |leverageTier|<=3
                    {
                        isPowerZone = true;
                    } else {
                        isPowerZone = false;
                    }
                }

                if (isPowerZone) {
                    /** PRICE IN POWER ZONE
                        priceSat = price*(R/(lA))^(r-1)
                     */

                    int256 tickRatioX42 = TickMathPrecision.getTickAtRatio(
                        isLeverageTierNonNegative ? vaultState.reserve : uint256(vaultState.reserve) << absLeverageTier, // Cannot OF cuz reserve is uint144, and |leverageTier|<=3
                        (uint256(reserves.reserveApes) << absLeverageTier) + reserves.reserveApes // Cannot OF cuz reserveApes is uint144, and |leverageTier|<=3
                    );

                    // Compute saturation price
                    int256 tempTickPriceSatX42 = reserves.tickPriceX42 +
                        (isLeverageTierNonNegative ? tickRatioX42 >> absLeverageTier : tickRatioX42 << absLeverageTier);

                    // Check if overflow
                    if (tempTickPriceSatX42 > type(int64).max) vaultState.tickPriceSatX42 = type(int64).max;
                    else vaultState.tickPriceSatX42 = int64(tempTickPriceSatX42);
                } else {
                    /** PRICE IN SATURATION ZONE
                        priceSat = r*price*L/R
                     */

                    int256 tickRatioX42 = TickMathPrecision.getTickAtRatio(
                        isLeverageTierNonNegative ? uint256(vaultState.reserve) << absLeverageTier : vaultState.reserve,
                        (uint256(reserves.reserveLPers) << absLeverageTier) + reserves.reserveLPers
                    );

                    // Compute saturation price
                    int256 tempTickPriceSatX42 = reserves.tickPriceX42 - tickRatioX42;

                    // Check if underflow
                    if (tempTickPriceSatX42 < type(int64).min) vaultState.tickPriceSatX42 = type(int64).min;
                    else vaultState.tickPriceSatX42 = int64(tempTickPriceSatX42);
                }
            }

            _vaultStates[vaultParams.debtToken][vaultParams.collateralToken][vaultParams.leverageTier] = vaultState;
        }
    }

    /*////////////////////////////////////////////////////////////////
                        SYSTEM CONTROL FUNCTIONS
    ////////////////////////////////////////////////////////////////*/

    /**
     * @notice This function is only intended to be called by the SIR contract.
     * @dev The fees collected from the vaults are are distributed to SIR stakers.
     * @param token to be distributed
     * @return totalFeesToStakers is the total amount of tokens to be distributed
     */
    function withdrawFees(address token) external nonReentrant returns (uint256 totalFeesToStakers) {
        require(msg.sender == _SIR);

        // Surplus above totalReserves is fees to stakers
        totalFeesToStakers = IERC20(token).balanceOf(address(this)) - totalReserves[token];

        TransferHelper.safeTransfer(token, _SIR, totalFeesToStakers);
    }

    /**
     * @dev This function is only intended to be called as last recourse to save the system from a critical bug or hack
     * during the beta period. To execute it, the system must be in Shutdown status
     * which can only be activated after SHUTDOWN_WITHDRAWAL_DELAY seconds elapsed since Emergency status was activated.
     * @param tokens is a list of tokens to be withdrawn.
     * @param to is the recipient of the tokens
     * @return amounts is the list of amounts of tokens to be withdrawn
     */
    function withdrawToSaveSystem(
        address[] calldata tokens,
        address to
    ) external onlySystemControl returns (uint256[] memory amounts) {
        amounts = new uint256[](tokens.length);
        bool success;
        bytes memory data;
        for (uint256 i = 0; i < tokens.length; i++) {
            // We use the low-level call because we want to continue with the next token if balanceOf reverts
            (success, data) = tokens[i].call(abi.encodeWithSelector(IERC20.balanceOf.selector, address(this)));

            // Data length is always a multiple of 32 bytes
            if (success && data.length == 32) {
                amounts[i] = abi.decode(data, (uint256));

                if (amounts[i] > 0) {
                    (success, data) = tokens[i].call(abi.encodeWithSelector(IERC20.transfer.selector, to, amounts[i]));

                    // If the transfer failed, set the amount of transfered tokens back to 0
                    success = success && (data.length == 0 || abi.decode(data, (bool)));

                    if (!success) amounts[i] = 0;
                }
            }
        }
    }

    /*////////////////////////////////////////////////////////////////
                            EXPLICIT GETTERS
    ////////////////////////////////////////////////////////////////*/

    /**
     * @notice Returns the state of a particular vault
     * @param vaultParams The 3 parameters identifying a vault: collateral token, debt token, and leverage tier.
     */
    function vaultStates(
        SirStructs.VaultParameters calldata vaultParams
    ) external view returns (SirStructs.VaultState memory) {
        return _vaultStates[vaultParams.debtToken][vaultParams.collateralToken][vaultParams.leverageTier];
    }
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title Interface for WETH9
interface IWETH9 is IERC20 {
    /// @notice Deposit ether to get wrapped ether
    function deposit() external payable;

    /// @notice Withdraw wrapped ether to get ether
    function withdraw(uint256) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Contributors {
    /** @dev Total contributor allocation: 31.87%
        @dev LP allocation: 68.13%
        @dev Sum of all allocations must be equal to type(uint56).max.
     */
    function getAllocation(address contributor) internal pure returns (uint56) {
        if (contributor == address(0xAacc079965F0F9473BF4299d930eF639690a9792)) return 58779012666421;
        else if (contributor == address(0xa485B739e99334f4B92B04da2122e2923a054688)) return 293895063332101;
        else if (contributor == address(0x1C5EB68630cCd90C3152FB9Dee3a1C2A7201631D)) return 37980285107534;
        else if (contributor == address(0x0e52b591Cbc9AB81c806F303DE8d9a3B0Dc4ea5C)) return 2260731256400770;
        else if (contributor == address(0xfdcc69463b0106888D1CA07CE118A64AdF9fe458)) return 2260731256400770;
        else if (contributor == address(0xF613cfD07af6D011fD671F98064214aB5B2942CF)) return 67369791440744;
        else if (contributor == address(0x3424cd7D170949636C300e62674a3DFB7706Fc35)) return 881685189996301;
        else if (contributor == address(0xe59813A4a120288dbf42630C051e3921E5dAbCd8)) return 226073125640078;
        else if (contributor == address(0x241F1A461Da47Ccd40B48c38340896A9948A4725)) return 323058496539671;
        else if (contributor == address(0x6422D607CA13457589A1f2dbf0ec63d5Adf87BFB)) return 81838471481709;
        else if (contributor == address(0xE19618C08F74b7e80278Ec14b63797419dACCDf8)) return 452146251280155;
        else if (contributor == address(0xbe1E110f4A2fD54622CD516e86b29f619ad994bF)) return 107859488242882;
        else if (contributor == address(0x30E14c4b4768F9B5F520a2F6214d2cCc21255fDa)) return 2938950633321001;
        else if (contributor == address(0x0C0aB132F5a8d0988e88997cb2604F494052BDEF)) return 22607312564009;
        else if (contributor == address(0x8D2a097607da5E2E3d599c72EC50FD0704a4D37f)) return 940170307599389;
        else if (contributor == address(0x78086Ad810f8F99A0B6c92a9A6c8857d3c665622)) return 539885231341069;
        else if (contributor == address(0x18e17dd452Ef58F91E45fD20Eb2F839ac13AA648)) return 678219376920232;
        else if (contributor == address(0xc4Ab0e3F12309f37A5cdf3A4b3B7C70A53eeBBa9)) return 63024665965942;
        else if (contributor == address(0xFe202706E36F31aFBaf4b4543C2A8bBa4ddB2deE)) return 1012807602867546;
        else if (contributor == address(0x7DF76FDEedE91d3cB80e4a86158dD9f6D206c98E)) return 254513124845600;
        else if (contributor == address(0xe4F047C5DEB2659f3659057fe5cAFB5bC6bD4307)) return 28033067579371;
        else if (contributor == address(0x26610e89A8B825F23E89e58879cE97D791aD4438)) return 1130365628200386;
        else if (contributor == address(0x32cf4d1df6fb7bB173183CF8b51EF9499c803634)) return 307120341182045;
        else if (contributor == address(0x8D677d312F2CA04dF98eB22ce886bE8E7804280d)) return 113036562820039;
        else if (contributor == address(0x40FEfD52714f298b9EaD6760753aAA720438D4bB)) return 113036562820039;
        else if (contributor == address(0x16fD74300dcDc02E9b1E594f293c6EfFB299a3fc)) return 113036562820039;
        else if (contributor == address(0xa233f74638Bd28A24CC2Ce23475eea7dC76881AC)) return 117662018970635;
        else if (contributor == address(0xA6f4fa9840Aa6825446c820aF6d5eCcf9f78BA05)) return 162998723586496;
        else if (contributor == address(0xa1a841D79758Bd4b06c9206e97343dFeBcBE200b)) return 18085850051206152;
        else if (contributor == address(0xEdA726014938d2E6Ed51c7d5A53193cf9713cdF7)) return 471362466959560;
        else if (contributor == address(0x65665e10EB86D72b02067863342277EA2DF78516)) return 339109688460115;
        else if (contributor == address(0xd11f322ad85730Eab11ef61eE9100feE84b63739)) return 5651828141001922;
        else if (contributor == address(0xdF58360e945F6a302FFFB012D114C9e2bE2F212a)) return 89072811502190;
        else if (contributor == address(0x65a831D9fB2CC87A7956eB8E4720956f6bfC6eeA)) return 87228054796967;
        else if (contributor == address(0xBA5EDc0d2Ae493C9574328d77dc36eEF19F699e2)) return 230142441901598;
        else if (contributor == address(0x1ff241abaD54DEcB967Bd0f57c2a584C7d1ca8BD)) return 271287750768092;
        else if (contributor == address(0x36D11126eBc59cb962AE8ddD3bcD0741b4e337Dc)) return 5411195906070625;
        else if (contributor == address(0x81B55FBe66C5FFbb8468328E924AF96a84438F14)) return 56518281410019;
        else if (contributor == address(0x686748764c5C7Aa06FEc784E60D14b650bF79129)) return 22607312564007688;
        else if (contributor == address(0x07bfeB5488ad97aA3920cf241E59d2A817054eA3)) return 23963751317848;
        else if (contributor == address(0xC3632CD03BEd246719965bB74279af79bE4bd813)) return 23963751317848;
        else if (contributor == address(0xb1f55485d7ebA772F0d454Ceb0EA9a27586Ad86f)) return 53353257651058;
        else if (contributor == address(0xC58D3aE892A104D663B01194f2EE325CfB5187f2)) return 1582511879480538;
        else if (contributor == address(0x0D5f69C67DAE06ce606246A8bd88B552d1DdE140)) return 67821937692023;
        else if (contributor == address(0xde3697dDA384ce178d04D8879F7a66423F72A326)) return 355906921695173;
        else if (contributor == address(0x79C1134a1dFdF7e0d58E58caFC84a514991372e6)) return 1061548968755545;
        
        return 0;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {SirStructs} from "./SirStructs.sol";

/**
 * @notice	Smart contract for computing fees in SIR.
 */

library Fees {
    /** @notice APES pay a fee to the LPers when they mint/burn APE
        @notice If a non-zero tax is set for the vault, 10% of the fee is sent to SIR stakers
        @param collateralDepositedOrOut Amount of collateral deposited or taken out by the apes
        @param baseFee Base fee in basis points per unit of liquidity
        @param leverageTier Tier of the vault
        @param tax Tax in basis points charged to the apes for getting SIR
     */
    function feeAPE(
        uint144 collateralDepositedOrOut,
        uint16 baseFee,
        int256 leverageTier,
        uint8 tax
    ) internal pure returns (SirStructs.Fees memory fees) {
        unchecked {
            uint256 feeNum;
            uint256 feeDen;
            if (leverageTier >= 0) {
                feeNum = 10000; // baseFee is uint16, leverageTier is int8, so feeNum does not require more than 24 bits
                feeDen = 10000 + (uint256(baseFee) << uint256(leverageTier));
            } else {
                uint256 temp = 10000 << uint256(-leverageTier);
                feeNum = temp;
                feeDen = temp + uint256(baseFee);
            }

            // collateralDepositedOrOut = collateralInOrWithdrawn + collateralFeeToLPers + collateralFeeToStakers
            fees.collateralInOrWithdrawn = uint144((uint256(collateralDepositedOrOut) * feeNum) / feeDen);
            uint256 totalFees = collateralDepositedOrOut - fees.collateralInOrWithdrawn;

            // Depending on the tax, between 0 and 10% of the fee is for SIR stakers
            fees.collateralFeeToStakers = uint144((totalFees * tax) / (10 * uint256(type(uint8).max))); // Cannot overflow cuz fee is uint144 and tax is uint8

            // The rest is sent to the gentlemen, if there are none, then it is POL
            fees.collateralFeeToLPers = uint144(totalFees) - fees.collateralFeeToStakers;
        }
    }

    /** @notice LPers pay a fee to the protocol when they mint TEA
        @notice collateralFeeToLPers is the fee paid to the protocol (not all LPers)
        @param collateralDeposited Amount of collateral deposited by the LPers
        @param lpFee Fee in basis points charged to LPers and sent to the protocol
     */
    function feeMintTEA(uint144 collateralDeposited, uint16 lpFee) internal pure returns (SirStructs.Fees memory fees) {
        unchecked {
            uint256 feeNum = 10000;
            uint256 feeDen = 10000 + uint256(lpFee);

            // collateralDeposited = collateralIn + collateralFeeToLPers
            fees.collateralInOrWithdrawn = uint144((uint256(collateralDeposited) * feeNum) / feeDen);
            fees.collateralFeeToLPers = collateralDeposited - fees.collateralInOrWithdrawn;
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Contains 512-bit math functions
/// @notice Facilitates multiplication and division that can have overflow of an intermediate value without any loss of precision
/// @dev Handles "phantom overflow" i.e., allows multiplication and division where an intermediate value overflows 256 bits
/// @dev Modified from https://github.com/Uniswap/v3-core/blob/main/contracts/libraries/FullMath.sol so that it can compile on Solidity 8
library FullMath {
    /// @notice Calculates floor(a×b÷denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
    /// @param a The multiplicand
    /// @param b The multiplier
    /// @param denominator The divisor
    /// @return result The 256-bit result
    /// @dev Credit to Remco Bloemen under MIT license https://xn--2-umb.com/21/muldiv
    function mulDiv(uint256 a, uint256 b, uint256 denominator) internal pure returns (uint256 result) {
        // 512-bit multiply [prod1 prod0] = a * b
        // Compute the product mod 2**256 and mod 2**256 - 1
        // then use the Chinese Remainder Theorem to reconstruct
        // the 512 bit result. The result is stored in two 256
        // variables such that product = prod1 * 2**256 + prod0
        uint256 prod0; // Least significant 256 bits of the product
        uint256 prod1; // Most significant 256 bits of the product
        assembly {
            let mm := mulmod(a, b, not(0))
            prod0 := mul(a, b)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }

        // Handle non-overflow cases, 256 by 256 division
        if (prod1 == 0) {
            require(denominator > 0);
            assembly {
                result := div(prod0, denominator)
            }
            return result;
        }

        // Make sure the result is less than 2**256.
        // Also prevents denominator == 0
        require(denominator > prod1);

        ///////////////////////////////////////////////
        // 512 by 256 division.
        ///////////////////////////////////////////////

        // Make division exact by subtracting the remainder from [prod1 prod0]
        // Compute remainder using mulmod
        uint256 remainder;
        assembly {
            remainder := mulmod(a, b, denominator)
        }
        // Subtract 256 bit number from 512 bit number
        assembly {
            prod1 := sub(prod1, gt(remainder, prod0))
            prod0 := sub(prod0, remainder)
        }

        // Factor powers of two out of denominator
        // Compute largest power of two divisor of denominator.
        // Always >= 1.
        unchecked {
            uint256 twos = (type(uint256).max - denominator + 1) & denominator;
            // Divide denominator by power of two
            assembly {
                denominator := div(denominator, twos)
            }

            // Divide [prod1 prod0] by the factors of two
            assembly {
                prod0 := div(prod0, twos)
            }
            // Shift in bits from prod1 into prod0. For this we need
            // to flip `twos` such that it is 2**256 / twos.
            // If twos is zero, then it becomes one
            assembly {
                twos := add(div(sub(0, twos), twos), 1)
            }
            prod0 |= prod1 * twos;

            // Invert denominator mod 2**256
            // Now that denominator is an odd number, it has an inverse
            // modulo 2**256 such that denominator * inv = 1 mod 2**256.
            // Compute the inverse by starting with a seed that is correct
            // correct for four bits. That is, denominator * inv = 1 mod 2**4
            uint256 inv = (3 * denominator) ^ 2;
            // Now use Newton-Raphson iteration to improve the precision.
            // Thanks to Hensel's lifting lemma, this also works in modular
            // arithmetic, doubling the correct bits in each step.
            inv *= 2 - denominator * inv; // inverse mod 2**8
            inv *= 2 - denominator * inv; // inverse mod 2**16
            inv *= 2 - denominator * inv; // inverse mod 2**32
            inv *= 2 - denominator * inv; // inverse mod 2**64
            inv *= 2 - denominator * inv; // inverse mod 2**128
            inv *= 2 - denominator * inv; // inverse mod 2**256

            // Because the division is now exact we can divide by multiplying
            // with the modular inverse of denominator. This will give us the
            // correct result modulo 2**256. Since the precoditions guarantee
            // that the outcome is less than 2**256, this is the final result.
            // We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inv;
            return result;
        }
    }

    function tryMulDiv(uint256 a, uint256 b, uint256 denominator) internal pure returns (bool success, uint256 result) {
        // 512-bit multiply [prod1 prod0] = a * b
        // Compute the product mod 2**256 and mod 2**256 - 1
        // then use the Chinese Remainder Theorem to reconstruct
        // the 512 bit result. The result is stored in two 256
        // variables such that product = prod1 * 2**256 + prod0
        uint256 prod0; // Least significant 256 bits of the product
        uint256 prod1; // Most significant 256 bits of the product
        assembly {
            let mm := mulmod(a, b, not(0))
            prod0 := mul(a, b)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }

        // Handle non-overflow cases, 256 by 256 division
        if (prod1 == 0) {
            if (denominator == 0) return (false, 0);
            assembly {
                result := div(prod0, denominator)
            }
            return (true, result);
        }

        // Make sure the result is less than 2**256.
        // Also prevents denominator == 0
        if (denominator <= prod1) return (false, 0);

        ///////////////////////////////////////////////
        // 512 by 256 division.
        ///////////////////////////////////////////////

        // Make division exact by subtracting the remainder from [prod1 prod0]
        // Compute remainder using mulmod
        uint256 remainder;
        assembly {
            remainder := mulmod(a, b, denominator)
        }
        // Subtract 256 bit number from 512 bit number
        assembly {
            prod1 := sub(prod1, gt(remainder, prod0))
            prod0 := sub(prod0, remainder)
        }

        // Factor powers of two out of denominator
        // Compute largest power of two divisor of denominator.
        // Always >= 1.
        unchecked {
            uint256 twos = (type(uint256).max - denominator + 1) & denominator;
            // Divide denominator by power of two
            assembly {
                denominator := div(denominator, twos)
            }

            // Divide [prod1 prod0] by the factors of two
            assembly {
                prod0 := div(prod0, twos)
            }
            // Shift in bits from prod1 into prod0. For this we need
            // to flip `twos` such that it is 2**256 / twos.
            // If twos is zero, then it becomes one
            assembly {
                twos := add(div(sub(0, twos), twos), 1)
            }
            prod0 |= prod1 * twos;

            // Invert denominator mod 2**256
            // Now that denominator is an odd number, it has an inverse
            // modulo 2**256 such that denominator * inv = 1 mod 2**256.
            // Compute the inverse by starting with a seed that is correct
            // correct for four bits. That is, denominator * inv = 1 mod 2**4
            uint256 inv = (3 * denominator) ^ 2;
            // Now use Newton-Raphson iteration to improve the precision.
            // Thanks to Hensel's lifting lemma, this also works in modular
            // arithmetic, doubling the correct bits in each step.
            inv *= 2 - denominator * inv; // inverse mod 2**8
            inv *= 2 - denominator * inv; // inverse mod 2**16
            inv *= 2 - denominator * inv; // inverse mod 2**32
            inv *= 2 - denominator * inv; // inverse mod 2**64
            inv *= 2 - denominator * inv; // inverse mod 2**128
            inv *= 2 - denominator * inv; // inverse mod 2**256

            // Because the division is now exact we can divide by multiplying
            // with the modular inverse of denominator. This will give us the
            // correct result modulo 2**256. Since the precoditions guarantee
            // that the outcome is less than 2**256, this is the final result.
            // We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inv;
            return (true, result);
        }
    }

    /// @notice Calculates ceil(a×b÷denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
    /// @param a The multiplicand
    /// @param b The multiplier
    /// @param denominator The divisor
    /// @return result The 256-bit result
    function mulDivRoundingUp(uint256 a, uint256 b, uint256 denominator) internal pure returns (uint256 result) {
        result = mulDiv(a, b, denominator);
        if (mulmod(a, b, denominator) > 0) {
            require(result < type(uint256).max);
            result++;
        }
    }

    function tryMulDivRoundingUp(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (bool success, uint256 result) {
        (success, result) = tryMulDiv(a, b, denominator);
        if (success && mulmod(a, b, denominator) > 0) {
            if (result == type(uint256).max) return (false, 0);
            result++;
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SirStructs {
    struct VaultIssuanceParams {
        uint8 tax; // (tax / type(uint8).max * 10%) of its fee revenue is directed to the Treasury.
        uint40 timestampLastUpdate; // timestamp of the last time cumulativeSIRPerTEAx96 was updated. 0 => use systemParams.timestampIssuanceStart instead
        uint176 cumulativeSIRPerTEAx96; // Q104.96, cumulative SIR minted by the vaultId per unit of TEA.
    }

    struct VaultParameters {
        address debtToken;
        address collateralToken;
        int8 leverageTier;
    }

    struct FeeStructure {
        uint16 fee; // Fee in basis points.
        uint16 feeNew; // New fee to replace fee if current time exceeds FEE_CHANGE_DELAY since timestampUpdate
        uint40 timestampUpdate; // Timestamp fee change was made. If 0, feeNew is not used.
    }

    struct SystemParameters {
        FeeStructure baseFee;
        FeeStructure lpFee;
        bool mintingStopped; // If true, no minting of TEA/APE
        /** Aggregated taxes for all vaults. Choice of uint16 type.
            For vault i, (tax_i / type(uint8).max)*10% is charged, where tax_i is of type uint8.
            They must satisfy the condition
                Σ_i (tax_i / type(uint8).max)^2 ≤ 0.1^2
            Under this constraint, cumulativeTax = Σ_i tax_i is maximized when all taxes are equal (tax_i = tax for all i) and
                tax = type(uint8).max / sqrt(Nvaults)
            Since the lowest non-zero value is tax=1, the maximum number of vaults with non-zero tax is
                Nvaults = type(uint8).max^2 < type(uint16).max
         */
        uint16 cumulativeTax;
    }

    /** Collateral owned by the apes and LPers in a vault
     */
    struct Reserves {
        uint144 reserveApes;
        uint144 reserveLPers;
        int64 tickPriceX42;
    }

    /** Data needed for recoverying the amount of collateral owned by the apes and LPers in a vault
     */
    struct VaultState {
        uint144 reserve; // reserve =  reserveApes + reserveLPers
        /** Price at the border of the power and saturation zone.
            Q21.42 - Fixed point number with 42 bits of precision after the comma.
            type(int64).max and type(int64).min are used to represent +∞ and -∞ respectively.
         */
        int64 tickPriceSatX42; // Saturation price in Q21.42 fixed point
        uint48 vaultId; // Allows the creation of approximately 281 trillion vaults
    }

    /** The sum of all amounts in Fees are equal to the amounts deposited by the user (in the case of a mint)
        or taken out by the user (in the case of a burn).
        collateralInOrWithdrawn: Amount of collateral deposited by the user (in the case of a mint) or taken out by the user (in the case of a burn).
        collateralFeeToStakers: Amount of collateral paid to the stakers.
        collateralFeeToLPers: Amount of collateral paid to the gentlemen.
        collateralFeeToProtocol: Amount of collateral paid to the protocol.
     */
    struct Fees {
        uint144 collateralInOrWithdrawn;
        uint144 collateralFeeToStakers;
        uint144 collateralFeeToLPers; // Sometimes all LPers and sometimes only protocol owned liquidity
    }

    struct StakingParams {
        uint80 stake; // Amount of staked SIR
        uint176 cumulativeETHPerSIRx80; // Cumulative ETH per SIR * 2^80
    }

    struct StakerParams {
        uint80 stake; // Total amount of staked SIR by the staker
        uint176 cumulativeETHPerSIRx80; // Cumulative ETH per SIR * 2^80 last time the user updated his balance of ETH dividends
        uint80 lockedStake; // Amount of stake that was locked at time 'tsLastUpdate'
        uint40 tsLastUpdate; // Timestamp of the last time the user staked or unstaked
    }

    struct Auction {
        address bidder; // Address of the bidder
        uint96 bid; // Amount of the bid
        uint40 startTime; // Auction start time
    }

    struct OracleState {
        int64 tickPriceX42; // Last stored price. Q21.42
        uint40 timeStampPrice; // Timestamp of the last stored price
        uint8 indexFeeTier; // Uniswap v3 fee tier currently being used as oracle
        uint8 indexFeeTierProbeNext; // Uniswap v3 fee tier to probe next
        uint40 timeStampFeeTier; // Timestamp of the last probed fee tier
        bool initialized; // Whether the oracle has been initialized
        UniswapFeeTier uniswapFeeTier; // Uniswap v3 fee tier currently being used as oracle
    }

    /**
     * Parameters of a Uniswap v3 tier.
     */
    struct UniswapFeeTier {
        uint24 fee;
        int24 tickSpacing;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SystemConstants {
    uint8 internal constant SIR_DECIMALS = 12;

    /** SIR Token Issuance Rate
        If we want to issue 2,015,000,000 SIR per year, this implies an issuance rate of 63.9 SIR/s.
     */
    uint72 internal constant ISSUANCE = uint72(2015e6 * 10 ** SIR_DECIMALS - 1) / 365 days + 1; // [sir/s]

    /** During the first 3 years, 30%-to-33% of the emissions are diverged to contributors.
        - 10% to pre-mainnet contributors
        - 10%-13% to fundraising contributors
        - 10% to a treasury for post-mainnet stuff
     */
    uint72 internal constant LP_ISSUANCE_FIRST_3_YEARS = uint72((uint256(68126421999999980) * ISSUANCE) / 1e17);

    uint128 internal constant TEA_MAX_SUPPLY = (uint128(LP_ISSUANCE_FIRST_3_YEARS) << 96) / type(uint16).max; // Must fit in uint128

    uint40 internal constant THREE_YEARS = 3 * 365 days;

    int64 internal constant MAX_TICK_X42 = 1951133415219145403; // log_1.0001((2^128-1(/2^64))*2^42

    // Approximately 10 days. We did not choose 10 days precisely to avoid auctions always ending on the same day and time of the week.
    uint40 internal constant AUCTION_COOLDOWN = 247 hours; // 247h & 240h have no common factors

    // Duration of an auction
    uint40 internal constant AUCTION_DURATION = 24 hours;

    // Time it takes for a change of LP or base fee to take effect
    uint256 internal constant FEE_CHANGE_DELAY = 10 days;

    uint40 internal constant SHUTDOWN_WITHDRAWAL_DELAY = 20 days;

    int8 internal constant MAX_LEVERAGE_TIER = 2;

    int8 internal constant MIN_LEVERAGE_TIER = -4;

    uint256 internal constant HALVING_PERIOD = 30 days; // Every 30 days, half of the locked stake is unlocked
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "./FullMath.sol";
import {SystemConstants} from "./SystemConstants.sol";

/// @notice Modified from Uniswap v3 TickMath
/// @notice Math library for computing log_1.0001(x/y) and 1.0001^z where x and y are uint and z is Q21.42
library TickMathPrecision {
    /// @return uint128 in Q63.64
    function getRatioAtTick(int64 tickX42) internal pure returns (uint128) {
        assert(tickX42 >= 0 && tickX42 <= SystemConstants.MAX_TICK_X42);

        uint256 ratioX64 = tickX42 & 0x1 != 0 ? 0x100000000000001A3 : 0x10000000000000000;
        if (tickX42 & 0x2 != 0) ratioX64 = (ratioX64 * 0x10000000000000346) >> 64; // 42th bit after the comma
        if (tickX42 & 0x4 != 0) ratioX64 = (ratioX64 * 0x1000000000000068D) >> 64;
        if (tickX42 & 0x8 != 0) ratioX64 = (ratioX64 * 0x10000000000000D1B) >> 64;
        if (tickX42 & 0x10 != 0) ratioX64 = (ratioX64 * 0x10000000000001A36) >> 64;
        if (tickX42 & 0x20 != 0) ratioX64 = (ratioX64 * 0x1000000000000346D) >> 64;
        if (tickX42 & 0x40 != 0) ratioX64 = (ratioX64 * 0x100000000000068DA) >> 64;
        if (tickX42 & 0x80 != 0) ratioX64 = (ratioX64 * 0x1000000000000D1B4) >> 64;
        if (tickX42 & 0x100 != 0) ratioX64 = (ratioX64 * 0x1000000000001A368) >> 64;
        if (tickX42 & 0x200 != 0) ratioX64 = (ratioX64 * 0x100000000000346D1) >> 64;
        if (tickX42 & 0x400 != 0) ratioX64 = (ratioX64 * 0x10000000000068DA3) >> 64;
        if (tickX42 & 0x800 != 0) ratioX64 = (ratioX64 * 0x100000000000D1B46) >> 64;
        if (tickX42 & 0x1000 != 0) ratioX64 = (ratioX64 * 0x100000000001A368D) >> 64;
        if (tickX42 & 0x2000 != 0) ratioX64 = (ratioX64 * 0x10000000000346D1A) >> 64;
        if (tickX42 & 0x4000 != 0) ratioX64 = (ratioX64 * 0x1000000000068DA34) >> 64;
        if (tickX42 & 0x8000 != 0) ratioX64 = (ratioX64 * 0x10000000000D1B468) >> 64;
        if (tickX42 & 0x10000 != 0) ratioX64 = (ratioX64 * 0x10000000001A368D0) >> 64;
        if (tickX42 & 0x20000 != 0) ratioX64 = (ratioX64 * 0x1000000000346D1A0) >> 64;
        if (tickX42 & 0x40000 != 0) ratioX64 = (ratioX64 * 0x100000000068DA341) >> 64;
        if (tickX42 & 0x80000 != 0) ratioX64 = (ratioX64 * 0x1000000000D1B4683) >> 64;
        if (tickX42 & 0x100000 != 0) ratioX64 = (ratioX64 * 0x1000000001A368D06) >> 64;
        if (tickX42 & 0x200000 != 0) ratioX64 = (ratioX64 * 0x100000000346D1A0C) >> 64;
        if (tickX42 & 0x400000 != 0) ratioX64 = (ratioX64 * 0x10000000068DA3419) >> 64;
        if (tickX42 & 0x800000 != 0) ratioX64 = (ratioX64 * 0x100000000D1B46833) >> 64;
        if (tickX42 & 0x1000000 != 0) ratioX64 = (ratioX64 * 0x100000001A368D066) >> 64;
        if (tickX42 & 0x2000000 != 0) ratioX64 = (ratioX64 * 0x10000000346D1A0D0) >> 64;
        if (tickX42 & 0x4000000 != 0) ratioX64 = (ratioX64 * 0x1000000068DA341AB) >> 64;
        if (tickX42 & 0x8000000 != 0) ratioX64 = (ratioX64 * 0x10000000D1B468381) >> 64;
        if (tickX42 & 0x10000000 != 0) ratioX64 = (ratioX64 * 0x10000001A368D07AF) >> 64;
        if (tickX42 & 0x20000000 != 0) ratioX64 = (ratioX64 * 0x1000000346D1A120E) >> 64;
        if (tickX42 & 0x40000000 != 0) ratioX64 = (ratioX64 * 0x100000068DA342ED9) >> 64;
        if (tickX42 & 0x80000000 != 0) ratioX64 = (ratioX64 * 0x1000000D1B46888A4) >> 64;
        if (tickX42 & 0x100000000 != 0) ratioX64 = (ratioX64 * 0x1000001A368D1BD10) >> 64;
        if (tickX42 & 0x200000000 != 0) ratioX64 = (ratioX64 * 0x100000346D1A62940) >> 64;
        if (tickX42 & 0x400000000 != 0) ratioX64 = (ratioX64 * 0x10000068DA3570F02) >> 64;
        if (tickX42 & 0x800000000 != 0) ratioX64 = (ratioX64 * 0x100000D1B46D9100A) >> 64;
        if (tickX42 & 0x1000000000 != 0) ratioX64 = (ratioX64 * 0x100001A368E5DE82E) >> 64;
        if (tickX42 & 0x2000000000 != 0) ratioX64 = (ratioX64 * 0x10000346D1F6AF0E7) >> 64;
        if (tickX42 & 0x4000000000 != 0) ratioX64 = (ratioX64 * 0x1000068DA49926517) >> 64;
        if (tickX42 & 0x8000000000 != 0) ratioX64 = (ratioX64 * 0x10000D1B4BE16E016) >> 64;
        if (tickX42 & 0x10000000000 != 0) ratioX64 = (ratioX64 * 0x10001A36A27F65E2A) >> 64;
        if (tickX42 & 0x20000000000 != 0) ratioX64 = (ratioX64 * 0x1000346D6FF11672A) >> 64; // 1st bit after the comma
        if (tickX42 & 0x40000000000 != 0) ratioX64 = (ratioX64 * 0x100068DB8BAC710CB) >> 64; // 1st bit before the comma
        if (tickX42 & 0x80000000000 != 0) ratioX64 = (ratioX64 * 0x1000D1B9C68ABE5F7) >> 64;
        if (tickX42 & 0x100000000000 != 0) ratioX64 = (ratioX64 * 0x1001A37E4A234CB08) >> 64;
        if (tickX42 & 0x200000000000 != 0) ratioX64 = (ratioX64 * 0x100347278AB0E92AD) >> 64;
        if (tickX42 & 0x400000000000 != 0) ratioX64 = (ratioX64 * 0x10068EFB00A525480) >> 64;
        if (tickX42 & 0x800000000000 != 0) ratioX64 = (ratioX64 * 0x100D20A63B4173839) >> 64;
        if (tickX42 & 0x1000000000000 != 0) ratioX64 = (ratioX64 * 0x101A4C11C742DD772) >> 64;
        if (tickX42 & 0x2000000000000 != 0) ratioX64 = (ratioX64 * 0x1034C35C31F64CFA6) >> 64;
        if (tickX42 & 0x4000000000000 != 0) ratioX64 = (ratioX64 * 0x106A34B78C8AAFFBF) >> 64;
        if (tickX42 & 0x8000000000000 != 0) ratioX64 = (ratioX64 * 0x10D72A6A46CCD8BCE) >> 64;
        if (tickX42 & 0x10000000000000 != 0) ratioX64 = (ratioX64 * 0x11B9A258E63928596) >> 64;
        if (tickX42 & 0x20000000000000 != 0) ratioX64 = (ratioX64 * 0x13A2E2BDA04F8379F) >> 64;
        if (tickX42 & 0x40000000000000 != 0) ratioX64 = (ratioX64 * 0x181954BE69E0DA8FE) >> 64;
        if (tickX42 & 0x80000000000000 != 0) ratioX64 = (ratioX64 * 0x244C2655D185A0290) >> 64;
        if (tickX42 & 0x100000000000000 != 0) ratioX64 = (ratioX64 * 0x525816EEB9F935B1C) >> 64;
        if (tickX42 & 0x200000000000000 != 0) ratioX64 = (ratioX64 * 0x1A7C8D00B551684FF4) >> 64;
        if (tickX42 & 0x400000000000000 != 0) ratioX64 = (ratioX64 * 0x2BD893D0B2DF7C97884) >> 64;
        if (tickX42 & 0x800000000000000 != 0) ratioX64 = (ratioX64 * 0x78278E1E19E448CF8B95D) >> 64;
        if (tickX42 & 0x1000000000000000 != 0) ratioX64 = (ratioX64 * 0x38651B58D457501416FEADE319) >> 64; // 19th bit before the comma
        // Bits 20 and 21st do not need to be checked because tickX42 <= SystemConstants.MAX_TICK_X42
        // if (tickX42 & 0x2000000000000000 != 0) ratioX64 = (ratioX64 * 0xC6C63E573E99B8B10F5961AE4CACB1F9927) >> 64;
        // if (tickX42 & 0x4000000000000000 != 0)
        //     ratioX64 = (ratioX64 * 0x9A5741F372F8FF89A6E21EE87E9D34BB06995021F74FC62066806D) >> 64; // 21st bit before the comma (1st bit after the comma)

        return uint128(ratioX64);
    }

    /// @return tickX42 Q21.42 (+1 bit for sign)
    /// @notice The result is never negative, but it is returned as an int for compatibilty with negative ticks used outside this library.
    /// @dev We cannot ensure that this function rounds up or down.
    function getTickAtRatio(uint256 num, uint256 den) internal pure returns (int64 tickX42) {
        assert(num >= den);
        assert(den != 0);

        uint256 ratio;
        unchecked {
            ratio = num / den;
        }
        uint256 r = ratio;
        uint256 msb = 0;

        assembly {
            let f := shl(7, gt(r, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(6, gt(r, 0xFFFFFFFFFFFFFFFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(5, gt(r, 0xFFFFFFFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(4, gt(r, 0xFFFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(3, gt(r, 0xFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(2, gt(r, 0xF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(1, gt(r, 0x3))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := gt(r, 0x1)
            msb := or(msb, f)
        }

        // Normalize to so that it starts at bit 127, and so the square will not overflow
        unchecked {
            if (msb >= 128) r = ratio >> (msb - 127);
            else r = FullMath.mulDiv(num, 2 ** (127 - msb), den);
        }

        // Make space for the decimals
        uint256 log_2 = msb << (42 + 13);

        for (uint256 i = 1; i <= 42 + 13; ++i) {
            assembly {
                r := shr(127, mul(r, r)) // This is product of two Q128.128 numbers, so r is Q128.128
                let f := shr(128, r) // 1 if r≥2, 0 otherwise
                log_2 := or(log_2, shl(sub(55, i), f)) // Add another bit of precision after the comma
                r := shr(f, r)
            }
        }

        return int64(uint64((log_2 * 5311490373674440127006610942261594940696236095528553491154) >> (13 + 179)));
    }
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Provides functions for deriving a pool address from the factory, tokens, and the fee
/// @notice Modified from https://github.com/Uniswap/v3-periphery/blob/main/contracts/libraries/PoolAddress.sol
library UniswapPoolAddress {
    bytes32 internal constant POOL_INIT_CODE_HASH = 0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54;

    /// @notice The identifying key of the pool
    struct PoolKey {
        address token0;
        address token1;
        uint24 fee;
    }

    /// @notice Returns PoolKey: the ordered tokens with the matched fee levels
    /// @param tokenA The first token of a pool, unsorted
    /// @param tokenB The second token of a pool, unsorted
    /// @param fee The fee level of the pool
    /// @return Poolkey The pool details with ordered token0 and token1 assignments
    function getPoolKey(address tokenA, address tokenB, uint24 fee) internal pure returns (PoolKey memory) {
        if (tokenA > tokenB) (tokenA, tokenB) = (tokenB, tokenA);
        return PoolKey({token0: tokenA, token1: tokenB, fee: fee});
    }

    /// @notice Deterministically computes the pool address given the factory and PoolKey
    /// @param factory The Uniswap V3 factory contract address
    /// @param key The PoolKey
    /// @return pool The contract address of the V3 pool
    function computeAddress(address factory, PoolKey memory key) internal pure returns (address pool) {
        require(key.token0 < key.token1);
        pool = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            hex"ff",
                            factory,
                            keccak256(abi.encode(key.token0, key.token1, key.fee)),
                            POOL_INIT_CODE_HASH
                        )
                    )
                )
            )
        );
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Interfaces
import {IERC20} from "v2-core/interfaces/IERC20.sol";

// Libraries
import {SirStructs} from "./SirStructs.sol";
import {TickMathPrecision} from "./TickMathPrecision.sol";
import {Strings} from "openzeppelin/utils/Strings.sol";
import {SystemConstants} from "./SystemConstants.sol";
import {ClonesWithImmutableArgs} from "lib/clones-with-immutable-args/src/ClonesWithImmutableArgs.sol";

// Contracts
import {Oracle} from "../Oracle.sol";

library VaultExternal {
    error VaultAlreadyInitialized();
    error LeverageTierOutOfRange();
    error VaultDoesNotExist();

    event VaultInitialized(
        address indexed debtToken,
        address indexed collateralToken,
        int8 indexed leverageTier,
        uint256 vaultId,
        address ape
    );

    // Deploy APE token
    function deploy(
        Oracle oracle,
        SirStructs.VaultState storage vaultState,
        SirStructs.VaultParameters[] storage paramsById,
        SirStructs.VaultParameters calldata vaultParams,
        address implementationOfAPE
    ) external {
        if (
            vaultParams.leverageTier > SystemConstants.MAX_LEVERAGE_TIER ||
            vaultParams.leverageTier < SystemConstants.MIN_LEVERAGE_TIER
        ) revert LeverageTierOutOfRange();

        /**
         * 1. This will initialize the oracle for this pair of tokens if it has not been initialized before.
         * 2. It also will revert if there are no pools with liquidity, which implicitly solves the case where the user
         *    tries to instantiate an invalid pair of tokens like address(0)
         */
        oracle.initialize(vaultParams.debtToken, vaultParams.collateralToken);

        // Check the vault has not been initialized previously
        if (vaultState.vaultId != 0) revert VaultAlreadyInitialized();

        // Next vault ID
        uint256 vaultId = paramsById.length;
        require(vaultId <= type(uint48).max); // It has to fit in a uint48

        // Save parameters
        paramsById.push(vaultParams);

        // Derive the name of the APE clone
        string memory name = _generateName(vaultParams);

        // Derive the future address of the APE clone
        address ape = ClonesWithImmutableArgs.addressOfClone3(bytes32(vaultId));

        // Compute the default domain separator for the APE clone
        bytes32 domainSeparator = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(name)),
                keccak256("1"),
                block.chainid,
                ape
            )
        );

        // Deploy APE clone
        ClonesWithImmutableArgs.clone3(
            implementationOfAPE,
            abi.encodePacked(
                vaultParams.leverageTier, // The clone needs to know the leverage tier when minting/burning
                address(this), // So the clone knows the owner
                domainSeparator // This way the domain separator is stored as a constant
            ),
            bytes32(vaultId)
        );

        // Initialize APE clone
        (bool success, ) = ape.call(
            abi.encodeWithSignature(
                "initialize(string,string,uint8,address,address)",
                name,
                string.concat("APE-", Strings.toString(vaultId)),
                IERC20(vaultParams.collateralToken).decimals(),
                vaultParams.debtToken,
                vaultParams.collateralToken
            )
        );
        require(success);

        // Save vaultId
        vaultState.vaultId = uint48(vaultId);

        emit VaultInitialized(
            vaultParams.debtToken,
            vaultParams.collateralToken,
            vaultParams.leverageTier,
            vaultId,
            ape
        );
    }

    function teaURI(
        SirStructs.VaultParameters[] storage paramsById,
        uint256 vaultId,
        uint256 totalSupply
    ) external view returns (string memory) {
        string memory vaultIdStr = Strings.toString(vaultId);

        SirStructs.VaultParameters memory params = paramsById[vaultId];
        require(vaultId != 0);

        return
            string.concat(
                "data:application/json;charset=UTF-8,%7B%22name%22%3A%22LP%20Token%20for%20APE-",
                vaultIdStr,
                "%22%2C%22symbol%22%3A%22TEA-",
                vaultIdStr,
                "%22%2C%22decimals%22%3A",
                Strings.toString(IERC20(params.collateralToken).decimals()),
                "%2C%22chain_id%22%3A1%2C%22vault_id%22%3A",
                vaultIdStr,
                "%2C%22debt_token%22%3A%22",
                Strings.toHexString(params.debtToken),
                "%22%2C%22collateral_token%22%3A%22",
                Strings.toHexString(params.collateralToken),
                "%22%2C%22leverage_tier%22%3A",
                Strings.toStringSigned(params.leverageTier),
                "%2C%22total_supply%22%3A",
                Strings.toString(totalSupply),
                "%7D"
            );
    }

    function getReservesReadOnly(
        mapping(address debtToken => mapping(address collateralToken => mapping(int8 leverageTier => SirStructs.VaultState)))
            storage _vaultStates,
        Oracle oracle,
        SirStructs.VaultParameters calldata vaultParams
    ) external view returns (SirStructs.Reserves memory reserves) {
        // Get price
        reserves.tickPriceX42 = oracle.getPrice(vaultParams.collateralToken, vaultParams.debtToken);

        _getReserves(
            _vaultStates[vaultParams.debtToken][vaultParams.collateralToken][vaultParams.leverageTier],
            reserves,
            vaultParams.leverageTier
        );
    }

    function getReserves(
        bool isAPE,
        mapping(address debtToken => mapping(address collateralToken => mapping(int8 leverageTier => SirStructs.VaultState)))
            storage _vaultStates,
        Oracle oracle,
        SirStructs.VaultParameters calldata vaultParams
    )
        external
        returns (
            SirStructs.VaultState memory vaultState,
            SirStructs.Reserves memory reserves,
            address ape,
            address uniswapPool
        )
    {
        unchecked {
            vaultState = _vaultStates[vaultParams.debtToken][vaultParams.collateralToken][vaultParams.leverageTier];

            // Get price and update oracle state if needed
            (reserves.tickPriceX42, uniswapPool) = oracle.updateOracleState(
                vaultParams.collateralToken,
                vaultParams.debtToken
            );

            // Derive APE address if needed
            if (isAPE) ape = ClonesWithImmutableArgs.addressOfClone3(bytes32(uint256(vaultState.vaultId)));

            _getReserves(vaultState, reserves, vaultParams.leverageTier);
        }
    }

    /*////////////////////////////////////////////////////////////////
                            INTERNAL FUNCTIONS
    ////////////////////////////////////////////////////////////////*/

    function _generateName(SirStructs.VaultParameters calldata vaultParams) private view returns (string memory) {
        string memory leverageStr;
        if (vaultParams.leverageTier == -4) leverageStr = "1.0625";
        else if (vaultParams.leverageTier == -3) leverageStr = "1.125";
        else if (vaultParams.leverageTier == -2) leverageStr = "1.25";
        else if (vaultParams.leverageTier == -1) leverageStr = "1.5";
        else if (vaultParams.leverageTier == 0) leverageStr = "2";
        else if (vaultParams.leverageTier == 1) leverageStr = "3";
        else if (vaultParams.leverageTier == 2) leverageStr = "5";

        return
            string(
                abi.encodePacked(
                    "Tokenized ",
                    IERC20(vaultParams.collateralToken).symbol(),
                    "/",
                    IERC20(vaultParams.debtToken).symbol(),
                    " with ",
                    leverageStr,
                    "x leverage"
                )
            );
    }

    function _getReserves(
        SirStructs.VaultState memory vaultState,
        SirStructs.Reserves memory reserves,
        int8 leverageTier
    ) private pure {
        unchecked {
            if (vaultState.vaultId == 0) revert VaultDoesNotExist();

            // Reserve is empty only in the 1st mint
            if (vaultState.reserve != 0) {
                assert(vaultState.reserve >= 1e6);

                if (vaultState.tickPriceSatX42 == type(int64).min) {
                    // type(int64).min represents -∞ => reserveLPers = 0
                    reserves.reserveApes = vaultState.reserve - 1;
                    reserves.reserveLPers = 1;
                } else if (vaultState.tickPriceSatX42 == type(int64).max) {
                    // type(int64).max represents +∞ => reserveApes = 0
                    reserves.reserveApes = 1;
                    reserves.reserveLPers = vaultState.reserve - 1;
                } else {
                    bool isLeverageTierNonNegative = leverageTier >= 0;
                    uint8 absLeverageTier = isLeverageTierNonNegative ? uint8(leverageTier) : uint8(-leverageTier);

                    if (reserves.tickPriceX42 < vaultState.tickPriceSatX42) {
                        /**
                         * POWER ZONE
                         * A = (price/priceSat)^(l-1) R/l
                         * price = 1.0001^tickPriceX42 and priceSat = 1.0001^tickPriceSatX42
                         * We use the fact that l = 1+2^leverageTier
                         * reserveApes is rounded up
                         */
                        int256 poweredTickPriceDiffX42 = isLeverageTierNonNegative
                            ? (int256(vaultState.tickPriceSatX42) - reserves.tickPriceX42) << absLeverageTier
                            : (int256(vaultState.tickPriceSatX42) - reserves.tickPriceX42) >> absLeverageTier;

                        if (poweredTickPriceDiffX42 > SystemConstants.MAX_TICK_X42) {
                            reserves.reserveApes = 1;
                        } else {
                            /** Rounds up reserveApes, rounds down reserveLPers.
                                Cannot overflow.
                                64 bits because getRatioAtTick returns a Q64.64 number.
                            */
                            uint256 poweredPriceRatioX64 = TickMathPrecision.getRatioAtTick(
                                int64(poweredTickPriceDiffX42)
                            );

                            reserves.reserveApes = uint144(
                                _divRoundUp(
                                    uint256(vaultState.reserve) <<
                                        (isLeverageTierNonNegative ? 64 : 64 + absLeverageTier),
                                    poweredPriceRatioX64 + (poweredPriceRatioX64 << absLeverageTier)
                                )
                            );

                            if (reserves.reserveApes == vaultState.reserve) reserves.reserveApes--;
                            assert(reserves.reserveApes != 0); // It should never be 0 because it's rounded up. Important for the protocol that it is at least 1.
                        }

                        reserves.reserveLPers = vaultState.reserve - reserves.reserveApes;
                    } else {
                        /**
                         * SATURATION ZONE
                         * LPers are 100% pegged to debt token.
                         * L = (priceSat/price) R/r
                         * price = 1.0001^tickPriceX42 and priceSat = 1.0001^tickPriceSatX42
                         * We use the fact that lr = 1+2^-leverageTier
                         * reserveLPers is rounded up
                         */
                        int256 tickPriceDiffX42 = int256(reserves.tickPriceX42) - vaultState.tickPriceSatX42;

                        if (tickPriceDiffX42 > SystemConstants.MAX_TICK_X42) {
                            reserves.reserveLPers = 1;
                        } else {
                            /** Rounds up reserveLPers, rounds down reserveApes.
                                Cannot overflow.
                                64 bits because getRatioAtTick returns a Q64.64 number.
                            */
                            uint256 priceRatioX64 = TickMathPrecision.getRatioAtTick(int64(tickPriceDiffX42));

                            reserves.reserveLPers = uint144(
                                _divRoundUp(
                                    uint256(vaultState.reserve) <<
                                        (isLeverageTierNonNegative ? 64 + absLeverageTier : 64),
                                    priceRatioX64 + (priceRatioX64 << absLeverageTier)
                                )
                            );

                            if (reserves.reserveLPers == vaultState.reserve) reserves.reserveLPers--;
                            assert(reserves.reserveLPers != 0); // It should never be 0 because it's rounded up. Important for the protocol that it is at least 1.
                        }

                        reserves.reserveApes = vaultState.reserve - reserves.reserveLPers;
                    }
                }
            }
        }
    }

    function _divRoundUp(uint256 a, uint256 b) private pure returns (uint256) {
        unchecked {
            return (a - 1) / b + 1;
        }
    }
}