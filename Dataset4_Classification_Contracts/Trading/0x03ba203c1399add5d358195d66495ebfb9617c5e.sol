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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Context.sol)

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
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

interface ITEARSale {
    /// @dev Struct to keep track of each user's information
    struct User {
        address addr; // User's address
        uint256 amount; // Amount of ETH contributed by the user
    }

    /// @dev Sale flags
    enum SaleFlag {
        SALE_CLOSED,
        SALE_PRESALE,
        SALE_PUBLIC
    }

    /// @dev Retrieves user information by their ID
    /// @param idx The ID of the user
    /// @return User memory The user data structure containing the address and amount contributed
    function getUser(uint256 idx) external view returns (User memory);

    /// @dev Retrieves the user ID associated with a given address
    /// @param user The address of the user
    /// @return uint256 The user ID corresponding to the given address
    function getUserIdx(address user) external view returns (uint256);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {Ownable} from "@openzeppelin/access/Ownable.sol";
import {ECDSA} from "@solady/utils/ECDSA.sol";
import {ITEARSale} from "./ITEARSale.sol";

/**
 * @title TEARSale
 * @custom:website www.descend.gg
 * @notice Sale contract for $TEAR
 */
contract TEARSale is ITEARSale, Ownable {
    using ECDSA for bytes32;

    /// @dev Minimum amount of ETH that can be contributed
    uint256 public minAmount = 0.05 ether;

    /// @dev Maximum amount of ETH that can be contributed
    uint256 public maxAmount = 5 ether;

    /// @dev Mapping of user ID to user information
    mapping(uint256 => User) private _user;

    /// @dev Mapping of user addresses to user IDs
    mapping(address => uint256) private _userIdx;

    /// @dev Total amount of ETH contributed
    uint256 public totalEth;

    /// @dev Total number of users who have contributed
    uint256 public totalUsers;

    /// @dev Maximum amount of ETH that the contract can hold
    uint256 public maxCapacity = 500 ether;

    /// @dev Sale flag
    SaleFlag public saleFlag;

    /// @dev Signer address
    address public signerAddress;

    /// @dev Sets the deployer as the initial owner
    constructor(address signerAddress_) Ownable(msg.sender) {
        setSignerAddress(signerAddress_);
    }

    /// @dev Allows the contract to receive ETH directly and triggers the enter process
    receive() external payable {
        require(saleFlag == SaleFlag.SALE_PUBLIC, "!public");
        _contribute();
    }

    /// @notice Contribute ETH to the sale (public)
    function contribute() public payable {
        require(saleFlag == SaleFlag.SALE_PUBLIC, "!public");
        _contribute();
    }

    /// @notice Contribute ETH to the sale (presale only)
    function presale(bytes calldata signature) public payable {
        require(saleFlag != SaleFlag.SALE_CLOSED, "!presale");
        if (saleFlag == SaleFlag.SALE_PRESALE) {
            bytes32 dataHash = keccak256(abi.encodePacked(msg.sender));
            bytes32 message = ECDSA.toEthSignedMessageHash(dataHash);
            address receivedAddress = ECDSA.recover(message, signature);
            require(
                receivedAddress != address(0) &&
                    receivedAddress == signerAddress,
                "!ineligible"
            );
        }
        _contribute();
    }

    /// @dev Private function to manage contributions, including validation and accounting
    function _contribute() private {
        require(msg.value >= minAmount, "!undermin");
        totalEth += msg.value;
        require(totalEth <= maxCapacity, "!overcap");
        uint256 idx = _userIdx[msg.sender];
        if (idx == 0) {
            idx = ++totalUsers;
        }
        uint256 userTotal = _user[idx].amount + msg.value;
        require(userTotal <= maxAmount, "!overmax");
        _userIdx[msg.sender] = idx;
        _user[idx].amount = userTotal;
        _user[idx].addr = msg.sender;
    }

    /// @dev Allows the owner to withdraw the entire balance of the contract
    function withdraw() public onlyOwner {
        (bool success, ) = payable(owner()).call{value: address(this).balance}(
            ""
        );
        require(success, "!failed");
    }

    /// @dev Allows the owner to withdraw the funds to an address
    function withdrawTo(address dest, uint256 amount) public onlyOwner {
        (bool success, ) = payable(dest).call{value: amount}("");
        require(success, "!failed");
    }

    /// @inheritdoc ITEARSale
    function getUser(uint256 idx) public view returns (User memory) {
        return _user[idx];
    }

    /// @inheritdoc ITEARSale
    function getUserIdx(address user) public view returns (uint256) {
        return _userIdx[user];
    }

    /// @dev Allows the owner to set a new capacity for the contract
    /// @param cap The new capacity in wei
    function setMaxCapacity(uint256 cap) public onlyOwner {
        maxCapacity = cap;
    }

    /// @dev Sets the address of the signer
    /// @param signerAddress_ The new signer's address
    function setSignerAddress(address signerAddress_) public onlyOwner {
        signerAddress = signerAddress_;
    }

    /// @dev Sets the minimum and maximum contribution amounts
    /// @param minAmount_ The new minimum amount of contribution
    /// @param maxAmount_ The new maximum amount of contribution
    function setMinMax(
        uint256 minAmount_,
        uint256 maxAmount_
    ) public onlyOwner {
        minAmount = minAmount_;
        maxAmount = maxAmount_;
    }

    /// @dev Sets the sale flag status
    /// @param saleFlag_ The new status of the sale flag
    function setSaleFlag(SaleFlag saleFlag_) public onlyOwner {
        saleFlag = saleFlag_;
    }
}