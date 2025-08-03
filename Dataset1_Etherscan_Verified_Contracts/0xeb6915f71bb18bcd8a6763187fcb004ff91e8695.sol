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
// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.20;

library Data {
    struct ExtraProofData {
        bytes leaf;
        bytes32 hashedLeaf;
        uint position;
        bytes32 extraRoot;
        bytes32[] extraMerkleProofs;
    }

    struct Proof {
        bytes32 leaf;
        uint position;
        bytes32[] merkleProofs;
    }
}
// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.20;

interface IValidator {
    function isValidSignatures(bytes32 hash, bytes[] memory signatures, address[] memory signers) external view returns (bool);

    function isValidator(address _addr) external view returns (bool);
}
// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.20;

// Interfaces
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// Internal libraries
import "./utils/cryptography/Hash.sol";
import "./utils/cryptography/MerkleProof.sol";
import "./Data.sol";

library Postchain {
    using MerkleProof for bytes32[];

    struct Event {
        uint256 serialNumber;
        uint256 networkId;
        IERC20 token;
        address beneficiary;
        uint256 amount;
    }

    struct BlockHeaderData {
        bytes32 blockchainRid;
        bytes32 blockRid;
        bytes32 previousBlockRid;
        bytes32 merkleRootHashHashedLeaf;
        uint timestamp;
        uint height;
        bytes32 dependenciesHashedLeaf;
        bytes32 extraDataHashedLeaf;
    }

    function verifyEvent(bytes32 _hash, bytes memory _event) internal pure returns (IERC20, address, uint256, uint256) {
        Event memory evt = abi.decode(_event, (Event));
        bytes32 hash = keccak256(_event);
        if (hash != _hash) {
            revert("Postchain: invalid event");
        }
        return (evt.token, evt.beneficiary, evt.amount, evt.networkId);
    }

    function verifyBlockHeader(
        bytes32 blockchainRid,
        bytes memory blockHeader,
        Data.ExtraProofData memory proof
    ) internal pure returns (uint, bytes32) {
        BlockHeaderData memory header = decodeBlockHeader(blockHeader);
        if (blockchainRid != header.blockchainRid) revert("Postchain: invalid blockchain rid");
        require(proof.extraRoot == header.extraDataHashedLeaf, "Postchain: invalid extra data root");
        if (!proof.extraMerkleProofs.verifySHA256(proof.hashedLeaf, proof.position, proof.extraRoot)) {
            revert("Postchain: invalid extra merkle proof");
        }
        return (header.height, header.blockRid);
    }

    function decodeBlockHeader(
        bytes memory blockHeader
    ) internal pure returns (BlockHeaderData memory) {
        BlockHeaderData memory header = abi.decode(blockHeader, (BlockHeaderData));

        bytes32 node12 = sha256(
            abi.encodePacked(
                uint8(0x00),
                Hash.hashGtvBytes32Leaf(header.blockchainRid),
                Hash.hashGtvBytes32Leaf(header.previousBlockRid)
            )
        );

        bytes32 node34 = sha256(
            abi.encodePacked(uint8(0x00), header.merkleRootHashHashedLeaf, Hash.hashGtvIntegerLeaf(header.timestamp))
        );

        bytes32 node56 = sha256(
            abi.encodePacked(uint8(0x00), Hash.hashGtvIntegerLeaf(header.height), header.dependenciesHashedLeaf)
        );

        bytes32 node1234 = sha256(abi.encodePacked(uint8(0x00), node12, node34));

        bytes32 node5678 = sha256(abi.encodePacked(uint8(0x00), node56, header.extraDataHashedLeaf));

        bytes32 blockRid = sha256(
            abi.encodePacked(
                uint8(0x7), // Gtv merkle tree Array Root Node prefix
                node1234,
                node5678
            )
        );

        if (blockRid != header.blockRid) revert("Postchain: invalid block header");
        return header;
    }

}
// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.20;

// Internal libraries
import "../Postchain.sol";
import "../IValidator.sol";

contract Anchoring {
    IValidator public validator;

    uint public lastAnchoredHeight = 0;
    bytes32 public lastAnchoredBlockRid;
    bytes32 public systemAnchoringBlockchainRid;

    event AnchoredBlock(Postchain.BlockHeaderData blockHeader);

    constructor(IValidator _validator, bytes32 _systemAnchoringBlockchainRid) {
        validator = _validator;
        systemAnchoringBlockchainRid = _systemAnchoringBlockchainRid;
    }

    function anchorBlock(bytes memory blockHeaderRawData, bytes[] memory signatures, address[] memory signers) public {
        Postchain.BlockHeaderData memory blockHeaderData = Postchain.decodeBlockHeader(blockHeaderRawData);

        if (blockHeaderData.blockchainRid != systemAnchoringBlockchainRid) revert("Anchoring: block is not from system anchoring chain");
        if (lastAnchoredHeight > 0 && blockHeaderData.height <= lastAnchoredHeight) revert("Anchoring: height is lower than or equal to previously anchored height");
        if (!validator.isValidSignatures(blockHeaderData.blockRid, signatures, signers)) revert("Anchoring: block signature is invalid");

        lastAnchoredHeight = blockHeaderData.height;
        lastAnchoredBlockRid = blockHeaderData.blockRid;
        emit AnchoredBlock(blockHeaderData);
    }

    /**
     * Provides an atomic read of both height and hash
     */
    function getLastAnchoredBlock() public view returns (uint, bytes32) {
        return (lastAnchoredHeight, lastAnchoredBlockRid);
    }
}
// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.20;

library Hash {

    function hash(bytes32 left, bytes32 right) internal pure returns (bytes32) {
        if (left == 0x0 && right == 0x0) {
            return 0x0;
        } else if (left == 0x0) {
            return keccak256(abi.encodePacked(right));
        } else if (right == 0x0) {
            return keccak256(abi.encodePacked(left));
        } else {
            return keccak256(abi.encodePacked(left, right));
        }
    }

    function hashGtvBytes32Leaf(bytes32 value) internal pure returns (bytes32) {
        return sha256(abi.encodePacked(
                uint8(0x1),  // Gtv merkle tree leaf prefix
                uint8(0xA1), // // Gtv ByteArray tag: CONTEXT_CLASS, CONSTRUCTED, 1
                uint8(32 + 2),
                uint8(0x4), // DER ByteArray tag
                uint8(32),
                value
        ));
    }

    function hashGtvBytes64Leaf(bytes memory value) internal pure returns (bytes32) {
        if (value.length != 64) {
            revert("Hash: value must be 64 bytes long");
        }
        return sha256(abi.encodePacked(
                uint8(0x1),  // Gtv merkle tree leaf prefix
                uint8(0xA1), // // Gtv ByteArray tag: CONTEXT_CLASS, CONSTRUCTED, 1
                uint8(64 + 2),
                uint8(0x4), // DER ByteArray tag
                uint8(64),
                value
        ));
    }

    function hashGtvIntegerLeaf(uint value) internal pure returns (bytes32) {
        uint8 nbytes = 1;
        uint remainingValue = value >> 8; // minimal length is 1 so we skip the first byte
        while (remainingValue > 0) {
            nbytes += 1;
            remainingValue = remainingValue >> 8;
        }
        bytes memory b = new bytes(nbytes);
        remainingValue = value;
        for (uint8 i = 1; i <= nbytes; i++) {
            uint8 v = uint8(remainingValue & 0xFF);
            b[nbytes - i] = bytes1(v);
            remainingValue = remainingValue >> 8;
        }

        if (uint8(b[0]) & 0x80 > 0) {
            return sha256(abi.encodePacked(
                uint8(0x1),  // Gtv merkle tree leaf prefix
                uint8(0xA3), // GtvInteger tag: CONTEXT_CLASS, CONSTRUCTED, 3
                uint8(nbytes + 3),
                uint8(0x2), // DER integer tag
                nbytes+1,
                uint8(0),
                b
            ));
        } 

        return sha256(abi.encodePacked(
                uint8(0x1),  // Gtv merkle tree leaf prefix
                uint8(0xA3), // GtvInteger tag: CONTEXT_CLASS, CONSTRUCTED, 3
                uint8(nbytes + 2),
                uint8(0x2), // DER integer tag
                nbytes,
                b
            ));
    }

}
// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.20;

import "./Hash.sol";

library MerkleProof {
    /**
     * @dev verify merkle proof using keccak256
     */
    function verify(bytes32[] memory proofs, bytes32 leaf, uint position, bytes32 rootHash) internal pure returns (bool) {
        if (leaf == 0x0 || position >= (1 << proofs.length)) {
            return false;
        }
        bytes32 r = leaf;
        for (uint i = 0; i < proofs.length; i++) {
            uint b = position & (1 << i);
            if (b == 0) {
                r = Hash.hash(r, proofs[i]);
            } else {
                r = Hash.hash(proofs[i], r);
            }
        }
        return (r == rootHash);
    }

    /**
     * @dev verify merkle proof using sha256
     * specific for postchain block header extra data in dictionary data format
     */
    function verifySHA256(bytes32[] memory proofs, bytes32 leaf, uint position, bytes32 rootHash) internal pure returns (bool) {
        if (position >= (1 << proofs.length)) {
            return false;
        }
        bytes32 r = leaf; // hashed leaf
        uint last = proofs.length-1;
        for (uint i = 0; i < last; i++) {
            uint b = position & (1 << i);
            if (b == 0) {
                r = sha256(abi.encodePacked(uint8(0x00), r, proofs[i]));
            } else {
                r = sha256(abi.encodePacked(uint8(0x00), proofs[i], r));
            }
        }
        // the last node is fixed in dictionary format, prefix = 0x8
        uint p = position & (1 << last);
        if (p == 0) {
            r = sha256(abi.encodePacked(uint8(0x08), r, proofs[last]));
        } else {
            r = sha256(abi.encodePacked(uint8(0x08), proofs[last], r));
        }
        return (r == rootHash);
    }
}