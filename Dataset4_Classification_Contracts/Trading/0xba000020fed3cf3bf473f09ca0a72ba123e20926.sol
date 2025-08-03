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
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/// @notice Minimalist and gas efficient standard ERC6909 implementation.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC6909.sol)
abstract contract ERC6909 {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event OperatorSet(address indexed owner, address indexed operator, bool approved);

    event Approval(address indexed owner, address indexed spender, uint256 indexed id, uint256 amount);

    event Transfer(address caller, address indexed from, address indexed to, uint256 indexed id, uint256 amount);

    /*//////////////////////////////////////////////////////////////
                             ERC6909 STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(address => mapping(address => bool)) public isOperator;

    mapping(address => mapping(uint256 => uint256)) public balanceOf;

    mapping(address => mapping(address => mapping(uint256 => uint256))) public allowance;

    /*//////////////////////////////////////////////////////////////
                              ERC6909 LOGIC
    //////////////////////////////////////////////////////////////*/

    function transfer(
        address receiver,
        uint256 id,
        uint256 amount
    ) public virtual returns (bool) {
        balanceOf[msg.sender][id] -= amount;

        balanceOf[receiver][id] += amount;

        emit Transfer(msg.sender, msg.sender, receiver, id, amount);

        return true;
    }

    function transferFrom(
        address sender,
        address receiver,
        uint256 id,
        uint256 amount
    ) public virtual returns (bool) {
        if (msg.sender != sender && !isOperator[sender][msg.sender]) {
            uint256 allowed = allowance[sender][msg.sender][id];
            if (allowed != type(uint256).max) allowance[sender][msg.sender][id] = allowed - amount;
        }

        balanceOf[sender][id] -= amount;

        balanceOf[receiver][id] += amount;

        emit Transfer(msg.sender, sender, receiver, id, amount);

        return true;
    }

    function approve(
        address spender,
        uint256 id,
        uint256 amount
    ) public virtual returns (bool) {
        allowance[msg.sender][spender][id] = amount;

        emit Approval(msg.sender, spender, id, amount);

        return true;
    }

    function setOperator(address operator, bool approved) public virtual returns (bool) {
        isOperator[msg.sender][operator] = approved;

        emit OperatorSet(msg.sender, operator, approved);

        return true;
    }

    /*//////////////////////////////////////////////////////////////
                              ERC165 LOGIC
    //////////////////////////////////////////////////////////////*/

    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return
            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
            interfaceId == 0x0f632fb3; // ERC165 Interface ID for ERC6909
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(
        address receiver,
        uint256 id,
        uint256 amount
    ) internal virtual {
        balanceOf[receiver][id] += amount;

        emit Transfer(msg.sender, address(0), receiver, id, amount);
    }

    function _burn(
        address sender,
        uint256 id,
        uint256 amount
    ) internal virtual {
        balanceOf[sender][id] -= amount;

        emit Transfer(msg.sender, sender, address(0), id, amount);
    }
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

/// @notice Gas optimized reentrancy protection for smart contracts.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/ReentrancyGuard.sol)
/// @author Modified from OpenZeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/ReentrancyGuard.sol)
abstract contract ReentrancyGuard {
    uint256 private locked = 1;

    modifier nonReentrant() virtual {
        require(locked == 1, "REENTRANCY");

        locked = 2;

        _;

        locked = 1;
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
// SPDX-License-Identifier: BSL-1.1
pragma solidity 0.8.19;

// Interfaces
import {IAuction} from "./interfaces/modules/IAuction.sol";
import {ICallback} from "./interfaces/ICallback.sol";
import {IBatchAuction} from "./interfaces/modules/IBatchAuction.sol";
import {IBatchAuctionHouse} from "./interfaces/IBatchAuctionHouse.sol";

// Internal libraries
import {Transfer} from "./lib/Transfer.sol";
import {Callbacks} from "./lib/Callbacks.sol";

// External libraries
import {ERC20} from "@solmate-6.7.0/tokens/ERC20.sol";

// Auctions
import {AuctionHouse} from "./bases/AuctionHouse.sol";
import {AuctionModule} from "./modules/Auction.sol";
import {BatchAuctionModule} from "./modules/auctions/BatchAuctionModule.sol";

import {fromVeecode} from "./modules/Keycode.sol";

/// @title      BatchAuctionHouse
/// @notice     As its name implies, the BatchAuctionHouse is where batch auctions are created, bid on, and settled. The core protocol logic is implemented here.
contract BatchAuctionHouse is IBatchAuctionHouse, AuctionHouse {
    using Callbacks for ICallback;

    // ========== ERRORS ========== //

    error AmountLessThanMinimum();
    error InsufficientFunding();

    // ========== EVENTS ========== //

    event Bid(uint96 indexed lotId, uint96 indexed bidId, address indexed bidder, uint256 amount);

    event RefundBid(uint96 indexed lotId, uint96 indexed bidId, address indexed bidder);

    event ClaimBid(uint96 indexed lotId, uint96 indexed bidId, address indexed bidder);

    event Settle(uint96 indexed lotId);

    event Abort(uint96 indexed lotId);

    // ========== STATE VARIABLES ========== //

    // ========== CONSTRUCTOR ========== //

    constructor(
        address owner_,
        address protocol_,
        address permit2_
    ) AuctionHouse(owner_, protocol_, permit2_) {}

    // ========== AUCTION MANAGEMENT ========== //

    /// @inheritdoc AuctionHouse
    /// @dev        Handles auction creation for a batch auction.
    ///
    ///             This function performs the following:
    ///             - Performs additional validation
    ///             - Collects the payout token from the seller (prefunding)
    ///             - Calls the onCreate callback, if configured
    ///
    ///             This function reverts if:
    ///             - The specified auction module is not for batch auctions
    ///             - The capacity is in quote tokens
    function _auction(
        uint96 lotId_,
        RoutingParams calldata routing_,
        IAuction.AuctionParams calldata params_
    ) internal override returns (bool performedCallback) {
        // Validation

        // Ensure the auction type is batch
        AuctionModule auctionModule = AuctionModule(_getLatestModuleIfActive(routing_.auctionType));
        if (auctionModule.auctionType() != IAuction.AuctionType.Batch) revert InvalidParams();

        // Batch auctions must be pre-funded

        // Capacity must be in base token for auctions that require pre-funding
        if (params_.capacityInQuote) revert InvalidParams();

        // Store pre-funding information
        lotRouting[lotId_].funding = params_.capacity;

        ERC20 baseToken = ERC20(routing_.baseToken);

        // Handle funding from callback or seller as configured
        if (routing_.callbacks.hasPermission(Callbacks.SEND_BASE_TOKENS_FLAG)) {
            uint256 balanceBefore = baseToken.balanceOf(address(this));

            // The onCreate callback should transfer the base token to this contract
            _onCreateCallback(routing_, lotId_, params_.capacity, true);

            // Check that the hook transferred the expected amount of base tokens
            if (baseToken.balanceOf(address(this)) < balanceBefore + params_.capacity) {
                revert InvalidCallback();
            }
        }
        // Otherwise fallback to a standard ERC20 transfer and then call the onCreate callback
        else {
            Transfer.transferFrom(baseToken, msg.sender, address(this), params_.capacity, true);
            _onCreateCallback(routing_, lotId_, params_.capacity, false);
        }

        // Return true to indicate that the callback was performed
        return true;
    }

    /// @inheritdoc AuctionHouse
    /// @dev        Handles cancellation of a batch auction lot.
    ///
    ///             This function performs the following:
    ///             - Refunds the base token to the seller (or callback)
    ///             - Calls the onCancel callback, if configured
    function _cancel(
        uint96 lotId_,
        bytes calldata callbackData_
    ) internal override returns (bool performedCallback) {
        // No additional validation needed

        // All batch auctions are prefunded
        Routing storage routing = lotRouting[lotId_];
        uint256 funding = routing.funding;

        // Set to 0 before transfer to avoid re-entrancy
        routing.funding = 0;

        // Transfer the base tokens to the appropriate contract
        Transfer.transfer(
            ERC20(routing.baseToken),
            _getAddressGivenCallbackBaseTokenFlag(routing.callbacks, routing.seller),
            funding,
            false
        );

        // Call the callback to transfer the base token to the owner
        Callbacks.onCancel(
            routing.callbacks,
            lotId_,
            funding,
            routing.callbacks.hasPermission(Callbacks.SEND_BASE_TOKENS_FLAG),
            callbackData_
        );

        return true;
    }

    // ========== CURATION ========== //

    /// @inheritdoc AuctionHouse
    /// @dev        Handles curation approval for a batch auction lot.
    ///
    ///             This function performs the following:
    ///             - Transfers the required base tokens from the seller (or callback)
    ///             - Calls the onCurate callback, if configured
    function _curate(
        uint96 lotId_,
        uint256 curatorFeePayout_,
        bytes calldata callbackData_
    ) internal override returns (bool performedCallback) {
        Routing storage routing = lotRouting[lotId_];

        // Increment the funding
        routing.funding += curatorFeePayout_;

        ERC20 baseToken = ERC20(routing.baseToken);

        // If the callbacks contract is configured to send base tokens, then source the fee from the callbacks contract
        // Otherwise, transfer from the auction owner
        if (Callbacks.hasPermission(routing.callbacks, Callbacks.SEND_BASE_TOKENS_FLAG)) {
            uint256 balanceBefore = baseToken.balanceOf(address(this));

            // The onCurate callback is expected to transfer the base tokens
            Callbacks.onCurate(routing.callbacks, lotId_, curatorFeePayout_, true, callbackData_);

            // Check that the callback transferred the expected amount of base tokens
            if (baseToken.balanceOf(address(this)) < balanceBefore + curatorFeePayout_) {
                revert InvalidCallback();
            }
        } else {
            // Don't need to check for fee on transfer here because it was checked on auction creation
            Transfer.transferFrom(
                baseToken, routing.seller, address(this), curatorFeePayout_, false
            );

            // Call the onCurate callback
            Callbacks.onCurate(routing.callbacks, lotId_, curatorFeePayout_, false, callbackData_);
        }

        // Calls the callback
        return true;
    }

    // ========== BID, REFUND, CLAIM ========== //

    /// @inheritdoc IBatchAuctionHouse
    /// @dev        This function performs the following:
    ///             - Validates the lot ID
    ///             - Records the bid on the auction module
    ///             - Transfers the quote token from the caller
    ///             - Calls the onBid callback
    ///
    ///             This function reverts if:
    ///             - `params_.lotId` is invalid
    ///             - The auction module reverts when creating a bid
    ///             - The quote token transfer fails
    ///             - Re-entrancy is detected
    function bid(
        BidParams memory params_,
        bytes calldata callbackData_
    ) external override nonReentrant returns (uint64 bidId) {
        _isLotValid(params_.lotId);

        // Set bidder to msg.sender if blank
        address bidder = params_.bidder == address(0) ? msg.sender : params_.bidder;

        // Record the bid on the auction module
        // The module will determine if the bid is valid - minimum bid size, minimum price, auction status, etc
        bidId = getBatchModuleForId(params_.lotId).bid(
            params_.lotId, bidder, params_.referrer, params_.amount, params_.auctionData
        );

        // Transfer the quote token from the caller
        // Note this transfers from the caller, not the bidder.
        // It allows for "bid on behalf of" functionality,
        // but if you bid for someone else, they will get the
        // payout and refund while you will pay initially.
        _collectPayment(
            params_.amount,
            ERC20(lotRouting[params_.lotId].quoteToken),
            Transfer.decodePermit2Approval(params_.permit2Data)
        );

        // Call the onBid callback
        Callbacks.onBid(
            lotRouting[params_.lotId].callbacks,
            params_.lotId,
            bidId,
            bidder, // Bidder is the buyer, should also be checked against any allowlist, if applicable
            params_.amount,
            callbackData_
        );

        // Emit event
        emit Bid(params_.lotId, bidId, bidder, params_.amount);

        return bidId;
    }

    /// @inheritdoc IBatchAuctionHouse
    /// @dev        This function performs the following:
    ///             - Validates the lot ID
    ///             - Refunds the bid on the auction module
    ///             - Transfers the quote token to the bidder
    ///
    ///             This function reverts if:
    ///             - The lot ID is invalid
    ///             - The auction module reverts when cancelling the bid
    ///             - Re-entrancy is detected
    function refundBid(
        uint96 lotId_,
        uint64 bidId_,
        uint256 index_
    ) external override nonReentrant {
        _isLotValid(lotId_);

        // Transfer the quote token to the bidder
        // The ownership of the bid has already been verified by the auction module
        Transfer.transfer(
            ERC20(lotRouting[lotId_].quoteToken),
            msg.sender,
            // Refund the bid on the auction module
            // The auction module is responsible for validating the bid and authorizing the caller
            getBatchModuleForId(lotId_).refundBid(lotId_, bidId_, index_, msg.sender),
            false
        );

        // Emit event
        emit RefundBid(lotId_, bidId_, msg.sender);
    }

    /// @inheritdoc IBatchAuctionHouse
    /// @dev        This function performs the following:
    ///             - Validates the lot ID
    ///             - Claims the bids on the auction module
    ///             - Allocates the fees for each successful bid
    ///             - Transfers the payout and/or refund to each bidder
    ///
    ///             This function reverts if:
    ///             - The lot ID is invalid
    ///             - The auction module reverts when claiming the bids
    ///             - Re-entrancy is detected
    function claimBids(uint96 lotId_, uint64[] calldata bidIds_) external override nonReentrant {
        _isLotValid(lotId_);

        // Claim the bids on the auction module
        // The auction module is responsible for validating the bid and authorizing the caller
        (IBatchAuction.BidClaim[] memory bidClaims, bytes memory auctionOutput) =
            getBatchModuleForId(lotId_).claimBids(lotId_, bidIds_);

        // Load routing data for the lot
        Routing storage routing = lotRouting[lotId_];
        ERC20 quoteToken = ERC20(routing.quoteToken);

        // Load fee data
        uint48 protocolFee = lotFees[lotId_].protocolFee;
        uint48 referrerFee = lotFees[lotId_].referrerFee;

        // Iterate through the bid claims and handle each one
        uint256 bidClaimsLen = bidClaims.length;
        for (uint256 i = 0; i < bidClaimsLen; i++) {
            IBatchAuction.BidClaim memory bidClaim = bidClaims[i];

            // If payout is greater than zero, then the bid was filled.
            // However, due to partial fills, there can be both a payout and a refund
            // If payout is zero, then the bid was not filled and the paid amount should be refunded

            if (bidClaim.payout > 0) {
                // Allocate quote and protocol fees for bid
                _allocateQuoteFees(
                    protocolFee,
                    referrerFee,
                    bidClaim.referrer,
                    quoteToken,
                    bidClaim.paid - bidClaim.refund // refund is included in paid
                );

                // Reduce funding by the payout amount
                unchecked {
                    routing.funding -= bidClaim.payout;
                }

                // Send the payout to the bidder
                _sendPayout(bidClaim.bidder, bidClaim.payout, routing, auctionOutput);
            }

            if (bidClaim.refund > 0) {
                // Refund the provided amount to the bidder
                // If the bid was not filled, the refund should be the full amount paid
                // If the bid was partially filled, the refund should be the difference
                // between the paid amount and the filled amount
                Transfer.transfer(quoteToken, bidClaim.bidder, bidClaim.refund, false);
            }

            // Emit event
            emit ClaimBid(lotId_, bidIds_[i], bidClaim.bidder);
        }
    }

    /// @inheritdoc IBatchAuctionHouse
    /// @dev        This function handles the following:
    ///             - Settles the auction on the auction module
    ///             - Sends proceeds and/or refund to the seller
    ///             - Executes the onSettle callback
    ///             - Allocates the curator fee to the curator
    ///
    ///             This function reverts if:
    ///             - The lot ID is invalid
    ///             - The auction module reverts when settling the auction
    ///             - Re-entrancy is detected
    function settle(
        uint96 lotId_,
        uint256 num_,
        bytes calldata callbackData_
    )
        external
        override
        nonReentrant
        returns (uint256 totalIn, uint256 totalOut, bool finished, bytes memory auctionOutput)
    {
        // Validation
        _isLotValid(lotId_);

        // Settle the auction
        uint256 capacity;
        {
            // Settle the lot on the auction module and get the winning bids
            // Reverts if the auction cannot be settled yet
            BatchAuctionModule module = getBatchModuleForId(lotId_);
            (totalIn, totalOut, capacity, finished, auctionOutput) = module.settle(lotId_, num_);

            // Return early if not finished
            if (finished == false) {
                return (totalIn, totalOut, finished, auctionOutput);
            }
        }

        // If the settlement is complete, then proceed with payouts, refunds, and callbacks
        // Load data for the lot
        Routing storage routing = lotRouting[lotId_];
        FeeData storage feeData = lotFees[lotId_];

        // Calculate the referrer and protocol fees for the amount in
        // Fees are not allocated until the user claims their payout so that we don't have to iterate through them here
        // If a referrer is not set, that portion of the fee defaults to the protocol
        uint256 totalInLessFees;
        {
            (, uint256 toProtocol) =
                calculateQuoteFees(feeData.protocolFee, feeData.referrerFee, false, totalIn);
            unchecked {
                totalInLessFees = totalIn - toProtocol;
            }
        }

        // Send payment in bulk to the address dictated by the callbacks address
        // If the callbacks contract is configured to receive quote tokens, send the quote tokens to the callbacks contract and call the onSettle callback
        // If not, send the quote tokens to the seller and call the onSettle callback
        _sendPayment(routing.seller, totalInLessFees, ERC20(routing.quoteToken), routing.callbacks);

        // Refund any unused capacity and curator fees to the address dictated by the callbacks address
        // Additionally, bidders are able to claim before the seller, so the funding isn't the right value
        // to use for the refund. Therefore, we use capacity, which is not decremented when batch auctions
        // are settled, minus the amount sold. Then, we add any unearned curator payout.
        uint256 prefundingRefund;
        {
            // Calculate the curator fee and allocate the fees to be claimed
            uint256 curatorPayout =
                _calculatePayoutFees(feeData.curated, feeData.curatorFee, totalOut);

            // If the curator payout is not zero, allocate it
            if (curatorPayout > 0) {
                // If the payout is a derivative, mint the derivative directly to the curator
                // Otherwise, allocate the fee using the internal rewards mechanism
                if (fromVeecode(routing.derivativeReference) != bytes7("")) {
                    // Mint the derivative to the curator
                    _sendPayout(feeData.curator, curatorPayout, routing, auctionOutput);
                } else {
                    // Allocate the curator fee to be claimed
                    rewards[feeData.curator][ERC20(routing.baseToken)] += curatorPayout;
                }

                // Decrease the funding amount
                unchecked {
                    routing.funding -= curatorPayout;
                }
            }

            uint256 maxCuratorPayout =
                _calculatePayoutFees(feeData.curated, feeData.curatorFee, capacity);
            prefundingRefund = capacity - totalOut + maxCuratorPayout - curatorPayout;
        }
        unchecked {
            routing.funding -= prefundingRefund;
        }
        Transfer.transfer(
            ERC20(routing.baseToken),
            _getAddressGivenCallbackBaseTokenFlag(routing.callbacks, routing.seller),
            prefundingRefund,
            false
        );

        // Call the onSettle callback
        Callbacks.onSettle(
            routing.callbacks, lotId_, totalInLessFees, prefundingRefund, callbackData_
        );

        // Emit event
        emit Settle(lotId_);
    }

    /// @inheritdoc IBatchAuctionHouse
    /// @dev        This function handles the following:
    ///             - Validates the lot id
    ///             - Aborts the auction on the auction module
    ///             - Refunds prefunding (in base tokens) to the seller
    ///             - Calls the onCancel callback
    ///
    ///             This function reverts if:
    ///             - The lot ID is invalid
    ///             - The auction module reverts when aborting the auction
    ///             - The refund amount is zero
    ///
    ///             Note that this function will not revert if the `onCancel` callback reverts.
    ///
    /// @param      lotId_   The lot ID to abort
    function abort(
        uint96 lotId_
    ) external override nonReentrant {
        // Validation
        _isLotValid(lotId_);

        // Call the abort function on the auction module to update the auction state
        getBatchModuleForId(lotId_).abort(lotId_);

        // Cache the funding value to use as the refund and set the funding to 0
        Routing storage routing = lotRouting[lotId_];
        uint256 refund = routing.funding;
        if (refund == 0) revert InsufficientFunding();
        routing.funding = 0;

        // Send the base token refund to the seller or callbacks contract
        Transfer.transfer(
            ERC20(lotRouting[lotId_].baseToken),
            _getAddressGivenCallbackBaseTokenFlag(
                lotRouting[lotId_].callbacks, lotRouting[lotId_].seller
            ),
            refund,
            false
        );

        // If there is a callback configured, call the onCancel callback
        // This is necessary as an auction lot configured with a callback that
        // sends base tokens will have the base tokens sent to the callback contract.
        // Calling onCancel offers the opportunity for the auction owner to handle
        // the refund of the base tokens.
        if (lotRouting[lotId_].callbacks != ICallback(address(0))) {
            // Assemble the calldata
            bytes memory onCancelCalldata = abi.encodeWithSelector(
                ICallback.onCancel.selector,
                lotId_,
                refund,
                lotRouting[lotId_].callbacks.hasPermission(Callbacks.SEND_BASE_TOKENS_FLAG),
                abi.encode("")
            );

            // Call the onCancel callback, but ignore the return value
            // As it is a low-level call, it will not revert on failure
            // This prevents an auction owner from blocking an abort by reverting in the callback
            address(lotRouting[lotId_].callbacks).call(onCancelCalldata);
        }

        emit Abort(lotId_);
    }

    // ========== INTERNAL FUNCTIONS ========== //

    function getBatchModuleForId(
        uint96 lotId_
    ) public view returns (BatchAuctionModule) {
        return BatchAuctionModule(address(_getAuctionModuleForId(lotId_)));
    }
}
// SPDX-License-Identifier: BSL-1.1
pragma solidity 0.8.19;

// Interfaces
import {IAuction} from "../interfaces/modules/IAuction.sol";
import {IAuctionHouse} from "../interfaces/IAuctionHouse.sol";
import {ICallback} from "../interfaces/ICallback.sol";
import {IDerivative} from "../interfaces/modules/IDerivative.sol";
import {IFeeManager} from "../interfaces/IFeeManager.sol";

// Internal libraries
import {Transfer} from "../lib/Transfer.sol";
import {Callbacks} from "../lib/Callbacks.sol";

// External libraries
import {ERC20} from "@solmate-6.7.0/tokens/ERC20.sol";
import {ReentrancyGuard} from "@solmate-6.7.0/utils/ReentrancyGuard.sol";

// Internal dependencies
import {
    fromKeycode, fromVeecode, keycodeFromVeecode, Keycode, Veecode
} from "../modules/Keycode.sol";
import {Module, WithModules} from "../modules/Modules.sol";
import {FeeManager} from "../bases/FeeManager.sol";

import {AuctionModule} from "../modules/Auction.sol";
import {DerivativeModule} from "../modules/Derivative.sol";
import {CondenserModule} from "../modules/Condenser.sol";

/// @title  AuctionHouse
/// @notice The base AuctionHouse contract defines common structures and functions across auction types (atomic and batch).
///         It defines the following:
///         - Creating new auction lots
///         - Cancelling auction lots
///         - Storing information about how to handle inputs and outputs for auctions ("routing")
abstract contract AuctionHouse is IAuctionHouse, WithModules, ReentrancyGuard, FeeManager {
    using Callbacks for ICallback;

    // ========== STATE ========== //

    /// @notice     Address of the Permit2 contract
    address internal immutable _PERMIT2;

    /// @inheritdoc IAuctionHouse
    uint96 public lotCounter;

    /// @inheritdoc IAuctionHouse
    mapping(uint96 lotId => Routing) public lotRouting;

    /// @inheritdoc IAuctionHouse
    mapping(uint96 lotId => FeeData) public lotFees;

    /// @inheritdoc IAuctionHouse
    mapping(Veecode auctionRef => mapping(Veecode derivativeRef => Veecode condenserRef)) public
        condensers;

    // ========== CONSTRUCTOR ========== //

    constructor(
        address owner_,
        address protocol_,
        address permit2_
    ) FeeManager(protocol_) WithModules(owner_) {
        _PERMIT2 = permit2_;
    }

    // ========== AUCTION MANAGEMENT ========== //

    /// @inheritdoc IAuctionHouse
    /// @dev        This function performs the following:
    ///             - Validates the auction parameters
    ///             - Validates the auction module
    ///             - Validates the derivative module (if provided)
    ///             - Validates the callbacks contract (if provided)
    ///             - Stores the auction routing information
    ///             - Calls the auction module to store implementation-specific data
    ///             - Caches the fees for the lot
    ///             - Calls the implementation-specific auction function
    ///             - Calls the onCreate callback (if needed)
    ///
    ///             This function reverts if:
    ///             - The module for the auction type is not installed
    ///             - The auction type is sunset
    ///             - The base token or quote token decimals are not within the required range
    ///             - Validation for the auction parameters fails
    ///             - The module for the optional specified derivative type is not installed
    ///             - Validation for the optional specified derivative type fails
    ///             - Validation for the optional specified callbacks contract fails
    ///             - Re-entrancy is detected
    function auction(
        IAuctionHouse.RoutingParams calldata routing_,
        IAuction.AuctionParams calldata params_,
        string calldata infoHash_
    ) external nonReentrant returns (uint96 lotId) {
        // Check that the module for the auction type is valid
        // Validate routing parameters

        // Tokens must not be the zero address
        if (address(routing_.baseToken) == address(0) || address(routing_.quoteToken) == address(0))
        {
            revert InvalidParams();
        }

        // Increment lot count and get ID
        lotId = lotCounter++;

        // Store routing information
        Routing storage routing = lotRouting[lotId];
        routing.seller = msg.sender;
        routing.baseToken = routing_.baseToken;
        routing.quoteToken = routing_.quoteToken;

        {
            // Load auction type module, this checks that it is installed.
            // We load it here vs. later to avoid two checks.
            AuctionModule auctionModule =
                AuctionModule(_getLatestModuleIfActive(routing_.auctionType));

            // Confirm tokens are within the required decimal range
            uint8 baseTokenDecimals = ERC20(routing.baseToken).decimals();
            uint8 quoteTokenDecimals = ERC20(routing.quoteToken).decimals();

            if (
                auctionModule.TYPE() != Module.Type.Auction || baseTokenDecimals < 6
                    || baseTokenDecimals > 18 || quoteTokenDecimals < 6 || quoteTokenDecimals > 18
            ) revert InvalidParams();

            // Call module auction function to store implementation-specific data
            auctionModule.auction(lotId, params_, quoteTokenDecimals, baseTokenDecimals);
            routing.auctionReference = auctionModule.VEECODE();
        }

        // Store fee information from params and snapshot fees for the lot
        {
            FeeData storage lotFee = lotFees[lotId];
            lotFee.curator = routing_.curator;
            lotFee.curated = false;

            Fees storage auctionFees = fees[routing_.auctionType];

            // Check that the curator's configured fee does not exceed the protocol max
            // If it does, set the fee to the max
            uint48 maxCuratorFee = auctionFees.maxCuratorFee;
            uint48 curatorFee = auctionFees.curator[routing_.curator];
            lotFee.curatorFee = curatorFee > maxCuratorFee ? maxCuratorFee : curatorFee;

            // Check that the referrer fee does not exceed the max.
            // If it does, revert. We revert here since the value is provided by the submitter
            // and can be changed whereas the curator fee above is set by someone else.
            // Otherwise, set the value.
            if (routing_.referrerFee > auctionFees.maxReferrerFee) revert InvalidParams();
            lotFee.referrerFee = routing_.referrerFee;

            // Snapshot the protocol fee
            lotFee.protocolFee = auctionFees.protocol;
        }

        // Derivative
        if (fromKeycode(routing_.derivativeType) != bytes5("")) {
            // Load derivative module, this checks that it is installed.
            DerivativeModule derivativeModule =
                DerivativeModule(_getLatestModuleIfActive(routing_.derivativeType));

            // Check that the module for the derivative type is valid
            // Call module validate function to validate implementation-specific data
            if (
                derivativeModule.TYPE() != Module.Type.Derivative
                    || !derivativeModule.validate(address(routing.baseToken), routing_.derivativeParams)
            ) {
                revert InvalidParams();
            }

            // Store derivative information
            routing.derivativeReference = derivativeModule.VEECODE();
            routing.derivativeParams = routing_.derivativeParams;
            routing.wrapDerivative = routing_.wrapDerivative;
        }

        // Condenser
        {
            // Get condenser reference
            Veecode condenserRef = condensers[routing.auctionReference][routing.derivativeReference];

            // Check that the module for the condenser type is valid
            if (fromVeecode(condenserRef) != bytes7(0)) {
                if (
                    CondenserModule(_getModuleIfInstalled(condenserRef)).TYPE()
                        != Module.Type.Condenser
                ) revert InvalidParams();

                // Check module status
                Keycode moduleKeycode = keycodeFromVeecode(condenserRef);
                if (getModuleStatus[moduleKeycode].sunset == true) {
                    revert ModuleIsSunset(moduleKeycode);
                }
            }
        }

        // Validate callbacks address and store if provided
        // This does not check whether the callbacks contract is implemented properly
        // Certain functions may revert later.
        if (!Callbacks.isValidCallbacksAddress(routing_.callbacks)) revert InvalidParams();
        // The zero address passes the isValidCallbackAddress check since we allow auctions to not use a callbacks contract
        if (address(routing_.callbacks) != address(0)) routing.callbacks = routing_.callbacks;

        // Perform auction-type specific validation and setup
        bool performedCallback = _auction(lotId, routing_, params_);

        // Call the onCreate callback with no prefunding if not already called
        if (!performedCallback) {
            _onCreateCallback(routing_, lotId, params_.capacity, false);
        }

        // Emit auction created event
        emit AuctionCreated(lotId, routing.auctionReference, infoHash_);
    }

    /// @notice     Implementation-specific logic for auction creation
    /// @dev        Inheriting contracts can implement additional logic, such as:
    ///             - Validation
    ///             - Prefunding
    ///
    /// @param      lotId_              The auction lot ID
    /// @param      routing_            RoutingParams
    /// @param      params_             AuctionParams
    /// @return     performedCallback   `true` if the implementing function calls the `onCreate` callback
    function _auction(
        uint96 lotId_,
        IAuctionHouse.RoutingParams calldata routing_,
        IAuction.AuctionParams calldata params_
    ) internal virtual returns (bool performedCallback);

    /// @notice     Cancels an auction lot
    /// @dev        This function performs the following:
    ///             - Checks that the lot ID is valid
    ///             - Checks that caller is the seller
    ///             - Calls the auction module to validate state, update records and determine the amount to be refunded
    ///             - Calls the implementation-specific logic for auction cancellation
    ///             - Calls the onCancel callback (if needed)
    ///
    ///             The function reverts if:
    ///             - The lot ID is invalid
    ///             - The caller is not the seller
    ///             - The respective auction module reverts
    ///             - Re-entrancy is detected
    ///
    /// @param      lotId_      ID of the auction lot
    function cancel(uint96 lotId_, bytes calldata callbackData_) external nonReentrant {
        // Validation
        _isLotValid(lotId_);

        Routing storage routing = lotRouting[lotId_];

        // Check ownership
        if (msg.sender != routing.seller) revert NotPermitted(msg.sender);

        // Cancel the auction on the module
        _getAuctionModuleForId(lotId_).cancelAuction(lotId_);

        // Call the implementation logic
        bool performedCallback = _cancel(lotId_, callbackData_);

        // Call the onCancel callback with no prefunding if not already called
        if (!performedCallback) {
            // Call the callback to notify of the cancellation
            Callbacks.onCancel(routing.callbacks, lotId_, 0, false, callbackData_);
        }

        emit AuctionCancelled(lotId_, routing.auctionReference);
    }

    /// @notice     Implementation-specific logic for auction cancellation
    /// @dev        Inheriting contracts can implement additional logic, such as:
    ///             - Validation
    ///             - Refunding
    ///
    /// @param      lotId_              The auction lot ID
    /// @param      callbackData_       Calldata for the callback
    /// @return     performedCallback   `true` if the implementing function calls the `onCancel` callback
    function _cancel(
        uint96 lotId_,
        bytes calldata callbackData_
    ) internal virtual returns (bool performedCallback);

    // ========== VIEW FUNCTIONS ========== //

    /// @inheritdoc IAuctionHouse
    /// @dev        The function reverts if:
    ///             - The lot ID is invalid
    ///             - The module for the auction type is not installed
    function getAuctionModuleForId(
        uint96 lotId_
    ) external view override returns (IAuction) {
        _isLotValid(lotId_);

        return _getAuctionModuleForId(lotId_);
    }

    /// @inheritdoc IAuctionHouse
    /// @dev        The function reverts if:
    ///             - The lot ID is invalid
    ///             - The module for the derivative type is not installed
    function getDerivativeModuleForId(
        uint96 lotId_
    ) external view override returns (IDerivative) {
        _isLotValid(lotId_);

        return _getDerivativeModuleForId(lotId_);
    }

    // ========== INTERNAL HELPER FUNCTIONS ========== //

    /// @notice         Gets the module for a given lot ID
    /// @dev            The function assumes:
    ///                 - The lot ID is valid
    ///
    /// @param lotId_   ID of the auction lot
    /// @return         AuctionModule
    function _getAuctionModuleForId(
        uint96 lotId_
    ) internal view returns (AuctionModule) {
        // Load module, will revert if not installed
        return AuctionModule(_getModuleIfInstalled(lotRouting[lotId_].auctionReference));
    }

    /// @notice         Gets the module for a given lot ID
    /// @dev            The function assumes:
    ///                 - The lot ID is valid
    ///
    /// @param lotId_   ID of the auction lot
    /// @return         DerivativeModule
    function _getDerivativeModuleForId(
        uint96 lotId_
    ) internal view returns (DerivativeModule) {
        // Load module, will revert if not installed. Also reverts if no derivative is specified.
        return DerivativeModule(_getModuleIfInstalled(lotRouting[lotId_].derivativeReference));
    }

    function _onCreateCallback(
        IAuctionHouse.RoutingParams calldata routing_,
        uint96 lotId_,
        uint256 capacity_,
        bool preFund_
    ) internal {
        Callbacks.onCreate(
            routing_.callbacks,
            lotId_,
            msg.sender,
            address(routing_.baseToken),
            address(routing_.quoteToken),
            capacity_,
            preFund_,
            routing_.callbackData
        );
    }

    function _getAddressGivenCallbackBaseTokenFlag(
        ICallback callbacks_,
        address seller_
    ) internal pure returns (address) {
        return callbacks_.hasPermission(Callbacks.SEND_BASE_TOKENS_FLAG)
            ? address(callbacks_)
            : seller_;
    }

    // ========= VALIDATION FUNCTIONS ========= //

    /// @notice     Checks that the lot ID is valid
    /// @dev        Reverts if the lot ID is invalid
    ///
    /// @param      lotId_  ID of the auction lot
    function _isLotValid(
        uint96 lotId_
    ) internal view {
        if (lotId_ >= lotCounter) revert InvalidLotId(lotId_);
    }

    // ========== CURATION ========== //

    /// @inheritdoc IAuctionHouse
    /// @dev        This function performs the following:
    ///             - Checks that the lot ID is valid
    ///             - Checks that the caller is the proposed curator
    ///             - Validates state
    ///             - Sets the curated state to true
    ///             - Calls the implementation-specific logic for curation
    ///             - Calls the onCurate callback (if needed)
    ///
    ///             This function reverts if:
    ///             - The lot ID is invalid
    ///             - The caller is not the proposed curator
    ///             - The auction has ended or is already curated
    ///             - Re-entrancy is detected
    function curate(uint96 lotId_, bytes calldata callbackData_) external override nonReentrant {
        _isLotValid(lotId_);

        FeeData storage feeData = lotFees[lotId_];

        // Check that the caller is the proposed curator
        if (msg.sender != feeData.curator) revert NotPermitted(msg.sender);

        AuctionModule module = _getAuctionModuleForId(lotId_);

        // Check that the curator has not already approved the auction
        // Check that the auction has not ended or been cancelled
        if (feeData.curated || module.hasEnded(lotId_) == true) revert InvalidState();

        Routing storage routing = lotRouting[lotId_];

        // Set the curator as approved
        feeData.curated = true;

        // Calculate the fee amount based on the remaining capacity (must be in base token if auction is pre-funded)
        uint256 curatorFeePayout = _calculatePayoutFees(
            feeData.curated, feeData.curatorFee, module.remainingCapacity(lotId_)
        );

        // Call the implementation-specific logic
        (bool performedCallback) = _curate(lotId_, curatorFeePayout, callbackData_);

        // Call onCurate if necessary
        if (!performedCallback) {
            Callbacks.onCurate(routing.callbacks, lotId_, curatorFeePayout, false, callbackData_);
        }

        // Emit event that the lot is curated by the proposed curator
        emit Curated(lotId_, msg.sender);
    }

    /// @notice     Implementation-specific logic for curation
    /// @dev        Inheriting contracts can implement additional logic, such as:
    ///             - Validation
    ///             - Prefunding
    ///
    /// @param      lotId_              The auction lot ID
    /// @param      curatorFeePayout_   The amount to pay the curator
    /// @param      callbackData_       Calldata for the callback
    /// @return     performedCallback   `true` if the implementing function calls the `onCurate` callback
    function _curate(
        uint96 lotId_,
        uint256 curatorFeePayout_,
        bytes calldata callbackData_
    ) internal virtual returns (bool performedCallback);

    // ========== ADMIN FUNCTIONS ========== //

    /// @inheritdoc IFeeManager
    /// @dev        Implemented in this contract as it required access to the `onlyOwner` modifier
    function setFee(Keycode auctionType_, FeeType type_, uint48 fee_) external override onlyOwner {
        // Check that the fee is a valid percentage
        if (fee_ > _FEE_DECIMALS) revert InvalidFee();

        // Set fee based on type
        // Protocol and max referrer fee cannot exceed 100%
        if (type_ == FeeType.Protocol) {
            if (fee_ + fees[auctionType_].maxReferrerFee > _FEE_DECIMALS) revert InvalidFee();
            fees[auctionType_].protocol = fee_;
        } else if (type_ == FeeType.MaxReferrer) {
            if (fee_ + fees[auctionType_].protocol > _FEE_DECIMALS) revert InvalidFee();
            fees[auctionType_].maxReferrerFee = fee_;
        } else if (type_ == FeeType.MaxCurator) {
            fees[auctionType_].maxCuratorFee = fee_;
        }
    }

    /// @inheritdoc IFeeManager
    /// @dev        Implemented in this contract as it required access to the `onlyOwner` modifier
    function setProtocol(
        address protocol_
    ) external override onlyOwner {
        _protocol = protocol_;
    }

    /// @notice     Sets the value of the Condenser for a given auction and derivative combination
    /// @dev        To remove a condenser, set the value of `condenserRef_` to a blank Veecode
    ///
    ///             This function will revert if:
    ///             - The caller is not the owner
    ///             - `auctionRef_` or `derivativeRef_` are empty
    ///             - `auctionRef_` does not belong to an auction module
    ///             - `derivativeRef_` does not belong to a derivative module
    ///             - `condenserRef_` does not belong to a condenser module
    ///
    /// @param      auctionRef_    The auction type
    /// @param      derivativeRef_ The derivative type
    /// @param      condenserRef_  The condenser type
    function setCondenser(
        Veecode auctionRef_,
        Veecode derivativeRef_,
        Veecode condenserRef_
    ) external onlyOwner {
        // Check that the auction type, derivative type, and condenser types are valid
        if (
            (AuctionModule(_getModuleIfInstalled(auctionRef_)).TYPE() != Module.Type.Auction)
                || (
                    DerivativeModule(_getModuleIfInstalled(derivativeRef_)).TYPE()
                        != Module.Type.Derivative
                )
                || (
                    fromVeecode(condenserRef_) != bytes7(0)
                        && CondenserModule(_getModuleIfInstalled(condenserRef_)).TYPE()
                            != Module.Type.Condenser
                )
        ) revert InvalidParams();

        // Set the condenser reference
        condensers[auctionRef_][derivativeRef_] = condenserRef_;
    }

    // ========== TOKEN TRANSFERS ========== //

    /// @notice     Convenience function to collect payment of the quote token from the user
    /// @dev        This function calls the Transfer library to handle the transfer of the quote token
    ///
    /// @param      amount_             Amount of quoteToken to collect (in native decimals)
    /// @param      quoteToken_         Quote token to collect
    /// @param      permit2Approval_    Permit2 approval data (optional)
    function _collectPayment(
        uint256 amount_,
        ERC20 quoteToken_,
        Transfer.Permit2Approval memory permit2Approval_
    ) internal {
        Transfer.permit2OrTransferFrom(
            quoteToken_, _PERMIT2, msg.sender, address(this), amount_, permit2Approval_, true
        );
    }

    /// @notice     Convenience function to send payment of the quote token to the seller
    /// @dev        This function calls the Transfer library to handle the transfer of the quote token
    ///
    /// @param      lotOwner_       Owner of the lot
    /// @param      amount_         Amount of quoteToken to send (in native decimals)
    /// @param      quoteToken_     Quote token to send
    /// @param      callbacks_      Callbacks contract that may receive the tokens
    function _sendPayment(
        address lotOwner_,
        uint256 amount_,
        ERC20 quoteToken_,
        ICallback callbacks_
    ) internal {
        // Determine where to send the payment
        address to = callbacks_.hasPermission(Callbacks.RECEIVE_QUOTE_TOKENS_FLAG)
            ? address(callbacks_)
            : lotOwner_;

        // Send the payment
        Transfer.transfer(quoteToken_, to, amount_, false);
    }

    /// @notice     Sends the payout token to the recipient
    /// @dev        This function handles the following:
    ///             - If the lot has a derivative defined, mints the derivative token ot the recipient
    ///             - Otherwise, sends the payout token to the recipient
    ///
    ///             This function assumes that:
    ///             - The payout token has already been transferred to this contract
    ///             - The payout token is supported (e.g. not fee-on-transfer)
    ///
    ///             This function reverts if:
    ///             - The payout token transfer fails
    ///             - The payout token transfer would result in a lesser amount being received
    ///
    /// @param      recipient_      Address to receive payout
    /// @param      payoutAmount_   Amount of payoutToken to send (in native decimals)
    /// @param      routingParams_  Routing parameters for the lot
    /// @param      auctionOutput_  Output data from the auction module
    function _sendPayout(
        address recipient_,
        uint256 payoutAmount_,
        Routing memory routingParams_,
        bytes memory auctionOutput_
    ) internal {
        Veecode derivativeReference = routingParams_.derivativeReference;
        ERC20 baseToken = ERC20(routingParams_.baseToken);

        // If no derivative, then the payout is sent directly to the recipient
        if (fromVeecode(derivativeReference) == bytes7("")) {
            Transfer.transfer(baseToken, recipient_, payoutAmount_, true);
        }
        // Otherwise, send parameters and payout to the derivative to mint to recipient
        else {
            // Get the module for the derivative type
            // We assume that the module type has been checked when the lot was created
            DerivativeModule module = DerivativeModule(_getModuleIfInstalled(derivativeReference));

            bytes memory derivativeParams = routingParams_.derivativeParams;

            // Lookup condenser module from combination of auction and derivative types
            // If condenser specified, condense auction output and derivative params before sending to derivative module
            Veecode condenserRef = condensers[routingParams_.auctionReference][derivativeReference];
            if (fromVeecode(condenserRef) != bytes7("")) {
                // Get condenser module
                CondenserModule condenser = CondenserModule(_getModuleIfInstalled(condenserRef));

                // Condense auction output and derivative params
                derivativeParams = condenser.condense(auctionOutput_, derivativeParams);
            }

            // Approve the module to transfer payout tokens when minting
            Transfer.approve(baseToken, address(module), payoutAmount_);

            // Call the module to mint derivative tokens to the recipient
            module.mint(
                recipient_,
                address(baseToken),
                derivativeParams,
                payoutAmount_,
                routingParams_.wrapDerivative
            );
        }
    }

    // ========== FEE FUNCTIONS ========== //

    /// @notice  Allocates fees on quote tokens to the protocol and referrer
    /// @dev     This function calculates the fees for the quote token and updates the balances.
    ///
    /// @param   protocolFee_   The fee charged by the protocol
    /// @param   referrerFee_   The fee charged by the referrer
    /// @param   referrer_      The address of the referrer
    /// @param   quoteToken_    The quote token
    /// @param   amount_        The amount of quote tokens
    function _allocateQuoteFees(
        uint48 protocolFee_,
        uint48 referrerFee_,
        address referrer_,
        ERC20 quoteToken_,
        uint256 amount_
    ) internal returns (uint256 totalFees) {
        // Calculate fees for purchase
        (uint256 toReferrer, uint256 toProtocol) =
            calculateQuoteFees(protocolFee_, referrerFee_, referrer_ != address(0), amount_);

        // Update fee balances if non-zero
        if (toReferrer > 0) rewards[referrer_][quoteToken_] += toReferrer;
        if (toProtocol > 0) rewards[_protocol][quoteToken_] += toProtocol;

        return toReferrer + toProtocol;
    }
}
// SPDX-License-Identifier: BSL-1.1
pragma solidity 0.8.19;

// Interfaces
import {IFeeManager} from "../interfaces/IFeeManager.sol";

// Internal libraries
import {Transfer} from "../lib/Transfer.sol";

// External libraries
import {ERC20} from "@solmate-6.7.0/tokens/ERC20.sol";
import {ReentrancyGuard} from "@solmate-6.7.0/utils/ReentrancyGuard.sol";
import {FixedPointMathLib as Math} from "@solmate-6.7.0/utils/FixedPointMathLib.sol";

import {Keycode} from "../modules/Keycode.sol";

/// @title      FeeManager
/// @notice     Defines fees for auctions and manages the collection and distribution of fees
abstract contract FeeManager is IFeeManager, ReentrancyGuard {
    // ========== STATE VARIABLES ========== //

    /// @notice     Fees are in basis points (hundredths of a percent). 1% equals 100.
    uint48 internal constant _FEE_DECIMALS = 100e2;

    /// @notice     Address the protocol receives fees at
    address internal _protocol;

    /// @notice     Fees charged for each auction type
    /// @dev        See Fees struct for more details
    mapping(Keycode => Fees) public fees;

    /// @notice     Fees earned by an address, by token
    mapping(address => mapping(ERC20 => uint256)) public rewards;

    // ========== CONSTRUCTOR ========== //

    constructor(
        address protocol_
    ) {
        _protocol = protocol_;
    }

    // ========== FEE CALCULATIONS ========== //

    /// @inheritdoc IFeeManager
    function calculateQuoteFees(
        uint48 protocolFee_,
        uint48 referrerFee_,
        bool hasReferrer_,
        uint256 amount_
    ) public pure returns (uint256 toReferrer, uint256 toProtocol) {
        if (hasReferrer_) {
            // In this case we need to:
            // 1. Calculate referrer fee
            // 2. Calculate protocol fee as the total expected fee amount minus the referrer fee
            //    to avoid issues with rounding from separate fee calculations
            toReferrer = Math.mulDivDown(amount_, referrerFee_, _FEE_DECIMALS);
            toProtocol =
                Math.mulDivDown(amount_, protocolFee_ + referrerFee_, _FEE_DECIMALS) - toReferrer;
        } else {
            // If there is no referrer, the protocol gets the entire fee
            toProtocol = Math.mulDivDown(amount_, protocolFee_ + referrerFee_, _FEE_DECIMALS);
        }
    }

    /// @notice     Calculates and allocates fees that are collected in the payout token
    function _calculatePayoutFees(
        bool curated_,
        uint48 curatorFee_,
        uint256 payout_
    ) internal pure returns (uint256 toCurator) {
        // No fees if the auction is not yet curated
        if (curated_ == false) return 0;

        // Calculate curator fee
        toCurator = Math.mulDivDown(payout_, uint256(curatorFee_), uint256(_FEE_DECIMALS));
    }

    // ========== FEE MANAGEMENT ========== //

    /// @inheritdoc IFeeManager
    function setCuratorFee(Keycode auctionType_, uint48 fee_) external {
        // Check that the fee is less than the maximum
        if (fee_ > fees[auctionType_].maxCuratorFee) revert InvalidFee();

        // Set the fee for the sender
        fees[auctionType_].curator[msg.sender] = fee_;
    }

    /// @inheritdoc IFeeManager
    function getFees(
        Keycode auctionType_
    )
        external
        view
        override
        returns (uint48 protocol, uint48 maxReferrerFee, uint48 maxCuratorFee)
    {
        Fees storage fee = fees[auctionType_];
        return (fee.protocol, fee.maxReferrerFee, fee.maxCuratorFee);
    }

    /// @inheritdoc IFeeManager
    function getCuratorFee(
        Keycode auctionType_,
        address curator_
    ) external view override returns (uint48 curatorFee) {
        return fees[auctionType_].curator[curator_];
    }

    // ========== REWARDS ========== //

    /// @inheritdoc IFeeManager
    /// @dev        This function reverts if:
    ///             - re-entrancy is detected
    function claimRewards(
        address token_
    ) external nonReentrant {
        ERC20 token = ERC20(token_);
        uint256 amount = rewards[msg.sender][token];
        rewards[msg.sender][token] = 0;

        Transfer.transfer(token, msg.sender, amount, false);
    }

    /// @inheritdoc IFeeManager
    function getRewards(
        address recipient_,
        address token_
    ) external view override returns (uint256 reward) {
        return rewards[recipient_][ERC20(token_)];
    }

    // ========== ADMIN FUNCTIONS ========== //

    /// @inheritdoc IFeeManager
    function getProtocol() public view returns (address) {
        return _protocol;
    }
}
// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity >=0.8.0;

// Interfaces
import {IAuction} from "./modules/IAuction.sol";
import {ICallback} from "./ICallback.sol";
import {IDerivative} from "./modules/IDerivative.sol";

// Internal dependencies
import {Keycode, Veecode} from "../modules/Keycode.sol";

/// @title  IAuctionHouse
/// @notice Interface for the Axis AuctionHouse contracts
interface IAuctionHouse {
    // ========= ERRORS ========= //

    error InvalidParams();
    error InvalidLotId(uint96 id_);
    error InvalidState();
    error InvalidCallback();

    /// @notice     Used when the caller is not permitted to perform that action
    error NotPermitted(address caller_);

    // ========= EVENTS ========= //

    /// @notice         Emitted when a new auction lot is created
    ///
    /// @param          lotId       ID of the auction lot
    /// @param          auctionRef  Auction module, represented by its Veecode
    /// @param          infoHash    IPFS hash of the auction information
    event AuctionCreated(uint96 indexed lotId, Veecode indexed auctionRef, string infoHash);

    /// @notice         Emitted when an auction lot is cancelled
    ///
    /// @param          lotId       ID of the auction lot
    /// @param          auctionRef  Auction module, represented by its Veecode
    event AuctionCancelled(uint96 indexed lotId, Veecode indexed auctionRef);

    /// @notice         Emitted when a curator accepts curation of an auction lot
    ///
    /// @param          lotId       ID of the auction lot
    /// @param          curator     Address of the curator
    event Curated(uint96 indexed lotId, address indexed curator);

    // ========= DATA STRUCTURES ========== //

    /// @notice     Auction routing information provided as input parameters
    ///
    /// @param      auctionType         Auction type, represented by the Keycode for the auction submodule
    /// @param      baseToken           Token provided by seller. Declared as an address to avoid dependency hell.
    /// @param      quoteToken          Token to accept as payment. Declared as an address to avoid dependency hell.
    /// @param      curator             (optional) Address of the proposed curator
    /// @param      referrerFee         (optional) Percent of bid/purchase amount received paid to a referrer in basis points, i.e. 1% = 100.
    /// @param      callbacks           (optional) Callbacks implementation for extended functionality
    /// @param      callbackData        (optional) abi-encoded data to be sent to the onCreate callback function
    /// @param      derivativeType      (optional) Derivative type, represented by the Keycode for the derivative submodule
    /// @param      derivativeParams    (optional) abi-encoded data to be used to create payout derivatives on a purchase. The format of this is dependent on the derivative module.
    /// @param      wrapDerivative      (optional) Whether to wrap the derivative in a ERC20 token instead of the native ERC6909 format
    struct RoutingParams {
        Keycode auctionType;
        address baseToken;
        address quoteToken;
        address curator;
        uint48 referrerFee;
        ICallback callbacks;
        bytes callbackData;
        Keycode derivativeType;
        bytes derivativeParams;
        bool wrapDerivative;
    }

    /// @notice     Auction routing information for a lot
    ///
    /// @param      seller              Lot seller
    /// @param      baseToken           ERC20 token provided by seller
    /// @param      quoteToken          ERC20 token to accept as payment
    /// @param      auctionReference    Auction module, represented by its Veecode
    /// @param      funding             The amount of base tokens in funding remaining
    /// @param      callbacks           (optional) Callbacks implementation for extended functionality
    /// @param      derivativeReference (optional) Derivative module, represented by its Veecode
    /// @param      wrapDerivative      (optional) Whether to wrap the derivative in a ERC20 token instead of the native ERC6909 format
    /// @param      derivativeParams    (optional) abi-encoded data to be used to create payout derivatives on a purchase
    struct Routing {
        address seller; // 20 bytes
        address baseToken; // 20 bytes
        address quoteToken; // 20 bytes
        Veecode auctionReference; // 7 bytes
        uint256 funding; // 32 bytes
        ICallback callbacks; // 20 bytes
        Veecode derivativeReference; // 7 bytes
        bool wrapDerivative; // 1 byte
        bytes derivativeParams;
    }

    /// @notice     Fee information for a lot
    /// @dev        This is split into a separate struct, otherwise the Routing struct would be too large
    ///             and would throw a "stack too deep" error.
    ///
    ///             Fee information is set at the time of auction creation, in order to prevent subsequent inflation.
    ///             The fees are cached in order to prevent:
    ///             - Reducing the amount of base tokens available for payout to the winning bidders
    ///             - Reducing the amount of quote tokens available for payment to the seller
    ///
    /// @param      curator     Address of the proposed curator
    /// @param      curated     Whether the curator has approved the auction
    /// @param      curatorFee  The fee charged by the curator
    /// @param      protocolFee The fee charged by the protocol
    /// @param      referrerFee The fee charged by the referrer
    struct FeeData {
        address curator; // 20 bytes
        bool curated; // 1 byte
        uint48 curatorFee; // 6 bytes
        uint48 protocolFee; // 6 bytes
        uint48 referrerFee; // 6 bytes
    }

    // ========== AUCTION MANAGEMENT ========== //

    /// @notice     Creates a new auction lot
    ///
    /// @param      routing_    Routing information for the auction lot
    /// @param      params_     Auction parameters for the auction lot
    /// @param      infoHash_   IPFS hash of the auction information
    /// @return     lotId       ID of the auction lot
    function auction(
        RoutingParams calldata routing_,
        IAuction.AuctionParams calldata params_,
        string calldata infoHash_
    ) external returns (uint96 lotId);

    /// @notice     Cancels an auction lot
    ///
    /// @param      lotId_          ID of the auction lot
    /// @param      callbackData_   (optional) abi-encoded data to be sent to the onCancel callback function
    function cancel(uint96 lotId_, bytes calldata callbackData_) external;

    /// @notice     Accept curation request for a lot.
    /// @notice     If the curator wishes to charge a fee, it must be set before this function is called.
    /// @notice     Access controlled. Must be proposed curator for lot.
    ///
    /// @param      lotId_           Lot ID
    /// @param      callbackData_    (optional) abi-encoded data to be sent to the onCurate callback function
    function curate(uint96 lotId_, bytes calldata callbackData_) external;

    // ========== AUCTION INFORMATION ========== //

    /// @notice     The counter tracks the total number of auction lots
    function lotCounter() external view returns (uint96 lotCount);

    /// @notice     Mapping of lot IDs to their routing information
    /// @dev        See the `Routing` struct for more information
    ///
    /// @param      lotId   ID of the auction lot
    function lotRouting(
        uint96 lotId
    )
        external
        view
        returns (
            address seller,
            address baseToken,
            address quoteToken,
            Veecode auctionReference,
            uint256 funding,
            ICallback callbacks,
            Veecode derivativeReference,
            bool wrapDerivative,
            bytes memory derivativeParams
        );

    /// @notice     Mapping of lot IDs to their fee information
    /// @dev        See the `FeeData` struct for more information
    ///
    /// @param      lotId   ID of the auction lot
    function lotFees(
        uint96 lotId
    )
        external
        view
        returns (
            address curator,
            bool curated,
            uint48 curatorFee,
            uint48 protocolFee,
            uint48 referrerFee
        );

    /// @notice     Mapping auction and derivative references to the condenser that is used to pass data between them
    ///
    /// @param      auctionRef      Versioned keycode for the auction module
    /// @param      derivativeRef   Versioned keycode for the derivative module
    /// @return     condenserRef    Versioned keycode for the condenser module
    function condensers(
        Veecode auctionRef,
        Veecode derivativeRef
    ) external view returns (Veecode condenserRef);

    /// @notice     Gets the auction module for a given lot ID
    ///
    /// @param      lotId_  ID of the auction lot
    /// @return     module  The auction module
    function getAuctionModuleForId(
        uint96 lotId_
    ) external view returns (IAuction module);

    /// @notice     Gets the derivative module for a given lot ID
    /// @dev        Will revert if the lot does not have a derivative module
    ///
    /// @param      lotId_  ID of the auction lot
    /// @return     module  The derivative module
    function getDerivativeModuleForId(
        uint96 lotId_
    ) external view returns (IDerivative module);
}
// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity >=0.8.0;

import {IAuctionHouse} from "./IAuctionHouse.sol";

/// @title      IBatchAuctionHouse
/// @notice     An interface to define the BatchAuctionHouse's buyer-facing functions
interface IBatchAuctionHouse is IAuctionHouse {
    // ========== DATA STRUCTURES ========== //

    /// @notice     Parameters used by the bid function
    /// @dev        This reduces the number of variables in scope for the bid function
    ///
    /// @param      lotId               Lot ID
    /// @param      bidder              Address to receive refunds and payouts (if not zero address)
    /// @param      referrer            Address of referrer
    /// @param      amount              Amount of quoteToken to purchase with (in native decimals)
    /// @param      auctionData         Custom data used by the auction module
    /// @param      permit2Data_        Permit2 approval for the quoteToken (abi-encoded Permit2Approval struct)
    struct BidParams {
        uint96 lotId;
        address bidder;
        address referrer;
        uint256 amount;
        bytes auctionData;
        bytes permit2Data;
    }

    // ========== BATCH AUCTIONS ========== //

    /// @notice     Bid on a lot in a batch auction
    /// @dev        The implementing function must perform the following:
    ///             1. Validate the bid
    ///             2. Store the bid
    ///             3. Transfer the amount of quote token from the bidder
    ///
    /// @param      params_         Bid parameters
    /// @param      callbackData_   Custom data provided to the onBid callback
    /// @return     bidId           Bid ID
    function bid(
        BidParams memory params_,
        bytes calldata callbackData_
    ) external returns (uint64 bidId);

    /// @notice     Refund a bid on a lot in a batch auction
    /// @dev        The implementing function must perform the following:
    ///             1. Validate the bid
    ///             2. Pass the request to the auction module to validate and update data
    ///             3. Send the refund to the bidder
    ///
    /// @param      lotId_          Lot ID
    /// @param      bidId_          Bid ID
    /// @param      index_          Index of the bid in the auction's bid list
    function refundBid(uint96 lotId_, uint64 bidId_, uint256 index_) external;

    /// @notice     Claim bid payouts and/or refunds after a batch auction has settled
    /// @dev        The implementing function must perform the following:
    ///             1. Validate the lot ID
    ///             2. Pass the request to the auction module to validate and update bid data
    ///             3. Send the refund and/or payout to the bidders
    ///
    /// @param      lotId_          Lot ID
    /// @param      bidIds_         Bid IDs
    function claimBids(uint96 lotId_, uint64[] calldata bidIds_) external;

    /// @notice     Settle a batch auction
    /// @notice     This function is used for versions with on-chain storage of bids and settlement
    /// @dev        The implementing function must perform the following:
    ///             1. Validate the lot
    ///             2. Pass the request to the auction module to calculate winning bids
    ///             If settlement is completed:
    ///             3. Send the proceeds (quote tokens) to the seller
    ///             4. Execute the onSettle callback
    ///             5. Refund any unused base tokens to the seller
    ///             6. Allocate the curator fee (base tokens) to the curator
    ///
    /// @param      lotId_          Lot ID
    /// @param      num_            Number of bids to settle in this pass (capped at the remaining number if more is provided)
    /// @param      callbackData_   Custom data provided to the onSettle callback
    /// @return     totalIn         Total amount of quote tokens from bids that were filled
    /// @return     totalOut        Total amount of base tokens paid out to winning bids
    /// @return     finished        Boolean indicating if the settlement was completed
    /// @return     auctionOutput   Custom data returned by the auction module
    function settle(
        uint96 lotId_,
        uint256 num_,
        bytes calldata callbackData_
    )
        external
        returns (uint256 totalIn, uint256 totalOut, bool finished, bytes memory auctionOutput);

    /// @notice    Abort a batch auction that cannot be settled, refunding the seller and allowing bidders to claim refunds
    /// @dev       This function can be called by anyone. Care should be taken to ensure proper logic is in place to prevent calling when not desired.
    /// @dev       The implementing function should handle the following:
    ///            1. Validate the lot
    ///            2. Pass the request to the auction module to update the lot data
    ///            3. Refund the seller
    ///
    /// @param     lotId_    The lot id
    function abort(
        uint96 lotId_
    ) external;
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/// @title  ICallback
/// @notice Interface for callback contracts use in the Axis system
interface ICallback {
    /// @notice Callback configuration. Used by AuctionHouse to know which functions are implemented on this contract.
    /// @dev 8-bit map of which callbacks are implemented on this contract.
    ///     The last two bits designate whether the callback should be expected send base tokens and receive quote tokens.
    ///     If the contract does not send/receive, then the AuctionHouse will expect the tokens to be sent/received directly by the seller wallet.
    ///     Bit 1: onCreate
    ///     Bit 2: onCancel
    ///     Bit 3: onCurate
    ///     Bit 4: onPurchase
    ///     Bit 5: onBid
    ///     Bit 6: onSettle
    ///     Bit 7: Receives quote tokens
    ///     Bit 8: Sends base tokens (and receives them if refunded)

    // General functions that can be used by all auctions

    /// @notice Called when an auction is created. Reverts if validation fails.
    /// @dev    The implementing function should:
    ///         - Register the lot ID on the Callback contract
    ///         - Validate that the seller is allowed to use the Callback contract
    ///
    /// @param  lotId         The ID of the lot
    /// @param  seller        The address of the seller
    /// @param  baseToken     The address of the base token
    /// @param  quoteToken    The address of the quote token
    /// @param  capacity      The capacity of the auction
    /// @param  preFund       If true, the calling contract expects base tokens to be sent to it
    /// @param  callbackData  Custom data provided by the seller
    function onCreate(
        uint96 lotId,
        address seller,
        address baseToken,
        address quoteToken,
        uint256 capacity,
        bool preFund,
        bytes calldata callbackData
    ) external returns (bytes4);

    /// @notice Called when an auction is cancelled.
    /// @dev    If the Callback is configured to receive tokens and the auction was prefunded, then the refund will be sent prior to the call.
    ///
    /// @param  lotId           The ID of the lot
    /// @param  refund          The refund amount
    /// @param  preFunded       If true, the calling contract will have sent base tokens prior to the call
    /// @param  callbackData    Custom data provided by the seller
    function onCancel(
        uint96 lotId,
        uint256 refund,
        bool preFunded,
        bytes calldata callbackData
    ) external returns (bytes4);

    /// @notice Called when curate is called for an auction.
    ///
    /// @param  lotId         The ID of the lot
    /// @param  curatorFee    The curator fee payout
    /// @param  preFund       If true, the calling contract expects base tokens to be sent to it
    /// @param  callbackData  Custom data provided by the seller
    function onCurate(
        uint96 lotId,
        uint256 curatorFee,
        bool preFund,
        bytes calldata callbackData
    ) external returns (bytes4);

    // Atomic Auction hooks

    /// @notice Called when a buyer purchases from an atomic auction. Reverts if validation fails.
    /// @dev    If the Callback is configured to receive quote tokens, then the user purchase amount of quote tokens will be sent prior to this call.
    ///         If the Callback is configured to send base tokens, then the AuctionHouse will expect the payout of base tokens to be sent back.
    ///
    /// @param  lotId         The ID of the lot
    /// @param  buyer         The address of the buyer
    /// @param  amount        The amount of quote tokens purchased
    /// @param  payout        The amount of base tokens to receive
    /// @param  preFunded     If true, the calling contract has already been provided the base tokens. Otherwise, they must be provided.
    /// @param  callbackData  Custom data provided by the buyer
    function onPurchase(
        uint96 lotId,
        address buyer,
        uint256 amount,
        uint256 payout,
        bool preFunded,
        bytes calldata callbackData
    ) external returns (bytes4);

    // Batch Auction hooks

    /// @notice Called when a buyer bids on a batch auction. Reverts if validation fails.
    ///
    /// @param  lotId         The ID of the lot
    /// @param  bidId         The ID of the bid
    /// @param  buyer         The address of the buyer
    /// @param  amount        The amount of quote tokens bid
    /// @param  callbackData  Custom data provided by the buyer
    function onBid(
        uint96 lotId,
        uint64 bidId,
        address buyer,
        uint256 amount,
        bytes calldata callbackData
    ) external returns (bytes4);

    /// @notice Called when a batch auction is settled.
    /// @dev    If the Callback is configured to receive tokens, then the proceeds and/or refund will be sent prior to the call.
    ///
    /// @param  lotId         The ID of the lot
    /// @param  proceeds      The proceeds amount
    /// @param  refund        The refund amount
    /// @param  callbackData  Custom data provided by the seller
    function onSettle(
        uint96 lotId,
        uint256 proceeds,
        uint256 refund,
        bytes calldata callbackData
    ) external returns (bytes4);
}
// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity >=0.8.0;

import {Keycode} from "../modules/Keycode.sol";

/// @title      IFeeManager
/// @notice     Defines the interface to interact with auction fees
interface IFeeManager {
    // ========== ERRORS ========== //

    error InvalidFee();

    // ========== DATA STRUCTURES ========== //

    /// @notice     Collection of fees charged for a specific auction type in basis points (3 decimals).
    /// @notice     Protocol and referrer fees are taken in the quoteToken and accumulate in the contract. These are set by the protocol.
    /// @notice     Curator fees are taken in the payoutToken and are sent when the auction is settled / purchase is made. Curators can set these up to the configured maximum.
    /// @dev        There are some situations where the fees may round down to zero if quantity of baseToken
    ///             is < 100e2 wei (can happen with big price differences on small decimal tokens). This is purely
    ///             a theoretical edge case, as the amount would not be practical.
    ///
    /// @param      protocol        Fee charged by the protocol
    /// @param      maxReferrerFee  Maximum fee that can be paid to a referrer
    /// @param      maxCuratorFee   Maximum fee that a curator can charge
    /// @param      curator         Fee charged by a specific curator
    struct Fees {
        uint48 protocol;
        uint48 maxReferrerFee;
        uint48 maxCuratorFee;
        mapping(address => uint48) curator;
    }

    /// @notice     Defines the type of fee to set
    enum FeeType {
        Protocol,
        MaxReferrer,
        MaxCurator
    }

    // ========== FEE CALCULATIONS ========== //

    /// @notice     Calculates and allocates fees that are collected in the quote token
    ///
    /// @param      protocolFee_  Fee charged by the protocol
    /// @param      referrerFee_  Fee charged by the referrer
    /// @param      hasReferrer_  Whether the auction has a referrer
    /// @param      amount_       Amount to calculate fees for
    /// @return     toReferrer    Amount to send to the referrer
    /// @return     toProtocol    Amount to send to the protocol
    function calculateQuoteFees(
        uint48 protocolFee_,
        uint48 referrerFee_,
        bool hasReferrer_,
        uint256 amount_
    ) external view returns (uint256 toReferrer, uint256 toProtocol);

    // ========== FEE MANAGEMENT ========== //

    /// @notice     Sets the fee for a curator (the sender) for a specific auction type
    ///
    /// @param      auctionType_ Auction type to set fees for
    /// @param      fee_         Fee to charge
    function setCuratorFee(Keycode auctionType_, uint48 fee_) external;

    /// @notice     Gets the fees for a specific auction type
    ///
    /// @param      auctionType_   Auction type to get fees for
    /// @return     protocol       Fee charged by the protocol
    /// @return     maxReferrerFee  Maximum fee that can be paid to a referrer
    /// @return     maxCuratorFee  Maximum fee that a curator can charge
    function getFees(
        Keycode auctionType_
    ) external view returns (uint48 protocol, uint48 maxReferrerFee, uint48 maxCuratorFee);

    /// @notice     Gets the fee for a specific auction type and curator
    ///
    /// @param      auctionType_  Auction type to get fees for
    /// @param      curator_      Curator to get fees for
    /// @return     curatorFee    Fee charged by the curator
    function getCuratorFee(
        Keycode auctionType_,
        address curator_
    ) external view returns (uint48 curatorFee);

    // ========== REWARDS ========== //

    /// @notice     Claims the rewards for a specific token and the sender
    ///
    /// @param      token_  Token to claim rewards for
    function claimRewards(
        address token_
    ) external;

    /// @notice     Gets the rewards for a specific recipient and token
    ///
    /// @param      recipient_  Recipient to get rewards for
    /// @param      token_      Token to get rewards for
    /// @return     reward      Reward amount
    function getRewards(
        address recipient_,
        address token_
    ) external view returns (uint256 reward);

    // ========== ADMIN FUNCTIONS ========== //

    /// @notice     Sets the protocol fee, referrer fee, or max curator fee for a specific auction type
    /// @notice     Access controlled: only owner
    ///
    /// @param      auctionType_  Auction type to set fees for
    /// @param      type_         Type of fee to set
    /// @param      fee_          Fee to charge
    function setFee(Keycode auctionType_, FeeType type_, uint48 fee_) external;

    /// @notice     Sets the protocol address
    /// @dev        Access controlled: only owner
    ///
    /// @param      protocol_  Address of the protocol
    function setProtocol(
        address protocol_
    ) external;

    /// @notice     Gets the protocol address
    function getProtocol() external view returns (address);
}
// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity >=0.8.0;

/// @title  IAuction
/// @notice Interface for all auction modules used in the Axis AuctionHouse
/// @dev    This contract defines the external functions and data that are required for an auction module to be installed in an AuctionHouse.
///
///         The implementing contract should define the following additional areas:
///         - Any un-implemented functions
///         - State variables for storage and configuration
///
///         Data storage:
///         - Each auction lot will have common data that is stored using the `Lot` struct. Inheriting auction modules may store additional data outside of the struct.
interface IAuction {
    // ========== ERRORS ========== //

    error Auction_LotNotActive(uint96 lotId);
    error Auction_LotActive(uint96 lotId);
    error Auction_InvalidStart(uint48 start_, uint48 minimum_);
    error Auction_InvalidDuration(uint48 duration_, uint48 minimum_);
    error Auction_InvalidLotId(uint96 lotId);
    error Auction_OnlyLotOwner();
    error Auction_AmountLessThanMinimum();
    error Auction_InvalidParams();
    error Auction_NotAuthorized();
    error Auction_NotImplemented();
    error Auction_InsufficientCapacity();
    error Auction_LotNotConcluded(uint96 lotId);

    // ========== DATA STRUCTURES ========== //

    /// @notice     Types of auctions
    enum AuctionType {
        Atomic,
        Batch
    }

    /// @notice     Parameters when creating an auction lot
    ///
    /// @param      start           The timestamp when the auction starts
    /// @param      duration        The duration of the auction (in seconds)
    /// @param      capacityInQuote Whether or not the capacity is in quote tokens
    /// @param      capacity        The capacity of the lot
    /// @param      implParams      Abi-encoded implementation-specific parameters
    struct AuctionParams {
        uint48 start;
        uint48 duration;
        bool capacityInQuote;
        uint256 capacity;
        bytes implParams;
    }

    /// @notice     Core data for an auction lot
    ///
    /// @param      start               The timestamp when the auction starts
    /// @param      conclusion          The timestamp when the auction ends
    /// @param      quoteTokenDecimals  The quote token decimals
    /// @param      baseTokenDecimals   The base token decimals
    /// @param      capacityInQuote     Whether or not the capacity is in quote tokens
    /// @param      capacity            The capacity of the lot
    /// @param      sold                The amount of base tokens sold
    /// @param      purchased           The amount of quote tokens purchased
    struct Lot {
        uint48 start; // 6 +
        uint48 conclusion; // 6 +
        uint8 quoteTokenDecimals; // 1 +
        uint8 baseTokenDecimals; // 1 +
        bool capacityInQuote; // 1 = 15 - end of slot 1
        uint256 capacity; // 32 - slot 2
        uint256 sold; // 32 - slot 3
        uint256 purchased; // 32 - slot 4
    }

    // ========== STATE VARIABLES ========== //

    /// @notice Minimum auction duration in seconds
    function minAuctionDuration() external view returns (uint48);

    /// @notice General information pertaining to auction lots
    /// @dev    See the `Lot` struct for more information on the return values
    ///
    /// @param  lotId   The lot ID
    function lotData(
        uint96 lotId
    )
        external
        view
        returns (
            uint48 start,
            uint48 conclusion,
            uint8 quoteTokenDecimals,
            uint8 baseTokenDecimals,
            bool capacityInQuote,
            uint256 capacity,
            uint256 sold,
            uint256 purchased
        );

    // ========== AUCTION MANAGEMENT ========== //

    /// @notice     Create an auction lot
    /// @dev        The implementing function should handle the following:
    ///             - Validate the lot parameters
    ///             - Store the lot data
    ///
    /// @param      lotId_                  The lot id
    /// @param      params_                 The auction parameters
    /// @param      quoteTokenDecimals_     The quote token decimals
    /// @param      baseTokenDecimals_      The base token decimals
    function auction(
        uint96 lotId_,
        AuctionParams memory params_,
        uint8 quoteTokenDecimals_,
        uint8 baseTokenDecimals_
    ) external;

    /// @notice     Cancel an auction lot
    /// @dev        The implementing function should handle the following:
    ///             - Validate the lot parameters
    ///             - Update the lot data
    ///
    /// @param      lotId_              The lot id
    function cancelAuction(
        uint96 lotId_
    ) external;

    // ========== AUCTION INFORMATION ========== //

    /// @notice     Returns whether the auction is currently accepting bids or purchases
    /// @dev        The implementing function should handle the following:
    ///             - Return true if the lot is accepting bids/purchases
    ///             - Return false if the lot has ended, been cancelled, or not started yet
    ///
    /// @param      lotId_  The lot id
    /// @return     bool    Whether or not the lot is active
    function isLive(
        uint96 lotId_
    ) external view returns (bool);

    /// @notice     Returns whether the auction is upcoming
    /// @dev        The implementing function should handle the following:
    ///             - Return true if the lot has not started yet AND has not been cancelled
    ///             - Return false if the lot is active, has ended, or was cancelled
    ///
    /// @param      lotId_  The lot id
    /// @return     bool    Whether or not the lot is upcoming
    function isUpcoming(
        uint96 lotId_
    ) external view returns (bool);

    /// @notice     Returns whether the auction has ended
    /// @dev        The implementing function should handle the following:
    ///             - Return true if the lot is not accepting bids/purchases and will not at any point
    ///             - Return false if the lot hasn't started or is actively accepting bids/purchases
    ///
    /// @param      lotId_  The lot id
    /// @return     bool    Whether or not the lot is active
    function hasEnded(
        uint96 lotId_
    ) external view returns (bool);

    /// @notice     Get the remaining capacity of a lot
    /// @dev        The implementing function should handle the following:
    ///             - Return the remaining capacity of the lot
    ///
    /// @param      lotId_  The lot id
    /// @return     uint96 The remaining capacity of the lot
    function remainingCapacity(
        uint96 lotId_
    ) external view returns (uint256);

    /// @notice     Get whether or not the capacity is in quote tokens
    /// @dev        The implementing function should handle the following:
    ///             - Return true if the capacity is in quote tokens
    ///             - Return false if the capacity is in base tokens
    ///
    /// @param      lotId_  The lot id
    /// @return     bool    Whether or not the capacity is in quote tokens
    function capacityInQuote(
        uint96 lotId_
    ) external view returns (bool);

    /// @notice     Get the lot data for a given lot ID
    ///
    /// @param     lotId_  The lot ID
    function getLot(
        uint96 lotId_
    ) external view returns (Lot memory);

    /// @notice     Get the auction type
    function auctionType() external view returns (AuctionType);
}
// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity >=0.8.0;

import {IAuction} from "./IAuction.sol";

/// @title  IBatchAuction
/// @notice Interface for batch auctions
/// @dev    The implementing contract should define the following additional areas:
///         - Any un-implemented functions
///         - State variables for storage and configuration
interface IBatchAuction is IAuction {
    // ========== ERRORS ========== //

    error Auction_DedicatedSettlePeriod(uint96 lotId);
    error Auction_InvalidBidId(uint96 lotId, uint96 bidId);
    error Auction_NotBidder();

    // ========== DATA STRUCTURES ========== //

    /// @notice Contains data about a bidder's outcome from an auction
    /// @dev    Only used in memory so doesn't need to be packed
    ///
    /// @param  bidder   The bidder
    /// @param  referrer The referrer
    /// @param  paid     The amount of quote tokens paid (including any refunded tokens)
    /// @param  payout   The amount of base tokens paid out
    /// @param  refund   The amount of quote tokens refunded
    struct BidClaim {
        address bidder;
        address referrer;
        uint256 paid;
        uint256 payout;
        uint256 refund;
    }

    // ========== STATE VARIABLES ========== //

    /// @notice     Time period after auction conclusion where bidders cannot refund bids
    function dedicatedSettlePeriod() external view returns (uint48);

    /// @notice     Custom auction output for each lot
    /// @dev        Stored during settlement
    ///
    /// @param      lotId   The lot ID
    function lotAuctionOutput(
        uint96 lotId
    ) external view returns (bytes memory);

    // ========== BATCH OPERATIONS ========== //

    /// @notice     Bid on an auction lot
    /// @dev        The implementing function should handle the following:
    ///             - Validate the bid parameters
    ///             - Store the bid data
    ///
    /// @param      lotId_          The lot id
    /// @param      bidder_         The bidder of the purchased tokens
    /// @param      referrer_       The referrer of the bid
    /// @param      amount_         The amount of quote tokens to bid
    /// @param      auctionData_    The auction-specific data
    /// @return     bidId           The bid id
    function bid(
        uint96 lotId_,
        address bidder_,
        address referrer_,
        uint256 amount_,
        bytes calldata auctionData_
    ) external returns (uint64 bidId);

    /// @notice     Refund a bid
    /// @dev        The implementing function should handle the following:
    ///             - Validate the bid parameters
    ///             - Authorize `caller_`
    ///             - Update the bid data
    ///
    /// @param      lotId_      The lot id
    /// @param      bidId_      The bid id
    /// @param      index_      The index of the bid ID in the auction's bid list
    /// @param      caller_     The caller
    /// @return     refund      The amount of quote tokens to refund
    function refundBid(
        uint96 lotId_,
        uint64 bidId_,
        uint256 index_,
        address caller_
    ) external returns (uint256 refund);

    /// @notice     Claim multiple bids
    /// @dev        The implementing function should handle the following:
    ///             - Validate the bid parameters
    ///             - Update the bid data
    ///
    /// @param      lotId_          The lot id
    /// @param      bidIds_         The bid ids
    /// @return     bidClaims       The bid claim data
    /// @return     auctionOutput   The auction-specific output
    function claimBids(
        uint96 lotId_,
        uint64[] calldata bidIds_
    ) external returns (BidClaim[] memory bidClaims, bytes memory auctionOutput);

    /// @notice     Settle a batch auction lot with on-chain storage and settlement
    /// @dev        The implementing function should handle the following:
    ///             - Validate the lot parameters
    ///             - Determine the winning bids
    ///             - Update the lot data
    ///
    /// @param      lotId_          The lot id
    /// @param      num_            The number of winning bids to settle (capped at the remaining number if more is provided)
    /// @return     totalIn         Total amount of quote tokens from bids that were filled
    /// @return     totalOut        Total amount of base tokens paid out to winning bids
    /// @return     capacity        The original capacity of the lot
    /// @return     finished        Whether the settlement is finished
    /// @return     auctionOutput   Custom data returned by the auction module
    function settle(
        uint96 lotId_,
        uint256 num_
    )
        external
        returns (
            uint256 totalIn,
            uint256 totalOut,
            uint256 capacity,
            bool finished,
            bytes memory auctionOutput
        );

    /// @notice    Abort a batch auction that cannot be settled, refunding the seller and allowing bidders to claim refunds
    /// @dev       The implementing function should handle the following:
    ///            - Validate the lot is in the correct state
    ///            - Set the auction in a state that allows bidders to claim refunds
    ///
    /// @param     lotId_    The lot id
    function abort(
        uint96 lotId_
    ) external;

    // ========== VIEW FUNCTIONS ========== //

    /// @notice Get the number of bids for a lot
    ///
    /// @param  lotId_  The lot ID
    /// @return numBids The number of bids
    function getNumBids(
        uint96 lotId_
    ) external view returns (uint256 numBids);

    /// @notice Get the bid IDs from the given index
    ///
    /// @param  lotId_  The lot ID
    /// @param  start_  The index to start retrieving bid IDs from
    /// @param  count_  The number of bids to retrieve
    /// @return bidIds  The bid IDs
    function getBidIds(
        uint96 lotId_,
        uint256 start_,
        uint256 count_
    ) external view returns (uint64[] memory bidIds);

    /// @notice Get the bid ID at the given index
    ///
    /// @param  lotId_  The lot ID
    /// @param  index_  The index
    /// @return bidId   The bid ID
    function getBidIdAtIndex(uint96 lotId_, uint256 index_) external view returns (uint64 bidId);

    /// @notice Get the claim data for a bid
    /// @notice This provides information on the outcome of a bid, independent of the claim status
    ///
    /// @param  lotId_  The lot ID
    /// @param  bidId_  The bid ID
    /// @return bidClaim    The bid claim data
    function getBidClaim(
        uint96 lotId_,
        uint64 bidId_
    ) external view returns (BidClaim memory bidClaim);
}
// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity >=0.8.0;

/// @title      ICondenser
/// @notice     Interface for Condenser functionality
/// @dev        Condensers are used to modify auction output data into a format that can be understood by a derivative
interface ICondenser {
    /// @notice     Condense auction output data into a format that can be understood by a derivative
    ///
    /// @param      auctionOutput_      Output data from an auction
    /// @param      derivativeConfig_   Configuration data for the derivative
    /// @return     condensedOutput     Condensed output data
    function condense(
        bytes memory auctionOutput_,
        bytes memory derivativeConfig_
    ) external pure returns (bytes memory condensedOutput);
}
// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity >=0.8.0;

/// @title      IDerivative
/// @notice     Interface for Derivative functionality
/// @dev        Derivatives provide a mechanism to create synthetic assets that are backed by collateral, such as base tokens from an auction.
interface IDerivative {
    // ========== ERRORS ========== //

    error Derivative_NotImplemented();

    // ========== DATA STRUCTURES ========== //

    /// @notice     Metadata for a derivative token
    ///
    /// @param      exists          True if the token has been deployed
    /// @param      wrapped         Non-zero if an ERC20-wrapped derivative has been deployed
    /// @param      underlyingToken The address of the underlying token
    /// @param      supply          The total supply of the derivative token
    /// @param      data            Implementation-specific data
    struct Token {
        bool exists;
        address wrapped;
        address underlyingToken;
        uint256 supply;
        bytes data;
    }

    // ========== STATE VARIABLES ========== //

    /// @notice The metadata for a derivative token
    ///
    /// @param  tokenId         The ID of the derivative token
    /// @return exists          True if the token has been deployed
    /// @return wrapped         Non-zero if an ERC20-wrapped derivative has been deployed
    /// @return underlyingToken The address of the underlying token
    /// @return supply          The total supply of the derivative token
    /// @return data            Implementation-specific data
    function tokenMetadata(
        uint256 tokenId
    )
        external
        view
        returns (
            bool exists,
            address wrapped,
            address underlyingToken,
            uint256 supply,
            bytes memory data
        );

    // ========== DERIVATIVE MANAGEMENT ========== //

    /// @notice     Deploy a new derivative token. Optionally, deploys an ERC20 wrapper for composability.
    ///
    /// @param      underlyingToken_    The address of the underlying token
    /// @param      params_             ABI-encoded parameters for the derivative to be created
    /// @param      wrapped_            Whether (true) or not (false) the derivative should be wrapped in an ERC20 token for composability
    /// @return     tokenId_            The ID of the newly created derivative token
    /// @return     wrappedAddress_     The address of the ERC20 wrapped derivative token, if wrapped_ is true, otherwise, it's the zero address.
    function deploy(
        address underlyingToken_,
        bytes memory params_,
        bool wrapped_
    ) external returns (uint256 tokenId_, address wrappedAddress_);

    /// @notice     Mint new derivative tokens.
    /// @notice     Deploys the derivative token if it does not already exist.
    /// @notice     The module is expected to transfer the collateral token to itself.
    ///
    /// @param      to_                 The address to mint the derivative tokens to
    /// @param      underlyingToken_    The address of the underlying token
    /// @param      params_             ABI-encoded parameters for the derivative to be created
    /// @param      amount_             The amount of derivative tokens to create
    /// @param      wrapped_            Whether (true) or not (false) the derivative should be wrapped in an ERC20 token for composability
    /// @return     tokenId_            The ID of the newly created derivative token
    /// @return     wrappedAddress_     The address of the ERC20 wrapped derivative token, if wrapped_ is true, otherwise, it's the zero address.
    /// @return     amountCreated_      The amount of derivative tokens created
    function mint(
        address to_,
        address underlyingToken_,
        bytes memory params_,
        uint256 amount_,
        bool wrapped_
    ) external returns (uint256 tokenId_, address wrappedAddress_, uint256 amountCreated_);

    /// @notice     Mint new derivative tokens for a specific token ID
    ///
    /// @param      to_                 The address to mint the derivative tokens to
    /// @param      tokenId_            The ID of the derivative token
    /// @param      amount_             The amount of derivative tokens to create
    /// @param      wrapped_            Whether (true) or not (false) the derivative should be wrapped in an ERC20 token for composability
    /// @return     tokenId_            The ID of the derivative token
    /// @return     wrappedAddress_     The address of the ERC20 wrapped derivative token, if wrapped_ is true, otherwise, it's the zero address.
    /// @return     amountCreated_      The amount of derivative tokens created
    function mint(
        address to_,
        uint256 tokenId_,
        uint256 amount_,
        bool wrapped_
    ) external returns (uint256, address, uint256);

    /// @notice     Redeem all available derivative tokens for underlying collateral
    ///
    /// @param      tokenId_    The ID of the derivative token to redeem
    function redeemMax(
        uint256 tokenId_
    ) external;

    /// @notice     Redeem derivative tokens for underlying collateral
    ///
    /// @param      tokenId_    The ID of the derivative token to redeem
    /// @param      amount_     The amount of derivative tokens to redeem
    function redeem(uint256 tokenId_, uint256 amount_) external;

    /// @notice     Determines the amount of redeemable tokens for a given derivative token
    ///
    /// @param      owner_      The owner of the derivative token
    /// @param      tokenId_    The ID of the derivative token
    /// @return     amount      The amount of redeemable tokens
    function redeemable(address owner_, uint256 tokenId_) external view returns (uint256 amount);

    /// @notice     Exercise a conversion of the derivative token per the specific implementation logic
    /// @dev        Used for options or other derivatives with convertible options, e.g. Rage vesting.
    ///
    /// @param      tokenId_    The ID of the derivative token to exercise
    /// @param      amount      The amount of derivative tokens to exercise
    function exercise(uint256 tokenId_, uint256 amount) external;

    /// @notice     Determines the cost to exercise a derivative token in the quoted token
    /// @dev        Used for options or other derivatives with convertible options, e.g. Rage vesting.
    ///
    /// @param      tokenId_    The ID of the derivative token to exercise
    /// @param      amount      The amount of derivative tokens to exercise
    /// @return     cost        The cost to exercise the derivative token
    function exerciseCost(uint256 tokenId_, uint256 amount) external view returns (uint256 cost);

    /// @notice     Reclaim posted collateral for a derivative token which can no longer be exercised
    /// @notice     Access controlled: only callable by the derivative issuer via the auction house.
    ///
    /// @param      tokenId_    The ID of the derivative token to reclaim
    function reclaim(
        uint256 tokenId_
    ) external;

    /// @notice     Transforms an existing derivative issued by this contract into something else. Derivative is burned and collateral sent to the auction house.
    /// @notice     Access controlled: only callable by the auction house.
    ///
    /// @param      tokenId_    The ID of the derivative token to transform
    /// @param      from_       The address of the owner of the derivative token
    /// @param      amount_     The amount of derivative tokens to transform
    function transform(uint256 tokenId_, address from_, uint256 amount_) external;

    /// @notice     Wrap an existing derivative into an ERC20 token for composability
    ///             Deploys the ERC20 wrapper if it does not already exist
    ///
    /// @param      tokenId_    The ID of the derivative token to wrap
    /// @param      amount_     The amount of derivative tokens to wrap
    function wrap(uint256 tokenId_, uint256 amount_) external;

    /// @notice     Unwrap an ERC20 derivative token into the underlying ERC6909 derivative
    ///
    /// @param      tokenId_    The ID of the derivative token to unwrap
    /// @param      amount_     The amount of derivative tokens to unwrap
    function unwrap(uint256 tokenId_, uint256 amount_) external;

    /// @notice     Validate derivative params for the specific implementation
    ///             The parameters should be the same as what is passed into `deploy()` or `mint()`
    ///
    /// @param      underlyingToken_    The address of the underlying token
    /// @param      params_             The params to validate
    /// @return     isValid             Whether or not the params are valid
    function validate(
        address underlyingToken_,
        bytes memory params_
    ) external view returns (bool isValid);

    // ========== DERIVATIVE INFORMATION ========== //

    /// @notice     Compute a unique token ID, given the parameters for the derivative
    ///
    /// @param      underlyingToken_    The address of the underlying token
    /// @param      params_             The parameters for the derivative
    /// @return     tokenId             The unique token ID
    function computeId(
        address underlyingToken_,
        bytes memory params_
    ) external pure returns (uint256 tokenId);

    /// @notice     Get the metadata for a derivative token
    ///
    /// @param      tokenId     The ID of the derivative token
    /// @return     tokenData   The metadata for the derivative token
    function getTokenMetadata(
        uint256 tokenId
    ) external view returns (Token memory tokenData);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ICallback} from "../interfaces/ICallback.sol";

/// @notice Library for handling callbacks
/// @dev This library is based on the design of UniswapV4's Hooks library (https://github.com/Uniswap/v4-core/blob/main/src/libraries/Hooks.sol)
/// and is published under the same MIT license.
/// We use the term callbacks because it is more appropriate for the type of extensibility we are providing to the Axis auction system.
/// The system decides whether to invoke specific hooks by inspecting the leading bits (first byte)
/// of the address that the callbacks contract is deployed to.
/// For example, a callbacks contract deployed to address: 0x9000000000000000000000000000000000000000
/// has leading bits '1001' which would cause the 'onCreate' and 'onPurchase' callbacks to be used.
/// There are 8 flags
library Callbacks {
    using Callbacks for ICallback;

    uint256 internal constant ON_CREATE_FLAG = 1 << 159;
    uint256 internal constant ON_CANCEL_FLAG = 1 << 158;
    uint256 internal constant ON_CURATE_FLAG = 1 << 157;
    uint256 internal constant ON_PURCHASE_FLAG = 1 << 156;
    uint256 internal constant ON_BID_FLAG = 1 << 155;
    uint256 internal constant ON_SETTLE_FLAG = 1 << 154;
    uint256 internal constant RECEIVE_QUOTE_TOKENS_FLAG = 1 << 153;
    uint256 internal constant SEND_BASE_TOKENS_FLAG = 1 << 152;

    struct Permissions {
        bool onCreate;
        bool onCancel;
        bool onCurate;
        bool onPurchase;
        bool onBid;
        bool onSettle;
        bool receiveQuoteTokens;
        bool sendBaseTokens;
    }

    /// @notice Thrown if the address will not lead to the specified callbacks being called
    /// @param callbacks The address of the callbacks contract
    error CallbacksAddressNotValid(address callbacks);

    /// @notice Callback did not return its selector
    error InvalidCallbackResponse();

    /// @notice thrown when a callback fails
    error FailedCallback();

    /// @notice Utility function intended to be used in hook constructors to ensure
    /// the deployed hooks address causes the intended hooks to be called
    /// @param permissions The hooks that are intended to be called
    /// @dev permissions param is memory as the function will be called from constructors
    function validateCallbacksPermissions(
        ICallback self,
        Permissions memory permissions
    ) internal pure {
        if (
            permissions.onCreate != self.hasPermission(ON_CREATE_FLAG)
                || permissions.onCancel != self.hasPermission(ON_CANCEL_FLAG)
                || permissions.onCurate != self.hasPermission(ON_CURATE_FLAG)
                || permissions.onPurchase != self.hasPermission(ON_PURCHASE_FLAG)
                || permissions.onBid != self.hasPermission(ON_BID_FLAG)
                || permissions.onSettle != self.hasPermission(ON_SETTLE_FLAG)
                || permissions.receiveQuoteTokens != self.hasPermission(RECEIVE_QUOTE_TOKENS_FLAG)
                || permissions.sendBaseTokens != self.hasPermission(SEND_BASE_TOKENS_FLAG)
        ) {
            revert CallbacksAddressNotValid(address(self));
        }
    }

    /// @notice Ensures that the callbacks contract includes at least one of the required flags and more if sending/receiving tokens
    /// @param callbacks The callbacks contract to verify
    function isValidCallbacksAddress(
        ICallback callbacks
    ) internal pure returns (bool) {
        // Ensure that if the contract is expected to send base tokens, then it implements atleast onCreate and onCurate OR onPurchase (atomic auctions may not be prefunded).
        if (
            callbacks.hasPermission(SEND_BASE_TOKENS_FLAG)
                && (
                    !callbacks.hasPermission(ON_CREATE_FLAG) || !callbacks.hasPermission(ON_CURATE_FLAG)
                ) && !callbacks.hasPermission(ON_PURCHASE_FLAG)
        ) {
            return false;
        }

        // Ensure that, if not the zero address, atleast one of the callback functions is implemented or the contract is set to receive quote tokens (which can be done without implementing anything else)
        return address(callbacks) == address(0) || uint160(address(callbacks)) >= 1 << 153;
    }

    /// @notice performs a call using the given calldata on the given callback
    function callback(ICallback self, bytes memory data) internal {
        bytes4 expectedSelector;
        assembly {
            expectedSelector := mload(add(data, 0x20))
        }

        (bool success, bytes memory result) = address(self).call(data);
        if (!success) _revert(result);

        bytes4 selector = abi.decode(result, (bytes4));

        if (selector != expectedSelector) {
            revert InvalidCallbackResponse();
        }
    }

    /// @notice calls onCreate callback if permissioned and validates return value
    function onCreate(
        ICallback self,
        uint96 lotId,
        address seller,
        address baseToken,
        address quoteToken,
        uint256 capacity,
        bool preFund,
        bytes calldata callbackData
    ) internal {
        if (self.hasPermission(ON_CREATE_FLAG)) {
            self.callback(
                abi.encodeWithSelector(
                    ICallback.onCreate.selector,
                    lotId,
                    seller,
                    baseToken,
                    quoteToken,
                    capacity,
                    preFund,
                    callbackData
                )
            );
        }
    }

    /// @notice calls onCancel callback if permissioned and validates return value
    function onCancel(
        ICallback self,
        uint96 lotId,
        uint256 refund,
        bool preFunded,
        bytes calldata callbackData
    ) internal {
        if (self.hasPermission(ON_CANCEL_FLAG)) {
            self.callback(
                abi.encodeWithSelector(
                    ICallback.onCancel.selector, lotId, refund, preFunded, callbackData
                )
            );
        }
    }

    /// @notice calls onCurate callback if permissioned and validates return value
    function onCurate(
        ICallback self,
        uint96 lotId,
        uint256 curatorFee,
        bool preFund,
        bytes calldata callbackData
    ) internal {
        if (self.hasPermission(ON_CURATE_FLAG)) {
            self.callback(
                abi.encodeWithSelector(
                    ICallback.onCurate.selector, lotId, curatorFee, preFund, callbackData
                )
            );
        }
    }

    /// @notice calls onPurchase callback if permissioned and validates return value
    function onPurchase(
        ICallback self,
        uint96 lotId,
        address buyer,
        uint256 amount,
        uint256 payout,
        bool preFunded,
        bytes calldata callbackData
    ) internal {
        if (self.hasPermission(ON_PURCHASE_FLAG)) {
            self.callback(
                abi.encodeWithSelector(
                    ICallback.onPurchase.selector,
                    lotId,
                    buyer,
                    amount,
                    payout,
                    preFunded,
                    callbackData
                )
            );
        }
    }

    /// @notice calls onBid callback if permissioned and validates return value
    function onBid(
        ICallback self,
        uint96 lotId,
        uint64 bidId,
        address buyer,
        uint256 amount,
        bytes calldata callbackData
    ) internal {
        if (self.hasPermission(ON_BID_FLAG)) {
            self.callback(
                abi.encodeWithSelector(
                    ICallback.onBid.selector, lotId, bidId, buyer, amount, callbackData
                )
            );
        }
    }

    /// @notice calls onSettle callback if permissioned and validates return value
    function onSettle(
        ICallback self,
        uint96 lotId,
        uint256 proceeds,
        uint256 refund,
        bytes calldata callbackData
    ) internal {
        if (self.hasPermission(ON_SETTLE_FLAG)) {
            self.callback(
                abi.encodeWithSelector(
                    ICallback.onSettle.selector, lotId, proceeds, refund, callbackData
                )
            );
        }
    }

    function hasPermission(ICallback self, uint256 flag) internal pure returns (bool) {
        return uint256(uint160(address(self))) & flag != 0;
    }

    /// @notice bubble up revert if present. Else throw FailedCallback error
    function _revert(
        bytes memory result
    ) private pure {
        if (result.length > 0) {
            assembly {
                revert(add(0x20, result), mload(result))
            }
        } else {
            revert FailedCallback();
        }
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

abstract contract ERC6909Metadata {
    /// @notice     Returns the name of the token
    ///
    /// @param      tokenId_    The ID of the token
    /// @return     string      The name of the token
    function name(
        uint256 tokenId_
    ) public view virtual returns (string memory);

    /// @notice     Returns the symbol of the token
    ///
    /// @param      tokenId_    The ID of the token
    /// @return     string      The symbol of the token
    function symbol(
        uint256 tokenId_
    ) public view virtual returns (string memory);

    /// @notice     Returns the number of decimals used by the token
    ///
    /// @param      tokenId_    The ID of the token
    /// @return     uint8       The number of decimals used by the token
    function decimals(
        uint256 tokenId_
    ) public view virtual returns (uint8);

    /// @notice     Returns the URI of the token
    ///
    /// @param      tokenId_    The ID of the token
    /// @return     string      The URI of the token
    function tokenURI(
        uint256 tokenId_
    ) public view virtual returns (string memory);

    /// @notice     Returns the total supply of the token
    ///
    /// @param      tokenId_    The ID of the token
    /// @return     uint256     The total supply of the token
    function totalSupply(
        uint256 tokenId_
    ) public view virtual returns (uint256);
}
// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.19;

import {ERC20} from "@solmate-6.7.0/tokens/ERC20.sol";
import {SafeTransferLib} from "@solmate-6.7.0/utils/SafeTransferLib.sol";
import {IPermit2} from "./permit2/interfaces/IPermit2.sol";

library Transfer {
    using SafeTransferLib for ERC20;

    uint256 internal constant _PERMIT2_PARAMS_LEN = 256;

    // ============ Data Structures ============ //

    /// @notice     Parameters used for Permit2 approvals
    struct Permit2Approval {
        uint48 deadline;
        uint256 nonce;
        bytes signature;
    }

    // ========== Errors ========== //

    error UnsupportedToken(address token_);

    error InvalidParams();

    // ============ Functions ============ //

    function approve(ERC20 token_, address spender_, uint256 amount_) internal {
        token_.safeApprove(spender_, amount_);
    }

    /// @notice     Performs an ERC20 transfer of `token_` from the caller
    /// @dev        This function handles the following:
    ///             1. Checks that the user has granted approval to transfer the token
    ///             2. Transfers the token from the user
    ///             3. Checks that the transferred amount was received
    ///
    ///             This function reverts if:
    ///             - Approval has not been granted to this contract to transfer the token
    ///             - The token transfer fails
    ///             - The transferred amount is less than the requested amount
    ///
    /// @param      token_              Token to transfer
    /// @param      recipient_          Address of the recipient
    /// @param      amount_             Amount of tokens to transfer (in native decimals)
    /// @param      validateBalance_    Whether to validate the balance of the recipient
    function transfer(
        ERC20 token_,
        address recipient_,
        uint256 amount_,
        bool validateBalance_
    ) internal {
        uint256 balanceBefore;
        if (validateBalance_ == true) {
            balanceBefore = token_.balanceOf(recipient_);
        }

        // Transfer the quote token from the user
        // `safeTransfer()` will revert upon failure or the lack of allowance or balance
        // We need to check that the amount is greater than zero, to protect against revert on zero tokens
        if (amount_ > 0) {
            token_.safeTransfer(recipient_, amount_);
        }

        // Check that it is not a fee-on-transfer token
        if (validateBalance_ == true && token_.balanceOf(recipient_) < balanceBefore + amount_) {
            revert UnsupportedToken(address(token_));
        }
    }

    /// @notice     Performs an ERC20 transferFrom of `token_` from the sender
    /// @dev        This function handles the following:
    ///             1. Checks that the user has granted approval to transfer the token
    ///             2. Transfers the token from the user
    ///             3. Checks that the transferred amount was received
    ///
    ///             This function reverts if:
    ///             - Approval has not been granted to this contract to transfer the token
    ///             - The token transfer fails
    ///             - The transferred amount is less than the requested amount
    ///
    /// @param      token_              Token to transfer
    /// @param      sender_             Address of the sender
    /// @param      recipient_          Address of the recipient
    /// @param      amount_             Amount of tokens to transfer (in native decimals)
    /// @param      validateBalance_    Whether to validate the balance of the recipient
    function transferFrom(
        ERC20 token_,
        address sender_,
        address recipient_,
        uint256 amount_,
        bool validateBalance_
    ) internal {
        uint256 balanceBefore;
        if (validateBalance_ == true) {
            balanceBefore = token_.balanceOf(recipient_);
        }

        // Transfer the quote token from the user
        // `safeTransferFrom()` will revert upon failure or the lack of allowance or balance
        // We need to check that the amount is greater than zero, to protect against revert on zero tokens
        if (amount_ > 0) {
            token_.safeTransferFrom(sender_, recipient_, amount_);
        }

        // Check that it is not a fee-on-transfer token
        if (validateBalance_ == true && token_.balanceOf(recipient_) < balanceBefore + amount_) {
            revert UnsupportedToken(address(token_));
        }
    }

    function permit2TransferFrom(
        ERC20 token_,
        address permit2_,
        address sender_,
        address recipient_,
        uint256 amount_,
        Permit2Approval memory approval_,
        bool validateBalance_
    ) internal {
        uint256 balanceBefore;
        if (validateBalance_ == true) {
            balanceBefore = token_.balanceOf(recipient_);
        }

        {
            // Use PERMIT2 to transfer the token from the user
            IPermit2(permit2_).permitTransferFrom(
                IPermit2.PermitTransferFrom(
                    IPermit2.TokenPermissions(address(token_), amount_),
                    approval_.nonce,
                    approval_.deadline
                ),
                IPermit2.SignatureTransferDetails({to: recipient_, requestedAmount: amount_}),
                sender_, // Spender of the tokens
                approval_.signature
            );
        }

        // Check that it is not a fee-on-transfer token
        if (validateBalance_ == true && token_.balanceOf(recipient_) < balanceBefore + amount_) {
            revert UnsupportedToken(address(token_));
        }
    }

    function permit2OrTransferFrom(
        ERC20 token_,
        address permit2_,
        address sender_,
        address recipient_,
        uint256 amount_,
        Permit2Approval memory approval_,
        bool validateBalance_
    ) internal {
        // If a Permit2 approval signature is provided, use it to transfer the quote token
        if (permit2_ != address(0) && approval_.signature.length > 0) {
            permit2TransferFrom(
                token_, permit2_, sender_, recipient_, amount_, approval_, validateBalance_
            );
        }
        // Otherwise fallback to a standard ERC20 transfer
        else {
            transferFrom(token_, sender_, recipient_, amount_, validateBalance_);
        }
    }

    function decodePermit2Approval(
        bytes memory data_
    ) internal pure returns (Permit2Approval memory) {
        // If the length is 0, then approval is not provided
        if (data_.length == 0) {
            return Permit2Approval({nonce: 0, deadline: 0, signature: bytes("")});
        }

        // If the length is non-standard, it is invalid
        if (data_.length != _PERMIT2_PARAMS_LEN) revert InvalidParams();

        return abi.decode(data_, (Permit2Approval));
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// Minimal Permit2 interface, derived from
// https://github.com/Uniswap/permit2/blob/main/src/interfaces/ISignatureTransfer.sol
interface IPermit2 {
    // Token and amount in a permit message.
    struct TokenPermissions {
        // Token to transfer.
        address token;
        // Amount to transfer.
        uint256 amount;
    }

    // The permit2 message.
    struct PermitTransferFrom {
        // Permitted token and amount.
        TokenPermissions permitted;
        // Unique identifier for this permit.
        uint256 nonce;
        // Expiration for this permit.
        uint256 deadline;
    }

    // Transfer details for permitTransferFrom().
    struct SignatureTransferDetails {
        // Recipient of tokens.
        address to;
        // Amount to transfer.
        uint256 requestedAmount;
    }

    // Consume a permit2 message and transfer tokens.
    function permitTransferFrom(
        PermitTransferFrom calldata permit,
        SignatureTransferDetails calldata transferDetails,
        address owner,
        bytes calldata signature
    ) external;
}
// SPDX-License-Identifier: BSL-1.1
pragma solidity 0.8.19;

import {IAuction} from "../interfaces/modules/IAuction.sol";
import {Module} from "./Modules.sol";

abstract contract AuctionModule is IAuction, Module {
    // ========= STATE ========== //

    /// @notice Constant for percentages, in basis points
    /// @dev    1% = 1_00 or 1e2. 100% = 100_00 or 100e2 or 1e4.
    uint48 internal constant _ONE_HUNDRED_PERCENT = 100e2;

    /// @inheritdoc IAuction
    uint48 public minAuctionDuration;

    /// @inheritdoc IAuction
    mapping(uint96 id => Lot lot) public lotData;

    // ========== CONSTRUCTOR ========== //

    constructor(
        address auctionHouse_
    ) Module(auctionHouse_) {}

    /// @inheritdoc Module
    function TYPE() public pure override returns (Type) {
        return Type.Auction;
    }

    // ========== AUCTION MANAGEMENT ========== //

    /// @inheritdoc IAuction
    /// @dev        If the start time is zero, the auction will have a start time of the current block timestamp.
    ///
    ///             This function handles the following:
    ///             - Validates the lot parameters
    ///             - Stores the auction lot
    ///             - Calls the implementation-specific function
    ///
    ///             This function reverts if:
    ///             - The caller is not the parent of the module
    ///             - The start time is in the past
    ///             - The duration is less than the minimum
    function auction(
        uint96 lotId_,
        AuctionParams memory params_,
        uint8 quoteTokenDecimals_,
        uint8 baseTokenDecimals_
    ) external virtual override onlyInternal {
        // Start time must be zero or in the future
        if (params_.start > 0 && params_.start < uint48(block.timestamp)) {
            revert Auction_InvalidStart(params_.start, uint48(block.timestamp));
        }

        // Duration must be at least min duration
        if (params_.duration < minAuctionDuration) {
            revert Auction_InvalidDuration(params_.duration, minAuctionDuration);
        }

        // Create core market data
        Lot memory lot;
        lot.start = params_.start == 0 ? uint48(block.timestamp) : params_.start;
        lot.conclusion = lot.start + params_.duration;
        lot.quoteTokenDecimals = quoteTokenDecimals_;
        lot.baseTokenDecimals = baseTokenDecimals_;
        lot.capacityInQuote = params_.capacityInQuote;
        lot.capacity = params_.capacity;

        // Call internal createAuction function to store implementation-specific data
        _auction(lotId_, lot, params_.implParams);

        // Store lot data
        lotData[lotId_] = lot;
    }

    /// @notice     Implementation-specific auction creation logic
    /// @dev        Auction modules should override this to perform any additional logic
    ///
    /// @param      lotId_              The lot ID
    /// @param      lot_                The lot data
    /// @param      params_             Additional auction parameters
    function _auction(uint96 lotId_, Lot memory lot_, bytes memory params_) internal virtual;

    /// @notice     Cancel an auction lot
    /// @dev        Assumptions:
    ///             - The parent will refund the seller the remaining capacity
    ///             - The parent will verify that the caller is the seller
    ///
    ///             This function handles the following:
    ///             - Calls the implementation-specific function
    ///             - Updates the lot data
    ///
    ///             This function reverts if:
    ///             - the caller is not the parent of the module
    ///             - the lot id is invalid
    ///             - the lot has concluded
    ///
    /// @param      lotId_      The lot id
    function cancelAuction(
        uint96 lotId_
    ) external virtual override onlyInternal {
        // Validation
        _revertIfLotInvalid(lotId_);
        _revertIfLotConcluded(lotId_);

        // Call internal closeAuction function to update any other required parameters
        _cancelAuction(lotId_);

        // Update lot
        Lot storage lot = lotData[lotId_];

        lot.conclusion = uint48(block.timestamp);
        lot.capacity = 0;
    }

    /// @notice     Implementation-specific auction cancellation logic
    /// @dev        Auction modules should override this to perform any additional logic
    ///
    /// @param      lotId_      The lot ID
    function _cancelAuction(
        uint96 lotId_
    ) internal virtual;

    // ========== AUCTION INFORMATION ========== //

    /// @inheritdoc IAuction
    /// @dev        A lot is active if:
    ///             - The lot has not concluded
    ///             - The lot has started
    ///             - The lot has not sold out or been cancelled (capacity > 0)
    ///
    /// @param      lotId_  The lot ID
    /// @return     bool    Whether or not the lot is active
    function isLive(
        uint96 lotId_
    ) public view override returns (bool) {
        return (
            lotData[lotId_].capacity != 0 && uint48(block.timestamp) < lotData[lotId_].conclusion
                && uint48(block.timestamp) >= lotData[lotId_].start
        );
    }

    /// @inheritdoc IAuction
    function isUpcoming(
        uint96 lotId_
    ) public view override returns (bool) {
        return (
            lotData[lotId_].capacity != 0 && uint48(block.timestamp) < lotData[lotId_].conclusion
                && uint48(block.timestamp) < lotData[lotId_].start
        );
    }

    /// @inheritdoc IAuction
    function hasEnded(
        uint96 lotId_
    ) public view override returns (bool) {
        return
            uint48(block.timestamp) >= lotData[lotId_].conclusion || lotData[lotId_].capacity == 0;
    }

    /// @inheritdoc IAuction
    function remainingCapacity(
        uint96 lotId_
    ) external view override returns (uint256) {
        return lotData[lotId_].capacity;
    }

    /// @inheritdoc IAuction
    function capacityInQuote(
        uint96 lotId_
    ) external view override returns (bool) {
        return lotData[lotId_].capacityInQuote;
    }

    /// @inheritdoc IAuction
    function getLot(
        uint96 lotId_
    ) external view override returns (Lot memory) {
        return lotData[lotId_];
    }

    // ========== ADMIN FUNCTIONS ========== //

    /// @notice     Set the minimum auction duration
    /// @dev        This function must be called by the parent AuctionHouse, and
    ///             can be called by governance using `execOnModule`.
    function setMinAuctionDuration(
        uint48 duration_
    ) external onlyParent {
        minAuctionDuration = duration_;
    }

    // ========== MODIFIERS ========== //

    /// @notice     Checks that `lotId_` is valid
    /// @dev        Should revert if the lot ID is invalid
    ///             Inheriting contracts can override this to implement custom logic
    ///
    /// @param      lotId_  The lot ID
    function _revertIfLotInvalid(
        uint96 lotId_
    ) internal view virtual {
        if (lotData[lotId_].start == 0) revert Auction_InvalidLotId(lotId_);
    }

    /// @notice     Checks that the lot represented by `lotId_` has not started
    /// @dev        Should revert if the lot has not started
    function _revertIfBeforeLotStart(
        uint96 lotId_
    ) internal view virtual {
        if (uint48(block.timestamp) < lotData[lotId_].start) revert Auction_LotNotActive(lotId_);
    }

    /// @notice     Checks that the lot represented by `lotId_` has started
    /// @dev        Should revert if the lot has started
    function _revertIfLotStarted(
        uint96 lotId_
    ) internal view virtual {
        if (uint48(block.timestamp) >= lotData[lotId_].start) revert Auction_LotActive(lotId_);
    }

    /// @notice     Checks that the lot represented by `lotId_` has not concluded
    /// @dev        Should revert if the lot has not concluded
    function _revertIfBeforeLotConcluded(
        uint96 lotId_
    ) internal view virtual {
        if (uint48(block.timestamp) < lotData[lotId_].conclusion && lotData[lotId_].capacity > 0) {
            revert Auction_LotNotConcluded(lotId_);
        }
    }

    /// @notice     Checks that the lot represented by `lotId_` has not concluded
    /// @dev        Should revert if the lot has concluded
    function _revertIfLotConcluded(
        uint96 lotId_
    ) internal view virtual {
        // Beyond the conclusion time
        if (uint48(block.timestamp) >= lotData[lotId_].conclusion) {
            revert Auction_LotNotActive(lotId_);
        }

        // Capacity is sold-out, or cancelled
        if (lotData[lotId_].capacity == 0) revert Auction_LotNotActive(lotId_);
    }

    /// @notice     Checks that the lot represented by `lotId_` is active
    /// @dev        Should revert if the lot is not active
    ///             Inheriting contracts can override this to implement custom logic
    ///
    /// @param      lotId_  The lot ID
    function _revertIfLotInactive(
        uint96 lotId_
    ) internal view virtual {
        if (!isLive(lotId_)) revert Auction_LotNotActive(lotId_);
    }

    /// @notice     Checks that the lot represented by `lotId_` is active
    /// @dev        Should revert if the lot is active
    ///             Inheriting contracts can override this to implement custom logic
    ///
    /// @param      lotId_  The lot ID
    function _revertIfLotActive(
        uint96 lotId_
    ) internal view virtual {
        if (isLive(lotId_)) revert Auction_LotActive(lotId_);
    }
}
// SPDX-License-Identifier: BSL-1.1
pragma solidity 0.8.19;

import {ICondenser} from "../interfaces/modules/ICondenser.sol";

import {Module} from "./Modules.sol";

/// @title  CondenserModule
/// @notice The CondenserModule contract is an abstract contract that provides condenser functionality for the AuctionHouse.
/// @dev    This contract is intended to be inherited by condenser modules that are used in the AuctionHouse.
abstract contract CondenserModule is ICondenser, Module {}
// SPDX-License-Identifier: BSL-1.1
pragma solidity 0.8.19;

import {ERC6909} from "@solmate-6.7.0/tokens/ERC6909.sol";
import {ERC6909Metadata} from "../lib/ERC6909Metadata.sol";
import {Module} from "./Modules.sol";
import {IDerivative} from "../interfaces/modules/IDerivative.sol";

/// @title  DerivativeModule
/// @notice The DerivativeModule contract is an abstract contract that provides derivative functionality for the AuctionHouse.
/// @dev    This contract is intended to be inherited by derivative modules that are used in the AuctionHouse.
abstract contract DerivativeModule is IDerivative, ERC6909, ERC6909Metadata, Module {
    // ========== STATE VARIABLES ========== //

    /// @inheritdoc IDerivative
    mapping(uint256 tokenId => Token metadata) public tokenMetadata;

    // ========== DERIVATIVE INFORMATION ========== //

    /// @inheritdoc IDerivative
    function getTokenMetadata(
        uint256 tokenId
    ) external view virtual returns (Token memory) {
        return tokenMetadata[tokenId];
    }

    // ========== ERC6909 TOKEN SUPPLY EXTENSION ========== //

    /// @inheritdoc ERC6909Metadata
    function totalSupply(
        uint256 tokenId
    ) public view virtual override returns (uint256) {
        return tokenMetadata[tokenId].supply;
    }
}
// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity >=0.8.19;

// Inspired by Default framework keycode management of dependencies and based on the Modules pattern

/// @notice     5 byte/character identifier for the Module
/// @dev        3-5 characters from A-Z
type Keycode is bytes5;

/// @notice     7 byte identifier for the Module, including version
/// @dev        2 characters from 0-9 (a version number), followed by Keycode
type Veecode is bytes7;

error InvalidVeecode(Veecode veecode_);

function toKeycode(
    bytes5 keycode_
) pure returns (Keycode) {
    return Keycode.wrap(keycode_);
}

function fromKeycode(
    Keycode keycode_
) pure returns (bytes5) {
    return Keycode.unwrap(keycode_);
}

// solhint-disable-next-line func-visibility
function wrapVeecode(Keycode keycode_, uint8 version_) pure returns (Veecode) {
    // Get the digits of the version
    bytes1 firstDigit = bytes1(version_ / 10 + 0x30);
    bytes1 secondDigit = bytes1((version_ % 10) + 0x30);

    // Pack everything and wrap as a Veecode
    return Veecode.wrap(bytes7(abi.encodePacked(firstDigit, secondDigit, keycode_)));
}

// solhint-disable-next-line func-visibility
function toVeecode(
    bytes7 veecode_
) pure returns (Veecode) {
    return Veecode.wrap(veecode_);
}

// solhint-disable-next-line func-visibility
function fromVeecode(
    Veecode veecode_
) pure returns (bytes7) {
    return Veecode.unwrap(veecode_);
}

function unwrapVeecode(
    Veecode veecode_
) pure returns (Keycode, uint8) {
    bytes7 unwrapped = Veecode.unwrap(veecode_);

    // Get the version from the first 2 bytes
    if (unwrapped[0] < 0x30 || unwrapped[0] > 0x39 || unwrapped[1] < 0x30 || unwrapped[1] > 0x39) {
        revert InvalidVeecode(veecode_);
    }
    uint8 version = (uint8(unwrapped[0]) - 0x30) * 10;
    version += uint8(unwrapped[1]) - 0x30;

    // Get the Keycode by shifting the full Veecode to the left by 2 bytes
    Keycode keycode = Keycode.wrap(bytes5(unwrapped << 16));

    return (keycode, version);
}

function keycodeFromVeecode(
    Veecode veecode_
) pure returns (Keycode) {
    (Keycode keycode,) = unwrapVeecode(veecode_);
    return keycode;
}

// solhint-disable-next-line func-visibility
function ensureValidVeecode(
    Veecode veecode_
) pure {
    bytes7 unwrapped = Veecode.unwrap(veecode_);
    for (uint256 i; i < 7;) {
        bytes1 char = unwrapped[i];
        if (i < 2) {
            // First 2 characters must be the version, each character is a number 0-9
            if (char < 0x30 || char > 0x39) revert InvalidVeecode(veecode_);
        } else if (i < 5) {
            // Next 3 characters after the first 3 can be A-Z
            if (char < 0x41 || char > 0x5A) revert InvalidVeecode(veecode_);
        } else {
            // Last 2 character must be A-Z or blank
            if (char != 0x00 && (char < 0x41 || char > 0x5A)) revert InvalidVeecode(veecode_);
        }
        unchecked {
            i++;
        }
    }

    // Check that the version is not 0
    // This is because the version is by default 0 if the module is not installed
    (, uint8 moduleVersion) = unwrapVeecode(veecode_);
    if (moduleVersion == 0) revert InvalidVeecode(veecode_);
}
// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.19;

import {Owned} from "@solmate-6.7.0/auth/Owned.sol";
import "./Keycode.sol";

/// @notice    Abstract contract that provides functionality for installing and interacting with modules.
/// @dev       This contract is intended to be inherited by any contract that needs to install modules.
abstract contract WithModules is Owned {
    // ========= ERRORS ========= //

    error InvalidModuleInstall(Keycode keycode_, uint8 version_);
    error ModuleNotInstalled(Keycode keycode_, uint8 version_);
    error ModuleExecutionReverted(bytes error_);
    error ModuleAlreadySunset(Keycode keycode_);
    error ModuleIsSunset(Keycode keycode_);
    error TargetNotAContract(address target_);

    // ========= EVENTS ========= //

    event ModuleInstalled(Keycode indexed keycode, uint8 indexed version, address indexed location);

    event ModuleSunset(Keycode indexed keycode);

    // ========= CONSTRUCTOR ========= //

    constructor(
        address owner_
    ) Owned(owner_) {}

    // ========= STRUCTS ========= //

    struct ModStatus {
        uint8 latestVersion;
        bool sunset;
    }

    // ========= STATE VARIABLES ========= //

    /// @notice Array of the Keycodes corresponding to the currently installed modules.
    Keycode[] public modules;

    /// @notice The number of modules installed.
    uint256 public modulesCount;

    /// @notice Mapping of Veecode to Module address.
    mapping(Veecode => Module) public getModuleForVeecode;

    /// @notice Mapping of Keycode to module status information.
    mapping(Keycode => ModStatus) public getModuleStatus;

    bool public isExecOnModule;

    // ========= MODULE MANAGEMENT ========= //

    /// @notice     Installs a module. Can be used to install a new module or upgrade an existing one.
    /// @dev        The version of the installed module must be one greater than the latest version. If it's a new module, then the version must be 1.
    /// @dev        Only one version of a module is active for creation functions at a time. Older versions continue to work for existing data.
    /// @dev        If a module is currently sunset, installing a new version will remove the sunset.
    ///
    /// @dev        This function reverts if:
    /// @dev        - The caller is not the owner
    /// @dev        - The module is not a contract
    /// @dev        - The module has an invalid Veecode
    /// @dev        - The module (or other versions) is already installed
    /// @dev        - The module version is not one greater than the latest version
    ///
    /// @param      newModule_  The new module
    function installModule(
        Module newModule_
    ) external onlyOwner {
        // Validate new module is a contract, has correct parent, and has valid Keycode
        _ensureContract(address(newModule_));
        Veecode veecode = newModule_.VEECODE();
        ensureValidVeecode(veecode);
        (Keycode keycode, uint8 version) = unwrapVeecode(veecode);

        // Validate that the module version is one greater than the latest version
        ModStatus storage status = getModuleStatus[keycode];
        if (version != status.latestVersion + 1) revert InvalidModuleInstall(keycode, version);

        // Store module data and remove sunset if applied
        status.latestVersion = version;
        if (status.sunset) status.sunset = false;
        getModuleForVeecode[veecode] = newModule_;

        // If the module is not already installed, add it to the list of modules
        if (version == uint8(1)) {
            modules.push(keycode);
            modulesCount++;
        }

        // Initialize the module
        newModule_.INIT();

        emit ModuleInstalled(keycode, version, address(newModule_));
    }

    function _ensureContract(
        address target_
    ) internal view {
        if (target_.code.length == 0) revert TargetNotAContract(target_);
    }

    /// @notice         Sunsets a module
    /// @notice         Sunsetting a module prevents future deployments that use the module, but functionality remains for existing users.
    /// @notice         Modules should implement functionality such that creation functions are disabled if sunset.
    /// @dev            Sunset is used to disable a module type without installing a new one.
    ///
    /// @dev            This function reverts if:
    /// @dev            - The caller is not the owner
    /// @dev            - The module is not installed
    /// @dev            - The module is already sunset
    ///
    /// @param          keycode_    The module keycode
    function sunsetModule(
        Keycode keycode_
    ) external onlyOwner {
        // Check that the module is installed
        if (!_moduleIsInstalled(keycode_)) revert ModuleNotInstalled(keycode_, 0);

        // Check that the module is not already sunset
        ModStatus storage status = getModuleStatus[keycode_];
        if (status.sunset) revert ModuleAlreadySunset(keycode_);

        // Set the module to sunset
        status.sunset = true;

        emit ModuleSunset(keycode_);
    }

    /// @notice         Checks whether any module is installed under the keycode
    ///
    /// @param          keycode_    The module keycode
    /// @return         True if the module is installed, false otherwise
    function _moduleIsInstalled(
        Keycode keycode_
    ) internal view returns (bool) {
        // Any module that has been installed will have a latest version greater than 0
        // We can check not equal here to save gas
        return getModuleStatus[keycode_].latestVersion != uint8(0);
    }

    /// @notice         Returns the address of the latest version of a module
    /// @dev            This function reverts if:
    /// @dev            - The module is not installed
    /// @dev            - The module is sunset
    ///
    /// @param          keycode_    The module keycode
    /// @return         The address of the latest version of the module
    function _getLatestModuleIfActive(
        Keycode keycode_
    ) internal view returns (address) {
        // Check that the module is installed
        ModStatus memory status = getModuleStatus[keycode_];
        if (status.latestVersion == uint8(0)) revert ModuleNotInstalled(keycode_, 0);

        // Check that the module is not sunset
        if (status.sunset) revert ModuleIsSunset(keycode_);

        // Wrap into a Veecode, get module address and return
        // We don't need to check that the Veecode is valid because we already checked that the module is installed and pulled the version from the contract
        Veecode veecode = wrapVeecode(keycode_, status.latestVersion);
        return address(getModuleForVeecode[veecode]);
    }

    /// @notice         Returns the address of a module
    /// @dev            This function reverts if:
    /// @dev            - The specific module and version is not installed
    ///
    /// @param          keycode_    The module keycode
    /// @param          version_    The module version
    /// @return         The address of the module
    function _getModuleIfInstalled(
        Keycode keycode_,
        uint8 version_
    ) internal view returns (address) {
        // Check that the module is installed
        ModStatus memory status = getModuleStatus[keycode_];
        if (status.latestVersion == uint8(0)) revert ModuleNotInstalled(keycode_, 0);

        // Check that the module version is less than or equal to the latest version and greater than 0
        if (version_ > status.latestVersion || version_ == 0) {
            revert ModuleNotInstalled(keycode_, version_);
        }

        // Wrap into a Veecode, get module address and return
        // We don't need to check that the Veecode is valid because we already checked that the module is installed and pulled the version from the contract
        Veecode veecode = wrapVeecode(keycode_, version_);
        return address(getModuleForVeecode[veecode]);
    }

    /// @notice         Returns the address of a module
    /// @dev            This function reverts if:
    /// @dev            - The specific module and version is not installed
    ///
    /// @param          veecode_    The module Veecode
    /// @return         The address of the module
    function _getModuleIfInstalled(
        Veecode veecode_
    ) internal view returns (address) {
        // In this case, it's simpler to check that the stored address is not zero
        Module mod = getModuleForVeecode[veecode_];
        if (address(mod) == address(0)) {
            (Keycode keycode, uint8 version) = unwrapVeecode(veecode_);
            revert ModuleNotInstalled(keycode, version);
        }
        return address(mod);
    }

    // ========= MODULE FUNCTIONS ========= //

    /// @notice         Performs a call on a module
    /// @notice         This can be used to perform administrative functions on a module, such as setting parameters or calling permissioned functions
    /// @dev            This function reverts if:
    /// @dev            - The caller is not the parent
    /// @dev            - The module is not installed
    /// @dev            - The call is made to a prohibited function
    /// @dev            - The call reverted
    ///
    /// @param          veecode_    The module Veecode
    /// @param          callData_   The call data
    /// @return         The return data from the call
    function execOnModule(
        Veecode veecode_,
        bytes calldata callData_
    ) external onlyOwner returns (bytes memory) {
        // Set the flag to true
        isExecOnModule = true;

        // Check that the module is installed (or revert)
        // Call the module
        (bool success, bytes memory returnData) = _getModuleIfInstalled(veecode_).call(callData_);
        if (!success) revert ModuleExecutionReverted(returnData);

        // Reset the flag to false
        isExecOnModule = false;

        return returnData;
    }
}

/// @notice Modules are isolated components of a contract that can be upgraded independently.
/// @dev    Two main patterns are considered for Modules:
/// @dev    1. Directly calling modules from the parent contract to execute upgradable logic or having the option to add new sub-components to a contract
/// @dev    2. Delegate calls to modules to execute upgradable logic, similar to a proxy, but only for specific functions and being able to add new sub-components to a contract
abstract contract Module {
    // ========= ERRORS ========= //

    /// @notice Error when a module function is called by a non-parent contract
    error Module_OnlyParent(address caller_);

    /// @notice Error when a module function is called by a non-internal contract
    error Module_OnlyInternal();

    /// @notice Error when the parent contract is invalid
    error Module_InvalidParent(address parent_);

    // ========= DATA TYPES ========= //

    /// @notice Enum of module types
    enum Type {
        Auction,
        Derivative,
        Condenser,
        Transformer
    }

    // ========= STATE VARIABLES ========= //

    /// @notice The parent contract for this module.
    address public immutable PARENT;

    // ========= CONSTRUCTOR ========= //

    constructor(
        address parent_
    ) {
        if (parent_ == address(0)) revert Module_InvalidParent(parent_);

        PARENT = parent_;
    }

    // ========= MODIFIERS ========= //

    /// @notice Modifier to restrict functions to be called only by the parent module.
    modifier onlyParent() {
        if (msg.sender != PARENT) revert Module_OnlyParent(msg.sender);
        _;
    }

    /// @notice Modifier to restrict functions to be called only by internal module.
    /// @notice If a function is called through `execOnModule()` on the parent contract, this modifier will revert.
    /// @dev    This modifier can be used to prevent functions from being called by governance or other external actors through `execOnModule()`.
    modifier onlyInternal() {
        if (msg.sender != PARENT) revert Module_OnlyParent(msg.sender);

        if (WithModules(PARENT).isExecOnModule()) revert Module_OnlyInternal();
        _;
    }

    // ========= FUNCTIONS ========= //

    /// @notice     2 byte identifier for the module type
    /// @dev        This enables the parent contract to check that the module Keycode specified
    /// @dev        is of the correct type
    // solhint-disable-next-line func-name-mixedcase
    function TYPE() public pure virtual returns (Type) {}

    /// @notice 7 byte, versioned identifier for the module. 2 characters from 0-9 that signify the version and 3-5 characters from A-Z.
    // solhint-disable-next-line func-name-mixedcase
    function VEECODE() public pure virtual returns (Veecode) {}

    /// @notice Initialization function for the module
    /// @dev    This function is called when the module is installed or upgraded by the module.
    /// @dev    MUST BE GATED BY onlyParent. Used to encompass any initialization or upgrade logic.
    // solhint-disable-next-line func-name-mixedcase
    function INIT() external virtual onlyParent {}
}
// SPDX-License-Identifier: BSL-1.1
pragma solidity 0.8.19;

// Interfaces
import {IAuction} from "../../interfaces/modules/IAuction.sol";
import {IBatchAuction} from "../../interfaces/modules/IBatchAuction.sol";

// Auctions
import {AuctionModule} from "../Auction.sol";

/// @title  Batch Auction Module
/// @notice A base contract for batch auctions
abstract contract BatchAuctionModule is IBatchAuction, AuctionModule {
    // ========== STATE VARIABLES ========== //

    /// @inheritdoc IBatchAuction
    uint48 public dedicatedSettlePeriod;

    /// @inheritdoc IBatchAuction
    mapping(uint96 => bytes) public lotAuctionOutput;

    /// @inheritdoc IAuction
    function auctionType() external pure override returns (AuctionType) {
        return AuctionType.Batch;
    }

    // ========== BATCH AUCTIONS ========== //

    /// @inheritdoc IBatchAuction
    /// @dev        Implements a basic bid function that:
    ///             - Validates the lot and bid parameters
    ///             - Calls the implementation-specific function
    ///
    ///             This function reverts if:
    ///             - The lot id is invalid
    ///             - The lot has not started
    ///             - The lot has concluded
    ///             - The lot is already settled
    ///             - The caller is not an internal module
    function bid(
        uint96 lotId_,
        address bidder_,
        address referrer_,
        uint256 amount_,
        bytes calldata auctionData_
    ) external virtual override onlyInternal returns (uint64 bidId) {
        // Standard validation
        _revertIfLotInvalid(lotId_);
        _revertIfBeforeLotStart(lotId_);
        _revertIfLotConcluded(lotId_);
        _revertIfLotSettled(lotId_);

        // Call implementation-specific logic
        return _bid(lotId_, bidder_, referrer_, amount_, auctionData_);
    }

    /// @notice     Implementation-specific bid logic
    /// @dev        Auction modules should override this to perform any additional logic, such as validation and storage.
    ///
    ///             The returned `bidId` should be a unique and persistent identifier for the bid,
    ///             which can be used in subsequent calls (e.g. `cancelBid()` or `settle()`).
    ///
    /// @param      lotId_          The lot ID
    /// @param      bidder_         The bidder of the purchased tokens
    /// @param      referrer_       The referrer of the bid
    /// @param      amount_         The amount of quote tokens to bid
    /// @param      auctionData_    The auction-specific data
    /// @return     bidId           The bid ID
    function _bid(
        uint96 lotId_,
        address bidder_,
        address referrer_,
        uint256 amount_,
        bytes calldata auctionData_
    ) internal virtual returns (uint64 bidId);

    /// @inheritdoc IBatchAuction
    /// @dev        Implements a basic refundBid function that:
    ///             - Validates the lot and bid parameters
    ///             - Calls the implementation-specific function
    ///
    ///             This function reverts if:
    ///             - The lot id is invalid
    ///             - The lot has not started
    ///             - The lot is concluded, decrypted or settled
    ///             - The bid id is invalid
    ///             - `caller_` is not the bid owner
    ///             - The bid is claimed or refunded
    ///             - The caller is not an internal module
    function refundBid(
        uint96 lotId_,
        uint64 bidId_,
        uint256 index_,
        address caller_
    ) external virtual override onlyInternal returns (uint256 refund) {
        // Standard validation
        _revertIfLotInvalid(lotId_);
        _revertIfBeforeLotStart(lotId_);
        _revertIfBidInvalid(lotId_, bidId_);
        _revertIfNotBidOwner(lotId_, bidId_, caller_);
        _revertIfBidClaimed(lotId_, bidId_);
        _revertIfLotConcluded(lotId_);

        // Call implementation-specific logic
        return _refundBid(lotId_, bidId_, index_, caller_);
    }

    /// @notice     Implementation-specific bid refund logic
    /// @dev        Auction modules should override this to perform any additional logic, such as validation and storage.
    ///
    ///             Implementation functions should check for lot cancellation, if needed.
    ///
    /// @param      lotId_      The lot ID
    /// @param      bidId_      The bid ID
    /// @param      index_      The index of the bid ID in the auction's bid list
    /// @param      caller_     The caller
    /// @return     refund      The amount of quote tokens to refund
    function _refundBid(
        uint96 lotId_,
        uint64 bidId_,
        uint256 index_,
        address caller_
    ) internal virtual returns (uint256 refund);

    /// @inheritdoc IBatchAuction
    /// @dev        Implements a basic claimBids function that:
    ///             - Validates the lot and bid parameters
    ///             - Calls the implementation-specific function
    ///
    ///             This function reverts if:
    ///             - The lot id is invalid
    ///             - The lot is not settled
    ///             - The caller is not an internal module
    function claimBids(
        uint96 lotId_,
        uint64[] calldata bidIds_
    )
        external
        virtual
        override
        onlyInternal
        returns (BidClaim[] memory bidClaims, bytes memory auctionOutput)
    {
        // Standard validation
        _revertIfLotInvalid(lotId_);
        _revertIfLotNotSettled(lotId_);

        // Call implementation-specific logic
        return _claimBids(lotId_, bidIds_);
    }

    /// @notice     Implementation-specific bid claim logic
    /// @dev        Auction modules should override this to perform any additional logic, such as:
    ///             - Validating the auction-specific parameters
    ///             - Validating the validity and status of each bid
    ///             - Updating the bid data
    ///
    /// @param      lotId_          The lot ID
    /// @param      bidIds_         The bid IDs
    /// @return     bidClaims       The bid claim data
    /// @return     auctionOutput   The auction-specific output
    function _claimBids(
        uint96 lotId_,
        uint64[] calldata bidIds_
    ) internal virtual returns (BidClaim[] memory bidClaims, bytes memory auctionOutput);

    /// @inheritdoc IBatchAuction
    /// @dev        Implements a basic settle function that:
    ///             - Validates the lot and bid parameters
    ///             - Calls the implementation-specific function
    ///             - Updates the lot data
    ///
    ///             This function reverts if:
    ///             - The lot id is invalid
    ///             - The lot has not started
    ///             - The lot is active
    ///             - The lot has already been settled
    ///             - The caller is not an internal module
    function settle(
        uint96 lotId_,
        uint256 num_
    )
        external
        virtual
        override
        onlyInternal
        returns (
            uint256 totalIn,
            uint256 totalOut,
            uint256 capacity,
            bool finished,
            bytes memory auctionOutput
        )
    {
        // Standard validation
        _revertIfLotInvalid(lotId_);
        _revertIfBeforeLotStart(lotId_);
        _revertIfLotActive(lotId_);
        _revertIfLotSettled(lotId_);

        Lot storage lot = lotData[lotId_];

        // Call implementation-specific logic
        (totalIn, totalOut, finished, auctionOutput) = _settle(lotId_, num_);

        // Store sold and purchased amounts
        lotData[lotId_].purchased = totalIn;
        lotData[lotId_].sold = totalOut;
        lotAuctionOutput[lotId_] = auctionOutput;

        return (totalIn, totalOut, lot.capacity, finished, auctionOutput);
    }

    /// @notice     Implementation-specific lot settlement logic
    /// @dev        Auction modules should override this to perform any additional logic, such as:
    ///             - Validating the auction-specific parameters
    ///             - Determining the winning bids
    ///             - Updating the lot data
    ///
    /// @param      lotId_          The lot ID
    /// @param      num_            The number of bids to settle in this pass (capped at the remaining number if more is provided)
    /// @return     totalIn         The total amount of quote tokens that filled the auction
    /// @return     totalOut        The total amount of base tokens sold
    /// @return     finished        Whether the settlement is finished
    /// @return     auctionOutput   The auction-type specific output to be used with a condenser
    function _settle(
        uint96 lotId_,
        uint256 num_
    )
        internal
        virtual
        returns (uint256 totalIn, uint256 totalOut, bool finished, bytes memory auctionOutput);

    /// @inheritdoc IBatchAuction
    /// @dev        Implements a basic abort function that:
    ///             - Validates the lot id and state
    ///             - Calls the implementation-specific function
    ///
    ///             The abort function allows anyone to abort the lot after the conclusion and settlement time has passed.
    ///             This can be useful if the lot is unable to be settled, or if the seller is unwilling to settle the lot.
    ///
    ///             This function reverts if:
    ///             - The lot id is invalid
    ///             - The lot has not concluded
    ///             - The lot is in the dedicated settle period
    ///             - The lot is settled (after which it cannot be aborted)
    function abort(
        uint96 lotId_
    ) external virtual override onlyInternal {
        // Standard validation
        _revertIfLotInvalid(lotId_);
        _revertIfBeforeLotConcluded(lotId_);
        _revertIfDedicatedSettlePeriod(lotId_);
        _revertIfLotSettled(lotId_);

        // Call implementation-specific logic
        _abort(lotId_);
    }

    /// @notice     Implementation-specific lot settlement logic
    /// @dev        Auction modules should override this to perform any additional logic, such as:
    ///             - Validating the auction-specific parameters
    ///             - Updating auction-specific data
    ///
    /// @param      lotId_  The lot ID
    function _abort(
        uint96 lotId_
    ) internal virtual;

    // ========== ADMIN CONFIGURATION ========== //

    function setDedicatedSettlePeriod(
        uint48 period_
    ) external onlyParent {
        // Dedicated settle period cannot be more than 7 days
        if (period_ > 7 days) revert Auction_InvalidParams();

        dedicatedSettlePeriod = period_;
    }

    // ========== MODIFIERS ========== //

    /// @notice     Checks that the lot represented by `lotId_` is not settled
    /// @dev        Should revert if the lot is settled
    ///             Inheriting contracts must override this to implement custom logic
    ///
    /// @param      lotId_  The lot ID
    function _revertIfLotSettled(
        uint96 lotId_
    ) internal view virtual;

    /// @notice     Checks that the lot represented by `lotId_` is settled
    /// @dev        Should revert if the lot is not settled
    ///             Inheriting contracts must override this to implement custom logic
    ///
    /// @param      lotId_  The lot ID
    function _revertIfLotNotSettled(
        uint96 lotId_
    ) internal view virtual;

    /// @notice     Checks that the lot and bid combination is valid
    /// @dev        Should revert if the bid is invalid
    ///             Inheriting contracts must override this to implement custom logic
    ///
    /// @param      lotId_  The lot ID
    /// @param      bidId_  The bid ID
    function _revertIfBidInvalid(uint96 lotId_, uint64 bidId_) internal view virtual;

    /// @notice     Checks that `caller_` is the bid owner
    /// @dev        Should revert if `caller_` is not the bid owner
    ///             Inheriting contracts must override this to implement custom logic
    ///
    /// @param      lotId_      The lot ID
    /// @param      bidId_      The bid ID
    /// @param      caller_     The caller
    function _revertIfNotBidOwner(
        uint96 lotId_,
        uint64 bidId_,
        address caller_
    ) internal view virtual;

    /// @notice     Checks that the bid is not claimed
    /// @dev        Should revert if the bid is claimed
    ///             Inheriting contracts must override this to implement custom logic
    ///
    /// @param      lotId_      The lot ID
    /// @param      bidId_      The bid ID
    function _revertIfBidClaimed(uint96 lotId_, uint64 bidId_) internal view virtual;

    function _revertIfDedicatedSettlePeriod(
        uint96 lotId_
    ) internal view {
        // Auction must not be in the dedicated settle period
        uint48 conclusion = lotData[lotId_].conclusion;
        if (
            uint48(block.timestamp) >= conclusion
                && uint48(block.timestamp) < conclusion + dedicatedSettlePeriod
        ) {
            revert Auction_DedicatedSettlePeriod(lotId_);
        }
    }
}