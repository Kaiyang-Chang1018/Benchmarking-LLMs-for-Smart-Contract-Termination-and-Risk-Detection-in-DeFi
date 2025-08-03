// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

pragma solidity ^0.8.20;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```solidity
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableSet.
 * ====
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position is the index of the value in the `values` array plus 1.
        // Position 0 is used to mean a value is not in the set.
        mapping(bytes32 value => uint256) _positions;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._positions[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We cache the value's position to prevent multiple reads from the same storage slot
        uint256 position = set._positions[value];

        if (position != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 valueIndex = position - 1;
            uint256 lastIndex = set._values.length - 1;

            if (valueIndex != lastIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the lastValue to the index where the value to delete is
                set._values[valueIndex] = lastValue;
                // Update the tracked position of the lastValue (that was just moved)
                set._positions[lastValue] = position;
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the tracked position for the deleted slot
            delete set._positions[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._positions[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}
// SPDX-License-Identifier: BUSL-1.1 AND MIT
// several functions are taken or adapted from https://github.com/HarryR/solcrypto/blob/master/contracts/altbn128.sol (MIT license):
// Copyright 2017 Christian Reitwiessner
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.

// The remainder of the code is written by LayrLabs Inc. and is under the BUSL-1.1 license

pragma solidity ^0.8.12;

/**
 * @title Library for operations on the BN254 elliptic curve.
 * @author Layr Labs, Inc.
 * @notice Terms of Service: https://docs.eigenlayer.xyz/overview/terms-of-service
 * @notice Contains BN254 parameters, common operations (addition, scalar mul, pairing), and BLS signature functionality.
 */
library BN254 {
    // modulus for the underlying field F_p of the elliptic curve
    uint256 internal constant FP_MODULUS = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
    // modulus for the underlying field F_r of the elliptic curve
    uint256 internal constant FR_MODULUS = 21888242871839275222246405745257275088548364400416034343698204186575808495617;

    struct G1Point {
        uint256 X;
        uint256 Y;
    }

    // Encoding of field elements is: X[1] * i + X[0]
    struct G2Point {
        uint256[2] X;
        uint256[2] Y;
    }

    function generatorG1() internal pure returns (G1Point memory) {
        return G1Point(1, 2);
    }

    // generator of group G2
    /// @dev Generator point in F_q2 is of the form: (x0 + ix1, y0 + iy1).
    uint256 internal constant G2x1 = 11559732032986387107991004021392285783925812861821192530917403151452391805634;
    uint256 internal constant G2x0 = 10857046999023057135944570762232829481370756359578518086990519993285655852781;
    uint256 internal constant G2y1 = 4082367875863433681332203403145435568316851327593401208105741076214120093531;
    uint256 internal constant G2y0 = 8495653923123431417604973247489272438418190587263600148770280649306958101930;

    /// @notice returns the G2 generator
    /// @dev mind the ordering of the 1s and 0s!
    ///      this is because of the (unknown to us) convention used in the bn254 pairing precompile contract
    ///      "Elements a * i + b of F_p^2 are encoded as two elements of F_p, (a, b)."
    ///      https://github.com/ethereum/EIPs/blob/master/EIPS/eip-197.md#encoding
    function generatorG2() internal pure returns (G2Point memory) {
        return G2Point([G2x1, G2x0], [G2y1, G2y0]);
    }

    // negation of the generator of group G2
    /// @dev Generator point in F_q2 is of the form: (x0 + ix1, y0 + iy1).
    uint256 internal constant nG2x1 = 11559732032986387107991004021392285783925812861821192530917403151452391805634;
    uint256 internal constant nG2x0 = 10857046999023057135944570762232829481370756359578518086990519993285655852781;
    uint256 internal constant nG2y1 = 17805874995975841540914202342111839520379459829704422454583296818431106115052;
    uint256 internal constant nG2y0 = 13392588948715843804641432497768002650278120570034223513918757245338268106653;

    function negGeneratorG2() internal pure returns (G2Point memory) {
        return G2Point([nG2x1, nG2x0], [nG2y1, nG2y0]);
    }

    bytes32 internal constant powersOfTauMerkleRoot = 0x22c998e49752bbb1918ba87d6d59dd0e83620a311ba91dd4b2cc84990b31b56f;

    /**
     * @param p Some point in G1.
     * @return The negation of `p`, i.e. p.plus(p.negate()) should be zero.
     */
    function negate(G1Point memory p) internal pure returns (G1Point memory) {
        // The prime q in the base field F_q for G1
        if (p.X == 0 && p.Y == 0) {
            return G1Point(0, 0);
        } else {
            return G1Point(p.X, FP_MODULUS - (p.Y % FP_MODULUS));
        }
    }

    /**
     * @return r the sum of two points of G1
     */
    function plus(G1Point memory p1, G1Point memory p2) internal view returns (G1Point memory r) {
        uint256[4] memory input;
        input[0] = p1.X;
        input[1] = p1.Y;
        input[2] = p2.X;
        input[3] = p2.Y;
        bool success;

        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := staticcall(sub(gas(), 2000), 6, input, 0x80, r, 0x40)
            // Use "invalid" to make gas estimation work
            switch success
            case 0 { invalid() }
        }

        require(success, "ec-add-failed");
    }

    /**
     * @notice an optimized ecMul implementation that takes O(log_2(s)) ecAdds
     * @param p the point to multiply
     * @param s the scalar to multiply by
     * @dev this function is only safe to use if the scalar is 9 bits or less
     */
    function scalar_mul_tiny(BN254.G1Point memory p, uint16 s) internal view returns (BN254.G1Point memory) {
        require(s < 2 ** 9, "scalar-too-large");

        // if s is 1 return p
        if (s == 1) {
            return p;
        }

        // the accumulated product to return
        BN254.G1Point memory acc = BN254.G1Point(0, 0);
        // the 2^n*p to add to the accumulated product in each iteration
        BN254.G1Point memory p2n = p;
        // value of most significant bit
        uint16 m = 1;
        // index of most significant bit
        uint8 i = 0;

        //loop until we reach the most significant bit
        while (s >= m) {
            unchecked {
                // if the  current bit is 1, add the 2^n*p to the accumulated product
                if ((s >> i) & 1 == 1) {
                    acc = plus(acc, p2n);
                }
                // double the 2^n*p for the next iteration
                p2n = plus(p2n, p2n);

                // increment the index and double the value of the most significant bit
                m <<= 1;
                ++i;
            }
        }

        // return the accumulated product
        return acc;
    }

    /**
     * @return r the product of a point on G1 and a scalar, i.e.
     *         p == p.scalar_mul(1) and p.plus(p) == p.scalar_mul(2) for all
     *         points p.
     */
    function scalar_mul(G1Point memory p, uint256 s) internal view returns (G1Point memory r) {
        uint256[3] memory input;
        input[0] = p.X;
        input[1] = p.Y;
        input[2] = s;
        bool success;
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := staticcall(sub(gas(), 2000), 7, input, 0x60, r, 0x40)
            // Use "invalid" to make gas estimation work
            switch success
            case 0 { invalid() }
        }
        require(success, "ec-mul-failed");
    }

    /**
     *  @return The result of computing the pairing check
     *         e(p1[0], p2[0]) *  .... * e(p1[n], p2[n]) == 1
     *         For example,
     *         pairing([P1(), P1().negate()], [P2(), P2()]) should return true.
     */
    function pairing(G1Point memory a1, G2Point memory a2, G1Point memory b1, G2Point memory b2)
        internal
        view
        returns (bool)
    {
        G1Point[2] memory p1 = [a1, b1];
        G2Point[2] memory p2 = [a2, b2];

        uint256[12] memory input;

        for (uint256 i = 0; i < 2; i++) {
            uint256 j = i * 6;
            input[j + 0] = p1[i].X;
            input[j + 1] = p1[i].Y;
            input[j + 2] = p2[i].X[0];
            input[j + 3] = p2[i].X[1];
            input[j + 4] = p2[i].Y[0];
            input[j + 5] = p2[i].Y[1];
        }

        uint256[1] memory out;
        bool success;

        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := staticcall(sub(gas(), 2000), 8, input, mul(12, 0x20), out, 0x20)
            // Use "invalid" to make gas estimation work
            switch success
            case 0 { invalid() }
        }

        require(success, "pairing-opcode-failed");

        return out[0] != 0;
    }

    /**
     * @notice This function is functionally the same as pairing(), however it specifies a gas limit
     *         the user can set, as a precompile may use the entire gas budget if it reverts.
     */
    function safePairing(G1Point memory a1, G2Point memory a2, G1Point memory b1, G2Point memory b2, uint256 pairingGas)
        internal
        view
        returns (bool, bool)
    {
        G1Point[2] memory p1 = [a1, b1];
        G2Point[2] memory p2 = [a2, b2];

        uint256[12] memory input;

        for (uint256 i = 0; i < 2; i++) {
            uint256 j = i * 6;
            input[j + 0] = p1[i].X;
            input[j + 1] = p1[i].Y;
            input[j + 2] = p2[i].X[0];
            input[j + 3] = p2[i].X[1];
            input[j + 4] = p2[i].Y[0];
            input[j + 5] = p2[i].Y[1];
        }

        uint256[1] memory out;
        bool success;

        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := staticcall(pairingGas, 8, input, mul(12, 0x20), out, 0x20)
        }

        //Out is the output of the pairing precompile, either 0 or 1 based on whether the two pairings are equal.
        //Success is true if the precompile actually goes through (aka all inputs are valid)

        return (success, out[0] != 0);
    }

    /// @return hashedG1 the keccak256 hash of the G1 Point
    /// @dev used for BLS signatures
    function hashG1Point(BN254.G1Point memory pk) internal pure returns (bytes32 hashedG1) {
        assembly {
            mstore(0, mload(pk))
            mstore(0x20, mload(add(0x20, pk)))
            hashedG1 := keccak256(0, 0x40)
        }
    }

    /// @return the keccak256 hash of the G2 Point
    /// @dev used for BLS signatures
    function hashG2Point(BN254.G2Point memory pk) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(pk.X[0], pk.X[1], pk.Y[0], pk.Y[1]));
    }

    /**
     * @notice adapted from https://github.com/HarryR/solcrypto/blob/master/contracts/altbn128.sol
     */
    function hashToG1(bytes32 _x) internal view returns (G1Point memory) {
        uint256 beta = 0;
        uint256 y = 0;

        uint256 x = uint256(_x) % FP_MODULUS;

        while (true) {
            (beta, y) = findYFromX(x);

            // y^2 == beta
            if (beta == mulmod(y, y, FP_MODULUS)) {
                return G1Point(x, y);
            }

            x = addmod(x, 1, FP_MODULUS);
        }
        return G1Point(0, 0);
    }

    /**
     * Given X, find Y
     *
     *   where y = sqrt(x^3 + b)
     *
     * Returns: (x^3 + b), y
     */
    function findYFromX(uint256 x) internal view returns (uint256, uint256) {
        // beta = (x^3 + b) % p
        uint256 beta = addmod(mulmod(mulmod(x, x, FP_MODULUS), x, FP_MODULUS), 3, FP_MODULUS);

        // y^2 = x^3 + b
        // this acts like: y = sqrt(beta) = beta^((p+1) / 4)
        uint256 y = expMod(beta, 0xc19139cb84c680a6e14116da060561765e05aa45a1c72a34f082305b61f3f52, FP_MODULUS);

        return (beta, y);
    }

    function expMod(uint256 _base, uint256 _exponent, uint256 _modulus) internal view returns (uint256 retval) {
        bool success;
        uint256[1] memory output;
        uint256[6] memory input;
        input[0] = 0x20; // baseLen = new(big.Int).SetBytes(getData(input, 0, 32))
        input[1] = 0x20; // expLen  = new(big.Int).SetBytes(getData(input, 32, 32))
        input[2] = 0x20; // modLen  = new(big.Int).SetBytes(getData(input, 64, 32))
        input[3] = _base;
        input[4] = _exponent;
        input[5] = _modulus;
        assembly {
            success := staticcall(sub(gas(), 2000), 5, input, 0xc0, output, 0x20)
            // Use "invalid" to make gas estimation work
            switch success
            case 0 { invalid() }
        }
        require(success, "BN254.expMod: call failure");
        return output[0];
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

/**
 * @title Library for Bitmap utilities such as converting between an array of bytes and a bitmap and finding the number of 1s in a bitmap.
 * @author Layr Labs, Inc.
 */
library BitmapUtils {
    /**
     * @notice Byte arrays are meant to contain unique bytes.
     * If the array length exceeds 256, then it's impossible for all entries to be unique.
     * This constant captures the max allowed array length (inclusive, i.e. 256 is allowed).
     */
    uint256 internal constant MAX_BYTE_ARRAY_LENGTH = 256;

    /**
     * @notice Converts an ordered array of bytes into a bitmap.
     * @param orderedBytesArray The array of bytes to convert/compress into a bitmap. Must be in strictly ascending order.
     * @return The resulting bitmap.
     * @dev Each byte in the input is processed as indicating a single bit to flip in the bitmap.
     * @dev This function will eventually revert in the event that the `orderedBytesArray` is not properly ordered (in ascending order).
     * @dev This function will also revert if the `orderedBytesArray` input contains any duplicate entries (i.e. duplicate bytes).
     */
    function orderedBytesArrayToBitmap(bytes memory orderedBytesArray) internal pure returns (uint256) {
        // sanity-check on input. a too-long input would fail later on due to having duplicate entry(s)
        require(
            orderedBytesArray.length <= MAX_BYTE_ARRAY_LENGTH,
            "BitmapUtils.orderedBytesArrayToBitmap: orderedBytesArray is too long"
        );

        // return empty bitmap early if length of array is 0
        if (orderedBytesArray.length == 0) {
            return uint256(0);
        }

        // initialize the empty bitmap, to be built inside the loop
        uint256 bitmap;
        // initialize an empty uint256 to be used as a bitmask inside the loop
        uint256 bitMask;

        // perform the 0-th loop iteration with the ordering check *omitted* (since it is unnecessary / will always pass)
        // construct a single-bit mask from the numerical value of the 0th byte of the array, and immediately add it to the bitmap
        bitmap = uint256(1 << uint8(orderedBytesArray[0]));

        // loop through each byte in the array to construct the bitmap
        for (uint256 i = 1; i < orderedBytesArray.length; ++i) {
            // construct a single-bit mask from the numerical value of the next byte of the array
            bitMask = uint256(1 << uint8(orderedBytesArray[i]));
            // check strictly ascending array ordering by comparing the mask to the bitmap so far (revert if mask isn't greater than bitmap)
            require(bitMask > bitmap, "BitmapUtils.orderedBytesArrayToBitmap: orderedBytesArray is not ordered");
            // add the entry to the bitmap
            bitmap = (bitmap | bitMask);
        }
        return bitmap;
    }

    /**
     * @notice Converts an ordered byte array to a bitmap, validating that all bits are less than `bitUpperBound`
     * @param orderedBytesArray The array to convert to a bitmap; must be in strictly ascending order
     * @param bitUpperBound The exclusive largest bit. Each bit must be strictly less than this value.
     * @dev Reverts if bitmap contains a bit greater than or equal to `bitUpperBound`
     */
    function orderedBytesArrayToBitmap(bytes memory orderedBytesArray, uint8 bitUpperBound)
        internal
        pure
        returns (uint256)
    {
        uint256 bitmap = orderedBytesArrayToBitmap(orderedBytesArray);

        require((1 << bitUpperBound) > bitmap, "BitmapUtils.orderedBytesArrayToBitmap: bitmap exceeds max value");

        return bitmap;
    }

    /**
     * @notice Utility function for checking if a bytes array is strictly ordered, in ascending order.
     * @param bytesArray the bytes array of interest
     * @return Returns 'true' if the array is ordered in strictly ascending order, and 'false' otherwise.
     * @dev This function returns 'true' for the edge case of the `bytesArray` having zero length.
     * It also returns 'false' early for arrays with length in excess of MAX_BYTE_ARRAY_LENGTH (i.e. so long that they cannot be strictly ordered)
     */
    function isArrayStrictlyAscendingOrdered(bytes calldata bytesArray) internal pure returns (bool) {
        // Return early if the array is too long, or has a length of 0
        if (bytesArray.length > MAX_BYTE_ARRAY_LENGTH) {
            return false;
        }

        if (bytesArray.length == 0) {
            return true;
        }

        // Perform the 0-th loop iteration by pulling the 0th byte out of the array
        bytes1 singleByte = bytesArray[0];

        // For each byte, validate that each entry is *strictly greater than* the previous
        // If it isn't, return false as the array is not ordered
        for (uint256 i = 1; i < bytesArray.length; ++i) {
            if (uint256(uint8(bytesArray[i])) <= uint256(uint8(singleByte))) {
                return false;
            }

            // Pull the next byte out of the array
            singleByte = bytesArray[i];
        }

        return true;
    }

    /**
     * @notice Converts a bitmap into an array of bytes.
     * @param bitmap The bitmap to decompress/convert to an array of bytes.
     * @return bytesArray The resulting bitmap array of bytes.
     * @dev Each byte in the input is processed as indicating a single bit to flip in the bitmap
     */
    function bitmapToBytesArray(uint256 bitmap) internal pure returns (bytes memory /*bytesArray*/ ) {
        // initialize an empty uint256 to be used as a bitmask inside the loop
        uint256 bitMask;
        // allocate only the needed amount of memory
        bytes memory bytesArray = new bytes(countNumOnes(bitmap));
        // track the array index to assign to
        uint256 arrayIndex = 0;
        /**
         * loop through each index in the bitmap to construct the array,
         * but short-circuit the loop if we reach the number of ones and thus are done
         * assigning to memory
         */
        for (uint256 i = 0; (arrayIndex < bytesArray.length) && (i < 256); ++i) {
            // construct a single-bit mask for the i-th bit
            bitMask = uint256(1 << i);
            // check if the i-th bit is flipped in the bitmap
            if (bitmap & bitMask != 0) {
                // if the i-th bit is flipped, then add a byte encoding the value 'i' to the `bytesArray`
                bytesArray[arrayIndex] = bytes1(uint8(i));
                // increment the bytesArray slot since we've assigned one more byte of memory
                unchecked {
                    ++arrayIndex;
                }
            }
        }
        return bytesArray;
    }

    /// @return count number of ones in binary representation of `n`
    function countNumOnes(uint256 n) internal pure returns (uint16) {
        uint16 count = 0;
        while (n > 0) {
            n &= (n - 1); // Clear the least significant bit (turn off the rightmost set bit).
            count++; // Increment the count for each cleared bit (each one encountered).
        }
        return count; // Return the total count of ones in the binary representation of n.
    }

    /// @notice Returns `true` if `bit` is in `bitmap`. Returns `false` otherwise.
    function isSet(uint256 bitmap, uint8 bit) internal pure returns (bool) {
        return 1 == ((bitmap >> bit) & 1);
    }

    /**
     * @notice Returns a copy of `bitmap` with `bit` set.
     * @dev IMPORTANT: we're dealing with stack values here, so this doesn't modify
     * the original bitmap. Using this correctly requires an assignment statement:
     * `bitmap = bitmap.setBit(bit);`
     */
    function setBit(uint256 bitmap, uint8 bit) internal pure returns (uint256) {
        return bitmap | (1 << bit);
    }

    /**
     * @notice Returns true if `bitmap` has no set bits
     */
    function isEmpty(uint256 bitmap) internal pure returns (bool) {
        return bitmap == 0;
    }

    /**
     * @notice Returns true if `a` and `b` have no common set bits
     */
    function noBitsInCommon(uint256 a, uint256 b) internal pure returns (bool) {
        return a & b == 0;
    }

    /**
     * @notice Returns true if `a` is a subset of `b`: ALL of the bits in `a` are also in `b`
     */
    function isSubsetOf(uint256 a, uint256 b) internal pure returns (bool) {
        return a & b == a;
    }

    /**
     * @notice Returns a new bitmap that contains all bits set in either `a` or `b`
     * @dev Result is the union of `a` and `b`
     */
    function plus(uint256 a, uint256 b) internal pure returns (uint256) {
        return a | b;
    }

    /**
     * @notice Returns a new bitmap that clears all set bits of `b` from `a`
     * @dev Negates `b` and returns the intersection of the result with `a`
     */
    function minus(uint256 a, uint256 b) internal pure returns (uint256) {
        return a & ~b;
    }
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

import {EigenDARollupUtils} from "./EigenDARollupUtils.sol";

/**
 * @title Library of functions for hashing various EigenDA structs.
 * @author Layr Labs, Inc.
 */
library EigenDAHasher {
    /**
     * @notice hashes the given metdata into the commitment that will be stored in the contract
     * @param batchHeaderHash the hash of the batchHeader
     * @param signatoryRecordHash the hash of the signatory record
     * @param blockNumber the block number at which the batch was confirmed
     */
    function hashBatchHashedMetadata(bytes32 batchHeaderHash, bytes32 signatoryRecordHash, uint32 blockNumber)
        internal
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(batchHeaderHash, signatoryRecordHash, blockNumber));
    }

    /**
     * @notice given the a batchHeader in the provided metdata, calculates the hash of the batchMetadata
     * @param batchMetadata the metadata of the batch
     * @return the hash of the batchMetadata
     */
    function hashBatchMetadata(EigenDARollupUtils.BatchMetadata memory batchMetadata) internal pure returns (bytes32) {
        return hashBatchHashedMetadata(
            keccak256(abi.encode(batchMetadata.batchHeader)),
            batchMetadata.signatoryRecordHash,
            batchMetadata.confirmationBlockNumber
        );
    }

    /**
     * @notice hashes the given batch header
     * @param batchHeader the batch header to hash
     */
    function hashBatchHeader(EigenDARollupUtils.BatchHeader calldata batchHeader) internal pure returns (bytes32) {
        return keccak256(abi.encode(batchHeader));
    }

    /**
     * @notice hashes the given blob header
     * @param blobHeader the blob header to hash
     */
    function hashBlobHeader(EigenDARollupUtils.BlobHeader memory blobHeader) internal pure returns (bytes32) {
        return keccak256(abi.encode(blobHeader));
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import {Merkle} from "src/dep/eigenda/Merkle.sol";
import {BN254} from "src/dep/eigenda/BN254.sol";
import {EigenDAHasher} from "src/dep/eigenda/EigenDAHasher.sol";
import {IEigenDAServiceManager} from "src/dep/eigenda/IEigenDAServiceManager.sol";
import {BitmapUtils} from "src/dep/eigenda/BitmapUtils.sol";

/**
 * @title Library of functions to be used by smart contracts wanting to prove blobs on EigenDA and open KZG commitments.
 * @author Layr Labs, Inc.
 */
library EigenDARollupUtils {
    using BN254 for BN254.G1Point;

    // STRUCTS

    struct QuorumBlobParam {
        uint8 quorumNumber;
        uint8 adversaryThresholdPercentage;
        uint8 confirmationThresholdPercentage;
        uint32 chunkLength; // the length of the chunks in the quorum
    }

    struct BlobHeader {
        BN254.G1Point commitment; // the kzg commitment to the blob
        uint32 dataLength; // the length of the blob in coefficients of the polynomial
        QuorumBlobParam[] quorumBlobParams; // the quorumBlobParams for each quorum
    }

    struct BatchHeader {
        bytes32 blobHeadersRoot;
        bytes quorumNumbers; // each byte is a different quorum number
        bytes signedStakeForQuorums; // every bytes is an amount less than 100 specifying the percentage of stake
            // that must have signed in the corresponding quorum in `quorumNumbers`
        uint32 referenceBlockNumber;
    }

    // Relevant metadata for a given datastore
    struct BatchMetadata {
        BatchHeader batchHeader; // the header of the data store
        bytes32 signatoryRecordHash; // the hash of the signatory record
        uint32 confirmationBlockNumber; // the block number at which the batch was confirmed
    }

    struct BlobVerificationProof {
        uint32 batchId;
        uint32 blobIndex;
        BatchMetadata batchMetadata;
        bytes inclusionProof;
        bytes quorumIndices;
    }

    /**
     * @notice Verifies the inclusion of a blob within a batch confirmed in `eigenDAServiceManager` and its trust assumptions
     * @param blobHeader the header of the blob containing relevant attributes of the blob
     * @param eigenDAServiceManager the contract in which the batch was confirmed
     * @param blobVerificationProof the relevant data needed to prove inclusion of the blob and that the trust assumptions were as expected
     */
    function verifyBlob(
        BlobHeader memory blobHeader,
        IEigenDAServiceManager eigenDAServiceManager,
        BlobVerificationProof memory blobVerificationProof
    ) internal view {
        require(
            EigenDAHasher.hashBatchMetadata(blobVerificationProof.batchMetadata)
                == eigenDAServiceManager.batchIdToBatchMetadataHash(blobVerificationProof.batchId),
            "EigenDARollupUtils.verifyBlob: batchMetadata does not match stored metadata"
        );

        require(
            Merkle.verifyInclusionKeccak(
                blobVerificationProof.inclusionProof,
                blobVerificationProof.batchMetadata.batchHeader.blobHeadersRoot,
                keccak256(abi.encodePacked(EigenDAHasher.hashBlobHeader(blobHeader))),
                blobVerificationProof.blobIndex
            ),
            "EigenDARollupUtils.verifyBlob: inclusion proof is invalid"
        );

        // bitmap of quorum numbers in all quorumBlobParams
        uint256 confirmedQuorumsBitmap;

        // require that the security param in each blob is met
        for (uint256 i = 0; i < blobHeader.quorumBlobParams.length; i++) {
            // make sure that the quorumIndex matches the given quorumNumber
            require(
                uint8(
                    blobVerificationProof.batchMetadata.batchHeader.quorumNumbers[uint8(
                        blobVerificationProof.quorumIndices[i]
                    )]
                ) == blobHeader.quorumBlobParams[i].quorumNumber,
                "EigenDARollupUtils.verifyBlob: quorumNumber does not match"
            );

            // make sure that the adversaryThresholdPercentage is less than the given confirmationThresholdPercentage
            require(
                blobHeader.quorumBlobParams[i].adversaryThresholdPercentage
                    < blobHeader.quorumBlobParams[i].confirmationThresholdPercentage,
                "EigenDARollupUtils.verifyBlob: adversaryThresholdPercentage is not valid"
            );

            // make sure that the adversaryThresholdPercentage is at least the given quorumAdversaryThresholdPercentage
            uint8 _adversaryThresholdPercentage =
                getQuorumAdversaryThreshold(eigenDAServiceManager, blobHeader.quorumBlobParams[i].quorumNumber);
            if (_adversaryThresholdPercentage > 0) {
                require(
                    blobHeader.quorumBlobParams[i].adversaryThresholdPercentage >= _adversaryThresholdPercentage,
                    "EigenDARollupUtils.verifyBlob: adversaryThresholdPercentage is not met"
                );
            }

            // make sure that the stake signed for is greater than the given confirmationThresholdPercentage
            require(
                uint8(
                    blobVerificationProof.batchMetadata.batchHeader.signedStakeForQuorums[uint8(
                        blobVerificationProof.quorumIndices[i]
                    )]
                ) >= blobHeader.quorumBlobParams[i].confirmationThresholdPercentage,
                "EigenDARollupUtils.verifyBlob: confirmationThresholdPercentage is not met"
            );

            // mark confirmed quorum in the bitmap
            confirmedQuorumsBitmap =
                BitmapUtils.setBit(confirmedQuorumsBitmap, blobHeader.quorumBlobParams[i].quorumNumber);
        }

        // check that required quorums are a subset of the confirmed quorums
        require(
            BitmapUtils.isSubsetOf(
                BitmapUtils.orderedBytesArrayToBitmap(eigenDAServiceManager.quorumNumbersRequired()),
                confirmedQuorumsBitmap
            ),
            "EigenDARollupUtils.verifyBlob: required quorums are not a subset of the confirmed quorums"
        );
    }

    /**
     * @notice gets the adversary threshold percentage for a given quorum
     * @param eigenDAServiceManager the contract in which the batch was confirmed
     * @param quorumNumber the quorum number to get the adversary threshold percentage for
     * @dev returns 0 if the quorumNumber is not found
     */
    function getQuorumAdversaryThreshold(IEigenDAServiceManager eigenDAServiceManager, uint256 quorumNumber)
        internal
        view
        returns (uint8 adversaryThresholdPercentage)
    {
        if (eigenDAServiceManager.quorumAdversaryThresholdPercentages().length > quorumNumber) {
            adversaryThresholdPercentage =
                uint8(eigenDAServiceManager.quorumAdversaryThresholdPercentages()[quorumNumber]);
        }
    }

    /**
     * @notice opens the KZG commitment at a point
     * @param point the point to evaluate the polynomial at
     * @param evaluation the evaluation of the polynomial at the point
     * @param tau the power of tau
     * @param commitment the commitment to the polynomial
     * @param proof the proof of the commitment
     */
    function openCommitment(
        uint256 point,
        uint256 evaluation,
        BN254.G1Point memory tau,
        BN254.G1Point memory commitment,
        BN254.G2Point memory proof
    ) internal view returns (bool) {
        BN254.G1Point memory negGeneratorG1 = BN254.generatorG1().negate();

        //e([s]_1 - w[1]_1, [pi(x)]_2) = e([p(x)]_1 - p(w)[1]_1, [1]_2)
        return BN254.pairing(
            tau.plus(negGeneratorG1.scalar_mul(point)),
            proof,
            commitment.plus(negGeneratorG1.scalar_mul(evaluation)),
            BN254.negGeneratorG2()
        );
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {BN254} from "./BN254.sol";

interface IEigenDAServiceManager {
    /// @notice mapping between the batchId to the hash of the metadata of the corresponding Batch
    function batchIdToBatchMetadataHash(uint32 batchId) external view returns (bytes32);

    /// @notice Returns the bytes array of quorumAdversaryThresholdPercentages
    function quorumAdversaryThresholdPercentages() external view returns (bytes memory);

    /// @notice Returns the bytes array of quorumsNumbersRequired
    function quorumNumbersRequired() external view returns (bytes memory);
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Adapted from OpenZeppelin Contracts (last updated v4.8.0) (utils/cryptography/MerkleProof.sol)

/**
 * @dev These functions deal with verification of Merkle Tree proofs.
 *
 * The tree and the proofs can be generated using our
 * https://github.com/OpenZeppelin/merkle-tree[JavaScript library].
 * You will find a quickstart guide in the readme.
 *
 * WARNING: You should avoid using leaf values that are 64 bytes long prior to
 * hashing, or use a hash function other than keccak256 for hashing leaves.
 * This is because the concatenation of a sorted pair of internal nodes in
 * the merkle tree could be reinterpreted as a leaf value.
 * OpenZeppelin's JavaScript library generates merkle trees that are safe
 * against this attack out of the box.
 */
library Merkle {
    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merkle tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. The tree is built assuming `leaf` is
     * the 0 indexed `index`'th leaf from the bottom left of the tree.
     *
     * Note this is for a Merkle tree using the keccak/sha3 hash function
     */
    function verifyInclusionKeccak(bytes memory proof, bytes32 root, bytes32 leaf, uint256 index)
        internal
        pure
        returns (bool)
    {
        return processInclusionProofKeccak(proof, leaf, index) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merkle tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. The tree is built assuming `leaf` is
     * the 0 indexed `index`'th leaf from the bottom left of the tree.
     *
     * _Available since v4.4._
     *
     * Note this is for a Merkle tree using the keccak/sha3 hash function
     */
    function processInclusionProofKeccak(bytes memory proof, bytes32 leaf, uint256 index)
        internal
        pure
        returns (bytes32)
    {
        require(
            proof.length != 0 && proof.length % 32 == 0,
            "Merkle.processInclusionProofKeccak: proof length should be a non-zero multiple of 32"
        );
        bytes32 computedHash = leaf;
        for (uint256 i = 32; i <= proof.length; i += 32) {
            if (index % 2 == 0) {
                // if ith bit of index is 0, then computedHash is a left sibling
                assembly {
                    mstore(0x00, computedHash)
                    mstore(0x20, mload(add(proof, i)))
                    computedHash := keccak256(0x00, 0x40)
                    index := div(index, 2)
                }
            } else {
                // if ith bit of index is 1, then computedHash is a right sibling
                assembly {
                    mstore(0x00, mload(add(proof, i)))
                    mstore(0x20, computedHash)
                    computedHash := keccak256(0x00, 0x40)
                    index := div(index, 2)
                }
            }
        }
        return computedHash;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merkle tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. The tree is built assuming `leaf` is
     * the 0 indexed `index`'th leaf from the bottom left of the tree.
     *
     * Note this is for a Merkle tree using the sha256 hash function
     */
    function verifyInclusionSha256(bytes memory proof, bytes32 root, bytes32 leaf, uint256 index)
        internal
        view
        returns (bool)
    {
        return processInclusionProofSha256(proof, leaf, index) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merkle tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. The tree is built assuming `leaf` is
     * the 0 indexed `index`'th leaf from the bottom left of the tree.
     *
     * _Available since v4.4._
     *
     * Note this is for a Merkle tree using the sha256 hash function
     */
    function processInclusionProofSha256(bytes memory proof, bytes32 leaf, uint256 index)
        internal
        view
        returns (bytes32)
    {
        require(
            proof.length != 0 && proof.length % 32 == 0,
            "Merkle.processInclusionProofSha256: proof length should be a non-zero multiple of 32"
        );
        bytes32[1] memory computedHash = [leaf];
        for (uint256 i = 32; i <= proof.length; i += 32) {
            if (index % 2 == 0) {
                // if ith bit of index is 0, then computedHash is a left sibling
                assembly {
                    mstore(0x00, mload(computedHash))
                    mstore(0x20, mload(add(proof, i)))
                    if iszero(staticcall(sub(gas(), 2000), 2, 0x00, 0x40, computedHash, 0x20)) { revert(0, 0) }
                    index := div(index, 2)
                }
            } else {
                // if ith bit of index is 1, then computedHash is a right sibling
                assembly {
                    mstore(0x00, mload(add(proof, i)))
                    mstore(0x20, mload(computedHash))
                    if iszero(staticcall(sub(gas(), 2000), 2, 0x00, 0x40, computedHash, 0x20)) { revert(0, 0) }
                    index := div(index, 2)
                }
            }
        }
        return computedHash[0];
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {EnumerableSet} from "@openzeppelin-contracts/contracts/utils/structs/EnumerableSet.sol";

library FactTypes {
    /// @notice Denotes the state of a fact in a fact registry.
    enum FactState {
        NOT_INITIATED,
        OPTIMISTIC,
        CHALLENGED,
        REVERTED,
        FINALIZED_TIMEOUT,
        FINALIZED_PROVED
    }

    /// @param prevStateHash The summary of the previous state to update from.
    /// @param pendingStateHash The summary of the pending state to update to.
    /// @param daFact The data availability fact that proves the pending state.
    /// @param onchainUpdatesHash The hash of the onchain updates that are applied to the pending state.
    struct StateUpdateFacts {
        bytes32 prevStateHash;
        bytes32 pendingStateHash;
        bytes32 daFact;
        bytes32 onchainUpdatesHash;
        uint64 startingActionId;
        uint64 endingActionId;
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {FactTypes as T} from "src/facts/FactTypes.sol";

interface IFactRegistry {
    function getFactState(bytes32 fact) external view returns (T.FactState);

    event FactStateUpdated(bytes32 indexed fact, T.FactState oldState, T.FactState newState);
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {FactTypes as T} from "src/facts/FactTypes.sol";
import {IFactRegistry} from "src/facts/IFactRegistry.sol";

import {EigenDARollupUtils} from "src/dep/eigenda/EigenDARollupUtils.sol";

interface IEigenDAFactRegistry is IFactRegistry {
    error InvalidLength(uint256 length);
    error MismatchedLength(uint256 length1, uint256 length2);

    function registerDAFact(
        EigenDARollupUtils.BlobHeader[] memory blobHeaders,
        EigenDARollupUtils.BlobVerificationProof[] memory blobVerificationProofs
    ) external;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {IEigenDAFactRegistry} from "src/facts/da/IEigenDAFactRegistry.sol";
import {FactTypes as T} from "src/facts/FactTypes.sol";

import {EigenDARollupUtils} from "src/dep/eigenda/EigenDARollupUtils.sol";
import {IEigenDAServiceManager} from "src/dep/eigenda/IEigenDAServiceManager.sol";

/// @notice this contract does not check the validity of the blobs submitted.
///         It only emits events so that these blobs can be found on EigenDA.
contract MockEigenDAFactRegistry is IEigenDAFactRegistry {
    mapping(bytes32 => T.FactState) internal _registeredFact;

    event BlobInfo(uint32 indexed batchId, uint32 indexed blobIndex);

    function getFactState(bytes32 fact) external view override returns (T.FactState) {
        return _registeredFact[fact];
    }

    // Skips verifying blobs, and only emits events to find the blobs.
    function registerDAFact(
        EigenDARollupUtils.BlobHeader[] calldata blobHeaders,
        EigenDARollupUtils.BlobVerificationProof[] calldata blobVerificationProofs
    ) external {
        if (blobHeaders.length == 0) {
            revert InvalidLength(blobHeaders.length);
        }
        if (blobHeaders.length != blobVerificationProofs.length) {
            revert MismatchedLength(blobHeaders.length, blobVerificationProofs.length);
        }

        bytes memory commitmentData;
        for (uint256 i; i < blobHeaders.length; i++) {
            commitmentData = bytes.concat(commitmentData, _getDACommitmentBytes(blobHeaders[i]));
            emit BlobInfo(blobVerificationProofs[i].batchId, blobVerificationProofs[i].blobIndex);
        }

        _registeredFact[sha256(commitmentData)] = T.FactState.FINALIZED_PROVED;
    }

    function _getDACommitmentBytes(EigenDARollupUtils.BlobHeader memory blobHeader)
        internal
        pure
        returns (bytes memory)
    {
        // Packed encoding is okay because the lengths are fixed
        return abi.encodePacked(blobHeader.commitment.X, blobHeader.commitment.Y, blobHeader.dataLength);
    }
}