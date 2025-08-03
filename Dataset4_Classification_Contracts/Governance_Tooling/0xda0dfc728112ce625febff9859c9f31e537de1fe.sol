// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
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
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
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
// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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
// OpenZeppelin Contracts (last updated v4.9.2) (utils/cryptography/MerkleProof.sol)

pragma solidity ^0.8.0;

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
library MerkleProof {
    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     */
    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    /**
     * @dev Calldata version of {verify}
     *
     * _Available since v4.7._
     */
    function verifyCalldata(bytes32[] calldata proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        return processProofCalldata(proof, leaf) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merkle tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leafs & pre-images are assumed to be sorted.
     *
     * _Available since v4.4._
     */
    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Calldata version of {processProof}
     *
     * _Available since v4.7._
     */
    function processProofCalldata(bytes32[] calldata proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Returns true if the `leaves` can be simultaneously proven to be a part of a merkle tree defined by
     * `root`, according to `proof` and `proofFlags` as described in {processMultiProof}.
     *
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
     */
    function multiProofVerify(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) internal pure returns (bool) {
        return processMultiProof(proof, proofFlags, leaves) == root;
    }

    /**
     * @dev Calldata version of {multiProofVerify}
     *
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
     */
    function multiProofVerifyCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) internal pure returns (bool) {
        return processMultiProofCalldata(proof, proofFlags, leaves) == root;
    }

    /**
     * @dev Returns the root of a tree reconstructed from `leaves` and sibling nodes in `proof`. The reconstruction
     * proceeds by incrementally reconstructing all inner nodes by combining a leaf/inner node with either another
     * leaf/inner node or a proof sibling node, depending on whether each `proofFlags` item is true or false
     * respectively.
     *
     * CAUTION: Not all merkle trees admit multiproofs. To use multiproofs, it is sufficient to ensure that: 1) the tree
     * is complete (but not necessarily perfect), 2) the leaves to be proven are in the opposite order they are in the
     * tree (i.e., as seen from right to left starting at the deepest layer and continuing at the next layer).
     *
     * _Available since v4.7._
     */
    function processMultiProof(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuilds the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 proofLen = proof.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        require(leavesLen + proofLen - 1 == totalHashes, "MerkleProof: invalid multiproof");

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value from the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i]
                ? (leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++])
                : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            require(proofPos == proofLen, "MerkleProof: invalid multiproof");
            unchecked {
                return hashes[totalHashes - 1];
            }
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    /**
     * @dev Calldata version of {processMultiProof}.
     *
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
     */
    function processMultiProofCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuilds the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 proofLen = proof.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        require(leavesLen + proofLen - 1 == totalHashes, "MerkleProof: invalid multiproof");

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value from the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i]
                ? (leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++])
                : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            require(proofPos == proofLen, "MerkleProof: invalid multiproof");
            unchecked {
                return hashes[totalHashes - 1];
            }
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {
        return a < b ? _efficientHash(a, b) : _efficientHash(b, a);
    }

    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

// import "hardhat/console.sol";

interface IWondersToken {
    function isApprovedForAll(address owner, address operator) external;

    function safeTransferFrom(address from, address to, uint256 id) external;
}

interface IBox {
    function mint(address to, uint256 quantity) external;

    function totalMinted() external view returns (uint256);

    function maxSupply() external view returns (uint256);
}

interface IBPX {
    function balanceOf(address _owner) external view returns (uint256 balance);

    function allowance(
        address _owner,
        address _spender
    ) external view returns (uint256 remaining);

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success);
}

struct Config {
    bool enabled;
    uint128 start;
    uint128 end;
    bytes32 merkleRoot;
    uint16 earnedPerWonder;
    //
    uint256 ethBoxPrice;
    uint256 bpxBoxPrice;
}

contract Claim is Ownable, ReentrancyGuard {
    address public wondersToken;
    address public boxesToken;
    address public bpxToken;
    address public banker;

    mapping(address => uint64) private _boxesEarned;
    mapping(address => uint64) private _allowlistBoxesMinted;
    mapping(address => uint64) private _wondersClaimed;

    uint256 private _nextWonderID = 0;
    uint256 private _maxWonderID = 5000;

    Config private _cfg;

    function setWondersTokenAddress(address addr) public onlyOwner {
        wondersToken = addr;
    }

    function setBoxesTokenAddress(address addr) public onlyOwner {
        boxesToken = addr;
    }

    function setBPXTokenAddress(address addr) public onlyOwner {
        bpxToken = addr;
    }

    function setBankerAddress(address addr) public onlyOwner {
        banker = addr;
    }

    function setClaimEnabled(bool v) public onlyOwner {
        _cfg.enabled = v;
    }

    function setClaimConfig(
        uint128 start,
        uint128 end,
        bytes32 root,
        uint16 earnedBoxesPerWonder
    ) public onlyOwner {
        _cfg.start = start;
        _cfg.end = end;
        _cfg.merkleRoot = root;
        _cfg.earnedPerWonder = earnedBoxesPerWonder;
    }

    function setBoxPrices(uint256 ethPrice, uint256 bpxPrice) public onlyOwner {
        _cfg.ethBoxPrice = ethPrice;
        _cfg.bpxBoxPrice = bpxPrice;
    }

    function setMaxTokenID(uint256 max) public onlyOwner {
        _maxWonderID = max;
    }

    function config() public view returns (Config memory) {
        return _cfg;
    }

    function wondersClaimed(address owner) public view returns (uint64) {
        return _wondersClaimed[owner];
    }

    function earnedBoxes(address dest) public view returns (uint64) {
        return _boxesEarned[dest];
    }

    function nextWonderID() public view returns (uint256) {
        return _nextWonderID;
    }

    function devclaim(address dest, uint256 wonders) public onlyOwner {
        require(
            _nextWonderID + wonders <= _maxWonderID,
            "Claim exceeds supply."
        );

        for (uint256 i = 0; i < wonders; i++) {
            IWondersToken(wondersToken).safeTransferFrom(
                wondersToken,
                dest,
                _nextWonderID + i
            );
        }

        _nextWonderID += wonders;
    }

    function claim(
        address dest,
        uint64 wonders,
        uint64 limit,
        bytes32[] calldata proof
    ) public {
        return claimWithBoxes(dest, wonders, 0, limit, proof);
    }

    function claimWithBoxes(
        address dest,
        uint64 wonders,
        uint64 boxes,
        uint64 limit,
        bytes32[] calldata proof
    ) public payable nonReentrant {
        require(_cfg.enabled, "Claim is not active.");
        require(
            block.timestamp >= _cfg.start && block.timestamp < _cfg.end,
            "Claim window is not open."
        );
        require(wonders <= 20, "Can only claim up to 20 at a time.");
        require(
            _nextWonderID + wonders <= _maxWonderID,
            "Claim exceeds supply."
        );

        bytes32 leaf = keccak256(abi.encodePacked(dest, limit));
        require(
            MerkleProof.verify(proof, _cfg.merkleRoot, leaf),
            "Address not on allowlist."
        );
        require(
            wonders + _wondersClaimed[dest] <= limit,
            "Claim exceeds limit."
        );

        uint64 boxesEarned = uint64(wonders) * _cfg.earnedPerWonder;
        if (boxes > 0) {
            IBox boxesContract = IBox(boxesToken);

            require(
                _boxesEarned[dest] + boxesEarned >= boxes,
                "Not enough boxes earned."
            );

            validateAndAcceptPayment(boxes);

            boxesContract.mint(dest, boxes);
        }

        if (boxesEarned != boxes) {
            _boxesEarned[dest] = uint64(
                int64(_boxesEarned[dest]) + int64(boxesEarned) - int64(boxes)
            );
        }

        _wondersClaimed[dest] += wonders;
        for (uint256 i = 0; i < wonders; i++) {
            IWondersToken(wondersToken).safeTransferFrom(
                wondersToken,
                dest,
                _nextWonderID + i
            );
        }

        _nextWonderID += wonders;
    }

    function buyEarnedBoxes(
        address dest,
        uint16 boxes
    ) public payable nonReentrant {
        IBox boxesContract = IBox(boxesToken);

        require(_cfg.enabled, "Claim is not active.");
        require(
            block.timestamp >= _cfg.start && block.timestamp < _cfg.end,
            "Claim window is not open."
        );

        require(boxes > 0, "Must buy at least one box.");

        require(_boxesEarned[dest] >= boxes, "Not enough boxes earned.");

        validateAndAcceptPayment(boxes);

        _boxesEarned[dest] -= boxes;

        boxesContract.mint(dest, boxes);
    }

    receive() external payable {}

    function validateAndAcceptPayment(uint64 boxes) internal {
        IBPX bpxContract = IBPX(bpxToken);

        if (msg.value > 0) {
            require(
                msg.value == boxes * _cfg.ethBoxPrice,
                "Invalid ETH amount sent."
            );
        } else {
            require(
                bpxContract.balanceOf(_msgSender()) >= boxes * _cfg.bpxBoxPrice,
                "Not enough BPX."
            );
            require(
                bpxContract.allowance(_msgSender(), address(this)) >=
                    boxes * _cfg.bpxBoxPrice,
                "Not enough BPX allowed."
            );
        }

        if (msg.value > 0) {
            (bool sent, ) = banker.call{value: msg.value}("");
            require(sent, "ETH not sent.");
        } else {
            bpxContract.transferFrom(
                _msgSender(),
                banker,
                boxes * _cfg.bpxBoxPrice
            );
        }
    }
}