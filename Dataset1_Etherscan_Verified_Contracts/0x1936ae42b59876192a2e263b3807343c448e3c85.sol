// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Gas optimized ECDSA wrapper.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/ECDSA.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/ECDSA.sol)
/// @author Modified from OpenZeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/cryptography/ECDSA.sol)
library ECDSA {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                        CUSTOM ERRORS                       */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The signature is invalid.
    error InvalidSignature();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         CONSTANTS                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The number which `s` must be less than in order for
    /// the signature to be non-malleable.
    bytes32 private constant _MALLEABILITY_THRESHOLD_PLUS_ONE =
        0x7fffffffffffffffffffffffffffffff5d576e7357a4501ddfe92f46681b20a1;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                    RECOVERY OPERATIONS                     */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // Note: as of Solady version 0.0.68, these functions will
    // revert upon recovery failure for more safety by default.

    /// @dev Recovers the signer's address from a message digest `hash`,
    /// and the `signature`.
    ///
    /// This function does NOT accept EIP-2098 short form signatures.
    /// Use `recover(bytes32 hash, bytes32 r, bytes32 vs)` for EIP-2098
    /// short form signatures instead.
    function recover(bytes32 hash, bytes memory signature) internal view returns (address result) {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x00, hash)
            mstore(0x20, byte(0, mload(add(signature, 0x60)))) // `v`.
            mstore(0x40, mload(add(signature, 0x20))) // `r`.
            mstore(0x60, mload(add(signature, 0x40))) // `s`.
            pop(
                staticcall(
                    gas(), // Amount of gas left for the transaction.
                    and(
                        // If the signature is exactly 65 bytes in length.
                        eq(mload(signature), 65),
                        // If `s` in lower half order, such that the signature is not malleable.
                        lt(mload(0x60), _MALLEABILITY_THRESHOLD_PLUS_ONE)
                    ), // Address of `ecrecover`.
                    0x00, // Start of input.
                    0x80, // Size of input.
                    0x00, // Start of output.
                    0x20 // Size of output.
                )
            )
            result := mload(0x00)
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
    /// and the `signature`.
    ///
    /// This function does NOT accept EIP-2098 short form signatures.
    /// Use `recover(bytes32 hash, bytes32 r, bytes32 vs)` for EIP-2098
    /// short form signatures instead.
    function recoverCalldata(bytes32 hash, bytes calldata signature)
        internal
        view
        returns (address result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x00, hash)
            mstore(0x20, byte(0, calldataload(add(signature.offset, 0x40)))) // `v`.
            calldatacopy(0x40, signature.offset, 0x40) // Copy `r` and `s`.
            pop(
                staticcall(
                    gas(), // Amount of gas left for the transaction.
                    and(
                        // If the signature is exactly 65 bytes in length.
                        eq(signature.length, 65),
                        // If `s` in lower half order, such that the signature is not malleable.
                        lt(mload(0x60), _MALLEABILITY_THRESHOLD_PLUS_ONE)
                    ), // Address of `ecrecover`.
                    0x00, // Start of input.
                    0x80, // Size of input.
                    0x00, // Start of output.
                    0x20 // Size of output.
                )
            )
            result := mload(0x00)
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
    ///
    /// This function only accepts EIP-2098 short form signatures.
    /// See: https://eips.ethereum.org/EIPS/eip-2098
    function recover(bytes32 hash, bytes32 r, bytes32 vs) internal view returns (address result) {
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
                    // If `s` in lower half order, such that the signature is not malleable.
                    lt(mload(0x60), _MALLEABILITY_THRESHOLD_PLUS_ONE), // Address of `ecrecover`.
                    0x00, // Start of input.
                    0x80, // Size of input.
                    0x00, // Start of output.
                    0x20 // Size of output.
                )
            )
            result := mload(0x00)
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
            pop(
                staticcall(
                    gas(), // Amount of gas left for the transaction.
                    // If `s` in lower half order, such that the signature is not malleable.
                    lt(s, _MALLEABILITY_THRESHOLD_PLUS_ONE), // Address of `ecrecover`.
                    0x00, // Start of input.
                    0x80, // Size of input.
                    0x00, // Start of output.
                    0x20 // Size of output.
                )
            )
            result := mload(0x00)
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

    /// @dev Recovers the signer's address from a message digest `hash`,
    /// and the `signature`.
    ///
    /// This function does NOT accept EIP-2098 short form signatures.
    /// Use `recover(bytes32 hash, bytes32 r, bytes32 vs)` for EIP-2098
    /// short form signatures instead.
    function tryRecover(bytes32 hash, bytes memory signature)
        internal
        view
        returns (address result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x00, hash)
            mstore(0x20, byte(0, mload(add(signature, 0x60)))) // `v`.
            mstore(0x40, mload(add(signature, 0x20))) // `r`.
            mstore(0x60, mload(add(signature, 0x40))) // `s`.
            pop(
                staticcall(
                    gas(), // Amount of gas left for the transaction.
                    and(
                        // If the signature is exactly 65 bytes in length.
                        eq(mload(signature), 65),
                        // If `s` in lower half order, such that the signature is not malleable.
                        lt(mload(0x60), _MALLEABILITY_THRESHOLD_PLUS_ONE)
                    ), // Address of `ecrecover`.
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
    /// and the `signature`.
    ///
    /// This function does NOT accept EIP-2098 short form signatures.
    /// Use `recover(bytes32 hash, bytes32 r, bytes32 vs)` for EIP-2098
    /// short form signatures instead.
    function tryRecoverCalldata(bytes32 hash, bytes calldata signature)
        internal
        view
        returns (address result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x00, hash)
            mstore(0x20, byte(0, calldataload(add(signature.offset, 0x40)))) // `v`.
            calldatacopy(0x40, signature.offset, 0x40) // Copy `r` and `s`.
            pop(
                staticcall(
                    gas(), // Amount of gas left for the transaction.
                    and(
                        // If the signature is exactly 65 bytes in length.
                        eq(signature.length, 65),
                        // If `s` in lower half order, such that the signature is not malleable.
                        lt(mload(0x60), _MALLEABILITY_THRESHOLD_PLUS_ONE)
                    ), // Address of `ecrecover`.
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
    ///
    /// This function only accepts EIP-2098 short form signatures.
    /// See: https://eips.ethereum.org/EIPS/eip-2098
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
                    // If `s` in lower half order, such that the signature is not malleable.
                    lt(mload(0x60), _MALLEABILITY_THRESHOLD_PLUS_ONE), // Address of `ecrecover`.
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
                    // If `s` in lower half order, such that the signature is not malleable.
                    lt(s, _MALLEABILITY_THRESHOLD_PLUS_ONE), // Address of `ecrecover`.
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
    /// [`eth_sign`](https://eth.wiki/json-rpc/API#eth_sign)
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
    /// [`eth_sign`](https://eth.wiki/json-rpc/API#eth_sign)
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
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "solmate/tokens/ERC20.sol";
import "solmate/auth/Owned.sol";
import "./IUniswapV2Router01.sol";
import "./PersonalEmbrVester.sol";
import "./PresaleManager.sol";
import "./SafeMath.sol";

contract EMBRToken is ERC20, Owned {
    using SafeMath for uint256;

    uint public buy_tax = 5;
    uint public sell_tax = 5;
    uint public preventSwapBefore = 10;
    uint public buyCount = 0;
    uint public swapThreshold = 100_000 * 10**18;
    uint public inSwap = 1; // 1 = false, 2 = true. Saves gas cuz changing from non zero to non zero is cheaper than changing zero to non zero.
    mapping(address => bool) public lps;
    mapping(address => bool) public routers;
    mapping(address => bool) public excludedFromFee;
    address public weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public uniRouter = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    uint public maxTx = 1_000_000 * 10**18;
    uint public maxHolding = 1_000_000 * 10**18;

    uint public isTradingEnabled = 1;

    mapping(address => bool) public excludedAntiWhales;

    constructor() ERC20("Ember", "EMBR", 18) Owned(msg.sender) {
        excludedAntiWhales[address(this)] = true;
        excludedAntiWhales[msg.sender] = true;


        // uni router 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        routers[0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D] = true;
        allowance[address(this)][0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D] = type(uint256).max;
        excludedAntiWhales[0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D] = true;

        super._mint(msg.sender, 9_000_000 * 10**18);
    }

    modifier lockTheSwap() {
        inSwap = 2;
        _;
        inSwap = 1;
    }

    function setMaxTx(uint amount) onlyOwner external {
        maxTx = amount;
    }

    function setMaxHolding(uint amount) onlyOwner external {
        maxHolding = amount;
    }

    function excludeWhale(address addy) onlyOwner external {
        excludedAntiWhales[addy] = true;
    }

    function setUniRouter(address newRouter) onlyOwner external {
        uniRouter = newRouter;
    }

    function setAmm(address lp) onlyOwner external {
        lps[lp] = true;
        excludedAntiWhales[lp] = true;
    }

    function setRouter(address router) onlyOwner external {
        routers[router] = true;
        allowance[address(this)][router] = type(uint256).max;
        excludedAntiWhales[router] = true;
    }

    function excludeFromFee(address addy) onlyOwner external {
        excludedFromFee[addy] = true;
    }

    function setPreventSwapBefore(uint counter) onlyOwner external {
        preventSwapBefore = counter;
    }

    function setSwapThreshold(uint newThreshold) onlyOwner external {
        swapThreshold = newThreshold;
    }

    function setSellTax(uint newTax) onlyOwner external {
        sell_tax = newTax;
    }

    function setBuyTax(uint newTax) onlyOwner external {
        buy_tax = newTax;
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.
        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;
        _transfer(from, to, amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(isTradingEnabled == 2 || tx.origin == owner, "trading isnt live");
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(maxTx >= amount || excludedAntiWhales[from], "max tx limit");

        uint256 taxAmount = 0;
        if (from != owner && to != owner && tx.origin != owner) {
            bool isSelling;
            if (lps[from] &&
                !routers[to] &&
                !excludedFromFee[to]) {
                    buyCount++;
                    taxAmount = amount
                    .mul(buy_tax)
                    .div(100);
            }

            if (lps[to] && from != address(this)) {
                isSelling = true;
                taxAmount = amount
                .mul(sell_tax)
                .div(100);
            }

            uint256 contractTokenBalance = balanceOf[address(this)];
            if (
                inSwap == 1 &&
                isSelling &&
                contractTokenBalance > swapThreshold &&
                buyCount > preventSwapBefore
            ) {
                swapTokensForEth(contractTokenBalance);
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0.1 ether) {
                    payable(owner).transfer(contractETHBalance);
                }
            }
        }

        if (taxAmount > 0) {
            balanceOf[address(this)] = balanceOf[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }

        balanceOf[from] = balanceOf[from].sub(amount);
        balanceOf[to] = balanceOf[to].add(amount.sub(taxAmount));

        require(balanceOf[to] <= maxHolding || excludedAntiWhales[to] || tx.origin == owner, "max holding limit");
        emit Transfer(from, to, amount.sub(taxAmount));
    }

    function enableTrading() onlyOwner external {
        isTradingEnabled = 2;
    }

    function claimTaxes() onlyOwner external {
        uint256 contractTokenBalance = balanceOf[address(this)];
        balanceOf[address(this)] -= contractTokenBalance;
        balanceOf[owner] += contractTokenBalance;
        emit Transfer(address(this), owner, contractTokenBalance);
    }

    function swapTokensForEth(uint amount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = weth;
        IUniswapV2Router01(uniRouter).swapExactTokensForETHSupportingFeeOnTransferTokens(amount, 0, path, address(this), 99999999999999999999);
    }

    function mint(uint amount) onlyOwner external {
        super._mint(owner, amount);
    }

    receive() external payable { }

    function withdraw() onlyOwner external {
        (bool sent,) = owner.call{value: address(this).balance}("");
        require(sent, "Failed to send Ether");
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

interface IEMBRToken {
    function mint_allowance(address addy) external returns (uint);
    function mintWithAllowance(uint amount, address receiver) external;
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

// https://uniswap.org/docs/v2/smart-contracts/router01/
// https://github.com/Uniswap/uniswap-v2-periphery/blob/master/contracts/UniswapV2Router01.sol implementation
// UniswapV2Router01 is deployed at 0xf164fC0Ec4E93095b804a4795bBe1e041497b92a on the Ethereum mainnet, and the Ropsten, Rinkeby, Görli, and Kovan testnets

interface IUniswapV2Router01 {
  function factory() external pure returns (address);
  function WETH() external pure returns (address);

  function addLiquidity(
      address tokenA,
      address tokenB,
      uint amountADesired,
      uint amountBDesired,
      uint amountAMin,
      uint amountBMin,
      address to,
      uint deadline
  ) external returns (uint amountA, uint amountB, uint liquidity);
  function addLiquidityETH(
      address token,
      uint amountTokenDesired,
      uint amountTokenMin,
      uint amountETHMin,
      address to,
      uint deadline
  ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
  function removeLiquidity(
      address tokenA,
      address tokenB,
      uint liquidity,
      uint amountAMin,
      uint amountBMin,
      address to,
      uint deadline
  ) external returns (uint amountA, uint amountB);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
  function removeLiquidityETH(
      address token,
      uint liquidity,
      uint amountTokenMin,
      uint amountETHMin,
      address to,
      uint deadline
  ) external returns (uint amountToken, uint amountETH);
  function removeLiquidityWithPermit(
      address tokenA,
      address tokenB,
      uint liquidity,
      uint amountAMin,
      uint amountBMin,
      address to,
      uint deadline,
      bool approveMax, uint8 v, bytes32 r, bytes32 s
  ) external returns (uint amountA, uint amountB);
  function removeLiquidityETHWithPermit(
      address token,
      uint liquidity,
      uint amountTokenMin,
      uint amountETHMin,
      address to,
      uint deadline,
      bool approveMax, uint8 v, bytes32 r, bytes32 s
  ) external returns (uint amountToken, uint amountETH);
  function swapExactTokensForTokens(
      uint amountIn,
      uint amountOutMin,
      address[] calldata path,
      address to,
      uint deadline
  ) external returns (uint[] memory amounts);
  function swapTokensForExactTokens(
      uint amountOut,
      uint amountInMax,
      address[] calldata path,
      address to,
      uint deadline
  ) external returns (uint[] memory amounts);
  function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
      external
      payable
      returns (uint[] memory amounts);
  function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
      external
      returns (uint[] memory amounts);
  function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
      external
      returns (uint[] memory amounts);
  function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
      external
      payable
      returns (uint[] memory amounts);

  function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
  function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
  function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
  function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
  function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./EMBR.sol";

import "solmate/tokens/ERC20.sol";

contract PersonalVester {
    // This is set in constructor
    address public claimer;
    EMBRToken public embr;
    uint public vestingTime;
    uint public cliff;
    uint public totalTokens;

    // This is set in startVest()
    uint public startingTime;

    uint public totalClaimed;

    uint256 public precision = 10e9;

    constructor(uint _totalTokens, uint _vestingTime, uint _cliff, address _claimer){
        totalTokens = _totalTokens;
        vestingTime = _vestingTime;
        cliff = _cliff;
        claimer = _claimer;
        // this contract is only deployed by embr
        // embr = EMBRToken(msg.sender);
    }

    // This function is only called by esEMBR contract. esEMBR also calls claim for this user.
    function startVest() external {
        require(msg.sender == address(embr), "caller must be embr contract");
        startingTime = block.timestamp;
    }

    function claim() public returns (uint256) {
        require(msg.sender == claimer, "invalid caller");
        require(startingTime != 0, "vesting is not started");
        require(block.timestamp > startingTime + cliff, "cliff not reached!");

        uint passedTime = block.timestamp - startingTime;
        if (passedTime > vestingTime) passedTime = vestingTime;

        uint totalClaimableTokens = totalTokens * precision * passedTime / vestingTime / precision;
        uint toClaim = totalClaimableTokens - totalClaimed;

        totalClaimed += toClaim;

        embr.transfer(msg.sender, toClaim);

        return toClaim;
    }

    function claimable() external view returns (uint256) {
        if (startingTime == 0) return 0;
        if (block.timestamp < startingTime + cliff) return 0;
        uint passedTime = block.timestamp - startingTime;
        if (passedTime > vestingTime) passedTime = vestingTime;

        uint totalClaimableTokens = totalTokens * precision * passedTime / vestingTime / precision;
        uint toClaim = totalClaimableTokens - totalClaimed;
        return toClaim;
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "solmate/auth/Owned.sol";
import "./IEMBR.sol";
import "solady/src/utils/ECDSA.sol";

using ECDSA for bytes32;

contract EMBRPresale is Owned {
    IEMBRToken public ember_token;

    uint public total_commited_eth;
    uint public hard_cap = 500.01 ether;

    uint public precision = 10**21;

    uint public commit_start;
    uint public commit_length;

    mapping(address => uint) public commited_amount;
    mapping(address => uint) public claimed;

    uint public vesting_start;
    uint public cliff_period = 14 days;
    uint public vesting_period = 90 days;

    uint public PRICE_PER_TOKEN = 0.00016667 ether;

    address public claimSigner;

    event Commit(address indexed from, uint commit_amount, uint total_commitment);

    constructor(address _claimSigner, uint _commitStart, uint _commitLength) Owned(msg.sender) {
        claimSigner = _claimSigner;

        commit_start = _commitStart;
        commit_length = _commitLength;
    }

    function commit(bytes memory signature, uint min_allocation, uint max_allocation) payable public {
        require(block.timestamp >= commit_start, "Sale is not live yet");
        require(block.timestamp < (commit_start + commit_length), "Sale already ended");

        require(msg.value > 0, "Commitment amount too low");

        // Verify signature & allocation size
        bytes32 hashed = keccak256(abi.encodePacked(msg.sender, min_allocation, max_allocation));
        bytes32 message = ECDSA.toEthSignedMessageHash(hashed);
        address recovered_address = ECDSA.recover(message, signature);
        require(recovered_address == claimSigner, "Invalid signer");

        uint user_commited_amount = commited_amount[msg.sender];
        require(user_commited_amount >= min_allocation || msg.value >= min_allocation, "Minimum presale commitment not met");

        uint allocation_available = max_allocation - user_commited_amount;

        uint leftFromHardCap = hard_cap - total_commited_eth;
        if (leftFromHardCap < allocation_available) allocation_available = leftFromHardCap;

        require(allocation_available > 0, "No more allocation left");

        uint commit_amount = msg.value;

        // If the user is trying to commit more than they have allocated, refund the difference and proceed
        if (msg.value > allocation_available) {
            uint leftover = msg.value - allocation_available;

            (bool sent,) = msg.sender.call{value: leftover}("");
            require(sent, "Failed to send Ether");

            commit_amount -= leftover;
        }

        commited_amount[msg.sender] += commit_amount;
        total_commited_eth += commit_amount;

        emit Commit(msg.sender, commit_amount, commited_amount[msg.sender]);
    }

    function claim() external returns (uint) {
        require(vesting_start != 0, "vesting hasnt started yet bro");
        require(block.timestamp >= vesting_start + cliff_period, "You can only start claiming after cliff period");

        uint passedTime = block.timestamp - vesting_start;
        if (passedTime > vesting_period) passedTime = vesting_period;

        uint totalUserTokens = commited_amount[msg.sender] * 10**18 / PRICE_PER_TOKEN;
        uint totalClaimableTokens = totalUserTokens * precision * passedTime / vesting_period / precision;
        uint toClaim = totalClaimableTokens - claimed[msg.sender];

        claimed[msg.sender] += toClaim;

        ember_token.mintWithAllowance(toClaim, msg.sender);

        return toClaim;
    }

    function claimable() external view returns (uint) {
        if (vesting_start == 0) return 0;
        if (block.timestamp < vesting_start + cliff_period) return 0;

        uint passedTime = block.timestamp - vesting_start;
        if (passedTime > vesting_period) passedTime = vesting_period;

        uint totalUserTokens = commited_amount[msg.sender] * 10**18 / PRICE_PER_TOKEN;
        uint totalClaimableTokens = totalUserTokens * precision * passedTime / vesting_period / precision;
        uint toClaim = totalClaimableTokens - claimed[msg.sender];

        return toClaim;
    }

    function withdraw() onlyOwner external {
        (bool sent,) = owner.call{value: address(this).balance}("");
        require(sent, "Failed to send Ether");
    }

    function startVesting() onlyOwner external {
        vesting_start = block.timestamp;
    }

    function setEmbr(address embr) onlyOwner external {
        ember_token = IEMBRToken(embr);
    }

    function setCommitInfo(uint startTs, uint length) onlyOwner external {
        commit_start = startTs;
        commit_length = length;
    }

    function setHardCap(uint new_hardcap) onlyOwner external {
        hard_cap = new_hardcap;
    }
}
pragma solidity ^0.8.20;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}