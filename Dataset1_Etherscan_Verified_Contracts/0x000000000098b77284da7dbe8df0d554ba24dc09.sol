// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.28;

contract NaniSignedDistributor {
    using SafeTransferLib for address;
    using SignatureCheckerLib for address;
    using SignatureCheckerLib for bytes32;

    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);

    address constant OPS = 0x0000000000001d8a2e7bf6bc369525A2654aa298;
    address constant DAO = 0xDa000000000000d2885F108500803dfBAaB2f2aA;
    address constant NANI = 0x00000000000007C8612bA63Df8DdEfD9E6077c97;

    address public owner;

    mapping(uint256 id => bool) public settled;

    error Unauthorized();
    error DeadlinePassed();
    error AlreadySettled();

    constructor() payable {
        owner = tx.origin;
    }

    function settle(
        address to,
        uint256 nani,
        uint256 deadline,
        uint256 id,
        bytes calldata signature
    ) public payable {
        if (block.timestamp > deadline) revert DeadlinePassed();
        if (settled[id]) revert AlreadySettled();
        settled[id] = true;
        if (
            owner.isValidSignatureNowCalldata(
                keccak256(
                    abi.encodePacked(
                        to, msg.value, nani, deadline, id, address(this), block.chainid
                    )
                ).toEthSignedMessageHash(),
                signature
            )
        ) {
            DAO.safeTransferETH(msg.value);
            NANI.safeTransferFrom(OPS, to, nani);
        } else {
            revert Unauthorized();
        }
    }

    function transferOwnership(address newOwner) public payable {
        if (msg.sender != owner) revert Unauthorized();
        emit OwnershipTransferred(msg.sender, owner = newOwner);
    }
}

library SignatureCheckerLib {
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32 result) {
        assembly ("memory-safe") {
            mstore(0x20, hash) // Store into scratch space for keccak256.
            mstore(0x00, "\x00\x00\x00\x00\x19Ethereum Signed Message:\n32") // 28 bytes.
            result := keccak256(0x04, 0x3c) // `32 * 2 - (32 - 28) = 60 = 0x3c`.
        }
    }

    function isValidSignatureNowCalldata(address signer, bytes32 hash, bytes calldata signature)
        internal
        view
        returns (bool isValid)
    {
        if (signer == address(0)) return isValid;
        assembly ("memory-safe") {
            let m := mload(0x40)
            for {} 1 {} {
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
            if iszero(isValid) {
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
    }
}

library SafeTransferLib {
    function safeTransferETH(address to, uint256 amount) internal {
        assembly ("memory-safe") {
            if iszero(call(gas(), to, amount, codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, 0xb12d13eb) // `ETHTransferFailed()`.
                revert(0x1c, 0x04)
            }
        }
    }

    function safeTransferFrom(address token, address from, address to, uint256 amount) internal {
        assembly ("memory-safe") {
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
}