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
// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

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

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
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
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title ERC20 Library
/// @dev This library provides basic ERC20 token functionality, allowing contracts to handle token transfers, allowances, and approvals efficiently.
/// It leverages Solidity 0.8's built-in overflow checks to prevent integer overflows and underflows.
library ERC20Lib {
    /// @dev Emitted when tokens are transferred from one account (`from`) to another (`to`).
    /// @param from The address from which tokens are transferred.
    /// @param to The address to which tokens are transferred.
    /// @param value The amount of tokens transferred.
    event Transfer(address indexed from, address indexed to, uint256 value);

    /// @dev Emitted when the allowance of a `spender` for an `owner` is set by a call to `approve`.
    /// @param owner The address which owns the funds.
    /// @param spender The address which will spend the funds.
    /// @param value The amount of tokens that are approved.
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /// @notice Transfers tokens from one address to another.
    /// @param _balances The mapping storing the balances of all addresses.
    /// @param from The address from which tokens will be sent.
    /// @param to The address to which tokens will be sent.
    /// @param amount The number of tokens to be transferred.
    /// @return A boolean that indicates whether the operation was successful.
    function transfer(
        mapping(address => uint256) storage _balances,
        address from,
        address to,
        uint256 amount
    ) internal returns (bool) {
        require(from != address(0), "Zero address");
        require(to != address(0), "Zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "IB");

        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);
        return true;
    }

    /// @notice Approves the `spender` to spend `amount` of tokens on behalf of `owner`.
    /// @param _allowances The mapping storing the allowances of all spender-owner pairs.
    /// @param owner The address which owns the funds.
    /// @param spender The address which will spend the funds.
    /// @param amount The number of tokens to be approved for spending.
    /// @return A boolean that indicates whether the operation was successful.
    function approve(
        mapping(address => mapping(address => uint256)) storage _allowances,
        address owner,
        address spender,
        uint256 amount
    ) internal returns (bool) {
        require(owner != address(0), "Zero address");
        require(spender != address(0), "Zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
        return true;
    }

    /// @notice Transfers tokens from one address to another using the allowance mechanism.
    /// @param _balances The mapping storing the balances of all addresses.
    /// @param _allowances The mapping storing the allowances of all spender-owner pairs.
    /// @param spender The address which is approved to spend the tokens.
    /// @param from The address from which tokens will be sent.
    /// @param to The address to which tokens will be sent.
    /// @param amount The number of tokens to be transferred.
    /// @return A boolean that indicates whether the operation was successful.
    function transferFrom(
        mapping(address => uint256) storage _balances,
        mapping(address => mapping(address => uint256)) storage _allowances,
        address spender,
        address from,
        address to,
        uint256 amount
    ) internal returns (bool) {
        require(from != address(0), "Zero address");
        require(to != address(0), "Zero address");

        uint256 currentAllowance = _allowances[from][spender];
        require(currentAllowance >= amount, "IB");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "IB");

        unchecked {
            _allowances[from][spender] = currentAllowance - amount;
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);
        return true;
    }

    /// @notice Increases the allowance of a `spender` for an `owner` by `addedValue`.
    /// @param _allowances The mapping storing the allowances of all spender-owner pairs.
    /// @param owner The address which owns the funds.
    /// @param spender The address which will spend the funds.
    /// @param addedValue The number of tokens to be added to the allowance.
    /// @return A boolean that indicates whether the operation was successful.
    function increaseAllowance(
        mapping(address => mapping(address => uint256)) storage _allowances,
        address owner,
        address spender,
        uint256 addedValue
    ) internal returns (bool) {
        require(owner != address(0), "Zero address");
        require(spender != address(0), "Zero address");

        unchecked {
            _allowances[owner][spender] += addedValue;
        }

        emit Approval(owner, spender, _allowances[owner][spender]);
        return true;
    }

    /// @notice Decreases the allowance of a `spender` for an `owner` by `subtractedValue`.
    /// @param _allowances The mapping storing the allowances of all spender-owner pairs.
    /// @param owner The address which owns the funds.
    /// @param spender The address which will spend the funds.
    /// @param subtractedValue The number of tokens to be subtracted from the allowance.
    /// @return A boolean that indicates whether the operation was successful.
    function decreaseAllowance(
        mapping(address => mapping(address => uint256)) storage _allowances,
        address owner,
        address spender,
        uint256 subtractedValue
    ) internal returns (bool) {
        require(owner != address(0), "Zero address");
        require(spender != address(0), "Zero address");

        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "IB");

        unchecked {
            _allowances[owner][spender] = currentAllowance - subtractedValue;
        }

        emit Approval(owner, spender, _allowances[owner][spender]);
        return true;
    }

    /// @notice Returns the remaining number of tokens that `spender` is allowed to spend on behalf of `owner`.
    /// @param _allowances The mapping storing the allowances of all spender-owner pairs.
    /// @param owner The address which owns the funds.
    /// @param spender The address which will spend the funds.
    /// @return The remaining allowance.
    function allowance(
        mapping(address => mapping(address => uint256)) storage _allowances,
        address owner,
        address spender
    ) internal view returns (uint256) {
        return _allowances[owner][spender];
    }

    /// @notice Sets the allowance of `spender` over the `owner`'s tokens to `amount`.
    /// @param _allowances The mapping storing the allowances of all spender-owner pairs.
    /// @param owner The address which owns the funds.
    /// @param spender The address which will spend the funds.
    /// @param amount The number of tokens to be approved for spending.
    function _approve(
        mapping(address => mapping(address => uint256)) storage _allowances,
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "Zero address");
        require(spender != address(0), "Zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /// @notice Spends `amount` from the allowance of `owner` toward `spender`.
    /// @param _allowances The mapping storing the allowances of all spender-owner pairs.
    /// @param owner The address which owns the funds.
    /// @param spender The address which will spend the funds.
    /// @param amount The number of tokens to be spent from the allowance.
    function _spendAllowance(
        mapping(address => mapping(address => uint256)) storage _allowances,
        address owner,
        address spender,
        uint256 amount
    ) internal {
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= amount, "IA");

        unchecked {
            _allowances[owner][spender] = currentAllowance - amount;
        }
    }
}
// SPDX-License-Identifier: MIT
/*
 *
 * All rights reserved. Property of Mintable PTE LTD.
 *
 */
pragma solidity ^0.8.0;

// Importing necessary contracts and libraries
import "./Initializable.sol";
import "./@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./IERC721A.sol";
import "./@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "./@openzeppelin/contracts/access/AccessControl.sol";
import "./IFactoryPoolDeployer.sol";
import "./ERC20Lib.sol";
import "./IBondingCurve.sol";
import "./iLogicLib.sol";

/**
 * @title ERC721ex
 * @dev This contract manages the issuance, logic, and burning of NFTs and associated community coins.
 *      It integrates with a bonding curve for coin pricing, handles voting mechanisms,
 *      and manages liquidity pools via Uniswap integration.
 *
 * @notice This contract is upgradeable using the Initializable pattern.
 * @notice It leverages OpenZeppelin's AccessControl for role-based permissions and ReentrancyGuard for security.
 */
contract ERC721ex is Initializable, ERC165, ReentrancyGuard, AccessControl {
    // Using ERC20Lib for token-related mappings
    using ERC20Lib for mapping(address => uint256);
    using ERC20Lib for mapping(address => mapping(address => uint256));
    // Custom Errors
    error Unauthorized(); // Replaces CallerIsNotAdmin & CallerIsNotLogicLib
    error InsufficientBalance();
    error TradingInactive(); // Replaces TradingNotLive
    error ExceedsLimit(); // Replaces ExceedsAvailableSupply
    error ProposalActive(); // Replaces ProposalStillActive
    error InvalidAction(); // Replaces InvalidActionType
    error CannotSellClaimedTokens();
    error InvalidAmount();
    error BondingCurveNotReady();
    error InsufficientETHInContract();
    error ErrorAddingLiquidity();

    // State Variables

    /// @notice Interface identifier for ERC721 standard.
    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    /// @notice Interface identifier for ERC165 standard.
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    /// @notice Interface identifier for ERC20 standard.
    bytes4 private constant _INTERFACE_ID_ERC20 = 0x36372b07;

    /// @notice Role identifier for the LogicLib contract.
    bytes32 public constant LogicLibRole = keccak256("LogicLibRole");

    /// @notice Divisor used in reward calculations.
    uint16 private constant DIVISOR = 10000;

    /// @notice Multiplier for ExecuteAction reward.
    uint8 private constant ACTION_EXECUTE_MULTIPLIER = 150;

    /// @notice Multiplier for SubmitVote reward.
    uint8 private constant ACTION_SUBMIT_VOTE_MULTIPLIER = 20;

    /// @notice Multiplier for EndVote reward.
    uint8 private constant ACTION_END_VOTE_MULTIPLIER = 50;

    /// @notice Multiplier for DeployToUniswap reward.
    uint8 private constant ACTION_DEPLOY_UNISWAP_MULTIPLIER = 100;

    /// @notice constant address holding specific tokens, used for voting deposits.
    address constant holderAddress = 0x0000000000000000000000000000000000069420;

    /// @notice Flag indicating if trading is live.
    bool public tradingLive;

    /// @notice Flag indicating if voting is currently live.
    bool public votingLive;

    /// @notice Flag for if Uniswap values are to be changed from voting.
    bool public poolSplitVote;

    /// @notice Flag indicating if claiming is disabled; false means enabled.
    bool public claimingDisabled;

    /// @notice Flag for burning is enabled, false means enabled
    bool public burningDisabled;

    /// @notice Timestamp for closing the pool based on sales.
    uint32 public closingTimer;

    /// @notice Timestamp of when bonding curve was deployed.
    uint32 public deployedTime;

    /// @notice Address of the factory contract deploying liquidity pools.
    address payable public factoryAddress;

    /// @notice Contract responsible for handling voting logic.
    ILogicLib public votingContract;

    /// @notice Factory contract responsible for deploying liquidity pools.
    IERC721exFactory public ERC721exFactory;

    /// @notice ERC721A compliant NFT contract.
    IERC721A public NFTContract;

    /// @notice Contract managing the bonding curve for token pricing.
    IBondingCurveLib public bondingCurveContract;

    /// @notice Name of the ERC20 token.
    string public name;

    /// @notice Symbol of the ERC20 token.
    string public symbol;

    /// @notice Total supply of ERC20 tokens.
    uint256 public totalSupply;

    /// @notice Decimal precision of the ERC20 token.
    uint256 public constant decimals = 6;

    /// @notice Number of tokens left available for minting.
    uint256 public supplyLeft;

    /// @notice Maximum supply of tokens that can be minted.
    uint256 public maxSupplyOfTokens;

    /// @notice Number of tokens sold through the bonding curve.
    uint256 public tokensSold;

    /// @notice Amount to reward for claiming and burning.
    uint256 public claimAndBurnReward;

    /// @notice Mapping of addresses to their ERC20 token balances.
    mapping(address => uint256) private _balances;

    /// @notice Nested mapping for allowances: owner => spender => amount.
    mapping(address => mapping(address => uint256)) private _allowances;

    /// @notice Nested mapping to track tokens deposited for voting: voter => proposalId => amount.
    mapping(address => mapping(uint256 => uint256)) public depositedTokensToVote;

    /// @notice Mapping to track tokens received from claiming NFTs: address => amount.
    mapping(address => uint256) public tokensFromClaimedNFTs;

    /// @notice Mapping to track tokens received from burning NFTs: address => amount.
    mapping(address => uint256) public tokensFromBurnedNFTs;

    /// @notice Mapping to keep track of claimed NFT token IDs.
    mapping(uint256 => bool) public claimedNFTs;

    /// @notice Mapping to keep track of which NFTs have been used for referrals.
    mapping(uint256 => uint256) public referredNFTs;

    // Events

    /// @notice Emitted when tokens are transferred from one address to another.
    event Transfer(address indexed from, address indexed to, uint256 value);

    /// @notice Emitted when tokens are given as referrals.
    event Referral(address indexed buyer, address indexed affiliate, uint256 amountSent);

    /// @notice Emitted when tokens are transferred from one address to another.
    event Swap(address indexed sender, uint256 amount0In, uint256 amount1In, uint256 amount0Out, uint256 amount1Out);

    /// @notice Emitted when an allowance is set by the owner for a spender.
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /// @notice Emitted when tokens are deposited for voting.
    event DepositForVotes(address indexed voter, uint256 id, uint256 amount);

    /// @notice Emitted when deposited tokens are withdrawn from voting.
    event WithdrawDeposit(address indexed voter, uint256 id, uint256 amount);

    /// @notice Emitted when tokens are claimed via an NFT.
    event ClaimViaNFT(address indexed from, uint256 tokenID, uint256 amount);

    /// @notice Emitted when an NFT is deposited for burning.
    event DepositNFT(address indexed owner, uint256 tokenID, uint256 amount);

    /// @notice Emitted when voting is enabled based on token sales.
    event VotingEnabled(uint256 indexed tokenAmount, uint256 percentSold, uint256 poolAmount);

    /// @notice Emitted when claiming is enabled or disabled.
    event ToggleClaiming(bool enabled);

    /// @notice Emitted when burning is enabled or disabled.
    event ToggleBurning(bool enabled);

    /// @notice Emitted when Timer is changed are enabled or disabled.
    event TimerOn(bool enabled);

    // Structs

    /**
     * @dev Represents the outcome of a voting process.
     * @param yesVotes Number of affirmative votes.
     * @param noVotes Number of negative votes.
     * @param executed Flag indicating if the vote has been executed.
     */
    struct VotingOutcome {
        uint256 yesVotes; // Number of yes votes
        uint256 noVotes; // Number of no votes
        bool executed; // If the vote has been executed
    }

    // Modifiers

    /**
     * @dev Modifier to check if the caller has the default admin role.
     */
    modifier onlyAdmin() {
        if (!hasRole(DEFAULT_ADMIN_ROLE, msg.sender)) revert Unauthorized();
        _;
    }

    /**
     * @dev Modifier to check if the caller has the LogicLib role.
     */
    modifier onlyLogicLib() {
        if (!hasRole(LogicLibRole, msg.sender)) revert Unauthorized();
        _;
    }

    // Constructor

    /**
     * @dev Sets the deployer as the initial factory address.
     */
    constructor() {
        factoryAddress = payable(msg.sender);
    }

    // Initialization Function

    /**
     * @dev Initializes the contract with necessary parameters and sets up initial roles and token distribution.
     * @param name_ Name of the ERC20 token.
     * @param symbol_ Symbol of the ERC20 token.
     * @param _NFTContract Address of the ERC721A NFT contract.
     * @param maxSupplyTokens Maximum number of tokens that can be minted.
     * @param _bondingCurveContract Address of the BondingCurve contract.
     * @param _logicLibAddress Address of the LogicLib contract for voting.
     * @param deployer Address receiving initial token allocations.
     * @return success Returns true upon successful initialization.
     */
    function initialize(
        string calldata name_,
        string calldata symbol_,
        address _NFTContract,
        uint256 maxSupplyTokens,
        address _bondingCurveContract,
        address _logicLibAddress,
        address deployer
    ) external payable initializer returns (bool success) {
        // Grant the deployer the default admin role
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);

        // Set the factory address to the initializer's address
        factoryAddress = payable(msg.sender);

        // Initialize the bonding curve contract
        bondingCurveContract = IBondingCurveLib(_bondingCurveContract);

        // Set token details
        name = name_;
        symbol = string(abi.encodePacked("e", symbol_));

        // Initialize the NFT contract
        NFTContract = IERC721A(_NFTContract);

        // Initialize the factory contract
        ERC721exFactory = IERC721exFactory(factoryAddress);

        // Initialize the voting contract
        votingContract = ILogicLib(_logicLibAddress);

        // Grant the LogicLibRole to the LogicLib contract
        _grantRole(LogicLibRole, _logicLibAddress);

        // Use IERC165 to verify that the NFT contract supports the ERC721 interface
        require(IERC165(_NFTContract).supportsInterface(_INTERFACE_ID_ERC721), "IC");

        // Calculate the maximum supply with decimals
        uint256 scaledMaxSupply = maxSupplyTokens * 1e6;

        maxSupplyOfTokens = scaledMaxSupply;
        claimAndBurnReward = scaledMaxSupply / 2000;
        supplyLeft = scaledMaxSupply - ((scaledMaxSupply * 22) / 100);
        deployedTime = uint32(block.timestamp);
        // Mint initial tokens to the deployer and factory
        _mint(msg.sender, ((scaledMaxSupply * 20) / 100));
        _mint(deployer, ((scaledMaxSupply * 2) / 100));

        // Track tokens claimed by the deployer
        tokensFromClaimedNFTs[deployer] = (scaledMaxSupply * 2) / 100;

        return true;
    }

    /*
     *
     *
     * ////////// External and Public Functions //////////////
     *
     *
     *
     */

    /**
     * @dev Calculates the maximum order size a user can place, considering slippage.
     * @return maxBuyAmount The maximum number of tokens that can be bought.
     * @return maxSlippage The maximum slippage percentage allowed.
     */
    function calculateMaxOrderSize() external view returns (uint256 maxBuyAmount, uint256 maxSlippage) {
        uint256 currentTotalSupply = totalSupply;
        uint256 maxSupply = maxSupplyOfTokens;
        //Calculate the maximum slippage based on the current bonding curve
        maxSlippage = bondingCurveContract.calculateSlippageCurvePercentage(currentTotalSupply, maxSupply);

        // Calculate the current price per token using the bonding curve
        uint256 currentPrice = bondingCurveContract.calculateCurrentPrice(currentTotalSupply, maxSupply);

        // Calculate the maximum buy amount based on current price and slippage

        maxBuyAmount = currentPrice * maxSlippage;
        return (maxBuyAmount, maxSlippage);
    }

    /**
     * @dev Calculates the percentage of the total supply that has been sold.
     * @return pmin lowest price
     * @return pmax highest price
     * @dev
     * - Determines PMIN and PMAX dynamically.
     */
    function getPMINandPMAX() public view returns (uint256, uint256) {
        (uint256 PMIN, uint256 PMAX) = bondingCurveContract.getPMINandPMAX(maxSupplyOfTokens);
        return (PMIN, PMAX);
    }

    /**
     * @dev Calculates the percentage of the total supply that has been sold.
     * @return percentageSold The percentage of tokens sold multiplied by 10000 for precision.
     */
    function calculateCurvePercentage() external view returns (uint256 percentageSold) {
        return percentageSold = (totalSupply * 10000) / maxSupplyOfTokens;
    }

    /**
     * @dev Calculates the current buy price of a token based on the bonding curve.
     * @return currentPrice The current price of a single token in wei.
     */
    function calculateCurrentBuyPrice() external view returns (uint256 currentPrice) {
        // Calculate the current price per token using the bonding curve
        currentPrice = bondingCurveContract.calculateCurrentPrice(totalSupply, maxSupplyOfTokens);

        return currentPrice;
    }

    /**
     * @dev Calculates the amount of ETH that would be returned for selling a given amount of tokens.
     * @return maxSlippage The maximum slippage percentage.
     * @return currentPricePertoken The current price per token for selling.
     */
    function calculateETHReturned() public view returns (uint256 maxSlippage, uint256 currentPricePertoken) {
        // Retrieve maximum slippage and current price per token for selling
        (maxSlippage, currentPricePertoken) = bondingCurveContract.showMaxSellPriceAndAmount(
            totalSupply,
            maxSupplyOfTokens
        );

        // Ensure the contract has enough ETH to cover the refund
        if (address(this).balance <= currentPricePertoken / 1e7) {
            revert InsufficientETHInContract();
        }

        return (maxSlippage, currentPricePertoken);
    }

    /**
     * @dev Allows users to buy tokens by sending ETH. It calculates the number of tokens to mint based on the bonding curve,
     * @dev handles fees, and manages the closing timer.
     * @param _minTokensAccepted The minimum number of tokens the user is willing to accept to account for max slippage minus their % slippage choice.
     */
    function buyTokens(uint256 _minTokensAccepted, uint256 _referralNFT) external payable nonReentrant {
        if (block.timestamp < deployedTime + 30 minutes) {
            revert BondingCurveNotReady();
        }
        require(ERC721exFactory.isActive(), "Emerg. Mode");
        uint256 value = msg.value;
        
        // Ensure that trading is not currently live
        if (tradingLive) revert TradingInactive();
        if (_referralNFT != 0) {
            //require unused referral nft
            require(referredNFTs[_referralNFT] < 2, "Used");
        }

        // Ensure that some ETH is sent
        if (value == 0) revert InsufficientBalance();

        uint256 currentTotalSupply = totalSupply;
        uint256 maxSupply = maxSupplyOfTokens;
        uint256 remainingSupplyLeft = supplyLeft;
        uint256 tokensSoldStackVar = tokensSold;

        // Calculate the number of tokens to buy and the price per token
        (uint256 tokensToBuy, uint256 priceOfToken) = bondingCurveContract.calculateTokensToMint(
            value,
            currentTotalSupply,
            maxSupply,
            remainingSupplyLeft
        );

        // Calculate the fee (0.2% of the sent ETH)
        uint256 fee = (value * 2) / 1000;

        // Calculate maximum slippage based on the bonding curve
        uint256 maxSlippage = bondingCurveContract.calculateSlippageCurvePercentage(currentTotalSupply, maxSupply);

        // If tokens to buy exceed slippage, ensure that at least 90% of tokens are sold
        if (tokensToBuy > maxSlippage && ((currentTotalSupply * 100) / maxSupply) < 90) {
            revert ExceedsLimit();
        }

        // Handle the case where tokens to buy exceed the available supply left
        if (tokensToBuy > remainingSupplyLeft) {
            // Adjust tokensToBuy to the remaining supply
            tokensToBuy = remainingSupplyLeft;

            // Calculate the fee (0.2% of the paid amount for the tokens actually being bought)
            uint256 paidForAmount = tokensToBuy * priceOfToken;
            fee = (paidForAmount * 2) / 1000;

            // Call refundDust() to handle fee and refund
            refundDust(msg.sender, value, paidForAmount, fee);

            // Emit Swap event
            emit Swap(msg.sender, paidForAmount, 0, 0, tokensToBuy);

            // Update supply left and tokens sold after minting
            supplyLeft = 0;
            tokensSold += tokensToBuy;

            // Mint the tokens to the buyer before updating totalSupply
            _mint(msg.sender, tokensToBuy);
            if (_referralNFT != 0) {
                useReferral(tokensToBuy, _referralNFT, msg.sender);
            }
            // Call executeTimerToTurnOffPool to handle closing the pool as it was the final purchase
            executeTimerToTurnOffPool(supplyLeft);
            return; // Exit to avoid executing further logic below
        }

        // Regular purchase handling if not buying the final tokens

        // Ensure that the minimum tokens accepted is within the slippage range
        if (_minTokensAccepted < (tokensToBuy * 95) / 100 || _minTokensAccepted > tokensToBuy) {
            revert InvalidAmount();
        }

        // Ensure that minting these tokens does not exceed the maximum supply
        if (currentTotalSupply + tokensToBuy > maxSupply) {
            revert ExceedsLimit();
        }

        // Emit Swap event
        emit Swap(msg.sender, value, 0, 0, tokensToBuy);

        // Update supply left and tokens sold after minting
        supplyLeft = remainingSupplyLeft - tokensToBuy;
        tokensSold = tokensSoldStackVar + tokensToBuy;

        // Mint the tokens to the buyer before updating totalSupply
        _mint(msg.sender, tokensToBuy);

        //transfer fee to factory
        payable(factoryAddress).transfer(fee);
        // Check referral
        if (_referralNFT != 0) {
            useReferral(tokensToBuy, _referralNFT, msg.sender);
        }
        // Check and manage the closing timer
        hasClosingTimer();

        // If more than 50% of tokens are sold and voting is not live, enable voting
        if (!votingLive && (((tokensSoldStackVar + tokensToBuy) * 100) / maxSupply) > 50) {
            emit VotingEnabled(
                currentTotalSupply,
                (((tokensSoldStackVar + tokensToBuy) * 100) / maxSupply),
                address(this).balance
            );
            votingLive = true;
        }
    }

    /**
     * @dev Refunds the remaining ETH to the buyer if they sent more ETH than required for the final tokens available.
     * @param sender The address of the buyer.
     * @param value The value of ETH sent by the buyer.
     * @param paidForAmount The paidForAmount in ETH.
     * @param fee The calculated fee amount.
     */
    function refundDust(address sender, uint256 value, uint256 paidForAmount, uint256 fee) internal {
        // Calculate the amount paid for the tokens
        uint256 remainingLeftOver = value > (paidForAmount + fee) ? value - (paidForAmount + fee) : 0;

        // Transfer the fee to the factory address
        payable(factoryAddress).transfer(fee);

        // Refund the remaining ETH to the buyer
        if (remainingLeftOver > 0) {
            payable(sender).transfer(remainingLeftOver);
        }
    }

    /**
     * @dev Allows users to sell their tokens in exchange for ETH based on the bonding curve.
     * @dev It handles fee deductions and updates the token supply accordingly.
     * @param amount The number of tokens the user wants to sell.
     * @param _minETHAccepted The minimum amount of ETH the user is willing to accept to account for slippage.
     */
    function sellTokens(uint256 amount, uint256 _minETHAccepted) external nonReentrant {
        // Ensure that trading is not currently live
        if (tradingLive) {
            revert TradingInactive();
        }
        require(ERC721exFactory.isActive(), "Emerg. Mode");
        uint256 senderBalance = _balances[msg.sender];
        // Ensure that the seller has enough tokens
        if (senderBalance < amount) revert InsufficientBalance();

        // Check and manage the closing timer
        hasClosingTimer();

        uint256 maxSupply = maxSupplyOfTokens;
        uint256 tokensSoldStackVar = tokensSold;
        uint256 tokensClaimedByUser = tokensFromClaimedNFTs[msg.sender];
        uint256 tokensByBurning = tokensFromBurnedNFTs[msg.sender];
        // Adjust the amount of tokens to sell based on tokens received from claiming NFTs
        if (senderBalance > tokensClaimedByUser + tokensByBurning) {
            if (senderBalance - amount > tokensClaimedByUser + tokensByBurning) {
                // The sell amount is okay as it leaves more than the claimed tokens, sell the requested amount
                // Proceed to sell the requested amount
            } else {
                // Adjust amount to ensure it does not dip into the claimed tokens
                amount = senderBalance - (tokensClaimedByUser + tokensByBurning);
            }
        } else {
            revert CannotSellClaimedTokens();
        }

        // Ensure that the amount to sell is greater than zero
        if (amount == 0) {
            revert InvalidAmount();
        }

        // Calculate the amount of ETH to return based on the bonding curve
        uint256 etherToReturn = bondingCurveContract.calculateEthToRefund(
            amount,
            tokensSoldStackVar,
            totalSupply,
            maxSupply
        );

        // Ensure that the minimum ETH accepted is at least 7% of the calculated refund
        if (_minETHAccepted < (etherToReturn * 93) / 100) {
            revert InvalidAmount();
        }

        // Ensure that the minimum ETH accepted does not exceed the calculated refund
        if (_minETHAccepted > etherToReturn) {
            revert InvalidAmount();
        }

        // Calculate the fee for withdrawing (0.5% of the refund)
        uint256 fee = (etherToReturn * 5) / 1000;

        // Ensure that the contract has enough ETH to cover the refund
        if (etherToReturn > address(this).balance) {
            revert InsufficientETHInContract();
        }

        // Deduct the fee from the refund amount
        etherToReturn -= fee;

        // Transfer the fee to the factory address
        payable(factoryAddress).transfer(fee);

        // Update the supply left and tokens sold
        supplyLeft += amount;

        tokensSold = tokensSoldStackVar - amount;

        // Burn the sold tokens from the seller's balance
        _burn(msg.sender, amount);

        // Transfer the remaining ETH to the seller
        payable(msg.sender).transfer(etherToReturn);

        emit Swap(msg.sender, 0, amount, etherToReturn, 0);
    }

    /**
     * @dev Allows an admin to deposit tokens for a specific voter and proposal.
     * @param proposalId The ID of the proposal for which tokens are being deposited.
     * @param _amount The amount of tokens to deposit.
     * @param _voter The address of the voter.
     * @return success Returns true upon successful deposit.
     */
    function depositTokensToVote(
        uint256 proposalId,
        uint256 _amount,
        address _voter
    ) external onlyLogicLib returns (bool success) {
        // Ensure the voter has enough tokens to deposit
        if (_balances[_voter] <= _amount) revert InsufficientBalance();

        // Update the deposited tokens for the voter and proposal
        depositedTokensToVote[_voter][proposalId] += _amount;

        // Deduct the deposited tokens from the voter's balance
        _balances[_voter] -= _amount;

        // Add the deposited tokens to the holder address
        _balances[holderAddress] += _amount;

        // Emit an event for the deposit
        emit DepositForVotes(_voter, proposalId, _amount);

        return true;
    }

    /**
     * @dev Allows a voter to withdraw their deposited tokens after a proposal has concluded.
     * @param proposalId The ID of the proposal for which tokens were deposited.
     * @param _amount The amount of tokens to withdraw.
     * @return success Returns true upon successful withdrawal.
     */
    function withdrawVotedTokens(uint256 proposalId, uint256 _amount) public returns (bool success) {
        // Ensure the voter has enough tokens deposited for the proposal
        if (depositedTokensToVote[msg.sender][proposalId] < _amount) {
            revert InsufficientBalance();
        }

        // Ensure that the proposal is no longer active
        if (votingContract.isProposalActive(address(this), proposalId)) {
            revert ProposalActive();
        }

        // Update the deposited tokens for the voter and proposal
        depositedTokensToVote[msg.sender][proposalId] -= _amount;

        // Deduct the withdrawn tokens from the holder address
        _balances[holderAddress] -= _amount;

        // Return the withdrawn tokens to the voter's balance
        _balances[msg.sender] += _amount;

        // Remove the deposit from the voting contract's tracking
        votingContract.removeDepositFromVote(proposalId, msg.sender);

        // Emit an event for the withdrawal
        emit WithdrawDeposit(msg.sender, proposalId, _amount);

        return true;
    }

    /**
     * @dev Allows users to claim tokens with an NFT they own.
     * @dev The amount of tokens minted is based on the bonding curve.
     * @param tokenId The ID of the NFT being burned.
     * @return amount The amount of tokens minted to the user.
     */
    function claimWithNFT(uint256 tokenId) external nonReentrant returns (uint256 amount) {
        // Ensure the claiming is enabled
        if (claimingDisabled) {
            revert InvalidAction();
        }
        require(ERC721exFactory.isActive(), "Emerg. Mode");
        // Ensure the caller owns the specified NFT
        require(NFTContract.ownerOf(tokenId) == msg.sender && NFTContract.balanceOf(msg.sender) >= 1, "NTO");

        // Ensure the NFT has not already been claimed
        if (claimedNFTs[tokenId]) revert ExceedsLimit();

        // Calculate the amount of tokens to mint
        amount = claimAndBurnReward;

        // Update the maximum supply to include the minted tokens
        maxSupplyOfTokens += amount;

        // Mark the NFT as claimed
        claimedNFTs[tokenId] = true;

        // Track the tokens received from claiming the NFT
        tokensFromClaimedNFTs[msg.sender] += amount;

        // Mint the tokens to the account
        _mint(msg.sender, amount);

        // Emit an event for the claim
        emit ClaimViaNFT(msg.sender, tokenId, amount);

        return amount;
    }

    /**
     * @dev Allows users to burn an NFT they own in exchange for additional tokens.
     * @dev The amount of tokens minted is a fixed fraction of the total supply.
     * @param tokenId The ID of the NFT being burned.
     * @return tokenAmount The amount of tokens minted to the user.
     */
    function burnNFTForTokens(uint256 tokenId) external nonReentrant returns (uint256 tokenAmount) {
        // Ensure the burning is enabled
        if (burningDisabled) {
            revert InvalidAction();
        }
        require(ERC721exFactory.isActive(), "Emerg. Mode");
        // Ensure the NFT is approved for transfer by this contract
        require(
            NFTContract.isApprovedForAll(msg.sender, address(this)) &&
                NFTContract.getApproved(tokenId) == address(this),
            "TNA"
        );

        // Calculate the amount of tokens to mint
        tokenAmount = claimAndBurnReward * 2;

        // Transfer the NFT from the user to the factory address
        NFTContract.transferFrom(msg.sender, factoryAddress, tokenId);

        // Emit an event for the NFT deposit
        emit DepositNFT(msg.sender, tokenId, tokenAmount);

        // Track the tokens received from burning the NFT
        tokensFromBurnedNFTs[msg.sender] = tokensFromBurnedNFTs[msg.sender] + tokenAmount;

        // Update the maximum supply to include the minted tokens
        maxSupplyOfTokens += tokenAmount;

        // Mint the tokens to the account
        _mint(msg.sender, tokenAmount);

        return tokenAmount;
    }

    /*==================================================

                    LogicLib Functions

    ====================================================*/


    /**
     * @dev Allows a vote to enable poolsplit
     * @param proposal_id The proposal id to check
     */
    function executePoolSplit(uint256 proposal_id) public onlyLogicLib {
        // Retrieve the voting outcome for the pool split proposal
        ILogicLib.VotingOutcome memory outcome = votingContract.getVotingOutcome(address(this), proposal_id);

        // Ensure that the vote has been executed
        require(outcome.executed, "NE");

        // If trading is not live, enable it
        bool _tradingLive = tradingLive;

        if (!_tradingLive) {
            // Enable pool split vote if trading is not live
            poolSplitVote = true;
        } else {
            // Use require with custom error
            if (!ERC721exFactory.removeAndSwapLiquidity(address(this))) {
                revert ErrorAddingLiquidity();
            }
        }
    }

    /**
     * @dev Allows an voting to toggle claim
     * @param proposal_id The proposal id to check
     */
    function toggleClaim(uint256 proposal_id) external onlyLogicLib {
        // Retrieve the outcome of the specified voting proposal
        ILogicLib.VotingOutcome memory outcome = votingContract.getVotingOutcome(address(this), proposal_id);

        // Ensure that the vote has been executed
        require(outcome.executed, "NE");

        claimingDisabled = !claimingDisabled;

        emit ToggleClaiming(claimingDisabled);
    }

    /**
     * @dev Allows an voting to toggle burn
     * @param proposal_id The proposal id to check
     */
    function toggleBurn(uint256 proposal_id) external onlyLogicLib {
        // Retrieve the outcome of the specified voting proposal
        ILogicLib.VotingOutcome memory outcome = votingContract.getVotingOutcome(address(this), proposal_id);

        // Ensure that the vote has been executed
        require(outcome.executed, "NE");

        burningDisabled = !burningDisabled;

        emit ToggleBurning(burningDisabled);
    }

    /**
     * @dev Creates a liquidity pool and adds liquidity via the factory based on the outcome of a proposal.
     * @param proposal_id The ID of the proposal being executed.
     * @return success Returns true upon successful execution.
     */
    function createPoolAndAddLiquidity(uint256 proposal_id) external onlyLogicLib returns (bool success) {
        // Retrieve the outcome of the specified voting proposal
        ILogicLib.VotingOutcome memory outcome = votingContract.getVotingOutcome(address(this), proposal_id);

        // Ensure that the vote has been executed
        require(outcome.executed, "NE");

        // Execute the timer to turn off the liquidity pool
        executeTimerToTurnOffPool(totalSupply);

        return true;
    }

    /**
     * @dev Allows the LogicLib contract to give rewards to a recipient based on an action.
     * @param recipient The address to receive the reward.
     * @param action The action based on which the reward is given.
     */
    function giveReward(address recipient, uint8 action) external onlyLogicLib {
        // Cache the maxSupplyOfTokens to reduce storage reads
        uint256 maxTokens = maxSupplyOfTokens;
        uint256 reward;

        // Determine the reward based on the action
        if (action == 0) {
            // ExecuteAction
            reward = (ACTION_EXECUTE_MULTIPLIER * maxTokens) / DIVISOR;
        } else if (action == 1) {
            // SubmitVote
            reward = (ACTION_SUBMIT_VOTE_MULTIPLIER * maxTokens) / DIVISOR;
        } else if (action == 2) {
            // EndVote
            reward = (ACTION_END_VOTE_MULTIPLIER * maxTokens) / DIVISOR;
        } else {
            revert InvalidAction();
        }

        // Update the maxSupplyOfTokens safely using unchecked
        unchecked {
            maxSupplyOfTokens += reward;
        }

        // Mint the reward to the recipient
        _mint(recipient, reward);
    }

    /*==================================================

                        ERC20 FUNCTIONS

    ====================================================*/

    /**
     * @notice Returns the balance of the specified address.
     * @param account The address to query the balance of.
     * @return A uint256 representing the amount owned by the passed address.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev Allows an owner to approve a spender to spend a specific amount of tokens.
     * @param spender The address authorized to spend the tokens.
     * @param amount The maximum amount of tokens the spender is authorized to spend.
     * @return success Returns true upon successful approval.
     */
    function approve(address spender, uint256 amount) public returns (bool success) {
        // Use ERC20Lib to handle the approval logic
        return ERC20Lib.approve(_allowances, msg.sender, spender, amount);
    }

    /**
     * @dev Allows a spender to transfer tokens from an owner's account to another account.
     * @param from The address of the token owner.
     * @param to The address to transfer tokens to.
     * @param amount The amount of tokens to transfer.
     * @return success Returns true upon successful transfer.
     */
    function transferFrom(address from, address to, uint256 amount) public returns (bool success) {
        require(tradingLive, 'Curve still on.'); 
        // Use ERC20Lib to handle the transferFrom logic with the amount
        return ERC20Lib.transferFrom(_balances, _allowances, msg.sender, from, to, amount);
    }

    /**
     * @dev Allows a user to transfer tokens to another account.
     * @param to The address to transfer tokens to.
     * @param amount The amount of tokens to transfer.
     * @return success Returns true upon successful transfer.
     */
    function transfer(address to, uint256 amount) public returns (bool success) {
        require(tradingLive, 'Curve still on.'); 
        // Use ERC20Lib to handle the transfer logic with the adjusted amount
        return ERC20Lib.transfer(_balances, msg.sender, to, amount);
    }

    /**
     * @dev Allows a user to increase the allowance granted to a spender.
     * @param spender The address authorized to spend the tokens.
     * @param addedValue The amount of tokens to increase the allowance by.
     * @return success Returns true upon successful allowance increase.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool success) {
        // Use ERC20Lib to handle the increaseAllowance logic
        return ERC20Lib.increaseAllowance(_allowances, msg.sender, spender, addedValue);
    }

    /**
     * @dev Allows a user to decrease the allowance granted to a spender.
     * @param spender The address authorized to spend the tokens.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     * @return success Returns true upon successful allowance decrease.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool success) {
        // Use ERC20Lib to handle the decreaseAllowance logic
        return ERC20Lib.decreaseAllowance(_allowances, msg.sender, spender, subtractedValue);
    }

    /**
     * @dev Returns the remaining number of tokens that a spender is allowed to spend on behalf of an owner.
     * @param _owner The address of the token owner.
     * @param spender The address authorized to spend the tokens.
     * @return remaining The remaining allowance for the spender.
     */
    function allowance(address _owner, address spender) public view returns (uint256 remaining) {
        // Use ERC20Lib to retrieve the allowance
        return ERC20Lib.allowance(_allowances, _owner, spender);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControl, ERC165) returns (bool) {
        return
            interfaceId == _INTERFACE_ID_ERC165 ||
            interfaceId == _INTERFACE_ID_ERC20 ||
            super.supportsInterface(interfaceId);
    }

    /*==================================================

                    INTERNAL FUNCTIONS

    ====================================================*/

    /**
     * @dev Checks and manages the closing timer based on the percentage of tokens sold.
     * @dev If certain thresholds are met, it updates the trading status and interacts with the factory.
     */
    function hasClosingTimer() internal {
        // Calculate the percentage of tokens sold
        uint256 currentTotalSupply = totalSupply;
        uint256 maxSupply = maxSupplyOfTokens;
        uint256 soldPercentage = (currentTotalSupply * 100) / maxSupply;
        uint256 closingTimerStackVar = closingTimer;

        // If all tokens are sold, deactivate the timer and enable trading
        if (currentTotalSupply >= maxSupply) {
            executeTimerToTurnOffPool(0);
            return; // Exit after turning off pool
        }

        // If 90% or more tokens are sold and no timer is set, set the closing timer
        if (soldPercentage >= 90 && closingTimerStackVar == 0) {
            closingTimer = uint32(block.timestamp) + 4 hours; // Set the timer for 1 hour
            emit TimerOn(true);
        }

        // If a closing timer is active, check if it has expired and take appropriate actions
        if (closingTimerStackVar > 0) {
            // Check if the closing timer has expired
            if (block.timestamp >= closingTimerStackVar) {
                // If sold percentage is still high enough, deactivate the timer and enable trading
                if (soldPercentage >= 70) {
                    executeTimerToTurnOffPool(currentTotalSupply);
                    return;
                } else {
                    // Otherwise, clear the timer and continue the pool
                    closingTimer = 0; // Clear timer
                    emit TimerOn(false);
                }
            }
        }
    }

    /**
     * @dev Executes the actions required to turn off the liquidity pool.
     * @dev Mints remaining tokens to the factory and interacts with the factory to add liquidity.
     */
    function executeTimerToTurnOffPool(uint256 currentTotalSupply) internal {
        // Calculate tokens left to mint

        if (currentTotalSupply != 0) {
            uint256 tokensLeft = maxSupplyOfTokens - currentTotalSupply;
            // Mint any remaining tokens to the factory address
            if (tokensLeft > 0) {
                _mint(factoryAddress, tokensLeft);
            }
        }

        tradingLive = true; // Allow trading
        // Require that adding liquidity via the factory succeeds
        if (!ERC721exFactory.UniswapAddLiquidity(totalSupply, address(NFTContract), address(this), poolSplitVote)) {
            revert ErrorAddingLiquidity();
        }
    }

    /**
     * @dev Internal function to mint tokens to a specific account.
     * Ensures that the minting does not exceed the maximum supply.
     * @param account The address to mint tokens to.
     * @param amount The amount of tokens to mint.
     * @return success Returns true upon successful minting.
     */
    function _mint(address account, uint256 amount) internal returns (bool success) {
        uint256 currentTotalSupply = totalSupply;
        // Ensure that minting these tokens does not exceed the maximum supply
        require(currentTotalSupply + amount <= maxSupplyOfTokens, "EMS");

        // Update the total supply and the account's balance
        unchecked {
            totalSupply += amount;
            _balances[account] += amount;
        }

        // Emit a transfer event from the zero address to signify minting
        emit Transfer(address(0), account, amount);

        return true;
    }

    /**
     * @dev Internal function to burn tokens from a specific account.
     * @dev Ensures that the account has enough tokens to burn.
     * @param account The address to burn tokens from.
     * @param amount The amount of tokens to burn.
     */
    function _burn(address account, uint256 amount) internal {
        // Deduct the amount from the account's balance, ensuring it doesn't go negative
        _balances[account] -= amount;

        // Deduct the amount from the total supply
        totalSupply -= amount;

        // Emit a transfer event to the zero address to signify burning
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Allows the User to use a referral NFT to a recipient based on an action.
     * @param _buyAmount The address to receive the bonus.
     * @param token_id The token id of the nft used
     * @param sender the msg.sender
     * @return success Returns true upon successful bonus distribution.
     */
    function useReferral(uint256 _buyAmount, uint256 token_id, address sender) internal returns (bool success) {
        // Calculate referral bonus: 5% of buy amount
        uint256 referralBonus = (_buyAmount * 25) / 1000;

        // Use a try/catch block to mint the referral bonus to the NFT holder
        try NFTContract.ownerOf(token_id) returns (address nftHolderRefer) {
            require(nftHolderRefer != address(0) && nftHolderRefer != sender, "IA");
            // Mark the referred NFT as used
            unchecked {
                // Use unchecked block to save gas on increment operation
                referredNFTs[token_id]++;
            }

            // Gas optimization: Batch mint operation by combining both mints.
            // Instead of calling _mint twice (which is expensive in gas), use internal bookkeeping and emit one Transfer event.
            // Mint half of the reward to the sender
            _balances[sender] += referralBonus;
            // Mint the other half of the reward to the NFT owner
            _balances[nftHolderRefer] += referralBonus;

            // Update total supply directly after calculating both referral rewards.
            unchecked {
                totalSupply += (referralBonus * 2);
                maxSupplyOfTokens += (referralBonus * 2);
            }

            // Emit two Transfer events for transparency
            emit Transfer(address(0), sender, referralBonus);
            emit Transfer(address(0), nftHolderRefer, referralBonus);
            emit Referral(sender, nftHolderRefer, referralBonus);
        } catch {
            // If retrieving the owner fails, mark the operation as failed
            return false;
        }

        // Return true if all operations were successful
        return true;
    }

    /*==================================================

                        Admin Functions

    ====================================================*/

    /**
     * @dev Allows Factory to withdraw ETH for Uniswap or during an emergency mode an admin can call.
     * @dev specified amount of ETH from the contract.
     * @param amount The amount of ETH to withdraw.
     * @return success Returns true upon successful withdrawal.
     */
    function withdraw(uint256 amount) external onlyAdmin returns (bool success) {
        // Transfer the specified amount of ETH to the admin
        payable(msg.sender).transfer(amount);
        return true;
    }


    /**
     * @dev Allows an admin to update the address of the BondingCurve contract.
     * @param curve The new address of the BondingCurve contract.
     */
    function updateBondingCurve(address curve) external onlyAdmin {
        // Update the bonding curve contract address
        bondingCurveContract = IBondingCurveLib(curve);
    }

    /**
     * @dev Allows an admin to set a new LogicLib contract address.
     * @param _logicLibAddress The new address of the LogicLib contract.
     */
    function setLogicLibAddress(address _logicLibAddress) external onlyAdmin {
        votingContract = ILogicLib(_logicLibAddress);
    }

    /**
     * @dev Allows an admin to grant the default admin role to a new user.
     * @param _newUser The address of the new user to grant the role to.
     */
    function grantRole(address _newUser) external onlyAdmin {
        // Grant the default admin role to the new user
        _grantRole(DEFAULT_ADMIN_ROLE, _newUser);
    }

    /**
     * @dev Fallback function to handle incoming ETH transfers with data.
     */
    fallback() external payable {
     
    }

    receive() external payable {
      
    }
}
// SPDX-License-Identifier: MIT
/*
 *
 * All rights reserved. Property of Mintable PTE LTD.
 *
 */

pragma solidity ^0.8.0;

/**
 * @title IBondingCurveLib
 * @dev Interface for the BondingCurveLib contract.
 *      It declares all the external and public functions available in the BondingCurveLib.
 */
interface IBondingCurveLib {
    // ============================================
    // State Variables Getters
    // ============================================

    /**
     * @notice The total target ETH for the bonding curve.
     * @return The total target ETH in wei.
     */
    function TOTAL_TARGET_ETH() external view returns (uint256);

    /**
     * @notice Phase 1 percentage for pricing.
     * @return The percentage value.
     */
    function PHASE_1_PERCENTAGE() external view returns (uint256);

    /**
     * @notice Phase 2 percentage for pricing.
     * @return The percentage value.
     */
    function PHASE_2_PERCENTAGE() external view returns (uint256);

    /**
     * @notice Phase 3 percentage for pricing.
     * @return The percentage value.
     */
    function PHASE_3_PERCENTAGE() external view returns (uint256);

    // ============================================
    // Pricing Calculation Functions
    // ============================================

    /**
     * @notice Calculates dynamic PMIN and PMAX based on total supply and target ETH.
     * @param totalSupply The current total supply of tokens.
     * @return PMIN The calculated minimum price in wei.
     * @return PMAX The calculated maximum price in wei.
     * @dev
     * - Ensures totalSupply is greater than zero.
     * - Calculates PMIN based on totalSupply and TOTAL_TARGET_ETH.
     * - Sets PMAX to be three times the average price needed to reach the target ETH.
     * - Ensures PMIN is less than PMAX.
     */
    function calculateDynamicPricing(uint256 totalSupply) external pure returns (uint256 PMIN, uint256 PMAX);

    /**
     * @notice getPMINandPMAX
     * @param maxSupplyOfTokens The maximum supply of tokens.
     * @return pmin The lowest price in wei.
     * @return pmax The highest price in wei.
     * @dev
     * - Determines PMIN and PMAX dynamically.
     */
    function getPMINandPMAX(uint256 maxSupplyOfTokens) external pure returns (uint256 pmin, uint256 pmax);

    /**
     * @notice Calculates the current price of the token based on the percentage of tokens sold.
     * @param totalSupply The current total supply of tokens.
     * @param maxSupplyOfTokens The maximum supply of tokens.
     * @return price The current price of the token in wei.
     * @dev
     * - Calculates the percentage of tokens sold.
     * - Determines PMIN and PMAX dynamically.
     * - Calculates the current price using the bonding curve logic.
     */
    function calculateCurrentPrice(
        uint256 totalSupply,
        uint256 maxSupplyOfTokens
    ) external pure returns (uint256 price);

    // ============================================
    // Buying Tokens Functions
    // ============================================

    /**
     * @notice Calculates the number of tokens that can be minted with the given ETH sent.
     * @param ethSent The amount of ETH sent for purchasing tokens.
     * @param totalSupply The current total supply of tokens.
     * @param maxSupplyOfTokens The maximum supply of tokens.
     * @param supplyLeft The remaining supply of tokens that can be minted.
     * @return tokensToMint The number of tokens that can be minted with the provided ETH.
     * @return currentPrice The current price of a single token in wei.
     * @dev
     * - Ensures there are tokens left to mint.
     * - Calculates the maximum allowable slippage based on the bonding curve.
     * - Determines the percentage of tokens sold.
     * - Calculates the current price of tokens.
     * - Determines the number of tokens that can be minted with the provided ETH.
     */
    function calculateTokensToMint(
        uint256 ethSent,
        uint256 totalSupply,
        uint256 maxSupplyOfTokens,
        uint256 supplyLeft
    ) external pure returns (uint256 tokensToMint, uint256 currentPrice);

    // ============================================
    // Selling Tokens Functions
    // ============================================

    /**
     * @notice Calculates the maximum slippage and current token price when selling tokens.
     * @param totalSupply The current total supply of tokens.
     * @param maxSupplyOfTokens The maximum supply of tokens.
     * @return maxSlippage The maximum allowable slippage in wei.
     * @return currentTokenPrice The current price of the token in wei.
     * @dev
     * - Calculates the adjusted maximum slippage based on tokens sold.
     * - Applies a 15% reduction to the maximum slippage.
     */
    function showMaxSellPriceAndAmount(
        uint256 totalSupply,
        uint256 maxSupplyOfTokens
    ) external pure returns (uint256 maxSlippage, uint256 currentTokenPrice);

    /**
     * @notice Calculates the amount of ETH to refund when selling a specific number of tokens.
     * @param tokensToSell The number of tokens the user wants to sell.
     * @param tokensSold The number of tokens already sold.
     * @param totalSupply The current total supply of tokens.
     * @param maxSupplyOfTokens The maximum supply of tokens.
     * @return ethToRefund The amount of ETH to refund to the seller.
     * @dev
     * - Ensures the seller is selling a valid number of tokens.
     * - Calculates the current token sell price and maximum slippage.
     * - Ensures the tokens to sell do not exceed the maximum slippage.
     * - Calculates the ETH to refund based on the tokens sold and current price.
     */
    function calculateEthToRefund(
        uint256 tokensToSell,
        uint256 tokensSold,
        uint256 totalSupply,
        uint256 maxSupplyOfTokens
    ) external pure returns (uint256 ethToRefund);

    /**
     * @notice Calculates the allowable slippage based on the percentage of ETH collected.
     * @param totalSupply The current total supply of tokens.
     * @param maxSupplyOfTokens The maximum supply of tokens.
     * @return slippageFactor The calculated slippage factor in wei.
     * @dev
     * - Determines the slippage factor based on the percentage of tokens sold.
     * - Applies different slippage percentages for different sale phases.
     * - Ensures the slippage factor does not exceed the remaining supply.
     */
    function calculateSlippageCurvePercentage(
        uint256 totalSupply,
        uint256 maxSupplyOfTokens
    ) external pure returns (uint256 slippageFactor);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.20;

/**
 * @dev Required interface of an ERC-721 compliant contract.
 */
interface IERC721A {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
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
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC-721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or
     *   {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC-721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
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
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the address zero.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool approved) external;

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
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    function totalSupply() external view returns (uint256);
}
// SPDX-License-Identifier: MIT

/*
 *
 * All rights reserved. Property of Mintable PTE LTD.
 *
 */

pragma solidity ^0.8.0;
import "./iLogicLib.sol";
/**
 * @title IERC721exFactory
 * @dev Interface for the ERC721exFactory contract.
 *      It declares all the external and public functions available in the ERC721exFactory.
 */
interface IERC721exFactory {
    // ============================================
    // Structs
    // ============================================

    /**
     * @dev Struct to hold information about bonding pools.
     */
    struct BondingPools {
        address uniswapPool; // Address of the Uniswap pool
        uint256 liquidityTokenID; // Token ID representing the liquidity position
        uint256 poolId; // ID of the pool
        uint256 maxSupplyOfTokens; // Maximum supply of tokens in the pool
        address token0; // Address of token0 in the pool
        address token1; // Address of token1 in the pool
    }

    // ============================================
    // State Variables Getters
    // ============================================

    /**
     * @notice Template address for cloning NFT contracts.
     * @return The address of the ERC721ex template.
     */
    function ERC721exTemplate() external view returns (address);

    /**
     * @notice Template address for cloning NFT contracts without burn functionality.
     * @return The address of the ERC721exNoBurn template.
     */
    function ERC721exTemplateNoBurn() external view returns (address);

    /**
     * @notice Address of the bonding curve contract.
     * @return The address of the bonding curve contract.
     */
    function bondingCurveContract() external view returns (address);

    /**
     * @notice Address of the Logic Library.
     * @return The address of the Logic Library.
     */
    function LogicLibAddress() external view returns (address);

    /**
     * @notice Address of the Mintology Factory.
     * @return The address of the Mintology Factory.
     */
    function MintableFactoryAddress() external view returns (address);

    /**
     * @notice Counter for pool IDs.
     * @return The current pool ID.
     */
    function poolId() external view returns (uint256);

    /**
     * @notice Flag indicating if the contract is active.
     * @return A boolean representing the active state of the contract.
     */
    function isActive() external view returns (bool);

    /**
     * @notice Role identifier for ERC20 contracts.
     * @return The bytes32 identifier for the ERC20CONTRACT role.
     */
    function ERC20CONTRACT() external view returns (bytes32);

    /**
     * @notice Role identifier for the Logic Library.
     * @return The bytes32 identifier for the LOGICLIB role.
     */
    function LOGICLIB() external view returns (bytes32);

    /**
     * @notice Mapping from ERC20 contract address to its bonding pool information.
     * @param _erc20Contract The address of the ERC20 contract.
     * @return The BondingPools struct containing pool details.
     */
    function poolsMade(address _erc20Contract) external view returns (BondingPools memory);

    /**
     * @notice Mapping from ERC20 contract address to its associated NFT contract address.
     * @param _erc20Contract The address of the ERC20 contract.
     * @return The address of the associated NFT contract.
     */
    function ercContractToNFTContract(address _erc20Contract) external view returns (address);

    /**
     * @notice Mapping from NFT contract address to the deployer's address.
     * @param _nftContract The address of the NFT contract.
     * @return The address of the deployer.
     */
    function nftContractToDeployer(address _nftContract) external view returns (address);

    // ============================================
    // Events
    // ============================================

    /**
     * @dev Emitted when liquidity is added to a pool.
     */
    event LiquidityAdded(
        address indexed user,
        uint256 tokenId,
        uint128 liquidity,
        uint256 amountAActual,
        uint256 amountBActual
    );

    /**
     * @dev Emitted when liquidity is removed from a pool.
     */
    event LiquidityRemoved(uint256 tokenId, uint128 liquidity, uint256 amount0, uint256 amount1);

    /**
     * @dev Emitted when a new pool is created.
     */
    event PoolCreated(address indexed pool, address indexed tokenA, address indexed tokenB);

    /**
     * @dev Emitted when fees are collected from a liquidity position.
     */
    event FeesCollected(uint256 tokenId, uint256 amount0Collected, uint256 amount1Collected);

    /**
     * @dev Emitted when a withdrawal is made.
     */
    event Withdrawal(address account, uint256 amount);

    /**
     * @dev Emitted when a new ERC20 contract is created.
     */
    event ERC20Created(
        address indexed erc20Address,
        address indexed deployer,
        address nftContract,
        string symbol,
        uint256 maxSupplyTokens
    );

    // ============================================
    // Administrative Functions
    // ============================================

    /**
     * @notice Sets a new ERC721ex template address.
     * @param newDrip Address of the new ERC721ex template.
     * @param newDripNoBurn Address of the new ERC721exNoBurn template.
     */
    function setERC721ex(address newDrip, address newDripNoBurn) external;

    /**
     * @notice Sets a new bonding curve contract address.
     * @param _bondingCurveContract Address of the new bonding curve contract.
     */
    function setBondingCurveContract(address _bondingCurveContract) external;

    /**
     * @notice Toggles the active state of the contract.
     */
    function setContractActive() external;

    // ============================================
    // Contract Creation Functions
    // ============================================

    /**
     * @notice Creates a new ERC20 contract tied to an NFT contract.
     * @param name_ Name of the ERC20 token.
     * @param symbol_ Symbol of the ERC20 token.
     * @param nftContract Address of the NFT contract.
     * @param maxSupplyTokens Maximum supply of ERC20 tokens.
     * @param signature Signature validating the total supply.
     */
    function createContract(
        string calldata name_,
        string calldata symbol_,
        address nftContract,
        uint256 maxSupplyTokens,
        bytes calldata signature
    ) external payable;

    /**
     * @notice Creates a new ERC20 contract by a factory with an additional deployer parameter.
     * @param name_ Name of the ERC20 token.
     * @param symbol_ Symbol of the ERC20 token.
     * @param nftContract Address of the NFT contract.
     * @param maxSupplyTokens Maximum supply of ERC20 tokens.
     * @param deployer Address of the deployer.
     * @return bool indicating successful creation.
     */
    function createContractByFactory(
        string calldata name_,
        string calldata symbol_,
        address nftContract,
        uint256 maxSupplyTokens,
        address deployer
    ) external payable returns (bool);

    // ============================================
    // Pool Management Functions
    // ============================================

    /**
     * @notice Public function to add liquidity to a specified ERC20 contract's pool.
     * @param maxSupply Maximum supply of tokens for liquidity provisioning.
     * @param _NFTContract Address of the NFT contract.
     * @param _erc20Contract Address of the ERC20 contract.
     * @param poolSplit Boolean indicating whether to split the pool.
     * @return bool indicating successful addition of liquidity.
     */
    function UniswapAddLiquidity(
        uint256 maxSupply,
        address _NFTContract,
        address _erc20Contract,
        bool poolSplit
    ) external returns (bool);

    /**
     * @notice Retrieves the current price of the ERC20 token in the associated Uniswap pool.
     * @param _erc20Contract Address of the ERC20 contract.
     * @return price Current price of the ERC20 token.
     */
    function getCurrentPrice(address _erc20Contract) external view returns (uint256 price);

    // ============================================
    // Liquidity Management Functions
    // ============================================

    /**
     * @notice Removes 25% liquidity from the position and swaps the withdrawn ETH for tokens.
     * @param _erc20Contract The ERC20 contract address being referenced.
     * @return bool indicating successful liquidity removal and swap.
     */
    function removeAndSwapLiquidity(address _erc20Contract) external returns (bool);

    // ============================================
    // Fee Collection Function
    // ============================================

    /**
     * @notice Collects fees from a specific liquidity position.
     * @param _erc20Contract Address of the ERC20 contract associated with the pool.
     * @param tokenId Token ID of the liquidity position.
     * @return amount0Collected Amount of token0 collected as fees.
     * @return amount1Collected Amount of token1 collected as fees.
     */
    function collectFeesFromPosition(
        address _erc20Contract,
        uint256 tokenId
    ) external returns (uint256 amount0Collected, uint256 amount1Collected);

    // ============================================
    // Helper Functions
    // ============================================

    /**
     * @notice Allows the admin to withdraw all ETH from the contract to a specified account.
     * @param account Address to receive the withdrawn ETH.
     */
    function withdrawETH(address payable account) external;

    /**
     * @notice Withdraws ETH from test contracts associated with a specific NFT contract.
     * @param _nftContract Address of the NFT contract.
     */
    function withdrawFromTestContracts(address _nftContract) external;

    /**
     * @notice Transfers ERC20 tokens from the contract to a specified address.
     * @param tokenAddress Address of the ERC20 token.
     * @param to Address to receive the tokens.
     * @param amount Amount of tokens to transfer.
     */
    function transferERC20Tokens(address tokenAddress, address to, uint256 amount) external;

    /**
     * @notice Transfers an NFT from the factory to a specified address.
     * @param _NFTContract Address of the NFT contract.
     * @param to Address to receive the NFT.
     * @param _tokenID Token ID of the NFT.
     * @return bool indicating successful transfer.
     */
    function transferNFTFromFactory(address _NFTContract, address to, uint256 _tokenID) external returns (bool);
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);
}

interface IERC721 {
    function balanceOf(address owner) external view returns (uint256);

    function transferFrom(address from, address to, uint256 tokenId) external;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "./lib/Address.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```solidity
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 *
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that functions marked with `initializer` can be nested in the context of a
     * constructor.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!Address.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: setting the version to 255 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized != type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    /**
     * @dev Returns the highest version that has been initialized. See {reinitializer}.
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Returns `true` if the contract is currently initializing. See {onlyInitializing}.
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}
// SPDX-License-Identifier: MIT

/*
 *
 * All rights reserved. Property of Mintable PTE LTD.
 *
 */
pragma solidity ^0.8.0;

interface ILogicLib {
    enum VoteOption {
        PoolSplit,
        UniswapTrading,
        ToggleClaim,
        ToggleBurn
    }

    struct VotingOutcome {
        uint256 yesVotes; // Number of yes votes
        uint256 noVotes; // Number of no votes
        bool executed; // If the vote has been executed
    }
    struct Proposal {
        address proposer; // Address of the proposer
        uint256 voteStartTime; // Start time of the voting
        uint256 voteEndTime; // End time of the voting
        uint256 totalVotes; // Total number of votes cast
        uint256 id; // Proposal ID
        bool executed; // Whether the proposal has been executed
        bool isActive; // Whether the proposal is currently active
        VoteOption voteOption; // The type of vote proposed
    }

    event ProposalCreated(
        address indexed proposer,
        address indexed contractAddress,
        VoteOption voteOption,
        uint256 duration
    );
    event VoteSubmitted(address indexed contractAddress, VoteOption voteOption, address indexed voter, bool vote);
    event ActionExecuted(address indexed contractAddress, VoteOption voteOption);

    function registerFactory(address contractAddress) external;
    function registerContract(address contractAddress, uint256 _reservedTokens) external;
    function proposeVote(address contractAddress, VoteOption voteOption, uint256 duration) external;
    function submitVote(address contractAddress, bool vote, uint256 proposal_id, uint256 voteAmount) external;
    function executeAction(address contractAddress, uint256 proposal_id) external;
    function getVotingOutcome(
        address contractAddress,
        uint256 proposal_id
    ) external view returns (VotingOutcome memory);
    function setActionTargets(address contractAddress, address[] calldata targets) external;
    function removeDepositFromVote(uint256 proposal_id, address _voter) external;
    function isProposalActive(address contractAddress, uint256 proposalId) external view returns (bool);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}