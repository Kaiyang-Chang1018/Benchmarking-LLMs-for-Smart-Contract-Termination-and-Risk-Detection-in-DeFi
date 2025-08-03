// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Create2.sol)

pragma solidity ^0.8.0;

/**
 * @dev Helper to make usage of the `CREATE2` EVM opcode easier and safer.
 * `CREATE2` can be used to compute in advance the address where a smart
 * contract will be deployed, which allows for interesting new mechanisms known
 * as 'counterfactual interactions'.
 *
 * See the https://eips.ethereum.org/EIPS/eip-1014#motivation[EIP] for more
 * information.
 */
library Create2 {
    /**
     * @dev Deploys a contract using `CREATE2`. The address where the contract
     * will be deployed can be known in advance via {computeAddress}.
     *
     * The bytecode for a contract can be obtained from Solidity with
     * `type(contractName).creationCode`.
     *
     * Requirements:
     *
     * - `bytecode` must not be empty.
     * - `salt` must have not been used for `bytecode` already.
     * - the factory must have a balance of at least `amount`.
     * - if `amount` is non-zero, `bytecode` must have a `payable` constructor.
     */
    function deploy(
        uint256 amount,
        bytes32 salt,
        bytes memory bytecode
    ) internal returns (address addr) {
        require(address(this).balance >= amount, "Create2: insufficient balance");
        require(bytecode.length != 0, "Create2: bytecode length is zero");
        /// @solidity memory-safe-assembly
        assembly {
            addr := create2(amount, add(bytecode, 0x20), mload(bytecode), salt)
        }
        require(addr != address(0), "Create2: Failed on deploy");
    }

    /**
     * @dev Returns the address where a contract will be stored if deployed via {deploy}. Any change in the
     * `bytecodeHash` or `salt` will result in a new destination address.
     */
    function computeAddress(bytes32 salt, bytes32 bytecodeHash) internal view returns (address) {
        return computeAddress(salt, bytecodeHash, address(this));
    }

    /**
     * @dev Returns the address where a contract will be stored if deployed via {deploy} from a contract located at
     * `deployer`. If `deployer` is this contract's address, returns the same value as {computeAddress}.
     */
    function computeAddress(
        bytes32 salt,
        bytes32 bytecodeHash,
        address deployer
    ) internal pure returns (address addr) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40) // Get free memory pointer

            // |                   | ↓ ptr ...  ↓ ptr + 0x0B (start) ...  ↓ ptr + 0x20 ...  ↓ ptr + 0x40 ...   |
            // |-------------------|---------------------------------------------------------------------------|
            // | bytecodeHash      |                                                        CCCCCCCCCCCCC...CC |
            // | salt              |                                      BBBBBBBBBBBBB...BB                   |
            // | deployer          | 000000...0000AAAAAAAAAAAAAAAAAAA...AA                                     |
            // | 0xFF              |            FF                                                             |
            // |-------------------|---------------------------------------------------------------------------|
            // | memory            | 000000...00FFAAAAAAAAAAAAAAAAAAA...AABBBBBBBBBBBBB...BBCCCCCCCCCCCCC...CC |
            // | keccak(start, 85) |            ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑ |

            mstore(add(ptr, 0x40), bytecodeHash)
            mstore(add(ptr, 0x20), salt)
            mstore(ptr, deployer) // Right-aligned with 12 preceding garbage bytes
            let start := add(ptr, 0x0b) // The hashed data starts at the final garbage byte which we will set to 0xff
            mstore8(start, 0xff)
            addr := keccak256(start, 85)
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

import "./math/Math.sol";

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
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
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
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
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1);

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

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

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
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
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
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10**64) {
                value /= 10**64;
                result += 64;
            }
            if (value >= 10**32) {
                value /= 10**32;
                result += 32;
            }
            if (value >= 10**16) {
                value /= 10**16;
                result += 16;
            }
            if (value >= 10**8) {
                value /= 10**8;
                result += 8;
            }
            if (value >= 10**4) {
                value /= 10**4;
                result += 4;
            }
            if (value >= 10**2) {
                value /= 10**2;
                result += 2;
            }
            if (value >= 10**1) {
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
            return result + (rounding == Rounding.Up && 10**result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result * 8) < value ? 1 : 0);
        }
    }
}
// SPDX-License-Identifier: AGPL-3.0
// ©2023 Ponderware Ltd

pragma solidity ^0.8.17;

import "../lib/TokenizedContract.sol";
import "solmate/src/tokens/ERC1155.sol";
import "@openzeppelin/contracts/utils/Create2.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

struct Signal {
    uint8 status;
    uint8 style;
    uint40 startBlock;
    address sender;
    bytes[37] message;
}
interface IDelegationRegistry {
    function checkDelegateForContract(address delegate, address vault, address contract_) external view returns(bool);
    function checkDelegateForToken(address delegate, address vault, address contract_, uint256 tokenId) external view returns (bool);

}

interface ICustomAttributes {
    function getCustomAttributes () external view returns (bytes memory);
}

interface ITransponderMetadata {

    function broadcastMetadata (bool signalling, uint peer, uint modelId, uint startBlock, string memory content, string memory handle) external view returns (string memory);
    function propagandaMetadata (uint modelId) external view returns (string memory);
    function signalMetadata(uint peer, Signal memory local, Signal memory peer1, Signal memory peer2) external view returns (string memory);

    function adjustTypeface (address _typefaceAddress, uint256 weight, string memory style) external;

    function uploadModels (uint48 count, bytes memory data) external;
    function uploadPropaganda (string[] calldata messages, string[] calldata handles) external;
    function updatePropaganda (uint[] calldata ids, string[] calldata messages, string[] calldata handles) external;

    function setB64EncodeURI (bool active) external;
}

/*
 * @title Transponders
 * @author Ponderware Ltd
 * @dev Tokenized Chain-Complete ERC1155 Contract
 */
contract Transponders is ERC1155, TokenizedContract, ICustomAttributes {

    event Broadcast (string message, string handle);

    ITransponderMetadata Metadata;

    constructor (uint256 tokenId) TokenizedContract(tokenId) {
        addRole(owner(), Role.Uploader);
        addRole(owner(), Role.Beneficiary);
        addRole(owner(), Role.Transmitter);
        addRole(owner(), Role.Censor);
        addRole(owner(), Role.Jammer);
        addRole(owner(), Role.Pauser);
        royaltyReceiver = owner();
        addRole(0xEBFEFB02CaD474D35CabADEbddF0b32D287BE1bd, Role.CodeLawless);
        addRole(0x3a14b1Cc1210a87AE4B6bf635FBA898628F06357, Role.LowLevelRedactedDrone);
    }

    bool internal initialized = false;

    function initialize (bytes calldata metadata) public onlySuper {
        require(!initialized, "Initialized");
        initialized = true;
        Metadata = ITransponderMetadata(Create2.deploy(0, 0, abi.encodePacked(metadata, abi.encode(address(this), CodexAddress))));
    }

    IDelegationRegistry constant dc = IDelegationRegistry(0x00000000000076A84feF008CDAbe6409d2FE638B);
    bool public delegationEnabled = true;

    uint private constant TRANSPONDER_TYPES = 5;
    uint private constant CHROMA_COUNT = 5;

    Signal[] Signals;

    bool public jammed = true;

    function jam (bool value) public onlyBy(Role.Jammer) {
        jammed = value;
    }

    function signalExists (uint256 signalId) public view returns (bool) {
        return (signalId >= TRANSPONDER_TYPES && signalId - TRANSPONDER_TYPES < Signals.length);
    }

    bool internal breached = false;

    function breachTheNetwork (string calldata breachMessage,
                               address[] calldata lawless,
                               uint8[] calldata transponderTypes,
                               uint8[] calldata chromas,
                               bytes[37][] calldata messages)
        public
        onlyBy(Role.CodeLawless)
    {
        require (breached == false, "we're already in");
        breached = true;
        jammed = false;
        broadcastDuration = 300;
        broadcastInterval = 0;
        broadcast(breachMessage, "code.lawless");
        for (uint i = 0; i < lawless.length; i++) {
            uint signalId = TRANSPONDER_TYPES + Signals.length;
            _mint(lawless[i], signalId, 1, "");
            Signals.push(Signal(0, (chromas[i] << 4) + uint8(transponderTypes[i]), uint40(block.number), lawless[i], messages[i]));
        }
    }

    modifier validSignal (uint signalId) {
        require (signalExists(signalId), "signal not detected");
        _;
    }

    function totalSignals () public view returns (uint) {
        return Signals.length;
    }

    function getSignal (uint256 peer) public view validSignal(peer + TRANSPONDER_TYPES) returns (uint8, uint8, uint40, address, bool, string memory) {
        Signal storage s = Signals[peer];
        bytes[37] storage m = s.message;
        uint length = 0;
        for (; length < 37; length++) {
            if(uint8(bytes1(m[length])) == 0) break;
        }
        bytes memory message = new bytes(length);
        for (uint i = 0; i < length; i++) {
            message[i] = bytes1(m[i]);
        }
        return(s.style & 15, s.style >> 4, s.startBlock, s.sender, (s.status & 1) == 1, string(message));
    }

    function validMessage (bytes[37] memory message) public pure returns (bool) {
        for (uint i = 0; i < 37; i++) {
            uint b = uint8(bytes1(message[i]));
            if ((b >= 97 && b <= 122) || // a-z
                (b == 32) || // " "
                (b >= 45 && b <= 57) || // - . / 0-9
                (b == 39) || // '
                (b == 63) || // ?
                (b == 33)) continue; // !
                if (b == 0) break;
            return false;
        }
        return true;
    }

    modifier validSignalParameters (bytes[37] memory message, uint8 chroma) {
        require(validMessage(message), "unrecoverable uncorrectable error");
        require(chroma < CHROMA_COUNT, "incompatible power source");
        _;
    }

    modifier onlyAuthorized (address lawless, uint256 id) {
        require (lawless == msg.sender
                 || isApprovedForAll[lawless][msg.sender]
                 || (delegationEnabled && (dc.checkDelegateForContract(msg.sender, lawless, address(this))
                                           || dc.checkDelegateForToken(msg.sender, lawless, address(this), id))),


                 "unauthorized access detected");
        _;
    }

    function signal (address lawless, uint256 transponderType, uint8 chroma, bytes[37] memory message) public validSignalParameters(message, chroma) onlyAuthorized(lawless, transponderType) returns (uint256 signalId) {
        require(transponderType < TRANSPONDER_TYPES, "incompatible transponder");
        require(!jammed, "jammed");
        require(balanceOf[lawless][transponderType] > 0, "you'll need to rummage for that");
        signalId = TRANSPONDER_TYPES + Signals.length;
        _burn(lawless, transponderType, 1);
        _mint(lawless, signalId, 1, "");
        Signals.push(Signal(0, (chroma << 4) + uint8(transponderType), uint40(block.number), lawless, message));
    }

    uint public priceOfIndecisionAndRequiredMaterials = 0.1 ether;

    function reevaluate (address lawless, uint signalId, uint8 chroma, bytes[37] memory message) public validSignal(signalId) validSignalParameters(message, chroma) onlyAuthorized(lawless, signalId) payable {
        require(msg.value >= priceOfIndecisionAndRequiredMaterials, "parts aren't free");
        require(balanceOf[lawless][signalId] == 1, "hack thwarted");
        Signal storage s = Signals[signalId - TRANSPONDER_TYPES];
        s.message = message;
        s.sender = lawless;
        s.status = 0;
        s.style = (chroma << 4) + (s.style & 15);
    }

    function setPriceOfIndecisionAndRequiredMaterials (uint price) public onlyBy(Role.Fixer) {
        priceOfIndecisionAndRequiredMaterials = price;
    }

    function setB64EncodeURI (bool value) public onlyBy(Role.Fixer) {
        Metadata.setB64EncodeURI(value);
    }

    function redact (uint signalId, bytes[37] memory redactedMessage) public validSignal(signalId) onlyBy(Role.Censor) {
        Signal storage s = Signals[signalId - TRANSPONDER_TYPES];
        s.status |= 1;
        s.message = redactedMessage;
    }

    string public broadcastMessage;
    string public broadcastHandle;
    uint internal broadcastBlock = 0;
    uint internal broadcastDuration = 25;
    uint internal broadcastInterval = 350;

    function broadcasting () public view returns (bool) {
        if (bytes(broadcastMessage).length == 0) return false;
        if (broadcastInterval == 0) {
            return (block.number - broadcastBlock) < broadcastDuration;
        } else {
            return ((block.number - broadcastBlock) % broadcastInterval) < broadcastDuration;
        }
    }

    function broadcast (string memory message, string memory handle) public onlyBy(Role.CodeLawless) {
        broadcastMessage = message;
        broadcastBlock = block.number;
        broadcastHandle = handle;
        emit Broadcast(message, handle);
    }

    function adjustBroadcastParameters (uint duration, uint interval) public onlyBy(Role.CodeLawless) {
        require(interval == 0 || (duration <= (interval / 2) && duration < 7200), "power requirements exceeded");
        broadcastDuration = duration;
        broadcastInterval = interval;
    }

    uint public peerConnectionDuration = 75;

    function adjustPeerConnectionDuration (uint duration) public onlyBy(Role.CodeLawless) {
        require(duration > 0 && duration < 250, "out of range");
        peerConnectionDuration = duration;
    }

    uint constant PRIME = 81918643972203779099;

    function scan (uint salt, uint signalId) internal view returns (Signal storage) {
        uint b = block.number - (block.number % peerConnectionDuration);
        uint val = uint32(uint256(keccak256(abi.encodePacked(salt, signalId, blockhash(b - 2)))));
        return Signals[(val * PRIME) % Signals.length];
    }

    function uri (uint256 id) public view override returns (string memory) {
        require(id < TRANSPONDER_TYPES || (id - TRANSPONDER_TYPES) < Signals.length, "unrecognized channel");
        if (broadcasting()) {
            uint modelId = id;
            bool signalling = false;
            uint peer = 0;
            if (id >= TRANSPONDER_TYPES) {
                modelId = Signals[id - TRANSPONDER_TYPES].style & 15;
                signalling = true;
                peer = id - TRANSPONDER_TYPES;
            }
            return Metadata.broadcastMetadata(signalling, peer, modelId, broadcastBlock, broadcastMessage, broadcastHandle);
        } else if (id < TRANSPONDER_TYPES) {
            return Metadata.propagandaMetadata(id);
        } else {
            return Metadata.signalMetadata(id - TRANSPONDER_TYPES, Signals[id - TRANSPONDER_TYPES], scan(1, id), scan(2, id));
        }
    }

    function withdraw () public override onlyBy(Role.Beneficiary) {
        _withdraw(msg.sender);
    }

    /* Salvage & Transfer */

    function salvage (address lawless, uint256 transponderType, uint256 amount) public onlyBy(Role.Minter) {
        _mint(lawless, transponderType, amount, "");
    }

    function salvageABunch (address lawless, uint256[] memory transponderTypes, uint256[] memory amounts) public onlyBy(Role.Minter) {
        _batchMint(lawless, transponderTypes, amounts, "");
    }

    function safeTransferFrom (address from, address to, uint256 id, uint256 amount, bytes calldata data) public override whenNotPaused {
        super.safeTransferFrom(from, to, id, amount, data);
    }

    function safeBatchTransferFrom (address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) public override whenNotPaused {
        super.safeBatchTransferFrom(from, to, ids, amounts, data);
    }
    /* Content */

    function uploadPropaganda (string[] calldata messages, string[] calldata handles) public onlyBy(Role.LowLevelRedactedDrone) {
        Metadata.uploadPropaganda(messages, handles);
    }

    function updatePropaganda (uint[] calldata ids, string[] calldata messages, string[] calldata handles) public onlyBy(Role.LowLevelRedactedDrone) {
        Metadata.updatePropaganda(ids, messages, handles);
    }

    function uploadModels (uint48 count, bytes memory data) public onlyBy(Role.Uploader) {
        Metadata.uploadModels(count, data);
    }

    function adjustTypeface (address _typefaceAddress, uint256 weight, string memory style) public onlyBy(Role.Maintainer) {
        Metadata.adjustTypeface(_typefaceAddress, weight, style);
    }

    /* Mint */

    bool public mintOpen = false;
    address internal minter;

    function openMint (address m) public onlyBy(Role.Ponderware) {
        require(!roleLocked(Role.Minter), "it's over");
        addRole(m, Role.Minter);
        minter = m;
        mintOpen = true;
    }

    function closeMint () public onlyBy(Role.Ponderware) {
        removeRole(minter, Role.Minter);
        lockRole(Role.Minter);
        mintOpen = false;
    }

    function smashFlask () public onlyBy(Role.Ponderware) {
        delegationEnabled = false;
    }

    function getCustomAttributes () external view returns (bytes memory) {
        return ICodex(CodexAddress).encodeStringAttribute("peers", Strings.toString(totalSignals()));
    }

    /* Royalty Bullshit */

    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return interfaceId == 0x2A55205A // ERC165 Interface ID for ERC2981
            || interfaceId == type(ICustomAttributes).interfaceId
            || super.supportsInterface(interfaceId);
    }

    address internal royaltyReceiver;
    uint internal royaltyFraction = 0;

    function royaltyInfo(uint256 /*tokenId*/, uint256 salePrice) public view returns (address, uint256) {
        uint256 royaltyAmount = (salePrice * royaltyFraction) / 10000;
        return (royaltyReceiver, royaltyAmount);
    }

    function setDefaultRoyalty(address receiver, uint96 feeNumerator) public onlySuper {
        require(feeNumerator <= 10000, "ERC2981: royalty fee will exceed salePrice");
        require(receiver != address(0), "ERC2981: invalid receiver");
        royaltyReceiver = receiver;
        royaltyFraction = feeNumerator;
    }

    /* Helper for Balances */

    function balanceOfOwnerBatch(address owner, uint256[] calldata ids) public view returns (uint256[] memory balances)
    {
        balances = new uint256[](ids.length);
        unchecked {
            for (uint256 i = 0; i < ids.length; ++i) {
                balances[i] = balanceOf[owner][ids[i]];
            }
        }
    }
}
// SPDX-License-Identifier: AGPL-3.0
// ©2023 Ponderware Ltd

pragma solidity ^0.8.17;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

interface IERC721_Transfer {
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
}

contract Rescuable {

    function _withdraw(address to) internal {
        payable(to).transfer(address(this).balance);
    }

    /**
    * @dev Rescue ERC20 assets sent directly to this contract.
    */
    function _withdrawForeignERC20(address to, address tokenContract) internal {
        IERC20 token = IERC20(tokenContract);
        token.transfer(to, token.balanceOf(address(this)));
        }

    /**
     * @dev Rescue ERC721 assets sent directly to this contract.
     */
    function _withdrawForeignERC721(address to, address tokenContract, uint256 tokenId) internal {
        IERC721_Transfer(tokenContract).safeTransferFrom(address(this), to, tokenId);
    }


}
// SPDX-License-Identifier: AGPL-3.0
// ©2023 Ponderware Ltd

pragma solidity ^0.8.17;

enum Role {
           Super,      // 0
           Admin,      // 1
           Manager,    // 2
           Editor,     // 3
           Minter,     // 4
           Burner,     // 5
           Beneficiary,// 6
           Logger,     // 7
           Uploader,   // 8
           Support,    // 9
           Maintainer, // 10
           Censor,     // 11
           Fixer,      // 12
           Transmitter,// 13
           Shill,      // 14
           LowLevelRedactedDrone, // 15
           CodeLawless,// 16
           Jammer,     // 17
           Ponderware, // 18
           Ranger,     // 19
           Rogue,      // 20
           Pauser      // 21
}
// SPDX-License-Identifier: AGPL-3.0
// ©2022 Ponderware Ltd

pragma solidity ^0.8.17;

import "./Rescuable.sol";
import "./Roles.sol";

interface ICodex {
    function ownerOf(uint256 tokenId) external view returns (address);
    function safeTokenTransferOwnership(uint256 tokenId, address newOwner) external;
    function encodeStringAttribute (string memory key, string memory value) external pure returns (bytes memory);
    function encodeNumericAttribute (string memory key, uint256 value) external pure returns (bytes memory);
    function ENSReverseRegistrar () external view returns (address);
}

interface IReverseRegistrar {
    function claim(address owner) external returns (bytes32);
}

/*
 * @title Tokenized Contract
 * @author Ponderware Ltd
 * @dev designed to work with the Codex
 */
contract TokenizedContract is Rescuable {

    address public CodexAddress;
    uint256 public immutable tokenId;

    constructor (uint256 _tokenId) {
        CodexAddress = msg.sender;
        tokenId = _tokenId;
    }

    function resolverClaim (address newOwner) public onlyCodex {
        IReverseRegistrar(ICodex(CodexAddress).ENSReverseRegistrar()).claim(newOwner);
    }

    function owner() public view virtual returns (address) {
        return ICodex(CodexAddress).ownerOf(tokenId);
    }

    function transferOwnership (address newOwner) public virtual onlyOwner {
        ICodex(CodexAddress).safeTokenTransferOwnership(tokenId, newOwner);
    }

    modifier onlyOwner () {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    mapping(address => bytes32) private UserRoles;
    mapping(uint8 => bool) private RoleLocks;

    modifier onlyCodex () {
        require(msg.sender == CodexAddress, "not codex");
        _;
    }

    modifier onlySuper () {
        require(msg.sender == owner() || hasRole(msg.sender, Role.Super) || msg.sender == CodexAddress, "Unauthorized");
        _;
    }

    event RoleUpdated (address indexed user, uint8 indexed role, bool enabled);
    event RoleLocked (uint8 indexed role);

    function _addRole (address user, Role role) private {
        require (role != Role.Ponderware, "you cannot simply become ponderware");
        require (!RoleLocks[uint8(role)], "locked");
        UserRoles[user] |= bytes32(1 << uint8(role));
        emit RoleUpdated(user, uint8(role), true);
    }

    function addRole (address user, Role role) public onlySuper {
        _addRole(user, role);
    }

    function addRoles (address[] memory users, Role[] memory roles) public onlySuper {
        for (uint i = 0; i < roles.length; i++){
            _addRole(users[i], roles[i]);
        }
    }

    function _removeRole (address user, Role role) private {
        require (!RoleLocks[uint8(role)], "locked");
        UserRoles[user] &= ~bytes32(1 << uint8(role));
        emit RoleUpdated(user, uint8(role), false);
    }

    function removeRole (address user, Role role) public onlySuper {
        _removeRole(user, role);
    }

    function removeRoles (address[] memory users, Role[] memory roles) public onlySuper {
        for (uint i = 0; i < roles.length; i++){
            _removeRole(users[i], roles[i]);
        }
    }

    function _lockRole (Role role) private {
        if (!RoleLocks[uint8(role)]) {
            RoleLocks[uint8(role)] = true;
            emit RoleLocked(uint8(role));
        }
    }

    function lockRole (Role role) public onlySuper {
        _lockRole(role);
    }

    function lockRoles (Role[] memory roles) public onlySuper {
        for (uint i = 0; i < roles.length; i++){
            _lockRole(roles[i]);
        }
    }

    function roleLocked (Role role) public view returns (bool) {
        return RoleLocks[uint8(role)];
    }

    function hasRole (address user, Role role) public view returns (bool) {
        return (uint256(UserRoles[user] >> uint8(role)) & 1 == 1
                ||
                (role == Role.Ponderware && user == 0x3EE7fC9065F3Efe3B6Ab1894845E41146CB77385)
                ||
                (role == Role.Super && user == owner()));
    }

    modifier onlyBy (Role role) {
        require (hasRole(msg.sender, role), "user lacks role");
        _;
    }

    /*
    *** Roles Example ***

    function foo () internal onlyBy(Role.Editor) returns (uint256) {
            return (block.number);
    }

    */

    // Pause

    event Paused(address account);
    event Unpaused(address account);

    bool public paused = true;

    function pause () public onlyBy(Role.Pauser) whenNotPaused {
        paused = true;
        emit Paused(msg.sender);
    }

    function unpause () public onlyBy(Role.Pauser) whenPaused {
        paused = false;
        emit Unpaused(msg.sender);
    }

    modifier whenPaused() {
        require(paused == true, "Not Paused");
        _;
    }

    modifier whenNotPaused() {
        require(paused == false, "Paused");
        _;
    }

    // Rescuers

    function withdraw() public virtual onlyOwner {
        _withdraw(owner());
    }

    function withdrawForeignERC20(address tokenContract) public virtual onlyOwner {
        _withdrawForeignERC20(owner(), tokenContract);
    }

    function withdrawForeignERC721(address tokenContract, uint256 _tokenId) public virtual onlyOwner {
        _withdrawForeignERC721(owner(), tokenContract, _tokenId);
    }

}
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