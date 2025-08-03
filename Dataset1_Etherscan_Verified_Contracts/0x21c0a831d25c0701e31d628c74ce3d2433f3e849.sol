// SPDX-License-Identifier: MIT

pragma solidity >=0.7.6 <0.8.0;

/**
 * @title ERC-173 Contract Ownership Standard
 * Note: the ERC-165 identifier for this interface is 0x7f5828d0
 */
interface IERC173 {
    /**
     * Event emited when ownership of a contract changes.
     * @param previousOwner the previous owner.
     * @param newOwner the new owner.
     */
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * Get the address of the owner
     * @return The address of the owner.
     */
    function owner() external view returns (address);

    /**
     * Set the address of the new owner of the contract
     * Set newOwner to address(0) to renounce any ownership.
     * @dev Emits an {OwnershipTransferred} event.
     * @param newOwner The address of the new owner of the contract. Using the zero address means renouncing ownership.
     */
    function transferOwnership(address newOwner) external;
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.7.6 <0.8.0;

import {ManagedIdentity} from "../metatx/ManagedIdentity.sol";
import {IERC173} from "./IERC173.sol";

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
abstract contract Ownable is ManagedIdentity, IERC173 {
    address internal _owner;

    /**
     * Initializes the contract, setting the deployer as the initial owner.
     * @dev Emits an {IERC173-OwnershipTransferred(address,address)} event.
     */
    constructor(address owner_) {
        _owner = owner_;
        emit OwnershipTransferred(address(0), owner_);
    }

    /**
     * Gets the address of the current contract owner.
     */
    function owner() public view virtual override returns (address) {
        return _owner;
    }

    /**
     * See {IERC173-transferOwnership(address)}
     * @dev Reverts if the sender is not the current contract owner.
     * @param newOwner the address of the new owner. Use the zero address to renounce the ownership.
     */
    function transferOwnership(address newOwner) public virtual override {
        _requireOwnership(_msgSender());
        _owner = newOwner;
        emit OwnershipTransferred(_owner, newOwner);
    }

    /**
     * @dev Reverts if `account` is not the contract owner.
     * @param account the account to test.
     */
    function _requireOwnership(address account) internal virtual {
        require(account == this.owner(), "Ownable: not the owner");
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.7.6 <0.8.0;

/*
 * Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner.
 */
abstract contract ManagedIdentity {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        return msg.data;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev These functions deal with verification of Merkle trees (hash trees),
 */
library MerkleProof {
    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     */
    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (computedHash <= proofElement) {
                // Hash(current computed hash + current element of the proof)
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                // Hash(current element of the proof + current computed hash)
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }

        // Check if the computed hash (root) is equal to the provided root
        return computedHash == root;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
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
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6 <0.8.0;

import {MerkleProof} from "@openzeppelin/contracts/cryptography/MerkleProof.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@animoca/ethereum-contracts-core/contracts/access/Ownable.sol";

/// @title PayoutClaimDistributor
/// @notice Through this contract, users could claim ERC20 token s/he is eligible to claim the rewards.
///      - The owner/deployer of the contract could set merkle root, distributor address or lock/unlock the distribution.
///      - Owner sets the ERC20 Token address (`token`) when deploying the contract, the owner also
///        sets distributor address (`distAddress`) through `setDistributorAddress` function from which to distribute the tokens.
///      - Owner should also approve the amount of ERC20 tokens allowed to distribute through this contract.
///      - For owner to set new merkle root through `setMerkleRoot` function, contract distribution should be locked though
///         `setLocked`.
///      - To enable distribution again, it should be unlocked with `setLocked` function.
///      - Users could claim the ERC20 token payout when the distributor is unlocked.

contract PayoutClaimDistributor is Ownable {
    using MerkleProof for bytes32[];

    event SetMerkleRoot(bytes32 indexed merkleRoot);
    event ClaimedPayout(address indexed account, uint256 amount, uint256 batch);
    event DistributionLocked(bool isLocked);
    event SetDistributorAddress(address indexed ownerAddress, address indexed distAddress);

    bytes32 public merkleRoot;
    IERC20 public token;
    address public distAddress;
    bool public isLocked;

    /*
     * Mapping for hash for (address, amount, batch) for claimed status
     */
    mapping(bytes32 => bool) public claimed;

    /// @dev Constructor for setting ERC token address on deployment
    /// @param token_ Address for token to distribute
    /// @dev `distAddress` deployer address will be distributor address by default
    constructor(IERC20 token_) Ownable(msg.sender) {
        token = token_;
        distAddress = msg.sender;
    }

    /// @notice Merkle Root for current period to use for payout.
    ///    - distributor contract should be locked before setting new merkle root
    /// @dev Owner sets merkle hash generated based on the payout set
    /// @dev Reverts if the distribution contract is not locked while setting new merkle root
    /// @dev Emits SetMerkleRoot event.
    /// @param merkleRoot_ bytes32 string of merkle root to set for specific period
    function setMerkleRoot(bytes32 merkleRoot_) public {
        _requireOwnership(_msgSender());
        require(isLocked, "Payout not locked");

        merkleRoot = merkleRoot_;
        emit SetMerkleRoot(merkleRoot_);
    }

    /// @notice Set locked/unlocked status  for PayoutClaim Distributor
    /// @dev Owner lock/unlock each time new merkle root is being generated
    /// @dev Emits DistributionLocked event.
    /// @param isLocked_ = true/false status
    function setLocked(bool isLocked_) public {
        _requireOwnership(_msgSender());
        isLocked = isLocked_;
        emit DistributionLocked(isLocked_);
    }

    /// @notice Distributor address in PayoutClaim Distributor
    /// @dev Wallet that holds token for distribution
    /// @dev Emits SetDistributorAddress event.
    /// @param distributorAddress Distributor address used for distribution of `token` token
    function setDistributorAddress(address distributorAddress) public {
        address msgSender = _msgSender();
        _requireOwnership(msgSender);

        distAddress = distributorAddress;
        emit SetDistributorAddress(msgSender, distributorAddress);
    }

    /// @notice Payout method that user calls to claim
    /// @dev Method user calls for claiming the payout for user
    /// @dev Emits ClaimedPayout event.
    /// @param account Address of the user to claim the payout
    /// @param amount Claimable amount of address
    /// @param batch Unique value for each new merkle root generating
    /// @param merkleProof Merkle proof of the user based on the merkle root
    function claimPayout(address account, uint256 amount, uint256 batch, bytes32[] calldata merkleProof) external {
        require(!isLocked, "Payout locked");

        bytes32 leafHash = keccak256(abi.encodePacked(account, amount, batch));

        require(!claimed[leafHash], "Payout already claimed");
        require(merkleProof.verify(merkleRoot, leafHash), "Invalid proof");

        claimed[leafHash] = true;

        IERC20(token).transferFrom(distAddress, account, amount);

        emit ClaimedPayout(account, amount, batch);
    }
}