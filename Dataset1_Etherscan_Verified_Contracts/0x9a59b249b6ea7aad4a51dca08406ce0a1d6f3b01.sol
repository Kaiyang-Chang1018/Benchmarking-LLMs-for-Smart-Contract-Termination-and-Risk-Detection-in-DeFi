// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/AccessControl.sol)

pragma solidity ^0.8.20;

import {IAccessControl} from "./IAccessControl.sol";
import {Context} from "../utils/Context.sol";
import {ERC165} from "../utils/introspection/ERC165.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```solidity
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```solidity
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it. We recommend using {AccessControlDefaultAdminRules}
 * to enforce additional security measures for this role.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address account => bool) hasRole;
        bytes32 adminRole;
    }

    mapping(bytes32 role => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with an {AccessControlUnauthorizedAccount} error including the required role.
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual returns (bool) {
        return _roles[role].hasRole[account];
    }

    /**
     * @dev Reverts with an {AccessControlUnauthorizedAccount} error if `_msgSender()`
     * is missing `role`. Overriding this function changes the behavior of the {onlyRole} modifier.
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Reverts with an {AccessControlUnauthorizedAccount} error if `account`
     * is missing `role`.
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert AccessControlUnauthorizedAccount(account, role);
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleGranted} event.
     */
    function grantRole(bytes32 role, address account) public virtual onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleRevoked} event.
     */
    function revokeRole(bytes32 role, address account) public virtual onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `callerConfirmation`.
     *
     * May emit a {RoleRevoked} event.
     */
    function renounceRole(bytes32 role, address callerConfirmation) public virtual {
        if (callerConfirmation != _msgSender()) {
            revert AccessControlBadConfirmation();
        }

        _revokeRole(role, callerConfirmation);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Attempts to grant `role` to `account` and returns a boolean indicating if `role` was granted.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleGranted} event.
     */
    function _grantRole(bytes32 role, address account) internal virtual returns (bool) {
        if (!hasRole(role, account)) {
            _roles[role].hasRole[account] = true;
            emit RoleGranted(role, account, _msgSender());
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Attempts to revoke `role` to `account` and returns a boolean indicating if `role` was revoked.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual returns (bool) {
        if (hasRole(role, account)) {
            _roles[role].hasRole[account] = false;
            emit RoleRevoked(role, account, _msgSender());
            return true;
        } else {
            return false;
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/IAccessControl.sol)

pragma solidity ^0.8.20;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev The `account` is missing a role.
     */
    error AccessControlUnauthorizedAccount(address account, bytes32 neededRole);

    /**
     * @dev The caller of a function is not the expected one.
     *
     * NOTE: Don't confuse with {AccessControlUnauthorizedAccount}.
     */
    error AccessControlBadConfirmation();

    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `callerConfirmation`.
     */
    function renounceRole(bytes32 role, address callerConfirmation) external;
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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/introspection/ERC165.sol)

pragma solidity ^0.8.20;

import {IERC165} from "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/introspection/IERC165.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.27;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {IStateOracle} from "./interfaces/IStateOracle.sol";
import {IUpdateVerifier} from "./interfaces/IUpdateVerifier.sol";
import {IProvingContract} from "./interfaces/IProvingContract.sol";
import {IActivityMonitor} from "./interfaces/IActivityMonitor.sol";

/// Update manager controls updating the bridge contracts, especially the state oracle.
/// A state update needs to be verified by the update verifier, which checks validators signatures.
/// @custom:security-contact security@fantom.foundation
contract UpdateManager is AccessControl {

    IStateOracle public immutable stateOracle;
    IUpdateVerifier public updateVerifier;
    IProvingContract public immutable provingContract;
    IActivityMonitor public activityMonitor;
    uint256 public heartbeat; // update period as a number of blocks
    uint256 public fastLanePadding;
    uint256 public fastLaneFee;
    bool public fastLaneInUse;

    bytes32 public constant HEARTBEAT_ROLE = keccak256("HEARTBEAT_ROLE");
    bytes32 public constant MONITOR_SETTER_ROLE = keccak256("MONITOR_SETTER_ROLE");
    bytes32 public constant FEE_SETTER_ROLE = keccak256("FEE_SETTER_ROLE");

    event FastLaneRequest(uint256 blockNum);
    event HeartbeatSet(uint256 heartbeat);
    event FastLanePaddingSet(uint256 padding);
    event FastLaneFeeSet(uint256 fee);
    event ActivityMonitorSet(IActivityMonitor activityMonitor);
    event UpdateVerifierSet(IUpdateVerifier updateVerifier);

    constructor(IStateOracle _stateOracle, IUpdateVerifier _updateVerifier, IProvingContract _provingContract, address admin, uint256 _heartbeat) {
        require(address(_stateOracle) != address(0), "StateOracle not set");
        require(address(_updateVerifier) != address(0), "UpdateVerifier not set");
        require(address(_provingContract) != address(0), "ProvingContract not set");
        require(admin != address(0), "Admin not set");
        require(_heartbeat >= 1, "Heartbeat must be positive");
        stateOracle = _stateOracle;
        updateVerifier = _updateVerifier;
        provingContract = _provingContract;
        heartbeat = _heartbeat;
        _grantRole(DEFAULT_ADMIN_ROLE, admin); // can grant roles
    }

    /// Update the state oracle and related stuff. Requires signatures of the bridge validators.
    function update(uint256 blockNum, bytes32 stateRoot, bytes calldata newValidators, address _proofVerifier, address _updateVerifier, address _exitAdmin, bytes[] calldata signatures) external {
        // verify update validity
        uint256 _chainId = stateOracle.chainId();
        uint256[] memory validators = updateVerifier.verifyUpdate(blockNum, stateRoot, _chainId, newValidators, _proofVerifier, _updateVerifier, _exitAdmin, signatures);

        // update
        stateOracle.update(blockNum, stateRoot);
        if (_proofVerifier != address(0)) {
            provingContract.setProofVerifier(_proofVerifier);
        }
        if (_exitAdmin != address(0)) {
            provingContract.setExitAdministrator(_exitAdmin);
        }
        if (_updateVerifier != address(0)) {
            // must be updated before the setValidators call
            updateVerifier = IUpdateVerifier(_updateVerifier);
            emit UpdateVerifierSet(IUpdateVerifier(_updateVerifier));
        }
        if (newValidators.length != 0) {
            updateVerifier.setValidators(newValidators);
        }
        if (newValidators.length != 0) {
            updateVerifier.setValidators(newValidators);
        }
        if (address(activityMonitor) != address(0)) {
            activityMonitor.markActivity(validators);
        }
        if (fastLaneInUse) {
            fastLaneInUse = false;
            (bool success, ) = msg.sender.call{value: address(this).balance}("");
            require(success, "Failed to transfer update reward");
        }
    }

    /// Request faster state oracle update, new state root should include result of txs done in blockNum of the watched chain.
    /// Request needs to have fastLaneFee value attached to be accepted. It will cover additional oracle update gas fee.
    function payFastLane(uint256 blockNum) external payable {
        require(!fastLaneInUse, "Fast lane busy");
        require(msg.value >= fastLaneFee, "Insufficient fee value");
        uint256 lastStateUpdate = stateOracle.lastBlockNum();
        // get next periodic state update block number (ignore the fast lane updates)
        uint256 nextStateUpdate = lastStateUpdate - (lastStateUpdate % heartbeat) + heartbeat;
        require(blockNum > lastStateUpdate + fastLanePadding, "Block number too low");
        require(blockNum < nextStateUpdate - fastLanePadding, "Block number too high");

        fastLaneInUse = true;
        emit FastLaneRequest(blockNum);
    }

    /// Set period of regular state oracle updates in the number of watched chain blocks.
    function setHeartbeat(uint256 _heartbeat) onlyRole(HEARTBEAT_ROLE) external {
        require(_heartbeat >= 1, "Heartbeat must be positive");
        require(fastLanePadding < _heartbeat, "Heartbeat must be greater than fast lane padding");
        heartbeat = _heartbeat;
        emit HeartbeatSet(_heartbeat);
    }

    /// Set minimal spacing between two consequent state oracle update in the number of watched chain blocks.
    /// This restrict possibility of fast-lane update.
    function setFastLanePadding(uint256 _padding) onlyRole(HEARTBEAT_ROLE) external {
        require(_padding < heartbeat, "Padding must be less than heartbeat");
        fastLanePadding = _padding;
        emit FastLanePaddingSet(_padding);
    }

    /// Set fee for a single usage of fast lane. Should cover gas fees of the oracle update.
    function setFastLaneFee(uint256 _fee) onlyRole(FEE_SETTER_ROLE) external {
        fastLaneFee = _fee;
        emit FastLaneFeeSet(_fee);
    }

    /// Set a contract responsible for validators activity monitoring.
    /// The monitor contract will be notified everytime when a validator contribute to an update.
    function setActivityMonitor(IActivityMonitor _monitor) onlyRole(MONITOR_SETTER_ROLE) external {
        activityMonitor = _monitor;
        emit ActivityMonitorSet(_monitor);
    }

    /// Get chain id of the watched chain
    function chainId() external view returns(uint256) {
        return stateOracle.chainId();
    }

    /// Get last update block number
    function lastBlockNum() external view returns(uint256) {
        return stateOracle.lastBlockNum();
    }

    /// Get proof verifier of the bridge contract
    function proofVerifier() external view returns(address) {
        return provingContract.proofVerifier();
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.27;

/// Activity monitor collects info about the bridge participation by individual validators.
interface IActivityMonitor {

    // mark validators as active (to be called by UpdateVerifier)
    function markActivity(uint256[] calldata validators) external;

    // get validator last activity block height
    function validatorLastActivity(uint256 validatorId) external returns(uint256);

}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.27;

/// Proving contract represents a contract which use the proof verifier.
/// Used for updating the proof verifier address.
interface IProvingContract {
    function proofVerifier() external view returns(address);
    function setProofVerifier(address proofVerifier) external;
    function setExitAdministrator(address exitAdministrator) external;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.27;

/// State oracle provides the hash of a different chain state.
interface IStateOracle {
    function lastState() external view returns (bytes32);
    function lastBlockNum() external view returns (uint256);
    function lastUpdateTime() external view returns (uint256);
    function chainId() external view returns (uint256);

    function update(uint256 blockNum, bytes32 stateRoot) external;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.27;

/// Update verifier provides a way to verify validators signatures on an update.
/// It provides access to the validators registry for the purpose of inter-chain synchronization.
interface IUpdateVerifier {
    struct Validator {
        uint256 id;
        address addr;
        uint256 weight;
    }

    /// Verify the state oracle update signatures
    function verifyUpdate(uint256 blockNum, bytes32 stateRoot, uint256 chainId, bytes calldata newValidators, address proofVerifier, address updateVerifier, address exitAdmin, bytes[] calldata signatures) external view returns (uint256[] memory);

    /// Write into the validators registry - reverts if the registry is readonly.
    function setValidators(bytes calldata newValidators) external;

    /// Get the highest validator id for purpose of iterating
    function lastValidatorId() external view returns(uint256);

    /// Get validator pubkey address by validator id
    function validatorAddress(uint256 index) external view returns(address);

    /// Get validator weight by validator address
    function validatorWeight(address addr) external view returns(uint256);

    /// Get validator id by validator pubkey address
    function validatorId(address addr) external view returns(uint256);

    /// Get weight of all registered validators
    function totalWeight() external view returns(uint256);

    /// Get weight necessary to update the state oracle
    function getQuorum() external view returns (uint256);
}