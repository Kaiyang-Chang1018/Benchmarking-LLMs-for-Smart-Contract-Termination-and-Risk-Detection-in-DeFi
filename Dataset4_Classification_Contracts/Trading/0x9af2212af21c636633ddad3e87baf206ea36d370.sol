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
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {ReentrancyGuard} from "solmate/utils/ReentrancyGuard.sol";
import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";
import {EmToken} from "./EmToken.sol";
import {EmHeadmaster} from "./EmHeadmaster.sol";
import {EmLedger} from "./EmLedger.sol";
import {ExternalEntities} from "./ExternalEntities.sol";

error InsufficientOutput();
error InsufficientTokenReserve();
error InsufficientEthReserve();
error InsufficientMcap();
error TooMuchMcap();
error AlreadyGraduated();
error NotEmToken();
error DeadlineExceeded();
error InvalidAmountIn();
error Forbidden();
error FeeTooHigh();
error Paused();

/// @notice Owner can pause trading, set fees, and set the graduation strategy, but cannot withdraw funds or modify the bonding curve.
contract EmCore is ReentrancyGuard {
    using FixedPointMathLib for uint256;

    struct Pool {
        EmToken token;
        uint256 tokenReserve;
        uint256 virtualTokenReserve;
        uint256 ethReserve;
        uint256 virtualEthReserve;
        uint256 lastPrice;
        uint256 lastMcapInEth;
        uint256 lastTimestamp;
        uint256 lastBlock;
        address creator;
        address headmaster;
        // poolId is not limited to address to support non-uniswap styled AMMs
        uint256 poolId;
        // K is never updated
        uint256 K;
    }

    uint8 public constant DECIMALS = 18;
    uint256 public constant FEE_DENOMINATOR = 10000;
    uint256 public constant MAX_FEE = 1000; // 10%
    uint256 public feeRate_ = 100; // 1%

    uint256 public constant INIT_VIRTUAL_TOKEN_RESERVE = 1073000000 ether;
    uint256 public constant INIT_REAL_TOKEN_RESERVE = 793100000 ether;
    uint256 public constant TOTAL_SUPPLY = 1000000000 ether;
    uint256 public initVirtualEthReserve_;
    uint256 public graduationThreshold_;
    uint256 public K_;

    mapping(EmToken => Pool) public pools_;
    EmLedger public emLedger_;

    uint256 public creationFee_ = 0;
    uint256 public graduationFeeRate_ = 200;
    address public feeTo_;
    bool public paused_;
    EmHeadmaster public headmaster_; // the contract which implements the graduation logic

    ExternalEntities public externalEntities_;

    /*//////////////////////////////////////////////////
    /////////////   PERMISSIONED METHODS   /////////////
    //////////////////////////////////////////////////*/

    address public owner_;

    modifier onlyOwner() {
        if (msg.sender != owner_) revert Forbidden();
        _;
    }

    function setFeeTo(address feeTo) external onlyOwner {
        feeTo_ = feeTo;
    }

    function setFeeRate(uint256 feeRate) external onlyOwner {
        if (feeRate > MAX_FEE) revert FeeTooHigh();
        feeRate_ = feeRate;
    }

    function setGraduationFeeRate(uint256 feeRate) external onlyOwner {
        if (feeRate > MAX_FEE) revert FeeTooHigh();
        graduationFeeRate_ = feeRate;
    }

    function setEmLedger(EmLedger _ledger) external onlyOwner {
        emLedger_ = _ledger;
    }

    function setInitVirtualEthReserve(
        uint256 initVirtualEthReserve
    ) external onlyOwner {
        initVirtualEthReserve_ = initVirtualEthReserve;
        K_ = initVirtualEthReserve_ * INIT_VIRTUAL_TOKEN_RESERVE;
        graduationThreshold_ =
            K_ /
            (INIT_VIRTUAL_TOKEN_RESERVE - INIT_REAL_TOKEN_RESERVE) -
            initVirtualEthReserve_;
    }

    function setCreationFee(uint256 fee) external onlyOwner {
        creationFee_ = fee;
    }

    function setHeadmaster(EmHeadmaster headmaster) external onlyOwner {
        headmaster_ = headmaster;
    }

    function setExternalEntities(
        ExternalEntities externalEntities
    ) external onlyOwner {
        externalEntities_ = externalEntities;
    }

    function setOwner(address owner) external onlyOwner {
        owner_ = owner;
    }

    function setPaused(bool paused) external onlyOwner {
        paused_ = paused;
    }

    /*//////////////////////////////////////////////////
    ////////////////   CONSTRUCTOR   ///////////////////
    //////////////////////////////////////////////////*/

    constructor(uint256 initVirtualEthReserve) {
        feeTo_ = msg.sender;
        owner_ = msg.sender;
        paused_ = false;

        emLedger_ = new EmLedger();
        initVirtualEthReserve_ = initVirtualEthReserve;
        K_ = initVirtualEthReserve_ * INIT_VIRTUAL_TOKEN_RESERVE;
        graduationThreshold_ =
            K_ /
            (INIT_VIRTUAL_TOKEN_RESERVE - INIT_REAL_TOKEN_RESERVE) -
            initVirtualEthReserve_;
    }

    /*//////////////////////////////////////////////////
    //////////////////   ASSERTIONS   //////////////////
    //////////////////////////////////////////////////*/

    modifier checkDeadline(uint256 deadline) {
        if (block.timestamp > deadline) revert DeadlineExceeded();
        _;
    }

    modifier onlyUnpaused() {
        if (paused_) revert Paused();
        _;
    }

    modifier onlyUngraduated(EmToken token) {
        if (pools_[token].headmaster != address(0)) revert AlreadyGraduated();
        if (pools_[token].ethReserve > graduationThreshold_) {
            revert TooMuchMcap();
        }
        _;
    }

    modifier onlyEmToken(EmToken token) {
        if (token == EmToken(address(0)) || pools_[token].token != token) {
            revert NotEmToken();
        }
        _;
    }

    function _isMcapGraduable(EmToken token) private view returns (bool) {
        return pools_[token].ethReserve >= graduationThreshold_;
    }

    /*//////////////////////////////////////////////////
    ////////////////////   EVENTS   ////////////////////
    //////////////////////////////////////////////////*/

    event TokenCreated(EmToken indexed token, address indexed creator);
    event TokenGraduated(
        EmToken indexed token,
        EmHeadmaster indexed headmaster,
        uint256 indexed poolId,
        uint256 amountToken,
        uint256 amountETH
    );
    event Buy(
        EmToken indexed token,
        address indexed sender,
        uint256 amountIn,
        uint256 amountOut,
        address indexed to
    );
    event Sell(
        EmToken indexed token,
        address indexed sender,
        uint256 amountIn,
        uint256 amountOut,
        address indexed to
    );
    event PriceUpdate(
        EmToken indexed token,
        address indexed sender,
        uint256 price,
        uint256 mcapInEth
    );

    /*//////////////////////////////////////////////////
    ////////////////   POOL FUNCTIONS   ////////////////
    //////////////////////////////////////////////////*/

    /// @notice Creates a new token in the EmCore.
    /// @param name The name of the token.
    /// @param symbol The symbol of the token.
    /// @param initAmountIn The initial amount of ETH to swap for the token.
    /// @param description The description of the token.
    /// @param extended The extended description of the token, typically a JSON string.
    /// @return token The newly created token.
    /// @return amountOut The output amount of token the creator received.
    function createToken(
        string memory name,
        string memory symbol,
        uint256 initAmountIn,
        string memory description,
        string memory extended
    ) external payable onlyUnpaused returns (EmToken token, uint256 amountOut) {
        if (msg.value != initAmountIn + creationFee_) revert InvalidAmountIn();
        if (creationFee_ > 0) {
            SafeTransferLib.safeTransferETH(feeTo_, creationFee_);
        }

        token = _deployToken(name, symbol, description, extended);
        if (initAmountIn > 0) {
            amountOut = _swapEthForTokens(token, initAmountIn, 0, msg.sender);
        }
    }

    function createTokenAndBurnLiquidity(
        string memory name,
        string memory symbol,
        uint256 initAmountIn,
        string memory description,
        string memory extended
    ) external payable onlyUnpaused returns (EmToken token, uint256 amountOut) {
        if (msg.value != initAmountIn + creationFee_) revert InvalidAmountIn();
        if (creationFee_ > 0) {
            SafeTransferLib.safeTransferETH(feeTo_, creationFee_);
        }

        token = _deployToken(name, symbol, description, extended);
        if (initAmountIn > 0) {
            amountOut = _swapEthForTokens(
                token,
                initAmountIn,
                0,
                0x000000000000000000000000000000000000dEaD
            );
        }
    }

    function _deployToken(
        string memory name,
        string memory symbol,
        string memory description,
        string memory extended
    ) private returns (EmToken) {
        EmToken token = new EmToken(
            name,
            symbol,
            DECIMALS,
            TOTAL_SUPPLY,
            description,
            extended,
            address(this),
            msg.sender
        );

        Pool storage pool = pools_[token];
        pool.token = token;
        pool.tokenReserve = INIT_REAL_TOKEN_RESERVE;
        pool.virtualTokenReserve = INIT_VIRTUAL_TOKEN_RESERVE;
        pool.ethReserve = 0;
        pool.virtualEthReserve = initVirtualEthReserve_;
        pool.lastPrice = initVirtualEthReserve_.divWadDown(
            INIT_VIRTUAL_TOKEN_RESERVE
        );
        pool.lastMcapInEth = TOTAL_SUPPLY.mulWadUp(pool.lastPrice);
        pool.lastTimestamp = block.timestamp;
        pool.lastBlock = block.number;
        pool.creator = msg.sender;
        pool.K = K_;

        emit TokenCreated(token, msg.sender);
        emit PriceUpdate(token, msg.sender, pool.lastPrice, pool.lastMcapInEth);
        emLedger_.addCreation(token, msg.sender);

        return token;
    }

    function _graduate(EmToken token) private {
        pools_[token].lastTimestamp = block.timestamp;
        pools_[token].lastBlock = block.number;

        uint256 fee = (pools_[token].ethReserve * graduationFeeRate_) /
            FEE_DENOMINATOR;
        SafeTransferLib.safeTransferETH(feeTo_, fee);
        uint256 _amountETH = pools_[token].ethReserve - fee;
        uint256 _amountToken = TOTAL_SUPPLY - INIT_REAL_TOKEN_RESERVE;

        EmToken(address(token)).setIsUnrestricted(true);
        token.approve(address(headmaster_), type(uint256).max);
        (uint256 poolId, uint256 amountToken, uint256 amountETH) = headmaster_
            .execute{value: _amountETH}(token, _amountToken, _amountETH);

        pools_[token].headmaster = address(headmaster_);
        pools_[token].poolId = poolId;
        pools_[token].virtualTokenReserve = 0;
        pools_[token].virtualEthReserve = 0;
        pools_[token].tokenReserve = 0;
        pools_[token].ethReserve = 0;

        emit TokenGraduated(token, headmaster_, poolId, amountToken, amountETH);
        emLedger_.addGraduation(token, amountETH);
    }

    /*//////////////////////////////////////////////////
    ////////////////   SWAP FUNCTIONS   ////////////////
    //////////////////////////////////////////////////*/

    /// @notice Swaps ETH for tokens.
    /// @param token The token to swap.
    /// @param amountIn Input amount of ETH.
    /// @param amountOutMin Minimum output amount of token.
    /// @param to Recipient of token.
    /// @param deadline Deadline for the swap.
    /// @return amountOut The actual output amount of token.
    function swapEthForTokens(
        EmToken token,
        uint256 amountIn,
        uint256 amountOutMin,
        address to,
        uint256 deadline
    )
        external
        payable
        nonReentrant
        onlyUnpaused
        onlyUngraduated(token)
        onlyEmToken(token)
        checkDeadline(deadline)
        returns (uint256 amountOut)
    {
        if (msg.value != amountIn) revert InvalidAmountIn();

        amountOut = _swapEthForTokens(token, amountIn, amountOutMin, to);

        if (_isMcapGraduable(token)) {
            _graduate(token);
        }
    }

    function _swapEthForTokens(
        EmToken token,
        uint256 amountIn,
        uint256 amountOutMin,
        address to
    ) private returns (uint256 amountOut) {
        if (amountIn == 0) revert InvalidAmountIn();

        uint256 fee = (amountIn * feeRate_) / FEE_DENOMINATOR;
        SafeTransferLib.safeTransferETH(feeTo_, fee);
        amountIn -= fee;

        uint256 newVirtualEthReserve = pools_[token].virtualEthReserve +
            amountIn;
        uint256 newVirtualTokenReserve = pools_[token].K / newVirtualEthReserve;
        amountOut = pools_[token].virtualTokenReserve - newVirtualTokenReserve;

        if (amountOut > pools_[token].tokenReserve) {
            amountOut = pools_[token].tokenReserve;
        }
        if (amountOut < amountOutMin) revert InsufficientOutput();

        pools_[token].virtualTokenReserve = newVirtualTokenReserve;
        pools_[token].virtualEthReserve = newVirtualEthReserve;

        pools_[token].lastPrice = newVirtualEthReserve.divWadDown(
            newVirtualTokenReserve
        );
        pools_[token].lastMcapInEth = TOTAL_SUPPLY.mulWadUp(
            pools_[token].lastPrice
        );
        pools_[token].lastTimestamp = block.timestamp;
        pools_[token].lastBlock = block.number;

        pools_[token].ethReserve += amountIn;
        pools_[token].tokenReserve -= amountOut;

        SafeTransferLib.safeTransfer(token, to, amountOut);

        emit Buy(token, msg.sender, amountIn + fee, amountOut, to);
        emit PriceUpdate(
            token,
            msg.sender,
            pools_[token].lastPrice,
            pools_[token].lastMcapInEth
        );
        EmLedger.Trade memory trade = EmLedger.Trade(
            token,
            true,
            to,
            amountIn + fee,
            amountOut,
            uint128(block.timestamp),
            uint128(block.number)
        );
        emLedger_.addTrade(trade);
    }

    /// @notice Swaps tokens for ETH.
    /// @param token The token to swap.
    /// @param amountIn Input amount of token.
    /// @param amountOutMin Minimum output amount of ETH.
    /// @param to Recipient of ETH.
    /// @param deadline Deadline for the swap.
    /// @return amountOut The actual output amount of ETH.
    function swapTokensForEth(
        EmToken token,
        uint256 amountIn,
        uint256 amountOutMin,
        address to,
        uint256 deadline
    )
        external
        nonReentrant
        onlyUnpaused
        onlyUngraduated(token)
        onlyEmToken(token)
        checkDeadline(deadline)
        returns (uint256 amountOut)
    {
        if (amountIn == 0) revert InvalidAmountIn();

        SafeTransferLib.safeTransferFrom(
            token,
            msg.sender,
            address(this),
            amountIn
        );

        uint256 newVirtualTokenReserve = pools_[token].virtualTokenReserve +
            amountIn;
        uint256 newVirtualEthReserve = pools_[token].K / newVirtualTokenReserve;
        amountOut = pools_[token].virtualEthReserve - newVirtualEthReserve;

        pools_[token].virtualTokenReserve = newVirtualTokenReserve;
        pools_[token].virtualEthReserve = newVirtualEthReserve;

        pools_[token].lastPrice = newVirtualEthReserve.divWadDown(
            newVirtualTokenReserve
        );
        pools_[token].lastMcapInEth = TOTAL_SUPPLY.mulWadUp(
            pools_[token].lastPrice
        );
        pools_[token].lastTimestamp = block.timestamp;
        pools_[token].lastBlock = block.number;

        pools_[token].tokenReserve += amountIn;
        pools_[token].ethReserve -= amountOut;

        uint256 fee = (amountOut * feeRate_) / FEE_DENOMINATOR;
        amountOut -= fee;

        if (amountOut < amountOutMin) revert InsufficientOutput();
        SafeTransferLib.safeTransferETH(feeTo_, fee);
        SafeTransferLib.safeTransferETH(to, amountOut);

        emit Sell(token, msg.sender, amountIn, amountOut, to);
        emit PriceUpdate(
            token,
            msg.sender,
            pools_[token].lastPrice,
            pools_[token].lastMcapInEth
        );
        EmLedger.Trade memory trade = EmLedger.Trade(
            token,
            false,
            msg.sender,
            amountIn,
            amountOut + fee,
            uint128(block.timestamp),
            uint128(block.number)
        );
        emLedger_.addTrade(trade);
    }

    /*//////////////////////////////////////////////////
    ////////////////   VIEW FUNCTIONS   ////////////////
    //////////////////////////////////////////////////*/

    /// @notice Calculates the expected output amount of ETH given an input amount of token.
    /// @param token The token to swap.
    /// @param amountIn Input amount of token.
    /// @return amountOut The expected output amount of ETH.
    function calcAmountOutFromToken(
        EmToken token,
        uint256 amountIn
    ) external view returns (uint256 amountOut) {
        if (amountIn == 0) revert InvalidAmountIn();

        uint256 newVirtualTokenReserve = pools_[token].virtualTokenReserve +
            amountIn;
        uint256 newVirtualEthReserve = pools_[token].K / newVirtualTokenReserve;
        amountOut = pools_[token].virtualEthReserve - newVirtualEthReserve;

        uint256 fee = (amountOut * feeRate_) / FEE_DENOMINATOR;
        amountOut -= fee;
    }

    /// @notice Calculates the expected output amount of token given an input amount of ETH.
    /// @param token The token to swap.
    /// @param amountIn Input amount of ETH.
    /// @return amountOut The expected output amount of token.
    function calcAmountOutFromEth(
        EmToken token,
        uint256 amountIn
    ) external view returns (uint256 amountOut) {
        if (amountIn == 0) revert InvalidAmountIn();

        uint256 fee = (amountIn * feeRate_) / FEE_DENOMINATOR;
        amountIn -= fee;

        uint256 newVirtualEthReserve = pools_[token].virtualEthReserve +
            amountIn;
        uint256 newVirtualTokenReserve = pools_[token].K / newVirtualEthReserve;
        amountOut = pools_[token].virtualTokenReserve - newVirtualTokenReserve;

        if (amountOut > pools_[token].tokenReserve) {
            amountOut = pools_[token].tokenReserve;
        }
    }

    /*///////////////////////////////////////////
    //             Storage  Getters            //
    ///////////////////////////////////////////*/

    function getPool(EmToken token) external view returns (Pool memory) {
        return pools_[token];
    }

    function getPoolsAll(
        uint256 offset,
        uint256 limit
    ) external view returns (Pool[] memory) {
        EmToken[] memory tokens = emLedger_.getTokens(offset, limit);
        Pool[] memory pools = new Pool[](tokens.length);

        for (uint256 i = 0; i < tokens.length; i++) {
            pools[i] = pools_[tokens[i]];
        }

        return pools;
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";
import {IUniswapV2Router02} from "./interfaces/IUniswapV2Router02.sol";
import {IUniswapV2Factory} from "./interfaces/IUniswapV2Factory.sol";
import {EmToken} from "./EmToken.sol";
import {EmCore} from "./EmCore.sol";

error Forbidden();
error InvalidAmountToken();
error InvalidAmountEth();

/// @title A Em protocol graduation strategy for bootstrapping liquidity on uni-v2 AMMs.
/// @notice This contract may be replaced by other strategies in the future.
contract EmHeadmaster {
    EmCore public immutable emCore;
    IUniswapV2Router02 public immutable uniswapV2Router02;
    IUniswapV2Factory public immutable uniswapV2Factory;

    address public constant liquidityOwner = address(0);

    EmToken[] public alumni;

    constructor(EmCore _emCore, IUniswapV2Router02 _uniswapV2Router02) {
        emCore = _emCore;
        uniswapV2Router02 = IUniswapV2Router02(payable(_uniswapV2Router02));
        uniswapV2Factory = IUniswapV2Factory(uniswapV2Router02.factory());
    }

    modifier onlyEmCore() {
        if (msg.sender != address(emCore)) revert Forbidden();
        _;
    }

    event Executed(
        EmToken token,
        uint256 indexed poolId,
        uint256 amountToken,
        uint256 amountETH,
        address indexed owner
    );

    function execute(
        EmToken token,
        uint256 amountToken,
        uint256 amountEth
    )
        external
        payable
        onlyEmCore
        returns (uint256 poolId, uint256 _amountToken, uint256 _amountETH)
    {
        if (amountToken == 0) revert InvalidAmountToken();
        if (amountEth == 0 || msg.value != amountEth) revert InvalidAmountEth();

        SafeTransferLib.safeTransferFrom(
            token,
            msg.sender,
            address(this),
            amountToken
        );
        SafeTransferLib.safeApprove(
            token,
            address(uniswapV2Router02),
            amountToken
        );

        address pair = uniswapV2Factory.getPair(
            address(token),
            uniswapV2Router02.WETH()
        );
        if (pair == address(0)) {
            pair = uniswapV2Factory.createPair(
                address(token),
                uniswapV2Router02.WETH()
            );
        }
        poolId = uint256(uint160(pair));
        uint256 amountTokenMin = (amountToken * 95) / 100;
        uint256 amountEthMin = (amountEth * 95) / 100;
        (_amountToken, _amountETH, ) = uniswapV2Router02.addLiquidityETH{
            value: amountEth
        }(
            address(token),
            amountToken,
            amountTokenMin,
            amountEthMin,
            liquidityOwner,
            block.timestamp
        );

        alumni.push(token);

        emit Executed(token, poolId, _amountToken, _amountETH, liquidityOwner);
    }

    /*///////////////////////////////////////////
    //             Storage  Getters            //
    ///////////////////////////////////////////*/

    function getAlumni(
        uint256 offset,
        uint256 limit
    ) external view returns (EmToken[] memory) {
        uint256 length = alumni.length;
        if (offset >= length) {
            return new EmToken[](0);
        }

        uint256 end = offset + limit;
        if (end > length) {
            end = length;
        }

        EmToken[] memory result = new EmToken[](end - offset);
        for (uint256 i = offset; i < end; i++) {
            result[i - offset] = alumni[i];
        }
        return result;
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {EmCore} from "./EmCore.sol";
import {EmToken} from "./EmToken.sol";

error NotFoundry();

/// @title The Em protocol user activity bookkeeper.
/// @notice Since this version of the protocol is not deployed on gas-expensive networks, this contract is designed to make data more available from onchain.
contract EmLedger {
    struct Stats {
        uint256 totalVolume;
        uint256 totalLiquidityBootstrapped;
        uint256 totalTokensCreated;
        uint256 totalTokensGraduated;
        uint256 totalTrades;
    }

    struct Trade {
        EmToken token;
        bool isBuy;
        address maker;
        uint256 amountIn;
        uint256 amountOut;
        uint128 timestamp;
        uint128 blockNumber;
    }

    uint256 public totalVolume;
    uint256 public totalLiquidityBootstrapped;

    mapping(address => EmToken[]) public tokensCreatedBy;
    mapping(address => EmToken[]) public tokensTradedBy;
    mapping(EmToken => mapping(address => bool)) public hasTraded;

    EmToken[] public tokensCreated;
    EmToken[] public tokensGraduated;
    mapping(EmToken => bool) public isGraduated;

    Trade[] public trades;
    mapping(EmToken => uint256[]) public tradesByToken;
    mapping(address => uint256[]) public tradesByUser;

    EmCore public immutable emCore;

    constructor() {
        emCore = EmCore(msg.sender);
    }

    modifier onlyFoundry() {
        if (msg.sender != address(emCore)) revert NotFoundry();
        _;
    }

    /// Add a token to the list of tokens created by a user
    /// @param token The token to add
    /// @param user The user to add the token for
    /// @notice This method should only be called once per token creation
    function addCreation(EmToken token, address user) public onlyFoundry {
        tokensCreatedBy[user].push(token);
        tokensCreated.push(token);
    }

    /// Add a trade to the ledger
    /// @param trade The trade to add
    function addTrade(Trade memory trade) public onlyFoundry {
        uint256 tradeId = trades.length;
        trades.push(trade);
        tradesByToken[trade.token].push(tradeId);
        tradesByUser[trade.maker].push(tradeId);
        totalVolume += trade.isBuy ? trade.amountIn : trade.amountOut;

        if (hasTraded[trade.token][trade.maker]) return;

        tokensTradedBy[trade.maker].push(trade.token);
        hasTraded[trade.token][trade.maker] = true;
    }

    /// Add a token to the list of graduated tokens
    /// @param token The token to add
    /// @notice This method should only be called once per token graduation
    function addGraduation(
        EmToken token,
        uint256 amountEth
    ) public onlyFoundry {
        tokensGraduated.push(token);
        isGraduated[token] = true;
        totalLiquidityBootstrapped += amountEth;
    }

    /*///////////////////////////////////////////
    //             Storage  Getters            //
    ///////////////////////////////////////////*/

    function getTokensCreatedBy(
        address user,
        uint256 offset,
        uint256 limit
    ) public view returns (EmToken[] memory) {
        EmToken[] storage allTokens = tokensCreatedBy[user];
        uint256 length = allTokens.length;
        if (offset >= length) {
            return new EmToken[](0);
        }

        uint256 end = offset + limit;
        if (end > length) {
            end = length;
        }

        EmToken[] memory result = new EmToken[](end - offset);
        for (uint256 i = offset; i < end; i++) {
            result[i - offset] = allTokens[i];
        }

        return result;
    }

    function getTokensTradedBy(
        address user,
        uint256 offset,
        uint256 limit
    ) public view returns (EmToken[] memory) {
        EmToken[] storage allTokens = tokensTradedBy[user];
        uint256 length = allTokens.length;
        if (offset >= length) {
            return new EmToken[](0);
        }

        uint256 end = offset + limit;
        if (end > length) {
            end = length;
        }

        EmToken[] memory result = new EmToken[](end - offset);
        for (uint256 i = offset; i < end; i++) {
            result[i - offset] = allTokens[i];
        }

        return result;
    }

    function getTokens(
        uint256 offset,
        uint256 limit
    ) public view returns (EmToken[] memory) {
        uint256 length = tokensCreated.length;
        if (offset >= length) {
            return new EmToken[](0);
        }

        uint256 end = offset + limit;
        if (end > length) {
            end = length;
        }

        EmToken[] memory result = new EmToken[](end - offset);
        for (uint256 i = offset; i < end; i++) {
            result[i - offset] = tokensCreated[i];
        }

        return result;
    }

    function getToken(uint256 tokenId) public view returns (EmToken) {
        return tokensCreated[tokenId];
    }

    function getTokensLength() public view returns (uint256) {
        return tokensCreated.length;
    }

    function getTokensGraduated(
        uint256 offset,
        uint256 limit
    ) public view returns (EmToken[] memory) {
        uint256 length = tokensGraduated.length;
        if (offset >= length) {
            return new EmToken[](0);
        }

        uint256 end = offset + limit;
        if (end > length) {
            end = length;
        }

        EmToken[] memory result = new EmToken[](end - offset);
        for (uint256 i = offset; i < end; i++) {
            result[i - offset] = tokensGraduated[i];
        }

        return result;
    }

    function getTokenGraduated(uint256 tokenId) public view returns (EmToken) {
        return tokensGraduated[tokenId];
    }

    function getTokensGraduatedLength() public view returns (uint256) {
        return tokensGraduated.length;
    }

    function getTradesAll(
        uint256 offset,
        uint256 limit
    ) public view returns (Trade[] memory) {
        uint256 length = trades.length;
        if (offset >= length) {
            return new Trade[](0);
        }

        uint256 end = offset + limit;
        if (end > length) {
            end = length;
        }

        Trade[] memory result = new Trade[](end - offset);
        for (uint256 i = offset; i < end; i++) {
            result[i - offset] = trades[i];
        }

        return result;
    }

    function getTrade(uint256 tradeId) public view returns (Trade memory) {
        return trades[tradeId];
    }

    function getTradesLength() public view returns (uint256) {
        return trades.length;
    }

    function getTradesByTokenLength(
        EmToken token
    ) public view returns (uint256) {
        return tradesByToken[token].length;
    }

    function getTradeIdsByToken(
        EmToken token,
        uint256 offset,
        uint256 limit
    ) public view returns (uint256[] memory) {
        uint256 length = tradesByToken[token].length;
        if (offset >= length) {
            return new uint256[](0);
        }

        uint256 end = offset + limit;
        if (end > length) {
            end = length;
        }

        uint256[] memory result = new uint256[](end - offset);
        for (uint256 i = offset; i < end; i++) {
            result[i - offset] = tradesByToken[token][i];
        }

        return result;
    }

    function getTradesByUserLength(address user) public view returns (uint256) {
        return tradesByUser[user].length;
    }

    function getTradeIdsByUser(
        address user,
        uint256 offset,
        uint256 limit
    ) public view returns (uint256[] memory) {
        uint256 length = tradesByUser[user].length;
        if (offset >= length) {
            return new uint256[](0);
        }

        uint256 end = offset + limit;
        if (end > length) {
            end = length;
        }

        uint256[] memory result = new uint256[](end - offset);
        for (uint256 i = offset; i < end; i++) {
            result[i - offset] = tradesByUser[user][i];
        }

        return result;
    }

    function getStats() public view returns (Stats memory) {
        return
            Stats({
                totalVolume: totalVolume,
                totalLiquidityBootstrapped: totalLiquidityBootstrapped,
                totalTokensCreated: tokensCreated.length,
                totalTokensGraduated: tokensGraduated.length,
                totalTrades: trades.length
            });
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {EmCore} from "./EmCore.sol";

error NotEmCore();
error Forbidden();

/// @title The Em protocol ERC20 token template.
/// @notice Until graduation, the token allowance is restricted to only the EmCore, and transfers to certain external entities are not
///         allowed (eg. Uniswap pairs). This makes sure the token is transferable but not tradable before graduation.
contract EmToken is ERC20 {
    struct Metadata {
        EmToken token;
        string name;
        string symbol;
        string description;
        string extended;
        address creator;
        bool isGraduated;
        uint256 mcap;
    }

    string public description;
    string public extended;
    EmCore public immutable emCore;
    address public immutable creator;

    address[] public holders;
    mapping(address => bool) public isHolder;

    /// @notice Locked before graduation to restrict trading to EmCore
    bool public isUnrestricted = false;

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _supply,
        string memory _description,
        string memory _extended,
        address _emCore,
        address _creator
    ) ERC20(_name, _symbol, _decimals) {
        description = _description;
        extended = _extended;
        emCore = EmCore(_emCore);
        creator = _creator;

        _mint(msg.sender, _supply);
        _addHolder(msg.sender);
    }

    function _addHolder(address holder) private {
        if (!isHolder[holder]) {
            holders.push(holder);
            isHolder[holder] = true;
        }
    }

    function getMetadata() public view returns (Metadata memory) {
        EmCore.Pool memory pool = emCore.getPool(this);
        return
            Metadata(
                EmToken(address(this)),
                this.name(),
                this.symbol(),
                description,
                extended,
                creator,
                isGraduated(),
                pool.lastMcapInEth
            );
    }

    function isGraduated() public view returns (bool) {
        EmCore.Pool memory pool = emCore.getPool(this);
        return pool.headmaster != address(0);
    }

    function setIsUnrestricted(bool _isUnrestricted) public {
        if (msg.sender != address(emCore)) revert NotEmCore();
        isUnrestricted = _isUnrestricted;
    }

    function transfer(
        address to,
        uint256 amount
    ) public override returns (bool) {
        if (!isUnrestricted) {
            bool isPregradRestricted = emCore
                .externalEntities_()
                .isPregradRestricted(address(this), address(to));
            if (isPregradRestricted) revert Forbidden();
        }
        _addHolder(to);
        return super.transfer(to, amount);
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        if (!isUnrestricted) {
            bool isPregradRestricted = emCore
                .externalEntities_()
                .isPregradRestricted(address(this), address(to));
            if (isPregradRestricted) revert Forbidden();
        }
        // Pre-approve EmCore for improved UX
        if (allowance[from][address(emCore)] != type(uint256).max) {
            allowance[from][address(emCore)] = type(uint256).max;
        }
        _addHolder(to);
        return super.transferFrom(from, to, amount);
    }

    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        if (!isUnrestricted) revert Forbidden();

        return super.approve(spender, amount);
    }

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public override {
        if (!isUnrestricted) revert Forbidden();

        super.permit(owner, spender, value, deadline, v, r, s);
    }

    /// Get all addresses who have ever held the token with their balances
    /// @return The holders and their balances
    /// @notice Some holders may have a zero balance
    function getHoldersWithBalance(
        uint256 offset,
        uint256 limit
    ) public view returns (address[] memory, uint256[] memory) {
        uint256 length = holders.length;
        if (offset >= length) {
            return (new address[](0), new uint256[](0));
        }

        uint256 end = offset + limit;
        if (end > length) {
            end = length;
        }

        address[] memory resultAddresses = new address[](end - offset);
        uint256[] memory resultBalances = new uint256[](end - offset);

        for (uint256 i = offset; i < end; i++) {
            address holder = holders[i];
            resultAddresses[i - offset] = holder;
            resultBalances[i - offset] = balanceOf[holder];
        }

        return (resultAddresses, resultBalances);
    }

    /// Get all addresses who have ever held the token
    /// @return The holders
    /// @notice Some holders may have a zero balance
    function getHolders(
        uint256 offset,
        uint256 limit
    ) public view returns (address[] memory) {
        uint256 length = holders.length;
        if (offset >= length) {
            return new address[](0);
        }

        uint256 end = offset + limit;
        if (end > length) {
            end = length;
        }

        address[] memory result = new address[](end - offset);
        for (uint256 i = offset; i < end; i++) {
            result[i - offset] = holders[i];
        }

        return result;
    }

    /// Get the number of all addresses who have ever held the token
    /// @return The number of holders
    /// @notice Some holders may have a zero balance
    function getHoldersLength() public view returns (uint256) {
        return holders.length;
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {EmCore} from "./EmCore.sol";
import {IUniswapV2Factory} from "./interfaces/IUniswapV2Factory.sol";

error Forbidden();

/// @title External entities registry. Primarily used to check and restrict pre-graduation token transfers to specific entities like Uniswap V2 pairs.
/// @notice Refer to the EmToken template contract to verify that the restriction is lifted after graduation.
contract ExternalEntities {
    address public immutable weth;

    IUniswapV2Factory[] public knownFactories;
    mapping(address => bool) public pregradRestricted;
    address public owner;

    constructor(address _weth) {
        owner = msg.sender;
        weth = _weth;
    }

    function setOwner(address _owner) external {
        if (msg.sender != owner) revert Forbidden();
        owner = _owner;
    }

    function addFactory(address factory) external {
        if (msg.sender != owner) revert Forbidden();

        knownFactories.push(IUniswapV2Factory(factory));
    }

    function removeFactory(address factory) external {
        if (msg.sender != owner) revert Forbidden();

        for (uint256 i = 0; i < knownFactories.length; i++) {
            if (address(knownFactories[i]) == factory) {
                knownFactories[i] = knownFactories[knownFactories.length - 1];
                knownFactories.pop();
                break;
            }
        }
    }

    function addPregradRestricted(address to) external {
        if (msg.sender != owner) revert Forbidden();

        pregradRestricted[to] = true;
    }

    function removePregradRestricted(address to) external {
        if (msg.sender != owner) revert Forbidden();

        pregradRestricted[to] = false;
    }

    function computeUniV2Pair(
        IUniswapV2Factory factory,
        address tokenA,
        address tokenB
    ) public view returns (address pair, bool exists) {
        pair = factory.getPair(tokenA, tokenB);
        if (pair != address(0)) {
            return (pair, true);
        }

        (address token0, address token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);

        // both uniswap and quickswap v2 are using the same init code hash
        pair = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            hex"ff",
                            factory,
                            keccak256(abi.encodePacked(token0, token1)),
                            hex"96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f"
                        )
                    )
                )
            )
        );

        return (pair, false);
    }

    function isPregradRestricted(
        address token,
        address to
    ) external view returns (bool) {
        for (uint256 i = 0; i < knownFactories.length; i++) {
            (address pair, ) = computeUniV2Pair(knownFactories[i], token, weth);
            if (pair == to) {
                return true;
            }
        }

        return pregradRestricted[to];
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function allPairs(uint256) external view returns (address);
    function allPairsLength() external view returns (uint256);
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function getPair(address, address) external view returns (address);
    function setFeeTo(address _feeTo) external;
    function setFeeToSetter(address _feeToSetter) external;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

interface IUniswapV2Router02 {
    function WETH() external view returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

    function factory() external view returns (address);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountsIn(
        uint256 amountOut,
        address[] memory path
    ) external view returns (uint256[] memory amounts);

    function getAmountsOut(
        uint256 amountIn,
        address[] memory path
    ) external view returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] memory path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] memory path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] memory path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] memory path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] memory path,
        address to,
        uint256 deadline
    ) external;

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] memory path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] memory path,
        address to,
        uint256 deadline
    ) external;

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] memory path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] memory path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    receive() external payable;
}