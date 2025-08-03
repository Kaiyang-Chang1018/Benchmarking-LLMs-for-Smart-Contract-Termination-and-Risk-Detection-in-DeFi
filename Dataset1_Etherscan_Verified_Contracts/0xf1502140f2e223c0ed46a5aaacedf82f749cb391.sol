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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/ReentrancyGuard.sol)

pragma solidity ^0.8.20;

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
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
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
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
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
// A public demonstration in single-contract dual-token implementations
// with zero-conflict events, and function overloading.

// Website : https://spacepoptroopers.io/
// X : https://x.com/spt_erc741
// TG : https://t.me/SPT_ERC741

// A big thank you to Serec Thunderson for your awesome code contribution.
// Your work is greatly appreciated.
// Thank you for your valuable input.

// Find his work on the following link:
// https://github.com/SJ741/sj741-token

// WARNING - Fungible NFT specs are universally new, and inherently DANGEROUS
// no systems have been built with these use-cases in mind, and there are a number of
// ways that experimental, complex contracts can lead to unforeseen consequences.
// INTERACT WITH EXPERIMENTAL SMART CONTRACTS AT YOUR OWN RISK

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// libraries to separate ERC20 and ERC721 events, and certain signature-specific functions
// ERC20 events
library libSPT20 {
    event Transfer(address indexed from, address indexed to, uint amount);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function emitTransfer(address _from, address _to, uint _amount) internal {
        emit Transfer(_from, _to, _amount);
    }

    function emitApproval(
        address _owner,
        address _spender,
        uint _value
    ) internal {
        emit Approval(_owner, _spender, _value);
    }
}

// ERC721 events
library libSPT721 {
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint indexed _tokenId
    );
    event Approval(
        address indexed _owner,
        address indexed _approved,
        uint indexed _tokenId
    );
    event ApprovalForAll(
        address indexed _owner,
        address indexed _operator,
        bool _approved
    );

    function emitTransfer(address _from, address _to, uint _tokenId) internal {
        emit Transfer(_from, _to, _tokenId);
    }

    function emitApproval(
        address _owner,
        address _approve,
        uint _tokenId
    ) internal {
        emit Approval(_owner, _approve, _tokenId);
    }

    function emitApprovalForAll(
        address _owner,
        address _operator,
        bool _approved
    ) internal {
        emit ApprovalForAll(_owner, _operator, _approved);
    }
}

// ERC165 https://eips.ethereum.org/EIPS/eip-721
interface IERC165 {
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

// ERC20 https://eips.ethereum.org/EIPS/eip-20
interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

// ERC721 https://eips.ethereum.org/EIPS/eip-721
interface IERC721 is IERC165 {
    function balanceOf(address account) external view returns (uint256);

    function ownerOf(uint256 _tokenId) external view returns (address);

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory data
    ) external payable;

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable;

    function setApprovalForAll(address _operator, bool _approved) external;

    function getApproved(uint256 _tokenId) external view returns (address);

    function isApprovedForAll(
        address _owner,
        address _operator
    ) external view returns (bool);

    // payable removed for erc20 etherscan compatibility
    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

interface ISPT741 is IERC20, IERC721 {
    // library transfers can not be included in the interface
    // incorporate them directly with library
    // libSPT20.Transfer
    // libSPT20.Approval
    // libSPT721.Transfer
    // libSPT721.Approval
    // libSPT721.ApprovalForAll
    function balanceOf(
        address account
    ) external view override(IERC20, IERC721) returns (uint256);

    function approve(
        address spender,
        uint256 value
    ) external override(IERC20, IERC721) returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external override(IERC20, IERC721) returns (bool);
}

// ERC721 Token Receiver https://eips.ethereum.org/EIPS/eip-721
interface IERC721TokenReceiver {
    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes memory _data
    ) external returns (bytes4);
}

contract SPT is ISPT741 {
    string public baseURI =
        "ipfs://bafybeidskgytes3zn4ge2yoejahnl7gmlsuwirg2czsujhxbzcwrthuuti/";
    string internal constant _name = "Space Pop Troopers";
    string internal constant _symbol = "SPT";

    uint internal constant _decimals = 8;
    uint internal constant _totalIds = 1741;
    uint internal constant _totalSupply = _totalIds * 10 ** _decimals;
    uint internal constant ONE = 10 ** _decimals; // 1.0 token(s)
    uint internal constant MAXID = ONE + _totalIds; // 1.00000001 : 1.00007777 is the range for NFT IDs

    uint32 public minted; // number of unique ID mints
    uint32[] private broken; // broken NFTs stored in limbo list

    address public dev;
    bool public supportsNFTinterface;
    bool public skipMintingGlobal = false;

    mapping(address => mapping(address => bool)) private _operatorApprovals;
    mapping(address => mapping(address => uint)) internal _allowance;
    mapping(uint256 => address) public ownerOf;
    mapping(uint256 => address) private _nftApprovals;
    mapping(address => uint) internal _balanceOf;
    mapping(address => uint32[]) public ownedNFTs;
    mapping(uint32 => uint256) private idToIndex;
    mapping(address => bool) internal skipMintingUser;

    function setSkipMintingGlobal(bool newSkipMintingGlobal) public onlyDev {
        skipMintingGlobal = newSkipMintingGlobal;
    }

    function setSkipMinting(bool newSkipMinting) public {
        skipMintingUser[msg.sender] = newSkipMinting;
    }

    error UnsupportedReceiver();

    modifier onlyDev() {
        require(msg.sender == dev, "Not the developer");
        _;
    }

    constructor() {
        //set minted at ONE to ensure correct operation within range of IDs
        minted = uint32(ONE);

        //the message sender receives the entire supply
        _balanceOf[msg.sender] = _totalSupply;

        //the message sender is set as "dev" role
        dev = msg.sender;
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint) {
        return _balanceOf[account];
    }

    function allowance(
        address owner,
        address spender
    ) public view override returns (uint) {
        return _allowance[owner][spender];
    }

    function setBaseURI(string memory newBaseURI) public onlyDev {
        baseURI = newBaseURI;
    }

    function changeDev(address newDev) public onlyDev {
        dev = newDev;
    } //simple function to change developer address, or revoke ownership (with address(0))

    // @DEV toggleNFTinterface is for the small possibility of frontend system changes leading the contract to favor enabling the disabled supportsNFTinterface flag
    // don't waste it, as frontends don't typically change classification of contracts
    // probably never to be used.
    function toggelNFTinterface() public onlyDev {
        supportsNFTinterface = !supportsNFTinterface;
    }

    function approve(
        address spender,
        uint amount
    ) public override returns (bool) {
        // if the amount is greater than one token, and within range of IDs for NFTs
        // then set NFT approval for the given ID
        if (amount > ONE && amount <= MAXID) {
            address owner = ownerOf[amount]; // getting the owner of token ID via the `amount` input
            if (msg.sender != owner && !isApprovedForAll(owner, msg.sender))
                revert("SPT741: You are not approved");
            _nftApprovals[amount] = spender; // calling nft approval for the token and spender
            libSPT721.emitApproval(owner, spender, amount);
            return true;
        }

        // else set the ERC20 allowance
        // the NFT ID range being set within a limited subset of ONE token(s)
        // allows for non-clashing interactions
        _allowance[msg.sender][spender] = amount;
        libSPT20.emitApproval(msg.sender, spender, amount);
        return true;
    }

    function _transfer741(
        address from,
        address to,
        uint amount
    ) internal virtual {
        require(
            _balanceOf[from] >= amount,
            "SPT741: transfer amount exceeds balance"
        );

        // checking the decimal amount of tokens owned before transaction for both participants
        uint256 fromDecimalsPre = _balanceOf[from] % ONE;
        uint256 toDecimalsPre = _balanceOf[to] % ONE;

        // simple erc20 balance operations
        _transfer20(from, to, amount);

        // checking the decimal amount of tokens after transaction for both partcipants
        uint256 fromDecimalsPost = _balanceOf[from] % ONE;
        uint256 toDecimalsPost = _balanceOf[to] % ONE;

        // stores the NFT IDs owned by `from`, enabling NFT management for that address.
        uint32[] storage ownedNFTsArray = ownedNFTs[from];

        // references NFTs marked as "broken", tracking these special state NFTs.
        uint32[] storage brokenIDsArray = broken;

        // if sender has higher decimal count after transaction, then they "roll under" and break an NFT
        if (fromDecimalsPre < fromDecimalsPost) {
            if (ownedNFTsArray.length > 0) {
                // if the sender has an nft to send

                uint32 tokenId = ownedNFTsArray[0]; //selects the user's first NFT from the list

                brokenIDsArray.push(tokenId); //pushes the nft into the "broken list" for limbo NFTs
                _transfer721(from, address(0), tokenId); //transfers the NFT ID ownership to (0) address for stewardship
            }
        }

        // if receiver has lower decimal count after transaction then they "roll over" and will "remake" an nft
        if (toDecimalsPre > toDecimalsPost) {
            if (brokenIDsArray.length > 0) {
                // recover an id from broken list

                _transfer721(
                    address(0),
                    to,
                    brokenIDsArray[brokenIDsArray.length - 1]
                );
                brokenIDsArray.pop();
            } else {
                // mint new id
                _mint(to);
            }
        }

        // amount of tokens - amount of whole tokens being processed in int
        uint amountInTokens = amount / ONE;

        // ignore minting nfts from dev when they call -- this allows for gas-efficient team operations
        // @DEV if dev gathers NFTs, use the ERC721 transferFrom method to extract
        // @DEV be careful, don't let the wallet fall to some convoluted transferFrom scam to do something unexpected
        if (
            from == dev ||
            skipMintingGlobal ||
            skipMintingUser[to] ||
            skipMintingUser[from]
        ) return;

        if (amountInTokens > 0) {
            uint len = ownedNFTsArray.length; //len is the length, or number of NFTs in the addresses's owned array
            len = amountInTokens < len ? amountInTokens : len;
            // transfers owned NFTs from `from` to `to` until either all are transferred or the desired amount is reached
            // Subtracts transferred NFT count from `amountInTokens` to update remaining transfers
            for (uint i = 0; i < len; i++) {
                _transfer721(from, to, ownedNFTsArray[0]);
            }
            amountInTokens -= len;
            len = brokenIDsArray.length;
            len = amountInTokens < len ? amountInTokens : len;

            // recovers NFTs from the broken state to `to`, or mints new ones if not enough broken NFTs are available
            // if any tokens remain to be allocated, it mints new NFTs to `to` for the remaining balance
            for (uint i = 0; i < len; i++) {
                _transfer721(
                    address(0),
                    to,
                    brokenIDsArray[brokenIDsArray.length - 1]
                );
                brokenIDsArray.pop();
            }

            _mintBatch(to, amountInTokens - len);
        }
    }

    function _mintBatch(address to, uint256 amount) internal {
        if (amount == 0) return; // Exit if no NFTs to mint

        if (amount == 1) {
            // Optimize single mint process
            _mint(to);
            return;
        }
        uint32 id = minted; // Start ID from last minted value
        uint256 ownedLen = ownedNFTs[to].length; // Current number of NFTs owned by 'to'
        for (uint i = 0; i < amount; ) {
            unchecked {
                id++; // Increment ID for each new NFT
            }
            ownerOf[id] = to; // Assign new NFT to owner.
            idToIndex[id] = ownedLen; // Map NFT ID to its index in owner's array
            ownedNFTs[to].push(id); // Add new NFT ID to owner's list

            libSPT721.emitTransfer(address(0), to, id); // Emit NFT transfer event

            unchecked {
                ownedLen++; // Increment count of owned NFTs
                i++; // Move to next NFT
            }
        }
        unchecked {
            minted += uint32(amount); // Update total minted count
        }
    }

    function _mint(address to) internal returns (uint32 tokenId) {
        unchecked {
            minted++; // Increment the total number of minted tokens
        }
        tokenId = minted; // Assign the newly minted token ID

        ownerOf[tokenId] = to; // Set ownership of the new token to 'to'
        idToIndex[tokenId] = ownedNFTs[to].length; // Map the new token ID to its index in the owner's list
        ownedNFTs[to].push(tokenId); // Add the new token ID to the owner's list of owned tokens

        libSPT721.emitTransfer(address(0), to, tokenId); // Emit an event for the token transfer
    }

    // Updates the mappings and arrays managing ownership and index of NFTs after a transfer
    function _updateOwnedNFTs(
        address from,
        address to,
        uint32 tokenId
    ) internal {
        uint256 index = idToIndex[tokenId]; // Get current index of the token in the owner's list
        uint32[] storage nftArray = ownedNFTs[from]; // Reference to the list of NFTs owned by 'from'
        uint256 len = nftArray.length; // Current number of NFTs owned by 'from'
        uint32 lastTokenId = nftArray[len - 1]; // Last token in the 'from' array to swap with transferred token

        nftArray[index] = lastTokenId; // Replace the transferred token with the last token in the array
        nftArray.pop(); // Remove the last element, effectively deleting the transferred token from 'from'

        if (len - 1 != 0) {
            idToIndex[lastTokenId] = index; // Update the index of the swapped token
        }

        ownedNFTs[to].push(tokenId); // Add the transferred token to the 'to' array
        idToIndex[tokenId] = ownedNFTs[to].length - 1; // Update the index mapping for the transferred token
    }

    // Executes a simple ERC20 token transfer.
    function _transfer20(address from, address to, uint256 amount) internal {
        _balanceOf[from] -= amount; // Deduct the amount from the sender's balance
        unchecked {
            _balanceOf[to] += amount; // Add the amount to the recipient's balance
        }
        libSPT20.emitTransfer(from, to, amount); // Emit an ERC20 transfer event
    }

    // Handles the transfer of an ERC721 token, ensuring proper ownership and event emission
    function _transfer721(
        address from,
        address to,
        uint32 tokenId
    ) internal virtual {
        require(from == ownerOf[tokenId], "SPT741: Incorrect owner"); // Ensure 'from' is the current owner

        delete _nftApprovals[tokenId]; // Clear any approvals for this token
        ownerOf[tokenId] = to; // Transfer ownership of the token to 'to'
        _updateOwnedNFTs(from, to, tokenId); // Update ownership tracking structures
        libSPT721.emitTransfer(from, to, tokenId); // Emit an ERC721 transfer event
    }

    // only erc20 calls this
    // if amount is a token id owned by the caller send as an NFT
    // else transfer741
    function transfer(address to, uint amount) public override returns (bool) {
        if (ownerOf[amount] == msg.sender) {
            _transfer721(msg.sender, to, uint32(amount));
            _transfer20(msg.sender, to, ONE);
            return true;
        }
        _transfer741(msg.sender, to, amount);
        return true;
    }

    // erc20 and erc721 call this
    function transferFrom(
        address from,
        address to,
        uint amount
    ) public override returns (bool) {
        //if amount is within the NFT id range, then a simple NFT transfer + token amount (ONE)
        if (amount > ONE && amount <= MAXID) {
            require(
                //require from is the msg caller, or that caller is approved for that specific NFT, or all NFTs
                msg.sender == from ||
                    msg.sender == getApproved(amount) ||
                    isApprovedForAll(from, msg.sender),
                "SPT741: You don't have the right"
            );

            _transfer721(from, to, uint32(amount));
            _transfer20(from, to, ONE);
            return true;
        }

        _spendAllowance(from, msg.sender, amount);
        _transfer741(from, to, amount);
        return true;
    }

    // erc721
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public payable override {
        require(
            msg.sender == from ||
                msg.sender == getApproved(tokenId) ||
                isApprovedForAll(from, msg.sender),
            "SPT741: You don't have the right"
        );
        _transfer721(from, to, uint32(tokenId));
        _transfer20(from, to, ONE);

        if (
            to.code.length != 0 &&
            IERC721TokenReceiver(to).onERC721Received(
                msg.sender,
                from,
                tokenId,
                ""
            ) !=
            IERC721TokenReceiver.onERC721Received.selector
        ) {
            revert UnsupportedReceiver();
        }
    }

    // erc721
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public payable override {
        require(
            msg.sender == from ||
                msg.sender == getApproved(tokenId) ||
                isApprovedForAll(from, msg.sender),
            "SPT741: You don't have the right"
        );
        _transfer721(from, to, uint32(tokenId));
        _transfer20(from, to, ONE);

        if (
            to.code.length != 0 &&
            IERC721TokenReceiver(to).onERC721Received(
                msg.sender,
                from,
                tokenId,
                data
            ) !=
            IERC721TokenReceiver.onERC721Received.selector
        ) {
            revert UnsupportedReceiver();
        }
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint amount
    ) internal virtual {
        require(
            _allowance[owner][spender] >= amount,
            "SPT741: insufficient allowance"
        );
        _allowance[owner][spender] -= amount;
    }

    function getApproved(
        uint256 tokenId
    ) public view override returns (address) {
        if (ownerOf[tokenId] == address(0)) revert();
        return _nftApprovals[tokenId];
    }

    function setApprovalForAll(
        address operator,
        bool approved
    ) public override {
        _operatorApprovals[msg.sender][operator] = approved;
        libSPT721.emitApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(
        address owner,
        address operator
    ) public view override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function tokenURI(
        uint256 tokenId
    ) public view virtual returns (string memory) {
        require(tokenId <= MAXID, "SPT741: invalid id");
        if (bytes(baseURI).length == 0) {
            return "";
        }
        return
            string(abi.encodePacked(baseURI, toString(tokenId - ONE), ".json"));
    }

    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(value % 10) + 48);
            value /= 10;
        }
        return string(buffer);
    }

    function withdraw() external onlyDev {
        payable(dev).transfer(address(this).balance);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override returns (bool) {
        return
            // Even though we support ERC721 and should return true, etherscan wants to treat us as ERC721 instead of ERC20
            // @DEV ERC165 for ERC721 can be toggled on for reasons of frontend/dapp/script implementations, but is very specific
            (supportsNFTinterface && interfaceId == 0x80ac58cd) || // ERC165 interface ID for ERC721
            interfaceId == 0x01ffc9a7 || // ERC165 interface ID for ERC165
            interfaceId == 0x36372b07; // ERC165 interface ID for ERC20
    }

    function getOwnedNFTs(
        address _owner
    ) external view returns (uint32[] memory) {
        return ownedNFTs[_owner];
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

import "./SPT.sol";

contract Vendor is Ownable, ReentrancyGuard {
    SPT public token; // Use interface

    uint256 public constant PRICE = 135000000000000000;
    uint256 public constant PRICE_WL = 110000000000000000;
    uint256 public maxBuyAmountPerWallet;
    uint256 public maxBuyAmountPerWalletForWLSales;
    uint256 public maxBuyAmountForWLSalesPeriod;
    uint256 public salesStep = 0; // 0 - not active, 1 - whitelist only, 2 - public
    uint256 public totalBought = 0;
    bytes32 public merkleRoot;

    mapping(address => uint256) public tokensCountPerAddress;

    event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
    event WithdrawEther(address caller, uint256 amount);
    event WithdrawTokens(address caller, uint256 amount);
    event MerkleRootUpdated(address caller, bytes32 merkleRoot);
    event SalesStepUpdated(address caller, uint256 salesStep);

    constructor(
        address _tokenAddress,
        bytes32 _merkleRoot,
        uint256 _maxBuyAmountPerWallet,
        uint256 _maxBuyAmountPerWalletForWLSales,
        uint256 _maxBuyAmountForWLSalesPeriod
    ) Ownable(msg.sender) {
        token = SPT(_tokenAddress);
        merkleRoot = _merkleRoot;
        maxBuyAmountPerWallet = _maxBuyAmountPerWallet;
        maxBuyAmountPerWalletForWLSales = _maxBuyAmountPerWalletForWLSales;
        maxBuyAmountForWLSalesPeriod = _maxBuyAmountForWLSalesPeriod;
    }

    /**
     * @notice Allow users to buy token for ETH
     */
    function buyTokens(
        bytes32[] calldata merkleProof
    ) public payable nonReentrant returns (uint256 tokenAmount) {
        require(salesStep != 0, "Sales not active");

        bool isWL = isWhitelisted(msg.sender, merkleProof);
        require(salesStep != 1 || isWL, "Private sales only");

        uint256 tokenDecimalsMultiplier = 10 ** token.decimals();

        uint256 price = salesStep == 1 ? PRICE_WL : PRICE;

        uint256 maxBuyAmount = salesStep == 1
            ? maxBuyAmountPerWalletForWLSales * tokenDecimalsMultiplier
            : maxBuyAmountPerWallet * tokenDecimalsMultiplier;

        uint256 transferAmount = (msg.value * tokenDecimalsMultiplier) / price;

        require(
            tokensCountPerAddress[msg.sender] + transferAmount <= maxBuyAmount,
            "Exceeded max buy amount per wallet"
        );
        require(
            token.balanceOf(address(this)) >= transferAmount,
            "Insufficient token balance in contract"
        );
        require(
            salesStep != 1 ||
                totalBought + transferAmount <=
                maxBuyAmountForWLSalesPeriod * tokenDecimalsMultiplier,
            "Max sales amount exceeded for private sales"
        );

        tokensCountPerAddress[msg.sender] += transferAmount;
        totalBought += transferAmount;

        bool success = token.transfer(msg.sender, transferAmount);
        require(success, "Transfer failed");

        emit BuyTokens(msg.sender, msg.value, transferAmount);
        return transferAmount;
    }

    function distributeTokens(
        address[] memory recipients,
        uint256[] memory amounts
    ) public onlyOwner {
        require(
            recipients.length == amounts.length,
            "Array lengths do not match"
        );

        uint256 n = recipients.length;
        uint256 totalAmount = 0;
        for (uint256 i = 0; i < n; i++) {
            totalAmount += amounts[i];
        }

        require(
            token.balanceOf(address(this)) >= totalAmount,
            "Insufficient token balance in contract"
        );

        for (uint256 i = 0; i < n; i++) {
            token.transfer(recipients[i], amounts[i]);
        }
    }

    /**
     * @notice Allow the owner of the contract to withdraw ETH
     */
    function withdrawEther() public onlyOwner {
        uint256 ownerBalance = address(this).balance;
        require(ownerBalance > 0, "Nothing to withdraw");

        (bool success, ) = payable(owner()).call{value: ownerBalance}("");
        require(success, "Transfer failed");

        emit WithdrawEther(msg.sender, ownerBalance);
    }

    function withdrawTokens(uint256 amountInWei) public onlyOwner {
        bool success = token.transfer(msg.sender, amountInWei);
        require(success, "Token removal failed");

        emit WithdrawTokens(msg.sender, amountInWei);
    }

    function setSaleStep(uint256 newStep) public onlyOwner {
        require(newStep >= 0 && newStep <= 2, "Invalid sale step");
        require(
            newStep != salesStep,
            "New step is the same as the current step"
        );

        salesStep = newStep;
        emit SalesStepUpdated(msg.sender, salesStep);
    }

    function setMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
        merkleRoot = _merkleRoot;
        emit MerkleRootUpdated(msg.sender, merkleRoot);
    }

    function ethBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function isWhitelisted(
        address _address,
        bytes32[] calldata merkleProof
    ) public view returns (bool) {
        bytes32 node = keccak256(abi.encodePacked(_address));
        return MerkleProof.verify(merkleProof, merkleRoot, node);
    }
}