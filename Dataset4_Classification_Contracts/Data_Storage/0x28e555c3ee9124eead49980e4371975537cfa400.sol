// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 *      _    _ _    _           _
 *     / \  | | | _(_)_ __ ___ (_)_   _  __ _
 *    / _ \ | | |/ / | '_ ` _ \| | | | |/ _` |
 *   / ___ \| |   <| | | | | | | | |_| | (_| |
 *  /_/   \_\_|_|\_\_|_| |_| |_|_|\__, |\__,_|
 *   ____ _____ ____   ___        |___/
 *  | __ )_   _/ ___| |_ _|_ __   __| | _____  __
 *  |  _ \ | || |      | || '_ \ / _` |/ _ \ \/ /
 *  | |_) || || |___   | || | | | (_| |  __/>  <
 *  |____/ |_| \____| |___|_| |_|\__,_|\___/_/\_\
 */
import {Ownable} from "@openzeppelin/access/Ownable.sol";
import {ISilicaIndex} from "../interfaces/ISilicaIndex.sol";
import {ECDSA} from "@openzeppelin/utils/cryptography/ECDSA.sol";
import {Ownable2Step} from "@openzeppelin/access/Ownable2Step.sol";
import {AccessControl} from "@openzeppelin/access/AccessControl.sol";

/// @title Silica BTC Fee Index Contract
/// @author Alkimiya
/// @notice Methods to provide an index pertaining to BTC Transaction Fees to the Silica Pools contract
contract BTCFeeIndex is ISilicaIndex, AccessControl, Ownable2Step {
    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/

    uint256 private _shares;
    uint256 private _balance;

    bytes32 private immutable _name;
    bytes32 private immutable _symbol;

    uint256 private immutable _decimals;
    address private immutable _balanceToken;

    event BTCFeeIndex__SharesUpdated(uint256 oldShares, uint256 newShares);
    event BTCFeeIndex__BalanceUpdated(uint256 oldBalance, uint256 newBalance);

    error BTCFeeIndex__InvalidShares(uint256 shares);
    error BTCFeeIndex__MathsError(uint256 valueChange);
    error BTCFeeIndex__InvalidSignature(bytes signature);
    error BTCFeeIndex__IncorrectHistoricalData(uint256 actualHistoricData);

    bytes32 public constant PUBLISHER_ROLE = keccak256("PUBLISHER_ROLE");
    bytes32 public constant CALCULATOR_ROLE = keccak256("CALCULATOR_ROLE");

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 shares_,
        uint256 balance_,
        uint256 decimals_,
        address publisher_,
        address calculator_,
        address balanceToken_
    ) Ownable(msg.sender) {
        require(bytes(name_).length > 0, "Name cannot be empty");
        require(bytes(symbol_).length > 0, "Symbol cannot be empty");
        require(bytes(name_).length <= 32, "Name cannot exceed 32 bytes");
        require(bytes(symbol_).length <= 32, "Symbol cannot exceed 32 bytes");
        require(shares_ > 0, "Index shares must be greater than zero");
        require(publisher_ != address(0), "Publisher cannot be zero address");
        require(calculator_ != address(0), "Calculator cannot be zero address");
        require(balanceToken_ != address(0), "Balance Token cannot be zero address");

        _name = bytes32(bytes(name_));
        _symbol = bytes32(bytes(symbol_));

        _shares = shares_;
        _balance = balance_;
        _decimals = decimals_;
        _balanceToken = balanceToken_;

        _grantRole(PUBLISHER_ROLE, publisher_);
        _grantRole(CALCULATOR_ROLE, calculator_);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);

        emit BTCFeeIndex__SharesUpdated(0, shares_);
        emit BTCFeeIndex__BalanceUpdated(0, balance_);
    }

    /*//////////////////////////////////////////////////////////////
                            OWNER FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @dev Grants `role` to `account`.
    /// @notice The caller must have ``role``'s admin role.
    /// If `account` had not been already granted `role`, emits {RoleGranted}event.
    function grantRole(bytes32 role, address account) public override onlyOwner {
        _grantRole(role, account);
    }

    /*//////////////////////////////////////////////////////////////
                     EXTERNAL PERMISSIONED FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Tracks the balance accumulated by the `shares()`.
    /// @param oldBalance The old balance.
    /// @param newBalance The new balance.
    /// @param balanceChange The change in balance.
    /// @dev This function is only callable by callers with publisher role.
    function setBalance(
        uint256 oldBalance,
        uint256 newBalance,
        uint256 balanceChange,
        uint256 expiry,
        bytes calldata signature
    ) external onlyRole(PUBLISHER_ROLE) {
        if (oldBalance != _balance) {
            revert BTCFeeIndex__IncorrectHistoricalData(_balance);
        }

        if (oldBalance >= newBalance) {
            if (balanceChange != oldBalance - newBalance) {
                revert BTCFeeIndex__MathsError(balanceChange);
            }
        } else if (oldBalance < newBalance) {
            if (balanceChange != newBalance - oldBalance) {
                revert BTCFeeIndex__MathsError(balanceChange);
            }
        }

        require(block.timestamp <= expiry, "signature expired");

        bytes32 calculatorMessageHash = keccak256(
            abi.encodePacked(
                "\x19Ethereum Signed Message:\n32",
                keccak256(abi.encode(0x01, oldBalance, newBalance, balanceChange, expiry))
            )
        );

        require(hasRole(CALCULATOR_ROLE, ECDSA.recover(calculatorMessageHash, signature)), "Invalid Signature");

        _balance = newBalance;
        emit BTCFeeIndex__BalanceUpdated(oldBalance, newBalance);
    }

    /// @notice Sets the number of shares (Size of the position tracked by this index)
    /// @param oldShares The old number of shares.
    /// @param newShares The new number of shares.
    /// @param sharesChange The change in shares.
    /// @dev This function is only callable by callers with publisher role.
    function setShares(uint256 oldShares, uint256 newShares, uint256 sharesChange, bytes calldata signature)
        external
        onlyRole(PUBLISHER_ROLE)
    {
        if (newShares == 0) {
            revert BTCFeeIndex__InvalidShares(newShares);
        }

        if (oldShares != _shares) {
            revert BTCFeeIndex__IncorrectHistoricalData(_shares);
        }

        if (oldShares >= newShares) {
            if (sharesChange != oldShares - newShares) {
                revert BTCFeeIndex__MathsError(sharesChange);
            }
        } else if (oldShares < newShares) {
            if (sharesChange != newShares - oldShares) {
                revert BTCFeeIndex__MathsError(sharesChange);
            }
        }

        bytes32 calculatorMessageHash =
            keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encode(newShares))));

        require(hasRole(CALCULATOR_ROLE, ECDSA.recover(calculatorMessageHash, signature)), "Invalid Signature");

        _shares = newShares;
        emit BTCFeeIndex__SharesUpdated(oldShares, newShares);
    }

    /*//////////////////////////////////////////////////////////////
                         EXTERNAL VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISilicaIndex
    function name() external view returns (string memory) {
        return string(abi.encodePacked(_name));
    }

    /// @inheritdoc ISilicaIndex
    function symbol() external view returns (string memory) {
        return string(abi.encodePacked(_symbol));
    }

    /// @inheritdoc ISilicaIndex
    function decimals() external view returns (uint256) {
        return _decimals;
    }

    /// @inheritdoc ISilicaIndex
    function shares() external view returns (uint256) {
        return _shares;
    }

    /// @inheritdoc ISilicaIndex
    function balanceToken() external view returns (address) {
        return _balanceToken;
    }

    /// @inheritdoc ISilicaIndex
    function balance() external view returns (uint256) {
        return _balance;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * _    _ _    _           _
 *     / \  | | | _(_)_ __ ___ (_)_   _  __ _
 *    / _ \ | | |/ / | '_ ` _ \| | | | |/ _` |
 *   / ___ \| |   <| | | | | | | | |_| | (_| |
 *  /_/_  \_\_|_|\_\_|_| |_| |_|_|\__, |\__,_|
 *  |_ _|_ __   __| | _____  __   |___/
 *   | || '_ \ / _` |/ _ \ \/ /
 *   | || | | | (_| |  __/>  <
 *  |___|_| |_|\__,_|\___/_/\_\
 */

/// @title Silica Index Protocol
/// @author Alkimiya
/// @notice Required methods for a contract to provide an index to Silica Pools
interface ISilicaIndex {
    /// @return A name suitable for display as a page title or heading.
    /// @custom:example "Bitcoin Mining Yield"
    /// @custom:example "Lido Staked Ethereum Yield"
    /// @custom:example "Gas Costs"
    /// @custom:since 0.1.0
    function name() external view returns (string memory);

    /// @return Short name of the display units of `shares()`.
    /// @custom:example "PH/s"
    /// @custom:example "ystETH"
    /// @custom:example "kgas"
    /// @custom:since 0.1.0
    function symbol() external view returns (string memory);

    /// @return Decimal offset of `symbol()` vs indivisible units of `shares()`.
    /// @custom:example If 1 `symbol()` (e.g. "PH/s") represents
    ///                 1e15 `shares()` (e.g. H/s)
    ///                 then `decimals()` should return 15.
    /// @custom:example If 1 `symbol()` (e.g. "ystETH") represents
    ///                 1e18 `shares()` (e.g. wei)
    ///                 then `decimals()` should return 18.
    /// @custom:example If 1 `symbol()` (e.g. "kgas") represents
    ///                 1e6 `shares()` (e.g. milligas per block)
    ///                 then `decimals()` should return 6.
    /// @custom:since 0.1.0
    function decimals() external view returns (uint256);

    /// @notice Size of the position tracked by this index.
    ///         Clients SHOULD NOT assume that this value is constant.
    ///         Clients SHOULD denominate pool shares in the same denomination
    ///         as `ISilicaIndex.shares()` (see: `symbol()`, `decimals()`).
    /// @custom:example 1e15 H/s.
    /// @custom:example `ILido.getPooledEthByShares(1 ether)` stETH wei.
    /// @custom:example 1e3 milligas per block
    /// @custom:since 0.1.0
    function shares() external view returns (uint256);

    /// @notice Clients MAY transact in any token which is pegged to
    ///         `balanceToken()`, as long as the `decimals()` match.
    ///         Clients SHOULD NOT transact in a token which is not pegged to
    ///         `balanceToken()`; the resulting financial contract will not
    ///         make sense.
    /// @custom:example 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599 (WBTC on mainnet)
    /// @custom:example 0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84 (stETH on mainnet)
    /// @custom:example 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2 (WETH on mainnet)
    /// @custom:since 0.1.0
    function balanceToken() external view returns (address);

    /// @return Tracks the balance accumulated by the `shares()`.
    /// @notice This is not required to increase over time.
    ///         Clients SHOULD have defensive programming against underflow
    ///         when taking `balance() - initialBalance`.
    /// @custom:example WBTC earned per PH/s since Jan 1, 2023.
    /// @custom:example `ILido.getPooledEthByShares(1 ether)` stETH.
    /// @custom:example Running cost to transact 1 gas every block since Jan 1, 2023.
    /// @custom:since 0.1.0
    function balance() external view returns (uint256);
}
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
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable2Step.sol)

pragma solidity ^0.8.20;

import {Ownable} from "./Ownable.sol";

/**
 * @dev Contract module which provides access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is specified at deployment time in the constructor for `Ownable`. This
 * can later be changed with {transferOwnership} and {acceptOwnership}.
 *
 * This module is used through inheritance. It will make available all functions
 * from parent (Ownable).
 */
abstract contract Ownable2Step is Ownable {
    address private _pendingOwner;

    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Returns the address of the pending owner.
     */
    function pendingOwner() public view virtual returns (address) {
        return _pendingOwner;
    }

    /**
     * @dev Starts the ownership transfer of the contract to a new account. Replaces the pending transfer if there is one.
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual override onlyOwner {
        _pendingOwner = newOwner;
        emit OwnershipTransferStarted(owner(), newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`) and deletes any pending owner.
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual override {
        delete _pendingOwner;
        super._transferOwnership(newOwner);
    }

    /**
     * @dev The new owner accepts the ownership transfer.
     */
    function acceptOwnership() public virtual {
        address sender = _msgSender();
        if (pendingOwner() != sender) {
            revert OwnableUnauthorizedAccount(sender);
        }
        _transferOwnership(sender);
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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.20;

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS
    }

    /**
     * @dev The signature derives the `address(0)`.
     */
    error ECDSAInvalidSignature();

    /**
     * @dev The signature has an invalid length.
     */
    error ECDSAInvalidSignatureLength(uint256 length);

    /**
     * @dev The signature has an S value that is in the upper half order.
     */
    error ECDSAInvalidSignatureS(bytes32 s);

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with `signature` or an error. This will not
     * return address(0) without also returning an error description. Errors are documented using an enum (error type)
     * and a bytes32 providing additional information about the error.
     *
     * If no error is returned, then the address can be used for verification purposes.
     *
     * The `ecrecover` EVM precompile allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {MessageHashUtils-toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError, bytes32) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength, bytes32(signature.length));
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM precompile allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {MessageHashUtils-toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, signature);
        _throwError(error, errorArg);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     */
    function tryRecover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address, RecoverError, bytes32) {
        unchecked {
            bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
            // We do not check for an overflow here since the shift operation results in 0 or 1.
            uint8 v = uint8((uint256(vs) >> 255) + 27);
            return tryRecover(hash, v, r, s);
        }
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     */
    function recover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address) {
        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, r, vs);
        _throwError(error, errorArg);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError, bytes32) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS, s);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature, bytes32(0));
        }

        return (signer, RecoverError.NoError, bytes32(0));
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, v, r, s);
        _throwError(error, errorArg);
        return recovered;
    }

    /**
     * @dev Optionally reverts with the corresponding custom error according to the `error` argument provided.
     */
    function _throwError(RecoverError error, bytes32 errorArg) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert ECDSAInvalidSignature();
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert ECDSAInvalidSignatureLength(uint256(errorArg));
        } else if (error == RecoverError.InvalidSignatureS) {
            revert ECDSAInvalidSignatureS(errorArg);
        }
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