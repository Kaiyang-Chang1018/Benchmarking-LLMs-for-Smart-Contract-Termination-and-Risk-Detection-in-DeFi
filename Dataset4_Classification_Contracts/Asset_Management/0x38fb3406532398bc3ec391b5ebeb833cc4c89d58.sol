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
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * The default value of {decimals} is 18. To change this, you should override
 * this function so it returns a different value.
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.4) (utils/Context.sol)

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

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

/// @author thirdweb

import "./interface/IContractMetadata.sol";

/**
 *  @title   Contract Metadata
 *  @notice  Thirdweb's `ContractMetadata` is a contract extension for any base contracts. It lets you set a metadata URI
 *           for you contract.
 *           Additionally, `ContractMetadata` is necessary for NFT contracts that want royalties to get distributed on OpenSea.
 */

abstract contract ContractMetadata is IContractMetadata {
    /// @dev The sender is not authorized to perform the action
    error ContractMetadataUnauthorized();

    /// @notice Returns the contract metadata URI.
    string public override contractURI;

    /**
     *  @notice         Lets a contract admin set the URI for contract-level metadata.
     *  @dev            Caller should be authorized to setup contractURI, e.g. contract admin.
     *                  See {_canSetContractURI}.
     *                  Emits {ContractURIUpdated Event}.
     *
     *  @param _uri     keccak256 hash of the role. e.g. keccak256("TRANSFER_ROLE")
     */
    function setContractURI(string memory _uri) external override {
        if (!_canSetContractURI()) {
            revert ContractMetadataUnauthorized();
        }

        _setupContractURI(_uri);
    }

    /// @dev Lets a contract admin set the URI for contract-level metadata.
    function _setupContractURI(string memory _uri) internal {
        string memory prevURI = contractURI;
        contractURI = _uri;

        emit ContractURIUpdated(prevURI, _uri);
    }

    /// @dev Returns whether contract metadata can be set in the given execution context.
    function _canSetContractURI() internal view virtual returns (bool);
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

/// @author thirdweb

import "./interface/IPermissions.sol";
import "@thirdweb-dev/contracts/lib/Strings.sol";

/**
 *  @title   Permissions
 *  @dev     This contracts provides extending-contracts with role-based access control mechanisms
 */
contract Permissions is IPermissions {
    /// @dev The `account` is missing a role.
    error PermissionsUnauthorizedAccount(address account, bytes32 neededRole);

    /// @dev The `account` already is a holder of `role`
    error PermissionsAlreadyGranted(address account, bytes32 role);

    /// @dev Invalid priviledge to revoke
    error PermissionsInvalidPermission(address expected, address actual);

    /// @dev Map from keccak256 hash of a role => a map from address => whether address has role.
    mapping(bytes32 => mapping(address => bool)) private _hasRole;

    /// @dev Map from keccak256 hash of a role to role admin. See {getRoleAdmin}.
    mapping(bytes32 => bytes32) private _getRoleAdmin;

    /// @dev Default admin role for all roles. Only accounts with this role can grant/revoke other roles.
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /// @dev Modifier that checks if an account has the specified role; reverts otherwise.
    modifier onlyRole(bytes32 role) {
        _checkRole(role, msg.sender);
        _;
    }

    /**
     *  @notice         Checks whether an account has a particular role.
     *  @dev            Returns `true` if `account` has been granted `role`.
     *
     *  @param role     keccak256 hash of the role. e.g. keccak256("TRANSFER_ROLE")
     *  @param account  Address of the account for which the role is being checked.
     */
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _hasRole[role][account];
    }

    /**
     *  @notice         Checks whether an account has a particular role;
     *                  role restrictions can be swtiched on and off.
     *
     *  @dev            Returns `true` if `account` has been granted `role`.
     *                  Role restrictions can be swtiched on and off:
     *                      - If address(0) has ROLE, then the ROLE restrictions
     *                        don't apply.
     *                      - If address(0) does not have ROLE, then the ROLE
     *                        restrictions will apply.
     *
     *  @param role     keccak256 hash of the role. e.g. keccak256("TRANSFER_ROLE")
     *  @param account  Address of the account for which the role is being checked.
     */
    function hasRoleWithSwitch(bytes32 role, address account) public view returns (bool) {
        if (!_hasRole[role][address(0)]) {
            return _hasRole[role][account];
        }

        return true;
    }

    /**
     *  @notice         Returns the admin role that controls the specified role.
     *  @dev            See {grantRole} and {revokeRole}.
     *                  To change a role's admin, use {_setRoleAdmin}.
     *
     *  @param role     keccak256 hash of the role. e.g. keccak256("TRANSFER_ROLE")
     */
    function getRoleAdmin(bytes32 role) external view override returns (bytes32) {
        return _getRoleAdmin[role];
    }

    /**
     *  @notice         Grants a role to an account, if not previously granted.
     *  @dev            Caller must have admin role for the `role`.
     *                  Emits {RoleGranted Event}.
     *
     *  @param role     keccak256 hash of the role. e.g. keccak256("TRANSFER_ROLE")
     *  @param account  Address of the account to which the role is being granted.
     */
    function grantRole(bytes32 role, address account) public virtual override {
        _checkRole(_getRoleAdmin[role], msg.sender);
        if (_hasRole[role][account]) {
            revert PermissionsAlreadyGranted(account, role);
        }
        _setupRole(role, account);
    }

    /**
     *  @notice         Revokes role from an account.
     *  @dev            Caller must have admin role for the `role`.
     *                  Emits {RoleRevoked Event}.
     *
     *  @param role     keccak256 hash of the role. e.g. keccak256("TRANSFER_ROLE")
     *  @param account  Address of the account from which the role is being revoked.
     */
    function revokeRole(bytes32 role, address account) public virtual override {
        _checkRole(_getRoleAdmin[role], msg.sender);
        _revokeRole(role, account);
    }

    /**
     *  @notice         Revokes role from the account.
     *  @dev            Caller must have the `role`, with caller being the same as `account`.
     *                  Emits {RoleRevoked Event}.
     *
     *  @param role     keccak256 hash of the role. e.g. keccak256("TRANSFER_ROLE")
     *  @param account  Address of the account from which the role is being revoked.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        if (msg.sender != account) {
            revert PermissionsInvalidPermission(msg.sender, account);
        }
        _revokeRole(role, account);
    }

    /// @dev Sets `adminRole` as `role`'s admin role.
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = _getRoleAdmin[role];
        _getRoleAdmin[role] = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /// @dev Sets up `role` for `account`
    function _setupRole(bytes32 role, address account) internal virtual {
        _hasRole[role][account] = true;
        emit RoleGranted(role, account, msg.sender);
    }

    /// @dev Revokes `role` from `account`
    function _revokeRole(bytes32 role, address account) internal virtual {
        _checkRole(role, account);
        delete _hasRole[role][account];
        emit RoleRevoked(role, account, msg.sender);
    }

    /// @dev Checks `role` for `account`. Reverts with a message including the required role.
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!_hasRole[role][account]) {
            revert PermissionsUnauthorizedAccount(account, role);
        }
    }

    /// @dev Checks `role` for `account`. Reverts with a message including the required role.
    function _checkRoleWithSwitch(bytes32 role, address account) internal view virtual {
        if (!hasRoleWithSwitch(role, account)) {
            revert PermissionsUnauthorizedAccount(account, role);
        }
    }
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

/// @author thirdweb

import "./interface/IPermissionsEnumerable.sol";
import "./Permissions.sol";

/**
 *  @title   PermissionsEnumerable
 *  @dev     This contracts provides extending-contracts with role-based access control mechanisms.
 *           Also provides interfaces to view all members with a given role, and total count of members.
 */
contract PermissionsEnumerable is IPermissionsEnumerable, Permissions {
    /**
     *  @notice A data structure to store data of members for a given role.
     *
     *  @param index    Current index in the list of accounts that have a role.
     *  @param members  map from index => address of account that has a role
     *  @param indexOf  map from address => index which the account has.
     */
    struct RoleMembers {
        uint256 index;
        mapping(uint256 => address) members;
        mapping(address => uint256) indexOf;
    }

    /// @dev map from keccak256 hash of a role to its members' data. See {RoleMembers}.
    mapping(bytes32 => RoleMembers) private roleMembers;

    /**
     *  @notice         Returns the role-member from a list of members for a role,
     *                  at a given index.
     *  @dev            Returns `member` who has `role`, at `index` of role-members list.
     *                  See struct {RoleMembers}, and mapping {roleMembers}
     *
     *  @param role     keccak256 hash of the role. e.g. keccak256("TRANSFER_ROLE")
     *  @param index    Index in list of current members for the role.
     *
     *  @return member  Address of account that has `role`
     */
    function getRoleMember(bytes32 role, uint256 index) external view override returns (address member) {
        uint256 currentIndex = roleMembers[role].index;
        uint256 check;

        for (uint256 i = 0; i < currentIndex; i += 1) {
            if (roleMembers[role].members[i] != address(0)) {
                if (check == index) {
                    member = roleMembers[role].members[i];
                    return member;
                }
                check += 1;
            } else if (hasRole(role, address(0)) && i == roleMembers[role].indexOf[address(0)]) {
                check += 1;
            }
        }
    }

    /**
     *  @notice         Returns total number of accounts that have a role.
     *  @dev            Returns `count` of accounts that have `role`.
     *                  See struct {RoleMembers}, and mapping {roleMembers}
     *
     *  @param role     keccak256 hash of the role. e.g. keccak256("TRANSFER_ROLE")
     *
     *  @return count   Total number of accounts that have `role`
     */
    function getRoleMemberCount(bytes32 role) external view override returns (uint256 count) {
        uint256 currentIndex = roleMembers[role].index;

        for (uint256 i = 0; i < currentIndex; i += 1) {
            if (roleMembers[role].members[i] != address(0)) {
                count += 1;
            }
        }
        if (hasRole(role, address(0))) {
            count += 1;
        }
    }

    /// @dev Revokes `role` from `account`, and removes `account` from {roleMembers}
    ///      See {_removeMember}
    function _revokeRole(bytes32 role, address account) internal override {
        super._revokeRole(role, account);
        _removeMember(role, account);
    }

    /// @dev Grants `role` to `account`, and adds `account` to {roleMembers}
    ///      See {_addMember}
    function _setupRole(bytes32 role, address account) internal override {
        super._setupRole(role, account);
        _addMember(role, account);
    }

    /// @dev adds `account` to {roleMembers}, for `role`
    function _addMember(bytes32 role, address account) internal {
        uint256 idx = roleMembers[role].index;
        roleMembers[role].index += 1;

        roleMembers[role].members[idx] = account;
        roleMembers[role].indexOf[account] = idx;
    }

    /// @dev removes `account` from {roleMembers}, for `role`
    function _removeMember(bytes32 role, address account) internal {
        uint256 idx = roleMembers[role].indexOf[account];

        delete roleMembers[role].members[idx];
        delete roleMembers[role].indexOf[account];
    }
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

/// @author thirdweb

/**
 *  Thirdweb's `ContractMetadata` is a contract extension for any base contracts. It lets you set a metadata URI
 *  for you contract.
 *
 *  Additionally, `ContractMetadata` is necessary for NFT contracts that want royalties to get distributed on OpenSea.
 */

interface IContractMetadata {
    /// @dev Returns the metadata URI of the contract.
    function contractURI() external view returns (string memory);

    /**
     *  @dev Sets contract URI for the storefront-level metadata of the contract.
     *       Only module admin can call this function.
     */
    function setContractURI(string calldata _uri) external;

    /// @dev Emitted when the contract URI is updated.
    event ContractURIUpdated(string prevURI, string newURI);
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

/// @author thirdweb

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IPermissions {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
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
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

/// @author thirdweb

import "./IPermissions.sol";

/**
 * @dev External interface of AccessControlEnumerable declared to support ERC165 detection.
 */
interface IPermissionsEnumerable is IPermissions {
    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * [forum post](https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296)
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) external view returns (address);

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) external view returns (uint256);
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

/// @author thirdweb

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /// @dev Returns the hexadecimal representation of `value`.
    /// The output is prefixed with "0x", encoded using 2 hexadecimal digits per byte,
    /// and the alphabets are capitalized conditionally according to
    /// https://eips.ethereum.org/EIPS/eip-55
    function toHexStringChecksummed(address value) internal pure returns (string memory str) {
        str = toHexString(value);
        /// @solidity memory-safe-assembly
        assembly {
            let mask := shl(6, div(not(0), 255)) // `0b010000000100000000 ...`
            let o := add(str, 0x22)
            let hashed := and(keccak256(o, 40), mul(34, mask)) // `0b10001000 ... `
            let t := shl(240, 136) // `0b10001000 << 240`
            for {
                let i := 0
            } 1 {

            } {
                mstore(add(i, i), mul(t, byte(i, hashed)))
                i := add(i, 1)
                if eq(i, 20) {
                    break
                }
            }
            mstore(o, xor(mload(o), shr(1, and(mload(0x00), and(mload(o), mask)))))
            o := add(o, 0x20)
            mstore(o, xor(mload(o), shr(1, and(mload(0x20), and(mload(o), mask)))))
        }
    }

    /// @dev Returns the hexadecimal representation of `value`.
    /// The output is prefixed with "0x" and encoded using 2 hexadecimal digits per byte.
    function toHexString(address value) internal pure returns (string memory str) {
        str = toHexStringNoPrefix(value);
        /// @solidity memory-safe-assembly
        assembly {
            let strLength := add(mload(str), 2) // Compute the length.
            mstore(str, 0x3078) // Write the "0x" prefix.
            str := sub(str, 2) // Move the pointer.
            mstore(str, strLength) // Write the length.
        }
    }

    /// @dev Returns the hexadecimal representation of `value`.
    /// The output is encoded using 2 hexadecimal digits per byte.
    function toHexStringNoPrefix(address value) internal pure returns (string memory str) {
        /// @solidity memory-safe-assembly
        assembly {
            str := mload(0x40)

            // Allocate the memory.
            // We need 0x20 bytes for the trailing zeros padding, 0x20 bytes for the length,
            // 0x02 bytes for the prefix, and 0x28 bytes for the digits.
            // The next multiple of 0x20 above (0x20 + 0x20 + 0x02 + 0x28) is 0x80.
            mstore(0x40, add(str, 0x80))

            // Store "0123456789abcdef" in scratch space.
            mstore(0x0f, 0x30313233343536373839616263646566)

            str := add(str, 2)
            mstore(str, 40)

            let o := add(str, 0x20)
            mstore(add(o, 40), 0)

            value := shl(96, value)

            // We write the string from rightmost digit to leftmost digit.
            // The following is essentially a do-while loop that also handles the zero case.
            for {
                let i := 0
            } 1 {

            } {
                let p := add(o, add(i, i))
                let temp := byte(i, value)
                mstore8(add(p, 1), mload(and(temp, 15)))
                mstore8(p, mload(shr(4, temp)))
                i := add(i, 1)
                if eq(i, 20) {
                    break
                }
            }
        }
    }

    /// @dev Returns the hex encoded string from the raw bytes.
    /// The output is encoded using 2 hexadecimal digits per byte.
    function toHexString(bytes memory raw) internal pure returns (string memory str) {
        str = toHexStringNoPrefix(raw);
        /// @solidity memory-safe-assembly
        assembly {
            let strLength := add(mload(str), 2) // Compute the length.
            mstore(str, 0x3078) // Write the "0x" prefix.
            str := sub(str, 2) // Move the pointer.
            mstore(str, strLength) // Write the length.
        }
    }

    /// @dev Returns the hex encoded string from the raw bytes.
    /// The output is encoded using 2 hexadecimal digits per byte.
    function toHexStringNoPrefix(bytes memory raw) internal pure returns (string memory str) {
        /// @solidity memory-safe-assembly
        assembly {
            let length := mload(raw)
            str := add(mload(0x40), 2) // Skip 2 bytes for the optional prefix.
            mstore(str, add(length, length)) // Store the length of the output.

            // Store "0123456789abcdef" in scratch space.
            mstore(0x0f, 0x30313233343536373839616263646566)

            let o := add(str, 0x20)
            let end := add(raw, length)

            for {

            } iszero(eq(raw, end)) {

            } {
                raw := add(raw, 1)
                mstore8(add(o, 1), mload(and(mload(raw), 15)))
                mstore8(o, mload(and(shr(4, mload(raw)), 15)))
                o := add(o, 2)
            }
            mstore(o, 0) // Zeroize the slot after the string.
            mstore(0x40, add(o, 0x20)) // Allocate the memory.
        }
    }
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.11;

// Tokens
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// Security
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@thirdweb-dev/contracts/extension/PermissionsEnumerable.sol";

// Utils
import "@thirdweb-dev/contracts/extension/ContractMetadata.sol";

/**
 * @author  @GrahamBellscoin / @VaultedLabs
 */
contract VaultedToken is
    ERC20,
    ReentrancyGuard,
    PermissionsEnumerable,
    ContractMetadata
{
    bytes32 internal constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 internal constant TRANSFER_ROLE = keccak256("TRANSFER_ROLE");

    address public televaultBroker;

    event TokensIssued(address toAddress, uint256 tokensIssuedAmount);
    event TokensBurned(uint256 tokensBurnedAmount);
    event BrokerAddressSet(address brokerAddress);

    constructor(
        address _initialAdmin,
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol) {
        // Set initial roles for deployer
        _setupRole(DEFAULT_ADMIN_ROLE, _initialAdmin);
        _setupRole(TRANSFER_ROLE, _initialAdmin);
        _setupRole(TRANSFER_ROLE, address(0));
    }

    /// @dev Runs after every transfer.
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override(ERC20) {
        super._afterTokenTransfer(from, to, amount);
        
        // Burn tokens if they are sent to the Broker address
        if (to == televaultBroker) {
          emit TokensBurned(amount); 
          _burn(televaultBroker, amount);
        }
    }

    /// @dev Runs on every transfer.
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override {
        super._beforeTokenTransfer(from, to, amount);

        if (!hasRole(TRANSFER_ROLE, address(0)) && from != address(0) && to != address(0)) {
            require(hasRole(TRANSFER_ROLE, from) || hasRole(TRANSFER_ROLE, to), "transfers restricted.");
        }
    }

    function _mint(address account, uint256 amount) internal virtual override(ERC20) {
        super._mint(account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual override(ERC20) {
        super._burn(account, amount);
    }

    /**
     * @dev Creates `amount` new tokens for `to`.
     *
     * See {ERC20-_mint}.
     *
     * Requirements:
     *
     * - the caller must have the `MINTER_ROLE`.
     */
    function mintTo(address to, uint256 amount) public virtual nonReentrant {
        require(hasRole(MINTER_ROLE, _msgSender()), "not minter.");
        emit TokensIssued(to, amount);
        _mintTo(to, amount);
    }

    /// @dev Mints `amount` of tokens to `to`
    function _mintTo(address _to, uint256 _amount) internal {
        _mint(_to, _amount);
    }

    /// @dev Sets the Televault Broker address `_brokerAddress`
    function setBroker(address _brokerAddress) external {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "not admin.");
        televaultBroker = _brokerAddress;
        _setupRole(MINTER_ROLE, televaultBroker);
        emit BrokerAddressSet(televaultBroker);
    }

    /// @dev Checks whether contract metadata can be set in the given execution context.
    function _canSetContractURI() internal view override returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }
    
}