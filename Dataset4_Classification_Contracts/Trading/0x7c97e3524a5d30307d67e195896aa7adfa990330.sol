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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
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
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.19;

import {
	Ownable
} from "@openzeppelin/contracts/access/Ownable.sol";
import {
	Address
} from "@openzeppelin/contracts/utils/Address.sol";

error RightNotSpecified();
error CallerHasNoAccess();
error ManagedRightNotSpecified();

/**
	@custom:benediction DEVS BENEDICAT ET PROTEGAT CONTRACTVS MEAM
	@title An advanced permission-management contract.
	@author Tim Clancy <@_Enoch>

	This contract allows for a contract owner to delegate specific rights to
	external addresses. Additionally, these rights can be gated behind certain
	sets of circumstances and granted expiration times. This is useful for some
	more finely-grained access control in contracts.

	The owner of this contract is always a fully-permissioned super-administrator.

	@custom:date August 23rd, 2021.
*/
abstract contract PermitControl is Ownable {
	using Address for address;

	/// A special reserved constant for representing no rights.
	bytes32 internal constant _ZERO_RIGHT = hex"00000000000000000000000000000000";

	/// A special constant specifying the unique, universal-rights circumstance.
	bytes32 internal constant _UNIVERSAL = hex"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";

	/**
		A special constant specifying the unique manager right. This right allows an
		address to freely-manipulate the `managedRight` mapping.
	*/
	bytes32 internal constant _MANAGER = hex"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";

	/**
		A mapping of per-address permissions to the circumstances, represented as
		an additional layer of generic bytes32 data, under which the addresses have
		various permits. A permit in this sense is represented by a per-circumstance
		mapping which couples some right, represented as a generic bytes32, to an
		expiration time wherein the right may no longer be exercised. An expiration
		time of 0 indicates that there is in fact no permit for the specified
		address to exercise the specified right under the specified circumstance.

		@dev Universal rights MUST be stored under the 0xFFFFFFFFFFFFFFFFFFFFFFFF...
		max-integer circumstance. Perpetual rights may be given an expiry time of
		max-integer.
	*/
	mapping ( address => mapping( bytes32 => mapping( bytes32 => uint256 ))) 
		internal _permissions;

	/**
		An additional mapping of managed rights to manager rights. This mapping
		represents the administrator relationship that various rights have with one
		another. An address with a manager right may freely set permits for that
		manager right's managed rights. Each right may be managed by only one other
		right.
	*/
	mapping ( bytes32 => bytes32 ) internal _managerRights;

	/**
		An event emitted when an address has a permit updated. This event captures,
		through its various parameter combinations, the cases of granting a permit,
		updating the expiration time of a permit, or revoking a permit.

		@param updater The address which has updated the permit.
		@param updatee The address whose permit was updated.
		@param circumstance The circumstance wherein the permit was updated.
		@param role The role which was updated.
		@param expirationTime The time when the permit expires.
	*/
	event PermitUpdated (
		address indexed updater,
		address indexed updatee,
		bytes32 circumstance,
		bytes32 indexed role,
		uint256 expirationTime
	);

	/**
		An event emitted when a management relationship in `managerRight` is
		updated. This event captures adding and revoking management permissions via
		observing the update history of the `managerRight` value.

		@param manager The address of the manager performing this update.
		@param managedRight The right which had its manager updated.
		@param managerRight The new manager right which was updated to.
	*/
	event ManagementUpdated (
		address indexed manager,
		bytes32 indexed managedRight,
		bytes32 indexed managerRight
	);

	/**
		A modifier which allows only the super-administrative owner or addresses
		with a specified valid right to perform a call.

		@param _circumstance The circumstance under which to check for the validity
			of the specified `right`.
		@param _right The right to validate for the calling address. It must be
			non-expired and exist within the specified `_circumstance`.
	*/
	modifier hasValidPermit (
		bytes32 _circumstance,
		bytes32 _right
	) {
		if (
			msg.sender != owner() &&
				!_hasRight(msg.sender, _circumstance, _right)
		) {
			revert CallerHasNoAccess();
		}
		_;
	}

	/**
		Determine whether or not an address has some rights under the given
		circumstance,

		@param _address The address to check for the specified `_right`.
		@param _circumstance The circumstance to check the specified `_right` for.
		@param _right The right to check for validity.

		@return true or false, whether user has rights and time is valid.
	*/
	function _hasRight (
		address _address,
		bytes32 _circumstance,
		bytes32 _right
	) internal view returns (bool) {
		return _permissions[_address][_circumstance][_right] > block.timestamp;
	}
	/**
		Set the `_managerRight` whose `UNIVERSAL` holders may freely manage the
		specified `_managedRight`.

		@param _managedRight The right which is to have its manager set to
			`_managerRight`.
		@param _managerRight The right whose `UNIVERSAL` holders may manage
			`_managedRight`.
	*/

	function setManagerRight (
		bytes32 _managedRight,
		bytes32 _managerRight
	) external virtual hasValidPermit(_UNIVERSAL, _MANAGER) {
		if (_managedRight == _ZERO_RIGHT) {
			revert ManagedRightNotSpecified();
		}
		_managerRights[_managedRight] = _managerRight;
		emit ManagementUpdated(msg.sender, _managedRight, _managerRight);
	}

	/**
		Set the permit to a specific address under some circumstances. A permit may
		only be set by the super-administrative contract owner or an address holding
		some delegated management permit.

		@param _address The address to assign the specified `_right` to.
		@param _circumstance The circumstance in which the `_right` is valid.
		@param _right The specific right to assign.
		@param _expirationTime The time when the `_right` expires for the provided
			`_circumstance`.
	*/
	function setPermit (
		address _address,
		bytes32 _circumstance,
		bytes32 _right,
		uint256 _expirationTime
	) public virtual hasValidPermit(_UNIVERSAL, _managerRights[_right]) {
		if(_right == _ZERO_RIGHT) {
			revert RightNotSpecified();
		}
		_permissions[_address][_circumstance][_right] = _expirationTime;
		emit PermitUpdated(
			msg.sender,
			_address,
			_circumstance,
			_right,
			_expirationTime
		);
	}

	/**
		Determine whether or not an address has some rights under the given
		circumstance, and if they do have the right, until when.

		@param _address The address to check for the specified `_right`.
		@param _circumstance The circumstance to check the specified `_right` for.
		@param _right The right to check for validity.

		@return The timestamp in seconds when the `_right` expires. If the timestamp
			is zero, we can assume that the user never had the right.
	*/
	function hasRightUntil (
		address _address,
		bytes32 _circumstance,
		bytes32 _right
	) public view returns (uint256) {
		return _permissions[_address][_circumstance][_right];
	}
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.19;

/// Thrown if non-authorized account tries to execute asset transfer.
error NonAuthorized(address);

/*
Enum of ItemTypes for the transfer.
	1. ERC721 - 0
	2. ERC1155 - 1
*/
enum ItemType {
	ERC721,
	ERC1155
}

/*
	Helper Struct for restricted ERC721 or ERC1155 token transfers.

	itemType - defines the type of the Item to transfer..
	collection - address of the collection, to which the item belongs to.
	from - address, from which item is being transferred.
	to - address where item is being transferred.
	id - it of the token.
	amount - amount of the token to transfer in case of ERC1155.
*/
struct Item {
	ItemType itemType;
	address collection;
	address from;
	address to;
	uint256 id;
	uint256 amount;
}

/*
	Helper struct for restricted ERC20 token transfers.

	token - address of the token, which is being transferred.
	from - address, from which token is being transferred.
	to - address where token is being transferred.
	amount - amount of ERC20 token to transfer.
*/
struct ERC20Payment {
	address token;
	address from;
	address to;
	uint256 amount;
}

/*
	Enum of Asset types for the transfer.
	1. ERC20 - 0
	2. ERC721 - 1
	3. ERC1155 - 2
*/
enum AssetType {
	ERC20,
	ERC721,
	ERC1155
}

/*
	Helper struct for public transfers.

	assetType - defines the type of the Asset to transfer.
	collection - address of the collection, to which the asset belongs to.
	to - address where item is being transferred.
	id - it of the token.
	amount - amount of ERC20 token to transfer.
*/
struct Transfer {
	AssetType assetType;
	address collection;
	address to;
	uint256 id;
	uint256 amount;
}

/**
	@custom:benediction DEVS BENEDICAT ET PROTEGAT CONTRACTVS MEAM
	@title Asset Handler component interface.
*/
interface IAssetHandler {

	/**
		Execute restricted ERC721 or ERC1155 transfer. Reverts if caller is
		not authorized to call this function.

		@param _item Item to transfer.
		
		@custom:throws NonAuthorized.
	*/
	function transferItem (Item calldata _item) external;


	/**
		Execute multiple transfers. 

		@param _transfers Items to transfer.
	*/
	function transferMultipleItems (
		Transfer[] calldata _transfers
	) external;

	/**
		Executes restricted ERC20 transfer. Reverts if caller is
		not authorized to call this function.

		@param _token Address of the token.
		@param _from Address, from which tokens are being transferred.
		@param _to Address, to which tokens are being transferrec.
		@param _amount Amount of tokens.

		@custom:throws NonAuthorized.
	*/
	function transferERC20 (
		address _token,
		address _from,
		address _to,
		uint256 _amount
	) external;

	/**
		Executes multiple restricted ERC20 transfers. Reverts if caller is
		not authorized to call this function.

		@param _payments Array of helper structs, which contains information
		about ERC20 token transfers.

		@custom:throws NonAuthorized.
	*/
	function transferPayments (
		ERC20Payment[] calldata _payments
	) external;

}

/// Thrown if an address authentifying is already an authorized caller.
error AlreadyAuthorized ();

/// Thrown if an address is already pending authentication.
error AlreadyPendingAuthentication ();

/// Thrown if an address ending authentication has not yet started it.
error AddressHasntStartedAuth ();

/// Thrown if an address ending authentication has not delayed long enough.
error AddressHasntClearedTimelock ();


/**
	@custom:benediction DEVS BENEDICAT ET PROTEGAT CONTRACTVS MEAM
	@title Registry component interface.
*/
interface IRegistry {

	/**
		Allow the `ProxyRegistry` owner to begin the process of enabling access to
		the registry for the unauthenticated address `_unauthenticated`. Once the
		grant authentication process has begun, it is subject to the `DELAY_PERIOD`
		before the authentication process may conclude. Once concluded, the new
		address `_unauthenticated` will have access to the registry.

		@param _unauthenticated The new address to grant access to the registry.

		@custom:throws AlreadyAuthorized if the address beginning authentication is 
			already an authorized caller.
		@custom:throws AlreadyPendingAuthentication if the address beginning 
			authentication is already pending.
	*/
	function startGrantAuthentication (
		address _unauthenticated
	) external;

	/**
		Allow the `ProxyRegistry` owner to end the process of enabling access to the
		registry for the unauthenticated address `_unauthenticated`. If the required
		`DELAY_PERIOD` has passed, then the new address `_unauthenticated` will have
		access to the registry.

		@param _unauthenticated The new address to grant access to the registry.

		@custom:throws AlreadyAuthorized if the address beginning authentication is
			already an authorized caller.
		@custom:throws AddressHasntStartedAuth if the address attempting to end 
			authentication has not yet started it.
		@custom:throws AddressHasntClearedTimelock if the address attempting to end 
			authentication has not yet incurred a sufficient delay.
	*/
	function endGrantAuthentication(
		address _unauthenticated
	) external;

	/**
		Allow the owner of the `ProxyRegistry` to immediately revoke authorization
		to call proxies from the specified address.

		@param _caller The address to revoke authentication from.
	*/
	function revokeAuthentication (
		address _caller
	) external;
}

/// Thrown if any initial caller of this proxy registry is already set.
error InitialCallerIsAlreadySet ();

/**
	@custom:benediction DEVS BENEDICAT ET PROTEGAT CONTRACTVS MEAM
	@title GigaMart Manager contract interface.
*/
interface IGigaMartManager is IRegistry, IAssetHandler{
	/**
		Allow the owner of this registry to grant immediate authorization to a
		set of addresses for calling proxies in this registry. This is to avoid
		waiting for the `DELAY_PERIOD` otherwise specified for further caller
		additions.

		@param _initials The array of initial callers authorized to operate in this 
			registry.

		@custom:throws InitialCallerIsAlreadySet if an intial caller is already set 
			for this proxy registry.
	*/
	function grantInitialAuthentication (
		address[] calldata _initials
	) external;
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.19;

import {
	ReentrancyGuard
} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import {
	IAssetHandler,
	NativeTransfer,
	Marketplace
} from "./lib/Marketplace.sol";

import {
	Order,
	Execution,
	Fulfillment
} from "./lib/Order.sol";

/// Thrown if recipient address is not specified.
error InvalidRecipient ();

/**
	@custom:benediction DEVS BENEDICAT ET PROTEGAT CONTRACTVS MEAM
	@title GigaMart Exchange
	@author Rostislav Khlebnikov <@catpic5buck>
	@custom:contributor Tim Clancy <@_Enoch>
	@custom:contributor throw; <@0xthrpw>
	
	GigaMart is a new NFT platform built for the world by the SuperVerse DAO. 
	@custom:date March 17th, 2023.
*/
contract GigaMart is ReentrancyGuard, Marketplace {
	using NativeTransfer for address;

	/**
		Construct a new instance of the GigaMart exchange.

		@param _assetHandler The address of the existing manager contract.
		@param _validator The address of a privileged validator for permitting 
			collection administrators to control their royalty fees.
		@param _protocolFeeRecipient The address which receives fees from the 
			exchange.
		@param _protocolFeePercent The percent of fees taken by 
			`_protocolFeeRecipient` in basis points (1/100th %; i.e. 200 = 2%).
	*/
	constructor (
		IAssetHandler _assetHandler,
		address _validator,
		address _protocolFeeRecipient,
		uint96 _protocolFeePercent
	) Marketplace (
		_assetHandler,
		_validator,
		_protocolFeeRecipient,
		_protocolFeePercent
	) {}

	/**
		Allow the caller to cancel an order so long as they are the maker of the 
		order.

		@param _order The `Order` data to cancel.
	*/
	function cancelOrder (
		Order calldata _order
	) external {
		_cancelOrder(_order); 
	}

	/**
		Allow the caller to cancel a set of particular orders so long as they are 
		the maker of each order.

		@param _orders An array of `Order` data to cancel.
	*/
	function cancelOrders (
		Order[] calldata _orders
	) external {
		for (uint256 i; i < _orders.length; ) {
			_cancelOrder(_orders[i]);
			unchecked {
				++i;
			}
		}
	}

	/**
		Allow the caller to cancel all of their orders created with a nonce lower 
		than the new `_minNonce`.

		@param _minNonce The new nonce to use in mass-cancelation.

		@custom:throws NonceLowerThanCurrent if the provided nonce is not less than 
			the current nonce.
	*/
	function cancelAllOrders (
		uint256 _minNonce
	) external {
		_setNonce(_minNonce);
	}

	/**
		Strictly executes single orde. Reverts if the `_order` didn't pass validation 
		or item transfer failed. Also reverts on payment failure.
		
		@param _order Order struct..
		@param _signature signature for the `_order`.
		@param _recipient address of the account, which receives items or payments.
		@param _fulfillment fulfiller struct, containing information on how to fulfill
			the `_order`.

		@custom:throws InvalidRecipient if `_recipient` was not specified.
	*/
	function exchangeSingleItem (
		Order calldata _order,
		bytes calldata _signature,
		address _recipient,
		Fulfillment calldata _fulfillment
	) external payable nonReentrant {

		// Prevent the item from being sent to the zero address.
		if (_recipient == address(0)) {
			revert InvalidRecipient();
		}

		// Strictly execute the order and return eth dust.
		_executeSingle(
			_order,
			_signature,
			_recipient,
			_fulfillment
		);
	}

	/**
		Atomically executes multiple orders, emits OrderResult with error code,
		if the order didn't pass validation or item transfer failed. Reverts
		on payment failure.

		@param _executions Wrapper structs, containing orders and fulfillment indices.
		@param _signatures signatures for the orders.
		@param _recipient address of the account, which receives items or payments.
		@param _fulfillments fulfiller structs, containing information on how to 
			fulfill the orders.

		@custom:throws InvalidRecipient if `_recipient` was not specified.
	*/
	function exchangeMultipleItems (
		Execution[] calldata _executions,
		bytes[] calldata _signatures,
		address _recipient,
		Fulfillment[] calldata _fulfillments
	) external payable nonReentrant {
		
		// Prevent the item from being sent to the zero address.
		if (_recipient == address(0)) {
			revert InvalidRecipient();
		}

		// Track spent eth.
		uint256 ethSpent;

		for (uint256 i; i < _executions.length;) {
			
			/*
				Atomically execute orders, using
				fulfillments specified in Execution.fillerIndex.
			*/
			ethSpent += _executeMultiple(
				_executions[i].toOrder(),
				_signatures[i],
				_recipient,
				_fulfillments[_executions[i].fillerIndex]
			);

			unchecked {
				++i;
			}
		}

		// Return leftovers.
		if (msg.value > ethSpent) {
			msg.sender.transferEth(msg.value - ethSpent);
		}
	}

	/**
		Reads order status and fill amount.

		@param _order Order calldata pointer.

		@return _ Order status.
		@return _ Order fill amount.
	*/
	function readOrderStatus(
		Order calldata _order
	) external view returns (uint256, uint256) {
		return _readOrderStatus(_order);
	}
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.19;

import {
	ONE_WORD,
	TWO_WORDS,
	ONE_WORD_SHIFT,
	PROOF_KEY,
	PROOF_KEY_SHIFT,
	ECDSA_MAX_LENGTH
} from "./Helpers.sol";

import {
	MAX_BULK_ORDER_HEIGHT,
	ORDER_TYPEHASH,
	BULK_ORDER_HEIGHT_ONE_TYPEHASH,
	BULK_ORDER_HEIGHT_TWO_TYPEHASH,
	BULK_ORDER_HEIGHT_THREE_TYPEHASH,
	BULK_ORDER_HEIGHT_FOUR_TYPEHASH,
	BULK_ORDER_HEIGHT_FIVE_TYPEHASH,
	BULK_ORDER_HEIGHT_SIX_TYPEHASH,
	BULK_ORDER_HEIGHT_SEVEN_TYPEHASH,
	BULK_ORDER_HEIGHT_EIGHT_TYPEHASH,
	BULK_ORDER_HEIGHT_NINE_TYPEHASH,
	BULK_ORDER_HEIGHT_TEN_TYPEHASH
} from "./OrderConstants.sol";

/**
	@custom:benediction DEVS BENEDICAT ET PROTEGAT CONTRACTVS MEAM
	@title EIP-712 Domain Manager
	@author Rostislav Khlebnikov <@catpic5buck>
	@custom:contributor Tim Clancy <@_Enoch>

	A contract for providing EIP-712 signature-services.
*/
contract DomainAndTypehashes {

	/**
		The typehash of the EIP-712 domain, used in dynamically deriving a domain 
		separator.
	*/
	/**
		The typehash of the EIP-712 domain, used in dynamically deriving a domain 
		separator.

		keccak256(
			"EIP712Domain(
				string name,
				string version,
				uint256 chainId
				,address verifyingContract
			)"
		)
	*/
	bytes32 private constant _EIP712_DOMAIN_TYPEHASH = 
		0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f;

	/// A name used in the domain separator.
	string public constant name = "GigaMart";

	/// The immutable chain ID detected during construction.
	uint256 internal immutable _CHAIN_ID;

	/// The immutable chain ID created during construction.
	bytes32 private immutable _DOMAIN_SEPARATOR;

	/**
		Construct a new EIP-712 domain instance.
	*/
	constructor () {

		uint chainId;
		assembly {
			chainId := chainid()
		}
		_CHAIN_ID = chainId;
		_DOMAIN_SEPARATOR = keccak256(
			abi.encode(
				_EIP712_DOMAIN_TYPEHASH,
				keccak256(bytes(name)),
				keccak256(bytes(version())),
				chainId,
				address(this)
			)
		);
	}

	/**
		Return the version of this EIP-712 domain.

		@return _ The version of this EIP-712 domain.
	*/
	function version () public pure returns (string memory) {
		return "1";
	}

	/**
		Dynamically derive an EIP-712 domain separator.

		@return _ A constructed domain separator.
	*/
	function _deriveDomainSeparator () internal view returns (bytes32) {
		uint chainId;
		assembly {
			chainId := chainid()
		}
		return chainId == _CHAIN_ID
			? _DOMAIN_SEPARATOR
			: keccak256(
				abi.encode(
					_EIP712_DOMAIN_TYPEHASH,
					keccak256(bytes(name)),
					keccak256(bytes(version())),
					chainId,
					address(this)
				)
			);
	}

	/**
		Computes hash from previously calculated order hash
			and merkle tree proofs,

		@param _proofAndSignature signature concatenated with
			proofs for the order.
		@param _leaf hash of the order.

		@return bulkOrderHash hash of the merkle tree.
	 */
	function _computeBulkOrderHash (
        bytes calldata _proofAndSignature,
        bytes32 _leaf
    ) internal pure returns (bytes32 bulkOrderHash) {
        // Declare arguments for the root hash and the height of the proof.
        bytes32 root;
        uint256 height;
		
        // Utilize assembly to efficiently derive the root hash using the proof.
        assembly {
            // Retrieve the length of the proof, key, and signature combined.
            let fullLength := _proofAndSignature.length

            // If proofAndSignature has odd length, it is a compact signature
            // with 64 bytes.
            let signatureLength := sub(ECDSA_MAX_LENGTH, and(fullLength, 1))

            // Derive height (or depth of tree) with signature and proof length.
            height := shr(ONE_WORD_SHIFT, sub(fullLength, signatureLength))

            // Derive the pointer for the key using the signature length.
            let keyPtr := add(_proofAndSignature.offset, signatureLength)
		
            // Retrieve the three-byte key using the derived pointer.
            let key := shr(PROOF_KEY_SHIFT, calldataload(keyPtr))
	
            /// Retrieve pointer to first proof element by applying a constant
            // for the key size to the derived key pointer.
            let proof := add(keyPtr, PROOF_KEY)
			
           // Compute level 1.
            let scratchPtr1 := shl(ONE_WORD_SHIFT, and(key, 1))
            mstore(scratchPtr1, _leaf)
            mstore(xor(scratchPtr1, ONE_WORD), calldataload(proof))

            // Compute remaining proofs.
            for {
                let i := 1
            } lt(i, height) {
                i := add(i, 1)
            } {
                proof := add(proof, ONE_WORD)
                let scratchPtr := shl(ONE_WORD_SHIFT, and(shr(i, key), 1))
                mstore(scratchPtr, keccak256(0, TWO_WORDS))
                mstore(xor(scratchPtr, ONE_WORD), calldataload(proof))
            }

            // Compute root hash.
            root := keccak256(0, TWO_WORDS)

			let typeHash

			switch height
				case 1 {
					typeHash := BULK_ORDER_HEIGHT_ONE_TYPEHASH
				}
				case 2 {
					typeHash := BULK_ORDER_HEIGHT_TWO_TYPEHASH
				}
				case 3 {
					typeHash := BULK_ORDER_HEIGHT_THREE_TYPEHASH
				}
				case 4 {
					typeHash := BULK_ORDER_HEIGHT_FOUR_TYPEHASH
				}
				case 5 {
					typeHash := BULK_ORDER_HEIGHT_FIVE_TYPEHASH
				}
				case 6 {
					typeHash := BULK_ORDER_HEIGHT_SIX_TYPEHASH
				}
				case 7 {
					typeHash := BULK_ORDER_HEIGHT_SEVEN_TYPEHASH
				}
				case 8 {
					typeHash := BULK_ORDER_HEIGHT_EIGHT_TYPEHASH
				}
				case 9 {
					typeHash := BULK_ORDER_HEIGHT_NINE_TYPEHASH
				}
				case 10 {
					typeHash := BULK_ORDER_HEIGHT_TEN_TYPEHASH
				}
				default {
					typeHash := ORDER_TYPEHASH
				}
      
        	// Use the typehash and the root hash to derive final bulk order hash.
            mstore(0, typeHash)
            mstore(ONE_WORD, root)
            bulkOrderHash := keccak256(0, TWO_WORDS)
        }
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.19;

/*
	This file contains constants and low-level functions
	for processing signatures.
*/

type MemoryPointer is uint256;

// Default free memory pointer value.
MemoryPointer constant FREE_MEMORY_POINTER = MemoryPointer.wrap(0x80);
uint256 constant ZERO_MEMORY_SLOT = 0x0;
// One 32 bytes word.
uint256 constant ONE_WORD = 0x20;
// Two 32 bytes words.
uint256 constant TWO_WORDS = 0x40; 
// Three 32 bytes words.
uint256 constant THREE_WORDS = 0x60; 
// Amount of bits to increase a pointer on one word.
uint256 constant ONE_WORD_SHIFT = 0x5;
// Length of the proof key.
uint256 constant PROOF_KEY = 0x3;
// Bits to shift to the next key.
uint256 constant PROOF_KEY_SHIFT = 0xe8;
// Max signature length in bytes.
uint256 constant ECDSA_MAX_LENGTH = 65;
// Ethereum message prefix.
bytes2 constant PREFIX = 0x1901;
 // IAssetHandler.transferItem function selector.
bytes4 constant TRANSFER_ITEM_SELECTOR = 0xfb6659f9;
uint256 constant TRANSFER_ITEM_DATA_LENGTH = 0xe4;
uint256 constant ERC721_ITEM_TYPE = 0;
uint256 constant ERC1155_ITEM_TYPE = 1;
// Divisor for percent math.
uint256 constant PRECISION = 10_000; 

/*
	Sets free memory pointer back to defaul value;
*/
function _resetMemoryPointer () pure {
	assembly {
		mstore(0x40, 0x80)
	}
}

/*
	Reads current free memory pointer.
*/
function _freeMemoryPointer () pure returns(MemoryPointer memPtr) {
	assembly{
		memPtr := mload(0x40)
	}
}

// keccak256(abi.encode(bytes(0)))
bytes32 constant HASH_OF_ZERO_BYTES=
    0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;

// 1 block reorg gap
uint256 constant LUCKY_NUMBER = 13;

/**
	Recover the address which signed `_hash` with signature `_signature`.

	@param _digest A hash signed by an address.
	@param _signature The signature of the hash.

	@return _ The address which signed `_hash` with signature `_signature.

	@custom:throws InvalidSignatureLength if the signature length is not valid.
*/
function _recover (
	bytes32 _digest,
	bytes calldata _signature
) pure returns (address) {

	// Divide the signature into r, s and v variables.
	bytes32 r;
	bytes32 s;
	uint8 v;
	assembly {
		r := calldataload(_signature.offset)
		s := calldataload(add(_signature.offset, 0x20))
		v := byte(0, calldataload(add(_signature.offset, 0x40)))
	}
	// Return the recovered address.
	return ecrecover(_digest, v, r, s);
}

// The selector for EIP-1271 contract-based signatures.
bytes4 constant EIP_1271_SELECTOR = bytes4(
	keccak256("isValidSignature(bytes32,bytes)")
);

/**
	A helper function to validate an EIP-1271 contract signature.

	@param _orderMaker The smart contract maker of the order.
	@param _hash The hash of the order.
	@param _signature The signature of the order to validate.

	@return _ Whether or not `_signature` is a valid signature of `_hash` by the 
		`_orderMaker` smart contract.
*/
function _recoverContractSignature (
	address _orderMaker,
	bytes32 _hash,
	bytes calldata _signature
) view returns (bool) {
	bytes32 r;
	bytes32 s;
	uint8 v;
	assembly {
		r := calldataload(_signature.offset)
		s := calldataload(add(_signature.offset, 0x20))
		v := byte(0, calldataload(add(_signature.offset, 0x40)))
	}
	bytes memory isValidSignatureData = abi.encodeWithSelector(
		EIP_1271_SELECTOR,
		_hash,
		abi.encodePacked(r, s, v)
	);

	/*
		Call the `_orderMaker` smart contract and check for the specific magic 
		EIP-1271 result.
	*/
	bytes4 result;
	assembly {
		let success := staticcall(
			
			// Forward all available gas.
			gas(),
			_orderMaker,
	
			// The calldata offset comes after length.
			add(isValidSignatureData, 0x20),

			// Load calldata length.
			mload(isValidSignatureData), // load calldata length

			// Do not use memory for return data.
			0,
			0
		)

		/*
			If the call failed, copy return data to memory and pass through revert 
			data.
		*/
		if iszero(success) {
			returndatacopy(0, 0, returndatasize())
			revert(0, returndatasize())
		}

		/*
			If the return data is the expected size, copy it to memory and load it 
			to our `result` on the stack.
		*/
		if eq(returndatasize(), 0x20) {
			returndatacopy(0, 0, 0x20)
			result := mload(0)
		}
	}

	// If the collected result is the expected selector, the signature is valid.
	return result == EIP_1271_SELECTOR;
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.19;

import {
	Order,
	Fulfillment,
	deriveOrder
} from "./Order.sol";

import {
	ORDER_IS_PARTIALLY_FILLED,
	ORDER_IS_FULFILLED,
	ORDER_IS_CANCELLED
} from "./OrderConstants.sol";

import {
	IAssetHandler,
	NativeTransfer,
	OrderFulfiller
} from "./OrderFulfiller.sol";

import {
	RoyaltyManager
} from "./RoyaltyManager.sol";

import {
	_getUserNonce,
	_setUserNonce,
	_getOrderStatus,
	_setOrderStatus,
	_getOrderFillAmount
} from "./Storage.sol";

import {
	MemoryPointer,
	FREE_MEMORY_POINTER,
	ECDSA_MAX_LENGTH,
	PREFIX,
	_freeMemoryPointer,
	_resetMemoryPointer,
	_recover,
	_recoverContractSignature
} from "./Helpers.sol";

/// Thrown if order.maker tries to fulfill own order.
error InvalidMaker ();

///	Thrown if order was signed with nonce, lowet than current.
error InvalidNonce ();

/**
	Thrown if order.amount is 0 for ERC1155 AssetType,
	and if order.amount is not 0 for ERC721 AssetType. 
*/
error InvalidAmount ();

/// Thrown if order parameters do not satisfy order.saleKind.
error InvalidSaleKind ();

/// Thrown if item transfer was unsuccsessfull.
error ItemTransferFailed ();

/// Thrown if order period is passed or not yet started.
error InvalidOrderPeriod ();

/**
	Thrown if order.paymentToken is zero address for ERC20
	paymentType, and if order.payment token is not zero for
	ETH paymentType.
*/
error InvalidPaymentToken ();

/** 
	Thrown if order.taker is not address zero, and neither the 
	msg.sender nor the recipient are the order.taker.
*/ 

error OrderTakerNotMatched ();

/**
	Thrown if order was already fulfilled or cancelled, or
	signature check failed.
*/
error OrderValidationFailed ();

/// Thrown if order was already fulfilled.
error OrderAlreadyFulfilled ();

/// Thrown if order was already cancelled.
error OrderAlreadyCancelled ();

/**
	@title GigaMart Executor
	@author Rostislav Khlebnikov <@catpic5buck>
	@custom:contributor Tim Clancy <@_Enoch>
	@custom:contributor throw; <@0xthrpw>
	
	This second iteration of the exchange executor is inspired by the old Wyvern 
	architecture `ExchangeCore`.
*/
contract Marketplace is OrderFulfiller, RoyaltyManager {
	using NativeTransfer for address;

	/**
		Emitted when an order is canceled.

		@param maker The order maker's address.
		@param hash The hash of the order.
		@param data function call.
	*/
	event OrderCancelled (
		address indexed maker,
		bytes32 hash, 
		bytes data
	);

	/**
		Emitted when a user cancels all of their orders. All orders with a nonce 
		less than `minNonce` will be canceled.

		@param sender The caller who is canceling their orders.
		@param minNonce The new nonce to use in mass-cancelation.
	*/
	event AllOrdersCancelled (
		address indexed sender,
		uint256 minNonce
	);

	/**
		Construct a new instance of the GigaMart marketplace.

		@param _assetHandler The address of the existing manager.
		@param _validator The address of a privileged validator for permitting 
			collection administrators to control their royalty fees.
		@param _protocolFeeRecipient The address which receives fees from the 
			exchange.
		@param _protocolFeePercent The percent of fees taken by 
			`_protocolFeeRecipient` in basis points (1/100th %; i.e. 200 = 2%).
	*/
	constructor(
		IAssetHandler _assetHandler,
		address _validator,
		address _protocolFeeRecipient,
		uint96 _protocolFeePercent
	) OrderFulfiller (
		_assetHandler
	) RoyaltyManager (
		_validator,
		_protocolFeeRecipient,
		_protocolFeePercent
	){}

	/**
		Reads order status and fill amount.

		@param _order Order calldata pointer.

		@return status Order status.
		@return fillAmount Order fill amount.
	*/
	function _readOrderStatus(
		Order calldata _order
	) internal view returns (uint256 status, uint256 fillAmount) {

		// Derive order hash.
		bytes32 hash = _order.hash();

		// Read status.
		status = _getOrderStatus(hash);

		// Read fill amount.
		fillAmount = _getOrderFillAmount(hash);
	}

	/**
		Validate that a provided order `_hash` does not correspond to a finalized or
		cancelled order, and was actually signed by its maker `_maker`
		with signature `_signature`.

		@param _hash A hash of an `Order` to validate.
		@param _maker The address of the maker who signed the order `_hash`.
		@param _signature The ECDSA signature of the order `_hash`, which must
			have been signed by the order `_maker`.

		@return _ Whether or not the specified order `_hash` is authenticated as 
			valid to continue fulfilling.
	*/
	function _validateOrder (
		bytes32 _hash,
		address _maker,
		bytes calldata _signature
	) internal view returns (bool) {

		// Verify order is still live.
		uint256 status = _getOrderStatus(_hash);

		// If order is partially filled, it is considered authenticated.
		if (status == ORDER_IS_PARTIALLY_FILLED) {
			return true;
		}
		
		// Order must not be cancelled.
		if (status == ORDER_IS_CANCELLED) {
			return false;
		}
		// Order must not be fulfilled.
		if (status == ORDER_IS_FULFILLED) {
			return false;
		}

		// Calculate digest before recovering signer's address.
		bytes32 digest = keccak256(
			abi.encodePacked(
				PREFIX,
				_deriveDomainSeparator(),
				_signature.length > ECDSA_MAX_LENGTH ?
					_computeBulkOrderHash(_signature, _hash) :
					_hash
			)
		);

		// Try recover maker address.
		if (_maker == _recover(digest, _signature)) {
			return true;
		}

		// If maker account is a contract, call it to validate signature.
		if (_maker.code.length > 0) {
			return _recoverContractSignature(
				_maker,
				_hash,
				_signature
			);
		} 

		// Return default.
		return false;
	}

	/**
		Strictly executes the `_order`. 

		1. Allocates each order field.
		2. Validates order parameters.
		3. Checks if order is still active and signature
			is valid.
		4. Distinguishes type of the trade.
		5. Transfers item and payments.
		6. Emits OrderResult
		7. Returns eth leftovers to msg.sender.

		@param _order The order to execute..
		@param _signature The signature provided for fulfilling the order, signed 
			by the order maker.
		@param _recipient The address of the caller who receives item or payment. E.g.
			1. msg.sender pays for the listing, item in question is transferred
				to `_recipient`.
			2. msg.sender fulfills the offer, payment is transferred to `_recipient`.
		@param _fulfillment fulfiller struct, containing information on how to fulfill
			the `_order`.

		@custom:throws InvalidMaker if maker is address(0) or equals to 
			recipient address.
		@custom:throws InvalidNonce if `_order` nonce is lower than current.
		@custom:throws InvalidOrderPeriod if block.timestamp is not in range 
			of `_order`.listingTime and `_order`.expirationTime.
		@custom:throws InvalidPaymentToken If address of paymentToken isn't 
			matched with order.paymentType.
		@custom:throws InvalidAmount if `_order`.amount isn't matched with
			order.assetType.
		@custom:throws InvalidSaleKind if `_order`.resolve data isn't matched
			with order.saleKind.
		@custom:throws OrderTakerNotMatched if order taker is specified and
			not equal to `_recipient`.
		@custom:throws OrderValidationFailed if order previously had been
			fulfilled or cancelled or `_signature` check failed/
		@custom:throws ItemTransferFailed if item transfer failed.
		@custom:throws TransferFailed if ETH transfer failed.
	*/
	function _executeSingle (
		Order calldata _order,
		bytes calldata _signature,
		address _recipient,
		Fulfillment calldata _fulfillment
	) internal {

		// Create a memory pointer to the order.
		Order memory order = deriveOrder(FREE_MEMORY_POINTER);
		// Allocate order type and load order typehash at the pointer slot.
		order.allocateOrderType(_order);
		// Allocate order parameters, which do not require validation.
		order.allocateTradeParameters(_order);

		// Validate and allocate order.maker.
		if (!order.validateMaker(_order, _recipient)) {
			revert InvalidMaker();
		}

		// Validate and allocate order.nonce.
		if (!order.validateNonce(_order, order.maker)) {
			revert InvalidNonce();
		}

		// Validate and allocate order.listingTime and order.expirationTime.
		if (!order.validateOrderPeriod(_order)) {
			revert InvalidOrderPeriod();
		}

		// Put saleKind on the stack.
		uint64 saleKind = order.saleKind();
		// Validate and allocate payment token.
		if (!order.validatePaymentType(_order, saleKind, order.paymentType())) {
			revert InvalidPaymentToken();
		}

		// Validate and allocate order item amount.
		if (!order.validateAssetType(_order, order.assetType())) {
			revert InvalidAmount();
		}

		// Validate resolveData parameters and derive the has of the order.
		(bytes32 hash, bool valid) = order.validateSaleKind(
			FREE_MEMORY_POINTER,
			_order,
			saleKind
		);

		if (!valid) {
			revert InvalidSaleKind();
		}

		// Order.taker must be recipient, if specified.
		if (order.taker != address(0) && order.taker != _recipient) {
			revert OrderTakerNotMatched();
		}

		// Check if order is still open and check the signature.
		if (!_validateOrder(hash, order.maker, _signature)) {
			revert OrderValidationFailed();
		}

		
		/// Transfer the item and payments. Put amount of spent eth on the stack. 
		(uint256 ethSpent, bool itemTransferred) = 
			_fulfill(saleKind, hash, order, _recipient, _fulfillment);

		// Revert if item transfer failed.
		if (!itemTransferred) {
			revert ItemTransferFailed();
		}

		// Return eth leftovers.
		if (msg.value > ethSpent){
			msg.sender.transferEth(msg.value - ethSpent);
		}
	}

	/**
		Executes order in a lenient way - emits OrderResult with error code,
		if the order didn't pass validation or item transfer failed. Reverts only
		on payment failure.

		1. Allocates each order field.
		2. Validates order parameters.
		3. Checks if order is still active and signature
			is valid.
		4. Distinguishes type of the trade.
		5. Transfers item and payments.
		6. Emits OrderResult
		7. Returns eth leftovers amount up the callstack.

		@param _order The order to execute..
		@param _signature The signature provided for fulfilling the order, signed 
			by the order maker.
		@param _recipient The address of the caller who receives item or payment. E.g.
			1. msg.sender pays for the listing, item in question is transferred
				to `_recipient`.
			2. msg.sender fulfills the offer, payment is transferred to `_recipient`.
		@param _fulfillment fulfiller struct, containing information on how to fulfill
			the `_order`.
	*/
	function _executeMultiple (
		Order calldata _order,
		bytes calldata _signature,
		address _recipient,
		Fulfillment calldata _fulfillment
	) internal returns (uint256) {
		
		// Create a memory pointer to the order.
		Order memory order = deriveOrder(_freeMemoryPointer());

		// Allocate order type and load order typehash at the pointer slot.
		order.allocateOrderType(_order);
		// Allocate order parameters, which do not require validation.
		order.allocateTradeParameters(_order);

		// Validate and allocate order.maker.
		if (!order.validateMaker(_order, _recipient)) {
			_emitOrderFailed(
				bytes1(0x01),
				_order.hash(),
				order.toTrade(),
				_recipient
			);
			/// Reset memory pointer for the next order.
			_resetMemoryPointer();
			return 0;
		}

		// Validate and allocate order.nonce.
		if (!order.validateNonce(_order, order.maker)) {
			_emitOrderFailed(
				(0x02),
				_order.hash(),
				order.toTrade(),
				_recipient
			);
			/// Reset memory pointer for the next order.
			_resetMemoryPointer();
			return 0;
		}

		// Validate and allocate order.listingTime and order.expirationTime.
		if (!order.validateOrderPeriod(_order)) {
			_emitOrderFailed(
				bytes1(0x03),
				_order.hash(),
				order.toTrade(),
				_recipient
			);
			/// Reset memory pointer for the next order.
			_resetMemoryPointer();
			return 0;
		}

		// Put saleKind on the stack.
		uint64 saleKind = order.saleKind();
		// Validate and allocate payment token.
		if (!order.validatePaymentType(_order, saleKind, order.paymentType())) {
			_emitOrderFailed(
				bytes1(0x04),
				_order.hash(),
				order.toTrade(),
				_recipient
			);
			/// Reset memory pointer for the next order.
			_resetMemoryPointer();
			return 0;
		}

		// Validate and allocate order item amount.
		if (!order.validateAssetType(_order, order.assetType())) {
			_emitOrderFailed(
				bytes1(0x05),
				_order.hash(),
				order.toTrade(),
				_recipient
			);
			/// Reset memory pointer for the next order.
			_resetMemoryPointer();
			return 0;
		}

		// Validate resolveData parameters and derive the has of the order.
		(bytes32 hash, bool valid) = order.validateSaleKind(
			FREE_MEMORY_POINTER,
			_order,
			saleKind
		);

		if (!valid) {
			_emitOrderFailed(
				bytes1(0x06),
				hash,
				order.toTrade(),
				_recipient
			);
			/// Reset memory pointer for the next order.
			_resetMemoryPointer();
			return 0;
		}

		// Order.taker must be recipient, if specified.
		if (order.taker != address(0) && order.taker != _recipient) {
			_emitOrderFailed(
				bytes1(0x08),
				hash,
				order.toTrade(),
				_recipient
			);
			/// Reset memory pointer for the next order.
			_resetMemoryPointer();
			return 0;
		}

		// Check if order is still open and check the signature.
		if (!_validateOrder(hash, order.maker, _signature)) {
			_emitOrderFailed(
				bytes1(0x07),
				hash,
				order.toTrade(),
				_recipient
			);
			/// Reset memory pointer for the next order.
			_resetMemoryPointer();
			return 0;
		}

		/// Transfer the item and payments. Put amount of spent eth on the stack. 
		(uint256 ethSpent, bool itemTransferred) = 
			_fulfill(saleKind, hash, order, _recipient, _fulfillment);

		/// If item transfer fails, skip payment and emit OrderResult with error code.
		if (!itemTransferred) {
			_emitOrderFailed(
				bytes1(0x09),
				hash,
				order.toTrade(),
				_recipient
			);
			/// Reset memory pointer for the next order.
			_resetMemoryPointer();
			return 0;
		}

		/// Reset memory pointer for the next order.
		_resetMemoryPointer();

		/// Return amount of spent eth up the callstack.
		return ethSpent;
	}


	/**
		Cancel an order, preventing it from being matched. An order must be 
		canceled by its maker.
		
		@param _order The `Order` to cancel.

		@custom:throws OrderAlreadyCancelled if the order has already been 
			individually canceled, or mass-canceled.
		@custom:throws OrderAlreadyFulfilled if the order has already been 
			fulfilled.
		@custom:throws OrderValidationFailed if the caller is not the maker of 
			the order.
	*/
	function _cancelOrder (Order calldata _order) internal {

		// Calculate the order hash.
		bytes32 hash = _order.hash();

		// Verify order is still live.
		uint256 status = _getOrderStatus(hash);
		if (
			status == ORDER_IS_CANCELLED || 
			_order.nonce < _getUserNonce(msg.sender)
		) {
			revert OrderAlreadyCancelled();
		}
		if (status == ORDER_IS_FULFILLED) {
			revert OrderAlreadyFulfilled();
		}

		// Verify the order is being canceled by its maker.
		if (_order.maker != msg.sender) {
			revert OrderValidationFailed();
		}

		// Distinguish the order side. Sell or Buy.
		bool sellSide = _order.saleKind() > 2;

		// Set buyer and seller according to the side of the order.
		uint256 buyer = sellSide ? 0 : uint256(uint160(_order.maker));
		uint256 seller = sellSide ? uint256(uint160(_order.maker)) : 0;

		/* 
			Encode parameters in such manner, for supporting 
			backwards compatibility with previos versions.
		*/
		bytes memory data = abi.encode(
			_order.collection,
			abi.encodePacked(
				bytes4(0),
				seller,
				buyer,
				_order.id,
				_order.amount
			)
		);

		// Update order status.
		_setOrderStatus(hash, ORDER_IS_CANCELLED);

		emit OrderCancelled(
			_order.maker,
			hash,
			data
		);
	}

	/**
		Sets new nonce for the msg.sender.
		
		@param _newNonce The new nonce to use in mass-cancelation.

		@custom:throws InvalidNonce if `_newNonce` is lower than current nonce.
	*/
	function _setNonce (uint256 _newNonce) internal {
		
		// New nonce must be larger than the previous.
		if ( _newNonce <= _getUserNonce(msg.sender) ) {
			revert InvalidNonce();
		}
		
		// Update user nonce.
		_setUserNonce(_newNonce);

		emit AllOrdersCancelled(msg.sender, _newNonce);
	}
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.19;

/// Emitted in the event that transfer of Ether fails.
error TransferFailed ();

/**
	@custom:benediction DEVS BENEDICAT ET PROTEGAT CONTRACTVS MEAM
	@title Native Ether Transfer Library
	@author Rostislav Khlebnikov <@catpic5buck>
	@custom:contributor Tim Clancy <@_Enoch>

	A library for safely conducting Ether transfers and verifying success.

	@custom:date December 4th, 2022.
*/
library NativeTransfer {

	/**
		A helper function for wrapping a low-level Ether transfer call with modern 
		error reversion.

		@param _to The address to send Ether to.
		@param _value The value of Ether to send to `_to`.

		@custom:throws TransferFailed if the transfer of Ether fails.
	*/
	function transferEth (
		address _to,
		uint _value
	) internal {
		(bool success, ) = _to.call{ value: _value }("");
		if (!success) {
			revert TransferFailed();
		}
	}
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.19;

import {
	MemoryPointer,
	ONE_WORD,
	TWO_WORDS,
	THREE_WORDS,
	HASH_OF_ZERO_BYTES,
	PREFIX,
	ZERO_MEMORY_SLOT,
	LUCKY_NUMBER
} from "./Helpers.sol";

import {
	_getUserNonce
} from "./Storage.sol";

import {
	FIXED_PRICE,
	DECREASING_PRICE,
	OFFER,
	COLLECTION_OFFER,
	ORDER_SIZE,
	ORDER_TYPEHASH,
	ERC20_PAYMENT,
	ETH_PAYMENT,
	ASSET_ERC721,
	ASSET_ERC1155,
	TYPEHASH_AND_ORDER_SIZE,
	COLLECTION_OFFER_SIZE,
	DECREASING_PRICE_ORDER_SIZE,
	ORDER_NONCE,
	ORDER_LISTING_TIME,
	ORDER_EXPIRATION_TIME,
	ORDER_MAKER,
	ORDER_ROYALTY,
	ORDER_BASE_PRICE,
	ORDER_TYPE,
	ORDER_COLLECTION,
	ORDER_ID,
	ORDER_AMOUNT,
	ORDER_PAYMENT_TOKEN,
	ORDER_TAKER,
	ORDER_RESOLVE_DATA,
	ORDER_RESOLVE_DATA_LENGTH,
	ORDER_PRICE_DECREASE_FLOOR,
	ORDER_PRICE_DECREASE_END_TIME,
	ORDER_DECREASE_FLOOR_MEMORY,
	ORDER_PRICE_DECREASE_END_TIME_MEMORY
} from "./OrderConstants.sol";

/**
	@custom:benediction DEVS BENEDICAT ET PROTEGAT CONTRACTVS MEAM
	@title Order Library
	@author Rostislav Khlebnikov <@catpic5buck>
	@custom:contributor Tim Clancy <@_Enoch>

	A library for managing supported order entities.
*/

/*
	Struct for providing information on how to fulfill the order.

		strict - flags Partial orders fulfillment strategy:
			true - if order is partially filled and order amount left is 
				lower than fulfillment.amount, order execution stops.
			false - if order is partially filled and order amount left is 
				lower than fulfillment.amount, order executed with
				available amount.
		amount - amount for ERC1155 Partial orders.
		id - token id to fulfill a Collection Offer with.
		proofs - proofs that tokenId belonges to signed collection
			offer merkle tree.
*/
struct Fulfillment {
    bool strict;
    uint256 amount;
    uint256 id;
    bytes32[] proofs;
}

/*
	Wraps the Order struct. Points to specific fulfillment
	index in the array of Fulfillments.

	fillerIndex - points to the specific fulfillment.
*/
struct Execution {
	uint256 fillerIndex;
	uint256 nonce; 
	uint256 listingTime;
	uint256 expirationTime;
	address maker; 
	address taker;
	uint256 royalty; 
	address paymentToken;
	uint256 basePrice; 
	uint256 orderType; 
	address collection; 
	uint256 id;
	uint256 amount;
	bytes resolveData;
}

/*
	Order struct. Contains parameters for trading an ERC721 or
		an ERC1155 for ETH or ERC20.

	nonce - user nonce, with which order had been signed with.
	listingTime - start of the trading period.
	expirationTime - end of the trading period.
	maker - account, which created and signed the order.
	taker - account, which supposed to fulfill the order, or
		order must be fulfilled on behalf of the account.
	royalty - index of the collection royalty, which was used
		at the time of order creation.
	paymentToken - address of the ERC20, or address(0) for ETH.
	basePrice - amount of ERC20 or ETH, item should be sold for.
	orderType - config of the order, contains:
		1. uint64 saleKind: 
			1. FixedPrice
			2. DutchAuction
			3. Offer
			4. Collection offer
		2. uint64 assetType:
			1. ERC721
			2. ERC1155
		3. uint64 fulfillmentType:
			1. Strict - entire order.amount should be filled at once.
			2. Partial - amount can be fulfilled partially.
		4. uint64 paymentType:
			1. ETH
			2. ERC20
	collection - address of the collection contract
	id - id of the token
	amount - amount of the token
	resolveData - array for additional arguments:
		1. DutchAuction - contains 64 bytes of additional arguments:
			uint256 floor - the minimum price for the decay.
			uint256 endTime - when the price should reach it's floor.
		2. CollectionOffer - contains 32 bytes of additional arguments:
			bytes32 root - root of the Merkle Tree, which contains a set
				of selected by the order.maker token ids. Can be empty,
				if CollectionOffer can be fulfilled with any id of the collection.
*/
struct Order {
	uint256 nonce;
	uint256 listingTime;
	uint256 expirationTime;
	address maker;
	address taker;
	uint256 royalty;
	address paymentToken;
	uint256 basePrice;
	uint256 orderType;
	address collection;
	uint256 id;
	uint256 amount;
	bytes resolveData;
}

// Runtime struct for processing FixedPrice listing and Offer.
struct Trade {
	address maker;
	address taker;
	uint256 royalty;
	address paymentToken;
	uint256 basePrice;
	uint256 orderType;
	address collection;
	uint256 id;
	uint256 amount;
}

/*
	Runtime struct for processing DutchAuction.

	floor - lowest boundary of the basePrice decay.
	endTime - when order price reaches floor.
*/
struct DutchAuction {
	address maker;
	address taker;
	uint256 royalty;
	address paymentToken;
	uint256 basePrice;
	uint256 orderType;
	address collection;
	uint256 id;
	uint256 amount;
	uint256 floor;
	uint256 endTime;
}

/*
	Runtime struct for processing CollectionOffer.

	rootHash - hash of the collection offer merkle tree.
*/
struct CollectionOffer {
	address maker;
	address taker;
	uint256 royalty;
	address paymentToken;
	uint256 basePrice;
	uint256 orderType;
	address collection;
	uint256 id;
	uint256 amount;
	bytes32 rootHash;
}

/**
	Creates memory pointer to the order.

	@param _memPtr Memory slot address.

	@return order Order memory type pointer.
*/
function deriveOrder(
	MemoryPointer _memPtr
) pure returns(Order memory order) {
	assembly {
		mstore(
			_memPtr,
			ORDER_TYPEHASH
		)
		order := add(_memPtr, ONE_WORD)
	}
}

using OrderLib for Order global;
using OrderLib for Execution global;
using OrderLib for Trade global;
using OrderLib for CollectionOffer global;
using OrderLib for DutchAuction global;

library OrderLib {

	/// Translates Execution to Order.
	function toOrder (
		Execution calldata _execution
	) internal pure returns (Order calldata order) {
		assembly {
			order := add(_execution, ONE_WORD)
		}
	}

	/// Shrinks Order to Trade size.
	function toTrade (
		Order memory _order
	) internal pure returns (Trade memory trade) {
		assembly {
			trade := add(_order, THREE_WORDS)
		}
	}

	/// Converts DutchAuction to Trade.
	function toTrade (
		DutchAuction memory _auction
	) internal pure returns (Trade memory trade) {
		assembly {
			trade := _auction
		}
	}

	/// Converts CollectionOffer to Trade.
	function toTrade (
		CollectionOffer memory _offer
	) internal pure returns (Trade memory trade) {
		assembly {
			trade := _offer
		}
	}

	/// Converts Order to DutchAuction.
	function toDutchAuction (
		Order memory _order
	) internal pure returns (DutchAuction memory auction) {
		assembly {
			auction := add(_order, THREE_WORDS)
		}
	}

	/// Converts Order to CollectionOffer.
	function toCollectionOffer (
		Order memory _order
	) internal pure returns (CollectionOffer memory offer) {
		assembly {
			offer := add(_order, THREE_WORDS)
		}
	}

	/**
		Read order type and cast to paymentType.

		@param _order Order memory pointer.

		@return _ Payment type value.
	*/
	function paymentType (
		Order memory _order
	) internal pure returns (uint64){
		return uint64(_order.orderType >> 192);
	}

	/**
		Read order type and cast to paymfulfillmentTypeentType.

		@param _order Order memory pointer.

		@return _ Fulfillment type value.
	*/
	function fulfillmentType (
		Order memory _order
	) internal pure returns (uint64) {
		return uint64(_order.orderType >> 128);
	}

	/**
		Read order type and cast to assetType.

		@param _order Order memory pointer.

		@return _ Asset type value.
	*/
	function assetType (
		Order memory _order
	) internal pure returns (uint64) {
		return uint64(_order.orderType >> 64);
	}

	/**
		Read order type and cast to saleKind.

		@param _order Order memory pointer.

		@return _  Sale kind value.
	*/
	function saleKind (
		Order memory _order
	) internal pure returns (uint64) {
		return uint64(_order.orderType);
	}

	/**
		Read order type and cast to paymentType.

		@param _trade Trade memory pointer.

		@return _  Payment type value.
	*/
	function paymentType (
		Trade memory _trade
	) internal pure returns (uint64){
		return uint64(_trade.orderType >> 192);
	}

	/**
		Read order type and cast to fulfillmentType.

		@param _trade Trade memory pointer.

		@return _  Fulfillment type value.
	*/
	function fulfillmentType (
		Trade memory _trade
	) internal pure returns (uint64) {
		return uint64(_trade.orderType >> 128);
	}

	/**
		Read order type and cast to assetType.

		@param _trade Trade memory pointer.

		@return _  Asset type value.
	*/
	function assetType (
		Trade memory _trade
	) internal pure returns (uint64) {
		return uint64(_trade.orderType >> 64);
	}

	/**
		Read order type and cast to saleKind.

		@param _trade Trade memory pointer.

		@return _  Sale kind value.
	*/
	function saleKind (
		Trade memory _trade
	) internal pure returns (uint64) {
		return uint64(_trade.orderType);
	}

	/**
		Validates and then allocates order.maker.

		@param _order Order memory pointer.
		@param _cdPtr Order calldata pointer.

		@return _ Flag of the maker being valid.
	*/
	function validateMaker (
		Order memory _order,
		Order calldata _cdPtr,
		address _fulfiller
	)  internal view returns (bool) {

		// Read maker address from the calldata.
		address maker;
		assembly {
			maker := calldataload(
				add(_cdPtr, ORDER_MAKER)
			)
		}
		/*
			Verify that the order maker is not the `_fulfiller`, nor the msg.sender, nor 
			the zero address.
		*/
		if (
				maker == _fulfiller ||
				maker == msg.sender ||
				maker == address(0)
			) {
				return false;
		}
		// Store maker address at the order memory pointer with an offset.
		assembly {
			mstore(
				add(_order, ORDER_MAKER),
				maker
			)
		}
		return true;
	}

	/**
		Validates and then allocates order.nonce.
		
		@param _order Order memory pointer.
		@param _cdPtr Order calldata pointer.
		@param _maker Order maker from the stack.

		@return _ Flag of the nonce being valid.
	*/
	function validateNonce (
		Order memory _order,
		Order calldata _cdPtr,
		address _maker
	) internal view  returns (bool) {

		// Read nonce from the calldata.
		uint256 nonce;
		assembly {
			nonce := calldataload(
				add(_cdPtr, ORDER_NONCE)
			)
		}
		// Verify that the order was not signed with an expired nonce.
		if (nonce < _getUserNonce(_maker)) {
			return false;
		}
		// Store nonce at the order memory pointer with an offset.
		assembly {
			mstore(
				add(_order, ORDER_NONCE),
				nonce
			)
		}
		return true;
	}

	/**
		Allocate order.orderType.

		@param _order Order memory pointer.
		@param _cdPtr Order calldata pointer.
	*/
	function allocateOrderType (
		Order memory _order,
		Order calldata _cdPtr
	) internal pure {

		//Read order type and store at the order memory pointer with an offset.
		assembly {
			mstore(
				add(_order, ORDER_TYPE),
				calldataload(
					add(_cdPtr, ORDER_TYPE)
				)
			)
		}
	}

	/**
		Return whether or not an order can be settled, verifying that the current
		block time is between order's initial listing and expiration time.

		@param _listingTime The starting time of the order being listed.
		@param _expirationTime The ending time where the order expires.

		@return _ Result of the order period check.
	*/
	function _canSettleOrder (
		uint256 _listingTime,
		uint256 _expirationTime
	) private view returns (bool) {
		return
			(_listingTime < block.timestamp) &&
			(_expirationTime == 0 || block.timestamp < _expirationTime);
	}

	/** 
		Validates trading period and allocates order.listingTime and
		order.expirationTime.
		
		@param _order Order memory pointer.
		@param _cdPtr Order calldata pointer.

		@return _ Flag of order period being valid.	
	*/
	function validateOrderPeriod (
		Order memory _order,
		Order calldata _cdPtr
	) internal view  returns (bool) {
		// Read order period boundaries from the calldata.
		uint256 listingTime_;
		uint256 expirationTime;
		assembly {
			listingTime_ := calldataload(
				add(_cdPtr, ORDER_LISTING_TIME)
			)
			expirationTime := calldataload(
				add(_cdPtr, ORDER_EXPIRATION_TIME)
			)
		}
		// Check if order is within trading period.
		if (
			!_canSettleOrder(
				listingTime_ - LUCKY_NUMBER,
				expirationTime
			)
			) {
			return false;
		}

		// Store period boundaries at the order memory slot with an offset.
		assembly {
			mstore(
				add(_order, ORDER_LISTING_TIME),
				listingTime_
			)
			mstore(
				add(_order, ORDER_EXPIRATION_TIME),
				expirationTime
			)
		}
		return true;
	}

	/**
		Allocates order.taker, order.royalty, order.basePrice, order.collection,
		order.id.

		@param _order Order memory pointer.
		@param _cdPtr Order calldata pointer.
	*/
	function allocateTradeParameters (
		Order memory _order,
		Order calldata _cdPtr
	) internal pure {
		assembly {
			/*
				Read taker from the calldata and store in the order memory slot
				with an offset.
			*/
			mstore(
				add(_order, ORDER_TAKER),
				calldataload(
					add(_cdPtr, ORDER_TAKER)
				)
			)
			/*
				Read  royalty from the calldata and store in the order memory slot
				with an offset.
			*/
			mstore(
				add(_order, ORDER_ROYALTY),
				calldataload(
					add(_cdPtr, ORDER_ROYALTY)
				)
			)
			/*
				Read taker from the calldata and store in the order memory slot
				with an offset.
			*/
			mstore(
				add(_order, ORDER_BASE_PRICE),
				calldataload(
					add(_cdPtr, ORDER_BASE_PRICE)
				)
			)
			/*
				Read collection from the calldata and store in the order memory slot
				with an offset.
			*/
			mstore(
				add(_order, ORDER_COLLECTION),
				calldataload(
					add(_cdPtr, ORDER_COLLECTION)
				)
			)
			/*
				Read id from the calldata and store in the order memory slot
				with an offset.
			*/
			mstore(
				add(_order, ORDER_ID),
				calldataload(
					add(_cdPtr, ORDER_ID)
				)
			)
		}
	}

	/**
		Validate and allocate order payment token address.
		
		@param _order Order memory pointer.
		@param _cdPtr Order calldata pointer.
		@param _saleKind Order sale kind from the stack.
		@param _paymentType Order payment type from the stack.

		@return _ Flag of payment being valid.	
	*/
	function validatePaymentType (
		Order memory _order,
		Order calldata _cdPtr,
		uint64 _saleKind,
		uint64 _paymentType
	) internal pure returns (bool) {
		/*
			Load payment token address from the calldata
			and verify that it is not a zero address.
		*/
		address paymentToken;
		assembly {
			paymentToken := calldataload(
				add(_cdPtr, ORDER_PAYMENT_TOKEN)
			)
		}

		// Validate ERC20 payment type.
		if (_paymentType == ERC20_PAYMENT) {

			if (paymentToken == address(0)) {
				return false;
			}
			// Store payment token address in the order memory slot with an offset.
			assembly{
				mstore(
					add(_order, ORDER_PAYMENT_TOKEN),
					paymentToken
				)
			}
			return true;
		}
	
		// Validate ETH payment type.
		if (_paymentType == ETH_PAYMENT) {

			if (
				paymentToken != address (0) ||
				_saleKind > 1
			) {
				return false;
			}
			// Store payment token address in the order memory slot with an offset.
			assembly{
				mstore(
					add(_order, ORDER_PAYMENT_TOKEN),
					paymentToken
				)
			}
			return true;
		}
		// Return false if payment type didn't match any known type.
		return false;
	}

	/**
		Validate and allocate order amount.

		@param _order Order memory pointer.
		@param _cdPtr Order calldata pointer.
		@param _assetType Order asset type from the stack.
	*/
	function validateAssetType ( 
		Order memory _order,
		Order calldata _cdPtr,
		uint64 _assetType
	) internal pure returns (bool){

		// Read order amount from the calldata.
		uint256 amount;
		assembly {
			amount := calldataload(
				add(_cdPtr, ORDER_AMOUNT)
			)
		}

		// Validate amount for ERC1155 asset.
		if (_assetType == ASSET_ERC1155) {
			
			if (amount == 0) {
				return false;
			}

			// Store amount in the order memory slot with an offset.
			assembly{
				mstore(
					add(_order, ORDER_AMOUNT),
					amount
				)
			}
			return true;
		}

		// Validate amount for ERC721 asset.
		if (_assetType == ASSET_ERC721) {

			if (amount != 0) {
				return false;
			}

			// Store amount in the order memory slot with an offset.
			assembly{
				mstore(
					add(_order, ORDER_AMOUNT),
					amount
				)
			}
			return true;
		}
		return false;
	}

	/**
		Validate saleKind and allocate order resolveData arguments.

		@param _order Order memory pointer.
		@param _memPtr Memory pointer for hashing order.
		@param _cdPtr Order calldata pointer.
		@param _saleKind Order sale kind from the stack.
	*/
	function validateSaleKind (
		Order memory _order,
		MemoryPointer _memPtr,
		Order calldata _cdPtr,
		uint64 _saleKind
	) internal pure returns (bytes32 hash_, bool) {

		// Read additional argument length from the calldata..
		uint256 length;
		assembly {
			length := calldataload(
				add(_cdPtr, ORDER_RESOLVE_DATA_LENGTH)
			)
		}

		// FixedPrice or Offer validation.
		if (_saleKind == FIXED_PRICE || _saleKind == OFFER) {
			
			if (length != 0) {
				return (hash_, false);
			}
			// Store precomputed hash of zero bytes at the resolveData location.
			assembly {
				mstore(
					add(_order, ORDER_RESOLVE_DATA),
					HASH_OF_ZERO_BYTES
				)
				// Derive order hash.
				hash_ := keccak256(
					_memPtr,
					TYPEHASH_AND_ORDER_SIZE
				)
				// Shift memory pointer to the end of the regular order.
				mstore(0x40, add(_order, ORDER_SIZE))
			}
			return (hash_, true);
		}

		// DecreasingPrice validation.
		if (_saleKind == DECREASING_PRICE) {

			if (length != TWO_WORDS) {
				return (hash_, false);
			}

			//Read additional arguments from the calldata.
			uint256 floor;
			uint256 endTime;
			assembly {
				floor := calldataload(add(_cdPtr, ORDER_PRICE_DECREASE_FLOOR))
				endTime := calldataload(add(_cdPtr, ORDER_PRICE_DECREASE_END_TIME))
				mstore(0, floor)
				mstore(ONE_WORD, endTime)

				/*
					Store the hash of the additional arguments at the
					resloveData location.
				*/
				mstore(
					add(_order, ORDER_RESOLVE_DATA),
					keccak256(0, TWO_WORDS)
				)
				// Derive order hash.
				hash_ := keccak256(
					_memPtr,
					TYPEHASH_AND_ORDER_SIZE
				)

				// Store floor in the order memory slot with an offset.
				mstore(
					add(_order, ORDER_DECREASE_FLOOR_MEMORY),
					floor
				)
				// Store endTime in the order memory slot with an offset.
				mstore(
					add(_order, ORDER_PRICE_DECREASE_END_TIME_MEMORY),
					endTime
				)

				// Shift memory pointer to the end of the DecreasingPrice.
				mstore(0x40, add(_order, DECREASING_PRICE_ORDER_SIZE))
			}
			return (hash_, true);
		}
		
		// CollectionOffer validation.
		if (_saleKind == COLLECTION_OFFER) {

			if (_order.id != 0) {
					return (hash_, false);
				}
			
			if (length > ONE_WORD) {
				return (hash_, false);
			}

			// If length is zero, offer can be fulfilled with any token id.
			if ( length != 0) {
				// Read rootHash from the calldata.
				bytes32 rootHash;
				assembly{
					rootHash := calldataload(add(_cdPtr, ORDER_PRICE_DECREASE_FLOOR))
					// Store rootHash in the first memory slot.
					mstore(
						0,
						rootHash
					)
					/*
						Store the hash of the rootHash at the
						resloveData location.
					*/
					mstore(
						add(_order, ORDER_RESOLVE_DATA),
						keccak256(0, ONE_WORD)
					)
					// Derive order hash.
					hash_ := keccak256(
						_memPtr,
						TYPEHASH_AND_ORDER_SIZE
					)
					// Store rootHash in the order memory slot with an offset.
					mstore(
						add(_order, ORDER_RESOLVE_DATA),
						rootHash
					)
					// Shift memory pointer to the end of the Collection Offer.
					mstore(0x40, add(_order, COLLECTION_OFFER_SIZE))
				}
			} else {
				assembly{
					// Store precomputed hash of zero bytes at the resolveData location.
					mstore(
						add(_order, ORDER_RESOLVE_DATA),
						HASH_OF_ZERO_BYTES
					)
					// Derive order hash.
					hash_ := keccak256(
						_memPtr,
						TYPEHASH_AND_ORDER_SIZE
					)
					// Store 0 in the rootHash field of the order.
					mstore(
						add(_order, ORDER_RESOLVE_DATA),
						0
					)
					// Shift memory pointer to the end of the Collection Offer.
					mstore(0x40, add(_order,COLLECTION_OFFER_SIZE))
				}
			}
			return (hash_, true);
		}
		// Did not match any kind of sale.
		return (hash_, false);
	}

	/**
		Derives order hash.

		@param _order Order calldata pointer.

		@return _ Hash of the order.
	*/
	function hash (
		Order calldata _order
	) internal pure returns (bytes32) {
		return keccak256(
			abi.encode(
				ORDER_TYPEHASH,
				_order.nonce,
				_order.listingTime,
				_order.expirationTime,
				_order.maker,
				_order.taker,
				_order.royalty,
				_order.paymentToken,
				_order.basePrice,
				_order.orderType,
				_order.collection,
				_order.id,
				_order.amount,
				keccak256(_order.resolveData)
			)
		);
	}
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.19;

/*
    This file contains verbose constant for future use in
    function and inline assembly.
 */

// SaleKind constants.
uint64 constant FIXED_PRICE = 0;
uint64 constant DECREASING_PRICE = 1;
uint64 constant OFFER = 2;
uint64 constant COLLECTION_OFFER = 3;

// AssetTyoe constants.
uint64 constant ASSET_ERC721 = 0;
uint64 constant ASSET_ERC1155 = 1;

// FulfillmentType constants.
uint64 constant STRICT = 0;
uint64 constant PARTIAL = 1;

// PaymentType constants.
uint64 constant ETH_PAYMENT = 0;
uint64 constant ERC20_PAYMENT = 1;

// Constants used for deriving order hash.
uint256 constant TYPEHASH_AND_ORDER_SIZE = 0x1c0;
uint256 constant ORDER_SIZE = 0x180;
uint256 constant COLLECTION_OFFER_SIZE = 0x1a0;
uint256 constant DECREASING_PRICE_ORDER_SIZE = 0x1c0;

// Order offsets, Trade offsets, Auction offsets, Colection offer offsets.
uint256 constant ORDER_NONCE = 0x0;
uint256 constant ORDER_LISTING_TIME = 0x20;
uint256 constant ORDER_EXPIRATION_TIME = 0x40;
uint256 constant ORDER_MAKER = 0x60;
uint256 constant ORDER_TAKER = 0x80;
uint256 constant ORDER_ROYALTY = 0xa0;
uint256 constant ORDER_PAYMENT_TOKEN = 0xc0;
uint256 constant ORDER_BASE_PRICE = 0xe0;
uint256 constant ORDER_TYPE = 0x100;
uint256 constant ORDER_COLLECTION = 0x120;
uint256 constant ORDER_ID = 0x140;
uint256 constant ORDER_AMOUNT = 0x160;
uint256 constant ORDER_RESOLVE_DATA = 0x180;
uint256 constant ORDER_RESOLVE_DATA_LENGTH = 0x1a0;
uint256 constant ORDER_COLECTION_OFFER_ROOTHASH = 0x1c0;
uint256 constant ORDER_COLECTION_OFFER_ROOTHASH_MEMORY = 0x180;
uint256 constant ORDER_PRICE_DECREASE_FLOOR = 0x1c0;
uint256 constant ORDER_DECREASE_FLOOR_MEMORY = 0x180;
uint256 constant ORDER_PRICE_DECREASE_END_TIME = 0x1e0;
uint256 constant ORDER_PRICE_DECREASE_END_TIME_MEMORY = 0x1a0;
uint256 constant TRADE_MAKER = 0;
uint256 constant TRADE_COLLECTION = 0xc0;
uint256 constant TRADE_ID = 0xe0;
uint256 constant TRADE_AMOUNT = 0x100;
uint256 constant TRADE_PAYMENT_TOKEN = 0x60;

// Order status constants.
uint256 constant ORDER_IS_OPEN = 0;
uint256 constant ORDER_IS_PARTIALLY_FILLED = 1;
uint256 constant ORDER_IS_FULFILLED = 2;
uint256 constant ORDER_IS_CANCELLED = 3;

// OrderResult event constants.
bytes32 constant ORDER_RESULT_SELECTOR = 
	0xa6b12b6984bda6bd875df5a33eaeb64d6d12857b59a7d120bf9444b1bf7796a1;
uint256 constant ORDER_RESULT_DATA_LENGTH = 0xaa;
bytes1 constant SUCCESS_CODE = 0xFF;

// Order typehash.
bytes32 constant ORDER_TYPEHASH =
		0x68d866f4b3d9454104b120166fed55c32dec7cdc4364d96d3c35fd74f499a546;

// 
uint256 constant MAX_BULK_ORDER_HEIGHT = 10;

// Typehashes for the merkle tree based on it's height. 
bytes32 constant BULK_ORDER_HEIGHT_ONE_TYPEHASH =
    0xcd0511c3edba288c7b7022a4e9d1309409d7c3dc815549ad502ae3c83153ec8d;

bytes32 constant BULK_ORDER_HEIGHT_TWO_TYPEHASH =
    0x9beb8a38951a872487aa75e49e0e6f218b38eae90fe3657ec10cd87fd1aca5f6;

bytes32 constant BULK_ORDER_HEIGHT_THREE_TYPEHASH =
    0x1907e099cd0b102d6d866a233966dace07bb7555aaaebc8389f11be90fc095c4;

bytes32 constant BULK_ORDER_HEIGHT_FOUR_TYPEHASH =
    0x89ee6c2dd775f15a95d29597ba9ce62100b4dd0bd6b6b2eefcfa4d2bd80af43b;

bytes32 constant BULK_ORDER_HEIGHT_FIVE_TYPEHASH =
    0x21f4c248b5e14bf8fd8d4ce2a90d95af66ada155282e47b9a2fe531c1ac8bf46;

bytes32 constant BULK_ORDER_HEIGHT_SIX_TYPEHASH =
    0x7974a224dd38aa4de830ad422e8b8b87952eb0c7ecdc515455b2d6b93856431f;

bytes32 constant BULK_ORDER_HEIGHT_SEVEN_TYPEHASH =
    0x8786a4d3c6831f1b8000b3fdbe170ebdd58e9ebf3533a5e18b41d7d4a8ef6a2d;

bytes32 constant BULK_ORDER_HEIGHT_EIGHT_TYPEHASH =
    0x525015a897b863903af7bd14d2d1c20bb2b74c85c251887728c8d87a277919d5;

bytes32 constant BULK_ORDER_HEIGHT_NINE_TYPEHASH =
    0x6f0940942471b62e57a516ba875d9e2f380ac3f44782f7a1aa1efd749b236128;

bytes32 constant BULK_ORDER_HEIGHT_TEN_TYPEHASH =
    0x49df94d1aa107700bd757da74f9ff6bd21ae6cedb7b5679fc606558a953e4700;
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.19;

import {
	MemoryPointer,
	FREE_MEMORY_POINTER,
	TRANSFER_ITEM_SELECTOR,
	TRANSFER_ITEM_DATA_LENGTH,
	ERC721_ITEM_TYPE,
	ERC1155_ITEM_TYPE,
	PRECISION,
	ONE_WORD,
	TWO_WORDS,
	ONE_WORD_SHIFT,
	_freeMemoryPointer
} from "./Helpers.sol";

import {
	Fulfillment,
	Order,
	Trade,
	CollectionOffer,
	DutchAuction
} from "./Order.sol";

import {
	NativeTransfer
} from "./NativeTransfer.sol";

import {
	FIXED_PRICE,
	DECREASING_PRICE,
	OFFER,
	COLLECTION_OFFER,
	STRICT,
	PARTIAL,
	ASSET_ERC721,
	ASSET_ERC1155,
	ETH_PAYMENT,
	ERC20_PAYMENT,
	TRADE_COLLECTION,
	ORDER_IS_PARTIALLY_FILLED,
	ORDER_IS_FULFILLED,
	ORDER_RESULT_SELECTOR,
	ORDER_RESULT_DATA_LENGTH,
	SUCCESS_CODE
} from "./OrderConstants.sol";

import {
	_getProtocolFee,
	_getRoyalty,
	_getOrderFillAmount,
	_setOrderFillAmount,
	_setOrderStatus
} from "./Storage.sol";

import {
	Item,
	ItemType,
	ERC20Payment,
	IAssetHandler
} from "../../manager/interfaces/IGigaMartManager.sol";

/// Thrown if msg.value is lover than required ETH amount.
error NotEnoughValueSent();

/**
	@custom:benediction DEVS BENEDICAT ET PROTEGAT CONTRACTVS MEAM
	@title GigaMart Order Fulfiller
	@author Rostislav Khlebnikov <@catpic5buck>

	A contract for distinguishing Order execution strategy, transferring Items
	and handling payments.
*/
contract OrderFulfiller {
	using NativeTransfer for address;

	/**
		Emitted at each attempt of exchanging an item.

		@param order The hash of the order.
		@param maker The order maker's address.
		@param taker The order taker's address.
		@param data An array of bytes that contains the success status,
			order sale kind, price, payment token, target, and transfer data.
	*/
	event OrderResult (
		bytes32 order,
		address indexed maker,
		address indexed taker,
		bytes data
	);

    IAssetHandler internal immutable _ASSET_HANDLER;

	/**
		Construct a new instance of the OrderFulfiller.

		@param _assetHandler The address of the existing manager contract.
	*/
    constructor (
        IAssetHandler _assetHandler
    ){
        _ASSET_HANDLER = _assetHandler;
    }

	/**
		Helper function for emitting OrderResult
			with the error code and lesser memory usage.

		@param _code error code.
		@param _hash order hash.
		@param _trade trade parameters
	*/
	function _emitOrderFailed (
		bytes1 _code,
		bytes32 _hash,
		Trade memory _trade,
		address _taker
	) internal {
		address maker = _trade.maker;
		assembly {
			mstore(0, _hash)
			mstore(add(0, 0x20), _code)
			log3(
				0,
				0x21,
				ORDER_RESULT_SELECTOR,
				maker,
				_taker
			)
		}
	}

	/**
		Helper function for emitting OrderResult

		@param _hash order hash.
		@param _price price, with which order was fulfilled.
		@param _trade trade parameters.
		@param _id id of the token.
		@param _amount amount of traded ERC721 or ERC1155.
		@param _taker account, which fulfilled the order or on
			whose behalf order was executed..
	*/
	function _emitOrderResultSuccess (
		bytes32 _hash,
		uint256 _price,
		Trade memory _trade,
		uint256 _id,
		uint256 _amount,
		address _taker
	) private {
		// read needed parameters from the trade.
		bytes1 saleKind = bytes1(uint8(_trade.saleKind()));
		address paymentToken = _trade.paymentToken;
		address collection = _trade.collection;
		address maker = _trade.maker;

		assembly {
			// Read free memory pointer.
			let ptr := mload(0x40)
			// Allocate OrderResult data at free pointer.
			mstore(ptr, _hash)
			mstore(add(ptr, 0x20), SUCCESS_CODE)
			mstore(add(ptr, 0x21), saleKind)
			mstore(add(ptr, 0x22), _price)
			mstore(add(ptr, 0x42), shl(96, paymentToken))
			mstore(add(ptr, 0x56), shl(96, collection))
			mstore(add(ptr, 0x6a), _id)
			mstore(add(ptr, 0x8a), _amount)
			// Emit OrderResult.
			log3(
				ptr,
				ORDER_RESULT_DATA_LENGTH,
				ORDER_RESULT_SELECTOR,
				maker,
				_taker
			)
		}
	}

	/**
		Calculates and transfers payments to the seller.

		@param _trade trade parameters.
		@param _price calculated price for the order.
		@param _seller address of the item seller.
		@param _buyer address of the item buyer.

		@custom:throws NotEnoughValueSent if msg.value lower than `_price`.
		@custom:throws TransferFailed if ETH transfer fails.
	*/
	function _pay (
		Trade memory _trade,
		uint256 _price,
		address _seller,
		address _buyer
	) private returns (uint256 ethPayment) {
		// Do nothing if price is 0.
		if (_price > 0) {
			// Distinguish paymentType.
			uint64 paymentType = _trade.paymentType();

			// Execute ETH payment.
			if (paymentType == ETH_PAYMENT) {
				// Check if enough ETH is sent with the call.
				if (msg.value < _price) {
					revert NotEnoughValueSent();
				}
				// track ethPayment.
				ethPayment = _price;

				// Track amount of eth to be received by the seller.
				uint256 receiveAmount = _price;

				// Read protocol fee config.
				uint256 config = _getProtocolFee();
				if (uint96(config) != 0) {
					// Calculate fee amount.
					uint256 fee = (_price * uint96(config)) / PRECISION;
					// Transfer ETH to the fee recipient.
					address(uint160(config >> 96)).transferEth(fee);
					//Substract fee from receive.amount.
					receiveAmount -= fee;
				}

				// Read royalty fee config.
				config = _getRoyalty(_trade.collection, _trade.royalty);
				if (uint96(config) != 0) {
					// Calculate fee amount.
					uint256 fee = (_price * uint96(config)) / PRECISION;
					// Transfer ETH to the fee recipient.
					address(uint160(config >> 96)).transferEth(fee);
					//Substract fee from receiveAmount.
					receiveAmount -= fee;
				}
				// Transfer the remainder of the payment to the item seller.
				_seller.transferEth(receiveAmount);
			}

			// Execute ERC20 payment.
			if (paymentType == ERC20_PAYMENT) {
				// Track amount of ERC20 to be received by the seller.
				uint256 receiveAmount = _price;

				// Read protocol fee config.
				uint256 config = _getProtocolFee();
				if (uint96(config) != 0) {
					// Calculate fee amount.
					uint256 fee = (_price * uint96(config)) / PRECISION;
					// Transfer ERC20 to the fee recipient.
					_ASSET_HANDLER.transferERC20(
						_trade.paymentToken,
						_buyer,
						 address(uint160(config >> 96)),
						fee
					);
					//Substract fee from receiveAmount.
					receiveAmount -= fee;
				}

				// Read royalty fee config.
				config = _getRoyalty(_trade.collection, _trade.royalty);
				if (uint96(config) != 0) {
					// Calculate fee amount.
					uint256 fee = (_price * uint96(config)) / PRECISION;
					// Transfer ERC20 to the fee recipient.
					_ASSET_HANDLER.transferERC20(
						_trade.paymentToken,
						_buyer,
						 address(uint160(config >> 96)),
						fee
					);
					//Substract fee from receiveAmount.
					receiveAmount -= fee;
				}

				// Transfer the remainder of the payment to the item seller.
				_ASSET_HANDLER.transferERC20(
					_trade.paymentToken,
					_buyer,
					_seller,
					receiveAmount
				);
			}
		}
	}

	/**
		Updates order status and, in case of partial order,
		updates fill amount.

		@param _hash Hash of the order.
		@param _amount Amount fill with this call.
		@param _previousAmount Previously filled amount.
		@param _totalAmount Total order amount.
		@param _fulfillmentType Order fulfillment type.
	*/
	function _updateOrderStatus(
		bytes32 _hash,
		uint256 _amount,
		uint256 _previousAmount,
		uint256 _totalAmount,
		uint64 _fulfillmentType
	) private {
		if (_fulfillmentType == STRICT) {
			// Mark order as fulfilled.
			_setOrderStatus(
				_hash,
				ORDER_IS_FULFILLED
			);
		} else {
			/* 
				If order amount is exhausted, update order status to Fullfilled,
				if not set order status as PARTIALLY_FILLED.
			*/
			_setOrderStatus(
				_hash,
				_previousAmount + _amount < _totalAmount ?
					ORDER_IS_PARTIALLY_FILLED :
					ORDER_IS_FULFILLED
			);

			// Update order fill amount.
			_setOrderFillAmount(
				_hash,
				_previousAmount + _amount
			);
		}
	}

	/**
		Transfers item from the seller to the recipient.

		@param _trade trade parameters.
		@param _hash hash of the order.
		@param _id id of the token.
		@param _fulfillmentType order fulfillmentType.
		@param _seller address of the seller.
		@param _recipient address of the recipent.
		@param _fulfillment fulfiller struct, containing information on how to fulfill
			the order.

		@return result flags if transfer was successfull.
		@return price calculated price.
		@return amount amount of transferred item.
	*/
	function _transferItem (
		Trade memory _trade,
		bytes32 _hash,
		uint256 _id,
		uint64 _fulfillmentType,
		address _seller,
		address _recipient,
		Fulfillment calldata _fulfillment
	) private returns (
		bool result,
		uint256 price,
		uint256 amount,
		uint256 previousAmount
	) {
		// Put handler address on the stack, for using in assembly.
		IAssetHandler handler = _ASSET_HANDLER;
		// Create a memory pointer to the Item.
		Item memory item;
		// Read current free memory pointer.
		MemoryPointer memPtr = _freeMemoryPointer();

		assembly {
			// Store IAssetHandler.transferItem.selector
			mstore(
				memPtr,
				TRANSFER_ITEM_SELECTOR
			)
			// Update item pointer.
			item := add(memPtr, 0x4)
			// Store collection address as Item.collection field.
			mstore(
				add(item, 0x20),
				mload(add(_trade, TRADE_COLLECTION))
			)
			// Store seller address as Item.from field.
			mstore(
				add(item, 0x40),
				_seller
			)
			// Store recipient address as Item.to field.
			mstore(
				add(item, 0x60),
				_recipient
			)
			// Store recipient address as Item.id field.
			mstore(
				add(item, 0x80),
				_id
			)
		}

		/*
			If order.assetType is ERC721 store ItemType.ERC721 as
			Item.itemType field.
		*/ 
		if (_trade.assetType() == ASSET_ERC721) {
			// Price equals original order.basePrice.
			price = _trade.basePrice;
			//Set amount to 1. 
			amount = 1;
			assembly {
				mstore(
					item,
					ERC721_ITEM_TYPE
				)
				mstore(
					add(item, 0xa0),
					0
				) 
			}
		}

		/*
			If order.assetType is ERC1155 store ItemType.ERC1155 as
			Item.itemType field.
		*/ 
		if (_trade.assetType() == ASSET_ERC1155) {

			// Check if desired amount is greater than order.amount.
			if (_fulfillment.amount > _trade.amount) {
				return (false, 0, 0, 0);
			}

			// If fullfilmentType is STRICT.
			if (_fulfillmentType == STRICT) {
				// Amount equals original order.amount.
				amount = _trade.amount;
			}

			// If fullfilmentType is PARTIAL.
			if (_fulfillmentType == PARTIAL) {
				// Amount equals desired amount.
				amount = _fulfillment.amount;

				//Read already filled amount
				previousAmount =_getOrderFillAmount(_hash);
				// Calculate this order's leftover amount.
				uint256 leftover =_trade.amount - previousAmount;

				// If fulfillment must be strict.
				if (_fulfillment.strict) {
					// Check if leftover satisfies desired amount.
					if ( leftover < amount) {
						return (false, 0, 0, 0);
					}
				} else {
					// If fulfillment is lenient and leftover is less than desired amount.
					if ( leftover < amount) {
						// Set amount to leftover amount.
						amount = leftover;
					}
				}
			}

			assembly {
				// Store ItemType.ERC1155 as Item.itemType field.
				mstore(
					item,
					ERC1155_ITEM_TYPE
				)
				// Store amount as Item.amount field.
				mstore(
					add(item, 0xa0),
					amount
				)
			}
			// Calculate the price of this portion of order.amount.
			price = amount * _trade.basePrice / _trade.amount;
		}

		// Execute item transfer call and return it's result.
		assembly {
			result := call(
				gas(),
				handler,
				0,
				memPtr,
				TRANSFER_ITEM_DATA_LENGTH,
				0, 0
			)
		}
	}

	/**
		Contains logic for fulfilling a FixedPrice listing.

		@param _trade trade parameters.
		@param _hash hash of the order.
		@param _fulfillmentType order fulfillment type, STRICT or PARTIAL
			 in case of ERC1155.
		@param _itemRecipient recipient of the item in question.
		@param _fulfillment fulfiller struct, containing information on how to fulfill
			the order.
	*/
	function _fulfillListing (
		Trade memory _trade,
		bytes32 _hash,
		uint64 _fulfillmentType,
		address _itemRecipient,
		Fulfillment calldata _fulfillment
	) private returns (uint256, bool) {

		// Execute item transfer, calculate price and amount.
		(
			bool result,
			uint256 basePrice,
			uint256 amount,
			uint256 previousAmount
		) = _transferItem(
			_trade,
			_hash,
			_trade.id,
			_fulfillmentType,
			_trade.maker,
			_itemRecipient,
			_fulfillment
		);

		// Exit if item transfer failed.
		if (!result) {
			return (0, false);
		}

		// Pay for item, track spent ETH.
		uint256 ethPayment = _pay(
			_trade,
			basePrice,
			_trade.maker,
			msg.sender
		);

		// Update order status.
		_updateOrderStatus(
			_hash,
			amount, 
			previousAmount,
			_trade.amount,
			_fulfillmentType
		);

		// Emit the event with computed parameters.
		_emitOrderResultSuccess(
			_hash,
			basePrice,
			_trade,
			_trade.id,
			amount,
			_itemRecipient
		);

		// Return amount of spent ETH and success.
		return (ethPayment, true);
	}

	/**
		Contains logic for fulfilling an Offer.

		@param _trade trade parameters.
		@param _hash hash of the order.
		@param _fulfillmentType order fulfillment type, STRICT or 
			PARTIAL in case of ERC1155.
		@param _paymentRecipient recipient of the payment for the item.
		@param _fulfillment fulfiller struct, containing information on how to fulfill
			the order.
	*/
	function _fulfillOffer (
		Trade memory _trade,
		bytes32 _hash,
		uint64 _fulfillmentType,
		address _paymentRecipient,
		Fulfillment calldata _fulfillment
	) private returns (uint256, bool) {

		// Execute item transfer, calculate price and amount.
		(
			bool result,
			uint256 basePrice,
			uint256 amount,
			uint256 previousAmount
		) = _transferItem(
			_trade,
			_hash,
			_trade.id,
			_fulfillmentType,
			msg.sender,
			_trade.maker,
			_fulfillment
		);

		// Exit if item transfer failed.
		if (!result) {
			return (0, false);
		}

		// Pay for item.
		_pay(
			_trade,
			basePrice,
			_paymentRecipient,
			_trade.maker
		);

		// Update order status.
		_updateOrderStatus(
			_hash,
			amount, 
			previousAmount,
			_trade.amount,
			_fulfillmentType
		);
		
		// Emit the event with computed parameters.
		_emitOrderResultSuccess(
			_hash,
			basePrice,
			_trade,
			_trade.id,
			amount,
			_paymentRecipient
		);

		// Return success.
		return (0, true);
	}

	/**
		Verifies that leaf belongs to the merkle tree.

		@param _leaf leaf of the merkle tree.
		@param _root root of the merkle tree.
		@param _proofs supplied proofs for computing root of the merkle tree.

		@return valid flags if leaf belongs to the merkle tree.
	*/
	function _verifyProof (
		uint256 _leaf,
		bytes32 _root,
		bytes32[] calldata _proofs
	) private pure returns (bool valid) {
		assembly {
			mstore(0, _leaf)
			let hash := keccak256(0, ONE_WORD)
			let length := _proofs.length

			for {
				let idx := 0
			} lt(idx, length) {
				// Increment by one word at a time.
				idx := add(idx, 1)
			} {
				// Get the proof.
				let proof := calldataload(add(_proofs.offset, mul(idx, ONE_WORD)))

				// Store lesser value in the zero slot
				let ptr := shl(ONE_WORD_SHIFT, gt(hash, proof))
				mstore(ptr, hash)
				mstore(xor(ptr, ONE_WORD), proof)

				// Calculate the hash.
				hash := keccak256(0, TWO_WORDS)
			}

			// Compare the final hash to the supplied root.
			valid := eq(hash, _root)
		}
	}

	/**
		Verifies that token id belongs to set of token ids defined in
		the merkle tree, which root had been put in the order.resolveData
		and signed by the order.maker.

		@param _offer collection offer.
		@param _fulfillment fulfiller struct, containing information on how to fulfill
			the `_offer`.
	*/
	function _verifyTokenId (
		CollectionOffer memory _offer,
		Fulfillment calldata _fulfillment
	) private pure returns (bool) {
		// If rootHash was not supplied, offer can be executed with any token.
		if (_offer.rootHash != 0){
			return _verifyProof(
				_fulfillment.id,
				_offer.rootHash,
				_fulfillment.proofs
			);
		}
		return true;
	}

	/**
		Contains logic for fulfilling a CollectionOffer.

		@param _offer collection offer parameters.
		@param _hash hash of the order.
		@param _fulfillmentType order fulfillment type, STRICT or 
			PARTIAL in case of ERC1155.
		@param _paymentRecipient recipient of the payment for the item.
		@param _fulfillment fulfiller struct, containing information on how to fulfill
			the order.
	*/
	function _fulfillCollectionOffer (
		CollectionOffer memory _offer,
		bytes32 _hash,
		uint64 _fulfillmentType,
		address _paymentRecipient,
		Fulfillment calldata _fulfillment
	) private returns (uint256, bool) {
		
		// Check if can fulfill with provided token id.
		if (!_verifyTokenId(
				_offer,
				_fulfillment
			)
		) {
			return (0, false);
		}

		// Execute item transfer, calculate price and amount.
		(
			bool result,
			uint256 basePrice,
			uint256 amount,
			uint256 previousAmount
		) = _transferItem(
			_offer.toTrade(),
			_hash,
			_fulfillment.id,
			_fulfillmentType,
			msg.sender,
			_offer.maker,
			_fulfillment
		);

		// Exit if item transfer failed.
		if (!result) {
			return (0, false);
		}

		// Pay for item.
		_pay(
			_offer.toTrade(),
			basePrice,
			_paymentRecipient,
			_offer.maker
		);

		// Update order status.
		_updateOrderStatus(
			_hash,
			amount, 
			previousAmount,
			_offer.amount,
			_fulfillmentType
		);

		// Emit the event with computed parameters.
		_emitOrderResultSuccess(
			_hash,
			basePrice,
			_offer.toTrade(),
			_fulfillment.id,
			amount,
			_paymentRecipient
		);

		return (0, true);
	}

	/**
		Calculate the final settlement price of an auction.

		@param _listingTime order listing time.
		@param _auction _auction parameters.

		@return _ decayed price.
	*/
	function _priceDecay (
		uint256 _amount,
		uint256 _listingTime,
		DutchAuction memory _auction
	) private view returns (uint256) {
		/*
			If the timestamp at which price decrease concludes has been exceeded,
			the item listing price maintains its configured floor price.
		*/
		if (block.timestamp >= _auction.endTime) {
			return _auction.floor * _amount / 
				(_auction.amount == 0 ? 1 : _auction.amount);
		}

		/*
			Calculate the portion of the decreasing total price that has not yet
			decayed.
		*/
		uint undecayed =

			// The total decayable portion of the price.
			(_auction.basePrice - _auction.floor) *

			// The duration in seconds of the time remaining until total decay.
			(_auction.endTime - block.timestamp) /

			/*
				The duration in seconds between the order listing time and the time
				of total decay.
			*/
			(_auction.endTime - _listingTime);

		// Return the current price as the floor price plus the undecayed portion.
		return (_auction.floor + undecayed) * _amount / 
			(_auction.amount == 0 ? 1 : _auction.amount);
	}

	/**
		Contains logic for fulfilling a DutchAuction.

		@param _auction trade parameters.
		@param _hash hash of the order.
		@param _fulfillmentType order fulfillment type, STRICT or 
			PARTIAL in case of ERC1155.
		@param _itemRecipient recipient of the item in question.
		@param _fulfillment fulfiller struct, containing information on how to fulfill
			the order.
	*/
	function _fulfillDutchAuction (
		DutchAuction memory _auction,
		bytes32 _hash,
		uint64 _fulfillmentType,
		address _itemRecipient,
		uint256 _listingTime,
		Fulfillment calldata _fulfillment
	) private returns (uint256, bool) {

		// Execute item transfer, calculate price and amount.
		(
			bool result, ,
			uint256 amount,
			uint256 previousAmount
		) = _transferItem(
			_auction.toTrade(),
			_hash,
			_auction.id,
			_fulfillmentType,
			_auction.maker,
			_itemRecipient,
			_fulfillment
		);

		// Exit if item transfer failed.
		if (!result) {
			return (0, false);
		}

		// Calculate price decay.
		uint256 price = _priceDecay(
			amount,
			_listingTime,
			_auction
		);

		// Pay for item, track spent ETH.
		uint256 ethPayment = _pay(
			_auction.toTrade(),
			price,
			_auction.maker,
			msg.sender
		);

		// Update order status.
		_updateOrderStatus(
			_hash,
			amount, 
			previousAmount,
			_auction.amount,
			_fulfillmentType
		);

		// Emit the event with computed parameters.
		_emitOrderResultSuccess(
			_hash,
			price,
			_auction.toTrade(),
			_auction.id,
			amount,
			_itemRecipient
		);

		// Return amount of spent ETH and success.
		return (ethPayment, true);
	}

	/**
		Distinguishes function to execute order with.

		@param _saleKind order sale kind.
		@param _hash hash of the order.
		@param _order order parameters.
		@param _recipient account, which receives item or payment.
		@param _fulfillment fulfiller struct, containing information on how to fulfill
			the order.
		
		@return _ spent ETH amount.
		@return _ flags if item transfer was successful.
	*/
	function _fulfill (
		uint64 _saleKind,
		bytes32 _hash,
		Order memory _order,
		address _recipient,
		Fulfillment calldata _fulfillment
	) internal returns (uint256, bool){

		// Execute FixedPrice listing strategy.
		if ( _saleKind == FIXED_PRICE) {
			return _fulfillListing(
				_order.toTrade(),
				_hash,
				_order.fulfillmentType(),
				_recipient,
				_fulfillment
			);
		}

		// Execute Offer strategy.
		if ( _saleKind == OFFER) {
			return _fulfillOffer(
				_order.toTrade(),
				_hash,
				_order.fulfillmentType(),
				_recipient,
				_fulfillment
			);
		}

		// Execute Collection Offer strategy.
		if ( _saleKind == COLLECTION_OFFER) {
			return _fulfillCollectionOffer(
				_order.toCollectionOffer(),
				_hash,
				_order.fulfillmentType(),
				_recipient,
				_fulfillment
			);
		}

		// Execute Dutch Auction strategy.
		if ( _saleKind == DECREASING_PRICE) {
			return _fulfillDutchAuction(
				_order.toDutchAuction(),
				_hash,
				_order.fulfillmentType(),
				_recipient,
				_order.listingTime,
				_fulfillment
			);
		}

		// Unknown strategy.
		return (0, false);
	}
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.19;

import {
	PermitControl
} from "../../access/PermitControl.sol";

import {
	_getProtocolFee,
	_setProtocolFee
} from "./Storage.sol";

/// Thrown if attempting to set the protocol fee to zero.
error ProtocolFeeRecipientCannotBeZero();

/**
	@custom:benediction DEVS BENEDICAT ET PROTEGAT CONTRACTVS MEAM
	@title GigaMart Protocol Fee Manager
	@author Rostislav Khlebnikov <@catpic5buck>
	@custom:contributor Tim Clancy <@_Enoch>

	A contract for providing platform fee management capabilities to GigaMart.
*/
contract ProtocolFeeManager is PermitControl {

	/**
		The public identifier for the right to update the fee configuration.
		_FEE_CONFIG = keccak256("FEE_CONFIG");
	*/
	bytes32 private constant _FEE_CONFIG = 
		0x04c68c9fff15bf997e5ceb309a37aa8077e41018445f90182d108811f0c988e3;

	/**
		Emmited when protocol fee config is altered.

		@param oldProtocolFeeRecipient The previous recipient address of protocol 
			fees.
		@param newProtocolFeeRecipient The new recipient address of protocol fees.
		@param oldProtocolFeePercent The previous amount of protocol fees.
		@param newProtocolFeePercent The new amount of protocol fees. 
	*/
	event ProtocolFeeChanged (
		address oldProtocolFeeRecipient,
		address newProtocolFeeRecipient,
		uint256 oldProtocolFeePercent,
		uint256 newProtocolFeePercent
	);

	/**
		Construct a new instance of the GigaMart fee manager.

		@param _protocolFeeRecipient The address that receives the protocol fee.
		@param _protocolFeePercent The percentage of the protocol fee in basis 
			points, i.e. 200 = 2%.
	*/
	constructor (
		address _protocolFeeRecipient,
		uint96 _protocolFeePercent
	) {
		unchecked {
			uint256 newProtocolFee =
				(uint256(uint160(_protocolFeeRecipient)) << 96) +
				uint256(_protocolFeePercent);
			_setProtocolFee(newProtocolFee);
		}
	}

	/**
		Returns current protocol fee config.
	*/
	function currentProtocolFee() public view returns (address, uint256) {
		uint256 fee = _getProtocolFee();
		return (address(uint160(fee >> 96)), uint256(uint96(fee)));
	}

	/**
		Changes the the fee details of the protocol.

		@param _newProtocolFeeRecipient The address of the new protocol fee 
			recipient.
		@param _newProtocolFeePercent The new amount of the protocol fees in basis 
			points, i.e. 200 = 2%.

		@custom:throws ProtocolFeeRecipientCannotBeZero if attempting to set the 
			recipient of the protocol fees to the zero address.
	*/
	function changeProtocolFees (
		address _newProtocolFeeRecipient,
		uint256 _newProtocolFeePercent
	) external hasValidPermit(_UNIVERSAL, _FEE_CONFIG) {
		if (_newProtocolFeeRecipient == address(0)) {
			revert ProtocolFeeRecipientCannotBeZero();
		}

		// Update the protocol fee.
		uint256 oldProtocolFee = _getProtocolFee();
		unchecked {
			uint256 newprotocolFee =
				(uint256(uint160(_newProtocolFeeRecipient)) << 96) +
				uint256(_newProtocolFeePercent);
			_setProtocolFee(newprotocolFee);
		}

		// Emit an event notifying about the update.
		emit ProtocolFeeChanged(
			address(uint160(oldProtocolFee >> 96)),
			_newProtocolFeeRecipient,
			uint256(uint96(oldProtocolFee)),
			_newProtocolFeePercent
		);
	}
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.19;

import {
	ProtocolFeeManager
} from "./ProtocolFeeManager.sol";

import {
	DomainAndTypehashes
} from "./DomainAndTypehashes.sol";

import {
	FREE_MEMORY_POINTER,
	_freeMemoryPointer,
	_recover
} from "./Helpers.sol";

import {
	_getValidatorAddress,
	_setValidatorAddress,
	_getRoyalty,
	_setRoyalty,
	_getRoyaltyIndex
} from "./Storage.sol";

/// Thrown if attempting to set the validator address to zero.
error ValidatorAddressCannotBeZero ();

/// Thrown if the signature provided by the validator is expired.
error SignatureExpired ();

/// Thrown if the signature provided by the validator is invalid.
error BadSignature ();

/// Thrown if attempting to recover a signature of invalid length.
error InvalidSignatureLength ();

/// Thrown if argument arrays length missmatched.
error LengthMismatch();

/**
	@custom:benediction DEVS BENEDICAT ET PROTEGAT CONTRACTVS MEAM
	@title GigaMart Royalty Manager
	@author Rostislav Khlebnikov <@catpic5buck>
	@custom:contributor Tim Clancy <@_Enoch>

	A contract for providing an EIP-712 signature-based approach for on-chain 
	direct royalty payments with royalty management as gated by an off-chain 
	validator.

	This approach to royalty management is a point of centralization on GigaMart. 
	The validator key gives its controller the ability to arbitrarily change 
	collection royalty fees.

	This approach is justified based on the fact that it allows GigaMart to offer 
	a gas-optimized middle ground where royalty fees are paid out directly to 
	collection owners while still allowing an arbitrary number of collection 
	administrators to manage collection royalty fees based on off-chain role 
	management semantics.
*/
contract RoyaltyManager is DomainAndTypehashes, ProtocolFeeManager {

	/** The public identifier for the right to change the validator address. 
			_VALIDATOR_SETTER = keccak256("VALIDATOR_SETTER");
	*/
	bytes32 private constant _VALIDATOR_SETTER = 
		0xab7922d407ee68907f3012689fc312513191a8f302400319928e871c6d39f8ec;
	

	/**  The EIP-712 typehash of a royalty update.
			keccak256(
	 			"Royalty(
						address setter,
						address collection,
						uint256 deadline,
						uint256 newRoyalties
					)"
			);
	*/
	bytes32 private constant _ROYALTY_TYPEHASH = 
		0xfb611fe2ee773273b2db591335adbd769558cf583a410ad6b83eb8860c37f0d7;

	/**  The EIP-712 typehash of a royalty update.
			keccak256(
	 			"Royalties(
						address setter,
						address[] collections,
						uint256 deadline,
						uint256[] newRoyalties
					)"
			);
	*/
	bytes32 private constant _MULTIPLE_ROYALTIES_TYPEHASH = 
		0xca8317744c36fb2eeb56f974afb6d5cd31ade90176dad0d7a06a624f10c09bdc;

	/**
		Emitted after altering the royalty fee of a collection.

		@param setter The address which altered the royalty fee.
		@param collection The collection which had its royalty fee altered.
		@param oldRoyalties The old royalty fee of the collection.
		@param newRoyalties The new royalty fee of the collection.
	*/
	event RoyaltyChanged (
		address indexed setter,
		address indexed collection,
		uint256 oldRoyalties,
		uint256 newRoyalties
	);

	/**
		Construct a new instance of the GigaMart royalty fee manager.

		@param _validator The address to use as the royalty change validation 
			signer.
		@param _protocolFeeRecipient The address which receives protocol fees.
		@param _protocolFeePercent The percent in basis points of the protocol fee.
	*/
	constructor (
		address _validator,
		address _protocolFeeRecipient,
		uint96 _protocolFeePercent
	) ProtocolFeeManager(_protocolFeeRecipient, _protocolFeePercent) {
		_setValidatorAddress(_validator);
	}

	/**
		Returns the current royalty fees of a collection.

		@param _collection The collection to return the royalty fees for.

		@return _ A tuple pairing the address of a collection fee recipient with 
			the actual royalty fee.
	*/
	function currentRoyalties (
		address _collection
	) external view returns (address, uint256) {
		uint256 fee = _getRoyalty(
			_collection,
			_getRoyaltyIndex(
				_collection
			)
		);

		// The fee is a packed address-fee pair into a single 256 bit integer.
		return (address(uint160(fee >> 96)), uint256(uint96(fee)));
	}

	/**
		Change the `validator` address.

		@param _validator The new `validator` address to set.

		@custom:throws ValidatorAddressCannotBeZero if attempting to set the 
			`validator` address to the zero address.
	*/
	function changeValidator (
		address _validator
	) external hasValidPermit(_UNIVERSAL, _VALIDATOR_SETTER) {
		if (_validator == address(0)) {
			revert ValidatorAddressCannotBeZero();
		}
		_setValidatorAddress(_validator);
	}

	/**
		Generate a hash from the royalty changing parameters.
		
		@param _setter The caller setting the royalty changes.
		@param _collection The address of the collection for which royalties will 
			be altered.
		@param _deadline The time when the `_setter` loses the right to alter 
			royalties.
		@param _newRoyalties The new royalty information to set.

		@return _ The hash of the royalty parameters for checking signature 
			validation.
	*/
	function _hash (
		address _setter,
		address _collection,
		uint256 _deadline,
		uint256 _newRoyalties
	) internal view returns (bytes32) {
		return keccak256(
			abi.encodePacked(
				"\x19\x01",
				_deriveDomainSeparator(),
				keccak256(
					abi.encode(
						_ROYALTY_TYPEHASH,
						_setter,
						_collection,
						_deadline,
						_newRoyalties
					)
				)
			)
		);
	}

	/**
		Generate a hash from the royalty changing parameters.
		
		@param _setter The caller setting the royalty changes.
		@param _collections The address of the collection for which royalties will 
			be altered.
		@param _deadline The time when the `_setter` loses the right to alter 
			royalties.
		@param _newRoyalties The new royalty information to set.

		@return _ The hash of the royalty parameters for checking signature 
			validation.
	*/
	function _hash (
		address _setter,
		address[] calldata _collections,
		uint256 _deadline,
		uint256[] calldata _newRoyalties
	) internal view returns (bytes32) {
		return keccak256(
			abi.encodePacked(
				"\x19\x01",
				_deriveDomainSeparator(),
				keccak256(
					abi.encode(
						_MULTIPLE_ROYALTIES_TYPEHASH,
						_setter,
						keccak256(
							abi.encodePacked(_collections)
						),
						_deadline,
						keccak256(
							abi.encodePacked(_newRoyalties)
						)
					)
				)
			)
		);
	}

	function indices (address _collection) public view returns(uint256) {
		return _getRoyaltyIndex(_collection);
	}
 
	/**
		Update the royalty mapping for a collection with a new royalty.

		@param _collection The address of the collection for which `_newRoyalties` 
			are set.
		@param _deadline The time until which the `_signature` is valid.
		@param _newRoyalties The updated royalties to set.
		@param _signature A signature signed by the `validator`.

		@custom:throws BadSignature if the signature submitted for setting 
			royalties is invalid.
		@custom:throws SignatureExpired if the signature is expired.
	*/
	function setRoyalties (
		address _collection,
		uint256 _deadline,
		uint256 _newRoyalties,
		bytes calldata _signature
	) external {

		// Verify that the signature was signed by the royalty validator.
		if (
			_recover(
				_hash(msg.sender, _collection, _deadline, _newRoyalties),
				_signature
			) != _getValidatorAddress()
		) {
			revert BadSignature();
		}

		// Verify that the signature has not expired.
		if (_deadline < block.timestamp) {
			revert SignatureExpired();
		}
		
		/*
			Increment the current royalty index for the collection and update its 
			royalty information.
		*/
		uint256 oldRoyalties = _getRoyalty(
			_collection,
			_getRoyaltyIndex(
				_collection
			)
		);
		_setRoyalty(
			_collection,
			_newRoyalties
		);

		// Emit an event notifying about the royalty change.
		emit RoyaltyChanged(
			msg.sender,
			_collection,
			oldRoyalties,
			_newRoyalties
		);
	}

	/**
		Update the royalty mapping for a collection with a new royalty.

		@param _collections The addresses of collections for which `_newRoyalties` 
			are set.
		@param _deadline The time until which the `_signature` is valid.
		@param _newRoyalties The updated royalties to set.
		@param _signature A signature signed by the `validator`.

		@custom:throws BadSignature if the signature submitted for setting 
			royalties is invalid.
		@custom:throws SignatureExpired if the signature is expired.
	*/
	function setMultipleRoyalties (
		address[] calldata _collections,
		uint256 _deadline,
		uint256[] calldata _newRoyalties,
		bytes calldata _signature
	) external {

		if (_newRoyalties.length != _collections.length) {
			revert LengthMismatch();
		}

		// Verify that the signature was signed by the royalty validator.
		if (
			_recover(
				_hash(msg.sender, _collections, _deadline, _newRoyalties),
				_signature
			) != _getValidatorAddress()
		) {
			revert BadSignature();
		}

		// Verify that the signature has not expired.
		if (_deadline < block.timestamp) {
			revert SignatureExpired();
		}

		for (uint256 i; i < _collections.length; ) {

			/*
				Increment the current royalty index for the collection and update its 
				royalty information.
			*/
			uint256 oldRoyalties = _getRoyalty(
				_collections[i],
				_getRoyaltyIndex(
					_collections[i]
				)
			);
			_setRoyalty(
				_collections[i],
				_newRoyalties[i]
			);

			// Emit an event notifying about the royalty change.
			emit RoyaltyChanged(
				msg.sender,
				_collections[i],
				oldRoyalties,
				_newRoyalties[i]
			);

			unchecked {
				++i;
			}
		}
	}
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.19;

import {
	MemoryPointer,
	ONE_WORD,
	TWO_WORDS,
	ZERO_MEMORY_SLOT
} from "./Helpers.sol";
/*
	This file contains functions for accessing the storage from other
	contract components w/o inheritance.
 */

// slot 0 is taken by ReentrancyGuard _status 
// slot 1 is taken by Ownable _owner
// slot 2 is taken by PermitControl permissions
// slot 3 is taken by PermitControl managerRight
uint256 constant ORDER_STATUS_SLOT = 4;

/**
	Reads and returns status of the order by `_hash`.

	@param _hash Hash of the order.

	@return status Status of the order.
*/
function _getOrderStatus (
	bytes32 _hash
) view returns(uint256 status) {
	assembly{
		// Store order hash in the first memory slot.
		mstore(ZERO_MEMORY_SLOT, _hash)
		// Store order status mapping storage slot in the second memory slot.
		mstore(add(ZERO_MEMORY_SLOT, ONE_WORD), ORDER_STATUS_SLOT)
		// Hash first two memory slots, and read storage at computed slot.
		status := sload(
			keccak256(ZERO_MEMORY_SLOT, TWO_WORDS)
		)
	}
}

/**
	Updates order status by `_hash`.

	@param _hash Hash of the order.
	@param _status New order status.
*/
function _setOrderStatus (
	bytes32 _hash,
	uint256 _status
) {
	assembly{
		// Store order hash in the first memory slot.
		mstore(ZERO_MEMORY_SLOT, _hash)
		// Store order status mapping storage slot in the second memory slot.
		mstore(add(ZERO_MEMORY_SLOT, ONE_WORD), ORDER_STATUS_SLOT)
		// Hash first two memory slots, and store new status in the computed slot.
		sstore(
			keccak256(ZERO_MEMORY_SLOT, TWO_WORDS),
			_status
		)
	}
}

uint256 constant PROTOCOL_FEE_SLOT = 5;

/**
	Returns protocol fee config (160 bits of add + 96 bits of fee percent).

	@return protocolFee Packed protocol fee config.
*/
function _getProtocolFee () view returns (uint256 protocolFee) {
	assembly{
		protocolFee := sload(PROTOCOL_FEE_SLOT)
	}
}

/**
	Updates protocol fee config.

	@param _protocolFee New protocol fee config.
*/
function _setProtocolFee (uint256 _protocolFee) {
	assembly {
		sstore(PROTOCOL_FEE_SLOT, _protocolFee)
	}
} 


uint256 constant ROYALTIES_SLOT = 6;

/**
	Reads and returns current royalty config 
	(160 bits of add + 96 bits of fee percent).

	@param _collection Address of the collection in question.
	@param _index Index, which was signed with the order.

	@return royalty royalty config.
*/
function _getRoyalty (
	address _collection,
	uint256 _index
) view returns (uint256 royalty) {
	assembly {
		// Store collection address in first memory slot.
		mstore(ZERO_MEMORY_SLOT, _collection)
		// Store slot of the royalties mapping in second memory slot.
		mstore(add(ZERO_MEMORY_SLOT, ONE_WORD), ROYALTIES_SLOT)
		// Hash first two memory slots.
		let nestedHash := keccak256(ZERO_MEMORY_SLOT, TWO_WORDS)
		// Store index in first memory slot.
		mstore(ZERO_MEMORY_SLOT, _index)
		// Store previosly computed hash in second memory slot.
		mstore(add(ZERO_MEMORY_SLOT, ONE_WORD), nestedHash)
		// Hash first two memory slots, and read storage at computed slot.
		royalty := sload(
			keccak256(ZERO_MEMORY_SLOT, TWO_WORDS)
		)
	}
}	

/**
	Updates royalty config for the collection. Increments royalty index by 1.

	@param _collection Address of the collection in question.
	@param _newRoyalty New royalty config.
*/
function _setRoyalty (
	address _collection,
	uint256 _newRoyalty
) {
	assembly{
		// Store collection address in the first memory slot
		mstore(ZERO_MEMORY_SLOT, _collection)
		// Store royalty indices mapping storage slot in the second memory slot.
		mstore(add(ZERO_MEMORY_SLOT, ONE_WORD), ROYALTY_INDICES_SLOT)
		// Hash first two memory slots, and read index at computed slot.
		let indexSlot := keccak256(ZERO_MEMORY_SLOT, TWO_WORDS)
		// Increment index
		let index := add(sload(indexSlot), 1)
		// Store incremented index value
		sstore(indexSlot, index)
		// Store royalties mapping storage slot in second memory slot.
		mstore(add(ZERO_MEMORY_SLOT, ONE_WORD), ROYALTIES_SLOT)
		// Collection address is still in the first memory slot.
		// Hash first two memory slots to compute nested mapping key.
		let nestedKey := keccak256(ZERO_MEMORY_SLOT, TWO_WORDS)
		// Store incremented index value in the first memory slot.
		mstore(ZERO_MEMORY_SLOT, index)
		// Store nested mapping key in the second memory slot
		mstore(add(ZERO_MEMORY_SLOT, ONE_WORD), nestedKey)
		// Hash first two memory slots, and store new royalty in the computed slot.
		sstore(
			keccak256(ZERO_MEMORY_SLOT, TWO_WORDS),
			_newRoyalty
		)
	}
}

uint256 constant ROYALTY_INDICES_SLOT = 7;

/**
	Reads and returns current royalty index for the collection.

	@param _collection address of the collection in question.

	@return index current royalty index of the `_collection`.
*/
function _getRoyaltyIndex (
	address _collection
) view returns (uint256 index) {
	assembly {
		// Store collection address in the first memory slot.
		mstore(ZERO_MEMORY_SLOT, _collection)
		// Store royalty indices mapping storage slot in the second memory slot.
		mstore(add(ZERO_MEMORY_SLOT, ONE_WORD), ROYALTY_INDICES_SLOT)
		// Hash first two memory slots, and read storage at computed slot.
		index := sload(
			keccak256(ZERO_MEMORY_SLOT, TWO_WORDS)
		)
	}
}

uint256 constant VALIDATOR_SLOT = 8;

/**
	Reads and returns validator address.

	@return validatorAddress Address of the royalty validator.
*/
function _getValidatorAddress () view returns (address validatorAddress) {
	assembly{
		validatorAddress := sload(VALIDATOR_SLOT)
	}
}

/**
	Sets new validator address.

	@param _validatorAddress New royalty validator address.
*/
function _setValidatorAddress (address _validatorAddress) {
	assembly {
		sstore(VALIDATOR_SLOT, _validatorAddress)
	}
} 

uint256 constant USER_NONCE_SLOT = 9;

/**
	Reads and returns user nonce.

	@param _user address of the user in question.

	@return nonce user nonce.
*/
function _getUserNonce (
	address _user
) view returns(uint256 nonce) {
	assembly {
		// Store user address in the first memory slot.
		mstore(ZERO_MEMORY_SLOT, _user)
		// Store nonce mapping storage slot in the second memory slot.
		mstore(add(ZERO_MEMORY_SLOT, ONE_WORD), USER_NONCE_SLOT)
		// Hash first two memory slots, and read storage at computed slot.
		nonce := sload(
			keccak256(ZERO_MEMORY_SLOT, TWO_WORDS)
		)
	}
}

/**
	Sets new value for the user nonce.

	@param _newNonce New user nonce value.
*/
function _setUserNonce (
	uint256 _newNonce
) {
	assembly{
		// Store msg.sender address in the first memory slot.
		mstore(ZERO_MEMORY_SLOT, caller())
		// Store nonce mapping storage slot in the second memory slot.
		mstore(add(ZERO_MEMORY_SLOT, ONE_WORD), USER_NONCE_SLOT)
		// Hash first two memory slots, and store new nonce in the computed slot.
		sstore(
			keccak256(ZERO_MEMORY_SLOT, TWO_WORDS),
			_newNonce
		)
	}
}

uint256 constant ORDER_FILL_AMOUNT_SLOT = 10;

/**
	Reads and returns current fill amount for the order by hash.

	@param _hash Hash of the order.

	@return amount previously filled amount for the order.
*/
function _getOrderFillAmount (
	bytes32 _hash
) view returns(uint256 amount) {
	assembly{
		// Store order hash in the first memory slot.
		mstore(ZERO_MEMORY_SLOT, _hash)
		// Store order fill amount mapping storage slot in the second memory slot.
		mstore(add(ZERO_MEMORY_SLOT, ONE_WORD), ORDER_FILL_AMOUNT_SLOT)
		// Hash first two memory slots, and read storage at computed slot.
		amount := sload(
			keccak256(ZERO_MEMORY_SLOT, TWO_WORDS)
		)
	}
}

/**
	Store order fill amount mapping storage slot in the second memory slot.

	@param _hash Hash of the order.
	@param _amount Updated order fill amount.
*/
function _setOrderFillAmount (
	bytes32 _hash,
	uint256 _amount
) {
	assembly{
		// Store order hash in the first memory slot.
		mstore(ZERO_MEMORY_SLOT, _hash)
		// Store order fill amount mapping storage slot in the second memory slot.
		mstore(add(ZERO_MEMORY_SLOT, ONE_WORD), ORDER_FILL_AMOUNT_SLOT)
		// Hash first two memory slots, and store new amount in the computed slot.
		sstore(
			keccak256(ZERO_MEMORY_SLOT, TWO_WORDS),
			_amount
		)
	}
}