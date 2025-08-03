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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/cryptography/MerkleProof.sol)

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
// SPDX-License-Identifier: UNLICENSED
// Developed by Liteflow.com
pragma solidity 0.8.20;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/cryptography/MerkleProof.sol';

contract LaunchBlockGrapesSale is Ownable {
    /// @notice Start date of the sale in timestamp
    /// @dev Set in the constructor
    uint256 public immutable startDate;

    /// @notice End date of the sale in timestamp
    /// @dev Set in the constructor
    uint256 public immutable endDate;

    /// @notice Price of one ticket in wei
    /// @dev Set in the constructor
    uint256 public immutable ticketPrice;

    /// @notice Max number of tickets that can be bought per buyer
    /// @dev Set in the constructor
    uint256 public immutable maxTicketsPerBuyer;

    /// @notice Number of tickets bought by each buyer
    /// @dev Managed internally by contract
    mapping(address buyer => uint256) public balances;

    /// @notice Number of tickets refunded for each buyer
    /// @dev Managed internally by contract
    mapping(address buyer => uint256) public refunds;

    /// @notice Refund Merkle root
    bytes32 public refundMerkleRoot;

    /// @notice Emitted when a ticket is bought
    // event TicketBought(address indexed wallet, uint256[] ticketIds);
    event TicketsBought(address indexed wallet, uint256 count);

    /// @notice Emitted when a ticket is refunded
    event TicketsRefunded(address indexed wallet, uint256 count);

    /// @notice Returned when the sale is not started or ended
    error SaleClosed();

    /// @notice Returned when the amount of ETH sent is not equal to the ticket price multiplied by the number of tickets to buy
    error InvalidAmount();

    /// @notice Returned when the number of tickets to buy is greater than the max allowed
    error TicketLimitReached();

    /// @notice Returned when the refund function is not open
    error RefundClosed();

    /// @notice Returned when ticket is already refunded
    error AlreadyRefunded();

    /// @notice Returned when the merkle proof is invalid
    error InvalidMerkleProof();

    /// @notice Returned when the refund transfer fails
    error RefundFailed();

    /// @notice Returned when the sale is not ended
    error SaleNotClosed();

    /// @notice Returned when refund merkle root is already set
    error RefundMerkleRootAlreadySet();

    /// @notice Returned when the withdraw all transfer fails
    error WithdrawFailed();

    /// @notice Returned when it's too early to execute withdraw all
    error WithdrawAllNotEligible();

    /// @notice Returned when the withdraw all ETH fails
    error WithdrawAllFailed();

    /// @notice Initializes the contract
    /// @param initialOwner_ The address of the initial owner of the contract
    /// @param ticketPrice_ The price of one ticket in wei
    /// @param maxTicketsPerBuyer_ Max number of tickets that can be bought per buyer
    /// @param startDate_ Start date of the sale in timestamp
    /// @param endDate_ End date of the sale in timestamp
    constructor(
        address initialOwner_,
        uint256 ticketPrice_,
        uint256 maxTicketsPerBuyer_,
        uint256 startDate_,
        uint256 endDate_
    ) Ownable(initialOwner_) {
        ticketPrice = ticketPrice_;
        maxTicketsPerBuyer = maxTicketsPerBuyer_;
        startDate = startDate_;
        endDate = endDate_;
    }

    /// @notice Buy tickets
    /// @param numberOfTickets_ The number of tickets to buy
    function buyTickets(uint256 numberOfTickets_) external payable {
        // check if the sale is closed
        if (block.timestamp < startDate || block.timestamp > endDate) {
            revert SaleClosed();
        }

        // check amount provided is correct
        if (msg.value != ticketPrice * numberOfTickets_) revert InvalidAmount();

        // calculate the number of tickets bought by the sender
        uint256 balance = balances[msg.sender] + numberOfTickets_;

        // check that the number of tickets is not greater than the max allowed
        if (balance > maxTicketsPerBuyer) revert TicketLimitReached();

        // update ticket balance of buyer
        balances[msg.sender] = balance;

        // emit event
        emit TicketsBought(msg.sender, numberOfTickets_);
    }

    /// @notice Refund tickets
    /// @param ticketsToRefund_ The number of the tickets to refund
    /// @param merkleProof_ The merkle proof of the tickets to refund
    function refundTickets(
        uint256 ticketsToRefund_,
        bytes32[] calldata merkleProof_
    ) external {
        // check refund is activated
        if (refundMerkleRoot == bytes32(0)) revert RefundClosed();

        // check sender was not already refunded
        if (refunds[msg.sender] > 0) revert AlreadyRefunded();

        // check that the merkle proof is valid
        if (
            !MerkleProof.verifyCalldata(
                merkleProof_,
                refundMerkleRoot,
                keccak256(
                    bytes.concat(
                        keccak256(abi.encode(msg.sender, ticketsToRefund_))
                    )
                )
            )
        ) revert InvalidMerkleProof();

        // mark the sender as refunded
        refunds[msg.sender] = ticketsToRefund_;

        // emit event
        emit TicketsRefunded(msg.sender, ticketsToRefund_);

        // do the refund transfer
        (bool sent, ) = msg.sender.call{value: ticketsToRefund_ * ticketPrice}(
            ''
        );
        if (!sent) revert RefundFailed();
    }

    /// @notice Set the refund merkle root and withdraw ETH of the winning tickets. Only owner can execute this function
    /// @param refundMerkleRoot_ The refund merkle root
    /// @param numberOfWinningTickets_ The number of winning tickets
    /// @param to_ The address to send the ETH to
    function finalizeSale(
        bytes32 refundMerkleRoot_,
        uint256 numberOfWinningTickets_,
        address payable to_
    ) external onlyOwner {
        // check if the sale is closed
        if (block.timestamp <= endDate) {
            revert SaleNotClosed();
        }

        // prevent setting the Merkle root if already set
        if (refundMerkleRoot != bytes32(0)) revert RefundMerkleRootAlreadySet();

        // set the merkle root
        refundMerkleRoot = refundMerkleRoot_;

        // transfer amount corresponding to the winning tickets
        (bool sent, ) = to_.call{value: numberOfWinningTickets_ * ticketPrice}(
            ''
        );
        if (!sent) revert WithdrawFailed();
    }

    /// @notice Withdraw all ETH from the contract. Only owner can execute this function.
    /// @param to_ The address to send the ETH to.
    function withdrawAll(address payable to_) external onlyOwner {
        // check the sale is closed for at least 3 days
        if (block.timestamp <= endDate + 3 days) {
            revert WithdrawAllNotEligible();
        }

        (bool sent, ) = to_.call{value: address(this).balance}('');
        if (!sent) revert WithdrawAllFailed();
    }
}