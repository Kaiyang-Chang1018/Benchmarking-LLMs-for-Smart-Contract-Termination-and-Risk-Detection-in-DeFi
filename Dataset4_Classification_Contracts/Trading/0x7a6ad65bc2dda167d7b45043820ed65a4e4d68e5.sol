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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/cryptography/MerkleProof.sol)

pragma solidity ^0.8.0;

/**
 * @dev These functions deal with verification of Merkle Tree proofs.
 *
 * The proofs can be generated using the JavaScript library
 * https://github.com/miguelmota/merkletreejs[merkletreejs].
 * Note: the hashing algorithm should be keccak256 and pair sorting should be enabled.
 *
 * See `test/utils/cryptography/MerkleProof.test.js` for some examples.
 *
 * WARNING: You should avoid using leaf values that are 64 bytes long prior to
 * hashing, or use a hash function other than keccak256 for hashing leaves.
 * This is because the concatenation of a sorted pair of internal nodes in
 * the merkle tree could be reinterpreted as a leaf value.
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
     * @dev Returns true if the `leaves` can be proved to be a part of a Merkle tree defined by
     * `root`, according to `proof` and `proofFlags` as described in {processMultiProof}.
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
     * @dev Returns the root of a tree reconstructed from `leaves` and the sibling nodes in `proof`,
     * consuming from one or the other at each step according to the instructions given by
     * `proofFlags`.
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
     * @dev Calldata version of {processMultiProof}
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
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./interfaces/ISloth.sol";
import "./interfaces/ISlothItemV2.sol";
import "./interfaces/ISpecialSlothItem.sol";
import "./interfaces/ISlothMintV2.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract SlothMintV6 is Ownable, ISlothMintV2 {
  address private _slothAddr;
  address private _slothItemAddr;
  address private _specialSlothItemAddr;
  address private _piementAddress;
  bool public publicSale;
  mapping(uint256 => bool) public forSaleCollabo;
  mapping(uint256 => uint256) public collaboSaleEndTimes;
  mapping(uint256 => uint256) public collaboSalePricePatterns;

  uint256 public immutable maxPerAddressDuringMint;
  uint256 public immutable collectionSize;
  uint256 public immutable itemCollectionSize;
  uint256 public immutable clothesSize;
  uint256 public immutable itemSize;
  uint256 public currentItemCount;
  uint256 public currentClothesCount;
  mapping(uint256 => uint256) public collaboItemSizes;
  mapping(uint256 => uint256) public currentCollaboItemCounts;

  uint256 private constant _MINT_WITH_CLOTHES_PRICE = 0.021 ether;
  uint256 private constant _MINT_WITH_COLLABO_PRICE = 0.03 ether;
  uint256 private constant _MINT_WITH_COLLABO_PRICE2 = 0.04 ether;
  uint256 private constant _MINT_COLLABO_PRICE = 0.01 ether;
  uint256 private constant _MINT_COLLABO_PRICE2 = 0.02 ether;
  address private _treasuryAddress = 0x452Ccc6d4a818D461e20837B417227aB70C72B56;

  constructor(uint256 newMaxPerAddressDuringMint, uint256 newCollectionSize, uint256 newItemCollectionSize, uint256 newClothesSize, uint256 newItemSize, uint256 newCurrentClothesCount, uint256 newCurrentItemCount) {
    maxPerAddressDuringMint = newMaxPerAddressDuringMint;
    collectionSize = newCollectionSize;
    itemCollectionSize = newItemCollectionSize;
    clothesSize = newClothesSize;
    itemSize = newItemSize;
    currentClothesCount = newCurrentClothesCount;
    currentItemCount = newCurrentItemCount;
  }

  function setSlothAddr(address newSlothAddr) external onlyOwner {
    _slothAddr = newSlothAddr;
  }
  function setSlothItemAddr(address newSlothItemAddr) external onlyOwner {
    _slothItemAddr = newSlothItemAddr;
  }
  function setSpecialSlothItemAddr(address newSpecialSlothItemAddr) external onlyOwner {
    _specialSlothItemAddr = newSpecialSlothItemAddr;
  }
  function setPiementAddress(address newPiementAddress) external onlyOwner {
    _piementAddress = newPiementAddress;
  }

  function _itemMint(uint256 quantity, address to) private {
    require(currentItemCount + quantity <= itemSize, "exceeds item size");

    ISlothItemV2(_slothItemAddr).itemMint(to, quantity);
    currentItemCount += quantity;
  }

  function publicMintWithClothes(uint8 quantity) payable external {
    require(msg.value == _MINT_WITH_CLOTHES_PRICE * quantity, "wrong price");
    require(ISloth(_slothAddr).numberMinted(msg.sender) + quantity <= maxPerAddressDuringMint, "wrong num");

    _publicMint(quantity, msg.sender);
    emit mintWithCloth(quantity);
  }

  function _publicMint(uint8 quantity, address to) private {
    require(publicSale, "inactive");
    require(ISloth(_slothAddr).totalSupply() + quantity <= collectionSize, "exceeds collection size");
    require(currentClothesCount + quantity <= clothesSize, "exceeds clothes size");

    ISloth(_slothAddr).mint(to, quantity);
    ISlothItemV2(_slothItemAddr).clothesMint(to, quantity);
    currentClothesCount += quantity;
  }

  function publicMintWithClothesAndItem(uint8 quantity, uint8 itemQuantity) payable external {
    require(msg.value == itemPrice(itemQuantity) + _MINT_WITH_CLOTHES_PRICE * quantity, "wrong price");
    require(ISlothItemV2(_slothItemAddr).totalSupply() + (quantity + itemQuantity) <= itemCollectionSize, "exceeds item collection size");
    require(ISloth(_slothAddr).numberMinted(msg.sender) + quantity <= maxPerAddressDuringMint, "wrong num");
    require(ISlothItemV2(_slothItemAddr).getItemMintCount(msg.sender) + itemQuantity <= 99, "wrong item num");

    _publicMint(quantity, msg.sender);
    _itemMint(itemQuantity, msg.sender);
    emit mintWithClothAndItem(quantity, itemQuantity, false);
  }

  function publicItemMint(uint8 quantity) payable external {
    require(publicSale, "inactive");
    require(msg.value == itemPrice(quantity), "wrong price");
    require(ISlothItemV2(_slothItemAddr).totalSupply() + quantity <= itemCollectionSize, "exceeds item collection size");
    require(ISlothItemV2(_slothItemAddr).getItemMintCount(msg.sender) + quantity <= 99, "wrong item num");

    _itemMint(quantity, msg.sender);
    emit mintItem(quantity);
  }

  function mintForPiement(address transferAddress, uint256 itemQuantity) payable public {
    uint8 quantity = 1;
    require(msg.value == itemPrice(itemQuantity) + _MINT_WITH_CLOTHES_PRICE * quantity, "wrong price");
    require(ISlothItemV2(_slothItemAddr).totalSupply() + (quantity + itemQuantity) <= itemCollectionSize, "exceeds item collection size");
    if (msg.sender == owner()) {
      _publicMint(quantity, transferAddress);
      _itemMint(itemQuantity, transferAddress);
      return;
    }
    require(msg.sender == _piementAddress, "worng address");

    _publicMint(quantity, transferAddress);
    _itemMint(itemQuantity, transferAddress);
  }
  function mintForPiementItem1(address transferAddress) payable public {
    mintForPiement(transferAddress, 1);
    emit mintWithClothAndItem(1, 1, true);
  }
  function mintForPiementItem3(address transferAddress) payable public {
    mintForPiement(transferAddress, 3);
    emit mintWithClothAndItem(1, 3, true);
  }
  function mintForPiementItem6(address transferAddress) payable public {
    mintForPiement(transferAddress, 6);
    emit mintWithClothAndItem(1, 6, true);
  }
  function mintForPiementItem9(address transferAddress) payable public {
    mintForPiement(transferAddress, 9);
    emit mintWithClothAndItem(1, 9, true);
  }

  function _isSaleEnded(uint256 specialType) internal view returns (bool) {
    if (collaboSaleEndTimes[specialType] == 0) {
      return false;
    }
    return block.timestamp >= collaboSaleEndTimes[specialType];
  }

  function checkAllowCollaboMint(uint8 quantity, uint256 specialType) internal view {
    require(forSaleCollabo[specialType], "inactive collabo");
    require(!_isSaleEnded(specialType), "ended");
    require(currentCollaboItemCounts[specialType] + quantity <= collaboItemSizes[specialType], "collabo sold out");
  }

  function collaboMintValue(uint8 quantity, uint256 specialType) internal view returns (uint256) {
    if (collaboSalePricePatterns[specialType] == 1) {
      return _MINT_COLLABO_PRICE2 * quantity;
    }
    return _MINT_COLLABO_PRICE * quantity;
  }

  function withCollaboMintValue(uint8 quantity, uint256 specialType) internal view returns (uint256) {
    if (collaboSalePricePatterns[specialType] == 1) {
      return _MINT_WITH_COLLABO_PRICE2 * quantity;
    }
    return _MINT_WITH_COLLABO_PRICE * quantity;
  }

  function mintCollaboWithBody(uint8 quantity, uint256 specialType) internal {
    checkAllowCollaboMint(quantity, specialType);
    require(ISlothItemV2(_slothItemAddr).totalSupply() + quantity <= itemCollectionSize, "exceeds item collection size");
    require(msg.value ==  withCollaboMintValue(quantity, specialType), "wrong price");

    _publicMint(quantity, msg.sender);
    ISpecialSlothItem(_specialSlothItemAddr).mintCollaboCloth(msg.sender, quantity, specialType);
    currentCollaboItemCounts[specialType] += quantity;
  }

  function mintCollaboCloth(uint8 quantity, uint256 specialType) internal {
    checkAllowCollaboMint(quantity, specialType);
    require(msg.value ==  collaboMintValue(quantity, specialType), "wrong price");
    require(ISloth(_slothAddr).balanceOf(msg.sender) > 0, "need sloth");
    ISpecialSlothItem(_specialSlothItemAddr).mintCollaboCloth(msg.sender, quantity, specialType);
    currentCollaboItemCounts[specialType] += quantity;
  }

  function publicMintWithClothesAndCollaboForPiement(address transferAddress, uint256 specialType) payable external {
    checkAllowCollaboMint(1, specialType);
    require(ISlothItemV2(_slothItemAddr).totalSupply() + 1 <= itemCollectionSize, "exceeds item collection size");
    require(currentClothesCount + 1 <= clothesSize, "exceeds clothes size");
    require(msg.value ==  withCollaboMintValue(1, specialType), "wrong price");
    if (msg.sender == owner()) {
      _publicMint(1, transferAddress);
      ISpecialSlothItem(_specialSlothItemAddr).mintCollaboCloth(transferAddress, 1, specialType);
      currentCollaboItemCounts[specialType] += 1;
      return;
    }
    require(msg.sender == _piementAddress, "worng address");
    _publicMint(1, transferAddress);
    ISpecialSlothItem(_specialSlothItemAddr).mintCollaboCloth(transferAddress, 1, specialType);
    currentCollaboItemCounts[specialType] += 1;
    emit mintWithClothAndCollabo(1, specialType, true);
  }

  function publicMintWithClothesAndVerylongAnimals(uint8 quantity) payable external {
    mintCollaboWithBody(quantity, 3);
    emit mintWithClothAndCollabo(quantity, 3, false);
  }
  function pulicMintOnlyVerylongAnimals(uint8 quantity) payable external {
    mintCollaboCloth(quantity, 3);
    emit mintCollabo(quantity, 3);
  }

  function publicMintWithClothesAndTakanotsumedan(uint8 quantity) payable external {
    mintCollaboWithBody(quantity, 4);
    emit mintWithClothAndCollabo(quantity, 4, false);
  }
  function pulicMintOnlyTakanotsumedan(uint8 quantity) payable external {
    mintCollaboCloth(quantity, 4);
    emit mintCollabo(quantity, 4);
  }

  function publicMintWithClothesAndMocomocoworkers(uint8 quantity) payable external {
    mintCollaboWithBody(quantity, 5);
    emit mintWithClothAndCollabo(quantity, 5, false);
  }
  function pulicMintOnlyMocomocoworkers(uint8 quantity) payable external {
    mintCollaboCloth(quantity, 5);
    emit mintCollabo(quantity, 5);
  }

  function publicMintWithClothesAndTorichan(uint8 quantity) payable external {
    mintCollaboWithBody(quantity, 6);
    emit mintWithClothAndCollabo(quantity, 6, false);
  }
  function pulicMintOnlyTorichan(uint8 quantity) payable external {
    mintCollaboCloth(quantity, 6);
    emit mintCollabo(quantity, 6);
  }

  function publicMintWithClothesAndGyozao(uint8 quantity) payable external {
    mintCollaboWithBody(quantity, 7);
    emit mintWithClothAndCollabo(quantity, 7, false);
  }
  function pulicMintOnlyGyozao(uint8 quantity) payable external {
    mintCollaboCloth(quantity, 7);
    emit mintCollabo(quantity, 7);
  }

  function publicMintWithClothesAndAstroOtto(uint8 quantity) payable external {
    mintCollaboWithBody(quantity, 8);
    emit mintWithClothAndCollabo(quantity, 8, false);
  }
  function pulicMintOnlyAstroOtto(uint8 quantity) payable external {
    mintCollaboCloth(quantity, 8);
    emit mintCollabo(quantity, 8);
  }

  function publicMintWithClothesAndYoshioka(uint8 quantity) payable external {
    mintCollaboWithBody(quantity, 9);
    emit mintWithClothAndCollabo(quantity, 9, false);
  }
  function pulicMintOnlyYoshioka(uint8 quantity) payable external {
    mintCollaboCloth(quantity, 9);
    emit mintCollabo(quantity, 9);
  }

  function publicMintWithClothesAndDJRIO(uint8 quantity) payable external {
    mintCollaboWithBody(quantity, 10);
    emit mintWithClothAndCollabo(quantity, 10, false);
  }
  function pulicMintOnlyDJRIO(uint8 quantity) payable external {
    mintCollaboCloth(quantity, 10);
    emit mintCollabo(quantity, 10);
  }

  function publicMintWithClothesAndShimonzgate(uint8 quantity) payable external {
    mintCollaboWithBody(quantity, 11);
    emit mintWithClothAndCollabo(quantity, 11, false);
  }
  function pulicMintOnlyShimonzgate(uint8 quantity) payable external {
    mintCollaboCloth(quantity, 11);
    emit mintCollabo(quantity, 11);
  }

  function setPublicSale(bool newPublicSale) external onlyOwner {
    publicSale = newPublicSale;
  }
  function setSaleCollabo(uint256[] calldata specialTypeArray, bool[] calldata newSaleCollaboArray) external onlyOwner {
    for (uint256 i = 0; i < specialTypeArray.length; i++) {
      forSaleCollabo[specialTypeArray[i]] = newSaleCollaboArray[i];
    }
  }
  function setCollaboItemSizes(uint256[] calldata specialTypeArray, uint256[] calldata itemSizeArray) external onlyOwner {
    for (uint256 i = 0; i < specialTypeArray.length; i++) {
      collaboItemSizes[specialTypeArray[i]] = itemSizeArray[i];
    }
  }
  function setCollaboSaleEndTimes(uint256[] calldata specialTypeArray, uint256[] calldata endTimeArray) external onlyOwner {
    for (uint256 i = 0; i < specialTypeArray.length; i++) {
      collaboSaleEndTimes[specialTypeArray[i]] = endTimeArray[i];
    }
  }
  function setCollaboSalePricePatterns(uint256[] calldata specialTypeArray, uint256[] calldata pricePatternArray) external onlyOwner {
    for (uint256 i = 0; i < specialTypeArray.length; i++) {
      collaboSalePricePatterns[specialTypeArray[i]] = pricePatternArray[i];
    }
  }
 
  function itemPrice(uint256 quantity) internal pure returns(uint256) {
    uint256 price = 0;
    if (quantity == 1) {
      price = 20;
    } else if (quantity == 2) {
      price = 39;
    } else if (quantity == 3) {
      price = 56;
    } else if (quantity == 4) {
      price = 72;
    } else if (quantity == 5) {
      price = 88;
    } else if (quantity == 6) {
      price = 100;
    } else if (quantity == 7) {
      price = 115 ;
    } else if (quantity == 8) {
      price = 125 ;
    } else if (quantity == 9) {
      price = 135;
    } else {
      price = 15 * quantity;
    }
    return price * 1 ether / 1000;
  }

  function withdraw() external onlyOwner {
    (bool sent,) = _treasuryAddress.call{value: address(this).balance}("");
    require(sent, "Failed to send Ether");
  }

  function ownerMint(uint8 quantity, uint256 itemQuantity) external onlyOwner {
    require(ISlothItemV2(_slothItemAddr).totalSupply() + (quantity + itemQuantity) <= itemCollectionSize, "exceeds item collection size");

    if (quantity > 0) {
      _publicMint(quantity, msg.sender);
    }
    if (itemQuantity > 0) {
      _itemMint(itemQuantity, msg.sender);
    }
  }
}
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IItemType {
  enum ItemType { CLOTHES, HEAD, HAND, FOOT, STAMP }
  enum ItemMintType { SLOTH_ITEM, SPECIAL_SLOTH_ITEM, USER_GENERATED_SLOTH_ITEM }
}
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import { IERC721AQueryableUpgradeable } from "erc721a-upgradeable/contracts/interfaces/IERC721AQueryableUpgradeable.sol";

interface ISloth is IERC721AQueryableUpgradeable {
  function mint(address sender, uint8 quantity) external;
  function numberMinted(address sender) external view returns (uint256);
}
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import { IERC721AQueryableUpgradeable } from "erc721a-upgradeable/contracts/interfaces/IERC721AQueryableUpgradeable.sol";

interface ISlothItemV2 is IERC721AQueryableUpgradeable {
  enum ItemType { CLOTHES, HEAD, HAND, FOOT, STAMP }

  function getItemType(uint256 tokenId) external view returns (ItemType);
  function getItemMintCount(address sender) external view returns (uint256);
  function exists(uint256 tokenId) external view returns (bool);
  function clothesMint(address sender, uint256 quantity) external;
  function itemMint(address sender, uint256 quantity) external;
}
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title Interface for Auction Houses
 */
interface ISlothMintV2 {
  event mintWithCloth(
    uint256 quantity
  );
  event mintWithClothAndItem(
    uint256 quantity,
    uint256 itemQuantity,
    bool piement
  );
  event mintWithClothAndPoupelle(
    uint256 quantity,
    bool piement
  );
  event mintPoupelle(
    uint256 quantity
  );
  event mintItem(
    uint256 quantity
  );
  event mintWithClothAndCollabo(
    uint256 quantity,
    uint256 specialType,
    bool piement
  );
  event mintCollabo(
    uint256 quantity,
    uint256 specialType
  );
}
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./IItemType.sol";
import { IERC721AQueryableUpgradeable } from "erc721a-upgradeable/contracts/interfaces/IERC721AQueryableUpgradeable.sol";

interface ISpecialSlothItem is IERC721AQueryableUpgradeable, IItemType {
  function getItemType(uint256 tokenId) external view returns (ItemType);
  function getSpecialType(uint256 tokenId) external view returns (uint256);
  function getClothType(uint256 tokenId) external view returns (uint256);
  function exists(uint256 tokenId) external view returns (bool);
  function isCombinational(uint256 _specialType) external view returns (bool);
  function mintPoupelle(address sender, uint256 quantity) external;
  function mintCollaboCloth(address sender, uint256 quantity, uint256 _specialType) external;
}
// SPDX-License-Identifier: MIT
// ERC721A Contracts v4.2.2
// Creator: Chiru Labs

pragma solidity ^0.8.4;

/**
 * @dev Interface of ERC721A.
 */
interface IERC721AUpgradeable {
    /**
     * The caller must own the token or be an approved operator.
     */
    error ApprovalCallerNotOwnerNorApproved();

    /**
     * The token does not exist.
     */
    error ApprovalQueryForNonexistentToken();

    /**
     * The caller cannot approve to their own address.
     */
    error ApproveToCaller();

    /**
     * Cannot query the balance for the zero address.
     */
    error BalanceQueryForZeroAddress();

    /**
     * Cannot mint to the zero address.
     */
    error MintToZeroAddress();

    /**
     * The quantity of tokens minted must be more than zero.
     */
    error MintZeroQuantity();

    /**
     * The token does not exist.
     */
    error OwnerQueryForNonexistentToken();

    /**
     * The caller must own the token or be an approved operator.
     */
    error TransferCallerNotOwnerNorApproved();

    /**
     * The token must be owned by `from`.
     */
    error TransferFromIncorrectOwner();

    /**
     * Cannot safely transfer to a contract that does not implement the
     * ERC721Receiver interface.
     */
    error TransferToNonERC721ReceiverImplementer();

    /**
     * Cannot transfer to the zero address.
     */
    error TransferToZeroAddress();

    /**
     * The token does not exist.
     */
    error URIQueryForNonexistentToken();

    /**
     * The `quantity` minted with ERC2309 exceeds the safety limit.
     */
    error MintERC2309QuantityExceedsLimit();

    /**
     * The `extraData` cannot be set on an unintialized ownership slot.
     */
    error OwnershipNotInitializedForExtraData();

    // =============================================================
    //                            STRUCTS
    // =============================================================

    struct TokenOwnership {
        // The address of the owner.
        address addr;
        // Stores the start time of ownership with minimal overhead for tokenomics.
        uint64 startTimestamp;
        // Whether the token has been burned.
        bool burned;
        // Arbitrary data similar to `startTimestamp` that can be set via {_extraData}.
        uint24 extraData;
    }

    // =============================================================
    //                         TOKEN COUNTERS
    // =============================================================

    /**
     * @dev Returns the total number of tokens in existence.
     * Burned tokens will reduce the count.
     * To get the total number of tokens minted, please see {_totalMinted}.
     */
    function totalSupply() external view returns (uint256);

    // =============================================================
    //                            IERC165
    // =============================================================

    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * [EIP section](https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified)
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);

    // =============================================================
    //                            IERC721
    // =============================================================

    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables
     * (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in `owner`'s account.
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
     * @dev Safely transfers `tokenId` token from `from` to `to`,
     * checking first that contract recipients are aware of the ERC721 protocol
     * to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move
     * this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement
     * {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
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
     * @dev Equivalent to `safeTransferFrom(from, to, tokenId, '')`.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom}
     * whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token
     * by either {approve} or {setApprovalForAll}.
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
     * Only a single account can be approved at a time, so approving the
     * zero address clears previous approvals.
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
     * Operators can call {transferFrom} or {safeTransferFrom}
     * for any token owned by the caller.
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
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    // =============================================================
    //                        IERC721Metadata
    // =============================================================

    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);

    // =============================================================
    //                           IERC2309
    // =============================================================

    /**
     * @dev Emitted when tokens in `fromTokenId` to `toTokenId`
     * (inclusive) is transferred from `from` to `to`, as defined in the
     * [ERC2309](https://eips.ethereum.org/EIPS/eip-2309) standard.
     *
     * See {_mintERC2309} for more details.
     */
    event ConsecutiveTransfer(uint256 indexed fromTokenId, uint256 toTokenId, address indexed from, address indexed to);
}
// SPDX-License-Identifier: MIT
// ERC721A Contracts v4.2.2
// Creator: Chiru Labs

pragma solidity ^0.8.4;

import '../IERC721AUpgradeable.sol';

/**
 * @dev Interface of ERC721AQueryable.
 */
interface IERC721AQueryableUpgradeable is IERC721AUpgradeable {
    /**
     * Invalid query range (`start` >= `stop`).
     */
    error InvalidQueryRange();

    /**
     * @dev Returns the `TokenOwnership` struct at `tokenId` without reverting.
     *
     * If the `tokenId` is out of bounds:
     *
     * - `addr = address(0)`
     * - `startTimestamp = 0`
     * - `burned = false`
     * - `extraData = 0`
     *
     * If the `tokenId` is burned:
     *
     * - `addr = <Address of owner before token was burned>`
     * - `startTimestamp = <Timestamp when token was burned>`
     * - `burned = true`
     * - `extraData = <Extra data when token was burned>`
     *
     * Otherwise:
     *
     * - `addr = <Address of owner>`
     * - `startTimestamp = <Timestamp of start of ownership>`
     * - `burned = false`
     * - `extraData = <Extra data at start of ownership>`
     */
    function explicitOwnershipOf(uint256 tokenId) external view returns (TokenOwnership memory);

    /**
     * @dev Returns an array of `TokenOwnership` structs at `tokenIds` in order.
     * See {ERC721AQueryable-explicitOwnershipOf}
     */
    function explicitOwnershipsOf(uint256[] memory tokenIds) external view returns (TokenOwnership[] memory);

    /**
     * @dev Returns an array of token IDs owned by `owner`,
     * in the range [`start`, `stop`)
     * (i.e. `start <= tokenId < stop`).
     *
     * This function allows for tokens to be queried if the collection
     * grows too big for a single call of {ERC721AQueryable-tokensOfOwner}.
     *
     * Requirements:
     *
     * - `start < stop`
     */
    function tokensOfOwnerIn(
        address owner,
        uint256 start,
        uint256 stop
    ) external view returns (uint256[] memory);

    /**
     * @dev Returns an array of token IDs owned by `owner`.
     *
     * This function scans the ownership mapping and is O(`totalSupply`) in complexity.
     * It is meant to be called off-chain.
     *
     * See {ERC721AQueryable-tokensOfOwnerIn} for splitting the scan into
     * multiple smaller scans if the collection is large enough to cause
     * an out-of-gas error (10K collections should be fine).
     */
    function tokensOfOwner(address owner) external view returns (uint256[] memory);
}
// SPDX-License-Identifier: MIT
// ERC721A Contracts v4.2.2
// Creator: Chiru Labs

pragma solidity ^0.8.4;

import '../extensions/IERC721AQueryableUpgradeable.sol';