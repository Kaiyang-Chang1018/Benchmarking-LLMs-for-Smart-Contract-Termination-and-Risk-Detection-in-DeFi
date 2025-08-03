/*
  _____   __  ____   ____  _      _       ____      ____  ____     ___  _____  ____  _        ___ 
 / ___/  /  ]|    \ |    || |    | |     /    |    |    \|    \   /  _]/ ___/ /    || |      /  _]
(   \_  /  / |  D  ) |  | | |    | |    |  o  |    |  o  )  D  ) /  [_(   \_ |  o  || |     /  [_ 
 \__  |/  /  |    /  |  | | |___ | |___ |     |    |   _/|    / |    _]\__  ||     || |___ |    _]
 /  \ /   \_ |    \  |  | |     ||     ||  _  |    |  |  |    \ |   [_ /  \ ||  _  ||     ||   [_ 
 \    \     ||  .  \ |  | |     ||     ||  |  |    |  |  |  .  \|     |\    ||  |  ||     ||     |
  \___|\____||__|\_||____||_____||_____||__|__|    |__|  |__|\_||_____| \___||__|__||_____||_____|
                                                                                                  
*/

//SPDX-License-Identifier: MIT Licensed
pragma solidity ^0.8.10;

interface IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function tokensForSale() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 value) external;

    function transfer(address to, uint256 value) external;

    function transferFrom(address from, address to, uint256 value) external;

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);
}

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
    function processProof(
        bytes32[] memory proof,
        bytes32 leaf
    ) internal pure returns (bytes32) {
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
    function processProofCalldata(
        bytes32[] calldata proof,
        bytes32 leaf
    ) internal pure returns (bytes32) {
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
        require(
            leavesLen + proof.length - 1 == totalHashes,
            "MerkleProof: invalid multiproof"
        );

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
            bytes32 a = leafPos < leavesLen
                ? leaves[leafPos++]
                : hashes[hashPos++];
            bytes32 b = proofFlags[i]
                ? leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++]
                : proof[proofPos++];
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
        require(
            leavesLen + proof.length - 1 == totalHashes,
            "MerkleProof: invalid multiproof"
        );

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
            bytes32 a = leafPos < leavesLen
                ? leaves[leafPos++]
                : hashes[hashPos++];
            bytes32 b = proofFlags[i]
                ? leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++]
                : proof[proofPos++];
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

    function _efficientHash(
        bytes32 a,
        bytes32 b
    ) private pure returns (bytes32 value) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}

contract presaleScrilla {
    IERC20 public Scrilla;

    address payable public owner;
    bytes32 public merkleRoot;

    uint256 public tokenPerEth = 2_333_333 ether;
    uint256 public totalUsers;
    uint256 public soldToken;
    uint256 public minPurchase = 0.1 ether;
    uint256 public maxPurchase = 2 ether;
    uint256 public tokensForSale = 350000000 ether;

    uint256 public amountRaisedInEth;
    address payable public fundReceiver =
        payable(0x3A04A1044494f2e7AdD96DB4C4786c8F2d99d494);

    uint256 public constant divider = 100;
    bool public SaleForEveryOne;
    bool public enableClaim;
    mapping(address => bool) public oldBuyer;
    struct user {
        uint256 Eth_balance;
        uint256 token_balance;
        uint256 claimed_token;
    }

    mapping(address => user) public users;

    modifier onlyOwner() {
        require(msg.sender == owner, "PRESALE: Not an owner");
        _;
    }

    event BuyToken(address indexed _user, uint256 indexed _amount);
    event ClaimToken(address indexed _user, uint256 indexed _amount);

    constructor(IERC20 _scrilla) {
        owner = payable(0x3A04A1044494f2e7AdD96DB4C4786c8F2d99d494);
        Scrilla = _scrilla;
    }

    receive() external payable {}

    // to buy token during preSale time with Eth => for web3 use

    function buyToken(bytes32[] calldata merkleProof) public payable {
        if (
            !MerkleProof.verify(merkleProof, merkleRoot, toBytes32(msg.sender))
        ) {
            require(
                SaleForEveryOne == true,
                "Presale : Presale is not Opened yet"
            );
        }
        require(
            msg.value >= minPurchase,
            "Presale : amount must be greater than minimum purchase"
        );
        require(
            users[msg.sender].Eth_balance + msg.value <= maxPurchase,
            "Presale : amount must be less than max purchase"
        );
        require(soldToken <= tokensForSale, "All Sold");

        uint256 numberOfTokens;
        numberOfTokens = EthToToken(msg.value);
        soldToken = soldToken + (numberOfTokens);
        amountRaisedInEth = amountRaisedInEth + (msg.value);
        fundReceiver.transfer(msg.value);

        users[msg.sender].Eth_balance =
            users[msg.sender].Eth_balance +
            (msg.value);
        users[msg.sender].token_balance =
            users[msg.sender].token_balance +
            (numberOfTokens);
    }

    // to change preSale amount limits
    function setSupply(
        uint256 tokenForPresale,
        uint256 _soldToken
    ) external onlyOwner {
        tokensForSale = tokenForPresale;
        soldToken = _soldToken;
    }

    function OpenPresale(bool _status) external onlyOwner {
        SaleForEveryOne = _status;
    }

    // Claim bought tokens
    function claimTokens() external {
        require(enableClaim == true, "Presale : Presale is not finished yet");
        require(users[msg.sender].token_balance != 0, "Presale: 0 to claim");

        user storage _usr = users[msg.sender];

        Scrilla.transfer(msg.sender, _usr.token_balance);
        _usr.claimed_token += _usr.token_balance;
        _usr.token_balance -= _usr.token_balance;

        emit ClaimToken(msg.sender, _usr.token_balance);
    }

    // to check percentage of token sold
    function getProgress() public view returns (uint256 _percent) {
        uint256 remaining = tokensForSale -
            (soldToken / (10 ** (Scrilla.decimals())));
        remaining = (remaining * (divider)) / (tokensForSale);
        uint256 hundred = 100;
        return hundred - (remaining);
    }

    /**
     * @notice Change merkle root hash
     */
    function setMerkleRoot(bytes32 merkleRootHash) external onlyOwner {
        merkleRoot = merkleRootHash;
    }

    function toBytes32(address addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(addr)));
    }

    // to check number of token for given eth
    function EthToToken(uint256 _amount) public view returns (uint256) {
        uint256 numberOfTokens = (_amount * (tokenPerEth)) / (1e18);
        return numberOfTokens;
    }

    // to change Price of the token
    function changePrice(uint256 _price) external onlyOwner {
        tokenPerEth = _price;
    }

    function EnableClaim(bool _claim) public onlyOwner {
        enableClaim = _claim;
    }

    function changePurchaseLimits(
        uint256 _minPurchase,
        uint256 _maxPurchase
    ) public onlyOwner {
        minPurchase = _minPurchase;
        maxPurchase = _maxPurchase;
    }

    // transfer ownership
    function changeOwner(address payable _newOwner) external onlyOwner {
        owner = _newOwner;
    }

    // change tokens
    function changeToken(address _token) external onlyOwner {
        Scrilla = IERC20(_token);
    }

    // to draw funds for liquidity
    function transferFundsEth(uint256 _value) external onlyOwner {
        owner.transfer(_value);
    }

    // to draw out tokens
    function transferTokens(IERC20 token, uint256 _value) external onlyOwner {
        token.transfer(msg.sender, _value);
    }
}