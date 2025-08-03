// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Contract that enables a single call to call multiple methods on itself.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/Multicallable.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/Multicallable.sol)
abstract contract Multicallable {
    /// @dev Apply `DELEGATECALL` with the current contract to each calldata in `data`,
    /// and store the `abi.encode` formatted results of each `DELEGATECALL` into `results`.
    /// If any of the `DELEGATECALL`s reverts, the entire context is reverted,
    /// and the error is bubbled up.
    ///
    /// This function is deliberately made non-payable to guard against double-spending.
    /// (See: https://www.paradigm.xyz/2021/08/two-rights-might-make-a-wrong)
    ///
    /// For efficiency, this function will directly return the results, terminating the context.
    /// If called internally, it must be called at the end of a function
    /// that returns `(bytes[] memory)`.
    function multicall(bytes[] calldata data) public virtual returns (bytes[] memory) {
        assembly {
            mstore(0x00, 0x20)
            mstore(0x20, data.length) // Store `data.length` into `results`.
            // Early return if no data.
            if iszero(data.length) { return(0x00, 0x40) }

            let results := 0x40
            // `shl` 5 is equivalent to multiplying by 0x20.
            let end := shl(5, data.length)
            // Copy the offsets from calldata into memory.
            calldatacopy(0x40, data.offset, end)
            // Offset into `results`.
            let resultsOffset := end
            // Pointer to the end of `results`.
            end := add(results, end)

            for {} 1 {} {
                // The offset of the current bytes in the calldata.
                let o := add(data.offset, mload(results))
                let memPtr := add(resultsOffset, 0x40)
                // Copy the current bytes from calldata to the memory.
                calldatacopy(
                    memPtr,
                    add(o, 0x20), // The offset of the current bytes' bytes.
                    calldataload(o) // The length of the current bytes.
                )
                if iszero(delegatecall(gas(), address(), memPtr, calldataload(o), 0x00, 0x00)) {
                    // Bubble up the revert if the delegatecall reverts.
                    returndatacopy(0x00, 0x00, returndatasize())
                    revert(0x00, returndatasize())
                }
                // Append the current `resultsOffset` into `results`.
                mstore(results, resultsOffset)
                results := add(results, 0x20)
                // Append the `returndatasize()`, and the return data.
                mstore(memPtr, returndatasize())
                returndatacopy(add(memPtr, 0x20), 0x00, returndatasize())
                // Advance the `resultsOffset` by `returndatasize() + 0x20`,
                // rounded up to the next multiple of 32.
                resultsOffset :=
                    and(add(add(resultsOffset, returndatasize()), 0x3f), 0xffffffffffffffe0)
                if iszero(lt(results, end)) { break }
            }
            return(0x00, add(resultsOffset, 0x40))
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Safe ETH and ERC20 transfer library that gracefully handles missing return values.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/SafeTransferLib.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/SafeTransferLib.sol)
/// @dev Caution! This library won't check that a token has code, responsibility is delegated to the caller.
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

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         CONSTANTS                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Suggested gas stipend for contract receiving ETH
    /// that disallows any storage writes.
    uint256 internal constant _GAS_STIPEND_NO_STORAGE_WRITES = 2300;

    /// @dev Suggested gas stipend for contract receiving ETH to perform a few
    /// storage reads and writes, but low enough to prevent griefing.
    /// Multiply by a small constant (e.g. 2), if needed.
    uint256 internal constant _GAS_STIPEND_NO_GRIEF = 100000;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       ETH OPERATIONS                       */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Sends `amount` (in wei) ETH to `to`.
    /// Reverts upon failure.
    function safeTransferETH(address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            // Transfer the ETH and check if it succeeded or not.
            if iszero(call(gas(), to, amount, 0, 0, 0, 0)) {
                // Store the function selector of `ETHTransferFailed()`.
                mstore(0x00, 0xb12d13eb)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }
        }
    }

    /// @dev Force sends `amount` (in wei) ETH to `to`, with a `gasStipend`.
    /// The `gasStipend` can be set to a low enough value to prevent
    /// storage writes or gas griefing.
    ///
    /// If sending via the normal procedure fails, force sends the ETH by
    /// creating a temporary contract which uses `SELFDESTRUCT` to force send the ETH.
    ///
    /// Reverts if the current contract has insufficient balance.
    function forceSafeTransferETH(address to, uint256 amount, uint256 gasStipend) internal {
        /// @solidity memory-safe-assembly
        assembly {
            // If insufficient balance, revert.
            if lt(selfbalance(), amount) {
                // Store the function selector of `ETHTransferFailed()`.
                mstore(0x00, 0xb12d13eb)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }
            // Transfer the ETH and check if it succeeded or not.
            if iszero(call(gasStipend, to, amount, 0, 0, 0, 0)) {
                mstore(0x00, to) // Store the address in scratch space.
                mstore8(0x0b, 0x73) // Opcode `PUSH20`.
                mstore8(0x20, 0xff) // Opcode `SELFDESTRUCT`.
                // We can directly use `SELFDESTRUCT` in the contract creation.
                // Compatible with `SENDALL`: https://eips.ethereum.org/EIPS/eip-4758
                if iszero(create(amount, 0x0b, 0x16)) {
                    // For better gas estimation.
                    if iszero(gt(gas(), 1000000)) { revert(0, 0) }
                }
            }
        }
    }

    /// @dev Force sends `amount` (in wei) ETH to `to`, with a gas stipend
    /// equal to `_GAS_STIPEND_NO_GRIEF`. This gas stipend is a reasonable default
    /// for 99% of cases and can be overriden with the three-argument version of this
    /// function if necessary.
    ///
    /// If sending via the normal procedure fails, force sends the ETH by
    /// creating a temporary contract which uses `SELFDESTRUCT` to force send the ETH.
    ///
    /// Reverts if the current contract has insufficient balance.
    function forceSafeTransferETH(address to, uint256 amount) internal {
        // Manually inlined because the compiler doesn't inline functions with branches.
        /// @solidity memory-safe-assembly
        assembly {
            // If insufficient balance, revert.
            if lt(selfbalance(), amount) {
                // Store the function selector of `ETHTransferFailed()`.
                mstore(0x00, 0xb12d13eb)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }
            // Transfer the ETH and check if it succeeded or not.
            if iszero(call(_GAS_STIPEND_NO_GRIEF, to, amount, 0, 0, 0, 0)) {
                mstore(0x00, to) // Store the address in scratch space.
                mstore8(0x0b, 0x73) // Opcode `PUSH20`.
                mstore8(0x20, 0xff) // Opcode `SELFDESTRUCT`.
                // We can directly use `SELFDESTRUCT` in the contract creation.
                // Compatible with `SENDALL`: https://eips.ethereum.org/EIPS/eip-4758
                if iszero(create(amount, 0x0b, 0x16)) {
                    // For better gas estimation.
                    if iszero(gt(gas(), 1000000)) { revert(0, 0) }
                }
            }
        }
    }

    /// @dev Sends `amount` (in wei) ETH to `to`, with a `gasStipend`.
    /// The `gasStipend` can be set to a low enough value to prevent
    /// storage writes or gas griefing.
    ///
    /// Simply use `gasleft()` for `gasStipend` if you don't need a gas stipend.
    ///
    /// Note: Does NOT revert upon failure.
    /// Returns whether the transfer of ETH is successful instead.
    function trySafeTransferETH(address to, uint256 amount, uint256 gasStipend)
        internal
        returns (bool success)
    {
        /// @solidity memory-safe-assembly
        assembly {
            // Transfer the ETH and check if it succeeded or not.
            success := call(gasStipend, to, amount, 0, 0, 0, 0)
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

            // Store the function selector of `transferFrom(address,address,uint256)`.
            mstore(0x00, 0x23b872dd)
            mstore(0x20, from) // Store the `from` argument.
            mstore(0x40, to) // Store the `to` argument.
            mstore(0x60, amount) // Store the `amount` argument.

            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    // Set success to whether the call reverted, if not we check it either
                    // returned exactly 1 (can't just be non-zero data), or had no return data.
                    or(eq(mload(0x00), 1), iszero(returndatasize())),
                    call(gas(), token, 0, 0x1c, 0x64, 0x00, 0x20)
                )
            ) {
                // Store the function selector of `TransferFromFailed()`.
                mstore(0x00, 0x7939f424)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }

            mstore(0x60, 0) // Restore the zero slot to zero.
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Sends all of ERC20 `token` from `from` to `to`.
    /// Reverts upon failure.
    ///
    /// The `from` account must have at least `amount` approved for
    /// the current contract to manage.
    function safeTransferAllFrom(address token, address from, address to)
        internal
        returns (uint256 amount)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.

            mstore(0x00, 0x70a08231) // Store the function selector of `balanceOf(address)`.
            mstore(0x20, from) // Store the `from` argument.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    gt(returndatasize(), 0x1f), // At least 32 bytes returned.
                    staticcall(gas(), token, 0x1c, 0x24, 0x60, 0x20)
                )
            ) {
                // Store the function selector of `TransferFromFailed()`.
                mstore(0x00, 0x7939f424)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }

            // Store the function selector of `transferFrom(address,address,uint256)`.
            mstore(0x00, 0x23b872dd)
            mstore(0x40, to) // Store the `to` argument.
            // The `amount` argument is already written to the memory word at 0x6a.
            amount := mload(0x60)

            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    // Set success to whether the call reverted, if not we check it either
                    // returned exactly 1 (can't just be non-zero data), or had no return data.
                    or(eq(mload(0x00), 1), iszero(returndatasize())),
                    call(gas(), token, 0, 0x1c, 0x64, 0x00, 0x20)
                )
            ) {
                // Store the function selector of `TransferFromFailed()`.
                mstore(0x00, 0x7939f424)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
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
            mstore(0x1a, to) // Store the `to` argument.
            mstore(0x3a, amount) // Store the `amount` argument.
            // Store the function selector of `transfer(address,uint256)`,
            // left by 6 bytes (enough for 8tb of memory represented by the free memory pointer).
            // We waste 6-3 = 3 bytes to save on 6 runtime gas (PUSH1 0x224 SHL).
            mstore(0x00, 0xa9059cbb000000000000)

            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    // Set success to whether the call reverted, if not we check it either
                    // returned exactly 1 (can't just be non-zero data), or had no return data.
                    or(eq(mload(0x00), 1), iszero(returndatasize())),
                    call(gas(), token, 0, 0x16, 0x44, 0x00, 0x20)
                )
            ) {
                // Store the function selector of `TransferFailed()`.
                mstore(0x00, 0x90b8ec18)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }
            // Restore the part of the free memory pointer that was overwritten,
            // which is guaranteed to be zero, if less than 8tb of memory is used.
            mstore(0x3a, 0)
        }
    }

    /// @dev Sends all of ERC20 `token` from the current contract to `to`.
    /// Reverts upon failure.
    function safeTransferAll(address token, address to) internal returns (uint256 amount) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, 0x70a08231) // Store the function selector of `balanceOf(address)`.
            mstore(0x20, address()) // Store the address of the current contract.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    gt(returndatasize(), 0x1f), // At least 32 bytes returned.
                    staticcall(gas(), token, 0x1c, 0x24, 0x3a, 0x20)
                )
            ) {
                // Store the function selector of `TransferFailed()`.
                mstore(0x00, 0x90b8ec18)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }

            mstore(0x1a, to) // Store the `to` argument.
            // The `amount` argument is already written to the memory word at 0x3a.
            amount := mload(0x3a)
            // Store the function selector of `transfer(address,uint256)`,
            // left by 6 bytes (enough for 8tb of memory represented by the free memory pointer).
            // We waste 6-3 = 3 bytes to save on 6 runtime gas (PUSH1 0x224 SHL).
            mstore(0x00, 0xa9059cbb000000000000)

            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    // Set success to whether the call reverted, if not we check it either
                    // returned exactly 1 (can't just be non-zero data), or had no return data.
                    or(eq(mload(0x00), 1), iszero(returndatasize())),
                    call(gas(), token, 0, 0x16, 0x44, 0x00, 0x20)
                )
            ) {
                // Store the function selector of `TransferFailed()`.
                mstore(0x00, 0x90b8ec18)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }
            // Restore the part of the free memory pointer that was overwritten,
            // which is guaranteed to be zero, if less than 8tb of memory is used.
            mstore(0x3a, 0)
        }
    }

    /// @dev Sets `amount` of ERC20 `token` for `to` to manage on behalf of the current contract.
    /// Reverts upon failure.
    function safeApprove(address token, address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x1a, to) // Store the `to` argument.
            mstore(0x3a, amount) // Store the `amount` argument.
            // Store the function selector of `approve(address,uint256)`,
            // left by 6 bytes (enough for 8tb of memory represented by the free memory pointer).
            // We waste 6-3 = 3 bytes to save on 6 runtime gas (PUSH1 0x224 SHL).
            mstore(0x00, 0x095ea7b3000000000000)

            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    // Set success to whether the call reverted, if not we check it either
                    // returned exactly 1 (can't just be non-zero data), or had no return data.
                    or(eq(mload(0x00), 1), iszero(returndatasize())),
                    call(gas(), token, 0, 0x16, 0x44, 0x00, 0x20)
                )
            ) {
                // Store the function selector of `ApproveFailed()`.
                mstore(0x00, 0x3e3f8f73)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }
            // Restore the part of the free memory pointer that was overwritten,
            // which is guaranteed to be zero, if less than 8tb of memory is used.
            mstore(0x3a, 0)
        }
    }

    /// @dev Returns the amount of ERC20 `token` owned by `account`.
    /// Returns zero if the `token` does not exist.
    function balanceOf(address token, address account) internal view returns (uint256 amount) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, 0x70a08231) // Store the function selector of `balanceOf(address)`.
            mstore(0x20, account) // Store the `account` argument.
            amount :=
                mul(
                    mload(0x20),
                    and( // The arguments of `and` are evaluated from right to left.
                        gt(returndatasize(), 0x1f), // At least 32 bytes returned.
                        staticcall(gas(), token, 0x1c, 0x24, 0x20, 0x20)
                    )
                )
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
            mstore(add(freeMemoryPointer, 4), from) // Append the "from" argument.
            mstore(add(freeMemoryPointer, 36), to) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 68), amount) // Append the "amount" argument.

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
            mstore(add(freeMemoryPointer, 4), to) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument.

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
            mstore(add(freeMemoryPointer, 4), to) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument.

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
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.17;

import {Owned} from "solmate/auth/Owned.sol";
import {AddressHelper} from "src/libraries/AddressHelper.sol";
import {ERC20, SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";

/// @notice Claim all rewards for a given platform.
abstract contract Auth is Owned {
    /// @notice Throwed the caller is not an approved manager.
    error NOT_ALLOWED_MANAGER();

    /// @notice Addresses of the approved managers.
    mapping(address => bool) public allowListManagers;

    ////////////////////////////////////////////////////////////////
    /// --- EVENTS
    ///////////////////////////////////////////////////////////////

    /// @notice Emitted when a manager is approved.
    /// @param manager The address of the manager.
    event ManagerAllowed(address indexed manager);

    /// @notice Emitted when a manager is disowned.
    /// @param manager The address of the manager.
    event ManagerDisowned(address indexed manager);

    modifier onlyAllowed() {
        if (!allowListManagers[msg.sender]) revert NOT_ALLOWED_MANAGER();
        _;
    }

    constructor(address _owner) Owned(_owner) {
        allowListManagers[_owner] = true;
    }

    /// @notice Approve a manager.
    /// @param _manager The manager to approve.
    function approveManager(address _manager) external onlyOwner {
        allowListManagers[_manager] = true;
        emit ManagerAllowed(_manager);
    }

    /// @notice Disown a manager.
    /// @param _manager The manager to disown.
    function disownManager(address _manager) external onlyOwner {
        allowListManagers[_manager] = false;
        emit ManagerDisowned(_manager);
    }
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.17;

import {Auth} from "src/Auth.sol";
import {Owned} from "solmate/auth/Owned.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {Multicallable} from "solady/utils/Multicallable.sol";
import {SafeTransferLib} from "solady/utils/SafeTransferLib.sol";

import "src/interfaces/IBalancerVault.sol";
import {IVotemarket} from "src/interfaces/IVM.sol";
import {ICurvePool} from "src/interfaces/ICurvePool.sol";

interface GPv2Settlement {
    function setPreSignature(bytes calldata, bool signed) external;
}

/// @title  BotMarket
/// @notice Helper contract to swap bribes rewards for distribution.
/// @author Stake DAO
contract BotMarket is Auth, Multicallable {
    function getVersion() external pure returns (string memory) {
        return "0.0.1";
    }

    ////////////////////////////////////////////////////////////////
    /// --- CONSTANTS
    ///////////////////////////////////////////////////////////////

    /// Common addresses.

    /// @notice WETH address.
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    /// @notice ETH address.
    address public constant _ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    /// @notice AugustusSwapper contract address.
    address public constant AUGUSTUS = 0xDEF171Fe48CF0115B1d80b88dc8eAB59176FEe57;

    /// @notice Paraswap Token pull contract address.
    address public constant TOKEN_TRANSFER_PROXY = 0x216B4B4Ba9F3e719726886d34a177484278Bfcae;

    /// @notice GPv2Settlement contract address.
    address public constant GPV2_SETTLEMENT = 0x9008D19f58AAbD9eD0D60971565AA8510560ab41;

    /// Balancer addresses.

    /// @notice BAL token address.
    address public constant BAL = 0xba100000625a3754423978a60c9317c58a424e3D;

    /// @notice Address of Balancer contract.
    address public constant BALANCER_VAULT = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;

    /// @notice Helper address to fetch quotes.
    address public constant BALANCER_QUERIES = 0xE39B5e3B6D74016b2F6A9673D7d7493B6DF549d5;

    /// @notice Pool BAL/ETH token address.
    address public constant B_80BAL_20WETH = 0x5c6Ee304399DBdB9C8Ef030aB642B10820DB8F56;

    /// @notice Pool ID BAL/ETH token address.
    bytes32 public constant B_80BAL_20WETH_POOL_ID = 0x5c6ee304399dbdb9c8ef030ab642b10820db8f56000200000000000000000014;

    /// @notice Pool ID SD_BALH token address.
    bytes32 public constant SD_BAL_80BAL_20WETH_POOL_ID =
        0x2d011adf89f0576c9b722c28269fcb5d50c2d17900020000000000000000024d;

    /// SD Tokens addresses.

    /// @notice SD FXS address.
    address public constant SD_FXS = 0x402F878BDd1f5C66FdAF0fabaBcF74741B68ac36;

    /// @notice SD CRV address.
    address public constant SD_CRV = 0xD1b5651E55D4CeeD36251c61c50C889B36F6abB5;

    /// @notice SD BAL address.
    address public constant SD_BAL = 0xF24d8651578a55b0C119B9910759a351A3458895;

    /// @notice SD ANGLE address.
    address public constant SD_ANGLE = 0x31429d1856aD1377A8A0079410B297e1a9e214c2;

    /// @notice Addresses of the pools for each market.
    mapping(address => address) public marketPools;

    address public immutable treasury;

    ////////////////////////////////////////////////////////////////
    /// --- ERRORS
    ///////////////////////////////////////////////////////////////

    /// @notice Throwed when a call fails.
    error CALL_FAILED();

    /// @notice Throwed when a swap fails.
    error SWAP_FAILED();

    /// @notice Throwed when
    error WRONG_MARKET();

    ////////////////////////////////////////////////////////////////
    /// --- EVENTS
    ///////////////////////////////////////////////////////////////

    /// @notice Emitted when a trade is executed.
    /// @param srcToken The token to exchange from.
    /// @param destToken The token to exchange to.
    /// @param srcAmount The amount of srcToken to exchange.
    /// @param destAmount The amount of destToken received.
    event ExchangeAggregator(
        address indexed srcToken, address indexed destToken, uint256 srcAmount, uint256 destAmount
    );

    ////////////////////////////////////////////////////////////////
    /// --- MODIFIERS
    ///////////////////////////////////////////////////////////////

    constructor(address _owner, address _treasury) Auth(_owner) {
        treasury = _treasury;
    }

    ////////////////////////////////////////////////////////////////
    /// --- EXTERNAL FUNCTIONS
    ///////////////////////////////////////////////////////////////

    function claimAll(address platform, address locker, uint256[] calldata ids) external onlyAllowed {
        IVotemarket(platform).claimAllFor(locker, ids);
    }

    function setPresignature(address token, bytes calldata orderUid) external onlyAllowed {
        approveIfNeeded(token, GPV2_SETTLEMENT);
        GPv2Settlement(GPV2_SETTLEMENT).setPreSignature(orderUid, true);
    }

    function handleCurveMarket(address market, address token, uint256 amount, uint256 minAmountOut)
        external
        onlyAllowed
        returns (uint256 _received)
    {
        /// Swap to sdToken
        if (market == SD_BAL) {
            revert WRONG_MARKET();
        }
        _received = _swapForSdToken(market, token, amount, minAmountOut);
    }

    function handleBalancerMarket(uint256 amount, uint256 minAmountOut, uint256 minLiquidityAmount, uint256 deadline)
        external
        onlyAllowed
        returns (uint256 _received)
    {
        _received = _swapForSdBAL(amount, minLiquidityAmount, minAmountOut, deadline);
    }

    /// @notice Exchanges tokens using 0x.
    /// @param srcToken The token to exchange from.
    /// @param destToken The token to exchange to.
    /// @param underlyingAmount The amount of srcToken to exchange.
    /// @param callData The calldata to use for the exchange.
    function exchange(address srcToken, address destToken, uint256 underlyingAmount, bytes memory callData)
        external
        payable
        onlyAllowed
        returns (uint256 received)
    {
        return _handleAggregator(srcToken, destToken, underlyingAmount, callData);
    }

    /// @notice Used to withdraw tokens from the contract.
    /// @param _tokens The tokens to withdraw.
    /// @param _amounts The amounts to withdraw.
    function withdraw(address[] calldata _tokens, uint256[] calldata _amounts) external onlyAllowed {
        for (uint256 i = 0; i < _tokens.length; i++) {
            SafeTransferLib.safeTransfer(_tokens[i], treasury, _amounts[i]);
        }
    }

    ////////////////////////////////////////////////////////////////
    /// --- INTERNAL IMPLEMENTATION
    ///////////////////////////////////////////////////////////////

    /// @notice Swaps tokens to sdTokens.
    /// @param underlyingAmount The amount of srcToken to exchange.
    /// @param minAmountOut The minimum amount of sdToken to receive.
    function _swapForSdToken(address market, address token, uint256 underlyingAmount, uint256 minAmountOut)
        internal
        returns (uint256 _received)
    {
        address pool = marketPools[market];

        // Approve the pool to spend the underlying token
        approveIfNeeded(token, pool);

        _received = ERC20(market).balanceOf(address(this));

        if (underlyingAmount == type(uint256).max) {
            underlyingAmount = ERC20(token).balanceOf(address(this));
        }

        // Swap the underlying token for the sdToken
        ICurvePool(pool).exchange(0, 1, underlyingAmount, minAmountOut);

        // Calculate the amount of sdToken received
        _received = ERC20(market).balanceOf(address(this)) - _received;
    }

    /// @notice Swaps BAL for sdBAL.
    /// @param minAmountOut The minimum amount of sdBAL to receive.
    /// @param deadline The deadline for the swap.
    function _swapForSdBAL(uint256 underlyingAmount, uint256 minLiquidityAmount, uint256 minAmountOut, uint256 deadline)
        internal
        returns (uint256 _received)
    {
        if (underlyingAmount == type(uint256).max) {
            underlyingAmount = ERC20(BAL).balanceOf(address(this));
        }

        underlyingAmount = _joinBALPool(underlyingAmount, minLiquidityAmount);

        // Approve the pool to spend the underlying token
        SafeTransferLib.safeApprove(B_80BAL_20WETH, BALANCER_VAULT, underlyingAmount);

        SingleSwap memory singleSwap = SingleSwap({
            poolId: SD_BAL_80BAL_20WETH_POOL_ID,
            kind: SwapKind.GIVEN_IN,
            assetIn: B_80BAL_20WETH,
            assetOut: SD_BAL,
            amount: underlyingAmount,
            userData: ""
        });

        FundManagement memory fundManagement = FundManagement({
            sender: address(this),
            fromInternalBalance: false,
            recipient: payable(address(this)),
            toInternalBalance: false
        });

        // Swap the underlying token for the sdToken
        _received = IBalancerVault(BALANCER_VAULT).swap(singleSwap, fundManagement, minAmountOut, deadline);
    }

    function _joinBALPool(uint256 underlyingAmount, uint256 minLiquidityAmount) internal returns (uint256 _received) {
        // Approve the pool to spend the underlying token
        approveIfNeeded(BAL, BALANCER_VAULT);

        address[] memory tokens = new address[](2);
        tokens[0] = BAL;
        tokens[1] = WETH;

        uint256[] memory maxAmountsIn = new uint256[](2);
        maxAmountsIn[0] = underlyingAmount;
        maxAmountsIn[1] = 0;

        JoinPoolRequest memory joinRequest = JoinPoolRequest({
            assets: tokens,
            maxAmountsIn: maxAmountsIn,
            userData: abi.encode(JoinKind.EXACT_TOKENS_IN_FOR_BPT_OUT, maxAmountsIn, minLiquidityAmount),
            fromInternalBalance: false
        });

        IBalancerVault(BALANCER_VAULT).joinPool(B_80BAL_20WETH_POOL_ID, address(this), address(this), joinRequest);

        _received = ERC20(B_80BAL_20WETH).balanceOf(address(this));
    }

    /// @notice Swaps tokens using 0x.
    /// @param srcToken The token to exchange from.
    /// @param destToken The token to exchange to.
    /// @param underlyingAmount The amount of srcToken to exchange.
    /// @param callData The calldata to use for the exchange.
    function _handleAggregator(address srcToken, address destToken, uint256 underlyingAmount, bytes memory callData)
        internal
        returns (uint256 received)
    {
        bool success;
        /// Checkpoint the balance of the destination token before the swap.
        uint256 before = destToken == _ETH ? address(this).balance : ERC20(destToken).balanceOf(address(this));

        if (srcToken == _ETH) {
            (success,) = AUGUSTUS.call{value: underlyingAmount}(callData);
        } else {
            approveIfNeeded(srcToken, TOKEN_TRANSFER_PROXY);
            (success,) = AUGUSTUS.call(callData);
        }

        if (!success) revert SWAP_FAILED();

        /// Checkpoint the balance of the destination token after the swap.
        /// Get the amount of destination token received.
        if (destToken == _ETH) {
            received = address(this).balance - before;
        } else {
            received = ERC20(destToken).balanceOf(address(this)) - before;
        }

        emit ExchangeAggregator(srcToken, destToken, underlyingAmount, received);
    }

    function approveIfNeeded(address _token, address _spender) internal {
        if (ERC20(_token).allowance(address(this), _spender) == 0) {
            SafeTransferLib.safeApprove(_token, _spender, type(uint256).max);
        }
    }
    ////////////////////////////////////////////////////////////////
    /// --- VIEWS FUNCTIONS
    ///////////////////////////////////////////////////////////////

    function getBalancerLiquidityQuote(uint256 underlyingAmount) public returns (uint256 _liquidityQuote) {
        address[] memory tokens = new address[](2);
        tokens[0] = BAL;
        tokens[1] = WETH;

        uint256[] memory maxAmountsIn = new uint256[](2);
        maxAmountsIn[0] = underlyingAmount;
        maxAmountsIn[1] = 0;

        JoinPoolRequest memory joinRequest = JoinPoolRequest({
            assets: tokens,
            maxAmountsIn: maxAmountsIn,
            userData: abi.encode(JoinKind.EXACT_TOKENS_IN_FOR_BPT_OUT, maxAmountsIn, 0),
            fromInternalBalance: false
        });

        (_liquidityQuote,) = IBalancerVault(BALANCER_QUERIES).queryJoin(
            B_80BAL_20WETH_POOL_ID, address(this), address(this), joinRequest
        );
    }

    function getBalancerSwapQuote(uint256 underlyingAmount) public returns (uint256) {
        SingleSwap memory singleSwap = SingleSwap({
            poolId: SD_BAL_80BAL_20WETH_POOL_ID,
            kind: SwapKind.GIVEN_IN,
            assetIn: B_80BAL_20WETH,
            assetOut: SD_BAL,
            amount: underlyingAmount,
            userData: ""
        });

        FundManagement memory fundManagement = FundManagement({
            sender: address(this),
            fromInternalBalance: false,
            recipient: payable(address(this)),
            toInternalBalance: false
        });

        return IBalancerVault(BALANCER_QUERIES).querySwap(singleSwap, fundManagement);
    }

    function getCurveQuote(address pool, int128 x, int128 y, uint256 amount) public view returns (uint256 _quote) {
        return ICurvePool(pool).get_dy(x, y, amount);
    }

    ////////////////////////////////////////////////////////////////
    /// --- AUTHORIZATION
    ///////////////////////////////////////////////////////////////

    function setMarketPool(address _market, address _pool) external onlyOwner {
        marketPools[_market] = _pool;
    }

    function resetAllowance(address _token, address _spender) external onlyOwner {
        SafeTransferLib.safeApprove(_token, _spender, 0);
    }

    receive() external payable {}
}
// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.17;

struct JoinPoolRequest {
    address[] assets;
    uint256[] maxAmountsIn;
    bytes userData;
    bool fromInternalBalance;
}

struct SingleSwap {
    bytes32 poolId;
    SwapKind kind;
    address assetIn;
    address assetOut;
    uint256 amount;
    bytes userData;
}

struct FundManagement {
    address sender;
    bool fromInternalBalance;
    address payable recipient;
    bool toInternalBalance;
}

enum SwapKind {
    GIVEN_IN,
    GIVEN_OUT
}

enum JoinKind {
    INIT,
    EXACT_TOKENS_IN_FOR_BPT_OUT,
    TOKEN_IN_FOR_EXACT_BPT_OUT,
    EXACT_BPT_IN_FOR_TOKENS_OUT
}

interface IBalancerVault {
    function joinPool(bytes32 _poolId, address _sender, address _recipient, JoinPoolRequest memory _request)
        external
        payable;

    function swap(SingleSwap memory singleSwap, FundManagement memory funds, uint256 limit, uint256 deadline)
        external
        payable
        returns (uint256);

    function querySwap(SingleSwap memory singleSwap, FundManagement memory funds) external returns (uint256);

    function queryJoin(bytes32 poolId, address sender, address recipient, JoinPoolRequest memory request)
        external
        returns (uint256 bptOut, uint256[] memory amountsIn);
}
// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.17;

interface ICurvePool {
    function exchange(int128 i, int128 j, uint256 dx, uint256 min_dy) external;
    function get_dy(int128 i, int128 j, uint256 dx) external view returns (uint256);
    function exchange_underlying(int128 i, int128 j, uint256 dx, uint256 min_dy) external;
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.17;

interface IVotemarket {
    /// @notice Bribe struct requirements.
    struct Bribe {
        // Address of the target gauge.
        address gauge;
        // Manager.
        address manager;
        // Address of the ERC20 used for rewards.
        address rewardToken;
        // Number of periods.
        uint8 numberOfPeriods;
        // Timestamp where the bribe become unclaimable.
        uint256 endTimestamp;
        // Max Price per vote.
        uint256 maxRewardPerVote;
        // Total Reward Added.
        uint256 totalRewardAmount;
        // Blacklisted addresses.
        address[] blacklist;
    }

    function nextID() external view returns (uint256);
    function claimAllFor(address _user, uint256[] calldata ids) external;
    function getBribe(uint256 bribeId) external view returns (Bribe memory);
    function claimable(address user, uint256 bribeId) external view returns (uint256 amount);
    function setRecipientFor(address _user, address _recipient) external;
    function owner() external view returns (address);
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.17;

library AddressHelper {
    ////////////////////////////////////////////////////////////////
    /// --- COMMON CONSTANTS
    ///////////////////////////////////////////////////////////////

    /// @notice WETH address.
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    /// @notice ETH address.
    address internal constant _ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    /// @notice AugustusSwapper contract address.
    address public constant AUGUSTUS = 0xDEF171Fe48CF0115B1d80b88dc8eAB59176FEe57;

    /// @notice Paraswap Token pull contract address.
    address public constant TOKEN_TRANSFER_PROXY = 0x216B4B4Ba9F3e719726886d34a177484278Bfcae;

    /// @notice Address of Balancer contract.
    address public constant BALANCER_VAULT = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;

    /// @notice CRV token address.
    address public constant CRV = 0xD533a949740bb3306d119CC777fa900bA034cd52;

    /// @notice BAL token address.
    address public constant BAL = 0xba100000625a3754423978a60c9317c58a424e3D;

    /// @notice Pool BAL/ETH token address.
    address public constant B_80BAL_20WETH = 0x5c6Ee304399DBdB9C8Ef030aB642B10820DB8F56;

    /// @notice Pool ID BAL/ETH token address.
    bytes32 public constant B_80BAL_20WETH_POOL_ID = 0x5c6ee304399dbdb9c8ef030ab642b10820db8f56000200000000000000000014;

    /// @notice Pool ID SD_BALH token address.
    bytes32 public constant SD_BAL_80BAL_20WETH_POOL_ID =
        0x2d011adf89f0576c9b722c28269fcb5d50c2d17900020000000000000000024d;

    ////////////////////////////////////////////////////////////////
    /// --- MARKET CONSTANTS
    ///////////////////////////////////////////////////////////////

    address public constant SD_FXS = 0x402F878BDd1f5C66FdAF0fabaBcF74741B68ac36;

    address public constant SD_CRV = 0xD1b5651E55D4CeeD36251c61c50C889B36F6abB5;

    address public constant SD_CRV_POOL = 0xf7b55C3732aD8b2c2dA7c24f30A69f55c54FB717;

    address public constant SD_BAL = 0xF24d8651578a55b0C119B9910759a351A3458895;

    address public constant SD_ANGLE = 0x31429d1856aD1377A8A0079410B297e1a9e214c2;
}