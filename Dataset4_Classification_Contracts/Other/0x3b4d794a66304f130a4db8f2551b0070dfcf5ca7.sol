// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity 0.8.25;

/// @title Interface of the upgradeable contract
/// @author Matter Labs (https://github.com/matter-labs/zksync/blob/master/contracts/contracts/Upgradeable.sol)
interface IUpgradeable {
  /// @notice Upgrades target of upgradeable contract
  /// @param newTarget New target
  /// @param newTargetInitializationParameters New target initialization parameters
  function upgradeTarget(address newTarget, bytes calldata newTargetInitializationParameters) external;
}
// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity 0.8.25;

/// @title Ownable Contract
/// @author Matter Labs (https://github.com/matter-labs/zksync/blob/master/contracts/contracts/Ownable.sol)
contract Ownable {
  /// @dev Storage position of the masters address (keccak256('eip1967.proxy.admin') - 1)
  bytes32 private constant MASTER_POSITION = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

  /// @notice Contract constructor
  /// @dev Sets msg sender address as masters address
  /// @param masterAddress Master address
  constructor(address masterAddress) {
    require(masterAddress != address(0), "1b"); // oro11 - master address can't be zero address
    setMaster(masterAddress);
  }

  /// @notice Check if specified address is master
  /// @param _address Address to check
  function requireMaster(address _address) internal view {
    require(_address == getMaster(), "1c"); // oro11 - only by master
  }

  /// @notice Returns contract masters address
  /// @return master Master's address
  function getMaster() public view returns (address master) {
    bytes32 position = MASTER_POSITION;
    assembly {
      master := sload(position)
    }
  }

  /// @dev Sets new masters address
  /// @param _newMaster New master's address
  function setMaster(address _newMaster) internal {
    bytes32 position = MASTER_POSITION;
    assembly {
      sstore(position, _newMaster)
    }
  }

  /// @notice Transfer mastership of the contract to new master
  /// @param _newMaster New masters address
  function transferMastership(address _newMaster) external {
    requireMaster(msg.sender);
    require(_newMaster != address(0), "1d"); // otp11 - new masters address can't be zero address
    setMaster(_newMaster);
  }
}
// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity 0.8.25;

import "./Ownable.sol";
import "./IUpgradeable.sol";

/// @title Proxy Contract
/// @author Matter Labs (https://github.com/matter-labs/zksync/blob/master/contracts/contracts/Proxy.sol)
/// @notice Modified to not implement UpgradeableMaster, UpgradeGatekeeper implements the UpgradeableMaster interface
contract Proxy is IUpgradeable, Ownable {
  /// @dev Storage position of "target" (actual implementation address: keccak256('eip1967.proxy.implementation') - 1)
  bytes32 private constant TARGET_POSITION = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

  /// @notice Contract constructor
  /// @dev Calls Ownable contract constructor and initialize target
  /// @param target Initial implementation address
  /// @param targetInitializationParameters Target initialization parameters
  constructor(address target, bytes memory targetInitializationParameters) Ownable(msg.sender) {
    setTarget(target);
    (bool initializationSuccess, ) = getTarget().delegatecall(abi.encodeWithSignature("initialize(bytes)", targetInitializationParameters));
    require(initializationSuccess, "uin11"); // uin11 - target initialization failed
  }

  /// @notice Intercepts initialization calls
  function initialize(bytes calldata) external pure {
    revert("ini11"); // ini11 - interception of initialization call
  }

  /// @notice Intercepts upgrade calls
  function upgrade(bytes calldata) external pure {
    revert("upg11"); // upg11 - interception of upgrade call
  }

  /// @notice Returns target of contract
  /// @return target Actual implementation address
  function getTarget() public view returns (address target) {
    bytes32 position = TARGET_POSITION;
    assembly {
      target := sload(position)
    }
  }

  /// @notice Sets new target of contract
  /// @param _newTarget New actual implementation address
  function setTarget(address _newTarget) internal {
    bytes32 position = TARGET_POSITION;
    assembly {
      sstore(position, _newTarget)
    }
  }

  /// @notice Upgrades target
  /// @param newTarget New target
  /// @param newTargetUpgradeParameters New target upgrade parameters
  function upgradeTarget(address newTarget, bytes calldata newTargetUpgradeParameters) external override {
    requireMaster(msg.sender);

    setTarget(newTarget);
    (bool upgradeSuccess, ) = getTarget().delegatecall(abi.encodeWithSignature("upgrade(bytes)", newTargetUpgradeParameters));
    require(upgradeSuccess, "ufu11"); // ufu11 - target upgrade failed
  }

  /// @notice Performs a delegatecall to the contract implementation
  /// @dev Fallback function allowing to perform a delegatecall to the given implementation
  /// This function will return whatever the implementation call returns
  function _fallback() internal {
    address _target = getTarget();
    assembly {
      // The pointer to the free memory slot
      let ptr := mload(0x40)
      // Copy function signature and arguments from calldata at zero position into memory at pointer position
      calldatacopy(ptr, 0x0, calldatasize())
      // Delegatecall method of the implementation contract, returns 0 on error
      let result := delegatecall(gas(), _target, ptr, calldatasize(), 0x0, 0)
      // Get the size of the last return data
      let size := returndatasize()
      // Copy the size length of bytes from return data at zero position to pointer position
      returndatacopy(ptr, 0x0, size)
      // Depending on result value
      switch result
      case 0 {
        // End execution and revert state changes
        revert(ptr, size)
      }
      default {
        // Return data with length of size at pointers position
        return(ptr, size)
      }
    }
  }

  /// @notice Will run when no functions matches call data
  fallback() external payable {
    _fallback();
  }

  /// @notice Same as fallback but called when calldata is empty
  receive() external payable {
    _fallback();
  }
}