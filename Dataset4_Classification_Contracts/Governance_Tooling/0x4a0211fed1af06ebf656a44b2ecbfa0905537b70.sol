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
// SPDX-License-Identifier: Business Source License 1.1
pragma solidity ^0.8.0;

struct StakingArgs {
  address token;
  address aggregator;
  uint32 subscribeStageFrom;
  uint32 subscribeStagePeriod;
  uint32 earnStagePeriod;
  uint32 claimStagePeriod;
  uint64 maxTotalStake;
  uint64 maxUserStake;
  uint64 earningsQuota;
}

struct StakingData {
  address token;
  address aggregator;
  uint32 subscribeStageFrom;
  uint32 subscribeStageTo;
  uint32 earnStageTo;
  uint32 claimStageTo;
  uint64 currentTotalDeposit;
  uint64 maxTotalStake;
  uint64 maxUserStake;
  uint64 earningsQuota;
  uint64 earningPercent;
  uint64 unusedQuota;
}

interface IStaking {
  function increaseDeposit(address from, uint256 value) external;

  function withdrawDeposit(address from) external;

  function claim(address from) external;

  function getData() external view returns (StakingData memory);
}

contract StakingTypes {
  event DepositIncreased(address indexed user, uint256 value);
  event DepositWithdrawn(address indexed user);
  event Claimed(address indexed user, uint256 total);

  error TokenTotalSupplyExceedsUint64();
  error DepositTooEarly();
  error DepositTooLate();
  error BalanceTooLow();
  error MaxUserStakeExceeded();
  error MaxTotalStakeExceeded();
  error ZeroBalance();
  error TooEarlyForClaimStage();
  error ZeroValue();
  error ZeroUnusedQuota();
  error UnusedQuotaAlreadyTransferred();
  error SubscribeStageNotFinished();
  error ClaimStageNotFinished();
  error CallerIsNotAggregator();
}
// SPDX-License-Identifier: Business Source License 1.1
pragma solidity ^0.8.0;

import './IStaking.sol';

contract IStakingAggregator {
  error StakingInvalidAggregatorAddress();
}

struct StakingInstanceData {
  address addr;
  StakingData data;
}
// SPDX-License-Identifier: Business Source License 1.1
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/access/Ownable.sol';

import './IStaking.sol';
import './IStakingAggregator.sol';

contract StakingAggregator is IStakingAggregator, Ownable {
  IStaking[] public instances;
  mapping(address => IStaking) public assigned;

  function addInstance(IStaking instance) external onlyOwner {
    if (instance.getData().aggregator != address(this)) {
      revert StakingInvalidAggregatorAddress();
    }

    instances.push(instance);
  }

  function isAssigned(address sender) external view returns (bool) {
    return address(assigned[sender]) != address(0);
  }

  function increaseDeposit(uint256 instanceIndex, uint256 value) external {
    return _getStakingInstance(msg.sender, instanceIndex).increaseDeposit(msg.sender, value);
  }

  function withdrawDeposit(uint256 instanceIndex) external {
    _getStakingInstance(msg.sender, instanceIndex).withdrawDeposit(msg.sender);

    assigned[msg.sender] = IStaking(address(0));
  }

  function claim(uint256 instanceIndex) external {
    return _getStakingInstance(msg.sender, instanceIndex).claim(msg.sender);
  }

  function getInstances() external view returns (StakingInstanceData[] memory) {
    StakingInstanceData[] memory arr = new StakingInstanceData[](instances.length);

    for (uint256 i = 0; i < instances.length; i++) {
      arr[i] = StakingInstanceData({addr: address(instances[i]), data: instances[i].getData()});
    }

    return arr;
  }

  function _getStakingInstance(address sender, uint256 index) internal returns (IStaking) {
    if (address(assigned[sender]) != address(0)) return assigned[sender];

    assigned[sender] = instances[index];

    return instances[index];
  }
}