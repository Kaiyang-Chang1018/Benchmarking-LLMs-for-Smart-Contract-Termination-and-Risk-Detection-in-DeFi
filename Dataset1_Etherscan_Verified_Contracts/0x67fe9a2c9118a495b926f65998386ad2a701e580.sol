// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Bytes
/// @notice Bytes is a library for manipulating byte arrays.
library Bytes {
    /// @custom:attribution https://github.com/GNSPS/solidity-bytes-utils
    /// @notice Slices a byte array with a given starting index and length. Returns a new byte array
    ///         as opposed to a pointer to the original array. Will throw if trying to slice more
    ///         bytes than exist in the array.
    /// @param _bytes Byte array to slice.
    /// @param _start Starting index of the slice.
    /// @param _length Length of the slice.
    /// @return Slice of the input byte array.
    function slice(bytes memory _bytes, uint256 _start, uint256 _length) internal pure returns (bytes memory) {
        unchecked {
            require(_length + 31 >= _length, "slice_overflow");
            require(_start + _length >= _start, "slice_overflow");
            require(_bytes.length >= _start + _length, "slice_outOfBounds");
        }

        bytes memory tempBytes;

        assembly {
            switch iszero(_length)
            case 0 {
                // Get a location of some free memory and store it in tempBytes as
                // Solidity does for memory variables.
                tempBytes := mload(0x40)

                // The first word of the slice result is potentially a partial
                // word read from the original array. To read it, we calculate
                // the length of that partial word and start copying that many
                // bytes into the array. The first word we copy will start with
                // data we don't care about, but the last `lengthmod` bytes will
                // land at the beginning of the contents of the new array. When
                // we're done copying, we overwrite the full first word with
                // the actual length of the slice.
                let lengthmod := and(_length, 31)

                // The multiplication in the next line is necessary
                // because when slicing multiples of 32 bytes (lengthmod == 0)
                // the following copy loop was copying the origin's length
                // and then ending prematurely not copying everything it should.
                let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                let end := add(mc, _length)

                for {
                    // The multiplication in the next line has the same exact purpose
                    // as the one above.
                    let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } { mstore(mc, mload(cc)) }

                mstore(tempBytes, _length)

                //update free-memory pointer
                //allocating the array padded to 32 bytes like the compiler does now
                mstore(0x40, and(add(mc, 31), not(31)))
            }
            //if we want a zero-length slice let's just return a zero-length array
            default {
                tempBytes := mload(0x40)

                //zero out the 32 bytes slice we are about to return
                //we need to do it because Solidity does not garbage collect
                mstore(tempBytes, 0)

                mstore(0x40, add(tempBytes, 0x20))
            }
        }

        return tempBytes;
    }

    /// @notice Slices a byte array with a given starting index up to the end of the original byte
    ///         array. Returns a new array rathern than a pointer to the original.
    /// @param _bytes Byte array to slice.
    /// @param _start Starting index of the slice.
    /// @return Slice of the input byte array.
    function slice(bytes memory _bytes, uint256 _start) internal pure returns (bytes memory) {
        if (_start >= _bytes.length) {
            return bytes("");
        }
        return slice(_bytes, _start, _bytes.length - _start);
    }

    /// @notice Converts a byte array into a nibble array by splitting each byte into two nibbles.
    ///         Resulting nibble array will be exactly twice as long as the input byte array.
    /// @param _bytes Input byte array to convert.
    /// @return Resulting nibble array.
    function toNibbles(bytes memory _bytes) internal pure returns (bytes memory) {
        bytes memory _nibbles;
        assembly {
            // Grab a free memory offset for the new array
            _nibbles := mload(0x40)

            // Load the length of the passed bytes array from memory
            let bytesLength := mload(_bytes)

            // Calculate the length of the new nibble array
            // This is the length of the input array times 2
            let nibblesLength := shl(0x01, bytesLength)

            // Update the free memory pointer to allocate memory for the new array.
            // To do this, we add the length of the new array + 32 bytes for the array length
            // rounded up to the nearest 32 byte boundary to the current free memory pointer.
            mstore(0x40, add(_nibbles, and(not(0x1F), add(nibblesLength, 0x3F))))

            // Store the length of the new array in memory
            mstore(_nibbles, nibblesLength)

            // Store the memory offset of the _bytes array's contents on the stack
            let bytesStart := add(_bytes, 0x20)

            // Store the memory offset of the nibbles array's contents on the stack
            let nibblesStart := add(_nibbles, 0x20)

            // Loop through each byte in the input array
            for { let i := 0x00 } lt(i, bytesLength) { i := add(i, 0x01) } {
                // Get the starting offset of the next 2 bytes in the nibbles array
                let offset := add(nibblesStart, shl(0x01, i))
                // Load the byte at the current index within the `_bytes` array
                let b := byte(0x00, mload(add(bytesStart, i)))

                // Pull out the first nibble and store it in the new array
                mstore8(offset, shr(0x04, b))
                // Pull out the second nibble and store it in the new array
                mstore8(add(offset, 0x01), and(b, 0x0F))
            }
        }
        return _nibbles;
    }

    /// @notice Compares two byte arrays by comparing their keccak256 hashes.
    /// @param _bytes First byte array to compare.
    /// @param _other Second byte array to compare.
    /// @return True if the two byte arrays are equal, false otherwise.
    function equal(bytes memory _bytes, bytes memory _other) internal pure returns (bool) {
        return keccak256(_bytes) == keccak256(_other);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

/// @custom:attribution https://github.com/hamdiallam/Solidity-RLP
/// @title RLPReader
/// @notice RLPReader is a library for parsing RLP-encoded byte arrays into Solidity types. Adapted
///         from Solidity-RLP (https://github.com/hamdiallam/Solidity-RLP) by Hamdi Allam with
///         various tweaks to improve readability.
library RLPReader {
    /// @notice Custom pointer type to avoid confusion between pointers and uint256s.
    type MemoryPointer is uint256;

    /// @notice RLP item types.
    /// @custom:value DATA_ITEM Represents an RLP data item (NOT a list).
    /// @custom:value LIST_ITEM Represents an RLP list item.
    enum RLPItemType {
        DATA_ITEM,
        LIST_ITEM
    }

    /// @notice Struct representing an RLP item.
    /// @custom:field length Length of the RLP item.
    /// @custom:field ptr    Pointer to the RLP item in memory.
    struct RLPItem {
        uint256 length;
        MemoryPointer ptr;
    }

    /// @notice Max list length that this library will accept.
    uint256 internal constant MAX_LIST_LENGTH = 32;

    /// @notice Converts bytes to a reference to memory position and length.
    /// @param _in Input bytes to convert.
    /// @return out_ Output memory reference.
    function toRLPItem(bytes memory _in) internal pure returns (RLPItem memory out_) {
        // Empty arrays are not RLP items.
        require(_in.length > 0, "RLPReader: length of an RLP item must be greater than zero to be decodable");

        MemoryPointer ptr;
        assembly {
            ptr := add(_in, 32)
        }

        out_ = RLPItem({ length: _in.length, ptr: ptr });
    }

    /// @notice Reads an RLP list value into a list of RLP items.
    /// @param _in RLP list value.
    /// @return out_ Decoded RLP list items.
    function readList(RLPItem memory _in) internal pure returns (RLPItem[] memory out_) {
        (uint256 listOffset, uint256 listLength, RLPItemType itemType) = _decodeLength(_in);

        require(itemType == RLPItemType.LIST_ITEM, "RLPReader: decoded item type for list is not a list item");

        require(listOffset + listLength == _in.length, "RLPReader: list item has an invalid data remainder");

        // Solidity in-memory arrays can't be increased in size, but *can* be decreased in size by
        // writing to the length. Since we can't know the number of RLP items without looping over
        // the entire input, we'd have to loop twice to accurately size this array. It's easier to
        // simply set a reasonable maximum list length and decrease the size before we finish.
        out_ = new RLPItem[](MAX_LIST_LENGTH);

        uint256 itemCount = 0;
        uint256 offset = listOffset;
        while (offset < _in.length) {
            (uint256 itemOffset, uint256 itemLength,) = _decodeLength(
                RLPItem({ length: _in.length - offset, ptr: MemoryPointer.wrap(MemoryPointer.unwrap(_in.ptr) + offset) })
            );

            // We don't need to check itemCount < out.length explicitly because Solidity already
            // handles this check on our behalf, we'd just be wasting gas.
            out_[itemCount] = RLPItem({
                length: itemLength + itemOffset,
                ptr: MemoryPointer.wrap(MemoryPointer.unwrap(_in.ptr) + offset)
            });

            itemCount += 1;
            offset += itemOffset + itemLength;
        }

        // Decrease the array size to match the actual item count.
        assembly {
            mstore(out_, itemCount)
        }
    }

    /// @notice Reads an RLP list value into a list of RLP items.
    /// @param _in RLP list value.
    /// @return out_ Decoded RLP list items.
    function readList(bytes memory _in) internal pure returns (RLPItem[] memory out_) {
        out_ = readList(toRLPItem(_in));
    }

    /// @notice Reads an RLP bytes value into bytes.
    /// @param _in RLP bytes value.
    /// @return out_ Decoded bytes.
    function readBytes(RLPItem memory _in) internal pure returns (bytes memory out_) {
        (uint256 itemOffset, uint256 itemLength, RLPItemType itemType) = _decodeLength(_in);

        require(itemType == RLPItemType.DATA_ITEM, "RLPReader: decoded item type for bytes is not a data item");

        require(_in.length == itemOffset + itemLength, "RLPReader: bytes value contains an invalid remainder");

        out_ = _copy(_in.ptr, itemOffset, itemLength);
    }

    /// @notice Reads an RLP bytes value into bytes.
    /// @param _in RLP bytes value.
    /// @return out_ Decoded bytes.
    function readBytes(bytes memory _in) internal pure returns (bytes memory out_) {
        out_ = readBytes(toRLPItem(_in));
    }

    /// @notice Reads the raw bytes of an RLP item.
    /// @param _in RLP item to read.
    /// @return out_ Raw RLP bytes.
    function readRawBytes(RLPItem memory _in) internal pure returns (bytes memory out_) {
        out_ = _copy(_in.ptr, 0, _in.length);
    }

    /// @notice Decodes the length of an RLP item.
    /// @param _in RLP item to decode.
    /// @return offset_ Offset of the encoded data.
    /// @return length_ Length of the encoded data.
    /// @return type_ RLP item type (LIST_ITEM or DATA_ITEM).
    function _decodeLength(RLPItem memory _in)
        private
        pure
        returns (uint256 offset_, uint256 length_, RLPItemType type_)
    {
        // Short-circuit if there's nothing to decode, note that we perform this check when
        // the user creates an RLP item via toRLPItem, but it's always possible for them to bypass
        // that function and create an RLP item directly. So we need to check this anyway.
        require(_in.length > 0, "RLPReader: length of an RLP item must be greater than zero to be decodable");

        MemoryPointer ptr = _in.ptr;
        uint256 prefix;
        assembly {
            prefix := byte(0, mload(ptr))
        }

        if (prefix <= 0x7f) {
            // Single byte.
            return (0, 1, RLPItemType.DATA_ITEM);
        } else if (prefix <= 0xb7) {
            // Short string.

            // slither-disable-next-line variable-scope
            uint256 strLen = prefix - 0x80;

            require(
                _in.length > strLen, "RLPReader: length of content must be greater than string length (short string)"
            );

            bytes1 firstByteOfContent;
            assembly {
                firstByteOfContent := and(mload(add(ptr, 1)), shl(248, 0xff))
            }

            require(
                strLen != 1 || firstByteOfContent >= 0x80,
                "RLPReader: invalid prefix, single byte < 0x80 are not prefixed (short string)"
            );

            return (1, strLen, RLPItemType.DATA_ITEM);
        } else if (prefix <= 0xbf) {
            // Long string.
            uint256 lenOfStrLen = prefix - 0xb7;

            require(
                _in.length > lenOfStrLen,
                "RLPReader: length of content must be > than length of string length (long string)"
            );

            bytes1 firstByteOfContent;
            assembly {
                firstByteOfContent := and(mload(add(ptr, 1)), shl(248, 0xff))
            }

            require(
                firstByteOfContent != 0x00, "RLPReader: length of content must not have any leading zeros (long string)"
            );

            uint256 strLen;
            assembly {
                strLen := shr(sub(256, mul(8, lenOfStrLen)), mload(add(ptr, 1)))
            }

            require(strLen > 55, "RLPReader: length of content must be greater than 55 bytes (long string)");

            require(
                _in.length > lenOfStrLen + strLen,
                "RLPReader: length of content must be greater than total length (long string)"
            );

            return (1 + lenOfStrLen, strLen, RLPItemType.DATA_ITEM);
        } else if (prefix <= 0xf7) {
            // Short list.
            // slither-disable-next-line variable-scope
            uint256 listLen = prefix - 0xc0;

            require(_in.length > listLen, "RLPReader: length of content must be greater than list length (short list)");

            return (1, listLen, RLPItemType.LIST_ITEM);
        } else {
            // Long list.
            uint256 lenOfListLen = prefix - 0xf7;

            require(
                _in.length > lenOfListLen,
                "RLPReader: length of content must be > than length of list length (long list)"
            );

            bytes1 firstByteOfContent;
            assembly {
                firstByteOfContent := and(mload(add(ptr, 1)), shl(248, 0xff))
            }

            require(
                firstByteOfContent != 0x00, "RLPReader: length of content must not have any leading zeros (long list)"
            );

            uint256 listLen;
            assembly {
                listLen := shr(sub(256, mul(8, lenOfListLen)), mload(add(ptr, 1)))
            }

            require(listLen > 55, "RLPReader: length of content must be greater than 55 bytes (long list)");

            require(
                _in.length > lenOfListLen + listLen,
                "RLPReader: length of content must be greater than total length (long list)"
            );

            return (1 + lenOfListLen, listLen, RLPItemType.LIST_ITEM);
        }
    }

    /// @notice Copies the bytes from a memory location.
    /// @param _src    Pointer to the location to read from.
    /// @param _offset Offset to start reading from.
    /// @param _length Number of bytes to read.
    /// @return out_ Copied bytes.
    function _copy(MemoryPointer _src, uint256 _offset, uint256 _length) private pure returns (bytes memory out_) {
        out_ = new bytes(_length);
        if (_length == 0) {
            return out_;
        }

        // Mostly based on Solidity's copy_memory_to_memory:
        // https://github.com/ethereum/solidity/blob/34dd30d71b4da730488be72ff6af7083cf2a91f6/libsolidity/codegen/YulUtilFunctions.cpp#L102-L114
        uint256 src = MemoryPointer.unwrap(_src) + _offset;
        assembly {
            let dest := add(out_, 32)
            let i := 0
            for { } lt(i, _length) { i := add(i, 32) } { mstore(add(dest, i), mload(add(src, i))) }

            if gt(i, _length) { mstore(add(dest, _length), 0) }
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @custom:attribution https://github.com/bakaoh/solidity-rlp-encode
/// @title RLPWriter
/// @author RLPWriter is a library for encoding Solidity types to RLP bytes. Adapted from Bakaoh's
///         RLPEncode library (https://github.com/bakaoh/solidity-rlp-encode) with minor
///         modifications to improve legibility.
library RLPWriter {
    /// @notice RLP encodes a byte string.
    /// @param _in The byte string to encode.
    /// @return out_ The RLP encoded string in bytes.
    function writeBytes(bytes memory _in) internal pure returns (bytes memory out_) {
        if (_in.length == 1 && uint8(_in[0]) < 128) {
            out_ = _in;
        } else {
            out_ = abi.encodePacked(_writeLength(_in.length, 128), _in);
        }
    }

    /// @notice RLP encodes a list of RLP encoded byte byte strings.
    /// @param _in The list of RLP encoded byte strings.
    /// @return list_ The RLP encoded list of items in bytes.
    function writeList(bytes[] memory _in) internal pure returns (bytes memory list_) {
        list_ = _flatten(_in);
        list_ = abi.encodePacked(_writeLength(list_.length, 192), list_);
    }

    /// @notice RLP encodes a string.
    /// @param _in The string to encode.
    /// @return out_ The RLP encoded string in bytes.
    function writeString(string memory _in) internal pure returns (bytes memory out_) {
        out_ = writeBytes(bytes(_in));
    }

    /// @notice RLP encodes an address.
    /// @param _in The address to encode.
    /// @return out_ The RLP encoded address in bytes.
    function writeAddress(address _in) internal pure returns (bytes memory out_) {
        out_ = writeBytes(abi.encodePacked(_in));
    }

    /// @notice RLP encodes a uint.
    /// @param _in The uint256 to encode.
    /// @return out_ The RLP encoded uint256 in bytes.
    function writeUint(uint256 _in) internal pure returns (bytes memory out_) {
        out_ = writeBytes(_toBinary(_in));
    }

    /// @notice RLP encodes a bool.
    /// @param _in The bool to encode.
    /// @return out_ The RLP encoded bool in bytes.
    function writeBool(bool _in) internal pure returns (bytes memory out_) {
        out_ = new bytes(1);
        out_[0] = (_in ? bytes1(0x01) : bytes1(0x80));
    }

    /// @notice Encode the first byte and then the `len` in binary form if `length` is more than 55.
    /// @param _len    The length of the string or the payload.
    /// @param _offset 128 if item is string, 192 if item is list.
    /// @return out_ RLP encoded bytes.
    function _writeLength(uint256 _len, uint256 _offset) private pure returns (bytes memory out_) {
        if (_len < 56) {
            out_ = new bytes(1);
            out_[0] = bytes1(uint8(_len) + uint8(_offset));
        } else {
            uint256 lenLen;
            uint256 i = 1;
            while (_len / i != 0) {
                lenLen++;
                i *= 256;
            }

            out_ = new bytes(lenLen + 1);
            out_[0] = bytes1(uint8(lenLen) + uint8(_offset) + 55);
            for (i = 1; i <= lenLen; i++) {
                out_[i] = bytes1(uint8((_len / (256 ** (lenLen - i))) % 256));
            }
        }
    }

    /// @notice Encode integer in big endian binary form with no leading zeroes.
    /// @param _x The integer to encode.
    /// @return out_ RLP encoded bytes.
    function _toBinary(uint256 _x) private pure returns (bytes memory out_) {
        bytes memory b = abi.encodePacked(_x);

        uint256 i = 0;
        for (; i < 32; i++) {
            if (b[i] != 0) {
                break;
            }
        }

        out_ = new bytes(32 - i);
        for (uint256 j = 0; j < out_.length; j++) {
            out_[j] = b[i++];
        }
    }

    /// @custom:attribution https://github.com/Arachnid/solidity-stringutils
    /// @notice Copies a piece of memory to another location.
    /// @param _dest Destination location.
    /// @param _src  Source location.
    /// @param _len  Length of memory to copy.
    function _memcpy(uint256 _dest, uint256 _src, uint256 _len) private pure {
        uint256 dest = _dest;
        uint256 src = _src;
        uint256 len = _len;

        for (; len >= 32; len -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }

        uint256 mask;
        unchecked {
            mask = 256 ** (32 - len) - 1;
        }
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }
    }

    /// @custom:attribution https://github.com/sammayo/solidity-rlp-encoder
    /// @notice Flattens a list of byte strings into one byte string.
    /// @param _list List of byte strings to flatten.
    /// @return out_ The flattened byte string.
    function _flatten(bytes[] memory _list) private pure returns (bytes memory out_) {
        if (_list.length == 0) {
            return new bytes(0);
        }

        uint256 len;
        uint256 i = 0;
        for (; i < _list.length; i++) {
            len += _list[i].length;
        }

        out_ = new bytes(len);
        uint256 flattenedPtr;
        assembly {
            flattenedPtr := add(out_, 0x20)
        }

        for (i = 0; i < _list.length; i++) {
            bytes memory item = _list[i];

            uint256 listPtr;
            assembly {
                listPtr := add(item, 0x20)
            }

            _memcpy(flattenedPtr, listPtr, item.length);
            flattenedPtr += _list[i].length;
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Bytes } from "../Bytes.sol";
import { RLPReader } from "../rlp/RLPReader.sol";

/// @title MerkleTrie
/// @notice MerkleTrie is a small library for verifying standard Ethereum Merkle-Patricia trie
///         inclusion proofs. By default, this library assumes a hexary trie. One can change the
///         trie radix constant to support other trie radixes.
library MerkleTrie {
    /// @notice Struct representing a node in the trie.
    /// @custom:field encoded The RLP-encoded node.
    /// @custom:field decoded The RLP-decoded node.
    struct TrieNode {
        bytes encoded;
        RLPReader.RLPItem[] decoded;
    }

    /// @notice Determines the number of elements per branch node.
    uint256 internal constant TREE_RADIX = 16;

    /// @notice Branch nodes have TREE_RADIX elements and one value element.
    uint256 internal constant BRANCH_NODE_LENGTH = TREE_RADIX + 1;

    /// @notice Leaf nodes and extension nodes have two elements, a `path` and a `value`.
    uint256 internal constant LEAF_OR_EXTENSION_NODE_LENGTH = 2;

    /// @notice Prefix for even-nibbled extension node paths.
    uint8 internal constant PREFIX_EXTENSION_EVEN = 0;

    /// @notice Prefix for odd-nibbled extension node paths.
    uint8 internal constant PREFIX_EXTENSION_ODD = 1;

    /// @notice Prefix for even-nibbled leaf node paths.
    uint8 internal constant PREFIX_LEAF_EVEN = 2;

    /// @notice Prefix for odd-nibbled leaf node paths.
    uint8 internal constant PREFIX_LEAF_ODD = 3;

    /// @notice Verifies a proof that a given key/value pair is present in the trie.
    /// @param _key   Key of the node to search for, as a hex string.
    /// @param _value Value of the node to search for, as a hex string.
    /// @param _proof Merkle trie inclusion proof for the desired node. Unlike traditional Merkle
    ///               trees, this proof is executed top-down and consists of a list of RLP-encoded
    ///               nodes that make a path down to the target node.
    /// @param _root  Known root of the Merkle trie. Used to verify that the included proof is
    ///               correctly constructed.
    /// @return valid_ Whether or not the proof is valid.
    function verifyInclusionProof(
        bytes memory _key,
        bytes memory _value,
        bytes[] memory _proof,
        bytes32 _root
    )
        internal
        pure
        returns (bool valid_)
    {
        valid_ = Bytes.equal(_value, get(_key, _proof, _root));
    }

    /// @notice Retrieves the value associated with a given key.
    /// @param _key   Key to search for, as hex bytes.
    /// @param _proof Merkle trie inclusion proof for the key.
    /// @param _root  Known root of the Merkle trie.
    /// @return value_ Value of the key if it exists.
    function get(bytes memory _key, bytes[] memory _proof, bytes32 _root) internal pure returns (bytes memory value_) {
        require(_key.length > 0, "MerkleTrie: empty key");

        TrieNode[] memory proof = _parseProof(_proof);
        bytes memory key = Bytes.toNibbles(_key);
        bytes memory currentNodeID = abi.encodePacked(_root);
        uint256 currentKeyIndex = 0;

        // Proof is top-down, so we start at the first element (root).
        for (uint256 i = 0; i < proof.length; i++) {
            TrieNode memory currentNode = proof[i];

            // Key index should never exceed total key length or we'll be out of bounds.
            require(currentKeyIndex <= key.length, "MerkleTrie: key index exceeds total key length");

            if (currentKeyIndex == 0) {
                // First proof element is always the root node.
                require(
                    Bytes.equal(abi.encodePacked(keccak256(currentNode.encoded)), currentNodeID),
                    "MerkleTrie: invalid root hash"
                );
            } else if (currentNode.encoded.length >= 32) {
                // Nodes 32 bytes or larger are hashed inside branch nodes.
                require(
                    Bytes.equal(abi.encodePacked(keccak256(currentNode.encoded)), currentNodeID),
                    "MerkleTrie: invalid large internal hash"
                );
            } else {
                // Nodes smaller than 32 bytes aren't hashed.
                require(Bytes.equal(currentNode.encoded, currentNodeID), "MerkleTrie: invalid internal node hash");
            }

            if (currentNode.decoded.length == BRANCH_NODE_LENGTH) {
                if (currentKeyIndex == key.length) {
                    // Value is the last element of the decoded list (for branch nodes). There's
                    // some ambiguity in the Merkle trie specification because bytes(0) is a
                    // valid value to place into the trie, but for branch nodes bytes(0) can exist
                    // even when the value wasn't explicitly placed there. Geth treats a value of
                    // bytes(0) as "key does not exist" and so we do the same.
                    value_ = RLPReader.readBytes(currentNode.decoded[TREE_RADIX]);
                    require(value_.length > 0, "MerkleTrie: value length must be greater than zero (branch)");

                    // Extra proof elements are not allowed.
                    require(i == proof.length - 1, "MerkleTrie: value node must be last node in proof (branch)");

                    return value_;
                } else {
                    // We're not at the end of the key yet.
                    // Figure out what the next node ID should be and continue.
                    uint8 branchKey = uint8(key[currentKeyIndex]);
                    RLPReader.RLPItem memory nextNode = currentNode.decoded[branchKey];
                    currentNodeID = _getNodeID(nextNode);
                    currentKeyIndex += 1;
                }
            } else if (currentNode.decoded.length == LEAF_OR_EXTENSION_NODE_LENGTH) {
                bytes memory path = _getNodePath(currentNode);
                uint8 prefix = uint8(path[0]);
                uint8 offset = 2 - (prefix % 2);
                bytes memory pathRemainder = Bytes.slice(path, offset);
                bytes memory keyRemainder = Bytes.slice(key, currentKeyIndex);
                uint256 sharedNibbleLength = _getSharedNibbleLength(pathRemainder, keyRemainder);

                // Whether this is a leaf node or an extension node, the path remainder MUST be a
                // prefix of the key remainder (or be equal to the key remainder) or the proof is
                // considered invalid.
                require(
                    pathRemainder.length == sharedNibbleLength,
                    "MerkleTrie: path remainder must share all nibbles with key"
                );

                if (prefix == PREFIX_LEAF_EVEN || prefix == PREFIX_LEAF_ODD) {
                    // Prefix of 2 or 3 means this is a leaf node. For the leaf node to be valid,
                    // the key remainder must be exactly equal to the path remainder. We already
                    // did the necessary byte comparison, so it's more efficient here to check that
                    // the key remainder length equals the shared nibble length, which implies
                    // equality with the path remainder (since we already did the same check with
                    // the path remainder and the shared nibble length).
                    require(
                        keyRemainder.length == sharedNibbleLength,
                        "MerkleTrie: key remainder must be identical to path remainder"
                    );

                    // Our Merkle Trie is designed specifically for the purposes of the Ethereum
                    // state trie. Empty values are not allowed in the state trie, so we can safely
                    // say that if the value is empty, the key should not exist and the proof is
                    // invalid.
                    value_ = RLPReader.readBytes(currentNode.decoded[1]);
                    require(value_.length > 0, "MerkleTrie: value length must be greater than zero (leaf)");

                    // Extra proof elements are not allowed.
                    require(i == proof.length - 1, "MerkleTrie: value node must be last node in proof (leaf)");

                    return value_;
                } else if (prefix == PREFIX_EXTENSION_EVEN || prefix == PREFIX_EXTENSION_ODD) {
                    // Prefix of 0 or 1 means this is an extension node. We move onto the next node
                    // in the proof and increment the key index by the length of the path remainder
                    // which is equal to the shared nibble length.
                    currentNodeID = _getNodeID(currentNode.decoded[1]);
                    currentKeyIndex += sharedNibbleLength;
                } else {
                    revert("MerkleTrie: received a node with an unknown prefix");
                }
            } else {
                revert("MerkleTrie: received an unparseable node");
            }
        }

        revert("MerkleTrie: ran out of proof elements");
    }

    /// @notice Parses an array of proof elements into a new array that contains both the original
    ///         encoded element and the RLP-decoded element.
    /// @param _proof Array of proof elements to parse.
    /// @return proof_ Proof parsed into easily accessible structs.
    function _parseProof(bytes[] memory _proof) private pure returns (TrieNode[] memory proof_) {
        uint256 length = _proof.length;
        proof_ = new TrieNode[](length);
        for (uint256 i = 0; i < length;) {
            proof_[i] = TrieNode({ encoded: _proof[i], decoded: RLPReader.readList(_proof[i]) });
            unchecked {
                ++i;
            }
        }
    }

    /// @notice Picks out the ID for a node. Node ID is referred to as the "hash" within the
    ///         specification, but nodes < 32 bytes are not actually hashed.
    /// @param _node Node to pull an ID for.
    /// @return id_ ID for the node, depending on the size of its contents.
    function _getNodeID(RLPReader.RLPItem memory _node) private pure returns (bytes memory id_) {
        id_ = _node.length < 32 ? RLPReader.readRawBytes(_node) : RLPReader.readBytes(_node);
    }

    /// @notice Gets the path for a leaf or extension node.
    /// @param _node Node to get a path for.
    /// @return nibbles_ Node path, converted to an array of nibbles.
    function _getNodePath(TrieNode memory _node) private pure returns (bytes memory nibbles_) {
        nibbles_ = Bytes.toNibbles(RLPReader.readBytes(_node.decoded[0]));
    }

    /// @notice Utility; determines the number of nibbles shared between two nibble arrays.
    /// @param _a First nibble array.
    /// @param _b Second nibble array.
    /// @return shared_ Number of shared nibbles.
    function _getSharedNibbleLength(bytes memory _a, bytes memory _b) private pure returns (uint256 shared_) {
        uint256 max = (_a.length < _b.length) ? _a.length : _b.length;
        for (; shared_ < max && _a[shared_] == _b[shared_];) {
            unchecked {
                ++shared_;
            }
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { MerkleTrie } from "./MerkleTrie.sol";

/// @title SecureMerkleTrie
/// @notice SecureMerkleTrie is a thin wrapper around the MerkleTrie library that hashes the input
///         keys. Ethereum's state trie hashes input keys before storing them.
library SecureMerkleTrie {
    /// @notice Verifies a proof that a given key/value pair is present in the Merkle trie.
    /// @param _key   Key of the node to search for, as a hex string.
    /// @param _value Value of the node to search for, as a hex string.
    /// @param _proof Merkle trie inclusion proof for the desired node. Unlike traditional Merkle
    ///               trees, this proof is executed top-down and consists of a list of RLP-encoded
    ///               nodes that make a path down to the target node.
    /// @param _root  Known root of the Merkle trie. Used to verify that the included proof is
    ///               correctly constructed.
    /// @return valid_ Whether or not the proof is valid.
    function verifyInclusionProof(
        bytes memory _key,
        bytes memory _value,
        bytes[] memory _proof,
        bytes32 _root
    )
        internal
        pure
        returns (bool valid_)
    {
        bytes memory key = _getSecureKey(_key);
        valid_ = MerkleTrie.verifyInclusionProof(key, _value, _proof, _root);
    }

    /// @notice Retrieves the value associated with a given key.
    /// @param _key   Key to search for, as hex bytes.
    /// @param _proof Merkle trie inclusion proof for the key.
    /// @param _root  Known root of the Merkle trie.
    /// @return value_ Value of the key if it exists.
    function get(bytes memory _key, bytes[] memory _proof, bytes32 _root) internal pure returns (bytes memory value_) {
        bytes memory key = _getSecureKey(_key);
        value_ = MerkleTrie.get(key, _proof, _root);
    }

    /// @notice Computes the hashed version of the input key.
    /// @param _key Key to hash.
    /// @return hash_ Hashed version of the key.
    function _getSecureKey(bytes memory _key) private pure returns (bytes memory hash_) {
        hash_ = abi.encodePacked(keccak256(_key));
    }
}
// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.6.11;

interface IInterchainSecurityModule {
    enum Types {
        UNUSED,
        ROUTING,
        AGGREGATION,
        LEGACY_MULTISIG,
        MERKLE_ROOT_MULTISIG,
        MESSAGE_ID_MULTISIG,
        NULL, // used with relayer carrying no metadata
        CCIP_READ,
        ARB_L2_TO_L1,
        WEIGHT_MERKLE_ROOT_MULTISIG,
        WEIGHT_MESSAGE_ID_MULTISIG,
        OP_L2_TO_L1
    }

    /**
     * @notice Returns an enum that represents the type of security model
     * encoded by this ISM.
     * @dev Relayers infer how to fetch and format metadata.
     */
    function moduleType() external view returns (uint8);

    /**
     * @notice Defines a security model responsible for verifying interchain
     * messages based on the provided metadata.
     * @param _metadata Off-chain metadata provided by a relayer, specific to
     * the security model encoded by the module (e.g. validator signatures)
     * @param _message Hyperlane encoded interchain message
     * @return True if the message was verified
     */
    function verify(
        bytes calldata _metadata,
        bytes calldata _message
    ) external returns (bool);
}

interface ISpecifiesInterchainSecurityModule {
    function interchainSecurityModule()
        external
        view
        returns (IInterchainSecurityModule);
}
// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.8.0;

import {IInterchainSecurityModule} from "./IInterchainSecurityModule.sol";
import {IPostDispatchHook} from "./hooks/IPostDispatchHook.sol";

interface IMailbox {
    // ============ Events ============
    /**
     * @notice Emitted when a new message is dispatched via Hyperlane
     * @param sender The address that dispatched the message
     * @param destination The destination domain of the message
     * @param recipient The message recipient address on `destination`
     * @param message Raw bytes of message
     */
    event Dispatch(
        address indexed sender,
        uint32 indexed destination,
        bytes32 indexed recipient,
        bytes message
    );

    /**
     * @notice Emitted when a new message is dispatched via Hyperlane
     * @param messageId The unique message identifier
     */
    event DispatchId(bytes32 indexed messageId);

    /**
     * @notice Emitted when a Hyperlane message is processed
     * @param messageId The unique message identifier
     */
    event ProcessId(bytes32 indexed messageId);

    /**
     * @notice Emitted when a Hyperlane message is delivered
     * @param origin The origin domain of the message
     * @param sender The message sender address on `origin`
     * @param recipient The address that handled the message
     */
    event Process(
        uint32 indexed origin,
        bytes32 indexed sender,
        address indexed recipient
    );

    function localDomain() external view returns (uint32);

    function delivered(bytes32 messageId) external view returns (bool);

    function defaultIsm() external view returns (IInterchainSecurityModule);

    function defaultHook() external view returns (IPostDispatchHook);

    function requiredHook() external view returns (IPostDispatchHook);

    function latestDispatchedId() external view returns (bytes32);

    function dispatch(
        uint32 destinationDomain,
        bytes32 recipientAddress,
        bytes calldata messageBody
    ) external payable returns (bytes32 messageId);

    function quoteDispatch(
        uint32 destinationDomain,
        bytes32 recipientAddress,
        bytes calldata messageBody
    ) external view returns (uint256 fee);

    function dispatch(
        uint32 destinationDomain,
        bytes32 recipientAddress,
        bytes calldata body,
        bytes calldata defaultHookMetadata
    ) external payable returns (bytes32 messageId);

    function quoteDispatch(
        uint32 destinationDomain,
        bytes32 recipientAddress,
        bytes calldata messageBody,
        bytes calldata defaultHookMetadata
    ) external view returns (uint256 fee);

    function dispatch(
        uint32 destinationDomain,
        bytes32 recipientAddress,
        bytes calldata body,
        bytes calldata customHookMetadata,
        IPostDispatchHook customHook
    ) external payable returns (bytes32 messageId);

    function quoteDispatch(
        uint32 destinationDomain,
        bytes32 recipientAddress,
        bytes calldata messageBody,
        bytes calldata customHookMetadata,
        IPostDispatchHook customHook
    ) external view returns (uint256 fee);

    function process(
        bytes calldata metadata,
        bytes calldata message
    ) external payable;

    function recipientIsm(
        address recipient
    ) external view returns (IInterchainSecurityModule module);
}
// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.6.11;

interface IMessageRecipient {
    function handle(
        uint32 _origin,
        bytes32 _sender,
        bytes calldata _message
    ) external payable;
}
// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.8.0;

/*@@@@@@@       @@@@@@@@@
 @@@@@@@@@       @@@@@@@@@
  @@@@@@@@@       @@@@@@@@@
   @@@@@@@@@       @@@@@@@@@
    @@@@@@@@@@@@@@@@@@@@@@@@@
     @@@@@  HYPERLANE  @@@@@@@
    @@@@@@@@@@@@@@@@@@@@@@@@@
   @@@@@@@@@       @@@@@@@@@
  @@@@@@@@@       @@@@@@@@@
 @@@@@@@@@       @@@@@@@@@
@@@@@@@@@       @@@@@@@@*/

interface IPostDispatchHook {
    enum Types {
        UNUSED,
        ROUTING,
        AGGREGATION,
        MERKLE_TREE,
        INTERCHAIN_GAS_PAYMASTER,
        FALLBACK_ROUTING,
        ID_AUTH_ISM,
        PAUSABLE,
        PROTOCOL_FEE,
        LAYER_ZERO_V1,
        RATE_LIMITED,
        ARB_L2_TO_L1,
        OP_L2_TO_L1
    }

    /**
     * @notice Returns an enum that represents the type of hook
     */
    function hookType() external view returns (uint8);

    /**
     * @notice Returns whether the hook supports metadata
     * @param metadata metadata
     * @return Whether the hook supports metadata
     */
    function supportsMetadata(
        bytes calldata metadata
    ) external view returns (bool);

    /**
     * @notice Post action after a message is dispatched via the Mailbox
     * @param metadata The metadata required for the hook
     * @param message The message passed from the Mailbox.dispatch() call
     */
    function postDispatch(
        bytes calldata metadata,
        bytes calldata message
    ) external payable;

    /**
     * @notice Compute the payment required by the postDispatch call
     * @param metadata The metadata required for the hook
     * @param message The message passed from the Mailbox.dispatch() call
     * @return Quoted payment for the postDispatch call
     */
    function quoteDispatch(
        bytes calldata metadata,
        bytes calldata message
    ) external view returns (uint256);
}
// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.8.0;

import {TypeCasts} from "./TypeCasts.sol";

/**
 * @title Hyperlane Message Library
 * @notice Library for formatted messages used by Mailbox
 **/
library Message {
    using TypeCasts for bytes32;

    uint256 private constant VERSION_OFFSET = 0;
    uint256 private constant NONCE_OFFSET = 1;
    uint256 private constant ORIGIN_OFFSET = 5;
    uint256 private constant SENDER_OFFSET = 9;
    uint256 private constant DESTINATION_OFFSET = 41;
    uint256 private constant RECIPIENT_OFFSET = 45;
    uint256 private constant BODY_OFFSET = 77;

    /**
     * @notice Returns formatted (packed) Hyperlane message with provided fields
     * @dev This function should only be used in memory message construction.
     * @param _version The version of the origin and destination Mailboxes
     * @param _nonce A nonce to uniquely identify the message on its origin chain
     * @param _originDomain Domain of origin chain
     * @param _sender Address of sender as bytes32
     * @param _destinationDomain Domain of destination chain
     * @param _recipient Address of recipient on destination chain as bytes32
     * @param _messageBody Raw bytes of message body
     * @return Formatted message
     */
    function formatMessage(
        uint8 _version,
        uint32 _nonce,
        uint32 _originDomain,
        bytes32 _sender,
        uint32 _destinationDomain,
        bytes32 _recipient,
        bytes calldata _messageBody
    ) internal pure returns (bytes memory) {
        return
            abi.encodePacked(
                _version,
                _nonce,
                _originDomain,
                _sender,
                _destinationDomain,
                _recipient,
                _messageBody
            );
    }

    /**
     * @notice Returns the message ID.
     * @param _message ABI encoded Hyperlane message.
     * @return ID of `_message`
     */
    function id(bytes memory _message) internal pure returns (bytes32) {
        return keccak256(_message);
    }

    /**
     * @notice Returns the message version.
     * @param _message ABI encoded Hyperlane message.
     * @return Version of `_message`
     */
    function version(bytes calldata _message) internal pure returns (uint8) {
        return uint8(bytes1(_message[VERSION_OFFSET:NONCE_OFFSET]));
    }

    /**
     * @notice Returns the message nonce.
     * @param _message ABI encoded Hyperlane message.
     * @return Nonce of `_message`
     */
    function nonce(bytes calldata _message) internal pure returns (uint32) {
        return uint32(bytes4(_message[NONCE_OFFSET:ORIGIN_OFFSET]));
    }

    /**
     * @notice Returns the message origin domain.
     * @param _message ABI encoded Hyperlane message.
     * @return Origin domain of `_message`
     */
    function origin(bytes calldata _message) internal pure returns (uint32) {
        return uint32(bytes4(_message[ORIGIN_OFFSET:SENDER_OFFSET]));
    }

    /**
     * @notice Returns the message sender as bytes32.
     * @param _message ABI encoded Hyperlane message.
     * @return Sender of `_message` as bytes32
     */
    function sender(bytes calldata _message) internal pure returns (bytes32) {
        return bytes32(_message[SENDER_OFFSET:DESTINATION_OFFSET]);
    }

    /**
     * @notice Returns the message sender as address.
     * @param _message ABI encoded Hyperlane message.
     * @return Sender of `_message` as address
     */
    function senderAddress(
        bytes calldata _message
    ) internal pure returns (address) {
        return sender(_message).bytes32ToAddress();
    }

    /**
     * @notice Returns the message destination domain.
     * @param _message ABI encoded Hyperlane message.
     * @return Destination domain of `_message`
     */
    function destination(
        bytes calldata _message
    ) internal pure returns (uint32) {
        return uint32(bytes4(_message[DESTINATION_OFFSET:RECIPIENT_OFFSET]));
    }

    /**
     * @notice Returns the message recipient as bytes32.
     * @param _message ABI encoded Hyperlane message.
     * @return Recipient of `_message` as bytes32
     */
    function recipient(
        bytes calldata _message
    ) internal pure returns (bytes32) {
        return bytes32(_message[RECIPIENT_OFFSET:BODY_OFFSET]);
    }

    /**
     * @notice Returns the message recipient as address.
     * @param _message ABI encoded Hyperlane message.
     * @return Recipient of `_message` as address
     */
    function recipientAddress(
        bytes calldata _message
    ) internal pure returns (address) {
        return recipient(_message).bytes32ToAddress();
    }

    /**
     * @notice Returns the message body.
     * @param _message ABI encoded Hyperlane message.
     * @return Body of `_message`
     */
    function body(
        bytes calldata _message
    ) internal pure returns (bytes calldata) {
        return bytes(_message[BODY_OFFSET:]);
    }
}
// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.6.11;

library TypeCasts {
    // alignment preserving cast
    function addressToBytes32(address _addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(_addr)));
    }

    // alignment preserving cast
    function bytes32ToAddress(bytes32 _buf) internal pure returns (address) {
        return address(uint160(uint256(_buf)));
    }
}
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
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC5267.sol)

pragma solidity ^0.8.20;

interface IERC5267 {
    /**
     * @dev MAY be emitted to signal that the domain could have changed.
     */
    event EIP712DomainChanged();

    /**
     * @dev returns the fields and values that describe the domain separator used by this contract for EIP-712
     * signature.
     */
    function eip712Domain()
        external
        view
        returns (
            bytes1 fields,
            string memory name,
            string memory version,
            uint256 chainId,
            address verifyingContract,
            bytes32 salt,
            uint256[] memory extensions
        );
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/draft-IERC6093.sol)
pragma solidity ^0.8.20;

/**
 * @dev Standard ERC20 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC20 tokens.
 */
interface IERC20Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC20InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC20InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `spender`’s `allowance`. Used in transfers.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     * @param allowance Amount of tokens a `spender` is allowed to operate with.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC20InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `spender` to be approved. Used in approvals.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC20InvalidSpender(address spender);
}

/**
 * @dev Standard ERC721 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC721 tokens.
 */
interface IERC721Errors {
    /**
     * @dev Indicates that an address can't be an owner. For example, `address(0)` is a forbidden owner in EIP-20.
     * Used in balance queries.
     * @param owner Address of the current owner of a token.
     */
    error ERC721InvalidOwner(address owner);

    /**
     * @dev Indicates a `tokenId` whose `owner` is the zero address.
     * @param tokenId Identifier number of a token.
     */
    error ERC721NonexistentToken(uint256 tokenId);

    /**
     * @dev Indicates an error related to the ownership over a particular token. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param tokenId Identifier number of a token.
     * @param owner Address of the current owner of a token.
     */
    error ERC721IncorrectOwner(address sender, uint256 tokenId, address owner);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC721InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC721InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param tokenId Identifier number of a token.
     */
    error ERC721InsufficientApproval(address operator, uint256 tokenId);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC721InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC721InvalidOperator(address operator);
}

/**
 * @dev Standard ERC1155 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC1155 tokens.
 */
interface IERC1155Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     * @param tokenId Identifier number of a token.
     */
    error ERC1155InsufficientBalance(address sender, uint256 balance, uint256 needed, uint256 tokenId);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC1155InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC1155InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param owner Address of the current owner of a token.
     */
    error ERC1155MissingApprovalForAll(address operator, address owner);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC1155InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC1155InvalidOperator(address operator);

    /**
     * @dev Indicates an array length mismatch between ids and values in a safeBatchTransferFrom operation.
     * Used in batch transfers.
     * @param idsLength Length of the array of token identifiers
     * @param valuesLength Length of the array of token amounts
     */
    error ERC1155InvalidArrayLength(uint256 idsLength, uint256 valuesLength);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.20;

import {IERC20} from "./IERC20.sol";
import {IERC20Metadata} from "./extensions/IERC20Metadata.sol";
import {Context} from "../../utils/Context.sol";
import {IERC20Errors} from "../../interfaces/draft-IERC6093.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * The default value of {decimals} is 18. To change this, you should override
 * this function so it returns a different value.
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 */
abstract contract ERC20 is Context, IERC20, IERC20Metadata, IERC20Errors {
    mapping(address account => uint256) private _balances;

    mapping(address account => mapping(address spender => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `value`.
     */
    function transfer(address to, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `value` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, value);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `value`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `value`.
     */
    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }

    /**
     * @dev Transfers a `value` amount of tokens from `from` to `to`, or alternatively mints (or burns) if `from`
     * (or `to`) is the zero address. All customizations to transfers, mints, and burns should be done by overriding
     * this function.
     *
     * Emits a {Transfer} event.
     */
    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            // Overflow check required: The rest of the code assumes that totalSupply never overflows
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                // Overflow not possible: value <= fromBalance <= totalSupply.
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                // Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
                _totalSupply -= value;
            }
        } else {
            unchecked {
                // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    /**
     * @dev Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0).
     * Relies on the `_update` mechanism
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }

    /**
     * @dev Destroys a `value` amount of tokens from `account`, lowering the total supply.
     * Relies on the `_update` mechanism.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead
     */
    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }

    /**
     * @dev Sets `value` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     *
     * Overrides to this logic should be done to the variant with an additional `bool emitEvent` argument.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        _approve(owner, spender, value, true);
    }

    /**
     * @dev Variant of {_approve} with an optional flag to enable or disable the {Approval} event.
     *
     * By default (when calling {_approve}) the flag is set to true. On the other hand, approval changes made by
     * `_spendAllowance` during the `transferFrom` operation set the flag to false. This saves gas by not emitting any
     * `Approval` event during `transferFrom` operations.
     *
     * Anyone who wishes to continue emitting `Approval` events on the`transferFrom` operation can force the flag to
     * true using the following override:
     * ```
     * function _approve(address owner, address spender, uint256 value, bool) internal virtual override {
     *     super._approve(owner, spender, value, true);
     * }
     * ```
     *
     * Requirements are the same as {_approve}.
     */
    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual {
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        _allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `value`.
     *
     * Does not update the allowance value in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Does not emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Permit.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 * ==== Security Considerations
 *
 * There are two important considerations concerning the use of `permit`. The first is that a valid permit signature
 * expresses an allowance, and it should not be assumed to convey additional meaning. In particular, it should not be
 * considered as an intention to spend the allowance in any specific way. The second is that because permits have
 * built-in replay protection and can be submitted by anyone, they can be frontrun. A protocol that uses permits should
 * take this into consideration and allow a `permit` call to fail. Combining these two aspects, a pattern that may be
 * generally recommended is:
 *
 * ```solidity
 * function doThingWithPermit(..., uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
 *     try token.permit(msg.sender, address(this), value, deadline, v, r, s) {} catch {}
 *     doThing(..., value);
 * }
 *
 * function doThing(..., uint256 value) public {
 *     token.safeTransferFrom(msg.sender, address(this), value);
 *     ...
 * }
 * ```
 *
 * Observe that: 1) `msg.sender` is used as the owner, leaving no ambiguity as to the signer intent, and 2) the use of
 * `try/catch` allows the permit to fail and makes the code tolerant to frontrunning. (See also
 * {SafeERC20-safeTransferFrom}).
 *
 * Additionally, note that smart contract wallets (such as Argent or Safe) are not able to produce permit signatures, so
 * contracts should have entry points that don't rely on permit.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     *
     * CAUTION: See Security Considerations above.
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../IERC20.sol";
import {IERC20Permit} from "../extensions/IERC20Permit.sol";
import {Address} from "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    /**
     * @dev An operation with an ERC20 token failed.
     */
    error SafeERC20FailedOperation(address token);

    /**
     * @dev Indicates a failed `decreaseAllowance` request.
     */
    error SafeERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `requestedDecrease`. If `token` returns no
     * value, non-reverting calls are assumed to be successful.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 requestedDecrease) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(spender, currentAllowance, requestedDecrease);
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data);
        if (returndata.length != 0 && !abi.decode(returndata, (bool))) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silents catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We cannot use {Address-functionCall} here since this should return false
        // and not revert is the subcall reverts.

        (bool success, bytes memory returndata) = address(token).call(data);
        return success && (returndata.length == 0 || abi.decode(returndata, (bool))) && address(token).code.length > 0;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Address.sol)

pragma solidity ^0.8.20;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev The ETH balance of the account is not enough to perform the operation.
     */
    error AddressInsufficientBalance(address account);

    /**
     * @dev There's no code at `target` (it is not a contract).
     */
    error AddressEmptyCode(address target);

    /**
     * @dev A call to an address target failed. The target may have reverted.
     */
    error FailedInnerCall();

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.20/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        if (address(this).balance < amount) {
            revert AddressInsufficientBalance(address(this));
        }

        (bool success, ) = recipient.call{value: amount}("");
        if (!success) {
            revert FailedInnerCall();
        }
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason or custom error, it is bubbled
     * up by this function (like regular Solidity function calls). However, if
     * the call reverted with no returned reason, this function reverts with a
     * {FailedInnerCall} error.
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        if (address(this).balance < value) {
            revert AddressInsufficientBalance(address(this));
        }
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and reverts if the target
     * was not a contract or bubbling up the revert reason (falling back to {FailedInnerCall}) in case of an
     * unsuccessful call.
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata
    ) internal view returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            // only check if target is a contract if the call was successful and the return data is empty
            // otherwise we already know that it was a contract
            if (returndata.length == 0 && target.code.length == 0) {
                revert AddressEmptyCode(target);
            }
            return returndata;
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and reverts if it wasn't, either by bubbling the
     * revert reason or with a default {FailedInnerCall} error.
     */
    function verifyCallResult(bool success, bytes memory returndata) internal pure returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            return returndata;
        }
    }

    /**
     * @dev Reverts with returndata if present. Otherwise reverts with {FailedInnerCall}.
     */
    function _revert(bytes memory returndata) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert FailedInnerCall();
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

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

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/ShortStrings.sol)

pragma solidity ^0.8.20;

import {StorageSlot} from "./StorageSlot.sol";

// | string  | 0xAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA   |
// | length  | 0x                                                              BB |
type ShortString is bytes32;

/**
 * @dev This library provides functions to convert short memory strings
 * into a `ShortString` type that can be used as an immutable variable.
 *
 * Strings of arbitrary length can be optimized using this library if
 * they are short enough (up to 31 bytes) by packing them with their
 * length (1 byte) in a single EVM word (32 bytes). Additionally, a
 * fallback mechanism can be used for every other case.
 *
 * Usage example:
 *
 * ```solidity
 * contract Named {
 *     using ShortStrings for *;
 *
 *     ShortString private immutable _name;
 *     string private _nameFallback;
 *
 *     constructor(string memory contractName) {
 *         _name = contractName.toShortStringWithFallback(_nameFallback);
 *     }
 *
 *     function name() external view returns (string memory) {
 *         return _name.toStringWithFallback(_nameFallback);
 *     }
 * }
 * ```
 */
library ShortStrings {
    // Used as an identifier for strings longer than 31 bytes.
    bytes32 private constant FALLBACK_SENTINEL = 0x00000000000000000000000000000000000000000000000000000000000000FF;

    error StringTooLong(string str);
    error InvalidShortString();

    /**
     * @dev Encode a string of at most 31 chars into a `ShortString`.
     *
     * This will trigger a `StringTooLong` error is the input string is too long.
     */
    function toShortString(string memory str) internal pure returns (ShortString) {
        bytes memory bstr = bytes(str);
        if (bstr.length > 31) {
            revert StringTooLong(str);
        }
        return ShortString.wrap(bytes32(uint256(bytes32(bstr)) | bstr.length));
    }

    /**
     * @dev Decode a `ShortString` back to a "normal" string.
     */
    function toString(ShortString sstr) internal pure returns (string memory) {
        uint256 len = byteLength(sstr);
        // using `new string(len)` would work locally but is not memory safe.
        string memory str = new string(32);
        /// @solidity memory-safe-assembly
        assembly {
            mstore(str, len)
            mstore(add(str, 0x20), sstr)
        }
        return str;
    }

    /**
     * @dev Return the length of a `ShortString`.
     */
    function byteLength(ShortString sstr) internal pure returns (uint256) {
        uint256 result = uint256(ShortString.unwrap(sstr)) & 0xFF;
        if (result > 31) {
            revert InvalidShortString();
        }
        return result;
    }

    /**
     * @dev Encode a string into a `ShortString`, or write it to storage if it is too long.
     */
    function toShortStringWithFallback(string memory value, string storage store) internal returns (ShortString) {
        if (bytes(value).length < 32) {
            return toShortString(value);
        } else {
            StorageSlot.getStringSlot(store).value = value;
            return ShortString.wrap(FALLBACK_SENTINEL);
        }
    }

    /**
     * @dev Decode a string that was encoded to `ShortString` or written to storage using {setWithFallback}.
     */
    function toStringWithFallback(ShortString value, string storage store) internal pure returns (string memory) {
        if (ShortString.unwrap(value) != FALLBACK_SENTINEL) {
            return toString(value);
        } else {
            return store;
        }
    }

    /**
     * @dev Return the length of a string that was encoded to `ShortString` or written to storage using
     * {setWithFallback}.
     *
     * WARNING: This will return the "byte length" of the string. This may not reflect the actual length in terms of
     * actual characters as the UTF-8 encoding of a single character can span over multiple bytes.
     */
    function byteLengthWithFallback(ShortString value, string storage store) internal view returns (uint256) {
        if (ShortString.unwrap(value) != FALLBACK_SENTINEL) {
            return byteLength(value);
        } else {
            return bytes(store).length;
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/StorageSlot.sol)
// This file was procedurally generated from scripts/generate/templates/StorageSlot.js.

pragma solidity ^0.8.20;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```solidity
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(newImplementation.code.length > 0);
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 */
library StorageSlot {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    struct StringSlot {
        string value;
    }

    struct BytesSlot {
        bytes value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `StringSlot` with member `value` located at `slot`.
     */
    function getStringSlot(bytes32 slot) internal pure returns (StringSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `StringSlot` representation of the string storage pointer `store`.
     */
    function getStringSlot(string storage store) internal pure returns (StringSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := store.slot
        }
    }

    /**
     * @dev Returns an `BytesSlot` with member `value` located at `slot`.
     */
    function getBytesSlot(bytes32 slot) internal pure returns (BytesSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BytesSlot` representation of the bytes storage pointer `store`.
     */
    function getBytesSlot(bytes storage store) internal pure returns (BytesSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := store.slot
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
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
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
     * @dev Returns true if the two strings are equal.
     */
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return bytes(a).length == bytes(b).length && keccak256(bytes(a)) == keccak256(bytes(b));
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.20;

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS
    }

    /**
     * @dev The signature derives the `address(0)`.
     */
    error ECDSAInvalidSignature();

    /**
     * @dev The signature has an invalid length.
     */
    error ECDSAInvalidSignatureLength(uint256 length);

    /**
     * @dev The signature has an S value that is in the upper half order.
     */
    error ECDSAInvalidSignatureS(bytes32 s);

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with `signature` or an error. This will not
     * return address(0) without also returning an error description. Errors are documented using an enum (error type)
     * and a bytes32 providing additional information about the error.
     *
     * If no error is returned, then the address can be used for verification purposes.
     *
     * The `ecrecover` EVM precompile allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {MessageHashUtils-toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError, bytes32) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength, bytes32(signature.length));
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM precompile allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {MessageHashUtils-toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, signature);
        _throwError(error, errorArg);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     */
    function tryRecover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address, RecoverError, bytes32) {
        unchecked {
            bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
            // We do not check for an overflow here since the shift operation results in 0 or 1.
            uint8 v = uint8((uint256(vs) >> 255) + 27);
            return tryRecover(hash, v, r, s);
        }
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     */
    function recover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address) {
        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, r, vs);
        _throwError(error, errorArg);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError, bytes32) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS, s);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature, bytes32(0));
        }

        return (signer, RecoverError.NoError, bytes32(0));
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, v, r, s);
        _throwError(error, errorArg);
        return recovered;
    }

    /**
     * @dev Optionally reverts with the corresponding custom error according to the `error` argument provided.
     */
    function _throwError(RecoverError error, bytes32 errorArg) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert ECDSAInvalidSignature();
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert ECDSAInvalidSignatureLength(uint256(errorArg));
        } else if (error == RecoverError.InvalidSignatureS) {
            revert ECDSAInvalidSignatureS(errorArg);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/cryptography/EIP712.sol)

pragma solidity ^0.8.20;

import {MessageHashUtils} from "./MessageHashUtils.sol";
import {ShortStrings, ShortString} from "../ShortStrings.sol";
import {IERC5267} from "../../interfaces/IERC5267.sol";

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding scheme specified in the EIP requires a domain separator and a hash of the typed structured data, whose
 * encoding is very generic and therefore its implementation in Solidity is not feasible, thus this contract
 * does not implement the encoding itself. Protocols need to implement the type-specific encoding they need in order to
 * produce the hash of their typed data using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * NOTE: In the upgradeable version of this contract, the cached values will correspond to the address, and the domain
 * separator of the implementation contract. This will cause the {_domainSeparatorV4} function to always rebuild the
 * separator from the immutable values, which is cheaper than accessing a cached version in cold storage.
 *
 * @custom:oz-upgrades-unsafe-allow state-variable-immutable
 */
abstract contract EIP712 is IERC5267 {
    using ShortStrings for *;

    bytes32 private constant TYPE_HASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to
    // invalidate the cached domain separator if the chain id changes.
    bytes32 private immutable _cachedDomainSeparator;
    uint256 private immutable _cachedChainId;
    address private immutable _cachedThis;

    bytes32 private immutable _hashedName;
    bytes32 private immutable _hashedVersion;

    ShortString private immutable _name;
    ShortString private immutable _version;
    string private _nameFallback;
    string private _versionFallback;

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     *
     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
     * contract upgrade].
     */
    constructor(string memory name, string memory version) {
        _name = name.toShortStringWithFallback(_nameFallback);
        _version = version.toShortStringWithFallback(_versionFallback);
        _hashedName = keccak256(bytes(name));
        _hashedVersion = keccak256(bytes(version));

        _cachedChainId = block.chainid;
        _cachedDomainSeparator = _buildDomainSeparator();
        _cachedThis = address(this);
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        if (address(this) == _cachedThis && block.chainid == _cachedChainId) {
            return _cachedDomainSeparator;
        } else {
            return _buildDomainSeparator();
        }
    }

    function _buildDomainSeparator() private view returns (bytes32) {
        return keccak256(abi.encode(TYPE_HASH, _hashedName, _hashedVersion, block.chainid, address(this)));
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return MessageHashUtils.toTypedDataHash(_domainSeparatorV4(), structHash);
    }

    /**
     * @dev See {IERC-5267}.
     */
    function eip712Domain()
        public
        view
        virtual
        returns (
            bytes1 fields,
            string memory name,
            string memory version,
            uint256 chainId,
            address verifyingContract,
            bytes32 salt,
            uint256[] memory extensions
        )
    {
        return (
            hex"0f", // 01111
            _EIP712Name(),
            _EIP712Version(),
            block.chainid,
            address(this),
            bytes32(0),
            new uint256[](0)
        );
    }

    /**
     * @dev The name parameter for the EIP712 domain.
     *
     * NOTE: By default this function reads _name which is an immutable value.
     * It only reads from storage if necessary (in case the value is too large to fit in a ShortString).
     */
    // solhint-disable-next-line func-name-mixedcase
    function _EIP712Name() internal view returns (string memory) {
        return _name.toStringWithFallback(_nameFallback);
    }

    /**
     * @dev The version parameter for the EIP712 domain.
     *
     * NOTE: By default this function reads _version which is an immutable value.
     * It only reads from storage if necessary (in case the value is too large to fit in a ShortString).
     */
    // solhint-disable-next-line func-name-mixedcase
    function _EIP712Version() internal view returns (string memory) {
        return _version.toStringWithFallback(_versionFallback);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/cryptography/MessageHashUtils.sol)

pragma solidity ^0.8.20;

import {Strings} from "../Strings.sol";

/**
 * @dev Signature message hash utilities for producing digests to be consumed by {ECDSA} recovery or signing.
 *
 * The library provides methods for generating a hash of a message that conforms to the
 * https://eips.ethereum.org/EIPS/eip-191[EIP 191] and https://eips.ethereum.org/EIPS/eip-712[EIP 712]
 * specifications.
 */
library MessageHashUtils {
    /**
     * @dev Returns the keccak256 digest of an EIP-191 signed data with version
     * `0x45` (`personal_sign` messages).
     *
     * The digest is calculated by prefixing a bytes32 `messageHash` with
     * `"\x19Ethereum Signed Message:\n32"` and hashing the result. It corresponds with the
     * hash signed when using the https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`] JSON-RPC method.
     *
     * NOTE: The `messageHash` parameter is intended to be the result of hashing a raw message with
     * keccak256, although any bytes32 value can be safely used because the final digest will
     * be re-hashed.
     *
     * See {ECDSA-recover}.
     */
    function toEthSignedMessageHash(bytes32 messageHash) internal pure returns (bytes32 digest) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, "\x19Ethereum Signed Message:\n32") // 32 is the bytes-length of messageHash
            mstore(0x1c, messageHash) // 0x1c (28) is the length of the prefix
            digest := keccak256(0x00, 0x3c) // 0x3c is the length of the prefix (0x1c) + messageHash (0x20)
        }
    }

    /**
     * @dev Returns the keccak256 digest of an EIP-191 signed data with version
     * `0x45` (`personal_sign` messages).
     *
     * The digest is calculated by prefixing an arbitrary `message` with
     * `"\x19Ethereum Signed Message:\n" + len(message)` and hashing the result. It corresponds with the
     * hash signed when using the https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`] JSON-RPC method.
     *
     * See {ECDSA-recover}.
     */
    function toEthSignedMessageHash(bytes memory message) internal pure returns (bytes32) {
        return
            keccak256(bytes.concat("\x19Ethereum Signed Message:\n", bytes(Strings.toString(message.length)), message));
    }

    /**
     * @dev Returns the keccak256 digest of an EIP-191 signed data with version
     * `0x00` (data with intended validator).
     *
     * The digest is calculated by prefixing an arbitrary `data` with `"\x19\x00"` and the intended
     * `validator` address. Then hashing the result.
     *
     * See {ECDSA-recover}.
     */
    function toDataWithIntendedValidatorHash(address validator, bytes memory data) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(hex"19_00", validator, data));
    }

    /**
     * @dev Returns the keccak256 digest of an EIP-712 typed data (EIP-191 version `0x01`).
     *
     * The digest is calculated from a `domainSeparator` and a `structHash`, by prefixing them with
     * `\x19\x01` and hashing the result. It corresponds to the hash signed by the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`] JSON-RPC method as part of EIP-712.
     *
     * See {ECDSA-recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32 digest) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, hex"19_01")
            mstore(add(ptr, 0x02), domainSeparator)
            mstore(add(ptr, 0x22), structHash)
            digest := keccak256(ptr, 0x42)
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/Math.sol)

pragma solidity ^0.8.20;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Muldiv operation overflow.
     */
    error MathOverflowedMulDiv();

    enum Rounding {
        Floor, // Toward negative infinity
        Ceil, // Toward positive infinity
        Trunc, // Toward zero
        Expand // Away from zero
    }

    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
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
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
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
     * This differs from standard division with `/` in that it rounds towards infinity instead
     * of rounding towards zero.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b == 0) {
            // Guarantee the same behavior as in a regular Solidity division.
            return a / b;
        }

        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or
     * denominator == 0.
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv) with further edits by
     * Uniswap Labs also under MIT license.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
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

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            if (denominator <= prod1) {
                revert MathOverflowedMulDiv();
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

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also
            // works in modular arithmetic, doubling the correct bits in each step.
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
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (unsignedRoundsUp(rounding) && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded
     * towards zero.
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
            return result + (unsignedRoundsUp(rounding) && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2 of a positive value rounded towards zero.
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
            return result + (unsignedRoundsUp(rounding) && 1 << result < value ? 1 : 0);
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
            return result + (unsignedRoundsUp(rounding) && 10 ** result < value ? 1 : 0);
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
     * @dev Return the log in base 256, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (unsignedRoundsUp(rounding) && 1 << (result << 3) < value ? 1 : 0);
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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/SignedMath.sol)

pragma solidity ^0.8.20;

/**
 * @dev Standard signed math utilities missing in the Solidity language.
 */
library SignedMath {
    /**
     * @dev Returns the largest of two signed numbers.
     */
    function max(int256 a, int256 b) internal pure returns (int256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two signed numbers.
     */
    function min(int256 a, int256 b) internal pure returns (int256) {
        return a < b ? a : b;
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
            // must be unchecked in order to support `n = type(int256).min`
            return uint256(n >= 0 ? n : -n);
        }
    }
}
/* -*- c-basic-offset: 4 -*- */
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {OnchainCrossChainOrder, ResolvedCrossChainOrder, GaslessCrossChainOrder, Output, FillInstruction} from "./types/ERC7683.sol";
import {IOriginSettler} from "./interfaces/ERC7683/IOriginSettler.sol";
import {IDestinationSettler} from "./interfaces/ERC7683/IDestinationSettler.sol";
import {Intent, Reward, Route, TokenAmount} from "./types/Intent.sol";
import {OnchainCrosschainOrderData} from "./types/EcoERC7683.sol";
import {IntentSource} from "./IntentSource.sol";
import {Inbox} from "./Inbox.sol";
import {IProver} from "./interfaces/IProver.sol";
import {Semver} from "./libs/Semver.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
contract Eco7683DestinationSettler is IDestinationSettler, Semver {
    using ECDSA for bytes32;

    uint256 constant MAX_UINT256 =
        uint256(
            0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
        );

    /**
     * @notice Emitted when an intent is fulfilled using Hyperlane instant proving
     * @param _orderId Hash of the fulfilled intent
     * @param _solver Address that fulfilled intent
     */
    event orderFilled(bytes32 _orderId, address _solver);

    // address of local hyperlane mailbox
    error BadProver();

    constructor() Semver() {}

    /**
     * @notice Fills a single leg of a particular order on the destination chain
     * @dev _originData is of type OnchainCrossChainOrder
     * @dev _fillerData is encoded bytes consisting of the uint256 prover type and the address claimant if the prover type is Storage (0)
     * and the address claimant, the address postDispatchHook, and the bytes metadata if the prover type is Hyperlane (1)
     * @param _orderId Unique order identifier for this order
     * @param _originData Data emitted on the origin to parameterize the fill
     * @param _fillerData Data provided by the filler to inform the fill or express their preferences
     */
    function fill(
        bytes32 _orderId,
        bytes calldata _originData,
        bytes calldata _fillerData
    ) external payable {
        OnchainCrossChainOrder memory order = abi.decode(
            _originData,
            (OnchainCrossChainOrder)
        );
        OnchainCrosschainOrderData memory onchainCrosschainOrderData = abi
            .decode(order.orderData, (OnchainCrosschainOrderData));
        Intent memory intent = Intent(
            onchainCrosschainOrderData.route,
            Reward(
                onchainCrosschainOrderData.creator,
                onchainCrosschainOrderData.prover,
                order.fillDeadline,
                onchainCrosschainOrderData.nativeValue,
                onchainCrosschainOrderData.rewardTokens
            )
        );
        bytes32 rewardHash = keccak256(abi.encode(intent.reward));
        Inbox inbox = Inbox(payable(intent.route.inbox));
        IProver.ProofType proofType = abi.decode(
            _fillerData,
            (IProver.ProofType)
        );
        doApprovals(address(inbox), intent.route.tokens);
        if (proofType == IProver.ProofType.Storage) {
            (, address claimant) = abi.decode(
                _fillerData,
                (IProver.ProofType, address)
            );
            inbox.fulfillStorage{value: msg.value}(
                intent.route,
                rewardHash,
                claimant,
                _orderId
            );
        } else if (proofType == IProver.ProofType.Hyperlane) {
            (
                ,
                address claimant,
                address postDispatchHook,
                bytes memory metadata
            ) = abi.decode(
                    _fillerData,
                    (IProver.ProofType, address, address, bytes)
                );
            inbox.fulfillHyperInstantWithRelayer{value: msg.value}(
                intent.route,
                rewardHash,
                claimant,
                _orderId,
                onchainCrosschainOrderData.prover,
                metadata,
                postDispatchHook
            );
        } else {
            revert BadProver();
        }
    }

    function doApprovals(
        address _inbox,
        TokenAmount[] memory _tokens
    ) internal {
        for (uint256 i = 0; i < _tokens.length; i++) {
            IERC20 token = IERC20(_tokens[i].token);
            if (token.allowance(address(this), _inbox) < MAX_UINT256) {
                token.approve(_inbox, MAX_UINT256);
            }
        }
    }

    receive() external payable {}
}
/* -*- c-basic-offset: 4 -*- */
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {OnchainCrossChainOrder, ResolvedCrossChainOrder, GaslessCrossChainOrder, Output, FillInstruction} from "./types/ERC7683.sol";
import {IOriginSettler} from "./interfaces/ERC7683/IOriginSettler.sol";
import {Intent, Reward, Route, Call, TokenAmount} from "./types/Intent.sol";
import {OnchainCrosschainOrderData, GaslessCrosschainOrderData} from "./types/EcoERC7683.sol";
import {IntentSource} from "./IntentSource.sol";
import {Semver} from "./libs/Semver.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title Eco7683OriginSettler
 * @notice Entry point to Eco Protocol via EIP-7683
 * @dev functionality is somewhat limited compared to interacting with Eco Protocol directly
 */
contract Eco7683OriginSettler is IOriginSettler, Semver, EIP712 {
    using ECDSA for bytes32;
    using SafeERC20 for IERC20;

    /// @notice typehash for gasless crosschain _order
    bytes32 public GASLESS_CROSSCHAIN_ORDER_TYPEHASH =
        keccak256(
            "GaslessCrossChainOrder(address originSettler,address user,uint256 nonce,uint256 originChainId,uint32 openDeadline,uint32 fillDeadline,bytes32 orderDataType,bytes32 orderDataHash)"
        );

    /// @notice address of IntentSource contract where intents are actually published
    address public immutable INTENT_SOURCE;

    /**
     * @notice Initializes the Eco7683OriginSettler
     * @param _name the name of the contract for EIP712
     * @param _version the version of the contract for EIP712
     * @param _intentSource the address of the IntentSource contract
     */
    constructor(
        string memory _name,
        string memory _version,
        address _intentSource
    ) EIP712(_name, _version) {
        INTENT_SOURCE = _intentSource;
    }

    /**
     * @notice opens an Eco intent directly on chaim
     * @dev to be called by the user
     * @dev assumes user has erc20 funds approved for the intent, and includes any reward native token in msg.value
     * @dev transfers the reward tokens at time of open
     * @param _order the OnchainCrossChainOrder that will be opened as an eco intent
     */
    function open(
        OnchainCrossChainOrder calldata _order
    ) external payable override {
        OnchainCrosschainOrderData memory onchainCrosschainOrderData = abi
            .decode(_order.orderData, (OnchainCrosschainOrderData));

        if (onchainCrosschainOrderData.route.source != block.chainid) {
            revert OriginChainIDMismatch();
        }

        Intent memory intent = Intent(
            onchainCrosschainOrderData.route,
            Reward(
                onchainCrosschainOrderData.creator,
                onchainCrosschainOrderData.prover,
                _order.fillDeadline,
                onchainCrosschainOrderData.nativeValue,
                onchainCrosschainOrderData.rewardTokens
            )
        );

        bytes32 orderId = _openEcoIntent(intent, msg.sender);

        emit Open(orderId, resolve(_order));
    }

    /**
     * @notice opens an Eco intent directly on chain for a user
     * @dev to be called by the user
     * @dev assumes user has erc20 funds approved for the intent, and includes any reward native token in msg.value
     * @dev transfers the reward tokens at time of open
     * @param _order the OnchainCrossChainOrder that will be opened as an eco intent
     */
    function openFor(
        GaslessCrossChainOrder calldata _order,
        bytes calldata _signature,
        bytes calldata _originFillerData
    ) external payable override {
        if (!_verifyOpenFor(_order, _signature)) {
            revert BadSignature();
        }
        GaslessCrosschainOrderData memory gaslessCrosschainOrderData = abi
            .decode(_order.orderData, (GaslessCrosschainOrderData));
        if (_order.originChainId != block.chainid) {
            revert OriginChainIDMismatch();
        }
        Intent memory intent = Intent(
            Route(
                bytes32(_order.nonce),
                _order.originChainId,
                gaslessCrosschainOrderData.destination,
                gaslessCrosschainOrderData.inbox,
                gaslessCrosschainOrderData.routeTokens,
                gaslessCrosschainOrderData.calls
            ),
            Reward(
                _order.user,
                gaslessCrosschainOrderData.prover,
                _order.fillDeadline,
                gaslessCrosschainOrderData.nativeValue,
                gaslessCrosschainOrderData.rewardTokens
            )
        );

        bytes32 orderId = _openEcoIntent(intent, _order.user);

        emit Open(orderId, resolveFor(_order, _originFillerData));
    }

    /**
     * @notice resolves an OnchainCrossChainOrder to a ResolvedCrossChainOrder
     * @param _order the OnchainCrossChainOrder to be resolved
     */
    function resolve(
        OnchainCrossChainOrder calldata _order
    ) public view override returns (ResolvedCrossChainOrder memory) {
        OnchainCrosschainOrderData memory onchainCrosschainOrderData = abi
            .decode(_order.orderData, (OnchainCrosschainOrderData));
        uint256 routeTokenCount = onchainCrosschainOrderData
            .route
            .tokens
            .length;
        Output[] memory maxSpent = new Output[](routeTokenCount);
        for (uint256 i = 0; i < routeTokenCount; ++i) {
            TokenAmount memory approval = onchainCrosschainOrderData
                .route
                .tokens[i];
            maxSpent[i] = Output(
                bytes32(bytes20(uint160(approval.token))),
                approval.amount,
                bytes32(bytes20(uint160(address(0)))), //filler is not known
                onchainCrosschainOrderData.route.destination
            );
        }
        uint256 rewardTokenCount = onchainCrosschainOrderData
            .rewardTokens
            .length;
        Output[] memory minReceived = new Output[](
            rewardTokenCount +
                (onchainCrosschainOrderData.nativeValue > 0 ? 1 : 0)
        ); //rewards are fixed

        for (uint256 i = 0; i < rewardTokenCount; ++i) {
            minReceived[i] = Output(
                bytes32(
                    bytes20(
                        uint160(
                            onchainCrosschainOrderData.rewardTokens[i].token
                        )
                    )
                ),
                onchainCrosschainOrderData.rewardTokens[i].amount,
                bytes32(bytes20(uint160(address(0)))), //filler is not known
                onchainCrosschainOrderData.route.destination
            );
        }
        if (onchainCrosschainOrderData.nativeValue > 0) {
            minReceived[rewardTokenCount] = Output(
                bytes32(bytes20(uint160(address(0)))),
                onchainCrosschainOrderData.nativeValue,
                bytes32(bytes20(uint160(address(0)))),
                onchainCrosschainOrderData.route.destination
            );
        }

        uint256 callCount = onchainCrosschainOrderData.route.calls.length;
        FillInstruction[] memory fillInstructions = new FillInstruction[](
            callCount
        );

        for (uint256 j = 0; j < callCount; j++) {
            fillInstructions[j] = FillInstruction(
                uint64(onchainCrosschainOrderData.route.destination),
                bytes32(
                    bytes20(uint160(onchainCrosschainOrderData.route.inbox))
                ),
                abi.encode(onchainCrosschainOrderData.route.calls[j])
            );
        }

        (bytes32 intentHash, , ) = IntentSource(INTENT_SOURCE).getIntentHash(
            Intent(
                onchainCrosschainOrderData.route,
                Reward(
                    onchainCrosschainOrderData.creator,
                    onchainCrosschainOrderData.prover,
                    _order.fillDeadline,
                    onchainCrosschainOrderData.nativeValue,
                    onchainCrosschainOrderData.rewardTokens
                )
            )
        );
        return
            ResolvedCrossChainOrder(
                onchainCrosschainOrderData.creator,
                onchainCrosschainOrderData.route.source,
                _order.fillDeadline,
                _order.fillDeadline,
                intentHash,
                maxSpent,
                minReceived,
                fillInstructions
            );
    }

    /**
     * @notice resolves GaslessCrossChainOrder to a ResolvedCrossChainOrder
     * @param _order the GaslessCrossChainOrder to be resolved
     * @param _originFillerData filler data for the origin chain (not used)
     */
    function resolveFor(
        GaslessCrossChainOrder calldata _order,
        bytes calldata _originFillerData // i dont think we need this, keeping it for purpose of interface
    ) public view override returns (ResolvedCrossChainOrder memory) {
        GaslessCrosschainOrderData memory gaslessCrosschainOrderData = abi
            .decode(_order.orderData, (GaslessCrosschainOrderData));
        uint256 routeTokenCount = gaslessCrosschainOrderData.routeTokens.length;
        Output[] memory maxSpent = new Output[](routeTokenCount);
        for (uint256 i = 0; i < routeTokenCount; ++i) {
            TokenAmount memory requirement = gaslessCrosschainOrderData
                .routeTokens[i];
            maxSpent[i] = Output(
                bytes32(bytes20(uint160(requirement.token))),
                requirement.amount,
                bytes32(bytes20(uint160(address(0)))), //filler is not known
                gaslessCrosschainOrderData.destination
            );
        }
        uint256 rewardTokenCount = gaslessCrosschainOrderData
            .rewardTokens
            .length;
        Output[] memory minReceived = new Output[](
            rewardTokenCount +
                (gaslessCrosschainOrderData.nativeValue > 0 ? 1 : 0)
        ); //rewards are fixed

        for (uint256 i = 0; i < rewardTokenCount; ++i) {
            minReceived[i] = Output(
                bytes32(
                    bytes20(
                        uint160(
                            gaslessCrosschainOrderData.rewardTokens[i].token
                        )
                    )
                ),
                gaslessCrosschainOrderData.rewardTokens[i].amount,
                bytes32(bytes20(uint160(address(0)))), //filler is not known
                gaslessCrosschainOrderData.destination
            );
        }
        if (gaslessCrosschainOrderData.nativeValue > 0) {
            minReceived[rewardTokenCount] = Output(
                bytes32(bytes20(uint160(address(0)))),
                gaslessCrosschainOrderData.nativeValue,
                bytes32(bytes20(uint160(address(0)))),
                gaslessCrosschainOrderData.destination
            );
        }

        uint256 callCount = gaslessCrosschainOrderData.calls.length;
        FillInstruction[] memory fillInstructions = new FillInstruction[](
            callCount
        );

        for (uint256 j = 0; j < callCount; j++) {
            fillInstructions[j] = FillInstruction(
                uint64(gaslessCrosschainOrderData.destination),
                bytes32(bytes20(uint160(gaslessCrosschainOrderData.inbox))),
                abi.encode(gaslessCrosschainOrderData.calls[j])
            );
        }

        (bytes32 intentHash, , ) = IntentSource(INTENT_SOURCE).getIntentHash(
            Intent(
                Route(
                    bytes32(_order.nonce),
                    _order.originChainId,
                    gaslessCrosschainOrderData.destination,
                    gaslessCrosschainOrderData.inbox,
                    gaslessCrosschainOrderData.routeTokens,
                    gaslessCrosschainOrderData.calls
                ),
                Reward(
                    _order.user,
                    gaslessCrosschainOrderData.prover,
                    _order.fillDeadline,
                    gaslessCrosschainOrderData.nativeValue,
                    gaslessCrosschainOrderData.rewardTokens
                )
            )
        );
        return
            ResolvedCrossChainOrder(
                _order.user,
                _order.originChainId,
                _order.fillDeadline, // we do not use opendeadline
                _order.fillDeadline,
                intentHash,
                maxSpent,
                minReceived,
                fillInstructions
            );
    }

    /// @notice helper method for signature verification
    function _verifyOpenFor(
        GaslessCrossChainOrder calldata _order,
        bytes calldata _signature
    ) internal view returns (bool) {
        if (_order.originSettler != address(this)) {
            return false;
        }
        bytes32 structHash = keccak256(
            abi.encode(
                GASLESS_CROSSCHAIN_ORDER_TYPEHASH,
                _order.originSettler,
                _order.user,
                _order.nonce,
                _order.originChainId,
                _order.openDeadline,
                _order.fillDeadline,
                _order.orderDataType,
                keccak256(_order.orderData)
            )
        );

        bytes32 hash = _hashTypedDataV4(structHash);
        address signer = hash.recover(_signature);

        return signer == _order.user;
    }

    /// @notice helper method that actually opens the intent
    function _openEcoIntent(
        Intent memory _intent,
        address _user
    ) internal returns (bytes32 intentHash) {
        address vault = IntentSource(INTENT_SOURCE).intentVaultAddress(_intent);

        if (_intent.reward.nativeValue > 0) {
            if (msg.value < _intent.reward.nativeValue) {
                revert InsufficientNativeReward();
            }

            payable(vault).transfer(_intent.reward.nativeValue);

            if (msg.value > _intent.reward.nativeValue) {
                payable(msg.sender).transfer(
                    msg.value - _intent.reward.nativeValue
                );
            }
        }
        uint256 rewardsLength = _intent.reward.tokens.length;
        for (uint256 i = 0; i < rewardsLength; ++i) {
            address token = _intent.reward.tokens[i].token;
            uint256 amount = _intent.reward.tokens[i].amount;

            IERC20(token).safeTransferFrom(_user, vault, amount);
        }
        return IntentSource(INTENT_SOURCE).publishIntent(_intent, false);
    }

    /// @notice EIP712 domain separator
    function domainSeparatorV4() public view returns (bytes32) {
        return _domainSeparatorV4();
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IMailbox, IPostDispatchHook} from "@hyperlane-xyz/core/contracts/interfaces/IMailbox.sol";
import {TypeCasts} from "@hyperlane-xyz/core/contracts/libs/TypeCasts.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {IInbox} from "./interfaces/IInbox.sol";
import {Intent, Route, Call, TokenAmount} from "./types/Intent.sol";
import {Semver} from "./libs/Semver.sol";

/**
 * @title Inbox
 * @notice Main entry point for fulfilling intents
 * @dev Validates intent hash authenticity and executes calldata. Enables provers
 * to claim rewards on the source chain by checking the fulfilled mapping
 */
contract Inbox is IInbox, Ownable, Semver {
    using TypeCasts for address;
    using SafeERC20 for IERC20;

    // Mapping of intent hash on the src chain to its fulfillment
    mapping(bytes32 => address) public fulfilled;

    // Mapping of solvers to if they are whitelisted
    mapping(address => bool) public solverWhitelist;

    // address of local hyperlane mailbox
    address public mailbox;

    // Is solving public
    bool public isSolvingPublic;

    /**
     * @notice Initializes the Inbox contract
     * @dev Privileged functions are designed to only allow one-time changes
     * @param _owner Address with access to privileged functions
     * @param _isSolvingPublic Whether solving is public at start
     * @param _solvers Initial whitelist of solvers (only relevant if solving is not public)
     */
    constructor(
        address _owner,
        bool _isSolvingPublic,
        address[] memory _solvers
    ) Ownable(_owner) {
        isSolvingPublic = _isSolvingPublic;
        for (uint256 i = 0; i < _solvers.length; ++i) {
            solverWhitelist[_solvers[i]] = true;
            emit SolverWhitelistChanged(_solvers[i], true);
        }
    }

    /**
     * @notice Fulfills an intent to be proven via storage proofs
     * @param _route The route of the intent
     * @param _rewardHash The hash of the reward
     * @param _claimant The address that will receive the reward on the source chain
     * @param _expectedHash The hash of the intent as created on the source chain
     * @return Array of execution results from each call
     */
    function fulfillStorage(
        Route calldata _route,
        bytes32 _rewardHash,
        address _claimant,
        bytes32 _expectedHash
    ) external payable returns (bytes[] memory) {
        bytes[] memory result = _fulfill(
            _route,
            _rewardHash,
            _claimant,
            _expectedHash
        );

        emit ToBeProven(_expectedHash, _route.source, _claimant);

        return result;
    }

    /**
     * @notice Fulfills an intent to be proven immediately via Hyperlane's mailbox
     * @dev More expensive but faster than hyperbatched. Requires fee for Hyperlane infrastructure
     * @param _route The route of the intent
     * @param _rewardHash The hash of the reward
     * @param _claimant The address that will receive the reward on the source chain
     * @param _expectedHash The hash of the intent as created on the source chain
     * @param _prover The address of the hyperprover on the source chain
     * @return Array of execution results from each call
     */
    function fulfillHyperInstant(
        Route calldata _route,
        bytes32 _rewardHash,
        address _claimant,
        bytes32 _expectedHash,
        address _prover
    ) external payable returns (bytes[] memory) {
        return
            fulfillHyperInstantWithRelayer(
                _route,
                _rewardHash,
                _claimant,
                _expectedHash,
                _prover,
                bytes(""),
                address(0)
            );
    }

    /**
     * @notice Fulfills an intent to be proven immediately via Hyperlane's mailbox with relayer support
     * @dev More expensive but faster than hyperbatched. Requires fee for Hyperlane infrastructure
     * @param _route The route of the intent
     * @param _rewardHash The hash of the reward
     * @param _claimant The address that will receive the reward on the source chain
     * @param _expectedHash The hash of the intent as created on the source chain
     * @param _prover The address of the hyperprover on the source chain
     * @param _metadata Metadata for postDispatchHook (empty bytes if not applicable)
     * @param _postDispatchHook Address of postDispatchHook (zero address if not applicable)
     * @return Array of execution results from each call
     */
    function fulfillHyperInstantWithRelayer(
        Route calldata _route,
        bytes32 _rewardHash,
        address _claimant,
        bytes32 _expectedHash,
        address _prover,
        bytes memory _metadata,
        address _postDispatchHook
    ) public payable returns (bytes[] memory) {
        bytes32[] memory hashes = new bytes32[](1);
        address[] memory claimants = new address[](1);
        hashes[0] = _expectedHash;
        claimants[0] = _claimant;

        bytes memory messageBody = abi.encode(hashes, claimants);
        bytes32 _prover32 = _prover.addressToBytes32();

        emit HyperInstantFulfillment(_expectedHash, _route.source, _claimant);

        uint256 fee = fetchFee(
            _route.source,
            _prover32,
            messageBody,
            _metadata,
            _postDispatchHook
        );
        bytes[] memory results = _fulfill(
            _route,
            _rewardHash,
            _claimant,
            _expectedHash
        );

        uint256 currentBalance = address(this).balance;
        if (currentBalance < fee) {
            revert InsufficientFee(fee);
        }
        if (currentBalance > fee) {
            (bool success, ) = payable(msg.sender).call{
                value: currentBalance - fee
            }("");
            if (!success) {
                revert NativeTransferFailed();
            }
        }
        if (_postDispatchHook == address(0)) {
            IMailbox(mailbox).dispatch{value: fee}(
                uint32(_route.source),
                _prover32,
                messageBody
            );
        } else {
            IMailbox(mailbox).dispatch{value: fee}(
                uint32(_route.source),
                _prover32,
                messageBody,
                _metadata,
                IPostDispatchHook(_postDispatchHook)
            );
        }
        return results;
    }

    /**
     * @notice Fulfills an intent to be proven in a batch via Hyperlane's mailbox
     * @dev Less expensive but slower than hyperinstant. Batch dispatched when sendBatch is called.
     * @param _route The route of the intent
     * @param _rewardHash The hash of the reward
     * @param _claimant The address that will receive the reward on the source chain
     * @param _expectedHash The hash of the intent as created on the source chain
     * @param _prover The address of the hyperprover on the source chain
     * @return Array of execution results from each call
     */
    function fulfillHyperBatched(
        Route calldata _route,
        bytes32 _rewardHash,
        address _claimant,
        bytes32 _expectedHash,
        address _prover
    ) external payable returns (bytes[] memory) {
        emit AddToBatch(_expectedHash, _route.source, _claimant, _prover);

        bytes[] memory results = _fulfill(
            _route,
            _rewardHash,
            _claimant,
            _expectedHash
        );

        return results;
    }

    /**
     * @notice Sends a batch of fulfilled intents to the mailbox
     * @dev Intent hashes must correspond to fulfilled intents from specified source chain
     * @param _sourceChainID Chain ID of the source chain
     * @param _prover Address of the hyperprover on the source chain
     * @param _intentHashes Hashes of the intents to be proven
     */
    function sendBatch(
        uint256 _sourceChainID,
        address _prover,
        bytes32[] calldata _intentHashes
    ) external payable {
        sendBatchWithRelayer(
            _sourceChainID,
            _prover,
            _intentHashes,
            bytes(""),
            address(0)
        );
    }

    /**
     * @notice Sends a batch of fulfilled intents to the mailbox with relayer support
     * @dev Intent hashes must correspond to fulfilled intents from specified source chain
     * @param _sourceChainID Chain ID of the source chain
     * @param _prover Address of the hyperprover on the source chain
     * @param _intentHashes Hashes of the intents to be proven
     * @param _metadata Metadata for postDispatchHook
     * @param _postDispatchHook Address of postDispatchHook
     */
    function sendBatchWithRelayer(
        uint256 _sourceChainID,
        address _prover,
        bytes32[] calldata _intentHashes,
        bytes memory _metadata,
        address _postDispatchHook
    ) public payable {
        uint256 size = _intentHashes.length;
        address[] memory claimants = new address[](size);
        for (uint256 i = 0; i < size; ++i) {
            address claimant = fulfilled[_intentHashes[i]];
            if (claimant == address(0)) {
                revert IntentNotFulfilled(_intentHashes[i]);
            }
            claimants[i] = claimant;
        }

        emit BatchSent(_intentHashes, _sourceChainID);

        bytes memory messageBody = abi.encode(_intentHashes, claimants);
        bytes32 _prover32 = _prover.addressToBytes32();
        uint256 fee = fetchFee(
            _sourceChainID,
            _prover32,
            messageBody,
            _metadata,
            _postDispatchHook
        );
        if (msg.value < fee) {
            revert InsufficientFee(fee);
        }
        if (msg.value > fee) {
            (bool success, ) = payable(msg.sender).call{value: msg.value - fee}(
                ""
            );
            if (!success) {
                revert NativeTransferFailed();
            }
        }
        if (_postDispatchHook == address(0)) {
            IMailbox(mailbox).dispatch{value: fee}(
                uint32(_sourceChainID),
                _prover32,
                messageBody
            );
        } else {
            IMailbox(mailbox).dispatch{value: fee}(
                uint32(_sourceChainID),
                _prover32,
                messageBody,
                _metadata,
                IPostDispatchHook(_postDispatchHook)
            );
        }
    }

    /**
     * @notice Quotes the fee required for message dispatch
     * @dev Used to determine fees for fulfillHyperInstant or sendBatch
     * @param _sourceChainID Chain ID of the source chain
     * @param _prover Address of the hyperprover on the source chain
     * @param _messageBody Message being sent over the bridge
     * @param _metadata Metadata for postDispatchHook
     * @param _postDispatchHook Address of postDispatchHook
     * @return fee The required fee amount
     */
    function fetchFee(
        uint256 _sourceChainID,
        bytes32 _prover,
        bytes memory _messageBody,
        bytes memory _metadata,
        address _postDispatchHook
    ) public view returns (uint256 fee) {
        return (
            _postDispatchHook == address(0)
                ? IMailbox(mailbox).quoteDispatch(
                    uint32(_sourceChainID),
                    _prover,
                    _messageBody
                )
                : IMailbox(mailbox).quoteDispatch(
                    uint32(_sourceChainID),
                    _prover,
                    _messageBody,
                    _metadata,
                    IPostDispatchHook(_postDispatchHook)
                )
        );
    }

    /**
     * @notice Sets the mailbox address
     * @dev Can only be called once during deployment
     * @param _mailbox Address of the Hyperlane mailbox
     */
    function setMailbox(address _mailbox) public onlyOwner {
        if (mailbox == address(0)) {
            mailbox = _mailbox;
            emit MailboxSet(_mailbox);
        }
    }

    /**
     * @notice Makes solving public if currently restricted
     * @dev Cannot be reversed once made public
     */
    function makeSolvingPublic() public onlyOwner {
        if (!isSolvingPublic) {
            isSolvingPublic = true;
            emit SolvingIsPublic();
        }
    }

    /**
     * @notice Updates the solver whitelist
     * @dev Whitelist is ignored if solving is public
     * @param _solver Address of the solver
     * @param _canSolve Whether solver should be whitelisted
     */
    function changeSolverWhitelist(
        address _solver,
        bool _canSolve
    ) public onlyOwner {
        solverWhitelist[_solver] = _canSolve;
        emit SolverWhitelistChanged(_solver, _canSolve);
    }

    /**
     * @notice Internal function to fulfill intents
     * @dev Validates intent and executes calls
     * @param _route The route of the intent
     * @param _rewardHash The hash of the reward
     * @param _claimant The reward recipient address
     * @param _expectedHash The expected intent hash
     * @return Array of execution results
     */
    function _fulfill(
        Route calldata _route,
        bytes32 _rewardHash,
        address _claimant,
        bytes32 _expectedHash
    ) internal returns (bytes[] memory) {
        if (!isSolvingPublic && !solverWhitelist[msg.sender]) {
            revert UnauthorizedSolveAttempt(msg.sender);
        }

        bytes32 routeHash = keccak256(abi.encode(_route));
        bytes32 intentHash = keccak256(
            abi.encodePacked(routeHash, _rewardHash)
        );

        if (_route.inbox != address(this)) {
            revert InvalidInbox(_route.inbox);
        }

        if (intentHash != _expectedHash) {
            revert InvalidHash(_expectedHash);
        }
        if (fulfilled[intentHash] != address(0)) {
            revert IntentAlreadyFulfilled(intentHash);
        }
        if (_claimant == address(0)) {
            revert ZeroClaimant();
        }

        fulfilled[intentHash] = _claimant;
        emit Fulfillment(_expectedHash, _route.source, _claimant);

        uint256 routeTokenCount = _route.tokens.length;
        // Transfer ERC20 tokens to the inbox
        for (uint256 i = 0; i < routeTokenCount; ++i) {
            TokenAmount memory approval = _route.tokens[i];
            IERC20(approval.token).safeTransferFrom(
                msg.sender,
                address(this),
                approval.amount
            );
        }

        // Store the results of the calls
        bytes[] memory results = new bytes[](_route.calls.length);

        for (uint256 i = 0; i < _route.calls.length; ++i) {
            Call calldata call = _route.calls[i];
            if (call.target == mailbox) {
                // no executing calls on the mailbox
                revert CallToMailbox();
            }
            (bool success, bytes memory result) = call.target.call{
                value: call.value
            }(call.data);
            if (!success) {
                revert IntentCallFailed(
                    call.target,
                    call.data,
                    call.value,
                    result
                );
            }
            results[i] = result;
        }
        return results;
    }

    receive() external payable {}
}
/* -*- c-basic-offset: 4 -*- */
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {IIntentSource} from "./interfaces/IIntentSource.sol";
import {Reward} from "./types/Intent.sol";

/**
 * @title IntentFunder
 * @notice Handles the funding process for intent rewards by transferring tokens and native currency to vaults
 * @dev This is a single-use contract that is deployed by IntentSource for each funding operation
 * and self-destructs after completing its task. It transfers any approved tokens from the funding
 * source to the vault up to the required amount or available allowance.
 */
contract IntentFunder {
    // Use OpenZeppelin's SafeERC20 for safe token transfers
    using SafeERC20 for IERC20;

    /**
     * @notice Instantiates and executes the funding operation in a single transaction
     * @dev The constructor performs all funding operations and then self-destructs.
     * The contract can only be deployed by IntentSource, which is checked implicitly
     * by accessing msg.sender as the IntentSource contract
     * @param vault The address of the vault that will receive the tokens and native currency
     * @param reward The reward structure containing token amounts and recipient details
     */
    constructor(address vault, Reward memory reward) {
        // Cast msg.sender to IIntentSource since we know it must be the IntentSource contract
        IIntentSource intentSource = IIntentSource(msg.sender);

        // Cache array length to save gas in loop
        uint256 rewardsLength = reward.tokens.length;

        // Get the address that is providing the tokens for funding
        address fundingSource = intentSource.getFundingSource();
        address refundToken = intentSource.getRefundToken();

        if (refundToken != address(0)) {
            IERC20(refundToken).safeTransfer(
                reward.creator,
                IERC20(refundToken).balanceOf(address(this))
            );
        }

        // Iterate through each token in the reward structure
        for (uint256 i; i < rewardsLength; ++i) {
            // Get token address and required amount for current reward
            address token = reward.tokens[i].token;
            uint256 amount = reward.tokens[i].amount;

            // Check how many tokens this contract is allowed to transfer from funding source
            uint256 allowance = IERC20(token).allowance(
                fundingSource,
                address(this)
            );

            // Calculate how many more tokens the vault needs to be fully funded
            // Cast to int256 to handle the case where vault is already overfunded
            int256 balanceDeficit = int256(amount) -
                int256(IERC20(token).balanceOf(vault));

            // Only proceed if vault needs more tokens and we have permission to transfer them
            if (balanceDeficit > 0 && allowance > 0) {
                // Calculate transfer amount as minimum of what's needed and what's allowed
                uint256 transferAmount = allowance > uint256(balanceDeficit)
                    ? uint256(balanceDeficit)
                    : allowance;

                // Transfer tokens from funding source to vault using safe transfer
                IERC20(token).safeTransferFrom(
                    fundingSource,
                    vault,
                    transferAmount
                );
            }
        }

        // After all transfers are complete, self-destruct and send any remaining ETH to reward creator
        selfdestruct(payable(reward.creator));
    }
}
/* -*- c-basic-offset: 4 -*- */
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {IIntentSource} from "./interfaces/IIntentSource.sol";
import {BaseProver} from "./prover/BaseProver.sol";
import {Intent, Route, Reward, Call} from "./types/Intent.sol";
import {Semver} from "./libs/Semver.sol";

import {IntentFunder} from "./IntentFunder.sol";
import {IntentVault} from "./IntentVault.sol";

/**
 * @notice Source chain contract for the Eco Protocol's intent system
 * @dev Used to create intents and withdraw associated rewards. Works in conjunction with
 *      an inbox contract on the destination chain. Verifies intent fulfillment through
 *      a prover contract on the source chain
 * @dev This contract shouldn't not hold any funds or hold ony roles for other contracts,
 *      as it executes arbitrary calls to other contracts when funding intents.
 */
contract IntentSource is IIntentSource, Semver {
    using SafeERC20 for IERC20;

    mapping(bytes32 intentHash => ClaimState) public claims;

    address public fundingSource;

    address public refundToken;

    constructor() {}

    /**
     * @notice Retrieves claim state for a given intent hash
     * @param intentHash Hash of the intent to query
     * @return ClaimState struct containing claim information
     */
    function getClaim(
        bytes32 intentHash
    ) external view returns (ClaimState memory) {
        return claims[intentHash];
    }

    /**
     * @notice Gets the funding source for the intent funder
     * @return Address of the native token funding source
     */
    function getFundingSource() external view returns (address) {
        return fundingSource;
    }

    /**
     * @notice Gets the token used for vault refunds
     * @return Address of the vault refund token
     */
    function getRefundToken() external view returns (address) {
        return refundToken;
    }

    /**
     * @notice Calculates the hash of an intent and its components
     * @param intent The intent to hash
     * @return intentHash Combined hash of route and reward
     * @return routeHash Hash of the route component
     * @return rewardHash Hash of the reward component
     */
    function getIntentHash(
        Intent calldata intent
    )
        public
        pure
        returns (bytes32 intentHash, bytes32 routeHash, bytes32 rewardHash)
    {
        routeHash = keccak256(abi.encode(intent.route));
        rewardHash = keccak256(abi.encode(intent.reward));
        intentHash = keccak256(abi.encodePacked(routeHash, rewardHash));
    }

    /**
     * @notice Calculates the deterministic address of the intent funder
     * @param intent Intent to calculate vault address for
     * @return Address of the intent funder
     */
    function intentFunderAddress(
        Intent calldata intent
    ) external view returns (address) {
        (bytes32 intentHash, bytes32 routeHash, ) = getIntentHash(intent);
        address vault = _getIntentVaultAddress(
            intentHash,
            routeHash,
            intent.reward
        );
        return _getIntentFunderAddress(vault, routeHash, intent.reward);
    }

    /**
     * @notice Calculates the deterministic address of the intent vault
     * @param intent Intent to calculate vault address for
     * @return Address of the intent vault
     */
    function intentVaultAddress(
        Intent calldata intent
    ) external view returns (address) {
        (bytes32 intentHash, bytes32 routeHash, ) = getIntentHash(intent);
        return _getIntentVaultAddress(intentHash, routeHash, intent.reward);
    }

    /**
     * @notice Funds an intent with native tokens and ERC20 tokens
     * @dev Security: this allows to call any contract from the IntentSource,
     *      which can impose a risk if anything relies on IntentSource to be msg.sender
     * @param routeHash Hash of the route component
     * @param reward Reward structure containing distribution details
     * @param fundingAddress Address to fund the intent from
     * @param permitCalls Array of permit calls to approve token transfers
     * @param recoverToken Optional token address for handling incorrect vault transfers
     */
    function fundIntent(
        bytes32 routeHash,
        Reward calldata reward,
        address fundingAddress,
        Call[] calldata permitCalls,
        address recoverToken
    ) external payable {
        bytes32 rewardHash = keccak256(abi.encode(reward));
        bytes32 intentHash = keccak256(abi.encodePacked(routeHash, rewardHash));

        address vault = _getIntentVaultAddress(intentHash, routeHash, reward);

        emit IntentFunded(intentHash, fundingAddress);

        int256 vaultBalanceDeficit = int256(reward.nativeValue) -
            int256(vault.balance);

        if (vaultBalanceDeficit > 0 && msg.value > 0) {
            uint256 nativeAmount = msg.value > uint256(vaultBalanceDeficit)
                ? uint256(vaultBalanceDeficit)
                : msg.value;

            payable(vault).transfer(nativeAmount);

            uint256 currentBalance = address(this).balance;

            if (currentBalance > 0) {
                (bool success, ) = payable(msg.sender).call{
                    value: currentBalance
                }("");

                if (!success) {
                    revert NativeRewardTransferFailed();
                }
            }
        }

        uint256 callsLength = permitCalls.length;

        for (uint256 i = 0; i < callsLength; ++i) {
            Call calldata call = permitCalls[i];

            (bool success, ) = call.target.call(call.data);

            if (!success) {
                revert PermitCallFailed();
            }
        }

        fundingSource = fundingAddress;

        if (recoverToken != address(0)) {
            refundToken = recoverToken;
        }

        new IntentFunder{salt: routeHash}(vault, reward);

        fundingSource = address(0);

        if (recoverToken != address(0)) {
            refundToken = address(0);
        }
    }

    /**
     * @notice Creates an intent to execute instructions on a supported chain in exchange for assets
     * @dev If source chain proof isn't completed by expiry, rewards aren't redeemable regardless of execution.
     *      Solver must manage timing considerations (e.g., L1 data posting delays)
     * @param intent The intent struct containing all parameters
     * @param fund Whether to fund the reward or not
     * @return intentHash The hash of the created intent
     */
    function publishIntent(
        Intent calldata intent,
        bool fund
    ) external payable returns (bytes32 intentHash) {
        Route calldata route = intent.route;
        Reward calldata reward = intent.reward;

        uint256 rewardsLength = reward.tokens.length;
        bytes32 routeHash;

        (intentHash, routeHash, ) = getIntentHash(intent);

        if (claims[intentHash].status != uint8(ClaimStatus.Initiated)) {
            revert IntentAlreadyExists(intentHash);
        }

        emit IntentCreated(
            intentHash,
            route.salt,
            route.source,
            route.destination,
            route.inbox,
            route.tokens,
            route.calls,
            reward.creator,
            reward.prover,
            reward.deadline,
            reward.nativeValue,
            reward.tokens
        );

        address vault = _getIntentVaultAddress(intentHash, routeHash, reward);

        if (fund && !_isIntentFunded(intent, vault)) {
            if (reward.nativeValue > 0) {
                if (msg.value < reward.nativeValue) {
                    revert InsufficientNativeReward();
                }

                payable(vault).transfer(reward.nativeValue);

                uint256 currentBalance = address(this).balance;

                if (currentBalance > 0) {
                    (bool success, ) = payable(msg.sender).call{
                        value: currentBalance
                    }("");

                    if (!success) {
                        revert NativeRewardTransferFailed();
                    }
                }
            }

            for (uint256 i = 0; i < rewardsLength; ++i) {
                IERC20(reward.tokens[i].token).safeTransferFrom(
                    msg.sender,
                    vault,
                    reward.tokens[i].amount
                );
            }
        }
    }

    /**
     * @notice Checks if an intent is properly funded
     * @param intent Intent to validate
     * @return True if intent is properly funded, false otherwise
     */
    function isIntentFunded(
        Intent calldata intent
    ) external view returns (bool) {
        (bytes32 intentHash, bytes32 routeHash, ) = getIntentHash(intent);
        address vault = _getIntentVaultAddress(
            intentHash,
            routeHash,
            intent.reward
        );

        return _isIntentFunded(intent, vault);
    }

    /**
     * @notice Withdraws rewards associated with an intent to its claimant
     * @param routeHash Hash of the intent's route
     * @param reward Reward structure of the intent
     */
    function withdrawRewards(bytes32 routeHash, Reward calldata reward) public {
        bytes32 rewardHash = keccak256(abi.encode(reward));
        bytes32 intentHash = keccak256(abi.encodePacked(routeHash, rewardHash));

        address claimant = BaseProver(reward.prover).provenIntents(intentHash);

        // Claim the rewards if the intent has not been claimed
        if (
            claimant != address(0) &&
            claims[intentHash].status == uint8(ClaimStatus.Initiated)
        ) {
            claims[intentHash].claimant = claimant;

            emit Withdrawal(intentHash, claimant);

            new IntentVault{salt: routeHash}(intentHash, reward);

            claims[intentHash].status = uint8(ClaimStatus.Claimed);

            return;
        }

        if (claimant == address(0)) {
            revert UnauthorizedWithdrawal(intentHash);
        } else {
            revert RewardsAlreadyWithdrawn(intentHash);
        }
    }

    /**
     * @notice Batch withdraws multiple intents with the same claimant
     * @param routeHashes Array of route hashes for the intents
     * @param rewards Array of reward structures for the intents
     */
    function batchWithdraw(
        bytes32[] calldata routeHashes,
        Reward[] calldata rewards
    ) external {
        uint256 length = routeHashes.length;

        if (length != rewards.length) {
            revert ArrayLengthMismatch();
        }

        for (uint256 i = 0; i < length; ++i) {
            withdrawRewards(routeHashes[i], rewards[i]);
        }
    }

    /**
     * @notice Refunds rewards to the intent creator
     * @param routeHash Hash of the intent's route
     * @param reward Reward structure of the intent
     * @param token Optional token address for handling incorrect vault transfers
     */
    function refundIntent(
        bytes32 routeHash,
        Reward calldata reward,
        address token
    ) external {
        bytes32 rewardHash = keccak256(abi.encode(reward));
        bytes32 intentHash = keccak256(abi.encodePacked(routeHash, rewardHash));

        if (token != address(0)) {
            refundToken = token;
        }

        emit Refund(intentHash, reward.creator);

        new IntentVault{salt: routeHash}(intentHash, reward);

        if (claims[intentHash].status == uint8(ClaimStatus.Initiated)) {
            claims[intentHash].status = uint8(ClaimStatus.Refunded);
        }

        if (token != address(0)) {
            refundToken = address(0);
        }
    }

    /**
     * @notice Validates that an intent's vault holds sufficient rewards
     * @dev Checks both native token and ERC20 token balances
     * @param intent Intent to validate
     * @param vault Address of the intent's vault
     * @return True if vault has sufficient funds, false otherwise
     */
    function _isIntentFunded(
        Intent calldata intent,
        address vault
    ) internal view returns (bool) {
        Reward calldata reward = intent.reward;
        uint256 rewardsLength = reward.tokens.length;

        if (vault.balance < reward.nativeValue) return false;
        for (uint256 i = 0; i < rewardsLength; ++i) {
            address token = reward.tokens[i].token;
            uint256 amount = reward.tokens[i].amount;
            uint256 balance = IERC20(token).balanceOf(vault);

            if (balance < amount) return false;
        }

        return true;
    }

    /**
     * @notice Calculates the deterministic address of an intent funder using CREATE2
     * @dev Follows EIP-1014 for address calculation
     * @param vault Address of the intent vault
     * @param routeHash Hash of the route component
     * @param reward Reward structure
     * @return The calculated vault address
     */
    function _getIntentFunderAddress(
        address vault,
        bytes32 routeHash,
        Reward calldata reward
    ) internal view returns (address) {
        /* Convert a hash which is bytes32 to an address which is 20-byte long
        according to https://docs.soliditylang.org/en/v0.8.9/control-structures.html?highlight=create2#salted-contract-creations-create2 */
        return
            address(
                uint160(
                    uint256(
                        keccak256(
                            abi.encodePacked(
                                hex"ff",
                                address(this),
                                routeHash,
                                keccak256(
                                    abi.encodePacked(
                                        type(IntentFunder).creationCode,
                                        abi.encode(vault, reward)
                                    )
                                )
                            )
                        )
                    )
                )
            );
    }

    /**
     * @notice Calculates the deterministic address of an intent vault using CREATE2
     * @dev Follows EIP-1014 for address calculation
     * @param intentHash Hash of the full intent
     * @param routeHash Hash of the route component
     * @param reward Reward structure
     * @return The calculated vault address
     */
    function _getIntentVaultAddress(
        bytes32 intentHash,
        bytes32 routeHash,
        Reward calldata reward
    ) internal view returns (address) {
        /* Convert a hash which is bytes32 to an address which is 20-byte long
        according to https://docs.soliditylang.org/en/v0.8.9/control-structures.html?highlight=create2#salted-contract-creations-create2 */
        return
            address(
                uint160(
                    uint256(
                        keccak256(
                            abi.encodePacked(
                                hex"ff",
                                address(this),
                                routeHash,
                                keccak256(
                                    abi.encodePacked(
                                        type(IntentVault).creationCode,
                                        abi.encode(intentHash, reward)
                                    )
                                )
                            )
                        )
                    )
                )
            );
    }
}
/* -*- c-basic-offset: 4 -*- */
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {IIntentSource} from "./interfaces/IIntentSource.sol";
import {IIntentVault} from "./interfaces/IIntentVault.sol";
import {Reward} from "./types/Intent.sol";

/**
 * @title IntentVault
 * @notice A self-destructing contract that handles reward distribution for intents
 * @dev Created by IntentSource for each intent, handles token and native currency transfers,
 * then self-destructs after distributing rewards
 */
contract IntentVault is IIntentVault {
    using SafeERC20 for IERC20;

    /**
     * @notice Creates and immediately executes reward distribution
     * @dev Contract self-destructs after execution
     * @param intentHash Hash of the intent being claimed/refunded
     * @param reward Reward data structure containing distribution details
     */
    constructor(bytes32 intentHash, Reward memory reward) {
        // Get reference to the IntentSource contract that created this vault
        IIntentSource intentSource = IIntentSource(msg.sender);
        uint256 rewardsLength = reward.tokens.length;

        // Get current claim state and any refund token override
        IIntentSource.ClaimState memory state = intentSource.getClaim(
            intentHash
        );
        address claimant = state.claimant;
        address refundToken = intentSource.getRefundToken();

        // Ensure intent has expired if there's no claimant
        if (claimant == address(0) && block.timestamp < reward.deadline) {
            revert IntentNotExpired();
        }

        // Withdrawing to creator if intent is expired or already claimed/refunded
        if (
            (claimant == address(0) && block.timestamp >= reward.deadline) ||
            state.status != uint8(IIntentSource.ClaimStatus.Initiated)
        ) {
            claimant = reward.creator;
        }

        // Process each reward token
        for (uint256 i; i < rewardsLength; ++i) {
            address token = reward.tokens[i].token;
            uint256 amount = reward.tokens[i].amount;
            uint256 balance = IERC20(token).balanceOf(address(this));

            // Prevent reward tokens from being used as refund tokens
            if (token == refundToken) {
                revert RefundTokenCannotBeRewardToken();
            }

            // If creator is claiming, send full balance
            if (claimant == reward.creator) {
                if (balance > 0) {
                    IERC20(token).safeTransfer(claimant, balance);
                }
            } else {
                // For solver claims, verify sufficient balance and send reward amount
                if (amount < balance) {
                    revert InsufficientTokenBalance();
                }

                IERC20(token).safeTransfer(claimant, amount);
                // Return excess balance to creator
                if (balance > amount) {
                    IERC20(token).safeTransfer(
                        reward.creator,
                        balance - amount
                    );
                }
            }
        }

        // Handle native token rewards for solver claims
        if (claimant != reward.creator && reward.nativeValue > 0) {
            if (address(this).balance < reward.nativeValue) {
                revert InsufficientNativeBalance();
            }

            (bool success, ) = payable(claimant).call{
                value: reward.nativeValue
            }("");

            if (!success) {
                revert NativeRewardTransferFailed();
            }
        }

        // Process any refund token if specified
        if (refundToken != address(0)) {
            uint256 refundAmount = IERC20(refundToken).balanceOf(address(this));
            if (refundAmount > 0)
                IERC20(refundToken).safeTransfer(reward.creator, refundAmount);
        }

        // Self-destruct and send remaining ETH to creator
        selfdestruct(payable(reward.creator));
    }
}
/* -*- c-basic-offset: 4 -*- */
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title IDestinationSettler
 * @notice Standard interface for settlement contracts on the destination chain
 */
interface IDestinationSettler {
    /**
     * @notice Fills a single leg of a particular order on the destination chain
     * @dev This method has been made payable, in contrast to original interface
     * @param orderId Unique order identifier for this order
     * @param originData Data emitted on the origin to parameterize the fill
     * @param fillerData Data provided by the filler to inform the fill or express their preferences
     */
    function fill(
        bytes32 orderId,
        bytes calldata originData,
        bytes calldata fillerData
    ) external payable;
}
/* -*- c-basic-offset: 4 -*- */
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "../../types/ERC7683.sol";

/**
 * @title IOriginSettler
 * @notice Standard interface for settlement contracts on the origin chain
 */

interface IOriginSettler {
    /// @notice Thrown when the sent native token amount is less than the required reward amount
    error InsufficientNativeReward();

    /// @notice Thrown when the source chain's chainID does not match the expected value
    error OriginChainIDMismatch();

    /// @notice Thrown when signature does not match the expected value
    error BadSignature();

    /**
     * @notice Signals that an order has been opened
     * @param orderId a unique order identifier within this settlement system
     * @param resolvedOrder resolved order that would be returned by resolve if called instead of Open
     */
    event Open(bytes32 indexed orderId, ResolvedCrossChainOrder resolvedOrder);

    /**
     * @notice Opens a cross-chain order
     * @dev To be called by the user
     * @dev This method must emit the Open event
     * @dev This method has been made payable, in contrast to original interface
     * @param order The OnchainCrossChainOrder definition
     */
    function open(OnchainCrossChainOrder calldata order) external payable;

    /**
     * @notice Opens a gasless cross-chain order on behalf of a user.
     * @dev To be called by the filler.
     * @dev This method must emit the Open event
     * @dev This method has been made payable, in contrast to original interface
     * @param order The GaslessCrossChainOrder definition
     * @param signature The user's signature over the order
     * @param originFillerData Any filler-defined data required by the settler
     */
    function openFor(
        GaslessCrossChainOrder calldata order,
        bytes calldata signature,
        bytes calldata originFillerData
    ) external payable;

    /**
     * @notice Resolves a specific GaslessCrossChainOrder into a generic ResolvedCrossChainOrder
     * @dev Intended to improve standardized integration of various order types and settlement contracts
     * @param order The GaslessCrossChainOrder definition
     * @param originFillerData Any filler-defined data required by the settler
     * @return ResolvedCrossChainOrder hydrated order data including the inputs and outputs of the order
     */
    function resolveFor(
        GaslessCrossChainOrder calldata order,
        bytes calldata originFillerData
    ) external view returns (ResolvedCrossChainOrder memory);

    /**
     * @notice Resolves a specific OnchainCrossChainOrder into a generic ResolvedCrossChainOrder
     * @dev Intended to improve standardized integration of various order types and settlement contracts
     * @param order The OnchainCrossChainOrder definition
     * @return ResolvedCrossChainOrder hydrated order data including the inputs and outputs of the order
     */
    function resolve(
        OnchainCrossChainOrder calldata order
    ) external view returns (ResolvedCrossChainOrder memory);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ISemver} from "./ISemver.sol";

import {Route} from "../types/Intent.sol";

/**
 * @title IInbox
 * @notice Interface for the destination chain portion of the Eco Protocol's intent system
 * @dev Handles intent fulfillment and proving via different mechanisms (storage proofs,
 * Hyperlane instant/batched)
 */
interface IInbox is ISemver {
    /**
     * @notice Emitted when an intent is successfully fulfilled
     * @param _hash Hash of the fulfilled intent
     * @param _sourceChainID ID of the source chain
     * @param _claimant Address eligible to claim rewards
     */
    event Fulfillment(
        bytes32 indexed _hash,
        uint256 indexed _sourceChainID,
        address indexed _claimant
    );

    /**
     * @notice Emitted when an intent is ready for storage proof validation
     * @param _hash Hash of the intent to prove
     * @param _sourceChainID ID of the source chain
     * @param _claimant Address eligible to claim rewards
     */
    event ToBeProven(
        bytes32 indexed _hash,
        uint256 indexed _sourceChainID,
        address indexed _claimant
    );

    /**
     * @notice Emitted when an intent is fulfilled using Hyperlane instant proving
     * @param _hash Hash of the fulfilled intent
     * @param _sourceChainID ID of the source chain
     * @param _claimant Address eligible to claim rewards
     */
    event HyperInstantFulfillment(
        bytes32 indexed _hash,
        uint256 indexed _sourceChainID,
        address indexed _claimant
    );

    /**
     * @notice Emitted when an intent is added to a Hyperlane batch
     * @param _hash Hash of the batched intent
     * @param _sourceChainID ID of the source chain
     * @param _claimant Address eligible to claim rewards
     * @param _prover Address of the Hyperlane prover
     */
    event AddToBatch(
        bytes32 indexed _hash,
        uint256 indexed _sourceChainID,
        address indexed _claimant,
        address _prover
    );

    /**
     * @notice Emitted when intent solving is made public
     * @param _hashes the intent hashes sent in the batch
     * @param _sourceChainID ID of the source chain
     */
    event BatchSent(bytes32[] indexed _hashes, uint256 indexed _sourceChainID);

    /**
     * @notice Emitted when intent solving is made public
     */
    event SolvingIsPublic();

    /**
     * @notice Emitted when Hyperlane mailbox address is set
     * @param _mailbox Address of the mailbox contract
     */
    event MailboxSet(address indexed _mailbox);

    /**
     * @notice Emitted when solver whitelist status changes
     * @param _solver Address of the solver
     * @param _canSolve Updated whitelist status
     */
    event SolverWhitelistChanged(
        address indexed _solver,
        bool indexed _canSolve
    );

    /**
     * @notice Unauthorized solver attempted to fulfill intent
     * @param _solver Address of the unauthorized solver
     */
    error UnauthorizedSolveAttempt(address _solver);

    /**
     * @notice Intent has expired and can no longer be fulfilled
     */
    error IntentExpired();

    /**
     * @notice Intent has already been fulfilled
     * @param _hash Hash of the fulfilled intent
     */
    error IntentAlreadyFulfilled(bytes32 _hash);

    /**
     * @notice Invalid inbox address provided
     * @param _inbox Address that is not a valid inbox
     */
    error InvalidInbox(address _inbox);

    /**
     * @notice Generated hash doesn't match expected hash
     * @param _expectedHash Hash that was expected
     */
    error InvalidHash(bytes32 _expectedHash);

    /**
     * @notice Zero address provided as claimant
     */
    error ZeroClaimant();

    /**
     * @notice Call during intent execution failed
     * @param _addr Target contract address
     * @param _data Call data that failed
     * @param value Native token value sent
     * @param _returnData Error data returned
     */
    error IntentCallFailed(
        address _addr,
        bytes _data,
        uint256 value,
        bytes _returnData
    );

    /**
     * @notice Attempted call to Hyperlane mailbox
     */
    error CallToMailbox();

    /**
     * @notice Unauthorized attempt to transfer native tokens
     */
    error UnauthorizedTransferNative();

    /**
     * @notice Attempted to batch an unfulfilled intent
     * @param _hash Hash of the unfulfilled intent
     */
    error IntentNotFulfilled(bytes32 _hash);

    /**
     * @notice Insufficient fee provided for Hyperlane fulfillment
     * @param _requiredFee Amount of fee required
     */
    error InsufficientFee(uint256 _requiredFee);

    /**
     * @notice Native token transfer failed
     */
    error NativeTransferFailed();

    /**
     * @notice Fulfills an intent using storage proofs
     * @dev Validates intent hash, executes calls, and marks as fulfilled
     * @param _route Route information for the intent
     * @param _rewardHash Hash of the reward details
     * @param _claimant Address eligible to claim rewards
     * @param _expectedHash Expected hash for validation
     * @return Array of execution results
     */
    function fulfillStorage(
        Route calldata _route,
        bytes32 _rewardHash,
        address _claimant,
        bytes32 _expectedHash
    ) external payable returns (bytes[] memory);

    /**
     * @notice Fulfills an intent with immediate Hyperlane proving
     * @dev Higher cost but faster than batched proving
     * @param _route Route information for the intent
     * @param _rewardHash Hash of the reward details
     * @param _claimant Address eligible to claim rewards
     * @param _expectedHash Expected hash for validation
     * @param _prover Address of the Hyperlane prover
     * @return Array of execution results
     */
    function fulfillHyperInstant(
        Route calldata _route,
        bytes32 _rewardHash,
        address _claimant,
        bytes32 _expectedHash,
        address _prover
    ) external payable returns (bytes[] memory);

    /**
     * @notice Fulfills an intent for deferred Hyperlane batch proving
     * @dev Lower cost but slower than instant proving
     * @param _route Route information for the intent
     * @param _rewardHash Hash of the reward details
     * @param _claimant Address eligible to claim rewards
     * @param _expectedHash Expected hash for validation
     * @param _prover Address of the Hyperlane prover
     * @return Array of execution results
     */
    function fulfillHyperBatched(
        Route calldata _route,
        bytes32 _rewardHash,
        address _claimant,
        bytes32 _expectedHash,
        address _prover
    ) external payable returns (bytes[] memory);

    /**
     * @notice Submits a batch of fulfilled intents to Hyperlane
     * @dev All intents must share source chain and prover
     * @param _sourceChainID Source chain ID for the batch
     * @param _prover Hyperlane prover address
     * @param _intentHashes Array of intent hashes to prove
     */
    function sendBatch(
        uint256 _sourceChainID,
        address _prover,
        bytes32[] calldata _intentHashes
    ) external payable;
}
/* -*- c-basic-offset: 4 -*- */
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ISemver} from "./ISemver.sol";

import {Intent, Reward, Call, TokenAmount} from "../types/Intent.sol";

/**
 * @title IIntentSource
 * @notice Interface for the source chain portion of the Eco Protocol's intent system
 * @dev Used to create intents and withdraw their associated rewards. Works with an inbox
 * contract on the destination chain and verifies fulfillment via a prover contract
 */
interface IIntentSource is ISemver {
    /**
     * @notice Thrown when an unauthorized address attempts to withdraw intent rewards
     * @param _hash Hash of the intent (key in intents mapping)
     */
    error UnauthorizedWithdrawal(bytes32 _hash);

    /**
     * @notice Thrown when attempting to withdraw from an intent with already claimed rewards
     * @param _hash Hash of the intent
     */
    error RewardsAlreadyWithdrawn(bytes32 _hash);

    /**
     * @notice Thrown when target addresses and calldata arrays have mismatched lengths or are empty
     */
    error CalldataMismatch();

    /**
     * @notice Thrown when reward tokens and amounts arrays have mismatched lengths or are empty
     */
    error RewardsMismatch();

    /**
     * @notice Thrown when batch withdrawal intent claimant doesn't match provided address
     * @param _hash Hash of the mismatched intent
     */
    error BadClaimant(bytes32 _hash);

    /**
     * @notice Thrown when a token transfer fails
     * @param _token Address of the token
     * @param _to Intended recipient
     * @param _amount Transfer amount
     */
    error TransferFailed(address _token, address _to, uint256 _amount);

    /**
     * @notice Thrown when a native token transfer fails
     */
    error NativeRewardTransferFailed();

    /**
     * @notice Thrown when a permit call to a contract fails
     */
    error PermitCallFailed();

    /**
     * @notice Thrown when attempting to publish an intent that already exists
     * @param intentHash Hash of the intent that already exists in the system
     */
    error IntentAlreadyExists(bytes32 intentHash);

    /**
     * @notice Thrown when attempting to fund an intent that has already been funded
     */
    error IntentAlreadyFunded();

    /**
     * @notice Thrown when the sent native token amount is less than the required reward amount
     */
    error InsufficientNativeReward();

    /**
     * @notice Thrown when attempting to validate an intent that fails basic validation checks
     * @dev This includes cases where the vault doesn't have sufficient balance or other validation failures
     */
    error InvalidIntent();

    /**
     * @notice Thrown when array lengths don't match in batch operations
     * @dev Used specifically in batch withdraw operations when routeHashes and rewards arrays have different lengths
     */
    error ArrayLengthMismatch();

    /**
     * @notice Status of an intent's reward claim
     */
    enum ClaimStatus {
        Initiated,
        Claimed,
        Refunded
    }

    /**
     * @notice State of an intent's reward claim
     * @dev Tracks claimant address and claim status
     */
    struct ClaimState {
        address claimant;
        uint8 status;
    }

    /**
     * @notice Emitted when an intent is funded with native tokens
     * @param intentHash Hash of the funded intent
     * @param fundingSource Address of the funder
     */
    event IntentFunded(bytes32 intentHash, address fundingSource);

    /**
     * @notice Emitted when a new intent is created
     * @param hash Hash of the created intent (key in intents mapping)
     * @param salt Creator-provided nonce
     * @param source Source chain ID
     * @param destination Destination chain ID
     * @param inbox Address of inbox contract on destination chain
     * @param routeTokens Array of tokens required for execution of calls on destination chain
     * @param calls Array of instruction calls to execute
     * @param creator Address that created the intent
     * @param prover Address of prover contract for validation
     * @param deadline Timestamp by which intent must be fulfilled for reward claim
     * @param nativeValue Amount of native tokens offered as reward
     * @param rewardTokens Array of ERC20 tokens and amounts offered as rewards
     */
    event IntentCreated(
        bytes32 indexed hash,
        bytes32 salt,
        uint256 source,
        uint256 destination,
        address inbox,
        TokenAmount[] routeTokens,
        Call[] calls,
        address indexed creator,
        address indexed prover,
        uint256 deadline,
        uint256 nativeValue,
        TokenAmount[] rewardTokens
    );

    /**
     * @notice Emitted when rewards are successfully withdrawn
     * @param _hash Hash of the claimed intent
     * @param _recipient Address receiving the rewards
     */
    event Withdrawal(bytes32 _hash, address indexed _recipient);

    /**
     * @notice Emitted when rewards are successfully withdrawn
     * @param _hash Hash of the claimed intent
     * @param _recipient Address receiving the rewards
     */
    event Refund(bytes32 _hash, address indexed _recipient);

    /**
     * @notice Gets the claim state for a given intent
     * @param intentHash Hash of the intent to query
     * @return Claim state struct containing claimant and status
     */
    function getClaim(
        bytes32 intentHash
    ) external view returns (ClaimState memory);

    /**
     * @notice Gets the funding source for the intent funder
     * @return Address of the native token funding source
     */
    function getFundingSource() external view returns (address);

    /**
     * @notice Gets the override token used for vault refunds
     * @return Address of the vault refund token
     */
    function getRefundToken() external view returns (address);

    /**
     * @notice Calculates the hash components of an intent
     * @param intent Intent to hash
     * @return intentHash Combined hash of route and reward
     * @return routeHash Hash of the route component
     * @return rewardHash Hash of the reward component
     */
    function getIntentHash(
        Intent calldata intent
    )
        external
        pure
        returns (bytes32 intentHash, bytes32 routeHash, bytes32 rewardHash);

    /**
     * @notice Calculates the deterministic address of the intent funder
     * @param intent Intent to calculate vault address for
     * @return Address of the intent funder
     */
    function intentFunderAddress(
        Intent calldata intent
    ) external view returns (address);

    /**
     * @notice Calculates the deterministic vault address for an intent
     * @param intent Intent to calculate vault address for
     * @return Predicted address of the intent vault
     */
    function intentVaultAddress(
        Intent calldata intent
    ) external view returns (address);

    /**
     * @notice Funds an intent with native tokens and ERC20 tokens
     * @dev Allows for permit calls to approve token transfers
     * @param routeHash Hash of the route component
     * @param reward Reward structure containing distribution details
     * @param fundingAddress Address to fund the intent from
     * @param permitCalls Array of permit calls to approve token transfers
     * @param recoverToken Address of the token to recover if sent to the vault
     */
    function fundIntent(
        bytes32 routeHash,
        Reward calldata reward,
        address fundingAddress,
        Call[] calldata permitCalls,
        address recoverToken
    ) external payable;

    /**
     * @notice Creates an intent to execute instructions on a supported chain for rewards
     * @dev Source chain proof must complete before expiry or rewards are unclaimable,
     *      regardless of execution status. Solver manages timing of L1 data posting
     * @param intent The complete intent struct
     * @param fund Whether to transfer rewards to vault during creation
     * @return intentHash Hash of the created intent
     */
    function publishIntent(
        Intent calldata intent,
        bool fund
    ) external payable returns (bytes32 intentHash);

    /**
     * @notice Verifies an intent's rewards are valid
     * @param intent Intent to validate
     * @return True if rewards are valid and funded
     */
    function isIntentFunded(
        Intent calldata intent
    ) external view returns (bool);

    /**
     * @notice Withdraws reward funds for a fulfilled intent
     * @param routeHash Hash of the intent's route
     * @param reward Reward struct containing distribution details
     */
    function withdrawRewards(
        bytes32 routeHash,
        Reward calldata reward
    ) external;

    /**
     * @notice Batch withdraws rewards for multiple intents
     * @param routeHashes Array of route hashes
     * @param rewards Array of reward structs
     */
    function batchWithdraw(
        bytes32[] calldata routeHashes,
        Reward[] calldata rewards
    ) external;

    /**
     * @notice Refunds rewards back to the intent creator
     * @param routeHash Hash of the intent's route
     * @param reward Reward struct containing distribution details
     * @param token Optional token to refund if incorrectly sent to vault
     */
    function refundIntent(
        bytes32 routeHash,
        Reward calldata reward,
        address token
    ) external;
}
/* -*- c-basic-offset: 4 -*- */
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title IIntentVault
 * @notice Interface defining errors for the IntentVault contract
 */
interface IIntentVault {
    /**
     * @notice Thrown when attempting to withdraw rewards before the intent has expired
     */
    error IntentNotExpired();

    /**
     * @notice Thrown when trying to use a reward token as a refund token
     */
    error RefundTokenCannotBeRewardToken();

    /**
     * @notice Thrown when the vault has insufficient token balance for reward distribution
     */
    error InsufficientTokenBalance();

    /**
     * @notice Thrown when the vault has insufficient native token balance
     */
    error InsufficientNativeBalance();

    /**
     * @notice Thrown when the native token transfer to the claimant fails
     */
    error NativeRewardTransferFailed();
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ISemver} from "./ISemver.sol";

interface IL1Block is ISemver {
    /// @notice The latest L1 block number known by the L2 system.
    function number() external view returns (uint64);

    /// @notice The latest L1 timestamp known by the L2 system.
    function timestamp() external view returns (uint64);

    /// @notice The latest L1 base fee.
    function basefee() external view returns (uint256);

    /// @notice The latest L1 blockhash.
    function hash() external view returns (bytes32);

    /// @notice The number of L2 blocks in the same epoch.
    function sequenceNumber() external view returns (uint64);

    /// @notice The scalar value applied to the L1 blob base fee portion of the blob-capable L1 cost func.
    function blobBaseFeeScalar() external view returns (uint32);

    /// @notice The scalar value applied to the L1 base fee portion of the blob-capable L1 cost func.
    function baseFeeScalar() external view returns (uint32);

    /// @notice The versioned hash to authenticate the batcher by.
    function batcherHash() external view returns (bytes32);

    /**
     * @notice The overhead value applied to the L1 portion of the transaction fee.
     * @custom:legacy
     */
    function l1FeeOverhead() external view returns (uint256);

    /**
     * @notice The scalar value applied to the L1 portion of the transaction fee.
     * @custom:legacy
     */
    function l1FeeScalar() external view returns (uint256);

    /// @notice The latest L1 blob base fee.
    function blobBaseFee() external view returns (uint256);

    /**
     * @notice Updates the L1 block values.
     * @custom:legacy
     * @param _number         L1 blocknumber.
     * @param _timestamp      L1 timestamp.
     * @param _basefee        L1 basefee.
     * @param _hash           L1 blockhash.
     * @param _sequenceNumber Number of L2 blocks since epoch start.
     * @param _batcherHash    Versioned hash to authenticate batcher by.
     * @param _l1FeeOverhead  L1 fee overhead.
     * @param _l1FeeScalar    L1 fee scalar.
     */
    function setL1BlockValues(
        uint64 _number,
        uint64 _timestamp,
        uint256 _basefee,
        bytes32 _hash,
        uint64 _sequenceNumber,
        bytes32 _batcherHash,
        uint256 _l1FeeOverhead,
        uint256 _l1FeeScalar
    ) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ISemver} from "./ISemver.sol";

/**
 * @title IProver
 * @notice Interface for proving intent fulfillment
 * @dev Defines required functionality for proving intent execution with different
 * proof mechanisms (storage or Hyperlane)
 */
interface IProver is ISemver {
    /**
     * @notice Types of proofs that can validate intent fulfillment
     * @param Storage Traditional storage-based proof mechanism
     * @param Hyperlane Proof using Hyperlane's cross-chain messaging
     */
    enum ProofType {
        Storage,
        Hyperlane
    }

    /**
     * @notice Emitted when an intent is successfully proven
     * @param _hash Hash of the proven intent
     * @param _claimant Address eligible to claim the intent's rewards
     */
    event IntentProven(bytes32 indexed _hash, address indexed _claimant);

    /**
     * @notice Gets the proof mechanism type used by this prover
     * @return ProofType enum indicating the prover's mechanism
     */
    function getProofType() external pure returns (ProofType);

    /**
     * @notice Gets the address eligible to claim rewards for a proven intent
     * @param intentHash Hash of the intent to query
     * @return Address of the claimant, or zero address if unproven
     */
    function getIntentClaimant(
        bytes32 intentHash
    ) external view returns (address);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title Semver Interface
 * @dev An interface for a contract that has a version
 */
interface ISemver {
    function version() external pure returns (string memory);
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import {ISemver} from "../interfaces/ISemver.sol";

abstract contract Semver is ISemver {
    function version() external pure returns (string memory) { return "1.9.13-a72f02f"; }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IProver} from "../interfaces/IProver.sol";

/**
 * @title BaseProver
 * @notice Base implementation for intent proving contracts
 * @dev Provides core storage and functionality for tracking proven intents
 * and their claimants
 */
abstract contract BaseProver is IProver {
    /**
     * @notice Mapping from intent hash to address eligible to claim rewards
     * @dev Zero address indicates intent hasn't been proven
     */
    mapping(bytes32 => address) public provenIntents;

    /**
     * @notice Gets the address eligible to claim rewards for a given intent
     * @param intentHash Hash of the intent to query
     * @return Address of the claimant, or zero address if unproven
     */
    function getIntentClaimant(
        bytes32 intentHash
    ) external view override returns (address) {
        return provenIntents[intentHash];
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IMessageRecipient} from "@hyperlane-xyz/core/contracts/interfaces/IMessageRecipient.sol";
import {TypeCasts} from "@hyperlane-xyz/core/contracts/libs/TypeCasts.sol";
import {BaseProver} from "./BaseProver.sol";
import {Semver} from "../libs/Semver.sol";

/**
 * @title HyperProver
 * @notice Prover implementation using Hyperlane's cross-chain messaging system
 * @dev Processes proof messages from Hyperlane mailbox and records proven intents
 */
contract HyperProver is IMessageRecipient, BaseProver, Semver {
    using TypeCasts for bytes32;

    /**
     * @notice Constant indicating this contract uses Hyperlane for proving
     */
    ProofType public constant PROOF_TYPE = ProofType.Hyperlane;

    /**
     * @notice Emitted when attempting to prove an already-proven intent
     * @dev Event instead of error to allow batch processing to continue
     * @param _intentHash Hash of the already proven intent
     */
    event IntentAlreadyProven(bytes32 _intentHash);

    /**
     * @notice Unauthorized call to handle() detected
     * @param _sender Address that attempted the call
     */
    error UnauthorizedHandle(address _sender);

    /**
     * @notice Unauthorized dispatch detected from source chain
     * @param _sender Address that initiated the invalid dispatch
     */
    error UnauthorizedDispatch(address _sender);

    /**
     * @notice Address of local Hyperlane mailbox
     */
    address public immutable MAILBOX;

    /**
     * @notice Address of Inbox contract (same across all chains via ERC-2470)
     */
    address public immutable INBOX;

    /**
     * @notice Initializes the HyperProver contract
     * @param _mailbox Address of local Hyperlane mailbox
     * @param _inbox Address of Inbox contract
     */
    constructor(address _mailbox, address _inbox) {
        MAILBOX = _mailbox;
        INBOX = _inbox;
    }

    /**
     * @notice Handles incoming Hyperlane messages containing proof data
     * @dev Processes batch updates to proven intents from valid sources
     * param _origin Origin chain ID (unused but required by interface)
     * @param _sender Address that dispatched the message on source chain
     * @param _messageBody Encoded array of intent hashes and claimants
     */
    function handle(
        uint32,
        bytes32 _sender,
        bytes calldata _messageBody
    ) public payable {
        // Verify message is from authorized mailbox
        if (MAILBOX != msg.sender) {
            revert UnauthorizedHandle(msg.sender);
        }

        // Verify dispatch originated from valid Inbox
        address sender = _sender.bytes32ToAddress();

        if (INBOX != sender) {
            revert UnauthorizedDispatch(sender);
        }

        // Decode message containing intent hashes and claimants
        (bytes32[] memory hashes, address[] memory claimants) = abi.decode(
            _messageBody,
            (bytes32[], address[])
        );

        // Process each intent proof
        for (uint256 i = 0; i < hashes.length; i++) {
            (bytes32 intentHash, address claimant) = (hashes[i], claimants[i]);
            if (provenIntents[intentHash] != address(0)) {
                emit IntentAlreadyProven(intentHash);
            } else {
                provenIntents[intentHash] = claimant;
                emit IntentProven(intentHash, claimant);
            }
        }
    }

    /**
     * @notice Returns the proof type used by this prover
     * @return ProofType indicating Hyperlane proving mechanism
     */
    function getProofType() external pure override returns (ProofType) {
        return PROOF_TYPE;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {SecureMerkleTrie} from "@eth-optimism/contracts-bedrock/src/libraries/trie/SecureMerkleTrie.sol";
import {RLPReader} from "@eth-optimism/contracts-bedrock/src/libraries/rlp/RLPReader.sol";
import {RLPWriter} from "@eth-optimism/contracts-bedrock/src/libraries/rlp/RLPWriter.sol";
import {IL1Block} from "../interfaces/IL1Block.sol";
import {BaseProver} from "./BaseProver.sol";
import {Semver} from "../libs/Semver.sol";

/**
 * @title Prover
 * @notice Validates cross-chain intent execution through storage proofs and Bedrock/Cannon L2 proving
 * @dev Inherits from BaseProver to provide core proving functionality. Supports both storage-based
 * proofs and optimistic rollup verification through various proving mechanisms
 */
contract Prover is BaseProver, Semver {
    ProofType public constant PROOF_TYPE = ProofType.Storage;

    // Output slot for Bedrock L2_OUTPUT_ORACLE where Settled Batches are stored
    uint256 public constant L2_OUTPUT_SLOT_NUMBER = 3;

    uint256 public constant L2_OUTPUT_ROOT_VERSION_NUMBER = 0;

    // L2OutputOracle on Ethereum used for Bedrock (Base) Proving
    // address public immutable l1OutputOracleAddress;

    // Cannon Data
    // FaultGameFactory on Ethereum used for Cannon (Optimism) Proving
    // address public immutable faultGameFactoryAddress;

    // Output slot for Cannon DisputeGameFactory where FaultDisputeGames gameId's are stored
    uint256 public constant L2_DISPUTE_GAME_FACTORY_LIST_SLOT_NUMBER = 104;

    // Output slot for the root claim (used as the block number settled is part of the root claim)
    uint256 public constant L2_FAULT_DISPUTE_GAME_ROOT_CLAIM_SLOT =
        0x405787fa12a823e0f2b7631cc41b3ba8828b3321ca811111fa75cd3aa3bb5ad1;

    // Output slot for the game status (fixed)
    uint256 public constant L2_FAULT_DISPUTE_GAME_STATUS_SLOT = 0;

    // Number of blocks to wait before Settlement Layer can be proven again
    uint256 public immutable SETTLEMENT_BLOCKS_DELAY;

    // This contract lives on an L2 and contains the data for the 'current' L1 block.
    // there is a delay between this contract and L1 state - the block information found here is usually a few blocks behind the most recent block on L1.
    // But optimism maintains a service that posts L1 block data on L2.
    IL1Block public l1BlockhashOracle;

    /**
     * @notice Configuration data for a chain's proving mechanism
     * @param provingMechanism Type of proving used (e.g., Bedrock, Cannon)
     * @param settlementChainId ID of chain where proofs are settled
     * @param settlementContract Address of contract handling proof settlement
     * @param blockhashOracle Address of oracle providing block data
     * @param outputRootVersionNumber Version of output root format
     * @param finalityDelaySeconds Required delay before finalizing proofs
     */
    struct ChainConfiguration {
        uint8 provingMechanism;
        uint256 settlementChainId;
        address settlementContract;
        address blockhashOracle;
        uint256 outputRootVersionNumber;
        uint256 finalityDelaySeconds;
    }

    /**
     * @notice Helper struct for constructor chain configuration
     * @param chainId ID of chain being configured
     * @param chainConfiguration Configuration parameters for the chain
     */
    struct ChainConfigurationConstructor {
        uint256 chainId;
        ChainConfiguration chainConfiguration;
    }

    /**
     * @notice Maps chain IDs to their proving configurations
     */
    mapping(uint256 => ChainConfiguration) public chainConfigurations;

    /**
     * @notice Stores proven block data for a chain
     * @param blockNumber Number of the proven block
     * @param blockHash Hash of the proven block
     * @param stateRoot State root of the proven block
     */
    struct BlockProof {
        uint256 blockNumber;
        bytes32 blockHash;
        bytes32 stateRoot;
    }

    /**
     * @notice Maps chain IDs to their latest proven block state
     */
    mapping(uint256 => BlockProof) public provenStates;

    /**
     * @notice Proof data required for dispute game factory verification
     * @param messagePasserStateRoot Root of the message passer state
     * @param latestBlockHash Hash of latest block
     * @param gameIndex Index in the dispute game factory
     * @param gameId Unique identifier of the dispute game
     * @param disputeFaultGameStorageProof Proof of storage for dispute game
     * @param rlpEncodedDisputeGameFactoryData RLP encoded factory contract data
     * @param disputeGameFactoryAccountProof Proof of factory contract account
     */
    struct DisputeGameFactoryProofData {
        bytes32 messagePasserStateRoot;
        bytes32 latestBlockHash;
        uint256 gameIndex;
        bytes32 gameId;
        bytes[] disputeFaultGameStorageProof;
        bytes rlpEncodedDisputeGameFactoryData;
        bytes[] disputeGameFactoryAccountProof;
    }

    /**
     * @notice Status data for a fault dispute game
     * @param createdAt Timestamp of game creation
     * @param resolvedAt Timestamp of game resolution
     * @param gameStatus Current status of the game
     * @param initialized Whether game is initialized
     * @param l2BlockNumberChallenged Whether block number was challenged
     */
    struct FaultDisputeGameStatusSlotData {
        uint64 createdAt;
        uint64 resolvedAt;
        uint8 gameStatus;
        bool initialized;
        bool l2BlockNumberChallenged;
    }

    /**
     * @notice Proof data for fault dispute game verification
     * @param faultDisputeGameStateRoot State root of dispute game
     * @param faultDisputeGameRootClaimStorageProof Proof of root claim storage
     * @param faultDisputeGameStatusSlotData Status data of the game
     * @param faultDisputeGameStatusStorageProof Proof of game status storage
     * @param rlpEncodedFaultDisputeGameData RLP encoded game contract data
     * @param faultDisputeGameAccountProof Proof of game contract account
     */
    struct FaultDisputeGameProofData {
        bytes32 faultDisputeGameStateRoot;
        bytes[] faultDisputeGameRootClaimStorageProof;
        FaultDisputeGameStatusSlotData faultDisputeGameStatusSlotData;
        bytes[] faultDisputeGameStatusStorageProof;
        bytes rlpEncodedFaultDisputeGameData;
        bytes[] faultDisputeGameAccountProof;
    }

    /**
     * @notice Emitted when L1 world state is successfully proven
     * @param _blockNumber Block number of proven state
     * @param _L1WorldStateRoot World state root that was proven
     */
    event L1WorldStateProven(
        uint256 indexed _blockNumber,
        bytes32 _L1WorldStateRoot
    );

    /**
     * @notice Emitted when L2 world state is successfully proven
     * @param _destinationChainID Chain ID of the L2
     * @param _blockNumber Block number of proven state
     * @param _L2WorldStateRoot World state root that was proven
     */
    event L2WorldStateProven(
        uint256 indexed _destinationChainID,
        uint256 indexed _blockNumber,
        bytes32 _L2WorldStateRoot
    );

    /**
     * @notice Block number is too recent to prove
     * @param _inputBlockNumber Block attempted to prove
     * @param _nextProvableBlockNumber Next valid block number
     */
    error NeedLaterBlock(
        uint256 _inputBlockNumber,
        uint256 _nextProvableBlockNumber
    );

    /**
     * @notice Block number is older than currently proven block
     * @param _inputBlockNumber Block attempted to prove
     * @param _latestBlockNumber Current proven block
     */
    error OutdatedBlock(uint256 _inputBlockNumber, uint256 _latestBlockNumber);

    /**
     * @notice RLP encoded block data hash mismatch
     * @param _expectedBlockHash Expected hash
     * @param _calculatedBlockHash Actual hash
     */
    error InvalidRLPEncodedBlock(
        bytes32 _expectedBlockHash,
        bytes32 _calculatedBlockHash
    );

    /**
     * @notice Failed storage proof verification
     * @param _key Storage key
     * @param _val Storage value
     * @param _proof Merkle proof
     * @param _root Expected root
     */
    error InvalidStorageProof(
        bytes _key,
        bytes _val,
        bytes[] _proof,
        bytes32 _root
    );

    /**
     * @notice Failed account proof verification
     * @param _address Account address
     * @param _data Account data
     * @param _proof Merkle proof
     * @param _root Expected root
     */
    error InvalidAccountProof(
        bytes _address,
        bytes _data,
        bytes[] _proof,
        bytes32 _root
    );

    /**
     * @notice Settlement chain state not yet proven
     * @param _blockProofStateRoot State root attempted to prove
     * @param _l1WorldStateRoot Current proven state root
     */
    error SettlementChainStateRootNotProved(
        bytes32 _blockProofStateRoot,
        bytes32 _l1WorldStateRoot
    );

    /**
     * @notice Destination chain state not yet proven
     * @param _blockProofStateRoot State root attempted to prove
     * @param _l2WorldStateRoot Current proven state root
     */
    error DestinationChainStateRootNotProved(
        bytes32 _blockProofStateRoot,
        bytes32 _l2WorldStateRoot
    );

    /**
     * @notice Block timestamp before finality period
     * @param _blockTimeStamp Block timestamp
     * @param _finalityDelayTimeStamp Required timestamp including delay
     */
    error BlockBeforeFinalityPeriod(
        uint256 _blockTimeStamp,
        uint256 _finalityDelayTimeStamp
    );

    /**
     * @notice Invalid output oracle state root encoding
     * @param _outputOracleStateRoot Invalid state root
     */
    error IncorrectOutputOracleStateRoot(bytes _outputOracleStateRoot);

    /**
     * @notice Invalid dispute game factory state root encoding
     * @param _disputeGameFactoryStateRoot Invalid state root
     */
    error IncorrectDisputeGameFactoryStateRoot(
        bytes _disputeGameFactoryStateRoot
    );

    /**
     * @notice Invalid inbox state root encoding
     * @param _inboxStateRoot Invalid state root
     */
    error IncorrectInboxStateRoot(bytes _inboxStateRoot);

    /**
     * @notice Fault dispute game not yet resolved
     * @param _gameStatus Current game status
     */
    error FaultDisputeGameUnresolved(uint8 _gameStatus);

    /**
     * @notice Validates RLP encoded block data matches expected hash
     * @param _rlpEncodedBlockData Encoded block data
     * @param _expectedBlockHash Expected block hash
     */
    modifier validRLPEncodeBlock(
        bytes calldata _rlpEncodedBlockData,
        bytes32 _expectedBlockHash
    ) {
        bytes32 calculatedBlockHash = keccak256(_rlpEncodedBlockData);
        if (calculatedBlockHash == _expectedBlockHash) {
            _;
        } else {
            revert InvalidRLPEncodedBlock(
                _expectedBlockHash,
                calculatedBlockHash
            );
        }
    }

    /**
     * @notice Initializes prover with chain configurations
     * @param _settlementBlocksDelay Minimum blocks between settlement proofs
     * @param _chainConfigurations Array of chain configurations
     */
    constructor(
        uint256 _settlementBlocksDelay,
        ChainConfigurationConstructor[] memory _chainConfigurations
    ) {
        SETTLEMENT_BLOCKS_DELAY = _settlementBlocksDelay;
        for (uint256 i = 0; i < _chainConfigurations.length; ++i) {
            _setChainConfiguration(
                _chainConfigurations[i].chainId,
                _chainConfigurations[i].chainConfiguration
            );
        }
    }

    /**
     * @notice Returns the proof type used by this prover
     */
    function getProofType() external pure override returns (ProofType) {
        return PROOF_TYPE;
    }
    /**
     * @notice Configures proving mechanism for a chain
     * @dev Sets blockhash oracle if configuring current chain
     * @param chainId Chain to configure
     * @param chainConfiguration Configuration parameters
     */
    function _setChainConfiguration(
        uint256 chainId,
        ChainConfiguration memory chainConfiguration
    ) internal {
        chainConfigurations[chainId] = chainConfiguration;
        if (block.chainid == chainId) {
            l1BlockhashOracle = IL1Block(chainConfiguration.blockhashOracle);
        }
    }

    /**
     * @notice Validates a storage proof against a root
     * @dev Uses SecureMerkleTrie for verification
     * @param _key Storage slot key
     * @param _val Expected value
     * @param _proof Merkle proof
     * @param _root Expected root
     */
    function proveStorage(
        bytes memory _key,
        bytes memory _val,
        bytes[] memory _proof,
        bytes32 _root
    ) public pure {
        if (!SecureMerkleTrie.verifyInclusionProof(_key, _val, _proof, _root)) {
            revert InvalidStorageProof(_key, _val, _proof, _root);
        }
    }

    /**
     * @notice Validates a bytes32 storage value against a root
     * @dev Encodes value as RLP before verification
     * @param _key Storage slot key
     * @param _val Expected bytes32 value
     * @param _proof Merkle proof
     * @param _root Expected root
     */
    function proveStorageBytes32(
        bytes memory _key,
        bytes32 _val,
        bytes[] memory _proof,
        bytes32 _root
    ) public pure {
        // `RLPWriter.writeUint` properly encodes values by removing any leading zeros.
        bytes memory rlpEncodedValue = RLPWriter.writeUint(uint256(_val));
        if (
            !SecureMerkleTrie.verifyInclusionProof(
                _key,
                rlpEncodedValue,
                _proof,
                _root
            )
        ) {
            revert InvalidStorageProof(_key, rlpEncodedValue, _proof, _root);
        }
    }

    /**
     * @notice Validates an account proof against a root
     * @dev Uses SecureMerkleTrie for verification
     * @param _address Account address
     * @param _data Expected account data
     * @param _proof Merkle proof
     * @param _root Expected root
     */
    function proveAccount(
        bytes memory _address,
        bytes memory _data,
        bytes[] memory _proof,
        bytes32 _root
    ) public pure {
        if (
            !SecureMerkleTrie.verifyInclusionProof(
                _address,
                _data,
                _proof,
                _root
            )
        ) {
            revert InvalidAccountProof(_address, _data, _proof, _root);
        }
    }

    /**
     * @notice Generates an output root for Bedrock and Cannon proving
     * @param outputRootVersion Version number (usually 0)
     * @param worldStateRoot State root
     * @param messagePasserStateRoot Message passer state root
     * @param latestBlockHash Latest block hash
     * @return Output root hash
     */
    function generateOutputRoot(
        uint256 outputRootVersion,
        bytes32 worldStateRoot,
        bytes32 messagePasserStateRoot,
        bytes32 latestBlockHash
    ) public pure returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    outputRootVersion,
                    worldStateRoot,
                    messagePasserStateRoot,
                    latestBlockHash
                )
            );
    }

    /**
     * @notice RLP encodes a list of data elements
     * @dev Helper function for batch encoding
     * @param dataList List of data elements to encode
     * @return RLP encoded bytes
     */
    function rlpEncodeDataLibList(
        bytes[] memory dataList
    ) external pure returns (bytes memory) {
        for (uint256 i = 0; i < dataList.length; ++i) {
            dataList[i] = RLPWriter.writeBytes(dataList[i]);
        }

        return RLPWriter.writeList(dataList);
    }

    /**
     * @notice Packs game metadata into a 32-byte GameId
     * @dev Combines type, timestamp, and proxy address into single identifier
     * @param _gameType Game type identifier
     * @param _timestamp Creation timestamp
     * @param _gameProxy Proxy contract address
     * @return gameId_ Packed game identifier
     */
    function pack(
        uint32 _gameType,
        uint64 _timestamp,
        address _gameProxy
    ) public pure returns (bytes32 gameId_) {
        assembly {
            gameId_ := or(
                or(shl(224, _gameType), shl(160, _timestamp)),
                _gameProxy
            )
        }
    }

    /**
     * @notice Unpacks a 32-byte GameId into its components
     * @param _gameId Packed game identifier
     * @return gameType_ Game type identifier
     * @return timestamp_ Creation timestamp
     * @return gameProxy_ Proxy contract address
     */
    function unpack(
        bytes32 _gameId
    )
        public
        pure
        returns (uint32 gameType_, uint64 timestamp_, address gameProxy_)
    {
        assembly {
            gameType_ := shr(224, _gameId)
            timestamp_ := and(shr(160, _gameId), 0xFFFFFFFFFFFFFFFF)
            gameProxy_ := and(
                _gameId,
                0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            )
        }
    }

    /**
     * @notice Converts bytes to uint256
     * @dev Manual byte-by-byte conversion
     * @param b Bytes to convert
     * @return Converted uint256 value
     */
    function _bytesToUint(bytes memory b) internal pure returns (uint256) {
        uint256 number;
        for (uint256 i = 0; i < b.length; i++) {
            number =
                number +
                uint256(uint8(b[i])) *
                (2 ** (8 * (b.length - (i + 1))));
        }
        return number;
    }

    /**
     * @notice Assembles game status storage slot data
     * @dev Packs status fields into a single bytes32
     * @param createdAt Creation timestamp
     * @param resolvedAt Resolution timestamp
     * @param gameStatus Game status code
     * @param initialized Initialization status
     * @param l2BlockNumberChallenged Block number challenge status
     * @return gameStatusStorageSlotRLP Packed status data
     */
    function assembleGameStatusStorage(
        uint64 createdAt,
        uint64 resolvedAt,
        uint8 gameStatus,
        bool initialized,
        bool l2BlockNumberChallenged
    ) public pure returns (bytes32 gameStatusStorageSlotRLP) {
        // Packed data is 64 + 64 + 8 + 8 + 8 = 152 bits / 19 bytes.
        // Need to convert to `uint152` to preserve right alignment.
        return
            bytes32(
                uint256(
                    uint152(
                        bytes19(
                            abi.encodePacked(
                                l2BlockNumberChallenged,
                                initialized,
                                gameStatus,
                                resolvedAt,
                                createdAt
                            )
                        )
                    )
                )
            );
    }

    /**
     * @notice Proves L1 settlement layer state against oracle
     * @dev Validates block data against L1 blockhash oracle and updates proven state
     * @param rlpEncodedBlockData RLP encoded block data
     */
    function proveSettlementLayerState(
        bytes calldata rlpEncodedBlockData
    )
        public
        validRLPEncodeBlock(rlpEncodedBlockData, l1BlockhashOracle.hash())
    {
        uint256 settlementChainId = chainConfigurations[block.chainid]
            .settlementChainId;
        // not necessary because we already confirm that the data is correct by ensuring that it hashes to the block hash
        // require(l1WorldStateRoot.length <= 32); // ensure lossless casting to bytes32

        // Extract block proof from encoded data
        BlockProof memory blockProof = BlockProof({
            blockNumber: _bytesToUint(
                RLPReader.readBytes(RLPReader.readList(rlpEncodedBlockData)[8])
            ),
            blockHash: keccak256(rlpEncodedBlockData),
            stateRoot: bytes32(
                RLPReader.readBytes(RLPReader.readList(rlpEncodedBlockData)[3])
            )
        });

        // Verify block delay and update state
        BlockProof memory existingBlockProof = provenStates[settlementChainId];
        if (
            existingBlockProof.blockNumber + SETTLEMENT_BLOCKS_DELAY <
            blockProof.blockNumber
        ) {
            provenStates[settlementChainId] = blockProof;
            emit L1WorldStateProven(
                blockProof.blockNumber,
                blockProof.stateRoot
            );
        } else {
            revert NeedLaterBlock(
                blockProof.blockNumber,
                existingBlockProof.blockNumber + SETTLEMENT_BLOCKS_DELAY
            );
        }
    }

    /**
     * @notice Handles Bedrock L2 world state validation
     * @dev Verifies L2 output root against L1 oracle and updates proven state
     * @param chainId Destination chain ID
     * @param rlpEncodedBlockData RLP encoded block data
     * @param l2WorldStateRoot L2 state root
     * @param l2MessagePasserStateRoot L2 message passer state root
     * @param l2OutputIndex Batch number
     * @param l1StorageProof L1 storage proof for L2OutputOracle
     * @param rlpEncodedOutputOracleData RLP encoded L2OutputOracle data
     * @param l1AccountProof L1 account proof for L2OutputOracle
     * @param l1WorldStateRoot Proven L1 world state root
     */
    function proveWorldStateBedrock(
        uint256 chainId,
        bytes calldata rlpEncodedBlockData,
        bytes32 l2WorldStateRoot,
        bytes32 l2MessagePasserStateRoot,
        uint256 l2OutputIndex,
        bytes[] calldata l1StorageProof,
        bytes calldata rlpEncodedOutputOracleData,
        bytes[] calldata l1AccountProof,
        bytes32 l1WorldStateRoot
    ) public virtual {
        // could set a more strict requirement here to make the L1 block number greater than something corresponding to the intent creation
        // can also use timestamp instead of block when this is proven for better crosschain knowledge
        // failing the need for all that, change the mapping to map to bool
        ChainConfiguration memory chainConfiguration = chainConfigurations[
            chainId
        ];
        BlockProof memory existingSettlementBlockProof = provenStates[
            chainConfiguration.settlementChainId
        ];

        // Verify settlement chain state root
        if (existingSettlementBlockProof.stateRoot != l1WorldStateRoot) {
            revert SettlementChainStateRootNotProved(
                existingSettlementBlockProof.stateRoot,
                l1WorldStateRoot
            );
        }

        // Verify block timestamp meets finality delay
        uint256 endBatchBlockTimeStamp = _bytesToUint(
            RLPReader.readBytes(RLPReader.readList(rlpEncodedBlockData)[11])
        );

        if (
            block.timestamp <=
            endBatchBlockTimeStamp + chainConfiguration.finalityDelaySeconds
        ) {
            revert BlockBeforeFinalityPeriod(
                block.timestamp,
                endBatchBlockTimeStamp + chainConfiguration.finalityDelaySeconds
            );
        }

        // Generate and verify output root
        bytes32 blockHash = keccak256(rlpEncodedBlockData);
        bytes32 outputRoot = generateOutputRoot(
            L2_OUTPUT_ROOT_VERSION_NUMBER,
            l2WorldStateRoot,
            l2MessagePasserStateRoot,
            blockHash
        );

        // Calculate storage slot and verify output root
        bytes32 outputRootStorageSlot = bytes32(
            (uint256(keccak256(abi.encode(L2_OUTPUT_SLOT_NUMBER))) +
                l2OutputIndex *
                2)
        );

        bytes memory outputOracleStateRoot = RLPReader.readBytes(
            RLPReader.readList(rlpEncodedOutputOracleData)[2]
        );

        if (outputOracleStateRoot.length > 32) {
            revert IncorrectOutputOracleStateRoot(outputOracleStateRoot);
        }

        proveStorageBytes32(
            abi.encodePacked(outputRootStorageSlot),
            outputRoot,
            l1StorageProof,
            bytes32(outputOracleStateRoot)
        );

        proveAccount(
            abi.encodePacked(chainConfiguration.settlementContract),
            rlpEncodedOutputOracleData,
            l1AccountProof,
            l1WorldStateRoot
        );

        // Update proven state if newer block
        BlockProof memory existingBlockProof = provenStates[chainId];
        BlockProof memory blockProof = BlockProof({
            blockNumber: _bytesToUint(
                RLPReader.readBytes(RLPReader.readList(rlpEncodedBlockData)[8])
            ),
            blockHash: blockHash,
            stateRoot: l2WorldStateRoot
        });

        if (existingBlockProof.blockNumber < blockProof.blockNumber) {
            provenStates[chainId] = blockProof;
            emit L2WorldStateProven(
                chainId,
                blockProof.blockNumber,
                blockProof.stateRoot
            );
        } else {
            if (existingBlockProof.blockNumber > blockProof.blockNumber) {
                revert OutdatedBlock(
                    blockProof.blockNumber,
                    existingBlockProof.blockNumber
                );
            }
        }
    }

    /**
     * @notice Validates fault dispute game from factory configuration
     * @dev Internal helper for Cannon proving
     * @param disputeGameFactoryAddress Factory contract address
     * @param l2WorldStateRoot L2 state root to verify
     * @param disputeGameFactoryProofData Proof data for factory validation
     * @param l1WorldStateRoot Proven L1 world state root
     * @return faultDisputeGameProxyAddress Address of game proxy
     * @return rootClaim Generated root claim
     */
    function _faultDisputeGameFromFactory(
        address disputeGameFactoryAddress,
        bytes32 l2WorldStateRoot,
        DisputeGameFactoryProofData calldata disputeGameFactoryProofData,
        bytes32 l1WorldStateRoot
    )
        internal
        pure
        returns (address faultDisputeGameProxyAddress, bytes32 rootClaim)
    {
        // Generate root claim from state data
        bytes32 _rootClaim = generateOutputRoot(
            L2_OUTPUT_ROOT_VERSION_NUMBER,
            l2WorldStateRoot,
            disputeGameFactoryProofData.messagePasserStateRoot,
            disputeGameFactoryProofData.latestBlockHash
        );

        // Verify game exists in factory
        bytes32 disputeGameFactoryStorageSlot = bytes32(
            abi.encode(
                (uint256(
                    keccak256(
                        abi.encode(L2_DISPUTE_GAME_FACTORY_LIST_SLOT_NUMBER)
                    )
                ) + disputeGameFactoryProofData.gameIndex)
            )
        );

        bytes memory disputeGameFactoryStateRoot = RLPReader.readBytes(
            RLPReader.readList(
                disputeGameFactoryProofData.rlpEncodedDisputeGameFactoryData
            )[2]
        );

        if (disputeGameFactoryStateRoot.length > 32) {
            revert IncorrectDisputeGameFactoryStateRoot(
                disputeGameFactoryStateRoot
            );
        }

        // Verify storage and account proofs
        proveStorageBytes32(
            abi.encodePacked(disputeGameFactoryStorageSlot),
            disputeGameFactoryProofData.gameId,
            disputeGameFactoryProofData.disputeFaultGameStorageProof,
            bytes32(disputeGameFactoryStateRoot)
        );

        proveAccount(
            abi.encodePacked(disputeGameFactoryAddress),
            disputeGameFactoryProofData.rlpEncodedDisputeGameFactoryData,
            disputeGameFactoryProofData.disputeGameFactoryAccountProof,
            l1WorldStateRoot
        );

        // Get proxy address from game ID
        (, , address _faultDisputeGameProxyAddress) = unpack(
            disputeGameFactoryProofData.gameId
        );

        return (_faultDisputeGameProxyAddress, _rootClaim);
    }

    /**
     * @notice Verifies fault dispute game resolution
     * @dev Verifies game status and root claim
     * @param rootClaim Expected root claim value
     * @param faultDisputeGameProxyAddress Game proxy contract
     * @param faultDisputeGameProofData Proof data for game verification
     * @param l1WorldStateRoot Proven L1 world state root
     */
    function _faultDisputeGameIsResolved(
        bytes32 rootClaim,
        address faultDisputeGameProxyAddress,
        FaultDisputeGameProofData memory faultDisputeGameProofData,
        bytes32 l1WorldStateRoot
    ) internal pure {
        // Verify game is resolved
        if (
            faultDisputeGameProofData
                .faultDisputeGameStatusSlotData
                .gameStatus != 2
        ) {
            revert FaultDisputeGameUnresolved(
                faultDisputeGameProofData
                    .faultDisputeGameStatusSlotData
                    .gameStatus
            );
        }

        // ensure faultDisputeGame is resolved
        // Prove that the FaultDispute game has been settled
        // storage proof for FaultDisputeGame rootClaim (means block is valid)
        proveStorageBytes32(
            abi.encodePacked(uint256(L2_FAULT_DISPUTE_GAME_ROOT_CLAIM_SLOT)),
            rootClaim,
            faultDisputeGameProofData.faultDisputeGameRootClaimStorageProof,
            bytes32(faultDisputeGameProofData.faultDisputeGameStateRoot)
        );

        // Assemble and verify game status
        bytes32 faultDisputeGameStatusStorage = assembleGameStatusStorage(
            faultDisputeGameProofData.faultDisputeGameStatusSlotData.createdAt,
            faultDisputeGameProofData.faultDisputeGameStatusSlotData.resolvedAt,
            faultDisputeGameProofData.faultDisputeGameStatusSlotData.gameStatus,
            faultDisputeGameProofData
                .faultDisputeGameStatusSlotData
                .initialized,
            faultDisputeGameProofData
                .faultDisputeGameStatusSlotData
                .l2BlockNumberChallenged
        );

        // Verify game status storage proof
        proveStorageBytes32(
            abi.encodePacked(uint256(L2_FAULT_DISPUTE_GAME_STATUS_SLOT)),
            faultDisputeGameStatusStorage,
            faultDisputeGameProofData.faultDisputeGameStatusStorageProof,
            bytes32(
                RLPReader.readBytes(
                    RLPReader.readList(
                        faultDisputeGameProofData.rlpEncodedFaultDisputeGameData
                    )[2]
                )
            )
        );

        // Verify game contract account proof
        proveAccount(
            abi.encodePacked(faultDisputeGameProxyAddress),
            faultDisputeGameProofData.rlpEncodedFaultDisputeGameData,
            faultDisputeGameProofData.faultDisputeGameAccountProof,
            l1WorldStateRoot
        );
    }

    /**
     * @notice Proves L2 world state using Cannon verification
     * @dev Verifies through fault dispute game resolution
     * @param chainId ID of destination chain
     * @param rlpEncodedBlockData RLP encoded block data
     * @param l2WorldStateRoot L2 state root to verify
     * @param disputeGameFactoryProofData Proof data for factory verification
     * @param faultDisputeGameProofData Proof data for game verification
     * @param l1WorldStateRoot Proven L1 world state root
     */
    function proveWorldStateCannon(
        uint256 chainId,
        bytes calldata rlpEncodedBlockData,
        bytes32 l2WorldStateRoot,
        DisputeGameFactoryProofData calldata disputeGameFactoryProofData,
        FaultDisputeGameProofData memory faultDisputeGameProofData,
        bytes32 l1WorldStateRoot
    )
        public
        validRLPEncodeBlock(
            rlpEncodedBlockData,
            disputeGameFactoryProofData.latestBlockHash
        )
    {
        ChainConfiguration memory chainConfiguration = chainConfigurations[
            chainId
        ];

        // Verify settlement chain state root
        BlockProof memory existingSettlementBlockProof = provenStates[
            chainConfiguration.settlementChainId
        ];
        if (existingSettlementBlockProof.stateRoot != l1WorldStateRoot) {
            revert SettlementChainStateRootNotProved(
                existingSettlementBlockProof.stateRoot,
                l1WorldStateRoot
            );
        }
        // prove that the FaultDisputeGame was created by the Dispute Game Factory

        // Verify dispute game creation and resolution
        bytes32 rootClaim;
        address faultDisputeGameProxyAddress;
        (
            faultDisputeGameProxyAddress,
            rootClaim
        ) = _faultDisputeGameFromFactory(
            chainConfiguration.settlementContract,
            l2WorldStateRoot,
            disputeGameFactoryProofData,
            l1WorldStateRoot
        );

        _faultDisputeGameIsResolved(
            rootClaim,
            faultDisputeGameProxyAddress,
            faultDisputeGameProofData,
            l1WorldStateRoot
        );

        // Update proven state if newer block
        BlockProof memory existingBlockProof = provenStates[chainId];
        BlockProof memory blockProof = BlockProof({
            blockNumber: _bytesToUint(
                RLPReader.readBytes(RLPReader.readList(rlpEncodedBlockData)[8])
            ),
            blockHash: keccak256(rlpEncodedBlockData),
            stateRoot: l2WorldStateRoot
        });

        if (existingBlockProof.blockNumber < blockProof.blockNumber) {
            provenStates[chainId] = blockProof;
            emit L2WorldStateProven(
                chainId,
                blockProof.blockNumber,
                blockProof.stateRoot
            );
        } else {
            if (existingBlockProof.blockNumber > blockProof.blockNumber) {
                revert OutdatedBlock(
                    blockProof.blockNumber,
                    existingBlockProof.blockNumber
                );
            }
        }
    }

    /**
     * @notice Proves an intent's execution on destination chain
     * @dev Verifies storage proof of intent fulfillment
     * @param chainId Destination chain ID
     * @param claimant Address eligible to claim rewards
     * @param inboxContract Inbox contract address
     * @param intermediateHash Partial intent hash
     * @param l2StorageProof Storage proof for intent mapping
     * @param rlpEncodedInboxData RLP encoded inbox contract data
     * @param l2AccountProof Account proof for inbox contract
     * @param l2WorldStateRoot L2 world state root
     */
    function proveIntent(
        uint256 chainId,
        address claimant,
        address inboxContract,
        bytes32 intermediateHash,
        bytes[] calldata l2StorageProof,
        bytes calldata rlpEncodedInboxData,
        bytes[] calldata l2AccountProof,
        bytes32 l2WorldStateRoot
    ) public {
        // Verify L2 state root is proven
        BlockProof memory existingBlockProof = provenStates[chainId];
        if (existingBlockProof.stateRoot != l2WorldStateRoot) {
            revert DestinationChainStateRootNotProved(
                existingBlockProof.stateRoot,
                l2WorldStateRoot
            );
        }

        // Calculate full intent hash
        bytes32 intentHash = keccak256(
            abi.encode(inboxContract, intermediateHash)
        );

        // Calculate storage slot for intent mapping
        bytes32 messageMappingSlot = keccak256(
            abi.encode(
                intentHash,
                1 // storage position of the intents mapping is the first slot
            )
        );

        // Verify inbox state root
        bytes memory inboxStateRoot = RLPReader.readBytes(
            RLPReader.readList(rlpEncodedInboxData)[2]
        );

        if (inboxStateRoot.length > 32) {
            revert IncorrectInboxStateRoot(inboxStateRoot);
        }

        // Verify storage proof for claimant mapping
        proveStorageBytes32(
            abi.encodePacked(messageMappingSlot),
            bytes32(uint256(uint160(claimant))),
            l2StorageProof,
            bytes32(inboxStateRoot)
        );

        // Verify inbox contract account proof
        proveAccount(
            abi.encodePacked(inboxContract),
            rlpEncodedInboxData,
            l2AccountProof,
            l2WorldStateRoot
        );

        // Record proven intent and emit event
        provenIntents[intentHash] = claimant;
        emit IntentProven(intentHash, claimant);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IL1Block} from "../interfaces/IL1Block.sol";

/// @custom:proxied
/// @custom:predeploy 0x4200000000000000000000000000000000000015
/// @title L1Block
/// @notice The L1Block predeploy gives users access to information about the last known L1 block.
///         Values within this contract are updated once per epoch (every L1 block) and can only be
///         set by the "depositor" account, a special system address. Depositor account transactions
///         are created by the protocol whenever we move to a new epoch.
contract MockL1Block {
    /// @notice The latest L1 block number known by the L2 system.
    uint64 public number;

    /// @notice The latest L1 timestamp known by the L2 system.
    uint64 public timestamp;

    /// @notice The latest L1 base fee.
    uint256 public basefee;

    /// @notice The latest L1 blockhash.
    bytes32 public hash;

    /// @notice The number of L2 blocks in the same epoch.
    uint64 public sequenceNumber;

    /// @notice The scalar value applied to the L1 blob base fee portion of the blob-capable L1 cost func.
    uint32 public blobBaseFeeScalar;

    /// @notice The scalar value applied to the L1 base fee portion of the blob-capable L1 cost func.
    uint32 public baseFeeScalar;

    /// @notice The versioned hash to authenticate the batcher by.
    bytes32 public batcherHash;

    /// @notice The overhead value applied to the L1 portion of the transaction fee.
    /// @custom:legacy
    uint256 public l1FeeOverhead;

    /// @notice The scalar value applied to the L1 portion of the transaction fee.
    /// @custom:legacy
    uint256 public l1FeeScalar;

    /// @notice The latest L1 blob base fee.
    uint256 public blobBaseFee;

    /// @custom:legacy
    /// @notice Updates the L1 block values.
    /// @param _number         L1 blocknumber.
    /// @param _timestamp      L1 timestamp.
    /// @param _basefee        L1 basefee.
    /// @param _hash           L1 blockhash.
    /// @param _sequenceNumber Number of L2 blocks since epoch start.
    /// @param _batcherHash    Versioned hash to authenticate batcher by.
    /// @param _l1FeeOverhead  L1 fee overhead.
    /// @param _l1FeeScalar    L1 fee scalar.
    function setL1BlockValues(
        uint64 _number,
        uint64 _timestamp,
        uint256 _basefee,
        bytes32 _hash,
        uint64 _sequenceNumber,
        bytes32 _batcherHash,
        uint256 _l1FeeOverhead,
        uint256 _l1FeeScalar
    ) external {
        number = _number;
        timestamp = _timestamp;
        basefee = _basefee;
        hash = _hash;
        sequenceNumber = _sequenceNumber;
        batcherHash = _batcherHash;
        l1FeeOverhead = _l1FeeOverhead;
        l1FeeScalar = _l1FeeScalar;
    }
}
/* -*- c-basic-offset: 4 -*- */
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TestERC20 is ERC20 {
    constructor(
        string memory name_,
        string memory symbol_
    ) ERC20(name_, symbol_) {}

    function mint(address recipient, uint256 amount) public {
        _mint(recipient, amount);
    }
}
/* -*- c-basic-offset: 4 -*- */
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;
import "@hyperlane-xyz/core/contracts/libs/Message.sol";
import "@hyperlane-xyz/core/contracts/interfaces/IMessageRecipient.sol";
import "@hyperlane-xyz/core/contracts/libs/TypeCasts.sol";
import "@hyperlane-xyz/core/contracts/interfaces/hooks/IPostDispatchHook.sol";

contract TestMailbox {
    using TypeCasts for bytes32;
    using TypeCasts for address;

    address public processor;

    uint32 public destinationDomain;

    bytes32 public recipientAddress;

    bytes public messageBody;

    bytes public metadata;

    address public relayer;

    bool public dispatched;

    bool public dispatchedWithRelayer;

    uint256 public constant fee = 100000;

    constructor(address _processor) {
        processor = _processor;
    }

    function dispatch(
        uint32 _destinationDomain,
        bytes32 _recipientAddress,
        bytes calldata _messageBody
    ) public payable returns (uint256) {
        destinationDomain = _destinationDomain;
        recipientAddress = _recipientAddress;
        messageBody = _messageBody;
        dispatched = true;

        if (processor != address(0)) {
            process(_messageBody);
        }

        if (msg.value < fee) {
            revert("no");
        }

        return (msg.value);
    }

    function dispatch(
        uint32 _destinationDomain,
        bytes32 _recipientAddress,
        bytes calldata _messageBody,
        bytes calldata _metadata,
        IPostDispatchHook _relayer
    ) public payable returns (uint256) {
        destinationDomain = _destinationDomain;
        recipientAddress = _recipientAddress;
        messageBody = _messageBody;
        metadata = _metadata;
        relayer = address(_relayer);

        dispatchedWithRelayer = true;

        if (processor != address(0)) {
            process(_messageBody);
        }

        if (msg.value < fee) {
            revert("no");
        }

        return (msg.value);
    }

    function process(bytes calldata _msg) public {
        IMessageRecipient(recipientAddress.bytes32ToAddress()).handle(
            uint32(block.chainid),
            msg.sender.addressToBytes32(),
            _msg
        );
    }

    function quoteDispatch(
        uint32,
        bytes32,
        bytes calldata
    ) public pure returns (bytes32) {
        return bytes32(fee);
    }

    function quoteDispatch(
        uint32,
        bytes32,
        bytes calldata,
        bytes calldata,
        address
    ) public pure returns (bytes32) {
        return bytes32(fee);
    }
}
/* -*- c-basic-offset: 4 -*- */
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "../prover/BaseProver.sol";

contract TestProver is BaseProver {
    function version() external pure returns (string memory) { return "1.9.13-a72f02f"; }

    function addProvenIntent(bytes32 _hash, address _claimant) public {
        provenIntents[_hash] = _claimant;
    }

    function getProofType() external pure override returns (ProofType) {
        return ProofType.Storage;
    }
}
// SPDX-License-Identifier: MIT
// from cupeyes/deployer
pragma solidity ^0.8.26; //initially ^0.6.0

interface IDeployer {
    function deploy(
        bytes memory _initCode,
        bytes32 _salt
    ) external returns (address payable createdContract);
}

contract Deployer {
    IDeployer public immutable deployer;

    constructor(IDeployer _deployer) {
        // Use EIP-2470 SingletonFactory address by default
        deployer = address(_deployer) == address(0)
            ? IDeployer(0xce0042B868300000d44A59004Da54A005ffdcf9f)
            : _deployer;
        emit Deployed(tx.origin, address(this));
    }

    event Deployed(address indexed sender, address indexed addr);

    function deploy(
        bytes memory _initCode,
        bytes32 _salt
    ) external returns (address payable createdContract) {
        createdContract = deployer.deploy(_initCode, _salt);
        require(createdContract != address(0), "Deploy failed");
        emit Deployed(msg.sender, createdContract);
    }
}
// SPDX-License-Identifier: MIT
// EIP-2470
pragma solidity ^0.8.26; // originally 0.6.2

/**
 * @title Singleton Factory (EIP-2470)
 * @notice Exposes CREATE2 (EIP-1014) to deploy bytecode on deterministic addresses based on initialization code and salt.
 * @author Ricardo Guilherme Schmidt (Status Research & Development GmbH)
 */
contract SingletonFactory {
    /**
     * @notice Deploys `_initCode` using `_salt` for defining the deterministic address.
     * @param _initCode Initialization code.
     * @param _salt Arbitrary value to modify resulting address.
     * @return createdContract Created contract address.
     */
    function deploy(
        bytes memory _initCode,
        bytes32 _salt
    ) public returns (address payable createdContract) {
        assembly {
            createdContract := create2(
                0,
                add(_initCode, 0x20),
                mload(_initCode),
                _salt
            )
        }
    }
}
// IV is a value changed to generate the vanity address.
// IV: 6583047
/* -*- c-basic-offset: 4 -*- */
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title GaslessCrossChainOrder CrossChainOrder type
 * @notice Standard order struct to be signed by users, disseminated to fillers, and submitted to origin settler contracts
 * @param originSettler The contract address that the order is meant to be settled by
 * Fillers send this order to this contract address on the origin chain
 * @param user The address of the user who is initiating the swap whose input tokens will be taken and escrowed
 * @param nonce Nonce to be used as replay protection for the order
 * @param originChainId The chainId of the origin chain
 * @param openDeadline The timestamp by which the order must be opened
 * @param fillDeadline The timestamp by which the order must be filled on the destination chain
 * @param orderDataType Type identifier for the order data. This is an EIP-712 typehash
 * @param orderData Arbitrary implementation-specific data
 * Can be used to define tokens, amounts, destination chains, fees, settlement parameters,
 * or any other order-type specific information
 */
struct GaslessCrossChainOrder {
    address originSettler;
    address user;
    uint256 nonce;
    uint256 originChainId;
    uint32 openDeadline;
    uint32 fillDeadline;
    bytes32 orderDataType;
    bytes orderData;
}
/**
 * @title OnchainCrossChainOrder CrossChainOrder type
 * @notice Standard order struct for user-opened orders, where the user is the msg.sender.
 * @param fillDeadline The timestamp by which the order must be filled on the destination chain
 * @param orderDataType Type identifier for the order data. This is an EIP-712 typehash
 * @param orderData Arbitrary implementation-specific data
 * Can be used to define tokens, amounts, destination chains, fees, settlement parameters,
 * or any other order-type specific information
 */
struct OnchainCrossChainOrder {
    uint32 fillDeadline;
    bytes32 orderDataType;
    bytes orderData;
}

/**
 * @title ResolvedCrossChainOrder type
 * @notice An implementation-generic representation of an order intended for filler consumption
 * @dev Defines all requirements for filling an order by unbundling the implementation-specific orderData.
 * @dev Intended to improve integration generalization by allowing fillers to compute the exact input and output information of any order
 * @param user The address of the user who is initiating the transfer
 * @param originChainId The chainId of the origin chain
 * @param openDeadline The timestamp by which the order must be opened
 * @param fillDeadline The timestamp by which the order must be filled on the destination chain(s)
 * @param orderId The unique identifier for this order within this settlement system
 * @param maxSpent The max outputs that the filler will send. It's possible the actual amount depends on the state of the destination
 * chain (destination dutch auction, for instance), so these outputs should be considered a cap on filler liabilities.
 * @param minReceived The minimum outputs that must be given to the filler as part of order settlement. Similar to maxSpent, it's possible
 * that special order types may not be able to guarantee the exact amount at open time, so this should be considered
 * a floor on filler receipts. Setting the `recipient` of an `Output` to address(0) indicates that the filler is not
 * known when creating this order.
 * @param fillInstructions Each instruction in this array is parameterizes a single leg of the fill. This provides the filler with the information
 * necessary to perform the fill on the destination(s).
 */
struct ResolvedCrossChainOrder {
    address user;
    uint256 originChainId;
    uint32 openDeadline;
    uint32 fillDeadline;
    bytes32 orderId;
    Output[] maxSpent;
    Output[] minReceived;
    FillInstruction[] fillInstructions;
}

/**
 * @title Output type
 * @notice Tokens that must be received for a valid order fulfillment
 * @param token The address of the ERC20 token on the destination chain
 * address(0) used as a sentinel for the native token
 * @param amount The amount of the token to be sent
 * @param recipient The address to receive the output tokens
 * @param chainId The destination chain for this output
 */
struct Output {
    bytes32 token;
    uint256 amount;
    bytes32 recipient;
    uint256 chainId;
}

/**
 * @title FillInstruction type
 * @notice Instructions to parameterize each leg of the fill
 * @dev Provides all the origin-generated information required to produce a valid fill leg
 * @param destinationChainId The chain ID that the order is meant to be settled by
 * @param destinationSettler The contract address that the order is meant to be filled on
 * @param originData The data generated on the origin chain needed by the destinationSettler to process the fill
 */
struct FillInstruction {
    uint64 destinationChainId;
    bytes32 destinationSettler;
    bytes originData;
}
/* -*- c-basic-offset: 4 -*- */
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {TokenAmount, Route, Call} from "./Intent.sol";
/**
 * @title EcoERC7683
 * @dev ERC7683 orderData subtypes designed for Eco Protocol
 */

/**
 * @notice contains everything which, when combined with other aspects of GaslessCrossChainOrder
 * is sufficient to publish an intent via Eco Protocol
 * @dev the orderData field of GaslessCrossChainOrder should be decoded as GaslessCrosschainOrderData\
 * @param route the route data
 * @param creator the address of the intent creator
 * @param prover the address of the prover contract this intent will be proven against
 * @param nativeValue the amount of native token offered as a reward
 * @param tokens the addresses and amounts of reward tokens
 */
struct OnchainCrosschainOrderData {
    Route route;
    address creator;
    address prover;
    uint256 nativeValue;
    TokenAmount[] rewardTokens;
}
/**
 * @notice contains everything which, when combined with other aspects of GaslessCrossChainOrder
 * is sufficient to publish an intent via Eco Protocol
 * @dev the orderData field of GaslessCrossChainOrder should be decoded as GaslessCrosschainOrderData
 * @param destination the ID of the chain where the intent was created
 * @param inbox the inbox contract on the destination chain that will fulfill the intent
 * @param calls the call instructions to be called during intent fulfillment
 * @param prover the address of the prover contract this intent will be proven against
 * @param nativeValue the amount of native token offered as a reward
 * @param tokens the addresses and amounts of reward tokens
 */
struct GaslessCrosschainOrderData {
    uint256 destination;
    address inbox;
    TokenAmount[] routeTokens;
    Call[] calls;
    address prover;
    uint256 nativeValue;
    TokenAmount[] rewardTokens;
}

//EIP712 typehashes
bytes32 constant ONCHAIN_CROSSCHAIN_ORDER_DATA_TYPEHASH = keccak256(
    "EcoOnchainGaslessCrosschainOrderData(Route route,address creator,address prover,uint256 nativeValue,TokenAmount[] tokens)Route(uint256 source,uint256 destination,address inbox,Call[] calls)TokenAmount(address token,uint256 amount)Call(address target,bytes data,uint256 value)"
);
bytes32 constant GASLESS_CROSSCHAIN_ORDER_DATA_TYPEHASH = keccak256(
    "EcoGaslessCrosschainOrderData(uint256 destination,address inbox,Call[] calls,address prover,uint256 nativeValue,TokenAmount[] tokens)TokenAmount(address token,uint256 amount)Call(address target,bytes data,uint256 value)"
);
/* -*- c-basic-offset: 4 -*- */
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @notice Represents a single contract call with encoded function data
 * @dev Used to execute arbitrary function calls on the destination chain
 * @param target The contract address to call
 * @param data ABI-encoded function call data
 * @param value Amount of native tokens to send with the call
 */
struct Call {
    address target;
    bytes data;
    uint256 value;
}

/**
 * @notice Represents a token amount pair
 * @dev Used to specify token rewards and transfers
 * @param token Address of the ERC20 token contract
 * @param amount Amount of tokens in the token's smallest unit
 */
struct TokenAmount {
    address token;
    uint256 amount;
}

/**
 * @notice Defines the routing and execution instructions for cross-chain messages
 * @dev Contains all necessary information to route and execute a message on the destination chain
 * @param salt Unique identifier provided by the intent creator, used to prevent duplicates
 * @param source Chain ID where the intent originated
 * @param destination Target chain ID where the calls should be executed
 * @param inbox Address of the inbox contract on the destination chain that receives messages
 * @param tokens Array of tokens required for execution of calls on destination chain
 * @param calls Array of contract calls to execute on the destination chain in sequence
 */
struct Route {
    bytes32 salt;
    uint256 source;
    uint256 destination;
    address inbox;
    TokenAmount[] tokens;
    Call[] calls;
}

/**
 * @notice Defines the reward and validation parameters for cross-chain execution
 * @dev Specifies who can execute the intent and what rewards they receive
 * @param creator Address that created the intent and has authority to modify/cancel
 * @param prover Address of the prover contract that must approve execution
 * @param deadline Timestamp after which the intent can no longer be executed
 * @param nativeValue Amount of native tokens offered as reward
 * @param tokens Array of ERC20 tokens and amounts offered as additional rewards
 */
struct Reward {
    address creator;
    address prover;
    uint256 deadline;
    uint256 nativeValue;
    TokenAmount[] tokens;
}

/**
 * @notice Complete cross-chain intent combining routing and reward information
 * @dev Main structure used to process and execute cross-chain messages
 * @param route Routing and execution instructions
 * @param reward Reward and validation parameters
 */
struct Intent {
    Route route;
    Reward reward;
}