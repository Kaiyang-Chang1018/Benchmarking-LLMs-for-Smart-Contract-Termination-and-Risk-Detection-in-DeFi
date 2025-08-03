// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Library for bit twiddling and boolean operations.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/LibBit.sol)
/// @author Inspired by (https://graphics.stanford.edu/~seander/bithacks.html)
library LibBit {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                  BIT TWIDDLING OPERATIONS                  */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Find last set.
    /// Returns the index of the most significant bit of `x`,
    /// counting from the least significant bit position.
    /// If `x` is zero, returns 256.
    function fls(uint256 x) internal pure returns (uint256 r) {
        /// @solidity memory-safe-assembly
        assembly {
            r := or(shl(8, iszero(x)), shl(7, lt(0xffffffffffffffffffffffffffffffff, x)))
            r := or(r, shl(6, lt(0xffffffffffffffff, shr(r, x))))
            r := or(r, shl(5, lt(0xffffffff, shr(r, x))))
            r := or(r, shl(4, lt(0xffff, shr(r, x))))
            r := or(r, shl(3, lt(0xff, shr(r, x))))
            r := or(r, shl(2, lt(0xf, shr(r, x))))
            r := or(r, byte(shr(r, x), hex"00000101020202020303030303030303"))
        }
    }

    /// @dev Count leading zeros.
    /// Returns the number of zeros preceding the most significant one bit.
    /// If `x` is zero, returns 256.
    function clz(uint256 x) internal pure returns (uint256 r) {
        /// @solidity memory-safe-assembly
        assembly {
            r := shl(7, lt(0xffffffffffffffffffffffffffffffff, x))
            r := or(r, shl(6, lt(0xffffffffffffffff, shr(r, x))))
            r := or(r, shl(5, lt(0xffffffff, shr(r, x))))
            r := or(r, shl(4, lt(0xffff, shr(r, x))))
            r := or(r, shl(3, lt(0xff, shr(r, x))))
            r := or(r, shl(2, lt(0xf, shr(r, x))))
            // forgefmt: disable-next-item
            r := add(iszero(x), xor(255,
                or(r, byte(shr(r, x), hex"00000101020202020303030303030303"))))
        }
    }

    /// @dev Find first set.
    /// Returns the index of the least significant bit of `x`,
    /// counting from the least significant bit position.
    /// If `x` is zero, returns 256.
    /// Equivalent to `ctz` (count trailing zeros), which gives
    /// the number of zeros following the least significant one bit.
    function ffs(uint256 x) internal pure returns (uint256 r) {
        /// @solidity memory-safe-assembly
        assembly {
            // Isolate the least significant bit.
            let b := and(x, add(not(x), 1))

            r := or(shl(8, iszero(x)), shl(7, lt(0xffffffffffffffffffffffffffffffff, b)))
            r := or(r, shl(6, lt(0xffffffffffffffff, shr(r, b))))
            r := or(r, shl(5, lt(0xffffffff, shr(r, b))))

            // For the remaining 32 bits, use a De Bruijn lookup.
            // forgefmt: disable-next-item
            r := or(r, byte(and(div(0xd76453e0, shr(r, b)), 0x1f),
                0x001f0d1e100c1d070f090b19131c1706010e11080a1a141802121b1503160405))
        }
    }

    /// @dev Returns the number of set bits in `x`.
    function popCount(uint256 x) internal pure returns (uint256 c) {
        /// @solidity memory-safe-assembly
        assembly {
            let max := not(0)
            let isMax := eq(x, max)
            x := sub(x, and(shr(1, x), div(max, 3)))
            x := add(and(x, div(max, 5)), and(shr(2, x), div(max, 5)))
            x := and(add(x, shr(4, x)), div(max, 17))
            c := or(shl(8, isMax), shr(248, mul(x, div(max, 255))))
        }
    }

    /// @dev Returns whether `x` is a power of 2.
    function isPo2(uint256 x) internal pure returns (bool result) {
        /// @solidity memory-safe-assembly
        assembly {
            // Equivalent to `x && !(x & (x - 1))`.
            result := iszero(add(and(x, sub(x, 1)), iszero(x)))
        }
    }

    /// @dev Returns `x` reversed at the bit level.
    function reverseBits(uint256 x) internal pure returns (uint256 r) {
        /// @solidity memory-safe-assembly
        assembly {
            // Computing masks on-the-fly reduces bytecode size by about 500 bytes.
            let m := not(0)
            r := x
            for { let s := 128 } 1 {} {
                m := xor(m, shl(s, m))
                r := or(and(shr(s, r), m), and(shl(s, r), not(m)))
                s := shr(1, s)
                if iszero(s) { break }
            }
        }
    }

    /// @dev Returns `x` reversed at the byte level.
    function reverseBytes(uint256 x) internal pure returns (uint256 r) {
        /// @solidity memory-safe-assembly
        assembly {
            // Computing masks on-the-fly reduces bytecode size by about 200 bytes.
            let m := not(0)
            r := x
            for { let s := 128 } 1 {} {
                m := xor(m, shl(s, m))
                r := or(and(shr(s, r), m), and(shl(s, r), not(m)))
                s := shr(1, s)
                if eq(s, 4) { break }
            }
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                     BOOLEAN OPERATIONS                     */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // A Solidity bool on the stack or memory is represented as a 256-bit word.
    // Non-zero values are true, zero is false.
    // A clean bool is either 0 (false) or 1 (true) under the hood.
    // Usually, if not always, the bool result of a regular Solidity expression,
    // or the argument of a public/external function will be a clean bool.
    // You can usually use the raw variants for more performance.
    // If uncertain, test (best with exact compiler settings).
    // Or use the non-raw variants (compiler can sometimes optimize out the double `iszero`s).

    /// @dev Returns `x & y`. Inputs must be clean.
    function rawAnd(bool x, bool y) internal pure returns (bool z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := and(x, y)
        }
    }

    /// @dev Returns `x & y`.
    function and(bool x, bool y) internal pure returns (bool z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := and(iszero(iszero(x)), iszero(iszero(y)))
        }
    }

    /// @dev Returns `x | y`. Inputs must be clean.
    function rawOr(bool x, bool y) internal pure returns (bool z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := or(x, y)
        }
    }

    /// @dev Returns `x | y`.
    function or(bool x, bool y) internal pure returns (bool z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := or(iszero(iszero(x)), iszero(iszero(y)))
        }
    }

    /// @dev Returns 1 if `b` is true, else 0. Input must be clean.
    function rawToUint(bool b) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := b
        }
    }

    /// @dev Returns 1 if `b` is true, else 0.
    function toUint(bool b) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := iszero(iszero(b))
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import './access/IHooks.sol';
import './interfaces/WildcatStructsAndEnums.sol';

struct HooksTemplate {
  /// @dev Asset used to pay origination fee
  address originationFeeAsset;
  /// @dev Amount of `originationFeeAsset` paid to deploy a new market using
  ///      an instance of this template.
  uint80 originationFeeAmount;
  /// @dev Basis points paid on interest for markets deployed using hooks
  ///      based on this template
  uint16 protocolFeeBips;
  /// @dev Whether the template exists
  bool exists;
  /// @dev Whether the template is enabled
  bool enabled;
  /// @dev Index of the template address in the array of hooks templates
  uint24 index;
  /// @dev Address to pay origination and interest fees
  address feeRecipient;
  /// @dev Name of the template
  string name;
}

interface IHooksFactoryEventsAndErrors {
  error FeeMismatch();
  error NotApprovedBorrower();
  error HooksTemplateNotFound();
  error HooksTemplateNotAvailable();
  error HooksTemplateAlreadyExists();
  error DeploymentFailed();
  error HooksInstanceNotFound();
  error CallerNotArchControllerOwner();
  error InvalidFeeConfiguration();
  error SaltDoesNotContainSender();
  error MarketAlreadyExists();
  error HooksInstanceAlreadyExists();
  error NameOrSymbolTooLong();
  error AssetBlacklisted();
  error SetProtocolFeeBipsFailed();

  event HooksInstanceDeployed(address hooksInstance, address hooksTemplate);
  event HooksTemplateAdded(
    address hooksTemplate,
    string name,
    address feeRecipient,
    address originationFeeAsset,
    uint80 originationFeeAmount,
    uint16 protocolFeeBips
  );
  event HooksTemplateDisabled(address hooksTemplate);
  event HooksTemplateFeesUpdated(
    address hooksTemplate,
    address feeRecipient,
    address originationFeeAsset,
    uint80 originationFeeAmount,
    uint16 protocolFeeBips
  );

  event MarketDeployed(
    address indexed hooksTemplate,
    address indexed market,
    string name,
    string symbol,
    address asset,
    uint256 maxTotalSupply,
    uint256 annualInterestBips,
    uint256 delinquencyFeeBips,
    uint256 withdrawalBatchDuration,
    uint256 reserveRatioBips,
    uint256 delinquencyGracePeriod,
    HooksConfig hooks
  );
}

interface IHooksFactory is IHooksFactoryEventsAndErrors {
  function archController() external view returns (address);

  function sanctionsSentinel() external view returns (address);

  function marketInitCodeStorage() external view returns (address);

  function marketInitCodeHash() external view returns (uint256);

  /// @dev Set-up function to register the factory as a controller with the arch-controller.
  ///      This enables the factory to register new markets.
  function registerWithArchController() external;

  function name() external view returns (string memory);

  // ========================================================================== //
  //                               Hooks Templates                              //
  // ========================================================================== //

  /// @dev Add a hooks template that stores the initcode for the template.
  ///
  ///      On success:
  ///      - Emits `HooksTemplateAdded` on success.
  ///      - Adds the template to the list of templates.
  ///      - Creates `HooksTemplate` struct with the given parameters mapped to the template address.
  ///
  ///      Reverts if:
  ///      - The caller is not the owner of the arch-controller.
  ///      - The template already exists.
  ///      - The fee settings are invalid.
  function addHooksTemplate(
    address hooksTemplate,
    string calldata name,
    address feeRecipient,
    address originationFeeAsset,
    uint80 originationFeeAmount,
    uint16 protocolFeeBips
  ) external;

  /// @dev Update the fees for a hooks template.
  ///
  ///      On success:
  ///      - Emits `HooksTemplateFeesUpdated` on success.
  ///      - Updates the fees for the `HooksTemplate` struct mapped to the template address.
  ///
  ///      Reverts if:
  ///      - The caller is not the owner of the arch-controller.
  ///      - The template does not exist.
  ///      - The fee settings are invalid.
  function updateHooksTemplateFees(
    address hooksTemplate,
    address feeRecipient,
    address originationFeeAsset,
    uint80 originationFeeAmount,
    uint16 protocolFeeBips
  ) external;

  /// @dev Disable a hooks template.
  ///
  ///      On success:
  ///      - Emits `HooksTemplateDisabled` on success.
  ///      - Disables the `HooksTemplate` struct mapped to the template address.
  ///
  ///      Reverts if:
  ///      - The caller is not the owner of the arch-controller.
  ///      - The template does not exist.
  function disableHooksTemplate(address hooksTemplate) external;

  /// @dev Get the name and fee configuration for an approved hooks template.
  function getHooksTemplateDetails(
    address hooksTemplate
  ) external view returns (HooksTemplate memory);

  /// @dev Check if a hooks template is approved.
  function isHooksTemplate(address hooksTemplate) external view returns (bool);

  /// @dev Get the list of approved hooks templates.
  function getHooksTemplates() external view returns (address[] memory);

  function getHooksTemplates(
    uint256 start,
    uint256 end
  ) external view returns (address[] memory arr);

  function getHooksTemplatesCount() external view returns (uint256);

  function getMarketsForHooksTemplate(
    address hooksTemplate
  ) external view returns (address[] memory);

  function getMarketsForHooksTemplate(
    address hooksTemplate,
    uint256 start,
    uint256 end
  ) external view returns (address[] memory arr);

  function getMarketsForHooksTemplateCount(address hooksTemplate) external view returns (uint256);

  // ========================================================================== //
  //                               Hooks Instances                              //
  // ========================================================================== //

  /// @dev Deploy a hooks instance for an approved template with constructor args.
  ///
  ///      On success:
  ///      - Emits `HooksInstanceDeployed`.
  ///      - Deploys a new hooks instance with the given templates and constructor args.
  ///      - Maps the hooks instance to the template address.
  ///
  ///      Reverts if:
  ///      - The caller is not an approved borrower.
  ///      - The template does not exist.
  ///      - The template is not enabled.
  ///      - The deployment fails.
  function deployHooksInstance(
    address hooksTemplate,
    bytes calldata constructorArgs
  ) external returns (address hooksDeployment);

  function getHooksInstancesForBorrower(address borrower) external view returns (address[] memory);

  function getHooksInstancesCountForBorrower(address borrower) external view returns (uint256);

  /// @dev Check if a hooks instance was deployed by the factory.
  function isHooksInstance(address hooks) external view returns (bool);

  /// @dev Get the template that was used to deploy a hooks instance.
  function getHooksTemplateForInstance(address hooks) external view returns (address);

  // ========================================================================== //
  //                                   Markets                                  //
  // ========================================================================== //
  function getMarketsForHooksInstance(
    address hooksInstance
  ) external view returns (address[] memory);

  function getMarketsForHooksInstance(
    address hooksInstance,
    uint256 start,
    uint256 len
  ) external view returns (address[] memory arr);

  function getMarketsForHooksInstanceCount(address hooksInstance) external view returns (uint256);

  /// @dev Get the temporarily stored market parameters for a market that is
  ///      currently being deployed.
  function getMarketParameters() external view returns (MarketParameters memory parameters);

  /// @dev Deploy a market with an existing hooks deployment (in `parameters.hooks`)
  ///
  ///      On success:
  ///      - Pays the origination fee (if applicable).
  ///      - Calls `onDeployMarket` on the hooks contract.
  ///      - Deploys a new market with the given parameters.
  ///      - Emits `MarketDeployed`.
  ///
  ///      Reverts if:
  ///      - The caller is not an approved borrower.
  ///      - The hooks instance does not exist.
  ///      - Payment of origination fee fails.
  ///      - The deployment fails.
  ///      - The call to `onDeployMarket` fails.
  ///      - `originationFeeAsset` does not match the hook template's
  ///      - `originationFeeAmount` does not match the hook template's
  function deployMarket(
    DeployMarketInputs calldata parameters,
    bytes calldata hooksData,
    bytes32 salt,
    address originationFeeAsset,
    uint256 originationFeeAmount
  ) external returns (address market);

  /// @dev Deploy a hooks instance for an approved template,then deploy a new market with that
  ///      instance as its hooks contract.
  ///      Will call `onCreateMarket` on `parameters.hooks`.
  function deployMarketAndHooks(
    address hooksTemplate,
    bytes calldata hooksConstructorArgs,
    DeployMarketInputs calldata parameters,
    bytes calldata hooksData,
    bytes32 salt,
    address originationFeeAsset,
    uint256 originationFeeAmount
  ) external returns (address market, address hooks);

  function computeMarketAddress(bytes32 salt) external view returns (address);

  function pushProtocolFeeBipsUpdates(
    address hooksTemplate,
    uint marketStartIndex,
    uint marketEndIndex
  ) external;

  function pushProtocolFeeBipsUpdates(address hooksTemplate) external;
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.20;

/// @dev Selector for `error NoReentrantCalls()`
uint256 constant NoReentrantCalls_ErrorSelector = 0x7fa8a987;

uint256 constant _REENTRANCY_GUARD_SLOT = 0x929eee14;

/**
 * @title ReentrancyGuard
 * @author d1ll0n
 * @notice Changes from original:
 *   - Removed the checks for whether tstore is supported.
 * @author Modified from Seaport contract by 0age (https://github.com/ProjectOpenSea/seaport-1.6)
 *
 * @notice ReentrancyGuard contains a transient storage variable and related
 *         functionality for protecting against reentrancy.
 */
contract ReentrancyGuard {
  /**
   * @dev Revert with an error when a caller attempts to reenter a protected function.
   *
   *      Note: Only defined for the sake of the interface and readability - the
   *      definition is not directly referenced in the contract code.
   */
  error NoReentrantCalls();

  uint256 private constant _NOT_ENTERED = 0;
  uint256 private constant _ENTERED = 1;

  /**
   * @dev Reentrancy guard for state-changing functions.
   *      Reverts if the reentrancy guard is currently set; otherwise, sets
   *      the reentrancy guard, executes the function body, then clears the
   *      reentrancy guard.
   */
  modifier nonReentrant() {
    _setReentrancyGuard();
    _;
    _clearReentrancyGuard();
  }

  /**
   * @dev Reentrancy guard for view functions.
   *      Reverts if the reentrancy guard is currently set.
   */
  modifier nonReentrantView() {
    _assertNonReentrant();
    _;
  }

  /**
   * @dev Internal function to ensure that a sentinel value for the reentrancy
   *      guard is not currently set and, if not, to set a sentinel value for
   *      the reentrancy guard.
   */
  function _setReentrancyGuard() internal {
    assembly {
      // Retrieve the current value of the reentrancy guard slot.
      let _reentrancyGuard := tload(_REENTRANCY_GUARD_SLOT)

      // Ensure that the reentrancy guard is not already set.
      // Equivalent to `if (_reentrancyGuard != _NOT_ENTERED) revert NoReentrantCalls();`
      if _reentrancyGuard {
        mstore(0, NoReentrantCalls_ErrorSelector)
        revert(0x1c, 0x04)
      }

      // Set the reentrancy guard.
      // Equivalent to `_reentrancyGuard = _ENTERED;`
      tstore(_REENTRANCY_GUARD_SLOT, _ENTERED)
    }
  }

  /**
   * @dev Internal function to unset the reentrancy guard sentinel value.
   */
  function _clearReentrancyGuard() internal {
    assembly {
      // Equivalent to `_reentrancyGuard = _NOT_ENTERED;`
      tstore(_REENTRANCY_GUARD_SLOT, _NOT_ENTERED)
    }
  }

  /**
   * @dev Internal view function to ensure that a sentinel value for the
   *         reentrancy guard is not currently set.
   */
  function _assertNonReentrant() internal view {
    assembly {
      // Ensure that the reentrancy guard is not currently set.
      // Equivalent to `if (_reentrancyGuard != _NOT_ENTERED) revert NoReentrantCalls();`
      if tload(_REENTRANCY_GUARD_SLOT) {
        mstore(0, NoReentrantCalls_ErrorSelector)
        revert(0x1c, 0x04)
      }
    }
  }
}
// SPDX-License-Identifier: Apache-2.0 WITH LicenseRef-Commons-Clause-1.0
pragma solidity >=0.8.20;

import './interfaces/IERC20.sol';
import './interfaces/IWildcatSanctionsEscrow.sol';
import './interfaces/IWildcatSanctionsSentinel.sol';
import './libraries/LibERC20.sol';

contract WildcatSanctionsEscrow is IWildcatSanctionsEscrow {
  using LibERC20 for address;

  address public immutable override sentinel;
  address public immutable override borrower;
  address public immutable override account;
  address internal immutable asset;

  constructor() {
    sentinel = msg.sender;
    (borrower, account, asset) = IWildcatSanctionsSentinel(sentinel).tmpEscrowParams();
  }

  function balance() public view override returns (uint256) {
    return IERC20(asset).balanceOf(address(this));
  }

  function canReleaseEscrow() public view override returns (bool) {
    return !IWildcatSanctionsSentinel(sentinel).isSanctioned(borrower, account);
  }

  function escrowedAsset() public view override returns (address, uint256) {
    return (asset, balance());
  }

  function releaseEscrow() public override {
    if (!canReleaseEscrow()) revert CanNotReleaseEscrow();

    uint256 amount = balance();
    address _account = account;
    address _asset = asset;

    asset.safeTransfer(_account, amount);

    emit EscrowReleased(_account, _asset, amount);
  }
}
// SPDX-License-Identifier: Apache-2.0 WITH LicenseRef-Commons-Clause-1.0
pragma solidity >=0.8.20;

import { IChainalysisSanctionsList } from './interfaces/IChainalysisSanctionsList.sol';
import { IWildcatSanctionsSentinel } from './interfaces/IWildcatSanctionsSentinel.sol';
import { WildcatSanctionsEscrow } from './WildcatSanctionsEscrow.sol';

contract WildcatSanctionsSentinel is IWildcatSanctionsSentinel {
  // ========================================================================== //
  //                                  Constants                                 //
  // ========================================================================== //

  bytes32 public constant override WildcatSanctionsEscrowInitcodeHash =
    keccak256(type(WildcatSanctionsEscrow).creationCode);

  address public immutable override chainalysisSanctionsList;

  address public immutable override archController;

  // ========================================================================== //
  //                                   Storage                                  //
  // ========================================================================== //

  TmpEscrowParams public override tmpEscrowParams;

  mapping(address borrower => mapping(address account => bool sanctionOverride))
    public
    override sanctionOverrides;

  // ========================================================================== //
  //                                 Constructor                                //
  // ========================================================================== //

  constructor(address _archController, address _chainalysisSanctionsList) {
    archController = _archController;
    chainalysisSanctionsList = _chainalysisSanctionsList;
    _resetTmpEscrowParams();
  }

  // ========================================================================== //
  //                              Internal Helpers                              //
  // ========================================================================== //

  function _resetTmpEscrowParams() internal {
    tmpEscrowParams = TmpEscrowParams(address(1), address(1), address(1));
  }

  /**
   * @dev Derive create2 salt for an escrow given the borrower, account and asset.
   *      name prefix and symbol prefix.
   */
  function _deriveSalt(
    address borrower,
    address account,
    address asset
  ) internal pure returns (bytes32 salt) {
    assembly {
      // Cache free memory pointer
      let freeMemoryPointer := mload(0x40)
      // `keccak256(abi.encode(borrower, account, asset))`
      mstore(0x00, borrower)
      mstore(0x20, account)
      mstore(0x40, asset)
      salt := keccak256(0, 0x60)
      // Restore free memory pointer
      mstore(0x40, freeMemoryPointer)
    }
  }

  // ========================================================================== //
  //                              Sanction Queries                              //
  // ========================================================================== //

  /**
   * @dev Returns boolean indicating whether `account` is sanctioned on Chainalysis.
   */
  function isFlaggedByChainalysis(address account) public view override returns (bool) {
    return IChainalysisSanctionsList(chainalysisSanctionsList).isSanctioned(account);
  }

  /**
   * @dev Returns boolean indicating whether `account` is sanctioned on Chainalysis
   *      and that status has not been overridden by `borrower`.
   */
  function isSanctioned(address borrower, address account) public view override returns (bool) {
    return !sanctionOverrides[borrower][account] && isFlaggedByChainalysis(account);
  }

  // ========================================================================== //
  //                             Sanction Overrides                             //
  // ========================================================================== //

  /**
   * @dev Overrides the sanction status of `account` for `borrower`.
   */
  function overrideSanction(address account) public override {
    sanctionOverrides[msg.sender][account] = true;
    emit SanctionOverride(msg.sender, account);
  }

  /**
   * @dev Removes the sanction override of `account` for `borrower`.
   */
  function removeSanctionOverride(address account) public override {
    sanctionOverrides[msg.sender][account] = false;
    emit SanctionOverrideRemoved(msg.sender, account);
  }

  // ========================================================================== //
  //                              Escrow Deployment                             //
  // ========================================================================== //

  /**
   * @dev Creates a new WildcatSanctionsEscrow contract for `borrower`,
   *      `account`, and `asset` or returns the existing escrow contract
   *      if one already exists.
   *
   *      The escrow contract is added to the set of sanction override
   *      addresses for `borrower` so that it can not be blocked.
   */
  function createEscrow(
    address borrower,
    address account,
    address asset
  ) public override returns (address escrowContract) {
    escrowContract = getEscrowAddress(borrower, account, asset);

    // Skip creation if the address code size is non-zero
    if (escrowContract.code.length != 0) return escrowContract;

    tmpEscrowParams = TmpEscrowParams(borrower, account, asset);

    new WildcatSanctionsEscrow{ salt: _deriveSalt(borrower, account, asset) }();

    emit NewSanctionsEscrow(borrower, account, asset);

    sanctionOverrides[borrower][escrowContract] = true;

    emit SanctionOverride(borrower, escrowContract);

    _resetTmpEscrowParams();
  }

  /**
   * @dev Calculate the create2 escrow address for the combination
   *      of `borrower`, `account`, and `asset`.
   */
  function getEscrowAddress(
    address borrower,
    address account,
    address asset
  ) public view override returns (address escrowAddress) {
    bytes32 salt = _deriveSalt(borrower, account, asset);
    bytes32 initCodeHash = WildcatSanctionsEscrowInitcodeHash;
    assembly {
      // Cache the free memory pointer so it can be restored at the end
      let freeMemoryPointer := mload(0x40)

      // Write 0xff + address(this) to bytes 11:32
      mstore(0x00, or(0xff0000000000000000000000000000000000000000, address()))

      // Write salt to bytes 32:64
      mstore(0x20, salt)

      // Write initcode hash to bytes 64:96
      mstore(0x40, initCodeHash)

      // Calculate create2 hash
      escrowAddress := and(keccak256(0x0b, 0x55), 0xffffffffffffffffffffffffffffffffffffffff)

      // Restore the free memory pointer
      mstore(0x40, freeMemoryPointer)
    }
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import '../types/HooksConfig.sol';
import '../libraries/MarketState.sol';
import '../interfaces/WildcatStructsAndEnums.sol';

abstract contract IHooks {
  error CallerNotFactory();

  address public immutable factory;

  constructor() {
    factory = msg.sender;
  }

  /// @dev Returns the version string of the hooks contract.
  ///      Used to determine what the contract does and how `extraData` is interpreted.
  function version() external view virtual returns (string memory);

  /// @dev Returns the HooksDeploymentConfig type which contains the sets
  ///      of optional and required hooks that this contract implements.
  function config() external view virtual returns (HooksDeploymentConfig);

  function onCreateMarket(
    address deployer,
    address marketAddress,
    DeployMarketInputs calldata parameters,
    bytes calldata extraData
  ) external returns (HooksConfig) {
    if (msg.sender != factory) revert CallerNotFactory();
    return _onCreateMarket(deployer, marketAddress, parameters, extraData);
  }

  function _onCreateMarket(
    address deployer,
    address marketAddress,
    DeployMarketInputs calldata parameters,
    bytes calldata extraData
  ) internal virtual returns (HooksConfig);

  function onDeposit(
    address lender,
    uint256 scaledAmount,
    MarketState calldata intermediateState,
    bytes calldata extraData
  ) external virtual;

  function onQueueWithdrawal(
    address lender,
    uint32 expiry,
    uint scaledAmount,
    MarketState calldata intermediateState,
    bytes calldata extraData
  ) external virtual;

  function onExecuteWithdrawal(
    address lender,
    uint128 normalizedAmountWithdrawn,
    MarketState calldata intermediateState,
    bytes calldata extraData
  ) external virtual;

  function onTransfer(
    address caller,
    address from,
    address to,
    uint scaledAmount,
    MarketState calldata intermediateState,
    bytes calldata extraData
  ) external virtual;

  function onBorrow(
    uint normalizedAmount,
    MarketState calldata intermediateState,
    bytes calldata extraData
  ) external virtual;

  function onRepay(
    uint normalizedAmount,
    MarketState calldata intermediateState,
    bytes calldata extraData
  ) external virtual;

  function onCloseMarket(
    MarketState calldata intermediateState,
    bytes calldata extraData
  ) external virtual;

  function onNukeFromOrbit(
    address lender,
    MarketState calldata intermediateState,
    bytes calldata extraData
  ) external virtual;

  function onSetMaxTotalSupply(
    uint256 maxTotalSupply,
    MarketState calldata intermediateState,
    bytes calldata extraData
  ) external virtual;

  function onSetAnnualInterestAndReserveRatioBips(
    uint16 annualInterestBips,
    uint16 reserveRatioBips,
    MarketState calldata intermediateState,
    bytes calldata extraData
  ) external virtual returns (uint16 updatedAnnualInterestBips, uint16 updatedReserveRatioBips);

  function onSetProtocolFeeBips(
    uint16 protocolFeeBips,
    MarketState memory intermediateState,
    bytes calldata extraData
  ) external virtual;
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.20;

interface IChainalysisSanctionsList {
  function isSanctioned(address addr) external view returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.20;

interface IERC20 {
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);

  function totalSupply() external view returns (uint256);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

  function increaseAllowance(address spender, uint256 addedValue) external returns (bool);

  function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  function name() external view returns (string memory);

  function symbol() external view returns (string memory);

  function decimals() external view returns (uint8);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.20;

import { MarketState } from '../libraries/MarketState.sol';

interface IMarketEventsAndErrors {
  /// @notice Error thrown when deposit exceeds maxTotalSupply
  error MaxSupplyExceeded();

  /// @notice Error thrown when non-borrower tries accessing borrower-only actions
  error NotApprovedBorrower();

  /// @notice Error thrown when non-approved lender tries lending to the market
  error NotApprovedLender();

  /// @notice Error thrown when caller other than factory tries changing protocol fee
  error NotFactory();

  /// @notice Error thrown when non-sentinel tries to use nukeFromOrbit
  error BadLaunchCode();

  /// @notice Error thrown when transfer target is blacklisted
  error AccountBlocked();

  error BadRescueAsset();

  error BorrowAmountTooHigh();

  error InsufficientReservesForFeeWithdrawal();

  error WithdrawalBatchNotExpired();

  error NullMintAmount();

  error NullBurnAmount();

  error NullFeeAmount();

  error NullTransferAmount();

  error NullWithdrawalAmount();

  error NullRepayAmount();

  error NullBuyBackAmount();

  error MarketAlreadyClosed();

  error DepositToClosedMarket();

  error RepayToClosedMarket();

  error BuyBackOnDelinquentMarket();

  error BorrowWhileSanctioned();

  error BorrowFromClosedMarket();

  error AprChangeOnClosedMarket();

  error CapacityChangeOnClosedMarket();

  error ProtocolFeeChangeOnClosedMarket();

  error CloseMarketWithUnpaidWithdrawals();

  error AnnualInterestBipsTooHigh();

  error ReserveRatioBipsTooHigh();

  error ProtocolFeeTooHigh();

  /// @dev Error thrown when reserve ratio is set to a value
  ///      that would make the market delinquent.
  error InsufficientReservesForNewLiquidityRatio();

  error InsufficientReservesForOldLiquidityRatio();

  error InvalidArrayLength();

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);

  event MaxTotalSupplyUpdated(uint256 assets);

  event ProtocolFeeBipsUpdated(uint256 protocolFeeBips);

  event AnnualInterestBipsUpdated(uint256 annualInterestBipsUpdated);

  event ReserveRatioBipsUpdated(uint256 reserveRatioBipsUpdated);

  event SanctionedAccountAssetsSentToEscrow(
    address indexed account,
    address escrow,
    uint256 amount
  );

  event SanctionedAccountAssetsQueuedForWithdrawal(
    address indexed account,
    uint256 expiry,
    uint256 scaledAmount,
    uint256 normalizedAmount
  );

  event Deposit(address indexed account, uint256 assetAmount, uint256 scaledAmount);

  event Borrow(uint256 assetAmount);

  event DebtRepaid(address indexed from, uint256 assetAmount);

  event MarketClosed(uint256 timestamp);

  event FeesCollected(uint256 assets);

  event StateUpdated(uint256 scaleFactor, bool isDelinquent);

  event InterestAndFeesAccrued(
    uint256 fromTimestamp,
    uint256 toTimestamp,
    uint256 scaleFactor,
    uint256 baseInterestRay,
    uint256 delinquencyFeeRay,
    uint256 protocolFees
  );

  event AccountSanctioned(address indexed account);

  // =====================================================================//
  //                          Withdrawl Events                            //
  // =====================================================================//

  event WithdrawalBatchExpired(
    uint256 indexed expiry,
    uint256 scaledTotalAmount,
    uint256 scaledAmountBurned,
    uint256 normalizedAmountPaid
  );

  /// @dev Emitted when a new withdrawal batch is created.
  event WithdrawalBatchCreated(uint256 indexed expiry);

  /// @dev Emitted when a withdrawal batch is paid off.
  event WithdrawalBatchClosed(uint256 indexed expiry);

  event WithdrawalBatchPayment(
    uint256 indexed expiry,
    uint256 scaledAmountBurned,
    uint256 normalizedAmountPaid
  );

  event WithdrawalQueued(
    uint256 indexed expiry,
    address indexed account,
    uint256 scaledAmount,
    uint256 normalizedAmount
  );

  event WithdrawalExecuted(
    uint256 indexed expiry,
    address indexed account,
    uint256 normalizedAmount
  );

  event SanctionedAccountWithdrawalSentToEscrow(
    address indexed account,
    address escrow,
    uint32 expiry,
    uint256 amount
  );
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.20;

interface IWildcatSanctionsEscrow {
  event EscrowReleased(address indexed account, address indexed asset, uint256 amount);

  error CanNotReleaseEscrow();

  function sentinel() external view returns (address);

  function borrower() external view returns (address);

  function account() external view returns (address);

  function balance() external view returns (uint256);

  function canReleaseEscrow() external view returns (bool);

  function escrowedAsset() external view returns (address token, uint256 amount);

  function releaseEscrow() external;
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.20;

interface IWildcatSanctionsSentinel {
  event NewSanctionsEscrow(
    address indexed borrower,
    address indexed account,
    address indexed asset
  );

  event SanctionOverride(address indexed borrower, address indexed account);

  event SanctionOverrideRemoved(address indexed borrower, address indexed account);

  struct TmpEscrowParams {
    address borrower;
    address account;
    address asset;
  }

  function WildcatSanctionsEscrowInitcodeHash() external pure returns (bytes32);

  // Returns immutable sanctions list contract
  function chainalysisSanctionsList() external view returns (address);

  // Returns immutable arch-controller
  function archController() external view returns (address);

  // Returns temporary escrow params
  function tmpEscrowParams()
    external
    view
    returns (address borrower, address account, address asset);

  // Returns result of `chainalysisSanctionsList().isSanctioned(account)`
  function isFlaggedByChainalysis(address account) external view returns (bool);

  // Returns result of `chainalysisSanctionsList().isSanctioned(account)`
  // if borrower has not overridden the status of `account`
  function isSanctioned(address borrower, address account) external view returns (bool);

  // Returns boolean indicating whether `borrower` has overridden the
  // sanction status of `account`
  function sanctionOverrides(address borrower, address account) external view returns (bool);

  function overrideSanction(address account) external;

  function removeSanctionOverride(address account) external;

  // Returns create2 address of sanctions escrow contract for
  // combination of `borrower,account,asset`
  function getEscrowAddress(
    address borrower,
    address account,
    address asset
  ) external view returns (address escrowContract);

  /**
   * @dev Returns a create2 deployment of WildcatSanctionsEscrow unique to each
   *      combination of `account,borrower,asset`. If the contract is already
   *      deployed, returns the existing address.
   *
   *      Emits `NewSanctionsEscrow(borrower, account, asset)` if a new contract
   *      is deployed.
   *
   *      The sanctions escrow contract is used to hold assets until either the
   *      sanctioned status is lifted or the assets are released by the borrower.
   */
  function createEscrow(
    address borrower,
    address account,
    address asset
  ) external returns (address escrowContract);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.20;

import { MarketState } from '../libraries/MarketState.sol';

import { HooksConfig } from '../types/HooksConfig.sol';

struct MarketParameters {
  address asset;
  uint8 decimals;
  bytes32 packedNameWord0;
  bytes32 packedNameWord1;
  bytes32 packedSymbolWord0;
  bytes32 packedSymbolWord1;
  address borrower;
  address feeRecipient;
  address sentinel;
  uint128 maxTotalSupply;
  uint16 protocolFeeBips;
  uint16 annualInterestBips;
  uint16 delinquencyFeeBips;
  uint32 withdrawalBatchDuration;
  uint16 reserveRatioBips;
  uint32 delinquencyGracePeriod;
  address archController;
  address sphereXEngine;
  HooksConfig hooks;
}

struct DeployMarketInputs {
  address asset;
  string namePrefix;
  string symbolPrefix;
  uint128 maxTotalSupply;
  uint16 annualInterestBips;
  uint16 delinquencyFeeBips;
  uint32 withdrawalBatchDuration;
  uint16 reserveRatioBips;
  uint32 delinquencyGracePeriod;
  HooksConfig hooks;
}

struct MarketControllerParameters {
  address archController;
  address borrower;
  address sentinel;
  address marketInitCodeStorage;
  uint256 marketInitCodeHash;
  uint32 minimumDelinquencyGracePeriod;
  uint32 maximumDelinquencyGracePeriod;
  uint16 minimumReserveRatioBips;
  uint16 maximumReserveRatioBips;
  uint16 minimumDelinquencyFeeBips;
  uint16 maximumDelinquencyFeeBips;
  uint32 minimumWithdrawalBatchDuration;
  uint32 maximumWithdrawalBatchDuration;
  uint16 minimumAnnualInterestBips;
  uint16 maximumAnnualInterestBips;
  address sphereXEngine;
}

struct ProtocolFeeConfiguration {
  address feeRecipient;
  address originationFeeAsset;
  uint80 originationFeeAmount;
  uint16 protocolFeeBips;
}

struct MarketParameterConstraints {
  uint32 minimumDelinquencyGracePeriod;
  uint32 maximumDelinquencyGracePeriod;
  uint16 minimumReserveRatioBips;
  uint16 maximumReserveRatioBips;
  uint16 minimumDelinquencyFeeBips;
  uint16 maximumDelinquencyFeeBips;
  uint32 minimumWithdrawalBatchDuration;
  uint32 maximumWithdrawalBatchDuration;
  uint16 minimumAnnualInterestBips;
  uint16 maximumAnnualInterestBips;
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.20;

library BoolUtils {
  function and(bool a, bool b) internal pure returns (bool c) {
    assembly {
      c := and(a, b)
    }
  }

  function or(bool a, bool b) internal pure returns (bool c) {
    assembly {
      c := or(a, b)
    }
  }

  function xor(bool a, bool b) internal pure returns (bool c) {
    assembly {
      c := xor(a, b)
    }
  }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.20;

uint256 constant Panic_CompilerPanic = 0x00;
uint256 constant Panic_AssertFalse = 0x01;
uint256 constant Panic_Arithmetic = 0x11;
uint256 constant Panic_DivideByZero = 0x12;
uint256 constant Panic_InvalidEnumValue = 0x21;
uint256 constant Panic_InvalidStorageByteArray = 0x22;
uint256 constant Panic_EmptyArrayPop = 0x31;
uint256 constant Panic_ArrayOutOfBounds = 0x32;
uint256 constant Panic_MemoryTooLarge = 0x41;
uint256 constant Panic_UninitializedFunctionPointer = 0x51;

uint256 constant Panic_ErrorSelector = 0x4e487b71;
uint256 constant Panic_ErrorCodePointer = 0x20;
uint256 constant Panic_ErrorLength = 0x24;
uint256 constant Error_SelectorPointer = 0x1c;

/**
 * @dev Reverts with the given error selector.
 * @param errorSelector The left-aligned error selector.
 */
function revertWithSelector(bytes4 errorSelector) pure {
  assembly {
    mstore(0, errorSelector)
    revert(0, 4)
  }
}

/**
 * @dev Reverts with the given error selector.
 * @param errorSelector The left-padded error selector.
 */
function revertWithSelector(uint256 errorSelector) pure {
  assembly {
    mstore(0, errorSelector)
    revert(Error_SelectorPointer, 4)
  }
}

/**
 * @dev Reverts with the given error selector and argument.
 * @param errorSelector The left-aligned error selector.
 * @param argument The argument to the error.
 */
function revertWithSelectorAndArgument(bytes4 errorSelector, uint256 argument) pure {
  assembly {
    mstore(0, errorSelector)
    mstore(4, argument)
    revert(0, 0x24)
  }
}

/**
 * @dev Reverts with the given error selector and argument.
 * @param errorSelector The left-padded error selector.
 * @param argument The argument to the error.
 */
function revertWithSelectorAndArgument(uint256 errorSelector, uint256 argument) pure {
  assembly {
    mstore(0, errorSelector)
    mstore(0x20, argument)
    revert(Error_SelectorPointer, 0x24)
  }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.20;

struct FIFOQueue {
  uint128 startIndex;
  uint128 nextIndex;
  mapping(uint256 => uint32) data;
}

// @todo - make array tightly packed for gas efficiency with multiple reads/writes
//         also make a memory version of the array with (nextIndex, startIndex, storageSlot)
//         so that multiple storage reads aren't required for tx's using multiple functions

using FIFOQueueLib for FIFOQueue global;

library FIFOQueueLib {
  error FIFOQueueOutOfBounds();

  function empty(FIFOQueue storage arr) internal view returns (bool) {
    return arr.nextIndex == arr.startIndex;
  }

  function first(FIFOQueue storage arr) internal view returns (uint32) {
    if (arr.startIndex == arr.nextIndex) {
      revert FIFOQueueOutOfBounds();
    }
    return arr.data[arr.startIndex];
  }

  function at(FIFOQueue storage arr, uint256 index) internal view returns (uint32) {
    index += arr.startIndex;
    if (index >= arr.nextIndex) {
      revert FIFOQueueOutOfBounds();
    }
    return arr.data[index];
  }

  function length(FIFOQueue storage arr) internal view returns (uint128) {
    return arr.nextIndex - arr.startIndex;
  }

  function values(FIFOQueue storage arr) internal view returns (uint32[] memory _values) {
    uint256 startIndex = arr.startIndex;
    uint256 nextIndex = arr.nextIndex;
    uint256 len = nextIndex - startIndex;
    _values = new uint32[](len);

    for (uint256 i = 0; i < len; i++) {
      _values[i] = arr.data[startIndex + i];
    }

    return _values;
  }

  function push(FIFOQueue storage arr, uint32 value) internal {
    uint128 nextIndex = arr.nextIndex;
    arr.data[nextIndex] = value;
    arr.nextIndex = nextIndex + 1;
  }

  function shift(FIFOQueue storage arr) internal {
    uint128 startIndex = arr.startIndex;
    if (startIndex == arr.nextIndex) {
      revert FIFOQueueOutOfBounds();
    }
    delete arr.data[startIndex];
    arr.startIndex = startIndex + 1;
  }

  function shiftN(FIFOQueue storage arr, uint128 n) internal {
    uint128 startIndex = arr.startIndex;
    if (startIndex + n > arr.nextIndex) {
      revert FIFOQueueOutOfBounds();
    }
    for (uint256 i = 0; i < n; i++) {
      delete arr.data[startIndex + i];
    }
    arr.startIndex = startIndex + n;
  }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.20;

import './MathUtils.sol';
import './SafeCastLib.sol';
import './MarketState.sol';

using SafeCastLib for uint256;
using MathUtils for uint256;

library FeeMath {
  /**
   * @dev Function to calculate the interest accumulated using a linear interest rate formula
   *
   * @param rateBip The interest rate, in bips
   * @param timeDelta The time elapsed since the last interest accrual
   * @return result The interest rate linearly accumulated during the timeDelta, in ray
   */
  function calculateLinearInterestFromBips(
    uint256 rateBip,
    uint256 timeDelta
  ) internal pure returns (uint256 result) {
    uint256 rate = rateBip.bipToRay();
    uint256 accumulatedInterestRay = rate * timeDelta;
    unchecked {
      return accumulatedInterestRay / SECONDS_IN_365_DAYS;
    }
  }

  function calculateBaseInterest(
    MarketState memory state,
    uint256 timestamp
  ) internal pure returns (uint256 baseInterestRay) {
    baseInterestRay = MathUtils.calculateLinearInterestFromBips(
      state.annualInterestBips,
      timestamp - state.lastInterestAccruedTimestamp
    );
  }

  function applyProtocolFee(
    MarketState memory state,
    uint256 baseInterestRay
  ) internal pure returns (uint256 protocolFee) {
    // Protocol fee is charged in addition to the interest paid to lenders.
    uint256 protocolFeeRay = uint(state.protocolFeeBips).bipMul(baseInterestRay);
    protocolFee = uint256(state.scaledTotalSupply).rayMul(
      uint256(state.scaleFactor).rayMul(protocolFeeRay)
    );
    state.accruedProtocolFees = (state.accruedProtocolFees + protocolFee).toUint128();
  }

  function updateDelinquency(
    MarketState memory state,
    uint256 timestamp,
    uint256 delinquencyFeeBips,
    uint256 delinquencyGracePeriod
  ) internal pure returns (uint256 delinquencyFeeRay) {
    // Calculate the number of seconds the borrower spent in penalized
    // delinquency since the last update.
    uint256 timeWithPenalty = updateTimeDelinquentAndGetPenaltyTime(
      state,
      delinquencyGracePeriod,
      timestamp - state.lastInterestAccruedTimestamp
    );

    if (timeWithPenalty > 0) {
      // Calculate penalty fees on the interest accrued.
      delinquencyFeeRay = calculateLinearInterestFromBips(delinquencyFeeBips, timeWithPenalty);
    }
  }

  /**
   * @notice  Calculate the number of seconds that the market has been in
   *          penalized delinquency since the last update, and update
   *          `timeDelinquent` in state.
   *
   * @dev When `isDelinquent`, equivalent to:
   *        max(0, timeDelta - max(0, delinquencyGracePeriod - previousTimeDelinquent))
   *      When `!isDelinquent`, equivalent to:
   *        min(timeDelta, max(0, previousTimeDelinquent - delinquencyGracePeriod))
   *
   * @param state Encoded state parameters
   * @param delinquencyGracePeriod Seconds in delinquency before penalties apply
   * @param timeDelta Seconds since the last update
   * @param `timeWithPenalty` Number of seconds since the last update where
   *        the market was in delinquency outside of the grace period.
   */
  function updateTimeDelinquentAndGetPenaltyTime(
    MarketState memory state,
    uint256 delinquencyGracePeriod,
    uint256 timeDelta
  ) internal pure returns (uint256 /* timeWithPenalty */) {
    // Seconds in delinquency at last update
    uint256 previousTimeDelinquent = state.timeDelinquent;

    if (state.isDelinquent) {
      // Since the borrower is still delinquent, increase the total
      // time in delinquency by the time elapsed.
      state.timeDelinquent = (previousTimeDelinquent + timeDelta).toUint32();

      // Calculate the number of seconds the borrower had remaining
      // in the grace period.
      uint256 secondsRemainingWithoutPenalty = delinquencyGracePeriod.satSub(
        previousTimeDelinquent
      );

      // Penalties apply for the number of seconds the market spent in
      // delinquency outside of the grace period since the last update.
      return timeDelta.satSub(secondsRemainingWithoutPenalty);
    }

    // Reduce the total time in delinquency by the time elapsed, stopping
    // when it reaches zero.
    state.timeDelinquent = previousTimeDelinquent.satSub(timeDelta).toUint32();

    // Calculate the number of seconds the old timeDelinquent had remaining
    // outside the grace period, or zero if it was already in the grace period.
    uint256 secondsRemainingWithPenalty = previousTimeDelinquent.satSub(delinquencyGracePeriod);

    // Only apply penalties for the remaining time outside of the grace period.
    return MathUtils.min(secondsRemainingWithPenalty, timeDelta);
  }

  /**
   * @dev Calculates interest and delinquency/protocol fees accrued since last state update
   *      and applies it to cached state, returning the rates for base interest and delinquency
   *      fees and the normalized amount of protocol fees accrued.
   *
   *      Takes `timestamp` as input to allow separate calculation of interest
   *      before and after withdrawal batch expiry.
   *
   * @param state Market scale parameters
   * @param delinquencyFeeBips Delinquency fee rate (in bips)
   * @param delinquencyGracePeriod Grace period (in seconds) before delinquency fees apply
   * @param timestamp Time to calculate interest and fees accrued until
   * @return baseInterestRay Interest accrued to lenders (ray)
   * @return delinquencyFeeRay Penalty fee incurred by borrower for delinquency (ray).
   * @return protocolFee Protocol fee charged on interest (normalized token amount).
   */
  function updateScaleFactorAndFees(
    MarketState memory state,
    uint256 delinquencyFeeBips,
    uint256 delinquencyGracePeriod,
    uint256 timestamp
  )
    internal
    pure
    returns (uint256 baseInterestRay, uint256 delinquencyFeeRay, uint256 protocolFee)
  {
    baseInterestRay = state.calculateBaseInterest(timestamp);

    if (state.protocolFeeBips > 0) {
      protocolFee = state.applyProtocolFee(baseInterestRay);
    }

    if (delinquencyFeeBips > 0) {
      delinquencyFeeRay = state.updateDelinquency(
        timestamp,
        delinquencyFeeBips,
        delinquencyGracePeriod
      );
    }

    // Calculate new scaleFactor
    uint256 prevScaleFactor = state.scaleFactor;
    uint256 scaleFactorDelta = prevScaleFactor.rayMul(baseInterestRay + delinquencyFeeRay);

    state.scaleFactor = (prevScaleFactor + scaleFactorDelta).toUint112();
    state.lastInterestAccruedTimestamp = uint32(timestamp);
  }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.20;

import { MarketParameters } from '../interfaces/WildcatStructsAndEnums.sol';
import { MarketState } from '../libraries/MarketState.sol';
import { WithdrawalBatch } from '../libraries/Withdrawal.sol';

/**
 * @dev Type-casts to convert functions returning raw (uint) pointers
 *      to functions returning memory pointers of specific types.
 *
 *      Used to get around solc's over-allocation of memory when
 *      dynamic return parameters are re-assigned.
 *
 *      With `viaIR` enabled, calling any of these functions is a noop.
 */
library FunctionTypeCasts {
  /**
   * @dev Function type cast to avoid duplicate declaration/allocation
   *      of MarketState return parameter.
   */
  function asReturnsMarketState(
    function() internal view returns (uint256) fnIn
  ) internal pure returns (function() internal view returns (MarketState memory) fnOut) {
    assembly {
      fnOut := fnIn
    }
  }

  /**
   * @dev Function type cast to avoid duplicate declaration/allocation
   *      of MarketState and WithdrawalBatch return parameters.
   */
  function asReturnsPointers(
    function() internal view returns (MarketState memory, uint32, WithdrawalBatch memory) fnIn
  ) internal pure returns (function() internal view returns (uint256, uint32, uint256) fnOut) {
    assembly {
      fnOut := fnIn
    }
  }

  /**
   * @dev Function type cast to avoid duplicate declaration/allocation
   *      of manually allocated MarketParameters in market constructor.
   */
  function asReturnsMarketParameters(
    function() internal view returns (uint256) fnIn
  ) internal pure returns (function() internal view returns (MarketParameters memory) fnOut) {
    assembly {
      fnOut := fnIn
    }
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import './StringQuery.sol';

/// @notice Safe ERC20 library
/// @author d1ll0n
/// @notice Changes from solady:
///   - Removed Permit2 and ETH functions
///   - `balanceOf(address)` reverts if the call fails or does not return >=32 bytes
///   - Added queries for `name`, `symbol`, `decimals`
///   - Set name to LibERC20 as it has queries unrelated to transfers and ETH functions were removed
/// @author Modified from Solady (https://github.com/vectorized/solady/blob/main/src/utils/LibERC20.sol)
/// @author Previously modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/LibERC20.sol)
///
/// @dev Note:
/// - For ERC20s, this implementation won't check that a token has code,
///   responsibility is delegated to the caller.
library LibERC20 {
  /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
  /*                       CUSTOM ERRORS                        */
  /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

  /// @dev The ERC20 `transferFrom` has failed.
  error TransferFromFailed();

  /// @dev The ERC20 `transfer` has failed.
  error TransferFailed();

  /// @dev The ERC20 `balanceOf` call has failed.
  error BalanceOfFailed();

  /// @dev The ERC20 `name` call has failed.
  error NameFailed();

  /// @dev The ERC20 `symbol` call has failed.
  error SymbolFailed();

  /// @dev The ERC20 `decimals` call has failed.
  error DecimalsFailed();

  /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
  /*                      ERC20 OPERATIONS                      */
  /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

  /// @dev Sends `amount` of ERC20 `token` from `from` to `to`.
  /// Reverts upon failure.
  ///
  /// The `from` account must have at least `amount` approved for
  /// the current contract to manage.
  function safeTransferFrom(address token, address from, address to, uint256 amount) internal {
    /// @solidity memory-safe-assembly
    assembly {
      let m := mload(0x40) // Cache the free memory pointer.
      mstore(0x60, amount) // Store the `amount` argument.
      mstore(0x40, to) // Store the `to` argument.
      mstore(0x2c, shl(96, from)) // Store the `from` argument.
      mstore(0x0c, 0x23b872dd000000000000000000000000) // `transferFrom(address,address,uint256)`.
      // Perform the transfer, reverting upon failure.
      if iszero(
        and(
          // The arguments of `and` are evaluated from right to left.
          or(eq(mload(0x00), 1), iszero(returndatasize())), // Returned 1 or nothing.
          call(gas(), token, 0, 0x1c, 0x64, 0x00, 0x20)
        )
      ) {
        mstore(0x00, 0x7939f424) // `TransferFromFailed()`.
        revert(0x1c, 0x04)
      }
      mstore(0x60, 0) // Restore the zero slot to zero.
      mstore(0x40, m) // Restore the free memory pointer.
    }
  }

  /// @dev Sends `amount` of ERC20 `token` from the current contract to `to`.
  /// Reverts upon failure.
  function safeTransfer(address token, address to, uint256 amount) internal {
    /// @solidity memory-safe-assembly
    assembly {
      mstore(0x14, to) // Store the `to` argument.
      mstore(0x34, amount) // Store the `amount` argument.
      mstore(0x00, 0xa9059cbb000000000000000000000000) // `transfer(address,uint256)`.
      // Perform the transfer, reverting upon failure.
      if iszero(
        and(
          // The arguments of `and` are evaluated from right to left.
          or(eq(mload(0x00), 1), iszero(returndatasize())), // Returned 1 or nothing.
          call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
        )
      ) {
        mstore(0x00, 0x90b8ec18) // `TransferFailed()`.
        revert(0x1c, 0x04)
      }
      mstore(0x34, 0) // Restore the part of the free memory pointer that was overwritten.
    }
  }

  /// @dev Sends all of ERC20 `token` from the current contract to `to`.
  /// Reverts upon failure.
  function safeTransferAll(address token, address to) internal returns (uint256 amount) {
    /// @solidity memory-safe-assembly
    assembly {
      mstore(0x00, 0x70a08231) // Store the function selector of `balanceOf(address)`.
      mstore(0x20, address()) // Store the address of the current contract.
      // Read the balance, reverting upon failure.
      if iszero(
        and(
          // The arguments of `and` are evaluated from right to left.
          gt(returndatasize(), 0x1f), // At least 32 bytes returned.
          staticcall(gas(), token, 0x1c, 0x24, 0x34, 0x20)
        )
      ) {
        mstore(0x00, 0x90b8ec18) // `TransferFailed()`.
        revert(0x1c, 0x04)
      }
      mstore(0x14, to) // Store the `to` argument.
      amount := mload(0x34) // The `amount` is already at 0x34. We'll need to return it.
      mstore(0x00, 0xa9059cbb000000000000000000000000) // `transfer(address,uint256)`.
      // Perform the transfer, reverting upon failure.
      if iszero(
        and(
          // The arguments of `and` are evaluated from right to left.
          or(eq(mload(0x00), 1), iszero(returndatasize())), // Returned 1 or nothing.
          call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
        )
      ) {
        mstore(0x00, 0x90b8ec18) // `TransferFailed()`.
        revert(0x1c, 0x04)
      }
      mstore(0x34, 0) // Restore the part of the free memory pointer that was overwritten.
    }
  }

  /// @dev Returns the amount of ERC20 `token` owned by `account`.
  /// Reverts if the call to `balanceOf` reverts or returns less than 32 bytes.
  function balanceOf(address token, address account) internal view returns (uint256 amount) {
    /// @solidity memory-safe-assembly
    assembly {
      mstore(0x00, 0x70a08231) // Store the function selector of `balanceOf(address)`.
      mstore(0x20, account) // Store the `account` argument.
      // Read the balance, reverting upon failure.
      if iszero(
        and(
          // The arguments of `and` are evaluated from right to left.
          gt(returndatasize(), 0x1f), // At least 32 bytes returned.
          staticcall(gas(), token, 0x1c, 0x24, 0x00, 0x20)
        )
      ) {
        mstore(0x00, 0x4963f6d5) // `BalanceOfFailed()`.
        revert(0x1c, 0x04)
      }
      amount := mload(0x00)
    }
  }

  /// @dev Returns the `decimals` of ERC20 `token`.
  /// Reverts if the call to `decimals` reverts or returns less than 32 bytes.
  function decimals(address token) internal view returns (uint8 _decimals) {
    assembly {
      // Write selector for `decimals()` to the end of the first word
      // of scratch space.
      mstore(0, 0x313ce567)
      // Call `asset.decimals()`, writing up to 32 bytes of returndata
      // to scratch space, overwriting the calldata used for the call.
      // Reverts if the call fails, does not return exactly 32 bytes, or the returndata
      // exceeds 8 bits.
      if iszero(
        and(
          and(eq(returndatasize(), 0x20), lt(mload(0), 0x100)),
          staticcall(gas(), token, 0x1c, 0x04, 0, 0x20)
        )
      ) {
        mstore(0x00, 0x3394d170) // `DecimalsFailed()`.
        revert(0x1c, 0x04)
      }
      // Read the return value from scratch space
      _decimals := mload(0)
    }
  }

  /// @dev Returns the `name` of ERC20 `token`.
  /// Reverts if the call to `name` reverts or returns a value which is neither
  /// a bytes32 string nor a valid ABI-encoded string.
  function name(address token) internal view returns (string memory) {
    // The `name` function selector is 0x06fdde03.
    // The `NameFailed` error selector is 0x2ed09f54.
    return queryStringOrBytes32AsString(token, 0x06fdde03, 0x2ed09f54);
  }

  /// @dev Returns the `symbol` of ERC20 `token`.
  /// Reverts if the call to `symbol` reverts or returns a value which is neither
  /// a bytes32 string nor a valid ABI-encoded string.
  function symbol(address token) internal view returns (string memory) {
    // The `symbol` function selector is 0x95d89b41.
    // The `SymbolFailed` error selector is 0x3ddcc60a.
    return queryStringOrBytes32AsString(token, 0x95d89b41, 0x3ddcc60a);
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

uint256 constant MaxSupplyExceeded_ErrorSelector = 0x8a164f63;

/// @dev Equivalent to `revert MaxSupplyExceeded()`
function revert_MaxSupplyExceeded() pure {
  assembly {
    mstore(0, 0x8a164f63)
    revert(0x1c, 0x04)
  }
}

uint256 constant CapacityChangeOnClosedMarket_ErrorSelector = 0x81b21078;

/// @dev Equivalent to `revert CapacityChangeOnClosedMarket()`
function revert_CapacityChangeOnClosedMarket() pure {
  assembly {
    mstore(0, 0x81b21078)
    revert(0x1c, 0x04)
  }
}

uint256 constant AprChangeOnClosedMarket_ErrorSelector = 0xb9de88a2;

/// @dev Equivalent to `revert AprChangeOnClosedMarket()`
function revert_AprChangeOnClosedMarket() pure {
  assembly {
    mstore(0, 0xb9de88a2)
    revert(0x1c, 0x04)
  }
}

uint256 constant MarketAlreadyClosed_ErrorSelector = 0x449e5f50;

/// @dev Equivalent to `revert MarketAlreadyClosed()`
function revert_MarketAlreadyClosed() pure {
  assembly {
    mstore(0, 0x449e5f50)
    revert(0x1c, 0x04)
  }
}

uint256 constant NotApprovedBorrower_ErrorSelector = 0x02171e6a;

/// @dev Equivalent to `revert NotApprovedBorrower()`
function revert_NotApprovedBorrower() pure {
  assembly {
    mstore(0, 0x02171e6a)
    revert(0x1c, 0x04)
  }
}

uint256 constant NotApprovedLender_ErrorSelector = 0xe50a45ce;

/// @dev Equivalent to `revert NotApprovedLender()`
function revert_NotApprovedLender() pure {
  assembly {
    mstore(0, 0xe50a45ce)
    revert(0x1c, 0x04)
  }
}

uint256 constant BadLaunchCode_ErrorSelector = 0xa97ab167;

/// @dev Equivalent to `revert BadLaunchCode()`
function revert_BadLaunchCode() pure {
  assembly {
    mstore(0, 0xa97ab167)
    revert(0x1c, 0x04)
  }
}

uint256 constant ReserveRatioBipsTooHigh_ErrorSelector = 0x8ec83073;

/// @dev Equivalent to `revert ReserveRatioBipsTooHigh()`
function revert_ReserveRatioBipsTooHigh() pure {
  assembly {
    mstore(0, 0x8ec83073)
    revert(0x1c, 0x04)
  }
}

/* 
code size: 25634
initcode size: 28024

errors: -48 runtime, -48 initcode
*/
uint256 constant AnnualInterestBipsTooHigh_ErrorSelector = 0xcf1f916f;

/// @dev Equivalent to `revert ReserveRatioBipsTooHigh()`
function revert_AnnualInterestBipsTooHigh() pure {
  assembly {
    mstore(0, 0xcf1f916f)
    revert(0x1c, 0x04)
  }
}

uint256 constant AccountBlocked_ErrorSelector = 0x6bc671fd;

/// @dev Equivalent to `revert AccountBlocked()`
function revert_AccountBlocked() pure {
  assembly {
    mstore(0, 0x6bc671fd)
    revert(0x1c, 0x04)
  }
}

uint256 constant BorrowAmountTooHigh_ErrorSelector = 0x119fe6e3;

/// @dev Equivalent to `revert BorrowAmountTooHigh()`
function revert_BorrowAmountTooHigh() pure {
  assembly {
    mstore(0, 0x119fe6e3)
    revert(0x1c, 0x04)
  }
}

uint256 constant BadRescueAsset_ErrorSelector = 0x11530cde;

/// @dev Equivalent to `revert BadRescueAsset()`
function revert_BadRescueAsset() pure {
  assembly {
    mstore(0, 0x11530cde)
    revert(0x1c, 0x04)
  }
}

uint256 constant InsufficientReservesForFeeWithdrawal_ErrorSelector = 0xf784cfa4;

/// @dev Equivalent to `revert InsufficientReservesForFeeWithdrawal()`
function revert_InsufficientReservesForFeeWithdrawal() pure {
  assembly {
    mstore(0, 0xf784cfa4)
    revert(0x1c, 0x04)
  }
}

uint256 constant WithdrawalBatchNotExpired_ErrorSelector = 0x2561b880;

/// @dev Equivalent to `revert WithdrawalBatchNotExpired()`
function revert_WithdrawalBatchNotExpired() pure {
  assembly {
    mstore(0, 0x2561b880)
    revert(0x1c, 0x04)
  }
}

uint256 constant NullMintAmount_ErrorSelector = 0xe4aa5055;

/// @dev Equivalent to `revert NullMintAmount()`
function revert_NullMintAmount() pure {
  assembly {
    mstore(0, 0xe4aa5055)
    revert(0x1c, 0x04)
  }
}

uint256 constant NullBurnAmount_ErrorSelector = 0xd61c50f8;

/// @dev Equivalent to `revert NullBurnAmount()`
function revert_NullBurnAmount() pure {
  assembly {
    mstore(0, 0xd61c50f8)
    revert(0x1c, 0x04)
  }
}

uint256 constant NullFeeAmount_ErrorSelector = 0x45c835cb;

/// @dev Equivalent to `revert NullFeeAmount()`
function revert_NullFeeAmount() pure {
  assembly {
    mstore(0, 0x45c835cb)
    revert(0x1c, 0x04)
  }
}

uint256 constant NullTransferAmount_ErrorSelector = 0xddee9b30;

/// @dev Equivalent to `revert NullTransferAmount()`
function revert_NullTransferAmount() pure {
  assembly {
    mstore(0, 0xddee9b30)
    revert(0x1c, 0x04)
  }
}

uint256 constant NullWithdrawalAmount_ErrorSelector = 0x186334fe;

/// @dev Equivalent to `revert NullWithdrawalAmount()`
function revert_NullWithdrawalAmount() pure {
  assembly {
    mstore(0, 0x186334fe)
    revert(0x1c, 0x04)
  }
}

uint256 constant NullRepayAmount_ErrorSelector = 0x7e082088;

/// @dev Equivalent to `revert NullRepayAmount()`
function revert_NullRepayAmount() pure {
  assembly {
    mstore(0, 0x7e082088)
    revert(0x1c, 0x04)
  }
}

uint256 constant NullBuyBackAmount_ErrorSelector = 0x50394120;

/// @dev Equivalent to `revert NullBuyBackAmount()`
function revert_NullBuyBackAmount() pure {
  assembly {
    mstore(0, 0x50394120)
    revert(0x1c, 0x04)
  }
}

uint256 constant DepositToClosedMarket_ErrorSelector = 0x22d7c043;

/// @dev Equivalent to `revert DepositToClosedMarket()`
function revert_DepositToClosedMarket() pure {
  assembly {
    mstore(0, 0x22d7c043)
    revert(0x1c, 0x04)
  }
}

uint256 constant RepayToClosedMarket_ErrorSelector = 0x61d1bc8f;

/// @dev Equivalent to `revert RepayToClosedMarket()`
function revert_RepayToClosedMarket() pure {
  assembly {
    mstore(0, 0x61d1bc8f)
    revert(0x1c, 0x04)
  }
}

uint256 constant BuyBackOnDelinquentMarket_Selector = 0x1707a7b7;

/// @dev Equivalent to `revert BuyBackOnDelinquentMarket()`
function revert_BuyBackOnDelinquentMarket() pure {
  assembly {
    mstore(0, 0x1707a7b7)
    revert(0x1c, 0x04)
  }
}

uint256 constant BorrowWhileSanctioned_ErrorSelector = 0x4a1c13a9;

/// @dev Equivalent to `revert BorrowWhileSanctioned()`
function revert_BorrowWhileSanctioned() pure {
  assembly {
    mstore(0, 0x4a1c13a9)
    revert(0x1c, 0x04)
  }
}

uint256 constant BorrowFromClosedMarket_ErrorSelector = 0xd0242b28;

/// @dev Equivalent to `revert BorrowFromClosedMarket()`
function revert_BorrowFromClosedMarket() pure {
  assembly {
    mstore(0, 0xd0242b28)
    revert(0x1c, 0x04)
  }
}

uint256 constant CloseMarketWithUnpaidWithdrawals_ErrorSelector = 0x4d790997;

/// @dev Equivalent to `revert CloseMarketWithUnpaidWithdrawals()`
function revert_CloseMarketWithUnpaidWithdrawals() pure {
  assembly {
    mstore(0, 0x4d790997)
    revert(0x1c, 0x04)
  }
}

uint256 constant InsufficientReservesForNewLiquidityRatio_ErrorSelector = 0x253ecbb9;

/// @dev Equivalent to `revert InsufficientReservesForNewLiquidityRatio()`
function revert_InsufficientReservesForNewLiquidityRatio() pure {
  assembly {
    mstore(0, 0x253ecbb9)
    revert(0x1c, 0x04)
  }
}

uint256 constant InsufficientReservesForOldLiquidityRatio_ErrorSelector = 0x0a68e5bf;

/// @dev Equivalent to `revert InsufficientReservesForOldLiquidityRatio()`
function revert_InsufficientReservesForOldLiquidityRatio() pure {
  assembly {
    mstore(0, 0x0a68e5bf)
    revert(0x1c, 0x04)
  }
}

uint256 constant InvalidArrayLength_ErrorSelector = 0x9d89020a;

/// @dev Equivalent to `revert InvalidArrayLength()`
function revert_InvalidArrayLength() pure {
  assembly {
    mstore(0, 0x9d89020a)
    revert(0x1c, 0x04)
  }
}

uint256 constant ProtocolFeeTooHigh_ErrorSelector = 0x499fddb1;

/// @dev Equivalent to `revert ProtocolFeeTooHigh()`
function revert_ProtocolFeeTooHigh() pure {
  assembly {
    mstore(0, 0x499fddb1)
    revert(0x1c, 0x04)
  }
}

uint256 constant ProtocolFeeChangeOnClosedMarket_ErrorSelector = 0x37f1a75f;

/// @dev Equivalent to `revert ProtocolFeeChangeOnClosedMarket()`
function revert_ProtocolFeeChangeOnClosedMarket() pure {
  assembly {
    mstore(0, 0x37f1a75f)
    revert(0x1c, 0x04)
  }
}

uint256 constant NotFactory_ErrorSelector = 0x32cc7236;

function revert_NotFactory() pure {
  assembly {
    mstore(0, 0x32cc7236)
    revert(0x1c, 0x04)
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

uint256 constant InterestAndFeesAccrued_abi_head_size = 0xc0;
uint256 constant InterestAndFeesAccrued_toTimestamp_offset = 0x20;
uint256 constant InterestAndFeesAccrued_scaleFactor_offset = 0x40;
uint256 constant InterestAndFeesAccrued_baseInterestRay_offset = 0x60;
uint256 constant InterestAndFeesAccrued_delinquencyFeeRay_offset = 0x80;
uint256 constant InterestAndFeesAccrued_protocolFees_offset = 0xa0;

function emit_Transfer(address from, address to, uint256 value) {
  assembly {
    mstore(0, value)
    log3(0, 0x20, 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef, from, to)
  }
}

function emit_Approval(address owner, address spender, uint256 value) {
  assembly {
    mstore(0, value)
    log3(
      0,
      0x20,
      0x8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925,
      owner,
      spender
    )
  }
}

function emit_MaxTotalSupplyUpdated(uint256 assets) {
  assembly {
    mstore(0, assets)
    log1(0, 0x20, 0xf2672935fc79f5237559e2e2999dbe743bf65430894ac2b37666890e7c69e1af)
  }
}

function emit_ProtocolFeeBipsUpdated(uint256 protocolFeeBips) {
  assembly {
    mstore(0, protocolFeeBips)
    log1(0, 0x20, 0x4b34705283cdb9398d0e50b216b8fb424c6d4def5db9bfadc661ee3adc6076ee)
  }
}

function emit_AnnualInterestBipsUpdated(uint256 annualInterestBipsUpdated) {
  assembly {
    mstore(0, annualInterestBipsUpdated)
    log1(0, 0x20, 0xff7b6c8be373823323d3c5d99f5d027dd409dce5db54eae511bbdd5546b75037)
  }
}

function emit_ReserveRatioBipsUpdated(uint256 reserveRatioBipsUpdated) {
  assembly {
    mstore(0, reserveRatioBipsUpdated)
    log1(0, 0x20, 0x72877a153052500f5edbb2f9da96a0f45d671d4b4555fdf8628a709dc4eab43a)
  }
}

function emit_SanctionedAccountAssetsSentToEscrow(address account, address escrow, uint256 amount) {
  assembly {
    mstore(0, escrow)
    mstore(0x20, amount)
    log2(0, 0x40, 0x571e706c2f09ae0632313e5f3ae89fffdedfc370a2ea59a07fb0d8091147645b, account)
  }
}

function emit_SanctionedAccountAssetsQueuedForWithdrawal(
  address account,
  uint32 expiry,
  uint256 scaledAmount,
  uint256 normalizedAmount
) {
  assembly {
    let freePointer := mload(0x40)
    mstore(0, expiry)
    mstore(0x20, scaledAmount)
    mstore(0x40, normalizedAmount)
    log2(0, 0x60, 0xe12b220b92469ae28fb0d79de531f94161431be9f073b96b8aad3effb88be6fa, account)
    mstore(0x40, freePointer)
  }
}

function emit_Deposit(address account, uint256 assetAmount, uint256 scaledAmount) {
  assembly {
    mstore(0, assetAmount)
    mstore(0x20, scaledAmount)
    log2(0, 0x40, 0x90890809c654f11d6e72a28fa60149770a0d11ec6c92319d6ceb2bb0a4ea1a15, account)
  }
}

function emit_Borrow(uint256 assetAmount) {
  assembly {
    mstore(0, assetAmount)
    log1(0, 0x20, 0xb848ae6b1253b6cb77e81464128ce8bd94d3d524fea54e801e0da869784dca33)
  }
}

function emit_DebtRepaid(address from, uint256 assetAmount) {
  assembly {
    mstore(0, assetAmount)
    log2(0, 0x20, 0xe8b606ac1e5df7657db58d297ca8f41c090fc94c5fd2d6958f043e41736e9fa6, from)
  }
}

function emit_MarketClosed(uint256 _timestamp) {
  assembly {
    mstore(0, _timestamp)
    log1(0, 0x20, 0x9dc30b8eda31a6a144e092e5de600955523a6a925cc15cc1d1b9b4872cfa6155)
  }
}

function emit_FeesCollected(uint256 assets) {
  assembly {
    mstore(0, assets)
    log1(0, 0x20, 0x860c0aa5520013080c2f65981705fcdea474d9f7c3daf954656ed5e65d692d1f)
  }
}

function emit_StateUpdated(uint256 scaleFactor, bool isDelinquent) {
  assembly {
    mstore(0, scaleFactor)
    mstore(0x20, isDelinquent)
    log1(0, 0x40, 0x9385f9ff65bcd2fb81cece54b27d4ec7376795fc4dcff686e370e347b0ed86c0)
  }
}

function emit_InterestAndFeesAccrued(
  uint256 fromTimestamp,
  uint256 toTimestamp,
  uint256 scaleFactor,
  uint256 baseInterestRay,
  uint256 delinquencyFeeRay,
  uint256 protocolFees
) {
  assembly {
    let dst := mload(0x40)
    /// Copy fromTimestamp
    mstore(dst, fromTimestamp)
    /// Copy toTimestamp
    mstore(add(dst, InterestAndFeesAccrued_toTimestamp_offset), toTimestamp)
    /// Copy scaleFactor
    mstore(add(dst, InterestAndFeesAccrued_scaleFactor_offset), scaleFactor)
    /// Copy baseInterestRay
    mstore(add(dst, InterestAndFeesAccrued_baseInterestRay_offset), baseInterestRay)
    /// Copy delinquencyFeeRay
    mstore(add(dst, InterestAndFeesAccrued_delinquencyFeeRay_offset), delinquencyFeeRay)
    /// Copy protocolFees
    mstore(add(dst, InterestAndFeesAccrued_protocolFees_offset), protocolFees)
    log1(
      dst,
      InterestAndFeesAccrued_abi_head_size,
      0x18247a393d0531b65fbd94f5e78bc5639801a4efda62ae7b43533c4442116c3a
    )
  }
}

function emit_WithdrawalBatchExpired(
  uint256 expiry,
  uint256 scaledTotalAmount,
  uint256 scaledAmountBurned,
  uint256 normalizedAmountPaid
) {
  assembly {
    let freePointer := mload(0x40)
    mstore(0, scaledTotalAmount)
    mstore(0x20, scaledAmountBurned)
    mstore(0x40, normalizedAmountPaid)
    log2(0, 0x60, 0x9262dc39b47cad3a0512e4c08dda248cb345e7163058f300bc63f56bda288b6e, expiry)
    mstore(0x40, freePointer)
  }
}

function emit_WithdrawalBatchCreated(uint256 expiry) {
  assembly {
    log2(0, 0x00, 0x5c9a946d3041134198ebefcd814de7748def6576efd3d1b48f48193e183e89ef, expiry)
  }
}

function emit_WithdrawalBatchClosed(uint256 expiry) {
  assembly {
    log2(0, 0x00, 0xcbdf25bf6e096dd9030d89bb2ba2e3e7adb82d25a233c3ca3d92e9f098b74e55, expiry)
  }
}

function emit_WithdrawalBatchPayment(
  uint256 expiry,
  uint256 scaledAmountBurned,
  uint256 normalizedAmountPaid
) {
  assembly {
    mstore(0, scaledAmountBurned)
    mstore(0x20, normalizedAmountPaid)
    log2(0, 0x40, 0x5272034725119f19d7236de4129fdb5093f0dcb80282ca5edbd587df91d2bd89, expiry)
  }
}

function emit_WithdrawalQueued(
  uint256 expiry,
  address account,
  uint256 scaledAmount,
  uint256 normalizedAmount
) {
  assembly {
    mstore(0, scaledAmount)
    mstore(0x20, normalizedAmount)
    log3(
      0,
      0x40,
      0xecc966b282a372469fa4d3e497c2ac17983c3eaed03f3f17c9acf4b15591663e,
      expiry,
      account
    )
  }
}

function emit_WithdrawalExecuted(uint256 expiry, address account, uint256 normalizedAmount) {
  assembly {
    mstore(0, normalizedAmount)
    log3(
      0,
      0x20,
      0xd6cddb3d69146e96ebc2c87b1b3dd0b20ee2d3b0eadf134e011afb434a3e56e6,
      expiry,
      account
    )
  }
}

function emit_SanctionedAccountWithdrawalSentToEscrow(
  address account,
  address escrow,
  uint32 expiry,
  uint256 amount
) {
  assembly {
    let freePointer := mload(0x40)
    mstore(0, escrow)
    mstore(0x20, expiry)
    mstore(0x40, amount)
    log2(0, 0x60, 0x0d0843a0fcb8b83f625aafb6e42f234ac48c6728b207d52d97cfa8fbd34d498f, account)
    mstore(0x40, freePointer)
  }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.20;

import './MathUtils.sol';
import './SafeCastLib.sol';
import './FeeMath.sol';

using MarketStateLib for MarketState global;
using MarketStateLib for Account global;
using FeeMath for MarketState global;

struct MarketState {
  bool isClosed;
  uint128 maxTotalSupply;
  uint128 accruedProtocolFees;
  // Underlying assets reserved for withdrawals which have been paid
  // by the borrower but not yet executed.
  uint128 normalizedUnclaimedWithdrawals;
  // Scaled token supply (divided by scaleFactor)
  uint104 scaledTotalSupply;
  // Scaled token amount in withdrawal batches that have not been
  // paid by borrower yet.
  uint104 scaledPendingWithdrawals;
  uint32 pendingWithdrawalExpiry;
  // Whether market is currently delinquent (liquidity under requirement)
  bool isDelinquent;
  // Seconds borrower has been delinquent
  uint32 timeDelinquent;
  // Fee charged to borrowers as a fraction of the annual interest rate
  uint16 protocolFeeBips;
  // Annual interest rate accrued to lenders, in basis points
  uint16 annualInterestBips;
  // Percentage of outstanding balance that must be held in liquid reserves
  uint16 reserveRatioBips;
  // Ratio between internal balances and underlying token amounts
  uint112 scaleFactor;
  uint32 lastInterestAccruedTimestamp;
}

struct Account {
  uint104 scaledBalance;
}

library MarketStateLib {
  using MathUtils for uint256;
  using SafeCastLib for uint256;

  /**
   * @dev Returns the normalized total supply of the market.
   */
  function totalSupply(MarketState memory state) internal pure returns (uint256) {
    return state.normalizeAmount(state.scaledTotalSupply);
  }

  /**
   * @dev Returns the maximum amount of tokens that can be deposited without
   *      reaching the maximum total supply.
   */
  function maximumDeposit(MarketState memory state) internal pure returns (uint256) {
    return uint256(state.maxTotalSupply).satSub(state.totalSupply());
  }

  /**
   * @dev Normalize an amount of scaled tokens using the current scale factor.
   */
  function normalizeAmount(
    MarketState memory state,
    uint256 amount
  ) internal pure returns (uint256) {
    return amount.rayMul(state.scaleFactor);
  }

  /**
   * @dev Scale an amount of normalized tokens using the current scale factor.
   */
  function scaleAmount(MarketState memory state, uint256 amount) internal pure returns (uint256) {
    return amount.rayDiv(state.scaleFactor);
  }

  /**
   * @dev Collateralization requirement is:
   *      - 100% of all pending (unpaid) withdrawals
   *      - 100% of all unclaimed (paid) withdrawals
   *      - reserve ratio times the outstanding debt (supply - pending withdrawals)
   *      - accrued protocol fees
   */
  function liquidityRequired(
    MarketState memory state
  ) internal pure returns (uint256 _liquidityRequired) {
    uint256 scaledWithdrawals = state.scaledPendingWithdrawals;
    uint256 scaledRequiredReserves = (state.scaledTotalSupply - scaledWithdrawals).bipMul(
      state.reserveRatioBips
    ) + scaledWithdrawals;
    return
      state.normalizeAmount(scaledRequiredReserves) +
      state.accruedProtocolFees +
      state.normalizedUnclaimedWithdrawals;
  }

  /**
   * @dev Returns the amount of underlying assets that can be withdrawn
   *      for protocol fees. The only debts with higher priority are
   *      processed withdrawals that have not been executed.
   */
  function withdrawableProtocolFees(
    MarketState memory state,
    uint256 totalAssets
  ) internal pure returns (uint128) {
    uint256 totalAvailableAssets = totalAssets - state.normalizedUnclaimedWithdrawals;
    return uint128(MathUtils.min(totalAvailableAssets, state.accruedProtocolFees));
  }

  /**
   * @dev Returns the amount of underlying assets that can be borrowed.
   *
   *      The borrower must maintain sufficient assets in the market to
   *      cover 100% of pending withdrawals, 100% of previously processed
   *      withdrawals (before they are executed), and the reserve ratio
   *      times the outstanding debt (deposits not pending withdrawal).
   *
   *      Any underlying assets in the market above this amount can be borrowed.
   */
  function borrowableAssets(
    MarketState memory state,
    uint256 totalAssets
  ) internal pure returns (uint256) {
    return totalAssets.satSub(state.liquidityRequired());
  }

  function hasPendingExpiredBatch(MarketState memory state) internal view returns (bool result) {
    uint256 expiry = state.pendingWithdrawalExpiry;
    assembly {
      // Equivalent to expiry > 0 && expiry < block.timestamp
      result := and(gt(expiry, 0), gt(timestamp(), expiry))
    }
  }

  function totalDebts(MarketState memory state) internal pure returns (uint256) {
    return
      state.normalizeAmount(state.scaledTotalSupply) +
      state.normalizedUnclaimedWithdrawals +
      state.accruedProtocolFees;
  }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.20;

import './Errors.sol';

uint256 constant BIP = 1e4;
uint256 constant HALF_BIP = 0.5e4;

uint256 constant RAY = 1e27;
uint256 constant HALF_RAY = 0.5e27;

uint256 constant BIP_RAY_RATIO = 1e23;

uint256 constant SECONDS_IN_365_DAYS = 365 days;

library MathUtils {
  /// @dev The multiply-divide operation failed, either due to a
  /// multiplication overflow, or a division by a zero.
  error MulDivFailed();

  using MathUtils for uint256;

  /**
   * @dev Function to calculate the interest accumulated using a linear interest rate formula
   *
   * @param rateBip The interest rate, in bips
   * @param timeDelta The time elapsed since the last interest accrual
   * @return result The interest rate linearly accumulated during the timeDelta, in ray
   */
  function calculateLinearInterestFromBips(
    uint256 rateBip,
    uint256 timeDelta
  ) internal pure returns (uint256 result) {
    uint256 rate = rateBip.bipToRay();
    uint256 accumulatedInterestRay = rate * timeDelta;
    unchecked {
      return accumulatedInterestRay / SECONDS_IN_365_DAYS;
    }
  }

  /**
   * @dev Return the smaller of `a` and `b`
   */
  function min(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = ternary(a < b, a, b);
  }

  /**
   * @dev Return the larger of `a` and `b`.
   */
  function max(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = ternary(a < b, b, a);
  }

  /**
   * @dev Saturation subtraction. Subtract `b` from `a` and return the result
   *      if it is positive or zero if it underflows.
   */
  function satSub(uint256 a, uint256 b) internal pure returns (uint256 c) {
    assembly {
      // (a > b) * (a - b)
      // If a-b underflows, the product will be zero
      c := mul(gt(a, b), sub(a, b))
    }
  }

  /**
   * @dev Saturation addition. Add `a` to `b` and return the result
   *      if it is less than `maxValue` or `maxValue` if it overflows.
   */
  function satAdd(uint256 a, uint256 b, uint256 maxValue) internal pure returns (uint256 c) {
    unchecked {
      c = a + b;
      return ternary(c < maxValue, c, maxValue);
    }
  }

  /**
   * @dev Return `valueIfTrue` if `condition` is true and `valueIfFalse` if it is false.
   *      Equivalent to `condition ? valueIfTrue : valueIfFalse`
   */
  function ternary(
    bool condition,
    uint256 valueIfTrue,
    uint256 valueIfFalse
  ) internal pure returns (uint256 c) {
    assembly {
      c := add(valueIfFalse, mul(condition, sub(valueIfTrue, valueIfFalse)))
    }
  }

  /**
   * @dev Multiplies two bip, rounding half up to the nearest bip
   *      see https://twitter.com/transmissions11/status/1451131036377571328
   */
  function bipMul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    assembly {
      // equivalent to `require(b == 0 || a <= (type(uint256).max - HALF_BIP) / b)`
      if iszero(or(iszero(b), iszero(gt(a, div(sub(not(0), HALF_BIP), b))))) {
        // Store the Panic error signature.
        mstore(0, Panic_ErrorSelector)
        // Store the arithmetic (0x11) panic code.
        mstore(Panic_ErrorCodePointer, Panic_Arithmetic)
        // revert(abi.encodeWithSignature("Panic(uint256)", 0x11))
        revert(Error_SelectorPointer, Panic_ErrorLength)
      }

      c := div(add(mul(a, b), HALF_BIP), BIP)
    }
  }

  /**
   * @dev Divides two bip, rounding half up to the nearest bip
   *      see https://twitter.com/transmissions11/status/1451131036377571328
   */
  function bipDiv(uint256 a, uint256 b) internal pure returns (uint256 c) {
    assembly {
      // equivalent to `require(b != 0 && a <= (type(uint256).max - b/2) / BIP)`
      if or(iszero(b), gt(a, div(sub(not(0), div(b, 2)), BIP))) {
        mstore(0, Panic_ErrorSelector)
        mstore(Panic_ErrorCodePointer, Panic_Arithmetic)
        revert(Error_SelectorPointer, Panic_ErrorLength)
      }

      c := div(add(mul(a, BIP), div(b, 2)), b)
    }
  }

  /**
   * @dev Converts bip up to ray
   */
  function bipToRay(uint256 a) internal pure returns (uint256 b) {
    // to avoid overflow, b/BIP_RAY_RATIO == a
    assembly {
      b := mul(a, BIP_RAY_RATIO)
      // equivalent to `require((b = a * BIP_RAY_RATIO) / BIP_RAY_RATIO == a )
      if iszero(eq(div(b, BIP_RAY_RATIO), a)) {
        mstore(0, Panic_ErrorSelector)
        mstore(Panic_ErrorCodePointer, Panic_Arithmetic)
        revert(Error_SelectorPointer, Panic_ErrorLength)
      }
    }
  }

  /**
   * @dev Multiplies two ray, rounding half up to the nearest ray
   *      see https://twitter.com/transmissions11/status/1451131036377571328
   */
  function rayMul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    assembly {
      // equivalent to `require(b == 0 || a <= (type(uint256).max - HALF_RAY) / b)`
      if iszero(or(iszero(b), iszero(gt(a, div(sub(not(0), HALF_RAY), b))))) {
        mstore(0, Panic_ErrorSelector)
        mstore(Panic_ErrorCodePointer, Panic_Arithmetic)
        revert(Error_SelectorPointer, Panic_ErrorLength)
      }

      c := div(add(mul(a, b), HALF_RAY), RAY)
    }
  }

  /**
   * @dev Divide two ray, rounding half up to the nearest ray
   *      see https://twitter.com/transmissions11/status/1451131036377571328
   */
  function rayDiv(uint256 a, uint256 b) internal pure returns (uint256 c) {
    assembly {
      // equivalent to `require(b != 0 && a <= (type(uint256).max - halfB) / RAY)`
      if or(iszero(b), gt(a, div(sub(not(0), div(b, 2)), RAY))) {
        mstore(0, Panic_ErrorSelector)
        mstore(Panic_ErrorCodePointer, Panic_Arithmetic)
        revert(Error_SelectorPointer, Panic_ErrorLength)
      }

      c := div(add(mul(a, RAY), div(b, 2)), b)
    }
  }

  /**
   * @dev Returns `floor(x * y / d)`.
   *      Reverts if `x * y` overflows, or `d` is zero.
   * @custom:author solady/src/utils/FixedPointMathLib.sol
   */
  function mulDiv(uint256 x, uint256 y, uint256 d) internal pure returns (uint256 z) {
    assembly {
      // Equivalent to require(d != 0 && (y == 0 || x <= type(uint256).max / y))
      if iszero(mul(d, iszero(mul(y, gt(x, div(not(0), y)))))) {
        // Store the function selector of `MulDivFailed()`.
        mstore(0x00, 0xad251c27)
        // Revert with (offset, size).
        revert(0x1c, 0x04)
      }
      z := div(mul(x, y), d)
    }
  }

  /**
   * @dev Returns `ceil(x * y / d)`.
   *      Reverts if `x * y` overflows, or `d` is zero.
   * @custom:author solady/src/utils/FixedPointMathLib.sol
   */
  function mulDivUp(uint256 x, uint256 y, uint256 d) internal pure returns (uint256 z) {
    assembly {
      // Equivalent to require(d != 0 && (y == 0 || x <= type(uint256).max / y))
      if iszero(mul(d, iszero(mul(y, gt(x, div(not(0), y)))))) {
        // Store the function selector of `MulDivFailed()`.
        mstore(0x00, 0xad251c27)
        // Revert with (offset, size).
        revert(0x1c, 0x04)
      }
      z := add(iszero(iszero(mod(mul(x, y), d))), div(mul(x, y), d))
    }
  }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.20;

import './Errors.sol';

library SafeCastLib {
  function _assertNonOverflow(bool didNotOverflow) private pure {
    assembly {
      if iszero(didNotOverflow) {
        mstore(0, Panic_ErrorSelector)
        mstore(Panic_ErrorCodePointer, Panic_Arithmetic)
        revert(Error_SelectorPointer, Panic_ErrorLength)
      }
    }
  }

  function toUint8(uint256 x) internal pure returns (uint8 y) {
    _assertNonOverflow(x == (y = uint8(x)));
  }

  function toUint16(uint256 x) internal pure returns (uint16 y) {
    _assertNonOverflow(x == (y = uint16(x)));
  }

  function toUint24(uint256 x) internal pure returns (uint24 y) {
    _assertNonOverflow(x == (y = uint24(x)));
  }

  function toUint32(uint256 x) internal pure returns (uint32 y) {
    _assertNonOverflow(x == (y = uint32(x)));
  }

  function toUint40(uint256 x) internal pure returns (uint40 y) {
    _assertNonOverflow(x == (y = uint40(x)));
  }

  function toUint48(uint256 x) internal pure returns (uint48 y) {
    _assertNonOverflow(x == (y = uint48(x)));
  }

  function toUint56(uint256 x) internal pure returns (uint56 y) {
    _assertNonOverflow(x == (y = uint56(x)));
  }

  function toUint64(uint256 x) internal pure returns (uint64 y) {
    _assertNonOverflow(x == (y = uint64(x)));
  }

  function toUint72(uint256 x) internal pure returns (uint72 y) {
    _assertNonOverflow(x == (y = uint72(x)));
  }

  function toUint80(uint256 x) internal pure returns (uint80 y) {
    _assertNonOverflow(x == (y = uint80(x)));
  }

  function toUint88(uint256 x) internal pure returns (uint88 y) {
    _assertNonOverflow(x == (y = uint88(x)));
  }

  function toUint96(uint256 x) internal pure returns (uint96 y) {
    _assertNonOverflow(x == (y = uint96(x)));
  }

  function toUint104(uint256 x) internal pure returns (uint104 y) {
    _assertNonOverflow(x == (y = uint104(x)));
  }

  function toUint112(uint256 x) internal pure returns (uint112 y) {
    _assertNonOverflow(x == (y = uint112(x)));
  }

  function toUint120(uint256 x) internal pure returns (uint120 y) {
    _assertNonOverflow(x == (y = uint120(x)));
  }

  function toUint128(uint256 x) internal pure returns (uint128 y) {
    _assertNonOverflow(x == (y = uint128(x)));
  }

  function toUint136(uint256 x) internal pure returns (uint136 y) {
    _assertNonOverflow(x == (y = uint136(x)));
  }

  function toUint144(uint256 x) internal pure returns (uint144 y) {
    _assertNonOverflow(x == (y = uint144(x)));
  }

  function toUint152(uint256 x) internal pure returns (uint152 y) {
    _assertNonOverflow(x == (y = uint152(x)));
  }

  function toUint160(uint256 x) internal pure returns (uint160 y) {
    _assertNonOverflow(x == (y = uint160(x)));
  }

  function toUint168(uint256 x) internal pure returns (uint168 y) {
    _assertNonOverflow(x == (y = uint168(x)));
  }

  function toUint176(uint256 x) internal pure returns (uint176 y) {
    _assertNonOverflow(x == (y = uint176(x)));
  }

  function toUint184(uint256 x) internal pure returns (uint184 y) {
    _assertNonOverflow(x == (y = uint184(x)));
  }

  function toUint192(uint256 x) internal pure returns (uint192 y) {
    _assertNonOverflow(x == (y = uint192(x)));
  }

  function toUint200(uint256 x) internal pure returns (uint200 y) {
    _assertNonOverflow(x == (y = uint200(x)));
  }

  function toUint208(uint256 x) internal pure returns (uint208 y) {
    _assertNonOverflow(x == (y = uint208(x)));
  }

  function toUint216(uint256 x) internal pure returns (uint216 y) {
    _assertNonOverflow(x == (y = uint216(x)));
  }

  function toUint224(uint256 x) internal pure returns (uint224 y) {
    _assertNonOverflow(x == (y = uint224(x)));
  }

  function toUint232(uint256 x) internal pure returns (uint232 y) {
    _assertNonOverflow(x == (y = uint232(x)));
  }

  function toUint240(uint256 x) internal pure returns (uint240 y) {
    _assertNonOverflow(x == (y = uint240(x)));
  }

  function toUint248(uint256 x) internal pure returns (uint248 y) {
    _assertNonOverflow(x == (y = uint248(x)));
  }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.20;

import { LibBit } from 'solady/utils/LibBit.sol';

using LibBit for uint256;

uint256 constant OnlyFullWordMask = 0xffffffe0;

function bytes32ToString(bytes32 value) pure returns (string memory str) {
  uint256 size;
  unchecked {
    uint256 sizeInBits = 255 - uint256(value).ffs();
    size = (sizeInBits + 7) / 8;
  }
  assembly {
    str := mload(0x40)
    mstore(0x40, add(str, 0x40))
    mstore(str, size)
    mstore(add(str, 0x20), value)
  }
}

function queryStringOrBytes32AsString(
  address target,
  uint256 leftPaddedFunctionSelector,
  uint256 leftPaddedGenericErrorSelector
) view returns (string memory str) {
  bool isBytes32;
  assembly {
    mstore(0, leftPaddedFunctionSelector)
    let status := staticcall(gas(), target, 0x1c, 0x04, 0, 0)
    isBytes32 := eq(returndatasize(), 0x20)
    // If call fails or function returns invalid data, revert.
    // Strings are always right padded to full words - if the returndata
    // is not 32 bytes (string encoded as bytes32) or >95 bytes (minimum abi
    // encoded string) it is an invalid string.
    if or(iszero(status), iszero(or(isBytes32, gt(returndatasize(), 0x5f)))) {
      // Check if call failed
      if iszero(status) {
        // Check if any revert data was given
        if returndatasize() {
          returndatacopy(0, 0, returndatasize())
          revert(0, returndatasize())
        }
        // If not, throw a generic error
        mstore(0, leftPaddedGenericErrorSelector)
        revert(0x1c, 0x04)
      }
      // If the returndata is the wrong size, `revert InvalidReturnDataString()`
      mstore(0, 0x4cb9c000)
      revert(0x1c, 0x04)
    }
  }
  if (isBytes32) {
    bytes32 value;
    assembly {
      returndatacopy(0x00, 0x00, 0x20)
      value := mload(0)
    }
    str = bytes32ToString(value);
  } else {
    // If returndata is a string, copy the length and value
    assembly {
      str := mload(0x40)
      // Get allocation size for the string including the length and data.
      // Rounding down returndatasize to nearest word because the returndata
      // has an extra offset word.
      let allocSize := and(sub(returndatasize(), 1), OnlyFullWordMask)
      mstore(0x40, add(str, allocSize))
      // Copy returndata after the offset
      returndatacopy(str, 0x20, sub(returndatasize(), 0x20))
      let length := mload(str)
      // Check if the length matches the returndatasize.
      // The encoded string should have the string length rounded up to the nearest word
      // as well as two words for length and offset.
      let expectedReturndataSize := add(allocSize, 0x20)
      if xor(returndatasize(), expectedReturndataSize) {
        mstore(0, 0x4cb9c000)
        revert(0x1c, 0x04)
      }
    }
  }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.20;

import './MarketState.sol';
import './FIFOQueue.sol';

using MathUtils for uint256;
using WithdrawalLib for WithdrawalBatch global;

/**
 * Withdrawals are grouped together in batches with a fixed expiry.
 * Until a withdrawal is paid out, the tokens are not burned from the market
 * and continue to accumulate interest.
 */
struct WithdrawalBatch {
  // Total scaled amount of tokens to be withdrawn
  uint104 scaledTotalAmount;
  // Amount of scaled tokens that have been paid by borrower
  uint104 scaledAmountBurned;
  // Amount of normalized tokens that have been paid by borrower
  uint128 normalizedAmountPaid;
}

struct AccountWithdrawalStatus {
  uint104 scaledAmount;
  uint128 normalizedAmountWithdrawn;
}

struct WithdrawalData {
  FIFOQueue unpaidBatches;
  mapping(uint32 => WithdrawalBatch) batches;
  mapping(uint256 => mapping(address => AccountWithdrawalStatus)) accountStatuses;
}

library WithdrawalLib {
  function scaledOwedAmount(WithdrawalBatch memory batch) internal pure returns (uint104) {
    return batch.scaledTotalAmount - batch.scaledAmountBurned;
  }

  /**
   * @dev Get the amount of assets which are not already reserved
   *      for prior withdrawal batches. This must only be used on
   *      the latest withdrawal batch to expire.
   */
  function availableLiquidityForPendingBatch(
    WithdrawalBatch memory batch,
    MarketState memory state,
    uint256 totalAssets
  ) internal pure returns (uint256) {
    // Subtract normalized value of pending scaled withdrawals, processed
    // withdrawals and protocol fees.
    uint256 priorScaledAmountPending = (state.scaledPendingWithdrawals - batch.scaledOwedAmount());
    uint256 unavailableAssets = state.normalizedUnclaimedWithdrawals +
      state.normalizeAmount(priorScaledAmountPending) +
      state.accruedProtocolFees;
    return totalAssets.satSub(unavailableAssets);
  }
}
// SPDX-License-Identifier: Apache-2.0 WITH LicenseRef-Commons-Clause-1.0
pragma solidity >=0.8.20;

import './WildcatMarketBase.sol';
import './WildcatMarketConfig.sol';
import './WildcatMarketToken.sol';
import './WildcatMarketWithdrawals.sol';
import '../WildcatSanctionsSentinel.sol';

contract WildcatMarket is
  WildcatMarketBase,
  WildcatMarketConfig,
  WildcatMarketToken,
  WildcatMarketWithdrawals
{
  using MathUtils for uint256;
  using SafeCastLib for uint256;
  using LibERC20 for address;
  using BoolUtils for bool;

  /**
   * @dev Apply pending interest, delinquency fees and protocol fees
   *      to the state and process the pending withdrawal batch if
   *      one exists and has expired, then update the market's
   *      delinquency status.
   */
  function updateState() external nonReentrant sphereXGuardExternal {
    MarketState memory state = _getUpdatedState();
    _writeState(state);
  }

  /**
   * @dev Token rescue function for recovering tokens sent to the market
   *      contract by mistake or otherwise outside of the normal course of
   *      operation.
   */
  function rescueTokens(address token) external nonReentrant onlyBorrower {
    if ((token == asset).or(token == address(this))) {
      revert_BadRescueAsset();
    }
    token.safeTransferAll(msg.sender);
  }

  /**
   * @dev Deposit up to `amount` underlying assets and mint market tokens
   *      for `msg.sender`.
   *
   *      The actual deposit amount is limited by the market's maximum deposit
   *      amount, which is the configured `maxTotalSupply` minus the current
   *      total supply.
   *
   *      Reverts if the market is closed or if the scaled token amount
   *      that would be minted for the deposit is zero.
   */
  function _depositUpTo(
    uint256 amount
  ) internal virtual nonReentrant returns (uint256 /* actualAmount */) {
    // Get current state
    MarketState memory state = _getUpdatedState();

    if (state.isClosed) revert_DepositToClosedMarket();

    // Reduce amount if it would exceed totalSupply
    amount = MathUtils.min(amount, state.maximumDeposit());

    // Scale the mint amount
    uint104 scaledAmount = state.scaleAmount(amount).toUint104();
    if (scaledAmount == 0) revert_NullMintAmount();

    // Cache account data and revert if not authorized to deposit.
    Account memory account = _getAccount(msg.sender);

    hooks.onDeposit(msg.sender, scaledAmount, state);

    // Transfer deposit from caller
    asset.safeTransferFrom(msg.sender, address(this), amount);

    account.scaledBalance += scaledAmount;
    _accounts[msg.sender] = account;

    emit_Transfer(_runtimeConstant(address(0)), msg.sender, amount);
    emit_Deposit(msg.sender, amount, scaledAmount);

    // Increase supply
    state.scaledTotalSupply += scaledAmount;

    // Update stored state
    _writeState(state);

    return amount;
  }

  /**
   * @dev Deposit up to `amount` underlying assets and mint market tokens
   *      for `msg.sender`.
   *
   *      The actual deposit amount is limited by the market's maximum deposit
   *      amount, which is the configured `maxTotalSupply` minus the current
   *      total supply.
   *
   *      Reverts if the market is closed or if the scaled token amount
   *      that would be minted for the deposit is zero.
   */
  function depositUpTo(
    uint256 amount
  ) external virtual sphereXGuardExternal returns (uint256 /* actualAmount */) {
    return _depositUpTo(amount);
  }

  /**
   * @dev Deposit exactly `amount` underlying assets and mint market tokens
   *      for `msg.sender`.
   *
   *     Reverts if the deposit amount would cause the market to exceed the
   *     configured `maxTotalSupply`.
   */
  function deposit(uint256 amount) external virtual sphereXGuardExternal {
    uint256 actualAmount = _depositUpTo(amount);
    if (amount != actualAmount) revert_MaxSupplyExceeded();
  }

  /**
   * @dev Withdraw available protocol fees to the fee recipient.
   */
  function collectFees() external nonReentrant sphereXGuardExternal {
    MarketState memory state = _getUpdatedState();
    if (state.accruedProtocolFees == 0) revert_NullFeeAmount();

    uint128 withdrawableFees = state.withdrawableProtocolFees(totalAssets());
    if (withdrawableFees == 0) revert_InsufficientReservesForFeeWithdrawal();

    state.accruedProtocolFees -= withdrawableFees;
    asset.safeTransfer(feeRecipient, withdrawableFees);
    _writeState(state);
    emit_FeesCollected(withdrawableFees);
  }

  /**
   * @dev Withdraw funds from the market to the borrower.
   *
   *      Can only withdraw up to the assets that are not required
   *      to meet the borrower's collateral obligations.
   *
   *      Reverts if the market is closed.
   */
  function borrow(uint256 amount) external onlyBorrower nonReentrant sphereXGuardExternal {
    // Check if the borrower is flagged as a sanctioned entity on Chainalysis.
    // Uses `isFlaggedByChainalysis` instead of `isSanctioned` to prevent the borrower
    // overriding their sanction status.
    if (_isFlaggedByChainalysis(borrower)) {
      revert_BorrowWhileSanctioned();
    }

    MarketState memory state = _getUpdatedState();
    if (state.isClosed) revert_BorrowFromClosedMarket();

    uint256 borrowable = state.borrowableAssets(totalAssets());
    if (amount > borrowable) revert_BorrowAmountTooHigh();

    // Execute borrow hook if enabled
    hooks.onBorrow(amount, state);

    asset.safeTransfer(msg.sender, amount);
    _writeState(state);
    emit_Borrow(amount);
  }

  function _repay(MarketState memory state, uint256 amount, uint256 baseCalldataSize) internal {
    if (amount == 0) revert_NullRepayAmount();
    if (state.isClosed) revert_RepayToClosedMarket();

    asset.safeTransferFrom(msg.sender, address(this), amount);
    emit_DebtRepaid(msg.sender, amount);

    // Execute repay hook if enabled
    hooks.onRepay(amount, state, baseCalldataSize);
  }

  /**
   * @dev Transfers funds from the caller to the market.
   *
   *      Any payments made through this function are considered
   *      repayments from the borrower. Do *not* use this function
   *      if you are a lender or an unrelated third party.
   *
   *      Reverts if the market is closed or `amount` is 0.
   */
  function repay(uint256 amount) external nonReentrant sphereXGuardExternal {
    if (amount == 0) revert_NullRepayAmount();

    asset.safeTransferFrom(msg.sender, address(this), amount);
    emit_DebtRepaid(msg.sender, amount);

    MarketState memory state = _getUpdatedState();
    if (state.isClosed) revert_RepayToClosedMarket();

    // Execute repay hook if enabled
    hooks.onRepay(amount, state, _runtimeConstant(0x24));

    _writeState(state);
  }

  /**
   * @dev Sets the market APR to 0% and marks market as closed.
   *
   *      Can not be called if there are any unpaid withdrawal batches.
   *
   *      Transfers remaining debts from borrower if market is not fully
   *      collateralized; otherwise, transfers any assets in excess of
   *      debts to the borrower.
   */
  function closeMarket() external onlyBorrower nonReentrant sphereXGuardExternal {
    MarketState memory state = _getUpdatedState();

    if (state.isClosed) revert_MarketAlreadyClosed();

    uint256 currentlyHeld = totalAssets();
    uint256 totalDebts = state.totalDebts();
    if (currentlyHeld < totalDebts) {
      // Transfer remaining debts from borrower
      uint256 remainingDebt = totalDebts - currentlyHeld;
      _repay(state, remainingDebt, 0x04);
      currentlyHeld += remainingDebt;
    } else if (currentlyHeld > totalDebts) {
      uint256 excessDebt = currentlyHeld - totalDebts;
      // Transfer excess assets to borrower
      asset.safeTransfer(borrower, excessDebt);
      currentlyHeld -= excessDebt;
    }
    hooks.onCloseMarket(state);
    state.annualInterestBips = 0;
    state.isClosed = true;
    state.reserveRatioBips = 10000;
    // Ensures that delinquency fee doesn't increase scale factor further
    // as doing so would mean last lender in market couldn't fully redeem
    state.timeDelinquent = 0;

    // Still track available liquidity in case of a rounding error
    uint256 availableLiquidity = currentlyHeld -
      (state.normalizedUnclaimedWithdrawals + state.accruedProtocolFees);

    // If there is a pending withdrawal batch which is not fully paid off, set aside
    // up to the available liquidity for that batch.
    if (state.pendingWithdrawalExpiry != 0) {
      uint32 expiry = state.pendingWithdrawalExpiry;
      WithdrawalBatch memory batch = _withdrawalData.batches[expiry];
      if (batch.scaledAmountBurned < batch.scaledTotalAmount) {
        (, uint128 normalizedAmountPaid) = _applyWithdrawalBatchPayment(
          batch,
          state,
          expiry,
          availableLiquidity
        );
        availableLiquidity -= normalizedAmountPaid;
        _withdrawalData.batches[expiry] = batch;
      }

      // Remove the pending batch to ensure new withdrawals are not
      // added to it after the market is closed.
      state.pendingWithdrawalExpiry = 0;
      emit_WithdrawalBatchExpired(
        expiry,
        batch.scaledTotalAmount,
        batch.scaledAmountBurned,
        batch.normalizedAmountPaid
      );
      emit_WithdrawalBatchClosed(expiry);

      // If the batch expiry is at the time of the market's closure, create
      // a new empty batch that expires in one second to ensure new batches
      // aren't created after the market is closed with the same expiry.
      if (expiry == block.timestamp) {
        uint32 newExpiry = expiry + 1;
        emit_WithdrawalBatchCreated(newExpiry);
        state.pendingWithdrawalExpiry = newExpiry;
      }
    }

    uint256 numBatches = _withdrawalData.unpaidBatches.length();
    for (uint256 i; i < numBatches; i++) {
      // Process the next unpaid batch using available liquidity
      uint256 normalizedAmountPaid = _processUnpaidWithdrawalBatch(state, availableLiquidity);
      // Reduce liquidity available to next batch
      availableLiquidity -= normalizedAmountPaid;
    }

    if (state.scaledPendingWithdrawals != 0) {
      revert_CloseMarketWithUnpaidWithdrawals();
    }

    _writeState(state);
    emit_MarketClosed(block.timestamp);
  }

  /**
   * @dev Queues a full withdrawal of a sanctioned account's assets.
   */
  function _blockAccount(MarketState memory state, address accountAddress) internal override {
    Account memory account = _accounts[accountAddress];
    if (account.scaledBalance > 0) {
      uint104 scaledAmount = account.scaledBalance;

      uint256 normalizedAmount = state.normalizeAmount(scaledAmount);

      uint32 expiry = _queueWithdrawal(
        state,
        account,
        accountAddress,
        scaledAmount,
        normalizedAmount,
        msg.data.length
      );

      emit_SanctionedAccountAssetsQueuedForWithdrawal(
        accountAddress,
        expiry,
        scaledAmount,
        normalizedAmount
      );
    }
  }
}
// SPDX-License-Identifier: Apache-2.0 WITH LicenseRef-Commons-Clause-1.0
pragma solidity >=0.8.20;

import '../ReentrancyGuard.sol';
import '../spherex/SphereXProtectedRegisteredBase.sol';
import '../interfaces/IMarketEventsAndErrors.sol';
import '../interfaces/IERC20.sol';
import '../IHooksFactory.sol';
import '../libraries/FeeMath.sol';
import '../libraries/MarketErrors.sol';
import '../libraries/MarketEvents.sol';
import '../libraries/Withdrawal.sol';
import '../libraries/FunctionTypeCasts.sol';
import '../libraries/LibERC20.sol';
import '../types/HooksConfig.sol';

contract WildcatMarketBase is
  SphereXProtectedRegisteredBase,
  ReentrancyGuard,
  IMarketEventsAndErrors
{
  using SafeCastLib for uint256;
  using MathUtils for uint256;
  using FunctionTypeCasts for *;
  using LibERC20 for address;

  // ==================================================================== //
  //                       Market Config (immutable)                       //
  // ==================================================================== //

  /**
   * @dev Return the contract version string "2".
   */
  function version() external pure returns (string memory) {
    assembly {
      mstore(0x40, 0)
      mstore(0x41, 0x0132)
      mstore(0x20, 0x20)
      return(0x20, 0x60)
    }
  }

  HooksConfig public immutable hooks;

  /// @dev Account with blacklist control, used for blocking sanctioned addresses.
  address public immutable sentinel;

  /// @dev Account with authority to borrow assets from the market.
  address public immutable borrower;

  /// @dev Factory that deployed the market. Has the ability to update the protocol fee.
  address public immutable factory;

  /// @dev Account that receives protocol fees.
  address public immutable feeRecipient;

  /// @dev Penalty fee added to interest earned by lenders, does not affect protocol fee.
  uint public immutable delinquencyFeeBips;

  /// @dev Time after which delinquency incurs penalty fee.
  uint public immutable delinquencyGracePeriod;

  /// @dev Time before withdrawal batches are processed.
  uint public immutable withdrawalBatchDuration;

  /// @dev Token decimals (same as underlying asset).
  uint8 public immutable decimals;

  /// @dev Address of the underlying asset.
  address public immutable asset;

  bytes32 internal immutable PACKED_NAME_WORD_0;
  bytes32 internal immutable PACKED_NAME_WORD_1;
  bytes32 internal immutable PACKED_SYMBOL_WORD_0;
  bytes32 internal immutable PACKED_SYMBOL_WORD_1;

  function symbol() external view returns (string memory) {
    bytes32 symbolWord0 = PACKED_SYMBOL_WORD_0;
    bytes32 symbolWord1 = PACKED_SYMBOL_WORD_1;

    assembly {
      // The layout here is:
      // 0x00: Offset to the string
      // 0x20: Length of the string
      // 0x40: First word of the string
      // 0x60: Second word of the string
      // The first word of the string that is kept in immutable storage also contains the
      // length byte, meaning the total size limit of the string is 63 bytes.
      mstore(0, 0x20)
      mstore(0x20, 0)
      mstore(0x3f, symbolWord0)
      mstore(0x5f, symbolWord1)
      return(0, 0x80)
    }
  }

  function name() external view returns (string memory) {
    bytes32 nameWord0 = PACKED_NAME_WORD_0;
    bytes32 nameWord1 = PACKED_NAME_WORD_1;

    assembly {
      // The layout here is:
      // 0x00: Offset to the string
      // 0x20: Length of the string
      // 0x40: First word of the string
      // 0x60: Second word of the string
      // The first word of the string that is kept in immutable storage also contains the
      // length byte, meaning the total size limit of the string is 63 bytes.
      mstore(0, 0x20)
      mstore(0x20, 0)
      mstore(0x3f, nameWord0)
      mstore(0x5f, nameWord1)
      return(0, 0x80)
    }
  }

  /// @dev Returns immutable arch-controller address.
  function archController() external view returns (address) {
    return _archController;
  }

  // ===================================================================== //
  //                             Market State                               //
  // ===================================================================== //

  MarketState internal _state;

  mapping(address => Account) internal _accounts;

  WithdrawalData internal _withdrawalData;

  // ===================================================================== //
  //                             Constructor                               //
  // ===================================================================== //

  function _getMarketParameters() internal view returns (uint256 marketParametersPointer) {
    assembly {
      marketParametersPointer := mload(0x40)
      mstore(0x40, add(marketParametersPointer, 0x260))
      // Write the selector for IHooksFactory.getMarketParameters
      mstore(0x00, 0x04032dbb)
      // Call `getMarketParameters` and copy the returned struct to the allocated memory
      // buffer, reverting if the call fails or does not return the correct amount of bytes.
      // This overrides all the ABI decoding safety checks, as the call is always made to
      // the factory contract which will only ever return the prepared market parameters.
      if iszero(
        and(
          eq(returndatasize(), 0x260),
          staticcall(gas(), caller(), 0x1c, 0x04, marketParametersPointer, 0x260)
        )
      ) {
        revert(0, 0)
      }
    }
  }

  constructor() {
    factory = msg.sender;
    // Cast the function signature of `_getMarketParameters` to get a valid reference to
    // a `MarketParameters` object without creating a duplicate allocation or unnecessarily
    // zeroing out the memory buffer.
    MarketParameters memory parameters = _getMarketParameters.asReturnsMarketParameters()();

    // Set asset metadata
    asset = parameters.asset;
    decimals = parameters.decimals;

    PACKED_NAME_WORD_0 = parameters.packedNameWord0;
    PACKED_NAME_WORD_1 = parameters.packedNameWord1;
    PACKED_SYMBOL_WORD_0 = parameters.packedSymbolWord0;
    PACKED_SYMBOL_WORD_1 = parameters.packedSymbolWord1;

    {
      // Initialize the market state - all values in slots 1 and 2 of the struct are
      // initialized to zero, so they are skipped.

      uint maxTotalSupply = parameters.maxTotalSupply;
      uint reserveRatioBips = parameters.reserveRatioBips;
      uint annualInterestBips = parameters.annualInterestBips;
      uint protocolFeeBips = parameters.protocolFeeBips;

      assembly {
        // MarketState Slot 0 Storage Layout:
        // [15:31] | state.maxTotalSupply
        // [31:32] | state.isClosed = false

        let slot0 := shl(8, maxTotalSupply)
        sstore(_state.slot, slot0)

        // MarketState Slot 3 Storage Layout:
        // [4:8] | lastInterestAccruedTimestamp
        // [8:22] | scaleFactor = 1e27
        // [22:24] | reserveRatioBips
        // [24:26] | annualInterestBips
        // [26:28] | protocolFeeBips
        // [28:32] | timeDelinquent = 0

        let slot3 := or(
          or(or(shl(0xc0, timestamp()), shl(0x50, RAY)), shl(0x40, reserveRatioBips)),
          or(shl(0x30, annualInterestBips), shl(0x20, protocolFeeBips))
        )

        sstore(add(_state.slot, 3), slot3)
      }
    }

    hooks = parameters.hooks;
    sentinel = parameters.sentinel;
    borrower = parameters.borrower;
    feeRecipient = parameters.feeRecipient;
    delinquencyFeeBips = parameters.delinquencyFeeBips;
    delinquencyGracePeriod = parameters.delinquencyGracePeriod;
    withdrawalBatchDuration = parameters.withdrawalBatchDuration;
    _archController = parameters.archController;
    __SphereXProtectedRegisteredBase_init(parameters.sphereXEngine);
  }

  // ===================================================================== //
  //                              Modifiers                                //
  // ===================================================================== //

  modifier onlyBorrower() {
    address _borrower = borrower;
    assembly {
      // Equivalent to
      // if (msg.sender != borrower) revert NotApprovedBorrower();
      if xor(caller(), _borrower) {
        mstore(0, 0x02171e6a)
        revert(0x1c, 0x04)
      }
    }
    _;
  }

  // ===================================================================== //
  //                       Internal State Getters                          //
  // ===================================================================== //

  /**
   * @dev Retrieve an account from storage.
   *
   *      Reverts if account is sanctioned.
   */
  function _getAccount(address accountAddress) internal view returns (Account memory account) {
    account = _accounts[accountAddress];
    if (_isSanctioned(accountAddress)) revert_AccountBlocked();
  }

  /**
   * @dev Checks if `account` is flagged as a sanctioned entity by Chainalysis.
   *      If an account is flagged mistakenly, the borrower can override their
   *      status on the sentinel and allow them to interact with the market.
   */
  function _isSanctioned(address account) internal view returns (bool result) {
    address _borrower = borrower;
    address _sentinel = address(sentinel);
    assembly {
      let freeMemoryPointer := mload(0x40)
      mstore(0, 0x06e74444)
      mstore(0x20, _borrower)
      mstore(0x40, account)
      // Call `sentinel.isSanctioned(borrower, account)` and revert if the call fails
      // or does not return 32 bytes.
      if iszero(
        and(eq(returndatasize(), 0x20), staticcall(gas(), _sentinel, 0x1c, 0x44, 0, 0x20))
      ) {
        returndatacopy(0, 0, returndatasize())
        revert(0, returndatasize())
      }
      result := mload(0)
      mstore(0x40, freeMemoryPointer)
    }
  }

  // ===================================================================== //
  //                       External State Getters                          //
  // ===================================================================== //

  /**
   * @dev Returns the amount of underlying assets the borrower is obligated
   *      to maintain in the market to avoid delinquency.
   */
  function coverageLiquidity() external view nonReentrantView returns (uint256) {
    return _calculateCurrentStatePointers.asReturnsMarketState()().liquidityRequired();
  }

  /**
   * @dev Returns the scale factor (in ray) used to convert scaled balances
   *      to normalized balances.
   */
  function scaleFactor() external view nonReentrantView returns (uint256) {
    return _calculateCurrentStatePointers.asReturnsMarketState()().scaleFactor;
  }

  /**
   * @dev Total balance in underlying asset.
   */
  function totalAssets() public view returns (uint256) {
    return asset.balanceOf(address(this));
  }

  /**
   * @dev Returns the amount of underlying assets the borrower is allowed
   *      to borrow.
   *
   *      This is the balance of underlying assets minus:
   *      - pending (unpaid) withdrawals
   *      - paid withdrawals
   *      - reserve ratio times the portion of the supply not pending withdrawal
   *      - protocol fees
   */
  function borrowableAssets() external view nonReentrantView returns (uint256) {
    return _calculateCurrentStatePointers.asReturnsMarketState()().borrowableAssets(totalAssets());
  }

  /**
   * @dev Returns the amount of protocol fees (in underlying asset amount)
   *      that have accrued and are pending withdrawal.
   */
  function accruedProtocolFees() external view nonReentrantView returns (uint256) {
    return _calculateCurrentStatePointers.asReturnsMarketState()().accruedProtocolFees;
  }

  function totalDebts() external view nonReentrantView returns (uint256) {
    return _calculateCurrentStatePointers.asReturnsMarketState()().totalDebts();
  }

  /**
   * @dev Returns the state of the market as of the last update.
   */
  function previousState() external view returns (MarketState memory) {
    MarketState memory state = _state;

    assembly {
      return(state, 0x1c0)
    }
  }

  /**
   * @dev Return the state the market would have at the current block after applying
   *      interest and fees accrued since the last update and processing the pending
   *      withdrawal batch if it is expired.
   */
  function currentState() external view nonReentrantView returns (MarketState memory state) {
    state = _calculateCurrentStatePointers.asReturnsMarketState()();
    assembly {
      return(state, 0x1c0)
    }
  }

  /**
   * @dev Call `_calculateCurrentState()` and return only the `state` parameter.
   *
   *      Casting the function type prevents a duplicate declaration of the MarketState
   *      return parameter, which would cause unnecessary zeroing and allocation of memory.
   *      With `viaIR` enabled, the cast is a noop.
   */
  function _calculateCurrentStatePointers() internal view returns (uint256 state) {
    (state, , ) = _calculateCurrentState.asReturnsPointers()();
  }

  /**
   * @dev Returns the scaled total supply the vaut would have at the current block
   *      after applying interest and fees accrued since the last update and burning
   *      market tokens for the pending withdrawal batch if it is expired.
   */
  function scaledTotalSupply() external view nonReentrantView returns (uint256) {
    return _calculateCurrentStatePointers.asReturnsMarketState()().scaledTotalSupply;
  }

  /**
   * @dev Returns the scaled balance of `account`
   */
  function scaledBalanceOf(address account) external view nonReentrantView returns (uint256) {
    return _accounts[account].scaledBalance;
  }

  /**
   * @dev Returns the amount of protocol fees that are currently
   *      withdrawable by the fee recipient.
   */
  function withdrawableProtocolFees() external view returns (uint128) {
    return
      _calculateCurrentStatePointers.asReturnsMarketState()().withdrawableProtocolFees(
        totalAssets()
      );
  }

  // /*//////////////////////////////////////////////////////////////
  //                     Internal State Handlers
  // //////////////////////////////////////////////////////////////*/

  function _blockAccount(MarketState memory state, address accountAddress) internal virtual {}

  /**
   * @dev Returns cached MarketState after accruing interest and delinquency / protocol fees
   *      and processing expired withdrawal batch, if any.
   *
   *      Used by functions that make additional changes to `state`.
   *
   *      NOTE: Returned `state` does not match `_state` if interest is accrued
   *            Calling function must update `_state` or revert.
   *
   * @return state Market state after interest is accrued.
   */
  function _getUpdatedState() internal returns (MarketState memory state) {
    state = _state;
    // Handle expired withdrawal batch
    if (state.hasPendingExpiredBatch()) {
      uint256 expiry = state.pendingWithdrawalExpiry;
      // Only accrue interest if time has passed since last update.
      // This will only be false if withdrawalBatchDuration is 0.
      uint32 lastInterestAccruedTimestamp = state.lastInterestAccruedTimestamp;
      if (expiry != lastInterestAccruedTimestamp) {
        (uint256 baseInterestRay, uint256 delinquencyFeeRay, uint256 protocolFee) = state
          .updateScaleFactorAndFees(delinquencyFeeBips, delinquencyGracePeriod, expiry);
        emit_InterestAndFeesAccrued(
          lastInterestAccruedTimestamp,
          expiry,
          state.scaleFactor,
          baseInterestRay,
          delinquencyFeeRay,
          protocolFee
        );
      }
      _processExpiredWithdrawalBatch(state);
    }
    uint32 lastInterestAccruedTimestamp = state.lastInterestAccruedTimestamp;
    // Apply interest and fees accrued since last update (expiry or previous tx)
    if (block.timestamp != lastInterestAccruedTimestamp) {
      (uint256 baseInterestRay, uint256 delinquencyFeeRay, uint256 protocolFee) = state
        .updateScaleFactorAndFees(delinquencyFeeBips, delinquencyGracePeriod, block.timestamp);
      emit_InterestAndFeesAccrued(
        lastInterestAccruedTimestamp,
        block.timestamp,
        state.scaleFactor,
        baseInterestRay,
        delinquencyFeeRay,
        protocolFee
      );
    }

    // If there is a pending withdrawal batch which is not fully paid off, set aside
    // up to the available liquidity for that batch.
    if (state.pendingWithdrawalExpiry != 0) {
      uint32 expiry = state.pendingWithdrawalExpiry;
      WithdrawalBatch memory batch = _withdrawalData.batches[expiry];
      if (batch.scaledAmountBurned < batch.scaledTotalAmount) {
        // Burn as much of the withdrawal batch as possible with available liquidity.
        uint256 availableLiquidity = batch.availableLiquidityForPendingBatch(state, totalAssets());
        if (availableLiquidity > 0) {
          _applyWithdrawalBatchPayment(batch, state, expiry, availableLiquidity);
          _withdrawalData.batches[expiry] = batch;
        }
      }
    }
  }

  /**
   * @dev Calculate the current state, applying fees and interest accrued since
   *      the last state update as well as the effects of withdrawal batch expiry
   *      on the market state.
   *      Identical to _getUpdatedState() except it does not modify storage or
   *      or emit events.
   *      Returns expired batch data, if any, so queries against batches have
   *      access to the most recent data.
   */
  function _calculateCurrentState()
    internal
    view
    returns (
      MarketState memory state,
      uint32 pendingBatchExpiry,
      WithdrawalBatch memory pendingBatch
    )
  {
    state = _state;
    // Handle expired withdrawal batch
    if (state.hasPendingExpiredBatch()) {
      pendingBatchExpiry = state.pendingWithdrawalExpiry;
      // Only accrue interest if time has passed since last update.
      // This will only be false if withdrawalBatchDuration is 0.
      if (pendingBatchExpiry != state.lastInterestAccruedTimestamp) {
        state.updateScaleFactorAndFees(
          delinquencyFeeBips,
          delinquencyGracePeriod,
          pendingBatchExpiry
        );
      }

      pendingBatch = _withdrawalData.batches[pendingBatchExpiry];
      uint256 availableLiquidity = pendingBatch.availableLiquidityForPendingBatch(
        state,
        totalAssets()
      );
      if (availableLiquidity > 0) {
        _applyWithdrawalBatchPaymentView(pendingBatch, state, availableLiquidity);
      }
      state.pendingWithdrawalExpiry = 0;
    }

    if (state.lastInterestAccruedTimestamp != block.timestamp) {
      state.updateScaleFactorAndFees(delinquencyFeeBips, delinquencyGracePeriod, block.timestamp);
    }

    // If there is a pending withdrawal batch which is not fully paid off, set aside
    // up to the available liquidity for that batch.
    if (state.pendingWithdrawalExpiry != 0) {
      pendingBatchExpiry = state.pendingWithdrawalExpiry;
      pendingBatch = _withdrawalData.batches[pendingBatchExpiry];
      if (pendingBatch.scaledAmountBurned < pendingBatch.scaledTotalAmount) {
        // Burn as much of the withdrawal batch as possible with available liquidity.
        uint256 availableLiquidity = pendingBatch.availableLiquidityForPendingBatch(
          state,
          totalAssets()
        );
        if (availableLiquidity > 0) {
          _applyWithdrawalBatchPaymentView(pendingBatch, state, availableLiquidity);
        }
      }
    }
  }

  /**
   * @dev Writes the cached MarketState to storage and emits an event.
   *      Used at the end of all functions which modify `state`.
   */
  function _writeState(MarketState memory state) internal {
    bool isDelinquent = state.liquidityRequired() > totalAssets();
    state.isDelinquent = isDelinquent;

    {
      bool isClosed = state.isClosed;
      uint maxTotalSupply = state.maxTotalSupply;
      assembly {
        // Slot 0 Storage Layout:
        // [15:31] | state.maxTotalSupply
        // [31:32] | state.isClosed
        let slot0 := or(isClosed, shl(0x08, maxTotalSupply))
        sstore(_state.slot, slot0)
      }
    }
    {
      uint accruedProtocolFees = state.accruedProtocolFees;
      uint normalizedUnclaimedWithdrawals = state.normalizedUnclaimedWithdrawals;
      assembly {
        // Slot 1 Storage Layout:
        // [0:16] | state.normalizedUnclaimedWithdrawals
        // [16:32] | state.accruedProtocolFees
        let slot1 := or(accruedProtocolFees, shl(0x80, normalizedUnclaimedWithdrawals))
        sstore(add(_state.slot, 1), slot1)
      }
    }
    {
      uint scaledTotalSupply = state.scaledTotalSupply;
      uint scaledPendingWithdrawals = state.scaledPendingWithdrawals;
      uint pendingWithdrawalExpiry = state.pendingWithdrawalExpiry;
      assembly {
        // Slot 2 Storage Layout:
        // [1:2] | state.isDelinquent
        // [2:6] | state.pendingWithdrawalExpiry
        // [6:19] | state.scaledPendingWithdrawals
        // [19:32] | state.scaledTotalSupply
        let slot2 := or(
          or(
            or(shl(0xf0, isDelinquent), shl(0xd0, pendingWithdrawalExpiry)),
            shl(0x68, scaledPendingWithdrawals)
          ),
          scaledTotalSupply
        )
        sstore(add(_state.slot, 2), slot2)
      }
    }
    {
      uint timeDelinquent = state.timeDelinquent;
      uint protocolFeeBips = state.protocolFeeBips;
      uint annualInterestBips = state.annualInterestBips;
      uint reserveRatioBips = state.reserveRatioBips;
      uint scaleFactor = state.scaleFactor;
      uint lastInterestAccruedTimestamp = state.lastInterestAccruedTimestamp;
      assembly {
        // Slot 3 Storage Layout:
        // [4:8] | state.lastInterestAccruedTimestamp
        // [8:22] | state.scaleFactor
        // [22:24] | state.reserveRatioBips
        // [24:26] | state.annualInterestBips
        // [26:28] | protocolFeeBips
        // [28:32] | state.timeDelinquent
        let slot3 := or(
          or(
            or(
              or(shl(0xc0, lastInterestAccruedTimestamp), shl(0x50, scaleFactor)),
              shl(0x40, reserveRatioBips)
            ),
            or(shl(0x30, annualInterestBips), shl(0x20, protocolFeeBips))
          ),
          timeDelinquent
        )
        sstore(add(_state.slot, 3), slot3)
      }
    }
    emit_StateUpdated(state.scaleFactor, isDelinquent);
  }

  /**
   * @dev Handles an expired withdrawal batch:
   *      - Retrieves the amount of underlying assets that can be used to pay for the batch.
   *      - If the amount is sufficient to pay the full amount owed to the batch, the batch
   *        is closed and the total withdrawal amount is reserved.
   *      - If the amount is insufficient to pay the full amount owed to the batch, the batch
   *        is recorded as an unpaid batch and the available assets are reserved.
   *      - The assets reserved for the batch are scaled by the current scale factor and that
   *        amount of scaled tokens is burned, ensuring borrowers do not continue paying interest
   *        on withdrawn assets.
   */
  function _processExpiredWithdrawalBatch(MarketState memory state) internal {
    uint32 expiry = state.pendingWithdrawalExpiry;
    WithdrawalBatch memory batch = _withdrawalData.batches[expiry];

    if (batch.scaledAmountBurned < batch.scaledTotalAmount) {
      // Burn as much of the withdrawal batch as possible with available liquidity.
      uint256 availableLiquidity = batch.availableLiquidityForPendingBatch(state, totalAssets());
      if (availableLiquidity > 0) {
        _applyWithdrawalBatchPayment(batch, state, expiry, availableLiquidity);
      }
    }

    emit_WithdrawalBatchExpired(
      expiry,
      batch.scaledTotalAmount,
      batch.scaledAmountBurned,
      batch.normalizedAmountPaid
    );

    if (batch.scaledAmountBurned < batch.scaledTotalAmount) {
      _withdrawalData.unpaidBatches.push(expiry);
    } else {
      emit_WithdrawalBatchClosed(expiry);
    }

    state.pendingWithdrawalExpiry = 0;

    _withdrawalData.batches[expiry] = batch;
  }

  /**
   * @dev Process withdrawal payment, burning market tokens and reserving
   *      underlying assets so they are only available for withdrawals.
   */
  function _applyWithdrawalBatchPayment(
    WithdrawalBatch memory batch,
    MarketState memory state,
    uint32 expiry,
    uint256 availableLiquidity
  ) internal returns (uint104 scaledAmountBurned, uint128 normalizedAmountPaid) {
    uint104 scaledAmountOwed = batch.scaledTotalAmount - batch.scaledAmountBurned;

    // Do nothing if batch is already paid
    if (scaledAmountOwed == 0) return (0, 0);

    uint256 scaledAvailableLiquidity = state.scaleAmount(availableLiquidity);
    scaledAmountBurned = MathUtils.min(scaledAvailableLiquidity, scaledAmountOwed).toUint104();
    // Use mulDiv instead of normalizeAmount to round `normalizedAmountPaid` down, ensuring
    // it is always possible to finish withdrawal batches on closed markets.
    normalizedAmountPaid = MathUtils.mulDiv(scaledAmountBurned, state.scaleFactor, RAY).toUint128();

    batch.scaledAmountBurned += scaledAmountBurned;
    batch.normalizedAmountPaid += normalizedAmountPaid;
    state.scaledPendingWithdrawals -= scaledAmountBurned;

    // Update normalizedUnclaimedWithdrawals so the tokens are only accessible for withdrawals.
    state.normalizedUnclaimedWithdrawals += normalizedAmountPaid;

    // Burn market tokens to stop interest accrual upon withdrawal payment.
    state.scaledTotalSupply -= scaledAmountBurned;

    // Emit transfer for external trackers to indicate burn.
    emit_Transfer(address(this), _runtimeConstant(address(0)), normalizedAmountPaid);
    emit_WithdrawalBatchPayment(expiry, scaledAmountBurned, normalizedAmountPaid);
  }

  function _applyWithdrawalBatchPaymentView(
    WithdrawalBatch memory batch,
    MarketState memory state,
    uint256 availableLiquidity
  ) internal pure {
    uint104 scaledAmountOwed = batch.scaledTotalAmount - batch.scaledAmountBurned;
    // Do nothing if batch is already paid
    if (scaledAmountOwed == 0) return;

    uint256 scaledAvailableLiquidity = state.scaleAmount(availableLiquidity);
    uint104 scaledAmountBurned = MathUtils
      .min(scaledAvailableLiquidity, scaledAmountOwed)
      .toUint104();
    // Use mulDiv instead of normalizeAmount to round `normalizedAmountPaid` down, ensuring
    // it is always possible to finish withdrawal batches on closed markets.
    uint128 normalizedAmountPaid = MathUtils
      .mulDiv(scaledAmountBurned, state.scaleFactor, RAY)
      .toUint128();

    batch.scaledAmountBurned += scaledAmountBurned;
    batch.normalizedAmountPaid += normalizedAmountPaid;
    state.scaledPendingWithdrawals -= scaledAmountBurned;

    // Update normalizedUnclaimedWithdrawals so the tokens are only accessible for withdrawals.
    state.normalizedUnclaimedWithdrawals += normalizedAmountPaid;

    // Burn market tokens to stop interest accrual upon withdrawal payment.
    state.scaledTotalSupply -= scaledAmountBurned;
  }

  /**
   * @dev Function to obfuscate the fact that a value is constant from solc's optimizer.
   *      This prevents function specialization for calls with a constant input parameter,
   *      which usually has very little benefit in terms of gas savings but can
   *      drastically increase contract size.
   *
   *      The value returned will always match the input value outside of the constructor,
   *      fallback and receive functions.
   */
  function _runtimeConstant(
    uint256 actualConstant
  ) internal pure returns (uint256 runtimeConstant) {
    assembly {
      mstore(0, actualConstant)
      runtimeConstant := mload(iszero(calldatasize()))
    }
  }

  function _runtimeConstant(
    address actualConstant
  ) internal pure returns (address runtimeConstant) {
    assembly {
      mstore(0, actualConstant)
      runtimeConstant := mload(iszero(calldatasize()))
    }
  }

  function _isFlaggedByChainalysis(address account) internal view returns (bool isFlagged) {
    address sentinelAddress = address(sentinel);
    assembly {
      mstore(0, 0x95c09839)
      mstore(0x20, account)
      if iszero(
        and(eq(returndatasize(), 0x20), staticcall(gas(), sentinelAddress, 0x1c, 0x24, 0, 0x20))
      ) {
        returndatacopy(0, 0, returndatasize())
        revert(0, returndatasize())
      }
      isFlagged := mload(0)
    }
  }

  function _createEscrowForUnderlyingAsset(
    address accountAddress
  ) internal returns (address escrow) {
    address tokenAddress = address(asset);
    address borrowerAddress = borrower;
    address sentinelAddress = address(sentinel);

    assembly {
      let freeMemoryPointer := mload(0x40)
      mstore(0, 0xa1054f6b)
      mstore(0x20, borrowerAddress)
      mstore(0x40, accountAddress)
      mstore(0x60, tokenAddress)
      if iszero(
        and(eq(returndatasize(), 0x20), call(gas(), sentinelAddress, 0, 0x1c, 0x64, 0, 0x20))
      ) {
        returndatacopy(0, 0, returndatasize())
        revert(0, returndatasize())
      }
      escrow := mload(0)
      mstore(0x40, freeMemoryPointer)
      mstore(0x60, 0)
    }
  }
}
// SPDX-License-Identifier: Apache-2.0 WITH LicenseRef-Commons-Clause-1.0
pragma solidity >=0.8.20;

import './WildcatMarketBase.sol';
import '../libraries/FeeMath.sol';
import '../libraries/SafeCastLib.sol';

contract WildcatMarketConfig is WildcatMarketBase {
  using SafeCastLib for uint256;
  using FunctionTypeCasts for *;

  // ===================================================================== //
  //                      External Config Getters                          //
  // ===================================================================== //

  /**
   * @dev Returns whether or not a market has been closed.
   */
  function isClosed() external view returns (bool) {
    // Use stored state because the state update can not affect whether
    // the market is closed.
    return _state.isClosed;
  }

  /**
   * @dev Returns the maximum amount of underlying asset that can
   *      currently be deposited to the market.
   */
  function maximumDeposit() external view returns (uint256) {
    MarketState memory state = _calculateCurrentStatePointers.asReturnsMarketState()();
    return state.maximumDeposit();
  }

  /**
   * @dev Returns the maximum supply the market can reach via
   *      deposits (does not apply to interest accrual).
   */
  function maxTotalSupply() external view returns (uint256) {
    return _state.maxTotalSupply;
  }

  /**
   * @dev Returns the annual interest rate earned by lenders
   *      in bips.
   */
  function annualInterestBips() external view returns (uint256) {
    return _state.annualInterestBips;
  }

  function reserveRatioBips() external view returns (uint256) {
    return _state.reserveRatioBips;
  }

  // ========================================================================== //
  //                                  Sanctions                                 //
  // ========================================================================== //

  /// @dev Block a sanctioned account from interacting with the market
  ///      and transfer its balance to an escrow contract.
  // ******************************************************************
  //          *  |\**/|  *          *                                *
  //          *  \ == /  *          *                                *
  //          *   | b|   *          *                                *
  //          *   | y|   *          *                                *
  //          *   \ e/   *          *                                *
  //          *    \/    *          *                                *
  //          *          *          *                                *
  //          *          *          *                                *
  //          *          *  |\**/|  *                                *
  //          *          *  \ == /  *         _.-^^---....,,--       *
  //          *          *   | b|   *    _--                  --_    *
  //          *          *   | y|   *   <                        >)  *
  //          *          *   \ e/   *   |         O-FAC!          |  *
  //          *          *    \/    *    \._                   _./   *
  //          *          *          *       ```--. . , ; .--'''      *
  //          *          *          *   💸        | |   |            *
  //          *          *          *          .-=||  | |=-.    💸   *
  //  💰🤑💰  *    😅    *    😐    *    💸    `-=#$%&%$#=-'         *
  //   \|/    *   /|\    *   /|\    *  🌪         | ;  :|    🌪      *
  //   /\     * 💰/\ 💰  * 💰/\ 💰  *    _____.,-#%&$@%#&#~,._____   *
  // ******************************************************************
  function nukeFromOrbit(address accountAddress) external nonReentrant sphereXGuardExternal {
    if (!_isSanctioned(accountAddress)) revert_BadLaunchCode();
    MarketState memory state = _getUpdatedState();
    hooks.onNukeFromOrbit(accountAddress, state);
    _blockAccount(state, accountAddress);
    _writeState(state);
  }

  // ========================================================================== //
  //                           External Config Setters                          //
  // ========================================================================== //

  /**
   * @dev Sets the maximum total supply - this only limits deposits and
   *      does not affect interest accrual.
   *
   *      The hooks contract may block the change but can not modify the
   *      value being set.
   */
  function setMaxTotalSupply(
    uint256 _maxTotalSupply
  ) external onlyBorrower nonReentrant sphereXGuardExternal {
    MarketState memory state = _getUpdatedState();
    if (state.isClosed) revert_CapacityChangeOnClosedMarket();

    hooks.onSetMaxTotalSupply(_maxTotalSupply, state);
    state.maxTotalSupply = _maxTotalSupply.toUint128();
    _writeState(state);
    emit_MaxTotalSupplyUpdated(_maxTotalSupply);
  }

  /**
   * @dev Sets the annual interest rate earned by lenders in bips.
   *
   *      If the new reserve ratio is lower than the old ratio,
   *      asserts that the market is not currently delinquent.
   *
   *      If the new reserve ratio is higher than the old ratio,
   *      asserts that the market will not become delinquent
   *      because of the change.
   */
  function setAnnualInterestAndReserveRatioBips(
    uint16 _annualInterestBips,
    uint16 _reserveRatioBips
  ) external onlyBorrower nonReentrant sphereXGuardExternal {
    MarketState memory state = _getUpdatedState();
    if (state.isClosed) revert_AprChangeOnClosedMarket();

    uint256 initialReserveRatioBips = state.reserveRatioBips;

    (_annualInterestBips, _reserveRatioBips) = hooks.onSetAnnualInterestAndReserveRatioBips(
      _annualInterestBips,
      _reserveRatioBips,
      state
    );

    if (_annualInterestBips > BIP) {
      revert_AnnualInterestBipsTooHigh();
    }

    if (_reserveRatioBips > BIP) {
      revert_ReserveRatioBipsTooHigh();
    }

    if (_reserveRatioBips <= initialReserveRatioBips) {
      if (state.liquidityRequired() > totalAssets()) {
        revert_InsufficientReservesForOldLiquidityRatio();
      }
    }
    state.reserveRatioBips = _reserveRatioBips;
    state.annualInterestBips = _annualInterestBips;
    if (_reserveRatioBips > initialReserveRatioBips) {
      if (state.liquidityRequired() > totalAssets()) {
        revert_InsufficientReservesForNewLiquidityRatio();
      }
    }

    _writeState(state);
    emit_AnnualInterestBipsUpdated(_annualInterestBips);
    emit_ReserveRatioBipsUpdated(_reserveRatioBips);
  }

  function setProtocolFeeBips(uint16 _protocolFeeBips) external nonReentrant sphereXGuardExternal {
    if (msg.sender != factory) revert_NotFactory();
    if (_protocolFeeBips > 1_000) revert_ProtocolFeeTooHigh();
    MarketState memory state = _getUpdatedState();
    if (state.isClosed) revert_ProtocolFeeChangeOnClosedMarket();
    if (_protocolFeeBips != state.protocolFeeBips) {
      hooks.onSetProtocolFeeBips(_protocolFeeBips, state);
      state.protocolFeeBips = _protocolFeeBips;
      emit ProtocolFeeBipsUpdated(_protocolFeeBips);
    }
    _writeState(state);
  }
}
// SPDX-License-Identifier: Apache-2.0 WITH LicenseRef-Commons-Clause-1.0
pragma solidity >=0.8.20;

import './WildcatMarketBase.sol';

contract WildcatMarketToken is WildcatMarketBase {
  using SafeCastLib for uint256;
  using FunctionTypeCasts for *;

  // ========================================================================== //
  //                                ERC20 Queries                               //
  // ========================================================================== //

  mapping(address => mapping(address => uint256)) public allowance;

  /// @notice Returns the normalized balance of `account` with interest.
  function balanceOf(address account) public view virtual nonReentrantView returns (uint256) {
    return
      _calculateCurrentStatePointers.asReturnsMarketState()().normalizeAmount(
        _accounts[account].scaledBalance
      );
  }

  /// @notice Returns the normalized total supply with interest.
  function totalSupply() external view virtual nonReentrantView returns (uint256) {
    return _calculateCurrentStatePointers.asReturnsMarketState()().totalSupply();
  }

  // ========================================================================== //
  //                                ERC20 Actions                               //
  // ========================================================================== //

  function approve(
    address spender,
    uint256 amount
  ) external virtual nonReentrant sphereXGuardExternal returns (bool) {
    _approve(msg.sender, spender, amount);
    return true;
  }

  function transfer(
    address to,
    uint256 amount
  ) external virtual nonReentrant sphereXGuardExternal returns (bool) {
    _transfer(msg.sender, to, amount, 0x44);
    return true;
  }

  function transferFrom(
    address from,
    address to,
    uint256 amount
  ) external virtual nonReentrant sphereXGuardExternal returns (bool) {
    uint256 allowed = allowance[from][msg.sender];

    // Saves gas for unlimited approvals.
    if (allowed != type(uint256).max) {
      uint256 newAllowance = allowed - amount;
      _approve(from, msg.sender, newAllowance);
    }

    _transfer(from, to, amount, 0x64);

    return true;
  }

  function _approve(address approver, address spender, uint256 amount) internal virtual {
    allowance[approver][spender] = amount;
    emit_Approval(approver, spender, amount);
  }

  function _transfer(
    address from,
    address to,
    uint256 amount,
    uint baseCalldataSize
  ) internal virtual {
    MarketState memory state = _getUpdatedState();
    uint104 scaledAmount = state.scaleAmount(amount).toUint104();

    if (scaledAmount == 0) revert_NullTransferAmount();

    hooks.onTransfer(from, to, scaledAmount, state, baseCalldataSize);

    Account memory fromAccount = _getAccount(from);
    fromAccount.scaledBalance -= scaledAmount;
    _accounts[from] = fromAccount;

    Account memory toAccount = _getAccount(to);
    toAccount.scaledBalance += scaledAmount;
    _accounts[to] = toAccount;

    _writeState(state);
    emit_Transfer(from, to, amount);
  }
}
// SPDX-License-Identifier: Apache-2.0 WITH LicenseRef-Commons-Clause-1.0
pragma solidity >=0.8.20;

import './WildcatMarketBase.sol';
import '../libraries/LibERC20.sol';
import '../libraries/BoolUtils.sol';

contract WildcatMarketWithdrawals is WildcatMarketBase {
  using LibERC20 for address;
  using MathUtils for uint256;
  using MathUtils for bool;
  using SafeCastLib for uint256;
  using BoolUtils for bool;

  // ========================================================================== //
  //                             Withdrawal Queries                             //
  // ========================================================================== //

  /**
   * @dev Returns the expiry timestamp of every unpaid withdrawal batch.
   */
  function getUnpaidBatchExpiries() external view nonReentrantView returns (uint32[] memory) {
    return _withdrawalData.unpaidBatches.values();
  }

  function getWithdrawalBatch(
    uint32 expiry
  ) external view nonReentrantView returns (WithdrawalBatch memory batch) {
    (, uint32 pendingBatchExpiry, WithdrawalBatch memory pendingBatch) = _calculateCurrentState();
    if ((expiry == pendingBatchExpiry).and(expiry > 0)) {
      return pendingBatch;
    }

    WithdrawalBatch storage _batch = _withdrawalData.batches[expiry];
    batch.scaledTotalAmount = _batch.scaledTotalAmount;
    batch.scaledAmountBurned = _batch.scaledAmountBurned;
    batch.normalizedAmountPaid = _batch.normalizedAmountPaid;
  }

  function getAccountWithdrawalStatus(
    address accountAddress,
    uint32 expiry
  ) external view nonReentrantView returns (AccountWithdrawalStatus memory status) {
    AccountWithdrawalStatus storage _status = _withdrawalData.accountStatuses[expiry][
      accountAddress
    ];
    status.scaledAmount = _status.scaledAmount;
    status.normalizedAmountWithdrawn = _status.normalizedAmountWithdrawn;
  }

  function getAvailableWithdrawalAmount(
    address accountAddress,
    uint32 expiry
  ) external view nonReentrantView returns (uint256) {
    if (expiry >= block.timestamp) {
      revert_WithdrawalBatchNotExpired();
    }
    (, uint32 pendingBatchExpiry, WithdrawalBatch memory pendingBatch) = _calculateCurrentState();
    WithdrawalBatch memory batch;
    if (expiry == pendingBatchExpiry) {
      batch = pendingBatch;
    } else {
      batch = _withdrawalData.batches[expiry];
    }
    AccountWithdrawalStatus memory status = _withdrawalData.accountStatuses[expiry][accountAddress];
    // Rounding errors will lead to some dust accumulating in the batch, but the cost of
    // executing a withdrawal will be lower for users.
    uint256 previousTotalWithdrawn = status.normalizedAmountWithdrawn;
    uint256 newTotalWithdrawn = uint256(batch.normalizedAmountPaid).mulDiv(
      status.scaledAmount,
      batch.scaledTotalAmount
    );
    return newTotalWithdrawn - previousTotalWithdrawn;
  }

  // ========================================================================== //
  //                             Withdrawal Actions                             //
  // ========================================================================== //

  function _queueWithdrawal(
    MarketState memory state,
    Account memory account,
    address accountAddress,
    uint104 scaledAmount,
    uint normalizedAmount,
    uint baseCalldataSize
  ) internal returns (uint32 expiry) {
    // Cache batch expiry on the stack for gas savings
    expiry = state.pendingWithdrawalExpiry;

    // If there is no pending withdrawal batch, create a new one.
    if (state.pendingWithdrawalExpiry == 0) {
      // If the market is closed, use zero for withdrawal batch duration.
      uint duration = state.isClosed.ternary(0, withdrawalBatchDuration);
      expiry = uint32(block.timestamp + duration);
      emit_WithdrawalBatchCreated(expiry);
      state.pendingWithdrawalExpiry = expiry;
    }

    // Execute queueWithdrawal hook if enabled
    hooks.onQueueWithdrawal(accountAddress, expiry, scaledAmount, state, baseCalldataSize);

    // Reduce account's balance and emit transfer event
    account.scaledBalance -= scaledAmount;
    _accounts[accountAddress] = account;

    emit_Transfer(accountAddress, address(this), normalizedAmount);

    WithdrawalBatch memory batch = _withdrawalData.batches[expiry];

    // Add scaled withdrawal amount to account withdrawal status, withdrawal batch and market state.
    _withdrawalData.accountStatuses[expiry][accountAddress].scaledAmount += scaledAmount;
    batch.scaledTotalAmount += scaledAmount;
    state.scaledPendingWithdrawals += scaledAmount;

    emit_WithdrawalQueued(expiry, accountAddress, scaledAmount, normalizedAmount);

    // Burn as much of the withdrawal batch as possible with available liquidity.
    uint256 availableLiquidity = batch.availableLiquidityForPendingBatch(state, totalAssets());
    if (availableLiquidity > 0) {
      _applyWithdrawalBatchPayment(batch, state, expiry, availableLiquidity);
    }

    // Update stored batch data
    _withdrawalData.batches[expiry] = batch;

    // Update stored state
    _writeState(state);
  }

  /**
   * @dev Create a withdrawal request for a lender.
   */
  function queueWithdrawal(
    uint256 amount
  ) external nonReentrant sphereXGuardExternal returns (uint32 expiry) {
    MarketState memory state = _getUpdatedState();

    uint104 scaledAmount = state.scaleAmount(amount).toUint104();
    if (scaledAmount == 0) revert_NullBurnAmount();

    // Cache account data
    Account memory account = _getAccount(msg.sender);

    return
      _queueWithdrawal(state, account, msg.sender, scaledAmount, amount, _runtimeConstant(0x24));
  }

  /**
   * @dev Queue a withdrawal for all of the caller's balance.
   */
  function queueFullWithdrawal()
    external
    nonReentrant
    sphereXGuardExternal
    returns (uint32 expiry)
  {
    MarketState memory state = _getUpdatedState();

    // Cache account data
    Account memory account = _getAccount(msg.sender);

    uint104 scaledAmount = account.scaledBalance;
    if (scaledAmount == 0) revert_NullBurnAmount();

    uint256 normalizedAmount = state.normalizeAmount(scaledAmount);

    return
      _queueWithdrawal(
        state,
        account,
        msg.sender,
        scaledAmount,
        normalizedAmount,
        _runtimeConstant(0x04)
      );
  }

  /**
   * @dev Execute a pending withdrawal request for a batch that has expired.
   *
   *      Withdraws the proportional amount of the paid batch owed to
   *      `accountAddress` which has not already been withdrawn.
   *
   *      If `accountAddress` is sanctioned, transfers the owed amount to
   *      an escrow contract specific to the account and blocks the account.
   *
   *      Reverts if:
   *      - `expiry >= block.timestamp`
   *      -  `expiry` does not correspond to an existing withdrawal batch
   *      - `accountAddress` has already withdrawn the full amount owed
   */
  function executeWithdrawal(
    address accountAddress,
    uint32 expiry
  ) public nonReentrant sphereXGuardExternal returns (uint256) {
    MarketState memory state = _getUpdatedState();
    // Use an obfuscated constant for the base calldata size to prevent solc
    // function specialization.
    uint256 normalizedAmountWithdrawn = _executeWithdrawal(
      state,
      accountAddress,
      expiry,
      _runtimeConstant(0x44)
    );
    // Update stored state
    _writeState(state);
    return normalizedAmountWithdrawn;
  }

  function executeWithdrawals(
    address[] calldata accountAddresses,
    uint32[] calldata expiries
  ) external nonReentrant sphereXGuardExternal returns (uint256[] memory amounts) {
    if (accountAddresses.length != expiries.length) revert_InvalidArrayLength();

    amounts = new uint256[](accountAddresses.length);

    MarketState memory state = _getUpdatedState();

    for (uint256 i = 0; i < accountAddresses.length; i++) {
      // Use calldatasize() for baseCalldataSize to indicate no data should be passed as `extraData`
      amounts[i] = _executeWithdrawal(state, accountAddresses[i], expiries[i], msg.data.length);
    }
    // Update stored state
    _writeState(state);
    return amounts;
  }

  function _executeWithdrawal(
    MarketState memory state,
    address accountAddress,
    uint32 expiry,
    uint baseCalldataSize
  ) internal returns (uint256) {
    WithdrawalBatch memory batch = _withdrawalData.batches[expiry];
    if (expiry == state.pendingWithdrawalExpiry) revert_WithdrawalBatchNotExpired();

    AccountWithdrawalStatus storage status = _withdrawalData.accountStatuses[expiry][
      accountAddress
    ];

    uint128 newTotalWithdrawn = uint128(
      MathUtils.mulDiv(batch.normalizedAmountPaid, status.scaledAmount, batch.scaledTotalAmount)
    );

    uint128 normalizedAmountWithdrawn = newTotalWithdrawn - status.normalizedAmountWithdrawn;

    if (normalizedAmountWithdrawn == 0) revert_NullWithdrawalAmount();

    hooks.onExecuteWithdrawal(accountAddress, normalizedAmountWithdrawn, state, baseCalldataSize);

    status.normalizedAmountWithdrawn = newTotalWithdrawn;
    state.normalizedUnclaimedWithdrawals -= normalizedAmountWithdrawn;

    if (_isSanctioned(accountAddress)) {
      // Get or create an escrow contract for the lender and transfer the owed amount to it.
      // They will be unable to withdraw from the escrow until their sanctioned
      // status is lifted on Chainalysis, or until the borrower overrides it.
      address escrow = _createEscrowForUnderlyingAsset(accountAddress);
      asset.safeTransfer(escrow, normalizedAmountWithdrawn);

      // Emit `SanctionedAccountWithdrawalSentToEscrow` event using a custom emitter.
      emit_SanctionedAccountWithdrawalSentToEscrow(
        accountAddress,
        escrow,
        expiry,
        normalizedAmountWithdrawn
      );
    } else {
      asset.safeTransfer(accountAddress, normalizedAmountWithdrawn);
    }

    emit_WithdrawalExecuted(expiry, accountAddress, normalizedAmountWithdrawn);

    return normalizedAmountWithdrawn;
  }

  function repayAndProcessUnpaidWithdrawalBatches(
    uint256 repayAmount,
    uint256 maxBatches
  ) public nonReentrant sphereXGuardExternal {
    // Repay before updating state to ensure the paid amount is counted towards
    // any pending or unpaid withdrawals.
    if (repayAmount > 0) {
      asset.safeTransferFrom(msg.sender, address(this), repayAmount);
      emit_DebtRepaid(msg.sender, repayAmount);
    }

    MarketState memory state = _getUpdatedState();
    if (state.isClosed) revert_RepayToClosedMarket();

    // Use an obfuscated constant for the base calldata size to prevent solc
    // function specialization.
    if (repayAmount > 0) hooks.onRepay(repayAmount, state, _runtimeConstant(0x44));

    // Calculate assets available to process the first batch - will be updated after each batch
    uint256 availableLiquidity = totalAssets() -
      (state.normalizedUnclaimedWithdrawals + state.accruedProtocolFees);

    // Get the maximum number of batches to process
    uint256 numBatches = MathUtils.min(maxBatches, _withdrawalData.unpaidBatches.length());

    uint256 i;
    // Process up to `maxBatches` unpaid batches while there is available liquidity
    while (i++ < numBatches && availableLiquidity > 0) {
      // Process the next unpaid batch using available liquidity
      uint256 normalizedAmountPaid = _processUnpaidWithdrawalBatch(state, availableLiquidity);
      // Reduce liquidity available to next batch
      availableLiquidity = availableLiquidity.satSub(normalizedAmountPaid);
    }
    _writeState(state);
  }

  function _processUnpaidWithdrawalBatch(
    MarketState memory state,
    uint256 availableLiquidity
  ) internal returns (uint256 normalizedAmountPaid) {
    // Get the next unpaid batch timestamp from storage (reverts if none)
    uint32 expiry = _withdrawalData.unpaidBatches.first();

    // Cache batch data in memory
    WithdrawalBatch memory batch = _withdrawalData.batches[expiry];

    // Pay up to the available liquidity to the batch
    (, normalizedAmountPaid) = _applyWithdrawalBatchPayment(
      batch,
      state,
      expiry,
      availableLiquidity
    );

    // Update stored batch
    _withdrawalData.batches[expiry] = batch;

    // Remove batch from unpaid set if fully paid
    if (batch.scaledTotalAmount == batch.scaledAmountBurned) {
      _withdrawalData.unpaidBatches.shift();
      emit_WithdrawalBatchClosed(expiry);
    }
  }
}
// SPDX-License-Identifier: UNLICENSED
// (c) SphereX 2023 Terms&Conditions
pragma solidity ^0.8.20;

/// @dev this struct is used to reduce the stack usage of the modifiers.
struct ModifierLocals {
  bytes32[] storageSlots;
  bytes32[] valuesBefore;
  uint256 gas;
  address engine;
}

/// @title Interface for SphereXEngine - definitions of core functionality
/// @author SphereX Technologies ltd
/// @notice This interface is imported by SphereXProtected, so that SphereXProtected can call functions from SphereXEngine
/// @dev Full docs of these functions can be found in SphereXEngine
interface ISphereXEngine {
  function sphereXValidatePre(
    int256 num,
    address sender,
    bytes calldata data
  ) external returns (bytes32[] memory);

  function sphereXValidatePost(
    int256 num,
    uint256 gas,
    bytes32[] calldata valuesBefore,
    bytes32[] calldata valuesAfter
  ) external;

  function sphereXValidateInternalPre(int256 num) external returns (bytes32[] memory);

  function sphereXValidateInternalPost(
    int256 num,
    uint256 gas,
    bytes32[] calldata valuesBefore,
    bytes32[] calldata valuesAfter
  ) external;

  function addAllowedSenderOnChain(address sender) external;

  /// This function is taken as is from OZ IERC165, we don't inherit from OZ
  /// to avoid collisions with the customer OZ version.
  /// @dev Returns true if this contract implements the interface defined by
  /// `interfaceId`. See the corresponding
  /// https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
  /// to learn more about how these ids are created.
  /// This function call must use less than 30 000 gas.
  function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

function revert_SphereXOperatorRequired() pure {
  assembly {
    mstore(0, 0x4ee0b8f8)
    revert(0x1c, 0x04)
  }
}

function revert_SphereXAdminRequired() pure {
  assembly {
    mstore(0, 0x6222a550)
    revert(0x1c, 0x04)
  }
}

function revert_SphereXOperatorOrAdminRequired() pure {
  assembly {
    mstore(0, 0xb2dbeb59)
    revert(0x1c, 0x04)
  }
}

function revert_SphereXNotPendingAdmin() pure {
  assembly {
    mstore(0, 0x4d28a58e)
    revert(0x1c, 0x04)
  }
}

function revert_SphereXNotEngine() pure {
  assembly {
    mstore(0, 0x7dcb7ada)
    revert(0x1c, 0x04)
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

function emit_ChangedSpherexOperator(address oldSphereXAdmin, address newSphereXAdmin) {
  assembly {
    mstore(0, oldSphereXAdmin)
    mstore(0x20, newSphereXAdmin)
    log1(0, 0x40, 0x2ac55ae7ba47db34b5334622acafeb34a65daf143b47019273185d64c73a35a5)
  }
}

function emit_ChangedSpherexEngineAddress(address oldEngineAddress, address newEngineAddress) {
  assembly {
    mstore(0, oldEngineAddress)
    mstore(0x20, newEngineAddress)
    log1(0, 0x40, 0xf33499cccaa0611882086224cc48cd82ef54b66a4d2edf4ed67108dd516896d5)
  }
}

function emit_SpherexAdminTransferStarted(address currentAdmin, address pendingAdmin) {
  assembly {
    mstore(0, currentAdmin)
    mstore(0x20, pendingAdmin)
    log1(0, 0x40, 0x5778f1547abbbb86090a43c32aec38334b31df4beeb6f8f3fa063f593b53a526)
  }
}

function emit_SpherexAdminTransferCompleted(address oldAdmin, address newAdmin) {
  assembly {
    mstore(0, oldAdmin)
    mstore(0x20, newAdmin)
    log1(0, 0x40, 0x67ebaebcd2ca5a91a404e898110f221747e8d15567f2388a34794aab151cf3e6)
  }
}

function emit_NewAllowedSenderOnchain(address sender) {
  assembly {
    mstore(0, sender)
    log1(0, 0x20, 0x6de0a1fd3a59e5479e6480ba65ef28d4f3ab8143c2c631bbfd9969ab39074797)
  }
}
// SPDX-License-Identifier: UNLICENSED
// (c) SphereX 2023 Terms&Conditions
pragma solidity ^0.8.20;

import { ISphereXEngine, ModifierLocals } from './ISphereXEngine.sol';
import './SphereXProtectedEvents.sol';
import './SphereXProtectedErrors.sol';

/**
 * @title Modified version of SphereXProtectedBase for contracts registered
 *        on Wildcat's arch controller.
 *
 * @author Modified from https://github.com/spherex-xyz/spherex-protect-contracts/blob/main/src/SphereXProtectedBase.sol
 *
 * @dev In this version, the WildcatArchController deployment is the SphereX operator.
 *      There is no admin because the arch controller address can not be modified.
 *
 *      All admin functions/events/errors have been removed to reduce contract size.
 *
 *      SphereX engine address validation is delegated to the arch controller.
 */
abstract contract SphereXProtectedRegisteredBase {
  // ========================================================================== //
  //                                  Constants                                 //
  // ========================================================================== //

  /// @dev Storage slot with the address of the SphereX engine contract.
  bytes32 private constant SPHEREX_ENGINE_STORAGE_SLOT =
    bytes32(uint256(keccak256('eip1967.spherex.spherex_engine')) - 1);

  /**
   * @dev Address of the WildcatArchController deployment.
   *      The arch controller is able to set the SphereX engine address.
   *      The inheriting contract must assign this in the constructor.
   */
  address internal immutable _archController;

  // ========================================================================== //
  //                                 Initializer                                //
  // ========================================================================== //

  /**
   * @dev Initializes the SphereXEngine and emits events for the initial
   *      engine and operator (arch controller).
   */
  function __SphereXProtectedRegisteredBase_init(address engine) internal virtual {
    emit_ChangedSpherexOperator(address(0), _archController);
    _setAddress(SPHEREX_ENGINE_STORAGE_SLOT, engine);
    emit_ChangedSpherexEngineAddress(address(0), engine);
  }

  // ========================================================================== //
  //                              Events and Errors                             //
  // ========================================================================== //

  error SphereXOperatorRequired();

  event ChangedSpherexOperator(address oldSphereXAdmin, address newSphereXAdmin);
  event ChangedSpherexEngineAddress(address oldEngineAddress, address newEngineAddress);

  // ========================================================================== //
  //                               Local Modifiers                              //
  // ========================================================================== //

  modifier spherexOnlyOperator() {
    if (msg.sender != _archController) {
      revert_SphereXOperatorRequired();
    }
    _;
  }

  modifier returnsIfNotActivatedPre(ModifierLocals memory locals) {
    locals.engine = sphereXEngine();
    if (locals.engine == address(0)) {
      return;
    }

    _;
  }

  modifier returnsIfNotActivatedPost(ModifierLocals memory locals) {
    if (locals.engine == address(0)) {
      return;
    }

    _;
  }

  // ========================================================================== //
  //                                 Management                                 //
  // ========================================================================== //

  /// @dev Returns the current operator address.
  function sphereXOperator() public view returns (address) {
    return _archController;
  }

  /// @dev Returns the current engine address.
  function sphereXEngine() public view returns (address) {
    return _getAddress(SPHEREX_ENGINE_STORAGE_SLOT);
  }

  /**
   * @dev  Change the address of the SphereX engine.
   *
   *       This is also used to enable SphereX protection, which is disabled
   *       when the engine address is 0.
   *
   * Note: The new engine is not validated as it would be in `SphereXProtectedBase`
   *       because the operator is the arch controller, which validates the engine
   *       address prior to updating it here.
   */
  function changeSphereXEngine(address newSphereXEngine) external spherexOnlyOperator {
    address oldEngine = _getAddress(SPHEREX_ENGINE_STORAGE_SLOT);
    _setAddress(SPHEREX_ENGINE_STORAGE_SLOT, newSphereXEngine);
    emit_ChangedSpherexEngineAddress(oldEngine, newSphereXEngine);
  }

  // ========================================================================== //
  //                                    Hooks                                   //
  // ========================================================================== //

  /**
   * @dev Wrapper for `_getStorageSlotsAndPreparePostCalldata` that returns
   *      a `uint256` pointer to `locals` rather than the struct itself.
   *
   *      Declaring a return parameter for a struct will always zero and
   *      allocate memory for every field in the struct. If the parameter
   *      is always reassigned, the gas and memory used on this are wasted.
   *
   *      Using a `uint256` pointer instead of a struct declaration avoids
   *      this waste while being functionally identical.
   */
  function _sphereXValidateExternalPre() internal returns (uint256 localsPointer) {
    return _castFunctionToPointerOutput(_getStorageSlotsAndPreparePostCalldata)(_getSelector());
  }

  /**
   * @dev Internal function for engine communication. We use it to reduce contract size.
   *      Should be called before the code of an external function.
   *
   *      Queries `storageSlots` from `sphereXValidatePre` on the engine and writes
   *      the result to `locals.storageSlots`, then caches the current storage values
   *      for those slots in `locals.valuesBefore`.
   *
   *      Also allocates memory for the calldata of the future call to `sphereXValidatePost`
   *      and initializes every value in the calldata except for `gas` and `valuesAfter` data.
   *
   * @param num function identifier
   */
  function _getStorageSlotsAndPreparePostCalldata(
    int256 num
  ) internal returnsIfNotActivatedPre(locals) returns (ModifierLocals memory locals) {
    assembly {
      // Read engine from `locals.engine` - this is filled by `returnsIfNotActivatedPre`
      let engineAddress := mload(add(locals, 0x60))

      // Get free memory pointer - this will be used for the calldata
      // to `sphereXValidatePre` and then reused for both `storageSlots`
      // and the future calldata to `sphereXValidatePost`
      let pointer := mload(0x40)

      // Call `sphereXValidatePre(num, msg.sender, msg.data)`
      mstore(pointer, 0x8925ca5a)
      mstore(add(pointer, 0x20), num)
      mstore(add(pointer, 0x40), caller())
      mstore(add(pointer, 0x60), 0x60)
      mstore(add(pointer, 0x80), calldatasize())
      calldatacopy(add(pointer, 0xa0), 0, calldatasize())
      let size := add(0xc4, calldatasize())

      if iszero(
        and(eq(mload(0), 0x20), call(gas(), engineAddress, 0, add(pointer, 28), size, 0, 0x40))
      ) {
        returndatacopy(0, 0, returndatasize())
        revert(0, returndatasize())
      }
      let length := mload(0x20)

      // Set up the memory after the allocation `locals` struct as:
      // [0x00:0x20]: `storageSlots.length`
      // [0x20:0x20+(length * 0x20)]: `storageSlots` data
      // [0x20+(length*0x20):]: calldata for `sphereXValidatePost`

      // The layout for the `sphereXValidatePost` calldata is:
      // [0x00:0x20]: num
      // [0x20:0x40]: gas
      // [0x40:0x60]: valuesBefore offset (0x80)
      // [0x60:0x80]: valuesAfter offset (0xa0 + (0x20 * length))
      // [0x80:0xa0]: valuesBefore length (0xa0 + (0x20 * length))
      // [0xa0:0xa0+(0x20*length)]: valuesBefore data
      // [0xa0+(0x20*length):0xc0+(0x20*length)] valuesAfter length
      // [0xc0+(0x20*length):0xc0+(0x40*length)]: valuesAfter data
      //
      // size of calldata: 0xc0 + (0x40 * length)
      //
      // size of allocation: 0xe0 + (0x60 * length)

      // Calculate size of array data (excluding length): 32 * length
      let arrayDataSize := shl(5, length)

      // Finalize memory allocation with space for `storageSlots` and
      // the calldata for `sphereXValidatePost`.
      mstore(0x40, add(pointer, add(0xe0, mul(arrayDataSize, 3))))

      // Copy `storageSlots` from returndata to the start of the allocated
      // memory buffer and write the pointer to `locals.storageSlots`
      returndatacopy(pointer, 0x20, add(arrayDataSize, 0x20))
      mstore(locals, pointer)

      // Get pointer to future calldata.
      // Add `32 + arrayDataSize` to skip the allocation for `locals.storageSlots`
      // @todo *could* put `valuesBefore` before `storageSlots` and reuse
      // the `storageSlots` buffer for `valuesAfter`
      let calldataPointer := add(pointer, add(arrayDataSize, 0x20))

      // Write `-num` to calldata
      mstore(calldataPointer, sub(0, num))

      // Write `valuesBefore` offset to calldata
      mstore(add(calldataPointer, 0x40), 0x80)

      // Write `locals.valuesBefore` pointer
      mstore(add(locals, 0x20), add(calldataPointer, 0x80))

      // Write `valuesAfter` offset to calldata
      mstore(add(calldataPointer, 0x60), add(0xa0, arrayDataSize))

      // Write `gasleft()` to `locals.gas`
      mstore(add(locals, 0x40), gas())
    }
    _readStorageTo(locals.storageSlots, locals.valuesBefore);
  }

  /**
   * @dev Wrapper for `_callSphereXValidatePost` that takes a pointer
   *      instead of a struct.
   */
  function _sphereXValidateExternalPost(uint256 locals) internal {
    _castFunctionToPointerInput(_callSphereXValidatePost)(locals);
  }

  function _callSphereXValidatePost(
    ModifierLocals memory locals
  ) internal returnsIfNotActivatedPost(locals) {
    uint256 length;
    bytes32[] memory storageSlots;
    bytes32[] memory valuesAfter;
    assembly {
      storageSlots := mload(locals)
      length := mload(storageSlots)
      valuesAfter := add(storageSlots, add(0xc0, shl(6, length)))
    }
    _readStorageTo(storageSlots, valuesAfter);
    assembly {
      let sphereXEngineAddress := mload(add(locals, 0x60))
      let arrayDataSize := shl(5, length)
      let calldataSize := add(0xc4, shl(1, arrayDataSize))

      let calldataPointer := add(storageSlots, add(arrayDataSize, 0x20))
      let gasDiff := sub(mload(add(locals, 0x40)), gas())
      mstore(add(calldataPointer, 0x20), gasDiff)
      let slotBefore := sub(calldataPointer, 32)
      let slotBeforeCache := mload(slotBefore)
      mstore(slotBefore, 0xf0bd9468)
      if iszero(call(gas(), sphereXEngineAddress, 0, add(slotBefore, 28), calldataSize, 0, 0)) {
        returndatacopy(0, 0, returndatasize())
        revert(0, returndatasize())
      }
      mstore(slotBefore, slotBeforeCache)
    }
  }

  /// @dev Returns the function selector from the current calldata.
  function _getSelector() internal pure returns (int256 selector) {
    assembly {
      selector := shr(224, calldataload(0))
    }
  }

  /// @dev Modifier to be incorporated in all external protected non-view functions
  modifier sphereXGuardExternal() {
    uint256 localsPointer = _sphereXValidateExternalPre();
    _;
    _sphereXValidateExternalPost(localsPointer);
  }

  // ========================================================================== //
  //                          Internal Storage Helpers                          //
  // ========================================================================== //

  /// @dev Stores an address in an arbitrary slot
  function _setAddress(bytes32 slot, address newAddress) internal {
    assembly {
      sstore(slot, newAddress)
    }
  }

  /// @dev Returns an address from an arbitrary slot.
  function _getAddress(bytes32 slot) internal view returns (address addr) {
    assembly {
      addr := sload(slot)
    }
  }

  /**
   * @dev Internal function that reads values from given storage slots
   *      and writes them to a particular memory location.
   *
   * @param storageSlots array of storage slots to read
   * @param values array of values to write values to
   */
  function _readStorageTo(bytes32[] memory storageSlots, bytes32[] memory values) internal view {
    assembly {
      let length := mload(storageSlots)
      let arrayDataSize := shl(5, length)
      mstore(values, length)
      let nextSlotPointer := add(storageSlots, 0x20)
      let nextElementPointer := add(values, 0x20)
      let endPointer := add(nextElementPointer, shl(5, length))
      for {

      } lt(nextElementPointer, endPointer) {

      } {
        mstore(nextElementPointer, sload(mload(nextSlotPointer)))
        nextElementPointer := add(nextElementPointer, 0x20)
        nextSlotPointer := add(nextSlotPointer, 0x20)
      }
    }
  }

  // ========================================================================== //
  //                             Function Type Casts                            //
  // ========================================================================== //

  function _castFunctionToPointerInput(
    function(ModifierLocals memory) internal fnIn
  ) internal pure returns (function(uint256) internal fnOut) {
    assembly {
      fnOut := fnIn
    }
  }

  function _castFunctionToPointerOutput(
    function(int256) internal returns (ModifierLocals memory) fnIn
  ) internal pure returns (function(int256) internal returns (uint256) fnOut) {
    assembly {
      fnOut := fnIn
    }
  }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.20;

import '../access/IHooks.sol';
import '../libraries/MarketState.sol';

type HooksConfig is uint256;

HooksConfig constant EmptyHooksConfig = HooksConfig.wrap(0);

using LibHooksConfig for HooksConfig global;
using LibHooksConfig for HooksDeploymentConfig global;

// Type that contains only the flags for a specific hooks contract, with one
// set of flags for optional hooks and one set of flags for required hooks.
type HooksDeploymentConfig is uint256;

function encodeHooksDeploymentConfig(
  HooksConfig optionalFlags,
  HooksConfig requiredFlags
) pure returns (HooksDeploymentConfig flags) {
  assembly {
    let cleanedOptionalFlags := and(0xffff, shr(0x50, optionalFlags))
    let cleanedRequiredFlags := and(0xffff0000, shr(0x40, requiredFlags))
    flags := or(cleanedOptionalFlags, cleanedRequiredFlags)
  }
}

// --------------------- Bits after hook activation flag -------------------- //

// Offsets are from the right

uint256 constant Bit_Enabled_Deposit = 95;
uint256 constant Bit_Enabled_QueueWithdrawal = 94;
uint256 constant Bit_Enabled_ExecuteWithdrawal = 93;
uint256 constant Bit_Enabled_Transfer = 92;
uint256 constant Bit_Enabled_Borrow = 91;
uint256 constant Bit_Enabled_Repay = 90;
uint256 constant Bit_Enabled_CloseMarket = 89;
uint256 constant Bit_Enabled_NukeFromOrbit = 88;
uint256 constant Bit_Enabled_SetMaxTotalSupply = 87;
uint256 constant Bit_Enabled_SetAnnualInterestAndReserveRatioBips = 86;
uint256 constant Bit_Enabled_SetProtocolFeeBips = 85;

uint256 constant MarketStateSize = 0x01c0;

function encodeHooksConfig(
  address hooksAddress,
  bool useOnDeposit,
  bool useOnQueueWithdrawal,
  bool useOnExecuteWithdrawal,
  bool useOnTransfer,
  bool useOnBorrow,
  bool useOnRepay,
  bool useOnCloseMarket,
  bool useOnNukeFromOrbit,
  bool useOnSetMaxTotalSupply,
  bool useOnSetAnnualInterestAndReserveRatioBips,
  bool useOnSetProtocolFeeBips
) pure returns (HooksConfig hooks) {
  assembly {
    hooks := shl(96, hooksAddress)
    hooks := or(hooks, shl(Bit_Enabled_Deposit, useOnDeposit))
    hooks := or(hooks, shl(Bit_Enabled_QueueWithdrawal, useOnQueueWithdrawal))
    hooks := or(hooks, shl(Bit_Enabled_ExecuteWithdrawal, useOnExecuteWithdrawal))
    hooks := or(hooks, shl(Bit_Enabled_Transfer, useOnTransfer))
    hooks := or(hooks, shl(Bit_Enabled_Borrow, useOnBorrow))
    hooks := or(hooks, shl(Bit_Enabled_Repay, useOnRepay))
    hooks := or(hooks, shl(Bit_Enabled_CloseMarket, useOnCloseMarket))
    hooks := or(hooks, shl(Bit_Enabled_NukeFromOrbit, useOnNukeFromOrbit))
    hooks := or(hooks, shl(Bit_Enabled_SetMaxTotalSupply, useOnSetMaxTotalSupply))
    hooks := or(
      hooks,
      shl(
        Bit_Enabled_SetAnnualInterestAndReserveRatioBips,
        useOnSetAnnualInterestAndReserveRatioBips
      )
    )
    hooks := or(hooks, shl(Bit_Enabled_SetProtocolFeeBips, useOnSetProtocolFeeBips))
  }
}

library LibHooksConfig {
  function setHooksAddress(
    HooksConfig hooks,
    address _hooksAddress
  ) internal pure returns (HooksConfig updatedHooks) {
    assembly {
      // Shift twice to clear the address
      updatedHooks := shr(160, shl(160, hooks))
      // Set the new address
      updatedHooks := or(updatedHooks, shl(96, _hooksAddress))
    }
  }

  /**
   * @dev Create a merged HooksConfig with the shared flags of `a` and `b`
   *      and the address of `a`.
   */
  function mergeSharedFlags(
    HooksConfig a,
    HooksConfig b
  ) internal pure returns (HooksConfig merged) {
    assembly {
      let addressA := shl(0x60, shr(0x60, a))
      let flagsA := shl(0xa0, a)
      let flagsB := shl(0xa0, b)
      let mergedFlags := shr(0xa0, and(flagsA, flagsB))
      merged := or(addressA, mergedFlags)
    }
  }

  /**
   * @dev Create a merged HooksConfig with the shared flags of `a` and `b`
   *      and the address of `a`.
   */
  function mergeAllFlags(HooksConfig a, HooksConfig b) internal pure returns (HooksConfig merged) {
    assembly {
      let addressA := shl(0x60, shr(0x60, a))
      let flagsA := shl(0xa0, a)
      let flagsB := shl(0xa0, b)
      let mergedFlags := shr(0xa0, or(flagsA, flagsB))
      merged := or(addressA, mergedFlags)
    }
  }

  function mergeFlags(
    HooksConfig config,
    HooksDeploymentConfig flags
  ) internal pure returns (HooksConfig merged) {
    assembly {
      let _hooksAddress := shl(96, shr(96, config))
      // Position flags at the end of the word
      let configFlags := shr(0x50, config)
      // Optional flags are already in the right position, required flags must be
      // shifted to align with the other flags. The leading and trailing bits for all 3
      // words will be masked out at the end
      let _optionalFlags := flags
      let _requiredFlags := shr(0x10, flags)
      let mergedFlags := and(0xffff, or(and(configFlags, _optionalFlags), _requiredFlags))

      merged := or(_hooksAddress, shl(0x50, mergedFlags))
    }
  }

  function optionalFlags(HooksDeploymentConfig flags) internal pure returns (HooksConfig config) {
    assembly {
      config := shl(0x50, and(flags, 0xffff))
    }
  }

  function requiredFlags(HooksDeploymentConfig flags) internal pure returns (HooksConfig config) {
    assembly {
      config := shl(0x40, and(flags, 0xffff0000))
    }
  }

  // ========================================================================== //
  //                              Parameter Readers                             //
  // ========================================================================== //

  function readFlag(HooksConfig hooks, uint256 bitsAfter) internal pure returns (bool flagged) {
    assembly {
      flagged := and(shr(bitsAfter, hooks), 1)
    }
  }

  function setFlag(
    HooksConfig hooks,
    uint256 bitsAfter
  ) internal pure returns (HooksConfig updatedHooks) {
    assembly {
      updatedHooks := or(hooks, shl(bitsAfter, 1))
    }
  }

  function clearFlag(
    HooksConfig hooks,
    uint256 bitsAfter
  ) internal pure returns (HooksConfig updatedHooks) {
    assembly {
      updatedHooks := and(hooks, not(shl(bitsAfter, 1)))
    }
  }

  /// @dev Address of the hooks contract
  function hooksAddress(HooksConfig hooks) internal pure returns (address _hooks) {
    assembly {
      _hooks := shr(96, hooks)
    }
  }

  /// @dev Whether to call hook contract for deposit
  function useOnDeposit(HooksConfig hooks) internal pure returns (bool) {
    return hooks.readFlag(Bit_Enabled_Deposit);
  }

  /// @dev Whether to call hook contract for queueWithdrawal
  function useOnQueueWithdrawal(HooksConfig hooks) internal pure returns (bool) {
    return hooks.readFlag(Bit_Enabled_QueueWithdrawal);
  }

  /// @dev Whether to call hook contract for executeWithdrawal
  function useOnExecuteWithdrawal(HooksConfig hooks) internal pure returns (bool) {
    return hooks.readFlag(Bit_Enabled_ExecuteWithdrawal);
  }

  /// @dev Whether to call hook contract for transfer
  function useOnTransfer(HooksConfig hooks) internal pure returns (bool) {
    return hooks.readFlag(Bit_Enabled_Transfer);
  }

  /// @dev Whether to call hook contract for borrow
  function useOnBorrow(HooksConfig hooks) internal pure returns (bool) {
    return hooks.readFlag(Bit_Enabled_Borrow);
  }

  /// @dev Whether to call hook contract for repay
  function useOnRepay(HooksConfig hooks) internal pure returns (bool) {
    return hooks.readFlag(Bit_Enabled_Repay);
  }

  /// @dev Whether to call hook contract for closeMarket
  function useOnCloseMarket(HooksConfig hooks) internal pure returns (bool) {
    return hooks.readFlag(Bit_Enabled_CloseMarket);
  }

  /// @dev Whether to call hook contract when account sanctioned
  function useOnNukeFromOrbit(HooksConfig hooks) internal pure returns (bool) {
    return hooks.readFlag(Bit_Enabled_NukeFromOrbit);
  }

  /// @dev Whether to call hook contract for setMaxTotalSupply
  function useOnSetMaxTotalSupply(HooksConfig hooks) internal pure returns (bool) {
    return hooks.readFlag(Bit_Enabled_SetMaxTotalSupply);
  }

  /// @dev Whether to call hook contract for setAnnualInterestAndReserveRatioBips
  function useOnSetAnnualInterestAndReserveRatioBips(
    HooksConfig hooks
  ) internal pure returns (bool) {
    return hooks.readFlag(Bit_Enabled_SetAnnualInterestAndReserveRatioBips);
  }

  /// @dev Whether to call hook contract for setProtocolFeeBips
  function useOnSetProtocolFeeBips(HooksConfig hooks) internal pure returns (bool) {
    return hooks.readFlag(Bit_Enabled_SetProtocolFeeBips);
  }

  // ========================================================================== //
  //                              Hook for deposit                              //
  // ========================================================================== //

  uint256 internal constant DepositCalldataSize = 0x24;
  // Size of lender + scaledAmount + state + extraData.offset + extraData.length
  uint256 internal constant DepositHook_Base_Size = 0x0244;
  uint256 internal constant DepositHook_ScaledAmount_Offset = 0x20;
  uint256 internal constant DepositHook_State_Offset = 0x40;
  uint256 internal constant DepositHook_ExtraData_Head_Offset = 0x200;
  uint256 internal constant DepositHook_ExtraData_Length_Offset = 0x0220;
  uint256 internal constant DepositHook_ExtraData_TailOffset = 0x0240;

  function onDeposit(
    HooksConfig self,
    address lender,
    uint256 scaledAmount,
    MarketState memory state
  ) internal {
    address target = self.hooksAddress();
    uint32 onDepositSelector = uint32(IHooks.onDeposit.selector);
    if (self.useOnDeposit()) {
      assembly {
        let extraCalldataBytes := sub(calldatasize(), DepositCalldataSize)
        let cdPointer := mload(0x40)
        let headPointer := add(cdPointer, 0x20)
        // Write selector for `onDeposit`
        mstore(cdPointer, onDepositSelector)
        // Write `lender` to hook calldata
        mstore(headPointer, lender)
        // Write `scaledAmount` to hook calldata
        mstore(add(headPointer, DepositHook_ScaledAmount_Offset), scaledAmount)
        // Copy market state to hook calldata
        mcopy(add(headPointer, DepositHook_State_Offset), state, MarketStateSize)
        // Write bytes offset for `extraData`
        mstore(
          add(headPointer, DepositHook_ExtraData_Head_Offset),
          DepositHook_ExtraData_Length_Offset
        )
        // Write length for `extraData`
        mstore(add(headPointer, DepositHook_ExtraData_Length_Offset), extraCalldataBytes)
        // Copy `extraData` from end of calldata to hook calldata
        calldatacopy(
          add(headPointer, DepositHook_ExtraData_TailOffset),
          DepositCalldataSize,
          extraCalldataBytes
        )

        let size := add(DepositHook_Base_Size, extraCalldataBytes)

        if iszero(call(gas(), target, 0, add(cdPointer, 0x1c), size, 0, 0)) {
          returndatacopy(0, 0, returndatasize())
          revert(0, returndatasize())
        }
      }
    }
  }

  // ========================================================================== //
  //                          Hook for queueWithdrawal                          //
  // ========================================================================== //

  // Size of lender + scaledAmount + state + extraData.offset + extraData.length
  uint256 internal constant QueueWithdrawalHook_Base_Size = 0x0264;
  uint256 internal constant QueueWithdrawalHook_Expiry_Offset = 0x20;
  uint256 internal constant QueueWithdrawalHook_ScaledAmount_Offset = 0x40;
  uint256 internal constant QueueWithdrawalHook_State_Offset = 0x60;
  uint256 internal constant QueueWithdrawalHook_ExtraData_Head_Offset = 0x220;
  uint256 internal constant QueueWithdrawalHook_ExtraData_Length_Offset = 0x0240;
  uint256 internal constant QueueWithdrawalHook_ExtraData_TailOffset = 0x0260;

  function onQueueWithdrawal(
    HooksConfig self,
    address lender,
    uint32 expiry,
    uint256 scaledAmount,
    MarketState memory state,
    uint256 baseCalldataSize
  ) internal {
    address target = self.hooksAddress();
    uint32 onQueueWithdrawalSelector = uint32(IHooks.onQueueWithdrawal.selector);
    if (self.useOnQueueWithdrawal()) {
      assembly {
        let extraCalldataBytes := sub(calldatasize(), baseCalldataSize)
        let cdPointer := mload(0x40)
        let headPointer := add(cdPointer, 0x20)
        // Write selector for `onQueueWithdrawal`
        mstore(cdPointer, onQueueWithdrawalSelector)
        // Write `lender` to hook calldata
        mstore(headPointer, lender)
        // Write `expiry` to hook calldata
        mstore(add(headPointer, QueueWithdrawalHook_Expiry_Offset), expiry)
        // Write `scaledAmount` to hook calldata
        mstore(add(headPointer, QueueWithdrawalHook_ScaledAmount_Offset), scaledAmount)
        // Copy market state to hook calldata
        mcopy(add(headPointer, QueueWithdrawalHook_State_Offset), state, MarketStateSize)
        // Write bytes offset for `extraData`
        mstore(
          add(headPointer, QueueWithdrawalHook_ExtraData_Head_Offset),
          QueueWithdrawalHook_ExtraData_Length_Offset
        )
        // Write length for `extraData`
        mstore(add(headPointer, QueueWithdrawalHook_ExtraData_Length_Offset), extraCalldataBytes)
        // Copy `extraData` from end of calldata to hook calldata
        calldatacopy(
          add(headPointer, QueueWithdrawalHook_ExtraData_TailOffset),
          baseCalldataSize,
          extraCalldataBytes
        )

        let size := add(QueueWithdrawalHook_Base_Size, extraCalldataBytes)

        if iszero(call(gas(), target, 0, add(cdPointer, 0x1c), size, 0, 0)) {
          returndatacopy(0, 0, returndatasize())
          revert(0, returndatasize())
        }
      }
    }
  }

  // ========================================================================== //
  //                         Hook for executeWithdrawal                         //
  // ========================================================================== //

  // Size of lender + scaledAmount + state + extraData.offset + extraData.length
  uint256 internal constant ExecuteWithdrawalHook_Base_Size = 0x0244;
  uint256 internal constant ExecuteWithdrawalHook_ScaledAmount_Offset = 0x20;
  uint256 internal constant ExecuteWithdrawalHook_State_Offset = 0x40;
  uint256 internal constant ExecuteWithdrawalHook_ExtraData_Head_Offset = 0x0200;
  uint256 internal constant ExecuteWithdrawalHook_ExtraData_Length_Offset = 0x0220;
  uint256 internal constant ExecuteWithdrawalHook_ExtraData_TailOffset = 0x0240;

  function onExecuteWithdrawal(
    HooksConfig self,
    address lender,
    uint256 scaledAmount,
    MarketState memory state,
    uint256 baseCalldataSize
  ) internal {
    address target = self.hooksAddress();
    uint32 onExecuteWithdrawalSelector = uint32(IHooks.onExecuteWithdrawal.selector);
    if (self.useOnExecuteWithdrawal()) {
      assembly {
        let extraCalldataBytes := sub(calldatasize(), baseCalldataSize)
        let cdPointer := mload(0x40)
        let headPointer := add(cdPointer, 0x20)
        // Write selector for `onExecuteWithdrawal`
        mstore(cdPointer, onExecuteWithdrawalSelector)
        // Write `lender` to hook calldata
        mstore(headPointer, lender)
        // Write `scaledAmount` to hook calldata
        mstore(add(headPointer, ExecuteWithdrawalHook_ScaledAmount_Offset), scaledAmount)
        // Copy market state to hook calldata
        mcopy(add(headPointer, ExecuteWithdrawalHook_State_Offset), state, MarketStateSize)
        // Write bytes offset for `extraData`
        mstore(
          add(headPointer, ExecuteWithdrawalHook_ExtraData_Head_Offset),
          ExecuteWithdrawalHook_ExtraData_Length_Offset
        )
        // Write length for `extraData`
        mstore(add(headPointer, ExecuteWithdrawalHook_ExtraData_Length_Offset), extraCalldataBytes)
        // Copy `extraData` from end of calldata to hook calldata
        calldatacopy(
          add(headPointer, ExecuteWithdrawalHook_ExtraData_TailOffset),
          baseCalldataSize,
          extraCalldataBytes
        )

        let size := add(ExecuteWithdrawalHook_Base_Size, extraCalldataBytes)

        if iszero(call(gas(), target, 0, add(cdPointer, 0x1c), size, 0, 0)) {
          returndatacopy(0, 0, returndatasize())
          revert(0, returndatasize())
        }
      }
    }
  }

  // ========================================================================== //
  //                              Hook for transfer                             //
  // ========================================================================== //

  // Size of caller + from + to + scaledAmount + state + extraData.offset + extraData.length
  uint256 internal constant TransferHook_Base_Size = 0x0284;
  uint256 internal constant TransferHook_From_Offset = 0x20;
  uint256 internal constant TransferHook_To_Offset = 0x40;
  uint256 internal constant TransferHook_ScaledAmount_Offset = 0x60;
  uint256 internal constant TransferHook_State_Offset = 0x80;
  uint256 internal constant TransferHook_ExtraData_Head_Offset = 0x240;
  uint256 internal constant TransferHook_ExtraData_Length_Offset = 0x0260;
  uint256 internal constant TransferHook_ExtraData_TailOffset = 0x0280;

  function onTransfer(
    HooksConfig self,
    address from,
    address to,
    uint256 scaledAmount,
    MarketState memory state,
    uint256 baseCalldataSize
  ) internal {
    address target = self.hooksAddress();
    uint32 onTransferSelector = uint32(IHooks.onTransfer.selector);
    if (self.useOnTransfer()) {
      assembly {
        let extraCalldataBytes := sub(calldatasize(), baseCalldataSize)
        let cdPointer := mload(0x40)
        let headPointer := add(cdPointer, 0x20)
        // Write selector for `onTransfer`
        mstore(cdPointer, onTransferSelector)
        // Write `caller` to hook calldata
        mstore(headPointer, caller())
        // Write `from` to hook calldata
        mstore(add(headPointer, TransferHook_From_Offset), from)
        // Write `to` to hook calldata
        mstore(add(headPointer, TransferHook_To_Offset), to)
        // Write `scaledAmount` to hook calldata
        mstore(add(headPointer, TransferHook_ScaledAmount_Offset), scaledAmount)
        // Copy market state to hook calldata
        mcopy(add(headPointer, TransferHook_State_Offset), state, MarketStateSize)
        // Write bytes offset for `extraData`
        mstore(
          add(headPointer, TransferHook_ExtraData_Head_Offset),
          TransferHook_ExtraData_Length_Offset
        )
        // Write length for `extraData`
        mstore(add(headPointer, TransferHook_ExtraData_Length_Offset), extraCalldataBytes)
        // Copy `extraData` from end of calldata to hook calldata
        calldatacopy(
          add(headPointer, TransferHook_ExtraData_TailOffset),
          baseCalldataSize,
          extraCalldataBytes
        )

        let size := add(TransferHook_Base_Size, extraCalldataBytes)

        if iszero(call(gas(), target, 0, add(cdPointer, 0x1c), size, 0, 0)) {
          returndatacopy(0, 0, returndatasize())
          revert(0, returndatasize())
        }
      }
    }
  }

  // ========================================================================== //
  //                               Hook for borrow                              //
  // ========================================================================== //

  uint256 internal constant BorrowCalldataSize = 0x24;
  // Size of normalizedAmount + state + extraData.offset + extraData.length
  uint256 internal constant BorrowHook_Base_Size = 0x0224;
  uint256 internal constant BorrowHook_State_Offset = 0x20;
  uint256 internal constant BorrowHook_ExtraData_Head_Offset = 0x01e0;
  uint256 internal constant BorrowHook_ExtraData_Length_Offset = 0x0200;
  uint256 internal constant BorrowHook_ExtraData_TailOffset = 0x0220;

  function onBorrow(HooksConfig self, uint256 normalizedAmount, MarketState memory state) internal {
    address target = self.hooksAddress();
    uint32 onBorrowSelector = uint32(IHooks.onBorrow.selector);
    if (self.useOnBorrow()) {
      assembly {
        let extraCalldataBytes := sub(calldatasize(), BorrowCalldataSize)
        let ptr := mload(0x40)
        let headPointer := add(ptr, 0x20)

        mstore(ptr, onBorrowSelector)
        // Copy `normalizedAmount` to hook calldata
        mstore(headPointer, normalizedAmount)
        // Copy market state to hook calldata
        mcopy(add(headPointer, BorrowHook_State_Offset), state, MarketStateSize)
        // Write bytes offset for `extraData`
        mstore(
          add(headPointer, BorrowHook_ExtraData_Head_Offset),
          BorrowHook_ExtraData_Length_Offset
        )
        // Write length for `extraData`
        mstore(add(headPointer, BorrowHook_ExtraData_Length_Offset), extraCalldataBytes)
        // Copy `extraData` from end of calldata to hook calldata
        calldatacopy(
          add(headPointer, BorrowHook_ExtraData_TailOffset),
          BorrowCalldataSize,
          extraCalldataBytes
        )

        let size := add(RepayHook_Base_Size, extraCalldataBytes)
        if iszero(call(gas(), target, 0, add(ptr, 0x1c), size, 0, 0)) {
          returndatacopy(0, 0, returndatasize())
          revert(0, returndatasize())
        }
      }
    }
  }

  // ========================================================================== //
  //                               Hook for repay                               //
  // ========================================================================== //

  // Size of normalizedAmount + state + extraData.offset + extraData.length
  uint256 internal constant RepayHook_Base_Size = 0x0224;
  uint256 internal constant RepayHook_State_Offset = 0x20;
  uint256 internal constant RepayHook_ExtraData_Head_Offset = 0x01e0;
  uint256 internal constant RepayHook_ExtraData_Length_Offset = 0x0200;
  uint256 internal constant RepayHook_ExtraData_TailOffset = 0x0220;

  function onRepay(
    HooksConfig self,
    uint256 normalizedAmount,
    MarketState memory state,
    uint256 baseCalldataSize
  ) internal {
    address target = self.hooksAddress();
    uint32 onRepaySelector = uint32(IHooks.onRepay.selector);
    if (self.useOnRepay()) {
      assembly {
        let extraCalldataBytes := sub(calldatasize(), baseCalldataSize)
        let ptr := mload(0x40)
        let headPointer := add(ptr, 0x20)

        mstore(ptr, onRepaySelector)
        // Copy `normalizedAmount` to hook calldata
        mstore(headPointer, normalizedAmount)
        // Copy market state to hook calldata
        mcopy(add(headPointer, RepayHook_State_Offset), state, MarketStateSize)
        // Write bytes offset for `extraData`
        mstore(add(headPointer, RepayHook_ExtraData_Head_Offset), RepayHook_ExtraData_Length_Offset)
        // Write length for `extraData`
        mstore(add(headPointer, RepayHook_ExtraData_Length_Offset), extraCalldataBytes)
        // Copy `extraData` from end of calldata to hook calldata
        calldatacopy(
          add(headPointer, RepayHook_ExtraData_TailOffset),
          baseCalldataSize,
          extraCalldataBytes
        )

        let size := add(RepayHook_Base_Size, extraCalldataBytes)
        if iszero(call(gas(), target, 0, add(ptr, 0x1c), size, 0, 0)) {
          returndatacopy(0, 0, returndatasize())
          revert(0, returndatasize())
        }
      }
    }
  }

  // ========================================================================== //
  //                            Hook for closeMarket                            //
  // ========================================================================== //

  // Size of calldata to `market.closeMarket`
  uint256 internal constant CloseMarketCalldataSize = 0x04;

  // Base size of calldata for `hooks.onCloseMarket()`
  uint256 internal constant CloseMarketHook_Base_Size = 0x0204;
  uint256 internal constant CloseMarketHook_ExtraData_Head_Offset = MarketStateSize;
  uint256 internal constant CloseMarketHook_ExtraData_Length_Offset = 0x01e0;
  uint256 internal constant CloseMarketHook_ExtraData_TailOffset = 0x0200;

  function onCloseMarket(HooksConfig self, MarketState memory state) internal {
    address target = self.hooksAddress();
    uint32 onCloseMarketSelector = uint32(IHooks.onCloseMarket.selector);
    if (self.useOnCloseMarket()) {
      assembly {
        let extraCalldataBytes := sub(calldatasize(), CloseMarketCalldataSize)
        let cdPointer := mload(0x40)
        let headPointer := add(cdPointer, 0x20)
        // Write selector for `onCloseMarket`
        mstore(cdPointer, onCloseMarketSelector)
        // Copy market state to hook calldata
        mcopy(headPointer, state, MarketStateSize)
        // Write bytes offset for `extraData`
        mstore(
          add(headPointer, CloseMarketHook_ExtraData_Head_Offset),
          CloseMarketHook_ExtraData_Length_Offset
        )
        // Write length for `extraData`
        mstore(add(headPointer, CloseMarketHook_ExtraData_Length_Offset), extraCalldataBytes)
        // Copy `extraData` from end of calldata to hook calldata
        calldatacopy(
          add(headPointer, CloseMarketHook_ExtraData_TailOffset),
          CloseMarketCalldataSize,
          extraCalldataBytes
        )

        let size := add(CloseMarketHook_Base_Size, extraCalldataBytes)

        if iszero(call(gas(), target, 0, add(cdPointer, 0x1c), size, 0, 0)) {
          returndatacopy(0, 0, returndatasize())
          revert(0, returndatasize())
        }
      }
    }
  }

  // ========================================================================== //
  //                         Hook for setMaxTotalSupply                         //
  // ========================================================================== //

  uint256 internal constant SetMaxTotalSupplyCalldataSize = 0x24;
  // Size of maxTotalSupply + state + extraData.offset + extraData.length
  uint256 internal constant SetMaxTotalSupplyHook_Base_Size = 0x0224;
  uint256 internal constant SetMaxTotalSupplyHook_State_Offset = 0x20;
  uint256 internal constant SetMaxTotalSupplyHook_ExtraData_Head_Offset = 0x01e0;
  uint256 internal constant SetMaxTotalSupplyHook_ExtraData_Length_Offset = 0x0200;
  uint256 internal constant SetMaxTotalSupplyHook_ExtraData_TailOffset = 0x0220;

  function onSetMaxTotalSupply(
    HooksConfig self,
    uint256 maxTotalSupply,
    MarketState memory state
  ) internal {
    address target = self.hooksAddress();
    uint32 onSetMaxTotalSupplySelector = uint32(IHooks.onSetMaxTotalSupply.selector);
    if (self.useOnSetMaxTotalSupply()) {
      assembly {
        let extraCalldataBytes := sub(calldatasize(), SetMaxTotalSupplyCalldataSize)
        let cdPointer := mload(0x40)
        let headPointer := add(cdPointer, 0x20)
        // Write selector for `onSetMaxTotalSupply`
        mstore(cdPointer, onSetMaxTotalSupplySelector)
        // Write `maxTotalSupply` to hook calldata
        mstore(headPointer, maxTotalSupply)
        // Copy market state to hook calldata
        mcopy(add(headPointer, SetMaxTotalSupplyHook_State_Offset), state, MarketStateSize)
        // Write bytes offset for `extraData`
        mstore(
          add(headPointer, SetMaxTotalSupplyHook_ExtraData_Head_Offset),
          SetMaxTotalSupplyHook_ExtraData_Length_Offset
        )
        // Write length for `extraData`
        mstore(add(headPointer, SetMaxTotalSupplyHook_ExtraData_Length_Offset), extraCalldataBytes)
        // Copy `extraData` from end of calldata to hook calldata
        calldatacopy(
          add(headPointer, SetMaxTotalSupplyHook_ExtraData_TailOffset),
          SetMaxTotalSupplyCalldataSize,
          extraCalldataBytes
        )

        let size := add(SetMaxTotalSupplyHook_Base_Size, extraCalldataBytes)

        if iszero(call(gas(), target, 0, add(cdPointer, 0x1c), size, 0, 0)) {
          returndatacopy(0, 0, returndatasize())
          revert(0, returndatasize())
        }
      }
    }
  }

  // ========================================================================== //
  //                       Hook for setAnnualInterestBips                       //
  // ========================================================================== //

  uint256 internal constant SetAnnualInterestAndReserveRatioBipsCalldataSize = 0x44;
  // Size of annualInterestBips + state + extraData.offset + extraData.length
  uint256 internal constant SetAnnualInterestAndReserveRatioBipsHook_Base_Size = 0x0244;
  uint256 internal constant SetAnnualInterestAndReserveRatioBipsHook_ReserveRatioBits_Offset = 0x20;
  uint256 internal constant SetAnnualInterestAndReserveRatioBipsHook_State_Offset = 0x40;
  uint256 internal constant SetAnnualInterestAndReserveRatioBipsHook_ExtraData_Head_Offset = 0x0200;
  uint256 internal constant SetAnnualInterestAndReserveRatioBipsHook_ExtraData_Length_Offset =
    0x0220;
  uint256 internal constant SetAnnualInterestAndReserveRatioBipsHook_ExtraData_TailOffset = 0x0240;

  function onSetAnnualInterestAndReserveRatioBips(
    HooksConfig self,
    uint16 annualInterestBips,
    uint16 reserveRatioBips,
    MarketState memory state
  ) internal returns (uint16 newAnnualInterestBips, uint16 newReserveRatioBips) {
    address target = self.hooksAddress();
    uint32 onSetAnnualInterestBipsSelector = uint32(
      IHooks.onSetAnnualInterestAndReserveRatioBips.selector
    );
    if (self.useOnSetAnnualInterestAndReserveRatioBips()) {
      assembly {
        let extraCalldataBytes := sub(
          calldatasize(),
          SetAnnualInterestAndReserveRatioBipsCalldataSize
        )
        let cdPointer := mload(0x40)
        let headPointer := add(cdPointer, 0x20)
        // Write selector for `onSetAnnualInterestBips`
        mstore(cdPointer, onSetAnnualInterestBipsSelector)
        // Write `annualInterestBips` to hook calldata
        mstore(headPointer, annualInterestBips)
        // Write `reserveRatioBips` to hook calldata
        mstore(
          add(headPointer, SetAnnualInterestAndReserveRatioBipsHook_ReserveRatioBits_Offset),
          reserveRatioBips
        )
        // Copy market state to hook calldata
        mcopy(
          add(headPointer, SetAnnualInterestAndReserveRatioBipsHook_State_Offset),
          state,
          MarketStateSize
        )
        // Write bytes offset for `extraData`
        mstore(
          add(headPointer, SetAnnualInterestAndReserveRatioBipsHook_ExtraData_Head_Offset),
          SetAnnualInterestAndReserveRatioBipsHook_ExtraData_Length_Offset
        )
        // Write length for `extraData`
        mstore(
          add(headPointer, SetAnnualInterestAndReserveRatioBipsHook_ExtraData_Length_Offset),
          extraCalldataBytes
        )
        // Copy `extraData` from end of calldata to hook calldata
        calldatacopy(
          add(headPointer, SetAnnualInterestAndReserveRatioBipsHook_ExtraData_TailOffset),
          SetAnnualInterestAndReserveRatioBipsCalldataSize,
          extraCalldataBytes
        )

        let size := add(SetAnnualInterestAndReserveRatioBipsHook_Base_Size, extraCalldataBytes)

        // Returndata is expected to have the new values for `annualInterestBips` and `reserveRatioBips`
        if or(
          lt(returndatasize(), 0x40),
          iszero(call(gas(), target, 0, add(cdPointer, 0x1c), size, 0, 0x40))
        ) {
          returndatacopy(0, 0, returndatasize())
          revert(0, returndatasize())
        }

        newAnnualInterestBips := and(mload(0), 0xffff)
        newReserveRatioBips := and(mload(0x20), 0xffff)
      }
    } else {
      (newAnnualInterestBips, newReserveRatioBips) = (annualInterestBips, reserveRatioBips);
    }
  }

  // ========================================================================== //
  //                     Hook for protocol fee bips updated                     //
  // ========================================================================== //

  uint256 internal constant SetProtocolFeeBipsCalldataSize = 0x24;
  // Size of protocolFeeBips + state + extraData.offset + extraData.length
  uint256 internal constant SetProtocolFeeBips_Base_Size = 0x0224;
  uint256 internal constant SetProtocolFeeBips_State_Offset = 0x20;
  uint256 internal constant SetProtocolFeeBips_ExtraData_Head_Offset = 0x01e0;
  uint256 internal constant SetProtocolFeeBips_ExtraData_Length_Offset = 0x0200;
  uint256 internal constant SetProtocolFeeBips_ExtraData_TailOffset = 0x0220;

  function onSetProtocolFeeBips(
    HooksConfig self,
    uint protocolFeeBips,
    MarketState memory state
  ) internal {
    address target = self.hooksAddress();
    uint32 onSetProtocolFeeBipsSelector = uint32(IHooks.onSetProtocolFeeBips.selector);
    if (self.useOnSetProtocolFeeBips()) {
      assembly {
        let extraCalldataBytes := sub(calldatasize(), SetProtocolFeeBipsCalldataSize)
        let cdPointer := mload(0x40)
        let headPointer := add(cdPointer, 0x20)
        // Write selector for `onSetProtocolFeeBips`
        mstore(cdPointer, onSetProtocolFeeBipsSelector)
        // Write `protocolFeeBips` to hook calldata
        mstore(headPointer, protocolFeeBips)
        // Copy market state to hook calldata
        mcopy(add(headPointer, SetProtocolFeeBips_State_Offset), state, MarketStateSize)
        // Write bytes offset for `extraData`
        mstore(
          add(headPointer, SetProtocolFeeBips_ExtraData_Head_Offset),
          SetProtocolFeeBips_ExtraData_Length_Offset
        )
        // Write length for `extraData`
        mstore(add(headPointer, SetProtocolFeeBips_ExtraData_Length_Offset), extraCalldataBytes)
        // Copy `extraData` from end of calldata to hook calldata
        calldatacopy(
          add(headPointer, SetProtocolFeeBips_ExtraData_TailOffset),
          SetProtocolFeeBipsCalldataSize,
          extraCalldataBytes
        )

        let size := add(SetProtocolFeeBips_Base_Size, extraCalldataBytes)

        if iszero(call(gas(), target, 0, add(cdPointer, 0x1c), size, 0, 0)) {
          returndatacopy(0, 0, returndatasize())
          revert(0, returndatasize())
        }
      }
    }
  }

  // ========================================================================== //
  //                       Hook for assets sent to escrow                       //
  // ========================================================================== //

  uint256 internal constant NukeFromOrbitCalldataSize = 0x24;
  // Size of lender + state + extraData.offset + extraData.length
  uint256 internal constant NukeFromOrbit_Base_Size = 0x0224;
  uint256 internal constant NukeFromOrbit_State_Offset = 0x20;
  uint256 internal constant NukeFromOrbit_ExtraData_Head_Offset = 0x01e0;
  uint256 internal constant NukeFromOrbit_ExtraData_Length_Offset = 0x0200;
  uint256 internal constant NukeFromOrbit_ExtraData_TailOffset = 0x0220;

  function onNukeFromOrbit(HooksConfig self, address lender, MarketState memory state) internal {
    address target = self.hooksAddress();
    uint32 onNukeFromOrbitSelector = uint32(IHooks.onNukeFromOrbit.selector);
    if (self.useOnNukeFromOrbit()) {
      assembly {
        let extraCalldataBytes := sub(calldatasize(), NukeFromOrbitCalldataSize)
        let cdPointer := mload(0x40)
        let headPointer := add(cdPointer, 0x20)
        // Write selector for `onNukeFromOrbit`
        mstore(cdPointer, onNukeFromOrbitSelector)
        // Write `lender` to hook calldata
        mstore(headPointer, lender)
        // Copy market state to hook calldata
        mcopy(add(headPointer, NukeFromOrbit_State_Offset), state, MarketStateSize)
        // Write bytes offset for `extraData`
        mstore(
          add(headPointer, NukeFromOrbit_ExtraData_Head_Offset),
          NukeFromOrbit_ExtraData_Length_Offset
        )
        // Write length for `extraData`
        mstore(add(headPointer, NukeFromOrbit_ExtraData_Length_Offset), extraCalldataBytes)
        // Copy `extraData` from end of calldata to hook calldata
        calldatacopy(
          add(headPointer, NukeFromOrbit_ExtraData_TailOffset),
          NukeFromOrbitCalldataSize,
          extraCalldataBytes
        )

        let size := add(NukeFromOrbit_Base_Size, extraCalldataBytes)

        if iszero(call(gas(), target, 0, add(cdPointer, 0x1c), size, 0, 0)) {
          returndatacopy(0, 0, returndatasize())
          revert(0, returndatasize())
        }
      }
    }
  }
}