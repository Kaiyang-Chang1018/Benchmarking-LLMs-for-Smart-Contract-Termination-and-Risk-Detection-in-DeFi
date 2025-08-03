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
// SPDX-License-Identifier: MIT
/** 
Telegram: https://t.me/MemesTokenOfficial
Twitter: https://twitter.com/MemestokenO
Discord: https://discord.gg/c6xkZSKGXT
Website: https://memestoken.com/
**/

pragma solidity ^0.8.21;

import '@openzeppelin/contracts/utils/Context.sol';
import '@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/cryptography/MerkleProof.sol';
import '@openzeppelin/contracts/utils/ReentrancyGuard.sol';

/**
 * @title Memes Token's token contract
 * @author Pwned (https://github.com/Pwnedev)
 */
contract MemesToken is Context, IERC20Metadata, Ownable, ReentrancyGuard {
    string private _name = "Memes Token";
    string private _symbol = "MEMES";
    uint8 private _decimals = 18;
    uint256 private _totalSupply = 100000000 * 10 ** _decimals; // Aka: "true total" or "tTotal"

    mapping(address => uint256) private _rOwned; // User's balance represented in r-space
    mapping(address => uint256) private _tOwned; // User's balance represented in t-space (only used by non-stakers)
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isExcludedFromReward;
    address[] private _excludedFromRewardAddresses;

    uint256 private constant MAX = ~uint256(0); // Max value of uint256 === (2^256)-1
    uint256 private _rTotal = (MAX - (MAX % _totalSupply)); // Aka: reflected total (_rTotal is always a multiple of _totalSupply)
    uint256 private _tFeeTotal;

    uint256 private constant MAX_TAX_FEE_VALUE = 9;
    uint256 public _taxFee = 6;
    uint256 private _previousTaxFee = _taxFee;

    bytes32 public _migrationMerkleRoot = 0;
    bool public _isMigrationTokenWithdrawalActive = false;
    mapping(address => bool) public _tokenMigrationClaimed;

    bool public _transfersPaused = false;

    modifier notPaused() {
        require(_transfersPaused == false, "All transfers are currently paused due to an emergency");
        _;
    }

    event TaxFeeChanged(uint256 oldValue, uint256 newValue);
    event TransfersPaused();
    event TransfersResumed();

    constructor() Ownable(_msgSender()) {
        _rOwned[_msgSender()] = _rTotal;

        // Exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;

        // Also exclude contract from reward
        _isExcludedFromReward[address(this)] = true;

        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    /**
     * @notice Returns token name
     * @dev See {IERC20Metadata}
     * @return Token name
     */
    function name() public view override returns (string memory) {
        return _name;
    }

    /**
     * @notice Returns token symbol
     * @dev See {IERC20Metadata}
     * @return Token symbol
     */
    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    /**
     * @notice Returns number of token decimals
     * @dev See {IERC20Metadata}
     * @return Number of token decimals
     */
    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    /**
     * @notice Returns number of all tokens in existence
     * @dev See {IERC20Metadata}
     * @return Number of all tokens in existence
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @notice Returns given `account`'s current balance
     * @dev See {IERC20Metadata}
     * @param account The account to get balance from
     * @return Given account's current balance
     */
    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcludedFromReward[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    /**
     * @notice Transfers given `ammount` of tokens from caller to `recipient`
     * @dev See {IERC20Metadata}
     * @param recipient The account that will receive the tokens
     * @param amount Amount of tokens that the `recipient` will receive
     * @return true if operation succeeded, false otherwise
     */
    function transfer(address recipient, uint256 amount) public override notPaused() returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @notice Returns amount of tokens `spender` is allowed to use on behalf of `owner` through {transferFrom}
     * @dev See {IERC20Metadata}
     * @param owner The account that owns the tokens
     * @param spender The account that may spend the tokens
     * @return Amount of tokens `spender` is allowed to use on behalf of `owner` through {transferFrom}
     */
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @notice Sets `amount` as the allowance of `spender` over the caller's tokens
     * @dev See {IERC20Metadata}
     * @param spender Spender account
     * @param amount Amount of tokens to set as allowance of `spender`
     * @return true if operation succeeded, false otherwise
     */
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @notice Moves `amount` tokens from `sender` to `recipient` using the allowance mechanism. `amount` is then deducted from the caller's allowance.
     * @dev See {IERC20Metadata}
     * @param sender Account that caller will take tokens from
     * @param recipient Account that receives the tokens
     * @param amount Amount of tokens to send from `sender` to `recipient`
     * @return true if operation succeeded, false otherwise
     */
    function transferFrom(address sender, address recipient, uint256 amount) public override notPaused() returns (bool) {
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }
        }

        _transfer(sender, recipient, amount);

        return true;
    }

    /**
     * @dev This function is only used internaly by the {transfer} function.
     */
    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        // Check if we should takeFee
        bool takeFee = true;
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        }
        
        _tokenTransfer(from, to, amount, takeFee);
    }

    /**
     * @dev This function is only used internaly by the {approve} function.
     */
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @notice Increases the allowance granted to `spender` by the caller.
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     * @param spender Target account to increase allowance
     * @param addedValue Amount of tokens added to allowance
     * @return true if operation succeeded, false otherwise
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @notice Decreases the allowance granted to `spender` by the caller.
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     * @param spender Target account to decrease allowance
     * @param subtractedValue Amount of tokens removed from allowance
     * @return true if operation succeeded, false otherwise
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Function to withdraw "ERC20" tokens from contract
     */
    function withdrawERC20(IERC20 _token) external onlyOwner() {
        uint256 balance = _token.balanceOf(address(this));
        _token.transfer(owner(), balance);
    }

    /**
     * @dev Function to withdraw "ETH" from contract
     */
    function withdrawETH() external onlyOwner() {
        uint256 balance = address(this).balance;
        payable(owner()).transfer(balance);
    }

    /**
     * @notice Returns true if given `account` is excluded from fee, false otherwise
     * @param account Target account to check if excluded from fee
     * @return true if given `account` is excluded from fee, false otherwise
     */
    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    /**
     * @dev Excludes target `account` from fee
     */
    function excludeFromFee(address account) external onlyOwner() {
        _isExcludedFromFee[account] = true;
    }

    /**
     * @dev Includes target `account` in fee
     */
    function includeInFee(address account) external onlyOwner() {
        _isExcludedFromFee[account] = false;
    }

    /**
     * @notice Returns true if given `account` is excluded from reward, false otherwise
     * @param account Target account to check if excluded from reward
     * @return true if given `account` is excluded from reward, false otherwise
     */
    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcludedFromReward[account];
    }

    /**
     * @dev Excludes target `account` from reward
     */
    function excludeFromReward(address account) external onlyOwner() {
        require(!_isExcludedFromReward[account], "Account is already excluded");

        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }

        _isExcludedFromReward[account] = true;
        _excludedFromRewardAddresses.push(account);
    }

    /**
     * @dev Includes target `account` in reward
     */
    function includeInReward(address account) external onlyOwner() {
        require(_isExcludedFromReward[account], "Account is already included");

        for (uint256 i = 0; i < _excludedFromRewardAddresses.length; i++) {
            if (_excludedFromRewardAddresses[i] == account) {
                _excludedFromRewardAddresses[i] = _excludedFromRewardAddresses[_excludedFromRewardAddresses.length - 1];
                _tOwned[account] = 0;
                _isExcludedFromReward[account] = false;
                _excludedFromRewardAddresses.pop();
                break;
            }
        }
    }

    /**
     * @dev Function to set fee percentage
     */
    function setTaxFeePercent(uint256 taxFee) external onlyOwner() {
        require(taxFee <= MAX_TAX_FEE_VALUE, "Tax fee must be less or equal to max tax fee value");
        emit TaxFeeChanged(_taxFee, taxFee);
        _taxFee = taxFee;
    }

    /**
     * @dev This function is only used by {_tokenTransfer} to remove fees when an "excluded from fee" address is making a transfer
     */
    function removeAllFee() private {
        if (_taxFee == 0) return;
        _previousTaxFee = _taxFee;
        _taxFee = 0;
    }

    /**
     * @dev This function is only used by {_tokenTransfer} to remove fees when an "excluded from fee" address is making a transfer
     */
    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
    }

    /**
     * @dev Updates fee total, used on token transfers
     */
    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal - rFee;
        _tFeeTotal = _tFeeTotal + tFee;
    }

    /**
     * @dev Total fees ever distributed
     */
    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    /**
     * @dev Converts a rSpace token amount to tSpace
     */
    function tokenFromReflection(uint256 rAmount) public view returns (uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate = _getRate();
        return rAmount/currentRate;
    }

    /**
     * @dev Returns reflection value from tAmount
     */
    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns (uint256) {
        require(tAmount <= _totalSupply, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,) = _getValues(tAmount);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    /**
     * @dev This function handles the fees on every token transfer
     */
    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {
        if (!takeFee) {
            removeAllFee();
        }
        
        if (_isExcludedFromReward[sender] && !_isExcludedFromReward[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcludedFromReward[sender] && _isExcludedFromReward[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (_isExcludedFromReward[sender] && _isExcludedFromReward[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else { // If both not excluded
            _transferStandard(sender, recipient, amount);
        }
        
        if (!takeFee) {
            restoreAllFee();
        }
    }

    // Transfer Cases
    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender] - tAmount;
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender] - tAmount;
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    // Reflection Helpers
    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee);
    }
    function _getTValues(uint256 tAmount) private view returns (uint256, uint256) {
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tTransferAmount = tAmount - tFee;

        return (tTransferAmount, tFee);
    }
    function _getRValues(uint256 tAmount, uint256 tFee, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount * currentRate;
        uint256 rFee = tFee * currentRate;
        uint256 rTransferAmount = rAmount - rFee;
        return (rAmount, rTransferAmount, rFee);
    }
    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply/tSupply;
    }
    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _totalSupply;
        for (uint256 i = 0; i < _excludedFromRewardAddresses.length; i++) {
            if (_rOwned[_excludedFromRewardAddresses[i]] > rSupply || _tOwned[_excludedFromRewardAddresses[i]] > tSupply) return (_rTotal, _totalSupply);
            rSupply = rSupply - (_rOwned[_excludedFromRewardAddresses[i]]);
            tSupply = tSupply - (_tOwned[_excludedFromRewardAddresses[i]]);
        }
        if (rSupply < (_rTotal/_totalSupply)) return (_rTotal, _totalSupply);
        return (rSupply, tSupply);
    }
    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return (_amount * _taxFee)/(10**2);
    }
    
    /**
     * @dev Enables {withdrawMyMigrationTokens} calls
     */
    function enableMigrationTokenWithdrawal() external onlyOwner() {
        require(_isMigrationTokenWithdrawalActive != true, "Migration token withdrawal is already enabled");
        _isMigrationTokenWithdrawalActive = true;
    }

    /**
     * @dev Disables {withdrawMyMigrationTokens} calls
     */
    function disableMigrationTokenWithdrawal() external onlyOwner() {
        require(_isMigrationTokenWithdrawalActive != false, "Migration token withdrawal is already disabled");
        _isMigrationTokenWithdrawalActive = false;
    }

    /**
     * @dev Sets new merkle root to use in {withdrawMyMigrationTokens}
     */
    function setMigrationMerkleRoot(bytes32 newMerkleRoot) external onlyOwner() {
        _migrationMerkleRoot = newMerkleRoot;
    }

    /**
     * @notice This function allows holders of the old contract to withdraw their memes in this contract
     * @dev See {MerkleProof}
     * @param merkleProof Proof containing sibling hashes on the branch from the leaf to the root of the tree
     * @param fundsToWithdraw Amount of tokens to withdraw
     */
    function withdrawMyMigrationTokens(bytes32[] calldata merkleProof, uint128 fundsToWithdraw) external nonReentrant() notPaused() {
        require(_isMigrationTokenWithdrawalActive == true, "Migration token withdrawal is disabled");
        require(!_tokenMigrationClaimed[_msgSender()], "This wallet already claimed it's tokens");
        require(fundsToWithdraw > 0, "Funds to withdraw must be greater than zero");
        require(fundsToWithdraw <= 3000000000000000000000000, "Funds to withdraw must be less than the given amount");

        bytes32 leaf = keccak256(abi.encodePacked(_msgSender(), fundsToWithdraw));

        require(
            MerkleProof.verify(merkleProof, _migrationMerkleRoot, leaf),
            "Invalid merkle proof"
        );

        _tokenMigrationClaimed[_msgSender()] = true;
        _transfer(address(this), _msgSender(), fundsToWithdraw);
    }

    /**
     * @notice Pauses all transfers. This will ONLY be used during an emergency or future migration. Giving a new layer of protection in some cases.
     * @dev Pauses transfers
     */
    function pauseTransfers() external onlyOwner() notPaused() {
        _transfersPaused = true;
        emit TransfersPaused();
    }

    /**
     * @notice Unpauses all transfers. This will ONLY be used during an emergency or future migration. Giving a new layer of protection in some cases.
     * @dev Unpauses transfers
     */
    function unpauseTransfers() external onlyOwner() {
        require(_transfersPaused != false, "Transfers are already unpaused");
        _transfersPaused = false;
        emit TransfersResumed();
    }

    receive() external payable {}
}