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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
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
pragma solidity >=0.8.0;

/// @notice Library for converting between addresses and bytes32 values.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/utils/Bytes32AddressLib.sol)
library Bytes32AddressLib {
    function fromLast20Bytes(bytes32 bytesValue) internal pure returns (address) {
        return address(uint160(uint256(bytesValue)));
    }

    function fillLast12Bytes(address addressValue) internal pure returns (bytes32) {
        return bytes32(bytes20(addressValue));
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Bytes32AddressLib} from "./Bytes32AddressLib.sol";

/// @notice Deploy to deterministic addresses without an initcode factor.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/utils/CREATE3.sol)
/// @author Modified from 0xSequence (https://github.com/0xSequence/create3/blob/master/contracts/Create3.sol)
library CREATE3 {
    using Bytes32AddressLib for bytes32;

    //--------------------------------------------------------------------------------//
    // Opcode     | Opcode + Arguments    | Description      | Stack View             //
    //--------------------------------------------------------------------------------//
    // 0x36       |  0x36                 | CALLDATASIZE     | size                   //
    // 0x3d       |  0x3d                 | RETURNDATASIZE   | 0 size                 //
    // 0x3d       |  0x3d                 | RETURNDATASIZE   | 0 0 size               //
    // 0x37       |  0x37                 | CALLDATACOPY     |                        //
    // 0x36       |  0x36                 | CALLDATASIZE     | size                   //
    // 0x3d       |  0x3d                 | RETURNDATASIZE   | 0 size                 //
    // 0x34       |  0x34                 | CALLVALUE        | value 0 size           //
    // 0xf0       |  0xf0                 | CREATE           | newContract            //
    //--------------------------------------------------------------------------------//
    // Opcode     | Opcode + Arguments    | Description      | Stack View             //
    //--------------------------------------------------------------------------------//
    // 0x67       |  0x67XXXXXXXXXXXXXXXX | PUSH8 bytecode   | bytecode               //
    // 0x3d       |  0x3d                 | RETURNDATASIZE   | 0 bytecode             //
    // 0x52       |  0x52                 | MSTORE           |                        //
    // 0x60       |  0x6008               | PUSH1 08         | 8                      //
    // 0x60       |  0x6018               | PUSH1 18         | 24 8                   //
    // 0xf3       |  0xf3                 | RETURN           |                        //
    //--------------------------------------------------------------------------------//
    bytes internal constant PROXY_BYTECODE = hex"67_36_3d_3d_37_36_3d_34_f0_3d_52_60_08_60_18_f3";

    bytes32 internal constant PROXY_BYTECODE_HASH = keccak256(PROXY_BYTECODE);

    function deploy(
        bytes32 salt,
        bytes memory creationCode,
        uint256 value
    ) internal returns (address deployed) {
        bytes memory proxyChildBytecode = PROXY_BYTECODE;

        address proxy;
        assembly {
            // Deploy a new contract with our pre-made bytecode via CREATE2.
            // We start 32 bytes into the code to avoid copying the byte length.
            proxy := create2(0, add(proxyChildBytecode, 32), mload(proxyChildBytecode), salt)
        }
        require(proxy != address(0), "DEPLOYMENT_FAILED");

        deployed = getDeployed(salt);
        (bool success, ) = proxy.call{value: value}(creationCode);
        require(success && deployed.code.length != 0, "INITIALIZATION_FAILED");
    }

    function getDeployed(bytes32 salt) internal view returns (address) {
        address proxy = keccak256(
            abi.encodePacked(
                // Prefix:
                bytes1(0xFF),
                // Creator:
                address(this),
                // Salt:
                salt,
                // Bytecode hash:
                PROXY_BYTECODE_HASH
            )
        ).fromLast20Bytes();

        return
            keccak256(
                abi.encodePacked(
                    // 0xd6 = 0xc0 (short RLP prefix) + 0x16 (length of: 0x94 ++ proxy ++ 0x01)
                    // 0x94 = 0x80 + 0x14 (0x14 = the length of an address, 20 bytes, in hex)
                    hex"d6_94",
                    proxy,
                    hex"01" // Nonce of the proxy contract (1)
                )
            ).fromLast20Bytes();
    }
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.19;

import "./TokenTimelock.sol";

/// Modified from: https://github.com/fei-protocol/fei-protocol-core/blob/develop/contracts/timelocks/LinearTokenTimelock.sol
/// @author Fei Protocol
contract LinearTokenTimelock is TokenTimelock {
  constructor(
    address _beneficiary,
    uint256 _duration,
    address _lockedToken,
    uint256 _cliffDuration,
    address _clawbackAdmin,
    uint256 _startTime
  ) TokenTimelock(_beneficiary, _duration, _cliffDuration, _lockedToken, _clawbackAdmin) {
    if (_startTime != 0) {
      startTime = _startTime;
    }
  }

  function _proportionAvailable(
    uint256 initialBalance,
    uint256 elapsed,
    uint256 duration
  ) internal pure override returns (uint256) {
    return (initialBalance * elapsed) / duration;
  }
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.19;

/// @title an abstract contract for timed events
/// @author Fei Protocol
/// @dev Modified from: https://github.com/fei-protocol/fei-protocol-core/blob/develop/contracts/utils/Timed.sol
abstract contract Timed {
  /// @notice the start timestamp of the timed period
  uint256 public startTime;

  /// @notice the duration of the timed period
  uint256 public duration;

  event DurationUpdate(uint256 oldDuration, uint256 newDuration);

  event TimerReset(uint256 startTime);

  constructor(uint256 _duration) {
    _setDuration(_duration);
  }

  modifier duringTime() {
    require(isTimeStarted(), "Timed: time not started");
    require(!isTimeEnded(), "Timed: time ended");
    _;
  }

  modifier afterTime() {
    require(isTimeEnded(), "Timed: time not ended");
    _;
  }

  /// @notice return true if time period has ended
  function isTimeEnded() public view returns (bool) {
    return remainingTime() == 0;
  }

  /// @notice number of seconds remaining until time is up
  /// @return remaining
  function remainingTime() public view returns (uint256) {
    return duration - timeSinceStart(); // duration always >= timeSinceStart which is on [0,d]
  }

  /// @notice number of seconds since contract was initialized
  /// @return timestamp
  /// @dev will be less than or equal to duration
  function timeSinceStart() public view returns (uint256) {
    if (!isTimeStarted()) {
      return 0; // uninitialized
    }
    uint256 _duration = duration;
    uint256 timePassed = block.timestamp - startTime; // block timestamp always >= startTime
    return timePassed > _duration ? _duration : timePassed;
  }

  function isTimeStarted() public view returns (bool) {
    return startTime < block.timestamp;
  }

  function _initTimed() internal {
    startTime = block.timestamp;

    emit TimerReset(block.timestamp);
  }

  function _setDuration(uint256 newDuration) internal {
    require(newDuration != 0, "Timed: zero duration");

    uint256 oldDuration = duration;
    duration = newDuration;
    emit DurationUpdate(oldDuration, newDuration);
  }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {CREATE3} from "lib/solmate/src/utils/CREATE3.sol";

import {TimelockedDelegator} from "./TimelockedDelegator.sol";

contract TimelockFactory {
  // ============ events ============
  event TimelockDeployed(
    address indexed timelock,
    address indexed token,
    address indexed beneficiary,
    address admin,
    uint256 cliffDuration,
    uint256 startTime,
    uint256 duration
  );

  // ============ public functions ============

  /**
   * @notice Deploys a LineatTokenTimelock with create3.
   * 
   * @dev Salt generated from token, beneficiary, amount, and deployer.
   * @dev Funding is optional. If funding is provided, the timelock will be funded with the funding amount.
   * 
   * @param _token Token to unlock
   * @param _beneficiary Unlocking address
   * @param _admin Clawback admin
   * @param _cliffDuration Duration of cliff in seconds
   * @param _startTime Unlock start time in seconds
   * @param _duration Duration of the unlock schedule in seconds
   * @param _amount The amount to unlock
   * @param _funding The initial funding amount
   */
  function deployTimelock(
    address _token,
    address _beneficiary,
    address _admin,
    uint256 _cliffDuration,
    uint256 _startTime,
    uint256 _duration,
    uint256 _amount,
    uint256 _funding
  ) public returns (address _deployed) {
    _deployed = _deployTimelock(_token, _beneficiary, _admin, _cliffDuration, _startTime, _duration, _amount);

    if (_funding > 0) {
      // fund timelock
      IERC20(_token).transferFrom(msg.sender, _deployed, _funding);
    }
  }

  /**
   * @notice Computes the address of a timelock contract.
   * 
   * @param _deployer The address that will deploy the contract
   * @param _token The token to unlock
   * @param _beneficiary The address that will claim unlocks
   * @param _startTime The start time
   * @param _amount The amount to unlock
   */
  function computeTimelockAddress(
    address _deployer,
    address _token,
    address _beneficiary,
    uint256 _startTime,
    uint256 _amount
  ) public view returns (address _computed) {
    // Get salt
    bytes32 salt = _getSalt(_token, _beneficiary, _deployer, _startTime, _amount);

    // Deploy timelock
    _computed = CREATE3.getDeployed(salt);
  }

  // ============ internal functions ============
  function _deployTimelock(
    address _token,
    address _beneficiary,
    address _admin,
    uint256 _cliffDuration,
    uint256 _startTime,
    uint256 _duration,
    uint256 _amount
  ) internal returns (address _deployed) {
    // Get salt
    bytes32 salt = _getSalt(_token, _beneficiary, msg.sender, _startTime, _amount);

    // Get bytecode
    bytes memory creation = type(TimelockedDelegator).creationCode;
    bytes memory bytecode = abi.encodePacked(
      creation,
      abi.encode(_token, _beneficiary, _admin, _cliffDuration, _startTime, _duration)
    );

    // Deploy timelock
    _deployed = CREATE3.deploy(salt, bytecode, 0);
    emit TimelockDeployed(_deployed, _token, _beneficiary, _admin, _cliffDuration, _startTime, _duration);
  }

  function _getSalt(
    address _token,
    address _beneficiary,
    address _deployer,
    uint256 _startTime,
    uint256 _amount
  ) internal pure returns (bytes32 _salt) {
    _salt = keccak256(abi.encodePacked(_token, _beneficiary, _deployer, _startTime, _amount));
  }

}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.19;

import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {ITimelockedDelegator, IDelegatable} from "./interface/ITimelockedDelegator.sol";
import {LinearTokenTimelock} from "./LinearTokenTimelock.sol";

/// @title a proxy delegate contract for token
/// @author Fei Protocol, modified by Connext. Fei reference:
///         https://github.com/fei-protocol/fei-protocol-core/blob/develop/contracts/timelocks/LinearTimelockedDelegator.sol
/// @dev https://eips.ethereum.org/EIPS/eip-4758 -> inclusion seems likely within
///      the next 4 years, so selfdestruct was removed from withdraw()
/// @dev
contract Delegatee is Ownable {
  IDelegatable public token;

  /// @notice Delegatee constructor
  /// @param _delegatee the address to delegate token to
  /// @param _token the delegatable token address
  constructor(address _delegatee, address _token) {
    token = IDelegatable(_token);
    token.delegate(_delegatee);
  }

  /// @notice send token back to timelock
  function withdraw() public onlyOwner {
    IDelegatable _token = token;
    uint256 balance = _token.balanceOf(address(this));
    _token.transfer(owner(), balance);
  }
}

/// @title a timelock for token allowing for sub-delegation
/// @author Fei Protocol
/// @notice allows the timelocked token to be delegated by the beneficiary while locked
contract TimelockedDelegator is ITimelockedDelegator, LinearTokenTimelock {
  /// @notice associated delegate proxy contract for a delegatee
  mapping(address => address) public override delegateContract;

  /// @notice associated delegated amount of token for a delegatee
  /// @dev Using as source of truth to prevent accounting errors by transferring to Delegate contracts
  mapping(address => uint256) public override delegateAmount;

  /// @notice the token contract
  IDelegatable public override token;

  /// @notice the total delegated amount of token
  uint256 public override totalDelegated;

  /// @notice Delegatee constructor
  /// @param _token the token address
  /// @param _beneficiary default delegate, admin, and timelock beneficiary
  /// @param _clawbackAdmin who can withdraw unclaimed tokens if timelock halted. use address(0) if there
  ///        shouldn't be clawbacks for this contract
  /// @param _cliffDuration cliff of unlock, in seconds. Use 0 for no cliff.
  /// @param _startTime start time of unlock period, in seconds. Use 0 for now.
  /// @param _duration duration of the token timelock window
  constructor(
    address _token,
    address _beneficiary,
    address _clawbackAdmin,
    uint256 _cliffDuration,
    uint256 _startTime,
    uint256 _duration
  ) LinearTokenTimelock(_beneficiary, _duration, _token, _cliffDuration, _clawbackAdmin, _startTime) {
    token = IDelegatable(_token);
    token.delegate(_beneficiary);
  }

  /// @notice delegate locked token to a delegatee
  /// @param delegatee the target address to delegate to
  /// @param amount the amount of token to delegate. Will increment existing delegated token
  function delegate(address delegatee, uint256 amount) public override onlyBeneficiary {
    require(amount <= _tokenBalance(), "TimelockedDelegator: Not enough balance");

    // withdraw and include an existing delegation
    if (delegateContract[delegatee] != address(0)) {
      amount = amount + undelegate(delegatee);
    }

    IDelegatable _token = token;
    address _delegateContract = address(new Delegatee(delegatee, address(_token)));
    delegateContract[delegatee] = _delegateContract;

    delegateAmount[delegatee] = amount;
    totalDelegated = totalDelegated + amount;

    _token.transfer(_delegateContract, amount);

    emit Delegate(delegatee, amount);
  }

  /// @notice return delegated token to the timelock
  /// @param delegatee the target address to undelegate from
  /// @return the amount of token returned
  function undelegate(address delegatee) public override onlyBeneficiary returns (uint256) {
    address _delegateContract = delegateContract[delegatee];
    require(_delegateContract != address(0), "TimelockedDelegator: Delegate contract nonexistent");

    Delegatee(_delegateContract).withdraw();

    uint256 amount = delegateAmount[delegatee];
    totalDelegated = totalDelegated - amount;

    delegateContract[delegatee] = address(0);
    delegateAmount[delegatee] = 0;

    emit Undelegate(delegatee, amount);

    return amount;
  }

  /// @notice calculate total token held plus delegated
  /// @dev used by LinearTokenTimelock to determine the released amount
  function totalToken() public view override returns (uint256) {
    return _tokenBalance() + totalDelegated;
  }

  /// @notice accept beneficiary role over timelocked token. Delegates all held (non-subdelegated) token to beneficiary
  function acceptBeneficiary() public override {
    _setBeneficiary(msg.sender);
    token.delegate(msg.sender);
  }

  function _tokenBalance() internal view returns (uint256) {
    return token.balanceOf(address(this));
  }
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.19;

// Modified from: https://github.com/fei-protocol/fei-protocol-core/blob/develop/contracts/timelocks/TokenTimelock.sol

// Inspired by OpenZeppelin TokenTimelock contract
// Reference: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/TokenTimelock.sol

import {Timed} from "./Timed.sol";
import {ITokenTimelock, IERC20} from "./interface/ITokenTimelock.sol";

abstract contract TokenTimelock is ITokenTimelock, Timed {
  /// @notice ERC20 basic token contract being held in timelock
  IERC20 public override lockedToken;

  /// @notice beneficiary of tokens after they are released
  address public override beneficiary;

  /// @notice pending beneficiary appointed by current beneficiary
  address public override pendingBeneficiary;

  /// @notice initial balance of lockedToken
  uint256 public override initialBalance;

  uint256 internal lastBalance;

  /// @notice number of seconds before releasing is allowed
  uint256 public immutable cliffSeconds;

  address public immutable clawbackAdmin;

  constructor(
    address _beneficiary,
    uint256 _duration,
    uint256 _cliffSeconds,
    address _lockedToken,
    address _clawbackAdmin
  ) Timed(_duration) {
    require(_duration != 0, "TokenTimelock: duration is 0");
    require(_beneficiary != address(0), "TokenTimelock: Beneficiary must not be 0 address");

    beneficiary = _beneficiary;
    _initTimed();

    _setLockedToken(_lockedToken);

    cliffSeconds = _cliffSeconds;

    clawbackAdmin = _clawbackAdmin;
  }

  // Prevents incoming LP tokens from messing up calculations
  modifier balanceCheck() {
    if (totalToken() > lastBalance) {
      uint256 delta = totalToken() - lastBalance;
      initialBalance = initialBalance + delta;
    }
    _;
    lastBalance = totalToken();
  }

  modifier onlyBeneficiary() {
    require(msg.sender == beneficiary, "TokenTimelock: Caller is not a beneficiary");
    _;
  }

  /// @notice releases `amount` unlocked tokens to address `to`
  function release(address to, uint256 amount) external override onlyBeneficiary balanceCheck {
    require(amount != 0, "TokenTimelock: no amount desired");
    require(passedCliff(), "TokenTimelock: Cliff not passed");

    uint256 available = availableForRelease();
    require(amount <= available, "TokenTimelock: not enough released tokens");

    _release(to, amount);
  }

  /// @notice releases maximum unlocked tokens to address `to`
  function releaseMax(address to) external override onlyBeneficiary balanceCheck {
    require(passedCliff(), "TokenTimelock: Cliff not passed");
    _release(to, availableForRelease());
  }

  /// @notice the total amount of tokens held by timelock
  function totalToken() public view virtual override returns (uint256) {
    return lockedToken.balanceOf(address(this));
  }

  /// @notice amount of tokens released to beneficiary
  function alreadyReleasedAmount() public view override returns (uint256) {
    return initialBalance == 0 ? 0 : initialBalance - totalToken();
  }

  /// @notice amount of held tokens unlocked and available for release
  function availableForRelease() public view override returns (uint256) {
    uint256 elapsed = timeSinceStart();

    uint256 totalAvailable = _proportionAvailable(initialBalance, elapsed, duration);
    uint256 netAvailable = totalAvailable - alreadyReleasedAmount();
    return netAvailable;
  }

  /// @notice current beneficiary can appoint new beneficiary, which must be accepted
  function setPendingBeneficiary(address _pendingBeneficiary) public override onlyBeneficiary {
    pendingBeneficiary = _pendingBeneficiary;
    emit PendingBeneficiaryUpdate(_pendingBeneficiary);
  }

  /// @notice pending beneficiary accepts new beneficiary
  function acceptBeneficiary() public virtual override {
    _setBeneficiary(msg.sender);
  }

  function clawback() public balanceCheck {
    require(msg.sender == clawbackAdmin, "TokenTimelock: Only clawbackAdmin");
    if (passedCliff()) {
      _release(beneficiary, availableForRelease());
    }
    _release(clawbackAdmin, totalToken());
  }

  function passedCliff() public view returns (bool) {
    return timeSinceStart() >= cliffSeconds;
  }

  function _proportionAvailable(
    uint256 initialBalance,
    uint256 elapsed,
    uint256 duration
  ) internal pure virtual returns (uint256);

  function _setBeneficiary(address newBeneficiary) internal {
    require(newBeneficiary == pendingBeneficiary, "TokenTimelock: Caller is not pending beneficiary");
    beneficiary = newBeneficiary;
    emit BeneficiaryUpdate(newBeneficiary);
    pendingBeneficiary = address(0);
  }

  function _setLockedToken(address tokenAddress) internal {
    lockedToken = IERC20(tokenAddress);
  }

  function _release(address to, uint256 amount) internal {
    lockedToken.transfer(to, amount);
    emit Release(beneficiary, to, amount);
  }
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.19;

import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

interface IDelegatable is IERC20 {
  function delegate(address delegatee) external;
}

/// @title TimelockedDelegator interface
/// @author Fei Protocol
/// @dev Modified from: https://github.com/fei-protocol/fei-protocol-core/blob/develop/contracts/timelocks/ITimelockedDelegator.sol
interface ITimelockedDelegator {
  // ----------- Events -----------

  event Delegate(address indexed _delegatee, uint256 _amount);

  event Undelegate(address indexed _delegatee, uint256 _amount);

  // ----------- Beneficiary only state changing api -----------

  function delegate(address delegatee, uint256 amount) external;

  function undelegate(address delegatee) external returns (uint256);

  // ----------- Getters -----------

  function delegateContract(address delegatee) external view returns (address);

  function delegateAmount(address delegatee) external view returns (uint256);

  function totalDelegated() external view returns (uint256);

  function token() external view returns (IDelegatable);
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.19;

import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

/// @title TokenTimelock interface
/// @author Fei Protocol
/// @dev Modified from: https://github.com/fei-protocol/fei-protocol-core/blob/develop/contracts/timelocks/ITokenTimelock.sol
interface ITokenTimelock {
  // ----------- Events -----------

  event Release(address indexed _beneficiary, address indexed _recipient, uint256 _amount);
  event BeneficiaryUpdate(address indexed _beneficiary);
  event PendingBeneficiaryUpdate(address indexed _pendingBeneficiary);

  // ----------- State changing api -----------

  function release(address to, uint256 amount) external;

  function releaseMax(address to) external;

  function setPendingBeneficiary(address _pendingBeneficiary) external;

  function acceptBeneficiary() external;

  // ----------- Getters -----------

  function lockedToken() external view returns (IERC20);

  function beneficiary() external view returns (address);

  function pendingBeneficiary() external view returns (address);

  function initialBalance() external view returns (uint256);

  function availableForRelease() external view returns (uint256);

  function totalToken() external view returns (uint256);

  function alreadyReleasedAmount() external view returns (uint256);
}