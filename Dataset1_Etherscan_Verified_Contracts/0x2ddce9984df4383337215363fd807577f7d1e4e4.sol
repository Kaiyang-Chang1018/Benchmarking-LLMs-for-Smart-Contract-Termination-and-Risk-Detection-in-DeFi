// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
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
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.2) (utils/cryptography/MerkleProof.sol)

pragma solidity ^0.8.20;

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
 * the Merkle tree could be reinterpreted as a leaf value.
 * OpenZeppelin's JavaScript library generates Merkle trees that are safe
 * against this attack out of the box.
 */
library MerkleProof {
    /**
     *@dev The multiproof provided is not valid.
     */
    error MerkleProofInvalidMultiproof();

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
     */
    function verifyCalldata(bytes32[] calldata proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        return processProofCalldata(proof, leaf) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merkle tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leafs & pre-images are assumed to be sorted.
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
     */
    function processProofCalldata(bytes32[] calldata proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Returns true if the `leaves` can be simultaneously proven to be a part of a Merkle tree defined by
     * `root`, according to `proof` and `proofFlags` as described in {processMultiProof}.
     *
     * CAUTION: Not all Merkle trees admit multiproofs. See {processMultiProof} for details.
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
     * CAUTION: Not all Merkle trees admit multiproofs. See {processMultiProof} for details.
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
     * CAUTION: Not all Merkle trees admit multiproofs. To use multiproofs, it is sufficient to ensure that: 1) the tree
     * is complete (but not necessarily perfect), 2) the leaves to be proven are in the opposite order they are in the
     * tree (i.e., as seen from right to left starting at the deepest layer and continuing at the next layer).
     */
    function processMultiProof(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuilds the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the Merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 proofLen = proof.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        if (leavesLen + proofLen != totalHashes + 1) {
            revert MerkleProofInvalidMultiproof();
        }

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
            if (proofPos != proofLen) {
                revert MerkleProofInvalidMultiproof();
            }
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
     * CAUTION: Not all Merkle trees admit multiproofs. See {processMultiProof} for details.
     */
    function processMultiProofCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuilds the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the Merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 proofLen = proof.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        if (leavesLen + proofLen != totalHashes + 1) {
            revert MerkleProofInvalidMultiproof();
        }

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
            if (proofPos != proofLen) {
                revert MerkleProofInvalidMultiproof();
            }
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
     * @dev Sorts the pair (a, b) and hashes the result.
     */
    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {
        return a < b ? _efficientHash(a, b) : _efficientHash(b, a);
    }

    /**
     * @dev Implementation of keccak256(abi.encode(a, b)) that doesn't allocate or expand memory.
     */
    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}
// * ————————————————————————————————————————————————————————————————————————————————— *
// |                                                                                   |
// |    SSSSS K    K EEEEEE L      EEEEEE PPPPP  H    H U    U N     N K    K  SSSSS   |
// |   S      K   K  E      L      E      P    P H    H U    U N N   N K   K  S        |
// |    SSSS  KKKK   EEE    L      EEE    PPPPP  HHHHHH U    U N  N  N KKKK    SSSS    |
// |        S K   K  E      L      E      P      H    H U    U N   N N K   K       S   |
// |   SSSSS  K    K EEEEEE LLLLLL EEEEEE P      H    H  UUUU  N     N K    K SSSSS    |
// |                                                                                   |
// | * AN ETHEREUM-BASED INDENTITY PLATFORM BROUGHT TO YOU BY NEUROMANTIC INDUSTRIES * |
// |                                                                                   |
// |                             @@@@@@@@@@@@@@@@@@@@@@@@                              |
// |                             @@@@@@@@@@@@@@@@@@@@@@@@                              |
// |                          @@@,,,,,,,,,,,,,,,,,,,,,,,,@@@                           |
// |                       @@@,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,@@@                        |
// |                       @@@,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,@@@                        |
// |                       @@@,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,@@@                        |
// |                       @@@,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,@@@                        |
// |                       @@@@@@@@@@,,,,,,,,,,@@@@@@,,,,,,,@@@                        |
// |                       @@@@@@@@@@,,,,,,,,,,@@@@@@,,,,,,,@@@                        |
// |                       @@@@@@@@@@,,,,,,,,,,@@@@@@,,,,,,,@@@                        |
// |                       @@@,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,@@@                        |
// |                       @@@,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,@@@                        |
// |                       @@@,,,,,,,@@@@@@,,,,,,,,,,,,,,,,,@@@                        |
// |                       @@@,,,,,,,@@@@@@,,,,,,,,,,,,,,,,,@@@                        |
// |                          @@@,,,,,,,,,,,,,,,,,,,,,,,,@@@                           |
// |                          @@@,,,,,,,,,,,,,,,,,,,,@@@@@@@                           |
// |                             @@@@@@@@@@@@@@@@@@@@@@@@@@@                           |
// |                             @@@@@@@@@@@@@@@@@@@@@@@@@@@                           |
// |                             @@@@,,,,,,,,,,,,,,,,@@@@,,,@@@                        |
// |                                 @@@@@@@@@@@@@@@@,,,,@@@                           |
// |                                           @@@,,,,,,,,,,@@@                        |
// |                                           @@@,,,,,,,,,,@@@                        |
// |                                              @@@,,,,@@@                           |
// |                                           @@@,,,,,,,,,,@@@                        |
// |                                                                                   |
// |                                                                                   |
// |   for more information visit skelephunks.com  |  follow @skelephunks on twitter   |
// |                                                                                   |
// * ————————————————————————————————————————————————————————————————————————————————— *
   
   
////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                           |                                                        //
//  The SkeleDrop Contract                   |  SkeleDrop is a way to manually airdrop crypt mints    //
//  By Autopsyop,for Neuromantic Industries  |  The tokens will be randomly selected from whats left  //
//  Part of the Skelephunks Platform         |  Only the owner of this contract can airdrop tokens    //
//                                           |                                                        //  
//////////////////////////////////////////////////////////////////////////////////////////////////////// 
// CHANGELOG
// V2: Fixes an issue where remaining claims for a wallet could be calculated incorrectly 


// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol"; 
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./MerkleProof.sol";

interface ISkelephunks is IERC721{
    function mintedAt(uint256 tokenId) external view returns (uint256);
    function minterOf(uint256 tokenId) external view returns (address);
    function getGenderAndDirection(uint256 tokenId) external view returns (uint256);
    function tokenOfOwnerByIndex( address owner, uint256 index) external view returns (uint256);
    function numMintedReserve() external view returns (uint256);
    function maxReserveSupply() external view returns (uint256);
    function mintReserve(address to, uint256 quantity, uint256 genderDirection) external;
    function mintPrice () external view returns (uint256);
}

contract SkeleDropV2 is Ownable {   
    constructor () {
        transferOwnership( msg.sender );
        setSkelephunksContract(0x7db8cD89308A295bb2D7F809B05DB6389e9a6d88);// MAINNET
    }
    /** 
        Math
    **/
    function max(
        uint256 a,
        uint256 b
    ) private pure returns (uint256){
        if(a > b)return a;
        return b;
    }
    function min(
        uint256 a,
        uint256 b
    ) private pure returns (uint256){
        if(a < b)return a;
        return b;
    }
    /**
        The skele contract
    **/    
    ISkelephunks public skelephunksContract;

    function setSkelephunksContract( 
        address addr 
    ) public onlyOwner {
        skelephunksContract = ISkelephunks( addr );
    }
 
    /**
        function requires the skele contract
    **/    
    modifier requiresSkelephunks {
        require( ISkelephunks(address(0)) != skelephunksContract, "No Skelephunks contract linked" );
        _;
    }
    /**
        SkeleDrop requires the crypt to have supply
    **/
    function maxCryptMints(
    ) private view returns (uint256){
        return  skelephunksContract.maxReserveSupply() - skelephunksContract.numMintedReserve() - 666;
    }
    function cryptHasMints(
    ) private view returns (bool){
        return 0 < maxCryptMints() ;
    }
// ALL DROPS
    uint256 public maxDrops = 666;
    uint256 public totalDrops;//number of explicit walletDrops (per-address) allocated
    function setMaxDrops( 
        uint256 maximum 
    ) public onlyOwner {
        require(totalDrops < maximum , "Already dropped more than that" );
        require(maximum - totalDrops < maxCryptMints() , "Not enough mints in crypt" );//new max cant be supported by crypt
        maxDrops = maximum;
    }
    function remainingDrops(
    ) public view returns (uint256) {
        if (!cryptHasMints() ){
            return 0;
        }
        return maxDrops - totalDrops;
    }
    function unclaimedListDrops(
    ) public view returns (uint256){
        uint256 count = 0;
        for(uint256 i = 0; i < lists.length; i++){
                count+=lists[i].remain;
        }
        return count;
    }
    function unclaimedDrops(
    )public view returns (uint256){
        return totalDrops - totalClaims;
    }
    modifier needsRemainingDrops{
        require(0 < remainingDrops());
        _;
    }
// WALLET DROPS
    mapping( address=>uint256) walletDrops;
    function dropsForWallet(
        address wallet
    ) public view returns (uint256){
        return walletDrops[wallet];
    }
    function listDropsForWallet(
        address wallet, 
        bytes32[][] calldata proofs
    ) private view returns (uint256){
        uint256 count = 0;
        bool[] memory used = new bool[](lists.length);
        for(uint256 p = 0; p < proofs.length; p++){
            for(uint256 l = 0; l < lists.length; l++){
                if(!used[l] && lists[l].remain > count && isMember(wallet,lists[l].root,proofs[p])){
                    used[l] = true;
                    count+=remainingDropsFromListForWallet(l,wallet);
                }
            }
        }
        return count;
    }
    function remainingDropsFromListForWallet(
        uint256 index,
        address wallet
    )private view returns(uint256){
        return min(lists[index].maxPer - claimedFromList[wallet][index],lists[index].remain);
    }
    function isMember(
        address wallet, 
        bytes32 root,
        bytes32[] calldata proof
    )private pure returns (bool){
        return MerkleProof.verifyCalldata(proof,root,keccak256(abi.encodePacked(wallet)));
    }
    function totalDropsForWallet(
        address wallet,
        bytes32[][] calldata proofs
    )public view returns (uint256){
        return listDropsForWallet(wallet,proofs) + walletDrops[wallet];
    }    
    function unclaimedDropsForWallet(
        address wallet,
        bytes32[][] calldata proofs
    )public view returns (uint256){
        return claimsPaused ? 0 : totalDropsForWallet(wallet,proofs) - claimsForWallet(wallet);
    }
// ALL CLAIMS
    uint256 public totalClaims;//number of walletDrops that have been claimed (from any source)

// WALLET CLAIMS
    mapping( address=>uint256 ) claims;
    mapping( address=>mapping( uint256=>uint256 ) ) claimedFromList;
    function listClaimsForWallet(
        address wallet
    ) private view returns (uint256){
        uint256 count = 0;
        for(uint256 i = 0; i < lists.length; i++){
            count+= claimedFromList[wallet][i];
        }
        return count;
    }
    function claimsForWallet(
        address wallet
    ) public view returns (uint256){
        return claims[wallet];
    }
// CONTROLS

    // sets the maximum to whats been allocated already to prevent future allocations 
    function freezeDrops(
    ) public onlyOwner {
        setMaxDrops(totalDrops);
    }
    /**
       claims can be paused
    **/  
    bool claimsPaused;
    function pauseClaims() public onlyOwner{ require(!claimsPaused,"claims already paused");claimsPaused = true;}
    function unpauseClaims() public onlyOwner{ require(claimsPaused,"claims not paused");claimsPaused = false;}
    modifier pauseable { require (!claimsPaused,"claimes are paused");_;}
    /**
       skeledrop enables an operator to allocate a free new mint claim to somebody from the crypt
    **/  
  
// LISTS

    struct List {
        bytes32 root;
        uint256 remain;
        uint256 maxPer;
    }
    List[] lists;
    /**
       skeledrop enables an operator to allocate create a list with access to an allocatoin of mints
    **/  
    function addList(
        bytes32 root,
        uint256 amount,
        uint256 maxPer
    )public onlyOwner{
        require(amount <= remainingDrops(),"cannot supply this many drops, please lower the amount");
        totalDrops+=amount;
        lists.push(List(root,amount,maxPer));
    }

    function quickAddList(
        bytes32 root,
        uint256 amount
    )public onlyOwner{
        addList(root,amount,1);
    }
    function remainingDropsForRoot(
        bytes32 root
    )public view returns (uint256){
        uint256 remaining;
        for(uint256 i = 0; i < lists.length; i++){//loop through all lists
            if (lists[i].root == root){
                remaining += lists[i].remain;
            }
        }
        return remaining;
    }
    function disableList(
        uint256 index
    )private onlyOwner{
        totalDrops -= lists[index].remain;
        lists[index].remain = 0;
    }
    function disableAllLists(
    ) public onlyOwner{
        require(lists.length > 0, "no lists to disable");
        for(uint256 i = 0; i < lists.length; i++){//loop through all lists
            disableList(i);
        }
    }
    function disableAllListsForRoot(// it is possible to add a root more than once. disable all matches
        bytes32 root
    ) public onlyOwner {
        uint256 found;
        for(uint256 i = 0; i < lists.length; i++){//loop through all lists
            if (lists[i].root == root && lists[i].remain > 0){
                found++;
                totalDrops -= lists[i].remain;
                lists[i].remain = 0;
            }
        }
        require(found > 0, "no active lists with that root can be found");
    }                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        

    function bulkDrop(
        address[] calldata tos,
        uint256 amount
    ) public onlyOwner needsRemainingDrops {
        require(remainingDrops() >= tos.length ,"not enuff walletDrops for all that");
        for( uint256 i = 0; i < tos.length; i++){
            drop(tos[i],amount);
        }
    }
    function quickDrop(
        address to
    ) public onlyOwner needsRemainingDrops {
        drop(to,1);
    }
    function drop(
        address to,
        uint256 amount
    ) public onlyOwner needsRemainingDrops {
        require(to != owner(), "WTF scammer");
        walletDrops[to]+=amount;
        totalDrops+=amount;
    }


    function mintFromCrypt(
        address to, 
        uint256 num, 
        uint256 gad
    ) private requiresSkelephunks {
        skelephunksContract.mintReserve(to, num, gad);
    }

    function claimDrops (
        uint256 gad
    ) public requiresSkelephunks pauseable {
        require(gad >= 0 && gad < 4, "invalid gender and direction");
        uint numDrops = walletDrops[msg.sender];
        uint numClaims = claims[msg.sender];
        uint256 dropsLeft = numDrops-numClaims ;// walletDrops left for wallet
        uint256 claimsRequested = dropsLeft;
        mintFromCrypt(msg.sender,claimsRequested,gad);// do the mint
        claims[msg.sender] += claimsRequested;//register the claims for wallet
        totalClaims += claimsRequested;//register claims to total
    }

    function claim (
        uint256 quantity,
        uint256 gad,
        bytes32[][] calldata proofs
    ) public requiresSkelephunks pauseable {
        require(gad >= 0 && gad < 4, "invalid gender and direction");
        uint256 unclaimed = unclaimedDropsForWallet(msg.sender,proofs);// all drops left for wallet
        require(quantity <= unclaimed, "not enough drops for this wallet to claim this quantity");
        uint256 requested = quantity == 0 ? unclaimed : quantity; //amount claiming - 0  = claim all
        uint requests = requested;

        // claim from lists first, then walletDrops 
        for(uint256 i = 0; i < lists.length; i++){//loop through all lists
            if( lists[i].remain > 0 && requests > 0 && claimedFromList[msg.sender][i] < lists[i].maxPer ){//claims remain, was list i max claimed by wallet?
                uint256 listRemains = remainingDropsFromListForWallet(i,msg.sender);//dont claim more than max ever
                uint256 listClaims = min(requests,listRemains);//we will claim no more than we're requesting from what remains
                lists[i].remain-=listClaims;//list remains minus claiming amount
                claimedFromList[msg.sender][i] += listClaims;// account for wallet claims from list
                require(claimedFromList[msg.sender][i]<=lists[i].maxPer,"attempted to claim more than maxPer from list");//this shouln't be possible
                requests-=listClaims;// requests less claiming amount
            }
        }
        claims[msg.sender] += requested;//register the claims for wallet
        totalClaims += requested;//register claims to total
        mintFromCrypt(msg.sender,requested,gad);// do the mint
    }

}