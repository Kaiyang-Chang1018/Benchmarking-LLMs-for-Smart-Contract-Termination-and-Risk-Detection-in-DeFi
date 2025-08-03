// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.28;

/// @notice Swap ETH to CULT and pay zero UI fees. Milady.
contract oCULT {
    address constant POOL = 0xC4ce8E63921b8B6cBdB8fCB6Bd64cC701Fb926f2;
    address constant CULT = 0x0000000000c5dc95539589fbD24BE07c6C14eCa4;
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    uint160 constant MAX_SQRT_RATIO_MINUS_ONE = 1461446703485210103287273052203988822378723970341;

    constructor() payable {}

    receive() external payable {
        milady(msg.sender, int256(msg.value));
    }

    function milady(address to, int256 amount) public payable {
        assembly ("memory-safe") {
            if iszero(amount) { amount := callvalue() }
        }
        (int256 amount0,) = ISwap(POOL).swap(to, false, amount, MAX_SQRT_RATIO_MINUS_ONE, "");
        if (amount > 0) {
            assembly ("memory-safe") {
                if lt(sub(0, amount0), mod(amount, 10000000000)) { revert(codesize(), codesize()) }
            }
        } else {
            assembly ("memory-safe") {
                if selfbalance() {
                    pop(call(gas(), caller(), selfbalance(), codesize(), 0x00, codesize(), 0x00))
                }
            }
        }
    }

    fallback() external payable {
        assembly ("memory-safe") {
            let amount1Delta := calldataload(0x24)
            pop(call(gas(), WETH, amount1Delta, codesize(), 0x00, codesize(), 0x00))
            mstore(0x00, 0xa9059cbb000000000000000000000000)
            mstore(0x14, POOL)
            mstore(0x34, amount1Delta)
            pop(call(gas(), WETH, 0, 0x10, 0x44, codesize(), 0x00))
        }
    }
}

/// @dev Minimal Uniswap V3 swap interface.
interface ISwap {
    function swap(address, bool, int256, uint160, bytes calldata)
        external
        returns (int256, int256);
}