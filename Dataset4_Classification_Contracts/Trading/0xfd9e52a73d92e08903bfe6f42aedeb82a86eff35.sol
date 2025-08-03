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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/cryptography/MerkleProof.sol)

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
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    /**
     * @dev Calldata version of {verify}
     *
     * _Available since v4.7._
     */
    function verifyCalldata(
        bytes32[] calldata proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
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
        // This function rebuild the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        require(leavesLen + proof.length - 1 == totalHashes, "MerkleProof: invalid multiproof");

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value for the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i] ? leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++] : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            return hashes[totalHashes - 1];
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
        // This function rebuild the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        require(leavesLen + proof.length - 1 == totalHashes, "MerkleProof: invalid multiproof");

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value for the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i] ? leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++] : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            return hashes[totalHashes - 1];
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
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

interface iNAGOMIHappyBirthday {
    function externalMint(address _to, uint256 _id, uint256 _amount) external;
    function sumOfTotalSupply() external view returns (uint256);
    function totalSupply(uint256 id) external view returns (uint256);
}

contract NAGOMIMinterHalfYear is Ownable {
    iNAGOMIHappyBirthday public NAGOMIHappyBirthday;

    bytes32 public freeMintMerkleRoot;
    bytes32 public allowlistMintMerkleRoot;

    uint256 public constant MAX_SUPPLY = 1299;
    uint256 public constant TOKEN_ID_ZERO_MAX_SUPPLY = 433;
    uint256 public constant TOKEN_ID_ONE_MAX_SUPPLY = 433;
    uint256 public constant TOKEN_ID_TWO_MAX_SUPPLY = 433;
    uint256 public constant MINT_COST = 0.005 ether;

    uint256[4] public withdrawShare = [40, 20, 20, 20];

    address[4] public withdrawAddress = [
        0x445513cd8ECA1E98b0C70f1Cdc52C4d986dDC987,
        0xF185B303775958C93AcFFa1231A8d14b38c049ac,
        0xCF8706F4aF69310c7372B5e9e91EF5fbc8d02C5a,
        0xe273eF71274926b7Dec32546Af84dB6e37eFADbF
    ];

    mapping(address => uint256) public freeMintCount;
    mapping(address => uint256) public allowlistMintCount;

    enum SalePhase {
        Locked,
        FreeMint,
        AllowlistMint,
        PublicMint
    }

    SalePhase public phase = SalePhase.Locked;

    event Minted(address _to, uint256 _amount);
    event PhaseChanged(SalePhase _phase);

    constructor() {}

    /**
     * モディファイア
     */
    modifier callerIsUser() {
        require(tx.origin == msg.sender, "called by contract");
        _;
    }

    modifier notZeroMint(uint256 _mintAmount) {
        require(_mintAmount != 0, "mintAmount is zero");
        _;
    }

    modifier enoughEth(uint256 _mintAmount) {
        require(MINT_COST * _mintAmount <= msg.value, "not enough eth");
        _;
    }

    modifier notOverMaxSupply(uint256 _mintAmount) {
        require(_mintAmount + sumOfTotalSupply() <= MAX_SUPPLY, "exceeds max supply");
        _;
    }

    /**
     * withdraw関数
     */
    /// @dev 引出し先アドレスのsetter関数
    function setWithdrawAddress(uint256 _index, address _withdrawAddress) external onlyOwner {
        require(_withdrawAddress != address(0), "withdrawAddress can't be 0");
        withdrawAddress[_index] = _withdrawAddress;
    }

    /// @dev 引出し割合のsetter関数
    function setWithdrawShare(uint256 _index, uint256 _withdrawShare) external onlyOwner {
        withdrawShare[_index] = _withdrawShare;
    }

    /// @dev 引出し用関数
    function withdraw() external payable onlyOwner {
        uint256 initialBalance = address(this).balance;
        for (uint256 index; index < withdrawAddress.length; index++) {
            require(withdrawAddress[index] != address(0), "withdrawAddress can't be 0");

            uint256 sharedAmount = (initialBalance * withdrawShare[index]) / 100;
            (bool sent,) = payable(withdrawAddress[index]).call{value: sharedAmount}("");
            require(sent, "failed to withdraw");
        }
    }

    /**
     * ミント関数
     */
    /// @dev フリーミント用のMint関数
    function freeMint(uint256 _mintAmount, bytes32[] calldata _merkleProof)
        external
        callerIsUser
        notZeroMint(_mintAmount)
        notOverMaxSupply(_mintAmount)
    {
        // セールフェイズチェック
        require(phase == SalePhase.FreeMint, "FreeMint is disabled");

        // マークルツリーチェック：ルートはfreeMintMerkleRoot
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(_merkleProof, freeMintMerkleRoot, leaf), "Invalid Merkle Proof");

        // ミント枚数チェック：フリーミントは1枚まで
        require(freeMintCount[msg.sender] + _mintAmount <= 1, "exceeds allocation");

        randomMint(msg.sender, _mintAmount);

        // フリーミント済み数加算
        unchecked {
            freeMintCount[msg.sender] += _mintAmount;
        }
    }

    /// @dev AllowListミント用のMint関数
    function allowlistMint(uint256 _mintAmount, bytes32[] calldata _merkleProof)
        external
        payable
        callerIsUser
        notZeroMint(_mintAmount)
        enoughEth(_mintAmount)
        notOverMaxSupply(_mintAmount)
    {
        // セールフェイズチェック
        require(phase == SalePhase.AllowlistMint, "AllowlistMint is disabled");

        // マークルツリーチェック：ルートはallowlistMintMerkleRoot
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(_merkleProof, allowlistMintMerkleRoot, leaf), "Invalid Merkle Proof");

        // ミント枚数チェック：ALミントは2枚まで
        require(allowlistMintCount[msg.sender] + _mintAmount <= 2, "exceeds allocation");

        randomMint(msg.sender, _mintAmount);

        // ALミント数済み数加算
        unchecked {
            allowlistMintCount[msg.sender] += _mintAmount;
        }
    }

    /// @dev パブリックミント用のMint関数
    function publicMint(uint256 _mintAmount)
        external
        payable
        callerIsUser
        notZeroMint(_mintAmount)
        enoughEth(_mintAmount)
        notOverMaxSupply(_mintAmount)
    {
        // セールフェイズチェック
        require(phase == SalePhase.PublicMint, "PublicMint is disabled");

        // マークルツリーチェック：なし

        // ミント枚数チェック：購入制限なし

        randomMint(msg.sender, _mintAmount);

        // パブリックミント数済み数加算：なし
    }

    /// @dev エアドロミント関数
    function adminMint(address[] calldata _airdropAddresses, uint256[] calldata _userMintAmount) external onlyOwner {
        require(_airdropAddresses.length == _userMintAmount.length, "array length mismatch");

        uint256 _totalMintAmmount;

        for (uint256 i = 0; i < _userMintAmount.length; i++) {
            require(_userMintAmount[i] > 0, "amount 0 address exists!");

            // adminがボケた引数を入れないことが大前提
            unchecked {
                _totalMintAmmount += _userMintAmount[i];
            }

            require(_totalMintAmmount + sumOfTotalSupply() <= MAX_SUPPLY, "exceeds max supply");

            randomMint(_airdropAddresses[i], _userMintAmount[i]);
        }
    }

    /// @dev tokenId 0, 1, 2 をランダムに選んでミントするための内部関数
    /// Keisuke-san arigato-gozaimasu
    function randomMint(address _to, uint256 _amount) private {
        uint256 remaining;

        for (uint256 i = 0; i < _amount; i++) {
            unchecked {
                remaining = MAX_SUPPLY - sumOfTotalSupply();
            }
            uint256 random = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender))) % remaining;

            if (0 <= random && random < (TOKEN_ID_ZERO_MAX_SUPPLY - NAGOMIHappyBirthday.totalSupply(0))) {
                NAGOMIHappyBirthday.externalMint(_to, 0, 1);
            } else if (
                (TOKEN_ID_ZERO_MAX_SUPPLY - NAGOMIHappyBirthday.totalSupply(0)) <= random
                    && random
                        < (
                            (TOKEN_ID_ZERO_MAX_SUPPLY - NAGOMIHappyBirthday.totalSupply(0))
                                + (TOKEN_ID_ONE_MAX_SUPPLY - NAGOMIHappyBirthday.totalSupply(1))
                        )
            ) {
                NAGOMIHappyBirthday.externalMint(_to, 1, 1);
            } else {
                NAGOMIHappyBirthday.externalMint(_to, 2, 1);
            }
        }

        emit Minted(_to, _amount);
    }

    /**
     * その他の関数
     */
    /// @dev 親コントラクトのsetter
    function setNAGOMIHappyBirthday(address _contractAddress) external onlyOwner {
        NAGOMIHappyBirthday = iNAGOMIHappyBirthday(_contractAddress);
    }

    /// @dev セールフェーズのsetter
    function setPhase(SalePhase _phase) external onlyOwner {
        if (_phase != phase) {
            phase = _phase;
            emit PhaseChanged(_phase);
        }
    }

    /// @dev フリーミント用MerkleRootのsetter
    function setFreeMintMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
        freeMintMerkleRoot = _merkleRoot;
    }

    /// @dev ALミント用MerkleRootのsetter
    function setAllowlistMintMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
        allowlistMintMerkleRoot = _merkleRoot;
    }

    /// @dev 全tokenIdのtotalSupply和のgetter
    function sumOfTotalSupply() public view returns (uint256) {
        return NAGOMIHappyBirthday.sumOfTotalSupply();
    }
}