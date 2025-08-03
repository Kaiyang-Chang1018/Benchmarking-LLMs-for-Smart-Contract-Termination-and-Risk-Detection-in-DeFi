// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4; // custom errors (0.8.4)

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * @title Initializable Role-based Access Control Core (I-RBAC-C)
 *
 * @notice Access control smart contract provides an API to check
 *      if a specific operation is permitted globally and/or
 *      if a particular user has a permission to execute it.
 *
 * @notice This contract is inherited by other contracts requiring the role-based access control (RBAC)
 *      protection for the restricted access functions
 *
 * @notice It deals with two main entities: features and roles.
 *
 * @notice Features are designed to be used to enable/disable public functions
 *      of the smart contract (used by a wide audience).
 * @notice User roles are designed to control the access to restricted functions
 *      of the smart contract (used by a limited set of maintainers).
 *
 * @notice Terms "role", "permissions" and "set of permissions" have equal meaning
 *      in the documentation text and may be used interchangeably.
 * @notice Terms "permission", "single permission" implies only one permission bit set.
 *
 * @notice Access manager is a special role which allows to grant/revoke other roles.
 *      Access managers can only grant/revoke permissions which they have themselves.
 *      As an example, access manager with no other roles set can only grant/revoke its own
 *      access manager permission and nothing else.
 *
 * @notice Access manager permission should be treated carefully, as a super admin permission:
 *      Access manager with even no other permission can interfere with another account by
 *      granting own access manager permission to it and effectively creating more powerful
 *      permission set than its own.
 *
 * @dev Both current and OpenZeppelin AccessControl implementations feature a similar API
 *      to check/know "who is allowed to do this thing".
 * @dev Zeppelin implementation is more flexible:
 *      - it allows setting unlimited number of roles, while current is limited to 256 different roles
 *      - it allows setting an admin for each role, while current allows having only one global admin
 * @dev Current implementation is more lightweight:
 *      - it uses only 1 bit per role, while Zeppelin uses 256 bits
 *      - it allows setting up to 256 roles at once, in a single transaction, while Zeppelin allows
 *        setting only one role in a single transaction
 *
 * @dev This smart contract is designed to be inherited by other
 *      smart contracts which require access control management capabilities.
 *
 * @dev Access manager permission has a bit 255 set.
 *      This bit must not be used by inheriting contracts for any other permissions/features.
 *
 * @dev This is an initializable version of the RBAC, based on Zeppelin implementation,
 *      it can be used for EIP-1167 minimal proxies, for ERC1967 proxies, etc.
 *      see https://docs.openzeppelin.com/contracts/4.x/api/proxy#Clones
 *      see https://docs.openzeppelin.com/contracts/4.x/upgradeable
 *      see https://docs.openzeppelin.com/contracts/4.x/api/proxy#UUPSUpgradeable
 *      see https://forum.openzeppelin.com/t/uups-proxies-tutorial-solidity-javascript/7786
 *      see https://eips.ethereum.org/EIPS/eip-1167
 *
 * @dev The 'core' version of the RBAC contract hides three rarely used external functions from the public ABI,
 *      making them internal and thus reducing the overall compiled implementation size.
 *      isFeatureEnabled() public -> _isFeatureEnabled() internal
 *      isSenderInRole() public -> _isSenderInRole() internal
 *      isOperatorInRole() public -> _isOperatorInRole() internal
 *
 * @custom:since 1.1.0
 *
 * @author Basil Gorin
 */
abstract contract InitializableAccessControlCore is Initializable {
	/**
	 * @dev Privileged addresses with defined roles/permissions
	 * @dev In the context of ERC20/ERC721 tokens these can be permissions to
	 *      allow minting or burning tokens, transferring on behalf and so on
	 *
	 * @dev Maps user address to the permissions bitmask (role), where each bit
	 *      represents a permission
	 * @dev Bitmask 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
	 *      represents all possible permissions
	 * @dev 'This' address mapping represents global features of the smart contract
	 *
	 * @dev We keep the mapping private to prevent direct writes to it from the inheriting
	 *      contracts, `getRole()` and `updateRole()` functions should be used instead
	 */
	mapping(address => uint256) private userRoles;

	/**
	 * @dev Empty reserved space in storage. The size of the __gap array is calculated so that
	 *      the amount of storage used by a contract always adds up to the 50.
	 *      See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
	 */
	uint256[49] private __gap;

	/**
	 * @notice Access manager is responsible for assigning the roles to users,
	 *      enabling/disabling global features of the smart contract
	 * @notice Access manager can add, remove and update user roles,
	 *      remove and update global features
	 *
	 * @dev Role ROLE_ACCESS_MANAGER allows modifying user roles and global features
	 * @dev Role ROLE_ACCESS_MANAGER has single bit at position 255 enabled
	 */
	uint256 public constant ROLE_ACCESS_MANAGER = 0x8000000000000000000000000000000000000000000000000000000000000000;

	/**
	 * @notice Upgrade manager is responsible for smart contract upgrades,
	 *      see https://docs.openzeppelin.com/contracts/4.x/api/proxy#UUPSUpgradeable
	 *      see https://docs.openzeppelin.com/contracts/4.x/upgradeable
	 *
	 * @dev Role ROLE_UPGRADE_MANAGER allows passing the _authorizeUpgrade() check
	 * @dev Role ROLE_UPGRADE_MANAGER has single bit at position 254 enabled
	 */
	uint256 public constant ROLE_UPGRADE_MANAGER = 0x4000000000000000000000000000000000000000000000000000000000000000;

	/**
	 * @dev Bitmask representing all the possible permissions (super admin role)
	 * @dev Has all the bits are enabled (2^256 - 1 value)
	 */
	uint256 internal constant FULL_PRIVILEGES_MASK = type(uint256).max; // before 0.8.0: uint256(-1) overflows to 0xFFFF...

	/**
	 * @notice Thrown when a function is executed by an account that does not have
	 *      the required access permission(s) (role)
	 *
	 * @dev This error is used to enforce role-based access control (RBAC) restrictions
	 */
	error AccessDenied();

	/**
	 * @dev Fired in updateRole() and updateFeatures()
	 *
	 * @param operator address which was granted/revoked permissions
	 * @param requested permissions requested
	 * @param assigned permissions effectively set
	 */
	event RoleUpdated(address indexed operator, uint256 requested, uint256 assigned);

	/**
	 * @notice Function modifier making a function defined as public behave as restricted
	 *      (so that only a pre-configured set of accounts can execute it)
	 *
	 * @param role the role transaction executor is required to have;
	 *      the function throws an "access denied" exception if this condition is not met
	 */
	modifier restrictedTo(uint256 role) {
		// verify the access permission
		_requireSenderInRole(role);

		// execute the rest of the function
		_;
	}

	/**
	 * @dev Creates/deploys the RBAC implementation to be used in a proxy
	 *
	 * @dev Note:
	 *      the implementation is already initialized and
	 *      `_postConstruct` is not executable on the implementation
	 *      `_postConstruct` is still available in the context of a proxy
	 *      and should be executed on the proxy deployment (in the same tx)
	 */
	constructor() initializer {}

	/**
	 * @dev Contract initializer, sets the contract owner to have full privileges
	 *
	 * @dev Can be executed only once, reverts when executed second time
	 *
	 * @dev IMPORTANT:
	 *      this function SHOULD be executed during proxy deployment (in the same transaction)
	 *
	 * @param _owner smart contract owner having full privileges, can be zero
	 * @param _features initial features mask of the contract, can be zero
	 */
	function _postConstruct(address _owner, uint256 _features) internal virtual onlyInitializing {
		// grant owner full privileges
		__setRole(_owner, FULL_PRIVILEGES_MASK, FULL_PRIVILEGES_MASK);
		// update initial features bitmask
		__setRole(address(this), _features, _features);
	}

	/**
	 * @dev Highest version that has been initialized.
	 *      Non-zero value means contract was already initialized.
	 * @dev see {Initializable}, {reinitializer}.
	 *
	 * @return highest version that has been initialized
	 */
	function getInitializedVersion() public view returns(uint64) {
		// delegate to `_getInitializedVersion`
		return _getInitializedVersion();
	}

	/**
	 * @notice Retrieves globally set of features enabled
	 *
	 * @dev Effectively reads userRoles role for the contract itself
	 *
	 * @return 256-bit bitmask of the features enabled
	 */
	function features() public view returns (uint256) {
		// features are stored in 'this' address mapping of `userRoles`
		return getRole(address(this));
	}

	/**
	 * @notice Updates set of the globally enabled features (`features`),
	 *      taking into account sender's permissions
	 *
	 * @dev Requires transaction sender to have `ROLE_ACCESS_MANAGER` permission
	 * @dev Function is left for backward compatibility with older versions
	 *
	 * @param _mask bitmask representing a set of features to enable/disable
	 */
	function updateFeatures(uint256 _mask) public {
		// delegate call to `updateRole`
		updateRole(address(this), _mask);
	}

	/**
	 * @notice Reads the permissions (role) for a given user from the `userRoles` mapping
	 *      (privileged addresses with defined roles/permissions)
	 * @notice In the context of ERC20/ERC721 tokens these can be permissions to
	 *      allow minting or burning tokens, transferring on behalf and so on
	 *
	 * @dev Having a simple getter instead of making the mapping public
	 *      allows enforcing the encapsulation of the mapping and protects from
	 *      writing to it directly in the inheriting smart contracts
	 *
	 * @param operator address of a user to read permissions for,
	 *      or self address to read global features of the smart contract
	 */
	function getRole(address operator) public view returns(uint256) {
		// read the value from `userRoles` and return
		return userRoles[operator];
	}

	/**
	 * @notice Updates set of permissions (role) for a given user,
	 *      taking into account sender's permissions.
	 *
	 * @dev Setting role to zero is equivalent to removing an all permissions
	 * @dev Setting role to `FULL_PRIVILEGES_MASK` is equivalent to
	 *      copying senders' permissions (role) to the user
	 * @dev Requires transaction sender to have `ROLE_ACCESS_MANAGER` permission
	 *
	 * @param operator address of a user to alter permissions for,
	 *       or self address to alter global features of the smart contract
	 * @param role bitmask representing a set of permissions to
	 *      enable/disable for a user specified
	 */
	function updateRole(address operator, uint256 role) public {
		// caller must have a permission to update user roles
		_requireSenderInRole(ROLE_ACCESS_MANAGER);

		// evaluate the role and reassign it
		__setRole(operator, role, _evaluateBy(msg.sender, getRole(operator), role));
	}

	/**
	 * @notice Determines the permission bitmask an operator can set on the
	 *      target permission set
	 * @notice Used to calculate the permission bitmask to be set when requested
	 *     in `updateRole` and `updateFeatures` functions
	 *
	 * @dev Calculated based on:
	 *      1) operator's own permission set read from userRoles[operator]
	 *      2) target permission set - what is already set on the target
	 *      3) desired permission set - what do we want set target to
	 *
	 * @dev Corner cases:
	 *      1) Operator is super admin and its permission set is `FULL_PRIVILEGES_MASK`:
	 *        `desired` bitset is returned regardless of the `target` permission set value
	 *        (what operator sets is what they get)
	 *      2) Operator with no permissions (zero bitset):
	 *        `target` bitset is returned regardless of the `desired` value
	 *        (operator has no authority and cannot modify anything)
	 *
	 * @dev Example:
	 *      Consider an operator with the permissions bitmask     00001111
	 *      is about to modify the target permission set          01010101
	 *      Operator wants to set that permission set to          00110011
	 *      Based on their role, an operator has the permissions
	 *      to update only lowest 4 bits on the target, meaning that
	 *      high 4 bits of the target set in this example is left
	 *      unchanged and low 4 bits get changed as desired:      01010011
	 *
	 * @param operator address of the contract operator which is about to set the permissions
	 * @param target input set of permissions to operator is going to modify
	 * @param desired desired set of permissions operator would like to set
	 * @return resulting set of permissions given operator will set
	 */
	function _evaluateBy(address operator, uint256 target, uint256 desired) internal view returns (uint256) {
		// read operator's permissions
		uint256 p = getRole(operator);

		// taking into account operator's permissions,
		// 1) enable the permissions desired on the `target`
		target |= p & desired;
		// 2) disable the permissions desired on the `target`
		target &= FULL_PRIVILEGES_MASK ^ (p & (FULL_PRIVILEGES_MASK ^ desired));

		// return calculated result
		return target;
	}

	/**
	 * @notice Ensures that the transaction sender has the required access permission(s) (role)
	 *
	 * @dev Reverts with an `AccessDenied` error if the sender does not have the required role
	 *
	 * @param required the set of permissions (role) that the transaction sender is required to have
	 */
	function _requireSenderInRole(uint256 required) internal view {
		// check if the transaction has the required permission(s),
		// reverting with the "access denied" error if not
		_requireAccessCondition(_isSenderInRole(required));
	}

	/**
	 * @notice Ensures that a specific condition is met
	 *
	 * @dev Reverts with an `AccessDenied` error if the condition is not met
	 *
	 * @param condition the condition that needs to be true for the function to proceed
	 */
	function _requireAccessCondition(bool condition) internal pure {
		// check if the condition holds
		if(!condition) {
			// revert with the "access denied" error if not
			revert AccessDenied();
		}
	}

	/**
	 * @notice Checks if requested set of features is enabled globally on the contract
	 *
	 * @param required set of features to check against
	 * @return true if all the features requested are enabled, false otherwise
	 */
	function _isFeatureEnabled(uint256 required) internal view returns (bool) {
		// delegate call to `__hasRole`, passing `features` property
		return __hasRole(features(), required);
	}

	/**
	 * @notice Checks if transaction sender `msg.sender` has all the permissions required
	 *
	 * @param required set of permissions (role) to check against
	 * @return true if all the permissions requested are enabled, false otherwise
	 */
	function _isSenderInRole(uint256 required) internal view returns (bool) {
		// delegate call to `isOperatorInRole`, passing transaction sender
		return _isOperatorInRole(msg.sender, required);
	}

	/**
	 * @notice Checks if operator has all the permissions (role) required
	 *
	 * @param operator address of the user to check role for
	 * @param required set of permissions (role) to check
	 * @return true if all the permissions requested are enabled, false otherwise
	 */
	function _isOperatorInRole(address operator, uint256 required) internal view returns (bool) {
		// delegate call to `__hasRole`, passing operator's permissions (role)
		return __hasRole(getRole(operator), required);
	}

	/**
	 * @dev Sets the `assignedRole` role to the operator, logs both `requestedRole` and `actualRole`
	 *
	 * @dev Unsafe:
	 *      provides direct write access to `userRoles` mapping without any security checks,
	 *      doesn't verify the executor (msg.sender) permissions,
	 *      must be kept private at all times
	 *
	 * @param operator address of a user to alter permissions for,
	 *       or self address to alter global features of the smart contract
	 * @param requestedRole bitmask representing a set of permissions requested
	 *      to be enabled/disabled for a user specified, used only to be logged into event
	 * @param assignedRole bitmask representing a set of permissions to
	 *      enable/disable for a user specified, used to update the mapping and to be logged into event
	 */
	function __setRole(address operator, uint256 requestedRole, uint256 assignedRole) private {
		// assign the role to the operator
		userRoles[operator] = assignedRole;

		// fire an event
		emit RoleUpdated(operator, requestedRole, assignedRole);
	}

	/**
	 * @dev Checks if role `actual` contains all the permissions required `required`
	 *
	 * @param actual existent role
	 * @param required required role
	 * @return true if actual has required role (all permissions), false otherwise
	 */
	function __hasRole(uint256 actual, uint256 required) private pure returns (bool) {
		// check the bitmask for the role required and return the result
		return actual & required == required;
	}
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * @title EIP-2612: permit - 712-signed approvals
 *
 * @notice A function permit extending ERC-20 which allows for approvals to be made via secp256k1 signatures.
 *      This kind of “account abstraction for ERC-20” brings about two main benefits:
 *        - transactions involving ERC-20 operations can be paid using the token itself rather than ETH,
 *        - approve and pull operations can happen in a single transaction instead of two consecutive transactions,
 *        - while adding as little as possible over the existing ERC-20 standard.
 *
 * @notice See https://eips.ethereum.org/EIPS/eip-2612#specification
 */
interface EIP2612 {
	/**
	 * @notice EIP712 domain separator of the smart contract. It should be unique to the contract
	 *      and chain to prevent replay attacks from other domains, and satisfy the requirements of EIP-712,
	 *      but is otherwise unconstrained.
	 */
	function DOMAIN_SEPARATOR() external view returns (bytes32);

	/**
	 * @notice Counter of the nonces used for the given address; nonce are used sequentially
	 *
	 * @dev To prevent from replay attacks nonce is incremented for each address after a successful `permit` execution
	 *
	 * @param owner an address to query number of used nonces for
	 * @return number of used nonce, nonce number to be used next
	 */
	function nonces(address owner) external view returns (uint);

	/**
	 * @notice For all addresses owner, spender, uint256s value, deadline and nonce, uint8 v, bytes32 r and s,
	 *      a call to permit(owner, spender, value, deadline, v, r, s) will set approval[owner][spender] to value,
	 *      increment nonces[owner] by 1, and emit a corresponding Approval event,
	 *      if and only if the following conditions are met:
	 *        - The current blocktime is less than or equal to deadline.
	 *        - owner is not the zero address.
	 *        - nonces[owner] (before the state update) is equal to nonce.
	 *        - r, s and v is a valid secp256k1 signature from owner of the message:
	 *
	 * @param owner token owner address, granting an approval to spend its tokens
	 * @param spender an address approved by the owner (token owner)
	 *      to spend some tokens on its behalf
	 * @param value an amount of tokens spender `spender` is allowed to
	 *      transfer on behalf of the token owner
	 * @param v the recovery byte of the signature
	 * @param r half of the ECDSA signature pair
	 * @param s half of the ECDSA signature pair
	 */
	function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * @title EIP-3009: Transfer With Authorization
 *
 * @notice A contract interface that enables transferring of fungible assets via a signed authorization.
 *      See https://eips.ethereum.org/EIPS/eip-3009
 *      See https://eips.ethereum.org/EIPS/eip-3009#specification
 */
interface EIP3009 {
	/**
	 * @dev Fired whenever the nonce gets used (ex.: `transferWithAuthorization`, `receiveWithAuthorization`)
	 *
	 * @param authorizer an address which has used the nonce
	 * @param nonce the nonce used
	 */
	event AuthorizationUsed(address indexed authorizer, bytes32 indexed nonce);

	/**
	 * @dev Fired whenever the nonce gets cancelled (ex.: `cancelAuthorization`)
	 *
	 * @dev Both `AuthorizationUsed` and `AuthorizationCanceled` imply the nonce
	 *      cannot be longer used, the only difference is that `AuthorizationCanceled`
	 *      implies no smart contract state change made (except the nonce marked as cancelled)
	 *
	 * @param authorizer an address which has cancelled the nonce
	 * @param nonce the nonce cancelled
	 */
	event AuthorizationCanceled(address indexed authorizer, bytes32 indexed nonce);

	/**
	 * @notice Returns the state of an authorization, more specifically
	 *      if the specified nonce was already used by the address specified
	 *
	 * @dev Nonces are expected to be client-side randomly generated 32-byte data
	 *      unique to the authorizer's address
	 *
	 * @param authorizer    Authorizer's address
	 * @param nonce         Nonce of the authorization
	 * @return true if the nonce is used
	 */
	function authorizationState(
		address authorizer,
		bytes32 nonce
	) external view returns (bool);

	/**
	 * @notice Execute a transfer with a signed authorization
	 *
	 * @param from          Payer's address (Authorizer)
	 * @param to            Payee's address
	 * @param value         Amount to be transferred
	 * @param validAfter    The time after which this is valid (unix time)
	 * @param validBefore   The time before which this is valid (unix time)
	 * @param nonce         Unique nonce
	 * @param v             v of the signature
	 * @param r             r of the signature
	 * @param s             s of the signature
	 */
	function transferWithAuthorization(
		address from,
		address to,
		uint256 value,
		uint256 validAfter,
		uint256 validBefore,
		bytes32 nonce,
		uint8 v,
		bytes32 r,
		bytes32 s
	) external;

	/**
	 * @notice Receive a transfer with a signed authorization from the payer
	 *
	 * @dev This has an additional check to ensure that the payee's address matches
	 *      the caller of this function to prevent front-running attacks.
	 * @dev See https://eips.ethereum.org/EIPS/eip-3009#security-considerations
	 *
	 * @param from          Payer's address (Authorizer)
	 * @param to            Payee's address
	 * @param value         Amount to be transferred
	 * @param validAfter    The time after which this is valid (unix time)
	 * @param validBefore   The time before which this is valid (unix time)
	 * @param nonce         Unique nonce
	 * @param v             v of the signature
	 * @param r             r of the signature
	 * @param s             s of the signature
	 */
	function receiveWithAuthorization(
		address from,
		address to,
		uint256 value,
		uint256 validAfter,
		uint256 validBefore,
		bytes32 nonce,
		uint8 v,
		bytes32 r,
		bytes32 s
	) external;

	/**
	 * @notice Attempt to cancel an authorization
	 *
	 * @param authorizer    Authorizer's address
	 * @param nonce         Nonce of the authorization
	 * @param v             v of the signature
	 * @param r             r of the signature
	 * @param s             s of the signature
	 */
	function cancelAuthorization(
		address authorizer,
		bytes32 nonce,
		uint8 v,
		bytes32 r,
		bytes32 s
	) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20Spec.sol";
import "./ERC165Spec.sol";

/**
 * @title ERC1363 Interface
 *
 * @dev Interface defining a ERC1363 Payable Token contract.
 *      Implementing contracts MUST implement the ERC1363 interface as well as the ERC20 and ERC165 interfaces.
 */
interface ERC1363 is ERC20, ERC165  {
	/*
	 * Note: the ERC-165 identifier for this interface is 0xb0202a11.
	 * 0xb0202a11 ===
	 *   bytes4(keccak256('transferAndCall(address,uint256)')) ^
	 *   bytes4(keccak256('transferAndCall(address,uint256,bytes)')) ^
	 *   bytes4(keccak256('transferFromAndCall(address,address,uint256)')) ^
	 *   bytes4(keccak256('transferFromAndCall(address,address,uint256,bytes)')) ^
	 *   bytes4(keccak256('approveAndCall(address,uint256)')) ^
	 *   bytes4(keccak256('approveAndCall(address,uint256,bytes)'))
	 */

	/**
	 * @notice Transfer tokens from `msg.sender` to another address and then call `onTransferReceived` on receiver
	 * @param to address The address which you want to transfer to
	 * @param value uint256 The amount of tokens to be transferred
	 * @return true unless throwing
	 */
	function transferAndCall(address to, uint256 value) external returns (bool);

	/**
	 * @notice Transfer tokens from `msg.sender` to another address and then call `onTransferReceived` on receiver
	 * @param to address The address which you want to transfer to
	 * @param value uint256 The amount of tokens to be transferred
	 * @param data bytes Additional data with no specified format, sent in call to `to`
	 * @return true unless throwing
	 */
	function transferAndCall(address to, uint256 value, bytes memory data) external returns (bool);

	/**
	 * @notice Transfer tokens from one address to another and then call `onTransferReceived` on receiver
	 * @param from address The address which you want to send tokens from
	 * @param to address The address which you want to transfer to
	 * @param value uint256 The amount of tokens to be transferred
	 * @return true unless throwing
	 */
	function transferFromAndCall(address from, address to, uint256 value) external returns (bool);

	/**
	 * @notice Transfer tokens from one address to another and then call `onTransferReceived` on receiver
	 * @param from address The address which you want to send tokens from
	 * @param to address The address which you want to transfer to
	 * @param value uint256 The amount of tokens to be transferred
	 * @param data bytes Additional data with no specified format, sent in call to `to`
	 * @return true unless throwing
	 */
	function transferFromAndCall(address from, address to, uint256 value, bytes memory data) external returns (bool);

	/**
	 * @notice Approve the passed address to spend the specified amount of tokens on behalf of msg.sender
	 * and then call `onApprovalReceived` on spender.
	 * @param spender address The address which will spend the funds
	 * @param value uint256 The amount of tokens to be spent
	 */
	function approveAndCall(address spender, uint256 value) external returns (bool);

	/**
	 * @notice Approve the passed address to spend the specified amount of tokens on behalf of msg.sender
	 * and then call `onApprovalReceived` on spender.
	 * @param spender address The address which will spend the funds
	 * @param value uint256 The amount of tokens to be spent
	 * @param data bytes Additional data with no specified format, sent in call to `spender`
	 */
	function approveAndCall(address spender, uint256 value, bytes memory data) external returns (bool);
}

/**
 * @title ERC1363Receiver Interface
 *
 * @dev Interface for any contract that wants to support `transferAndCall` or `transferFromAndCall`
 *      from ERC1363 token contracts.
 */
interface ERC1363Receiver {
	/*
	 * Note: the ERC-165 identifier for this interface is 0x88a7ca5c.
	 * 0x88a7ca5c === bytes4(keccak256("onTransferReceived(address,address,uint256,bytes)"))
	 */

	/**
	 * @notice Handle the receipt of ERC1363 tokens
	 *
	 * @dev Any ERC1363 smart contract calls this function on the recipient
	 *      after a `transfer` or a `transferFrom`. This function MAY throw to revert and reject the
	 *      transfer. Return of other than the magic value MUST result in the
	 *      transaction being reverted.
	 *      Note: the token contract address is always the message sender.
	 *
	 * @param operator address The address which called `transferAndCall` or `transferFromAndCall` function
	 * @param from address The address which are token transferred from
	 * @param value uint256 The amount of tokens transferred
	 * @param data bytes Additional data with no specified format
	 * @return `bytes4(keccak256("onTransferReceived(address,address,uint256,bytes)"))`
	 *      unless throwing
	 */
	function onTransferReceived(address operator, address from, uint256 value, bytes memory data) external returns (bytes4);
}

/**
 * @title ERC1363Spender Interface
 *
 * @dev Interface for any contract that wants to support `approveAndCall`
 *      from ERC1363 token contracts.
 */
interface ERC1363Spender {
	/*
	 * Note: the ERC-165 identifier for this interface is 0x7b04a2d0.
	 * 0x7b04a2d0 === bytes4(keccak256("onApprovalReceived(address,uint256,bytes)"))
	 */

	/**
	 * @notice Handle the approval of ERC1363 tokens
	 *
	 * @dev Any ERC1363 smart contract calls this function on the recipient
	 *      after an `approve`. This function MAY throw to revert and reject the
	 *      approval. Return of other than the magic value MUST result in the
	 *      transaction being reverted.
	 *      Note: the token contract address is always the message sender.
	 *
	 * @param owner address The address which called `approveAndCall` function
	 * @param value uint256 The amount of tokens to be spent
	 * @param data bytes Additional data with no specified format
	 * @return `bytes4(keccak256("onApprovalReceived(address,uint256,bytes)"))`
	 *      unless throwing
	 */
	function onApprovalReceived(address owner, uint256 value, bytes memory data) external returns (bytes4);
}

/**
 * @title Mintable ERC1363 Extension
 *
 * @notice Adds mint functions to the ERC1363 interface, these functions
 *      follow the same idea and logic as ERC1363 transferAndCall functions,
 *      allowing to notify the recipient ERC1363Receiver contract about the tokens received
 */
interface MintableERC1363 is ERC1363 {
	/**
	 * @notice Mint tokens to the receiver and then call `onTransferReceived` on the receiver
	 * @param to address The address which you want to mint to
	 * @param value uint256 The amount of tokens to be minted
	 * @return true unless throwing
	 */
	function mintAndCall(address to, uint256 value) external returns (bool);

	/**
	 * @notice Mint tokens to the receiver and then call `onTransferReceived` on the receiver
	 * @param to address The address which you want to mint to
	 * @param value uint256 The amount of tokens to be minted
	 * @param data bytes Additional data with no specified format, sent in call to `to`
	 * @return true unless throwing
	 */
	function mintAndCall(address to, uint256 value, bytes memory data) external returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * @title ERC-165 Standard Interface Detection
 *
 * @dev Interface of the ERC165 standard, as defined in the
 *       https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * @dev Implementers can declare support of contract interfaces,
 *      which can then be queried by others.
 *
 * @author Christian Reitwießner, Nick Johnson, Fabian Vogelsteller, Jordi Baylina, Konrad Feldmeier, William Entriken
 */
interface ERC165 {
	/**
	 * @notice Query if a contract implements an interface
	 *
	 * @dev Interface identification is specified in ERC-165.
	 *      This function uses less than 30,000 gas.
	 *
	 * @param interfaceID The interface identifier, as specified in ERC-165
	 * @return `true` if the contract implements `interfaceID` and
	 *      `interfaceID` is not 0xffffffff, `false` otherwise
	 */
	function supportsInterface(bytes4 interfaceID) external view returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * @title EIP-20: ERC-20 Token Standard
 *
 * @notice The ERC-20 (Ethereum Request for Comments 20), proposed by Fabian Vogelsteller in November 2015,
 *      is a Token Standard that implements an API for tokens within Smart Contracts.
 *
 * @notice It provides functionalities like to transfer tokens from one account to another,
 *      to get the current token balance of an account and also the total supply of the token available on the network.
 *      Besides these it also has some other functionalities like to approve that an amount of
 *      token from an account can be spent by a third party account.
 *
 * @notice If a Smart Contract implements the following methods and events it can be called an ERC-20 Token
 *      Contract and, once deployed, it will be responsible to keep track of the created tokens on Ethereum.
 *
 * @notice See https://ethereum.org/en/developers/docs/standards/tokens/erc-20/
 * @notice See https://eips.ethereum.org/EIPS/eip-20
 */
interface ERC20 {
	/**
	 * @dev Fired in transfer(), transferFrom() to indicate that token transfer happened
	 *
	 * @param from an address tokens were consumed from
	 * @param to an address tokens were sent to
	 * @param value number of tokens transferred
	 */
	event Transfer(address indexed from, address indexed to, uint256 value);

	/**
	 * @dev Fired in approve() to indicate an approval event happened
	 *
	 * @param owner an address which granted a permission to transfer
	 *      tokens on its behalf
	 * @param spender an address which received a permission to transfer
	 *      tokens on behalf of the owner `owner`
	 * @param value amount of tokens granted to transfer on behalf
	 */
	event Approval(address indexed owner, address indexed spender, uint256 value);

	/**
	 * @return name of the token (ex.: USD Coin)
	 */
	// OPTIONAL - This method can be used to improve usability,
	// but interfaces and other contracts MUST NOT expect these values to be present.
	// function name() external view returns (string memory);

	/**
	 * @return symbol of the token (ex.: USDC)
	 */
	// OPTIONAL - This method can be used to improve usability,
	// but interfaces and other contracts MUST NOT expect these values to be present.
	// function symbol() external view returns (string memory);

	/**
	 * @dev Returns the number of decimals used to get its user representation.
	 *      For example, if `decimals` equals `2`, a balance of `505` tokens should
	 *      be displayed to a user as `5,05` (`505 / 10 ** 2`).
	 *
	 * @dev Tokens usually opt for a value of 18, imitating the relationship between
	 *      Ether and Wei. This is the value {ERC20} uses, unless this function is
	 *      overridden;
	 *
	 * @dev NOTE: This information is only used for _display_ purposes: it in
	 *      no way affects any of the arithmetic of the contract, including
	 *      {IERC20-balanceOf} and {IERC20-transfer}.
	 *
	 * @return token decimals
	 */
	// OPTIONAL - This method can be used to improve usability,
	// but interfaces and other contracts MUST NOT expect these values to be present.
	// function decimals() external view returns (uint8);

	/**
	 * @return the amount of tokens in existence
	 */
	function totalSupply() external view returns (uint256);

	/**
	 * @notice Gets the balance of a particular address
	 *
	 * @param owner the address to query the the balance for
	 * @return balance an amount of tokens owned by the address specified
	 */
	function balanceOf(address owner) external view returns (uint256 balance);

	/**
	 * @notice Transfers some tokens to an external address or a smart contract
	 *
	 * @dev Called by token owner (an address which has a
	 *      positive token balance tracked by this smart contract)
	 * @dev Throws on any error like
	 *      * insufficient token balance or
	 *      * incorrect `to` address:
	 *          * zero address or
	 *          * self address or
	 *          * smart contract which doesn't support ERC20
	 *
	 * @param to an address to transfer tokens to,
	 *      must be either an external address or a smart contract,
	 *      compliant with the ERC20 standard
	 * @param value amount of tokens to be transferred,, zero
	 *      value is allowed
	 * @return success true on success, throws otherwise
	 */
	function transfer(address to, uint256 value) external returns (bool success);

	/**
	 * @notice Transfers some tokens on behalf of address `from' (token owner)
	 *      to some other address `to`
	 *
	 * @dev Called by token owner on his own or approved address,
	 *      an address approved earlier by token owner to
	 *      transfer some amount of tokens on its behalf
	 * @dev Throws on any error like
	 *      * insufficient token balance or
	 *      * incorrect `to` address:
	 *          * zero address or
	 *          * same as `from` address (self transfer)
	 *          * smart contract which doesn't support ERC20
	 *
	 * @param from token owner which approved caller (transaction sender)
	 *      to transfer `value` of tokens on its behalf
	 * @param to an address to transfer tokens to,
	 *      must be either an external address or a smart contract,
	 *      compliant with the ERC20 standard
	 * @param value amount of tokens to be transferred,, zero
	 *      value is allowed
	 * @return success true on success, throws otherwise
	 */
	function transferFrom(address from, address to, uint256 value) external returns (bool success);

	/**
	 * @notice Approves address called `spender` to transfer some amount
	 *      of tokens on behalf of the owner (transaction sender)
	 *
	 * @dev Transaction sender must not necessarily own any tokens to grant the permission
	 *
	 * @param spender an address approved by the caller (token owner)
	 *      to spend some tokens on its behalf
	 * @param value an amount of tokens spender `spender` is allowed to
	 *      transfer on behalf of the token owner
	 * @return success true on success, throws otherwise
	 */
	function approve(address spender, uint256 value) external returns (bool success);

	/**
	 * @notice Returns the amount which `spender` is still allowed to withdraw from `owner`.
	 *
	 * @dev A function to check an amount of tokens owner approved
	 *      to transfer on its behalf by some other address called "spender"
	 *
	 * @param owner an address which approves transferring some tokens on its behalf
	 * @param spender an address approved to transfer some tokens on behalf
	 * @return remaining an amount of tokens approved address `spender` can transfer on behalf
	 *      of token owner `owner`
	 */
	function allowance(address owner, address spender) external view returns (uint256 remaining);
}

/**
 * @title Mintable/burnable ERC20 Extension
 *
 * @notice Adds mint/burn functions to the ERC20 interface;
 *      these functions are usually present in ERC20 implementations;
 *      they become a must for the bridged tokens since the bridge usually
 *      needs to have a way to mint tokens deposited from L1 to L2
 *      and to burn tokens to be withdrawn from L2 to L1
 */
interface MintableBurnableERC20 is ERC20 {
	/**
	 * @dev Mints (creates) some tokens to address specified
	 * @dev The value specified is treated as is without taking
	 *      into account what `decimals` value is
	 *
	 * @param to an address to mint tokens to
	 * @param value an amount of tokens to mint (create)
	 * @return success true on success, false otherwise
	 */
	function mint(address to, uint256 value) external returns (bool success);

	/**
	 * @dev Burns (destroys) some tokens from the address specified
	 *
	 * @dev The value specified is treated as is without taking
	 *      into account what `decimals` value is
	 *
	 * @param from an address to burn some tokens from
	 * @param value an amount of tokens to burn (destroy)
	 * @return success true on success, false otherwise
	 */
	function burn(address from, uint256 value) external returns (bool success);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 *
 * @dev Copy of the Zeppelin's library:
 *      https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b0cf6fbb7a70f31527f36579ad644e1cf12fdf4e/contracts/utils/cryptography/ECDSA.sol
 */
library ECDSA {
	/**
	 * @dev Overload of {ECDSA-recover} that receives the `v`,
	 * `r` and `s` signature fields separately.
	 */
	function recover(
		bytes32 hash,
		uint8 v,
		bytes32 r,
		bytes32 s
	) internal pure returns (address) {
		// EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
		// unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
		// the valid range for s in (281): 0 < s < secp256k1n ÷ 2 + 1, and for v in (282): v ∈ {27, 28}. Most
		// signatures from current libraries generate a unique signature with an s-value in the lower half order.
		//
		// If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
		// with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
		// vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
		// these malleable signatures as well.
		require(
			uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0,
			"invalid signature 's' value"
		);
		require(v == 27 || v == 28, "invalid signature 'v' value");

		// If the signature is valid (and not malleable), return the signer address
		address signer = ecrecover(hash, v, r, s);
		require(signer != address(0), "invalid signature");

		return signer;
	}
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../interfaces/ERC1363Spec.sol";
import "../interfaces/EIP2612.sol";
import "../interfaces/EIP3009.sol";
import "../lib/ECDSA.sol";

import "@lazy-sol/access-control-upgradeable/contracts/InitializableAccessControlCore.sol";

/**
 * @title Advanced ERC20
 *
 * @notice Feature rich lightweight ERC20 implementation which is not built on top of OpenZeppelin ERC20 implementation.
 *      It uses some other OpenZeppelin code:
 *         - low level functions to work with ECDSA signatures (recover)
 *         - low level functions to work contract addresses (isContract)
 *         - OZ UUPS proxy and smart contracts upgradeability code
 *
 * @notice Token Summary:
 *      - Symbol: configurable (set on deployment)
 *      - Name: configurable (set on deployment)
 *      - Decimals: 18
 *      - Initial/maximum total supply: configurable (set on deployment)
 *      - Initial supply holder (initial holder) address: configurable (set on deployment)
 *      - Mintability: configurable (initially enabled, but possible to revoke forever)
 *      - Burnability: configurable (initially enabled, but possible to revoke forever)
 *      - DAO Support: supports voting delegation
 *
 * @notice Features Summary:
 *      - Supports atomic allowance modification, resolves well-known ERC20 issue with approve (arXiv:1907.00903)
 *      - Voting delegation and delegation on behalf via EIP-712 (like in Compound CMP token) - gives the token
 *        powerful governance capabilities by allowing holders to form voting groups by electing delegates
 *      - Unlimited approval feature (like in 0x ZRX token) - saves gas for transfers on behalf
 *        by eliminating the need to update “unlimited” allowance value
 *      - ERC-1363 Payable Token - ERC721-like callback execution mechanism for transfers, transfers on behalf,
 *        approvals, and restricted access mints (which are sometimes viewed as transfers from zero address);
 *        allows creation of smart contracts capable of executing callbacks - in response to token transfer, approval,
  *       and token minting - in a single transaction
 *      - EIP-2612: permit - 712-signed approvals - improves user experience by allowing to use a token
 *        without having an ETH to pay gas fees
 *      - EIP-3009: Transfer With Authorization - improves user experience by allowing to use a token
 *        without having an ETH to pay gas fees
 *
 * @notice This smart contract can be used as is, but also can be inherited and used as a template.
 *
 * @dev Even though smart contract has mint() function which is used to mint initial token supply,
 *      the function is disabled forever after smart contract deployment by revoking `TOKEN_CREATOR`
 *      permission from the deployer account
 *
 * @dev Token balances and total supply are effectively 192 bits long, meaning that maximum
 *      possible total supply smart contract is able to track is 2^192 (close to 10^40 tokens)
 *
 * @dev Smart contract doesn't use safe math. All arithmetic operations are overflow/underflow safe.
 *      Additionally, Solidity 0.8.7 enforces overflow/underflow safety.
 *
 * @dev Multiple Withdrawal Attack on ERC20 Tokens (arXiv:1907.00903) - resolved
 *      Related events and functions are marked with "arXiv:1907.00903" tag:
 *        - event Transfer(address indexed by, address indexed from, address indexed to, uint256 value)
 *        - event Approve(address indexed owner, address indexed spender, uint256 oldValue, uint256 value)
 *        - function increaseAllowance(address spender, uint256 value) public returns (bool)
 *        - function decreaseAllowance(address spender, uint256 value) public returns (bool)
 *      See: https://arxiv.org/abs/1907.00903v1
 *           https://ieeexplore.ieee.org/document/8802438
 *      See: https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
 *
 * @dev Reviewed
 *      ERC-20   - according to https://eips.ethereum.org/EIPS/eip-20
 *      ERC-1363 - according to https://eips.ethereum.org/EIPS/eip-1363
 *      EIP-2612 - according to https://eips.ethereum.org/EIPS/eip-2612
 *      EIP-3009 - according to https://eips.ethereum.org/EIPS/eip-3009
 *
 * @dev ERC20: contract has passed
 *      - OpenZeppelin ERC20 tests
 *        https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/test/token/ERC20/ERC20.behavior.js
 *        https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/test/token/ERC20/ERC20.test.js
 *      - Ref ERC1363 tests
 *        https://github.com/vittominacori/erc1363-payable-token/blob/master/test/token/ERC1363/ERC1363.behaviour.js
 *      - OpenZeppelin EIP2612 tests
 *        https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/test/token/ERC20/extensions/draft-ERC20Permit.test.js
 *      - Coinbase EIP3009 tests
 *        https://github.com/CoinbaseStablecoin/eip-3009/blob/master/test/EIP3009.test.ts
 *      - Compound voting delegation tests
 *        https://github.com/compound-finance/compound-protocol/blob/master/tests/Governance/CompTest.js
 *        https://github.com/compound-finance/compound-protocol/blob/master/tests/Utils/EIP712.js
 *      - OpenZeppelin voting delegation tests
 *        https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/test/token/ERC20/extensions/ERC20Votes.test.js
 *      See adopted copies of all the tests in the project test folder
 *
 * @dev Compound-like voting delegation functions', public getters', and events' names
 *      were changed for better code readability (Advanced ERC20 Name <- Comp/Zeppelin name):
 *      - votingDelegates           <- delegates
 *      - votingPowerHistory        <- checkpoints
 *      - votingPowerHistoryLength  <- numCheckpoints
 *      - totalSupplyHistory        <- _totalSupplyCheckpoints (private)
 *      - usedNonces                <- nonces (note: nonces are random instead of sequential)
 *      - DelegateChanged (unchanged)
 *      - VotingPowerChanged        <- DelegateVotesChanged
 *      - votingPowerOf             <- getCurrentVotes
 *      - votingPowerAt             <- getPriorVotes
 *      - totalSupplyAt             <- getPriorTotalSupply
 *      - delegate (unchanged)
 *      - delegateWithAuthorization <- delegateBySig
 * @dev Compound-like voting delegation improved to allow the use of random nonces like in EIP-3009,
 *      instead of sequential; same `usedNonces` EIP-3009 mapping is used to track nonces
 *
 * @dev Reference implementations "used":
 *      - Atomic allowance:    https://github.com/OpenZeppelin/openzeppelin-contracts
 *      - Unlimited allowance: https://github.com/0xProject/protocol
 *      - Voting delegation:   https://github.com/compound-finance/compound-protocol
 *                             https://github.com/OpenZeppelin/openzeppelin-contracts
 *      - ERC-1363:            https://github.com/vittominacori/erc1363-payable-token
 *      - EIP-2612:            https://github.com/Uniswap/uniswap-v2-core
 *      - EIP-3009:            https://github.com/centrehq/centre-tokens
 *                             https://github.com/CoinbaseStablecoin/eip-3009
 *      - Meta transactions:   https://github.com/0xProject/protocol
 *
 * @dev The code is based on Artificial Liquid Intelligence Token (ALI) developed by Alethea team
 * @dev Includes resolutions for ALI ERC20 Audit by Miguel Palhas, https://hackmd.io/@naps62/alierc20-audit
 *
 * @author Basil Gorin
 */
contract AdvancedERC20 is MintableERC1363, MintableBurnableERC20, EIP2612, EIP3009, InitializableAccessControlCore {
	/**
	 * @notice Name of the token
	 *
	 * @notice ERC20 name of the token (long name)
	 *
	 * @dev ERC20 `function name() public view returns (string)`
	 *
	 * @dev Field is declared public: getter name() is created when compiled,
	 *      it returns the name of the token.
	 */
	string public name;

	/**
	 * @notice Symbol of the token
	 *
	 * @notice ERC20 symbol of that token (short name)
	 *
	 * @dev ERC20 `function symbol() public view returns (string)`
	 *
	 * @dev Field is declared public: getter symbol() is created when compiled,
	 *      it returns the symbol of the token
	 */
	string public symbol;

	/**
	 * @notice Decimals of the token: 18
	 *
	 * @dev ERC20 `function decimals() public view returns (uint8)`
	 *
	 * @dev Field is declared public: getter decimals() is created when compiled,
	 *      it returns the number of decimals used to get its user representation.
	 *      For example, if `decimals` equals `6`, a balance of `1,500,000` tokens should
	 *      be displayed to a user as `1,5` (`1,500,000 / 10 ** 6`).
	 *
	 * @dev NOTE: This information is only used for _display_ purposes: it in
	 *      no way affects any of the arithmetic of the contract, including balanceOf() and transfer().
	 */
	uint8 public constant decimals = 18;

	/**
	 * @notice Total supply of the token: initially 10,000,000,000,
	 *      with the potential to decline over time as some tokens may get burnt but not minted
	 *
	 * @dev ERC20 `function totalSupply() public view returns (uint256)`
	 *
	 * @dev Field is declared public: getter totalSupply() is created when compiled,
	 *      it returns the amount of tokens in existence.
	 */
	uint256 public override totalSupply; // is set to 10 billion * 10^18 in the constructor

	/**
	 * @dev A record of all the token balances
	 * @dev This mapping keeps record of all token owners:
	 *      owner => balance
	 */
	mapping(address => uint256) private tokenBalances;

	/**
	 * @notice A record of each account's voting delegate
	 *
	 * @dev Auxiliary data structure used to sum up an account's voting power
	 *
	 * @dev This mapping keeps record of all voting power delegations:
	 *      voting delegator (token owner) => voting delegate
	 */
	mapping(address => address) public votingDelegates;

	/**
	 * @notice Auxiliary structure to store key-value pair, used to store:
	 *      - voting power record (key: block.timestamp, value: voting power)
	 *      - total supply record (key: block.timestamp, value: total supply)
	 * @notice A voting power record binds voting power of a delegate to a particular
	 *      block when the voting power delegation change happened
	 *         k: block.number when delegation has changed; starting from
	 *            that block voting power value is in effect
	 *         v: cumulative voting power a delegate has obtained starting
	 *            from the block stored in blockNumber
	 * @notice Total supply record binds total token supply to a particular
	 *      block when total supply change happened (due to mint/burn operations)
	 */
	struct KV {
		/*
		 * @dev key, a block number
		 */
		uint64 k;

		/*
		 * @dev value, token balance or voting power
		 */
		uint192 v;
	}

	/**
	 * @notice A record of each account's voting power historical data
	 *
	 * @dev Primarily data structure to store voting power for each account.
	 *      Voting power sums up from the account's token balance and delegated
	 *      balances.
	 *
	 * @dev Stores current value and entire history of its changes.
	 *      The changes are stored as an array of checkpoints (key-value pairs).
	 *      Checkpoint is an auxiliary data structure containing voting
	 *      power (number of votes) and block number when the checkpoint is saved
	 *
	 * @dev Maps voting delegate => voting power record
	 */
	mapping(address => KV[]) public votingPowerHistory;

	/**
	 * @notice A record of total token supply historical data
	 *
	 * @dev Primarily data structure to store total token supply.
	 *
	 * @dev Stores current value and entire history of its changes.
	 *      The changes are stored as an array of checkpoints (key-value pairs).
	 *      Checkpoint is an auxiliary data structure containing total
	 *      token supply and block number when the checkpoint is saved
	 */
	KV[] public totalSupplyHistory;

	/**
	 * @dev A record of nonces for signing/validating signatures in EIP-2612 `permit`
	 *
	 * @dev Note: EIP2612 doesn't imply a possibility for nonce randomization like in EIP-3009
	 *
	 * @dev Maps delegate address => delegate nonce
	 */
	mapping(address => uint256) public override nonces;

	/**
	 * @dev A record of used nonces for EIP-3009 transactions
	 *
	 * @dev A record of used nonces for signing/validating signatures
	 *      in `delegateWithAuthorization` for every delegate
	 *
	 * @dev Maps authorizer address => nonce => true/false (used unused)
	 */
	mapping(address => mapping(bytes32 => bool)) private usedNonces;

	/**
	 * @notice A record of all the allowances to spend tokens on behalf
	 * @dev Maps token owner address to an address approved to spend
	 *      some tokens on behalf, maps approved address to that amount
	 * @dev owner => spender => value
	 */
	mapping(address => mapping(address => uint256)) private transferAllowances;

	/**
	 * @notice Enables ERC20 transfers of the tokens
	 *      (transfer by the token owner himself)
	 * @dev Feature FEATURE_TRANSFERS must be enabled in order for
	 *      `transfer()` function to succeed
	 */
	uint32 public constant FEATURE_TRANSFERS = 0x0000_0001;

	/**
	 * @notice Enables ERC20 transfers on behalf
	 *      (transfer by someone else on behalf of token owner)
	 * @dev Feature FEATURE_TRANSFERS_ON_BEHALF must be enabled in order for
	 *      `transferFrom()` function to succeed
	 * @dev Token owner must call `approve()` first to authorize
	 *      the transfer on behalf
	 */
	uint32 public constant FEATURE_TRANSFERS_ON_BEHALF = 0x0000_0002;

	/**
	 * @dev Defines if the default behavior of `transfer` and `transferFrom`
	 *      checks if the receiver smart contract supports ERC20 tokens
	 * @dev When feature FEATURE_UNSAFE_TRANSFERS is enabled the transfers do not
	 *      check if the receiver smart contract supports ERC20 tokens,
	 *      i.e. `transfer` and `transferFrom` behave like `unsafeTransferFrom`
	 * @dev When feature FEATURE_UNSAFE_TRANSFERS is disabled (default) the transfers
	 *      check if the receiver smart contract supports ERC20 tokens,
	 *      i.e. `transfer` and `transferFrom` behave like `transferFromAndCall`
	 */
	uint32 public constant FEATURE_UNSAFE_TRANSFERS = 0x0000_0004;

	/**
	 * @notice Enables token owners to burn their own tokens
	 *
	 * @dev Feature FEATURE_OWN_BURNS must be enabled in order for
	 *      `burn()` function to succeed when called by token owner
	 */
	uint32 public constant FEATURE_OWN_BURNS = 0x0000_0008;

	/**
	 * @notice Enables approved operators to burn tokens on behalf of their owners
	 *
	 * @dev Feature FEATURE_BURNS_ON_BEHALF must be enabled in order for
	 *      `burn()` function to succeed when called by approved operator
	 */
	uint32 public constant FEATURE_BURNS_ON_BEHALF = 0x0000_0010;

	/**
	 * @notice Enables delegators to elect delegates
	 * @dev Feature FEATURE_DELEGATIONS must be enabled in order for
	 *      `delegate()` function to succeed
	 */
	uint32 public constant FEATURE_DELEGATIONS = 0x0000_0020;

	/**
	 * @notice Enables delegators to elect delegates on behalf
	 *      (via an EIP712 signature)
	 * @dev Feature FEATURE_DELEGATIONS_ON_BEHALF must be enabled in order for
	 *      `delegateWithAuthorization()` function to succeed
	 */
	uint32 public constant FEATURE_DELEGATIONS_ON_BEHALF = 0x0000_0040;

	/**
	 * @notice Enables ERC-1363 transfers with callback
	 * @dev Feature FEATURE_ERC1363_TRANSFERS must be enabled in order for
	 *      ERC-1363 `transferFromAndCall` functions to succeed
	 */
	uint32 public constant FEATURE_ERC1363_TRANSFERS = 0x0000_0080;

	/**
	 * @notice Enables ERC-1363 approvals with callback
	 * @dev Feature FEATURE_ERC1363_APPROVALS must be enabled in order for
	 *      ERC-1363 `approveAndCall` functions to succeed
	 */
	uint32 public constant FEATURE_ERC1363_APPROVALS = 0x0000_0100;

	/**
	 * @notice Enables approvals on behalf (EIP2612 permits
	 *      via an EIP712 signature)
	 * @dev Feature FEATURE_EIP2612_PERMITS must be enabled in order for
	 *      `permit()` function to succeed
	 */
	uint32 public constant FEATURE_EIP2612_PERMITS = 0x0000_0200;

	/**
	 * @notice Enables meta transfers on behalf (EIP3009 transfers
	 *      via an EIP712 signature)
	 * @dev Feature FEATURE_EIP3009_TRANSFERS must be enabled in order for
	 *      `transferWithAuthorization()` function to succeed
	 */
	uint32 public constant FEATURE_EIP3009_TRANSFERS = 0x0000_0400;

	/**
	 * @notice Enables meta transfers on behalf (EIP3009 transfers
	 *      via an EIP712 signature)
	 * @dev Feature FEATURE_EIP3009_RECEPTIONS must be enabled in order for
	 *      `receiveWithAuthorization()` function to succeed
	 */
	uint32 public constant FEATURE_EIP3009_RECEPTIONS = 0x0000_0800;

	/**
	 * @notice Token creator is responsible for creating (minting)
	 *      tokens to an arbitrary address
	 * @dev Role ROLE_TOKEN_CREATOR allows minting tokens
	 *      (calling `mint` function)
	 */
	uint32 public constant ROLE_TOKEN_CREATOR = 0x0001_0000;

	/**
	 * @notice Token destroyer is responsible for destroying (burning)
	 *      tokens owned by an arbitrary address
	 * @dev Role ROLE_TOKEN_DESTROYER allows burning tokens
	 *      (calling `burn` function)
	 */
	uint32 public constant ROLE_TOKEN_DESTROYER = 0x0002_0000;

	/**
	 * @notice ERC20 receivers are allowed to receive tokens without ERC20 safety checks,
	 *      which may be useful to simplify tokens transfers into "legacy" smart contracts
	 * @dev When `FEATURE_UNSAFE_TRANSFERS` is not enabled addresses having
	 *      `ROLE_ERC20_RECEIVER` permission are allowed to receive tokens
	 *      via `transfer` and `transferFrom` functions in the same way they
	 *      would via `unsafeTransferFrom` function
	 * @dev When `FEATURE_UNSAFE_TRANSFERS` is enabled `ROLE_ERC20_RECEIVER` permission
	 *      doesn't affect the transfer behaviour since
	 *      `transfer` and `transferFrom` behave like `unsafeTransferFrom` for any receiver
	 * @dev ROLE_ERC20_RECEIVER is a shortening for ROLE_UNSAFE_ERC20_RECEIVER
	 */
	uint32 public constant ROLE_ERC20_RECEIVER = 0x0004_0000;

	/**
	 * @notice ERC20 senders are allowed to send tokens without ERC20 safety checks,
	 *      which may be useful to simplify tokens transfers into "legacy" smart contracts
	 * @dev When `FEATURE_UNSAFE_TRANSFERS` is not enabled senders having
	 *      `ROLE_ERC20_SENDER` permission are allowed to send tokens
	 *      via `transfer` and `transferFrom` functions in the same way they
	 *      would via `unsafeTransferFrom` function
	 * @dev When `FEATURE_UNSAFE_TRANSFERS` is enabled `ROLE_ERC20_SENDER` permission
	 *      doesn't affect the transfer behaviour since
	 *      `transfer` and `transferFrom` behave like `unsafeTransferFrom` for any receiver
	 * @dev ROLE_ERC20_SENDER is a shortening for ROLE_UNSAFE_ERC20_SENDER
	 */
	uint32 public constant ROLE_ERC20_SENDER = 0x0008_0000;

	/**
	 * @notice EIP-712 contract's domain typeHash,
	 *      see https://eips.ethereum.org/EIPS/eip-712#rationale-for-typehash
	 *
	 * @dev Note: we do not include version into the domain typehash/separator,
	 *      it is implied version is concatenated to the name field, like "AdvancedERC20v1"
	 */
	// keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)")
	bytes32 public constant DOMAIN_TYPEHASH = 0x8cad95687ba82c2ce50e74f7b754645e5117c3a5bec8151c0726d5857980a866;

	/**
	 * @notice EIP-712 contract domain separator,
	 *      see https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator
	 *      note: we specify contract version in its name
	 */
	function DOMAIN_SEPARATOR() public view override returns(bytes32) {
		// build the EIP-712 contract domain separator, see https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator
		// note: we specify contract version in its name
		return keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes("AdvancedERC20v1")), block.chainid, address(this)));
	}

	/**
	 * @notice EIP-712 delegation struct typeHash,
	 *      see https://eips.ethereum.org/EIPS/eip-712#rationale-for-typehash
	 */
	// keccak256("Delegation(address delegate,uint256 nonce,uint256 expiry)")
	bytes32 public constant DELEGATION_TYPEHASH = 0xff41620983935eb4d4a3c7384a066ca8c1d10cef9a5eca9eb97ca735cd14a755;

	/**
	 * @notice EIP-712 permit (EIP-2612) struct typeHash,
	 *      see https://eips.ethereum.org/EIPS/eip-712#rationale-for-typehash
	 */
	// keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)")
	bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;

	/**
	 * @notice EIP-712 TransferWithAuthorization (EIP-3009) struct typeHash,
	 *      see https://eips.ethereum.org/EIPS/eip-712#rationale-for-typehash
	 */
	// keccak256("TransferWithAuthorization(address from,address to,uint256 value,uint256 validAfter,uint256 validBefore,bytes32 nonce)")
	bytes32 public constant TRANSFER_WITH_AUTHORIZATION_TYPEHASH = 0x7c7c6cdb67a18743f49ec6fa9b35f50d52ed05cbed4cc592e13b44501c1a2267;

	/**
	 * @notice EIP-712 ReceiveWithAuthorization (EIP-3009) struct typeHash,
	 *      see https://eips.ethereum.org/EIPS/eip-712#rationale-for-typehash
	 */
	// keccak256("ReceiveWithAuthorization(address from,address to,uint256 value,uint256 validAfter,uint256 validBefore,bytes32 nonce)")
	bytes32 public constant RECEIVE_WITH_AUTHORIZATION_TYPEHASH = 0xd099cc98ef71107a616c4f0f941f04c322d8e254fe26b3c6668db87aae413de8;

	/**
	 * @notice EIP-712 CancelAuthorization (EIP-3009) struct typeHash,
	 *      see https://eips.ethereum.org/EIPS/eip-712#rationale-for-typehash
	 */
	// keccak256("CancelAuthorization(address authorizer,bytes32 nonce)")
	bytes32 public constant CANCEL_AUTHORIZATION_TYPEHASH = 0x158b0a9edf7a828aad02f63cd515c68ef2f50ba807396f6d12842833a1597429;

	/**
	 * @dev Fired in mint() function
	 *
	 * @param by an address which minted some tokens (transaction sender)
	 * @param to an address the tokens were minted to
	 * @param value an amount of tokens minted
	 */
	event Minted(address indexed by, address indexed to, uint256 value);

	/**
	 * @dev Fired in burn() function
	 *
	 * @param by an address which burned some tokens (transaction sender)
	 * @param from an address the tokens were burnt from
	 * @param value an amount of tokens burnt
	 */
	event Burnt(address indexed by, address indexed from, uint256 value);

	/**
	 * @dev Resolution for the Multiple Withdrawal Attack on ERC20 Tokens (arXiv:1907.00903)
	 *
	 * @dev Similar to ERC20 Transfer event, but also logs an address which executed transfer
	 *
	 * @dev Fired in transfer(), transferFrom() and some other (non-ERC20) functions
	 *
	 * @param by an address which performed the transfer
	 * @param from an address tokens were consumed from
	 * @param to an address tokens were sent to
	 * @param value number of tokens transferred
	 */
	event Transfer(address indexed by, address indexed from, address indexed to, uint256 value);

	/**
	 * @dev Resolution for the Multiple Withdrawal Attack on ERC20 Tokens (arXiv:1907.00903)
	 *
	 * @dev Similar to ERC20 Approve event, but also logs old approval value
	 *
	 * @dev Fired in approve(), increaseAllowance(), decreaseAllowance() functions,
	 *      may get fired in transfer functions
	 *
	 * @param owner an address which granted a permission to transfer
	 *      tokens on its behalf
	 * @param spender an address which received a permission to transfer
	 *      tokens on behalf of the owner `owner`
	 * @param oldValue previously granted amount of tokens to transfer on behalf
	 * @param value new granted amount of tokens to transfer on behalf
	 */
	event Approval(address indexed owner, address indexed spender, uint256 oldValue, uint256 value);

	/**
	 * @dev Notifies that a key-value pair in `votingDelegates` mapping has changed,
	 *      i.e. a delegator address has changed its delegate address
	 *
	 * @param source delegator address, a token owner, effectively transaction sender (`by`)
	 * @param from old delegate, an address which delegate right is revoked
	 * @param to new delegate, an address which received the voting power
	 */
	event DelegateChanged(address indexed source, address indexed from, address indexed to);

	/**
	 * @dev Notifies that a key-value pair in `votingPowerHistory` mapping has changed,
	 *      i.e. a delegate's voting power has changed.
	 *
	 * @param by an address which executed delegate, mint, burn, or transfer operation
	 *      which had led to delegate voting power change
	 * @param target delegate whose voting power has changed
	 * @param fromVal previous number of votes delegate had
	 * @param toVal new number of votes delegate has
	 */
	event VotingPowerChanged(address indexed by, address indexed target, uint256 fromVal, uint256 toVal);

	/**
	 * @dev Deploys the token smart contract,
	 *      assigns initial token supply to the address specified
	 *
	 * @param contractOwner smart contract owner (has minting/burning and all other permissions)
	 * @param _name token name to set
	 * @param _symbol token symbol to set
	 * @param initialHolder owner of the initial token supply
	 * @param initialSupply initial token supply
	 * @param initialFeatures RBAC features enabled initially
	 */
	constructor(
		address contractOwner,
		string memory _name,
		string memory _symbol,
		address initialHolder,
		uint256 initialSupply,
		uint256 initialFeatures
	) {
		// delegate to the same `postConstruct` function which would be used
		// by all the proxies to be deployed and to be pointing to this impl
		postConstruct(contractOwner, _name, _symbol, initialHolder, initialSupply, initialFeatures);
	}

	/**
	 * @dev "Constructor replacement" for a smart contract with a delayed initialization (post-deployment initialization)
	 *
	 * @param contractOwner smart contract owner (has minting/burning and all other permissions)
	 * @param _name token name to set
	 * @param _symbol token symbol to set
	 * @param initialHolder owner of the initial token supply
	 * @param initialSupply initial token supply value
	 * @param initialFeatures RBAC features enabled initially
	 */
	function postConstruct(
		address contractOwner,
		string memory _name,
		string memory _symbol,
		address initialHolder,
		uint256 initialSupply,
		uint256 initialFeatures
	) public initializer {
		// verify name and symbol are set
		require(bytes(_name).length > 0, "token name is not set");
		require(bytes(_symbol).length > 0, "token symbol is not set");

		// assign token name and symbol
		name = _name;
		symbol = _symbol;

		// verify initial holder address non-zero (is set) if there is an initial supply to mint
		require(initialSupply == 0 || initialHolder != address(0), "_initialHolder not set (zero address)");

		// if there is an initial supply to mint
		if(initialSupply != 0) {
			// mint the initial supply
			__mint(initialHolder, initialSupply);
		}

		// if initial contract owner or features are specified
		if(contractOwner != address(0) || initialFeatures != 0) {
			// initialize the RBAC module
			_postConstruct(contractOwner, initialFeatures);
		}
	}

	/**
	 * @inheritdoc ERC165
	 */
	function supportsInterface(bytes4 interfaceId) public pure virtual override returns (bool) {
		// reconstruct from current interface(s) and super interface(s) (if any)
		return interfaceId == type(ERC165).interfaceId
		    || interfaceId == type(ERC20).interfaceId
		    || interfaceId == type(ERC1363).interfaceId
		    || interfaceId == type(EIP2612).interfaceId
		    || interfaceId == type(EIP3009).interfaceId;
	}

	// ===== Start: ERC-1363 functions =====

	/**
	 * @notice Transfers some tokens and then executes `onTransferReceived` callback on the receiver
	 *
	 * @inheritdoc ERC1363
	 *
	 * @dev Called by token owner (an address which has a
	 *      positive token balance tracked by this smart contract)
	 * @dev Throws on any error like
	 *      * insufficient token balance or
	 *      * incorrect `to` address:
	 *          * zero address or
	 *          * same as `from` address (self transfer)
	 *          * EOA or smart contract which doesn't support ERC1363Receiver interface
	 * @dev Returns true on success, throws otherwise
	 *
	 * @param to an address to transfer tokens to,
	 *      must be a smart contract, implementing the ERC1363Receiver interface
	 * @param value amount of tokens to be transferred, zero
	 *      value is allowed
	 * @return true unless throwing
	 */
	function transferAndCall(address to, uint256 value) public override returns (bool) {
		// delegate to `transferFromAndCall` passing `msg.sender` as `from`
		return transferFromAndCall(msg.sender, to, value);
	}

	/**
	 * @notice Transfers some tokens and then executes `onTransferReceived` callback on the receiver
	 *
	 * @inheritdoc ERC1363
	 *
	 * @dev Called by token owner (an address which has a
	 *      positive token balance tracked by this smart contract)
	 * @dev Throws on any error like
	 *      * insufficient token balance or
	 *      * incorrect `to` address:
	 *          * zero address or
	 *          * same as `from` address (self transfer)
	 *          * EOA or smart contract which doesn't support ERC1363Receiver interface
	 * @dev Returns true on success, throws otherwise
	 *
	 * @param to an address to transfer tokens to,
	 *      must be a smart contract, implementing the ERC1363Receiver interface
	 * @param value amount of tokens to be transferred, zero
	 *      value is allowed
	 * @param data [optional] additional data with no specified format,
	 *      sent in onTransferReceived call to `to`
	 * @return true unless throwing
	 */
	function transferAndCall(address to, uint256 value, bytes memory data) public override returns (bool) {
		// delegate to `transferFromAndCall` passing `msg.sender` as `from`
		return transferFromAndCall(msg.sender, to, value, data);
	}

	/**
	 * @notice Transfers some tokens on behalf of address `from' (token owner)
	 *      to some other address `to` and then executes `onTransferReceived` callback on the receiver
	 *
	 * @inheritdoc ERC1363
	 *
	 * @dev Called by token owner on his own or approved address,
	 *      an address approved earlier by token owner to
	 *      transfer some amount of tokens on its behalf
	 * @dev Throws on any error like
	 *      * insufficient token balance or
	 *      * incorrect `to` address:
	 *          * zero address or
	 *          * same as `from` address (self transfer)
	 *          * EOA or smart contract which doesn't support ERC1363Receiver interface
	 * @dev Returns true on success, throws otherwise
	 *
	 * @param from token owner which approved caller (transaction sender)
	 *      to transfer `value` of tokens on its behalf
	 * @param to an address to transfer tokens to,
	 *      must be a smart contract, implementing the ERC1363Receiver interface
	 * @param value amount of tokens to be transferred, zero
	 *      value is allowed
	 * @return true unless throwing
	 */
	function transferFromAndCall(address from, address to, uint256 value) public override returns (bool) {
		// delegate to `transferFromAndCall` passing empty data param
		return transferFromAndCall(from, to, value, "");
	}

	/**
	 * @notice Transfers some tokens on behalf of address `from' (token owner)
	 *      to some other address `to` and then executes a `onTransferReceived` callback on the receiver
	 *
	 * @inheritdoc ERC1363
	 *
	 * @dev Called by token owner on his own or approved address,
	 *      an address approved earlier by token owner to
	 *      transfer some amount of tokens on its behalf
	 * @dev Throws on any error like
	 *      * insufficient token balance or
	 *      * incorrect `to` address:
	 *          * zero address or
	 *          * same as `from` address (self transfer)
	 *          * EOA or smart contract which doesn't support ERC1363Receiver interface
	 * @dev Returns true on success, throws otherwise
	 *
	 * @param from token owner which approved caller (transaction sender)
	 *      to transfer `value` of tokens on its behalf
	 * @param to an address to transfer tokens to,
	 *      must be a smart contract, implementing the ERC1363Receiver interface
	 * @param value amount of tokens to be transferred, zero
	 *      value is allowed
	 * @param data [optional] additional data with no specified format,
	 *      sent in onTransferReceived call to `to`
	 * @return true unless throwing
	 */
	function transferFromAndCall(address from, address to, uint256 value, bytes memory data) public override returns (bool) {
		// ensure ERC-1363 transfers are enabled
		require(_isFeatureEnabled(FEATURE_ERC1363_TRANSFERS), "ERC1363 transfers are disabled");

		// first delegate call to `unsafeTransferFrom` to perform the unsafe token(s) transfer
		unsafeTransferFrom(from, to, value);

		// after the successful transfer - check if receiver supports
		// ERC1363Receiver and execute a callback handler `onTransferReceived`,
		// reverting whole transaction on any error
		_notifyTransferred(from, to, value, data, false);

		// function throws on any error, so if we're here - it means operation successful, just return true
		return true;
	}

	/**
	 * @notice Approves address called `spender` to transfer some amount
	 *      of tokens on behalf of the owner, then executes a `onApprovalReceived` callback on `spender`
	 *
	 * @inheritdoc ERC1363
	 *
	 * @dev Caller must not necessarily own any tokens to grant the permission
	 *
	 * @dev Throws if `spender` is an EOA or a smart contract which doesn't support ERC1363Spender interface
	 *
	 * @param spender an address approved by the caller (token owner)
	 *      to spend some tokens on its behalf
	 * @param value an amount of tokens spender `spender` is allowed to
	 *      transfer on behalf of the token owner
	 * @return true unless throwing
	 */
	function approveAndCall(address spender, uint256 value) public override returns (bool) {
		// delegate to `approveAndCall` passing empty data
		return approveAndCall(spender, value, "");
	}

	/**
	 * @notice Approves address called `spender` to transfer some amount
	 *      of tokens on behalf of the owner, then executes a callback on `spender`
	 *
	 * @inheritdoc ERC1363
	 *
	 * @dev Caller must not necessarily own any tokens to grant the permission
	 *
	 * @param spender an address approved by the caller (token owner)
	 *      to spend some tokens on its behalf
	 * @param value an amount of tokens spender `spender` is allowed to
	 *      transfer on behalf of the token owner
	 * @param data [optional] additional data with no specified format,
	 *      sent in onApprovalReceived call to `spender`
	 * @return true unless throwing
	 */
	function approveAndCall(address spender, uint256 value, bytes memory data) public override returns (bool) {
		// ensure ERC-1363 approvals are enabled
		require(_isFeatureEnabled(FEATURE_ERC1363_APPROVALS), "ERC1363 approvals are disabled");

		// execute regular ERC20 approve - delegate to `approve`
		approve(spender, value);

		// after the successful approve - check if receiver supports
		// ERC1363Spender and execute a callback handler `onApprovalReceived`,
		// reverting whole transaction on any error
		_notifyApproved(spender, value, data);

		// function throws on any error, so if we're here - it means operation successful, just return true
		return true;
	}

	/**
	 * @dev Auxiliary function to invoke `onTransferReceived` on a target address
	 *      The call is not executed if the target address is not a contract; in such
	 *      a case function throws if `allowEoa` is set to false, succeeds if it's true
	 *
	 * @dev Throws on any error; returns silently on success
	 *
	 * @param from representing the previous owner of the given token value
	 * @param to target address that will receive the tokens
	 * @param value the amount mount of tokens to be transferred
	 * @param data [optional] data to send along with the call
	 * @param allowEoa indicates if function should fail if `to` is an EOA
	 */
	function _notifyTransferred(address from, address to, uint256 value, bytes memory data, bool allowEoa) private {
		// if recipient `to` is EOA
		if(to.code.length == 0) { // !AddressUtils.isContract(_to)
			// ensure EOA recipient is allowed
			require(allowEoa, "EOA recipient");

			// exit if successful
			return;
		}

		// otherwise - if `to` is a contract - execute onTransferReceived
		bytes4 response = ERC1363Receiver(to).onTransferReceived(msg.sender, from, value, data);

		// expected response is ERC1363Receiver(_to).onTransferReceived.selector
		// bytes4(keccak256("onTransferReceived(address,address,uint256,bytes)"))
		require(response == ERC1363Receiver(to).onTransferReceived.selector, "invalid onTransferReceived response");
	}

	/**
	 * @dev Auxiliary function to invoke `onApprovalReceived` on a target address
	 *      The call is not executed if the target address is not a contract; in such
	 *      a case function throws if `allowEoa` is set to false, succeeds if it's true
	 *
	 * @dev Throws on any error; returns silently on success
	 *
	 * @param spender the address which will spend the funds
	 * @param value the amount of tokens to be spent
	 * @param data [optional] data to send along with the call
	 */
	function _notifyApproved(address spender, uint256 value, bytes memory data) private {
		// ensure recipient is not EOA
		require(spender.code.length > 0, "EOA spender"); // AddressUtils.isContract(_spender)

		// otherwise - if `to` is a contract - execute onApprovalReceived
		bytes4 response = ERC1363Spender(spender).onApprovalReceived(msg.sender, value, data);

		// expected response is ERC1363Spender(_to).onApprovalReceived.selector
		// bytes4(keccak256("onApprovalReceived(address,uint256,bytes)"))
		require(response == ERC1363Spender(spender).onApprovalReceived.selector, "invalid onApprovalReceived response");
	}
	// ===== End: ERC-1363 functions =====

	// ===== Start: ERC20 functions =====

	/**
	 * @notice Gets the balance of a particular address
	 *
	 * @inheritdoc ERC20
	 *
	 * @param owner the address to query the the balance for
	 * @return balance an amount of tokens owned by the address specified
	 */
	function balanceOf(address owner) public view override returns (uint256 balance) {
		// read the balance and return
		return tokenBalances[owner];
	}

	/**
	 * @notice Transfers some tokens to an external address or a smart contract
	 *
	 * @inheritdoc ERC20
	 *
	 * @dev Called by token owner (an address which has a
	 *      positive token balance tracked by this smart contract)
	 * @dev Throws on any error like
	 *      * insufficient token balance or
	 *      * incorrect `to` address:
	 *          * zero address or
	 *          * self address or
	 *          * smart contract which doesn't support ERC20
	 *
	 * @param to an address to transfer tokens to,
	 *      must be either an external address or a smart contract,
	 *      compliant with the ERC20 standard
	 * @param value amount of tokens to be transferred, zero
	 *      value is allowed
	 * @return success true on success, throws otherwise
	 */
	function transfer(address to, uint256 value) public override returns (bool success) {
		// just delegate call to `transferFrom`,
		// `FEATURE_TRANSFERS` is verified inside it
		return transferFrom(msg.sender, to, value);
	}

	/**
	 * @notice Transfers some tokens on behalf of address `from' (token owner)
	 *      to some other address `to`
	 *
	 * @inheritdoc ERC20
	 *
	 * @dev Called by token owner on his own or approved address,
	 *      an address approved earlier by token owner to
	 *      transfer some amount of tokens on its behalf
	 * @dev Throws on any error like
	 *      * insufficient token balance or
	 *      * incorrect `to` address:
	 *          * zero address or
	 *          * same as `from` address (self transfer)
	 *          * smart contract which doesn't support ERC20
	 *
	 * @param from token owner which approved caller (transaction sender)
	 *      to transfer `value` of tokens on its behalf
	 * @param to an address to transfer tokens to,
	 *      must be either an external address or a smart contract,
	 *      compliant with the ERC20 standard
	 * @param value amount of tokens to be transferred, zero
	 *      value is allowed
	 * @return success true on success, throws otherwise
	 */
	function transferFrom(address from, address to, uint256 value) public override returns (bool success) {
		// depending on `FEATURE_UNSAFE_TRANSFERS` we execute either safe (default)
		// or unsafe transfer
		// if `FEATURE_UNSAFE_TRANSFERS` is enabled
		// or receiver has `ROLE_ERC20_RECEIVER` permission
		// or sender has `ROLE_ERC20_SENDER` permission
		if(_isFeatureEnabled(FEATURE_UNSAFE_TRANSFERS)
			|| _isOperatorInRole(to, ROLE_ERC20_RECEIVER)
			|| _isSenderInRole(ROLE_ERC20_SENDER)) {
			// we execute unsafe transfer - delegate call to `unsafeTransferFrom`,
			// `FEATURE_TRANSFERS` is verified inside it
			unsafeTransferFrom(from, to, value);
		}
		// otherwise - if `FEATURE_UNSAFE_TRANSFERS` is disabled
		// and receiver doesn't have `ROLE_ERC20_RECEIVER` permission
		else {
			// we execute safe transfer - delegate call to `safeTransferFrom`, passing empty `data`,
			// `FEATURE_TRANSFERS` is verified inside it
			safeTransferFrom(from, to, value, "");
		}

		// both `unsafeTransferFrom` and `safeTransferFrom` throw on any error, so
		// if we're here - it means operation successful,
		// just return true
		return true;
	}

	/**
	 * @notice Transfers some tokens on behalf of address `from' (token owner)
	 *      to some other address `to` and then executes `onTransferReceived` callback
	 *      on the receiver if it is a smart contract (not an EOA)
	 *
	 * @dev Called by token owner on his own or approved address,
	 *      an address approved earlier by token owner to
	 *      transfer some amount of tokens on its behalf
	 * @dev Throws on any error like
	 *      * insufficient token balance or
	 *      * incorrect `to` address:
	 *          * zero address or
	 *          * same as `from` address (self transfer)
	 *          * smart contract which doesn't support ERC1363Receiver interface
	 * @dev Returns true on success, throws otherwise
	 *
	 * @param from token owner which approved caller (transaction sender)
	 *      to transfer `value` of tokens on its behalf
	 * @param to an address to transfer tokens to,
	 *      must be either an external address or a smart contract,
	 *      implementing ERC1363Receiver
	 * @param value amount of tokens to be transferred, zero
	 *      value is allowed
	 * @param data [optional] additional data with no specified format,
	 *      sent in onTransferReceived call to `to` in case if its a smart contract
	 * @return true unless throwing
	 */
	function safeTransferFrom(address from, address to, uint256 value, bytes memory data) public returns (bool) {
		// first delegate call to `unsafeTransferFrom` to perform the unsafe token(s) transfer
		unsafeTransferFrom(from, to, value);

		// after the successful transfer - check if receiver supports
		// ERC1363Receiver and execute a callback handler `onTransferReceived`,
		// reverting whole transaction on any error
		_notifyTransferred(from, to, value, data, true);

		// function throws on any error, so if we're here - it means operation successful, just return true
		return true;
	}

	/**
	 * @notice Transfers some tokens on behalf of address `from' (token owner)
	 *      to some other address `to`
	 *
	 * @dev In contrast to `transferFromAndCall` doesn't check recipient
	 *      smart contract to support ERC20 tokens (ERC1363Receiver)
	 * @dev Designed to be used by developers when the receiver is known
	 *      to support ERC20 tokens but doesn't implement ERC1363Receiver interface
	 * @dev Called by token owner on his own or approved address,
	 *      an address approved earlier by token owner to
	 *      transfer some amount of tokens on its behalf
	 * @dev Throws on any error like
	 *      * insufficient token balance or
	 *      * incorrect `to` address:
	 *          * zero address or
	 *          * same as `from` address (self transfer)
	 * @dev Returns silently on success, throws otherwise
	 *
	 * @param from token sender, token owner which approved caller (transaction sender)
	 *      to transfer `value` of tokens on its behalf
	 * @param to token receiver, an address to transfer tokens to
	 * @param value amount of tokens to be transferred, zero
	 *      value is allowed
	 */
	function unsafeTransferFrom(address from, address to, uint256 value) public {
		// make an internal transferFrom - delegate to `__transferFrom`
		__transferFrom(msg.sender, from, to, value);
	}

	/**
	 * @dev Powers the meta transactions for `unsafeTransferFrom` - EIP-3009 `transferWithAuthorization`
	 *      and `receiveWithAuthorization`
	 *
	 * @dev See `unsafeTransferFrom` and `transferFrom` soldoc for details
	 *
	 * @param by an address executing the transfer, it can be token owner itself,
	 *      or an operator previously approved with `approve()`
	 * @param from token sender, token owner which approved caller (transaction sender)
	 *      to transfer `value` of tokens on its behalf
	 * @param to token receiver, an address to transfer tokens to
	 * @param value amount of tokens to be transferred, zero
	 *      value is allowed
	 */
	function __transferFrom(address by, address from, address to, uint256 value) private {
		// if `from` is equal to sender, require transfers feature to be enabled
		// otherwise require transfers on behalf feature to be enabled
		require(from == by && _isFeatureEnabled(FEATURE_TRANSFERS)
		     || from != by && _isFeatureEnabled(FEATURE_TRANSFERS_ON_BEHALF),
		        from == by ? "transfers are disabled": "transfers on behalf are disabled");

		// non-zero source address check - Zeppelin
		// obviously, zero source address is a client mistake
		// it's not part of ERC20 standard but it's reasonable to fail fast
		// since for zero value transfer transaction succeeds otherwise
		require(from != address(0), "transfer from the zero address");

		// non-zero recipient address check
		require(to != address(0), "transfer to the zero address");

		// according to the Ethereum ERC20 token standard, it is possible to transfer
		// tokens to oneself using the transfer or transferFrom functions.
		// In both cases, the transfer will succeed as long as the sender has a sufficient balance of tokens.
		// require(_from != _to, "sender and recipient are the same (_from = _to)");

		// sending tokens to the token smart contract itself is a client mistake
		require(to != address(this), "invalid recipient (transfer to the token smart contract itself)");

		// according to ERC-20 Token Standard, https://eips.ethereum.org/EIPS/eip-20
		// "Transfers of 0 values MUST be treated as normal transfers and fire the Transfer event."
		if(value == 0) {
			// emit an improved transfer event (arXiv:1907.00903)
			emit Transfer(by, from, to, value);

			// emit an ERC20 transfer event
			emit Transfer(from, to, value);

			// don't forget to return - we're done
			return;
		}

		// no need to make arithmetic overflow check on the `value` - by design of mint()

		// in case of transfer on behalf
		if(from != by) {
			// read allowance value - the amount of tokens allowed to transfer - into the stack
			uint256 _allowance = transferAllowances[from][by];

			// verify sender has an allowance to transfer amount of tokens requested
			require(_allowance >= value, "transfer amount exceeds allowance");

			// we treat max uint256 allowance value as an "unlimited" and
			// do not decrease allowance when it is set to "unlimited" value
			if(_allowance < type(uint256).max) {
				// update allowance value on the stack
				_allowance -= value;

				// update the allowance value in storage
				transferAllowances[from][by] = _allowance;

				// emit an improved atomic approve event
				emit Approval(from, by, _allowance + value, _allowance);

				// emit an ERC20 approval event to reflect the decrease
				emit Approval(from, by, _allowance);
			}
		}

		// verify sender has enough tokens to transfer on behalf
		require(tokenBalances[from] >= value, "transfer amount exceeds balance");

		// perform the transfer:
		// decrease token owner (sender) balance
		tokenBalances[from] -= value;

		// increase `to` address (receiver) balance
		tokenBalances[to] += value;

		// move voting power associated with the tokens transferred
		__moveVotingPower(by, votingDelegates[from], votingDelegates[to], value);

		// emit an improved transfer event (arXiv:1907.00903)
		emit Transfer(by, from, to, value);

		// emit an ERC20 transfer event
		emit Transfer(from, to, value);
	}

	/**
	 * @notice Approves address called `spender` to transfer some amount
	 *      of tokens on behalf of the owner (transaction sender)
	 *
	 * @inheritdoc ERC20
	 *
	 * @dev Transaction sender must not necessarily own any tokens to grant the permission
	 *
	 * @param spender an address approved by the caller (token owner)
	 *      to spend some tokens on its behalf
	 * @param value an amount of tokens spender `spender` is allowed to
	 *      transfer on behalf of the token owner
	 * @return success true on success, throws otherwise
	 */
	function approve(address spender, uint256 value) public override returns (bool success) {
		// make an internal approve - delegate to `__approve`
		__approve(msg.sender, spender, value);

		// operation successful, return true
		return true;
	}

	/**
	 * @dev Powers the meta transaction for `approve` - EIP-2612 `permit`
	 *
	 * @dev Approves address called `spender` to transfer some amount
	 *      of tokens on behalf of the `owner`
	 *
	 * @dev `owner` must not necessarily own any tokens to grant the permission
	 * @dev Throws if `spender` is a zero address
	 *
	 * @param owner owner of the tokens to set approval on behalf of
	 * @param spender an address approved by the token owner
	 *      to spend some tokens on its behalf
	 * @param value an amount of tokens spender `spender` is allowed to
	 *      transfer on behalf of the token owner
	 */
	function __approve(address owner, address spender, uint256 value) private {
		// non-zero spender address check - Zeppelin
		// obviously, zero spender address is a client mistake
		// it's not part of ERC20 standard but it's reasonable to fail fast
		require(spender != address(0), "approve to the zero address");

		// read old approval value to emmit an improved event (arXiv:1907.00903)
		uint256 oldValue = transferAllowances[owner][spender];

		// perform an operation: write value requested into the storage
		transferAllowances[owner][spender] = value;

		// emit an improved atomic approve event (arXiv:1907.00903)
		emit Approval(owner, spender, oldValue, value);

		// emit an ERC20 approval event
		emit Approval(owner, spender, value);
	}

	/**
	 * @notice Returns the amount which spender is still allowed to withdraw from owner.
	 *
	 * @inheritdoc ERC20
	 *
	 * @dev A function to check an amount of tokens owner approved
	 *      to transfer on its behalf by some other address called "spender"
	 *
	 * @param owner an address which approves transferring some tokens on its behalf
	 * @param spender an address approved to transfer some tokens on behalf
	 * @return remaining an amount of tokens approved address `spender` can transfer on behalf
	 *      of token owner `owner`
	 */
	function allowance(address owner, address spender) public view override returns (uint256 remaining) {
		// read the value from storage and return
		return transferAllowances[owner][spender];
	}

	// ===== End: ERC20 functions =====

	// ===== Start: Resolution for the Multiple Withdrawal Attack on ERC20 Tokens (arXiv:1907.00903) =====

	/**
	 * @notice Increases the allowance granted to `spender` by the transaction sender
	 *
	 * @dev Resolution for the Multiple Withdrawal Attack on ERC20 Tokens (arXiv:1907.00903)
	 *
	 * @dev Throws if value to increase by is zero or too big and causes arithmetic overflow
	 *
	 * @param spender an address approved by the caller (token owner)
	 *      to spend some tokens on its behalf
	 * @param value an amount of tokens to increase by
	 * @return true unless throwing
	 */
	function increaseAllowance(address spender, uint256 value) public returns (bool) {
		// read current allowance value
		uint256 currentVal = transferAllowances[msg.sender][spender];

		// non-zero value and arithmetic overflow check on the allowance
		unchecked {
			// put operation into unchecked block to display user-friendly overflow error message for Solidity 0.8+
			require(currentVal + value > currentVal, "zero value approval increase or arithmetic overflow");
		}

		// delegate call to `approve` with the new value
		return approve(spender, currentVal + value);
	}

	/**
	 * @notice Decreases the allowance granted to `spender` by the caller.
	 *
	 * @dev Resolution for the Multiple Withdrawal Attack on ERC20 Tokens (arXiv:1907.00903)
	 *
	 * @dev Throws if value to decrease by is zero or is greater than currently allowed value
	 *
	 * @param spender an address approved by the caller (token owner)
	 *      to spend some tokens on its behalf
	 * @param value an amount of tokens to decrease by
	 * @return true unless throwing
	 */
	function decreaseAllowance(address spender, uint256 value) public returns (bool) {
		// read current allowance value
		uint256 currentVal = transferAllowances[msg.sender][spender];

		// non-zero value check on the allowance
		require(value > 0, "zero value approval decrease");

		// verify allowance decrease doesn't underflow
		require(currentVal >= value, "ERC20: decreased allowance below zero");

		// delegate call to `approve` with the new value
		return approve(spender, currentVal - value);
	}

	// ===== End: Resolution for the Multiple Withdrawal Attack on ERC20 Tokens (arXiv:1907.00903) =====

	// ===== Start: Minting/burning extension =====

	/**
	 * @dev Mints (creates) some tokens to address specified
	 * @dev The value specified is treated as is without taking
	 *      into account what `decimals` value is
	 *
	 * @dev Requires executor to have `ROLE_TOKEN_CREATOR` permission
	 *
	 * @dev Throws on overflow, if totalSupply + value doesn't fit into uint192
	 *
	 * @param to the destination address to mint tokens to
	 * @param value an amount of tokens to mint (create)
	 * @return success true on success, throws otherwise
	 */
	function mint(address to, uint256 value) public override virtual returns(bool success) {
		// check if caller has sufficient permissions to mint tokens
		require(_isSenderInRole(ROLE_TOKEN_CREATOR), "access denied");

		// delegate call to unsafe `__mint`
		__mint(to, value);

		// always return true
		return true;
	}

	/**
	 * @dev Mints (creates) some tokens and then executes `onTransferReceived` callback on the receiver,
	 *      passing zero address as the token source address `from`
	 * @dev The value specified is treated as is without taking into account what `decimals` value is
	 *
	 * @dev Requires executor to have `ROLE_TOKEN_CREATOR` permission
	 * @dev Throws on overflow, if totalSupply + value doesn't fit into uint192
	 * @dev Throws if the destination address `to` is a smart contract not supporting ERC1363Receiver interface
	 *
	 * @param to the destination address to mint tokens to, can be an EAO
	 *      or a smart contract, implementing the ERC1363Receiver interface
	 * @param value amount of tokens to mint (create)
	 * @return success true on success, throws otherwise
	 */
	function safeMint(address to, uint256 value, bytes memory data) public virtual returns(bool success) {
		// first delegate call to `mint` to perform regular minting
		mint(to, value);

		// after the successful minting - check if receiver supports
		// ERC1363Receiver and execute a callback handler `onTransferReceived`,
		// reverting whole transaction on any error
		_notifyTransferred(address(0), to, value, data, true);

		// function throws on any error, so if we're here - it means operation successful, just return true
		return true;
	}

	/**
	 * @dev Mints (creates) some tokens and then executes `onTransferReceived` callback on the receiver,
	 *      passing zero address as the token source address `from`
	 * @dev The value specified is treated as is without taking into account what `decimals` value is
	 *
	 * @dev Requires executor to have `ROLE_TOKEN_CREATOR` permission
	 * @dev Throws on overflow, if totalSupply + value doesn't fit into uint192
	 * @dev Throws if the destination address `to` is EOA or smart contract not supporting ERC1363Receiver interface
	 *
	 * @param to the destination address to mint tokens to,
	 *      must be a smart contract, implementing the ERC1363Receiver interface
	 * @param value amount of tokens to mint (create)
	 * @return success true on success, throws otherwise
	 */
	function mintAndCall(address to, uint256 value) public override virtual returns (bool success) {
		// delegate to `mintAndCall` passing empty data param
		return mintAndCall(to, value, "");
	}

	/**
	 * @dev Mints (creates) some tokens and then executes `onTransferReceived` callback on the receiver,
	 *      passing zero address as the token source address `from`
	 * @dev The value specified is treated as is without taking into account what `decimals` value is
	 *
	 * @dev Requires executor to have `ROLE_TOKEN_CREATOR` permission
	 * @dev Throws on overflow, if totalSupply + value doesn't fit into uint192
	 * @dev Throws if the destination address `to` is EOA or smart contract not supporting ERC1363Receiver interface
	 *
	 * @param to the destination address to mint tokens to,
	 *      must be a smart contract, implementing the ERC1363Receiver interface
	 * @param value amount of tokens to mint (create)
	 * @param data [optional] additional data with no specified format,
	 *      sent in onTransferReceived call to `to`
	 * @return success true on success, throws otherwise
	 */
	function mintAndCall(address to, uint256 value, bytes memory data) public override virtual returns (bool success) {
		// first delegate call to `mint` to perform regular minting
		mint(to, value);

		// after the successful minting - check if receiver supports
		// ERC1363Receiver and execute a callback handler `onTransferReceived`,
		// reverting whole transaction on any error
		_notifyTransferred(address(0), to, value, data, false);

		// function throws on any error, so if we're here - it means operation successful, just return true
		return true;
	}

	/**
	 * @dev Mints (creates) some tokens to address specified
	 * @dev The value specified is treated as is without taking
	 *      into account what `decimals` value is
	 *
	 * @dev Unsafe: doesn't verify the executor (msg.sender) permissions,
	 *      must be kept private at all times
	 *
	 * @dev Throws on overflow, if totalSupply + value doesn't fit into uint256
	 *
	 * @param to an address to mint tokens to
	 * @param value an amount of tokens to mint (create)
	 */
	function __mint(address to, uint256 value) private {
		// non-zero recipient address check
		require(to != address(0), "zero address");

		// non-zero value and arithmetic overflow check on the total supply
		// this check automatically secures arithmetic overflow on the individual balance
		unchecked {
			// put operation into unchecked block to display user-friendly overflow error message for Solidity 0.8+
			require(totalSupply + value > totalSupply, "zero value or arithmetic overflow");
		}

		// uint192 overflow check (required by voting delegation)
		require(totalSupply + value <= type(uint192).max, "total supply overflow (uint192)");

		// perform mint:
		// increase total amount of tokens value
		totalSupply += value;

		// increase `to` address balance
		tokenBalances[to] += value;

		// update total token supply history
		__updateHistory(totalSupplyHistory, add, value);

		// create voting power associated with the tokens minted
		__moveVotingPower(msg.sender, address(0), votingDelegates[to], value);

		// fire a minted event
		emit Minted(msg.sender, to, value);

		// emit an improved transfer event (arXiv:1907.00903)
		emit Transfer(msg.sender, address(0), to, value);

		// fire ERC20 compliant transfer event
		emit Transfer(address(0), to, value);
	}

	/**
	 * @dev Burns (destroys) some tokens from the address specified
	 *
	 * @dev The value specified is treated as is without taking
	 *      into account what `decimals` value is
	 *
	 * @dev Requires executor to have `ROLE_TOKEN_DESTROYER` permission
	 *      or FEATURE_OWN_BURNS/FEATURE_BURNS_ON_BEHALF features to be enabled
	 *
	 * @dev Can be disabled by the contract creator forever by disabling
	 *      FEATURE_OWN_BURNS/FEATURE_BURNS_ON_BEHALF features and then revoking
	 *      its own roles to burn tokens and to enable burning features
	 *
	 * @param from an address to burn some tokens from
	 * @param value an amount of tokens to burn (destroy)
	 * @return success true on success, throws otherwise
	 */
	function burn(address from, uint256 value) public override virtual returns(bool success) {
		// check if caller has sufficient permissions to burn tokens
		// and if not - check for possibility to burn own tokens or to burn on behalf
		if(!_isSenderInRole(ROLE_TOKEN_DESTROYER)) {
			// if `from` is equal to sender, require own burns feature to be enabled
			// otherwise require burns on behalf feature to be enabled
			require(from == msg.sender && _isFeatureEnabled(FEATURE_OWN_BURNS)
			     || from != msg.sender && _isFeatureEnabled(FEATURE_BURNS_ON_BEHALF),
			        from == msg.sender? "burns are disabled": "burns on behalf are disabled");

			// in case of burn on behalf
			if(from != msg.sender) {
				// read allowance value - the amount of tokens allowed to be burnt - into the stack
				uint256 _allowance = transferAllowances[from][msg.sender];

				// verify sender has an allowance to burn amount of tokens requested
				require(_allowance >= value, "burn amount exceeds allowance");

				// we treat max uint256 allowance value as an "unlimited" and
				// do not decrease allowance when it is set to "unlimited" value
				if(_allowance < type(uint256).max) {
					// update allowance value on the stack
					_allowance -= value;

					// update the allowance value in storage
					transferAllowances[from][msg.sender] = _allowance;

					// emit an improved atomic approve event (arXiv:1907.00903)
					emit Approval(msg.sender, from, _allowance + value, _allowance);

					// emit an ERC20 approval event to reflect the decrease
					emit Approval(from, msg.sender, _allowance);
				}
			}
		}

		// at this point we know that either sender is ROLE_TOKEN_DESTROYER or
		// we burn own tokens or on behalf (in latest case we already checked and updated allowances)
		// we have left to execute balance checks and burning logic itself

		// non-zero burn value check
		require(value != 0, "zero value burn");

		// non-zero source address check - Zeppelin
		require(from != address(0), "burn from the zero address");

		// verify `from` address has enough tokens to destroy
		// (basically this is a arithmetic overflow check)
		require(tokenBalances[from] >= value, "burn amount exceeds balance");

		// perform burn:
		// decrease `from` address balance
		tokenBalances[from] -= value;

		// decrease total amount of tokens value
		totalSupply -= value;

		// update total token supply history
		__updateHistory(totalSupplyHistory, sub, value);

		// destroy voting power associated with the tokens burnt
		__moveVotingPower(msg.sender, votingDelegates[from], address(0), value);

		// fire a burnt event
		emit Burnt(msg.sender, from, value);

		// emit an improved transfer event (arXiv:1907.00903)
		emit Transfer(msg.sender, from, address(0), value);

		// fire ERC20 compliant transfer event
		emit Transfer(from, address(0), value);

		// always return true
		return true;
	}

	// ===== End: Minting/burning extension =====

	// ===== Start: EIP-2612 functions =====

	/**
	 * @inheritdoc EIP2612
	 *
	 * @dev Executes approve(spender, value) on behalf of the owner who EIP-712
	 *      signed the transaction, i.e. as if transaction sender is the EIP712 signer
	 *
	 * @dev Sets the `value` as the allowance of `spender` over `owner` tokens,
	 *      given `owner` EIP-712 signed approval
	 *
	 * @dev Inherits the Multiple Withdrawal Attack on ERC20 Tokens (arXiv:1907.00903)
	 *      vulnerability in the same way as ERC20 `approve`, use standard ERC20 workaround
	 *      if this might become an issue:
	 *      https://docs.google.com/document/d/1YLPtQxZu1UAvO9cZ1O2RPXBbT0mooh4DYKjA_jp-RLM/edit
	 *
	 * @dev Emits `Approval` event(s) in the same way as `approve` does
	 *
	 * @dev Requires:
	 *     - `spender` to be non-zero address
	 *     - `exp` to be a timestamp in the future
	 *     - `v`, `r` and `s` to be a valid `secp256k1` signature from `owner`
	 *        over the EIP712-formatted function arguments.
	 *     - the signature to use `owner` current nonce (see `nonces`).
	 *
	 * @dev For more information on the signature format, see the
	 *      https://eips.ethereum.org/EIPS/eip-2612#specification
	 *
	 * @param owner owner of the tokens to set approval on behalf of,
	 *      an address which signed the EIP-712 message
	 * @param spender an address approved by the token owner
	 *      to spend some tokens on its behalf
	 * @param value an amount of tokens spender `spender` is allowed to
	 *      transfer on behalf of the token owner
	 * @param exp signature expiration time (unix timestamp)
	 * @param v the recovery byte of the signature
	 * @param r half of the ECDSA signature pair
	 * @param s half of the ECDSA signature pair
	 */
	function permit(address owner, address spender, uint256 value, uint256 exp, uint8 v, bytes32 r, bytes32 s) public override {
		// verify permits are enabled
		require(_isFeatureEnabled(FEATURE_EIP2612_PERMITS), "EIP2612 permits are disabled");

		// derive signer of the EIP712 Permit message, and
		// update the nonce for that particular signer to avoid replay attack!!! --------->>> ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
		address signer = __deriveSigner(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, exp), v, r, s);

		// perform message integrity and security validations
		require(signer == owner, "invalid signature");
		require(block.timestamp < exp, "signature expired");

		// delegate call to `__approve` - execute the logic required
		__approve(owner, spender, value);
	}

	// ===== End: EIP-2612 functions =====

	// ===== Start: EIP-3009 functions =====

	/**
	 * @inheritdoc EIP3009
	 *
	 * @notice Checks if specified nonce was already used
	 *
	 * @dev Nonces are expected to be client-side randomly generated 32-byte values
	 *      unique to the authorizer's address
	 *
	 * @dev Alias for usedNonces(authorizer, nonce)
	 *
	 * @param authorizer an address to check nonce for
	 * @param nonce a nonce to check
	 * @return true if the nonce was used, false otherwise
	 */
	function authorizationState(address authorizer, bytes32 nonce) public override view returns (bool) {
		// simply return the value from the mapping
		return usedNonces[authorizer][nonce];
	}

	/**
	 * @inheritdoc EIP3009
	 *
	 * @notice Execute a transfer with a signed authorization
	 *
	 * @param from token sender and transaction authorizer
	 * @param to token receiver
	 * @param value amount to be transferred
	 * @param validAfter signature valid after time (unix timestamp)
	 * @param validBefore signature valid before time (unix timestamp)
	 * @param nonce unique random nonce
	 * @param v the recovery byte of the signature
	 * @param r half of the ECDSA signature pair
	 * @param s half of the ECDSA signature pair
	 */
	function transferWithAuthorization(
		address from,
		address to,
		uint256 value,
		uint256 validAfter,
		uint256 validBefore,
		bytes32 nonce,
		uint8 v,
		bytes32 r,
		bytes32 s
	) public override {
		// ensure EIP-3009 transfers are enabled
		require(_isFeatureEnabled(FEATURE_EIP3009_TRANSFERS), "EIP3009 transfers are disabled");

		// derive signer of the EIP712 TransferWithAuthorization message
		address signer = __deriveSigner(abi.encode(TRANSFER_WITH_AUTHORIZATION_TYPEHASH, from, to, value, validAfter, validBefore, nonce), v, r, s);

		// perform message integrity and security validations
		require(signer == from, "invalid signature");
		require(block.timestamp > validAfter, "signature not yet valid");
		require(block.timestamp < validBefore, "signature expired");

		// use the nonce supplied (verify, mark as used, emit event)
		__useNonce(from, nonce, false);

		// delegate call to `__transferFrom` - execute the logic required
		__transferFrom(signer, from, to, value);
	}

	/**
	 * @inheritdoc EIP3009
	 *
	 * @notice Receive a transfer with a signed authorization from the payer
	 *
	 * @dev This has an additional check to ensure that the payee's address
	 *      matches the caller of this function to prevent front-running attacks.
	 *
	 * @param from token sender and transaction authorizer
	 * @param to token receiver
	 * @param value amount to be transferred
	 * @param validAfter signature valid after time (unix timestamp)
	 * @param validBefore signature valid before time (unix timestamp)
	 * @param nonce unique random nonce
	 * @param v the recovery byte of the signature
	 * @param r half of the ECDSA signature pair
	 * @param s half of the ECDSA signature pair
	 */
	function receiveWithAuthorization(
		address from,
		address to,
		uint256 value,
		uint256 validAfter,
		uint256 validBefore,
		bytes32 nonce,
		uint8 v,
		bytes32 r,
		bytes32 s
	) public override {
		// verify EIP3009 receptions are enabled
		require(_isFeatureEnabled(FEATURE_EIP3009_RECEPTIONS), "EIP3009 receptions are disabled");

		// derive signer of the EIP712 ReceiveWithAuthorization message
		address signer = __deriveSigner(abi.encode(RECEIVE_WITH_AUTHORIZATION_TYPEHASH, from, to, value, validAfter, validBefore, nonce), v, r, s);

		// perform message integrity and security validations
		require(signer == from, "invalid signature");
		require(block.timestamp > validAfter, "signature not yet valid");
		require(block.timestamp < validBefore, "signature expired");
		require(to == msg.sender, "access denied");

		// use the nonce supplied (verify, mark as used, emit event)
		__useNonce(from, nonce, false);

		// delegate call to `__transferFrom` - execute the logic required
		__transferFrom(signer, from, to, value);
	}

	/**
	 * @inheritdoc EIP3009
	 *
	 * @notice Attempt to cancel an authorization
	 *
	 * @param authorizer transaction authorizer
	 * @param nonce unique random nonce to cancel (mark as used)
	 * @param v the recovery byte of the signature
	 * @param r half of the ECDSA signature pair
	 * @param s half of the ECDSA signature pair
	 */
	function cancelAuthorization(
		address authorizer,
		bytes32 nonce,
		uint8 v,
		bytes32 r,
		bytes32 s
	) public override {
		// derive signer of the EIP712 ReceiveWithAuthorization message
		address signer = __deriveSigner(abi.encode(CANCEL_AUTHORIZATION_TYPEHASH, authorizer, nonce), v, r, s);

		// perform message integrity and security validations
		require(signer == authorizer, "invalid signature");

		// cancel the nonce supplied (verify, mark as used, emit event)
		__useNonce(authorizer, nonce, true);
	}

	/**
	 * @dev Auxiliary function to verify structured EIP712 message signature and derive its signer
	 *
	 * @dev Recovers the non-zero signer address from the signed message throwing on failure
	 *
	 * @param abiEncodedTypehash abi.encode of the message typehash together with all its parameters
	 * @param v the recovery byte of the signature
	 * @param r half of the ECDSA signature pair
	 * @param s half of the ECDSA signature pair
	 * @return recovered non-zero signer address, unless throwing
	 */
	function __deriveSigner(bytes memory abiEncodedTypehash, uint8 v, bytes32 r, bytes32 s) private view returns(address) {
		// build the EIP-712 hashStruct of the message
		bytes32 hashStruct = keccak256(abiEncodedTypehash);

		// calculate the EIP-712 digest "\x19\x01" ‖ domainSeparator ‖ hashStruct(message)
		bytes32 digest = keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR(), hashStruct));

		// recover the address which signed the message with v, r, s
		address signer = ECDSA.recover(digest, v, r, s);

		// according to the specs, zero address must be rejected when using ecrecover
		// this check already happened inside `ECDSA.recover`

		// return the signer address derived from the signature
		return signer;
	}

	/**
	 * @dev Auxiliary function to use/cancel the nonce supplied for a given authorizer:
	 *      1. Verifies the nonce was not used before
	 *      2. Marks the nonce as used
	 *      3. Emits an event that the nonce was used/cancelled
	 *
	 * @dev Set `cancellation` to false (default) to use nonce,
	 *      set `cancellation` to true to cancel nonce
	 *
	 * @dev It is expected that the nonce supplied is a randomly
	 *      generated uint256 generated by the client
	 *
	 * @param authorizer an address to use/cancel nonce for
	 * @param nonce random nonce to use
	 * @param cancellation true to emit `AuthorizationCancelled`, false to emit `AuthorizationUsed` event
	 */
	function __useNonce(address authorizer, bytes32 nonce, bool cancellation) private {
		// verify nonce was not used before
		require(!usedNonces[authorizer][nonce], "invalid nonce");

		// update the nonce state to "used" for that particular signer to avoid replay attack
		usedNonces[authorizer][nonce] = true;

		// depending on the usage type (use/cancel)
		if(cancellation) {
			// emit an event regarding the nonce cancelled
			emit AuthorizationCanceled(authorizer, nonce);
		}
		else {
			// emit an event regarding the nonce used
			emit AuthorizationUsed(authorizer, nonce);
		}
	}

	// ===== End: EIP-3009 functions =====

	// ===== Start: DAO Support (Compound-like voting delegation) =====

	/**
	 * @notice Gets current voting power of the account `holder`
	 *
	 * @param holder the address of account to get voting power of
	 * @return current cumulative voting power of the account,
	 *      sum of token balances of all its voting delegators
	 */
	function votingPowerOf(address holder) public view returns (uint256) {
		// get a link to an array of voting power history records for an address specified
		KV[] storage history = votingPowerHistory[holder];

		// lookup the history and return latest element
		return history.length == 0? 0: history[history.length - 1].v;
	}

	/**
	 * @notice Gets past voting power of the account `holder` at some block `blockNum`
	 *
	 * @dev Throws if `blockNum` is not in the past (not the finalized block)
	 *
	 * @param holder the address of account to get voting power of
	 * @param blockNum block number to get the voting power at
	 * @return past cumulative voting power of the account,
	 *      sum of token balances of all its voting delegators at block number `blockNum`
	 */
	function votingPowerAt(address holder, uint256 blockNum) public view returns (uint256) {
		// make sure block number is in the past (the finalized block)
		require(blockNum < block.number, "block not yet mined"); // Compound msg not yet determined

		// `votingPowerHistory[holder]` is an array ordered by `blockNumber`, ascending;
		// apply binary search on `votingPowerHistory[_of]` to find such an entry number `i`, that
		// `votingPowerHistory[holder][i].k ≤ blockNum`, but in the same time
		// `votingPowerHistory[holder][i + 1].k > blockNum`
		// return the result - voting power found at index `i`
		return __binaryLookup(votingPowerHistory[holder], blockNum);
	}

	/**
	 * @dev Reads an entire voting power history array for the delegate specified
	 *
	 * @param holder delegate to query voting power history for
	 * @return voting power history array for the delegate of interest
	 */
	function votingPowerHistoryOf(address holder) public view returns(KV[] memory) {
		// return an entire array as memory
		return votingPowerHistory[holder];
	}

	/**
	 * @dev Returns length of the voting power history array for the delegate specified;
	 *      useful since reading an entire array just to get its length is expensive (gas cost)
	 *
	 * @param holder delegate to query voting power history length for
	 * @return voting power history array length for the delegate of interest
	 */
	function votingPowerHistoryLength(address holder) public view returns(uint256) {
		// read array length and return
		return votingPowerHistory[holder].length;
	}

	/**
	 * @notice Gets past total token supply value at some block `blockNum`
	 *
	 * @dev Throws if `blockNum` is not in the past (not the finalized block)
	 *
	 * @param blockNum block number to get the total token supply at
	 * @return past total token supply at block number `blockNum`
	 */
	function totalSupplyAt(uint256 blockNum) public view returns(uint256) {
		// make sure block number is in the past (the finalized block)
		require(blockNum < block.number, "block not yet mined");

		// `totalSupplyHistory` is an array ordered by `k`, ascending;
		// apply binary search on `totalSupplyHistory` to find such an entry number `i`, that
		// `totalSupplyHistory[i].k ≤ blockNum`, but in the same time
		// `totalSupplyHistory[i + 1].k > blockNum`
		// return the result - value `totalSupplyHistory[i].v` found at index `i`
		return __binaryLookup(totalSupplyHistory, blockNum);
	}

	/**
	 * @dev Reads an entire total token supply history array
	 *
	 * @return total token supply history array, a key-value pair array,
	 *      where key is a block number and value is total token supply at that block
	 */
	function entireSupplyHistory() public view returns(KV[] memory) {
		// return an entire array as memory
		return totalSupplyHistory;
	}

	/**
	 * @dev Returns length of the total token supply history array;
	 *      useful since reading an entire array just to get its length is expensive (gas cost)
	 *
	 * @return total token supply history array
	 */
	function totalSupplyHistoryLength() public view returns(uint256) {
		// read array length and return
		return totalSupplyHistory.length;
	}

	/**
	 * @notice Delegates voting power of the delegator `msg.sender` to the delegate `to`
	 *
	 * @dev Accepts zero value address to delegate voting power to, effectively
	 *      removing the delegate in that case
	 *
	 * @param to address to delegate voting power to
	 */
	function delegate(address to) public {
		// verify delegations are enabled
		require(_isFeatureEnabled(FEATURE_DELEGATIONS), "delegations are disabled");
		// delegate call to `__delegate`
		__delegate(msg.sender, to);
	}

	/**
	 * @dev Powers the meta transaction for `delegate` - `delegateWithAuthorization`
	 *
	 * @dev Auxiliary function to delegate delegator's `from` voting power to the delegate `to`
	 * @dev Writes to `votingDelegates` and `votingPowerHistory` mappings
	 *
	 * @param from delegator who delegates his voting power
	 * @param to delegate who receives the voting power
	 */
	function __delegate(address from, address to) private {
		// read current delegate to be replaced by a new one
		address fromDelegate = votingDelegates[from];

		// read current voting power (it is equal to token balance)
		uint256 value = tokenBalances[from];

		// reassign voting delegate to `to`
		votingDelegates[from] = to;

		// update voting power for `fromDelegate` and `to`
		__moveVotingPower(from, fromDelegate, to, value);

		// emit an event
		emit DelegateChanged(from, fromDelegate, to);
	}

	/**
	 * @notice Delegates voting power of the delegator (represented by its signature) to the delegate `to`
	 *
	 * @dev Accepts zero value address to delegate voting power to, effectively
	 *      removing the delegate in that case
	 *
	 * @dev Compliant with EIP-712: Ethereum typed structured data hashing and signing,
	 *      see https://eips.ethereum.org/EIPS/eip-712
	 *
	 * @param to address to delegate voting power to
	 * @param nonce nonce used to construct the signature, and used to validate it;
	 *      nonce is increased by one after successful signature validation and vote delegation
	 * @param exp signature expiration time
	 * @param v the recovery byte of the signature
	 * @param r half of the ECDSA signature pair
	 * @param s half of the ECDSA signature pair
	 */
	function delegateWithAuthorization(address to, bytes32 nonce, uint256 exp, uint8 v, bytes32 r, bytes32 s) public {
		// verify delegations on behalf are enabled
		require(_isFeatureEnabled(FEATURE_DELEGATIONS_ON_BEHALF), "delegations on behalf are disabled");

		// derive signer of the EIP712 Delegation message
		address signer = __deriveSigner(abi.encode(DELEGATION_TYPEHASH, to, nonce, exp), v, r, s);

		// perform message integrity and security validations
		require(block.timestamp < exp, "signature expired"); // Compound msg

		// use the nonce supplied (verify, mark as used, emit event)
		__useNonce(signer, nonce, false);

		// delegate call to `__delegate` - execute the logic required
		__delegate(signer, to);
	}

	/**
	 * @dev Auxiliary function to move voting power `value`
	 *      from delegate `from` to the delegate `to`
	 *
	 * @dev Doesn't have any effect if `from == to`, or if `value == 0`
	 *
	 * @param by an address which executed delegate, mint, burn, or transfer operation
	 *      which had led to delegate voting power change
	 * @param from delegate to move voting power from
	 * @param to delegate to move voting power to
	 * @param value voting power to move from `from` to `to`
	 */
	function __moveVotingPower(address by, address from, address to, uint256 value) private {
		// if there is no move (`from == to`) or there is nothing to move (`value == 0`)
		if(from == to || value == 0) {
			// return silently with no action
			return;
		}

		// if source address is not zero - decrease its voting power
		if(from != address(0)) {
			// get a link to an array of voting power history records for an address specified
			KV[] storage h = votingPowerHistory[from];

			// update source voting power: decrease by `value`
			(uint256 fromVal, uint256 toVal) = __updateHistory(h, sub, value);

			// emit an event
			emit VotingPowerChanged(by, from, fromVal, toVal);
		}

		// if destination address is not zero - increase its voting power
		if(to != address(0)) {
			// get a link to an array of voting power history records for an address specified
			KV[] storage h = votingPowerHistory[to];

			// update destination voting power: increase by `value`
			(uint256 fromVal, uint256 toVal) = __updateHistory(h, add, value);

			// emit an event
			emit VotingPowerChanged(by, to, fromVal, toVal);
		}
	}

	/**
	 * @dev Auxiliary function to append key-value pair to an array,
	 *      sets the key to the current block number and
	 *      value as derived
	 *
	 * @param h array of key-value pairs to append to
	 * @param op a function (add/subtract) to apply
	 * @param delta the value for a key-value pair to add/subtract
	 */
	function __updateHistory(
		KV[] storage h,
		function(uint256,uint256) pure returns(uint256) op,
		uint256 delta
	) private returns(uint256 fromVal, uint256 toVal) {
		// init the old value - value of the last pair of the array
		fromVal = h.length == 0? 0: h[h.length - 1].v;
		// init the new value - result of the operation on the old value
		toVal = op(fromVal, delta);

		// if there is an existing voting power value stored for current block
		if(h.length != 0 && h[h.length - 1].k == block.number) {
			// update voting power which is already stored in the current block
			h[h.length - 1].v = uint192(toVal);
		}
		// otherwise - if there is no value stored for current block
		else {
			// add new element into array representing the value for current block
			h.push(KV(uint64(block.number), uint192(toVal)));
		}
	}

	/**
	 * @dev Auxiliary function to lookup for a value in a sorted by key (ascending)
	 *      array of key-value pairs
	 *
	 * @dev This function finds a key-value pair element in an array with the closest key
	 *      to the key of interest (not exceeding that key) and returns the value
	 *      of the key-value pair element found
	 *
	 * @dev An array to search in is a KV[] key-value pair array ordered by key `k`,
	 *      it is sorted in ascending order (`k` increases as array index increases)
	 *
	 * @dev Returns zero for an empty array input regardless of the key input
	 *
	 * @param h an array of key-value pair elements to search in
	 * @param k key of interest to look the value for
	 * @return the value of the key-value pair of the key-value pair element with the closest
	 *      key to the key of interest (not exceeding that key)
	 */
	function __binaryLookup(KV[] storage h, uint256 k) private view returns(uint256) {
		// if an array is empty, there is nothing to lookup in
		if(h.length == 0) {
			// by documented agreement, fall back to a zero result
			return 0;
		}

		// check last key-value pair key:
		// if the key is smaller than the key of interest
		if(h[h.length - 1].k <= k) {
			// we're done - return the value from the last element
			return h[h.length - 1].v;
		}

		// check first voting power history record block number:
		// if history was never updated before the block of interest
		if(h[0].k > k) {
			// we're done - voting power at the block num of interest was zero
			return 0;
		}

		// left bound of the search interval, originally start of the array
		uint256 i = 0;

		// right bound of the search interval, originally end of the array
		uint256 j = h.length - 1;

		// the iteration process narrows down the bounds by
		// splitting the interval in a half oce per each iteration
		while(j > i) {
			// get an index in the middle of the interval [i, j]
			uint256 m = j - (j - i) / 2;

			// read an element to compare it with the value of interest
			KV memory kv = h[m];

			// if we've got a strict equal - we're lucky and done
			if(kv.k == k) {
				// just return the result - pair value at index `k`
				return kv.v;
			}
			// if the value of interest is larger - move left bound to the middle
			else if(kv.k < k) {
				// move left bound `i` to the middle position `k`
				i = m;
			}
			// otherwise, when the value of interest is smaller - move right bound to the middle
			else {
				// move right bound `j` to the middle position `k - 1`:
				// element at position `k` is greater and cannot be the result
				j = m - 1;
			}
		}

		// reaching that point means no exact match found
		// since we're interested in the element which is not larger than the
		// element of interest, we return the lower bound `i`
		return h[i].v;
	}

	/**
	 * @dev Adds a + b
	 *      Function is used as a parameter for other functions
	 *
	 * @param a addition term 1
	 * @param b addition term 2
	 * @return a + b
	 */
	function add(uint256 a, uint256 b) private pure returns(uint256) {
		// add `a` to `b` and return
		return a + b;
	}

	/**
	 * @dev Subtracts a - b
	 *      Function is used as a parameter for other functions
	 *
	 * @dev Requires a ≥ b
	 *
	 * @param a subtraction term 1
	 * @param b subtraction term 2, b ≤ a
	 * @return a - b
	 */
	function sub(uint256 a, uint256 b) private pure returns(uint256) {
		// subtract `b` from `a` and return
		return a - b;
	}

	// ===== End: DAO Support (Compound-like voting delegation) =====
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

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
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
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
// OpenZeppelin Contracts (last updated v4.9.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
     *
     * Furthermore, `isContract` will also return true if the target contract within
     * the same transaction is already scheduled for destruction by `SELFDESTRUCT`,
     * which only has an effect at the end of a transaction.
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.0/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
        return functionCallWithValue(target, data, 0, errorMessage);
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@lazy-sol/advanced-erc20/contracts/token/AdvancedERC20.sol";

/**
 *                                                                                                               
 *                                            ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑                                            
 *                                      ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑                                     
 *                                ↑↑↑↑↑↑↑↑↑↑↑↑↑                     ↑↑↑↑↑↑↑↑↑↑↑↑↑↑                               
 *                             ↑↑↑↑↑↑↑↑↑↑↑     ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑        ↑↑↑↑↑↑↑↑↑↑                            
 *                          ↑↑↑↑↑↑↑↑      ↑↑↑                          ↑↑↑      ↑↑↑↑↑↑↑↑                         
 *                       ↑↑↑↑↑↑↑↑     ↑↑      ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑     ↑↑     ↑↑↑↑↑↑↑↑                      
 *                     ↑↑↑↑↑↑↑           ↑↑↑↑↑↑                      ↑↑↑↑↑↑           ↑↑↑↑↑↑↑                    
 *                   ↑↑↑↑↑↑           ↑↑↑                                  ↑↑↑           ↑↑↑↑↑↑                  
 *                 ↑↑↑↑↑↑          ↑↑                                          ↑↑          ↑↑↑↑↑↑                
 *               ↑↑↑↑↑↑                                                                      ↑↑↑↑↑↑              
 *             ↑↑↑↑↑    ↑↑                                                                ↑↑    ↑↑↑↑             
 *            ↑↑↑↑   ↑↑↑                                                                    ↑↑    ↑↑↑↑           
 *           ↑↑↑↑  ↑     ↑                                                                ↑↑    ↑↑ ↑↑↑↑          
 *          ↑↑↑  ↑    ↑↑                                                                    ↑↑    ↑  ↑↑↑         
 *        ↑↑↑↑  ↑    ↑↑                                                                      ↑↑     ↑ ↑↑↑        
 *        ↑↑↑ ↑    ↑↑↑                                                                        ↑↑↑    ↑ ↑↑↑       
 *       ↑↑↑ ↑    ↑↑                             ↑↑↑↑↑↑↑↑↑↑                                     ↑↑    ↑ ↑↑↑      
 *      ↑↑↑ ↑    ↑↑                            ↑↑↑↑       ↑↑↑↑↑↑↑↑↑                              ↑↑    ↑ ↑↑↑     
 *     ↑↑↑ ↑    ↑↑                       ↑↑↑↑↑↑↑    ↑↑↑↑         ↑↑↑↑↑                            ↑↑    ↑ ↑↑↑    
 *     ↑↑↑      ↑                    ↑↑↑↑                 ↑↑↑↑↑↑↑↑  ↑↑↑                            ↑↑    ↑ ↑↑    
 *    ↑↑↑      ↑                   ↑↑↑    ↑↑↑↑↑↑↑↑↑↑↑   ↑↑↑   ↑   ↑↑↑ ↑↑↑                           ↑      ↑↑↑   
 *    ↑↑↑     ↑↑                  ↑↑  ↑↑↑↑      ↑↑↑↑↑↑ ↑↑  ↑↑↑   ↑  ↑↑  ↑↑↑↑                         ↑      ↑↑   
 *   ↑↑↑      ↑                  ↑  ↑                ↑ ↑↑ ↑       ↑ ↑↑    ↑↑↑↑                       ↑↑     ↑↑↑  
 *   ↑↑      ↑                  ↑↑     ↑             ↑  ↑ ↑↑  ↑↑ ↑↑ ↑↑  ↑↑   ↑↑↑                      ↑      ↑↑  
 *  ↑↑↑                         ↑   ↑ ↑  ↑↑          ↑↑  ↑↑  ↑↑↑↑  ↑↑ ↑↑↑↑↑↑↑  ↑↑↑                    ↑      ↑↑↑ 
 *  ↑↑↑                         ↑   ↑  ↑  ↑↑↑↑         ↑↑       ↑↑↑  ↑↑    ↑↑↑  ↑↑↑                   ↑      ↑↑↑ 
 *  ↑↑                          ↑↑   ↑  ↑↑   ↑↑↑↑       ↑↑↑↑       ↑↑↑       ↑↑↑  ↑↑                  ↑       ↑↑ 
 *  ↑↑                           ↑↑  ↑↑   ↑↑↑   ↑↑↑↑↑       ↑↑↑↑↑↑↑           ↑↑↑  ↑↑                 ↑↑      ↑↑ 
 *  ↑↑                            ↑↑  ↑↑↑   ↑↑↑↑↑    ↑↑↑↑↑↑↑↑↑                 ↑↑   ↑↑                ↑↑      ↑↑ 
 *  ↑↑                             ↑↑   ↑↑      ↑↑↑↑↑                           ↑↑   ↑↑               ↑       ↑↑ 
 *  ↑↑                              ↑↑↑  ↑↑↑        ↑↑↑↑↑↑↑↑↑↑↑↑↑                ↑↑↑  ↑↑              ↑       ↑↑ 
 *  ↑↑                               ↑↑↑   ↑↑↑                                    ↑↑↑  ↑↑             ↑       ↑↑ 
 *  ↑↑↑                                ↑↑↑   ↑↑                                    ↑↑   ↑↑                   ↑↑↑ 
 *  ↑↑↑     ↑ ↑                          ↑↑↑  ↑↑↑                                   ↑↑   ↑↑                  ↑↑  
 *   ↑↑↑    ↑  ↑                           ↑↑↑  ↑↑↑                                  ↑↑   ↑↑                 ↑↑  
 *   ↑↑↑     ↑ ↑                            ↑↑↑↑  ↑↑↑                                 ↑↑   ↑↑               ↑↑↑  
 *    ↑↑↑    ↑↑ ↑                             ↑↑↑↑  ↑↑↑                                ↑↑↑  ↑↑             ↑↑↑↑  
 *     ↑↑↑    ↑ ↑                               ↑↑↑↑  ↑↑↑↑                              ↑↑↑  ↑↑      ↑     ↑↑    
 *     ↑↑↑↑    ↑ ↑                                ↑↑↑↑  ↑↑↑↑                              ↑↑  ↑↑↑   ↑     ↑↑↑    
 *      ↑↑↑↑      ↑                                 ↑↑↑↑   ↑↑↑                             ↑↑↑  ↑↑       ↑↑↑↑    
 *       ↑↑↑↑      ↑                                   ↑↑↑   ↑↑↑                            ↑↑↑  ↑↑      ↑↑↑     
 *       ↑↑↑        ↑                                    ↑↑↑↑  ↑↑↑                            ↑↑↑↑     ↑↑↑↑      
 *        ↑↑↑↑       ↑                                     ↑↑↑↑ ↑↑↑                            ↑↑     ↑↑↑↑↑      
 *        ↑↑↑↑↑       ↑↑                                     ↑↑↑  ↑↑                                 ↑↑↑↑        
 *           ↑↑↑        ↑↑                                     ↑↑  ↑↑                               ↑↑↑          
 *           ↑↑↑↑        ↑↑↑                                    ↑↑  ↑↑                             ↑↑↑↑          
 *            ↑↑↑↑↑        ↑↑↑                                   ↑  ↑↑                           ↑↑↑↑↑           
 *             ↑↑↑↑↑↑         ↑↑↑                                ↑   ↑             ↑↑  ↑       ↑↑↑↑↑↑            
 *               ↑↑↑↑↑↑          ↑↑↑                             ↑  ↑↑          ↑↑           ↑↑↑↑↑↑              
 *                 ↑↑↑↑↑              ↑↑↑                       ↑↑  ↑↑      ↑↑    ↑↑↑     ↑↑↑↑↑↑                 
 *                   ↑↑↑↑↑        ↑↑      ↑↑↑                   ↑↑  ↑  ↑↑↑     ↑↑↑      ↑↑↑↑↑↑                   
 *                     ↑↑↑↑↑↑↑        ↑↑        ↑↑↑↑↑          ↑↑  ↑↑      ↑↑↑↑      ↑↑↑↑↑↑↑                     
 *                       ↑↑↑↑↑↑↑↑         ↑↑↑                   ↑↑↑↑   ↑↑↑       ↑↑↑↑↑↑↑↑↑                       
 *                          ↑↑↑↑↑↑↑↑             ↑↑↑↑↑↑↑↑↑↑    ↑↑↑↑           ↑ ↑↑↑↑↑↑↑                          
 *                             ↑↑↑↑↑↑↑↑↑↑↑                              ↑ ↑↑↑↑↑↑↑↑↑↑                             
 *                                ↑↑↑↑↑↑↑↑↑↑↑↑↑↑   ↑↑↑↑↑↑      ↑↑   ↑↑↑↑↑↑↑↑↑↑↑↑↑                                
 *                                       ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑                                      
 *                                             ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑                                            
 *                                                                                                               
 */

/**
 * @title Lizcoin ERC20
 *
 * @notice The ERC-20 token Lizcoin is the governance token for the Gaming Sub-DAO of Lizard Labs.
 *      While the studio focuses on immersive, interconnected gaming experiences, the token is primarily used for
 *      yield farming and revenue distribution for active participants, protocol governance, and liquidity staking.
 *
 * @notice Token Summary:
 *      - Symbol: LIZ
 *      - Name: Lizcoin
 *      - Decimals: 18
 *      - Initial total supply: 9B (1B to be minted as staking rewards)
 *      - Final total supply: 10B (not enforced by the token contract)
 *      - Initial supply holder (initial holder) address: 0xC93c904fFE3d55E15483eF37e38ECAF8Fe003Ba7
 *      - Mintability: configurable (initially enabled, but possible to revoke forever)
 *      - Burnability: configurable (initially enabled, but possible to revoke forever)
 *      - DAO Support: supports voting delegation
 *
 * @notice Features Summary:
 *      - Supports atomic allowance modification, resolves well-known ERC20 issue with approve (arXiv:1907.00903)
 *      - Voting delegation and delegation on behalf via EIP-712 (like in Compound CMP token) - gives the token
 *        powerful governance capabilities by allowing holders to form voting groups by electing delegates
 *      - Unlimited approval feature (like in 0x ZRX token) - saves gas for transfers on behalf
 *        by eliminating the need to update “unlimited” allowance value
 *      - ERC-1363 Payable Token - ERC721-like callback execution mechanism for transfers,
 *        transfers on behalf and approvals; allows creation of smart contracts capable of executing callbacks
 *        in response to transfer or approval in a single transaction
 *      - EIP-2612: permit - 712-signed approvals - improves user experience by allowing to use a token
 *        without having an ETH to pay gas fees
 *      - EIP-3009: Transfer With Authorization - improves user experience by allowing to use a token
 *        without having an ETH to pay gas fees
 *
 * @dev Based on the https://github.com/lazy-sol/advanced-erc20 implementation
 *
 * @author Lizard Labs Core Contributors
 */
contract LizcoinERC20 is AdvancedERC20 {
	/**
	 * @dev Deploys the token smart contract,
	 *      sets token name, symbol, initial token supply
	 *
	 * @param _initialHolder initial holder of the token supply
	 */
	constructor(address _initialHolder) AdvancedERC20 (
		msg.sender, // _contractOwner smart contract owner (has minting/burning and all other permissions)
		"Lizcoin", // _name token name to set
		"LIZ", // _symbol token symbol to set
		_initialHolder, //  _initialHolder owner of the initial token supply
		// 9 bil + 15 mil + 16'358'635 + 147'227'717
		9_178_586_352 ether, // _initialSupply initial token supply (9.18 bil)
		0xFFFF // _initialFeatures RBAC features enabled initially
	) {}
}