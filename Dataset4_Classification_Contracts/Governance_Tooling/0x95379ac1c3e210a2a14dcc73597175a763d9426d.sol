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
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

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
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface PulseBitcoinLockNFTRewardsInterface {
  function pulseBitcoinLockNftContractAddress() external view returns (address);
  function tokenIdsToRegistered(uint tokenId) external view returns (bool);
  function tokenIdsToLastWithdrawalDay(uint tokenId) external view returns (uint);
  function tokenIdsToEndRewardsDay(uint tokenId) external view returns (uint);
  function tokenIdsToDailyRewardAmount(uint tokenId) external view returns (uint);

  function registerNftForRewards(uint tokenId) external;
  function withdrawRewards(uint tokenId) external;

  function currentDay() external view returns (uint256);
}

interface PulseBitcoinLockNFTInterface {
  function ownerOf(uint256 tokenId) external returns (address);
}

contract PulseBitcoinLockNFTRewardsBulk is Ownable, ReentrancyGuard {
  PulseBitcoinLockNFTRewardsInterface public plsbLockRewards;

  address public txnFeeSendTo;
  uint public baseTxnFee;

  event TxnError(uint tokenId, string reason);
  event TxnErrorBytes(uint tokenId, bytes reason);
  event NotOwnerError(uint tokenId);

  struct NftVariables {
    uint tokenId;
    bool isRegistered;
    bool canWithdrawal;
    uint withdrawalAmount;
  }

  constructor(address _txnFeeSendTo) {
    txnFeeSendTo = _txnFeeSendTo;
    baseTxnFee = 0.0007 ether;
  }

  receive() payable external {
    payable(txnFeeSendTo).transfer(msg.value);
  }

  function _senderIsTokenOwner(uint tokenId) internal returns(bool) {
    return msg.sender == PulseBitcoinLockNFTInterface(
      plsbLockRewards.pulseBitcoinLockNftContractAddress()
    ).ownerOf(tokenId);
  }

  function _txnFee(uint tokenIdLength) internal view returns(uint) {
    uint txnFee = baseTxnFee * tokenIdLength;

    if(txnFee < baseTxnFee * 10) {
      txnFee = baseTxnFee * 10;
    }

    return txnFee;
  }

  function fetchNftVariables(
    uint[] calldata tokenIds
  ) public view returns(NftVariables[] memory) {

    NftVariables[] memory variablesArray;
    variablesArray = new NftVariables[](tokenIds.length);

    for(uint i; i < tokenIds.length;) {
      uint tokenId = tokenIds[i];

      NftVariables memory nftVariables = NftVariables({
        tokenId: tokenId,
        isRegistered: false,
        canWithdrawal: false,
        withdrawalAmount: 0
      });

      if(plsbLockRewards.tokenIdsToRegistered(tokenId)) {
        nftVariables.isRegistered = true;

        // Can withdraw today?
        if(
            plsbLockRewards.tokenIdsToLastWithdrawalDay(tokenId) < 
            plsbLockRewards.tokenIdsToEndRewardsDay(tokenId)
          &&
            plsbLockRewards.currentDay() > 
            plsbLockRewards.tokenIdsToLastWithdrawalDay(tokenId)
          ) {
          nftVariables.canWithdrawal = true;

          // Calc rewards
          uint256 totalDaysOfRewardsLeft =
            plsbLockRewards.tokenIdsToEndRewardsDay(tokenId) -
            plsbLockRewards.tokenIdsToLastWithdrawalDay(tokenId);

          uint256 numOfDaysSinceLastWithdrawal =
            plsbLockRewards.currentDay() -
            plsbLockRewards.tokenIdsToLastWithdrawalDay(tokenId);

          if (numOfDaysSinceLastWithdrawal > totalDaysOfRewardsLeft) {
            numOfDaysSinceLastWithdrawal = totalDaysOfRewardsLeft;
          }

          nftVariables.withdrawalAmount =
            plsbLockRewards.tokenIdsToDailyRewardAmount(tokenId) *
            numOfDaysSinceLastWithdrawal;
        }
      }

      variablesArray[i] = nftVariables;

      unchecked {
        i++;
      }
    }

    return variablesArray;
  }

  function bulkRegister(uint[] calldata tokenIds) public payable nonReentrant {
    uint tokenIdsLength = tokenIds.length;
    uint txnFee = _txnFee(tokenIdsLength);

    if(msg.value != txnFee) {
      revert("Txn Fee invalid");
    }

    payable(txnFeeSendTo).transfer(txnFee);

    for( uint i; i < tokenIdsLength; ) {
      if(!_senderIsTokenOwner(tokenIds[i])) {
        emit NotOwnerError(tokenIds[i]);
        continue;
      }

      try plsbLockRewards.registerNftForRewards(tokenIds[i]) {
        // Do nothing
      } catch Error(string memory reason) {
        emit TxnError(tokenIds[i], reason);
      } catch (bytes memory reason) {
        emit TxnErrorBytes(tokenIds[i], reason);
      }

      unchecked {
        i++;
      }
    }

  }

  function bulkWithdraw(uint[] calldata tokenIds) public payable nonReentrant {
    uint tokenIdsLength = tokenIds.length;
    uint txnFee = _txnFee(tokenIdsLength);

    if(msg.value != txnFee) {
      revert("Txn Fee invalid");
    }

    payable(txnFeeSendTo).transfer(txnFee);

    for( uint i; i < tokenIdsLength; ) {
      if(!_senderIsTokenOwner(tokenIds[i])) {
        emit NotOwnerError(tokenIds[i]);
        continue;
      }

      try plsbLockRewards.withdrawRewards(tokenIds[i]) {
        // Do nothing
      } catch Error(string memory reason) {
        emit TxnError(tokenIds[i], reason);
      } catch (bytes memory reason) {
        emit TxnErrorBytes(tokenIds[i], reason);
      }

      unchecked {
        i++;
      }
    }

  }

  function configureLockRewards(address _plsbLockRewardsAddress) public onlyOwner {
    plsbLockRewards = PulseBitcoinLockNFTRewardsInterface(_plsbLockRewardsAddress);
  }
}